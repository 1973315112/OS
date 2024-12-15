#include <default_pmm.h>
#include <defs.h>
#include <error.h>
#include <kmalloc.h>
#include <memlayout.h>
#include <mmu.h>
#include <pmm.h>
#include <sbi.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <sync.h>
#include <vmm.h>
#include <riscv.h>

bool shared_read_state(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end,bool share)
{
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));
    // copy content by page unit.
    do 
    {
        // call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
        if (ptep == NULL) 
        {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue;
        }
        // call get_pte to find process B's pte according to the addr start. If
        // pte is NULL, just alloc a PT
        if (*ptep & PTE_V)
        {
            if ((nptep = get_pte(to, start, 1)) == NULL) return -E_NO_MEM;
            uint32_t perm = (*ptep & PTE_USER & (~PTE_W));
            // get page from ptep
            struct Page *page = pte2page(*ptep);
            // alloc a page for process B
            //struct Page *npage = alloc_page();
            struct Page *npage = page;  // 父进程和子进程共享内存页面
            (*ptep) = *ptep & (~PTE_W); // 页面设置为只读
            int ret = 0;
            assert(page != NULL);
            assert(npage != NULL);
            ret = page_insert(to, npage, start, perm);
            assert(ret == 0);
        }
        start += PGSIZE;
    } 
    while (start != 0 && start < end);
    return 0;
}

int privated_write_state(struct mm_struct *mm, uint_t error_code, uintptr_t addr)
{
    pte_t *ptep = get_pte(mm->pgdir, addr, 0);
    uint32_t perm = (*ptep & PTE_USER | PTE_W);
    uintptr_t start = ROUNDDOWN(addr, PGSIZE);
    struct Page *page = pte2page(*ptep);
    struct Page *npage = alloc_page();  // 分配新页面
    (*ptep) = *ptep | (PTE_W);          // 页面设置为可写
    assert(page != NULL);
    assert(npage != NULL);
    int ret = 0;
    uintptr_t* src_kvaddr = page2kva(page);
    uintptr_t* dst_kvaddr = page2kva(npage);
    memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
    ret = page_insert(mm->pgdir, npage, start, perm);
    return ret;
}