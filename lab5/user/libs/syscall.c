#include <defs.h>
#include <unistd.h>
#include <stdarg.h>
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
    va_list ap;
    va_start(ap, num); // 存储 ... 的参数列表
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t); // 参数保存到 a 数组中
    }
    va_end(ap);

    asm volatile (
        "ld a0, %1\n"
        "ld a1, %2\n"
        "ld a2, %3\n"
        "ld a3, %4\n"
        "ld a4, %5\n"
    	"ld a5, %6\n"
        "ecall\n" // ecall 执行系统调用
        "sd a0, %0"
        : "=m" (ret) // ecall 执行完毕后，返回值存储在 a0 中，然后将 a0 的值存储到 ret 中 <------+
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4]) //             |
        :"memory"); //                                                                   |
        // a0 中存储 num                                                                  |
        // a1 中存储 a[0]                                                                 |
        // a2 中存储 a[1]                                                                 |
        // a3 中存储 a[2]                                                                 |
        // a4 中存储 a[3]                                                                 |
        // a5 中存储 a[4]                                                                 |
    return ret; // ----------------------------------------------------------------------+
    
}

int
sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
}

int
sys_fork(void) {
    return syscall(SYS_fork);
}

int
sys_wait(int64_t pid, int *store) {
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
}

int
sys_kill(int64_t pid) {
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
}

int
sys_pgdir(void) {
    return syscall(SYS_pgdir);
}

