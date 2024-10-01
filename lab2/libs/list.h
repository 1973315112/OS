#ifndef __LIBS_LIST_H__
#define __LIBS_LIST_H__

#ifndef __ASSEMBLER__

#include <defs.h>

/* *
 * 本文件为简单的双向链表实现。
 * 一些内部函数（“__xxx”）在操作整个链表而不是单个节点时很有用:
 * 当我们已经知道下一个或上一个节点，可以直接使用内部函数，
 * 而不是使用针对单个节点的通用函数来生成更好的代码。
 * 
 * 注意:我们把list_entry作为其他结构体的成员，
 *     就可以利用C语言结构体内存连续布局的特点，
 *     从`list_entry的地址获得它所在的上一级结构体。
 *     (实例为:连成链表的Page结构体(相关代码位于libs/defs.h,kern/mm/memlayout.h))
 * */

struct list_entry {
    struct list_entry *prev, *next;
};

typedef struct list_entry list_entry_t;

static inline void list_init(list_entry_t *elm) __attribute__((always_inline));
static inline void list_add(list_entry_t *listelm, list_entry_t *elm) __attribute__((always_inline));
static inline void list_add_before(list_entry_t *listelm, list_entry_t *elm) __attribute__((always_inline));
static inline void list_add_after(list_entry_t *listelm, list_entry_t *elm) __attribute__((always_inline));
static inline void list_del(list_entry_t *listelm) __attribute__((always_inline));
static inline void list_del_init(list_entry_t *listelm) __attribute__((always_inline));
static inline bool list_empty(list_entry_t *list) __attribute__((always_inline));
static inline list_entry_t *list_next(list_entry_t *listelm) __attribute__((always_inline));
static inline list_entry_t *list_prev(list_entry_t *listelm) __attribute__((always_inline));

static inline void __list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) __attribute__((always_inline));
static inline void __list_del(list_entry_t *prev, list_entry_t *next) __attribute__((always_inline));

/* *
 * list_init - initialize a new entry
 * 功能:将新节点初始化为链表
 * 参数:
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
}

/* *
 * list_add - add a new entry
 * 功能:添加新节点
 * 参数:
 * @listelm:    新节点将被添加在该节点之后
 * @elm:        被添加的新节点
 *
 * 在列表中已有的节点@listlm*之后*插入新节点@elm
 * */
static inline void
list_add(list_entry_t *listelm, list_entry_t *elm) {
    list_add_after(listelm, elm);
}

/* *
 * list_add_before - add a new entry
 * 功能:添加新节点
 * 参数:
 * @listelm:    新节点将被添加在该节点之前
 * @elm:        被添加的新节点
 *
 * 在列表中已有的元素@listlm*之前*插入新元素@elm
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
}

/* *
 * list_add - add a new entry
 * 功能:添加新节点
 * 参数:
 * @listelm:    新节点将被添加在该节点之后
 * @elm:        被添加的新节点
 *
 * 在列表中已有的元素@listlm*之后*插入新元素@elm
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
}

/* *
 * list_del - deletes entry from list
 * 功能:删除节点(尽量用list_del_init)
 * 参数:
 * @listelm:    被删除的节点
 *
 * 注意：对@listlm调用的list_empty（）在此之后不返回true，该节点处于未定义状态。
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
}

/* *
 * list_del_init - deletes entry from list and reinitialize it.
 * 功能:从链表中删除并重新初始化节点
 * 参数:
 * @listelm:    要从链表中删除的节点
 *
 * 注意：对@listlm调用的list_empty（）在此之后返回true
 * */
static inline void
list_del_init(list_entry_t *listelm) {
    list_del(listelm);
    list_init(listelm);
}

/* *
 * list_empty - tests whether a list is empty
 * 功能:测试链表是否为空
 * 参数:
 * @list:       被检测是否为空的链表
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
}

/* *
 * list_next - get the next entry
 * 功能:获取后一个节点
 * 参数: 
 * @listelm:    当前节点(链表头)
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
}

/* *
 * list_prev - get the previous entry
 * 功能:获取前一个节点
 * 参数:  
 * @listelm:    当前节点(链表头)
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
}

/* *
 * 功能:在两个已知的连续节点之间插入一个新节点。
 * 注意:这仅用于内部列表操作，我们已经知道上一个/下一个节点了！
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
    elm->next = next;
    elm->prev = prev;
}

/* *
 * 功能:通过使上一个和下一个节点相互连接(指向)来删除链表节点。
 * 注意:这仅用于内部列表操作，我们已经知道上一个/下一个节点了！
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
    next->prev = prev;
}

#endif /* !__ASSEMBLER__ */

#endif /* !__LIBS_LIST_H__ */

