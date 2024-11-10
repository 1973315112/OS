//################################################################################
/*LAB3 扩展练习 Challenge: 2213917 CODE*/ 
#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>
#include <list.h>

static list_entry_t pra_list_head, *curr_ptr;

/*
 * 功能: 初始化LRU管理器
 * 参数:
 *      @mm     :使用相同页目录表的一组vma的控制结构
 * 步骤:
 *     1.初始化pra_list_head为空链表
 *     2.初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
 *     3.将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
 */
static int _lru_init_mm(struct mm_struct *mm)
{     
    list_init(&pra_list_head);
    curr_ptr = &pra_list_head;
    mm->sm_priv = &pra_list_head;
    //cprintf(" mm->sm_priv %x in lru_init_mm\n",mm->sm_priv);
    return 0;
}

/*
 * 功能: LRU管理器将页面设为可被替换（即其对应的物理页正在被某个虚拟页映射）
 * 参数:
 *      @mm     :使用相同页目录表的一组vma的控制结构
 *      @addr   :地址(在本函数未被使用)
 *      @page   :页面描述符结构体
 *      @swap_in:能否被替换(在本函数未被使用)
 * 步骤:
 *     1.将页面page插入到页面链表pra_list_head的末尾
 *     2.将页面的visited标志置为1，表示该页面已被访问
 */
static int _lru_map_swappable(struct mm_struct* mm, uintptr_t addr, struct Page* page, int swap_in)
{
    list_entry_t *entry=&(page->pra_page_link);
    assert(entry != NULL && curr_ptr != NULL);
    list_add_after((list_entry_t*)mm->sm_priv,entry);
    page->visited=1;
    return 0;
}

/*
 * 功能: LRU管理器选择将要被换出的物理页（称为受害者页，victim）
 * 参数:
 *      @mm         :使用相同页目录表的一组vma的控制结构
 *      @ptr_page   :Page的指针，用于标记换出页面
 *      @in_tick    :是否处于时钟中断(在本函数中要求不处于时钟中断)
 * 步骤:
 *     将页面链表pra_list_head的最后一个节点（即最久未被访问的页面）,
 *     从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
 */
static int _lru_swap_out_victim(struct mm_struct* mm, struct Page** ptr_page, int in_tick)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    assert(head != NULL);
    assert(in_tick==0);
    curr_ptr = list_prev(head); 
    if(curr_ptr == head) 
    {
        *ptr_page = NULL;
        return 0;
    }
    struct Page* page = le2page(curr_ptr, pra_page_link);
    list_del(curr_ptr);
    *ptr_page = page;
    cprintf("curr_ptr %p\n",curr_ptr);
    return 0;
}

/*
 * 功能: 清空页表项的A标志位
 */
static void clear_A()
{
    cprintf("[调试信息]进入clear_A()\n");
    list_entry_t *now=list_next(&pra_list_head);
    while(now!=&pra_list_head)
    {
        struct Page* page = le2page(now, pra_page_link);
        uintptr_t la = ROUNDDOWN(page->pra_vaddr, PGSIZE);
        //pte_t *ptep = get_pte(boot_pgdir, la, 1); // 获取指向页表中对应页表项的指针
        //if(((*ptep)>>6&1)==1) *ptep = (*ptep) - 64;
        update_visited(page);
        page->visited = 0;
        now=list_next(now);
    }
}

/*
 * 功能: 更新LRU的链表
 */
static void lru_update_list(size_t x)
{
    //cprintf("[调试信息]进入lru_update_list()\n");
    list_entry_t *now=list_next(&pra_list_head);
    while(now != (&pra_list_head))
    {
        struct Page* page = le2page(now, pra_page_link);
        if(x == page->pra_vaddr)
        {
            cprintf("[调试信息]将0x%x放到链表的首部\n",page->pra_vaddr);
            page->visited = 0;
            break;
        }
        now=list_next(now);
    }
    if(now == (&pra_list_head)) return;
    list_del(now);
    list_add_after(&pra_list_head,now);
}


/*
 * 功能: 打印page->visited，页表项的A标志位和对应的虚拟地址
 */
static void testprint()
{
    cprintf("[调试信息]:当前LRU链表为:");
    list_entry_t *now=list_next(&pra_list_head);
    // 打印page->pra_vaddr
    now=list_next(&pra_list_head);
    while(now!=&pra_list_head)
    {
        struct Page* page = le2page(now, pra_page_link);
        cprintf("0x%x ",page->pra_vaddr);
        now=list_next(now);
    }
    cprintf("\n");   
}

/*
 * 功能: LRU管理器的自检程序
 */
static int _lru_check_swap(void) {
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
    // 注意:本测试样例仅作为示例，在真正有效的LRU换页机制中应实现每次内存访问
    //     都能自动执行lru_update_list()函数
    //cprintf("[调试信息]进入_lru_check_swap\n");
    testprint();
    // 4321
    //----------------------------------------
    __asm__ __volatile__("fence");
    *(unsigned char *)0x3000 = 0x0c;
    __asm__ __volatile__("fence");
    lru_update_list(0x3000);
    __asm__ __volatile__("fence");
    testprint();
    __asm__ __volatile__("fence");
    assert(pgfault_num==4);
    // 3421
    //----------------------------------------
    __asm__ __volatile__("fence");
    *(unsigned char *)0x1000 = 0x0a;
    __asm__ __volatile__("fence");
    lru_update_list(0x1000);
    __asm__ __volatile__("fence");
    testprint();
    __asm__ __volatile__("fence");
    assert(pgfault_num==4);
    // 1342
    //----------------------------------------
    __asm__ __volatile__("fence");
    *(unsigned char *)0x4000 = 0x0d;
    __asm__ __volatile__("fence");
    lru_update_list(0x4000);
    __asm__ __volatile__("fence");
    testprint();
    __asm__ __volatile__("fence");
    assert(pgfault_num==4);
    // 4132
    //----------------------------------------
    __asm__ __volatile__("fence");
    *(unsigned char *)0x2000 = 0x0b;
    __asm__ __volatile__("fence");
    lru_update_list(0x2000);
    __asm__ __volatile__("fence");
    testprint();
    __asm__ __volatile__("fence");
    assert(pgfault_num==4);
    // 2413
    //----------------------------------------
    __asm__ __volatile__("fence");
    *(unsigned char *)0x5000 = 0x0e;
    __asm__ __volatile__("fence");
    lru_update_list(0x5000);
    __asm__ __volatile__("fence");
    testprint();
    __asm__ __volatile__("fence");
    assert(pgfault_num==5);
    // 5241 3->5
    //----------------------------------------
    __asm__ __volatile__("fence");
    *(unsigned char *)0x2000 = 0x0b;
    __asm__ __volatile__("fence");
    lru_update_list(0x2000);
    __asm__ __volatile__("fence");
    testprint();
    __asm__ __volatile__("fence");
    assert(pgfault_num==5);
    // 2541
    //----------------------------------------
    __asm__ __volatile__("fence");
    *(unsigned char *)0x1000 = 0x0a;
    __asm__ __volatile__("fence");
    lru_update_list(0x1000);
    __asm__ __volatile__("fence");
    testprint();
    __asm__ __volatile__("fence");
    assert(pgfault_num==5);
    // 1254
    //----------------------------------------
    __asm__ __volatile__("fence");
    *(unsigned char *)0x2000 = 0x0b;
    __asm__ __volatile__("fence");
    lru_update_list(0x2000);
    __asm__ __volatile__("fence");
    testprint();
    __asm__ __volatile__("fence");
    assert(pgfault_num==5);
    // 2154
    //----------------------------------------
    __asm__ __volatile__("fence");
    *(unsigned char *)0x3000 = 0x0c;
    __asm__ __volatile__("fence");
    lru_update_list(0x3000);
    __asm__ __volatile__("fence");
    testprint();
    __asm__ __volatile__("fence");
    assert(pgfault_num==6);
    // 3215 4->3
    //----------------------------------------
    __asm__ __volatile__("fence");
    *(unsigned char *)0x4000 = 0x0d;
    __asm__ __volatile__("fence");
    lru_update_list(0x4000);
    __asm__ __volatile__("fence");
    testprint();
    __asm__ __volatile__("fence");
    assert(pgfault_num==7);
    // 4321 5->4
    //----------------------------------------
    __asm__ __volatile__("fence");
    *(unsigned char *)0x5000 = 0x0e;
    __asm__ __volatile__("fence");
    lru_update_list(0x5000);
    __asm__ __volatile__("fence");
    testprint();
    __asm__ __volatile__("fence");
    assert(pgfault_num==8);
    // 5432 1->5
    //----------------------------------------
    __asm__ __volatile__("fence");
    assert(*(unsigned char *)0x1000 == 0x0a);
    __asm__ __volatile__("fence");
    lru_update_list(0x1000);
    __asm__ __volatile__("fence");
    testprint();
    __asm__ __volatile__("fence");
    assert(pgfault_num==9);
    // 1543 2->1
    //----------------------------------------
    __asm__ __volatile__("fence");
    *(unsigned char *)0x1000 = 0x0a;
    __asm__ __volatile__("fence");
    lru_update_list(0x1000);
    __asm__ __volatile__("fence");
    testprint();
    __asm__ __volatile__("fence");
    assert(pgfault_num==9);
    // 1543
    //----------------------------------------
#endif
    return 0;
}

/*
 * 功能: 未知
 */
static int _lru_init(void)
{
    return 0;
}

/*
 * 功能: 未知
 */
static int _lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

/*
 * 功能: 未知
 */
static int _lru_tick_event(struct mm_struct *mm)
{ 
    return 0; 
}


struct swap_manager swap_manager_lru =
{
     .name            = "LRU swap manager",
     .init            = &_lru_init,
     .init_mm         = &_lru_init_mm,
     .tick_event      = &_lru_tick_event,
     .map_swappable   = &_lru_map_swappable,
     .set_unswappable = &_lru_set_unswappable,
     .swap_out_victim = &_lru_swap_out_victim,
     .check_swap      = &_lru_check_swap,
};
//################################################################################