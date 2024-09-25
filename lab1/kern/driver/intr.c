#include <intr.h>
#include <riscv.h>

/* intr_enable - 启用 IRQ 中断
 * set_csr - 用于设置控制和状态寄存器（CSR）
 * SSTATUS_SIE - 用于启用软件中断
 * sstatus - 是一个 CSR 寄存器，保存了当前 CPU 的状态信息
     位位置 | 位名称                               | 大小 | 说明
    -----------------------------------------------------------------------------------------------------
    [31]   | SD (Supervisor Dirty)               | 1 位 | 当浮点或扩展状态寄存器被修改时，该位设置为1，表示状态已变脏。这是一个只读位。
    [30:20]| Reserved                            | 11 位| 保留位，未定义，读取时为0，写入无效。
    [19]   | MXR (Make eXecutable Readable)      | 1 位 | 控制是否允许将可执行的页作为可读。1表示允许读取可执行的页，0表示不允许。
    [18]   | SUM (Supervisor User Memory Access) | 1 位 | 控制在特权模式下是否允许访问用户模式的内存。1表示允许，0表示不允许。
    [17]   | Reserved                            | 1 位 | 保留位，未定义，读取时为0，写入无效。
    [16:15]| XS (Extension Status)               | 2 位 | 扩展状态寄存器使用情况的指示。00：禁用；01：预留；10：惰性保存；11：启用。
    [14:13]| FS (Floating-Point Status)          | 2 位 | 浮点寄存器状态。00：禁用；01：预留；10：惰性保存；11：启用。
    [12:10]| Reserved                            | 3 位 | 保留位，未定义，读取时为0，写入无效。
    [9:8]  | Reserved                            | 2 位 | 保留位，未定义，读取时为0，写入无效。
    [7]    | UBE (User-mode Endianness)          | 1 位 | 决定用户模式字节序。1：大端模式；0：小端模式。
    [6:5]  | SPIE (Supervisor Previous IE)       | 1 位 | 保存SIE位进入异常前的状态，异常处理完毕后，SIE值由SPIE恢复。
    [4]    | Reserved                            | 1 位 | 保留位，未定义，读取时为0，写入无效。
    [3:2]  | Reserved                            | 2 位 | 保留位，未定义，读取时为0，写入无效。
    [1]    | SIE (Supervisor Interrupt Enable)   | 1 位 | 控制是否在特权模式下启用中断。1：启用；0：禁用。
    [0]    | UIE (User Interrupt Enable)         | 1 位 | 控制用户模式下的中断。1：允许中断；0：禁用中断。
 */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }

/* intr_disable - 禁用 IRQ 中断 */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
