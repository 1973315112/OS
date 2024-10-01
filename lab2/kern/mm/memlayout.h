#ifndef __KERN_MM_MEMLAYOUT_H__
#define __KERN_MM_MEMLAYOUT_H__

/* All physical memory mapped at this address */
#define KERNBASE            0xFFFFFFFFC0200000 // = 0x80200000(物理内存里内核的起始位置, KERN_BEGIN_PADDR) + 0xFFFFFFFF40000000(偏移量, PHYSICAL_MEMORY_OFFSET)
//把原有内存映射到虚拟内存空间的最后一页
#define KMEMSIZE            0x7E00000          // the maximum amount of physical memory
// 0x7E00000 = 0x8000000 - 0x200000
// QEMU 缺省的RAM为 0x80000000到0x88000000, 128MiB, 0x80000000到0x80200000被OpenSBI占用
#define KERNTOP             (KERNBASE + KMEMSIZE) // 0x88000000对应的虚拟地址

#define PHYSICAL_MEMORY_END         0x88000000
#define PHYSICAL_MEMORY_OFFSET      0xFFFFFFFF40000000
#define KERNEL_BEGIN_PADDR          0x80200000
#define KERNEL_BEGIN_VADDR          0xFFFFFFFFC0200000


#define KSTACKPAGE          2                           // # of pages in kernel stack
#define KSTACKSIZE          (KSTACKPAGE * PGSIZE)       // sizeof kernel stack

#ifndef __ASSEMBLER__

#include <defs.h>
#include <atomic.h>
#include <list.h>

typedef uintptr_t pte_t;
typedef uintptr_t pde_t;

/* *
 * struct Page-页面描述符结构。每个页面描述一个页框(物理页)。
 * 在kern/mm/pmm.h中，您可以找到许多将Page转换为其他数据类型（如物理地址）的有用函数。
 * */
struct Page {
    int ref;                        // 页框(物理页)的引用计数器
    uint64_t flags;                 // 描述页框(物理页)状态的标志数组
    unsigned int property;          // 空闲块数（first-fit中使用，used in first fit pm manager）
    list_entry_t page_link;         // 空闲链表链接(功能:用该节点进行链表相关操作，类型:链表节点结构体)
};

/* 描述页框(物理页)状态的标志Flags */
#define PG_reserved                 0       // 如果该bit=1：页面是为内核保留的，不能在alloc/free_pages中使用；否则，此位该bit=0
#define PG_property                 1       // if this bit=1: the Page is the head page of a free memory block(contains some continuous_addrress pages), and can be used in alloc_pages; if this bit=0: if the Page is the the head page of a free memory block, then this Page and the memory block is alloced. Or this Page isn't the head page.
                                            //如果该bit=1：Page是空闲内存块的首页（包含一些连续的地址页），可以在alloc_pages中使用；
                                            //如果该bit=0：如果Page是空闲内存块的首页，则分配此Page和内存块。或者这个页面不是首页。
                                            
#define SetPageReserved(page)       set_bit(PG_reserved, &((page)->flags))   //将该bit设为1，为内核保留页面
#define ClearPageReserved(page)     clear_bit(PG_reserved, &((page)->flags))
#define PageReserved(page)          test_bit(PG_reserved, &((page)->flags))
#define SetPageProperty(page)       set_bit(PG_property, &((page)->flags))
#define ClearPageProperty(page)     clear_bit(PG_property, &((page)->flags))
#define PageProperty(page)          test_bit(PG_property, &((page)->flags))

// 将链表节点转换为页框(物理页，Page类型结构体)
#define le2page(le, member)                 \
    to_struct((le), struct Page, member)

/* free_area_t - maintains a doubly linked list to record free (unused) pages 
 * 功能:维护一个双向链表来记录空闲（未使用）页框(物理页)
 */
typedef struct {
    list_entry_t free_list;         // 链表头节点
    unsigned int nr_free;           // 此空闲链表中的可用页框(物理页)数
} free_area_t;

#endif /* !__ASSEMBLER__ */

#endif /* !__KERN_MM_MEMLAYOUT_H__ */
