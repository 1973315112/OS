
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
<<<<<<< HEAD
ffffffffc020003e:	43e60613          	addi	a2,a2,1086 # ffffffffc0206478 <end>
=======
ffffffffc020003e:	43660613          	addi	a2,a2,1078 # ffffffffc0206470 <end>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
<<<<<<< HEAD
ffffffffc020004a:	2ba010ef          	jal	ra,ffffffffc0201304 <memset>
=======
ffffffffc020004a:	153010ef          	jal	ra,ffffffffc020199c <memset>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
    cons_init();  // 初始化命令行
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
<<<<<<< HEAD
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	7b650513          	addi	a0,a0,1974 # ffffffffc0201808 <etext>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>
    print_kerninfo();   // 打印核心信息
ffffffffc020005e:	138000ef          	jal	ra,ffffffffc0200196 <print_kerninfo>
    // grade_backtrace();
    idt_init();         // 初始化中断描述符表
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();         // 初始化物理内存管理器(本次的核心)
ffffffffc0200066:	0ba010ef          	jal	ra,ffffffffc0201120 <pmm_init>

    idt_init();         // 初始化中断描述符表
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>
    clock_init();       // 初始化时钟中断
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();      // 启用中断请求
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>
    while (1) {}    
=======
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	95e50513          	addi	a0,a0,-1698 # ffffffffc02019b0 <etext+0x2>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>
    print_kerninfo(); // 打印核心信息
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    // grade_backtrace();
    idt_init();  // 初始化中断描述符表
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // 初始化物理内存管理器(本次的核心)
ffffffffc0200066:	260010ef          	jal	ra,ffffffffc02012c6 <pmm_init>

    idt_init();  // 初始化中断描述符表
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>
    clock_init();   // 初始化时钟中断
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // 启用中断请求
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>
    while (1) {}
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
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
<<<<<<< HEAD
ffffffffc02000a6:	2dc010ef          	jal	ra,ffffffffc0201382 <vprintfmt>
=======
ffffffffc02000a6:	420010ef          	jal	ra,ffffffffc02014c6 <vprintfmt>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
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
<<<<<<< HEAD
ffffffffc02000dc:	2a6010ef          	jal	ra,ffffffffc0201382 <vprintfmt>
=======
ffffffffc02000dc:	3ea010ef          	jal	ra,ffffffffc02014c6 <vprintfmt>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
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

<<<<<<< HEAD
ffffffffc020013a <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020013a:	00006317          	auipc	t1,0x6
ffffffffc020013e:	2f630313          	addi	t1,t1,758 # ffffffffc0206430 <is_panic>
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
ffffffffc0200168:	00001517          	auipc	a0,0x1
ffffffffc020016c:	6c050513          	addi	a0,a0,1728 # ffffffffc0201828 <etext+0x20>
    va_start(ap, fmt);
ffffffffc0200170:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200172:	f41ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200176:	65a2                	ld	a1,8(sp)
ffffffffc0200178:	8522                	mv	a0,s0
ffffffffc020017a:	f19ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	79250513          	addi	a0,a0,1938 # ffffffffc0201910 <etext+0x108>
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
=======
ffffffffc020013a <print_kerninfo>:
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
<<<<<<< HEAD
ffffffffc0200196:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200198:	00001517          	auipc	a0,0x1
ffffffffc020019c:	6b050513          	addi	a0,a0,1712 # ffffffffc0201848 <etext+0x40>
void print_kerninfo(void) {
ffffffffc02001a0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001a2:	f11ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001a6:	00000597          	auipc	a1,0x0
ffffffffc02001aa:	e8c58593          	addi	a1,a1,-372 # ffffffffc0200032 <kern_init>
ffffffffc02001ae:	00001517          	auipc	a0,0x1
ffffffffc02001b2:	6ba50513          	addi	a0,a0,1722 # ffffffffc0201868 <etext+0x60>
ffffffffc02001b6:	efdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001ba:	00001597          	auipc	a1,0x1
ffffffffc02001be:	64e58593          	addi	a1,a1,1614 # ffffffffc0201808 <etext>
ffffffffc02001c2:	00001517          	auipc	a0,0x1
ffffffffc02001c6:	6c650513          	addi	a0,a0,1734 # ffffffffc0201888 <etext+0x80>
ffffffffc02001ca:	ee9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001ce:	00006597          	auipc	a1,0x6
ffffffffc02001d2:	e4258593          	addi	a1,a1,-446 # ffffffffc0206010 <free_area>
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	6d250513          	addi	a0,a0,1746 # ffffffffc02018a8 <etext+0xa0>
ffffffffc02001de:	ed5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001e2:	00006597          	auipc	a1,0x6
ffffffffc02001e6:	29658593          	addi	a1,a1,662 # ffffffffc0206478 <end>
ffffffffc02001ea:	00001517          	auipc	a0,0x1
ffffffffc02001ee:	6de50513          	addi	a0,a0,1758 # ffffffffc02018c8 <etext+0xc0>
ffffffffc02001f2:	ec1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001f6:	00006597          	auipc	a1,0x6
ffffffffc02001fa:	68158593          	addi	a1,a1,1665 # ffffffffc0206877 <end+0x3ff>
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
ffffffffc0200218:	00001517          	auipc	a0,0x1
ffffffffc020021c:	6d050513          	addi	a0,a0,1744 # ffffffffc02018e8 <etext+0xe0>
}
ffffffffc0200220:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200222:	bd41                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200224 <print_stackframe>:
=======
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00002517          	auipc	a0,0x2
ffffffffc0200140:	89450513          	addi	a0,a0,-1900 # ffffffffc02019d0 <etext+0x22>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00002517          	auipc	a0,0x2
ffffffffc0200156:	89e50513          	addi	a0,a0,-1890 # ffffffffc02019f0 <etext+0x42>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00002597          	auipc	a1,0x2
ffffffffc0200162:	85058593          	addi	a1,a1,-1968 # ffffffffc02019ae <etext>
ffffffffc0200166:	00002517          	auipc	a0,0x2
ffffffffc020016a:	8aa50513          	addi	a0,a0,-1878 # ffffffffc0201a10 <etext+0x62>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <free_area>
ffffffffc020017a:	00002517          	auipc	a0,0x2
ffffffffc020017e:	8b650513          	addi	a0,a0,-1866 # ffffffffc0201a30 <etext+0x82>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2ea58593          	addi	a1,a1,746 # ffffffffc0206470 <end>
ffffffffc020018e:	00002517          	auipc	a0,0x2
ffffffffc0200192:	8c250513          	addi	a0,a0,-1854 # ffffffffc0201a50 <etext+0xa2>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6d558593          	addi	a1,a1,1749 # ffffffffc020686f <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00002517          	auipc	a0,0x2
ffffffffc02001c0:	8b450513          	addi	a0,a0,-1868 # ffffffffc0201a70 <etext+0xc2>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
<<<<<<< HEAD
ffffffffc0200224:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200226:	00001617          	auipc	a2,0x1
ffffffffc020022a:	6f260613          	addi	a2,a2,1778 # ffffffffc0201918 <etext+0x110>
ffffffffc020022e:	04e00593          	li	a1,78
ffffffffc0200232:	00001517          	auipc	a0,0x1
ffffffffc0200236:	6fe50513          	addi	a0,a0,1790 # ffffffffc0201930 <etext+0x128>
void print_stackframe(void) {
ffffffffc020023a:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020023c:	effff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200240 <mon_help>:
=======
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00002617          	auipc	a2,0x2
ffffffffc02001ce:	8d660613          	addi	a2,a2,-1834 # ffffffffc0201aa0 <etext+0xf2>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	8e250513          	addi	a0,a0,-1822 # ffffffffc0201ab8 <etext+0x10a>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
<<<<<<< HEAD
ffffffffc0200240:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200242:	00001617          	auipc	a2,0x1
ffffffffc0200246:	70660613          	addi	a2,a2,1798 # ffffffffc0201948 <etext+0x140>
ffffffffc020024a:	00001597          	auipc	a1,0x1
ffffffffc020024e:	71e58593          	addi	a1,a1,1822 # ffffffffc0201968 <etext+0x160>
ffffffffc0200252:	00001517          	auipc	a0,0x1
ffffffffc0200256:	71e50513          	addi	a0,a0,1822 # ffffffffc0201970 <etext+0x168>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020025c:	e57ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200260:	00001617          	auipc	a2,0x1
ffffffffc0200264:	72060613          	addi	a2,a2,1824 # ffffffffc0201980 <etext+0x178>
ffffffffc0200268:	00001597          	auipc	a1,0x1
ffffffffc020026c:	74058593          	addi	a1,a1,1856 # ffffffffc02019a8 <etext+0x1a0>
ffffffffc0200270:	00001517          	auipc	a0,0x1
ffffffffc0200274:	70050513          	addi	a0,a0,1792 # ffffffffc0201970 <etext+0x168>
ffffffffc0200278:	e3bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020027c:	00001617          	auipc	a2,0x1
ffffffffc0200280:	73c60613          	addi	a2,a2,1852 # ffffffffc02019b8 <etext+0x1b0>
ffffffffc0200284:	00001597          	auipc	a1,0x1
ffffffffc0200288:	75458593          	addi	a1,a1,1876 # ffffffffc02019d8 <etext+0x1d0>
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	6e450513          	addi	a0,a0,1764 # ffffffffc0201970 <etext+0x168>
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
ffffffffc02002c6:	00001517          	auipc	a0,0x1
ffffffffc02002ca:	72250513          	addi	a0,a0,1826 # ffffffffc02019e8 <etext+0x1e0>
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
ffffffffc02002e8:	00001517          	auipc	a0,0x1
ffffffffc02002ec:	72850513          	addi	a0,a0,1832 # ffffffffc0201a10 <etext+0x208>
ffffffffc02002f0:	dc3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc02002f4:	000b8563          	beqz	s7,ffffffffc02002fe <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002f8:	855e                	mv	a0,s7
ffffffffc02002fa:	348000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002fe:	00001c17          	auipc	s8,0x1
ffffffffc0200302:	782c0c13          	addi	s8,s8,1922 # ffffffffc0201a80 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200306:	00001917          	auipc	s2,0x1
ffffffffc020030a:	73290913          	addi	s2,s2,1842 # ffffffffc0201a38 <etext+0x230>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030e:	00001497          	auipc	s1,0x1
ffffffffc0200312:	73248493          	addi	s1,s1,1842 # ffffffffc0201a40 <etext+0x238>
        if (argc == MAXARGS - 1) {
ffffffffc0200316:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200318:	00001b17          	auipc	s6,0x1
ffffffffc020031c:	730b0b13          	addi	s6,s6,1840 # ffffffffc0201a48 <etext+0x240>
        argv[argc ++] = buf;
ffffffffc0200320:	00001a17          	auipc	s4,0x1
ffffffffc0200324:	648a0a13          	addi	s4,s4,1608 # ffffffffc0201968 <etext+0x160>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200328:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020032a:	854a                	mv	a0,s2
ffffffffc020032c:	3d8010ef          	jal	ra,ffffffffc0201704 <readline>
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
ffffffffc0200342:	00001d17          	auipc	s10,0x1
ffffffffc0200346:	73ed0d13          	addi	s10,s10,1854 # ffffffffc0201a80 <commands>
        argv[argc ++] = buf;
ffffffffc020034a:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020034c:	4401                	li	s0,0
ffffffffc020034e:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200350:	781000ef          	jal	ra,ffffffffc02012d0 <strcmp>
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
ffffffffc0200364:	76d000ef          	jal	ra,ffffffffc02012d0 <strcmp>
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
ffffffffc02003a2:	74d000ef          	jal	ra,ffffffffc02012ee <strchr>
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
ffffffffc02003e0:	70f000ef          	jal	ra,ffffffffc02012ee <strchr>
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
ffffffffc02003fa:	00001517          	auipc	a0,0x1
ffffffffc02003fe:	66e50513          	addi	a0,a0,1646 # ffffffffc0201a68 <etext+0x260>
ffffffffc0200402:	cb1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc0200406:	b715                	j	ffffffffc020032a <kmonitor+0x6a>
=======
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00002617          	auipc	a2,0x2
ffffffffc02001ea:	8ea60613          	addi	a2,a2,-1814 # ffffffffc0201ad0 <etext+0x122>
ffffffffc02001ee:	00002597          	auipc	a1,0x2
ffffffffc02001f2:	90258593          	addi	a1,a1,-1790 # ffffffffc0201af0 <etext+0x142>
ffffffffc02001f6:	00002517          	auipc	a0,0x2
ffffffffc02001fa:	90250513          	addi	a0,a0,-1790 # ffffffffc0201af8 <etext+0x14a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00002617          	auipc	a2,0x2
ffffffffc0200208:	90460613          	addi	a2,a2,-1788 # ffffffffc0201b08 <etext+0x15a>
ffffffffc020020c:	00002597          	auipc	a1,0x2
ffffffffc0200210:	92458593          	addi	a1,a1,-1756 # ffffffffc0201b30 <etext+0x182>
ffffffffc0200214:	00002517          	auipc	a0,0x2
ffffffffc0200218:	8e450513          	addi	a0,a0,-1820 # ffffffffc0201af8 <etext+0x14a>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00002617          	auipc	a2,0x2
ffffffffc0200224:	92060613          	addi	a2,a2,-1760 # ffffffffc0201b40 <etext+0x192>
ffffffffc0200228:	00002597          	auipc	a1,0x2
ffffffffc020022c:	93858593          	addi	a1,a1,-1736 # ffffffffc0201b60 <etext+0x1b2>
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	8c850513          	addi	a0,a0,-1848 # ffffffffc0201af8 <etext+0x14a>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00002517          	auipc	a0,0x2
ffffffffc020026e:	90650513          	addi	a0,a0,-1786 # ffffffffc0201b70 <etext+0x1c2>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00002517          	auipc	a0,0x2
ffffffffc0200290:	90c50513          	addi	a0,a0,-1780 # ffffffffc0201b98 <etext+0x1ea>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00002c17          	auipc	s8,0x2
ffffffffc02002a6:	966c0c13          	addi	s8,s8,-1690 # ffffffffc0201c08 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00002917          	auipc	s2,0x2
ffffffffc02002ae:	91690913          	addi	s2,s2,-1770 # ffffffffc0201bc0 <etext+0x212>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00002497          	auipc	s1,0x2
ffffffffc02002b6:	91648493          	addi	s1,s1,-1770 # ffffffffc0201bc8 <etext+0x21a>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00002b17          	auipc	s6,0x2
ffffffffc02002c0:	914b0b13          	addi	s6,s6,-1772 # ffffffffc0201bd0 <etext+0x222>
        argv[argc ++] = buf;
ffffffffc02002c4:	00002a17          	auipc	s4,0x2
ffffffffc02002c8:	82ca0a13          	addi	s4,s4,-2004 # ffffffffc0201af0 <etext+0x142>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	578010ef          	jal	ra,ffffffffc0201848 <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00002d17          	auipc	s10,0x2
ffffffffc02002ea:	922d0d13          	addi	s10,s10,-1758 # ffffffffc0201c08 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	674010ef          	jal	ra,ffffffffc0201968 <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	660010ef          	jal	ra,ffffffffc0201968 <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	640010ef          	jal	ra,ffffffffc0201986 <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	602010ef          	jal	ra,ffffffffc0201986 <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	85250513          	addi	a0,a0,-1966 # ffffffffc0201bf0 <etext+0x242>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	07c30313          	addi	t1,t1,124 # ffffffffc0206428 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00002517          	auipc	a0,0x2
ffffffffc02003de:	87650513          	addi	a0,a0,-1930 # ffffffffc0201c50 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	6a850513          	addi	a0,a0,1704 # ffffffffc0201a98 <etext+0xea>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029

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
<<<<<<< HEAD
ffffffffc0200420:	3b2010ef          	jal	ra,ffffffffc02017d2 <sbi_set_timer>
=======
ffffffffc0200420:	4f6010ef          	jal	ra,ffffffffc0201916 <sbi_set_timer>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
<<<<<<< HEAD
ffffffffc020042a:	0007b923          	sd	zero,18(a5) # ffffffffc0206438 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	69a50513          	addi	a0,a0,1690 # ffffffffc0201ac8 <commands+0x48>
=======
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	84250513          	addi	a0,a0,-1982 # ffffffffc0201c70 <commands+0x68>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
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
<<<<<<< HEAD
ffffffffc0200446:	38c0106f          	j	ffffffffc02017d2 <sbi_set_timer>
=======
ffffffffc0200446:	4d00106f          	j	ffffffffc0201916 <sbi_set_timer>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029

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
<<<<<<< HEAD
ffffffffc0200450:	3680106f          	j	ffffffffc02017b8 <sbi_console_putchar>
=======
ffffffffc0200450:	4ac0106f          	j	ffffffffc02018fc <sbi_console_putchar>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
<<<<<<< HEAD
ffffffffc0200454:	3980106f          	j	ffffffffc02017ec <sbi_console_getchar>
=======
ffffffffc0200454:	4dc0106f          	j	ffffffffc0201930 <sbi_console_getchar>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029

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
<<<<<<< HEAD
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	66a50513          	addi	a0,a0,1642 # ffffffffc0201ae8 <commands+0x68>
=======
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	81250513          	addi	a0,a0,-2030 # ffffffffc0201c90 <commands+0x88>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
<<<<<<< HEAD
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	67250513          	addi	a0,a0,1650 # ffffffffc0201b00 <commands+0x80>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	67c50513          	addi	a0,a0,1660 # ffffffffc0201b18 <commands+0x98>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	68650513          	addi	a0,a0,1670 # ffffffffc0201b30 <commands+0xb0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	69050513          	addi	a0,a0,1680 # ffffffffc0201b48 <commands+0xc8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	69a50513          	addi	a0,a0,1690 # ffffffffc0201b60 <commands+0xe0>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	6a450513          	addi	a0,a0,1700 # ffffffffc0201b78 <commands+0xf8>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	6ae50513          	addi	a0,a0,1710 # ffffffffc0201b90 <commands+0x110>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	6b850513          	addi	a0,a0,1720 # ffffffffc0201ba8 <commands+0x128>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	6c250513          	addi	a0,a0,1730 # ffffffffc0201bc0 <commands+0x140>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	6cc50513          	addi	a0,a0,1740 # ffffffffc0201bd8 <commands+0x158>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	6d650513          	addi	a0,a0,1750 # ffffffffc0201bf0 <commands+0x170>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	6e050513          	addi	a0,a0,1760 # ffffffffc0201c08 <commands+0x188>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	6ea50513          	addi	a0,a0,1770 # ffffffffc0201c20 <commands+0x1a0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	6f450513          	addi	a0,a0,1780 # ffffffffc0201c38 <commands+0x1b8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	6fe50513          	addi	a0,a0,1790 # ffffffffc0201c50 <commands+0x1d0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	70850513          	addi	a0,a0,1800 # ffffffffc0201c68 <commands+0x1e8>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	71250513          	addi	a0,a0,1810 # ffffffffc0201c80 <commands+0x200>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	71c50513          	addi	a0,a0,1820 # ffffffffc0201c98 <commands+0x218>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	72650513          	addi	a0,a0,1830 # ffffffffc0201cb0 <commands+0x230>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	73050513          	addi	a0,a0,1840 # ffffffffc0201cc8 <commands+0x248>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	73a50513          	addi	a0,a0,1850 # ffffffffc0201ce0 <commands+0x260>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	74450513          	addi	a0,a0,1860 # ffffffffc0201cf8 <commands+0x278>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	74e50513          	addi	a0,a0,1870 # ffffffffc0201d10 <commands+0x290>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	75850513          	addi	a0,a0,1880 # ffffffffc0201d28 <commands+0x2a8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	76250513          	addi	a0,a0,1890 # ffffffffc0201d40 <commands+0x2c0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	76c50513          	addi	a0,a0,1900 # ffffffffc0201d58 <commands+0x2d8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	77650513          	addi	a0,a0,1910 # ffffffffc0201d70 <commands+0x2f0>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	78050513          	addi	a0,a0,1920 # ffffffffc0201d88 <commands+0x308>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	78a50513          	addi	a0,a0,1930 # ffffffffc0201da0 <commands+0x320>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	79450513          	addi	a0,a0,1940 # ffffffffc0201db8 <commands+0x338>
=======
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	81a50513          	addi	a0,a0,-2022 # ffffffffc0201ca8 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	82450513          	addi	a0,a0,-2012 # ffffffffc0201cc0 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	82e50513          	addi	a0,a0,-2002 # ffffffffc0201cd8 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	83850513          	addi	a0,a0,-1992 # ffffffffc0201cf0 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	84250513          	addi	a0,a0,-1982 # ffffffffc0201d08 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	84c50513          	addi	a0,a0,-1972 # ffffffffc0201d20 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	85650513          	addi	a0,a0,-1962 # ffffffffc0201d38 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	86050513          	addi	a0,a0,-1952 # ffffffffc0201d50 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	86a50513          	addi	a0,a0,-1942 # ffffffffc0201d68 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	87450513          	addi	a0,a0,-1932 # ffffffffc0201d80 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	87e50513          	addi	a0,a0,-1922 # ffffffffc0201d98 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	88850513          	addi	a0,a0,-1912 # ffffffffc0201db0 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	89250513          	addi	a0,a0,-1902 # ffffffffc0201dc8 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	89c50513          	addi	a0,a0,-1892 # ffffffffc0201de0 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	8a650513          	addi	a0,a0,-1882 # ffffffffc0201df8 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	8b050513          	addi	a0,a0,-1872 # ffffffffc0201e10 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0201e28 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	8c450513          	addi	a0,a0,-1852 # ffffffffc0201e40 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0201e58 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	8d850513          	addi	a0,a0,-1832 # ffffffffc0201e70 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	8e250513          	addi	a0,a0,-1822 # ffffffffc0201e88 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0201ea0 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	8f650513          	addi	a0,a0,-1802 # ffffffffc0201eb8 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	90050513          	addi	a0,a0,-1792 # ffffffffc0201ed0 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	90a50513          	addi	a0,a0,-1782 # ffffffffc0201ee8 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	91450513          	addi	a0,a0,-1772 # ffffffffc0201f00 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	91e50513          	addi	a0,a0,-1762 # ffffffffc0201f18 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	92850513          	addi	a0,a0,-1752 # ffffffffc0201f30 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	93250513          	addi	a0,a0,-1742 # ffffffffc0201f48 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	93c50513          	addi	a0,a0,-1732 # ffffffffc0201f60 <commands+0x358>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
<<<<<<< HEAD
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	79a50513          	addi	a0,a0,1946 # ffffffffc0201dd0 <commands+0x350>
=======
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	94250513          	addi	a0,a0,-1726 # ffffffffc0201f78 <commands+0x370>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
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
<<<<<<< HEAD
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	79e50513          	addi	a0,a0,1950 # ffffffffc0201de8 <commands+0x368>
=======
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	94650513          	addi	a0,a0,-1722 # ffffffffc0201f90 <commands+0x388>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
<<<<<<< HEAD
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	79e50513          	addi	a0,a0,1950 # ffffffffc0201e00 <commands+0x380>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	7a650513          	addi	a0,a0,1958 # ffffffffc0201e18 <commands+0x398>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	7ae50513          	addi	a0,a0,1966 # ffffffffc0201e30 <commands+0x3b0>
=======
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	94650513          	addi	a0,a0,-1722 # ffffffffc0201fa8 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	94e50513          	addi	a0,a0,-1714 # ffffffffc0201fc0 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	95650513          	addi	a0,a0,-1706 # ffffffffc0201fd8 <commands+0x3d0>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
<<<<<<< HEAD
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	7b250513          	addi	a0,a0,1970 # ffffffffc0201e48 <commands+0x3c8>
=======
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	95a50513          	addi	a0,a0,-1702 # ffffffffc0201ff0 <commands+0x3e8>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
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
<<<<<<< HEAD
ffffffffc02006b4:	87870713          	addi	a4,a4,-1928 # ffffffffc0201f28 <commands+0x4a8>
=======
ffffffffc02006b4:	a2070713          	addi	a4,a4,-1504 # ffffffffc02020d0 <commands+0x4c8>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
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
<<<<<<< HEAD
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	7fe50513          	addi	a0,a0,2046 # ffffffffc0201ec0 <commands+0x440>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	7d450513          	addi	a0,a0,2004 # ffffffffc0201ea0 <commands+0x420>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	78a50513          	addi	a0,a0,1930 # ffffffffc0201e60 <commands+0x3e0>
=======
ffffffffc02006c2:	00002517          	auipc	a0,0x2
ffffffffc02006c6:	9a650513          	addi	a0,a0,-1626 # ffffffffc0202068 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	97c50513          	addi	a0,a0,-1668 # ffffffffc0202048 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	93250513          	addi	a0,a0,-1742 # ffffffffc0202008 <commands+0x400>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
<<<<<<< HEAD
ffffffffc02006e4:	80050513          	addi	a0,a0,-2048 # ffffffffc0201ee0 <commands+0x460>
=======
ffffffffc02006e4:	9a850513          	addi	a0,a0,-1624 # ffffffffc0202088 <commands+0x480>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
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
ffffffffc02006f6:	d4668693          	addi	a3,a3,-698 # ffffffffc0206438 <ticks>
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
<<<<<<< HEAD
ffffffffc0200710:	00001517          	auipc	a0,0x1
ffffffffc0200714:	7f850513          	addi	a0,a0,2040 # ffffffffc0201f08 <commands+0x488>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	76650513          	addi	a0,a0,1894 # ffffffffc0201e80 <commands+0x400>
=======
ffffffffc0200710:	00002517          	auipc	a0,0x2
ffffffffc0200714:	9a050513          	addi	a0,a0,-1632 # ffffffffc02020b0 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	90e50513          	addi	a0,a0,-1778 # ffffffffc0202028 <commands+0x420>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
<<<<<<< HEAD
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	7cc50513          	addi	a0,a0,1996 # ffffffffc0201ef8 <commands+0x478>
=======
ffffffffc020072c:	00002517          	auipc	a0,0x2
ffffffffc0200730:	97450513          	addi	a0,a0,-1676 # ffffffffc02020a0 <commands+0x498>
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
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

<<<<<<< HEAD
ffffffffc0200802 <buddy_system_init>:
 * 功能:初始化free_area(清空性质)
 */
static void buddy_system_init(void) 
{
    //cprintf("调试信息:进入buddy_system_init()\n");
    Base = NULL;
ffffffffc0200802:	00006797          	auipc	a5,0x6
ffffffffc0200806:	80e78793          	addi	a5,a5,-2034 # ffffffffc0206010 <free_area>
ffffffffc020080a:	0007b023          	sd	zero,0(a5)
    free_tree= NULL ;
ffffffffc020080e:	0007b423          	sd	zero,8(a5)
    nr_free = 0;
ffffffffc0200812:	0007a823          	sw	zero,16(a5)
    max_size = 0;   
ffffffffc0200816:	0007ac23          	sw	zero,24(a5)
}
ffffffffc020081a:	8082                	ret

ffffffffc020081c <buddy_system_nr_free_pages>:
 * 注意:该函数返回值代表总共的可用可用物理页数，不代表可以申请连续的这么多
 */
static size_t buddy_system_nr_free_pages(void) 
{
    return nr_free;
}
ffffffffc020081c:	00006517          	auipc	a0,0x6
ffffffffc0200820:	80456503          	lwu	a0,-2044(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc0200824:	8082                	ret

ffffffffc0200826 <up_to_2_power>:
    assert(n > 0);
ffffffffc0200826:	c515                	beqz	a0,ffffffffc0200852 <up_to_2_power+0x2c>
    n--; 
ffffffffc0200828:	157d                	addi	a0,a0,-1
    n |= n >> 1;  
ffffffffc020082a:	00155793          	srli	a5,a0,0x1
ffffffffc020082e:	8d5d                	or	a0,a0,a5
    n |= n >> 2;  
ffffffffc0200830:	00255793          	srli	a5,a0,0x2
ffffffffc0200834:	8d5d                	or	a0,a0,a5
    n |= n >> 4;  
ffffffffc0200836:	00455793          	srli	a5,a0,0x4
ffffffffc020083a:	8fc9                	or	a5,a5,a0
    n |= n >> 8;  
ffffffffc020083c:	0087d513          	srli	a0,a5,0x8
ffffffffc0200840:	8fc9                	or	a5,a5,a0
    n |= n >> 16;
ffffffffc0200842:	0107d513          	srli	a0,a5,0x10
ffffffffc0200846:	8d5d                	or	a0,a0,a5
    n |= n >> 32;  
ffffffffc0200848:	02055793          	srli	a5,a0,0x20
ffffffffc020084c:	8d5d                	or	a0,a0,a5
}
ffffffffc020084e:	0505                	addi	a0,a0,1
ffffffffc0200850:	8082                	ret
{
ffffffffc0200852:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200854:	00001697          	auipc	a3,0x1
ffffffffc0200858:	70468693          	addi	a3,a3,1796 # ffffffffc0201f58 <commands+0x4d8>
ffffffffc020085c:	00001617          	auipc	a2,0x1
ffffffffc0200860:	70460613          	addi	a2,a2,1796 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc0200864:	04200593          	li	a1,66
ffffffffc0200868:	00001517          	auipc	a0,0x1
ffffffffc020086c:	71050513          	addi	a0,a0,1808 # ffffffffc0201f78 <commands+0x4f8>
{
ffffffffc0200870:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200872:	8c9ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200876 <buddy_system_free_pages>:
{
ffffffffc0200876:	1141                	addi	sp,sp,-16
ffffffffc0200878:	e406                	sd	ra,8(sp)
ffffffffc020087a:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc020087c:	12058863          	beqz	a1,ffffffffc02009ac <buddy_system_free_pages+0x136>
ffffffffc0200880:	842a                	mv	s0,a0
    n = up_to_2_power(n);
ffffffffc0200882:	852e                	mv	a0,a1
ffffffffc0200884:	fa3ff0ef          	jal	ra,ffffffffc0200826 <up_to_2_power>
    for (; p != base + n; p ++) 
ffffffffc0200888:	00251693          	slli	a3,a0,0x2
ffffffffc020088c:	96aa                	add	a3,a3,a0
ffffffffc020088e:	068e                	slli	a3,a3,0x3
ffffffffc0200890:	96a2                	add	a3,a3,s0
ffffffffc0200892:	87a2                	mv	a5,s0
ffffffffc0200894:	02d40063          	beq	s0,a3,ffffffffc02008b4 <buddy_system_free_pages+0x3e>
 * 功能:返回某个二进制位的值 
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200898:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020089a:	8b05                	andi	a4,a4,1
ffffffffc020089c:	eb65                	bnez	a4,ffffffffc020098c <buddy_system_free_pages+0x116>
ffffffffc020089e:	6798                	ld	a4,8(a5)
ffffffffc02008a0:	8b09                	andi	a4,a4,2
ffffffffc02008a2:	e76d                	bnez	a4,ffffffffc020098c <buddy_system_free_pages+0x116>
        p->flags = 0;
ffffffffc02008a4:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02008a8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) 
ffffffffc02008ac:	02878793          	addi	a5,a5,40
ffffffffc02008b0:	fed794e3          	bne	a5,a3,ffffffffc0200898 <buddy_system_free_pages+0x22>
    nr_free += n;
ffffffffc02008b4:	00005897          	auipc	a7,0x5
ffffffffc02008b8:	75c88893          	addi	a7,a7,1884 # ffffffffc0206010 <free_area>
    size_t offset = base-Base;
ffffffffc02008bc:	0008b783          	ld	a5,0(a7)
ffffffffc02008c0:	00002717          	auipc	a4,0x2
ffffffffc02008c4:	c9873703          	ld	a4,-872(a4) # ffffffffc0202558 <error_string+0x38>
    size_t i = (offset+max_size)/n-1;
ffffffffc02008c8:	0188e603          	lwu	a2,24(a7)
    size_t offset = base-Base;
ffffffffc02008cc:	40f407b3          	sub	a5,s0,a5
ffffffffc02008d0:	878d                	srai	a5,a5,0x3
ffffffffc02008d2:	02e787b3          	mul	a5,a5,a4
    nr_free += n;
ffffffffc02008d6:	0108a683          	lw	a3,16(a7)
    free_tree[i]= n;
ffffffffc02008da:	0088b703          	ld	a4,8(a7)
    nr_free += n;
ffffffffc02008de:	9ea9                	addw	a3,a3,a0
ffffffffc02008e0:	00d8a823          	sw	a3,16(a7)
    size_t i = (offset+max_size)/n-1;
ffffffffc02008e4:	97b2                	add	a5,a5,a2
ffffffffc02008e6:	02a7d7b3          	divu	a5,a5,a0
ffffffffc02008ea:	17fd                	addi	a5,a5,-1
    free_tree[i]= n;
ffffffffc02008ec:	00379693          	slli	a3,a5,0x3
ffffffffc02008f0:	9736                	add	a4,a4,a3
ffffffffc02008f2:	e308                	sd	a0,0(a4)
    base->property = n;
ffffffffc02008f4:	c808                	sw	a0,16(s0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02008f6:	4709                	li	a4,2
ffffffffc02008f8:	00840693          	addi	a3,s0,8
ffffffffc02008fc:	40e6b02f          	amoor.d	zero,a4,(a3)
ffffffffc0200900:	4e09                	li	t3,2
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200902:	5375                	li	t1,-3
    while(i!=0)
ffffffffc0200904:	cb8d                	beqz	a5,ffffffffc0200936 <buddy_system_free_pages+0xc0>
        if( free_tree[(i<<1)+1]==size && free_tree[(i<<1)+2]==size ) //如果当前节点的左右子节点对应的内存块均完整，则合并它们
ffffffffc0200906:	0088b603          	ld	a2,8(a7)
        i = (i-1)>>1;
ffffffffc020090a:	17fd                	addi	a5,a5,-1
ffffffffc020090c:	8385                	srli	a5,a5,0x1
        if( free_tree[(i<<1)+1]==size && free_tree[(i<<1)+2]==size ) //如果当前节点的左右子节点对应的内存块均完整，则合并它们
ffffffffc020090e:	00479693          	slli	a3,a5,0x4
ffffffffc0200912:	96b2                	add	a3,a3,a2
ffffffffc0200914:	6698                	ld	a4,8(a3)
            free_tree[i] = 2*size;
ffffffffc0200916:	00379593          	slli	a1,a5,0x3
        if( free_tree[(i<<1)+1]==size && free_tree[(i<<1)+2]==size ) //如果当前节点的左右子节点对应的内存块均完整，则合并它们
ffffffffc020091a:	6a94                	ld	a3,16(a3)
ffffffffc020091c:	00178813          	addi	a6,a5,1
            free_tree[i] = 2*size;
ffffffffc0200920:	962e                	add	a2,a2,a1
        if( free_tree[(i<<1)+1]==size && free_tree[(i<<1)+2]==size ) //如果当前节点的左右子节点对应的内存块均完整，则合并它们
ffffffffc0200922:	00a70e63          	beq	a4,a0,ffffffffc020093e <buddy_system_free_pages+0xc8>
        else free_tree[i]=max(free_tree[(i<<1)+1],free_tree[(i<<1)+2]);
ffffffffc0200926:	00d77363          	bgeu	a4,a3,ffffffffc020092c <buddy_system_free_pages+0xb6>
ffffffffc020092a:	8736                	mv	a4,a3
ffffffffc020092c:	e218                	sd	a4,0(a2)
ffffffffc020092e:	00151713          	slli	a4,a0,0x1
        size = size<<1;
ffffffffc0200932:	853a                	mv	a0,a4
    while(i!=0)
ffffffffc0200934:	fbe9                	bnez	a5,ffffffffc0200906 <buddy_system_free_pages+0x90>
}
ffffffffc0200936:	60a2                	ld	ra,8(sp)
ffffffffc0200938:	6402                	ld	s0,0(sp)
ffffffffc020093a:	0141                	addi	sp,sp,16
ffffffffc020093c:	8082                	ret
        if( free_tree[(i<<1)+1]==size && free_tree[(i<<1)+2]==size ) //如果当前节点的左右子节点对应的内存块均完整，则合并它们
ffffffffc020093e:	fed514e3          	bne	a0,a3,ffffffffc0200926 <buddy_system_free_pages+0xb0>
            offset = 2*size*(i+1)-max_size;
ffffffffc0200942:	030506b3          	mul	a3,a0,a6
ffffffffc0200946:	0188ee83          	lwu	t4,24(a7)
            struct Page* Right = Left+size;
ffffffffc020094a:	00251593          	slli	a1,a0,0x2
            free_tree[i] = 2*size;
ffffffffc020094e:	00151713          	slli	a4,a0,0x1
            struct Page* Right = Left+size;
ffffffffc0200952:	95aa                	add	a1,a1,a0
            free_tree[i] = 2*size;
ffffffffc0200954:	e218                	sd	a4,0(a2)
            struct Page* Left  = Base+offset;
ffffffffc0200956:	0008b803          	ld	a6,0(a7)
            struct Page* Right = Left+size;
ffffffffc020095a:	00359613          	slli	a2,a1,0x3
            Left->property  = 2*size;
ffffffffc020095e:	0015151b          	slliw	a0,a0,0x1
            offset = 2*size*(i+1)-max_size;
ffffffffc0200962:	0686                	slli	a3,a3,0x1
ffffffffc0200964:	41d686b3          	sub	a3,a3,t4
            struct Page* Left  = Base+offset;
ffffffffc0200968:	00269593          	slli	a1,a3,0x2
ffffffffc020096c:	95b6                	add	a1,a1,a3
ffffffffc020096e:	058e                	slli	a1,a1,0x3
ffffffffc0200970:	95c2                	add	a1,a1,a6
            struct Page* Right = Left+size;
ffffffffc0200972:	00c586b3          	add	a3,a1,a2
            Left->property  = 2*size;
ffffffffc0200976:	c988                	sw	a0,16(a1)
            Right->property = 0;
ffffffffc0200978:	0006a823          	sw	zero,16(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020097c:	00858613          	addi	a2,a1,8
ffffffffc0200980:	41c6302f          	amoor.d	zero,t3,(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200984:	06a1                	addi	a3,a3,8
ffffffffc0200986:	6066b02f          	amoand.d	zero,t1,(a3)
}
ffffffffc020098a:	b765                	j	ffffffffc0200932 <buddy_system_free_pages+0xbc>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020098c:	00001697          	auipc	a3,0x1
ffffffffc0200990:	60c68693          	addi	a3,a3,1548 # ffffffffc0201f98 <commands+0x518>
ffffffffc0200994:	00001617          	auipc	a2,0x1
ffffffffc0200998:	5cc60613          	addi	a2,a2,1484 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc020099c:	0d600593          	li	a1,214
ffffffffc02009a0:	00001517          	auipc	a0,0x1
ffffffffc02009a4:	5d850513          	addi	a0,a0,1496 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc02009a8:	f92ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(n > 0);
ffffffffc02009ac:	00001697          	auipc	a3,0x1
ffffffffc02009b0:	5ac68693          	addi	a3,a3,1452 # ffffffffc0201f58 <commands+0x4d8>
ffffffffc02009b4:	00001617          	auipc	a2,0x1
ffffffffc02009b8:	5ac60613          	addi	a2,a2,1452 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc02009bc:	0cf00593          	li	a1,207
ffffffffc02009c0:	00001517          	auipc	a0,0x1
ffffffffc02009c4:	5b850513          	addi	a0,a0,1464 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc02009c8:	f72ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc02009cc <buddy_system_alloc_pages>:
{
ffffffffc02009cc:	1101                	addi	sp,sp,-32
ffffffffc02009ce:	ec06                	sd	ra,24(sp)
ffffffffc02009d0:	e822                	sd	s0,16(sp)
ffffffffc02009d2:	e426                	sd	s1,8(sp)
ffffffffc02009d4:	e04a                	sd	s2,0(sp)
    assert(n > 0);
ffffffffc02009d6:	12050a63          	beqz	a0,ffffffffc0200b0a <buddy_system_alloc_pages+0x13e>
    if (n > nr_free)  return NULL;
ffffffffc02009da:	00005417          	auipc	s0,0x5
ffffffffc02009de:	63640413          	addi	s0,s0,1590 # ffffffffc0206010 <free_area>
ffffffffc02009e2:	01042903          	lw	s2,16(s0)
ffffffffc02009e6:	4481                	li	s1,0
ffffffffc02009e8:	02091713          	slli	a4,s2,0x20
ffffffffc02009ec:	9301                	srli	a4,a4,0x20
ffffffffc02009ee:	04a76b63          	bltu	a4,a0,ffffffffc0200a44 <buddy_system_alloc_pages+0x78>
    n = up_to_2_power(n);
ffffffffc02009f2:	e35ff0ef          	jal	ra,ffffffffc0200826 <up_to_2_power>
    if( n>free_tree[0] ) return NULL;
ffffffffc02009f6:	6410                	ld	a2,8(s0)
ffffffffc02009f8:	621c                	ld	a5,0(a2)
ffffffffc02009fa:	04a7e563          	bltu	a5,a0,ffffffffc0200a44 <buddy_system_alloc_pages+0x78>
    size_t i = 0,size = max_size,offset = 0;
ffffffffc02009fe:	4781                	li	a5,0
    while (free_tree[(i<<1)+1]>=n || free_tree[(i<<1)+2]>=n)
ffffffffc0200a00:	00479713          	slli	a4,a5,0x4
ffffffffc0200a04:	9732                	add	a4,a4,a2
    size_t i = 0,size = max_size,offset = 0;
ffffffffc0200a06:	01846583          	lwu	a1,24(s0)
    while (free_tree[(i<<1)+1]>=n || free_tree[(i<<1)+2]>=n)
ffffffffc0200a0a:	6714                	ld	a3,8(a4)
    nr_free -= n;
ffffffffc0200a0c:	40a9093b          	subw	s2,s2,a0
ffffffffc0200a10:	01242823          	sw	s2,16(s0)
    size_t i = 0,size = max_size,offset = 0;
ffffffffc0200a14:	882e                	mv	a6,a1
    while (free_tree[(i<<1)+1]>=n || free_tree[(i<<1)+2]>=n)
ffffffffc0200a16:	02a6f163          	bgeu	a3,a0,ffffffffc0200a38 <buddy_system_alloc_pages+0x6c>
ffffffffc0200a1a:	6b18                	ld	a4,16(a4)
ffffffffc0200a1c:	00178693          	addi	a3,a5,1
ffffffffc0200a20:	02a76963          	bltu	a4,a0,ffffffffc0200a52 <buddy_system_alloc_pages+0x86>
        else i = (i<<1)+2;
ffffffffc0200a24:	0786                	slli	a5,a5,0x1
ffffffffc0200a26:	0789                	addi	a5,a5,2
        size = size>>1;
ffffffffc0200a28:	00185813          	srli	a6,a6,0x1
    while (free_tree[(i<<1)+1]>=n || free_tree[(i<<1)+2]>=n)
ffffffffc0200a2c:	00479713          	slli	a4,a5,0x4
ffffffffc0200a30:	9732                	add	a4,a4,a2
ffffffffc0200a32:	6714                	ld	a3,8(a4)
ffffffffc0200a34:	fea6e3e3          	bltu	a3,a0,ffffffffc0200a1a <buddy_system_alloc_pages+0x4e>
        if(free_tree[(i<<1)+1]>=n) i = (i<<1)+1;
ffffffffc0200a38:	0786                	slli	a5,a5,0x1
ffffffffc0200a3a:	0785                	addi	a5,a5,1
        size = size>>1;
ffffffffc0200a3c:	00185813          	srli	a6,a6,0x1
ffffffffc0200a40:	b7f5                	j	ffffffffc0200a2c <buddy_system_alloc_pages+0x60>
    while (i!=0)
ffffffffc0200a42:	e7a1                	bnez	a5,ffffffffc0200a8a <buddy_system_alloc_pages+0xbe>
}
ffffffffc0200a44:	60e2                	ld	ra,24(sp)
ffffffffc0200a46:	6442                	ld	s0,16(sp)
ffffffffc0200a48:	6902                	ld	s2,0(sp)
ffffffffc0200a4a:	8526                	mv	a0,s1
ffffffffc0200a4c:	64a2                	ld	s1,8(sp)
ffffffffc0200a4e:	6105                	addi	sp,sp,32
ffffffffc0200a50:	8082                	ret
    offset = (i + 1) * size - max_size;
ffffffffc0200a52:	03068733          	mul	a4,a3,a6
    page = Base+offset;
ffffffffc0200a56:	6008                	ld	a0,0(s0)
    free_tree[i] = 0;
ffffffffc0200a58:	00379893          	slli	a7,a5,0x3
ffffffffc0200a5c:	9646                	add	a2,a2,a7
ffffffffc0200a5e:	00063023          	sd	zero,0(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200a62:	5675                	li	a2,-3
    offset = (i + 1) * size - max_size;
ffffffffc0200a64:	8f0d                	sub	a4,a4,a1
    page = Base+offset;
ffffffffc0200a66:	00271493          	slli	s1,a4,0x2
ffffffffc0200a6a:	94ba                	add	s1,s1,a4
ffffffffc0200a6c:	048e                	slli	s1,s1,0x3
ffffffffc0200a6e:	94aa                	add	s1,s1,a0
    page->property = 0;
ffffffffc0200a70:	0004a823          	sw	zero,16(s1)
ffffffffc0200a74:	00848593          	addi	a1,s1,8
ffffffffc0200a78:	60c5b02f          	amoand.d	zero,a2,(a1)
    if( i%2==1 && free_tree[i+1]==size) 
ffffffffc0200a7c:	0017f613          	andi	a2,a5,1
ffffffffc0200a80:	e22d                	bnez	a2,ffffffffc0200ae2 <buddy_system_alloc_pages+0x116>
    while (i!=0)
ffffffffc0200a82:	d3e9                	beqz	a5,ffffffffc0200a44 <buddy_system_alloc_pages+0x78>
        free_tree[i]=max(free_tree[(i<<1)+1],free_tree[(i<<1)+2]); //树上操作:更新祖宗节点的值
ffffffffc0200a84:	640c                	ld	a1,8(s0)
        offset = (i + 1) * size - max_size;        
ffffffffc0200a86:	4c08                	lw	a0,24(s0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200a88:	4889                	li	a7,2
        i = (i-1)>>1;
ffffffffc0200a8a:	17fd                	addi	a5,a5,-1
ffffffffc0200a8c:	8385                	srli	a5,a5,0x1
        offset = (i + 1) * size - max_size;        
ffffffffc0200a8e:	00178713          	addi	a4,a5,1
        free_tree[i]=max(free_tree[(i<<1)+1],free_tree[(i<<1)+2]); //树上操作:更新祖宗节点的值
ffffffffc0200a92:	0712                	slli	a4,a4,0x4
ffffffffc0200a94:	972e                	add	a4,a4,a1
ffffffffc0200a96:	6310                	ld	a2,0(a4)
ffffffffc0200a98:	ff873683          	ld	a3,-8(a4)
ffffffffc0200a9c:	00379713          	slli	a4,a5,0x3
        size = size<<1;
ffffffffc0200aa0:	0806                	slli	a6,a6,0x1
        free_tree[i]=max(free_tree[(i<<1)+1],free_tree[(i<<1)+2]); //树上操作:更新祖宗节点的值
ffffffffc0200aa2:	972e                	add	a4,a4,a1
ffffffffc0200aa4:	00c6f363          	bgeu	a3,a2,ffffffffc0200aaa <buddy_system_alloc_pages+0xde>
ffffffffc0200aa8:	86b2                	mv	a3,a2
ffffffffc0200aaa:	e314                	sd	a3,0(a4)
        if( i%2==1 && free_tree[i+1]==size) 
ffffffffc0200aac:	0017f693          	andi	a3,a5,1
ffffffffc0200ab0:	dac9                	beqz	a3,ffffffffc0200a42 <buddy_system_alloc_pages+0x76>
ffffffffc0200ab2:	6714                	ld	a3,8(a4)
ffffffffc0200ab4:	fd069be3          	bne	a3,a6,ffffffffc0200a8a <buddy_system_alloc_pages+0xbe>
            struct Page* right = Base+offset+size;
ffffffffc0200ab8:	00278713          	addi	a4,a5,2
ffffffffc0200abc:	03070733          	mul	a4,a4,a6
        offset = (i + 1) * size - max_size;        
ffffffffc0200ac0:	1502                	slli	a0,a0,0x20
ffffffffc0200ac2:	9101                	srli	a0,a0,0x20
            struct Page* right = Base+offset+size;
ffffffffc0200ac4:	6014                	ld	a3,0(s0)
ffffffffc0200ac6:	8f09                	sub	a4,a4,a0
ffffffffc0200ac8:	00271613          	slli	a2,a4,0x2
ffffffffc0200acc:	9732                	add	a4,a4,a2
ffffffffc0200ace:	070e                	slli	a4,a4,0x3
ffffffffc0200ad0:	9736                	add	a4,a4,a3
            right->property = size;
ffffffffc0200ad2:	01072823          	sw	a6,16(a4)
ffffffffc0200ad6:	0721                	addi	a4,a4,8
ffffffffc0200ad8:	4117302f          	amoor.d	zero,a7,(a4)
        offset = (i + 1) * size - max_size;        
ffffffffc0200adc:	4c08                	lw	a0,24(s0)
        free_tree[i]=max(free_tree[(i<<1)+1],free_tree[(i<<1)+2]); //树上操作:更新祖宗节点的值
ffffffffc0200ade:	640c                	ld	a1,8(s0)
}
ffffffffc0200ae0:	b76d                	j	ffffffffc0200a8a <buddy_system_alloc_pages+0xbe>
    if( i%2==1 && free_tree[i+1]==size) 
ffffffffc0200ae2:	640c                	ld	a1,8(s0)
ffffffffc0200ae4:	068e                	slli	a3,a3,0x3
ffffffffc0200ae6:	96ae                	add	a3,a3,a1
ffffffffc0200ae8:	6294                	ld	a3,0(a3)
ffffffffc0200aea:	f9069ee3          	bne	a3,a6,ffffffffc0200a86 <buddy_system_alloc_pages+0xba>
        struct Page* right = Base+offset+size;
ffffffffc0200aee:	9742                	add	a4,a4,a6
ffffffffc0200af0:	00271693          	slli	a3,a4,0x2
ffffffffc0200af4:	9736                	add	a4,a4,a3
ffffffffc0200af6:	070e                	slli	a4,a4,0x3
ffffffffc0200af8:	953a                	add	a0,a0,a4
        right->property = size;
ffffffffc0200afa:	01052823          	sw	a6,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200afe:	4709                	li	a4,2
ffffffffc0200b00:	00850693          	addi	a3,a0,8
ffffffffc0200b04:	40e6b02f          	amoor.d	zero,a4,(a3)
}
ffffffffc0200b08:	bfbd                	j	ffffffffc0200a86 <buddy_system_alloc_pages+0xba>
    assert(n > 0);
ffffffffc0200b0a:	00001697          	auipc	a3,0x1
ffffffffc0200b0e:	44e68693          	addi	a3,a3,1102 # ffffffffc0201f58 <commands+0x4d8>
ffffffffc0200b12:	00001617          	auipc	a2,0x1
ffffffffc0200b16:	44e60613          	addi	a2,a2,1102 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc0200b1a:	09400593          	li	a1,148
ffffffffc0200b1e:	00001517          	auipc	a0,0x1
ffffffffc0200b22:	45a50513          	addi	a0,a0,1114 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0200b26:	e14ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200b2a <buddy_system_init_memmap>:
{
ffffffffc0200b2a:	1101                	addi	sp,sp,-32
ffffffffc0200b2c:	ec06                	sd	ra,24(sp)
ffffffffc0200b2e:	e822                	sd	s0,16(sp)
ffffffffc0200b30:	e426                	sd	s1,8(sp)
    assert(n > 0);
ffffffffc0200b32:	18058c63          	beqz	a1,ffffffffc0200cca <buddy_system_init_memmap+0x1a0>
ffffffffc0200b36:	842a                	mv	s0,a0
    size_t N = up_to_2_power(n); //将n向上变为2的幂，以便于buddy_system算法的实现
ffffffffc0200b38:	852e                	mv	a0,a1
ffffffffc0200b3a:	84ae                	mv	s1,a1
ffffffffc0200b3c:	cebff0ef          	jal	ra,ffffffffc0200826 <up_to_2_power>
    for (; p != base + n; p ++) 
ffffffffc0200b40:	00249693          	slli	a3,s1,0x2
ffffffffc0200b44:	96a6                	add	a3,a3,s1
ffffffffc0200b46:	068e                	slli	a3,a3,0x3
ffffffffc0200b48:	96a2                	add	a3,a3,s0
ffffffffc0200b4a:	87a2                	mv	a5,s0
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200b4c:	5675                	li	a2,-3
ffffffffc0200b4e:	02d40463          	beq	s0,a3,ffffffffc0200b76 <buddy_system_init_memmap+0x4c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b52:	6798                	ld	a4,8(a5)
        assert(PageReserved(p)); 
ffffffffc0200b54:	8b05                	andi	a4,a4,1
ffffffffc0200b56:	10070e63          	beqz	a4,ffffffffc0200c72 <buddy_system_init_memmap+0x148>
        p->flags = 0;
ffffffffc0200b5a:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc0200b5e:	0007a823          	sw	zero,16(a5)
ffffffffc0200b62:	0007a023          	sw	zero,0(a5)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200b66:	00878713          	addi	a4,a5,8
ffffffffc0200b6a:	60c7302f          	amoand.d	zero,a2,(a4)
    for (; p != base + n; p ++) 
ffffffffc0200b6e:	02878793          	addi	a5,a5,40
ffffffffc0200b72:	fed790e3          	bne	a5,a3,ffffffffc0200b52 <buddy_system_init_memmap+0x28>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b76:	00006697          	auipc	a3,0x6
ffffffffc0200b7a:	8d26b683          	ld	a3,-1838(a3) # ffffffffc0206448 <pages>
ffffffffc0200b7e:	40d406b3          	sub	a3,s0,a3
ffffffffc0200b82:	00002797          	auipc	a5,0x2
ffffffffc0200b86:	9d67b783          	ld	a5,-1578(a5) # ffffffffc0202558 <error_string+0x38>
ffffffffc0200b8a:	868d                	srai	a3,a3,0x3
ffffffffc0200b8c:	02f686b3          	mul	a3,a3,a5
ffffffffc0200b90:	00002717          	auipc	a4,0x2
ffffffffc0200b94:	9d073703          	ld	a4,-1584(a4) # ffffffffc0202560 <nbase>
    Base = base;
ffffffffc0200b98:	00005797          	auipc	a5,0x5
ffffffffc0200b9c:	47878793          	addi	a5,a5,1144 # ffffffffc0206010 <free_area>
    nr_free = n;
ffffffffc0200ba0:	0004881b          	sext.w	a6,s1
    Base = base;
ffffffffc0200ba4:	e380                	sd	s0,0(a5)
    nr_free = n;
ffffffffc0200ba6:	0107a823          	sw	a6,16(a5)
    true_size = n;
ffffffffc0200baa:	0107aa23          	sw	a6,20(a5)
    max_size = N;
ffffffffc0200bae:	cf88                	sw	a0,24(a5)
    free_tree = (size_t*)KADDR(page2pa(base)); 
ffffffffc0200bb0:	00006617          	auipc	a2,0x6
ffffffffc0200bb4:	89063603          	ld	a2,-1904(a2) # ffffffffc0206440 <npage>
ffffffffc0200bb8:	96ba                	add	a3,a3,a4
ffffffffc0200bba:	00c69713          	slli	a4,a3,0xc
ffffffffc0200bbe:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bc0:	06b2                	slli	a3,a3,0xc
ffffffffc0200bc2:	0ec77863          	bgeu	a4,a2,ffffffffc0200cb2 <buddy_system_init_memmap+0x188>
ffffffffc0200bc6:	00006717          	auipc	a4,0x6
ffffffffc0200bca:	8a273703          	ld	a4,-1886(a4) # ffffffffc0206468 <va_pa_offset>
ffffffffc0200bce:	96ba                	add	a3,a3,a4
ffffffffc0200bd0:	e794                	sd	a3,8(a5)
    assert(free_tree != NULL);
ffffffffc0200bd2:	c2e1                	beqz	a3,ffffffffc0200c92 <buddy_system_init_memmap+0x168>
    size_t i = 2*N-1; //最后一个再后一个
ffffffffc0200bd4:	00151893          	slli	a7,a0,0x1
    while(i>N+n-1) free_tree[--i] = 0;
ffffffffc0200bd8:	14fd                	addi	s1,s1,-1
    size_t i = 2*N-1; //最后一个再后一个
ffffffffc0200bda:	fff88793          	addi	a5,a7,-1
    while(i>N+n-1) free_tree[--i] = 0;
ffffffffc0200bde:	94aa                	add	s1,s1,a0
ffffffffc0200be0:	02f4f463          	bgeu	s1,a5,ffffffffc0200c08 <buddy_system_init_memmap+0xde>
ffffffffc0200be4:	ffe88713          	addi	a4,a7,-2
ffffffffc0200be8:	070e                	slli	a4,a4,0x3
ffffffffc0200bea:	00349613          	slli	a2,s1,0x3
ffffffffc0200bee:	ff868313          	addi	t1,a3,-8
ffffffffc0200bf2:	9736                	add	a4,a4,a3
ffffffffc0200bf4:	961a                	add	a2,a2,t1
ffffffffc0200bf6:	00073023          	sd	zero,0(a4)
ffffffffc0200bfa:	1761                	addi	a4,a4,-8
ffffffffc0200bfc:	fee61de3          	bne	a2,a4,ffffffffc0200bf6 <buddy_system_init_memmap+0xcc>
ffffffffc0200c00:	0485                	addi	s1,s1,1
ffffffffc0200c02:	97a6                	add	a5,a5,s1
ffffffffc0200c04:	411787b3          	sub	a5,a5,a7
    while(i>N-1)   free_tree[--i] = 1;
ffffffffc0200c08:	fff50713          	addi	a4,a0,-1
ffffffffc0200c0c:	06f77163          	bgeu	a4,a5,ffffffffc0200c6e <buddy_system_init_memmap+0x144>
ffffffffc0200c10:	17fd                	addi	a5,a5,-1
ffffffffc0200c12:	078e                	slli	a5,a5,0x3
ffffffffc0200c14:	050e                	slli	a0,a0,0x3
ffffffffc0200c16:	ff068613          	addi	a2,a3,-16
ffffffffc0200c1a:	97b6                	add	a5,a5,a3
ffffffffc0200c1c:	962a                	add	a2,a2,a0
ffffffffc0200c1e:	4585                	li	a1,1
ffffffffc0200c20:	e38c                	sd	a1,0(a5)
ffffffffc0200c22:	17e1                	addi	a5,a5,-8
ffffffffc0200c24:	fef61ee3          	bne	a2,a5,ffffffffc0200c20 <buddy_system_init_memmap+0xf6>
    while(i>0)     
ffffffffc0200c28:	c705                	beqz	a4,ffffffffc0200c50 <buddy_system_init_memmap+0x126>
ffffffffc0200c2a:	fff70613          	addi	a2,a4,-1
ffffffffc0200c2e:	060e                	slli	a2,a2,0x3
ffffffffc0200c30:	0712                	slli	a4,a4,0x4
ffffffffc0200c32:	9736                	add	a4,a4,a3
ffffffffc0200c34:	9636                	add	a2,a2,a3
        if( free_tree[(i<<1)+1]==free_tree[(i<<1)+2] ) free_tree[i] = free_tree[(i<<1)+1]+free_tree[(i<<1)+2];
ffffffffc0200c36:	ff873783          	ld	a5,-8(a4)
ffffffffc0200c3a:	630c                	ld	a1,0(a4)
ffffffffc0200c3c:	02b78663          	beq	a5,a1,ffffffffc0200c68 <buddy_system_init_memmap+0x13e>
        else free_tree[i]=max(free_tree[(i<<1)+1],free_tree[(i<<1)+2]);         
ffffffffc0200c40:	00b7f363          	bgeu	a5,a1,ffffffffc0200c46 <buddy_system_init_memmap+0x11c>
ffffffffc0200c44:	87ae                	mv	a5,a1
ffffffffc0200c46:	e21c                	sd	a5,0(a2)
    while(i>0)     
ffffffffc0200c48:	1741                	addi	a4,a4,-16
ffffffffc0200c4a:	1661                	addi	a2,a2,-8
ffffffffc0200c4c:	fee695e3          	bne	a3,a4,ffffffffc0200c36 <buddy_system_init_memmap+0x10c>
    base->property = n;
ffffffffc0200c50:	01042823          	sw	a6,16(s0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200c54:	4789                	li	a5,2
ffffffffc0200c56:	00840713          	addi	a4,s0,8
ffffffffc0200c5a:	40f7302f          	amoor.d	zero,a5,(a4)
}
ffffffffc0200c5e:	60e2                	ld	ra,24(sp)
ffffffffc0200c60:	6442                	ld	s0,16(sp)
ffffffffc0200c62:	64a2                	ld	s1,8(sp)
ffffffffc0200c64:	6105                	addi	sp,sp,32
ffffffffc0200c66:	8082                	ret
        if( free_tree[(i<<1)+1]==free_tree[(i<<1)+2] ) free_tree[i] = free_tree[(i<<1)+1]+free_tree[(i<<1)+2];
ffffffffc0200c68:	0786                	slli	a5,a5,0x1
ffffffffc0200c6a:	e21c                	sd	a5,0(a2)
ffffffffc0200c6c:	bff1                	j	ffffffffc0200c48 <buddy_system_init_memmap+0x11e>
    while(i>N-1)   free_tree[--i] = 1;
ffffffffc0200c6e:	873e                	mv	a4,a5
ffffffffc0200c70:	bf65                	j	ffffffffc0200c28 <buddy_system_init_memmap+0xfe>
        assert(PageReserved(p)); 
ffffffffc0200c72:	00001697          	auipc	a3,0x1
ffffffffc0200c76:	34e68693          	addi	a3,a3,846 # ffffffffc0201fc0 <commands+0x540>
ffffffffc0200c7a:	00001617          	auipc	a2,0x1
ffffffffc0200c7e:	2e660613          	addi	a2,a2,742 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc0200c82:	06c00593          	li	a1,108
ffffffffc0200c86:	00001517          	auipc	a0,0x1
ffffffffc0200c8a:	2f250513          	addi	a0,a0,754 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0200c8e:	cacff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(free_tree != NULL);
ffffffffc0200c92:	00001697          	auipc	a3,0x1
ffffffffc0200c96:	36668693          	addi	a3,a3,870 # ffffffffc0201ff8 <commands+0x578>
ffffffffc0200c9a:	00001617          	auipc	a2,0x1
ffffffffc0200c9e:	2c660613          	addi	a2,a2,710 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc0200ca2:	07a00593          	li	a1,122
ffffffffc0200ca6:	00001517          	auipc	a0,0x1
ffffffffc0200caa:	2d250513          	addi	a0,a0,722 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0200cae:	c8cff0ef          	jal	ra,ffffffffc020013a <__panic>
    free_tree = (size_t*)KADDR(page2pa(base)); 
ffffffffc0200cb2:	00001617          	auipc	a2,0x1
ffffffffc0200cb6:	31e60613          	addi	a2,a2,798 # ffffffffc0201fd0 <commands+0x550>
ffffffffc0200cba:	07900593          	li	a1,121
ffffffffc0200cbe:	00001517          	auipc	a0,0x1
ffffffffc0200cc2:	2ba50513          	addi	a0,a0,698 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0200cc6:	c74ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(n > 0);
ffffffffc0200cca:	00001697          	auipc	a3,0x1
ffffffffc0200cce:	28e68693          	addi	a3,a3,654 # ffffffffc0201f58 <commands+0x4d8>
ffffffffc0200cd2:	00001617          	auipc	a2,0x1
ffffffffc0200cd6:	28e60613          	addi	a2,a2,654 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc0200cda:	06400593          	li	a1,100
ffffffffc0200cde:	00001517          	auipc	a0,0x1
ffffffffc0200ce2:	29a50513          	addi	a0,a0,666 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0200ce6:	c54ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200cea <test_print.constprop.0>:
 * 参数:
 * @p0              物理页指针
 * @n               数量n
 * 注意:通过是否注释return决定是否在buddy_system_check()中是否输出
 */
static void test_print(struct Page* p0,size_t n)
ffffffffc0200cea:	7179                	addi	sp,sp,-48
ffffffffc0200cec:	f022                	sd	s0,32(sp)
ffffffffc0200cee:	ec26                	sd	s1,24(sp)
ffffffffc0200cf0:	e84a                	sd	s2,16(sp)
ffffffffc0200cf2:	e44e                	sd	s3,8(sp)
ffffffffc0200cf4:	f406                	sd	ra,40(sp)
ffffffffc0200cf6:	84aa                	mv	s1,a0
ffffffffc0200cf8:	28050993          	addi	s3,a0,640
ffffffffc0200cfc:	842a                	mv	s0,a0
{
    for(int i=0;i<n;i++)
    {
        cprintf("%d ",PageProperty(p0+i));
ffffffffc0200cfe:	00001917          	auipc	s2,0x1
ffffffffc0200d02:	31290913          	addi	s2,s2,786 # ffffffffc0202010 <commands+0x590>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200d06:	640c                	ld	a1,8(s0)
ffffffffc0200d08:	854a                	mv	a0,s2
    for(int i=0;i<n;i++)
ffffffffc0200d0a:	02840413          	addi	s0,s0,40
ffffffffc0200d0e:	8185                	srli	a1,a1,0x1
        cprintf("%d ",PageProperty(p0+i));
ffffffffc0200d10:	8985                	andi	a1,a1,1
ffffffffc0200d12:	ba0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for(int i=0;i<n;i++)
ffffffffc0200d16:	ff3418e3          	bne	s0,s3,ffffffffc0200d06 <test_print.constprop.0+0x1c>
    }
    cprintf("\n");
ffffffffc0200d1a:	00001517          	auipc	a0,0x1
ffffffffc0200d1e:	bf650513          	addi	a0,a0,-1034 # ffffffffc0201910 <etext+0x108>
ffffffffc0200d22:	01048413          	addi	s0,s1,16
ffffffffc0200d26:	b8cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        for(int i=0;i<n;i++)
ffffffffc0200d2a:	29048493          	addi	s1,s1,656
    {
        cprintf("%d ",(p0+i)->property);
ffffffffc0200d2e:	00001917          	auipc	s2,0x1
ffffffffc0200d32:	2e290913          	addi	s2,s2,738 # ffffffffc0202010 <commands+0x590>
ffffffffc0200d36:	400c                	lw	a1,0(s0)
ffffffffc0200d38:	854a                	mv	a0,s2
        for(int i=0;i<n;i++)
ffffffffc0200d3a:	02840413          	addi	s0,s0,40
        cprintf("%d ",(p0+i)->property);
ffffffffc0200d3e:	b74ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        for(int i=0;i<n;i++)
ffffffffc0200d42:	fe849ae3          	bne	s1,s0,ffffffffc0200d36 <test_print.constprop.0+0x4c>
    }
    cprintf("\n");
ffffffffc0200d46:	00001517          	auipc	a0,0x1
ffffffffc0200d4a:	bca50513          	addi	a0,a0,-1078 # ffffffffc0201910 <etext+0x108>
ffffffffc0200d4e:	b64ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("\n");
}
ffffffffc0200d52:	7402                	ld	s0,32(sp)
ffffffffc0200d54:	70a2                	ld	ra,40(sp)
ffffffffc0200d56:	64e2                	ld	s1,24(sp)
ffffffffc0200d58:	6942                	ld	s2,16(sp)
ffffffffc0200d5a:	69a2                	ld	s3,8(sp)
    cprintf("\n");
ffffffffc0200d5c:	00001517          	auipc	a0,0x1
ffffffffc0200d60:	bb450513          	addi	a0,a0,-1100 # ffffffffc0201910 <etext+0x108>
}
ffffffffc0200d64:	6145                	addi	sp,sp,48
    cprintf("\n");
ffffffffc0200d66:	b4cff06f          	j	ffffffffc02000b2 <cprintf>

ffffffffc0200d6a <buddy_system_check>:
 * 功能:检查buddy_system是否正确
 * 注意:本函数参考自https://github.com/AllenKaixuan/Operating-System/blob/main/labcodes/lab2/kern/mm/buddy_pmm.c的buddy_check()函数。
 * 注意:以上参考代码本身存在一定缺陷（甚至可以说是错误）,对其进行较大幅度修正。
 */
static void buddy_system_check(void) 
{
ffffffffc0200d6a:	7179                	addi	sp,sp,-48
ffffffffc0200d6c:	f406                	sd	ra,40(sp)
ffffffffc0200d6e:	f022                	sd	s0,32(sp)
ffffffffc0200d70:	ec26                	sd	s1,24(sp)
ffffffffc0200d72:	e84a                	sd	s2,16(sp)
ffffffffc0200d74:	e44e                	sd	s3,8(sp)
    int all_pages = nr_free_pages();
ffffffffc0200d76:	370000ef          	jal	ra,ffffffffc02010e6 <nr_free_pages>
    struct Page* p0, *p1, *p2, *p3;
    // 分配过大的页数
    assert(alloc_pages(all_pages + 1) == NULL);
ffffffffc0200d7a:	2505                	addiw	a0,a0,1
ffffffffc0200d7c:	2ec000ef          	jal	ra,ffffffffc0201068 <alloc_pages>
ffffffffc0200d80:	2a051463          	bnez	a0,ffffffffc0201028 <buddy_system_check+0x2be>
    // 分配两个组页
    p0 = alloc_pages(1);
ffffffffc0200d84:	4505                	li	a0,1
ffffffffc0200d86:	2e2000ef          	jal	ra,ffffffffc0201068 <alloc_pages>
ffffffffc0200d8a:	842a                	mv	s0,a0
    test_print(p0,16);//1
ffffffffc0200d8c:	f5fff0ef          	jal	ra,ffffffffc0200cea <test_print.constprop.0>
    assert(p0 != NULL);
ffffffffc0200d90:	26040c63          	beqz	s0,ffffffffc0201008 <buddy_system_check+0x29e>
    p1 = alloc_pages(2);
ffffffffc0200d94:	4509                	li	a0,2
ffffffffc0200d96:	2d2000ef          	jal	ra,ffffffffc0201068 <alloc_pages>
ffffffffc0200d9a:	84aa                	mv	s1,a0
    test_print(p0,16);//2
ffffffffc0200d9c:	8522                	mv	a0,s0
ffffffffc0200d9e:	f4dff0ef          	jal	ra,ffffffffc0200cea <test_print.constprop.0>
    assert(p1 == p0 + 2);
ffffffffc0200da2:	05040793          	addi	a5,s0,80
ffffffffc0200da6:	24f49163          	bne	s1,a5,ffffffffc0200fe8 <buddy_system_check+0x27e>
ffffffffc0200daa:	641c                	ld	a5,8(s0)
    assert(!PageReserved(p0) && !PageProperty(p0));
ffffffffc0200dac:	8b85                	andi	a5,a5,1
ffffffffc0200dae:	14079d63          	bnez	a5,ffffffffc0200f08 <buddy_system_check+0x19e>
ffffffffc0200db2:	641c                	ld	a5,8(s0)
ffffffffc0200db4:	8385                	srli	a5,a5,0x1
ffffffffc0200db6:	8b85                	andi	a5,a5,1
ffffffffc0200db8:	14079863          	bnez	a5,ffffffffc0200f08 <buddy_system_check+0x19e>
ffffffffc0200dbc:	649c                	ld	a5,8(s1)
    assert(!PageReserved(p1) && !PageProperty(p1));
ffffffffc0200dbe:	8b85                	andi	a5,a5,1
ffffffffc0200dc0:	12079463          	bnez	a5,ffffffffc0200ee8 <buddy_system_check+0x17e>
ffffffffc0200dc4:	649c                	ld	a5,8(s1)
ffffffffc0200dc6:	8385                	srli	a5,a5,0x1
ffffffffc0200dc8:	8b85                	andi	a5,a5,1
ffffffffc0200dca:	10079f63          	bnez	a5,ffffffffc0200ee8 <buddy_system_check+0x17e>
    // 再分配两个组页
    p2 = alloc_pages(1);
ffffffffc0200dce:	4505                	li	a0,1
ffffffffc0200dd0:	298000ef          	jal	ra,ffffffffc0201068 <alloc_pages>
ffffffffc0200dd4:	89aa                	mv	s3,a0
    test_print(p0,16);//3
ffffffffc0200dd6:	8522                	mv	a0,s0
ffffffffc0200dd8:	f13ff0ef          	jal	ra,ffffffffc0200cea <test_print.constprop.0>
    assert(p2 == p0 + 1);
ffffffffc0200ddc:	02840793          	addi	a5,s0,40
ffffffffc0200de0:	1af99463          	bne	s3,a5,ffffffffc0200f88 <buddy_system_check+0x21e>
    p3 = alloc_pages(8);
ffffffffc0200de4:	4521                	li	a0,8
ffffffffc0200de6:	282000ef          	jal	ra,ffffffffc0201068 <alloc_pages>
ffffffffc0200dea:	892a                	mv	s2,a0
    test_print(p0,16);//4
ffffffffc0200dec:	8522                	mv	a0,s0
ffffffffc0200dee:	efdff0ef          	jal	ra,ffffffffc0200cea <test_print.constprop.0>
    assert(p3 == p0 + 8);
ffffffffc0200df2:	14040793          	addi	a5,s0,320
ffffffffc0200df6:	16f91963          	bne	s2,a5,ffffffffc0200f68 <buddy_system_check+0x1fe>
ffffffffc0200dfa:	00893783          	ld	a5,8(s2)
ffffffffc0200dfe:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p3) && !PageProperty(p3 + 7) && PageProperty(p3 + 8));
ffffffffc0200e00:	8b85                	andi	a5,a5,1
ffffffffc0200e02:	0c079363          	bnez	a5,ffffffffc0200ec8 <buddy_system_check+0x15e>
ffffffffc0200e06:	12093783          	ld	a5,288(s2)
ffffffffc0200e0a:	8385                	srli	a5,a5,0x1
ffffffffc0200e0c:	8b85                	andi	a5,a5,1
ffffffffc0200e0e:	efcd                	bnez	a5,ffffffffc0200ec8 <buddy_system_check+0x15e>
ffffffffc0200e10:	14893783          	ld	a5,328(s2)
ffffffffc0200e14:	8385                	srli	a5,a5,0x1
ffffffffc0200e16:	8b85                	andi	a5,a5,1
ffffffffc0200e18:	cbc5                	beqz	a5,ffffffffc0200ec8 <buddy_system_check+0x15e>
    // 回收页
    free_pages(p1, 2);
ffffffffc0200e1a:	4589                	li	a1,2
ffffffffc0200e1c:	8526                	mv	a0,s1
ffffffffc0200e1e:	288000ef          	jal	ra,ffffffffc02010a6 <free_pages>
    test_print(p0,16);//5
ffffffffc0200e22:	8522                	mv	a0,s0
ffffffffc0200e24:	ec7ff0ef          	jal	ra,ffffffffc0200cea <test_print.constprop.0>
ffffffffc0200e28:	649c                	ld	a5,8(s1)
ffffffffc0200e2a:	8385                	srli	a5,a5,0x1
    //assert(PageProperty(p1) && PageProperty(p1 + 1));参考代码修正
    assert(PageProperty(p1) && !PageProperty(p1 + 1));
ffffffffc0200e2c:	8b85                	andi	a5,a5,1
ffffffffc0200e2e:	0e078d63          	beqz	a5,ffffffffc0200f28 <buddy_system_check+0x1be>
ffffffffc0200e32:	789c                	ld	a5,48(s1)
ffffffffc0200e34:	8385                	srli	a5,a5,0x1
ffffffffc0200e36:	8b85                	andi	a5,a5,1
ffffffffc0200e38:	0e079863          	bnez	a5,ffffffffc0200f28 <buddy_system_check+0x1be>
    assert(p1->ref == 0);
ffffffffc0200e3c:	409c                	lw	a5,0(s1)
ffffffffc0200e3e:	10079563          	bnez	a5,ffffffffc0200f48 <buddy_system_check+0x1de>
    free_pages(p0, 1);
ffffffffc0200e42:	4585                	li	a1,1
ffffffffc0200e44:	8522                	mv	a0,s0
ffffffffc0200e46:	260000ef          	jal	ra,ffffffffc02010a6 <free_pages>
    test_print(p0,16);//6
ffffffffc0200e4a:	8522                	mv	a0,s0
ffffffffc0200e4c:	e9fff0ef          	jal	ra,ffffffffc0200cea <test_print.constprop.0>
    free_pages(p2, 1);
ffffffffc0200e50:	4585                	li	a1,1
ffffffffc0200e52:	854e                	mv	a0,s3
ffffffffc0200e54:	252000ef          	jal	ra,ffffffffc02010a6 <free_pages>
    test_print(p0,16);//7
ffffffffc0200e58:	8522                	mv	a0,s0
ffffffffc0200e5a:	e91ff0ef          	jal	ra,ffffffffc0200cea <test_print.constprop.0>
    // 回收后再分配
    p2 = alloc_pages(3);
ffffffffc0200e5e:	450d                	li	a0,3
ffffffffc0200e60:	208000ef          	jal	ra,ffffffffc0201068 <alloc_pages>
ffffffffc0200e64:	84aa                	mv	s1,a0
    test_print(p0,16);//8
ffffffffc0200e66:	8522                	mv	a0,s0
ffffffffc0200e68:	e83ff0ef          	jal	ra,ffffffffc0200cea <test_print.constprop.0>
    assert(p2 == p0);
ffffffffc0200e6c:	14941e63          	bne	s0,s1,ffffffffc0200fc8 <buddy_system_check+0x25e>
    free_pages(p2, 3);//9
ffffffffc0200e70:	458d                	li	a1,3
ffffffffc0200e72:	8522                	mv	a0,s0
ffffffffc0200e74:	232000ef          	jal	ra,ffffffffc02010a6 <free_pages>
    assert((p2 + 2)->ref == 0);
ffffffffc0200e78:	483c                	lw	a5,80(s0)
ffffffffc0200e7a:	12079763          	bnez	a5,ffffffffc0200fa8 <buddy_system_check+0x23e>
    test_print(p0,16);//10
ffffffffc0200e7e:	8522                	mv	a0,s0
ffffffffc0200e80:	e6bff0ef          	jal	ra,ffffffffc0200cea <test_print.constprop.0>
    //assert(nr_free_pages() == all_pages >> 1);
    p1 = alloc_pages(129);
ffffffffc0200e84:	08100513          	li	a0,129
ffffffffc0200e88:	1e0000ef          	jal	ra,ffffffffc0201068 <alloc_pages>
ffffffffc0200e8c:	84aa                	mv	s1,a0
    test_print(p0,16);//11
ffffffffc0200e8e:	8522                	mv	a0,s0
ffffffffc0200e90:	e5bff0ef          	jal	ra,ffffffffc0200cea <test_print.constprop.0>
    assert(p1 == p0 + 256);
ffffffffc0200e94:	678d                	lui	a5,0x3
ffffffffc0200e96:	80078793          	addi	a5,a5,-2048 # 2800 <kern_entry-0xffffffffc01fd800>
ffffffffc0200e9a:	97a2                	add	a5,a5,s0
ffffffffc0200e9c:	1af49663          	bne	s1,a5,ffffffffc0201048 <buddy_system_check+0x2de>
    //free_pages(p1, 256);
    free_pages(p1, 129);//参考代码适配
ffffffffc0200ea0:	08100593          	li	a1,129
ffffffffc0200ea4:	8526                	mv	a0,s1
ffffffffc0200ea6:	200000ef          	jal	ra,ffffffffc02010a6 <free_pages>
    test_print(p0,16);//12
ffffffffc0200eaa:	8522                	mv	a0,s0
ffffffffc0200eac:	e3fff0ef          	jal	ra,ffffffffc0200cea <test_print.constprop.0>
    free_pages(p3, 8);
ffffffffc0200eb0:	854a                	mv	a0,s2
ffffffffc0200eb2:	45a1                	li	a1,8
ffffffffc0200eb4:	1f2000ef          	jal	ra,ffffffffc02010a6 <free_pages>
    test_print(p0,16);//13
ffffffffc0200eb8:	8522                	mv	a0,s0
}
ffffffffc0200eba:	7402                	ld	s0,32(sp)
ffffffffc0200ebc:	70a2                	ld	ra,40(sp)
ffffffffc0200ebe:	64e2                	ld	s1,24(sp)
ffffffffc0200ec0:	6942                	ld	s2,16(sp)
ffffffffc0200ec2:	69a2                	ld	s3,8(sp)
ffffffffc0200ec4:	6145                	addi	sp,sp,48
    test_print(p0,16);//13
ffffffffc0200ec6:	b515                	j	ffffffffc0200cea <test_print.constprop.0>
    assert(!PageProperty(p3) && !PageProperty(p3 + 7) && PageProperty(p3 + 8));
ffffffffc0200ec8:	00001697          	auipc	a3,0x1
ffffffffc0200ecc:	20868693          	addi	a3,a3,520 # ffffffffc02020d0 <commands+0x650>
ffffffffc0200ed0:	00001617          	auipc	a2,0x1
ffffffffc0200ed4:	09060613          	addi	a2,a2,144 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc0200ed8:	13400593          	li	a1,308
ffffffffc0200edc:	00001517          	auipc	a0,0x1
ffffffffc0200ee0:	09c50513          	addi	a0,a0,156 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0200ee4:	a56ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(!PageReserved(p1) && !PageProperty(p1));
ffffffffc0200ee8:	00001697          	auipc	a3,0x1
ffffffffc0200eec:	1a068693          	addi	a3,a3,416 # ffffffffc0202088 <commands+0x608>
ffffffffc0200ef0:	00001617          	auipc	a2,0x1
ffffffffc0200ef4:	07060613          	addi	a2,a2,112 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc0200ef8:	12c00593          	li	a1,300
ffffffffc0200efc:	00001517          	auipc	a0,0x1
ffffffffc0200f00:	07c50513          	addi	a0,a0,124 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0200f04:	a36ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(!PageReserved(p0) && !PageProperty(p0));
ffffffffc0200f08:	00001697          	auipc	a3,0x1
ffffffffc0200f0c:	15868693          	addi	a3,a3,344 # ffffffffc0202060 <commands+0x5e0>
ffffffffc0200f10:	00001617          	auipc	a2,0x1
ffffffffc0200f14:	05060613          	addi	a2,a2,80 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc0200f18:	12b00593          	li	a1,299
ffffffffc0200f1c:	00001517          	auipc	a0,0x1
ffffffffc0200f20:	05c50513          	addi	a0,a0,92 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0200f24:	a16ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(PageProperty(p1) && !PageProperty(p1 + 1));
ffffffffc0200f28:	00001697          	auipc	a3,0x1
ffffffffc0200f2c:	1f068693          	addi	a3,a3,496 # ffffffffc0202118 <commands+0x698>
ffffffffc0200f30:	00001617          	auipc	a2,0x1
ffffffffc0200f34:	03060613          	addi	a2,a2,48 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc0200f38:	13900593          	li	a1,313
ffffffffc0200f3c:	00001517          	auipc	a0,0x1
ffffffffc0200f40:	03c50513          	addi	a0,a0,60 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0200f44:	9f6ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p1->ref == 0);
ffffffffc0200f48:	00001697          	auipc	a3,0x1
ffffffffc0200f4c:	20068693          	addi	a3,a3,512 # ffffffffc0202148 <commands+0x6c8>
ffffffffc0200f50:	00001617          	auipc	a2,0x1
ffffffffc0200f54:	01060613          	addi	a2,a2,16 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc0200f58:	13a00593          	li	a1,314
ffffffffc0200f5c:	00001517          	auipc	a0,0x1
ffffffffc0200f60:	01c50513          	addi	a0,a0,28 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0200f64:	9d6ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p3 == p0 + 8);
ffffffffc0200f68:	00001697          	auipc	a3,0x1
ffffffffc0200f6c:	15868693          	addi	a3,a3,344 # ffffffffc02020c0 <commands+0x640>
ffffffffc0200f70:	00001617          	auipc	a2,0x1
ffffffffc0200f74:	ff060613          	addi	a2,a2,-16 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc0200f78:	13300593          	li	a1,307
ffffffffc0200f7c:	00001517          	auipc	a0,0x1
ffffffffc0200f80:	ffc50513          	addi	a0,a0,-4 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0200f84:	9b6ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p2 == p0 + 1);
ffffffffc0200f88:	00001697          	auipc	a3,0x1
ffffffffc0200f8c:	12868693          	addi	a3,a3,296 # ffffffffc02020b0 <commands+0x630>
ffffffffc0200f90:	00001617          	auipc	a2,0x1
ffffffffc0200f94:	fd060613          	addi	a2,a2,-48 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc0200f98:	13000593          	li	a1,304
ffffffffc0200f9c:	00001517          	auipc	a0,0x1
ffffffffc0200fa0:	fdc50513          	addi	a0,a0,-36 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0200fa4:	996ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert((p2 + 2)->ref == 0);
ffffffffc0200fa8:	00001697          	auipc	a3,0x1
ffffffffc0200fac:	1c068693          	addi	a3,a3,448 # ffffffffc0202168 <commands+0x6e8>
ffffffffc0200fb0:	00001617          	auipc	a2,0x1
ffffffffc0200fb4:	fb060613          	addi	a2,a2,-80 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc0200fb8:	14400593          	li	a1,324
ffffffffc0200fbc:	00001517          	auipc	a0,0x1
ffffffffc0200fc0:	fbc50513          	addi	a0,a0,-68 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0200fc4:	976ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p2 == p0);
ffffffffc0200fc8:	00001697          	auipc	a3,0x1
ffffffffc0200fcc:	19068693          	addi	a3,a3,400 # ffffffffc0202158 <commands+0x6d8>
ffffffffc0200fd0:	00001617          	auipc	a2,0x1
ffffffffc0200fd4:	f9060613          	addi	a2,a2,-112 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc0200fd8:	14200593          	li	a1,322
ffffffffc0200fdc:	00001517          	auipc	a0,0x1
ffffffffc0200fe0:	f9c50513          	addi	a0,a0,-100 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0200fe4:	956ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p1 == p0 + 2);
ffffffffc0200fe8:	00001697          	auipc	a3,0x1
ffffffffc0200fec:	06868693          	addi	a3,a3,104 # ffffffffc0202050 <commands+0x5d0>
ffffffffc0200ff0:	00001617          	auipc	a2,0x1
ffffffffc0200ff4:	f7060613          	addi	a2,a2,-144 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc0200ff8:	12a00593          	li	a1,298
ffffffffc0200ffc:	00001517          	auipc	a0,0x1
ffffffffc0201000:	f7c50513          	addi	a0,a0,-132 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0201004:	936ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p0 != NULL);
ffffffffc0201008:	00001697          	auipc	a3,0x1
ffffffffc020100c:	03868693          	addi	a3,a3,56 # ffffffffc0202040 <commands+0x5c0>
ffffffffc0201010:	00001617          	auipc	a2,0x1
ffffffffc0201014:	f5060613          	addi	a2,a2,-176 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc0201018:	12700593          	li	a1,295
ffffffffc020101c:	00001517          	auipc	a0,0x1
ffffffffc0201020:	f5c50513          	addi	a0,a0,-164 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0201024:	916ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_pages(all_pages + 1) == NULL);
ffffffffc0201028:	00001697          	auipc	a3,0x1
ffffffffc020102c:	ff068693          	addi	a3,a3,-16 # ffffffffc0202018 <commands+0x598>
ffffffffc0201030:	00001617          	auipc	a2,0x1
ffffffffc0201034:	f3060613          	addi	a2,a2,-208 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc0201038:	12300593          	li	a1,291
ffffffffc020103c:	00001517          	auipc	a0,0x1
ffffffffc0201040:	f3c50513          	addi	a0,a0,-196 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0201044:	8f6ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(p1 == p0 + 256);
ffffffffc0201048:	00001697          	auipc	a3,0x1
ffffffffc020104c:	13868693          	addi	a3,a3,312 # ffffffffc0202180 <commands+0x700>
ffffffffc0201050:	00001617          	auipc	a2,0x1
ffffffffc0201054:	f1060613          	addi	a2,a2,-240 # ffffffffc0201f60 <commands+0x4e0>
ffffffffc0201058:	14900593          	li	a1,329
ffffffffc020105c:	00001517          	auipc	a0,0x1
ffffffffc0201060:	f1c50513          	addi	a0,a0,-228 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0201064:	8d6ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0201068 <alloc_pages>:

/*
 * 功能:保存 sstatus寄存器中的中断使能位(SIE)信息并屏蔽中断的功能
 */
static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201068:	100027f3          	csrr	a5,sstatus
ffffffffc020106c:	8b89                	andi	a5,a5,2
ffffffffc020106e:	e799                	bnez	a5,ffffffffc020107c <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201070:	00005797          	auipc	a5,0x5
ffffffffc0201074:	3e07b783          	ld	a5,992(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0201078:	6f9c                	ld	a5,24(a5)
ffffffffc020107a:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc020107c:	1141                	addi	sp,sp,-16
ffffffffc020107e:	e406                	sd	ra,8(sp)
ffffffffc0201080:	e022                	sd	s0,0(sp)
ffffffffc0201082:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201084:	bdaff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201088:	00005797          	auipc	a5,0x5
ffffffffc020108c:	3c87b783          	ld	a5,968(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0201090:	6f9c                	ld	a5,24(a5)
ffffffffc0201092:	8522                	mv	a0,s0
ffffffffc0201094:	9782                	jalr	a5
ffffffffc0201096:	842a                	mv	s0,a0
/*
 * 功能:根据保存的中断使能位信息来使能中断的功能
 */
static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201098:	bc0ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020109c:	60a2                	ld	ra,8(sp)
ffffffffc020109e:	8522                	mv	a0,s0
ffffffffc02010a0:	6402                	ld	s0,0(sp)
ffffffffc02010a2:	0141                	addi	sp,sp,16
ffffffffc02010a4:	8082                	ret

ffffffffc02010a6 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02010a6:	100027f3          	csrr	a5,sstatus
ffffffffc02010aa:	8b89                	andi	a5,a5,2
ffffffffc02010ac:	e799                	bnez	a5,ffffffffc02010ba <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02010ae:	00005797          	auipc	a5,0x5
ffffffffc02010b2:	3a27b783          	ld	a5,930(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc02010b6:	739c                	ld	a5,32(a5)
ffffffffc02010b8:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02010ba:	1101                	addi	sp,sp,-32
ffffffffc02010bc:	ec06                	sd	ra,24(sp)
ffffffffc02010be:	e822                	sd	s0,16(sp)
ffffffffc02010c0:	e426                	sd	s1,8(sp)
ffffffffc02010c2:	842a                	mv	s0,a0
ffffffffc02010c4:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02010c6:	b98ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02010ca:	00005797          	auipc	a5,0x5
ffffffffc02010ce:	3867b783          	ld	a5,902(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc02010d2:	739c                	ld	a5,32(a5)
ffffffffc02010d4:	85a6                	mv	a1,s1
ffffffffc02010d6:	8522                	mv	a0,s0
ffffffffc02010d8:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02010da:	6442                	ld	s0,16(sp)
ffffffffc02010dc:	60e2                	ld	ra,24(sp)
ffffffffc02010de:	64a2                	ld	s1,8(sp)
ffffffffc02010e0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02010e2:	b76ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc02010e6 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02010e6:	100027f3          	csrr	a5,sstatus
ffffffffc02010ea:	8b89                	andi	a5,a5,2
ffffffffc02010ec:	e799                	bnez	a5,ffffffffc02010fa <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02010ee:	00005797          	auipc	a5,0x5
ffffffffc02010f2:	3627b783          	ld	a5,866(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc02010f6:	779c                	ld	a5,40(a5)
ffffffffc02010f8:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02010fa:	1141                	addi	sp,sp,-16
ffffffffc02010fc:	e406                	sd	ra,8(sp)
ffffffffc02010fe:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201100:	b5eff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201104:	00005797          	auipc	a5,0x5
ffffffffc0201108:	34c7b783          	ld	a5,844(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc020110c:	779c                	ld	a5,40(a5)
ffffffffc020110e:	9782                	jalr	a5
ffffffffc0201110:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201112:	b46ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201116:	60a2                	ld	ra,8(sp)
ffffffffc0201118:	8522                	mv	a0,s0
ffffffffc020111a:	6402                	ld	s0,0(sp)
ffffffffc020111c:	0141                	addi	sp,sp,16
ffffffffc020111e:	8082                	ret

ffffffffc0201120 <pmm_init>:
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0201120:	00001797          	auipc	a5,0x1
ffffffffc0201124:	09078793          	addi	a5,a5,144 # ffffffffc02021b0 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201128:	638c                	ld	a1,0(a5)

/* pmm_init - initialize the physical memory management */
/*
 * 功能:初始化物理内存管理器
 */
void pmm_init(void) {
ffffffffc020112a:	1101                	addi	sp,sp,-32
ffffffffc020112c:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020112e:	00001517          	auipc	a0,0x1
ffffffffc0201132:	0ba50513          	addi	a0,a0,186 # ffffffffc02021e8 <buddy_system_pmm_manager+0x38>
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0201136:	00005497          	auipc	s1,0x5
ffffffffc020113a:	31a48493          	addi	s1,s1,794 # ffffffffc0206450 <pmm_manager>
void pmm_init(void) {
ffffffffc020113e:	ec06                	sd	ra,24(sp)
ffffffffc0201140:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0201142:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201144:	f6ffe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0201148:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;  //硬编码 0xFFFFFFFF40000000
ffffffffc020114a:	00005417          	auipc	s0,0x5
ffffffffc020114e:	31e40413          	addi	s0,s0,798 # ffffffffc0206468 <va_pa_offset>
    pmm_manager->init();
ffffffffc0201152:	679c                	ld	a5,8(a5)
ffffffffc0201154:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;  //硬编码 0xFFFFFFFF40000000
ffffffffc0201156:	57f5                	li	a5,-3
ffffffffc0201158:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020115a:	00001517          	auipc	a0,0x1
ffffffffc020115e:	0a650513          	addi	a0,a0,166 # ffffffffc0202200 <buddy_system_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;  //硬编码 0xFFFFFFFF40000000
ffffffffc0201162:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0201164:	f4ffe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201168:	46c5                	li	a3,17
ffffffffc020116a:	06ee                	slli	a3,a3,0x1b
ffffffffc020116c:	40100613          	li	a2,1025
ffffffffc0201170:	16fd                	addi	a3,a3,-1
ffffffffc0201172:	07e005b7          	lui	a1,0x7e00
ffffffffc0201176:	0656                	slli	a2,a2,0x15
ffffffffc0201178:	00001517          	auipc	a0,0x1
ffffffffc020117c:	0a050513          	addi	a0,a0,160 # ffffffffc0202218 <buddy_system_pmm_manager+0x68>
ffffffffc0201180:	f33fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201184:	777d                	lui	a4,0xfffff
ffffffffc0201186:	00006797          	auipc	a5,0x6
ffffffffc020118a:	2f178793          	addi	a5,a5,753 # ffffffffc0207477 <end+0xfff>
ffffffffc020118e:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201190:	00005517          	auipc	a0,0x5
ffffffffc0201194:	2b050513          	addi	a0,a0,688 # ffffffffc0206440 <npage>
ffffffffc0201198:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020119c:	00005597          	auipc	a1,0x5
ffffffffc02011a0:	2ac58593          	addi	a1,a1,684 # ffffffffc0206448 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02011a4:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02011a6:	e19c                	sd	a5,0(a1)
ffffffffc02011a8:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02011aa:	4701                	li	a4,0
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02011ac:	4885                	li	a7,1
ffffffffc02011ae:	fff80837          	lui	a6,0xfff80
ffffffffc02011b2:	a011                	j	ffffffffc02011b6 <pmm_init+0x96>
        SetPageReserved(pages + i); //在kern/mm/memlayout.h定义的(将该bit设为1，为内核保留页面)
ffffffffc02011b4:	619c                	ld	a5,0(a1)
ffffffffc02011b6:	97b6                	add	a5,a5,a3
ffffffffc02011b8:	07a1                	addi	a5,a5,8
ffffffffc02011ba:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02011be:	611c                	ld	a5,0(a0)
ffffffffc02011c0:	0705                	addi	a4,a4,1
ffffffffc02011c2:	02868693          	addi	a3,a3,40
ffffffffc02011c6:	01078633          	add	a2,a5,a6
ffffffffc02011ca:	fec765e3          	bltu	a4,a2,ffffffffc02011b4 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02011ce:	6190                	ld	a2,0(a1)
ffffffffc02011d0:	00279713          	slli	a4,a5,0x2
ffffffffc02011d4:	973e                	add	a4,a4,a5
ffffffffc02011d6:	fec006b7          	lui	a3,0xfec00
ffffffffc02011da:	070e                	slli	a4,a4,0x3
ffffffffc02011dc:	96b2                	add	a3,a3,a2
ffffffffc02011de:	96ba                	add	a3,a3,a4
ffffffffc02011e0:	c0200737          	lui	a4,0xc0200
ffffffffc02011e4:	08e6ef63          	bltu	a3,a4,ffffffffc0201282 <pmm_init+0x162>
ffffffffc02011e8:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc02011ea:	45c5                	li	a1,17
ffffffffc02011ec:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02011ee:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02011f0:	04b6e863          	bltu	a3,a1,ffffffffc0201240 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02011f4:	609c                	ld	a5,0(s1)
ffffffffc02011f6:	7b9c                	ld	a5,48(a5)
ffffffffc02011f8:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02011fa:	00001517          	auipc	a0,0x1
ffffffffc02011fe:	0b650513          	addi	a0,a0,182 # ffffffffc02022b0 <buddy_system_pmm_manager+0x100>
ffffffffc0201202:	eb1fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201206:	00004597          	auipc	a1,0x4
ffffffffc020120a:	dfa58593          	addi	a1,a1,-518 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020120e:	00005797          	auipc	a5,0x5
ffffffffc0201212:	24b7b923          	sd	a1,594(a5) # ffffffffc0206460 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201216:	c02007b7          	lui	a5,0xc0200
ffffffffc020121a:	08f5e063          	bltu	a1,a5,ffffffffc020129a <pmm_init+0x17a>
ffffffffc020121e:	6010                	ld	a2,0(s0)
}
ffffffffc0201220:	6442                	ld	s0,16(sp)
ffffffffc0201222:	60e2                	ld	ra,24(sp)
ffffffffc0201224:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201226:	40c58633          	sub	a2,a1,a2
ffffffffc020122a:	00005797          	auipc	a5,0x5
ffffffffc020122e:	22c7b723          	sd	a2,558(a5) # ffffffffc0206458 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201232:	00001517          	auipc	a0,0x1
ffffffffc0201236:	09e50513          	addi	a0,a0,158 # ffffffffc02022d0 <buddy_system_pmm_manager+0x120>
}
ffffffffc020123a:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020123c:	e77fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201240:	6705                	lui	a4,0x1
ffffffffc0201242:	177d                	addi	a4,a4,-1
ffffffffc0201244:	96ba                	add	a3,a3,a4
ffffffffc0201246:	777d                	lui	a4,0xfffff
ffffffffc0201248:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020124a:	00c6d513          	srli	a0,a3,0xc
ffffffffc020124e:	00f57e63          	bgeu	a0,a5,ffffffffc020126a <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0201252:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201254:	982a                	add	a6,a6,a0
ffffffffc0201256:	00281513          	slli	a0,a6,0x2
ffffffffc020125a:	9542                	add	a0,a0,a6
ffffffffc020125c:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020125e:	8d95                	sub	a1,a1,a3
ffffffffc0201260:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201262:	81b1                	srli	a1,a1,0xc
ffffffffc0201264:	9532                	add	a0,a0,a2
ffffffffc0201266:	9782                	jalr	a5
}
ffffffffc0201268:	b771                	j	ffffffffc02011f4 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc020126a:	00001617          	auipc	a2,0x1
ffffffffc020126e:	01660613          	addi	a2,a2,22 # ffffffffc0202280 <buddy_system_pmm_manager+0xd0>
ffffffffc0201272:	06700593          	li	a1,103
ffffffffc0201276:	00001517          	auipc	a0,0x1
ffffffffc020127a:	02a50513          	addi	a0,a0,42 # ffffffffc02022a0 <buddy_system_pmm_manager+0xf0>
ffffffffc020127e:	ebdfe0ef          	jal	ra,ffffffffc020013a <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201282:	00001617          	auipc	a2,0x1
ffffffffc0201286:	fc660613          	addi	a2,a2,-58 # ffffffffc0202248 <buddy_system_pmm_manager+0x98>
ffffffffc020128a:	07e00593          	li	a1,126
ffffffffc020128e:	00001517          	auipc	a0,0x1
ffffffffc0201292:	fe250513          	addi	a0,a0,-30 # ffffffffc0202270 <buddy_system_pmm_manager+0xc0>
ffffffffc0201296:	ea5fe0ef          	jal	ra,ffffffffc020013a <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020129a:	86ae                	mv	a3,a1
ffffffffc020129c:	00001617          	auipc	a2,0x1
ffffffffc02012a0:	fac60613          	addi	a2,a2,-84 # ffffffffc0202248 <buddy_system_pmm_manager+0x98>
ffffffffc02012a4:	09d00593          	li	a1,157
ffffffffc02012a8:	00001517          	auipc	a0,0x1
ffffffffc02012ac:	fc850513          	addi	a0,a0,-56 # ffffffffc0202270 <buddy_system_pmm_manager+0xc0>
ffffffffc02012b0:	e8bfe0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc02012b4 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02012b4:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02012b6:	e589                	bnez	a1,ffffffffc02012c0 <strnlen+0xc>
ffffffffc02012b8:	a811                	j	ffffffffc02012cc <strnlen+0x18>
        cnt ++;
ffffffffc02012ba:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02012bc:	00f58863          	beq	a1,a5,ffffffffc02012cc <strnlen+0x18>
ffffffffc02012c0:	00f50733          	add	a4,a0,a5
ffffffffc02012c4:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0x3fdf8b88>
ffffffffc02012c8:	fb6d                	bnez	a4,ffffffffc02012ba <strnlen+0x6>
ffffffffc02012ca:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02012cc:	852e                	mv	a0,a1
ffffffffc02012ce:	8082                	ret

ffffffffc02012d0 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02012d0:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02012d4:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02012d8:	cb89                	beqz	a5,ffffffffc02012ea <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02012da:	0505                	addi	a0,a0,1
ffffffffc02012dc:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02012de:	fee789e3          	beq	a5,a4,ffffffffc02012d0 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02012e2:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
=======
ffffffffc0200802 <best_fit_init>:
 * 参数:
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200802:	00006797          	auipc	a5,0x6
ffffffffc0200806:	80e78793          	addi	a5,a5,-2034 # ffffffffc0206010 <free_area>
ffffffffc020080a:	e79c                	sd	a5,8(a5)
ffffffffc020080c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020080e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200812:	8082                	ret

ffffffffc0200814 <best_fit_nr_free_pages>:
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
}
ffffffffc02012e6:	9d19                	subw	a0,a0,a4
ffffffffc02012e8:	8082                	ret
ffffffffc02012ea:	4501                	li	a0,0
ffffffffc02012ec:	bfed                	j	ffffffffc02012e6 <strcmp+0x16>

ffffffffc02012ee <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02012ee:	00054783          	lbu	a5,0(a0)
ffffffffc02012f2:	c799                	beqz	a5,ffffffffc0201300 <strchr+0x12>
        if (*s == c) {
ffffffffc02012f4:	00f58763          	beq	a1,a5,ffffffffc0201302 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02012f8:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02012fc:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02012fe:	fbfd                	bnez	a5,ffffffffc02012f4 <strchr+0x6>
    }
    return NULL;
ffffffffc0201300:	4501                	li	a0,0
}
ffffffffc0201302:	8082                	ret

ffffffffc0201304 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201304:	ca01                	beqz	a2,ffffffffc0201314 <memset+0x10>
ffffffffc0201306:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201308:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020130a:	0785                	addi	a5,a5,1
ffffffffc020130c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201310:	fec79de3          	bne	a5,a2,ffffffffc020130a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
<<<<<<< HEAD
ffffffffc0201314:	8082                	ret

ffffffffc0201316 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201316:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020131a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020131c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201320:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201322:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201326:	f022                	sd	s0,32(sp)
ffffffffc0201328:	ec26                	sd	s1,24(sp)
ffffffffc020132a:	e84a                	sd	s2,16(sp)
ffffffffc020132c:	f406                	sd	ra,40(sp)
ffffffffc020132e:	e44e                	sd	s3,8(sp)
ffffffffc0201330:	84aa                	mv	s1,a0
ffffffffc0201332:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201334:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201338:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020133a:	03067e63          	bgeu	a2,a6,ffffffffc0201376 <printnum+0x60>
ffffffffc020133e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201340:	00805763          	blez	s0,ffffffffc020134e <printnum+0x38>
ffffffffc0201344:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201346:	85ca                	mv	a1,s2
ffffffffc0201348:	854e                	mv	a0,s3
ffffffffc020134a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020134c:	fc65                	bnez	s0,ffffffffc0201344 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020134e:	1a02                	slli	s4,s4,0x20
ffffffffc0201350:	00001797          	auipc	a5,0x1
ffffffffc0201354:	fc078793          	addi	a5,a5,-64 # ffffffffc0202310 <buddy_system_pmm_manager+0x160>
ffffffffc0201358:	020a5a13          	srli	s4,s4,0x20
ffffffffc020135c:	9a3e                	add	s4,s4,a5
}
ffffffffc020135e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201360:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201364:	70a2                	ld	ra,40(sp)
ffffffffc0201366:	69a2                	ld	s3,8(sp)
ffffffffc0201368:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020136a:	85ca                	mv	a1,s2
ffffffffc020136c:	87a6                	mv	a5,s1
}
ffffffffc020136e:	6942                	ld	s2,16(sp)
ffffffffc0201370:	64e2                	ld	s1,24(sp)
ffffffffc0201372:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201374:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201376:	03065633          	divu	a2,a2,a6
ffffffffc020137a:	8722                	mv	a4,s0
ffffffffc020137c:	f9bff0ef          	jal	ra,ffffffffc0201316 <printnum>
ffffffffc0201380:	b7f9                	j	ffffffffc020134e <printnum+0x38>

ffffffffc0201382 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201382:	7119                	addi	sp,sp,-128
ffffffffc0201384:	f4a6                	sd	s1,104(sp)
ffffffffc0201386:	f0ca                	sd	s2,96(sp)
ffffffffc0201388:	ecce                	sd	s3,88(sp)
ffffffffc020138a:	e8d2                	sd	s4,80(sp)
ffffffffc020138c:	e4d6                	sd	s5,72(sp)
ffffffffc020138e:	e0da                	sd	s6,64(sp)
ffffffffc0201390:	fc5e                	sd	s7,56(sp)
ffffffffc0201392:	f06a                	sd	s10,32(sp)
ffffffffc0201394:	fc86                	sd	ra,120(sp)
ffffffffc0201396:	f8a2                	sd	s0,112(sp)
ffffffffc0201398:	f862                	sd	s8,48(sp)
ffffffffc020139a:	f466                	sd	s9,40(sp)
ffffffffc020139c:	ec6e                	sd	s11,24(sp)
ffffffffc020139e:	892a                	mv	s2,a0
ffffffffc02013a0:	84ae                	mv	s1,a1
ffffffffc02013a2:	8d32                	mv	s10,a2
ffffffffc02013a4:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013a6:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02013aa:	5b7d                	li	s6,-1
ffffffffc02013ac:	00001a97          	auipc	s5,0x1
ffffffffc02013b0:	f98a8a93          	addi	s5,s5,-104 # ffffffffc0202344 <buddy_system_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02013b4:	00001b97          	auipc	s7,0x1
ffffffffc02013b8:	16cb8b93          	addi	s7,s7,364 # ffffffffc0202520 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013bc:	000d4503          	lbu	a0,0(s10)
ffffffffc02013c0:	001d0413          	addi	s0,s10,1
ffffffffc02013c4:	01350a63          	beq	a0,s3,ffffffffc02013d8 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02013c8:	c121                	beqz	a0,ffffffffc0201408 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02013ca:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013cc:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02013ce:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013d0:	fff44503          	lbu	a0,-1(s0)
ffffffffc02013d4:	ff351ae3          	bne	a0,s3,ffffffffc02013c8 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013d8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02013dc:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02013e0:	4c81                	li	s9,0
ffffffffc02013e2:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02013e4:	5c7d                	li	s8,-1
ffffffffc02013e6:	5dfd                	li	s11,-1
ffffffffc02013e8:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02013ec:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013ee:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02013f2:	0ff5f593          	zext.b	a1,a1
ffffffffc02013f6:	00140d13          	addi	s10,s0,1
ffffffffc02013fa:	04b56263          	bltu	a0,a1,ffffffffc020143e <vprintfmt+0xbc>
ffffffffc02013fe:	058a                	slli	a1,a1,0x2
ffffffffc0201400:	95d6                	add	a1,a1,s5
ffffffffc0201402:	4194                	lw	a3,0(a1)
ffffffffc0201404:	96d6                	add	a3,a3,s5
ffffffffc0201406:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201408:	70e6                	ld	ra,120(sp)
ffffffffc020140a:	7446                	ld	s0,112(sp)
ffffffffc020140c:	74a6                	ld	s1,104(sp)
ffffffffc020140e:	7906                	ld	s2,96(sp)
ffffffffc0201410:	69e6                	ld	s3,88(sp)
ffffffffc0201412:	6a46                	ld	s4,80(sp)
ffffffffc0201414:	6aa6                	ld	s5,72(sp)
ffffffffc0201416:	6b06                	ld	s6,64(sp)
ffffffffc0201418:	7be2                	ld	s7,56(sp)
ffffffffc020141a:	7c42                	ld	s8,48(sp)
ffffffffc020141c:	7ca2                	ld	s9,40(sp)
ffffffffc020141e:	7d02                	ld	s10,32(sp)
ffffffffc0201420:	6de2                	ld	s11,24(sp)
ffffffffc0201422:	6109                	addi	sp,sp,128
ffffffffc0201424:	8082                	ret
            padc = '0';
ffffffffc0201426:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201428:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020142c:	846a                	mv	s0,s10
ffffffffc020142e:	00140d13          	addi	s10,s0,1
ffffffffc0201432:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201436:	0ff5f593          	zext.b	a1,a1
ffffffffc020143a:	fcb572e3          	bgeu	a0,a1,ffffffffc02013fe <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020143e:	85a6                	mv	a1,s1
ffffffffc0201440:	02500513          	li	a0,37
ffffffffc0201444:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201446:	fff44783          	lbu	a5,-1(s0)
ffffffffc020144a:	8d22                	mv	s10,s0
ffffffffc020144c:	f73788e3          	beq	a5,s3,ffffffffc02013bc <vprintfmt+0x3a>
ffffffffc0201450:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201454:	1d7d                	addi	s10,s10,-1
ffffffffc0201456:	ff379de3          	bne	a5,s3,ffffffffc0201450 <vprintfmt+0xce>
ffffffffc020145a:	b78d                	j	ffffffffc02013bc <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020145c:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201460:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201464:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201466:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020146a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020146e:	02d86463          	bltu	a6,a3,ffffffffc0201496 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201472:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201476:	002c169b          	slliw	a3,s8,0x2
ffffffffc020147a:	0186873b          	addw	a4,a3,s8
ffffffffc020147e:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201482:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201484:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201488:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020148a:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020148e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201492:	fed870e3          	bgeu	a6,a3,ffffffffc0201472 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201496:	f40ddce3          	bgez	s11,ffffffffc02013ee <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020149a:	8de2                	mv	s11,s8
ffffffffc020149c:	5c7d                	li	s8,-1
ffffffffc020149e:	bf81                	j	ffffffffc02013ee <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02014a0:	fffdc693          	not	a3,s11
ffffffffc02014a4:	96fd                	srai	a3,a3,0x3f
ffffffffc02014a6:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014aa:	00144603          	lbu	a2,1(s0)
ffffffffc02014ae:	2d81                	sext.w	s11,s11
ffffffffc02014b0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02014b2:	bf35                	j	ffffffffc02013ee <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02014b4:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014b8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02014bc:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014be:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02014c0:	bfd9                	j	ffffffffc0201496 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02014c2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02014c4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02014c8:	01174463          	blt	a4,a7,ffffffffc02014d0 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02014cc:	1a088e63          	beqz	a7,ffffffffc0201688 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02014d0:	000a3603          	ld	a2,0(s4)
ffffffffc02014d4:	46c1                	li	a3,16
ffffffffc02014d6:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02014d8:	2781                	sext.w	a5,a5
ffffffffc02014da:	876e                	mv	a4,s11
ffffffffc02014dc:	85a6                	mv	a1,s1
ffffffffc02014de:	854a                	mv	a0,s2
ffffffffc02014e0:	e37ff0ef          	jal	ra,ffffffffc0201316 <printnum>
            break;
ffffffffc02014e4:	bde1                	j	ffffffffc02013bc <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02014e6:	000a2503          	lw	a0,0(s4)
ffffffffc02014ea:	85a6                	mv	a1,s1
ffffffffc02014ec:	0a21                	addi	s4,s4,8
ffffffffc02014ee:	9902                	jalr	s2
            break;
ffffffffc02014f0:	b5f1                	j	ffffffffc02013bc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02014f2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02014f4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02014f8:	01174463          	blt	a4,a7,ffffffffc0201500 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02014fc:	18088163          	beqz	a7,ffffffffc020167e <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201500:	000a3603          	ld	a2,0(s4)
ffffffffc0201504:	46a9                	li	a3,10
ffffffffc0201506:	8a2e                	mv	s4,a1
ffffffffc0201508:	bfc1                	j	ffffffffc02014d8 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020150a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020150e:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201510:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201512:	bdf1                	j	ffffffffc02013ee <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201514:	85a6                	mv	a1,s1
ffffffffc0201516:	02500513          	li	a0,37
ffffffffc020151a:	9902                	jalr	s2
            break;
ffffffffc020151c:	b545                	j	ffffffffc02013bc <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020151e:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201522:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201524:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201526:	b5e1                	j	ffffffffc02013ee <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201528:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020152a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020152e:	01174463          	blt	a4,a7,ffffffffc0201536 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201532:	14088163          	beqz	a7,ffffffffc0201674 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201536:	000a3603          	ld	a2,0(s4)
ffffffffc020153a:	46a1                	li	a3,8
ffffffffc020153c:	8a2e                	mv	s4,a1
ffffffffc020153e:	bf69                	j	ffffffffc02014d8 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201540:	03000513          	li	a0,48
ffffffffc0201544:	85a6                	mv	a1,s1
ffffffffc0201546:	e03e                	sd	a5,0(sp)
ffffffffc0201548:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020154a:	85a6                	mv	a1,s1
ffffffffc020154c:	07800513          	li	a0,120
ffffffffc0201550:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201552:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201554:	6782                	ld	a5,0(sp)
ffffffffc0201556:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201558:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020155c:	bfb5                	j	ffffffffc02014d8 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020155e:	000a3403          	ld	s0,0(s4)
ffffffffc0201562:	008a0713          	addi	a4,s4,8
ffffffffc0201566:	e03a                	sd	a4,0(sp)
ffffffffc0201568:	14040263          	beqz	s0,ffffffffc02016ac <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020156c:	0fb05763          	blez	s11,ffffffffc020165a <vprintfmt+0x2d8>
ffffffffc0201570:	02d00693          	li	a3,45
ffffffffc0201574:	0cd79163          	bne	a5,a3,ffffffffc0201636 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201578:	00044783          	lbu	a5,0(s0)
ffffffffc020157c:	0007851b          	sext.w	a0,a5
ffffffffc0201580:	cf85                	beqz	a5,ffffffffc02015b8 <vprintfmt+0x236>
ffffffffc0201582:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201586:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020158a:	000c4563          	bltz	s8,ffffffffc0201594 <vprintfmt+0x212>
ffffffffc020158e:	3c7d                	addiw	s8,s8,-1
ffffffffc0201590:	036c0263          	beq	s8,s6,ffffffffc02015b4 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201594:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201596:	0e0c8e63          	beqz	s9,ffffffffc0201692 <vprintfmt+0x310>
ffffffffc020159a:	3781                	addiw	a5,a5,-32
ffffffffc020159c:	0ef47b63          	bgeu	s0,a5,ffffffffc0201692 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02015a0:	03f00513          	li	a0,63
ffffffffc02015a4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02015a6:	000a4783          	lbu	a5,0(s4)
ffffffffc02015aa:	3dfd                	addiw	s11,s11,-1
ffffffffc02015ac:	0a05                	addi	s4,s4,1
ffffffffc02015ae:	0007851b          	sext.w	a0,a5
ffffffffc02015b2:	ffe1                	bnez	a5,ffffffffc020158a <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02015b4:	01b05963          	blez	s11,ffffffffc02015c6 <vprintfmt+0x244>
ffffffffc02015b8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02015ba:	85a6                	mv	a1,s1
ffffffffc02015bc:	02000513          	li	a0,32
ffffffffc02015c0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02015c2:	fe0d9be3          	bnez	s11,ffffffffc02015b8 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02015c6:	6a02                	ld	s4,0(sp)
ffffffffc02015c8:	bbd5                	j	ffffffffc02013bc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02015ca:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02015cc:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02015d0:	01174463          	blt	a4,a7,ffffffffc02015d8 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02015d4:	08088d63          	beqz	a7,ffffffffc020166e <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02015d8:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02015dc:	0a044d63          	bltz	s0,ffffffffc0201696 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02015e0:	8622                	mv	a2,s0
ffffffffc02015e2:	8a66                	mv	s4,s9
ffffffffc02015e4:	46a9                	li	a3,10
ffffffffc02015e6:	bdcd                	j	ffffffffc02014d8 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02015e8:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02015ec:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02015ee:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02015f0:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02015f4:	8fb5                	xor	a5,a5,a3
ffffffffc02015f6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02015fa:	02d74163          	blt	a4,a3,ffffffffc020161c <vprintfmt+0x29a>
ffffffffc02015fe:	00369793          	slli	a5,a3,0x3
ffffffffc0201602:	97de                	add	a5,a5,s7
ffffffffc0201604:	639c                	ld	a5,0(a5)
ffffffffc0201606:	cb99                	beqz	a5,ffffffffc020161c <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201608:	86be                	mv	a3,a5
ffffffffc020160a:	00001617          	auipc	a2,0x1
ffffffffc020160e:	d3660613          	addi	a2,a2,-714 # ffffffffc0202340 <buddy_system_pmm_manager+0x190>
ffffffffc0201612:	85a6                	mv	a1,s1
ffffffffc0201614:	854a                	mv	a0,s2
ffffffffc0201616:	0ce000ef          	jal	ra,ffffffffc02016e4 <printfmt>
ffffffffc020161a:	b34d                	j	ffffffffc02013bc <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020161c:	00001617          	auipc	a2,0x1
ffffffffc0201620:	d1460613          	addi	a2,a2,-748 # ffffffffc0202330 <buddy_system_pmm_manager+0x180>
ffffffffc0201624:	85a6                	mv	a1,s1
ffffffffc0201626:	854a                	mv	a0,s2
ffffffffc0201628:	0bc000ef          	jal	ra,ffffffffc02016e4 <printfmt>
ffffffffc020162c:	bb41                	j	ffffffffc02013bc <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020162e:	00001417          	auipc	s0,0x1
ffffffffc0201632:	cfa40413          	addi	s0,s0,-774 # ffffffffc0202328 <buddy_system_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201636:	85e2                	mv	a1,s8
ffffffffc0201638:	8522                	mv	a0,s0
ffffffffc020163a:	e43e                	sd	a5,8(sp)
ffffffffc020163c:	c79ff0ef          	jal	ra,ffffffffc02012b4 <strnlen>
ffffffffc0201640:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201644:	01b05b63          	blez	s11,ffffffffc020165a <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201648:	67a2                	ld	a5,8(sp)
ffffffffc020164a:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020164e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201650:	85a6                	mv	a1,s1
ffffffffc0201652:	8552                	mv	a0,s4
ffffffffc0201654:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201656:	fe0d9ce3          	bnez	s11,ffffffffc020164e <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020165a:	00044783          	lbu	a5,0(s0)
ffffffffc020165e:	00140a13          	addi	s4,s0,1
ffffffffc0201662:	0007851b          	sext.w	a0,a5
ffffffffc0201666:	d3a5                	beqz	a5,ffffffffc02015c6 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201668:	05e00413          	li	s0,94
ffffffffc020166c:	bf39                	j	ffffffffc020158a <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020166e:	000a2403          	lw	s0,0(s4)
ffffffffc0201672:	b7ad                	j	ffffffffc02015dc <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201674:	000a6603          	lwu	a2,0(s4)
ffffffffc0201678:	46a1                	li	a3,8
ffffffffc020167a:	8a2e                	mv	s4,a1
ffffffffc020167c:	bdb1                	j	ffffffffc02014d8 <vprintfmt+0x156>
ffffffffc020167e:	000a6603          	lwu	a2,0(s4)
ffffffffc0201682:	46a9                	li	a3,10
ffffffffc0201684:	8a2e                	mv	s4,a1
ffffffffc0201686:	bd89                	j	ffffffffc02014d8 <vprintfmt+0x156>
ffffffffc0201688:	000a6603          	lwu	a2,0(s4)
ffffffffc020168c:	46c1                	li	a3,16
ffffffffc020168e:	8a2e                	mv	s4,a1
ffffffffc0201690:	b5a1                	j	ffffffffc02014d8 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201692:	9902                	jalr	s2
ffffffffc0201694:	bf09                	j	ffffffffc02015a6 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201696:	85a6                	mv	a1,s1
ffffffffc0201698:	02d00513          	li	a0,45
ffffffffc020169c:	e03e                	sd	a5,0(sp)
ffffffffc020169e:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02016a0:	6782                	ld	a5,0(sp)
ffffffffc02016a2:	8a66                	mv	s4,s9
ffffffffc02016a4:	40800633          	neg	a2,s0
ffffffffc02016a8:	46a9                	li	a3,10
ffffffffc02016aa:	b53d                	j	ffffffffc02014d8 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02016ac:	03b05163          	blez	s11,ffffffffc02016ce <vprintfmt+0x34c>
ffffffffc02016b0:	02d00693          	li	a3,45
ffffffffc02016b4:	f6d79de3          	bne	a5,a3,ffffffffc020162e <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02016b8:	00001417          	auipc	s0,0x1
ffffffffc02016bc:	c7040413          	addi	s0,s0,-912 # ffffffffc0202328 <buddy_system_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016c0:	02800793          	li	a5,40
ffffffffc02016c4:	02800513          	li	a0,40
ffffffffc02016c8:	00140a13          	addi	s4,s0,1
ffffffffc02016cc:	bd6d                	j	ffffffffc0201586 <vprintfmt+0x204>
ffffffffc02016ce:	00001a17          	auipc	s4,0x1
ffffffffc02016d2:	c5ba0a13          	addi	s4,s4,-933 # ffffffffc0202329 <buddy_system_pmm_manager+0x179>
ffffffffc02016d6:	02800513          	li	a0,40
ffffffffc02016da:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016de:	05e00413          	li	s0,94
ffffffffc02016e2:	b565                	j	ffffffffc020158a <vprintfmt+0x208>

ffffffffc02016e4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02016e4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02016e6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02016ea:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02016ec:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02016ee:	ec06                	sd	ra,24(sp)
ffffffffc02016f0:	f83a                	sd	a4,48(sp)
ffffffffc02016f2:	fc3e                	sd	a5,56(sp)
ffffffffc02016f4:	e0c2                	sd	a6,64(sp)
ffffffffc02016f6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02016f8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02016fa:	c89ff0ef          	jal	ra,ffffffffc0201382 <vprintfmt>
}
ffffffffc02016fe:	60e2                	ld	ra,24(sp)
ffffffffc0201700:	6161                	addi	sp,sp,80
ffffffffc0201702:	8082                	ret

ffffffffc0201704 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201704:	715d                	addi	sp,sp,-80
ffffffffc0201706:	e486                	sd	ra,72(sp)
ffffffffc0201708:	e0a6                	sd	s1,64(sp)
ffffffffc020170a:	fc4a                	sd	s2,56(sp)
ffffffffc020170c:	f84e                	sd	s3,48(sp)
ffffffffc020170e:	f452                	sd	s4,40(sp)
ffffffffc0201710:	f056                	sd	s5,32(sp)
ffffffffc0201712:	ec5a                	sd	s6,24(sp)
ffffffffc0201714:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201716:	c901                	beqz	a0,ffffffffc0201726 <readline+0x22>
ffffffffc0201718:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020171a:	00001517          	auipc	a0,0x1
ffffffffc020171e:	c2650513          	addi	a0,a0,-986 # ffffffffc0202340 <buddy_system_pmm_manager+0x190>
ffffffffc0201722:	991fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201726:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201728:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020172a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020172c:	4aa9                	li	s5,10
ffffffffc020172e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201730:	00005b97          	auipc	s7,0x5
ffffffffc0201734:	900b8b93          	addi	s7,s7,-1792 # ffffffffc0206030 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201738:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020173c:	9effe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201740:	00054a63          	bltz	a0,ffffffffc0201754 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201744:	00a95a63          	bge	s2,a0,ffffffffc0201758 <readline+0x54>
ffffffffc0201748:	029a5263          	bge	s4,s1,ffffffffc020176c <readline+0x68>
        c = getchar();
ffffffffc020174c:	9dffe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201750:	fe055ae3          	bgez	a0,ffffffffc0201744 <readline+0x40>
            return NULL;
ffffffffc0201754:	4501                	li	a0,0
ffffffffc0201756:	a091                	j	ffffffffc020179a <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201758:	03351463          	bne	a0,s3,ffffffffc0201780 <readline+0x7c>
ffffffffc020175c:	e8a9                	bnez	s1,ffffffffc02017ae <readline+0xaa>
        c = getchar();
ffffffffc020175e:	9cdfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201762:	fe0549e3          	bltz	a0,ffffffffc0201754 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201766:	fea959e3          	bge	s2,a0,ffffffffc0201758 <readline+0x54>
ffffffffc020176a:	4481                	li	s1,0
            cputchar(c);
ffffffffc020176c:	e42a                	sd	a0,8(sp)
ffffffffc020176e:	97bfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201772:	6522                	ld	a0,8(sp)
ffffffffc0201774:	009b87b3          	add	a5,s7,s1
ffffffffc0201778:	2485                	addiw	s1,s1,1
ffffffffc020177a:	00a78023          	sb	a0,0(a5)
ffffffffc020177e:	bf7d                	j	ffffffffc020173c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201780:	01550463          	beq	a0,s5,ffffffffc0201788 <readline+0x84>
ffffffffc0201784:	fb651ce3          	bne	a0,s6,ffffffffc020173c <readline+0x38>
            cputchar(c);
ffffffffc0201788:	961fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc020178c:	00005517          	auipc	a0,0x5
ffffffffc0201790:	8a450513          	addi	a0,a0,-1884 # ffffffffc0206030 <buf>
ffffffffc0201794:	94aa                	add	s1,s1,a0
ffffffffc0201796:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020179a:	60a6                	ld	ra,72(sp)
ffffffffc020179c:	6486                	ld	s1,64(sp)
ffffffffc020179e:	7962                	ld	s2,56(sp)
ffffffffc02017a0:	79c2                	ld	s3,48(sp)
ffffffffc02017a2:	7a22                	ld	s4,40(sp)
ffffffffc02017a4:	7a82                	ld	s5,32(sp)
ffffffffc02017a6:	6b62                	ld	s6,24(sp)
ffffffffc02017a8:	6bc2                	ld	s7,16(sp)
ffffffffc02017aa:	6161                	addi	sp,sp,80
ffffffffc02017ac:	8082                	ret
            cputchar(c);
ffffffffc02017ae:	4521                	li	a0,8
ffffffffc02017b0:	939fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc02017b4:	34fd                	addiw	s1,s1,-1
ffffffffc02017b6:	b759                	j	ffffffffc020173c <readline+0x38>

ffffffffc02017b8 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02017b8:	4781                	li	a5,0
ffffffffc02017ba:	00005717          	auipc	a4,0x5
ffffffffc02017be:	84e73703          	ld	a4,-1970(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02017c2:	88ba                	mv	a7,a4
ffffffffc02017c4:	852a                	mv	a0,a0
ffffffffc02017c6:	85be                	mv	a1,a5
ffffffffc02017c8:	863e                	mv	a2,a5
ffffffffc02017ca:	00000073          	ecall
ffffffffc02017ce:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02017d0:	8082                	ret

ffffffffc02017d2 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02017d2:	4781                	li	a5,0
ffffffffc02017d4:	00005717          	auipc	a4,0x5
ffffffffc02017d8:	c9c73703          	ld	a4,-868(a4) # ffffffffc0206470 <SBI_SET_TIMER>
ffffffffc02017dc:	88ba                	mv	a7,a4
ffffffffc02017de:	852a                	mv	a0,a0
ffffffffc02017e0:	85be                	mv	a1,a5
ffffffffc02017e2:	863e                	mv	a2,a5
ffffffffc02017e4:	00000073          	ecall
ffffffffc02017e8:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02017ea:	8082                	ret

ffffffffc02017ec <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02017ec:	4501                	li	a0,0
ffffffffc02017ee:	00005797          	auipc	a5,0x5
ffffffffc02017f2:	8127b783          	ld	a5,-2030(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc02017f6:	88be                	mv	a7,a5
ffffffffc02017f8:	852a                	mv	a0,a0
ffffffffc02017fa:	85aa                	mv	a1,a0
ffffffffc02017fc:	862a                	mv	a2,a0
ffffffffc02017fe:	00000073          	ecall
ffffffffc0201802:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201804:	2501                	sext.w	a0,a0
ffffffffc0201806:	8082                	ret
=======
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	80c56503          	lwu	a0,-2036(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc020081c:	8082                	ret

ffffffffc020081e <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc020081e:	c14d                	beqz	a0,ffffffffc02008c0 <best_fit_alloc_pages+0xa2>
    if (n > nr_free) {
ffffffffc0200820:	00005617          	auipc	a2,0x5
ffffffffc0200824:	7f060613          	addi	a2,a2,2032 # ffffffffc0206010 <free_area>
ffffffffc0200828:	01062803          	lw	a6,16(a2)
ffffffffc020082c:	86aa                	mv	a3,a0
ffffffffc020082e:	02081793          	slli	a5,a6,0x20
ffffffffc0200832:	9381                	srli	a5,a5,0x20
ffffffffc0200834:	08a7e463          	bltu	a5,a0,ffffffffc02008bc <best_fit_alloc_pages+0x9e>
 * 参数: 
 * @listelm:    当前节点(链表头)
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200838:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1;
ffffffffc020083a:	0018059b          	addiw	a1,a6,1
ffffffffc020083e:	1582                	slli	a1,a1,0x20
ffffffffc0200840:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL;
ffffffffc0200842:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) 
ffffffffc0200844:	06c78b63          	beq	a5,a2,ffffffffc02008ba <best_fit_alloc_pages+0x9c>
        if (p->property >= n && p->property < min_size) 
ffffffffc0200848:	ff87e703          	lwu	a4,-8(a5)
ffffffffc020084c:	00d76763          	bltu	a4,a3,ffffffffc020085a <best_fit_alloc_pages+0x3c>
ffffffffc0200850:	00b77563          	bgeu	a4,a1,ffffffffc020085a <best_fit_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc0200854:	fe878513          	addi	a0,a5,-24
ffffffffc0200858:	85ba                	mv	a1,a4
ffffffffc020085a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) 
ffffffffc020085c:	fec796e3          	bne	a5,a2,ffffffffc0200848 <best_fit_alloc_pages+0x2a>
    if (page != NULL) {
ffffffffc0200860:	cd29                	beqz	a0,ffffffffc02008ba <best_fit_alloc_pages+0x9c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200862:	711c                	ld	a5,32(a0)
 * 参数:  
 * @listelm:    当前节点(链表头)
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200864:	6d18                	ld	a4,24(a0)
        if (page->property > n) {
ffffffffc0200866:	490c                	lw	a1,16(a0)
            p->property = page->property - n;
ffffffffc0200868:	0006889b          	sext.w	a7,a3
 * 功能:通过使上一个和下一个节点相互连接(指向)来删除链表节点。
 * 注意:这仅用于内部列表操作，我们已经知道上一个/下一个节点了！
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020086c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020086e:	e398                	sd	a4,0(a5)
        if (page->property > n) {
ffffffffc0200870:	02059793          	slli	a5,a1,0x20
ffffffffc0200874:	9381                	srli	a5,a5,0x20
ffffffffc0200876:	02f6f863          	bgeu	a3,a5,ffffffffc02008a6 <best_fit_alloc_pages+0x88>
            struct Page *p = page + n;
ffffffffc020087a:	00269793          	slli	a5,a3,0x2
ffffffffc020087e:	97b6                	add	a5,a5,a3
ffffffffc0200880:	078e                	slli	a5,a5,0x3
ffffffffc0200882:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc0200884:	411585bb          	subw	a1,a1,a7
ffffffffc0200888:	cb8c                	sw	a1,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020088a:	4689                	li	a3,2
ffffffffc020088c:	00878593          	addi	a1,a5,8
ffffffffc0200890:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200894:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc0200896:	01878593          	addi	a1,a5,24
        nr_free -= n;
ffffffffc020089a:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc020089e:	e28c                	sd	a1,0(a3)
ffffffffc02008a0:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc02008a2:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc02008a4:	ef98                	sd	a4,24(a5)
ffffffffc02008a6:	4118083b          	subw	a6,a6,a7
ffffffffc02008aa:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02008ae:	57f5                	li	a5,-3
ffffffffc02008b0:	00850713          	addi	a4,a0,8
ffffffffc02008b4:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc02008b8:	8082                	ret
}
ffffffffc02008ba:	8082                	ret
        return NULL;
ffffffffc02008bc:	4501                	li	a0,0
ffffffffc02008be:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02008c0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02008c2:	00002697          	auipc	a3,0x2
ffffffffc02008c6:	83e68693          	addi	a3,a3,-1986 # ffffffffc0202100 <commands+0x4f8>
ffffffffc02008ca:	00002617          	auipc	a2,0x2
ffffffffc02008ce:	83e60613          	addi	a2,a2,-1986 # ffffffffc0202108 <commands+0x500>
ffffffffc02008d2:	07300593          	li	a1,115
ffffffffc02008d6:	00002517          	auipc	a0,0x2
ffffffffc02008da:	84a50513          	addi	a0,a0,-1974 # ffffffffc0202120 <commands+0x518>
best_fit_alloc_pages(size_t n) {
ffffffffc02008de:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02008e0:	acdff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02008e4 <best_fit_check>:
}

// LAB2: 下面的代码用于检查Best-Fit分配算法
// 注意：您不应该更改basic_check、default_check函数！
static void
best_fit_check(void) {
ffffffffc02008e4:	715d                	addi	sp,sp,-80
ffffffffc02008e6:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc02008e8:	00005417          	auipc	s0,0x5
ffffffffc02008ec:	72840413          	addi	s0,s0,1832 # ffffffffc0206010 <free_area>
ffffffffc02008f0:	641c                	ld	a5,8(s0)
ffffffffc02008f2:	e486                	sd	ra,72(sp)
ffffffffc02008f4:	fc26                	sd	s1,56(sp)
ffffffffc02008f6:	f84a                	sd	s2,48(sp)
ffffffffc02008f8:	f44e                	sd	s3,40(sp)
ffffffffc02008fa:	f052                	sd	s4,32(sp)
ffffffffc02008fc:	ec56                	sd	s5,24(sp)
ffffffffc02008fe:	e85a                	sd	s6,16(sp)
ffffffffc0200900:	e45e                	sd	s7,8(sp)
ffffffffc0200902:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200904:	26878b63          	beq	a5,s0,ffffffffc0200b7a <best_fit_check+0x296>
    int count = 0, total = 0;
ffffffffc0200908:	4481                	li	s1,0
ffffffffc020090a:	4901                	li	s2,0
 * 功能:返回某个二进制位的值 
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020090c:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200910:	8b09                	andi	a4,a4,2
ffffffffc0200912:	26070863          	beqz	a4,ffffffffc0200b82 <best_fit_check+0x29e>
        count ++, total += p->property;
ffffffffc0200916:	ff87a703          	lw	a4,-8(a5)
ffffffffc020091a:	679c                	ld	a5,8(a5)
ffffffffc020091c:	2905                	addiw	s2,s2,1
ffffffffc020091e:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200920:	fe8796e3          	bne	a5,s0,ffffffffc020090c <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200924:	89a6                	mv	s3,s1
ffffffffc0200926:	167000ef          	jal	ra,ffffffffc020128c <nr_free_pages>
ffffffffc020092a:	33351c63          	bne	a0,s3,ffffffffc0200c62 <best_fit_check+0x37e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020092e:	4505                	li	a0,1
ffffffffc0200930:	0df000ef          	jal	ra,ffffffffc020120e <alloc_pages>
ffffffffc0200934:	8a2a                	mv	s4,a0
ffffffffc0200936:	36050663          	beqz	a0,ffffffffc0200ca2 <best_fit_check+0x3be>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020093a:	4505                	li	a0,1
ffffffffc020093c:	0d3000ef          	jal	ra,ffffffffc020120e <alloc_pages>
ffffffffc0200940:	89aa                	mv	s3,a0
ffffffffc0200942:	34050063          	beqz	a0,ffffffffc0200c82 <best_fit_check+0x39e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200946:	4505                	li	a0,1
ffffffffc0200948:	0c7000ef          	jal	ra,ffffffffc020120e <alloc_pages>
ffffffffc020094c:	8aaa                	mv	s5,a0
ffffffffc020094e:	2c050a63          	beqz	a0,ffffffffc0200c22 <best_fit_check+0x33e>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200952:	253a0863          	beq	s4,s3,ffffffffc0200ba2 <best_fit_check+0x2be>
ffffffffc0200956:	24aa0663          	beq	s4,a0,ffffffffc0200ba2 <best_fit_check+0x2be>
ffffffffc020095a:	24a98463          	beq	s3,a0,ffffffffc0200ba2 <best_fit_check+0x2be>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020095e:	000a2783          	lw	a5,0(s4)
ffffffffc0200962:	26079063          	bnez	a5,ffffffffc0200bc2 <best_fit_check+0x2de>
ffffffffc0200966:	0009a783          	lw	a5,0(s3)
ffffffffc020096a:	24079c63          	bnez	a5,ffffffffc0200bc2 <best_fit_check+0x2de>
ffffffffc020096e:	411c                	lw	a5,0(a0)
ffffffffc0200970:	24079963          	bnez	a5,ffffffffc0200bc2 <best_fit_check+0x2de>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200974:	00006797          	auipc	a5,0x6
ffffffffc0200978:	acc7b783          	ld	a5,-1332(a5) # ffffffffc0206440 <pages>
ffffffffc020097c:	40fa0733          	sub	a4,s4,a5
ffffffffc0200980:	870d                	srai	a4,a4,0x3
ffffffffc0200982:	00002597          	auipc	a1,0x2
ffffffffc0200986:	e6e5b583          	ld	a1,-402(a1) # ffffffffc02027f0 <error_string+0x38>
ffffffffc020098a:	02b70733          	mul	a4,a4,a1
ffffffffc020098e:	00002617          	auipc	a2,0x2
ffffffffc0200992:	e6a63603          	ld	a2,-406(a2) # ffffffffc02027f8 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200996:	00006697          	auipc	a3,0x6
ffffffffc020099a:	aa26b683          	ld	a3,-1374(a3) # ffffffffc0206438 <npage>
ffffffffc020099e:	06b2                	slli	a3,a3,0xc
ffffffffc02009a0:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02009a2:	0732                	slli	a4,a4,0xc
ffffffffc02009a4:	22d77f63          	bgeu	a4,a3,ffffffffc0200be2 <best_fit_check+0x2fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009a8:	40f98733          	sub	a4,s3,a5
ffffffffc02009ac:	870d                	srai	a4,a4,0x3
ffffffffc02009ae:	02b70733          	mul	a4,a4,a1
ffffffffc02009b2:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02009b4:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02009b6:	3ed77663          	bgeu	a4,a3,ffffffffc0200da2 <best_fit_check+0x4be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009ba:	40f507b3          	sub	a5,a0,a5
ffffffffc02009be:	878d                	srai	a5,a5,0x3
ffffffffc02009c0:	02b787b3          	mul	a5,a5,a1
ffffffffc02009c4:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02009c6:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02009c8:	3ad7fd63          	bgeu	a5,a3,ffffffffc0200d82 <best_fit_check+0x49e>
    assert(alloc_page() == NULL);
ffffffffc02009cc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02009ce:	00043c03          	ld	s8,0(s0)
ffffffffc02009d2:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc02009d6:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc02009da:	e400                	sd	s0,8(s0)
ffffffffc02009dc:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc02009de:	00005797          	auipc	a5,0x5
ffffffffc02009e2:	6407a123          	sw	zero,1602(a5) # ffffffffc0206020 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02009e6:	029000ef          	jal	ra,ffffffffc020120e <alloc_pages>
ffffffffc02009ea:	36051c63          	bnez	a0,ffffffffc0200d62 <best_fit_check+0x47e>
    free_page(p0);
ffffffffc02009ee:	4585                	li	a1,1
ffffffffc02009f0:	8552                	mv	a0,s4
ffffffffc02009f2:	05b000ef          	jal	ra,ffffffffc020124c <free_pages>
    free_page(p1);
ffffffffc02009f6:	4585                	li	a1,1
ffffffffc02009f8:	854e                	mv	a0,s3
ffffffffc02009fa:	053000ef          	jal	ra,ffffffffc020124c <free_pages>
    free_page(p2);
ffffffffc02009fe:	4585                	li	a1,1
ffffffffc0200a00:	8556                	mv	a0,s5
ffffffffc0200a02:	04b000ef          	jal	ra,ffffffffc020124c <free_pages>
    assert(nr_free == 3);
ffffffffc0200a06:	4818                	lw	a4,16(s0)
ffffffffc0200a08:	478d                	li	a5,3
ffffffffc0200a0a:	32f71c63          	bne	a4,a5,ffffffffc0200d42 <best_fit_check+0x45e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a0e:	4505                	li	a0,1
ffffffffc0200a10:	7fe000ef          	jal	ra,ffffffffc020120e <alloc_pages>
ffffffffc0200a14:	89aa                	mv	s3,a0
ffffffffc0200a16:	30050663          	beqz	a0,ffffffffc0200d22 <best_fit_check+0x43e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a1a:	4505                	li	a0,1
ffffffffc0200a1c:	7f2000ef          	jal	ra,ffffffffc020120e <alloc_pages>
ffffffffc0200a20:	8aaa                	mv	s5,a0
ffffffffc0200a22:	2e050063          	beqz	a0,ffffffffc0200d02 <best_fit_check+0x41e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a26:	4505                	li	a0,1
ffffffffc0200a28:	7e6000ef          	jal	ra,ffffffffc020120e <alloc_pages>
ffffffffc0200a2c:	8a2a                	mv	s4,a0
ffffffffc0200a2e:	2a050a63          	beqz	a0,ffffffffc0200ce2 <best_fit_check+0x3fe>
    assert(alloc_page() == NULL);
ffffffffc0200a32:	4505                	li	a0,1
ffffffffc0200a34:	7da000ef          	jal	ra,ffffffffc020120e <alloc_pages>
ffffffffc0200a38:	28051563          	bnez	a0,ffffffffc0200cc2 <best_fit_check+0x3de>
    free_page(p0);
ffffffffc0200a3c:	4585                	li	a1,1
ffffffffc0200a3e:	854e                	mv	a0,s3
ffffffffc0200a40:	00d000ef          	jal	ra,ffffffffc020124c <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200a44:	641c                	ld	a5,8(s0)
ffffffffc0200a46:	1a878e63          	beq	a5,s0,ffffffffc0200c02 <best_fit_check+0x31e>
    assert((p = alloc_page()) == p0);
ffffffffc0200a4a:	4505                	li	a0,1
ffffffffc0200a4c:	7c2000ef          	jal	ra,ffffffffc020120e <alloc_pages>
ffffffffc0200a50:	52a99963          	bne	s3,a0,ffffffffc0200f82 <best_fit_check+0x69e>
    assert(alloc_page() == NULL);
ffffffffc0200a54:	4505                	li	a0,1
ffffffffc0200a56:	7b8000ef          	jal	ra,ffffffffc020120e <alloc_pages>
ffffffffc0200a5a:	50051463          	bnez	a0,ffffffffc0200f62 <best_fit_check+0x67e>
    assert(nr_free == 0);
ffffffffc0200a5e:	481c                	lw	a5,16(s0)
ffffffffc0200a60:	4e079163          	bnez	a5,ffffffffc0200f42 <best_fit_check+0x65e>
    free_page(p);
ffffffffc0200a64:	854e                	mv	a0,s3
ffffffffc0200a66:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200a68:	01843023          	sd	s8,0(s0)
ffffffffc0200a6c:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200a70:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200a74:	7d8000ef          	jal	ra,ffffffffc020124c <free_pages>
    free_page(p1);
ffffffffc0200a78:	4585                	li	a1,1
ffffffffc0200a7a:	8556                	mv	a0,s5
ffffffffc0200a7c:	7d0000ef          	jal	ra,ffffffffc020124c <free_pages>
    free_page(p2);
ffffffffc0200a80:	4585                	li	a1,1
ffffffffc0200a82:	8552                	mv	a0,s4
ffffffffc0200a84:	7c8000ef          	jal	ra,ffffffffc020124c <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200a88:	4515                	li	a0,5
ffffffffc0200a8a:	784000ef          	jal	ra,ffffffffc020120e <alloc_pages>
ffffffffc0200a8e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200a90:	48050963          	beqz	a0,ffffffffc0200f22 <best_fit_check+0x63e>
ffffffffc0200a94:	651c                	ld	a5,8(a0)
ffffffffc0200a96:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200a98:	8b85                	andi	a5,a5,1
ffffffffc0200a9a:	46079463          	bnez	a5,ffffffffc0200f02 <best_fit_check+0x61e>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200a9e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200aa0:	00043a83          	ld	s5,0(s0)
ffffffffc0200aa4:	00843a03          	ld	s4,8(s0)
ffffffffc0200aa8:	e000                	sd	s0,0(s0)
ffffffffc0200aaa:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200aac:	762000ef          	jal	ra,ffffffffc020120e <alloc_pages>
ffffffffc0200ab0:	42051963          	bnez	a0,ffffffffc0200ee2 <best_fit_check+0x5fe>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200ab4:	4589                	li	a1,2
ffffffffc0200ab6:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200aba:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200abe:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200ac2:	00005797          	auipc	a5,0x5
ffffffffc0200ac6:	5407af23          	sw	zero,1374(a5) # ffffffffc0206020 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200aca:	782000ef          	jal	ra,ffffffffc020124c <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200ace:	8562                	mv	a0,s8
ffffffffc0200ad0:	4585                	li	a1,1
ffffffffc0200ad2:	77a000ef          	jal	ra,ffffffffc020124c <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200ad6:	4511                	li	a0,4
ffffffffc0200ad8:	736000ef          	jal	ra,ffffffffc020120e <alloc_pages>
ffffffffc0200adc:	3e051363          	bnez	a0,ffffffffc0200ec2 <best_fit_check+0x5de>
ffffffffc0200ae0:	0309b783          	ld	a5,48(s3)
ffffffffc0200ae4:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200ae6:	8b85                	andi	a5,a5,1
ffffffffc0200ae8:	3a078d63          	beqz	a5,ffffffffc0200ea2 <best_fit_check+0x5be>
ffffffffc0200aec:	0389a703          	lw	a4,56(s3)
ffffffffc0200af0:	4789                	li	a5,2
ffffffffc0200af2:	3af71863          	bne	a4,a5,ffffffffc0200ea2 <best_fit_check+0x5be>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200af6:	4505                	li	a0,1
ffffffffc0200af8:	716000ef          	jal	ra,ffffffffc020120e <alloc_pages>
ffffffffc0200afc:	8baa                	mv	s7,a0
ffffffffc0200afe:	38050263          	beqz	a0,ffffffffc0200e82 <best_fit_check+0x59e>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200b02:	4509                	li	a0,2
ffffffffc0200b04:	70a000ef          	jal	ra,ffffffffc020120e <alloc_pages>
ffffffffc0200b08:	34050d63          	beqz	a0,ffffffffc0200e62 <best_fit_check+0x57e>
    assert(p0 + 4 == p1);
ffffffffc0200b0c:	337c1b63          	bne	s8,s7,ffffffffc0200e42 <best_fit_check+0x55e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200b10:	854e                	mv	a0,s3
ffffffffc0200b12:	4595                	li	a1,5
ffffffffc0200b14:	738000ef          	jal	ra,ffffffffc020124c <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200b18:	4515                	li	a0,5
ffffffffc0200b1a:	6f4000ef          	jal	ra,ffffffffc020120e <alloc_pages>
ffffffffc0200b1e:	89aa                	mv	s3,a0
ffffffffc0200b20:	30050163          	beqz	a0,ffffffffc0200e22 <best_fit_check+0x53e>
    assert(alloc_page() == NULL);
ffffffffc0200b24:	4505                	li	a0,1
ffffffffc0200b26:	6e8000ef          	jal	ra,ffffffffc020120e <alloc_pages>
ffffffffc0200b2a:	2c051c63          	bnez	a0,ffffffffc0200e02 <best_fit_check+0x51e>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200b2e:	481c                	lw	a5,16(s0)
ffffffffc0200b30:	2a079963          	bnez	a5,ffffffffc0200de2 <best_fit_check+0x4fe>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200b34:	4595                	li	a1,5
ffffffffc0200b36:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200b38:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0200b3c:	01543023          	sd	s5,0(s0)
ffffffffc0200b40:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0200b44:	708000ef          	jal	ra,ffffffffc020124c <free_pages>
    return listelm->next;
ffffffffc0200b48:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b4a:	00878963          	beq	a5,s0,ffffffffc0200b5c <best_fit_check+0x278>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200b4e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b52:	679c                	ld	a5,8(a5)
ffffffffc0200b54:	397d                	addiw	s2,s2,-1
ffffffffc0200b56:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b58:	fe879be3          	bne	a5,s0,ffffffffc0200b4e <best_fit_check+0x26a>
    }
    assert(count == 0);
ffffffffc0200b5c:	26091363          	bnez	s2,ffffffffc0200dc2 <best_fit_check+0x4de>
    assert(total == 0);
ffffffffc0200b60:	e0ed                	bnez	s1,ffffffffc0200c42 <best_fit_check+0x35e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200b62:	60a6                	ld	ra,72(sp)
ffffffffc0200b64:	6406                	ld	s0,64(sp)
ffffffffc0200b66:	74e2                	ld	s1,56(sp)
ffffffffc0200b68:	7942                	ld	s2,48(sp)
ffffffffc0200b6a:	79a2                	ld	s3,40(sp)
ffffffffc0200b6c:	7a02                	ld	s4,32(sp)
ffffffffc0200b6e:	6ae2                	ld	s5,24(sp)
ffffffffc0200b70:	6b42                	ld	s6,16(sp)
ffffffffc0200b72:	6ba2                	ld	s7,8(sp)
ffffffffc0200b74:	6c02                	ld	s8,0(sp)
ffffffffc0200b76:	6161                	addi	sp,sp,80
ffffffffc0200b78:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b7a:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200b7c:	4481                	li	s1,0
ffffffffc0200b7e:	4901                	li	s2,0
ffffffffc0200b80:	b35d                	j	ffffffffc0200926 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200b82:	00001697          	auipc	a3,0x1
ffffffffc0200b86:	5b668693          	addi	a3,a3,1462 # ffffffffc0202138 <commands+0x530>
ffffffffc0200b8a:	00001617          	auipc	a2,0x1
ffffffffc0200b8e:	57e60613          	addi	a2,a2,1406 # ffffffffc0202108 <commands+0x500>
ffffffffc0200b92:	12400593          	li	a1,292
ffffffffc0200b96:	00001517          	auipc	a0,0x1
ffffffffc0200b9a:	58a50513          	addi	a0,a0,1418 # ffffffffc0202120 <commands+0x518>
ffffffffc0200b9e:	80fff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ba2:	00001697          	auipc	a3,0x1
ffffffffc0200ba6:	62668693          	addi	a3,a3,1574 # ffffffffc02021c8 <commands+0x5c0>
ffffffffc0200baa:	00001617          	auipc	a2,0x1
ffffffffc0200bae:	55e60613          	addi	a2,a2,1374 # ffffffffc0202108 <commands+0x500>
ffffffffc0200bb2:	0f000593          	li	a1,240
ffffffffc0200bb6:	00001517          	auipc	a0,0x1
ffffffffc0200bba:	56a50513          	addi	a0,a0,1386 # ffffffffc0202120 <commands+0x518>
ffffffffc0200bbe:	feeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200bc2:	00001697          	auipc	a3,0x1
ffffffffc0200bc6:	62e68693          	addi	a3,a3,1582 # ffffffffc02021f0 <commands+0x5e8>
ffffffffc0200bca:	00001617          	auipc	a2,0x1
ffffffffc0200bce:	53e60613          	addi	a2,a2,1342 # ffffffffc0202108 <commands+0x500>
ffffffffc0200bd2:	0f100593          	li	a1,241
ffffffffc0200bd6:	00001517          	auipc	a0,0x1
ffffffffc0200bda:	54a50513          	addi	a0,a0,1354 # ffffffffc0202120 <commands+0x518>
ffffffffc0200bde:	fceff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200be2:	00001697          	auipc	a3,0x1
ffffffffc0200be6:	64e68693          	addi	a3,a3,1614 # ffffffffc0202230 <commands+0x628>
ffffffffc0200bea:	00001617          	auipc	a2,0x1
ffffffffc0200bee:	51e60613          	addi	a2,a2,1310 # ffffffffc0202108 <commands+0x500>
ffffffffc0200bf2:	0f300593          	li	a1,243
ffffffffc0200bf6:	00001517          	auipc	a0,0x1
ffffffffc0200bfa:	52a50513          	addi	a0,a0,1322 # ffffffffc0202120 <commands+0x518>
ffffffffc0200bfe:	faeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c02:	00001697          	auipc	a3,0x1
ffffffffc0200c06:	6b668693          	addi	a3,a3,1718 # ffffffffc02022b8 <commands+0x6b0>
ffffffffc0200c0a:	00001617          	auipc	a2,0x1
ffffffffc0200c0e:	4fe60613          	addi	a2,a2,1278 # ffffffffc0202108 <commands+0x500>
ffffffffc0200c12:	10c00593          	li	a1,268
ffffffffc0200c16:	00001517          	auipc	a0,0x1
ffffffffc0200c1a:	50a50513          	addi	a0,a0,1290 # ffffffffc0202120 <commands+0x518>
ffffffffc0200c1e:	f8eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c22:	00001697          	auipc	a3,0x1
ffffffffc0200c26:	58668693          	addi	a3,a3,1414 # ffffffffc02021a8 <commands+0x5a0>
ffffffffc0200c2a:	00001617          	auipc	a2,0x1
ffffffffc0200c2e:	4de60613          	addi	a2,a2,1246 # ffffffffc0202108 <commands+0x500>
ffffffffc0200c32:	0ee00593          	li	a1,238
ffffffffc0200c36:	00001517          	auipc	a0,0x1
ffffffffc0200c3a:	4ea50513          	addi	a0,a0,1258 # ffffffffc0202120 <commands+0x518>
ffffffffc0200c3e:	f6eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200c42:	00001697          	auipc	a3,0x1
ffffffffc0200c46:	7a668693          	addi	a3,a3,1958 # ffffffffc02023e8 <commands+0x7e0>
ffffffffc0200c4a:	00001617          	auipc	a2,0x1
ffffffffc0200c4e:	4be60613          	addi	a2,a2,1214 # ffffffffc0202108 <commands+0x500>
ffffffffc0200c52:	16600593          	li	a1,358
ffffffffc0200c56:	00001517          	auipc	a0,0x1
ffffffffc0200c5a:	4ca50513          	addi	a0,a0,1226 # ffffffffc0202120 <commands+0x518>
ffffffffc0200c5e:	f4eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200c62:	00001697          	auipc	a3,0x1
ffffffffc0200c66:	4e668693          	addi	a3,a3,1254 # ffffffffc0202148 <commands+0x540>
ffffffffc0200c6a:	00001617          	auipc	a2,0x1
ffffffffc0200c6e:	49e60613          	addi	a2,a2,1182 # ffffffffc0202108 <commands+0x500>
ffffffffc0200c72:	12700593          	li	a1,295
ffffffffc0200c76:	00001517          	auipc	a0,0x1
ffffffffc0200c7a:	4aa50513          	addi	a0,a0,1194 # ffffffffc0202120 <commands+0x518>
ffffffffc0200c7e:	f2eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c82:	00001697          	auipc	a3,0x1
ffffffffc0200c86:	50668693          	addi	a3,a3,1286 # ffffffffc0202188 <commands+0x580>
ffffffffc0200c8a:	00001617          	auipc	a2,0x1
ffffffffc0200c8e:	47e60613          	addi	a2,a2,1150 # ffffffffc0202108 <commands+0x500>
ffffffffc0200c92:	0ed00593          	li	a1,237
ffffffffc0200c96:	00001517          	auipc	a0,0x1
ffffffffc0200c9a:	48a50513          	addi	a0,a0,1162 # ffffffffc0202120 <commands+0x518>
ffffffffc0200c9e:	f0eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ca2:	00001697          	auipc	a3,0x1
ffffffffc0200ca6:	4c668693          	addi	a3,a3,1222 # ffffffffc0202168 <commands+0x560>
ffffffffc0200caa:	00001617          	auipc	a2,0x1
ffffffffc0200cae:	45e60613          	addi	a2,a2,1118 # ffffffffc0202108 <commands+0x500>
ffffffffc0200cb2:	0ec00593          	li	a1,236
ffffffffc0200cb6:	00001517          	auipc	a0,0x1
ffffffffc0200cba:	46a50513          	addi	a0,a0,1130 # ffffffffc0202120 <commands+0x518>
ffffffffc0200cbe:	eeeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200cc2:	00001697          	auipc	a3,0x1
ffffffffc0200cc6:	5ce68693          	addi	a3,a3,1486 # ffffffffc0202290 <commands+0x688>
ffffffffc0200cca:	00001617          	auipc	a2,0x1
ffffffffc0200cce:	43e60613          	addi	a2,a2,1086 # ffffffffc0202108 <commands+0x500>
ffffffffc0200cd2:	10900593          	li	a1,265
ffffffffc0200cd6:	00001517          	auipc	a0,0x1
ffffffffc0200cda:	44a50513          	addi	a0,a0,1098 # ffffffffc0202120 <commands+0x518>
ffffffffc0200cde:	eceff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ce2:	00001697          	auipc	a3,0x1
ffffffffc0200ce6:	4c668693          	addi	a3,a3,1222 # ffffffffc02021a8 <commands+0x5a0>
ffffffffc0200cea:	00001617          	auipc	a2,0x1
ffffffffc0200cee:	41e60613          	addi	a2,a2,1054 # ffffffffc0202108 <commands+0x500>
ffffffffc0200cf2:	10700593          	li	a1,263
ffffffffc0200cf6:	00001517          	auipc	a0,0x1
ffffffffc0200cfa:	42a50513          	addi	a0,a0,1066 # ffffffffc0202120 <commands+0x518>
ffffffffc0200cfe:	eaeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d02:	00001697          	auipc	a3,0x1
ffffffffc0200d06:	48668693          	addi	a3,a3,1158 # ffffffffc0202188 <commands+0x580>
ffffffffc0200d0a:	00001617          	auipc	a2,0x1
ffffffffc0200d0e:	3fe60613          	addi	a2,a2,1022 # ffffffffc0202108 <commands+0x500>
ffffffffc0200d12:	10600593          	li	a1,262
ffffffffc0200d16:	00001517          	auipc	a0,0x1
ffffffffc0200d1a:	40a50513          	addi	a0,a0,1034 # ffffffffc0202120 <commands+0x518>
ffffffffc0200d1e:	e8eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d22:	00001697          	auipc	a3,0x1
ffffffffc0200d26:	44668693          	addi	a3,a3,1094 # ffffffffc0202168 <commands+0x560>
ffffffffc0200d2a:	00001617          	auipc	a2,0x1
ffffffffc0200d2e:	3de60613          	addi	a2,a2,990 # ffffffffc0202108 <commands+0x500>
ffffffffc0200d32:	10500593          	li	a1,261
ffffffffc0200d36:	00001517          	auipc	a0,0x1
ffffffffc0200d3a:	3ea50513          	addi	a0,a0,1002 # ffffffffc0202120 <commands+0x518>
ffffffffc0200d3e:	e6eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200d42:	00001697          	auipc	a3,0x1
ffffffffc0200d46:	56668693          	addi	a3,a3,1382 # ffffffffc02022a8 <commands+0x6a0>
ffffffffc0200d4a:	00001617          	auipc	a2,0x1
ffffffffc0200d4e:	3be60613          	addi	a2,a2,958 # ffffffffc0202108 <commands+0x500>
ffffffffc0200d52:	10300593          	li	a1,259
ffffffffc0200d56:	00001517          	auipc	a0,0x1
ffffffffc0200d5a:	3ca50513          	addi	a0,a0,970 # ffffffffc0202120 <commands+0x518>
ffffffffc0200d5e:	e4eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d62:	00001697          	auipc	a3,0x1
ffffffffc0200d66:	52e68693          	addi	a3,a3,1326 # ffffffffc0202290 <commands+0x688>
ffffffffc0200d6a:	00001617          	auipc	a2,0x1
ffffffffc0200d6e:	39e60613          	addi	a2,a2,926 # ffffffffc0202108 <commands+0x500>
ffffffffc0200d72:	0fe00593          	li	a1,254
ffffffffc0200d76:	00001517          	auipc	a0,0x1
ffffffffc0200d7a:	3aa50513          	addi	a0,a0,938 # ffffffffc0202120 <commands+0x518>
ffffffffc0200d7e:	e2eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200d82:	00001697          	auipc	a3,0x1
ffffffffc0200d86:	4ee68693          	addi	a3,a3,1262 # ffffffffc0202270 <commands+0x668>
ffffffffc0200d8a:	00001617          	auipc	a2,0x1
ffffffffc0200d8e:	37e60613          	addi	a2,a2,894 # ffffffffc0202108 <commands+0x500>
ffffffffc0200d92:	0f500593          	li	a1,245
ffffffffc0200d96:	00001517          	auipc	a0,0x1
ffffffffc0200d9a:	38a50513          	addi	a0,a0,906 # ffffffffc0202120 <commands+0x518>
ffffffffc0200d9e:	e0eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200da2:	00001697          	auipc	a3,0x1
ffffffffc0200da6:	4ae68693          	addi	a3,a3,1198 # ffffffffc0202250 <commands+0x648>
ffffffffc0200daa:	00001617          	auipc	a2,0x1
ffffffffc0200dae:	35e60613          	addi	a2,a2,862 # ffffffffc0202108 <commands+0x500>
ffffffffc0200db2:	0f400593          	li	a1,244
ffffffffc0200db6:	00001517          	auipc	a0,0x1
ffffffffc0200dba:	36a50513          	addi	a0,a0,874 # ffffffffc0202120 <commands+0x518>
ffffffffc0200dbe:	deeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200dc2:	00001697          	auipc	a3,0x1
ffffffffc0200dc6:	61668693          	addi	a3,a3,1558 # ffffffffc02023d8 <commands+0x7d0>
ffffffffc0200dca:	00001617          	auipc	a2,0x1
ffffffffc0200dce:	33e60613          	addi	a2,a2,830 # ffffffffc0202108 <commands+0x500>
ffffffffc0200dd2:	16500593          	li	a1,357
ffffffffc0200dd6:	00001517          	auipc	a0,0x1
ffffffffc0200dda:	34a50513          	addi	a0,a0,842 # ffffffffc0202120 <commands+0x518>
ffffffffc0200dde:	dceff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200de2:	00001697          	auipc	a3,0x1
ffffffffc0200de6:	50e68693          	addi	a3,a3,1294 # ffffffffc02022f0 <commands+0x6e8>
ffffffffc0200dea:	00001617          	auipc	a2,0x1
ffffffffc0200dee:	31e60613          	addi	a2,a2,798 # ffffffffc0202108 <commands+0x500>
ffffffffc0200df2:	15a00593          	li	a1,346
ffffffffc0200df6:	00001517          	auipc	a0,0x1
ffffffffc0200dfa:	32a50513          	addi	a0,a0,810 # ffffffffc0202120 <commands+0x518>
ffffffffc0200dfe:	daeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e02:	00001697          	auipc	a3,0x1
ffffffffc0200e06:	48e68693          	addi	a3,a3,1166 # ffffffffc0202290 <commands+0x688>
ffffffffc0200e0a:	00001617          	auipc	a2,0x1
ffffffffc0200e0e:	2fe60613          	addi	a2,a2,766 # ffffffffc0202108 <commands+0x500>
ffffffffc0200e12:	15400593          	li	a1,340
ffffffffc0200e16:	00001517          	auipc	a0,0x1
ffffffffc0200e1a:	30a50513          	addi	a0,a0,778 # ffffffffc0202120 <commands+0x518>
ffffffffc0200e1e:	d8eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e22:	00001697          	auipc	a3,0x1
ffffffffc0200e26:	59668693          	addi	a3,a3,1430 # ffffffffc02023b8 <commands+0x7b0>
ffffffffc0200e2a:	00001617          	auipc	a2,0x1
ffffffffc0200e2e:	2de60613          	addi	a2,a2,734 # ffffffffc0202108 <commands+0x500>
ffffffffc0200e32:	15300593          	li	a1,339
ffffffffc0200e36:	00001517          	auipc	a0,0x1
ffffffffc0200e3a:	2ea50513          	addi	a0,a0,746 # ffffffffc0202120 <commands+0x518>
ffffffffc0200e3e:	d6eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200e42:	00001697          	auipc	a3,0x1
ffffffffc0200e46:	56668693          	addi	a3,a3,1382 # ffffffffc02023a8 <commands+0x7a0>
ffffffffc0200e4a:	00001617          	auipc	a2,0x1
ffffffffc0200e4e:	2be60613          	addi	a2,a2,702 # ffffffffc0202108 <commands+0x500>
ffffffffc0200e52:	14b00593          	li	a1,331
ffffffffc0200e56:	00001517          	auipc	a0,0x1
ffffffffc0200e5a:	2ca50513          	addi	a0,a0,714 # ffffffffc0202120 <commands+0x518>
ffffffffc0200e5e:	d4eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200e62:	00001697          	auipc	a3,0x1
ffffffffc0200e66:	52e68693          	addi	a3,a3,1326 # ffffffffc0202390 <commands+0x788>
ffffffffc0200e6a:	00001617          	auipc	a2,0x1
ffffffffc0200e6e:	29e60613          	addi	a2,a2,670 # ffffffffc0202108 <commands+0x500>
ffffffffc0200e72:	14a00593          	li	a1,330
ffffffffc0200e76:	00001517          	auipc	a0,0x1
ffffffffc0200e7a:	2aa50513          	addi	a0,a0,682 # ffffffffc0202120 <commands+0x518>
ffffffffc0200e7e:	d2eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200e82:	00001697          	auipc	a3,0x1
ffffffffc0200e86:	4ee68693          	addi	a3,a3,1262 # ffffffffc0202370 <commands+0x768>
ffffffffc0200e8a:	00001617          	auipc	a2,0x1
ffffffffc0200e8e:	27e60613          	addi	a2,a2,638 # ffffffffc0202108 <commands+0x500>
ffffffffc0200e92:	14900593          	li	a1,329
ffffffffc0200e96:	00001517          	auipc	a0,0x1
ffffffffc0200e9a:	28a50513          	addi	a0,a0,650 # ffffffffc0202120 <commands+0x518>
ffffffffc0200e9e:	d0eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200ea2:	00001697          	auipc	a3,0x1
ffffffffc0200ea6:	49e68693          	addi	a3,a3,1182 # ffffffffc0202340 <commands+0x738>
ffffffffc0200eaa:	00001617          	auipc	a2,0x1
ffffffffc0200eae:	25e60613          	addi	a2,a2,606 # ffffffffc0202108 <commands+0x500>
ffffffffc0200eb2:	14700593          	li	a1,327
ffffffffc0200eb6:	00001517          	auipc	a0,0x1
ffffffffc0200eba:	26a50513          	addi	a0,a0,618 # ffffffffc0202120 <commands+0x518>
ffffffffc0200ebe:	ceeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200ec2:	00001697          	auipc	a3,0x1
ffffffffc0200ec6:	46668693          	addi	a3,a3,1126 # ffffffffc0202328 <commands+0x720>
ffffffffc0200eca:	00001617          	auipc	a2,0x1
ffffffffc0200ece:	23e60613          	addi	a2,a2,574 # ffffffffc0202108 <commands+0x500>
ffffffffc0200ed2:	14600593          	li	a1,326
ffffffffc0200ed6:	00001517          	auipc	a0,0x1
ffffffffc0200eda:	24a50513          	addi	a0,a0,586 # ffffffffc0202120 <commands+0x518>
ffffffffc0200ede:	cceff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ee2:	00001697          	auipc	a3,0x1
ffffffffc0200ee6:	3ae68693          	addi	a3,a3,942 # ffffffffc0202290 <commands+0x688>
ffffffffc0200eea:	00001617          	auipc	a2,0x1
ffffffffc0200eee:	21e60613          	addi	a2,a2,542 # ffffffffc0202108 <commands+0x500>
ffffffffc0200ef2:	13a00593          	li	a1,314
ffffffffc0200ef6:	00001517          	auipc	a0,0x1
ffffffffc0200efa:	22a50513          	addi	a0,a0,554 # ffffffffc0202120 <commands+0x518>
ffffffffc0200efe:	caeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f02:	00001697          	auipc	a3,0x1
ffffffffc0200f06:	40e68693          	addi	a3,a3,1038 # ffffffffc0202310 <commands+0x708>
ffffffffc0200f0a:	00001617          	auipc	a2,0x1
ffffffffc0200f0e:	1fe60613          	addi	a2,a2,510 # ffffffffc0202108 <commands+0x500>
ffffffffc0200f12:	13100593          	li	a1,305
ffffffffc0200f16:	00001517          	auipc	a0,0x1
ffffffffc0200f1a:	20a50513          	addi	a0,a0,522 # ffffffffc0202120 <commands+0x518>
ffffffffc0200f1e:	c8eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200f22:	00001697          	auipc	a3,0x1
ffffffffc0200f26:	3de68693          	addi	a3,a3,990 # ffffffffc0202300 <commands+0x6f8>
ffffffffc0200f2a:	00001617          	auipc	a2,0x1
ffffffffc0200f2e:	1de60613          	addi	a2,a2,478 # ffffffffc0202108 <commands+0x500>
ffffffffc0200f32:	13000593          	li	a1,304
ffffffffc0200f36:	00001517          	auipc	a0,0x1
ffffffffc0200f3a:	1ea50513          	addi	a0,a0,490 # ffffffffc0202120 <commands+0x518>
ffffffffc0200f3e:	c6eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200f42:	00001697          	auipc	a3,0x1
ffffffffc0200f46:	3ae68693          	addi	a3,a3,942 # ffffffffc02022f0 <commands+0x6e8>
ffffffffc0200f4a:	00001617          	auipc	a2,0x1
ffffffffc0200f4e:	1be60613          	addi	a2,a2,446 # ffffffffc0202108 <commands+0x500>
ffffffffc0200f52:	11200593          	li	a1,274
ffffffffc0200f56:	00001517          	auipc	a0,0x1
ffffffffc0200f5a:	1ca50513          	addi	a0,a0,458 # ffffffffc0202120 <commands+0x518>
ffffffffc0200f5e:	c4eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f62:	00001697          	auipc	a3,0x1
ffffffffc0200f66:	32e68693          	addi	a3,a3,814 # ffffffffc0202290 <commands+0x688>
ffffffffc0200f6a:	00001617          	auipc	a2,0x1
ffffffffc0200f6e:	19e60613          	addi	a2,a2,414 # ffffffffc0202108 <commands+0x500>
ffffffffc0200f72:	11000593          	li	a1,272
ffffffffc0200f76:	00001517          	auipc	a0,0x1
ffffffffc0200f7a:	1aa50513          	addi	a0,a0,426 # ffffffffc0202120 <commands+0x518>
ffffffffc0200f7e:	c2eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f82:	00001697          	auipc	a3,0x1
ffffffffc0200f86:	34e68693          	addi	a3,a3,846 # ffffffffc02022d0 <commands+0x6c8>
ffffffffc0200f8a:	00001617          	auipc	a2,0x1
ffffffffc0200f8e:	17e60613          	addi	a2,a2,382 # ffffffffc0202108 <commands+0x500>
ffffffffc0200f92:	10f00593          	li	a1,271
ffffffffc0200f96:	00001517          	auipc	a0,0x1
ffffffffc0200f9a:	18a50513          	addi	a0,a0,394 # ffffffffc0202120 <commands+0x518>
ffffffffc0200f9e:	c0eff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200fa2 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0200fa2:	1141                	addi	sp,sp,-16
ffffffffc0200fa4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200fa6:	14058a63          	beqz	a1,ffffffffc02010fa <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0200faa:	00259693          	slli	a3,a1,0x2
ffffffffc0200fae:	96ae                	add	a3,a3,a1
ffffffffc0200fb0:	068e                	slli	a3,a3,0x3
ffffffffc0200fb2:	96aa                	add	a3,a3,a0
ffffffffc0200fb4:	87aa                	mv	a5,a0
ffffffffc0200fb6:	02d50263          	beq	a0,a3,ffffffffc0200fda <best_fit_free_pages+0x38>
ffffffffc0200fba:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200fbc:	8b05                	andi	a4,a4,1
ffffffffc0200fbe:	10071e63          	bnez	a4,ffffffffc02010da <best_fit_free_pages+0x138>
ffffffffc0200fc2:	6798                	ld	a4,8(a5)
ffffffffc0200fc4:	8b09                	andi	a4,a4,2
ffffffffc0200fc6:	10071a63          	bnez	a4,ffffffffc02010da <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc0200fca:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200fce:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200fd2:	02878793          	addi	a5,a5,40
ffffffffc0200fd6:	fed792e3          	bne	a5,a3,ffffffffc0200fba <best_fit_free_pages+0x18>
    base->property = n;      //设置当前页块的属性为释放的页块数
ffffffffc0200fda:	2581                	sext.w	a1,a1
ffffffffc0200fdc:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);   //将当前页块标记为已分配状态
ffffffffc0200fde:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200fe2:	4789                	li	a5,2
ffffffffc0200fe4:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;            //最后增加nr_free的值
ffffffffc0200fe8:	00005697          	auipc	a3,0x5
ffffffffc0200fec:	02868693          	addi	a3,a3,40 # ffffffffc0206010 <free_area>
ffffffffc0200ff0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0200ff2:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0200ff4:	01850613          	addi	a2,a0,24
    nr_free += n;            //最后增加nr_free的值
ffffffffc0200ff8:	9db9                	addw	a1,a1,a4
ffffffffc0200ffa:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0200ffc:	0ad78863          	beq	a5,a3,ffffffffc02010ac <best_fit_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0201000:	fe878713          	addi	a4,a5,-24
ffffffffc0201004:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201008:	4581                	li	a1,0
            if (base < page) {
ffffffffc020100a:	00e56a63          	bltu	a0,a4,ffffffffc020101e <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc020100e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201010:	06d70263          	beq	a4,a3,ffffffffc0201074 <best_fit_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201014:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201016:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020101a:	fee57ae3          	bgeu	a0,a4,ffffffffc020100e <best_fit_free_pages+0x6c>
ffffffffc020101e:	c199                	beqz	a1,ffffffffc0201024 <best_fit_free_pages+0x82>
ffffffffc0201020:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201024:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201026:	e390                	sd	a2,0(a5)
ffffffffc0201028:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020102a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020102c:	ed18                	sd	a4,24(a0)
    if (le != &free_list) 
ffffffffc020102e:	02d70063          	beq	a4,a3,ffffffffc020104e <best_fit_free_pages+0xac>
        if (p + p->property == base)        //1、判断前面的空闲页块是否与当前页块是连续的，如果是连续的，则将当前页块合并到前面的空闲页块中
ffffffffc0201032:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201036:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base)        //1、判断前面的空闲页块是否与当前页块是连续的，如果是连续的，则将当前页块合并到前面的空闲页块中
ffffffffc020103a:	02081613          	slli	a2,a6,0x20
ffffffffc020103e:	9201                	srli	a2,a2,0x20
ffffffffc0201040:	00261793          	slli	a5,a2,0x2
ffffffffc0201044:	97b2                	add	a5,a5,a2
ffffffffc0201046:	078e                	slli	a5,a5,0x3
ffffffffc0201048:	97ae                	add	a5,a5,a1
ffffffffc020104a:	02f50f63          	beq	a0,a5,ffffffffc0201088 <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc020104e:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc0201050:	00d70f63          	beq	a4,a3,ffffffffc020106e <best_fit_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201054:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0201056:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc020105a:	02059613          	slli	a2,a1,0x20
ffffffffc020105e:	9201                	srli	a2,a2,0x20
ffffffffc0201060:	00261793          	slli	a5,a2,0x2
ffffffffc0201064:	97b2                	add	a5,a5,a2
ffffffffc0201066:	078e                	slli	a5,a5,0x3
ffffffffc0201068:	97aa                	add	a5,a5,a0
ffffffffc020106a:	04f68863          	beq	a3,a5,ffffffffc02010ba <best_fit_free_pages+0x118>
}
ffffffffc020106e:	60a2                	ld	ra,8(sp)
ffffffffc0201070:	0141                	addi	sp,sp,16
ffffffffc0201072:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201074:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201076:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201078:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020107a:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020107c:	02d70563          	beq	a4,a3,ffffffffc02010a6 <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201080:	8832                	mv	a6,a2
ffffffffc0201082:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201084:	87ba                	mv	a5,a4
ffffffffc0201086:	bf41                	j	ffffffffc0201016 <best_fit_free_pages+0x74>
            p->property += base->property;  //2、首先更新前一个空闲页块的大小，加上当前页块的大小
ffffffffc0201088:	491c                	lw	a5,16(a0)
ffffffffc020108a:	0107883b          	addw	a6,a5,a6
ffffffffc020108e:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201092:	57f5                	li	a5,-3
ffffffffc0201094:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201098:	6d10                	ld	a2,24(a0)
ffffffffc020109a:	711c                	ld	a5,32(a0)
            base = p;                       //5、将指针指向前一个空闲页块，以便继续检查合并后的连续空闲页块
ffffffffc020109c:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc020109e:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02010a0:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02010a2:	e390                	sd	a2,0(a5)
ffffffffc02010a4:	b775                	j	ffffffffc0201050 <best_fit_free_pages+0xae>
ffffffffc02010a6:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010a8:	873e                	mv	a4,a5
ffffffffc02010aa:	b761                	j	ffffffffc0201032 <best_fit_free_pages+0x90>
}
ffffffffc02010ac:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02010ae:	e390                	sd	a2,0(a5)
ffffffffc02010b0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02010b2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010b4:	ed1c                	sd	a5,24(a0)
ffffffffc02010b6:	0141                	addi	sp,sp,16
ffffffffc02010b8:	8082                	ret
            base->property += p->property;
ffffffffc02010ba:	ff872783          	lw	a5,-8(a4)
ffffffffc02010be:	ff070693          	addi	a3,a4,-16
ffffffffc02010c2:	9dbd                	addw	a1,a1,a5
ffffffffc02010c4:	c90c                	sw	a1,16(a0)
ffffffffc02010c6:	57f5                	li	a5,-3
ffffffffc02010c8:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02010cc:	6314                	ld	a3,0(a4)
ffffffffc02010ce:	671c                	ld	a5,8(a4)
}
ffffffffc02010d0:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02010d2:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02010d4:	e394                	sd	a3,0(a5)
ffffffffc02010d6:	0141                	addi	sp,sp,16
ffffffffc02010d8:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02010da:	00001697          	auipc	a3,0x1
ffffffffc02010de:	31e68693          	addi	a3,a3,798 # ffffffffc02023f8 <commands+0x7f0>
ffffffffc02010e2:	00001617          	auipc	a2,0x1
ffffffffc02010e6:	02660613          	addi	a2,a2,38 # ffffffffc0202108 <commands+0x500>
ffffffffc02010ea:	0a400593          	li	a1,164
ffffffffc02010ee:	00001517          	auipc	a0,0x1
ffffffffc02010f2:	03250513          	addi	a0,a0,50 # ffffffffc0202120 <commands+0x518>
ffffffffc02010f6:	ab6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02010fa:	00001697          	auipc	a3,0x1
ffffffffc02010fe:	00668693          	addi	a3,a3,6 # ffffffffc0202100 <commands+0x4f8>
ffffffffc0201102:	00001617          	auipc	a2,0x1
ffffffffc0201106:	00660613          	addi	a2,a2,6 # ffffffffc0202108 <commands+0x500>
ffffffffc020110a:	0a100593          	li	a1,161
ffffffffc020110e:	00001517          	auipc	a0,0x1
ffffffffc0201112:	01250513          	addi	a0,a0,18 # ffffffffc0202120 <commands+0x518>
ffffffffc0201116:	a96ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020111a <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc020111a:	1141                	addi	sp,sp,-16
ffffffffc020111c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020111e:	c9e1                	beqz	a1,ffffffffc02011ee <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0201120:	00259693          	slli	a3,a1,0x2
ffffffffc0201124:	96ae                	add	a3,a3,a1
ffffffffc0201126:	068e                	slli	a3,a3,0x3
ffffffffc0201128:	96aa                	add	a3,a3,a0
ffffffffc020112a:	87aa                	mv	a5,a0
ffffffffc020112c:	00d50f63          	beq	a0,a3,ffffffffc020114a <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201130:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201132:	8b05                	andi	a4,a4,1
ffffffffc0201134:	cf49                	beqz	a4,ffffffffc02011ce <best_fit_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0201136:	0007a823          	sw	zero,16(a5)
ffffffffc020113a:	0007b423          	sd	zero,8(a5)
ffffffffc020113e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201142:	02878793          	addi	a5,a5,40
ffffffffc0201146:	fed795e3          	bne	a5,a3,ffffffffc0201130 <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc020114a:	2581                	sext.w	a1,a1
ffffffffc020114c:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020114e:	4789                	li	a5,2
ffffffffc0201150:	00850713          	addi	a4,a0,8
ffffffffc0201154:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201158:	00005697          	auipc	a3,0x5
ffffffffc020115c:	eb868693          	addi	a3,a3,-328 # ffffffffc0206010 <free_area>
ffffffffc0201160:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201162:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201164:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201168:	9db9                	addw	a1,a1,a4
ffffffffc020116a:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020116c:	04d78a63          	beq	a5,a3,ffffffffc02011c0 <best_fit_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0201170:	fe878713          	addi	a4,a5,-24
ffffffffc0201174:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201178:	4581                	li	a1,0
            if (base < page) //找到第一个大于base的页，将base插入到它前面，并退出循环
ffffffffc020117a:	00e56a63          	bltu	a0,a4,ffffffffc020118e <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc020117e:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list) //若已经到达链表结尾，将base插入到链表尾部
ffffffffc0201180:	02d70263          	beq	a4,a3,ffffffffc02011a4 <best_fit_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0201184:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201186:	fe878713          	addi	a4,a5,-24
            if (base < page) //找到第一个大于base的页，将base插入到它前面，并退出循环
ffffffffc020118a:	fee57ae3          	bgeu	a0,a4,ffffffffc020117e <best_fit_init_memmap+0x64>
ffffffffc020118e:	c199                	beqz	a1,ffffffffc0201194 <best_fit_init_memmap+0x7a>
ffffffffc0201190:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201194:	6398                	ld	a4,0(a5)
}
ffffffffc0201196:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201198:	e390                	sd	a2,0(a5)
ffffffffc020119a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020119c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020119e:	ed18                	sd	a4,24(a0)
ffffffffc02011a0:	0141                	addi	sp,sp,16
ffffffffc02011a2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02011a4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02011a6:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02011a8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02011aa:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) //遍历从小到达有序列表（le和page代表有序列表的元素），并插入base
ffffffffc02011ac:	00d70663          	beq	a4,a3,ffffffffc02011b8 <best_fit_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02011b0:	8832                	mv	a6,a2
ffffffffc02011b2:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02011b4:	87ba                	mv	a5,a4
ffffffffc02011b6:	bfc1                	j	ffffffffc0201186 <best_fit_init_memmap+0x6c>
}
ffffffffc02011b8:	60a2                	ld	ra,8(sp)
ffffffffc02011ba:	e290                	sd	a2,0(a3)
ffffffffc02011bc:	0141                	addi	sp,sp,16
ffffffffc02011be:	8082                	ret
ffffffffc02011c0:	60a2                	ld	ra,8(sp)
ffffffffc02011c2:	e390                	sd	a2,0(a5)
ffffffffc02011c4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02011c6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011c8:	ed1c                	sd	a5,24(a0)
ffffffffc02011ca:	0141                	addi	sp,sp,16
ffffffffc02011cc:	8082                	ret
        assert(PageReserved(p));
ffffffffc02011ce:	00001697          	auipc	a3,0x1
ffffffffc02011d2:	25268693          	addi	a3,a3,594 # ffffffffc0202420 <commands+0x818>
ffffffffc02011d6:	00001617          	auipc	a2,0x1
ffffffffc02011da:	f3260613          	addi	a2,a2,-206 # ffffffffc0202108 <commands+0x500>
ffffffffc02011de:	04a00593          	li	a1,74
ffffffffc02011e2:	00001517          	auipc	a0,0x1
ffffffffc02011e6:	f3e50513          	addi	a0,a0,-194 # ffffffffc0202120 <commands+0x518>
ffffffffc02011ea:	9c2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02011ee:	00001697          	auipc	a3,0x1
ffffffffc02011f2:	f1268693          	addi	a3,a3,-238 # ffffffffc0202100 <commands+0x4f8>
ffffffffc02011f6:	00001617          	auipc	a2,0x1
ffffffffc02011fa:	f1260613          	addi	a2,a2,-238 # ffffffffc0202108 <commands+0x500>
ffffffffc02011fe:	04700593          	li	a1,71
ffffffffc0201202:	00001517          	auipc	a0,0x1
ffffffffc0201206:	f1e50513          	addi	a0,a0,-226 # ffffffffc0202120 <commands+0x518>
ffffffffc020120a:	9a2ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020120e <alloc_pages>:

/*
 * 功能:保存 sstatus寄存器中的中断使能位(SIE)信息并屏蔽中断的功能
 */
static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020120e:	100027f3          	csrr	a5,sstatus
ffffffffc0201212:	8b89                	andi	a5,a5,2
ffffffffc0201214:	e799                	bnez	a5,ffffffffc0201222 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201216:	00005797          	auipc	a5,0x5
ffffffffc020121a:	2327b783          	ld	a5,562(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020121e:	6f9c                	ld	a5,24(a5)
ffffffffc0201220:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0201222:	1141                	addi	sp,sp,-16
ffffffffc0201224:	e406                	sd	ra,8(sp)
ffffffffc0201226:	e022                	sd	s0,0(sp)
ffffffffc0201228:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020122a:	a34ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020122e:	00005797          	auipc	a5,0x5
ffffffffc0201232:	21a7b783          	ld	a5,538(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201236:	6f9c                	ld	a5,24(a5)
ffffffffc0201238:	8522                	mv	a0,s0
ffffffffc020123a:	9782                	jalr	a5
ffffffffc020123c:	842a                	mv	s0,a0
/*
 * 功能:根据保存的中断使能位信息来使能中断的功能
 */
static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020123e:	a1aff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201242:	60a2                	ld	ra,8(sp)
ffffffffc0201244:	8522                	mv	a0,s0
ffffffffc0201246:	6402                	ld	s0,0(sp)
ffffffffc0201248:	0141                	addi	sp,sp,16
ffffffffc020124a:	8082                	ret

ffffffffc020124c <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020124c:	100027f3          	csrr	a5,sstatus
ffffffffc0201250:	8b89                	andi	a5,a5,2
ffffffffc0201252:	e799                	bnez	a5,ffffffffc0201260 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201254:	00005797          	auipc	a5,0x5
ffffffffc0201258:	1f47b783          	ld	a5,500(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020125c:	739c                	ld	a5,32(a5)
ffffffffc020125e:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201260:	1101                	addi	sp,sp,-32
ffffffffc0201262:	ec06                	sd	ra,24(sp)
ffffffffc0201264:	e822                	sd	s0,16(sp)
ffffffffc0201266:	e426                	sd	s1,8(sp)
ffffffffc0201268:	842a                	mv	s0,a0
ffffffffc020126a:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020126c:	9f2ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201270:	00005797          	auipc	a5,0x5
ffffffffc0201274:	1d87b783          	ld	a5,472(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201278:	739c                	ld	a5,32(a5)
ffffffffc020127a:	85a6                	mv	a1,s1
ffffffffc020127c:	8522                	mv	a0,s0
ffffffffc020127e:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201280:	6442                	ld	s0,16(sp)
ffffffffc0201282:	60e2                	ld	ra,24(sp)
ffffffffc0201284:	64a2                	ld	s1,8(sp)
ffffffffc0201286:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201288:	9d0ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc020128c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020128c:	100027f3          	csrr	a5,sstatus
ffffffffc0201290:	8b89                	andi	a5,a5,2
ffffffffc0201292:	e799                	bnez	a5,ffffffffc02012a0 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201294:	00005797          	auipc	a5,0x5
ffffffffc0201298:	1b47b783          	ld	a5,436(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020129c:	779c                	ld	a5,40(a5)
ffffffffc020129e:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02012a0:	1141                	addi	sp,sp,-16
ffffffffc02012a2:	e406                	sd	ra,8(sp)
ffffffffc02012a4:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02012a6:	9b8ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02012aa:	00005797          	auipc	a5,0x5
ffffffffc02012ae:	19e7b783          	ld	a5,414(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02012b2:	779c                	ld	a5,40(a5)
ffffffffc02012b4:	9782                	jalr	a5
ffffffffc02012b6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02012b8:	9a0ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02012bc:	60a2                	ld	ra,8(sp)
ffffffffc02012be:	8522                	mv	a0,s0
ffffffffc02012c0:	6402                	ld	s0,0(sp)
ffffffffc02012c2:	0141                	addi	sp,sp,16
ffffffffc02012c4:	8082                	ret

ffffffffc02012c6 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012c6:	00001797          	auipc	a5,0x1
ffffffffc02012ca:	18278793          	addi	a5,a5,386 # ffffffffc0202448 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012ce:	638c                	ld	a1,0(a5)

/* pmm_init - initialize the physical memory management */
/*
 * 功能:初始化物理内存管理器
 */
void pmm_init(void) {
ffffffffc02012d0:	1101                	addi	sp,sp,-32
ffffffffc02012d2:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012d4:	00001517          	auipc	a0,0x1
ffffffffc02012d8:	1ac50513          	addi	a0,a0,428 # ffffffffc0202480 <best_fit_pmm_manager+0x38>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012dc:	00005497          	auipc	s1,0x5
ffffffffc02012e0:	16c48493          	addi	s1,s1,364 # ffffffffc0206448 <pmm_manager>
void pmm_init(void) {
ffffffffc02012e4:	ec06                	sd	ra,24(sp)
ffffffffc02012e6:	e822                	sd	s0,16(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012e8:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012ea:	dc9fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc02012ee:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;  //硬编码 0xFFFFFFFF40000000
ffffffffc02012f0:	00005417          	auipc	s0,0x5
ffffffffc02012f4:	17040413          	addi	s0,s0,368 # ffffffffc0206460 <va_pa_offset>
    pmm_manager->init();
ffffffffc02012f8:	679c                	ld	a5,8(a5)
ffffffffc02012fa:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;  //硬编码 0xFFFFFFFF40000000
ffffffffc02012fc:	57f5                	li	a5,-3
ffffffffc02012fe:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201300:	00001517          	auipc	a0,0x1
ffffffffc0201304:	19850513          	addi	a0,a0,408 # ffffffffc0202498 <best_fit_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;  //硬编码 0xFFFFFFFF40000000
ffffffffc0201308:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc020130a:	da9fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020130e:	46c5                	li	a3,17
ffffffffc0201310:	06ee                	slli	a3,a3,0x1b
ffffffffc0201312:	40100613          	li	a2,1025
ffffffffc0201316:	16fd                	addi	a3,a3,-1
ffffffffc0201318:	07e005b7          	lui	a1,0x7e00
ffffffffc020131c:	0656                	slli	a2,a2,0x15
ffffffffc020131e:	00001517          	auipc	a0,0x1
ffffffffc0201322:	19250513          	addi	a0,a0,402 # ffffffffc02024b0 <best_fit_pmm_manager+0x68>
ffffffffc0201326:	d8dfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020132a:	777d                	lui	a4,0xfffff
ffffffffc020132c:	00006797          	auipc	a5,0x6
ffffffffc0201330:	14378793          	addi	a5,a5,323 # ffffffffc020746f <end+0xfff>
ffffffffc0201334:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201336:	00005517          	auipc	a0,0x5
ffffffffc020133a:	10250513          	addi	a0,a0,258 # ffffffffc0206438 <npage>
ffffffffc020133e:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201342:	00005597          	auipc	a1,0x5
ffffffffc0201346:	0fe58593          	addi	a1,a1,254 # ffffffffc0206440 <pages>
    npage = maxpa / PGSIZE;
ffffffffc020134a:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020134c:	e19c                	sd	a5,0(a1)
ffffffffc020134e:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201350:	4701                	li	a4,0
ffffffffc0201352:	4885                	li	a7,1
ffffffffc0201354:	fff80837          	lui	a6,0xfff80
ffffffffc0201358:	a011                	j	ffffffffc020135c <pmm_init+0x96>
        SetPageReserved(pages + i); //在kern/mm/memlayout.h定义的(将该bit设为1，为内核保留页面)
ffffffffc020135a:	619c                	ld	a5,0(a1)
ffffffffc020135c:	97b6                	add	a5,a5,a3
ffffffffc020135e:	07a1                	addi	a5,a5,8
ffffffffc0201360:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201364:	611c                	ld	a5,0(a0)
ffffffffc0201366:	0705                	addi	a4,a4,1
ffffffffc0201368:	02868693          	addi	a3,a3,40
ffffffffc020136c:	01078633          	add	a2,a5,a6
ffffffffc0201370:	fec765e3          	bltu	a4,a2,ffffffffc020135a <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201374:	6190                	ld	a2,0(a1)
ffffffffc0201376:	00279713          	slli	a4,a5,0x2
ffffffffc020137a:	973e                	add	a4,a4,a5
ffffffffc020137c:	fec006b7          	lui	a3,0xfec00
ffffffffc0201380:	070e                	slli	a4,a4,0x3
ffffffffc0201382:	96b2                	add	a3,a3,a2
ffffffffc0201384:	96ba                	add	a3,a3,a4
ffffffffc0201386:	c0200737          	lui	a4,0xc0200
ffffffffc020138a:	08e6ef63          	bltu	a3,a4,ffffffffc0201428 <pmm_init+0x162>
ffffffffc020138e:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0201390:	45c5                	li	a1,17
ffffffffc0201392:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201394:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201396:	04b6e863          	bltu	a3,a1,ffffffffc02013e6 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020139a:	609c                	ld	a5,0(s1)
ffffffffc020139c:	7b9c                	ld	a5,48(a5)
ffffffffc020139e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02013a0:	00001517          	auipc	a0,0x1
ffffffffc02013a4:	1a850513          	addi	a0,a0,424 # ffffffffc0202548 <best_fit_pmm_manager+0x100>
ffffffffc02013a8:	d0bfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02013ac:	00004597          	auipc	a1,0x4
ffffffffc02013b0:	c5458593          	addi	a1,a1,-940 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02013b4:	00005797          	auipc	a5,0x5
ffffffffc02013b8:	0ab7b223          	sd	a1,164(a5) # ffffffffc0206458 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02013bc:	c02007b7          	lui	a5,0xc0200
ffffffffc02013c0:	08f5e063          	bltu	a1,a5,ffffffffc0201440 <pmm_init+0x17a>
ffffffffc02013c4:	6010                	ld	a2,0(s0)
}
ffffffffc02013c6:	6442                	ld	s0,16(sp)
ffffffffc02013c8:	60e2                	ld	ra,24(sp)
ffffffffc02013ca:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02013cc:	40c58633          	sub	a2,a1,a2
ffffffffc02013d0:	00005797          	auipc	a5,0x5
ffffffffc02013d4:	08c7b023          	sd	a2,128(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013d8:	00001517          	auipc	a0,0x1
ffffffffc02013dc:	19050513          	addi	a0,a0,400 # ffffffffc0202568 <best_fit_pmm_manager+0x120>
}
ffffffffc02013e0:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013e2:	cd1fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02013e6:	6705                	lui	a4,0x1
ffffffffc02013e8:	177d                	addi	a4,a4,-1
ffffffffc02013ea:	96ba                	add	a3,a3,a4
ffffffffc02013ec:	777d                	lui	a4,0xfffff
ffffffffc02013ee:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02013f0:	00c6d513          	srli	a0,a3,0xc
ffffffffc02013f4:	00f57e63          	bgeu	a0,a5,ffffffffc0201410 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02013f8:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02013fa:	982a                	add	a6,a6,a0
ffffffffc02013fc:	00281513          	slli	a0,a6,0x2
ffffffffc0201400:	9542                	add	a0,a0,a6
ffffffffc0201402:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201404:	8d95                	sub	a1,a1,a3
ffffffffc0201406:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201408:	81b1                	srli	a1,a1,0xc
ffffffffc020140a:	9532                	add	a0,a0,a2
ffffffffc020140c:	9782                	jalr	a5
}
ffffffffc020140e:	b771                	j	ffffffffc020139a <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0201410:	00001617          	auipc	a2,0x1
ffffffffc0201414:	10860613          	addi	a2,a2,264 # ffffffffc0202518 <best_fit_pmm_manager+0xd0>
ffffffffc0201418:	06700593          	li	a1,103
ffffffffc020141c:	00001517          	auipc	a0,0x1
ffffffffc0201420:	11c50513          	addi	a0,a0,284 # ffffffffc0202538 <best_fit_pmm_manager+0xf0>
ffffffffc0201424:	f89fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201428:	00001617          	auipc	a2,0x1
ffffffffc020142c:	0b860613          	addi	a2,a2,184 # ffffffffc02024e0 <best_fit_pmm_manager+0x98>
ffffffffc0201430:	07e00593          	li	a1,126
ffffffffc0201434:	00001517          	auipc	a0,0x1
ffffffffc0201438:	0d450513          	addi	a0,a0,212 # ffffffffc0202508 <best_fit_pmm_manager+0xc0>
ffffffffc020143c:	f71fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201440:	86ae                	mv	a3,a1
ffffffffc0201442:	00001617          	auipc	a2,0x1
ffffffffc0201446:	09e60613          	addi	a2,a2,158 # ffffffffc02024e0 <best_fit_pmm_manager+0x98>
ffffffffc020144a:	09d00593          	li	a1,157
ffffffffc020144e:	00001517          	auipc	a0,0x1
ffffffffc0201452:	0ba50513          	addi	a0,a0,186 # ffffffffc0202508 <best_fit_pmm_manager+0xc0>
ffffffffc0201456:	f57fe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020145a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020145a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020145e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201460:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201464:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201466:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020146a:	f022                	sd	s0,32(sp)
ffffffffc020146c:	ec26                	sd	s1,24(sp)
ffffffffc020146e:	e84a                	sd	s2,16(sp)
ffffffffc0201470:	f406                	sd	ra,40(sp)
ffffffffc0201472:	e44e                	sd	s3,8(sp)
ffffffffc0201474:	84aa                	mv	s1,a0
ffffffffc0201476:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201478:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020147c:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020147e:	03067e63          	bgeu	a2,a6,ffffffffc02014ba <printnum+0x60>
ffffffffc0201482:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201484:	00805763          	blez	s0,ffffffffc0201492 <printnum+0x38>
ffffffffc0201488:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020148a:	85ca                	mv	a1,s2
ffffffffc020148c:	854e                	mv	a0,s3
ffffffffc020148e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201490:	fc65                	bnez	s0,ffffffffc0201488 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201492:	1a02                	slli	s4,s4,0x20
ffffffffc0201494:	00001797          	auipc	a5,0x1
ffffffffc0201498:	11478793          	addi	a5,a5,276 # ffffffffc02025a8 <best_fit_pmm_manager+0x160>
ffffffffc020149c:	020a5a13          	srli	s4,s4,0x20
ffffffffc02014a0:	9a3e                	add	s4,s4,a5
}
ffffffffc02014a2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014a4:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02014a8:	70a2                	ld	ra,40(sp)
ffffffffc02014aa:	69a2                	ld	s3,8(sp)
ffffffffc02014ac:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014ae:	85ca                	mv	a1,s2
ffffffffc02014b0:	87a6                	mv	a5,s1
}
ffffffffc02014b2:	6942                	ld	s2,16(sp)
ffffffffc02014b4:	64e2                	ld	s1,24(sp)
ffffffffc02014b6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014b8:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02014ba:	03065633          	divu	a2,a2,a6
ffffffffc02014be:	8722                	mv	a4,s0
ffffffffc02014c0:	f9bff0ef          	jal	ra,ffffffffc020145a <printnum>
ffffffffc02014c4:	b7f9                	j	ffffffffc0201492 <printnum+0x38>

ffffffffc02014c6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02014c6:	7119                	addi	sp,sp,-128
ffffffffc02014c8:	f4a6                	sd	s1,104(sp)
ffffffffc02014ca:	f0ca                	sd	s2,96(sp)
ffffffffc02014cc:	ecce                	sd	s3,88(sp)
ffffffffc02014ce:	e8d2                	sd	s4,80(sp)
ffffffffc02014d0:	e4d6                	sd	s5,72(sp)
ffffffffc02014d2:	e0da                	sd	s6,64(sp)
ffffffffc02014d4:	fc5e                	sd	s7,56(sp)
ffffffffc02014d6:	f06a                	sd	s10,32(sp)
ffffffffc02014d8:	fc86                	sd	ra,120(sp)
ffffffffc02014da:	f8a2                	sd	s0,112(sp)
ffffffffc02014dc:	f862                	sd	s8,48(sp)
ffffffffc02014de:	f466                	sd	s9,40(sp)
ffffffffc02014e0:	ec6e                	sd	s11,24(sp)
ffffffffc02014e2:	892a                	mv	s2,a0
ffffffffc02014e4:	84ae                	mv	s1,a1
ffffffffc02014e6:	8d32                	mv	s10,a2
ffffffffc02014e8:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02014ea:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02014ee:	5b7d                	li	s6,-1
ffffffffc02014f0:	00001a97          	auipc	s5,0x1
ffffffffc02014f4:	0eca8a93          	addi	s5,s5,236 # ffffffffc02025dc <best_fit_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014f8:	00001b97          	auipc	s7,0x1
ffffffffc02014fc:	2c0b8b93          	addi	s7,s7,704 # ffffffffc02027b8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201500:	000d4503          	lbu	a0,0(s10)
ffffffffc0201504:	001d0413          	addi	s0,s10,1
ffffffffc0201508:	01350a63          	beq	a0,s3,ffffffffc020151c <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020150c:	c121                	beqz	a0,ffffffffc020154c <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020150e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201510:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201512:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201514:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201518:	ff351ae3          	bne	a0,s3,ffffffffc020150c <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020151c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201520:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201524:	4c81                	li	s9,0
ffffffffc0201526:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201528:	5c7d                	li	s8,-1
ffffffffc020152a:	5dfd                	li	s11,-1
ffffffffc020152c:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201530:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201532:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201536:	0ff5f593          	zext.b	a1,a1
ffffffffc020153a:	00140d13          	addi	s10,s0,1
ffffffffc020153e:	04b56263          	bltu	a0,a1,ffffffffc0201582 <vprintfmt+0xbc>
ffffffffc0201542:	058a                	slli	a1,a1,0x2
ffffffffc0201544:	95d6                	add	a1,a1,s5
ffffffffc0201546:	4194                	lw	a3,0(a1)
ffffffffc0201548:	96d6                	add	a3,a3,s5
ffffffffc020154a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020154c:	70e6                	ld	ra,120(sp)
ffffffffc020154e:	7446                	ld	s0,112(sp)
ffffffffc0201550:	74a6                	ld	s1,104(sp)
ffffffffc0201552:	7906                	ld	s2,96(sp)
ffffffffc0201554:	69e6                	ld	s3,88(sp)
ffffffffc0201556:	6a46                	ld	s4,80(sp)
ffffffffc0201558:	6aa6                	ld	s5,72(sp)
ffffffffc020155a:	6b06                	ld	s6,64(sp)
ffffffffc020155c:	7be2                	ld	s7,56(sp)
ffffffffc020155e:	7c42                	ld	s8,48(sp)
ffffffffc0201560:	7ca2                	ld	s9,40(sp)
ffffffffc0201562:	7d02                	ld	s10,32(sp)
ffffffffc0201564:	6de2                	ld	s11,24(sp)
ffffffffc0201566:	6109                	addi	sp,sp,128
ffffffffc0201568:	8082                	ret
            padc = '0';
ffffffffc020156a:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020156c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201570:	846a                	mv	s0,s10
ffffffffc0201572:	00140d13          	addi	s10,s0,1
ffffffffc0201576:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020157a:	0ff5f593          	zext.b	a1,a1
ffffffffc020157e:	fcb572e3          	bgeu	a0,a1,ffffffffc0201542 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201582:	85a6                	mv	a1,s1
ffffffffc0201584:	02500513          	li	a0,37
ffffffffc0201588:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020158a:	fff44783          	lbu	a5,-1(s0)
ffffffffc020158e:	8d22                	mv	s10,s0
ffffffffc0201590:	f73788e3          	beq	a5,s3,ffffffffc0201500 <vprintfmt+0x3a>
ffffffffc0201594:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201598:	1d7d                	addi	s10,s10,-1
ffffffffc020159a:	ff379de3          	bne	a5,s3,ffffffffc0201594 <vprintfmt+0xce>
ffffffffc020159e:	b78d                	j	ffffffffc0201500 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02015a0:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02015a4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015a8:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02015aa:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02015ae:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02015b2:	02d86463          	bltu	a6,a3,ffffffffc02015da <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02015b6:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02015ba:	002c169b          	slliw	a3,s8,0x2
ffffffffc02015be:	0186873b          	addw	a4,a3,s8
ffffffffc02015c2:	0017171b          	slliw	a4,a4,0x1
ffffffffc02015c6:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02015c8:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02015cc:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02015ce:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02015d2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02015d6:	fed870e3          	bgeu	a6,a3,ffffffffc02015b6 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02015da:	f40ddce3          	bgez	s11,ffffffffc0201532 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02015de:	8de2                	mv	s11,s8
ffffffffc02015e0:	5c7d                	li	s8,-1
ffffffffc02015e2:	bf81                	j	ffffffffc0201532 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02015e4:	fffdc693          	not	a3,s11
ffffffffc02015e8:	96fd                	srai	a3,a3,0x3f
ffffffffc02015ea:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015ee:	00144603          	lbu	a2,1(s0)
ffffffffc02015f2:	2d81                	sext.w	s11,s11
ffffffffc02015f4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02015f6:	bf35                	j	ffffffffc0201532 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02015f8:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015fc:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201600:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201602:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201604:	bfd9                	j	ffffffffc02015da <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201606:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201608:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020160c:	01174463          	blt	a4,a7,ffffffffc0201614 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201610:	1a088e63          	beqz	a7,ffffffffc02017cc <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201614:	000a3603          	ld	a2,0(s4)
ffffffffc0201618:	46c1                	li	a3,16
ffffffffc020161a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020161c:	2781                	sext.w	a5,a5
ffffffffc020161e:	876e                	mv	a4,s11
ffffffffc0201620:	85a6                	mv	a1,s1
ffffffffc0201622:	854a                	mv	a0,s2
ffffffffc0201624:	e37ff0ef          	jal	ra,ffffffffc020145a <printnum>
            break;
ffffffffc0201628:	bde1                	j	ffffffffc0201500 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020162a:	000a2503          	lw	a0,0(s4)
ffffffffc020162e:	85a6                	mv	a1,s1
ffffffffc0201630:	0a21                	addi	s4,s4,8
ffffffffc0201632:	9902                	jalr	s2
            break;
ffffffffc0201634:	b5f1                	j	ffffffffc0201500 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201636:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201638:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020163c:	01174463          	blt	a4,a7,ffffffffc0201644 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201640:	18088163          	beqz	a7,ffffffffc02017c2 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201644:	000a3603          	ld	a2,0(s4)
ffffffffc0201648:	46a9                	li	a3,10
ffffffffc020164a:	8a2e                	mv	s4,a1
ffffffffc020164c:	bfc1                	j	ffffffffc020161c <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020164e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201652:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201654:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201656:	bdf1                	j	ffffffffc0201532 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201658:	85a6                	mv	a1,s1
ffffffffc020165a:	02500513          	li	a0,37
ffffffffc020165e:	9902                	jalr	s2
            break;
ffffffffc0201660:	b545                	j	ffffffffc0201500 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201662:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201666:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201668:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020166a:	b5e1                	j	ffffffffc0201532 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020166c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020166e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201672:	01174463          	blt	a4,a7,ffffffffc020167a <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201676:	14088163          	beqz	a7,ffffffffc02017b8 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020167a:	000a3603          	ld	a2,0(s4)
ffffffffc020167e:	46a1                	li	a3,8
ffffffffc0201680:	8a2e                	mv	s4,a1
ffffffffc0201682:	bf69                	j	ffffffffc020161c <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201684:	03000513          	li	a0,48
ffffffffc0201688:	85a6                	mv	a1,s1
ffffffffc020168a:	e03e                	sd	a5,0(sp)
ffffffffc020168c:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020168e:	85a6                	mv	a1,s1
ffffffffc0201690:	07800513          	li	a0,120
ffffffffc0201694:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201696:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201698:	6782                	ld	a5,0(sp)
ffffffffc020169a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020169c:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02016a0:	bfb5                	j	ffffffffc020161c <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02016a2:	000a3403          	ld	s0,0(s4)
ffffffffc02016a6:	008a0713          	addi	a4,s4,8
ffffffffc02016aa:	e03a                	sd	a4,0(sp)
ffffffffc02016ac:	14040263          	beqz	s0,ffffffffc02017f0 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02016b0:	0fb05763          	blez	s11,ffffffffc020179e <vprintfmt+0x2d8>
ffffffffc02016b4:	02d00693          	li	a3,45
ffffffffc02016b8:	0cd79163          	bne	a5,a3,ffffffffc020177a <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016bc:	00044783          	lbu	a5,0(s0)
ffffffffc02016c0:	0007851b          	sext.w	a0,a5
ffffffffc02016c4:	cf85                	beqz	a5,ffffffffc02016fc <vprintfmt+0x236>
ffffffffc02016c6:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016ca:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016ce:	000c4563          	bltz	s8,ffffffffc02016d8 <vprintfmt+0x212>
ffffffffc02016d2:	3c7d                	addiw	s8,s8,-1
ffffffffc02016d4:	036c0263          	beq	s8,s6,ffffffffc02016f8 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02016d8:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016da:	0e0c8e63          	beqz	s9,ffffffffc02017d6 <vprintfmt+0x310>
ffffffffc02016de:	3781                	addiw	a5,a5,-32
ffffffffc02016e0:	0ef47b63          	bgeu	s0,a5,ffffffffc02017d6 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02016e4:	03f00513          	li	a0,63
ffffffffc02016e8:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016ea:	000a4783          	lbu	a5,0(s4)
ffffffffc02016ee:	3dfd                	addiw	s11,s11,-1
ffffffffc02016f0:	0a05                	addi	s4,s4,1
ffffffffc02016f2:	0007851b          	sext.w	a0,a5
ffffffffc02016f6:	ffe1                	bnez	a5,ffffffffc02016ce <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02016f8:	01b05963          	blez	s11,ffffffffc020170a <vprintfmt+0x244>
ffffffffc02016fc:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02016fe:	85a6                	mv	a1,s1
ffffffffc0201700:	02000513          	li	a0,32
ffffffffc0201704:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201706:	fe0d9be3          	bnez	s11,ffffffffc02016fc <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020170a:	6a02                	ld	s4,0(sp)
ffffffffc020170c:	bbd5                	j	ffffffffc0201500 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020170e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201710:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201714:	01174463          	blt	a4,a7,ffffffffc020171c <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201718:	08088d63          	beqz	a7,ffffffffc02017b2 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020171c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201720:	0a044d63          	bltz	s0,ffffffffc02017da <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201724:	8622                	mv	a2,s0
ffffffffc0201726:	8a66                	mv	s4,s9
ffffffffc0201728:	46a9                	li	a3,10
ffffffffc020172a:	bdcd                	j	ffffffffc020161c <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020172c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201730:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201732:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201734:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201738:	8fb5                	xor	a5,a5,a3
ffffffffc020173a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020173e:	02d74163          	blt	a4,a3,ffffffffc0201760 <vprintfmt+0x29a>
ffffffffc0201742:	00369793          	slli	a5,a3,0x3
ffffffffc0201746:	97de                	add	a5,a5,s7
ffffffffc0201748:	639c                	ld	a5,0(a5)
ffffffffc020174a:	cb99                	beqz	a5,ffffffffc0201760 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020174c:	86be                	mv	a3,a5
ffffffffc020174e:	00001617          	auipc	a2,0x1
ffffffffc0201752:	e8a60613          	addi	a2,a2,-374 # ffffffffc02025d8 <best_fit_pmm_manager+0x190>
ffffffffc0201756:	85a6                	mv	a1,s1
ffffffffc0201758:	854a                	mv	a0,s2
ffffffffc020175a:	0ce000ef          	jal	ra,ffffffffc0201828 <printfmt>
ffffffffc020175e:	b34d                	j	ffffffffc0201500 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201760:	00001617          	auipc	a2,0x1
ffffffffc0201764:	e6860613          	addi	a2,a2,-408 # ffffffffc02025c8 <best_fit_pmm_manager+0x180>
ffffffffc0201768:	85a6                	mv	a1,s1
ffffffffc020176a:	854a                	mv	a0,s2
ffffffffc020176c:	0bc000ef          	jal	ra,ffffffffc0201828 <printfmt>
ffffffffc0201770:	bb41                	j	ffffffffc0201500 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201772:	00001417          	auipc	s0,0x1
ffffffffc0201776:	e4e40413          	addi	s0,s0,-434 # ffffffffc02025c0 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020177a:	85e2                	mv	a1,s8
ffffffffc020177c:	8522                	mv	a0,s0
ffffffffc020177e:	e43e                	sd	a5,8(sp)
ffffffffc0201780:	1cc000ef          	jal	ra,ffffffffc020194c <strnlen>
ffffffffc0201784:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201788:	01b05b63          	blez	s11,ffffffffc020179e <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020178c:	67a2                	ld	a5,8(sp)
ffffffffc020178e:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201792:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201794:	85a6                	mv	a1,s1
ffffffffc0201796:	8552                	mv	a0,s4
ffffffffc0201798:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020179a:	fe0d9ce3          	bnez	s11,ffffffffc0201792 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020179e:	00044783          	lbu	a5,0(s0)
ffffffffc02017a2:	00140a13          	addi	s4,s0,1
ffffffffc02017a6:	0007851b          	sext.w	a0,a5
ffffffffc02017aa:	d3a5                	beqz	a5,ffffffffc020170a <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017ac:	05e00413          	li	s0,94
ffffffffc02017b0:	bf39                	j	ffffffffc02016ce <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02017b2:	000a2403          	lw	s0,0(s4)
ffffffffc02017b6:	b7ad                	j	ffffffffc0201720 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02017b8:	000a6603          	lwu	a2,0(s4)
ffffffffc02017bc:	46a1                	li	a3,8
ffffffffc02017be:	8a2e                	mv	s4,a1
ffffffffc02017c0:	bdb1                	j	ffffffffc020161c <vprintfmt+0x156>
ffffffffc02017c2:	000a6603          	lwu	a2,0(s4)
ffffffffc02017c6:	46a9                	li	a3,10
ffffffffc02017c8:	8a2e                	mv	s4,a1
ffffffffc02017ca:	bd89                	j	ffffffffc020161c <vprintfmt+0x156>
ffffffffc02017cc:	000a6603          	lwu	a2,0(s4)
ffffffffc02017d0:	46c1                	li	a3,16
ffffffffc02017d2:	8a2e                	mv	s4,a1
ffffffffc02017d4:	b5a1                	j	ffffffffc020161c <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02017d6:	9902                	jalr	s2
ffffffffc02017d8:	bf09                	j	ffffffffc02016ea <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02017da:	85a6                	mv	a1,s1
ffffffffc02017dc:	02d00513          	li	a0,45
ffffffffc02017e0:	e03e                	sd	a5,0(sp)
ffffffffc02017e2:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02017e4:	6782                	ld	a5,0(sp)
ffffffffc02017e6:	8a66                	mv	s4,s9
ffffffffc02017e8:	40800633          	neg	a2,s0
ffffffffc02017ec:	46a9                	li	a3,10
ffffffffc02017ee:	b53d                	j	ffffffffc020161c <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02017f0:	03b05163          	blez	s11,ffffffffc0201812 <vprintfmt+0x34c>
ffffffffc02017f4:	02d00693          	li	a3,45
ffffffffc02017f8:	f6d79de3          	bne	a5,a3,ffffffffc0201772 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02017fc:	00001417          	auipc	s0,0x1
ffffffffc0201800:	dc440413          	addi	s0,s0,-572 # ffffffffc02025c0 <best_fit_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201804:	02800793          	li	a5,40
ffffffffc0201808:	02800513          	li	a0,40
ffffffffc020180c:	00140a13          	addi	s4,s0,1
ffffffffc0201810:	bd6d                	j	ffffffffc02016ca <vprintfmt+0x204>
ffffffffc0201812:	00001a17          	auipc	s4,0x1
ffffffffc0201816:	dafa0a13          	addi	s4,s4,-593 # ffffffffc02025c1 <best_fit_pmm_manager+0x179>
ffffffffc020181a:	02800513          	li	a0,40
ffffffffc020181e:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201822:	05e00413          	li	s0,94
ffffffffc0201826:	b565                	j	ffffffffc02016ce <vprintfmt+0x208>

ffffffffc0201828 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201828:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020182a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020182e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201830:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201832:	ec06                	sd	ra,24(sp)
ffffffffc0201834:	f83a                	sd	a4,48(sp)
ffffffffc0201836:	fc3e                	sd	a5,56(sp)
ffffffffc0201838:	e0c2                	sd	a6,64(sp)
ffffffffc020183a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020183c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020183e:	c89ff0ef          	jal	ra,ffffffffc02014c6 <vprintfmt>
}
ffffffffc0201842:	60e2                	ld	ra,24(sp)
ffffffffc0201844:	6161                	addi	sp,sp,80
ffffffffc0201846:	8082                	ret

ffffffffc0201848 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201848:	715d                	addi	sp,sp,-80
ffffffffc020184a:	e486                	sd	ra,72(sp)
ffffffffc020184c:	e0a6                	sd	s1,64(sp)
ffffffffc020184e:	fc4a                	sd	s2,56(sp)
ffffffffc0201850:	f84e                	sd	s3,48(sp)
ffffffffc0201852:	f452                	sd	s4,40(sp)
ffffffffc0201854:	f056                	sd	s5,32(sp)
ffffffffc0201856:	ec5a                	sd	s6,24(sp)
ffffffffc0201858:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc020185a:	c901                	beqz	a0,ffffffffc020186a <readline+0x22>
ffffffffc020185c:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020185e:	00001517          	auipc	a0,0x1
ffffffffc0201862:	d7a50513          	addi	a0,a0,-646 # ffffffffc02025d8 <best_fit_pmm_manager+0x190>
ffffffffc0201866:	84dfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc020186a:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020186c:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020186e:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201870:	4aa9                	li	s5,10
ffffffffc0201872:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201874:	00004b97          	auipc	s7,0x4
ffffffffc0201878:	7b4b8b93          	addi	s7,s7,1972 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020187c:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201880:	8abfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201884:	00054a63          	bltz	a0,ffffffffc0201898 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201888:	00a95a63          	bge	s2,a0,ffffffffc020189c <readline+0x54>
ffffffffc020188c:	029a5263          	bge	s4,s1,ffffffffc02018b0 <readline+0x68>
        c = getchar();
ffffffffc0201890:	89bfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201894:	fe055ae3          	bgez	a0,ffffffffc0201888 <readline+0x40>
            return NULL;
ffffffffc0201898:	4501                	li	a0,0
ffffffffc020189a:	a091                	j	ffffffffc02018de <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020189c:	03351463          	bne	a0,s3,ffffffffc02018c4 <readline+0x7c>
ffffffffc02018a0:	e8a9                	bnez	s1,ffffffffc02018f2 <readline+0xaa>
        c = getchar();
ffffffffc02018a2:	889fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02018a6:	fe0549e3          	bltz	a0,ffffffffc0201898 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018aa:	fea959e3          	bge	s2,a0,ffffffffc020189c <readline+0x54>
ffffffffc02018ae:	4481                	li	s1,0
            cputchar(c);
ffffffffc02018b0:	e42a                	sd	a0,8(sp)
ffffffffc02018b2:	837fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02018b6:	6522                	ld	a0,8(sp)
ffffffffc02018b8:	009b87b3          	add	a5,s7,s1
ffffffffc02018bc:	2485                	addiw	s1,s1,1
ffffffffc02018be:	00a78023          	sb	a0,0(a5)
ffffffffc02018c2:	bf7d                	j	ffffffffc0201880 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02018c4:	01550463          	beq	a0,s5,ffffffffc02018cc <readline+0x84>
ffffffffc02018c8:	fb651ce3          	bne	a0,s6,ffffffffc0201880 <readline+0x38>
            cputchar(c);
ffffffffc02018cc:	81dfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02018d0:	00004517          	auipc	a0,0x4
ffffffffc02018d4:	75850513          	addi	a0,a0,1880 # ffffffffc0206028 <buf>
ffffffffc02018d8:	94aa                	add	s1,s1,a0
ffffffffc02018da:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02018de:	60a6                	ld	ra,72(sp)
ffffffffc02018e0:	6486                	ld	s1,64(sp)
ffffffffc02018e2:	7962                	ld	s2,56(sp)
ffffffffc02018e4:	79c2                	ld	s3,48(sp)
ffffffffc02018e6:	7a22                	ld	s4,40(sp)
ffffffffc02018e8:	7a82                	ld	s5,32(sp)
ffffffffc02018ea:	6b62                	ld	s6,24(sp)
ffffffffc02018ec:	6bc2                	ld	s7,16(sp)
ffffffffc02018ee:	6161                	addi	sp,sp,80
ffffffffc02018f0:	8082                	ret
            cputchar(c);
ffffffffc02018f2:	4521                	li	a0,8
ffffffffc02018f4:	ff4fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc02018f8:	34fd                	addiw	s1,s1,-1
ffffffffc02018fa:	b759                	j	ffffffffc0201880 <readline+0x38>

ffffffffc02018fc <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02018fc:	4781                	li	a5,0
ffffffffc02018fe:	00004717          	auipc	a4,0x4
ffffffffc0201902:	70a73703          	ld	a4,1802(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201906:	88ba                	mv	a7,a4
ffffffffc0201908:	852a                	mv	a0,a0
ffffffffc020190a:	85be                	mv	a1,a5
ffffffffc020190c:	863e                	mv	a2,a5
ffffffffc020190e:	00000073          	ecall
ffffffffc0201912:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201914:	8082                	ret

ffffffffc0201916 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201916:	4781                	li	a5,0
ffffffffc0201918:	00005717          	auipc	a4,0x5
ffffffffc020191c:	b5073703          	ld	a4,-1200(a4) # ffffffffc0206468 <SBI_SET_TIMER>
ffffffffc0201920:	88ba                	mv	a7,a4
ffffffffc0201922:	852a                	mv	a0,a0
ffffffffc0201924:	85be                	mv	a1,a5
ffffffffc0201926:	863e                	mv	a2,a5
ffffffffc0201928:	00000073          	ecall
ffffffffc020192c:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc020192e:	8082                	ret

ffffffffc0201930 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201930:	4501                	li	a0,0
ffffffffc0201932:	00004797          	auipc	a5,0x4
ffffffffc0201936:	6ce7b783          	ld	a5,1742(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc020193a:	88be                	mv	a7,a5
ffffffffc020193c:	852a                	mv	a0,a0
ffffffffc020193e:	85aa                	mv	a1,a0
ffffffffc0201940:	862a                	mv	a2,a0
ffffffffc0201942:	00000073          	ecall
ffffffffc0201946:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201948:	2501                	sext.w	a0,a0
ffffffffc020194a:	8082                	ret

ffffffffc020194c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020194c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020194e:	e589                	bnez	a1,ffffffffc0201958 <strnlen+0xc>
ffffffffc0201950:	a811                	j	ffffffffc0201964 <strnlen+0x18>
        cnt ++;
ffffffffc0201952:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201954:	00f58863          	beq	a1,a5,ffffffffc0201964 <strnlen+0x18>
ffffffffc0201958:	00f50733          	add	a4,a0,a5
ffffffffc020195c:	00074703          	lbu	a4,0(a4)
ffffffffc0201960:	fb6d                	bnez	a4,ffffffffc0201952 <strnlen+0x6>
ffffffffc0201962:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201964:	852e                	mv	a0,a1
ffffffffc0201966:	8082                	ret

ffffffffc0201968 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201968:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020196c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201970:	cb89                	beqz	a5,ffffffffc0201982 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201972:	0505                	addi	a0,a0,1
ffffffffc0201974:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201976:	fee789e3          	beq	a5,a4,ffffffffc0201968 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020197a:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020197e:	9d19                	subw	a0,a0,a4
ffffffffc0201980:	8082                	ret
ffffffffc0201982:	4501                	li	a0,0
ffffffffc0201984:	bfed                	j	ffffffffc020197e <strcmp+0x16>

ffffffffc0201986 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201986:	00054783          	lbu	a5,0(a0)
ffffffffc020198a:	c799                	beqz	a5,ffffffffc0201998 <strchr+0x12>
        if (*s == c) {
ffffffffc020198c:	00f58763          	beq	a1,a5,ffffffffc020199a <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201990:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201994:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201996:	fbfd                	bnez	a5,ffffffffc020198c <strchr+0x6>
    }
    return NULL;
ffffffffc0201998:	4501                	li	a0,0
}
ffffffffc020199a:	8082                	ret

ffffffffc020199c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020199c:	ca01                	beqz	a2,ffffffffc02019ac <memset+0x10>
ffffffffc020199e:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02019a0:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02019a2:	0785                	addi	a5,a5,1
ffffffffc02019a4:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02019a8:	fec79de3          	bne	a5,a2,ffffffffc02019a2 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02019ac:	8082                	ret
>>>>>>> 97596ce2241fa37ea12cf2ab59a6d24c0ff06029
