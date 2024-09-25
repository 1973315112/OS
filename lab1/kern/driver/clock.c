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
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    // timebase = sbi_timebase() / 500;
    clock_set_next_event();

    // initialize time counter 'ticks' to zero
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

/* *
 * clock_set_next_event - 设置下一次时钟中断事件
 * get_cycles() - 获取当前时钟周期数
 * timebase - 硬编码时基
 * sbi_set_timer() - 设置下一次时钟中断事件，sbi 代表 "Supervisor Binary Interface"，是 RISC-V 架构中的一个接口，用于在操作系统和硬件之间进行通信
 * */
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
