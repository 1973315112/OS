#include <default_pmm.h>
#include <best_fit_pmm.h>
#include <buddy_system_pmm.h>
#include <slub_pmm.h>
#include <defs.h>
#include <error.h>
#include <memlayout.h>
#include <mmu.h>
#include <pmm.h>
#include <sbi.h>
#include <stdio.h>
#include <string.h>
#include <../sync/sync.h>
#include <riscv.h>

// 页框(物理页)数组的虚拟地址
// pages指针保存的是第一个Page结构体所在的位置，也可以认为是Page结构体组成的数组的开头
// 由于C语言的特性，可以把pages作为数组名使用，pages[i]表示顺序排列的第i个结构体
struct Page *pages;
// 物理内存的数量（以页为单位）
size_t npage = 0;
// 内核镜像(image)映射到VA=KERNBASE和PA=info.base
uint64_t va_pa_offset;
// RISC-V中的内存从0x80000000开始
// DRAM_BASE在riscv.h中定义为0x80000000
// (npage - nbase)表示物理内存的页数
const size_t nbase = DRAM_BASE / PGSIZE;

// virtual address of boot-time page directory
uintptr_t *satp_virtual = NULL;
// physical address of boot-time page directory
uintptr_t satp_physical;

/*
 *物理内存管理器,在函数init_pmm_manager()中用不同类型初始化从而支持不同的分配算法，包括:
 *[default_pmm_manager,best_fit_pmm_manager,buddy_system_pmm_manager,slub_pmm_manager]
 */ 
const struct pmm_manager *pmm_manager;


static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
/*
 * 功能:初始化pmm_manager实例
 */
static void init_pmm_manager(void) {
    //pmm_manager = &default_pmm_manager;
    //pmm_manager = &best_fit_pmm_manager;
    pmm_manager = &buddy_system_pmm_manager;
    //pmm_manager = &slub_pmm_manager;
    cprintf("memory management: %s\n", pmm_manager->name);
    pmm_manager->init();
}

// init_memmap - call pmm->init_memmap to build Page struct for free memory
static void init_memmap(struct Page *base, size_t n) {
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
    }
    local_intr_restore(intr_flag);
    return page;
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
    }
    local_intr_restore(intr_flag);
}

// nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
    }
    local_intr_restore(intr_flag);
    return ret;
}

static void page_init(void) {
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;  //硬编码 0xFFFFFFFF40000000

    uint64_t mem_begin = KERNEL_BEGIN_PADDR;  //硬编码 0x80200000
    uint64_t mem_size = PHYSICAL_MEMORY_END - KERNEL_BEGIN_PADDR;
    uint64_t mem_end = PHYSICAL_MEMORY_END; //硬编码取代 sbi_query_memory()接口,硬编码 0x88000000

    cprintf("physcial memory map:\n");
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
            mem_end - 1);

    uint64_t maxpa = mem_end;
    //KERNEL_BEGIN_PADDR:内核起始地址 KERNTOP:内核顶部(结束)地址
    if (maxpa > KERNTOP) {
        maxpa = KERNTOP;
    }

    extern char end[];//全局变量在kern_init()之前已被设置

    npage = maxpa / PGSIZE;
    //kernel在end[]结束, pages是剩下的页的开始
    //把pages指针指向内核所占内存空间结束后的第一页
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    //一开始把所有页面都设置为保留给内核使用的，之后再设置哪些页面可以分配给其他程序
    for (size_t i = 0; i < npage - nbase; i++) {
        SetPageReserved(pages + i); //在kern/mm/memlayout.h定义的(将该bit设为1，为内核保留页面)
    }
    //从这个地方开始才是我们可以自由使用的物理内存
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
    //按照页面大小PGSIZE进行对齐, ROUNDUP, ROUNDDOWN是在libs/defs.h定义的
    mem_begin = ROUNDUP(freemem, PGSIZE);
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
    if (freemem < mem_end) {
        //初始化我们可以自由使用的物理内存
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
/*
 * 功能:初始化物理内存管理器
 */
void pmm_init(void) {
    /*
     * 我们需要分配/释放物理内存（大小为4KB或其他）。
     * 因此，在pmm.h中定义了一个物理内存管理器框架（struct pmm_manager）
     * 首先，我们应该基于框架初始化一个物理内存管理器(pmm),然后pmm可以分配/释放物理内存。
     * 现在first_fit/best_fit/worst_fit/buddy_system pmm可用。
     */
    init_pmm_manager();

    // 检测物理内存空间、保留已使用的内存，然后使用pmm->init_mamp创建空闲页面列表
    page_init();

    // 使用pmm->check验证pmm中alloc/free函数的正确性
    check_alloc_page();

    extern char boot_page_table_sv39[];
    satp_virtual = (pte_t*)boot_page_table_sv39;
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
    cprintf("check_alloc_page() succeeded!\n");
}
