//################################################################################
/*LAB2 EXERCISE 2: 2213917 CODE*/ 
#ifndef __KERN_MM_BUDDY_SYSTEM_PMM_H__
#define __KERN_MM_BUDDY_SYSTEM_PMM_H__

#include <pmm.h>

struct free_area_tree
{
    struct Page *Base;                // 连续内存块的基底址
    size_t* free_tree;                // 二叉树数组根节点(指针)
    unsigned int nr_free;             // 此空闲链表中的可用页框(物理页)数
    unsigned int true_size;           // 真正的可用页框(物理页)数
    unsigned int max_size;            // 虚拟的可用页框(物理页)数
};

extern struct free_area_tree free_area;
extern const struct pmm_manager buddy_system_pmm_manager;

#endif /* ! __KERN_MM_BEST_FIT_PMM_H__ */
//################################################################################