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


#define SLOB_UNIT sizeof(slob_t)								// 将SLOB_UNIT设为16Byte(可能与内存对齐相关)
#define SLOB_UNITS(size) (((size) + SLOB_UNIT - 1)/SLOB_UNIT)   // 将size从以Byte为单位转换为以<SLOB_UNIT的数量>为单位，即需要几个<SLOB_UNIT>(16Byte)
#define SLOB_ALIGN L1_CACHE_BYTES

/*
 * 功能:单向链表节点(>=1页)
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
static bigblock_t *bigblocks;			// 单链表的头节点(大等于1页，插入时使用类似链式前向星的方法)

//################################################################################
/*LAB2 扩展练习Challenge 任意大小的内存单元slub分配算法: 2213917 CODE*/
//slub分配算法相关的结构体，宏定义和全局变量，
/*
 * 考虑到slub分配算法相关的结构体关系复杂，我们在此对其进行命名和包含关系说明。
 * slub_t[] Slubs:slub内存管理器组，可以管理小于一页物理页的内存分配和释放
 *     slub_t slub:slub内存管理器,可以管理一种固定大小的内存分配和释放
 *         slub_cache_waiting wait:slub内存管理器的等待缓冲区
 *             	object* partial :等待缓冲区的半空闲状态的物理页链表
 *          	object* full    :等待缓冲区的忙碌状态的物理页链表
 *         slub_cache_working work:slub内存管理器的工作缓冲区
 *              object* freelist:工作缓冲区的物理页
 * 
 * partial/full/freelist
 * 均维护连续物理页(在我们的程序中均为1页)链表
 * 不同物理页依靠next_head组成链表(节点为连续物理页)
 * 相同物理页的空闲内存块依靠state.next_free组成链表(节点为空闲内存块)
 */

struct object;
typedef struct object object;

/*
 * 功能:聚合类型,在空闲内存块和忙碌内存块提供不同的功能
 * 变量:
 * 		@next_free	:作为空闲内存块链表的链条
 * 		@size		:记录空闲内存块大小(包括首部,方便还原)
 */
union State 
{
    object *next_free;  
    size_t size;
};  
typedef union State State;

/*
 * 功能:内存块节点(内存块的首部)
 * 变量:
 * 		@state	  	:聚合类型,在空闲内存块和忙碌内存块提供不同的功能
 * 		@nfree    	:记录当前连续物理页的空闲内存块数量
 * 		@first_free	:指向当前连续物理页的第一个空闲内存块的指针
 *		@next_head 	:指向下一个连续物理页第一块的单向链表的指针
 * 注意:object有三种实例
 * 		1.连续物理页的第一块 :启用nfree,first_free,next_head
 *      2.空闲内存块		:启用next_free作为链表的链条
 * 		3.忙碌内存块		:启用next_free记录内存块大小(包括首部,方便还原)
 * 注意:object大小为32Bytes，所以当使用小于64Bytes时(int[16],long long[32]时建议直接适当调大，静态声明)（待优化）
 */
struct object 
{
	State   state;
	size_t  nfree;
	object* first_free;
	object* next_head;
};

/*
 * 功能:slub内存管理器的等待缓冲区
 * 变量:
 * 		@nr_partial	:半空闲状态的物理页链表的数量
 *		@nr_slabs 	:物理页链表的数量(在我们的程序中没有功能性作用,可能是辅助判断内存分配状态的)
 *		@partial 	:半空闲状态的物理页链表
 *		@block   	:忙碌状态的物理页链表
 * 注意:这个结构体与参考资料中的<kmem_cache_node>相同
 */
struct slub_cache_waiting
{
	size_t nr_partial;
	size_t nr_slabs;
	object* partial;
	object* full;
};

/*
 * 功能:slub内存管理器的工作缓冲区
 * 变量:
 *		@pages   	:正在使用的连续物理页的首地址 
 *		@freelist 	:正在使用的连续物理页的首个空闲块
 *		参考资料中还有其他变量(困惑)
 * 注意:这个结构体与参考资料中的<kmem_cache_cpu>相同
 */
struct slub_cache_working
{
	void*   pages;
	object* freelist;
};

/*
 * 功能:slub内存管理器,可以管理一种固定大小的内存分配和释放
 * 变量:
 *		@size 		:slub分配器管理的块大小(包括头部，为2^n)
 *		@obj_size 	:slub分配器管理的块大小(不包括头部) 
 *		@wait   	:slub分配器管理处于等待状态的slab分配器的缓存
 *		@work		:slub分配器管理处于使用状态的slab分配器的缓存
 *		参考资料中还有其他变量(困惑)
 * 注意:这个结构体与参考资料中的<kmem_cache>相同
 */
struct slub_t
{
	size_t size;
	size_t obj_size;
	struct slub_cache_waiting  wait;
	struct slub_cache_working  work;
};
typedef struct slub_t slub_t;


// 使用slob还是slub内存管理器
#define USING_SLOB 0
#define USING_SLUB 1

// slub管理器数组大小为6，对应64,128,256,512,1024,2048 Byte
// 注意:
//     1.object大小为32Bytes，所以可以管理的最小内存应大于32Bytes(待优化)
//     2.可以支持更多的内存(包括非2^n的情况)(待优化)
#define Slubs_size 6				// slub管理器数组大小
#define Slubs_min_order 6			// slub管理器最小的内存(包括头部)的大小(以2的n次幂为单位)
#define SLUB_UNIT sizeof(object)	// 将SLUB_UNIT设为32Byte

//静态声明的变量会在栈中分配内存
slub_t Slubs[Slubs_size]; //这个变量与参考资料中的<kmalloc_caches>相同
//################################################################################

/*
 * 功能:slob分配器请求分配虚拟页
 * 参数:
 *		@gfp  :位掩码，用于表示内存分配的各种选项和限制(这里可能一般为0)
 *		@order:可能用于表示内存块的大小(以页为单位，以2的幂次方大小表示,这里可能一般为0)。
 */
static void* __slob_get_free_pages(gfp_t gfp, int order)
{
  struct Page * page = alloc_pages(1 << order);
  if(!page) return NULL;
  return page2kva(page);
}

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

/*
 * 功能:使用释放页(通用函数，与slob无关)
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
			if (!cur) return 0;

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
		if (cur >= cur->next && (b > cur || b < cur->next)) break; 
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
 * 功能:初始化slob内存管理器(实际上只打印了"use SLOB allocator\n")
 */
void slob_init(void) 
{
  cprintf("use SLOB allocator\n");
}


//################################################################################
/*LAB2 扩展练习Challenge 任意大小的内存单元slub分配算法: 2213917 CODE*/
//在这里完成支持slub版本的void *kmalloc(size_t n)，和void kfree(void *objp)的辅助函数

static void kmalloc_check(void);

/*
 * 功能:初始化slub内存管理器
 */
void slub_init(void) 
{
	//cprintf("[调试信息]进入slub_init()\n");
	cprintf("use SLUB allocator\n");
	for(int i=0,size=(1<<Slubs_min_order);i<Slubs_size;i++,size=(size<<1)) // 遍历初始化Slubs
	{
		// 初始化slub
		Slubs[i].size            = size;
		Slubs[i].obj_size        = size-SLUB_UNIT;
		// 初始化内存管理器的等待缓冲区
		Slubs[i].wait.nr_partial = 0;
		Slubs[i].wait.nr_slabs   = 0;
		Slubs[i].wait.partial    = NULL;
		Slubs[i].wait.full       = NULL;
		// 初始化内存管理器的工作缓冲区
		Slubs[i].work.freelist   = NULL;
		Slubs[i].work.pages 	 = NULL;
	}
	//cprintf("[调试信息]退出slub_init()\n");
	kmalloc_check();
}

/*
 * 功能:将n向上变为2的幂
 * 参数：
 * @n:      待转换的数
 */
static size_t up_to_2_power(size_t n) 
{
    assert(n > 0);
    n--; 
    n |= n >> 1;  
    n |= n >> 2;  
    n |= n >> 4;  
    n |= n >> 8;  
    n |= n >> 16;
    n |= n >> 32;  
    n++;
    return n;  
}

/*
 * 功能:n=2^m次幂，求m
 * 参数：
 * @n:      2^m次幂(n>0)
 */
static size_t log2(size_t n) 
{
	assert(n > 0);
    size_t m = -1;
	while(n>0)
	{
		n=(n>>1);
		m++;
	}
    return m;  
}

/*
 * 功能:使用slub分配器分配内存
 * 参数:
 *		@size :请求分配的内存的大小(包括首部，因此>=16,且已规范为2^n）
 *		@gfp  :位掩码，用于表示内存分配的各种选项和限制(这里可能一般为0)
 *		@align:指定分配的内存块需要对齐的边界(这里可能一般为0)
 * 注意:暂时未考虑对齐问题(待改进)
 */
static void* slub_alloc(size_t size, gfp_t gfp, int align)
{
	//cprintf("[调试信息]进入slub_alloc()\n");
	assert(size < PAGE_SIZE);
//----------------------------变量声明----------------------------
	slub_t* slub      = Slubs+(log2(size)-Slubs_min_order); // 获取对应的slub
	size_t  slub_size = slub->size;					        // 当前slub管理的size大小	
	object* cur       = NULL;								// 正在处理的object节点(最终作为返回值)
	object* page      = NULL;						   		// slub工作缓冲区的物理页
	unsigned long flags = 0;								// 自旋锁参数
	struct slub_cache_waiting*  wait = &(slub->wait);  		// slub内存管理器的等待缓冲区
	struct slub_cache_working*  work = &(slub->work);  		// slub内存管理器的工作缓冲区
//----------------------------上锁----------------------------
	spin_lock_irqsave(&slob_lock, flags);
//----------------------------工作缓冲区缺失----------------------------
	if(work->freelist == NULL)
	{
		//cprintf("[调试信息]工作缓冲区缺失\n");
//----------------------------等待缓冲区partial链表非空:将partial的一个物理页节点转移到工作区----------------------------	
		if(wait->nr_partial > 0)
		{
			//cprintf("[调试信息]等待缓冲区partial链表非空\n");
			// 处理partial链表(围绕取下的cur物理页节点)
			cur = wait->partial;
			wait->partial  = cur->next_head;
			cur->next_head = NULL;
			// 处理等待缓冲区
			wait->nr_partial--;
			wait->nr_slabs  --;
			// 处理工作缓冲区
			work->pages    = (void*)cur;
			work->freelist = cur->first_free;
		}
//----------------------------等待缓冲区partial链表为空:获取新页面生成物理页节点----------------------------
		else
		{
			//cprintf("[调试信息]等待缓冲区partial链表为空\n");
			cur = (object *)__slob_get_free_page(gfp); // 分配一页内存(可以通用，和slob无关)
			//cprintf("[调试信息]新页面地址为%x\n",cur);
			if (!cur) 
			{
//----------------------------解锁----------------------------
				spin_unlock_irqrestore(&slob_lock, flags);
				//cprintf("[调试信息]分配页面失败,分配内存失败\n");
				return 0;
			}
			// 处理空闲内存块节点
			for(void *prev = (void*)cur,*now = prev+slub_size,*finish = prev+PAGE_SIZE; now<finish ; prev = now,now += slub_size)
			{
				((object*)prev)->state.next_free = now;
			}
			((object*)(((void*)cur)+PAGE_SIZE-slub_size))->state.next_free = NULL;
			// 处理连续物理页节点
			cur->nfree      = PAGE_SIZE/slub_size;
			cur->next_head  = NULL;
			cur->first_free = cur;
			// 处理工作缓冲区
			work->pages     = (void*)cur;
			work->freelist  = cur;
		}		
	}
//----------------------------工作缓冲区非空:获取空闲内存块(现在可以保证工作区非空)----------------------------
	assert(work->freelist != NULL);
	//cprintf("[调试信息]工作缓冲区非空\n");
	page = (object*)work->pages;   		// slub工作缓冲区的物理页
	// 处理freelist链表的空闲内存块链表(围绕取下的cur空闲内存块节点)
	cur = work->freelist;
	work->freelist = work->freelist->state.next_free;
	// 处理连续物理页节点
	page->nfree--;
	page->first_free = work->freelist;  //可以考虑注释这一行，改为将page->nfree==0时直接设为NULL(因为没有维护的必要)	
	// 处理取下的cur空闲内存块节点
	cur->state.size = slub_size; // 当内存块节点使用时，使用其state.size记录大小以便释放
//----------------------------连续物理页节点已满:将工作区物理页节点转移到等待缓冲区full链表----------------------------
	if(page->nfree==0) 
	{
		//cprintf("[调试信息]连续物理页节点已满\n");
		//page->first_free = NULL;
		assert(work->freelist==NULL && page->first_free==NULL);
		// 处理连续物理页节点
		page->next_head = wait->full;
		// 处理等待缓冲区
		wait->nr_slabs++;
		wait->full = page;	
		// 处理工作缓冲区
		work->pages    = NULL;
		//work->freelist = NULL;
	}
//----------------------------解锁----------------------------
	spin_unlock_irqrestore(&slob_lock, flags);
	//cprintf("[调试信息]退出slub_alloc(),分配的内存地址为%x\n",cur);
	return cur;
}

/*
 * 功能:使用slub分配器释放内存
 * 参数:
 * 		@block:slob单链表的节点
 *		@size :请求释放的内存的大小 
 * 注意:目前当一页为空时会被立即释放，可能影响效率（有待改进）
 */
static void slub_free(void* block, int size)
{
	//cprintf("[调试信息]进入slub_free(),释放的内存地址为%x,请求释放的内存的大小为%d\n",block,size);
	if (!block) return;
//----------------------------变量声明----------------------------
	slub_t* slub      = Slubs+(log2(size)-Slubs_min_order);	// 获取对应的slub
	size_t slub_size                 = slub->size;			// 当前slub管理的size大小	
	object* b = (object *)block;							// 需要释放的object节点
	unsigned long flags = 0;								// 自旋锁参数
	struct slub_cache_waiting*  wait = &(slub->wait);	    // slub内存管理器的等待缓冲区
	struct slub_cache_working*  work = &(slub->work);       // slub内存管理器的工作缓冲区
	object* page                =(object*)work->pages;		// slub工作缓冲区的物理页
//----------------------------上锁----------------------------
	spin_lock_irqsave(&slob_lock, flags);
//----------------------------尝试释放到工作缓冲区----------------------------
	//cprintf("[调试信息]尝试释放到工作缓冲区\n");
	if( page!=NULL && page<=block && block<(work->pages+PAGE_SIZE) ) 
	{
		//cprintf("[调试信息]释放到工作缓冲区\n");
		// 处理需要释放的object节点
		b->state.next_free = work->freelist;
		// 处理工作缓冲区
		work->freelist = b;
		// 处理连续物理页节点
		page->nfree++;
//----------------------------如果空了，需要释放物理页----------------------------
		if(page->nfree*slub_size==PAGE_SIZE)
		{
			//cprintf("[调试信息]释放物理页\n");
			__slob_free_pages((unsigned long)page,0);
			// 处理工作缓冲区
			work->freelist = NULL;
			work->pages    = NULL;
		}
//----------------------------解锁----------------------------
		spin_unlock_irqrestore(&slob_lock, flags);
		return;
	}
//----------------------------尝试释放到等待缓冲区的full链表----------------------------
	//cprintf("[调试信息]尝试释放到等待缓冲区的full链表\n");
	for(object *prev=NULL,*cur=wait->full;cur!=NULL;prev=cur,cur=cur->next_head)
	{
		if(cur<=block && block<(((void*)cur)+PAGE_SIZE))
		{
			//cprintf("[调试信息]释放到等待缓冲区的full链表\n");
			// 处理需要释放的object节点(cur->first_free预期为NULL,所以也可以直接设为NULL)
			assert(cur->first_free==NULL);
			b->state.next_free = cur->first_free;
			// 处理连续物理页节点
			cur->first_free = b;
			cur->nfree++;
			// 处理等待缓冲区
			wait->nr_partial++;
			// 将b插入到prev和cur之间
			// 处理等待缓冲区的full链表
			if(prev==NULL) wait->full      = cur->next_head; //cur为第一个的情况
			else           prev->next_head = cur->next_head;
			// 处理等待缓冲区的partial链表
			cur->next_head = wait->partial;
			wait->partial  = cur;
//----------------------------解锁----------------------------
			spin_unlock_irqrestore(&slob_lock, flags);
			return;
		}
	}
//----------------------------尝试释放到等待缓冲区的partial链表----------------------------
	//cprintf("[调试信息]尝试释放到等待缓冲区的partial链表\n");
	for(object *prev=NULL,*cur=wait->partial;cur!=NULL;prev=cur,cur=cur->next_head)
	{
		if(cur<=block && block<(((void*)cur)+PAGE_SIZE))
		{
			//cprintf("[调试信息]释放到等待缓冲区的partial链表\n");
			// 处理需要释放的object节点
			b->state.next_free = cur->first_free;
			// 处理连续物理页节点
			cur->first_free = b;
			cur->nfree++;
//----------------------------如果空了，需要释放物理页----------------------------
			if(cur->nfree*slub_size==PAGE_SIZE)
			{
				//cprintf("[调试信息]释放物理页\n");
				// 处理等待缓冲区的partial链表
				if(prev==NULL) wait->partial   = cur->next_head; //cur为第一个的情况
				else           prev->next_head = cur->next_head;
				__slob_free_pages((unsigned long)cur,0);
				// 处理等待缓冲区
				wait->nr_partial--;
				wait->nr_slabs  --;
			}	
//----------------------------解锁----------------------------
			spin_unlock_irqrestore(&slob_lock, flags);
			return;
		}
	}	
//----------------------------解锁(原则上不会到这，以防万一)----------------------------
	spin_unlock_irqrestore(&slob_lock, flags);
	return;
}

/*
 * 功能:打印管理结构相关内容
 */
void print_struct(int i,int time)
{
	return;
	size_t j=0,k=0;
	cprintf("\n管理结构相关内容即将第%d次打印\n",time);
	cprintf("  Slubs[%d]相关内容即将打印\n",i);
	cprintf("    Slubs[%d].size   =%d\n",i,Slubs[i].size);
	cprintf("    Slubs[%d].objsize=%d\n",i,Slubs[i].obj_size);
	cprintf("    Slubs[%d].wait相关内容即将打印\n",i);
	cprintf("      Slubs[%d].wait.nr_partial=%d\n",i,Slubs[i].wait.nr_partial);
	cprintf("      Slubs[%d].wait.nr_slab   =%d\n",i,Slubs[i].wait.nr_slabs);
	cprintf("      Slubs[%d].wait.partial相关内容即将打印\n",i);
	if(Slubs[i].wait.partial==NULL)  cprintf("        Slubs[%d].wait.partial(半空闲区)为空\n",i);
	j=0;
	for(object* cur_slab = Slubs[i].wait.partial;cur_slab != NULL;cur_slab = cur_slab->next_head,j++)
	{
		cprintf("        Slubs[%d].wait.partial node[%d]->nfree=%d\n",i,j,cur_slab->nfree);
		k=0;
		for(object* cur_slob = cur_slab->first_free;cur_slob!=NULL;cur_slob = cur_slob->state.next_free,k++)
		{
			cprintf("          Slubs[%d].wait.partial node[%d][%d] address=%x\n",i,j,k,cur_slob);
		}
	}
	cprintf("      Slubs[%d].wait.full相关内容即将打印\n",i);
	if(Slubs[i].wait.full==NULL)  cprintf("        Slubs[%d].wait.full(忙碌区)为空\n",i);
	j=0;
	for(object* cur_slab = Slubs[i].wait.full;cur_slab != NULL;cur_slab = cur_slab->next_head,j++)
	{
		cprintf("        Slubs[%d].wait.full node[%d] address=%x\n",i,j,cur_slab);
		cprintf("        Slubs[%d].wait.full node[%d]->nfree=%d\n",i,j,cur_slab->nfree);
	}		
	cprintf("    Slubs[%d].work相关内容即将打印\n",i);
	object* cur_slab = Slubs[i].work.pages;
	if(cur_slab==NULL)  cprintf("      Slubs[%d].work.pages(工作区)为空\n",i);
	else 
	{
		cprintf("      Slubs[%d].work.pages相关内容即将打印\n",i);
		cprintf("        Slubs[%d].work.pages->nfree=%d\n",i,cur_slab->nfree);
		cprintf("      Slubs[%d].work.freelist相关内容即将打印\n",i);
		j=0;
		for(object* cur_slob = Slubs[i].work.freelist;cur_slob!=NULL;cur_slob = cur_slob->state.next_free,j++)
		{			
			cprintf("        Slubs[%d].work.freelist node[%d] address=%x\n",i,j,cur_slob);
		}		
	}
	cprintf("  大等于1个物理页面相关内容即将打印\n");
	if(bigblocks==NULL) cprintf("  bigblocks为空\n");
	else
	{
		i=0;
		for(bigblock_t* cur=bigblocks;cur!=NULL;cur=cur->next,i++)
		{
			cprintf("    bigblocks node[%d]->pages=%x\n",i,cur->pages);
			cprintf("    bigblocks node[%d]->order=%d\n",i,cur->order);				
		}
	}
	cprintf("管理结构相关内容结束打印\n\n");
}

/*
 * 功能:slub内存管理器的启动自检程序
 */
static void kmalloc_check(void) 
{

	// kmalloc(900); //期望分配1024Byte的块(包括头部)
	void *x1,*x2,*x3,*x4;
	void *y1,*y2,*y3,*y4;
	size_t size = 900;
	size_t big_size = 4096;
	size_t up_size = up_to_2_power(size+SLUB_UNIT);
	size_t i = log2(up_size)-Slubs_min_order;
	cprintf("################################################################################\n");
	cprintf("[自检程序]启动slub内存管理器的启动自检程序\n");
	//cprintf("size=%d,up_size=%d,i=%d\n",size,up_size,i);
	print_struct(i,1);	  	// 第1次打印
	assert(Slubs[i].size==up_size && size<=Slubs[i].obj_size);
	x1 = kmalloc(size);		// 冷启动分配(从新物理页）
	print_struct(i,2);		// 第2次打印
	assert(Slubs[i].work.pages!=NULL);
	x2 = kmalloc(size);		// 工作区分配
	print_struct(i,3);		// 第3次打印
	x3 = kmalloc(size);		// 工作区分配
	x4 = kmalloc(size);		// 工作区分配后为满(放入等待区full链表)
	print_struct(i,4);		// 第4次打印
	assert(x1+up_size==x2&&x2+up_size==x3&&x3+up_size==x4);
	//assert(Slubs[i].work.pages==NULL);
	//assert(Slubs[i].wait.full!=NULL);
	y1 = kmalloc(size);		// 工作区为空分配(从新物理页）
	print_struct(i,5);		// 第5次打印
	//assert(Slubs[i].work.pages!=NULL);
	kfree(y1);				// 工作区释放后为空(释放物理页）
	print_struct(i,6);		// 第6次打印
	//assert(Slubs[i].work.pages==NULL);
	y1 = kmalloc(size);		// 工作区分配(从新物理页）
	y2 = kmalloc(size);		// 工作区分配
	y3 = kmalloc(size);		// 工作区分配	
	y4 = kmalloc(size);		// 工作区分配后为满(放入等待区full链表)
	assert(y1+up_size==y2&&y2+up_size==y3&&y3+up_size==y4);
	kfree(y1);				// 等待区full链表释放(放入等待区partial链表)
	print_struct(i,7);		// 第7次打印
	//assert(Slubs[i].wait.partial!=NULL);
	kfree(x1);				// 等待区full链表释放(放入等待区partial链表)
	kfree(x2);				// 等待区partial链表释放
	print_struct(i,8);		// 第8次打印
	kfree(x3);				// 等待区partial链表释放
	kfree(x4);				// 等待区partial链表释放为空(释放物理页）
	print_struct(i,9);		// 第9次打印(y2,y3,y4)
	kfree(y2);				// 等待区full链表释放(放入等待区partial链表)
	y2 = kmalloc(size);		// 工作区为空分配(从等待区partial链表分配)
	print_struct(i,10);		// 第10次打印(y3,y4)
	//assert(Slubs[i].work.pages!=NULL);
	kfree(y2);				// 工作区释放                                                     
	kfree(y3);				// 工作区释放
	kfree(y4);				// 工作区释放后为空(释放物理页）
	assert(Slubs[i].work.pages==NULL);
	print_struct(i,11);		// 第11次打印
	x1 = kmalloc(big_size);
	print_struct(0,12);		// 第12次打印
	kfree(x1);
	print_struct(0,13);		// 第13次打印
	x1 = kmalloc(big_size);
	x2 = kmalloc(big_size);
	x3 = kmalloc(2*big_size);
	x4 = kmalloc(20*big_size);
	print_struct(0,14);		// 第14次打印
	kfree(x1);
	kfree(x2);
	kfree(x3);
	kfree(x4);
	print_struct(0,15);		// 第15次打印
	cprintf("[自检程序]退出slub内存管理器的启动自检程序\n");
	cprintf("[自检程序]slub内存管理器的工作正常\n");
	cprintf("################################################################################\n");
}
//################################################################################



/*
 * 功能:初始化内存分配
 * 注意:这是初始化对外的接口
 */
inline void kmalloc_init(void) 
{
    if(USING_SLOB) slob_init();
	if(USING_SLUB) slub_init();
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
	if(size<=0) return NULL;

	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if(USING_SLOB)
	{
		if (size < PAGE_SIZE - SLOB_UNIT) // 如果小于1页(包括头部)
		{
			m = slob_alloc(size + SLOB_UNIT, gfp, 0); 		// 使用slob分配器分配内存
			return m ? (void *)(m + 1) : 0;					// 如果分配到了返回指针，否则返回NULL
		}		
	}
	if(USING_SLUB) 
	{
		size_t up_size = up_to_2_power(size+SLUB_UNIT);		// 向上取整后的大小(Byte)
		if (up_size < PAGE_SIZE) 							// 如果小于1页(包括头部)
		{
			object* m = slub_alloc(up_size, gfp, 0); 				// 使用slub分配器分配内存
			return m ? (void *)(m + 1) : 0;					// 如果分配到了返回指针，否则返回NULL			
		}
	}

	// 如果大等于1页(包括头部)
	if(USING_SLOB) 	// 使用slob分配器分配一个单向链表节点(>=1页)(困惑)
	{
		bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
		if (!bb) return 0;
	}
	if(USING_SLUB) 	// 使用slub分配器分配一个单向链表节点(>=1页)
	{
		size_t up_size = up_to_2_power(sizeof(bigblock_t)+SLUB_UNIT);		// 向上取整后的大小(Byte)
		bb = slub_alloc(up_size, gfp, 0);
		if (!bb) return 0;
		bb = (bigblock_t*)((void*)bb+SLUB_UNIT);
	}
	

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
	if(USING_SLOB) slob_free(bb, sizeof(bigblock_t)); //(困惑)
	if(USING_SLUB) 
	{
		slub_free((object *)bb - 1, (size_t)((object *)bb-1)->state.size); 
	}
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
				if(USING_SLOB) slob_free(bb, sizeof(bigblock_t));					
				else slub_free(bb, (size_t)((object*)bb-1)->state.size);	
				return;
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
	}
	
	// 释放小于1页的
    if(USING_SLOB) slob_free((slob_t *)block - 1, 0); 
	if(USING_SLUB) slub_free((object *)block - 1, (size_t)((object*)block-1)->state.size); 
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



