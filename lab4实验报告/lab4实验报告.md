# Lab4实验报告
该实验报告和完整代码已上传[github](https://github.com/1973315112/OS)

# 练习1：分配并初始化一个进程控制块（需要编码）

alloc_proc函数（位于kern/process/proc.c中）负责分配并返回一个新的struct proc_struct结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。

【提示】在alloc_proc函数的实现中，需要初始化的proc_struct结构中的成员变量至少包括：state/pid/runs/kstack/need_resched/parent/mm/context/tf/cr3/flags/name。

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

* 请说明proc_struct中struct context context和struct trapframe *tf成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）

## 编程代码

``` c
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
//################################################################################
    //LAB4:EXERCISE1 2213917 CODE
    /*
     * proc_struct中的以下成员变量需要初始化
     *       enum proc_state state;                      // 进程状态
     *       int pid;                                    // 进程ID
     *       int runs;                                   // 进程运行的时间
     *       uintptr_t kstack;                           // 进程内核堆栈
     *       volatile bool need_resched;                 // bool类型:是否需要重新调度以释放CPU
     *       struct proc_struct *parent;                 // 父进程
     *       struct mm_struct *mm;                       // 进程的内存管理器(field)
     *       struct context context;                     // 在此处切换以运行进程(Switch here to run process)
     *       struct trapframe *tf;                       // 当前中断的陷入表(Trap frame for current interrupt)
     *       uintptr_t cr3;                              // CR3寄存器：页目录表（Page Directroy Table，PDT）的基地址
     *       uint32_t flags;                             // 进程标志
     *       char name[PROC_NAME_LEN + 1];               // 进程名称
     */
    //注:初始化是指产生一个空的结构体(或许与c不允许在定义初始化默认值有关),两个memset初始化的变量参考自proc_init()
    //   附注:初始化的具体严格要求参考proc_init()的相关检查语句。
    proc->state        = PROC_UNINIT;
    proc->pid          = -1;                                    
    proc->runs         = 0; 
    proc->kstack       = 0;    
    proc->need_resched = 0;
    proc->parent       = NULL;
    proc->mm           = NULL;
    memset(&(proc->context), 0, sizeof(struct context));
    proc->tf           = NULL;
    proc->cr3          = boot_cr3;
    proc->flags        = 0;
    memset(proc->name, 0, PROC_NAME_LEN+1);                      
//################################################################################
    }
    return proc;
}
```
根据指导手册可知，这里把proc进行初步初始化（即把proc_struct中的各个成员变量清零）。但有些成员变量设置了特殊的值，比如
``` c
proc->state = PROC_UNINIT;  // 设置进程为“初始”态
proc->pid = -1;             // 设置进程pid的未初始化值
proc->cr3 = boot_cr3;       // 使用内核页目录表的基址
```
* 第一条设置了进程的状态为“初始”态，这表示进程已经 “出生”了，正在获取资源茁壮成长中；
* 第二条语句设置了进程的pid为-1，这表示进程的“身份证号”还没有办好；
* 第三条语句表明由于该内核线程在内核中运行，故采用为uCore内核已经建立的页表，即设置为在uCore内核页表的起始地址boot_cr3。

## 问题回答

``` c
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
    uintptr_t cr3;                              // CR3寄存器：页目录表（Page Directroy Table，PDT）的基地址
    uint32_t flags;                             // 进程标志
    char name[PROC_NAME_LEN + 1];               // 进程名称
    list_entry_t list_link;                     // 进程链表
    list_entry_t hash_link;                     // 进程哈希链表
};
```
struct context 保存进程的执行上下文，包括关键寄存器的值，用于在进程切换时还原之前的运行状态。在 proc_run 函数中，通过 switch_to 函数切换进程上下文，将当前进程的 context 保存，并切换到目标进程的 context。

``` c
struct trapframe {
    struct pushregs gpr;    // 通用寄存器
    uintptr_t status;       // 状态寄存器
    uintptr_t epc;          // 异常程序计数器
    uintptr_t badvaddr;     // 导致异常的地址
    uintptr_t cause;        // 异常原因代码
};
```
struct trapframe 保存进程的中断帧，包括32个通用寄存器和异常相关的寄存器。在系统调用时，寄存器的值会改变，通过调整中断帧可以使系统调用返回特定的值。在 kernel_thread 函数中，初始化 trapframe 并设置内核线程的参数和函数指针，然后通过 do_fork 创建一个新进程，并将 trapframe 传递给新进程。


# 练习2：为新创建的内核线程分配资源（需要编码）
创建一个内核线程需要分配和设置好很多资源。kernel_thread函数通过调用**do_fork**函数完成具体内核线程的创建工作。do_kernel函数会调用alloc_proc函数来分配并初始化一个进程控制块，但alloc_proc只是找到了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore一般通过do_fork实际创建新的内核线程。do_fork的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。因此，我们**实际需要"fork"的东西就是stack和trapframe**。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。你需要完成在kern/process/proc.c中的do_fork函数中的处理过程。它的大致执行步骤包括：
* 调用alloc_proc，首先获得一块用户信息块。
* 为进程分配一个内核栈。
* 复制原进程的内存管理信息到新进程（但内核线程不必做此事）
* 复制原进程上下文到新进程
* 将新进程添加到进程列表
* 唤醒新进程
* 返回新进程号

请在实验报告中简要说明你的设计实现过程。请回答如下问题：
* 请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。

## 编程代码
``` c
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
//################################################################################
    //LAB4:EXERCISE2 2210628 CODE
    /*
     * 一些有用的宏定义(MACROs)、函数和预处理器宏定义（DEFINEs），您可以在下面的实现中使用它们。
     * 宏定义(MACROs)或函数:
     *   alloc_proc:   创建进程结构体(proc)和初始化变量(lab4:exercise1)
     *   setup_kstack: 分配大小为KSTACKPAGE的页作为内核进程堆栈
     *   copy_mm:      根据clone_flags,复制进程proc或共享当前运行进程current的mm，
     *                 如果(clone_ftags&clone_VM==1)，共享(当前运行进程current的mm),否则复制(进程proc的mm)
     *   copy_thread:  在进程的内核堆栈顶部设置trapframe，并设置内核入口点和进程堆栈
     *   hash_proc:    将进程proc添加到进程hash_list中
     *   get_pid:      为进程分配一个独特的pid
     *   wakeup_proc:  设置proc->state = PROC_RUNNABLE
     * 变量:
     *   proc_list:    进程集合的链表
     *   nr_process:   进程集合元素的数量
     */

    /* 
     * 1.调用alloc_proc来分配proc_struct
     * 2.调用setup_kstack为子进程分配内核堆栈
     * 3.调用copy_mm根据clone_flag复制或共享mm
     * 4.调用copy_thread来设置proc_struct中的tf和context
     * 5.将proc_struct插入hash_list和proc_list
     * 6.调用wakeup_proc将新的子进程的状态设为RUNNABLE
     * 7.使用子进程的pid设置返回值(ret vaule)
     */
     proc=alloc_proc();//1
     proc->parent=current;
     proc->pid=get_pid();
     setup_kstack(proc);//2
     copy_mm(clone_flags,proc);//3
     copy_thread(proc,stack,tf);//4
     hash_proc(proc);//5
     list_add_before(&proc_list,&proc->list_link);
     nr_process+=1;
     wakeup_proc(proc);//6
     ret=proc->pid;


//################################################################################
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
```

## 问题回答

在 ucore 中，get_pid 函数用于为每个新创建的进程分配一个唯一的 PID。通过分析 get_pid 函数的实现，可以确定 ucore 是否能够做到这一点。
``` c
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}
```
* last_pid 每次调用 get_pid 时都会递增。如果 last_pid 达到或超过 MAX_PID，则重置为 1，这确保了 PID 在一定范围内循环使用。
* 在递增 last_pid 后，函数会遍历当前的进程列表，检查是否有进程已经使用了 last_pid，如果发现冲突（即某个进程的 PID 等于 last_pid），则继续递增 last_pid 并重新检查，直到找到一个未被使用的 PID。
* 通过遍历进程列表并检查冲突，get_pid 确保了每次分配的 PID 都是唯一的，如果 last_pid 达到 next_safe，则重置 next_safe 为 MAX_PID 并重新开始检查。
* 如果 last_pid 达到 MAX_PID，则重置为 1，并重新开始检查，这确保了即使 PID 达到上限，也不会出现重复分配的情况。

# 练习3：编写proc_run 函数（需要编码）

proc_run用于将指定的进程切换到CPU上运行。它的大致执行步骤包括：
* 检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。
* 禁用中断。你可以使用/kern/sync/sync.h中定义好的宏local_intr_save(x)和local_intr_restore(x)来实现关、开中断。
* 切换当前进程为要运行的进程。
* 切换页表，以便使用新进程的地址空间。/libs/riscv.h中提供了lcr3(unsigned int cr3)函数，可实现修改CR3寄存器值的功能。
* 实现上下文切换。/kern/process中已经预先编写好了switch.S，其中定义了switch_to()函数。可实现两个进程的context切换。
* 允许中断。

请回答如下问题：
* 在本实验的执行过程中，创建且运行了几个内核线程？

完成代码编写后，编译并运行代码：make qemu

如果可以得到如 附录A所示的显示内容（仅供参考，不是标准答案输出），则基本正确。

## 编程代码

``` c
void
proc_run(struct proc_struct *proc) {
    if (proc != current) 
    {
//################################################################################
       // LAB4:EXERCISE3 2210705 CODE
       /*
        * 一些有用的宏定义(MACROs)、函数和预处理器宏定义（DEFINEs），您可以在下面的实现中使用它们。
        * 宏定义(MACROs)或函数:
        *   local_intr_save():        关闭中断
        *   local_intr_restore():     启用中断
        *   lcr3():                   修改CR3寄存器的值
        *   switch_to():              两个进程之间的上下文切换
        */
        int x;
        struct  proc_struct *prev = current;
        local_intr_save(x);
        {
            current = proc;
            lcr3(proc->cr3);
            switch_to(&(prev->context), &(proc->context));
        }
        local_intr_restore(x);
       
//################################################################################
    }
}
```

## 问题回答
在本实验中，创建且运行了两个内核线程：

* idleproc：第一个内核进程，负责完成内核中各个子系统的初始化。初始化完成后，它进入一个无限循环，等待调度其他进程。

* initproc：第二个内核进程，用于完成实验的功能。它在 idleproc 初始化完成后被创建，并在内核中执行特定的任务（打印字符串）。

## 运行结果

![运行结果](/qemu.png)

# 扩展练习 Challenge

* 说明语句local_intr_save(intr_flag);....local_intr_restore(intr_flag);是如何实现开关中断的？

## 问题回答

kern/sync.h中定义的中断前后使能信号保存和退出的函数
``` c
#ifndef __KERN_SYNC_SYNC_H__
#define __KERN_SYNC_SYNC_H__

#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}

#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)
#define local_intr_restore(x) __intr_restore(x);

#endif /* !__KERN_SYNC_SYNC_H__ */
```

## __intr_save 函数

``` c
static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}
```
* 读取 sstatus 寄存器，并检查 SSTATUS_SIE 位（Supervisor Interrupt Enable），判断当前是否启用了中断。
* 如果中断已启用，则调用 intr_disable() 函数禁用中断，并返回 1 表示中断之前是启用的。
* 如果中断未启用，则直接返回 0。

## __intr_restore 函数
``` c
static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}
```
* 根据传入的 flag 值恢复中断状态。
* 如果 flag 为 1，则调用 intr_enable() 函数启用中断。
* 如果 flag 为 0，则不做任何操作。

## local_intr_save 宏
``` c
#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)
```
这个宏定义 local_intr_save(x) 使用了 do { ... } while (0) 结构，确保宏在使用时的行为与普通函数调用一致，避免潜在的语法错误和控制流问题。


## local_intr_restore 宏
``` c
#define local_intr_restore(x) __intr_restore(x);
```