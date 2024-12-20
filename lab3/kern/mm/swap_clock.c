#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_clock.h>
#include <list.h>

/* [wikipedia]The simplest Page Replacement Algorithm(PRA) is a FIFO algorithm. The first-in, first-out
 * page replacement algorithm is a low-overhead algorithm that requires little book-keeping on
 * the part of the operating system. The idea is obvious from the name - the operating system
 * keeps track of all the pages in memory in a queue, with the most recent arrival at the back,
 * and the earliest arrival in front. When a page needs to be replaced, the page at the front
 * of the queue (the oldest page) is selected. While FIFO is cheap and intuitive, it performs
 * poorly in practical application. Thus, it is rarely used in its unmodified form. This
 * algorithm experiences Belady's anomaly.
 *
 * Details of FIFO PRA
 * (1) Prepare: In order to implement FIFO PRA, we should manage all swappable pages, so we can
 *              link these pages into pra_list_head according the time order. At first you should
 *              be familiar to the struct list in list.h. struct list is a simple doubly linked list
 *              implementation. You should know howto USE: list_init, list_add(list_add_after),
 *              list_add_before, list_del, list_next, list_prev. Another tricky method is to transform
 *              a general list struct to a special struct (such as struct page). You can find some MACRO:
 *              le2page (in memlayout.h), (in future labs: le2vma (in vmm.h), le2proc (in proc.h),etc.
 */

static list_entry_t pra_list_head, *curr_ptr;
/*
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_clock_init_mm(struct mm_struct *mm)
{     
//################################################################################
    /*LAB3 EXERCISE 4: 2210705 CODE*/ 
    /* 
       初始化pra_list_head为空链表
       初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
       将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
    */
    // 初始化pra_list_head为空链表
    list_init(&pra_list_head);
    // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
    curr_ptr = &pra_list_head;
    // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
    mm->sm_priv = &pra_list_head;
    //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
//################################################################################
    return 0;
}
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *entry=&(page->pra_page_link);
    assert(entry != NULL && curr_ptr != NULL);
//################################################################################
    //record the page access situlation
    /*LAB3 EXERCISE 4: 2210628 CODE*/ 
    /* 
       link the most recent arrival page at the back of the pra_list_head qeueue.
       1.将页面page插入到页面链表pra_list_head的末尾
       2.将页面的visited标志置为1，表示该页面已被访问
    */
    list_add_before((list_entry_t*)mm->sm_priv,entry);  //1.将页面page插入到页面链表pra_list_head的末尾
    page->visited=1;                                    //2.将页面的visited标志置为1，表示该页面已被访问
//################################################################################
    return 0;
}
/*
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then set the addr of addr of this page to ptr_page.
 */
static int
_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    assert(head != NULL);
    assert(in_tick==0);
//################################################################################
     /* Select the victim */
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
    while (1) {
        /*LAB3 EXERCISE 4: 2213917 CODE*/ 
        /* 
           编写代码
           遍历页面链表pra_list_head，查找最早未被访问的页面
           获取当前页面对应的Page结构指针
           如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
           如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问
        */
        // 遍历页面链表pra_list_head
        curr_ptr = list_next(curr_ptr);  
        if(curr_ptr==head) curr_ptr = list_next(curr_ptr);
        if(curr_ptr==head) 
        {
            *ptr_page = NULL;
            break;
        }
        // 获取当前页面对应的Page结构指针
        struct Page* page = le2page(curr_ptr, pra_page_link);
        // 查找最早未被访问的页面
        update_visited(page);
        if( page->visited==0 )
        {
            // 如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
            list_del(curr_ptr);
            *ptr_page = page;
            // 根据make grade要求输出curr_ptr(注:指导手册中似乎输出了2次)
            cprintf("curr_ptr %p\n",curr_ptr);
            break;
        }
        //（如果当前页面已被访问，则）将visited标志置为0，表示该页面在下次遍历有可能被作为换出页面（已被重新访问）
        page->visited = 0;
//################################################################################
    }
    return 0;
}

/*
 * 功能: 打印page->visited，页表项的A标志位和对应的虚拟地址
 */
static void testprint()
{
    // 打印page->visited
    list_entry_t *now=list_next(&pra_list_head);
    while(now!=&pra_list_head)
    {
        struct Page* page = le2page(now, pra_page_link);
        cprintf("%d ",page->visited);
        now=list_next(now);
    }
    cprintf("\n");
    // 打印页表项A
    now=list_next(&pra_list_head);
    extern pde_t *boot_pgdir;
    while(now!=&pra_list_head)
    {
        struct Page* page = le2page(now, pra_page_link);
        uintptr_t la = ROUNDDOWN(page->pra_vaddr, PGSIZE);
        pte_t *ptep = get_pte(boot_pgdir, la, 1); // 获取指向页表中对应页表项的指针
        cprintf("%d ",(*ptep)>>6&1);
        //if(((*ptep)>>6&1)==1) *ptep = (*ptep) - 64;
        now=list_next(now);
    }
    cprintf("\n"); 
    
    // 打印page->pra_vaddr
    now=list_next(&pra_list_head);
    while(now!=&pra_list_head)
    {
        struct Page* page = le2page(now, pra_page_link);
        cprintf("0x%x ",page->pra_vaddr);
        now=list_next(now);
    }
    cprintf("\n\n");   
}

static int
_clock_check_swap(void) {
#ifdef ucore_test
    int score = 0, totalscore = 5;
    cprintf("%d\n", &score);
    ++ score; cprintf("grading %d/%d points", score, totalscore);
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==4);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==4);
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==4);
    *(unsigned char *)0x2000 = 0x0b;
    ++ score; cprintf("grading %d/%d points", score, totalscore);
    assert(pgfault_num==4);
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    ++ score; cprintf("grading %d/%d points", score, totalscore);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==5);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==5);
    ++ score; cprintf("grading %d/%d points", score, totalscore);
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==5);
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==6);
    ++ score; cprintf("grading %d/%d points", score, totalscore);
#else 
/*  注意:这部分为作业自带的测试样例，它由于指令重排所以并非按照表面的顺序执行，
 *      但其assert检查同样按照指令重排后的情况设计，所以<我们的代码能通过该测试>,
 *      但其不能完全体现我们的clock算法的正确性，所以我们使用__asm__ __volatile__("fence");
 *      设计了相同的无指令重排的assert检查。
 *  注意:make grade时必须使用该测试样例 
 */
///*
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==4);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==4);
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==4);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==4);
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==5);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==5);
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==5);
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==6);
//*/
/*  注意:这部分使用__asm__ __volatile__("fence");
 *      设计了无指令重排的assert检查。
 *  注意:make grade时不能使用该测试样例 
 */
/*
    __asm__ __volatile__("fence");
    *(unsigned char *)0x3000 = 0x0c;
    __asm__ __volatile__("fence");
    assert(pgfault_num==4);
    __asm__ __volatile__("fence");
    *(unsigned char *)0x1000 = 0x0a;
    __asm__ __volatile__("fence");
    assert(pgfault_num==4);
    __asm__ __volatile__("fence");
    *(unsigned char *)0x4000 = 0x0d;
    __asm__ __volatile__("fence");
    assert(pgfault_num==4);
    __asm__ __volatile__("fence");
    *(unsigned char *)0x2000 = 0x0b;    // 1(1),2(1),3(1),4(1)
    __asm__ __volatile__("fence");
    assert(pgfault_num==4);
    __asm__ __volatile__("fence");
    *(unsigned char *)0x5000 = 0x0e;    // 2(0),3(0),4(0),5(1) 1->5
    __asm__ __volatile__("fence");
    assert(pgfault_num==5);
    __asm__ __volatile__("fence");
    *(unsigned char *)0x2000 = 0x0b;    // 2(1),3(0),4(0),5(1)
    __asm__ __volatile__("fence");
    assert(pgfault_num==5);
    __asm__ __volatile__("fence");
    *(unsigned char *)0x1000 = 0x0a;    // 2(0),4(0),5(1),1(1) 3->1
    __asm__ __volatile__("fence");
    assert(pgfault_num==6);
    __asm__ __volatile__("fence");      
    *(unsigned char *)0x2000 = 0x0b;    // 2(1),4(0),5(1),1(1)
    __asm__ __volatile__("fence");
    assert(pgfault_num==6);
    __asm__ __volatile__("fence");
    *(unsigned char *)0x3000 = 0x0c;    // 2(0),5(1),1(1),3(0) 4->3
    assert(pgfault_num==7);
    __asm__ __volatile__("fence");
    *(unsigned char *)0x4000 = 0x0d;    // 5(1),1(1),3(0),4(1) 2->4
    __asm__ __volatile__("fence");
    assert(pgfault_num==8);
    __asm__ __volatile__("fence");
    *(unsigned char *)0x5000 = 0x0e;    // 5(1),1(1),3(0),4(1)
    __asm__ __volatile__("fence");
    assert(pgfault_num==8);
    __asm__ __volatile__("fence");
    assert(*(unsigned char *)0x1000 == 0x0a);    // 5(1),1(1),3(0),4(1)
    __asm__ __volatile__("fence");
    *(unsigned char *)0x1000 = 0x0a;    // 5(1),1(1),3(0),4(1)
    __asm__ __volatile__("fence");
    assert(pgfault_num==8);
*/
#endif
    return 0;
}


static int
_clock_init(void)
{
    return 0;
}

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }


struct swap_manager swap_manager_clock =
{
     .name            = "clock swap manager",
     .init            = &_clock_init,
     .init_mm         = &_clock_init_mm,
     .tick_event      = &_clock_tick_event,
     .map_swappable   = &_clock_map_swappable,
     .set_unswappable = &_clock_set_unswappable,
     .swap_out_victim = &_clock_swap_out_victim,
     .check_swap      = &_clock_check_swap,
};
