#ifndef __KERN_MM_VMM_H__
#define __KERN_MM_VMM_H__

#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <sync.h>

//pre define
struct mm_struct;

// 虚拟连续存储区（vma），[vm_start，vm_end）
// addr属于vma意味着vma.vm_start<= addr <vma.vm_end
struct vma_struct {
    struct mm_struct *vm_mm; // 使用相同PDT的vma集合
    uintptr_t vm_start;      // vma的起始地址    
    uintptr_t vm_end;        // vma的结束地址，不包括vm_end本身
    uint_t vm_flags;         // vma标志(权限)
    list_entry_t list_link;  // 按vma起始地址排序的有序链表节点
};

#define le2vma(le, member)                  \
    to_struct((le), struct vma_struct, member)

#define VM_READ                 0x00000001
#define VM_WRITE                0x00000002
#define VM_EXEC                 0x00000004

// 使用相同页目录表的一组vma的控制结构(the control struct for a set of vma using the same PDT)
struct mm_struct {
    list_entry_t mmap_list;        // 按vma起始地址排序的有序链表
    struct vma_struct *mmap_cache; // 当前访问的vma，出于速度考虑(used for speed purpose)
    pde_t *pgdir;                  // 这些vma的页目录表
    int map_count;                 // 这些vma的数量
    void *sm_priv;                 // swap管理器的私有数据
};

struct vma_struct *find_vma(struct mm_struct *mm, uintptr_t addr);
struct vma_struct *vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags);
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma);

struct mm_struct *mm_create(void);
void mm_destroy(struct mm_struct *mm);

void vmm_init(void);

int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr);

extern volatile unsigned int pgfault_num;
extern struct mm_struct *check_mm_struct;

#endif /* !__KERN_MM_VMM_H__ */

