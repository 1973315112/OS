# lab2
该实验报告和完整代码已上传[github](https://github.com/1973315112/OS)

## 练习1：理解first-fit 连续物理内存分配算法（思考题）

first-fit 连续物理内存分配算法作为物理内存分配一个很基础的方法，需要同学们理解它的实现过程。请大家仔细阅读实验手册的教程并结合`kern/mm/default_pmm.c`中的相关代码，认真分析`default_init`，`default_init_memmap`，`default_alloc_pages`， `default_free_pages`等相关函数，并描述程序在进行物理内存分配的过程以及各个函数的作用。 请在实验报告中简要说明你的设计实现过程。请回答如下问题：
* 你的first fit算法是否有进一步的改进空间？

### `default_init()`
```c
static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
}
```
该函数初始化first-fit内存管理器。它将空闲物理页链表的头节点free_list初始化为空链表，并将空闲物理页计数器nr_free设置为0。这些字段属于free_area_t结构体，用于存储空闲物理页的相关信息。

### `default_init_memmap(struct Page *base, size_t n)`
该函数初始化以`base`为基址，包含`n`个页面的页块。每个页面由`struct Page`结构体表示：
```c
struct Page {
    int ref;                       
    uint64_t flags;             
    unsigned int property;         
    list_entry_t page_link;        
};
```
函数实现如下：
```c
static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
}
```
该函数执行以下任务：
1. 初始化页块：给定页块的基址`base`和大小`n`，函数依次将每个页面的`flags`和`property`设为`0`，并将引用计数`ref`设为`0`。`flags`的两个比特位表示页面的保留状态和属性：
    * `PG_reserved`：表示页面是否为内核保留页。
    * `PG_property`：表示页面是否为一个空闲页块的首页。
页块的第一个页面的`property`成员设为`n`，表示该页块内包含`n`个连续的空闲页。
2. 插入空闲链表：
    * 空链表：如果空闲链表为空，则直接将该页块插入。
    * 非空链表：若链表不为空，则按页块的地址顺序插入。遍历链表，找到第一个地址大于该页块的节点，将其插入该节点之前；若遍历到链表尾仍未找到合适位置，则将其插入链表末尾。

### `default_alloc_pages(size_t n)`
该函数根据 `first-fit` 思想分配内存。给定页数 `n` 后，该算法从空闲页块链表中找到第一个包含大等于`n`个连续空闲页的页块，并进行分配。
```c
static struct Page *
default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
        list_entry_t* prev = list_prev(&(page->page_link));
        list_del(&(page->page_link));
        if (page->property > n) {
            struct Page *p = page + n;
            p->property = page->property - n;
            SetPageProperty(p);
            list_add(prev, &(p->page_link));
        }
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;
}
```

该函数实现的过程分为两个步骤：
1. 找到满足需求的页块：通过遍历空闲页块链表 `free_list`，找到第一个 `p->property >= n` 的页块，保存其指针并跳出循环。
2. 调整空闲链表：
    * 分配页块：找到满足需求的页块后，从链表中删除该页块。如果该页块的大小超过需求，则拆分多余部分，并将剩余部分重新插入到链表中。
    * 更新空闲页数量：减去已分配的页数 `n`，并清除分配出去的页块的 `PG_property` 标志。

### `default_free_pages(struct Page *base, size_t n)`
该函数用于释放从基址 `base` 开始的连续 `n` 个物理页面，并将它们重新加入空闲链表中。
```c
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;

    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }

    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (p + p->property == base) {
            p->property += base->property;
            ClearPageProperty(base);
            list_del(&(base->page_link));
            base = p;
        }
    }

    le = list_next(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
    }
}
```
该函数的实现步骤如下：
1. 释放页块：首先将 `base` 开始的连续 `n` 页的标志位和引用计数清除，并将第一个页面的 `property` 设为 `n`，表示该页块包含 `n` 个空闲页。
2. 重新加入空闲链表：将 `base` 重新插入到空闲链表中，按页地址的顺序插入到合适位置。
3. 合并空闲页块：
    * 与前一页块合并：检查当前页块的前一页块，如果它与当前页块是连续的，则合并它们，更新页块大小并清除当前页块的属性标记。
    * 与后一页块合并：检查当前页块的后一页块，执行类似的合并操作。

###  `first fit` 算法的进一步的改进空间
#### 优化搜索效率
在当前实现中，`first-fit` 通过遍历空闲链表寻找第一个符合条件的块。在大型系统中，这种线性搜索可能导致性能瓶颈。可以考虑使用平衡树（如红黑树、AVL树）或其他高级数据结构（如跳表）来存储空闲页块。这样可以加速搜索过程，减少查找合适块所需的时间，但需要权衡数据结构维护的开销。
#### 延迟碎片合并策略
每次释放页面时立即合并相邻的空闲页块会带来性能开销。可以改进为延迟合并策略，即在内存压力较低时或定期进行批量合并，减少释放时的开销。通过延迟合并的方式可以在高负载时提高系统性能。
#### 预分配
基于系统的历史内存使用模式和负载信息，可以预测未来的内存需求。对于常见的内存分配请求，可以预先保留一定数量的内存块，避免在分配时频繁从空闲链表中查找，减少分配的等待时间。
#### 双向查找改进
在 `first-fit` 算法中，当前搜索从链表头开始查找。如果允许从上次找到的空闲块位置继续查找，或者在空闲列表中进行双向搜索，可以减少查找的时间，特别是在空闲链表较长时，避免重复搜索的开销。
#### 快速路径分配
对于小型或特定大小的内存分配请求，可以设计专门的快速分配路径，避免进入常规的分配逻辑。这种方式通过优化常见的内存请求场景，提升内存管理的整体效率。
#### 异步化内存管理
可以考虑将内存分配和释放操作异步化，利用多线程的优势。内存释放时可以先标记空闲，再通过后台线程进行真正的合并操作，避免释放过程中阻塞其他内存操作，进一步提高并发性能。

## 练习2：实现 Best-Fit 连续物理内存分配算法（需要编程）
在完成练习一后，参考`kern/mm/default_pmm.c`对`First Fit`算法的实现，编程实现`Best Fit`页面分配算法，算法的时空复杂度不做要求，能通过测试即可。 请在实验报告中简要说明你的设计实现过程，阐述代码是如何对物理内存进行分配和释放，并回答如下问题：
* 你的 Best-Fit 算法是否有进一步的改进空间？

### 设计实现过程
#### `static void best_fit_init_memmap(struct Page *base, size_t n)`
具体实现和`first-fit`完全相同：
```c
static void best_fit_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list)
        {
            struct Page* page = le2page(le, page_link);
            if (base < page)
            {
                list_add_before(le, &(base->page_link));
                break;
            }
            else if (list_next(le) == &free_list)
            {
                list_add(le, &(base->page_link));
            }
        }
    }
}
```
#### `static struct Page *best_fit_alloc_pages(size_t n)`
与 `first-fit` 不同的是，`best-fit` 需要遍历空闲链表寻找最合适的页块，也就是大等于需求`n` 的最小页块，这样可以减少内存碎片化的可能性，但由于每次都需要遍历整个链表，查找效率较低。

```c
static struct Page *
best_fit_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    size_t min_size = nr_free + 1;
    while ((le = list_next(le)) != &free_list) 
    {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n && p->property < min_size) 
        {
            page = p;
            min_size = p->property;
        }
    }

    if (page != NULL) {
        list_entry_t* prev = list_prev(&(page->page_link));
        list_del(&(page->page_link));
        if (page->property > n) {
            struct Page *p = page + n;
            p->property = page->property - n;
            SetPageProperty(p);
            list_add(prev, &(p->page_link));
        }
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;
}
```

#### `static void best_fit_free_pages(struct Page *base, size_t n)`
释放占用的块，具体实现和`first-fit`一模一样：
```c
static void best_fit_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n; 
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &free_list) 
    {
        p = le2page(le, page_link);
        if (p + p->property == base)
        {
            p->property += base->property; 
            ClearPageProperty(base); 
            list_del(&(base->page_link)); 
            base = p; 
        }
    }
    le = list_next(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
    }
}
```
### `best fit` 算法的进一步的改进空间
优化改进与`first fit`算法类似
#### 分级内存管理
将内存划分为不同大小的页块，并为每种大小维护独立的链表或链表数组，这种方式类似于多级分配器（如伙伴系统）。当需要分配页面时，直接从对应大小的链表中进行分配，避免了线性搜索。通过这种分层管理，可以快速定位合适的空闲块，进一步提高分配效率。
#### 小块内存缓存机制
对于频繁分配和释放的小块内存，可以引入缓存机制（如 slab 分配器）。通过缓存常见的内存块大小，减少频繁的分配和释放操作，避免碎片化的加剧。同时，缓存机制可以显著降低锁的竞争，提升并发性能。
#### 异步化内存管理
可以考虑将内存分配和释放操作异步化，利用多线程的优势。内存释放时可以先标记空闲，再通过后台线程进行真正的合并操作，避免释放过程中阻塞其他内存操作，进一步提高并发性能。



## 扩展练习Challenge：buddy system（伙伴系统）分配算法（需要编程）
Buddy System算法把系统中的可用存储空间划分为存储块(Block)来进行管理, 每个存储块的大小必须是2的n次幂(Pow(2, n)), 即1, 2, 4, 8, 16, 32, 64, 128...
* 参考伙伴分配器的一个[极简实现](https://coolshell.cn/articles/10427.html)， 在ucore中实现buddy system分配算法，要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

### 简介
Buddy system是一种内存分配算法，用于管理操作系统中的内存。该算法能够有效地管理内存块，分配，释放和合并内存块的复杂度均为O(logN)，因此该算法特别适用于需要频繁分配和释放内存的场景。（但由于这一算法只能分配2的幂次方的内存，因此可能存在内存空间的浪费，实质上是一种用空间换时间的方法）。

#### 基本原理
Buddy system的核心思想是将内存单元递归的两两分组成为伙伴，当分割和合并的时候，只允许伙伴之间进行分割和合并。通过这种方式，内存被划分为2的幂次方的存储块，可以通过完全二叉树(线段树)将这些块组织成层次结构。

分配过程：Buddy system接收请求，将需求转换为大等于它的最小的2的幂次方，然后从根节点开始在二叉树上寻找符合要求的内存块，最后对二叉树进行回溯对伙伴内存块进行拆分。

回收过程：Buddy system将内存进行释放，然后从叶节点开始向上遍历二叉树，从而实现对伙伴内存块的合并。

# Buddy System内存管理器设计文档
林逸典 2024/10/24
## 引言
本程序实现了Buddy System内存管理器，用于管理以页为单位的内存空间。

## 关键结构与函数
### 主要管理结构:`struct free_area_tree`
Buddy system管理结构体，主要包含二叉树结构，还包含部分辅助变量
```c
struct free_area_tree
{
    struct Page *Base;                // 连续内存块的基地址
    size_t* free_tree;                // 二叉树数组根节点(指针)
    unsigned int nr_free;             // 当前可用页框(物理页)数
    unsigned int true_size;           // 真正的总可用页框(物理页)数
    unsigned int max_size;            // 虚拟的总可用页框(物理页)数
};

static struct free_area_tree free_area;
```

### 关键函数
以下是Buddy system的关键函数，我们将对最为重要的分配和释放函数进行完整展示。
```c
/*
 * 功能:初始化free_area(清空性质)
 */
static void buddy_system_init(void) 

/*
 * 功能:初始化buddy_system内存管理器
 * 参数：
 * @base:      连续空闲块的基底址指针
 * @n:         连续空闲块的数量
 * 注意:n会向下变为2的幂，多余的空间将无法被使用
 */
static void buddy_system_init_memmap(struct Page *base, size_t n) 

/*
 * 功能:buddy_system分配空闲块
 * 参数：
 * @n:         申请的空闲块数量
 * 注意:n会向上变为2的幂
 */
static struct Page* buddy_system_alloc_pages(size_t n) 

/*
 * 功能:buddy_system释放空闲块
 * 参数：
 * @base       释放的内存块的基底址
 * @n:         释放的空闲块数量
 * 注意:n会向上变为2的幂
 */
static void buddy_system_free_pages(struct Page *base, size_t n) 

/*
 * 功能:返回剩余的可用物理页数
 * 注意:该函数返回值代表总共的可用可用物理页数，不代表可以申请连续的这么多
 */
static size_t buddy_system_nr_free_pages(void) 

/*
 * 功能:检查buddy_system是否正确
 * 注意:本函数参考自https://github.com/AllenKaixuan/Operating-System/blob/main/labcodes/lab2/kern/mm/buddy_pmm.c的buddy_check()函数。
 * 注意:以上参考代码本身存在一定缺陷（甚至可以说是错误）,对其进行较大幅度修正。
 */
static void buddy_system_check(void) 
```

#### `static struct Page* buddy_system_alloc_pages(size_t n) `
空闲内存块分配函数，通过遍历空闲块二叉树，寻找合适的节点，进行分配。
```c
/*
 * 功能:buddy_system分配空闲块
 * 参数：
 * @n:         申请的空闲块数量
 * 注意:n会向上变为2的幂
 */
static struct Page* buddy_system_alloc_pages(size_t n) 
{
    assert(n > 0);
    if (n > nr_free)     return NULL;
    n = up_to_2_power(n);
    if( n>free_tree[0] ) return NULL;
    nr_free -= n;

    struct Page* page = NULL ;
    size_t i = 0,size = max_size,offset = 0;
    //向下寻找合适的节点:当左右子树都不满足条件时，使用当前节点进行分配
    while (free_tree[(i<<1)+1]>=n || free_tree[(i<<1)+2]>=n)
    {
        if(free_tree[(i<<1)+1]>=n) i = (i<<1)+1;
        else i = (i<<1)+2;
        size = size>>1;
    }
    //分配:
    offset = (i + 1) * size - max_size;
    free_tree[i] = 0;
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
        free_tree[i]=max(free_tree[(i<<1)+1],free_tree[(i<<1)+2]);
        if( i%2==1 && free_tree[i+1]==size) 
        {
            struct Page* right = Base+offset+size;
            right->property = size;
            SetPageProperty(right);            
        }
    }
    return page;
}
```


#### `static void buddy_system_free_pages(struct Page *base, size_t n) `
内存块释放函数，通过遍历空闲块二叉树，对伙伴内存块进行合并。
```c
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
```
## 功能测试
我们通过`buddy_system_check（）`函数对Buddy System内存管理器的功能进行测试，其表现良好，执行过程符合预期。

我们使用Buddy System内存管理器运行lab2的程序，实验结果正确。

我们还使用Buddy System内存管理器运行lab4的程序，并使其支持slub内存管理器，实验结果正确。

综上所述，我们对Buddy System进行了比较充分的测试，说明其实现的正确性。

## 扩展练习Challenge：任意大小的内存单元slub分配算法（需要编程）
slub算法，实现两层架构的高效内存单元分配，第一层是基于页大小的内存分配，第二层是在第一层基础上实现基于任意大小的内存分配。可简化实现，能够体现其主体思想即可。

* 参考[linux的slub分配算法](https://github.com/torvalds/linux/blob/master/mm/slub.c)，在ucore中实现slub分配算法。要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

# slub内存管理器设计文档
林逸典 2024/10/24
## 引言
本程序实现了slub内存管理器，用于管理以Byte为单位的任意大小内存空间，其中第一层基于页大小的内存分配使用Buddy System内存管理器，在此不做赘述。完整代码已上传[github](https://github.com/1973315112/OS/blob/main/lab4/kern/mm/kmalloc.c)

## 管理结构体
考虑到slub分配算法相关的结构体关系复杂，我们在此对其进行命名和包含关系说明。
```c
/*
 * slub_t[] Slubs:slub内存管理器组，可以管理小于一页物理页的内存分配和释放
 *     slub_t slub:slub内存管理器,可以管理一种固定大小的内存分配和释放
 *         slub_cache_waiting wait:slub内存管理器的等待缓冲区
 *             	object* partial :等待缓冲区的半空闲状态的物理页链表
 *          	object* full    :等待缓冲区的忙碌状态的物理页链表
 *         slub_cache_working work:slub内存管理器的工作缓冲区
 *              object* freelist:工作缓冲区的物理页
 */
```
### `struct object`
```c
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
```

### `struct slub_cache_waiting`
```c
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
```

### `slub_cache_working`
```c
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
```

### `slub_t`
```c
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
```

### 关键函数
```c

/*
 * 功能:初始化slub内存管理器
 */
void slub_init(void) 

/*
 * 功能:使用slub分配器分配内存
 * 参数:
 *		@size :请求分配的内存的大小(包括首部，因此>=16,且已规范为2^n）
 *		@gfp  :位掩码，用于表示内存分配的各种选项和限制(这里可能一般为0)
 *		@align:指定分配的内存块需要对齐的边界(这里可能一般为0)
 * 注意:暂时未考虑对齐问题(待改进)
 */
static void* slub_alloc(size_t size, gfp_t gfp, int align)

/*
 * 功能:使用slub分配器释放内存
 * 参数:
 * 		@block:slob单链表的节点
 *		@size :请求释放的内存的大小 
 * 注意:目前当一页为空时会被立即释放，可能影响效率（有待改进）
 */
static void slub_free(void* block, int size)

/*
 * 功能:slub内存管理器的启动自检程序
 */
static void kmalloc_check(void) 
```

## 功能测试
我们通过`kmalloc_check（）`函数对slub内存管理器的功能进行测试，其表现良好，执行过程符合预期。

我们还使用slub内存管理器运行lab4的程序，实验结果正确。

综上所述，我们对slub进行了比较充分的测试，说明其实现的正确性。

## 扩展练习Challenge：硬件的可用物理内存范围的获取方法（思考题）
* 如果 OS 无法提前知道当前硬件的可用物理内存范围，请问你有何办法让 OS 获取可用物理内存范围？

如果操作系统无法提前知道当前硬件的可用物理内存范围，且无法通过传统的方法（如BIOS、UEFI、设备树、引导加载器等）获取该信息，可以通过`内存探测（Memory Probing）`的方法来获取可用物理内存范围。

具体的实现方式是从一个已知的安全内存地址开始（例如，内核映像结束后的地址），向该内存地址写入一个已知的测试模式（例如，`0x55AA55AA`），然后读取该内存地址的内容，验证是否与写入的测试模式一致。
如果读取的值与写入的值一致，认为该内存地址是可用的；如果发生异常或读取的值不一致，认为已达到内存的末尾或进入了不可用的内存区域。

### 实现方法
#### 设置异常处理器
在RISC-V架构下，需要设置合适的异常处理器，以捕获由于非法内存访问引发的异常。
* 选择异常级别：根据操作系统运行的特权级（`M-mode`或`S-mode`），设置对应级别的异常处理器。
* 注册异常处理函数：实现异常处理函数，并在异常向量表中注册。
* 处理存储/加载访问故障：在异常处理函数中，捕获`Load/Store Access Fault`等异常类型。
处理异常的时候，先记录异常信息，保存导致异常的内存地址和异常类型，然后跳转回内存探测程序，停止进一步的内存探测，防止系统崩溃。
#### 迭代探测内存
首先会进行参数的初始化：比如起始地址（`start_addr`）、最大地址（`max_addr`）、步长（`step`）等，然后对当前地址调用内存测试函数`test_memory(addr)`。在探测之前，尽可能了解系统中常见的设备映射地址范围，限制最大探测地址在已知的物理内存范围内，防止访问到硬件设备或未映射的区域。
#### 记录可用内存范围
在探测完成后，得到一系列连续的内存地址，这些地址被认为是可用的物理内存，需要将这些信息保存到内存管理模块，然后更新内存布局数据结构（如页表、内存段描述符等）。

### 示例代码
#### 异常处理器的实现
```c
// 异常处理器声明
void trap_handler();

// 异常向量表设置
void init_trap() {
    // 设置异常向量基地址为trap_handler的地址
    write_csr(mtvec, &trap_handler);
}

// 异常处理函数
void trap_handler() {
    uintptr_t scause = read_csr(scause);
    uintptr_t stval = read_csr(stval);

    // 判断是否为加载/存储访问故障
    if ((scause & 0xFFF) == 5 || (scause & 0xFFF) == 7) {
        // 记录故障地址
        memory_probe_failed_addr = stval;
        // 设置标志位，表示探测结束
        memory_probe_done = 1;
        // 调整程序计数器，跳过导致异常的指令
        uintptr_t sepc = read_csr(sepc);
        write_csr(sepc, sepc + 4);
    } else {
        // 处理其他异常
        while (1);
    }
}
```
#### 内存探测函数的实现
```c
volatile int memory_probe_done = 0;
volatile uintptr_t memory_probe_failed_addr = 0;

void memory_probe(uintptr_t start_addr, uintptr_t max_addr, size_t step) {
    uintptr_t addr = start_addr;
    init_trap(); // 初始化异常处理器

    while (addr < max_addr && !memory_probe_done) {
        if (test_memory(addr)) {
            addr += step;
        } else {
            break;
        }
    }

    if (memory_probe_done) {
        // 探测结束，获取可用内存范围
        uintptr_t available_memory_end = memory_probe_failed_addr;
        printf("Available memory: 0x%lx - 0x%lx\n", start_addr, available_memory_end);
    } else {
        // 正常探测完成
        printf("Available memory: 0x%lx - 0x%lx\n", start_addr, addr);
    }
}

bool test_memory(uintptr_t addr) {
    volatile uint32_t *ptr = (uint32_t *)addr;
    uint32_t original_value;

    // 异常处理标志复位
    memory_probe_done = 0;

    // 保存原始值
    original_value = *ptr;

    // 写入测试值
    *ptr = 0x55AA55AA;
    __sync_synchronize(); // 确保写入完成

    // 读取验证
    uint32_t read_value = *ptr;

    // 恢复原始值
    *ptr = original_value;

    // 检查是否发生异常
    if (memory_probe_done) {
        return false;
    }

    return read_value == 0x55AA55AA;
}
```
