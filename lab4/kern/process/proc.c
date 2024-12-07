#include <proc.h>
#include <kmalloc.h>
#include <string.h>
#include <sync.h>
#include <pmm.h>
#include <error.h>
#include <sched.h>
#include <elf.h>
#include <vmm.h>
#include <trap.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

/* ------------- 进程/线程机制的设计与实现 -------------
(一种简化的Linux进程/线程机制)
简介：
ucore实现了一个简单的进程/线程机制。进程包含独立的内存空间、至少一个用于执行的线程、内核数据(用于管理)、处理器状态(用于上下文切换)、文件(在lab6中)等。ucore需要有效地管理所有这些细节。
在ucore中，线程只是一种特殊的进程(共享进程的内存)。

------------------------------
process state       :     meaning                                                   -- reason
    PROC_UNINIT     :   未初始化                         uninitialized               -- 创建进程
    PROC_SLEEPING   :   挂起                             sleeping                   -- 尝试释放页,等待,睡眠
    PROC_RUNNABLE   :   等待或者运行                      runnable(maybe running)    -- 初始化进程,唤醒进程
    PROC_ZOMBIE     :   僵尸进程:近似死亡，等待父进程回收资源 almost dead                -- 退出进程

-----------------------------
进程状态更改:
                                            
  alloc_proc                          RUNNING
      +                             +--<----<--+
      +                             + proc_run +
      V                             +-->---->--+ 
PROC_UNINIT -- 初始化进程/唤醒进程 --> PROC_RUNNABLE -- 尝试释放页/等待/睡眠 --> PROC_SLEEPING --
                                      A      +                                            +
                                      |      +--- 退出进程 --> PROC_ZOMBIE                  +
                                      +                                                   + 
                                      -----------------------唤醒进程-----------------------
-----------------------------
进程关系
parent:           proc->parent  (proc是孩进程)
children:         proc->cptr    (proc是父进程)
older sibling:    proc->optr    (proc是新的兄弟进程)
younger sibling:  proc->yptr    (proc是老的兄弟进程)
-----------------------------
进程的相关系统调用:
SYS_exit        : 进程退出                              -->do_exit
SYS_fork        : 创建子进程，复制内存管理                 -->do_fork-->wakeup_proc
SYS_wait        : 等待进程                              -->do_wait
SYS_exec        : 在 fork 之后，进程执行一个程序           -->加载程序并刷新内存管理
SYS_clone       : 创建子线程                            -->do_fork-->wakeup_proc
SYS_yield       : 进程标记自身需要重新调度                 -->proc->need_sched=1，然后调度器将重新调度该进程
SYS_sleep       : 进程休眠                              -->do_sleep 
SYS_kill        : 杀死进程                              -->do_kill-->proc->flags |= PF_EXITING
                                                       -->wakeup_proc-->do_wait-->do_exit   
SYS_getpid      : 获取进程的 pid

*/

// the process set's list
list_entry_t proc_list;

#define HASH_SHIFT          10
#define HASH_LIST_SIZE      (1 << HASH_SHIFT)
#define pid_hashfn(x)       (hash32(x, HASH_SHIFT))

// has list for process set based on pid
static list_entry_t hash_list[HASH_LIST_SIZE];

// idle proc
struct proc_struct *idleproc = NULL;
// init proc
struct proc_struct *initproc = NULL;
// current proc
struct proc_struct *current = NULL;

static int nr_process = 0;

void kernel_thread_entry(void);
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

/* 
 * alloc_proc - alloc a proc_struct and init all fields of proc_struct
 * 功能:创建一个proc_struct并初始化proc_struct的所有成员变量
 */
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
     *       uintptr_t cr3;                              // CR3寄存器：二级页表（Page Directroy Table，PDT）的基地址
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

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
    memset(proc->name, 0, sizeof(proc->name));
    return memcpy(proc->name, name, PROC_NAME_LEN);
}

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
    return memcpy(name, proc->name, PROC_NAME_LEN);
}

// get_pid - alloc a unique pid for process
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

/* 
   proc_run - make process "proc" running on cpu
   功能:使进程proc在cpu上运行
   注:在调用switch_to之前，应该加载proc的新PDT的基址
 */
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

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
}

/* 
 * hash_proc - add proc into proc hash_list
 * 功能:将proc添加到hash_list中
 * 注:本函数依赖proc->pid，所以应在调用之前正确设置
 */
static void
hash_proc(struct proc_struct *proc) {
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
}

/* 
 * find_proc - find proc frome proc hash_list according to pid
 * 功能:根据pid从proc的hash_list中查找proc
 */
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
            struct proc_struct *proc = le2proc(le, hash_link);
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
}

/* 
 *kernel_thread - create a kernel thread using "fn" function
 * 功能:使用fn()函数创建内核线程
 * 注:临时trapframe tf的内容将被复制到do_fork-->copy_thread函数中的proc->tf(the contents of temp trapframe tf will be copied to proc->tf in do_fork-->copy_thread function)
 */
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
    // 对trameframe，也就是我们程序的一些上下文进行一些初始化
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));

    // 设置内核线程的参数和函数指针
    tf.gpr.s0 = (uintptr_t)fn; // s0 寄存器保存函数指针
    tf.gpr.s1 = (uintptr_t)arg; // s1 寄存器保存函数参数

    // 设置 trapframe 中的 status 寄存器（SSTATUS）
    // SSTATUS_SPP：Supervisor Previous Privilege（设置为 supervisor 模式，因为这是一个内核线程）
    // SSTATUS_SPIE：Supervisor Previous Interrupt Enable（设置为启用中断，因为这是一个内核线程）
    // SSTATUS_SIE：Supervisor Interrupt Enable（设置为禁用中断，因为我们不希望该线程被中断）
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;

    // 将入口点（epc）设置为 kernel_thread_entry 函数，作用实际上是将pc指针指向它(*trapentry.S会用到)
    tf.epc = (uintptr_t)kernel_thread_entry;

    // 使用 do_fork 创建一个新进程（内核线程），这样才真正用设置的tf创建新进程。
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
    struct Page *page = alloc_pages(KSTACKPAGE);
    if (page != NULL) {
        proc->kstack = (uintptr_t)page2kva(page);
        return 0;
    }
    return -E_NO_MEM;
}

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
}

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
    assert(current->mm == NULL);
    /* do nothing in this project */
    return 0;
}

/* 
 * copy_thread - setup the trapframe on the  process's kernel stack top and
 *             - setup the kernel entry point and stack of process
 * 功能:在进程的内核堆栈顶部设置trapframe，并设置内核入口点和进程堆栈
 */
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
    // 在分配的内核栈上分配出一片空间来保存trapframe
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
    *(proc->tf) = *tf;

    // Set a0 to 0 so a child process knows it's just forked
    // 将trapframe中的a0寄存器（返回值）设置为0，说明这个进程是一个子进程
    proc->tf->gpr.a0 = 0;
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
    // 将上下文中的ra设置为了forkret函数的入口，并且把trapframe放在上下文的栈顶
    proc->context.ra = (uintptr_t)forkret;
    proc->context.sp = (uintptr_t)(proc->tf);
}

/* 
 * do_fork -     parent process for a new child process
 * 功能:父进程创建一个新的子进程
 * @clone_flags: 用于指导如何创建(clone)子进程
 * @stack:       父进程的用户堆栈指针。如果stack==0，表示创建(fork)一个内核线程
 * @tf:          陷入表(trapframe)信息，将被复制到子进程的proc->tf
 */
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

// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
    panic("process exit!!.\n");
}

/* init_main - the second kernel thread used to create user_main kernel threads
 * 功能:用于创建第二个内核线程user_main
 */
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
    cprintf("To U: \"%s\".\n", (const char *)arg);
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
    return 0;
}

/* proc_init - set up the first kernel thread idleproc "idle" by itself and 
 *           - create the second kernel thread init_main
 * 功能:第一个内核线程<空闲线程(idleproc)>将自己的状态设为空闲，并创建第二个内核线程init_main
 */
void
proc_init(void) {
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
    memset(context_mem, 0, sizeof(struct context));
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
    memset(proc_name_mem, 0, PROC_NAME_LEN);
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
    ){
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
    set_proc_name(idleproc, "idle");
    nr_process ++;

    current = idleproc;

    int pid = kernel_thread(init_main, "Hello world!!", 0);
    if (pid <= 0) {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
    assert(initproc != NULL && initproc->pid == 1);
}

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
    while (1) {
        if (current->need_resched) {
            schedule();
        }
    }
}

