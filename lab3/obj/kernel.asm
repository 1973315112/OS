
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
ffffffffc020004a:	038040ef          	jal	ra,ffffffffc0204082 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	50258593          	addi	a1,a1,1282 # ffffffffc0204550 <etext+0x2>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	51a50513          	addi	a0,a0,1306 # ffffffffc0204570 <etext+0x22>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();           // 打印核心信息
ffffffffc0200062:	0fc000ef          	jal	ra,ffffffffc020015e <print_kerninfo>
    // grade_backtrace();
    pmm_init();                 // 初始化物理内存管理器
ffffffffc0200066:	7d1020ef          	jal	ra,ffffffffc0203036 <pmm_init>
    idt_init();                 // 初始化中断描述符表
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init();                 // 初始化虚拟内存管理器(本次的新增)
ffffffffc020006e:	10c010ef          	jal	ra,ffffffffc020117a <vmm_init>
    ide_init();                 // 初始化磁盘设备(本次的新增,空的)
ffffffffc0200072:	35e000ef          	jal	ra,ffffffffc02003d0 <ide_init>
    swap_init();                // 初始化页面交换机制(本次的核心)
ffffffffc0200076:	7aa010ef          	jal	ra,ffffffffc0201820 <swap_init>

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
ffffffffc02000ae:	06a040ef          	jal	ra,ffffffffc0204118 <vprintfmt>
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
ffffffffc02000e4:	034040ef          	jal	ra,ffffffffc0204118 <vprintfmt>
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
ffffffffc0200134:	44850513          	addi	a0,a0,1096 # ffffffffc0204578 <etext+0x2a>
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
ffffffffc020014a:	e4250513          	addi	a0,a0,-446 # ffffffffc0205f88 <default_pmm_manager+0x420>
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
ffffffffc0200164:	43850513          	addi	a0,a0,1080 # ffffffffc0204598 <etext+0x4a>
void print_kerninfo(void) {
ffffffffc0200168:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020016a:	f51ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020016e:	00000597          	auipc	a1,0x0
ffffffffc0200172:	ec458593          	addi	a1,a1,-316 # ffffffffc0200032 <kern_init>
ffffffffc0200176:	00004517          	auipc	a0,0x4
ffffffffc020017a:	44250513          	addi	a0,a0,1090 # ffffffffc02045b8 <etext+0x6a>
ffffffffc020017e:	f3dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200182:	00004597          	auipc	a1,0x4
ffffffffc0200186:	3cc58593          	addi	a1,a1,972 # ffffffffc020454e <etext>
ffffffffc020018a:	00004517          	auipc	a0,0x4
ffffffffc020018e:	44e50513          	addi	a0,a0,1102 # ffffffffc02045d8 <etext+0x8a>
ffffffffc0200192:	f29ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200196:	0000a597          	auipc	a1,0xa
ffffffffc020019a:	eaa58593          	addi	a1,a1,-342 # ffffffffc020a040 <ide>
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	45a50513          	addi	a0,a0,1114 # ffffffffc02045f8 <etext+0xaa>
ffffffffc02001a6:	f15ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001aa:	00011597          	auipc	a1,0x11
ffffffffc02001ae:	3c658593          	addi	a1,a1,966 # ffffffffc0211570 <end>
ffffffffc02001b2:	00004517          	auipc	a0,0x4
ffffffffc02001b6:	46650513          	addi	a0,a0,1126 # ffffffffc0204618 <etext+0xca>
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
ffffffffc02001e4:	45850513          	addi	a0,a0,1112 # ffffffffc0204638 <etext+0xea>
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
ffffffffc02001f2:	47a60613          	addi	a2,a2,1146 # ffffffffc0204668 <etext+0x11a>
ffffffffc02001f6:	04e00593          	li	a1,78
ffffffffc02001fa:	00004517          	auipc	a0,0x4
ffffffffc02001fe:	48650513          	addi	a0,a0,1158 # ffffffffc0204680 <etext+0x132>
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
ffffffffc020020e:	48e60613          	addi	a2,a2,1166 # ffffffffc0204698 <etext+0x14a>
ffffffffc0200212:	00004597          	auipc	a1,0x4
ffffffffc0200216:	4a658593          	addi	a1,a1,1190 # ffffffffc02046b8 <etext+0x16a>
ffffffffc020021a:	00004517          	auipc	a0,0x4
ffffffffc020021e:	4a650513          	addi	a0,a0,1190 # ffffffffc02046c0 <etext+0x172>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200224:	e97ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200228:	00004617          	auipc	a2,0x4
ffffffffc020022c:	4a860613          	addi	a2,a2,1192 # ffffffffc02046d0 <etext+0x182>
ffffffffc0200230:	00004597          	auipc	a1,0x4
ffffffffc0200234:	4c858593          	addi	a1,a1,1224 # ffffffffc02046f8 <etext+0x1aa>
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	48850513          	addi	a0,a0,1160 # ffffffffc02046c0 <etext+0x172>
ffffffffc0200240:	e7bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200244:	00004617          	auipc	a2,0x4
ffffffffc0200248:	4c460613          	addi	a2,a2,1220 # ffffffffc0204708 <etext+0x1ba>
ffffffffc020024c:	00004597          	auipc	a1,0x4
ffffffffc0200250:	4dc58593          	addi	a1,a1,1244 # ffffffffc0204728 <etext+0x1da>
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	46c50513          	addi	a0,a0,1132 # ffffffffc02046c0 <etext+0x172>
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
ffffffffc0200292:	4aa50513          	addi	a0,a0,1194 # ffffffffc0204738 <etext+0x1ea>
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
ffffffffc02002b4:	4b050513          	addi	a0,a0,1200 # ffffffffc0204760 <etext+0x212>
ffffffffc02002b8:	e03ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc02002bc:	000b8563          	beqz	s7,ffffffffc02002c6 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002c0:	855e                	mv	a0,s7
ffffffffc02002c2:	48c000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc02002c6:	00004c17          	auipc	s8,0x4
ffffffffc02002ca:	502c0c13          	addi	s8,s8,1282 # ffffffffc02047c8 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002ce:	00005917          	auipc	s2,0x5
ffffffffc02002d2:	43a90913          	addi	s2,s2,1082 # ffffffffc0205708 <commands+0xf40>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d6:	00004497          	auipc	s1,0x4
ffffffffc02002da:	4b248493          	addi	s1,s1,1202 # ffffffffc0204788 <etext+0x23a>
        if (argc == MAXARGS - 1) {
ffffffffc02002de:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002e0:	00004b17          	auipc	s6,0x4
ffffffffc02002e4:	4b0b0b13          	addi	s6,s6,1200 # ffffffffc0204790 <etext+0x242>
        argv[argc ++] = buf;
ffffffffc02002e8:	00004a17          	auipc	s4,0x4
ffffffffc02002ec:	3d0a0a13          	addi	s4,s4,976 # ffffffffc02046b8 <etext+0x16a>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002f2:	854a                	mv	a0,s2
ffffffffc02002f4:	1a6040ef          	jal	ra,ffffffffc020449a <readline>
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
ffffffffc020030e:	4bed0d13          	addi	s10,s10,1214 # ffffffffc02047c8 <commands>
        argv[argc ++] = buf;
ffffffffc0200312:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200314:	4401                	li	s0,0
ffffffffc0200316:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	537030ef          	jal	ra,ffffffffc020404e <strcmp>
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
ffffffffc020032c:	523030ef          	jal	ra,ffffffffc020404e <strcmp>
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
ffffffffc020036a:	503030ef          	jal	ra,ffffffffc020406c <strchr>
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
ffffffffc02003a8:	4c5030ef          	jal	ra,ffffffffc020406c <strchr>
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
ffffffffc02003c6:	3ee50513          	addi	a0,a0,1006 # ffffffffc02047b0 <etext+0x262>
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
ffffffffc02003f6:	49f030ef          	jal	ra,ffffffffc0204094 <memcpy>
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
ffffffffc020041a:	47b030ef          	jal	ra,ffffffffc0204094 <memcpy>
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
ffffffffc0200450:	3c450513          	addi	a0,a0,964 # ffffffffc0204810 <commands+0x48>
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
ffffffffc0200528:	30c50513          	addi	a0,a0,780 # ffffffffc0204830 <commands+0x68>
ffffffffc020052c:	b8fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	fe853503          	ld	a0,-24(a0) # ffffffffc0211518 <check_mm_struct>
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
ffffffffc0200548:	20a0106f          	j	ffffffffc0201752 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020054c:	00004617          	auipc	a2,0x4
ffffffffc0200550:	30460613          	addi	a2,a2,772 # ffffffffc0204850 <commands+0x88>
ffffffffc0200554:	07800593          	li	a1,120
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	31050513          	addi	a0,a0,784 # ffffffffc0204868 <commands+0xa0>
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
ffffffffc020058e:	2f650513          	addi	a0,a0,758 # ffffffffc0204880 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	2fe50513          	addi	a0,a0,766 # ffffffffc0204898 <commands+0xd0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	30850513          	addi	a0,a0,776 # ffffffffc02048b0 <commands+0xe8>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	31250513          	addi	a0,a0,786 # ffffffffc02048c8 <commands+0x100>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	31c50513          	addi	a0,a0,796 # ffffffffc02048e0 <commands+0x118>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	32650513          	addi	a0,a0,806 # ffffffffc02048f8 <commands+0x130>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	33050513          	addi	a0,a0,816 # ffffffffc0204910 <commands+0x148>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	33a50513          	addi	a0,a0,826 # ffffffffc0204928 <commands+0x160>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	34450513          	addi	a0,a0,836 # ffffffffc0204940 <commands+0x178>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	34e50513          	addi	a0,a0,846 # ffffffffc0204958 <commands+0x190>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	35850513          	addi	a0,a0,856 # ffffffffc0204970 <commands+0x1a8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	36250513          	addi	a0,a0,866 # ffffffffc0204988 <commands+0x1c0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	36c50513          	addi	a0,a0,876 # ffffffffc02049a0 <commands+0x1d8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	37650513          	addi	a0,a0,886 # ffffffffc02049b8 <commands+0x1f0>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	38050513          	addi	a0,a0,896 # ffffffffc02049d0 <commands+0x208>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	38a50513          	addi	a0,a0,906 # ffffffffc02049e8 <commands+0x220>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	39450513          	addi	a0,a0,916 # ffffffffc0204a00 <commands+0x238>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	39e50513          	addi	a0,a0,926 # ffffffffc0204a18 <commands+0x250>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	3a850513          	addi	a0,a0,936 # ffffffffc0204a30 <commands+0x268>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	3b250513          	addi	a0,a0,946 # ffffffffc0204a48 <commands+0x280>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	3bc50513          	addi	a0,a0,956 # ffffffffc0204a60 <commands+0x298>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	3c650513          	addi	a0,a0,966 # ffffffffc0204a78 <commands+0x2b0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	3d050513          	addi	a0,a0,976 # ffffffffc0204a90 <commands+0x2c8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	3da50513          	addi	a0,a0,986 # ffffffffc0204aa8 <commands+0x2e0>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	3e450513          	addi	a0,a0,996 # ffffffffc0204ac0 <commands+0x2f8>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	3ee50513          	addi	a0,a0,1006 # ffffffffc0204ad8 <commands+0x310>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	3f850513          	addi	a0,a0,1016 # ffffffffc0204af0 <commands+0x328>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	40250513          	addi	a0,a0,1026 # ffffffffc0204b08 <commands+0x340>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	40c50513          	addi	a0,a0,1036 # ffffffffc0204b20 <commands+0x358>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	41650513          	addi	a0,a0,1046 # ffffffffc0204b38 <commands+0x370>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	42050513          	addi	a0,a0,1056 # ffffffffc0204b50 <commands+0x388>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	42650513          	addi	a0,a0,1062 # ffffffffc0204b68 <commands+0x3a0>
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
ffffffffc020075a:	42a50513          	addi	a0,a0,1066 # ffffffffc0204b80 <commands+0x3b8>
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
ffffffffc0200772:	42a50513          	addi	a0,a0,1066 # ffffffffc0204b98 <commands+0x3d0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	43250513          	addi	a0,a0,1074 # ffffffffc0204bb0 <commands+0x3e8>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	43a50513          	addi	a0,a0,1082 # ffffffffc0204bc8 <commands+0x400>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	43e50513          	addi	a0,a0,1086 # ffffffffc0204be0 <commands+0x418>
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
ffffffffc02007c2:	4ea70713          	addi	a4,a4,1258 # ffffffffc0204ca8 <commands+0x4e0>
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
ffffffffc02007d4:	48850513          	addi	a0,a0,1160 # ffffffffc0204c58 <commands+0x490>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	45c50513          	addi	a0,a0,1116 # ffffffffc0204c38 <commands+0x470>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	41050513          	addi	a0,a0,1040 # ffffffffc0204bf8 <commands+0x430>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	42450513          	addi	a0,a0,1060 # ffffffffc0204c18 <commands+0x450>
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
ffffffffc020082a:	46250513          	addi	a0,a0,1122 # ffffffffc0204c88 <commands+0x4c0>
ffffffffc020082e:	88dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200832:	bf31                	j	ffffffffc020074e <print_trapframe>
}
ffffffffc0200834:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200836:	06400593          	li	a1,100
ffffffffc020083a:	00004517          	auipc	a0,0x4
ffffffffc020083e:	43e50513          	addi	a0,a0,1086 # ffffffffc0204c78 <commands+0x4b0>
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
ffffffffc0200860:	63470713          	addi	a4,a4,1588 # ffffffffc0204e90 <commands+0x6c8>
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
ffffffffc0200872:	60a50513          	addi	a0,a0,1546 # ffffffffc0204e78 <commands+0x6b0>
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
ffffffffc0200894:	44850513          	addi	a0,a0,1096 # ffffffffc0204cd8 <commands+0x510>
}
ffffffffc0200898:	6442                	ld	s0,16(sp)
ffffffffc020089a:	60e2                	ld	ra,24(sp)
ffffffffc020089c:	64a2                	ld	s1,8(sp)
ffffffffc020089e:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008a0:	81bff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	45450513          	addi	a0,a0,1108 # ffffffffc0204cf8 <commands+0x530>
ffffffffc02008ac:	b7f5                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008ae:	00004517          	auipc	a0,0x4
ffffffffc02008b2:	46a50513          	addi	a0,a0,1130 # ffffffffc0204d18 <commands+0x550>
ffffffffc02008b6:	b7cd                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008b8:	00004517          	auipc	a0,0x4
ffffffffc02008bc:	47850513          	addi	a0,a0,1144 # ffffffffc0204d30 <commands+0x568>
ffffffffc02008c0:	bfe1                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008c2:	00004517          	auipc	a0,0x4
ffffffffc02008c6:	47e50513          	addi	a0,a0,1150 # ffffffffc0204d40 <commands+0x578>
ffffffffc02008ca:	b7f9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	49450513          	addi	a0,a0,1172 # ffffffffc0204d60 <commands+0x598>
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
ffffffffc02008ee:	48e60613          	addi	a2,a2,1166 # ffffffffc0204d78 <commands+0x5b0>
ffffffffc02008f2:	0ca00593          	li	a1,202
ffffffffc02008f6:	00004517          	auipc	a0,0x4
ffffffffc02008fa:	f7250513          	addi	a0,a0,-142 # ffffffffc0204868 <commands+0xa0>
ffffffffc02008fe:	805ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	49650513          	addi	a0,a0,1174 # ffffffffc0204d98 <commands+0x5d0>
ffffffffc020090a:	b779                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc020090c:	00004517          	auipc	a0,0x4
ffffffffc0200910:	4a450513          	addi	a0,a0,1188 # ffffffffc0204db0 <commands+0x5e8>
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
ffffffffc020092e:	44e60613          	addi	a2,a2,1102 # ffffffffc0204d78 <commands+0x5b0>
ffffffffc0200932:	0d400593          	li	a1,212
ffffffffc0200936:	00004517          	auipc	a0,0x4
ffffffffc020093a:	f3250513          	addi	a0,a0,-206 # ffffffffc0204868 <commands+0xa0>
ffffffffc020093e:	fc4ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	48650513          	addi	a0,a0,1158 # ffffffffc0204dc8 <commands+0x600>
ffffffffc020094a:	b7b9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc020094c:	00004517          	auipc	a0,0x4
ffffffffc0200950:	49c50513          	addi	a0,a0,1180 # ffffffffc0204de8 <commands+0x620>
ffffffffc0200954:	b791                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200956:	00004517          	auipc	a0,0x4
ffffffffc020095a:	4b250513          	addi	a0,a0,1202 # ffffffffc0204e08 <commands+0x640>
ffffffffc020095e:	bf2d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200960:	00004517          	auipc	a0,0x4
ffffffffc0200964:	4c850513          	addi	a0,a0,1224 # ffffffffc0204e28 <commands+0x660>
ffffffffc0200968:	bf05                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	4de50513          	addi	a0,a0,1246 # ffffffffc0204e48 <commands+0x680>
ffffffffc0200972:	b71d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	4ec50513          	addi	a0,a0,1260 # ffffffffc0204e60 <commands+0x698>
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
ffffffffc0200998:	3e460613          	addi	a2,a2,996 # ffffffffc0204d78 <commands+0x5b0>
ffffffffc020099c:	0ea00593          	li	a1,234
ffffffffc02009a0:	00004517          	auipc	a0,0x4
ffffffffc02009a4:	ec850513          	addi	a0,a0,-312 # ffffffffc0204868 <commands+0xa0>
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
ffffffffc02009c4:	3b860613          	addi	a2,a2,952 # ffffffffc0204d78 <commands+0x5b0>
ffffffffc02009c8:	0f100593          	li	a1,241
ffffffffc02009cc:	00004517          	auipc	a0,0x4
ffffffffc02009d0:	e9c50513          	addi	a0,a0,-356 # ffffffffc0204868 <commands+0xa0>
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

ffffffffc0200ab0 <_lru_init_mm>:
 * 参数:
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ab0:	00010797          	auipc	a5,0x10
ffffffffc0200ab4:	59078793          	addi	a5,a5,1424 # ffffffffc0211040 <pra_list_head>
 */
static int _lru_init_mm(struct mm_struct *mm)
{     
    list_init(&pra_list_head);
    curr_ptr = &pra_list_head;
    mm->sm_priv = &pra_list_head;
ffffffffc0200ab8:	f51c                	sd	a5,40(a0)
ffffffffc0200aba:	e79c                	sd	a5,8(a5)
ffffffffc0200abc:	e39c                	sd	a5,0(a5)
    curr_ptr = &pra_list_head;
ffffffffc0200abe:	00011717          	auipc	a4,0x11
ffffffffc0200ac2:	a4f73923          	sd	a5,-1454(a4) # ffffffffc0211510 <curr_ptr>
    //cprintf(" mm->sm_priv %x in lru_init_mm\n",mm->sm_priv);
    return 0;
}
ffffffffc0200ac6:	4501                	li	a0,0
ffffffffc0200ac8:	8082                	ret

ffffffffc0200aca <_lru_init>:
 * 功能: 未知
 */
static int _lru_init(void)
{
    return 0;
}
ffffffffc0200aca:	4501                	li	a0,0
ffffffffc0200acc:	8082                	ret

ffffffffc0200ace <_lru_set_unswappable>:
 * 功能: 未知
 */
static int _lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0200ace:	4501                	li	a0,0
ffffffffc0200ad0:	8082                	ret

ffffffffc0200ad2 <_lru_tick_event>:
 * 功能: 未知
 */
static int _lru_tick_event(struct mm_struct *mm)
{ 
    return 0; 
}
ffffffffc0200ad2:	4501                	li	a0,0
ffffffffc0200ad4:	8082                	ret

ffffffffc0200ad6 <_lru_swap_out_victim>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0200ad6:	7518                	ld	a4,40(a0)
{
ffffffffc0200ad8:	1141                	addi	sp,sp,-16
ffffffffc0200ada:	e406                	sd	ra,8(sp)
    assert(head != NULL);
ffffffffc0200adc:	c32d                	beqz	a4,ffffffffc0200b3e <_lru_swap_out_victim+0x68>
    assert(in_tick==0);
ffffffffc0200ade:	e221                	bnez	a2,ffffffffc0200b1e <_lru_swap_out_victim+0x48>
 * 参数:  
 * @listelm:    当前节点(链表头)
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200ae0:	87ae                	mv	a5,a1
ffffffffc0200ae2:	630c                	ld	a1,0(a4)
    curr_ptr = list_prev(head); 
ffffffffc0200ae4:	00011697          	auipc	a3,0x11
ffffffffc0200ae8:	a2b6b623          	sd	a1,-1492(a3) # ffffffffc0211510 <curr_ptr>
    if(curr_ptr == head) 
ffffffffc0200aec:	02b70363          	beq	a4,a1,ffffffffc0200b12 <_lru_swap_out_victim+0x3c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200af0:	6194                	ld	a3,0(a1)
ffffffffc0200af2:	6598                	ld	a4,8(a1)
    struct Page* page = le2page(curr_ptr, pra_page_link);
ffffffffc0200af4:	fd058613          	addi	a2,a1,-48
    cprintf("curr_ptr %p\n",curr_ptr);
ffffffffc0200af8:	00004517          	auipc	a0,0x4
ffffffffc0200afc:	42850513          	addi	a0,a0,1064 # ffffffffc0204f20 <commands+0x758>
 * 功能:通过使上一个和下一个节点相互连接(指向)来删除链表节点。
 * 注意:这仅用于内部列表操作，我们已经知道上一个/下一个节点了！
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200b00:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0200b02:	e314                	sd	a3,0(a4)
    *ptr_page = page;
ffffffffc0200b04:	e390                	sd	a2,0(a5)
    cprintf("curr_ptr %p\n",curr_ptr);
ffffffffc0200b06:	db4ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0200b0a:	60a2                	ld	ra,8(sp)
ffffffffc0200b0c:	4501                	li	a0,0
ffffffffc0200b0e:	0141                	addi	sp,sp,16
ffffffffc0200b10:	8082                	ret
ffffffffc0200b12:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc0200b14:	0007b023          	sd	zero,0(a5)
}
ffffffffc0200b18:	4501                	li	a0,0
ffffffffc0200b1a:	0141                	addi	sp,sp,16
ffffffffc0200b1c:	8082                	ret
    assert(in_tick==0);
ffffffffc0200b1e:	00004697          	auipc	a3,0x4
ffffffffc0200b22:	3f268693          	addi	a3,a3,1010 # ffffffffc0204f10 <commands+0x748>
ffffffffc0200b26:	00004617          	auipc	a2,0x4
ffffffffc0200b2a:	3ba60613          	addi	a2,a2,954 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0200b2e:	04100593          	li	a1,65
ffffffffc0200b32:	00004517          	auipc	a0,0x4
ffffffffc0200b36:	3c650513          	addi	a0,a0,966 # ffffffffc0204ef8 <commands+0x730>
ffffffffc0200b3a:	dc8ff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(head != NULL);
ffffffffc0200b3e:	00004697          	auipc	a3,0x4
ffffffffc0200b42:	39268693          	addi	a3,a3,914 # ffffffffc0204ed0 <commands+0x708>
ffffffffc0200b46:	00004617          	auipc	a2,0x4
ffffffffc0200b4a:	39a60613          	addi	a2,a2,922 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0200b4e:	04000593          	li	a1,64
ffffffffc0200b52:	00004517          	auipc	a0,0x4
ffffffffc0200b56:	3a650513          	addi	a0,a0,934 # ffffffffc0204ef8 <commands+0x730>
ffffffffc0200b5a:	da8ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200b5e <update_visited>:
 * 功能:将页表中的A信息位更新到page->visited
 * 参数:
 *      page:需要更新的物理页页面描述符
 */
static void update_visited(struct Page* page)
{
ffffffffc0200b5e:	1101                	addi	sp,sp,-32
ffffffffc0200b60:	e822                	sd	s0,16(sp)
ffffffffc0200b62:	842a                	mv	s0,a0
    cprintf("[调试信息]update_visited()\n");
ffffffffc0200b64:	00004517          	auipc	a0,0x4
ffffffffc0200b68:	3cc50513          	addi	a0,a0,972 # ffffffffc0204f30 <commands+0x768>
{
ffffffffc0200b6c:	ec06                	sd	ra,24(sp)
ffffffffc0200b6e:	e426                	sd	s1,8(sp)
    cprintf("[调试信息]update_visited()\n");
ffffffffc0200b70:	d4aff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern pde_t *boot_pgdir;
    uintptr_t la = ROUNDDOWN(page->pra_vaddr, PGSIZE);
ffffffffc0200b74:	603c                	ld	a5,64(s0)
    pte_t *ptep = get_pte(boot_pgdir, la, 1); // 获取指向页表中对应页表项的指针
ffffffffc0200b76:	75fd                	lui	a1,0xfffff
ffffffffc0200b78:	4605                	li	a2,1
ffffffffc0200b7a:	8dfd                	and	a1,a1,a5
ffffffffc0200b7c:	00011517          	auipc	a0,0x11
ffffffffc0200b80:	9cc53503          	ld	a0,-1588(a0) # ffffffffc0211548 <boot_pgdir>
ffffffffc0200b84:	0c8020ef          	jal	ra,ffffffffc0202c4c <get_pte>
    cprintf("[调试信息]页表项=%x\n",(*ptep));
ffffffffc0200b88:	610c                	ld	a1,0(a0)
    pte_t *ptep = get_pte(boot_pgdir, la, 1); // 获取指向页表中对应页表项的指针
ffffffffc0200b8a:	84aa                	mv	s1,a0
    cprintf("[调试信息]页表项=%x\n",(*ptep));
ffffffffc0200b8c:	00004517          	auipc	a0,0x4
ffffffffc0200b90:	3c450513          	addi	a0,a0,964 # ffffffffc0204f50 <commands+0x788>
ffffffffc0200b94:	d26ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    page->visited = ((*ptep)>>6)&1;
ffffffffc0200b98:	6090                	ld	a2,0(s1)
    cprintf("[调试信息]0x%x的page->visited=%d\n",page->pra_vaddr,page->visited);
ffffffffc0200b9a:	602c                	ld	a1,64(s0)
ffffffffc0200b9c:	00004517          	auipc	a0,0x4
ffffffffc0200ba0:	3d450513          	addi	a0,a0,980 # ffffffffc0204f70 <commands+0x7a8>
    page->visited = ((*ptep)>>6)&1;
ffffffffc0200ba4:	8219                	srli	a2,a2,0x6
ffffffffc0200ba6:	8a05                	andi	a2,a2,1
ffffffffc0200ba8:	e810                	sd	a2,16(s0)
    cprintf("[调试信息]0x%x的page->visited=%d\n",page->pra_vaddr,page->visited);
ffffffffc0200baa:	d10ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if(page->visited==1) *ptep = (*ptep) - 64;
ffffffffc0200bae:	6818                	ld	a4,16(s0)
ffffffffc0200bb0:	4785                	li	a5,1
ffffffffc0200bb2:	00f71663          	bne	a4,a5,ffffffffc0200bbe <update_visited+0x60>
ffffffffc0200bb6:	609c                	ld	a5,0(s1)
ffffffffc0200bb8:	fc078793          	addi	a5,a5,-64
ffffffffc0200bbc:	e09c                	sd	a5,0(s1)
}
ffffffffc0200bbe:	60e2                	ld	ra,24(sp)
ffffffffc0200bc0:	6442                	ld	s0,16(sp)
ffffffffc0200bc2:	64a2                	ld	s1,8(sp)
ffffffffc0200bc4:	6105                	addi	sp,sp,32
ffffffffc0200bc6:	8082                	ret

ffffffffc0200bc8 <lru_update_list>:
{
ffffffffc0200bc8:	7179                	addi	sp,sp,-48
ffffffffc0200bca:	ec26                	sd	s1,24(sp)
    cprintf("[调试信息]进入lru_update_list()\n");
ffffffffc0200bcc:	00004517          	auipc	a0,0x4
ffffffffc0200bd0:	3cc50513          	addi	a0,a0,972 # ffffffffc0204f98 <commands+0x7d0>
    return listelm->next;
ffffffffc0200bd4:	00010497          	auipc	s1,0x10
ffffffffc0200bd8:	46c48493          	addi	s1,s1,1132 # ffffffffc0211040 <pra_list_head>
{
ffffffffc0200bdc:	f022                	sd	s0,32(sp)
ffffffffc0200bde:	f406                	sd	ra,40(sp)
ffffffffc0200be0:	e84a                	sd	s2,16(sp)
ffffffffc0200be2:	e44e                	sd	s3,8(sp)
    cprintf("[调试信息]进入lru_update_list()\n");
ffffffffc0200be4:	cd6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200be8:	6480                	ld	s0,8(s1)
    while(now != (&pra_list_head))
ffffffffc0200bea:	06940a63          	beq	s0,s1,ffffffffc0200c5e <lru_update_list+0x96>
ffffffffc0200bee:	00011997          	auipc	s3,0x11
ffffffffc0200bf2:	95a98993          	addi	s3,s3,-1702 # ffffffffc0211548 <boot_pgdir>
        uintptr_t la = ROUNDDOWN(page->pra_vaddr, PGSIZE);
ffffffffc0200bf6:	797d                	lui	s2,0xfffff
ffffffffc0200bf8:	a021                	j	ffffffffc0200c00 <lru_update_list+0x38>
ffffffffc0200bfa:	6400                	ld	s0,8(s0)
    while(now != (&pra_list_head))
ffffffffc0200bfc:	06940163          	beq	s0,s1,ffffffffc0200c5e <lru_update_list+0x96>
        uintptr_t la = ROUNDDOWN(page->pra_vaddr, PGSIZE);
ffffffffc0200c00:	680c                	ld	a1,16(s0)
        pte_t *ptep = get_pte(boot_pgdir, la, 1); // 获取指向页表中对应页表项的指针
ffffffffc0200c02:	0009b503          	ld	a0,0(s3)
ffffffffc0200c06:	4605                	li	a2,1
ffffffffc0200c08:	00b975b3          	and	a1,s2,a1
ffffffffc0200c0c:	040020ef          	jal	ra,ffffffffc0202c4c <get_pte>
        update_visited(page);
ffffffffc0200c10:	fd040513          	addi	a0,s0,-48
ffffffffc0200c14:	f4bff0ef          	jal	ra,ffffffffc0200b5e <update_visited>
        if( page->visited==1 )  
ffffffffc0200c18:	fe043703          	ld	a4,-32(s0)
ffffffffc0200c1c:	4785                	li	a5,1
ffffffffc0200c1e:	fcf71ee3          	bne	a4,a5,ffffffffc0200bfa <lru_update_list+0x32>
            cprintf("[调试信息]将0x%x放到链表的首部\n",page->pra_vaddr);
ffffffffc0200c22:	680c                	ld	a1,16(s0)
ffffffffc0200c24:	00004517          	auipc	a0,0x4
ffffffffc0200c28:	39c50513          	addi	a0,a0,924 # ffffffffc0204fc0 <commands+0x7f8>
ffffffffc0200c2c:	c8eff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c30:	6014                	ld	a3,0(s0)
ffffffffc0200c32:	6418                	ld	a4,8(s0)
            page->visited = 0;
ffffffffc0200c34:	fe043023          	sd	zero,-32(s0)
}
ffffffffc0200c38:	70a2                	ld	ra,40(sp)
    prev->next = next;
ffffffffc0200c3a:	e698                	sd	a4,8(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200c3c:	649c                	ld	a5,8(s1)
    next->prev = prev;
ffffffffc0200c3e:	e314                	sd	a3,0(a4)
ffffffffc0200c40:	6942                	ld	s2,16(sp)
    prev->next = next->prev = elm;
ffffffffc0200c42:	e380                	sd	s0,0(a5)
ffffffffc0200c44:	e480                	sd	s0,8(s1)
    elm->prev = prev;
ffffffffc0200c46:	e004                	sd	s1,0(s0)
    elm->next = next;
ffffffffc0200c48:	e41c                	sd	a5,8(s0)
ffffffffc0200c4a:	7402                	ld	s0,32(sp)
ffffffffc0200c4c:	64e2                	ld	s1,24(sp)
ffffffffc0200c4e:	69a2                	ld	s3,8(sp)
    cprintf("\n");
ffffffffc0200c50:	00005517          	auipc	a0,0x5
ffffffffc0200c54:	33850513          	addi	a0,a0,824 # ffffffffc0205f88 <default_pmm_manager+0x420>
}
ffffffffc0200c58:	6145                	addi	sp,sp,48
    cprintf("\n");
ffffffffc0200c5a:	c60ff06f          	j	ffffffffc02000ba <cprintf>
}
ffffffffc0200c5e:	70a2                	ld	ra,40(sp)
ffffffffc0200c60:	7402                	ld	s0,32(sp)
ffffffffc0200c62:	64e2                	ld	s1,24(sp)
ffffffffc0200c64:	6942                	ld	s2,16(sp)
ffffffffc0200c66:	69a2                	ld	s3,8(sp)
ffffffffc0200c68:	6145                	addi	sp,sp,48
ffffffffc0200c6a:	8082                	ret

ffffffffc0200c6c <testprint>:
{
ffffffffc0200c6c:	7179                	addi	sp,sp,-48
ffffffffc0200c6e:	ec26                	sd	s1,24(sp)
    return listelm->next;
ffffffffc0200c70:	00010497          	auipc	s1,0x10
ffffffffc0200c74:	3d048493          	addi	s1,s1,976 # ffffffffc0211040 <pra_list_head>
ffffffffc0200c78:	f022                	sd	s0,32(sp)
ffffffffc0200c7a:	6480                	ld	s0,8(s1)
ffffffffc0200c7c:	f406                	sd	ra,40(sp)
ffffffffc0200c7e:	e84a                	sd	s2,16(sp)
ffffffffc0200c80:	e44e                	sd	s3,8(sp)
ffffffffc0200c82:	e052                	sd	s4,0(sp)
    while(now!=&pra_list_head)
ffffffffc0200c84:	00940e63          	beq	s0,s1,ffffffffc0200ca0 <testprint+0x34>
        cprintf("%d ",page->visited);
ffffffffc0200c88:	00004917          	auipc	s2,0x4
ffffffffc0200c8c:	36890913          	addi	s2,s2,872 # ffffffffc0204ff0 <commands+0x828>
ffffffffc0200c90:	fe043583          	ld	a1,-32(s0)
ffffffffc0200c94:	854a                	mv	a0,s2
ffffffffc0200c96:	c24ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200c9a:	6400                	ld	s0,8(s0)
    while(now!=&pra_list_head)
ffffffffc0200c9c:	fe941ae3          	bne	s0,s1,ffffffffc0200c90 <testprint+0x24>
    cprintf("\n");
ffffffffc0200ca0:	00005517          	auipc	a0,0x5
ffffffffc0200ca4:	2e850513          	addi	a0,a0,744 # ffffffffc0205f88 <default_pmm_manager+0x420>
ffffffffc0200ca8:	c12ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200cac:	6480                	ld	s0,8(s1)
    while(now!=&pra_list_head)
ffffffffc0200cae:	02940c63          	beq	s0,s1,ffffffffc0200ce6 <testprint+0x7a>
ffffffffc0200cb2:	00011a17          	auipc	s4,0x11
ffffffffc0200cb6:	896a0a13          	addi	s4,s4,-1898 # ffffffffc0211548 <boot_pgdir>
        uintptr_t la = ROUNDDOWN(page->pra_vaddr, PGSIZE);
ffffffffc0200cba:	79fd                	lui	s3,0xfffff
        cprintf("%d ",(*ptep)>>6&1);
ffffffffc0200cbc:	00004917          	auipc	s2,0x4
ffffffffc0200cc0:	33490913          	addi	s2,s2,820 # ffffffffc0204ff0 <commands+0x828>
        uintptr_t la = ROUNDDOWN(page->pra_vaddr, PGSIZE);
ffffffffc0200cc4:	680c                	ld	a1,16(s0)
        pte_t *ptep = get_pte(boot_pgdir, la, 1); // 获取指向页表中对应页表项的指针
ffffffffc0200cc6:	000a3503          	ld	a0,0(s4)
ffffffffc0200cca:	4605                	li	a2,1
ffffffffc0200ccc:	00b9f5b3          	and	a1,s3,a1
ffffffffc0200cd0:	77d010ef          	jal	ra,ffffffffc0202c4c <get_pte>
        cprintf("%d ",(*ptep)>>6&1);
ffffffffc0200cd4:	610c                	ld	a1,0(a0)
ffffffffc0200cd6:	854a                	mv	a0,s2
ffffffffc0200cd8:	8199                	srli	a1,a1,0x6
ffffffffc0200cda:	8985                	andi	a1,a1,1
ffffffffc0200cdc:	bdeff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200ce0:	6400                	ld	s0,8(s0)
    while(now!=&pra_list_head)
ffffffffc0200ce2:	fe9411e3          	bne	s0,s1,ffffffffc0200cc4 <testprint+0x58>
    cprintf("\n"); 
ffffffffc0200ce6:	00005517          	auipc	a0,0x5
ffffffffc0200cea:	2a250513          	addi	a0,a0,674 # ffffffffc0205f88 <default_pmm_manager+0x420>
ffffffffc0200cee:	bccff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200cf2:	6480                	ld	s0,8(s1)
    while(now!=&pra_list_head)
ffffffffc0200cf4:	00940d63          	beq	s0,s1,ffffffffc0200d0e <testprint+0xa2>
        cprintf("0x%x ",page->pra_vaddr);
ffffffffc0200cf8:	00004917          	auipc	s2,0x4
ffffffffc0200cfc:	30090913          	addi	s2,s2,768 # ffffffffc0204ff8 <commands+0x830>
ffffffffc0200d00:	680c                	ld	a1,16(s0)
ffffffffc0200d02:	854a                	mv	a0,s2
ffffffffc0200d04:	bb6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200d08:	6400                	ld	s0,8(s0)
    while(now!=&pra_list_head)
ffffffffc0200d0a:	fe941be3          	bne	s0,s1,ffffffffc0200d00 <testprint+0x94>
}
ffffffffc0200d0e:	7402                	ld	s0,32(sp)
ffffffffc0200d10:	70a2                	ld	ra,40(sp)
ffffffffc0200d12:	64e2                	ld	s1,24(sp)
ffffffffc0200d14:	6942                	ld	s2,16(sp)
ffffffffc0200d16:	69a2                	ld	s3,8(sp)
ffffffffc0200d18:	6a02                	ld	s4,0(sp)
    cprintf("\n\n");   
ffffffffc0200d1a:	00004517          	auipc	a0,0x4
ffffffffc0200d1e:	2e650513          	addi	a0,a0,742 # ffffffffc0205000 <commands+0x838>
}
ffffffffc0200d22:	6145                	addi	sp,sp,48
    cprintf("\n\n");   
ffffffffc0200d24:	b96ff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0200d28 <_lru_check_swap>:
static int _lru_check_swap(void) {
ffffffffc0200d28:	711d                	addi	sp,sp,-96
    cprintf("[调试信息]进入_lru_check_swap\n");
ffffffffc0200d2a:	00004517          	auipc	a0,0x4
ffffffffc0200d2e:	2de50513          	addi	a0,a0,734 # ffffffffc0205008 <commands+0x840>
static int _lru_check_swap(void) {
ffffffffc0200d32:	ec86                	sd	ra,88(sp)
ffffffffc0200d34:	e8a2                	sd	s0,80(sp)
ffffffffc0200d36:	e4a6                	sd	s1,72(sp)
ffffffffc0200d38:	e0ca                	sd	s2,64(sp)
ffffffffc0200d3a:	fc4e                	sd	s3,56(sp)
ffffffffc0200d3c:	f852                	sd	s4,48(sp)
ffffffffc0200d3e:	f456                	sd	s5,40(sp)
ffffffffc0200d40:	f05a                	sd	s6,32(sp)
ffffffffc0200d42:	ec5e                	sd	s7,24(sp)
ffffffffc0200d44:	e862                	sd	s8,16(sp)
ffffffffc0200d46:	e466                	sd	s9,8(sp)
    cprintf("[调试信息]进入_lru_check_swap\n");
ffffffffc0200d48:	b72ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("[调试信息]进入clear_A()\n");
ffffffffc0200d4c:	00004517          	auipc	a0,0x4
ffffffffc0200d50:	2e450513          	addi	a0,a0,740 # ffffffffc0205030 <commands+0x868>
ffffffffc0200d54:	00010497          	auipc	s1,0x10
ffffffffc0200d58:	2ec48493          	addi	s1,s1,748 # ffffffffc0211040 <pra_list_head>
ffffffffc0200d5c:	b5eff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200d60:	6480                	ld	s0,8(s1)
    while(now!=&pra_list_head)
ffffffffc0200d62:	00940b63          	beq	s0,s1,ffffffffc0200d78 <_lru_check_swap+0x50>
        update_visited(page);
ffffffffc0200d66:	fd040513          	addi	a0,s0,-48
ffffffffc0200d6a:	df5ff0ef          	jal	ra,ffffffffc0200b5e <update_visited>
        page->visited = 0;
ffffffffc0200d6e:	fe043023          	sd	zero,-32(s0)
ffffffffc0200d72:	6400                	ld	s0,8(s0)
    while(now!=&pra_list_head)
ffffffffc0200d74:	fe9419e3          	bne	s0,s1,ffffffffc0200d66 <_lru_check_swap+0x3e>
    *(unsigned char *)0x3000 = 0x0c;testprint();lru_update_list();testprint(); // 3124
ffffffffc0200d78:	6b0d                	lui	s6,0x3
ffffffffc0200d7a:	4bb1                	li	s7,12
    testprint();
ffffffffc0200d7c:	ef1ff0ef          	jal	ra,ffffffffc0200c6c <testprint>
    *(unsigned char *)0x3000 = 0x0c;testprint();lru_update_list();testprint(); // 3124
ffffffffc0200d80:	017b0023          	sb	s7,0(s6) # 3000 <kern_entry-0xffffffffc01fd000>
ffffffffc0200d84:	ee9ff0ef          	jal	ra,ffffffffc0200c6c <testprint>
ffffffffc0200d88:	e41ff0ef          	jal	ra,ffffffffc0200bc8 <lru_update_list>
ffffffffc0200d8c:	ee1ff0ef          	jal	ra,ffffffffc0200c6c <testprint>
    assert(pgfault_num==4);
ffffffffc0200d90:	4791                	li	a5,4
ffffffffc0200d92:	00010917          	auipc	s2,0x10
ffffffffc0200d96:	78e92903          	lw	s2,1934(s2) # ffffffffc0211520 <pgfault_num>
ffffffffc0200d9a:	00010a17          	auipc	s4,0x10
ffffffffc0200d9e:	786a0a13          	addi	s4,s4,1926 # ffffffffc0211520 <pgfault_num>
ffffffffc0200da2:	10f91963          	bne	s2,a5,ffffffffc0200eb4 <_lru_check_swap+0x18c>
    *(unsigned char *)0x1000 = 0x0a;testprint();lru_update_list();testprint(); // 1324
ffffffffc0200da6:	6485                	lui	s1,0x1
ffffffffc0200da8:	49a9                	li	s3,10
ffffffffc0200daa:	01348023          	sb	s3,0(s1) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0200dae:	ebfff0ef          	jal	ra,ffffffffc0200c6c <testprint>
ffffffffc0200db2:	e17ff0ef          	jal	ra,ffffffffc0200bc8 <lru_update_list>
ffffffffc0200db6:	eb7ff0ef          	jal	ra,ffffffffc0200c6c <testprint>
    assert(pgfault_num==4);
ffffffffc0200dba:	000a2403          	lw	s0,0(s4)
ffffffffc0200dbe:	2401                	sext.w	s0,s0
ffffffffc0200dc0:	17241a63          	bne	s0,s2,ffffffffc0200f34 <_lru_check_swap+0x20c>
    *(unsigned char *)0x4000 = 0x0d;testprint();lru_update_list();testprint();
ffffffffc0200dc4:	6c11                	lui	s8,0x4
ffffffffc0200dc6:	4cb5                	li	s9,13
ffffffffc0200dc8:	019c0023          	sb	s9,0(s8) # 4000 <kern_entry-0xffffffffc01fc000>
ffffffffc0200dcc:	ea1ff0ef          	jal	ra,ffffffffc0200c6c <testprint>
ffffffffc0200dd0:	df9ff0ef          	jal	ra,ffffffffc0200bc8 <lru_update_list>
ffffffffc0200dd4:	e99ff0ef          	jal	ra,ffffffffc0200c6c <testprint>
    assert(pgfault_num==4);
ffffffffc0200dd8:	000a2903          	lw	s2,0(s4)
ffffffffc0200ddc:	2901                	sext.w	s2,s2
ffffffffc0200dde:	12891b63          	bne	s2,s0,ffffffffc0200f14 <_lru_check_swap+0x1ec>
    *(unsigned char *)0x2000 = 0x0b;testprint();lru_update_list();testprint(); // 2413      // 2134 
ffffffffc0200de2:	6409                	lui	s0,0x2
ffffffffc0200de4:	4aad                	li	s5,11
ffffffffc0200de6:	01540023          	sb	s5,0(s0) # 2000 <kern_entry-0xffffffffc01fe000>
ffffffffc0200dea:	e83ff0ef          	jal	ra,ffffffffc0200c6c <testprint>
ffffffffc0200dee:	ddbff0ef          	jal	ra,ffffffffc0200bc8 <lru_update_list>
ffffffffc0200df2:	e7bff0ef          	jal	ra,ffffffffc0200c6c <testprint>
    assert(pgfault_num==4);
ffffffffc0200df6:	000a2783          	lw	a5,0(s4)
ffffffffc0200dfa:	2781                	sext.w	a5,a5
ffffffffc0200dfc:	0f279c63          	bne	a5,s2,ffffffffc0200ef4 <_lru_check_swap+0x1cc>
    *(unsigned char *)0x5000 = 0x0e;testprint();lru_update_list();testprint(); // 5241 3->5 // 5213 4->5 
ffffffffc0200e00:	6915                	lui	s2,0x5
ffffffffc0200e02:	4a39                	li	s4,14
ffffffffc0200e04:	01490023          	sb	s4,0(s2) # 5000 <kern_entry-0xffffffffc01fb000>
ffffffffc0200e08:	e65ff0ef          	jal	ra,ffffffffc0200c6c <testprint>
ffffffffc0200e0c:	dbdff0ef          	jal	ra,ffffffffc0200bc8 <lru_update_list>
ffffffffc0200e10:	e5dff0ef          	jal	ra,ffffffffc0200c6c <testprint>
    *(unsigned char *)0x2000 = 0x0b;testprint();lru_update_list();testprint(); // 2541      // 2513 
ffffffffc0200e14:	01540023          	sb	s5,0(s0)
ffffffffc0200e18:	e55ff0ef          	jal	ra,ffffffffc0200c6c <testprint>
ffffffffc0200e1c:	dadff0ef          	jal	ra,ffffffffc0200bc8 <lru_update_list>
ffffffffc0200e20:	e4dff0ef          	jal	ra,ffffffffc0200c6c <testprint>
    *(unsigned char *)0x1000 = 0x0a;testprint();lru_update_list();testprint(); // 1254      // 1253 
ffffffffc0200e24:	01348023          	sb	s3,0(s1)
ffffffffc0200e28:	e45ff0ef          	jal	ra,ffffffffc0200c6c <testprint>
ffffffffc0200e2c:	d9dff0ef          	jal	ra,ffffffffc0200bc8 <lru_update_list>
ffffffffc0200e30:	e3dff0ef          	jal	ra,ffffffffc0200c6c <testprint>
    *(unsigned char *)0x2000 = 0x0b;testprint();lru_update_list();testprint(); // 2154      // 2153 
ffffffffc0200e34:	01540023          	sb	s5,0(s0)
ffffffffc0200e38:	e35ff0ef          	jal	ra,ffffffffc0200c6c <testprint>
ffffffffc0200e3c:	d8dff0ef          	jal	ra,ffffffffc0200bc8 <lru_update_list>
ffffffffc0200e40:	e2dff0ef          	jal	ra,ffffffffc0200c6c <testprint>
    *(unsigned char *)0x3000 = 0x0c;testprint();lru_update_list();testprint(); // 3215 4->3 // 3215 
ffffffffc0200e44:	017b0023          	sb	s7,0(s6)
ffffffffc0200e48:	e25ff0ef          	jal	ra,ffffffffc0200c6c <testprint>
ffffffffc0200e4c:	d7dff0ef          	jal	ra,ffffffffc0200bc8 <lru_update_list>
ffffffffc0200e50:	e1dff0ef          	jal	ra,ffffffffc0200c6c <testprint>
    *(unsigned char *)0x4000 = 0x0d;testprint();lru_update_list();testprint(); // 4321 5->4 // 4321 5->4 
ffffffffc0200e54:	019c0023          	sb	s9,0(s8)
ffffffffc0200e58:	e15ff0ef          	jal	ra,ffffffffc0200c6c <testprint>
ffffffffc0200e5c:	d6dff0ef          	jal	ra,ffffffffc0200bc8 <lru_update_list>
ffffffffc0200e60:	e0dff0ef          	jal	ra,ffffffffc0200c6c <testprint>
    *(unsigned char *)0x5000 = 0x0e;testprint();lru_update_list();testprint(); // 5432 1->5 // 5432 1->5 
ffffffffc0200e64:	01490023          	sb	s4,0(s2)
ffffffffc0200e68:	e05ff0ef          	jal	ra,ffffffffc0200c6c <testprint>
ffffffffc0200e6c:	d5dff0ef          	jal	ra,ffffffffc0200bc8 <lru_update_list>
ffffffffc0200e70:	dfdff0ef          	jal	ra,ffffffffc0200c6c <testprint>
    assert(*(unsigned char *)0x1000 == 0x0a);testprint();lru_update_list();testprint(); //1543 2->1  // 1543 2->1 
ffffffffc0200e74:	0004c403          	lbu	s0,0(s1)
ffffffffc0200e78:	05341e63          	bne	s0,s3,ffffffffc0200ed4 <_lru_check_swap+0x1ac>
ffffffffc0200e7c:	df1ff0ef          	jal	ra,ffffffffc0200c6c <testprint>
ffffffffc0200e80:	d49ff0ef          	jal	ra,ffffffffc0200bc8 <lru_update_list>
ffffffffc0200e84:	de9ff0ef          	jal	ra,ffffffffc0200c6c <testprint>
    *(unsigned char *)0x1000 = 0x0a;testprint();lru_update_list();testprint(); 
ffffffffc0200e88:	00848023          	sb	s0,0(s1)
ffffffffc0200e8c:	de1ff0ef          	jal	ra,ffffffffc0200c6c <testprint>
ffffffffc0200e90:	d39ff0ef          	jal	ra,ffffffffc0200bc8 <lru_update_list>
ffffffffc0200e94:	dd9ff0ef          	jal	ra,ffffffffc0200c6c <testprint>
}
ffffffffc0200e98:	60e6                	ld	ra,88(sp)
ffffffffc0200e9a:	6446                	ld	s0,80(sp)
ffffffffc0200e9c:	64a6                	ld	s1,72(sp)
ffffffffc0200e9e:	6906                	ld	s2,64(sp)
ffffffffc0200ea0:	79e2                	ld	s3,56(sp)
ffffffffc0200ea2:	7a42                	ld	s4,48(sp)
ffffffffc0200ea4:	7aa2                	ld	s5,40(sp)
ffffffffc0200ea6:	7b02                	ld	s6,32(sp)
ffffffffc0200ea8:	6be2                	ld	s7,24(sp)
ffffffffc0200eaa:	6c42                	ld	s8,16(sp)
ffffffffc0200eac:	6ca2                	ld	s9,8(sp)
ffffffffc0200eae:	4501                	li	a0,0
ffffffffc0200eb0:	6125                	addi	sp,sp,96
ffffffffc0200eb2:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0200eb4:	00004697          	auipc	a3,0x4
ffffffffc0200eb8:	19c68693          	addi	a3,a3,412 # ffffffffc0205050 <commands+0x888>
ffffffffc0200ebc:	00004617          	auipc	a2,0x4
ffffffffc0200ec0:	02460613          	addi	a2,a2,36 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0200ec4:	0cf00593          	li	a1,207
ffffffffc0200ec8:	00004517          	auipc	a0,0x4
ffffffffc0200ecc:	03050513          	addi	a0,a0,48 # ffffffffc0204ef8 <commands+0x730>
ffffffffc0200ed0:	a32ff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);testprint();lru_update_list();testprint(); //1543 2->1  // 1543 2->1 
ffffffffc0200ed4:	00004697          	auipc	a3,0x4
ffffffffc0200ed8:	18c68693          	addi	a3,a3,396 # ffffffffc0205060 <commands+0x898>
ffffffffc0200edc:	00004617          	auipc	a2,0x4
ffffffffc0200ee0:	00460613          	addi	a2,a2,4 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0200ee4:	0e400593          	li	a1,228
ffffffffc0200ee8:	00004517          	auipc	a0,0x4
ffffffffc0200eec:	01050513          	addi	a0,a0,16 # ffffffffc0204ef8 <commands+0x730>
ffffffffc0200ef0:	a12ff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0200ef4:	00004697          	auipc	a3,0x4
ffffffffc0200ef8:	15c68693          	addi	a3,a3,348 # ffffffffc0205050 <commands+0x888>
ffffffffc0200efc:	00004617          	auipc	a2,0x4
ffffffffc0200f00:	fe460613          	addi	a2,a2,-28 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0200f04:	0d500593          	li	a1,213
ffffffffc0200f08:	00004517          	auipc	a0,0x4
ffffffffc0200f0c:	ff050513          	addi	a0,a0,-16 # ffffffffc0204ef8 <commands+0x730>
ffffffffc0200f10:	9f2ff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0200f14:	00004697          	auipc	a3,0x4
ffffffffc0200f18:	13c68693          	addi	a3,a3,316 # ffffffffc0205050 <commands+0x888>
ffffffffc0200f1c:	00004617          	auipc	a2,0x4
ffffffffc0200f20:	fc460613          	addi	a2,a2,-60 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0200f24:	0d300593          	li	a1,211
ffffffffc0200f28:	00004517          	auipc	a0,0x4
ffffffffc0200f2c:	fd050513          	addi	a0,a0,-48 # ffffffffc0204ef8 <commands+0x730>
ffffffffc0200f30:	9d2ff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc0200f34:	00004697          	auipc	a3,0x4
ffffffffc0200f38:	11c68693          	addi	a3,a3,284 # ffffffffc0205050 <commands+0x888>
ffffffffc0200f3c:	00004617          	auipc	a2,0x4
ffffffffc0200f40:	fa460613          	addi	a2,a2,-92 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0200f44:	0d100593          	li	a1,209
ffffffffc0200f48:	00004517          	auipc	a0,0x4
ffffffffc0200f4c:	fb050513          	addi	a0,a0,-80 # ffffffffc0204ef8 <commands+0x730>
ffffffffc0200f50:	9b2ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200f54 <_lru_map_swappable>:
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0200f54:	00010797          	auipc	a5,0x10
ffffffffc0200f58:	5bc7b783          	ld	a5,1468(a5) # ffffffffc0211510 <curr_ptr>
ffffffffc0200f5c:	cf89                	beqz	a5,ffffffffc0200f76 <_lru_map_swappable+0x22>
    list_add_before((list_entry_t*)mm->sm_priv,entry);
ffffffffc0200f5e:	751c                	ld	a5,40(a0)
ffffffffc0200f60:	03060713          	addi	a4,a2,48
}
ffffffffc0200f64:	4501                	li	a0,0
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200f66:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0200f68:	e398                	sd	a4,0(a5)
ffffffffc0200f6a:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0200f6c:	fe1c                	sd	a5,56(a2)
    page->visited=1;
ffffffffc0200f6e:	4785                	li	a5,1
    elm->prev = prev;
ffffffffc0200f70:	fa14                	sd	a3,48(a2)
ffffffffc0200f72:	ea1c                	sd	a5,16(a2)
}
ffffffffc0200f74:	8082                	ret
{
ffffffffc0200f76:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0200f78:	00004697          	auipc	a3,0x4
ffffffffc0200f7c:	11068693          	addi	a3,a3,272 # ffffffffc0205088 <commands+0x8c0>
ffffffffc0200f80:	00004617          	auipc	a2,0x4
ffffffffc0200f84:	f6060613          	addi	a2,a2,-160 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0200f88:	02d00593          	li	a1,45
ffffffffc0200f8c:	00004517          	auipc	a0,0x4
ffffffffc0200f90:	f6c50513          	addi	a0,a0,-148 # ffffffffc0204ef8 <commands+0x730>
{
ffffffffc0200f94:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0200f96:	96cff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200f9a <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200f9a:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200f9c:	00004697          	auipc	a3,0x4
ffffffffc0200fa0:	12c68693          	addi	a3,a3,300 # ffffffffc02050c8 <commands+0x900>
ffffffffc0200fa4:	00004617          	auipc	a2,0x4
ffffffffc0200fa8:	f3c60613          	addi	a2,a2,-196 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0200fac:	08000593          	li	a1,128
ffffffffc0200fb0:	00004517          	auipc	a0,0x4
ffffffffc0200fb4:	13850513          	addi	a0,a0,312 # ffffffffc02050e8 <commands+0x920>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200fb8:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200fba:	948ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200fbe <mm_create>:
mm_create(void) {
ffffffffc0200fbe:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200fc0:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0200fc4:	e022                	sd	s0,0(sp)
ffffffffc0200fc6:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200fc8:	531020ef          	jal	ra,ffffffffc0203cf8 <kmalloc>
ffffffffc0200fcc:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200fce:	c105                	beqz	a0,ffffffffc0200fee <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc0200fd0:	e408                	sd	a0,8(s0)
ffffffffc0200fd2:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200fd4:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200fd8:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200fdc:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200fe0:	00010797          	auipc	a5,0x10
ffffffffc0200fe4:	5587a783          	lw	a5,1368(a5) # ffffffffc0211538 <swap_init_ok>
ffffffffc0200fe8:	eb81                	bnez	a5,ffffffffc0200ff8 <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc0200fea:	02053423          	sd	zero,40(a0)
}
ffffffffc0200fee:	60a2                	ld	ra,8(sp)
ffffffffc0200ff0:	8522                	mv	a0,s0
ffffffffc0200ff2:	6402                	ld	s0,0(sp)
ffffffffc0200ff4:	0141                	addi	sp,sp,16
ffffffffc0200ff6:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200ff8:	693000ef          	jal	ra,ffffffffc0201e8a <swap_init_mm>
}
ffffffffc0200ffc:	60a2                	ld	ra,8(sp)
ffffffffc0200ffe:	8522                	mv	a0,s0
ffffffffc0201000:	6402                	ld	s0,0(sp)
ffffffffc0201002:	0141                	addi	sp,sp,16
ffffffffc0201004:	8082                	ret

ffffffffc0201006 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0201006:	1101                	addi	sp,sp,-32
ffffffffc0201008:	e04a                	sd	s2,0(sp)
ffffffffc020100a:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020100c:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0201010:	e822                	sd	s0,16(sp)
ffffffffc0201012:	e426                	sd	s1,8(sp)
ffffffffc0201014:	ec06                	sd	ra,24(sp)
ffffffffc0201016:	84ae                	mv	s1,a1
ffffffffc0201018:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020101a:	4df020ef          	jal	ra,ffffffffc0203cf8 <kmalloc>
    if (vma != NULL) {
ffffffffc020101e:	c509                	beqz	a0,ffffffffc0201028 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0201020:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201024:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201026:	ed00                	sd	s0,24(a0)
}
ffffffffc0201028:	60e2                	ld	ra,24(sp)
ffffffffc020102a:	6442                	ld	s0,16(sp)
ffffffffc020102c:	64a2                	ld	s1,8(sp)
ffffffffc020102e:	6902                	ld	s2,0(sp)
ffffffffc0201030:	6105                	addi	sp,sp,32
ffffffffc0201032:	8082                	ret

ffffffffc0201034 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0201034:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0201036:	c505                	beqz	a0,ffffffffc020105e <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0201038:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020103a:	c501                	beqz	a0,ffffffffc0201042 <find_vma+0xe>
ffffffffc020103c:	651c                	ld	a5,8(a0)
ffffffffc020103e:	02f5f263          	bgeu	a1,a5,ffffffffc0201062 <find_vma+0x2e>
    return listelm->next;
ffffffffc0201042:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0201044:	00f68d63          	beq	a3,a5,ffffffffc020105e <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0201048:	fe87b703          	ld	a4,-24(a5)
ffffffffc020104c:	00e5e663          	bltu	a1,a4,ffffffffc0201058 <find_vma+0x24>
ffffffffc0201050:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201054:	00e5ec63          	bltu	a1,a4,ffffffffc020106c <find_vma+0x38>
ffffffffc0201058:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020105a:	fef697e3          	bne	a3,a5,ffffffffc0201048 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc020105e:	4501                	li	a0,0
}
ffffffffc0201060:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201062:	691c                	ld	a5,16(a0)
ffffffffc0201064:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0201042 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0201068:	ea88                	sd	a0,16(a3)
ffffffffc020106a:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc020106c:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0201070:	ea88                	sd	a0,16(a3)
ffffffffc0201072:	8082                	ret

ffffffffc0201074 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201074:	6590                	ld	a2,8(a1)
ffffffffc0201076:	0105b803          	ld	a6,16(a1) # fffffffffffff010 <end+0x3fdedaa0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020107a:	1141                	addi	sp,sp,-16
ffffffffc020107c:	e406                	sd	ra,8(sp)
ffffffffc020107e:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201080:	01066763          	bltu	a2,a6,ffffffffc020108e <insert_vma_struct+0x1a>
ffffffffc0201084:	a085                	j	ffffffffc02010e4 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0201086:	fe87b703          	ld	a4,-24(a5)
ffffffffc020108a:	04e66863          	bltu	a2,a4,ffffffffc02010da <insert_vma_struct+0x66>
ffffffffc020108e:	86be                	mv	a3,a5
ffffffffc0201090:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0201092:	fef51ae3          	bne	a0,a5,ffffffffc0201086 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0201096:	02a68463          	beq	a3,a0,ffffffffc02010be <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020109a:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020109e:	fe86b883          	ld	a7,-24(a3)
ffffffffc02010a2:	08e8f163          	bgeu	a7,a4,ffffffffc0201124 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02010a6:	04e66f63          	bltu	a2,a4,ffffffffc0201104 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc02010aa:	00f50a63          	beq	a0,a5,ffffffffc02010be <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02010ae:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02010b2:	05076963          	bltu	a4,a6,ffffffffc0201104 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02010b6:	ff07b603          	ld	a2,-16(a5)
ffffffffc02010ba:	02c77363          	bgeu	a4,a2,ffffffffc02010e0 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02010be:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02010c0:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02010c2:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02010c6:	e390                	sd	a2,0(a5)
ffffffffc02010c8:	e690                	sd	a2,8(a3)
}
ffffffffc02010ca:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02010cc:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02010ce:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc02010d0:	0017079b          	addiw	a5,a4,1
ffffffffc02010d4:	d11c                	sw	a5,32(a0)
}
ffffffffc02010d6:	0141                	addi	sp,sp,16
ffffffffc02010d8:	8082                	ret
    if (le_prev != list) {
ffffffffc02010da:	fca690e3          	bne	a3,a0,ffffffffc020109a <insert_vma_struct+0x26>
ffffffffc02010de:	bfd1                	j	ffffffffc02010b2 <insert_vma_struct+0x3e>
ffffffffc02010e0:	ebbff0ef          	jal	ra,ffffffffc0200f9a <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02010e4:	00004697          	auipc	a3,0x4
ffffffffc02010e8:	01468693          	addi	a3,a3,20 # ffffffffc02050f8 <commands+0x930>
ffffffffc02010ec:	00004617          	auipc	a2,0x4
ffffffffc02010f0:	df460613          	addi	a2,a2,-524 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02010f4:	08700593          	li	a1,135
ffffffffc02010f8:	00004517          	auipc	a0,0x4
ffffffffc02010fc:	ff050513          	addi	a0,a0,-16 # ffffffffc02050e8 <commands+0x920>
ffffffffc0201100:	802ff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201104:	00004697          	auipc	a3,0x4
ffffffffc0201108:	03468693          	addi	a3,a3,52 # ffffffffc0205138 <commands+0x970>
ffffffffc020110c:	00004617          	auipc	a2,0x4
ffffffffc0201110:	dd460613          	addi	a2,a2,-556 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201114:	07f00593          	li	a1,127
ffffffffc0201118:	00004517          	auipc	a0,0x4
ffffffffc020111c:	fd050513          	addi	a0,a0,-48 # ffffffffc02050e8 <commands+0x920>
ffffffffc0201120:	fe3fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201124:	00004697          	auipc	a3,0x4
ffffffffc0201128:	ff468693          	addi	a3,a3,-12 # ffffffffc0205118 <commands+0x950>
ffffffffc020112c:	00004617          	auipc	a2,0x4
ffffffffc0201130:	db460613          	addi	a2,a2,-588 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201134:	07e00593          	li	a1,126
ffffffffc0201138:	00004517          	auipc	a0,0x4
ffffffffc020113c:	fb050513          	addi	a0,a0,-80 # ffffffffc02050e8 <commands+0x920>
ffffffffc0201140:	fc3fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201144 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0201144:	1141                	addi	sp,sp,-16
ffffffffc0201146:	e022                	sd	s0,0(sp)
ffffffffc0201148:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020114a:	6508                	ld	a0,8(a0)
ffffffffc020114c:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020114e:	00a40e63          	beq	s0,a0,ffffffffc020116a <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201152:	6118                	ld	a4,0(a0)
ffffffffc0201154:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0201156:	03000593          	li	a1,48
ffffffffc020115a:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020115c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020115e:	e398                	sd	a4,0(a5)
ffffffffc0201160:	453020ef          	jal	ra,ffffffffc0203db2 <kfree>
    return listelm->next;
ffffffffc0201164:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201166:	fea416e3          	bne	s0,a0,ffffffffc0201152 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020116a:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc020116c:	6402                	ld	s0,0(sp)
ffffffffc020116e:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201170:	03000593          	li	a1,48
}
ffffffffc0201174:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201176:	43d0206f          	j	ffffffffc0203db2 <kfree>

ffffffffc020117a <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020117a:	715d                	addi	sp,sp,-80
ffffffffc020117c:	e486                	sd	ra,72(sp)
ffffffffc020117e:	f44e                	sd	s3,40(sp)
ffffffffc0201180:	f052                	sd	s4,32(sp)
ffffffffc0201182:	e0a2                	sd	s0,64(sp)
ffffffffc0201184:	fc26                	sd	s1,56(sp)
ffffffffc0201186:	f84a                	sd	s2,48(sp)
ffffffffc0201188:	ec56                	sd	s5,24(sp)
ffffffffc020118a:	e85a                	sd	s6,16(sp)
ffffffffc020118c:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020118e:	285010ef          	jal	ra,ffffffffc0202c12 <nr_free_pages>
ffffffffc0201192:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201194:	27f010ef          	jal	ra,ffffffffc0202c12 <nr_free_pages>
ffffffffc0201198:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020119a:	03000513          	li	a0,48
ffffffffc020119e:	35b020ef          	jal	ra,ffffffffc0203cf8 <kmalloc>
    if (mm != NULL) {
ffffffffc02011a2:	56050863          	beqz	a0,ffffffffc0201712 <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc02011a6:	e508                	sd	a0,8(a0)
ffffffffc02011a8:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02011aa:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02011ae:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02011b2:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02011b6:	00010797          	auipc	a5,0x10
ffffffffc02011ba:	3827a783          	lw	a5,898(a5) # ffffffffc0211538 <swap_init_ok>
ffffffffc02011be:	84aa                	mv	s1,a0
ffffffffc02011c0:	e7b9                	bnez	a5,ffffffffc020120e <vmm_init+0x94>
        else mm->sm_priv = NULL;
ffffffffc02011c2:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc02011c6:	03200413          	li	s0,50
ffffffffc02011ca:	a811                	j	ffffffffc02011de <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc02011cc:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02011ce:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02011d0:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc02011d4:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02011d6:	8526                	mv	a0,s1
ffffffffc02011d8:	e9dff0ef          	jal	ra,ffffffffc0201074 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02011dc:	cc05                	beqz	s0,ffffffffc0201214 <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02011de:	03000513          	li	a0,48
ffffffffc02011e2:	317020ef          	jal	ra,ffffffffc0203cf8 <kmalloc>
ffffffffc02011e6:	85aa                	mv	a1,a0
ffffffffc02011e8:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02011ec:	f165                	bnez	a0,ffffffffc02011cc <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc02011ee:	00004697          	auipc	a3,0x4
ffffffffc02011f2:	19a68693          	addi	a3,a3,410 # ffffffffc0205388 <commands+0xbc0>
ffffffffc02011f6:	00004617          	auipc	a2,0x4
ffffffffc02011fa:	cea60613          	addi	a2,a2,-790 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02011fe:	0d100593          	li	a1,209
ffffffffc0201202:	00004517          	auipc	a0,0x4
ffffffffc0201206:	ee650513          	addi	a0,a0,-282 # ffffffffc02050e8 <commands+0x920>
ffffffffc020120a:	ef9fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020120e:	47d000ef          	jal	ra,ffffffffc0201e8a <swap_init_mm>
ffffffffc0201212:	bf55                	j	ffffffffc02011c6 <vmm_init+0x4c>
ffffffffc0201214:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201218:	1f900913          	li	s2,505
ffffffffc020121c:	a819                	j	ffffffffc0201232 <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc020121e:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201220:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201222:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201226:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201228:	8526                	mv	a0,s1
ffffffffc020122a:	e4bff0ef          	jal	ra,ffffffffc0201074 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020122e:	03240a63          	beq	s0,s2,ffffffffc0201262 <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201232:	03000513          	li	a0,48
ffffffffc0201236:	2c3020ef          	jal	ra,ffffffffc0203cf8 <kmalloc>
ffffffffc020123a:	85aa                	mv	a1,a0
ffffffffc020123c:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0201240:	fd79                	bnez	a0,ffffffffc020121e <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc0201242:	00004697          	auipc	a3,0x4
ffffffffc0201246:	14668693          	addi	a3,a3,326 # ffffffffc0205388 <commands+0xbc0>
ffffffffc020124a:	00004617          	auipc	a2,0x4
ffffffffc020124e:	c9660613          	addi	a2,a2,-874 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201252:	0d700593          	li	a1,215
ffffffffc0201256:	00004517          	auipc	a0,0x4
ffffffffc020125a:	e9250513          	addi	a0,a0,-366 # ffffffffc02050e8 <commands+0x920>
ffffffffc020125e:	ea5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    return listelm->next;
ffffffffc0201262:	649c                	ld	a5,8(s1)
ffffffffc0201264:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0201266:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc020126a:	2ef48463          	beq	s1,a5,ffffffffc0201552 <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020126e:	fe87b603          	ld	a2,-24(a5)
ffffffffc0201272:	ffe70693          	addi	a3,a4,-2
ffffffffc0201276:	26d61e63          	bne	a2,a3,ffffffffc02014f2 <vmm_init+0x378>
ffffffffc020127a:	ff07b683          	ld	a3,-16(a5)
ffffffffc020127e:	26e69a63          	bne	a3,a4,ffffffffc02014f2 <vmm_init+0x378>
    for (i = 1; i <= step2; i ++) {
ffffffffc0201282:	0715                	addi	a4,a4,5
ffffffffc0201284:	679c                	ld	a5,8(a5)
ffffffffc0201286:	feb712e3          	bne	a4,a1,ffffffffc020126a <vmm_init+0xf0>
ffffffffc020128a:	4b1d                	li	s6,7
ffffffffc020128c:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020128e:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0201292:	85a2                	mv	a1,s0
ffffffffc0201294:	8526                	mv	a0,s1
ffffffffc0201296:	d9fff0ef          	jal	ra,ffffffffc0201034 <find_vma>
ffffffffc020129a:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc020129c:	2c050b63          	beqz	a0,ffffffffc0201572 <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02012a0:	00140593          	addi	a1,s0,1
ffffffffc02012a4:	8526                	mv	a0,s1
ffffffffc02012a6:	d8fff0ef          	jal	ra,ffffffffc0201034 <find_vma>
ffffffffc02012aa:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc02012ac:	2e050363          	beqz	a0,ffffffffc0201592 <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02012b0:	85da                	mv	a1,s6
ffffffffc02012b2:	8526                	mv	a0,s1
ffffffffc02012b4:	d81ff0ef          	jal	ra,ffffffffc0201034 <find_vma>
        assert(vma3 == NULL);
ffffffffc02012b8:	2e051d63          	bnez	a0,ffffffffc02015b2 <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02012bc:	00340593          	addi	a1,s0,3
ffffffffc02012c0:	8526                	mv	a0,s1
ffffffffc02012c2:	d73ff0ef          	jal	ra,ffffffffc0201034 <find_vma>
        assert(vma4 == NULL);
ffffffffc02012c6:	30051663          	bnez	a0,ffffffffc02015d2 <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02012ca:	00440593          	addi	a1,s0,4
ffffffffc02012ce:	8526                	mv	a0,s1
ffffffffc02012d0:	d65ff0ef          	jal	ra,ffffffffc0201034 <find_vma>
        assert(vma5 == NULL);
ffffffffc02012d4:	30051f63          	bnez	a0,ffffffffc02015f2 <vmm_init+0x478>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02012d8:	00893783          	ld	a5,8(s2)
ffffffffc02012dc:	24879b63          	bne	a5,s0,ffffffffc0201532 <vmm_init+0x3b8>
ffffffffc02012e0:	01093783          	ld	a5,16(s2)
ffffffffc02012e4:	25679763          	bne	a5,s6,ffffffffc0201532 <vmm_init+0x3b8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02012e8:	008ab783          	ld	a5,8(s5)
ffffffffc02012ec:	22879363          	bne	a5,s0,ffffffffc0201512 <vmm_init+0x398>
ffffffffc02012f0:	010ab783          	ld	a5,16(s5)
ffffffffc02012f4:	21679f63          	bne	a5,s6,ffffffffc0201512 <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02012f8:	0415                	addi	s0,s0,5
ffffffffc02012fa:	0b15                	addi	s6,s6,5
ffffffffc02012fc:	f9741be3          	bne	s0,s7,ffffffffc0201292 <vmm_init+0x118>
ffffffffc0201300:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0201302:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0201304:	85a2                	mv	a1,s0
ffffffffc0201306:	8526                	mv	a0,s1
ffffffffc0201308:	d2dff0ef          	jal	ra,ffffffffc0201034 <find_vma>
ffffffffc020130c:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0201310:	c90d                	beqz	a0,ffffffffc0201342 <vmm_init+0x1c8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0201312:	6914                	ld	a3,16(a0)
ffffffffc0201314:	6510                	ld	a2,8(a0)
ffffffffc0201316:	00004517          	auipc	a0,0x4
ffffffffc020131a:	f4250513          	addi	a0,a0,-190 # ffffffffc0205258 <commands+0xa90>
ffffffffc020131e:	d9dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0201322:	00004697          	auipc	a3,0x4
ffffffffc0201326:	f5e68693          	addi	a3,a3,-162 # ffffffffc0205280 <commands+0xab8>
ffffffffc020132a:	00004617          	auipc	a2,0x4
ffffffffc020132e:	bb660613          	addi	a2,a2,-1098 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201332:	0f900593          	li	a1,249
ffffffffc0201336:	00004517          	auipc	a0,0x4
ffffffffc020133a:	db250513          	addi	a0,a0,-590 # ffffffffc02050e8 <commands+0x920>
ffffffffc020133e:	dc5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0201342:	147d                	addi	s0,s0,-1
ffffffffc0201344:	fd2410e3          	bne	s0,s2,ffffffffc0201304 <vmm_init+0x18a>
ffffffffc0201348:	a811                	j	ffffffffc020135c <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc020134a:	6118                	ld	a4,0(a0)
ffffffffc020134c:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc020134e:	03000593          	li	a1,48
ffffffffc0201352:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0201354:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201356:	e398                	sd	a4,0(a5)
ffffffffc0201358:	25b020ef          	jal	ra,ffffffffc0203db2 <kfree>
    return listelm->next;
ffffffffc020135c:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc020135e:	fea496e3          	bne	s1,a0,ffffffffc020134a <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201362:	03000593          	li	a1,48
ffffffffc0201366:	8526                	mv	a0,s1
ffffffffc0201368:	24b020ef          	jal	ra,ffffffffc0203db2 <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020136c:	0a7010ef          	jal	ra,ffffffffc0202c12 <nr_free_pages>
ffffffffc0201370:	3caa1163          	bne	s4,a0,ffffffffc0201732 <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0201374:	00004517          	auipc	a0,0x4
ffffffffc0201378:	f4c50513          	addi	a0,a0,-180 # ffffffffc02052c0 <commands+0xaf8>
ffffffffc020137c:	d3ffe0ef          	jal	ra,ffffffffc02000ba <cprintf>

// check_pgfault - 检查pgfault处理程序的正确性(check correctness of pgfault handler)
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201380:	093010ef          	jal	ra,ffffffffc0202c12 <nr_free_pages>
ffffffffc0201384:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201386:	03000513          	li	a0,48
ffffffffc020138a:	16f020ef          	jal	ra,ffffffffc0203cf8 <kmalloc>
ffffffffc020138e:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0201390:	2a050163          	beqz	a0,ffffffffc0201632 <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201394:	00010797          	auipc	a5,0x10
ffffffffc0201398:	1a47a783          	lw	a5,420(a5) # ffffffffc0211538 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc020139c:	e508                	sd	a0,8(a0)
ffffffffc020139e:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02013a0:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02013a4:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02013a8:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02013ac:	14079063          	bnez	a5,ffffffffc02014ec <vmm_init+0x372>
        else mm->sm_priv = NULL;
ffffffffc02013b0:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013b4:	00010917          	auipc	s2,0x10
ffffffffc02013b8:	19493903          	ld	s2,404(s2) # ffffffffc0211548 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc02013bc:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc02013c0:	00010717          	auipc	a4,0x10
ffffffffc02013c4:	14873c23          	sd	s0,344(a4) # ffffffffc0211518 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013c8:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc02013cc:	24079363          	bnez	a5,ffffffffc0201612 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02013d0:	03000513          	li	a0,48
ffffffffc02013d4:	125020ef          	jal	ra,ffffffffc0203cf8 <kmalloc>
ffffffffc02013d8:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc02013da:	28050063          	beqz	a0,ffffffffc020165a <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc02013de:	002007b7          	lui	a5,0x200
ffffffffc02013e2:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc02013e6:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02013e8:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02013ea:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc02013ee:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02013f0:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc02013f4:	c81ff0ef          	jal	ra,ffffffffc0201074 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02013f8:	10000593          	li	a1,256
ffffffffc02013fc:	8522                	mv	a0,s0
ffffffffc02013fe:	c37ff0ef          	jal	ra,ffffffffc0201034 <find_vma>
ffffffffc0201402:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0201406:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020140a:	26aa1863          	bne	s4,a0,ffffffffc020167a <vmm_init+0x500>
        *(char *)(addr + i) = i;
ffffffffc020140e:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0201412:	0785                	addi	a5,a5,1
ffffffffc0201414:	fee79de3          	bne	a5,a4,ffffffffc020140e <vmm_init+0x294>
        sum += i;
ffffffffc0201418:	6705                	lui	a4,0x1
ffffffffc020141a:	10000793          	li	a5,256
ffffffffc020141e:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0201422:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0201426:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc020142a:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc020142c:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc020142e:	fec79ce3          	bne	a5,a2,ffffffffc0201426 <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc0201432:	26071463          	bnez	a4,ffffffffc020169a <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0201436:	4581                	li	a1,0
ffffffffc0201438:	854a                	mv	a0,s2
ffffffffc020143a:	263010ef          	jal	ra,ffffffffc0202e9c <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020143e:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201442:	00010717          	auipc	a4,0x10
ffffffffc0201446:	10e73703          	ld	a4,270(a4) # ffffffffc0211550 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc020144a:	078a                	slli	a5,a5,0x2
ffffffffc020144c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020144e:	26e7f663          	bgeu	a5,a4,ffffffffc02016ba <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc0201452:	00005717          	auipc	a4,0x5
ffffffffc0201456:	fee73703          	ld	a4,-18(a4) # ffffffffc0206440 <nbase>
ffffffffc020145a:	8f99                	sub	a5,a5,a4
ffffffffc020145c:	00379713          	slli	a4,a5,0x3
ffffffffc0201460:	97ba                	add	a5,a5,a4
ffffffffc0201462:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0201464:	00010517          	auipc	a0,0x10
ffffffffc0201468:	0f453503          	ld	a0,244(a0) # ffffffffc0211558 <pages>
ffffffffc020146c:	953e                	add	a0,a0,a5
ffffffffc020146e:	4585                	li	a1,1
ffffffffc0201470:	762010ef          	jal	ra,ffffffffc0202bd2 <free_pages>
    return listelm->next;
ffffffffc0201474:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc0201476:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc020147a:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020147e:	00a40e63          	beq	s0,a0,ffffffffc020149a <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201482:	6118                	ld	a4,0(a0)
ffffffffc0201484:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0201486:	03000593          	li	a1,48
ffffffffc020148a:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020148c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020148e:	e398                	sd	a4,0(a5)
ffffffffc0201490:	123020ef          	jal	ra,ffffffffc0203db2 <kfree>
    return listelm->next;
ffffffffc0201494:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201496:	fea416e3          	bne	s0,a0,ffffffffc0201482 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020149a:	03000593          	li	a1,48
ffffffffc020149e:	8522                	mv	a0,s0
ffffffffc02014a0:	113020ef          	jal	ra,ffffffffc0203db2 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc02014a4:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc02014a6:	00010797          	auipc	a5,0x10
ffffffffc02014aa:	0607b923          	sd	zero,114(a5) # ffffffffc0211518 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02014ae:	764010ef          	jal	ra,ffffffffc0202c12 <nr_free_pages>
ffffffffc02014b2:	22a49063          	bne	s1,a0,ffffffffc02016d2 <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02014b6:	00004517          	auipc	a0,0x4
ffffffffc02014ba:	e9a50513          	addi	a0,a0,-358 # ffffffffc0205350 <commands+0xb88>
ffffffffc02014be:	bfdfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02014c2:	750010ef          	jal	ra,ffffffffc0202c12 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc02014c6:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02014c8:	22a99563          	bne	s3,a0,ffffffffc02016f2 <vmm_init+0x578>
}
ffffffffc02014cc:	6406                	ld	s0,64(sp)
ffffffffc02014ce:	60a6                	ld	ra,72(sp)
ffffffffc02014d0:	74e2                	ld	s1,56(sp)
ffffffffc02014d2:	7942                	ld	s2,48(sp)
ffffffffc02014d4:	79a2                	ld	s3,40(sp)
ffffffffc02014d6:	7a02                	ld	s4,32(sp)
ffffffffc02014d8:	6ae2                	ld	s5,24(sp)
ffffffffc02014da:	6b42                	ld	s6,16(sp)
ffffffffc02014dc:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02014de:	00004517          	auipc	a0,0x4
ffffffffc02014e2:	e9250513          	addi	a0,a0,-366 # ffffffffc0205370 <commands+0xba8>
}
ffffffffc02014e6:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc02014e8:	bd3fe06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02014ec:	19f000ef          	jal	ra,ffffffffc0201e8a <swap_init_mm>
ffffffffc02014f0:	b5d1                	j	ffffffffc02013b4 <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02014f2:	00004697          	auipc	a3,0x4
ffffffffc02014f6:	c7e68693          	addi	a3,a3,-898 # ffffffffc0205170 <commands+0x9a8>
ffffffffc02014fa:	00004617          	auipc	a2,0x4
ffffffffc02014fe:	9e660613          	addi	a2,a2,-1562 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201502:	0e000593          	li	a1,224
ffffffffc0201506:	00004517          	auipc	a0,0x4
ffffffffc020150a:	be250513          	addi	a0,a0,-1054 # ffffffffc02050e8 <commands+0x920>
ffffffffc020150e:	bf5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201512:	00004697          	auipc	a3,0x4
ffffffffc0201516:	d1668693          	addi	a3,a3,-746 # ffffffffc0205228 <commands+0xa60>
ffffffffc020151a:	00004617          	auipc	a2,0x4
ffffffffc020151e:	9c660613          	addi	a2,a2,-1594 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201522:	0f100593          	li	a1,241
ffffffffc0201526:	00004517          	auipc	a0,0x4
ffffffffc020152a:	bc250513          	addi	a0,a0,-1086 # ffffffffc02050e8 <commands+0x920>
ffffffffc020152e:	bd5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201532:	00004697          	auipc	a3,0x4
ffffffffc0201536:	cc668693          	addi	a3,a3,-826 # ffffffffc02051f8 <commands+0xa30>
ffffffffc020153a:	00004617          	auipc	a2,0x4
ffffffffc020153e:	9a660613          	addi	a2,a2,-1626 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201542:	0f000593          	li	a1,240
ffffffffc0201546:	00004517          	auipc	a0,0x4
ffffffffc020154a:	ba250513          	addi	a0,a0,-1118 # ffffffffc02050e8 <commands+0x920>
ffffffffc020154e:	bb5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201552:	00004697          	auipc	a3,0x4
ffffffffc0201556:	c0668693          	addi	a3,a3,-1018 # ffffffffc0205158 <commands+0x990>
ffffffffc020155a:	00004617          	auipc	a2,0x4
ffffffffc020155e:	98660613          	addi	a2,a2,-1658 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201562:	0de00593          	li	a1,222
ffffffffc0201566:	00004517          	auipc	a0,0x4
ffffffffc020156a:	b8250513          	addi	a0,a0,-1150 # ffffffffc02050e8 <commands+0x920>
ffffffffc020156e:	b95fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1 != NULL);
ffffffffc0201572:	00004697          	auipc	a3,0x4
ffffffffc0201576:	c3668693          	addi	a3,a3,-970 # ffffffffc02051a8 <commands+0x9e0>
ffffffffc020157a:	00004617          	auipc	a2,0x4
ffffffffc020157e:	96660613          	addi	a2,a2,-1690 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201582:	0e600593          	li	a1,230
ffffffffc0201586:	00004517          	auipc	a0,0x4
ffffffffc020158a:	b6250513          	addi	a0,a0,-1182 # ffffffffc02050e8 <commands+0x920>
ffffffffc020158e:	b75fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2 != NULL);
ffffffffc0201592:	00004697          	auipc	a3,0x4
ffffffffc0201596:	c2668693          	addi	a3,a3,-986 # ffffffffc02051b8 <commands+0x9f0>
ffffffffc020159a:	00004617          	auipc	a2,0x4
ffffffffc020159e:	94660613          	addi	a2,a2,-1722 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02015a2:	0e800593          	li	a1,232
ffffffffc02015a6:	00004517          	auipc	a0,0x4
ffffffffc02015aa:	b4250513          	addi	a0,a0,-1214 # ffffffffc02050e8 <commands+0x920>
ffffffffc02015ae:	b55fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma3 == NULL);
ffffffffc02015b2:	00004697          	auipc	a3,0x4
ffffffffc02015b6:	c1668693          	addi	a3,a3,-1002 # ffffffffc02051c8 <commands+0xa00>
ffffffffc02015ba:	00004617          	auipc	a2,0x4
ffffffffc02015be:	92660613          	addi	a2,a2,-1754 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02015c2:	0ea00593          	li	a1,234
ffffffffc02015c6:	00004517          	auipc	a0,0x4
ffffffffc02015ca:	b2250513          	addi	a0,a0,-1246 # ffffffffc02050e8 <commands+0x920>
ffffffffc02015ce:	b35fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma4 == NULL);
ffffffffc02015d2:	00004697          	auipc	a3,0x4
ffffffffc02015d6:	c0668693          	addi	a3,a3,-1018 # ffffffffc02051d8 <commands+0xa10>
ffffffffc02015da:	00004617          	auipc	a2,0x4
ffffffffc02015de:	90660613          	addi	a2,a2,-1786 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02015e2:	0ec00593          	li	a1,236
ffffffffc02015e6:	00004517          	auipc	a0,0x4
ffffffffc02015ea:	b0250513          	addi	a0,a0,-1278 # ffffffffc02050e8 <commands+0x920>
ffffffffc02015ee:	b15fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma5 == NULL);
ffffffffc02015f2:	00004697          	auipc	a3,0x4
ffffffffc02015f6:	bf668693          	addi	a3,a3,-1034 # ffffffffc02051e8 <commands+0xa20>
ffffffffc02015fa:	00004617          	auipc	a2,0x4
ffffffffc02015fe:	8e660613          	addi	a2,a2,-1818 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201602:	0ee00593          	li	a1,238
ffffffffc0201606:	00004517          	auipc	a0,0x4
ffffffffc020160a:	ae250513          	addi	a0,a0,-1310 # ffffffffc02050e8 <commands+0x920>
ffffffffc020160e:	af5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0201612:	00004697          	auipc	a3,0x4
ffffffffc0201616:	cce68693          	addi	a3,a3,-818 # ffffffffc02052e0 <commands+0xb18>
ffffffffc020161a:	00004617          	auipc	a2,0x4
ffffffffc020161e:	8c660613          	addi	a2,a2,-1850 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201622:	11000593          	li	a1,272
ffffffffc0201626:	00004517          	auipc	a0,0x4
ffffffffc020162a:	ac250513          	addi	a0,a0,-1342 # ffffffffc02050e8 <commands+0x920>
ffffffffc020162e:	ad5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0201632:	00004697          	auipc	a3,0x4
ffffffffc0201636:	d6668693          	addi	a3,a3,-666 # ffffffffc0205398 <commands+0xbd0>
ffffffffc020163a:	00004617          	auipc	a2,0x4
ffffffffc020163e:	8a660613          	addi	a2,a2,-1882 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201642:	10d00593          	li	a1,269
ffffffffc0201646:	00004517          	auipc	a0,0x4
ffffffffc020164a:	aa250513          	addi	a0,a0,-1374 # ffffffffc02050e8 <commands+0x920>
    check_mm_struct = mm_create();
ffffffffc020164e:	00010797          	auipc	a5,0x10
ffffffffc0201652:	ec07b523          	sd	zero,-310(a5) # ffffffffc0211518 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0201656:	aadfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(vma != NULL);
ffffffffc020165a:	00004697          	auipc	a3,0x4
ffffffffc020165e:	d2e68693          	addi	a3,a3,-722 # ffffffffc0205388 <commands+0xbc0>
ffffffffc0201662:	00004617          	auipc	a2,0x4
ffffffffc0201666:	87e60613          	addi	a2,a2,-1922 # ffffffffc0204ee0 <commands+0x718>
ffffffffc020166a:	11400593          	li	a1,276
ffffffffc020166e:	00004517          	auipc	a0,0x4
ffffffffc0201672:	a7a50513          	addi	a0,a0,-1414 # ffffffffc02050e8 <commands+0x920>
ffffffffc0201676:	a8dfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc020167a:	00004697          	auipc	a3,0x4
ffffffffc020167e:	c7668693          	addi	a3,a3,-906 # ffffffffc02052f0 <commands+0xb28>
ffffffffc0201682:	00004617          	auipc	a2,0x4
ffffffffc0201686:	85e60613          	addi	a2,a2,-1954 # ffffffffc0204ee0 <commands+0x718>
ffffffffc020168a:	11900593          	li	a1,281
ffffffffc020168e:	00004517          	auipc	a0,0x4
ffffffffc0201692:	a5a50513          	addi	a0,a0,-1446 # ffffffffc02050e8 <commands+0x920>
ffffffffc0201696:	a6dfe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(sum == 0);
ffffffffc020169a:	00004697          	auipc	a3,0x4
ffffffffc020169e:	c7668693          	addi	a3,a3,-906 # ffffffffc0205310 <commands+0xb48>
ffffffffc02016a2:	00004617          	auipc	a2,0x4
ffffffffc02016a6:	83e60613          	addi	a2,a2,-1986 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02016aa:	12300593          	li	a1,291
ffffffffc02016ae:	00004517          	auipc	a0,0x4
ffffffffc02016b2:	a3a50513          	addi	a0,a0,-1478 # ffffffffc02050e8 <commands+0x920>
ffffffffc02016b6:	a4dfe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02016ba:	00004617          	auipc	a2,0x4
ffffffffc02016be:	c6660613          	addi	a2,a2,-922 # ffffffffc0205320 <commands+0xb58>
ffffffffc02016c2:	06600593          	li	a1,102
ffffffffc02016c6:	00004517          	auipc	a0,0x4
ffffffffc02016ca:	c7a50513          	addi	a0,a0,-902 # ffffffffc0205340 <commands+0xb78>
ffffffffc02016ce:	a35fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02016d2:	00004697          	auipc	a3,0x4
ffffffffc02016d6:	bc668693          	addi	a3,a3,-1082 # ffffffffc0205298 <commands+0xad0>
ffffffffc02016da:	00004617          	auipc	a2,0x4
ffffffffc02016de:	80660613          	addi	a2,a2,-2042 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02016e2:	13100593          	li	a1,305
ffffffffc02016e6:	00004517          	auipc	a0,0x4
ffffffffc02016ea:	a0250513          	addi	a0,a0,-1534 # ffffffffc02050e8 <commands+0x920>
ffffffffc02016ee:	a15fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02016f2:	00004697          	auipc	a3,0x4
ffffffffc02016f6:	ba668693          	addi	a3,a3,-1114 # ffffffffc0205298 <commands+0xad0>
ffffffffc02016fa:	00003617          	auipc	a2,0x3
ffffffffc02016fe:	7e660613          	addi	a2,a2,2022 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201702:	0c000593          	li	a1,192
ffffffffc0201706:	00004517          	auipc	a0,0x4
ffffffffc020170a:	9e250513          	addi	a0,a0,-1566 # ffffffffc02050e8 <commands+0x920>
ffffffffc020170e:	9f5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(mm != NULL);
ffffffffc0201712:	00004697          	auipc	a3,0x4
ffffffffc0201716:	c9e68693          	addi	a3,a3,-866 # ffffffffc02053b0 <commands+0xbe8>
ffffffffc020171a:	00003617          	auipc	a2,0x3
ffffffffc020171e:	7c660613          	addi	a2,a2,1990 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201722:	0ca00593          	li	a1,202
ffffffffc0201726:	00004517          	auipc	a0,0x4
ffffffffc020172a:	9c250513          	addi	a0,a0,-1598 # ffffffffc02050e8 <commands+0x920>
ffffffffc020172e:	9d5fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201732:	00004697          	auipc	a3,0x4
ffffffffc0201736:	b6668693          	addi	a3,a3,-1178 # ffffffffc0205298 <commands+0xad0>
ffffffffc020173a:	00003617          	auipc	a2,0x3
ffffffffc020173e:	7a660613          	addi	a2,a2,1958 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201742:	0fe00593          	li	a1,254
ffffffffc0201746:	00004517          	auipc	a0,0x4
ffffffffc020174a:	9a250513          	addi	a0,a0,-1630 # ffffffffc02050e8 <commands+0x920>
ffffffffc020174e:	9b5fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201752 <do_pgfault>:
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */

int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201752:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0201754:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201756:	f022                	sd	s0,32(sp)
ffffffffc0201758:	ec26                	sd	s1,24(sp)
ffffffffc020175a:	f406                	sd	ra,40(sp)
ffffffffc020175c:	e84a                	sd	s2,16(sp)
ffffffffc020175e:	8432                	mv	s0,a2
ffffffffc0201760:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0201762:	8d3ff0ef          	jal	ra,ffffffffc0201034 <find_vma>

    pgfault_num++;
ffffffffc0201766:	00010797          	auipc	a5,0x10
ffffffffc020176a:	dba7a783          	lw	a5,-582(a5) # ffffffffc0211520 <pgfault_num>
ffffffffc020176e:	2785                	addiw	a5,a5,1
ffffffffc0201770:	00010717          	auipc	a4,0x10
ffffffffc0201774:	daf72823          	sw	a5,-592(a4) # ffffffffc0211520 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201778:	c159                	beqz	a0,ffffffffc02017fe <do_pgfault+0xac>
ffffffffc020177a:	651c                	ld	a5,8(a0)
ffffffffc020177c:	08f46163          	bltu	s0,a5,ffffffffc02017fe <do_pgfault+0xac>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201780:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0201782:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201784:	8b89                	andi	a5,a5,2
ffffffffc0201786:	ebb1                	bnez	a5,ffffffffc02017da <do_pgfault+0x88>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201788:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc020178a:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc020178c:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc020178e:	85a2                	mv	a1,s0
ffffffffc0201790:	4605                	li	a2,1
ffffffffc0201792:	4ba010ef          	jal	ra,ffffffffc0202c4c <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0201796:	610c                	ld	a1,0(a0)
ffffffffc0201798:	c1b9                	beqz	a1,ffffffffc02017de <do_pgfault+0x8c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) 
ffffffffc020179a:	00010797          	auipc	a5,0x10
ffffffffc020179e:	d9e7a783          	lw	a5,-610(a5) # ffffffffc0211538 <swap_init_ok>
ffffffffc02017a2:	c7bd                	beqz	a5,ffffffffc0201810 <do_pgfault+0xbe>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）根据mm和addr，尝试将右侧磁盘页面的内容放入页面管理的内存中。
            //(2) 根据mm、addr和page，设置物理addr<--->虚拟(logical)addr的映射
            //(3) 使页面可交换。
            swap_in(mm, addr, &page);
ffffffffc02017a4:	85a2                	mv	a1,s0
ffffffffc02017a6:	0030                	addi	a2,sp,8
ffffffffc02017a8:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02017aa:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc02017ac:	00b000ef          	jal	ra,ffffffffc0201fb6 <swap_in>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc02017b0:	65a2                	ld	a1,8(sp)
ffffffffc02017b2:	6c88                	ld	a0,24(s1)
ffffffffc02017b4:	86ca                	mv	a3,s2
ffffffffc02017b6:	8622                	mv	a2,s0
ffffffffc02017b8:	77e010ef          	jal	ra,ffffffffc0202f36 <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc02017bc:	6622                	ld	a2,8(sp)
ffffffffc02017be:	4685                	li	a3,1
ffffffffc02017c0:	85a2                	mv	a1,s0
ffffffffc02017c2:	8526                	mv	a0,s1
ffffffffc02017c4:	6d2000ef          	jal	ra,ffffffffc0201e96 <swap_map_swappable>
            
            page->pra_vaddr = addr;  //必须等待前几条设置好权限才能写这行
ffffffffc02017c8:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc02017ca:	4501                	li	a0,0
            page->pra_vaddr = addr;  //必须等待前几条设置好权限才能写这行
ffffffffc02017cc:	e3a0                	sd	s0,64(a5)
failed:
    return ret;
}
ffffffffc02017ce:	70a2                	ld	ra,40(sp)
ffffffffc02017d0:	7402                	ld	s0,32(sp)
ffffffffc02017d2:	64e2                	ld	s1,24(sp)
ffffffffc02017d4:	6942                	ld	s2,16(sp)
ffffffffc02017d6:	6145                	addi	sp,sp,48
ffffffffc02017d8:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc02017da:	4959                	li	s2,22
ffffffffc02017dc:	b775                	j	ffffffffc0201788 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02017de:	6c88                	ld	a0,24(s1)
ffffffffc02017e0:	864a                	mv	a2,s2
ffffffffc02017e2:	85a2                	mv	a1,s0
ffffffffc02017e4:	45c020ef          	jal	ra,ffffffffc0203c40 <pgdir_alloc_page>
ffffffffc02017e8:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc02017ea:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02017ec:	f3ed                	bnez	a5,ffffffffc02017ce <do_pgfault+0x7c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02017ee:	00004517          	auipc	a0,0x4
ffffffffc02017f2:	c0250513          	addi	a0,a0,-1022 # ffffffffc02053f0 <commands+0xc28>
ffffffffc02017f6:	8c5fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc02017fa:	5571                	li	a0,-4
            goto failed;
ffffffffc02017fc:	bfc9                	j	ffffffffc02017ce <do_pgfault+0x7c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc02017fe:	85a2                	mv	a1,s0
ffffffffc0201800:	00004517          	auipc	a0,0x4
ffffffffc0201804:	bc050513          	addi	a0,a0,-1088 # ffffffffc02053c0 <commands+0xbf8>
ffffffffc0201808:	8b3fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc020180c:	5575                	li	a0,-3
        goto failed;
ffffffffc020180e:	b7c1                	j	ffffffffc02017ce <do_pgfault+0x7c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0201810:	00004517          	auipc	a0,0x4
ffffffffc0201814:	c0850513          	addi	a0,a0,-1016 # ffffffffc0205418 <commands+0xc50>
ffffffffc0201818:	8a3fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc020181c:	5571                	li	a0,-4
            goto failed;
ffffffffc020181e:	bf45                	j	ffffffffc02017ce <do_pgfault+0x7c>

ffffffffc0201820 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0201820:	7135                	addi	sp,sp,-160
ffffffffc0201822:	ed06                	sd	ra,152(sp)
ffffffffc0201824:	e922                	sd	s0,144(sp)
ffffffffc0201826:	e526                	sd	s1,136(sp)
ffffffffc0201828:	e14a                	sd	s2,128(sp)
ffffffffc020182a:	fcce                	sd	s3,120(sp)
ffffffffc020182c:	f8d2                	sd	s4,112(sp)
ffffffffc020182e:	f4d6                	sd	s5,104(sp)
ffffffffc0201830:	f0da                	sd	s6,96(sp)
ffffffffc0201832:	ecde                	sd	s7,88(sp)
ffffffffc0201834:	e8e2                	sd	s8,80(sp)
ffffffffc0201836:	e4e6                	sd	s9,72(sp)
ffffffffc0201838:	e0ea                	sd	s10,64(sp)
ffffffffc020183a:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc020183c:	65e020ef          	jal	ra,ffffffffc0203e9a <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     // 由于IDE是伪造的，它最多只能存储7个页面才能通过测试
     if (!(7 <= max_swap_offset &&
ffffffffc0201840:	00010697          	auipc	a3,0x10
ffffffffc0201844:	ce86b683          	ld	a3,-792(a3) # ffffffffc0211528 <max_swap_offset>
ffffffffc0201848:	010007b7          	lui	a5,0x1000
ffffffffc020184c:	ff968713          	addi	a4,a3,-7
ffffffffc0201850:	17e1                	addi	a5,a5,-8
ffffffffc0201852:	3ee7e063          	bltu	a5,a4,ffffffffc0201c32 <swap_init+0x412>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     //sm = &swap_manager_fifo;
     //sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
     sm = &swap_manager_lru;
ffffffffc0201856:	00008797          	auipc	a5,0x8
ffffffffc020185a:	7aa78793          	addi	a5,a5,1962 # ffffffffc020a000 <swap_manager_lru>
     int r = sm->init();
ffffffffc020185e:	6798                	ld	a4,8(a5)
     sm = &swap_manager_lru;
ffffffffc0201860:	00010b17          	auipc	s6,0x10
ffffffffc0201864:	cd0b0b13          	addi	s6,s6,-816 # ffffffffc0211530 <sm>
ffffffffc0201868:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc020186c:	9702                	jalr	a4
ffffffffc020186e:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc0201870:	c10d                	beqz	a0,ffffffffc0201892 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0201872:	60ea                	ld	ra,152(sp)
ffffffffc0201874:	644a                	ld	s0,144(sp)
ffffffffc0201876:	64aa                	ld	s1,136(sp)
ffffffffc0201878:	690a                	ld	s2,128(sp)
ffffffffc020187a:	7a46                	ld	s4,112(sp)
ffffffffc020187c:	7aa6                	ld	s5,104(sp)
ffffffffc020187e:	7b06                	ld	s6,96(sp)
ffffffffc0201880:	6be6                	ld	s7,88(sp)
ffffffffc0201882:	6c46                	ld	s8,80(sp)
ffffffffc0201884:	6ca6                	ld	s9,72(sp)
ffffffffc0201886:	6d06                	ld	s10,64(sp)
ffffffffc0201888:	7de2                	ld	s11,56(sp)
ffffffffc020188a:	854e                	mv	a0,s3
ffffffffc020188c:	79e6                	ld	s3,120(sp)
ffffffffc020188e:	610d                	addi	sp,sp,160
ffffffffc0201890:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201892:	000b3783          	ld	a5,0(s6)
ffffffffc0201896:	00004517          	auipc	a0,0x4
ffffffffc020189a:	bda50513          	addi	a0,a0,-1062 # ffffffffc0205470 <commands+0xca8>
ffffffffc020189e:	00010497          	auipc	s1,0x10
ffffffffc02018a2:	84248493          	addi	s1,s1,-1982 # ffffffffc02110e0 <free_area>
ffffffffc02018a6:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02018a8:	4785                	li	a5,1
ffffffffc02018aa:	00010717          	auipc	a4,0x10
ffffffffc02018ae:	c8f72723          	sw	a5,-882(a4) # ffffffffc0211538 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02018b2:	809fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02018b6:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02018b8:	4401                	li	s0,0
ffffffffc02018ba:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02018bc:	2c978163          	beq	a5,s1,ffffffffc0201b7e <swap_init+0x35e>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02018c0:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02018c4:	8b09                	andi	a4,a4,2
ffffffffc02018c6:	2a070e63          	beqz	a4,ffffffffc0201b82 <swap_init+0x362>
        count ++, total += p->property;
ffffffffc02018ca:	ff87a703          	lw	a4,-8(a5)
ffffffffc02018ce:	679c                	ld	a5,8(a5)
ffffffffc02018d0:	2d05                	addiw	s10,s10,1
ffffffffc02018d2:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02018d4:	fe9796e3          	bne	a5,s1,ffffffffc02018c0 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc02018d8:	8922                	mv	s2,s0
ffffffffc02018da:	338010ef          	jal	ra,ffffffffc0202c12 <nr_free_pages>
ffffffffc02018de:	47251663          	bne	a0,s2,ffffffffc0201d4a <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02018e2:	8622                	mv	a2,s0
ffffffffc02018e4:	85ea                	mv	a1,s10
ffffffffc02018e6:	00004517          	auipc	a0,0x4
ffffffffc02018ea:	bd250513          	addi	a0,a0,-1070 # ffffffffc02054b8 <commands+0xcf0>
ffffffffc02018ee:	fccfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02018f2:	eccff0ef          	jal	ra,ffffffffc0200fbe <mm_create>
ffffffffc02018f6:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc02018f8:	52050963          	beqz	a0,ffffffffc0201e2a <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02018fc:	00010797          	auipc	a5,0x10
ffffffffc0201900:	c1c78793          	addi	a5,a5,-996 # ffffffffc0211518 <check_mm_struct>
ffffffffc0201904:	6398                	ld	a4,0(a5)
ffffffffc0201906:	54071263          	bnez	a4,ffffffffc0201e4a <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020190a:	00010b97          	auipc	s7,0x10
ffffffffc020190e:	c3ebbb83          	ld	s7,-962(s7) # ffffffffc0211548 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc0201912:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc0201916:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201918:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc020191c:	3c071763          	bnez	a4,ffffffffc0201cea <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0201920:	6599                	lui	a1,0x6
ffffffffc0201922:	460d                	li	a2,3
ffffffffc0201924:	6505                	lui	a0,0x1
ffffffffc0201926:	ee0ff0ef          	jal	ra,ffffffffc0201006 <vma_create>
ffffffffc020192a:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc020192c:	3c050f63          	beqz	a0,ffffffffc0201d0a <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc0201930:	8556                	mv	a0,s5
ffffffffc0201932:	f42ff0ef          	jal	ra,ffffffffc0201074 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0201936:	00004517          	auipc	a0,0x4
ffffffffc020193a:	bc250513          	addi	a0,a0,-1086 # ffffffffc02054f8 <commands+0xd30>
ffffffffc020193e:	f7cfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0201942:	018ab503          	ld	a0,24(s5)
ffffffffc0201946:	4605                	li	a2,1
ffffffffc0201948:	6585                	lui	a1,0x1
ffffffffc020194a:	302010ef          	jal	ra,ffffffffc0202c4c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc020194e:	3c050e63          	beqz	a0,ffffffffc0201d2a <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201952:	00004517          	auipc	a0,0x4
ffffffffc0201956:	bf650513          	addi	a0,a0,-1034 # ffffffffc0205548 <commands+0xd80>
ffffffffc020195a:	0000f917          	auipc	s2,0xf
ffffffffc020195e:	71690913          	addi	s2,s2,1814 # ffffffffc0211070 <check_rp>
ffffffffc0201962:	f58fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201966:	0000fa17          	auipc	s4,0xf
ffffffffc020196a:	72aa0a13          	addi	s4,s4,1834 # ffffffffc0211090 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc020196e:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc0201970:	4505                	li	a0,1
ffffffffc0201972:	1ce010ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc0201976:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc020197a:	28050c63          	beqz	a0,ffffffffc0201c12 <swap_init+0x3f2>
ffffffffc020197e:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0201980:	8b89                	andi	a5,a5,2
ffffffffc0201982:	26079863          	bnez	a5,ffffffffc0201bf2 <swap_init+0x3d2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201986:	0c21                	addi	s8,s8,8
ffffffffc0201988:	ff4c14e3          	bne	s8,s4,ffffffffc0201970 <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc020198c:	609c                	ld	a5,0(s1)
ffffffffc020198e:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc0201992:	e084                	sd	s1,0(s1)
ffffffffc0201994:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc0201996:	489c                	lw	a5,16(s1)
ffffffffc0201998:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc020199a:	0000fc17          	auipc	s8,0xf
ffffffffc020199e:	6d6c0c13          	addi	s8,s8,1750 # ffffffffc0211070 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc02019a2:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc02019a4:	0000f797          	auipc	a5,0xf
ffffffffc02019a8:	7407a623          	sw	zero,1868(a5) # ffffffffc02110f0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02019ac:	000c3503          	ld	a0,0(s8)
ffffffffc02019b0:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02019b2:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc02019b4:	21e010ef          	jal	ra,ffffffffc0202bd2 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02019b8:	ff4c1ae3          	bne	s8,s4,ffffffffc02019ac <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02019bc:	0104ac03          	lw	s8,16(s1)
ffffffffc02019c0:	4791                	li	a5,4
ffffffffc02019c2:	4afc1463          	bne	s8,a5,ffffffffc0201e6a <swap_init+0x64a>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02019c6:	00004517          	auipc	a0,0x4
ffffffffc02019ca:	c0a50513          	addi	a0,a0,-1014 # ffffffffc02055d0 <commands+0xe08>
ffffffffc02019ce:	eecfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02019d2:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02019d4:	00010797          	auipc	a5,0x10
ffffffffc02019d8:	b407a623          	sw	zero,-1204(a5) # ffffffffc0211520 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02019dc:	4529                	li	a0,10
ffffffffc02019de:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc02019e2:	00010597          	auipc	a1,0x10
ffffffffc02019e6:	b3e5a583          	lw	a1,-1218(a1) # ffffffffc0211520 <pgfault_num>
ffffffffc02019ea:	4805                	li	a6,1
ffffffffc02019ec:	00010797          	auipc	a5,0x10
ffffffffc02019f0:	b3478793          	addi	a5,a5,-1228 # ffffffffc0211520 <pgfault_num>
ffffffffc02019f4:	3f059b63          	bne	a1,a6,ffffffffc0201dea <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02019f8:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num==1);
ffffffffc02019fc:	4390                	lw	a2,0(a5)
ffffffffc02019fe:	2601                	sext.w	a2,a2
ffffffffc0201a00:	40b61563          	bne	a2,a1,ffffffffc0201e0a <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201a04:	6589                	lui	a1,0x2
ffffffffc0201a06:	452d                	li	a0,11
ffffffffc0201a08:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0201a0c:	4390                	lw	a2,0(a5)
ffffffffc0201a0e:	4809                	li	a6,2
ffffffffc0201a10:	2601                	sext.w	a2,a2
ffffffffc0201a12:	35061c63          	bne	a2,a6,ffffffffc0201d6a <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0201a16:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==2);
ffffffffc0201a1a:	438c                	lw	a1,0(a5)
ffffffffc0201a1c:	2581                	sext.w	a1,a1
ffffffffc0201a1e:	36c59663          	bne	a1,a2,ffffffffc0201d8a <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201a22:	658d                	lui	a1,0x3
ffffffffc0201a24:	4531                	li	a0,12
ffffffffc0201a26:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0201a2a:	4390                	lw	a2,0(a5)
ffffffffc0201a2c:	480d                	li	a6,3
ffffffffc0201a2e:	2601                	sext.w	a2,a2
ffffffffc0201a30:	37061d63          	bne	a2,a6,ffffffffc0201daa <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0201a34:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==3);
ffffffffc0201a38:	438c                	lw	a1,0(a5)
ffffffffc0201a3a:	2581                	sext.w	a1,a1
ffffffffc0201a3c:	38c59763          	bne	a1,a2,ffffffffc0201dca <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201a40:	6591                	lui	a1,0x4
ffffffffc0201a42:	4535                	li	a0,13
ffffffffc0201a44:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0201a48:	4390                	lw	a2,0(a5)
ffffffffc0201a4a:	2601                	sext.w	a2,a2
ffffffffc0201a4c:	21861f63          	bne	a2,s8,ffffffffc0201c6a <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0201a50:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==4);
ffffffffc0201a54:	439c                	lw	a5,0(a5)
ffffffffc0201a56:	2781                	sext.w	a5,a5
ffffffffc0201a58:	22c79963          	bne	a5,a2,ffffffffc0201c8a <swap_init+0x46a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0201a5c:	489c                	lw	a5,16(s1)
ffffffffc0201a5e:	24079663          	bnez	a5,ffffffffc0201caa <swap_init+0x48a>
ffffffffc0201a62:	0000f797          	auipc	a5,0xf
ffffffffc0201a66:	62e78793          	addi	a5,a5,1582 # ffffffffc0211090 <swap_in_seq_no>
ffffffffc0201a6a:	0000f617          	auipc	a2,0xf
ffffffffc0201a6e:	64e60613          	addi	a2,a2,1614 # ffffffffc02110b8 <swap_out_seq_no>
ffffffffc0201a72:	0000f517          	auipc	a0,0xf
ffffffffc0201a76:	64650513          	addi	a0,a0,1606 # ffffffffc02110b8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0201a7a:	55fd                	li	a1,-1
ffffffffc0201a7c:	c38c                	sw	a1,0(a5)
ffffffffc0201a7e:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201a80:	0791                	addi	a5,a5,4
ffffffffc0201a82:	0611                	addi	a2,a2,4
ffffffffc0201a84:	fef51ce3          	bne	a0,a5,ffffffffc0201a7c <swap_init+0x25c>
ffffffffc0201a88:	0000f817          	auipc	a6,0xf
ffffffffc0201a8c:	5c880813          	addi	a6,a6,1480 # ffffffffc0211050 <check_ptep>
ffffffffc0201a90:	0000f897          	auipc	a7,0xf
ffffffffc0201a94:	5e088893          	addi	a7,a7,1504 # ffffffffc0211070 <check_rp>
ffffffffc0201a98:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc0201a9a:	00010c97          	auipc	s9,0x10
ffffffffc0201a9e:	abec8c93          	addi	s9,s9,-1346 # ffffffffc0211558 <pages>
ffffffffc0201aa2:	00005c17          	auipc	s8,0x5
ffffffffc0201aa6:	99ec0c13          	addi	s8,s8,-1634 # ffffffffc0206440 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0201aaa:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201aae:	4601                	li	a2,0
ffffffffc0201ab0:	855e                	mv	a0,s7
ffffffffc0201ab2:	ec46                	sd	a7,24(sp)
ffffffffc0201ab4:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc0201ab6:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201ab8:	194010ef          	jal	ra,ffffffffc0202c4c <get_pte>
ffffffffc0201abc:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0201abe:	65c2                	ld	a1,16(sp)
ffffffffc0201ac0:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201ac2:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc0201ac6:	00010317          	auipc	t1,0x10
ffffffffc0201aca:	a8a30313          	addi	t1,t1,-1398 # ffffffffc0211550 <npage>
ffffffffc0201ace:	16050e63          	beqz	a0,ffffffffc0201c4a <swap_init+0x42a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201ad2:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201ad4:	0017f613          	andi	a2,a5,1
ffffffffc0201ad8:	0e060563          	beqz	a2,ffffffffc0201bc2 <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc0201adc:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ae0:	078a                	slli	a5,a5,0x2
ffffffffc0201ae2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ae4:	0ec7fb63          	bgeu	a5,a2,ffffffffc0201bda <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ae8:	000c3603          	ld	a2,0(s8)
ffffffffc0201aec:	000cb503          	ld	a0,0(s9)
ffffffffc0201af0:	0008bf03          	ld	t5,0(a7)
ffffffffc0201af4:	8f91                	sub	a5,a5,a2
ffffffffc0201af6:	00379613          	slli	a2,a5,0x3
ffffffffc0201afa:	97b2                	add	a5,a5,a2
ffffffffc0201afc:	078e                	slli	a5,a5,0x3
ffffffffc0201afe:	97aa                	add	a5,a5,a0
ffffffffc0201b00:	0aff1163          	bne	t5,a5,ffffffffc0201ba2 <swap_init+0x382>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201b04:	6785                	lui	a5,0x1
ffffffffc0201b06:	95be                	add	a1,a1,a5
ffffffffc0201b08:	6795                	lui	a5,0x5
ffffffffc0201b0a:	0821                	addi	a6,a6,8
ffffffffc0201b0c:	08a1                	addi	a7,a7,8
ffffffffc0201b0e:	f8f59ee3          	bne	a1,a5,ffffffffc0201aaa <swap_init+0x28a>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0201b12:	00004517          	auipc	a0,0x4
ffffffffc0201b16:	b8e50513          	addi	a0,a0,-1138 # ffffffffc02056a0 <commands+0xed8>
ffffffffc0201b1a:	da0fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc0201b1e:	000b3783          	ld	a5,0(s6)
ffffffffc0201b22:	7f9c                	ld	a5,56(a5)
ffffffffc0201b24:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0201b26:	1a051263          	bnez	a0,ffffffffc0201cca <swap_init+0x4aa>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0201b2a:	00093503          	ld	a0,0(s2)
ffffffffc0201b2e:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201b30:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc0201b32:	0a0010ef          	jal	ra,ffffffffc0202bd2 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201b36:	ff491ae3          	bne	s2,s4,ffffffffc0201b2a <swap_init+0x30a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0201b3a:	8556                	mv	a0,s5
ffffffffc0201b3c:	e08ff0ef          	jal	ra,ffffffffc0201144 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0201b40:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0201b42:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc0201b46:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc0201b48:	7782                	ld	a5,32(sp)
ffffffffc0201b4a:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201b4c:	009d8a63          	beq	s11,s1,ffffffffc0201b60 <swap_init+0x340>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201b50:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc0201b54:	008dbd83          	ld	s11,8(s11)
ffffffffc0201b58:	3d7d                	addiw	s10,s10,-1
ffffffffc0201b5a:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201b5c:	fe9d9ae3          	bne	s11,s1,ffffffffc0201b50 <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0201b60:	8622                	mv	a2,s0
ffffffffc0201b62:	85ea                	mv	a1,s10
ffffffffc0201b64:	00004517          	auipc	a0,0x4
ffffffffc0201b68:	b6c50513          	addi	a0,a0,-1172 # ffffffffc02056d0 <commands+0xf08>
ffffffffc0201b6c:	d4efe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0201b70:	00004517          	auipc	a0,0x4
ffffffffc0201b74:	b8050513          	addi	a0,a0,-1152 # ffffffffc02056f0 <commands+0xf28>
ffffffffc0201b78:	d42fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0201b7c:	b9dd                	j	ffffffffc0201872 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201b7e:	4901                	li	s2,0
ffffffffc0201b80:	bba9                	j	ffffffffc02018da <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc0201b82:	00004697          	auipc	a3,0x4
ffffffffc0201b86:	90668693          	addi	a3,a3,-1786 # ffffffffc0205488 <commands+0xcc0>
ffffffffc0201b8a:	00003617          	auipc	a2,0x3
ffffffffc0201b8e:	35660613          	addi	a2,a2,854 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201b92:	0bd00593          	li	a1,189
ffffffffc0201b96:	00004517          	auipc	a0,0x4
ffffffffc0201b9a:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201b9e:	d64fe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201ba2:	00004697          	auipc	a3,0x4
ffffffffc0201ba6:	ad668693          	addi	a3,a3,-1322 # ffffffffc0205678 <commands+0xeb0>
ffffffffc0201baa:	00003617          	auipc	a2,0x3
ffffffffc0201bae:	33660613          	addi	a2,a2,822 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201bb2:	0fd00593          	li	a1,253
ffffffffc0201bb6:	00004517          	auipc	a0,0x4
ffffffffc0201bba:	8aa50513          	addi	a0,a0,-1878 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201bbe:	d44fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201bc2:	00004617          	auipc	a2,0x4
ffffffffc0201bc6:	a8e60613          	addi	a2,a2,-1394 # ffffffffc0205650 <commands+0xe88>
ffffffffc0201bca:	07100593          	li	a1,113
ffffffffc0201bce:	00003517          	auipc	a0,0x3
ffffffffc0201bd2:	77250513          	addi	a0,a0,1906 # ffffffffc0205340 <commands+0xb78>
ffffffffc0201bd6:	d2cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201bda:	00003617          	auipc	a2,0x3
ffffffffc0201bde:	74660613          	addi	a2,a2,1862 # ffffffffc0205320 <commands+0xb58>
ffffffffc0201be2:	06600593          	li	a1,102
ffffffffc0201be6:	00003517          	auipc	a0,0x3
ffffffffc0201bea:	75a50513          	addi	a0,a0,1882 # ffffffffc0205340 <commands+0xb78>
ffffffffc0201bee:	d14fe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0201bf2:	00004697          	auipc	a3,0x4
ffffffffc0201bf6:	99668693          	addi	a3,a3,-1642 # ffffffffc0205588 <commands+0xdc0>
ffffffffc0201bfa:	00003617          	auipc	a2,0x3
ffffffffc0201bfe:	2e660613          	addi	a2,a2,742 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201c02:	0de00593          	li	a1,222
ffffffffc0201c06:	00004517          	auipc	a0,0x4
ffffffffc0201c0a:	85a50513          	addi	a0,a0,-1958 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201c0e:	cf4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0201c12:	00004697          	auipc	a3,0x4
ffffffffc0201c16:	95e68693          	addi	a3,a3,-1698 # ffffffffc0205570 <commands+0xda8>
ffffffffc0201c1a:	00003617          	auipc	a2,0x3
ffffffffc0201c1e:	2c660613          	addi	a2,a2,710 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201c22:	0dd00593          	li	a1,221
ffffffffc0201c26:	00004517          	auipc	a0,0x4
ffffffffc0201c2a:	83a50513          	addi	a0,a0,-1990 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201c2e:	cd4fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0201c32:	00004617          	auipc	a2,0x4
ffffffffc0201c36:	80e60613          	addi	a2,a2,-2034 # ffffffffc0205440 <commands+0xc78>
ffffffffc0201c3a:	02900593          	li	a1,41
ffffffffc0201c3e:	00004517          	auipc	a0,0x4
ffffffffc0201c42:	82250513          	addi	a0,a0,-2014 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201c46:	cbcfe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0201c4a:	00004697          	auipc	a3,0x4
ffffffffc0201c4e:	9ee68693          	addi	a3,a3,-1554 # ffffffffc0205638 <commands+0xe70>
ffffffffc0201c52:	00003617          	auipc	a2,0x3
ffffffffc0201c56:	28e60613          	addi	a2,a2,654 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201c5a:	0fc00593          	li	a1,252
ffffffffc0201c5e:	00004517          	auipc	a0,0x4
ffffffffc0201c62:	80250513          	addi	a0,a0,-2046 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201c66:	c9cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc0201c6a:	00003697          	auipc	a3,0x3
ffffffffc0201c6e:	3e668693          	addi	a3,a3,998 # ffffffffc0205050 <commands+0x888>
ffffffffc0201c72:	00003617          	auipc	a2,0x3
ffffffffc0201c76:	26e60613          	addi	a2,a2,622 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201c7a:	0a000593          	li	a1,160
ffffffffc0201c7e:	00003517          	auipc	a0,0x3
ffffffffc0201c82:	7e250513          	addi	a0,a0,2018 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201c86:	c7cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc0201c8a:	00003697          	auipc	a3,0x3
ffffffffc0201c8e:	3c668693          	addi	a3,a3,966 # ffffffffc0205050 <commands+0x888>
ffffffffc0201c92:	00003617          	auipc	a2,0x3
ffffffffc0201c96:	24e60613          	addi	a2,a2,590 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201c9a:	0a200593          	li	a1,162
ffffffffc0201c9e:	00003517          	auipc	a0,0x3
ffffffffc0201ca2:	7c250513          	addi	a0,a0,1986 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201ca6:	c5cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert( nr_free == 0);         
ffffffffc0201caa:	00004697          	auipc	a3,0x4
ffffffffc0201cae:	97e68693          	addi	a3,a3,-1666 # ffffffffc0205628 <commands+0xe60>
ffffffffc0201cb2:	00003617          	auipc	a2,0x3
ffffffffc0201cb6:	22e60613          	addi	a2,a2,558 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201cba:	0f400593          	li	a1,244
ffffffffc0201cbe:	00003517          	auipc	a0,0x3
ffffffffc0201cc2:	7a250513          	addi	a0,a0,1954 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201cc6:	c3cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(ret==0);
ffffffffc0201cca:	00004697          	auipc	a3,0x4
ffffffffc0201cce:	9fe68693          	addi	a3,a3,-1538 # ffffffffc02056c8 <commands+0xf00>
ffffffffc0201cd2:	00003617          	auipc	a2,0x3
ffffffffc0201cd6:	20e60613          	addi	a2,a2,526 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201cda:	10300593          	li	a1,259
ffffffffc0201cde:	00003517          	auipc	a0,0x3
ffffffffc0201ce2:	78250513          	addi	a0,a0,1922 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201ce6:	c1cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0201cea:	00003697          	auipc	a3,0x3
ffffffffc0201cee:	5f668693          	addi	a3,a3,1526 # ffffffffc02052e0 <commands+0xb18>
ffffffffc0201cf2:	00003617          	auipc	a2,0x3
ffffffffc0201cf6:	1ee60613          	addi	a2,a2,494 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201cfa:	0cd00593          	li	a1,205
ffffffffc0201cfe:	00003517          	auipc	a0,0x3
ffffffffc0201d02:	76250513          	addi	a0,a0,1890 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201d06:	bfcfe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(vma != NULL);
ffffffffc0201d0a:	00003697          	auipc	a3,0x3
ffffffffc0201d0e:	67e68693          	addi	a3,a3,1662 # ffffffffc0205388 <commands+0xbc0>
ffffffffc0201d12:	00003617          	auipc	a2,0x3
ffffffffc0201d16:	1ce60613          	addi	a2,a2,462 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201d1a:	0d000593          	li	a1,208
ffffffffc0201d1e:	00003517          	auipc	a0,0x3
ffffffffc0201d22:	74250513          	addi	a0,a0,1858 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201d26:	bdcfe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0201d2a:	00004697          	auipc	a3,0x4
ffffffffc0201d2e:	80668693          	addi	a3,a3,-2042 # ffffffffc0205530 <commands+0xd68>
ffffffffc0201d32:	00003617          	auipc	a2,0x3
ffffffffc0201d36:	1ae60613          	addi	a2,a2,430 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201d3a:	0d800593          	li	a1,216
ffffffffc0201d3e:	00003517          	auipc	a0,0x3
ffffffffc0201d42:	72250513          	addi	a0,a0,1826 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201d46:	bbcfe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(total == nr_free_pages());
ffffffffc0201d4a:	00003697          	auipc	a3,0x3
ffffffffc0201d4e:	74e68693          	addi	a3,a3,1870 # ffffffffc0205498 <commands+0xcd0>
ffffffffc0201d52:	00003617          	auipc	a2,0x3
ffffffffc0201d56:	18e60613          	addi	a2,a2,398 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201d5a:	0c000593          	li	a1,192
ffffffffc0201d5e:	00003517          	auipc	a0,0x3
ffffffffc0201d62:	70250513          	addi	a0,a0,1794 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201d66:	b9cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc0201d6a:	00004697          	auipc	a3,0x4
ffffffffc0201d6e:	89e68693          	addi	a3,a3,-1890 # ffffffffc0205608 <commands+0xe40>
ffffffffc0201d72:	00003617          	auipc	a2,0x3
ffffffffc0201d76:	16e60613          	addi	a2,a2,366 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201d7a:	09800593          	li	a1,152
ffffffffc0201d7e:	00003517          	auipc	a0,0x3
ffffffffc0201d82:	6e250513          	addi	a0,a0,1762 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201d86:	b7cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc0201d8a:	00004697          	auipc	a3,0x4
ffffffffc0201d8e:	87e68693          	addi	a3,a3,-1922 # ffffffffc0205608 <commands+0xe40>
ffffffffc0201d92:	00003617          	auipc	a2,0x3
ffffffffc0201d96:	14e60613          	addi	a2,a2,334 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201d9a:	09a00593          	li	a1,154
ffffffffc0201d9e:	00003517          	auipc	a0,0x3
ffffffffc0201da2:	6c250513          	addi	a0,a0,1730 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201da6:	b5cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc0201daa:	00004697          	auipc	a3,0x4
ffffffffc0201dae:	86e68693          	addi	a3,a3,-1938 # ffffffffc0205618 <commands+0xe50>
ffffffffc0201db2:	00003617          	auipc	a2,0x3
ffffffffc0201db6:	12e60613          	addi	a2,a2,302 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201dba:	09c00593          	li	a1,156
ffffffffc0201dbe:	00003517          	auipc	a0,0x3
ffffffffc0201dc2:	6a250513          	addi	a0,a0,1698 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201dc6:	b3cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc0201dca:	00004697          	auipc	a3,0x4
ffffffffc0201dce:	84e68693          	addi	a3,a3,-1970 # ffffffffc0205618 <commands+0xe50>
ffffffffc0201dd2:	00003617          	auipc	a2,0x3
ffffffffc0201dd6:	10e60613          	addi	a2,a2,270 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201dda:	09e00593          	li	a1,158
ffffffffc0201dde:	00003517          	auipc	a0,0x3
ffffffffc0201de2:	68250513          	addi	a0,a0,1666 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201de6:	b1cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201dea:	00004697          	auipc	a3,0x4
ffffffffc0201dee:	80e68693          	addi	a3,a3,-2034 # ffffffffc02055f8 <commands+0xe30>
ffffffffc0201df2:	00003617          	auipc	a2,0x3
ffffffffc0201df6:	0ee60613          	addi	a2,a2,238 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201dfa:	09400593          	li	a1,148
ffffffffc0201dfe:	00003517          	auipc	a0,0x3
ffffffffc0201e02:	66250513          	addi	a0,a0,1634 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201e06:	afcfe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201e0a:	00003697          	auipc	a3,0x3
ffffffffc0201e0e:	7ee68693          	addi	a3,a3,2030 # ffffffffc02055f8 <commands+0xe30>
ffffffffc0201e12:	00003617          	auipc	a2,0x3
ffffffffc0201e16:	0ce60613          	addi	a2,a2,206 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201e1a:	09600593          	li	a1,150
ffffffffc0201e1e:	00003517          	auipc	a0,0x3
ffffffffc0201e22:	64250513          	addi	a0,a0,1602 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201e26:	adcfe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(mm != NULL);
ffffffffc0201e2a:	00003697          	auipc	a3,0x3
ffffffffc0201e2e:	58668693          	addi	a3,a3,1414 # ffffffffc02053b0 <commands+0xbe8>
ffffffffc0201e32:	00003617          	auipc	a2,0x3
ffffffffc0201e36:	0ae60613          	addi	a2,a2,174 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201e3a:	0c500593          	li	a1,197
ffffffffc0201e3e:	00003517          	auipc	a0,0x3
ffffffffc0201e42:	62250513          	addi	a0,a0,1570 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201e46:	abcfe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0201e4a:	00003697          	auipc	a3,0x3
ffffffffc0201e4e:	69668693          	addi	a3,a3,1686 # ffffffffc02054e0 <commands+0xd18>
ffffffffc0201e52:	00003617          	auipc	a2,0x3
ffffffffc0201e56:	08e60613          	addi	a2,a2,142 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201e5a:	0c800593          	li	a1,200
ffffffffc0201e5e:	00003517          	auipc	a0,0x3
ffffffffc0201e62:	60250513          	addi	a0,a0,1538 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201e66:	a9cfe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201e6a:	00003697          	auipc	a3,0x3
ffffffffc0201e6e:	73e68693          	addi	a3,a3,1854 # ffffffffc02055a8 <commands+0xde0>
ffffffffc0201e72:	00003617          	auipc	a2,0x3
ffffffffc0201e76:	06e60613          	addi	a2,a2,110 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201e7a:	0eb00593          	li	a1,235
ffffffffc0201e7e:	00003517          	auipc	a0,0x3
ffffffffc0201e82:	5e250513          	addi	a0,a0,1506 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201e86:	a7cfe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201e8a <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0201e8a:	0000f797          	auipc	a5,0xf
ffffffffc0201e8e:	6a67b783          	ld	a5,1702(a5) # ffffffffc0211530 <sm>
ffffffffc0201e92:	6b9c                	ld	a5,16(a5)
ffffffffc0201e94:	8782                	jr	a5

ffffffffc0201e96 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0201e96:	0000f797          	auipc	a5,0xf
ffffffffc0201e9a:	69a7b783          	ld	a5,1690(a5) # ffffffffc0211530 <sm>
ffffffffc0201e9e:	739c                	ld	a5,32(a5)
ffffffffc0201ea0:	8782                	jr	a5

ffffffffc0201ea2 <swap_out>:
{
ffffffffc0201ea2:	711d                	addi	sp,sp,-96
ffffffffc0201ea4:	ec86                	sd	ra,88(sp)
ffffffffc0201ea6:	e8a2                	sd	s0,80(sp)
ffffffffc0201ea8:	e4a6                	sd	s1,72(sp)
ffffffffc0201eaa:	e0ca                	sd	s2,64(sp)
ffffffffc0201eac:	fc4e                	sd	s3,56(sp)
ffffffffc0201eae:	f852                	sd	s4,48(sp)
ffffffffc0201eb0:	f456                	sd	s5,40(sp)
ffffffffc0201eb2:	f05a                	sd	s6,32(sp)
ffffffffc0201eb4:	ec5e                	sd	s7,24(sp)
ffffffffc0201eb6:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0201eb8:	cde9                	beqz	a1,ffffffffc0201f92 <swap_out+0xf0>
ffffffffc0201eba:	8a2e                	mv	s4,a1
ffffffffc0201ebc:	892a                	mv	s2,a0
ffffffffc0201ebe:	8ab2                	mv	s5,a2
ffffffffc0201ec0:	4401                	li	s0,0
ffffffffc0201ec2:	0000f997          	auipc	s3,0xf
ffffffffc0201ec6:	66e98993          	addi	s3,s3,1646 # ffffffffc0211530 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201eca:	00004b17          	auipc	s6,0x4
ffffffffc0201ece:	8a6b0b13          	addi	s6,s6,-1882 # ffffffffc0205770 <commands+0xfa8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201ed2:	00004b97          	auipc	s7,0x4
ffffffffc0201ed6:	886b8b93          	addi	s7,s7,-1914 # ffffffffc0205758 <commands+0xf90>
ffffffffc0201eda:	a825                	j	ffffffffc0201f12 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201edc:	67a2                	ld	a5,8(sp)
ffffffffc0201ede:	8626                	mv	a2,s1
ffffffffc0201ee0:	85a2                	mv	a1,s0
ffffffffc0201ee2:	63b4                	ld	a3,64(a5)
ffffffffc0201ee4:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0201ee6:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201ee8:	82b1                	srli	a3,a3,0xc
ffffffffc0201eea:	0685                	addi	a3,a3,1
ffffffffc0201eec:	9cefe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201ef0:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0201ef2:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201ef4:	613c                	ld	a5,64(a0)
ffffffffc0201ef6:	83b1                	srli	a5,a5,0xc
ffffffffc0201ef8:	0785                	addi	a5,a5,1
ffffffffc0201efa:	07a2                	slli	a5,a5,0x8
ffffffffc0201efc:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0201f00:	4d3000ef          	jal	ra,ffffffffc0202bd2 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0201f04:	01893503          	ld	a0,24(s2)
ffffffffc0201f08:	85a6                	mv	a1,s1
ffffffffc0201f0a:	531010ef          	jal	ra,ffffffffc0203c3a <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0201f0e:	048a0d63          	beq	s4,s0,ffffffffc0201f68 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0201f12:	0009b783          	ld	a5,0(s3)
ffffffffc0201f16:	8656                	mv	a2,s5
ffffffffc0201f18:	002c                	addi	a1,sp,8
ffffffffc0201f1a:	7b9c                	ld	a5,48(a5)
ffffffffc0201f1c:	854a                	mv	a0,s2
ffffffffc0201f1e:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0201f20:	e12d                	bnez	a0,ffffffffc0201f82 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0201f22:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201f24:	01893503          	ld	a0,24(s2)
ffffffffc0201f28:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0201f2a:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201f2c:	85a6                	mv	a1,s1
ffffffffc0201f2e:	51f000ef          	jal	ra,ffffffffc0202c4c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201f32:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201f34:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0201f36:	8b85                	andi	a5,a5,1
ffffffffc0201f38:	cfb9                	beqz	a5,ffffffffc0201f96 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0201f3a:	65a2                	ld	a1,8(sp)
ffffffffc0201f3c:	61bc                	ld	a5,64(a1)
ffffffffc0201f3e:	83b1                	srli	a5,a5,0xc
ffffffffc0201f40:	0785                	addi	a5,a5,1
ffffffffc0201f42:	00879513          	slli	a0,a5,0x8
ffffffffc0201f46:	026020ef          	jal	ra,ffffffffc0203f6c <swapfs_write>
ffffffffc0201f4a:	d949                	beqz	a0,ffffffffc0201edc <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201f4c:	855e                	mv	a0,s7
ffffffffc0201f4e:	96cfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201f52:	0009b783          	ld	a5,0(s3)
ffffffffc0201f56:	6622                	ld	a2,8(sp)
ffffffffc0201f58:	4681                	li	a3,0
ffffffffc0201f5a:	739c                	ld	a5,32(a5)
ffffffffc0201f5c:	85a6                	mv	a1,s1
ffffffffc0201f5e:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0201f60:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201f62:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0201f64:	fa8a17e3          	bne	s4,s0,ffffffffc0201f12 <swap_out+0x70>
}
ffffffffc0201f68:	60e6                	ld	ra,88(sp)
ffffffffc0201f6a:	8522                	mv	a0,s0
ffffffffc0201f6c:	6446                	ld	s0,80(sp)
ffffffffc0201f6e:	64a6                	ld	s1,72(sp)
ffffffffc0201f70:	6906                	ld	s2,64(sp)
ffffffffc0201f72:	79e2                	ld	s3,56(sp)
ffffffffc0201f74:	7a42                	ld	s4,48(sp)
ffffffffc0201f76:	7aa2                	ld	s5,40(sp)
ffffffffc0201f78:	7b02                	ld	s6,32(sp)
ffffffffc0201f7a:	6be2                	ld	s7,24(sp)
ffffffffc0201f7c:	6c42                	ld	s8,16(sp)
ffffffffc0201f7e:	6125                	addi	sp,sp,96
ffffffffc0201f80:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0201f82:	85a2                	mv	a1,s0
ffffffffc0201f84:	00003517          	auipc	a0,0x3
ffffffffc0201f88:	78c50513          	addi	a0,a0,1932 # ffffffffc0205710 <commands+0xf48>
ffffffffc0201f8c:	92efe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                  break;
ffffffffc0201f90:	bfe1                	j	ffffffffc0201f68 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0201f92:	4401                	li	s0,0
ffffffffc0201f94:	bfd1                	j	ffffffffc0201f68 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201f96:	00003697          	auipc	a3,0x3
ffffffffc0201f9a:	7aa68693          	addi	a3,a3,1962 # ffffffffc0205740 <commands+0xf78>
ffffffffc0201f9e:	00003617          	auipc	a2,0x3
ffffffffc0201fa2:	f4260613          	addi	a2,a2,-190 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0201fa6:	06900593          	li	a1,105
ffffffffc0201faa:	00003517          	auipc	a0,0x3
ffffffffc0201fae:	4b650513          	addi	a0,a0,1206 # ffffffffc0205460 <commands+0xc98>
ffffffffc0201fb2:	950fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201fb6 <swap_in>:
{
ffffffffc0201fb6:	7179                	addi	sp,sp,-48
ffffffffc0201fb8:	e84a                	sd	s2,16(sp)
ffffffffc0201fba:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0201fbc:	4505                	li	a0,1
{
ffffffffc0201fbe:	ec26                	sd	s1,24(sp)
ffffffffc0201fc0:	e44e                	sd	s3,8(sp)
ffffffffc0201fc2:	f406                	sd	ra,40(sp)
ffffffffc0201fc4:	f022                	sd	s0,32(sp)
ffffffffc0201fc6:	84ae                	mv	s1,a1
ffffffffc0201fc8:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0201fca:	377000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
     assert(result!=NULL);
ffffffffc0201fce:	c129                	beqz	a0,ffffffffc0202010 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0201fd0:	842a                	mv	s0,a0
ffffffffc0201fd2:	01893503          	ld	a0,24(s2)
ffffffffc0201fd6:	4601                	li	a2,0
ffffffffc0201fd8:	85a6                	mv	a1,s1
ffffffffc0201fda:	473000ef          	jal	ra,ffffffffc0202c4c <get_pte>
ffffffffc0201fde:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0201fe0:	6108                	ld	a0,0(a0)
ffffffffc0201fe2:	85a2                	mv	a1,s0
ffffffffc0201fe4:	6ef010ef          	jal	ra,ffffffffc0203ed2 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0201fe8:	00093583          	ld	a1,0(s2)
ffffffffc0201fec:	8626                	mv	a2,s1
ffffffffc0201fee:	00003517          	auipc	a0,0x3
ffffffffc0201ff2:	7d250513          	addi	a0,a0,2002 # ffffffffc02057c0 <commands+0xff8>
ffffffffc0201ff6:	81a1                	srli	a1,a1,0x8
ffffffffc0201ff8:	8c2fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0201ffc:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0201ffe:	0089b023          	sd	s0,0(s3)
}
ffffffffc0202002:	7402                	ld	s0,32(sp)
ffffffffc0202004:	64e2                	ld	s1,24(sp)
ffffffffc0202006:	6942                	ld	s2,16(sp)
ffffffffc0202008:	69a2                	ld	s3,8(sp)
ffffffffc020200a:	4501                	li	a0,0
ffffffffc020200c:	6145                	addi	sp,sp,48
ffffffffc020200e:	8082                	ret
     assert(result!=NULL);
ffffffffc0202010:	00003697          	auipc	a3,0x3
ffffffffc0202014:	7a068693          	addi	a3,a3,1952 # ffffffffc02057b0 <commands+0xfe8>
ffffffffc0202018:	00003617          	auipc	a2,0x3
ffffffffc020201c:	ec860613          	addi	a2,a2,-312 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202020:	07f00593          	li	a1,127
ffffffffc0202024:	00003517          	auipc	a0,0x3
ffffffffc0202028:	43c50513          	addi	a0,a0,1084 # ffffffffc0205460 <commands+0xc98>
ffffffffc020202c:	8d6fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202030 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0202030:	0000f797          	auipc	a5,0xf
ffffffffc0202034:	0b078793          	addi	a5,a5,176 # ffffffffc02110e0 <free_area>
ffffffffc0202038:	e79c                	sd	a5,8(a5)
ffffffffc020203a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020203c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0202040:	8082                	ret

ffffffffc0202042 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0202042:	0000f517          	auipc	a0,0xf
ffffffffc0202046:	0ae56503          	lwu	a0,174(a0) # ffffffffc02110f0 <free_area+0x10>
ffffffffc020204a:	8082                	ret

ffffffffc020204c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc020204c:	715d                	addi	sp,sp,-80
ffffffffc020204e:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0202050:	0000f417          	auipc	s0,0xf
ffffffffc0202054:	09040413          	addi	s0,s0,144 # ffffffffc02110e0 <free_area>
ffffffffc0202058:	641c                	ld	a5,8(s0)
ffffffffc020205a:	e486                	sd	ra,72(sp)
ffffffffc020205c:	fc26                	sd	s1,56(sp)
ffffffffc020205e:	f84a                	sd	s2,48(sp)
ffffffffc0202060:	f44e                	sd	s3,40(sp)
ffffffffc0202062:	f052                	sd	s4,32(sp)
ffffffffc0202064:	ec56                	sd	s5,24(sp)
ffffffffc0202066:	e85a                	sd	s6,16(sp)
ffffffffc0202068:	e45e                	sd	s7,8(sp)
ffffffffc020206a:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020206c:	2c878763          	beq	a5,s0,ffffffffc020233a <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0202070:	4481                	li	s1,0
ffffffffc0202072:	4901                	li	s2,0
ffffffffc0202074:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202078:	8b09                	andi	a4,a4,2
ffffffffc020207a:	2c070463          	beqz	a4,ffffffffc0202342 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc020207e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202082:	679c                	ld	a5,8(a5)
ffffffffc0202084:	2905                	addiw	s2,s2,1
ffffffffc0202086:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202088:	fe8796e3          	bne	a5,s0,ffffffffc0202074 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc020208c:	89a6                	mv	s3,s1
ffffffffc020208e:	385000ef          	jal	ra,ffffffffc0202c12 <nr_free_pages>
ffffffffc0202092:	71351863          	bne	a0,s3,ffffffffc02027a2 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202096:	4505                	li	a0,1
ffffffffc0202098:	2a9000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc020209c:	8a2a                	mv	s4,a0
ffffffffc020209e:	44050263          	beqz	a0,ffffffffc02024e2 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02020a2:	4505                	li	a0,1
ffffffffc02020a4:	29d000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc02020a8:	89aa                	mv	s3,a0
ffffffffc02020aa:	70050c63          	beqz	a0,ffffffffc02027c2 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02020ae:	4505                	li	a0,1
ffffffffc02020b0:	291000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc02020b4:	8aaa                	mv	s5,a0
ffffffffc02020b6:	4a050663          	beqz	a0,ffffffffc0202562 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02020ba:	2b3a0463          	beq	s4,s3,ffffffffc0202362 <default_check+0x316>
ffffffffc02020be:	2aaa0263          	beq	s4,a0,ffffffffc0202362 <default_check+0x316>
ffffffffc02020c2:	2aa98063          	beq	s3,a0,ffffffffc0202362 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02020c6:	000a2783          	lw	a5,0(s4)
ffffffffc02020ca:	2a079c63          	bnez	a5,ffffffffc0202382 <default_check+0x336>
ffffffffc02020ce:	0009a783          	lw	a5,0(s3)
ffffffffc02020d2:	2a079863          	bnez	a5,ffffffffc0202382 <default_check+0x336>
ffffffffc02020d6:	411c                	lw	a5,0(a0)
ffffffffc02020d8:	2a079563          	bnez	a5,ffffffffc0202382 <default_check+0x336>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02020dc:	0000f797          	auipc	a5,0xf
ffffffffc02020e0:	47c7b783          	ld	a5,1148(a5) # ffffffffc0211558 <pages>
ffffffffc02020e4:	40fa0733          	sub	a4,s4,a5
ffffffffc02020e8:	870d                	srai	a4,a4,0x3
ffffffffc02020ea:	00004597          	auipc	a1,0x4
ffffffffc02020ee:	34e5b583          	ld	a1,846(a1) # ffffffffc0206438 <error_string+0x38>
ffffffffc02020f2:	02b70733          	mul	a4,a4,a1
ffffffffc02020f6:	00004617          	auipc	a2,0x4
ffffffffc02020fa:	34a63603          	ld	a2,842(a2) # ffffffffc0206440 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02020fe:	0000f697          	auipc	a3,0xf
ffffffffc0202102:	4526b683          	ld	a3,1106(a3) # ffffffffc0211550 <npage>
ffffffffc0202106:	06b2                	slli	a3,a3,0xc
ffffffffc0202108:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020210a:	0732                	slli	a4,a4,0xc
ffffffffc020210c:	28d77b63          	bgeu	a4,a3,ffffffffc02023a2 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202110:	40f98733          	sub	a4,s3,a5
ffffffffc0202114:	870d                	srai	a4,a4,0x3
ffffffffc0202116:	02b70733          	mul	a4,a4,a1
ffffffffc020211a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020211c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020211e:	4cd77263          	bgeu	a4,a3,ffffffffc02025e2 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202122:	40f507b3          	sub	a5,a0,a5
ffffffffc0202126:	878d                	srai	a5,a5,0x3
ffffffffc0202128:	02b787b3          	mul	a5,a5,a1
ffffffffc020212c:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020212e:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202130:	30d7f963          	bgeu	a5,a3,ffffffffc0202442 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0202134:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202136:	00043c03          	ld	s8,0(s0)
ffffffffc020213a:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc020213e:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0202142:	e400                	sd	s0,8(s0)
ffffffffc0202144:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0202146:	0000f797          	auipc	a5,0xf
ffffffffc020214a:	fa07a523          	sw	zero,-86(a5) # ffffffffc02110f0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc020214e:	1f3000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc0202152:	2c051863          	bnez	a0,ffffffffc0202422 <default_check+0x3d6>
    free_page(p0);
ffffffffc0202156:	4585                	li	a1,1
ffffffffc0202158:	8552                	mv	a0,s4
ffffffffc020215a:	279000ef          	jal	ra,ffffffffc0202bd2 <free_pages>
    free_page(p1);
ffffffffc020215e:	4585                	li	a1,1
ffffffffc0202160:	854e                	mv	a0,s3
ffffffffc0202162:	271000ef          	jal	ra,ffffffffc0202bd2 <free_pages>
    free_page(p2);
ffffffffc0202166:	4585                	li	a1,1
ffffffffc0202168:	8556                	mv	a0,s5
ffffffffc020216a:	269000ef          	jal	ra,ffffffffc0202bd2 <free_pages>
    assert(nr_free == 3);
ffffffffc020216e:	4818                	lw	a4,16(s0)
ffffffffc0202170:	478d                	li	a5,3
ffffffffc0202172:	28f71863          	bne	a4,a5,ffffffffc0202402 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202176:	4505                	li	a0,1
ffffffffc0202178:	1c9000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc020217c:	89aa                	mv	s3,a0
ffffffffc020217e:	26050263          	beqz	a0,ffffffffc02023e2 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202182:	4505                	li	a0,1
ffffffffc0202184:	1bd000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc0202188:	8aaa                	mv	s5,a0
ffffffffc020218a:	3a050c63          	beqz	a0,ffffffffc0202542 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020218e:	4505                	li	a0,1
ffffffffc0202190:	1b1000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc0202194:	8a2a                	mv	s4,a0
ffffffffc0202196:	38050663          	beqz	a0,ffffffffc0202522 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc020219a:	4505                	li	a0,1
ffffffffc020219c:	1a5000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc02021a0:	36051163          	bnez	a0,ffffffffc0202502 <default_check+0x4b6>
    free_page(p0);
ffffffffc02021a4:	4585                	li	a1,1
ffffffffc02021a6:	854e                	mv	a0,s3
ffffffffc02021a8:	22b000ef          	jal	ra,ffffffffc0202bd2 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02021ac:	641c                	ld	a5,8(s0)
ffffffffc02021ae:	20878a63          	beq	a5,s0,ffffffffc02023c2 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc02021b2:	4505                	li	a0,1
ffffffffc02021b4:	18d000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc02021b8:	30a99563          	bne	s3,a0,ffffffffc02024c2 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc02021bc:	4505                	li	a0,1
ffffffffc02021be:	183000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc02021c2:	2e051063          	bnez	a0,ffffffffc02024a2 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc02021c6:	481c                	lw	a5,16(s0)
ffffffffc02021c8:	2a079d63          	bnez	a5,ffffffffc0202482 <default_check+0x436>
    free_page(p);
ffffffffc02021cc:	854e                	mv	a0,s3
ffffffffc02021ce:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02021d0:	01843023          	sd	s8,0(s0)
ffffffffc02021d4:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc02021d8:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02021dc:	1f7000ef          	jal	ra,ffffffffc0202bd2 <free_pages>
    free_page(p1);
ffffffffc02021e0:	4585                	li	a1,1
ffffffffc02021e2:	8556                	mv	a0,s5
ffffffffc02021e4:	1ef000ef          	jal	ra,ffffffffc0202bd2 <free_pages>
    free_page(p2);
ffffffffc02021e8:	4585                	li	a1,1
ffffffffc02021ea:	8552                	mv	a0,s4
ffffffffc02021ec:	1e7000ef          	jal	ra,ffffffffc0202bd2 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02021f0:	4515                	li	a0,5
ffffffffc02021f2:	14f000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc02021f6:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02021f8:	26050563          	beqz	a0,ffffffffc0202462 <default_check+0x416>
ffffffffc02021fc:	651c                	ld	a5,8(a0)
ffffffffc02021fe:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0202200:	8b85                	andi	a5,a5,1
ffffffffc0202202:	54079063          	bnez	a5,ffffffffc0202742 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202206:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202208:	00043b03          	ld	s6,0(s0)
ffffffffc020220c:	00843a83          	ld	s5,8(s0)
ffffffffc0202210:	e000                	sd	s0,0(s0)
ffffffffc0202212:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0202214:	12d000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc0202218:	50051563          	bnez	a0,ffffffffc0202722 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020221c:	09098a13          	addi	s4,s3,144
ffffffffc0202220:	8552                	mv	a0,s4
ffffffffc0202222:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202224:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0202228:	0000f797          	auipc	a5,0xf
ffffffffc020222c:	ec07a423          	sw	zero,-312(a5) # ffffffffc02110f0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202230:	1a3000ef          	jal	ra,ffffffffc0202bd2 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0202234:	4511                	li	a0,4
ffffffffc0202236:	10b000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc020223a:	4c051463          	bnez	a0,ffffffffc0202702 <default_check+0x6b6>
ffffffffc020223e:	0989b783          	ld	a5,152(s3)
ffffffffc0202242:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202244:	8b85                	andi	a5,a5,1
ffffffffc0202246:	48078e63          	beqz	a5,ffffffffc02026e2 <default_check+0x696>
ffffffffc020224a:	0a89a703          	lw	a4,168(s3)
ffffffffc020224e:	478d                	li	a5,3
ffffffffc0202250:	48f71963          	bne	a4,a5,ffffffffc02026e2 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202254:	450d                	li	a0,3
ffffffffc0202256:	0eb000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc020225a:	8c2a                	mv	s8,a0
ffffffffc020225c:	46050363          	beqz	a0,ffffffffc02026c2 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0202260:	4505                	li	a0,1
ffffffffc0202262:	0df000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc0202266:	42051e63          	bnez	a0,ffffffffc02026a2 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc020226a:	418a1c63          	bne	s4,s8,ffffffffc0202682 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc020226e:	4585                	li	a1,1
ffffffffc0202270:	854e                	mv	a0,s3
ffffffffc0202272:	161000ef          	jal	ra,ffffffffc0202bd2 <free_pages>
    free_pages(p1, 3);
ffffffffc0202276:	458d                	li	a1,3
ffffffffc0202278:	8552                	mv	a0,s4
ffffffffc020227a:	159000ef          	jal	ra,ffffffffc0202bd2 <free_pages>
ffffffffc020227e:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202282:	04898c13          	addi	s8,s3,72
ffffffffc0202286:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202288:	8b85                	andi	a5,a5,1
ffffffffc020228a:	3c078c63          	beqz	a5,ffffffffc0202662 <default_check+0x616>
ffffffffc020228e:	0189a703          	lw	a4,24(s3)
ffffffffc0202292:	4785                	li	a5,1
ffffffffc0202294:	3cf71763          	bne	a4,a5,ffffffffc0202662 <default_check+0x616>
ffffffffc0202298:	008a3783          	ld	a5,8(s4)
ffffffffc020229c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020229e:	8b85                	andi	a5,a5,1
ffffffffc02022a0:	3a078163          	beqz	a5,ffffffffc0202642 <default_check+0x5f6>
ffffffffc02022a4:	018a2703          	lw	a4,24(s4)
ffffffffc02022a8:	478d                	li	a5,3
ffffffffc02022aa:	38f71c63          	bne	a4,a5,ffffffffc0202642 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02022ae:	4505                	li	a0,1
ffffffffc02022b0:	091000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc02022b4:	36a99763          	bne	s3,a0,ffffffffc0202622 <default_check+0x5d6>
    free_page(p0);
ffffffffc02022b8:	4585                	li	a1,1
ffffffffc02022ba:	119000ef          	jal	ra,ffffffffc0202bd2 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02022be:	4509                	li	a0,2
ffffffffc02022c0:	081000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc02022c4:	32aa1f63          	bne	s4,a0,ffffffffc0202602 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc02022c8:	4589                	li	a1,2
ffffffffc02022ca:	109000ef          	jal	ra,ffffffffc0202bd2 <free_pages>
    free_page(p2);
ffffffffc02022ce:	4585                	li	a1,1
ffffffffc02022d0:	8562                	mv	a0,s8
ffffffffc02022d2:	101000ef          	jal	ra,ffffffffc0202bd2 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02022d6:	4515                	li	a0,5
ffffffffc02022d8:	069000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc02022dc:	89aa                	mv	s3,a0
ffffffffc02022de:	48050263          	beqz	a0,ffffffffc0202762 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc02022e2:	4505                	li	a0,1
ffffffffc02022e4:	05d000ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc02022e8:	2c051d63          	bnez	a0,ffffffffc02025c2 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc02022ec:	481c                	lw	a5,16(s0)
ffffffffc02022ee:	2a079a63          	bnez	a5,ffffffffc02025a2 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02022f2:	4595                	li	a1,5
ffffffffc02022f4:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02022f6:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02022fa:	01643023          	sd	s6,0(s0)
ffffffffc02022fe:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0202302:	0d1000ef          	jal	ra,ffffffffc0202bd2 <free_pages>
    return listelm->next;
ffffffffc0202306:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202308:	00878963          	beq	a5,s0,ffffffffc020231a <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020230c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202310:	679c                	ld	a5,8(a5)
ffffffffc0202312:	397d                	addiw	s2,s2,-1
ffffffffc0202314:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202316:	fe879be3          	bne	a5,s0,ffffffffc020230c <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc020231a:	26091463          	bnez	s2,ffffffffc0202582 <default_check+0x536>
    assert(total == 0);
ffffffffc020231e:	46049263          	bnez	s1,ffffffffc0202782 <default_check+0x736>
}
ffffffffc0202322:	60a6                	ld	ra,72(sp)
ffffffffc0202324:	6406                	ld	s0,64(sp)
ffffffffc0202326:	74e2                	ld	s1,56(sp)
ffffffffc0202328:	7942                	ld	s2,48(sp)
ffffffffc020232a:	79a2                	ld	s3,40(sp)
ffffffffc020232c:	7a02                	ld	s4,32(sp)
ffffffffc020232e:	6ae2                	ld	s5,24(sp)
ffffffffc0202330:	6b42                	ld	s6,16(sp)
ffffffffc0202332:	6ba2                	ld	s7,8(sp)
ffffffffc0202334:	6c02                	ld	s8,0(sp)
ffffffffc0202336:	6161                	addi	sp,sp,80
ffffffffc0202338:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020233a:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020233c:	4481                	li	s1,0
ffffffffc020233e:	4901                	li	s2,0
ffffffffc0202340:	b3b9                	j	ffffffffc020208e <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0202342:	00003697          	auipc	a3,0x3
ffffffffc0202346:	14668693          	addi	a3,a3,326 # ffffffffc0205488 <commands+0xcc0>
ffffffffc020234a:	00003617          	auipc	a2,0x3
ffffffffc020234e:	b9660613          	addi	a2,a2,-1130 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202352:	0f000593          	li	a1,240
ffffffffc0202356:	00003517          	auipc	a0,0x3
ffffffffc020235a:	4aa50513          	addi	a0,a0,1194 # ffffffffc0205800 <commands+0x1038>
ffffffffc020235e:	da5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202362:	00003697          	auipc	a3,0x3
ffffffffc0202366:	51668693          	addi	a3,a3,1302 # ffffffffc0205878 <commands+0x10b0>
ffffffffc020236a:	00003617          	auipc	a2,0x3
ffffffffc020236e:	b7660613          	addi	a2,a2,-1162 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202372:	0bd00593          	li	a1,189
ffffffffc0202376:	00003517          	auipc	a0,0x3
ffffffffc020237a:	48a50513          	addi	a0,a0,1162 # ffffffffc0205800 <commands+0x1038>
ffffffffc020237e:	d85fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202382:	00003697          	auipc	a3,0x3
ffffffffc0202386:	51e68693          	addi	a3,a3,1310 # ffffffffc02058a0 <commands+0x10d8>
ffffffffc020238a:	00003617          	auipc	a2,0x3
ffffffffc020238e:	b5660613          	addi	a2,a2,-1194 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202392:	0be00593          	li	a1,190
ffffffffc0202396:	00003517          	auipc	a0,0x3
ffffffffc020239a:	46a50513          	addi	a0,a0,1130 # ffffffffc0205800 <commands+0x1038>
ffffffffc020239e:	d65fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02023a2:	00003697          	auipc	a3,0x3
ffffffffc02023a6:	53e68693          	addi	a3,a3,1342 # ffffffffc02058e0 <commands+0x1118>
ffffffffc02023aa:	00003617          	auipc	a2,0x3
ffffffffc02023ae:	b3660613          	addi	a2,a2,-1226 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02023b2:	0c000593          	li	a1,192
ffffffffc02023b6:	00003517          	auipc	a0,0x3
ffffffffc02023ba:	44a50513          	addi	a0,a0,1098 # ffffffffc0205800 <commands+0x1038>
ffffffffc02023be:	d45fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02023c2:	00003697          	auipc	a3,0x3
ffffffffc02023c6:	5a668693          	addi	a3,a3,1446 # ffffffffc0205968 <commands+0x11a0>
ffffffffc02023ca:	00003617          	auipc	a2,0x3
ffffffffc02023ce:	b1660613          	addi	a2,a2,-1258 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02023d2:	0d900593          	li	a1,217
ffffffffc02023d6:	00003517          	auipc	a0,0x3
ffffffffc02023da:	42a50513          	addi	a0,a0,1066 # ffffffffc0205800 <commands+0x1038>
ffffffffc02023de:	d25fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02023e2:	00003697          	auipc	a3,0x3
ffffffffc02023e6:	43668693          	addi	a3,a3,1078 # ffffffffc0205818 <commands+0x1050>
ffffffffc02023ea:	00003617          	auipc	a2,0x3
ffffffffc02023ee:	af660613          	addi	a2,a2,-1290 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02023f2:	0d200593          	li	a1,210
ffffffffc02023f6:	00003517          	auipc	a0,0x3
ffffffffc02023fa:	40a50513          	addi	a0,a0,1034 # ffffffffc0205800 <commands+0x1038>
ffffffffc02023fe:	d05fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 3);
ffffffffc0202402:	00003697          	auipc	a3,0x3
ffffffffc0202406:	55668693          	addi	a3,a3,1366 # ffffffffc0205958 <commands+0x1190>
ffffffffc020240a:	00003617          	auipc	a2,0x3
ffffffffc020240e:	ad660613          	addi	a2,a2,-1322 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202412:	0d000593          	li	a1,208
ffffffffc0202416:	00003517          	auipc	a0,0x3
ffffffffc020241a:	3ea50513          	addi	a0,a0,1002 # ffffffffc0205800 <commands+0x1038>
ffffffffc020241e:	ce5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202422:	00003697          	auipc	a3,0x3
ffffffffc0202426:	51e68693          	addi	a3,a3,1310 # ffffffffc0205940 <commands+0x1178>
ffffffffc020242a:	00003617          	auipc	a2,0x3
ffffffffc020242e:	ab660613          	addi	a2,a2,-1354 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202432:	0cb00593          	li	a1,203
ffffffffc0202436:	00003517          	auipc	a0,0x3
ffffffffc020243a:	3ca50513          	addi	a0,a0,970 # ffffffffc0205800 <commands+0x1038>
ffffffffc020243e:	cc5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202442:	00003697          	auipc	a3,0x3
ffffffffc0202446:	4de68693          	addi	a3,a3,1246 # ffffffffc0205920 <commands+0x1158>
ffffffffc020244a:	00003617          	auipc	a2,0x3
ffffffffc020244e:	a9660613          	addi	a2,a2,-1386 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202452:	0c200593          	li	a1,194
ffffffffc0202456:	00003517          	auipc	a0,0x3
ffffffffc020245a:	3aa50513          	addi	a0,a0,938 # ffffffffc0205800 <commands+0x1038>
ffffffffc020245e:	ca5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != NULL);
ffffffffc0202462:	00003697          	auipc	a3,0x3
ffffffffc0202466:	53e68693          	addi	a3,a3,1342 # ffffffffc02059a0 <commands+0x11d8>
ffffffffc020246a:	00003617          	auipc	a2,0x3
ffffffffc020246e:	a7660613          	addi	a2,a2,-1418 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202472:	0f800593          	li	a1,248
ffffffffc0202476:	00003517          	auipc	a0,0x3
ffffffffc020247a:	38a50513          	addi	a0,a0,906 # ffffffffc0205800 <commands+0x1038>
ffffffffc020247e:	c85fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc0202482:	00003697          	auipc	a3,0x3
ffffffffc0202486:	1a668693          	addi	a3,a3,422 # ffffffffc0205628 <commands+0xe60>
ffffffffc020248a:	00003617          	auipc	a2,0x3
ffffffffc020248e:	a5660613          	addi	a2,a2,-1450 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202492:	0df00593          	li	a1,223
ffffffffc0202496:	00003517          	auipc	a0,0x3
ffffffffc020249a:	36a50513          	addi	a0,a0,874 # ffffffffc0205800 <commands+0x1038>
ffffffffc020249e:	c65fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02024a2:	00003697          	auipc	a3,0x3
ffffffffc02024a6:	49e68693          	addi	a3,a3,1182 # ffffffffc0205940 <commands+0x1178>
ffffffffc02024aa:	00003617          	auipc	a2,0x3
ffffffffc02024ae:	a3660613          	addi	a2,a2,-1482 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02024b2:	0dd00593          	li	a1,221
ffffffffc02024b6:	00003517          	auipc	a0,0x3
ffffffffc02024ba:	34a50513          	addi	a0,a0,842 # ffffffffc0205800 <commands+0x1038>
ffffffffc02024be:	c45fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02024c2:	00003697          	auipc	a3,0x3
ffffffffc02024c6:	4be68693          	addi	a3,a3,1214 # ffffffffc0205980 <commands+0x11b8>
ffffffffc02024ca:	00003617          	auipc	a2,0x3
ffffffffc02024ce:	a1660613          	addi	a2,a2,-1514 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02024d2:	0dc00593          	li	a1,220
ffffffffc02024d6:	00003517          	auipc	a0,0x3
ffffffffc02024da:	32a50513          	addi	a0,a0,810 # ffffffffc0205800 <commands+0x1038>
ffffffffc02024de:	c25fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02024e2:	00003697          	auipc	a3,0x3
ffffffffc02024e6:	33668693          	addi	a3,a3,822 # ffffffffc0205818 <commands+0x1050>
ffffffffc02024ea:	00003617          	auipc	a2,0x3
ffffffffc02024ee:	9f660613          	addi	a2,a2,-1546 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02024f2:	0b900593          	li	a1,185
ffffffffc02024f6:	00003517          	auipc	a0,0x3
ffffffffc02024fa:	30a50513          	addi	a0,a0,778 # ffffffffc0205800 <commands+0x1038>
ffffffffc02024fe:	c05fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202502:	00003697          	auipc	a3,0x3
ffffffffc0202506:	43e68693          	addi	a3,a3,1086 # ffffffffc0205940 <commands+0x1178>
ffffffffc020250a:	00003617          	auipc	a2,0x3
ffffffffc020250e:	9d660613          	addi	a2,a2,-1578 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202512:	0d600593          	li	a1,214
ffffffffc0202516:	00003517          	auipc	a0,0x3
ffffffffc020251a:	2ea50513          	addi	a0,a0,746 # ffffffffc0205800 <commands+0x1038>
ffffffffc020251e:	be5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202522:	00003697          	auipc	a3,0x3
ffffffffc0202526:	33668693          	addi	a3,a3,822 # ffffffffc0205858 <commands+0x1090>
ffffffffc020252a:	00003617          	auipc	a2,0x3
ffffffffc020252e:	9b660613          	addi	a2,a2,-1610 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202532:	0d400593          	li	a1,212
ffffffffc0202536:	00003517          	auipc	a0,0x3
ffffffffc020253a:	2ca50513          	addi	a0,a0,714 # ffffffffc0205800 <commands+0x1038>
ffffffffc020253e:	bc5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202542:	00003697          	auipc	a3,0x3
ffffffffc0202546:	2f668693          	addi	a3,a3,758 # ffffffffc0205838 <commands+0x1070>
ffffffffc020254a:	00003617          	auipc	a2,0x3
ffffffffc020254e:	99660613          	addi	a2,a2,-1642 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202552:	0d300593          	li	a1,211
ffffffffc0202556:	00003517          	auipc	a0,0x3
ffffffffc020255a:	2aa50513          	addi	a0,a0,682 # ffffffffc0205800 <commands+0x1038>
ffffffffc020255e:	ba5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202562:	00003697          	auipc	a3,0x3
ffffffffc0202566:	2f668693          	addi	a3,a3,758 # ffffffffc0205858 <commands+0x1090>
ffffffffc020256a:	00003617          	auipc	a2,0x3
ffffffffc020256e:	97660613          	addi	a2,a2,-1674 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202572:	0bb00593          	li	a1,187
ffffffffc0202576:	00003517          	auipc	a0,0x3
ffffffffc020257a:	28a50513          	addi	a0,a0,650 # ffffffffc0205800 <commands+0x1038>
ffffffffc020257e:	b85fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(count == 0);
ffffffffc0202582:	00003697          	auipc	a3,0x3
ffffffffc0202586:	56e68693          	addi	a3,a3,1390 # ffffffffc0205af0 <commands+0x1328>
ffffffffc020258a:	00003617          	auipc	a2,0x3
ffffffffc020258e:	95660613          	addi	a2,a2,-1706 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202592:	12500593          	li	a1,293
ffffffffc0202596:	00003517          	auipc	a0,0x3
ffffffffc020259a:	26a50513          	addi	a0,a0,618 # ffffffffc0205800 <commands+0x1038>
ffffffffc020259e:	b65fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc02025a2:	00003697          	auipc	a3,0x3
ffffffffc02025a6:	08668693          	addi	a3,a3,134 # ffffffffc0205628 <commands+0xe60>
ffffffffc02025aa:	00003617          	auipc	a2,0x3
ffffffffc02025ae:	93660613          	addi	a2,a2,-1738 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02025b2:	11a00593          	li	a1,282
ffffffffc02025b6:	00003517          	auipc	a0,0x3
ffffffffc02025ba:	24a50513          	addi	a0,a0,586 # ffffffffc0205800 <commands+0x1038>
ffffffffc02025be:	b45fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02025c2:	00003697          	auipc	a3,0x3
ffffffffc02025c6:	37e68693          	addi	a3,a3,894 # ffffffffc0205940 <commands+0x1178>
ffffffffc02025ca:	00003617          	auipc	a2,0x3
ffffffffc02025ce:	91660613          	addi	a2,a2,-1770 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02025d2:	11800593          	li	a1,280
ffffffffc02025d6:	00003517          	auipc	a0,0x3
ffffffffc02025da:	22a50513          	addi	a0,a0,554 # ffffffffc0205800 <commands+0x1038>
ffffffffc02025de:	b25fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02025e2:	00003697          	auipc	a3,0x3
ffffffffc02025e6:	31e68693          	addi	a3,a3,798 # ffffffffc0205900 <commands+0x1138>
ffffffffc02025ea:	00003617          	auipc	a2,0x3
ffffffffc02025ee:	8f660613          	addi	a2,a2,-1802 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02025f2:	0c100593          	li	a1,193
ffffffffc02025f6:	00003517          	auipc	a0,0x3
ffffffffc02025fa:	20a50513          	addi	a0,a0,522 # ffffffffc0205800 <commands+0x1038>
ffffffffc02025fe:	b05fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202602:	00003697          	auipc	a3,0x3
ffffffffc0202606:	4ae68693          	addi	a3,a3,1198 # ffffffffc0205ab0 <commands+0x12e8>
ffffffffc020260a:	00003617          	auipc	a2,0x3
ffffffffc020260e:	8d660613          	addi	a2,a2,-1834 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202612:	11200593          	li	a1,274
ffffffffc0202616:	00003517          	auipc	a0,0x3
ffffffffc020261a:	1ea50513          	addi	a0,a0,490 # ffffffffc0205800 <commands+0x1038>
ffffffffc020261e:	ae5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202622:	00003697          	auipc	a3,0x3
ffffffffc0202626:	46e68693          	addi	a3,a3,1134 # ffffffffc0205a90 <commands+0x12c8>
ffffffffc020262a:	00003617          	auipc	a2,0x3
ffffffffc020262e:	8b660613          	addi	a2,a2,-1866 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202632:	11000593          	li	a1,272
ffffffffc0202636:	00003517          	auipc	a0,0x3
ffffffffc020263a:	1ca50513          	addi	a0,a0,458 # ffffffffc0205800 <commands+0x1038>
ffffffffc020263e:	ac5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202642:	00003697          	auipc	a3,0x3
ffffffffc0202646:	42668693          	addi	a3,a3,1062 # ffffffffc0205a68 <commands+0x12a0>
ffffffffc020264a:	00003617          	auipc	a2,0x3
ffffffffc020264e:	89660613          	addi	a2,a2,-1898 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202652:	10e00593          	li	a1,270
ffffffffc0202656:	00003517          	auipc	a0,0x3
ffffffffc020265a:	1aa50513          	addi	a0,a0,426 # ffffffffc0205800 <commands+0x1038>
ffffffffc020265e:	aa5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202662:	00003697          	auipc	a3,0x3
ffffffffc0202666:	3de68693          	addi	a3,a3,990 # ffffffffc0205a40 <commands+0x1278>
ffffffffc020266a:	00003617          	auipc	a2,0x3
ffffffffc020266e:	87660613          	addi	a2,a2,-1930 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202672:	10d00593          	li	a1,269
ffffffffc0202676:	00003517          	auipc	a0,0x3
ffffffffc020267a:	18a50513          	addi	a0,a0,394 # ffffffffc0205800 <commands+0x1038>
ffffffffc020267e:	a85fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0202682:	00003697          	auipc	a3,0x3
ffffffffc0202686:	3ae68693          	addi	a3,a3,942 # ffffffffc0205a30 <commands+0x1268>
ffffffffc020268a:	00003617          	auipc	a2,0x3
ffffffffc020268e:	85660613          	addi	a2,a2,-1962 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202692:	10800593          	li	a1,264
ffffffffc0202696:	00003517          	auipc	a0,0x3
ffffffffc020269a:	16a50513          	addi	a0,a0,362 # ffffffffc0205800 <commands+0x1038>
ffffffffc020269e:	a65fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02026a2:	00003697          	auipc	a3,0x3
ffffffffc02026a6:	29e68693          	addi	a3,a3,670 # ffffffffc0205940 <commands+0x1178>
ffffffffc02026aa:	00003617          	auipc	a2,0x3
ffffffffc02026ae:	83660613          	addi	a2,a2,-1994 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02026b2:	10700593          	li	a1,263
ffffffffc02026b6:	00003517          	auipc	a0,0x3
ffffffffc02026ba:	14a50513          	addi	a0,a0,330 # ffffffffc0205800 <commands+0x1038>
ffffffffc02026be:	a45fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02026c2:	00003697          	auipc	a3,0x3
ffffffffc02026c6:	34e68693          	addi	a3,a3,846 # ffffffffc0205a10 <commands+0x1248>
ffffffffc02026ca:	00003617          	auipc	a2,0x3
ffffffffc02026ce:	81660613          	addi	a2,a2,-2026 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02026d2:	10600593          	li	a1,262
ffffffffc02026d6:	00003517          	auipc	a0,0x3
ffffffffc02026da:	12a50513          	addi	a0,a0,298 # ffffffffc0205800 <commands+0x1038>
ffffffffc02026de:	a25fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02026e2:	00003697          	auipc	a3,0x3
ffffffffc02026e6:	2fe68693          	addi	a3,a3,766 # ffffffffc02059e0 <commands+0x1218>
ffffffffc02026ea:	00002617          	auipc	a2,0x2
ffffffffc02026ee:	7f660613          	addi	a2,a2,2038 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02026f2:	10500593          	li	a1,261
ffffffffc02026f6:	00003517          	auipc	a0,0x3
ffffffffc02026fa:	10a50513          	addi	a0,a0,266 # ffffffffc0205800 <commands+0x1038>
ffffffffc02026fe:	a05fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202702:	00003697          	auipc	a3,0x3
ffffffffc0202706:	2c668693          	addi	a3,a3,710 # ffffffffc02059c8 <commands+0x1200>
ffffffffc020270a:	00002617          	auipc	a2,0x2
ffffffffc020270e:	7d660613          	addi	a2,a2,2006 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202712:	10400593          	li	a1,260
ffffffffc0202716:	00003517          	auipc	a0,0x3
ffffffffc020271a:	0ea50513          	addi	a0,a0,234 # ffffffffc0205800 <commands+0x1038>
ffffffffc020271e:	9e5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202722:	00003697          	auipc	a3,0x3
ffffffffc0202726:	21e68693          	addi	a3,a3,542 # ffffffffc0205940 <commands+0x1178>
ffffffffc020272a:	00002617          	auipc	a2,0x2
ffffffffc020272e:	7b660613          	addi	a2,a2,1974 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202732:	0fe00593          	li	a1,254
ffffffffc0202736:	00003517          	auipc	a0,0x3
ffffffffc020273a:	0ca50513          	addi	a0,a0,202 # ffffffffc0205800 <commands+0x1038>
ffffffffc020273e:	9c5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!PageProperty(p0));
ffffffffc0202742:	00003697          	auipc	a3,0x3
ffffffffc0202746:	26e68693          	addi	a3,a3,622 # ffffffffc02059b0 <commands+0x11e8>
ffffffffc020274a:	00002617          	auipc	a2,0x2
ffffffffc020274e:	79660613          	addi	a2,a2,1942 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202752:	0f900593          	li	a1,249
ffffffffc0202756:	00003517          	auipc	a0,0x3
ffffffffc020275a:	0aa50513          	addi	a0,a0,170 # ffffffffc0205800 <commands+0x1038>
ffffffffc020275e:	9a5fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202762:	00003697          	auipc	a3,0x3
ffffffffc0202766:	36e68693          	addi	a3,a3,878 # ffffffffc0205ad0 <commands+0x1308>
ffffffffc020276a:	00002617          	auipc	a2,0x2
ffffffffc020276e:	77660613          	addi	a2,a2,1910 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202772:	11700593          	li	a1,279
ffffffffc0202776:	00003517          	auipc	a0,0x3
ffffffffc020277a:	08a50513          	addi	a0,a0,138 # ffffffffc0205800 <commands+0x1038>
ffffffffc020277e:	985fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == 0);
ffffffffc0202782:	00003697          	auipc	a3,0x3
ffffffffc0202786:	37e68693          	addi	a3,a3,894 # ffffffffc0205b00 <commands+0x1338>
ffffffffc020278a:	00002617          	auipc	a2,0x2
ffffffffc020278e:	75660613          	addi	a2,a2,1878 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202792:	12600593          	li	a1,294
ffffffffc0202796:	00003517          	auipc	a0,0x3
ffffffffc020279a:	06a50513          	addi	a0,a0,106 # ffffffffc0205800 <commands+0x1038>
ffffffffc020279e:	965fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == nr_free_pages());
ffffffffc02027a2:	00003697          	auipc	a3,0x3
ffffffffc02027a6:	cf668693          	addi	a3,a3,-778 # ffffffffc0205498 <commands+0xcd0>
ffffffffc02027aa:	00002617          	auipc	a2,0x2
ffffffffc02027ae:	73660613          	addi	a2,a2,1846 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02027b2:	0f300593          	li	a1,243
ffffffffc02027b6:	00003517          	auipc	a0,0x3
ffffffffc02027ba:	04a50513          	addi	a0,a0,74 # ffffffffc0205800 <commands+0x1038>
ffffffffc02027be:	945fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02027c2:	00003697          	auipc	a3,0x3
ffffffffc02027c6:	07668693          	addi	a3,a3,118 # ffffffffc0205838 <commands+0x1070>
ffffffffc02027ca:	00002617          	auipc	a2,0x2
ffffffffc02027ce:	71660613          	addi	a2,a2,1814 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02027d2:	0ba00593          	li	a1,186
ffffffffc02027d6:	00003517          	auipc	a0,0x3
ffffffffc02027da:	02a50513          	addi	a0,a0,42 # ffffffffc0205800 <commands+0x1038>
ffffffffc02027de:	925fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02027e2 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02027e2:	1141                	addi	sp,sp,-16
ffffffffc02027e4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02027e6:	14058a63          	beqz	a1,ffffffffc020293a <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc02027ea:	00359693          	slli	a3,a1,0x3
ffffffffc02027ee:	96ae                	add	a3,a3,a1
ffffffffc02027f0:	068e                	slli	a3,a3,0x3
ffffffffc02027f2:	96aa                	add	a3,a3,a0
ffffffffc02027f4:	87aa                	mv	a5,a0
ffffffffc02027f6:	02d50263          	beq	a0,a3,ffffffffc020281a <default_free_pages+0x38>
ffffffffc02027fa:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02027fc:	8b05                	andi	a4,a4,1
ffffffffc02027fe:	10071e63          	bnez	a4,ffffffffc020291a <default_free_pages+0x138>
ffffffffc0202802:	6798                	ld	a4,8(a5)
ffffffffc0202804:	8b09                	andi	a4,a4,2
ffffffffc0202806:	10071a63          	bnez	a4,ffffffffc020291a <default_free_pages+0x138>
        p->flags = 0;
ffffffffc020280a:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020280e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202812:	04878793          	addi	a5,a5,72
ffffffffc0202816:	fed792e3          	bne	a5,a3,ffffffffc02027fa <default_free_pages+0x18>
    base->property = n;
ffffffffc020281a:	2581                	sext.w	a1,a1
ffffffffc020281c:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc020281e:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202822:	4789                	li	a5,2
ffffffffc0202824:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0202828:	0000f697          	auipc	a3,0xf
ffffffffc020282c:	8b868693          	addi	a3,a3,-1864 # ffffffffc02110e0 <free_area>
ffffffffc0202830:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202832:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202834:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0202838:	9db9                	addw	a1,a1,a4
ffffffffc020283a:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020283c:	0ad78863          	beq	a5,a3,ffffffffc02028ec <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0202840:	fe078713          	addi	a4,a5,-32
ffffffffc0202844:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202848:	4581                	li	a1,0
            if (base < page) {
ffffffffc020284a:	00e56a63          	bltu	a0,a4,ffffffffc020285e <default_free_pages+0x7c>
    return listelm->next;
ffffffffc020284e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202850:	06d70263          	beq	a4,a3,ffffffffc02028b4 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0202854:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202856:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc020285a:	fee57ae3          	bgeu	a0,a4,ffffffffc020284e <default_free_pages+0x6c>
ffffffffc020285e:	c199                	beqz	a1,ffffffffc0202864 <default_free_pages+0x82>
ffffffffc0202860:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202864:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0202866:	e390                	sd	a2,0(a5)
ffffffffc0202868:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020286a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020286c:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc020286e:	02d70063          	beq	a4,a3,ffffffffc020288e <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0202872:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0202876:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc020287a:	02081613          	slli	a2,a6,0x20
ffffffffc020287e:	9201                	srli	a2,a2,0x20
ffffffffc0202880:	00361793          	slli	a5,a2,0x3
ffffffffc0202884:	97b2                	add	a5,a5,a2
ffffffffc0202886:	078e                	slli	a5,a5,0x3
ffffffffc0202888:	97ae                	add	a5,a5,a1
ffffffffc020288a:	02f50f63          	beq	a0,a5,ffffffffc02028c8 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc020288e:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc0202890:	00d70f63          	beq	a4,a3,ffffffffc02028ae <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0202894:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc0202896:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc020289a:	02059613          	slli	a2,a1,0x20
ffffffffc020289e:	9201                	srli	a2,a2,0x20
ffffffffc02028a0:	00361793          	slli	a5,a2,0x3
ffffffffc02028a4:	97b2                	add	a5,a5,a2
ffffffffc02028a6:	078e                	slli	a5,a5,0x3
ffffffffc02028a8:	97aa                	add	a5,a5,a0
ffffffffc02028aa:	04f68863          	beq	a3,a5,ffffffffc02028fa <default_free_pages+0x118>
}
ffffffffc02028ae:	60a2                	ld	ra,8(sp)
ffffffffc02028b0:	0141                	addi	sp,sp,16
ffffffffc02028b2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02028b4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02028b6:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc02028b8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02028ba:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02028bc:	02d70563          	beq	a4,a3,ffffffffc02028e6 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc02028c0:	8832                	mv	a6,a2
ffffffffc02028c2:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02028c4:	87ba                	mv	a5,a4
ffffffffc02028c6:	bf41                	j	ffffffffc0202856 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc02028c8:	4d1c                	lw	a5,24(a0)
ffffffffc02028ca:	0107883b          	addw	a6,a5,a6
ffffffffc02028ce:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02028d2:	57f5                	li	a5,-3
ffffffffc02028d4:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02028d8:	7110                	ld	a2,32(a0)
ffffffffc02028da:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc02028dc:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc02028de:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02028e0:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02028e2:	e390                	sd	a2,0(a5)
ffffffffc02028e4:	b775                	j	ffffffffc0202890 <default_free_pages+0xae>
ffffffffc02028e6:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02028e8:	873e                	mv	a4,a5
ffffffffc02028ea:	b761                	j	ffffffffc0202872 <default_free_pages+0x90>
}
ffffffffc02028ec:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02028ee:	e390                	sd	a2,0(a5)
ffffffffc02028f0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02028f2:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02028f4:	f11c                	sd	a5,32(a0)
ffffffffc02028f6:	0141                	addi	sp,sp,16
ffffffffc02028f8:	8082                	ret
            base->property += p->property;
ffffffffc02028fa:	ff872783          	lw	a5,-8(a4)
ffffffffc02028fe:	fe870693          	addi	a3,a4,-24
ffffffffc0202902:	9dbd                	addw	a1,a1,a5
ffffffffc0202904:	cd0c                	sw	a1,24(a0)
ffffffffc0202906:	57f5                	li	a5,-3
ffffffffc0202908:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020290c:	6314                	ld	a3,0(a4)
ffffffffc020290e:	671c                	ld	a5,8(a4)
}
ffffffffc0202910:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0202912:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0202914:	e394                	sd	a3,0(a5)
ffffffffc0202916:	0141                	addi	sp,sp,16
ffffffffc0202918:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020291a:	00003697          	auipc	a3,0x3
ffffffffc020291e:	1fe68693          	addi	a3,a3,510 # ffffffffc0205b18 <commands+0x1350>
ffffffffc0202922:	00002617          	auipc	a2,0x2
ffffffffc0202926:	5be60613          	addi	a2,a2,1470 # ffffffffc0204ee0 <commands+0x718>
ffffffffc020292a:	08300593          	li	a1,131
ffffffffc020292e:	00003517          	auipc	a0,0x3
ffffffffc0202932:	ed250513          	addi	a0,a0,-302 # ffffffffc0205800 <commands+0x1038>
ffffffffc0202936:	fccfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc020293a:	00003697          	auipc	a3,0x3
ffffffffc020293e:	1d668693          	addi	a3,a3,470 # ffffffffc0205b10 <commands+0x1348>
ffffffffc0202942:	00002617          	auipc	a2,0x2
ffffffffc0202946:	59e60613          	addi	a2,a2,1438 # ffffffffc0204ee0 <commands+0x718>
ffffffffc020294a:	08000593          	li	a1,128
ffffffffc020294e:	00003517          	auipc	a0,0x3
ffffffffc0202952:	eb250513          	addi	a0,a0,-334 # ffffffffc0205800 <commands+0x1038>
ffffffffc0202956:	facfd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc020295a <default_alloc_pages>:
    assert(n > 0);
ffffffffc020295a:	c959                	beqz	a0,ffffffffc02029f0 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020295c:	0000e597          	auipc	a1,0xe
ffffffffc0202960:	78458593          	addi	a1,a1,1924 # ffffffffc02110e0 <free_area>
ffffffffc0202964:	0105a803          	lw	a6,16(a1)
ffffffffc0202968:	862a                	mv	a2,a0
ffffffffc020296a:	02081793          	slli	a5,a6,0x20
ffffffffc020296e:	9381                	srli	a5,a5,0x20
ffffffffc0202970:	00a7ee63          	bltu	a5,a0,ffffffffc020298c <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0202974:	87ae                	mv	a5,a1
ffffffffc0202976:	a801                	j	ffffffffc0202986 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0202978:	ff87a703          	lw	a4,-8(a5)
ffffffffc020297c:	02071693          	slli	a3,a4,0x20
ffffffffc0202980:	9281                	srli	a3,a3,0x20
ffffffffc0202982:	00c6f763          	bgeu	a3,a2,ffffffffc0202990 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0202986:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202988:	feb798e3          	bne	a5,a1,ffffffffc0202978 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020298c:	4501                	li	a0,0
}
ffffffffc020298e:	8082                	ret
    return listelm->prev;
ffffffffc0202990:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202994:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0202998:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc020299c:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc02029a0:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02029a4:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02029a8:	02d67b63          	bgeu	a2,a3,ffffffffc02029de <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc02029ac:	00361693          	slli	a3,a2,0x3
ffffffffc02029b0:	96b2                	add	a3,a3,a2
ffffffffc02029b2:	068e                	slli	a3,a3,0x3
ffffffffc02029b4:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02029b6:	41c7073b          	subw	a4,a4,t3
ffffffffc02029ba:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02029bc:	00868613          	addi	a2,a3,8
ffffffffc02029c0:	4709                	li	a4,2
ffffffffc02029c2:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02029c6:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02029ca:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc02029ce:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02029d2:	e310                	sd	a2,0(a4)
ffffffffc02029d4:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02029d8:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc02029da:	0316b023          	sd	a7,32(a3)
ffffffffc02029de:	41c8083b          	subw	a6,a6,t3
ffffffffc02029e2:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02029e6:	5775                	li	a4,-3
ffffffffc02029e8:	17a1                	addi	a5,a5,-24
ffffffffc02029ea:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02029ee:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02029f0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02029f2:	00003697          	auipc	a3,0x3
ffffffffc02029f6:	11e68693          	addi	a3,a3,286 # ffffffffc0205b10 <commands+0x1348>
ffffffffc02029fa:	00002617          	auipc	a2,0x2
ffffffffc02029fe:	4e660613          	addi	a2,a2,1254 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202a02:	06200593          	li	a1,98
ffffffffc0202a06:	00003517          	auipc	a0,0x3
ffffffffc0202a0a:	dfa50513          	addi	a0,a0,-518 # ffffffffc0205800 <commands+0x1038>
default_alloc_pages(size_t n) {
ffffffffc0202a0e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202a10:	ef2fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202a14 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0202a14:	1141                	addi	sp,sp,-16
ffffffffc0202a16:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202a18:	c9e1                	beqz	a1,ffffffffc0202ae8 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0202a1a:	00359693          	slli	a3,a1,0x3
ffffffffc0202a1e:	96ae                	add	a3,a3,a1
ffffffffc0202a20:	068e                	slli	a3,a3,0x3
ffffffffc0202a22:	96aa                	add	a3,a3,a0
ffffffffc0202a24:	87aa                	mv	a5,a0
ffffffffc0202a26:	00d50f63          	beq	a0,a3,ffffffffc0202a44 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202a2a:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0202a2c:	8b05                	andi	a4,a4,1
ffffffffc0202a2e:	cf49                	beqz	a4,ffffffffc0202ac8 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0202a30:	0007ac23          	sw	zero,24(a5)
ffffffffc0202a34:	0007b423          	sd	zero,8(a5)
ffffffffc0202a38:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202a3c:	04878793          	addi	a5,a5,72
ffffffffc0202a40:	fed795e3          	bne	a5,a3,ffffffffc0202a2a <default_init_memmap+0x16>
    base->property = n;
ffffffffc0202a44:	2581                	sext.w	a1,a1
ffffffffc0202a46:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202a48:	4789                	li	a5,2
ffffffffc0202a4a:	00850713          	addi	a4,a0,8
ffffffffc0202a4e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0202a52:	0000e697          	auipc	a3,0xe
ffffffffc0202a56:	68e68693          	addi	a3,a3,1678 # ffffffffc02110e0 <free_area>
ffffffffc0202a5a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202a5c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202a5e:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0202a62:	9db9                	addw	a1,a1,a4
ffffffffc0202a64:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202a66:	04d78a63          	beq	a5,a3,ffffffffc0202aba <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0202a6a:	fe078713          	addi	a4,a5,-32
ffffffffc0202a6e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202a72:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202a74:	00e56a63          	bltu	a0,a4,ffffffffc0202a88 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc0202a78:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202a7a:	02d70263          	beq	a4,a3,ffffffffc0202a9e <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0202a7e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202a80:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0202a84:	fee57ae3          	bgeu	a0,a4,ffffffffc0202a78 <default_init_memmap+0x64>
ffffffffc0202a88:	c199                	beqz	a1,ffffffffc0202a8e <default_init_memmap+0x7a>
ffffffffc0202a8a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202a8e:	6398                	ld	a4,0(a5)
}
ffffffffc0202a90:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202a92:	e390                	sd	a2,0(a5)
ffffffffc0202a94:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202a96:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202a98:	f118                	sd	a4,32(a0)
ffffffffc0202a9a:	0141                	addi	sp,sp,16
ffffffffc0202a9c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202a9e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202aa0:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0202aa2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202aa4:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202aa6:	00d70663          	beq	a4,a3,ffffffffc0202ab2 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc0202aaa:	8832                	mv	a6,a2
ffffffffc0202aac:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0202aae:	87ba                	mv	a5,a4
ffffffffc0202ab0:	bfc1                	j	ffffffffc0202a80 <default_init_memmap+0x6c>
}
ffffffffc0202ab2:	60a2                	ld	ra,8(sp)
ffffffffc0202ab4:	e290                	sd	a2,0(a3)
ffffffffc0202ab6:	0141                	addi	sp,sp,16
ffffffffc0202ab8:	8082                	ret
ffffffffc0202aba:	60a2                	ld	ra,8(sp)
ffffffffc0202abc:	e390                	sd	a2,0(a5)
ffffffffc0202abe:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202ac0:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202ac2:	f11c                	sd	a5,32(a0)
ffffffffc0202ac4:	0141                	addi	sp,sp,16
ffffffffc0202ac6:	8082                	ret
        assert(PageReserved(p));
ffffffffc0202ac8:	00003697          	auipc	a3,0x3
ffffffffc0202acc:	07868693          	addi	a3,a3,120 # ffffffffc0205b40 <commands+0x1378>
ffffffffc0202ad0:	00002617          	auipc	a2,0x2
ffffffffc0202ad4:	41060613          	addi	a2,a2,1040 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202ad8:	04900593          	li	a1,73
ffffffffc0202adc:	00003517          	auipc	a0,0x3
ffffffffc0202ae0:	d2450513          	addi	a0,a0,-732 # ffffffffc0205800 <commands+0x1038>
ffffffffc0202ae4:	e1efd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc0202ae8:	00003697          	auipc	a3,0x3
ffffffffc0202aec:	02868693          	addi	a3,a3,40 # ffffffffc0205b10 <commands+0x1348>
ffffffffc0202af0:	00002617          	auipc	a2,0x2
ffffffffc0202af4:	3f060613          	addi	a2,a2,1008 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0202af8:	04600593          	li	a1,70
ffffffffc0202afc:	00003517          	auipc	a0,0x3
ffffffffc0202b00:	d0450513          	addi	a0,a0,-764 # ffffffffc0205800 <commands+0x1038>
ffffffffc0202b04:	dfefd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202b08 <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0202b08:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202b0a:	00003617          	auipc	a2,0x3
ffffffffc0202b0e:	81660613          	addi	a2,a2,-2026 # ffffffffc0205320 <commands+0xb58>
ffffffffc0202b12:	06600593          	li	a1,102
ffffffffc0202b16:	00003517          	auipc	a0,0x3
ffffffffc0202b1a:	82a50513          	addi	a0,a0,-2006 # ffffffffc0205340 <commands+0xb78>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0202b1e:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202b20:	de2fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202b24 <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0202b24:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0202b26:	00003617          	auipc	a2,0x3
ffffffffc0202b2a:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0205650 <commands+0xe88>
ffffffffc0202b2e:	07100593          	li	a1,113
ffffffffc0202b32:	00003517          	auipc	a0,0x3
ffffffffc0202b36:	80e50513          	addi	a0,a0,-2034 # ffffffffc0205340 <commands+0xb78>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0202b3a:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0202b3c:	dc6fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202b40 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0202b40:	7139                	addi	sp,sp,-64
ffffffffc0202b42:	f426                	sd	s1,40(sp)
ffffffffc0202b44:	f04a                	sd	s2,32(sp)
ffffffffc0202b46:	ec4e                	sd	s3,24(sp)
ffffffffc0202b48:	e852                	sd	s4,16(sp)
ffffffffc0202b4a:	e456                	sd	s5,8(sp)
ffffffffc0202b4c:	e05a                	sd	s6,0(sp)
ffffffffc0202b4e:	fc06                	sd	ra,56(sp)
ffffffffc0202b50:	f822                	sd	s0,48(sp)
ffffffffc0202b52:	84aa                	mv	s1,a0
ffffffffc0202b54:	0000f917          	auipc	s2,0xf
ffffffffc0202b58:	a0c90913          	addi	s2,s2,-1524 # ffffffffc0211560 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202b5c:	4a05                	li	s4,1
ffffffffc0202b5e:	0000fa97          	auipc	s5,0xf
ffffffffc0202b62:	9daa8a93          	addi	s5,s5,-1574 # ffffffffc0211538 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0202b66:	0005099b          	sext.w	s3,a0
ffffffffc0202b6a:	0000fb17          	auipc	s6,0xf
ffffffffc0202b6e:	9aeb0b13          	addi	s6,s6,-1618 # ffffffffc0211518 <check_mm_struct>
ffffffffc0202b72:	a01d                	j	ffffffffc0202b98 <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202b74:	00093783          	ld	a5,0(s2)
ffffffffc0202b78:	6f9c                	ld	a5,24(a5)
ffffffffc0202b7a:	9782                	jalr	a5
ffffffffc0202b7c:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0202b7e:	4601                	li	a2,0
ffffffffc0202b80:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202b82:	ec0d                	bnez	s0,ffffffffc0202bbc <alloc_pages+0x7c>
ffffffffc0202b84:	029a6c63          	bltu	s4,s1,ffffffffc0202bbc <alloc_pages+0x7c>
ffffffffc0202b88:	000aa783          	lw	a5,0(s5)
ffffffffc0202b8c:	2781                	sext.w	a5,a5
ffffffffc0202b8e:	c79d                	beqz	a5,ffffffffc0202bbc <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202b90:	000b3503          	ld	a0,0(s6)
ffffffffc0202b94:	b0eff0ef          	jal	ra,ffffffffc0201ea2 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202b98:	100027f3          	csrr	a5,sstatus
ffffffffc0202b9c:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202b9e:	8526                	mv	a0,s1
ffffffffc0202ba0:	dbf1                	beqz	a5,ffffffffc0202b74 <alloc_pages+0x34>
        intr_disable();
ffffffffc0202ba2:	94dfd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202ba6:	00093783          	ld	a5,0(s2)
ffffffffc0202baa:	8526                	mv	a0,s1
ffffffffc0202bac:	6f9c                	ld	a5,24(a5)
ffffffffc0202bae:	9782                	jalr	a5
ffffffffc0202bb0:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202bb2:	937fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202bb6:	4601                	li	a2,0
ffffffffc0202bb8:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202bba:	d469                	beqz	s0,ffffffffc0202b84 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0202bbc:	70e2                	ld	ra,56(sp)
ffffffffc0202bbe:	8522                	mv	a0,s0
ffffffffc0202bc0:	7442                	ld	s0,48(sp)
ffffffffc0202bc2:	74a2                	ld	s1,40(sp)
ffffffffc0202bc4:	7902                	ld	s2,32(sp)
ffffffffc0202bc6:	69e2                	ld	s3,24(sp)
ffffffffc0202bc8:	6a42                	ld	s4,16(sp)
ffffffffc0202bca:	6aa2                	ld	s5,8(sp)
ffffffffc0202bcc:	6b02                	ld	s6,0(sp)
ffffffffc0202bce:	6121                	addi	sp,sp,64
ffffffffc0202bd0:	8082                	ret

ffffffffc0202bd2 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202bd2:	100027f3          	csrr	a5,sstatus
ffffffffc0202bd6:	8b89                	andi	a5,a5,2
ffffffffc0202bd8:	e799                	bnez	a5,ffffffffc0202be6 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0202bda:	0000f797          	auipc	a5,0xf
ffffffffc0202bde:	9867b783          	ld	a5,-1658(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202be2:	739c                	ld	a5,32(a5)
ffffffffc0202be4:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0202be6:	1101                	addi	sp,sp,-32
ffffffffc0202be8:	ec06                	sd	ra,24(sp)
ffffffffc0202bea:	e822                	sd	s0,16(sp)
ffffffffc0202bec:	e426                	sd	s1,8(sp)
ffffffffc0202bee:	842a                	mv	s0,a0
ffffffffc0202bf0:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202bf2:	8fdfd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202bf6:	0000f797          	auipc	a5,0xf
ffffffffc0202bfa:	96a7b783          	ld	a5,-1686(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202bfe:	739c                	ld	a5,32(a5)
ffffffffc0202c00:	85a6                	mv	a1,s1
ffffffffc0202c02:	8522                	mv	a0,s0
ffffffffc0202c04:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0202c06:	6442                	ld	s0,16(sp)
ffffffffc0202c08:	60e2                	ld	ra,24(sp)
ffffffffc0202c0a:	64a2                	ld	s1,8(sp)
ffffffffc0202c0c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202c0e:	8dbfd06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc0202c12 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202c12:	100027f3          	csrr	a5,sstatus
ffffffffc0202c16:	8b89                	andi	a5,a5,2
ffffffffc0202c18:	e799                	bnez	a5,ffffffffc0202c26 <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202c1a:	0000f797          	auipc	a5,0xf
ffffffffc0202c1e:	9467b783          	ld	a5,-1722(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202c22:	779c                	ld	a5,40(a5)
ffffffffc0202c24:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0202c26:	1141                	addi	sp,sp,-16
ffffffffc0202c28:	e406                	sd	ra,8(sp)
ffffffffc0202c2a:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0202c2c:	8c3fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202c30:	0000f797          	auipc	a5,0xf
ffffffffc0202c34:	9307b783          	ld	a5,-1744(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202c38:	779c                	ld	a5,40(a5)
ffffffffc0202c3a:	9782                	jalr	a5
ffffffffc0202c3c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202c3e:	8abfd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202c42:	60a2                	ld	ra,8(sp)
ffffffffc0202c44:	8522                	mv	a0,s0
ffffffffc0202c46:	6402                	ld	s0,0(sp)
ffffffffc0202c48:	0141                	addi	sp,sp,16
ffffffffc0202c4a:	8082                	ret

ffffffffc0202c4c <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202c4c:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202c50:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202c54:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202c56:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202c58:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202c5a:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202c5e:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202c60:	f84a                	sd	s2,48(sp)
ffffffffc0202c62:	f44e                	sd	s3,40(sp)
ffffffffc0202c64:	f052                	sd	s4,32(sp)
ffffffffc0202c66:	e486                	sd	ra,72(sp)
ffffffffc0202c68:	e0a2                	sd	s0,64(sp)
ffffffffc0202c6a:	ec56                	sd	s5,24(sp)
ffffffffc0202c6c:	e85a                	sd	s6,16(sp)
ffffffffc0202c6e:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202c70:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202c74:	892e                	mv	s2,a1
ffffffffc0202c76:	8a32                	mv	s4,a2
ffffffffc0202c78:	0000f997          	auipc	s3,0xf
ffffffffc0202c7c:	8d898993          	addi	s3,s3,-1832 # ffffffffc0211550 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202c80:	efb5                	bnez	a5,ffffffffc0202cfc <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202c82:	14060c63          	beqz	a2,ffffffffc0202dda <get_pte+0x18e>
ffffffffc0202c86:	4505                	li	a0,1
ffffffffc0202c88:	eb9ff0ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc0202c8c:	842a                	mv	s0,a0
ffffffffc0202c8e:	14050663          	beqz	a0,ffffffffc0202dda <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c92:	0000fb97          	auipc	s7,0xf
ffffffffc0202c96:	8c6b8b93          	addi	s7,s7,-1850 # ffffffffc0211558 <pages>
ffffffffc0202c9a:	000bb503          	ld	a0,0(s7)
ffffffffc0202c9e:	00003b17          	auipc	s6,0x3
ffffffffc0202ca2:	79ab3b03          	ld	s6,1946(s6) # ffffffffc0206438 <error_string+0x38>
ffffffffc0202ca6:	00080ab7          	lui	s5,0x80
ffffffffc0202caa:	40a40533          	sub	a0,s0,a0
ffffffffc0202cae:	850d                	srai	a0,a0,0x3
ffffffffc0202cb0:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202cb4:	0000f997          	auipc	s3,0xf
ffffffffc0202cb8:	89c98993          	addi	s3,s3,-1892 # ffffffffc0211550 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202cbc:	4785                	li	a5,1
ffffffffc0202cbe:	0009b703          	ld	a4,0(s3)
ffffffffc0202cc2:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202cc4:	9556                	add	a0,a0,s5
ffffffffc0202cc6:	00c51793          	slli	a5,a0,0xc
ffffffffc0202cca:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ccc:	0532                	slli	a0,a0,0xc
ffffffffc0202cce:	14e7fd63          	bgeu	a5,a4,ffffffffc0202e28 <get_pte+0x1dc>
ffffffffc0202cd2:	0000f797          	auipc	a5,0xf
ffffffffc0202cd6:	8967b783          	ld	a5,-1898(a5) # ffffffffc0211568 <va_pa_offset>
ffffffffc0202cda:	6605                	lui	a2,0x1
ffffffffc0202cdc:	4581                	li	a1,0
ffffffffc0202cde:	953e                	add	a0,a0,a5
ffffffffc0202ce0:	3a2010ef          	jal	ra,ffffffffc0204082 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202ce4:	000bb683          	ld	a3,0(s7)
ffffffffc0202ce8:	40d406b3          	sub	a3,s0,a3
ffffffffc0202cec:	868d                	srai	a3,a3,0x3
ffffffffc0202cee:	036686b3          	mul	a3,a3,s6
ffffffffc0202cf2:	96d6                	add	a3,a3,s5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202cf4:	06aa                	slli	a3,a3,0xa
ffffffffc0202cf6:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202cfa:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202cfc:	77fd                	lui	a5,0xfffff
ffffffffc0202cfe:	068a                	slli	a3,a3,0x2
ffffffffc0202d00:	0009b703          	ld	a4,0(s3)
ffffffffc0202d04:	8efd                	and	a3,a3,a5
ffffffffc0202d06:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202d0a:	0ce7fa63          	bgeu	a5,a4,ffffffffc0202dde <get_pte+0x192>
ffffffffc0202d0e:	0000fa97          	auipc	s5,0xf
ffffffffc0202d12:	85aa8a93          	addi	s5,s5,-1958 # ffffffffc0211568 <va_pa_offset>
ffffffffc0202d16:	000ab403          	ld	s0,0(s5)
ffffffffc0202d1a:	01595793          	srli	a5,s2,0x15
ffffffffc0202d1e:	1ff7f793          	andi	a5,a5,511
ffffffffc0202d22:	96a2                	add	a3,a3,s0
ffffffffc0202d24:	00379413          	slli	s0,a5,0x3
ffffffffc0202d28:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0202d2a:	6014                	ld	a3,0(s0)
ffffffffc0202d2c:	0016f793          	andi	a5,a3,1
ffffffffc0202d30:	ebad                	bnez	a5,ffffffffc0202da2 <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202d32:	0a0a0463          	beqz	s4,ffffffffc0202dda <get_pte+0x18e>
ffffffffc0202d36:	4505                	li	a0,1
ffffffffc0202d38:	e09ff0ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc0202d3c:	84aa                	mv	s1,a0
ffffffffc0202d3e:	cd51                	beqz	a0,ffffffffc0202dda <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202d40:	0000fb97          	auipc	s7,0xf
ffffffffc0202d44:	818b8b93          	addi	s7,s7,-2024 # ffffffffc0211558 <pages>
ffffffffc0202d48:	000bb503          	ld	a0,0(s7)
ffffffffc0202d4c:	00003b17          	auipc	s6,0x3
ffffffffc0202d50:	6ecb3b03          	ld	s6,1772(s6) # ffffffffc0206438 <error_string+0x38>
ffffffffc0202d54:	00080a37          	lui	s4,0x80
ffffffffc0202d58:	40a48533          	sub	a0,s1,a0
ffffffffc0202d5c:	850d                	srai	a0,a0,0x3
ffffffffc0202d5e:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202d62:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202d64:	0009b703          	ld	a4,0(s3)
ffffffffc0202d68:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202d6a:	9552                	add	a0,a0,s4
ffffffffc0202d6c:	00c51793          	slli	a5,a0,0xc
ffffffffc0202d70:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d72:	0532                	slli	a0,a0,0xc
ffffffffc0202d74:	08e7fd63          	bgeu	a5,a4,ffffffffc0202e0e <get_pte+0x1c2>
ffffffffc0202d78:	000ab783          	ld	a5,0(s5)
ffffffffc0202d7c:	6605                	lui	a2,0x1
ffffffffc0202d7e:	4581                	li	a1,0
ffffffffc0202d80:	953e                	add	a0,a0,a5
ffffffffc0202d82:	300010ef          	jal	ra,ffffffffc0204082 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202d86:	000bb683          	ld	a3,0(s7)
ffffffffc0202d8a:	40d486b3          	sub	a3,s1,a3
ffffffffc0202d8e:	868d                	srai	a3,a3,0x3
ffffffffc0202d90:	036686b3          	mul	a3,a3,s6
ffffffffc0202d94:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202d96:	06aa                	slli	a3,a3,0xa
ffffffffc0202d98:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202d9c:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202d9e:	0009b703          	ld	a4,0(s3)
ffffffffc0202da2:	068a                	slli	a3,a3,0x2
ffffffffc0202da4:	757d                	lui	a0,0xfffff
ffffffffc0202da6:	8ee9                	and	a3,a3,a0
ffffffffc0202da8:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202dac:	04e7f563          	bgeu	a5,a4,ffffffffc0202df6 <get_pte+0x1aa>
ffffffffc0202db0:	000ab503          	ld	a0,0(s5)
ffffffffc0202db4:	00c95913          	srli	s2,s2,0xc
ffffffffc0202db8:	1ff97913          	andi	s2,s2,511
ffffffffc0202dbc:	96aa                	add	a3,a3,a0
ffffffffc0202dbe:	00391513          	slli	a0,s2,0x3
ffffffffc0202dc2:	9536                	add	a0,a0,a3
}
ffffffffc0202dc4:	60a6                	ld	ra,72(sp)
ffffffffc0202dc6:	6406                	ld	s0,64(sp)
ffffffffc0202dc8:	74e2                	ld	s1,56(sp)
ffffffffc0202dca:	7942                	ld	s2,48(sp)
ffffffffc0202dcc:	79a2                	ld	s3,40(sp)
ffffffffc0202dce:	7a02                	ld	s4,32(sp)
ffffffffc0202dd0:	6ae2                	ld	s5,24(sp)
ffffffffc0202dd2:	6b42                	ld	s6,16(sp)
ffffffffc0202dd4:	6ba2                	ld	s7,8(sp)
ffffffffc0202dd6:	6161                	addi	sp,sp,80
ffffffffc0202dd8:	8082                	ret
            return NULL;
ffffffffc0202dda:	4501                	li	a0,0
ffffffffc0202ddc:	b7e5                	j	ffffffffc0202dc4 <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202dde:	00003617          	auipc	a2,0x3
ffffffffc0202de2:	dc260613          	addi	a2,a2,-574 # ffffffffc0205ba0 <default_pmm_manager+0x38>
ffffffffc0202de6:	10d00593          	li	a1,269
ffffffffc0202dea:	00003517          	auipc	a0,0x3
ffffffffc0202dee:	dde50513          	addi	a0,a0,-546 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0202df2:	b10fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202df6:	00003617          	auipc	a2,0x3
ffffffffc0202dfa:	daa60613          	addi	a2,a2,-598 # ffffffffc0205ba0 <default_pmm_manager+0x38>
ffffffffc0202dfe:	11a00593          	li	a1,282
ffffffffc0202e02:	00003517          	auipc	a0,0x3
ffffffffc0202e06:	dc650513          	addi	a0,a0,-570 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0202e0a:	af8fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202e0e:	86aa                	mv	a3,a0
ffffffffc0202e10:	00003617          	auipc	a2,0x3
ffffffffc0202e14:	d9060613          	addi	a2,a2,-624 # ffffffffc0205ba0 <default_pmm_manager+0x38>
ffffffffc0202e18:	11600593          	li	a1,278
ffffffffc0202e1c:	00003517          	auipc	a0,0x3
ffffffffc0202e20:	dac50513          	addi	a0,a0,-596 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0202e24:	adefd0ef          	jal	ra,ffffffffc0200102 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202e28:	86aa                	mv	a3,a0
ffffffffc0202e2a:	00003617          	auipc	a2,0x3
ffffffffc0202e2e:	d7660613          	addi	a2,a2,-650 # ffffffffc0205ba0 <default_pmm_manager+0x38>
ffffffffc0202e32:	10a00593          	li	a1,266
ffffffffc0202e36:	00003517          	auipc	a0,0x3
ffffffffc0202e3a:	d9250513          	addi	a0,a0,-622 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0202e3e:	ac4fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202e42 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
// 使用PDT pgdir获取线性地址la的相关Page结构
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202e42:	1141                	addi	sp,sp,-16
ffffffffc0202e44:	e022                	sd	s0,0(sp)
ffffffffc0202e46:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202e48:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202e4a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202e4c:	e01ff0ef          	jal	ra,ffffffffc0202c4c <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202e50:	c011                	beqz	s0,ffffffffc0202e54 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202e52:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202e54:	c511                	beqz	a0,ffffffffc0202e60 <get_page+0x1e>
ffffffffc0202e56:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202e58:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202e5a:	0017f713          	andi	a4,a5,1
ffffffffc0202e5e:	e709                	bnez	a4,ffffffffc0202e68 <get_page+0x26>
}
ffffffffc0202e60:	60a2                	ld	ra,8(sp)
ffffffffc0202e62:	6402                	ld	s0,0(sp)
ffffffffc0202e64:	0141                	addi	sp,sp,16
ffffffffc0202e66:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202e68:	078a                	slli	a5,a5,0x2
ffffffffc0202e6a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e6c:	0000e717          	auipc	a4,0xe
ffffffffc0202e70:	6e473703          	ld	a4,1764(a4) # ffffffffc0211550 <npage>
ffffffffc0202e74:	02e7f263          	bgeu	a5,a4,ffffffffc0202e98 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e78:	fff80537          	lui	a0,0xfff80
ffffffffc0202e7c:	97aa                	add	a5,a5,a0
ffffffffc0202e7e:	60a2                	ld	ra,8(sp)
ffffffffc0202e80:	6402                	ld	s0,0(sp)
ffffffffc0202e82:	00379513          	slli	a0,a5,0x3
ffffffffc0202e86:	97aa                	add	a5,a5,a0
ffffffffc0202e88:	078e                	slli	a5,a5,0x3
ffffffffc0202e8a:	0000e517          	auipc	a0,0xe
ffffffffc0202e8e:	6ce53503          	ld	a0,1742(a0) # ffffffffc0211558 <pages>
ffffffffc0202e92:	953e                	add	a0,a0,a5
ffffffffc0202e94:	0141                	addi	sp,sp,16
ffffffffc0202e96:	8082                	ret
ffffffffc0202e98:	c71ff0ef          	jal	ra,ffffffffc0202b08 <pa2page.part.0>

ffffffffc0202e9c <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202e9c:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202e9e:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202ea0:	ec06                	sd	ra,24(sp)
ffffffffc0202ea2:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202ea4:	da9ff0ef          	jal	ra,ffffffffc0202c4c <get_pte>
    if (ptep != NULL) {
ffffffffc0202ea8:	c511                	beqz	a0,ffffffffc0202eb4 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202eaa:	611c                	ld	a5,0(a0)
ffffffffc0202eac:	842a                	mv	s0,a0
ffffffffc0202eae:	0017f713          	andi	a4,a5,1
ffffffffc0202eb2:	e709                	bnez	a4,ffffffffc0202ebc <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0202eb4:	60e2                	ld	ra,24(sp)
ffffffffc0202eb6:	6442                	ld	s0,16(sp)
ffffffffc0202eb8:	6105                	addi	sp,sp,32
ffffffffc0202eba:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202ebc:	078a                	slli	a5,a5,0x2
ffffffffc0202ebe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ec0:	0000e717          	auipc	a4,0xe
ffffffffc0202ec4:	69073703          	ld	a4,1680(a4) # ffffffffc0211550 <npage>
ffffffffc0202ec8:	06e7f563          	bgeu	a5,a4,ffffffffc0202f32 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ecc:	fff80737          	lui	a4,0xfff80
ffffffffc0202ed0:	97ba                	add	a5,a5,a4
ffffffffc0202ed2:	00379513          	slli	a0,a5,0x3
ffffffffc0202ed6:	97aa                	add	a5,a5,a0
ffffffffc0202ed8:	078e                	slli	a5,a5,0x3
ffffffffc0202eda:	0000e517          	auipc	a0,0xe
ffffffffc0202ede:	67e53503          	ld	a0,1662(a0) # ffffffffc0211558 <pages>
ffffffffc0202ee2:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202ee4:	411c                	lw	a5,0(a0)
ffffffffc0202ee6:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202eea:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202eec:	cb09                	beqz	a4,ffffffffc0202efe <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202eee:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202ef2:	12000073          	sfence.vma
}
ffffffffc0202ef6:	60e2                	ld	ra,24(sp)
ffffffffc0202ef8:	6442                	ld	s0,16(sp)
ffffffffc0202efa:	6105                	addi	sp,sp,32
ffffffffc0202efc:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202efe:	100027f3          	csrr	a5,sstatus
ffffffffc0202f02:	8b89                	andi	a5,a5,2
ffffffffc0202f04:	eb89                	bnez	a5,ffffffffc0202f16 <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202f06:	0000e797          	auipc	a5,0xe
ffffffffc0202f0a:	65a7b783          	ld	a5,1626(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202f0e:	739c                	ld	a5,32(a5)
ffffffffc0202f10:	4585                	li	a1,1
ffffffffc0202f12:	9782                	jalr	a5
    if (flag) {
ffffffffc0202f14:	bfe9                	j	ffffffffc0202eee <page_remove+0x52>
        intr_disable();
ffffffffc0202f16:	e42a                	sd	a0,8(sp)
ffffffffc0202f18:	dd6fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202f1c:	0000e797          	auipc	a5,0xe
ffffffffc0202f20:	6447b783          	ld	a5,1604(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202f24:	739c                	ld	a5,32(a5)
ffffffffc0202f26:	6522                	ld	a0,8(sp)
ffffffffc0202f28:	4585                	li	a1,1
ffffffffc0202f2a:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f2c:	dbcfd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202f30:	bf7d                	j	ffffffffc0202eee <page_remove+0x52>
ffffffffc0202f32:	bd7ff0ef          	jal	ra,ffffffffc0202b08 <pa2page.part.0>

ffffffffc0202f36 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202f36:	7179                	addi	sp,sp,-48
ffffffffc0202f38:	87b2                	mv	a5,a2
ffffffffc0202f3a:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202f3c:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202f3e:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202f40:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202f42:	ec26                	sd	s1,24(sp)
ffffffffc0202f44:	f406                	sd	ra,40(sp)
ffffffffc0202f46:	e84a                	sd	s2,16(sp)
ffffffffc0202f48:	e44e                	sd	s3,8(sp)
ffffffffc0202f4a:	e052                	sd	s4,0(sp)
ffffffffc0202f4c:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202f4e:	cffff0ef          	jal	ra,ffffffffc0202c4c <get_pte>
    if (ptep == NULL) {
ffffffffc0202f52:	cd71                	beqz	a0,ffffffffc020302e <page_insert+0xf8>
    page->ref += 1;
ffffffffc0202f54:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0202f56:	611c                	ld	a5,0(a0)
ffffffffc0202f58:	89aa                	mv	s3,a0
ffffffffc0202f5a:	0016871b          	addiw	a4,a3,1
ffffffffc0202f5e:	c018                	sw	a4,0(s0)
ffffffffc0202f60:	0017f713          	andi	a4,a5,1
ffffffffc0202f64:	e331                	bnez	a4,ffffffffc0202fa8 <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202f66:	0000e797          	auipc	a5,0xe
ffffffffc0202f6a:	5f27b783          	ld	a5,1522(a5) # ffffffffc0211558 <pages>
ffffffffc0202f6e:	40f407b3          	sub	a5,s0,a5
ffffffffc0202f72:	878d                	srai	a5,a5,0x3
ffffffffc0202f74:	00003417          	auipc	s0,0x3
ffffffffc0202f78:	4c443403          	ld	s0,1220(s0) # ffffffffc0206438 <error_string+0x38>
ffffffffc0202f7c:	028787b3          	mul	a5,a5,s0
ffffffffc0202f80:	00080437          	lui	s0,0x80
ffffffffc0202f84:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202f86:	07aa                	slli	a5,a5,0xa
ffffffffc0202f88:	8cdd                	or	s1,s1,a5
ffffffffc0202f8a:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202f8e:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202f92:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0202f96:	4501                	li	a0,0
}
ffffffffc0202f98:	70a2                	ld	ra,40(sp)
ffffffffc0202f9a:	7402                	ld	s0,32(sp)
ffffffffc0202f9c:	64e2                	ld	s1,24(sp)
ffffffffc0202f9e:	6942                	ld	s2,16(sp)
ffffffffc0202fa0:	69a2                	ld	s3,8(sp)
ffffffffc0202fa2:	6a02                	ld	s4,0(sp)
ffffffffc0202fa4:	6145                	addi	sp,sp,48
ffffffffc0202fa6:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202fa8:	00279713          	slli	a4,a5,0x2
ffffffffc0202fac:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202fae:	0000e797          	auipc	a5,0xe
ffffffffc0202fb2:	5a27b783          	ld	a5,1442(a5) # ffffffffc0211550 <npage>
ffffffffc0202fb6:	06f77e63          	bgeu	a4,a5,ffffffffc0203032 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0202fba:	fff807b7          	lui	a5,0xfff80
ffffffffc0202fbe:	973e                	add	a4,a4,a5
ffffffffc0202fc0:	0000ea17          	auipc	s4,0xe
ffffffffc0202fc4:	598a0a13          	addi	s4,s4,1432 # ffffffffc0211558 <pages>
ffffffffc0202fc8:	000a3783          	ld	a5,0(s4)
ffffffffc0202fcc:	00371913          	slli	s2,a4,0x3
ffffffffc0202fd0:	993a                	add	s2,s2,a4
ffffffffc0202fd2:	090e                	slli	s2,s2,0x3
ffffffffc0202fd4:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0202fd6:	03240063          	beq	s0,s2,ffffffffc0202ff6 <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0202fda:	00092783          	lw	a5,0(s2)
ffffffffc0202fde:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202fe2:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0202fe6:	cb11                	beqz	a4,ffffffffc0202ffa <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202fe8:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202fec:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202ff0:	000a3783          	ld	a5,0(s4)
}
ffffffffc0202ff4:	bfad                	j	ffffffffc0202f6e <page_insert+0x38>
    page->ref -= 1;
ffffffffc0202ff6:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202ff8:	bf9d                	j	ffffffffc0202f6e <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202ffa:	100027f3          	csrr	a5,sstatus
ffffffffc0202ffe:	8b89                	andi	a5,a5,2
ffffffffc0203000:	eb91                	bnez	a5,ffffffffc0203014 <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203002:	0000e797          	auipc	a5,0xe
ffffffffc0203006:	55e7b783          	ld	a5,1374(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc020300a:	739c                	ld	a5,32(a5)
ffffffffc020300c:	4585                	li	a1,1
ffffffffc020300e:	854a                	mv	a0,s2
ffffffffc0203010:	9782                	jalr	a5
    if (flag) {
ffffffffc0203012:	bfd9                	j	ffffffffc0202fe8 <page_insert+0xb2>
        intr_disable();
ffffffffc0203014:	cdafd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203018:	0000e797          	auipc	a5,0xe
ffffffffc020301c:	5487b783          	ld	a5,1352(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0203020:	739c                	ld	a5,32(a5)
ffffffffc0203022:	4585                	li	a1,1
ffffffffc0203024:	854a                	mv	a0,s2
ffffffffc0203026:	9782                	jalr	a5
        intr_enable();
ffffffffc0203028:	cc0fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020302c:	bf75                	j	ffffffffc0202fe8 <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc020302e:	5571                	li	a0,-4
ffffffffc0203030:	b7a5                	j	ffffffffc0202f98 <page_insert+0x62>
ffffffffc0203032:	ad7ff0ef          	jal	ra,ffffffffc0202b08 <pa2page.part.0>

ffffffffc0203036 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0203036:	00003797          	auipc	a5,0x3
ffffffffc020303a:	b3278793          	addi	a5,a5,-1230 # ffffffffc0205b68 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020303e:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0203040:	7159                	addi	sp,sp,-112
ffffffffc0203042:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203044:	00003517          	auipc	a0,0x3
ffffffffc0203048:	b9450513          	addi	a0,a0,-1132 # ffffffffc0205bd8 <default_pmm_manager+0x70>
    pmm_manager = &default_pmm_manager;
ffffffffc020304c:	0000eb97          	auipc	s7,0xe
ffffffffc0203050:	514b8b93          	addi	s7,s7,1300 # ffffffffc0211560 <pmm_manager>
void pmm_init(void) {
ffffffffc0203054:	f486                	sd	ra,104(sp)
ffffffffc0203056:	f0a2                	sd	s0,96(sp)
ffffffffc0203058:	eca6                	sd	s1,88(sp)
ffffffffc020305a:	e8ca                	sd	s2,80(sp)
ffffffffc020305c:	e4ce                	sd	s3,72(sp)
ffffffffc020305e:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0203060:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0203064:	e0d2                	sd	s4,64(sp)
ffffffffc0203066:	fc56                	sd	s5,56(sp)
ffffffffc0203068:	f062                	sd	s8,32(sp)
ffffffffc020306a:	ec66                	sd	s9,24(sp)
ffffffffc020306c:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020306e:	84cfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0203072:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0203076:	4445                	li	s0,17
ffffffffc0203078:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc020307c:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020307e:	0000e997          	auipc	s3,0xe
ffffffffc0203082:	4ea98993          	addi	s3,s3,1258 # ffffffffc0211568 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0203086:	0000e497          	auipc	s1,0xe
ffffffffc020308a:	4ca48493          	addi	s1,s1,1226 # ffffffffc0211550 <npage>
    pmm_manager->init();
ffffffffc020308e:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203090:	57f5                	li	a5,-3
ffffffffc0203092:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0203094:	07e006b7          	lui	a3,0x7e00
ffffffffc0203098:	01b41613          	slli	a2,s0,0x1b
ffffffffc020309c:	01591593          	slli	a1,s2,0x15
ffffffffc02030a0:	00003517          	auipc	a0,0x3
ffffffffc02030a4:	b5050513          	addi	a0,a0,-1200 # ffffffffc0205bf0 <default_pmm_manager+0x88>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02030a8:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc02030ac:	80efd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc02030b0:	00003517          	auipc	a0,0x3
ffffffffc02030b4:	b7050513          	addi	a0,a0,-1168 # ffffffffc0205c20 <default_pmm_manager+0xb8>
ffffffffc02030b8:	802fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02030bc:	01b41693          	slli	a3,s0,0x1b
ffffffffc02030c0:	16fd                	addi	a3,a3,-1
ffffffffc02030c2:	07e005b7          	lui	a1,0x7e00
ffffffffc02030c6:	01591613          	slli	a2,s2,0x15
ffffffffc02030ca:	00003517          	auipc	a0,0x3
ffffffffc02030ce:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0205c38 <default_pmm_manager+0xd0>
ffffffffc02030d2:	fe9fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02030d6:	777d                	lui	a4,0xfffff
ffffffffc02030d8:	0000f797          	auipc	a5,0xf
ffffffffc02030dc:	49778793          	addi	a5,a5,1175 # ffffffffc021256f <end+0xfff>
ffffffffc02030e0:	8ff9                	and	a5,a5,a4
ffffffffc02030e2:	0000eb17          	auipc	s6,0xe
ffffffffc02030e6:	476b0b13          	addi	s6,s6,1142 # ffffffffc0211558 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02030ea:	00088737          	lui	a4,0x88
ffffffffc02030ee:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02030f0:	00fb3023          	sd	a5,0(s6)
ffffffffc02030f4:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02030f6:	4701                	li	a4,0
ffffffffc02030f8:	4505                	li	a0,1
ffffffffc02030fa:	fff805b7          	lui	a1,0xfff80
ffffffffc02030fe:	a019                	j	ffffffffc0203104 <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0203100:	000b3783          	ld	a5,0(s6)
ffffffffc0203104:	97b6                	add	a5,a5,a3
ffffffffc0203106:	07a1                	addi	a5,a5,8
ffffffffc0203108:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020310c:	609c                	ld	a5,0(s1)
ffffffffc020310e:	0705                	addi	a4,a4,1
ffffffffc0203110:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0203114:	00b78633          	add	a2,a5,a1
ffffffffc0203118:	fec764e3          	bltu	a4,a2,ffffffffc0203100 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020311c:	000b3503          	ld	a0,0(s6)
ffffffffc0203120:	00379693          	slli	a3,a5,0x3
ffffffffc0203124:	96be                	add	a3,a3,a5
ffffffffc0203126:	fdc00737          	lui	a4,0xfdc00
ffffffffc020312a:	972a                	add	a4,a4,a0
ffffffffc020312c:	068e                	slli	a3,a3,0x3
ffffffffc020312e:	96ba                	add	a3,a3,a4
ffffffffc0203130:	c0200737          	lui	a4,0xc0200
ffffffffc0203134:	64e6e463          	bltu	a3,a4,ffffffffc020377c <pmm_init+0x746>
ffffffffc0203138:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc020313c:	4645                	li	a2,17
ffffffffc020313e:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203140:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0203142:	4ec6e263          	bltu	a3,a2,ffffffffc0203626 <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0203146:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020314a:	0000e917          	auipc	s2,0xe
ffffffffc020314e:	3fe90913          	addi	s2,s2,1022 # ffffffffc0211548 <boot_pgdir>
    pmm_manager->check();
ffffffffc0203152:	7b9c                	ld	a5,48(a5)
ffffffffc0203154:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0203156:	00003517          	auipc	a0,0x3
ffffffffc020315a:	b3250513          	addi	a0,a0,-1230 # ffffffffc0205c88 <default_pmm_manager+0x120>
ffffffffc020315e:	f5dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203162:	00006697          	auipc	a3,0x6
ffffffffc0203166:	e9e68693          	addi	a3,a3,-354 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc020316a:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020316e:	c02007b7          	lui	a5,0xc0200
ffffffffc0203172:	62f6e163          	bltu	a3,a5,ffffffffc0203794 <pmm_init+0x75e>
ffffffffc0203176:	0009b783          	ld	a5,0(s3)
ffffffffc020317a:	8e9d                	sub	a3,a3,a5
ffffffffc020317c:	0000e797          	auipc	a5,0xe
ffffffffc0203180:	3cd7b223          	sd	a3,964(a5) # ffffffffc0211540 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203184:	100027f3          	csrr	a5,sstatus
ffffffffc0203188:	8b89                	andi	a5,a5,2
ffffffffc020318a:	4c079763          	bnez	a5,ffffffffc0203658 <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020318e:	000bb783          	ld	a5,0(s7)
ffffffffc0203192:	779c                	ld	a5,40(a5)
ffffffffc0203194:	9782                	jalr	a5
ffffffffc0203196:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203198:	6098                	ld	a4,0(s1)
ffffffffc020319a:	c80007b7          	lui	a5,0xc8000
ffffffffc020319e:	83b1                	srli	a5,a5,0xc
ffffffffc02031a0:	62e7e663          	bltu	a5,a4,ffffffffc02037cc <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02031a4:	00093503          	ld	a0,0(s2)
ffffffffc02031a8:	60050263          	beqz	a0,ffffffffc02037ac <pmm_init+0x776>
ffffffffc02031ac:	03451793          	slli	a5,a0,0x34
ffffffffc02031b0:	5e079e63          	bnez	a5,ffffffffc02037ac <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02031b4:	4601                	li	a2,0
ffffffffc02031b6:	4581                	li	a1,0
ffffffffc02031b8:	c8bff0ef          	jal	ra,ffffffffc0202e42 <get_page>
ffffffffc02031bc:	66051a63          	bnez	a0,ffffffffc0203830 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02031c0:	4505                	li	a0,1
ffffffffc02031c2:	97fff0ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc02031c6:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02031c8:	00093503          	ld	a0,0(s2)
ffffffffc02031cc:	4681                	li	a3,0
ffffffffc02031ce:	4601                	li	a2,0
ffffffffc02031d0:	85d2                	mv	a1,s4
ffffffffc02031d2:	d65ff0ef          	jal	ra,ffffffffc0202f36 <page_insert>
ffffffffc02031d6:	62051d63          	bnez	a0,ffffffffc0203810 <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02031da:	00093503          	ld	a0,0(s2)
ffffffffc02031de:	4601                	li	a2,0
ffffffffc02031e0:	4581                	li	a1,0
ffffffffc02031e2:	a6bff0ef          	jal	ra,ffffffffc0202c4c <get_pte>
ffffffffc02031e6:	60050563          	beqz	a0,ffffffffc02037f0 <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc02031ea:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02031ec:	0017f713          	andi	a4,a5,1
ffffffffc02031f0:	5e070e63          	beqz	a4,ffffffffc02037ec <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc02031f4:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02031f6:	078a                	slli	a5,a5,0x2
ffffffffc02031f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031fa:	56c7ff63          	bgeu	a5,a2,ffffffffc0203778 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02031fe:	fff80737          	lui	a4,0xfff80
ffffffffc0203202:	97ba                	add	a5,a5,a4
ffffffffc0203204:	000b3683          	ld	a3,0(s6)
ffffffffc0203208:	00379713          	slli	a4,a5,0x3
ffffffffc020320c:	97ba                	add	a5,a5,a4
ffffffffc020320e:	078e                	slli	a5,a5,0x3
ffffffffc0203210:	97b6                	add	a5,a5,a3
ffffffffc0203212:	14fa18e3          	bne	s4,a5,ffffffffc0203b62 <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc0203216:	000a2703          	lw	a4,0(s4)
ffffffffc020321a:	4785                	li	a5,1
ffffffffc020321c:	16f71fe3          	bne	a4,a5,ffffffffc0203b9a <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203220:	00093503          	ld	a0,0(s2)
ffffffffc0203224:	77fd                	lui	a5,0xfffff
ffffffffc0203226:	6114                	ld	a3,0(a0)
ffffffffc0203228:	068a                	slli	a3,a3,0x2
ffffffffc020322a:	8efd                	and	a3,a3,a5
ffffffffc020322c:	00c6d713          	srli	a4,a3,0xc
ffffffffc0203230:	14c779e3          	bgeu	a4,a2,ffffffffc0203b82 <pmm_init+0xb4c>
ffffffffc0203234:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203238:	96e2                	add	a3,a3,s8
ffffffffc020323a:	0006ba83          	ld	s5,0(a3)
ffffffffc020323e:	0a8a                	slli	s5,s5,0x2
ffffffffc0203240:	00fafab3          	and	s5,s5,a5
ffffffffc0203244:	00cad793          	srli	a5,s5,0xc
ffffffffc0203248:	66c7f463          	bgeu	a5,a2,ffffffffc02038b0 <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020324c:	4601                	li	a2,0
ffffffffc020324e:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203250:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203252:	9fbff0ef          	jal	ra,ffffffffc0202c4c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203256:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203258:	63551c63          	bne	a0,s5,ffffffffc0203890 <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc020325c:	4505                	li	a0,1
ffffffffc020325e:	8e3ff0ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc0203262:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203264:	00093503          	ld	a0,0(s2)
ffffffffc0203268:	46d1                	li	a3,20
ffffffffc020326a:	6605                	lui	a2,0x1
ffffffffc020326c:	85d6                	mv	a1,s5
ffffffffc020326e:	cc9ff0ef          	jal	ra,ffffffffc0202f36 <page_insert>
ffffffffc0203272:	5c051f63          	bnez	a0,ffffffffc0203850 <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203276:	00093503          	ld	a0,0(s2)
ffffffffc020327a:	4601                	li	a2,0
ffffffffc020327c:	6585                	lui	a1,0x1
ffffffffc020327e:	9cfff0ef          	jal	ra,ffffffffc0202c4c <get_pte>
ffffffffc0203282:	12050ce3          	beqz	a0,ffffffffc0203bba <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc0203286:	611c                	ld	a5,0(a0)
ffffffffc0203288:	0107f713          	andi	a4,a5,16
ffffffffc020328c:	72070f63          	beqz	a4,ffffffffc02039ca <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc0203290:	8b91                	andi	a5,a5,4
ffffffffc0203292:	6e078c63          	beqz	a5,ffffffffc020398a <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203296:	00093503          	ld	a0,0(s2)
ffffffffc020329a:	611c                	ld	a5,0(a0)
ffffffffc020329c:	8bc1                	andi	a5,a5,16
ffffffffc020329e:	6c078663          	beqz	a5,ffffffffc020396a <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc02032a2:	000aa703          	lw	a4,0(s5)
ffffffffc02032a6:	4785                	li	a5,1
ffffffffc02032a8:	5cf71463          	bne	a4,a5,ffffffffc0203870 <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02032ac:	4681                	li	a3,0
ffffffffc02032ae:	6605                	lui	a2,0x1
ffffffffc02032b0:	85d2                	mv	a1,s4
ffffffffc02032b2:	c85ff0ef          	jal	ra,ffffffffc0202f36 <page_insert>
ffffffffc02032b6:	66051a63          	bnez	a0,ffffffffc020392a <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc02032ba:	000a2703          	lw	a4,0(s4)
ffffffffc02032be:	4789                	li	a5,2
ffffffffc02032c0:	64f71563          	bne	a4,a5,ffffffffc020390a <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc02032c4:	000aa783          	lw	a5,0(s5)
ffffffffc02032c8:	62079163          	bnez	a5,ffffffffc02038ea <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02032cc:	00093503          	ld	a0,0(s2)
ffffffffc02032d0:	4601                	li	a2,0
ffffffffc02032d2:	6585                	lui	a1,0x1
ffffffffc02032d4:	979ff0ef          	jal	ra,ffffffffc0202c4c <get_pte>
ffffffffc02032d8:	5e050963          	beqz	a0,ffffffffc02038ca <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc02032dc:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02032de:	00177793          	andi	a5,a4,1
ffffffffc02032e2:	50078563          	beqz	a5,ffffffffc02037ec <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc02032e6:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02032e8:	00271793          	slli	a5,a4,0x2
ffffffffc02032ec:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02032ee:	48d7f563          	bgeu	a5,a3,ffffffffc0203778 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02032f2:	fff806b7          	lui	a3,0xfff80
ffffffffc02032f6:	97b6                	add	a5,a5,a3
ffffffffc02032f8:	000b3603          	ld	a2,0(s6)
ffffffffc02032fc:	00379693          	slli	a3,a5,0x3
ffffffffc0203300:	97b6                	add	a5,a5,a3
ffffffffc0203302:	078e                	slli	a5,a5,0x3
ffffffffc0203304:	97b2                	add	a5,a5,a2
ffffffffc0203306:	72fa1263          	bne	s4,a5,ffffffffc0203a2a <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc020330a:	8b41                	andi	a4,a4,16
ffffffffc020330c:	6e071f63          	bnez	a4,ffffffffc0203a0a <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0203310:	00093503          	ld	a0,0(s2)
ffffffffc0203314:	4581                	li	a1,0
ffffffffc0203316:	b87ff0ef          	jal	ra,ffffffffc0202e9c <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020331a:	000a2703          	lw	a4,0(s4)
ffffffffc020331e:	4785                	li	a5,1
ffffffffc0203320:	6cf71563          	bne	a4,a5,ffffffffc02039ea <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc0203324:	000aa783          	lw	a5,0(s5)
ffffffffc0203328:	78079d63          	bnez	a5,ffffffffc0203ac2 <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020332c:	00093503          	ld	a0,0(s2)
ffffffffc0203330:	6585                	lui	a1,0x1
ffffffffc0203332:	b6bff0ef          	jal	ra,ffffffffc0202e9c <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0203336:	000a2783          	lw	a5,0(s4)
ffffffffc020333a:	76079463          	bnez	a5,ffffffffc0203aa2 <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc020333e:	000aa783          	lw	a5,0(s5)
ffffffffc0203342:	74079063          	bnez	a5,ffffffffc0203a82 <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203346:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020334a:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020334c:	000a3783          	ld	a5,0(s4)
ffffffffc0203350:	078a                	slli	a5,a5,0x2
ffffffffc0203352:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203354:	42c7f263          	bgeu	a5,a2,ffffffffc0203778 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203358:	fff80737          	lui	a4,0xfff80
ffffffffc020335c:	973e                	add	a4,a4,a5
ffffffffc020335e:	00371793          	slli	a5,a4,0x3
ffffffffc0203362:	000b3503          	ld	a0,0(s6)
ffffffffc0203366:	97ba                	add	a5,a5,a4
ffffffffc0203368:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc020336a:	00f50733          	add	a4,a0,a5
ffffffffc020336e:	4314                	lw	a3,0(a4)
ffffffffc0203370:	4705                	li	a4,1
ffffffffc0203372:	6ee69863          	bne	a3,a4,ffffffffc0203a62 <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203376:	4037d693          	srai	a3,a5,0x3
ffffffffc020337a:	00003c97          	auipc	s9,0x3
ffffffffc020337e:	0becbc83          	ld	s9,190(s9) # ffffffffc0206438 <error_string+0x38>
ffffffffc0203382:	039686b3          	mul	a3,a3,s9
ffffffffc0203386:	000805b7          	lui	a1,0x80
ffffffffc020338a:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020338c:	00c69713          	slli	a4,a3,0xc
ffffffffc0203390:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203392:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203394:	6ac77b63          	bgeu	a4,a2,ffffffffc0203a4a <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0203398:	0009b703          	ld	a4,0(s3)
ffffffffc020339c:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc020339e:	629c                	ld	a5,0(a3)
ffffffffc02033a0:	078a                	slli	a5,a5,0x2
ffffffffc02033a2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033a4:	3cc7fa63          	bgeu	a5,a2,ffffffffc0203778 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02033a8:	8f8d                	sub	a5,a5,a1
ffffffffc02033aa:	00379713          	slli	a4,a5,0x3
ffffffffc02033ae:	97ba                	add	a5,a5,a4
ffffffffc02033b0:	078e                	slli	a5,a5,0x3
ffffffffc02033b2:	953e                	add	a0,a0,a5
ffffffffc02033b4:	100027f3          	csrr	a5,sstatus
ffffffffc02033b8:	8b89                	andi	a5,a5,2
ffffffffc02033ba:	2e079963          	bnez	a5,ffffffffc02036ac <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc02033be:	000bb783          	ld	a5,0(s7)
ffffffffc02033c2:	4585                	li	a1,1
ffffffffc02033c4:	739c                	ld	a5,32(a5)
ffffffffc02033c6:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02033c8:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02033cc:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02033ce:	078a                	slli	a5,a5,0x2
ffffffffc02033d0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033d2:	3ae7f363          	bgeu	a5,a4,ffffffffc0203778 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02033d6:	fff80737          	lui	a4,0xfff80
ffffffffc02033da:	97ba                	add	a5,a5,a4
ffffffffc02033dc:	000b3503          	ld	a0,0(s6)
ffffffffc02033e0:	00379713          	slli	a4,a5,0x3
ffffffffc02033e4:	97ba                	add	a5,a5,a4
ffffffffc02033e6:	078e                	slli	a5,a5,0x3
ffffffffc02033e8:	953e                	add	a0,a0,a5
ffffffffc02033ea:	100027f3          	csrr	a5,sstatus
ffffffffc02033ee:	8b89                	andi	a5,a5,2
ffffffffc02033f0:	2a079263          	bnez	a5,ffffffffc0203694 <pmm_init+0x65e>
ffffffffc02033f4:	000bb783          	ld	a5,0(s7)
ffffffffc02033f8:	4585                	li	a1,1
ffffffffc02033fa:	739c                	ld	a5,32(a5)
ffffffffc02033fc:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02033fe:	00093783          	ld	a5,0(s2)
ffffffffc0203402:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda90>
ffffffffc0203406:	100027f3          	csrr	a5,sstatus
ffffffffc020340a:	8b89                	andi	a5,a5,2
ffffffffc020340c:	26079a63          	bnez	a5,ffffffffc0203680 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203410:	000bb783          	ld	a5,0(s7)
ffffffffc0203414:	779c                	ld	a5,40(a5)
ffffffffc0203416:	9782                	jalr	a5
ffffffffc0203418:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc020341a:	73441463          	bne	s0,s4,ffffffffc0203b42 <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020341e:	00003517          	auipc	a0,0x3
ffffffffc0203422:	b5250513          	addi	a0,a0,-1198 # ffffffffc0205f70 <default_pmm_manager+0x408>
ffffffffc0203426:	c95fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020342a:	100027f3          	csrr	a5,sstatus
ffffffffc020342e:	8b89                	andi	a5,a5,2
ffffffffc0203430:	22079e63          	bnez	a5,ffffffffc020366c <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203434:	000bb783          	ld	a5,0(s7)
ffffffffc0203438:	779c                	ld	a5,40(a5)
ffffffffc020343a:	9782                	jalr	a5
ffffffffc020343c:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020343e:	6098                	ld	a4,0(s1)
ffffffffc0203440:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203444:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203446:	00c71793          	slli	a5,a4,0xc
ffffffffc020344a:	6a05                	lui	s4,0x1
ffffffffc020344c:	02f47c63          	bgeu	s0,a5,ffffffffc0203484 <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203450:	00c45793          	srli	a5,s0,0xc
ffffffffc0203454:	00093503          	ld	a0,0(s2)
ffffffffc0203458:	30e7f363          	bgeu	a5,a4,ffffffffc020375e <pmm_init+0x728>
ffffffffc020345c:	0009b583          	ld	a1,0(s3)
ffffffffc0203460:	4601                	li	a2,0
ffffffffc0203462:	95a2                	add	a1,a1,s0
ffffffffc0203464:	fe8ff0ef          	jal	ra,ffffffffc0202c4c <get_pte>
ffffffffc0203468:	2c050b63          	beqz	a0,ffffffffc020373e <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020346c:	611c                	ld	a5,0(a0)
ffffffffc020346e:	078a                	slli	a5,a5,0x2
ffffffffc0203470:	0157f7b3          	and	a5,a5,s5
ffffffffc0203474:	2a879563          	bne	a5,s0,ffffffffc020371e <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203478:	6098                	ld	a4,0(s1)
ffffffffc020347a:	9452                	add	s0,s0,s4
ffffffffc020347c:	00c71793          	slli	a5,a4,0xc
ffffffffc0203480:	fcf468e3          	bltu	s0,a5,ffffffffc0203450 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0203484:	00093783          	ld	a5,0(s2)
ffffffffc0203488:	639c                	ld	a5,0(a5)
ffffffffc020348a:	68079c63          	bnez	a5,ffffffffc0203b22 <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc020348e:	4505                	li	a0,1
ffffffffc0203490:	eb0ff0ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc0203494:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203496:	00093503          	ld	a0,0(s2)
ffffffffc020349a:	4699                	li	a3,6
ffffffffc020349c:	10000613          	li	a2,256
ffffffffc02034a0:	85d6                	mv	a1,s5
ffffffffc02034a2:	a95ff0ef          	jal	ra,ffffffffc0202f36 <page_insert>
ffffffffc02034a6:	64051e63          	bnez	a0,ffffffffc0203b02 <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc02034aa:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda90>
ffffffffc02034ae:	4785                	li	a5,1
ffffffffc02034b0:	62f71963          	bne	a4,a5,ffffffffc0203ae2 <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02034b4:	00093503          	ld	a0,0(s2)
ffffffffc02034b8:	6405                	lui	s0,0x1
ffffffffc02034ba:	4699                	li	a3,6
ffffffffc02034bc:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc02034c0:	85d6                	mv	a1,s5
ffffffffc02034c2:	a75ff0ef          	jal	ra,ffffffffc0202f36 <page_insert>
ffffffffc02034c6:	48051263          	bnez	a0,ffffffffc020394a <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc02034ca:	000aa703          	lw	a4,0(s5)
ffffffffc02034ce:	4789                	li	a5,2
ffffffffc02034d0:	74f71563          	bne	a4,a5,ffffffffc0203c1a <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02034d4:	00003597          	auipc	a1,0x3
ffffffffc02034d8:	bd458593          	addi	a1,a1,-1068 # ffffffffc02060a8 <default_pmm_manager+0x540>
ffffffffc02034dc:	10000513          	li	a0,256
ffffffffc02034e0:	35d000ef          	jal	ra,ffffffffc020403c <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02034e4:	10040593          	addi	a1,s0,256
ffffffffc02034e8:	10000513          	li	a0,256
ffffffffc02034ec:	363000ef          	jal	ra,ffffffffc020404e <strcmp>
ffffffffc02034f0:	70051563          	bnez	a0,ffffffffc0203bfa <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02034f4:	000b3683          	ld	a3,0(s6)
ffffffffc02034f8:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02034fc:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02034fe:	40da86b3          	sub	a3,s5,a3
ffffffffc0203502:	868d                	srai	a3,a3,0x3
ffffffffc0203504:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203508:	609c                	ld	a5,0(s1)
ffffffffc020350a:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020350c:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020350e:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203512:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203514:	52f77b63          	bgeu	a4,a5,ffffffffc0203a4a <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203518:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020351c:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203520:	96be                	add	a3,a3,a5
ffffffffc0203522:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb90>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203526:	2e1000ef          	jal	ra,ffffffffc0204006 <strlen>
ffffffffc020352a:	6a051863          	bnez	a0,ffffffffc0203bda <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020352e:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203532:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203534:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203538:	078a                	slli	a5,a5,0x2
ffffffffc020353a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020353c:	22e7fe63          	bgeu	a5,a4,ffffffffc0203778 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203540:	41a787b3          	sub	a5,a5,s10
ffffffffc0203544:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203548:	96be                	add	a3,a3,a5
ffffffffc020354a:	03968cb3          	mul	s9,a3,s9
ffffffffc020354e:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203552:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203554:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203556:	4ee47a63          	bgeu	s0,a4,ffffffffc0203a4a <pmm_init+0xa14>
ffffffffc020355a:	0009b403          	ld	s0,0(s3)
ffffffffc020355e:	9436                	add	s0,s0,a3
ffffffffc0203560:	100027f3          	csrr	a5,sstatus
ffffffffc0203564:	8b89                	andi	a5,a5,2
ffffffffc0203566:	1a079163          	bnez	a5,ffffffffc0203708 <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc020356a:	000bb783          	ld	a5,0(s7)
ffffffffc020356e:	4585                	li	a1,1
ffffffffc0203570:	8556                	mv	a0,s5
ffffffffc0203572:	739c                	ld	a5,32(a5)
ffffffffc0203574:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203576:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203578:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020357a:	078a                	slli	a5,a5,0x2
ffffffffc020357c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020357e:	1ee7fd63          	bgeu	a5,a4,ffffffffc0203778 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203582:	fff80737          	lui	a4,0xfff80
ffffffffc0203586:	97ba                	add	a5,a5,a4
ffffffffc0203588:	000b3503          	ld	a0,0(s6)
ffffffffc020358c:	00379713          	slli	a4,a5,0x3
ffffffffc0203590:	97ba                	add	a5,a5,a4
ffffffffc0203592:	078e                	slli	a5,a5,0x3
ffffffffc0203594:	953e                	add	a0,a0,a5
ffffffffc0203596:	100027f3          	csrr	a5,sstatus
ffffffffc020359a:	8b89                	andi	a5,a5,2
ffffffffc020359c:	14079a63          	bnez	a5,ffffffffc02036f0 <pmm_init+0x6ba>
ffffffffc02035a0:	000bb783          	ld	a5,0(s7)
ffffffffc02035a4:	4585                	li	a1,1
ffffffffc02035a6:	739c                	ld	a5,32(a5)
ffffffffc02035a8:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02035aa:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02035ae:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02035b0:	078a                	slli	a5,a5,0x2
ffffffffc02035b2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02035b4:	1ce7f263          	bgeu	a5,a4,ffffffffc0203778 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02035b8:	fff80737          	lui	a4,0xfff80
ffffffffc02035bc:	97ba                	add	a5,a5,a4
ffffffffc02035be:	000b3503          	ld	a0,0(s6)
ffffffffc02035c2:	00379713          	slli	a4,a5,0x3
ffffffffc02035c6:	97ba                	add	a5,a5,a4
ffffffffc02035c8:	078e                	slli	a5,a5,0x3
ffffffffc02035ca:	953e                	add	a0,a0,a5
ffffffffc02035cc:	100027f3          	csrr	a5,sstatus
ffffffffc02035d0:	8b89                	andi	a5,a5,2
ffffffffc02035d2:	10079363          	bnez	a5,ffffffffc02036d8 <pmm_init+0x6a2>
ffffffffc02035d6:	000bb783          	ld	a5,0(s7)
ffffffffc02035da:	4585                	li	a1,1
ffffffffc02035dc:	739c                	ld	a5,32(a5)
ffffffffc02035de:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02035e0:	00093783          	ld	a5,0(s2)
ffffffffc02035e4:	0007b023          	sd	zero,0(a5)
ffffffffc02035e8:	100027f3          	csrr	a5,sstatus
ffffffffc02035ec:	8b89                	andi	a5,a5,2
ffffffffc02035ee:	0c079b63          	bnez	a5,ffffffffc02036c4 <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02035f2:	000bb783          	ld	a5,0(s7)
ffffffffc02035f6:	779c                	ld	a5,40(a5)
ffffffffc02035f8:	9782                	jalr	a5
ffffffffc02035fa:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc02035fc:	3a8c1763          	bne	s8,s0,ffffffffc02039aa <pmm_init+0x974>
}
ffffffffc0203600:	7406                	ld	s0,96(sp)
ffffffffc0203602:	70a6                	ld	ra,104(sp)
ffffffffc0203604:	64e6                	ld	s1,88(sp)
ffffffffc0203606:	6946                	ld	s2,80(sp)
ffffffffc0203608:	69a6                	ld	s3,72(sp)
ffffffffc020360a:	6a06                	ld	s4,64(sp)
ffffffffc020360c:	7ae2                	ld	s5,56(sp)
ffffffffc020360e:	7b42                	ld	s6,48(sp)
ffffffffc0203610:	7ba2                	ld	s7,40(sp)
ffffffffc0203612:	7c02                	ld	s8,32(sp)
ffffffffc0203614:	6ce2                	ld	s9,24(sp)
ffffffffc0203616:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0203618:	00003517          	auipc	a0,0x3
ffffffffc020361c:	b0850513          	addi	a0,a0,-1272 # ffffffffc0206120 <default_pmm_manager+0x5b8>
}
ffffffffc0203620:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0203622:	a99fc06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0203626:	6705                	lui	a4,0x1
ffffffffc0203628:	177d                	addi	a4,a4,-1
ffffffffc020362a:	96ba                	add	a3,a3,a4
ffffffffc020362c:	777d                	lui	a4,0xfffff
ffffffffc020362e:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc0203630:	00c75693          	srli	a3,a4,0xc
ffffffffc0203634:	14f6f263          	bgeu	a3,a5,ffffffffc0203778 <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc0203638:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc020363c:	95b6                	add	a1,a1,a3
ffffffffc020363e:	00359793          	slli	a5,a1,0x3
ffffffffc0203642:	97ae                	add	a5,a5,a1
ffffffffc0203644:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203648:	40e60733          	sub	a4,a2,a4
ffffffffc020364c:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020364e:	00c75593          	srli	a1,a4,0xc
ffffffffc0203652:	953e                	add	a0,a0,a5
ffffffffc0203654:	9682                	jalr	a3
}
ffffffffc0203656:	bcc5                	j	ffffffffc0203146 <pmm_init+0x110>
        intr_disable();
ffffffffc0203658:	e97fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020365c:	000bb783          	ld	a5,0(s7)
ffffffffc0203660:	779c                	ld	a5,40(a5)
ffffffffc0203662:	9782                	jalr	a5
ffffffffc0203664:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203666:	e83fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020366a:	b63d                	j	ffffffffc0203198 <pmm_init+0x162>
        intr_disable();
ffffffffc020366c:	e83fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203670:	000bb783          	ld	a5,0(s7)
ffffffffc0203674:	779c                	ld	a5,40(a5)
ffffffffc0203676:	9782                	jalr	a5
ffffffffc0203678:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc020367a:	e6ffc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020367e:	b3c1                	j	ffffffffc020343e <pmm_init+0x408>
        intr_disable();
ffffffffc0203680:	e6ffc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203684:	000bb783          	ld	a5,0(s7)
ffffffffc0203688:	779c                	ld	a5,40(a5)
ffffffffc020368a:	9782                	jalr	a5
ffffffffc020368c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020368e:	e5bfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203692:	b361                	j	ffffffffc020341a <pmm_init+0x3e4>
ffffffffc0203694:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203696:	e59fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020369a:	000bb783          	ld	a5,0(s7)
ffffffffc020369e:	6522                	ld	a0,8(sp)
ffffffffc02036a0:	4585                	li	a1,1
ffffffffc02036a2:	739c                	ld	a5,32(a5)
ffffffffc02036a4:	9782                	jalr	a5
        intr_enable();
ffffffffc02036a6:	e43fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02036aa:	bb91                	j	ffffffffc02033fe <pmm_init+0x3c8>
ffffffffc02036ac:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02036ae:	e41fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02036b2:	000bb783          	ld	a5,0(s7)
ffffffffc02036b6:	6522                	ld	a0,8(sp)
ffffffffc02036b8:	4585                	li	a1,1
ffffffffc02036ba:	739c                	ld	a5,32(a5)
ffffffffc02036bc:	9782                	jalr	a5
        intr_enable();
ffffffffc02036be:	e2bfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02036c2:	b319                	j	ffffffffc02033c8 <pmm_init+0x392>
        intr_disable();
ffffffffc02036c4:	e2bfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02036c8:	000bb783          	ld	a5,0(s7)
ffffffffc02036cc:	779c                	ld	a5,40(a5)
ffffffffc02036ce:	9782                	jalr	a5
ffffffffc02036d0:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02036d2:	e17fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02036d6:	b71d                	j	ffffffffc02035fc <pmm_init+0x5c6>
ffffffffc02036d8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02036da:	e15fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02036de:	000bb783          	ld	a5,0(s7)
ffffffffc02036e2:	6522                	ld	a0,8(sp)
ffffffffc02036e4:	4585                	li	a1,1
ffffffffc02036e6:	739c                	ld	a5,32(a5)
ffffffffc02036e8:	9782                	jalr	a5
        intr_enable();
ffffffffc02036ea:	dfffc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02036ee:	bdcd                	j	ffffffffc02035e0 <pmm_init+0x5aa>
ffffffffc02036f0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02036f2:	dfdfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02036f6:	000bb783          	ld	a5,0(s7)
ffffffffc02036fa:	6522                	ld	a0,8(sp)
ffffffffc02036fc:	4585                	li	a1,1
ffffffffc02036fe:	739c                	ld	a5,32(a5)
ffffffffc0203700:	9782                	jalr	a5
        intr_enable();
ffffffffc0203702:	de7fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203706:	b555                	j	ffffffffc02035aa <pmm_init+0x574>
        intr_disable();
ffffffffc0203708:	de7fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020370c:	000bb783          	ld	a5,0(s7)
ffffffffc0203710:	4585                	li	a1,1
ffffffffc0203712:	8556                	mv	a0,s5
ffffffffc0203714:	739c                	ld	a5,32(a5)
ffffffffc0203716:	9782                	jalr	a5
        intr_enable();
ffffffffc0203718:	dd1fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020371c:	bda9                	j	ffffffffc0203576 <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020371e:	00003697          	auipc	a3,0x3
ffffffffc0203722:	8b268693          	addi	a3,a3,-1870 # ffffffffc0205fd0 <default_pmm_manager+0x468>
ffffffffc0203726:	00001617          	auipc	a2,0x1
ffffffffc020372a:	7ba60613          	addi	a2,a2,1978 # ffffffffc0204ee0 <commands+0x718>
ffffffffc020372e:	1da00593          	li	a1,474
ffffffffc0203732:	00002517          	auipc	a0,0x2
ffffffffc0203736:	49650513          	addi	a0,a0,1174 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc020373a:	9c9fc0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020373e:	00003697          	auipc	a3,0x3
ffffffffc0203742:	85268693          	addi	a3,a3,-1966 # ffffffffc0205f90 <default_pmm_manager+0x428>
ffffffffc0203746:	00001617          	auipc	a2,0x1
ffffffffc020374a:	79a60613          	addi	a2,a2,1946 # ffffffffc0204ee0 <commands+0x718>
ffffffffc020374e:	1d900593          	li	a1,473
ffffffffc0203752:	00002517          	auipc	a0,0x2
ffffffffc0203756:	47650513          	addi	a0,a0,1142 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc020375a:	9a9fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc020375e:	86a2                	mv	a3,s0
ffffffffc0203760:	00002617          	auipc	a2,0x2
ffffffffc0203764:	44060613          	addi	a2,a2,1088 # ffffffffc0205ba0 <default_pmm_manager+0x38>
ffffffffc0203768:	1d900593          	li	a1,473
ffffffffc020376c:	00002517          	auipc	a0,0x2
ffffffffc0203770:	45c50513          	addi	a0,a0,1116 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203774:	98ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203778:	b90ff0ef          	jal	ra,ffffffffc0202b08 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020377c:	00002617          	auipc	a2,0x2
ffffffffc0203780:	4e460613          	addi	a2,a2,1252 # ffffffffc0205c60 <default_pmm_manager+0xf8>
ffffffffc0203784:	07700593          	li	a1,119
ffffffffc0203788:	00002517          	auipc	a0,0x2
ffffffffc020378c:	44050513          	addi	a0,a0,1088 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203790:	973fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203794:	00002617          	auipc	a2,0x2
ffffffffc0203798:	4cc60613          	addi	a2,a2,1228 # ffffffffc0205c60 <default_pmm_manager+0xf8>
ffffffffc020379c:	0c600593          	li	a1,198
ffffffffc02037a0:	00002517          	auipc	a0,0x2
ffffffffc02037a4:	42850513          	addi	a0,a0,1064 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc02037a8:	95bfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02037ac:	00002697          	auipc	a3,0x2
ffffffffc02037b0:	51c68693          	addi	a3,a3,1308 # ffffffffc0205cc8 <default_pmm_manager+0x160>
ffffffffc02037b4:	00001617          	auipc	a2,0x1
ffffffffc02037b8:	72c60613          	addi	a2,a2,1836 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02037bc:	19f00593          	li	a1,415
ffffffffc02037c0:	00002517          	auipc	a0,0x2
ffffffffc02037c4:	40850513          	addi	a0,a0,1032 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc02037c8:	93bfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02037cc:	00002697          	auipc	a3,0x2
ffffffffc02037d0:	4dc68693          	addi	a3,a3,1244 # ffffffffc0205ca8 <default_pmm_manager+0x140>
ffffffffc02037d4:	00001617          	auipc	a2,0x1
ffffffffc02037d8:	70c60613          	addi	a2,a2,1804 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02037dc:	19e00593          	li	a1,414
ffffffffc02037e0:	00002517          	auipc	a0,0x2
ffffffffc02037e4:	3e850513          	addi	a0,a0,1000 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc02037e8:	91bfc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc02037ec:	b38ff0ef          	jal	ra,ffffffffc0202b24 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02037f0:	00002697          	auipc	a3,0x2
ffffffffc02037f4:	56868693          	addi	a3,a3,1384 # ffffffffc0205d58 <default_pmm_manager+0x1f0>
ffffffffc02037f8:	00001617          	auipc	a2,0x1
ffffffffc02037fc:	6e860613          	addi	a2,a2,1768 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203800:	1a600593          	li	a1,422
ffffffffc0203804:	00002517          	auipc	a0,0x2
ffffffffc0203808:	3c450513          	addi	a0,a0,964 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc020380c:	8f7fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203810:	00002697          	auipc	a3,0x2
ffffffffc0203814:	51868693          	addi	a3,a3,1304 # ffffffffc0205d28 <default_pmm_manager+0x1c0>
ffffffffc0203818:	00001617          	auipc	a2,0x1
ffffffffc020381c:	6c860613          	addi	a2,a2,1736 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203820:	1a400593          	li	a1,420
ffffffffc0203824:	00002517          	auipc	a0,0x2
ffffffffc0203828:	3a450513          	addi	a0,a0,932 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc020382c:	8d7fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203830:	00002697          	auipc	a3,0x2
ffffffffc0203834:	4d068693          	addi	a3,a3,1232 # ffffffffc0205d00 <default_pmm_manager+0x198>
ffffffffc0203838:	00001617          	auipc	a2,0x1
ffffffffc020383c:	6a860613          	addi	a2,a2,1704 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203840:	1a000593          	li	a1,416
ffffffffc0203844:	00002517          	auipc	a0,0x2
ffffffffc0203848:	38450513          	addi	a0,a0,900 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc020384c:	8b7fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203850:	00002697          	auipc	a3,0x2
ffffffffc0203854:	59068693          	addi	a3,a3,1424 # ffffffffc0205de0 <default_pmm_manager+0x278>
ffffffffc0203858:	00001617          	auipc	a2,0x1
ffffffffc020385c:	68860613          	addi	a2,a2,1672 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203860:	1af00593          	li	a1,431
ffffffffc0203864:	00002517          	auipc	a0,0x2
ffffffffc0203868:	36450513          	addi	a0,a0,868 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc020386c:	897fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203870:	00002697          	auipc	a3,0x2
ffffffffc0203874:	61068693          	addi	a3,a3,1552 # ffffffffc0205e80 <default_pmm_manager+0x318>
ffffffffc0203878:	00001617          	auipc	a2,0x1
ffffffffc020387c:	66860613          	addi	a2,a2,1640 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203880:	1b400593          	li	a1,436
ffffffffc0203884:	00002517          	auipc	a0,0x2
ffffffffc0203888:	34450513          	addi	a0,a0,836 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc020388c:	877fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203890:	00002697          	auipc	a3,0x2
ffffffffc0203894:	52868693          	addi	a3,a3,1320 # ffffffffc0205db8 <default_pmm_manager+0x250>
ffffffffc0203898:	00001617          	auipc	a2,0x1
ffffffffc020389c:	64860613          	addi	a2,a2,1608 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02038a0:	1ac00593          	li	a1,428
ffffffffc02038a4:	00002517          	auipc	a0,0x2
ffffffffc02038a8:	32450513          	addi	a0,a0,804 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc02038ac:	857fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02038b0:	86d6                	mv	a3,s5
ffffffffc02038b2:	00002617          	auipc	a2,0x2
ffffffffc02038b6:	2ee60613          	addi	a2,a2,750 # ffffffffc0205ba0 <default_pmm_manager+0x38>
ffffffffc02038ba:	1ab00593          	li	a1,427
ffffffffc02038be:	00002517          	auipc	a0,0x2
ffffffffc02038c2:	30a50513          	addi	a0,a0,778 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc02038c6:	83dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02038ca:	00002697          	auipc	a3,0x2
ffffffffc02038ce:	54e68693          	addi	a3,a3,1358 # ffffffffc0205e18 <default_pmm_manager+0x2b0>
ffffffffc02038d2:	00001617          	auipc	a2,0x1
ffffffffc02038d6:	60e60613          	addi	a2,a2,1550 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02038da:	1b900593          	li	a1,441
ffffffffc02038de:	00002517          	auipc	a0,0x2
ffffffffc02038e2:	2ea50513          	addi	a0,a0,746 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc02038e6:	81dfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02038ea:	00002697          	auipc	a3,0x2
ffffffffc02038ee:	5f668693          	addi	a3,a3,1526 # ffffffffc0205ee0 <default_pmm_manager+0x378>
ffffffffc02038f2:	00001617          	auipc	a2,0x1
ffffffffc02038f6:	5ee60613          	addi	a2,a2,1518 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02038fa:	1b800593          	li	a1,440
ffffffffc02038fe:	00002517          	auipc	a0,0x2
ffffffffc0203902:	2ca50513          	addi	a0,a0,714 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203906:	ffcfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020390a:	00002697          	auipc	a3,0x2
ffffffffc020390e:	5be68693          	addi	a3,a3,1470 # ffffffffc0205ec8 <default_pmm_manager+0x360>
ffffffffc0203912:	00001617          	auipc	a2,0x1
ffffffffc0203916:	5ce60613          	addi	a2,a2,1486 # ffffffffc0204ee0 <commands+0x718>
ffffffffc020391a:	1b700593          	li	a1,439
ffffffffc020391e:	00002517          	auipc	a0,0x2
ffffffffc0203922:	2aa50513          	addi	a0,a0,682 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203926:	fdcfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020392a:	00002697          	auipc	a3,0x2
ffffffffc020392e:	56e68693          	addi	a3,a3,1390 # ffffffffc0205e98 <default_pmm_manager+0x330>
ffffffffc0203932:	00001617          	auipc	a2,0x1
ffffffffc0203936:	5ae60613          	addi	a2,a2,1454 # ffffffffc0204ee0 <commands+0x718>
ffffffffc020393a:	1b600593          	li	a1,438
ffffffffc020393e:	00002517          	auipc	a0,0x2
ffffffffc0203942:	28a50513          	addi	a0,a0,650 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203946:	fbcfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020394a:	00002697          	auipc	a3,0x2
ffffffffc020394e:	70668693          	addi	a3,a3,1798 # ffffffffc0206050 <default_pmm_manager+0x4e8>
ffffffffc0203952:	00001617          	auipc	a2,0x1
ffffffffc0203956:	58e60613          	addi	a2,a2,1422 # ffffffffc0204ee0 <commands+0x718>
ffffffffc020395a:	1e400593          	li	a1,484
ffffffffc020395e:	00002517          	auipc	a0,0x2
ffffffffc0203962:	26a50513          	addi	a0,a0,618 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203966:	f9cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020396a:	00002697          	auipc	a3,0x2
ffffffffc020396e:	4fe68693          	addi	a3,a3,1278 # ffffffffc0205e68 <default_pmm_manager+0x300>
ffffffffc0203972:	00001617          	auipc	a2,0x1
ffffffffc0203976:	56e60613          	addi	a2,a2,1390 # ffffffffc0204ee0 <commands+0x718>
ffffffffc020397a:	1b300593          	li	a1,435
ffffffffc020397e:	00002517          	auipc	a0,0x2
ffffffffc0203982:	24a50513          	addi	a0,a0,586 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203986:	f7cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020398a:	00002697          	auipc	a3,0x2
ffffffffc020398e:	4ce68693          	addi	a3,a3,1230 # ffffffffc0205e58 <default_pmm_manager+0x2f0>
ffffffffc0203992:	00001617          	auipc	a2,0x1
ffffffffc0203996:	54e60613          	addi	a2,a2,1358 # ffffffffc0204ee0 <commands+0x718>
ffffffffc020399a:	1b200593          	li	a1,434
ffffffffc020399e:	00002517          	auipc	a0,0x2
ffffffffc02039a2:	22a50513          	addi	a0,a0,554 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc02039a6:	f5cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02039aa:	00002697          	auipc	a3,0x2
ffffffffc02039ae:	5a668693          	addi	a3,a3,1446 # ffffffffc0205f50 <default_pmm_manager+0x3e8>
ffffffffc02039b2:	00001617          	auipc	a2,0x1
ffffffffc02039b6:	52e60613          	addi	a2,a2,1326 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02039ba:	1f400593          	li	a1,500
ffffffffc02039be:	00002517          	auipc	a0,0x2
ffffffffc02039c2:	20a50513          	addi	a0,a0,522 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc02039c6:	f3cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02039ca:	00002697          	auipc	a3,0x2
ffffffffc02039ce:	47e68693          	addi	a3,a3,1150 # ffffffffc0205e48 <default_pmm_manager+0x2e0>
ffffffffc02039d2:	00001617          	auipc	a2,0x1
ffffffffc02039d6:	50e60613          	addi	a2,a2,1294 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02039da:	1b100593          	li	a1,433
ffffffffc02039de:	00002517          	auipc	a0,0x2
ffffffffc02039e2:	1ea50513          	addi	a0,a0,490 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc02039e6:	f1cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02039ea:	00002697          	auipc	a3,0x2
ffffffffc02039ee:	3b668693          	addi	a3,a3,950 # ffffffffc0205da0 <default_pmm_manager+0x238>
ffffffffc02039f2:	00001617          	auipc	a2,0x1
ffffffffc02039f6:	4ee60613          	addi	a2,a2,1262 # ffffffffc0204ee0 <commands+0x718>
ffffffffc02039fa:	1be00593          	li	a1,446
ffffffffc02039fe:	00002517          	auipc	a0,0x2
ffffffffc0203a02:	1ca50513          	addi	a0,a0,458 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203a06:	efcfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203a0a:	00002697          	auipc	a3,0x2
ffffffffc0203a0e:	4ee68693          	addi	a3,a3,1262 # ffffffffc0205ef8 <default_pmm_manager+0x390>
ffffffffc0203a12:	00001617          	auipc	a2,0x1
ffffffffc0203a16:	4ce60613          	addi	a2,a2,1230 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203a1a:	1bb00593          	li	a1,443
ffffffffc0203a1e:	00002517          	auipc	a0,0x2
ffffffffc0203a22:	1aa50513          	addi	a0,a0,426 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203a26:	edcfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203a2a:	00002697          	auipc	a3,0x2
ffffffffc0203a2e:	35e68693          	addi	a3,a3,862 # ffffffffc0205d88 <default_pmm_manager+0x220>
ffffffffc0203a32:	00001617          	auipc	a2,0x1
ffffffffc0203a36:	4ae60613          	addi	a2,a2,1198 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203a3a:	1ba00593          	li	a1,442
ffffffffc0203a3e:	00002517          	auipc	a0,0x2
ffffffffc0203a42:	18a50513          	addi	a0,a0,394 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203a46:	ebcfc0ef          	jal	ra,ffffffffc0200102 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203a4a:	00002617          	auipc	a2,0x2
ffffffffc0203a4e:	15660613          	addi	a2,a2,342 # ffffffffc0205ba0 <default_pmm_manager+0x38>
ffffffffc0203a52:	06b00593          	li	a1,107
ffffffffc0203a56:	00002517          	auipc	a0,0x2
ffffffffc0203a5a:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0205340 <commands+0xb78>
ffffffffc0203a5e:	ea4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203a62:	00002697          	auipc	a3,0x2
ffffffffc0203a66:	4c668693          	addi	a3,a3,1222 # ffffffffc0205f28 <default_pmm_manager+0x3c0>
ffffffffc0203a6a:	00001617          	auipc	a2,0x1
ffffffffc0203a6e:	47660613          	addi	a2,a2,1142 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203a72:	1c500593          	li	a1,453
ffffffffc0203a76:	00002517          	auipc	a0,0x2
ffffffffc0203a7a:	15250513          	addi	a0,a0,338 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203a7e:	e84fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203a82:	00002697          	auipc	a3,0x2
ffffffffc0203a86:	45e68693          	addi	a3,a3,1118 # ffffffffc0205ee0 <default_pmm_manager+0x378>
ffffffffc0203a8a:	00001617          	auipc	a2,0x1
ffffffffc0203a8e:	45660613          	addi	a2,a2,1110 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203a92:	1c300593          	li	a1,451
ffffffffc0203a96:	00002517          	auipc	a0,0x2
ffffffffc0203a9a:	13250513          	addi	a0,a0,306 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203a9e:	e64fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203aa2:	00002697          	auipc	a3,0x2
ffffffffc0203aa6:	46e68693          	addi	a3,a3,1134 # ffffffffc0205f10 <default_pmm_manager+0x3a8>
ffffffffc0203aaa:	00001617          	auipc	a2,0x1
ffffffffc0203aae:	43660613          	addi	a2,a2,1078 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203ab2:	1c200593          	li	a1,450
ffffffffc0203ab6:	00002517          	auipc	a0,0x2
ffffffffc0203aba:	11250513          	addi	a0,a0,274 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203abe:	e44fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203ac2:	00002697          	auipc	a3,0x2
ffffffffc0203ac6:	41e68693          	addi	a3,a3,1054 # ffffffffc0205ee0 <default_pmm_manager+0x378>
ffffffffc0203aca:	00001617          	auipc	a2,0x1
ffffffffc0203ace:	41660613          	addi	a2,a2,1046 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203ad2:	1bf00593          	li	a1,447
ffffffffc0203ad6:	00002517          	auipc	a0,0x2
ffffffffc0203ada:	0f250513          	addi	a0,a0,242 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203ade:	e24fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203ae2:	00002697          	auipc	a3,0x2
ffffffffc0203ae6:	55668693          	addi	a3,a3,1366 # ffffffffc0206038 <default_pmm_manager+0x4d0>
ffffffffc0203aea:	00001617          	auipc	a2,0x1
ffffffffc0203aee:	3f660613          	addi	a2,a2,1014 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203af2:	1e300593          	li	a1,483
ffffffffc0203af6:	00002517          	auipc	a0,0x2
ffffffffc0203afa:	0d250513          	addi	a0,a0,210 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203afe:	e04fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203b02:	00002697          	auipc	a3,0x2
ffffffffc0203b06:	4fe68693          	addi	a3,a3,1278 # ffffffffc0206000 <default_pmm_manager+0x498>
ffffffffc0203b0a:	00001617          	auipc	a2,0x1
ffffffffc0203b0e:	3d660613          	addi	a2,a2,982 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203b12:	1e200593          	li	a1,482
ffffffffc0203b16:	00002517          	auipc	a0,0x2
ffffffffc0203b1a:	0b250513          	addi	a0,a0,178 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203b1e:	de4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203b22:	00002697          	auipc	a3,0x2
ffffffffc0203b26:	4c668693          	addi	a3,a3,1222 # ffffffffc0205fe8 <default_pmm_manager+0x480>
ffffffffc0203b2a:	00001617          	auipc	a2,0x1
ffffffffc0203b2e:	3b660613          	addi	a2,a2,950 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203b32:	1de00593          	li	a1,478
ffffffffc0203b36:	00002517          	auipc	a0,0x2
ffffffffc0203b3a:	09250513          	addi	a0,a0,146 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203b3e:	dc4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203b42:	00002697          	auipc	a3,0x2
ffffffffc0203b46:	40e68693          	addi	a3,a3,1038 # ffffffffc0205f50 <default_pmm_manager+0x3e8>
ffffffffc0203b4a:	00001617          	auipc	a2,0x1
ffffffffc0203b4e:	39660613          	addi	a2,a2,918 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203b52:	1cc00593          	li	a1,460
ffffffffc0203b56:	00002517          	auipc	a0,0x2
ffffffffc0203b5a:	07250513          	addi	a0,a0,114 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203b5e:	da4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203b62:	00002697          	auipc	a3,0x2
ffffffffc0203b66:	22668693          	addi	a3,a3,550 # ffffffffc0205d88 <default_pmm_manager+0x220>
ffffffffc0203b6a:	00001617          	auipc	a2,0x1
ffffffffc0203b6e:	37660613          	addi	a2,a2,886 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203b72:	1a700593          	li	a1,423
ffffffffc0203b76:	00002517          	auipc	a0,0x2
ffffffffc0203b7a:	05250513          	addi	a0,a0,82 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203b7e:	d84fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203b82:	00002617          	auipc	a2,0x2
ffffffffc0203b86:	01e60613          	addi	a2,a2,30 # ffffffffc0205ba0 <default_pmm_manager+0x38>
ffffffffc0203b8a:	1aa00593          	li	a1,426
ffffffffc0203b8e:	00002517          	auipc	a0,0x2
ffffffffc0203b92:	03a50513          	addi	a0,a0,58 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203b96:	d6cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203b9a:	00002697          	auipc	a3,0x2
ffffffffc0203b9e:	20668693          	addi	a3,a3,518 # ffffffffc0205da0 <default_pmm_manager+0x238>
ffffffffc0203ba2:	00001617          	auipc	a2,0x1
ffffffffc0203ba6:	33e60613          	addi	a2,a2,830 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203baa:	1a800593          	li	a1,424
ffffffffc0203bae:	00002517          	auipc	a0,0x2
ffffffffc0203bb2:	01a50513          	addi	a0,a0,26 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203bb6:	d4cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203bba:	00002697          	auipc	a3,0x2
ffffffffc0203bbe:	25e68693          	addi	a3,a3,606 # ffffffffc0205e18 <default_pmm_manager+0x2b0>
ffffffffc0203bc2:	00001617          	auipc	a2,0x1
ffffffffc0203bc6:	31e60613          	addi	a2,a2,798 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203bca:	1b000593          	li	a1,432
ffffffffc0203bce:	00002517          	auipc	a0,0x2
ffffffffc0203bd2:	ffa50513          	addi	a0,a0,-6 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203bd6:	d2cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203bda:	00002697          	auipc	a3,0x2
ffffffffc0203bde:	51e68693          	addi	a3,a3,1310 # ffffffffc02060f8 <default_pmm_manager+0x590>
ffffffffc0203be2:	00001617          	auipc	a2,0x1
ffffffffc0203be6:	2fe60613          	addi	a2,a2,766 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203bea:	1ec00593          	li	a1,492
ffffffffc0203bee:	00002517          	auipc	a0,0x2
ffffffffc0203bf2:	fda50513          	addi	a0,a0,-38 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203bf6:	d0cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203bfa:	00002697          	auipc	a3,0x2
ffffffffc0203bfe:	4c668693          	addi	a3,a3,1222 # ffffffffc02060c0 <default_pmm_manager+0x558>
ffffffffc0203c02:	00001617          	auipc	a2,0x1
ffffffffc0203c06:	2de60613          	addi	a2,a2,734 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203c0a:	1e900593          	li	a1,489
ffffffffc0203c0e:	00002517          	auipc	a0,0x2
ffffffffc0203c12:	fba50513          	addi	a0,a0,-70 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203c16:	cecfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203c1a:	00002697          	auipc	a3,0x2
ffffffffc0203c1e:	47668693          	addi	a3,a3,1142 # ffffffffc0206090 <default_pmm_manager+0x528>
ffffffffc0203c22:	00001617          	auipc	a2,0x1
ffffffffc0203c26:	2be60613          	addi	a2,a2,702 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203c2a:	1e500593          	li	a1,485
ffffffffc0203c2e:	00002517          	auipc	a0,0x2
ffffffffc0203c32:	f9a50513          	addi	a0,a0,-102 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203c36:	cccfc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203c3a <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0203c3a:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0203c3e:	8082                	ret

ffffffffc0203c40 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203c40:	7179                	addi	sp,sp,-48
ffffffffc0203c42:	e84a                	sd	s2,16(sp)
ffffffffc0203c44:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203c46:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203c48:	f022                	sd	s0,32(sp)
ffffffffc0203c4a:	ec26                	sd	s1,24(sp)
ffffffffc0203c4c:	e44e                	sd	s3,8(sp)
ffffffffc0203c4e:	f406                	sd	ra,40(sp)
ffffffffc0203c50:	84ae                	mv	s1,a1
ffffffffc0203c52:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203c54:	eedfe0ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
ffffffffc0203c58:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203c5a:	cd09                	beqz	a0,ffffffffc0203c74 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203c5c:	85aa                	mv	a1,a0
ffffffffc0203c5e:	86ce                	mv	a3,s3
ffffffffc0203c60:	8626                	mv	a2,s1
ffffffffc0203c62:	854a                	mv	a0,s2
ffffffffc0203c64:	ad2ff0ef          	jal	ra,ffffffffc0202f36 <page_insert>
ffffffffc0203c68:	ed21                	bnez	a0,ffffffffc0203cc0 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0203c6a:	0000e797          	auipc	a5,0xe
ffffffffc0203c6e:	8ce7a783          	lw	a5,-1842(a5) # ffffffffc0211538 <swap_init_ok>
ffffffffc0203c72:	eb89                	bnez	a5,ffffffffc0203c84 <pgdir_alloc_page+0x44>
}
ffffffffc0203c74:	70a2                	ld	ra,40(sp)
ffffffffc0203c76:	8522                	mv	a0,s0
ffffffffc0203c78:	7402                	ld	s0,32(sp)
ffffffffc0203c7a:	64e2                	ld	s1,24(sp)
ffffffffc0203c7c:	6942                	ld	s2,16(sp)
ffffffffc0203c7e:	69a2                	ld	s3,8(sp)
ffffffffc0203c80:	6145                	addi	sp,sp,48
ffffffffc0203c82:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203c84:	4681                	li	a3,0
ffffffffc0203c86:	8622                	mv	a2,s0
ffffffffc0203c88:	85a6                	mv	a1,s1
ffffffffc0203c8a:	0000e517          	auipc	a0,0xe
ffffffffc0203c8e:	88e53503          	ld	a0,-1906(a0) # ffffffffc0211518 <check_mm_struct>
ffffffffc0203c92:	a04fe0ef          	jal	ra,ffffffffc0201e96 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0203c96:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0203c98:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0203c9a:	4785                	li	a5,1
ffffffffc0203c9c:	fcf70ce3          	beq	a4,a5,ffffffffc0203c74 <pgdir_alloc_page+0x34>
ffffffffc0203ca0:	00002697          	auipc	a3,0x2
ffffffffc0203ca4:	4a068693          	addi	a3,a3,1184 # ffffffffc0206140 <default_pmm_manager+0x5d8>
ffffffffc0203ca8:	00001617          	auipc	a2,0x1
ffffffffc0203cac:	23860613          	addi	a2,a2,568 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203cb0:	18600593          	li	a1,390
ffffffffc0203cb4:	00002517          	auipc	a0,0x2
ffffffffc0203cb8:	f1450513          	addi	a0,a0,-236 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203cbc:	c46fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203cc0:	100027f3          	csrr	a5,sstatus
ffffffffc0203cc4:	8b89                	andi	a5,a5,2
ffffffffc0203cc6:	eb99                	bnez	a5,ffffffffc0203cdc <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203cc8:	0000e797          	auipc	a5,0xe
ffffffffc0203ccc:	8987b783          	ld	a5,-1896(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0203cd0:	739c                	ld	a5,32(a5)
ffffffffc0203cd2:	8522                	mv	a0,s0
ffffffffc0203cd4:	4585                	li	a1,1
ffffffffc0203cd6:	9782                	jalr	a5
            return NULL;
ffffffffc0203cd8:	4401                	li	s0,0
ffffffffc0203cda:	bf69                	j	ffffffffc0203c74 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0203cdc:	813fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203ce0:	0000e797          	auipc	a5,0xe
ffffffffc0203ce4:	8807b783          	ld	a5,-1920(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0203ce8:	739c                	ld	a5,32(a5)
ffffffffc0203cea:	8522                	mv	a0,s0
ffffffffc0203cec:	4585                	li	a1,1
ffffffffc0203cee:	9782                	jalr	a5
            return NULL;
ffffffffc0203cf0:	4401                	li	s0,0
        intr_enable();
ffffffffc0203cf2:	ff6fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203cf6:	bfbd                	j	ffffffffc0203c74 <pgdir_alloc_page+0x34>

ffffffffc0203cf8 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0203cf8:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203cfa:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0203cfc:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203cfe:	fff50713          	addi	a4,a0,-1
ffffffffc0203d02:	17f9                	addi	a5,a5,-2
ffffffffc0203d04:	04e7ea63          	bltu	a5,a4,ffffffffc0203d58 <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203d08:	6785                	lui	a5,0x1
ffffffffc0203d0a:	17fd                	addi	a5,a5,-1
ffffffffc0203d0c:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0203d0e:	8131                	srli	a0,a0,0xc
ffffffffc0203d10:	e31fe0ef          	jal	ra,ffffffffc0202b40 <alloc_pages>
    assert(base != NULL);
ffffffffc0203d14:	cd3d                	beqz	a0,ffffffffc0203d92 <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d16:	0000e797          	auipc	a5,0xe
ffffffffc0203d1a:	8427b783          	ld	a5,-1982(a5) # ffffffffc0211558 <pages>
ffffffffc0203d1e:	8d1d                	sub	a0,a0,a5
ffffffffc0203d20:	00002697          	auipc	a3,0x2
ffffffffc0203d24:	7186b683          	ld	a3,1816(a3) # ffffffffc0206438 <error_string+0x38>
ffffffffc0203d28:	850d                	srai	a0,a0,0x3
ffffffffc0203d2a:	02d50533          	mul	a0,a0,a3
ffffffffc0203d2e:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d32:	0000e717          	auipc	a4,0xe
ffffffffc0203d36:	81e73703          	ld	a4,-2018(a4) # ffffffffc0211550 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d3a:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d3c:	00c51793          	slli	a5,a0,0xc
ffffffffc0203d40:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d42:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d44:	02e7fa63          	bgeu	a5,a4,ffffffffc0203d78 <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0203d48:	60a2                	ld	ra,8(sp)
ffffffffc0203d4a:	0000e797          	auipc	a5,0xe
ffffffffc0203d4e:	81e7b783          	ld	a5,-2018(a5) # ffffffffc0211568 <va_pa_offset>
ffffffffc0203d52:	953e                	add	a0,a0,a5
ffffffffc0203d54:	0141                	addi	sp,sp,16
ffffffffc0203d56:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203d58:	00002697          	auipc	a3,0x2
ffffffffc0203d5c:	40068693          	addi	a3,a3,1024 # ffffffffc0206158 <default_pmm_manager+0x5f0>
ffffffffc0203d60:	00001617          	auipc	a2,0x1
ffffffffc0203d64:	18060613          	addi	a2,a2,384 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203d68:	1fc00593          	li	a1,508
ffffffffc0203d6c:	00002517          	auipc	a0,0x2
ffffffffc0203d70:	e5c50513          	addi	a0,a0,-420 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203d74:	b8efc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203d78:	86aa                	mv	a3,a0
ffffffffc0203d7a:	00002617          	auipc	a2,0x2
ffffffffc0203d7e:	e2660613          	addi	a2,a2,-474 # ffffffffc0205ba0 <default_pmm_manager+0x38>
ffffffffc0203d82:	06b00593          	li	a1,107
ffffffffc0203d86:	00001517          	auipc	a0,0x1
ffffffffc0203d8a:	5ba50513          	addi	a0,a0,1466 # ffffffffc0205340 <commands+0xb78>
ffffffffc0203d8e:	b74fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(base != NULL);
ffffffffc0203d92:	00002697          	auipc	a3,0x2
ffffffffc0203d96:	3e668693          	addi	a3,a3,998 # ffffffffc0206178 <default_pmm_manager+0x610>
ffffffffc0203d9a:	00001617          	auipc	a2,0x1
ffffffffc0203d9e:	14660613          	addi	a2,a2,326 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203da2:	1ff00593          	li	a1,511
ffffffffc0203da6:	00002517          	auipc	a0,0x2
ffffffffc0203daa:	e2250513          	addi	a0,a0,-478 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203dae:	b54fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203db2 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0203db2:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203db4:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0203db6:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203db8:	fff58713          	addi	a4,a1,-1
ffffffffc0203dbc:	17f9                	addi	a5,a5,-2
ffffffffc0203dbe:	0ae7ee63          	bltu	a5,a4,ffffffffc0203e7a <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0203dc2:	cd41                	beqz	a0,ffffffffc0203e5a <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203dc4:	6785                	lui	a5,0x1
ffffffffc0203dc6:	17fd                	addi	a5,a5,-1
ffffffffc0203dc8:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203dca:	c02007b7          	lui	a5,0xc0200
ffffffffc0203dce:	81b1                	srli	a1,a1,0xc
ffffffffc0203dd0:	06f56863          	bltu	a0,a5,ffffffffc0203e40 <kfree+0x8e>
ffffffffc0203dd4:	0000d697          	auipc	a3,0xd
ffffffffc0203dd8:	7946b683          	ld	a3,1940(a3) # ffffffffc0211568 <va_pa_offset>
ffffffffc0203ddc:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc0203dde:	8131                	srli	a0,a0,0xc
ffffffffc0203de0:	0000d797          	auipc	a5,0xd
ffffffffc0203de4:	7707b783          	ld	a5,1904(a5) # ffffffffc0211550 <npage>
ffffffffc0203de8:	04f57a63          	bgeu	a0,a5,ffffffffc0203e3c <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc0203dec:	fff806b7          	lui	a3,0xfff80
ffffffffc0203df0:	9536                	add	a0,a0,a3
ffffffffc0203df2:	00351793          	slli	a5,a0,0x3
ffffffffc0203df6:	953e                	add	a0,a0,a5
ffffffffc0203df8:	050e                	slli	a0,a0,0x3
ffffffffc0203dfa:	0000d797          	auipc	a5,0xd
ffffffffc0203dfe:	75e7b783          	ld	a5,1886(a5) # ffffffffc0211558 <pages>
ffffffffc0203e02:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203e04:	100027f3          	csrr	a5,sstatus
ffffffffc0203e08:	8b89                	andi	a5,a5,2
ffffffffc0203e0a:	eb89                	bnez	a5,ffffffffc0203e1c <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203e0c:	0000d797          	auipc	a5,0xd
ffffffffc0203e10:	7547b783          	ld	a5,1876(a5) # ffffffffc0211560 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0203e14:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc0203e16:	739c                	ld	a5,32(a5)
}
ffffffffc0203e18:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc0203e1a:	8782                	jr	a5
        intr_disable();
ffffffffc0203e1c:	e42a                	sd	a0,8(sp)
ffffffffc0203e1e:	e02e                	sd	a1,0(sp)
ffffffffc0203e20:	ecefc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203e24:	0000d797          	auipc	a5,0xd
ffffffffc0203e28:	73c7b783          	ld	a5,1852(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0203e2c:	6582                	ld	a1,0(sp)
ffffffffc0203e2e:	6522                	ld	a0,8(sp)
ffffffffc0203e30:	739c                	ld	a5,32(a5)
ffffffffc0203e32:	9782                	jalr	a5
}
ffffffffc0203e34:	60e2                	ld	ra,24(sp)
ffffffffc0203e36:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203e38:	eb0fc06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc0203e3c:	ccdfe0ef          	jal	ra,ffffffffc0202b08 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203e40:	86aa                	mv	a3,a0
ffffffffc0203e42:	00002617          	auipc	a2,0x2
ffffffffc0203e46:	e1e60613          	addi	a2,a2,-482 # ffffffffc0205c60 <default_pmm_manager+0xf8>
ffffffffc0203e4a:	06d00593          	li	a1,109
ffffffffc0203e4e:	00001517          	auipc	a0,0x1
ffffffffc0203e52:	4f250513          	addi	a0,a0,1266 # ffffffffc0205340 <commands+0xb78>
ffffffffc0203e56:	aacfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(ptr != NULL);
ffffffffc0203e5a:	00002697          	auipc	a3,0x2
ffffffffc0203e5e:	32e68693          	addi	a3,a3,814 # ffffffffc0206188 <default_pmm_manager+0x620>
ffffffffc0203e62:	00001617          	auipc	a2,0x1
ffffffffc0203e66:	07e60613          	addi	a2,a2,126 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203e6a:	20600593          	li	a1,518
ffffffffc0203e6e:	00002517          	auipc	a0,0x2
ffffffffc0203e72:	d5a50513          	addi	a0,a0,-678 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203e76:	a8cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203e7a:	00002697          	auipc	a3,0x2
ffffffffc0203e7e:	2de68693          	addi	a3,a3,734 # ffffffffc0206158 <default_pmm_manager+0x5f0>
ffffffffc0203e82:	00001617          	auipc	a2,0x1
ffffffffc0203e86:	05e60613          	addi	a2,a2,94 # ffffffffc0204ee0 <commands+0x718>
ffffffffc0203e8a:	20500593          	li	a1,517
ffffffffc0203e8e:	00002517          	auipc	a0,0x2
ffffffffc0203e92:	d3a50513          	addi	a0,a0,-710 # ffffffffc0205bc8 <default_pmm_manager+0x60>
ffffffffc0203e96:	a6cfc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203e9a <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203e9a:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203e9c:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203e9e:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203ea0:	d32fc0ef          	jal	ra,ffffffffc02003d2 <ide_device_valid>
ffffffffc0203ea4:	cd01                	beqz	a0,ffffffffc0203ebc <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203ea6:	4505                	li	a0,1
ffffffffc0203ea8:	d30fc0ef          	jal	ra,ffffffffc02003d8 <ide_device_size>
}
ffffffffc0203eac:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203eae:	810d                	srli	a0,a0,0x3
ffffffffc0203eb0:	0000d797          	auipc	a5,0xd
ffffffffc0203eb4:	66a7bc23          	sd	a0,1656(a5) # ffffffffc0211528 <max_swap_offset>
}
ffffffffc0203eb8:	0141                	addi	sp,sp,16
ffffffffc0203eba:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203ebc:	00002617          	auipc	a2,0x2
ffffffffc0203ec0:	2dc60613          	addi	a2,a2,732 # ffffffffc0206198 <default_pmm_manager+0x630>
ffffffffc0203ec4:	45b5                	li	a1,13
ffffffffc0203ec6:	00002517          	auipc	a0,0x2
ffffffffc0203eca:	2f250513          	addi	a0,a0,754 # ffffffffc02061b8 <default_pmm_manager+0x650>
ffffffffc0203ece:	a34fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203ed2 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203ed2:	1141                	addi	sp,sp,-16
ffffffffc0203ed4:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ed6:	00855793          	srli	a5,a0,0x8
ffffffffc0203eda:	c3a5                	beqz	a5,ffffffffc0203f3a <swapfs_read+0x68>
ffffffffc0203edc:	0000d717          	auipc	a4,0xd
ffffffffc0203ee0:	64c73703          	ld	a4,1612(a4) # ffffffffc0211528 <max_swap_offset>
ffffffffc0203ee4:	04e7fb63          	bgeu	a5,a4,ffffffffc0203f3a <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ee8:	0000d617          	auipc	a2,0xd
ffffffffc0203eec:	67063603          	ld	a2,1648(a2) # ffffffffc0211558 <pages>
ffffffffc0203ef0:	8d91                	sub	a1,a1,a2
ffffffffc0203ef2:	4035d613          	srai	a2,a1,0x3
ffffffffc0203ef6:	00002597          	auipc	a1,0x2
ffffffffc0203efa:	5425b583          	ld	a1,1346(a1) # ffffffffc0206438 <error_string+0x38>
ffffffffc0203efe:	02b60633          	mul	a2,a2,a1
ffffffffc0203f02:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203f06:	00002797          	auipc	a5,0x2
ffffffffc0203f0a:	53a7b783          	ld	a5,1338(a5) # ffffffffc0206440 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f0e:	0000d717          	auipc	a4,0xd
ffffffffc0203f12:	64273703          	ld	a4,1602(a4) # ffffffffc0211550 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f16:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f18:	00c61793          	slli	a5,a2,0xc
ffffffffc0203f1c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f1e:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f20:	02e7f963          	bgeu	a5,a4,ffffffffc0203f52 <swapfs_read+0x80>
}
ffffffffc0203f24:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f26:	0000d797          	auipc	a5,0xd
ffffffffc0203f2a:	6427b783          	ld	a5,1602(a5) # ffffffffc0211568 <va_pa_offset>
ffffffffc0203f2e:	46a1                	li	a3,8
ffffffffc0203f30:	963e                	add	a2,a2,a5
ffffffffc0203f32:	4505                	li	a0,1
}
ffffffffc0203f34:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f36:	ca8fc06f          	j	ffffffffc02003de <ide_read_secs>
ffffffffc0203f3a:	86aa                	mv	a3,a0
ffffffffc0203f3c:	00002617          	auipc	a2,0x2
ffffffffc0203f40:	29460613          	addi	a2,a2,660 # ffffffffc02061d0 <default_pmm_manager+0x668>
ffffffffc0203f44:	45d1                	li	a1,20
ffffffffc0203f46:	00002517          	auipc	a0,0x2
ffffffffc0203f4a:	27250513          	addi	a0,a0,626 # ffffffffc02061b8 <default_pmm_manager+0x650>
ffffffffc0203f4e:	9b4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203f52:	86b2                	mv	a3,a2
ffffffffc0203f54:	06b00593          	li	a1,107
ffffffffc0203f58:	00002617          	auipc	a2,0x2
ffffffffc0203f5c:	c4860613          	addi	a2,a2,-952 # ffffffffc0205ba0 <default_pmm_manager+0x38>
ffffffffc0203f60:	00001517          	auipc	a0,0x1
ffffffffc0203f64:	3e050513          	addi	a0,a0,992 # ffffffffc0205340 <commands+0xb78>
ffffffffc0203f68:	99afc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203f6c <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203f6c:	1141                	addi	sp,sp,-16
ffffffffc0203f6e:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f70:	00855793          	srli	a5,a0,0x8
ffffffffc0203f74:	c3a5                	beqz	a5,ffffffffc0203fd4 <swapfs_write+0x68>
ffffffffc0203f76:	0000d717          	auipc	a4,0xd
ffffffffc0203f7a:	5b273703          	ld	a4,1458(a4) # ffffffffc0211528 <max_swap_offset>
ffffffffc0203f7e:	04e7fb63          	bgeu	a5,a4,ffffffffc0203fd4 <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f82:	0000d617          	auipc	a2,0xd
ffffffffc0203f86:	5d663603          	ld	a2,1494(a2) # ffffffffc0211558 <pages>
ffffffffc0203f8a:	8d91                	sub	a1,a1,a2
ffffffffc0203f8c:	4035d613          	srai	a2,a1,0x3
ffffffffc0203f90:	00002597          	auipc	a1,0x2
ffffffffc0203f94:	4a85b583          	ld	a1,1192(a1) # ffffffffc0206438 <error_string+0x38>
ffffffffc0203f98:	02b60633          	mul	a2,a2,a1
ffffffffc0203f9c:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203fa0:	00002797          	auipc	a5,0x2
ffffffffc0203fa4:	4a07b783          	ld	a5,1184(a5) # ffffffffc0206440 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203fa8:	0000d717          	auipc	a4,0xd
ffffffffc0203fac:	5a873703          	ld	a4,1448(a4) # ffffffffc0211550 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203fb0:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203fb2:	00c61793          	slli	a5,a2,0xc
ffffffffc0203fb6:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203fb8:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203fba:	02e7f963          	bgeu	a5,a4,ffffffffc0203fec <swapfs_write+0x80>
}
ffffffffc0203fbe:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203fc0:	0000d797          	auipc	a5,0xd
ffffffffc0203fc4:	5a87b783          	ld	a5,1448(a5) # ffffffffc0211568 <va_pa_offset>
ffffffffc0203fc8:	46a1                	li	a3,8
ffffffffc0203fca:	963e                	add	a2,a2,a5
ffffffffc0203fcc:	4505                	li	a0,1
}
ffffffffc0203fce:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203fd0:	c32fc06f          	j	ffffffffc0200402 <ide_write_secs>
ffffffffc0203fd4:	86aa                	mv	a3,a0
ffffffffc0203fd6:	00002617          	auipc	a2,0x2
ffffffffc0203fda:	1fa60613          	addi	a2,a2,506 # ffffffffc02061d0 <default_pmm_manager+0x668>
ffffffffc0203fde:	45e5                	li	a1,25
ffffffffc0203fe0:	00002517          	auipc	a0,0x2
ffffffffc0203fe4:	1d850513          	addi	a0,a0,472 # ffffffffc02061b8 <default_pmm_manager+0x650>
ffffffffc0203fe8:	91afc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203fec:	86b2                	mv	a3,a2
ffffffffc0203fee:	06b00593          	li	a1,107
ffffffffc0203ff2:	00002617          	auipc	a2,0x2
ffffffffc0203ff6:	bae60613          	addi	a2,a2,-1106 # ffffffffc0205ba0 <default_pmm_manager+0x38>
ffffffffc0203ffa:	00001517          	auipc	a0,0x1
ffffffffc0203ffe:	34650513          	addi	a0,a0,838 # ffffffffc0205340 <commands+0xb78>
ffffffffc0204002:	900fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0204006 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204006:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc020400a:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc020400c:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc020400e:	cb81                	beqz	a5,ffffffffc020401e <strlen+0x18>
        cnt ++;
ffffffffc0204010:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0204012:	00a707b3          	add	a5,a4,a0
ffffffffc0204016:	0007c783          	lbu	a5,0(a5)
ffffffffc020401a:	fbfd                	bnez	a5,ffffffffc0204010 <strlen+0xa>
ffffffffc020401c:	8082                	ret
    }
    return cnt;
}
ffffffffc020401e:	8082                	ret

ffffffffc0204020 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0204020:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204022:	e589                	bnez	a1,ffffffffc020402c <strnlen+0xc>
ffffffffc0204024:	a811                	j	ffffffffc0204038 <strnlen+0x18>
        cnt ++;
ffffffffc0204026:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204028:	00f58863          	beq	a1,a5,ffffffffc0204038 <strnlen+0x18>
ffffffffc020402c:	00f50733          	add	a4,a0,a5
ffffffffc0204030:	00074703          	lbu	a4,0(a4)
ffffffffc0204034:	fb6d                	bnez	a4,ffffffffc0204026 <strnlen+0x6>
ffffffffc0204036:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0204038:	852e                	mv	a0,a1
ffffffffc020403a:	8082                	ret

ffffffffc020403c <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020403c:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020403e:	0005c703          	lbu	a4,0(a1)
ffffffffc0204042:	0785                	addi	a5,a5,1
ffffffffc0204044:	0585                	addi	a1,a1,1
ffffffffc0204046:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020404a:	fb75                	bnez	a4,ffffffffc020403e <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020404c:	8082                	ret

ffffffffc020404e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020404e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204052:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204056:	cb89                	beqz	a5,ffffffffc0204068 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0204058:	0505                	addi	a0,a0,1
ffffffffc020405a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020405c:	fee789e3          	beq	a5,a4,ffffffffc020404e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204060:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204064:	9d19                	subw	a0,a0,a4
ffffffffc0204066:	8082                	ret
ffffffffc0204068:	4501                	li	a0,0
ffffffffc020406a:	bfed                	j	ffffffffc0204064 <strcmp+0x16>

ffffffffc020406c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020406c:	00054783          	lbu	a5,0(a0)
ffffffffc0204070:	c799                	beqz	a5,ffffffffc020407e <strchr+0x12>
        if (*s == c) {
ffffffffc0204072:	00f58763          	beq	a1,a5,ffffffffc0204080 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0204076:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020407a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020407c:	fbfd                	bnez	a5,ffffffffc0204072 <strchr+0x6>
    }
    return NULL;
ffffffffc020407e:	4501                	li	a0,0
}
ffffffffc0204080:	8082                	ret

ffffffffc0204082 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204082:	ca01                	beqz	a2,ffffffffc0204092 <memset+0x10>
ffffffffc0204084:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204086:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204088:	0785                	addi	a5,a5,1
ffffffffc020408a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020408e:	fec79de3          	bne	a5,a2,ffffffffc0204088 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204092:	8082                	ret

ffffffffc0204094 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204094:	ca19                	beqz	a2,ffffffffc02040aa <memcpy+0x16>
ffffffffc0204096:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204098:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020409a:	0005c703          	lbu	a4,0(a1)
ffffffffc020409e:	0585                	addi	a1,a1,1
ffffffffc02040a0:	0785                	addi	a5,a5,1
ffffffffc02040a2:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02040a6:	fec59ae3          	bne	a1,a2,ffffffffc020409a <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02040aa:	8082                	ret

ffffffffc02040ac <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02040ac:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02040b0:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02040b2:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02040b6:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02040b8:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02040bc:	f022                	sd	s0,32(sp)
ffffffffc02040be:	ec26                	sd	s1,24(sp)
ffffffffc02040c0:	e84a                	sd	s2,16(sp)
ffffffffc02040c2:	f406                	sd	ra,40(sp)
ffffffffc02040c4:	e44e                	sd	s3,8(sp)
ffffffffc02040c6:	84aa                	mv	s1,a0
ffffffffc02040c8:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02040ca:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02040ce:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02040d0:	03067e63          	bgeu	a2,a6,ffffffffc020410c <printnum+0x60>
ffffffffc02040d4:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02040d6:	00805763          	blez	s0,ffffffffc02040e4 <printnum+0x38>
ffffffffc02040da:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02040dc:	85ca                	mv	a1,s2
ffffffffc02040de:	854e                	mv	a0,s3
ffffffffc02040e0:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02040e2:	fc65                	bnez	s0,ffffffffc02040da <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02040e4:	1a02                	slli	s4,s4,0x20
ffffffffc02040e6:	00002797          	auipc	a5,0x2
ffffffffc02040ea:	10a78793          	addi	a5,a5,266 # ffffffffc02061f0 <default_pmm_manager+0x688>
ffffffffc02040ee:	020a5a13          	srli	s4,s4,0x20
ffffffffc02040f2:	9a3e                	add	s4,s4,a5
}
ffffffffc02040f4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02040f6:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02040fa:	70a2                	ld	ra,40(sp)
ffffffffc02040fc:	69a2                	ld	s3,8(sp)
ffffffffc02040fe:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204100:	85ca                	mv	a1,s2
ffffffffc0204102:	87a6                	mv	a5,s1
}
ffffffffc0204104:	6942                	ld	s2,16(sp)
ffffffffc0204106:	64e2                	ld	s1,24(sp)
ffffffffc0204108:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020410a:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020410c:	03065633          	divu	a2,a2,a6
ffffffffc0204110:	8722                	mv	a4,s0
ffffffffc0204112:	f9bff0ef          	jal	ra,ffffffffc02040ac <printnum>
ffffffffc0204116:	b7f9                	j	ffffffffc02040e4 <printnum+0x38>

ffffffffc0204118 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204118:	7119                	addi	sp,sp,-128
ffffffffc020411a:	f4a6                	sd	s1,104(sp)
ffffffffc020411c:	f0ca                	sd	s2,96(sp)
ffffffffc020411e:	ecce                	sd	s3,88(sp)
ffffffffc0204120:	e8d2                	sd	s4,80(sp)
ffffffffc0204122:	e4d6                	sd	s5,72(sp)
ffffffffc0204124:	e0da                	sd	s6,64(sp)
ffffffffc0204126:	fc5e                	sd	s7,56(sp)
ffffffffc0204128:	f06a                	sd	s10,32(sp)
ffffffffc020412a:	fc86                	sd	ra,120(sp)
ffffffffc020412c:	f8a2                	sd	s0,112(sp)
ffffffffc020412e:	f862                	sd	s8,48(sp)
ffffffffc0204130:	f466                	sd	s9,40(sp)
ffffffffc0204132:	ec6e                	sd	s11,24(sp)
ffffffffc0204134:	892a                	mv	s2,a0
ffffffffc0204136:	84ae                	mv	s1,a1
ffffffffc0204138:	8d32                	mv	s10,a2
ffffffffc020413a:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020413c:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204140:	5b7d                	li	s6,-1
ffffffffc0204142:	00002a97          	auipc	s5,0x2
ffffffffc0204146:	0e2a8a93          	addi	s5,s5,226 # ffffffffc0206224 <default_pmm_manager+0x6bc>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020414a:	00002b97          	auipc	s7,0x2
ffffffffc020414e:	2b6b8b93          	addi	s7,s7,694 # ffffffffc0206400 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204152:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0204156:	001d0413          	addi	s0,s10,1
ffffffffc020415a:	01350a63          	beq	a0,s3,ffffffffc020416e <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020415e:	c121                	beqz	a0,ffffffffc020419e <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204160:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204162:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204164:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204166:	fff44503          	lbu	a0,-1(s0)
ffffffffc020416a:	ff351ae3          	bne	a0,s3,ffffffffc020415e <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020416e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204172:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204176:	4c81                	li	s9,0
ffffffffc0204178:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020417a:	5c7d                	li	s8,-1
ffffffffc020417c:	5dfd                	li	s11,-1
ffffffffc020417e:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0204182:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204184:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204188:	0ff5f593          	zext.b	a1,a1
ffffffffc020418c:	00140d13          	addi	s10,s0,1
ffffffffc0204190:	04b56263          	bltu	a0,a1,ffffffffc02041d4 <vprintfmt+0xbc>
ffffffffc0204194:	058a                	slli	a1,a1,0x2
ffffffffc0204196:	95d6                	add	a1,a1,s5
ffffffffc0204198:	4194                	lw	a3,0(a1)
ffffffffc020419a:	96d6                	add	a3,a3,s5
ffffffffc020419c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020419e:	70e6                	ld	ra,120(sp)
ffffffffc02041a0:	7446                	ld	s0,112(sp)
ffffffffc02041a2:	74a6                	ld	s1,104(sp)
ffffffffc02041a4:	7906                	ld	s2,96(sp)
ffffffffc02041a6:	69e6                	ld	s3,88(sp)
ffffffffc02041a8:	6a46                	ld	s4,80(sp)
ffffffffc02041aa:	6aa6                	ld	s5,72(sp)
ffffffffc02041ac:	6b06                	ld	s6,64(sp)
ffffffffc02041ae:	7be2                	ld	s7,56(sp)
ffffffffc02041b0:	7c42                	ld	s8,48(sp)
ffffffffc02041b2:	7ca2                	ld	s9,40(sp)
ffffffffc02041b4:	7d02                	ld	s10,32(sp)
ffffffffc02041b6:	6de2                	ld	s11,24(sp)
ffffffffc02041b8:	6109                	addi	sp,sp,128
ffffffffc02041ba:	8082                	ret
            padc = '0';
ffffffffc02041bc:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02041be:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041c2:	846a                	mv	s0,s10
ffffffffc02041c4:	00140d13          	addi	s10,s0,1
ffffffffc02041c8:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02041cc:	0ff5f593          	zext.b	a1,a1
ffffffffc02041d0:	fcb572e3          	bgeu	a0,a1,ffffffffc0204194 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02041d4:	85a6                	mv	a1,s1
ffffffffc02041d6:	02500513          	li	a0,37
ffffffffc02041da:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02041dc:	fff44783          	lbu	a5,-1(s0)
ffffffffc02041e0:	8d22                	mv	s10,s0
ffffffffc02041e2:	f73788e3          	beq	a5,s3,ffffffffc0204152 <vprintfmt+0x3a>
ffffffffc02041e6:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02041ea:	1d7d                	addi	s10,s10,-1
ffffffffc02041ec:	ff379de3          	bne	a5,s3,ffffffffc02041e6 <vprintfmt+0xce>
ffffffffc02041f0:	b78d                	j	ffffffffc0204152 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02041f2:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02041f6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041fa:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02041fc:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204200:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204204:	02d86463          	bltu	a6,a3,ffffffffc020422c <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0204208:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020420c:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204210:	0186873b          	addw	a4,a3,s8
ffffffffc0204214:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204218:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020421a:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020421e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204220:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204224:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204228:	fed870e3          	bgeu	a6,a3,ffffffffc0204208 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020422c:	f40ddce3          	bgez	s11,ffffffffc0204184 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204230:	8de2                	mv	s11,s8
ffffffffc0204232:	5c7d                	li	s8,-1
ffffffffc0204234:	bf81                	j	ffffffffc0204184 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0204236:	fffdc693          	not	a3,s11
ffffffffc020423a:	96fd                	srai	a3,a3,0x3f
ffffffffc020423c:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204240:	00144603          	lbu	a2,1(s0)
ffffffffc0204244:	2d81                	sext.w	s11,s11
ffffffffc0204246:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204248:	bf35                	j	ffffffffc0204184 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020424a:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020424e:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204252:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204254:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204256:	bfd9                	j	ffffffffc020422c <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0204258:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020425a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020425e:	01174463          	blt	a4,a7,ffffffffc0204266 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204262:	1a088e63          	beqz	a7,ffffffffc020441e <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204266:	000a3603          	ld	a2,0(s4)
ffffffffc020426a:	46c1                	li	a3,16
ffffffffc020426c:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020426e:	2781                	sext.w	a5,a5
ffffffffc0204270:	876e                	mv	a4,s11
ffffffffc0204272:	85a6                	mv	a1,s1
ffffffffc0204274:	854a                	mv	a0,s2
ffffffffc0204276:	e37ff0ef          	jal	ra,ffffffffc02040ac <printnum>
            break;
ffffffffc020427a:	bde1                	j	ffffffffc0204152 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020427c:	000a2503          	lw	a0,0(s4)
ffffffffc0204280:	85a6                	mv	a1,s1
ffffffffc0204282:	0a21                	addi	s4,s4,8
ffffffffc0204284:	9902                	jalr	s2
            break;
ffffffffc0204286:	b5f1                	j	ffffffffc0204152 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204288:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020428a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020428e:	01174463          	blt	a4,a7,ffffffffc0204296 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0204292:	18088163          	beqz	a7,ffffffffc0204414 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0204296:	000a3603          	ld	a2,0(s4)
ffffffffc020429a:	46a9                	li	a3,10
ffffffffc020429c:	8a2e                	mv	s4,a1
ffffffffc020429e:	bfc1                	j	ffffffffc020426e <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02042a0:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02042a4:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02042a6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02042a8:	bdf1                	j	ffffffffc0204184 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02042aa:	85a6                	mv	a1,s1
ffffffffc02042ac:	02500513          	li	a0,37
ffffffffc02042b0:	9902                	jalr	s2
            break;
ffffffffc02042b2:	b545                	j	ffffffffc0204152 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02042b4:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02042b8:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02042ba:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02042bc:	b5e1                	j	ffffffffc0204184 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02042be:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02042c0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02042c4:	01174463          	blt	a4,a7,ffffffffc02042cc <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02042c8:	14088163          	beqz	a7,ffffffffc020440a <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02042cc:	000a3603          	ld	a2,0(s4)
ffffffffc02042d0:	46a1                	li	a3,8
ffffffffc02042d2:	8a2e                	mv	s4,a1
ffffffffc02042d4:	bf69                	j	ffffffffc020426e <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02042d6:	03000513          	li	a0,48
ffffffffc02042da:	85a6                	mv	a1,s1
ffffffffc02042dc:	e03e                	sd	a5,0(sp)
ffffffffc02042de:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02042e0:	85a6                	mv	a1,s1
ffffffffc02042e2:	07800513          	li	a0,120
ffffffffc02042e6:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02042e8:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02042ea:	6782                	ld	a5,0(sp)
ffffffffc02042ec:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02042ee:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02042f2:	bfb5                	j	ffffffffc020426e <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02042f4:	000a3403          	ld	s0,0(s4)
ffffffffc02042f8:	008a0713          	addi	a4,s4,8
ffffffffc02042fc:	e03a                	sd	a4,0(sp)
ffffffffc02042fe:	14040263          	beqz	s0,ffffffffc0204442 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204302:	0fb05763          	blez	s11,ffffffffc02043f0 <vprintfmt+0x2d8>
ffffffffc0204306:	02d00693          	li	a3,45
ffffffffc020430a:	0cd79163          	bne	a5,a3,ffffffffc02043cc <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020430e:	00044783          	lbu	a5,0(s0)
ffffffffc0204312:	0007851b          	sext.w	a0,a5
ffffffffc0204316:	cf85                	beqz	a5,ffffffffc020434e <vprintfmt+0x236>
ffffffffc0204318:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020431c:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204320:	000c4563          	bltz	s8,ffffffffc020432a <vprintfmt+0x212>
ffffffffc0204324:	3c7d                	addiw	s8,s8,-1
ffffffffc0204326:	036c0263          	beq	s8,s6,ffffffffc020434a <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020432a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020432c:	0e0c8e63          	beqz	s9,ffffffffc0204428 <vprintfmt+0x310>
ffffffffc0204330:	3781                	addiw	a5,a5,-32
ffffffffc0204332:	0ef47b63          	bgeu	s0,a5,ffffffffc0204428 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0204336:	03f00513          	li	a0,63
ffffffffc020433a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020433c:	000a4783          	lbu	a5,0(s4)
ffffffffc0204340:	3dfd                	addiw	s11,s11,-1
ffffffffc0204342:	0a05                	addi	s4,s4,1
ffffffffc0204344:	0007851b          	sext.w	a0,a5
ffffffffc0204348:	ffe1                	bnez	a5,ffffffffc0204320 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020434a:	01b05963          	blez	s11,ffffffffc020435c <vprintfmt+0x244>
ffffffffc020434e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204350:	85a6                	mv	a1,s1
ffffffffc0204352:	02000513          	li	a0,32
ffffffffc0204356:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204358:	fe0d9be3          	bnez	s11,ffffffffc020434e <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020435c:	6a02                	ld	s4,0(sp)
ffffffffc020435e:	bbd5                	j	ffffffffc0204152 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204360:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204362:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0204366:	01174463          	blt	a4,a7,ffffffffc020436e <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020436a:	08088d63          	beqz	a7,ffffffffc0204404 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020436e:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204372:	0a044d63          	bltz	s0,ffffffffc020442c <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0204376:	8622                	mv	a2,s0
ffffffffc0204378:	8a66                	mv	s4,s9
ffffffffc020437a:	46a9                	li	a3,10
ffffffffc020437c:	bdcd                	j	ffffffffc020426e <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020437e:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204382:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204384:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0204386:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020438a:	8fb5                	xor	a5,a5,a3
ffffffffc020438c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204390:	02d74163          	blt	a4,a3,ffffffffc02043b2 <vprintfmt+0x29a>
ffffffffc0204394:	00369793          	slli	a5,a3,0x3
ffffffffc0204398:	97de                	add	a5,a5,s7
ffffffffc020439a:	639c                	ld	a5,0(a5)
ffffffffc020439c:	cb99                	beqz	a5,ffffffffc02043b2 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020439e:	86be                	mv	a3,a5
ffffffffc02043a0:	00002617          	auipc	a2,0x2
ffffffffc02043a4:	e8060613          	addi	a2,a2,-384 # ffffffffc0206220 <default_pmm_manager+0x6b8>
ffffffffc02043a8:	85a6                	mv	a1,s1
ffffffffc02043aa:	854a                	mv	a0,s2
ffffffffc02043ac:	0ce000ef          	jal	ra,ffffffffc020447a <printfmt>
ffffffffc02043b0:	b34d                	j	ffffffffc0204152 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02043b2:	00002617          	auipc	a2,0x2
ffffffffc02043b6:	e5e60613          	addi	a2,a2,-418 # ffffffffc0206210 <default_pmm_manager+0x6a8>
ffffffffc02043ba:	85a6                	mv	a1,s1
ffffffffc02043bc:	854a                	mv	a0,s2
ffffffffc02043be:	0bc000ef          	jal	ra,ffffffffc020447a <printfmt>
ffffffffc02043c2:	bb41                	j	ffffffffc0204152 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02043c4:	00002417          	auipc	s0,0x2
ffffffffc02043c8:	e4440413          	addi	s0,s0,-444 # ffffffffc0206208 <default_pmm_manager+0x6a0>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02043cc:	85e2                	mv	a1,s8
ffffffffc02043ce:	8522                	mv	a0,s0
ffffffffc02043d0:	e43e                	sd	a5,8(sp)
ffffffffc02043d2:	c4fff0ef          	jal	ra,ffffffffc0204020 <strnlen>
ffffffffc02043d6:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02043da:	01b05b63          	blez	s11,ffffffffc02043f0 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02043de:	67a2                	ld	a5,8(sp)
ffffffffc02043e0:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02043e4:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02043e6:	85a6                	mv	a1,s1
ffffffffc02043e8:	8552                	mv	a0,s4
ffffffffc02043ea:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02043ec:	fe0d9ce3          	bnez	s11,ffffffffc02043e4 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02043f0:	00044783          	lbu	a5,0(s0)
ffffffffc02043f4:	00140a13          	addi	s4,s0,1
ffffffffc02043f8:	0007851b          	sext.w	a0,a5
ffffffffc02043fc:	d3a5                	beqz	a5,ffffffffc020435c <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02043fe:	05e00413          	li	s0,94
ffffffffc0204402:	bf39                	j	ffffffffc0204320 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204404:	000a2403          	lw	s0,0(s4)
ffffffffc0204408:	b7ad                	j	ffffffffc0204372 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020440a:	000a6603          	lwu	a2,0(s4)
ffffffffc020440e:	46a1                	li	a3,8
ffffffffc0204410:	8a2e                	mv	s4,a1
ffffffffc0204412:	bdb1                	j	ffffffffc020426e <vprintfmt+0x156>
ffffffffc0204414:	000a6603          	lwu	a2,0(s4)
ffffffffc0204418:	46a9                	li	a3,10
ffffffffc020441a:	8a2e                	mv	s4,a1
ffffffffc020441c:	bd89                	j	ffffffffc020426e <vprintfmt+0x156>
ffffffffc020441e:	000a6603          	lwu	a2,0(s4)
ffffffffc0204422:	46c1                	li	a3,16
ffffffffc0204424:	8a2e                	mv	s4,a1
ffffffffc0204426:	b5a1                	j	ffffffffc020426e <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204428:	9902                	jalr	s2
ffffffffc020442a:	bf09                	j	ffffffffc020433c <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020442c:	85a6                	mv	a1,s1
ffffffffc020442e:	02d00513          	li	a0,45
ffffffffc0204432:	e03e                	sd	a5,0(sp)
ffffffffc0204434:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204436:	6782                	ld	a5,0(sp)
ffffffffc0204438:	8a66                	mv	s4,s9
ffffffffc020443a:	40800633          	neg	a2,s0
ffffffffc020443e:	46a9                	li	a3,10
ffffffffc0204440:	b53d                	j	ffffffffc020426e <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204442:	03b05163          	blez	s11,ffffffffc0204464 <vprintfmt+0x34c>
ffffffffc0204446:	02d00693          	li	a3,45
ffffffffc020444a:	f6d79de3          	bne	a5,a3,ffffffffc02043c4 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020444e:	00002417          	auipc	s0,0x2
ffffffffc0204452:	dba40413          	addi	s0,s0,-582 # ffffffffc0206208 <default_pmm_manager+0x6a0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204456:	02800793          	li	a5,40
ffffffffc020445a:	02800513          	li	a0,40
ffffffffc020445e:	00140a13          	addi	s4,s0,1
ffffffffc0204462:	bd6d                	j	ffffffffc020431c <vprintfmt+0x204>
ffffffffc0204464:	00002a17          	auipc	s4,0x2
ffffffffc0204468:	da5a0a13          	addi	s4,s4,-603 # ffffffffc0206209 <default_pmm_manager+0x6a1>
ffffffffc020446c:	02800513          	li	a0,40
ffffffffc0204470:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204474:	05e00413          	li	s0,94
ffffffffc0204478:	b565                	j	ffffffffc0204320 <vprintfmt+0x208>

ffffffffc020447a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020447a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020447c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204480:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204482:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204484:	ec06                	sd	ra,24(sp)
ffffffffc0204486:	f83a                	sd	a4,48(sp)
ffffffffc0204488:	fc3e                	sd	a5,56(sp)
ffffffffc020448a:	e0c2                	sd	a6,64(sp)
ffffffffc020448c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020448e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204490:	c89ff0ef          	jal	ra,ffffffffc0204118 <vprintfmt>
}
ffffffffc0204494:	60e2                	ld	ra,24(sp)
ffffffffc0204496:	6161                	addi	sp,sp,80
ffffffffc0204498:	8082                	ret

ffffffffc020449a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020449a:	715d                	addi	sp,sp,-80
ffffffffc020449c:	e486                	sd	ra,72(sp)
ffffffffc020449e:	e0a6                	sd	s1,64(sp)
ffffffffc02044a0:	fc4a                	sd	s2,56(sp)
ffffffffc02044a2:	f84e                	sd	s3,48(sp)
ffffffffc02044a4:	f452                	sd	s4,40(sp)
ffffffffc02044a6:	f056                	sd	s5,32(sp)
ffffffffc02044a8:	ec5a                	sd	s6,24(sp)
ffffffffc02044aa:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02044ac:	c901                	beqz	a0,ffffffffc02044bc <readline+0x22>
ffffffffc02044ae:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02044b0:	00002517          	auipc	a0,0x2
ffffffffc02044b4:	d7050513          	addi	a0,a0,-656 # ffffffffc0206220 <default_pmm_manager+0x6b8>
ffffffffc02044b8:	c03fb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc02044bc:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02044be:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02044c0:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02044c2:	4aa9                	li	s5,10
ffffffffc02044c4:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02044c6:	0000db97          	auipc	s7,0xd
ffffffffc02044ca:	c32b8b93          	addi	s7,s7,-974 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02044ce:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02044d2:	c21fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02044d6:	00054a63          	bltz	a0,ffffffffc02044ea <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02044da:	00a95a63          	bge	s2,a0,ffffffffc02044ee <readline+0x54>
ffffffffc02044de:	029a5263          	bge	s4,s1,ffffffffc0204502 <readline+0x68>
        c = getchar();
ffffffffc02044e2:	c11fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02044e6:	fe055ae3          	bgez	a0,ffffffffc02044da <readline+0x40>
            return NULL;
ffffffffc02044ea:	4501                	li	a0,0
ffffffffc02044ec:	a091                	j	ffffffffc0204530 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02044ee:	03351463          	bne	a0,s3,ffffffffc0204516 <readline+0x7c>
ffffffffc02044f2:	e8a9                	bnez	s1,ffffffffc0204544 <readline+0xaa>
        c = getchar();
ffffffffc02044f4:	bfffb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02044f8:	fe0549e3          	bltz	a0,ffffffffc02044ea <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02044fc:	fea959e3          	bge	s2,a0,ffffffffc02044ee <readline+0x54>
ffffffffc0204500:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204502:	e42a                	sd	a0,8(sp)
ffffffffc0204504:	bedfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc0204508:	6522                	ld	a0,8(sp)
ffffffffc020450a:	009b87b3          	add	a5,s7,s1
ffffffffc020450e:	2485                	addiw	s1,s1,1
ffffffffc0204510:	00a78023          	sb	a0,0(a5)
ffffffffc0204514:	bf7d                	j	ffffffffc02044d2 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0204516:	01550463          	beq	a0,s5,ffffffffc020451e <readline+0x84>
ffffffffc020451a:	fb651ce3          	bne	a0,s6,ffffffffc02044d2 <readline+0x38>
            cputchar(c);
ffffffffc020451e:	bd3fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc0204522:	0000d517          	auipc	a0,0xd
ffffffffc0204526:	bd650513          	addi	a0,a0,-1066 # ffffffffc02110f8 <buf>
ffffffffc020452a:	94aa                	add	s1,s1,a0
ffffffffc020452c:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204530:	60a6                	ld	ra,72(sp)
ffffffffc0204532:	6486                	ld	s1,64(sp)
ffffffffc0204534:	7962                	ld	s2,56(sp)
ffffffffc0204536:	79c2                	ld	s3,48(sp)
ffffffffc0204538:	7a22                	ld	s4,40(sp)
ffffffffc020453a:	7a82                	ld	s5,32(sp)
ffffffffc020453c:	6b62                	ld	s6,24(sp)
ffffffffc020453e:	6bc2                	ld	s7,16(sp)
ffffffffc0204540:	6161                	addi	sp,sp,80
ffffffffc0204542:	8082                	ret
            cputchar(c);
ffffffffc0204544:	4521                	li	a0,8
ffffffffc0204546:	babfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc020454a:	34fd                	addiw	s1,s1,-1
ffffffffc020454c:	b759                	j	ffffffffc02044d2 <readline+0x38>
