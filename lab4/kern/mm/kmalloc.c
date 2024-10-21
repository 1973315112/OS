#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <assert.h>
#include <kmalloc.h>
#include <sync.h>
#include <pmm.h>
#include <stdio.h>

/*
 * SLOB Allocator: Simple List Of Blocks
 *
 * Matt Mackall <mpm@selenic.com> 12/30/03
 *
 * How SLOB works:
 *
 * The core of SLOB is a traditional K&R style heap allocator, with
 * support for returning aligned objects. The granularity of this
 * allocator is 8 bytes on x86, though it's perhaps possible to reduce
 * this to 4 if it's deemed worth the effort. The slob heap is a
 * singly-linked list of pages from __get_free_page, grown on demand
 * and allocation from the heap is currently first-fit.
 *
 * Above this is an implementation of kmalloc/kfree. Blocks returned
 * from kmalloc are 8-byte aligned and prepended with a 8-byte header.
 * If kmalloc is asked for objects of PAGE_SIZE or larger, it calls
 * __get_free_pages directly so that it can return page-aligned blocks
 * and keeps a linked list of such pages and their orders. These
 * objects are detected in kfree() by their page alignment.
 *
 * SLAB is emulated on top of SLOB by simply calling constructors and
 * destructors for every SLAB allocation. Objects are returned with
 * the 8-byte alignment unless the SLAB_MUST_HWCACHE_ALIGN flag is
 * set, in which case the low-level allocator will fragment blocks to
 * create the proper alignment. Again, objects of page-size or greater
 * are allocated by calling __get_free_pages. As SLAB objects know
 * their size, no separate size bookkeeping is necessary and there is
 * essentially no allocation space overhead.
 * 翻译:
 * SLOB分配器：简单的块列表
 * Matt Mackall <mpm@selenic.com> 12/30/03
 * SLOB的工作原理：
 * SLOB的核心是一个传统的K&R风格的堆分配器，支持返回对齐的对象。这个分配器在x86上的粒度是8字节，
 * 但如果认为值得的话，也许可以将其减少到4字节。slob堆是一个来自__get_free_page的页面单链表，
 * 根据需求增长并且保证从堆中分配是目前最合适的(currently first-fit,可能指best-fit算法)。
 *
 * 以下是kmalloc/kfree的实现。从kmalloc返回的块是8字节对齐的，并在前面加上8字节的头部。
 * 如果kmalloc被要求提供PAGE_SIZE或更大的对象，它会直接调用__get_free_pages，
 * 这样它就可以返回与页面对齐的块，并保留这些页面及其顺序的链表。
 * 这些对象在kfree（）中通过其页面对齐方式进行检测。
 *
 * SLAB是基于SLOB的，只需为每个SLAB分配调用构造函数和析构函数即可。除非设置了SLAB_MUST_HWCACHE_ALIGN标志，
 * 否则对象将以8字节对齐返回，在这种情况下，低级分配器将对块进行分段以创建正确的对齐。
 * 同样，页面大小或更大的对象是通过调用__get_free_pages来分配的。
 * 由于SLAB对象知道它们的大小，因此不需要单独的大小记账，基本上也没有分配空间开销。
 */


//some helper
#define spin_lock_irqsave(l, f) local_intr_save(f)
#define spin_unlock_irqrestore(l, f) local_intr_restore(f)
// gfp_t是位掩码，用于表示内存分配的各种选项和限制。
// 通常作为参数传递给内存分配函数，以指定所需的内存分配行为。
// 这些标志可以用来指定内存分配的类型，范围，策略和目的等。
typedef unsigned int gfp_t;

// 设置页面大小为4096Byte
#ifndef PAGE_SIZE
#define PAGE_SIZE PGSIZE 
#endif

#ifndef L1_CACHE_BYTES
#define L1_CACHE_BYTES 64
#endif

// 将给定的地址addr向上调整到最近的size的倍数
#ifndef ALIGN
#define ALIGN(addr,size)   (((addr)+(size)-1)&(~((size)-1)))  
#endif

/*
 * 功能:slob分配器管理的单向链表节点(<1页)
 * 变量:
 * 		@units:可能表示能够存储的字节数。
 *		@next :链表指针，指向下一个节点
 */
struct slob_block 
{
	int units;
	struct slob_block *next;
};
typedef struct slob_block slob_t;


#define SLOB_UNIT sizeof(slob_t)								// 将SLOB_UNIT设为16Byte(可能与内存对其相关)
#define SLOB_UNITS(size) (((size) + SLOB_UNIT - 1)/SLOB_UNIT)   // 将size从以Byte为单位转换为以<SLOB_UNIT的数量>为单位，即需要几个<SLOB_UNIT>(16Byte)
#define SLOB_ALIGN L1_CACHE_BYTES

/*
 * 功能:slob分配器管理的单向链表节点(>=1页)
 * 变量:
 * 		@order:可能用于表示内存块的大小(以页为单位，以2的幂次方大小表示)。
 * 		@pages:可能指向连续页的开头
 * 		@next :链表指针，指向下一个节点
 */
struct bigblock 
{
	int order;
	void *pages;
	struct bigblock *next;
};
typedef struct bigblock bigblock_t;

static slob_t arena = { .next = &arena, .units = 1 };
static slob_t *slobfree = &arena;		// slob分配器单链表的头节点(小 于1页)
static bigblock_t *bigblocks;			// slob分配器单链表的头节点(大等于1页，插入时使用类似链式前向星的方法)

/*
 * 功能:slob分配器请求分配虚拟页
 * 参数:
 *		@gfp  :位掩码，用于表示内存分配的各种选项和限制(这里可能一般为0)
 *		@order:可能用于表示内存块的大小(以页为单位，以2的幂次方大小表示)。
 */
static void* __slob_get_free_pages(gfp_t gfp, int order)
{
  struct Page * page = alloc_pages(1 << order);
  if(!page) return NULL;
  return page2kva(page);
}

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

/*
 * 功能:使用slob分配器释放页
 * 参数:
 *		@kva:
 *		@order:释放页的大小(以2的幂次方大小表示)。
 */
static inline void __slob_free_pages(unsigned long kva, int order)
{
	free_pages(kva2page(kva), 1 << order);
}

static void slob_free(void *b, int size);

/*
 * 功能:使用slob分配器分配内存
 * 参数:
 *		@size :请求分配的内存的大小(包括首部)
 *		@gfp  :位掩码，用于表示内存分配的各种选项和限制(这里可能一般为0)
 *		@align:指定分配的内存块需要对齐的边界(这里可能一般为0)
 */
static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
	assert( (size + SLOB_UNIT) < PAGE_SIZE ); // 困惑

	slob_t *prev, *cur, *aligned = 0;
	int delta = 0, units = SLOB_UNITS(size);
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) // 遍历链表
	{
		if (align) 
		{
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
			delta = aligned - cur;
		}
		if (cur->units >= units + delta) // 检查这一块的大小是否足够(/* room enough? */)
		{ 
			if (delta) // 将这一块拆成delta和units-delta的两块(/* need to fragment head to align? */)
			{ 
				aligned->units = cur->units - delta;
				aligned->next = cur->next;
				cur->next = aligned;
				cur->units = delta;
				prev = cur;
				cur = aligned;
			}

			if (cur->units == units) prev->next = cur->next; //如果这块的大小非常合适(/* exact fit? */)，那么从链表中取下(/* unlink */)
			else //如果这块的大小不是恰好合适(/* fragment */)，进行拆分
			{ 
				prev->next = cur + units;
				prev->next->units = cur->units - units;
				prev->next->next = cur->next;
				cur->units = units;
			}

			slobfree = prev; // 改变头节点(困惑)
			spin_unlock_irqrestore(&slob_lock, flags);
			return cur;
		}
		if (cur == slobfree) // 如果没有可用的
		{
			spin_unlock_irqrestore(&slob_lock, flags);

			if (size == PAGE_SIZE) /* trying to shrink arena? */
				return 0;

			cur = (slob_t *)__slob_get_free_page(gfp);
			if (!cur)
				return 0;

			slob_free(cur, PAGE_SIZE);
			spin_lock_irqsave(&slob_lock, flags);
			cur = slobfree;
		}
	}
}

/*
 * 功能:使用slob分配器释放内存
 * 参数:
 * 		@block:slob单链表的节点
 *		@size :请求分配的内存的大小
 */
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block) return;

	if (size) b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next) // 遍历链表，当b的地址在cur和cur—>next的中间时退出
	{
		//如果已经到链表的最后(此时cur是地址最大的，cur->next是地址最小的)，并且b的地址比cur大或者比cur->next小(这意味着b是最大的或者最小的)
		if (cur >= cur->next && (b > cur || b < cur->next)) break; // 
	}

	if (b + b->units == cur->next) // 如果b可以合并后一块 
	{
		b->units += cur->next->units;
		b->next = cur->next->next;
	} 
	else b->next = cur->next;

	if (cur + cur->units == b) // 如果b可以合并前一块 
	{
		cur->units += b->units;
		cur->next = b->next;
	} 
	else cur->next = b;

	slobfree = cur;

	spin_unlock_irqrestore(&slob_lock, flags);
}


/*
 * 功能:初始化slob内存分配(实际上只打印了"use SLOB allocator\n")
 */
void slob_init(void) 
{
  cprintf("use SLOB allocator\n");
}

/*
 * 功能:初始化内存分配
 * 注意:这是初始化对外的接口
 */
inline void kmalloc_init(void) 
{
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}

size_t slob_allocated(void) {
  return 0;
}

size_t kallocated(void) {
   return slob_allocated();
}

/*
 * 功能:将以Byte为单位的size转换为以<2的幂次页>为单位i的order(上取整)
 * 参数:
 *     @size:请求分配的内存的大小
 */
static int find_order(int size)
{
	int order = 0;
	for ( ; size > 4096 ; size >>=1)
	{
		order++;
	}		
	return order;
}

/*
 * 功能:分配内存
 * 参数:
 *     @size:请求分配的内存的大小
 *     @gfp :位掩码，用于表示内存分配的各种选项和限制。(这里可能一般为0)
 */
static void *__kmalloc(size_t size, gfp_t gfp)
{
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) // 如果小于1页(包括头部)
	{
		m = slob_alloc(size + SLOB_UNIT, gfp, 0); 	// 使用slob分配器分配内存
		return m ? (void *)(m + 1) : 0;				// 如果分配到了返回指针，否则返回NULL
	}

	// 如果大等于1页(包括头部)
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);	// 使用slob分配器分配一个单向链表节点(>=1页)
	if (!bb) return 0;

	bb->order = find_order(size);
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);

	if (bb->pages) 
	{
		spin_lock_irqsave(&block_lock, flags);
		bb->next = bigblocks;
		bigblocks = bb;
		spin_unlock_irqrestore(&block_lock, flags);
		return bb->pages;
	}

	slob_free(bb, sizeof(bigblock_t));
	return 0;
}

/*
 * 功能:分配内存
 * 参数:
 *     @size:请求分配的内存的大小
 * 注意:这是分配内存对外的接口
 */
void* kmalloc(size_t size)
{
  return __kmalloc(size, 0);
}

/*
 * 功能:释放内存
 * 参数:
 *     @block:请求释放的地址的指针
 * 注意:这是释放内存对外的接口
 */
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block) return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) // 如果是与页对齐的(即可能为按页分配的)
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) // 遍历链表(似乎尾节点缺乏显示初始化为NULL)
		{
			if (bb->pages == block) // 如果在链表里
			{
				*last = bb->next;
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0); // 释放小于1页的
	return;
}


unsigned int ksize(const void *block)
{
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
		return 0;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; bb = bb->next)
			if (bb->pages == block) {
				spin_unlock_irqrestore(&slob_lock, flags);
				return PAGE_SIZE << bb->order;
			}
		spin_unlock_irqrestore(&block_lock, flags);
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
}



