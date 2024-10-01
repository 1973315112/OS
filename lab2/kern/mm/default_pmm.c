#include <pmm.h>
#include <list.h>
#include <string.h>
#include <default_pmm.h>

/*
    在first-fit算法中，分配器保留一个空闲块链表（称为空闲链表），在收到内存分配请求后，沿着链表扫描第一个足够大的满足请求的块，
    如果所选块明显大于请求的块，则通常会拆分，其余部分作为另一个空闲块添加到链表中。
    请参阅严伟民中文著作《数据结构——C编程语言》第8.2节第196~198页
*/
// 您应该重写函数：default_init(),default_init_memmap(),default_alloc_pages(), default_free_pages().
/*
 * Details of FFMA
 * (1) 准备：为了实现First Fit内存分配算法（First Fit Mem Alloc,FFMA），我们应该使用一些链表来管理空闲内存块。
 *          使用结构体free_area_t用于管理空闲内存块。首先，您应该熟悉list.h中的结构体链表。struct list是一个简单的双链表实现。
 *          你应该知道如何使用：list_init()、list_add()（list_add_after() ）、list_add_before()、list_del()、list_next()、list_prev()
 *          另一个困难的问题是如何将一个通用的链表结构体转换为一个特殊的结构体（如页表结构体）：
 *          你可以找到一些宏定义:le2page（在memlayout.h中)(在未来的lab中：le2vma（在vmm.h中）,le2proc（在proc.h中）等。）
 * (2) default_init()：您可以重用示例default_init()函数来初始化freelist并将nrfree设置为0。
 *                     freelist用于记录空闲的内存块。nrfree是空闲内存块的总数。
 * (3) default_init_memmap():调用顺序：kern_init --> pmm_init-->page_init-->init_memmap--> pmm_manager->init_memmap
 *                          此函数用于初始化空闲块（参数为：addr_base，page_number）。
 *                          首先，你应该初始化这个空闲块中的每个页面（在memlayout.h中），包括：
 *                          p->flags应设置为位PG_property（表示此页面有效。在pmm.c中的pmm_init()函数中，位PG_reserved设置在p->flags中。
 *                          如果此页面是空闲的，并且不是空闲块的第一页，则p->property应设置为0。
 *                          如果此页面是空闲的，并且是空闲块的第一页，则p->property应设置为块的总数。
 *                          p->ref应该是0，因为现在p是空闲的，没有引用。
 *                          我们可以使用p->page_link将此页面链接到free_list（例如：list_add_before（&free_list，&（p->page-link））；）
 *                          最后，我们应该将空闲内存块的数量相加：nr_free+=n
 * (4) default_alloc_pages()：在空闲列表中搜索第一个空闲块（块大小>=n），并对空闲块进行reszie，返回分配的块的地址。
 *                         （4.1）所以你应该这样搜索freelist：
 *                                  list_entry_t le = &free_list;
 *                                  while((le=list_next(le)) != &free_list) {
 *                                  ....
 *                              (4.1.1) 在while循环中，获取结构体页面并检查p->property（记录空闲块的数量）是否>=n
 *                                      struct Page *p = le2page(le, page_link);
 *                                      if(p->property >= n){ ...
 *                              (4.1.2) 如果我们找到这个p，那么这意味着我们找到了一个空闲块（块大小>=n），并且前n个页面可以被分配。
 *                                      应设置此页面的某些标志位： PG_reserved =1, PG_property =0
 *                                      取消页面与free_list的链接
 *                                      (4.1.2.1) 如果（p->property>n），我们应该重新计算这个空闲块剩余部分的块数(例如:le2page(le,page_link))->property = p->property - n;)
 *                              (4.1.3) 重新计算nr_free（所有空闲块剩余部分的数量）
 *                              (4.1.4) 返回p
 *                           (4.2) 如果我们找不到空闲块（块大小>=n），则返回NULL
 *(5) default_free_pages(): relink the pages into  free list, maybe merge small free blocks into big free blocks.
 *               (5.1) according the base addr of withdrawed blocks, search free list, find the correct position
 *                     (from low to high addr), and insert the pages. (may use list_next, le2page, list_add_before)
 *               (5.2) reset the fields of pages, such as p->ref, p->flags (PageProperty)
 *               (5.3) try to merge low addr or high addr blocks. Notice: should change some pages's p->property correctly.
 * (5) default_free_pages()：将页面重新链接到自由链表中，可能会将小空闲块合并为大空闲块。
 *                          (5.1) 根据释放区块的基址，搜索空闲列表，找到正确的位置(从低到高地址），并插入页表。（可以使用list_next()、le2page()、list_add_before() ）
 *                          (5.2) 重新设置页面的属性，如p->ref, p->flags (PageProperty)
 *                          (5.3) 尝试合并低地址或高地址块。注意：应该正确更改某些页面的p->property。
 */
static free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
}

static void
default_init_memmap(struct Page *base, size_t n) {
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

static size_t
default_nr_free_pages(void) {
    return nr_free;
}

// 注意：您不应该更改basic_check！！！
static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p);
    free_page(p1);
    free_page(p2);
}

// LAB2：以下代码用于检查first-fit内存分配算法
// 注意：您不应该更改basic_check、default_check函数！
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
    assert(alloc_pages(4) == NULL);
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
    assert((p1 = alloc_pages(3)) != NULL);
    assert(alloc_page() == NULL);
    assert(p0 + 2 == p1);

    p2 = p0 + 1;
    free_page(p0);
    free_pages(p1, 3);
    assert(PageProperty(p0) && p0->property == 1);
    assert(PageProperty(p1) && p1->property == 3);

    assert((p0 = alloc_page()) == p2 - 1);
    free_page(p0);
    assert((p0 = alloc_pages(2)) == p2 + 1);

    free_pages(p0, 2);
    free_page(p2);

    assert((p0 = alloc_pages(5)) != NULL);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);
}
//这个结构体在
const struct pmm_manager default_pmm_manager = {
    .name = "default_pmm_manager",
    .init = default_init,
    .init_memmap = default_init_memmap,
    .alloc_pages = default_alloc_pages,
    .free_pages = default_free_pages,
    .nr_free_pages = default_nr_free_pages,
    .check = default_check,
};

