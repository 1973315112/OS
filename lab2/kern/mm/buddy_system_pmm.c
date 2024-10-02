//################################################################################
/*LAB2 EXERCISE 2: 2213917 CODE*/ 
#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_system_pmm.h>
#include <stdio.h>

/*
 * 该文件用于编写buddy system（伙伴系统）分配算法相关代码
 * 注:本文件大量参考https://coolshell.cn/articles/10427.html, 作者:@我的上铺叫路遥 和 出处:酷 壳 – CoolShell 
 * 注:buddy_system_check()参考自https://github.com/AllenKaixuan/Operating-System/blob/main/labcodes/lab2/kern/mm/buddy_pmm.c的buddy_check()函数。
 * 注:本文件通过空闲块二叉树管理空闲块(树上操作)，为了可能的兼容性问题，需要正确处理Page的相关属性(页操作),
 *    主要为Page->flags的PG_property(是否可以被分配)位和property(空闲块数)。
 * 注:二叉树数组索引和页表偏移量互换关系:
 *       offset = (i+1)*size-max_size;
 *       i      = (offset+max_size)/size-1
 * 注:本文件只能管理一个连续的物理页数组(实际上可以通过声明多个管理器分别管理，但目前的代码框架是不允许的)。
 * 注:已优化:本文件对一个连续的物理页数组会向上变为2的幂，正常的空间全部可以使用，取整产生的多余空间不会被分配，请勿使用非法操作尝试访问或在释放(否则会导致未定义行为)
 *         <本文件对一个连续的物理页数组会向下变为2的幂，多余的空间无法被使用。(可能可以通过置空的方式使用，待优化)>
 * 注:本文件对申请的内存会向上变为2的幂，多给出的空间可以被使用
 * 注:本文件要求释放的内存使用申请时的参数(大小n和返回的指针)，不支持部分释放(否则会导致未定义行为)
 * 注:已优化:将所有递归函数优化为循环
 *          <本文件的所有递归函数都可以被优化成循环(待优化)>
 * 注:nr_free代表总共的可用物理页数(换言之,每次申请1页一定可以申请到这么多,与先前的管理器类似)，free_tree[0]为可以申请的最多连续物理页数
 * 注:参考贴中提到可以free_tree可以使用一个字节(存储log2(长度))(待优化)
 */ 

struct free_area_tree
{
    struct Page *Base;                // 连续内存块的基底址
    size_t* free_tree;                // 二叉树数组根节点(指针)
    unsigned int nr_free;             // 此空闲链表中的可用页框(物理页)数
    unsigned int true_size;           // 真正的可用页框(物理页)数
    unsigned int max_size;            // 虚拟的可用页框(物理页)数
};

static struct free_area_tree free_area;

#define Base      (free_area.Base)
#define free_tree (free_area.free_tree)
#define nr_free   (free_area.nr_free)
#define true_size (free_area.true_size)
#define max_size  (free_area.max_size)
#define max(a,b)  (((a)>(b)) ? (a) : (b))
 

/*
 * 功能:检查n是否是2的幂
 * 参数：
 * @n:      待检查的数
 */
static bool check_2_power(size_t n) 
{
    assert(n > 0);
    return (( n & (~n) )== 0);
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
 * 功能:初始化free_area(清空性质)
 */
static void buddy_system_init(void) 
{
    //cprintf("调试信息:进入buddy_system_init()\n");
    Base = NULL;
    free_tree= NULL ;
    nr_free = 0;
    max_size = 0;   
}

/*
 * 功能:初始化buddy_system内存管理器
 * 参数：
 * @base:      连续空闲块的基底址指针
 * @n:         连续空闲块的数量
 * 注意:n会向下变为2的幂，多余的空间将无法被使用
 */
static void buddy_system_init_memmap(struct Page *base, size_t n) 
{
    //cprintf("调试信息:进入buddy_system_init_memmap():实际物理页数n=%d \n",n);
    assert(n > 0);
    size_t N = up_to_2_power(n); //将n向上变为2的幂，以便于buddy_system算法的实现
    //cprintf("调试信息:buddy_system_init_memmap():物理页数向上变为2的幂N=%d \n",N);
    
    //检查p及其后n页均为为内核保留的(根据实验流程或许意味着已经被初始化)
    struct Page *p = base;
    for (; p != base + n; p ++) 
    {
        assert(PageReserved(p)); 
        p->flags = 0;
        p->property = 0;
        set_page_ref(p, 0);
        ClearPageProperty(p);
    }

    // 初始化free_area(工作性质)
    Base = base;
    nr_free = n;
    true_size = n;
    max_size = N;
    // 树上操作:为二叉树分配内存空间
    free_tree = (size_t*)KADDR(page2pa(base)); 
    assert(free_tree != NULL);
    size_t i = 2*N-1; //最后一个再后一个
    while(i>N+n-1) free_tree[--i] = 0;
    while(i>N-1)   free_tree[--i] = 1;
    while(i>0)     
    {
        //树上操作:初始化祖宗节点的值
        i--;
        if( free_tree[(i<<1)+1]==free_tree[(i<<1)+2] ) free_tree[i] = free_tree[(i<<1)+1]+free_tree[(i<<1)+2];
        else free_tree[i]=max(free_tree[(i<<1)+1],free_tree[(i<<1)+2]);         
    }

    // 页操作:初始化
    base->property = n;
    SetPageProperty(base);
}

/*
 * 功能:buddy_system分配空闲块
 * 参数：
 * @n:         申请的空闲块数量
 * 注意:n会向上变为2的幂
 */
static struct Page* buddy_system_alloc_pages(size_t n) 
{
    //cprintf("调试信息:进入buddy_system_alloc_pages()\n");
    assert(n > 0);
    if (n > nr_free)  return NULL;
    n = up_to_2_power(n);
    if( n>free_tree[0] ) return NULL;
    nr_free -= n;

    struct Page* page = NULL ;
    size_t i = 0,size = max_size,offset = 0;
    //向下寻找合适的节点:当左右子树都不满足条件时，使用当前节点进行分配(n==size)
    while (free_tree[(i<<1)+1]>=n || free_tree[(i<<1)+2]>=n)
    {
        if(free_tree[(i<<1)+1]>=n) i = (i<<1)+1;
        else i = (i<<1)+2;
        size = size>>1;
    }
    //分配:
    offset = (i + 1) * size - max_size;
    //树上操作
    free_tree[i] = 0;
    //页操作
    page = Base+offset;
    page->property = 0;
    ClearPageProperty(page);
    if( i%2==1 && free_tree[i+1]==size) 
    {
        struct Page* right = Base+offset+size;
        right->property = size;
        SetPageProperty(right);            
    }
    
    //回溯：
    while (i!=0)
    {
        i = (i-1)>>1;
        size = size<<1;
        offset = (i + 1) * size - max_size;        
        free_tree[i]=max(free_tree[(i<<1)+1],free_tree[(i<<1)+2]); //树上操作:更新祖宗节点的值
        //拆分:页操作
        //如果当前节点是左节点，且右节点对应内存块完整，将右节点对应内存块拆分(设为空闲和正确大小)
        if( i%2==1 && free_tree[i+1]==size) 
        {
            struct Page* right = Base+offset+size;
            right->property = size;
            SetPageProperty(right);            
        }
    }
    return page;
}

/*
 * 功能:buddy_system释放空闲块
 * 参数：
 * @base       释放的内存块的基底址
 * @n:         释放的空闲块数量
 * 注意:n会向上变为2的幂
 */
static void buddy_system_free_pages(struct Page *base, size_t n) 
{
    //cprintf("调试信息:进入buddy_system_free_pages()\n");
    assert(n > 0);
    n = up_to_2_power(n);
    //将释放的内存块放回空闲块二叉树中
    struct Page *p = base;
    //检查p及其后n页均不是为内核保留的(可以被编入空闲块二叉树)且处于占用状态后清除标志
    for (; p != base + n; p ++) 
    {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    nr_free += n;
    //树上操作
    size_t offset = base-Base;
    size_t i = (offset+max_size)/n-1;
    free_tree[i]= n;
    //页操作
    base->property = n;
    SetPageProperty(base);

    // 进行兄弟节点的合并
    size_t size = n;
    while(i!=0)
    {
        i = (i-1)>>1;
        if( free_tree[(i<<1)+1]==size && free_tree[(i<<1)+2]==size ) //如果当前节点的左右子节点对应的内存块均完整，则合并它们
        {
            //树上操作
            free_tree[i] = 2*size;
            //页操作
            offset = 2*size*(i+1)-max_size;
            struct Page* Left  = Base+offset;
            struct Page* Right = Left+size;
            Left->property  = 2*size;
            Right->property = 0;
            SetPageProperty(Left);
            ClearPageProperty(Right);            
        }
        else free_tree[i]=max(free_tree[(i<<1)+1],free_tree[(i<<1)+2]);
        size = size<<1;
    }
}

/*
 * 功能:返回剩余的可用物理页数
 * 注意:该函数返回值代表总共的可用可用物理页数，不代表可以申请连续的这么多
 */
static size_t buddy_system_nr_free_pages(void) 
{
    return nr_free;
}

/*
 * 功能:输出p0开始n张物理页是否可以分配以及可分配的页数(buddy_system_check()的辅助函数)
 * 参数:
 * @p0              物理页指针
 * @n               数量n
 * 注意:通过是否注释return决定是否在buddy_system_check()中是否输出
 */
static void test_print(struct Page* p0,size_t n)
{
    for(int i=0;i<n;i++)
    {
        cprintf("%d ",PageProperty(p0+i));
    }
    cprintf("\n");
        for(int i=0;i<n;i++)
    {
        cprintf("%d ",(p0+i)->property);
    }
    cprintf("\n");
    cprintf("\n");
}

/*
 * 功能:检查buddy_system是否正确
 * 注意:本函数参考自https://github.com/AllenKaixuan/Operating-System/blob/main/labcodes/lab2/kern/mm/buddy_pmm.c的buddy_check()函数。
 * 注意:以上参考代码本身存在一定缺陷（甚至可以说是错误）,对其进行较大幅度修正。
 */
static void buddy_system_check(void) 
{
    int all_pages = nr_free_pages();
    struct Page* p0, *p1, *p2, *p3;
    // 分配过大的页数
    assert(alloc_pages(all_pages + 1) == NULL);
    // 分配两个组页
    p0 = alloc_pages(1);
    test_print(p0,16);//1
    assert(p0 != NULL);
    p1 = alloc_pages(2);
    test_print(p0,16);//2
    assert(p1 == p0 + 2);
    assert(!PageReserved(p0) && !PageProperty(p0));
    assert(!PageReserved(p1) && !PageProperty(p1));
    // 再分配两个组页
    p2 = alloc_pages(1);
    test_print(p0,16);//3
    assert(p2 == p0 + 1);
    p3 = alloc_pages(8);
    test_print(p0,16);//4
    assert(p3 == p0 + 8);
    assert(!PageProperty(p3) && !PageProperty(p3 + 7) && PageProperty(p3 + 8));
    // 回收页
    free_pages(p1, 2);
    test_print(p0,16);//5
    //assert(PageProperty(p1) && PageProperty(p1 + 1));参考代码修正
    assert(PageProperty(p1) && !PageProperty(p1 + 1));
    assert(p1->ref == 0);
    free_pages(p0, 1);
    test_print(p0,16);//6
    free_pages(p2, 1);
    test_print(p0,16);//7
    // 回收后再分配
    p2 = alloc_pages(3);
    test_print(p0,16);//8
    assert(p2 == p0);
    free_pages(p2, 3);//9
    assert((p2 + 2)->ref == 0);
    test_print(p0,16);//10
    //assert(nr_free_pages() == all_pages >> 1);
    p1 = alloc_pages(129);
    test_print(p0,16);//11
    assert(p1 == p0 + 256);
    //free_pages(p1, 256);
    free_pages(p1, 129);//参考代码适配
    test_print(p0,16);//12
    free_pages(p3, 8);
    test_print(p0,16);//13
}

const struct pmm_manager buddy_system_pmm_manager = 
{
    .name = "buddy_system_pmm_manager",
    .init = buddy_system_init,
    .init_memmap = buddy_system_init_memmap,
    .alloc_pages = buddy_system_alloc_pages,
    .free_pages = buddy_system_free_pages,
    .nr_free_pages = buddy_system_nr_free_pages,
    .check = buddy_system_check,
};
//################################################################################