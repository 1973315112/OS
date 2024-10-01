
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
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
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

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


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	43660613          	addi	a2,a2,1078 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	52a010ef          	jal	ra,ffffffffc0201574 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	a2650513          	addi	a0,a0,-1498 # ffffffffc0201a78 <etext>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	138000ef          	jal	ra,ffffffffc0200196 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	053000ef          	jal	ra,ffffffffc02008b8 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1) {}
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	54c010ef          	jal	ra,ffffffffc02015f2 <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	516010ef          	jal	ra,ffffffffc02015f2 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020013a:	00006317          	auipc	t1,0x6
ffffffffc020013e:	2ee30313          	addi	t1,t1,750 # ffffffffc0206428 <is_panic>
ffffffffc0200142:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200146:	715d                	addi	sp,sp,-80
ffffffffc0200148:	ec06                	sd	ra,24(sp)
ffffffffc020014a:	e822                	sd	s0,16(sp)
ffffffffc020014c:	f436                	sd	a3,40(sp)
ffffffffc020014e:	f83a                	sd	a4,48(sp)
ffffffffc0200150:	fc3e                	sd	a5,56(sp)
ffffffffc0200152:	e0c2                	sd	a6,64(sp)
ffffffffc0200154:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200156:	020e1a63          	bnez	t3,ffffffffc020018a <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020015a:	4785                	li	a5,1
ffffffffc020015c:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200160:	8432                	mv	s0,a2
ffffffffc0200162:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200164:	862e                	mv	a2,a1
ffffffffc0200166:	85aa                	mv	a1,a0
ffffffffc0200168:	00002517          	auipc	a0,0x2
ffffffffc020016c:	93050513          	addi	a0,a0,-1744 # ffffffffc0201a98 <etext+0x20>
    va_start(ap, fmt);
ffffffffc0200170:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200172:	f41ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200176:	65a2                	ld	a1,8(sp)
ffffffffc0200178:	8522                	mv	a0,s0
ffffffffc020017a:	f19ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc020017e:	00002517          	auipc	a0,0x2
ffffffffc0200182:	a0250513          	addi	a0,a0,-1534 # ffffffffc0201b80 <etext+0x108>
ffffffffc0200186:	f2dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020018a:	2d4000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020018e:	4501                	li	a0,0
ffffffffc0200190:	130000ef          	jal	ra,ffffffffc02002c0 <kmonitor>
    while (1) {
ffffffffc0200194:	bfed                	j	ffffffffc020018e <__panic+0x54>

ffffffffc0200196 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200196:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200198:	00002517          	auipc	a0,0x2
ffffffffc020019c:	92050513          	addi	a0,a0,-1760 # ffffffffc0201ab8 <etext+0x40>
void print_kerninfo(void) {
ffffffffc02001a0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001a2:	f11ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001a6:	00000597          	auipc	a1,0x0
ffffffffc02001aa:	e8c58593          	addi	a1,a1,-372 # ffffffffc0200032 <kern_init>
ffffffffc02001ae:	00002517          	auipc	a0,0x2
ffffffffc02001b2:	92a50513          	addi	a0,a0,-1750 # ffffffffc0201ad8 <etext+0x60>
ffffffffc02001b6:	efdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001ba:	00002597          	auipc	a1,0x2
ffffffffc02001be:	8be58593          	addi	a1,a1,-1858 # ffffffffc0201a78 <etext>
ffffffffc02001c2:	00002517          	auipc	a0,0x2
ffffffffc02001c6:	93650513          	addi	a0,a0,-1738 # ffffffffc0201af8 <etext+0x80>
ffffffffc02001ca:	ee9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001ce:	00006597          	auipc	a1,0x6
ffffffffc02001d2:	e4258593          	addi	a1,a1,-446 # ffffffffc0206010 <free_area>
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	94250513          	addi	a0,a0,-1726 # ffffffffc0201b18 <etext+0xa0>
ffffffffc02001de:	ed5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001e2:	00006597          	auipc	a1,0x6
ffffffffc02001e6:	28e58593          	addi	a1,a1,654 # ffffffffc0206470 <end>
ffffffffc02001ea:	00002517          	auipc	a0,0x2
ffffffffc02001ee:	94e50513          	addi	a0,a0,-1714 # ffffffffc0201b38 <etext+0xc0>
ffffffffc02001f2:	ec1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001f6:	00006597          	auipc	a1,0x6
ffffffffc02001fa:	67958593          	addi	a1,a1,1657 # ffffffffc020686f <end+0x3ff>
ffffffffc02001fe:	00000797          	auipc	a5,0x0
ffffffffc0200202:	e3478793          	addi	a5,a5,-460 # ffffffffc0200032 <kern_init>
ffffffffc0200206:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020020a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020020e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200210:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200214:	95be                	add	a1,a1,a5
ffffffffc0200216:	85a9                	srai	a1,a1,0xa
ffffffffc0200218:	00002517          	auipc	a0,0x2
ffffffffc020021c:	94050513          	addi	a0,a0,-1728 # ffffffffc0201b58 <etext+0xe0>
}
ffffffffc0200220:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200222:	bd41                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200224 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200224:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	96260613          	addi	a2,a2,-1694 # ffffffffc0201b88 <etext+0x110>
ffffffffc020022e:	04e00593          	li	a1,78
ffffffffc0200232:	00002517          	auipc	a0,0x2
ffffffffc0200236:	96e50513          	addi	a0,a0,-1682 # ffffffffc0201ba0 <etext+0x128>
void print_stackframe(void) {
ffffffffc020023a:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020023c:	effff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200240 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200240:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200242:	00002617          	auipc	a2,0x2
ffffffffc0200246:	97660613          	addi	a2,a2,-1674 # ffffffffc0201bb8 <etext+0x140>
ffffffffc020024a:	00002597          	auipc	a1,0x2
ffffffffc020024e:	98e58593          	addi	a1,a1,-1650 # ffffffffc0201bd8 <etext+0x160>
ffffffffc0200252:	00002517          	auipc	a0,0x2
ffffffffc0200256:	98e50513          	addi	a0,a0,-1650 # ffffffffc0201be0 <etext+0x168>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020025c:	e57ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200260:	00002617          	auipc	a2,0x2
ffffffffc0200264:	99060613          	addi	a2,a2,-1648 # ffffffffc0201bf0 <etext+0x178>
ffffffffc0200268:	00002597          	auipc	a1,0x2
ffffffffc020026c:	9b058593          	addi	a1,a1,-1616 # ffffffffc0201c18 <etext+0x1a0>
ffffffffc0200270:	00002517          	auipc	a0,0x2
ffffffffc0200274:	97050513          	addi	a0,a0,-1680 # ffffffffc0201be0 <etext+0x168>
ffffffffc0200278:	e3bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020027c:	00002617          	auipc	a2,0x2
ffffffffc0200280:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0201c28 <etext+0x1b0>
ffffffffc0200284:	00002597          	auipc	a1,0x2
ffffffffc0200288:	9c458593          	addi	a1,a1,-1596 # ffffffffc0201c48 <etext+0x1d0>
ffffffffc020028c:	00002517          	auipc	a0,0x2
ffffffffc0200290:	95450513          	addi	a0,a0,-1708 # ffffffffc0201be0 <etext+0x168>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc0200298:	60a2                	ld	ra,8(sp)
ffffffffc020029a:	4501                	li	a0,0
ffffffffc020029c:	0141                	addi	sp,sp,16
ffffffffc020029e:	8082                	ret

ffffffffc02002a0 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002a0:	1141                	addi	sp,sp,-16
ffffffffc02002a2:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002a4:	ef3ff0ef          	jal	ra,ffffffffc0200196 <print_kerninfo>
    return 0;
}
ffffffffc02002a8:	60a2                	ld	ra,8(sp)
ffffffffc02002aa:	4501                	li	a0,0
ffffffffc02002ac:	0141                	addi	sp,sp,16
ffffffffc02002ae:	8082                	ret

ffffffffc02002b0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002b0:	1141                	addi	sp,sp,-16
ffffffffc02002b2:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002b4:	f71ff0ef          	jal	ra,ffffffffc0200224 <print_stackframe>
    return 0;
}
ffffffffc02002b8:	60a2                	ld	ra,8(sp)
ffffffffc02002ba:	4501                	li	a0,0
ffffffffc02002bc:	0141                	addi	sp,sp,16
ffffffffc02002be:	8082                	ret

ffffffffc02002c0 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002c0:	7115                	addi	sp,sp,-224
ffffffffc02002c2:	ed5e                	sd	s7,152(sp)
ffffffffc02002c4:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002c6:	00002517          	auipc	a0,0x2
ffffffffc02002ca:	99250513          	addi	a0,a0,-1646 # ffffffffc0201c58 <etext+0x1e0>
kmonitor(struct trapframe *tf) {
ffffffffc02002ce:	ed86                	sd	ra,216(sp)
ffffffffc02002d0:	e9a2                	sd	s0,208(sp)
ffffffffc02002d2:	e5a6                	sd	s1,200(sp)
ffffffffc02002d4:	e1ca                	sd	s2,192(sp)
ffffffffc02002d6:	fd4e                	sd	s3,184(sp)
ffffffffc02002d8:	f952                	sd	s4,176(sp)
ffffffffc02002da:	f556                	sd	s5,168(sp)
ffffffffc02002dc:	f15a                	sd	s6,160(sp)
ffffffffc02002de:	e962                	sd	s8,144(sp)
ffffffffc02002e0:	e566                	sd	s9,136(sp)
ffffffffc02002e2:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002e4:	dcfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002e8:	00002517          	auipc	a0,0x2
ffffffffc02002ec:	99850513          	addi	a0,a0,-1640 # ffffffffc0201c80 <etext+0x208>
ffffffffc02002f0:	dc3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc02002f4:	000b8563          	beqz	s7,ffffffffc02002fe <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002f8:	855e                	mv	a0,s7
ffffffffc02002fa:	348000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002fe:	00002c17          	auipc	s8,0x2
ffffffffc0200302:	9f2c0c13          	addi	s8,s8,-1550 # ffffffffc0201cf0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200306:	00002917          	auipc	s2,0x2
ffffffffc020030a:	9a290913          	addi	s2,s2,-1630 # ffffffffc0201ca8 <etext+0x230>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030e:	00002497          	auipc	s1,0x2
ffffffffc0200312:	9a248493          	addi	s1,s1,-1630 # ffffffffc0201cb0 <etext+0x238>
        if (argc == MAXARGS - 1) {
ffffffffc0200316:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200318:	00002b17          	auipc	s6,0x2
ffffffffc020031c:	9a0b0b13          	addi	s6,s6,-1632 # ffffffffc0201cb8 <etext+0x240>
        argv[argc ++] = buf;
ffffffffc0200320:	00002a17          	auipc	s4,0x2
ffffffffc0200324:	8b8a0a13          	addi	s4,s4,-1864 # ffffffffc0201bd8 <etext+0x160>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200328:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020032a:	854a                	mv	a0,s2
ffffffffc020032c:	648010ef          	jal	ra,ffffffffc0201974 <readline>
ffffffffc0200330:	842a                	mv	s0,a0
ffffffffc0200332:	dd65                	beqz	a0,ffffffffc020032a <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200334:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200338:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020033a:	e1bd                	bnez	a1,ffffffffc02003a0 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc020033c:	fe0c87e3          	beqz	s9,ffffffffc020032a <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200340:	6582                	ld	a1,0(sp)
ffffffffc0200342:	00002d17          	auipc	s10,0x2
ffffffffc0200346:	9aed0d13          	addi	s10,s10,-1618 # ffffffffc0201cf0 <commands>
        argv[argc ++] = buf;
ffffffffc020034a:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020034c:	4401                	li	s0,0
ffffffffc020034e:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200350:	1f0010ef          	jal	ra,ffffffffc0201540 <strcmp>
ffffffffc0200354:	c919                	beqz	a0,ffffffffc020036a <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200356:	2405                	addiw	s0,s0,1
ffffffffc0200358:	0b540063          	beq	s0,s5,ffffffffc02003f8 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020035c:	000d3503          	ld	a0,0(s10)
ffffffffc0200360:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200362:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200364:	1dc010ef          	jal	ra,ffffffffc0201540 <strcmp>
ffffffffc0200368:	f57d                	bnez	a0,ffffffffc0200356 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020036a:	00141793          	slli	a5,s0,0x1
ffffffffc020036e:	97a2                	add	a5,a5,s0
ffffffffc0200370:	078e                	slli	a5,a5,0x3
ffffffffc0200372:	97e2                	add	a5,a5,s8
ffffffffc0200374:	6b9c                	ld	a5,16(a5)
ffffffffc0200376:	865e                	mv	a2,s7
ffffffffc0200378:	002c                	addi	a1,sp,8
ffffffffc020037a:	fffc851b          	addiw	a0,s9,-1
ffffffffc020037e:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200380:	fa0555e3          	bgez	a0,ffffffffc020032a <kmonitor+0x6a>
}
ffffffffc0200384:	60ee                	ld	ra,216(sp)
ffffffffc0200386:	644e                	ld	s0,208(sp)
ffffffffc0200388:	64ae                	ld	s1,200(sp)
ffffffffc020038a:	690e                	ld	s2,192(sp)
ffffffffc020038c:	79ea                	ld	s3,184(sp)
ffffffffc020038e:	7a4a                	ld	s4,176(sp)
ffffffffc0200390:	7aaa                	ld	s5,168(sp)
ffffffffc0200392:	7b0a                	ld	s6,160(sp)
ffffffffc0200394:	6bea                	ld	s7,152(sp)
ffffffffc0200396:	6c4a                	ld	s8,144(sp)
ffffffffc0200398:	6caa                	ld	s9,136(sp)
ffffffffc020039a:	6d0a                	ld	s10,128(sp)
ffffffffc020039c:	612d                	addi	sp,sp,224
ffffffffc020039e:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a0:	8526                	mv	a0,s1
ffffffffc02003a2:	1bc010ef          	jal	ra,ffffffffc020155e <strchr>
ffffffffc02003a6:	c901                	beqz	a0,ffffffffc02003b6 <kmonitor+0xf6>
ffffffffc02003a8:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003ac:	00040023          	sb	zero,0(s0)
ffffffffc02003b0:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b2:	d5c9                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003b4:	b7f5                	j	ffffffffc02003a0 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02003b6:	00044783          	lbu	a5,0(s0)
ffffffffc02003ba:	d3c9                	beqz	a5,ffffffffc020033c <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02003bc:	033c8963          	beq	s9,s3,ffffffffc02003ee <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02003c0:	003c9793          	slli	a5,s9,0x3
ffffffffc02003c4:	0118                	addi	a4,sp,128
ffffffffc02003c6:	97ba                	add	a5,a5,a4
ffffffffc02003c8:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003cc:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003d0:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d2:	e591                	bnez	a1,ffffffffc02003de <kmonitor+0x11e>
ffffffffc02003d4:	b7b5                	j	ffffffffc0200340 <kmonitor+0x80>
ffffffffc02003d6:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003da:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003dc:	d1a5                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003de:	8526                	mv	a0,s1
ffffffffc02003e0:	17e010ef          	jal	ra,ffffffffc020155e <strchr>
ffffffffc02003e4:	d96d                	beqz	a0,ffffffffc02003d6 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003e6:	00044583          	lbu	a1,0(s0)
ffffffffc02003ea:	d9a9                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003ec:	bf55                	j	ffffffffc02003a0 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003ee:	45c1                	li	a1,16
ffffffffc02003f0:	855a                	mv	a0,s6
ffffffffc02003f2:	cc1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02003f6:	b7e9                	j	ffffffffc02003c0 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003f8:	6582                	ld	a1,0(sp)
ffffffffc02003fa:	00002517          	auipc	a0,0x2
ffffffffc02003fe:	8de50513          	addi	a0,a0,-1826 # ffffffffc0201cd8 <etext+0x260>
ffffffffc0200402:	cb1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc0200406:	b715                	j	ffffffffc020032a <kmonitor+0x6a>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	622010ef          	jal	ra,ffffffffc0201a42 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	90a50513          	addi	a0,a0,-1782 # ffffffffc0201d38 <commands+0x48>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	5fc0106f          	j	ffffffffc0201a42 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	5d80106f          	j	ffffffffc0201a28 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	6080106f          	j	ffffffffc0201a5c <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	8da50513          	addi	a0,a0,-1830 # ffffffffc0201d58 <commands+0x68>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	8e250513          	addi	a0,a0,-1822 # ffffffffc0201d70 <commands+0x80>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0201d88 <commands+0x98>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	8f650513          	addi	a0,a0,-1802 # ffffffffc0201da0 <commands+0xb0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	90050513          	addi	a0,a0,-1792 # ffffffffc0201db8 <commands+0xc8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	90a50513          	addi	a0,a0,-1782 # ffffffffc0201dd0 <commands+0xe0>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	91450513          	addi	a0,a0,-1772 # ffffffffc0201de8 <commands+0xf8>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	91e50513          	addi	a0,a0,-1762 # ffffffffc0201e00 <commands+0x110>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	92850513          	addi	a0,a0,-1752 # ffffffffc0201e18 <commands+0x128>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	93250513          	addi	a0,a0,-1742 # ffffffffc0201e30 <commands+0x140>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	93c50513          	addi	a0,a0,-1732 # ffffffffc0201e48 <commands+0x158>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	94650513          	addi	a0,a0,-1722 # ffffffffc0201e60 <commands+0x170>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	95050513          	addi	a0,a0,-1712 # ffffffffc0201e78 <commands+0x188>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	95a50513          	addi	a0,a0,-1702 # ffffffffc0201e90 <commands+0x1a0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	96450513          	addi	a0,a0,-1692 # ffffffffc0201ea8 <commands+0x1b8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	96e50513          	addi	a0,a0,-1682 # ffffffffc0201ec0 <commands+0x1d0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	97850513          	addi	a0,a0,-1672 # ffffffffc0201ed8 <commands+0x1e8>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	98250513          	addi	a0,a0,-1662 # ffffffffc0201ef0 <commands+0x200>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	98c50513          	addi	a0,a0,-1652 # ffffffffc0201f08 <commands+0x218>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	99650513          	addi	a0,a0,-1642 # ffffffffc0201f20 <commands+0x230>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	9a050513          	addi	a0,a0,-1632 # ffffffffc0201f38 <commands+0x248>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0201f50 <commands+0x260>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	9b450513          	addi	a0,a0,-1612 # ffffffffc0201f68 <commands+0x278>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	9be50513          	addi	a0,a0,-1602 # ffffffffc0201f80 <commands+0x290>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	9c850513          	addi	a0,a0,-1592 # ffffffffc0201f98 <commands+0x2a8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	9d250513          	addi	a0,a0,-1582 # ffffffffc0201fb0 <commands+0x2c0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0201fc8 <commands+0x2d8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	9e650513          	addi	a0,a0,-1562 # ffffffffc0201fe0 <commands+0x2f0>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	9f050513          	addi	a0,a0,-1552 # ffffffffc0201ff8 <commands+0x308>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0202010 <commands+0x320>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	a0450513          	addi	a0,a0,-1532 # ffffffffc0202028 <commands+0x338>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0202040 <commands+0x350>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0202058 <commands+0x368>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0202070 <commands+0x380>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	a1650513          	addi	a0,a0,-1514 # ffffffffc0202088 <commands+0x398>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	a1e50513          	addi	a0,a0,-1506 # ffffffffc02020a0 <commands+0x3b0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	a2250513          	addi	a0,a0,-1502 # ffffffffc02020b8 <commands+0x3c8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00002717          	auipc	a4,0x2
ffffffffc02006b4:	ae870713          	addi	a4,a4,-1304 # ffffffffc0202198 <commands+0x4a8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00002517          	auipc	a0,0x2
ffffffffc02006c6:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0202130 <commands+0x440>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	a4450513          	addi	a0,a0,-1468 # ffffffffc0202110 <commands+0x420>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	9fa50513          	addi	a0,a0,-1542 # ffffffffc02020d0 <commands+0x3e0>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	a7050513          	addi	a0,a0,-1424 # ffffffffc0202150 <commands+0x460>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	d3e68693          	addi	a3,a3,-706 # ffffffffc0206430 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00002517          	auipc	a0,0x2
ffffffffc0200714:	a6850513          	addi	a0,a0,-1432 # ffffffffc0202178 <commands+0x488>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	9d650513          	addi	a0,a0,-1578 # ffffffffc02020f0 <commands+0x400>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00002517          	auipc	a0,0x2
ffffffffc0200730:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0202168 <commands+0x478>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200802:	100027f3          	csrr	a5,sstatus
ffffffffc0200806:	8b89                	andi	a5,a5,2
ffffffffc0200808:	e799                	bnez	a5,ffffffffc0200816 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc020080a:	00006797          	auipc	a5,0x6
ffffffffc020080e:	c3e7b783          	ld	a5,-962(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0200812:	6f9c                	ld	a5,24(a5)
ffffffffc0200814:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200816:	1141                	addi	sp,sp,-16
ffffffffc0200818:	e406                	sd	ra,8(sp)
ffffffffc020081a:	e022                	sd	s0,0(sp)
ffffffffc020081c:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020081e:	c41ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200822:	00006797          	auipc	a5,0x6
ffffffffc0200826:	c267b783          	ld	a5,-986(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020082a:	6f9c                	ld	a5,24(a5)
ffffffffc020082c:	8522                	mv	a0,s0
ffffffffc020082e:	9782                	jalr	a5
ffffffffc0200830:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200832:	c27ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200836:	60a2                	ld	ra,8(sp)
ffffffffc0200838:	8522                	mv	a0,s0
ffffffffc020083a:	6402                	ld	s0,0(sp)
ffffffffc020083c:	0141                	addi	sp,sp,16
ffffffffc020083e:	8082                	ret

ffffffffc0200840 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200840:	100027f3          	csrr	a5,sstatus
ffffffffc0200844:	8b89                	andi	a5,a5,2
ffffffffc0200846:	e799                	bnez	a5,ffffffffc0200854 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200848:	00006797          	auipc	a5,0x6
ffffffffc020084c:	c007b783          	ld	a5,-1024(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0200850:	739c                	ld	a5,32(a5)
ffffffffc0200852:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200854:	1101                	addi	sp,sp,-32
ffffffffc0200856:	ec06                	sd	ra,24(sp)
ffffffffc0200858:	e822                	sd	s0,16(sp)
ffffffffc020085a:	e426                	sd	s1,8(sp)
ffffffffc020085c:	842a                	mv	s0,a0
ffffffffc020085e:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200860:	bffff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200864:	00006797          	auipc	a5,0x6
ffffffffc0200868:	be47b783          	ld	a5,-1052(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020086c:	739c                	ld	a5,32(a5)
ffffffffc020086e:	85a6                	mv	a1,s1
ffffffffc0200870:	8522                	mv	a0,s0
ffffffffc0200872:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200874:	6442                	ld	s0,16(sp)
ffffffffc0200876:	60e2                	ld	ra,24(sp)
ffffffffc0200878:	64a2                	ld	s1,8(sp)
ffffffffc020087a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020087c:	bef1                	j	ffffffffc0200458 <intr_enable>

ffffffffc020087e <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020087e:	100027f3          	csrr	a5,sstatus
ffffffffc0200882:	8b89                	andi	a5,a5,2
ffffffffc0200884:	e799                	bnez	a5,ffffffffc0200892 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200886:	00006797          	auipc	a5,0x6
ffffffffc020088a:	bc27b783          	ld	a5,-1086(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020088e:	779c                	ld	a5,40(a5)
ffffffffc0200890:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0200892:	1141                	addi	sp,sp,-16
ffffffffc0200894:	e406                	sd	ra,8(sp)
ffffffffc0200896:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200898:	bc7ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020089c:	00006797          	auipc	a5,0x6
ffffffffc02008a0:	bac7b783          	ld	a5,-1108(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02008a4:	779c                	ld	a5,40(a5)
ffffffffc02008a6:	9782                	jalr	a5
ffffffffc02008a8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02008aa:	bafff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02008ae:	60a2                	ld	ra,8(sp)
ffffffffc02008b0:	8522                	mv	a0,s0
ffffffffc02008b2:	6402                	ld	s0,0(sp)
ffffffffc02008b4:	0141                	addi	sp,sp,16
ffffffffc02008b6:	8082                	ret

ffffffffc02008b8 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02008b8:	00002797          	auipc	a5,0x2
ffffffffc02008bc:	df878793          	addi	a5,a5,-520 # ffffffffc02026b0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008c0:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02008c2:	1101                	addi	sp,sp,-32
ffffffffc02008c4:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008c6:	00002517          	auipc	a0,0x2
ffffffffc02008ca:	90250513          	addi	a0,a0,-1790 # ffffffffc02021c8 <commands+0x4d8>
    pmm_manager = &default_pmm_manager;
ffffffffc02008ce:	00006497          	auipc	s1,0x6
ffffffffc02008d2:	b7a48493          	addi	s1,s1,-1158 # ffffffffc0206448 <pmm_manager>
void pmm_init(void) {
ffffffffc02008d6:	ec06                	sd	ra,24(sp)
ffffffffc02008d8:	e822                	sd	s0,16(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02008da:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008dc:	fd6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc02008e0:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02008e2:	00006417          	auipc	s0,0x6
ffffffffc02008e6:	b7e40413          	addi	s0,s0,-1154 # ffffffffc0206460 <va_pa_offset>
    pmm_manager->init();
ffffffffc02008ea:	679c                	ld	a5,8(a5)
ffffffffc02008ec:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02008ee:	57f5                	li	a5,-3
ffffffffc02008f0:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02008f2:	00002517          	auipc	a0,0x2
ffffffffc02008f6:	8ee50513          	addi	a0,a0,-1810 # ffffffffc02021e0 <commands+0x4f0>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02008fa:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02008fc:	fb6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200900:	46c5                	li	a3,17
ffffffffc0200902:	06ee                	slli	a3,a3,0x1b
ffffffffc0200904:	40100613          	li	a2,1025
ffffffffc0200908:	16fd                	addi	a3,a3,-1
ffffffffc020090a:	07e005b7          	lui	a1,0x7e00
ffffffffc020090e:	0656                	slli	a2,a2,0x15
ffffffffc0200910:	00002517          	auipc	a0,0x2
ffffffffc0200914:	8e850513          	addi	a0,a0,-1816 # ffffffffc02021f8 <commands+0x508>
ffffffffc0200918:	f9aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020091c:	777d                	lui	a4,0xfffff
ffffffffc020091e:	00007797          	auipc	a5,0x7
ffffffffc0200922:	b5178793          	addi	a5,a5,-1199 # ffffffffc020746f <end+0xfff>
ffffffffc0200926:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200928:	00006517          	auipc	a0,0x6
ffffffffc020092c:	b1050513          	addi	a0,a0,-1264 # ffffffffc0206438 <npage>
ffffffffc0200930:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200934:	00006597          	auipc	a1,0x6
ffffffffc0200938:	b0c58593          	addi	a1,a1,-1268 # ffffffffc0206440 <pages>
    npage = maxpa / PGSIZE;
ffffffffc020093c:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020093e:	e19c                	sd	a5,0(a1)
ffffffffc0200940:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200942:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200944:	4885                	li	a7,1
ffffffffc0200946:	fff80837          	lui	a6,0xfff80
ffffffffc020094a:	a011                	j	ffffffffc020094e <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc020094c:	619c                	ld	a5,0(a1)
ffffffffc020094e:	97b6                	add	a5,a5,a3
ffffffffc0200950:	07a1                	addi	a5,a5,8
ffffffffc0200952:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200956:	611c                	ld	a5,0(a0)
ffffffffc0200958:	0705                	addi	a4,a4,1
ffffffffc020095a:	02868693          	addi	a3,a3,40
ffffffffc020095e:	01078633          	add	a2,a5,a6
ffffffffc0200962:	fec765e3          	bltu	a4,a2,ffffffffc020094c <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200966:	6190                	ld	a2,0(a1)
ffffffffc0200968:	00279713          	slli	a4,a5,0x2
ffffffffc020096c:	973e                	add	a4,a4,a5
ffffffffc020096e:	fec006b7          	lui	a3,0xfec00
ffffffffc0200972:	070e                	slli	a4,a4,0x3
ffffffffc0200974:	96b2                	add	a3,a3,a2
ffffffffc0200976:	96ba                	add	a3,a3,a4
ffffffffc0200978:	c0200737          	lui	a4,0xc0200
ffffffffc020097c:	08e6ef63          	bltu	a3,a4,ffffffffc0200a1a <pmm_init+0x162>
ffffffffc0200980:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200982:	45c5                	li	a1,17
ffffffffc0200984:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200986:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200988:	04b6e863          	bltu	a3,a1,ffffffffc02009d8 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020098c:	609c                	ld	a5,0(s1)
ffffffffc020098e:	7b9c                	ld	a5,48(a5)
ffffffffc0200990:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200992:	00002517          	auipc	a0,0x2
ffffffffc0200996:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0202290 <commands+0x5a0>
ffffffffc020099a:	f18ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc020099e:	00004597          	auipc	a1,0x4
ffffffffc02009a2:	66258593          	addi	a1,a1,1634 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02009a6:	00006797          	auipc	a5,0x6
ffffffffc02009aa:	aab7b923          	sd	a1,-1358(a5) # ffffffffc0206458 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02009ae:	c02007b7          	lui	a5,0xc0200
ffffffffc02009b2:	08f5e063          	bltu	a1,a5,ffffffffc0200a32 <pmm_init+0x17a>
ffffffffc02009b6:	6010                	ld	a2,0(s0)
}
ffffffffc02009b8:	6442                	ld	s0,16(sp)
ffffffffc02009ba:	60e2                	ld	ra,24(sp)
ffffffffc02009bc:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02009be:	40c58633          	sub	a2,a1,a2
ffffffffc02009c2:	00006797          	auipc	a5,0x6
ffffffffc02009c6:	a8c7b723          	sd	a2,-1394(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02009ca:	00002517          	auipc	a0,0x2
ffffffffc02009ce:	8e650513          	addi	a0,a0,-1818 # ffffffffc02022b0 <commands+0x5c0>
}
ffffffffc02009d2:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02009d4:	edeff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02009d8:	6705                	lui	a4,0x1
ffffffffc02009da:	177d                	addi	a4,a4,-1
ffffffffc02009dc:	96ba                	add	a3,a3,a4
ffffffffc02009de:	777d                	lui	a4,0xfffff
ffffffffc02009e0:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02009e2:	00c6d513          	srli	a0,a3,0xc
ffffffffc02009e6:	00f57e63          	bgeu	a0,a5,ffffffffc0200a02 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02009ea:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02009ec:	982a                	add	a6,a6,a0
ffffffffc02009ee:	00281513          	slli	a0,a6,0x2
ffffffffc02009f2:	9542                	add	a0,a0,a6
ffffffffc02009f4:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02009f6:	8d95                	sub	a1,a1,a3
ffffffffc02009f8:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02009fa:	81b1                	srli	a1,a1,0xc
ffffffffc02009fc:	9532                	add	a0,a0,a2
ffffffffc02009fe:	9782                	jalr	a5
}
ffffffffc0200a00:	b771                	j	ffffffffc020098c <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0200a02:	00002617          	auipc	a2,0x2
ffffffffc0200a06:	85e60613          	addi	a2,a2,-1954 # ffffffffc0202260 <commands+0x570>
ffffffffc0200a0a:	06b00593          	li	a1,107
ffffffffc0200a0e:	00002517          	auipc	a0,0x2
ffffffffc0200a12:	87250513          	addi	a0,a0,-1934 # ffffffffc0202280 <commands+0x590>
ffffffffc0200a16:	f24ff0ef          	jal	ra,ffffffffc020013a <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200a1a:	00002617          	auipc	a2,0x2
ffffffffc0200a1e:	80e60613          	addi	a2,a2,-2034 # ffffffffc0202228 <commands+0x538>
ffffffffc0200a22:	06f00593          	li	a1,111
ffffffffc0200a26:	00002517          	auipc	a0,0x2
ffffffffc0200a2a:	82a50513          	addi	a0,a0,-2006 # ffffffffc0202250 <commands+0x560>
ffffffffc0200a2e:	f0cff0ef          	jal	ra,ffffffffc020013a <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a32:	86ae                	mv	a3,a1
ffffffffc0200a34:	00001617          	auipc	a2,0x1
ffffffffc0200a38:	7f460613          	addi	a2,a2,2036 # ffffffffc0202228 <commands+0x538>
ffffffffc0200a3c:	08a00593          	li	a1,138
ffffffffc0200a40:	00002517          	auipc	a0,0x2
ffffffffc0200a44:	81050513          	addi	a0,a0,-2032 # ffffffffc0202250 <commands+0x560>
ffffffffc0200a48:	ef2ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200a4c <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200a4c:	00005797          	auipc	a5,0x5
ffffffffc0200a50:	5c478793          	addi	a5,a5,1476 # ffffffffc0206010 <free_area>
ffffffffc0200a54:	e79c                	sd	a5,8(a5)
ffffffffc0200a56:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200a58:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200a5c:	8082                	ret

ffffffffc0200a5e <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200a5e:	00005517          	auipc	a0,0x5
ffffffffc0200a62:	5c256503          	lwu	a0,1474(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc0200a66:	8082                	ret

ffffffffc0200a68 <default_check>:
}

// LAB2：以下代码用于检查first-fit内存分配算法
// 注意：您不应该更改basic_check、default_check函数！
static void
default_check(void) {
ffffffffc0200a68:	715d                	addi	sp,sp,-80
ffffffffc0200a6a:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200a6c:	00005417          	auipc	s0,0x5
ffffffffc0200a70:	5a440413          	addi	s0,s0,1444 # ffffffffc0206010 <free_area>
ffffffffc0200a74:	641c                	ld	a5,8(s0)
ffffffffc0200a76:	e486                	sd	ra,72(sp)
ffffffffc0200a78:	fc26                	sd	s1,56(sp)
ffffffffc0200a7a:	f84a                	sd	s2,48(sp)
ffffffffc0200a7c:	f44e                	sd	s3,40(sp)
ffffffffc0200a7e:	f052                	sd	s4,32(sp)
ffffffffc0200a80:	ec56                	sd	s5,24(sp)
ffffffffc0200a82:	e85a                	sd	s6,16(sp)
ffffffffc0200a84:	e45e                	sd	s7,8(sp)
ffffffffc0200a86:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a88:	2c878763          	beq	a5,s0,ffffffffc0200d56 <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0200a8c:	4481                	li	s1,0
ffffffffc0200a8e:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a90:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200a94:	8b09                	andi	a4,a4,2
ffffffffc0200a96:	2c070463          	beqz	a4,ffffffffc0200d5e <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0200a9a:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200a9e:	679c                	ld	a5,8(a5)
ffffffffc0200aa0:	2905                	addiw	s2,s2,1
ffffffffc0200aa2:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200aa4:	fe8796e3          	bne	a5,s0,ffffffffc0200a90 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200aa8:	89a6                	mv	s3,s1
ffffffffc0200aaa:	dd5ff0ef          	jal	ra,ffffffffc020087e <nr_free_pages>
ffffffffc0200aae:	71351863          	bne	a0,s3,ffffffffc02011be <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ab2:	4505                	li	a0,1
ffffffffc0200ab4:	d4fff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200ab8:	8a2a                	mv	s4,a0
ffffffffc0200aba:	44050263          	beqz	a0,ffffffffc0200efe <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200abe:	4505                	li	a0,1
ffffffffc0200ac0:	d43ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200ac4:	89aa                	mv	s3,a0
ffffffffc0200ac6:	70050c63          	beqz	a0,ffffffffc02011de <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200aca:	4505                	li	a0,1
ffffffffc0200acc:	d37ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200ad0:	8aaa                	mv	s5,a0
ffffffffc0200ad2:	4a050663          	beqz	a0,ffffffffc0200f7e <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ad6:	2b3a0463          	beq	s4,s3,ffffffffc0200d7e <default_check+0x316>
ffffffffc0200ada:	2aaa0263          	beq	s4,a0,ffffffffc0200d7e <default_check+0x316>
ffffffffc0200ade:	2aa98063          	beq	s3,a0,ffffffffc0200d7e <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200ae2:	000a2783          	lw	a5,0(s4)
ffffffffc0200ae6:	2a079c63          	bnez	a5,ffffffffc0200d9e <default_check+0x336>
ffffffffc0200aea:	0009a783          	lw	a5,0(s3)
ffffffffc0200aee:	2a079863          	bnez	a5,ffffffffc0200d9e <default_check+0x336>
ffffffffc0200af2:	411c                	lw	a5,0(a0)
ffffffffc0200af4:	2a079563          	bnez	a5,ffffffffc0200d9e <default_check+0x336>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200af8:	00006797          	auipc	a5,0x6
ffffffffc0200afc:	9487b783          	ld	a5,-1720(a5) # ffffffffc0206440 <pages>
ffffffffc0200b00:	40fa0733          	sub	a4,s4,a5
ffffffffc0200b04:	870d                	srai	a4,a4,0x3
ffffffffc0200b06:	00002597          	auipc	a1,0x2
ffffffffc0200b0a:	e325b583          	ld	a1,-462(a1) # ffffffffc0202938 <nbase+0x8>
ffffffffc0200b0e:	02b70733          	mul	a4,a4,a1
ffffffffc0200b12:	00002617          	auipc	a2,0x2
ffffffffc0200b16:	e1e63603          	ld	a2,-482(a2) # ffffffffc0202930 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b1a:	00006697          	auipc	a3,0x6
ffffffffc0200b1e:	91e6b683          	ld	a3,-1762(a3) # ffffffffc0206438 <npage>
ffffffffc0200b22:	06b2                	slli	a3,a3,0xc
ffffffffc0200b24:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b26:	0732                	slli	a4,a4,0xc
ffffffffc0200b28:	28d77b63          	bgeu	a4,a3,ffffffffc0200dbe <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b2c:	40f98733          	sub	a4,s3,a5
ffffffffc0200b30:	870d                	srai	a4,a4,0x3
ffffffffc0200b32:	02b70733          	mul	a4,a4,a1
ffffffffc0200b36:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b38:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200b3a:	4cd77263          	bgeu	a4,a3,ffffffffc0200ffe <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b3e:	40f507b3          	sub	a5,a0,a5
ffffffffc0200b42:	878d                	srai	a5,a5,0x3
ffffffffc0200b44:	02b787b3          	mul	a5,a5,a1
ffffffffc0200b48:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b4a:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200b4c:	30d7f963          	bgeu	a5,a3,ffffffffc0200e5e <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0200b50:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200b52:	00043c03          	ld	s8,0(s0)
ffffffffc0200b56:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200b5a:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200b5e:	e400                	sd	s0,8(s0)
ffffffffc0200b60:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200b62:	00005797          	auipc	a5,0x5
ffffffffc0200b66:	4a07af23          	sw	zero,1214(a5) # ffffffffc0206020 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200b6a:	c99ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200b6e:	2c051863          	bnez	a0,ffffffffc0200e3e <default_check+0x3d6>
    free_page(p0);
ffffffffc0200b72:	4585                	li	a1,1
ffffffffc0200b74:	8552                	mv	a0,s4
ffffffffc0200b76:	ccbff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    free_page(p1);
ffffffffc0200b7a:	4585                	li	a1,1
ffffffffc0200b7c:	854e                	mv	a0,s3
ffffffffc0200b7e:	cc3ff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    free_page(p2);
ffffffffc0200b82:	4585                	li	a1,1
ffffffffc0200b84:	8556                	mv	a0,s5
ffffffffc0200b86:	cbbff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    assert(nr_free == 3);
ffffffffc0200b8a:	4818                	lw	a4,16(s0)
ffffffffc0200b8c:	478d                	li	a5,3
ffffffffc0200b8e:	28f71863          	bne	a4,a5,ffffffffc0200e1e <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b92:	4505                	li	a0,1
ffffffffc0200b94:	c6fff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200b98:	89aa                	mv	s3,a0
ffffffffc0200b9a:	26050263          	beqz	a0,ffffffffc0200dfe <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b9e:	4505                	li	a0,1
ffffffffc0200ba0:	c63ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200ba4:	8aaa                	mv	s5,a0
ffffffffc0200ba6:	3a050c63          	beqz	a0,ffffffffc0200f5e <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200baa:	4505                	li	a0,1
ffffffffc0200bac:	c57ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200bb0:	8a2a                	mv	s4,a0
ffffffffc0200bb2:	38050663          	beqz	a0,ffffffffc0200f3e <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0200bb6:	4505                	li	a0,1
ffffffffc0200bb8:	c4bff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200bbc:	36051163          	bnez	a0,ffffffffc0200f1e <default_check+0x4b6>
    free_page(p0);
ffffffffc0200bc0:	4585                	li	a1,1
ffffffffc0200bc2:	854e                	mv	a0,s3
ffffffffc0200bc4:	c7dff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200bc8:	641c                	ld	a5,8(s0)
ffffffffc0200bca:	20878a63          	beq	a5,s0,ffffffffc0200dde <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0200bce:	4505                	li	a0,1
ffffffffc0200bd0:	c33ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200bd4:	30a99563          	bne	s3,a0,ffffffffc0200ede <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0200bd8:	4505                	li	a0,1
ffffffffc0200bda:	c29ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200bde:	2e051063          	bnez	a0,ffffffffc0200ebe <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0200be2:	481c                	lw	a5,16(s0)
ffffffffc0200be4:	2a079d63          	bnez	a5,ffffffffc0200e9e <default_check+0x436>
    free_page(p);
ffffffffc0200be8:	854e                	mv	a0,s3
ffffffffc0200bea:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200bec:	01843023          	sd	s8,0(s0)
ffffffffc0200bf0:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200bf4:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200bf8:	c49ff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    free_page(p1);
ffffffffc0200bfc:	4585                	li	a1,1
ffffffffc0200bfe:	8556                	mv	a0,s5
ffffffffc0200c00:	c41ff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    free_page(p2);
ffffffffc0200c04:	4585                	li	a1,1
ffffffffc0200c06:	8552                	mv	a0,s4
ffffffffc0200c08:	c39ff0ef          	jal	ra,ffffffffc0200840 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200c0c:	4515                	li	a0,5
ffffffffc0200c0e:	bf5ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200c12:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200c14:	26050563          	beqz	a0,ffffffffc0200e7e <default_check+0x416>
ffffffffc0200c18:	651c                	ld	a5,8(a0)
ffffffffc0200c1a:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200c1c:	8b85                	andi	a5,a5,1
ffffffffc0200c1e:	54079063          	bnez	a5,ffffffffc020115e <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200c22:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c24:	00043b03          	ld	s6,0(s0)
ffffffffc0200c28:	00843a83          	ld	s5,8(s0)
ffffffffc0200c2c:	e000                	sd	s0,0(s0)
ffffffffc0200c2e:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200c30:	bd3ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200c34:	50051563          	bnez	a0,ffffffffc020113e <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200c38:	05098a13          	addi	s4,s3,80
ffffffffc0200c3c:	8552                	mv	a0,s4
ffffffffc0200c3e:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200c40:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200c44:	00005797          	auipc	a5,0x5
ffffffffc0200c48:	3c07ae23          	sw	zero,988(a5) # ffffffffc0206020 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200c4c:	bf5ff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200c50:	4511                	li	a0,4
ffffffffc0200c52:	bb1ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200c56:	4c051463          	bnez	a0,ffffffffc020111e <default_check+0x6b6>
ffffffffc0200c5a:	0589b783          	ld	a5,88(s3)
ffffffffc0200c5e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200c60:	8b85                	andi	a5,a5,1
ffffffffc0200c62:	48078e63          	beqz	a5,ffffffffc02010fe <default_check+0x696>
ffffffffc0200c66:	0609a703          	lw	a4,96(s3)
ffffffffc0200c6a:	478d                	li	a5,3
ffffffffc0200c6c:	48f71963          	bne	a4,a5,ffffffffc02010fe <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200c70:	450d                	li	a0,3
ffffffffc0200c72:	b91ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200c76:	8c2a                	mv	s8,a0
ffffffffc0200c78:	46050363          	beqz	a0,ffffffffc02010de <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0200c7c:	4505                	li	a0,1
ffffffffc0200c7e:	b85ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200c82:	42051e63          	bnez	a0,ffffffffc02010be <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0200c86:	418a1c63          	bne	s4,s8,ffffffffc020109e <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200c8a:	4585                	li	a1,1
ffffffffc0200c8c:	854e                	mv	a0,s3
ffffffffc0200c8e:	bb3ff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    free_pages(p1, 3);
ffffffffc0200c92:	458d                	li	a1,3
ffffffffc0200c94:	8552                	mv	a0,s4
ffffffffc0200c96:	babff0ef          	jal	ra,ffffffffc0200840 <free_pages>
ffffffffc0200c9a:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200c9e:	02898c13          	addi	s8,s3,40
ffffffffc0200ca2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200ca4:	8b85                	andi	a5,a5,1
ffffffffc0200ca6:	3c078c63          	beqz	a5,ffffffffc020107e <default_check+0x616>
ffffffffc0200caa:	0109a703          	lw	a4,16(s3)
ffffffffc0200cae:	4785                	li	a5,1
ffffffffc0200cb0:	3cf71763          	bne	a4,a5,ffffffffc020107e <default_check+0x616>
ffffffffc0200cb4:	008a3783          	ld	a5,8(s4)
ffffffffc0200cb8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200cba:	8b85                	andi	a5,a5,1
ffffffffc0200cbc:	3a078163          	beqz	a5,ffffffffc020105e <default_check+0x5f6>
ffffffffc0200cc0:	010a2703          	lw	a4,16(s4)
ffffffffc0200cc4:	478d                	li	a5,3
ffffffffc0200cc6:	38f71c63          	bne	a4,a5,ffffffffc020105e <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200cca:	4505                	li	a0,1
ffffffffc0200ccc:	b37ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200cd0:	36a99763          	bne	s3,a0,ffffffffc020103e <default_check+0x5d6>
    free_page(p0);
ffffffffc0200cd4:	4585                	li	a1,1
ffffffffc0200cd6:	b6bff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200cda:	4509                	li	a0,2
ffffffffc0200cdc:	b27ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200ce0:	32aa1f63          	bne	s4,a0,ffffffffc020101e <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0200ce4:	4589                	li	a1,2
ffffffffc0200ce6:	b5bff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    free_page(p2);
ffffffffc0200cea:	4585                	li	a1,1
ffffffffc0200cec:	8562                	mv	a0,s8
ffffffffc0200cee:	b53ff0ef          	jal	ra,ffffffffc0200840 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200cf2:	4515                	li	a0,5
ffffffffc0200cf4:	b0fff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200cf8:	89aa                	mv	s3,a0
ffffffffc0200cfa:	48050263          	beqz	a0,ffffffffc020117e <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0200cfe:	4505                	li	a0,1
ffffffffc0200d00:	b03ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200d04:	2c051d63          	bnez	a0,ffffffffc0200fde <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0200d08:	481c                	lw	a5,16(s0)
ffffffffc0200d0a:	2a079a63          	bnez	a5,ffffffffc0200fbe <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200d0e:	4595                	li	a1,5
ffffffffc0200d10:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200d12:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200d16:	01643023          	sd	s6,0(s0)
ffffffffc0200d1a:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200d1e:	b23ff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    return listelm->next;
ffffffffc0200d22:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d24:	00878963          	beq	a5,s0,ffffffffc0200d36 <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200d28:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200d2c:	679c                	ld	a5,8(a5)
ffffffffc0200d2e:	397d                	addiw	s2,s2,-1
ffffffffc0200d30:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d32:	fe879be3          	bne	a5,s0,ffffffffc0200d28 <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0200d36:	26091463          	bnez	s2,ffffffffc0200f9e <default_check+0x536>
    assert(total == 0);
ffffffffc0200d3a:	46049263          	bnez	s1,ffffffffc020119e <default_check+0x736>
}
ffffffffc0200d3e:	60a6                	ld	ra,72(sp)
ffffffffc0200d40:	6406                	ld	s0,64(sp)
ffffffffc0200d42:	74e2                	ld	s1,56(sp)
ffffffffc0200d44:	7942                	ld	s2,48(sp)
ffffffffc0200d46:	79a2                	ld	s3,40(sp)
ffffffffc0200d48:	7a02                	ld	s4,32(sp)
ffffffffc0200d4a:	6ae2                	ld	s5,24(sp)
ffffffffc0200d4c:	6b42                	ld	s6,16(sp)
ffffffffc0200d4e:	6ba2                	ld	s7,8(sp)
ffffffffc0200d50:	6c02                	ld	s8,0(sp)
ffffffffc0200d52:	6161                	addi	sp,sp,80
ffffffffc0200d54:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d56:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200d58:	4481                	li	s1,0
ffffffffc0200d5a:	4901                	li	s2,0
ffffffffc0200d5c:	b3b9                	j	ffffffffc0200aaa <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200d5e:	00001697          	auipc	a3,0x1
ffffffffc0200d62:	59268693          	addi	a3,a3,1426 # ffffffffc02022f0 <commands+0x600>
ffffffffc0200d66:	00001617          	auipc	a2,0x1
ffffffffc0200d6a:	59a60613          	addi	a2,a2,1434 # ffffffffc0202300 <commands+0x610>
ffffffffc0200d6e:	0ef00593          	li	a1,239
ffffffffc0200d72:	00001517          	auipc	a0,0x1
ffffffffc0200d76:	5a650513          	addi	a0,a0,1446 # ffffffffc0202318 <commands+0x628>
ffffffffc0200d7a:	bc0ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200d7e:	00001697          	auipc	a3,0x1
ffffffffc0200d82:	63268693          	addi	a3,a3,1586 # ffffffffc02023b0 <commands+0x6c0>
ffffffffc0200d86:	00001617          	auipc	a2,0x1
ffffffffc0200d8a:	57a60613          	addi	a2,a2,1402 # ffffffffc0202300 <commands+0x610>
ffffffffc0200d8e:	0bc00593          	li	a1,188
ffffffffc0200d92:	00001517          	auipc	a0,0x1
ffffffffc0200d96:	58650513          	addi	a0,a0,1414 # ffffffffc0202318 <commands+0x628>
ffffffffc0200d9a:	ba0ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200d9e:	00001697          	auipc	a3,0x1
ffffffffc0200da2:	63a68693          	addi	a3,a3,1594 # ffffffffc02023d8 <commands+0x6e8>
ffffffffc0200da6:	00001617          	auipc	a2,0x1
ffffffffc0200daa:	55a60613          	addi	a2,a2,1370 # ffffffffc0202300 <commands+0x610>
ffffffffc0200dae:	0bd00593          	li	a1,189
ffffffffc0200db2:	00001517          	auipc	a0,0x1
ffffffffc0200db6:	56650513          	addi	a0,a0,1382 # ffffffffc0202318 <commands+0x628>
ffffffffc0200dba:	b80ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200dbe:	00001697          	auipc	a3,0x1
ffffffffc0200dc2:	65a68693          	addi	a3,a3,1626 # ffffffffc0202418 <commands+0x728>
ffffffffc0200dc6:	00001617          	auipc	a2,0x1
ffffffffc0200dca:	53a60613          	addi	a2,a2,1338 # ffffffffc0202300 <commands+0x610>
ffffffffc0200dce:	0bf00593          	li	a1,191
ffffffffc0200dd2:	00001517          	auipc	a0,0x1
ffffffffc0200dd6:	54650513          	addi	a0,a0,1350 # ffffffffc0202318 <commands+0x628>
ffffffffc0200dda:	b60ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200dde:	00001697          	auipc	a3,0x1
ffffffffc0200de2:	6c268693          	addi	a3,a3,1730 # ffffffffc02024a0 <commands+0x7b0>
ffffffffc0200de6:	00001617          	auipc	a2,0x1
ffffffffc0200dea:	51a60613          	addi	a2,a2,1306 # ffffffffc0202300 <commands+0x610>
ffffffffc0200dee:	0d800593          	li	a1,216
ffffffffc0200df2:	00001517          	auipc	a0,0x1
ffffffffc0200df6:	52650513          	addi	a0,a0,1318 # ffffffffc0202318 <commands+0x628>
ffffffffc0200dfa:	b40ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200dfe:	00001697          	auipc	a3,0x1
ffffffffc0200e02:	55268693          	addi	a3,a3,1362 # ffffffffc0202350 <commands+0x660>
ffffffffc0200e06:	00001617          	auipc	a2,0x1
ffffffffc0200e0a:	4fa60613          	addi	a2,a2,1274 # ffffffffc0202300 <commands+0x610>
ffffffffc0200e0e:	0d100593          	li	a1,209
ffffffffc0200e12:	00001517          	auipc	a0,0x1
ffffffffc0200e16:	50650513          	addi	a0,a0,1286 # ffffffffc0202318 <commands+0x628>
ffffffffc0200e1a:	b20ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(nr_free == 3);
ffffffffc0200e1e:	00001697          	auipc	a3,0x1
ffffffffc0200e22:	67268693          	addi	a3,a3,1650 # ffffffffc0202490 <commands+0x7a0>
ffffffffc0200e26:	00001617          	auipc	a2,0x1
ffffffffc0200e2a:	4da60613          	addi	a2,a2,1242 # ffffffffc0202300 <commands+0x610>
ffffffffc0200e2e:	0cf00593          	li	a1,207
ffffffffc0200e32:	00001517          	auipc	a0,0x1
ffffffffc0200e36:	4e650513          	addi	a0,a0,1254 # ffffffffc0202318 <commands+0x628>
ffffffffc0200e3a:	b00ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e3e:	00001697          	auipc	a3,0x1
ffffffffc0200e42:	63a68693          	addi	a3,a3,1594 # ffffffffc0202478 <commands+0x788>
ffffffffc0200e46:	00001617          	auipc	a2,0x1
ffffffffc0200e4a:	4ba60613          	addi	a2,a2,1210 # ffffffffc0202300 <commands+0x610>
ffffffffc0200e4e:	0ca00593          	li	a1,202
ffffffffc0200e52:	00001517          	auipc	a0,0x1
ffffffffc0200e56:	4c650513          	addi	a0,a0,1222 # ffffffffc0202318 <commands+0x628>
ffffffffc0200e5a:	ae0ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200e5e:	00001697          	auipc	a3,0x1
ffffffffc0200e62:	5fa68693          	addi	a3,a3,1530 # ffffffffc0202458 <commands+0x768>
ffffffffc0200e66:	00001617          	auipc	a2,0x1
ffffffffc0200e6a:	49a60613          	addi	a2,a2,1178 # ffffffffc0202300 <commands+0x610>
ffffffffc0200e6e:	0c100593          	li	a1,193
ffffffffc0200e72:	00001517          	auipc	a0,0x1
ffffffffc0200e76:	4a650513          	addi	a0,a0,1190 # ffffffffc0202318 <commands+0x628>
ffffffffc0200e7a:	ac0ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p0 != NULL);
ffffffffc0200e7e:	00001697          	auipc	a3,0x1
ffffffffc0200e82:	66a68693          	addi	a3,a3,1642 # ffffffffc02024e8 <commands+0x7f8>
ffffffffc0200e86:	00001617          	auipc	a2,0x1
ffffffffc0200e8a:	47a60613          	addi	a2,a2,1146 # ffffffffc0202300 <commands+0x610>
ffffffffc0200e8e:	0f700593          	li	a1,247
ffffffffc0200e92:	00001517          	auipc	a0,0x1
ffffffffc0200e96:	48650513          	addi	a0,a0,1158 # ffffffffc0202318 <commands+0x628>
ffffffffc0200e9a:	aa0ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(nr_free == 0);
ffffffffc0200e9e:	00001697          	auipc	a3,0x1
ffffffffc0200ea2:	63a68693          	addi	a3,a3,1594 # ffffffffc02024d8 <commands+0x7e8>
ffffffffc0200ea6:	00001617          	auipc	a2,0x1
ffffffffc0200eaa:	45a60613          	addi	a2,a2,1114 # ffffffffc0202300 <commands+0x610>
ffffffffc0200eae:	0de00593          	li	a1,222
ffffffffc0200eb2:	00001517          	auipc	a0,0x1
ffffffffc0200eb6:	46650513          	addi	a0,a0,1126 # ffffffffc0202318 <commands+0x628>
ffffffffc0200eba:	a80ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ebe:	00001697          	auipc	a3,0x1
ffffffffc0200ec2:	5ba68693          	addi	a3,a3,1466 # ffffffffc0202478 <commands+0x788>
ffffffffc0200ec6:	00001617          	auipc	a2,0x1
ffffffffc0200eca:	43a60613          	addi	a2,a2,1082 # ffffffffc0202300 <commands+0x610>
ffffffffc0200ece:	0dc00593          	li	a1,220
ffffffffc0200ed2:	00001517          	auipc	a0,0x1
ffffffffc0200ed6:	44650513          	addi	a0,a0,1094 # ffffffffc0202318 <commands+0x628>
ffffffffc0200eda:	a60ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200ede:	00001697          	auipc	a3,0x1
ffffffffc0200ee2:	5da68693          	addi	a3,a3,1498 # ffffffffc02024b8 <commands+0x7c8>
ffffffffc0200ee6:	00001617          	auipc	a2,0x1
ffffffffc0200eea:	41a60613          	addi	a2,a2,1050 # ffffffffc0202300 <commands+0x610>
ffffffffc0200eee:	0db00593          	li	a1,219
ffffffffc0200ef2:	00001517          	auipc	a0,0x1
ffffffffc0200ef6:	42650513          	addi	a0,a0,1062 # ffffffffc0202318 <commands+0x628>
ffffffffc0200efa:	a40ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200efe:	00001697          	auipc	a3,0x1
ffffffffc0200f02:	45268693          	addi	a3,a3,1106 # ffffffffc0202350 <commands+0x660>
ffffffffc0200f06:	00001617          	auipc	a2,0x1
ffffffffc0200f0a:	3fa60613          	addi	a2,a2,1018 # ffffffffc0202300 <commands+0x610>
ffffffffc0200f0e:	0b800593          	li	a1,184
ffffffffc0200f12:	00001517          	auipc	a0,0x1
ffffffffc0200f16:	40650513          	addi	a0,a0,1030 # ffffffffc0202318 <commands+0x628>
ffffffffc0200f1a:	a20ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f1e:	00001697          	auipc	a3,0x1
ffffffffc0200f22:	55a68693          	addi	a3,a3,1370 # ffffffffc0202478 <commands+0x788>
ffffffffc0200f26:	00001617          	auipc	a2,0x1
ffffffffc0200f2a:	3da60613          	addi	a2,a2,986 # ffffffffc0202300 <commands+0x610>
ffffffffc0200f2e:	0d500593          	li	a1,213
ffffffffc0200f32:	00001517          	auipc	a0,0x1
ffffffffc0200f36:	3e650513          	addi	a0,a0,998 # ffffffffc0202318 <commands+0x628>
ffffffffc0200f3a:	a00ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f3e:	00001697          	auipc	a3,0x1
ffffffffc0200f42:	45268693          	addi	a3,a3,1106 # ffffffffc0202390 <commands+0x6a0>
ffffffffc0200f46:	00001617          	auipc	a2,0x1
ffffffffc0200f4a:	3ba60613          	addi	a2,a2,954 # ffffffffc0202300 <commands+0x610>
ffffffffc0200f4e:	0d300593          	li	a1,211
ffffffffc0200f52:	00001517          	auipc	a0,0x1
ffffffffc0200f56:	3c650513          	addi	a0,a0,966 # ffffffffc0202318 <commands+0x628>
ffffffffc0200f5a:	9e0ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f5e:	00001697          	auipc	a3,0x1
ffffffffc0200f62:	41268693          	addi	a3,a3,1042 # ffffffffc0202370 <commands+0x680>
ffffffffc0200f66:	00001617          	auipc	a2,0x1
ffffffffc0200f6a:	39a60613          	addi	a2,a2,922 # ffffffffc0202300 <commands+0x610>
ffffffffc0200f6e:	0d200593          	li	a1,210
ffffffffc0200f72:	00001517          	auipc	a0,0x1
ffffffffc0200f76:	3a650513          	addi	a0,a0,934 # ffffffffc0202318 <commands+0x628>
ffffffffc0200f7a:	9c0ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f7e:	00001697          	auipc	a3,0x1
ffffffffc0200f82:	41268693          	addi	a3,a3,1042 # ffffffffc0202390 <commands+0x6a0>
ffffffffc0200f86:	00001617          	auipc	a2,0x1
ffffffffc0200f8a:	37a60613          	addi	a2,a2,890 # ffffffffc0202300 <commands+0x610>
ffffffffc0200f8e:	0ba00593          	li	a1,186
ffffffffc0200f92:	00001517          	auipc	a0,0x1
ffffffffc0200f96:	38650513          	addi	a0,a0,902 # ffffffffc0202318 <commands+0x628>
ffffffffc0200f9a:	9a0ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(count == 0);
ffffffffc0200f9e:	00001697          	auipc	a3,0x1
ffffffffc0200fa2:	69a68693          	addi	a3,a3,1690 # ffffffffc0202638 <commands+0x948>
ffffffffc0200fa6:	00001617          	auipc	a2,0x1
ffffffffc0200faa:	35a60613          	addi	a2,a2,858 # ffffffffc0202300 <commands+0x610>
ffffffffc0200fae:	12400593          	li	a1,292
ffffffffc0200fb2:	00001517          	auipc	a0,0x1
ffffffffc0200fb6:	36650513          	addi	a0,a0,870 # ffffffffc0202318 <commands+0x628>
ffffffffc0200fba:	980ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(nr_free == 0);
ffffffffc0200fbe:	00001697          	auipc	a3,0x1
ffffffffc0200fc2:	51a68693          	addi	a3,a3,1306 # ffffffffc02024d8 <commands+0x7e8>
ffffffffc0200fc6:	00001617          	auipc	a2,0x1
ffffffffc0200fca:	33a60613          	addi	a2,a2,826 # ffffffffc0202300 <commands+0x610>
ffffffffc0200fce:	11900593          	li	a1,281
ffffffffc0200fd2:	00001517          	auipc	a0,0x1
ffffffffc0200fd6:	34650513          	addi	a0,a0,838 # ffffffffc0202318 <commands+0x628>
ffffffffc0200fda:	960ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fde:	00001697          	auipc	a3,0x1
ffffffffc0200fe2:	49a68693          	addi	a3,a3,1178 # ffffffffc0202478 <commands+0x788>
ffffffffc0200fe6:	00001617          	auipc	a2,0x1
ffffffffc0200fea:	31a60613          	addi	a2,a2,794 # ffffffffc0202300 <commands+0x610>
ffffffffc0200fee:	11700593          	li	a1,279
ffffffffc0200ff2:	00001517          	auipc	a0,0x1
ffffffffc0200ff6:	32650513          	addi	a0,a0,806 # ffffffffc0202318 <commands+0x628>
ffffffffc0200ffa:	940ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200ffe:	00001697          	auipc	a3,0x1
ffffffffc0201002:	43a68693          	addi	a3,a3,1082 # ffffffffc0202438 <commands+0x748>
ffffffffc0201006:	00001617          	auipc	a2,0x1
ffffffffc020100a:	2fa60613          	addi	a2,a2,762 # ffffffffc0202300 <commands+0x610>
ffffffffc020100e:	0c000593          	li	a1,192
ffffffffc0201012:	00001517          	auipc	a0,0x1
ffffffffc0201016:	30650513          	addi	a0,a0,774 # ffffffffc0202318 <commands+0x628>
ffffffffc020101a:	920ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020101e:	00001697          	auipc	a3,0x1
ffffffffc0201022:	5da68693          	addi	a3,a3,1498 # ffffffffc02025f8 <commands+0x908>
ffffffffc0201026:	00001617          	auipc	a2,0x1
ffffffffc020102a:	2da60613          	addi	a2,a2,730 # ffffffffc0202300 <commands+0x610>
ffffffffc020102e:	11100593          	li	a1,273
ffffffffc0201032:	00001517          	auipc	a0,0x1
ffffffffc0201036:	2e650513          	addi	a0,a0,742 # ffffffffc0202318 <commands+0x628>
ffffffffc020103a:	900ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020103e:	00001697          	auipc	a3,0x1
ffffffffc0201042:	59a68693          	addi	a3,a3,1434 # ffffffffc02025d8 <commands+0x8e8>
ffffffffc0201046:	00001617          	auipc	a2,0x1
ffffffffc020104a:	2ba60613          	addi	a2,a2,698 # ffffffffc0202300 <commands+0x610>
ffffffffc020104e:	10f00593          	li	a1,271
ffffffffc0201052:	00001517          	auipc	a0,0x1
ffffffffc0201056:	2c650513          	addi	a0,a0,710 # ffffffffc0202318 <commands+0x628>
ffffffffc020105a:	8e0ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020105e:	00001697          	auipc	a3,0x1
ffffffffc0201062:	55268693          	addi	a3,a3,1362 # ffffffffc02025b0 <commands+0x8c0>
ffffffffc0201066:	00001617          	auipc	a2,0x1
ffffffffc020106a:	29a60613          	addi	a2,a2,666 # ffffffffc0202300 <commands+0x610>
ffffffffc020106e:	10d00593          	li	a1,269
ffffffffc0201072:	00001517          	auipc	a0,0x1
ffffffffc0201076:	2a650513          	addi	a0,a0,678 # ffffffffc0202318 <commands+0x628>
ffffffffc020107a:	8c0ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020107e:	00001697          	auipc	a3,0x1
ffffffffc0201082:	50a68693          	addi	a3,a3,1290 # ffffffffc0202588 <commands+0x898>
ffffffffc0201086:	00001617          	auipc	a2,0x1
ffffffffc020108a:	27a60613          	addi	a2,a2,634 # ffffffffc0202300 <commands+0x610>
ffffffffc020108e:	10c00593          	li	a1,268
ffffffffc0201092:	00001517          	auipc	a0,0x1
ffffffffc0201096:	28650513          	addi	a0,a0,646 # ffffffffc0202318 <commands+0x628>
ffffffffc020109a:	8a0ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p0 + 2 == p1);
ffffffffc020109e:	00001697          	auipc	a3,0x1
ffffffffc02010a2:	4da68693          	addi	a3,a3,1242 # ffffffffc0202578 <commands+0x888>
ffffffffc02010a6:	00001617          	auipc	a2,0x1
ffffffffc02010aa:	25a60613          	addi	a2,a2,602 # ffffffffc0202300 <commands+0x610>
ffffffffc02010ae:	10700593          	li	a1,263
ffffffffc02010b2:	00001517          	auipc	a0,0x1
ffffffffc02010b6:	26650513          	addi	a0,a0,614 # ffffffffc0202318 <commands+0x628>
ffffffffc02010ba:	880ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010be:	00001697          	auipc	a3,0x1
ffffffffc02010c2:	3ba68693          	addi	a3,a3,954 # ffffffffc0202478 <commands+0x788>
ffffffffc02010c6:	00001617          	auipc	a2,0x1
ffffffffc02010ca:	23a60613          	addi	a2,a2,570 # ffffffffc0202300 <commands+0x610>
ffffffffc02010ce:	10600593          	li	a1,262
ffffffffc02010d2:	00001517          	auipc	a0,0x1
ffffffffc02010d6:	24650513          	addi	a0,a0,582 # ffffffffc0202318 <commands+0x628>
ffffffffc02010da:	860ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02010de:	00001697          	auipc	a3,0x1
ffffffffc02010e2:	47a68693          	addi	a3,a3,1146 # ffffffffc0202558 <commands+0x868>
ffffffffc02010e6:	00001617          	auipc	a2,0x1
ffffffffc02010ea:	21a60613          	addi	a2,a2,538 # ffffffffc0202300 <commands+0x610>
ffffffffc02010ee:	10500593          	li	a1,261
ffffffffc02010f2:	00001517          	auipc	a0,0x1
ffffffffc02010f6:	22650513          	addi	a0,a0,550 # ffffffffc0202318 <commands+0x628>
ffffffffc02010fa:	840ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02010fe:	00001697          	auipc	a3,0x1
ffffffffc0201102:	42a68693          	addi	a3,a3,1066 # ffffffffc0202528 <commands+0x838>
ffffffffc0201106:	00001617          	auipc	a2,0x1
ffffffffc020110a:	1fa60613          	addi	a2,a2,506 # ffffffffc0202300 <commands+0x610>
ffffffffc020110e:	10400593          	li	a1,260
ffffffffc0201112:	00001517          	auipc	a0,0x1
ffffffffc0201116:	20650513          	addi	a0,a0,518 # ffffffffc0202318 <commands+0x628>
ffffffffc020111a:	820ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020111e:	00001697          	auipc	a3,0x1
ffffffffc0201122:	3f268693          	addi	a3,a3,1010 # ffffffffc0202510 <commands+0x820>
ffffffffc0201126:	00001617          	auipc	a2,0x1
ffffffffc020112a:	1da60613          	addi	a2,a2,474 # ffffffffc0202300 <commands+0x610>
ffffffffc020112e:	10300593          	li	a1,259
ffffffffc0201132:	00001517          	auipc	a0,0x1
ffffffffc0201136:	1e650513          	addi	a0,a0,486 # ffffffffc0202318 <commands+0x628>
ffffffffc020113a:	800ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_page() == NULL);
ffffffffc020113e:	00001697          	auipc	a3,0x1
ffffffffc0201142:	33a68693          	addi	a3,a3,826 # ffffffffc0202478 <commands+0x788>
ffffffffc0201146:	00001617          	auipc	a2,0x1
ffffffffc020114a:	1ba60613          	addi	a2,a2,442 # ffffffffc0202300 <commands+0x610>
ffffffffc020114e:	0fd00593          	li	a1,253
ffffffffc0201152:	00001517          	auipc	a0,0x1
ffffffffc0201156:	1c650513          	addi	a0,a0,454 # ffffffffc0202318 <commands+0x628>
ffffffffc020115a:	fe1fe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(!PageProperty(p0));
ffffffffc020115e:	00001697          	auipc	a3,0x1
ffffffffc0201162:	39a68693          	addi	a3,a3,922 # ffffffffc02024f8 <commands+0x808>
ffffffffc0201166:	00001617          	auipc	a2,0x1
ffffffffc020116a:	19a60613          	addi	a2,a2,410 # ffffffffc0202300 <commands+0x610>
ffffffffc020116e:	0f800593          	li	a1,248
ffffffffc0201172:	00001517          	auipc	a0,0x1
ffffffffc0201176:	1a650513          	addi	a0,a0,422 # ffffffffc0202318 <commands+0x628>
ffffffffc020117a:	fc1fe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020117e:	00001697          	auipc	a3,0x1
ffffffffc0201182:	49a68693          	addi	a3,a3,1178 # ffffffffc0202618 <commands+0x928>
ffffffffc0201186:	00001617          	auipc	a2,0x1
ffffffffc020118a:	17a60613          	addi	a2,a2,378 # ffffffffc0202300 <commands+0x610>
ffffffffc020118e:	11600593          	li	a1,278
ffffffffc0201192:	00001517          	auipc	a0,0x1
ffffffffc0201196:	18650513          	addi	a0,a0,390 # ffffffffc0202318 <commands+0x628>
ffffffffc020119a:	fa1fe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(total == 0);
ffffffffc020119e:	00001697          	auipc	a3,0x1
ffffffffc02011a2:	4aa68693          	addi	a3,a3,1194 # ffffffffc0202648 <commands+0x958>
ffffffffc02011a6:	00001617          	auipc	a2,0x1
ffffffffc02011aa:	15a60613          	addi	a2,a2,346 # ffffffffc0202300 <commands+0x610>
ffffffffc02011ae:	12500593          	li	a1,293
ffffffffc02011b2:	00001517          	auipc	a0,0x1
ffffffffc02011b6:	16650513          	addi	a0,a0,358 # ffffffffc0202318 <commands+0x628>
ffffffffc02011ba:	f81fe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(total == nr_free_pages());
ffffffffc02011be:	00001697          	auipc	a3,0x1
ffffffffc02011c2:	17268693          	addi	a3,a3,370 # ffffffffc0202330 <commands+0x640>
ffffffffc02011c6:	00001617          	auipc	a2,0x1
ffffffffc02011ca:	13a60613          	addi	a2,a2,314 # ffffffffc0202300 <commands+0x610>
ffffffffc02011ce:	0f200593          	li	a1,242
ffffffffc02011d2:	00001517          	auipc	a0,0x1
ffffffffc02011d6:	14650513          	addi	a0,a0,326 # ffffffffc0202318 <commands+0x628>
ffffffffc02011da:	f61fe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02011de:	00001697          	auipc	a3,0x1
ffffffffc02011e2:	19268693          	addi	a3,a3,402 # ffffffffc0202370 <commands+0x680>
ffffffffc02011e6:	00001617          	auipc	a2,0x1
ffffffffc02011ea:	11a60613          	addi	a2,a2,282 # ffffffffc0202300 <commands+0x610>
ffffffffc02011ee:	0b900593          	li	a1,185
ffffffffc02011f2:	00001517          	auipc	a0,0x1
ffffffffc02011f6:	12650513          	addi	a0,a0,294 # ffffffffc0202318 <commands+0x628>
ffffffffc02011fa:	f41fe0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc02011fe <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02011fe:	1141                	addi	sp,sp,-16
ffffffffc0201200:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201202:	14058a63          	beqz	a1,ffffffffc0201356 <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0201206:	00259693          	slli	a3,a1,0x2
ffffffffc020120a:	96ae                	add	a3,a3,a1
ffffffffc020120c:	068e                	slli	a3,a3,0x3
ffffffffc020120e:	96aa                	add	a3,a3,a0
ffffffffc0201210:	87aa                	mv	a5,a0
ffffffffc0201212:	02d50263          	beq	a0,a3,ffffffffc0201236 <default_free_pages+0x38>
ffffffffc0201216:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201218:	8b05                	andi	a4,a4,1
ffffffffc020121a:	10071e63          	bnez	a4,ffffffffc0201336 <default_free_pages+0x138>
ffffffffc020121e:	6798                	ld	a4,8(a5)
ffffffffc0201220:	8b09                	andi	a4,a4,2
ffffffffc0201222:	10071a63          	bnez	a4,ffffffffc0201336 <default_free_pages+0x138>
        p->flags = 0;
ffffffffc0201226:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020122a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020122e:	02878793          	addi	a5,a5,40
ffffffffc0201232:	fed792e3          	bne	a5,a3,ffffffffc0201216 <default_free_pages+0x18>
    base->property = n;
ffffffffc0201236:	2581                	sext.w	a1,a1
ffffffffc0201238:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020123a:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020123e:	4789                	li	a5,2
ffffffffc0201240:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201244:	00005697          	auipc	a3,0x5
ffffffffc0201248:	dcc68693          	addi	a3,a3,-564 # ffffffffc0206010 <free_area>
ffffffffc020124c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020124e:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201250:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201254:	9db9                	addw	a1,a1,a4
ffffffffc0201256:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201258:	0ad78863          	beq	a5,a3,ffffffffc0201308 <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc020125c:	fe878713          	addi	a4,a5,-24
ffffffffc0201260:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201264:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201266:	00e56a63          	bltu	a0,a4,ffffffffc020127a <default_free_pages+0x7c>
    return listelm->next;
ffffffffc020126a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020126c:	06d70263          	beq	a4,a3,ffffffffc02012d0 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201270:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201272:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201276:	fee57ae3          	bgeu	a0,a4,ffffffffc020126a <default_free_pages+0x6c>
ffffffffc020127a:	c199                	beqz	a1,ffffffffc0201280 <default_free_pages+0x82>
ffffffffc020127c:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201280:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201282:	e390                	sd	a2,0(a5)
ffffffffc0201284:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201286:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201288:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc020128a:	02d70063          	beq	a4,a3,ffffffffc02012aa <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc020128e:	ff872803          	lw	a6,-8(a4) # ffffffffffffeff8 <end+0x3fdf8b88>
        p = le2page(le, page_link);
ffffffffc0201292:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc0201296:	02081613          	slli	a2,a6,0x20
ffffffffc020129a:	9201                	srli	a2,a2,0x20
ffffffffc020129c:	00261793          	slli	a5,a2,0x2
ffffffffc02012a0:	97b2                	add	a5,a5,a2
ffffffffc02012a2:	078e                	slli	a5,a5,0x3
ffffffffc02012a4:	97ae                	add	a5,a5,a1
ffffffffc02012a6:	02f50f63          	beq	a0,a5,ffffffffc02012e4 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc02012aa:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc02012ac:	00d70f63          	beq	a4,a3,ffffffffc02012ca <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc02012b0:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc02012b2:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc02012b6:	02059613          	slli	a2,a1,0x20
ffffffffc02012ba:	9201                	srli	a2,a2,0x20
ffffffffc02012bc:	00261793          	slli	a5,a2,0x2
ffffffffc02012c0:	97b2                	add	a5,a5,a2
ffffffffc02012c2:	078e                	slli	a5,a5,0x3
ffffffffc02012c4:	97aa                	add	a5,a5,a0
ffffffffc02012c6:	04f68863          	beq	a3,a5,ffffffffc0201316 <default_free_pages+0x118>
}
ffffffffc02012ca:	60a2                	ld	ra,8(sp)
ffffffffc02012cc:	0141                	addi	sp,sp,16
ffffffffc02012ce:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02012d0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02012d2:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02012d4:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02012d6:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02012d8:	02d70563          	beq	a4,a3,ffffffffc0201302 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc02012dc:	8832                	mv	a6,a2
ffffffffc02012de:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02012e0:	87ba                	mv	a5,a4
ffffffffc02012e2:	bf41                	j	ffffffffc0201272 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc02012e4:	491c                	lw	a5,16(a0)
ffffffffc02012e6:	0107883b          	addw	a6,a5,a6
ffffffffc02012ea:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02012ee:	57f5                	li	a5,-3
ffffffffc02012f0:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02012f4:	6d10                	ld	a2,24(a0)
ffffffffc02012f6:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc02012f8:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02012fa:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02012fc:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02012fe:	e390                	sd	a2,0(a5)
ffffffffc0201300:	b775                	j	ffffffffc02012ac <default_free_pages+0xae>
ffffffffc0201302:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201304:	873e                	mv	a4,a5
ffffffffc0201306:	b761                	j	ffffffffc020128e <default_free_pages+0x90>
}
ffffffffc0201308:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020130a:	e390                	sd	a2,0(a5)
ffffffffc020130c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020130e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201310:	ed1c                	sd	a5,24(a0)
ffffffffc0201312:	0141                	addi	sp,sp,16
ffffffffc0201314:	8082                	ret
            base->property += p->property;
ffffffffc0201316:	ff872783          	lw	a5,-8(a4)
ffffffffc020131a:	ff070693          	addi	a3,a4,-16
ffffffffc020131e:	9dbd                	addw	a1,a1,a5
ffffffffc0201320:	c90c                	sw	a1,16(a0)
ffffffffc0201322:	57f5                	li	a5,-3
ffffffffc0201324:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201328:	6314                	ld	a3,0(a4)
ffffffffc020132a:	671c                	ld	a5,8(a4)
}
ffffffffc020132c:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020132e:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201330:	e394                	sd	a3,0(a5)
ffffffffc0201332:	0141                	addi	sp,sp,16
ffffffffc0201334:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201336:	00001697          	auipc	a3,0x1
ffffffffc020133a:	32a68693          	addi	a3,a3,810 # ffffffffc0202660 <commands+0x970>
ffffffffc020133e:	00001617          	auipc	a2,0x1
ffffffffc0201342:	fc260613          	addi	a2,a2,-62 # ffffffffc0202300 <commands+0x610>
ffffffffc0201346:	08100593          	li	a1,129
ffffffffc020134a:	00001517          	auipc	a0,0x1
ffffffffc020134e:	fce50513          	addi	a0,a0,-50 # ffffffffc0202318 <commands+0x628>
ffffffffc0201352:	de9fe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(n > 0);
ffffffffc0201356:	00001697          	auipc	a3,0x1
ffffffffc020135a:	30268693          	addi	a3,a3,770 # ffffffffc0202658 <commands+0x968>
ffffffffc020135e:	00001617          	auipc	a2,0x1
ffffffffc0201362:	fa260613          	addi	a2,a2,-94 # ffffffffc0202300 <commands+0x610>
ffffffffc0201366:	07e00593          	li	a1,126
ffffffffc020136a:	00001517          	auipc	a0,0x1
ffffffffc020136e:	fae50513          	addi	a0,a0,-82 # ffffffffc0202318 <commands+0x628>
ffffffffc0201372:	dc9fe0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0201376 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201376:	c959                	beqz	a0,ffffffffc020140c <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0201378:	00005597          	auipc	a1,0x5
ffffffffc020137c:	c9858593          	addi	a1,a1,-872 # ffffffffc0206010 <free_area>
ffffffffc0201380:	0105a803          	lw	a6,16(a1)
ffffffffc0201384:	862a                	mv	a2,a0
ffffffffc0201386:	02081793          	slli	a5,a6,0x20
ffffffffc020138a:	9381                	srli	a5,a5,0x20
ffffffffc020138c:	00a7ee63          	bltu	a5,a0,ffffffffc02013a8 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201390:	87ae                	mv	a5,a1
ffffffffc0201392:	a801                	j	ffffffffc02013a2 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201394:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201398:	02071693          	slli	a3,a4,0x20
ffffffffc020139c:	9281                	srli	a3,a3,0x20
ffffffffc020139e:	00c6f763          	bgeu	a3,a2,ffffffffc02013ac <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02013a2:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02013a4:	feb798e3          	bne	a5,a1,ffffffffc0201394 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02013a8:	4501                	li	a0,0
}
ffffffffc02013aa:	8082                	ret
    return listelm->prev;
ffffffffc02013ac:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013b0:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02013b4:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc02013b8:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc02013bc:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02013c0:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02013c4:	02d67b63          	bgeu	a2,a3,ffffffffc02013fa <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc02013c8:	00261693          	slli	a3,a2,0x2
ffffffffc02013cc:	96b2                	add	a3,a3,a2
ffffffffc02013ce:	068e                	slli	a3,a3,0x3
ffffffffc02013d0:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02013d2:	41c7073b          	subw	a4,a4,t3
ffffffffc02013d6:	ca98                	sw	a4,16(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02013d8:	00868613          	addi	a2,a3,8
ffffffffc02013dc:	4709                	li	a4,2
ffffffffc02013de:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02013e2:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02013e6:	01868613          	addi	a2,a3,24
        nr_free -= n;
ffffffffc02013ea:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02013ee:	e310                	sd	a2,0(a4)
ffffffffc02013f0:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02013f4:	f298                	sd	a4,32(a3)
    elm->prev = prev;
ffffffffc02013f6:	0116bc23          	sd	a7,24(a3)
ffffffffc02013fa:	41c8083b          	subw	a6,a6,t3
ffffffffc02013fe:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201402:	5775                	li	a4,-3
ffffffffc0201404:	17c1                	addi	a5,a5,-16
ffffffffc0201406:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020140a:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020140c:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020140e:	00001697          	auipc	a3,0x1
ffffffffc0201412:	24a68693          	addi	a3,a3,586 # ffffffffc0202658 <commands+0x968>
ffffffffc0201416:	00001617          	auipc	a2,0x1
ffffffffc020141a:	eea60613          	addi	a2,a2,-278 # ffffffffc0202300 <commands+0x610>
ffffffffc020141e:	06000593          	li	a1,96
ffffffffc0201422:	00001517          	auipc	a0,0x1
ffffffffc0201426:	ef650513          	addi	a0,a0,-266 # ffffffffc0202318 <commands+0x628>
default_alloc_pages(size_t n) {
ffffffffc020142a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020142c:	d0ffe0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0201430 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201430:	1141                	addi	sp,sp,-16
ffffffffc0201432:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201434:	c9e1                	beqz	a1,ffffffffc0201504 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0201436:	00259693          	slli	a3,a1,0x2
ffffffffc020143a:	96ae                	add	a3,a3,a1
ffffffffc020143c:	068e                	slli	a3,a3,0x3
ffffffffc020143e:	96aa                	add	a3,a3,a0
ffffffffc0201440:	87aa                	mv	a5,a0
ffffffffc0201442:	00d50f63          	beq	a0,a3,ffffffffc0201460 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201446:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201448:	8b05                	andi	a4,a4,1
ffffffffc020144a:	cf49                	beqz	a4,ffffffffc02014e4 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc020144c:	0007a823          	sw	zero,16(a5)
ffffffffc0201450:	0007b423          	sd	zero,8(a5)
ffffffffc0201454:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201458:	02878793          	addi	a5,a5,40
ffffffffc020145c:	fed795e3          	bne	a5,a3,ffffffffc0201446 <default_init_memmap+0x16>
    base->property = n;
ffffffffc0201460:	2581                	sext.w	a1,a1
ffffffffc0201462:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201464:	4789                	li	a5,2
ffffffffc0201466:	00850713          	addi	a4,a0,8
ffffffffc020146a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020146e:	00005697          	auipc	a3,0x5
ffffffffc0201472:	ba268693          	addi	a3,a3,-1118 # ffffffffc0206010 <free_area>
ffffffffc0201476:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201478:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020147a:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020147e:	9db9                	addw	a1,a1,a4
ffffffffc0201480:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201482:	04d78a63          	beq	a5,a3,ffffffffc02014d6 <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0201486:	fe878713          	addi	a4,a5,-24
ffffffffc020148a:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020148e:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201490:	00e56a63          	bltu	a0,a4,ffffffffc02014a4 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc0201494:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201496:	02d70263          	beq	a4,a3,ffffffffc02014ba <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc020149a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020149c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02014a0:	fee57ae3          	bgeu	a0,a4,ffffffffc0201494 <default_init_memmap+0x64>
ffffffffc02014a4:	c199                	beqz	a1,ffffffffc02014aa <default_init_memmap+0x7a>
ffffffffc02014a6:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02014aa:	6398                	ld	a4,0(a5)
}
ffffffffc02014ac:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02014ae:	e390                	sd	a2,0(a5)
ffffffffc02014b0:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02014b2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02014b4:	ed18                	sd	a4,24(a0)
ffffffffc02014b6:	0141                	addi	sp,sp,16
ffffffffc02014b8:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02014ba:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02014bc:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02014be:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02014c0:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02014c2:	00d70663          	beq	a4,a3,ffffffffc02014ce <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02014c6:	8832                	mv	a6,a2
ffffffffc02014c8:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02014ca:	87ba                	mv	a5,a4
ffffffffc02014cc:	bfc1                	j	ffffffffc020149c <default_init_memmap+0x6c>
}
ffffffffc02014ce:	60a2                	ld	ra,8(sp)
ffffffffc02014d0:	e290                	sd	a2,0(a3)
ffffffffc02014d2:	0141                	addi	sp,sp,16
ffffffffc02014d4:	8082                	ret
ffffffffc02014d6:	60a2                	ld	ra,8(sp)
ffffffffc02014d8:	e390                	sd	a2,0(a5)
ffffffffc02014da:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02014dc:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02014de:	ed1c                	sd	a5,24(a0)
ffffffffc02014e0:	0141                	addi	sp,sp,16
ffffffffc02014e2:	8082                	ret
        assert(PageReserved(p));
ffffffffc02014e4:	00001697          	auipc	a3,0x1
ffffffffc02014e8:	1a468693          	addi	a3,a3,420 # ffffffffc0202688 <commands+0x998>
ffffffffc02014ec:	00001617          	auipc	a2,0x1
ffffffffc02014f0:	e1460613          	addi	a2,a2,-492 # ffffffffc0202300 <commands+0x610>
ffffffffc02014f4:	04700593          	li	a1,71
ffffffffc02014f8:	00001517          	auipc	a0,0x1
ffffffffc02014fc:	e2050513          	addi	a0,a0,-480 # ffffffffc0202318 <commands+0x628>
ffffffffc0201500:	c3bfe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(n > 0);
ffffffffc0201504:	00001697          	auipc	a3,0x1
ffffffffc0201508:	15468693          	addi	a3,a3,340 # ffffffffc0202658 <commands+0x968>
ffffffffc020150c:	00001617          	auipc	a2,0x1
ffffffffc0201510:	df460613          	addi	a2,a2,-524 # ffffffffc0202300 <commands+0x610>
ffffffffc0201514:	04400593          	li	a1,68
ffffffffc0201518:	00001517          	auipc	a0,0x1
ffffffffc020151c:	e0050513          	addi	a0,a0,-512 # ffffffffc0202318 <commands+0x628>
ffffffffc0201520:	c1bfe0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0201524 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201524:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201526:	e589                	bnez	a1,ffffffffc0201530 <strnlen+0xc>
ffffffffc0201528:	a811                	j	ffffffffc020153c <strnlen+0x18>
        cnt ++;
ffffffffc020152a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020152c:	00f58863          	beq	a1,a5,ffffffffc020153c <strnlen+0x18>
ffffffffc0201530:	00f50733          	add	a4,a0,a5
ffffffffc0201534:	00074703          	lbu	a4,0(a4)
ffffffffc0201538:	fb6d                	bnez	a4,ffffffffc020152a <strnlen+0x6>
ffffffffc020153a:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020153c:	852e                	mv	a0,a1
ffffffffc020153e:	8082                	ret

ffffffffc0201540 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201540:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201544:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201548:	cb89                	beqz	a5,ffffffffc020155a <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020154a:	0505                	addi	a0,a0,1
ffffffffc020154c:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020154e:	fee789e3          	beq	a5,a4,ffffffffc0201540 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201552:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201556:	9d19                	subw	a0,a0,a4
ffffffffc0201558:	8082                	ret
ffffffffc020155a:	4501                	li	a0,0
ffffffffc020155c:	bfed                	j	ffffffffc0201556 <strcmp+0x16>

ffffffffc020155e <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020155e:	00054783          	lbu	a5,0(a0)
ffffffffc0201562:	c799                	beqz	a5,ffffffffc0201570 <strchr+0x12>
        if (*s == c) {
ffffffffc0201564:	00f58763          	beq	a1,a5,ffffffffc0201572 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201568:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020156c:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020156e:	fbfd                	bnez	a5,ffffffffc0201564 <strchr+0x6>
    }
    return NULL;
ffffffffc0201570:	4501                	li	a0,0
}
ffffffffc0201572:	8082                	ret

ffffffffc0201574 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201574:	ca01                	beqz	a2,ffffffffc0201584 <memset+0x10>
ffffffffc0201576:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201578:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020157a:	0785                	addi	a5,a5,1
ffffffffc020157c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201580:	fec79de3          	bne	a5,a2,ffffffffc020157a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201584:	8082                	ret

ffffffffc0201586 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201586:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020158a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020158c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201590:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201592:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201596:	f022                	sd	s0,32(sp)
ffffffffc0201598:	ec26                	sd	s1,24(sp)
ffffffffc020159a:	e84a                	sd	s2,16(sp)
ffffffffc020159c:	f406                	sd	ra,40(sp)
ffffffffc020159e:	e44e                	sd	s3,8(sp)
ffffffffc02015a0:	84aa                	mv	s1,a0
ffffffffc02015a2:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02015a4:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02015a8:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02015aa:	03067e63          	bgeu	a2,a6,ffffffffc02015e6 <printnum+0x60>
ffffffffc02015ae:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02015b0:	00805763          	blez	s0,ffffffffc02015be <printnum+0x38>
ffffffffc02015b4:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02015b6:	85ca                	mv	a1,s2
ffffffffc02015b8:	854e                	mv	a0,s3
ffffffffc02015ba:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02015bc:	fc65                	bnez	s0,ffffffffc02015b4 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015be:	1a02                	slli	s4,s4,0x20
ffffffffc02015c0:	00001797          	auipc	a5,0x1
ffffffffc02015c4:	12878793          	addi	a5,a5,296 # ffffffffc02026e8 <default_pmm_manager+0x38>
ffffffffc02015c8:	020a5a13          	srli	s4,s4,0x20
ffffffffc02015cc:	9a3e                	add	s4,s4,a5
}
ffffffffc02015ce:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015d0:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02015d4:	70a2                	ld	ra,40(sp)
ffffffffc02015d6:	69a2                	ld	s3,8(sp)
ffffffffc02015d8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015da:	85ca                	mv	a1,s2
ffffffffc02015dc:	87a6                	mv	a5,s1
}
ffffffffc02015de:	6942                	ld	s2,16(sp)
ffffffffc02015e0:	64e2                	ld	s1,24(sp)
ffffffffc02015e2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015e4:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02015e6:	03065633          	divu	a2,a2,a6
ffffffffc02015ea:	8722                	mv	a4,s0
ffffffffc02015ec:	f9bff0ef          	jal	ra,ffffffffc0201586 <printnum>
ffffffffc02015f0:	b7f9                	j	ffffffffc02015be <printnum+0x38>

ffffffffc02015f2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02015f2:	7119                	addi	sp,sp,-128
ffffffffc02015f4:	f4a6                	sd	s1,104(sp)
ffffffffc02015f6:	f0ca                	sd	s2,96(sp)
ffffffffc02015f8:	ecce                	sd	s3,88(sp)
ffffffffc02015fa:	e8d2                	sd	s4,80(sp)
ffffffffc02015fc:	e4d6                	sd	s5,72(sp)
ffffffffc02015fe:	e0da                	sd	s6,64(sp)
ffffffffc0201600:	fc5e                	sd	s7,56(sp)
ffffffffc0201602:	f06a                	sd	s10,32(sp)
ffffffffc0201604:	fc86                	sd	ra,120(sp)
ffffffffc0201606:	f8a2                	sd	s0,112(sp)
ffffffffc0201608:	f862                	sd	s8,48(sp)
ffffffffc020160a:	f466                	sd	s9,40(sp)
ffffffffc020160c:	ec6e                	sd	s11,24(sp)
ffffffffc020160e:	892a                	mv	s2,a0
ffffffffc0201610:	84ae                	mv	s1,a1
ffffffffc0201612:	8d32                	mv	s10,a2
ffffffffc0201614:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201616:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020161a:	5b7d                	li	s6,-1
ffffffffc020161c:	00001a97          	auipc	s5,0x1
ffffffffc0201620:	100a8a93          	addi	s5,s5,256 # ffffffffc020271c <default_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201624:	00001b97          	auipc	s7,0x1
ffffffffc0201628:	2d4b8b93          	addi	s7,s7,724 # ffffffffc02028f8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020162c:	000d4503          	lbu	a0,0(s10)
ffffffffc0201630:	001d0413          	addi	s0,s10,1
ffffffffc0201634:	01350a63          	beq	a0,s3,ffffffffc0201648 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201638:	c121                	beqz	a0,ffffffffc0201678 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020163a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020163c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020163e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201640:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201644:	ff351ae3          	bne	a0,s3,ffffffffc0201638 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201648:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020164c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201650:	4c81                	li	s9,0
ffffffffc0201652:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201654:	5c7d                	li	s8,-1
ffffffffc0201656:	5dfd                	li	s11,-1
ffffffffc0201658:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020165c:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020165e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201662:	0ff5f593          	zext.b	a1,a1
ffffffffc0201666:	00140d13          	addi	s10,s0,1
ffffffffc020166a:	04b56263          	bltu	a0,a1,ffffffffc02016ae <vprintfmt+0xbc>
ffffffffc020166e:	058a                	slli	a1,a1,0x2
ffffffffc0201670:	95d6                	add	a1,a1,s5
ffffffffc0201672:	4194                	lw	a3,0(a1)
ffffffffc0201674:	96d6                	add	a3,a3,s5
ffffffffc0201676:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201678:	70e6                	ld	ra,120(sp)
ffffffffc020167a:	7446                	ld	s0,112(sp)
ffffffffc020167c:	74a6                	ld	s1,104(sp)
ffffffffc020167e:	7906                	ld	s2,96(sp)
ffffffffc0201680:	69e6                	ld	s3,88(sp)
ffffffffc0201682:	6a46                	ld	s4,80(sp)
ffffffffc0201684:	6aa6                	ld	s5,72(sp)
ffffffffc0201686:	6b06                	ld	s6,64(sp)
ffffffffc0201688:	7be2                	ld	s7,56(sp)
ffffffffc020168a:	7c42                	ld	s8,48(sp)
ffffffffc020168c:	7ca2                	ld	s9,40(sp)
ffffffffc020168e:	7d02                	ld	s10,32(sp)
ffffffffc0201690:	6de2                	ld	s11,24(sp)
ffffffffc0201692:	6109                	addi	sp,sp,128
ffffffffc0201694:	8082                	ret
            padc = '0';
ffffffffc0201696:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201698:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020169c:	846a                	mv	s0,s10
ffffffffc020169e:	00140d13          	addi	s10,s0,1
ffffffffc02016a2:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02016a6:	0ff5f593          	zext.b	a1,a1
ffffffffc02016aa:	fcb572e3          	bgeu	a0,a1,ffffffffc020166e <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02016ae:	85a6                	mv	a1,s1
ffffffffc02016b0:	02500513          	li	a0,37
ffffffffc02016b4:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02016b6:	fff44783          	lbu	a5,-1(s0)
ffffffffc02016ba:	8d22                	mv	s10,s0
ffffffffc02016bc:	f73788e3          	beq	a5,s3,ffffffffc020162c <vprintfmt+0x3a>
ffffffffc02016c0:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02016c4:	1d7d                	addi	s10,s10,-1
ffffffffc02016c6:	ff379de3          	bne	a5,s3,ffffffffc02016c0 <vprintfmt+0xce>
ffffffffc02016ca:	b78d                	j	ffffffffc020162c <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02016cc:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02016d0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016d4:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02016d6:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02016da:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02016de:	02d86463          	bltu	a6,a3,ffffffffc0201706 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02016e2:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02016e6:	002c169b          	slliw	a3,s8,0x2
ffffffffc02016ea:	0186873b          	addw	a4,a3,s8
ffffffffc02016ee:	0017171b          	slliw	a4,a4,0x1
ffffffffc02016f2:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02016f4:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02016f8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02016fa:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02016fe:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201702:	fed870e3          	bgeu	a6,a3,ffffffffc02016e2 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201706:	f40ddce3          	bgez	s11,ffffffffc020165e <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020170a:	8de2                	mv	s11,s8
ffffffffc020170c:	5c7d                	li	s8,-1
ffffffffc020170e:	bf81                	j	ffffffffc020165e <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201710:	fffdc693          	not	a3,s11
ffffffffc0201714:	96fd                	srai	a3,a3,0x3f
ffffffffc0201716:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020171a:	00144603          	lbu	a2,1(s0)
ffffffffc020171e:	2d81                	sext.w	s11,s11
ffffffffc0201720:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201722:	bf35                	j	ffffffffc020165e <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201724:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201728:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020172c:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020172e:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201730:	bfd9                	j	ffffffffc0201706 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201732:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201734:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201738:	01174463          	blt	a4,a7,ffffffffc0201740 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020173c:	1a088e63          	beqz	a7,ffffffffc02018f8 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201740:	000a3603          	ld	a2,0(s4)
ffffffffc0201744:	46c1                	li	a3,16
ffffffffc0201746:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201748:	2781                	sext.w	a5,a5
ffffffffc020174a:	876e                	mv	a4,s11
ffffffffc020174c:	85a6                	mv	a1,s1
ffffffffc020174e:	854a                	mv	a0,s2
ffffffffc0201750:	e37ff0ef          	jal	ra,ffffffffc0201586 <printnum>
            break;
ffffffffc0201754:	bde1                	j	ffffffffc020162c <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201756:	000a2503          	lw	a0,0(s4)
ffffffffc020175a:	85a6                	mv	a1,s1
ffffffffc020175c:	0a21                	addi	s4,s4,8
ffffffffc020175e:	9902                	jalr	s2
            break;
ffffffffc0201760:	b5f1                	j	ffffffffc020162c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201762:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201764:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201768:	01174463          	blt	a4,a7,ffffffffc0201770 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020176c:	18088163          	beqz	a7,ffffffffc02018ee <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201770:	000a3603          	ld	a2,0(s4)
ffffffffc0201774:	46a9                	li	a3,10
ffffffffc0201776:	8a2e                	mv	s4,a1
ffffffffc0201778:	bfc1                	j	ffffffffc0201748 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020177a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020177e:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201780:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201782:	bdf1                	j	ffffffffc020165e <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201784:	85a6                	mv	a1,s1
ffffffffc0201786:	02500513          	li	a0,37
ffffffffc020178a:	9902                	jalr	s2
            break;
ffffffffc020178c:	b545                	j	ffffffffc020162c <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020178e:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201792:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201794:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201796:	b5e1                	j	ffffffffc020165e <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201798:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020179a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020179e:	01174463          	blt	a4,a7,ffffffffc02017a6 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02017a2:	14088163          	beqz	a7,ffffffffc02018e4 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02017a6:	000a3603          	ld	a2,0(s4)
ffffffffc02017aa:	46a1                	li	a3,8
ffffffffc02017ac:	8a2e                	mv	s4,a1
ffffffffc02017ae:	bf69                	j	ffffffffc0201748 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02017b0:	03000513          	li	a0,48
ffffffffc02017b4:	85a6                	mv	a1,s1
ffffffffc02017b6:	e03e                	sd	a5,0(sp)
ffffffffc02017b8:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02017ba:	85a6                	mv	a1,s1
ffffffffc02017bc:	07800513          	li	a0,120
ffffffffc02017c0:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02017c2:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02017c4:	6782                	ld	a5,0(sp)
ffffffffc02017c6:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02017c8:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02017cc:	bfb5                	j	ffffffffc0201748 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02017ce:	000a3403          	ld	s0,0(s4)
ffffffffc02017d2:	008a0713          	addi	a4,s4,8
ffffffffc02017d6:	e03a                	sd	a4,0(sp)
ffffffffc02017d8:	14040263          	beqz	s0,ffffffffc020191c <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02017dc:	0fb05763          	blez	s11,ffffffffc02018ca <vprintfmt+0x2d8>
ffffffffc02017e0:	02d00693          	li	a3,45
ffffffffc02017e4:	0cd79163          	bne	a5,a3,ffffffffc02018a6 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017e8:	00044783          	lbu	a5,0(s0)
ffffffffc02017ec:	0007851b          	sext.w	a0,a5
ffffffffc02017f0:	cf85                	beqz	a5,ffffffffc0201828 <vprintfmt+0x236>
ffffffffc02017f2:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017f6:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017fa:	000c4563          	bltz	s8,ffffffffc0201804 <vprintfmt+0x212>
ffffffffc02017fe:	3c7d                	addiw	s8,s8,-1
ffffffffc0201800:	036c0263          	beq	s8,s6,ffffffffc0201824 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201804:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201806:	0e0c8e63          	beqz	s9,ffffffffc0201902 <vprintfmt+0x310>
ffffffffc020180a:	3781                	addiw	a5,a5,-32
ffffffffc020180c:	0ef47b63          	bgeu	s0,a5,ffffffffc0201902 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201810:	03f00513          	li	a0,63
ffffffffc0201814:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201816:	000a4783          	lbu	a5,0(s4)
ffffffffc020181a:	3dfd                	addiw	s11,s11,-1
ffffffffc020181c:	0a05                	addi	s4,s4,1
ffffffffc020181e:	0007851b          	sext.w	a0,a5
ffffffffc0201822:	ffe1                	bnez	a5,ffffffffc02017fa <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201824:	01b05963          	blez	s11,ffffffffc0201836 <vprintfmt+0x244>
ffffffffc0201828:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020182a:	85a6                	mv	a1,s1
ffffffffc020182c:	02000513          	li	a0,32
ffffffffc0201830:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201832:	fe0d9be3          	bnez	s11,ffffffffc0201828 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201836:	6a02                	ld	s4,0(sp)
ffffffffc0201838:	bbd5                	j	ffffffffc020162c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020183a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020183c:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201840:	01174463          	blt	a4,a7,ffffffffc0201848 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201844:	08088d63          	beqz	a7,ffffffffc02018de <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201848:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020184c:	0a044d63          	bltz	s0,ffffffffc0201906 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201850:	8622                	mv	a2,s0
ffffffffc0201852:	8a66                	mv	s4,s9
ffffffffc0201854:	46a9                	li	a3,10
ffffffffc0201856:	bdcd                	j	ffffffffc0201748 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201858:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020185c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020185e:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201860:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201864:	8fb5                	xor	a5,a5,a3
ffffffffc0201866:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020186a:	02d74163          	blt	a4,a3,ffffffffc020188c <vprintfmt+0x29a>
ffffffffc020186e:	00369793          	slli	a5,a3,0x3
ffffffffc0201872:	97de                	add	a5,a5,s7
ffffffffc0201874:	639c                	ld	a5,0(a5)
ffffffffc0201876:	cb99                	beqz	a5,ffffffffc020188c <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201878:	86be                	mv	a3,a5
ffffffffc020187a:	00001617          	auipc	a2,0x1
ffffffffc020187e:	e9e60613          	addi	a2,a2,-354 # ffffffffc0202718 <default_pmm_manager+0x68>
ffffffffc0201882:	85a6                	mv	a1,s1
ffffffffc0201884:	854a                	mv	a0,s2
ffffffffc0201886:	0ce000ef          	jal	ra,ffffffffc0201954 <printfmt>
ffffffffc020188a:	b34d                	j	ffffffffc020162c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020188c:	00001617          	auipc	a2,0x1
ffffffffc0201890:	e7c60613          	addi	a2,a2,-388 # ffffffffc0202708 <default_pmm_manager+0x58>
ffffffffc0201894:	85a6                	mv	a1,s1
ffffffffc0201896:	854a                	mv	a0,s2
ffffffffc0201898:	0bc000ef          	jal	ra,ffffffffc0201954 <printfmt>
ffffffffc020189c:	bb41                	j	ffffffffc020162c <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020189e:	00001417          	auipc	s0,0x1
ffffffffc02018a2:	e6240413          	addi	s0,s0,-414 # ffffffffc0202700 <default_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018a6:	85e2                	mv	a1,s8
ffffffffc02018a8:	8522                	mv	a0,s0
ffffffffc02018aa:	e43e                	sd	a5,8(sp)
ffffffffc02018ac:	c79ff0ef          	jal	ra,ffffffffc0201524 <strnlen>
ffffffffc02018b0:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02018b4:	01b05b63          	blez	s11,ffffffffc02018ca <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02018b8:	67a2                	ld	a5,8(sp)
ffffffffc02018ba:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018be:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02018c0:	85a6                	mv	a1,s1
ffffffffc02018c2:	8552                	mv	a0,s4
ffffffffc02018c4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018c6:	fe0d9ce3          	bnez	s11,ffffffffc02018be <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018ca:	00044783          	lbu	a5,0(s0)
ffffffffc02018ce:	00140a13          	addi	s4,s0,1
ffffffffc02018d2:	0007851b          	sext.w	a0,a5
ffffffffc02018d6:	d3a5                	beqz	a5,ffffffffc0201836 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018d8:	05e00413          	li	s0,94
ffffffffc02018dc:	bf39                	j	ffffffffc02017fa <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02018de:	000a2403          	lw	s0,0(s4)
ffffffffc02018e2:	b7ad                	j	ffffffffc020184c <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02018e4:	000a6603          	lwu	a2,0(s4)
ffffffffc02018e8:	46a1                	li	a3,8
ffffffffc02018ea:	8a2e                	mv	s4,a1
ffffffffc02018ec:	bdb1                	j	ffffffffc0201748 <vprintfmt+0x156>
ffffffffc02018ee:	000a6603          	lwu	a2,0(s4)
ffffffffc02018f2:	46a9                	li	a3,10
ffffffffc02018f4:	8a2e                	mv	s4,a1
ffffffffc02018f6:	bd89                	j	ffffffffc0201748 <vprintfmt+0x156>
ffffffffc02018f8:	000a6603          	lwu	a2,0(s4)
ffffffffc02018fc:	46c1                	li	a3,16
ffffffffc02018fe:	8a2e                	mv	s4,a1
ffffffffc0201900:	b5a1                	j	ffffffffc0201748 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201902:	9902                	jalr	s2
ffffffffc0201904:	bf09                	j	ffffffffc0201816 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201906:	85a6                	mv	a1,s1
ffffffffc0201908:	02d00513          	li	a0,45
ffffffffc020190c:	e03e                	sd	a5,0(sp)
ffffffffc020190e:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201910:	6782                	ld	a5,0(sp)
ffffffffc0201912:	8a66                	mv	s4,s9
ffffffffc0201914:	40800633          	neg	a2,s0
ffffffffc0201918:	46a9                	li	a3,10
ffffffffc020191a:	b53d                	j	ffffffffc0201748 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020191c:	03b05163          	blez	s11,ffffffffc020193e <vprintfmt+0x34c>
ffffffffc0201920:	02d00693          	li	a3,45
ffffffffc0201924:	f6d79de3          	bne	a5,a3,ffffffffc020189e <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201928:	00001417          	auipc	s0,0x1
ffffffffc020192c:	dd840413          	addi	s0,s0,-552 # ffffffffc0202700 <default_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201930:	02800793          	li	a5,40
ffffffffc0201934:	02800513          	li	a0,40
ffffffffc0201938:	00140a13          	addi	s4,s0,1
ffffffffc020193c:	bd6d                	j	ffffffffc02017f6 <vprintfmt+0x204>
ffffffffc020193e:	00001a17          	auipc	s4,0x1
ffffffffc0201942:	dc3a0a13          	addi	s4,s4,-573 # ffffffffc0202701 <default_pmm_manager+0x51>
ffffffffc0201946:	02800513          	li	a0,40
ffffffffc020194a:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020194e:	05e00413          	li	s0,94
ffffffffc0201952:	b565                	j	ffffffffc02017fa <vprintfmt+0x208>

ffffffffc0201954 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201954:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201956:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020195a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020195c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020195e:	ec06                	sd	ra,24(sp)
ffffffffc0201960:	f83a                	sd	a4,48(sp)
ffffffffc0201962:	fc3e                	sd	a5,56(sp)
ffffffffc0201964:	e0c2                	sd	a6,64(sp)
ffffffffc0201966:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201968:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020196a:	c89ff0ef          	jal	ra,ffffffffc02015f2 <vprintfmt>
}
ffffffffc020196e:	60e2                	ld	ra,24(sp)
ffffffffc0201970:	6161                	addi	sp,sp,80
ffffffffc0201972:	8082                	ret

ffffffffc0201974 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201974:	715d                	addi	sp,sp,-80
ffffffffc0201976:	e486                	sd	ra,72(sp)
ffffffffc0201978:	e0a6                	sd	s1,64(sp)
ffffffffc020197a:	fc4a                	sd	s2,56(sp)
ffffffffc020197c:	f84e                	sd	s3,48(sp)
ffffffffc020197e:	f452                	sd	s4,40(sp)
ffffffffc0201980:	f056                	sd	s5,32(sp)
ffffffffc0201982:	ec5a                	sd	s6,24(sp)
ffffffffc0201984:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201986:	c901                	beqz	a0,ffffffffc0201996 <readline+0x22>
ffffffffc0201988:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020198a:	00001517          	auipc	a0,0x1
ffffffffc020198e:	d8e50513          	addi	a0,a0,-626 # ffffffffc0202718 <default_pmm_manager+0x68>
ffffffffc0201992:	f20fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201996:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201998:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020199a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020199c:	4aa9                	li	s5,10
ffffffffc020199e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02019a0:	00004b97          	auipc	s7,0x4
ffffffffc02019a4:	688b8b93          	addi	s7,s7,1672 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019a8:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02019ac:	f7efe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02019b0:	00054a63          	bltz	a0,ffffffffc02019c4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019b4:	00a95a63          	bge	s2,a0,ffffffffc02019c8 <readline+0x54>
ffffffffc02019b8:	029a5263          	bge	s4,s1,ffffffffc02019dc <readline+0x68>
        c = getchar();
ffffffffc02019bc:	f6efe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02019c0:	fe055ae3          	bgez	a0,ffffffffc02019b4 <readline+0x40>
            return NULL;
ffffffffc02019c4:	4501                	li	a0,0
ffffffffc02019c6:	a091                	j	ffffffffc0201a0a <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02019c8:	03351463          	bne	a0,s3,ffffffffc02019f0 <readline+0x7c>
ffffffffc02019cc:	e8a9                	bnez	s1,ffffffffc0201a1e <readline+0xaa>
        c = getchar();
ffffffffc02019ce:	f5cfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02019d2:	fe0549e3          	bltz	a0,ffffffffc02019c4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019d6:	fea959e3          	bge	s2,a0,ffffffffc02019c8 <readline+0x54>
ffffffffc02019da:	4481                	li	s1,0
            cputchar(c);
ffffffffc02019dc:	e42a                	sd	a0,8(sp)
ffffffffc02019de:	f0afe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02019e2:	6522                	ld	a0,8(sp)
ffffffffc02019e4:	009b87b3          	add	a5,s7,s1
ffffffffc02019e8:	2485                	addiw	s1,s1,1
ffffffffc02019ea:	00a78023          	sb	a0,0(a5)
ffffffffc02019ee:	bf7d                	j	ffffffffc02019ac <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02019f0:	01550463          	beq	a0,s5,ffffffffc02019f8 <readline+0x84>
ffffffffc02019f4:	fb651ce3          	bne	a0,s6,ffffffffc02019ac <readline+0x38>
            cputchar(c);
ffffffffc02019f8:	ef0fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02019fc:	00004517          	auipc	a0,0x4
ffffffffc0201a00:	62c50513          	addi	a0,a0,1580 # ffffffffc0206028 <buf>
ffffffffc0201a04:	94aa                	add	s1,s1,a0
ffffffffc0201a06:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201a0a:	60a6                	ld	ra,72(sp)
ffffffffc0201a0c:	6486                	ld	s1,64(sp)
ffffffffc0201a0e:	7962                	ld	s2,56(sp)
ffffffffc0201a10:	79c2                	ld	s3,48(sp)
ffffffffc0201a12:	7a22                	ld	s4,40(sp)
ffffffffc0201a14:	7a82                	ld	s5,32(sp)
ffffffffc0201a16:	6b62                	ld	s6,24(sp)
ffffffffc0201a18:	6bc2                	ld	s7,16(sp)
ffffffffc0201a1a:	6161                	addi	sp,sp,80
ffffffffc0201a1c:	8082                	ret
            cputchar(c);
ffffffffc0201a1e:	4521                	li	a0,8
ffffffffc0201a20:	ec8fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201a24:	34fd                	addiw	s1,s1,-1
ffffffffc0201a26:	b759                	j	ffffffffc02019ac <readline+0x38>

ffffffffc0201a28 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201a28:	4781                	li	a5,0
ffffffffc0201a2a:	00004717          	auipc	a4,0x4
ffffffffc0201a2e:	5de73703          	ld	a4,1502(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201a32:	88ba                	mv	a7,a4
ffffffffc0201a34:	852a                	mv	a0,a0
ffffffffc0201a36:	85be                	mv	a1,a5
ffffffffc0201a38:	863e                	mv	a2,a5
ffffffffc0201a3a:	00000073          	ecall
ffffffffc0201a3e:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201a40:	8082                	ret

ffffffffc0201a42 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201a42:	4781                	li	a5,0
ffffffffc0201a44:	00005717          	auipc	a4,0x5
ffffffffc0201a48:	a2473703          	ld	a4,-1500(a4) # ffffffffc0206468 <SBI_SET_TIMER>
ffffffffc0201a4c:	88ba                	mv	a7,a4
ffffffffc0201a4e:	852a                	mv	a0,a0
ffffffffc0201a50:	85be                	mv	a1,a5
ffffffffc0201a52:	863e                	mv	a2,a5
ffffffffc0201a54:	00000073          	ecall
ffffffffc0201a58:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201a5a:	8082                	ret

ffffffffc0201a5c <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201a5c:	4501                	li	a0,0
ffffffffc0201a5e:	00004797          	auipc	a5,0x4
ffffffffc0201a62:	5a27b783          	ld	a5,1442(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201a66:	88be                	mv	a7,a5
ffffffffc0201a68:	852a                	mv	a0,a0
ffffffffc0201a6a:	85aa                	mv	a1,a0
ffffffffc0201a6c:	862a                	mv	a2,a0
ffffffffc0201a6e:	00000073          	ecall
ffffffffc0201a72:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201a74:	2501                	sext.w	a0,a0
ffffffffc0201a76:	8082                	ret
