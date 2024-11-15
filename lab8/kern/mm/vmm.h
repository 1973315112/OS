#ifndef __KERN_MM_VMM_H__
#define __KERN_MM_VMM_H__

#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <sync.h>
#include <sem.h>
#include <proc.h>
//pre define
struct mm_struct;

// 虚拟连续内存区域（vma），[vm_start, vm_end)
// 地址属于一个 vma 意味着 vma.vm_start <= addr < vma.vm_end
struct vma_struct {
    struct mm_struct *vm_mm; // 使用相同页目录表（PDT）的一组 vma
    uintptr_t vm_start;      // vma 的起始地址
    uintptr_t vm_end;        // vma 的结束地址，不包括 vm_end 本身
    uint32_t vm_flags;       // vma 的标志
    list_entry_t list_link;  // 按 vma 起始地址排序的线性链表链接
};

#define le2vma(le, member)                  \
    to_struct((le), struct vma_struct, member)

#define VM_READ                 0x00000001
#define VM_WRITE                0x00000002
#define VM_EXEC                 0x00000004
#define VM_STACK                0x00000008

// 使用相同页目录表（PDT）的一组虚拟内存区域（VMA）的控制结构体
struct mm_struct {
    list_entry_t mmap_list;        // 按 VMA 起始地址排序的线性链表链接
    struct vma_struct *mmap_cache; // 当前访问的 VMA，用于加速访问
    pde_t *pgdir;                  // 这些 VMA 的页目录表（PDT）
    int map_count;                 // 这些 VMA 的数量
    void *sm_priv;                 // 交换管理器的私有数据
    int mm_count;                  // 共享该 mm 的进程数量
    semaphore_t mm_sem;            // 用于使用 dup_mmap 函数复制 mm 的互斥信号量
    int locked_by;                 // 锁定该 mm 的进程 ID
};

struct vma_struct *find_vma(struct mm_struct *mm, uintptr_t addr);
struct vma_struct *vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags);
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma);

struct mm_struct *mm_create(void);
void mm_destroy(struct mm_struct *mm);

void vmm_init(void);
int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store);
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr);

int mm_unmap(struct mm_struct *mm, uintptr_t addr, size_t len);
int dup_mmap(struct mm_struct *to, struct mm_struct *from);
void exit_mmap(struct mm_struct *mm);
uintptr_t get_unmapped_area(struct mm_struct *mm, size_t len);
int mm_brk(struct mm_struct *mm, uintptr_t addr, size_t len);

extern volatile unsigned int pgfault_num;
extern struct mm_struct *check_mm_struct;

bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);
bool copy_string(struct mm_struct *mm, char *dst, const char *src, size_t maxn);

static inline int
mm_count(struct mm_struct *mm) {
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
    return mm->mm_count;
}

static inline int
mm_count_dec(struct mm_struct *mm) {
    mm->mm_count -= 1;
    return mm->mm_count;
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        down(&(mm->mm_sem));
        if (current != NULL) {
            mm->locked_by = current->pid;
        }
    }
}

static inline void
unlock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        up(&(mm->mm_sem));
        mm->locked_by = 0;
    }
}

#endif /* !__KERN_MM_VMM_H__ */

