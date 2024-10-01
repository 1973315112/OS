#ifndef __KERN_MM_PMM_H__
#define __KERN_MM_PMM_H__

#include <assert.h>
#include <atomic.h>
#include <defs.h>
#include <memlayout.h>
#include <mmu.h>
#include <riscv.h>

/*
 * pmm_manager是一个物理内存管理类。
 * 一个特定(special)的pmm管理器(XXX_pmm_manager)只需要实现pmm_manager类中的方法，
 * 那么ucore就可以使用XXX_pmm_manager来管理整个物理内存空间。
 * 注意:让函数指针作为结构体的成员，在C语言里支持了类似”成员函数“的效果
 */
struct pmm_manager {
    const char *name;  // XXX_pmm_manager的名字
    void (*init)(
        void);  // 初始化XXX_pm_manager的内部描述符和管理数据结构（空闲块链表、空闲块数量）
    void (*init_memmap)(
        struct Page *base,
        size_t n);  // 根据物理内存空间设置描述符和管理数据结构(知道了可用的物理页面数目之后，进行更详细的初始化)
    struct Page *(*alloc_pages)(
        size_t n);  // 分配至少n页的物理内存，具体取决于分配算法（分配至少n个物理页面, 根据分配算法可能返回不同的结果）
    void (*free_pages)(struct Page *base, size_t n);  // 释放至少n页的内存，具有页面描述符结构（memlayout.h）的“base”地址
    size_t (*nr_free_pages)(void);  // 返回空闲物理页面的数目
    void (*check)(void);            // 测试XXX_pmm_manager的正确性 
};

extern const struct pmm_manager *pmm_manager;

void pmm_init(void);

struct Page *alloc_pages(size_t n);
void free_pages(struct Page *base, size_t n);
size_t nr_free_pages(void); // number of free pages

#define alloc_page() alloc_pages(1)
#define free_page(page) free_pages(page, 1)


/* *
 * PADDR - takes a kernel virtual address (an address that points above
 * KERNBASE),
 * 功能:接受一个内核虚拟地址（指向KERNBASE(内核基地址)之上的地址）,其中映射了机器最大256MB的物理内存，
 *      并返回相应的物理地址。如果你传递一个非内核虚拟地址，它会出错（panics）。
 * 参数:
 * @kva:        内核虚拟地址
 * */
#define PADDR(kva)                                                 \
    ({                                                             \
        uintptr_t __m_kva = (uintptr_t)(kva);                      \
        if (__m_kva < KERNBASE) {                                  \
            panic("PADDR called with invalid kva %08lx", __m_kva); \
        }                                                          \
        __m_kva - va_pa_offset;                                    \
    })

/* *
 * KADDR - takes a physical address and returns the corresponding kernel virtual
 * address. It panics if you pass an invalid physical address.
 * */
/*
#define KADDR(pa)                                                \
    ({                                                           \
        uintptr_t __m_pa = (pa);                                 \
        size_t __m_ppn = PPN(__m_pa);                            \
        if (__m_ppn >= npage) {                                  \
            panic("KADDR called with invalid pa %08lx", __m_pa); \
        }                                                        \
        (void *)(__m_pa + va_pa_offset);                         \
    })
*/
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }

static inline int page_ref_inc(struct Page *page) {
    page->ref += 1;
    return page->ref;
}

static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
}
static inline void flush_tlb() { asm volatile("sfence.vm"); }
extern char bootstack[], bootstacktop[]; // defined in entry.S

#endif /* !__KERN_MM_PMM_H__ */
