
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	01650513          	addi	a0,a0,22 # ffffffffc020a048 <buf>
ffffffffc020003a:	00015617          	auipc	a2,0x15
ffffffffc020003e:	67260613          	addi	a2,a2,1650 # ffffffffc02156ac <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	001040ef          	jal	ra,ffffffffc020484a <memset>

    cons_init();                // 初始化命令行
ffffffffc020004e:	4a6000ef          	jal	ra,ffffffffc02004f4 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00005597          	auipc	a1,0x5
ffffffffc0200056:	84658593          	addi	a1,a1,-1978 # ffffffffc0204898 <etext>
ffffffffc020005a:	00005517          	auipc	a0,0x5
ffffffffc020005e:	85e50513          	addi	a0,a0,-1954 # ffffffffc02048b8 <etext+0x20>
ffffffffc0200062:	11e000ef          	jal	ra,ffffffffc0200180 <cprintf>

    print_kerninfo();           // 打印核心信息
ffffffffc0200066:	162000ef          	jal	ra,ffffffffc02001c8 <print_kerninfo>
    // grade_backtrace();
    pmm_init();                 // 初始化物理内存管理器
ffffffffc020006a:	018020ef          	jal	ra,ffffffffc0202082 <pmm_init>

    pic_init();                 // 初始化中断控制器(本次的新增)
ffffffffc020006e:	55a000ef          	jal	ra,ffffffffc02005c8 <pic_init>
    
    idt_init();                 // 初始化中断描述符表
ffffffffc0200072:	5c8000ef          	jal	ra,ffffffffc020063a <idt_init>
    vmm_init();                 // 初始化虚拟内存管理器
ffffffffc0200076:	3ca030ef          	jal	ra,ffffffffc0203440 <vmm_init>
    
    proc_init();                // 初始化进程表(本次的重点)
ffffffffc020007a:	7b7030ef          	jal	ra,ffffffffc0204030 <proc_init>
    
    ide_init();                 // 初始化磁盘设备
ffffffffc020007e:	4e8000ef          	jal	ra,ffffffffc0200566 <ide_init>
    swap_init();                // 初始化页面交换机制
ffffffffc0200082:	471020ef          	jal	ra,ffffffffc0202cf2 <swap_init>
    clock_init();               // 初始化时钟中断
ffffffffc0200086:	41c000ef          	jal	ra,ffffffffc02004a2 <clock_init>
    intr_enable();              // 启用中断请求
ffffffffc020008a:	532000ef          	jal	ra,ffffffffc02005bc <intr_enable>
    
    cpu_idle();                 // 运行空闲进程(本次的重点)
ffffffffc020008e:	1f0040ef          	jal	ra,ffffffffc020427e <cpu_idle>

ffffffffc0200092 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200092:	715d                	addi	sp,sp,-80
ffffffffc0200094:	e486                	sd	ra,72(sp)
ffffffffc0200096:	e0a6                	sd	s1,64(sp)
ffffffffc0200098:	fc4a                	sd	s2,56(sp)
ffffffffc020009a:	f84e                	sd	s3,48(sp)
ffffffffc020009c:	f452                	sd	s4,40(sp)
ffffffffc020009e:	f056                	sd	s5,32(sp)
ffffffffc02000a0:	ec5a                	sd	s6,24(sp)
ffffffffc02000a2:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02000a4:	c901                	beqz	a0,ffffffffc02000b4 <readline+0x22>
ffffffffc02000a6:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000a8:	00005517          	auipc	a0,0x5
ffffffffc02000ac:	81850513          	addi	a0,a0,-2024 # ffffffffc02048c0 <etext+0x28>
ffffffffc02000b0:	0d0000ef          	jal	ra,ffffffffc0200180 <cprintf>
readline(const char *prompt) {
ffffffffc02000b4:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000b6:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000b8:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ba:	4aa9                	li	s5,10
ffffffffc02000bc:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000be:	0000ab97          	auipc	s7,0xa
ffffffffc02000c2:	f8ab8b93          	addi	s7,s7,-118 # ffffffffc020a048 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000ca:	0ee000ef          	jal	ra,ffffffffc02001b8 <getchar>
        if (c < 0) {
ffffffffc02000ce:	00054a63          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d2:	00a95a63          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000d6:	029a5263          	bge	s4,s1,ffffffffc02000fa <readline+0x68>
        c = getchar();
ffffffffc02000da:	0de000ef          	jal	ra,ffffffffc02001b8 <getchar>
        if (c < 0) {
ffffffffc02000de:	fe055ae3          	bgez	a0,ffffffffc02000d2 <readline+0x40>
            return NULL;
ffffffffc02000e2:	4501                	li	a0,0
ffffffffc02000e4:	a091                	j	ffffffffc0200128 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000e6:	03351463          	bne	a0,s3,ffffffffc020010e <readline+0x7c>
ffffffffc02000ea:	e8a9                	bnez	s1,ffffffffc020013c <readline+0xaa>
        c = getchar();
ffffffffc02000ec:	0cc000ef          	jal	ra,ffffffffc02001b8 <getchar>
        if (c < 0) {
ffffffffc02000f0:	fe0549e3          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000f4:	fea959e3          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000f8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02000fa:	e42a                	sd	a0,8(sp)
ffffffffc02000fc:	0ba000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i ++] = c;
ffffffffc0200100:	6522                	ld	a0,8(sp)
ffffffffc0200102:	009b87b3          	add	a5,s7,s1
ffffffffc0200106:	2485                	addiw	s1,s1,1
ffffffffc0200108:	00a78023          	sb	a0,0(a5)
ffffffffc020010c:	bf7d                	j	ffffffffc02000ca <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020010e:	01550463          	beq	a0,s5,ffffffffc0200116 <readline+0x84>
ffffffffc0200112:	fb651ce3          	bne	a0,s6,ffffffffc02000ca <readline+0x38>
            cputchar(c);
ffffffffc0200116:	0a0000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i] = '\0';
ffffffffc020011a:	0000a517          	auipc	a0,0xa
ffffffffc020011e:	f2e50513          	addi	a0,a0,-210 # ffffffffc020a048 <buf>
ffffffffc0200122:	94aa                	add	s1,s1,a0
ffffffffc0200124:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200128:	60a6                	ld	ra,72(sp)
ffffffffc020012a:	6486                	ld	s1,64(sp)
ffffffffc020012c:	7962                	ld	s2,56(sp)
ffffffffc020012e:	79c2                	ld	s3,48(sp)
ffffffffc0200130:	7a22                	ld	s4,40(sp)
ffffffffc0200132:	7a82                	ld	s5,32(sp)
ffffffffc0200134:	6b62                	ld	s6,24(sp)
ffffffffc0200136:	6bc2                	ld	s7,16(sp)
ffffffffc0200138:	6161                	addi	sp,sp,80
ffffffffc020013a:	8082                	ret
            cputchar(c);
ffffffffc020013c:	4521                	li	a0,8
ffffffffc020013e:	078000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            i --;
ffffffffc0200142:	34fd                	addiw	s1,s1,-1
ffffffffc0200144:	b759                	j	ffffffffc02000ca <readline+0x38>

ffffffffc0200146 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200146:	1141                	addi	sp,sp,-16
ffffffffc0200148:	e022                	sd	s0,0(sp)
ffffffffc020014a:	e406                	sd	ra,8(sp)
ffffffffc020014c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020014e:	3a8000ef          	jal	ra,ffffffffc02004f6 <cons_putc>
    (*cnt) ++;
ffffffffc0200152:	401c                	lw	a5,0(s0)
}
ffffffffc0200154:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200156:	2785                	addiw	a5,a5,1
ffffffffc0200158:	c01c                	sw	a5,0(s0)
}
ffffffffc020015a:	6402                	ld	s0,0(sp)
ffffffffc020015c:	0141                	addi	sp,sp,16
ffffffffc020015e:	8082                	ret

ffffffffc0200160 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200160:	1101                	addi	sp,sp,-32
ffffffffc0200162:	862a                	mv	a2,a0
ffffffffc0200164:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200166:	00000517          	auipc	a0,0x0
ffffffffc020016a:	fe050513          	addi	a0,a0,-32 # ffffffffc0200146 <cputch>
ffffffffc020016e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200170:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200172:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200174:	2d8040ef          	jal	ra,ffffffffc020444c <vprintfmt>
    return cnt;
}
ffffffffc0200178:	60e2                	ld	ra,24(sp)
ffffffffc020017a:	4532                	lw	a0,12(sp)
ffffffffc020017c:	6105                	addi	sp,sp,32
ffffffffc020017e:	8082                	ret

ffffffffc0200180 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200180:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200182:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200186:	8e2a                	mv	t3,a0
ffffffffc0200188:	f42e                	sd	a1,40(sp)
ffffffffc020018a:	f832                	sd	a2,48(sp)
ffffffffc020018c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020018e:	00000517          	auipc	a0,0x0
ffffffffc0200192:	fb850513          	addi	a0,a0,-72 # ffffffffc0200146 <cputch>
ffffffffc0200196:	004c                	addi	a1,sp,4
ffffffffc0200198:	869a                	mv	a3,t1
ffffffffc020019a:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc020019c:	ec06                	sd	ra,24(sp)
ffffffffc020019e:	e0ba                	sd	a4,64(sp)
ffffffffc02001a0:	e4be                	sd	a5,72(sp)
ffffffffc02001a2:	e8c2                	sd	a6,80(sp)
ffffffffc02001a4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001a6:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001a8:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001aa:	2a2040ef          	jal	ra,ffffffffc020444c <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ae:	60e2                	ld	ra,24(sp)
ffffffffc02001b0:	4512                	lw	a0,4(sp)
ffffffffc02001b2:	6125                	addi	sp,sp,96
ffffffffc02001b4:	8082                	ret

ffffffffc02001b6 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001b6:	a681                	j	ffffffffc02004f6 <cons_putc>

ffffffffc02001b8 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001b8:	1141                	addi	sp,sp,-16
ffffffffc02001ba:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001bc:	36e000ef          	jal	ra,ffffffffc020052a <cons_getc>
ffffffffc02001c0:	dd75                	beqz	a0,ffffffffc02001bc <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001c2:	60a2                	ld	ra,8(sp)
ffffffffc02001c4:	0141                	addi	sp,sp,16
ffffffffc02001c6:	8082                	ret

ffffffffc02001c8 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001ca:	00004517          	auipc	a0,0x4
ffffffffc02001ce:	6fe50513          	addi	a0,a0,1790 # ffffffffc02048c8 <etext+0x30>
void print_kerninfo(void) {
ffffffffc02001d2:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001d4:	fadff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02001d8:	00000597          	auipc	a1,0x0
ffffffffc02001dc:	e5a58593          	addi	a1,a1,-422 # ffffffffc0200032 <kern_init>
ffffffffc02001e0:	00004517          	auipc	a0,0x4
ffffffffc02001e4:	70850513          	addi	a0,a0,1800 # ffffffffc02048e8 <etext+0x50>
ffffffffc02001e8:	f99ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02001ec:	00004597          	auipc	a1,0x4
ffffffffc02001f0:	6ac58593          	addi	a1,a1,1708 # ffffffffc0204898 <etext>
ffffffffc02001f4:	00004517          	auipc	a0,0x4
ffffffffc02001f8:	71450513          	addi	a0,a0,1812 # ffffffffc0204908 <etext+0x70>
ffffffffc02001fc:	f85ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200200:	0000a597          	auipc	a1,0xa
ffffffffc0200204:	e4858593          	addi	a1,a1,-440 # ffffffffc020a048 <buf>
ffffffffc0200208:	00004517          	auipc	a0,0x4
ffffffffc020020c:	72050513          	addi	a0,a0,1824 # ffffffffc0204928 <etext+0x90>
ffffffffc0200210:	f71ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200214:	00015597          	auipc	a1,0x15
ffffffffc0200218:	49858593          	addi	a1,a1,1176 # ffffffffc02156ac <end>
ffffffffc020021c:	00004517          	auipc	a0,0x4
ffffffffc0200220:	72c50513          	addi	a0,a0,1836 # ffffffffc0204948 <etext+0xb0>
ffffffffc0200224:	f5dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200228:	00016597          	auipc	a1,0x16
ffffffffc020022c:	88358593          	addi	a1,a1,-1917 # ffffffffc0215aab <end+0x3ff>
ffffffffc0200230:	00000797          	auipc	a5,0x0
ffffffffc0200234:	e0278793          	addi	a5,a5,-510 # ffffffffc0200032 <kern_init>
ffffffffc0200238:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020023c:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200240:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200242:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200246:	95be                	add	a1,a1,a5
ffffffffc0200248:	85a9                	srai	a1,a1,0xa
ffffffffc020024a:	00004517          	auipc	a0,0x4
ffffffffc020024e:	71e50513          	addi	a0,a0,1822 # ffffffffc0204968 <etext+0xd0>
}
ffffffffc0200252:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200254:	b735                	j	ffffffffc0200180 <cprintf>

ffffffffc0200256 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200256:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200258:	00004617          	auipc	a2,0x4
ffffffffc020025c:	74060613          	addi	a2,a2,1856 # ffffffffc0204998 <etext+0x100>
ffffffffc0200260:	04d00593          	li	a1,77
ffffffffc0200264:	00004517          	auipc	a0,0x4
ffffffffc0200268:	74c50513          	addi	a0,a0,1868 # ffffffffc02049b0 <etext+0x118>
void print_stackframe(void) {
ffffffffc020026c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020026e:	1d8000ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0200272 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200272:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200274:	00004617          	auipc	a2,0x4
ffffffffc0200278:	75460613          	addi	a2,a2,1876 # ffffffffc02049c8 <etext+0x130>
ffffffffc020027c:	00004597          	auipc	a1,0x4
ffffffffc0200280:	76c58593          	addi	a1,a1,1900 # ffffffffc02049e8 <etext+0x150>
ffffffffc0200284:	00004517          	auipc	a0,0x4
ffffffffc0200288:	76c50513          	addi	a0,a0,1900 # ffffffffc02049f0 <etext+0x158>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020028c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020028e:	ef3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200292:	00004617          	auipc	a2,0x4
ffffffffc0200296:	76e60613          	addi	a2,a2,1902 # ffffffffc0204a00 <etext+0x168>
ffffffffc020029a:	00004597          	auipc	a1,0x4
ffffffffc020029e:	78e58593          	addi	a1,a1,1934 # ffffffffc0204a28 <etext+0x190>
ffffffffc02002a2:	00004517          	auipc	a0,0x4
ffffffffc02002a6:	74e50513          	addi	a0,a0,1870 # ffffffffc02049f0 <etext+0x158>
ffffffffc02002aa:	ed7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002ae:	00004617          	auipc	a2,0x4
ffffffffc02002b2:	78a60613          	addi	a2,a2,1930 # ffffffffc0204a38 <etext+0x1a0>
ffffffffc02002b6:	00004597          	auipc	a1,0x4
ffffffffc02002ba:	7a258593          	addi	a1,a1,1954 # ffffffffc0204a58 <etext+0x1c0>
ffffffffc02002be:	00004517          	auipc	a0,0x4
ffffffffc02002c2:	73250513          	addi	a0,a0,1842 # ffffffffc02049f0 <etext+0x158>
ffffffffc02002c6:	ebbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    }
    return 0;
}
ffffffffc02002ca:	60a2                	ld	ra,8(sp)
ffffffffc02002cc:	4501                	li	a0,0
ffffffffc02002ce:	0141                	addi	sp,sp,16
ffffffffc02002d0:	8082                	ret

ffffffffc02002d2 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002d2:	1141                	addi	sp,sp,-16
ffffffffc02002d4:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002d6:	ef3ff0ef          	jal	ra,ffffffffc02001c8 <print_kerninfo>
    return 0;
}
ffffffffc02002da:	60a2                	ld	ra,8(sp)
ffffffffc02002dc:	4501                	li	a0,0
ffffffffc02002de:	0141                	addi	sp,sp,16
ffffffffc02002e0:	8082                	ret

ffffffffc02002e2 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e2:	1141                	addi	sp,sp,-16
ffffffffc02002e4:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002e6:	f71ff0ef          	jal	ra,ffffffffc0200256 <print_stackframe>
    return 0;
}
ffffffffc02002ea:	60a2                	ld	ra,8(sp)
ffffffffc02002ec:	4501                	li	a0,0
ffffffffc02002ee:	0141                	addi	sp,sp,16
ffffffffc02002f0:	8082                	ret

ffffffffc02002f2 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002f2:	7115                	addi	sp,sp,-224
ffffffffc02002f4:	ed5e                	sd	s7,152(sp)
ffffffffc02002f6:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002f8:	00004517          	auipc	a0,0x4
ffffffffc02002fc:	77050513          	addi	a0,a0,1904 # ffffffffc0204a68 <etext+0x1d0>
kmonitor(struct trapframe *tf) {
ffffffffc0200300:	ed86                	sd	ra,216(sp)
ffffffffc0200302:	e9a2                	sd	s0,208(sp)
ffffffffc0200304:	e5a6                	sd	s1,200(sp)
ffffffffc0200306:	e1ca                	sd	s2,192(sp)
ffffffffc0200308:	fd4e                	sd	s3,184(sp)
ffffffffc020030a:	f952                	sd	s4,176(sp)
ffffffffc020030c:	f556                	sd	s5,168(sp)
ffffffffc020030e:	f15a                	sd	s6,160(sp)
ffffffffc0200310:	e962                	sd	s8,144(sp)
ffffffffc0200312:	e566                	sd	s9,136(sp)
ffffffffc0200314:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200316:	e6bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020031a:	00004517          	auipc	a0,0x4
ffffffffc020031e:	77650513          	addi	a0,a0,1910 # ffffffffc0204a90 <etext+0x1f8>
ffffffffc0200322:	e5fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    if (tf != NULL) {
ffffffffc0200326:	000b8563          	beqz	s7,ffffffffc0200330 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020032a:	855e                	mv	a0,s7
ffffffffc020032c:	4f4000ef          	jal	ra,ffffffffc0200820 <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200330:	4501                	li	a0,0
ffffffffc0200332:	4581                	li	a1,0
ffffffffc0200334:	4601                	li	a2,0
ffffffffc0200336:	48a1                	li	a7,8
ffffffffc0200338:	00000073          	ecall
ffffffffc020033c:	00004c17          	auipc	s8,0x4
ffffffffc0200340:	7c4c0c13          	addi	s8,s8,1988 # ffffffffc0204b00 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200344:	00004917          	auipc	s2,0x4
ffffffffc0200348:	77490913          	addi	s2,s2,1908 # ffffffffc0204ab8 <etext+0x220>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020034c:	00004497          	auipc	s1,0x4
ffffffffc0200350:	77448493          	addi	s1,s1,1908 # ffffffffc0204ac0 <etext+0x228>
        if (argc == MAXARGS - 1) {
ffffffffc0200354:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200356:	00004b17          	auipc	s6,0x4
ffffffffc020035a:	772b0b13          	addi	s6,s6,1906 # ffffffffc0204ac8 <etext+0x230>
        argv[argc ++] = buf;
ffffffffc020035e:	00004a17          	auipc	s4,0x4
ffffffffc0200362:	68aa0a13          	addi	s4,s4,1674 # ffffffffc02049e8 <etext+0x150>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200366:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200368:	854a                	mv	a0,s2
ffffffffc020036a:	d29ff0ef          	jal	ra,ffffffffc0200092 <readline>
ffffffffc020036e:	842a                	mv	s0,a0
ffffffffc0200370:	dd65                	beqz	a0,ffffffffc0200368 <kmonitor+0x76>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200372:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200376:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200378:	e1bd                	bnez	a1,ffffffffc02003de <kmonitor+0xec>
    if (argc == 0) {
ffffffffc020037a:	fe0c87e3          	beqz	s9,ffffffffc0200368 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037e:	6582                	ld	a1,0(sp)
ffffffffc0200380:	00004d17          	auipc	s10,0x4
ffffffffc0200384:	780d0d13          	addi	s10,s10,1920 # ffffffffc0204b00 <commands>
        argv[argc ++] = buf;
ffffffffc0200388:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020038a:	4401                	li	s0,0
ffffffffc020038c:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020038e:	488040ef          	jal	ra,ffffffffc0204816 <strcmp>
ffffffffc0200392:	c919                	beqz	a0,ffffffffc02003a8 <kmonitor+0xb6>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200394:	2405                	addiw	s0,s0,1
ffffffffc0200396:	0b540063          	beq	s0,s5,ffffffffc0200436 <kmonitor+0x144>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020039a:	000d3503          	ld	a0,0(s10)
ffffffffc020039e:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003a0:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003a2:	474040ef          	jal	ra,ffffffffc0204816 <strcmp>
ffffffffc02003a6:	f57d                	bnez	a0,ffffffffc0200394 <kmonitor+0xa2>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003a8:	00141793          	slli	a5,s0,0x1
ffffffffc02003ac:	97a2                	add	a5,a5,s0
ffffffffc02003ae:	078e                	slli	a5,a5,0x3
ffffffffc02003b0:	97e2                	add	a5,a5,s8
ffffffffc02003b2:	6b9c                	ld	a5,16(a5)
ffffffffc02003b4:	865e                	mv	a2,s7
ffffffffc02003b6:	002c                	addi	a1,sp,8
ffffffffc02003b8:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003bc:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003be:	fa0555e3          	bgez	a0,ffffffffc0200368 <kmonitor+0x76>
}
ffffffffc02003c2:	60ee                	ld	ra,216(sp)
ffffffffc02003c4:	644e                	ld	s0,208(sp)
ffffffffc02003c6:	64ae                	ld	s1,200(sp)
ffffffffc02003c8:	690e                	ld	s2,192(sp)
ffffffffc02003ca:	79ea                	ld	s3,184(sp)
ffffffffc02003cc:	7a4a                	ld	s4,176(sp)
ffffffffc02003ce:	7aaa                	ld	s5,168(sp)
ffffffffc02003d0:	7b0a                	ld	s6,160(sp)
ffffffffc02003d2:	6bea                	ld	s7,152(sp)
ffffffffc02003d4:	6c4a                	ld	s8,144(sp)
ffffffffc02003d6:	6caa                	ld	s9,136(sp)
ffffffffc02003d8:	6d0a                	ld	s10,128(sp)
ffffffffc02003da:	612d                	addi	sp,sp,224
ffffffffc02003dc:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003de:	8526                	mv	a0,s1
ffffffffc02003e0:	454040ef          	jal	ra,ffffffffc0204834 <strchr>
ffffffffc02003e4:	c901                	beqz	a0,ffffffffc02003f4 <kmonitor+0x102>
ffffffffc02003e6:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003ea:	00040023          	sb	zero,0(s0)
ffffffffc02003ee:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003f0:	d5c9                	beqz	a1,ffffffffc020037a <kmonitor+0x88>
ffffffffc02003f2:	b7f5                	j	ffffffffc02003de <kmonitor+0xec>
        if (*buf == '\0') {
ffffffffc02003f4:	00044783          	lbu	a5,0(s0)
ffffffffc02003f8:	d3c9                	beqz	a5,ffffffffc020037a <kmonitor+0x88>
        if (argc == MAXARGS - 1) {
ffffffffc02003fa:	033c8963          	beq	s9,s3,ffffffffc020042c <kmonitor+0x13a>
        argv[argc ++] = buf;
ffffffffc02003fe:	003c9793          	slli	a5,s9,0x3
ffffffffc0200402:	0118                	addi	a4,sp,128
ffffffffc0200404:	97ba                	add	a5,a5,a4
ffffffffc0200406:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020040a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020040e:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200410:	e591                	bnez	a1,ffffffffc020041c <kmonitor+0x12a>
ffffffffc0200412:	b7b5                	j	ffffffffc020037e <kmonitor+0x8c>
ffffffffc0200414:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200418:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020041a:	d1a5                	beqz	a1,ffffffffc020037a <kmonitor+0x88>
ffffffffc020041c:	8526                	mv	a0,s1
ffffffffc020041e:	416040ef          	jal	ra,ffffffffc0204834 <strchr>
ffffffffc0200422:	d96d                	beqz	a0,ffffffffc0200414 <kmonitor+0x122>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200424:	00044583          	lbu	a1,0(s0)
ffffffffc0200428:	d9a9                	beqz	a1,ffffffffc020037a <kmonitor+0x88>
ffffffffc020042a:	bf55                	j	ffffffffc02003de <kmonitor+0xec>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020042c:	45c1                	li	a1,16
ffffffffc020042e:	855a                	mv	a0,s6
ffffffffc0200430:	d51ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200434:	b7e9                	j	ffffffffc02003fe <kmonitor+0x10c>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200436:	6582                	ld	a1,0(sp)
ffffffffc0200438:	00004517          	auipc	a0,0x4
ffffffffc020043c:	6b050513          	addi	a0,a0,1712 # ffffffffc0204ae8 <etext+0x250>
ffffffffc0200440:	d41ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
ffffffffc0200444:	b715                	j	ffffffffc0200368 <kmonitor+0x76>

ffffffffc0200446 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200446:	00015317          	auipc	t1,0x15
ffffffffc020044a:	1d230313          	addi	t1,t1,466 # ffffffffc0215618 <is_panic>
ffffffffc020044e:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200452:	715d                	addi	sp,sp,-80
ffffffffc0200454:	ec06                	sd	ra,24(sp)
ffffffffc0200456:	e822                	sd	s0,16(sp)
ffffffffc0200458:	f436                	sd	a3,40(sp)
ffffffffc020045a:	f83a                	sd	a4,48(sp)
ffffffffc020045c:	fc3e                	sd	a5,56(sp)
ffffffffc020045e:	e0c2                	sd	a6,64(sp)
ffffffffc0200460:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200462:	020e1a63          	bnez	t3,ffffffffc0200496 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200466:	4785                	li	a5,1
ffffffffc0200468:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020046c:	8432                	mv	s0,a2
ffffffffc020046e:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200470:	862e                	mv	a2,a1
ffffffffc0200472:	85aa                	mv	a1,a0
ffffffffc0200474:	00004517          	auipc	a0,0x4
ffffffffc0200478:	6d450513          	addi	a0,a0,1748 # ffffffffc0204b48 <commands+0x48>
    va_start(ap, fmt);
ffffffffc020047c:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020047e:	d03ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200482:	65a2                	ld	a1,8(sp)
ffffffffc0200484:	8522                	mv	a0,s0
ffffffffc0200486:	cdbff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc020048a:	00005517          	auipc	a0,0x5
ffffffffc020048e:	7a650513          	addi	a0,a0,1958 # ffffffffc0205c30 <buddy_system_pmm_manager+0x6b8>
ffffffffc0200492:	cefff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200496:	12c000ef          	jal	ra,ffffffffc02005c2 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020049a:	4501                	li	a0,0
ffffffffc020049c:	e57ff0ef          	jal	ra,ffffffffc02002f2 <kmonitor>
    while (1) {
ffffffffc02004a0:	bfed                	j	ffffffffc020049a <__panic+0x54>

ffffffffc02004a2 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004a2:	67e1                	lui	a5,0x18
ffffffffc02004a4:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02004a8:	00015717          	auipc	a4,0x15
ffffffffc02004ac:	18f73023          	sd	a5,384(a4) # ffffffffc0215628 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004b0:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02004b4:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004b6:	953e                	add	a0,a0,a5
ffffffffc02004b8:	4601                	li	a2,0
ffffffffc02004ba:	4881                	li	a7,0
ffffffffc02004bc:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02004c0:	02000793          	li	a5,32
ffffffffc02004c4:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02004c8:	00004517          	auipc	a0,0x4
ffffffffc02004cc:	6a050513          	addi	a0,a0,1696 # ffffffffc0204b68 <commands+0x68>
    ticks = 0;
ffffffffc02004d0:	00015797          	auipc	a5,0x15
ffffffffc02004d4:	1407b823          	sd	zero,336(a5) # ffffffffc0215620 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02004d8:	b165                	j	ffffffffc0200180 <cprintf>

ffffffffc02004da <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004da:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004de:	00015797          	auipc	a5,0x15
ffffffffc02004e2:	14a7b783          	ld	a5,330(a5) # ffffffffc0215628 <timebase>
ffffffffc02004e6:	953e                	add	a0,a0,a5
ffffffffc02004e8:	4581                	li	a1,0
ffffffffc02004ea:	4601                	li	a2,0
ffffffffc02004ec:	4881                	li	a7,0
ffffffffc02004ee:	00000073          	ecall
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02004f4:	8082                	ret

ffffffffc02004f6 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004f6:	100027f3          	csrr	a5,sstatus
ffffffffc02004fa:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02004fc:	0ff57513          	zext.b	a0,a0
ffffffffc0200500:	e799                	bnez	a5,ffffffffc020050e <cons_putc+0x18>
ffffffffc0200502:	4581                	li	a1,0
ffffffffc0200504:	4601                	li	a2,0
ffffffffc0200506:	4885                	li	a7,1
ffffffffc0200508:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020050c:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020050e:	1101                	addi	sp,sp,-32
ffffffffc0200510:	ec06                	sd	ra,24(sp)
ffffffffc0200512:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200514:	0ae000ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0200518:	6522                	ld	a0,8(sp)
ffffffffc020051a:	4581                	li	a1,0
ffffffffc020051c:	4601                	li	a2,0
ffffffffc020051e:	4885                	li	a7,1
ffffffffc0200520:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200524:	60e2                	ld	ra,24(sp)
ffffffffc0200526:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200528:	a851                	j	ffffffffc02005bc <intr_enable>

ffffffffc020052a <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020052a:	100027f3          	csrr	a5,sstatus
ffffffffc020052e:	8b89                	andi	a5,a5,2
ffffffffc0200530:	eb89                	bnez	a5,ffffffffc0200542 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200532:	4501                	li	a0,0
ffffffffc0200534:	4581                	li	a1,0
ffffffffc0200536:	4601                	li	a2,0
ffffffffc0200538:	4889                	li	a7,2
ffffffffc020053a:	00000073          	ecall
ffffffffc020053e:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200540:	8082                	ret
int cons_getc(void) {
ffffffffc0200542:	1101                	addi	sp,sp,-32
ffffffffc0200544:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200546:	07c000ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc020054a:	4501                	li	a0,0
ffffffffc020054c:	4581                	li	a1,0
ffffffffc020054e:	4601                	li	a2,0
ffffffffc0200550:	4889                	li	a7,2
ffffffffc0200552:	00000073          	ecall
ffffffffc0200556:	2501                	sext.w	a0,a0
ffffffffc0200558:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020055a:	062000ef          	jal	ra,ffffffffc02005bc <intr_enable>
}
ffffffffc020055e:	60e2                	ld	ra,24(sp)
ffffffffc0200560:	6522                	ld	a0,8(sp)
ffffffffc0200562:	6105                	addi	sp,sp,32
ffffffffc0200564:	8082                	ret

ffffffffc0200566 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200566:	8082                	ret

ffffffffc0200568 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200568:	00253513          	sltiu	a0,a0,2
ffffffffc020056c:	8082                	ret

ffffffffc020056e <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020056e:	03800513          	li	a0,56
ffffffffc0200572:	8082                	ret

ffffffffc0200574 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200574:	0000a797          	auipc	a5,0xa
ffffffffc0200578:	ed478793          	addi	a5,a5,-300 # ffffffffc020a448 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc020057c:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200580:	1141                	addi	sp,sp,-16
ffffffffc0200582:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200584:	95be                	add	a1,a1,a5
ffffffffc0200586:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020058a:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020058c:	2d0040ef          	jal	ra,ffffffffc020485c <memcpy>
    return 0;
}
ffffffffc0200590:	60a2                	ld	ra,8(sp)
ffffffffc0200592:	4501                	li	a0,0
ffffffffc0200594:	0141                	addi	sp,sp,16
ffffffffc0200596:	8082                	ret

ffffffffc0200598 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200598:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020059c:	0000a517          	auipc	a0,0xa
ffffffffc02005a0:	eac50513          	addi	a0,a0,-340 # ffffffffc020a448 <ide>
                   size_t nsecs) {
ffffffffc02005a4:	1141                	addi	sp,sp,-16
ffffffffc02005a6:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005a8:	953e                	add	a0,a0,a5
ffffffffc02005aa:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02005ae:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005b0:	2ac040ef          	jal	ra,ffffffffc020485c <memcpy>
    return 0;
}
ffffffffc02005b4:	60a2                	ld	ra,8(sp)
ffffffffc02005b6:	4501                	li	a0,0
ffffffffc02005b8:	0141                	addi	sp,sp,16
ffffffffc02005ba:	8082                	ret

ffffffffc02005bc <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005bc:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005c0:	8082                	ret

ffffffffc02005c2 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005c2:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005c6:	8082                	ret

ffffffffc02005c8 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005c8:	8082                	ret

ffffffffc02005ca <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005ca:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005ce:	1141                	addi	sp,sp,-16
ffffffffc02005d0:	e022                	sd	s0,0(sp)
ffffffffc02005d2:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005d4:	1007f793          	andi	a5,a5,256
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005d8:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005dc:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005de:	05500613          	li	a2,85
ffffffffc02005e2:	c399                	beqz	a5,ffffffffc02005e8 <pgfault_handler+0x1e>
ffffffffc02005e4:	04b00613          	li	a2,75
ffffffffc02005e8:	11843703          	ld	a4,280(s0)
ffffffffc02005ec:	47bd                	li	a5,15
ffffffffc02005ee:	05700693          	li	a3,87
ffffffffc02005f2:	00f70463          	beq	a4,a5,ffffffffc02005fa <pgfault_handler+0x30>
ffffffffc02005f6:	05200693          	li	a3,82
ffffffffc02005fa:	00004517          	auipc	a0,0x4
ffffffffc02005fe:	58e50513          	addi	a0,a0,1422 # ffffffffc0204b88 <commands+0x88>
ffffffffc0200602:	b7fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200606:	00015517          	auipc	a0,0x15
ffffffffc020060a:	07a53503          	ld	a0,122(a0) # ffffffffc0215680 <check_mm_struct>
ffffffffc020060e:	c911                	beqz	a0,ffffffffc0200622 <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200610:	11043603          	ld	a2,272(s0)
ffffffffc0200614:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200618:	6402                	ld	s0,0(sp)
ffffffffc020061a:	60a2                	ld	ra,8(sp)
ffffffffc020061c:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020061e:	3f60306f          	j	ffffffffc0203a14 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200622:	00004617          	auipc	a2,0x4
ffffffffc0200626:	58660613          	addi	a2,a2,1414 # ffffffffc0204ba8 <commands+0xa8>
ffffffffc020062a:	06200593          	li	a1,98
ffffffffc020062e:	00004517          	auipc	a0,0x4
ffffffffc0200632:	59250513          	addi	a0,a0,1426 # ffffffffc0204bc0 <commands+0xc0>
ffffffffc0200636:	e11ff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020063a <idt_init>:
    write_csr(sscratch, 0);
ffffffffc020063a:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020063e:	00000797          	auipc	a5,0x0
ffffffffc0200642:	47a78793          	addi	a5,a5,1146 # ffffffffc0200ab8 <__alltraps>
ffffffffc0200646:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020064a:	000407b7          	lui	a5,0x40
ffffffffc020064e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200652:	8082                	ret

ffffffffc0200654 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200654:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200656:	1141                	addi	sp,sp,-16
ffffffffc0200658:	e022                	sd	s0,0(sp)
ffffffffc020065a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020065c:	00004517          	auipc	a0,0x4
ffffffffc0200660:	57c50513          	addi	a0,a0,1404 # ffffffffc0204bd8 <commands+0xd8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200664:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200666:	b1bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020066a:	640c                	ld	a1,8(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	58450513          	addi	a0,a0,1412 # ffffffffc0204bf0 <commands+0xf0>
ffffffffc0200674:	b0dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200678:	680c                	ld	a1,16(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	58e50513          	addi	a0,a0,1422 # ffffffffc0204c08 <commands+0x108>
ffffffffc0200682:	affff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200686:	6c0c                	ld	a1,24(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	59850513          	addi	a0,a0,1432 # ffffffffc0204c20 <commands+0x120>
ffffffffc0200690:	af1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200694:	700c                	ld	a1,32(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	5a250513          	addi	a0,a0,1442 # ffffffffc0204c38 <commands+0x138>
ffffffffc020069e:	ae3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006a2:	740c                	ld	a1,40(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	5ac50513          	addi	a0,a0,1452 # ffffffffc0204c50 <commands+0x150>
ffffffffc02006ac:	ad5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006b0:	780c                	ld	a1,48(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	5b650513          	addi	a0,a0,1462 # ffffffffc0204c68 <commands+0x168>
ffffffffc02006ba:	ac7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006be:	7c0c                	ld	a1,56(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	5c050513          	addi	a0,a0,1472 # ffffffffc0204c80 <commands+0x180>
ffffffffc02006c8:	ab9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006cc:	602c                	ld	a1,64(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	5ca50513          	addi	a0,a0,1482 # ffffffffc0204c98 <commands+0x198>
ffffffffc02006d6:	aabff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006da:	642c                	ld	a1,72(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	5d450513          	addi	a0,a0,1492 # ffffffffc0204cb0 <commands+0x1b0>
ffffffffc02006e4:	a9dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006e8:	682c                	ld	a1,80(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	5de50513          	addi	a0,a0,1502 # ffffffffc0204cc8 <commands+0x1c8>
ffffffffc02006f2:	a8fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006f6:	6c2c                	ld	a1,88(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	5e850513          	addi	a0,a0,1512 # ffffffffc0204ce0 <commands+0x1e0>
ffffffffc0200700:	a81ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200704:	702c                	ld	a1,96(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	5f250513          	addi	a0,a0,1522 # ffffffffc0204cf8 <commands+0x1f8>
ffffffffc020070e:	a73ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200712:	742c                	ld	a1,104(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	5fc50513          	addi	a0,a0,1532 # ffffffffc0204d10 <commands+0x210>
ffffffffc020071c:	a65ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200720:	782c                	ld	a1,112(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	60650513          	addi	a0,a0,1542 # ffffffffc0204d28 <commands+0x228>
ffffffffc020072a:	a57ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020072e:	7c2c                	ld	a1,120(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	61050513          	addi	a0,a0,1552 # ffffffffc0204d40 <commands+0x240>
ffffffffc0200738:	a49ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020073c:	604c                	ld	a1,128(s0)
ffffffffc020073e:	00004517          	auipc	a0,0x4
ffffffffc0200742:	61a50513          	addi	a0,a0,1562 # ffffffffc0204d58 <commands+0x258>
ffffffffc0200746:	a3bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020074a:	644c                	ld	a1,136(s0)
ffffffffc020074c:	00004517          	auipc	a0,0x4
ffffffffc0200750:	62450513          	addi	a0,a0,1572 # ffffffffc0204d70 <commands+0x270>
ffffffffc0200754:	a2dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200758:	684c                	ld	a1,144(s0)
ffffffffc020075a:	00004517          	auipc	a0,0x4
ffffffffc020075e:	62e50513          	addi	a0,a0,1582 # ffffffffc0204d88 <commands+0x288>
ffffffffc0200762:	a1fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200766:	6c4c                	ld	a1,152(s0)
ffffffffc0200768:	00004517          	auipc	a0,0x4
ffffffffc020076c:	63850513          	addi	a0,a0,1592 # ffffffffc0204da0 <commands+0x2a0>
ffffffffc0200770:	a11ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200774:	704c                	ld	a1,160(s0)
ffffffffc0200776:	00004517          	auipc	a0,0x4
ffffffffc020077a:	64250513          	addi	a0,a0,1602 # ffffffffc0204db8 <commands+0x2b8>
ffffffffc020077e:	a03ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200782:	744c                	ld	a1,168(s0)
ffffffffc0200784:	00004517          	auipc	a0,0x4
ffffffffc0200788:	64c50513          	addi	a0,a0,1612 # ffffffffc0204dd0 <commands+0x2d0>
ffffffffc020078c:	9f5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200790:	784c                	ld	a1,176(s0)
ffffffffc0200792:	00004517          	auipc	a0,0x4
ffffffffc0200796:	65650513          	addi	a0,a0,1622 # ffffffffc0204de8 <commands+0x2e8>
ffffffffc020079a:	9e7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020079e:	7c4c                	ld	a1,184(s0)
ffffffffc02007a0:	00004517          	auipc	a0,0x4
ffffffffc02007a4:	66050513          	addi	a0,a0,1632 # ffffffffc0204e00 <commands+0x300>
ffffffffc02007a8:	9d9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007ac:	606c                	ld	a1,192(s0)
ffffffffc02007ae:	00004517          	auipc	a0,0x4
ffffffffc02007b2:	66a50513          	addi	a0,a0,1642 # ffffffffc0204e18 <commands+0x318>
ffffffffc02007b6:	9cbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ba:	646c                	ld	a1,200(s0)
ffffffffc02007bc:	00004517          	auipc	a0,0x4
ffffffffc02007c0:	67450513          	addi	a0,a0,1652 # ffffffffc0204e30 <commands+0x330>
ffffffffc02007c4:	9bdff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007c8:	686c                	ld	a1,208(s0)
ffffffffc02007ca:	00004517          	auipc	a0,0x4
ffffffffc02007ce:	67e50513          	addi	a0,a0,1662 # ffffffffc0204e48 <commands+0x348>
ffffffffc02007d2:	9afff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007d6:	6c6c                	ld	a1,216(s0)
ffffffffc02007d8:	00004517          	auipc	a0,0x4
ffffffffc02007dc:	68850513          	addi	a0,a0,1672 # ffffffffc0204e60 <commands+0x360>
ffffffffc02007e0:	9a1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007e4:	706c                	ld	a1,224(s0)
ffffffffc02007e6:	00004517          	auipc	a0,0x4
ffffffffc02007ea:	69250513          	addi	a0,a0,1682 # ffffffffc0204e78 <commands+0x378>
ffffffffc02007ee:	993ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007f2:	746c                	ld	a1,232(s0)
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	69c50513          	addi	a0,a0,1692 # ffffffffc0204e90 <commands+0x390>
ffffffffc02007fc:	985ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200800:	786c                	ld	a1,240(s0)
ffffffffc0200802:	00004517          	auipc	a0,0x4
ffffffffc0200806:	6a650513          	addi	a0,a0,1702 # ffffffffc0204ea8 <commands+0x3a8>
ffffffffc020080a:	977ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020080e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200810:	6402                	ld	s0,0(sp)
ffffffffc0200812:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200814:	00004517          	auipc	a0,0x4
ffffffffc0200818:	6ac50513          	addi	a0,a0,1708 # ffffffffc0204ec0 <commands+0x3c0>
}
ffffffffc020081c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020081e:	b28d                	j	ffffffffc0200180 <cprintf>

ffffffffc0200820 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200820:	1141                	addi	sp,sp,-16
ffffffffc0200822:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200824:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200826:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200828:	00004517          	auipc	a0,0x4
ffffffffc020082c:	6b050513          	addi	a0,a0,1712 # ffffffffc0204ed8 <commands+0x3d8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200830:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200832:	94fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200836:	8522                	mv	a0,s0
ffffffffc0200838:	e1dff0ef          	jal	ra,ffffffffc0200654 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020083c:	10043583          	ld	a1,256(s0)
ffffffffc0200840:	00004517          	auipc	a0,0x4
ffffffffc0200844:	6b050513          	addi	a0,a0,1712 # ffffffffc0204ef0 <commands+0x3f0>
ffffffffc0200848:	939ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020084c:	10843583          	ld	a1,264(s0)
ffffffffc0200850:	00004517          	auipc	a0,0x4
ffffffffc0200854:	6b850513          	addi	a0,a0,1720 # ffffffffc0204f08 <commands+0x408>
ffffffffc0200858:	929ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020085c:	11043583          	ld	a1,272(s0)
ffffffffc0200860:	00004517          	auipc	a0,0x4
ffffffffc0200864:	6c050513          	addi	a0,a0,1728 # ffffffffc0204f20 <commands+0x420>
ffffffffc0200868:	919ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020086c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200870:	6402                	ld	s0,0(sp)
ffffffffc0200872:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200874:	00004517          	auipc	a0,0x4
ffffffffc0200878:	6c450513          	addi	a0,a0,1732 # ffffffffc0204f38 <commands+0x438>
}
ffffffffc020087c:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020087e:	903ff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0200882 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200882:	11853783          	ld	a5,280(a0)
ffffffffc0200886:	472d                	li	a4,11
ffffffffc0200888:	0786                	slli	a5,a5,0x1
ffffffffc020088a:	8385                	srli	a5,a5,0x1
ffffffffc020088c:	06f76c63          	bltu	a4,a5,ffffffffc0200904 <interrupt_handler+0x82>
ffffffffc0200890:	00004717          	auipc	a4,0x4
ffffffffc0200894:	77070713          	addi	a4,a4,1904 # ffffffffc0205000 <commands+0x500>
ffffffffc0200898:	078a                	slli	a5,a5,0x2
ffffffffc020089a:	97ba                	add	a5,a5,a4
ffffffffc020089c:	439c                	lw	a5,0(a5)
ffffffffc020089e:	97ba                	add	a5,a5,a4
ffffffffc02008a0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02008a2:	00004517          	auipc	a0,0x4
ffffffffc02008a6:	70e50513          	addi	a0,a0,1806 # ffffffffc0204fb0 <commands+0x4b0>
ffffffffc02008aa:	8d7ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008ae:	00004517          	auipc	a0,0x4
ffffffffc02008b2:	6e250513          	addi	a0,a0,1762 # ffffffffc0204f90 <commands+0x490>
ffffffffc02008b6:	8cbff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008ba:	00004517          	auipc	a0,0x4
ffffffffc02008be:	69650513          	addi	a0,a0,1686 # ffffffffc0204f50 <commands+0x450>
ffffffffc02008c2:	8bfff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008c6:	00004517          	auipc	a0,0x4
ffffffffc02008ca:	6aa50513          	addi	a0,a0,1706 # ffffffffc0204f70 <commands+0x470>
ffffffffc02008ce:	8b3ff06f          	j	ffffffffc0200180 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008d2:	1141                	addi	sp,sp,-16
ffffffffc02008d4:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02008d6:	c05ff0ef          	jal	ra,ffffffffc02004da <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02008da:	00015697          	auipc	a3,0x15
ffffffffc02008de:	d4668693          	addi	a3,a3,-698 # ffffffffc0215620 <ticks>
ffffffffc02008e2:	629c                	ld	a5,0(a3)
ffffffffc02008e4:	06400713          	li	a4,100
ffffffffc02008e8:	0785                	addi	a5,a5,1
ffffffffc02008ea:	02e7f733          	remu	a4,a5,a4
ffffffffc02008ee:	e29c                	sd	a5,0(a3)
ffffffffc02008f0:	cb19                	beqz	a4,ffffffffc0200906 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008f2:	60a2                	ld	ra,8(sp)
ffffffffc02008f4:	0141                	addi	sp,sp,16
ffffffffc02008f6:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc02008f8:	00004517          	auipc	a0,0x4
ffffffffc02008fc:	6e850513          	addi	a0,a0,1768 # ffffffffc0204fe0 <commands+0x4e0>
ffffffffc0200900:	881ff06f          	j	ffffffffc0200180 <cprintf>
            print_trapframe(tf);
ffffffffc0200904:	bf31                	j	ffffffffc0200820 <print_trapframe>
}
ffffffffc0200906:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200908:	06400593          	li	a1,100
ffffffffc020090c:	00004517          	auipc	a0,0x4
ffffffffc0200910:	6c450513          	addi	a0,a0,1732 # ffffffffc0204fd0 <commands+0x4d0>
}
ffffffffc0200914:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200916:	86bff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc020091a <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020091a:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020091e:	1101                	addi	sp,sp,-32
ffffffffc0200920:	e822                	sd	s0,16(sp)
ffffffffc0200922:	ec06                	sd	ra,24(sp)
ffffffffc0200924:	e426                	sd	s1,8(sp)
ffffffffc0200926:	473d                	li	a4,15
ffffffffc0200928:	842a                	mv	s0,a0
ffffffffc020092a:	14f76a63          	bltu	a4,a5,ffffffffc0200a7e <exception_handler+0x164>
ffffffffc020092e:	00005717          	auipc	a4,0x5
ffffffffc0200932:	8ba70713          	addi	a4,a4,-1862 # ffffffffc02051e8 <commands+0x6e8>
ffffffffc0200936:	078a                	slli	a5,a5,0x2
ffffffffc0200938:	97ba                	add	a5,a5,a4
ffffffffc020093a:	439c                	lw	a5,0(a5)
ffffffffc020093c:	97ba                	add	a5,a5,a4
ffffffffc020093e:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200940:	00005517          	auipc	a0,0x5
ffffffffc0200944:	89050513          	addi	a0,a0,-1904 # ffffffffc02051d0 <commands+0x6d0>
ffffffffc0200948:	839ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020094c:	8522                	mv	a0,s0
ffffffffc020094e:	c7dff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc0200952:	84aa                	mv	s1,a0
ffffffffc0200954:	12051b63          	bnez	a0,ffffffffc0200a8a <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200958:	60e2                	ld	ra,24(sp)
ffffffffc020095a:	6442                	ld	s0,16(sp)
ffffffffc020095c:	64a2                	ld	s1,8(sp)
ffffffffc020095e:	6105                	addi	sp,sp,32
ffffffffc0200960:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200962:	00004517          	auipc	a0,0x4
ffffffffc0200966:	6ce50513          	addi	a0,a0,1742 # ffffffffc0205030 <commands+0x530>
}
ffffffffc020096a:	6442                	ld	s0,16(sp)
ffffffffc020096c:	60e2                	ld	ra,24(sp)
ffffffffc020096e:	64a2                	ld	s1,8(sp)
ffffffffc0200970:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200972:	80fff06f          	j	ffffffffc0200180 <cprintf>
ffffffffc0200976:	00004517          	auipc	a0,0x4
ffffffffc020097a:	6da50513          	addi	a0,a0,1754 # ffffffffc0205050 <commands+0x550>
ffffffffc020097e:	b7f5                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200980:	00004517          	auipc	a0,0x4
ffffffffc0200984:	6f050513          	addi	a0,a0,1776 # ffffffffc0205070 <commands+0x570>
ffffffffc0200988:	b7cd                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc020098a:	00004517          	auipc	a0,0x4
ffffffffc020098e:	6fe50513          	addi	a0,a0,1790 # ffffffffc0205088 <commands+0x588>
ffffffffc0200992:	bfe1                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc0200994:	00004517          	auipc	a0,0x4
ffffffffc0200998:	70450513          	addi	a0,a0,1796 # ffffffffc0205098 <commands+0x598>
ffffffffc020099c:	b7f9                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc020099e:	00004517          	auipc	a0,0x4
ffffffffc02009a2:	71a50513          	addi	a0,a0,1818 # ffffffffc02050b8 <commands+0x5b8>
ffffffffc02009a6:	fdaff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009aa:	8522                	mv	a0,s0
ffffffffc02009ac:	c1fff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc02009b0:	84aa                	mv	s1,a0
ffffffffc02009b2:	d15d                	beqz	a0,ffffffffc0200958 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009b4:	8522                	mv	a0,s0
ffffffffc02009b6:	e6bff0ef          	jal	ra,ffffffffc0200820 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ba:	86a6                	mv	a3,s1
ffffffffc02009bc:	00004617          	auipc	a2,0x4
ffffffffc02009c0:	71460613          	addi	a2,a2,1812 # ffffffffc02050d0 <commands+0x5d0>
ffffffffc02009c4:	0b300593          	li	a1,179
ffffffffc02009c8:	00004517          	auipc	a0,0x4
ffffffffc02009cc:	1f850513          	addi	a0,a0,504 # ffffffffc0204bc0 <commands+0xc0>
ffffffffc02009d0:	a77ff0ef          	jal	ra,ffffffffc0200446 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009d4:	00004517          	auipc	a0,0x4
ffffffffc02009d8:	71c50513          	addi	a0,a0,1820 # ffffffffc02050f0 <commands+0x5f0>
ffffffffc02009dc:	b779                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02009de:	00004517          	auipc	a0,0x4
ffffffffc02009e2:	72a50513          	addi	a0,a0,1834 # ffffffffc0205108 <commands+0x608>
ffffffffc02009e6:	f9aff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009ea:	8522                	mv	a0,s0
ffffffffc02009ec:	bdfff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc02009f0:	84aa                	mv	s1,a0
ffffffffc02009f2:	d13d                	beqz	a0,ffffffffc0200958 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009f4:	8522                	mv	a0,s0
ffffffffc02009f6:	e2bff0ef          	jal	ra,ffffffffc0200820 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009fa:	86a6                	mv	a3,s1
ffffffffc02009fc:	00004617          	auipc	a2,0x4
ffffffffc0200a00:	6d460613          	addi	a2,a2,1748 # ffffffffc02050d0 <commands+0x5d0>
ffffffffc0200a04:	0bd00593          	li	a1,189
ffffffffc0200a08:	00004517          	auipc	a0,0x4
ffffffffc0200a0c:	1b850513          	addi	a0,a0,440 # ffffffffc0204bc0 <commands+0xc0>
ffffffffc0200a10:	a37ff0ef          	jal	ra,ffffffffc0200446 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a14:	00004517          	auipc	a0,0x4
ffffffffc0200a18:	70c50513          	addi	a0,a0,1804 # ffffffffc0205120 <commands+0x620>
ffffffffc0200a1c:	b7b9                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a1e:	00004517          	auipc	a0,0x4
ffffffffc0200a22:	72250513          	addi	a0,a0,1826 # ffffffffc0205140 <commands+0x640>
ffffffffc0200a26:	b791                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a28:	00004517          	auipc	a0,0x4
ffffffffc0200a2c:	73850513          	addi	a0,a0,1848 # ffffffffc0205160 <commands+0x660>
ffffffffc0200a30:	bf2d                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a32:	00004517          	auipc	a0,0x4
ffffffffc0200a36:	74e50513          	addi	a0,a0,1870 # ffffffffc0205180 <commands+0x680>
ffffffffc0200a3a:	bf05                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a3c:	00004517          	auipc	a0,0x4
ffffffffc0200a40:	76450513          	addi	a0,a0,1892 # ffffffffc02051a0 <commands+0x6a0>
ffffffffc0200a44:	b71d                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a46:	00004517          	auipc	a0,0x4
ffffffffc0200a4a:	77250513          	addi	a0,a0,1906 # ffffffffc02051b8 <commands+0x6b8>
ffffffffc0200a4e:	f32ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a52:	8522                	mv	a0,s0
ffffffffc0200a54:	b77ff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc0200a58:	84aa                	mv	s1,a0
ffffffffc0200a5a:	ee050fe3          	beqz	a0,ffffffffc0200958 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a5e:	8522                	mv	a0,s0
ffffffffc0200a60:	dc1ff0ef          	jal	ra,ffffffffc0200820 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a64:	86a6                	mv	a3,s1
ffffffffc0200a66:	00004617          	auipc	a2,0x4
ffffffffc0200a6a:	66a60613          	addi	a2,a2,1642 # ffffffffc02050d0 <commands+0x5d0>
ffffffffc0200a6e:	0d300593          	li	a1,211
ffffffffc0200a72:	00004517          	auipc	a0,0x4
ffffffffc0200a76:	14e50513          	addi	a0,a0,334 # ffffffffc0204bc0 <commands+0xc0>
ffffffffc0200a7a:	9cdff0ef          	jal	ra,ffffffffc0200446 <__panic>
            print_trapframe(tf);
ffffffffc0200a7e:	8522                	mv	a0,s0
}
ffffffffc0200a80:	6442                	ld	s0,16(sp)
ffffffffc0200a82:	60e2                	ld	ra,24(sp)
ffffffffc0200a84:	64a2                	ld	s1,8(sp)
ffffffffc0200a86:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a88:	bb61                	j	ffffffffc0200820 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a8a:	8522                	mv	a0,s0
ffffffffc0200a8c:	d95ff0ef          	jal	ra,ffffffffc0200820 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a90:	86a6                	mv	a3,s1
ffffffffc0200a92:	00004617          	auipc	a2,0x4
ffffffffc0200a96:	63e60613          	addi	a2,a2,1598 # ffffffffc02050d0 <commands+0x5d0>
ffffffffc0200a9a:	0da00593          	li	a1,218
ffffffffc0200a9e:	00004517          	auipc	a0,0x4
ffffffffc0200aa2:	12250513          	addi	a0,a0,290 # ffffffffc0204bc0 <commands+0xc0>
ffffffffc0200aa6:	9a1ff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0200aaa <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200aaa:	11853783          	ld	a5,280(a0)
ffffffffc0200aae:	0007c363          	bltz	a5,ffffffffc0200ab4 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200ab2:	b5a5                	j	ffffffffc020091a <exception_handler>
        interrupt_handler(tf);
ffffffffc0200ab4:	b3f9                	j	ffffffffc0200882 <interrupt_handler>
	...

ffffffffc0200ab8 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ab8:	14011073          	csrw	sscratch,sp
ffffffffc0200abc:	712d                	addi	sp,sp,-288
ffffffffc0200abe:	e406                	sd	ra,8(sp)
ffffffffc0200ac0:	ec0e                	sd	gp,24(sp)
ffffffffc0200ac2:	f012                	sd	tp,32(sp)
ffffffffc0200ac4:	f416                	sd	t0,40(sp)
ffffffffc0200ac6:	f81a                	sd	t1,48(sp)
ffffffffc0200ac8:	fc1e                	sd	t2,56(sp)
ffffffffc0200aca:	e0a2                	sd	s0,64(sp)
ffffffffc0200acc:	e4a6                	sd	s1,72(sp)
ffffffffc0200ace:	e8aa                	sd	a0,80(sp)
ffffffffc0200ad0:	ecae                	sd	a1,88(sp)
ffffffffc0200ad2:	f0b2                	sd	a2,96(sp)
ffffffffc0200ad4:	f4b6                	sd	a3,104(sp)
ffffffffc0200ad6:	f8ba                	sd	a4,112(sp)
ffffffffc0200ad8:	fcbe                	sd	a5,120(sp)
ffffffffc0200ada:	e142                	sd	a6,128(sp)
ffffffffc0200adc:	e546                	sd	a7,136(sp)
ffffffffc0200ade:	e94a                	sd	s2,144(sp)
ffffffffc0200ae0:	ed4e                	sd	s3,152(sp)
ffffffffc0200ae2:	f152                	sd	s4,160(sp)
ffffffffc0200ae4:	f556                	sd	s5,168(sp)
ffffffffc0200ae6:	f95a                	sd	s6,176(sp)
ffffffffc0200ae8:	fd5e                	sd	s7,184(sp)
ffffffffc0200aea:	e1e2                	sd	s8,192(sp)
ffffffffc0200aec:	e5e6                	sd	s9,200(sp)
ffffffffc0200aee:	e9ea                	sd	s10,208(sp)
ffffffffc0200af0:	edee                	sd	s11,216(sp)
ffffffffc0200af2:	f1f2                	sd	t3,224(sp)
ffffffffc0200af4:	f5f6                	sd	t4,232(sp)
ffffffffc0200af6:	f9fa                	sd	t5,240(sp)
ffffffffc0200af8:	fdfe                	sd	t6,248(sp)
ffffffffc0200afa:	14002473          	csrr	s0,sscratch
ffffffffc0200afe:	100024f3          	csrr	s1,sstatus
ffffffffc0200b02:	14102973          	csrr	s2,sepc
ffffffffc0200b06:	143029f3          	csrr	s3,stval
ffffffffc0200b0a:	14202a73          	csrr	s4,scause
ffffffffc0200b0e:	e822                	sd	s0,16(sp)
ffffffffc0200b10:	e226                	sd	s1,256(sp)
ffffffffc0200b12:	e64a                	sd	s2,264(sp)
ffffffffc0200b14:	ea4e                	sd	s3,272(sp)
ffffffffc0200b16:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b18:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b1a:	f91ff0ef          	jal	ra,ffffffffc0200aaa <trap>

ffffffffc0200b1e <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b1e:	6492                	ld	s1,256(sp)
ffffffffc0200b20:	6932                	ld	s2,264(sp)
ffffffffc0200b22:	10049073          	csrw	sstatus,s1
ffffffffc0200b26:	14191073          	csrw	sepc,s2
ffffffffc0200b2a:	60a2                	ld	ra,8(sp)
ffffffffc0200b2c:	61e2                	ld	gp,24(sp)
ffffffffc0200b2e:	7202                	ld	tp,32(sp)
ffffffffc0200b30:	72a2                	ld	t0,40(sp)
ffffffffc0200b32:	7342                	ld	t1,48(sp)
ffffffffc0200b34:	73e2                	ld	t2,56(sp)
ffffffffc0200b36:	6406                	ld	s0,64(sp)
ffffffffc0200b38:	64a6                	ld	s1,72(sp)
ffffffffc0200b3a:	6546                	ld	a0,80(sp)
ffffffffc0200b3c:	65e6                	ld	a1,88(sp)
ffffffffc0200b3e:	7606                	ld	a2,96(sp)
ffffffffc0200b40:	76a6                	ld	a3,104(sp)
ffffffffc0200b42:	7746                	ld	a4,112(sp)
ffffffffc0200b44:	77e6                	ld	a5,120(sp)
ffffffffc0200b46:	680a                	ld	a6,128(sp)
ffffffffc0200b48:	68aa                	ld	a7,136(sp)
ffffffffc0200b4a:	694a                	ld	s2,144(sp)
ffffffffc0200b4c:	69ea                	ld	s3,152(sp)
ffffffffc0200b4e:	7a0a                	ld	s4,160(sp)
ffffffffc0200b50:	7aaa                	ld	s5,168(sp)
ffffffffc0200b52:	7b4a                	ld	s6,176(sp)
ffffffffc0200b54:	7bea                	ld	s7,184(sp)
ffffffffc0200b56:	6c0e                	ld	s8,192(sp)
ffffffffc0200b58:	6cae                	ld	s9,200(sp)
ffffffffc0200b5a:	6d4e                	ld	s10,208(sp)
ffffffffc0200b5c:	6dee                	ld	s11,216(sp)
ffffffffc0200b5e:	7e0e                	ld	t3,224(sp)
ffffffffc0200b60:	7eae                	ld	t4,232(sp)
ffffffffc0200b62:	7f4e                	ld	t5,240(sp)
ffffffffc0200b64:	7fee                	ld	t6,248(sp)
ffffffffc0200b66:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200b68:	10200073          	sret

ffffffffc0200b6c <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200b6c:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200b6e:	bf45                	j	ffffffffc0200b1e <__trapret>
	...

ffffffffc0200b72 <buddy_system_init>:
 * 功能:初始化free_area(清空性质)
 */
static void buddy_system_init(void) 
{
    //cprintf("调试信息:进入buddy_system_init()\n");
    Base = NULL;
ffffffffc0200b72:	00011797          	auipc	a5,0x11
ffffffffc0200b76:	8d678793          	addi	a5,a5,-1834 # ffffffffc0211448 <free_area>
ffffffffc0200b7a:	0007b023          	sd	zero,0(a5)
    nr_free = 0;
ffffffffc0200b7e:	0007a823          	sw	zero,16(a5)
    max_size = 0;   
ffffffffc0200b82:	0007ac23          	sw	zero,24(a5)
}
ffffffffc0200b86:	8082                	ret

ffffffffc0200b88 <buddy_system_nr_free_pages>:
 * 注意:该函数返回值代表总共的可用可用物理页数，不代表可以申请连续的这么多
 */
static size_t buddy_system_nr_free_pages(void) 
{
    return nr_free;
}
ffffffffc0200b88:	00011517          	auipc	a0,0x11
ffffffffc0200b8c:	8d056503          	lwu	a0,-1840(a0) # ffffffffc0211458 <free_area+0x10>
ffffffffc0200b90:	8082                	ret

ffffffffc0200b92 <buddy_system_check>:
 * 功能:检查buddy_system是否正确
 * 注意:本函数参考自https://github.com/AllenKaixuan/Operating-System/blob/main/labcodes/lab2/kern/mm/buddy_pmm.c的buddy_check()函数。
 * 注意:以上参考代码本身存在一定缺陷（甚至可以说是错误）,对其进行较大幅度修正。
 */
static void buddy_system_check(void) 
{
ffffffffc0200b92:	7179                	addi	sp,sp,-48
    //cprintf("[调试信息]进入buddy_system_check()函数\n");
    cprintf("################################################################################\n");
ffffffffc0200b94:	00004517          	auipc	a0,0x4
ffffffffc0200b98:	69450513          	addi	a0,a0,1684 # ffffffffc0205228 <commands+0x728>
{
ffffffffc0200b9c:	f406                	sd	ra,40(sp)
ffffffffc0200b9e:	f022                	sd	s0,32(sp)
ffffffffc0200ba0:	ec26                	sd	s1,24(sp)
ffffffffc0200ba2:	e84a                	sd	s2,16(sp)
ffffffffc0200ba4:	e44e                	sd	s3,8(sp)
    cprintf("################################################################################\n");
ffffffffc0200ba6:	ddaff0ef          	jal	ra,ffffffffc0200180 <cprintf>
	cprintf("[自检程序]启动buddy_system内存管理器的启动自检程序\n");
ffffffffc0200baa:	00004517          	auipc	a0,0x4
ffffffffc0200bae:	6d650513          	addi	a0,a0,1750 # ffffffffc0205280 <commands+0x780>
ffffffffc0200bb2:	dceff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int all_pages = nr_free_pages();
ffffffffc0200bb6:	0da010ef          	jal	ra,ffffffffc0201c90 <nr_free_pages>
    struct Page* p0, *p1, *p2, *p3;
    // 分配过大的页数
    assert(alloc_pages(all_pages + 1) == NULL);
ffffffffc0200bba:	2505                	addiw	a0,a0,1
ffffffffc0200bbc:	002010ef          	jal	ra,ffffffffc0201bbe <alloc_pages>
ffffffffc0200bc0:	26051d63          	bnez	a0,ffffffffc0200e3a <buddy_system_check+0x2a8>
    // 分配两个组页
    p0 = alloc_pages(1);
ffffffffc0200bc4:	4505                	li	a0,1
ffffffffc0200bc6:	7f9000ef          	jal	ra,ffffffffc0201bbe <alloc_pages>
ffffffffc0200bca:	842a                	mv	s0,a0
    test_print(p0,16);//1
    assert(p0 != NULL);
ffffffffc0200bcc:	24050763          	beqz	a0,ffffffffc0200e1a <buddy_system_check+0x288>
    p1 = alloc_pages(2);
ffffffffc0200bd0:	4509                	li	a0,2
ffffffffc0200bd2:	7ed000ef          	jal	ra,ffffffffc0201bbe <alloc_pages>
    test_print(p0,16);//2
    assert(p1 == p0 + 2);
ffffffffc0200bd6:	08040793          	addi	a5,s0,128
    p1 = alloc_pages(2);
ffffffffc0200bda:	84aa                	mv	s1,a0
    assert(p1 == p0 + 2);
ffffffffc0200bdc:	20f51f63          	bne	a0,a5,ffffffffc0200dfa <buddy_system_check+0x268>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200be0:	641c                	ld	a5,8(s0)
    assert(!PageReserved(p0) && !PageProperty(p0));
ffffffffc0200be2:	8b85                	andi	a5,a5,1
ffffffffc0200be4:	12079b63          	bnez	a5,ffffffffc0200d1a <buddy_system_check+0x188>
ffffffffc0200be8:	641c                	ld	a5,8(s0)
ffffffffc0200bea:	8385                	srli	a5,a5,0x1
ffffffffc0200bec:	8b85                	andi	a5,a5,1
ffffffffc0200bee:	12079663          	bnez	a5,ffffffffc0200d1a <buddy_system_check+0x188>
ffffffffc0200bf2:	651c                	ld	a5,8(a0)
    assert(!PageReserved(p1) && !PageProperty(p1));
ffffffffc0200bf4:	8b85                	andi	a5,a5,1
ffffffffc0200bf6:	10079263          	bnez	a5,ffffffffc0200cfa <buddy_system_check+0x168>
ffffffffc0200bfa:	651c                	ld	a5,8(a0)
ffffffffc0200bfc:	8385                	srli	a5,a5,0x1
ffffffffc0200bfe:	8b85                	andi	a5,a5,1
ffffffffc0200c00:	0e079d63          	bnez	a5,ffffffffc0200cfa <buddy_system_check+0x168>
    // 再分配两个组页
    p2 = alloc_pages(1);
ffffffffc0200c04:	4505                	li	a0,1
ffffffffc0200c06:	7b9000ef          	jal	ra,ffffffffc0201bbe <alloc_pages>
    test_print(p0,16);//3
    assert(p2 == p0 + 1);
ffffffffc0200c0a:	04040793          	addi	a5,s0,64
    p2 = alloc_pages(1);
ffffffffc0200c0e:	89aa                	mv	s3,a0
    assert(p2 == p0 + 1);
ffffffffc0200c10:	18f51563          	bne	a0,a5,ffffffffc0200d9a <buddy_system_check+0x208>
    p3 = alloc_pages(8);
ffffffffc0200c14:	4521                	li	a0,8
ffffffffc0200c16:	7a9000ef          	jal	ra,ffffffffc0201bbe <alloc_pages>
    test_print(p0,16);//4
    assert(p3 == p0 + 8);
ffffffffc0200c1a:	20040793          	addi	a5,s0,512
    p3 = alloc_pages(8);
ffffffffc0200c1e:	892a                	mv	s2,a0
    assert(p3 == p0 + 8);
ffffffffc0200c20:	14f51d63          	bne	a0,a5,ffffffffc0200d7a <buddy_system_check+0x1e8>
ffffffffc0200c24:	651c                	ld	a5,8(a0)
ffffffffc0200c26:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p3) && !PageProperty(p3 + 7) && PageProperty(p3 + 8));
ffffffffc0200c28:	8b85                	andi	a5,a5,1
ffffffffc0200c2a:	ebc5                	bnez	a5,ffffffffc0200cda <buddy_system_check+0x148>
ffffffffc0200c2c:	1c853783          	ld	a5,456(a0)
ffffffffc0200c30:	8385                	srli	a5,a5,0x1
ffffffffc0200c32:	8b85                	andi	a5,a5,1
ffffffffc0200c34:	e3dd                	bnez	a5,ffffffffc0200cda <buddy_system_check+0x148>
ffffffffc0200c36:	20853783          	ld	a5,520(a0)
ffffffffc0200c3a:	8385                	srli	a5,a5,0x1
ffffffffc0200c3c:	8b85                	andi	a5,a5,1
ffffffffc0200c3e:	cfd1                	beqz	a5,ffffffffc0200cda <buddy_system_check+0x148>
    // 回收页
    free_pages(p1, 2);
ffffffffc0200c40:	4589                	li	a1,2
ffffffffc0200c42:	8526                	mv	a0,s1
ffffffffc0200c44:	00c010ef          	jal	ra,ffffffffc0201c50 <free_pages>
ffffffffc0200c48:	649c                	ld	a5,8(s1)
ffffffffc0200c4a:	8385                	srli	a5,a5,0x1
    test_print(p0,16);//5
    //assert(PageProperty(p1) && PageProperty(p1 + 1));参考代码修正
    assert(PageProperty(p1) && !PageProperty(p1 + 1));
ffffffffc0200c4c:	8b85                	andi	a5,a5,1
ffffffffc0200c4e:	0e078663          	beqz	a5,ffffffffc0200d3a <buddy_system_check+0x1a8>
ffffffffc0200c52:	64bc                	ld	a5,72(s1)
ffffffffc0200c54:	8385                	srli	a5,a5,0x1
ffffffffc0200c56:	8b85                	andi	a5,a5,1
ffffffffc0200c58:	0e079163          	bnez	a5,ffffffffc0200d3a <buddy_system_check+0x1a8>
    assert(p1->ref == 0);
ffffffffc0200c5c:	409c                	lw	a5,0(s1)
ffffffffc0200c5e:	0e079e63          	bnez	a5,ffffffffc0200d5a <buddy_system_check+0x1c8>
    free_pages(p0, 1);
ffffffffc0200c62:	4585                	li	a1,1
ffffffffc0200c64:	8522                	mv	a0,s0
ffffffffc0200c66:	7eb000ef          	jal	ra,ffffffffc0201c50 <free_pages>
    test_print(p0,16);//6
    free_pages(p2, 1);
ffffffffc0200c6a:	854e                	mv	a0,s3
ffffffffc0200c6c:	4585                	li	a1,1
ffffffffc0200c6e:	7e3000ef          	jal	ra,ffffffffc0201c50 <free_pages>
    test_print(p0,16);//7
    // 回收后再分配
    p2 = alloc_pages(3);
ffffffffc0200c72:	450d                	li	a0,3
ffffffffc0200c74:	74b000ef          	jal	ra,ffffffffc0201bbe <alloc_pages>
    test_print(p0,16);//8
    assert(p2 == p0);
ffffffffc0200c78:	16a41163          	bne	s0,a0,ffffffffc0200dda <buddy_system_check+0x248>
    free_pages(p2, 3);//9
ffffffffc0200c7c:	458d                	li	a1,3
ffffffffc0200c7e:	7d3000ef          	jal	ra,ffffffffc0201c50 <free_pages>
    assert((p2 + 2)->ref == 0);
ffffffffc0200c82:	08042783          	lw	a5,128(s0)
ffffffffc0200c86:	12079a63          	bnez	a5,ffffffffc0200dba <buddy_system_check+0x228>
    test_print(p0,16);//10
    //assert(nr_free_pages() == all_pages >> 1);
    p1 = alloc_pages(129);
ffffffffc0200c8a:	08100513          	li	a0,129
ffffffffc0200c8e:	731000ef          	jal	ra,ffffffffc0201bbe <alloc_pages>
    test_print(p0,16);//11
    assert(p1 == p0 + 256);
ffffffffc0200c92:	6791                	lui	a5,0x4
ffffffffc0200c94:	943e                	add	s0,s0,a5
ffffffffc0200c96:	1c851263          	bne	a0,s0,ffffffffc0200e5a <buddy_system_check+0x2c8>
    //free_pages(p1, 256);
    free_pages(p1, 129);//参考代码适配
ffffffffc0200c9a:	08100593          	li	a1,129
ffffffffc0200c9e:	7b3000ef          	jal	ra,ffffffffc0201c50 <free_pages>
    test_print(p0,16);//12
    free_pages(p3, 8);
ffffffffc0200ca2:	45a1                	li	a1,8
ffffffffc0200ca4:	854a                	mv	a0,s2
ffffffffc0200ca6:	7ab000ef          	jal	ra,ffffffffc0201c50 <free_pages>
    test_print(p0,16);//13
    cprintf("[自检程序]退出buddy_system内存管理器的启动自检程序\n");
ffffffffc0200caa:	00004517          	auipc	a0,0x4
ffffffffc0200cae:	7ce50513          	addi	a0,a0,1998 # ffffffffc0205478 <commands+0x978>
ffffffffc0200cb2:	cceff0ef          	jal	ra,ffffffffc0200180 <cprintf>
	cprintf("[自检程序]buddy_system内存管理器的工作正常\n");
ffffffffc0200cb6:	00005517          	auipc	a0,0x5
ffffffffc0200cba:	80a50513          	addi	a0,a0,-2038 # ffffffffc02054c0 <commands+0x9c0>
ffffffffc0200cbe:	cc2ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
	cprintf("################################################################################\n");
}
ffffffffc0200cc2:	7402                	ld	s0,32(sp)
ffffffffc0200cc4:	70a2                	ld	ra,40(sp)
ffffffffc0200cc6:	64e2                	ld	s1,24(sp)
ffffffffc0200cc8:	6942                	ld	s2,16(sp)
ffffffffc0200cca:	69a2                	ld	s3,8(sp)
	cprintf("################################################################################\n");
ffffffffc0200ccc:	00004517          	auipc	a0,0x4
ffffffffc0200cd0:	55c50513          	addi	a0,a0,1372 # ffffffffc0205228 <commands+0x728>
}
ffffffffc0200cd4:	6145                	addi	sp,sp,48
	cprintf("################################################################################\n");
ffffffffc0200cd6:	caaff06f          	j	ffffffffc0200180 <cprintf>
    assert(!PageProperty(p3) && !PageProperty(p3 + 7) && PageProperty(p3 + 8));
ffffffffc0200cda:	00004697          	auipc	a3,0x4
ffffffffc0200cde:	6de68693          	addi	a3,a3,1758 # ffffffffc02053b8 <commands+0x8b8>
ffffffffc0200ce2:	00004617          	auipc	a2,0x4
ffffffffc0200ce6:	60e60613          	addi	a2,a2,1550 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0200cea:	13800593          	li	a1,312
ffffffffc0200cee:	00004517          	auipc	a0,0x4
ffffffffc0200cf2:	61a50513          	addi	a0,a0,1562 # ffffffffc0205308 <commands+0x808>
ffffffffc0200cf6:	f50ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(!PageReserved(p1) && !PageProperty(p1));
ffffffffc0200cfa:	00004697          	auipc	a3,0x4
ffffffffc0200cfe:	67668693          	addi	a3,a3,1654 # ffffffffc0205370 <commands+0x870>
ffffffffc0200d02:	00004617          	auipc	a2,0x4
ffffffffc0200d06:	5ee60613          	addi	a2,a2,1518 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0200d0a:	13000593          	li	a1,304
ffffffffc0200d0e:	00004517          	auipc	a0,0x4
ffffffffc0200d12:	5fa50513          	addi	a0,a0,1530 # ffffffffc0205308 <commands+0x808>
ffffffffc0200d16:	f30ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(!PageReserved(p0) && !PageProperty(p0));
ffffffffc0200d1a:	00004697          	auipc	a3,0x4
ffffffffc0200d1e:	62e68693          	addi	a3,a3,1582 # ffffffffc0205348 <commands+0x848>
ffffffffc0200d22:	00004617          	auipc	a2,0x4
ffffffffc0200d26:	5ce60613          	addi	a2,a2,1486 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0200d2a:	12f00593          	li	a1,303
ffffffffc0200d2e:	00004517          	auipc	a0,0x4
ffffffffc0200d32:	5da50513          	addi	a0,a0,1498 # ffffffffc0205308 <commands+0x808>
ffffffffc0200d36:	f10ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(PageProperty(p1) && !PageProperty(p1 + 1));
ffffffffc0200d3a:	00004697          	auipc	a3,0x4
ffffffffc0200d3e:	6c668693          	addi	a3,a3,1734 # ffffffffc0205400 <commands+0x900>
ffffffffc0200d42:	00004617          	auipc	a2,0x4
ffffffffc0200d46:	5ae60613          	addi	a2,a2,1454 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0200d4a:	13d00593          	li	a1,317
ffffffffc0200d4e:	00004517          	auipc	a0,0x4
ffffffffc0200d52:	5ba50513          	addi	a0,a0,1466 # ffffffffc0205308 <commands+0x808>
ffffffffc0200d56:	ef0ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p1->ref == 0);
ffffffffc0200d5a:	00004697          	auipc	a3,0x4
ffffffffc0200d5e:	6d668693          	addi	a3,a3,1750 # ffffffffc0205430 <commands+0x930>
ffffffffc0200d62:	00004617          	auipc	a2,0x4
ffffffffc0200d66:	58e60613          	addi	a2,a2,1422 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0200d6a:	13e00593          	li	a1,318
ffffffffc0200d6e:	00004517          	auipc	a0,0x4
ffffffffc0200d72:	59a50513          	addi	a0,a0,1434 # ffffffffc0205308 <commands+0x808>
ffffffffc0200d76:	ed0ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p3 == p0 + 8);
ffffffffc0200d7a:	00004697          	auipc	a3,0x4
ffffffffc0200d7e:	62e68693          	addi	a3,a3,1582 # ffffffffc02053a8 <commands+0x8a8>
ffffffffc0200d82:	00004617          	auipc	a2,0x4
ffffffffc0200d86:	56e60613          	addi	a2,a2,1390 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0200d8a:	13700593          	li	a1,311
ffffffffc0200d8e:	00004517          	auipc	a0,0x4
ffffffffc0200d92:	57a50513          	addi	a0,a0,1402 # ffffffffc0205308 <commands+0x808>
ffffffffc0200d96:	eb0ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p2 == p0 + 1);
ffffffffc0200d9a:	00004697          	auipc	a3,0x4
ffffffffc0200d9e:	5fe68693          	addi	a3,a3,1534 # ffffffffc0205398 <commands+0x898>
ffffffffc0200da2:	00004617          	auipc	a2,0x4
ffffffffc0200da6:	54e60613          	addi	a2,a2,1358 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0200daa:	13400593          	li	a1,308
ffffffffc0200dae:	00004517          	auipc	a0,0x4
ffffffffc0200db2:	55a50513          	addi	a0,a0,1370 # ffffffffc0205308 <commands+0x808>
ffffffffc0200db6:	e90ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((p2 + 2)->ref == 0);
ffffffffc0200dba:	00004697          	auipc	a3,0x4
ffffffffc0200dbe:	69668693          	addi	a3,a3,1686 # ffffffffc0205450 <commands+0x950>
ffffffffc0200dc2:	00004617          	auipc	a2,0x4
ffffffffc0200dc6:	52e60613          	addi	a2,a2,1326 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0200dca:	14800593          	li	a1,328
ffffffffc0200dce:	00004517          	auipc	a0,0x4
ffffffffc0200dd2:	53a50513          	addi	a0,a0,1338 # ffffffffc0205308 <commands+0x808>
ffffffffc0200dd6:	e70ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p2 == p0);
ffffffffc0200dda:	00004697          	auipc	a3,0x4
ffffffffc0200dde:	66668693          	addi	a3,a3,1638 # ffffffffc0205440 <commands+0x940>
ffffffffc0200de2:	00004617          	auipc	a2,0x4
ffffffffc0200de6:	50e60613          	addi	a2,a2,1294 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0200dea:	14600593          	li	a1,326
ffffffffc0200dee:	00004517          	auipc	a0,0x4
ffffffffc0200df2:	51a50513          	addi	a0,a0,1306 # ffffffffc0205308 <commands+0x808>
ffffffffc0200df6:	e50ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p1 == p0 + 2);
ffffffffc0200dfa:	00004697          	auipc	a3,0x4
ffffffffc0200dfe:	53e68693          	addi	a3,a3,1342 # ffffffffc0205338 <commands+0x838>
ffffffffc0200e02:	00004617          	auipc	a2,0x4
ffffffffc0200e06:	4ee60613          	addi	a2,a2,1262 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0200e0a:	12e00593          	li	a1,302
ffffffffc0200e0e:	00004517          	auipc	a0,0x4
ffffffffc0200e12:	4fa50513          	addi	a0,a0,1274 # ffffffffc0205308 <commands+0x808>
ffffffffc0200e16:	e30ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p0 != NULL);
ffffffffc0200e1a:	00004697          	auipc	a3,0x4
ffffffffc0200e1e:	50e68693          	addi	a3,a3,1294 # ffffffffc0205328 <commands+0x828>
ffffffffc0200e22:	00004617          	auipc	a2,0x4
ffffffffc0200e26:	4ce60613          	addi	a2,a2,1230 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0200e2a:	12b00593          	li	a1,299
ffffffffc0200e2e:	00004517          	auipc	a0,0x4
ffffffffc0200e32:	4da50513          	addi	a0,a0,1242 # ffffffffc0205308 <commands+0x808>
ffffffffc0200e36:	e10ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(alloc_pages(all_pages + 1) == NULL);
ffffffffc0200e3a:	00004697          	auipc	a3,0x4
ffffffffc0200e3e:	48e68693          	addi	a3,a3,1166 # ffffffffc02052c8 <commands+0x7c8>
ffffffffc0200e42:	00004617          	auipc	a2,0x4
ffffffffc0200e46:	4ae60613          	addi	a2,a2,1198 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0200e4a:	12700593          	li	a1,295
ffffffffc0200e4e:	00004517          	auipc	a0,0x4
ffffffffc0200e52:	4ba50513          	addi	a0,a0,1210 # ffffffffc0205308 <commands+0x808>
ffffffffc0200e56:	df0ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(p1 == p0 + 256);
ffffffffc0200e5a:	00004697          	auipc	a3,0x4
ffffffffc0200e5e:	60e68693          	addi	a3,a3,1550 # ffffffffc0205468 <commands+0x968>
ffffffffc0200e62:	00004617          	auipc	a2,0x4
ffffffffc0200e66:	48e60613          	addi	a2,a2,1166 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0200e6a:	14d00593          	li	a1,333
ffffffffc0200e6e:	00004517          	auipc	a0,0x4
ffffffffc0200e72:	49a50513          	addi	a0,a0,1178 # ffffffffc0205308 <commands+0x808>
ffffffffc0200e76:	dd0ff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0200e7a <up_to_2_power>:
    assert(n > 0);
ffffffffc0200e7a:	c515                	beqz	a0,ffffffffc0200ea6 <up_to_2_power+0x2c>
    n--; 
ffffffffc0200e7c:	157d                	addi	a0,a0,-1
    n |= n >> 1;  
ffffffffc0200e7e:	00155793          	srli	a5,a0,0x1
ffffffffc0200e82:	8d5d                	or	a0,a0,a5
    n |= n >> 2;  
ffffffffc0200e84:	00255793          	srli	a5,a0,0x2
ffffffffc0200e88:	8d5d                	or	a0,a0,a5
    n |= n >> 4;  
ffffffffc0200e8a:	00455793          	srli	a5,a0,0x4
ffffffffc0200e8e:	8fc9                	or	a5,a5,a0
    n |= n >> 8;  
ffffffffc0200e90:	0087d513          	srli	a0,a5,0x8
ffffffffc0200e94:	8fc9                	or	a5,a5,a0
    n |= n >> 16;
ffffffffc0200e96:	0107d513          	srli	a0,a5,0x10
ffffffffc0200e9a:	8d5d                	or	a0,a0,a5
    n |= n >> 32;  
ffffffffc0200e9c:	02055793          	srli	a5,a0,0x20
ffffffffc0200ea0:	8d5d                	or	a0,a0,a5
}
ffffffffc0200ea2:	0505                	addi	a0,a0,1
ffffffffc0200ea4:	8082                	ret
{
ffffffffc0200ea6:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200ea8:	00004697          	auipc	a3,0x4
ffffffffc0200eac:	65868693          	addi	a3,a3,1624 # ffffffffc0205500 <commands+0xa00>
ffffffffc0200eb0:	00004617          	auipc	a2,0x4
ffffffffc0200eb4:	44060613          	addi	a2,a2,1088 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0200eb8:	04200593          	li	a1,66
ffffffffc0200ebc:	00004517          	auipc	a0,0x4
ffffffffc0200ec0:	44c50513          	addi	a0,a0,1100 # ffffffffc0205308 <commands+0x808>
{
ffffffffc0200ec4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200ec6:	d80ff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0200eca <buddy_system_free_pages>:
{
ffffffffc0200eca:	1141                	addi	sp,sp,-16
ffffffffc0200ecc:	e406                	sd	ra,8(sp)
ffffffffc0200ece:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc0200ed0:	10058963          	beqz	a1,ffffffffc0200fe2 <buddy_system_free_pages+0x118>
ffffffffc0200ed4:	842a                	mv	s0,a0
ffffffffc0200ed6:	852e                	mv	a0,a1
    n = up_to_2_power(n);
ffffffffc0200ed8:	fa3ff0ef          	jal	ra,ffffffffc0200e7a <up_to_2_power>
    for (; p != base + n; p ++) 
ffffffffc0200edc:	00651693          	slli	a3,a0,0x6
ffffffffc0200ee0:	96a2                	add	a3,a3,s0
ffffffffc0200ee2:	87a2                	mv	a5,s0
ffffffffc0200ee4:	02d40063          	beq	s0,a3,ffffffffc0200f04 <buddy_system_free_pages+0x3a>
ffffffffc0200ee8:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200eea:	8b05                	andi	a4,a4,1
ffffffffc0200eec:	eb79                	bnez	a4,ffffffffc0200fc2 <buddy_system_free_pages+0xf8>
ffffffffc0200eee:	6798                	ld	a4,8(a5)
ffffffffc0200ef0:	8b09                	andi	a4,a4,2
ffffffffc0200ef2:	eb61                	bnez	a4,ffffffffc0200fc2 <buddy_system_free_pages+0xf8>
        p->flags = 0;
ffffffffc0200ef4:	0007b423          	sd	zero,8(a5) # 4008 <kern_entry-0xffffffffc01fbff8>
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0200ef8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) 
ffffffffc0200efc:	04078793          	addi	a5,a5,64
ffffffffc0200f00:	fed794e3          	bne	a5,a3,ffffffffc0200ee8 <buddy_system_free_pages+0x1e>
    nr_free += n;
ffffffffc0200f04:	00010897          	auipc	a7,0x10
ffffffffc0200f08:	54488893          	addi	a7,a7,1348 # ffffffffc0211448 <free_area>
    size_t offset = base-Base;
ffffffffc0200f0c:	0008b783          	ld	a5,0(a7)
    size_t i = (offset+max_size)/n-1;
ffffffffc0200f10:	0188e703          	lwu	a4,24(a7)
    nr_free += n;
ffffffffc0200f14:	0108a683          	lw	a3,16(a7)
    size_t offset = base-Base;
ffffffffc0200f18:	40f407b3          	sub	a5,s0,a5
ffffffffc0200f1c:	8799                	srai	a5,a5,0x6
    size_t i = (offset+max_size)/n-1;
ffffffffc0200f1e:	97ba                	add	a5,a5,a4
ffffffffc0200f20:	02a7d7b3          	divu	a5,a5,a0
    free_tree[i]= n;
ffffffffc0200f24:	0088b703          	ld	a4,8(a7)
    nr_free += n;
ffffffffc0200f28:	9ea9                	addw	a3,a3,a0
ffffffffc0200f2a:	00d8a823          	sw	a3,16(a7)
    size_t i = (offset+max_size)/n-1;
ffffffffc0200f2e:	17fd                	addi	a5,a5,-1
    free_tree[i]= n;
ffffffffc0200f30:	00379693          	slli	a3,a5,0x3
ffffffffc0200f34:	9736                	add	a4,a4,a3
ffffffffc0200f36:	e308                	sd	a0,0(a4)
    base->property = n;
ffffffffc0200f38:	c808                	sw	a0,16(s0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200f3a:	4709                	li	a4,2
ffffffffc0200f3c:	00840693          	addi	a3,s0,8
ffffffffc0200f40:	40e6b02f          	amoor.d	zero,a4,(a3)
ffffffffc0200f44:	4e09                	li	t3,2
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200f46:	5375                	li	t1,-3
    while(i!=0)
ffffffffc0200f48:	cb8d                	beqz	a5,ffffffffc0200f7a <buddy_system_free_pages+0xb0>
        if( free_tree[(i<<1)+1]==size && free_tree[(i<<1)+2]==size ) //如果当前节点的左右子节点对应的内存块均完整，则合并它们
ffffffffc0200f4a:	0088b603          	ld	a2,8(a7)
        i = (i-1)>>1;
ffffffffc0200f4e:	17fd                	addi	a5,a5,-1
ffffffffc0200f50:	8385                	srli	a5,a5,0x1
        if( free_tree[(i<<1)+1]==size && free_tree[(i<<1)+2]==size ) //如果当前节点的左右子节点对应的内存块均完整，则合并它们
ffffffffc0200f52:	00479693          	slli	a3,a5,0x4
ffffffffc0200f56:	96b2                	add	a3,a3,a2
ffffffffc0200f58:	6698                	ld	a4,8(a3)
            free_tree[i] = 2*size;
ffffffffc0200f5a:	00379813          	slli	a6,a5,0x3
        if( free_tree[(i<<1)+1]==size && free_tree[(i<<1)+2]==size ) //如果当前节点的左右子节点对应的内存块均完整，则合并它们
ffffffffc0200f5e:	6a94                	ld	a3,16(a3)
ffffffffc0200f60:	00178593          	addi	a1,a5,1
            free_tree[i] = 2*size;
ffffffffc0200f64:	9642                	add	a2,a2,a6
        if( free_tree[(i<<1)+1]==size && free_tree[(i<<1)+2]==size ) //如果当前节点的左右子节点对应的内存块均完整，则合并它们
ffffffffc0200f66:	00a70e63          	beq	a4,a0,ffffffffc0200f82 <buddy_system_free_pages+0xb8>
        else free_tree[i]=max(free_tree[(i<<1)+1],free_tree[(i<<1)+2]);
ffffffffc0200f6a:	00d77363          	bgeu	a4,a3,ffffffffc0200f70 <buddy_system_free_pages+0xa6>
ffffffffc0200f6e:	8736                	mv	a4,a3
ffffffffc0200f70:	e218                	sd	a4,0(a2)
ffffffffc0200f72:	00151713          	slli	a4,a0,0x1
        size = size<<1;
ffffffffc0200f76:	853a                	mv	a0,a4
    while(i!=0)
ffffffffc0200f78:	fbe9                	bnez	a5,ffffffffc0200f4a <buddy_system_free_pages+0x80>
}
ffffffffc0200f7a:	60a2                	ld	ra,8(sp)
ffffffffc0200f7c:	6402                	ld	s0,0(sp)
ffffffffc0200f7e:	0141                	addi	sp,sp,16
ffffffffc0200f80:	8082                	ret
        if( free_tree[(i<<1)+1]==size && free_tree[(i<<1)+2]==size ) //如果当前节点的左右子节点对应的内存块均完整，则合并它们
ffffffffc0200f82:	fed514e3          	bne	a0,a3,ffffffffc0200f6a <buddy_system_free_pages+0xa0>
            offset = 2*size*(i+1)-max_size;
ffffffffc0200f86:	02b506b3          	mul	a3,a0,a1
ffffffffc0200f8a:	0188e803          	lwu	a6,24(a7)
            struct Page* Left  = Base+offset;
ffffffffc0200f8e:	0008b583          	ld	a1,0(a7)
            free_tree[i] = 2*size;
ffffffffc0200f92:	00151713          	slli	a4,a0,0x1
ffffffffc0200f96:	e218                	sd	a4,0(a2)
            struct Page* Right = Left+size;
ffffffffc0200f98:	00651613          	slli	a2,a0,0x6
            Left->property  = 2*size;
ffffffffc0200f9c:	0015151b          	slliw	a0,a0,0x1
            offset = 2*size*(i+1)-max_size;
ffffffffc0200fa0:	0686                	slli	a3,a3,0x1
ffffffffc0200fa2:	410686b3          	sub	a3,a3,a6
            struct Page* Left  = Base+offset;
ffffffffc0200fa6:	069a                	slli	a3,a3,0x6
ffffffffc0200fa8:	96ae                	add	a3,a3,a1
            struct Page* Right = Left+size;
ffffffffc0200faa:	9636                	add	a2,a2,a3
            Left->property  = 2*size;
ffffffffc0200fac:	ca88                	sw	a0,16(a3)
            Right->property = 0;
ffffffffc0200fae:	00062823          	sw	zero,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200fb2:	06a1                	addi	a3,a3,8
ffffffffc0200fb4:	41c6b02f          	amoor.d	zero,t3,(a3)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200fb8:	00860693          	addi	a3,a2,8
ffffffffc0200fbc:	6066b02f          	amoand.d	zero,t1,(a3)
}
ffffffffc0200fc0:	bf5d                	j	ffffffffc0200f76 <buddy_system_free_pages+0xac>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200fc2:	00004697          	auipc	a3,0x4
ffffffffc0200fc6:	54668693          	addi	a3,a3,1350 # ffffffffc0205508 <commands+0xa08>
ffffffffc0200fca:	00004617          	auipc	a2,0x4
ffffffffc0200fce:	32660613          	addi	a2,a2,806 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0200fd2:	0d600593          	li	a1,214
ffffffffc0200fd6:	00004517          	auipc	a0,0x4
ffffffffc0200fda:	33250513          	addi	a0,a0,818 # ffffffffc0205308 <commands+0x808>
ffffffffc0200fde:	c68ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(n > 0);
ffffffffc0200fe2:	00004697          	auipc	a3,0x4
ffffffffc0200fe6:	51e68693          	addi	a3,a3,1310 # ffffffffc0205500 <commands+0xa00>
ffffffffc0200fea:	00004617          	auipc	a2,0x4
ffffffffc0200fee:	30660613          	addi	a2,a2,774 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0200ff2:	0cf00593          	li	a1,207
ffffffffc0200ff6:	00004517          	auipc	a0,0x4
ffffffffc0200ffa:	31250513          	addi	a0,a0,786 # ffffffffc0205308 <commands+0x808>
ffffffffc0200ffe:	c48ff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201002 <buddy_system_alloc_pages>:
{
ffffffffc0201002:	1101                	addi	sp,sp,-32
ffffffffc0201004:	ec06                	sd	ra,24(sp)
ffffffffc0201006:	e822                	sd	s0,16(sp)
ffffffffc0201008:	e426                	sd	s1,8(sp)
ffffffffc020100a:	e04a                	sd	s2,0(sp)
    assert(n > 0);
ffffffffc020100c:	14050863          	beqz	a0,ffffffffc020115c <buddy_system_alloc_pages+0x15a>
    if (n > nr_free)  return NULL;
ffffffffc0201010:	00010417          	auipc	s0,0x10
ffffffffc0201014:	43840413          	addi	s0,s0,1080 # ffffffffc0211448 <free_area>
ffffffffc0201018:	01042903          	lw	s2,16(s0)
ffffffffc020101c:	4481                	li	s1,0
ffffffffc020101e:	02091713          	slli	a4,s2,0x20
ffffffffc0201022:	9301                	srli	a4,a4,0x20
ffffffffc0201024:	10a76563          	bltu	a4,a0,ffffffffc020112e <buddy_system_alloc_pages+0x12c>
    n = up_to_2_power(n);
ffffffffc0201028:	e53ff0ef          	jal	ra,ffffffffc0200e7a <up_to_2_power>
    if( n>free_tree[0] ) return NULL;
ffffffffc020102c:	00843303          	ld	t1,8(s0)
ffffffffc0201030:	00033783          	ld	a5,0(t1)
ffffffffc0201034:	0ea7ed63          	bltu	a5,a0,ffffffffc020112e <buddy_system_alloc_pages+0x12c>
    size_t i = 0,size = max_size,offset = 0;
ffffffffc0201038:	4c1c                	lw	a5,24(s0)
    while ( (((i<<1)+1)<(max_size+true_size-1) && free_tree[(i<<1)+1]>=n) || (((i<<1)+2)<(max_size+true_size-1) && free_tree[(i<<1)+2]>=n) ) 
ffffffffc020103a:	01442803          	lw	a6,20(s0)
    nr_free -= n;
ffffffffc020103e:	40a9093b          	subw	s2,s2,a0
    size_t i = 0,size = max_size,offset = 0;
ffffffffc0201042:	02079e93          	slli	t4,a5,0x20
    while ( (((i<<1)+1)<(max_size+true_size-1) && free_tree[(i<<1)+1]>=n) || (((i<<1)+2)<(max_size+true_size-1) && free_tree[(i<<1)+2]>=n) ) 
ffffffffc0201046:	00f8083b          	addw	a6,a6,a5
ffffffffc020104a:	387d                	addiw	a6,a6,-1
    size_t i = 0,size = max_size,offset = 0;
ffffffffc020104c:	020ede93          	srli	t4,t4,0x20
    while ( (((i<<1)+1)<(max_size+true_size-1) && free_tree[(i<<1)+1]>=n) || (((i<<1)+2)<(max_size+true_size-1) && free_tree[(i<<1)+2]>=n) ) 
ffffffffc0201050:	1802                	slli	a6,a6,0x20
    nr_free -= n;
ffffffffc0201052:	01242823          	sw	s2,16(s0)
    while ( (((i<<1)+1)<(max_size+true_size-1) && free_tree[(i<<1)+1]>=n) || (((i<<1)+2)<(max_size+true_size-1) && free_tree[(i<<1)+2]>=n) ) 
ffffffffc0201056:	02085813          	srli	a6,a6,0x20
    size_t i = 0,size = max_size,offset = 0;
ffffffffc020105a:	86f6                	mv	a3,t4
ffffffffc020105c:	4781                	li	a5,0
    while ( (((i<<1)+1)<(max_size+true_size-1) && free_tree[(i<<1)+1]>=n) || (((i<<1)+2)<(max_size+true_size-1) && free_tree[(i<<1)+2]>=n) ) 
ffffffffc020105e:	a839                	j	ffffffffc020107c <buddy_system_alloc_pages+0x7a>
ffffffffc0201060:	00489613          	slli	a2,a7,0x4
ffffffffc0201064:	961a                	add	a2,a2,t1
ffffffffc0201066:	00063e03          	ld	t3,0(a2)
ffffffffc020106a:	02ae6a63          	bltu	t3,a0,ffffffffc020109e <buddy_system_alloc_pages+0x9c>
        if(free_tree[(i<<1)+1]>=n) i = (i<<1)+1;
ffffffffc020106e:	ff863783          	ld	a5,-8(a2)
ffffffffc0201072:	00a7f363          	bgeu	a5,a0,ffffffffc0201078 <buddy_system_alloc_pages+0x76>
ffffffffc0201076:	85ba                	mv	a1,a4
        size = size>>1;
ffffffffc0201078:	8285                	srli	a3,a3,0x1
ffffffffc020107a:	87ae                	mv	a5,a1
    while ( (((i<<1)+1)<(max_size+true_size-1) && free_tree[(i<<1)+1]>=n) || (((i<<1)+2)<(max_size+true_size-1) && free_tree[(i<<1)+2]>=n) ) 
ffffffffc020107c:	00179713          	slli	a4,a5,0x1
ffffffffc0201080:	00170593          	addi	a1,a4,1
ffffffffc0201084:	0105f863          	bgeu	a1,a6,ffffffffc0201094 <buddy_system_alloc_pages+0x92>
ffffffffc0201088:	00479613          	slli	a2,a5,0x4
ffffffffc020108c:	961a                	add	a2,a2,t1
ffffffffc020108e:	6610                	ld	a2,8(a2)
ffffffffc0201090:	fea674e3          	bgeu	a2,a0,ffffffffc0201078 <buddy_system_alloc_pages+0x76>
ffffffffc0201094:	0709                	addi	a4,a4,2
ffffffffc0201096:	00178893          	addi	a7,a5,1
ffffffffc020109a:	fd0763e3          	bltu	a4,a6,ffffffffc0201060 <buddy_system_alloc_pages+0x5e>
    offset = (i + 1) * size - max_size;
ffffffffc020109e:	03168733          	mul	a4,a3,a7
    page = Base+offset;
ffffffffc02010a2:	6010                	ld	a2,0(s0)
    free_tree[i] = 0;
ffffffffc02010a4:	00379593          	slli	a1,a5,0x3
ffffffffc02010a8:	932e                	add	t1,t1,a1
ffffffffc02010aa:	00033023          	sd	zero,0(t1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02010ae:	55f5                	li	a1,-3
    offset = (i + 1) * size - max_size;
ffffffffc02010b0:	41d70733          	sub	a4,a4,t4
    page = Base+offset;
ffffffffc02010b4:	00671493          	slli	s1,a4,0x6
ffffffffc02010b8:	94b2                	add	s1,s1,a2
    page->property = 0;
ffffffffc02010ba:	0004a823          	sw	zero,16(s1)
ffffffffc02010be:	00848513          	addi	a0,s1,8
ffffffffc02010c2:	60b5302f          	amoand.d	zero,a1,(a0)
    if( i%2==1 && free_tree[i+1]==size) 
ffffffffc02010c6:	0017f593          	andi	a1,a5,1
ffffffffc02010ca:	e9ad                	bnez	a1,ffffffffc020113c <buddy_system_alloc_pages+0x13a>
    while (i!=0)
ffffffffc02010cc:	c3ad                	beqz	a5,ffffffffc020112e <buddy_system_alloc_pages+0x12c>
        free_tree[i]=max(free_tree[(i<<1)+1],free_tree[(i<<1)+2]); //树上操作:更新祖宗节点的值
ffffffffc02010ce:	6408                	ld	a0,8(s0)
        offset = (i + 1) * size - max_size;        
ffffffffc02010d0:	01842803          	lw	a6,24(s0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02010d4:	4889                	li	a7,2
        i = (i-1)>>1;
ffffffffc02010d6:	17fd                	addi	a5,a5,-1
ffffffffc02010d8:	8385                	srli	a5,a5,0x1
        offset = (i + 1) * size - max_size;        
ffffffffc02010da:	00178713          	addi	a4,a5,1
        free_tree[i]=max(free_tree[(i<<1)+1],free_tree[(i<<1)+2]); //树上操作:更新祖宗节点的值
ffffffffc02010de:	0712                	slli	a4,a4,0x4
ffffffffc02010e0:	972a                	add	a4,a4,a0
ffffffffc02010e2:	630c                	ld	a1,0(a4)
ffffffffc02010e4:	ff873603          	ld	a2,-8(a4)
ffffffffc02010e8:	00379713          	slli	a4,a5,0x3
        size = size<<1;
ffffffffc02010ec:	0686                	slli	a3,a3,0x1
        free_tree[i]=max(free_tree[(i<<1)+1],free_tree[(i<<1)+2]); //树上操作:更新祖宗节点的值
ffffffffc02010ee:	972a                	add	a4,a4,a0
ffffffffc02010f0:	00b67363          	bgeu	a2,a1,ffffffffc02010f6 <buddy_system_alloc_pages+0xf4>
ffffffffc02010f4:	862e                	mv	a2,a1
ffffffffc02010f6:	e310                	sd	a2,0(a4)
        if( i%2==1 && free_tree[i+1]==size) 
ffffffffc02010f8:	0017f613          	andi	a2,a5,1
ffffffffc02010fc:	ca05                	beqz	a2,ffffffffc020112c <buddy_system_alloc_pages+0x12a>
ffffffffc02010fe:	6710                	ld	a2,8(a4)
ffffffffc0201100:	fcd61be3          	bne	a2,a3,ffffffffc02010d6 <buddy_system_alloc_pages+0xd4>
            struct Page* right = Base+offset+size;
ffffffffc0201104:	00278713          	addi	a4,a5,2
ffffffffc0201108:	02d70733          	mul	a4,a4,a3
        offset = (i + 1) * size - max_size;        
ffffffffc020110c:	1802                	slli	a6,a6,0x20
            struct Page* right = Base+offset+size;
ffffffffc020110e:	6010                	ld	a2,0(s0)
        offset = (i + 1) * size - max_size;        
ffffffffc0201110:	02085813          	srli	a6,a6,0x20
            struct Page* right = Base+offset+size;
ffffffffc0201114:	41070733          	sub	a4,a4,a6
ffffffffc0201118:	071a                	slli	a4,a4,0x6
ffffffffc020111a:	9732                	add	a4,a4,a2
            right->property = size;
ffffffffc020111c:	cb14                	sw	a3,16(a4)
ffffffffc020111e:	0721                	addi	a4,a4,8
ffffffffc0201120:	4117302f          	amoor.d	zero,a7,(a4)
        offset = (i + 1) * size - max_size;        
ffffffffc0201124:	01842803          	lw	a6,24(s0)
        free_tree[i]=max(free_tree[(i<<1)+1],free_tree[(i<<1)+2]); //树上操作:更新祖宗节点的值
ffffffffc0201128:	6408                	ld	a0,8(s0)
}
ffffffffc020112a:	b775                	j	ffffffffc02010d6 <buddy_system_alloc_pages+0xd4>
    while (i!=0)
ffffffffc020112c:	f7cd                	bnez	a5,ffffffffc02010d6 <buddy_system_alloc_pages+0xd4>
}
ffffffffc020112e:	60e2                	ld	ra,24(sp)
ffffffffc0201130:	6442                	ld	s0,16(sp)
ffffffffc0201132:	6902                	ld	s2,0(sp)
ffffffffc0201134:	8526                	mv	a0,s1
ffffffffc0201136:	64a2                	ld	s1,8(sp)
ffffffffc0201138:	6105                	addi	sp,sp,32
ffffffffc020113a:	8082                	ret
    if( i%2==1 && free_tree[i+1]==size) 
ffffffffc020113c:	6408                	ld	a0,8(s0)
ffffffffc020113e:	088e                	slli	a7,a7,0x3
ffffffffc0201140:	98aa                	add	a7,a7,a0
ffffffffc0201142:	0008b583          	ld	a1,0(a7)
ffffffffc0201146:	f8d595e3          	bne	a1,a3,ffffffffc02010d0 <buddy_system_alloc_pages+0xce>
        struct Page* right = Base+offset+size;
ffffffffc020114a:	9736                	add	a4,a4,a3
ffffffffc020114c:	071a                	slli	a4,a4,0x6
ffffffffc020114e:	9732                	add	a4,a4,a2
        right->property = size;
ffffffffc0201150:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201152:	4609                	li	a2,2
ffffffffc0201154:	0721                	addi	a4,a4,8
ffffffffc0201156:	40c7302f          	amoor.d	zero,a2,(a4)
}
ffffffffc020115a:	bf9d                	j	ffffffffc02010d0 <buddy_system_alloc_pages+0xce>
    assert(n > 0);
ffffffffc020115c:	00004697          	auipc	a3,0x4
ffffffffc0201160:	3a468693          	addi	a3,a3,932 # ffffffffc0205500 <commands+0xa00>
ffffffffc0201164:	00004617          	auipc	a2,0x4
ffffffffc0201168:	18c60613          	addi	a2,a2,396 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc020116c:	09400593          	li	a1,148
ffffffffc0201170:	00004517          	auipc	a0,0x4
ffffffffc0201174:	19850513          	addi	a0,a0,408 # ffffffffc0205308 <commands+0x808>
ffffffffc0201178:	aceff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020117c <buddy_system_init_memmap>:
{
ffffffffc020117c:	1101                	addi	sp,sp,-32
ffffffffc020117e:	ec06                	sd	ra,24(sp)
ffffffffc0201180:	e822                	sd	s0,16(sp)
ffffffffc0201182:	e426                	sd	s1,8(sp)
    assert(n > 0);
ffffffffc0201184:	12058863          	beqz	a1,ffffffffc02012b4 <buddy_system_init_memmap+0x138>
ffffffffc0201188:	842a                	mv	s0,a0
    size_t N = up_to_2_power(n); //将n向上变为2的幂，以便于buddy_system算法的实现
ffffffffc020118a:	852e                	mv	a0,a1
ffffffffc020118c:	84ae                	mv	s1,a1
ffffffffc020118e:	cedff0ef          	jal	ra,ffffffffc0200e7a <up_to_2_power>
    for (; p != base + n; p ++) 
ffffffffc0201192:	00649693          	slli	a3,s1,0x6
ffffffffc0201196:	96a2                	add	a3,a3,s0
ffffffffc0201198:	87a2                	mv	a5,s0
ffffffffc020119a:	00d40f63          	beq	s0,a3,ffffffffc02011b8 <buddy_system_init_memmap+0x3c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020119e:	6798                	ld	a4,8(a5)
        assert(PageReserved(p)); 
ffffffffc02011a0:	8b05                	andi	a4,a4,1
ffffffffc02011a2:	cb69                	beqz	a4,ffffffffc0201274 <buddy_system_init_memmap+0xf8>
        p->flags = 0;
ffffffffc02011a4:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc02011a8:	0007a823          	sw	zero,16(a5)
ffffffffc02011ac:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) 
ffffffffc02011b0:	04078793          	addi	a5,a5,64
ffffffffc02011b4:	fed795e3          	bne	a5,a3,ffffffffc020119e <buddy_system_init_memmap+0x22>
    Base = base;
ffffffffc02011b8:	00010797          	auipc	a5,0x10
ffffffffc02011bc:	29078793          	addi	a5,a5,656 # ffffffffc0211448 <free_area>
    assert(free_tree != NULL);
ffffffffc02011c0:	678c                	ld	a1,8(a5)
    nr_free = n;
ffffffffc02011c2:	0004881b          	sext.w	a6,s1
    Base = base;
ffffffffc02011c6:	e380                	sd	s0,0(a5)
    nr_free = n;
ffffffffc02011c8:	0107a823          	sw	a6,16(a5)
    true_size = n;
ffffffffc02011cc:	0107aa23          	sw	a6,20(a5)
    max_size = N;
ffffffffc02011d0:	cf88                	sw	a0,24(a5)
    assert(free_tree != NULL);
ffffffffc02011d2:	c1e9                	beqz	a1,ffffffffc0201294 <buddy_system_init_memmap+0x118>
    size_t i = 2*N-1; //最后一个再后一个
ffffffffc02011d4:	00151313          	slli	t1,a0,0x1
    while(i>N+n-1) free_tree[--i] = 0;
ffffffffc02011d8:	14fd                	addi	s1,s1,-1
    size_t i = 2*N-1; //最后一个再后一个
ffffffffc02011da:	fff30793          	addi	a5,t1,-1
    while(i>N+n-1) free_tree[--i] = 0;
ffffffffc02011de:	94aa                	add	s1,s1,a0
ffffffffc02011e0:	02f4f363          	bgeu	s1,a5,ffffffffc0201206 <buddy_system_init_memmap+0x8a>
ffffffffc02011e4:	00451713          	slli	a4,a0,0x4
ffffffffc02011e8:	00858693          	addi	a3,a1,8
ffffffffc02011ec:	00349893          	slli	a7,s1,0x3
ffffffffc02011f0:	972e                	add	a4,a4,a1
ffffffffc02011f2:	96c6                	add	a3,a3,a7
ffffffffc02011f4:	fe073823          	sd	zero,-16(a4)
ffffffffc02011f8:	1761                	addi	a4,a4,-8
ffffffffc02011fa:	fed71de3          	bne	a4,a3,ffffffffc02011f4 <buddy_system_init_memmap+0x78>
ffffffffc02011fe:	0485                	addi	s1,s1,1
ffffffffc0201200:	97a6                	add	a5,a5,s1
ffffffffc0201202:	406787b3          	sub	a5,a5,t1
    while(i>N-1)   free_tree[--i] = 1;
ffffffffc0201206:	fff50713          	addi	a4,a0,-1
ffffffffc020120a:	06f77363          	bgeu	a4,a5,ffffffffc0201270 <buddy_system_init_memmap+0xf4>
ffffffffc020120e:	00351613          	slli	a2,a0,0x3
ffffffffc0201212:	078e                	slli	a5,a5,0x3
ffffffffc0201214:	ff858693          	addi	a3,a1,-8
ffffffffc0201218:	96b2                	add	a3,a3,a2
ffffffffc020121a:	97ae                	add	a5,a5,a1
ffffffffc020121c:	4605                	li	a2,1
ffffffffc020121e:	fec7bc23          	sd	a2,-8(a5)
ffffffffc0201222:	17e1                	addi	a5,a5,-8
ffffffffc0201224:	fed79de3          	bne	a5,a3,ffffffffc020121e <buddy_system_init_memmap+0xa2>
    while(i>0)     
ffffffffc0201228:	c705                	beqz	a4,ffffffffc0201250 <buddy_system_init_memmap+0xd4>
ffffffffc020122a:	00471693          	slli	a3,a4,0x4
ffffffffc020122e:	070e                	slli	a4,a4,0x3
ffffffffc0201230:	96ae                	add	a3,a3,a1
ffffffffc0201232:	972e                	add	a4,a4,a1
        if( free_tree[(i<<1)+1]==free_tree[(i<<1)+2] ) free_tree[i] = free_tree[(i<<1)+1]+free_tree[(i<<1)+2];
ffffffffc0201234:	ff86b783          	ld	a5,-8(a3)
ffffffffc0201238:	6290                	ld	a2,0(a3)
ffffffffc020123a:	02c78763          	beq	a5,a2,ffffffffc0201268 <buddy_system_init_memmap+0xec>
        else free_tree[i]=max(free_tree[(i<<1)+1],free_tree[(i<<1)+2]);         
ffffffffc020123e:	00c7f363          	bgeu	a5,a2,ffffffffc0201244 <buddy_system_init_memmap+0xc8>
ffffffffc0201242:	87b2                	mv	a5,a2
ffffffffc0201244:	fef73c23          	sd	a5,-8(a4)
    while(i>0)     
ffffffffc0201248:	1761                	addi	a4,a4,-8
ffffffffc020124a:	16c1                	addi	a3,a3,-16
ffffffffc020124c:	fee594e3          	bne	a1,a4,ffffffffc0201234 <buddy_system_init_memmap+0xb8>
    base->property = n;
ffffffffc0201250:	01042823          	sw	a6,16(s0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201254:	4789                	li	a5,2
ffffffffc0201256:	00840713          	addi	a4,s0,8
ffffffffc020125a:	40f7302f          	amoor.d	zero,a5,(a4)
}
ffffffffc020125e:	60e2                	ld	ra,24(sp)
ffffffffc0201260:	6442                	ld	s0,16(sp)
ffffffffc0201262:	64a2                	ld	s1,8(sp)
ffffffffc0201264:	6105                	addi	sp,sp,32
ffffffffc0201266:	8082                	ret
        if( free_tree[(i<<1)+1]==free_tree[(i<<1)+2] ) free_tree[i] = free_tree[(i<<1)+1]+free_tree[(i<<1)+2];
ffffffffc0201268:	0786                	slli	a5,a5,0x1
ffffffffc020126a:	fef73c23          	sd	a5,-8(a4)
ffffffffc020126e:	bfe9                	j	ffffffffc0201248 <buddy_system_init_memmap+0xcc>
    while(i>N-1)   free_tree[--i] = 1;
ffffffffc0201270:	873e                	mv	a4,a5
ffffffffc0201272:	bf5d                	j	ffffffffc0201228 <buddy_system_init_memmap+0xac>
        assert(PageReserved(p)); 
ffffffffc0201274:	00004697          	auipc	a3,0x4
ffffffffc0201278:	2bc68693          	addi	a3,a3,700 # ffffffffc0205530 <commands+0xa30>
ffffffffc020127c:	00004617          	auipc	a2,0x4
ffffffffc0201280:	07460613          	addi	a2,a2,116 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0201284:	06b00593          	li	a1,107
ffffffffc0201288:	00004517          	auipc	a0,0x4
ffffffffc020128c:	08050513          	addi	a0,a0,128 # ffffffffc0205308 <commands+0x808>
ffffffffc0201290:	9b6ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(free_tree != NULL);
ffffffffc0201294:	00004697          	auipc	a3,0x4
ffffffffc0201298:	2ac68693          	addi	a3,a3,684 # ffffffffc0205540 <commands+0xa40>
ffffffffc020129c:	00004617          	auipc	a2,0x4
ffffffffc02012a0:	05460613          	addi	a2,a2,84 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02012a4:	07900593          	li	a1,121
ffffffffc02012a8:	00004517          	auipc	a0,0x4
ffffffffc02012ac:	06050513          	addi	a0,a0,96 # ffffffffc0205308 <commands+0x808>
ffffffffc02012b0:	996ff0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(n > 0);
ffffffffc02012b4:	00004697          	auipc	a3,0x4
ffffffffc02012b8:	24c68693          	addi	a3,a3,588 # ffffffffc0205500 <commands+0xa00>
ffffffffc02012bc:	00004617          	auipc	a2,0x4
ffffffffc02012c0:	03460613          	addi	a2,a2,52 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02012c4:	06300593          	li	a1,99
ffffffffc02012c8:	00004517          	auipc	a0,0x4
ffffffffc02012cc:	04050513          	addi	a0,a0,64 # ffffffffc0205308 <commands+0x808>
ffffffffc02012d0:	976ff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02012d4 <log2.part.0>:
/*
 * 功能:n=2^m次幂，求m
 * 参数：
 * @n:      2^m次幂(n>0)
 */
static size_t log2(size_t n) 
ffffffffc02012d4:	1141                	addi	sp,sp,-16
{
	assert(n > 0);
ffffffffc02012d6:	00004697          	auipc	a3,0x4
ffffffffc02012da:	22a68693          	addi	a3,a3,554 # ffffffffc0205500 <commands+0xa00>
ffffffffc02012de:	00004617          	auipc	a2,0x4
ffffffffc02012e2:	01260613          	addi	a2,a2,18 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02012e6:	1bc00593          	li	a1,444
ffffffffc02012ea:	00004517          	auipc	a0,0x4
ffffffffc02012ee:	2c650513          	addi	a0,a0,710 # ffffffffc02055b0 <buddy_system_pmm_manager+0x38>
static size_t log2(size_t n) 
ffffffffc02012f2:	e406                	sd	ra,8(sp)
	assert(n > 0);
ffffffffc02012f4:	952ff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02012f8 <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc02012f8:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02012fa:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc02012fc:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201300:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201302:	0bd000ef          	jal	ra,ffffffffc0201bbe <alloc_pages>
  if(!page) return NULL;
ffffffffc0201306:	c91d                	beqz	a0,ffffffffc020133c <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201308:	00014697          	auipc	a3,0x14
ffffffffc020130c:	3486b683          	ld	a3,840(a3) # ffffffffc0215650 <pages>
ffffffffc0201310:	8d15                	sub	a0,a0,a3
ffffffffc0201312:	8519                	srai	a0,a0,0x6
ffffffffc0201314:	00005697          	auipc	a3,0x5
ffffffffc0201318:	5bc6b683          	ld	a3,1468(a3) # ffffffffc02068d0 <nbase>
ffffffffc020131c:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc020131e:	00c51793          	slli	a5,a0,0xc
ffffffffc0201322:	83b1                	srli	a5,a5,0xc
ffffffffc0201324:	00014717          	auipc	a4,0x14
ffffffffc0201328:	32473703          	ld	a4,804(a4) # ffffffffc0215648 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc020132c:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc020132e:	00e7fa63          	bgeu	a5,a4,ffffffffc0201342 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201332:	00014697          	auipc	a3,0x14
ffffffffc0201336:	32e6b683          	ld	a3,814(a3) # ffffffffc0215660 <va_pa_offset>
ffffffffc020133a:	9536                	add	a0,a0,a3
}
ffffffffc020133c:	60a2                	ld	ra,8(sp)
ffffffffc020133e:	0141                	addi	sp,sp,16
ffffffffc0201340:	8082                	ret
ffffffffc0201342:	86aa                	mv	a3,a0
ffffffffc0201344:	00004617          	auipc	a2,0x4
ffffffffc0201348:	28460613          	addi	a2,a2,644 # ffffffffc02055c8 <buddy_system_pmm_manager+0x50>
ffffffffc020134c:	06900593          	li	a1,105
ffffffffc0201350:	00004517          	auipc	a0,0x4
ffffffffc0201354:	2a050513          	addi	a0,a0,672 # ffffffffc02055f0 <buddy_system_pmm_manager+0x78>
ffffffffc0201358:	8eeff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020135c <slub_alloc.constprop.0>:
 *		@size :请求分配的内存的大小(包括首部，因此>=16,且已规范为2^n）
 *		@gfp  :位掩码，用于表示内存分配的各种选项和限制(这里可能一般为0)
 *		@align:指定分配的内存块需要对齐的边界(这里可能一般为0)
 * 注意:暂时未考虑对齐问题(待改进)
 */
static void* slub_alloc(size_t size, gfp_t gfp, int align)
ffffffffc020135c:	7179                	addi	sp,sp,-48
ffffffffc020135e:	f406                	sd	ra,40(sp)
ffffffffc0201360:	f022                	sd	s0,32(sp)
ffffffffc0201362:	ec26                	sd	s1,24(sp)
ffffffffc0201364:	e84a                	sd	s2,16(sp)
{
	//cprintf("[调试信息]进入slub_alloc()\n");
	assert(size < PAGE_SIZE);
ffffffffc0201366:	6785                	lui	a5,0x1
ffffffffc0201368:	10f57e63          	bgeu	a0,a5,ffffffffc0201484 <slub_alloc.constprop.0+0x128>
    size_t m = -1;
ffffffffc020136c:	57fd                	li	a5,-1
	assert(n > 0);
ffffffffc020136e:	12050b63          	beqz	a0,ffffffffc02014a4 <slub_alloc.constprop.0+0x148>
		n=(n>>1);
ffffffffc0201372:	8105                	srli	a0,a0,0x1
		m++;
ffffffffc0201374:	0785                	addi	a5,a5,1
	while(n>0)
ffffffffc0201376:	fd75                	bnez	a0,ffffffffc0201372 <slub_alloc.constprop.0+0x16>
//----------------------------变量声明----------------------------
	slub_t* slub      = Slubs+(log2(size)-Slubs_min_order); // 获取对应的slub
ffffffffc0201378:	079a                	slli	a5,a5,0x6
ffffffffc020137a:	00010417          	auipc	s0,0x10
ffffffffc020137e:	f6e40413          	addi	s0,s0,-146 # ffffffffc02112e8 <ide+0x6ea0>
ffffffffc0201382:	943e                	add	s0,s0,a5
	size_t  slub_size = slub->size;					        // 当前slub管理的size大小	
ffffffffc0201384:	6004                	ld	s1,0(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201386:	100027f3          	csrr	a5,sstatus
ffffffffc020138a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020138c:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020138e:	ebad                	bnez	a5,ffffffffc0201400 <slub_alloc.constprop.0+0xa4>
	struct slub_cache_waiting*  wait = &(slub->wait);  		// slub内存管理器的等待缓冲区
	struct slub_cache_working*  work = &(slub->work);  		// slub内存管理器的工作缓冲区
//----------------------------上锁----------------------------
	spin_lock_irqsave(&slob_lock, flags);
//----------------------------工作缓冲区缺失----------------------------
	if(work->freelist == NULL)
ffffffffc0201390:	7c08                	ld	a0,56(s0)
ffffffffc0201392:	c529                	beqz	a0,ffffffffc02013dc <slub_alloc.constprop.0+0x80>
		}		
	}
//----------------------------工作缓冲区非空:获取空闲内存块(现在可以保证工作区非空)----------------------------
	assert(work->freelist != NULL);
	//cprintf("[调试信息]工作缓冲区非空\n");
	page = (object*)work->pages;   		// slub工作缓冲区的物理页
ffffffffc0201394:	781c                	ld	a5,48(s0)
	// 处理freelist链表的空闲内存块链表(围绕取下的cur空闲内存块节点)
	cur = work->freelist;
	work->freelist = work->freelist->state.next_free;
	// 处理连续物理页节点
	page->nfree--;
ffffffffc0201396:	6798                	ld	a4,8(a5)
	work->freelist = work->freelist->state.next_free;
ffffffffc0201398:	6114                	ld	a3,0(a0)
	page->nfree--;
ffffffffc020139a:	177d                	addi	a4,a4,-1
	work->freelist = work->freelist->state.next_free;
ffffffffc020139c:	fc14                	sd	a3,56(s0)
	page->nfree--;
ffffffffc020139e:	e798                	sd	a4,8(a5)
	page->first_free = work->freelist;  //可以考虑注释这一行，改为将page->nfree==0时直接设为NULL(因为没有维护的必要)	
ffffffffc02013a0:	eb94                	sd	a3,16(a5)
	// 处理取下的cur空闲内存块节点
	cur->state.size = slub_size; // 当内存块节点使用时，使用其state.size记录大小以便释放
ffffffffc02013a2:	e104                	sd	s1,0(a0)
//----------------------------连续物理页节点已满:将工作区物理页节点转移到等待缓冲区full链表----------------------------
	if(page->nfree==0) 
ffffffffc02013a4:	eb11                	bnez	a4,ffffffffc02013b8 <slub_alloc.constprop.0+0x5c>
	{
		//cprintf("[调试信息]连续物理页节点已满\n");
		//page->first_free = NULL;
		assert(work->freelist==NULL && page->first_free==NULL);
ffffffffc02013a6:	eed9                	bnez	a3,ffffffffc0201444 <slub_alloc.constprop.0+0xe8>
		// 处理连续物理页节点
		page->next_head = wait->full;
		// 处理等待缓冲区
		wait->nr_slabs++;
ffffffffc02013a8:	6c18                	ld	a4,24(s0)
		page->next_head = wait->full;
ffffffffc02013aa:	7414                	ld	a3,40(s0)
		wait->nr_slabs++;
ffffffffc02013ac:	0705                	addi	a4,a4,1
		page->next_head = wait->full;
ffffffffc02013ae:	ef94                	sd	a3,24(a5)
		wait->nr_slabs++;
ffffffffc02013b0:	ec18                	sd	a4,24(s0)
		wait->full = page;	
ffffffffc02013b2:	f41c                	sd	a5,40(s0)
		// 处理工作缓冲区
		work->pages    = NULL;
ffffffffc02013b4:	02043823          	sd	zero,48(s0)
    if (flag) {
ffffffffc02013b8:	00091863          	bnez	s2,ffffffffc02013c8 <slub_alloc.constprop.0+0x6c>
	}
//----------------------------解锁----------------------------
	spin_unlock_irqrestore(&slob_lock, flags);
	//cprintf("[调试信息]退出slub_alloc(),分配的内存地址为%x\n",cur);
	return cur;
}
ffffffffc02013bc:	70a2                	ld	ra,40(sp)
ffffffffc02013be:	7402                	ld	s0,32(sp)
ffffffffc02013c0:	64e2                	ld	s1,24(sp)
ffffffffc02013c2:	6942                	ld	s2,16(sp)
ffffffffc02013c4:	6145                	addi	sp,sp,48
ffffffffc02013c6:	8082                	ret
ffffffffc02013c8:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02013ca:	9f2ff0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02013ce:	70a2                	ld	ra,40(sp)
ffffffffc02013d0:	7402                	ld	s0,32(sp)
ffffffffc02013d2:	6522                	ld	a0,8(sp)
ffffffffc02013d4:	64e2                	ld	s1,24(sp)
ffffffffc02013d6:	6942                	ld	s2,16(sp)
ffffffffc02013d8:	6145                	addi	sp,sp,48
ffffffffc02013da:	8082                	ret
		if(wait->nr_partial > 0)
ffffffffc02013dc:	6818                	ld	a4,16(s0)
ffffffffc02013de:	c70d                	beqz	a4,ffffffffc0201408 <slub_alloc.constprop.0+0xac>
			cur = wait->partial;
ffffffffc02013e0:	701c                	ld	a5,32(s0)
			wait->nr_slabs  --;
ffffffffc02013e2:	6c14                	ld	a3,24(s0)
			wait->nr_partial--;
ffffffffc02013e4:	177d                	addi	a4,a4,-1
			wait->partial  = cur->next_head;
ffffffffc02013e6:	6f90                	ld	a2,24(a5)
			work->freelist = cur->first_free;
ffffffffc02013e8:	6b88                	ld	a0,16(a5)
			wait->nr_slabs  --;
ffffffffc02013ea:	16fd                	addi	a3,a3,-1
			wait->partial  = cur->next_head;
ffffffffc02013ec:	f010                	sd	a2,32(s0)
			cur->next_head = NULL;
ffffffffc02013ee:	0007bc23          	sd	zero,24(a5) # 1018 <kern_entry-0xffffffffc01fefe8>
			wait->nr_partial--;
ffffffffc02013f2:	e818                	sd	a4,16(s0)
			wait->nr_slabs  --;
ffffffffc02013f4:	ec14                	sd	a3,24(s0)
			work->pages    = (void*)cur;
ffffffffc02013f6:	f81c                	sd	a5,48(s0)
			work->freelist = cur->first_free;
ffffffffc02013f8:	fc08                	sd	a0,56(s0)
	assert(work->freelist != NULL);
ffffffffc02013fa:	c52d                	beqz	a0,ffffffffc0201464 <slub_alloc.constprop.0+0x108>
	page->nfree--;
ffffffffc02013fc:	6798                	ld	a4,8(a5)
ffffffffc02013fe:	bf69                	j	ffffffffc0201398 <slub_alloc.constprop.0+0x3c>
        intr_disable();
ffffffffc0201400:	9c2ff0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        return 1;
ffffffffc0201404:	4905                	li	s2,1
ffffffffc0201406:	b769                	j	ffffffffc0201390 <slub_alloc.constprop.0+0x34>
			cur = (object *)__slob_get_free_page(gfp); // 分配一页内存(可以通用，和slob无关)
ffffffffc0201408:	4501                	li	a0,0
ffffffffc020140a:	eefff0ef          	jal	ra,ffffffffc02012f8 <__slob_get_free_pages.constprop.0>
			if (!cur) 
ffffffffc020140e:	d54d                	beqz	a0,ffffffffc02013b8 <slub_alloc.constprop.0+0x5c>
			for(void *prev = (void*)cur,*now = prev+slub_size,*finish = prev+PAGE_SIZE; now<finish ; prev = now,now += slub_size)
ffffffffc0201410:	6685                	lui	a3,0x1
ffffffffc0201412:	009507b3          	add	a5,a0,s1
ffffffffc0201416:	96aa                	add	a3,a3,a0
ffffffffc0201418:	872a                	mv	a4,a0
ffffffffc020141a:	00d7f763          	bgeu	a5,a3,ffffffffc0201428 <slub_alloc.constprop.0+0xcc>
				((object*)prev)->state.next_free = now;
ffffffffc020141e:	e31c                	sd	a5,0(a4)
			for(void *prev = (void*)cur,*now = prev+slub_size,*finish = prev+PAGE_SIZE; now<finish ; prev = now,now += slub_size)
ffffffffc0201420:	97a6                	add	a5,a5,s1
ffffffffc0201422:	9726                	add	a4,a4,s1
ffffffffc0201424:	fed7ede3          	bltu	a5,a3,ffffffffc020141e <slub_alloc.constprop.0+0xc2>
			((object*)(((void*)cur)+PAGE_SIZE-slub_size))->state.next_free = NULL;
ffffffffc0201428:	6785                	lui	a5,0x1
			cur->nfree      = PAGE_SIZE/slub_size;
ffffffffc020142a:	0297d733          	divu	a4,a5,s1
			((object*)(((void*)cur)+PAGE_SIZE-slub_size))->state.next_free = NULL;
ffffffffc020142e:	8f85                	sub	a5,a5,s1
ffffffffc0201430:	97aa                	add	a5,a5,a0
ffffffffc0201432:	0007b023          	sd	zero,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
			cur->next_head  = NULL;
ffffffffc0201436:	00053c23          	sd	zero,24(a0)
			cur->first_free = cur;
ffffffffc020143a:	e908                	sd	a0,16(a0)
			work->pages     = (void*)cur;
ffffffffc020143c:	87aa                	mv	a5,a0
			cur->nfree      = PAGE_SIZE/slub_size;
ffffffffc020143e:	e518                	sd	a4,8(a0)
			work->pages     = (void*)cur;
ffffffffc0201440:	f808                	sd	a0,48(s0)
			work->freelist  = cur;
ffffffffc0201442:	bf99                	j	ffffffffc0201398 <slub_alloc.constprop.0+0x3c>
		assert(work->freelist==NULL && page->first_free==NULL);
ffffffffc0201444:	00004697          	auipc	a3,0x4
ffffffffc0201448:	1ec68693          	addi	a3,a3,492 # ffffffffc0205630 <buddy_system_pmm_manager+0xb8>
ffffffffc020144c:	00004617          	auipc	a2,0x4
ffffffffc0201450:	ea460613          	addi	a2,a2,-348 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0201454:	21c00593          	li	a1,540
ffffffffc0201458:	00004517          	auipc	a0,0x4
ffffffffc020145c:	15850513          	addi	a0,a0,344 # ffffffffc02055b0 <buddy_system_pmm_manager+0x38>
ffffffffc0201460:	fe7fe0ef          	jal	ra,ffffffffc0200446 <__panic>
	assert(work->freelist != NULL);
ffffffffc0201464:	00004697          	auipc	a3,0x4
ffffffffc0201468:	1b468693          	addi	a3,a3,436 # ffffffffc0205618 <buddy_system_pmm_manager+0xa0>
ffffffffc020146c:	00004617          	auipc	a2,0x4
ffffffffc0201470:	e8460613          	addi	a2,a2,-380 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0201474:	20c00593          	li	a1,524
ffffffffc0201478:	00004517          	auipc	a0,0x4
ffffffffc020147c:	13850513          	addi	a0,a0,312 # ffffffffc02055b0 <buddy_system_pmm_manager+0x38>
ffffffffc0201480:	fc7fe0ef          	jal	ra,ffffffffc0200446 <__panic>
	assert(size < PAGE_SIZE);
ffffffffc0201484:	00004697          	auipc	a3,0x4
ffffffffc0201488:	17c68693          	addi	a3,a3,380 # ffffffffc0205600 <buddy_system_pmm_manager+0x88>
ffffffffc020148c:	00004617          	auipc	a2,0x4
ffffffffc0201490:	e6460613          	addi	a2,a2,-412 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0201494:	1d100593          	li	a1,465
ffffffffc0201498:	00004517          	auipc	a0,0x4
ffffffffc020149c:	11850513          	addi	a0,a0,280 # ffffffffc02055b0 <buddy_system_pmm_manager+0x38>
ffffffffc02014a0:	fa7fe0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02014a4:	e31ff0ef          	jal	ra,ffffffffc02012d4 <log2.part.0>

ffffffffc02014a8 <slub_free.part.0>:
 * 参数:
 * 		@block:slob单链表的节点
 *		@size :请求释放的内存的大小 
 * 注意:目前当一页为空时会被立即释放，可能影响效率（有待改进）
 */
static void slub_free(void* block, int size)
ffffffffc02014a8:	7139                	addi	sp,sp,-64
ffffffffc02014aa:	fc06                	sd	ra,56(sp)
ffffffffc02014ac:	f826                	sd	s1,48(sp)
ffffffffc02014ae:	f44a                	sd	s2,40(sp)
ffffffffc02014b0:	f04e                	sd	s3,32(sp)
ffffffffc02014b2:	ec52                	sd	s4,24(sp)
ffffffffc02014b4:	57fd                	li	a5,-1
	assert(n > 0);
ffffffffc02014b6:	1c058a63          	beqz	a1,ffffffffc020168a <slub_free.part.0+0x1e2>
		n=(n>>1);
ffffffffc02014ba:	8185                	srli	a1,a1,0x1
		m++;
ffffffffc02014bc:	0785                	addi	a5,a5,1
	while(n>0)
ffffffffc02014be:	fdf5                	bnez	a1,ffffffffc02014ba <slub_free.part.0+0x12>
{
	//cprintf("[调试信息]进入slub_free(),释放的内存地址为%x,请求释放的内存的大小为%d\n",block,size);
	if (!block) return;
//----------------------------变量声明----------------------------
	slub_t* slub      = Slubs+(log2(size)-Slubs_min_order);	// 获取对应的slub
ffffffffc02014c0:	079a                	slli	a5,a5,0x6
ffffffffc02014c2:	00010917          	auipc	s2,0x10
ffffffffc02014c6:	e2690913          	addi	s2,s2,-474 # ffffffffc02112e8 <ide+0x6ea0>
ffffffffc02014ca:	993e                	add	s2,s2,a5
	size_t slub_size                 = slub->size;			// 当前slub管理的size大小	
ffffffffc02014cc:	00093a03          	ld	s4,0(s2)
	object* b = (object *)block;							// 需要释放的object节点
	unsigned long flags = 0;								// 自旋锁参数
	struct slub_cache_waiting*  wait = &(slub->wait);	    // slub内存管理器的等待缓冲区
	struct slub_cache_working*  work = &(slub->work);       // slub内存管理器的工作缓冲区
	object* page                =(object*)work->pages;		// slub工作缓冲区的物理页
ffffffffc02014d0:	03093483          	ld	s1,48(s2)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02014d4:	10002773          	csrr	a4,sstatus
ffffffffc02014d8:	8b09                	andi	a4,a4,2
    return 0;
ffffffffc02014da:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02014dc:	ef5d                	bnez	a4,ffffffffc020159a <slub_free.part.0+0xf2>
//----------------------------上锁----------------------------
	spin_lock_irqsave(&slob_lock, flags);
//----------------------------尝试释放到工作缓冲区----------------------------
	//cprintf("[调试信息]尝试释放到工作缓冲区\n");
	if( page!=NULL && page<=block && block<(work->pages+PAGE_SIZE) ) 
ffffffffc02014de:	c099                	beqz	s1,ffffffffc02014e4 <slub_free.part.0+0x3c>
ffffffffc02014e0:	04957263          	bgeu	a0,s1,ffffffffc0201524 <slub_free.part.0+0x7c>
		spin_unlock_irqrestore(&slob_lock, flags);
		return;
	}
//----------------------------尝试释放到等待缓冲区的full链表----------------------------
	//cprintf("[调试信息]尝试释放到等待缓冲区的full链表\n");
	for(object *prev=NULL,*cur=wait->full;cur!=NULL;prev=cur,cur=cur->next_head)
ffffffffc02014e4:	02893783          	ld	a5,40(s2)
ffffffffc02014e8:	cf91                	beqz	a5,ffffffffc0201504 <slub_free.part.0+0x5c>
ffffffffc02014ea:	4681                	li	a3,0
	{
		if(cur<=block && block<(((void*)cur)+PAGE_SIZE))
ffffffffc02014ec:	6605                	lui	a2,0x1
ffffffffc02014ee:	00f56663          	bltu	a0,a5,ffffffffc02014fa <slub_free.part.0+0x52>
ffffffffc02014f2:	00c78733          	add	a4,a5,a2
ffffffffc02014f6:	06e56263          	bltu	a0,a4,ffffffffc020155a <slub_free.part.0+0xb2>
	for(object *prev=NULL,*cur=wait->full;cur!=NULL;prev=cur,cur=cur->next_head)
ffffffffc02014fa:	6f98                	ld	a4,24(a5)
ffffffffc02014fc:	86be                	mv	a3,a5
ffffffffc02014fe:	c319                	beqz	a4,ffffffffc0201504 <slub_free.part.0+0x5c>
ffffffffc0201500:	87ba                	mv	a5,a4
ffffffffc0201502:	b7f5                	j	ffffffffc02014ee <slub_free.part.0+0x46>
			return;
		}
	}
//----------------------------尝试释放到等待缓冲区的partial链表----------------------------
	//cprintf("[调试信息]尝试释放到等待缓冲区的partial链表\n");
	for(object *prev=NULL,*cur=wait->partial;cur!=NULL;prev=cur,cur=cur->next_head)
ffffffffc0201504:	02093683          	ld	a3,32(s2)
ffffffffc0201508:	c2a1                	beqz	a3,ffffffffc0201548 <slub_free.part.0+0xa0>
ffffffffc020150a:	4601                	li	a2,0
	{
		if(cur<=block && block<(((void*)cur)+PAGE_SIZE))
ffffffffc020150c:	6585                	lui	a1,0x1
ffffffffc020150e:	00d56663          	bltu	a0,a3,ffffffffc020151a <slub_free.part.0+0x72>
ffffffffc0201512:	00b68733          	add	a4,a3,a1
ffffffffc0201516:	08e56b63          	bltu	a0,a4,ffffffffc02015ac <slub_free.part.0+0x104>
	for(object *prev=NULL,*cur=wait->partial;cur!=NULL;prev=cur,cur=cur->next_head)
ffffffffc020151a:	6e98                	ld	a4,24(a3)
ffffffffc020151c:	8636                	mv	a2,a3
ffffffffc020151e:	c70d                	beqz	a4,ffffffffc0201548 <slub_free.part.0+0xa0>
ffffffffc0201520:	86ba                	mv	a3,a4
ffffffffc0201522:	b7f5                	j	ffffffffc020150e <slub_free.part.0+0x66>
	if( page!=NULL && page<=block && block<(work->pages+PAGE_SIZE) ) 
ffffffffc0201524:	03093783          	ld	a5,48(s2)
ffffffffc0201528:	6705                	lui	a4,0x1
ffffffffc020152a:	97ba                	add	a5,a5,a4
ffffffffc020152c:	faf57ce3          	bgeu	a0,a5,ffffffffc02014e4 <slub_free.part.0+0x3c>
		page->nfree++;
ffffffffc0201530:	649c                	ld	a5,8(s1)
		b->state.next_free = work->freelist;
ffffffffc0201532:	03893683          	ld	a3,56(s2)
		page->nfree++;
ffffffffc0201536:	0785                	addi	a5,a5,1
		if(page->nfree*slub_size==PAGE_SIZE)
ffffffffc0201538:	02fa0a33          	mul	s4,s4,a5
		b->state.next_free = work->freelist;
ffffffffc020153c:	e114                	sd	a3,0(a0)
		work->freelist = b;
ffffffffc020153e:	02a93c23          	sd	a0,56(s2)
		page->nfree++;
ffffffffc0201542:	e49c                	sd	a5,8(s1)
		if(page->nfree*slub_size==PAGE_SIZE)
ffffffffc0201544:	0cea0d63          	beq	s4,a4,ffffffffc020161e <slub_free.part.0+0x176>
    if (flag) {
ffffffffc0201548:	04099163          	bnez	s3,ffffffffc020158a <slub_free.part.0+0xe2>
		}
	}	
//----------------------------解锁(原则上不会到这，以防万一)----------------------------
	spin_unlock_irqrestore(&slob_lock, flags);
	return;
}
ffffffffc020154c:	70e2                	ld	ra,56(sp)
ffffffffc020154e:	74c2                	ld	s1,48(sp)
ffffffffc0201550:	7922                	ld	s2,40(sp)
ffffffffc0201552:	7982                	ld	s3,32(sp)
ffffffffc0201554:	6a62                	ld	s4,24(sp)
ffffffffc0201556:	6121                	addi	sp,sp,64
ffffffffc0201558:	8082                	ret
			assert(cur->first_free==NULL);
ffffffffc020155a:	6b98                	ld	a4,16(a5)
ffffffffc020155c:	12071963          	bnez	a4,ffffffffc020168e <slub_free.part.0+0x1e6>
			cur->nfree++;
ffffffffc0201560:	6790                	ld	a2,8(a5)
			wait->nr_partial++;
ffffffffc0201562:	01093703          	ld	a4,16(s2)
			b->state.next_free = cur->first_free;
ffffffffc0201566:	00053023          	sd	zero,0(a0)
			cur->nfree++;
ffffffffc020156a:	0605                	addi	a2,a2,1
			wait->nr_partial++;
ffffffffc020156c:	0705                	addi	a4,a4,1
			cur->first_free = b;
ffffffffc020156e:	eb88                	sd	a0,16(a5)
			cur->nfree++;
ffffffffc0201570:	e790                	sd	a2,8(a5)
			wait->nr_partial++;
ffffffffc0201572:	00e93823          	sd	a4,16(s2)
			if(prev==NULL) wait->full      = cur->next_head; //cur为第一个的情况
ffffffffc0201576:	6f98                	ld	a4,24(a5)
ffffffffc0201578:	c69d                	beqz	a3,ffffffffc02015a6 <slub_free.part.0+0xfe>
			else           prev->next_head = cur->next_head;
ffffffffc020157a:	ee98                	sd	a4,24(a3)
			cur->next_head = wait->partial;
ffffffffc020157c:	02093703          	ld	a4,32(s2)
ffffffffc0201580:	ef98                	sd	a4,24(a5)
			wait->partial  = cur;
ffffffffc0201582:	02f93023          	sd	a5,32(s2)
ffffffffc0201586:	fc0983e3          	beqz	s3,ffffffffc020154c <slub_free.part.0+0xa4>
}
ffffffffc020158a:	70e2                	ld	ra,56(sp)
ffffffffc020158c:	74c2                	ld	s1,48(sp)
ffffffffc020158e:	7922                	ld	s2,40(sp)
ffffffffc0201590:	7982                	ld	s3,32(sp)
ffffffffc0201592:	6a62                	ld	s4,24(sp)
ffffffffc0201594:	6121                	addi	sp,sp,64
        intr_enable();
ffffffffc0201596:	826ff06f          	j	ffffffffc02005bc <intr_enable>
ffffffffc020159a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020159c:	826ff0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        return 1;
ffffffffc02015a0:	6522                	ld	a0,8(sp)
ffffffffc02015a2:	4985                	li	s3,1
ffffffffc02015a4:	bf2d                	j	ffffffffc02014de <slub_free.part.0+0x36>
			if(prev==NULL) wait->full      = cur->next_head; //cur为第一个的情况
ffffffffc02015a6:	02e93423          	sd	a4,40(s2)
ffffffffc02015aa:	bfc9                	j	ffffffffc020157c <slub_free.part.0+0xd4>
			cur->nfree++;
ffffffffc02015ac:	669c                	ld	a5,8(a3)
			b->state.next_free = cur->first_free;
ffffffffc02015ae:	6a98                	ld	a4,16(a3)
			cur->nfree++;
ffffffffc02015b0:	0785                	addi	a5,a5,1
			if(cur->nfree*slub_size==PAGE_SIZE)
ffffffffc02015b2:	02fa0a33          	mul	s4,s4,a5
			b->state.next_free = cur->first_free;
ffffffffc02015b6:	e118                	sd	a4,0(a0)
			cur->first_free = b;
ffffffffc02015b8:	ea88                	sd	a0,16(a3)
			cur->nfree++;
ffffffffc02015ba:	e69c                	sd	a5,8(a3)
			if(cur->nfree*slub_size==PAGE_SIZE)
ffffffffc02015bc:	f8ba16e3          	bne	s4,a1,ffffffffc0201548 <slub_free.part.0+0xa0>
				if(prev==NULL) wait->partial   = cur->next_head; //cur为第一个的情况
ffffffffc02015c0:	6e9c                	ld	a5,24(a3)
ffffffffc02015c2:	c645                	beqz	a2,ffffffffc020166a <slub_free.part.0+0x1c2>
				else           prev->next_head = cur->next_head;
ffffffffc02015c4:	ee1c                	sd	a5,24(a2)
    return pa2page(PADDR(kva));
ffffffffc02015c6:	c02007b7          	lui	a5,0xc0200
ffffffffc02015ca:	0ef6ee63          	bltu	a3,a5,ffffffffc02016c6 <slub_free.part.0+0x21e>
ffffffffc02015ce:	00014797          	auipc	a5,0x14
ffffffffc02015d2:	0927b783          	ld	a5,146(a5) # ffffffffc0215660 <va_pa_offset>
ffffffffc02015d6:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02015da:	83b1                	srli	a5,a5,0xc
ffffffffc02015dc:	00014717          	auipc	a4,0x14
ffffffffc02015e0:	06c73703          	ld	a4,108(a4) # ffffffffc0215648 <npage>
ffffffffc02015e4:	0ce7f563          	bgeu	a5,a4,ffffffffc02016ae <slub_free.part.0+0x206>
    return &pages[PPN(pa) - nbase];
ffffffffc02015e8:	00005717          	auipc	a4,0x5
ffffffffc02015ec:	2e873703          	ld	a4,744(a4) # ffffffffc02068d0 <nbase>
ffffffffc02015f0:	8f99                	sub	a5,a5,a4
ffffffffc02015f2:	079a                	slli	a5,a5,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc02015f4:	00014517          	auipc	a0,0x14
ffffffffc02015f8:	05c53503          	ld	a0,92(a0) # ffffffffc0215650 <pages>
ffffffffc02015fc:	953e                	add	a0,a0,a5
ffffffffc02015fe:	4585                	li	a1,1
ffffffffc0201600:	650000ef          	jal	ra,ffffffffc0201c50 <free_pages>
				wait->nr_partial--;
ffffffffc0201604:	01093703          	ld	a4,16(s2)
				wait->nr_slabs  --;
ffffffffc0201608:	01893783          	ld	a5,24(s2)
				wait->nr_partial--;
ffffffffc020160c:	177d                	addi	a4,a4,-1
				wait->nr_slabs  --;
ffffffffc020160e:	17fd                	addi	a5,a5,-1
				wait->nr_partial--;
ffffffffc0201610:	00e93823          	sd	a4,16(s2)
				wait->nr_slabs  --;
ffffffffc0201614:	00f93c23          	sd	a5,24(s2)
    if (flag) {
ffffffffc0201618:	f2098ae3          	beqz	s3,ffffffffc020154c <slub_free.part.0+0xa4>
ffffffffc020161c:	b7bd                	j	ffffffffc020158a <slub_free.part.0+0xe2>
    return pa2page(PADDR(kva));
ffffffffc020161e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201622:	04f4e763          	bltu	s1,a5,ffffffffc0201670 <slub_free.part.0+0x1c8>
ffffffffc0201626:	00014717          	auipc	a4,0x14
ffffffffc020162a:	03a73703          	ld	a4,58(a4) # ffffffffc0215660 <va_pa_offset>
ffffffffc020162e:	40e48733          	sub	a4,s1,a4
    if (PPN(pa) >= npage) {
ffffffffc0201632:	8331                	srli	a4,a4,0xc
ffffffffc0201634:	00014797          	auipc	a5,0x14
ffffffffc0201638:	0147b783          	ld	a5,20(a5) # ffffffffc0215648 <npage>
ffffffffc020163c:	06f77963          	bgeu	a4,a5,ffffffffc02016ae <slub_free.part.0+0x206>
    return &pages[PPN(pa) - nbase];
ffffffffc0201640:	00005797          	auipc	a5,0x5
ffffffffc0201644:	2907b783          	ld	a5,656(a5) # ffffffffc02068d0 <nbase>
ffffffffc0201648:	8f1d                	sub	a4,a4,a5
ffffffffc020164a:	071a                	slli	a4,a4,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc020164c:	00014517          	auipc	a0,0x14
ffffffffc0201650:	00453503          	ld	a0,4(a0) # ffffffffc0215650 <pages>
ffffffffc0201654:	4585                	li	a1,1
ffffffffc0201656:	953a                	add	a0,a0,a4
ffffffffc0201658:	5f8000ef          	jal	ra,ffffffffc0201c50 <free_pages>
			work->freelist = NULL;
ffffffffc020165c:	02093c23          	sd	zero,56(s2)
			work->pages    = NULL;
ffffffffc0201660:	02093823          	sd	zero,48(s2)
ffffffffc0201664:	ee0984e3          	beqz	s3,ffffffffc020154c <slub_free.part.0+0xa4>
ffffffffc0201668:	b70d                	j	ffffffffc020158a <slub_free.part.0+0xe2>
				if(prev==NULL) wait->partial   = cur->next_head; //cur为第一个的情况
ffffffffc020166a:	02f93023          	sd	a5,32(s2)
ffffffffc020166e:	bfa1                	j	ffffffffc02015c6 <slub_free.part.0+0x11e>
    return pa2page(PADDR(kva));
ffffffffc0201670:	86a6                	mv	a3,s1
ffffffffc0201672:	00004617          	auipc	a2,0x4
ffffffffc0201676:	fee60613          	addi	a2,a2,-18 # ffffffffc0205660 <buddy_system_pmm_manager+0xe8>
ffffffffc020167a:	06e00593          	li	a1,110
ffffffffc020167e:	00004517          	auipc	a0,0x4
ffffffffc0201682:	f7250513          	addi	a0,a0,-142 # ffffffffc02055f0 <buddy_system_pmm_manager+0x78>
ffffffffc0201686:	dc1fe0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020168a:	c4bff0ef          	jal	ra,ffffffffc02012d4 <log2.part.0>
			assert(cur->first_free==NULL);
ffffffffc020168e:	00004697          	auipc	a3,0x4
ffffffffc0201692:	01a68693          	addi	a3,a3,26 # ffffffffc02056a8 <buddy_system_pmm_manager+0x130>
ffffffffc0201696:	00004617          	auipc	a2,0x4
ffffffffc020169a:	c5a60613          	addi	a2,a2,-934 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc020169e:	26100593          	li	a1,609
ffffffffc02016a2:	00004517          	auipc	a0,0x4
ffffffffc02016a6:	f0e50513          	addi	a0,a0,-242 # ffffffffc02055b0 <buddy_system_pmm_manager+0x38>
ffffffffc02016aa:	d9dfe0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02016ae:	00004617          	auipc	a2,0x4
ffffffffc02016b2:	fda60613          	addi	a2,a2,-38 # ffffffffc0205688 <buddy_system_pmm_manager+0x110>
ffffffffc02016b6:	06200593          	li	a1,98
ffffffffc02016ba:	00004517          	auipc	a0,0x4
ffffffffc02016be:	f3650513          	addi	a0,a0,-202 # ffffffffc02055f0 <buddy_system_pmm_manager+0x78>
ffffffffc02016c2:	d85fe0ef          	jal	ra,ffffffffc0200446 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02016c6:	00004617          	auipc	a2,0x4
ffffffffc02016ca:	f9a60613          	addi	a2,a2,-102 # ffffffffc0205660 <buddy_system_pmm_manager+0xe8>
ffffffffc02016ce:	06e00593          	li	a1,110
ffffffffc02016d2:	00004517          	auipc	a0,0x4
ffffffffc02016d6:	f1e50513          	addi	a0,a0,-226 # ffffffffc02055f0 <buddy_system_pmm_manager+0x78>
ffffffffc02016da:	d6dfe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02016de <__kmalloc.constprop.0>:
 * 功能:分配内存
 * 参数:
 *     @size:请求分配的内存的大小
 *     @gfp :位掩码，用于表示内存分配的各种选项和限制。(这里可能一般为0)
 */
static void *__kmalloc(size_t size, gfp_t gfp)
ffffffffc02016de:	7179                	addi	sp,sp,-48
ffffffffc02016e0:	f406                	sd	ra,40(sp)
ffffffffc02016e2:	f022                	sd	s0,32(sp)
ffffffffc02016e4:	ec26                	sd	s1,24(sp)
ffffffffc02016e6:	e84a                	sd	s2,16(sp)
ffffffffc02016e8:	e44e                	sd	s3,8(sp)
{
	if(size<=0) return NULL;
ffffffffc02016ea:	cd49                	beqz	a0,ffffffffc0201784 <__kmalloc.constprop.0+0xa6>
    assert(n > 0);
ffffffffc02016ec:	5781                	li	a5,-32
ffffffffc02016ee:	842a                	mv	s0,a0
ffffffffc02016f0:	0cf50d63          	beq	a0,a5,ffffffffc02017ca <__kmalloc.constprop.0+0xec>
    n--; 
ffffffffc02016f4:	057d                	addi	a0,a0,31
    n |= n >> 1;  
ffffffffc02016f6:	00155793          	srli	a5,a0,0x1
ffffffffc02016fa:	8d5d                	or	a0,a0,a5
    n |= n >> 2;  
ffffffffc02016fc:	00255793          	srli	a5,a0,0x2
ffffffffc0201700:	8d5d                	or	a0,a0,a5
    n |= n >> 4;  
ffffffffc0201702:	00455793          	srli	a5,a0,0x4
ffffffffc0201706:	8d5d                	or	a0,a0,a5
    n |= n >> 8;  
ffffffffc0201708:	00855793          	srli	a5,a0,0x8
ffffffffc020170c:	8d5d                	or	a0,a0,a5
    n |= n >> 16;
ffffffffc020170e:	01055793          	srli	a5,a0,0x10
ffffffffc0201712:	8d5d                	or	a0,a0,a5
    n |= n >> 32;  
ffffffffc0201714:	02055793          	srli	a5,a0,0x20
ffffffffc0201718:	8d5d                	or	a0,a0,a5
    n++;
ffffffffc020171a:	0505                	addi	a0,a0,1
		}		
	}
	if(USING_SLUB) 
	{
		size_t up_size = up_to_2_power(size+SLUB_UNIT);		// 向上取整后的大小(Byte)
		if (up_size < PAGE_SIZE) 							// 如果小于1页(包括头部)
ffffffffc020171c:	6905                	lui	s2,0x1
ffffffffc020171e:	05256e63          	bltu	a0,s2,ffffffffc020177a <__kmalloc.constprop.0+0x9c>
		if (!bb) return 0;
	}
	if(USING_SLUB) 	// 使用slub分配器分配一个单向链表节点(>=1页)
	{
		size_t up_size = up_to_2_power(sizeof(bigblock_t)+SLUB_UNIT);		// 向上取整后的大小(Byte)
		bb = slub_alloc(up_size, gfp, 0);
ffffffffc0201722:	04000513          	li	a0,64
ffffffffc0201726:	c37ff0ef          	jal	ra,ffffffffc020135c <slub_alloc.constprop.0>
ffffffffc020172a:	84aa                	mv	s1,a0
		if (!bb) return 0;
ffffffffc020172c:	cd21                	beqz	a0,ffffffffc0201784 <__kmalloc.constprop.0+0xa6>
		bb = (bigblock_t*)((void*)bb+SLUB_UNIT);
	}
	

	bb->order = find_order(size);
ffffffffc020172e:	0004079b          	sext.w	a5,s0
		bb = (bigblock_t*)((void*)bb+SLUB_UNIT);
ffffffffc0201732:	02050993          	addi	s3,a0,32
	int order = 0;
ffffffffc0201736:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201738:	00f95763          	bge	s2,a5,ffffffffc0201746 <__kmalloc.constprop.0+0x68>
ffffffffc020173c:	6705                	lui	a4,0x1
ffffffffc020173e:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201740:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201742:	fef74ee3          	blt	a4,a5,ffffffffc020173e <__kmalloc.constprop.0+0x60>
	bb->order = find_order(size);
ffffffffc0201746:	d088                	sw	a0,32(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201748:	bb1ff0ef          	jal	ra,ffffffffc02012f8 <__slob_get_free_pages.constprop.0>
ffffffffc020174c:	f488                	sd	a0,40(s1)
ffffffffc020174e:	842a                	mv	s0,a0

	if (bb->pages) 
ffffffffc0201750:	c925                	beqz	a0,ffffffffc02017c0 <__kmalloc.constprop.0+0xe2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201752:	100027f3          	csrr	a5,sstatus
ffffffffc0201756:	8b89                	andi	a5,a5,2
ffffffffc0201758:	ef9d                	bnez	a5,ffffffffc0201796 <__kmalloc.constprop.0+0xb8>
	{
		spin_lock_irqsave(&block_lock, flags);
		bb->next = bigblocks;
ffffffffc020175a:	00014797          	auipc	a5,0x14
ffffffffc020175e:	ed678793          	addi	a5,a5,-298 # ffffffffc0215630 <bigblocks>
ffffffffc0201762:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201764:	0137b023          	sd	s3,0(a5)
		bb->next = bigblocks;
ffffffffc0201768:	f898                	sd	a4,48(s1)
	if(USING_SLUB) 
	{
		slub_free((object *)bb - 1, (size_t)((object *)bb-1)->state.size); 
	}
	return 0;
}
ffffffffc020176a:	70a2                	ld	ra,40(sp)
ffffffffc020176c:	8522                	mv	a0,s0
ffffffffc020176e:	7402                	ld	s0,32(sp)
ffffffffc0201770:	64e2                	ld	s1,24(sp)
ffffffffc0201772:	6942                	ld	s2,16(sp)
ffffffffc0201774:	69a2                	ld	s3,8(sp)
ffffffffc0201776:	6145                	addi	sp,sp,48
ffffffffc0201778:	8082                	ret
			object* m = slub_alloc(up_size, gfp, 0); 				// 使用slub分配器分配内存
ffffffffc020177a:	be3ff0ef          	jal	ra,ffffffffc020135c <slub_alloc.constprop.0>
			return m ? (void *)(m + 1) : 0;					// 如果分配到了返回指针，否则返回NULL			
ffffffffc020177e:	02050413          	addi	s0,a0,32
ffffffffc0201782:	f565                	bnez	a0,ffffffffc020176a <__kmalloc.constprop.0+0x8c>
	if(size<=0) return NULL;
ffffffffc0201784:	4401                	li	s0,0
}
ffffffffc0201786:	70a2                	ld	ra,40(sp)
ffffffffc0201788:	8522                	mv	a0,s0
ffffffffc020178a:	7402                	ld	s0,32(sp)
ffffffffc020178c:	64e2                	ld	s1,24(sp)
ffffffffc020178e:	6942                	ld	s2,16(sp)
ffffffffc0201790:	69a2                	ld	s3,8(sp)
ffffffffc0201792:	6145                	addi	sp,sp,48
ffffffffc0201794:	8082                	ret
        intr_disable();
ffffffffc0201796:	e2dfe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
		bb->next = bigblocks;
ffffffffc020179a:	00014797          	auipc	a5,0x14
ffffffffc020179e:	e9678793          	addi	a5,a5,-362 # ffffffffc0215630 <bigblocks>
ffffffffc02017a2:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc02017a4:	0137b023          	sd	s3,0(a5)
		bb->next = bigblocks;
ffffffffc02017a8:	f898                	sd	a4,48(s1)
        intr_enable();
ffffffffc02017aa:	e13fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
		return bb->pages;
ffffffffc02017ae:	7480                	ld	s0,40(s1)
}
ffffffffc02017b0:	70a2                	ld	ra,40(sp)
ffffffffc02017b2:	64e2                	ld	s1,24(sp)
ffffffffc02017b4:	8522                	mv	a0,s0
ffffffffc02017b6:	7402                	ld	s0,32(sp)
ffffffffc02017b8:	6942                	ld	s2,16(sp)
ffffffffc02017ba:	69a2                	ld	s3,8(sp)
ffffffffc02017bc:	6145                	addi	sp,sp,48
ffffffffc02017be:	8082                	ret
	if (!block) return;
ffffffffc02017c0:	408c                	lw	a1,0(s1)
ffffffffc02017c2:	8526                	mv	a0,s1
ffffffffc02017c4:	ce5ff0ef          	jal	ra,ffffffffc02014a8 <slub_free.part.0>
	return 0;
ffffffffc02017c8:	b74d                	j	ffffffffc020176a <__kmalloc.constprop.0+0x8c>
    assert(n > 0);
ffffffffc02017ca:	00004697          	auipc	a3,0x4
ffffffffc02017ce:	d3668693          	addi	a3,a3,-714 # ffffffffc0205500 <commands+0xa00>
ffffffffc02017d2:	00004617          	auipc	a2,0x4
ffffffffc02017d6:	b1e60613          	addi	a2,a2,-1250 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02017da:	1a900593          	li	a1,425
ffffffffc02017de:	00004517          	auipc	a0,0x4
ffffffffc02017e2:	dd250513          	addi	a0,a0,-558 # ffffffffc02055b0 <buddy_system_pmm_manager+0x38>
ffffffffc02017e6:	c61fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02017ea <kmalloc>:
 *     @size:请求分配的内存的大小
 * 注意:这是分配内存对外的接口
 */
void* kmalloc(size_t size)
{
	return __kmalloc(size, 0);
ffffffffc02017ea:	bdd5                	j	ffffffffc02016de <__kmalloc.constprop.0>

ffffffffc02017ec <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block) return;
ffffffffc02017ec:	c179                	beqz	a0,ffffffffc02018b2 <kfree+0xc6>
{
ffffffffc02017ee:	1101                	addi	sp,sp,-32
ffffffffc02017f0:	e822                	sd	s0,16(sp)
ffffffffc02017f2:	ec06                	sd	ra,24(sp)
ffffffffc02017f4:	e426                	sd	s1,8(sp)

	if (!((unsigned long)block & (PAGE_SIZE-1))) // 如果是与页对齐的(即可能为按页分配的)
ffffffffc02017f6:	03451793          	slli	a5,a0,0x34
ffffffffc02017fa:	842a                	mv	s0,a0
ffffffffc02017fc:	e7c1                	bnez	a5,ffffffffc0201884 <kfree+0x98>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02017fe:	100027f3          	csrr	a5,sstatus
ffffffffc0201802:	8b89                	andi	a5,a5,2
ffffffffc0201804:	ebc9                	bnez	a5,ffffffffc0201896 <kfree+0xaa>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) // 遍历链表(似乎尾节点缺乏显示初始化为NULL)
ffffffffc0201806:	00014797          	auipc	a5,0x14
ffffffffc020180a:	e2a7b783          	ld	a5,-470(a5) # ffffffffc0215630 <bigblocks>
    return 0;
ffffffffc020180e:	4601                	li	a2,0
ffffffffc0201810:	cbb5                	beqz	a5,ffffffffc0201884 <kfree+0x98>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201812:	00014697          	auipc	a3,0x14
ffffffffc0201816:	e1e68693          	addi	a3,a3,-482 # ffffffffc0215630 <bigblocks>
ffffffffc020181a:	a021                	j	ffffffffc0201822 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) // 遍历链表(似乎尾节点缺乏显示初始化为NULL)
ffffffffc020181c:	01048693          	addi	a3,s1,16
ffffffffc0201820:	c3ad                	beqz	a5,ffffffffc0201882 <kfree+0x96>
		{
			if (bb->pages == block) // 如果在链表里
ffffffffc0201822:	6798                	ld	a4,8(a5)
ffffffffc0201824:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc0201826:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) // 如果在链表里
ffffffffc0201828:	fe871ae3          	bne	a4,s0,ffffffffc020181c <kfree+0x30>
				*last = bb->next;
ffffffffc020182c:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc020182e:	ee3d                	bnez	a2,ffffffffc02018ac <kfree+0xc0>
ffffffffc0201830:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201834:	4098                	lw	a4,0(s1)
ffffffffc0201836:	08f46b63          	bltu	s0,a5,ffffffffc02018cc <kfree+0xe0>
ffffffffc020183a:	00014697          	auipc	a3,0x14
ffffffffc020183e:	e266b683          	ld	a3,-474(a3) # ffffffffc0215660 <va_pa_offset>
ffffffffc0201842:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201844:	8031                	srli	s0,s0,0xc
ffffffffc0201846:	00014797          	auipc	a5,0x14
ffffffffc020184a:	e027b783          	ld	a5,-510(a5) # ffffffffc0215648 <npage>
ffffffffc020184e:	06f47363          	bgeu	s0,a5,ffffffffc02018b4 <kfree+0xc8>
    return &pages[PPN(pa) - nbase];
ffffffffc0201852:	00005517          	auipc	a0,0x5
ffffffffc0201856:	07e53503          	ld	a0,126(a0) # ffffffffc02068d0 <nbase>
ffffffffc020185a:	8c09                	sub	s0,s0,a0
ffffffffc020185c:	041a                	slli	s0,s0,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc020185e:	00014517          	auipc	a0,0x14
ffffffffc0201862:	df253503          	ld	a0,-526(a0) # ffffffffc0215650 <pages>
ffffffffc0201866:	4585                	li	a1,1
ffffffffc0201868:	9522                	add	a0,a0,s0
ffffffffc020186a:	00e595bb          	sllw	a1,a1,a4
ffffffffc020186e:	3e2000ef          	jal	ra,ffffffffc0201c50 <free_pages>
	
	// 释放小于1页的
    if(USING_SLOB) slob_free((slob_t *)block - 1, 0); 
	if(USING_SLUB) slub_free((object *)block - 1, (size_t)((object*)block-1)->state.size); 
	return;
}
ffffffffc0201872:	6442                	ld	s0,16(sp)
ffffffffc0201874:	fe04a583          	lw	a1,-32(s1)
ffffffffc0201878:	60e2                	ld	ra,24(sp)
ffffffffc020187a:	8526                	mv	a0,s1
ffffffffc020187c:	64a2                	ld	s1,8(sp)
ffffffffc020187e:	6105                	addi	sp,sp,32
ffffffffc0201880:	b125                	j	ffffffffc02014a8 <slub_free.part.0>
ffffffffc0201882:	e215                	bnez	a2,ffffffffc02018a6 <kfree+0xba>
	if (!block) return;
ffffffffc0201884:	fe042583          	lw	a1,-32(s0)
ffffffffc0201888:	fe040513          	addi	a0,s0,-32
}
ffffffffc020188c:	6442                	ld	s0,16(sp)
ffffffffc020188e:	60e2                	ld	ra,24(sp)
ffffffffc0201890:	64a2                	ld	s1,8(sp)
ffffffffc0201892:	6105                	addi	sp,sp,32
ffffffffc0201894:	b911                	j	ffffffffc02014a8 <slub_free.part.0>
        intr_disable();
ffffffffc0201896:	d2dfe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) // 遍历链表(似乎尾节点缺乏显示初始化为NULL)
ffffffffc020189a:	00014797          	auipc	a5,0x14
ffffffffc020189e:	d967b783          	ld	a5,-618(a5) # ffffffffc0215630 <bigblocks>
        return 1;
ffffffffc02018a2:	4605                	li	a2,1
ffffffffc02018a4:	f7bd                	bnez	a5,ffffffffc0201812 <kfree+0x26>
        intr_enable();
ffffffffc02018a6:	d17fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02018aa:	bfe9                	j	ffffffffc0201884 <kfree+0x98>
ffffffffc02018ac:	d11fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02018b0:	b741                	j	ffffffffc0201830 <kfree+0x44>
ffffffffc02018b2:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc02018b4:	00004617          	auipc	a2,0x4
ffffffffc02018b8:	dd460613          	addi	a2,a2,-556 # ffffffffc0205688 <buddy_system_pmm_manager+0x110>
ffffffffc02018bc:	06200593          	li	a1,98
ffffffffc02018c0:	00004517          	auipc	a0,0x4
ffffffffc02018c4:	d3050513          	addi	a0,a0,-720 # ffffffffc02055f0 <buddy_system_pmm_manager+0x78>
ffffffffc02018c8:	b7ffe0ef          	jal	ra,ffffffffc0200446 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02018cc:	86a2                	mv	a3,s0
ffffffffc02018ce:	00004617          	auipc	a2,0x4
ffffffffc02018d2:	d9260613          	addi	a2,a2,-622 # ffffffffc0205660 <buddy_system_pmm_manager+0xe8>
ffffffffc02018d6:	06e00593          	li	a1,110
ffffffffc02018da:	00004517          	auipc	a0,0x4
ffffffffc02018de:	d1650513          	addi	a0,a0,-746 # ffffffffc02055f0 <buddy_system_pmm_manager+0x78>
ffffffffc02018e2:	b65fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02018e6 <slub_init>:
{
ffffffffc02018e6:	715d                	addi	sp,sp,-80
	cprintf("use SLUB allocator\n");
ffffffffc02018e8:	00004517          	auipc	a0,0x4
ffffffffc02018ec:	dd850513          	addi	a0,a0,-552 # ffffffffc02056c0 <buddy_system_pmm_manager+0x148>
{
ffffffffc02018f0:	e0a2                	sd	s0,64(sp)
ffffffffc02018f2:	e486                	sd	ra,72(sp)
ffffffffc02018f4:	fc26                	sd	s1,56(sp)
ffffffffc02018f6:	f84a                	sd	s2,48(sp)
ffffffffc02018f8:	f44e                	sd	s3,40(sp)
ffffffffc02018fa:	f052                	sd	s4,32(sp)
ffffffffc02018fc:	ec56                	sd	s5,24(sp)
ffffffffc02018fe:	e85a                	sd	s6,16(sp)
ffffffffc0201900:	e45e                	sd	s7,8(sp)
ffffffffc0201902:	e062                	sd	s8,0(sp)
ffffffffc0201904:	00010417          	auipc	s0,0x10
ffffffffc0201908:	b6440413          	addi	s0,s0,-1180 # ffffffffc0211468 <Slubs>
	cprintf("use SLUB allocator\n");
ffffffffc020190c:	875fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
	for(int i=0,size=(1<<Slubs_min_order);i<Slubs_size;i++,size=(size<<1)) // 遍历初始化Slubs
ffffffffc0201910:	87a2                	mv	a5,s0
ffffffffc0201912:	00010617          	auipc	a2,0x10
ffffffffc0201916:	cd660613          	addi	a2,a2,-810 # ffffffffc02115e8 <pra_list_head>
ffffffffc020191a:	04000713          	li	a4,64
		Slubs[i].obj_size        = size-SLUB_UNIT;
ffffffffc020191e:	fe070693          	addi	a3,a4,-32 # fe0 <kern_entry-0xffffffffc01ff020>
		Slubs[i].size            = size;
ffffffffc0201922:	e398                	sd	a4,0(a5)
		Slubs[i].obj_size        = size-SLUB_UNIT;
ffffffffc0201924:	e794                	sd	a3,8(a5)
		Slubs[i].wait.nr_partial = 0;
ffffffffc0201926:	0007b823          	sd	zero,16(a5)
		Slubs[i].wait.nr_slabs   = 0;
ffffffffc020192a:	0007bc23          	sd	zero,24(a5)
		Slubs[i].wait.partial    = NULL;
ffffffffc020192e:	0207b023          	sd	zero,32(a5)
		Slubs[i].wait.full       = NULL;
ffffffffc0201932:	0207b423          	sd	zero,40(a5)
		Slubs[i].work.freelist   = NULL;
ffffffffc0201936:	0207bc23          	sd	zero,56(a5)
		Slubs[i].work.pages 	 = NULL;
ffffffffc020193a:	0207b823          	sd	zero,48(a5)
	for(int i=0,size=(1<<Slubs_min_order);i<Slubs_size;i++,size=(size<<1)) // 遍历初始化Slubs
ffffffffc020193e:	04078793          	addi	a5,a5,64
ffffffffc0201942:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201946:	fcc79ce3          	bne	a5,a2,ffffffffc020191e <slub_init+0x38>
	cprintf("################################################################################\n");
ffffffffc020194a:	00004517          	auipc	a0,0x4
ffffffffc020194e:	8de50513          	addi	a0,a0,-1826 # ffffffffc0205228 <commands+0x728>
ffffffffc0201952:	82ffe0ef          	jal	ra,ffffffffc0200180 <cprintf>
	cprintf("[自检程序]启动slub内存管理器的启动自检程序\n");
ffffffffc0201956:	00004517          	auipc	a0,0x4
ffffffffc020195a:	d8250513          	addi	a0,a0,-638 # ffffffffc02056d8 <buddy_system_pmm_manager+0x160>
ffffffffc020195e:	823fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
	assert(Slubs[i].size==up_size && size<=Slubs[i].obj_size);
ffffffffc0201962:	10043703          	ld	a4,256(s0)
ffffffffc0201966:	40000793          	li	a5,1024
ffffffffc020196a:	16f71263          	bne	a4,a5,ffffffffc0201ace <slub_init+0x1e8>
ffffffffc020196e:	10843703          	ld	a4,264(s0)
ffffffffc0201972:	38300793          	li	a5,899
ffffffffc0201976:	14e7fc63          	bgeu	a5,a4,ffffffffc0201ace <slub_init+0x1e8>
	return __kmalloc(size, 0);
ffffffffc020197a:	38400513          	li	a0,900
ffffffffc020197e:	d61ff0ef          	jal	ra,ffffffffc02016de <__kmalloc.constprop.0>
	assert(Slubs[i].work.pages!=NULL);
ffffffffc0201982:	13043783          	ld	a5,304(s0)
	return __kmalloc(size, 0);
ffffffffc0201986:	8baa                	mv	s7,a0
	assert(Slubs[i].work.pages!=NULL);
ffffffffc0201988:	1c078363          	beqz	a5,ffffffffc0201b4e <slub_init+0x268>
	return __kmalloc(size, 0);
ffffffffc020198c:	38400513          	li	a0,900
ffffffffc0201990:	d4fff0ef          	jal	ra,ffffffffc02016de <__kmalloc.constprop.0>
ffffffffc0201994:	8a2a                	mv	s4,a0
ffffffffc0201996:	38400513          	li	a0,900
ffffffffc020199a:	d45ff0ef          	jal	ra,ffffffffc02016de <__kmalloc.constprop.0>
ffffffffc020199e:	89aa                	mv	s3,a0
ffffffffc02019a0:	38400513          	li	a0,900
ffffffffc02019a4:	d3bff0ef          	jal	ra,ffffffffc02016de <__kmalloc.constprop.0>
	assert(x1+up_size==x2&&x2+up_size==x3&&x3+up_size==x4);
ffffffffc02019a8:	400b8793          	addi	a5,s7,1024
	return __kmalloc(size, 0);
ffffffffc02019ac:	8b2a                	mv	s6,a0
	assert(x1+up_size==x2&&x2+up_size==x3&&x3+up_size==x4);
ffffffffc02019ae:	16fa1063          	bne	s4,a5,ffffffffc0201b0e <slub_init+0x228>
ffffffffc02019b2:	400a0793          	addi	a5,s4,1024
ffffffffc02019b6:	14f99c63          	bne	s3,a5,ffffffffc0201b0e <slub_init+0x228>
ffffffffc02019ba:	40098793          	addi	a5,s3,1024
ffffffffc02019be:	14f51863          	bne	a0,a5,ffffffffc0201b0e <slub_init+0x228>
	return __kmalloc(size, 0);
ffffffffc02019c2:	38400513          	li	a0,900
ffffffffc02019c6:	d19ff0ef          	jal	ra,ffffffffc02016de <__kmalloc.constprop.0>
	kfree(y1);				// 工作区释放后为空(释放物理页）
ffffffffc02019ca:	e23ff0ef          	jal	ra,ffffffffc02017ec <kfree>
	return __kmalloc(size, 0);
ffffffffc02019ce:	38400513          	li	a0,900
ffffffffc02019d2:	d0dff0ef          	jal	ra,ffffffffc02016de <__kmalloc.constprop.0>
ffffffffc02019d6:	8c2a                	mv	s8,a0
ffffffffc02019d8:	38400513          	li	a0,900
ffffffffc02019dc:	d03ff0ef          	jal	ra,ffffffffc02016de <__kmalloc.constprop.0>
ffffffffc02019e0:	892a                	mv	s2,a0
ffffffffc02019e2:	38400513          	li	a0,900
ffffffffc02019e6:	cf9ff0ef          	jal	ra,ffffffffc02016de <__kmalloc.constprop.0>
ffffffffc02019ea:	84aa                	mv	s1,a0
ffffffffc02019ec:	38400513          	li	a0,900
ffffffffc02019f0:	cefff0ef          	jal	ra,ffffffffc02016de <__kmalloc.constprop.0>
	assert(y1+up_size==y2&&y2+up_size==y3&&y3+up_size==y4);
ffffffffc02019f4:	400c0793          	addi	a5,s8,1024
	return __kmalloc(size, 0);
ffffffffc02019f8:	8aaa                	mv	s5,a0
	assert(y1+up_size==y2&&y2+up_size==y3&&y3+up_size==y4);
ffffffffc02019fa:	0ef91a63          	bne	s2,a5,ffffffffc0201aee <slub_init+0x208>
ffffffffc02019fe:	40090793          	addi	a5,s2,1024 # 1400 <kern_entry-0xffffffffc01fec00>
ffffffffc0201a02:	0ef49663          	bne	s1,a5,ffffffffc0201aee <slub_init+0x208>
ffffffffc0201a06:	40048793          	addi	a5,s1,1024
ffffffffc0201a0a:	0ef51263          	bne	a0,a5,ffffffffc0201aee <slub_init+0x208>
	kfree(y1);				// 等待区full链表释放(放入等待区partial链表)
ffffffffc0201a0e:	8562                	mv	a0,s8
ffffffffc0201a10:	dddff0ef          	jal	ra,ffffffffc02017ec <kfree>
	kfree(x1);				// 等待区full链表释放(放入等待区partial链表)
ffffffffc0201a14:	855e                	mv	a0,s7
ffffffffc0201a16:	dd7ff0ef          	jal	ra,ffffffffc02017ec <kfree>
	kfree(x2);				// 等待区partial链表释放
ffffffffc0201a1a:	8552                	mv	a0,s4
ffffffffc0201a1c:	dd1ff0ef          	jal	ra,ffffffffc02017ec <kfree>
	kfree(x3);				// 等待区partial链表释放
ffffffffc0201a20:	854e                	mv	a0,s3
ffffffffc0201a22:	dcbff0ef          	jal	ra,ffffffffc02017ec <kfree>
	kfree(x4);				// 等待区partial链表释放为空(释放物理页）
ffffffffc0201a26:	855a                	mv	a0,s6
ffffffffc0201a28:	dc5ff0ef          	jal	ra,ffffffffc02017ec <kfree>
	kfree(y2);				// 等待区full链表释放(放入等待区partial链表)
ffffffffc0201a2c:	854a                	mv	a0,s2
ffffffffc0201a2e:	dbfff0ef          	jal	ra,ffffffffc02017ec <kfree>
	return __kmalloc(size, 0);
ffffffffc0201a32:	38400513          	li	a0,900
ffffffffc0201a36:	ca9ff0ef          	jal	ra,ffffffffc02016de <__kmalloc.constprop.0>
	kfree(y2);				// 工作区释放                                                     
ffffffffc0201a3a:	db3ff0ef          	jal	ra,ffffffffc02017ec <kfree>
	kfree(y3);				// 工作区释放
ffffffffc0201a3e:	8526                	mv	a0,s1
ffffffffc0201a40:	dadff0ef          	jal	ra,ffffffffc02017ec <kfree>
	kfree(y4);				// 工作区释放后为空(释放物理页）
ffffffffc0201a44:	8556                	mv	a0,s5
ffffffffc0201a46:	da7ff0ef          	jal	ra,ffffffffc02017ec <kfree>
	assert(Slubs[i].work.pages==NULL);
ffffffffc0201a4a:	13043783          	ld	a5,304(s0)
ffffffffc0201a4e:	0e079063          	bnez	a5,ffffffffc0201b2e <slub_init+0x248>
	return __kmalloc(size, 0);
ffffffffc0201a52:	6505                	lui	a0,0x1
ffffffffc0201a54:	c8bff0ef          	jal	ra,ffffffffc02016de <__kmalloc.constprop.0>
	kfree(x1);
ffffffffc0201a58:	d95ff0ef          	jal	ra,ffffffffc02017ec <kfree>
	return __kmalloc(size, 0);
ffffffffc0201a5c:	6505                	lui	a0,0x1
ffffffffc0201a5e:	c81ff0ef          	jal	ra,ffffffffc02016de <__kmalloc.constprop.0>
ffffffffc0201a62:	89aa                	mv	s3,a0
ffffffffc0201a64:	6505                	lui	a0,0x1
ffffffffc0201a66:	c79ff0ef          	jal	ra,ffffffffc02016de <__kmalloc.constprop.0>
ffffffffc0201a6a:	892a                	mv	s2,a0
ffffffffc0201a6c:	6509                	lui	a0,0x2
ffffffffc0201a6e:	c71ff0ef          	jal	ra,ffffffffc02016de <__kmalloc.constprop.0>
ffffffffc0201a72:	84aa                	mv	s1,a0
ffffffffc0201a74:	6551                	lui	a0,0x14
ffffffffc0201a76:	c69ff0ef          	jal	ra,ffffffffc02016de <__kmalloc.constprop.0>
ffffffffc0201a7a:	842a                	mv	s0,a0
	kfree(x1);
ffffffffc0201a7c:	854e                	mv	a0,s3
ffffffffc0201a7e:	d6fff0ef          	jal	ra,ffffffffc02017ec <kfree>
	kfree(x2);
ffffffffc0201a82:	854a                	mv	a0,s2
ffffffffc0201a84:	d69ff0ef          	jal	ra,ffffffffc02017ec <kfree>
	kfree(x3);
ffffffffc0201a88:	8526                	mv	a0,s1
ffffffffc0201a8a:	d63ff0ef          	jal	ra,ffffffffc02017ec <kfree>
	kfree(x4);
ffffffffc0201a8e:	8522                	mv	a0,s0
ffffffffc0201a90:	d5dff0ef          	jal	ra,ffffffffc02017ec <kfree>
	cprintf("[自检程序]退出slub内存管理器的启动自检程序\n");
ffffffffc0201a94:	00004517          	auipc	a0,0x4
ffffffffc0201a98:	d5c50513          	addi	a0,a0,-676 # ffffffffc02057f0 <buddy_system_pmm_manager+0x278>
ffffffffc0201a9c:	ee4fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
	cprintf("[自检程序]slub内存管理器的工作正常\n");
ffffffffc0201aa0:	00004517          	auipc	a0,0x4
ffffffffc0201aa4:	d9050513          	addi	a0,a0,-624 # ffffffffc0205830 <buddy_system_pmm_manager+0x2b8>
ffffffffc0201aa8:	ed8fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0201aac:	6406                	ld	s0,64(sp)
ffffffffc0201aae:	60a6                	ld	ra,72(sp)
ffffffffc0201ab0:	74e2                	ld	s1,56(sp)
ffffffffc0201ab2:	7942                	ld	s2,48(sp)
ffffffffc0201ab4:	79a2                	ld	s3,40(sp)
ffffffffc0201ab6:	7a02                	ld	s4,32(sp)
ffffffffc0201ab8:	6ae2                	ld	s5,24(sp)
ffffffffc0201aba:	6b42                	ld	s6,16(sp)
ffffffffc0201abc:	6ba2                	ld	s7,8(sp)
ffffffffc0201abe:	6c02                	ld	s8,0(sp)
	cprintf("################################################################################\n");
ffffffffc0201ac0:	00003517          	auipc	a0,0x3
ffffffffc0201ac4:	76850513          	addi	a0,a0,1896 # ffffffffc0205228 <commands+0x728>
}
ffffffffc0201ac8:	6161                	addi	sp,sp,80
	cprintf("################################################################################\n");
ffffffffc0201aca:	eb6fe06f          	j	ffffffffc0200180 <cprintf>
	assert(Slubs[i].size==up_size && size<=Slubs[i].obj_size);
ffffffffc0201ace:	00004697          	auipc	a3,0x4
ffffffffc0201ad2:	c4a68693          	addi	a3,a3,-950 # ffffffffc0205718 <buddy_system_pmm_manager+0x1a0>
ffffffffc0201ad6:	00004617          	auipc	a2,0x4
ffffffffc0201ada:	81a60613          	addi	a2,a2,-2022 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0201ade:	2e500593          	li	a1,741
ffffffffc0201ae2:	00004517          	auipc	a0,0x4
ffffffffc0201ae6:	ace50513          	addi	a0,a0,-1330 # ffffffffc02055b0 <buddy_system_pmm_manager+0x38>
ffffffffc0201aea:	95dfe0ef          	jal	ra,ffffffffc0200446 <__panic>
	assert(y1+up_size==y2&&y2+up_size==y3&&y3+up_size==y4);
ffffffffc0201aee:	00004697          	auipc	a3,0x4
ffffffffc0201af2:	cb268693          	addi	a3,a3,-846 # ffffffffc02057a0 <buddy_system_pmm_manager+0x228>
ffffffffc0201af6:	00003617          	auipc	a2,0x3
ffffffffc0201afa:	7fa60613          	addi	a2,a2,2042 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0201afe:	2fb00593          	li	a1,763
ffffffffc0201b02:	00004517          	auipc	a0,0x4
ffffffffc0201b06:	aae50513          	addi	a0,a0,-1362 # ffffffffc02055b0 <buddy_system_pmm_manager+0x38>
ffffffffc0201b0a:	93dfe0ef          	jal	ra,ffffffffc0200446 <__panic>
	assert(x1+up_size==x2&&x2+up_size==x3&&x3+up_size==x4);
ffffffffc0201b0e:	00004697          	auipc	a3,0x4
ffffffffc0201b12:	c6268693          	addi	a3,a3,-926 # ffffffffc0205770 <buddy_system_pmm_manager+0x1f8>
ffffffffc0201b16:	00003617          	auipc	a2,0x3
ffffffffc0201b1a:	7da60613          	addi	a2,a2,2010 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0201b1e:	2ee00593          	li	a1,750
ffffffffc0201b22:	00004517          	auipc	a0,0x4
ffffffffc0201b26:	a8e50513          	addi	a0,a0,-1394 # ffffffffc02055b0 <buddy_system_pmm_manager+0x38>
ffffffffc0201b2a:	91dfe0ef          	jal	ra,ffffffffc0200446 <__panic>
	assert(Slubs[i].work.pages==NULL);
ffffffffc0201b2e:	00004697          	auipc	a3,0x4
ffffffffc0201b32:	ca268693          	addi	a3,a3,-862 # ffffffffc02057d0 <buddy_system_pmm_manager+0x258>
ffffffffc0201b36:	00003617          	auipc	a2,0x3
ffffffffc0201b3a:	7ba60613          	addi	a2,a2,1978 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0201b3e:	30c00593          	li	a1,780
ffffffffc0201b42:	00004517          	auipc	a0,0x4
ffffffffc0201b46:	a6e50513          	addi	a0,a0,-1426 # ffffffffc02055b0 <buddy_system_pmm_manager+0x38>
ffffffffc0201b4a:	8fdfe0ef          	jal	ra,ffffffffc0200446 <__panic>
	assert(Slubs[i].work.pages!=NULL);
ffffffffc0201b4e:	00004697          	auipc	a3,0x4
ffffffffc0201b52:	c0268693          	addi	a3,a3,-1022 # ffffffffc0205750 <buddy_system_pmm_manager+0x1d8>
ffffffffc0201b56:	00003617          	auipc	a2,0x3
ffffffffc0201b5a:	79a60613          	addi	a2,a2,1946 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0201b5e:	2e800593          	li	a1,744
ffffffffc0201b62:	00004517          	auipc	a0,0x4
ffffffffc0201b66:	a4e50513          	addi	a0,a0,-1458 # ffffffffc02055b0 <buddy_system_pmm_manager+0x38>
ffffffffc0201b6a:	8ddfe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201b6e <kmalloc_init>:
{
ffffffffc0201b6e:	1141                	addi	sp,sp,-16
ffffffffc0201b70:	e406                	sd	ra,8(sp)
	if(USING_SLUB) slub_init();
ffffffffc0201b72:	d75ff0ef          	jal	ra,ffffffffc02018e6 <slub_init>
}
ffffffffc0201b76:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201b78:	00004517          	auipc	a0,0x4
ffffffffc0201b7c:	cf050513          	addi	a0,a0,-784 # ffffffffc0205868 <buddy_system_pmm_manager+0x2f0>
}
ffffffffc0201b80:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201b82:	dfefe06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0201b86 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0201b86:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201b88:	00004617          	auipc	a2,0x4
ffffffffc0201b8c:	b0060613          	addi	a2,a2,-1280 # ffffffffc0205688 <buddy_system_pmm_manager+0x110>
ffffffffc0201b90:	06200593          	li	a1,98
ffffffffc0201b94:	00004517          	auipc	a0,0x4
ffffffffc0201b98:	a5c50513          	addi	a0,a0,-1444 # ffffffffc02055f0 <buddy_system_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201b9c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201b9e:	8a9fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201ba2 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc0201ba2:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201ba4:	00004617          	auipc	a2,0x4
ffffffffc0201ba8:	ce460613          	addi	a2,a2,-796 # ffffffffc0205888 <buddy_system_pmm_manager+0x310>
ffffffffc0201bac:	07400593          	li	a1,116
ffffffffc0201bb0:	00004517          	auipc	a0,0x4
ffffffffc0201bb4:	a4050513          	addi	a0,a0,-1472 # ffffffffc02055f0 <buddy_system_pmm_manager+0x78>
pte2page(pte_t pte) {
ffffffffc0201bb8:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201bba:	88dfe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201bbe <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201bbe:	7139                	addi	sp,sp,-64
ffffffffc0201bc0:	f426                	sd	s1,40(sp)
ffffffffc0201bc2:	f04a                	sd	s2,32(sp)
ffffffffc0201bc4:	ec4e                	sd	s3,24(sp)
ffffffffc0201bc6:	e852                	sd	s4,16(sp)
ffffffffc0201bc8:	e456                	sd	s5,8(sp)
ffffffffc0201bca:	e05a                	sd	s6,0(sp)
ffffffffc0201bcc:	fc06                	sd	ra,56(sp)
ffffffffc0201bce:	f822                	sd	s0,48(sp)
ffffffffc0201bd0:	84aa                	mv	s1,a0
ffffffffc0201bd2:	00014917          	auipc	s2,0x14
ffffffffc0201bd6:	a8690913          	addi	s2,s2,-1402 # ffffffffc0215658 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201bda:	4a05                	li	s4,1
ffffffffc0201bdc:	00014a97          	auipc	s5,0x14
ffffffffc0201be0:	a9ca8a93          	addi	s5,s5,-1380 # ffffffffc0215678 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201be4:	0005099b          	sext.w	s3,a0
ffffffffc0201be8:	00014b17          	auipc	s6,0x14
ffffffffc0201bec:	a98b0b13          	addi	s6,s6,-1384 # ffffffffc0215680 <check_mm_struct>
ffffffffc0201bf0:	a01d                	j	ffffffffc0201c16 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201bf2:	00093783          	ld	a5,0(s2)
ffffffffc0201bf6:	6f9c                	ld	a5,24(a5)
ffffffffc0201bf8:	9782                	jalr	a5
ffffffffc0201bfa:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0201bfc:	4601                	li	a2,0
ffffffffc0201bfe:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201c00:	ec0d                	bnez	s0,ffffffffc0201c3a <alloc_pages+0x7c>
ffffffffc0201c02:	029a6c63          	bltu	s4,s1,ffffffffc0201c3a <alloc_pages+0x7c>
ffffffffc0201c06:	000aa783          	lw	a5,0(s5)
ffffffffc0201c0a:	2781                	sext.w	a5,a5
ffffffffc0201c0c:	c79d                	beqz	a5,ffffffffc0201c3a <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201c0e:	000b3503          	ld	a0,0(s6)
ffffffffc0201c12:	17e010ef          	jal	ra,ffffffffc0202d90 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c16:	100027f3          	csrr	a5,sstatus
ffffffffc0201c1a:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201c1c:	8526                	mv	a0,s1
ffffffffc0201c1e:	dbf1                	beqz	a5,ffffffffc0201bf2 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201c20:	9a3fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0201c24:	00093783          	ld	a5,0(s2)
ffffffffc0201c28:	8526                	mv	a0,s1
ffffffffc0201c2a:	6f9c                	ld	a5,24(a5)
ffffffffc0201c2c:	9782                	jalr	a5
ffffffffc0201c2e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201c30:	98dfe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201c34:	4601                	li	a2,0
ffffffffc0201c36:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201c38:	d469                	beqz	s0,ffffffffc0201c02 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201c3a:	70e2                	ld	ra,56(sp)
ffffffffc0201c3c:	8522                	mv	a0,s0
ffffffffc0201c3e:	7442                	ld	s0,48(sp)
ffffffffc0201c40:	74a2                	ld	s1,40(sp)
ffffffffc0201c42:	7902                	ld	s2,32(sp)
ffffffffc0201c44:	69e2                	ld	s3,24(sp)
ffffffffc0201c46:	6a42                	ld	s4,16(sp)
ffffffffc0201c48:	6aa2                	ld	s5,8(sp)
ffffffffc0201c4a:	6b02                	ld	s6,0(sp)
ffffffffc0201c4c:	6121                	addi	sp,sp,64
ffffffffc0201c4e:	8082                	ret

ffffffffc0201c50 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c50:	100027f3          	csrr	a5,sstatus
ffffffffc0201c54:	8b89                	andi	a5,a5,2
ffffffffc0201c56:	e799                	bnez	a5,ffffffffc0201c64 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201c58:	00014797          	auipc	a5,0x14
ffffffffc0201c5c:	a007b783          	ld	a5,-1536(a5) # ffffffffc0215658 <pmm_manager>
ffffffffc0201c60:	739c                	ld	a5,32(a5)
ffffffffc0201c62:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201c64:	1101                	addi	sp,sp,-32
ffffffffc0201c66:	ec06                	sd	ra,24(sp)
ffffffffc0201c68:	e822                	sd	s0,16(sp)
ffffffffc0201c6a:	e426                	sd	s1,8(sp)
ffffffffc0201c6c:	842a                	mv	s0,a0
ffffffffc0201c6e:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201c70:	953fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201c74:	00014797          	auipc	a5,0x14
ffffffffc0201c78:	9e47b783          	ld	a5,-1564(a5) # ffffffffc0215658 <pmm_manager>
ffffffffc0201c7c:	739c                	ld	a5,32(a5)
ffffffffc0201c7e:	85a6                	mv	a1,s1
ffffffffc0201c80:	8522                	mv	a0,s0
ffffffffc0201c82:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201c84:	6442                	ld	s0,16(sp)
ffffffffc0201c86:	60e2                	ld	ra,24(sp)
ffffffffc0201c88:	64a2                	ld	s1,8(sp)
ffffffffc0201c8a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201c8c:	931fe06f          	j	ffffffffc02005bc <intr_enable>

ffffffffc0201c90 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c90:	100027f3          	csrr	a5,sstatus
ffffffffc0201c94:	8b89                	andi	a5,a5,2
ffffffffc0201c96:	e799                	bnez	a5,ffffffffc0201ca4 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201c98:	00014797          	auipc	a5,0x14
ffffffffc0201c9c:	9c07b783          	ld	a5,-1600(a5) # ffffffffc0215658 <pmm_manager>
ffffffffc0201ca0:	779c                	ld	a5,40(a5)
ffffffffc0201ca2:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201ca4:	1141                	addi	sp,sp,-16
ffffffffc0201ca6:	e406                	sd	ra,8(sp)
ffffffffc0201ca8:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201caa:	919fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201cae:	00014797          	auipc	a5,0x14
ffffffffc0201cb2:	9aa7b783          	ld	a5,-1622(a5) # ffffffffc0215658 <pmm_manager>
ffffffffc0201cb6:	779c                	ld	a5,40(a5)
ffffffffc0201cb8:	9782                	jalr	a5
ffffffffc0201cba:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201cbc:	901fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201cc0:	60a2                	ld	ra,8(sp)
ffffffffc0201cc2:	8522                	mv	a0,s0
ffffffffc0201cc4:	6402                	ld	s0,0(sp)
ffffffffc0201cc6:	0141                	addi	sp,sp,16
ffffffffc0201cc8:	8082                	ret

ffffffffc0201cca <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201cca:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201cce:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201cd2:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201cd4:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201cd6:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201cd8:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201cdc:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201cde:	f04a                	sd	s2,32(sp)
ffffffffc0201ce0:	ec4e                	sd	s3,24(sp)
ffffffffc0201ce2:	e852                	sd	s4,16(sp)
ffffffffc0201ce4:	fc06                	sd	ra,56(sp)
ffffffffc0201ce6:	f822                	sd	s0,48(sp)
ffffffffc0201ce8:	e456                	sd	s5,8(sp)
ffffffffc0201cea:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201cec:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201cf0:	892e                	mv	s2,a1
ffffffffc0201cf2:	89b2                	mv	s3,a2
ffffffffc0201cf4:	00014a17          	auipc	s4,0x14
ffffffffc0201cf8:	954a0a13          	addi	s4,s4,-1708 # ffffffffc0215648 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201cfc:	e7b5                	bnez	a5,ffffffffc0201d68 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201cfe:	12060b63          	beqz	a2,ffffffffc0201e34 <get_pte+0x16a>
ffffffffc0201d02:	4505                	li	a0,1
ffffffffc0201d04:	ebbff0ef          	jal	ra,ffffffffc0201bbe <alloc_pages>
ffffffffc0201d08:	842a                	mv	s0,a0
ffffffffc0201d0a:	12050563          	beqz	a0,ffffffffc0201e34 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201d0e:	00014b17          	auipc	s6,0x14
ffffffffc0201d12:	942b0b13          	addi	s6,s6,-1726 # ffffffffc0215650 <pages>
ffffffffc0201d16:	000b3503          	ld	a0,0(s6)
ffffffffc0201d1a:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201d1e:	00014a17          	auipc	s4,0x14
ffffffffc0201d22:	92aa0a13          	addi	s4,s4,-1750 # ffffffffc0215648 <npage>
ffffffffc0201d26:	40a40533          	sub	a0,s0,a0
ffffffffc0201d2a:	8519                	srai	a0,a0,0x6
ffffffffc0201d2c:	9556                	add	a0,a0,s5
ffffffffc0201d2e:	000a3703          	ld	a4,0(s4)
ffffffffc0201d32:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201d36:	4685                	li	a3,1
ffffffffc0201d38:	c014                	sw	a3,0(s0)
ffffffffc0201d3a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201d3c:	0532                	slli	a0,a0,0xc
ffffffffc0201d3e:	14e7f263          	bgeu	a5,a4,ffffffffc0201e82 <get_pte+0x1b8>
ffffffffc0201d42:	00014797          	auipc	a5,0x14
ffffffffc0201d46:	91e7b783          	ld	a5,-1762(a5) # ffffffffc0215660 <va_pa_offset>
ffffffffc0201d4a:	6605                	lui	a2,0x1
ffffffffc0201d4c:	4581                	li	a1,0
ffffffffc0201d4e:	953e                	add	a0,a0,a5
ffffffffc0201d50:	2fb020ef          	jal	ra,ffffffffc020484a <memset>
    return page - pages + nbase;
ffffffffc0201d54:	000b3683          	ld	a3,0(s6)
ffffffffc0201d58:	40d406b3          	sub	a3,s0,a3
ffffffffc0201d5c:	8699                	srai	a3,a3,0x6
ffffffffc0201d5e:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201d60:	06aa                	slli	a3,a3,0xa
ffffffffc0201d62:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201d66:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201d68:	77fd                	lui	a5,0xfffff
ffffffffc0201d6a:	068a                	slli	a3,a3,0x2
ffffffffc0201d6c:	000a3703          	ld	a4,0(s4)
ffffffffc0201d70:	8efd                	and	a3,a3,a5
ffffffffc0201d72:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201d76:	0ce7f163          	bgeu	a5,a4,ffffffffc0201e38 <get_pte+0x16e>
ffffffffc0201d7a:	00014a97          	auipc	s5,0x14
ffffffffc0201d7e:	8e6a8a93          	addi	s5,s5,-1818 # ffffffffc0215660 <va_pa_offset>
ffffffffc0201d82:	000ab403          	ld	s0,0(s5)
ffffffffc0201d86:	01595793          	srli	a5,s2,0x15
ffffffffc0201d8a:	1ff7f793          	andi	a5,a5,511
ffffffffc0201d8e:	96a2                	add	a3,a3,s0
ffffffffc0201d90:	00379413          	slli	s0,a5,0x3
ffffffffc0201d94:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201d96:	6014                	ld	a3,0(s0)
ffffffffc0201d98:	0016f793          	andi	a5,a3,1
ffffffffc0201d9c:	e3ad                	bnez	a5,ffffffffc0201dfe <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201d9e:	08098b63          	beqz	s3,ffffffffc0201e34 <get_pte+0x16a>
ffffffffc0201da2:	4505                	li	a0,1
ffffffffc0201da4:	e1bff0ef          	jal	ra,ffffffffc0201bbe <alloc_pages>
ffffffffc0201da8:	84aa                	mv	s1,a0
ffffffffc0201daa:	c549                	beqz	a0,ffffffffc0201e34 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201dac:	00014b17          	auipc	s6,0x14
ffffffffc0201db0:	8a4b0b13          	addi	s6,s6,-1884 # ffffffffc0215650 <pages>
ffffffffc0201db4:	000b3503          	ld	a0,0(s6)
ffffffffc0201db8:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201dbc:	000a3703          	ld	a4,0(s4)
ffffffffc0201dc0:	40a48533          	sub	a0,s1,a0
ffffffffc0201dc4:	8519                	srai	a0,a0,0x6
ffffffffc0201dc6:	954e                	add	a0,a0,s3
ffffffffc0201dc8:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201dcc:	4685                	li	a3,1
ffffffffc0201dce:	c094                	sw	a3,0(s1)
ffffffffc0201dd0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201dd2:	0532                	slli	a0,a0,0xc
ffffffffc0201dd4:	08e7fa63          	bgeu	a5,a4,ffffffffc0201e68 <get_pte+0x19e>
ffffffffc0201dd8:	000ab783          	ld	a5,0(s5)
ffffffffc0201ddc:	6605                	lui	a2,0x1
ffffffffc0201dde:	4581                	li	a1,0
ffffffffc0201de0:	953e                	add	a0,a0,a5
ffffffffc0201de2:	269020ef          	jal	ra,ffffffffc020484a <memset>
    return page - pages + nbase;
ffffffffc0201de6:	000b3683          	ld	a3,0(s6)
ffffffffc0201dea:	40d486b3          	sub	a3,s1,a3
ffffffffc0201dee:	8699                	srai	a3,a3,0x6
ffffffffc0201df0:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201df2:	06aa                	slli	a3,a3,0xa
ffffffffc0201df4:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201df8:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201dfa:	000a3703          	ld	a4,0(s4)
ffffffffc0201dfe:	068a                	slli	a3,a3,0x2
ffffffffc0201e00:	757d                	lui	a0,0xfffff
ffffffffc0201e02:	8ee9                	and	a3,a3,a0
ffffffffc0201e04:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201e08:	04e7f463          	bgeu	a5,a4,ffffffffc0201e50 <get_pte+0x186>
ffffffffc0201e0c:	000ab503          	ld	a0,0(s5)
ffffffffc0201e10:	00c95913          	srli	s2,s2,0xc
ffffffffc0201e14:	1ff97913          	andi	s2,s2,511
ffffffffc0201e18:	96aa                	add	a3,a3,a0
ffffffffc0201e1a:	00391513          	slli	a0,s2,0x3
ffffffffc0201e1e:	9536                	add	a0,a0,a3
}
ffffffffc0201e20:	70e2                	ld	ra,56(sp)
ffffffffc0201e22:	7442                	ld	s0,48(sp)
ffffffffc0201e24:	74a2                	ld	s1,40(sp)
ffffffffc0201e26:	7902                	ld	s2,32(sp)
ffffffffc0201e28:	69e2                	ld	s3,24(sp)
ffffffffc0201e2a:	6a42                	ld	s4,16(sp)
ffffffffc0201e2c:	6aa2                	ld	s5,8(sp)
ffffffffc0201e2e:	6b02                	ld	s6,0(sp)
ffffffffc0201e30:	6121                	addi	sp,sp,64
ffffffffc0201e32:	8082                	ret
            return NULL;
ffffffffc0201e34:	4501                	li	a0,0
ffffffffc0201e36:	b7ed                	j	ffffffffc0201e20 <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201e38:	00003617          	auipc	a2,0x3
ffffffffc0201e3c:	79060613          	addi	a2,a2,1936 # ffffffffc02055c8 <buddy_system_pmm_manager+0x50>
ffffffffc0201e40:	0f500593          	li	a1,245
ffffffffc0201e44:	00004517          	auipc	a0,0x4
ffffffffc0201e48:	a6c50513          	addi	a0,a0,-1428 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0201e4c:	dfafe0ef          	jal	ra,ffffffffc0200446 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201e50:	00003617          	auipc	a2,0x3
ffffffffc0201e54:	77860613          	addi	a2,a2,1912 # ffffffffc02055c8 <buddy_system_pmm_manager+0x50>
ffffffffc0201e58:	10000593          	li	a1,256
ffffffffc0201e5c:	00004517          	auipc	a0,0x4
ffffffffc0201e60:	a5450513          	addi	a0,a0,-1452 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0201e64:	de2fe0ef          	jal	ra,ffffffffc0200446 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e68:	86aa                	mv	a3,a0
ffffffffc0201e6a:	00003617          	auipc	a2,0x3
ffffffffc0201e6e:	75e60613          	addi	a2,a2,1886 # ffffffffc02055c8 <buddy_system_pmm_manager+0x50>
ffffffffc0201e72:	0fd00593          	li	a1,253
ffffffffc0201e76:	00004517          	auipc	a0,0x4
ffffffffc0201e7a:	a3a50513          	addi	a0,a0,-1478 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0201e7e:	dc8fe0ef          	jal	ra,ffffffffc0200446 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e82:	86aa                	mv	a3,a0
ffffffffc0201e84:	00003617          	auipc	a2,0x3
ffffffffc0201e88:	74460613          	addi	a2,a2,1860 # ffffffffc02055c8 <buddy_system_pmm_manager+0x50>
ffffffffc0201e8c:	0f200593          	li	a1,242
ffffffffc0201e90:	00004517          	auipc	a0,0x4
ffffffffc0201e94:	a2050513          	addi	a0,a0,-1504 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0201e98:	daefe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201e9c <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201e9c:	1141                	addi	sp,sp,-16
ffffffffc0201e9e:	e022                	sd	s0,0(sp)
ffffffffc0201ea0:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201ea2:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201ea4:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201ea6:	e25ff0ef          	jal	ra,ffffffffc0201cca <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201eaa:	c011                	beqz	s0,ffffffffc0201eae <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201eac:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201eae:	c511                	beqz	a0,ffffffffc0201eba <get_page+0x1e>
ffffffffc0201eb0:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201eb2:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201eb4:	0017f713          	andi	a4,a5,1
ffffffffc0201eb8:	e709                	bnez	a4,ffffffffc0201ec2 <get_page+0x26>
}
ffffffffc0201eba:	60a2                	ld	ra,8(sp)
ffffffffc0201ebc:	6402                	ld	s0,0(sp)
ffffffffc0201ebe:	0141                	addi	sp,sp,16
ffffffffc0201ec0:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ec2:	078a                	slli	a5,a5,0x2
ffffffffc0201ec4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ec6:	00013717          	auipc	a4,0x13
ffffffffc0201eca:	78273703          	ld	a4,1922(a4) # ffffffffc0215648 <npage>
ffffffffc0201ece:	00e7ff63          	bgeu	a5,a4,ffffffffc0201eec <get_page+0x50>
ffffffffc0201ed2:	60a2                	ld	ra,8(sp)
ffffffffc0201ed4:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0201ed6:	fff80537          	lui	a0,0xfff80
ffffffffc0201eda:	97aa                	add	a5,a5,a0
ffffffffc0201edc:	079a                	slli	a5,a5,0x6
ffffffffc0201ede:	00013517          	auipc	a0,0x13
ffffffffc0201ee2:	77253503          	ld	a0,1906(a0) # ffffffffc0215650 <pages>
ffffffffc0201ee6:	953e                	add	a0,a0,a5
ffffffffc0201ee8:	0141                	addi	sp,sp,16
ffffffffc0201eea:	8082                	ret
ffffffffc0201eec:	c9bff0ef          	jal	ra,ffffffffc0201b86 <pa2page.part.0>

ffffffffc0201ef0 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201ef0:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201ef2:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201ef4:	ec26                	sd	s1,24(sp)
ffffffffc0201ef6:	f406                	sd	ra,40(sp)
ffffffffc0201ef8:	f022                	sd	s0,32(sp)
ffffffffc0201efa:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201efc:	dcfff0ef          	jal	ra,ffffffffc0201cca <get_pte>
    if (ptep != NULL) {
ffffffffc0201f00:	c511                	beqz	a0,ffffffffc0201f0c <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201f02:	611c                	ld	a5,0(a0)
ffffffffc0201f04:	842a                	mv	s0,a0
ffffffffc0201f06:	0017f713          	andi	a4,a5,1
ffffffffc0201f0a:	e711                	bnez	a4,ffffffffc0201f16 <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201f0c:	70a2                	ld	ra,40(sp)
ffffffffc0201f0e:	7402                	ld	s0,32(sp)
ffffffffc0201f10:	64e2                	ld	s1,24(sp)
ffffffffc0201f12:	6145                	addi	sp,sp,48
ffffffffc0201f14:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201f16:	078a                	slli	a5,a5,0x2
ffffffffc0201f18:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f1a:	00013717          	auipc	a4,0x13
ffffffffc0201f1e:	72e73703          	ld	a4,1838(a4) # ffffffffc0215648 <npage>
ffffffffc0201f22:	06e7f363          	bgeu	a5,a4,ffffffffc0201f88 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f26:	fff80537          	lui	a0,0xfff80
ffffffffc0201f2a:	97aa                	add	a5,a5,a0
ffffffffc0201f2c:	079a                	slli	a5,a5,0x6
ffffffffc0201f2e:	00013517          	auipc	a0,0x13
ffffffffc0201f32:	72253503          	ld	a0,1826(a0) # ffffffffc0215650 <pages>
ffffffffc0201f36:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201f38:	411c                	lw	a5,0(a0)
ffffffffc0201f3a:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201f3e:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201f40:	cb11                	beqz	a4,ffffffffc0201f54 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201f42:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201f46:	12048073          	sfence.vma	s1
}
ffffffffc0201f4a:	70a2                	ld	ra,40(sp)
ffffffffc0201f4c:	7402                	ld	s0,32(sp)
ffffffffc0201f4e:	64e2                	ld	s1,24(sp)
ffffffffc0201f50:	6145                	addi	sp,sp,48
ffffffffc0201f52:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f54:	100027f3          	csrr	a5,sstatus
ffffffffc0201f58:	8b89                	andi	a5,a5,2
ffffffffc0201f5a:	eb89                	bnez	a5,ffffffffc0201f6c <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0201f5c:	00013797          	auipc	a5,0x13
ffffffffc0201f60:	6fc7b783          	ld	a5,1788(a5) # ffffffffc0215658 <pmm_manager>
ffffffffc0201f64:	739c                	ld	a5,32(a5)
ffffffffc0201f66:	4585                	li	a1,1
ffffffffc0201f68:	9782                	jalr	a5
    if (flag) {
ffffffffc0201f6a:	bfe1                	j	ffffffffc0201f42 <page_remove+0x52>
        intr_disable();
ffffffffc0201f6c:	e42a                	sd	a0,8(sp)
ffffffffc0201f6e:	e54fe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0201f72:	00013797          	auipc	a5,0x13
ffffffffc0201f76:	6e67b783          	ld	a5,1766(a5) # ffffffffc0215658 <pmm_manager>
ffffffffc0201f7a:	739c                	ld	a5,32(a5)
ffffffffc0201f7c:	6522                	ld	a0,8(sp)
ffffffffc0201f7e:	4585                	li	a1,1
ffffffffc0201f80:	9782                	jalr	a5
        intr_enable();
ffffffffc0201f82:	e3afe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0201f86:	bf75                	j	ffffffffc0201f42 <page_remove+0x52>
ffffffffc0201f88:	bffff0ef          	jal	ra,ffffffffc0201b86 <pa2page.part.0>

ffffffffc0201f8c <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f8c:	7139                	addi	sp,sp,-64
ffffffffc0201f8e:	e852                	sd	s4,16(sp)
ffffffffc0201f90:	8a32                	mv	s4,a2
ffffffffc0201f92:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201f94:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f96:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201f98:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f9a:	f426                	sd	s1,40(sp)
ffffffffc0201f9c:	fc06                	sd	ra,56(sp)
ffffffffc0201f9e:	f04a                	sd	s2,32(sp)
ffffffffc0201fa0:	ec4e                	sd	s3,24(sp)
ffffffffc0201fa2:	e456                	sd	s5,8(sp)
ffffffffc0201fa4:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201fa6:	d25ff0ef          	jal	ra,ffffffffc0201cca <get_pte>
    if (ptep == NULL) {
ffffffffc0201faa:	c961                	beqz	a0,ffffffffc020207a <page_insert+0xee>
    page->ref += 1;
ffffffffc0201fac:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201fae:	611c                	ld	a5,0(a0)
ffffffffc0201fb0:	89aa                	mv	s3,a0
ffffffffc0201fb2:	0016871b          	addiw	a4,a3,1
ffffffffc0201fb6:	c018                	sw	a4,0(s0)
ffffffffc0201fb8:	0017f713          	andi	a4,a5,1
ffffffffc0201fbc:	ef05                	bnez	a4,ffffffffc0201ff4 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0201fbe:	00013717          	auipc	a4,0x13
ffffffffc0201fc2:	69273703          	ld	a4,1682(a4) # ffffffffc0215650 <pages>
ffffffffc0201fc6:	8c19                	sub	s0,s0,a4
ffffffffc0201fc8:	000807b7          	lui	a5,0x80
ffffffffc0201fcc:	8419                	srai	s0,s0,0x6
ffffffffc0201fce:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201fd0:	042a                	slli	s0,s0,0xa
ffffffffc0201fd2:	8cc1                	or	s1,s1,s0
ffffffffc0201fd4:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201fd8:	0099b023          	sd	s1,0(s3) # 80000 <kern_entry-0xffffffffc0180000>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201fdc:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0201fe0:	4501                	li	a0,0
}
ffffffffc0201fe2:	70e2                	ld	ra,56(sp)
ffffffffc0201fe4:	7442                	ld	s0,48(sp)
ffffffffc0201fe6:	74a2                	ld	s1,40(sp)
ffffffffc0201fe8:	7902                	ld	s2,32(sp)
ffffffffc0201fea:	69e2                	ld	s3,24(sp)
ffffffffc0201fec:	6a42                	ld	s4,16(sp)
ffffffffc0201fee:	6aa2                	ld	s5,8(sp)
ffffffffc0201ff0:	6121                	addi	sp,sp,64
ffffffffc0201ff2:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ff4:	078a                	slli	a5,a5,0x2
ffffffffc0201ff6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ff8:	00013717          	auipc	a4,0x13
ffffffffc0201ffc:	65073703          	ld	a4,1616(a4) # ffffffffc0215648 <npage>
ffffffffc0202000:	06e7ff63          	bgeu	a5,a4,ffffffffc020207e <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0202004:	00013a97          	auipc	s5,0x13
ffffffffc0202008:	64ca8a93          	addi	s5,s5,1612 # ffffffffc0215650 <pages>
ffffffffc020200c:	000ab703          	ld	a4,0(s5)
ffffffffc0202010:	fff80937          	lui	s2,0xfff80
ffffffffc0202014:	993e                	add	s2,s2,a5
ffffffffc0202016:	091a                	slli	s2,s2,0x6
ffffffffc0202018:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc020201a:	01240c63          	beq	s0,s2,ffffffffc0202032 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc020201e:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fd6a954>
ffffffffc0202022:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202026:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc020202a:	c691                	beqz	a3,ffffffffc0202036 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020202c:	120a0073          	sfence.vma	s4
}
ffffffffc0202030:	bf59                	j	ffffffffc0201fc6 <page_insert+0x3a>
ffffffffc0202032:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202034:	bf49                	j	ffffffffc0201fc6 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202036:	100027f3          	csrr	a5,sstatus
ffffffffc020203a:	8b89                	andi	a5,a5,2
ffffffffc020203c:	ef91                	bnez	a5,ffffffffc0202058 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc020203e:	00013797          	auipc	a5,0x13
ffffffffc0202042:	61a7b783          	ld	a5,1562(a5) # ffffffffc0215658 <pmm_manager>
ffffffffc0202046:	739c                	ld	a5,32(a5)
ffffffffc0202048:	4585                	li	a1,1
ffffffffc020204a:	854a                	mv	a0,s2
ffffffffc020204c:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc020204e:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202052:	120a0073          	sfence.vma	s4
ffffffffc0202056:	bf85                	j	ffffffffc0201fc6 <page_insert+0x3a>
        intr_disable();
ffffffffc0202058:	d6afe0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020205c:	00013797          	auipc	a5,0x13
ffffffffc0202060:	5fc7b783          	ld	a5,1532(a5) # ffffffffc0215658 <pmm_manager>
ffffffffc0202064:	739c                	ld	a5,32(a5)
ffffffffc0202066:	4585                	li	a1,1
ffffffffc0202068:	854a                	mv	a0,s2
ffffffffc020206a:	9782                	jalr	a5
        intr_enable();
ffffffffc020206c:	d50fe0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202070:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202074:	120a0073          	sfence.vma	s4
ffffffffc0202078:	b7b9                	j	ffffffffc0201fc6 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020207a:	5571                	li	a0,-4
ffffffffc020207c:	b79d                	j	ffffffffc0201fe2 <page_insert+0x56>
ffffffffc020207e:	b09ff0ef          	jal	ra,ffffffffc0201b86 <pa2page.part.0>

ffffffffc0202082 <pmm_init>:
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0202082:	00003797          	auipc	a5,0x3
ffffffffc0202086:	4f678793          	addi	a5,a5,1270 # ffffffffc0205578 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020208a:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020208c:	711d                	addi	sp,sp,-96
ffffffffc020208e:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202090:	00004517          	auipc	a0,0x4
ffffffffc0202094:	83050513          	addi	a0,a0,-2000 # ffffffffc02058c0 <buddy_system_pmm_manager+0x348>
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0202098:	00013b97          	auipc	s7,0x13
ffffffffc020209c:	5c0b8b93          	addi	s7,s7,1472 # ffffffffc0215658 <pmm_manager>
void pmm_init(void) {
ffffffffc02020a0:	ec86                	sd	ra,88(sp)
ffffffffc02020a2:	e4a6                	sd	s1,72(sp)
ffffffffc02020a4:	fc4e                	sd	s3,56(sp)
ffffffffc02020a6:	f05a                	sd	s6,32(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc02020a8:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc02020ac:	e8a2                	sd	s0,80(sp)
ffffffffc02020ae:	e0ca                	sd	s2,64(sp)
ffffffffc02020b0:	f852                	sd	s4,48(sp)
ffffffffc02020b2:	f456                	sd	s5,40(sp)
ffffffffc02020b4:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02020b6:	8cafe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pmm_manager->init();
ffffffffc02020ba:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;                           // 虚拟地址到物理地址的偏移量
ffffffffc02020be:	00013997          	auipc	s3,0x13
ffffffffc02020c2:	5a298993          	addi	s3,s3,1442 # ffffffffc0215660 <va_pa_offset>
    npage = maxpa / PGSIZE;     // 物理页的页数
ffffffffc02020c6:	00013497          	auipc	s1,0x13
ffffffffc02020ca:	58248493          	addi	s1,s1,1410 # ffffffffc0215648 <npage>
    pmm_manager->init();
ffffffffc02020ce:	679c                	ld	a5,8(a5)
    pages = pages_begin;
ffffffffc02020d0:	00013b17          	auipc	s6,0x13
ffffffffc02020d4:	580b0b13          	addi	s6,s6,1408 # ffffffffc0215650 <pages>
    pmm_manager->init();
ffffffffc02020d8:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;                           // 虚拟地址到物理地址的偏移量
ffffffffc02020da:	57f5                	li	a5,-3
ffffffffc02020dc:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02020de:	00003517          	auipc	a0,0x3
ffffffffc02020e2:	7fa50513          	addi	a0,a0,2042 # ffffffffc02058d8 <buddy_system_pmm_manager+0x360>
    va_pa_offset = KERNBASE - 0x80200000;                           // 虚拟地址到物理地址的偏移量
ffffffffc02020e6:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc02020ea:	896fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin, mem_end - 1);
ffffffffc02020ee:	46c5                	li	a3,17
ffffffffc02020f0:	06ee                	slli	a3,a3,0x1b
ffffffffc02020f2:	40100613          	li	a2,1025
ffffffffc02020f6:	16fd                	addi	a3,a3,-1
ffffffffc02020f8:	0656                	slli	a2,a2,0x15
ffffffffc02020fa:	07e005b7          	lui	a1,0x7e00
ffffffffc02020fe:	00003517          	auipc	a0,0x3
ffffffffc0202102:	7f250513          	addi	a0,a0,2034 # ffffffffc02058f0 <buddy_system_pmm_manager+0x378>
ffffffffc0202106:	87afe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    size_t* tree_begin = (size_t *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020210a:	767d                	lui	a2,0xfffff
ffffffffc020210c:	00014717          	auipc	a4,0x14
ffffffffc0202110:	59f70713          	addi	a4,a4,1439 # ffffffffc02166ab <end+0xfff>
ffffffffc0202114:	8f71                	and	a4,a4,a2
    size_t* tree_end = tree_begin+tree_size;
ffffffffc0202116:	000807b7          	lui	a5,0x80
    struct Page* pages_begin = (struct Page*)ROUNDUP(tree_end, PGSIZE);
ffffffffc020211a:	6685                	lui	a3,0x1
    size_t* tree_end = tree_begin+tree_size;
ffffffffc020211c:	97ba                	add	a5,a5,a4
    struct Page* pages_begin = (struct Page*)ROUNDUP(tree_end, PGSIZE);
ffffffffc020211e:	16fd                	addi	a3,a3,-1
ffffffffc0202120:	97b6                	add	a5,a5,a3
    npage = maxpa / PGSIZE;     // 物理页的页数
ffffffffc0202122:	000886b7          	lui	a3,0x88
ffffffffc0202126:	e094                	sd	a3,0(s1)
    free_area.free_tree = tree_begin;
ffffffffc0202128:	0000f697          	auipc	a3,0xf
ffffffffc020212c:	32e6b423          	sd	a4,808(a3) # ffffffffc0211450 <free_area+0x8>
    struct Page* pages_begin = (struct Page*)ROUNDUP(tree_end, PGSIZE);
ffffffffc0202130:	8ff1                	and	a5,a5,a2
    struct Page* page_end    = pages_begin+page_num;
ffffffffc0202132:	002006b7          	lui	a3,0x200
ffffffffc0202136:	96be                	add	a3,a3,a5
    pages = pages_begin;
ffffffffc0202138:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) 
ffffffffc020213c:	4701                	li	a4,0
ffffffffc020213e:	4585                	li	a1,1
ffffffffc0202140:	fff80837          	lui	a6,0xfff80
ffffffffc0202144:	a019                	j	ffffffffc020214a <pmm_init+0xc8>
        SetPageReserved(pages + i); //在kern/mm/memlayout.h定义的(将该bit设为1，为内核保留页面)
ffffffffc0202146:	000b3783          	ld	a5,0(s6)
ffffffffc020214a:	00671613          	slli	a2,a4,0x6
ffffffffc020214e:	97b2                	add	a5,a5,a2
ffffffffc0202150:	07a1                	addi	a5,a5,8
ffffffffc0202152:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) 
ffffffffc0202156:	609c                	ld	a5,0(s1)
ffffffffc0202158:	0705                	addi	a4,a4,1
ffffffffc020215a:	01078633          	add	a2,a5,a6
ffffffffc020215e:	fec764e3          	bltu	a4,a2,ffffffffc0202146 <pmm_init+0xc4>
    uintptr_t freemem = PADDR(page_end);
ffffffffc0202162:	c0200737          	lui	a4,0xc0200
ffffffffc0202166:	60e6e863          	bltu	a3,a4,ffffffffc0202776 <pmm_init+0x6f4>
ffffffffc020216a:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc020216e:	4645                	li	a2,17
ffffffffc0202170:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR(page_end);
ffffffffc0202172:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0202174:	4ac6e563          	bltu	a3,a2,ffffffffc020261e <pmm_init+0x59c>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202178:	00003517          	auipc	a0,0x3
ffffffffc020217c:	7a050513          	addi	a0,a0,1952 # ffffffffc0205918 <buddy_system_pmm_manager+0x3a0>
ffffffffc0202180:	800fe0ef          	jal	ra,ffffffffc0200180 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202184:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202188:	00013917          	auipc	s2,0x13
ffffffffc020218c:	4b890913          	addi	s2,s2,1208 # ffffffffc0215640 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202190:	7b9c                	ld	a5,48(a5)
ffffffffc0202192:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202194:	00003517          	auipc	a0,0x3
ffffffffc0202198:	79c50513          	addi	a0,a0,1948 # ffffffffc0205930 <buddy_system_pmm_manager+0x3b8>
ffffffffc020219c:	fe5fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02021a0:	00007697          	auipc	a3,0x7
ffffffffc02021a4:	e6068693          	addi	a3,a3,-416 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc02021a8:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02021ac:	c02007b7          	lui	a5,0xc0200
ffffffffc02021b0:	5cf6ef63          	bltu	a3,a5,ffffffffc020278e <pmm_init+0x70c>
ffffffffc02021b4:	0009b783          	ld	a5,0(s3)
ffffffffc02021b8:	8e9d                	sub	a3,a3,a5
ffffffffc02021ba:	00013797          	auipc	a5,0x13
ffffffffc02021be:	46d7bf23          	sd	a3,1150(a5) # ffffffffc0215638 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02021c2:	100027f3          	csrr	a5,sstatus
ffffffffc02021c6:	8b89                	andi	a5,a5,2
ffffffffc02021c8:	48079563          	bnez	a5,ffffffffc0202652 <pmm_init+0x5d0>
        ret = pmm_manager->nr_free_pages();
ffffffffc02021cc:	000bb783          	ld	a5,0(s7)
ffffffffc02021d0:	779c                	ld	a5,40(a5)
ffffffffc02021d2:	9782                	jalr	a5
ffffffffc02021d4:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02021d6:	6098                	ld	a4,0(s1)
ffffffffc02021d8:	c80007b7          	lui	a5,0xc8000
ffffffffc02021dc:	83b1                	srli	a5,a5,0xc
ffffffffc02021de:	5ee7e463          	bltu	a5,a4,ffffffffc02027c6 <pmm_init+0x744>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02021e2:	00093503          	ld	a0,0(s2)
ffffffffc02021e6:	5c050063          	beqz	a0,ffffffffc02027a6 <pmm_init+0x724>
ffffffffc02021ea:	03451793          	slli	a5,a0,0x34
ffffffffc02021ee:	5a079c63          	bnez	a5,ffffffffc02027a6 <pmm_init+0x724>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02021f2:	4601                	li	a2,0
ffffffffc02021f4:	4581                	li	a1,0
ffffffffc02021f6:	ca7ff0ef          	jal	ra,ffffffffc0201e9c <get_page>
ffffffffc02021fa:	62051863          	bnez	a0,ffffffffc020282a <pmm_init+0x7a8>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02021fe:	4505                	li	a0,1
ffffffffc0202200:	9bfff0ef          	jal	ra,ffffffffc0201bbe <alloc_pages>
ffffffffc0202204:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202206:	00093503          	ld	a0,0(s2)
ffffffffc020220a:	4681                	li	a3,0
ffffffffc020220c:	4601                	li	a2,0
ffffffffc020220e:	85d2                	mv	a1,s4
ffffffffc0202210:	d7dff0ef          	jal	ra,ffffffffc0201f8c <page_insert>
ffffffffc0202214:	5e051b63          	bnez	a0,ffffffffc020280a <pmm_init+0x788>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202218:	00093503          	ld	a0,0(s2)
ffffffffc020221c:	4601                	li	a2,0
ffffffffc020221e:	4581                	li	a1,0
ffffffffc0202220:	aabff0ef          	jal	ra,ffffffffc0201cca <get_pte>
ffffffffc0202224:	5c050363          	beqz	a0,ffffffffc02027ea <pmm_init+0x768>
    assert(pte2page(*ptep) == p1);
ffffffffc0202228:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020222a:	0017f713          	andi	a4,a5,1
ffffffffc020222e:	5a070c63          	beqz	a4,ffffffffc02027e6 <pmm_init+0x764>
    if (PPN(pa) >= npage) {
ffffffffc0202232:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202234:	078a                	slli	a5,a5,0x2
ffffffffc0202236:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202238:	52e7fd63          	bgeu	a5,a4,ffffffffc0202772 <pmm_init+0x6f0>
    return &pages[PPN(pa) - nbase];
ffffffffc020223c:	000b3683          	ld	a3,0(s6)
ffffffffc0202240:	fff80637          	lui	a2,0xfff80
ffffffffc0202244:	97b2                	add	a5,a5,a2
ffffffffc0202246:	079a                	slli	a5,a5,0x6
ffffffffc0202248:	97b6                	add	a5,a5,a3
ffffffffc020224a:	10fa19e3          	bne	s4,a5,ffffffffc0202b5c <pmm_init+0xada>
    assert(page_ref(p1) == 1);
ffffffffc020224e:	000a2683          	lw	a3,0(s4)
ffffffffc0202252:	4785                	li	a5,1
ffffffffc0202254:	14f690e3          	bne	a3,a5,ffffffffc0202b94 <pmm_init+0xb12>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202258:	00093503          	ld	a0,0(s2)
ffffffffc020225c:	77fd                	lui	a5,0xfffff
ffffffffc020225e:	6114                	ld	a3,0(a0)
ffffffffc0202260:	068a                	slli	a3,a3,0x2
ffffffffc0202262:	8efd                	and	a3,a3,a5
ffffffffc0202264:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202268:	10e67ae3          	bgeu	a2,a4,ffffffffc0202b7c <pmm_init+0xafa>
ffffffffc020226c:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202270:	96e2                	add	a3,a3,s8
ffffffffc0202272:	0006ba83          	ld	s5,0(a3)
ffffffffc0202276:	0a8a                	slli	s5,s5,0x2
ffffffffc0202278:	00fafab3          	and	s5,s5,a5
ffffffffc020227c:	00cad793          	srli	a5,s5,0xc
ffffffffc0202280:	62e7f563          	bgeu	a5,a4,ffffffffc02028aa <pmm_init+0x828>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202284:	4601                	li	a2,0
ffffffffc0202286:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202288:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020228a:	a41ff0ef          	jal	ra,ffffffffc0201cca <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020228e:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202290:	5f551d63          	bne	a0,s5,ffffffffc020288a <pmm_init+0x808>

    p2 = alloc_page();
ffffffffc0202294:	4505                	li	a0,1
ffffffffc0202296:	929ff0ef          	jal	ra,ffffffffc0201bbe <alloc_pages>
ffffffffc020229a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020229c:	00093503          	ld	a0,0(s2)
ffffffffc02022a0:	46d1                	li	a3,20
ffffffffc02022a2:	6605                	lui	a2,0x1
ffffffffc02022a4:	85d6                	mv	a1,s5
ffffffffc02022a6:	ce7ff0ef          	jal	ra,ffffffffc0201f8c <page_insert>
ffffffffc02022aa:	5a051063          	bnez	a0,ffffffffc020284a <pmm_init+0x7c8>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02022ae:	00093503          	ld	a0,0(s2)
ffffffffc02022b2:	4601                	li	a2,0
ffffffffc02022b4:	6585                	lui	a1,0x1
ffffffffc02022b6:	a15ff0ef          	jal	ra,ffffffffc0201cca <get_pte>
ffffffffc02022ba:	0e050de3          	beqz	a0,ffffffffc0202bb4 <pmm_init+0xb32>
    assert(*ptep & PTE_U);
ffffffffc02022be:	611c                	ld	a5,0(a0)
ffffffffc02022c0:	0107f713          	andi	a4,a5,16
ffffffffc02022c4:	70070063          	beqz	a4,ffffffffc02029c4 <pmm_init+0x942>
    assert(*ptep & PTE_W);
ffffffffc02022c8:	8b91                	andi	a5,a5,4
ffffffffc02022ca:	6a078d63          	beqz	a5,ffffffffc0202984 <pmm_init+0x902>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02022ce:	00093503          	ld	a0,0(s2)
ffffffffc02022d2:	611c                	ld	a5,0(a0)
ffffffffc02022d4:	8bc1                	andi	a5,a5,16
ffffffffc02022d6:	68078763          	beqz	a5,ffffffffc0202964 <pmm_init+0x8e2>
    assert(page_ref(p2) == 1);
ffffffffc02022da:	000aa703          	lw	a4,0(s5)
ffffffffc02022de:	4785                	li	a5,1
ffffffffc02022e0:	58f71563          	bne	a4,a5,ffffffffc020286a <pmm_init+0x7e8>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02022e4:	4681                	li	a3,0
ffffffffc02022e6:	6605                	lui	a2,0x1
ffffffffc02022e8:	85d2                	mv	a1,s4
ffffffffc02022ea:	ca3ff0ef          	jal	ra,ffffffffc0201f8c <page_insert>
ffffffffc02022ee:	62051b63          	bnez	a0,ffffffffc0202924 <pmm_init+0x8a2>
    assert(page_ref(p1) == 2);
ffffffffc02022f2:	000a2703          	lw	a4,0(s4)
ffffffffc02022f6:	4789                	li	a5,2
ffffffffc02022f8:	60f71663          	bne	a4,a5,ffffffffc0202904 <pmm_init+0x882>
    assert(page_ref(p2) == 0);
ffffffffc02022fc:	000aa783          	lw	a5,0(s5)
ffffffffc0202300:	5e079263          	bnez	a5,ffffffffc02028e4 <pmm_init+0x862>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202304:	00093503          	ld	a0,0(s2)
ffffffffc0202308:	4601                	li	a2,0
ffffffffc020230a:	6585                	lui	a1,0x1
ffffffffc020230c:	9bfff0ef          	jal	ra,ffffffffc0201cca <get_pte>
ffffffffc0202310:	5a050a63          	beqz	a0,ffffffffc02028c4 <pmm_init+0x842>
    assert(pte2page(*ptep) == p1);
ffffffffc0202314:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202316:	00177793          	andi	a5,a4,1
ffffffffc020231a:	4c078663          	beqz	a5,ffffffffc02027e6 <pmm_init+0x764>
    if (PPN(pa) >= npage) {
ffffffffc020231e:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202320:	00271793          	slli	a5,a4,0x2
ffffffffc0202324:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202326:	44d7f663          	bgeu	a5,a3,ffffffffc0202772 <pmm_init+0x6f0>
    return &pages[PPN(pa) - nbase];
ffffffffc020232a:	000b3683          	ld	a3,0(s6)
ffffffffc020232e:	fff80637          	lui	a2,0xfff80
ffffffffc0202332:	97b2                	add	a5,a5,a2
ffffffffc0202334:	079a                	slli	a5,a5,0x6
ffffffffc0202336:	97b6                	add	a5,a5,a3
ffffffffc0202338:	6efa1663          	bne	s4,a5,ffffffffc0202a24 <pmm_init+0x9a2>
    assert((*ptep & PTE_U) == 0);
ffffffffc020233c:	8b41                	andi	a4,a4,16
ffffffffc020233e:	6c071363          	bnez	a4,ffffffffc0202a04 <pmm_init+0x982>

    page_remove(boot_pgdir, 0x0);
ffffffffc0202342:	00093503          	ld	a0,0(s2)
ffffffffc0202346:	4581                	li	a1,0
ffffffffc0202348:	ba9ff0ef          	jal	ra,ffffffffc0201ef0 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020234c:	000a2703          	lw	a4,0(s4)
ffffffffc0202350:	4785                	li	a5,1
ffffffffc0202352:	68f71963          	bne	a4,a5,ffffffffc02029e4 <pmm_init+0x962>
    assert(page_ref(p2) == 0);
ffffffffc0202356:	000aa783          	lw	a5,0(s5)
ffffffffc020235a:	76079163          	bnez	a5,ffffffffc0202abc <pmm_init+0xa3a>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020235e:	00093503          	ld	a0,0(s2)
ffffffffc0202362:	6585                	lui	a1,0x1
ffffffffc0202364:	b8dff0ef          	jal	ra,ffffffffc0201ef0 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202368:	000a2783          	lw	a5,0(s4)
ffffffffc020236c:	72079863          	bnez	a5,ffffffffc0202a9c <pmm_init+0xa1a>
    assert(page_ref(p2) == 0);
ffffffffc0202370:	000aa783          	lw	a5,0(s5)
ffffffffc0202374:	70079463          	bnez	a5,ffffffffc0202a7c <pmm_init+0x9fa>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202378:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020237c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020237e:	000a3683          	ld	a3,0(s4)
ffffffffc0202382:	068a                	slli	a3,a3,0x2
ffffffffc0202384:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202386:	3ee6f663          	bgeu	a3,a4,ffffffffc0202772 <pmm_init+0x6f0>
    return &pages[PPN(pa) - nbase];
ffffffffc020238a:	fff807b7          	lui	a5,0xfff80
ffffffffc020238e:	000b3503          	ld	a0,0(s6)
ffffffffc0202392:	96be                	add	a3,a3,a5
ffffffffc0202394:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0202396:	00d507b3          	add	a5,a0,a3
ffffffffc020239a:	4390                	lw	a2,0(a5)
ffffffffc020239c:	4785                	li	a5,1
ffffffffc020239e:	6af61f63          	bne	a2,a5,ffffffffc0202a5c <pmm_init+0x9da>
    return page - pages + nbase;
ffffffffc02023a2:	8699                	srai	a3,a3,0x6
ffffffffc02023a4:	000805b7          	lui	a1,0x80
ffffffffc02023a8:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc02023aa:	00c69613          	slli	a2,a3,0xc
ffffffffc02023ae:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02023b0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023b2:	68e67963          	bgeu	a2,a4,ffffffffc0202a44 <pmm_init+0x9c2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02023b6:	0009b603          	ld	a2,0(s3)
ffffffffc02023ba:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc02023bc:	629c                	ld	a5,0(a3)
ffffffffc02023be:	078a                	slli	a5,a5,0x2
ffffffffc02023c0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023c2:	3ae7f863          	bgeu	a5,a4,ffffffffc0202772 <pmm_init+0x6f0>
    return &pages[PPN(pa) - nbase];
ffffffffc02023c6:	8f8d                	sub	a5,a5,a1
ffffffffc02023c8:	079a                	slli	a5,a5,0x6
ffffffffc02023ca:	953e                	add	a0,a0,a5
ffffffffc02023cc:	100027f3          	csrr	a5,sstatus
ffffffffc02023d0:	8b89                	andi	a5,a5,2
ffffffffc02023d2:	2c079a63          	bnez	a5,ffffffffc02026a6 <pmm_init+0x624>
        pmm_manager->free_pages(base, n);
ffffffffc02023d6:	000bb783          	ld	a5,0(s7)
ffffffffc02023da:	4585                	li	a1,1
ffffffffc02023dc:	739c                	ld	a5,32(a5)
ffffffffc02023de:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02023e0:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02023e4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023e6:	078a                	slli	a5,a5,0x2
ffffffffc02023e8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023ea:	38e7f463          	bgeu	a5,a4,ffffffffc0202772 <pmm_init+0x6f0>
    return &pages[PPN(pa) - nbase];
ffffffffc02023ee:	000b3503          	ld	a0,0(s6)
ffffffffc02023f2:	fff80737          	lui	a4,0xfff80
ffffffffc02023f6:	97ba                	add	a5,a5,a4
ffffffffc02023f8:	079a                	slli	a5,a5,0x6
ffffffffc02023fa:	953e                	add	a0,a0,a5
ffffffffc02023fc:	100027f3          	csrr	a5,sstatus
ffffffffc0202400:	8b89                	andi	a5,a5,2
ffffffffc0202402:	28079663          	bnez	a5,ffffffffc020268e <pmm_init+0x60c>
ffffffffc0202406:	000bb783          	ld	a5,0(s7)
ffffffffc020240a:	4585                	li	a1,1
ffffffffc020240c:	739c                	ld	a5,32(a5)
ffffffffc020240e:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202410:	00093783          	ld	a5,0(s2)
ffffffffc0202414:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fd6a954>
  asm volatile("sfence.vma");
ffffffffc0202418:	12000073          	sfence.vma
ffffffffc020241c:	100027f3          	csrr	a5,sstatus
ffffffffc0202420:	8b89                	andi	a5,a5,2
ffffffffc0202422:	24079c63          	bnez	a5,ffffffffc020267a <pmm_init+0x5f8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202426:	000bb783          	ld	a5,0(s7)
ffffffffc020242a:	779c                	ld	a5,40(a5)
ffffffffc020242c:	9782                	jalr	a5
ffffffffc020242e:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202430:	71441663          	bne	s0,s4,ffffffffc0202b3c <pmm_init+0xaba>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202434:	00003517          	auipc	a0,0x3
ffffffffc0202438:	7e450513          	addi	a0,a0,2020 # ffffffffc0205c18 <buddy_system_pmm_manager+0x6a0>
ffffffffc020243c:	d45fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202440:	100027f3          	csrr	a5,sstatus
ffffffffc0202444:	8b89                	andi	a5,a5,2
ffffffffc0202446:	22079063          	bnez	a5,ffffffffc0202666 <pmm_init+0x5e4>
        ret = pmm_manager->nr_free_pages();
ffffffffc020244a:	000bb783          	ld	a5,0(s7)
ffffffffc020244e:	779c                	ld	a5,40(a5)
ffffffffc0202450:	9782                	jalr	a5
ffffffffc0202452:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202454:	6098                	ld	a4,0(s1)
ffffffffc0202456:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020245a:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020245c:	00c71793          	slli	a5,a4,0xc
ffffffffc0202460:	6a05                	lui	s4,0x1
ffffffffc0202462:	02f47c63          	bgeu	s0,a5,ffffffffc020249a <pmm_init+0x418>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202466:	00c45793          	srli	a5,s0,0xc
ffffffffc020246a:	00093503          	ld	a0,0(s2)
ffffffffc020246e:	2ee7f563          	bgeu	a5,a4,ffffffffc0202758 <pmm_init+0x6d6>
ffffffffc0202472:	0009b583          	ld	a1,0(s3)
ffffffffc0202476:	4601                	li	a2,0
ffffffffc0202478:	95a2                	add	a1,a1,s0
ffffffffc020247a:	851ff0ef          	jal	ra,ffffffffc0201cca <get_pte>
ffffffffc020247e:	2a050d63          	beqz	a0,ffffffffc0202738 <pmm_init+0x6b6>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202482:	611c                	ld	a5,0(a0)
ffffffffc0202484:	078a                	slli	a5,a5,0x2
ffffffffc0202486:	0157f7b3          	and	a5,a5,s5
ffffffffc020248a:	28879763          	bne	a5,s0,ffffffffc0202718 <pmm_init+0x696>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020248e:	6098                	ld	a4,0(s1)
ffffffffc0202490:	9452                	add	s0,s0,s4
ffffffffc0202492:	00c71793          	slli	a5,a4,0xc
ffffffffc0202496:	fcf468e3          	bltu	s0,a5,ffffffffc0202466 <pmm_init+0x3e4>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc020249a:	00093783          	ld	a5,0(s2)
ffffffffc020249e:	639c                	ld	a5,0(a5)
ffffffffc02024a0:	66079e63          	bnez	a5,ffffffffc0202b1c <pmm_init+0xa9a>

    struct Page *p;
    p = alloc_page();
ffffffffc02024a4:	4505                	li	a0,1
ffffffffc02024a6:	f18ff0ef          	jal	ra,ffffffffc0201bbe <alloc_pages>
ffffffffc02024aa:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02024ac:	00093503          	ld	a0,0(s2)
ffffffffc02024b0:	4699                	li	a3,6
ffffffffc02024b2:	10000613          	li	a2,256
ffffffffc02024b6:	85d6                	mv	a1,s5
ffffffffc02024b8:	ad5ff0ef          	jal	ra,ffffffffc0201f8c <page_insert>
ffffffffc02024bc:	64051063          	bnez	a0,ffffffffc0202afc <pmm_init+0xa7a>
    assert(page_ref(p) == 1);
ffffffffc02024c0:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fde9954>
ffffffffc02024c4:	4785                	li	a5,1
ffffffffc02024c6:	60f71b63          	bne	a4,a5,ffffffffc0202adc <pmm_init+0xa5a>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02024ca:	00093503          	ld	a0,0(s2)
ffffffffc02024ce:	6405                	lui	s0,0x1
ffffffffc02024d0:	4699                	li	a3,6
ffffffffc02024d2:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc02024d6:	85d6                	mv	a1,s5
ffffffffc02024d8:	ab5ff0ef          	jal	ra,ffffffffc0201f8c <page_insert>
ffffffffc02024dc:	46051463          	bnez	a0,ffffffffc0202944 <pmm_init+0x8c2>
    assert(page_ref(p) == 2);
ffffffffc02024e0:	000aa703          	lw	a4,0(s5)
ffffffffc02024e4:	4789                	li	a5,2
ffffffffc02024e6:	72f71763          	bne	a4,a5,ffffffffc0202c14 <pmm_init+0xb92>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02024ea:	00004597          	auipc	a1,0x4
ffffffffc02024ee:	86658593          	addi	a1,a1,-1946 # ffffffffc0205d50 <buddy_system_pmm_manager+0x7d8>
ffffffffc02024f2:	10000513          	li	a0,256
ffffffffc02024f6:	30e020ef          	jal	ra,ffffffffc0204804 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02024fa:	10040593          	addi	a1,s0,256
ffffffffc02024fe:	10000513          	li	a0,256
ffffffffc0202502:	314020ef          	jal	ra,ffffffffc0204816 <strcmp>
ffffffffc0202506:	6e051763          	bnez	a0,ffffffffc0202bf4 <pmm_init+0xb72>
    return page - pages + nbase;
ffffffffc020250a:	000b3683          	ld	a3,0(s6)
ffffffffc020250e:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202512:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0202514:	40da86b3          	sub	a3,s5,a3
ffffffffc0202518:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020251a:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc020251c:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020251e:	8031                	srli	s0,s0,0xc
ffffffffc0202520:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202524:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202526:	50f77f63          	bgeu	a4,a5,ffffffffc0202a44 <pmm_init+0x9c2>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020252a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020252e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202532:	96be                	add	a3,a3,a5
ffffffffc0202534:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202538:	296020ef          	jal	ra,ffffffffc02047ce <strlen>
ffffffffc020253c:	68051c63          	bnez	a0,ffffffffc0202bd4 <pmm_init+0xb52>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202540:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202544:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202546:	000a3683          	ld	a3,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc020254a:	068a                	slli	a3,a3,0x2
ffffffffc020254c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020254e:	22f6f263          	bgeu	a3,a5,ffffffffc0202772 <pmm_init+0x6f0>
    return KADDR(page2pa(page));
ffffffffc0202552:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202554:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202556:	4ef47763          	bgeu	s0,a5,ffffffffc0202a44 <pmm_init+0x9c2>
ffffffffc020255a:	0009b403          	ld	s0,0(s3)
ffffffffc020255e:	9436                	add	s0,s0,a3
ffffffffc0202560:	100027f3          	csrr	a5,sstatus
ffffffffc0202564:	8b89                	andi	a5,a5,2
ffffffffc0202566:	18079e63          	bnez	a5,ffffffffc0202702 <pmm_init+0x680>
        pmm_manager->free_pages(base, n);
ffffffffc020256a:	000bb783          	ld	a5,0(s7)
ffffffffc020256e:	4585                	li	a1,1
ffffffffc0202570:	8556                	mv	a0,s5
ffffffffc0202572:	739c                	ld	a5,32(a5)
ffffffffc0202574:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202576:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202578:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020257a:	078a                	slli	a5,a5,0x2
ffffffffc020257c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020257e:	1ee7fa63          	bgeu	a5,a4,ffffffffc0202772 <pmm_init+0x6f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202582:	000b3503          	ld	a0,0(s6)
ffffffffc0202586:	fff80737          	lui	a4,0xfff80
ffffffffc020258a:	97ba                	add	a5,a5,a4
ffffffffc020258c:	079a                	slli	a5,a5,0x6
ffffffffc020258e:	953e                	add	a0,a0,a5
ffffffffc0202590:	100027f3          	csrr	a5,sstatus
ffffffffc0202594:	8b89                	andi	a5,a5,2
ffffffffc0202596:	14079a63          	bnez	a5,ffffffffc02026ea <pmm_init+0x668>
ffffffffc020259a:	000bb783          	ld	a5,0(s7)
ffffffffc020259e:	4585                	li	a1,1
ffffffffc02025a0:	739c                	ld	a5,32(a5)
ffffffffc02025a2:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02025a4:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02025a8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02025aa:	078a                	slli	a5,a5,0x2
ffffffffc02025ac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025ae:	1ce7f263          	bgeu	a5,a4,ffffffffc0202772 <pmm_init+0x6f0>
    return &pages[PPN(pa) - nbase];
ffffffffc02025b2:	000b3503          	ld	a0,0(s6)
ffffffffc02025b6:	fff80737          	lui	a4,0xfff80
ffffffffc02025ba:	97ba                	add	a5,a5,a4
ffffffffc02025bc:	079a                	slli	a5,a5,0x6
ffffffffc02025be:	953e                	add	a0,a0,a5
ffffffffc02025c0:	100027f3          	csrr	a5,sstatus
ffffffffc02025c4:	8b89                	andi	a5,a5,2
ffffffffc02025c6:	10079663          	bnez	a5,ffffffffc02026d2 <pmm_init+0x650>
ffffffffc02025ca:	000bb783          	ld	a5,0(s7)
ffffffffc02025ce:	4585                	li	a1,1
ffffffffc02025d0:	739c                	ld	a5,32(a5)
ffffffffc02025d2:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02025d4:	00093783          	ld	a5,0(s2)
ffffffffc02025d8:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02025dc:	12000073          	sfence.vma
ffffffffc02025e0:	100027f3          	csrr	a5,sstatus
ffffffffc02025e4:	8b89                	andi	a5,a5,2
ffffffffc02025e6:	0c079c63          	bnez	a5,ffffffffc02026be <pmm_init+0x63c>
        ret = pmm_manager->nr_free_pages();
ffffffffc02025ea:	000bb783          	ld	a5,0(s7)
ffffffffc02025ee:	779c                	ld	a5,40(a5)
ffffffffc02025f0:	9782                	jalr	a5
ffffffffc02025f2:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02025f4:	3a8c1863          	bne	s8,s0,ffffffffc02029a4 <pmm_init+0x922>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02025f8:	00003517          	auipc	a0,0x3
ffffffffc02025fc:	7d050513          	addi	a0,a0,2000 # ffffffffc0205dc8 <buddy_system_pmm_manager+0x850>
ffffffffc0202600:	b81fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0202604:	6446                	ld	s0,80(sp)
ffffffffc0202606:	60e6                	ld	ra,88(sp)
ffffffffc0202608:	64a6                	ld	s1,72(sp)
ffffffffc020260a:	6906                	ld	s2,64(sp)
ffffffffc020260c:	79e2                	ld	s3,56(sp)
ffffffffc020260e:	7a42                	ld	s4,48(sp)
ffffffffc0202610:	7aa2                	ld	s5,40(sp)
ffffffffc0202612:	7b02                	ld	s6,32(sp)
ffffffffc0202614:	6be2                	ld	s7,24(sp)
ffffffffc0202616:	6c42                	ld	s8,16(sp)
ffffffffc0202618:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc020261a:	d54ff06f          	j	ffffffffc0201b6e <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020261e:	6705                	lui	a4,0x1
ffffffffc0202620:	177d                	addi	a4,a4,-1
ffffffffc0202622:	96ba                	add	a3,a3,a4
ffffffffc0202624:	777d                	lui	a4,0xfffff
ffffffffc0202626:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc0202628:	00c75693          	srli	a3,a4,0xc
ffffffffc020262c:	14f6f363          	bgeu	a3,a5,ffffffffc0202772 <pmm_init+0x6f0>
    pmm_manager->init_memmap(base, n);
ffffffffc0202630:	000bb583          	ld	a1,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0202634:	000b3503          	ld	a0,0(s6)
ffffffffc0202638:	010687b3          	add	a5,a3,a6
ffffffffc020263c:	6994                	ld	a3,16(a1)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020263e:	40e60733          	sub	a4,a2,a4
ffffffffc0202642:	079a                	slli	a5,a5,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202644:	00c75593          	srli	a1,a4,0xc
ffffffffc0202648:	953e                	add	a0,a0,a5
ffffffffc020264a:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc020264c:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202650:	b625                	j	ffffffffc0202178 <pmm_init+0xf6>
        intr_disable();
ffffffffc0202652:	f71fd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202656:	000bb783          	ld	a5,0(s7)
ffffffffc020265a:	779c                	ld	a5,40(a5)
ffffffffc020265c:	9782                	jalr	a5
ffffffffc020265e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202660:	f5dfd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202664:	be8d                	j	ffffffffc02021d6 <pmm_init+0x154>
        intr_disable();
ffffffffc0202666:	f5dfd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc020266a:	000bb783          	ld	a5,0(s7)
ffffffffc020266e:	779c                	ld	a5,40(a5)
ffffffffc0202670:	9782                	jalr	a5
ffffffffc0202672:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202674:	f49fd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202678:	bbf1                	j	ffffffffc0202454 <pmm_init+0x3d2>
        intr_disable();
ffffffffc020267a:	f49fd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc020267e:	000bb783          	ld	a5,0(s7)
ffffffffc0202682:	779c                	ld	a5,40(a5)
ffffffffc0202684:	9782                	jalr	a5
ffffffffc0202686:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202688:	f35fd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc020268c:	b355                	j	ffffffffc0202430 <pmm_init+0x3ae>
ffffffffc020268e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202690:	f33fd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202694:	000bb783          	ld	a5,0(s7)
ffffffffc0202698:	6522                	ld	a0,8(sp)
ffffffffc020269a:	4585                	li	a1,1
ffffffffc020269c:	739c                	ld	a5,32(a5)
ffffffffc020269e:	9782                	jalr	a5
        intr_enable();
ffffffffc02026a0:	f1dfd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02026a4:	b3b5                	j	ffffffffc0202410 <pmm_init+0x38e>
ffffffffc02026a6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02026a8:	f1bfd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc02026ac:	000bb783          	ld	a5,0(s7)
ffffffffc02026b0:	6522                	ld	a0,8(sp)
ffffffffc02026b2:	4585                	li	a1,1
ffffffffc02026b4:	739c                	ld	a5,32(a5)
ffffffffc02026b6:	9782                	jalr	a5
        intr_enable();
ffffffffc02026b8:	f05fd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02026bc:	b315                	j	ffffffffc02023e0 <pmm_init+0x35e>
        intr_disable();
ffffffffc02026be:	f05fd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02026c2:	000bb783          	ld	a5,0(s7)
ffffffffc02026c6:	779c                	ld	a5,40(a5)
ffffffffc02026c8:	9782                	jalr	a5
ffffffffc02026ca:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02026cc:	ef1fd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02026d0:	b715                	j	ffffffffc02025f4 <pmm_init+0x572>
ffffffffc02026d2:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02026d4:	eeffd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02026d8:	000bb783          	ld	a5,0(s7)
ffffffffc02026dc:	6522                	ld	a0,8(sp)
ffffffffc02026de:	4585                	li	a1,1
ffffffffc02026e0:	739c                	ld	a5,32(a5)
ffffffffc02026e2:	9782                	jalr	a5
        intr_enable();
ffffffffc02026e4:	ed9fd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc02026e8:	b5f5                	j	ffffffffc02025d4 <pmm_init+0x552>
ffffffffc02026ea:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02026ec:	ed7fd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc02026f0:	000bb783          	ld	a5,0(s7)
ffffffffc02026f4:	6522                	ld	a0,8(sp)
ffffffffc02026f6:	4585                	li	a1,1
ffffffffc02026f8:	739c                	ld	a5,32(a5)
ffffffffc02026fa:	9782                	jalr	a5
        intr_enable();
ffffffffc02026fc:	ec1fd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202700:	b555                	j	ffffffffc02025a4 <pmm_init+0x522>
        intr_disable();
ffffffffc0202702:	ec1fd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
ffffffffc0202706:	000bb783          	ld	a5,0(s7)
ffffffffc020270a:	4585                	li	a1,1
ffffffffc020270c:	8556                	mv	a0,s5
ffffffffc020270e:	739c                	ld	a5,32(a5)
ffffffffc0202710:	9782                	jalr	a5
        intr_enable();
ffffffffc0202712:	eabfd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202716:	b585                	j	ffffffffc0202576 <pmm_init+0x4f4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202718:	00003697          	auipc	a3,0x3
ffffffffc020271c:	56068693          	addi	a3,a3,1376 # ffffffffc0205c78 <buddy_system_pmm_manager+0x700>
ffffffffc0202720:	00003617          	auipc	a2,0x3
ffffffffc0202724:	bd060613          	addi	a2,a2,-1072 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202728:	1af00593          	li	a1,431
ffffffffc020272c:	00003517          	auipc	a0,0x3
ffffffffc0202730:	18450513          	addi	a0,a0,388 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202734:	d13fd0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202738:	00003697          	auipc	a3,0x3
ffffffffc020273c:	50068693          	addi	a3,a3,1280 # ffffffffc0205c38 <buddy_system_pmm_manager+0x6c0>
ffffffffc0202740:	00003617          	auipc	a2,0x3
ffffffffc0202744:	bb060613          	addi	a2,a2,-1104 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202748:	1ae00593          	li	a1,430
ffffffffc020274c:	00003517          	auipc	a0,0x3
ffffffffc0202750:	16450513          	addi	a0,a0,356 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202754:	cf3fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202758:	86a2                	mv	a3,s0
ffffffffc020275a:	00003617          	auipc	a2,0x3
ffffffffc020275e:	e6e60613          	addi	a2,a2,-402 # ffffffffc02055c8 <buddy_system_pmm_manager+0x50>
ffffffffc0202762:	1ae00593          	li	a1,430
ffffffffc0202766:	00003517          	auipc	a0,0x3
ffffffffc020276a:	14a50513          	addi	a0,a0,330 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc020276e:	cd9fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202772:	c14ff0ef          	jal	ra,ffffffffc0201b86 <pa2page.part.0>
    uintptr_t freemem = PADDR(page_end);
ffffffffc0202776:	00003617          	auipc	a2,0x3
ffffffffc020277a:	eea60613          	addi	a2,a2,-278 # ffffffffc0205660 <buddy_system_pmm_manager+0xe8>
ffffffffc020277e:	08e00593          	li	a1,142
ffffffffc0202782:	00003517          	auipc	a0,0x3
ffffffffc0202786:	12e50513          	addi	a0,a0,302 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc020278a:	cbdfd0ef          	jal	ra,ffffffffc0200446 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020278e:	00003617          	auipc	a2,0x3
ffffffffc0202792:	ed260613          	addi	a2,a2,-302 # ffffffffc0205660 <buddy_system_pmm_manager+0xe8>
ffffffffc0202796:	0d400593          	li	a1,212
ffffffffc020279a:	00003517          	auipc	a0,0x3
ffffffffc020279e:	11650513          	addi	a0,a0,278 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc02027a2:	ca5fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02027a6:	00003697          	auipc	a3,0x3
ffffffffc02027aa:	1ca68693          	addi	a3,a3,458 # ffffffffc0205970 <buddy_system_pmm_manager+0x3f8>
ffffffffc02027ae:	00003617          	auipc	a2,0x3
ffffffffc02027b2:	b4260613          	addi	a2,a2,-1214 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02027b6:	17200593          	li	a1,370
ffffffffc02027ba:	00003517          	auipc	a0,0x3
ffffffffc02027be:	0f650513          	addi	a0,a0,246 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc02027c2:	c85fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02027c6:	00003697          	auipc	a3,0x3
ffffffffc02027ca:	18a68693          	addi	a3,a3,394 # ffffffffc0205950 <buddy_system_pmm_manager+0x3d8>
ffffffffc02027ce:	00003617          	auipc	a2,0x3
ffffffffc02027d2:	b2260613          	addi	a2,a2,-1246 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02027d6:	17100593          	li	a1,369
ffffffffc02027da:	00003517          	auipc	a0,0x3
ffffffffc02027de:	0d650513          	addi	a0,a0,214 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc02027e2:	c65fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02027e6:	bbcff0ef          	jal	ra,ffffffffc0201ba2 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02027ea:	00003697          	auipc	a3,0x3
ffffffffc02027ee:	21668693          	addi	a3,a3,534 # ffffffffc0205a00 <buddy_system_pmm_manager+0x488>
ffffffffc02027f2:	00003617          	auipc	a2,0x3
ffffffffc02027f6:	afe60613          	addi	a2,a2,-1282 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02027fa:	17a00593          	li	a1,378
ffffffffc02027fe:	00003517          	auipc	a0,0x3
ffffffffc0202802:	0b250513          	addi	a0,a0,178 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202806:	c41fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020280a:	00003697          	auipc	a3,0x3
ffffffffc020280e:	1c668693          	addi	a3,a3,454 # ffffffffc02059d0 <buddy_system_pmm_manager+0x458>
ffffffffc0202812:	00003617          	auipc	a2,0x3
ffffffffc0202816:	ade60613          	addi	a2,a2,-1314 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc020281a:	17700593          	li	a1,375
ffffffffc020281e:	00003517          	auipc	a0,0x3
ffffffffc0202822:	09250513          	addi	a0,a0,146 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202826:	c21fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020282a:	00003697          	auipc	a3,0x3
ffffffffc020282e:	17e68693          	addi	a3,a3,382 # ffffffffc02059a8 <buddy_system_pmm_manager+0x430>
ffffffffc0202832:	00003617          	auipc	a2,0x3
ffffffffc0202836:	abe60613          	addi	a2,a2,-1346 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc020283a:	17300593          	li	a1,371
ffffffffc020283e:	00003517          	auipc	a0,0x3
ffffffffc0202842:	07250513          	addi	a0,a0,114 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202846:	c01fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020284a:	00003697          	auipc	a3,0x3
ffffffffc020284e:	23e68693          	addi	a3,a3,574 # ffffffffc0205a88 <buddy_system_pmm_manager+0x510>
ffffffffc0202852:	00003617          	auipc	a2,0x3
ffffffffc0202856:	a9e60613          	addi	a2,a2,-1378 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc020285a:	18300593          	li	a1,387
ffffffffc020285e:	00003517          	auipc	a0,0x3
ffffffffc0202862:	05250513          	addi	a0,a0,82 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202866:	be1fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020286a:	00003697          	auipc	a3,0x3
ffffffffc020286e:	2be68693          	addi	a3,a3,702 # ffffffffc0205b28 <buddy_system_pmm_manager+0x5b0>
ffffffffc0202872:	00003617          	auipc	a2,0x3
ffffffffc0202876:	a7e60613          	addi	a2,a2,-1410 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc020287a:	18800593          	li	a1,392
ffffffffc020287e:	00003517          	auipc	a0,0x3
ffffffffc0202882:	03250513          	addi	a0,a0,50 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202886:	bc1fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020288a:	00003697          	auipc	a3,0x3
ffffffffc020288e:	1d668693          	addi	a3,a3,470 # ffffffffc0205a60 <buddy_system_pmm_manager+0x4e8>
ffffffffc0202892:	00003617          	auipc	a2,0x3
ffffffffc0202896:	a5e60613          	addi	a2,a2,-1442 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc020289a:	18000593          	li	a1,384
ffffffffc020289e:	00003517          	auipc	a0,0x3
ffffffffc02028a2:	01250513          	addi	a0,a0,18 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc02028a6:	ba1fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02028aa:	86d6                	mv	a3,s5
ffffffffc02028ac:	00003617          	auipc	a2,0x3
ffffffffc02028b0:	d1c60613          	addi	a2,a2,-740 # ffffffffc02055c8 <buddy_system_pmm_manager+0x50>
ffffffffc02028b4:	17f00593          	li	a1,383
ffffffffc02028b8:	00003517          	auipc	a0,0x3
ffffffffc02028bc:	ff850513          	addi	a0,a0,-8 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc02028c0:	b87fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02028c4:	00003697          	auipc	a3,0x3
ffffffffc02028c8:	1fc68693          	addi	a3,a3,508 # ffffffffc0205ac0 <buddy_system_pmm_manager+0x548>
ffffffffc02028cc:	00003617          	auipc	a2,0x3
ffffffffc02028d0:	a2460613          	addi	a2,a2,-1500 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02028d4:	18d00593          	li	a1,397
ffffffffc02028d8:	00003517          	auipc	a0,0x3
ffffffffc02028dc:	fd850513          	addi	a0,a0,-40 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc02028e0:	b67fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02028e4:	00003697          	auipc	a3,0x3
ffffffffc02028e8:	2a468693          	addi	a3,a3,676 # ffffffffc0205b88 <buddy_system_pmm_manager+0x610>
ffffffffc02028ec:	00003617          	auipc	a2,0x3
ffffffffc02028f0:	a0460613          	addi	a2,a2,-1532 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02028f4:	18c00593          	li	a1,396
ffffffffc02028f8:	00003517          	auipc	a0,0x3
ffffffffc02028fc:	fb850513          	addi	a0,a0,-72 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202900:	b47fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202904:	00003697          	auipc	a3,0x3
ffffffffc0202908:	26c68693          	addi	a3,a3,620 # ffffffffc0205b70 <buddy_system_pmm_manager+0x5f8>
ffffffffc020290c:	00003617          	auipc	a2,0x3
ffffffffc0202910:	9e460613          	addi	a2,a2,-1564 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202914:	18b00593          	li	a1,395
ffffffffc0202918:	00003517          	auipc	a0,0x3
ffffffffc020291c:	f9850513          	addi	a0,a0,-104 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202920:	b27fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202924:	00003697          	auipc	a3,0x3
ffffffffc0202928:	21c68693          	addi	a3,a3,540 # ffffffffc0205b40 <buddy_system_pmm_manager+0x5c8>
ffffffffc020292c:	00003617          	auipc	a2,0x3
ffffffffc0202930:	9c460613          	addi	a2,a2,-1596 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202934:	18a00593          	li	a1,394
ffffffffc0202938:	00003517          	auipc	a0,0x3
ffffffffc020293c:	f7850513          	addi	a0,a0,-136 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202940:	b07fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202944:	00003697          	auipc	a3,0x3
ffffffffc0202948:	3b468693          	addi	a3,a3,948 # ffffffffc0205cf8 <buddy_system_pmm_manager+0x780>
ffffffffc020294c:	00003617          	auipc	a2,0x3
ffffffffc0202950:	9a460613          	addi	a2,a2,-1628 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202954:	1b800593          	li	a1,440
ffffffffc0202958:	00003517          	auipc	a0,0x3
ffffffffc020295c:	f5850513          	addi	a0,a0,-168 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202960:	ae7fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202964:	00003697          	auipc	a3,0x3
ffffffffc0202968:	1ac68693          	addi	a3,a3,428 # ffffffffc0205b10 <buddy_system_pmm_manager+0x598>
ffffffffc020296c:	00003617          	auipc	a2,0x3
ffffffffc0202970:	98460613          	addi	a2,a2,-1660 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202974:	18700593          	li	a1,391
ffffffffc0202978:	00003517          	auipc	a0,0x3
ffffffffc020297c:	f3850513          	addi	a0,a0,-200 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202980:	ac7fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202984:	00003697          	auipc	a3,0x3
ffffffffc0202988:	17c68693          	addi	a3,a3,380 # ffffffffc0205b00 <buddy_system_pmm_manager+0x588>
ffffffffc020298c:	00003617          	auipc	a2,0x3
ffffffffc0202990:	96460613          	addi	a2,a2,-1692 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202994:	18600593          	li	a1,390
ffffffffc0202998:	00003517          	auipc	a0,0x3
ffffffffc020299c:	f1850513          	addi	a0,a0,-232 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc02029a0:	aa7fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02029a4:	00003697          	auipc	a3,0x3
ffffffffc02029a8:	25468693          	addi	a3,a3,596 # ffffffffc0205bf8 <buddy_system_pmm_manager+0x680>
ffffffffc02029ac:	00003617          	auipc	a2,0x3
ffffffffc02029b0:	94460613          	addi	a2,a2,-1724 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02029b4:	1c900593          	li	a1,457
ffffffffc02029b8:	00003517          	auipc	a0,0x3
ffffffffc02029bc:	ef850513          	addi	a0,a0,-264 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc02029c0:	a87fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02029c4:	00003697          	auipc	a3,0x3
ffffffffc02029c8:	12c68693          	addi	a3,a3,300 # ffffffffc0205af0 <buddy_system_pmm_manager+0x578>
ffffffffc02029cc:	00003617          	auipc	a2,0x3
ffffffffc02029d0:	92460613          	addi	a2,a2,-1756 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02029d4:	18500593          	li	a1,389
ffffffffc02029d8:	00003517          	auipc	a0,0x3
ffffffffc02029dc:	ed850513          	addi	a0,a0,-296 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc02029e0:	a67fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02029e4:	00003697          	auipc	a3,0x3
ffffffffc02029e8:	06468693          	addi	a3,a3,100 # ffffffffc0205a48 <buddy_system_pmm_manager+0x4d0>
ffffffffc02029ec:	00003617          	auipc	a2,0x3
ffffffffc02029f0:	90460613          	addi	a2,a2,-1788 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02029f4:	19200593          	li	a1,402
ffffffffc02029f8:	00003517          	auipc	a0,0x3
ffffffffc02029fc:	eb850513          	addi	a0,a0,-328 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202a00:	a47fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202a04:	00003697          	auipc	a3,0x3
ffffffffc0202a08:	19c68693          	addi	a3,a3,412 # ffffffffc0205ba0 <buddy_system_pmm_manager+0x628>
ffffffffc0202a0c:	00003617          	auipc	a2,0x3
ffffffffc0202a10:	8e460613          	addi	a2,a2,-1820 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202a14:	18f00593          	li	a1,399
ffffffffc0202a18:	00003517          	auipc	a0,0x3
ffffffffc0202a1c:	e9850513          	addi	a0,a0,-360 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202a20:	a27fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202a24:	00003697          	auipc	a3,0x3
ffffffffc0202a28:	00c68693          	addi	a3,a3,12 # ffffffffc0205a30 <buddy_system_pmm_manager+0x4b8>
ffffffffc0202a2c:	00003617          	auipc	a2,0x3
ffffffffc0202a30:	8c460613          	addi	a2,a2,-1852 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202a34:	18e00593          	li	a1,398
ffffffffc0202a38:	00003517          	auipc	a0,0x3
ffffffffc0202a3c:	e7850513          	addi	a0,a0,-392 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202a40:	a07fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202a44:	00003617          	auipc	a2,0x3
ffffffffc0202a48:	b8460613          	addi	a2,a2,-1148 # ffffffffc02055c8 <buddy_system_pmm_manager+0x50>
ffffffffc0202a4c:	06900593          	li	a1,105
ffffffffc0202a50:	00003517          	auipc	a0,0x3
ffffffffc0202a54:	ba050513          	addi	a0,a0,-1120 # ffffffffc02055f0 <buddy_system_pmm_manager+0x78>
ffffffffc0202a58:	9effd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202a5c:	00003697          	auipc	a3,0x3
ffffffffc0202a60:	17468693          	addi	a3,a3,372 # ffffffffc0205bd0 <buddy_system_pmm_manager+0x658>
ffffffffc0202a64:	00003617          	auipc	a2,0x3
ffffffffc0202a68:	88c60613          	addi	a2,a2,-1908 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202a6c:	19900593          	li	a1,409
ffffffffc0202a70:	00003517          	auipc	a0,0x3
ffffffffc0202a74:	e4050513          	addi	a0,a0,-448 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202a78:	9cffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202a7c:	00003697          	auipc	a3,0x3
ffffffffc0202a80:	10c68693          	addi	a3,a3,268 # ffffffffc0205b88 <buddy_system_pmm_manager+0x610>
ffffffffc0202a84:	00003617          	auipc	a2,0x3
ffffffffc0202a88:	86c60613          	addi	a2,a2,-1940 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202a8c:	19700593          	li	a1,407
ffffffffc0202a90:	00003517          	auipc	a0,0x3
ffffffffc0202a94:	e2050513          	addi	a0,a0,-480 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202a98:	9affd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202a9c:	00003697          	auipc	a3,0x3
ffffffffc0202aa0:	11c68693          	addi	a3,a3,284 # ffffffffc0205bb8 <buddy_system_pmm_manager+0x640>
ffffffffc0202aa4:	00003617          	auipc	a2,0x3
ffffffffc0202aa8:	84c60613          	addi	a2,a2,-1972 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202aac:	19600593          	li	a1,406
ffffffffc0202ab0:	00003517          	auipc	a0,0x3
ffffffffc0202ab4:	e0050513          	addi	a0,a0,-512 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202ab8:	98ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202abc:	00003697          	auipc	a3,0x3
ffffffffc0202ac0:	0cc68693          	addi	a3,a3,204 # ffffffffc0205b88 <buddy_system_pmm_manager+0x610>
ffffffffc0202ac4:	00003617          	auipc	a2,0x3
ffffffffc0202ac8:	82c60613          	addi	a2,a2,-2004 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202acc:	19300593          	li	a1,403
ffffffffc0202ad0:	00003517          	auipc	a0,0x3
ffffffffc0202ad4:	de050513          	addi	a0,a0,-544 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202ad8:	96ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202adc:	00003697          	auipc	a3,0x3
ffffffffc0202ae0:	20468693          	addi	a3,a3,516 # ffffffffc0205ce0 <buddy_system_pmm_manager+0x768>
ffffffffc0202ae4:	00003617          	auipc	a2,0x3
ffffffffc0202ae8:	80c60613          	addi	a2,a2,-2036 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202aec:	1b700593          	li	a1,439
ffffffffc0202af0:	00003517          	auipc	a0,0x3
ffffffffc0202af4:	dc050513          	addi	a0,a0,-576 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202af8:	94ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202afc:	00003697          	auipc	a3,0x3
ffffffffc0202b00:	1ac68693          	addi	a3,a3,428 # ffffffffc0205ca8 <buddy_system_pmm_manager+0x730>
ffffffffc0202b04:	00002617          	auipc	a2,0x2
ffffffffc0202b08:	7ec60613          	addi	a2,a2,2028 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202b0c:	1b600593          	li	a1,438
ffffffffc0202b10:	00003517          	auipc	a0,0x3
ffffffffc0202b14:	da050513          	addi	a0,a0,-608 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202b18:	92ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202b1c:	00003697          	auipc	a3,0x3
ffffffffc0202b20:	17468693          	addi	a3,a3,372 # ffffffffc0205c90 <buddy_system_pmm_manager+0x718>
ffffffffc0202b24:	00002617          	auipc	a2,0x2
ffffffffc0202b28:	7cc60613          	addi	a2,a2,1996 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202b2c:	1b200593          	li	a1,434
ffffffffc0202b30:	00003517          	auipc	a0,0x3
ffffffffc0202b34:	d8050513          	addi	a0,a0,-640 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202b38:	90ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202b3c:	00003697          	auipc	a3,0x3
ffffffffc0202b40:	0bc68693          	addi	a3,a3,188 # ffffffffc0205bf8 <buddy_system_pmm_manager+0x680>
ffffffffc0202b44:	00002617          	auipc	a2,0x2
ffffffffc0202b48:	7ac60613          	addi	a2,a2,1964 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202b4c:	1a100593          	li	a1,417
ffffffffc0202b50:	00003517          	auipc	a0,0x3
ffffffffc0202b54:	d6050513          	addi	a0,a0,-672 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202b58:	8effd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202b5c:	00003697          	auipc	a3,0x3
ffffffffc0202b60:	ed468693          	addi	a3,a3,-300 # ffffffffc0205a30 <buddy_system_pmm_manager+0x4b8>
ffffffffc0202b64:	00002617          	auipc	a2,0x2
ffffffffc0202b68:	78c60613          	addi	a2,a2,1932 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202b6c:	17b00593          	li	a1,379
ffffffffc0202b70:	00003517          	auipc	a0,0x3
ffffffffc0202b74:	d4050513          	addi	a0,a0,-704 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202b78:	8cffd0ef          	jal	ra,ffffffffc0200446 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202b7c:	00003617          	auipc	a2,0x3
ffffffffc0202b80:	a4c60613          	addi	a2,a2,-1460 # ffffffffc02055c8 <buddy_system_pmm_manager+0x50>
ffffffffc0202b84:	17e00593          	li	a1,382
ffffffffc0202b88:	00003517          	auipc	a0,0x3
ffffffffc0202b8c:	d2850513          	addi	a0,a0,-728 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202b90:	8b7fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202b94:	00003697          	auipc	a3,0x3
ffffffffc0202b98:	eb468693          	addi	a3,a3,-332 # ffffffffc0205a48 <buddy_system_pmm_manager+0x4d0>
ffffffffc0202b9c:	00002617          	auipc	a2,0x2
ffffffffc0202ba0:	75460613          	addi	a2,a2,1876 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202ba4:	17c00593          	li	a1,380
ffffffffc0202ba8:	00003517          	auipc	a0,0x3
ffffffffc0202bac:	d0850513          	addi	a0,a0,-760 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202bb0:	897fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202bb4:	00003697          	auipc	a3,0x3
ffffffffc0202bb8:	f0c68693          	addi	a3,a3,-244 # ffffffffc0205ac0 <buddy_system_pmm_manager+0x548>
ffffffffc0202bbc:	00002617          	auipc	a2,0x2
ffffffffc0202bc0:	73460613          	addi	a2,a2,1844 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202bc4:	18400593          	li	a1,388
ffffffffc0202bc8:	00003517          	auipc	a0,0x3
ffffffffc0202bcc:	ce850513          	addi	a0,a0,-792 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202bd0:	877fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202bd4:	00003697          	auipc	a3,0x3
ffffffffc0202bd8:	1cc68693          	addi	a3,a3,460 # ffffffffc0205da0 <buddy_system_pmm_manager+0x828>
ffffffffc0202bdc:	00002617          	auipc	a2,0x2
ffffffffc0202be0:	71460613          	addi	a2,a2,1812 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202be4:	1c000593          	li	a1,448
ffffffffc0202be8:	00003517          	auipc	a0,0x3
ffffffffc0202bec:	cc850513          	addi	a0,a0,-824 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202bf0:	857fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202bf4:	00003697          	auipc	a3,0x3
ffffffffc0202bf8:	17468693          	addi	a3,a3,372 # ffffffffc0205d68 <buddy_system_pmm_manager+0x7f0>
ffffffffc0202bfc:	00002617          	auipc	a2,0x2
ffffffffc0202c00:	6f460613          	addi	a2,a2,1780 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202c04:	1bd00593          	li	a1,445
ffffffffc0202c08:	00003517          	auipc	a0,0x3
ffffffffc0202c0c:	ca850513          	addi	a0,a0,-856 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202c10:	837fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202c14:	00003697          	auipc	a3,0x3
ffffffffc0202c18:	12468693          	addi	a3,a3,292 # ffffffffc0205d38 <buddy_system_pmm_manager+0x7c0>
ffffffffc0202c1c:	00002617          	auipc	a2,0x2
ffffffffc0202c20:	6d460613          	addi	a2,a2,1748 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202c24:	1b900593          	li	a1,441
ffffffffc0202c28:	00003517          	auipc	a0,0x3
ffffffffc0202c2c:	c8850513          	addi	a0,a0,-888 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202c30:	817fd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0202c34 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202c34:	12058073          	sfence.vma	a1
}
ffffffffc0202c38:	8082                	ret

ffffffffc0202c3a <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202c3a:	7179                	addi	sp,sp,-48
ffffffffc0202c3c:	e84a                	sd	s2,16(sp)
ffffffffc0202c3e:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202c40:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202c42:	f022                	sd	s0,32(sp)
ffffffffc0202c44:	ec26                	sd	s1,24(sp)
ffffffffc0202c46:	e44e                	sd	s3,8(sp)
ffffffffc0202c48:	f406                	sd	ra,40(sp)
ffffffffc0202c4a:	84ae                	mv	s1,a1
ffffffffc0202c4c:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202c4e:	f71fe0ef          	jal	ra,ffffffffc0201bbe <alloc_pages>
ffffffffc0202c52:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202c54:	cd09                	beqz	a0,ffffffffc0202c6e <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202c56:	85aa                	mv	a1,a0
ffffffffc0202c58:	86ce                	mv	a3,s3
ffffffffc0202c5a:	8626                	mv	a2,s1
ffffffffc0202c5c:	854a                	mv	a0,s2
ffffffffc0202c5e:	b2eff0ef          	jal	ra,ffffffffc0201f8c <page_insert>
ffffffffc0202c62:	ed21                	bnez	a0,ffffffffc0202cba <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0202c64:	00013797          	auipc	a5,0x13
ffffffffc0202c68:	a147a783          	lw	a5,-1516(a5) # ffffffffc0215678 <swap_init_ok>
ffffffffc0202c6c:	eb89                	bnez	a5,ffffffffc0202c7e <pgdir_alloc_page+0x44>
}
ffffffffc0202c6e:	70a2                	ld	ra,40(sp)
ffffffffc0202c70:	8522                	mv	a0,s0
ffffffffc0202c72:	7402                	ld	s0,32(sp)
ffffffffc0202c74:	64e2                	ld	s1,24(sp)
ffffffffc0202c76:	6942                	ld	s2,16(sp)
ffffffffc0202c78:	69a2                	ld	s3,8(sp)
ffffffffc0202c7a:	6145                	addi	sp,sp,48
ffffffffc0202c7c:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202c7e:	4681                	li	a3,0
ffffffffc0202c80:	8622                	mv	a2,s0
ffffffffc0202c82:	85a6                	mv	a1,s1
ffffffffc0202c84:	00013517          	auipc	a0,0x13
ffffffffc0202c88:	9fc53503          	ld	a0,-1540(a0) # ffffffffc0215680 <check_mm_struct>
ffffffffc0202c8c:	0f8000ef          	jal	ra,ffffffffc0202d84 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202c90:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202c92:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0202c94:	4785                	li	a5,1
ffffffffc0202c96:	fcf70ce3          	beq	a4,a5,ffffffffc0202c6e <pgdir_alloc_page+0x34>
ffffffffc0202c9a:	00003697          	auipc	a3,0x3
ffffffffc0202c9e:	14e68693          	addi	a3,a3,334 # ffffffffc0205de8 <buddy_system_pmm_manager+0x870>
ffffffffc0202ca2:	00002617          	auipc	a2,0x2
ffffffffc0202ca6:	64e60613          	addi	a2,a2,1614 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202caa:	15900593          	li	a1,345
ffffffffc0202cae:	00003517          	auipc	a0,0x3
ffffffffc0202cb2:	c0250513          	addi	a0,a0,-1022 # ffffffffc02058b0 <buddy_system_pmm_manager+0x338>
ffffffffc0202cb6:	f90fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202cba:	100027f3          	csrr	a5,sstatus
ffffffffc0202cbe:	8b89                	andi	a5,a5,2
ffffffffc0202cc0:	eb99                	bnez	a5,ffffffffc0202cd6 <pgdir_alloc_page+0x9c>
        pmm_manager->free_pages(base, n);
ffffffffc0202cc2:	00013797          	auipc	a5,0x13
ffffffffc0202cc6:	9967b783          	ld	a5,-1642(a5) # ffffffffc0215658 <pmm_manager>
ffffffffc0202cca:	739c                	ld	a5,32(a5)
ffffffffc0202ccc:	8522                	mv	a0,s0
ffffffffc0202cce:	4585                	li	a1,1
ffffffffc0202cd0:	9782                	jalr	a5
            return NULL;
ffffffffc0202cd2:	4401                	li	s0,0
ffffffffc0202cd4:	bf69                	j	ffffffffc0202c6e <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0202cd6:	8edfd0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202cda:	00013797          	auipc	a5,0x13
ffffffffc0202cde:	97e7b783          	ld	a5,-1666(a5) # ffffffffc0215658 <pmm_manager>
ffffffffc0202ce2:	739c                	ld	a5,32(a5)
ffffffffc0202ce4:	8522                	mv	a0,s0
ffffffffc0202ce6:	4585                	li	a1,1
ffffffffc0202ce8:	9782                	jalr	a5
            return NULL;
ffffffffc0202cea:	4401                	li	s0,0
        intr_enable();
ffffffffc0202cec:	8d1fd0ef          	jal	ra,ffffffffc02005bc <intr_enable>
ffffffffc0202cf0:	bfbd                	j	ffffffffc0202c6e <pgdir_alloc_page+0x34>

ffffffffc0202cf2 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202cf2:	1101                	addi	sp,sp,-32
ffffffffc0202cf4:	ec06                	sd	ra,24(sp)
ffffffffc0202cf6:	e822                	sd	s0,16(sp)
ffffffffc0202cf8:	e426                	sd	s1,8(sp)
     swapfs_init();
ffffffffc0202cfa:	5fb000ef          	jal	ra,ffffffffc0203af4 <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202cfe:	00013697          	auipc	a3,0x13
ffffffffc0202d02:	96a6b683          	ld	a3,-1686(a3) # ffffffffc0215668 <max_swap_offset>
ffffffffc0202d06:	010007b7          	lui	a5,0x1000
ffffffffc0202d0a:	ff968713          	addi	a4,a3,-7
ffffffffc0202d0e:	17e1                	addi	a5,a5,-8
ffffffffc0202d10:	04e7e863          	bltu	a5,a4,ffffffffc0202d60 <swap_init+0x6e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0202d14:	00007797          	auipc	a5,0x7
ffffffffc0202d18:	2ec78793          	addi	a5,a5,748 # ffffffffc020a000 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202d1c:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202d1e:	00013497          	auipc	s1,0x13
ffffffffc0202d22:	95248493          	addi	s1,s1,-1710 # ffffffffc0215670 <sm>
ffffffffc0202d26:	e09c                	sd	a5,0(s1)
     int r = sm->init();
ffffffffc0202d28:	9702                	jalr	a4
ffffffffc0202d2a:	842a                	mv	s0,a0
     
     if (r == 0)
ffffffffc0202d2c:	c519                	beqz	a0,ffffffffc0202d3a <swap_init+0x48>
          cprintf("SWAP: manager = %s\n", sm->name);
          //check_swap();  //这个测试程序针对链表型内存管理器，使用伙伴管理时应注释掉
     }

     return r;
}
ffffffffc0202d2e:	60e2                	ld	ra,24(sp)
ffffffffc0202d30:	8522                	mv	a0,s0
ffffffffc0202d32:	6442                	ld	s0,16(sp)
ffffffffc0202d34:	64a2                	ld	s1,8(sp)
ffffffffc0202d36:	6105                	addi	sp,sp,32
ffffffffc0202d38:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202d3a:	609c                	ld	a5,0(s1)
ffffffffc0202d3c:	00003517          	auipc	a0,0x3
ffffffffc0202d40:	0f450513          	addi	a0,a0,244 # ffffffffc0205e30 <buddy_system_pmm_manager+0x8b8>
ffffffffc0202d44:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202d46:	4785                	li	a5,1
ffffffffc0202d48:	00013717          	auipc	a4,0x13
ffffffffc0202d4c:	92f72823          	sw	a5,-1744(a4) # ffffffffc0215678 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202d50:	c30fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0202d54:	60e2                	ld	ra,24(sp)
ffffffffc0202d56:	8522                	mv	a0,s0
ffffffffc0202d58:	6442                	ld	s0,16(sp)
ffffffffc0202d5a:	64a2                	ld	s1,8(sp)
ffffffffc0202d5c:	6105                	addi	sp,sp,32
ffffffffc0202d5e:	8082                	ret
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202d60:	00003617          	auipc	a2,0x3
ffffffffc0202d64:	0a060613          	addi	a2,a2,160 # ffffffffc0205e00 <buddy_system_pmm_manager+0x888>
ffffffffc0202d68:	02a00593          	li	a1,42
ffffffffc0202d6c:	00003517          	auipc	a0,0x3
ffffffffc0202d70:	0b450513          	addi	a0,a0,180 # ffffffffc0205e20 <buddy_system_pmm_manager+0x8a8>
ffffffffc0202d74:	ed2fd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0202d78 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
     return sm->init_mm(mm);
ffffffffc0202d78:	00013797          	auipc	a5,0x13
ffffffffc0202d7c:	8f87b783          	ld	a5,-1800(a5) # ffffffffc0215670 <sm>
ffffffffc0202d80:	6b9c                	ld	a5,16(a5)
ffffffffc0202d82:	8782                	jr	a5

ffffffffc0202d84 <swap_map_swappable>:
}

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202d84:	00013797          	auipc	a5,0x13
ffffffffc0202d88:	8ec7b783          	ld	a5,-1812(a5) # ffffffffc0215670 <sm>
ffffffffc0202d8c:	739c                	ld	a5,32(a5)
ffffffffc0202d8e:	8782                	jr	a5

ffffffffc0202d90 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
ffffffffc0202d90:	711d                	addi	sp,sp,-96
ffffffffc0202d92:	ec86                	sd	ra,88(sp)
ffffffffc0202d94:	e8a2                	sd	s0,80(sp)
ffffffffc0202d96:	e4a6                	sd	s1,72(sp)
ffffffffc0202d98:	e0ca                	sd	s2,64(sp)
ffffffffc0202d9a:	fc4e                	sd	s3,56(sp)
ffffffffc0202d9c:	f852                	sd	s4,48(sp)
ffffffffc0202d9e:	f456                	sd	s5,40(sp)
ffffffffc0202da0:	f05a                	sd	s6,32(sp)
ffffffffc0202da2:	ec5e                	sd	s7,24(sp)
ffffffffc0202da4:	e862                	sd	s8,16(sp)
     int i;
     for (i = 0; i != n; ++ i)
ffffffffc0202da6:	cde9                	beqz	a1,ffffffffc0202e80 <swap_out+0xf0>
ffffffffc0202da8:	8a2e                	mv	s4,a1
ffffffffc0202daa:	892a                	mv	s2,a0
ffffffffc0202dac:	8ab2                	mv	s5,a2
ffffffffc0202dae:	4401                	li	s0,0
ffffffffc0202db0:	00013997          	auipc	s3,0x13
ffffffffc0202db4:	8c098993          	addi	s3,s3,-1856 # ffffffffc0215670 <sm>
                    cprintf("SWAP: failed to save\n");
                    sm->map_swappable(mm, v, page, 0);
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202db8:	00003b17          	auipc	s6,0x3
ffffffffc0202dbc:	0f0b0b13          	addi	s6,s6,240 # ffffffffc0205ea8 <buddy_system_pmm_manager+0x930>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202dc0:	00003b97          	auipc	s7,0x3
ffffffffc0202dc4:	0d0b8b93          	addi	s7,s7,208 # ffffffffc0205e90 <buddy_system_pmm_manager+0x918>
ffffffffc0202dc8:	a825                	j	ffffffffc0202e00 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202dca:	67a2                	ld	a5,8(sp)
ffffffffc0202dcc:	8626                	mv	a2,s1
ffffffffc0202dce:	85a2                	mv	a1,s0
ffffffffc0202dd0:	7f94                	ld	a3,56(a5)
ffffffffc0202dd2:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202dd4:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202dd6:	82b1                	srli	a3,a3,0xc
ffffffffc0202dd8:	0685                	addi	a3,a3,1
ffffffffc0202dda:	ba6fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202dde:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202de0:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202de2:	7d1c                	ld	a5,56(a0)
ffffffffc0202de4:	83b1                	srli	a5,a5,0xc
ffffffffc0202de6:	0785                	addi	a5,a5,1
ffffffffc0202de8:	07a2                	slli	a5,a5,0x8
ffffffffc0202dea:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202dee:	e63fe0ef          	jal	ra,ffffffffc0201c50 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202df2:	01893503          	ld	a0,24(s2)
ffffffffc0202df6:	85a6                	mv	a1,s1
ffffffffc0202df8:	e3dff0ef          	jal	ra,ffffffffc0202c34 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202dfc:	048a0d63          	beq	s4,s0,ffffffffc0202e56 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202e00:	0009b783          	ld	a5,0(s3)
ffffffffc0202e04:	8656                	mv	a2,s5
ffffffffc0202e06:	002c                	addi	a1,sp,8
ffffffffc0202e08:	7b9c                	ld	a5,48(a5)
ffffffffc0202e0a:	854a                	mv	a0,s2
ffffffffc0202e0c:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202e0e:	e12d                	bnez	a0,ffffffffc0202e70 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202e10:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202e12:	01893503          	ld	a0,24(s2)
ffffffffc0202e16:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202e18:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202e1a:	85a6                	mv	a1,s1
ffffffffc0202e1c:	eaffe0ef          	jal	ra,ffffffffc0201cca <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202e20:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202e22:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202e24:	8b85                	andi	a5,a5,1
ffffffffc0202e26:	cfb9                	beqz	a5,ffffffffc0202e84 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202e28:	65a2                	ld	a1,8(sp)
ffffffffc0202e2a:	7d9c                	ld	a5,56(a1)
ffffffffc0202e2c:	83b1                	srli	a5,a5,0xc
ffffffffc0202e2e:	0785                	addi	a5,a5,1
ffffffffc0202e30:	00879513          	slli	a0,a5,0x8
ffffffffc0202e34:	587000ef          	jal	ra,ffffffffc0203bba <swapfs_write>
ffffffffc0202e38:	d949                	beqz	a0,ffffffffc0202dca <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202e3a:	855e                	mv	a0,s7
ffffffffc0202e3c:	b44fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202e40:	0009b783          	ld	a5,0(s3)
ffffffffc0202e44:	6622                	ld	a2,8(sp)
ffffffffc0202e46:	4681                	li	a3,0
ffffffffc0202e48:	739c                	ld	a5,32(a5)
ffffffffc0202e4a:	85a6                	mv	a1,s1
ffffffffc0202e4c:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202e4e:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202e50:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202e52:	fa8a17e3          	bne	s4,s0,ffffffffc0202e00 <swap_out+0x70>
     }
     return i;
}
ffffffffc0202e56:	60e6                	ld	ra,88(sp)
ffffffffc0202e58:	8522                	mv	a0,s0
ffffffffc0202e5a:	6446                	ld	s0,80(sp)
ffffffffc0202e5c:	64a6                	ld	s1,72(sp)
ffffffffc0202e5e:	6906                	ld	s2,64(sp)
ffffffffc0202e60:	79e2                	ld	s3,56(sp)
ffffffffc0202e62:	7a42                	ld	s4,48(sp)
ffffffffc0202e64:	7aa2                	ld	s5,40(sp)
ffffffffc0202e66:	7b02                	ld	s6,32(sp)
ffffffffc0202e68:	6be2                	ld	s7,24(sp)
ffffffffc0202e6a:	6c42                	ld	s8,16(sp)
ffffffffc0202e6c:	6125                	addi	sp,sp,96
ffffffffc0202e6e:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202e70:	85a2                	mv	a1,s0
ffffffffc0202e72:	00003517          	auipc	a0,0x3
ffffffffc0202e76:	fd650513          	addi	a0,a0,-42 # ffffffffc0205e48 <buddy_system_pmm_manager+0x8d0>
ffffffffc0202e7a:	b06fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
                  break;
ffffffffc0202e7e:	bfe1                	j	ffffffffc0202e56 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202e80:	4401                	li	s0,0
ffffffffc0202e82:	bfd1                	j	ffffffffc0202e56 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202e84:	00003697          	auipc	a3,0x3
ffffffffc0202e88:	ff468693          	addi	a3,a3,-12 # ffffffffc0205e78 <buddy_system_pmm_manager+0x900>
ffffffffc0202e8c:	00002617          	auipc	a2,0x2
ffffffffc0202e90:	46460613          	addi	a2,a2,1124 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202e94:	06900593          	li	a1,105
ffffffffc0202e98:	00003517          	auipc	a0,0x3
ffffffffc0202e9c:	f8850513          	addi	a0,a0,-120 # ffffffffc0205e20 <buddy_system_pmm_manager+0x8a8>
ffffffffc0202ea0:	da6fd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0202ea4 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
ffffffffc0202ea4:	7179                	addi	sp,sp,-48
ffffffffc0202ea6:	e84a                	sd	s2,16(sp)
ffffffffc0202ea8:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202eaa:	4505                	li	a0,1
{
ffffffffc0202eac:	ec26                	sd	s1,24(sp)
ffffffffc0202eae:	e44e                	sd	s3,8(sp)
ffffffffc0202eb0:	f406                	sd	ra,40(sp)
ffffffffc0202eb2:	f022                	sd	s0,32(sp)
ffffffffc0202eb4:	84ae                	mv	s1,a1
ffffffffc0202eb6:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202eb8:	d07fe0ef          	jal	ra,ffffffffc0201bbe <alloc_pages>
     assert(result!=NULL);
ffffffffc0202ebc:	c129                	beqz	a0,ffffffffc0202efe <swap_in+0x5a>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202ebe:	842a                	mv	s0,a0
ffffffffc0202ec0:	01893503          	ld	a0,24(s2)
ffffffffc0202ec4:	4601                	li	a2,0
ffffffffc0202ec6:	85a6                	mv	a1,s1
ffffffffc0202ec8:	e03fe0ef          	jal	ra,ffffffffc0201cca <get_pte>
ffffffffc0202ecc:	892a                	mv	s2,a0
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0202ece:	6108                	ld	a0,0(a0)
ffffffffc0202ed0:	85a2                	mv	a1,s0
ffffffffc0202ed2:	45b000ef          	jal	ra,ffffffffc0203b2c <swapfs_read>
     {
        assert(r!=0);
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202ed6:	00093583          	ld	a1,0(s2)
ffffffffc0202eda:	8626                	mv	a2,s1
ffffffffc0202edc:	00003517          	auipc	a0,0x3
ffffffffc0202ee0:	01c50513          	addi	a0,a0,28 # ffffffffc0205ef8 <buddy_system_pmm_manager+0x980>
ffffffffc0202ee4:	81a1                	srli	a1,a1,0x8
ffffffffc0202ee6:	a9afd0ef          	jal	ra,ffffffffc0200180 <cprintf>
     *ptr_result=result;
     return 0;
}
ffffffffc0202eea:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0202eec:	0089b023          	sd	s0,0(s3)
}
ffffffffc0202ef0:	7402                	ld	s0,32(sp)
ffffffffc0202ef2:	64e2                	ld	s1,24(sp)
ffffffffc0202ef4:	6942                	ld	s2,16(sp)
ffffffffc0202ef6:	69a2                	ld	s3,8(sp)
ffffffffc0202ef8:	4501                	li	a0,0
ffffffffc0202efa:	6145                	addi	sp,sp,48
ffffffffc0202efc:	8082                	ret
     assert(result!=NULL);
ffffffffc0202efe:	00003697          	auipc	a3,0x3
ffffffffc0202f02:	fea68693          	addi	a3,a3,-22 # ffffffffc0205ee8 <buddy_system_pmm_manager+0x970>
ffffffffc0202f06:	00002617          	auipc	a2,0x2
ffffffffc0202f0a:	3ea60613          	addi	a2,a2,1002 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0202f0e:	07f00593          	li	a1,127
ffffffffc0202f12:	00003517          	auipc	a0,0x3
ffffffffc0202f16:	f0e50513          	addi	a0,a0,-242 # ffffffffc0205e20 <buddy_system_pmm_manager+0x8a8>
ffffffffc0202f1a:	d2cfd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0202f1e <_fifo_init_mm>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0202f1e:	0000e797          	auipc	a5,0xe
ffffffffc0202f22:	6ca78793          	addi	a5,a5,1738 # ffffffffc02115e8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0202f26:	f51c                	sd	a5,40(a0)
ffffffffc0202f28:	e79c                	sd	a5,8(a5)
ffffffffc0202f2a:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0202f2c:	4501                	li	a0,0
ffffffffc0202f2e:	8082                	ret

ffffffffc0202f30 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0202f30:	4501                	li	a0,0
ffffffffc0202f32:	8082                	ret

ffffffffc0202f34 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0202f34:	4501                	li	a0,0
ffffffffc0202f36:	8082                	ret

ffffffffc0202f38 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0202f38:	4501                	li	a0,0
ffffffffc0202f3a:	8082                	ret

ffffffffc0202f3c <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0202f3c:	711d                	addi	sp,sp,-96
ffffffffc0202f3e:	fc4e                	sd	s3,56(sp)
ffffffffc0202f40:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0202f42:	00003517          	auipc	a0,0x3
ffffffffc0202f46:	ff650513          	addi	a0,a0,-10 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9c0>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202f4a:	698d                	lui	s3,0x3
ffffffffc0202f4c:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0202f4e:	e0ca                	sd	s2,64(sp)
ffffffffc0202f50:	ec86                	sd	ra,88(sp)
ffffffffc0202f52:	e8a2                	sd	s0,80(sp)
ffffffffc0202f54:	e4a6                	sd	s1,72(sp)
ffffffffc0202f56:	f456                	sd	s5,40(sp)
ffffffffc0202f58:	f05a                	sd	s6,32(sp)
ffffffffc0202f5a:	ec5e                	sd	s7,24(sp)
ffffffffc0202f5c:	e862                	sd	s8,16(sp)
ffffffffc0202f5e:	e466                	sd	s9,8(sp)
ffffffffc0202f60:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0202f62:	a1efd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202f66:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0202f6a:	00012917          	auipc	s2,0x12
ffffffffc0202f6e:	71e92903          	lw	s2,1822(s2) # ffffffffc0215688 <pgfault_num>
ffffffffc0202f72:	4791                	li	a5,4
ffffffffc0202f74:	14f91e63          	bne	s2,a5,ffffffffc02030d0 <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0202f78:	00003517          	auipc	a0,0x3
ffffffffc0202f7c:	01050513          	addi	a0,a0,16 # ffffffffc0205f88 <buddy_system_pmm_manager+0xa10>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202f80:	6a85                	lui	s5,0x1
ffffffffc0202f82:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0202f84:	9fcfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202f88:	00012417          	auipc	s0,0x12
ffffffffc0202f8c:	70040413          	addi	s0,s0,1792 # ffffffffc0215688 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202f90:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0202f94:	4004                	lw	s1,0(s0)
ffffffffc0202f96:	2481                	sext.w	s1,s1
ffffffffc0202f98:	2b249c63          	bne	s1,s2,ffffffffc0203250 <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0202f9c:	00003517          	auipc	a0,0x3
ffffffffc0202fa0:	01450513          	addi	a0,a0,20 # ffffffffc0205fb0 <buddy_system_pmm_manager+0xa38>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202fa4:	6b91                	lui	s7,0x4
ffffffffc0202fa6:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0202fa8:	9d8fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202fac:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0202fb0:	00042903          	lw	s2,0(s0)
ffffffffc0202fb4:	2901                	sext.w	s2,s2
ffffffffc0202fb6:	26991d63          	bne	s2,s1,ffffffffc0203230 <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202fba:	00003517          	auipc	a0,0x3
ffffffffc0202fbe:	01e50513          	addi	a0,a0,30 # ffffffffc0205fd8 <buddy_system_pmm_manager+0xa60>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202fc2:	6c89                	lui	s9,0x2
ffffffffc0202fc4:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202fc6:	9bafd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202fca:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0202fce:	401c                	lw	a5,0(s0)
ffffffffc0202fd0:	2781                	sext.w	a5,a5
ffffffffc0202fd2:	23279f63          	bne	a5,s2,ffffffffc0203210 <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0202fd6:	00003517          	auipc	a0,0x3
ffffffffc0202fda:	02a50513          	addi	a0,a0,42 # ffffffffc0206000 <buddy_system_pmm_manager+0xa88>
ffffffffc0202fde:	9a2fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0202fe2:	6795                	lui	a5,0x5
ffffffffc0202fe4:	4739                	li	a4,14
ffffffffc0202fe6:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0202fea:	4004                	lw	s1,0(s0)
ffffffffc0202fec:	4795                	li	a5,5
ffffffffc0202fee:	2481                	sext.w	s1,s1
ffffffffc0202ff0:	20f49063          	bne	s1,a5,ffffffffc02031f0 <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202ff4:	00003517          	auipc	a0,0x3
ffffffffc0202ff8:	fe450513          	addi	a0,a0,-28 # ffffffffc0205fd8 <buddy_system_pmm_manager+0xa60>
ffffffffc0202ffc:	984fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203000:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0203004:	401c                	lw	a5,0(s0)
ffffffffc0203006:	2781                	sext.w	a5,a5
ffffffffc0203008:	1c979463          	bne	a5,s1,ffffffffc02031d0 <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020300c:	00003517          	auipc	a0,0x3
ffffffffc0203010:	f7c50513          	addi	a0,a0,-132 # ffffffffc0205f88 <buddy_system_pmm_manager+0xa10>
ffffffffc0203014:	96cfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203018:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc020301c:	401c                	lw	a5,0(s0)
ffffffffc020301e:	4719                	li	a4,6
ffffffffc0203020:	2781                	sext.w	a5,a5
ffffffffc0203022:	18e79763          	bne	a5,a4,ffffffffc02031b0 <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203026:	00003517          	auipc	a0,0x3
ffffffffc020302a:	fb250513          	addi	a0,a0,-78 # ffffffffc0205fd8 <buddy_system_pmm_manager+0xa60>
ffffffffc020302e:	952fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203032:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0203036:	401c                	lw	a5,0(s0)
ffffffffc0203038:	471d                	li	a4,7
ffffffffc020303a:	2781                	sext.w	a5,a5
ffffffffc020303c:	14e79a63          	bne	a5,a4,ffffffffc0203190 <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203040:	00003517          	auipc	a0,0x3
ffffffffc0203044:	ef850513          	addi	a0,a0,-264 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9c0>
ffffffffc0203048:	938fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020304c:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203050:	401c                	lw	a5,0(s0)
ffffffffc0203052:	4721                	li	a4,8
ffffffffc0203054:	2781                	sext.w	a5,a5
ffffffffc0203056:	10e79d63          	bne	a5,a4,ffffffffc0203170 <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020305a:	00003517          	auipc	a0,0x3
ffffffffc020305e:	f5650513          	addi	a0,a0,-170 # ffffffffc0205fb0 <buddy_system_pmm_manager+0xa38>
ffffffffc0203062:	91efd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203066:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc020306a:	401c                	lw	a5,0(s0)
ffffffffc020306c:	4725                	li	a4,9
ffffffffc020306e:	2781                	sext.w	a5,a5
ffffffffc0203070:	0ee79063          	bne	a5,a4,ffffffffc0203150 <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203074:	00003517          	auipc	a0,0x3
ffffffffc0203078:	f8c50513          	addi	a0,a0,-116 # ffffffffc0206000 <buddy_system_pmm_manager+0xa88>
ffffffffc020307c:	904fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203080:	6795                	lui	a5,0x5
ffffffffc0203082:	4739                	li	a4,14
ffffffffc0203084:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0203088:	4004                	lw	s1,0(s0)
ffffffffc020308a:	47a9                	li	a5,10
ffffffffc020308c:	2481                	sext.w	s1,s1
ffffffffc020308e:	0af49163          	bne	s1,a5,ffffffffc0203130 <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203092:	00003517          	auipc	a0,0x3
ffffffffc0203096:	ef650513          	addi	a0,a0,-266 # ffffffffc0205f88 <buddy_system_pmm_manager+0xa10>
ffffffffc020309a:	8e6fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020309e:	6785                	lui	a5,0x1
ffffffffc02030a0:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02030a4:	06979663          	bne	a5,s1,ffffffffc0203110 <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc02030a8:	401c                	lw	a5,0(s0)
ffffffffc02030aa:	472d                	li	a4,11
ffffffffc02030ac:	2781                	sext.w	a5,a5
ffffffffc02030ae:	04e79163          	bne	a5,a4,ffffffffc02030f0 <_fifo_check_swap+0x1b4>
}
ffffffffc02030b2:	60e6                	ld	ra,88(sp)
ffffffffc02030b4:	6446                	ld	s0,80(sp)
ffffffffc02030b6:	64a6                	ld	s1,72(sp)
ffffffffc02030b8:	6906                	ld	s2,64(sp)
ffffffffc02030ba:	79e2                	ld	s3,56(sp)
ffffffffc02030bc:	7a42                	ld	s4,48(sp)
ffffffffc02030be:	7aa2                	ld	s5,40(sp)
ffffffffc02030c0:	7b02                	ld	s6,32(sp)
ffffffffc02030c2:	6be2                	ld	s7,24(sp)
ffffffffc02030c4:	6c42                	ld	s8,16(sp)
ffffffffc02030c6:	6ca2                	ld	s9,8(sp)
ffffffffc02030c8:	6d02                	ld	s10,0(sp)
ffffffffc02030ca:	4501                	li	a0,0
ffffffffc02030cc:	6125                	addi	sp,sp,96
ffffffffc02030ce:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02030d0:	00003697          	auipc	a3,0x3
ffffffffc02030d4:	e9068693          	addi	a3,a3,-368 # ffffffffc0205f60 <buddy_system_pmm_manager+0x9e8>
ffffffffc02030d8:	00002617          	auipc	a2,0x2
ffffffffc02030dc:	21860613          	addi	a2,a2,536 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02030e0:	05100593          	li	a1,81
ffffffffc02030e4:	00003517          	auipc	a0,0x3
ffffffffc02030e8:	e8c50513          	addi	a0,a0,-372 # ffffffffc0205f70 <buddy_system_pmm_manager+0x9f8>
ffffffffc02030ec:	b5afd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==11);
ffffffffc02030f0:	00003697          	auipc	a3,0x3
ffffffffc02030f4:	fc068693          	addi	a3,a3,-64 # ffffffffc02060b0 <buddy_system_pmm_manager+0xb38>
ffffffffc02030f8:	00002617          	auipc	a2,0x2
ffffffffc02030fc:	1f860613          	addi	a2,a2,504 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0203100:	07300593          	li	a1,115
ffffffffc0203104:	00003517          	auipc	a0,0x3
ffffffffc0203108:	e6c50513          	addi	a0,a0,-404 # ffffffffc0205f70 <buddy_system_pmm_manager+0x9f8>
ffffffffc020310c:	b3afd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203110:	00003697          	auipc	a3,0x3
ffffffffc0203114:	f7868693          	addi	a3,a3,-136 # ffffffffc0206088 <buddy_system_pmm_manager+0xb10>
ffffffffc0203118:	00002617          	auipc	a2,0x2
ffffffffc020311c:	1d860613          	addi	a2,a2,472 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0203120:	07100593          	li	a1,113
ffffffffc0203124:	00003517          	auipc	a0,0x3
ffffffffc0203128:	e4c50513          	addi	a0,a0,-436 # ffffffffc0205f70 <buddy_system_pmm_manager+0x9f8>
ffffffffc020312c:	b1afd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==10);
ffffffffc0203130:	00003697          	auipc	a3,0x3
ffffffffc0203134:	f4868693          	addi	a3,a3,-184 # ffffffffc0206078 <buddy_system_pmm_manager+0xb00>
ffffffffc0203138:	00002617          	auipc	a2,0x2
ffffffffc020313c:	1b860613          	addi	a2,a2,440 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0203140:	06f00593          	li	a1,111
ffffffffc0203144:	00003517          	auipc	a0,0x3
ffffffffc0203148:	e2c50513          	addi	a0,a0,-468 # ffffffffc0205f70 <buddy_system_pmm_manager+0x9f8>
ffffffffc020314c:	afafd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==9);
ffffffffc0203150:	00003697          	auipc	a3,0x3
ffffffffc0203154:	f1868693          	addi	a3,a3,-232 # ffffffffc0206068 <buddy_system_pmm_manager+0xaf0>
ffffffffc0203158:	00002617          	auipc	a2,0x2
ffffffffc020315c:	19860613          	addi	a2,a2,408 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0203160:	06c00593          	li	a1,108
ffffffffc0203164:	00003517          	auipc	a0,0x3
ffffffffc0203168:	e0c50513          	addi	a0,a0,-500 # ffffffffc0205f70 <buddy_system_pmm_manager+0x9f8>
ffffffffc020316c:	adafd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==8);
ffffffffc0203170:	00003697          	auipc	a3,0x3
ffffffffc0203174:	ee868693          	addi	a3,a3,-280 # ffffffffc0206058 <buddy_system_pmm_manager+0xae0>
ffffffffc0203178:	00002617          	auipc	a2,0x2
ffffffffc020317c:	17860613          	addi	a2,a2,376 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0203180:	06900593          	li	a1,105
ffffffffc0203184:	00003517          	auipc	a0,0x3
ffffffffc0203188:	dec50513          	addi	a0,a0,-532 # ffffffffc0205f70 <buddy_system_pmm_manager+0x9f8>
ffffffffc020318c:	abafd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==7);
ffffffffc0203190:	00003697          	auipc	a3,0x3
ffffffffc0203194:	eb868693          	addi	a3,a3,-328 # ffffffffc0206048 <buddy_system_pmm_manager+0xad0>
ffffffffc0203198:	00002617          	auipc	a2,0x2
ffffffffc020319c:	15860613          	addi	a2,a2,344 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02031a0:	06600593          	li	a1,102
ffffffffc02031a4:	00003517          	auipc	a0,0x3
ffffffffc02031a8:	dcc50513          	addi	a0,a0,-564 # ffffffffc0205f70 <buddy_system_pmm_manager+0x9f8>
ffffffffc02031ac:	a9afd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==6);
ffffffffc02031b0:	00003697          	auipc	a3,0x3
ffffffffc02031b4:	e8868693          	addi	a3,a3,-376 # ffffffffc0206038 <buddy_system_pmm_manager+0xac0>
ffffffffc02031b8:	00002617          	auipc	a2,0x2
ffffffffc02031bc:	13860613          	addi	a2,a2,312 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02031c0:	06300593          	li	a1,99
ffffffffc02031c4:	00003517          	auipc	a0,0x3
ffffffffc02031c8:	dac50513          	addi	a0,a0,-596 # ffffffffc0205f70 <buddy_system_pmm_manager+0x9f8>
ffffffffc02031cc:	a7afd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==5);
ffffffffc02031d0:	00003697          	auipc	a3,0x3
ffffffffc02031d4:	e5868693          	addi	a3,a3,-424 # ffffffffc0206028 <buddy_system_pmm_manager+0xab0>
ffffffffc02031d8:	00002617          	auipc	a2,0x2
ffffffffc02031dc:	11860613          	addi	a2,a2,280 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02031e0:	06000593          	li	a1,96
ffffffffc02031e4:	00003517          	auipc	a0,0x3
ffffffffc02031e8:	d8c50513          	addi	a0,a0,-628 # ffffffffc0205f70 <buddy_system_pmm_manager+0x9f8>
ffffffffc02031ec:	a5afd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==5);
ffffffffc02031f0:	00003697          	auipc	a3,0x3
ffffffffc02031f4:	e3868693          	addi	a3,a3,-456 # ffffffffc0206028 <buddy_system_pmm_manager+0xab0>
ffffffffc02031f8:	00002617          	auipc	a2,0x2
ffffffffc02031fc:	0f860613          	addi	a2,a2,248 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0203200:	05d00593          	li	a1,93
ffffffffc0203204:	00003517          	auipc	a0,0x3
ffffffffc0203208:	d6c50513          	addi	a0,a0,-660 # ffffffffc0205f70 <buddy_system_pmm_manager+0x9f8>
ffffffffc020320c:	a3afd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==4);
ffffffffc0203210:	00003697          	auipc	a3,0x3
ffffffffc0203214:	d5068693          	addi	a3,a3,-688 # ffffffffc0205f60 <buddy_system_pmm_manager+0x9e8>
ffffffffc0203218:	00002617          	auipc	a2,0x2
ffffffffc020321c:	0d860613          	addi	a2,a2,216 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0203220:	05a00593          	li	a1,90
ffffffffc0203224:	00003517          	auipc	a0,0x3
ffffffffc0203228:	d4c50513          	addi	a0,a0,-692 # ffffffffc0205f70 <buddy_system_pmm_manager+0x9f8>
ffffffffc020322c:	a1afd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==4);
ffffffffc0203230:	00003697          	auipc	a3,0x3
ffffffffc0203234:	d3068693          	addi	a3,a3,-720 # ffffffffc0205f60 <buddy_system_pmm_manager+0x9e8>
ffffffffc0203238:	00002617          	auipc	a2,0x2
ffffffffc020323c:	0b860613          	addi	a2,a2,184 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0203240:	05700593          	li	a1,87
ffffffffc0203244:	00003517          	auipc	a0,0x3
ffffffffc0203248:	d2c50513          	addi	a0,a0,-724 # ffffffffc0205f70 <buddy_system_pmm_manager+0x9f8>
ffffffffc020324c:	9fafd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgfault_num==4);
ffffffffc0203250:	00003697          	auipc	a3,0x3
ffffffffc0203254:	d1068693          	addi	a3,a3,-752 # ffffffffc0205f60 <buddy_system_pmm_manager+0x9e8>
ffffffffc0203258:	00002617          	auipc	a2,0x2
ffffffffc020325c:	09860613          	addi	a2,a2,152 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0203260:	05400593          	li	a1,84
ffffffffc0203264:	00003517          	auipc	a0,0x3
ffffffffc0203268:	d0c50513          	addi	a0,a0,-756 # ffffffffc0205f70 <buddy_system_pmm_manager+0x9f8>
ffffffffc020326c:	9dafd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203270 <_fifo_swap_out_victim>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203270:	751c                	ld	a5,40(a0)
{
ffffffffc0203272:	1141                	addi	sp,sp,-16
ffffffffc0203274:	e406                	sd	ra,8(sp)
    assert(head != NULL);
ffffffffc0203276:	cf91                	beqz	a5,ffffffffc0203292 <_fifo_swap_out_victim+0x22>
    assert(in_tick==0);
ffffffffc0203278:	ee0d                	bnez	a2,ffffffffc02032b2 <_fifo_swap_out_victim+0x42>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020327a:	679c                	ld	a5,8(a5)
}
ffffffffc020327c:	60a2                	ld	ra,8(sp)
ffffffffc020327e:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0203280:	6394                	ld	a3,0(a5)
ffffffffc0203282:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203284:	fd878793          	addi	a5,a5,-40
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0203288:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020328a:	e314                	sd	a3,0(a4)
ffffffffc020328c:	e19c                	sd	a5,0(a1)
}
ffffffffc020328e:	0141                	addi	sp,sp,16
ffffffffc0203290:	8082                	ret
    assert(head != NULL);
ffffffffc0203292:	00003697          	auipc	a3,0x3
ffffffffc0203296:	e2e68693          	addi	a3,a3,-466 # ffffffffc02060c0 <buddy_system_pmm_manager+0xb48>
ffffffffc020329a:	00002617          	auipc	a2,0x2
ffffffffc020329e:	05660613          	addi	a2,a2,86 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02032a2:	04100593          	li	a1,65
ffffffffc02032a6:	00003517          	auipc	a0,0x3
ffffffffc02032aa:	cca50513          	addi	a0,a0,-822 # ffffffffc0205f70 <buddy_system_pmm_manager+0x9f8>
ffffffffc02032ae:	998fd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(in_tick==0);
ffffffffc02032b2:	00003697          	auipc	a3,0x3
ffffffffc02032b6:	e1e68693          	addi	a3,a3,-482 # ffffffffc02060d0 <buddy_system_pmm_manager+0xb58>
ffffffffc02032ba:	00002617          	auipc	a2,0x2
ffffffffc02032be:	03660613          	addi	a2,a2,54 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02032c2:	04200593          	li	a1,66
ffffffffc02032c6:	00003517          	auipc	a0,0x3
ffffffffc02032ca:	caa50513          	addi	a0,a0,-854 # ffffffffc0205f70 <buddy_system_pmm_manager+0x9f8>
ffffffffc02032ce:	978fd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02032d2 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02032d2:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc02032d4:	cb91                	beqz	a5,ffffffffc02032e8 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02032d6:	6394                	ld	a3,0(a5)
ffffffffc02032d8:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc02032dc:	e398                	sd	a4,0(a5)
ffffffffc02032de:	e698                	sd	a4,8(a3)
}
ffffffffc02032e0:	4501                	li	a0,0
    elm->next = next;
ffffffffc02032e2:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc02032e4:	f614                	sd	a3,40(a2)
ffffffffc02032e6:	8082                	ret
{
ffffffffc02032e8:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc02032ea:	00003697          	auipc	a3,0x3
ffffffffc02032ee:	df668693          	addi	a3,a3,-522 # ffffffffc02060e0 <buddy_system_pmm_manager+0xb68>
ffffffffc02032f2:	00002617          	auipc	a2,0x2
ffffffffc02032f6:	ffe60613          	addi	a2,a2,-2 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02032fa:	03200593          	li	a1,50
ffffffffc02032fe:	00003517          	auipc	a0,0x3
ffffffffc0203302:	c7250513          	addi	a0,a0,-910 # ffffffffc0205f70 <buddy_system_pmm_manager+0x9f8>
{
ffffffffc0203306:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203308:	93efd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020330c <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020330c:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020330e:	00003697          	auipc	a3,0x3
ffffffffc0203312:	e0a68693          	addi	a3,a3,-502 # ffffffffc0206118 <buddy_system_pmm_manager+0xba0>
ffffffffc0203316:	00002617          	auipc	a2,0x2
ffffffffc020331a:	fda60613          	addi	a2,a2,-38 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc020331e:	07e00593          	li	a1,126
ffffffffc0203322:	00003517          	auipc	a0,0x3
ffffffffc0203326:	e1650513          	addi	a0,a0,-490 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020332a:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020332c:	91afd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203330 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0203330:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0203332:	c505                	beqz	a0,ffffffffc020335a <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0203334:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203336:	c501                	beqz	a0,ffffffffc020333e <find_vma+0xe>
ffffffffc0203338:	651c                	ld	a5,8(a0)
ffffffffc020333a:	02f5f263          	bgeu	a1,a5,ffffffffc020335e <find_vma+0x2e>
    return listelm->next;
ffffffffc020333e:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0203340:	00f68d63          	beq	a3,a5,ffffffffc020335a <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0203344:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203348:	00e5e663          	bltu	a1,a4,ffffffffc0203354 <find_vma+0x24>
ffffffffc020334c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203350:	00e5ec63          	bltu	a1,a4,ffffffffc0203368 <find_vma+0x38>
ffffffffc0203354:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0203356:	fef697e3          	bne	a3,a5,ffffffffc0203344 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc020335a:	4501                	li	a0,0
}
ffffffffc020335c:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020335e:	691c                	ld	a5,16(a0)
ffffffffc0203360:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020333e <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203364:	ea88                	sd	a0,16(a3)
ffffffffc0203366:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0203368:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc020336c:	ea88                	sd	a0,16(a3)
ffffffffc020336e:	8082                	ret

ffffffffc0203370 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203370:	6590                	ld	a2,8(a1)
ffffffffc0203372:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203376:	1141                	addi	sp,sp,-16
ffffffffc0203378:	e406                	sd	ra,8(sp)
ffffffffc020337a:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020337c:	01066763          	bltu	a2,a6,ffffffffc020338a <insert_vma_struct+0x1a>
ffffffffc0203380:	a085                	j	ffffffffc02033e0 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203382:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203386:	04e66863          	bltu	a2,a4,ffffffffc02033d6 <insert_vma_struct+0x66>
ffffffffc020338a:	86be                	mv	a3,a5
ffffffffc020338c:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020338e:	fef51ae3          	bne	a0,a5,ffffffffc0203382 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203392:	02a68463          	beq	a3,a0,ffffffffc02033ba <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203396:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020339a:	fe86b883          	ld	a7,-24(a3)
ffffffffc020339e:	08e8f163          	bgeu	a7,a4,ffffffffc0203420 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02033a2:	04e66f63          	bltu	a2,a4,ffffffffc0203400 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc02033a6:	00f50a63          	beq	a0,a5,ffffffffc02033ba <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02033aa:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02033ae:	05076963          	bltu	a4,a6,ffffffffc0203400 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02033b2:	ff07b603          	ld	a2,-16(a5)
ffffffffc02033b6:	02c77363          	bgeu	a4,a2,ffffffffc02033dc <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02033ba:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02033bc:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02033be:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02033c2:	e390                	sd	a2,0(a5)
ffffffffc02033c4:	e690                	sd	a2,8(a3)
}
ffffffffc02033c6:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02033c8:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02033ca:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc02033cc:	0017079b          	addiw	a5,a4,1
ffffffffc02033d0:	d11c                	sw	a5,32(a0)
}
ffffffffc02033d2:	0141                	addi	sp,sp,16
ffffffffc02033d4:	8082                	ret
    if (le_prev != list) {
ffffffffc02033d6:	fca690e3          	bne	a3,a0,ffffffffc0203396 <insert_vma_struct+0x26>
ffffffffc02033da:	bfd1                	j	ffffffffc02033ae <insert_vma_struct+0x3e>
ffffffffc02033dc:	f31ff0ef          	jal	ra,ffffffffc020330c <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02033e0:	00003697          	auipc	a3,0x3
ffffffffc02033e4:	d6868693          	addi	a3,a3,-664 # ffffffffc0206148 <buddy_system_pmm_manager+0xbd0>
ffffffffc02033e8:	00002617          	auipc	a2,0x2
ffffffffc02033ec:	f0860613          	addi	a2,a2,-248 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02033f0:	08500593          	li	a1,133
ffffffffc02033f4:	00003517          	auipc	a0,0x3
ffffffffc02033f8:	d4450513          	addi	a0,a0,-700 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc02033fc:	84afd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203400:	00003697          	auipc	a3,0x3
ffffffffc0203404:	d8868693          	addi	a3,a3,-632 # ffffffffc0206188 <buddy_system_pmm_manager+0xc10>
ffffffffc0203408:	00002617          	auipc	a2,0x2
ffffffffc020340c:	ee860613          	addi	a2,a2,-280 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0203410:	07d00593          	li	a1,125
ffffffffc0203414:	00003517          	auipc	a0,0x3
ffffffffc0203418:	d2450513          	addi	a0,a0,-732 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc020341c:	82afd0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203420:	00003697          	auipc	a3,0x3
ffffffffc0203424:	d4868693          	addi	a3,a3,-696 # ffffffffc0206168 <buddy_system_pmm_manager+0xbf0>
ffffffffc0203428:	00002617          	auipc	a2,0x2
ffffffffc020342c:	ec860613          	addi	a2,a2,-312 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0203430:	07c00593          	li	a1,124
ffffffffc0203434:	00003517          	auipc	a0,0x3
ffffffffc0203438:	d0450513          	addi	a0,a0,-764 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc020343c:	80afd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203440 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203440:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203442:	03000513          	li	a0,48
vmm_init(void) {
ffffffffc0203446:	fc06                	sd	ra,56(sp)
ffffffffc0203448:	f822                	sd	s0,48(sp)
ffffffffc020344a:	f426                	sd	s1,40(sp)
ffffffffc020344c:	f04a                	sd	s2,32(sp)
ffffffffc020344e:	ec4e                	sd	s3,24(sp)
ffffffffc0203450:	e852                	sd	s4,16(sp)
ffffffffc0203452:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203454:	b96fe0ef          	jal	ra,ffffffffc02017ea <kmalloc>
    if (mm != NULL) {
ffffffffc0203458:	58050e63          	beqz	a0,ffffffffc02039f4 <vmm_init+0x5b4>
    elm->prev = elm->next = elm;
ffffffffc020345c:	e508                	sd	a0,8(a0)
ffffffffc020345e:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203460:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203464:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203468:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020346c:	00012797          	auipc	a5,0x12
ffffffffc0203470:	20c7a783          	lw	a5,524(a5) # ffffffffc0215678 <swap_init_ok>
ffffffffc0203474:	84aa                	mv	s1,a0
ffffffffc0203476:	e7b9                	bnez	a5,ffffffffc02034c4 <vmm_init+0x84>
        else mm->sm_priv = NULL;
ffffffffc0203478:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc020347c:	03200413          	li	s0,50
ffffffffc0203480:	a811                	j	ffffffffc0203494 <vmm_init+0x54>
        vma->vm_start = vm_start;
ffffffffc0203482:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203484:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203486:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc020348a:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020348c:	8526                	mv	a0,s1
ffffffffc020348e:	ee3ff0ef          	jal	ra,ffffffffc0203370 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203492:	cc05                	beqz	s0,ffffffffc02034ca <vmm_init+0x8a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203494:	03000513          	li	a0,48
ffffffffc0203498:	b52fe0ef          	jal	ra,ffffffffc02017ea <kmalloc>
ffffffffc020349c:	85aa                	mv	a1,a0
ffffffffc020349e:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02034a2:	f165                	bnez	a0,ffffffffc0203482 <vmm_init+0x42>
        assert(vma != NULL);
ffffffffc02034a4:	00003697          	auipc	a3,0x3
ffffffffc02034a8:	f0468693          	addi	a3,a3,-252 # ffffffffc02063a8 <buddy_system_pmm_manager+0xe30>
ffffffffc02034ac:	00002617          	auipc	a2,0x2
ffffffffc02034b0:	e4460613          	addi	a2,a2,-444 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02034b4:	0c900593          	li	a1,201
ffffffffc02034b8:	00003517          	auipc	a0,0x3
ffffffffc02034bc:	c8050513          	addi	a0,a0,-896 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc02034c0:	f87fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02034c4:	8b5ff0ef          	jal	ra,ffffffffc0202d78 <swap_init_mm>
ffffffffc02034c8:	bf55                	j	ffffffffc020347c <vmm_init+0x3c>
ffffffffc02034ca:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02034ce:	1f900913          	li	s2,505
ffffffffc02034d2:	a819                	j	ffffffffc02034e8 <vmm_init+0xa8>
        vma->vm_start = vm_start;
ffffffffc02034d4:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02034d6:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02034d8:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02034dc:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02034de:	8526                	mv	a0,s1
ffffffffc02034e0:	e91ff0ef          	jal	ra,ffffffffc0203370 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02034e4:	03240a63          	beq	s0,s2,ffffffffc0203518 <vmm_init+0xd8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02034e8:	03000513          	li	a0,48
ffffffffc02034ec:	afefe0ef          	jal	ra,ffffffffc02017ea <kmalloc>
ffffffffc02034f0:	85aa                	mv	a1,a0
ffffffffc02034f2:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02034f6:	fd79                	bnez	a0,ffffffffc02034d4 <vmm_init+0x94>
        assert(vma != NULL);
ffffffffc02034f8:	00003697          	auipc	a3,0x3
ffffffffc02034fc:	eb068693          	addi	a3,a3,-336 # ffffffffc02063a8 <buddy_system_pmm_manager+0xe30>
ffffffffc0203500:	00002617          	auipc	a2,0x2
ffffffffc0203504:	df060613          	addi	a2,a2,-528 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0203508:	0cf00593          	li	a1,207
ffffffffc020350c:	00003517          	auipc	a0,0x3
ffffffffc0203510:	c2c50513          	addi	a0,a0,-980 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc0203514:	f33fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    return listelm->next;
ffffffffc0203518:	649c                	ld	a5,8(s1)
ffffffffc020351a:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc020351c:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203520:	30f48e63          	beq	s1,a5,ffffffffc020383c <vmm_init+0x3fc>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203524:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203528:	ffe70613          	addi	a2,a4,-2
ffffffffc020352c:	2ad61863          	bne	a2,a3,ffffffffc02037dc <vmm_init+0x39c>
ffffffffc0203530:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203534:	2ae69463          	bne	a3,a4,ffffffffc02037dc <vmm_init+0x39c>
    for (i = 1; i <= step2; i ++) {
ffffffffc0203538:	0715                	addi	a4,a4,5
ffffffffc020353a:	679c                	ld	a5,8(a5)
ffffffffc020353c:	feb712e3          	bne	a4,a1,ffffffffc0203520 <vmm_init+0xe0>
ffffffffc0203540:	4a1d                	li	s4,7
ffffffffc0203542:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203544:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203548:	85a2                	mv	a1,s0
ffffffffc020354a:	8526                	mv	a0,s1
ffffffffc020354c:	de5ff0ef          	jal	ra,ffffffffc0203330 <find_vma>
ffffffffc0203550:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203552:	34050563          	beqz	a0,ffffffffc020389c <vmm_init+0x45c>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203556:	00140593          	addi	a1,s0,1
ffffffffc020355a:	8526                	mv	a0,s1
ffffffffc020355c:	dd5ff0ef          	jal	ra,ffffffffc0203330 <find_vma>
ffffffffc0203560:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203562:	34050d63          	beqz	a0,ffffffffc02038bc <vmm_init+0x47c>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203566:	85d2                	mv	a1,s4
ffffffffc0203568:	8526                	mv	a0,s1
ffffffffc020356a:	dc7ff0ef          	jal	ra,ffffffffc0203330 <find_vma>
        assert(vma3 == NULL);
ffffffffc020356e:	36051763          	bnez	a0,ffffffffc02038dc <vmm_init+0x49c>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203572:	00340593          	addi	a1,s0,3
ffffffffc0203576:	8526                	mv	a0,s1
ffffffffc0203578:	db9ff0ef          	jal	ra,ffffffffc0203330 <find_vma>
        assert(vma4 == NULL);
ffffffffc020357c:	2e051063          	bnez	a0,ffffffffc020385c <vmm_init+0x41c>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203580:	00440593          	addi	a1,s0,4
ffffffffc0203584:	8526                	mv	a0,s1
ffffffffc0203586:	dabff0ef          	jal	ra,ffffffffc0203330 <find_vma>
        assert(vma5 == NULL);
ffffffffc020358a:	2e051963          	bnez	a0,ffffffffc020387c <vmm_init+0x43c>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020358e:	00893783          	ld	a5,8(s2)
ffffffffc0203592:	26879563          	bne	a5,s0,ffffffffc02037fc <vmm_init+0x3bc>
ffffffffc0203596:	01093783          	ld	a5,16(s2)
ffffffffc020359a:	27479163          	bne	a5,s4,ffffffffc02037fc <vmm_init+0x3bc>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020359e:	0089b783          	ld	a5,8(s3)
ffffffffc02035a2:	26879d63          	bne	a5,s0,ffffffffc020381c <vmm_init+0x3dc>
ffffffffc02035a6:	0109b783          	ld	a5,16(s3)
ffffffffc02035aa:	27479963          	bne	a5,s4,ffffffffc020381c <vmm_init+0x3dc>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02035ae:	0415                	addi	s0,s0,5
ffffffffc02035b0:	0a15                	addi	s4,s4,5
ffffffffc02035b2:	f9541be3          	bne	s0,s5,ffffffffc0203548 <vmm_init+0x108>
ffffffffc02035b6:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02035b8:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02035ba:	85a2                	mv	a1,s0
ffffffffc02035bc:	8526                	mv	a0,s1
ffffffffc02035be:	d73ff0ef          	jal	ra,ffffffffc0203330 <find_vma>
ffffffffc02035c2:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc02035c6:	c90d                	beqz	a0,ffffffffc02035f8 <vmm_init+0x1b8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02035c8:	6914                	ld	a3,16(a0)
ffffffffc02035ca:	6510                	ld	a2,8(a0)
ffffffffc02035cc:	00003517          	auipc	a0,0x3
ffffffffc02035d0:	cdc50513          	addi	a0,a0,-804 # ffffffffc02062a8 <buddy_system_pmm_manager+0xd30>
ffffffffc02035d4:	badfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02035d8:	00003697          	auipc	a3,0x3
ffffffffc02035dc:	cf868693          	addi	a3,a3,-776 # ffffffffc02062d0 <buddy_system_pmm_manager+0xd58>
ffffffffc02035e0:	00002617          	auipc	a2,0x2
ffffffffc02035e4:	d1060613          	addi	a2,a2,-752 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02035e8:	0f100593          	li	a1,241
ffffffffc02035ec:	00003517          	auipc	a0,0x3
ffffffffc02035f0:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc02035f4:	e53fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc02035f8:	147d                	addi	s0,s0,-1
ffffffffc02035fa:	fd2410e3          	bne	s0,s2,ffffffffc02035ba <vmm_init+0x17a>
ffffffffc02035fe:	a801                	j	ffffffffc020360e <vmm_init+0x1ce>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203600:	6118                	ld	a4,0(a0)
ffffffffc0203602:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203604:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203606:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203608:	e398                	sd	a4,0(a5)
ffffffffc020360a:	9e2fe0ef          	jal	ra,ffffffffc02017ec <kfree>
    return listelm->next;
ffffffffc020360e:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0203610:	fea498e3          	bne	s1,a0,ffffffffc0203600 <vmm_init+0x1c0>
    kfree(mm); //kfree mm
ffffffffc0203614:	8526                	mv	a0,s1
ffffffffc0203616:	9d6fe0ef          	jal	ra,ffffffffc02017ec <kfree>
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020361a:	00003517          	auipc	a0,0x3
ffffffffc020361e:	cce50513          	addi	a0,a0,-818 # ffffffffc02062e8 <buddy_system_pmm_manager+0xd70>
ffffffffc0203622:	b5ffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203626:	e6afe0ef          	jal	ra,ffffffffc0201c90 <nr_free_pages>
ffffffffc020362a:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020362c:	03000513          	li	a0,48
ffffffffc0203630:	9bafe0ef          	jal	ra,ffffffffc02017ea <kmalloc>
ffffffffc0203634:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203636:	2c050363          	beqz	a0,ffffffffc02038fc <vmm_init+0x4bc>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020363a:	00012797          	auipc	a5,0x12
ffffffffc020363e:	03e7a783          	lw	a5,62(a5) # ffffffffc0215678 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0203642:	e508                	sd	a0,8(a0)
ffffffffc0203644:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203646:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020364a:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020364e:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203652:	18079263          	bnez	a5,ffffffffc02037d6 <vmm_init+0x396>
        else mm->sm_priv = NULL;
ffffffffc0203656:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();
    assert(check_mm_struct != NULL);

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020365a:	00012917          	auipc	s2,0x12
ffffffffc020365e:	fe693903          	ld	s2,-26(s2) # ffffffffc0215640 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0203662:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0203666:	00012717          	auipc	a4,0x12
ffffffffc020366a:	00873d23          	sd	s0,26(a4) # ffffffffc0215680 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020366e:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0203672:	36079163          	bnez	a5,ffffffffc02039d4 <vmm_init+0x594>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203676:	03000513          	li	a0,48
ffffffffc020367a:	970fe0ef          	jal	ra,ffffffffc02017ea <kmalloc>
ffffffffc020367e:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0203680:	2a050263          	beqz	a0,ffffffffc0203924 <vmm_init+0x4e4>
        vma->vm_end = vm_end;
ffffffffc0203684:	002007b7          	lui	a5,0x200
ffffffffc0203688:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc020368c:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020368e:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203690:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc0203694:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0203696:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc020369a:	cd7ff0ef          	jal	ra,ffffffffc0203370 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020369e:	10000593          	li	a1,256
ffffffffc02036a2:	8522                	mv	a0,s0
ffffffffc02036a4:	c8dff0ef          	jal	ra,ffffffffc0203330 <find_vma>
ffffffffc02036a8:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc02036ac:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02036b0:	28a99a63          	bne	s3,a0,ffffffffc0203944 <vmm_init+0x504>
        *(char *)(addr + i) = i;
ffffffffc02036b4:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc02036b8:	0785                	addi	a5,a5,1
ffffffffc02036ba:	fee79de3          	bne	a5,a4,ffffffffc02036b4 <vmm_init+0x274>
        sum += i;
ffffffffc02036be:	6705                	lui	a4,0x1
ffffffffc02036c0:	10000793          	li	a5,256
ffffffffc02036c4:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02036c8:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02036cc:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc02036d0:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc02036d2:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02036d4:	fec79ce3          	bne	a5,a2,ffffffffc02036cc <vmm_init+0x28c>
    }
    assert(sum == 0);
ffffffffc02036d8:	28071663          	bnez	a4,ffffffffc0203964 <vmm_init+0x524>
    return pa2page(PDE_ADDR(pde));
ffffffffc02036dc:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02036e0:	00012a97          	auipc	s5,0x12
ffffffffc02036e4:	f68a8a93          	addi	s5,s5,-152 # ffffffffc0215648 <npage>
ffffffffc02036e8:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02036ec:	078a                	slli	a5,a5,0x2
ffffffffc02036ee:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036f0:	28c7fa63          	bgeu	a5,a2,ffffffffc0203984 <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc02036f4:	00003a17          	auipc	s4,0x3
ffffffffc02036f8:	1dca3a03          	ld	s4,476(s4) # ffffffffc02068d0 <nbase>
ffffffffc02036fc:	414787b3          	sub	a5,a5,s4
ffffffffc0203700:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc0203702:	8799                	srai	a5,a5,0x6
ffffffffc0203704:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0203706:	00c79713          	slli	a4,a5,0xc
ffffffffc020370a:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020370c:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0203710:	28c77663          	bgeu	a4,a2,ffffffffc020399c <vmm_init+0x55c>
ffffffffc0203714:	00012997          	auipc	s3,0x12
ffffffffc0203718:	f4c9b983          	ld	s3,-180(s3) # ffffffffc0215660 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc020371c:	4581                	li	a1,0
ffffffffc020371e:	854a                	mv	a0,s2
ffffffffc0203720:	99b6                	add	s3,s3,a3
ffffffffc0203722:	fcefe0ef          	jal	ra,ffffffffc0201ef0 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203726:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc020372a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020372e:	078a                	slli	a5,a5,0x2
ffffffffc0203730:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203732:	24e7f963          	bgeu	a5,a4,ffffffffc0203984 <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0203736:	00012997          	auipc	s3,0x12
ffffffffc020373a:	f1a98993          	addi	s3,s3,-230 # ffffffffc0215650 <pages>
ffffffffc020373e:	0009b503          	ld	a0,0(s3)
ffffffffc0203742:	414787b3          	sub	a5,a5,s4
ffffffffc0203746:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0203748:	953e                	add	a0,a0,a5
ffffffffc020374a:	4585                	li	a1,1
ffffffffc020374c:	d04fe0ef          	jal	ra,ffffffffc0201c50 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203750:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203754:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203758:	078a                	slli	a5,a5,0x2
ffffffffc020375a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020375c:	22e7f463          	bgeu	a5,a4,ffffffffc0203984 <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0203760:	0009b503          	ld	a0,0(s3)
ffffffffc0203764:	414787b3          	sub	a5,a5,s4
ffffffffc0203768:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020376a:	4585                	li	a1,1
ffffffffc020376c:	953e                	add	a0,a0,a5
ffffffffc020376e:	ce2fe0ef          	jal	ra,ffffffffc0201c50 <free_pages>
    pgdir[0] = 0;
ffffffffc0203772:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0203776:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020377a:	6408                	ld	a0,8(s0)
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc020377c:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203780:	00a40c63          	beq	s0,a0,ffffffffc0203798 <vmm_init+0x358>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203784:	6118                	ld	a4,0(a0)
ffffffffc0203786:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203788:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020378a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020378c:	e398                	sd	a4,0(a5)
ffffffffc020378e:	85efe0ef          	jal	ra,ffffffffc02017ec <kfree>
    return listelm->next;
ffffffffc0203792:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203794:	fea418e3          	bne	s0,a0,ffffffffc0203784 <vmm_init+0x344>
    kfree(mm); //kfree mm
ffffffffc0203798:	8522                	mv	a0,s0
ffffffffc020379a:	852fe0ef          	jal	ra,ffffffffc02017ec <kfree>
    mm_destroy(mm);
    check_mm_struct = NULL;
ffffffffc020379e:	00012797          	auipc	a5,0x12
ffffffffc02037a2:	ee07b123          	sd	zero,-286(a5) # ffffffffc0215680 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02037a6:	ceafe0ef          	jal	ra,ffffffffc0201c90 <nr_free_pages>
ffffffffc02037aa:	20a49563          	bne	s1,a0,ffffffffc02039b4 <vmm_init+0x574>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02037ae:	00003517          	auipc	a0,0x3
ffffffffc02037b2:	bc250513          	addi	a0,a0,-1086 # ffffffffc0206370 <buddy_system_pmm_manager+0xdf8>
ffffffffc02037b6:	9cbfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc02037ba:	7442                	ld	s0,48(sp)
ffffffffc02037bc:	70e2                	ld	ra,56(sp)
ffffffffc02037be:	74a2                	ld	s1,40(sp)
ffffffffc02037c0:	7902                	ld	s2,32(sp)
ffffffffc02037c2:	69e2                	ld	s3,24(sp)
ffffffffc02037c4:	6a42                	ld	s4,16(sp)
ffffffffc02037c6:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02037c8:	00003517          	auipc	a0,0x3
ffffffffc02037cc:	bc850513          	addi	a0,a0,-1080 # ffffffffc0206390 <buddy_system_pmm_manager+0xe18>
}
ffffffffc02037d0:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02037d2:	9affc06f          	j	ffffffffc0200180 <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02037d6:	da2ff0ef          	jal	ra,ffffffffc0202d78 <swap_init_mm>
ffffffffc02037da:	b541                	j	ffffffffc020365a <vmm_init+0x21a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02037dc:	00003697          	auipc	a3,0x3
ffffffffc02037e0:	9e468693          	addi	a3,a3,-1564 # ffffffffc02061c0 <buddy_system_pmm_manager+0xc48>
ffffffffc02037e4:	00002617          	auipc	a2,0x2
ffffffffc02037e8:	b0c60613          	addi	a2,a2,-1268 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02037ec:	0d800593          	li	a1,216
ffffffffc02037f0:	00003517          	auipc	a0,0x3
ffffffffc02037f4:	94850513          	addi	a0,a0,-1720 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc02037f8:	c4ffc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02037fc:	00003697          	auipc	a3,0x3
ffffffffc0203800:	a4c68693          	addi	a3,a3,-1460 # ffffffffc0206248 <buddy_system_pmm_manager+0xcd0>
ffffffffc0203804:	00002617          	auipc	a2,0x2
ffffffffc0203808:	aec60613          	addi	a2,a2,-1300 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc020380c:	0e800593          	li	a1,232
ffffffffc0203810:	00003517          	auipc	a0,0x3
ffffffffc0203814:	92850513          	addi	a0,a0,-1752 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc0203818:	c2ffc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020381c:	00003697          	auipc	a3,0x3
ffffffffc0203820:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0206278 <buddy_system_pmm_manager+0xd00>
ffffffffc0203824:	00002617          	auipc	a2,0x2
ffffffffc0203828:	acc60613          	addi	a2,a2,-1332 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc020382c:	0e900593          	li	a1,233
ffffffffc0203830:	00003517          	auipc	a0,0x3
ffffffffc0203834:	90850513          	addi	a0,a0,-1784 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc0203838:	c0ffc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020383c:	00003697          	auipc	a3,0x3
ffffffffc0203840:	96c68693          	addi	a3,a3,-1684 # ffffffffc02061a8 <buddy_system_pmm_manager+0xc30>
ffffffffc0203844:	00002617          	auipc	a2,0x2
ffffffffc0203848:	aac60613          	addi	a2,a2,-1364 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc020384c:	0d600593          	li	a1,214
ffffffffc0203850:	00003517          	auipc	a0,0x3
ffffffffc0203854:	8e850513          	addi	a0,a0,-1816 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc0203858:	beffc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma4 == NULL);
ffffffffc020385c:	00003697          	auipc	a3,0x3
ffffffffc0203860:	9cc68693          	addi	a3,a3,-1588 # ffffffffc0206228 <buddy_system_pmm_manager+0xcb0>
ffffffffc0203864:	00002617          	auipc	a2,0x2
ffffffffc0203868:	a8c60613          	addi	a2,a2,-1396 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc020386c:	0e400593          	li	a1,228
ffffffffc0203870:	00003517          	auipc	a0,0x3
ffffffffc0203874:	8c850513          	addi	a0,a0,-1848 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc0203878:	bcffc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma5 == NULL);
ffffffffc020387c:	00003697          	auipc	a3,0x3
ffffffffc0203880:	9bc68693          	addi	a3,a3,-1604 # ffffffffc0206238 <buddy_system_pmm_manager+0xcc0>
ffffffffc0203884:	00002617          	auipc	a2,0x2
ffffffffc0203888:	a6c60613          	addi	a2,a2,-1428 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc020388c:	0e600593          	li	a1,230
ffffffffc0203890:	00003517          	auipc	a0,0x3
ffffffffc0203894:	8a850513          	addi	a0,a0,-1880 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc0203898:	baffc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma1 != NULL);
ffffffffc020389c:	00003697          	auipc	a3,0x3
ffffffffc02038a0:	95c68693          	addi	a3,a3,-1700 # ffffffffc02061f8 <buddy_system_pmm_manager+0xc80>
ffffffffc02038a4:	00002617          	auipc	a2,0x2
ffffffffc02038a8:	a4c60613          	addi	a2,a2,-1460 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02038ac:	0de00593          	li	a1,222
ffffffffc02038b0:	00003517          	auipc	a0,0x3
ffffffffc02038b4:	88850513          	addi	a0,a0,-1912 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc02038b8:	b8ffc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma2 != NULL);
ffffffffc02038bc:	00003697          	auipc	a3,0x3
ffffffffc02038c0:	94c68693          	addi	a3,a3,-1716 # ffffffffc0206208 <buddy_system_pmm_manager+0xc90>
ffffffffc02038c4:	00002617          	auipc	a2,0x2
ffffffffc02038c8:	a2c60613          	addi	a2,a2,-1492 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02038cc:	0e000593          	li	a1,224
ffffffffc02038d0:	00003517          	auipc	a0,0x3
ffffffffc02038d4:	86850513          	addi	a0,a0,-1944 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc02038d8:	b6ffc0ef          	jal	ra,ffffffffc0200446 <__panic>
        assert(vma3 == NULL);
ffffffffc02038dc:	00003697          	auipc	a3,0x3
ffffffffc02038e0:	93c68693          	addi	a3,a3,-1732 # ffffffffc0206218 <buddy_system_pmm_manager+0xca0>
ffffffffc02038e4:	00002617          	auipc	a2,0x2
ffffffffc02038e8:	a0c60613          	addi	a2,a2,-1524 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02038ec:	0e200593          	li	a1,226
ffffffffc02038f0:	00003517          	auipc	a0,0x3
ffffffffc02038f4:	84850513          	addi	a0,a0,-1976 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc02038f8:	b4ffc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02038fc:	00003697          	auipc	a3,0x3
ffffffffc0203900:	abc68693          	addi	a3,a3,-1348 # ffffffffc02063b8 <buddy_system_pmm_manager+0xe40>
ffffffffc0203904:	00002617          	auipc	a2,0x2
ffffffffc0203908:	9ec60613          	addi	a2,a2,-1556 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc020390c:	10100593          	li	a1,257
ffffffffc0203910:	00003517          	auipc	a0,0x3
ffffffffc0203914:	82850513          	addi	a0,a0,-2008 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
    check_mm_struct = mm_create();
ffffffffc0203918:	00012797          	auipc	a5,0x12
ffffffffc020391c:	d607b423          	sd	zero,-664(a5) # ffffffffc0215680 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0203920:	b27fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(vma != NULL);
ffffffffc0203924:	00003697          	auipc	a3,0x3
ffffffffc0203928:	a8468693          	addi	a3,a3,-1404 # ffffffffc02063a8 <buddy_system_pmm_manager+0xe30>
ffffffffc020392c:	00002617          	auipc	a2,0x2
ffffffffc0203930:	9c460613          	addi	a2,a2,-1596 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0203934:	10800593          	li	a1,264
ffffffffc0203938:	00003517          	auipc	a0,0x3
ffffffffc020393c:	80050513          	addi	a0,a0,-2048 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc0203940:	b07fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203944:	00003697          	auipc	a3,0x3
ffffffffc0203948:	9d468693          	addi	a3,a3,-1580 # ffffffffc0206318 <buddy_system_pmm_manager+0xda0>
ffffffffc020394c:	00002617          	auipc	a2,0x2
ffffffffc0203950:	9a460613          	addi	a2,a2,-1628 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0203954:	10d00593          	li	a1,269
ffffffffc0203958:	00002517          	auipc	a0,0x2
ffffffffc020395c:	7e050513          	addi	a0,a0,2016 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc0203960:	ae7fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(sum == 0);
ffffffffc0203964:	00003697          	auipc	a3,0x3
ffffffffc0203968:	9d468693          	addi	a3,a3,-1580 # ffffffffc0206338 <buddy_system_pmm_manager+0xdc0>
ffffffffc020396c:	00002617          	auipc	a2,0x2
ffffffffc0203970:	98460613          	addi	a2,a2,-1660 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0203974:	11700593          	li	a1,279
ffffffffc0203978:	00002517          	auipc	a0,0x2
ffffffffc020397c:	7c050513          	addi	a0,a0,1984 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc0203980:	ac7fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203984:	00002617          	auipc	a2,0x2
ffffffffc0203988:	d0460613          	addi	a2,a2,-764 # ffffffffc0205688 <buddy_system_pmm_manager+0x110>
ffffffffc020398c:	06200593          	li	a1,98
ffffffffc0203990:	00002517          	auipc	a0,0x2
ffffffffc0203994:	c6050513          	addi	a0,a0,-928 # ffffffffc02055f0 <buddy_system_pmm_manager+0x78>
ffffffffc0203998:	aaffc0ef          	jal	ra,ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc020399c:	00002617          	auipc	a2,0x2
ffffffffc02039a0:	c2c60613          	addi	a2,a2,-980 # ffffffffc02055c8 <buddy_system_pmm_manager+0x50>
ffffffffc02039a4:	06900593          	li	a1,105
ffffffffc02039a8:	00002517          	auipc	a0,0x2
ffffffffc02039ac:	c4850513          	addi	a0,a0,-952 # ffffffffc02055f0 <buddy_system_pmm_manager+0x78>
ffffffffc02039b0:	a97fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02039b4:	00003697          	auipc	a3,0x3
ffffffffc02039b8:	99468693          	addi	a3,a3,-1644 # ffffffffc0206348 <buddy_system_pmm_manager+0xdd0>
ffffffffc02039bc:	00002617          	auipc	a2,0x2
ffffffffc02039c0:	93460613          	addi	a2,a2,-1740 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02039c4:	12400593          	li	a1,292
ffffffffc02039c8:	00002517          	auipc	a0,0x2
ffffffffc02039cc:	77050513          	addi	a0,a0,1904 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc02039d0:	a77fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02039d4:	00003697          	auipc	a3,0x3
ffffffffc02039d8:	93468693          	addi	a3,a3,-1740 # ffffffffc0206308 <buddy_system_pmm_manager+0xd90>
ffffffffc02039dc:	00002617          	auipc	a2,0x2
ffffffffc02039e0:	91460613          	addi	a2,a2,-1772 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc02039e4:	10500593          	li	a1,261
ffffffffc02039e8:	00002517          	auipc	a0,0x2
ffffffffc02039ec:	75050513          	addi	a0,a0,1872 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc02039f0:	a57fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(mm != NULL);
ffffffffc02039f4:	00003697          	auipc	a3,0x3
ffffffffc02039f8:	9dc68693          	addi	a3,a3,-1572 # ffffffffc02063d0 <buddy_system_pmm_manager+0xe58>
ffffffffc02039fc:	00002617          	auipc	a2,0x2
ffffffffc0203a00:	8f460613          	addi	a2,a2,-1804 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0203a04:	0c200593          	li	a1,194
ffffffffc0203a08:	00002517          	auipc	a0,0x2
ffffffffc0203a0c:	73050513          	addi	a0,a0,1840 # ffffffffc0206138 <buddy_system_pmm_manager+0xbc0>
ffffffffc0203a10:	a37fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203a14 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203a14:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203a16:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203a18:	f022                	sd	s0,32(sp)
ffffffffc0203a1a:	ec26                	sd	s1,24(sp)
ffffffffc0203a1c:	f406                	sd	ra,40(sp)
ffffffffc0203a1e:	e84a                	sd	s2,16(sp)
ffffffffc0203a20:	8432                	mv	s0,a2
ffffffffc0203a22:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203a24:	90dff0ef          	jal	ra,ffffffffc0203330 <find_vma>

    pgfault_num++;
ffffffffc0203a28:	00012797          	auipc	a5,0x12
ffffffffc0203a2c:	c607a783          	lw	a5,-928(a5) # ffffffffc0215688 <pgfault_num>
ffffffffc0203a30:	2785                	addiw	a5,a5,1
ffffffffc0203a32:	00012717          	auipc	a4,0x12
ffffffffc0203a36:	c4f72b23          	sw	a5,-938(a4) # ffffffffc0215688 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203a3a:	c541                	beqz	a0,ffffffffc0203ac2 <do_pgfault+0xae>
ffffffffc0203a3c:	651c                	ld	a5,8(a0)
ffffffffc0203a3e:	08f46263          	bltu	s0,a5,ffffffffc0203ac2 <do_pgfault+0xae>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203a42:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203a44:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203a46:	8b89                	andi	a5,a5,2
ffffffffc0203a48:	ebb9                	bnez	a5,ffffffffc0203a9e <do_pgfault+0x8a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203a4a:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203a4c:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203a4e:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203a50:	4605                	li	a2,1
ffffffffc0203a52:	85a2                	mv	a1,s0
ffffffffc0203a54:	a76fe0ef          	jal	ra,ffffffffc0201cca <get_pte>
ffffffffc0203a58:	c551                	beqz	a0,ffffffffc0203ae4 <do_pgfault+0xd0>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0203a5a:	610c                	ld	a1,0(a0)
ffffffffc0203a5c:	c1b9                	beqz	a1,ffffffffc0203aa2 <do_pgfault+0x8e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) 
ffffffffc0203a5e:	00012797          	auipc	a5,0x12
ffffffffc0203a62:	c1a7a783          	lw	a5,-998(a5) # ffffffffc0215678 <swap_init_ok>
ffffffffc0203a66:	c7bd                	beqz	a5,ffffffffc0203ad4 <do_pgfault+0xc0>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）根据mm和addr，尝试将右侧磁盘页面的内容放入页面管理的内存中。
            //(2) 根据mm、addr和page，设置物理addr<--->虚拟(logical)addr的映射
            //(3) 使页面可交换。
            swap_in(mm, addr, &page);
ffffffffc0203a68:	85a2                	mv	a1,s0
ffffffffc0203a6a:	0030                	addi	a2,sp,8
ffffffffc0203a6c:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203a6e:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0203a70:	c34ff0ef          	jal	ra,ffffffffc0202ea4 <swap_in>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc0203a74:	65a2                	ld	a1,8(sp)
ffffffffc0203a76:	6c88                	ld	a0,24(s1)
ffffffffc0203a78:	86ca                	mv	a3,s2
ffffffffc0203a7a:	8622                	mv	a2,s0
ffffffffc0203a7c:	d10fe0ef          	jal	ra,ffffffffc0201f8c <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc0203a80:	6622                	ld	a2,8(sp)
ffffffffc0203a82:	4685                	li	a3,1
ffffffffc0203a84:	85a2                	mv	a1,s0
ffffffffc0203a86:	8526                	mv	a0,s1
ffffffffc0203a88:	afcff0ef          	jal	ra,ffffffffc0202d84 <swap_map_swappable>
            
            page->pra_vaddr = addr;  //必须等待前几条设置好权限才能写这行
ffffffffc0203a8c:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203a8e:	4501                	li	a0,0
            page->pra_vaddr = addr;  //必须等待前几条设置好权限才能写这行
ffffffffc0203a90:	ff80                	sd	s0,56(a5)
failed:
    return ret;
ffffffffc0203a92:	70a2                	ld	ra,40(sp)
ffffffffc0203a94:	7402                	ld	s0,32(sp)
ffffffffc0203a96:	64e2                	ld	s1,24(sp)
ffffffffc0203a98:	6942                	ld	s2,16(sp)
ffffffffc0203a9a:	6145                	addi	sp,sp,48
ffffffffc0203a9c:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0203a9e:	495d                	li	s2,23
ffffffffc0203aa0:	b76d                	j	ffffffffc0203a4a <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203aa2:	6c88                	ld	a0,24(s1)
ffffffffc0203aa4:	864a                	mv	a2,s2
ffffffffc0203aa6:	85a2                	mv	a1,s0
ffffffffc0203aa8:	992ff0ef          	jal	ra,ffffffffc0202c3a <pgdir_alloc_page>
ffffffffc0203aac:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0203aae:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203ab0:	f3ed                	bnez	a5,ffffffffc0203a92 <do_pgfault+0x7e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203ab2:	00003517          	auipc	a0,0x3
ffffffffc0203ab6:	97e50513          	addi	a0,a0,-1666 # ffffffffc0206430 <buddy_system_pmm_manager+0xeb8>
ffffffffc0203aba:	ec6fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203abe:	5571                	li	a0,-4
            goto failed;
ffffffffc0203ac0:	bfc9                	j	ffffffffc0203a92 <do_pgfault+0x7e>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203ac2:	85a2                	mv	a1,s0
ffffffffc0203ac4:	00003517          	auipc	a0,0x3
ffffffffc0203ac8:	91c50513          	addi	a0,a0,-1764 # ffffffffc02063e0 <buddy_system_pmm_manager+0xe68>
ffffffffc0203acc:	eb4fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = -E_INVAL;
ffffffffc0203ad0:	5575                	li	a0,-3
        goto failed;
ffffffffc0203ad2:	b7c1                	j	ffffffffc0203a92 <do_pgfault+0x7e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203ad4:	00003517          	auipc	a0,0x3
ffffffffc0203ad8:	98450513          	addi	a0,a0,-1660 # ffffffffc0206458 <buddy_system_pmm_manager+0xee0>
ffffffffc0203adc:	ea4fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203ae0:	5571                	li	a0,-4
            goto failed;
ffffffffc0203ae2:	bf45                	j	ffffffffc0203a92 <do_pgfault+0x7e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0203ae4:	00003517          	auipc	a0,0x3
ffffffffc0203ae8:	92c50513          	addi	a0,a0,-1748 # ffffffffc0206410 <buddy_system_pmm_manager+0xe98>
ffffffffc0203aec:	e94fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203af0:	5571                	li	a0,-4
        goto failed;
ffffffffc0203af2:	b745                	j	ffffffffc0203a92 <do_pgfault+0x7e>

ffffffffc0203af4 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203af4:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203af6:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203af8:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203afa:	a6ffc0ef          	jal	ra,ffffffffc0200568 <ide_device_valid>
ffffffffc0203afe:	cd01                	beqz	a0,ffffffffc0203b16 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203b00:	4505                	li	a0,1
ffffffffc0203b02:	a6dfc0ef          	jal	ra,ffffffffc020056e <ide_device_size>
}
ffffffffc0203b06:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203b08:	810d                	srli	a0,a0,0x3
ffffffffc0203b0a:	00012797          	auipc	a5,0x12
ffffffffc0203b0e:	b4a7bf23          	sd	a0,-1186(a5) # ffffffffc0215668 <max_swap_offset>
}
ffffffffc0203b12:	0141                	addi	sp,sp,16
ffffffffc0203b14:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203b16:	00003617          	auipc	a2,0x3
ffffffffc0203b1a:	96a60613          	addi	a2,a2,-1686 # ffffffffc0206480 <buddy_system_pmm_manager+0xf08>
ffffffffc0203b1e:	45b5                	li	a1,13
ffffffffc0203b20:	00003517          	auipc	a0,0x3
ffffffffc0203b24:	98050513          	addi	a0,a0,-1664 # ffffffffc02064a0 <buddy_system_pmm_manager+0xf28>
ffffffffc0203b28:	91ffc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203b2c <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203b2c:	1141                	addi	sp,sp,-16
ffffffffc0203b2e:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203b30:	00855793          	srli	a5,a0,0x8
ffffffffc0203b34:	cbb1                	beqz	a5,ffffffffc0203b88 <swapfs_read+0x5c>
ffffffffc0203b36:	00012717          	auipc	a4,0x12
ffffffffc0203b3a:	b3273703          	ld	a4,-1230(a4) # ffffffffc0215668 <max_swap_offset>
ffffffffc0203b3e:	04e7f563          	bgeu	a5,a4,ffffffffc0203b88 <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0203b42:	00012617          	auipc	a2,0x12
ffffffffc0203b46:	b0e63603          	ld	a2,-1266(a2) # ffffffffc0215650 <pages>
ffffffffc0203b4a:	8d91                	sub	a1,a1,a2
ffffffffc0203b4c:	4065d613          	srai	a2,a1,0x6
ffffffffc0203b50:	00003717          	auipc	a4,0x3
ffffffffc0203b54:	d8073703          	ld	a4,-640(a4) # ffffffffc02068d0 <nbase>
ffffffffc0203b58:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0203b5a:	00c61713          	slli	a4,a2,0xc
ffffffffc0203b5e:	8331                	srli	a4,a4,0xc
ffffffffc0203b60:	00012697          	auipc	a3,0x12
ffffffffc0203b64:	ae86b683          	ld	a3,-1304(a3) # ffffffffc0215648 <npage>
ffffffffc0203b68:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203b6c:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0203b6e:	02d77963          	bgeu	a4,a3,ffffffffc0203ba0 <swapfs_read+0x74>
}
ffffffffc0203b72:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203b74:	00012797          	auipc	a5,0x12
ffffffffc0203b78:	aec7b783          	ld	a5,-1300(a5) # ffffffffc0215660 <va_pa_offset>
ffffffffc0203b7c:	46a1                	li	a3,8
ffffffffc0203b7e:	963e                	add	a2,a2,a5
ffffffffc0203b80:	4505                	li	a0,1
}
ffffffffc0203b82:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203b84:	9f1fc06f          	j	ffffffffc0200574 <ide_read_secs>
ffffffffc0203b88:	86aa                	mv	a3,a0
ffffffffc0203b8a:	00003617          	auipc	a2,0x3
ffffffffc0203b8e:	92e60613          	addi	a2,a2,-1746 # ffffffffc02064b8 <buddy_system_pmm_manager+0xf40>
ffffffffc0203b92:	45d1                	li	a1,20
ffffffffc0203b94:	00003517          	auipc	a0,0x3
ffffffffc0203b98:	90c50513          	addi	a0,a0,-1780 # ffffffffc02064a0 <buddy_system_pmm_manager+0xf28>
ffffffffc0203b9c:	8abfc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203ba0:	86b2                	mv	a3,a2
ffffffffc0203ba2:	06900593          	li	a1,105
ffffffffc0203ba6:	00002617          	auipc	a2,0x2
ffffffffc0203baa:	a2260613          	addi	a2,a2,-1502 # ffffffffc02055c8 <buddy_system_pmm_manager+0x50>
ffffffffc0203bae:	00002517          	auipc	a0,0x2
ffffffffc0203bb2:	a4250513          	addi	a0,a0,-1470 # ffffffffc02055f0 <buddy_system_pmm_manager+0x78>
ffffffffc0203bb6:	891fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203bba <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203bba:	1141                	addi	sp,sp,-16
ffffffffc0203bbc:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203bbe:	00855793          	srli	a5,a0,0x8
ffffffffc0203bc2:	cbb1                	beqz	a5,ffffffffc0203c16 <swapfs_write+0x5c>
ffffffffc0203bc4:	00012717          	auipc	a4,0x12
ffffffffc0203bc8:	aa473703          	ld	a4,-1372(a4) # ffffffffc0215668 <max_swap_offset>
ffffffffc0203bcc:	04e7f563          	bgeu	a5,a4,ffffffffc0203c16 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0203bd0:	00012617          	auipc	a2,0x12
ffffffffc0203bd4:	a8063603          	ld	a2,-1408(a2) # ffffffffc0215650 <pages>
ffffffffc0203bd8:	8d91                	sub	a1,a1,a2
ffffffffc0203bda:	4065d613          	srai	a2,a1,0x6
ffffffffc0203bde:	00003717          	auipc	a4,0x3
ffffffffc0203be2:	cf273703          	ld	a4,-782(a4) # ffffffffc02068d0 <nbase>
ffffffffc0203be6:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0203be8:	00c61713          	slli	a4,a2,0xc
ffffffffc0203bec:	8331                	srli	a4,a4,0xc
ffffffffc0203bee:	00012697          	auipc	a3,0x12
ffffffffc0203bf2:	a5a6b683          	ld	a3,-1446(a3) # ffffffffc0215648 <npage>
ffffffffc0203bf6:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203bfa:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0203bfc:	02d77963          	bgeu	a4,a3,ffffffffc0203c2e <swapfs_write+0x74>
}
ffffffffc0203c00:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c02:	00012797          	auipc	a5,0x12
ffffffffc0203c06:	a5e7b783          	ld	a5,-1442(a5) # ffffffffc0215660 <va_pa_offset>
ffffffffc0203c0a:	46a1                	li	a3,8
ffffffffc0203c0c:	963e                	add	a2,a2,a5
ffffffffc0203c0e:	4505                	li	a0,1
}
ffffffffc0203c10:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c12:	987fc06f          	j	ffffffffc0200598 <ide_write_secs>
ffffffffc0203c16:	86aa                	mv	a3,a0
ffffffffc0203c18:	00003617          	auipc	a2,0x3
ffffffffc0203c1c:	8a060613          	addi	a2,a2,-1888 # ffffffffc02064b8 <buddy_system_pmm_manager+0xf40>
ffffffffc0203c20:	45e5                	li	a1,25
ffffffffc0203c22:	00003517          	auipc	a0,0x3
ffffffffc0203c26:	87e50513          	addi	a0,a0,-1922 # ffffffffc02064a0 <buddy_system_pmm_manager+0xf28>
ffffffffc0203c2a:	81dfc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203c2e:	86b2                	mv	a3,a2
ffffffffc0203c30:	06900593          	li	a1,105
ffffffffc0203c34:	00002617          	auipc	a2,0x2
ffffffffc0203c38:	99460613          	addi	a2,a2,-1644 # ffffffffc02055c8 <buddy_system_pmm_manager+0x50>
ffffffffc0203c3c:	00002517          	auipc	a0,0x2
ffffffffc0203c40:	9b450513          	addi	a0,a0,-1612 # ffffffffc02055f0 <buddy_system_pmm_manager+0x78>
ffffffffc0203c44:	803fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203c48 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203c48:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203c4a:	9402                	jalr	s0

	jal do_exit
ffffffffc0203c4c:	3c8000ef          	jal	ra,ffffffffc0204014 <do_exit>

ffffffffc0203c50 <alloc_proc>:
/* 
 * alloc_proc - alloc a proc_struct and init all fields of proc_struct
 * 功能:创建一个proc_struct并初始化proc_struct的所有成员变量
 */
static struct proc_struct *
alloc_proc(void) {
ffffffffc0203c50:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203c52:	0e800513          	li	a0,232
alloc_proc(void) {
ffffffffc0203c56:	e022                	sd	s0,0(sp)
ffffffffc0203c58:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203c5a:	b91fd0ef          	jal	ra,ffffffffc02017ea <kmalloc>
ffffffffc0203c5e:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0203c60:	c521                	beqz	a0,ffffffffc0203ca8 <alloc_proc+0x58>
     *       uint32_t flags;                             // 进程标志
     *       char name[PROC_NAME_LEN + 1];               // 进程名称
     */
    //注:初始化是指产生一个空的结构体(或许与c不允许在定义初始化默认值有关),两个memset初始化的变量参考自proc_init()
    //   附注:初始化的具体严格要求参考proc_init()的相关检查语句。
    proc->state        = PROC_UNINIT;
ffffffffc0203c62:	57fd                	li	a5,-1
ffffffffc0203c64:	1782                	slli	a5,a5,0x20
ffffffffc0203c66:	e11c                	sd	a5,0(a0)
    proc->runs         = 0; 
    proc->kstack       = 0;    
    proc->need_resched = 0;
    proc->parent       = NULL;
    proc->mm           = NULL;
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0203c68:	07000613          	li	a2,112
ffffffffc0203c6c:	4581                	li	a1,0
    proc->runs         = 0; 
ffffffffc0203c6e:	00052423          	sw	zero,8(a0)
    proc->kstack       = 0;    
ffffffffc0203c72:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc0203c76:	00052c23          	sw	zero,24(a0)
    proc->parent       = NULL;
ffffffffc0203c7a:	02053023          	sd	zero,32(a0)
    proc->mm           = NULL;
ffffffffc0203c7e:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0203c82:	03050513          	addi	a0,a0,48
ffffffffc0203c86:	3c5000ef          	jal	ra,ffffffffc020484a <memset>
    proc->tf           = NULL;
    proc->cr3          = boot_cr3;
ffffffffc0203c8a:	00012797          	auipc	a5,0x12
ffffffffc0203c8e:	9ae7b783          	ld	a5,-1618(a5) # ffffffffc0215638 <boot_cr3>
    proc->tf           = NULL;
ffffffffc0203c92:	0a043023          	sd	zero,160(s0)
    proc->cr3          = boot_cr3;
ffffffffc0203c96:	f45c                	sd	a5,168(s0)
    proc->flags        = 0;
ffffffffc0203c98:	0a042823          	sw	zero,176(s0)
    memset(proc->name, 0, PROC_NAME_LEN+1);                      
ffffffffc0203c9c:	4641                	li	a2,16
ffffffffc0203c9e:	4581                	li	a1,0
ffffffffc0203ca0:	0b440513          	addi	a0,s0,180
ffffffffc0203ca4:	3a7000ef          	jal	ra,ffffffffc020484a <memset>
//################################################################################
    }
    return proc;
}
ffffffffc0203ca8:	60a2                	ld	ra,8(sp)
ffffffffc0203caa:	8522                	mv	a0,s0
ffffffffc0203cac:	6402                	ld	s0,0(sp)
ffffffffc0203cae:	0141                	addi	sp,sp,16
ffffffffc0203cb0:	8082                	ret

ffffffffc0203cb2 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0203cb2:	00012797          	auipc	a5,0x12
ffffffffc0203cb6:	9de7b783          	ld	a5,-1570(a5) # ffffffffc0215690 <current>
ffffffffc0203cba:	73c8                	ld	a0,160(a5)
ffffffffc0203cbc:	eb1fc06f          	j	ffffffffc0200b6c <forkrets>

ffffffffc0203cc0 <init_main>:

/* init_main - the second kernel thread used to create user_main kernel threads
 * 功能:用于创建第二个内核线程user_main
 */
static int
init_main(void *arg) {
ffffffffc0203cc0:	7179                	addi	sp,sp,-48
ffffffffc0203cc2:	ec26                	sd	s1,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc0203cc4:	00012497          	auipc	s1,0x12
ffffffffc0203cc8:	93448493          	addi	s1,s1,-1740 # ffffffffc02155f8 <name.2>
init_main(void *arg) {
ffffffffc0203ccc:	f022                	sd	s0,32(sp)
ffffffffc0203cce:	e84a                	sd	s2,16(sp)
ffffffffc0203cd0:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0203cd2:	00012917          	auipc	s2,0x12
ffffffffc0203cd6:	9be93903          	ld	s2,-1602(s2) # ffffffffc0215690 <current>
    memset(name, 0, sizeof(name));
ffffffffc0203cda:	4641                	li	a2,16
ffffffffc0203cdc:	4581                	li	a1,0
ffffffffc0203cde:	8526                	mv	a0,s1
init_main(void *arg) {
ffffffffc0203ce0:	f406                	sd	ra,40(sp)
ffffffffc0203ce2:	e44e                	sd	s3,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0203ce4:	00492983          	lw	s3,4(s2)
    memset(name, 0, sizeof(name));
ffffffffc0203ce8:	363000ef          	jal	ra,ffffffffc020484a <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0203cec:	0b490593          	addi	a1,s2,180
ffffffffc0203cf0:	463d                	li	a2,15
ffffffffc0203cf2:	8526                	mv	a0,s1
ffffffffc0203cf4:	369000ef          	jal	ra,ffffffffc020485c <memcpy>
ffffffffc0203cf8:	862a                	mv	a2,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0203cfa:	85ce                	mv	a1,s3
ffffffffc0203cfc:	00002517          	auipc	a0,0x2
ffffffffc0203d00:	7dc50513          	addi	a0,a0,2012 # ffffffffc02064d8 <buddy_system_pmm_manager+0xf60>
ffffffffc0203d04:	c7cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc0203d08:	85a2                	mv	a1,s0
ffffffffc0203d0a:	00002517          	auipc	a0,0x2
ffffffffc0203d0e:	7f650513          	addi	a0,a0,2038 # ffffffffc0206500 <buddy_system_pmm_manager+0xf88>
ffffffffc0203d12:	c6efc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc0203d16:	00002517          	auipc	a0,0x2
ffffffffc0203d1a:	7fa50513          	addi	a0,a0,2042 # ffffffffc0206510 <buddy_system_pmm_manager+0xf98>
ffffffffc0203d1e:	c62fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
}
ffffffffc0203d22:	70a2                	ld	ra,40(sp)
ffffffffc0203d24:	7402                	ld	s0,32(sp)
ffffffffc0203d26:	64e2                	ld	s1,24(sp)
ffffffffc0203d28:	6942                	ld	s2,16(sp)
ffffffffc0203d2a:	69a2                	ld	s3,8(sp)
ffffffffc0203d2c:	4501                	li	a0,0
ffffffffc0203d2e:	6145                	addi	sp,sp,48
ffffffffc0203d30:	8082                	ret

ffffffffc0203d32 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0203d32:	7179                	addi	sp,sp,-48
ffffffffc0203d34:	ec4a                	sd	s2,24(sp)
    if (proc != current) 
ffffffffc0203d36:	00012917          	auipc	s2,0x12
ffffffffc0203d3a:	95a90913          	addi	s2,s2,-1702 # ffffffffc0215690 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0203d3e:	f026                	sd	s1,32(sp)
    if (proc != current) 
ffffffffc0203d40:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0203d44:	f406                	sd	ra,40(sp)
ffffffffc0203d46:	e84e                	sd	s3,16(sp)
    if (proc != current) 
ffffffffc0203d48:	02a48963          	beq	s1,a0,ffffffffc0203d7a <proc_run+0x48>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203d4c:	100027f3          	csrr	a5,sstatus
ffffffffc0203d50:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203d52:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203d54:	e3a1                	bnez	a5,ffffffffc0203d94 <proc_run+0x62>
            lcr3(proc->cr3);
ffffffffc0203d56:	755c                	ld	a5,168(a0)

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc0203d58:	80000737          	lui	a4,0x80000
            current = proc;
ffffffffc0203d5c:	00a93023          	sd	a0,0(s2)
ffffffffc0203d60:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc0203d64:	8fd9                	or	a5,a5,a4
ffffffffc0203d66:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc0203d6a:	03050593          	addi	a1,a0,48
ffffffffc0203d6e:	03048513          	addi	a0,s1,48
ffffffffc0203d72:	528000ef          	jal	ra,ffffffffc020429a <switch_to>
    if (flag) {
ffffffffc0203d76:	00099863          	bnez	s3,ffffffffc0203d86 <proc_run+0x54>
}
ffffffffc0203d7a:	70a2                	ld	ra,40(sp)
ffffffffc0203d7c:	7482                	ld	s1,32(sp)
ffffffffc0203d7e:	6962                	ld	s2,24(sp)
ffffffffc0203d80:	69c2                	ld	s3,16(sp)
ffffffffc0203d82:	6145                	addi	sp,sp,48
ffffffffc0203d84:	8082                	ret
ffffffffc0203d86:	70a2                	ld	ra,40(sp)
ffffffffc0203d88:	7482                	ld	s1,32(sp)
ffffffffc0203d8a:	6962                	ld	s2,24(sp)
ffffffffc0203d8c:	69c2                	ld	s3,16(sp)
ffffffffc0203d8e:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0203d90:	82dfc06f          	j	ffffffffc02005bc <intr_enable>
ffffffffc0203d94:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203d96:	82dfc0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        return 1;
ffffffffc0203d9a:	6522                	ld	a0,8(sp)
ffffffffc0203d9c:	4985                	li	s3,1
ffffffffc0203d9e:	bf65                	j	ffffffffc0203d56 <proc_run+0x24>

ffffffffc0203da0 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0203da0:	7179                	addi	sp,sp,-48
ffffffffc0203da2:	e44e                	sd	s3,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0203da4:	00012997          	auipc	s3,0x12
ffffffffc0203da8:	90498993          	addi	s3,s3,-1788 # ffffffffc02156a8 <nr_process>
ffffffffc0203dac:	0009a703          	lw	a4,0(s3)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0203db0:	f406                	sd	ra,40(sp)
ffffffffc0203db2:	f022                	sd	s0,32(sp)
ffffffffc0203db4:	ec26                	sd	s1,24(sp)
ffffffffc0203db6:	e84a                	sd	s2,16(sp)
ffffffffc0203db8:	e052                	sd	s4,0(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0203dba:	6785                	lui	a5,0x1
ffffffffc0203dbc:	1cf75363          	bge	a4,a5,ffffffffc0203f82 <do_fork+0x1e2>
ffffffffc0203dc0:	892e                	mv	s2,a1
ffffffffc0203dc2:	8432                	mv	s0,a2
     proc=alloc_proc();//1
ffffffffc0203dc4:	e8dff0ef          	jal	ra,ffffffffc0203c50 <alloc_proc>
    if (++ last_pid >= MAX_PID) {
ffffffffc0203dc8:	00006897          	auipc	a7,0x6
ffffffffc0203dcc:	27888893          	addi	a7,a7,632 # ffffffffc020a040 <last_pid.1>
ffffffffc0203dd0:	0008a783          	lw	a5,0(a7)
     proc->parent=current;
ffffffffc0203dd4:	00012a17          	auipc	s4,0x12
ffffffffc0203dd8:	8bca0a13          	addi	s4,s4,-1860 # ffffffffc0215690 <current>
ffffffffc0203ddc:	000a3703          	ld	a4,0(s4)
    if (++ last_pid >= MAX_PID) {
ffffffffc0203de0:	0017881b          	addiw	a6,a5,1
ffffffffc0203de4:	0108a023          	sw	a6,0(a7)
     proc->parent=current;
ffffffffc0203de8:	f118                	sd	a4,32(a0)
    if (++ last_pid >= MAX_PID) {
ffffffffc0203dea:	6789                	lui	a5,0x2
     proc=alloc_proc();//1
ffffffffc0203dec:	84aa                	mv	s1,a0
    if (++ last_pid >= MAX_PID) {
ffffffffc0203dee:	10f85763          	bge	a6,a5,ffffffffc0203efc <do_fork+0x15c>
    if (last_pid >= next_safe) {
ffffffffc0203df2:	00006e17          	auipc	t3,0x6
ffffffffc0203df6:	252e0e13          	addi	t3,t3,594 # ffffffffc020a044 <next_safe.0>
ffffffffc0203dfa:	000e2783          	lw	a5,0(t3)
ffffffffc0203dfe:	10f85763          	bge	a6,a5,ffffffffc0203f0c <do_fork+0x16c>
     proc->pid=get_pid();
ffffffffc0203e02:	0104a223          	sw	a6,4(s1)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0203e06:	4509                	li	a0,2
ffffffffc0203e08:	db7fd0ef          	jal	ra,ffffffffc0201bbe <alloc_pages>
    if (page != NULL) {
ffffffffc0203e0c:	cd0d                	beqz	a0,ffffffffc0203e46 <do_fork+0xa6>
    return page - pages + nbase;
ffffffffc0203e0e:	00012697          	auipc	a3,0x12
ffffffffc0203e12:	8426b683          	ld	a3,-1982(a3) # ffffffffc0215650 <pages>
ffffffffc0203e16:	40d506b3          	sub	a3,a0,a3
ffffffffc0203e1a:	8699                	srai	a3,a3,0x6
ffffffffc0203e1c:	00003517          	auipc	a0,0x3
ffffffffc0203e20:	ab453503          	ld	a0,-1356(a0) # ffffffffc02068d0 <nbase>
ffffffffc0203e24:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0203e26:	00c69793          	slli	a5,a3,0xc
ffffffffc0203e2a:	83b1                	srli	a5,a5,0xc
ffffffffc0203e2c:	00012717          	auipc	a4,0x12
ffffffffc0203e30:	81c73703          	ld	a4,-2020(a4) # ffffffffc0215648 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0203e34:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203e36:	16e7fb63          	bgeu	a5,a4,ffffffffc0203fac <do_fork+0x20c>
ffffffffc0203e3a:	00012797          	auipc	a5,0x12
ffffffffc0203e3e:	8267b783          	ld	a5,-2010(a5) # ffffffffc0215660 <va_pa_offset>
ffffffffc0203e42:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0203e44:	e894                	sd	a3,16(s1)
    assert(current->mm == NULL);
ffffffffc0203e46:	000a3783          	ld	a5,0(s4)
ffffffffc0203e4a:	779c                	ld	a5,40(a5)
ffffffffc0203e4c:	14079063          	bnez	a5,ffffffffc0203f8c <do_fork+0x1ec>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0203e50:	6898                	ld	a4,16(s1)
ffffffffc0203e52:	6789                	lui	a5,0x2
ffffffffc0203e54:	ee078793          	addi	a5,a5,-288 # 1ee0 <kern_entry-0xffffffffc01fe120>
ffffffffc0203e58:	973e                	add	a4,a4,a5
    *(proc->tf) = *tf;
ffffffffc0203e5a:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0203e5c:	f0d8                	sd	a4,160(s1)
    *(proc->tf) = *tf;
ffffffffc0203e5e:	87ba                	mv	a5,a4
ffffffffc0203e60:	12040893          	addi	a7,s0,288
ffffffffc0203e64:	00063803          	ld	a6,0(a2)
ffffffffc0203e68:	6608                	ld	a0,8(a2)
ffffffffc0203e6a:	6a0c                	ld	a1,16(a2)
ffffffffc0203e6c:	6e14                	ld	a3,24(a2)
ffffffffc0203e6e:	0107b023          	sd	a6,0(a5)
ffffffffc0203e72:	e788                	sd	a0,8(a5)
ffffffffc0203e74:	eb8c                	sd	a1,16(a5)
ffffffffc0203e76:	ef94                	sd	a3,24(a5)
ffffffffc0203e78:	02060613          	addi	a2,a2,32
ffffffffc0203e7c:	02078793          	addi	a5,a5,32
ffffffffc0203e80:	ff1612e3          	bne	a2,a7,ffffffffc0203e64 <do_fork+0xc4>
    proc->tf->gpr.a0 = 0;
ffffffffc0203e84:	04073823          	sd	zero,80(a4)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0203e88:	0e090163          	beqz	s2,ffffffffc0203f6a <do_fork+0x1ca>
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0203e8c:	40c8                	lw	a0,4(s1)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0203e8e:	00000797          	auipc	a5,0x0
ffffffffc0203e92:	e2478793          	addi	a5,a5,-476 # ffffffffc0203cb2 <forkret>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0203e96:	01273823          	sd	s2,16(a4)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0203e9a:	45a9                	li	a1,10
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0203e9c:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0203e9e:	fc98                	sd	a4,56(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0203ea0:	52a000ef          	jal	ra,ffffffffc02043ca <hash32>
ffffffffc0203ea4:	02051793          	slli	a5,a0,0x20
ffffffffc0203ea8:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0203eac:	0000d797          	auipc	a5,0xd
ffffffffc0203eb0:	74c78793          	addi	a5,a5,1868 # ffffffffc02115f8 <hash_list>
ffffffffc0203eb4:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0203eb6:	6514                	ld	a3,8(a0)
ffffffffc0203eb8:	0d848793          	addi	a5,s1,216
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203ebc:	00011717          	auipc	a4,0x11
ffffffffc0203ec0:	74c70713          	addi	a4,a4,1868 # ffffffffc0215608 <proc_list>
    prev->next = next->prev = elm;
ffffffffc0203ec4:	e29c                	sd	a5,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203ec6:	6310                	ld	a2,0(a4)
    prev->next = next->prev = elm;
ffffffffc0203ec8:	e51c                	sd	a5,8(a0)
     nr_process+=1;
ffffffffc0203eca:	0009a783          	lw	a5,0(s3)
    elm->next = next;
ffffffffc0203ece:	f0f4                	sd	a3,224(s1)
    elm->prev = prev;
ffffffffc0203ed0:	ece8                	sd	a0,216(s1)
     list_add_before(&proc_list,&proc->list_link);
ffffffffc0203ed2:	0c848693          	addi	a3,s1,200
    prev->next = next->prev = elm;
ffffffffc0203ed6:	e614                	sd	a3,8(a2)
     nr_process+=1;
ffffffffc0203ed8:	2785                	addiw	a5,a5,1
     wakeup_proc(proc);//6
ffffffffc0203eda:	8526                	mv	a0,s1
    elm->next = next;
ffffffffc0203edc:	e8f8                	sd	a4,208(s1)
    elm->prev = prev;
ffffffffc0203ede:	e4f0                	sd	a2,200(s1)
    prev->next = next->prev = elm;
ffffffffc0203ee0:	e314                	sd	a3,0(a4)
     nr_process+=1;
ffffffffc0203ee2:	00f9a023          	sw	a5,0(s3)
     wakeup_proc(proc);//6
ffffffffc0203ee6:	41e000ef          	jal	ra,ffffffffc0204304 <wakeup_proc>
     ret=proc->pid;
ffffffffc0203eea:	40c8                	lw	a0,4(s1)
}
ffffffffc0203eec:	70a2                	ld	ra,40(sp)
ffffffffc0203eee:	7402                	ld	s0,32(sp)
ffffffffc0203ef0:	64e2                	ld	s1,24(sp)
ffffffffc0203ef2:	6942                	ld	s2,16(sp)
ffffffffc0203ef4:	69a2                	ld	s3,8(sp)
ffffffffc0203ef6:	6a02                	ld	s4,0(sp)
ffffffffc0203ef8:	6145                	addi	sp,sp,48
ffffffffc0203efa:	8082                	ret
        last_pid = 1;
ffffffffc0203efc:	4785                	li	a5,1
ffffffffc0203efe:	00f8a023          	sw	a5,0(a7)
        goto inside;
ffffffffc0203f02:	4805                	li	a6,1
ffffffffc0203f04:	00006e17          	auipc	t3,0x6
ffffffffc0203f08:	140e0e13          	addi	t3,t3,320 # ffffffffc020a044 <next_safe.0>
    return listelm->next;
ffffffffc0203f0c:	00011617          	auipc	a2,0x11
ffffffffc0203f10:	6fc60613          	addi	a2,a2,1788 # ffffffffc0215608 <proc_list>
ffffffffc0203f14:	00863e83          	ld	t4,8(a2)
        next_safe = MAX_PID;
ffffffffc0203f18:	6789                	lui	a5,0x2
ffffffffc0203f1a:	00fe2023          	sw	a5,0(t3)
ffffffffc0203f1e:	86c2                	mv	a3,a6
ffffffffc0203f20:	4501                	li	a0,0
        while ((le = list_next(le)) != list) {
ffffffffc0203f22:	6f09                	lui	t5,0x2
ffffffffc0203f24:	04ce8a63          	beq	t4,a2,ffffffffc0203f78 <do_fork+0x1d8>
ffffffffc0203f28:	832a                	mv	t1,a0
ffffffffc0203f2a:	87f6                	mv	a5,t4
ffffffffc0203f2c:	6589                	lui	a1,0x2
ffffffffc0203f2e:	a811                	j	ffffffffc0203f42 <do_fork+0x1a2>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0203f30:	00e6d663          	bge	a3,a4,ffffffffc0203f3c <do_fork+0x19c>
ffffffffc0203f34:	00b75463          	bge	a4,a1,ffffffffc0203f3c <do_fork+0x19c>
ffffffffc0203f38:	85ba                	mv	a1,a4
ffffffffc0203f3a:	4305                	li	t1,1
ffffffffc0203f3c:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0203f3e:	00c78d63          	beq	a5,a2,ffffffffc0203f58 <do_fork+0x1b8>
            if (proc->pid == last_pid) {
ffffffffc0203f42:	f3c7a703          	lw	a4,-196(a5) # 1f3c <kern_entry-0xffffffffc01fe0c4>
ffffffffc0203f46:	fee695e3          	bne	a3,a4,ffffffffc0203f30 <do_fork+0x190>
                if (++ last_pid >= next_safe) {
ffffffffc0203f4a:	2685                	addiw	a3,a3,1
ffffffffc0203f4c:	02b6d163          	bge	a3,a1,ffffffffc0203f6e <do_fork+0x1ce>
ffffffffc0203f50:	679c                	ld	a5,8(a5)
ffffffffc0203f52:	4505                	li	a0,1
        while ((le = list_next(le)) != list) {
ffffffffc0203f54:	fec797e3          	bne	a5,a2,ffffffffc0203f42 <do_fork+0x1a2>
ffffffffc0203f58:	c501                	beqz	a0,ffffffffc0203f60 <do_fork+0x1c0>
ffffffffc0203f5a:	00d8a023          	sw	a3,0(a7)
ffffffffc0203f5e:	8836                	mv	a6,a3
ffffffffc0203f60:	ea0301e3          	beqz	t1,ffffffffc0203e02 <do_fork+0x62>
ffffffffc0203f64:	00be2023          	sw	a1,0(t3)
ffffffffc0203f68:	bd69                	j	ffffffffc0203e02 <do_fork+0x62>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0203f6a:	893a                	mv	s2,a4
ffffffffc0203f6c:	b705                	j	ffffffffc0203e8c <do_fork+0xec>
                    if (last_pid >= MAX_PID) {
ffffffffc0203f6e:	01e6c363          	blt	a3,t5,ffffffffc0203f74 <do_fork+0x1d4>
                        last_pid = 1;
ffffffffc0203f72:	4685                	li	a3,1
                    goto repeat;
ffffffffc0203f74:	4505                	li	a0,1
ffffffffc0203f76:	b77d                	j	ffffffffc0203f24 <do_fork+0x184>
ffffffffc0203f78:	c519                	beqz	a0,ffffffffc0203f86 <do_fork+0x1e6>
ffffffffc0203f7a:	00d8a023          	sw	a3,0(a7)
    return last_pid;
ffffffffc0203f7e:	8836                	mv	a6,a3
ffffffffc0203f80:	b549                	j	ffffffffc0203e02 <do_fork+0x62>
    int ret = -E_NO_FREE_PROC;
ffffffffc0203f82:	556d                	li	a0,-5
    return ret;
ffffffffc0203f84:	b7a5                	j	ffffffffc0203eec <do_fork+0x14c>
    return last_pid;
ffffffffc0203f86:	0008a803          	lw	a6,0(a7)
ffffffffc0203f8a:	bda5                	j	ffffffffc0203e02 <do_fork+0x62>
    assert(current->mm == NULL);
ffffffffc0203f8c:	00002697          	auipc	a3,0x2
ffffffffc0203f90:	5a468693          	addi	a3,a3,1444 # ffffffffc0206530 <buddy_system_pmm_manager+0xfb8>
ffffffffc0203f94:	00001617          	auipc	a2,0x1
ffffffffc0203f98:	35c60613          	addi	a2,a2,860 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0203f9c:	12700593          	li	a1,295
ffffffffc0203fa0:	00002517          	auipc	a0,0x2
ffffffffc0203fa4:	5a850513          	addi	a0,a0,1448 # ffffffffc0206548 <buddy_system_pmm_manager+0xfd0>
ffffffffc0203fa8:	c9efc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203fac:	00001617          	auipc	a2,0x1
ffffffffc0203fb0:	61c60613          	addi	a2,a2,1564 # ffffffffc02055c8 <buddy_system_pmm_manager+0x50>
ffffffffc0203fb4:	06900593          	li	a1,105
ffffffffc0203fb8:	00001517          	auipc	a0,0x1
ffffffffc0203fbc:	63850513          	addi	a0,a0,1592 # ffffffffc02055f0 <buddy_system_pmm_manager+0x78>
ffffffffc0203fc0:	c86fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203fc4 <kernel_thread>:
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0203fc4:	7129                	addi	sp,sp,-320
ffffffffc0203fc6:	fa22                	sd	s0,304(sp)
ffffffffc0203fc8:	f626                	sd	s1,296(sp)
ffffffffc0203fca:	f24a                	sd	s2,288(sp)
ffffffffc0203fcc:	84ae                	mv	s1,a1
ffffffffc0203fce:	892a                	mv	s2,a0
ffffffffc0203fd0:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0203fd2:	4581                	li	a1,0
ffffffffc0203fd4:	12000613          	li	a2,288
ffffffffc0203fd8:	850a                	mv	a0,sp
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0203fda:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0203fdc:	06f000ef          	jal	ra,ffffffffc020484a <memset>
    tf.gpr.s0 = (uintptr_t)fn; // s0 寄存器保存函数指针
ffffffffc0203fe0:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg; // s1 寄存器保存函数参数
ffffffffc0203fe2:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0203fe4:	100027f3          	csrr	a5,sstatus
ffffffffc0203fe8:	edd7f793          	andi	a5,a5,-291
ffffffffc0203fec:	1207e793          	ori	a5,a5,288
ffffffffc0203ff0:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0203ff2:	860a                	mv	a2,sp
ffffffffc0203ff4:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0203ff8:	00000797          	auipc	a5,0x0
ffffffffc0203ffc:	c5078793          	addi	a5,a5,-944 # ffffffffc0203c48 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204000:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204002:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204004:	d9dff0ef          	jal	ra,ffffffffc0203da0 <do_fork>
}
ffffffffc0204008:	70f2                	ld	ra,312(sp)
ffffffffc020400a:	7452                	ld	s0,304(sp)
ffffffffc020400c:	74b2                	ld	s1,296(sp)
ffffffffc020400e:	7912                	ld	s2,288(sp)
ffffffffc0204010:	6131                	addi	sp,sp,320
ffffffffc0204012:	8082                	ret

ffffffffc0204014 <do_exit>:
do_exit(int error_code) {
ffffffffc0204014:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc0204016:	00002617          	auipc	a2,0x2
ffffffffc020401a:	54a60613          	addi	a2,a2,1354 # ffffffffc0206560 <buddy_system_pmm_manager+0xfe8>
ffffffffc020401e:	18600593          	li	a1,390
ffffffffc0204022:	00002517          	auipc	a0,0x2
ffffffffc0204026:	52650513          	addi	a0,a0,1318 # ffffffffc0206548 <buddy_system_pmm_manager+0xfd0>
do_exit(int error_code) {
ffffffffc020402a:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc020402c:	c1afc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0204030 <proc_init>:
/* proc_init - set up the first kernel thread idleproc "idle" by itself and 
 *           - create the second kernel thread init_main
 * 功能:第一个内核线程<空闲线程(idleproc)>将自己的状态设为空闲，并创建第二个内核线程init_main
 */
void
proc_init(void) {
ffffffffc0204030:	7179                	addi	sp,sp,-48
ffffffffc0204032:	ec26                	sd	s1,24(sp)
    elm->prev = elm->next = elm;
ffffffffc0204034:	00011797          	auipc	a5,0x11
ffffffffc0204038:	5d478793          	addi	a5,a5,1492 # ffffffffc0215608 <proc_list>
ffffffffc020403c:	f406                	sd	ra,40(sp)
ffffffffc020403e:	f022                	sd	s0,32(sp)
ffffffffc0204040:	e84a                	sd	s2,16(sp)
ffffffffc0204042:	e44e                	sd	s3,8(sp)
ffffffffc0204044:	0000d497          	auipc	s1,0xd
ffffffffc0204048:	5b448493          	addi	s1,s1,1460 # ffffffffc02115f8 <hash_list>
ffffffffc020404c:	e79c                	sd	a5,8(a5)
ffffffffc020404e:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0204050:	00011717          	auipc	a4,0x11
ffffffffc0204054:	5a870713          	addi	a4,a4,1448 # ffffffffc02155f8 <name.2>
ffffffffc0204058:	87a6                	mv	a5,s1
ffffffffc020405a:	e79c                	sd	a5,8(a5)
ffffffffc020405c:	e39c                	sd	a5,0(a5)
ffffffffc020405e:	07c1                	addi	a5,a5,16
ffffffffc0204060:	fef71de3          	bne	a4,a5,ffffffffc020405a <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0204064:	bedff0ef          	jal	ra,ffffffffc0203c50 <alloc_proc>
ffffffffc0204068:	00011917          	auipc	s2,0x11
ffffffffc020406c:	63090913          	addi	s2,s2,1584 # ffffffffc0215698 <idleproc>
ffffffffc0204070:	00a93023          	sd	a0,0(s2)
ffffffffc0204074:	18050d63          	beqz	a0,ffffffffc020420e <proc_init+0x1de>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204078:	07000513          	li	a0,112
ffffffffc020407c:	f6efd0ef          	jal	ra,ffffffffc02017ea <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204080:	07000613          	li	a2,112
ffffffffc0204084:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204086:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204088:	7c2000ef          	jal	ra,ffffffffc020484a <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc020408c:	00093503          	ld	a0,0(s2)
ffffffffc0204090:	85a2                	mv	a1,s0
ffffffffc0204092:	07000613          	li	a2,112
ffffffffc0204096:	03050513          	addi	a0,a0,48
ffffffffc020409a:	7da000ef          	jal	ra,ffffffffc0204874 <memcmp>
ffffffffc020409e:	89aa                	mv	s3,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02040a0:	453d                	li	a0,15
ffffffffc02040a2:	f48fd0ef          	jal	ra,ffffffffc02017ea <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02040a6:	463d                	li	a2,15
ffffffffc02040a8:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02040aa:	842a                	mv	s0,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02040ac:	79e000ef          	jal	ra,ffffffffc020484a <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc02040b0:	00093503          	ld	a0,0(s2)
ffffffffc02040b4:	463d                	li	a2,15
ffffffffc02040b6:	85a2                	mv	a1,s0
ffffffffc02040b8:	0b450513          	addi	a0,a0,180
ffffffffc02040bc:	7b8000ef          	jal	ra,ffffffffc0204874 <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02040c0:	00093783          	ld	a5,0(s2)
ffffffffc02040c4:	00011717          	auipc	a4,0x11
ffffffffc02040c8:	57473703          	ld	a4,1396(a4) # ffffffffc0215638 <boot_cr3>
ffffffffc02040cc:	77d4                	ld	a3,168(a5)
ffffffffc02040ce:	0ee68463          	beq	a3,a4,ffffffffc02041b6 <proc_init+0x186>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02040d2:	4709                	li	a4,2
ffffffffc02040d4:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02040d6:	00003717          	auipc	a4,0x3
ffffffffc02040da:	f2a70713          	addi	a4,a4,-214 # ffffffffc0207000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02040de:	0b478413          	addi	s0,a5,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02040e2:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc02040e4:	4705                	li	a4,1
ffffffffc02040e6:	cf98                	sw	a4,24(a5)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02040e8:	4641                	li	a2,16
ffffffffc02040ea:	4581                	li	a1,0
ffffffffc02040ec:	8522                	mv	a0,s0
ffffffffc02040ee:	75c000ef          	jal	ra,ffffffffc020484a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02040f2:	463d                	li	a2,15
ffffffffc02040f4:	00002597          	auipc	a1,0x2
ffffffffc02040f8:	4b458593          	addi	a1,a1,1204 # ffffffffc02065a8 <buddy_system_pmm_manager+0x1030>
ffffffffc02040fc:	8522                	mv	a0,s0
ffffffffc02040fe:	75e000ef          	jal	ra,ffffffffc020485c <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0204102:	00011717          	auipc	a4,0x11
ffffffffc0204106:	5a670713          	addi	a4,a4,1446 # ffffffffc02156a8 <nr_process>
ffffffffc020410a:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc020410c:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204110:	4601                	li	a2,0
    nr_process ++;
ffffffffc0204112:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204114:	00002597          	auipc	a1,0x2
ffffffffc0204118:	49c58593          	addi	a1,a1,1180 # ffffffffc02065b0 <buddy_system_pmm_manager+0x1038>
ffffffffc020411c:	00000517          	auipc	a0,0x0
ffffffffc0204120:	ba450513          	addi	a0,a0,-1116 # ffffffffc0203cc0 <init_main>
    nr_process ++;
ffffffffc0204124:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0204126:	00011797          	auipc	a5,0x11
ffffffffc020412a:	56d7b523          	sd	a3,1386(a5) # ffffffffc0215690 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020412e:	e97ff0ef          	jal	ra,ffffffffc0203fc4 <kernel_thread>
ffffffffc0204132:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0204134:	0ea05963          	blez	a0,ffffffffc0204226 <proc_init+0x1f6>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204138:	6789                	lui	a5,0x2
ffffffffc020413a:	fff5071b          	addiw	a4,a0,-1
ffffffffc020413e:	17f9                	addi	a5,a5,-2
ffffffffc0204140:	2501                	sext.w	a0,a0
ffffffffc0204142:	02e7e363          	bltu	a5,a4,ffffffffc0204168 <proc_init+0x138>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204146:	45a9                	li	a1,10
ffffffffc0204148:	282000ef          	jal	ra,ffffffffc02043ca <hash32>
ffffffffc020414c:	02051793          	slli	a5,a0,0x20
ffffffffc0204150:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204154:	96a6                	add	a3,a3,s1
ffffffffc0204156:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204158:	a029                	j	ffffffffc0204162 <proc_init+0x132>
            if (proc->pid == pid) {
ffffffffc020415a:	f2c7a703          	lw	a4,-212(a5) # 1f2c <kern_entry-0xffffffffc01fe0d4>
ffffffffc020415e:	0a870563          	beq	a4,s0,ffffffffc0204208 <proc_init+0x1d8>
    return listelm->next;
ffffffffc0204162:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204164:	fef69be3          	bne	a3,a5,ffffffffc020415a <proc_init+0x12a>
    return NULL;
ffffffffc0204168:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020416a:	0b478493          	addi	s1,a5,180
ffffffffc020416e:	4641                	li	a2,16
ffffffffc0204170:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204172:	00011417          	auipc	s0,0x11
ffffffffc0204176:	52e40413          	addi	s0,s0,1326 # ffffffffc02156a0 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020417a:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc020417c:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020417e:	6cc000ef          	jal	ra,ffffffffc020484a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204182:	463d                	li	a2,15
ffffffffc0204184:	00002597          	auipc	a1,0x2
ffffffffc0204188:	45c58593          	addi	a1,a1,1116 # ffffffffc02065e0 <buddy_system_pmm_manager+0x1068>
ffffffffc020418c:	8526                	mv	a0,s1
ffffffffc020418e:	6ce000ef          	jal	ra,ffffffffc020485c <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204192:	00093783          	ld	a5,0(s2)
ffffffffc0204196:	c7e1                	beqz	a5,ffffffffc020425e <proc_init+0x22e>
ffffffffc0204198:	43dc                	lw	a5,4(a5)
ffffffffc020419a:	e3f1                	bnez	a5,ffffffffc020425e <proc_init+0x22e>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020419c:	601c                	ld	a5,0(s0)
ffffffffc020419e:	c3c5                	beqz	a5,ffffffffc020423e <proc_init+0x20e>
ffffffffc02041a0:	43d8                	lw	a4,4(a5)
ffffffffc02041a2:	4785                	li	a5,1
ffffffffc02041a4:	08f71d63          	bne	a4,a5,ffffffffc020423e <proc_init+0x20e>
}
ffffffffc02041a8:	70a2                	ld	ra,40(sp)
ffffffffc02041aa:	7402                	ld	s0,32(sp)
ffffffffc02041ac:	64e2                	ld	s1,24(sp)
ffffffffc02041ae:	6942                	ld	s2,16(sp)
ffffffffc02041b0:	69a2                	ld	s3,8(sp)
ffffffffc02041b2:	6145                	addi	sp,sp,48
ffffffffc02041b4:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02041b6:	73d8                	ld	a4,160(a5)
ffffffffc02041b8:	ff09                	bnez	a4,ffffffffc02040d2 <proc_init+0xa2>
ffffffffc02041ba:	f0099ce3          	bnez	s3,ffffffffc02040d2 <proc_init+0xa2>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc02041be:	6394                	ld	a3,0(a5)
ffffffffc02041c0:	577d                	li	a4,-1
ffffffffc02041c2:	1702                	slli	a4,a4,0x20
ffffffffc02041c4:	f0e697e3          	bne	a3,a4,ffffffffc02040d2 <proc_init+0xa2>
ffffffffc02041c8:	4798                	lw	a4,8(a5)
ffffffffc02041ca:	f00714e3          	bnez	a4,ffffffffc02040d2 <proc_init+0xa2>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc02041ce:	6b98                	ld	a4,16(a5)
ffffffffc02041d0:	f00711e3          	bnez	a4,ffffffffc02040d2 <proc_init+0xa2>
ffffffffc02041d4:	4f98                	lw	a4,24(a5)
ffffffffc02041d6:	2701                	sext.w	a4,a4
ffffffffc02041d8:	ee071de3          	bnez	a4,ffffffffc02040d2 <proc_init+0xa2>
ffffffffc02041dc:	7398                	ld	a4,32(a5)
ffffffffc02041de:	ee071ae3          	bnez	a4,ffffffffc02040d2 <proc_init+0xa2>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc02041e2:	7798                	ld	a4,40(a5)
ffffffffc02041e4:	ee0717e3          	bnez	a4,ffffffffc02040d2 <proc_init+0xa2>
ffffffffc02041e8:	0b07a703          	lw	a4,176(a5)
ffffffffc02041ec:	8d59                	or	a0,a0,a4
ffffffffc02041ee:	0005071b          	sext.w	a4,a0
ffffffffc02041f2:	ee0710e3          	bnez	a4,ffffffffc02040d2 <proc_init+0xa2>
        cprintf("alloc_proc() correct!\n");
ffffffffc02041f6:	00002517          	auipc	a0,0x2
ffffffffc02041fa:	39a50513          	addi	a0,a0,922 # ffffffffc0206590 <buddy_system_pmm_manager+0x1018>
ffffffffc02041fe:	f83fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    idleproc->pid = 0;
ffffffffc0204202:	00093783          	ld	a5,0(s2)
ffffffffc0204206:	b5f1                	j	ffffffffc02040d2 <proc_init+0xa2>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204208:	f2878793          	addi	a5,a5,-216
ffffffffc020420c:	bfb9                	j	ffffffffc020416a <proc_init+0x13a>
        panic("cannot alloc idleproc.\n");
ffffffffc020420e:	00002617          	auipc	a2,0x2
ffffffffc0204212:	36a60613          	addi	a2,a2,874 # ffffffffc0206578 <buddy_system_pmm_manager+0x1000>
ffffffffc0204216:	1a200593          	li	a1,418
ffffffffc020421a:	00002517          	auipc	a0,0x2
ffffffffc020421e:	32e50513          	addi	a0,a0,814 # ffffffffc0206548 <buddy_system_pmm_manager+0xfd0>
ffffffffc0204222:	a24fc0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("create init_main failed.\n");
ffffffffc0204226:	00002617          	auipc	a2,0x2
ffffffffc020422a:	39a60613          	addi	a2,a2,922 # ffffffffc02065c0 <buddy_system_pmm_manager+0x1048>
ffffffffc020422e:	1c200593          	li	a1,450
ffffffffc0204232:	00002517          	auipc	a0,0x2
ffffffffc0204236:	31650513          	addi	a0,a0,790 # ffffffffc0206548 <buddy_system_pmm_manager+0xfd0>
ffffffffc020423a:	a0cfc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020423e:	00002697          	auipc	a3,0x2
ffffffffc0204242:	3d268693          	addi	a3,a3,978 # ffffffffc0206610 <buddy_system_pmm_manager+0x1098>
ffffffffc0204246:	00001617          	auipc	a2,0x1
ffffffffc020424a:	0aa60613          	addi	a2,a2,170 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc020424e:	1c900593          	li	a1,457
ffffffffc0204252:	00002517          	auipc	a0,0x2
ffffffffc0204256:	2f650513          	addi	a0,a0,758 # ffffffffc0206548 <buddy_system_pmm_manager+0xfd0>
ffffffffc020425a:	9ecfc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020425e:	00002697          	auipc	a3,0x2
ffffffffc0204262:	38a68693          	addi	a3,a3,906 # ffffffffc02065e8 <buddy_system_pmm_manager+0x1070>
ffffffffc0204266:	00001617          	auipc	a2,0x1
ffffffffc020426a:	08a60613          	addi	a2,a2,138 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc020426e:	1c800593          	li	a1,456
ffffffffc0204272:	00002517          	auipc	a0,0x2
ffffffffc0204276:	2d650513          	addi	a0,a0,726 # ffffffffc0206548 <buddy_system_pmm_manager+0xfd0>
ffffffffc020427a:	9ccfc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020427e <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc020427e:	1141                	addi	sp,sp,-16
ffffffffc0204280:	e022                	sd	s0,0(sp)
ffffffffc0204282:	e406                	sd	ra,8(sp)
ffffffffc0204284:	00011417          	auipc	s0,0x11
ffffffffc0204288:	40c40413          	addi	s0,s0,1036 # ffffffffc0215690 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc020428c:	6018                	ld	a4,0(s0)
ffffffffc020428e:	4f1c                	lw	a5,24(a4)
ffffffffc0204290:	2781                	sext.w	a5,a5
ffffffffc0204292:	dff5                	beqz	a5,ffffffffc020428e <cpu_idle+0x10>
            schedule();
ffffffffc0204294:	0a2000ef          	jal	ra,ffffffffc0204336 <schedule>
ffffffffc0204298:	bfd5                	j	ffffffffc020428c <cpu_idle+0xe>

ffffffffc020429a <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc020429a:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc020429e:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc02042a2:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc02042a4:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc02042a6:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc02042aa:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc02042ae:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc02042b2:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc02042b6:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc02042ba:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc02042be:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc02042c2:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc02042c6:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc02042ca:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc02042ce:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc02042d2:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02042d6:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02042d8:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02042da:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc02042de:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02042e2:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02042e6:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc02042ea:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc02042ee:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc02042f2:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc02042f6:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc02042fa:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc02042fe:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204302:	8082                	ret

ffffffffc0204304 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204304:	411c                	lw	a5,0(a0)
ffffffffc0204306:	4705                	li	a4,1
ffffffffc0204308:	37f9                	addiw	a5,a5,-2
ffffffffc020430a:	00f77563          	bgeu	a4,a5,ffffffffc0204314 <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc020430e:	4789                	li	a5,2
ffffffffc0204310:	c11c                	sw	a5,0(a0)
ffffffffc0204312:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204314:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204316:	00002697          	auipc	a3,0x2
ffffffffc020431a:	32268693          	addi	a3,a3,802 # ffffffffc0206638 <buddy_system_pmm_manager+0x10c0>
ffffffffc020431e:	00001617          	auipc	a2,0x1
ffffffffc0204322:	fd260613          	addi	a2,a2,-46 # ffffffffc02052f0 <commands+0x7f0>
ffffffffc0204326:	45a5                	li	a1,9
ffffffffc0204328:	00002517          	auipc	a0,0x2
ffffffffc020432c:	35050513          	addi	a0,a0,848 # ffffffffc0206678 <buddy_system_pmm_manager+0x1100>
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204330:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204332:	914fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0204336 <schedule>:
}

void
schedule(void) {
ffffffffc0204336:	1141                	addi	sp,sp,-16
ffffffffc0204338:	e406                	sd	ra,8(sp)
ffffffffc020433a:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020433c:	100027f3          	csrr	a5,sstatus
ffffffffc0204340:	8b89                	andi	a5,a5,2
ffffffffc0204342:	4401                	li	s0,0
ffffffffc0204344:	efbd                	bnez	a5,ffffffffc02043c2 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0204346:	00011897          	auipc	a7,0x11
ffffffffc020434a:	34a8b883          	ld	a7,842(a7) # ffffffffc0215690 <current>
ffffffffc020434e:	0008ac23          	sw	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204352:	00011517          	auipc	a0,0x11
ffffffffc0204356:	34653503          	ld	a0,838(a0) # ffffffffc0215698 <idleproc>
ffffffffc020435a:	04a88e63          	beq	a7,a0,ffffffffc02043b6 <schedule+0x80>
ffffffffc020435e:	0c888693          	addi	a3,a7,200
ffffffffc0204362:	00011617          	auipc	a2,0x11
ffffffffc0204366:	2a660613          	addi	a2,a2,678 # ffffffffc0215608 <proc_list>
        le = last;
ffffffffc020436a:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc020436c:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc020436e:	4809                	li	a6,2
ffffffffc0204370:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0204372:	00c78863          	beq	a5,a2,ffffffffc0204382 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204376:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc020437a:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc020437e:	03070163          	beq	a4,a6,ffffffffc02043a0 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0204382:	fef697e3          	bne	a3,a5,ffffffffc0204370 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204386:	ed89                	bnez	a1,ffffffffc02043a0 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0204388:	451c                	lw	a5,8(a0)
ffffffffc020438a:	2785                	addiw	a5,a5,1
ffffffffc020438c:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc020438e:	00a88463          	beq	a7,a0,ffffffffc0204396 <schedule+0x60>
            proc_run(next);
ffffffffc0204392:	9a1ff0ef          	jal	ra,ffffffffc0203d32 <proc_run>
    if (flag) {
ffffffffc0204396:	e819                	bnez	s0,ffffffffc02043ac <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0204398:	60a2                	ld	ra,8(sp)
ffffffffc020439a:	6402                	ld	s0,0(sp)
ffffffffc020439c:	0141                	addi	sp,sp,16
ffffffffc020439e:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02043a0:	4198                	lw	a4,0(a1)
ffffffffc02043a2:	4789                	li	a5,2
ffffffffc02043a4:	fef712e3          	bne	a4,a5,ffffffffc0204388 <schedule+0x52>
ffffffffc02043a8:	852e                	mv	a0,a1
ffffffffc02043aa:	bff9                	j	ffffffffc0204388 <schedule+0x52>
}
ffffffffc02043ac:	6402                	ld	s0,0(sp)
ffffffffc02043ae:	60a2                	ld	ra,8(sp)
ffffffffc02043b0:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02043b2:	a0afc06f          	j	ffffffffc02005bc <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02043b6:	00011617          	auipc	a2,0x11
ffffffffc02043ba:	25260613          	addi	a2,a2,594 # ffffffffc0215608 <proc_list>
ffffffffc02043be:	86b2                	mv	a3,a2
ffffffffc02043c0:	b76d                	j	ffffffffc020436a <schedule+0x34>
        intr_disable();
ffffffffc02043c2:	a00fc0ef          	jal	ra,ffffffffc02005c2 <intr_disable>
        return 1;
ffffffffc02043c6:	4405                	li	s0,1
ffffffffc02043c8:	bfbd                	j	ffffffffc0204346 <schedule+0x10>

ffffffffc02043ca <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02043ca:	9e3707b7          	lui	a5,0x9e370
ffffffffc02043ce:	2785                	addiw	a5,a5,1
ffffffffc02043d0:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc02043d4:	02000793          	li	a5,32
ffffffffc02043d8:	9f8d                	subw	a5,a5,a1
}
ffffffffc02043da:	00f5553b          	srlw	a0,a0,a5
ffffffffc02043de:	8082                	ret

ffffffffc02043e0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02043e0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02043e4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02043e6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02043ea:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02043ec:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02043f0:	f022                	sd	s0,32(sp)
ffffffffc02043f2:	ec26                	sd	s1,24(sp)
ffffffffc02043f4:	e84a                	sd	s2,16(sp)
ffffffffc02043f6:	f406                	sd	ra,40(sp)
ffffffffc02043f8:	e44e                	sd	s3,8(sp)
ffffffffc02043fa:	84aa                	mv	s1,a0
ffffffffc02043fc:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02043fe:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204402:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0204404:	03067e63          	bgeu	a2,a6,ffffffffc0204440 <printnum+0x60>
ffffffffc0204408:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020440a:	00805763          	blez	s0,ffffffffc0204418 <printnum+0x38>
ffffffffc020440e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204410:	85ca                	mv	a1,s2
ffffffffc0204412:	854e                	mv	a0,s3
ffffffffc0204414:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204416:	fc65                	bnez	s0,ffffffffc020440e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204418:	1a02                	slli	s4,s4,0x20
ffffffffc020441a:	00002797          	auipc	a5,0x2
ffffffffc020441e:	27678793          	addi	a5,a5,630 # ffffffffc0206690 <buddy_system_pmm_manager+0x1118>
ffffffffc0204422:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204426:	9a3e                	add	s4,s4,a5
}
ffffffffc0204428:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020442a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020442e:	70a2                	ld	ra,40(sp)
ffffffffc0204430:	69a2                	ld	s3,8(sp)
ffffffffc0204432:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204434:	85ca                	mv	a1,s2
ffffffffc0204436:	87a6                	mv	a5,s1
}
ffffffffc0204438:	6942                	ld	s2,16(sp)
ffffffffc020443a:	64e2                	ld	s1,24(sp)
ffffffffc020443c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020443e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204440:	03065633          	divu	a2,a2,a6
ffffffffc0204444:	8722                	mv	a4,s0
ffffffffc0204446:	f9bff0ef          	jal	ra,ffffffffc02043e0 <printnum>
ffffffffc020444a:	b7f9                	j	ffffffffc0204418 <printnum+0x38>

ffffffffc020444c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020444c:	7119                	addi	sp,sp,-128
ffffffffc020444e:	f4a6                	sd	s1,104(sp)
ffffffffc0204450:	f0ca                	sd	s2,96(sp)
ffffffffc0204452:	ecce                	sd	s3,88(sp)
ffffffffc0204454:	e8d2                	sd	s4,80(sp)
ffffffffc0204456:	e4d6                	sd	s5,72(sp)
ffffffffc0204458:	e0da                	sd	s6,64(sp)
ffffffffc020445a:	fc5e                	sd	s7,56(sp)
ffffffffc020445c:	f06a                	sd	s10,32(sp)
ffffffffc020445e:	fc86                	sd	ra,120(sp)
ffffffffc0204460:	f8a2                	sd	s0,112(sp)
ffffffffc0204462:	f862                	sd	s8,48(sp)
ffffffffc0204464:	f466                	sd	s9,40(sp)
ffffffffc0204466:	ec6e                	sd	s11,24(sp)
ffffffffc0204468:	892a                	mv	s2,a0
ffffffffc020446a:	84ae                	mv	s1,a1
ffffffffc020446c:	8d32                	mv	s10,a2
ffffffffc020446e:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204470:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204474:	5b7d                	li	s6,-1
ffffffffc0204476:	00002a97          	auipc	s5,0x2
ffffffffc020447a:	246a8a93          	addi	s5,s5,582 # ffffffffc02066bc <buddy_system_pmm_manager+0x1144>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020447e:	00002b97          	auipc	s7,0x2
ffffffffc0204482:	41ab8b93          	addi	s7,s7,1050 # ffffffffc0206898 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204486:	000d4503          	lbu	a0,0(s10)
ffffffffc020448a:	001d0413          	addi	s0,s10,1
ffffffffc020448e:	01350a63          	beq	a0,s3,ffffffffc02044a2 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204492:	c121                	beqz	a0,ffffffffc02044d2 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204494:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204496:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204498:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020449a:	fff44503          	lbu	a0,-1(s0)
ffffffffc020449e:	ff351ae3          	bne	a0,s3,ffffffffc0204492 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02044a2:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02044a6:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02044aa:	4c81                	li	s9,0
ffffffffc02044ac:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02044ae:	5c7d                	li	s8,-1
ffffffffc02044b0:	5dfd                	li	s11,-1
ffffffffc02044b2:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02044b6:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02044b8:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02044bc:	0ff5f593          	zext.b	a1,a1
ffffffffc02044c0:	00140d13          	addi	s10,s0,1
ffffffffc02044c4:	04b56263          	bltu	a0,a1,ffffffffc0204508 <vprintfmt+0xbc>
ffffffffc02044c8:	058a                	slli	a1,a1,0x2
ffffffffc02044ca:	95d6                	add	a1,a1,s5
ffffffffc02044cc:	4194                	lw	a3,0(a1)
ffffffffc02044ce:	96d6                	add	a3,a3,s5
ffffffffc02044d0:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02044d2:	70e6                	ld	ra,120(sp)
ffffffffc02044d4:	7446                	ld	s0,112(sp)
ffffffffc02044d6:	74a6                	ld	s1,104(sp)
ffffffffc02044d8:	7906                	ld	s2,96(sp)
ffffffffc02044da:	69e6                	ld	s3,88(sp)
ffffffffc02044dc:	6a46                	ld	s4,80(sp)
ffffffffc02044de:	6aa6                	ld	s5,72(sp)
ffffffffc02044e0:	6b06                	ld	s6,64(sp)
ffffffffc02044e2:	7be2                	ld	s7,56(sp)
ffffffffc02044e4:	7c42                	ld	s8,48(sp)
ffffffffc02044e6:	7ca2                	ld	s9,40(sp)
ffffffffc02044e8:	7d02                	ld	s10,32(sp)
ffffffffc02044ea:	6de2                	ld	s11,24(sp)
ffffffffc02044ec:	6109                	addi	sp,sp,128
ffffffffc02044ee:	8082                	ret
            padc = '0';
ffffffffc02044f0:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02044f2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02044f6:	846a                	mv	s0,s10
ffffffffc02044f8:	00140d13          	addi	s10,s0,1
ffffffffc02044fc:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204500:	0ff5f593          	zext.b	a1,a1
ffffffffc0204504:	fcb572e3          	bgeu	a0,a1,ffffffffc02044c8 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0204508:	85a6                	mv	a1,s1
ffffffffc020450a:	02500513          	li	a0,37
ffffffffc020450e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204510:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204514:	8d22                	mv	s10,s0
ffffffffc0204516:	f73788e3          	beq	a5,s3,ffffffffc0204486 <vprintfmt+0x3a>
ffffffffc020451a:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020451e:	1d7d                	addi	s10,s10,-1
ffffffffc0204520:	ff379de3          	bne	a5,s3,ffffffffc020451a <vprintfmt+0xce>
ffffffffc0204524:	b78d                	j	ffffffffc0204486 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204526:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020452a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020452e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204530:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204534:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204538:	02d86463          	bltu	a6,a3,ffffffffc0204560 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020453c:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204540:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204544:	0186873b          	addw	a4,a3,s8
ffffffffc0204548:	0017171b          	slliw	a4,a4,0x1
ffffffffc020454c:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020454e:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204552:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204554:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204558:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020455c:	fed870e3          	bgeu	a6,a3,ffffffffc020453c <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204560:	f40ddce3          	bgez	s11,ffffffffc02044b8 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204564:	8de2                	mv	s11,s8
ffffffffc0204566:	5c7d                	li	s8,-1
ffffffffc0204568:	bf81                	j	ffffffffc02044b8 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020456a:	fffdc693          	not	a3,s11
ffffffffc020456e:	96fd                	srai	a3,a3,0x3f
ffffffffc0204570:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204574:	00144603          	lbu	a2,1(s0)
ffffffffc0204578:	2d81                	sext.w	s11,s11
ffffffffc020457a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020457c:	bf35                	j	ffffffffc02044b8 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020457e:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204582:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204586:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204588:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020458a:	bfd9                	j	ffffffffc0204560 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020458c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020458e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204592:	01174463          	blt	a4,a7,ffffffffc020459a <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204596:	1a088e63          	beqz	a7,ffffffffc0204752 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020459a:	000a3603          	ld	a2,0(s4)
ffffffffc020459e:	46c1                	li	a3,16
ffffffffc02045a0:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02045a2:	2781                	sext.w	a5,a5
ffffffffc02045a4:	876e                	mv	a4,s11
ffffffffc02045a6:	85a6                	mv	a1,s1
ffffffffc02045a8:	854a                	mv	a0,s2
ffffffffc02045aa:	e37ff0ef          	jal	ra,ffffffffc02043e0 <printnum>
            break;
ffffffffc02045ae:	bde1                	j	ffffffffc0204486 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02045b0:	000a2503          	lw	a0,0(s4)
ffffffffc02045b4:	85a6                	mv	a1,s1
ffffffffc02045b6:	0a21                	addi	s4,s4,8
ffffffffc02045b8:	9902                	jalr	s2
            break;
ffffffffc02045ba:	b5f1                	j	ffffffffc0204486 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02045bc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02045be:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02045c2:	01174463          	blt	a4,a7,ffffffffc02045ca <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02045c6:	18088163          	beqz	a7,ffffffffc0204748 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02045ca:	000a3603          	ld	a2,0(s4)
ffffffffc02045ce:	46a9                	li	a3,10
ffffffffc02045d0:	8a2e                	mv	s4,a1
ffffffffc02045d2:	bfc1                	j	ffffffffc02045a2 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02045d4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02045d8:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02045da:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02045dc:	bdf1                	j	ffffffffc02044b8 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02045de:	85a6                	mv	a1,s1
ffffffffc02045e0:	02500513          	li	a0,37
ffffffffc02045e4:	9902                	jalr	s2
            break;
ffffffffc02045e6:	b545                	j	ffffffffc0204486 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02045e8:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02045ec:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02045ee:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02045f0:	b5e1                	j	ffffffffc02044b8 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02045f2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02045f4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02045f8:	01174463          	blt	a4,a7,ffffffffc0204600 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02045fc:	14088163          	beqz	a7,ffffffffc020473e <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0204600:	000a3603          	ld	a2,0(s4)
ffffffffc0204604:	46a1                	li	a3,8
ffffffffc0204606:	8a2e                	mv	s4,a1
ffffffffc0204608:	bf69                	j	ffffffffc02045a2 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020460a:	03000513          	li	a0,48
ffffffffc020460e:	85a6                	mv	a1,s1
ffffffffc0204610:	e03e                	sd	a5,0(sp)
ffffffffc0204612:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204614:	85a6                	mv	a1,s1
ffffffffc0204616:	07800513          	li	a0,120
ffffffffc020461a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020461c:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020461e:	6782                	ld	a5,0(sp)
ffffffffc0204620:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204622:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204626:	bfb5                	j	ffffffffc02045a2 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204628:	000a3403          	ld	s0,0(s4)
ffffffffc020462c:	008a0713          	addi	a4,s4,8
ffffffffc0204630:	e03a                	sd	a4,0(sp)
ffffffffc0204632:	14040263          	beqz	s0,ffffffffc0204776 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204636:	0fb05763          	blez	s11,ffffffffc0204724 <vprintfmt+0x2d8>
ffffffffc020463a:	02d00693          	li	a3,45
ffffffffc020463e:	0cd79163          	bne	a5,a3,ffffffffc0204700 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204642:	00044783          	lbu	a5,0(s0)
ffffffffc0204646:	0007851b          	sext.w	a0,a5
ffffffffc020464a:	cf85                	beqz	a5,ffffffffc0204682 <vprintfmt+0x236>
ffffffffc020464c:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204650:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204654:	000c4563          	bltz	s8,ffffffffc020465e <vprintfmt+0x212>
ffffffffc0204658:	3c7d                	addiw	s8,s8,-1
ffffffffc020465a:	036c0263          	beq	s8,s6,ffffffffc020467e <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020465e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204660:	0e0c8e63          	beqz	s9,ffffffffc020475c <vprintfmt+0x310>
ffffffffc0204664:	3781                	addiw	a5,a5,-32
ffffffffc0204666:	0ef47b63          	bgeu	s0,a5,ffffffffc020475c <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020466a:	03f00513          	li	a0,63
ffffffffc020466e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204670:	000a4783          	lbu	a5,0(s4)
ffffffffc0204674:	3dfd                	addiw	s11,s11,-1
ffffffffc0204676:	0a05                	addi	s4,s4,1
ffffffffc0204678:	0007851b          	sext.w	a0,a5
ffffffffc020467c:	ffe1                	bnez	a5,ffffffffc0204654 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020467e:	01b05963          	blez	s11,ffffffffc0204690 <vprintfmt+0x244>
ffffffffc0204682:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204684:	85a6                	mv	a1,s1
ffffffffc0204686:	02000513          	li	a0,32
ffffffffc020468a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020468c:	fe0d9be3          	bnez	s11,ffffffffc0204682 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204690:	6a02                	ld	s4,0(sp)
ffffffffc0204692:	bbd5                	j	ffffffffc0204486 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204694:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204696:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020469a:	01174463          	blt	a4,a7,ffffffffc02046a2 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020469e:	08088d63          	beqz	a7,ffffffffc0204738 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02046a2:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02046a6:	0a044d63          	bltz	s0,ffffffffc0204760 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02046aa:	8622                	mv	a2,s0
ffffffffc02046ac:	8a66                	mv	s4,s9
ffffffffc02046ae:	46a9                	li	a3,10
ffffffffc02046b0:	bdcd                	j	ffffffffc02045a2 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02046b2:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02046b6:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02046b8:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02046ba:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02046be:	8fb5                	xor	a5,a5,a3
ffffffffc02046c0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02046c4:	02d74163          	blt	a4,a3,ffffffffc02046e6 <vprintfmt+0x29a>
ffffffffc02046c8:	00369793          	slli	a5,a3,0x3
ffffffffc02046cc:	97de                	add	a5,a5,s7
ffffffffc02046ce:	639c                	ld	a5,0(a5)
ffffffffc02046d0:	cb99                	beqz	a5,ffffffffc02046e6 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02046d2:	86be                	mv	a3,a5
ffffffffc02046d4:	00000617          	auipc	a2,0x0
ffffffffc02046d8:	1ec60613          	addi	a2,a2,492 # ffffffffc02048c0 <etext+0x28>
ffffffffc02046dc:	85a6                	mv	a1,s1
ffffffffc02046de:	854a                	mv	a0,s2
ffffffffc02046e0:	0ce000ef          	jal	ra,ffffffffc02047ae <printfmt>
ffffffffc02046e4:	b34d                	j	ffffffffc0204486 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02046e6:	00002617          	auipc	a2,0x2
ffffffffc02046ea:	fca60613          	addi	a2,a2,-54 # ffffffffc02066b0 <buddy_system_pmm_manager+0x1138>
ffffffffc02046ee:	85a6                	mv	a1,s1
ffffffffc02046f0:	854a                	mv	a0,s2
ffffffffc02046f2:	0bc000ef          	jal	ra,ffffffffc02047ae <printfmt>
ffffffffc02046f6:	bb41                	j	ffffffffc0204486 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02046f8:	00002417          	auipc	s0,0x2
ffffffffc02046fc:	fb040413          	addi	s0,s0,-80 # ffffffffc02066a8 <buddy_system_pmm_manager+0x1130>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204700:	85e2                	mv	a1,s8
ffffffffc0204702:	8522                	mv	a0,s0
ffffffffc0204704:	e43e                	sd	a5,8(sp)
ffffffffc0204706:	0e2000ef          	jal	ra,ffffffffc02047e8 <strnlen>
ffffffffc020470a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020470e:	01b05b63          	blez	s11,ffffffffc0204724 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204712:	67a2                	ld	a5,8(sp)
ffffffffc0204714:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204718:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020471a:	85a6                	mv	a1,s1
ffffffffc020471c:	8552                	mv	a0,s4
ffffffffc020471e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204720:	fe0d9ce3          	bnez	s11,ffffffffc0204718 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204724:	00044783          	lbu	a5,0(s0)
ffffffffc0204728:	00140a13          	addi	s4,s0,1
ffffffffc020472c:	0007851b          	sext.w	a0,a5
ffffffffc0204730:	d3a5                	beqz	a5,ffffffffc0204690 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204732:	05e00413          	li	s0,94
ffffffffc0204736:	bf39                	j	ffffffffc0204654 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204738:	000a2403          	lw	s0,0(s4)
ffffffffc020473c:	b7ad                	j	ffffffffc02046a6 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020473e:	000a6603          	lwu	a2,0(s4)
ffffffffc0204742:	46a1                	li	a3,8
ffffffffc0204744:	8a2e                	mv	s4,a1
ffffffffc0204746:	bdb1                	j	ffffffffc02045a2 <vprintfmt+0x156>
ffffffffc0204748:	000a6603          	lwu	a2,0(s4)
ffffffffc020474c:	46a9                	li	a3,10
ffffffffc020474e:	8a2e                	mv	s4,a1
ffffffffc0204750:	bd89                	j	ffffffffc02045a2 <vprintfmt+0x156>
ffffffffc0204752:	000a6603          	lwu	a2,0(s4)
ffffffffc0204756:	46c1                	li	a3,16
ffffffffc0204758:	8a2e                	mv	s4,a1
ffffffffc020475a:	b5a1                	j	ffffffffc02045a2 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020475c:	9902                	jalr	s2
ffffffffc020475e:	bf09                	j	ffffffffc0204670 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204760:	85a6                	mv	a1,s1
ffffffffc0204762:	02d00513          	li	a0,45
ffffffffc0204766:	e03e                	sd	a5,0(sp)
ffffffffc0204768:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020476a:	6782                	ld	a5,0(sp)
ffffffffc020476c:	8a66                	mv	s4,s9
ffffffffc020476e:	40800633          	neg	a2,s0
ffffffffc0204772:	46a9                	li	a3,10
ffffffffc0204774:	b53d                	j	ffffffffc02045a2 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204776:	03b05163          	blez	s11,ffffffffc0204798 <vprintfmt+0x34c>
ffffffffc020477a:	02d00693          	li	a3,45
ffffffffc020477e:	f6d79de3          	bne	a5,a3,ffffffffc02046f8 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204782:	00002417          	auipc	s0,0x2
ffffffffc0204786:	f2640413          	addi	s0,s0,-218 # ffffffffc02066a8 <buddy_system_pmm_manager+0x1130>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020478a:	02800793          	li	a5,40
ffffffffc020478e:	02800513          	li	a0,40
ffffffffc0204792:	00140a13          	addi	s4,s0,1
ffffffffc0204796:	bd6d                	j	ffffffffc0204650 <vprintfmt+0x204>
ffffffffc0204798:	00002a17          	auipc	s4,0x2
ffffffffc020479c:	f11a0a13          	addi	s4,s4,-239 # ffffffffc02066a9 <buddy_system_pmm_manager+0x1131>
ffffffffc02047a0:	02800513          	li	a0,40
ffffffffc02047a4:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02047a8:	05e00413          	li	s0,94
ffffffffc02047ac:	b565                	j	ffffffffc0204654 <vprintfmt+0x208>

ffffffffc02047ae <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02047ae:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02047b0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02047b4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02047b6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02047b8:	ec06                	sd	ra,24(sp)
ffffffffc02047ba:	f83a                	sd	a4,48(sp)
ffffffffc02047bc:	fc3e                	sd	a5,56(sp)
ffffffffc02047be:	e0c2                	sd	a6,64(sp)
ffffffffc02047c0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02047c2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02047c4:	c89ff0ef          	jal	ra,ffffffffc020444c <vprintfmt>
}
ffffffffc02047c8:	60e2                	ld	ra,24(sp)
ffffffffc02047ca:	6161                	addi	sp,sp,80
ffffffffc02047cc:	8082                	ret

ffffffffc02047ce <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02047ce:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02047d2:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02047d4:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02047d6:	cb81                	beqz	a5,ffffffffc02047e6 <strlen+0x18>
        cnt ++;
ffffffffc02047d8:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02047da:	00a707b3          	add	a5,a4,a0
ffffffffc02047de:	0007c783          	lbu	a5,0(a5)
ffffffffc02047e2:	fbfd                	bnez	a5,ffffffffc02047d8 <strlen+0xa>
ffffffffc02047e4:	8082                	ret
    }
    return cnt;
}
ffffffffc02047e6:	8082                	ret

ffffffffc02047e8 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02047e8:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02047ea:	e589                	bnez	a1,ffffffffc02047f4 <strnlen+0xc>
ffffffffc02047ec:	a811                	j	ffffffffc0204800 <strnlen+0x18>
        cnt ++;
ffffffffc02047ee:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02047f0:	00f58863          	beq	a1,a5,ffffffffc0204800 <strnlen+0x18>
ffffffffc02047f4:	00f50733          	add	a4,a0,a5
ffffffffc02047f8:	00074703          	lbu	a4,0(a4)
ffffffffc02047fc:	fb6d                	bnez	a4,ffffffffc02047ee <strnlen+0x6>
ffffffffc02047fe:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0204800:	852e                	mv	a0,a1
ffffffffc0204802:	8082                	ret

ffffffffc0204804 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204804:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204806:	0005c703          	lbu	a4,0(a1)
ffffffffc020480a:	0785                	addi	a5,a5,1
ffffffffc020480c:	0585                	addi	a1,a1,1
ffffffffc020480e:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204812:	fb75                	bnez	a4,ffffffffc0204806 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204814:	8082                	ret

ffffffffc0204816 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204816:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020481a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020481e:	cb89                	beqz	a5,ffffffffc0204830 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0204820:	0505                	addi	a0,a0,1
ffffffffc0204822:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204824:	fee789e3          	beq	a5,a4,ffffffffc0204816 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204828:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020482c:	9d19                	subw	a0,a0,a4
ffffffffc020482e:	8082                	ret
ffffffffc0204830:	4501                	li	a0,0
ffffffffc0204832:	bfed                	j	ffffffffc020482c <strcmp+0x16>

ffffffffc0204834 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204834:	00054783          	lbu	a5,0(a0)
ffffffffc0204838:	c799                	beqz	a5,ffffffffc0204846 <strchr+0x12>
        if (*s == c) {
ffffffffc020483a:	00f58763          	beq	a1,a5,ffffffffc0204848 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020483e:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0204842:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204844:	fbfd                	bnez	a5,ffffffffc020483a <strchr+0x6>
    }
    return NULL;
ffffffffc0204846:	4501                	li	a0,0
}
ffffffffc0204848:	8082                	ret

ffffffffc020484a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020484a:	ca01                	beqz	a2,ffffffffc020485a <memset+0x10>
ffffffffc020484c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020484e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204850:	0785                	addi	a5,a5,1
ffffffffc0204852:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204856:	fec79de3          	bne	a5,a2,ffffffffc0204850 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020485a:	8082                	ret

ffffffffc020485c <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020485c:	ca19                	beqz	a2,ffffffffc0204872 <memcpy+0x16>
ffffffffc020485e:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204860:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204862:	0005c703          	lbu	a4,0(a1)
ffffffffc0204866:	0585                	addi	a1,a1,1
ffffffffc0204868:	0785                	addi	a5,a5,1
ffffffffc020486a:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020486e:	fec59ae3          	bne	a1,a2,ffffffffc0204862 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204872:	8082                	ret

ffffffffc0204874 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204874:	c205                	beqz	a2,ffffffffc0204894 <memcmp+0x20>
ffffffffc0204876:	962e                	add	a2,a2,a1
ffffffffc0204878:	a019                	j	ffffffffc020487e <memcmp+0xa>
ffffffffc020487a:	00c58d63          	beq	a1,a2,ffffffffc0204894 <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc020487e:	00054783          	lbu	a5,0(a0)
ffffffffc0204882:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204886:	0505                	addi	a0,a0,1
ffffffffc0204888:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc020488a:	fee788e3          	beq	a5,a4,ffffffffc020487a <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020488e:	40e7853b          	subw	a0,a5,a4
ffffffffc0204892:	8082                	ret
    }
    return 0;
ffffffffc0204894:	4501                	li	a0,0
}
ffffffffc0204896:	8082                	ret
