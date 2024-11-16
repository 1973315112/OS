
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


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc020a040 <ide>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	53660613          	addi	a2,a2,1334 # ffffffffc0211570 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	70f030ef          	jal	ra,ffffffffc0203f58 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	3da58593          	addi	a1,a1,986 # ffffffffc0204428 <etext+0x4>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	3f250513          	addi	a0,a0,1010 # ffffffffc0204448 <etext+0x24>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();           // 打印核心信息
ffffffffc0200062:	0fc000ef          	jal	ra,ffffffffc020015e <print_kerninfo>
    // grade_backtrace();
    pmm_init();                 // 初始化物理内存管理器
ffffffffc0200066:	6a7020ef          	jal	ra,ffffffffc0202f0c <pmm_init>
    idt_init();                 // 初始化中断描述符表
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init();                 // 初始化虚拟内存管理器(本次的新增)
ffffffffc020006e:	423000ef          	jal	ra,ffffffffc0200c90 <vmm_init>
    ide_init();                 // 初始化磁盘设备(本次的新增,空的)
ffffffffc0200072:	35e000ef          	jal	ra,ffffffffc02003d0 <ide_init>
    swap_init();                // 初始化页面交换机制(本次的核心)
ffffffffc0200076:	2c0010ef          	jal	ra,ffffffffc0201336 <swap_init>

    clock_init();               // 初始化时钟中断
ffffffffc020007a:	3ac000ef          	jal	ra,ffffffffc0200426 <clock_init>
    // intr_enable();           // 启用中断请求
    /* do nothing */
    while (1) {};
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200088:	3f0000ef          	jal	ra,ffffffffc0200478 <cons_putc>
    (*cnt) ++;
ffffffffc020008c:	401c                	lw	a5,0(s0)
}
ffffffffc020008e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
}
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ac:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ae:	741030ef          	jal	ra,ffffffffc0203fee <vprintfmt>
    return cnt;
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ba:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000bc:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c0:	8e2a                	mv	t3,a0
ffffffffc02000c2:	f42e                	sd	a1,40(sp)
ffffffffc02000c4:	f832                	sd	a2,48(sp)
ffffffffc02000c6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c8:	00000517          	auipc	a0,0x0
ffffffffc02000cc:	fb850513          	addi	a0,a0,-72 # ffffffffc0200080 <cputch>
ffffffffc02000d0:	004c                	addi	a1,sp,4
ffffffffc02000d2:	869a                	mv	a3,t1
ffffffffc02000d4:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	ec06                	sd	ra,24(sp)
ffffffffc02000d8:	e0ba                	sd	a4,64(sp)
ffffffffc02000da:	e4be                	sd	a5,72(sp)
ffffffffc02000dc:	e8c2                	sd	a6,80(sp)
ffffffffc02000de:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e0:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e2:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e4:	70b030ef          	jal	ra,ffffffffc0203fee <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e8:	60e2                	ld	ra,24(sp)
ffffffffc02000ea:	4512                	lw	a0,4(sp)
ffffffffc02000ec:	6125                	addi	sp,sp,96
ffffffffc02000ee:	8082                	ret

ffffffffc02000f0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f0:	a661                	j	ffffffffc0200478 <cons_putc>

ffffffffc02000f2 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f2:	1141                	addi	sp,sp,-16
ffffffffc02000f4:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f6:	3b6000ef          	jal	ra,ffffffffc02004ac <cons_getc>
ffffffffc02000fa:	dd75                	beqz	a0,ffffffffc02000f6 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fc:	60a2                	ld	ra,8(sp)
ffffffffc02000fe:	0141                	addi	sp,sp,16
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200102:	00011317          	auipc	t1,0x11
ffffffffc0200106:	3f630313          	addi	t1,t1,1014 # ffffffffc02114f8 <is_panic>
ffffffffc020010a:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020010e:	715d                	addi	sp,sp,-80
ffffffffc0200110:	ec06                	sd	ra,24(sp)
ffffffffc0200112:	e822                	sd	s0,16(sp)
ffffffffc0200114:	f436                	sd	a3,40(sp)
ffffffffc0200116:	f83a                	sd	a4,48(sp)
ffffffffc0200118:	fc3e                	sd	a5,56(sp)
ffffffffc020011a:	e0c2                	sd	a6,64(sp)
ffffffffc020011c:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020011e:	020e1a63          	bnez	t3,ffffffffc0200152 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200122:	4785                	li	a5,1
ffffffffc0200124:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200128:	8432                	mv	s0,a2
ffffffffc020012a:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020012c:	862e                	mv	a2,a1
ffffffffc020012e:	85aa                	mv	a1,a0
ffffffffc0200130:	00004517          	auipc	a0,0x4
ffffffffc0200134:	32050513          	addi	a0,a0,800 # ffffffffc0204450 <etext+0x2c>
    va_start(ap, fmt);
ffffffffc0200138:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020013a:	f81ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc020013e:	65a2                	ld	a1,8(sp)
ffffffffc0200140:	8522                	mv	a0,s0
ffffffffc0200142:	f59ff0ef          	jal	ra,ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc0200146:	00006517          	auipc	a0,0x6
ffffffffc020014a:	c1a50513          	addi	a0,a0,-998 # ffffffffc0205d60 <default_pmm_manager+0x4f0>
ffffffffc020014e:	f6dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200152:	39c000ef          	jal	ra,ffffffffc02004ee <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200156:	4501                	li	a0,0
ffffffffc0200158:	130000ef          	jal	ra,ffffffffc0200288 <kmonitor>
    while (1) {
ffffffffc020015c:	bfed                	j	ffffffffc0200156 <__panic+0x54>

ffffffffc020015e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020015e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200160:	00004517          	auipc	a0,0x4
ffffffffc0200164:	31050513          	addi	a0,a0,784 # ffffffffc0204470 <etext+0x4c>
void print_kerninfo(void) {
ffffffffc0200168:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020016a:	f51ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020016e:	00000597          	auipc	a1,0x0
ffffffffc0200172:	ec458593          	addi	a1,a1,-316 # ffffffffc0200032 <kern_init>
ffffffffc0200176:	00004517          	auipc	a0,0x4
ffffffffc020017a:	31a50513          	addi	a0,a0,794 # ffffffffc0204490 <etext+0x6c>
ffffffffc020017e:	f3dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200182:	00004597          	auipc	a1,0x4
ffffffffc0200186:	2a258593          	addi	a1,a1,674 # ffffffffc0204424 <etext>
ffffffffc020018a:	00004517          	auipc	a0,0x4
ffffffffc020018e:	32650513          	addi	a0,a0,806 # ffffffffc02044b0 <etext+0x8c>
ffffffffc0200192:	f29ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200196:	0000a597          	auipc	a1,0xa
ffffffffc020019a:	eaa58593          	addi	a1,a1,-342 # ffffffffc020a040 <ide>
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	33250513          	addi	a0,a0,818 # ffffffffc02044d0 <etext+0xac>
ffffffffc02001a6:	f15ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001aa:	00011597          	auipc	a1,0x11
ffffffffc02001ae:	3c658593          	addi	a1,a1,966 # ffffffffc0211570 <end>
ffffffffc02001b2:	00004517          	auipc	a0,0x4
ffffffffc02001b6:	33e50513          	addi	a0,a0,830 # ffffffffc02044f0 <etext+0xcc>
ffffffffc02001ba:	f01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001be:	00011597          	auipc	a1,0x11
ffffffffc02001c2:	7b158593          	addi	a1,a1,1969 # ffffffffc021196f <end+0x3ff>
ffffffffc02001c6:	00000797          	auipc	a5,0x0
ffffffffc02001ca:	e6c78793          	addi	a5,a5,-404 # ffffffffc0200032 <kern_init>
ffffffffc02001ce:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001d6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001dc:	95be                	add	a1,a1,a5
ffffffffc02001de:	85a9                	srai	a1,a1,0xa
ffffffffc02001e0:	00004517          	auipc	a0,0x4
ffffffffc02001e4:	33050513          	addi	a0,a0,816 # ffffffffc0204510 <etext+0xec>
}
ffffffffc02001e8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ea:	bdc1                	j	ffffffffc02000ba <cprintf>

ffffffffc02001ec <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ec:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ee:	00004617          	auipc	a2,0x4
ffffffffc02001f2:	35260613          	addi	a2,a2,850 # ffffffffc0204540 <etext+0x11c>
ffffffffc02001f6:	04e00593          	li	a1,78
ffffffffc02001fa:	00004517          	auipc	a0,0x4
ffffffffc02001fe:	35e50513          	addi	a0,a0,862 # ffffffffc0204558 <etext+0x134>
void print_stackframe(void) {
ffffffffc0200202:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200204:	effff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200208 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200208:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020020a:	00004617          	auipc	a2,0x4
ffffffffc020020e:	36660613          	addi	a2,a2,870 # ffffffffc0204570 <etext+0x14c>
ffffffffc0200212:	00004597          	auipc	a1,0x4
ffffffffc0200216:	37e58593          	addi	a1,a1,894 # ffffffffc0204590 <etext+0x16c>
ffffffffc020021a:	00004517          	auipc	a0,0x4
ffffffffc020021e:	37e50513          	addi	a0,a0,894 # ffffffffc0204598 <etext+0x174>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200224:	e97ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200228:	00004617          	auipc	a2,0x4
ffffffffc020022c:	38060613          	addi	a2,a2,896 # ffffffffc02045a8 <etext+0x184>
ffffffffc0200230:	00004597          	auipc	a1,0x4
ffffffffc0200234:	3a058593          	addi	a1,a1,928 # ffffffffc02045d0 <etext+0x1ac>
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	36050513          	addi	a0,a0,864 # ffffffffc0204598 <etext+0x174>
ffffffffc0200240:	e7bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200244:	00004617          	auipc	a2,0x4
ffffffffc0200248:	39c60613          	addi	a2,a2,924 # ffffffffc02045e0 <etext+0x1bc>
ffffffffc020024c:	00004597          	auipc	a1,0x4
ffffffffc0200250:	3b458593          	addi	a1,a1,948 # ffffffffc0204600 <etext+0x1dc>
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	34450513          	addi	a0,a0,836 # ffffffffc0204598 <etext+0x174>
ffffffffc020025c:	e5fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc0200260:	60a2                	ld	ra,8(sp)
ffffffffc0200262:	4501                	li	a0,0
ffffffffc0200264:	0141                	addi	sp,sp,16
ffffffffc0200266:	8082                	ret

ffffffffc0200268 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200268:	1141                	addi	sp,sp,-16
ffffffffc020026a:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020026c:	ef3ff0ef          	jal	ra,ffffffffc020015e <print_kerninfo>
    return 0;
}
ffffffffc0200270:	60a2                	ld	ra,8(sp)
ffffffffc0200272:	4501                	li	a0,0
ffffffffc0200274:	0141                	addi	sp,sp,16
ffffffffc0200276:	8082                	ret

ffffffffc0200278 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200278:	1141                	addi	sp,sp,-16
ffffffffc020027a:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020027c:	f71ff0ef          	jal	ra,ffffffffc02001ec <print_stackframe>
    return 0;
}
ffffffffc0200280:	60a2                	ld	ra,8(sp)
ffffffffc0200282:	4501                	li	a0,0
ffffffffc0200284:	0141                	addi	sp,sp,16
ffffffffc0200286:	8082                	ret

ffffffffc0200288 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200288:	7115                	addi	sp,sp,-224
ffffffffc020028a:	ed5e                	sd	s7,152(sp)
ffffffffc020028c:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	00004517          	auipc	a0,0x4
ffffffffc0200292:	38250513          	addi	a0,a0,898 # ffffffffc0204610 <etext+0x1ec>
kmonitor(struct trapframe *tf) {
ffffffffc0200296:	ed86                	sd	ra,216(sp)
ffffffffc0200298:	e9a2                	sd	s0,208(sp)
ffffffffc020029a:	e5a6                	sd	s1,200(sp)
ffffffffc020029c:	e1ca                	sd	s2,192(sp)
ffffffffc020029e:	fd4e                	sd	s3,184(sp)
ffffffffc02002a0:	f952                	sd	s4,176(sp)
ffffffffc02002a2:	f556                	sd	s5,168(sp)
ffffffffc02002a4:	f15a                	sd	s6,160(sp)
ffffffffc02002a6:	e962                	sd	s8,144(sp)
ffffffffc02002a8:	e566                	sd	s9,136(sp)
ffffffffc02002aa:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002ac:	e0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002b0:	00004517          	auipc	a0,0x4
ffffffffc02002b4:	38850513          	addi	a0,a0,904 # ffffffffc0204638 <etext+0x214>
ffffffffc02002b8:	e03ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc02002bc:	000b8563          	beqz	s7,ffffffffc02002c6 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002c0:	855e                	mv	a0,s7
ffffffffc02002c2:	48c000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc02002c6:	00004c17          	auipc	s8,0x4
ffffffffc02002ca:	3dac0c13          	addi	s8,s8,986 # ffffffffc02046a0 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002ce:	00005917          	auipc	s2,0x5
ffffffffc02002d2:	14290913          	addi	s2,s2,322 # ffffffffc0205410 <commands+0xd70>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d6:	00004497          	auipc	s1,0x4
ffffffffc02002da:	38a48493          	addi	s1,s1,906 # ffffffffc0204660 <etext+0x23c>
        if (argc == MAXARGS - 1) {
ffffffffc02002de:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002e0:	00004b17          	auipc	s6,0x4
ffffffffc02002e4:	388b0b13          	addi	s6,s6,904 # ffffffffc0204668 <etext+0x244>
        argv[argc ++] = buf;
ffffffffc02002e8:	00004a17          	auipc	s4,0x4
ffffffffc02002ec:	2a8a0a13          	addi	s4,s4,680 # ffffffffc0204590 <etext+0x16c>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002f2:	854a                	mv	a0,s2
ffffffffc02002f4:	07c040ef          	jal	ra,ffffffffc0204370 <readline>
ffffffffc02002f8:	842a                	mv	s0,a0
ffffffffc02002fa:	dd65                	beqz	a0,ffffffffc02002f2 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002fc:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200300:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200302:	e1bd                	bnez	a1,ffffffffc0200368 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc0200304:	fe0c87e3          	beqz	s9,ffffffffc02002f2 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	6582                	ld	a1,0(sp)
ffffffffc020030a:	00004d17          	auipc	s10,0x4
ffffffffc020030e:	396d0d13          	addi	s10,s10,918 # ffffffffc02046a0 <commands>
        argv[argc ++] = buf;
ffffffffc0200312:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200314:	4401                	li	s0,0
ffffffffc0200316:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	40d030ef          	jal	ra,ffffffffc0203f24 <strcmp>
ffffffffc020031c:	c919                	beqz	a0,ffffffffc0200332 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020031e:	2405                	addiw	s0,s0,1
ffffffffc0200320:	0b540063          	beq	s0,s5,ffffffffc02003c0 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200324:	000d3503          	ld	a0,0(s10)
ffffffffc0200328:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020032a:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020032c:	3f9030ef          	jal	ra,ffffffffc0203f24 <strcmp>
ffffffffc0200330:	f57d                	bnez	a0,ffffffffc020031e <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200332:	00141793          	slli	a5,s0,0x1
ffffffffc0200336:	97a2                	add	a5,a5,s0
ffffffffc0200338:	078e                	slli	a5,a5,0x3
ffffffffc020033a:	97e2                	add	a5,a5,s8
ffffffffc020033c:	6b9c                	ld	a5,16(a5)
ffffffffc020033e:	865e                	mv	a2,s7
ffffffffc0200340:	002c                	addi	a1,sp,8
ffffffffc0200342:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200346:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200348:	fa0555e3          	bgez	a0,ffffffffc02002f2 <kmonitor+0x6a>
}
ffffffffc020034c:	60ee                	ld	ra,216(sp)
ffffffffc020034e:	644e                	ld	s0,208(sp)
ffffffffc0200350:	64ae                	ld	s1,200(sp)
ffffffffc0200352:	690e                	ld	s2,192(sp)
ffffffffc0200354:	79ea                	ld	s3,184(sp)
ffffffffc0200356:	7a4a                	ld	s4,176(sp)
ffffffffc0200358:	7aaa                	ld	s5,168(sp)
ffffffffc020035a:	7b0a                	ld	s6,160(sp)
ffffffffc020035c:	6bea                	ld	s7,152(sp)
ffffffffc020035e:	6c4a                	ld	s8,144(sp)
ffffffffc0200360:	6caa                	ld	s9,136(sp)
ffffffffc0200362:	6d0a                	ld	s10,128(sp)
ffffffffc0200364:	612d                	addi	sp,sp,224
ffffffffc0200366:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200368:	8526                	mv	a0,s1
ffffffffc020036a:	3d9030ef          	jal	ra,ffffffffc0203f42 <strchr>
ffffffffc020036e:	c901                	beqz	a0,ffffffffc020037e <kmonitor+0xf6>
ffffffffc0200370:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200374:	00040023          	sb	zero,0(s0)
ffffffffc0200378:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020037a:	d5c9                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc020037c:	b7f5                	j	ffffffffc0200368 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020037e:	00044783          	lbu	a5,0(s0)
ffffffffc0200382:	d3c9                	beqz	a5,ffffffffc0200304 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200384:	033c8963          	beq	s9,s3,ffffffffc02003b6 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200388:	003c9793          	slli	a5,s9,0x3
ffffffffc020038c:	0118                	addi	a4,sp,128
ffffffffc020038e:	97ba                	add	a5,a5,a4
ffffffffc0200390:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200394:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200398:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020039a:	e591                	bnez	a1,ffffffffc02003a6 <kmonitor+0x11e>
ffffffffc020039c:	b7b5                	j	ffffffffc0200308 <kmonitor+0x80>
ffffffffc020039e:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003a2:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a4:	d1a5                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc02003a6:	8526                	mv	a0,s1
ffffffffc02003a8:	39b030ef          	jal	ra,ffffffffc0203f42 <strchr>
ffffffffc02003ac:	d96d                	beqz	a0,ffffffffc020039e <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ae:	00044583          	lbu	a1,0(s0)
ffffffffc02003b2:	d9a9                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc02003b4:	bf55                	j	ffffffffc0200368 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003b6:	45c1                	li	a1,16
ffffffffc02003b8:	855a                	mv	a0,s6
ffffffffc02003ba:	d01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02003be:	b7e9                	j	ffffffffc0200388 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003c0:	6582                	ld	a1,0(sp)
ffffffffc02003c2:	00004517          	auipc	a0,0x4
ffffffffc02003c6:	2c650513          	addi	a0,a0,710 # ffffffffc0204688 <etext+0x264>
ffffffffc02003ca:	cf1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    return 0;
ffffffffc02003ce:	b715                	j	ffffffffc02002f2 <kmonitor+0x6a>

ffffffffc02003d0 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02003d0:	8082                	ret

ffffffffc02003d2 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02003d2:	00253513          	sltiu	a0,a0,2
ffffffffc02003d6:	8082                	ret

ffffffffc02003d8 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02003d8:	03800513          	li	a0,56
ffffffffc02003dc:	8082                	ret

ffffffffc02003de <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003de:	0000a797          	auipc	a5,0xa
ffffffffc02003e2:	c6278793          	addi	a5,a5,-926 # ffffffffc020a040 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02003e6:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02003ea:	1141                	addi	sp,sp,-16
ffffffffc02003ec:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003ee:	95be                	add	a1,a1,a5
ffffffffc02003f0:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02003f4:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003f6:	375030ef          	jal	ra,ffffffffc0203f6a <memcpy>
    return 0;
}
ffffffffc02003fa:	60a2                	ld	ra,8(sp)
ffffffffc02003fc:	4501                	li	a0,0
ffffffffc02003fe:	0141                	addi	sp,sp,16
ffffffffc0200400:	8082                	ret

ffffffffc0200402 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200402:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200406:	0000a517          	auipc	a0,0xa
ffffffffc020040a:	c3a50513          	addi	a0,a0,-966 # ffffffffc020a040 <ide>
                   size_t nsecs) {
ffffffffc020040e:	1141                	addi	sp,sp,-16
ffffffffc0200410:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200412:	953e                	add	a0,a0,a5
ffffffffc0200414:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc0200418:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020041a:	351030ef          	jal	ra,ffffffffc0203f6a <memcpy>
    return 0;
}
ffffffffc020041e:	60a2                	ld	ra,8(sp)
ffffffffc0200420:	4501                	li	a0,0
ffffffffc0200422:	0141                	addi	sp,sp,16
ffffffffc0200424:	8082                	ret

ffffffffc0200426 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200426:	67e1                	lui	a5,0x18
ffffffffc0200428:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020042c:	00011717          	auipc	a4,0x11
ffffffffc0200430:	0cf73e23          	sd	a5,220(a4) # ffffffffc0211508 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200434:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200438:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043a:	953e                	add	a0,a0,a5
ffffffffc020043c:	4601                	li	a2,0
ffffffffc020043e:	4881                	li	a7,0
ffffffffc0200440:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200444:	02000793          	li	a5,32
ffffffffc0200448:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020044c:	00004517          	auipc	a0,0x4
ffffffffc0200450:	29c50513          	addi	a0,a0,668 # ffffffffc02046e8 <commands+0x48>
    ticks = 0;
ffffffffc0200454:	00011797          	auipc	a5,0x11
ffffffffc0200458:	0a07b623          	sd	zero,172(a5) # ffffffffc0211500 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020045c:	b9b9                	j	ffffffffc02000ba <cprintf>

ffffffffc020045e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020045e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200462:	00011797          	auipc	a5,0x11
ffffffffc0200466:	0a67b783          	ld	a5,166(a5) # ffffffffc0211508 <timebase>
ffffffffc020046a:	953e                	add	a0,a0,a5
ffffffffc020046c:	4581                	li	a1,0
ffffffffc020046e:	4601                	li	a2,0
ffffffffc0200470:	4881                	li	a7,0
ffffffffc0200472:	00000073          	ecall
ffffffffc0200476:	8082                	ret

ffffffffc0200478 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200478:	100027f3          	csrr	a5,sstatus
ffffffffc020047c:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020047e:	0ff57513          	zext.b	a0,a0
ffffffffc0200482:	e799                	bnez	a5,ffffffffc0200490 <cons_putc+0x18>
ffffffffc0200484:	4581                	li	a1,0
ffffffffc0200486:	4601                	li	a2,0
ffffffffc0200488:	4885                	li	a7,1
ffffffffc020048a:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020048e:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200490:	1101                	addi	sp,sp,-32
ffffffffc0200492:	ec06                	sd	ra,24(sp)
ffffffffc0200494:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200496:	058000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020049a:	6522                	ld	a0,8(sp)
ffffffffc020049c:	4581                	li	a1,0
ffffffffc020049e:	4601                	li	a2,0
ffffffffc02004a0:	4885                	li	a7,1
ffffffffc02004a2:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02004a6:	60e2                	ld	ra,24(sp)
ffffffffc02004a8:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02004aa:	a83d                	j	ffffffffc02004e8 <intr_enable>

ffffffffc02004ac <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004ac:	100027f3          	csrr	a5,sstatus
ffffffffc02004b0:	8b89                	andi	a5,a5,2
ffffffffc02004b2:	eb89                	bnez	a5,ffffffffc02004c4 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02004b4:	4501                	li	a0,0
ffffffffc02004b6:	4581                	li	a1,0
ffffffffc02004b8:	4601                	li	a2,0
ffffffffc02004ba:	4889                	li	a7,2
ffffffffc02004bc:	00000073          	ecall
ffffffffc02004c0:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02004c2:	8082                	ret
int cons_getc(void) {
ffffffffc02004c4:	1101                	addi	sp,sp,-32
ffffffffc02004c6:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02004c8:	026000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02004cc:	4501                	li	a0,0
ffffffffc02004ce:	4581                	li	a1,0
ffffffffc02004d0:	4601                	li	a2,0
ffffffffc02004d2:	4889                	li	a7,2
ffffffffc02004d4:	00000073          	ecall
ffffffffc02004d8:	2501                	sext.w	a0,a0
ffffffffc02004da:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02004dc:	00c000ef          	jal	ra,ffffffffc02004e8 <intr_enable>
}
ffffffffc02004e0:	60e2                	ld	ra,24(sp)
ffffffffc02004e2:	6522                	ld	a0,8(sp)
ffffffffc02004e4:	6105                	addi	sp,sp,32
ffffffffc02004e6:	8082                	ret

ffffffffc02004e8 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004e8:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004ec:	8082                	ret

ffffffffc02004ee <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ee:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f4:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004f8:	1141                	addi	sp,sp,-16
ffffffffc02004fa:	e022                	sd	s0,0(sp)
ffffffffc02004fc:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004fe:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200502:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200506:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200508:	05500613          	li	a2,85
ffffffffc020050c:	c399                	beqz	a5,ffffffffc0200512 <pgfault_handler+0x1e>
ffffffffc020050e:	04b00613          	li	a2,75
ffffffffc0200512:	11843703          	ld	a4,280(s0)
ffffffffc0200516:	47bd                	li	a5,15
ffffffffc0200518:	05700693          	li	a3,87
ffffffffc020051c:	00f70463          	beq	a4,a5,ffffffffc0200524 <pgfault_handler+0x30>
ffffffffc0200520:	05200693          	li	a3,82
ffffffffc0200524:	00004517          	auipc	a0,0x4
ffffffffc0200528:	1e450513          	addi	a0,a0,484 # ffffffffc0204708 <commands+0x68>
ffffffffc020052c:	b8fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	fe053503          	ld	a0,-32(a0) # ffffffffc0211510 <check_mm_struct>
ffffffffc0200538:	c911                	beqz	a0,ffffffffc020054c <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020053a:	11043603          	ld	a2,272(s0)
ffffffffc020053e:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200542:	6402                	ld	s0,0(sp)
ffffffffc0200544:	60a2                	ld	ra,8(sp)
ffffffffc0200546:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	5210006f          	j	ffffffffc0201268 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020054c:	00004617          	auipc	a2,0x4
ffffffffc0200550:	1dc60613          	addi	a2,a2,476 # ffffffffc0204728 <commands+0x88>
ffffffffc0200554:	07800593          	li	a1,120
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	1e850513          	addi	a0,a0,488 # ffffffffc0204740 <commands+0xa0>
ffffffffc0200560:	ba3ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200564 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200564:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200568:	00000797          	auipc	a5,0x0
ffffffffc020056c:	48878793          	addi	a5,a5,1160 # ffffffffc02009f0 <__alltraps>
ffffffffc0200570:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200574:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200578:	000407b7          	lui	a5,0x40
ffffffffc020057c:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200582:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200584:	1141                	addi	sp,sp,-16
ffffffffc0200586:	e022                	sd	s0,0(sp)
ffffffffc0200588:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020058a:	00004517          	auipc	a0,0x4
ffffffffc020058e:	1ce50513          	addi	a0,a0,462 # ffffffffc0204758 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	1d650513          	addi	a0,a0,470 # ffffffffc0204770 <commands+0xd0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	1e050513          	addi	a0,a0,480 # ffffffffc0204788 <commands+0xe8>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	1ea50513          	addi	a0,a0,490 # ffffffffc02047a0 <commands+0x100>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	1f450513          	addi	a0,a0,500 # ffffffffc02047b8 <commands+0x118>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	1fe50513          	addi	a0,a0,510 # ffffffffc02047d0 <commands+0x130>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	20850513          	addi	a0,a0,520 # ffffffffc02047e8 <commands+0x148>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	21250513          	addi	a0,a0,530 # ffffffffc0204800 <commands+0x160>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	21c50513          	addi	a0,a0,540 # ffffffffc0204818 <commands+0x178>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	22650513          	addi	a0,a0,550 # ffffffffc0204830 <commands+0x190>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	23050513          	addi	a0,a0,560 # ffffffffc0204848 <commands+0x1a8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	23a50513          	addi	a0,a0,570 # ffffffffc0204860 <commands+0x1c0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	24450513          	addi	a0,a0,580 # ffffffffc0204878 <commands+0x1d8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	24e50513          	addi	a0,a0,590 # ffffffffc0204890 <commands+0x1f0>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	25850513          	addi	a0,a0,600 # ffffffffc02048a8 <commands+0x208>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	26250513          	addi	a0,a0,610 # ffffffffc02048c0 <commands+0x220>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	26c50513          	addi	a0,a0,620 # ffffffffc02048d8 <commands+0x238>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	27650513          	addi	a0,a0,630 # ffffffffc02048f0 <commands+0x250>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	28050513          	addi	a0,a0,640 # ffffffffc0204908 <commands+0x268>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	28a50513          	addi	a0,a0,650 # ffffffffc0204920 <commands+0x280>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	29450513          	addi	a0,a0,660 # ffffffffc0204938 <commands+0x298>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	29e50513          	addi	a0,a0,670 # ffffffffc0204950 <commands+0x2b0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	2a850513          	addi	a0,a0,680 # ffffffffc0204968 <commands+0x2c8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	2b250513          	addi	a0,a0,690 # ffffffffc0204980 <commands+0x2e0>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	2bc50513          	addi	a0,a0,700 # ffffffffc0204998 <commands+0x2f8>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	2c650513          	addi	a0,a0,710 # ffffffffc02049b0 <commands+0x310>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	2d050513          	addi	a0,a0,720 # ffffffffc02049c8 <commands+0x328>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	2da50513          	addi	a0,a0,730 # ffffffffc02049e0 <commands+0x340>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	2e450513          	addi	a0,a0,740 # ffffffffc02049f8 <commands+0x358>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	2ee50513          	addi	a0,a0,750 # ffffffffc0204a10 <commands+0x370>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	2f850513          	addi	a0,a0,760 # ffffffffc0204a28 <commands+0x388>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	2fe50513          	addi	a0,a0,766 # ffffffffc0204a40 <commands+0x3a0>
}
ffffffffc020074a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074c:	b2bd                	j	ffffffffc02000ba <cprintf>

ffffffffc020074e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020074e:	1141                	addi	sp,sp,-16
ffffffffc0200750:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200752:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200754:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200756:	00004517          	auipc	a0,0x4
ffffffffc020075a:	30250513          	addi	a0,a0,770 # ffffffffc0204a58 <commands+0x3b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200760:	95bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200764:	8522                	mv	a0,s0
ffffffffc0200766:	e1dff0ef          	jal	ra,ffffffffc0200582 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020076a:	10043583          	ld	a1,256(s0)
ffffffffc020076e:	00004517          	auipc	a0,0x4
ffffffffc0200772:	30250513          	addi	a0,a0,770 # ffffffffc0204a70 <commands+0x3d0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	30a50513          	addi	a0,a0,778 # ffffffffc0204a88 <commands+0x3e8>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	31250513          	addi	a0,a0,786 # ffffffffc0204aa0 <commands+0x400>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	31650513          	addi	a0,a0,790 # ffffffffc0204ab8 <commands+0x418>
}
ffffffffc02007aa:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007ac:	90fff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc02007b0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007b0:	11853783          	ld	a5,280(a0)
ffffffffc02007b4:	472d                	li	a4,11
ffffffffc02007b6:	0786                	slli	a5,a5,0x1
ffffffffc02007b8:	8385                	srli	a5,a5,0x1
ffffffffc02007ba:	06f76c63          	bltu	a4,a5,ffffffffc0200832 <interrupt_handler+0x82>
ffffffffc02007be:	00004717          	auipc	a4,0x4
ffffffffc02007c2:	3c270713          	addi	a4,a4,962 # ffffffffc0204b80 <commands+0x4e0>
ffffffffc02007c6:	078a                	slli	a5,a5,0x2
ffffffffc02007c8:	97ba                	add	a5,a5,a4
ffffffffc02007ca:	439c                	lw	a5,0(a5)
ffffffffc02007cc:	97ba                	add	a5,a5,a4
ffffffffc02007ce:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	36050513          	addi	a0,a0,864 # ffffffffc0204b30 <commands+0x490>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	33450513          	addi	a0,a0,820 # ffffffffc0204b10 <commands+0x470>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	2e850513          	addi	a0,a0,744 # ffffffffc0204ad0 <commands+0x430>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	2fc50513          	addi	a0,a0,764 # ffffffffc0204af0 <commands+0x450>
ffffffffc02007fc:	8bfff06f          	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200800:	1141                	addi	sp,sp,-16
ffffffffc0200802:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200804:	c5bff0ef          	jal	ra,ffffffffc020045e <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200808:	00011697          	auipc	a3,0x11
ffffffffc020080c:	cf868693          	addi	a3,a3,-776 # ffffffffc0211500 <ticks>
ffffffffc0200810:	629c                	ld	a5,0(a3)
ffffffffc0200812:	06400713          	li	a4,100
ffffffffc0200816:	0785                	addi	a5,a5,1
ffffffffc0200818:	02e7f733          	remu	a4,a5,a4
ffffffffc020081c:	e29c                	sd	a5,0(a3)
ffffffffc020081e:	cb19                	beqz	a4,ffffffffc0200834 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200820:	60a2                	ld	ra,8(sp)
ffffffffc0200822:	0141                	addi	sp,sp,16
ffffffffc0200824:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200826:	00004517          	auipc	a0,0x4
ffffffffc020082a:	33a50513          	addi	a0,a0,826 # ffffffffc0204b60 <commands+0x4c0>
ffffffffc020082e:	88dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200832:	bf31                	j	ffffffffc020074e <print_trapframe>
}
ffffffffc0200834:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200836:	06400593          	li	a1,100
ffffffffc020083a:	00004517          	auipc	a0,0x4
ffffffffc020083e:	31650513          	addi	a0,a0,790 # ffffffffc0204b50 <commands+0x4b0>
}
ffffffffc0200842:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200844:	877ff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0200848 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200848:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020084c:	1101                	addi	sp,sp,-32
ffffffffc020084e:	e822                	sd	s0,16(sp)
ffffffffc0200850:	ec06                	sd	ra,24(sp)
ffffffffc0200852:	e426                	sd	s1,8(sp)
ffffffffc0200854:	473d                	li	a4,15
ffffffffc0200856:	842a                	mv	s0,a0
ffffffffc0200858:	14f76a63          	bltu	a4,a5,ffffffffc02009ac <exception_handler+0x164>
ffffffffc020085c:	00004717          	auipc	a4,0x4
ffffffffc0200860:	50c70713          	addi	a4,a4,1292 # ffffffffc0204d68 <commands+0x6c8>
ffffffffc0200864:	078a                	slli	a5,a5,0x2
ffffffffc0200866:	97ba                	add	a5,a5,a4
ffffffffc0200868:	439c                	lw	a5,0(a5)
ffffffffc020086a:	97ba                	add	a5,a5,a4
ffffffffc020086c:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020086e:	00004517          	auipc	a0,0x4
ffffffffc0200872:	4e250513          	addi	a0,a0,1250 # ffffffffc0204d50 <commands+0x6b0>
ffffffffc0200876:	845ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020087a:	8522                	mv	a0,s0
ffffffffc020087c:	c79ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200880:	84aa                	mv	s1,a0
ffffffffc0200882:	12051b63          	bnez	a0,ffffffffc02009b8 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200886:	60e2                	ld	ra,24(sp)
ffffffffc0200888:	6442                	ld	s0,16(sp)
ffffffffc020088a:	64a2                	ld	s1,8(sp)
ffffffffc020088c:	6105                	addi	sp,sp,32
ffffffffc020088e:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200890:	00004517          	auipc	a0,0x4
ffffffffc0200894:	32050513          	addi	a0,a0,800 # ffffffffc0204bb0 <commands+0x510>
}
ffffffffc0200898:	6442                	ld	s0,16(sp)
ffffffffc020089a:	60e2                	ld	ra,24(sp)
ffffffffc020089c:	64a2                	ld	s1,8(sp)
ffffffffc020089e:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008a0:	81bff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	32c50513          	addi	a0,a0,812 # ffffffffc0204bd0 <commands+0x530>
ffffffffc02008ac:	b7f5                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008ae:	00004517          	auipc	a0,0x4
ffffffffc02008b2:	34250513          	addi	a0,a0,834 # ffffffffc0204bf0 <commands+0x550>
ffffffffc02008b6:	b7cd                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008b8:	00004517          	auipc	a0,0x4
ffffffffc02008bc:	35050513          	addi	a0,a0,848 # ffffffffc0204c08 <commands+0x568>
ffffffffc02008c0:	bfe1                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008c2:	00004517          	auipc	a0,0x4
ffffffffc02008c6:	35650513          	addi	a0,a0,854 # ffffffffc0204c18 <commands+0x578>
ffffffffc02008ca:	b7f9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	36c50513          	addi	a0,a0,876 # ffffffffc0204c38 <commands+0x598>
ffffffffc02008d4:	fe6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008d8:	8522                	mv	a0,s0
ffffffffc02008da:	c1bff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02008de:	84aa                	mv	s1,a0
ffffffffc02008e0:	d15d                	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008e2:	8522                	mv	a0,s0
ffffffffc02008e4:	e6bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02008e8:	86a6                	mv	a3,s1
ffffffffc02008ea:	00004617          	auipc	a2,0x4
ffffffffc02008ee:	36660613          	addi	a2,a2,870 # ffffffffc0204c50 <commands+0x5b0>
ffffffffc02008f2:	0ca00593          	li	a1,202
ffffffffc02008f6:	00004517          	auipc	a0,0x4
ffffffffc02008fa:	e4a50513          	addi	a0,a0,-438 # ffffffffc0204740 <commands+0xa0>
ffffffffc02008fe:	805ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	36e50513          	addi	a0,a0,878 # ffffffffc0204c70 <commands+0x5d0>
ffffffffc020090a:	b779                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc020090c:	00004517          	auipc	a0,0x4
ffffffffc0200910:	37c50513          	addi	a0,a0,892 # ffffffffc0204c88 <commands+0x5e8>
ffffffffc0200914:	fa6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200918:	8522                	mv	a0,s0
ffffffffc020091a:	bdbff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc020091e:	84aa                	mv	s1,a0
ffffffffc0200920:	d13d                	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200922:	8522                	mv	a0,s0
ffffffffc0200924:	e2bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200928:	86a6                	mv	a3,s1
ffffffffc020092a:	00004617          	auipc	a2,0x4
ffffffffc020092e:	32660613          	addi	a2,a2,806 # ffffffffc0204c50 <commands+0x5b0>
ffffffffc0200932:	0d400593          	li	a1,212
ffffffffc0200936:	00004517          	auipc	a0,0x4
ffffffffc020093a:	e0a50513          	addi	a0,a0,-502 # ffffffffc0204740 <commands+0xa0>
ffffffffc020093e:	fc4ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	35e50513          	addi	a0,a0,862 # ffffffffc0204ca0 <commands+0x600>
ffffffffc020094a:	b7b9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc020094c:	00004517          	auipc	a0,0x4
ffffffffc0200950:	37450513          	addi	a0,a0,884 # ffffffffc0204cc0 <commands+0x620>
ffffffffc0200954:	b791                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200956:	00004517          	auipc	a0,0x4
ffffffffc020095a:	38a50513          	addi	a0,a0,906 # ffffffffc0204ce0 <commands+0x640>
ffffffffc020095e:	bf2d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200960:	00004517          	auipc	a0,0x4
ffffffffc0200964:	3a050513          	addi	a0,a0,928 # ffffffffc0204d00 <commands+0x660>
ffffffffc0200968:	bf05                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	3b650513          	addi	a0,a0,950 # ffffffffc0204d20 <commands+0x680>
ffffffffc0200972:	b71d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	3c450513          	addi	a0,a0,964 # ffffffffc0204d38 <commands+0x698>
ffffffffc020097c:	f3eff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200980:	8522                	mv	a0,s0
ffffffffc0200982:	b73ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200986:	84aa                	mv	s1,a0
ffffffffc0200988:	ee050fe3          	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020098c:	8522                	mv	a0,s0
ffffffffc020098e:	dc1ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200992:	86a6                	mv	a3,s1
ffffffffc0200994:	00004617          	auipc	a2,0x4
ffffffffc0200998:	2bc60613          	addi	a2,a2,700 # ffffffffc0204c50 <commands+0x5b0>
ffffffffc020099c:	0ea00593          	li	a1,234
ffffffffc02009a0:	00004517          	auipc	a0,0x4
ffffffffc02009a4:	da050513          	addi	a0,a0,-608 # ffffffffc0204740 <commands+0xa0>
ffffffffc02009a8:	f5aff0ef          	jal	ra,ffffffffc0200102 <__panic>
            print_trapframe(tf);
ffffffffc02009ac:	8522                	mv	a0,s0
}
ffffffffc02009ae:	6442                	ld	s0,16(sp)
ffffffffc02009b0:	60e2                	ld	ra,24(sp)
ffffffffc02009b2:	64a2                	ld	s1,8(sp)
ffffffffc02009b4:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009b6:	bb61                	j	ffffffffc020074e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009b8:	8522                	mv	a0,s0
ffffffffc02009ba:	d95ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009be:	86a6                	mv	a3,s1
ffffffffc02009c0:	00004617          	auipc	a2,0x4
ffffffffc02009c4:	29060613          	addi	a2,a2,656 # ffffffffc0204c50 <commands+0x5b0>
ffffffffc02009c8:	0f100593          	li	a1,241
ffffffffc02009cc:	00004517          	auipc	a0,0x4
ffffffffc02009d0:	d7450513          	addi	a0,a0,-652 # ffffffffc0204740 <commands+0xa0>
ffffffffc02009d4:	f2eff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02009d8 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009d8:	11853783          	ld	a5,280(a0)
ffffffffc02009dc:	0007c363          	bltz	a5,ffffffffc02009e2 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009e0:	b5a5                	j	ffffffffc0200848 <exception_handler>
        interrupt_handler(tf);
ffffffffc02009e2:	b3f9                	j	ffffffffc02007b0 <interrupt_handler>
	...

ffffffffc02009f0 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc02009f0:	14011073          	csrw	sscratch,sp
ffffffffc02009f4:	712d                	addi	sp,sp,-288
ffffffffc02009f6:	e406                	sd	ra,8(sp)
ffffffffc02009f8:	ec0e                	sd	gp,24(sp)
ffffffffc02009fa:	f012                	sd	tp,32(sp)
ffffffffc02009fc:	f416                	sd	t0,40(sp)
ffffffffc02009fe:	f81a                	sd	t1,48(sp)
ffffffffc0200a00:	fc1e                	sd	t2,56(sp)
ffffffffc0200a02:	e0a2                	sd	s0,64(sp)
ffffffffc0200a04:	e4a6                	sd	s1,72(sp)
ffffffffc0200a06:	e8aa                	sd	a0,80(sp)
ffffffffc0200a08:	ecae                	sd	a1,88(sp)
ffffffffc0200a0a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a0c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a0e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a10:	fcbe                	sd	a5,120(sp)
ffffffffc0200a12:	e142                	sd	a6,128(sp)
ffffffffc0200a14:	e546                	sd	a7,136(sp)
ffffffffc0200a16:	e94a                	sd	s2,144(sp)
ffffffffc0200a18:	ed4e                	sd	s3,152(sp)
ffffffffc0200a1a:	f152                	sd	s4,160(sp)
ffffffffc0200a1c:	f556                	sd	s5,168(sp)
ffffffffc0200a1e:	f95a                	sd	s6,176(sp)
ffffffffc0200a20:	fd5e                	sd	s7,184(sp)
ffffffffc0200a22:	e1e2                	sd	s8,192(sp)
ffffffffc0200a24:	e5e6                	sd	s9,200(sp)
ffffffffc0200a26:	e9ea                	sd	s10,208(sp)
ffffffffc0200a28:	edee                	sd	s11,216(sp)
ffffffffc0200a2a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a2c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a2e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a30:	fdfe                	sd	t6,248(sp)
ffffffffc0200a32:	14002473          	csrr	s0,sscratch
ffffffffc0200a36:	100024f3          	csrr	s1,sstatus
ffffffffc0200a3a:	14102973          	csrr	s2,sepc
ffffffffc0200a3e:	143029f3          	csrr	s3,stval
ffffffffc0200a42:	14202a73          	csrr	s4,scause
ffffffffc0200a46:	e822                	sd	s0,16(sp)
ffffffffc0200a48:	e226                	sd	s1,256(sp)
ffffffffc0200a4a:	e64a                	sd	s2,264(sp)
ffffffffc0200a4c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a4e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a50:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a52:	f87ff0ef          	jal	ra,ffffffffc02009d8 <trap>

ffffffffc0200a56 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a56:	6492                	ld	s1,256(sp)
ffffffffc0200a58:	6932                	ld	s2,264(sp)
ffffffffc0200a5a:	10049073          	csrw	sstatus,s1
ffffffffc0200a5e:	14191073          	csrw	sepc,s2
ffffffffc0200a62:	60a2                	ld	ra,8(sp)
ffffffffc0200a64:	61e2                	ld	gp,24(sp)
ffffffffc0200a66:	7202                	ld	tp,32(sp)
ffffffffc0200a68:	72a2                	ld	t0,40(sp)
ffffffffc0200a6a:	7342                	ld	t1,48(sp)
ffffffffc0200a6c:	73e2                	ld	t2,56(sp)
ffffffffc0200a6e:	6406                	ld	s0,64(sp)
ffffffffc0200a70:	64a6                	ld	s1,72(sp)
ffffffffc0200a72:	6546                	ld	a0,80(sp)
ffffffffc0200a74:	65e6                	ld	a1,88(sp)
ffffffffc0200a76:	7606                	ld	a2,96(sp)
ffffffffc0200a78:	76a6                	ld	a3,104(sp)
ffffffffc0200a7a:	7746                	ld	a4,112(sp)
ffffffffc0200a7c:	77e6                	ld	a5,120(sp)
ffffffffc0200a7e:	680a                	ld	a6,128(sp)
ffffffffc0200a80:	68aa                	ld	a7,136(sp)
ffffffffc0200a82:	694a                	ld	s2,144(sp)
ffffffffc0200a84:	69ea                	ld	s3,152(sp)
ffffffffc0200a86:	7a0a                	ld	s4,160(sp)
ffffffffc0200a88:	7aaa                	ld	s5,168(sp)
ffffffffc0200a8a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a8c:	7bea                	ld	s7,184(sp)
ffffffffc0200a8e:	6c0e                	ld	s8,192(sp)
ffffffffc0200a90:	6cae                	ld	s9,200(sp)
ffffffffc0200a92:	6d4e                	ld	s10,208(sp)
ffffffffc0200a94:	6dee                	ld	s11,216(sp)
ffffffffc0200a96:	7e0e                	ld	t3,224(sp)
ffffffffc0200a98:	7eae                	ld	t4,232(sp)
ffffffffc0200a9a:	7f4e                	ld	t5,240(sp)
ffffffffc0200a9c:	7fee                	ld	t6,248(sp)
ffffffffc0200a9e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200aa0:	10200073          	sret
	...

ffffffffc0200ab0 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200ab0:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200ab2:	00004697          	auipc	a3,0x4
ffffffffc0200ab6:	2f668693          	addi	a3,a3,758 # ffffffffc0204da8 <commands+0x708>
ffffffffc0200aba:	00004617          	auipc	a2,0x4
ffffffffc0200abe:	30e60613          	addi	a2,a2,782 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0200ac2:	08300593          	li	a1,131
ffffffffc0200ac6:	00004517          	auipc	a0,0x4
ffffffffc0200aca:	31a50513          	addi	a0,a0,794 # ffffffffc0204de0 <commands+0x740>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200ace:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200ad0:	e32ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200ad4 <mm_create>:
mm_create(void) {
ffffffffc0200ad4:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200ad6:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0200ada:	e022                	sd	s0,0(sp)
ffffffffc0200adc:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200ade:	0f0030ef          	jal	ra,ffffffffc0203bce <kmalloc>
ffffffffc0200ae2:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200ae4:	c105                	beqz	a0,ffffffffc0200b04 <mm_create+0x30>
 * 参数:
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ae6:	e408                	sd	a0,8(s0)
ffffffffc0200ae8:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200aea:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200aee:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200af2:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200af6:	00011797          	auipc	a5,0x11
ffffffffc0200afa:	a3a7a783          	lw	a5,-1478(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc0200afe:	eb81                	bnez	a5,ffffffffc0200b0e <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc0200b00:	02053423          	sd	zero,40(a0)
}
ffffffffc0200b04:	60a2                	ld	ra,8(sp)
ffffffffc0200b06:	8522                	mv	a0,s0
ffffffffc0200b08:	6402                	ld	s0,0(sp)
ffffffffc0200b0a:	0141                	addi	sp,sp,16
ffffffffc0200b0c:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200b0e:	693000ef          	jal	ra,ffffffffc02019a0 <swap_init_mm>
}
ffffffffc0200b12:	60a2                	ld	ra,8(sp)
ffffffffc0200b14:	8522                	mv	a0,s0
ffffffffc0200b16:	6402                	ld	s0,0(sp)
ffffffffc0200b18:	0141                	addi	sp,sp,16
ffffffffc0200b1a:	8082                	ret

ffffffffc0200b1c <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0200b1c:	1101                	addi	sp,sp,-32
ffffffffc0200b1e:	e04a                	sd	s2,0(sp)
ffffffffc0200b20:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200b22:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0200b26:	e822                	sd	s0,16(sp)
ffffffffc0200b28:	e426                	sd	s1,8(sp)
ffffffffc0200b2a:	ec06                	sd	ra,24(sp)
ffffffffc0200b2c:	84ae                	mv	s1,a1
ffffffffc0200b2e:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200b30:	09e030ef          	jal	ra,ffffffffc0203bce <kmalloc>
    if (vma != NULL) {
ffffffffc0200b34:	c509                	beqz	a0,ffffffffc0200b3e <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200b36:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200b3a:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200b3c:	ed00                	sd	s0,24(a0)
}
ffffffffc0200b3e:	60e2                	ld	ra,24(sp)
ffffffffc0200b40:	6442                	ld	s0,16(sp)
ffffffffc0200b42:	64a2                	ld	s1,8(sp)
ffffffffc0200b44:	6902                	ld	s2,0(sp)
ffffffffc0200b46:	6105                	addi	sp,sp,32
ffffffffc0200b48:	8082                	ret

ffffffffc0200b4a <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0200b4a:	86aa                	mv	a3,a0
    if (mm != NULL) 
ffffffffc0200b4c:	c505                	beqz	a0,ffffffffc0200b74 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0200b4e:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) // 如果不是<缓存非空且地址区间正确>
ffffffffc0200b50:	c501                	beqz	a0,ffffffffc0200b58 <find_vma+0xe>
ffffffffc0200b52:	651c                	ld	a5,8(a0)
ffffffffc0200b54:	02f5f263          	bgeu	a1,a5,ffffffffc0200b78 <find_vma+0x2e>
 * 参数: 
 * @listelm:    当前节点(链表头)
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b58:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0200b5a:	00f68d63          	beq	a3,a5,ffffffffc0200b74 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200b5e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200b62:	00e5e663          	bltu	a1,a4,ffffffffc0200b6e <find_vma+0x24>
ffffffffc0200b66:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200b6a:	00e5ec63          	bltu	a1,a4,ffffffffc0200b82 <find_vma+0x38>
ffffffffc0200b6e:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200b70:	fef697e3          	bne	a3,a5,ffffffffc0200b5e <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0200b74:	4501                	li	a0,0
}
ffffffffc0200b76:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) // 如果不是<缓存非空且地址区间正确>
ffffffffc0200b78:	691c                	ld	a5,16(a0)
ffffffffc0200b7a:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0200b58 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0200b7e:	ea88                	sd	a0,16(a3)
ffffffffc0200b80:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0200b82:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0200b86:	ea88                	sd	a0,16(a3)
ffffffffc0200b88:	8082                	ret

ffffffffc0200b8a <insert_vma_struct>:


// insert_vma_struct -将vma插入mm的链表
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200b8a:	6590                	ld	a2,8(a1)
ffffffffc0200b8c:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200b90:	1141                	addi	sp,sp,-16
ffffffffc0200b92:	e406                	sd	ra,8(sp)
ffffffffc0200b94:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200b96:	01066763          	bltu	a2,a6,ffffffffc0200ba4 <insert_vma_struct+0x1a>
ffffffffc0200b9a:	a085                	j	ffffffffc0200bfa <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200b9c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200ba0:	04e66863          	bltu	a2,a4,ffffffffc0200bf0 <insert_vma_struct+0x66>
ffffffffc0200ba4:	86be                	mv	a3,a5
ffffffffc0200ba6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0200ba8:	fef51ae3          	bne	a0,a5,ffffffffc0200b9c <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200bac:	02a68463          	beq	a3,a0,ffffffffc0200bd4 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200bb0:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200bb4:	fe86b883          	ld	a7,-24(a3)
ffffffffc0200bb8:	08e8f163          	bgeu	a7,a4,ffffffffc0200c3a <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200bbc:	04e66f63          	bltu	a2,a4,ffffffffc0200c1a <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0200bc0:	00f50a63          	beq	a0,a5,ffffffffc0200bd4 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200bc4:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200bc8:	05076963          	bltu	a4,a6,ffffffffc0200c1a <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0200bcc:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200bd0:	02c77363          	bgeu	a4,a2,ffffffffc0200bf6 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200bd4:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0200bd6:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200bd8:	02058613          	addi	a2,a1,32
 * 功能:在两个已知的连续节点之间插入一个新节点。
 * 注意:这仅用于内部列表操作，我们已经知道上一个/下一个节点了！
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200bdc:	e390                	sd	a2,0(a5)
ffffffffc0200bde:	e690                	sd	a2,8(a3)
}
ffffffffc0200be0:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200be2:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200be4:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0200be6:	0017079b          	addiw	a5,a4,1
ffffffffc0200bea:	d11c                	sw	a5,32(a0)
}
ffffffffc0200bec:	0141                	addi	sp,sp,16
ffffffffc0200bee:	8082                	ret
    if (le_prev != list) {
ffffffffc0200bf0:	fca690e3          	bne	a3,a0,ffffffffc0200bb0 <insert_vma_struct+0x26>
ffffffffc0200bf4:	bfd1                	j	ffffffffc0200bc8 <insert_vma_struct+0x3e>
ffffffffc0200bf6:	ebbff0ef          	jal	ra,ffffffffc0200ab0 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200bfa:	00004697          	auipc	a3,0x4
ffffffffc0200bfe:	1f668693          	addi	a3,a3,502 # ffffffffc0204df0 <commands+0x750>
ffffffffc0200c02:	00004617          	auipc	a2,0x4
ffffffffc0200c06:	1c660613          	addi	a2,a2,454 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0200c0a:	08a00593          	li	a1,138
ffffffffc0200c0e:	00004517          	auipc	a0,0x4
ffffffffc0200c12:	1d250513          	addi	a0,a0,466 # ffffffffc0204de0 <commands+0x740>
ffffffffc0200c16:	cecff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200c1a:	00004697          	auipc	a3,0x4
ffffffffc0200c1e:	21668693          	addi	a3,a3,534 # ffffffffc0204e30 <commands+0x790>
ffffffffc0200c22:	00004617          	auipc	a2,0x4
ffffffffc0200c26:	1a660613          	addi	a2,a2,422 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0200c2a:	08200593          	li	a1,130
ffffffffc0200c2e:	00004517          	auipc	a0,0x4
ffffffffc0200c32:	1b250513          	addi	a0,a0,434 # ffffffffc0204de0 <commands+0x740>
ffffffffc0200c36:	cccff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200c3a:	00004697          	auipc	a3,0x4
ffffffffc0200c3e:	1d668693          	addi	a3,a3,470 # ffffffffc0204e10 <commands+0x770>
ffffffffc0200c42:	00004617          	auipc	a2,0x4
ffffffffc0200c46:	18660613          	addi	a2,a2,390 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0200c4a:	08100593          	li	a1,129
ffffffffc0200c4e:	00004517          	auipc	a0,0x4
ffffffffc0200c52:	19250513          	addi	a0,a0,402 # ffffffffc0204de0 <commands+0x740>
ffffffffc0200c56:	cacff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200c5a <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0200c5a:	1141                	addi	sp,sp,-16
ffffffffc0200c5c:	e022                	sd	s0,0(sp)
ffffffffc0200c5e:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200c60:	6508                	ld	a0,8(a0)
ffffffffc0200c62:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200c64:	00a40e63          	beq	s0,a0,ffffffffc0200c80 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c68:	6118                	ld	a4,0(a0)
ffffffffc0200c6a:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200c6c:	03000593          	li	a1,48
ffffffffc0200c70:	1501                	addi	a0,a0,-32
 * 功能:通过使上一个和下一个节点相互连接(指向)来删除链表节点。
 * 注意:这仅用于内部列表操作，我们已经知道上一个/下一个节点了！
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200c72:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200c74:	e398                	sd	a4,0(a5)
ffffffffc0200c76:	012030ef          	jal	ra,ffffffffc0203c88 <kfree>
    return listelm->next;
ffffffffc0200c7a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200c7c:	fea416e3          	bne	s0,a0,ffffffffc0200c68 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200c80:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0200c82:	6402                	ld	s0,0(sp)
ffffffffc0200c84:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200c86:	03000593          	li	a1,48
}
ffffffffc0200c8a:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200c8c:	7fd0206f          	j	ffffffffc0203c88 <kfree>

ffffffffc0200c90 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0200c90:	715d                	addi	sp,sp,-80
ffffffffc0200c92:	e486                	sd	ra,72(sp)
ffffffffc0200c94:	f44e                	sd	s3,40(sp)
ffffffffc0200c96:	f052                	sd	s4,32(sp)
ffffffffc0200c98:	e0a2                	sd	s0,64(sp)
ffffffffc0200c9a:	fc26                	sd	s1,56(sp)
ffffffffc0200c9c:	f84a                	sd	s2,48(sp)
ffffffffc0200c9e:	ec56                	sd	s5,24(sp)
ffffffffc0200ca0:	e85a                	sd	s6,16(sp)
ffffffffc0200ca2:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200ca4:	645010ef          	jal	ra,ffffffffc0202ae8 <nr_free_pages>
ffffffffc0200ca8:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200caa:	63f010ef          	jal	ra,ffffffffc0202ae8 <nr_free_pages>
ffffffffc0200cae:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200cb0:	03000513          	li	a0,48
ffffffffc0200cb4:	71b020ef          	jal	ra,ffffffffc0203bce <kmalloc>
    if (mm != NULL) {
ffffffffc0200cb8:	56050863          	beqz	a0,ffffffffc0201228 <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc0200cbc:	e508                	sd	a0,8(a0)
ffffffffc0200cbe:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200cc0:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200cc4:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200cc8:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200ccc:	00011797          	auipc	a5,0x11
ffffffffc0200cd0:	8647a783          	lw	a5,-1948(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc0200cd4:	84aa                	mv	s1,a0
ffffffffc0200cd6:	e7b9                	bnez	a5,ffffffffc0200d24 <vmm_init+0x94>
        else mm->sm_priv = NULL;
ffffffffc0200cd8:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc0200cdc:	03200413          	li	s0,50
ffffffffc0200ce0:	a811                	j	ffffffffc0200cf4 <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc0200ce2:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200ce4:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200ce6:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0200cea:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200cec:	8526                	mv	a0,s1
ffffffffc0200cee:	e9dff0ef          	jal	ra,ffffffffc0200b8a <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0200cf2:	cc05                	beqz	s0,ffffffffc0200d2a <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200cf4:	03000513          	li	a0,48
ffffffffc0200cf8:	6d7020ef          	jal	ra,ffffffffc0203bce <kmalloc>
ffffffffc0200cfc:	85aa                	mv	a1,a0
ffffffffc0200cfe:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200d02:	f165                	bnez	a0,ffffffffc0200ce2 <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc0200d04:	00004697          	auipc	a3,0x4
ffffffffc0200d08:	37c68693          	addi	a3,a3,892 # ffffffffc0205080 <commands+0x9e0>
ffffffffc0200d0c:	00004617          	auipc	a2,0x4
ffffffffc0200d10:	0bc60613          	addi	a2,a2,188 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0200d14:	0d400593          	li	a1,212
ffffffffc0200d18:	00004517          	auipc	a0,0x4
ffffffffc0200d1c:	0c850513          	addi	a0,a0,200 # ffffffffc0204de0 <commands+0x740>
ffffffffc0200d20:	be2ff0ef          	jal	ra,ffffffffc0200102 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200d24:	47d000ef          	jal	ra,ffffffffc02019a0 <swap_init_mm>
ffffffffc0200d28:	bf55                	j	ffffffffc0200cdc <vmm_init+0x4c>
ffffffffc0200d2a:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d2e:	1f900913          	li	s2,505
ffffffffc0200d32:	a819                	j	ffffffffc0200d48 <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc0200d34:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200d36:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200d38:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d3c:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200d3e:	8526                	mv	a0,s1
ffffffffc0200d40:	e4bff0ef          	jal	ra,ffffffffc0200b8a <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d44:	03240a63          	beq	s0,s2,ffffffffc0200d78 <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200d48:	03000513          	li	a0,48
ffffffffc0200d4c:	683020ef          	jal	ra,ffffffffc0203bce <kmalloc>
ffffffffc0200d50:	85aa                	mv	a1,a0
ffffffffc0200d52:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200d56:	fd79                	bnez	a0,ffffffffc0200d34 <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc0200d58:	00004697          	auipc	a3,0x4
ffffffffc0200d5c:	32868693          	addi	a3,a3,808 # ffffffffc0205080 <commands+0x9e0>
ffffffffc0200d60:	00004617          	auipc	a2,0x4
ffffffffc0200d64:	06860613          	addi	a2,a2,104 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0200d68:	0da00593          	li	a1,218
ffffffffc0200d6c:	00004517          	auipc	a0,0x4
ffffffffc0200d70:	07450513          	addi	a0,a0,116 # ffffffffc0204de0 <commands+0x740>
ffffffffc0200d74:	b8eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    return listelm->next;
ffffffffc0200d78:	649c                	ld	a5,8(s1)
ffffffffc0200d7a:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0200d7c:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0200d80:	2ef48463          	beq	s1,a5,ffffffffc0201068 <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0200d84:	fe87b603          	ld	a2,-24(a5)
ffffffffc0200d88:	ffe70693          	addi	a3,a4,-2
ffffffffc0200d8c:	26d61e63          	bne	a2,a3,ffffffffc0201008 <vmm_init+0x378>
ffffffffc0200d90:	ff07b683          	ld	a3,-16(a5)
ffffffffc0200d94:	26e69a63          	bne	a3,a4,ffffffffc0201008 <vmm_init+0x378>
    for (i = 1; i <= step2; i ++) {
ffffffffc0200d98:	0715                	addi	a4,a4,5
ffffffffc0200d9a:	679c                	ld	a5,8(a5)
ffffffffc0200d9c:	feb712e3          	bne	a4,a1,ffffffffc0200d80 <vmm_init+0xf0>
ffffffffc0200da0:	4b1d                	li	s6,7
ffffffffc0200da2:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200da4:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0200da8:	85a2                	mv	a1,s0
ffffffffc0200daa:	8526                	mv	a0,s1
ffffffffc0200dac:	d9fff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
ffffffffc0200db0:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0200db2:	2c050b63          	beqz	a0,ffffffffc0201088 <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0200db6:	00140593          	addi	a1,s0,1
ffffffffc0200dba:	8526                	mv	a0,s1
ffffffffc0200dbc:	d8fff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
ffffffffc0200dc0:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0200dc2:	2e050363          	beqz	a0,ffffffffc02010a8 <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0200dc6:	85da                	mv	a1,s6
ffffffffc0200dc8:	8526                	mv	a0,s1
ffffffffc0200dca:	d81ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
        assert(vma3 == NULL);
ffffffffc0200dce:	2e051d63          	bnez	a0,ffffffffc02010c8 <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0200dd2:	00340593          	addi	a1,s0,3
ffffffffc0200dd6:	8526                	mv	a0,s1
ffffffffc0200dd8:	d73ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
        assert(vma4 == NULL);
ffffffffc0200ddc:	30051663          	bnez	a0,ffffffffc02010e8 <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0200de0:	00440593          	addi	a1,s0,4
ffffffffc0200de4:	8526                	mv	a0,s1
ffffffffc0200de6:	d65ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
        assert(vma5 == NULL);
ffffffffc0200dea:	30051f63          	bnez	a0,ffffffffc0201108 <vmm_init+0x478>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0200dee:	00893783          	ld	a5,8(s2)
ffffffffc0200df2:	24879b63          	bne	a5,s0,ffffffffc0201048 <vmm_init+0x3b8>
ffffffffc0200df6:	01093783          	ld	a5,16(s2)
ffffffffc0200dfa:	25679763          	bne	a5,s6,ffffffffc0201048 <vmm_init+0x3b8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0200dfe:	008ab783          	ld	a5,8(s5)
ffffffffc0200e02:	22879363          	bne	a5,s0,ffffffffc0201028 <vmm_init+0x398>
ffffffffc0200e06:	010ab783          	ld	a5,16(s5)
ffffffffc0200e0a:	21679f63          	bne	a5,s6,ffffffffc0201028 <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200e0e:	0415                	addi	s0,s0,5
ffffffffc0200e10:	0b15                	addi	s6,s6,5
ffffffffc0200e12:	f9741be3          	bne	s0,s7,ffffffffc0200da8 <vmm_init+0x118>
ffffffffc0200e16:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0200e18:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0200e1a:	85a2                	mv	a1,s0
ffffffffc0200e1c:	8526                	mv	a0,s1
ffffffffc0200e1e:	d2dff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
ffffffffc0200e22:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0200e26:	c90d                	beqz	a0,ffffffffc0200e58 <vmm_init+0x1c8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0200e28:	6914                	ld	a3,16(a0)
ffffffffc0200e2a:	6510                	ld	a2,8(a0)
ffffffffc0200e2c:	00004517          	auipc	a0,0x4
ffffffffc0200e30:	12450513          	addi	a0,a0,292 # ffffffffc0204f50 <commands+0x8b0>
ffffffffc0200e34:	a86ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0200e38:	00004697          	auipc	a3,0x4
ffffffffc0200e3c:	14068693          	addi	a3,a3,320 # ffffffffc0204f78 <commands+0x8d8>
ffffffffc0200e40:	00004617          	auipc	a2,0x4
ffffffffc0200e44:	f8860613          	addi	a2,a2,-120 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0200e48:	0fc00593          	li	a1,252
ffffffffc0200e4c:	00004517          	auipc	a0,0x4
ffffffffc0200e50:	f9450513          	addi	a0,a0,-108 # ffffffffc0204de0 <commands+0x740>
ffffffffc0200e54:	aaeff0ef          	jal	ra,ffffffffc0200102 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0200e58:	147d                	addi	s0,s0,-1
ffffffffc0200e5a:	fd2410e3          	bne	s0,s2,ffffffffc0200e1a <vmm_init+0x18a>
ffffffffc0200e5e:	a811                	j	ffffffffc0200e72 <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200e60:	6118                	ld	a4,0(a0)
ffffffffc0200e62:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200e64:	03000593          	li	a1,48
ffffffffc0200e68:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0200e6a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200e6c:	e398                	sd	a4,0(a5)
ffffffffc0200e6e:	61b020ef          	jal	ra,ffffffffc0203c88 <kfree>
    return listelm->next;
ffffffffc0200e72:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0200e74:	fea496e3          	bne	s1,a0,ffffffffc0200e60 <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200e78:	03000593          	li	a1,48
ffffffffc0200e7c:	8526                	mv	a0,s1
ffffffffc0200e7e:	60b020ef          	jal	ra,ffffffffc0203c88 <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200e82:	467010ef          	jal	ra,ffffffffc0202ae8 <nr_free_pages>
ffffffffc0200e86:	3caa1163          	bne	s4,a0,ffffffffc0201248 <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0200e8a:	00004517          	auipc	a0,0x4
ffffffffc0200e8e:	12e50513          	addi	a0,a0,302 # ffffffffc0204fb8 <commands+0x918>
ffffffffc0200e92:	a28ff0ef          	jal	ra,ffffffffc02000ba <cprintf>

// check_pgfault - 检查pgfault处理程序的正确性(check correctness of pgfault handler)
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200e96:	453010ef          	jal	ra,ffffffffc0202ae8 <nr_free_pages>
ffffffffc0200e9a:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e9c:	03000513          	li	a0,48
ffffffffc0200ea0:	52f020ef          	jal	ra,ffffffffc0203bce <kmalloc>
ffffffffc0200ea4:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200ea6:	2a050163          	beqz	a0,ffffffffc0201148 <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200eaa:	00010797          	auipc	a5,0x10
ffffffffc0200eae:	6867a783          	lw	a5,1670(a5) # ffffffffc0211530 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0200eb2:	e508                	sd	a0,8(a0)
ffffffffc0200eb4:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200eb6:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200eba:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200ebe:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200ec2:	14079063          	bnez	a5,ffffffffc0201002 <vmm_init+0x372>
        else mm->sm_priv = NULL;
ffffffffc0200ec6:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200eca:	00010917          	auipc	s2,0x10
ffffffffc0200ece:	67e93903          	ld	s2,1662(s2) # ffffffffc0211548 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0200ed2:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0200ed6:	00010717          	auipc	a4,0x10
ffffffffc0200eda:	62873d23          	sd	s0,1594(a4) # ffffffffc0211510 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200ede:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0200ee2:	24079363          	bnez	a5,ffffffffc0201128 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200ee6:	03000513          	li	a0,48
ffffffffc0200eea:	4e5020ef          	jal	ra,ffffffffc0203bce <kmalloc>
ffffffffc0200eee:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0200ef0:	28050063          	beqz	a0,ffffffffc0201170 <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc0200ef4:	002007b7          	lui	a5,0x200
ffffffffc0200ef8:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0200efc:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0200efe:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0200f00:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0200f04:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0200f06:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0200f0a:	c81ff0ef          	jal	ra,ffffffffc0200b8a <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0200f0e:	10000593          	li	a1,256
ffffffffc0200f12:	8522                	mv	a0,s0
ffffffffc0200f14:	c37ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
ffffffffc0200f18:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0200f1c:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0200f20:	26aa1863          	bne	s4,a0,ffffffffc0201190 <vmm_init+0x500>
        *(char *)(addr + i) = i;
ffffffffc0200f24:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0200f28:	0785                	addi	a5,a5,1
ffffffffc0200f2a:	fee79de3          	bne	a5,a4,ffffffffc0200f24 <vmm_init+0x294>
        sum += i;
ffffffffc0200f2e:	6705                	lui	a4,0x1
ffffffffc0200f30:	10000793          	li	a5,256
ffffffffc0200f34:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0200f38:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0200f3c:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0200f40:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0200f42:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0200f44:	fec79ce3          	bne	a5,a2,ffffffffc0200f3c <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc0200f48:	26071463          	bnez	a4,ffffffffc02011b0 <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0200f4c:	4581                	li	a1,0
ffffffffc0200f4e:	854a                	mv	a0,s2
ffffffffc0200f50:	623010ef          	jal	ra,ffffffffc0202d72 <page_remove>
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f54:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0200f58:	00010717          	auipc	a4,0x10
ffffffffc0200f5c:	5f873703          	ld	a4,1528(a4) # ffffffffc0211550 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f60:	078a                	slli	a5,a5,0x2
ffffffffc0200f62:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f64:	26e7f663          	bgeu	a5,a4,ffffffffc02011d0 <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f68:	00005717          	auipc	a4,0x5
ffffffffc0200f6c:	2b073703          	ld	a4,688(a4) # ffffffffc0206218 <nbase>
ffffffffc0200f70:	8f99                	sub	a5,a5,a4
ffffffffc0200f72:	00379713          	slli	a4,a5,0x3
ffffffffc0200f76:	97ba                	add	a5,a5,a4
ffffffffc0200f78:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0200f7a:	00010517          	auipc	a0,0x10
ffffffffc0200f7e:	5de53503          	ld	a0,1502(a0) # ffffffffc0211558 <pages>
ffffffffc0200f82:	953e                	add	a0,a0,a5
ffffffffc0200f84:	4585                	li	a1,1
ffffffffc0200f86:	323010ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    return listelm->next;
ffffffffc0200f8a:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc0200f8c:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc0200f90:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200f94:	00a40e63          	beq	s0,a0,ffffffffc0200fb0 <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200f98:	6118                	ld	a4,0(a0)
ffffffffc0200f9a:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200f9c:	03000593          	li	a1,48
ffffffffc0200fa0:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0200fa2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200fa4:	e398                	sd	a4,0(a5)
ffffffffc0200fa6:	4e3020ef          	jal	ra,ffffffffc0203c88 <kfree>
    return listelm->next;
ffffffffc0200faa:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200fac:	fea416e3          	bne	s0,a0,ffffffffc0200f98 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200fb0:	03000593          	li	a1,48
ffffffffc0200fb4:	8522                	mv	a0,s0
ffffffffc0200fb6:	4d3020ef          	jal	ra,ffffffffc0203c88 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0200fba:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0200fbc:	00010797          	auipc	a5,0x10
ffffffffc0200fc0:	5407ba23          	sd	zero,1364(a5) # ffffffffc0211510 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200fc4:	325010ef          	jal	ra,ffffffffc0202ae8 <nr_free_pages>
ffffffffc0200fc8:	22a49063          	bne	s1,a0,ffffffffc02011e8 <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0200fcc:	00004517          	auipc	a0,0x4
ffffffffc0200fd0:	07c50513          	addi	a0,a0,124 # ffffffffc0205048 <commands+0x9a8>
ffffffffc0200fd4:	8e6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200fd8:	311010ef          	jal	ra,ffffffffc0202ae8 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0200fdc:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200fde:	22a99563          	bne	s3,a0,ffffffffc0201208 <vmm_init+0x578>
}
ffffffffc0200fe2:	6406                	ld	s0,64(sp)
ffffffffc0200fe4:	60a6                	ld	ra,72(sp)
ffffffffc0200fe6:	74e2                	ld	s1,56(sp)
ffffffffc0200fe8:	7942                	ld	s2,48(sp)
ffffffffc0200fea:	79a2                	ld	s3,40(sp)
ffffffffc0200fec:	7a02                	ld	s4,32(sp)
ffffffffc0200fee:	6ae2                	ld	s5,24(sp)
ffffffffc0200ff0:	6b42                	ld	s6,16(sp)
ffffffffc0200ff2:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0200ff4:	00004517          	auipc	a0,0x4
ffffffffc0200ff8:	07450513          	addi	a0,a0,116 # ffffffffc0205068 <commands+0x9c8>
}
ffffffffc0200ffc:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0200ffe:	8bcff06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201002:	19f000ef          	jal	ra,ffffffffc02019a0 <swap_init_mm>
ffffffffc0201006:	b5d1                	j	ffffffffc0200eca <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201008:	00004697          	auipc	a3,0x4
ffffffffc020100c:	e6068693          	addi	a3,a3,-416 # ffffffffc0204e68 <commands+0x7c8>
ffffffffc0201010:	00004617          	auipc	a2,0x4
ffffffffc0201014:	db860613          	addi	a2,a2,-584 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201018:	0e300593          	li	a1,227
ffffffffc020101c:	00004517          	auipc	a0,0x4
ffffffffc0201020:	dc450513          	addi	a0,a0,-572 # ffffffffc0204de0 <commands+0x740>
ffffffffc0201024:	8deff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201028:	00004697          	auipc	a3,0x4
ffffffffc020102c:	ef868693          	addi	a3,a3,-264 # ffffffffc0204f20 <commands+0x880>
ffffffffc0201030:	00004617          	auipc	a2,0x4
ffffffffc0201034:	d9860613          	addi	a2,a2,-616 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201038:	0f400593          	li	a1,244
ffffffffc020103c:	00004517          	auipc	a0,0x4
ffffffffc0201040:	da450513          	addi	a0,a0,-604 # ffffffffc0204de0 <commands+0x740>
ffffffffc0201044:	8beff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201048:	00004697          	auipc	a3,0x4
ffffffffc020104c:	ea868693          	addi	a3,a3,-344 # ffffffffc0204ef0 <commands+0x850>
ffffffffc0201050:	00004617          	auipc	a2,0x4
ffffffffc0201054:	d7860613          	addi	a2,a2,-648 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201058:	0f300593          	li	a1,243
ffffffffc020105c:	00004517          	auipc	a0,0x4
ffffffffc0201060:	d8450513          	addi	a0,a0,-636 # ffffffffc0204de0 <commands+0x740>
ffffffffc0201064:	89eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201068:	00004697          	auipc	a3,0x4
ffffffffc020106c:	de868693          	addi	a3,a3,-536 # ffffffffc0204e50 <commands+0x7b0>
ffffffffc0201070:	00004617          	auipc	a2,0x4
ffffffffc0201074:	d5860613          	addi	a2,a2,-680 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201078:	0e100593          	li	a1,225
ffffffffc020107c:	00004517          	auipc	a0,0x4
ffffffffc0201080:	d6450513          	addi	a0,a0,-668 # ffffffffc0204de0 <commands+0x740>
ffffffffc0201084:	87eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1 != NULL);
ffffffffc0201088:	00004697          	auipc	a3,0x4
ffffffffc020108c:	e1868693          	addi	a3,a3,-488 # ffffffffc0204ea0 <commands+0x800>
ffffffffc0201090:	00004617          	auipc	a2,0x4
ffffffffc0201094:	d3860613          	addi	a2,a2,-712 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201098:	0e900593          	li	a1,233
ffffffffc020109c:	00004517          	auipc	a0,0x4
ffffffffc02010a0:	d4450513          	addi	a0,a0,-700 # ffffffffc0204de0 <commands+0x740>
ffffffffc02010a4:	85eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2 != NULL);
ffffffffc02010a8:	00004697          	auipc	a3,0x4
ffffffffc02010ac:	e0868693          	addi	a3,a3,-504 # ffffffffc0204eb0 <commands+0x810>
ffffffffc02010b0:	00004617          	auipc	a2,0x4
ffffffffc02010b4:	d1860613          	addi	a2,a2,-744 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02010b8:	0eb00593          	li	a1,235
ffffffffc02010bc:	00004517          	auipc	a0,0x4
ffffffffc02010c0:	d2450513          	addi	a0,a0,-732 # ffffffffc0204de0 <commands+0x740>
ffffffffc02010c4:	83eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma3 == NULL);
ffffffffc02010c8:	00004697          	auipc	a3,0x4
ffffffffc02010cc:	df868693          	addi	a3,a3,-520 # ffffffffc0204ec0 <commands+0x820>
ffffffffc02010d0:	00004617          	auipc	a2,0x4
ffffffffc02010d4:	cf860613          	addi	a2,a2,-776 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02010d8:	0ed00593          	li	a1,237
ffffffffc02010dc:	00004517          	auipc	a0,0x4
ffffffffc02010e0:	d0450513          	addi	a0,a0,-764 # ffffffffc0204de0 <commands+0x740>
ffffffffc02010e4:	81eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma4 == NULL);
ffffffffc02010e8:	00004697          	auipc	a3,0x4
ffffffffc02010ec:	de868693          	addi	a3,a3,-536 # ffffffffc0204ed0 <commands+0x830>
ffffffffc02010f0:	00004617          	auipc	a2,0x4
ffffffffc02010f4:	cd860613          	addi	a2,a2,-808 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02010f8:	0ef00593          	li	a1,239
ffffffffc02010fc:	00004517          	auipc	a0,0x4
ffffffffc0201100:	ce450513          	addi	a0,a0,-796 # ffffffffc0204de0 <commands+0x740>
ffffffffc0201104:	ffffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma5 == NULL);
ffffffffc0201108:	00004697          	auipc	a3,0x4
ffffffffc020110c:	dd868693          	addi	a3,a3,-552 # ffffffffc0204ee0 <commands+0x840>
ffffffffc0201110:	00004617          	auipc	a2,0x4
ffffffffc0201114:	cb860613          	addi	a2,a2,-840 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201118:	0f100593          	li	a1,241
ffffffffc020111c:	00004517          	auipc	a0,0x4
ffffffffc0201120:	cc450513          	addi	a0,a0,-828 # ffffffffc0204de0 <commands+0x740>
ffffffffc0201124:	fdffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0201128:	00004697          	auipc	a3,0x4
ffffffffc020112c:	eb068693          	addi	a3,a3,-336 # ffffffffc0204fd8 <commands+0x938>
ffffffffc0201130:	00004617          	auipc	a2,0x4
ffffffffc0201134:	c9860613          	addi	a2,a2,-872 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201138:	11300593          	li	a1,275
ffffffffc020113c:	00004517          	auipc	a0,0x4
ffffffffc0201140:	ca450513          	addi	a0,a0,-860 # ffffffffc0204de0 <commands+0x740>
ffffffffc0201144:	fbffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0201148:	00004697          	auipc	a3,0x4
ffffffffc020114c:	f4868693          	addi	a3,a3,-184 # ffffffffc0205090 <commands+0x9f0>
ffffffffc0201150:	00004617          	auipc	a2,0x4
ffffffffc0201154:	c7860613          	addi	a2,a2,-904 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201158:	11000593          	li	a1,272
ffffffffc020115c:	00004517          	auipc	a0,0x4
ffffffffc0201160:	c8450513          	addi	a0,a0,-892 # ffffffffc0204de0 <commands+0x740>
    check_mm_struct = mm_create();
ffffffffc0201164:	00010797          	auipc	a5,0x10
ffffffffc0201168:	3a07b623          	sd	zero,940(a5) # ffffffffc0211510 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc020116c:	f97fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(vma != NULL);
ffffffffc0201170:	00004697          	auipc	a3,0x4
ffffffffc0201174:	f1068693          	addi	a3,a3,-240 # ffffffffc0205080 <commands+0x9e0>
ffffffffc0201178:	00004617          	auipc	a2,0x4
ffffffffc020117c:	c5060613          	addi	a2,a2,-944 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201180:	11700593          	li	a1,279
ffffffffc0201184:	00004517          	auipc	a0,0x4
ffffffffc0201188:	c5c50513          	addi	a0,a0,-932 # ffffffffc0204de0 <commands+0x740>
ffffffffc020118c:	f77fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0201190:	00004697          	auipc	a3,0x4
ffffffffc0201194:	e5868693          	addi	a3,a3,-424 # ffffffffc0204fe8 <commands+0x948>
ffffffffc0201198:	00004617          	auipc	a2,0x4
ffffffffc020119c:	c3060613          	addi	a2,a2,-976 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02011a0:	11c00593          	li	a1,284
ffffffffc02011a4:	00004517          	auipc	a0,0x4
ffffffffc02011a8:	c3c50513          	addi	a0,a0,-964 # ffffffffc0204de0 <commands+0x740>
ffffffffc02011ac:	f57fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(sum == 0);
ffffffffc02011b0:	00004697          	auipc	a3,0x4
ffffffffc02011b4:	e5868693          	addi	a3,a3,-424 # ffffffffc0205008 <commands+0x968>
ffffffffc02011b8:	00004617          	auipc	a2,0x4
ffffffffc02011bc:	c1060613          	addi	a2,a2,-1008 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02011c0:	12600593          	li	a1,294
ffffffffc02011c4:	00004517          	auipc	a0,0x4
ffffffffc02011c8:	c1c50513          	addi	a0,a0,-996 # ffffffffc0204de0 <commands+0x740>
ffffffffc02011cc:	f37fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02011d0:	00004617          	auipc	a2,0x4
ffffffffc02011d4:	e4860613          	addi	a2,a2,-440 # ffffffffc0205018 <commands+0x978>
ffffffffc02011d8:	06700593          	li	a1,103
ffffffffc02011dc:	00004517          	auipc	a0,0x4
ffffffffc02011e0:	e5c50513          	addi	a0,a0,-420 # ffffffffc0205038 <commands+0x998>
ffffffffc02011e4:	f1ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02011e8:	00004697          	auipc	a3,0x4
ffffffffc02011ec:	da868693          	addi	a3,a3,-600 # ffffffffc0204f90 <commands+0x8f0>
ffffffffc02011f0:	00004617          	auipc	a2,0x4
ffffffffc02011f4:	bd860613          	addi	a2,a2,-1064 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02011f8:	13400593          	li	a1,308
ffffffffc02011fc:	00004517          	auipc	a0,0x4
ffffffffc0201200:	be450513          	addi	a0,a0,-1052 # ffffffffc0204de0 <commands+0x740>
ffffffffc0201204:	efffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201208:	00004697          	auipc	a3,0x4
ffffffffc020120c:	d8868693          	addi	a3,a3,-632 # ffffffffc0204f90 <commands+0x8f0>
ffffffffc0201210:	00004617          	auipc	a2,0x4
ffffffffc0201214:	bb860613          	addi	a2,a2,-1096 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201218:	0c300593          	li	a1,195
ffffffffc020121c:	00004517          	auipc	a0,0x4
ffffffffc0201220:	bc450513          	addi	a0,a0,-1084 # ffffffffc0204de0 <commands+0x740>
ffffffffc0201224:	edffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(mm != NULL);
ffffffffc0201228:	00004697          	auipc	a3,0x4
ffffffffc020122c:	e8068693          	addi	a3,a3,-384 # ffffffffc02050a8 <commands+0xa08>
ffffffffc0201230:	00004617          	auipc	a2,0x4
ffffffffc0201234:	b9860613          	addi	a2,a2,-1128 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201238:	0cd00593          	li	a1,205
ffffffffc020123c:	00004517          	auipc	a0,0x4
ffffffffc0201240:	ba450513          	addi	a0,a0,-1116 # ffffffffc0204de0 <commands+0x740>
ffffffffc0201244:	ebffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201248:	00004697          	auipc	a3,0x4
ffffffffc020124c:	d4868693          	addi	a3,a3,-696 # ffffffffc0204f90 <commands+0x8f0>
ffffffffc0201250:	00004617          	auipc	a2,0x4
ffffffffc0201254:	b7860613          	addi	a2,a2,-1160 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201258:	10100593          	li	a1,257
ffffffffc020125c:	00004517          	auipc	a0,0x4
ffffffffc0201260:	b8450513          	addi	a0,a0,-1148 # ffffffffc0204de0 <commands+0x740>
ffffffffc0201264:	e9ffe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201268 <do_pgfault>:
 *         -- W/R标志（第1位）指示导致异常的内存访问是读取（0）还是写入（1）。
 *         -- U/S标志（第2位）指示处理器在异常发生时是处于用户模式（1）还是管理模式（0）。
 */

int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201268:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020126a:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020126c:	f022                	sd	s0,32(sp)
ffffffffc020126e:	ec26                	sd	s1,24(sp)
ffffffffc0201270:	f406                	sd	ra,40(sp)
ffffffffc0201272:	e84a                	sd	s2,16(sp)
ffffffffc0201274:	8432                	mv	s0,a2
ffffffffc0201276:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0201278:	8d3ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>

    pgfault_num++;
ffffffffc020127c:	00010797          	auipc	a5,0x10
ffffffffc0201280:	29c7a783          	lw	a5,668(a5) # ffffffffc0211518 <pgfault_num>
ffffffffc0201284:	2785                	addiw	a5,a5,1
ffffffffc0201286:	00010717          	auipc	a4,0x10
ffffffffc020128a:	28f72923          	sw	a5,658(a4) # ffffffffc0211518 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc020128e:	c159                	beqz	a0,ffffffffc0201314 <do_pgfault+0xac>
ffffffffc0201290:	651c                	ld	a5,8(a0)
ffffffffc0201292:	08f46163          	bltu	s0,a5,ffffffffc0201314 <do_pgfault+0xac>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201296:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0201298:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020129a:	8b89                	andi	a5,a5,2
ffffffffc020129c:	ebb1                	bnez	a5,ffffffffc02012f0 <do_pgfault+0x88>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc020129e:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : 这些 vma 的页目录表
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02012a0:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02012a2:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02012a4:	85a2                	mv	a1,s0
ffffffffc02012a6:	4605                	li	a2,1
ffffffffc02012a8:	07b010ef          	jal	ra,ffffffffc0202b22 <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc02012ac:	610c                	ld	a1,0(a0)
ffffffffc02012ae:	c1b9                	beqz	a1,ffffffffc02012f4 <do_pgfault+0x8c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据页目录表(PTE)中的swap条目的addr，
        *                               找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) 
ffffffffc02012b0:	00010797          	auipc	a5,0x10
ffffffffc02012b4:	2807a783          	lw	a5,640(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc02012b8:	c7bd                	beqz	a5,ffffffffc0201326 <do_pgfault+0xbe>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）根据mm和addr，尝试将右侧磁盘页面的内容放入页面管理的内存中。
            //(2) 根据mm、addr和page，设置物理addr<--->虚拟(logical)addr的映射
            //(3) 使页面可交换。
            swap_in(mm, addr, &page);
ffffffffc02012ba:	85a2                	mv	a1,s0
ffffffffc02012bc:	0030                	addi	a2,sp,8
ffffffffc02012be:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02012c0:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc02012c2:	00b000ef          	jal	ra,ffffffffc0201acc <swap_in>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc02012c6:	65a2                	ld	a1,8(sp)
ffffffffc02012c8:	6c88                	ld	a0,24(s1)
ffffffffc02012ca:	86ca                	mv	a3,s2
ffffffffc02012cc:	8622                	mv	a2,s0
ffffffffc02012ce:	33f010ef          	jal	ra,ffffffffc0202e0c <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc02012d2:	6622                	ld	a2,8(sp)
ffffffffc02012d4:	4685                	li	a3,1
ffffffffc02012d6:	85a2                	mv	a1,s0
ffffffffc02012d8:	8526                	mv	a0,s1
ffffffffc02012da:	6d2000ef          	jal	ra,ffffffffc02019ac <swap_map_swappable>
            
            page->pra_vaddr = addr;  //必须等待前几条设置好权限才能写这行
ffffffffc02012de:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc02012e0:	4501                	li	a0,0
            page->pra_vaddr = addr;  //必须等待前几条设置好权限才能写这行
ffffffffc02012e2:	e3a0                	sd	s0,64(a5)
failed:
    return ret;
}
ffffffffc02012e4:	70a2                	ld	ra,40(sp)
ffffffffc02012e6:	7402                	ld	s0,32(sp)
ffffffffc02012e8:	64e2                	ld	s1,24(sp)
ffffffffc02012ea:	6942                	ld	s2,16(sp)
ffffffffc02012ec:	6145                	addi	sp,sp,48
ffffffffc02012ee:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc02012f0:	4959                	li	s2,22
ffffffffc02012f2:	b775                	j	ffffffffc020129e <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02012f4:	6c88                	ld	a0,24(s1)
ffffffffc02012f6:	864a                	mv	a2,s2
ffffffffc02012f8:	85a2                	mv	a1,s0
ffffffffc02012fa:	01d020ef          	jal	ra,ffffffffc0203b16 <pgdir_alloc_page>
ffffffffc02012fe:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0201300:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201302:	f3ed                	bnez	a5,ffffffffc02012e4 <do_pgfault+0x7c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0201304:	00004517          	auipc	a0,0x4
ffffffffc0201308:	de450513          	addi	a0,a0,-540 # ffffffffc02050e8 <commands+0xa48>
ffffffffc020130c:	daffe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201310:	5571                	li	a0,-4
            goto failed;
ffffffffc0201312:	bfc9                	j	ffffffffc02012e4 <do_pgfault+0x7c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0201314:	85a2                	mv	a1,s0
ffffffffc0201316:	00004517          	auipc	a0,0x4
ffffffffc020131a:	da250513          	addi	a0,a0,-606 # ffffffffc02050b8 <commands+0xa18>
ffffffffc020131e:	d9dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc0201322:	5575                	li	a0,-3
        goto failed;
ffffffffc0201324:	b7c1                	j	ffffffffc02012e4 <do_pgfault+0x7c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0201326:	00004517          	auipc	a0,0x4
ffffffffc020132a:	dea50513          	addi	a0,a0,-534 # ffffffffc0205110 <commands+0xa70>
ffffffffc020132e:	d8dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201332:	5571                	li	a0,-4
            goto failed;
ffffffffc0201334:	bf45                	j	ffffffffc02012e4 <do_pgfault+0x7c>

ffffffffc0201336 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0201336:	7135                	addi	sp,sp,-160
ffffffffc0201338:	ed06                	sd	ra,152(sp)
ffffffffc020133a:	e922                	sd	s0,144(sp)
ffffffffc020133c:	e526                	sd	s1,136(sp)
ffffffffc020133e:	e14a                	sd	s2,128(sp)
ffffffffc0201340:	fcce                	sd	s3,120(sp)
ffffffffc0201342:	f8d2                	sd	s4,112(sp)
ffffffffc0201344:	f4d6                	sd	s5,104(sp)
ffffffffc0201346:	f0da                	sd	s6,96(sp)
ffffffffc0201348:	ecde                	sd	s7,88(sp)
ffffffffc020134a:	e8e2                	sd	s8,80(sp)
ffffffffc020134c:	e4e6                	sd	s9,72(sp)
ffffffffc020134e:	e0ea                	sd	s10,64(sp)
ffffffffc0201350:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0201352:	21f020ef          	jal	ra,ffffffffc0203d70 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     // 由于IDE是伪造的，它最多只能存储7个页面才能通过测试
     if (!(7 <= max_swap_offset &&
ffffffffc0201356:	00010697          	auipc	a3,0x10
ffffffffc020135a:	1ca6b683          	ld	a3,458(a3) # ffffffffc0211520 <max_swap_offset>
ffffffffc020135e:	010007b7          	lui	a5,0x1000
ffffffffc0201362:	ff968713          	addi	a4,a3,-7
ffffffffc0201366:	17e1                	addi	a5,a5,-8
ffffffffc0201368:	3ee7e063          	bltu	a5,a4,ffffffffc0201748 <swap_init+0x412>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     //sm = &swap_manager_fifo;
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc020136c:	00009797          	auipc	a5,0x9
ffffffffc0201370:	c9478793          	addi	a5,a5,-876 # ffffffffc020a000 <swap_manager_clock>
     //sm = &swap_manager_lru;
     int r = sm->init();
ffffffffc0201374:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc0201376:	00010b17          	auipc	s6,0x10
ffffffffc020137a:	1b2b0b13          	addi	s6,s6,434 # ffffffffc0211528 <sm>
ffffffffc020137e:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc0201382:	9702                	jalr	a4
ffffffffc0201384:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc0201386:	c10d                	beqz	a0,ffffffffc02013a8 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0201388:	60ea                	ld	ra,152(sp)
ffffffffc020138a:	644a                	ld	s0,144(sp)
ffffffffc020138c:	64aa                	ld	s1,136(sp)
ffffffffc020138e:	690a                	ld	s2,128(sp)
ffffffffc0201390:	7a46                	ld	s4,112(sp)
ffffffffc0201392:	7aa6                	ld	s5,104(sp)
ffffffffc0201394:	7b06                	ld	s6,96(sp)
ffffffffc0201396:	6be6                	ld	s7,88(sp)
ffffffffc0201398:	6c46                	ld	s8,80(sp)
ffffffffc020139a:	6ca6                	ld	s9,72(sp)
ffffffffc020139c:	6d06                	ld	s10,64(sp)
ffffffffc020139e:	7de2                	ld	s11,56(sp)
ffffffffc02013a0:	854e                	mv	a0,s3
ffffffffc02013a2:	79e6                	ld	s3,120(sp)
ffffffffc02013a4:	610d                	addi	sp,sp,160
ffffffffc02013a6:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02013a8:	000b3783          	ld	a5,0(s6)
ffffffffc02013ac:	00004517          	auipc	a0,0x4
ffffffffc02013b0:	dbc50513          	addi	a0,a0,-580 # ffffffffc0205168 <commands+0xac8>
ffffffffc02013b4:	00010497          	auipc	s1,0x10
ffffffffc02013b8:	d1c48493          	addi	s1,s1,-740 # ffffffffc02110d0 <free_area>
ffffffffc02013bc:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02013be:	4785                	li	a5,1
ffffffffc02013c0:	00010717          	auipc	a4,0x10
ffffffffc02013c4:	16f72823          	sw	a5,368(a4) # ffffffffc0211530 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02013c8:	cf3fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02013cc:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02013ce:	4401                	li	s0,0
ffffffffc02013d0:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02013d2:	2c978163          	beq	a5,s1,ffffffffc0201694 <swap_init+0x35e>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02013d6:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02013da:	8b09                	andi	a4,a4,2
ffffffffc02013dc:	2a070e63          	beqz	a4,ffffffffc0201698 <swap_init+0x362>
        count ++, total += p->property;
ffffffffc02013e0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013e4:	679c                	ld	a5,8(a5)
ffffffffc02013e6:	2d05                	addiw	s10,s10,1
ffffffffc02013e8:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02013ea:	fe9796e3          	bne	a5,s1,ffffffffc02013d6 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc02013ee:	8922                	mv	s2,s0
ffffffffc02013f0:	6f8010ef          	jal	ra,ffffffffc0202ae8 <nr_free_pages>
ffffffffc02013f4:	47251663          	bne	a0,s2,ffffffffc0201860 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02013f8:	8622                	mv	a2,s0
ffffffffc02013fa:	85ea                	mv	a1,s10
ffffffffc02013fc:	00004517          	auipc	a0,0x4
ffffffffc0201400:	db450513          	addi	a0,a0,-588 # ffffffffc02051b0 <commands+0xb10>
ffffffffc0201404:	cb7fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0201408:	eccff0ef          	jal	ra,ffffffffc0200ad4 <mm_create>
ffffffffc020140c:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc020140e:	52050963          	beqz	a0,ffffffffc0201940 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0201412:	00010797          	auipc	a5,0x10
ffffffffc0201416:	0fe78793          	addi	a5,a5,254 # ffffffffc0211510 <check_mm_struct>
ffffffffc020141a:	6398                	ld	a4,0(a5)
ffffffffc020141c:	54071263          	bnez	a4,ffffffffc0201960 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201420:	00010b97          	auipc	s7,0x10
ffffffffc0201424:	128bbb83          	ld	s7,296(s7) # ffffffffc0211548 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc0201428:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc020142c:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020142e:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0201432:	3c071763          	bnez	a4,ffffffffc0201800 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0201436:	6599                	lui	a1,0x6
ffffffffc0201438:	460d                	li	a2,3
ffffffffc020143a:	6505                	lui	a0,0x1
ffffffffc020143c:	ee0ff0ef          	jal	ra,ffffffffc0200b1c <vma_create>
ffffffffc0201440:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0201442:	3c050f63          	beqz	a0,ffffffffc0201820 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc0201446:	8556                	mv	a0,s5
ffffffffc0201448:	f42ff0ef          	jal	ra,ffffffffc0200b8a <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020144c:	00004517          	auipc	a0,0x4
ffffffffc0201450:	da450513          	addi	a0,a0,-604 # ffffffffc02051f0 <commands+0xb50>
ffffffffc0201454:	c67fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0201458:	018ab503          	ld	a0,24(s5)
ffffffffc020145c:	4605                	li	a2,1
ffffffffc020145e:	6585                	lui	a1,0x1
ffffffffc0201460:	6c2010ef          	jal	ra,ffffffffc0202b22 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0201464:	3c050e63          	beqz	a0,ffffffffc0201840 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201468:	00004517          	auipc	a0,0x4
ffffffffc020146c:	dd850513          	addi	a0,a0,-552 # ffffffffc0205240 <commands+0xba0>
ffffffffc0201470:	00010917          	auipc	s2,0x10
ffffffffc0201474:	bf090913          	addi	s2,s2,-1040 # ffffffffc0211060 <check_rp>
ffffffffc0201478:	c43fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020147c:	00010a17          	auipc	s4,0x10
ffffffffc0201480:	c04a0a13          	addi	s4,s4,-1020 # ffffffffc0211080 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201484:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc0201486:	4505                	li	a0,1
ffffffffc0201488:	58e010ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc020148c:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0201490:	28050c63          	beqz	a0,ffffffffc0201728 <swap_init+0x3f2>
ffffffffc0201494:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0201496:	8b89                	andi	a5,a5,2
ffffffffc0201498:	26079863          	bnez	a5,ffffffffc0201708 <swap_init+0x3d2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020149c:	0c21                	addi	s8,s8,8
ffffffffc020149e:	ff4c14e3          	bne	s8,s4,ffffffffc0201486 <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02014a2:	609c                	ld	a5,0(s1)
ffffffffc02014a4:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc02014a8:	e084                	sd	s1,0(s1)
ffffffffc02014aa:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc02014ac:	489c                	lw	a5,16(s1)
ffffffffc02014ae:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc02014b0:	00010c17          	auipc	s8,0x10
ffffffffc02014b4:	bb0c0c13          	addi	s8,s8,-1104 # ffffffffc0211060 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc02014b8:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc02014ba:	00010797          	auipc	a5,0x10
ffffffffc02014be:	c207a323          	sw	zero,-986(a5) # ffffffffc02110e0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02014c2:	000c3503          	ld	a0,0(s8)
ffffffffc02014c6:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02014c8:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc02014ca:	5de010ef          	jal	ra,ffffffffc0202aa8 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02014ce:	ff4c1ae3          	bne	s8,s4,ffffffffc02014c2 <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02014d2:	0104ac03          	lw	s8,16(s1)
ffffffffc02014d6:	4791                	li	a5,4
ffffffffc02014d8:	4afc1463          	bne	s8,a5,ffffffffc0201980 <swap_init+0x64a>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02014dc:	00004517          	auipc	a0,0x4
ffffffffc02014e0:	dec50513          	addi	a0,a0,-532 # ffffffffc02052c8 <commands+0xc28>
ffffffffc02014e4:	bd7fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02014e8:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02014ea:	00010797          	auipc	a5,0x10
ffffffffc02014ee:	0207a723          	sw	zero,46(a5) # ffffffffc0211518 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02014f2:	4529                	li	a0,10
ffffffffc02014f4:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc02014f8:	00010597          	auipc	a1,0x10
ffffffffc02014fc:	0205a583          	lw	a1,32(a1) # ffffffffc0211518 <pgfault_num>
ffffffffc0201500:	4805                	li	a6,1
ffffffffc0201502:	00010797          	auipc	a5,0x10
ffffffffc0201506:	01678793          	addi	a5,a5,22 # ffffffffc0211518 <pgfault_num>
ffffffffc020150a:	3f059b63          	bne	a1,a6,ffffffffc0201900 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc020150e:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num==1);
ffffffffc0201512:	4390                	lw	a2,0(a5)
ffffffffc0201514:	2601                	sext.w	a2,a2
ffffffffc0201516:	40b61563          	bne	a2,a1,ffffffffc0201920 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc020151a:	6589                	lui	a1,0x2
ffffffffc020151c:	452d                	li	a0,11
ffffffffc020151e:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0201522:	4390                	lw	a2,0(a5)
ffffffffc0201524:	4809                	li	a6,2
ffffffffc0201526:	2601                	sext.w	a2,a2
ffffffffc0201528:	35061c63          	bne	a2,a6,ffffffffc0201880 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc020152c:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==2);
ffffffffc0201530:	438c                	lw	a1,0(a5)
ffffffffc0201532:	2581                	sext.w	a1,a1
ffffffffc0201534:	36c59663          	bne	a1,a2,ffffffffc02018a0 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201538:	658d                	lui	a1,0x3
ffffffffc020153a:	4531                	li	a0,12
ffffffffc020153c:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0201540:	4390                	lw	a2,0(a5)
ffffffffc0201542:	480d                	li	a6,3
ffffffffc0201544:	2601                	sext.w	a2,a2
ffffffffc0201546:	37061d63          	bne	a2,a6,ffffffffc02018c0 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc020154a:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==3);
ffffffffc020154e:	438c                	lw	a1,0(a5)
ffffffffc0201550:	2581                	sext.w	a1,a1
ffffffffc0201552:	38c59763          	bne	a1,a2,ffffffffc02018e0 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201556:	6591                	lui	a1,0x4
ffffffffc0201558:	4535                	li	a0,13
ffffffffc020155a:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc020155e:	4390                	lw	a2,0(a5)
ffffffffc0201560:	2601                	sext.w	a2,a2
ffffffffc0201562:	21861f63          	bne	a2,s8,ffffffffc0201780 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0201566:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==4);
ffffffffc020156a:	439c                	lw	a5,0(a5)
ffffffffc020156c:	2781                	sext.w	a5,a5
ffffffffc020156e:	22c79963          	bne	a5,a2,ffffffffc02017a0 <swap_init+0x46a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0201572:	489c                	lw	a5,16(s1)
ffffffffc0201574:	24079663          	bnez	a5,ffffffffc02017c0 <swap_init+0x48a>
ffffffffc0201578:	00010797          	auipc	a5,0x10
ffffffffc020157c:	b0878793          	addi	a5,a5,-1272 # ffffffffc0211080 <swap_in_seq_no>
ffffffffc0201580:	00010617          	auipc	a2,0x10
ffffffffc0201584:	b2860613          	addi	a2,a2,-1240 # ffffffffc02110a8 <swap_out_seq_no>
ffffffffc0201588:	00010517          	auipc	a0,0x10
ffffffffc020158c:	b2050513          	addi	a0,a0,-1248 # ffffffffc02110a8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0201590:	55fd                	li	a1,-1
ffffffffc0201592:	c38c                	sw	a1,0(a5)
ffffffffc0201594:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201596:	0791                	addi	a5,a5,4
ffffffffc0201598:	0611                	addi	a2,a2,4
ffffffffc020159a:	fef51ce3          	bne	a0,a5,ffffffffc0201592 <swap_init+0x25c>
ffffffffc020159e:	00010817          	auipc	a6,0x10
ffffffffc02015a2:	aa280813          	addi	a6,a6,-1374 # ffffffffc0211040 <check_ptep>
ffffffffc02015a6:	00010897          	auipc	a7,0x10
ffffffffc02015aa:	aba88893          	addi	a7,a7,-1350 # ffffffffc0211060 <check_rp>
ffffffffc02015ae:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc02015b0:	00010c97          	auipc	s9,0x10
ffffffffc02015b4:	fa8c8c93          	addi	s9,s9,-88 # ffffffffc0211558 <pages>
ffffffffc02015b8:	00005c17          	auipc	s8,0x5
ffffffffc02015bc:	c60c0c13          	addi	s8,s8,-928 # ffffffffc0206218 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc02015c0:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02015c4:	4601                	li	a2,0
ffffffffc02015c6:	855e                	mv	a0,s7
ffffffffc02015c8:	ec46                	sd	a7,24(sp)
ffffffffc02015ca:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc02015cc:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02015ce:	554010ef          	jal	ra,ffffffffc0202b22 <get_pte>
ffffffffc02015d2:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02015d4:	65c2                	ld	a1,16(sp)
ffffffffc02015d6:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02015d8:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc02015dc:	00010317          	auipc	t1,0x10
ffffffffc02015e0:	f7430313          	addi	t1,t1,-140 # ffffffffc0211550 <npage>
ffffffffc02015e4:	16050e63          	beqz	a0,ffffffffc0201760 <swap_init+0x42a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02015e8:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02015ea:	0017f613          	andi	a2,a5,1
ffffffffc02015ee:	0e060563          	beqz	a2,ffffffffc02016d8 <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc02015f2:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02015f6:	078a                	slli	a5,a5,0x2
ffffffffc02015f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02015fa:	0ec7fb63          	bgeu	a5,a2,ffffffffc02016f0 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc02015fe:	000c3603          	ld	a2,0(s8)
ffffffffc0201602:	000cb503          	ld	a0,0(s9)
ffffffffc0201606:	0008bf03          	ld	t5,0(a7)
ffffffffc020160a:	8f91                	sub	a5,a5,a2
ffffffffc020160c:	00379613          	slli	a2,a5,0x3
ffffffffc0201610:	97b2                	add	a5,a5,a2
ffffffffc0201612:	078e                	slli	a5,a5,0x3
ffffffffc0201614:	97aa                	add	a5,a5,a0
ffffffffc0201616:	0aff1163          	bne	t5,a5,ffffffffc02016b8 <swap_init+0x382>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020161a:	6785                	lui	a5,0x1
ffffffffc020161c:	95be                	add	a1,a1,a5
ffffffffc020161e:	6795                	lui	a5,0x5
ffffffffc0201620:	0821                	addi	a6,a6,8
ffffffffc0201622:	08a1                	addi	a7,a7,8
ffffffffc0201624:	f8f59ee3          	bne	a1,a5,ffffffffc02015c0 <swap_init+0x28a>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0201628:	00004517          	auipc	a0,0x4
ffffffffc020162c:	d8050513          	addi	a0,a0,-640 # ffffffffc02053a8 <commands+0xd08>
ffffffffc0201630:	a8bfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc0201634:	000b3783          	ld	a5,0(s6)
ffffffffc0201638:	7f9c                	ld	a5,56(a5)
ffffffffc020163a:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc020163c:	1a051263          	bnez	a0,ffffffffc02017e0 <swap_init+0x4aa>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0201640:	00093503          	ld	a0,0(s2)
ffffffffc0201644:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201646:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc0201648:	460010ef          	jal	ra,ffffffffc0202aa8 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020164c:	ff491ae3          	bne	s2,s4,ffffffffc0201640 <swap_init+0x30a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0201650:	8556                	mv	a0,s5
ffffffffc0201652:	e08ff0ef          	jal	ra,ffffffffc0200c5a <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0201656:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0201658:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc020165c:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc020165e:	7782                	ld	a5,32(sp)
ffffffffc0201660:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201662:	009d8a63          	beq	s11,s1,ffffffffc0201676 <swap_init+0x340>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201666:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc020166a:	008dbd83          	ld	s11,8(s11)
ffffffffc020166e:	3d7d                	addiw	s10,s10,-1
ffffffffc0201670:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201672:	fe9d9ae3          	bne	s11,s1,ffffffffc0201666 <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0201676:	8622                	mv	a2,s0
ffffffffc0201678:	85ea                	mv	a1,s10
ffffffffc020167a:	00004517          	auipc	a0,0x4
ffffffffc020167e:	d5e50513          	addi	a0,a0,-674 # ffffffffc02053d8 <commands+0xd38>
ffffffffc0201682:	a39fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0201686:	00004517          	auipc	a0,0x4
ffffffffc020168a:	d7250513          	addi	a0,a0,-654 # ffffffffc02053f8 <commands+0xd58>
ffffffffc020168e:	a2dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0201692:	b9dd                	j	ffffffffc0201388 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201694:	4901                	li	s2,0
ffffffffc0201696:	bba9                	j	ffffffffc02013f0 <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc0201698:	00004697          	auipc	a3,0x4
ffffffffc020169c:	ae868693          	addi	a3,a3,-1304 # ffffffffc0205180 <commands+0xae0>
ffffffffc02016a0:	00003617          	auipc	a2,0x3
ffffffffc02016a4:	72860613          	addi	a2,a2,1832 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02016a8:	0c000593          	li	a1,192
ffffffffc02016ac:	00004517          	auipc	a0,0x4
ffffffffc02016b0:	aac50513          	addi	a0,a0,-1364 # ffffffffc0205158 <commands+0xab8>
ffffffffc02016b4:	a4ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02016b8:	00004697          	auipc	a3,0x4
ffffffffc02016bc:	cc868693          	addi	a3,a3,-824 # ffffffffc0205380 <commands+0xce0>
ffffffffc02016c0:	00003617          	auipc	a2,0x3
ffffffffc02016c4:	70860613          	addi	a2,a2,1800 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02016c8:	10000593          	li	a1,256
ffffffffc02016cc:	00004517          	auipc	a0,0x4
ffffffffc02016d0:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0205158 <commands+0xab8>
ffffffffc02016d4:	a2ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02016d8:	00004617          	auipc	a2,0x4
ffffffffc02016dc:	c8060613          	addi	a2,a2,-896 # ffffffffc0205358 <commands+0xcb8>
ffffffffc02016e0:	07200593          	li	a1,114
ffffffffc02016e4:	00004517          	auipc	a0,0x4
ffffffffc02016e8:	95450513          	addi	a0,a0,-1708 # ffffffffc0205038 <commands+0x998>
ffffffffc02016ec:	a17fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02016f0:	00004617          	auipc	a2,0x4
ffffffffc02016f4:	92860613          	addi	a2,a2,-1752 # ffffffffc0205018 <commands+0x978>
ffffffffc02016f8:	06700593          	li	a1,103
ffffffffc02016fc:	00004517          	auipc	a0,0x4
ffffffffc0201700:	93c50513          	addi	a0,a0,-1732 # ffffffffc0205038 <commands+0x998>
ffffffffc0201704:	9fffe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0201708:	00004697          	auipc	a3,0x4
ffffffffc020170c:	b7868693          	addi	a3,a3,-1160 # ffffffffc0205280 <commands+0xbe0>
ffffffffc0201710:	00003617          	auipc	a2,0x3
ffffffffc0201714:	6b860613          	addi	a2,a2,1720 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201718:	0e100593          	li	a1,225
ffffffffc020171c:	00004517          	auipc	a0,0x4
ffffffffc0201720:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0205158 <commands+0xab8>
ffffffffc0201724:	9dffe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0201728:	00004697          	auipc	a3,0x4
ffffffffc020172c:	b4068693          	addi	a3,a3,-1216 # ffffffffc0205268 <commands+0xbc8>
ffffffffc0201730:	00003617          	auipc	a2,0x3
ffffffffc0201734:	69860613          	addi	a2,a2,1688 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201738:	0e000593          	li	a1,224
ffffffffc020173c:	00004517          	auipc	a0,0x4
ffffffffc0201740:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0205158 <commands+0xab8>
ffffffffc0201744:	9bffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0201748:	00004617          	auipc	a2,0x4
ffffffffc020174c:	9f060613          	addi	a2,a2,-1552 # ffffffffc0205138 <commands+0xa98>
ffffffffc0201750:	02900593          	li	a1,41
ffffffffc0201754:	00004517          	auipc	a0,0x4
ffffffffc0201758:	a0450513          	addi	a0,a0,-1532 # ffffffffc0205158 <commands+0xab8>
ffffffffc020175c:	9a7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0201760:	00004697          	auipc	a3,0x4
ffffffffc0201764:	be068693          	addi	a3,a3,-1056 # ffffffffc0205340 <commands+0xca0>
ffffffffc0201768:	00003617          	auipc	a2,0x3
ffffffffc020176c:	66060613          	addi	a2,a2,1632 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201770:	0ff00593          	li	a1,255
ffffffffc0201774:	00004517          	auipc	a0,0x4
ffffffffc0201778:	9e450513          	addi	a0,a0,-1564 # ffffffffc0205158 <commands+0xab8>
ffffffffc020177c:	987fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc0201780:	00004697          	auipc	a3,0x4
ffffffffc0201784:	ba068693          	addi	a3,a3,-1120 # ffffffffc0205320 <commands+0xc80>
ffffffffc0201788:	00003617          	auipc	a2,0x3
ffffffffc020178c:	64060613          	addi	a2,a2,1600 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201790:	0a300593          	li	a1,163
ffffffffc0201794:	00004517          	auipc	a0,0x4
ffffffffc0201798:	9c450513          	addi	a0,a0,-1596 # ffffffffc0205158 <commands+0xab8>
ffffffffc020179c:	967fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc02017a0:	00004697          	auipc	a3,0x4
ffffffffc02017a4:	b8068693          	addi	a3,a3,-1152 # ffffffffc0205320 <commands+0xc80>
ffffffffc02017a8:	00003617          	auipc	a2,0x3
ffffffffc02017ac:	62060613          	addi	a2,a2,1568 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02017b0:	0a500593          	li	a1,165
ffffffffc02017b4:	00004517          	auipc	a0,0x4
ffffffffc02017b8:	9a450513          	addi	a0,a0,-1628 # ffffffffc0205158 <commands+0xab8>
ffffffffc02017bc:	947fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert( nr_free == 0);         
ffffffffc02017c0:	00004697          	auipc	a3,0x4
ffffffffc02017c4:	b7068693          	addi	a3,a3,-1168 # ffffffffc0205330 <commands+0xc90>
ffffffffc02017c8:	00003617          	auipc	a2,0x3
ffffffffc02017cc:	60060613          	addi	a2,a2,1536 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02017d0:	0f700593          	li	a1,247
ffffffffc02017d4:	00004517          	auipc	a0,0x4
ffffffffc02017d8:	98450513          	addi	a0,a0,-1660 # ffffffffc0205158 <commands+0xab8>
ffffffffc02017dc:	927fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(ret==0);
ffffffffc02017e0:	00004697          	auipc	a3,0x4
ffffffffc02017e4:	bf068693          	addi	a3,a3,-1040 # ffffffffc02053d0 <commands+0xd30>
ffffffffc02017e8:	00003617          	auipc	a2,0x3
ffffffffc02017ec:	5e060613          	addi	a2,a2,1504 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02017f0:	10600593          	li	a1,262
ffffffffc02017f4:	00004517          	auipc	a0,0x4
ffffffffc02017f8:	96450513          	addi	a0,a0,-1692 # ffffffffc0205158 <commands+0xab8>
ffffffffc02017fc:	907fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0201800:	00003697          	auipc	a3,0x3
ffffffffc0201804:	7d868693          	addi	a3,a3,2008 # ffffffffc0204fd8 <commands+0x938>
ffffffffc0201808:	00003617          	auipc	a2,0x3
ffffffffc020180c:	5c060613          	addi	a2,a2,1472 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201810:	0d000593          	li	a1,208
ffffffffc0201814:	00004517          	auipc	a0,0x4
ffffffffc0201818:	94450513          	addi	a0,a0,-1724 # ffffffffc0205158 <commands+0xab8>
ffffffffc020181c:	8e7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(vma != NULL);
ffffffffc0201820:	00004697          	auipc	a3,0x4
ffffffffc0201824:	86068693          	addi	a3,a3,-1952 # ffffffffc0205080 <commands+0x9e0>
ffffffffc0201828:	00003617          	auipc	a2,0x3
ffffffffc020182c:	5a060613          	addi	a2,a2,1440 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201830:	0d300593          	li	a1,211
ffffffffc0201834:	00004517          	auipc	a0,0x4
ffffffffc0201838:	92450513          	addi	a0,a0,-1756 # ffffffffc0205158 <commands+0xab8>
ffffffffc020183c:	8c7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0201840:	00004697          	auipc	a3,0x4
ffffffffc0201844:	9e868693          	addi	a3,a3,-1560 # ffffffffc0205228 <commands+0xb88>
ffffffffc0201848:	00003617          	auipc	a2,0x3
ffffffffc020184c:	58060613          	addi	a2,a2,1408 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201850:	0db00593          	li	a1,219
ffffffffc0201854:	00004517          	auipc	a0,0x4
ffffffffc0201858:	90450513          	addi	a0,a0,-1788 # ffffffffc0205158 <commands+0xab8>
ffffffffc020185c:	8a7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(total == nr_free_pages());
ffffffffc0201860:	00004697          	auipc	a3,0x4
ffffffffc0201864:	93068693          	addi	a3,a3,-1744 # ffffffffc0205190 <commands+0xaf0>
ffffffffc0201868:	00003617          	auipc	a2,0x3
ffffffffc020186c:	56060613          	addi	a2,a2,1376 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201870:	0c300593          	li	a1,195
ffffffffc0201874:	00004517          	auipc	a0,0x4
ffffffffc0201878:	8e450513          	addi	a0,a0,-1820 # ffffffffc0205158 <commands+0xab8>
ffffffffc020187c:	887fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc0201880:	00004697          	auipc	a3,0x4
ffffffffc0201884:	a8068693          	addi	a3,a3,-1408 # ffffffffc0205300 <commands+0xc60>
ffffffffc0201888:	00003617          	auipc	a2,0x3
ffffffffc020188c:	54060613          	addi	a2,a2,1344 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201890:	09b00593          	li	a1,155
ffffffffc0201894:	00004517          	auipc	a0,0x4
ffffffffc0201898:	8c450513          	addi	a0,a0,-1852 # ffffffffc0205158 <commands+0xab8>
ffffffffc020189c:	867fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc02018a0:	00004697          	auipc	a3,0x4
ffffffffc02018a4:	a6068693          	addi	a3,a3,-1440 # ffffffffc0205300 <commands+0xc60>
ffffffffc02018a8:	00003617          	auipc	a2,0x3
ffffffffc02018ac:	52060613          	addi	a2,a2,1312 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02018b0:	09d00593          	li	a1,157
ffffffffc02018b4:	00004517          	auipc	a0,0x4
ffffffffc02018b8:	8a450513          	addi	a0,a0,-1884 # ffffffffc0205158 <commands+0xab8>
ffffffffc02018bc:	847fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc02018c0:	00004697          	auipc	a3,0x4
ffffffffc02018c4:	a5068693          	addi	a3,a3,-1456 # ffffffffc0205310 <commands+0xc70>
ffffffffc02018c8:	00003617          	auipc	a2,0x3
ffffffffc02018cc:	50060613          	addi	a2,a2,1280 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02018d0:	09f00593          	li	a1,159
ffffffffc02018d4:	00004517          	auipc	a0,0x4
ffffffffc02018d8:	88450513          	addi	a0,a0,-1916 # ffffffffc0205158 <commands+0xab8>
ffffffffc02018dc:	827fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc02018e0:	00004697          	auipc	a3,0x4
ffffffffc02018e4:	a3068693          	addi	a3,a3,-1488 # ffffffffc0205310 <commands+0xc70>
ffffffffc02018e8:	00003617          	auipc	a2,0x3
ffffffffc02018ec:	4e060613          	addi	a2,a2,1248 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02018f0:	0a100593          	li	a1,161
ffffffffc02018f4:	00004517          	auipc	a0,0x4
ffffffffc02018f8:	86450513          	addi	a0,a0,-1948 # ffffffffc0205158 <commands+0xab8>
ffffffffc02018fc:	807fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201900:	00004697          	auipc	a3,0x4
ffffffffc0201904:	9f068693          	addi	a3,a3,-1552 # ffffffffc02052f0 <commands+0xc50>
ffffffffc0201908:	00003617          	auipc	a2,0x3
ffffffffc020190c:	4c060613          	addi	a2,a2,1216 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201910:	09700593          	li	a1,151
ffffffffc0201914:	00004517          	auipc	a0,0x4
ffffffffc0201918:	84450513          	addi	a0,a0,-1980 # ffffffffc0205158 <commands+0xab8>
ffffffffc020191c:	fe6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201920:	00004697          	auipc	a3,0x4
ffffffffc0201924:	9d068693          	addi	a3,a3,-1584 # ffffffffc02052f0 <commands+0xc50>
ffffffffc0201928:	00003617          	auipc	a2,0x3
ffffffffc020192c:	4a060613          	addi	a2,a2,1184 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201930:	09900593          	li	a1,153
ffffffffc0201934:	00004517          	auipc	a0,0x4
ffffffffc0201938:	82450513          	addi	a0,a0,-2012 # ffffffffc0205158 <commands+0xab8>
ffffffffc020193c:	fc6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(mm != NULL);
ffffffffc0201940:	00003697          	auipc	a3,0x3
ffffffffc0201944:	76868693          	addi	a3,a3,1896 # ffffffffc02050a8 <commands+0xa08>
ffffffffc0201948:	00003617          	auipc	a2,0x3
ffffffffc020194c:	48060613          	addi	a2,a2,1152 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201950:	0c800593          	li	a1,200
ffffffffc0201954:	00004517          	auipc	a0,0x4
ffffffffc0201958:	80450513          	addi	a0,a0,-2044 # ffffffffc0205158 <commands+0xab8>
ffffffffc020195c:	fa6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0201960:	00004697          	auipc	a3,0x4
ffffffffc0201964:	87868693          	addi	a3,a3,-1928 # ffffffffc02051d8 <commands+0xb38>
ffffffffc0201968:	00003617          	auipc	a2,0x3
ffffffffc020196c:	46060613          	addi	a2,a2,1120 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201970:	0cb00593          	li	a1,203
ffffffffc0201974:	00003517          	auipc	a0,0x3
ffffffffc0201978:	7e450513          	addi	a0,a0,2020 # ffffffffc0205158 <commands+0xab8>
ffffffffc020197c:	f86fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201980:	00004697          	auipc	a3,0x4
ffffffffc0201984:	92068693          	addi	a3,a3,-1760 # ffffffffc02052a0 <commands+0xc00>
ffffffffc0201988:	00003617          	auipc	a2,0x3
ffffffffc020198c:	44060613          	addi	a2,a2,1088 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201990:	0ee00593          	li	a1,238
ffffffffc0201994:	00003517          	auipc	a0,0x3
ffffffffc0201998:	7c450513          	addi	a0,a0,1988 # ffffffffc0205158 <commands+0xab8>
ffffffffc020199c:	f66fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02019a0 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02019a0:	00010797          	auipc	a5,0x10
ffffffffc02019a4:	b887b783          	ld	a5,-1144(a5) # ffffffffc0211528 <sm>
ffffffffc02019a8:	6b9c                	ld	a5,16(a5)
ffffffffc02019aa:	8782                	jr	a5

ffffffffc02019ac <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02019ac:	00010797          	auipc	a5,0x10
ffffffffc02019b0:	b7c7b783          	ld	a5,-1156(a5) # ffffffffc0211528 <sm>
ffffffffc02019b4:	739c                	ld	a5,32(a5)
ffffffffc02019b6:	8782                	jr	a5

ffffffffc02019b8 <swap_out>:
{
ffffffffc02019b8:	711d                	addi	sp,sp,-96
ffffffffc02019ba:	ec86                	sd	ra,88(sp)
ffffffffc02019bc:	e8a2                	sd	s0,80(sp)
ffffffffc02019be:	e4a6                	sd	s1,72(sp)
ffffffffc02019c0:	e0ca                	sd	s2,64(sp)
ffffffffc02019c2:	fc4e                	sd	s3,56(sp)
ffffffffc02019c4:	f852                	sd	s4,48(sp)
ffffffffc02019c6:	f456                	sd	s5,40(sp)
ffffffffc02019c8:	f05a                	sd	s6,32(sp)
ffffffffc02019ca:	ec5e                	sd	s7,24(sp)
ffffffffc02019cc:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02019ce:	cde9                	beqz	a1,ffffffffc0201aa8 <swap_out+0xf0>
ffffffffc02019d0:	8a2e                	mv	s4,a1
ffffffffc02019d2:	892a                	mv	s2,a0
ffffffffc02019d4:	8ab2                	mv	s5,a2
ffffffffc02019d6:	4401                	li	s0,0
ffffffffc02019d8:	00010997          	auipc	s3,0x10
ffffffffc02019dc:	b5098993          	addi	s3,s3,-1200 # ffffffffc0211528 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02019e0:	00004b17          	auipc	s6,0x4
ffffffffc02019e4:	a98b0b13          	addi	s6,s6,-1384 # ffffffffc0205478 <commands+0xdd8>
                    cprintf("SWAP: failed to save\n");
ffffffffc02019e8:	00004b97          	auipc	s7,0x4
ffffffffc02019ec:	a78b8b93          	addi	s7,s7,-1416 # ffffffffc0205460 <commands+0xdc0>
ffffffffc02019f0:	a825                	j	ffffffffc0201a28 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02019f2:	67a2                	ld	a5,8(sp)
ffffffffc02019f4:	8626                	mv	a2,s1
ffffffffc02019f6:	85a2                	mv	a1,s0
ffffffffc02019f8:	63b4                	ld	a3,64(a5)
ffffffffc02019fa:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc02019fc:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02019fe:	82b1                	srli	a3,a3,0xc
ffffffffc0201a00:	0685                	addi	a3,a3,1
ffffffffc0201a02:	eb8fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201a06:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0201a08:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201a0a:	613c                	ld	a5,64(a0)
ffffffffc0201a0c:	83b1                	srli	a5,a5,0xc
ffffffffc0201a0e:	0785                	addi	a5,a5,1
ffffffffc0201a10:	07a2                	slli	a5,a5,0x8
ffffffffc0201a12:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0201a16:	092010ef          	jal	ra,ffffffffc0202aa8 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0201a1a:	01893503          	ld	a0,24(s2)
ffffffffc0201a1e:	85a6                	mv	a1,s1
ffffffffc0201a20:	0f0020ef          	jal	ra,ffffffffc0203b10 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0201a24:	048a0d63          	beq	s4,s0,ffffffffc0201a7e <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0201a28:	0009b783          	ld	a5,0(s3)
ffffffffc0201a2c:	8656                	mv	a2,s5
ffffffffc0201a2e:	002c                	addi	a1,sp,8
ffffffffc0201a30:	7b9c                	ld	a5,48(a5)
ffffffffc0201a32:	854a                	mv	a0,s2
ffffffffc0201a34:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0201a36:	e12d                	bnez	a0,ffffffffc0201a98 <swap_out+0xe0>
          v=page->pra_vaddr; //可以获取物理页面对应的虚拟地址
ffffffffc0201a38:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a3a:	01893503          	ld	a0,24(s2)
ffffffffc0201a3e:	4601                	li	a2,0
          v=page->pra_vaddr; //可以获取物理页面对应的虚拟地址
ffffffffc0201a40:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a42:	85a6                	mv	a1,s1
ffffffffc0201a44:	0de010ef          	jal	ra,ffffffffc0202b22 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201a48:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a4a:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0201a4c:	8b85                	andi	a5,a5,1
ffffffffc0201a4e:	cfb9                	beqz	a5,ffffffffc0201aac <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0201a50:	65a2                	ld	a1,8(sp)
ffffffffc0201a52:	61bc                	ld	a5,64(a1)
ffffffffc0201a54:	83b1                	srli	a5,a5,0xc
ffffffffc0201a56:	0785                	addi	a5,a5,1
ffffffffc0201a58:	00879513          	slli	a0,a5,0x8
ffffffffc0201a5c:	3e6020ef          	jal	ra,ffffffffc0203e42 <swapfs_write>
ffffffffc0201a60:	d949                	beqz	a0,ffffffffc02019f2 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201a62:	855e                	mv	a0,s7
ffffffffc0201a64:	e56fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201a68:	0009b783          	ld	a5,0(s3)
ffffffffc0201a6c:	6622                	ld	a2,8(sp)
ffffffffc0201a6e:	4681                	li	a3,0
ffffffffc0201a70:	739c                	ld	a5,32(a5)
ffffffffc0201a72:	85a6                	mv	a1,s1
ffffffffc0201a74:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0201a76:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201a78:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0201a7a:	fa8a17e3          	bne	s4,s0,ffffffffc0201a28 <swap_out+0x70>
}
ffffffffc0201a7e:	60e6                	ld	ra,88(sp)
ffffffffc0201a80:	8522                	mv	a0,s0
ffffffffc0201a82:	6446                	ld	s0,80(sp)
ffffffffc0201a84:	64a6                	ld	s1,72(sp)
ffffffffc0201a86:	6906                	ld	s2,64(sp)
ffffffffc0201a88:	79e2                	ld	s3,56(sp)
ffffffffc0201a8a:	7a42                	ld	s4,48(sp)
ffffffffc0201a8c:	7aa2                	ld	s5,40(sp)
ffffffffc0201a8e:	7b02                	ld	s6,32(sp)
ffffffffc0201a90:	6be2                	ld	s7,24(sp)
ffffffffc0201a92:	6c42                	ld	s8,16(sp)
ffffffffc0201a94:	6125                	addi	sp,sp,96
ffffffffc0201a96:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0201a98:	85a2                	mv	a1,s0
ffffffffc0201a9a:	00004517          	auipc	a0,0x4
ffffffffc0201a9e:	97e50513          	addi	a0,a0,-1666 # ffffffffc0205418 <commands+0xd78>
ffffffffc0201aa2:	e18fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                  break;
ffffffffc0201aa6:	bfe1                	j	ffffffffc0201a7e <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0201aa8:	4401                	li	s0,0
ffffffffc0201aaa:	bfd1                	j	ffffffffc0201a7e <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201aac:	00004697          	auipc	a3,0x4
ffffffffc0201ab0:	99c68693          	addi	a3,a3,-1636 # ffffffffc0205448 <commands+0xda8>
ffffffffc0201ab4:	00003617          	auipc	a2,0x3
ffffffffc0201ab8:	31460613          	addi	a2,a2,788 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201abc:	06b00593          	li	a1,107
ffffffffc0201ac0:	00003517          	auipc	a0,0x3
ffffffffc0201ac4:	69850513          	addi	a0,a0,1688 # ffffffffc0205158 <commands+0xab8>
ffffffffc0201ac8:	e3afe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201acc <swap_in>:
{
ffffffffc0201acc:	7179                	addi	sp,sp,-48
ffffffffc0201ace:	e84a                	sd	s2,16(sp)
ffffffffc0201ad0:	892a                	mv	s2,a0
     struct Page* result = alloc_page(); //这里alloc_page()内部可能调用swap_out()
ffffffffc0201ad2:	4505                	li	a0,1
{
ffffffffc0201ad4:	ec26                	sd	s1,24(sp)
ffffffffc0201ad6:	e44e                	sd	s3,8(sp)
ffffffffc0201ad8:	f406                	sd	ra,40(sp)
ffffffffc0201ada:	f022                	sd	s0,32(sp)
ffffffffc0201adc:	84ae                	mv	s1,a1
ffffffffc0201ade:	89b2                	mv	s3,a2
     struct Page* result = alloc_page(); //这里alloc_page()内部可能调用swap_out()
ffffffffc0201ae0:	737000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
     assert(result!=NULL);
ffffffffc0201ae4:	c129                	beqz	a0,ffffffffc0201b26 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);//找到/构建对应的页表项
ffffffffc0201ae6:	842a                	mv	s0,a0
ffffffffc0201ae8:	01893503          	ld	a0,24(s2)
ffffffffc0201aec:	4601                	li	a2,0
ffffffffc0201aee:	85a6                	mv	a1,s1
ffffffffc0201af0:	032010ef          	jal	ra,ffffffffc0202b22 <get_pte>
ffffffffc0201af4:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)//将数据从硬盘读到内存
ffffffffc0201af6:	6108                	ld	a0,0(a0)
ffffffffc0201af8:	85a2                	mv	a1,s0
ffffffffc0201afa:	2ae020ef          	jal	ra,ffffffffc0203da8 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0201afe:	00093583          	ld	a1,0(s2)
ffffffffc0201b02:	8626                	mv	a2,s1
ffffffffc0201b04:	00004517          	auipc	a0,0x4
ffffffffc0201b08:	9c450513          	addi	a0,a0,-1596 # ffffffffc02054c8 <commands+0xe28>
ffffffffc0201b0c:	81a1                	srli	a1,a1,0x8
ffffffffc0201b0e:	dacfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0201b12:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0201b14:	0089b023          	sd	s0,0(s3)
}
ffffffffc0201b18:	7402                	ld	s0,32(sp)
ffffffffc0201b1a:	64e2                	ld	s1,24(sp)
ffffffffc0201b1c:	6942                	ld	s2,16(sp)
ffffffffc0201b1e:	69a2                	ld	s3,8(sp)
ffffffffc0201b20:	4501                	li	a0,0
ffffffffc0201b22:	6145                	addi	sp,sp,48
ffffffffc0201b24:	8082                	ret
     assert(result!=NULL);
ffffffffc0201b26:	00004697          	auipc	a3,0x4
ffffffffc0201b2a:	99268693          	addi	a3,a3,-1646 # ffffffffc02054b8 <commands+0xe18>
ffffffffc0201b2e:	00003617          	auipc	a2,0x3
ffffffffc0201b32:	29a60613          	addi	a2,a2,666 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201b36:	08200593          	li	a1,130
ffffffffc0201b3a:	00003517          	auipc	a0,0x3
ffffffffc0201b3e:	61e50513          	addi	a0,a0,1566 # ffffffffc0205158 <commands+0xab8>
ffffffffc0201b42:	dc0fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201b46 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0201b46:	0000f797          	auipc	a5,0xf
ffffffffc0201b4a:	58a78793          	addi	a5,a5,1418 # ffffffffc02110d0 <free_area>
ffffffffc0201b4e:	e79c                	sd	a5,8(a5)
ffffffffc0201b50:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201b52:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201b56:	8082                	ret

ffffffffc0201b58 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0201b58:	0000f517          	auipc	a0,0xf
ffffffffc0201b5c:	58856503          	lwu	a0,1416(a0) # ffffffffc02110e0 <free_area+0x10>
ffffffffc0201b60:	8082                	ret

ffffffffc0201b62 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0201b62:	715d                	addi	sp,sp,-80
ffffffffc0201b64:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0201b66:	0000f417          	auipc	s0,0xf
ffffffffc0201b6a:	56a40413          	addi	s0,s0,1386 # ffffffffc02110d0 <free_area>
ffffffffc0201b6e:	641c                	ld	a5,8(s0)
ffffffffc0201b70:	e486                	sd	ra,72(sp)
ffffffffc0201b72:	fc26                	sd	s1,56(sp)
ffffffffc0201b74:	f84a                	sd	s2,48(sp)
ffffffffc0201b76:	f44e                	sd	s3,40(sp)
ffffffffc0201b78:	f052                	sd	s4,32(sp)
ffffffffc0201b7a:	ec56                	sd	s5,24(sp)
ffffffffc0201b7c:	e85a                	sd	s6,16(sp)
ffffffffc0201b7e:	e45e                	sd	s7,8(sp)
ffffffffc0201b80:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201b82:	2c878763          	beq	a5,s0,ffffffffc0201e50 <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0201b86:	4481                	li	s1,0
ffffffffc0201b88:	4901                	li	s2,0
ffffffffc0201b8a:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201b8e:	8b09                	andi	a4,a4,2
ffffffffc0201b90:	2c070463          	beqz	a4,ffffffffc0201e58 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0201b94:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201b98:	679c                	ld	a5,8(a5)
ffffffffc0201b9a:	2905                	addiw	s2,s2,1
ffffffffc0201b9c:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201b9e:	fe8796e3          	bne	a5,s0,ffffffffc0201b8a <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0201ba2:	89a6                	mv	s3,s1
ffffffffc0201ba4:	745000ef          	jal	ra,ffffffffc0202ae8 <nr_free_pages>
ffffffffc0201ba8:	71351863          	bne	a0,s3,ffffffffc02022b8 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201bac:	4505                	li	a0,1
ffffffffc0201bae:	669000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201bb2:	8a2a                	mv	s4,a0
ffffffffc0201bb4:	44050263          	beqz	a0,ffffffffc0201ff8 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201bb8:	4505                	li	a0,1
ffffffffc0201bba:	65d000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201bbe:	89aa                	mv	s3,a0
ffffffffc0201bc0:	70050c63          	beqz	a0,ffffffffc02022d8 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201bc4:	4505                	li	a0,1
ffffffffc0201bc6:	651000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201bca:	8aaa                	mv	s5,a0
ffffffffc0201bcc:	4a050663          	beqz	a0,ffffffffc0202078 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201bd0:	2b3a0463          	beq	s4,s3,ffffffffc0201e78 <default_check+0x316>
ffffffffc0201bd4:	2aaa0263          	beq	s4,a0,ffffffffc0201e78 <default_check+0x316>
ffffffffc0201bd8:	2aa98063          	beq	s3,a0,ffffffffc0201e78 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201bdc:	000a2783          	lw	a5,0(s4)
ffffffffc0201be0:	2a079c63          	bnez	a5,ffffffffc0201e98 <default_check+0x336>
ffffffffc0201be4:	0009a783          	lw	a5,0(s3)
ffffffffc0201be8:	2a079863          	bnez	a5,ffffffffc0201e98 <default_check+0x336>
ffffffffc0201bec:	411c                	lw	a5,0(a0)
ffffffffc0201bee:	2a079563          	bnez	a5,ffffffffc0201e98 <default_check+0x336>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201bf2:	00010797          	auipc	a5,0x10
ffffffffc0201bf6:	9667b783          	ld	a5,-1690(a5) # ffffffffc0211558 <pages>
ffffffffc0201bfa:	40fa0733          	sub	a4,s4,a5
ffffffffc0201bfe:	870d                	srai	a4,a4,0x3
ffffffffc0201c00:	00004597          	auipc	a1,0x4
ffffffffc0201c04:	6105b583          	ld	a1,1552(a1) # ffffffffc0206210 <error_string+0x38>
ffffffffc0201c08:	02b70733          	mul	a4,a4,a1
ffffffffc0201c0c:	00004617          	auipc	a2,0x4
ffffffffc0201c10:	60c63603          	ld	a2,1548(a2) # ffffffffc0206218 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201c14:	00010697          	auipc	a3,0x10
ffffffffc0201c18:	93c6b683          	ld	a3,-1732(a3) # ffffffffc0211550 <npage>
ffffffffc0201c1c:	06b2                	slli	a3,a3,0xc
ffffffffc0201c1e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c20:	0732                	slli	a4,a4,0xc
ffffffffc0201c22:	28d77b63          	bgeu	a4,a3,ffffffffc0201eb8 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201c26:	40f98733          	sub	a4,s3,a5
ffffffffc0201c2a:	870d                	srai	a4,a4,0x3
ffffffffc0201c2c:	02b70733          	mul	a4,a4,a1
ffffffffc0201c30:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c32:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201c34:	4cd77263          	bgeu	a4,a3,ffffffffc02020f8 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201c38:	40f507b3          	sub	a5,a0,a5
ffffffffc0201c3c:	878d                	srai	a5,a5,0x3
ffffffffc0201c3e:	02b787b3          	mul	a5,a5,a1
ffffffffc0201c42:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c44:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201c46:	30d7f963          	bgeu	a5,a3,ffffffffc0201f58 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0201c4a:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201c4c:	00043c03          	ld	s8,0(s0)
ffffffffc0201c50:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0201c54:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0201c58:	e400                	sd	s0,8(s0)
ffffffffc0201c5a:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0201c5c:	0000f797          	auipc	a5,0xf
ffffffffc0201c60:	4807a223          	sw	zero,1156(a5) # ffffffffc02110e0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201c64:	5b3000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201c68:	2c051863          	bnez	a0,ffffffffc0201f38 <default_check+0x3d6>
    free_page(p0);
ffffffffc0201c6c:	4585                	li	a1,1
ffffffffc0201c6e:	8552                	mv	a0,s4
ffffffffc0201c70:	639000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    free_page(p1);
ffffffffc0201c74:	4585                	li	a1,1
ffffffffc0201c76:	854e                	mv	a0,s3
ffffffffc0201c78:	631000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    free_page(p2);
ffffffffc0201c7c:	4585                	li	a1,1
ffffffffc0201c7e:	8556                	mv	a0,s5
ffffffffc0201c80:	629000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    assert(nr_free == 3);
ffffffffc0201c84:	4818                	lw	a4,16(s0)
ffffffffc0201c86:	478d                	li	a5,3
ffffffffc0201c88:	28f71863          	bne	a4,a5,ffffffffc0201f18 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201c8c:	4505                	li	a0,1
ffffffffc0201c8e:	589000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201c92:	89aa                	mv	s3,a0
ffffffffc0201c94:	26050263          	beqz	a0,ffffffffc0201ef8 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201c98:	4505                	li	a0,1
ffffffffc0201c9a:	57d000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201c9e:	8aaa                	mv	s5,a0
ffffffffc0201ca0:	3a050c63          	beqz	a0,ffffffffc0202058 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201ca4:	4505                	li	a0,1
ffffffffc0201ca6:	571000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201caa:	8a2a                	mv	s4,a0
ffffffffc0201cac:	38050663          	beqz	a0,ffffffffc0202038 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0201cb0:	4505                	li	a0,1
ffffffffc0201cb2:	565000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201cb6:	36051163          	bnez	a0,ffffffffc0202018 <default_check+0x4b6>
    free_page(p0);
ffffffffc0201cba:	4585                	li	a1,1
ffffffffc0201cbc:	854e                	mv	a0,s3
ffffffffc0201cbe:	5eb000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201cc2:	641c                	ld	a5,8(s0)
ffffffffc0201cc4:	20878a63          	beq	a5,s0,ffffffffc0201ed8 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0201cc8:	4505                	li	a0,1
ffffffffc0201cca:	54d000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201cce:	30a99563          	bne	s3,a0,ffffffffc0201fd8 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0201cd2:	4505                	li	a0,1
ffffffffc0201cd4:	543000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201cd8:	2e051063          	bnez	a0,ffffffffc0201fb8 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0201cdc:	481c                	lw	a5,16(s0)
ffffffffc0201cde:	2a079d63          	bnez	a5,ffffffffc0201f98 <default_check+0x436>
    free_page(p);
ffffffffc0201ce2:	854e                	mv	a0,s3
ffffffffc0201ce4:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201ce6:	01843023          	sd	s8,0(s0)
ffffffffc0201cea:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0201cee:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0201cf2:	5b7000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    free_page(p1);
ffffffffc0201cf6:	4585                	li	a1,1
ffffffffc0201cf8:	8556                	mv	a0,s5
ffffffffc0201cfa:	5af000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    free_page(p2);
ffffffffc0201cfe:	4585                	li	a1,1
ffffffffc0201d00:	8552                	mv	a0,s4
ffffffffc0201d02:	5a7000ef          	jal	ra,ffffffffc0202aa8 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201d06:	4515                	li	a0,5
ffffffffc0201d08:	50f000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201d0c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201d0e:	26050563          	beqz	a0,ffffffffc0201f78 <default_check+0x416>
ffffffffc0201d12:	651c                	ld	a5,8(a0)
ffffffffc0201d14:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0201d16:	8b85                	andi	a5,a5,1
ffffffffc0201d18:	54079063          	bnez	a5,ffffffffc0202258 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201d1c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201d1e:	00043b03          	ld	s6,0(s0)
ffffffffc0201d22:	00843a83          	ld	s5,8(s0)
ffffffffc0201d26:	e000                	sd	s0,0(s0)
ffffffffc0201d28:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0201d2a:	4ed000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201d2e:	50051563          	bnez	a0,ffffffffc0202238 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201d32:	09098a13          	addi	s4,s3,144
ffffffffc0201d36:	8552                	mv	a0,s4
ffffffffc0201d38:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201d3a:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0201d3e:	0000f797          	auipc	a5,0xf
ffffffffc0201d42:	3a07a123          	sw	zero,930(a5) # ffffffffc02110e0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201d46:	563000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201d4a:	4511                	li	a0,4
ffffffffc0201d4c:	4cb000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201d50:	4c051463          	bnez	a0,ffffffffc0202218 <default_check+0x6b6>
ffffffffc0201d54:	0989b783          	ld	a5,152(s3)
ffffffffc0201d58:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201d5a:	8b85                	andi	a5,a5,1
ffffffffc0201d5c:	48078e63          	beqz	a5,ffffffffc02021f8 <default_check+0x696>
ffffffffc0201d60:	0a89a703          	lw	a4,168(s3)
ffffffffc0201d64:	478d                	li	a5,3
ffffffffc0201d66:	48f71963          	bne	a4,a5,ffffffffc02021f8 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201d6a:	450d                	li	a0,3
ffffffffc0201d6c:	4ab000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201d70:	8c2a                	mv	s8,a0
ffffffffc0201d72:	46050363          	beqz	a0,ffffffffc02021d8 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0201d76:	4505                	li	a0,1
ffffffffc0201d78:	49f000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201d7c:	42051e63          	bnez	a0,ffffffffc02021b8 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0201d80:	418a1c63          	bne	s4,s8,ffffffffc0202198 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201d84:	4585                	li	a1,1
ffffffffc0201d86:	854e                	mv	a0,s3
ffffffffc0201d88:	521000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    free_pages(p1, 3);
ffffffffc0201d8c:	458d                	li	a1,3
ffffffffc0201d8e:	8552                	mv	a0,s4
ffffffffc0201d90:	519000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
ffffffffc0201d94:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201d98:	04898c13          	addi	s8,s3,72
ffffffffc0201d9c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201d9e:	8b85                	andi	a5,a5,1
ffffffffc0201da0:	3c078c63          	beqz	a5,ffffffffc0202178 <default_check+0x616>
ffffffffc0201da4:	0189a703          	lw	a4,24(s3)
ffffffffc0201da8:	4785                	li	a5,1
ffffffffc0201daa:	3cf71763          	bne	a4,a5,ffffffffc0202178 <default_check+0x616>
ffffffffc0201dae:	008a3783          	ld	a5,8(s4)
ffffffffc0201db2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201db4:	8b85                	andi	a5,a5,1
ffffffffc0201db6:	3a078163          	beqz	a5,ffffffffc0202158 <default_check+0x5f6>
ffffffffc0201dba:	018a2703          	lw	a4,24(s4)
ffffffffc0201dbe:	478d                	li	a5,3
ffffffffc0201dc0:	38f71c63          	bne	a4,a5,ffffffffc0202158 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201dc4:	4505                	li	a0,1
ffffffffc0201dc6:	451000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201dca:	36a99763          	bne	s3,a0,ffffffffc0202138 <default_check+0x5d6>
    free_page(p0);
ffffffffc0201dce:	4585                	li	a1,1
ffffffffc0201dd0:	4d9000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201dd4:	4509                	li	a0,2
ffffffffc0201dd6:	441000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201dda:	32aa1f63          	bne	s4,a0,ffffffffc0202118 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0201dde:	4589                	li	a1,2
ffffffffc0201de0:	4c9000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    free_page(p2);
ffffffffc0201de4:	4585                	li	a1,1
ffffffffc0201de6:	8562                	mv	a0,s8
ffffffffc0201de8:	4c1000ef          	jal	ra,ffffffffc0202aa8 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201dec:	4515                	li	a0,5
ffffffffc0201dee:	429000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201df2:	89aa                	mv	s3,a0
ffffffffc0201df4:	48050263          	beqz	a0,ffffffffc0202278 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0201df8:	4505                	li	a0,1
ffffffffc0201dfa:	41d000ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0201dfe:	2c051d63          	bnez	a0,ffffffffc02020d8 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0201e02:	481c                	lw	a5,16(s0)
ffffffffc0201e04:	2a079a63          	bnez	a5,ffffffffc02020b8 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201e08:	4595                	li	a1,5
ffffffffc0201e0a:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201e0c:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0201e10:	01643023          	sd	s6,0(s0)
ffffffffc0201e14:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0201e18:	491000ef          	jal	ra,ffffffffc0202aa8 <free_pages>
    return listelm->next;
ffffffffc0201e1c:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e1e:	00878963          	beq	a5,s0,ffffffffc0201e30 <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201e22:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201e26:	679c                	ld	a5,8(a5)
ffffffffc0201e28:	397d                	addiw	s2,s2,-1
ffffffffc0201e2a:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e2c:	fe879be3          	bne	a5,s0,ffffffffc0201e22 <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0201e30:	26091463          	bnez	s2,ffffffffc0202098 <default_check+0x536>
    assert(total == 0);
ffffffffc0201e34:	46049263          	bnez	s1,ffffffffc0202298 <default_check+0x736>
}
ffffffffc0201e38:	60a6                	ld	ra,72(sp)
ffffffffc0201e3a:	6406                	ld	s0,64(sp)
ffffffffc0201e3c:	74e2                	ld	s1,56(sp)
ffffffffc0201e3e:	7942                	ld	s2,48(sp)
ffffffffc0201e40:	79a2                	ld	s3,40(sp)
ffffffffc0201e42:	7a02                	ld	s4,32(sp)
ffffffffc0201e44:	6ae2                	ld	s5,24(sp)
ffffffffc0201e46:	6b42                	ld	s6,16(sp)
ffffffffc0201e48:	6ba2                	ld	s7,8(sp)
ffffffffc0201e4a:	6c02                	ld	s8,0(sp)
ffffffffc0201e4c:	6161                	addi	sp,sp,80
ffffffffc0201e4e:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e50:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201e52:	4481                	li	s1,0
ffffffffc0201e54:	4901                	li	s2,0
ffffffffc0201e56:	b3b9                	j	ffffffffc0201ba4 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0201e58:	00003697          	auipc	a3,0x3
ffffffffc0201e5c:	32868693          	addi	a3,a3,808 # ffffffffc0205180 <commands+0xae0>
ffffffffc0201e60:	00003617          	auipc	a2,0x3
ffffffffc0201e64:	f6860613          	addi	a2,a2,-152 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201e68:	0f000593          	li	a1,240
ffffffffc0201e6c:	00003517          	auipc	a0,0x3
ffffffffc0201e70:	69c50513          	addi	a0,a0,1692 # ffffffffc0205508 <commands+0xe68>
ffffffffc0201e74:	a8efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201e78:	00003697          	auipc	a3,0x3
ffffffffc0201e7c:	70868693          	addi	a3,a3,1800 # ffffffffc0205580 <commands+0xee0>
ffffffffc0201e80:	00003617          	auipc	a2,0x3
ffffffffc0201e84:	f4860613          	addi	a2,a2,-184 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201e88:	0bd00593          	li	a1,189
ffffffffc0201e8c:	00003517          	auipc	a0,0x3
ffffffffc0201e90:	67c50513          	addi	a0,a0,1660 # ffffffffc0205508 <commands+0xe68>
ffffffffc0201e94:	a6efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201e98:	00003697          	auipc	a3,0x3
ffffffffc0201e9c:	71068693          	addi	a3,a3,1808 # ffffffffc02055a8 <commands+0xf08>
ffffffffc0201ea0:	00003617          	auipc	a2,0x3
ffffffffc0201ea4:	f2860613          	addi	a2,a2,-216 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201ea8:	0be00593          	li	a1,190
ffffffffc0201eac:	00003517          	auipc	a0,0x3
ffffffffc0201eb0:	65c50513          	addi	a0,a0,1628 # ffffffffc0205508 <commands+0xe68>
ffffffffc0201eb4:	a4efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201eb8:	00003697          	auipc	a3,0x3
ffffffffc0201ebc:	73068693          	addi	a3,a3,1840 # ffffffffc02055e8 <commands+0xf48>
ffffffffc0201ec0:	00003617          	auipc	a2,0x3
ffffffffc0201ec4:	f0860613          	addi	a2,a2,-248 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201ec8:	0c000593          	li	a1,192
ffffffffc0201ecc:	00003517          	auipc	a0,0x3
ffffffffc0201ed0:	63c50513          	addi	a0,a0,1596 # ffffffffc0205508 <commands+0xe68>
ffffffffc0201ed4:	a2efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201ed8:	00003697          	auipc	a3,0x3
ffffffffc0201edc:	79868693          	addi	a3,a3,1944 # ffffffffc0205670 <commands+0xfd0>
ffffffffc0201ee0:	00003617          	auipc	a2,0x3
ffffffffc0201ee4:	ee860613          	addi	a2,a2,-280 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201ee8:	0d900593          	li	a1,217
ffffffffc0201eec:	00003517          	auipc	a0,0x3
ffffffffc0201ef0:	61c50513          	addi	a0,a0,1564 # ffffffffc0205508 <commands+0xe68>
ffffffffc0201ef4:	a0efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201ef8:	00003697          	auipc	a3,0x3
ffffffffc0201efc:	62868693          	addi	a3,a3,1576 # ffffffffc0205520 <commands+0xe80>
ffffffffc0201f00:	00003617          	auipc	a2,0x3
ffffffffc0201f04:	ec860613          	addi	a2,a2,-312 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201f08:	0d200593          	li	a1,210
ffffffffc0201f0c:	00003517          	auipc	a0,0x3
ffffffffc0201f10:	5fc50513          	addi	a0,a0,1532 # ffffffffc0205508 <commands+0xe68>
ffffffffc0201f14:	9eefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 3);
ffffffffc0201f18:	00003697          	auipc	a3,0x3
ffffffffc0201f1c:	74868693          	addi	a3,a3,1864 # ffffffffc0205660 <commands+0xfc0>
ffffffffc0201f20:	00003617          	auipc	a2,0x3
ffffffffc0201f24:	ea860613          	addi	a2,a2,-344 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201f28:	0d000593          	li	a1,208
ffffffffc0201f2c:	00003517          	auipc	a0,0x3
ffffffffc0201f30:	5dc50513          	addi	a0,a0,1500 # ffffffffc0205508 <commands+0xe68>
ffffffffc0201f34:	9cefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201f38:	00003697          	auipc	a3,0x3
ffffffffc0201f3c:	71068693          	addi	a3,a3,1808 # ffffffffc0205648 <commands+0xfa8>
ffffffffc0201f40:	00003617          	auipc	a2,0x3
ffffffffc0201f44:	e8860613          	addi	a2,a2,-376 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201f48:	0cb00593          	li	a1,203
ffffffffc0201f4c:	00003517          	auipc	a0,0x3
ffffffffc0201f50:	5bc50513          	addi	a0,a0,1468 # ffffffffc0205508 <commands+0xe68>
ffffffffc0201f54:	9aefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201f58:	00003697          	auipc	a3,0x3
ffffffffc0201f5c:	6d068693          	addi	a3,a3,1744 # ffffffffc0205628 <commands+0xf88>
ffffffffc0201f60:	00003617          	auipc	a2,0x3
ffffffffc0201f64:	e6860613          	addi	a2,a2,-408 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201f68:	0c200593          	li	a1,194
ffffffffc0201f6c:	00003517          	auipc	a0,0x3
ffffffffc0201f70:	59c50513          	addi	a0,a0,1436 # ffffffffc0205508 <commands+0xe68>
ffffffffc0201f74:	98efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != NULL);
ffffffffc0201f78:	00003697          	auipc	a3,0x3
ffffffffc0201f7c:	73068693          	addi	a3,a3,1840 # ffffffffc02056a8 <commands+0x1008>
ffffffffc0201f80:	00003617          	auipc	a2,0x3
ffffffffc0201f84:	e4860613          	addi	a2,a2,-440 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201f88:	0f800593          	li	a1,248
ffffffffc0201f8c:	00003517          	auipc	a0,0x3
ffffffffc0201f90:	57c50513          	addi	a0,a0,1404 # ffffffffc0205508 <commands+0xe68>
ffffffffc0201f94:	96efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc0201f98:	00003697          	auipc	a3,0x3
ffffffffc0201f9c:	39868693          	addi	a3,a3,920 # ffffffffc0205330 <commands+0xc90>
ffffffffc0201fa0:	00003617          	auipc	a2,0x3
ffffffffc0201fa4:	e2860613          	addi	a2,a2,-472 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201fa8:	0df00593          	li	a1,223
ffffffffc0201fac:	00003517          	auipc	a0,0x3
ffffffffc0201fb0:	55c50513          	addi	a0,a0,1372 # ffffffffc0205508 <commands+0xe68>
ffffffffc0201fb4:	94efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201fb8:	00003697          	auipc	a3,0x3
ffffffffc0201fbc:	69068693          	addi	a3,a3,1680 # ffffffffc0205648 <commands+0xfa8>
ffffffffc0201fc0:	00003617          	auipc	a2,0x3
ffffffffc0201fc4:	e0860613          	addi	a2,a2,-504 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201fc8:	0dd00593          	li	a1,221
ffffffffc0201fcc:	00003517          	auipc	a0,0x3
ffffffffc0201fd0:	53c50513          	addi	a0,a0,1340 # ffffffffc0205508 <commands+0xe68>
ffffffffc0201fd4:	92efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201fd8:	00003697          	auipc	a3,0x3
ffffffffc0201fdc:	6b068693          	addi	a3,a3,1712 # ffffffffc0205688 <commands+0xfe8>
ffffffffc0201fe0:	00003617          	auipc	a2,0x3
ffffffffc0201fe4:	de860613          	addi	a2,a2,-536 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0201fe8:	0dc00593          	li	a1,220
ffffffffc0201fec:	00003517          	auipc	a0,0x3
ffffffffc0201ff0:	51c50513          	addi	a0,a0,1308 # ffffffffc0205508 <commands+0xe68>
ffffffffc0201ff4:	90efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201ff8:	00003697          	auipc	a3,0x3
ffffffffc0201ffc:	52868693          	addi	a3,a3,1320 # ffffffffc0205520 <commands+0xe80>
ffffffffc0202000:	00003617          	auipc	a2,0x3
ffffffffc0202004:	dc860613          	addi	a2,a2,-568 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202008:	0b900593          	li	a1,185
ffffffffc020200c:	00003517          	auipc	a0,0x3
ffffffffc0202010:	4fc50513          	addi	a0,a0,1276 # ffffffffc0205508 <commands+0xe68>
ffffffffc0202014:	8eefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202018:	00003697          	auipc	a3,0x3
ffffffffc020201c:	63068693          	addi	a3,a3,1584 # ffffffffc0205648 <commands+0xfa8>
ffffffffc0202020:	00003617          	auipc	a2,0x3
ffffffffc0202024:	da860613          	addi	a2,a2,-600 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202028:	0d600593          	li	a1,214
ffffffffc020202c:	00003517          	auipc	a0,0x3
ffffffffc0202030:	4dc50513          	addi	a0,a0,1244 # ffffffffc0205508 <commands+0xe68>
ffffffffc0202034:	8cefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202038:	00003697          	auipc	a3,0x3
ffffffffc020203c:	52868693          	addi	a3,a3,1320 # ffffffffc0205560 <commands+0xec0>
ffffffffc0202040:	00003617          	auipc	a2,0x3
ffffffffc0202044:	d8860613          	addi	a2,a2,-632 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202048:	0d400593          	li	a1,212
ffffffffc020204c:	00003517          	auipc	a0,0x3
ffffffffc0202050:	4bc50513          	addi	a0,a0,1212 # ffffffffc0205508 <commands+0xe68>
ffffffffc0202054:	8aefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202058:	00003697          	auipc	a3,0x3
ffffffffc020205c:	4e868693          	addi	a3,a3,1256 # ffffffffc0205540 <commands+0xea0>
ffffffffc0202060:	00003617          	auipc	a2,0x3
ffffffffc0202064:	d6860613          	addi	a2,a2,-664 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202068:	0d300593          	li	a1,211
ffffffffc020206c:	00003517          	auipc	a0,0x3
ffffffffc0202070:	49c50513          	addi	a0,a0,1180 # ffffffffc0205508 <commands+0xe68>
ffffffffc0202074:	88efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202078:	00003697          	auipc	a3,0x3
ffffffffc020207c:	4e868693          	addi	a3,a3,1256 # ffffffffc0205560 <commands+0xec0>
ffffffffc0202080:	00003617          	auipc	a2,0x3
ffffffffc0202084:	d4860613          	addi	a2,a2,-696 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202088:	0bb00593          	li	a1,187
ffffffffc020208c:	00003517          	auipc	a0,0x3
ffffffffc0202090:	47c50513          	addi	a0,a0,1148 # ffffffffc0205508 <commands+0xe68>
ffffffffc0202094:	86efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(count == 0);
ffffffffc0202098:	00003697          	auipc	a3,0x3
ffffffffc020209c:	76068693          	addi	a3,a3,1888 # ffffffffc02057f8 <commands+0x1158>
ffffffffc02020a0:	00003617          	auipc	a2,0x3
ffffffffc02020a4:	d2860613          	addi	a2,a2,-728 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02020a8:	12500593          	li	a1,293
ffffffffc02020ac:	00003517          	auipc	a0,0x3
ffffffffc02020b0:	45c50513          	addi	a0,a0,1116 # ffffffffc0205508 <commands+0xe68>
ffffffffc02020b4:	84efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc02020b8:	00003697          	auipc	a3,0x3
ffffffffc02020bc:	27868693          	addi	a3,a3,632 # ffffffffc0205330 <commands+0xc90>
ffffffffc02020c0:	00003617          	auipc	a2,0x3
ffffffffc02020c4:	d0860613          	addi	a2,a2,-760 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02020c8:	11a00593          	li	a1,282
ffffffffc02020cc:	00003517          	auipc	a0,0x3
ffffffffc02020d0:	43c50513          	addi	a0,a0,1084 # ffffffffc0205508 <commands+0xe68>
ffffffffc02020d4:	82efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02020d8:	00003697          	auipc	a3,0x3
ffffffffc02020dc:	57068693          	addi	a3,a3,1392 # ffffffffc0205648 <commands+0xfa8>
ffffffffc02020e0:	00003617          	auipc	a2,0x3
ffffffffc02020e4:	ce860613          	addi	a2,a2,-792 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02020e8:	11800593          	li	a1,280
ffffffffc02020ec:	00003517          	auipc	a0,0x3
ffffffffc02020f0:	41c50513          	addi	a0,a0,1052 # ffffffffc0205508 <commands+0xe68>
ffffffffc02020f4:	80efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02020f8:	00003697          	auipc	a3,0x3
ffffffffc02020fc:	51068693          	addi	a3,a3,1296 # ffffffffc0205608 <commands+0xf68>
ffffffffc0202100:	00003617          	auipc	a2,0x3
ffffffffc0202104:	cc860613          	addi	a2,a2,-824 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202108:	0c100593          	li	a1,193
ffffffffc020210c:	00003517          	auipc	a0,0x3
ffffffffc0202110:	3fc50513          	addi	a0,a0,1020 # ffffffffc0205508 <commands+0xe68>
ffffffffc0202114:	feffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202118:	00003697          	auipc	a3,0x3
ffffffffc020211c:	6a068693          	addi	a3,a3,1696 # ffffffffc02057b8 <commands+0x1118>
ffffffffc0202120:	00003617          	auipc	a2,0x3
ffffffffc0202124:	ca860613          	addi	a2,a2,-856 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202128:	11200593          	li	a1,274
ffffffffc020212c:	00003517          	auipc	a0,0x3
ffffffffc0202130:	3dc50513          	addi	a0,a0,988 # ffffffffc0205508 <commands+0xe68>
ffffffffc0202134:	fcffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202138:	00003697          	auipc	a3,0x3
ffffffffc020213c:	66068693          	addi	a3,a3,1632 # ffffffffc0205798 <commands+0x10f8>
ffffffffc0202140:	00003617          	auipc	a2,0x3
ffffffffc0202144:	c8860613          	addi	a2,a2,-888 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202148:	11000593          	li	a1,272
ffffffffc020214c:	00003517          	auipc	a0,0x3
ffffffffc0202150:	3bc50513          	addi	a0,a0,956 # ffffffffc0205508 <commands+0xe68>
ffffffffc0202154:	faffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202158:	00003697          	auipc	a3,0x3
ffffffffc020215c:	61868693          	addi	a3,a3,1560 # ffffffffc0205770 <commands+0x10d0>
ffffffffc0202160:	00003617          	auipc	a2,0x3
ffffffffc0202164:	c6860613          	addi	a2,a2,-920 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202168:	10e00593          	li	a1,270
ffffffffc020216c:	00003517          	auipc	a0,0x3
ffffffffc0202170:	39c50513          	addi	a0,a0,924 # ffffffffc0205508 <commands+0xe68>
ffffffffc0202174:	f8ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202178:	00003697          	auipc	a3,0x3
ffffffffc020217c:	5d068693          	addi	a3,a3,1488 # ffffffffc0205748 <commands+0x10a8>
ffffffffc0202180:	00003617          	auipc	a2,0x3
ffffffffc0202184:	c4860613          	addi	a2,a2,-952 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202188:	10d00593          	li	a1,269
ffffffffc020218c:	00003517          	auipc	a0,0x3
ffffffffc0202190:	37c50513          	addi	a0,a0,892 # ffffffffc0205508 <commands+0xe68>
ffffffffc0202194:	f6ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0202198:	00003697          	auipc	a3,0x3
ffffffffc020219c:	5a068693          	addi	a3,a3,1440 # ffffffffc0205738 <commands+0x1098>
ffffffffc02021a0:	00003617          	auipc	a2,0x3
ffffffffc02021a4:	c2860613          	addi	a2,a2,-984 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02021a8:	10800593          	li	a1,264
ffffffffc02021ac:	00003517          	auipc	a0,0x3
ffffffffc02021b0:	35c50513          	addi	a0,a0,860 # ffffffffc0205508 <commands+0xe68>
ffffffffc02021b4:	f4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02021b8:	00003697          	auipc	a3,0x3
ffffffffc02021bc:	49068693          	addi	a3,a3,1168 # ffffffffc0205648 <commands+0xfa8>
ffffffffc02021c0:	00003617          	auipc	a2,0x3
ffffffffc02021c4:	c0860613          	addi	a2,a2,-1016 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02021c8:	10700593          	li	a1,263
ffffffffc02021cc:	00003517          	auipc	a0,0x3
ffffffffc02021d0:	33c50513          	addi	a0,a0,828 # ffffffffc0205508 <commands+0xe68>
ffffffffc02021d4:	f2ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02021d8:	00003697          	auipc	a3,0x3
ffffffffc02021dc:	54068693          	addi	a3,a3,1344 # ffffffffc0205718 <commands+0x1078>
ffffffffc02021e0:	00003617          	auipc	a2,0x3
ffffffffc02021e4:	be860613          	addi	a2,a2,-1048 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02021e8:	10600593          	li	a1,262
ffffffffc02021ec:	00003517          	auipc	a0,0x3
ffffffffc02021f0:	31c50513          	addi	a0,a0,796 # ffffffffc0205508 <commands+0xe68>
ffffffffc02021f4:	f0ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02021f8:	00003697          	auipc	a3,0x3
ffffffffc02021fc:	4f068693          	addi	a3,a3,1264 # ffffffffc02056e8 <commands+0x1048>
ffffffffc0202200:	00003617          	auipc	a2,0x3
ffffffffc0202204:	bc860613          	addi	a2,a2,-1080 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202208:	10500593          	li	a1,261
ffffffffc020220c:	00003517          	auipc	a0,0x3
ffffffffc0202210:	2fc50513          	addi	a0,a0,764 # ffffffffc0205508 <commands+0xe68>
ffffffffc0202214:	eeffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202218:	00003697          	auipc	a3,0x3
ffffffffc020221c:	4b868693          	addi	a3,a3,1208 # ffffffffc02056d0 <commands+0x1030>
ffffffffc0202220:	00003617          	auipc	a2,0x3
ffffffffc0202224:	ba860613          	addi	a2,a2,-1112 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202228:	10400593          	li	a1,260
ffffffffc020222c:	00003517          	auipc	a0,0x3
ffffffffc0202230:	2dc50513          	addi	a0,a0,732 # ffffffffc0205508 <commands+0xe68>
ffffffffc0202234:	ecffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202238:	00003697          	auipc	a3,0x3
ffffffffc020223c:	41068693          	addi	a3,a3,1040 # ffffffffc0205648 <commands+0xfa8>
ffffffffc0202240:	00003617          	auipc	a2,0x3
ffffffffc0202244:	b8860613          	addi	a2,a2,-1144 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202248:	0fe00593          	li	a1,254
ffffffffc020224c:	00003517          	auipc	a0,0x3
ffffffffc0202250:	2bc50513          	addi	a0,a0,700 # ffffffffc0205508 <commands+0xe68>
ffffffffc0202254:	eaffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!PageProperty(p0));
ffffffffc0202258:	00003697          	auipc	a3,0x3
ffffffffc020225c:	46068693          	addi	a3,a3,1120 # ffffffffc02056b8 <commands+0x1018>
ffffffffc0202260:	00003617          	auipc	a2,0x3
ffffffffc0202264:	b6860613          	addi	a2,a2,-1176 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202268:	0f900593          	li	a1,249
ffffffffc020226c:	00003517          	auipc	a0,0x3
ffffffffc0202270:	29c50513          	addi	a0,a0,668 # ffffffffc0205508 <commands+0xe68>
ffffffffc0202274:	e8ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202278:	00003697          	auipc	a3,0x3
ffffffffc020227c:	56068693          	addi	a3,a3,1376 # ffffffffc02057d8 <commands+0x1138>
ffffffffc0202280:	00003617          	auipc	a2,0x3
ffffffffc0202284:	b4860613          	addi	a2,a2,-1208 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202288:	11700593          	li	a1,279
ffffffffc020228c:	00003517          	auipc	a0,0x3
ffffffffc0202290:	27c50513          	addi	a0,a0,636 # ffffffffc0205508 <commands+0xe68>
ffffffffc0202294:	e6ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == 0);
ffffffffc0202298:	00003697          	auipc	a3,0x3
ffffffffc020229c:	57068693          	addi	a3,a3,1392 # ffffffffc0205808 <commands+0x1168>
ffffffffc02022a0:	00003617          	auipc	a2,0x3
ffffffffc02022a4:	b2860613          	addi	a2,a2,-1240 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02022a8:	12600593          	li	a1,294
ffffffffc02022ac:	00003517          	auipc	a0,0x3
ffffffffc02022b0:	25c50513          	addi	a0,a0,604 # ffffffffc0205508 <commands+0xe68>
ffffffffc02022b4:	e4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == nr_free_pages());
ffffffffc02022b8:	00003697          	auipc	a3,0x3
ffffffffc02022bc:	ed868693          	addi	a3,a3,-296 # ffffffffc0205190 <commands+0xaf0>
ffffffffc02022c0:	00003617          	auipc	a2,0x3
ffffffffc02022c4:	b0860613          	addi	a2,a2,-1272 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02022c8:	0f300593          	li	a1,243
ffffffffc02022cc:	00003517          	auipc	a0,0x3
ffffffffc02022d0:	23c50513          	addi	a0,a0,572 # ffffffffc0205508 <commands+0xe68>
ffffffffc02022d4:	e2ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02022d8:	00003697          	auipc	a3,0x3
ffffffffc02022dc:	26868693          	addi	a3,a3,616 # ffffffffc0205540 <commands+0xea0>
ffffffffc02022e0:	00003617          	auipc	a2,0x3
ffffffffc02022e4:	ae860613          	addi	a2,a2,-1304 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02022e8:	0ba00593          	li	a1,186
ffffffffc02022ec:	00003517          	auipc	a0,0x3
ffffffffc02022f0:	21c50513          	addi	a0,a0,540 # ffffffffc0205508 <commands+0xe68>
ffffffffc02022f4:	e0ffd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02022f8 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02022f8:	1141                	addi	sp,sp,-16
ffffffffc02022fa:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02022fc:	14058a63          	beqz	a1,ffffffffc0202450 <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0202300:	00359693          	slli	a3,a1,0x3
ffffffffc0202304:	96ae                	add	a3,a3,a1
ffffffffc0202306:	068e                	slli	a3,a3,0x3
ffffffffc0202308:	96aa                	add	a3,a3,a0
ffffffffc020230a:	87aa                	mv	a5,a0
ffffffffc020230c:	02d50263          	beq	a0,a3,ffffffffc0202330 <default_free_pages+0x38>
ffffffffc0202310:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202312:	8b05                	andi	a4,a4,1
ffffffffc0202314:	10071e63          	bnez	a4,ffffffffc0202430 <default_free_pages+0x138>
ffffffffc0202318:	6798                	ld	a4,8(a5)
ffffffffc020231a:	8b09                	andi	a4,a4,2
ffffffffc020231c:	10071a63          	bnez	a4,ffffffffc0202430 <default_free_pages+0x138>
        p->flags = 0;
ffffffffc0202320:	0007b423          	sd	zero,8(a5)
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202324:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202328:	04878793          	addi	a5,a5,72
ffffffffc020232c:	fed792e3          	bne	a5,a3,ffffffffc0202310 <default_free_pages+0x18>
    base->property = n;
ffffffffc0202330:	2581                	sext.w	a1,a1
ffffffffc0202332:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0202334:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202338:	4789                	li	a5,2
ffffffffc020233a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020233e:	0000f697          	auipc	a3,0xf
ffffffffc0202342:	d9268693          	addi	a3,a3,-622 # ffffffffc02110d0 <free_area>
ffffffffc0202346:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202348:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020234a:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc020234e:	9db9                	addw	a1,a1,a4
ffffffffc0202350:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202352:	0ad78863          	beq	a5,a3,ffffffffc0202402 <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0202356:	fe078713          	addi	a4,a5,-32
ffffffffc020235a:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020235e:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202360:	00e56a63          	bltu	a0,a4,ffffffffc0202374 <default_free_pages+0x7c>
    return listelm->next;
ffffffffc0202364:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202366:	06d70263          	beq	a4,a3,ffffffffc02023ca <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc020236a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020236c:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0202370:	fee57ae3          	bgeu	a0,a4,ffffffffc0202364 <default_free_pages+0x6c>
ffffffffc0202374:	c199                	beqz	a1,ffffffffc020237a <default_free_pages+0x82>
ffffffffc0202376:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020237a:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc020237c:	e390                	sd	a2,0(a5)
ffffffffc020237e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202380:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202382:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc0202384:	02d70063          	beq	a4,a3,ffffffffc02023a4 <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0202388:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc020238c:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc0202390:	02081613          	slli	a2,a6,0x20
ffffffffc0202394:	9201                	srli	a2,a2,0x20
ffffffffc0202396:	00361793          	slli	a5,a2,0x3
ffffffffc020239a:	97b2                	add	a5,a5,a2
ffffffffc020239c:	078e                	slli	a5,a5,0x3
ffffffffc020239e:	97ae                	add	a5,a5,a1
ffffffffc02023a0:	02f50f63          	beq	a0,a5,ffffffffc02023de <default_free_pages+0xe6>
    return listelm->next;
ffffffffc02023a4:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc02023a6:	00d70f63          	beq	a4,a3,ffffffffc02023c4 <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc02023aa:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc02023ac:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc02023b0:	02059613          	slli	a2,a1,0x20
ffffffffc02023b4:	9201                	srli	a2,a2,0x20
ffffffffc02023b6:	00361793          	slli	a5,a2,0x3
ffffffffc02023ba:	97b2                	add	a5,a5,a2
ffffffffc02023bc:	078e                	slli	a5,a5,0x3
ffffffffc02023be:	97aa                	add	a5,a5,a0
ffffffffc02023c0:	04f68863          	beq	a3,a5,ffffffffc0202410 <default_free_pages+0x118>
}
ffffffffc02023c4:	60a2                	ld	ra,8(sp)
ffffffffc02023c6:	0141                	addi	sp,sp,16
ffffffffc02023c8:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02023ca:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02023cc:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc02023ce:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02023d0:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02023d2:	02d70563          	beq	a4,a3,ffffffffc02023fc <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc02023d6:	8832                	mv	a6,a2
ffffffffc02023d8:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02023da:	87ba                	mv	a5,a4
ffffffffc02023dc:	bf41                	j	ffffffffc020236c <default_free_pages+0x74>
            p->property += base->property;
ffffffffc02023de:	4d1c                	lw	a5,24(a0)
ffffffffc02023e0:	0107883b          	addw	a6,a5,a6
ffffffffc02023e4:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02023e8:	57f5                	li	a5,-3
ffffffffc02023ea:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02023ee:	7110                	ld	a2,32(a0)
ffffffffc02023f0:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc02023f2:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc02023f4:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02023f6:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02023f8:	e390                	sd	a2,0(a5)
ffffffffc02023fa:	b775                	j	ffffffffc02023a6 <default_free_pages+0xae>
ffffffffc02023fc:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02023fe:	873e                	mv	a4,a5
ffffffffc0202400:	b761                	j	ffffffffc0202388 <default_free_pages+0x90>
}
ffffffffc0202402:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202404:	e390                	sd	a2,0(a5)
ffffffffc0202406:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202408:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020240a:	f11c                	sd	a5,32(a0)
ffffffffc020240c:	0141                	addi	sp,sp,16
ffffffffc020240e:	8082                	ret
            base->property += p->property;
ffffffffc0202410:	ff872783          	lw	a5,-8(a4)
ffffffffc0202414:	fe870693          	addi	a3,a4,-24
ffffffffc0202418:	9dbd                	addw	a1,a1,a5
ffffffffc020241a:	cd0c                	sw	a1,24(a0)
ffffffffc020241c:	57f5                	li	a5,-3
ffffffffc020241e:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202422:	6314                	ld	a3,0(a4)
ffffffffc0202424:	671c                	ld	a5,8(a4)
}
ffffffffc0202426:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0202428:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc020242a:	e394                	sd	a3,0(a5)
ffffffffc020242c:	0141                	addi	sp,sp,16
ffffffffc020242e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202430:	00003697          	auipc	a3,0x3
ffffffffc0202434:	3f068693          	addi	a3,a3,1008 # ffffffffc0205820 <commands+0x1180>
ffffffffc0202438:	00003617          	auipc	a2,0x3
ffffffffc020243c:	99060613          	addi	a2,a2,-1648 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202440:	08300593          	li	a1,131
ffffffffc0202444:	00003517          	auipc	a0,0x3
ffffffffc0202448:	0c450513          	addi	a0,a0,196 # ffffffffc0205508 <commands+0xe68>
ffffffffc020244c:	cb7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc0202450:	00003697          	auipc	a3,0x3
ffffffffc0202454:	3c868693          	addi	a3,a3,968 # ffffffffc0205818 <commands+0x1178>
ffffffffc0202458:	00003617          	auipc	a2,0x3
ffffffffc020245c:	97060613          	addi	a2,a2,-1680 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202460:	08000593          	li	a1,128
ffffffffc0202464:	00003517          	auipc	a0,0x3
ffffffffc0202468:	0a450513          	addi	a0,a0,164 # ffffffffc0205508 <commands+0xe68>
ffffffffc020246c:	c97fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202470 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0202470:	c959                	beqz	a0,ffffffffc0202506 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0202472:	0000f597          	auipc	a1,0xf
ffffffffc0202476:	c5e58593          	addi	a1,a1,-930 # ffffffffc02110d0 <free_area>
ffffffffc020247a:	0105a803          	lw	a6,16(a1)
ffffffffc020247e:	862a                	mv	a2,a0
ffffffffc0202480:	02081793          	slli	a5,a6,0x20
ffffffffc0202484:	9381                	srli	a5,a5,0x20
ffffffffc0202486:	00a7ee63          	bltu	a5,a0,ffffffffc02024a2 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020248a:	87ae                	mv	a5,a1
ffffffffc020248c:	a801                	j	ffffffffc020249c <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020248e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202492:	02071693          	slli	a3,a4,0x20
ffffffffc0202496:	9281                	srli	a3,a3,0x20
ffffffffc0202498:	00c6f763          	bgeu	a3,a2,ffffffffc02024a6 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc020249c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020249e:	feb798e3          	bne	a5,a1,ffffffffc020248e <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02024a2:	4501                	li	a0,0
}
ffffffffc02024a4:	8082                	ret
    return listelm->prev;
ffffffffc02024a6:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02024aa:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02024ae:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc02024b2:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc02024b6:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02024ba:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02024be:	02d67b63          	bgeu	a2,a3,ffffffffc02024f4 <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc02024c2:	00361693          	slli	a3,a2,0x3
ffffffffc02024c6:	96b2                	add	a3,a3,a2
ffffffffc02024c8:	068e                	slli	a3,a3,0x3
ffffffffc02024ca:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02024cc:	41c7073b          	subw	a4,a4,t3
ffffffffc02024d0:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02024d2:	00868613          	addi	a2,a3,8
ffffffffc02024d6:	4709                	li	a4,2
ffffffffc02024d8:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02024dc:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02024e0:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc02024e4:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02024e8:	e310                	sd	a2,0(a4)
ffffffffc02024ea:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02024ee:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc02024f0:	0316b023          	sd	a7,32(a3)
ffffffffc02024f4:	41c8083b          	subw	a6,a6,t3
ffffffffc02024f8:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02024fc:	5775                	li	a4,-3
ffffffffc02024fe:	17a1                	addi	a5,a5,-24
ffffffffc0202500:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0202504:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0202506:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202508:	00003697          	auipc	a3,0x3
ffffffffc020250c:	31068693          	addi	a3,a3,784 # ffffffffc0205818 <commands+0x1178>
ffffffffc0202510:	00003617          	auipc	a2,0x3
ffffffffc0202514:	8b860613          	addi	a2,a2,-1864 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202518:	06200593          	li	a1,98
ffffffffc020251c:	00003517          	auipc	a0,0x3
ffffffffc0202520:	fec50513          	addi	a0,a0,-20 # ffffffffc0205508 <commands+0xe68>
default_alloc_pages(size_t n) {
ffffffffc0202524:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202526:	bddfd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc020252a <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020252a:	1141                	addi	sp,sp,-16
ffffffffc020252c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020252e:	c9e1                	beqz	a1,ffffffffc02025fe <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0202530:	00359693          	slli	a3,a1,0x3
ffffffffc0202534:	96ae                	add	a3,a3,a1
ffffffffc0202536:	068e                	slli	a3,a3,0x3
ffffffffc0202538:	96aa                	add	a3,a3,a0
ffffffffc020253a:	87aa                	mv	a5,a0
ffffffffc020253c:	00d50f63          	beq	a0,a3,ffffffffc020255a <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202540:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0202542:	8b05                	andi	a4,a4,1
ffffffffc0202544:	cf49                	beqz	a4,ffffffffc02025de <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0202546:	0007ac23          	sw	zero,24(a5)
ffffffffc020254a:	0007b423          	sd	zero,8(a5)
ffffffffc020254e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202552:	04878793          	addi	a5,a5,72
ffffffffc0202556:	fed795e3          	bne	a5,a3,ffffffffc0202540 <default_init_memmap+0x16>
    base->property = n;
ffffffffc020255a:	2581                	sext.w	a1,a1
ffffffffc020255c:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020255e:	4789                	li	a5,2
ffffffffc0202560:	00850713          	addi	a4,a0,8
ffffffffc0202564:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0202568:	0000f697          	auipc	a3,0xf
ffffffffc020256c:	b6868693          	addi	a3,a3,-1176 # ffffffffc02110d0 <free_area>
ffffffffc0202570:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202572:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202574:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0202578:	9db9                	addw	a1,a1,a4
ffffffffc020257a:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020257c:	04d78a63          	beq	a5,a3,ffffffffc02025d0 <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0202580:	fe078713          	addi	a4,a5,-32
ffffffffc0202584:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202588:	4581                	li	a1,0
            if (base < page) {
ffffffffc020258a:	00e56a63          	bltu	a0,a4,ffffffffc020259e <default_init_memmap+0x74>
    return listelm->next;
ffffffffc020258e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202590:	02d70263          	beq	a4,a3,ffffffffc02025b4 <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0202594:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202596:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc020259a:	fee57ae3          	bgeu	a0,a4,ffffffffc020258e <default_init_memmap+0x64>
ffffffffc020259e:	c199                	beqz	a1,ffffffffc02025a4 <default_init_memmap+0x7a>
ffffffffc02025a0:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02025a4:	6398                	ld	a4,0(a5)
}
ffffffffc02025a6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02025a8:	e390                	sd	a2,0(a5)
ffffffffc02025aa:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02025ac:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02025ae:	f118                	sd	a4,32(a0)
ffffffffc02025b0:	0141                	addi	sp,sp,16
ffffffffc02025b2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02025b4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02025b6:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc02025b8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02025ba:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02025bc:	00d70663          	beq	a4,a3,ffffffffc02025c8 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02025c0:	8832                	mv	a6,a2
ffffffffc02025c2:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02025c4:	87ba                	mv	a5,a4
ffffffffc02025c6:	bfc1                	j	ffffffffc0202596 <default_init_memmap+0x6c>
}
ffffffffc02025c8:	60a2                	ld	ra,8(sp)
ffffffffc02025ca:	e290                	sd	a2,0(a3)
ffffffffc02025cc:	0141                	addi	sp,sp,16
ffffffffc02025ce:	8082                	ret
ffffffffc02025d0:	60a2                	ld	ra,8(sp)
ffffffffc02025d2:	e390                	sd	a2,0(a5)
ffffffffc02025d4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02025d6:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02025d8:	f11c                	sd	a5,32(a0)
ffffffffc02025da:	0141                	addi	sp,sp,16
ffffffffc02025dc:	8082                	ret
        assert(PageReserved(p));
ffffffffc02025de:	00003697          	auipc	a3,0x3
ffffffffc02025e2:	26a68693          	addi	a3,a3,618 # ffffffffc0205848 <commands+0x11a8>
ffffffffc02025e6:	00002617          	auipc	a2,0x2
ffffffffc02025ea:	7e260613          	addi	a2,a2,2018 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02025ee:	04900593          	li	a1,73
ffffffffc02025f2:	00003517          	auipc	a0,0x3
ffffffffc02025f6:	f1650513          	addi	a0,a0,-234 # ffffffffc0205508 <commands+0xe68>
ffffffffc02025fa:	b09fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc02025fe:	00003697          	auipc	a3,0x3
ffffffffc0202602:	21a68693          	addi	a3,a3,538 # ffffffffc0205818 <commands+0x1178>
ffffffffc0202606:	00002617          	auipc	a2,0x2
ffffffffc020260a:	7c260613          	addi	a2,a2,1986 # ffffffffc0204dc8 <commands+0x728>
ffffffffc020260e:	04600593          	li	a1,70
ffffffffc0202612:	00003517          	auipc	a0,0x3
ffffffffc0202616:	ef650513          	addi	a0,a0,-266 # ffffffffc0205508 <commands+0xe68>
ffffffffc020261a:	ae9fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc020261e <_clock_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020261e:	0000f797          	auipc	a5,0xf
ffffffffc0202622:	aca78793          	addi	a5,a5,-1334 # ffffffffc02110e8 <pra_list_head>
    // 初始化pra_list_head为空链表
    list_init(&pra_list_head);
    // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
    curr_ptr = &pra_list_head;
    // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
    mm->sm_priv = &pra_list_head;
ffffffffc0202626:	f51c                	sd	a5,40(a0)
ffffffffc0202628:	e79c                	sd	a5,8(a5)
ffffffffc020262a:	e39c                	sd	a5,0(a5)
    curr_ptr = &pra_list_head;
ffffffffc020262c:	0000f717          	auipc	a4,0xf
ffffffffc0202630:	f0f73623          	sd	a5,-244(a4) # ffffffffc0211538 <curr_ptr>
    //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
//################################################################################
    return 0;
}
ffffffffc0202634:	4501                	li	a0,0
ffffffffc0202636:	8082                	ret

ffffffffc0202638 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc0202638:	4501                	li	a0,0
ffffffffc020263a:	8082                	ret

ffffffffc020263c <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc020263c:	4501                	li	a0,0
ffffffffc020263e:	8082                	ret

ffffffffc0202640 <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0202640:	4501                	li	a0,0
ffffffffc0202642:	8082                	ret

ffffffffc0202644 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc0202644:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202646:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc0202648:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020264a:	678d                	lui	a5,0x3
ffffffffc020264c:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0202650:	0000f697          	auipc	a3,0xf
ffffffffc0202654:	ec86a683          	lw	a3,-312(a3) # ffffffffc0211518 <pgfault_num>
ffffffffc0202658:	4711                	li	a4,4
ffffffffc020265a:	0ae69363          	bne	a3,a4,ffffffffc0202700 <_clock_check_swap+0xbc>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020265e:	6705                	lui	a4,0x1
ffffffffc0202660:	4629                	li	a2,10
ffffffffc0202662:	0000f797          	auipc	a5,0xf
ffffffffc0202666:	eb678793          	addi	a5,a5,-330 # ffffffffc0211518 <pgfault_num>
ffffffffc020266a:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc020266e:	4398                	lw	a4,0(a5)
ffffffffc0202670:	2701                	sext.w	a4,a4
ffffffffc0202672:	20d71763          	bne	a4,a3,ffffffffc0202880 <_clock_check_swap+0x23c>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202676:	6691                	lui	a3,0x4
ffffffffc0202678:	4635                	li	a2,13
ffffffffc020267a:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc020267e:	4394                	lw	a3,0(a5)
ffffffffc0202680:	2681                	sext.w	a3,a3
ffffffffc0202682:	1ce69f63          	bne	a3,a4,ffffffffc0202860 <_clock_check_swap+0x21c>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202686:	6709                	lui	a4,0x2
ffffffffc0202688:	462d                	li	a2,11
ffffffffc020268a:	00c70023          	sb	a2,0(a4) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc020268e:	4398                	lw	a4,0(a5)
ffffffffc0202690:	2701                	sext.w	a4,a4
ffffffffc0202692:	1ad71763          	bne	a4,a3,ffffffffc0202840 <_clock_check_swap+0x1fc>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0202696:	6715                	lui	a4,0x5
ffffffffc0202698:	46b9                	li	a3,14
ffffffffc020269a:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc020269e:	4398                	lw	a4,0(a5)
ffffffffc02026a0:	4695                	li	a3,5
ffffffffc02026a2:	2701                	sext.w	a4,a4
ffffffffc02026a4:	16d71e63          	bne	a4,a3,ffffffffc0202820 <_clock_check_swap+0x1dc>
    assert(pgfault_num==5);
ffffffffc02026a8:	4394                	lw	a3,0(a5)
ffffffffc02026aa:	2681                	sext.w	a3,a3
ffffffffc02026ac:	14e69a63          	bne	a3,a4,ffffffffc0202800 <_clock_check_swap+0x1bc>
    assert(pgfault_num==5);
ffffffffc02026b0:	4398                	lw	a4,0(a5)
ffffffffc02026b2:	2701                	sext.w	a4,a4
ffffffffc02026b4:	12d71663          	bne	a4,a3,ffffffffc02027e0 <_clock_check_swap+0x19c>
    assert(pgfault_num==5);
ffffffffc02026b8:	4394                	lw	a3,0(a5)
ffffffffc02026ba:	2681                	sext.w	a3,a3
ffffffffc02026bc:	10e69263          	bne	a3,a4,ffffffffc02027c0 <_clock_check_swap+0x17c>
    assert(pgfault_num==5);
ffffffffc02026c0:	4398                	lw	a4,0(a5)
ffffffffc02026c2:	2701                	sext.w	a4,a4
ffffffffc02026c4:	0cd71e63          	bne	a4,a3,ffffffffc02027a0 <_clock_check_swap+0x15c>
    assert(pgfault_num==5);
ffffffffc02026c8:	4394                	lw	a3,0(a5)
ffffffffc02026ca:	2681                	sext.w	a3,a3
ffffffffc02026cc:	0ae69a63          	bne	a3,a4,ffffffffc0202780 <_clock_check_swap+0x13c>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02026d0:	6715                	lui	a4,0x5
ffffffffc02026d2:	46b9                	li	a3,14
ffffffffc02026d4:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02026d8:	4398                	lw	a4,0(a5)
ffffffffc02026da:	4695                	li	a3,5
ffffffffc02026dc:	2701                	sext.w	a4,a4
ffffffffc02026de:	08d71163          	bne	a4,a3,ffffffffc0202760 <_clock_check_swap+0x11c>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02026e2:	6705                	lui	a4,0x1
ffffffffc02026e4:	00074683          	lbu	a3,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02026e8:	4729                	li	a4,10
ffffffffc02026ea:	04e69b63          	bne	a3,a4,ffffffffc0202740 <_clock_check_swap+0xfc>
    assert(pgfault_num==6);
ffffffffc02026ee:	439c                	lw	a5,0(a5)
ffffffffc02026f0:	4719                	li	a4,6
ffffffffc02026f2:	2781                	sext.w	a5,a5
ffffffffc02026f4:	02e79663          	bne	a5,a4,ffffffffc0202720 <_clock_check_swap+0xdc>
}
ffffffffc02026f8:	60a2                	ld	ra,8(sp)
ffffffffc02026fa:	4501                	li	a0,0
ffffffffc02026fc:	0141                	addi	sp,sp,16
ffffffffc02026fe:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0202700:	00003697          	auipc	a3,0x3
ffffffffc0202704:	c2068693          	addi	a3,a3,-992 # ffffffffc0205320 <commands+0xc80>
ffffffffc0202708:	00002617          	auipc	a2,0x2
ffffffffc020270c:	6c060613          	addi	a2,a2,1728 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202710:	0d000593          	li	a1,208
ffffffffc0202714:	00003517          	auipc	a0,0x3
ffffffffc0202718:	19450513          	addi	a0,a0,404 # ffffffffc02058a8 <default_pmm_manager+0x38>
ffffffffc020271c:	9e7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==6);
ffffffffc0202720:	00003697          	auipc	a3,0x3
ffffffffc0202724:	1d868693          	addi	a3,a3,472 # ffffffffc02058f8 <default_pmm_manager+0x88>
ffffffffc0202728:	00002617          	auipc	a2,0x2
ffffffffc020272c:	6a060613          	addi	a2,a2,1696 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202730:	0e700593          	li	a1,231
ffffffffc0202734:	00003517          	auipc	a0,0x3
ffffffffc0202738:	17450513          	addi	a0,a0,372 # ffffffffc02058a8 <default_pmm_manager+0x38>
ffffffffc020273c:	9c7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0202740:	00003697          	auipc	a3,0x3
ffffffffc0202744:	19068693          	addi	a3,a3,400 # ffffffffc02058d0 <default_pmm_manager+0x60>
ffffffffc0202748:	00002617          	auipc	a2,0x2
ffffffffc020274c:	68060613          	addi	a2,a2,1664 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202750:	0e500593          	li	a1,229
ffffffffc0202754:	00003517          	auipc	a0,0x3
ffffffffc0202758:	15450513          	addi	a0,a0,340 # ffffffffc02058a8 <default_pmm_manager+0x38>
ffffffffc020275c:	9a7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0202760:	00003697          	auipc	a3,0x3
ffffffffc0202764:	16068693          	addi	a3,a3,352 # ffffffffc02058c0 <default_pmm_manager+0x50>
ffffffffc0202768:	00002617          	auipc	a2,0x2
ffffffffc020276c:	66060613          	addi	a2,a2,1632 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202770:	0e400593          	li	a1,228
ffffffffc0202774:	00003517          	auipc	a0,0x3
ffffffffc0202778:	13450513          	addi	a0,a0,308 # ffffffffc02058a8 <default_pmm_manager+0x38>
ffffffffc020277c:	987fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0202780:	00003697          	auipc	a3,0x3
ffffffffc0202784:	14068693          	addi	a3,a3,320 # ffffffffc02058c0 <default_pmm_manager+0x50>
ffffffffc0202788:	00002617          	auipc	a2,0x2
ffffffffc020278c:	64060613          	addi	a2,a2,1600 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202790:	0e200593          	li	a1,226
ffffffffc0202794:	00003517          	auipc	a0,0x3
ffffffffc0202798:	11450513          	addi	a0,a0,276 # ffffffffc02058a8 <default_pmm_manager+0x38>
ffffffffc020279c:	967fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc02027a0:	00003697          	auipc	a3,0x3
ffffffffc02027a4:	12068693          	addi	a3,a3,288 # ffffffffc02058c0 <default_pmm_manager+0x50>
ffffffffc02027a8:	00002617          	auipc	a2,0x2
ffffffffc02027ac:	62060613          	addi	a2,a2,1568 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02027b0:	0e000593          	li	a1,224
ffffffffc02027b4:	00003517          	auipc	a0,0x3
ffffffffc02027b8:	0f450513          	addi	a0,a0,244 # ffffffffc02058a8 <default_pmm_manager+0x38>
ffffffffc02027bc:	947fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc02027c0:	00003697          	auipc	a3,0x3
ffffffffc02027c4:	10068693          	addi	a3,a3,256 # ffffffffc02058c0 <default_pmm_manager+0x50>
ffffffffc02027c8:	00002617          	auipc	a2,0x2
ffffffffc02027cc:	60060613          	addi	a2,a2,1536 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02027d0:	0de00593          	li	a1,222
ffffffffc02027d4:	00003517          	auipc	a0,0x3
ffffffffc02027d8:	0d450513          	addi	a0,a0,212 # ffffffffc02058a8 <default_pmm_manager+0x38>
ffffffffc02027dc:	927fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc02027e0:	00003697          	auipc	a3,0x3
ffffffffc02027e4:	0e068693          	addi	a3,a3,224 # ffffffffc02058c0 <default_pmm_manager+0x50>
ffffffffc02027e8:	00002617          	auipc	a2,0x2
ffffffffc02027ec:	5e060613          	addi	a2,a2,1504 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02027f0:	0dc00593          	li	a1,220
ffffffffc02027f4:	00003517          	auipc	a0,0x3
ffffffffc02027f8:	0b450513          	addi	a0,a0,180 # ffffffffc02058a8 <default_pmm_manager+0x38>
ffffffffc02027fc:	907fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0202800:	00003697          	auipc	a3,0x3
ffffffffc0202804:	0c068693          	addi	a3,a3,192 # ffffffffc02058c0 <default_pmm_manager+0x50>
ffffffffc0202808:	00002617          	auipc	a2,0x2
ffffffffc020280c:	5c060613          	addi	a2,a2,1472 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202810:	0da00593          	li	a1,218
ffffffffc0202814:	00003517          	auipc	a0,0x3
ffffffffc0202818:	09450513          	addi	a0,a0,148 # ffffffffc02058a8 <default_pmm_manager+0x38>
ffffffffc020281c:	8e7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc0202820:	00003697          	auipc	a3,0x3
ffffffffc0202824:	0a068693          	addi	a3,a3,160 # ffffffffc02058c0 <default_pmm_manager+0x50>
ffffffffc0202828:	00002617          	auipc	a2,0x2
ffffffffc020282c:	5a060613          	addi	a2,a2,1440 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202830:	0d800593          	li	a1,216
ffffffffc0202834:	00003517          	auipc	a0,0x3
ffffffffc0202838:	07450513          	addi	a0,a0,116 # ffffffffc02058a8 <default_pmm_manager+0x38>
ffffffffc020283c:	8c7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0202840:	00003697          	auipc	a3,0x3
ffffffffc0202844:	ae068693          	addi	a3,a3,-1312 # ffffffffc0205320 <commands+0xc80>
ffffffffc0202848:	00002617          	auipc	a2,0x2
ffffffffc020284c:	58060613          	addi	a2,a2,1408 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202850:	0d600593          	li	a1,214
ffffffffc0202854:	00003517          	auipc	a0,0x3
ffffffffc0202858:	05450513          	addi	a0,a0,84 # ffffffffc02058a8 <default_pmm_manager+0x38>
ffffffffc020285c:	8a7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0202860:	00003697          	auipc	a3,0x3
ffffffffc0202864:	ac068693          	addi	a3,a3,-1344 # ffffffffc0205320 <commands+0xc80>
ffffffffc0202868:	00002617          	auipc	a2,0x2
ffffffffc020286c:	56060613          	addi	a2,a2,1376 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202870:	0d400593          	li	a1,212
ffffffffc0202874:	00003517          	auipc	a0,0x3
ffffffffc0202878:	03450513          	addi	a0,a0,52 # ffffffffc02058a8 <default_pmm_manager+0x38>
ffffffffc020287c:	887fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0202880:	00003697          	auipc	a3,0x3
ffffffffc0202884:	aa068693          	addi	a3,a3,-1376 # ffffffffc0205320 <commands+0xc80>
ffffffffc0202888:	00002617          	auipc	a2,0x2
ffffffffc020288c:	54060613          	addi	a2,a2,1344 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202890:	0d200593          	li	a1,210
ffffffffc0202894:	00003517          	auipc	a0,0x3
ffffffffc0202898:	01450513          	addi	a0,a0,20 # ffffffffc02058a8 <default_pmm_manager+0x38>
ffffffffc020289c:	867fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02028a0 <_clock_swap_out_victim>:
{
ffffffffc02028a0:	7139                	addi	sp,sp,-64
ffffffffc02028a2:	f426                	sd	s1,40(sp)
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02028a4:	7504                	ld	s1,40(a0)
{
ffffffffc02028a6:	fc06                	sd	ra,56(sp)
ffffffffc02028a8:	f822                	sd	s0,48(sp)
ffffffffc02028aa:	f04a                	sd	s2,32(sp)
ffffffffc02028ac:	ec4e                	sd	s3,24(sp)
ffffffffc02028ae:	e852                	sd	s4,16(sp)
ffffffffc02028b0:	e456                	sd	s5,8(sp)
    assert(head != NULL);
ffffffffc02028b2:	c0dd                	beqz	s1,ffffffffc0202958 <_clock_swap_out_victim+0xb8>
ffffffffc02028b4:	89ae                	mv	s3,a1
    assert(in_tick==0);
ffffffffc02028b6:	0000fa97          	auipc	s5,0xf
ffffffffc02028ba:	c82a8a93          	addi	s5,s5,-894 # ffffffffc0211538 <curr_ptr>
 */
static void update_visited(struct Page* page)
{
    //cprintf("[调试信息]update_visited()\n");
    extern pde_t *boot_pgdir;
    uintptr_t la = ROUNDDOWN(page->pra_vaddr, PGSIZE);
ffffffffc02028be:	7a7d                	lui	s4,0xfffff
    pte_t *ptep = get_pte(boot_pgdir, la, 1); // 获取指向页表中对应页表项的指针
ffffffffc02028c0:	0000f917          	auipc	s2,0xf
ffffffffc02028c4:	c8890913          	addi	s2,s2,-888 # ffffffffc0211548 <boot_pgdir>
ffffffffc02028c8:	ea45                	bnez	a2,ffffffffc0202978 <_clock_swap_out_victim+0xd8>
    return listelm->next;
ffffffffc02028ca:	000ab783          	ld	a5,0(s5)
ffffffffc02028ce:	6780                	ld	s0,8(a5)
        curr_ptr = list_next(curr_ptr);  
ffffffffc02028d0:	008ab023          	sd	s0,0(s5)
        if(curr_ptr==head) curr_ptr = list_next(curr_ptr);
ffffffffc02028d4:	06848a63          	beq	s1,s0,ffffffffc0202948 <_clock_swap_out_victim+0xa8>
    uintptr_t la = ROUNDDOWN(page->pra_vaddr, PGSIZE);
ffffffffc02028d8:	680c                	ld	a1,16(s0)
    pte_t *ptep = get_pte(boot_pgdir, la, 1); // 获取指向页表中对应页表项的指针
ffffffffc02028da:	00093503          	ld	a0,0(s2)
ffffffffc02028de:	4605                	li	a2,1
ffffffffc02028e0:	00ba75b3          	and	a1,s4,a1
ffffffffc02028e4:	23e000ef          	jal	ra,ffffffffc0202b22 <get_pte>
    //cprintf("[调试信息]页表项=%x\n",(*ptep));
    page->visited = ((*ptep)>>6)&1;
ffffffffc02028e8:	611c                	ld	a5,0(a0)
ffffffffc02028ea:	8399                	srli	a5,a5,0x6
ffffffffc02028ec:	8b85                	andi	a5,a5,1
ffffffffc02028ee:	fef43023          	sd	a5,-32(s0)
    //cprintf("[调试信息]0x%x的page->visited=%d\n",page->pra_vaddr,page->visited);
    if(page->visited==1) *ptep = (*ptep) - 64;
ffffffffc02028f2:	eb9d                	bnez	a5,ffffffffc0202928 <_clock_swap_out_victim+0x88>
            list_del(curr_ptr);
ffffffffc02028f4:	000ab583          	ld	a1,0(s5)
        struct Page* page = le2page(curr_ptr, pra_page_link);
ffffffffc02028f8:	fd040413          	addi	s0,s0,-48
            cprintf("curr_ptr %p\n",curr_ptr);
ffffffffc02028fc:	00003517          	auipc	a0,0x3
ffffffffc0202900:	02c50513          	addi	a0,a0,44 # ffffffffc0205928 <default_pmm_manager+0xb8>
    __list_del(listelm->prev, listelm->next);
ffffffffc0202904:	6198                	ld	a4,0(a1)
ffffffffc0202906:	659c                	ld	a5,8(a1)
    prev->next = next;
ffffffffc0202908:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020290a:	e398                	sd	a4,0(a5)
            *ptr_page = page;
ffffffffc020290c:	0089b023          	sd	s0,0(s3)
            cprintf("curr_ptr %p\n",curr_ptr);
ffffffffc0202910:	faafd0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0202914:	70e2                	ld	ra,56(sp)
ffffffffc0202916:	7442                	ld	s0,48(sp)
ffffffffc0202918:	74a2                	ld	s1,40(sp)
ffffffffc020291a:	7902                	ld	s2,32(sp)
ffffffffc020291c:	69e2                	ld	s3,24(sp)
ffffffffc020291e:	6a42                	ld	s4,16(sp)
ffffffffc0202920:	6aa2                	ld	s5,8(sp)
ffffffffc0202922:	4501                	li	a0,0
ffffffffc0202924:	6121                	addi	sp,sp,64
ffffffffc0202926:	8082                	ret
ffffffffc0202928:	611c                	ld	a5,0(a0)
ffffffffc020292a:	fc078793          	addi	a5,a5,-64
ffffffffc020292e:	e11c                	sd	a5,0(a0)
        if( page->visited==0 )
ffffffffc0202930:	fe043783          	ld	a5,-32(s0)
ffffffffc0202934:	d3e1                	beqz	a5,ffffffffc02028f4 <_clock_swap_out_victim+0x54>
    return listelm->next;
ffffffffc0202936:	000ab783          	ld	a5,0(s5)
        page->visited = 0;
ffffffffc020293a:	fe043023          	sd	zero,-32(s0)
ffffffffc020293e:	6780                	ld	s0,8(a5)
        curr_ptr = list_next(curr_ptr);  
ffffffffc0202940:	008ab023          	sd	s0,0(s5)
        if(curr_ptr==head) curr_ptr = list_next(curr_ptr);
ffffffffc0202944:	f8849ae3          	bne	s1,s0,ffffffffc02028d8 <_clock_swap_out_victim+0x38>
ffffffffc0202948:	6480                	ld	s0,8(s1)
ffffffffc020294a:	008ab023          	sd	s0,0(s5)
        if(curr_ptr==head) 
ffffffffc020294e:	f88495e3          	bne	s1,s0,ffffffffc02028d8 <_clock_swap_out_victim+0x38>
            *ptr_page = NULL;
ffffffffc0202952:	0009b023          	sd	zero,0(s3)
            break;
ffffffffc0202956:	bf7d                	j	ffffffffc0202914 <_clock_swap_out_victim+0x74>
    assert(head != NULL);
ffffffffc0202958:	00003697          	auipc	a3,0x3
ffffffffc020295c:	fb068693          	addi	a3,a3,-80 # ffffffffc0205908 <default_pmm_manager+0x98>
ffffffffc0202960:	00002617          	auipc	a2,0x2
ffffffffc0202964:	46860613          	addi	a2,a2,1128 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202968:	05200593          	li	a1,82
ffffffffc020296c:	00003517          	auipc	a0,0x3
ffffffffc0202970:	f3c50513          	addi	a0,a0,-196 # ffffffffc02058a8 <default_pmm_manager+0x38>
ffffffffc0202974:	f8efd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(in_tick==0);
ffffffffc0202978:	00003697          	auipc	a3,0x3
ffffffffc020297c:	fa068693          	addi	a3,a3,-96 # ffffffffc0205918 <default_pmm_manager+0xa8>
ffffffffc0202980:	00002617          	auipc	a2,0x2
ffffffffc0202984:	44860613          	addi	a2,a2,1096 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0202988:	05300593          	li	a1,83
ffffffffc020298c:	00003517          	auipc	a0,0x3
ffffffffc0202990:	f1c50513          	addi	a0,a0,-228 # ffffffffc02058a8 <default_pmm_manager+0x38>
ffffffffc0202994:	f6efd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202998 <_clock_map_swappable>:
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0202998:	0000f797          	auipc	a5,0xf
ffffffffc020299c:	ba07b783          	ld	a5,-1120(a5) # ffffffffc0211538 <curr_ptr>
ffffffffc02029a0:	cf89                	beqz	a5,ffffffffc02029ba <_clock_map_swappable+0x22>
    list_add_before((list_entry_t*)mm->sm_priv,entry);  //1.将页面page插入到页面链表pra_list_head的末尾
ffffffffc02029a2:	751c                	ld	a5,40(a0)
ffffffffc02029a4:	03060713          	addi	a4,a2,48
}
ffffffffc02029a8:	4501                	li	a0,0
    __list_add(elm, listelm->prev, listelm);
ffffffffc02029aa:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc02029ac:	e398                	sd	a4,0(a5)
ffffffffc02029ae:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc02029b0:	fe1c                	sd	a5,56(a2)
    page->visited=1;                                    //2.将页面的visited标志置为1，表示该页面已被访问
ffffffffc02029b2:	4785                	li	a5,1
    elm->prev = prev;
ffffffffc02029b4:	fa14                	sd	a3,48(a2)
ffffffffc02029b6:	ea1c                	sd	a5,16(a2)
}
ffffffffc02029b8:	8082                	ret
{
ffffffffc02029ba:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02029bc:	00003697          	auipc	a3,0x3
ffffffffc02029c0:	f7c68693          	addi	a3,a3,-132 # ffffffffc0205938 <default_pmm_manager+0xc8>
ffffffffc02029c4:	00002617          	auipc	a2,0x2
ffffffffc02029c8:	40460613          	addi	a2,a2,1028 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02029cc:	03c00593          	li	a1,60
ffffffffc02029d0:	00003517          	auipc	a0,0x3
ffffffffc02029d4:	ed850513          	addi	a0,a0,-296 # ffffffffc02058a8 <default_pmm_manager+0x38>
{
ffffffffc02029d8:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02029da:	f28fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02029de <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02029de:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02029e0:	00002617          	auipc	a2,0x2
ffffffffc02029e4:	63860613          	addi	a2,a2,1592 # ffffffffc0205018 <commands+0x978>
ffffffffc02029e8:	06700593          	li	a1,103
ffffffffc02029ec:	00002517          	auipc	a0,0x2
ffffffffc02029f0:	64c50513          	addi	a0,a0,1612 # ffffffffc0205038 <commands+0x998>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02029f4:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02029f6:	f0cfd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02029fa <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02029fa:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02029fc:	00003617          	auipc	a2,0x3
ffffffffc0202a00:	95c60613          	addi	a2,a2,-1700 # ffffffffc0205358 <commands+0xcb8>
ffffffffc0202a04:	07200593          	li	a1,114
ffffffffc0202a08:	00002517          	auipc	a0,0x2
ffffffffc0202a0c:	63050513          	addi	a0,a0,1584 # ffffffffc0205038 <commands+0x998>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0202a10:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0202a12:	ef0fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202a16 <alloc_pages>:
static void init_memmap(struct Page *base, size_t n) {
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - 调用 pmm->alloc_pages 分配连续的 n*PAGESIZE 内存
struct Page *alloc_pages(size_t n) {
ffffffffc0202a16:	7139                	addi	sp,sp,-64
ffffffffc0202a18:	f426                	sd	s1,40(sp)
ffffffffc0202a1a:	f04a                	sd	s2,32(sp)
ffffffffc0202a1c:	ec4e                	sd	s3,24(sp)
ffffffffc0202a1e:	e852                	sd	s4,16(sp)
ffffffffc0202a20:	e456                	sd	s5,8(sp)
ffffffffc0202a22:	e05a                	sd	s6,0(sp)
ffffffffc0202a24:	fc06                	sd	ra,56(sp)
ffffffffc0202a26:	f822                	sd	s0,48(sp)
ffffffffc0202a28:	84aa                	mv	s1,a0
ffffffffc0202a2a:	0000f917          	auipc	s2,0xf
ffffffffc0202a2e:	b3690913          	addi	s2,s2,-1226 # ffffffffc0211560 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);
        //如果n>1, 说明希望分配多个连续的页面，但是我们换出页面的时候并不能换出连续的页面
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a32:	4a05                	li	s4,1
ffffffffc0202a34:	0000fa97          	auipc	s5,0xf
ffffffffc0202a38:	afca8a93          	addi	s5,s5,-1284 # ffffffffc0211530 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a3c:	0005099b          	sext.w	s3,a0
ffffffffc0202a40:	0000fb17          	auipc	s6,0xf
ffffffffc0202a44:	ad0b0b13          	addi	s6,s6,-1328 # ffffffffc0211510 <check_mm_struct>
ffffffffc0202a48:	a01d                	j	ffffffffc0202a6e <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202a4a:	00093783          	ld	a5,0(s2)
ffffffffc0202a4e:	6f9c                	ld	a5,24(a5)
ffffffffc0202a50:	9782                	jalr	a5
ffffffffc0202a52:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a54:	4601                	li	a2,0
ffffffffc0202a56:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a58:	ec0d                	bnez	s0,ffffffffc0202a92 <alloc_pages+0x7c>
ffffffffc0202a5a:	029a6c63          	bltu	s4,s1,ffffffffc0202a92 <alloc_pages+0x7c>
ffffffffc0202a5e:	000aa783          	lw	a5,0(s5)
ffffffffc0202a62:	2781                	sext.w	a5,a5
ffffffffc0202a64:	c79d                	beqz	a5,ffffffffc0202a92 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a66:	000b3503          	ld	a0,0(s6)
ffffffffc0202a6a:	f4ffe0ef          	jal	ra,ffffffffc02019b8 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202a6e:	100027f3          	csrr	a5,sstatus
ffffffffc0202a72:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202a74:	8526                	mv	a0,s1
ffffffffc0202a76:	dbf1                	beqz	a5,ffffffffc0202a4a <alloc_pages+0x34>
        intr_disable();
ffffffffc0202a78:	a77fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202a7c:	00093783          	ld	a5,0(s2)
ffffffffc0202a80:	8526                	mv	a0,s1
ffffffffc0202a82:	6f9c                	ld	a5,24(a5)
ffffffffc0202a84:	9782                	jalr	a5
ffffffffc0202a86:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202a88:	a61fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a8c:	4601                	li	a2,0
ffffffffc0202a8e:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a90:	d469                	beqz	s0,ffffffffc0202a5a <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0202a92:	70e2                	ld	ra,56(sp)
ffffffffc0202a94:	8522                	mv	a0,s0
ffffffffc0202a96:	7442                	ld	s0,48(sp)
ffffffffc0202a98:	74a2                	ld	s1,40(sp)
ffffffffc0202a9a:	7902                	ld	s2,32(sp)
ffffffffc0202a9c:	69e2                	ld	s3,24(sp)
ffffffffc0202a9e:	6a42                	ld	s4,16(sp)
ffffffffc0202aa0:	6aa2                	ld	s5,8(sp)
ffffffffc0202aa2:	6b02                	ld	s6,0(sp)
ffffffffc0202aa4:	6121                	addi	sp,sp,64
ffffffffc0202aa6:	8082                	ret

ffffffffc0202aa8 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202aa8:	100027f3          	csrr	a5,sstatus
ffffffffc0202aac:	8b89                	andi	a5,a5,2
ffffffffc0202aae:	e799                	bnez	a5,ffffffffc0202abc <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0202ab0:	0000f797          	auipc	a5,0xf
ffffffffc0202ab4:	ab07b783          	ld	a5,-1360(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202ab8:	739c                	ld	a5,32(a5)
ffffffffc0202aba:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0202abc:	1101                	addi	sp,sp,-32
ffffffffc0202abe:	ec06                	sd	ra,24(sp)
ffffffffc0202ac0:	e822                	sd	s0,16(sp)
ffffffffc0202ac2:	e426                	sd	s1,8(sp)
ffffffffc0202ac4:	842a                	mv	s0,a0
ffffffffc0202ac6:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202ac8:	a27fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202acc:	0000f797          	auipc	a5,0xf
ffffffffc0202ad0:	a947b783          	ld	a5,-1388(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202ad4:	739c                	ld	a5,32(a5)
ffffffffc0202ad6:	85a6                	mv	a1,s1
ffffffffc0202ad8:	8522                	mv	a0,s0
ffffffffc0202ada:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0202adc:	6442                	ld	s0,16(sp)
ffffffffc0202ade:	60e2                	ld	ra,24(sp)
ffffffffc0202ae0:	64a2                	ld	s1,8(sp)
ffffffffc0202ae2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202ae4:	a05fd06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc0202ae8 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202ae8:	100027f3          	csrr	a5,sstatus
ffffffffc0202aec:	8b89                	andi	a5,a5,2
ffffffffc0202aee:	e799                	bnez	a5,ffffffffc0202afc <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202af0:	0000f797          	auipc	a5,0xf
ffffffffc0202af4:	a707b783          	ld	a5,-1424(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202af8:	779c                	ld	a5,40(a5)
ffffffffc0202afa:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0202afc:	1141                	addi	sp,sp,-16
ffffffffc0202afe:	e406                	sd	ra,8(sp)
ffffffffc0202b00:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0202b02:	9edfd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202b06:	0000f797          	auipc	a5,0xf
ffffffffc0202b0a:	a5a7b783          	ld	a5,-1446(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202b0e:	779c                	ld	a5,40(a5)
ffffffffc0202b10:	9782                	jalr	a5
ffffffffc0202b12:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202b14:	9d5fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202b18:	60a2                	ld	ra,8(sp)
ffffffffc0202b1a:	8522                	mv	a0,s0
ffffffffc0202b1c:	6402                	ld	s0,0(sp)
ffffffffc0202b1e:	0141                	addi	sp,sp,16
ffffffffc0202b20:	8082                	ret

ffffffffc0202b22 <get_pte>:
     * 定义:
     *   PTE_P           0x001                   // 页表/目录项标志位: 存在
     *   PTE_W           0x002                   // 页表/目录项标志位: 可写
     *   PTE_U           0x004                   // 页表/目录项标志位: 用户可访问
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];    // 根据虚拟地址的30-38位从页目录表（三级页表）获取三级页表项（从0开始编号）
ffffffffc0202b22:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202b26:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202b2a:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];    // 根据虚拟地址的30-38位从页目录表（三级页表）获取三级页表项（从0开始编号）
ffffffffc0202b2c:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202b2e:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];    // 根据虚拟地址的30-38位从页目录表（三级页表）获取三级页表项（从0开始编号）
ffffffffc0202b30:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V))              // 如果页表项是否无效
ffffffffc0202b34:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202b36:	f84a                	sd	s2,48(sp)
ffffffffc0202b38:	f44e                	sd	s3,40(sp)
ffffffffc0202b3a:	f052                	sd	s4,32(sp)
ffffffffc0202b3c:	e486                	sd	ra,72(sp)
ffffffffc0202b3e:	e0a2                	sd	s0,64(sp)
ffffffffc0202b40:	ec56                	sd	s5,24(sp)
ffffffffc0202b42:	e85a                	sd	s6,16(sp)
ffffffffc0202b44:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V))              // 如果页表项是否无效
ffffffffc0202b46:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202b4a:	892e                	mv	s2,a1
ffffffffc0202b4c:	8a32                	mv	s4,a2
ffffffffc0202b4e:	0000f997          	auipc	s3,0xf
ffffffffc0202b52:	a0298993          	addi	s3,s3,-1534 # ffffffffc0211550 <npage>
    if (!(*pdep1 & PTE_V))              // 如果页表项是否无效
ffffffffc0202b56:	efb5                	bnez	a5,ffffffffc0202bd2 <get_pte+0xb0>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202b58:	14060c63          	beqz	a2,ffffffffc0202cb0 <get_pte+0x18e>
ffffffffc0202b5c:	4505                	li	a0,1
ffffffffc0202b5e:	eb9ff0ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0202b62:	842a                	mv	s0,a0
ffffffffc0202b64:	14050663          	beqz	a0,ffffffffc0202cb0 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202b68:	0000fb97          	auipc	s7,0xf
ffffffffc0202b6c:	9f0b8b93          	addi	s7,s7,-1552 # ffffffffc0211558 <pages>
ffffffffc0202b70:	000bb503          	ld	a0,0(s7)
ffffffffc0202b74:	00003b17          	auipc	s6,0x3
ffffffffc0202b78:	69cb3b03          	ld	s6,1692(s6) # ffffffffc0206210 <error_string+0x38>
ffffffffc0202b7c:	00080ab7          	lui	s5,0x80
ffffffffc0202b80:	40a40533          	sub	a0,s0,a0
ffffffffc0202b84:	850d                	srai	a0,a0,0x3
ffffffffc0202b86:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202b8a:	0000f997          	auipc	s3,0xf
ffffffffc0202b8e:	9c698993          	addi	s3,s3,-1594 # ffffffffc0211550 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202b92:	4785                	li	a5,1
ffffffffc0202b94:	0009b703          	ld	a4,0(s3)
ffffffffc0202b98:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202b9a:	9556                	add	a0,a0,s5
ffffffffc0202b9c:	00c51793          	slli	a5,a0,0xc
ffffffffc0202ba0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ba2:	0532                	slli	a0,a0,0xc
ffffffffc0202ba4:	14e7fd63          	bgeu	a5,a4,ffffffffc0202cfe <get_pte+0x1dc>
ffffffffc0202ba8:	0000f797          	auipc	a5,0xf
ffffffffc0202bac:	9c07b783          	ld	a5,-1600(a5) # ffffffffc0211568 <va_pa_offset>
ffffffffc0202bb0:	6605                	lui	a2,0x1
ffffffffc0202bb2:	4581                	li	a1,0
ffffffffc0202bb4:	953e                	add	a0,a0,a5
ffffffffc0202bb6:	3a2010ef          	jal	ra,ffffffffc0203f58 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202bba:	000bb683          	ld	a3,0(s7)
ffffffffc0202bbe:	40d406b3          	sub	a3,s0,a3
ffffffffc0202bc2:	868d                	srai	a3,a3,0x3
ffffffffc0202bc4:	036686b3          	mul	a3,a3,s6
ffffffffc0202bc8:	96d6                	add	a3,a3,s5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202bca:	06aa                	slli	a3,a3,0xa
ffffffffc0202bcc:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202bd0:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)]; // 根据虚拟地址的21-29位从二级页表获取二级页表项（从0开始编号）
ffffffffc0202bd2:	77fd                	lui	a5,0xfffff
ffffffffc0202bd4:	068a                	slli	a3,a3,0x2
ffffffffc0202bd6:	0009b703          	ld	a4,0(s3)
ffffffffc0202bda:	8efd                	and	a3,a3,a5
ffffffffc0202bdc:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202be0:	0ce7fa63          	bgeu	a5,a4,ffffffffc0202cb4 <get_pte+0x192>
ffffffffc0202be4:	0000fa97          	auipc	s5,0xf
ffffffffc0202be8:	984a8a93          	addi	s5,s5,-1660 # ffffffffc0211568 <va_pa_offset>
ffffffffc0202bec:	000ab403          	ld	s0,0(s5)
ffffffffc0202bf0:	01595793          	srli	a5,s2,0x15
ffffffffc0202bf4:	1ff7f793          	andi	a5,a5,511
ffffffffc0202bf8:	96a2                	add	a3,a3,s0
ffffffffc0202bfa:	00379413          	slli	s0,a5,0x3
ffffffffc0202bfe:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0202c00:	6014                	ld	a3,0(s0)
ffffffffc0202c02:	0016f793          	andi	a5,a3,1
ffffffffc0202c06:	ebad                	bnez	a5,ffffffffc0202c78 <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202c08:	0a0a0463          	beqz	s4,ffffffffc0202cb0 <get_pte+0x18e>
ffffffffc0202c0c:	4505                	li	a0,1
ffffffffc0202c0e:	e09ff0ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0202c12:	84aa                	mv	s1,a0
ffffffffc0202c14:	cd51                	beqz	a0,ffffffffc0202cb0 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c16:	0000fb97          	auipc	s7,0xf
ffffffffc0202c1a:	942b8b93          	addi	s7,s7,-1726 # ffffffffc0211558 <pages>
ffffffffc0202c1e:	000bb503          	ld	a0,0(s7)
ffffffffc0202c22:	00003b17          	auipc	s6,0x3
ffffffffc0202c26:	5eeb3b03          	ld	s6,1518(s6) # ffffffffc0206210 <error_string+0x38>
ffffffffc0202c2a:	00080a37          	lui	s4,0x80
ffffffffc0202c2e:	40a48533          	sub	a0,s1,a0
ffffffffc0202c32:	850d                	srai	a0,a0,0x3
ffffffffc0202c34:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202c38:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202c3a:	0009b703          	ld	a4,0(s3)
ffffffffc0202c3e:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c40:	9552                	add	a0,a0,s4
ffffffffc0202c42:	00c51793          	slli	a5,a0,0xc
ffffffffc0202c46:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c48:	0532                	slli	a0,a0,0xc
ffffffffc0202c4a:	08e7fd63          	bgeu	a5,a4,ffffffffc0202ce4 <get_pte+0x1c2>
ffffffffc0202c4e:	000ab783          	ld	a5,0(s5)
ffffffffc0202c52:	6605                	lui	a2,0x1
ffffffffc0202c54:	4581                	li	a1,0
ffffffffc0202c56:	953e                	add	a0,a0,a5
ffffffffc0202c58:	300010ef          	jal	ra,ffffffffc0203f58 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c5c:	000bb683          	ld	a3,0(s7)
ffffffffc0202c60:	40d486b3          	sub	a3,s1,a3
ffffffffc0202c64:	868d                	srai	a3,a3,0x3
ffffffffc0202c66:	036686b3          	mul	a3,a3,s6
ffffffffc0202c6a:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202c6c:	06aa                	slli	a3,a3,0xa
ffffffffc0202c6e:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202c72:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)]; // 根据虚拟地址的12-20位从一级页表获取一级页表项（从0开始编号）
ffffffffc0202c74:	0009b703          	ld	a4,0(s3)
ffffffffc0202c78:	068a                	slli	a3,a3,0x2
ffffffffc0202c7a:	757d                	lui	a0,0xfffff
ffffffffc0202c7c:	8ee9                	and	a3,a3,a0
ffffffffc0202c7e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202c82:	04e7f563          	bgeu	a5,a4,ffffffffc0202ccc <get_pte+0x1aa>
ffffffffc0202c86:	000ab503          	ld	a0,0(s5)
ffffffffc0202c8a:	00c95913          	srli	s2,s2,0xc
ffffffffc0202c8e:	1ff97913          	andi	s2,s2,511
ffffffffc0202c92:	96aa                	add	a3,a3,a0
ffffffffc0202c94:	00391513          	slli	a0,s2,0x3
ffffffffc0202c98:	9536                	add	a0,a0,a3
}
ffffffffc0202c9a:	60a6                	ld	ra,72(sp)
ffffffffc0202c9c:	6406                	ld	s0,64(sp)
ffffffffc0202c9e:	74e2                	ld	s1,56(sp)
ffffffffc0202ca0:	7942                	ld	s2,48(sp)
ffffffffc0202ca2:	79a2                	ld	s3,40(sp)
ffffffffc0202ca4:	7a02                	ld	s4,32(sp)
ffffffffc0202ca6:	6ae2                	ld	s5,24(sp)
ffffffffc0202ca8:	6b42                	ld	s6,16(sp)
ffffffffc0202caa:	6ba2                	ld	s7,8(sp)
ffffffffc0202cac:	6161                	addi	sp,sp,80
ffffffffc0202cae:	8082                	ret
            return NULL;
ffffffffc0202cb0:	4501                	li	a0,0
ffffffffc0202cb2:	b7e5                	j	ffffffffc0202c9a <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)]; // 根据虚拟地址的21-29位从二级页表获取二级页表项（从0开始编号）
ffffffffc0202cb4:	00003617          	auipc	a2,0x3
ffffffffc0202cb8:	cc460613          	addi	a2,a2,-828 # ffffffffc0205978 <default_pmm_manager+0x108>
ffffffffc0202cbc:	10400593          	li	a1,260
ffffffffc0202cc0:	00003517          	auipc	a0,0x3
ffffffffc0202cc4:	ce050513          	addi	a0,a0,-800 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0202cc8:	c3afd0ef          	jal	ra,ffffffffc0200102 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)]; // 根据虚拟地址的12-20位从一级页表获取一级页表项（从0开始编号）
ffffffffc0202ccc:	00003617          	auipc	a2,0x3
ffffffffc0202cd0:	cac60613          	addi	a2,a2,-852 # ffffffffc0205978 <default_pmm_manager+0x108>
ffffffffc0202cd4:	11100593          	li	a1,273
ffffffffc0202cd8:	00003517          	auipc	a0,0x3
ffffffffc0202cdc:	cc850513          	addi	a0,a0,-824 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0202ce0:	c22fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202ce4:	86aa                	mv	a3,a0
ffffffffc0202ce6:	00003617          	auipc	a2,0x3
ffffffffc0202cea:	c9260613          	addi	a2,a2,-878 # ffffffffc0205978 <default_pmm_manager+0x108>
ffffffffc0202cee:	10d00593          	li	a1,269
ffffffffc0202cf2:	00003517          	auipc	a0,0x3
ffffffffc0202cf6:	cae50513          	addi	a0,a0,-850 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0202cfa:	c08fd0ef          	jal	ra,ffffffffc0200102 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202cfe:	86aa                	mv	a3,a0
ffffffffc0202d00:	00003617          	auipc	a2,0x3
ffffffffc0202d04:	c7860613          	addi	a2,a2,-904 # ffffffffc0205978 <default_pmm_manager+0x108>
ffffffffc0202d08:	10100593          	li	a1,257
ffffffffc0202d0c:	00003517          	auipc	a0,0x3
ffffffffc0202d10:	c9450513          	addi	a0,a0,-876 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0202d14:	beefd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202d18 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
// 使用PDT pgdir获取线性地址la的相关Page结构
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202d18:	1141                	addi	sp,sp,-16
ffffffffc0202d1a:	e022                	sd	s0,0(sp)
ffffffffc0202d1c:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d1e:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202d20:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d22:	e01ff0ef          	jal	ra,ffffffffc0202b22 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202d26:	c011                	beqz	s0,ffffffffc0202d2a <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202d28:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202d2a:	c511                	beqz	a0,ffffffffc0202d36 <get_page+0x1e>
ffffffffc0202d2c:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202d2e:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202d30:	0017f713          	andi	a4,a5,1
ffffffffc0202d34:	e709                	bnez	a4,ffffffffc0202d3e <get_page+0x26>
}
ffffffffc0202d36:	60a2                	ld	ra,8(sp)
ffffffffc0202d38:	6402                	ld	s0,0(sp)
ffffffffc0202d3a:	0141                	addi	sp,sp,16
ffffffffc0202d3c:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202d3e:	078a                	slli	a5,a5,0x2
ffffffffc0202d40:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d42:	0000f717          	auipc	a4,0xf
ffffffffc0202d46:	80e73703          	ld	a4,-2034(a4) # ffffffffc0211550 <npage>
ffffffffc0202d4a:	02e7f263          	bgeu	a5,a4,ffffffffc0202d6e <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d4e:	fff80537          	lui	a0,0xfff80
ffffffffc0202d52:	97aa                	add	a5,a5,a0
ffffffffc0202d54:	60a2                	ld	ra,8(sp)
ffffffffc0202d56:	6402                	ld	s0,0(sp)
ffffffffc0202d58:	00379513          	slli	a0,a5,0x3
ffffffffc0202d5c:	97aa                	add	a5,a5,a0
ffffffffc0202d5e:	078e                	slli	a5,a5,0x3
ffffffffc0202d60:	0000e517          	auipc	a0,0xe
ffffffffc0202d64:	7f853503          	ld	a0,2040(a0) # ffffffffc0211558 <pages>
ffffffffc0202d68:	953e                	add	a0,a0,a5
ffffffffc0202d6a:	0141                	addi	sp,sp,16
ffffffffc0202d6c:	8082                	ret
ffffffffc0202d6e:	c71ff0ef          	jal	ra,ffffffffc02029de <pa2page.part.0>

ffffffffc0202d72 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202d72:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d74:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202d76:	ec06                	sd	ra,24(sp)
ffffffffc0202d78:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d7a:	da9ff0ef          	jal	ra,ffffffffc0202b22 <get_pte>
    if (ptep != NULL) {
ffffffffc0202d7e:	c511                	beqz	a0,ffffffffc0202d8a <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202d80:	611c                	ld	a5,0(a0)
ffffffffc0202d82:	842a                	mv	s0,a0
ffffffffc0202d84:	0017f713          	andi	a4,a5,1
ffffffffc0202d88:	e709                	bnez	a4,ffffffffc0202d92 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0202d8a:	60e2                	ld	ra,24(sp)
ffffffffc0202d8c:	6442                	ld	s0,16(sp)
ffffffffc0202d8e:	6105                	addi	sp,sp,32
ffffffffc0202d90:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202d92:	078a                	slli	a5,a5,0x2
ffffffffc0202d94:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d96:	0000e717          	auipc	a4,0xe
ffffffffc0202d9a:	7ba73703          	ld	a4,1978(a4) # ffffffffc0211550 <npage>
ffffffffc0202d9e:	06e7f563          	bgeu	a5,a4,ffffffffc0202e08 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc0202da2:	fff80737          	lui	a4,0xfff80
ffffffffc0202da6:	97ba                	add	a5,a5,a4
ffffffffc0202da8:	00379513          	slli	a0,a5,0x3
ffffffffc0202dac:	97aa                	add	a5,a5,a0
ffffffffc0202dae:	078e                	slli	a5,a5,0x3
ffffffffc0202db0:	0000e517          	auipc	a0,0xe
ffffffffc0202db4:	7a853503          	ld	a0,1960(a0) # ffffffffc0211558 <pages>
ffffffffc0202db8:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202dba:	411c                	lw	a5,0(a0)
ffffffffc0202dbc:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202dc0:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202dc2:	cb09                	beqz	a4,ffffffffc0202dd4 <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202dc4:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202dc8:	12000073          	sfence.vma
}
ffffffffc0202dcc:	60e2                	ld	ra,24(sp)
ffffffffc0202dce:	6442                	ld	s0,16(sp)
ffffffffc0202dd0:	6105                	addi	sp,sp,32
ffffffffc0202dd2:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202dd4:	100027f3          	csrr	a5,sstatus
ffffffffc0202dd8:	8b89                	andi	a5,a5,2
ffffffffc0202dda:	eb89                	bnez	a5,ffffffffc0202dec <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202ddc:	0000e797          	auipc	a5,0xe
ffffffffc0202de0:	7847b783          	ld	a5,1924(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202de4:	739c                	ld	a5,32(a5)
ffffffffc0202de6:	4585                	li	a1,1
ffffffffc0202de8:	9782                	jalr	a5
    if (flag) {
ffffffffc0202dea:	bfe9                	j	ffffffffc0202dc4 <page_remove+0x52>
        intr_disable();
ffffffffc0202dec:	e42a                	sd	a0,8(sp)
ffffffffc0202dee:	f00fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202df2:	0000e797          	auipc	a5,0xe
ffffffffc0202df6:	76e7b783          	ld	a5,1902(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202dfa:	739c                	ld	a5,32(a5)
ffffffffc0202dfc:	6522                	ld	a0,8(sp)
ffffffffc0202dfe:	4585                	li	a1,1
ffffffffc0202e00:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e02:	ee6fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202e06:	bf7d                	j	ffffffffc0202dc4 <page_remove+0x52>
ffffffffc0202e08:	bd7ff0ef          	jal	ra,ffffffffc02029de <pa2page.part.0>

ffffffffc0202e0c <page_insert>:
//  page:  需要映射的 Page
//  la:    需要映射的线性地址
//  perm:  设置在相关页表项中的 Page 权限
// 返回值: 始终为 0
// 注意: 页表已更改，因此需要使 TLB 失效
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202e0c:	7179                	addi	sp,sp,-48
ffffffffc0202e0e:	87b2                	mv	a5,a2
ffffffffc0202e10:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202e12:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202e14:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202e16:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202e18:	ec26                	sd	s1,24(sp)
ffffffffc0202e1a:	f406                	sd	ra,40(sp)
ffffffffc0202e1c:	e84a                	sd	s2,16(sp)
ffffffffc0202e1e:	e44e                	sd	s3,8(sp)
ffffffffc0202e20:	e052                	sd	s4,0(sp)
ffffffffc0202e22:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202e24:	cffff0ef          	jal	ra,ffffffffc0202b22 <get_pte>
    if (ptep == NULL) {
ffffffffc0202e28:	cd71                	beqz	a0,ffffffffc0202f04 <page_insert+0xf8>
    page->ref += 1;
ffffffffc0202e2a:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0202e2c:	611c                	ld	a5,0(a0)
ffffffffc0202e2e:	89aa                	mv	s3,a0
ffffffffc0202e30:	0016871b          	addiw	a4,a3,1
ffffffffc0202e34:	c018                	sw	a4,0(s0)
ffffffffc0202e36:	0017f713          	andi	a4,a5,1
ffffffffc0202e3a:	e331                	bnez	a4,ffffffffc0202e7e <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202e3c:	0000e797          	auipc	a5,0xe
ffffffffc0202e40:	71c7b783          	ld	a5,1820(a5) # ffffffffc0211558 <pages>
ffffffffc0202e44:	40f407b3          	sub	a5,s0,a5
ffffffffc0202e48:	878d                	srai	a5,a5,0x3
ffffffffc0202e4a:	00003417          	auipc	s0,0x3
ffffffffc0202e4e:	3c643403          	ld	s0,966(s0) # ffffffffc0206210 <error_string+0x38>
ffffffffc0202e52:	028787b3          	mul	a5,a5,s0
ffffffffc0202e56:	00080437          	lui	s0,0x80
ffffffffc0202e5a:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202e5c:	07aa                	slli	a5,a5,0xa
ffffffffc0202e5e:	8cdd                	or	s1,s1,a5
ffffffffc0202e60:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202e64:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202e68:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0202e6c:	4501                	li	a0,0
}
ffffffffc0202e6e:	70a2                	ld	ra,40(sp)
ffffffffc0202e70:	7402                	ld	s0,32(sp)
ffffffffc0202e72:	64e2                	ld	s1,24(sp)
ffffffffc0202e74:	6942                	ld	s2,16(sp)
ffffffffc0202e76:	69a2                	ld	s3,8(sp)
ffffffffc0202e78:	6a02                	ld	s4,0(sp)
ffffffffc0202e7a:	6145                	addi	sp,sp,48
ffffffffc0202e7c:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202e7e:	00279713          	slli	a4,a5,0x2
ffffffffc0202e82:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e84:	0000e797          	auipc	a5,0xe
ffffffffc0202e88:	6cc7b783          	ld	a5,1740(a5) # ffffffffc0211550 <npage>
ffffffffc0202e8c:	06f77e63          	bgeu	a4,a5,ffffffffc0202f08 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e90:	fff807b7          	lui	a5,0xfff80
ffffffffc0202e94:	973e                	add	a4,a4,a5
ffffffffc0202e96:	0000ea17          	auipc	s4,0xe
ffffffffc0202e9a:	6c2a0a13          	addi	s4,s4,1730 # ffffffffc0211558 <pages>
ffffffffc0202e9e:	000a3783          	ld	a5,0(s4)
ffffffffc0202ea2:	00371913          	slli	s2,a4,0x3
ffffffffc0202ea6:	993a                	add	s2,s2,a4
ffffffffc0202ea8:	090e                	slli	s2,s2,0x3
ffffffffc0202eaa:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0202eac:	03240063          	beq	s0,s2,ffffffffc0202ecc <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0202eb0:	00092783          	lw	a5,0(s2)
ffffffffc0202eb4:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202eb8:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0202ebc:	cb11                	beqz	a4,ffffffffc0202ed0 <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202ebe:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202ec2:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202ec6:	000a3783          	ld	a5,0(s4)
}
ffffffffc0202eca:	bfad                	j	ffffffffc0202e44 <page_insert+0x38>
    page->ref -= 1;
ffffffffc0202ecc:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202ece:	bf9d                	j	ffffffffc0202e44 <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202ed0:	100027f3          	csrr	a5,sstatus
ffffffffc0202ed4:	8b89                	andi	a5,a5,2
ffffffffc0202ed6:	eb91                	bnez	a5,ffffffffc0202eea <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202ed8:	0000e797          	auipc	a5,0xe
ffffffffc0202edc:	6887b783          	ld	a5,1672(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202ee0:	739c                	ld	a5,32(a5)
ffffffffc0202ee2:	4585                	li	a1,1
ffffffffc0202ee4:	854a                	mv	a0,s2
ffffffffc0202ee6:	9782                	jalr	a5
    if (flag) {
ffffffffc0202ee8:	bfd9                	j	ffffffffc0202ebe <page_insert+0xb2>
        intr_disable();
ffffffffc0202eea:	e04fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202eee:	0000e797          	auipc	a5,0xe
ffffffffc0202ef2:	6727b783          	ld	a5,1650(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202ef6:	739c                	ld	a5,32(a5)
ffffffffc0202ef8:	4585                	li	a1,1
ffffffffc0202efa:	854a                	mv	a0,s2
ffffffffc0202efc:	9782                	jalr	a5
        intr_enable();
ffffffffc0202efe:	deafd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202f02:	bf75                	j	ffffffffc0202ebe <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0202f04:	5571                	li	a0,-4
ffffffffc0202f06:	b7a5                	j	ffffffffc0202e6e <page_insert+0x62>
ffffffffc0202f08:	ad7ff0ef          	jal	ra,ffffffffc02029de <pa2page.part.0>

ffffffffc0202f0c <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202f0c:	00003797          	auipc	a5,0x3
ffffffffc0202f10:	96478793          	addi	a5,a5,-1692 # ffffffffc0205870 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202f14:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202f16:	7159                	addi	sp,sp,-112
ffffffffc0202f18:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202f1a:	00003517          	auipc	a0,0x3
ffffffffc0202f1e:	a9650513          	addi	a0,a0,-1386 # ffffffffc02059b0 <default_pmm_manager+0x140>
    pmm_manager = &default_pmm_manager;
ffffffffc0202f22:	0000eb97          	auipc	s7,0xe
ffffffffc0202f26:	63eb8b93          	addi	s7,s7,1598 # ffffffffc0211560 <pmm_manager>
void pmm_init(void) {
ffffffffc0202f2a:	f486                	sd	ra,104(sp)
ffffffffc0202f2c:	f0a2                	sd	s0,96(sp)
ffffffffc0202f2e:	eca6                	sd	s1,88(sp)
ffffffffc0202f30:	e8ca                	sd	s2,80(sp)
ffffffffc0202f32:	e4ce                	sd	s3,72(sp)
ffffffffc0202f34:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202f36:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0202f3a:	e0d2                	sd	s4,64(sp)
ffffffffc0202f3c:	fc56                	sd	s5,56(sp)
ffffffffc0202f3e:	f062                	sd	s8,32(sp)
ffffffffc0202f40:	ec66                	sd	s9,24(sp)
ffffffffc0202f42:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202f44:	976fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0202f48:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202f4c:	4445                	li	s0,17
ffffffffc0202f4e:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0202f52:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202f54:	0000e997          	auipc	s3,0xe
ffffffffc0202f58:	61498993          	addi	s3,s3,1556 # ffffffffc0211568 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0202f5c:	0000e497          	auipc	s1,0xe
ffffffffc0202f60:	5f448493          	addi	s1,s1,1524 # ffffffffc0211550 <npage>
    pmm_manager->init();
ffffffffc0202f64:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202f66:	57f5                	li	a5,-3
ffffffffc0202f68:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202f6a:	07e006b7          	lui	a3,0x7e00
ffffffffc0202f6e:	01b41613          	slli	a2,s0,0x1b
ffffffffc0202f72:	01591593          	slli	a1,s2,0x15
ffffffffc0202f76:	00003517          	auipc	a0,0x3
ffffffffc0202f7a:	a5250513          	addi	a0,a0,-1454 # ffffffffc02059c8 <default_pmm_manager+0x158>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202f7e:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202f82:	938fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0202f86:	00003517          	auipc	a0,0x3
ffffffffc0202f8a:	a7250513          	addi	a0,a0,-1422 # ffffffffc02059f8 <default_pmm_manager+0x188>
ffffffffc0202f8e:	92cfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202f92:	01b41693          	slli	a3,s0,0x1b
ffffffffc0202f96:	16fd                	addi	a3,a3,-1
ffffffffc0202f98:	07e005b7          	lui	a1,0x7e00
ffffffffc0202f9c:	01591613          	slli	a2,s2,0x15
ffffffffc0202fa0:	00003517          	auipc	a0,0x3
ffffffffc0202fa4:	a7050513          	addi	a0,a0,-1424 # ffffffffc0205a10 <default_pmm_manager+0x1a0>
ffffffffc0202fa8:	912fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202fac:	777d                	lui	a4,0xfffff
ffffffffc0202fae:	0000f797          	auipc	a5,0xf
ffffffffc0202fb2:	5c178793          	addi	a5,a5,1473 # ffffffffc021256f <end+0xfff>
ffffffffc0202fb6:	8ff9                	and	a5,a5,a4
ffffffffc0202fb8:	0000eb17          	auipc	s6,0xe
ffffffffc0202fbc:	5a0b0b13          	addi	s6,s6,1440 # ffffffffc0211558 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0202fc0:	00088737          	lui	a4,0x88
ffffffffc0202fc4:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202fc6:	00fb3023          	sd	a5,0(s6)
ffffffffc0202fca:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202fcc:	4701                	li	a4,0
ffffffffc0202fce:	4505                	li	a0,1
ffffffffc0202fd0:	fff805b7          	lui	a1,0xfff80
ffffffffc0202fd4:	a019                	j	ffffffffc0202fda <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0202fd6:	000b3783          	ld	a5,0(s6)
ffffffffc0202fda:	97b6                	add	a5,a5,a3
ffffffffc0202fdc:	07a1                	addi	a5,a5,8
ffffffffc0202fde:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202fe2:	609c                	ld	a5,0(s1)
ffffffffc0202fe4:	0705                	addi	a4,a4,1
ffffffffc0202fe6:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0202fea:	00b78633          	add	a2,a5,a1
ffffffffc0202fee:	fec764e3          	bltu	a4,a2,ffffffffc0202fd6 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202ff2:	000b3503          	ld	a0,0(s6)
ffffffffc0202ff6:	00379693          	slli	a3,a5,0x3
ffffffffc0202ffa:	96be                	add	a3,a3,a5
ffffffffc0202ffc:	fdc00737          	lui	a4,0xfdc00
ffffffffc0203000:	972a                	add	a4,a4,a0
ffffffffc0203002:	068e                	slli	a3,a3,0x3
ffffffffc0203004:	96ba                	add	a3,a3,a4
ffffffffc0203006:	c0200737          	lui	a4,0xc0200
ffffffffc020300a:	64e6e463          	bltu	a3,a4,ffffffffc0203652 <pmm_init+0x746>
ffffffffc020300e:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0203012:	4645                	li	a2,17
ffffffffc0203014:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203016:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0203018:	4ec6e263          	bltu	a3,a2,ffffffffc02034fc <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020301c:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203020:	0000e917          	auipc	s2,0xe
ffffffffc0203024:	52890913          	addi	s2,s2,1320 # ffffffffc0211548 <boot_pgdir>
    pmm_manager->check();
ffffffffc0203028:	7b9c                	ld	a5,48(a5)
ffffffffc020302a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020302c:	00003517          	auipc	a0,0x3
ffffffffc0203030:	a3450513          	addi	a0,a0,-1484 # ffffffffc0205a60 <default_pmm_manager+0x1f0>
ffffffffc0203034:	886fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203038:	00006697          	auipc	a3,0x6
ffffffffc020303c:	fc868693          	addi	a3,a3,-56 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0203040:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203044:	c02007b7          	lui	a5,0xc0200
ffffffffc0203048:	62f6e163          	bltu	a3,a5,ffffffffc020366a <pmm_init+0x75e>
ffffffffc020304c:	0009b783          	ld	a5,0(s3)
ffffffffc0203050:	8e9d                	sub	a3,a3,a5
ffffffffc0203052:	0000e797          	auipc	a5,0xe
ffffffffc0203056:	4ed7b723          	sd	a3,1262(a5) # ffffffffc0211540 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020305a:	100027f3          	csrr	a5,sstatus
ffffffffc020305e:	8b89                	andi	a5,a5,2
ffffffffc0203060:	4c079763          	bnez	a5,ffffffffc020352e <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203064:	000bb783          	ld	a5,0(s7)
ffffffffc0203068:	779c                	ld	a5,40(a5)
ffffffffc020306a:	9782                	jalr	a5
ffffffffc020306c:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020306e:	6098                	ld	a4,0(s1)
ffffffffc0203070:	c80007b7          	lui	a5,0xc8000
ffffffffc0203074:	83b1                	srli	a5,a5,0xc
ffffffffc0203076:	62e7e663          	bltu	a5,a4,ffffffffc02036a2 <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020307a:	00093503          	ld	a0,0(s2)
ffffffffc020307e:	60050263          	beqz	a0,ffffffffc0203682 <pmm_init+0x776>
ffffffffc0203082:	03451793          	slli	a5,a0,0x34
ffffffffc0203086:	5e079e63          	bnez	a5,ffffffffc0203682 <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020308a:	4601                	li	a2,0
ffffffffc020308c:	4581                	li	a1,0
ffffffffc020308e:	c8bff0ef          	jal	ra,ffffffffc0202d18 <get_page>
ffffffffc0203092:	66051a63          	bnez	a0,ffffffffc0203706 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0203096:	4505                	li	a0,1
ffffffffc0203098:	97fff0ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc020309c:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020309e:	00093503          	ld	a0,0(s2)
ffffffffc02030a2:	4681                	li	a3,0
ffffffffc02030a4:	4601                	li	a2,0
ffffffffc02030a6:	85d2                	mv	a1,s4
ffffffffc02030a8:	d65ff0ef          	jal	ra,ffffffffc0202e0c <page_insert>
ffffffffc02030ac:	62051d63          	bnez	a0,ffffffffc02036e6 <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02030b0:	00093503          	ld	a0,0(s2)
ffffffffc02030b4:	4601                	li	a2,0
ffffffffc02030b6:	4581                	li	a1,0
ffffffffc02030b8:	a6bff0ef          	jal	ra,ffffffffc0202b22 <get_pte>
ffffffffc02030bc:	60050563          	beqz	a0,ffffffffc02036c6 <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc02030c0:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02030c2:	0017f713          	andi	a4,a5,1
ffffffffc02030c6:	5e070e63          	beqz	a4,ffffffffc02036c2 <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc02030ca:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02030cc:	078a                	slli	a5,a5,0x2
ffffffffc02030ce:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02030d0:	56c7ff63          	bgeu	a5,a2,ffffffffc020364e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02030d4:	fff80737          	lui	a4,0xfff80
ffffffffc02030d8:	97ba                	add	a5,a5,a4
ffffffffc02030da:	000b3683          	ld	a3,0(s6)
ffffffffc02030de:	00379713          	slli	a4,a5,0x3
ffffffffc02030e2:	97ba                	add	a5,a5,a4
ffffffffc02030e4:	078e                	slli	a5,a5,0x3
ffffffffc02030e6:	97b6                	add	a5,a5,a3
ffffffffc02030e8:	14fa18e3          	bne	s4,a5,ffffffffc0203a38 <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc02030ec:	000a2703          	lw	a4,0(s4)
ffffffffc02030f0:	4785                	li	a5,1
ffffffffc02030f2:	16f71fe3          	bne	a4,a5,ffffffffc0203a70 <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02030f6:	00093503          	ld	a0,0(s2)
ffffffffc02030fa:	77fd                	lui	a5,0xfffff
ffffffffc02030fc:	6114                	ld	a3,0(a0)
ffffffffc02030fe:	068a                	slli	a3,a3,0x2
ffffffffc0203100:	8efd                	and	a3,a3,a5
ffffffffc0203102:	00c6d713          	srli	a4,a3,0xc
ffffffffc0203106:	14c779e3          	bgeu	a4,a2,ffffffffc0203a58 <pmm_init+0xb4c>
ffffffffc020310a:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020310e:	96e2                	add	a3,a3,s8
ffffffffc0203110:	0006ba83          	ld	s5,0(a3)
ffffffffc0203114:	0a8a                	slli	s5,s5,0x2
ffffffffc0203116:	00fafab3          	and	s5,s5,a5
ffffffffc020311a:	00cad793          	srli	a5,s5,0xc
ffffffffc020311e:	66c7f463          	bgeu	a5,a2,ffffffffc0203786 <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203122:	4601                	li	a2,0
ffffffffc0203124:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203126:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203128:	9fbff0ef          	jal	ra,ffffffffc0202b22 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020312c:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020312e:	63551c63          	bne	a0,s5,ffffffffc0203766 <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc0203132:	4505                	li	a0,1
ffffffffc0203134:	8e3ff0ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0203138:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020313a:	00093503          	ld	a0,0(s2)
ffffffffc020313e:	46d1                	li	a3,20
ffffffffc0203140:	6605                	lui	a2,0x1
ffffffffc0203142:	85d6                	mv	a1,s5
ffffffffc0203144:	cc9ff0ef          	jal	ra,ffffffffc0202e0c <page_insert>
ffffffffc0203148:	5c051f63          	bnez	a0,ffffffffc0203726 <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020314c:	00093503          	ld	a0,0(s2)
ffffffffc0203150:	4601                	li	a2,0
ffffffffc0203152:	6585                	lui	a1,0x1
ffffffffc0203154:	9cfff0ef          	jal	ra,ffffffffc0202b22 <get_pte>
ffffffffc0203158:	12050ce3          	beqz	a0,ffffffffc0203a90 <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc020315c:	611c                	ld	a5,0(a0)
ffffffffc020315e:	0107f713          	andi	a4,a5,16
ffffffffc0203162:	72070f63          	beqz	a4,ffffffffc02038a0 <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc0203166:	8b91                	andi	a5,a5,4
ffffffffc0203168:	6e078c63          	beqz	a5,ffffffffc0203860 <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020316c:	00093503          	ld	a0,0(s2)
ffffffffc0203170:	611c                	ld	a5,0(a0)
ffffffffc0203172:	8bc1                	andi	a5,a5,16
ffffffffc0203174:	6c078663          	beqz	a5,ffffffffc0203840 <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc0203178:	000aa703          	lw	a4,0(s5)
ffffffffc020317c:	4785                	li	a5,1
ffffffffc020317e:	5cf71463          	bne	a4,a5,ffffffffc0203746 <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203182:	4681                	li	a3,0
ffffffffc0203184:	6605                	lui	a2,0x1
ffffffffc0203186:	85d2                	mv	a1,s4
ffffffffc0203188:	c85ff0ef          	jal	ra,ffffffffc0202e0c <page_insert>
ffffffffc020318c:	66051a63          	bnez	a0,ffffffffc0203800 <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc0203190:	000a2703          	lw	a4,0(s4)
ffffffffc0203194:	4789                	li	a5,2
ffffffffc0203196:	64f71563          	bne	a4,a5,ffffffffc02037e0 <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc020319a:	000aa783          	lw	a5,0(s5)
ffffffffc020319e:	62079163          	bnez	a5,ffffffffc02037c0 <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02031a2:	00093503          	ld	a0,0(s2)
ffffffffc02031a6:	4601                	li	a2,0
ffffffffc02031a8:	6585                	lui	a1,0x1
ffffffffc02031aa:	979ff0ef          	jal	ra,ffffffffc0202b22 <get_pte>
ffffffffc02031ae:	5e050963          	beqz	a0,ffffffffc02037a0 <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc02031b2:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02031b4:	00177793          	andi	a5,a4,1
ffffffffc02031b8:	50078563          	beqz	a5,ffffffffc02036c2 <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc02031bc:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02031be:	00271793          	slli	a5,a4,0x2
ffffffffc02031c2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031c4:	48d7f563          	bgeu	a5,a3,ffffffffc020364e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02031c8:	fff806b7          	lui	a3,0xfff80
ffffffffc02031cc:	97b6                	add	a5,a5,a3
ffffffffc02031ce:	000b3603          	ld	a2,0(s6)
ffffffffc02031d2:	00379693          	slli	a3,a5,0x3
ffffffffc02031d6:	97b6                	add	a5,a5,a3
ffffffffc02031d8:	078e                	slli	a5,a5,0x3
ffffffffc02031da:	97b2                	add	a5,a5,a2
ffffffffc02031dc:	72fa1263          	bne	s4,a5,ffffffffc0203900 <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc02031e0:	8b41                	andi	a4,a4,16
ffffffffc02031e2:	6e071f63          	bnez	a4,ffffffffc02038e0 <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc02031e6:	00093503          	ld	a0,0(s2)
ffffffffc02031ea:	4581                	li	a1,0
ffffffffc02031ec:	b87ff0ef          	jal	ra,ffffffffc0202d72 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02031f0:	000a2703          	lw	a4,0(s4)
ffffffffc02031f4:	4785                	li	a5,1
ffffffffc02031f6:	6cf71563          	bne	a4,a5,ffffffffc02038c0 <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc02031fa:	000aa783          	lw	a5,0(s5)
ffffffffc02031fe:	78079d63          	bnez	a5,ffffffffc0203998 <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0203202:	00093503          	ld	a0,0(s2)
ffffffffc0203206:	6585                	lui	a1,0x1
ffffffffc0203208:	b6bff0ef          	jal	ra,ffffffffc0202d72 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020320c:	000a2783          	lw	a5,0(s4)
ffffffffc0203210:	76079463          	bnez	a5,ffffffffc0203978 <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc0203214:	000aa783          	lw	a5,0(s5)
ffffffffc0203218:	74079063          	bnez	a5,ffffffffc0203958 <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020321c:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203220:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203222:	000a3783          	ld	a5,0(s4)
ffffffffc0203226:	078a                	slli	a5,a5,0x2
ffffffffc0203228:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020322a:	42c7f263          	bgeu	a5,a2,ffffffffc020364e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020322e:	fff80737          	lui	a4,0xfff80
ffffffffc0203232:	973e                	add	a4,a4,a5
ffffffffc0203234:	00371793          	slli	a5,a4,0x3
ffffffffc0203238:	000b3503          	ld	a0,0(s6)
ffffffffc020323c:	97ba                	add	a5,a5,a4
ffffffffc020323e:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0203240:	00f50733          	add	a4,a0,a5
ffffffffc0203244:	4314                	lw	a3,0(a4)
ffffffffc0203246:	4705                	li	a4,1
ffffffffc0203248:	6ee69863          	bne	a3,a4,ffffffffc0203938 <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020324c:	4037d693          	srai	a3,a5,0x3
ffffffffc0203250:	00003c97          	auipc	s9,0x3
ffffffffc0203254:	fc0cbc83          	ld	s9,-64(s9) # ffffffffc0206210 <error_string+0x38>
ffffffffc0203258:	039686b3          	mul	a3,a3,s9
ffffffffc020325c:	000805b7          	lui	a1,0x80
ffffffffc0203260:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203262:	00c69713          	slli	a4,a3,0xc
ffffffffc0203266:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203268:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020326a:	6ac77b63          	bgeu	a4,a2,ffffffffc0203920 <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020326e:	0009b703          	ld	a4,0(s3)
ffffffffc0203272:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0203274:	629c                	ld	a5,0(a3)
ffffffffc0203276:	078a                	slli	a5,a5,0x2
ffffffffc0203278:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020327a:	3cc7fa63          	bgeu	a5,a2,ffffffffc020364e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020327e:	8f8d                	sub	a5,a5,a1
ffffffffc0203280:	00379713          	slli	a4,a5,0x3
ffffffffc0203284:	97ba                	add	a5,a5,a4
ffffffffc0203286:	078e                	slli	a5,a5,0x3
ffffffffc0203288:	953e                	add	a0,a0,a5
ffffffffc020328a:	100027f3          	csrr	a5,sstatus
ffffffffc020328e:	8b89                	andi	a5,a5,2
ffffffffc0203290:	2e079963          	bnez	a5,ffffffffc0203582 <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203294:	000bb783          	ld	a5,0(s7)
ffffffffc0203298:	4585                	li	a1,1
ffffffffc020329a:	739c                	ld	a5,32(a5)
ffffffffc020329c:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020329e:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02032a2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02032a4:	078a                	slli	a5,a5,0x2
ffffffffc02032a6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02032a8:	3ae7f363          	bgeu	a5,a4,ffffffffc020364e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02032ac:	fff80737          	lui	a4,0xfff80
ffffffffc02032b0:	97ba                	add	a5,a5,a4
ffffffffc02032b2:	000b3503          	ld	a0,0(s6)
ffffffffc02032b6:	00379713          	slli	a4,a5,0x3
ffffffffc02032ba:	97ba                	add	a5,a5,a4
ffffffffc02032bc:	078e                	slli	a5,a5,0x3
ffffffffc02032be:	953e                	add	a0,a0,a5
ffffffffc02032c0:	100027f3          	csrr	a5,sstatus
ffffffffc02032c4:	8b89                	andi	a5,a5,2
ffffffffc02032c6:	2a079263          	bnez	a5,ffffffffc020356a <pmm_init+0x65e>
ffffffffc02032ca:	000bb783          	ld	a5,0(s7)
ffffffffc02032ce:	4585                	li	a1,1
ffffffffc02032d0:	739c                	ld	a5,32(a5)
ffffffffc02032d2:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02032d4:	00093783          	ld	a5,0(s2)
ffffffffc02032d8:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda90>
ffffffffc02032dc:	100027f3          	csrr	a5,sstatus
ffffffffc02032e0:	8b89                	andi	a5,a5,2
ffffffffc02032e2:	26079a63          	bnez	a5,ffffffffc0203556 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02032e6:	000bb783          	ld	a5,0(s7)
ffffffffc02032ea:	779c                	ld	a5,40(a5)
ffffffffc02032ec:	9782                	jalr	a5
ffffffffc02032ee:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc02032f0:	73441463          	bne	s0,s4,ffffffffc0203a18 <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02032f4:	00003517          	auipc	a0,0x3
ffffffffc02032f8:	a5450513          	addi	a0,a0,-1452 # ffffffffc0205d48 <default_pmm_manager+0x4d8>
ffffffffc02032fc:	dbffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203300:	100027f3          	csrr	a5,sstatus
ffffffffc0203304:	8b89                	andi	a5,a5,2
ffffffffc0203306:	22079e63          	bnez	a5,ffffffffc0203542 <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020330a:	000bb783          	ld	a5,0(s7)
ffffffffc020330e:	779c                	ld	a5,40(a5)
ffffffffc0203310:	9782                	jalr	a5
ffffffffc0203312:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203314:	6098                	ld	a4,0(s1)
ffffffffc0203316:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020331a:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020331c:	00c71793          	slli	a5,a4,0xc
ffffffffc0203320:	6a05                	lui	s4,0x1
ffffffffc0203322:	02f47c63          	bgeu	s0,a5,ffffffffc020335a <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203326:	00c45793          	srli	a5,s0,0xc
ffffffffc020332a:	00093503          	ld	a0,0(s2)
ffffffffc020332e:	30e7f363          	bgeu	a5,a4,ffffffffc0203634 <pmm_init+0x728>
ffffffffc0203332:	0009b583          	ld	a1,0(s3)
ffffffffc0203336:	4601                	li	a2,0
ffffffffc0203338:	95a2                	add	a1,a1,s0
ffffffffc020333a:	fe8ff0ef          	jal	ra,ffffffffc0202b22 <get_pte>
ffffffffc020333e:	2c050b63          	beqz	a0,ffffffffc0203614 <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203342:	611c                	ld	a5,0(a0)
ffffffffc0203344:	078a                	slli	a5,a5,0x2
ffffffffc0203346:	0157f7b3          	and	a5,a5,s5
ffffffffc020334a:	2a879563          	bne	a5,s0,ffffffffc02035f4 <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020334e:	6098                	ld	a4,0(s1)
ffffffffc0203350:	9452                	add	s0,s0,s4
ffffffffc0203352:	00c71793          	slli	a5,a4,0xc
ffffffffc0203356:	fcf468e3          	bltu	s0,a5,ffffffffc0203326 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc020335a:	00093783          	ld	a5,0(s2)
ffffffffc020335e:	639c                	ld	a5,0(a5)
ffffffffc0203360:	68079c63          	bnez	a5,ffffffffc02039f8 <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc0203364:	4505                	li	a0,1
ffffffffc0203366:	eb0ff0ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc020336a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020336c:	00093503          	ld	a0,0(s2)
ffffffffc0203370:	4699                	li	a3,6
ffffffffc0203372:	10000613          	li	a2,256
ffffffffc0203376:	85d6                	mv	a1,s5
ffffffffc0203378:	a95ff0ef          	jal	ra,ffffffffc0202e0c <page_insert>
ffffffffc020337c:	64051e63          	bnez	a0,ffffffffc02039d8 <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc0203380:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda90>
ffffffffc0203384:	4785                	li	a5,1
ffffffffc0203386:	62f71963          	bne	a4,a5,ffffffffc02039b8 <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020338a:	00093503          	ld	a0,0(s2)
ffffffffc020338e:	6405                	lui	s0,0x1
ffffffffc0203390:	4699                	li	a3,6
ffffffffc0203392:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0203396:	85d6                	mv	a1,s5
ffffffffc0203398:	a75ff0ef          	jal	ra,ffffffffc0202e0c <page_insert>
ffffffffc020339c:	48051263          	bnez	a0,ffffffffc0203820 <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc02033a0:	000aa703          	lw	a4,0(s5)
ffffffffc02033a4:	4789                	li	a5,2
ffffffffc02033a6:	74f71563          	bne	a4,a5,ffffffffc0203af0 <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02033aa:	00003597          	auipc	a1,0x3
ffffffffc02033ae:	ad658593          	addi	a1,a1,-1322 # ffffffffc0205e80 <default_pmm_manager+0x610>
ffffffffc02033b2:	10000513          	li	a0,256
ffffffffc02033b6:	35d000ef          	jal	ra,ffffffffc0203f12 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02033ba:	10040593          	addi	a1,s0,256
ffffffffc02033be:	10000513          	li	a0,256
ffffffffc02033c2:	363000ef          	jal	ra,ffffffffc0203f24 <strcmp>
ffffffffc02033c6:	70051563          	bnez	a0,ffffffffc0203ad0 <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02033ca:	000b3683          	ld	a3,0(s6)
ffffffffc02033ce:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033d2:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02033d4:	40da86b3          	sub	a3,s5,a3
ffffffffc02033d8:	868d                	srai	a3,a3,0x3
ffffffffc02033da:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033de:	609c                	ld	a5,0(s1)
ffffffffc02033e0:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02033e2:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033e4:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc02033e8:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033ea:	52f77b63          	bgeu	a4,a5,ffffffffc0203920 <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02033ee:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02033f2:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02033f6:	96be                	add	a3,a3,a5
ffffffffc02033f8:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb90>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02033fc:	2e1000ef          	jal	ra,ffffffffc0203edc <strlen>
ffffffffc0203400:	6a051863          	bnez	a0,ffffffffc0203ab0 <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203404:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203408:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020340a:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc020340e:	078a                	slli	a5,a5,0x2
ffffffffc0203410:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203412:	22e7fe63          	bgeu	a5,a4,ffffffffc020364e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203416:	41a787b3          	sub	a5,a5,s10
ffffffffc020341a:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020341e:	96be                	add	a3,a3,a5
ffffffffc0203420:	03968cb3          	mul	s9,a3,s9
ffffffffc0203424:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203428:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020342a:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020342c:	4ee47a63          	bgeu	s0,a4,ffffffffc0203920 <pmm_init+0xa14>
ffffffffc0203430:	0009b403          	ld	s0,0(s3)
ffffffffc0203434:	9436                	add	s0,s0,a3
ffffffffc0203436:	100027f3          	csrr	a5,sstatus
ffffffffc020343a:	8b89                	andi	a5,a5,2
ffffffffc020343c:	1a079163          	bnez	a5,ffffffffc02035de <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203440:	000bb783          	ld	a5,0(s7)
ffffffffc0203444:	4585                	li	a1,1
ffffffffc0203446:	8556                	mv	a0,s5
ffffffffc0203448:	739c                	ld	a5,32(a5)
ffffffffc020344a:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020344c:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020344e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203450:	078a                	slli	a5,a5,0x2
ffffffffc0203452:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203454:	1ee7fd63          	bgeu	a5,a4,ffffffffc020364e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203458:	fff80737          	lui	a4,0xfff80
ffffffffc020345c:	97ba                	add	a5,a5,a4
ffffffffc020345e:	000b3503          	ld	a0,0(s6)
ffffffffc0203462:	00379713          	slli	a4,a5,0x3
ffffffffc0203466:	97ba                	add	a5,a5,a4
ffffffffc0203468:	078e                	slli	a5,a5,0x3
ffffffffc020346a:	953e                	add	a0,a0,a5
ffffffffc020346c:	100027f3          	csrr	a5,sstatus
ffffffffc0203470:	8b89                	andi	a5,a5,2
ffffffffc0203472:	14079a63          	bnez	a5,ffffffffc02035c6 <pmm_init+0x6ba>
ffffffffc0203476:	000bb783          	ld	a5,0(s7)
ffffffffc020347a:	4585                	li	a1,1
ffffffffc020347c:	739c                	ld	a5,32(a5)
ffffffffc020347e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203480:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0203484:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203486:	078a                	slli	a5,a5,0x2
ffffffffc0203488:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020348a:	1ce7f263          	bgeu	a5,a4,ffffffffc020364e <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020348e:	fff80737          	lui	a4,0xfff80
ffffffffc0203492:	97ba                	add	a5,a5,a4
ffffffffc0203494:	000b3503          	ld	a0,0(s6)
ffffffffc0203498:	00379713          	slli	a4,a5,0x3
ffffffffc020349c:	97ba                	add	a5,a5,a4
ffffffffc020349e:	078e                	slli	a5,a5,0x3
ffffffffc02034a0:	953e                	add	a0,a0,a5
ffffffffc02034a2:	100027f3          	csrr	a5,sstatus
ffffffffc02034a6:	8b89                	andi	a5,a5,2
ffffffffc02034a8:	10079363          	bnez	a5,ffffffffc02035ae <pmm_init+0x6a2>
ffffffffc02034ac:	000bb783          	ld	a5,0(s7)
ffffffffc02034b0:	4585                	li	a1,1
ffffffffc02034b2:	739c                	ld	a5,32(a5)
ffffffffc02034b4:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02034b6:	00093783          	ld	a5,0(s2)
ffffffffc02034ba:	0007b023          	sd	zero,0(a5)
ffffffffc02034be:	100027f3          	csrr	a5,sstatus
ffffffffc02034c2:	8b89                	andi	a5,a5,2
ffffffffc02034c4:	0c079b63          	bnez	a5,ffffffffc020359a <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02034c8:	000bb783          	ld	a5,0(s7)
ffffffffc02034cc:	779c                	ld	a5,40(a5)
ffffffffc02034ce:	9782                	jalr	a5
ffffffffc02034d0:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc02034d2:	3a8c1763          	bne	s8,s0,ffffffffc0203880 <pmm_init+0x974>
}
ffffffffc02034d6:	7406                	ld	s0,96(sp)
ffffffffc02034d8:	70a6                	ld	ra,104(sp)
ffffffffc02034da:	64e6                	ld	s1,88(sp)
ffffffffc02034dc:	6946                	ld	s2,80(sp)
ffffffffc02034de:	69a6                	ld	s3,72(sp)
ffffffffc02034e0:	6a06                	ld	s4,64(sp)
ffffffffc02034e2:	7ae2                	ld	s5,56(sp)
ffffffffc02034e4:	7b42                	ld	s6,48(sp)
ffffffffc02034e6:	7ba2                	ld	s7,40(sp)
ffffffffc02034e8:	7c02                	ld	s8,32(sp)
ffffffffc02034ea:	6ce2                	ld	s9,24(sp)
ffffffffc02034ec:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02034ee:	00003517          	auipc	a0,0x3
ffffffffc02034f2:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0205ef8 <default_pmm_manager+0x688>
}
ffffffffc02034f6:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02034f8:	bc3fc06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02034fc:	6705                	lui	a4,0x1
ffffffffc02034fe:	177d                	addi	a4,a4,-1
ffffffffc0203500:	96ba                	add	a3,a3,a4
ffffffffc0203502:	777d                	lui	a4,0xfffff
ffffffffc0203504:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc0203506:	00c75693          	srli	a3,a4,0xc
ffffffffc020350a:	14f6f263          	bgeu	a3,a5,ffffffffc020364e <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc020350e:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0203512:	95b6                	add	a1,a1,a3
ffffffffc0203514:	00359793          	slli	a5,a1,0x3
ffffffffc0203518:	97ae                	add	a5,a5,a1
ffffffffc020351a:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020351e:	40e60733          	sub	a4,a2,a4
ffffffffc0203522:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0203524:	00c75593          	srli	a1,a4,0xc
ffffffffc0203528:	953e                	add	a0,a0,a5
ffffffffc020352a:	9682                	jalr	a3
}
ffffffffc020352c:	bcc5                	j	ffffffffc020301c <pmm_init+0x110>
        intr_disable();
ffffffffc020352e:	fc1fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203532:	000bb783          	ld	a5,0(s7)
ffffffffc0203536:	779c                	ld	a5,40(a5)
ffffffffc0203538:	9782                	jalr	a5
ffffffffc020353a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020353c:	fadfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203540:	b63d                	j	ffffffffc020306e <pmm_init+0x162>
        intr_disable();
ffffffffc0203542:	fadfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203546:	000bb783          	ld	a5,0(s7)
ffffffffc020354a:	779c                	ld	a5,40(a5)
ffffffffc020354c:	9782                	jalr	a5
ffffffffc020354e:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0203550:	f99fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203554:	b3c1                	j	ffffffffc0203314 <pmm_init+0x408>
        intr_disable();
ffffffffc0203556:	f99fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020355a:	000bb783          	ld	a5,0(s7)
ffffffffc020355e:	779c                	ld	a5,40(a5)
ffffffffc0203560:	9782                	jalr	a5
ffffffffc0203562:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0203564:	f85fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203568:	b361                	j	ffffffffc02032f0 <pmm_init+0x3e4>
ffffffffc020356a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020356c:	f83fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203570:	000bb783          	ld	a5,0(s7)
ffffffffc0203574:	6522                	ld	a0,8(sp)
ffffffffc0203576:	4585                	li	a1,1
ffffffffc0203578:	739c                	ld	a5,32(a5)
ffffffffc020357a:	9782                	jalr	a5
        intr_enable();
ffffffffc020357c:	f6dfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203580:	bb91                	j	ffffffffc02032d4 <pmm_init+0x3c8>
ffffffffc0203582:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203584:	f6bfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203588:	000bb783          	ld	a5,0(s7)
ffffffffc020358c:	6522                	ld	a0,8(sp)
ffffffffc020358e:	4585                	li	a1,1
ffffffffc0203590:	739c                	ld	a5,32(a5)
ffffffffc0203592:	9782                	jalr	a5
        intr_enable();
ffffffffc0203594:	f55fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203598:	b319                	j	ffffffffc020329e <pmm_init+0x392>
        intr_disable();
ffffffffc020359a:	f55fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020359e:	000bb783          	ld	a5,0(s7)
ffffffffc02035a2:	779c                	ld	a5,40(a5)
ffffffffc02035a4:	9782                	jalr	a5
ffffffffc02035a6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02035a8:	f41fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02035ac:	b71d                	j	ffffffffc02034d2 <pmm_init+0x5c6>
ffffffffc02035ae:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02035b0:	f3ffc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02035b4:	000bb783          	ld	a5,0(s7)
ffffffffc02035b8:	6522                	ld	a0,8(sp)
ffffffffc02035ba:	4585                	li	a1,1
ffffffffc02035bc:	739c                	ld	a5,32(a5)
ffffffffc02035be:	9782                	jalr	a5
        intr_enable();
ffffffffc02035c0:	f29fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02035c4:	bdcd                	j	ffffffffc02034b6 <pmm_init+0x5aa>
ffffffffc02035c6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02035c8:	f27fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02035cc:	000bb783          	ld	a5,0(s7)
ffffffffc02035d0:	6522                	ld	a0,8(sp)
ffffffffc02035d2:	4585                	li	a1,1
ffffffffc02035d4:	739c                	ld	a5,32(a5)
ffffffffc02035d6:	9782                	jalr	a5
        intr_enable();
ffffffffc02035d8:	f11fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02035dc:	b555                	j	ffffffffc0203480 <pmm_init+0x574>
        intr_disable();
ffffffffc02035de:	f11fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02035e2:	000bb783          	ld	a5,0(s7)
ffffffffc02035e6:	4585                	li	a1,1
ffffffffc02035e8:	8556                	mv	a0,s5
ffffffffc02035ea:	739c                	ld	a5,32(a5)
ffffffffc02035ec:	9782                	jalr	a5
        intr_enable();
ffffffffc02035ee:	efbfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02035f2:	bda9                	j	ffffffffc020344c <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02035f4:	00002697          	auipc	a3,0x2
ffffffffc02035f8:	7b468693          	addi	a3,a3,1972 # ffffffffc0205da8 <default_pmm_manager+0x538>
ffffffffc02035fc:	00001617          	auipc	a2,0x1
ffffffffc0203600:	7cc60613          	addi	a2,a2,1996 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203604:	1d100593          	li	a1,465
ffffffffc0203608:	00002517          	auipc	a0,0x2
ffffffffc020360c:	39850513          	addi	a0,a0,920 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203610:	af3fc0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203614:	00002697          	auipc	a3,0x2
ffffffffc0203618:	75468693          	addi	a3,a3,1876 # ffffffffc0205d68 <default_pmm_manager+0x4f8>
ffffffffc020361c:	00001617          	auipc	a2,0x1
ffffffffc0203620:	7ac60613          	addi	a2,a2,1964 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203624:	1d000593          	li	a1,464
ffffffffc0203628:	00002517          	auipc	a0,0x2
ffffffffc020362c:	37850513          	addi	a0,a0,888 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203630:	ad3fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203634:	86a2                	mv	a3,s0
ffffffffc0203636:	00002617          	auipc	a2,0x2
ffffffffc020363a:	34260613          	addi	a2,a2,834 # ffffffffc0205978 <default_pmm_manager+0x108>
ffffffffc020363e:	1d000593          	li	a1,464
ffffffffc0203642:	00002517          	auipc	a0,0x2
ffffffffc0203646:	35e50513          	addi	a0,a0,862 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc020364a:	ab9fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc020364e:	b90ff0ef          	jal	ra,ffffffffc02029de <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203652:	00002617          	auipc	a2,0x2
ffffffffc0203656:	3e660613          	addi	a2,a2,998 # ffffffffc0205a38 <default_pmm_manager+0x1c8>
ffffffffc020365a:	07600593          	li	a1,118
ffffffffc020365e:	00002517          	auipc	a0,0x2
ffffffffc0203662:	34250513          	addi	a0,a0,834 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203666:	a9dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020366a:	00002617          	auipc	a2,0x2
ffffffffc020366e:	3ce60613          	addi	a2,a2,974 # ffffffffc0205a38 <default_pmm_manager+0x1c8>
ffffffffc0203672:	0c500593          	li	a1,197
ffffffffc0203676:	00002517          	auipc	a0,0x2
ffffffffc020367a:	32a50513          	addi	a0,a0,810 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc020367e:	a85fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203682:	00002697          	auipc	a3,0x2
ffffffffc0203686:	41e68693          	addi	a3,a3,1054 # ffffffffc0205aa0 <default_pmm_manager+0x230>
ffffffffc020368a:	00001617          	auipc	a2,0x1
ffffffffc020368e:	73e60613          	addi	a2,a2,1854 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203692:	19600593          	li	a1,406
ffffffffc0203696:	00002517          	auipc	a0,0x2
ffffffffc020369a:	30a50513          	addi	a0,a0,778 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc020369e:	a65fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02036a2:	00002697          	auipc	a3,0x2
ffffffffc02036a6:	3de68693          	addi	a3,a3,990 # ffffffffc0205a80 <default_pmm_manager+0x210>
ffffffffc02036aa:	00001617          	auipc	a2,0x1
ffffffffc02036ae:	71e60613          	addi	a2,a2,1822 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02036b2:	19500593          	li	a1,405
ffffffffc02036b6:	00002517          	auipc	a0,0x2
ffffffffc02036ba:	2ea50513          	addi	a0,a0,746 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc02036be:	a45fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc02036c2:	b38ff0ef          	jal	ra,ffffffffc02029fa <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02036c6:	00002697          	auipc	a3,0x2
ffffffffc02036ca:	46a68693          	addi	a3,a3,1130 # ffffffffc0205b30 <default_pmm_manager+0x2c0>
ffffffffc02036ce:	00001617          	auipc	a2,0x1
ffffffffc02036d2:	6fa60613          	addi	a2,a2,1786 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02036d6:	19d00593          	li	a1,413
ffffffffc02036da:	00002517          	auipc	a0,0x2
ffffffffc02036de:	2c650513          	addi	a0,a0,710 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc02036e2:	a21fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02036e6:	00002697          	auipc	a3,0x2
ffffffffc02036ea:	41a68693          	addi	a3,a3,1050 # ffffffffc0205b00 <default_pmm_manager+0x290>
ffffffffc02036ee:	00001617          	auipc	a2,0x1
ffffffffc02036f2:	6da60613          	addi	a2,a2,1754 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02036f6:	19b00593          	li	a1,411
ffffffffc02036fa:	00002517          	auipc	a0,0x2
ffffffffc02036fe:	2a650513          	addi	a0,a0,678 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203702:	a01fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203706:	00002697          	auipc	a3,0x2
ffffffffc020370a:	3d268693          	addi	a3,a3,978 # ffffffffc0205ad8 <default_pmm_manager+0x268>
ffffffffc020370e:	00001617          	auipc	a2,0x1
ffffffffc0203712:	6ba60613          	addi	a2,a2,1722 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203716:	19700593          	li	a1,407
ffffffffc020371a:	00002517          	auipc	a0,0x2
ffffffffc020371e:	28650513          	addi	a0,a0,646 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203722:	9e1fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203726:	00002697          	auipc	a3,0x2
ffffffffc020372a:	49268693          	addi	a3,a3,1170 # ffffffffc0205bb8 <default_pmm_manager+0x348>
ffffffffc020372e:	00001617          	auipc	a2,0x1
ffffffffc0203732:	69a60613          	addi	a2,a2,1690 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203736:	1a600593          	li	a1,422
ffffffffc020373a:	00002517          	auipc	a0,0x2
ffffffffc020373e:	26650513          	addi	a0,a0,614 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203742:	9c1fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203746:	00002697          	auipc	a3,0x2
ffffffffc020374a:	51268693          	addi	a3,a3,1298 # ffffffffc0205c58 <default_pmm_manager+0x3e8>
ffffffffc020374e:	00001617          	auipc	a2,0x1
ffffffffc0203752:	67a60613          	addi	a2,a2,1658 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203756:	1ab00593          	li	a1,427
ffffffffc020375a:	00002517          	auipc	a0,0x2
ffffffffc020375e:	24650513          	addi	a0,a0,582 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203762:	9a1fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203766:	00002697          	auipc	a3,0x2
ffffffffc020376a:	42a68693          	addi	a3,a3,1066 # ffffffffc0205b90 <default_pmm_manager+0x320>
ffffffffc020376e:	00001617          	auipc	a2,0x1
ffffffffc0203772:	65a60613          	addi	a2,a2,1626 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203776:	1a300593          	li	a1,419
ffffffffc020377a:	00002517          	auipc	a0,0x2
ffffffffc020377e:	22650513          	addi	a0,a0,550 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203782:	981fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203786:	86d6                	mv	a3,s5
ffffffffc0203788:	00002617          	auipc	a2,0x2
ffffffffc020378c:	1f060613          	addi	a2,a2,496 # ffffffffc0205978 <default_pmm_manager+0x108>
ffffffffc0203790:	1a200593          	li	a1,418
ffffffffc0203794:	00002517          	auipc	a0,0x2
ffffffffc0203798:	20c50513          	addi	a0,a0,524 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc020379c:	967fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02037a0:	00002697          	auipc	a3,0x2
ffffffffc02037a4:	45068693          	addi	a3,a3,1104 # ffffffffc0205bf0 <default_pmm_manager+0x380>
ffffffffc02037a8:	00001617          	auipc	a2,0x1
ffffffffc02037ac:	62060613          	addi	a2,a2,1568 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02037b0:	1b000593          	li	a1,432
ffffffffc02037b4:	00002517          	auipc	a0,0x2
ffffffffc02037b8:	1ec50513          	addi	a0,a0,492 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc02037bc:	947fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02037c0:	00002697          	auipc	a3,0x2
ffffffffc02037c4:	4f868693          	addi	a3,a3,1272 # ffffffffc0205cb8 <default_pmm_manager+0x448>
ffffffffc02037c8:	00001617          	auipc	a2,0x1
ffffffffc02037cc:	60060613          	addi	a2,a2,1536 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02037d0:	1af00593          	li	a1,431
ffffffffc02037d4:	00002517          	auipc	a0,0x2
ffffffffc02037d8:	1cc50513          	addi	a0,a0,460 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc02037dc:	927fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02037e0:	00002697          	auipc	a3,0x2
ffffffffc02037e4:	4c068693          	addi	a3,a3,1216 # ffffffffc0205ca0 <default_pmm_manager+0x430>
ffffffffc02037e8:	00001617          	auipc	a2,0x1
ffffffffc02037ec:	5e060613          	addi	a2,a2,1504 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02037f0:	1ae00593          	li	a1,430
ffffffffc02037f4:	00002517          	auipc	a0,0x2
ffffffffc02037f8:	1ac50513          	addi	a0,a0,428 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc02037fc:	907fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203800:	00002697          	auipc	a3,0x2
ffffffffc0203804:	47068693          	addi	a3,a3,1136 # ffffffffc0205c70 <default_pmm_manager+0x400>
ffffffffc0203808:	00001617          	auipc	a2,0x1
ffffffffc020380c:	5c060613          	addi	a2,a2,1472 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203810:	1ad00593          	li	a1,429
ffffffffc0203814:	00002517          	auipc	a0,0x2
ffffffffc0203818:	18c50513          	addi	a0,a0,396 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc020381c:	8e7fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203820:	00002697          	auipc	a3,0x2
ffffffffc0203824:	60868693          	addi	a3,a3,1544 # ffffffffc0205e28 <default_pmm_manager+0x5b8>
ffffffffc0203828:	00001617          	auipc	a2,0x1
ffffffffc020382c:	5a060613          	addi	a2,a2,1440 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203830:	1db00593          	li	a1,475
ffffffffc0203834:	00002517          	auipc	a0,0x2
ffffffffc0203838:	16c50513          	addi	a0,a0,364 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc020383c:	8c7fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203840:	00002697          	auipc	a3,0x2
ffffffffc0203844:	40068693          	addi	a3,a3,1024 # ffffffffc0205c40 <default_pmm_manager+0x3d0>
ffffffffc0203848:	00001617          	auipc	a2,0x1
ffffffffc020384c:	58060613          	addi	a2,a2,1408 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203850:	1aa00593          	li	a1,426
ffffffffc0203854:	00002517          	auipc	a0,0x2
ffffffffc0203858:	14c50513          	addi	a0,a0,332 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc020385c:	8a7fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203860:	00002697          	auipc	a3,0x2
ffffffffc0203864:	3d068693          	addi	a3,a3,976 # ffffffffc0205c30 <default_pmm_manager+0x3c0>
ffffffffc0203868:	00001617          	auipc	a2,0x1
ffffffffc020386c:	56060613          	addi	a2,a2,1376 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203870:	1a900593          	li	a1,425
ffffffffc0203874:	00002517          	auipc	a0,0x2
ffffffffc0203878:	12c50513          	addi	a0,a0,300 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc020387c:	887fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203880:	00002697          	auipc	a3,0x2
ffffffffc0203884:	4a868693          	addi	a3,a3,1192 # ffffffffc0205d28 <default_pmm_manager+0x4b8>
ffffffffc0203888:	00001617          	auipc	a2,0x1
ffffffffc020388c:	54060613          	addi	a2,a2,1344 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203890:	1eb00593          	li	a1,491
ffffffffc0203894:	00002517          	auipc	a0,0x2
ffffffffc0203898:	10c50513          	addi	a0,a0,268 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc020389c:	867fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02038a0:	00002697          	auipc	a3,0x2
ffffffffc02038a4:	38068693          	addi	a3,a3,896 # ffffffffc0205c20 <default_pmm_manager+0x3b0>
ffffffffc02038a8:	00001617          	auipc	a2,0x1
ffffffffc02038ac:	52060613          	addi	a2,a2,1312 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02038b0:	1a800593          	li	a1,424
ffffffffc02038b4:	00002517          	auipc	a0,0x2
ffffffffc02038b8:	0ec50513          	addi	a0,a0,236 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc02038bc:	847fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02038c0:	00002697          	auipc	a3,0x2
ffffffffc02038c4:	2b868693          	addi	a3,a3,696 # ffffffffc0205b78 <default_pmm_manager+0x308>
ffffffffc02038c8:	00001617          	auipc	a2,0x1
ffffffffc02038cc:	50060613          	addi	a2,a2,1280 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02038d0:	1b500593          	li	a1,437
ffffffffc02038d4:	00002517          	auipc	a0,0x2
ffffffffc02038d8:	0cc50513          	addi	a0,a0,204 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc02038dc:	827fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02038e0:	00002697          	auipc	a3,0x2
ffffffffc02038e4:	3f068693          	addi	a3,a3,1008 # ffffffffc0205cd0 <default_pmm_manager+0x460>
ffffffffc02038e8:	00001617          	auipc	a2,0x1
ffffffffc02038ec:	4e060613          	addi	a2,a2,1248 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02038f0:	1b200593          	li	a1,434
ffffffffc02038f4:	00002517          	auipc	a0,0x2
ffffffffc02038f8:	0ac50513          	addi	a0,a0,172 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc02038fc:	807fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203900:	00002697          	auipc	a3,0x2
ffffffffc0203904:	26068693          	addi	a3,a3,608 # ffffffffc0205b60 <default_pmm_manager+0x2f0>
ffffffffc0203908:	00001617          	auipc	a2,0x1
ffffffffc020390c:	4c060613          	addi	a2,a2,1216 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203910:	1b100593          	li	a1,433
ffffffffc0203914:	00002517          	auipc	a0,0x2
ffffffffc0203918:	08c50513          	addi	a0,a0,140 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc020391c:	fe6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203920:	00002617          	auipc	a2,0x2
ffffffffc0203924:	05860613          	addi	a2,a2,88 # ffffffffc0205978 <default_pmm_manager+0x108>
ffffffffc0203928:	06c00593          	li	a1,108
ffffffffc020392c:	00001517          	auipc	a0,0x1
ffffffffc0203930:	70c50513          	addi	a0,a0,1804 # ffffffffc0205038 <commands+0x998>
ffffffffc0203934:	fcefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203938:	00002697          	auipc	a3,0x2
ffffffffc020393c:	3c868693          	addi	a3,a3,968 # ffffffffc0205d00 <default_pmm_manager+0x490>
ffffffffc0203940:	00001617          	auipc	a2,0x1
ffffffffc0203944:	48860613          	addi	a2,a2,1160 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203948:	1bc00593          	li	a1,444
ffffffffc020394c:	00002517          	auipc	a0,0x2
ffffffffc0203950:	05450513          	addi	a0,a0,84 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203954:	faefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203958:	00002697          	auipc	a3,0x2
ffffffffc020395c:	36068693          	addi	a3,a3,864 # ffffffffc0205cb8 <default_pmm_manager+0x448>
ffffffffc0203960:	00001617          	auipc	a2,0x1
ffffffffc0203964:	46860613          	addi	a2,a2,1128 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203968:	1ba00593          	li	a1,442
ffffffffc020396c:	00002517          	auipc	a0,0x2
ffffffffc0203970:	03450513          	addi	a0,a0,52 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203974:	f8efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203978:	00002697          	auipc	a3,0x2
ffffffffc020397c:	37068693          	addi	a3,a3,880 # ffffffffc0205ce8 <default_pmm_manager+0x478>
ffffffffc0203980:	00001617          	auipc	a2,0x1
ffffffffc0203984:	44860613          	addi	a2,a2,1096 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203988:	1b900593          	li	a1,441
ffffffffc020398c:	00002517          	auipc	a0,0x2
ffffffffc0203990:	01450513          	addi	a0,a0,20 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203994:	f6efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203998:	00002697          	auipc	a3,0x2
ffffffffc020399c:	32068693          	addi	a3,a3,800 # ffffffffc0205cb8 <default_pmm_manager+0x448>
ffffffffc02039a0:	00001617          	auipc	a2,0x1
ffffffffc02039a4:	42860613          	addi	a2,a2,1064 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02039a8:	1b600593          	li	a1,438
ffffffffc02039ac:	00002517          	auipc	a0,0x2
ffffffffc02039b0:	ff450513          	addi	a0,a0,-12 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc02039b4:	f4efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 1);
ffffffffc02039b8:	00002697          	auipc	a3,0x2
ffffffffc02039bc:	45868693          	addi	a3,a3,1112 # ffffffffc0205e10 <default_pmm_manager+0x5a0>
ffffffffc02039c0:	00001617          	auipc	a2,0x1
ffffffffc02039c4:	40860613          	addi	a2,a2,1032 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02039c8:	1da00593          	li	a1,474
ffffffffc02039cc:	00002517          	auipc	a0,0x2
ffffffffc02039d0:	fd450513          	addi	a0,a0,-44 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc02039d4:	f2efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02039d8:	00002697          	auipc	a3,0x2
ffffffffc02039dc:	40068693          	addi	a3,a3,1024 # ffffffffc0205dd8 <default_pmm_manager+0x568>
ffffffffc02039e0:	00001617          	auipc	a2,0x1
ffffffffc02039e4:	3e860613          	addi	a2,a2,1000 # ffffffffc0204dc8 <commands+0x728>
ffffffffc02039e8:	1d900593          	li	a1,473
ffffffffc02039ec:	00002517          	auipc	a0,0x2
ffffffffc02039f0:	fb450513          	addi	a0,a0,-76 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc02039f4:	f0efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02039f8:	00002697          	auipc	a3,0x2
ffffffffc02039fc:	3c868693          	addi	a3,a3,968 # ffffffffc0205dc0 <default_pmm_manager+0x550>
ffffffffc0203a00:	00001617          	auipc	a2,0x1
ffffffffc0203a04:	3c860613          	addi	a2,a2,968 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203a08:	1d500593          	li	a1,469
ffffffffc0203a0c:	00002517          	auipc	a0,0x2
ffffffffc0203a10:	f9450513          	addi	a0,a0,-108 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203a14:	eeefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203a18:	00002697          	auipc	a3,0x2
ffffffffc0203a1c:	31068693          	addi	a3,a3,784 # ffffffffc0205d28 <default_pmm_manager+0x4b8>
ffffffffc0203a20:	00001617          	auipc	a2,0x1
ffffffffc0203a24:	3a860613          	addi	a2,a2,936 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203a28:	1c300593          	li	a1,451
ffffffffc0203a2c:	00002517          	auipc	a0,0x2
ffffffffc0203a30:	f7450513          	addi	a0,a0,-140 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203a34:	ecefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203a38:	00002697          	auipc	a3,0x2
ffffffffc0203a3c:	12868693          	addi	a3,a3,296 # ffffffffc0205b60 <default_pmm_manager+0x2f0>
ffffffffc0203a40:	00001617          	auipc	a2,0x1
ffffffffc0203a44:	38860613          	addi	a2,a2,904 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203a48:	19e00593          	li	a1,414
ffffffffc0203a4c:	00002517          	auipc	a0,0x2
ffffffffc0203a50:	f5450513          	addi	a0,a0,-172 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203a54:	eaefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203a58:	00002617          	auipc	a2,0x2
ffffffffc0203a5c:	f2060613          	addi	a2,a2,-224 # ffffffffc0205978 <default_pmm_manager+0x108>
ffffffffc0203a60:	1a100593          	li	a1,417
ffffffffc0203a64:	00002517          	auipc	a0,0x2
ffffffffc0203a68:	f3c50513          	addi	a0,a0,-196 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203a6c:	e96fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203a70:	00002697          	auipc	a3,0x2
ffffffffc0203a74:	10868693          	addi	a3,a3,264 # ffffffffc0205b78 <default_pmm_manager+0x308>
ffffffffc0203a78:	00001617          	auipc	a2,0x1
ffffffffc0203a7c:	35060613          	addi	a2,a2,848 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203a80:	19f00593          	li	a1,415
ffffffffc0203a84:	00002517          	auipc	a0,0x2
ffffffffc0203a88:	f1c50513          	addi	a0,a0,-228 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203a8c:	e76fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203a90:	00002697          	auipc	a3,0x2
ffffffffc0203a94:	16068693          	addi	a3,a3,352 # ffffffffc0205bf0 <default_pmm_manager+0x380>
ffffffffc0203a98:	00001617          	auipc	a2,0x1
ffffffffc0203a9c:	33060613          	addi	a2,a2,816 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203aa0:	1a700593          	li	a1,423
ffffffffc0203aa4:	00002517          	auipc	a0,0x2
ffffffffc0203aa8:	efc50513          	addi	a0,a0,-260 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203aac:	e56fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203ab0:	00002697          	auipc	a3,0x2
ffffffffc0203ab4:	42068693          	addi	a3,a3,1056 # ffffffffc0205ed0 <default_pmm_manager+0x660>
ffffffffc0203ab8:	00001617          	auipc	a2,0x1
ffffffffc0203abc:	31060613          	addi	a2,a2,784 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203ac0:	1e300593          	li	a1,483
ffffffffc0203ac4:	00002517          	auipc	a0,0x2
ffffffffc0203ac8:	edc50513          	addi	a0,a0,-292 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203acc:	e36fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203ad0:	00002697          	auipc	a3,0x2
ffffffffc0203ad4:	3c868693          	addi	a3,a3,968 # ffffffffc0205e98 <default_pmm_manager+0x628>
ffffffffc0203ad8:	00001617          	auipc	a2,0x1
ffffffffc0203adc:	2f060613          	addi	a2,a2,752 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203ae0:	1e000593          	li	a1,480
ffffffffc0203ae4:	00002517          	auipc	a0,0x2
ffffffffc0203ae8:	ebc50513          	addi	a0,a0,-324 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203aec:	e16fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203af0:	00002697          	auipc	a3,0x2
ffffffffc0203af4:	37868693          	addi	a3,a3,888 # ffffffffc0205e68 <default_pmm_manager+0x5f8>
ffffffffc0203af8:	00001617          	auipc	a2,0x1
ffffffffc0203afc:	2d060613          	addi	a2,a2,720 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203b00:	1dc00593          	li	a1,476
ffffffffc0203b04:	00002517          	auipc	a0,0x2
ffffffffc0203b08:	e9c50513          	addi	a0,a0,-356 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203b0c:	df6fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203b10 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0203b10:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0203b14:	8082                	ret

ffffffffc0203b16 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203b16:	7179                	addi	sp,sp,-48
ffffffffc0203b18:	e84a                	sd	s2,16(sp)
ffffffffc0203b1a:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203b1c:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203b1e:	f022                	sd	s0,32(sp)
ffffffffc0203b20:	ec26                	sd	s1,24(sp)
ffffffffc0203b22:	e44e                	sd	s3,8(sp)
ffffffffc0203b24:	f406                	sd	ra,40(sp)
ffffffffc0203b26:	84ae                	mv	s1,a1
ffffffffc0203b28:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203b2a:	eedfe0ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
ffffffffc0203b2e:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203b30:	cd09                	beqz	a0,ffffffffc0203b4a <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203b32:	85aa                	mv	a1,a0
ffffffffc0203b34:	86ce                	mv	a3,s3
ffffffffc0203b36:	8626                	mv	a2,s1
ffffffffc0203b38:	854a                	mv	a0,s2
ffffffffc0203b3a:	ad2ff0ef          	jal	ra,ffffffffc0202e0c <page_insert>
ffffffffc0203b3e:	ed21                	bnez	a0,ffffffffc0203b96 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0203b40:	0000e797          	auipc	a5,0xe
ffffffffc0203b44:	9f07a783          	lw	a5,-1552(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc0203b48:	eb89                	bnez	a5,ffffffffc0203b5a <pgdir_alloc_page+0x44>
}
ffffffffc0203b4a:	70a2                	ld	ra,40(sp)
ffffffffc0203b4c:	8522                	mv	a0,s0
ffffffffc0203b4e:	7402                	ld	s0,32(sp)
ffffffffc0203b50:	64e2                	ld	s1,24(sp)
ffffffffc0203b52:	6942                	ld	s2,16(sp)
ffffffffc0203b54:	69a2                	ld	s3,8(sp)
ffffffffc0203b56:	6145                	addi	sp,sp,48
ffffffffc0203b58:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203b5a:	4681                	li	a3,0
ffffffffc0203b5c:	8622                	mv	a2,s0
ffffffffc0203b5e:	85a6                	mv	a1,s1
ffffffffc0203b60:	0000e517          	auipc	a0,0xe
ffffffffc0203b64:	9b053503          	ld	a0,-1616(a0) # ffffffffc0211510 <check_mm_struct>
ffffffffc0203b68:	e45fd0ef          	jal	ra,ffffffffc02019ac <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0203b6c:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0203b6e:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0203b70:	4785                	li	a5,1
ffffffffc0203b72:	fcf70ce3          	beq	a4,a5,ffffffffc0203b4a <pgdir_alloc_page+0x34>
ffffffffc0203b76:	00002697          	auipc	a3,0x2
ffffffffc0203b7a:	3a268693          	addi	a3,a3,930 # ffffffffc0205f18 <default_pmm_manager+0x6a8>
ffffffffc0203b7e:	00001617          	auipc	a2,0x1
ffffffffc0203b82:	24a60613          	addi	a2,a2,586 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203b86:	17d00593          	li	a1,381
ffffffffc0203b8a:	00002517          	auipc	a0,0x2
ffffffffc0203b8e:	e1650513          	addi	a0,a0,-490 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203b92:	d70fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203b96:	100027f3          	csrr	a5,sstatus
ffffffffc0203b9a:	8b89                	andi	a5,a5,2
ffffffffc0203b9c:	eb99                	bnez	a5,ffffffffc0203bb2 <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203b9e:	0000e797          	auipc	a5,0xe
ffffffffc0203ba2:	9c27b783          	ld	a5,-1598(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0203ba6:	739c                	ld	a5,32(a5)
ffffffffc0203ba8:	8522                	mv	a0,s0
ffffffffc0203baa:	4585                	li	a1,1
ffffffffc0203bac:	9782                	jalr	a5
            return NULL;
ffffffffc0203bae:	4401                	li	s0,0
ffffffffc0203bb0:	bf69                	j	ffffffffc0203b4a <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0203bb2:	93dfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203bb6:	0000e797          	auipc	a5,0xe
ffffffffc0203bba:	9aa7b783          	ld	a5,-1622(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0203bbe:	739c                	ld	a5,32(a5)
ffffffffc0203bc0:	8522                	mv	a0,s0
ffffffffc0203bc2:	4585                	li	a1,1
ffffffffc0203bc4:	9782                	jalr	a5
            return NULL;
ffffffffc0203bc6:	4401                	li	s0,0
        intr_enable();
ffffffffc0203bc8:	921fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203bcc:	bfbd                	j	ffffffffc0203b4a <pgdir_alloc_page+0x34>

ffffffffc0203bce <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0203bce:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203bd0:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0203bd2:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203bd4:	fff50713          	addi	a4,a0,-1
ffffffffc0203bd8:	17f9                	addi	a5,a5,-2
ffffffffc0203bda:	04e7ea63          	bltu	a5,a4,ffffffffc0203c2e <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203bde:	6785                	lui	a5,0x1
ffffffffc0203be0:	17fd                	addi	a5,a5,-1
ffffffffc0203be2:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0203be4:	8131                	srli	a0,a0,0xc
ffffffffc0203be6:	e31fe0ef          	jal	ra,ffffffffc0202a16 <alloc_pages>
    assert(base != NULL);
ffffffffc0203bea:	cd3d                	beqz	a0,ffffffffc0203c68 <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203bec:	0000e797          	auipc	a5,0xe
ffffffffc0203bf0:	96c7b783          	ld	a5,-1684(a5) # ffffffffc0211558 <pages>
ffffffffc0203bf4:	8d1d                	sub	a0,a0,a5
ffffffffc0203bf6:	00002697          	auipc	a3,0x2
ffffffffc0203bfa:	61a6b683          	ld	a3,1562(a3) # ffffffffc0206210 <error_string+0x38>
ffffffffc0203bfe:	850d                	srai	a0,a0,0x3
ffffffffc0203c00:	02d50533          	mul	a0,a0,a3
ffffffffc0203c04:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c08:	0000e717          	auipc	a4,0xe
ffffffffc0203c0c:	94873703          	ld	a4,-1720(a4) # ffffffffc0211550 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c10:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c12:	00c51793          	slli	a5,a0,0xc
ffffffffc0203c16:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203c18:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c1a:	02e7fa63          	bgeu	a5,a4,ffffffffc0203c4e <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0203c1e:	60a2                	ld	ra,8(sp)
ffffffffc0203c20:	0000e797          	auipc	a5,0xe
ffffffffc0203c24:	9487b783          	ld	a5,-1720(a5) # ffffffffc0211568 <va_pa_offset>
ffffffffc0203c28:	953e                	add	a0,a0,a5
ffffffffc0203c2a:	0141                	addi	sp,sp,16
ffffffffc0203c2c:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203c2e:	00002697          	auipc	a3,0x2
ffffffffc0203c32:	30268693          	addi	a3,a3,770 # ffffffffc0205f30 <default_pmm_manager+0x6c0>
ffffffffc0203c36:	00001617          	auipc	a2,0x1
ffffffffc0203c3a:	19260613          	addi	a2,a2,402 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203c3e:	1f300593          	li	a1,499
ffffffffc0203c42:	00002517          	auipc	a0,0x2
ffffffffc0203c46:	d5e50513          	addi	a0,a0,-674 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203c4a:	cb8fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203c4e:	86aa                	mv	a3,a0
ffffffffc0203c50:	00002617          	auipc	a2,0x2
ffffffffc0203c54:	d2860613          	addi	a2,a2,-728 # ffffffffc0205978 <default_pmm_manager+0x108>
ffffffffc0203c58:	06c00593          	li	a1,108
ffffffffc0203c5c:	00001517          	auipc	a0,0x1
ffffffffc0203c60:	3dc50513          	addi	a0,a0,988 # ffffffffc0205038 <commands+0x998>
ffffffffc0203c64:	c9efc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(base != NULL);
ffffffffc0203c68:	00002697          	auipc	a3,0x2
ffffffffc0203c6c:	2e868693          	addi	a3,a3,744 # ffffffffc0205f50 <default_pmm_manager+0x6e0>
ffffffffc0203c70:	00001617          	auipc	a2,0x1
ffffffffc0203c74:	15860613          	addi	a2,a2,344 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203c78:	1f600593          	li	a1,502
ffffffffc0203c7c:	00002517          	auipc	a0,0x2
ffffffffc0203c80:	d2450513          	addi	a0,a0,-732 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203c84:	c7efc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203c88 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0203c88:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203c8a:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0203c8c:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203c8e:	fff58713          	addi	a4,a1,-1
ffffffffc0203c92:	17f9                	addi	a5,a5,-2
ffffffffc0203c94:	0ae7ee63          	bltu	a5,a4,ffffffffc0203d50 <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0203c98:	cd41                	beqz	a0,ffffffffc0203d30 <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203c9a:	6785                	lui	a5,0x1
ffffffffc0203c9c:	17fd                	addi	a5,a5,-1
ffffffffc0203c9e:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203ca0:	c02007b7          	lui	a5,0xc0200
ffffffffc0203ca4:	81b1                	srli	a1,a1,0xc
ffffffffc0203ca6:	06f56863          	bltu	a0,a5,ffffffffc0203d16 <kfree+0x8e>
ffffffffc0203caa:	0000e697          	auipc	a3,0xe
ffffffffc0203cae:	8be6b683          	ld	a3,-1858(a3) # ffffffffc0211568 <va_pa_offset>
ffffffffc0203cb2:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc0203cb4:	8131                	srli	a0,a0,0xc
ffffffffc0203cb6:	0000e797          	auipc	a5,0xe
ffffffffc0203cba:	89a7b783          	ld	a5,-1894(a5) # ffffffffc0211550 <npage>
ffffffffc0203cbe:	04f57a63          	bgeu	a0,a5,ffffffffc0203d12 <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc0203cc2:	fff806b7          	lui	a3,0xfff80
ffffffffc0203cc6:	9536                	add	a0,a0,a3
ffffffffc0203cc8:	00351793          	slli	a5,a0,0x3
ffffffffc0203ccc:	953e                	add	a0,a0,a5
ffffffffc0203cce:	050e                	slli	a0,a0,0x3
ffffffffc0203cd0:	0000e797          	auipc	a5,0xe
ffffffffc0203cd4:	8887b783          	ld	a5,-1912(a5) # ffffffffc0211558 <pages>
ffffffffc0203cd8:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203cda:	100027f3          	csrr	a5,sstatus
ffffffffc0203cde:	8b89                	andi	a5,a5,2
ffffffffc0203ce0:	eb89                	bnez	a5,ffffffffc0203cf2 <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203ce2:	0000e797          	auipc	a5,0xe
ffffffffc0203ce6:	87e7b783          	ld	a5,-1922(a5) # ffffffffc0211560 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0203cea:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc0203cec:	739c                	ld	a5,32(a5)
}
ffffffffc0203cee:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc0203cf0:	8782                	jr	a5
        intr_disable();
ffffffffc0203cf2:	e42a                	sd	a0,8(sp)
ffffffffc0203cf4:	e02e                	sd	a1,0(sp)
ffffffffc0203cf6:	ff8fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203cfa:	0000e797          	auipc	a5,0xe
ffffffffc0203cfe:	8667b783          	ld	a5,-1946(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0203d02:	6582                	ld	a1,0(sp)
ffffffffc0203d04:	6522                	ld	a0,8(sp)
ffffffffc0203d06:	739c                	ld	a5,32(a5)
ffffffffc0203d08:	9782                	jalr	a5
}
ffffffffc0203d0a:	60e2                	ld	ra,24(sp)
ffffffffc0203d0c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203d0e:	fdafc06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc0203d12:	ccdfe0ef          	jal	ra,ffffffffc02029de <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203d16:	86aa                	mv	a3,a0
ffffffffc0203d18:	00002617          	auipc	a2,0x2
ffffffffc0203d1c:	d2060613          	addi	a2,a2,-736 # ffffffffc0205a38 <default_pmm_manager+0x1c8>
ffffffffc0203d20:	06e00593          	li	a1,110
ffffffffc0203d24:	00001517          	auipc	a0,0x1
ffffffffc0203d28:	31450513          	addi	a0,a0,788 # ffffffffc0205038 <commands+0x998>
ffffffffc0203d2c:	bd6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(ptr != NULL);
ffffffffc0203d30:	00002697          	auipc	a3,0x2
ffffffffc0203d34:	23068693          	addi	a3,a3,560 # ffffffffc0205f60 <default_pmm_manager+0x6f0>
ffffffffc0203d38:	00001617          	auipc	a2,0x1
ffffffffc0203d3c:	09060613          	addi	a2,a2,144 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203d40:	1fd00593          	li	a1,509
ffffffffc0203d44:	00002517          	auipc	a0,0x2
ffffffffc0203d48:	c5c50513          	addi	a0,a0,-932 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203d4c:	bb6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203d50:	00002697          	auipc	a3,0x2
ffffffffc0203d54:	1e068693          	addi	a3,a3,480 # ffffffffc0205f30 <default_pmm_manager+0x6c0>
ffffffffc0203d58:	00001617          	auipc	a2,0x1
ffffffffc0203d5c:	07060613          	addi	a2,a2,112 # ffffffffc0204dc8 <commands+0x728>
ffffffffc0203d60:	1fc00593          	li	a1,508
ffffffffc0203d64:	00002517          	auipc	a0,0x2
ffffffffc0203d68:	c3c50513          	addi	a0,a0,-964 # ffffffffc02059a0 <default_pmm_manager+0x130>
ffffffffc0203d6c:	b96fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203d70 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203d70:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203d72:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203d74:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203d76:	e5cfc0ef          	jal	ra,ffffffffc02003d2 <ide_device_valid>
ffffffffc0203d7a:	cd01                	beqz	a0,ffffffffc0203d92 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203d7c:	4505                	li	a0,1
ffffffffc0203d7e:	e5afc0ef          	jal	ra,ffffffffc02003d8 <ide_device_size>
}
ffffffffc0203d82:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203d84:	810d                	srli	a0,a0,0x3
ffffffffc0203d86:	0000d797          	auipc	a5,0xd
ffffffffc0203d8a:	78a7bd23          	sd	a0,1946(a5) # ffffffffc0211520 <max_swap_offset>
}
ffffffffc0203d8e:	0141                	addi	sp,sp,16
ffffffffc0203d90:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203d92:	00002617          	auipc	a2,0x2
ffffffffc0203d96:	1de60613          	addi	a2,a2,478 # ffffffffc0205f70 <default_pmm_manager+0x700>
ffffffffc0203d9a:	45b5                	li	a1,13
ffffffffc0203d9c:	00002517          	auipc	a0,0x2
ffffffffc0203da0:	1f450513          	addi	a0,a0,500 # ffffffffc0205f90 <default_pmm_manager+0x720>
ffffffffc0203da4:	b5efc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203da8 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203da8:	1141                	addi	sp,sp,-16
ffffffffc0203daa:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203dac:	00855793          	srli	a5,a0,0x8
ffffffffc0203db0:	c3a5                	beqz	a5,ffffffffc0203e10 <swapfs_read+0x68>
ffffffffc0203db2:	0000d717          	auipc	a4,0xd
ffffffffc0203db6:	76e73703          	ld	a4,1902(a4) # ffffffffc0211520 <max_swap_offset>
ffffffffc0203dba:	04e7fb63          	bgeu	a5,a4,ffffffffc0203e10 <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203dbe:	0000d617          	auipc	a2,0xd
ffffffffc0203dc2:	79a63603          	ld	a2,1946(a2) # ffffffffc0211558 <pages>
ffffffffc0203dc6:	8d91                	sub	a1,a1,a2
ffffffffc0203dc8:	4035d613          	srai	a2,a1,0x3
ffffffffc0203dcc:	00002597          	auipc	a1,0x2
ffffffffc0203dd0:	4445b583          	ld	a1,1092(a1) # ffffffffc0206210 <error_string+0x38>
ffffffffc0203dd4:	02b60633          	mul	a2,a2,a1
ffffffffc0203dd8:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203ddc:	00002797          	auipc	a5,0x2
ffffffffc0203de0:	43c7b783          	ld	a5,1084(a5) # ffffffffc0206218 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203de4:	0000d717          	auipc	a4,0xd
ffffffffc0203de8:	76c73703          	ld	a4,1900(a4) # ffffffffc0211550 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203dec:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203dee:	00c61793          	slli	a5,a2,0xc
ffffffffc0203df2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203df4:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203df6:	02e7f963          	bgeu	a5,a4,ffffffffc0203e28 <swapfs_read+0x80>
}
ffffffffc0203dfa:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203dfc:	0000d797          	auipc	a5,0xd
ffffffffc0203e00:	76c7b783          	ld	a5,1900(a5) # ffffffffc0211568 <va_pa_offset>
ffffffffc0203e04:	46a1                	li	a3,8
ffffffffc0203e06:	963e                	add	a2,a2,a5
ffffffffc0203e08:	4505                	li	a0,1
}
ffffffffc0203e0a:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e0c:	dd2fc06f          	j	ffffffffc02003de <ide_read_secs>
ffffffffc0203e10:	86aa                	mv	a3,a0
ffffffffc0203e12:	00002617          	auipc	a2,0x2
ffffffffc0203e16:	19660613          	addi	a2,a2,406 # ffffffffc0205fa8 <default_pmm_manager+0x738>
ffffffffc0203e1a:	45d1                	li	a1,20
ffffffffc0203e1c:	00002517          	auipc	a0,0x2
ffffffffc0203e20:	17450513          	addi	a0,a0,372 # ffffffffc0205f90 <default_pmm_manager+0x720>
ffffffffc0203e24:	adefc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203e28:	86b2                	mv	a3,a2
ffffffffc0203e2a:	06c00593          	li	a1,108
ffffffffc0203e2e:	00002617          	auipc	a2,0x2
ffffffffc0203e32:	b4a60613          	addi	a2,a2,-1206 # ffffffffc0205978 <default_pmm_manager+0x108>
ffffffffc0203e36:	00001517          	auipc	a0,0x1
ffffffffc0203e3a:	20250513          	addi	a0,a0,514 # ffffffffc0205038 <commands+0x998>
ffffffffc0203e3e:	ac4fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203e42 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203e42:	1141                	addi	sp,sp,-16
ffffffffc0203e44:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e46:	00855793          	srli	a5,a0,0x8
ffffffffc0203e4a:	c3a5                	beqz	a5,ffffffffc0203eaa <swapfs_write+0x68>
ffffffffc0203e4c:	0000d717          	auipc	a4,0xd
ffffffffc0203e50:	6d473703          	ld	a4,1748(a4) # ffffffffc0211520 <max_swap_offset>
ffffffffc0203e54:	04e7fb63          	bgeu	a5,a4,ffffffffc0203eaa <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e58:	0000d617          	auipc	a2,0xd
ffffffffc0203e5c:	70063603          	ld	a2,1792(a2) # ffffffffc0211558 <pages>
ffffffffc0203e60:	8d91                	sub	a1,a1,a2
ffffffffc0203e62:	4035d613          	srai	a2,a1,0x3
ffffffffc0203e66:	00002597          	auipc	a1,0x2
ffffffffc0203e6a:	3aa5b583          	ld	a1,938(a1) # ffffffffc0206210 <error_string+0x38>
ffffffffc0203e6e:	02b60633          	mul	a2,a2,a1
ffffffffc0203e72:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203e76:	00002797          	auipc	a5,0x2
ffffffffc0203e7a:	3a27b783          	ld	a5,930(a5) # ffffffffc0206218 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e7e:	0000d717          	auipc	a4,0xd
ffffffffc0203e82:	6d273703          	ld	a4,1746(a4) # ffffffffc0211550 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e86:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e88:	00c61793          	slli	a5,a2,0xc
ffffffffc0203e8c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203e8e:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e90:	02e7f963          	bgeu	a5,a4,ffffffffc0203ec2 <swapfs_write+0x80>
}
ffffffffc0203e94:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e96:	0000d797          	auipc	a5,0xd
ffffffffc0203e9a:	6d27b783          	ld	a5,1746(a5) # ffffffffc0211568 <va_pa_offset>
ffffffffc0203e9e:	46a1                	li	a3,8
ffffffffc0203ea0:	963e                	add	a2,a2,a5
ffffffffc0203ea2:	4505                	li	a0,1
}
ffffffffc0203ea4:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ea6:	d5cfc06f          	j	ffffffffc0200402 <ide_write_secs>
ffffffffc0203eaa:	86aa                	mv	a3,a0
ffffffffc0203eac:	00002617          	auipc	a2,0x2
ffffffffc0203eb0:	0fc60613          	addi	a2,a2,252 # ffffffffc0205fa8 <default_pmm_manager+0x738>
ffffffffc0203eb4:	45e5                	li	a1,25
ffffffffc0203eb6:	00002517          	auipc	a0,0x2
ffffffffc0203eba:	0da50513          	addi	a0,a0,218 # ffffffffc0205f90 <default_pmm_manager+0x720>
ffffffffc0203ebe:	a44fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203ec2:	86b2                	mv	a3,a2
ffffffffc0203ec4:	06c00593          	li	a1,108
ffffffffc0203ec8:	00002617          	auipc	a2,0x2
ffffffffc0203ecc:	ab060613          	addi	a2,a2,-1360 # ffffffffc0205978 <default_pmm_manager+0x108>
ffffffffc0203ed0:	00001517          	auipc	a0,0x1
ffffffffc0203ed4:	16850513          	addi	a0,a0,360 # ffffffffc0205038 <commands+0x998>
ffffffffc0203ed8:	a2afc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203edc <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203edc:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0203ee0:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0203ee2:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0203ee4:	cb81                	beqz	a5,ffffffffc0203ef4 <strlen+0x18>
        cnt ++;
ffffffffc0203ee6:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0203ee8:	00a707b3          	add	a5,a4,a0
ffffffffc0203eec:	0007c783          	lbu	a5,0(a5)
ffffffffc0203ef0:	fbfd                	bnez	a5,ffffffffc0203ee6 <strlen+0xa>
ffffffffc0203ef2:	8082                	ret
    }
    return cnt;
}
ffffffffc0203ef4:	8082                	ret

ffffffffc0203ef6 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0203ef6:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203ef8:	e589                	bnez	a1,ffffffffc0203f02 <strnlen+0xc>
ffffffffc0203efa:	a811                	j	ffffffffc0203f0e <strnlen+0x18>
        cnt ++;
ffffffffc0203efc:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203efe:	00f58863          	beq	a1,a5,ffffffffc0203f0e <strnlen+0x18>
ffffffffc0203f02:	00f50733          	add	a4,a0,a5
ffffffffc0203f06:	00074703          	lbu	a4,0(a4)
ffffffffc0203f0a:	fb6d                	bnez	a4,ffffffffc0203efc <strnlen+0x6>
ffffffffc0203f0c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0203f0e:	852e                	mv	a0,a1
ffffffffc0203f10:	8082                	ret

ffffffffc0203f12 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203f12:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203f14:	0005c703          	lbu	a4,0(a1)
ffffffffc0203f18:	0785                	addi	a5,a5,1
ffffffffc0203f1a:	0585                	addi	a1,a1,1
ffffffffc0203f1c:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203f20:	fb75                	bnez	a4,ffffffffc0203f14 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203f22:	8082                	ret

ffffffffc0203f24 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203f24:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203f28:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203f2c:	cb89                	beqz	a5,ffffffffc0203f3e <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0203f2e:	0505                	addi	a0,a0,1
ffffffffc0203f30:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203f32:	fee789e3          	beq	a5,a4,ffffffffc0203f24 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203f36:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203f3a:	9d19                	subw	a0,a0,a4
ffffffffc0203f3c:	8082                	ret
ffffffffc0203f3e:	4501                	li	a0,0
ffffffffc0203f40:	bfed                	j	ffffffffc0203f3a <strcmp+0x16>

ffffffffc0203f42 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203f42:	00054783          	lbu	a5,0(a0)
ffffffffc0203f46:	c799                	beqz	a5,ffffffffc0203f54 <strchr+0x12>
        if (*s == c) {
ffffffffc0203f48:	00f58763          	beq	a1,a5,ffffffffc0203f56 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0203f4c:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0203f50:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203f52:	fbfd                	bnez	a5,ffffffffc0203f48 <strchr+0x6>
    }
    return NULL;
ffffffffc0203f54:	4501                	li	a0,0
}
ffffffffc0203f56:	8082                	ret

ffffffffc0203f58 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203f58:	ca01                	beqz	a2,ffffffffc0203f68 <memset+0x10>
ffffffffc0203f5a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203f5c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203f5e:	0785                	addi	a5,a5,1
ffffffffc0203f60:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203f64:	fec79de3          	bne	a5,a2,ffffffffc0203f5e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203f68:	8082                	ret

ffffffffc0203f6a <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203f6a:	ca19                	beqz	a2,ffffffffc0203f80 <memcpy+0x16>
ffffffffc0203f6c:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203f6e:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203f70:	0005c703          	lbu	a4,0(a1)
ffffffffc0203f74:	0585                	addi	a1,a1,1
ffffffffc0203f76:	0785                	addi	a5,a5,1
ffffffffc0203f78:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203f7c:	fec59ae3          	bne	a1,a2,ffffffffc0203f70 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203f80:	8082                	ret

ffffffffc0203f82 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203f82:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f86:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203f88:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f8c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203f8e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f92:	f022                	sd	s0,32(sp)
ffffffffc0203f94:	ec26                	sd	s1,24(sp)
ffffffffc0203f96:	e84a                	sd	s2,16(sp)
ffffffffc0203f98:	f406                	sd	ra,40(sp)
ffffffffc0203f9a:	e44e                	sd	s3,8(sp)
ffffffffc0203f9c:	84aa                	mv	s1,a0
ffffffffc0203f9e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203fa0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203fa4:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203fa6:	03067e63          	bgeu	a2,a6,ffffffffc0203fe2 <printnum+0x60>
ffffffffc0203faa:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203fac:	00805763          	blez	s0,ffffffffc0203fba <printnum+0x38>
ffffffffc0203fb0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203fb2:	85ca                	mv	a1,s2
ffffffffc0203fb4:	854e                	mv	a0,s3
ffffffffc0203fb6:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203fb8:	fc65                	bnez	s0,ffffffffc0203fb0 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203fba:	1a02                	slli	s4,s4,0x20
ffffffffc0203fbc:	00002797          	auipc	a5,0x2
ffffffffc0203fc0:	00c78793          	addi	a5,a5,12 # ffffffffc0205fc8 <default_pmm_manager+0x758>
ffffffffc0203fc4:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203fc8:	9a3e                	add	s4,s4,a5
}
ffffffffc0203fca:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203fcc:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203fd0:	70a2                	ld	ra,40(sp)
ffffffffc0203fd2:	69a2                	ld	s3,8(sp)
ffffffffc0203fd4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203fd6:	85ca                	mv	a1,s2
ffffffffc0203fd8:	87a6                	mv	a5,s1
}
ffffffffc0203fda:	6942                	ld	s2,16(sp)
ffffffffc0203fdc:	64e2                	ld	s1,24(sp)
ffffffffc0203fde:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203fe0:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203fe2:	03065633          	divu	a2,a2,a6
ffffffffc0203fe6:	8722                	mv	a4,s0
ffffffffc0203fe8:	f9bff0ef          	jal	ra,ffffffffc0203f82 <printnum>
ffffffffc0203fec:	b7f9                	j	ffffffffc0203fba <printnum+0x38>

ffffffffc0203fee <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203fee:	7119                	addi	sp,sp,-128
ffffffffc0203ff0:	f4a6                	sd	s1,104(sp)
ffffffffc0203ff2:	f0ca                	sd	s2,96(sp)
ffffffffc0203ff4:	ecce                	sd	s3,88(sp)
ffffffffc0203ff6:	e8d2                	sd	s4,80(sp)
ffffffffc0203ff8:	e4d6                	sd	s5,72(sp)
ffffffffc0203ffa:	e0da                	sd	s6,64(sp)
ffffffffc0203ffc:	fc5e                	sd	s7,56(sp)
ffffffffc0203ffe:	f06a                	sd	s10,32(sp)
ffffffffc0204000:	fc86                	sd	ra,120(sp)
ffffffffc0204002:	f8a2                	sd	s0,112(sp)
ffffffffc0204004:	f862                	sd	s8,48(sp)
ffffffffc0204006:	f466                	sd	s9,40(sp)
ffffffffc0204008:	ec6e                	sd	s11,24(sp)
ffffffffc020400a:	892a                	mv	s2,a0
ffffffffc020400c:	84ae                	mv	s1,a1
ffffffffc020400e:	8d32                	mv	s10,a2
ffffffffc0204010:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204012:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204016:	5b7d                	li	s6,-1
ffffffffc0204018:	00002a97          	auipc	s5,0x2
ffffffffc020401c:	fe4a8a93          	addi	s5,s5,-28 # ffffffffc0205ffc <default_pmm_manager+0x78c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204020:	00002b97          	auipc	s7,0x2
ffffffffc0204024:	1b8b8b93          	addi	s7,s7,440 # ffffffffc02061d8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204028:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc020402c:	001d0413          	addi	s0,s10,1
ffffffffc0204030:	01350a63          	beq	a0,s3,ffffffffc0204044 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204034:	c121                	beqz	a0,ffffffffc0204074 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204036:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204038:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020403a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020403c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204040:	ff351ae3          	bne	a0,s3,ffffffffc0204034 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204044:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204048:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020404c:	4c81                	li	s9,0
ffffffffc020404e:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0204050:	5c7d                	li	s8,-1
ffffffffc0204052:	5dfd                	li	s11,-1
ffffffffc0204054:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0204058:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020405a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020405e:	0ff5f593          	zext.b	a1,a1
ffffffffc0204062:	00140d13          	addi	s10,s0,1
ffffffffc0204066:	04b56263          	bltu	a0,a1,ffffffffc02040aa <vprintfmt+0xbc>
ffffffffc020406a:	058a                	slli	a1,a1,0x2
ffffffffc020406c:	95d6                	add	a1,a1,s5
ffffffffc020406e:	4194                	lw	a3,0(a1)
ffffffffc0204070:	96d6                	add	a3,a3,s5
ffffffffc0204072:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204074:	70e6                	ld	ra,120(sp)
ffffffffc0204076:	7446                	ld	s0,112(sp)
ffffffffc0204078:	74a6                	ld	s1,104(sp)
ffffffffc020407a:	7906                	ld	s2,96(sp)
ffffffffc020407c:	69e6                	ld	s3,88(sp)
ffffffffc020407e:	6a46                	ld	s4,80(sp)
ffffffffc0204080:	6aa6                	ld	s5,72(sp)
ffffffffc0204082:	6b06                	ld	s6,64(sp)
ffffffffc0204084:	7be2                	ld	s7,56(sp)
ffffffffc0204086:	7c42                	ld	s8,48(sp)
ffffffffc0204088:	7ca2                	ld	s9,40(sp)
ffffffffc020408a:	7d02                	ld	s10,32(sp)
ffffffffc020408c:	6de2                	ld	s11,24(sp)
ffffffffc020408e:	6109                	addi	sp,sp,128
ffffffffc0204090:	8082                	ret
            padc = '0';
ffffffffc0204092:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0204094:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204098:	846a                	mv	s0,s10
ffffffffc020409a:	00140d13          	addi	s10,s0,1
ffffffffc020409e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02040a2:	0ff5f593          	zext.b	a1,a1
ffffffffc02040a6:	fcb572e3          	bgeu	a0,a1,ffffffffc020406a <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02040aa:	85a6                	mv	a1,s1
ffffffffc02040ac:	02500513          	li	a0,37
ffffffffc02040b0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02040b2:	fff44783          	lbu	a5,-1(s0)
ffffffffc02040b6:	8d22                	mv	s10,s0
ffffffffc02040b8:	f73788e3          	beq	a5,s3,ffffffffc0204028 <vprintfmt+0x3a>
ffffffffc02040bc:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02040c0:	1d7d                	addi	s10,s10,-1
ffffffffc02040c2:	ff379de3          	bne	a5,s3,ffffffffc02040bc <vprintfmt+0xce>
ffffffffc02040c6:	b78d                	j	ffffffffc0204028 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02040c8:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02040cc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040d0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02040d2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02040d6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02040da:	02d86463          	bltu	a6,a3,ffffffffc0204102 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02040de:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02040e2:	002c169b          	slliw	a3,s8,0x2
ffffffffc02040e6:	0186873b          	addw	a4,a3,s8
ffffffffc02040ea:	0017171b          	slliw	a4,a4,0x1
ffffffffc02040ee:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02040f0:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02040f4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02040f6:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02040fa:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02040fe:	fed870e3          	bgeu	a6,a3,ffffffffc02040de <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204102:	f40ddce3          	bgez	s11,ffffffffc020405a <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204106:	8de2                	mv	s11,s8
ffffffffc0204108:	5c7d                	li	s8,-1
ffffffffc020410a:	bf81                	j	ffffffffc020405a <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020410c:	fffdc693          	not	a3,s11
ffffffffc0204110:	96fd                	srai	a3,a3,0x3f
ffffffffc0204112:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204116:	00144603          	lbu	a2,1(s0)
ffffffffc020411a:	2d81                	sext.w	s11,s11
ffffffffc020411c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020411e:	bf35                	j	ffffffffc020405a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0204120:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204124:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204128:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020412a:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020412c:	bfd9                	j	ffffffffc0204102 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020412e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204130:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204134:	01174463          	blt	a4,a7,ffffffffc020413c <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204138:	1a088e63          	beqz	a7,ffffffffc02042f4 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020413c:	000a3603          	ld	a2,0(s4)
ffffffffc0204140:	46c1                	li	a3,16
ffffffffc0204142:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204144:	2781                	sext.w	a5,a5
ffffffffc0204146:	876e                	mv	a4,s11
ffffffffc0204148:	85a6                	mv	a1,s1
ffffffffc020414a:	854a                	mv	a0,s2
ffffffffc020414c:	e37ff0ef          	jal	ra,ffffffffc0203f82 <printnum>
            break;
ffffffffc0204150:	bde1                	j	ffffffffc0204028 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204152:	000a2503          	lw	a0,0(s4)
ffffffffc0204156:	85a6                	mv	a1,s1
ffffffffc0204158:	0a21                	addi	s4,s4,8
ffffffffc020415a:	9902                	jalr	s2
            break;
ffffffffc020415c:	b5f1                	j	ffffffffc0204028 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020415e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204160:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204164:	01174463          	blt	a4,a7,ffffffffc020416c <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0204168:	18088163          	beqz	a7,ffffffffc02042ea <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020416c:	000a3603          	ld	a2,0(s4)
ffffffffc0204170:	46a9                	li	a3,10
ffffffffc0204172:	8a2e                	mv	s4,a1
ffffffffc0204174:	bfc1                	j	ffffffffc0204144 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204176:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020417a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020417c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020417e:	bdf1                	j	ffffffffc020405a <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0204180:	85a6                	mv	a1,s1
ffffffffc0204182:	02500513          	li	a0,37
ffffffffc0204186:	9902                	jalr	s2
            break;
ffffffffc0204188:	b545                	j	ffffffffc0204028 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020418a:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020418e:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204190:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204192:	b5e1                	j	ffffffffc020405a <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204194:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204196:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020419a:	01174463          	blt	a4,a7,ffffffffc02041a2 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020419e:	14088163          	beqz	a7,ffffffffc02042e0 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02041a2:	000a3603          	ld	a2,0(s4)
ffffffffc02041a6:	46a1                	li	a3,8
ffffffffc02041a8:	8a2e                	mv	s4,a1
ffffffffc02041aa:	bf69                	j	ffffffffc0204144 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02041ac:	03000513          	li	a0,48
ffffffffc02041b0:	85a6                	mv	a1,s1
ffffffffc02041b2:	e03e                	sd	a5,0(sp)
ffffffffc02041b4:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02041b6:	85a6                	mv	a1,s1
ffffffffc02041b8:	07800513          	li	a0,120
ffffffffc02041bc:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02041be:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02041c0:	6782                	ld	a5,0(sp)
ffffffffc02041c2:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02041c4:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02041c8:	bfb5                	j	ffffffffc0204144 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02041ca:	000a3403          	ld	s0,0(s4)
ffffffffc02041ce:	008a0713          	addi	a4,s4,8
ffffffffc02041d2:	e03a                	sd	a4,0(sp)
ffffffffc02041d4:	14040263          	beqz	s0,ffffffffc0204318 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02041d8:	0fb05763          	blez	s11,ffffffffc02042c6 <vprintfmt+0x2d8>
ffffffffc02041dc:	02d00693          	li	a3,45
ffffffffc02041e0:	0cd79163          	bne	a5,a3,ffffffffc02042a2 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041e4:	00044783          	lbu	a5,0(s0)
ffffffffc02041e8:	0007851b          	sext.w	a0,a5
ffffffffc02041ec:	cf85                	beqz	a5,ffffffffc0204224 <vprintfmt+0x236>
ffffffffc02041ee:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02041f2:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041f6:	000c4563          	bltz	s8,ffffffffc0204200 <vprintfmt+0x212>
ffffffffc02041fa:	3c7d                	addiw	s8,s8,-1
ffffffffc02041fc:	036c0263          	beq	s8,s6,ffffffffc0204220 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204200:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204202:	0e0c8e63          	beqz	s9,ffffffffc02042fe <vprintfmt+0x310>
ffffffffc0204206:	3781                	addiw	a5,a5,-32
ffffffffc0204208:	0ef47b63          	bgeu	s0,a5,ffffffffc02042fe <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020420c:	03f00513          	li	a0,63
ffffffffc0204210:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204212:	000a4783          	lbu	a5,0(s4)
ffffffffc0204216:	3dfd                	addiw	s11,s11,-1
ffffffffc0204218:	0a05                	addi	s4,s4,1
ffffffffc020421a:	0007851b          	sext.w	a0,a5
ffffffffc020421e:	ffe1                	bnez	a5,ffffffffc02041f6 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204220:	01b05963          	blez	s11,ffffffffc0204232 <vprintfmt+0x244>
ffffffffc0204224:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204226:	85a6                	mv	a1,s1
ffffffffc0204228:	02000513          	li	a0,32
ffffffffc020422c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020422e:	fe0d9be3          	bnez	s11,ffffffffc0204224 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204232:	6a02                	ld	s4,0(sp)
ffffffffc0204234:	bbd5                	j	ffffffffc0204028 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204236:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204238:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020423c:	01174463          	blt	a4,a7,ffffffffc0204244 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204240:	08088d63          	beqz	a7,ffffffffc02042da <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204244:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204248:	0a044d63          	bltz	s0,ffffffffc0204302 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020424c:	8622                	mv	a2,s0
ffffffffc020424e:	8a66                	mv	s4,s9
ffffffffc0204250:	46a9                	li	a3,10
ffffffffc0204252:	bdcd                	j	ffffffffc0204144 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204254:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204258:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020425a:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020425c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204260:	8fb5                	xor	a5,a5,a3
ffffffffc0204262:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204266:	02d74163          	blt	a4,a3,ffffffffc0204288 <vprintfmt+0x29a>
ffffffffc020426a:	00369793          	slli	a5,a3,0x3
ffffffffc020426e:	97de                	add	a5,a5,s7
ffffffffc0204270:	639c                	ld	a5,0(a5)
ffffffffc0204272:	cb99                	beqz	a5,ffffffffc0204288 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204274:	86be                	mv	a3,a5
ffffffffc0204276:	00002617          	auipc	a2,0x2
ffffffffc020427a:	d8260613          	addi	a2,a2,-638 # ffffffffc0205ff8 <default_pmm_manager+0x788>
ffffffffc020427e:	85a6                	mv	a1,s1
ffffffffc0204280:	854a                	mv	a0,s2
ffffffffc0204282:	0ce000ef          	jal	ra,ffffffffc0204350 <printfmt>
ffffffffc0204286:	b34d                	j	ffffffffc0204028 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204288:	00002617          	auipc	a2,0x2
ffffffffc020428c:	d6060613          	addi	a2,a2,-672 # ffffffffc0205fe8 <default_pmm_manager+0x778>
ffffffffc0204290:	85a6                	mv	a1,s1
ffffffffc0204292:	854a                	mv	a0,s2
ffffffffc0204294:	0bc000ef          	jal	ra,ffffffffc0204350 <printfmt>
ffffffffc0204298:	bb41                	j	ffffffffc0204028 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020429a:	00002417          	auipc	s0,0x2
ffffffffc020429e:	d4640413          	addi	s0,s0,-698 # ffffffffc0205fe0 <default_pmm_manager+0x770>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02042a2:	85e2                	mv	a1,s8
ffffffffc02042a4:	8522                	mv	a0,s0
ffffffffc02042a6:	e43e                	sd	a5,8(sp)
ffffffffc02042a8:	c4fff0ef          	jal	ra,ffffffffc0203ef6 <strnlen>
ffffffffc02042ac:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02042b0:	01b05b63          	blez	s11,ffffffffc02042c6 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02042b4:	67a2                	ld	a5,8(sp)
ffffffffc02042b6:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02042ba:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02042bc:	85a6                	mv	a1,s1
ffffffffc02042be:	8552                	mv	a0,s4
ffffffffc02042c0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02042c2:	fe0d9ce3          	bnez	s11,ffffffffc02042ba <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02042c6:	00044783          	lbu	a5,0(s0)
ffffffffc02042ca:	00140a13          	addi	s4,s0,1
ffffffffc02042ce:	0007851b          	sext.w	a0,a5
ffffffffc02042d2:	d3a5                	beqz	a5,ffffffffc0204232 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02042d4:	05e00413          	li	s0,94
ffffffffc02042d8:	bf39                	j	ffffffffc02041f6 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02042da:	000a2403          	lw	s0,0(s4)
ffffffffc02042de:	b7ad                	j	ffffffffc0204248 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02042e0:	000a6603          	lwu	a2,0(s4)
ffffffffc02042e4:	46a1                	li	a3,8
ffffffffc02042e6:	8a2e                	mv	s4,a1
ffffffffc02042e8:	bdb1                	j	ffffffffc0204144 <vprintfmt+0x156>
ffffffffc02042ea:	000a6603          	lwu	a2,0(s4)
ffffffffc02042ee:	46a9                	li	a3,10
ffffffffc02042f0:	8a2e                	mv	s4,a1
ffffffffc02042f2:	bd89                	j	ffffffffc0204144 <vprintfmt+0x156>
ffffffffc02042f4:	000a6603          	lwu	a2,0(s4)
ffffffffc02042f8:	46c1                	li	a3,16
ffffffffc02042fa:	8a2e                	mv	s4,a1
ffffffffc02042fc:	b5a1                	j	ffffffffc0204144 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02042fe:	9902                	jalr	s2
ffffffffc0204300:	bf09                	j	ffffffffc0204212 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204302:	85a6                	mv	a1,s1
ffffffffc0204304:	02d00513          	li	a0,45
ffffffffc0204308:	e03e                	sd	a5,0(sp)
ffffffffc020430a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020430c:	6782                	ld	a5,0(sp)
ffffffffc020430e:	8a66                	mv	s4,s9
ffffffffc0204310:	40800633          	neg	a2,s0
ffffffffc0204314:	46a9                	li	a3,10
ffffffffc0204316:	b53d                	j	ffffffffc0204144 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204318:	03b05163          	blez	s11,ffffffffc020433a <vprintfmt+0x34c>
ffffffffc020431c:	02d00693          	li	a3,45
ffffffffc0204320:	f6d79de3          	bne	a5,a3,ffffffffc020429a <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204324:	00002417          	auipc	s0,0x2
ffffffffc0204328:	cbc40413          	addi	s0,s0,-836 # ffffffffc0205fe0 <default_pmm_manager+0x770>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020432c:	02800793          	li	a5,40
ffffffffc0204330:	02800513          	li	a0,40
ffffffffc0204334:	00140a13          	addi	s4,s0,1
ffffffffc0204338:	bd6d                	j	ffffffffc02041f2 <vprintfmt+0x204>
ffffffffc020433a:	00002a17          	auipc	s4,0x2
ffffffffc020433e:	ca7a0a13          	addi	s4,s4,-857 # ffffffffc0205fe1 <default_pmm_manager+0x771>
ffffffffc0204342:	02800513          	li	a0,40
ffffffffc0204346:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020434a:	05e00413          	li	s0,94
ffffffffc020434e:	b565                	j	ffffffffc02041f6 <vprintfmt+0x208>

ffffffffc0204350 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204350:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204352:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204356:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204358:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020435a:	ec06                	sd	ra,24(sp)
ffffffffc020435c:	f83a                	sd	a4,48(sp)
ffffffffc020435e:	fc3e                	sd	a5,56(sp)
ffffffffc0204360:	e0c2                	sd	a6,64(sp)
ffffffffc0204362:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204364:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204366:	c89ff0ef          	jal	ra,ffffffffc0203fee <vprintfmt>
}
ffffffffc020436a:	60e2                	ld	ra,24(sp)
ffffffffc020436c:	6161                	addi	sp,sp,80
ffffffffc020436e:	8082                	ret

ffffffffc0204370 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0204370:	715d                	addi	sp,sp,-80
ffffffffc0204372:	e486                	sd	ra,72(sp)
ffffffffc0204374:	e0a6                	sd	s1,64(sp)
ffffffffc0204376:	fc4a                	sd	s2,56(sp)
ffffffffc0204378:	f84e                	sd	s3,48(sp)
ffffffffc020437a:	f452                	sd	s4,40(sp)
ffffffffc020437c:	f056                	sd	s5,32(sp)
ffffffffc020437e:	ec5a                	sd	s6,24(sp)
ffffffffc0204380:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0204382:	c901                	beqz	a0,ffffffffc0204392 <readline+0x22>
ffffffffc0204384:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0204386:	00002517          	auipc	a0,0x2
ffffffffc020438a:	c7250513          	addi	a0,a0,-910 # ffffffffc0205ff8 <default_pmm_manager+0x788>
ffffffffc020438e:	d2dfb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc0204392:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204394:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0204396:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0204398:	4aa9                	li	s5,10
ffffffffc020439a:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020439c:	0000db97          	auipc	s7,0xd
ffffffffc02043a0:	d5cb8b93          	addi	s7,s7,-676 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043a4:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02043a8:	d4bfb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02043ac:	00054a63          	bltz	a0,ffffffffc02043c0 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043b0:	00a95a63          	bge	s2,a0,ffffffffc02043c4 <readline+0x54>
ffffffffc02043b4:	029a5263          	bge	s4,s1,ffffffffc02043d8 <readline+0x68>
        c = getchar();
ffffffffc02043b8:	d3bfb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02043bc:	fe055ae3          	bgez	a0,ffffffffc02043b0 <readline+0x40>
            return NULL;
ffffffffc02043c0:	4501                	li	a0,0
ffffffffc02043c2:	a091                	j	ffffffffc0204406 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02043c4:	03351463          	bne	a0,s3,ffffffffc02043ec <readline+0x7c>
ffffffffc02043c8:	e8a9                	bnez	s1,ffffffffc020441a <readline+0xaa>
        c = getchar();
ffffffffc02043ca:	d29fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02043ce:	fe0549e3          	bltz	a0,ffffffffc02043c0 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043d2:	fea959e3          	bge	s2,a0,ffffffffc02043c4 <readline+0x54>
ffffffffc02043d6:	4481                	li	s1,0
            cputchar(c);
ffffffffc02043d8:	e42a                	sd	a0,8(sp)
ffffffffc02043da:	d17fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc02043de:	6522                	ld	a0,8(sp)
ffffffffc02043e0:	009b87b3          	add	a5,s7,s1
ffffffffc02043e4:	2485                	addiw	s1,s1,1
ffffffffc02043e6:	00a78023          	sb	a0,0(a5)
ffffffffc02043ea:	bf7d                	j	ffffffffc02043a8 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02043ec:	01550463          	beq	a0,s5,ffffffffc02043f4 <readline+0x84>
ffffffffc02043f0:	fb651ce3          	bne	a0,s6,ffffffffc02043a8 <readline+0x38>
            cputchar(c);
ffffffffc02043f4:	cfdfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc02043f8:	0000d517          	auipc	a0,0xd
ffffffffc02043fc:	d0050513          	addi	a0,a0,-768 # ffffffffc02110f8 <buf>
ffffffffc0204400:	94aa                	add	s1,s1,a0
ffffffffc0204402:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204406:	60a6                	ld	ra,72(sp)
ffffffffc0204408:	6486                	ld	s1,64(sp)
ffffffffc020440a:	7962                	ld	s2,56(sp)
ffffffffc020440c:	79c2                	ld	s3,48(sp)
ffffffffc020440e:	7a22                	ld	s4,40(sp)
ffffffffc0204410:	7a82                	ld	s5,32(sp)
ffffffffc0204412:	6b62                	ld	s6,24(sp)
ffffffffc0204414:	6bc2                	ld	s7,16(sp)
ffffffffc0204416:	6161                	addi	sp,sp,80
ffffffffc0204418:	8082                	ret
            cputchar(c);
ffffffffc020441a:	4521                	li	a0,8
ffffffffc020441c:	cd5fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc0204420:	34fd                	addiw	s1,s1,-1
ffffffffc0204422:	b759                	j	ffffffffc02043a8 <readline+0x38>
