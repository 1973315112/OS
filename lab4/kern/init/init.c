#include <defs.h>
#include <stdio.h>
#include <string.h>
#include <console.h>
#include <kdebug.h>
#include <picirq.h>
#include <trap.h>
#include <clock.h>
#include <intr.h>
#include <pmm.h>
#include <vmm.h>
#include <ide.h>
#include <swap.h>
#include <proc.h>
#include <kmonitor.h>

int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);

    cons_init();                // 初始化命令行

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);

    print_kerninfo();           // 打印核心信息
    // grade_backtrace();
    pmm_init();                 // 初始化物理内存管理器

    pic_init();                 // 初始化中断控制器(本次的新增)
    
    idt_init();                 // 初始化中断描述符表
    vmm_init();                 // 初始化虚拟内存管理器
    
    proc_init();                // 初始化进程表(本次的重点)
    
    ide_init();                 // 初始化磁盘设备
    swap_init();                // 初始化页面交换机制
    clock_init();               // 初始化时钟中断
    intr_enable();              // 启用中断请求
    
    cpu_idle();                 // 运行空闲进程(本次的重点)
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
    mon_backtrace(0, NULL, NULL);
}

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
}

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
    grade_backtrace1(arg0, arg2);
}

void
grade_backtrace(void) {
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
}

static void
lab1_print_cur_status(void) {
    static int round = 0;
    round ++;
}

