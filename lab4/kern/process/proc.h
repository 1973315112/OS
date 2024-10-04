#ifndef __KERN_PROCESS_PROC_H__
#define __KERN_PROCESS_PROC_H__

#include <defs.h>
#include <list.h>
#include <trap.h>
#include <memlayout.h>


// process's state in his life cycle
enum proc_state {
    PROC_UNINIT = 0,  // 未初始化
    PROC_SLEEPING,    // 挂起(sleeping)
    PROC_RUNNABLE,    // 等待或者运行（runnable(maybe running)）
    PROC_ZOMBIE,      // 僵尸进程:近似死亡，等待父进程回收资源(almost dead, and wait parent proc to reclaim his resource)
};

struct context {
    uintptr_t ra;
    uintptr_t sp;
    uintptr_t s0;
    uintptr_t s1;
    uintptr_t s2;
    uintptr_t s3;
    uintptr_t s4;
    uintptr_t s5;
    uintptr_t s6;
    uintptr_t s7;
    uintptr_t s8;
    uintptr_t s9;
    uintptr_t s10;
    uintptr_t s11;
};

#define PROC_NAME_LEN               15
#define MAX_PROCESS                 4096
#define MAX_PID                     (MAX_PROCESS * 2)

extern list_entry_t proc_list;

struct proc_struct {
    enum proc_state state;                      // 进程状态
    int pid;                                    // 进程ID
    int runs;                                   // 进程运行的时间
    uintptr_t kstack;                           // 进程内核堆栈
    volatile bool need_resched;                 // bool类型:是否需要重新调度以释放CPU
    struct proc_struct *parent;                 // 父进程
    struct mm_struct *mm;                       // 进程的内存管理器(field)
    struct context context;                     // 在此处切换以运行进程(Switch here to run process)
    struct trapframe *tf;                       // 当前中断的陷入表(Trap frame for current interrupt)
    uintptr_t cr3;                              // CR3寄存器：二级页表（Page Directroy Table，PDT）的基地址
    uint32_t flags;                             // 进程标志
    char name[PROC_NAME_LEN + 1];               // 进程名称
    list_entry_t list_link;                     // 进程链表
    list_entry_t hash_link;                     // 进程哈希链表
};

#define le2proc(le, member)         \
    to_struct((le), struct proc_struct, member)

extern struct proc_struct *idleproc, *initproc, *current;

void proc_init(void);
void proc_run(struct proc_struct *proc);
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags);

char *set_proc_name(struct proc_struct *proc, const char *name);
char *get_proc_name(struct proc_struct *proc);
void cpu_idle(void) __attribute__((noreturn));

struct proc_struct *find_proc(int pid);
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf);
int do_exit(int error_code);

#endif /* !__KERN_PROCESS_PROC_H__ */

