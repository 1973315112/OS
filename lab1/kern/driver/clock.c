#include <clock.h>
#include <defs.h>
#include <sbi.h>
#include <stdio.h>
#include <riscv.h>


/* *
 * ticks - 系统启动以来的时钟中断次数
 * volatile - 防止编译器优化，编译器在每次访问这个变量时都会重新读取它的值，而不是使用寄存器中的缓存值
 * */
volatile size_t ticks;

//对64位和32位架构，读取time的方法是不同的
//32位架构下，需要把64位的time寄存器读到两个32位整数里，然后拼起来形成一个64位整数
//64位架构简单的一句rdtime就可以了
//__riscv_xlen是gcc定义的一个宏，可以用来区分是32位还是64位。
/* *
 * get_cycles - 获取当前时钟周期数
 * */
static inline uint64_t get_cycles(void) {
#if __riscv_xlen == 64
    uint64_t n;
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    return n;
#else
    uint32_t lo, hi, tmp;
    __asm__ __volatile__(
        "1:\n"
        "rdtimeh %0\n"
        "rdtime %1\n"
        "rdtimeh %2\n"
        "bne %0, %2, 1b"
        : "=&r"(hi), "=&r"(lo), "=&r"(tmp));
    return ((uint64_t)hi << 32) | lo;
#endif
}


// 硬编码时基
static uint64_t timebase = 100000;

/* *
 * clock_init - 初始化 8253 clock 以每秒中断 100 次，然后启用 IRQ TIMER
 * */
void clock_init(void) {
    // 在 SIE 中启用计时器中断
    // sie这个CSR可以单独使能/禁用某个来源的中断。默认时钟中断是关闭的
    // 所以我们要在初始化的时候，使能时钟中断
    set_csr(sie, MIP_STIP);
    //设置第一个时钟中断事件
    clock_set_next_event();
    // 初始化一个计数器
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

//设置时钟中断：timer的数值变为当前时间 + timebase 后，触发一次时钟中断
//对于QEMU, timer增加1，过去了10^-7 s， 也就是100ns
/* *
 * clock_set_next_event - 设置下一次时钟中断事件
 * get_cycles() - 获取当前时钟周期数
 * timebase - 硬编码时基
 * sbi_set_timer() - 设置下一次时钟中断事件，sbi 代表 "Supervisor Binary Interface"，是 RISC-V 架构中的一个接口，用于在操作系统和硬件之间进行通信
 * */
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
