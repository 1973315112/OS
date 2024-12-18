
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200024:	c020b137          	lui	sp,0xc020b

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
ffffffffc0200032:	000a7517          	auipc	a0,0xa7
ffffffffc0200036:	31650513          	addi	a0,a0,790 # ffffffffc02a7348 <buf>
ffffffffc020003a:	000b3617          	auipc	a2,0xb3
ffffffffc020003e:	86a60613          	addi	a2,a2,-1942 # ffffffffc02b28a4 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	67e060ef          	jal	ra,ffffffffc02066c8 <memset>
    cons_init();                // init the console
ffffffffc020004e:	52a000ef          	jal	ra,ffffffffc0200578 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	6a658593          	addi	a1,a1,1702 # ffffffffc02066f8 <etext+0x6>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	6be50513          	addi	a0,a0,1726 # ffffffffc0206718 <etext+0x26>
ffffffffc0200062:	11e000ef          	jal	ra,ffffffffc0200180 <cprintf>

    print_kerninfo();
ffffffffc0200066:	1a2000ef          	jal	ra,ffffffffc0200208 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	03f020ef          	jal	ra,ffffffffc02028a8 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5de000ef          	jal	ra,ffffffffc020064c <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5dc000ef          	jal	ra,ffffffffc020064e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	53e040ef          	jal	ra,ffffffffc02045b4 <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	5c7050ef          	jal	ra,ffffffffc0205e40 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	56c000ef          	jal	ra,ffffffffc02005ea <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	49c030ef          	jal	ra,ffffffffc020351e <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	4a0000ef          	jal	ra,ffffffffc0200526 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	5b6000ef          	jal	ra,ffffffffc0200640 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	74b050ef          	jal	ra,ffffffffc0205fd8 <cpu_idle>

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
ffffffffc02000a8:	00006517          	auipc	a0,0x6
ffffffffc02000ac:	67850513          	addi	a0,a0,1656 # ffffffffc0206720 <etext+0x2e>
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
ffffffffc02000be:	000a7b97          	auipc	s7,0xa7
ffffffffc02000c2:	28ab8b93          	addi	s7,s7,650 # ffffffffc02a7348 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000ca:	12e000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000ce:	00054a63          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d2:	00a95a63          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000d6:	029a5263          	bge	s4,s1,ffffffffc02000fa <readline+0x68>
        c = getchar();
ffffffffc02000da:	11e000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000de:	fe055ae3          	bgez	a0,ffffffffc02000d2 <readline+0x40>
            return NULL;
ffffffffc02000e2:	4501                	li	a0,0
ffffffffc02000e4:	a091                	j	ffffffffc0200128 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000e6:	03351463          	bne	a0,s3,ffffffffc020010e <readline+0x7c>
ffffffffc02000ea:	e8a9                	bnez	s1,ffffffffc020013c <readline+0xaa>
        c = getchar();
ffffffffc02000ec:	10c000ef          	jal	ra,ffffffffc02001f8 <getchar>
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
ffffffffc020011a:	000a7517          	auipc	a0,0xa7
ffffffffc020011e:	22e50513          	addi	a0,a0,558 # ffffffffc02a7348 <buf>
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
ffffffffc020014e:	42c000ef          	jal	ra,ffffffffc020057a <cons_putc>
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
ffffffffc0200174:	156060ef          	jal	ra,ffffffffc02062ca <vprintfmt>
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
ffffffffc0200182:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
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
ffffffffc02001aa:	120060ef          	jal	ra,ffffffffc02062ca <vprintfmt>
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
ffffffffc02001b6:	a6d1                	j	ffffffffc020057a <cons_putc>

ffffffffc02001b8 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001b8:	1101                	addi	sp,sp,-32
ffffffffc02001ba:	e822                	sd	s0,16(sp)
ffffffffc02001bc:	ec06                	sd	ra,24(sp)
ffffffffc02001be:	e426                	sd	s1,8(sp)
ffffffffc02001c0:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001c2:	00054503          	lbu	a0,0(a0)
ffffffffc02001c6:	c51d                	beqz	a0,ffffffffc02001f4 <cputs+0x3c>
ffffffffc02001c8:	0405                	addi	s0,s0,1
ffffffffc02001ca:	4485                	li	s1,1
ffffffffc02001cc:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001ce:	3ac000ef          	jal	ra,ffffffffc020057a <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02001d2:	00044503          	lbu	a0,0(s0)
ffffffffc02001d6:	008487bb          	addw	a5,s1,s0
ffffffffc02001da:	0405                	addi	s0,s0,1
ffffffffc02001dc:	f96d                	bnez	a0,ffffffffc02001ce <cputs+0x16>
    (*cnt) ++;
ffffffffc02001de:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001e2:	4529                	li	a0,10
ffffffffc02001e4:	396000ef          	jal	ra,ffffffffc020057a <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001e8:	60e2                	ld	ra,24(sp)
ffffffffc02001ea:	8522                	mv	a0,s0
ffffffffc02001ec:	6442                	ld	s0,16(sp)
ffffffffc02001ee:	64a2                	ld	s1,8(sp)
ffffffffc02001f0:	6105                	addi	sp,sp,32
ffffffffc02001f2:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc02001f4:	4405                	li	s0,1
ffffffffc02001f6:	b7f5                	j	ffffffffc02001e2 <cputs+0x2a>

ffffffffc02001f8 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001f8:	1141                	addi	sp,sp,-16
ffffffffc02001fa:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001fc:	3b2000ef          	jal	ra,ffffffffc02005ae <cons_getc>
ffffffffc0200200:	dd75                	beqz	a0,ffffffffc02001fc <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200202:	60a2                	ld	ra,8(sp)
ffffffffc0200204:	0141                	addi	sp,sp,16
ffffffffc0200206:	8082                	ret

ffffffffc0200208 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200208:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020020a:	00006517          	auipc	a0,0x6
ffffffffc020020e:	51e50513          	addi	a0,a0,1310 # ffffffffc0206728 <etext+0x36>
void print_kerninfo(void) {
ffffffffc0200212:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200214:	f6dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200218:	00000597          	auipc	a1,0x0
ffffffffc020021c:	e1a58593          	addi	a1,a1,-486 # ffffffffc0200032 <kern_init>
ffffffffc0200220:	00006517          	auipc	a0,0x6
ffffffffc0200224:	52850513          	addi	a0,a0,1320 # ffffffffc0206748 <etext+0x56>
ffffffffc0200228:	f59ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020022c:	00006597          	auipc	a1,0x6
ffffffffc0200230:	4c658593          	addi	a1,a1,1222 # ffffffffc02066f2 <etext>
ffffffffc0200234:	00006517          	auipc	a0,0x6
ffffffffc0200238:	53450513          	addi	a0,a0,1332 # ffffffffc0206768 <etext+0x76>
ffffffffc020023c:	f45ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200240:	000a7597          	auipc	a1,0xa7
ffffffffc0200244:	10858593          	addi	a1,a1,264 # ffffffffc02a7348 <buf>
ffffffffc0200248:	00006517          	auipc	a0,0x6
ffffffffc020024c:	54050513          	addi	a0,a0,1344 # ffffffffc0206788 <etext+0x96>
ffffffffc0200250:	f31ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200254:	000b2597          	auipc	a1,0xb2
ffffffffc0200258:	65058593          	addi	a1,a1,1616 # ffffffffc02b28a4 <end>
ffffffffc020025c:	00006517          	auipc	a0,0x6
ffffffffc0200260:	54c50513          	addi	a0,a0,1356 # ffffffffc02067a8 <etext+0xb6>
ffffffffc0200264:	f1dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200268:	000b3597          	auipc	a1,0xb3
ffffffffc020026c:	a3b58593          	addi	a1,a1,-1477 # ffffffffc02b2ca3 <end+0x3ff>
ffffffffc0200270:	00000797          	auipc	a5,0x0
ffffffffc0200274:	dc278793          	addi	a5,a5,-574 # ffffffffc0200032 <kern_init>
ffffffffc0200278:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020027c:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200280:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200282:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200286:	95be                	add	a1,a1,a5
ffffffffc0200288:	85a9                	srai	a1,a1,0xa
ffffffffc020028a:	00006517          	auipc	a0,0x6
ffffffffc020028e:	53e50513          	addi	a0,a0,1342 # ffffffffc02067c8 <etext+0xd6>
}
ffffffffc0200292:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200294:	b5f5                	j	ffffffffc0200180 <cprintf>

ffffffffc0200296 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200296:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200298:	00006617          	auipc	a2,0x6
ffffffffc020029c:	56060613          	addi	a2,a2,1376 # ffffffffc02067f8 <etext+0x106>
ffffffffc02002a0:	04d00593          	li	a1,77
ffffffffc02002a4:	00006517          	auipc	a0,0x6
ffffffffc02002a8:	56c50513          	addi	a0,a0,1388 # ffffffffc0206810 <etext+0x11e>
void print_stackframe(void) {
ffffffffc02002ac:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002ae:	1cc000ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02002b2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002b2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002b4:	00006617          	auipc	a2,0x6
ffffffffc02002b8:	57460613          	addi	a2,a2,1396 # ffffffffc0206828 <etext+0x136>
ffffffffc02002bc:	00006597          	auipc	a1,0x6
ffffffffc02002c0:	58c58593          	addi	a1,a1,1420 # ffffffffc0206848 <etext+0x156>
ffffffffc02002c4:	00006517          	auipc	a0,0x6
ffffffffc02002c8:	58c50513          	addi	a0,a0,1420 # ffffffffc0206850 <etext+0x15e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002cc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002ce:	eb3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002d2:	00006617          	auipc	a2,0x6
ffffffffc02002d6:	58e60613          	addi	a2,a2,1422 # ffffffffc0206860 <etext+0x16e>
ffffffffc02002da:	00006597          	auipc	a1,0x6
ffffffffc02002de:	5ae58593          	addi	a1,a1,1454 # ffffffffc0206888 <etext+0x196>
ffffffffc02002e2:	00006517          	auipc	a0,0x6
ffffffffc02002e6:	56e50513          	addi	a0,a0,1390 # ffffffffc0206850 <etext+0x15e>
ffffffffc02002ea:	e97ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002ee:	00006617          	auipc	a2,0x6
ffffffffc02002f2:	5aa60613          	addi	a2,a2,1450 # ffffffffc0206898 <etext+0x1a6>
ffffffffc02002f6:	00006597          	auipc	a1,0x6
ffffffffc02002fa:	5c258593          	addi	a1,a1,1474 # ffffffffc02068b8 <etext+0x1c6>
ffffffffc02002fe:	00006517          	auipc	a0,0x6
ffffffffc0200302:	55250513          	addi	a0,a0,1362 # ffffffffc0206850 <etext+0x15e>
ffffffffc0200306:	e7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    }
    return 0;
}
ffffffffc020030a:	60a2                	ld	ra,8(sp)
ffffffffc020030c:	4501                	li	a0,0
ffffffffc020030e:	0141                	addi	sp,sp,16
ffffffffc0200310:	8082                	ret

ffffffffc0200312 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200312:	1141                	addi	sp,sp,-16
ffffffffc0200314:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200316:	ef3ff0ef          	jal	ra,ffffffffc0200208 <print_kerninfo>
    return 0;
}
ffffffffc020031a:	60a2                	ld	ra,8(sp)
ffffffffc020031c:	4501                	li	a0,0
ffffffffc020031e:	0141                	addi	sp,sp,16
ffffffffc0200320:	8082                	ret

ffffffffc0200322 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200322:	1141                	addi	sp,sp,-16
ffffffffc0200324:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200326:	f71ff0ef          	jal	ra,ffffffffc0200296 <print_stackframe>
    return 0;
}
ffffffffc020032a:	60a2                	ld	ra,8(sp)
ffffffffc020032c:	4501                	li	a0,0
ffffffffc020032e:	0141                	addi	sp,sp,16
ffffffffc0200330:	8082                	ret

ffffffffc0200332 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200332:	7115                	addi	sp,sp,-224
ffffffffc0200334:	ed5e                	sd	s7,152(sp)
ffffffffc0200336:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200338:	00006517          	auipc	a0,0x6
ffffffffc020033c:	59050513          	addi	a0,a0,1424 # ffffffffc02068c8 <etext+0x1d6>
kmonitor(struct trapframe *tf) {
ffffffffc0200340:	ed86                	sd	ra,216(sp)
ffffffffc0200342:	e9a2                	sd	s0,208(sp)
ffffffffc0200344:	e5a6                	sd	s1,200(sp)
ffffffffc0200346:	e1ca                	sd	s2,192(sp)
ffffffffc0200348:	fd4e                	sd	s3,184(sp)
ffffffffc020034a:	f952                	sd	s4,176(sp)
ffffffffc020034c:	f556                	sd	s5,168(sp)
ffffffffc020034e:	f15a                	sd	s6,160(sp)
ffffffffc0200350:	e962                	sd	s8,144(sp)
ffffffffc0200352:	e566                	sd	s9,136(sp)
ffffffffc0200354:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200356:	e2bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020035a:	00006517          	auipc	a0,0x6
ffffffffc020035e:	59650513          	addi	a0,a0,1430 # ffffffffc02068f0 <etext+0x1fe>
ffffffffc0200362:	e1fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    if (tf != NULL) {
ffffffffc0200366:	000b8563          	beqz	s7,ffffffffc0200370 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020036a:	855e                	mv	a0,s7
ffffffffc020036c:	4c8000ef          	jal	ra,ffffffffc0200834 <print_trapframe>
ffffffffc0200370:	00006c17          	auipc	s8,0x6
ffffffffc0200374:	5f0c0c13          	addi	s8,s8,1520 # ffffffffc0206960 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200378:	00006917          	auipc	s2,0x6
ffffffffc020037c:	5a090913          	addi	s2,s2,1440 # ffffffffc0206918 <etext+0x226>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200380:	00006497          	auipc	s1,0x6
ffffffffc0200384:	5a048493          	addi	s1,s1,1440 # ffffffffc0206920 <etext+0x22e>
        if (argc == MAXARGS - 1) {
ffffffffc0200388:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020038a:	00006b17          	auipc	s6,0x6
ffffffffc020038e:	59eb0b13          	addi	s6,s6,1438 # ffffffffc0206928 <etext+0x236>
        argv[argc ++] = buf;
ffffffffc0200392:	00006a17          	auipc	s4,0x6
ffffffffc0200396:	4b6a0a13          	addi	s4,s4,1206 # ffffffffc0206848 <etext+0x156>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020039a:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020039c:	854a                	mv	a0,s2
ffffffffc020039e:	cf5ff0ef          	jal	ra,ffffffffc0200092 <readline>
ffffffffc02003a2:	842a                	mv	s0,a0
ffffffffc02003a4:	dd65                	beqz	a0,ffffffffc020039c <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003aa:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ac:	e1bd                	bnez	a1,ffffffffc0200412 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02003ae:	fe0c87e3          	beqz	s9,ffffffffc020039c <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003b2:	6582                	ld	a1,0(sp)
ffffffffc02003b4:	00006d17          	auipc	s10,0x6
ffffffffc02003b8:	5acd0d13          	addi	s10,s10,1452 # ffffffffc0206960 <commands>
        argv[argc ++] = buf;
ffffffffc02003bc:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003be:	4401                	li	s0,0
ffffffffc02003c0:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003c2:	2d2060ef          	jal	ra,ffffffffc0206694 <strcmp>
ffffffffc02003c6:	c919                	beqz	a0,ffffffffc02003dc <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003c8:	2405                	addiw	s0,s0,1
ffffffffc02003ca:	0b540063          	beq	s0,s5,ffffffffc020046a <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ce:	000d3503          	ld	a0,0(s10)
ffffffffc02003d2:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d4:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d6:	2be060ef          	jal	ra,ffffffffc0206694 <strcmp>
ffffffffc02003da:	f57d                	bnez	a0,ffffffffc02003c8 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003dc:	00141793          	slli	a5,s0,0x1
ffffffffc02003e0:	97a2                	add	a5,a5,s0
ffffffffc02003e2:	078e                	slli	a5,a5,0x3
ffffffffc02003e4:	97e2                	add	a5,a5,s8
ffffffffc02003e6:	6b9c                	ld	a5,16(a5)
ffffffffc02003e8:	865e                	mv	a2,s7
ffffffffc02003ea:	002c                	addi	a1,sp,8
ffffffffc02003ec:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003f0:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003f2:	fa0555e3          	bgez	a0,ffffffffc020039c <kmonitor+0x6a>
}
ffffffffc02003f6:	60ee                	ld	ra,216(sp)
ffffffffc02003f8:	644e                	ld	s0,208(sp)
ffffffffc02003fa:	64ae                	ld	s1,200(sp)
ffffffffc02003fc:	690e                	ld	s2,192(sp)
ffffffffc02003fe:	79ea                	ld	s3,184(sp)
ffffffffc0200400:	7a4a                	ld	s4,176(sp)
ffffffffc0200402:	7aaa                	ld	s5,168(sp)
ffffffffc0200404:	7b0a                	ld	s6,160(sp)
ffffffffc0200406:	6bea                	ld	s7,152(sp)
ffffffffc0200408:	6c4a                	ld	s8,144(sp)
ffffffffc020040a:	6caa                	ld	s9,136(sp)
ffffffffc020040c:	6d0a                	ld	s10,128(sp)
ffffffffc020040e:	612d                	addi	sp,sp,224
ffffffffc0200410:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200412:	8526                	mv	a0,s1
ffffffffc0200414:	29e060ef          	jal	ra,ffffffffc02066b2 <strchr>
ffffffffc0200418:	c901                	beqz	a0,ffffffffc0200428 <kmonitor+0xf6>
ffffffffc020041a:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc020041e:	00040023          	sb	zero,0(s0)
ffffffffc0200422:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200424:	d5c9                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc0200426:	b7f5                	j	ffffffffc0200412 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200428:	00044783          	lbu	a5,0(s0)
ffffffffc020042c:	d3c9                	beqz	a5,ffffffffc02003ae <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc020042e:	033c8963          	beq	s9,s3,ffffffffc0200460 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200432:	003c9793          	slli	a5,s9,0x3
ffffffffc0200436:	0118                	addi	a4,sp,128
ffffffffc0200438:	97ba                	add	a5,a5,a4
ffffffffc020043a:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020043e:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200442:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200444:	e591                	bnez	a1,ffffffffc0200450 <kmonitor+0x11e>
ffffffffc0200446:	b7b5                	j	ffffffffc02003b2 <kmonitor+0x80>
ffffffffc0200448:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020044c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044e:	d1a5                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc0200450:	8526                	mv	a0,s1
ffffffffc0200452:	260060ef          	jal	ra,ffffffffc02066b2 <strchr>
ffffffffc0200456:	d96d                	beqz	a0,ffffffffc0200448 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200458:	00044583          	lbu	a1,0(s0)
ffffffffc020045c:	d9a9                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc020045e:	bf55                	j	ffffffffc0200412 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200460:	45c1                	li	a1,16
ffffffffc0200462:	855a                	mv	a0,s6
ffffffffc0200464:	d1dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200468:	b7e9                	j	ffffffffc0200432 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020046a:	6582                	ld	a1,0(sp)
ffffffffc020046c:	00006517          	auipc	a0,0x6
ffffffffc0200470:	4dc50513          	addi	a0,a0,1244 # ffffffffc0206948 <etext+0x256>
ffffffffc0200474:	d0dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
ffffffffc0200478:	b715                	j	ffffffffc020039c <kmonitor+0x6a>

ffffffffc020047a <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020047a:	000b2317          	auipc	t1,0xb2
ffffffffc020047e:	39630313          	addi	t1,t1,918 # ffffffffc02b2810 <is_panic>
ffffffffc0200482:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200486:	715d                	addi	sp,sp,-80
ffffffffc0200488:	ec06                	sd	ra,24(sp)
ffffffffc020048a:	e822                	sd	s0,16(sp)
ffffffffc020048c:	f436                	sd	a3,40(sp)
ffffffffc020048e:	f83a                	sd	a4,48(sp)
ffffffffc0200490:	fc3e                	sd	a5,56(sp)
ffffffffc0200492:	e0c2                	sd	a6,64(sp)
ffffffffc0200494:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200496:	020e1a63          	bnez	t3,ffffffffc02004ca <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020049a:	4785                	li	a5,1
ffffffffc020049c:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004a0:	8432                	mv	s0,a2
ffffffffc02004a2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004a4:	862e                	mv	a2,a1
ffffffffc02004a6:	85aa                	mv	a1,a0
ffffffffc02004a8:	00006517          	auipc	a0,0x6
ffffffffc02004ac:	50050513          	addi	a0,a0,1280 # ffffffffc02069a8 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02004b0:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b2:	ccfff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004b6:	65a2                	ld	a1,8(sp)
ffffffffc02004b8:	8522                	mv	a0,s0
ffffffffc02004ba:	ca7ff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc02004be:	00007517          	auipc	a0,0x7
ffffffffc02004c2:	54a50513          	addi	a0,a0,1354 # ffffffffc0207a08 <default_pmm_manager+0x450>
ffffffffc02004c6:	cbbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004ca:	4501                	li	a0,0
ffffffffc02004cc:	4581                	li	a1,0
ffffffffc02004ce:	4601                	li	a2,0
ffffffffc02004d0:	48a1                	li	a7,8
ffffffffc02004d2:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004d6:	170000ef          	jal	ra,ffffffffc0200646 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004da:	4501                	li	a0,0
ffffffffc02004dc:	e57ff0ef          	jal	ra,ffffffffc0200332 <kmonitor>
    while (1) {
ffffffffc02004e0:	bfed                	j	ffffffffc02004da <__panic+0x60>

ffffffffc02004e2 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004e2:	715d                	addi	sp,sp,-80
ffffffffc02004e4:	832e                	mv	t1,a1
ffffffffc02004e6:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004e8:	85aa                	mv	a1,a0
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004ea:	8432                	mv	s0,a2
ffffffffc02004ec:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004ee:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc02004f0:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004f2:	00006517          	auipc	a0,0x6
ffffffffc02004f6:	4d650513          	addi	a0,a0,1238 # ffffffffc02069c8 <commands+0x68>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004fa:	ec06                	sd	ra,24(sp)
ffffffffc02004fc:	f436                	sd	a3,40(sp)
ffffffffc02004fe:	f83a                	sd	a4,48(sp)
ffffffffc0200500:	e0c2                	sd	a6,64(sp)
ffffffffc0200502:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200504:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200506:	c7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020050a:	65a2                	ld	a1,8(sp)
ffffffffc020050c:	8522                	mv	a0,s0
ffffffffc020050e:	c53ff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc0200512:	00007517          	auipc	a0,0x7
ffffffffc0200516:	4f650513          	addi	a0,a0,1270 # ffffffffc0207a08 <default_pmm_manager+0x450>
ffffffffc020051a:	c67ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    va_end(ap);
}
ffffffffc020051e:	60e2                	ld	ra,24(sp)
ffffffffc0200520:	6442                	ld	s0,16(sp)
ffffffffc0200522:	6161                	addi	sp,sp,80
ffffffffc0200524:	8082                	ret

ffffffffc0200526 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200526:	67e1                	lui	a5,0x18
ffffffffc0200528:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd578>
ffffffffc020052c:	000b2717          	auipc	a4,0xb2
ffffffffc0200530:	2ef73a23          	sd	a5,756(a4) # ffffffffc02b2820 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200534:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200538:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020053a:	953e                	add	a0,a0,a5
ffffffffc020053c:	4601                	li	a2,0
ffffffffc020053e:	4881                	li	a7,0
ffffffffc0200540:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200544:	02000793          	li	a5,32
ffffffffc0200548:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020054c:	00006517          	auipc	a0,0x6
ffffffffc0200550:	49c50513          	addi	a0,a0,1180 # ffffffffc02069e8 <commands+0x88>
    ticks = 0;
ffffffffc0200554:	000b2797          	auipc	a5,0xb2
ffffffffc0200558:	2c07b223          	sd	zero,708(a5) # ffffffffc02b2818 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020055c:	b115                	j	ffffffffc0200180 <cprintf>

ffffffffc020055e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020055e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200562:	000b2797          	auipc	a5,0xb2
ffffffffc0200566:	2be7b783          	ld	a5,702(a5) # ffffffffc02b2820 <timebase>
ffffffffc020056a:	953e                	add	a0,a0,a5
ffffffffc020056c:	4581                	li	a1,0
ffffffffc020056e:	4601                	li	a2,0
ffffffffc0200570:	4881                	li	a7,0
ffffffffc0200572:	00000073          	ecall
ffffffffc0200576:	8082                	ret

ffffffffc0200578 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200578:	8082                	ret

ffffffffc020057a <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020057a:	100027f3          	csrr	a5,sstatus
ffffffffc020057e:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200580:	0ff57513          	zext.b	a0,a0
ffffffffc0200584:	e799                	bnez	a5,ffffffffc0200592 <cons_putc+0x18>
ffffffffc0200586:	4581                	li	a1,0
ffffffffc0200588:	4601                	li	a2,0
ffffffffc020058a:	4885                	li	a7,1
ffffffffc020058c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200590:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200592:	1101                	addi	sp,sp,-32
ffffffffc0200594:	ec06                	sd	ra,24(sp)
ffffffffc0200596:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200598:	0ae000ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc020059c:	6522                	ld	a0,8(sp)
ffffffffc020059e:	4581                	li	a1,0
ffffffffc02005a0:	4601                	li	a2,0
ffffffffc02005a2:	4885                	li	a7,1
ffffffffc02005a4:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005a8:	60e2                	ld	ra,24(sp)
ffffffffc02005aa:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005ac:	a851                	j	ffffffffc0200640 <intr_enable>

ffffffffc02005ae <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005ae:	100027f3          	csrr	a5,sstatus
ffffffffc02005b2:	8b89                	andi	a5,a5,2
ffffffffc02005b4:	eb89                	bnez	a5,ffffffffc02005c6 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005b6:	4501                	li	a0,0
ffffffffc02005b8:	4581                	li	a1,0
ffffffffc02005ba:	4601                	li	a2,0
ffffffffc02005bc:	4889                	li	a7,2
ffffffffc02005be:	00000073          	ecall
ffffffffc02005c2:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005c4:	8082                	ret
int cons_getc(void) {
ffffffffc02005c6:	1101                	addi	sp,sp,-32
ffffffffc02005c8:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005ca:	07c000ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc02005ce:	4501                	li	a0,0
ffffffffc02005d0:	4581                	li	a1,0
ffffffffc02005d2:	4601                	li	a2,0
ffffffffc02005d4:	4889                	li	a7,2
ffffffffc02005d6:	00000073          	ecall
ffffffffc02005da:	2501                	sext.w	a0,a0
ffffffffc02005dc:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005de:	062000ef          	jal	ra,ffffffffc0200640 <intr_enable>
}
ffffffffc02005e2:	60e2                	ld	ra,24(sp)
ffffffffc02005e4:	6522                	ld	a0,8(sp)
ffffffffc02005e6:	6105                	addi	sp,sp,32
ffffffffc02005e8:	8082                	ret

ffffffffc02005ea <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005ea:	8082                	ret

ffffffffc02005ec <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005ec:	00253513          	sltiu	a0,a0,2
ffffffffc02005f0:	8082                	ret

ffffffffc02005f2 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02005f2:	03800513          	li	a0,56
ffffffffc02005f6:	8082                	ret

ffffffffc02005f8 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02005f8:	000a7797          	auipc	a5,0xa7
ffffffffc02005fc:	15078793          	addi	a5,a5,336 # ffffffffc02a7748 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc0200600:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200604:	1141                	addi	sp,sp,-16
ffffffffc0200606:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200608:	95be                	add	a1,a1,a5
ffffffffc020060a:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020060e:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200610:	0ca060ef          	jal	ra,ffffffffc02066da <memcpy>
    return 0;
}
ffffffffc0200614:	60a2                	ld	ra,8(sp)
ffffffffc0200616:	4501                	li	a0,0
ffffffffc0200618:	0141                	addi	sp,sp,16
ffffffffc020061a:	8082                	ret

ffffffffc020061c <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc020061c:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200620:	000a7517          	auipc	a0,0xa7
ffffffffc0200624:	12850513          	addi	a0,a0,296 # ffffffffc02a7748 <ide>
                   size_t nsecs) {
ffffffffc0200628:	1141                	addi	sp,sp,-16
ffffffffc020062a:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020062c:	953e                	add	a0,a0,a5
ffffffffc020062e:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc0200632:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200634:	0a6060ef          	jal	ra,ffffffffc02066da <memcpy>
    return 0;
}
ffffffffc0200638:	60a2                	ld	ra,8(sp)
ffffffffc020063a:	4501                	li	a0,0
ffffffffc020063c:	0141                	addi	sp,sp,16
ffffffffc020063e:	8082                	ret

ffffffffc0200640 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200640:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200644:	8082                	ret

ffffffffc0200646 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200646:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020064a:	8082                	ret

ffffffffc020064c <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc020064c:	8082                	ret

ffffffffc020064e <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020064e:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200652:	00000797          	auipc	a5,0x0
ffffffffc0200656:	65a78793          	addi	a5,a5,1626 # ffffffffc0200cac <__alltraps>
ffffffffc020065a:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020065e:	000407b7          	lui	a5,0x40
ffffffffc0200662:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200666:	8082                	ret

ffffffffc0200668 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200668:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020066a:	1141                	addi	sp,sp,-16
ffffffffc020066c:	e022                	sd	s0,0(sp)
ffffffffc020066e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200670:	00006517          	auipc	a0,0x6
ffffffffc0200674:	39850513          	addi	a0,a0,920 # ffffffffc0206a08 <commands+0xa8>
void print_regs(struct pushregs* gpr) {
ffffffffc0200678:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067a:	b07ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020067e:	640c                	ld	a1,8(s0)
ffffffffc0200680:	00006517          	auipc	a0,0x6
ffffffffc0200684:	3a050513          	addi	a0,a0,928 # ffffffffc0206a20 <commands+0xc0>
ffffffffc0200688:	af9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020068c:	680c                	ld	a1,16(s0)
ffffffffc020068e:	00006517          	auipc	a0,0x6
ffffffffc0200692:	3aa50513          	addi	a0,a0,938 # ffffffffc0206a38 <commands+0xd8>
ffffffffc0200696:	aebff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069a:	6c0c                	ld	a1,24(s0)
ffffffffc020069c:	00006517          	auipc	a0,0x6
ffffffffc02006a0:	3b450513          	addi	a0,a0,948 # ffffffffc0206a50 <commands+0xf0>
ffffffffc02006a4:	addff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a8:	700c                	ld	a1,32(s0)
ffffffffc02006aa:	00006517          	auipc	a0,0x6
ffffffffc02006ae:	3be50513          	addi	a0,a0,958 # ffffffffc0206a68 <commands+0x108>
ffffffffc02006b2:	acfff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b6:	740c                	ld	a1,40(s0)
ffffffffc02006b8:	00006517          	auipc	a0,0x6
ffffffffc02006bc:	3c850513          	addi	a0,a0,968 # ffffffffc0206a80 <commands+0x120>
ffffffffc02006c0:	ac1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c4:	780c                	ld	a1,48(s0)
ffffffffc02006c6:	00006517          	auipc	a0,0x6
ffffffffc02006ca:	3d250513          	addi	a0,a0,978 # ffffffffc0206a98 <commands+0x138>
ffffffffc02006ce:	ab3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d2:	7c0c                	ld	a1,56(s0)
ffffffffc02006d4:	00006517          	auipc	a0,0x6
ffffffffc02006d8:	3dc50513          	addi	a0,a0,988 # ffffffffc0206ab0 <commands+0x150>
ffffffffc02006dc:	aa5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e0:	602c                	ld	a1,64(s0)
ffffffffc02006e2:	00006517          	auipc	a0,0x6
ffffffffc02006e6:	3e650513          	addi	a0,a0,998 # ffffffffc0206ac8 <commands+0x168>
ffffffffc02006ea:	a97ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ee:	642c                	ld	a1,72(s0)
ffffffffc02006f0:	00006517          	auipc	a0,0x6
ffffffffc02006f4:	3f050513          	addi	a0,a0,1008 # ffffffffc0206ae0 <commands+0x180>
ffffffffc02006f8:	a89ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006fc:	682c                	ld	a1,80(s0)
ffffffffc02006fe:	00006517          	auipc	a0,0x6
ffffffffc0200702:	3fa50513          	addi	a0,a0,1018 # ffffffffc0206af8 <commands+0x198>
ffffffffc0200706:	a7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070a:	6c2c                	ld	a1,88(s0)
ffffffffc020070c:	00006517          	auipc	a0,0x6
ffffffffc0200710:	40450513          	addi	a0,a0,1028 # ffffffffc0206b10 <commands+0x1b0>
ffffffffc0200714:	a6dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200718:	702c                	ld	a1,96(s0)
ffffffffc020071a:	00006517          	auipc	a0,0x6
ffffffffc020071e:	40e50513          	addi	a0,a0,1038 # ffffffffc0206b28 <commands+0x1c8>
ffffffffc0200722:	a5fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200726:	742c                	ld	a1,104(s0)
ffffffffc0200728:	00006517          	auipc	a0,0x6
ffffffffc020072c:	41850513          	addi	a0,a0,1048 # ffffffffc0206b40 <commands+0x1e0>
ffffffffc0200730:	a51ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200734:	782c                	ld	a1,112(s0)
ffffffffc0200736:	00006517          	auipc	a0,0x6
ffffffffc020073a:	42250513          	addi	a0,a0,1058 # ffffffffc0206b58 <commands+0x1f8>
ffffffffc020073e:	a43ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200742:	7c2c                	ld	a1,120(s0)
ffffffffc0200744:	00006517          	auipc	a0,0x6
ffffffffc0200748:	42c50513          	addi	a0,a0,1068 # ffffffffc0206b70 <commands+0x210>
ffffffffc020074c:	a35ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200750:	604c                	ld	a1,128(s0)
ffffffffc0200752:	00006517          	auipc	a0,0x6
ffffffffc0200756:	43650513          	addi	a0,a0,1078 # ffffffffc0206b88 <commands+0x228>
ffffffffc020075a:	a27ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020075e:	644c                	ld	a1,136(s0)
ffffffffc0200760:	00006517          	auipc	a0,0x6
ffffffffc0200764:	44050513          	addi	a0,a0,1088 # ffffffffc0206ba0 <commands+0x240>
ffffffffc0200768:	a19ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020076c:	684c                	ld	a1,144(s0)
ffffffffc020076e:	00006517          	auipc	a0,0x6
ffffffffc0200772:	44a50513          	addi	a0,a0,1098 # ffffffffc0206bb8 <commands+0x258>
ffffffffc0200776:	a0bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077a:	6c4c                	ld	a1,152(s0)
ffffffffc020077c:	00006517          	auipc	a0,0x6
ffffffffc0200780:	45450513          	addi	a0,a0,1108 # ffffffffc0206bd0 <commands+0x270>
ffffffffc0200784:	9fdff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200788:	704c                	ld	a1,160(s0)
ffffffffc020078a:	00006517          	auipc	a0,0x6
ffffffffc020078e:	45e50513          	addi	a0,a0,1118 # ffffffffc0206be8 <commands+0x288>
ffffffffc0200792:	9efff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200796:	744c                	ld	a1,168(s0)
ffffffffc0200798:	00006517          	auipc	a0,0x6
ffffffffc020079c:	46850513          	addi	a0,a0,1128 # ffffffffc0206c00 <commands+0x2a0>
ffffffffc02007a0:	9e1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a4:	784c                	ld	a1,176(s0)
ffffffffc02007a6:	00006517          	auipc	a0,0x6
ffffffffc02007aa:	47250513          	addi	a0,a0,1138 # ffffffffc0206c18 <commands+0x2b8>
ffffffffc02007ae:	9d3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b2:	7c4c                	ld	a1,184(s0)
ffffffffc02007b4:	00006517          	auipc	a0,0x6
ffffffffc02007b8:	47c50513          	addi	a0,a0,1148 # ffffffffc0206c30 <commands+0x2d0>
ffffffffc02007bc:	9c5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c0:	606c                	ld	a1,192(s0)
ffffffffc02007c2:	00006517          	auipc	a0,0x6
ffffffffc02007c6:	48650513          	addi	a0,a0,1158 # ffffffffc0206c48 <commands+0x2e8>
ffffffffc02007ca:	9b7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ce:	646c                	ld	a1,200(s0)
ffffffffc02007d0:	00006517          	auipc	a0,0x6
ffffffffc02007d4:	49050513          	addi	a0,a0,1168 # ffffffffc0206c60 <commands+0x300>
ffffffffc02007d8:	9a9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007dc:	686c                	ld	a1,208(s0)
ffffffffc02007de:	00006517          	auipc	a0,0x6
ffffffffc02007e2:	49a50513          	addi	a0,a0,1178 # ffffffffc0206c78 <commands+0x318>
ffffffffc02007e6:	99bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ea:	6c6c                	ld	a1,216(s0)
ffffffffc02007ec:	00006517          	auipc	a0,0x6
ffffffffc02007f0:	4a450513          	addi	a0,a0,1188 # ffffffffc0206c90 <commands+0x330>
ffffffffc02007f4:	98dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f8:	706c                	ld	a1,224(s0)
ffffffffc02007fa:	00006517          	auipc	a0,0x6
ffffffffc02007fe:	4ae50513          	addi	a0,a0,1198 # ffffffffc0206ca8 <commands+0x348>
ffffffffc0200802:	97fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200806:	746c                	ld	a1,232(s0)
ffffffffc0200808:	00006517          	auipc	a0,0x6
ffffffffc020080c:	4b850513          	addi	a0,a0,1208 # ffffffffc0206cc0 <commands+0x360>
ffffffffc0200810:	971ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200814:	786c                	ld	a1,240(s0)
ffffffffc0200816:	00006517          	auipc	a0,0x6
ffffffffc020081a:	4c250513          	addi	a0,a0,1218 # ffffffffc0206cd8 <commands+0x378>
ffffffffc020081e:	963ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200824:	6402                	ld	s0,0(sp)
ffffffffc0200826:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200828:	00006517          	auipc	a0,0x6
ffffffffc020082c:	4c850513          	addi	a0,a0,1224 # ffffffffc0206cf0 <commands+0x390>
}
ffffffffc0200830:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200832:	b2b9                	j	ffffffffc0200180 <cprintf>

ffffffffc0200834 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200834:	1141                	addi	sp,sp,-16
ffffffffc0200836:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200838:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc020083a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	4cc50513          	addi	a0,a0,1228 # ffffffffc0206d08 <commands+0x3a8>
print_trapframe(struct trapframe *tf) {
ffffffffc0200844:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200846:	93bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    print_regs(&tf->gpr);
ffffffffc020084a:	8522                	mv	a0,s0
ffffffffc020084c:	e1dff0ef          	jal	ra,ffffffffc0200668 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200850:	10043583          	ld	a1,256(s0)
ffffffffc0200854:	00006517          	auipc	a0,0x6
ffffffffc0200858:	4cc50513          	addi	a0,a0,1228 # ffffffffc0206d20 <commands+0x3c0>
ffffffffc020085c:	925ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200860:	10843583          	ld	a1,264(s0)
ffffffffc0200864:	00006517          	auipc	a0,0x6
ffffffffc0200868:	4d450513          	addi	a0,a0,1236 # ffffffffc0206d38 <commands+0x3d8>
ffffffffc020086c:	915ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200870:	11043583          	ld	a1,272(s0)
ffffffffc0200874:	00006517          	auipc	a0,0x6
ffffffffc0200878:	4dc50513          	addi	a0,a0,1244 # ffffffffc0206d50 <commands+0x3f0>
ffffffffc020087c:	905ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200880:	11843583          	ld	a1,280(s0)
}
ffffffffc0200884:	6402                	ld	s0,0(sp)
ffffffffc0200886:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200888:	00006517          	auipc	a0,0x6
ffffffffc020088c:	4d850513          	addi	a0,a0,1240 # ffffffffc0206d60 <commands+0x400>
}
ffffffffc0200890:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200892:	8efff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0200896 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200896:	1101                	addi	sp,sp,-32
ffffffffc0200898:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc020089a:	000b2497          	auipc	s1,0xb2
ffffffffc020089e:	fde48493          	addi	s1,s1,-34 # ffffffffc02b2878 <check_mm_struct>
ffffffffc02008a2:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a4:	e822                	sd	s0,16(sp)
ffffffffc02008a6:	ec06                	sd	ra,24(sp)
ffffffffc02008a8:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008aa:	cbad                	beqz	a5,ffffffffc020091c <pgfault_handler+0x86>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ac:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008b0:	11053583          	ld	a1,272(a0)
ffffffffc02008b4:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008b8:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008bc:	c7b1                	beqz	a5,ffffffffc0200908 <pgfault_handler+0x72>
ffffffffc02008be:	11843703          	ld	a4,280(s0)
ffffffffc02008c2:	47bd                	li	a5,15
ffffffffc02008c4:	05700693          	li	a3,87
ffffffffc02008c8:	00f70463          	beq	a4,a5,ffffffffc02008d0 <pgfault_handler+0x3a>
ffffffffc02008cc:	05200693          	li	a3,82
ffffffffc02008d0:	00006517          	auipc	a0,0x6
ffffffffc02008d4:	4a850513          	addi	a0,a0,1192 # ffffffffc0206d78 <commands+0x418>
ffffffffc02008d8:	8a9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008dc:	6088                	ld	a0,0(s1)
ffffffffc02008de:	cd1d                	beqz	a0,ffffffffc020091c <pgfault_handler+0x86>
        assert(current == idleproc);
ffffffffc02008e0:	000b2717          	auipc	a4,0xb2
ffffffffc02008e4:	fa873703          	ld	a4,-88(a4) # ffffffffc02b2888 <current>
ffffffffc02008e8:	000b2797          	auipc	a5,0xb2
ffffffffc02008ec:	fa87b783          	ld	a5,-88(a5) # ffffffffc02b2890 <idleproc>
ffffffffc02008f0:	04f71663          	bne	a4,a5,ffffffffc020093c <pgfault_handler+0xa6>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008f4:	11043603          	ld	a2,272(s0)
ffffffffc02008f8:	11843583          	ld	a1,280(s0)
}
ffffffffc02008fc:	6442                	ld	s0,16(sp)
ffffffffc02008fe:	60e2                	ld	ra,24(sp)
ffffffffc0200900:	64a2                	ld	s1,8(sp)
ffffffffc0200902:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200904:	1f00406f          	j	ffffffffc0204af4 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200908:	11843703          	ld	a4,280(s0)
ffffffffc020090c:	47bd                	li	a5,15
ffffffffc020090e:	05500613          	li	a2,85
ffffffffc0200912:	05700693          	li	a3,87
ffffffffc0200916:	faf71be3          	bne	a4,a5,ffffffffc02008cc <pgfault_handler+0x36>
ffffffffc020091a:	bf5d                	j	ffffffffc02008d0 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020091c:	000b2797          	auipc	a5,0xb2
ffffffffc0200920:	f6c7b783          	ld	a5,-148(a5) # ffffffffc02b2888 <current>
ffffffffc0200924:	cf85                	beqz	a5,ffffffffc020095c <pgfault_handler+0xc6>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200926:	11043603          	ld	a2,272(s0)
ffffffffc020092a:	11843583          	ld	a1,280(s0)
}
ffffffffc020092e:	6442                	ld	s0,16(sp)
ffffffffc0200930:	60e2                	ld	ra,24(sp)
ffffffffc0200932:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200934:	7788                	ld	a0,40(a5)
}
ffffffffc0200936:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200938:	1bc0406f          	j	ffffffffc0204af4 <do_pgfault>
        assert(current == idleproc);
ffffffffc020093c:	00006697          	auipc	a3,0x6
ffffffffc0200940:	45c68693          	addi	a3,a3,1116 # ffffffffc0206d98 <commands+0x438>
ffffffffc0200944:	00006617          	auipc	a2,0x6
ffffffffc0200948:	46c60613          	addi	a2,a2,1132 # ffffffffc0206db0 <commands+0x450>
ffffffffc020094c:	06b00593          	li	a1,107
ffffffffc0200950:	00006517          	auipc	a0,0x6
ffffffffc0200954:	47850513          	addi	a0,a0,1144 # ffffffffc0206dc8 <commands+0x468>
ffffffffc0200958:	b23ff0ef          	jal	ra,ffffffffc020047a <__panic>
            print_trapframe(tf);
ffffffffc020095c:	8522                	mv	a0,s0
ffffffffc020095e:	ed7ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200962:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200966:	11043583          	ld	a1,272(s0)
ffffffffc020096a:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020096e:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200972:	e399                	bnez	a5,ffffffffc0200978 <pgfault_handler+0xe2>
ffffffffc0200974:	05500613          	li	a2,85
ffffffffc0200978:	11843703          	ld	a4,280(s0)
ffffffffc020097c:	47bd                	li	a5,15
ffffffffc020097e:	02f70663          	beq	a4,a5,ffffffffc02009aa <pgfault_handler+0x114>
ffffffffc0200982:	05200693          	li	a3,82
ffffffffc0200986:	00006517          	auipc	a0,0x6
ffffffffc020098a:	3f250513          	addi	a0,a0,1010 # ffffffffc0206d78 <commands+0x418>
ffffffffc020098e:	ff2ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200992:	00006617          	auipc	a2,0x6
ffffffffc0200996:	44e60613          	addi	a2,a2,1102 # ffffffffc0206de0 <commands+0x480>
ffffffffc020099a:	07200593          	li	a1,114
ffffffffc020099e:	00006517          	auipc	a0,0x6
ffffffffc02009a2:	42a50513          	addi	a0,a0,1066 # ffffffffc0206dc8 <commands+0x468>
ffffffffc02009a6:	ad5ff0ef          	jal	ra,ffffffffc020047a <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009aa:	05700693          	li	a3,87
ffffffffc02009ae:	bfe1                	j	ffffffffc0200986 <pgfault_handler+0xf0>

ffffffffc02009b0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009b0:	11853783          	ld	a5,280(a0)
ffffffffc02009b4:	472d                	li	a4,11
ffffffffc02009b6:	0786                	slli	a5,a5,0x1
ffffffffc02009b8:	8385                	srli	a5,a5,0x1
ffffffffc02009ba:	08f76363          	bltu	a4,a5,ffffffffc0200a40 <interrupt_handler+0x90>
ffffffffc02009be:	00006717          	auipc	a4,0x6
ffffffffc02009c2:	4da70713          	addi	a4,a4,1242 # ffffffffc0206e98 <commands+0x538>
ffffffffc02009c6:	078a                	slli	a5,a5,0x2
ffffffffc02009c8:	97ba                	add	a5,a5,a4
ffffffffc02009ca:	439c                	lw	a5,0(a5)
ffffffffc02009cc:	97ba                	add	a5,a5,a4
ffffffffc02009ce:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009d0:	00006517          	auipc	a0,0x6
ffffffffc02009d4:	48850513          	addi	a0,a0,1160 # ffffffffc0206e58 <commands+0x4f8>
ffffffffc02009d8:	fa8ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009dc:	00006517          	auipc	a0,0x6
ffffffffc02009e0:	45c50513          	addi	a0,a0,1116 # ffffffffc0206e38 <commands+0x4d8>
ffffffffc02009e4:	f9cff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009e8:	00006517          	auipc	a0,0x6
ffffffffc02009ec:	41050513          	addi	a0,a0,1040 # ffffffffc0206df8 <commands+0x498>
ffffffffc02009f0:	f90ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009f4:	00006517          	auipc	a0,0x6
ffffffffc02009f8:	42450513          	addi	a0,a0,1060 # ffffffffc0206e18 <commands+0x4b8>
ffffffffc02009fc:	f84ff06f          	j	ffffffffc0200180 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a00:	1141                	addi	sp,sp,-16
ffffffffc0200a02:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200a04:	b5bff0ef          	jal	ra,ffffffffc020055e <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a08:	000b2697          	auipc	a3,0xb2
ffffffffc0200a0c:	e1068693          	addi	a3,a3,-496 # ffffffffc02b2818 <ticks>
ffffffffc0200a10:	629c                	ld	a5,0(a3)
ffffffffc0200a12:	06400713          	li	a4,100
ffffffffc0200a16:	0785                	addi	a5,a5,1
ffffffffc0200a18:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a1c:	e29c                	sd	a5,0(a3)
ffffffffc0200a1e:	eb01                	bnez	a4,ffffffffc0200a2e <interrupt_handler+0x7e>
ffffffffc0200a20:	000b2797          	auipc	a5,0xb2
ffffffffc0200a24:	e687b783          	ld	a5,-408(a5) # ffffffffc02b2888 <current>
ffffffffc0200a28:	c399                	beqz	a5,ffffffffc0200a2e <interrupt_handler+0x7e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc0200a2a:	4705                	li	a4,1
ffffffffc0200a2c:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a2e:	60a2                	ld	ra,8(sp)
ffffffffc0200a30:	0141                	addi	sp,sp,16
ffffffffc0200a32:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a34:	00006517          	auipc	a0,0x6
ffffffffc0200a38:	44450513          	addi	a0,a0,1092 # ffffffffc0206e78 <commands+0x518>
ffffffffc0200a3c:	f44ff06f          	j	ffffffffc0200180 <cprintf>
            print_trapframe(tf);
ffffffffc0200a40:	bbd5                	j	ffffffffc0200834 <print_trapframe>

ffffffffc0200a42 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) { //通过中断帧里 scause寄存器的数值，判断出当前是来自USER_ECALL的异常
ffffffffc0200a42:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a46:	1101                	addi	sp,sp,-32
ffffffffc0200a48:	e822                	sd	s0,16(sp)
ffffffffc0200a4a:	ec06                	sd	ra,24(sp)
ffffffffc0200a4c:	e426                	sd	s1,8(sp)
ffffffffc0200a4e:	473d                	li	a4,15
ffffffffc0200a50:	842a                	mv	s0,a0
ffffffffc0200a52:	18f76563          	bltu	a4,a5,ffffffffc0200bdc <exception_handler+0x19a>
ffffffffc0200a56:	00006717          	auipc	a4,0x6
ffffffffc0200a5a:	60a70713          	addi	a4,a4,1546 # ffffffffc0207060 <commands+0x700>
ffffffffc0200a5e:	078a                	slli	a5,a5,0x2
ffffffffc0200a60:	97ba                	add	a5,a5,a4
ffffffffc0200a62:	439c                	lw	a5,0(a5)
ffffffffc0200a64:	97ba                	add	a5,a5,a4
ffffffffc0200a66:	8782                	jr	a5
            //对于ecall, 我们希望sepc寄存器要指向产生异常的指令(ecall)的下一条指令
            //否则就会回到ecall执行再执行一次ecall, 无限循环
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a68:	00006517          	auipc	a0,0x6
ffffffffc0200a6c:	55050513          	addi	a0,a0,1360 # ffffffffc0206fb8 <commands+0x658>
ffffffffc0200a70:	f10ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            tf->epc += 4;
ffffffffc0200a74:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a78:	60e2                	ld	ra,24(sp)
ffffffffc0200a7a:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a7c:	0791                	addi	a5,a5,4
ffffffffc0200a7e:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a82:	6442                	ld	s0,16(sp)
ffffffffc0200a84:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a86:	7420506f          	j	ffffffffc02061c8 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a8a:	00006517          	auipc	a0,0x6
ffffffffc0200a8e:	54e50513          	addi	a0,a0,1358 # ffffffffc0206fd8 <commands+0x678>
}
ffffffffc0200a92:	6442                	ld	s0,16(sp)
ffffffffc0200a94:	60e2                	ld	ra,24(sp)
ffffffffc0200a96:	64a2                	ld	s1,8(sp)
ffffffffc0200a98:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a9a:	ee6ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a9e:	00006517          	auipc	a0,0x6
ffffffffc0200aa2:	55a50513          	addi	a0,a0,1370 # ffffffffc0206ff8 <commands+0x698>
ffffffffc0200aa6:	b7f5                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200aa8:	00006517          	auipc	a0,0x6
ffffffffc0200aac:	57050513          	addi	a0,a0,1392 # ffffffffc0207018 <commands+0x6b8>
ffffffffc0200ab0:	b7cd                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	57e50513          	addi	a0,a0,1406 # ffffffffc0207030 <commands+0x6d0>
ffffffffc0200aba:	ec6ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200abe:	8522                	mv	a0,s0
ffffffffc0200ac0:	dd7ff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200ac4:	84aa                	mv	s1,a0
ffffffffc0200ac6:	12051d63          	bnez	a0,ffffffffc0200c00 <exception_handler+0x1be>
}
ffffffffc0200aca:	60e2                	ld	ra,24(sp)
ffffffffc0200acc:	6442                	ld	s0,16(sp)
ffffffffc0200ace:	64a2                	ld	s1,8(sp)
ffffffffc0200ad0:	6105                	addi	sp,sp,32
ffffffffc0200ad2:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200ad4:	00006517          	auipc	a0,0x6
ffffffffc0200ad8:	57450513          	addi	a0,a0,1396 # ffffffffc0207048 <commands+0x6e8>
ffffffffc0200adc:	ea4ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae0:	8522                	mv	a0,s0
ffffffffc0200ae2:	db5ff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200ae6:	84aa                	mv	s1,a0
ffffffffc0200ae8:	d16d                	beqz	a0,ffffffffc0200aca <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200aea:	8522                	mv	a0,s0
ffffffffc0200aec:	d49ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200af0:	86a6                	mv	a3,s1
ffffffffc0200af2:	00006617          	auipc	a2,0x6
ffffffffc0200af6:	47660613          	addi	a2,a2,1142 # ffffffffc0206f68 <commands+0x608>
ffffffffc0200afa:	0fb00593          	li	a1,251
ffffffffc0200afe:	00006517          	auipc	a0,0x6
ffffffffc0200b02:	2ca50513          	addi	a0,a0,714 # ffffffffc0206dc8 <commands+0x468>
ffffffffc0200b06:	975ff0ef          	jal	ra,ffffffffc020047a <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b0a:	00006517          	auipc	a0,0x6
ffffffffc0200b0e:	3be50513          	addi	a0,a0,958 # ffffffffc0206ec8 <commands+0x568>
ffffffffc0200b12:	b741                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b14:	00006517          	auipc	a0,0x6
ffffffffc0200b18:	3d450513          	addi	a0,a0,980 # ffffffffc0206ee8 <commands+0x588>
ffffffffc0200b1c:	bf9d                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b1e:	00006517          	auipc	a0,0x6
ffffffffc0200b22:	3ea50513          	addi	a0,a0,1002 # ffffffffc0206f08 <commands+0x5a8>
ffffffffc0200b26:	b7b5                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b28:	00006517          	auipc	a0,0x6
ffffffffc0200b2c:	3f850513          	addi	a0,a0,1016 # ffffffffc0206f20 <commands+0x5c0>
ffffffffc0200b30:	e50ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b34:	6458                	ld	a4,136(s0)
ffffffffc0200b36:	47a9                	li	a5,10
ffffffffc0200b38:	f8f719e3          	bne	a4,a5,ffffffffc0200aca <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b3c:	10843783          	ld	a5,264(s0)
ffffffffc0200b40:	0791                	addi	a5,a5,4
ffffffffc0200b42:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b46:	682050ef          	jal	ra,ffffffffc02061c8 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b4a:	000b2797          	auipc	a5,0xb2
ffffffffc0200b4e:	d3e7b783          	ld	a5,-706(a5) # ffffffffc02b2888 <current>
ffffffffc0200b52:	6b9c                	ld	a5,16(a5)
ffffffffc0200b54:	8522                	mv	a0,s0
}
ffffffffc0200b56:	6442                	ld	s0,16(sp)
ffffffffc0200b58:	60e2                	ld	ra,24(sp)
ffffffffc0200b5a:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b5c:	6589                	lui	a1,0x2
ffffffffc0200b5e:	95be                	add	a1,a1,a5
}
ffffffffc0200b60:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b62:	ac21                	j	ffffffffc0200d7a <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b64:	00006517          	auipc	a0,0x6
ffffffffc0200b68:	3cc50513          	addi	a0,a0,972 # ffffffffc0206f30 <commands+0x5d0>
ffffffffc0200b6c:	b71d                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b6e:	00006517          	auipc	a0,0x6
ffffffffc0200b72:	3e250513          	addi	a0,a0,994 # ffffffffc0206f50 <commands+0x5f0>
ffffffffc0200b76:	e0aff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b7a:	8522                	mv	a0,s0
ffffffffc0200b7c:	d1bff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200b80:	84aa                	mv	s1,a0
ffffffffc0200b82:	d521                	beqz	a0,ffffffffc0200aca <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b84:	8522                	mv	a0,s0
ffffffffc0200b86:	cafff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b8a:	86a6                	mv	a3,s1
ffffffffc0200b8c:	00006617          	auipc	a2,0x6
ffffffffc0200b90:	3dc60613          	addi	a2,a2,988 # ffffffffc0206f68 <commands+0x608>
ffffffffc0200b94:	0cd00593          	li	a1,205
ffffffffc0200b98:	00006517          	auipc	a0,0x6
ffffffffc0200b9c:	23050513          	addi	a0,a0,560 # ffffffffc0206dc8 <commands+0x468>
ffffffffc0200ba0:	8dbff0ef          	jal	ra,ffffffffc020047a <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200ba4:	00006517          	auipc	a0,0x6
ffffffffc0200ba8:	3fc50513          	addi	a0,a0,1020 # ffffffffc0206fa0 <commands+0x640>
ffffffffc0200bac:	dd4ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bb0:	8522                	mv	a0,s0
ffffffffc0200bb2:	ce5ff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200bb6:	84aa                	mv	s1,a0
ffffffffc0200bb8:	f00509e3          	beqz	a0,ffffffffc0200aca <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bbc:	8522                	mv	a0,s0
ffffffffc0200bbe:	c77ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bc2:	86a6                	mv	a3,s1
ffffffffc0200bc4:	00006617          	auipc	a2,0x6
ffffffffc0200bc8:	3a460613          	addi	a2,a2,932 # ffffffffc0206f68 <commands+0x608>
ffffffffc0200bcc:	0d700593          	li	a1,215
ffffffffc0200bd0:	00006517          	auipc	a0,0x6
ffffffffc0200bd4:	1f850513          	addi	a0,a0,504 # ffffffffc0206dc8 <commands+0x468>
ffffffffc0200bd8:	8a3ff0ef          	jal	ra,ffffffffc020047a <__panic>
            print_trapframe(tf);
ffffffffc0200bdc:	8522                	mv	a0,s0
}
ffffffffc0200bde:	6442                	ld	s0,16(sp)
ffffffffc0200be0:	60e2                	ld	ra,24(sp)
ffffffffc0200be2:	64a2                	ld	s1,8(sp)
ffffffffc0200be4:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200be6:	b1b9                	j	ffffffffc0200834 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200be8:	00006617          	auipc	a2,0x6
ffffffffc0200bec:	3a060613          	addi	a2,a2,928 # ffffffffc0206f88 <commands+0x628>
ffffffffc0200bf0:	0d100593          	li	a1,209
ffffffffc0200bf4:	00006517          	auipc	a0,0x6
ffffffffc0200bf8:	1d450513          	addi	a0,a0,468 # ffffffffc0206dc8 <commands+0x468>
ffffffffc0200bfc:	87fff0ef          	jal	ra,ffffffffc020047a <__panic>
                print_trapframe(tf);
ffffffffc0200c00:	8522                	mv	a0,s0
ffffffffc0200c02:	c33ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c06:	86a6                	mv	a3,s1
ffffffffc0200c08:	00006617          	auipc	a2,0x6
ffffffffc0200c0c:	36060613          	addi	a2,a2,864 # ffffffffc0206f68 <commands+0x608>
ffffffffc0200c10:	0f400593          	li	a1,244
ffffffffc0200c14:	00006517          	auipc	a0,0x6
ffffffffc0200c18:	1b450513          	addi	a0,a0,436 # ffffffffc0206dc8 <commands+0x468>
ffffffffc0200c1c:	85fff0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0200c20 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c20:	1101                	addi	sp,sp,-32
ffffffffc0200c22:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c24:	000b2417          	auipc	s0,0xb2
ffffffffc0200c28:	c6440413          	addi	s0,s0,-924 # ffffffffc02b2888 <current>
ffffffffc0200c2c:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c2e:	ec06                	sd	ra,24(sp)
ffffffffc0200c30:	e426                	sd	s1,8(sp)
ffffffffc0200c32:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c34:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c38:	cf1d                	beqz	a4,ffffffffc0200c76 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c3a:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c3e:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c42:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c44:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c48:	0206c463          	bltz	a3,ffffffffc0200c70 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c4c:	df7ff0ef          	jal	ra,ffffffffc0200a42 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c50:	601c                	ld	a5,0(s0)
ffffffffc0200c52:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c56:	e499                	bnez	s1,ffffffffc0200c64 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c58:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c5c:	8b05                	andi	a4,a4,1
ffffffffc0200c5e:	e329                	bnez	a4,ffffffffc0200ca0 <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c60:	6f9c                	ld	a5,24(a5)
ffffffffc0200c62:	eb85                	bnez	a5,ffffffffc0200c92 <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c64:	60e2                	ld	ra,24(sp)
ffffffffc0200c66:	6442                	ld	s0,16(sp)
ffffffffc0200c68:	64a2                	ld	s1,8(sp)
ffffffffc0200c6a:	6902                	ld	s2,0(sp)
ffffffffc0200c6c:	6105                	addi	sp,sp,32
ffffffffc0200c6e:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c70:	d41ff0ef          	jal	ra,ffffffffc02009b0 <interrupt_handler>
ffffffffc0200c74:	bff1                	j	ffffffffc0200c50 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c76:	0006c863          	bltz	a3,ffffffffc0200c86 <trap+0x66>
}
ffffffffc0200c7a:	6442                	ld	s0,16(sp)
ffffffffc0200c7c:	60e2                	ld	ra,24(sp)
ffffffffc0200c7e:	64a2                	ld	s1,8(sp)
ffffffffc0200c80:	6902                	ld	s2,0(sp)
ffffffffc0200c82:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c84:	bb7d                	j	ffffffffc0200a42 <exception_handler>
}
ffffffffc0200c86:	6442                	ld	s0,16(sp)
ffffffffc0200c88:	60e2                	ld	ra,24(sp)
ffffffffc0200c8a:	64a2                	ld	s1,8(sp)
ffffffffc0200c8c:	6902                	ld	s2,0(sp)
ffffffffc0200c8e:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c90:	b305                	j	ffffffffc02009b0 <interrupt_handler>
}
ffffffffc0200c92:	6442                	ld	s0,16(sp)
ffffffffc0200c94:	60e2                	ld	ra,24(sp)
ffffffffc0200c96:	64a2                	ld	s1,8(sp)
ffffffffc0200c98:	6902                	ld	s2,0(sp)
ffffffffc0200c9a:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c9c:	4400506f          	j	ffffffffc02060dc <schedule>
                do_exit(-E_KILLED);
ffffffffc0200ca0:	555d                	li	a0,-9
ffffffffc0200ca2:	784040ef          	jal	ra,ffffffffc0205426 <do_exit>
            if (current->need_resched) {
ffffffffc0200ca6:	601c                	ld	a5,0(s0)
ffffffffc0200ca8:	bf65                	j	ffffffffc0200c60 <trap+0x40>
	...

ffffffffc0200cac <__alltraps>:
    LOAD x2, 2*REGBYTES(sp) #如果是用户态产生的中断，此时sp恢复为用户栈指针
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cac:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200cb0:	00011463          	bnez	sp,ffffffffc0200cb8 <__alltraps+0xc>
ffffffffc0200cb4:	14002173          	csrr	sp,sscratch
ffffffffc0200cb8:	712d                	addi	sp,sp,-288
ffffffffc0200cba:	e002                	sd	zero,0(sp)
ffffffffc0200cbc:	e406                	sd	ra,8(sp)
ffffffffc0200cbe:	ec0e                	sd	gp,24(sp)
ffffffffc0200cc0:	f012                	sd	tp,32(sp)
ffffffffc0200cc2:	f416                	sd	t0,40(sp)
ffffffffc0200cc4:	f81a                	sd	t1,48(sp)
ffffffffc0200cc6:	fc1e                	sd	t2,56(sp)
ffffffffc0200cc8:	e0a2                	sd	s0,64(sp)
ffffffffc0200cca:	e4a6                	sd	s1,72(sp)
ffffffffc0200ccc:	e8aa                	sd	a0,80(sp)
ffffffffc0200cce:	ecae                	sd	a1,88(sp)
ffffffffc0200cd0:	f0b2                	sd	a2,96(sp)
ffffffffc0200cd2:	f4b6                	sd	a3,104(sp)
ffffffffc0200cd4:	f8ba                	sd	a4,112(sp)
ffffffffc0200cd6:	fcbe                	sd	a5,120(sp)
ffffffffc0200cd8:	e142                	sd	a6,128(sp)
ffffffffc0200cda:	e546                	sd	a7,136(sp)
ffffffffc0200cdc:	e94a                	sd	s2,144(sp)
ffffffffc0200cde:	ed4e                	sd	s3,152(sp)
ffffffffc0200ce0:	f152                	sd	s4,160(sp)
ffffffffc0200ce2:	f556                	sd	s5,168(sp)
ffffffffc0200ce4:	f95a                	sd	s6,176(sp)
ffffffffc0200ce6:	fd5e                	sd	s7,184(sp)
ffffffffc0200ce8:	e1e2                	sd	s8,192(sp)
ffffffffc0200cea:	e5e6                	sd	s9,200(sp)
ffffffffc0200cec:	e9ea                	sd	s10,208(sp)
ffffffffc0200cee:	edee                	sd	s11,216(sp)
ffffffffc0200cf0:	f1f2                	sd	t3,224(sp)
ffffffffc0200cf2:	f5f6                	sd	t4,232(sp)
ffffffffc0200cf4:	f9fa                	sd	t5,240(sp)
ffffffffc0200cf6:	fdfe                	sd	t6,248(sp)
ffffffffc0200cf8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cfc:	100024f3          	csrr	s1,sstatus
ffffffffc0200d00:	14102973          	csrr	s2,sepc
ffffffffc0200d04:	143029f3          	csrr	s3,stval
ffffffffc0200d08:	14202a73          	csrr	s4,scause
ffffffffc0200d0c:	e822                	sd	s0,16(sp)
ffffffffc0200d0e:	e226                	sd	s1,256(sp)
ffffffffc0200d10:	e64a                	sd	s2,264(sp)
ffffffffc0200d12:	ea4e                	sd	s3,272(sp)
ffffffffc0200d14:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d16:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d18:	f09ff0ef          	jal	ra,ffffffffc0200c20 <trap>

ffffffffc0200d1c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d1c:	6492                	ld	s1,256(sp)
ffffffffc0200d1e:	6932                	ld	s2,264(sp)
ffffffffc0200d20:	1004f413          	andi	s0,s1,256
ffffffffc0200d24:	e401                	bnez	s0,ffffffffc0200d2c <__trapret+0x10>
ffffffffc0200d26:	1200                	addi	s0,sp,288
ffffffffc0200d28:	14041073          	csrw	sscratch,s0
ffffffffc0200d2c:	10049073          	csrw	sstatus,s1
ffffffffc0200d30:	14191073          	csrw	sepc,s2
ffffffffc0200d34:	60a2                	ld	ra,8(sp)
ffffffffc0200d36:	61e2                	ld	gp,24(sp)
ffffffffc0200d38:	7202                	ld	tp,32(sp)
ffffffffc0200d3a:	72a2                	ld	t0,40(sp)
ffffffffc0200d3c:	7342                	ld	t1,48(sp)
ffffffffc0200d3e:	73e2                	ld	t2,56(sp)
ffffffffc0200d40:	6406                	ld	s0,64(sp)
ffffffffc0200d42:	64a6                	ld	s1,72(sp)
ffffffffc0200d44:	6546                	ld	a0,80(sp)
ffffffffc0200d46:	65e6                	ld	a1,88(sp)
ffffffffc0200d48:	7606                	ld	a2,96(sp)
ffffffffc0200d4a:	76a6                	ld	a3,104(sp)
ffffffffc0200d4c:	7746                	ld	a4,112(sp)
ffffffffc0200d4e:	77e6                	ld	a5,120(sp)
ffffffffc0200d50:	680a                	ld	a6,128(sp)
ffffffffc0200d52:	68aa                	ld	a7,136(sp)
ffffffffc0200d54:	694a                	ld	s2,144(sp)
ffffffffc0200d56:	69ea                	ld	s3,152(sp)
ffffffffc0200d58:	7a0a                	ld	s4,160(sp)
ffffffffc0200d5a:	7aaa                	ld	s5,168(sp)
ffffffffc0200d5c:	7b4a                	ld	s6,176(sp)
ffffffffc0200d5e:	7bea                	ld	s7,184(sp)
ffffffffc0200d60:	6c0e                	ld	s8,192(sp)
ffffffffc0200d62:	6cae                	ld	s9,200(sp)
ffffffffc0200d64:	6d4e                	ld	s10,208(sp)
ffffffffc0200d66:	6dee                	ld	s11,216(sp)
ffffffffc0200d68:	7e0e                	ld	t3,224(sp)
ffffffffc0200d6a:	7eae                	ld	t4,232(sp)
ffffffffc0200d6c:	7f4e                	ld	t5,240(sp)
ffffffffc0200d6e:	7fee                	ld	t6,248(sp)
ffffffffc0200d70:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d72:	10200073          	sret

ffffffffc0200d76 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d76:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d78:	b755                	j	ffffffffc0200d1c <__trapret>

ffffffffc0200d7a <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d7a:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd0>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d7e:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d82:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d86:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d8a:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d8e:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d92:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d96:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d9a:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d9e:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200da0:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200da2:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200da4:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200da6:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200da8:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200daa:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dac:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dae:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200db0:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200db2:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200db4:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200db6:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200db8:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dba:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200dbc:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200dbe:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200dc0:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200dc2:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200dc4:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dc6:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dc8:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dca:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200dcc:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200dce:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dd0:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dd2:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200dd4:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dd6:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200dd8:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dda:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200ddc:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dde:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200de0:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200de2:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200de4:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200de6:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200de8:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dea:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200dec:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200dee:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200df0:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200df2:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200df4:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200df6:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200df8:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200dfa:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200dfc:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200dfe:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e00:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e02:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e04:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e06:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e08:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e0a:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e0c:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e0e:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e10:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e12:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e14:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e16:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e18:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e1a:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e1c:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e1e:	812e                	mv	sp,a1
ffffffffc0200e20:	bdf5                	j	ffffffffc0200d1c <__trapret>

ffffffffc0200e22 <shared_read_state>:
#include <sync.h>
#include <vmm.h>
#include <riscv.h>

bool shared_read_state(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end,bool share)
{
ffffffffc0200e22:	711d                	addi	sp,sp,-96
ffffffffc0200e24:	f852                	sd	s4,48(sp)
ffffffffc0200e26:	8a2a                	mv	s4,a0
    cprintf("COW:以共享只读状态创建子进程\n");
ffffffffc0200e28:	00006517          	auipc	a0,0x6
ffffffffc0200e2c:	27850513          	addi	a0,a0,632 # ffffffffc02070a0 <commands+0x740>
{
ffffffffc0200e30:	e4a6                	sd	s1,72(sp)
ffffffffc0200e32:	e0ca                	sd	s2,64(sp)
ffffffffc0200e34:	e06a                	sd	s10,0(sp)
ffffffffc0200e36:	84b6                	mv	s1,a3
ffffffffc0200e38:	8d32                	mv	s10,a2
ffffffffc0200e3a:	ec86                	sd	ra,88(sp)
ffffffffc0200e3c:	e8a2                	sd	s0,80(sp)
ffffffffc0200e3e:	fc4e                	sd	s3,56(sp)
ffffffffc0200e40:	f456                	sd	s5,40(sp)
ffffffffc0200e42:	f05a                	sd	s6,32(sp)
ffffffffc0200e44:	ec5e                	sd	s7,24(sp)
ffffffffc0200e46:	e862                	sd	s8,16(sp)
ffffffffc0200e48:	e466                	sd	s9,8(sp)
ffffffffc0200e4a:	892e                	mv	s2,a1
    cprintf("COW:以共享只读状态创建子进程\n");
ffffffffc0200e4c:	b34ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0200e50:	009d67b3          	or	a5,s10,s1
ffffffffc0200e54:	17d2                	slli	a5,a5,0x34
ffffffffc0200e56:	14079c63          	bnez	a5,ffffffffc0200fae <shared_read_state+0x18c>
    assert(USER_ACCESS(start, end));
ffffffffc0200e5a:	002007b7          	lui	a5,0x200
ffffffffc0200e5e:	10fd6d63          	bltu	s10,a5,ffffffffc0200f78 <shared_read_state+0x156>
ffffffffc0200e62:	109d7b63          	bgeu	s10,s1,ffffffffc0200f78 <shared_read_state+0x156>
ffffffffc0200e66:	4785                	li	a5,1
ffffffffc0200e68:	07fe                	slli	a5,a5,0x1f
ffffffffc0200e6a:	1097e763          	bltu	a5,s1,ffffffffc0200f78 <shared_read_state+0x156>
            assert(page != NULL);
            assert(npage != NULL);
            ret = page_insert(to, npage, start, perm);
            assert(ret == 0);
        }
        start += PGSIZE;
ffffffffc0200e6e:	6985                	lui	s3,0x1
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200e70:	000b2b97          	auipc	s7,0xb2
ffffffffc0200e74:	9d0b8b93          	addi	s7,s7,-1584 # ffffffffc02b2840 <npage>
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200e78:	000b2b17          	auipc	s6,0xb2
ffffffffc0200e7c:	9d0b0b13          	addi	s6,s6,-1584 # ffffffffc02b2848 <pages>
ffffffffc0200e80:	00008a97          	auipc	s5,0x8
ffffffffc0200e84:	fc8a8a93          	addi	s5,s5,-56 # ffffffffc0208e48 <nbase>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0200e88:	00200cb7          	lui	s9,0x200
ffffffffc0200e8c:	ffe00c37          	lui	s8,0xffe00
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0200e90:	4601                	li	a2,0
ffffffffc0200e92:	85ea                	mv	a1,s10
ffffffffc0200e94:	854a                	mv	a0,s2
ffffffffc0200e96:	282010ef          	jal	ra,ffffffffc0202118 <get_pte>
ffffffffc0200e9a:	842a                	mv	s0,a0
        if (ptep == NULL) 
ffffffffc0200e9c:	c941                	beqz	a0,ffffffffc0200f2c <shared_read_state+0x10a>
        if (*ptep & PTE_V)
ffffffffc0200e9e:	611c                	ld	a5,0(a0)
ffffffffc0200ea0:	8b85                	andi	a5,a5,1
ffffffffc0200ea2:	e39d                	bnez	a5,ffffffffc0200ec8 <shared_read_state+0xa6>
        start += PGSIZE;
ffffffffc0200ea4:	9d4e                	add	s10,s10,s3
    } 
    while (start != 0 && start < end);
ffffffffc0200ea6:	fe9d65e3          	bltu	s10,s1,ffffffffc0200e90 <shared_read_state+0x6e>
    return 0;
ffffffffc0200eaa:	4501                	li	a0,0
}
ffffffffc0200eac:	60e6                	ld	ra,88(sp)
ffffffffc0200eae:	6446                	ld	s0,80(sp)
ffffffffc0200eb0:	64a6                	ld	s1,72(sp)
ffffffffc0200eb2:	6906                	ld	s2,64(sp)
ffffffffc0200eb4:	79e2                	ld	s3,56(sp)
ffffffffc0200eb6:	7a42                	ld	s4,48(sp)
ffffffffc0200eb8:	7aa2                	ld	s5,40(sp)
ffffffffc0200eba:	7b02                	ld	s6,32(sp)
ffffffffc0200ebc:	6be2                	ld	s7,24(sp)
ffffffffc0200ebe:	6c42                	ld	s8,16(sp)
ffffffffc0200ec0:	6ca2                	ld	s9,8(sp)
ffffffffc0200ec2:	6d02                	ld	s10,0(sp)
ffffffffc0200ec4:	6125                	addi	sp,sp,96
ffffffffc0200ec6:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) return -E_NO_MEM;
ffffffffc0200ec8:	4605                	li	a2,1
ffffffffc0200eca:	85ea                	mv	a1,s10
ffffffffc0200ecc:	8552                	mv	a0,s4
ffffffffc0200ece:	24a010ef          	jal	ra,ffffffffc0202118 <get_pte>
ffffffffc0200ed2:	c52d                	beqz	a0,ffffffffc0200f3c <shared_read_state+0x11a>
            uint32_t perm = (*ptep & PTE_USER & (~PTE_W));
ffffffffc0200ed4:	6018                	ld	a4,0(s0)
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
    if (!(pte & PTE_V)) {
ffffffffc0200ed6:	00177793          	andi	a5,a4,1
ffffffffc0200eda:	01b77693          	andi	a3,a4,27
ffffffffc0200ede:	cfc5                	beqz	a5,ffffffffc0200f96 <shared_read_state+0x174>
    if (PPN(pa) >= npage) {
ffffffffc0200ee0:	000bb603          	ld	a2,0(s7)
        panic("pte2page called with invalid pte");
    }
    return pa2page(PTE_ADDR(pte));
ffffffffc0200ee4:	00271793          	slli	a5,a4,0x2
ffffffffc0200ee8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200eea:	06c7fb63          	bgeu	a5,a2,ffffffffc0200f60 <shared_read_state+0x13e>
    return &pages[PPN(pa) - nbase];
ffffffffc0200eee:	000ab603          	ld	a2,0(s5)
ffffffffc0200ef2:	000b3583          	ld	a1,0(s6)
            (*ptep) = *ptep & (~PTE_W); // 页面设置为只读
ffffffffc0200ef6:	9b6d                	andi	a4,a4,-5
ffffffffc0200ef8:	8f91                	sub	a5,a5,a2
ffffffffc0200efa:	079a                	slli	a5,a5,0x6
ffffffffc0200efc:	95be                	add	a1,a1,a5
ffffffffc0200efe:	e018                	sd	a4,0(s0)
            assert(page != NULL);
ffffffffc0200f00:	c1a1                	beqz	a1,ffffffffc0200f40 <shared_read_state+0x11e>
            ret = page_insert(to, npage, start, perm);
ffffffffc0200f02:	866a                	mv	a2,s10
ffffffffc0200f04:	8552                	mv	a0,s4
ffffffffc0200f06:	0ad010ef          	jal	ra,ffffffffc02027b2 <page_insert>
            assert(ret == 0);
ffffffffc0200f0a:	dd49                	beqz	a0,ffffffffc0200ea4 <shared_read_state+0x82>
ffffffffc0200f0c:	00006697          	auipc	a3,0x6
ffffffffc0200f10:	28468693          	addi	a3,a3,644 # ffffffffc0207190 <commands+0x830>
ffffffffc0200f14:	00006617          	auipc	a2,0x6
ffffffffc0200f18:	e9c60613          	addi	a2,a2,-356 # ffffffffc0206db0 <commands+0x450>
ffffffffc0200f1c:	02f00593          	li	a1,47
ffffffffc0200f20:	00006517          	auipc	a0,0x6
ffffffffc0200f24:	1e050513          	addi	a0,a0,480 # ffffffffc0207100 <commands+0x7a0>
ffffffffc0200f28:	d52ff0ef          	jal	ra,ffffffffc020047a <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0200f2c:	9d66                	add	s10,s10,s9
ffffffffc0200f2e:	018d7d33          	and	s10,s10,s8
    while (start != 0 && start < end);
ffffffffc0200f32:	f60d0ce3          	beqz	s10,ffffffffc0200eaa <shared_read_state+0x88>
ffffffffc0200f36:	f49d6de3          	bltu	s10,s1,ffffffffc0200e90 <shared_read_state+0x6e>
ffffffffc0200f3a:	bf85                	j	ffffffffc0200eaa <shared_read_state+0x88>
            if ((nptep = get_pte(to, start, 1)) == NULL) return -E_NO_MEM;
ffffffffc0200f3c:	5571                	li	a0,-4
ffffffffc0200f3e:	b7bd                	j	ffffffffc0200eac <shared_read_state+0x8a>
            assert(page != NULL);
ffffffffc0200f40:	00006697          	auipc	a3,0x6
ffffffffc0200f44:	24068693          	addi	a3,a3,576 # ffffffffc0207180 <commands+0x820>
ffffffffc0200f48:	00006617          	auipc	a2,0x6
ffffffffc0200f4c:	e6860613          	addi	a2,a2,-408 # ffffffffc0206db0 <commands+0x450>
ffffffffc0200f50:	02c00593          	li	a1,44
ffffffffc0200f54:	00006517          	auipc	a0,0x6
ffffffffc0200f58:	1ac50513          	addi	a0,a0,428 # ffffffffc0207100 <commands+0x7a0>
ffffffffc0200f5c:	d1eff0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200f60:	00006617          	auipc	a2,0x6
ffffffffc0200f64:	20060613          	addi	a2,a2,512 # ffffffffc0207160 <commands+0x800>
ffffffffc0200f68:	06200593          	li	a1,98
ffffffffc0200f6c:	00006517          	auipc	a0,0x6
ffffffffc0200f70:	1e450513          	addi	a0,a0,484 # ffffffffc0207150 <commands+0x7f0>
ffffffffc0200f74:	d06ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0200f78:	00006697          	auipc	a3,0x6
ffffffffc0200f7c:	19868693          	addi	a3,a3,408 # ffffffffc0207110 <commands+0x7b0>
ffffffffc0200f80:	00006617          	auipc	a2,0x6
ffffffffc0200f84:	e3060613          	addi	a2,a2,-464 # ffffffffc0206db0 <commands+0x450>
ffffffffc0200f88:	45d1                	li	a1,20
ffffffffc0200f8a:	00006517          	auipc	a0,0x6
ffffffffc0200f8e:	17650513          	addi	a0,a0,374 # ffffffffc0207100 <commands+0x7a0>
ffffffffc0200f92:	ce8ff0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0200f96:	00006617          	auipc	a2,0x6
ffffffffc0200f9a:	19260613          	addi	a2,a2,402 # ffffffffc0207128 <commands+0x7c8>
ffffffffc0200f9e:	07400593          	li	a1,116
ffffffffc0200fa2:	00006517          	auipc	a0,0x6
ffffffffc0200fa6:	1ae50513          	addi	a0,a0,430 # ffffffffc0207150 <commands+0x7f0>
ffffffffc0200faa:	cd0ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0200fae:	00006697          	auipc	a3,0x6
ffffffffc0200fb2:	12268693          	addi	a3,a3,290 # ffffffffc02070d0 <commands+0x770>
ffffffffc0200fb6:	00006617          	auipc	a2,0x6
ffffffffc0200fba:	dfa60613          	addi	a2,a2,-518 # ffffffffc0206db0 <commands+0x450>
ffffffffc0200fbe:	45cd                	li	a1,19
ffffffffc0200fc0:	00006517          	auipc	a0,0x6
ffffffffc0200fc4:	14050513          	addi	a0,a0,320 # ffffffffc0207100 <commands+0x7a0>
ffffffffc0200fc8:	cb2ff0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0200fcc <privated_write_state>:

int privated_write_state(struct mm_struct *mm, uint_t error_code, uintptr_t addr)
{
ffffffffc0200fcc:	715d                	addi	sp,sp,-80
ffffffffc0200fce:	f84a                	sd	s2,48(sp)
ffffffffc0200fd0:	892a                	mv	s2,a0
    cprintf("COW:由共享只读状态变为私有可写状态\n");
ffffffffc0200fd2:	00006517          	auipc	a0,0x6
ffffffffc0200fd6:	1ce50513          	addi	a0,a0,462 # ffffffffc02071a0 <commands+0x840>
{
ffffffffc0200fda:	e486                	sd	ra,72(sp)
ffffffffc0200fdc:	fc26                	sd	s1,56(sp)
ffffffffc0200fde:	e0a2                	sd	s0,64(sp)
ffffffffc0200fe0:	84b2                	mv	s1,a2
ffffffffc0200fe2:	f44e                	sd	s3,40(sp)
ffffffffc0200fe4:	f052                	sd	s4,32(sp)
ffffffffc0200fe6:	ec56                	sd	s5,24(sp)
ffffffffc0200fe8:	e85a                	sd	s6,16(sp)
ffffffffc0200fea:	e45e                	sd	s7,8(sp)
ffffffffc0200fec:	e062                	sd	s8,0(sp)
    cprintf("COW:由共享只读状态变为私有可写状态\n");
ffffffffc0200fee:	992ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0200ff2:	01893503          	ld	a0,24(s2)
ffffffffc0200ff6:	85a6                	mv	a1,s1
ffffffffc0200ff8:	4601                	li	a2,0
ffffffffc0200ffa:	11e010ef          	jal	ra,ffffffffc0202118 <get_pte>
    uint32_t perm = (*ptep & PTE_USER | PTE_W);
ffffffffc0200ffe:	611c                	ld	a5,0(a0)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201000:	75fd                	lui	a1,0xfffff
ffffffffc0201002:	8ced                	and	s1,s1,a1
    if (!(pte & PTE_V)) {
ffffffffc0201004:	0017f713          	andi	a4,a5,1
ffffffffc0201008:	12070763          	beqz	a4,ffffffffc0201136 <privated_write_state+0x16a>
    if (PPN(pa) >= npage) {
ffffffffc020100c:	000b2b97          	auipc	s7,0xb2
ffffffffc0201010:	834b8b93          	addi	s7,s7,-1996 # ffffffffc02b2840 <npage>
ffffffffc0201014:	000bb703          	ld	a4,0(s7)
ffffffffc0201018:	01b7f993          	andi	s3,a5,27
    return pa2page(PTE_ADDR(pte));
ffffffffc020101c:	078a                	slli	a5,a5,0x2
ffffffffc020101e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201020:	0ee7ff63          	bgeu	a5,a4,ffffffffc020111e <privated_write_state+0x152>
    return &pages[PPN(pa) - nbase];
ffffffffc0201024:	000b2c17          	auipc	s8,0xb2
ffffffffc0201028:	824c0c13          	addi	s8,s8,-2012 # ffffffffc02b2848 <pages>
ffffffffc020102c:	000c3403          	ld	s0,0(s8)
ffffffffc0201030:	00008b17          	auipc	s6,0x8
ffffffffc0201034:	e18b3b03          	ld	s6,-488(s6) # ffffffffc0208e48 <nbase>
ffffffffc0201038:	416787b3          	sub	a5,a5,s6
ffffffffc020103c:	8a2a                	mv	s4,a0
ffffffffc020103e:	079a                	slli	a5,a5,0x6
    struct Page *page = pte2page(*ptep);
    struct Page *npage = alloc_page();  // 分配新页面
ffffffffc0201040:	4505                	li	a0,1
ffffffffc0201042:	943e                	add	s0,s0,a5
ffffffffc0201044:	7c9000ef          	jal	ra,ffffffffc020200c <alloc_pages>
    (*ptep) = *ptep | (PTE_W);          // 页面设置为可写
ffffffffc0201048:	000a3703          	ld	a4,0(s4)
    struct Page *npage = alloc_page();  // 分配新页面
ffffffffc020104c:	8aaa                	mv	s5,a0
    (*ptep) = *ptep | (PTE_W);          // 页面设置为可写
ffffffffc020104e:	00476713          	ori	a4,a4,4
ffffffffc0201052:	00ea3023          	sd	a4,0(s4)
    assert(page != NULL);
ffffffffc0201056:	c445                	beqz	s0,ffffffffc02010fe <privated_write_state+0x132>
    assert(npage != NULL);
ffffffffc0201058:	c159                	beqz	a0,ffffffffc02010de <privated_write_state+0x112>
    return page - pages + nbase;
ffffffffc020105a:	000c3703          	ld	a4,0(s8)
    return KADDR(page2pa(page));
ffffffffc020105e:	567d                	li	a2,-1
ffffffffc0201060:	000bb803          	ld	a6,0(s7)
    return page - pages + nbase;
ffffffffc0201064:	40e406b3          	sub	a3,s0,a4
ffffffffc0201068:	8699                	srai	a3,a3,0x6
ffffffffc020106a:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc020106c:	8231                	srli	a2,a2,0xc
ffffffffc020106e:	00c6f7b3          	and	a5,a3,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201072:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201074:	0507f963          	bgeu	a5,a6,ffffffffc02010c6 <privated_write_state+0xfa>
    return page - pages + nbase;
ffffffffc0201078:	40e507b3          	sub	a5,a0,a4
ffffffffc020107c:	8799                	srai	a5,a5,0x6
ffffffffc020107e:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc0201080:	000b1517          	auipc	a0,0xb1
ffffffffc0201084:	7d853503          	ld	a0,2008(a0) # ffffffffc02b2858 <va_pa_offset>
ffffffffc0201088:	8e7d                	and	a2,a2,a5
ffffffffc020108a:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020108e:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0201090:	03067a63          	bgeu	a2,a6,ffffffffc02010c4 <privated_write_state+0xf8>
    int ret = 0;
    uintptr_t* src_kvaddr = page2kva(page);
    uintptr_t* dst_kvaddr = page2kva(npage);
    memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc0201094:	6605                	lui	a2,0x1
ffffffffc0201096:	953e                	add	a0,a0,a5
ffffffffc0201098:	642050ef          	jal	ra,ffffffffc02066da <memcpy>
    ret = page_insert(mm->pgdir, npage, start, perm);
ffffffffc020109c:	0049e993          	ori	s3,s3,4
    return ret;
ffffffffc02010a0:	6406                	ld	s0,64(sp)
    ret = page_insert(mm->pgdir, npage, start, perm);
ffffffffc02010a2:	01893503          	ld	a0,24(s2)
ffffffffc02010a6:	60a6                	ld	ra,72(sp)
ffffffffc02010a8:	7942                	ld	s2,48(sp)
ffffffffc02010aa:	7a02                	ld	s4,32(sp)
ffffffffc02010ac:	6b42                	ld	s6,16(sp)
ffffffffc02010ae:	6ba2                	ld	s7,8(sp)
ffffffffc02010b0:	6c02                	ld	s8,0(sp)
    ret = page_insert(mm->pgdir, npage, start, perm);
ffffffffc02010b2:	86ce                	mv	a3,s3
ffffffffc02010b4:	8626                	mv	a2,s1
ffffffffc02010b6:	79a2                	ld	s3,40(sp)
ffffffffc02010b8:	74e2                	ld	s1,56(sp)
    ret = page_insert(mm->pgdir, npage, start, perm);
ffffffffc02010ba:	85d6                	mv	a1,s5
ffffffffc02010bc:	6ae2                	ld	s5,24(sp)
ffffffffc02010be:	6161                	addi	sp,sp,80
    ret = page_insert(mm->pgdir, npage, start, perm);
ffffffffc02010c0:	6f20106f          	j	ffffffffc02027b2 <page_insert>
ffffffffc02010c4:	86be                	mv	a3,a5
ffffffffc02010c6:	00006617          	auipc	a2,0x6
ffffffffc02010ca:	12260613          	addi	a2,a2,290 # ffffffffc02071e8 <commands+0x888>
ffffffffc02010ce:	06900593          	li	a1,105
ffffffffc02010d2:	00006517          	auipc	a0,0x6
ffffffffc02010d6:	07e50513          	addi	a0,a0,126 # ffffffffc0207150 <commands+0x7f0>
ffffffffc02010da:	ba0ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(npage != NULL);
ffffffffc02010de:	00006697          	auipc	a3,0x6
ffffffffc02010e2:	0fa68693          	addi	a3,a3,250 # ffffffffc02071d8 <commands+0x878>
ffffffffc02010e6:	00006617          	auipc	a2,0x6
ffffffffc02010ea:	cca60613          	addi	a2,a2,-822 # ffffffffc0206db0 <commands+0x450>
ffffffffc02010ee:	04100593          	li	a1,65
ffffffffc02010f2:	00006517          	auipc	a0,0x6
ffffffffc02010f6:	00e50513          	addi	a0,a0,14 # ffffffffc0207100 <commands+0x7a0>
ffffffffc02010fa:	b80ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page != NULL);
ffffffffc02010fe:	00006697          	auipc	a3,0x6
ffffffffc0201102:	08268693          	addi	a3,a3,130 # ffffffffc0207180 <commands+0x820>
ffffffffc0201106:	00006617          	auipc	a2,0x6
ffffffffc020110a:	caa60613          	addi	a2,a2,-854 # ffffffffc0206db0 <commands+0x450>
ffffffffc020110e:	04000593          	li	a1,64
ffffffffc0201112:	00006517          	auipc	a0,0x6
ffffffffc0201116:	fee50513          	addi	a0,a0,-18 # ffffffffc0207100 <commands+0x7a0>
ffffffffc020111a:	b60ff0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020111e:	00006617          	auipc	a2,0x6
ffffffffc0201122:	04260613          	addi	a2,a2,66 # ffffffffc0207160 <commands+0x800>
ffffffffc0201126:	06200593          	li	a1,98
ffffffffc020112a:	00006517          	auipc	a0,0x6
ffffffffc020112e:	02650513          	addi	a0,a0,38 # ffffffffc0207150 <commands+0x7f0>
ffffffffc0201132:	b48ff0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201136:	00006617          	auipc	a2,0x6
ffffffffc020113a:	ff260613          	addi	a2,a2,-14 # ffffffffc0207128 <commands+0x7c8>
ffffffffc020113e:	07400593          	li	a1,116
ffffffffc0201142:	00006517          	auipc	a0,0x6
ffffffffc0201146:	00e50513          	addi	a0,a0,14 # ffffffffc0207150 <commands+0x7f0>
ffffffffc020114a:	b30ff0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020114e <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020114e:	000ad797          	auipc	a5,0xad
ffffffffc0201152:	5fa78793          	addi	a5,a5,1530 # ffffffffc02ae748 <free_area>
ffffffffc0201156:	e79c                	sd	a5,8(a5)
ffffffffc0201158:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020115a:	0007a823          	sw	zero,16(a5)
}
ffffffffc020115e:	8082                	ret

ffffffffc0201160 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0201160:	000ad517          	auipc	a0,0xad
ffffffffc0201164:	5f856503          	lwu	a0,1528(a0) # ffffffffc02ae758 <free_area+0x10>
ffffffffc0201168:	8082                	ret

ffffffffc020116a <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc020116a:	715d                	addi	sp,sp,-80
ffffffffc020116c:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020116e:	000ad417          	auipc	s0,0xad
ffffffffc0201172:	5da40413          	addi	s0,s0,1498 # ffffffffc02ae748 <free_area>
ffffffffc0201176:	641c                	ld	a5,8(s0)
ffffffffc0201178:	e486                	sd	ra,72(sp)
ffffffffc020117a:	fc26                	sd	s1,56(sp)
ffffffffc020117c:	f84a                	sd	s2,48(sp)
ffffffffc020117e:	f44e                	sd	s3,40(sp)
ffffffffc0201180:	f052                	sd	s4,32(sp)
ffffffffc0201182:	ec56                	sd	s5,24(sp)
ffffffffc0201184:	e85a                	sd	s6,16(sp)
ffffffffc0201186:	e45e                	sd	s7,8(sp)
ffffffffc0201188:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020118a:	2a878d63          	beq	a5,s0,ffffffffc0201444 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc020118e:	4481                	li	s1,0
ffffffffc0201190:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201192:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201196:	8b09                	andi	a4,a4,2
ffffffffc0201198:	2a070a63          	beqz	a4,ffffffffc020144c <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc020119c:	ff87a703          	lw	a4,-8(a5)
ffffffffc02011a0:	679c                	ld	a5,8(a5)
ffffffffc02011a2:	2905                	addiw	s2,s2,1
ffffffffc02011a4:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02011a6:	fe8796e3          	bne	a5,s0,ffffffffc0201192 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc02011aa:	89a6                	mv	s3,s1
ffffffffc02011ac:	733000ef          	jal	ra,ffffffffc02020de <nr_free_pages>
ffffffffc02011b0:	6f351e63          	bne	a0,s3,ffffffffc02018ac <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02011b4:	4505                	li	a0,1
ffffffffc02011b6:	657000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc02011ba:	8aaa                	mv	s5,a0
ffffffffc02011bc:	42050863          	beqz	a0,ffffffffc02015ec <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02011c0:	4505                	li	a0,1
ffffffffc02011c2:	64b000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc02011c6:	89aa                	mv	s3,a0
ffffffffc02011c8:	70050263          	beqz	a0,ffffffffc02018cc <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02011cc:	4505                	li	a0,1
ffffffffc02011ce:	63f000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc02011d2:	8a2a                	mv	s4,a0
ffffffffc02011d4:	48050c63          	beqz	a0,ffffffffc020166c <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02011d8:	293a8a63          	beq	s5,s3,ffffffffc020146c <default_check+0x302>
ffffffffc02011dc:	28aa8863          	beq	s5,a0,ffffffffc020146c <default_check+0x302>
ffffffffc02011e0:	28a98663          	beq	s3,a0,ffffffffc020146c <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02011e4:	000aa783          	lw	a5,0(s5)
ffffffffc02011e8:	2a079263          	bnez	a5,ffffffffc020148c <default_check+0x322>
ffffffffc02011ec:	0009a783          	lw	a5,0(s3) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc02011f0:	28079e63          	bnez	a5,ffffffffc020148c <default_check+0x322>
ffffffffc02011f4:	411c                	lw	a5,0(a0)
ffffffffc02011f6:	28079b63          	bnez	a5,ffffffffc020148c <default_check+0x322>
    return page - pages + nbase;
ffffffffc02011fa:	000b1797          	auipc	a5,0xb1
ffffffffc02011fe:	64e7b783          	ld	a5,1614(a5) # ffffffffc02b2848 <pages>
ffffffffc0201202:	40fa8733          	sub	a4,s5,a5
ffffffffc0201206:	00008617          	auipc	a2,0x8
ffffffffc020120a:	c4263603          	ld	a2,-958(a2) # ffffffffc0208e48 <nbase>
ffffffffc020120e:	8719                	srai	a4,a4,0x6
ffffffffc0201210:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201212:	000b1697          	auipc	a3,0xb1
ffffffffc0201216:	62e6b683          	ld	a3,1582(a3) # ffffffffc02b2840 <npage>
ffffffffc020121a:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020121c:	0732                	slli	a4,a4,0xc
ffffffffc020121e:	28d77763          	bgeu	a4,a3,ffffffffc02014ac <default_check+0x342>
    return page - pages + nbase;
ffffffffc0201222:	40f98733          	sub	a4,s3,a5
ffffffffc0201226:	8719                	srai	a4,a4,0x6
ffffffffc0201228:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020122a:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020122c:	4cd77063          	bgeu	a4,a3,ffffffffc02016ec <default_check+0x582>
    return page - pages + nbase;
ffffffffc0201230:	40f507b3          	sub	a5,a0,a5
ffffffffc0201234:	8799                	srai	a5,a5,0x6
ffffffffc0201236:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201238:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020123a:	30d7f963          	bgeu	a5,a3,ffffffffc020154c <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc020123e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201240:	00043c03          	ld	s8,0(s0)
ffffffffc0201244:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0201248:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc020124c:	e400                	sd	s0,8(s0)
ffffffffc020124e:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0201250:	000ad797          	auipc	a5,0xad
ffffffffc0201254:	5007a423          	sw	zero,1288(a5) # ffffffffc02ae758 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201258:	5b5000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc020125c:	2c051863          	bnez	a0,ffffffffc020152c <default_check+0x3c2>
    free_page(p0);
ffffffffc0201260:	4585                	li	a1,1
ffffffffc0201262:	8556                	mv	a0,s5
ffffffffc0201264:	63b000ef          	jal	ra,ffffffffc020209e <free_pages>
    free_page(p1);
ffffffffc0201268:	4585                	li	a1,1
ffffffffc020126a:	854e                	mv	a0,s3
ffffffffc020126c:	633000ef          	jal	ra,ffffffffc020209e <free_pages>
    free_page(p2);
ffffffffc0201270:	4585                	li	a1,1
ffffffffc0201272:	8552                	mv	a0,s4
ffffffffc0201274:	62b000ef          	jal	ra,ffffffffc020209e <free_pages>
    assert(nr_free == 3);
ffffffffc0201278:	4818                	lw	a4,16(s0)
ffffffffc020127a:	478d                	li	a5,3
ffffffffc020127c:	28f71863          	bne	a4,a5,ffffffffc020150c <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201280:	4505                	li	a0,1
ffffffffc0201282:	58b000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc0201286:	89aa                	mv	s3,a0
ffffffffc0201288:	26050263          	beqz	a0,ffffffffc02014ec <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020128c:	4505                	li	a0,1
ffffffffc020128e:	57f000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc0201292:	8aaa                	mv	s5,a0
ffffffffc0201294:	3a050c63          	beqz	a0,ffffffffc020164c <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201298:	4505                	li	a0,1
ffffffffc020129a:	573000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc020129e:	8a2a                	mv	s4,a0
ffffffffc02012a0:	38050663          	beqz	a0,ffffffffc020162c <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc02012a4:	4505                	li	a0,1
ffffffffc02012a6:	567000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc02012aa:	36051163          	bnez	a0,ffffffffc020160c <default_check+0x4a2>
    free_page(p0);
ffffffffc02012ae:	4585                	li	a1,1
ffffffffc02012b0:	854e                	mv	a0,s3
ffffffffc02012b2:	5ed000ef          	jal	ra,ffffffffc020209e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02012b6:	641c                	ld	a5,8(s0)
ffffffffc02012b8:	20878a63          	beq	a5,s0,ffffffffc02014cc <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc02012bc:	4505                	li	a0,1
ffffffffc02012be:	54f000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc02012c2:	30a99563          	bne	s3,a0,ffffffffc02015cc <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc02012c6:	4505                	li	a0,1
ffffffffc02012c8:	545000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc02012cc:	2e051063          	bnez	a0,ffffffffc02015ac <default_check+0x442>
    assert(nr_free == 0);
ffffffffc02012d0:	481c                	lw	a5,16(s0)
ffffffffc02012d2:	2a079d63          	bnez	a5,ffffffffc020158c <default_check+0x422>
    free_page(p);
ffffffffc02012d6:	854e                	mv	a0,s3
ffffffffc02012d8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02012da:	01843023          	sd	s8,0(s0)
ffffffffc02012de:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc02012e2:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02012e6:	5b9000ef          	jal	ra,ffffffffc020209e <free_pages>
    free_page(p1);
ffffffffc02012ea:	4585                	li	a1,1
ffffffffc02012ec:	8556                	mv	a0,s5
ffffffffc02012ee:	5b1000ef          	jal	ra,ffffffffc020209e <free_pages>
    free_page(p2);
ffffffffc02012f2:	4585                	li	a1,1
ffffffffc02012f4:	8552                	mv	a0,s4
ffffffffc02012f6:	5a9000ef          	jal	ra,ffffffffc020209e <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02012fa:	4515                	li	a0,5
ffffffffc02012fc:	511000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc0201300:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201302:	26050563          	beqz	a0,ffffffffc020156c <default_check+0x402>
ffffffffc0201306:	651c                	ld	a5,8(a0)
ffffffffc0201308:	8385                	srli	a5,a5,0x1
ffffffffc020130a:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc020130c:	54079063          	bnez	a5,ffffffffc020184c <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201310:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201312:	00043b03          	ld	s6,0(s0)
ffffffffc0201316:	00843a83          	ld	s5,8(s0)
ffffffffc020131a:	e000                	sd	s0,0(s0)
ffffffffc020131c:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc020131e:	4ef000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc0201322:	50051563          	bnez	a0,ffffffffc020182c <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201326:	08098a13          	addi	s4,s3,128
ffffffffc020132a:	8552                	mv	a0,s4
ffffffffc020132c:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc020132e:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0201332:	000ad797          	auipc	a5,0xad
ffffffffc0201336:	4207a323          	sw	zero,1062(a5) # ffffffffc02ae758 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020133a:	565000ef          	jal	ra,ffffffffc020209e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc020133e:	4511                	li	a0,4
ffffffffc0201340:	4cd000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc0201344:	4c051463          	bnez	a0,ffffffffc020180c <default_check+0x6a2>
ffffffffc0201348:	0889b783          	ld	a5,136(s3)
ffffffffc020134c:	8385                	srli	a5,a5,0x1
ffffffffc020134e:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201350:	48078e63          	beqz	a5,ffffffffc02017ec <default_check+0x682>
ffffffffc0201354:	0909a703          	lw	a4,144(s3)
ffffffffc0201358:	478d                	li	a5,3
ffffffffc020135a:	48f71963          	bne	a4,a5,ffffffffc02017ec <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020135e:	450d                	li	a0,3
ffffffffc0201360:	4ad000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc0201364:	8c2a                	mv	s8,a0
ffffffffc0201366:	46050363          	beqz	a0,ffffffffc02017cc <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc020136a:	4505                	li	a0,1
ffffffffc020136c:	4a1000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc0201370:	42051e63          	bnez	a0,ffffffffc02017ac <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0201374:	418a1c63          	bne	s4,s8,ffffffffc020178c <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201378:	4585                	li	a1,1
ffffffffc020137a:	854e                	mv	a0,s3
ffffffffc020137c:	523000ef          	jal	ra,ffffffffc020209e <free_pages>
    free_pages(p1, 3);
ffffffffc0201380:	458d                	li	a1,3
ffffffffc0201382:	8552                	mv	a0,s4
ffffffffc0201384:	51b000ef          	jal	ra,ffffffffc020209e <free_pages>
ffffffffc0201388:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc020138c:	04098c13          	addi	s8,s3,64
ffffffffc0201390:	8385                	srli	a5,a5,0x1
ffffffffc0201392:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201394:	3c078c63          	beqz	a5,ffffffffc020176c <default_check+0x602>
ffffffffc0201398:	0109a703          	lw	a4,16(s3)
ffffffffc020139c:	4785                	li	a5,1
ffffffffc020139e:	3cf71763          	bne	a4,a5,ffffffffc020176c <default_check+0x602>
ffffffffc02013a2:	008a3783          	ld	a5,8(s4)
ffffffffc02013a6:	8385                	srli	a5,a5,0x1
ffffffffc02013a8:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02013aa:	3a078163          	beqz	a5,ffffffffc020174c <default_check+0x5e2>
ffffffffc02013ae:	010a2703          	lw	a4,16(s4)
ffffffffc02013b2:	478d                	li	a5,3
ffffffffc02013b4:	38f71c63          	bne	a4,a5,ffffffffc020174c <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02013b8:	4505                	li	a0,1
ffffffffc02013ba:	453000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc02013be:	36a99763          	bne	s3,a0,ffffffffc020172c <default_check+0x5c2>
    free_page(p0);
ffffffffc02013c2:	4585                	li	a1,1
ffffffffc02013c4:	4db000ef          	jal	ra,ffffffffc020209e <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02013c8:	4509                	li	a0,2
ffffffffc02013ca:	443000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc02013ce:	32aa1f63          	bne	s4,a0,ffffffffc020170c <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc02013d2:	4589                	li	a1,2
ffffffffc02013d4:	4cb000ef          	jal	ra,ffffffffc020209e <free_pages>
    free_page(p2);
ffffffffc02013d8:	4585                	li	a1,1
ffffffffc02013da:	8562                	mv	a0,s8
ffffffffc02013dc:	4c3000ef          	jal	ra,ffffffffc020209e <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02013e0:	4515                	li	a0,5
ffffffffc02013e2:	42b000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc02013e6:	89aa                	mv	s3,a0
ffffffffc02013e8:	48050263          	beqz	a0,ffffffffc020186c <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc02013ec:	4505                	li	a0,1
ffffffffc02013ee:	41f000ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc02013f2:	2c051d63          	bnez	a0,ffffffffc02016cc <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02013f6:	481c                	lw	a5,16(s0)
ffffffffc02013f8:	2a079a63          	bnez	a5,ffffffffc02016ac <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02013fc:	4595                	li	a1,5
ffffffffc02013fe:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201400:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0201404:	01643023          	sd	s6,0(s0)
ffffffffc0201408:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc020140c:	493000ef          	jal	ra,ffffffffc020209e <free_pages>
    return listelm->next;
ffffffffc0201410:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201412:	00878963          	beq	a5,s0,ffffffffc0201424 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201416:	ff87a703          	lw	a4,-8(a5)
ffffffffc020141a:	679c                	ld	a5,8(a5)
ffffffffc020141c:	397d                	addiw	s2,s2,-1
ffffffffc020141e:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201420:	fe879be3          	bne	a5,s0,ffffffffc0201416 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0201424:	26091463          	bnez	s2,ffffffffc020168c <default_check+0x522>
    assert(total == 0);
ffffffffc0201428:	46049263          	bnez	s1,ffffffffc020188c <default_check+0x722>
}
ffffffffc020142c:	60a6                	ld	ra,72(sp)
ffffffffc020142e:	6406                	ld	s0,64(sp)
ffffffffc0201430:	74e2                	ld	s1,56(sp)
ffffffffc0201432:	7942                	ld	s2,48(sp)
ffffffffc0201434:	79a2                	ld	s3,40(sp)
ffffffffc0201436:	7a02                	ld	s4,32(sp)
ffffffffc0201438:	6ae2                	ld	s5,24(sp)
ffffffffc020143a:	6b42                	ld	s6,16(sp)
ffffffffc020143c:	6ba2                	ld	s7,8(sp)
ffffffffc020143e:	6c02                	ld	s8,0(sp)
ffffffffc0201440:	6161                	addi	sp,sp,80
ffffffffc0201442:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201444:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201446:	4481                	li	s1,0
ffffffffc0201448:	4901                	li	s2,0
ffffffffc020144a:	b38d                	j	ffffffffc02011ac <default_check+0x42>
        assert(PageProperty(p));
ffffffffc020144c:	00006697          	auipc	a3,0x6
ffffffffc0201450:	dc468693          	addi	a3,a3,-572 # ffffffffc0207210 <commands+0x8b0>
ffffffffc0201454:	00006617          	auipc	a2,0x6
ffffffffc0201458:	95c60613          	addi	a2,a2,-1700 # ffffffffc0206db0 <commands+0x450>
ffffffffc020145c:	0f000593          	li	a1,240
ffffffffc0201460:	00006517          	auipc	a0,0x6
ffffffffc0201464:	dc050513          	addi	a0,a0,-576 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201468:	812ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020146c:	00006697          	auipc	a3,0x6
ffffffffc0201470:	e4c68693          	addi	a3,a3,-436 # ffffffffc02072b8 <commands+0x958>
ffffffffc0201474:	00006617          	auipc	a2,0x6
ffffffffc0201478:	93c60613          	addi	a2,a2,-1732 # ffffffffc0206db0 <commands+0x450>
ffffffffc020147c:	0bd00593          	li	a1,189
ffffffffc0201480:	00006517          	auipc	a0,0x6
ffffffffc0201484:	da050513          	addi	a0,a0,-608 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201488:	ff3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020148c:	00006697          	auipc	a3,0x6
ffffffffc0201490:	e5468693          	addi	a3,a3,-428 # ffffffffc02072e0 <commands+0x980>
ffffffffc0201494:	00006617          	auipc	a2,0x6
ffffffffc0201498:	91c60613          	addi	a2,a2,-1764 # ffffffffc0206db0 <commands+0x450>
ffffffffc020149c:	0be00593          	li	a1,190
ffffffffc02014a0:	00006517          	auipc	a0,0x6
ffffffffc02014a4:	d8050513          	addi	a0,a0,-640 # ffffffffc0207220 <commands+0x8c0>
ffffffffc02014a8:	fd3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02014ac:	00006697          	auipc	a3,0x6
ffffffffc02014b0:	e7468693          	addi	a3,a3,-396 # ffffffffc0207320 <commands+0x9c0>
ffffffffc02014b4:	00006617          	auipc	a2,0x6
ffffffffc02014b8:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0206db0 <commands+0x450>
ffffffffc02014bc:	0c000593          	li	a1,192
ffffffffc02014c0:	00006517          	auipc	a0,0x6
ffffffffc02014c4:	d6050513          	addi	a0,a0,-672 # ffffffffc0207220 <commands+0x8c0>
ffffffffc02014c8:	fb3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(!list_empty(&free_list));
ffffffffc02014cc:	00006697          	auipc	a3,0x6
ffffffffc02014d0:	edc68693          	addi	a3,a3,-292 # ffffffffc02073a8 <commands+0xa48>
ffffffffc02014d4:	00006617          	auipc	a2,0x6
ffffffffc02014d8:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0206db0 <commands+0x450>
ffffffffc02014dc:	0d900593          	li	a1,217
ffffffffc02014e0:	00006517          	auipc	a0,0x6
ffffffffc02014e4:	d4050513          	addi	a0,a0,-704 # ffffffffc0207220 <commands+0x8c0>
ffffffffc02014e8:	f93fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02014ec:	00006697          	auipc	a3,0x6
ffffffffc02014f0:	d6c68693          	addi	a3,a3,-660 # ffffffffc0207258 <commands+0x8f8>
ffffffffc02014f4:	00006617          	auipc	a2,0x6
ffffffffc02014f8:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0206db0 <commands+0x450>
ffffffffc02014fc:	0d200593          	li	a1,210
ffffffffc0201500:	00006517          	auipc	a0,0x6
ffffffffc0201504:	d2050513          	addi	a0,a0,-736 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201508:	f73fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 3);
ffffffffc020150c:	00006697          	auipc	a3,0x6
ffffffffc0201510:	e8c68693          	addi	a3,a3,-372 # ffffffffc0207398 <commands+0xa38>
ffffffffc0201514:	00006617          	auipc	a2,0x6
ffffffffc0201518:	89c60613          	addi	a2,a2,-1892 # ffffffffc0206db0 <commands+0x450>
ffffffffc020151c:	0d000593          	li	a1,208
ffffffffc0201520:	00006517          	auipc	a0,0x6
ffffffffc0201524:	d0050513          	addi	a0,a0,-768 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201528:	f53fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc020152c:	00006697          	auipc	a3,0x6
ffffffffc0201530:	e5468693          	addi	a3,a3,-428 # ffffffffc0207380 <commands+0xa20>
ffffffffc0201534:	00006617          	auipc	a2,0x6
ffffffffc0201538:	87c60613          	addi	a2,a2,-1924 # ffffffffc0206db0 <commands+0x450>
ffffffffc020153c:	0cb00593          	li	a1,203
ffffffffc0201540:	00006517          	auipc	a0,0x6
ffffffffc0201544:	ce050513          	addi	a0,a0,-800 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201548:	f33fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020154c:	00006697          	auipc	a3,0x6
ffffffffc0201550:	e1468693          	addi	a3,a3,-492 # ffffffffc0207360 <commands+0xa00>
ffffffffc0201554:	00006617          	auipc	a2,0x6
ffffffffc0201558:	85c60613          	addi	a2,a2,-1956 # ffffffffc0206db0 <commands+0x450>
ffffffffc020155c:	0c200593          	li	a1,194
ffffffffc0201560:	00006517          	auipc	a0,0x6
ffffffffc0201564:	cc050513          	addi	a0,a0,-832 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201568:	f13fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 != NULL);
ffffffffc020156c:	00006697          	auipc	a3,0x6
ffffffffc0201570:	e8468693          	addi	a3,a3,-380 # ffffffffc02073f0 <commands+0xa90>
ffffffffc0201574:	00006617          	auipc	a2,0x6
ffffffffc0201578:	83c60613          	addi	a2,a2,-1988 # ffffffffc0206db0 <commands+0x450>
ffffffffc020157c:	0f800593          	li	a1,248
ffffffffc0201580:	00006517          	auipc	a0,0x6
ffffffffc0201584:	ca050513          	addi	a0,a0,-864 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201588:	ef3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 0);
ffffffffc020158c:	00006697          	auipc	a3,0x6
ffffffffc0201590:	e5468693          	addi	a3,a3,-428 # ffffffffc02073e0 <commands+0xa80>
ffffffffc0201594:	00006617          	auipc	a2,0x6
ffffffffc0201598:	81c60613          	addi	a2,a2,-2020 # ffffffffc0206db0 <commands+0x450>
ffffffffc020159c:	0df00593          	li	a1,223
ffffffffc02015a0:	00006517          	auipc	a0,0x6
ffffffffc02015a4:	c8050513          	addi	a0,a0,-896 # ffffffffc0207220 <commands+0x8c0>
ffffffffc02015a8:	ed3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02015ac:	00006697          	auipc	a3,0x6
ffffffffc02015b0:	dd468693          	addi	a3,a3,-556 # ffffffffc0207380 <commands+0xa20>
ffffffffc02015b4:	00005617          	auipc	a2,0x5
ffffffffc02015b8:	7fc60613          	addi	a2,a2,2044 # ffffffffc0206db0 <commands+0x450>
ffffffffc02015bc:	0dd00593          	li	a1,221
ffffffffc02015c0:	00006517          	auipc	a0,0x6
ffffffffc02015c4:	c6050513          	addi	a0,a0,-928 # ffffffffc0207220 <commands+0x8c0>
ffffffffc02015c8:	eb3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02015cc:	00006697          	auipc	a3,0x6
ffffffffc02015d0:	df468693          	addi	a3,a3,-524 # ffffffffc02073c0 <commands+0xa60>
ffffffffc02015d4:	00005617          	auipc	a2,0x5
ffffffffc02015d8:	7dc60613          	addi	a2,a2,2012 # ffffffffc0206db0 <commands+0x450>
ffffffffc02015dc:	0dc00593          	li	a1,220
ffffffffc02015e0:	00006517          	auipc	a0,0x6
ffffffffc02015e4:	c4050513          	addi	a0,a0,-960 # ffffffffc0207220 <commands+0x8c0>
ffffffffc02015e8:	e93fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02015ec:	00006697          	auipc	a3,0x6
ffffffffc02015f0:	c6c68693          	addi	a3,a3,-916 # ffffffffc0207258 <commands+0x8f8>
ffffffffc02015f4:	00005617          	auipc	a2,0x5
ffffffffc02015f8:	7bc60613          	addi	a2,a2,1980 # ffffffffc0206db0 <commands+0x450>
ffffffffc02015fc:	0b900593          	li	a1,185
ffffffffc0201600:	00006517          	auipc	a0,0x6
ffffffffc0201604:	c2050513          	addi	a0,a0,-992 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201608:	e73fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc020160c:	00006697          	auipc	a3,0x6
ffffffffc0201610:	d7468693          	addi	a3,a3,-652 # ffffffffc0207380 <commands+0xa20>
ffffffffc0201614:	00005617          	auipc	a2,0x5
ffffffffc0201618:	79c60613          	addi	a2,a2,1948 # ffffffffc0206db0 <commands+0x450>
ffffffffc020161c:	0d600593          	li	a1,214
ffffffffc0201620:	00006517          	auipc	a0,0x6
ffffffffc0201624:	c0050513          	addi	a0,a0,-1024 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201628:	e53fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020162c:	00006697          	auipc	a3,0x6
ffffffffc0201630:	c6c68693          	addi	a3,a3,-916 # ffffffffc0207298 <commands+0x938>
ffffffffc0201634:	00005617          	auipc	a2,0x5
ffffffffc0201638:	77c60613          	addi	a2,a2,1916 # ffffffffc0206db0 <commands+0x450>
ffffffffc020163c:	0d400593          	li	a1,212
ffffffffc0201640:	00006517          	auipc	a0,0x6
ffffffffc0201644:	be050513          	addi	a0,a0,-1056 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201648:	e33fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020164c:	00006697          	auipc	a3,0x6
ffffffffc0201650:	c2c68693          	addi	a3,a3,-980 # ffffffffc0207278 <commands+0x918>
ffffffffc0201654:	00005617          	auipc	a2,0x5
ffffffffc0201658:	75c60613          	addi	a2,a2,1884 # ffffffffc0206db0 <commands+0x450>
ffffffffc020165c:	0d300593          	li	a1,211
ffffffffc0201660:	00006517          	auipc	a0,0x6
ffffffffc0201664:	bc050513          	addi	a0,a0,-1088 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201668:	e13fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020166c:	00006697          	auipc	a3,0x6
ffffffffc0201670:	c2c68693          	addi	a3,a3,-980 # ffffffffc0207298 <commands+0x938>
ffffffffc0201674:	00005617          	auipc	a2,0x5
ffffffffc0201678:	73c60613          	addi	a2,a2,1852 # ffffffffc0206db0 <commands+0x450>
ffffffffc020167c:	0bb00593          	li	a1,187
ffffffffc0201680:	00006517          	auipc	a0,0x6
ffffffffc0201684:	ba050513          	addi	a0,a0,-1120 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201688:	df3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(count == 0);
ffffffffc020168c:	00006697          	auipc	a3,0x6
ffffffffc0201690:	eb468693          	addi	a3,a3,-332 # ffffffffc0207540 <commands+0xbe0>
ffffffffc0201694:	00005617          	auipc	a2,0x5
ffffffffc0201698:	71c60613          	addi	a2,a2,1820 # ffffffffc0206db0 <commands+0x450>
ffffffffc020169c:	12500593          	li	a1,293
ffffffffc02016a0:	00006517          	auipc	a0,0x6
ffffffffc02016a4:	b8050513          	addi	a0,a0,-1152 # ffffffffc0207220 <commands+0x8c0>
ffffffffc02016a8:	dd3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 0);
ffffffffc02016ac:	00006697          	auipc	a3,0x6
ffffffffc02016b0:	d3468693          	addi	a3,a3,-716 # ffffffffc02073e0 <commands+0xa80>
ffffffffc02016b4:	00005617          	auipc	a2,0x5
ffffffffc02016b8:	6fc60613          	addi	a2,a2,1788 # ffffffffc0206db0 <commands+0x450>
ffffffffc02016bc:	11a00593          	li	a1,282
ffffffffc02016c0:	00006517          	auipc	a0,0x6
ffffffffc02016c4:	b6050513          	addi	a0,a0,-1184 # ffffffffc0207220 <commands+0x8c0>
ffffffffc02016c8:	db3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02016cc:	00006697          	auipc	a3,0x6
ffffffffc02016d0:	cb468693          	addi	a3,a3,-844 # ffffffffc0207380 <commands+0xa20>
ffffffffc02016d4:	00005617          	auipc	a2,0x5
ffffffffc02016d8:	6dc60613          	addi	a2,a2,1756 # ffffffffc0206db0 <commands+0x450>
ffffffffc02016dc:	11800593          	li	a1,280
ffffffffc02016e0:	00006517          	auipc	a0,0x6
ffffffffc02016e4:	b4050513          	addi	a0,a0,-1216 # ffffffffc0207220 <commands+0x8c0>
ffffffffc02016e8:	d93fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02016ec:	00006697          	auipc	a3,0x6
ffffffffc02016f0:	c5468693          	addi	a3,a3,-940 # ffffffffc0207340 <commands+0x9e0>
ffffffffc02016f4:	00005617          	auipc	a2,0x5
ffffffffc02016f8:	6bc60613          	addi	a2,a2,1724 # ffffffffc0206db0 <commands+0x450>
ffffffffc02016fc:	0c100593          	li	a1,193
ffffffffc0201700:	00006517          	auipc	a0,0x6
ffffffffc0201704:	b2050513          	addi	a0,a0,-1248 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201708:	d73fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020170c:	00006697          	auipc	a3,0x6
ffffffffc0201710:	df468693          	addi	a3,a3,-524 # ffffffffc0207500 <commands+0xba0>
ffffffffc0201714:	00005617          	auipc	a2,0x5
ffffffffc0201718:	69c60613          	addi	a2,a2,1692 # ffffffffc0206db0 <commands+0x450>
ffffffffc020171c:	11200593          	li	a1,274
ffffffffc0201720:	00006517          	auipc	a0,0x6
ffffffffc0201724:	b0050513          	addi	a0,a0,-1280 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201728:	d53fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020172c:	00006697          	auipc	a3,0x6
ffffffffc0201730:	db468693          	addi	a3,a3,-588 # ffffffffc02074e0 <commands+0xb80>
ffffffffc0201734:	00005617          	auipc	a2,0x5
ffffffffc0201738:	67c60613          	addi	a2,a2,1660 # ffffffffc0206db0 <commands+0x450>
ffffffffc020173c:	11000593          	li	a1,272
ffffffffc0201740:	00006517          	auipc	a0,0x6
ffffffffc0201744:	ae050513          	addi	a0,a0,-1312 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201748:	d33fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020174c:	00006697          	auipc	a3,0x6
ffffffffc0201750:	d6c68693          	addi	a3,a3,-660 # ffffffffc02074b8 <commands+0xb58>
ffffffffc0201754:	00005617          	auipc	a2,0x5
ffffffffc0201758:	65c60613          	addi	a2,a2,1628 # ffffffffc0206db0 <commands+0x450>
ffffffffc020175c:	10e00593          	li	a1,270
ffffffffc0201760:	00006517          	auipc	a0,0x6
ffffffffc0201764:	ac050513          	addi	a0,a0,-1344 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201768:	d13fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020176c:	00006697          	auipc	a3,0x6
ffffffffc0201770:	d2468693          	addi	a3,a3,-732 # ffffffffc0207490 <commands+0xb30>
ffffffffc0201774:	00005617          	auipc	a2,0x5
ffffffffc0201778:	63c60613          	addi	a2,a2,1596 # ffffffffc0206db0 <commands+0x450>
ffffffffc020177c:	10d00593          	li	a1,269
ffffffffc0201780:	00006517          	auipc	a0,0x6
ffffffffc0201784:	aa050513          	addi	a0,a0,-1376 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201788:	cf3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 + 2 == p1);
ffffffffc020178c:	00006697          	auipc	a3,0x6
ffffffffc0201790:	cf468693          	addi	a3,a3,-780 # ffffffffc0207480 <commands+0xb20>
ffffffffc0201794:	00005617          	auipc	a2,0x5
ffffffffc0201798:	61c60613          	addi	a2,a2,1564 # ffffffffc0206db0 <commands+0x450>
ffffffffc020179c:	10800593          	li	a1,264
ffffffffc02017a0:	00006517          	auipc	a0,0x6
ffffffffc02017a4:	a8050513          	addi	a0,a0,-1408 # ffffffffc0207220 <commands+0x8c0>
ffffffffc02017a8:	cd3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02017ac:	00006697          	auipc	a3,0x6
ffffffffc02017b0:	bd468693          	addi	a3,a3,-1068 # ffffffffc0207380 <commands+0xa20>
ffffffffc02017b4:	00005617          	auipc	a2,0x5
ffffffffc02017b8:	5fc60613          	addi	a2,a2,1532 # ffffffffc0206db0 <commands+0x450>
ffffffffc02017bc:	10700593          	li	a1,263
ffffffffc02017c0:	00006517          	auipc	a0,0x6
ffffffffc02017c4:	a6050513          	addi	a0,a0,-1440 # ffffffffc0207220 <commands+0x8c0>
ffffffffc02017c8:	cb3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02017cc:	00006697          	auipc	a3,0x6
ffffffffc02017d0:	c9468693          	addi	a3,a3,-876 # ffffffffc0207460 <commands+0xb00>
ffffffffc02017d4:	00005617          	auipc	a2,0x5
ffffffffc02017d8:	5dc60613          	addi	a2,a2,1500 # ffffffffc0206db0 <commands+0x450>
ffffffffc02017dc:	10600593          	li	a1,262
ffffffffc02017e0:	00006517          	auipc	a0,0x6
ffffffffc02017e4:	a4050513          	addi	a0,a0,-1472 # ffffffffc0207220 <commands+0x8c0>
ffffffffc02017e8:	c93fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02017ec:	00006697          	auipc	a3,0x6
ffffffffc02017f0:	c4468693          	addi	a3,a3,-956 # ffffffffc0207430 <commands+0xad0>
ffffffffc02017f4:	00005617          	auipc	a2,0x5
ffffffffc02017f8:	5bc60613          	addi	a2,a2,1468 # ffffffffc0206db0 <commands+0x450>
ffffffffc02017fc:	10500593          	li	a1,261
ffffffffc0201800:	00006517          	auipc	a0,0x6
ffffffffc0201804:	a2050513          	addi	a0,a0,-1504 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201808:	c73fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020180c:	00006697          	auipc	a3,0x6
ffffffffc0201810:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0207418 <commands+0xab8>
ffffffffc0201814:	00005617          	auipc	a2,0x5
ffffffffc0201818:	59c60613          	addi	a2,a2,1436 # ffffffffc0206db0 <commands+0x450>
ffffffffc020181c:	10400593          	li	a1,260
ffffffffc0201820:	00006517          	auipc	a0,0x6
ffffffffc0201824:	a0050513          	addi	a0,a0,-1536 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201828:	c53fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc020182c:	00006697          	auipc	a3,0x6
ffffffffc0201830:	b5468693          	addi	a3,a3,-1196 # ffffffffc0207380 <commands+0xa20>
ffffffffc0201834:	00005617          	auipc	a2,0x5
ffffffffc0201838:	57c60613          	addi	a2,a2,1404 # ffffffffc0206db0 <commands+0x450>
ffffffffc020183c:	0fe00593          	li	a1,254
ffffffffc0201840:	00006517          	auipc	a0,0x6
ffffffffc0201844:	9e050513          	addi	a0,a0,-1568 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201848:	c33fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(!PageProperty(p0));
ffffffffc020184c:	00006697          	auipc	a3,0x6
ffffffffc0201850:	bb468693          	addi	a3,a3,-1100 # ffffffffc0207400 <commands+0xaa0>
ffffffffc0201854:	00005617          	auipc	a2,0x5
ffffffffc0201858:	55c60613          	addi	a2,a2,1372 # ffffffffc0206db0 <commands+0x450>
ffffffffc020185c:	0f900593          	li	a1,249
ffffffffc0201860:	00006517          	auipc	a0,0x6
ffffffffc0201864:	9c050513          	addi	a0,a0,-1600 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201868:	c13fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020186c:	00006697          	auipc	a3,0x6
ffffffffc0201870:	cb468693          	addi	a3,a3,-844 # ffffffffc0207520 <commands+0xbc0>
ffffffffc0201874:	00005617          	auipc	a2,0x5
ffffffffc0201878:	53c60613          	addi	a2,a2,1340 # ffffffffc0206db0 <commands+0x450>
ffffffffc020187c:	11700593          	li	a1,279
ffffffffc0201880:	00006517          	auipc	a0,0x6
ffffffffc0201884:	9a050513          	addi	a0,a0,-1632 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201888:	bf3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(total == 0);
ffffffffc020188c:	00006697          	auipc	a3,0x6
ffffffffc0201890:	cc468693          	addi	a3,a3,-828 # ffffffffc0207550 <commands+0xbf0>
ffffffffc0201894:	00005617          	auipc	a2,0x5
ffffffffc0201898:	51c60613          	addi	a2,a2,1308 # ffffffffc0206db0 <commands+0x450>
ffffffffc020189c:	12600593          	li	a1,294
ffffffffc02018a0:	00006517          	auipc	a0,0x6
ffffffffc02018a4:	98050513          	addi	a0,a0,-1664 # ffffffffc0207220 <commands+0x8c0>
ffffffffc02018a8:	bd3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(total == nr_free_pages());
ffffffffc02018ac:	00006697          	auipc	a3,0x6
ffffffffc02018b0:	98c68693          	addi	a3,a3,-1652 # ffffffffc0207238 <commands+0x8d8>
ffffffffc02018b4:	00005617          	auipc	a2,0x5
ffffffffc02018b8:	4fc60613          	addi	a2,a2,1276 # ffffffffc0206db0 <commands+0x450>
ffffffffc02018bc:	0f300593          	li	a1,243
ffffffffc02018c0:	00006517          	auipc	a0,0x6
ffffffffc02018c4:	96050513          	addi	a0,a0,-1696 # ffffffffc0207220 <commands+0x8c0>
ffffffffc02018c8:	bb3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02018cc:	00006697          	auipc	a3,0x6
ffffffffc02018d0:	9ac68693          	addi	a3,a3,-1620 # ffffffffc0207278 <commands+0x918>
ffffffffc02018d4:	00005617          	auipc	a2,0x5
ffffffffc02018d8:	4dc60613          	addi	a2,a2,1244 # ffffffffc0206db0 <commands+0x450>
ffffffffc02018dc:	0ba00593          	li	a1,186
ffffffffc02018e0:	00006517          	auipc	a0,0x6
ffffffffc02018e4:	94050513          	addi	a0,a0,-1728 # ffffffffc0207220 <commands+0x8c0>
ffffffffc02018e8:	b93fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02018ec <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02018ec:	1141                	addi	sp,sp,-16
ffffffffc02018ee:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02018f0:	14058463          	beqz	a1,ffffffffc0201a38 <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc02018f4:	00659693          	slli	a3,a1,0x6
ffffffffc02018f8:	96aa                	add	a3,a3,a0
ffffffffc02018fa:	87aa                	mv	a5,a0
ffffffffc02018fc:	02d50263          	beq	a0,a3,ffffffffc0201920 <default_free_pages+0x34>
ffffffffc0201900:	6798                	ld	a4,8(a5)
ffffffffc0201902:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201904:	10071a63          	bnez	a4,ffffffffc0201a18 <default_free_pages+0x12c>
ffffffffc0201908:	6798                	ld	a4,8(a5)
ffffffffc020190a:	8b09                	andi	a4,a4,2
ffffffffc020190c:	10071663          	bnez	a4,ffffffffc0201a18 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0201910:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201914:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201918:	04078793          	addi	a5,a5,64
ffffffffc020191c:	fed792e3          	bne	a5,a3,ffffffffc0201900 <default_free_pages+0x14>
    base->property = n;
ffffffffc0201920:	2581                	sext.w	a1,a1
ffffffffc0201922:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201924:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201928:	4789                	li	a5,2
ffffffffc020192a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020192e:	000ad697          	auipc	a3,0xad
ffffffffc0201932:	e1a68693          	addi	a3,a3,-486 # ffffffffc02ae748 <free_area>
ffffffffc0201936:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201938:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020193a:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020193e:	9db9                	addw	a1,a1,a4
ffffffffc0201940:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201942:	0ad78463          	beq	a5,a3,ffffffffc02019ea <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc0201946:	fe878713          	addi	a4,a5,-24
ffffffffc020194a:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020194e:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201950:	00e56a63          	bltu	a0,a4,ffffffffc0201964 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0201954:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201956:	04d70c63          	beq	a4,a3,ffffffffc02019ae <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc020195a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020195c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201960:	fee57ae3          	bgeu	a0,a4,ffffffffc0201954 <default_free_pages+0x68>
ffffffffc0201964:	c199                	beqz	a1,ffffffffc020196a <default_free_pages+0x7e>
ffffffffc0201966:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020196a:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020196c:	e390                	sd	a2,0(a5)
ffffffffc020196e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201970:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201972:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201974:	00d70d63          	beq	a4,a3,ffffffffc020198e <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc0201978:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc020197c:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0201980:	02059813          	slli	a6,a1,0x20
ffffffffc0201984:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201988:	97b2                	add	a5,a5,a2
ffffffffc020198a:	02f50c63          	beq	a0,a5,ffffffffc02019c2 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc020198e:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201990:	00d78c63          	beq	a5,a3,ffffffffc02019a8 <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0201994:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0201996:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc020199a:	02061593          	slli	a1,a2,0x20
ffffffffc020199e:	01a5d713          	srli	a4,a1,0x1a
ffffffffc02019a2:	972a                	add	a4,a4,a0
ffffffffc02019a4:	04e68a63          	beq	a3,a4,ffffffffc02019f8 <default_free_pages+0x10c>
}
ffffffffc02019a8:	60a2                	ld	ra,8(sp)
ffffffffc02019aa:	0141                	addi	sp,sp,16
ffffffffc02019ac:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02019ae:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02019b0:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02019b2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02019b4:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02019b6:	02d70763          	beq	a4,a3,ffffffffc02019e4 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc02019ba:	8832                	mv	a6,a2
ffffffffc02019bc:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02019be:	87ba                	mv	a5,a4
ffffffffc02019c0:	bf71                	j	ffffffffc020195c <default_free_pages+0x70>
            p->property += base->property;
ffffffffc02019c2:	491c                	lw	a5,16(a0)
ffffffffc02019c4:	9dbd                	addw	a1,a1,a5
ffffffffc02019c6:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02019ca:	57f5                	li	a5,-3
ffffffffc02019cc:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02019d0:	01853803          	ld	a6,24(a0)
ffffffffc02019d4:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc02019d6:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02019d8:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc02019dc:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc02019de:	0105b023          	sd	a6,0(a1) # fffffffffffff000 <end+0x3fd4c75c>
ffffffffc02019e2:	b77d                	j	ffffffffc0201990 <default_free_pages+0xa4>
ffffffffc02019e4:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02019e6:	873e                	mv	a4,a5
ffffffffc02019e8:	bf41                	j	ffffffffc0201978 <default_free_pages+0x8c>
}
ffffffffc02019ea:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02019ec:	e390                	sd	a2,0(a5)
ffffffffc02019ee:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02019f0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02019f2:	ed1c                	sd	a5,24(a0)
ffffffffc02019f4:	0141                	addi	sp,sp,16
ffffffffc02019f6:	8082                	ret
            base->property += p->property;
ffffffffc02019f8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02019fc:	ff078693          	addi	a3,a5,-16
ffffffffc0201a00:	9e39                	addw	a2,a2,a4
ffffffffc0201a02:	c910                	sw	a2,16(a0)
ffffffffc0201a04:	5775                	li	a4,-3
ffffffffc0201a06:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201a0a:	6398                	ld	a4,0(a5)
ffffffffc0201a0c:	679c                	ld	a5,8(a5)
}
ffffffffc0201a0e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201a10:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201a12:	e398                	sd	a4,0(a5)
ffffffffc0201a14:	0141                	addi	sp,sp,16
ffffffffc0201a16:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201a18:	00006697          	auipc	a3,0x6
ffffffffc0201a1c:	b5068693          	addi	a3,a3,-1200 # ffffffffc0207568 <commands+0xc08>
ffffffffc0201a20:	00005617          	auipc	a2,0x5
ffffffffc0201a24:	39060613          	addi	a2,a2,912 # ffffffffc0206db0 <commands+0x450>
ffffffffc0201a28:	08300593          	li	a1,131
ffffffffc0201a2c:	00005517          	auipc	a0,0x5
ffffffffc0201a30:	7f450513          	addi	a0,a0,2036 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201a34:	a47fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(n > 0);
ffffffffc0201a38:	00006697          	auipc	a3,0x6
ffffffffc0201a3c:	b2868693          	addi	a3,a3,-1240 # ffffffffc0207560 <commands+0xc00>
ffffffffc0201a40:	00005617          	auipc	a2,0x5
ffffffffc0201a44:	37060613          	addi	a2,a2,880 # ffffffffc0206db0 <commands+0x450>
ffffffffc0201a48:	08000593          	li	a1,128
ffffffffc0201a4c:	00005517          	auipc	a0,0x5
ffffffffc0201a50:	7d450513          	addi	a0,a0,2004 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201a54:	a27fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201a58 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201a58:	c941                	beqz	a0,ffffffffc0201ae8 <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc0201a5a:	000ad597          	auipc	a1,0xad
ffffffffc0201a5e:	cee58593          	addi	a1,a1,-786 # ffffffffc02ae748 <free_area>
ffffffffc0201a62:	0105a803          	lw	a6,16(a1)
ffffffffc0201a66:	872a                	mv	a4,a0
ffffffffc0201a68:	02081793          	slli	a5,a6,0x20
ffffffffc0201a6c:	9381                	srli	a5,a5,0x20
ffffffffc0201a6e:	00a7ee63          	bltu	a5,a0,ffffffffc0201a8a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201a72:	87ae                	mv	a5,a1
ffffffffc0201a74:	a801                	j	ffffffffc0201a84 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201a76:	ff87a683          	lw	a3,-8(a5)
ffffffffc0201a7a:	02069613          	slli	a2,a3,0x20
ffffffffc0201a7e:	9201                	srli	a2,a2,0x20
ffffffffc0201a80:	00e67763          	bgeu	a2,a4,ffffffffc0201a8e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201a84:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201a86:	feb798e3          	bne	a5,a1,ffffffffc0201a76 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201a8a:	4501                	li	a0,0
}
ffffffffc0201a8c:	8082                	ret
    return listelm->prev;
ffffffffc0201a8e:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201a92:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201a96:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0201a9a:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0201a9e:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201aa2:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201aa6:	02c77863          	bgeu	a4,a2,ffffffffc0201ad6 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0201aaa:	071a                	slli	a4,a4,0x6
ffffffffc0201aac:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201aae:	41c686bb          	subw	a3,a3,t3
ffffffffc0201ab2:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201ab4:	00870613          	addi	a2,a4,8
ffffffffc0201ab8:	4689                	li	a3,2
ffffffffc0201aba:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201abe:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201ac2:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0201ac6:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201aca:	e290                	sd	a2,0(a3)
ffffffffc0201acc:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201ad0:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0201ad2:	01173c23          	sd	a7,24(a4)
ffffffffc0201ad6:	41c8083b          	subw	a6,a6,t3
ffffffffc0201ada:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201ade:	5775                	li	a4,-3
ffffffffc0201ae0:	17c1                	addi	a5,a5,-16
ffffffffc0201ae2:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201ae6:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201ae8:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201aea:	00006697          	auipc	a3,0x6
ffffffffc0201aee:	a7668693          	addi	a3,a3,-1418 # ffffffffc0207560 <commands+0xc00>
ffffffffc0201af2:	00005617          	auipc	a2,0x5
ffffffffc0201af6:	2be60613          	addi	a2,a2,702 # ffffffffc0206db0 <commands+0x450>
ffffffffc0201afa:	06200593          	li	a1,98
ffffffffc0201afe:	00005517          	auipc	a0,0x5
ffffffffc0201b02:	72250513          	addi	a0,a0,1826 # ffffffffc0207220 <commands+0x8c0>
default_alloc_pages(size_t n) {
ffffffffc0201b06:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201b08:	973fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201b0c <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201b0c:	1141                	addi	sp,sp,-16
ffffffffc0201b0e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201b10:	c5f1                	beqz	a1,ffffffffc0201bdc <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0201b12:	00659693          	slli	a3,a1,0x6
ffffffffc0201b16:	96aa                	add	a3,a3,a0
ffffffffc0201b18:	87aa                	mv	a5,a0
ffffffffc0201b1a:	00d50f63          	beq	a0,a3,ffffffffc0201b38 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201b1e:	6798                	ld	a4,8(a5)
ffffffffc0201b20:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc0201b22:	cf49                	beqz	a4,ffffffffc0201bbc <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0201b24:	0007a823          	sw	zero,16(a5)
ffffffffc0201b28:	0007b423          	sd	zero,8(a5)
ffffffffc0201b2c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201b30:	04078793          	addi	a5,a5,64
ffffffffc0201b34:	fed795e3          	bne	a5,a3,ffffffffc0201b1e <default_init_memmap+0x12>
    base->property = n;
ffffffffc0201b38:	2581                	sext.w	a1,a1
ffffffffc0201b3a:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201b3c:	4789                	li	a5,2
ffffffffc0201b3e:	00850713          	addi	a4,a0,8
ffffffffc0201b42:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201b46:	000ad697          	auipc	a3,0xad
ffffffffc0201b4a:	c0268693          	addi	a3,a3,-1022 # ffffffffc02ae748 <free_area>
ffffffffc0201b4e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201b50:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201b52:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201b56:	9db9                	addw	a1,a1,a4
ffffffffc0201b58:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201b5a:	04d78a63          	beq	a5,a3,ffffffffc0201bae <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0201b5e:	fe878713          	addi	a4,a5,-24
ffffffffc0201b62:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201b66:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201b68:	00e56a63          	bltu	a0,a4,ffffffffc0201b7c <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201b6c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201b6e:	02d70263          	beq	a4,a3,ffffffffc0201b92 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0201b72:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201b74:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201b78:	fee57ae3          	bgeu	a0,a4,ffffffffc0201b6c <default_init_memmap+0x60>
ffffffffc0201b7c:	c199                	beqz	a1,ffffffffc0201b82 <default_init_memmap+0x76>
ffffffffc0201b7e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201b82:	6398                	ld	a4,0(a5)
}
ffffffffc0201b84:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201b86:	e390                	sd	a2,0(a5)
ffffffffc0201b88:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201b8a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201b8c:	ed18                	sd	a4,24(a0)
ffffffffc0201b8e:	0141                	addi	sp,sp,16
ffffffffc0201b90:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201b92:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201b94:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201b96:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201b98:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201b9a:	00d70663          	beq	a4,a3,ffffffffc0201ba6 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0201b9e:	8832                	mv	a6,a2
ffffffffc0201ba0:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201ba2:	87ba                	mv	a5,a4
ffffffffc0201ba4:	bfc1                	j	ffffffffc0201b74 <default_init_memmap+0x68>
}
ffffffffc0201ba6:	60a2                	ld	ra,8(sp)
ffffffffc0201ba8:	e290                	sd	a2,0(a3)
ffffffffc0201baa:	0141                	addi	sp,sp,16
ffffffffc0201bac:	8082                	ret
ffffffffc0201bae:	60a2                	ld	ra,8(sp)
ffffffffc0201bb0:	e390                	sd	a2,0(a5)
ffffffffc0201bb2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201bb4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201bb6:	ed1c                	sd	a5,24(a0)
ffffffffc0201bb8:	0141                	addi	sp,sp,16
ffffffffc0201bba:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201bbc:	00006697          	auipc	a3,0x6
ffffffffc0201bc0:	9d468693          	addi	a3,a3,-1580 # ffffffffc0207590 <commands+0xc30>
ffffffffc0201bc4:	00005617          	auipc	a2,0x5
ffffffffc0201bc8:	1ec60613          	addi	a2,a2,492 # ffffffffc0206db0 <commands+0x450>
ffffffffc0201bcc:	04900593          	li	a1,73
ffffffffc0201bd0:	00005517          	auipc	a0,0x5
ffffffffc0201bd4:	65050513          	addi	a0,a0,1616 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201bd8:	8a3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(n > 0);
ffffffffc0201bdc:	00006697          	auipc	a3,0x6
ffffffffc0201be0:	98468693          	addi	a3,a3,-1660 # ffffffffc0207560 <commands+0xc00>
ffffffffc0201be4:	00005617          	auipc	a2,0x5
ffffffffc0201be8:	1cc60613          	addi	a2,a2,460 # ffffffffc0206db0 <commands+0x450>
ffffffffc0201bec:	04600593          	li	a1,70
ffffffffc0201bf0:	00005517          	auipc	a0,0x5
ffffffffc0201bf4:	63050513          	addi	a0,a0,1584 # ffffffffc0207220 <commands+0x8c0>
ffffffffc0201bf8:	883fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201bfc <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201bfc:	c94d                	beqz	a0,ffffffffc0201cae <slob_free+0xb2>
{
ffffffffc0201bfe:	1141                	addi	sp,sp,-16
ffffffffc0201c00:	e022                	sd	s0,0(sp)
ffffffffc0201c02:	e406                	sd	ra,8(sp)
ffffffffc0201c04:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201c06:	e9c1                	bnez	a1,ffffffffc0201c96 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c08:	100027f3          	csrr	a5,sstatus
ffffffffc0201c0c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201c0e:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c10:	ebd9                	bnez	a5,ffffffffc0201ca6 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201c12:	000a5617          	auipc	a2,0xa5
ffffffffc0201c16:	72660613          	addi	a2,a2,1830 # ffffffffc02a7338 <slobfree>
ffffffffc0201c1a:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201c1c:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201c1e:	679c                	ld	a5,8(a5)
ffffffffc0201c20:	02877a63          	bgeu	a4,s0,ffffffffc0201c54 <slob_free+0x58>
ffffffffc0201c24:	00f46463          	bltu	s0,a5,ffffffffc0201c2c <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201c28:	fef76ae3          	bltu	a4,a5,ffffffffc0201c1c <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201c2c:	400c                	lw	a1,0(s0)
ffffffffc0201c2e:	00459693          	slli	a3,a1,0x4
ffffffffc0201c32:	96a2                	add	a3,a3,s0
ffffffffc0201c34:	02d78a63          	beq	a5,a3,ffffffffc0201c68 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201c38:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201c3a:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201c3c:	00469793          	slli	a5,a3,0x4
ffffffffc0201c40:	97ba                	add	a5,a5,a4
ffffffffc0201c42:	02f40e63          	beq	s0,a5,ffffffffc0201c7e <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201c46:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201c48:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc0201c4a:	e129                	bnez	a0,ffffffffc0201c8c <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201c4c:	60a2                	ld	ra,8(sp)
ffffffffc0201c4e:	6402                	ld	s0,0(sp)
ffffffffc0201c50:	0141                	addi	sp,sp,16
ffffffffc0201c52:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201c54:	fcf764e3          	bltu	a4,a5,ffffffffc0201c1c <slob_free+0x20>
ffffffffc0201c58:	fcf472e3          	bgeu	s0,a5,ffffffffc0201c1c <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc0201c5c:	400c                	lw	a1,0(s0)
ffffffffc0201c5e:	00459693          	slli	a3,a1,0x4
ffffffffc0201c62:	96a2                	add	a3,a3,s0
ffffffffc0201c64:	fcd79ae3          	bne	a5,a3,ffffffffc0201c38 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201c68:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201c6a:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201c6c:	9db5                	addw	a1,a1,a3
ffffffffc0201c6e:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc0201c70:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201c72:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201c74:	00469793          	slli	a5,a3,0x4
ffffffffc0201c78:	97ba                	add	a5,a5,a4
ffffffffc0201c7a:	fcf416e3          	bne	s0,a5,ffffffffc0201c46 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201c7e:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201c80:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201c82:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201c84:	9ebd                	addw	a3,a3,a5
ffffffffc0201c86:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201c88:	e70c                	sd	a1,8(a4)
ffffffffc0201c8a:	d169                	beqz	a0,ffffffffc0201c4c <slob_free+0x50>
}
ffffffffc0201c8c:	6402                	ld	s0,0(sp)
ffffffffc0201c8e:	60a2                	ld	ra,8(sp)
ffffffffc0201c90:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201c92:	9affe06f          	j	ffffffffc0200640 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201c96:	25bd                	addiw	a1,a1,15
ffffffffc0201c98:	8191                	srli	a1,a1,0x4
ffffffffc0201c9a:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c9c:	100027f3          	csrr	a5,sstatus
ffffffffc0201ca0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201ca2:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ca4:	d7bd                	beqz	a5,ffffffffc0201c12 <slob_free+0x16>
        intr_disable();
ffffffffc0201ca6:	9a1fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0201caa:	4505                	li	a0,1
ffffffffc0201cac:	b79d                	j	ffffffffc0201c12 <slob_free+0x16>
ffffffffc0201cae:	8082                	ret

ffffffffc0201cb0 <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201cb0:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201cb2:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201cb4:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201cb8:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201cba:	352000ef          	jal	ra,ffffffffc020200c <alloc_pages>
  if(!page)
ffffffffc0201cbe:	c91d                	beqz	a0,ffffffffc0201cf4 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201cc0:	000b1697          	auipc	a3,0xb1
ffffffffc0201cc4:	b886b683          	ld	a3,-1144(a3) # ffffffffc02b2848 <pages>
ffffffffc0201cc8:	8d15                	sub	a0,a0,a3
ffffffffc0201cca:	8519                	srai	a0,a0,0x6
ffffffffc0201ccc:	00007697          	auipc	a3,0x7
ffffffffc0201cd0:	17c6b683          	ld	a3,380(a3) # ffffffffc0208e48 <nbase>
ffffffffc0201cd4:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201cd6:	00c51793          	slli	a5,a0,0xc
ffffffffc0201cda:	83b1                	srli	a5,a5,0xc
ffffffffc0201cdc:	000b1717          	auipc	a4,0xb1
ffffffffc0201ce0:	b6473703          	ld	a4,-1180(a4) # ffffffffc02b2840 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ce4:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201ce6:	00e7fa63          	bgeu	a5,a4,ffffffffc0201cfa <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201cea:	000b1697          	auipc	a3,0xb1
ffffffffc0201cee:	b6e6b683          	ld	a3,-1170(a3) # ffffffffc02b2858 <va_pa_offset>
ffffffffc0201cf2:	9536                	add	a0,a0,a3
}
ffffffffc0201cf4:	60a2                	ld	ra,8(sp)
ffffffffc0201cf6:	0141                	addi	sp,sp,16
ffffffffc0201cf8:	8082                	ret
ffffffffc0201cfa:	86aa                	mv	a3,a0
ffffffffc0201cfc:	00005617          	auipc	a2,0x5
ffffffffc0201d00:	4ec60613          	addi	a2,a2,1260 # ffffffffc02071e8 <commands+0x888>
ffffffffc0201d04:	06900593          	li	a1,105
ffffffffc0201d08:	00005517          	auipc	a0,0x5
ffffffffc0201d0c:	44850513          	addi	a0,a0,1096 # ffffffffc0207150 <commands+0x7f0>
ffffffffc0201d10:	f6afe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201d14 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201d14:	1101                	addi	sp,sp,-32
ffffffffc0201d16:	ec06                	sd	ra,24(sp)
ffffffffc0201d18:	e822                	sd	s0,16(sp)
ffffffffc0201d1a:	e426                	sd	s1,8(sp)
ffffffffc0201d1c:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201d1e:	01050713          	addi	a4,a0,16
ffffffffc0201d22:	6785                	lui	a5,0x1
ffffffffc0201d24:	0cf77363          	bgeu	a4,a5,ffffffffc0201dea <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201d28:	00f50493          	addi	s1,a0,15
ffffffffc0201d2c:	8091                	srli	s1,s1,0x4
ffffffffc0201d2e:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d30:	10002673          	csrr	a2,sstatus
ffffffffc0201d34:	8a09                	andi	a2,a2,2
ffffffffc0201d36:	e25d                	bnez	a2,ffffffffc0201ddc <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201d38:	000a5917          	auipc	s2,0xa5
ffffffffc0201d3c:	60090913          	addi	s2,s2,1536 # ffffffffc02a7338 <slobfree>
ffffffffc0201d40:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201d44:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201d46:	4398                	lw	a4,0(a5)
ffffffffc0201d48:	08975e63          	bge	a4,s1,ffffffffc0201de4 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0201d4c:	00f68b63          	beq	a3,a5,ffffffffc0201d62 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201d50:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201d52:	4018                	lw	a4,0(s0)
ffffffffc0201d54:	02975a63          	bge	a4,s1,ffffffffc0201d88 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0201d58:	00093683          	ld	a3,0(s2)
ffffffffc0201d5c:	87a2                	mv	a5,s0
ffffffffc0201d5e:	fef699e3          	bne	a3,a5,ffffffffc0201d50 <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0201d62:	ee31                	bnez	a2,ffffffffc0201dbe <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201d64:	4501                	li	a0,0
ffffffffc0201d66:	f4bff0ef          	jal	ra,ffffffffc0201cb0 <__slob_get_free_pages.constprop.0>
ffffffffc0201d6a:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201d6c:	cd05                	beqz	a0,ffffffffc0201da4 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201d6e:	6585                	lui	a1,0x1
ffffffffc0201d70:	e8dff0ef          	jal	ra,ffffffffc0201bfc <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d74:	10002673          	csrr	a2,sstatus
ffffffffc0201d78:	8a09                	andi	a2,a2,2
ffffffffc0201d7a:	ee05                	bnez	a2,ffffffffc0201db2 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201d7c:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201d80:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201d82:	4018                	lw	a4,0(s0)
ffffffffc0201d84:	fc974ae3          	blt	a4,s1,ffffffffc0201d58 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201d88:	04e48763          	beq	s1,a4,ffffffffc0201dd6 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201d8c:	00449693          	slli	a3,s1,0x4
ffffffffc0201d90:	96a2                	add	a3,a3,s0
ffffffffc0201d92:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201d94:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201d96:	9f05                	subw	a4,a4,s1
ffffffffc0201d98:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201d9a:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201d9c:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201d9e:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0201da2:	e20d                	bnez	a2,ffffffffc0201dc4 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201da4:	60e2                	ld	ra,24(sp)
ffffffffc0201da6:	8522                	mv	a0,s0
ffffffffc0201da8:	6442                	ld	s0,16(sp)
ffffffffc0201daa:	64a2                	ld	s1,8(sp)
ffffffffc0201dac:	6902                	ld	s2,0(sp)
ffffffffc0201dae:	6105                	addi	sp,sp,32
ffffffffc0201db0:	8082                	ret
        intr_disable();
ffffffffc0201db2:	895fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
			cur = slobfree;
ffffffffc0201db6:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201dba:	4605                	li	a2,1
ffffffffc0201dbc:	b7d1                	j	ffffffffc0201d80 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201dbe:	883fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0201dc2:	b74d                	j	ffffffffc0201d64 <slob_alloc.constprop.0+0x50>
ffffffffc0201dc4:	87dfe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
}
ffffffffc0201dc8:	60e2                	ld	ra,24(sp)
ffffffffc0201dca:	8522                	mv	a0,s0
ffffffffc0201dcc:	6442                	ld	s0,16(sp)
ffffffffc0201dce:	64a2                	ld	s1,8(sp)
ffffffffc0201dd0:	6902                	ld	s2,0(sp)
ffffffffc0201dd2:	6105                	addi	sp,sp,32
ffffffffc0201dd4:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201dd6:	6418                	ld	a4,8(s0)
ffffffffc0201dd8:	e798                	sd	a4,8(a5)
ffffffffc0201dda:	b7d1                	j	ffffffffc0201d9e <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201ddc:	86bfe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0201de0:	4605                	li	a2,1
ffffffffc0201de2:	bf99                	j	ffffffffc0201d38 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201de4:	843e                	mv	s0,a5
ffffffffc0201de6:	87b6                	mv	a5,a3
ffffffffc0201de8:	b745                	j	ffffffffc0201d88 <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201dea:	00006697          	auipc	a3,0x6
ffffffffc0201dee:	80668693          	addi	a3,a3,-2042 # ffffffffc02075f0 <default_pmm_manager+0x38>
ffffffffc0201df2:	00005617          	auipc	a2,0x5
ffffffffc0201df6:	fbe60613          	addi	a2,a2,-66 # ffffffffc0206db0 <commands+0x450>
ffffffffc0201dfa:	06400593          	li	a1,100
ffffffffc0201dfe:	00006517          	auipc	a0,0x6
ffffffffc0201e02:	81250513          	addi	a0,a0,-2030 # ffffffffc0207610 <default_pmm_manager+0x58>
ffffffffc0201e06:	e74fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201e0a <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201e0a:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201e0c:	00006517          	auipc	a0,0x6
ffffffffc0201e10:	81c50513          	addi	a0,a0,-2020 # ffffffffc0207628 <default_pmm_manager+0x70>
kmalloc_init(void) {
ffffffffc0201e14:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201e16:	b6afe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201e1a:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201e1c:	00006517          	auipc	a0,0x6
ffffffffc0201e20:	82450513          	addi	a0,a0,-2012 # ffffffffc0207640 <default_pmm_manager+0x88>
}
ffffffffc0201e24:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201e26:	b5afe06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0201e2a <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201e2a:	4501                	li	a0,0
ffffffffc0201e2c:	8082                	ret

ffffffffc0201e2e <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201e2e:	1101                	addi	sp,sp,-32
ffffffffc0201e30:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201e32:	6905                	lui	s2,0x1
{
ffffffffc0201e34:	e822                	sd	s0,16(sp)
ffffffffc0201e36:	ec06                	sd	ra,24(sp)
ffffffffc0201e38:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201e3a:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bc1>
{
ffffffffc0201e3e:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201e40:	04a7f963          	bgeu	a5,a0,ffffffffc0201e92 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201e44:	4561                	li	a0,24
ffffffffc0201e46:	ecfff0ef          	jal	ra,ffffffffc0201d14 <slob_alloc.constprop.0>
ffffffffc0201e4a:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201e4c:	c929                	beqz	a0,ffffffffc0201e9e <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201e4e:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201e52:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201e54:	00f95763          	bge	s2,a5,ffffffffc0201e62 <kmalloc+0x34>
ffffffffc0201e58:	6705                	lui	a4,0x1
ffffffffc0201e5a:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201e5c:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201e5e:	fef74ee3          	blt	a4,a5,ffffffffc0201e5a <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201e62:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201e64:	e4dff0ef          	jal	ra,ffffffffc0201cb0 <__slob_get_free_pages.constprop.0>
ffffffffc0201e68:	e488                	sd	a0,8(s1)
ffffffffc0201e6a:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201e6c:	c525                	beqz	a0,ffffffffc0201ed4 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e6e:	100027f3          	csrr	a5,sstatus
ffffffffc0201e72:	8b89                	andi	a5,a5,2
ffffffffc0201e74:	ef8d                	bnez	a5,ffffffffc0201eae <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201e76:	000b1797          	auipc	a5,0xb1
ffffffffc0201e7a:	9b278793          	addi	a5,a5,-1614 # ffffffffc02b2828 <bigblocks>
ffffffffc0201e7e:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201e80:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201e82:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201e84:	60e2                	ld	ra,24(sp)
ffffffffc0201e86:	8522                	mv	a0,s0
ffffffffc0201e88:	6442                	ld	s0,16(sp)
ffffffffc0201e8a:	64a2                	ld	s1,8(sp)
ffffffffc0201e8c:	6902                	ld	s2,0(sp)
ffffffffc0201e8e:	6105                	addi	sp,sp,32
ffffffffc0201e90:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201e92:	0541                	addi	a0,a0,16
ffffffffc0201e94:	e81ff0ef          	jal	ra,ffffffffc0201d14 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201e98:	01050413          	addi	s0,a0,16
ffffffffc0201e9c:	f565                	bnez	a0,ffffffffc0201e84 <kmalloc+0x56>
ffffffffc0201e9e:	4401                	li	s0,0
}
ffffffffc0201ea0:	60e2                	ld	ra,24(sp)
ffffffffc0201ea2:	8522                	mv	a0,s0
ffffffffc0201ea4:	6442                	ld	s0,16(sp)
ffffffffc0201ea6:	64a2                	ld	s1,8(sp)
ffffffffc0201ea8:	6902                	ld	s2,0(sp)
ffffffffc0201eaa:	6105                	addi	sp,sp,32
ffffffffc0201eac:	8082                	ret
        intr_disable();
ffffffffc0201eae:	f98fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201eb2:	000b1797          	auipc	a5,0xb1
ffffffffc0201eb6:	97678793          	addi	a5,a5,-1674 # ffffffffc02b2828 <bigblocks>
ffffffffc0201eba:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201ebc:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201ebe:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201ec0:	f80fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
		return bb->pages;
ffffffffc0201ec4:	6480                	ld	s0,8(s1)
}
ffffffffc0201ec6:	60e2                	ld	ra,24(sp)
ffffffffc0201ec8:	64a2                	ld	s1,8(sp)
ffffffffc0201eca:	8522                	mv	a0,s0
ffffffffc0201ecc:	6442                	ld	s0,16(sp)
ffffffffc0201ece:	6902                	ld	s2,0(sp)
ffffffffc0201ed0:	6105                	addi	sp,sp,32
ffffffffc0201ed2:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ed4:	45e1                	li	a1,24
ffffffffc0201ed6:	8526                	mv	a0,s1
ffffffffc0201ed8:	d25ff0ef          	jal	ra,ffffffffc0201bfc <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201edc:	b765                	j	ffffffffc0201e84 <kmalloc+0x56>

ffffffffc0201ede <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201ede:	c169                	beqz	a0,ffffffffc0201fa0 <kfree+0xc2>
{
ffffffffc0201ee0:	1101                	addi	sp,sp,-32
ffffffffc0201ee2:	e822                	sd	s0,16(sp)
ffffffffc0201ee4:	ec06                	sd	ra,24(sp)
ffffffffc0201ee6:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201ee8:	03451793          	slli	a5,a0,0x34
ffffffffc0201eec:	842a                	mv	s0,a0
ffffffffc0201eee:	e3d9                	bnez	a5,ffffffffc0201f74 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ef0:	100027f3          	csrr	a5,sstatus
ffffffffc0201ef4:	8b89                	andi	a5,a5,2
ffffffffc0201ef6:	e7d9                	bnez	a5,ffffffffc0201f84 <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201ef8:	000b1797          	auipc	a5,0xb1
ffffffffc0201efc:	9307b783          	ld	a5,-1744(a5) # ffffffffc02b2828 <bigblocks>
    return 0;
ffffffffc0201f00:	4601                	li	a2,0
ffffffffc0201f02:	cbad                	beqz	a5,ffffffffc0201f74 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201f04:	000b1697          	auipc	a3,0xb1
ffffffffc0201f08:	92468693          	addi	a3,a3,-1756 # ffffffffc02b2828 <bigblocks>
ffffffffc0201f0c:	a021                	j	ffffffffc0201f14 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201f0e:	01048693          	addi	a3,s1,16
ffffffffc0201f12:	c3a5                	beqz	a5,ffffffffc0201f72 <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201f14:	6798                	ld	a4,8(a5)
ffffffffc0201f16:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0201f18:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0201f1a:	fe871ae3          	bne	a4,s0,ffffffffc0201f0e <kfree+0x30>
				*last = bb->next;
ffffffffc0201f1e:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201f20:	ee2d                	bnez	a2,ffffffffc0201f9a <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201f22:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201f26:	4098                	lw	a4,0(s1)
ffffffffc0201f28:	08f46963          	bltu	s0,a5,ffffffffc0201fba <kfree+0xdc>
ffffffffc0201f2c:	000b1697          	auipc	a3,0xb1
ffffffffc0201f30:	92c6b683          	ld	a3,-1748(a3) # ffffffffc02b2858 <va_pa_offset>
ffffffffc0201f34:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201f36:	8031                	srli	s0,s0,0xc
ffffffffc0201f38:	000b1797          	auipc	a5,0xb1
ffffffffc0201f3c:	9087b783          	ld	a5,-1784(a5) # ffffffffc02b2840 <npage>
ffffffffc0201f40:	06f47163          	bgeu	s0,a5,ffffffffc0201fa2 <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f44:	00007517          	auipc	a0,0x7
ffffffffc0201f48:	f0453503          	ld	a0,-252(a0) # ffffffffc0208e48 <nbase>
ffffffffc0201f4c:	8c09                	sub	s0,s0,a0
ffffffffc0201f4e:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201f50:	000b1517          	auipc	a0,0xb1
ffffffffc0201f54:	8f853503          	ld	a0,-1800(a0) # ffffffffc02b2848 <pages>
ffffffffc0201f58:	4585                	li	a1,1
ffffffffc0201f5a:	9522                	add	a0,a0,s0
ffffffffc0201f5c:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201f60:	13e000ef          	jal	ra,ffffffffc020209e <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201f64:	6442                	ld	s0,16(sp)
ffffffffc0201f66:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201f68:	8526                	mv	a0,s1
}
ffffffffc0201f6a:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201f6c:	45e1                	li	a1,24
}
ffffffffc0201f6e:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201f70:	b171                	j	ffffffffc0201bfc <slob_free>
ffffffffc0201f72:	e20d                	bnez	a2,ffffffffc0201f94 <kfree+0xb6>
ffffffffc0201f74:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201f78:	6442                	ld	s0,16(sp)
ffffffffc0201f7a:	60e2                	ld	ra,24(sp)
ffffffffc0201f7c:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201f7e:	4581                	li	a1,0
}
ffffffffc0201f80:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201f82:	b9ad                	j	ffffffffc0201bfc <slob_free>
        intr_disable();
ffffffffc0201f84:	ec2fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201f88:	000b1797          	auipc	a5,0xb1
ffffffffc0201f8c:	8a07b783          	ld	a5,-1888(a5) # ffffffffc02b2828 <bigblocks>
        return 1;
ffffffffc0201f90:	4605                	li	a2,1
ffffffffc0201f92:	fbad                	bnez	a5,ffffffffc0201f04 <kfree+0x26>
        intr_enable();
ffffffffc0201f94:	eacfe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0201f98:	bff1                	j	ffffffffc0201f74 <kfree+0x96>
ffffffffc0201f9a:	ea6fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0201f9e:	b751                	j	ffffffffc0201f22 <kfree+0x44>
ffffffffc0201fa0:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201fa2:	00005617          	auipc	a2,0x5
ffffffffc0201fa6:	1be60613          	addi	a2,a2,446 # ffffffffc0207160 <commands+0x800>
ffffffffc0201faa:	06200593          	li	a1,98
ffffffffc0201fae:	00005517          	auipc	a0,0x5
ffffffffc0201fb2:	1a250513          	addi	a0,a0,418 # ffffffffc0207150 <commands+0x7f0>
ffffffffc0201fb6:	cc4fe0ef          	jal	ra,ffffffffc020047a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201fba:	86a2                	mv	a3,s0
ffffffffc0201fbc:	00005617          	auipc	a2,0x5
ffffffffc0201fc0:	6a460613          	addi	a2,a2,1700 # ffffffffc0207660 <default_pmm_manager+0xa8>
ffffffffc0201fc4:	06e00593          	li	a1,110
ffffffffc0201fc8:	00005517          	auipc	a0,0x5
ffffffffc0201fcc:	18850513          	addi	a0,a0,392 # ffffffffc0207150 <commands+0x7f0>
ffffffffc0201fd0:	caafe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201fd4 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0201fd4:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201fd6:	00005617          	auipc	a2,0x5
ffffffffc0201fda:	18a60613          	addi	a2,a2,394 # ffffffffc0207160 <commands+0x800>
ffffffffc0201fde:	06200593          	li	a1,98
ffffffffc0201fe2:	00005517          	auipc	a0,0x5
ffffffffc0201fe6:	16e50513          	addi	a0,a0,366 # ffffffffc0207150 <commands+0x7f0>
pa2page(uintptr_t pa) {
ffffffffc0201fea:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201fec:	c8efe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201ff0 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc0201ff0:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201ff2:	00005617          	auipc	a2,0x5
ffffffffc0201ff6:	13660613          	addi	a2,a2,310 # ffffffffc0207128 <commands+0x7c8>
ffffffffc0201ffa:	07400593          	li	a1,116
ffffffffc0201ffe:	00005517          	auipc	a0,0x5
ffffffffc0202002:	15250513          	addi	a0,a0,338 # ffffffffc0207150 <commands+0x7f0>
pte2page(pte_t pte) {
ffffffffc0202006:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0202008:	c72fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020200c <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc020200c:	7139                	addi	sp,sp,-64
ffffffffc020200e:	f426                	sd	s1,40(sp)
ffffffffc0202010:	f04a                	sd	s2,32(sp)
ffffffffc0202012:	ec4e                	sd	s3,24(sp)
ffffffffc0202014:	e852                	sd	s4,16(sp)
ffffffffc0202016:	e456                	sd	s5,8(sp)
ffffffffc0202018:	e05a                	sd	s6,0(sp)
ffffffffc020201a:	fc06                	sd	ra,56(sp)
ffffffffc020201c:	f822                	sd	s0,48(sp)
ffffffffc020201e:	84aa                	mv	s1,a0
ffffffffc0202020:	000b1917          	auipc	s2,0xb1
ffffffffc0202024:	83090913          	addi	s2,s2,-2000 # ffffffffc02b2850 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202028:	4a05                	li	s4,1
ffffffffc020202a:	000b1a97          	auipc	s5,0xb1
ffffffffc020202e:	846a8a93          	addi	s5,s5,-1978 # ffffffffc02b2870 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0202032:	0005099b          	sext.w	s3,a0
ffffffffc0202036:	000b1b17          	auipc	s6,0xb1
ffffffffc020203a:	842b0b13          	addi	s6,s6,-1982 # ffffffffc02b2878 <check_mm_struct>
ffffffffc020203e:	a01d                	j	ffffffffc0202064 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0202040:	00093783          	ld	a5,0(s2)
ffffffffc0202044:	6f9c                	ld	a5,24(a5)
ffffffffc0202046:	9782                	jalr	a5
ffffffffc0202048:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc020204a:	4601                	li	a2,0
ffffffffc020204c:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020204e:	ec0d                	bnez	s0,ffffffffc0202088 <alloc_pages+0x7c>
ffffffffc0202050:	029a6c63          	bltu	s4,s1,ffffffffc0202088 <alloc_pages+0x7c>
ffffffffc0202054:	000aa783          	lw	a5,0(s5)
ffffffffc0202058:	2781                	sext.w	a5,a5
ffffffffc020205a:	c79d                	beqz	a5,ffffffffc0202088 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc020205c:	000b3503          	ld	a0,0(s6)
ffffffffc0202060:	41d010ef          	jal	ra,ffffffffc0203c7c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202064:	100027f3          	csrr	a5,sstatus
ffffffffc0202068:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc020206a:	8526                	mv	a0,s1
ffffffffc020206c:	dbf1                	beqz	a5,ffffffffc0202040 <alloc_pages+0x34>
        intr_disable();
ffffffffc020206e:	dd8fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202072:	00093783          	ld	a5,0(s2)
ffffffffc0202076:	8526                	mv	a0,s1
ffffffffc0202078:	6f9c                	ld	a5,24(a5)
ffffffffc020207a:	9782                	jalr	a5
ffffffffc020207c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020207e:	dc2fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202082:	4601                	li	a2,0
ffffffffc0202084:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202086:	d469                	beqz	s0,ffffffffc0202050 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0202088:	70e2                	ld	ra,56(sp)
ffffffffc020208a:	8522                	mv	a0,s0
ffffffffc020208c:	7442                	ld	s0,48(sp)
ffffffffc020208e:	74a2                	ld	s1,40(sp)
ffffffffc0202090:	7902                	ld	s2,32(sp)
ffffffffc0202092:	69e2                	ld	s3,24(sp)
ffffffffc0202094:	6a42                	ld	s4,16(sp)
ffffffffc0202096:	6aa2                	ld	s5,8(sp)
ffffffffc0202098:	6b02                	ld	s6,0(sp)
ffffffffc020209a:	6121                	addi	sp,sp,64
ffffffffc020209c:	8082                	ret

ffffffffc020209e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020209e:	100027f3          	csrr	a5,sstatus
ffffffffc02020a2:	8b89                	andi	a5,a5,2
ffffffffc02020a4:	e799                	bnez	a5,ffffffffc02020b2 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02020a6:	000b0797          	auipc	a5,0xb0
ffffffffc02020aa:	7aa7b783          	ld	a5,1962(a5) # ffffffffc02b2850 <pmm_manager>
ffffffffc02020ae:	739c                	ld	a5,32(a5)
ffffffffc02020b0:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02020b2:	1101                	addi	sp,sp,-32
ffffffffc02020b4:	ec06                	sd	ra,24(sp)
ffffffffc02020b6:	e822                	sd	s0,16(sp)
ffffffffc02020b8:	e426                	sd	s1,8(sp)
ffffffffc02020ba:	842a                	mv	s0,a0
ffffffffc02020bc:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02020be:	d88fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02020c2:	000b0797          	auipc	a5,0xb0
ffffffffc02020c6:	78e7b783          	ld	a5,1934(a5) # ffffffffc02b2850 <pmm_manager>
ffffffffc02020ca:	739c                	ld	a5,32(a5)
ffffffffc02020cc:	85a6                	mv	a1,s1
ffffffffc02020ce:	8522                	mv	a0,s0
ffffffffc02020d0:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02020d2:	6442                	ld	s0,16(sp)
ffffffffc02020d4:	60e2                	ld	ra,24(sp)
ffffffffc02020d6:	64a2                	ld	s1,8(sp)
ffffffffc02020d8:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02020da:	d66fe06f          	j	ffffffffc0200640 <intr_enable>

ffffffffc02020de <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02020de:	100027f3          	csrr	a5,sstatus
ffffffffc02020e2:	8b89                	andi	a5,a5,2
ffffffffc02020e4:	e799                	bnez	a5,ffffffffc02020f2 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02020e6:	000b0797          	auipc	a5,0xb0
ffffffffc02020ea:	76a7b783          	ld	a5,1898(a5) # ffffffffc02b2850 <pmm_manager>
ffffffffc02020ee:	779c                	ld	a5,40(a5)
ffffffffc02020f0:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02020f2:	1141                	addi	sp,sp,-16
ffffffffc02020f4:	e406                	sd	ra,8(sp)
ffffffffc02020f6:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02020f8:	d4efe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02020fc:	000b0797          	auipc	a5,0xb0
ffffffffc0202100:	7547b783          	ld	a5,1876(a5) # ffffffffc02b2850 <pmm_manager>
ffffffffc0202104:	779c                	ld	a5,40(a5)
ffffffffc0202106:	9782                	jalr	a5
ffffffffc0202108:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020210a:	d36fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc020210e:	60a2                	ld	ra,8(sp)
ffffffffc0202110:	8522                	mv	a0,s0
ffffffffc0202112:	6402                	ld	s0,0(sp)
ffffffffc0202114:	0141                	addi	sp,sp,16
ffffffffc0202116:	8082                	ret

ffffffffc0202118 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202118:	01e5d793          	srli	a5,a1,0x1e
ffffffffc020211c:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202120:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202122:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202124:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202126:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc020212a:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020212c:	f04a                	sd	s2,32(sp)
ffffffffc020212e:	ec4e                	sd	s3,24(sp)
ffffffffc0202130:	e852                	sd	s4,16(sp)
ffffffffc0202132:	fc06                	sd	ra,56(sp)
ffffffffc0202134:	f822                	sd	s0,48(sp)
ffffffffc0202136:	e456                	sd	s5,8(sp)
ffffffffc0202138:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc020213a:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020213e:	892e                	mv	s2,a1
ffffffffc0202140:	89b2                	mv	s3,a2
ffffffffc0202142:	000b0a17          	auipc	s4,0xb0
ffffffffc0202146:	6fea0a13          	addi	s4,s4,1790 # ffffffffc02b2840 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc020214a:	e7b5                	bnez	a5,ffffffffc02021b6 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc020214c:	12060b63          	beqz	a2,ffffffffc0202282 <get_pte+0x16a>
ffffffffc0202150:	4505                	li	a0,1
ffffffffc0202152:	ebbff0ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc0202156:	842a                	mv	s0,a0
ffffffffc0202158:	12050563          	beqz	a0,ffffffffc0202282 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc020215c:	000b0b17          	auipc	s6,0xb0
ffffffffc0202160:	6ecb0b13          	addi	s6,s6,1772 # ffffffffc02b2848 <pages>
ffffffffc0202164:	000b3503          	ld	a0,0(s6)
ffffffffc0202168:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020216c:	000b0a17          	auipc	s4,0xb0
ffffffffc0202170:	6d4a0a13          	addi	s4,s4,1748 # ffffffffc02b2840 <npage>
ffffffffc0202174:	40a40533          	sub	a0,s0,a0
ffffffffc0202178:	8519                	srai	a0,a0,0x6
ffffffffc020217a:	9556                	add	a0,a0,s5
ffffffffc020217c:	000a3703          	ld	a4,0(s4)
ffffffffc0202180:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0202184:	4685                	li	a3,1
ffffffffc0202186:	c014                	sw	a3,0(s0)
ffffffffc0202188:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020218a:	0532                	slli	a0,a0,0xc
ffffffffc020218c:	14e7f263          	bgeu	a5,a4,ffffffffc02022d0 <get_pte+0x1b8>
ffffffffc0202190:	000b0797          	auipc	a5,0xb0
ffffffffc0202194:	6c87b783          	ld	a5,1736(a5) # ffffffffc02b2858 <va_pa_offset>
ffffffffc0202198:	6605                	lui	a2,0x1
ffffffffc020219a:	4581                	li	a1,0
ffffffffc020219c:	953e                	add	a0,a0,a5
ffffffffc020219e:	52a040ef          	jal	ra,ffffffffc02066c8 <memset>
    return page - pages + nbase;
ffffffffc02021a2:	000b3683          	ld	a3,0(s6)
ffffffffc02021a6:	40d406b3          	sub	a3,s0,a3
ffffffffc02021aa:	8699                	srai	a3,a3,0x6
ffffffffc02021ac:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02021ae:	06aa                	slli	a3,a3,0xa
ffffffffc02021b0:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02021b4:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02021b6:	77fd                	lui	a5,0xfffff
ffffffffc02021b8:	068a                	slli	a3,a3,0x2
ffffffffc02021ba:	000a3703          	ld	a4,0(s4)
ffffffffc02021be:	8efd                	and	a3,a3,a5
ffffffffc02021c0:	00c6d793          	srli	a5,a3,0xc
ffffffffc02021c4:	0ce7f163          	bgeu	a5,a4,ffffffffc0202286 <get_pte+0x16e>
ffffffffc02021c8:	000b0a97          	auipc	s5,0xb0
ffffffffc02021cc:	690a8a93          	addi	s5,s5,1680 # ffffffffc02b2858 <va_pa_offset>
ffffffffc02021d0:	000ab403          	ld	s0,0(s5)
ffffffffc02021d4:	01595793          	srli	a5,s2,0x15
ffffffffc02021d8:	1ff7f793          	andi	a5,a5,511
ffffffffc02021dc:	96a2                	add	a3,a3,s0
ffffffffc02021de:	00379413          	slli	s0,a5,0x3
ffffffffc02021e2:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc02021e4:	6014                	ld	a3,0(s0)
ffffffffc02021e6:	0016f793          	andi	a5,a3,1
ffffffffc02021ea:	e3ad                	bnez	a5,ffffffffc020224c <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02021ec:	08098b63          	beqz	s3,ffffffffc0202282 <get_pte+0x16a>
ffffffffc02021f0:	4505                	li	a0,1
ffffffffc02021f2:	e1bff0ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc02021f6:	84aa                	mv	s1,a0
ffffffffc02021f8:	c549                	beqz	a0,ffffffffc0202282 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc02021fa:	000b0b17          	auipc	s6,0xb0
ffffffffc02021fe:	64eb0b13          	addi	s6,s6,1614 # ffffffffc02b2848 <pages>
ffffffffc0202202:	000b3503          	ld	a0,0(s6)
ffffffffc0202206:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020220a:	000a3703          	ld	a4,0(s4)
ffffffffc020220e:	40a48533          	sub	a0,s1,a0
ffffffffc0202212:	8519                	srai	a0,a0,0x6
ffffffffc0202214:	954e                	add	a0,a0,s3
ffffffffc0202216:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc020221a:	4685                	li	a3,1
ffffffffc020221c:	c094                	sw	a3,0(s1)
ffffffffc020221e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202220:	0532                	slli	a0,a0,0xc
ffffffffc0202222:	08e7fa63          	bgeu	a5,a4,ffffffffc02022b6 <get_pte+0x19e>
ffffffffc0202226:	000ab783          	ld	a5,0(s5)
ffffffffc020222a:	6605                	lui	a2,0x1
ffffffffc020222c:	4581                	li	a1,0
ffffffffc020222e:	953e                	add	a0,a0,a5
ffffffffc0202230:	498040ef          	jal	ra,ffffffffc02066c8 <memset>
    return page - pages + nbase;
ffffffffc0202234:	000b3683          	ld	a3,0(s6)
ffffffffc0202238:	40d486b3          	sub	a3,s1,a3
ffffffffc020223c:	8699                	srai	a3,a3,0x6
ffffffffc020223e:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202240:	06aa                	slli	a3,a3,0xa
ffffffffc0202242:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202246:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202248:	000a3703          	ld	a4,0(s4)
ffffffffc020224c:	068a                	slli	a3,a3,0x2
ffffffffc020224e:	757d                	lui	a0,0xfffff
ffffffffc0202250:	8ee9                	and	a3,a3,a0
ffffffffc0202252:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202256:	04e7f463          	bgeu	a5,a4,ffffffffc020229e <get_pte+0x186>
ffffffffc020225a:	000ab503          	ld	a0,0(s5)
ffffffffc020225e:	00c95913          	srli	s2,s2,0xc
ffffffffc0202262:	1ff97913          	andi	s2,s2,511
ffffffffc0202266:	96aa                	add	a3,a3,a0
ffffffffc0202268:	00391513          	slli	a0,s2,0x3
ffffffffc020226c:	9536                	add	a0,a0,a3
}
ffffffffc020226e:	70e2                	ld	ra,56(sp)
ffffffffc0202270:	7442                	ld	s0,48(sp)
ffffffffc0202272:	74a2                	ld	s1,40(sp)
ffffffffc0202274:	7902                	ld	s2,32(sp)
ffffffffc0202276:	69e2                	ld	s3,24(sp)
ffffffffc0202278:	6a42                	ld	s4,16(sp)
ffffffffc020227a:	6aa2                	ld	s5,8(sp)
ffffffffc020227c:	6b02                	ld	s6,0(sp)
ffffffffc020227e:	6121                	addi	sp,sp,64
ffffffffc0202280:	8082                	ret
            return NULL;
ffffffffc0202282:	4501                	li	a0,0
ffffffffc0202284:	b7ed                	j	ffffffffc020226e <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202286:	00005617          	auipc	a2,0x5
ffffffffc020228a:	f6260613          	addi	a2,a2,-158 # ffffffffc02071e8 <commands+0x888>
ffffffffc020228e:	0e300593          	li	a1,227
ffffffffc0202292:	00005517          	auipc	a0,0x5
ffffffffc0202296:	3f650513          	addi	a0,a0,1014 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc020229a:	9e0fe0ef          	jal	ra,ffffffffc020047a <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020229e:	00005617          	auipc	a2,0x5
ffffffffc02022a2:	f4a60613          	addi	a2,a2,-182 # ffffffffc02071e8 <commands+0x888>
ffffffffc02022a6:	0ee00593          	li	a1,238
ffffffffc02022aa:	00005517          	auipc	a0,0x5
ffffffffc02022ae:	3de50513          	addi	a0,a0,990 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc02022b2:	9c8fe0ef          	jal	ra,ffffffffc020047a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02022b6:	86aa                	mv	a3,a0
ffffffffc02022b8:	00005617          	auipc	a2,0x5
ffffffffc02022bc:	f3060613          	addi	a2,a2,-208 # ffffffffc02071e8 <commands+0x888>
ffffffffc02022c0:	0eb00593          	li	a1,235
ffffffffc02022c4:	00005517          	auipc	a0,0x5
ffffffffc02022c8:	3c450513          	addi	a0,a0,964 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc02022cc:	9aefe0ef          	jal	ra,ffffffffc020047a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02022d0:	86aa                	mv	a3,a0
ffffffffc02022d2:	00005617          	auipc	a2,0x5
ffffffffc02022d6:	f1660613          	addi	a2,a2,-234 # ffffffffc02071e8 <commands+0x888>
ffffffffc02022da:	0df00593          	li	a1,223
ffffffffc02022de:	00005517          	auipc	a0,0x5
ffffffffc02022e2:	3aa50513          	addi	a0,a0,938 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc02022e6:	994fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02022ea <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02022ea:	1141                	addi	sp,sp,-16
ffffffffc02022ec:	e022                	sd	s0,0(sp)
ffffffffc02022ee:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02022f0:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02022f2:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02022f4:	e25ff0ef          	jal	ra,ffffffffc0202118 <get_pte>
    if (ptep_store != NULL) {
ffffffffc02022f8:	c011                	beqz	s0,ffffffffc02022fc <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02022fa:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02022fc:	c511                	beqz	a0,ffffffffc0202308 <get_page+0x1e>
ffffffffc02022fe:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202300:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202302:	0017f713          	andi	a4,a5,1
ffffffffc0202306:	e709                	bnez	a4,ffffffffc0202310 <get_page+0x26>
}
ffffffffc0202308:	60a2                	ld	ra,8(sp)
ffffffffc020230a:	6402                	ld	s0,0(sp)
ffffffffc020230c:	0141                	addi	sp,sp,16
ffffffffc020230e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202310:	078a                	slli	a5,a5,0x2
ffffffffc0202312:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202314:	000b0717          	auipc	a4,0xb0
ffffffffc0202318:	52c73703          	ld	a4,1324(a4) # ffffffffc02b2840 <npage>
ffffffffc020231c:	00e7ff63          	bgeu	a5,a4,ffffffffc020233a <get_page+0x50>
ffffffffc0202320:	60a2                	ld	ra,8(sp)
ffffffffc0202322:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0202324:	fff80537          	lui	a0,0xfff80
ffffffffc0202328:	97aa                	add	a5,a5,a0
ffffffffc020232a:	079a                	slli	a5,a5,0x6
ffffffffc020232c:	000b0517          	auipc	a0,0xb0
ffffffffc0202330:	51c53503          	ld	a0,1308(a0) # ffffffffc02b2848 <pages>
ffffffffc0202334:	953e                	add	a0,a0,a5
ffffffffc0202336:	0141                	addi	sp,sp,16
ffffffffc0202338:	8082                	ret
ffffffffc020233a:	c9bff0ef          	jal	ra,ffffffffc0201fd4 <pa2page.part.0>

ffffffffc020233e <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020233e:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202340:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202344:	f486                	sd	ra,104(sp)
ffffffffc0202346:	f0a2                	sd	s0,96(sp)
ffffffffc0202348:	eca6                	sd	s1,88(sp)
ffffffffc020234a:	e8ca                	sd	s2,80(sp)
ffffffffc020234c:	e4ce                	sd	s3,72(sp)
ffffffffc020234e:	e0d2                	sd	s4,64(sp)
ffffffffc0202350:	fc56                	sd	s5,56(sp)
ffffffffc0202352:	f85a                	sd	s6,48(sp)
ffffffffc0202354:	f45e                	sd	s7,40(sp)
ffffffffc0202356:	f062                	sd	s8,32(sp)
ffffffffc0202358:	ec66                	sd	s9,24(sp)
ffffffffc020235a:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020235c:	17d2                	slli	a5,a5,0x34
ffffffffc020235e:	e3ed                	bnez	a5,ffffffffc0202440 <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc0202360:	002007b7          	lui	a5,0x200
ffffffffc0202364:	842e                	mv	s0,a1
ffffffffc0202366:	0ef5ed63          	bltu	a1,a5,ffffffffc0202460 <unmap_range+0x122>
ffffffffc020236a:	8932                	mv	s2,a2
ffffffffc020236c:	0ec5fa63          	bgeu	a1,a2,ffffffffc0202460 <unmap_range+0x122>
ffffffffc0202370:	4785                	li	a5,1
ffffffffc0202372:	07fe                	slli	a5,a5,0x1f
ffffffffc0202374:	0ec7e663          	bltu	a5,a2,ffffffffc0202460 <unmap_range+0x122>
ffffffffc0202378:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc020237a:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc020237c:	000b0c97          	auipc	s9,0xb0
ffffffffc0202380:	4c4c8c93          	addi	s9,s9,1220 # ffffffffc02b2840 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202384:	000b0c17          	auipc	s8,0xb0
ffffffffc0202388:	4c4c0c13          	addi	s8,s8,1220 # ffffffffc02b2848 <pages>
ffffffffc020238c:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc0202390:	000b0d17          	auipc	s10,0xb0
ffffffffc0202394:	4c0d0d13          	addi	s10,s10,1216 # ffffffffc02b2850 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202398:	00200b37          	lui	s6,0x200
ffffffffc020239c:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02023a0:	4601                	li	a2,0
ffffffffc02023a2:	85a2                	mv	a1,s0
ffffffffc02023a4:	854e                	mv	a0,s3
ffffffffc02023a6:	d73ff0ef          	jal	ra,ffffffffc0202118 <get_pte>
ffffffffc02023aa:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02023ac:	cd29                	beqz	a0,ffffffffc0202406 <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc02023ae:	611c                	ld	a5,0(a0)
ffffffffc02023b0:	e395                	bnez	a5,ffffffffc02023d4 <unmap_range+0x96>
        start += PGSIZE;
ffffffffc02023b2:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02023b4:	ff2466e3          	bltu	s0,s2,ffffffffc02023a0 <unmap_range+0x62>
}
ffffffffc02023b8:	70a6                	ld	ra,104(sp)
ffffffffc02023ba:	7406                	ld	s0,96(sp)
ffffffffc02023bc:	64e6                	ld	s1,88(sp)
ffffffffc02023be:	6946                	ld	s2,80(sp)
ffffffffc02023c0:	69a6                	ld	s3,72(sp)
ffffffffc02023c2:	6a06                	ld	s4,64(sp)
ffffffffc02023c4:	7ae2                	ld	s5,56(sp)
ffffffffc02023c6:	7b42                	ld	s6,48(sp)
ffffffffc02023c8:	7ba2                	ld	s7,40(sp)
ffffffffc02023ca:	7c02                	ld	s8,32(sp)
ffffffffc02023cc:	6ce2                	ld	s9,24(sp)
ffffffffc02023ce:	6d42                	ld	s10,16(sp)
ffffffffc02023d0:	6165                	addi	sp,sp,112
ffffffffc02023d2:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02023d4:	0017f713          	andi	a4,a5,1
ffffffffc02023d8:	df69                	beqz	a4,ffffffffc02023b2 <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc02023da:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02023de:	078a                	slli	a5,a5,0x2
ffffffffc02023e0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023e2:	08e7ff63          	bgeu	a5,a4,ffffffffc0202480 <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc02023e6:	000c3503          	ld	a0,0(s8)
ffffffffc02023ea:	97de                	add	a5,a5,s7
ffffffffc02023ec:	079a                	slli	a5,a5,0x6
ffffffffc02023ee:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02023f0:	411c                	lw	a5,0(a0)
ffffffffc02023f2:	fff7871b          	addiw	a4,a5,-1
ffffffffc02023f6:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02023f8:	cf11                	beqz	a4,ffffffffc0202414 <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02023fa:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02023fe:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0202402:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202404:	bf45                	j	ffffffffc02023b4 <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202406:	945a                	add	s0,s0,s6
ffffffffc0202408:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc020240c:	d455                	beqz	s0,ffffffffc02023b8 <unmap_range+0x7a>
ffffffffc020240e:	f92469e3          	bltu	s0,s2,ffffffffc02023a0 <unmap_range+0x62>
ffffffffc0202412:	b75d                	j	ffffffffc02023b8 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202414:	100027f3          	csrr	a5,sstatus
ffffffffc0202418:	8b89                	andi	a5,a5,2
ffffffffc020241a:	e799                	bnez	a5,ffffffffc0202428 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc020241c:	000d3783          	ld	a5,0(s10)
ffffffffc0202420:	4585                	li	a1,1
ffffffffc0202422:	739c                	ld	a5,32(a5)
ffffffffc0202424:	9782                	jalr	a5
    if (flag) {
ffffffffc0202426:	bfd1                	j	ffffffffc02023fa <unmap_range+0xbc>
ffffffffc0202428:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020242a:	a1cfe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc020242e:	000d3783          	ld	a5,0(s10)
ffffffffc0202432:	6522                	ld	a0,8(sp)
ffffffffc0202434:	4585                	li	a1,1
ffffffffc0202436:	739c                	ld	a5,32(a5)
ffffffffc0202438:	9782                	jalr	a5
        intr_enable();
ffffffffc020243a:	a06fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc020243e:	bf75                	j	ffffffffc02023fa <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202440:	00005697          	auipc	a3,0x5
ffffffffc0202444:	c9068693          	addi	a3,a3,-880 # ffffffffc02070d0 <commands+0x770>
ffffffffc0202448:	00005617          	auipc	a2,0x5
ffffffffc020244c:	96860613          	addi	a2,a2,-1688 # ffffffffc0206db0 <commands+0x450>
ffffffffc0202450:	10f00593          	li	a1,271
ffffffffc0202454:	00005517          	auipc	a0,0x5
ffffffffc0202458:	23450513          	addi	a0,a0,564 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc020245c:	81efe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202460:	00005697          	auipc	a3,0x5
ffffffffc0202464:	cb068693          	addi	a3,a3,-848 # ffffffffc0207110 <commands+0x7b0>
ffffffffc0202468:	00005617          	auipc	a2,0x5
ffffffffc020246c:	94860613          	addi	a2,a2,-1720 # ffffffffc0206db0 <commands+0x450>
ffffffffc0202470:	11000593          	li	a1,272
ffffffffc0202474:	00005517          	auipc	a0,0x5
ffffffffc0202478:	21450513          	addi	a0,a0,532 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc020247c:	ffffd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202480:	b55ff0ef          	jal	ra,ffffffffc0201fd4 <pa2page.part.0>

ffffffffc0202484 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202484:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202486:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020248a:	fc86                	sd	ra,120(sp)
ffffffffc020248c:	f8a2                	sd	s0,112(sp)
ffffffffc020248e:	f4a6                	sd	s1,104(sp)
ffffffffc0202490:	f0ca                	sd	s2,96(sp)
ffffffffc0202492:	ecce                	sd	s3,88(sp)
ffffffffc0202494:	e8d2                	sd	s4,80(sp)
ffffffffc0202496:	e4d6                	sd	s5,72(sp)
ffffffffc0202498:	e0da                	sd	s6,64(sp)
ffffffffc020249a:	fc5e                	sd	s7,56(sp)
ffffffffc020249c:	f862                	sd	s8,48(sp)
ffffffffc020249e:	f466                	sd	s9,40(sp)
ffffffffc02024a0:	f06a                	sd	s10,32(sp)
ffffffffc02024a2:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02024a4:	17d2                	slli	a5,a5,0x34
ffffffffc02024a6:	20079a63          	bnez	a5,ffffffffc02026ba <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc02024aa:	002007b7          	lui	a5,0x200
ffffffffc02024ae:	24f5e463          	bltu	a1,a5,ffffffffc02026f6 <exit_range+0x272>
ffffffffc02024b2:	8ab2                	mv	s5,a2
ffffffffc02024b4:	24c5f163          	bgeu	a1,a2,ffffffffc02026f6 <exit_range+0x272>
ffffffffc02024b8:	4785                	li	a5,1
ffffffffc02024ba:	07fe                	slli	a5,a5,0x1f
ffffffffc02024bc:	22c7ed63          	bltu	a5,a2,ffffffffc02026f6 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02024c0:	c00009b7          	lui	s3,0xc0000
ffffffffc02024c4:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02024c8:	ffe00937          	lui	s2,0xffe00
ffffffffc02024cc:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc02024d0:	5cfd                	li	s9,-1
ffffffffc02024d2:	8c2a                	mv	s8,a0
ffffffffc02024d4:	0125f933          	and	s2,a1,s2
ffffffffc02024d8:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc02024da:	000b0d17          	auipc	s10,0xb0
ffffffffc02024de:	366d0d13          	addi	s10,s10,870 # ffffffffc02b2840 <npage>
    return KADDR(page2pa(page));
ffffffffc02024e2:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02024e6:	000b0717          	auipc	a4,0xb0
ffffffffc02024ea:	36270713          	addi	a4,a4,866 # ffffffffc02b2848 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc02024ee:	000b0d97          	auipc	s11,0xb0
ffffffffc02024f2:	362d8d93          	addi	s11,s11,866 # ffffffffc02b2850 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02024f6:	c0000437          	lui	s0,0xc0000
ffffffffc02024fa:	944e                	add	s0,s0,s3
ffffffffc02024fc:	8079                	srli	s0,s0,0x1e
ffffffffc02024fe:	1ff47413          	andi	s0,s0,511
ffffffffc0202502:	040e                	slli	s0,s0,0x3
ffffffffc0202504:	9462                	add	s0,s0,s8
ffffffffc0202506:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed8>
        if (pde1 & PTE_V){
ffffffffc020250a:	001a7793          	andi	a5,s4,1
ffffffffc020250e:	eb99                	bnez	a5,ffffffffc0202524 <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc0202510:	12098463          	beqz	s3,ffffffffc0202638 <exit_range+0x1b4>
ffffffffc0202514:	400007b7          	lui	a5,0x40000
ffffffffc0202518:	97ce                	add	a5,a5,s3
ffffffffc020251a:	894e                	mv	s2,s3
ffffffffc020251c:	1159fe63          	bgeu	s3,s5,ffffffffc0202638 <exit_range+0x1b4>
ffffffffc0202520:	89be                	mv	s3,a5
ffffffffc0202522:	bfd1                	j	ffffffffc02024f6 <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc0202524:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202528:	0a0a                	slli	s4,s4,0x2
ffffffffc020252a:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc020252e:	1cfa7263          	bgeu	s4,a5,ffffffffc02026f2 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202532:	fff80637          	lui	a2,0xfff80
ffffffffc0202536:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc0202538:	000806b7          	lui	a3,0x80
ffffffffc020253c:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc020253e:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0202542:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202544:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202546:	18f5fa63          	bgeu	a1,a5,ffffffffc02026da <exit_range+0x256>
ffffffffc020254a:	000b0817          	auipc	a6,0xb0
ffffffffc020254e:	30e80813          	addi	a6,a6,782 # ffffffffc02b2858 <va_pa_offset>
ffffffffc0202552:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc0202556:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202558:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc020255c:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc020255e:	00080337          	lui	t1,0x80
ffffffffc0202562:	6885                	lui	a7,0x1
ffffffffc0202564:	a819                	j	ffffffffc020257a <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc0202566:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc0202568:	002007b7          	lui	a5,0x200
ffffffffc020256c:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc020256e:	08090c63          	beqz	s2,ffffffffc0202606 <exit_range+0x182>
ffffffffc0202572:	09397a63          	bgeu	s2,s3,ffffffffc0202606 <exit_range+0x182>
ffffffffc0202576:	0f597063          	bgeu	s2,s5,ffffffffc0202656 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc020257a:	01595493          	srli	s1,s2,0x15
ffffffffc020257e:	1ff4f493          	andi	s1,s1,511
ffffffffc0202582:	048e                	slli	s1,s1,0x3
ffffffffc0202584:	94da                	add	s1,s1,s6
ffffffffc0202586:	609c                	ld	a5,0(s1)
                if (pde0 & PTE_V) {
ffffffffc0202588:	0017f693          	andi	a3,a5,1
ffffffffc020258c:	dee9                	beqz	a3,ffffffffc0202566 <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc020258e:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202592:	078a                	slli	a5,a5,0x2
ffffffffc0202594:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202596:	14b7fe63          	bgeu	a5,a1,ffffffffc02026f2 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc020259a:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc020259c:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc02025a0:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02025a4:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02025a8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02025aa:	12bef863          	bgeu	t4,a1,ffffffffc02026da <exit_range+0x256>
ffffffffc02025ae:	00083783          	ld	a5,0(a6)
ffffffffc02025b2:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02025b4:	011685b3          	add	a1,a3,a7
                        if (pt[i] & PTE_V){
ffffffffc02025b8:	629c                	ld	a5,0(a3)
ffffffffc02025ba:	8b85                	andi	a5,a5,1
ffffffffc02025bc:	f7d5                	bnez	a5,ffffffffc0202568 <exit_range+0xe4>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02025be:	06a1                	addi	a3,a3,8
ffffffffc02025c0:	fed59ce3          	bne	a1,a3,ffffffffc02025b8 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc02025c4:	631c                	ld	a5,0(a4)
ffffffffc02025c6:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02025c8:	100027f3          	csrr	a5,sstatus
ffffffffc02025cc:	8b89                	andi	a5,a5,2
ffffffffc02025ce:	e7d9                	bnez	a5,ffffffffc020265c <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc02025d0:	000db783          	ld	a5,0(s11)
ffffffffc02025d4:	4585                	li	a1,1
ffffffffc02025d6:	e032                	sd	a2,0(sp)
ffffffffc02025d8:	739c                	ld	a5,32(a5)
ffffffffc02025da:	9782                	jalr	a5
    if (flag) {
ffffffffc02025dc:	6602                	ld	a2,0(sp)
ffffffffc02025de:	000b0817          	auipc	a6,0xb0
ffffffffc02025e2:	27a80813          	addi	a6,a6,634 # ffffffffc02b2858 <va_pa_offset>
ffffffffc02025e6:	fff80e37          	lui	t3,0xfff80
ffffffffc02025ea:	00080337          	lui	t1,0x80
ffffffffc02025ee:	6885                	lui	a7,0x1
ffffffffc02025f0:	000b0717          	auipc	a4,0xb0
ffffffffc02025f4:	25870713          	addi	a4,a4,600 # ffffffffc02b2848 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02025f8:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc02025fc:	002007b7          	lui	a5,0x200
ffffffffc0202600:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202602:	f60918e3          	bnez	s2,ffffffffc0202572 <exit_range+0xee>
            if (free_pd0) {
ffffffffc0202606:	f00b85e3          	beqz	s7,ffffffffc0202510 <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc020260a:	000d3783          	ld	a5,0(s10)
ffffffffc020260e:	0efa7263          	bgeu	s4,a5,ffffffffc02026f2 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202612:	6308                	ld	a0,0(a4)
ffffffffc0202614:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202616:	100027f3          	csrr	a5,sstatus
ffffffffc020261a:	8b89                	andi	a5,a5,2
ffffffffc020261c:	efad                	bnez	a5,ffffffffc0202696 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc020261e:	000db783          	ld	a5,0(s11)
ffffffffc0202622:	4585                	li	a1,1
ffffffffc0202624:	739c                	ld	a5,32(a5)
ffffffffc0202626:	9782                	jalr	a5
ffffffffc0202628:	000b0717          	auipc	a4,0xb0
ffffffffc020262c:	22070713          	addi	a4,a4,544 # ffffffffc02b2848 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202630:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc0202634:	ee0990e3          	bnez	s3,ffffffffc0202514 <exit_range+0x90>
}
ffffffffc0202638:	70e6                	ld	ra,120(sp)
ffffffffc020263a:	7446                	ld	s0,112(sp)
ffffffffc020263c:	74a6                	ld	s1,104(sp)
ffffffffc020263e:	7906                	ld	s2,96(sp)
ffffffffc0202640:	69e6                	ld	s3,88(sp)
ffffffffc0202642:	6a46                	ld	s4,80(sp)
ffffffffc0202644:	6aa6                	ld	s5,72(sp)
ffffffffc0202646:	6b06                	ld	s6,64(sp)
ffffffffc0202648:	7be2                	ld	s7,56(sp)
ffffffffc020264a:	7c42                	ld	s8,48(sp)
ffffffffc020264c:	7ca2                	ld	s9,40(sp)
ffffffffc020264e:	7d02                	ld	s10,32(sp)
ffffffffc0202650:	6de2                	ld	s11,24(sp)
ffffffffc0202652:	6109                	addi	sp,sp,128
ffffffffc0202654:	8082                	ret
            if (free_pd0) {
ffffffffc0202656:	ea0b8fe3          	beqz	s7,ffffffffc0202514 <exit_range+0x90>
ffffffffc020265a:	bf45                	j	ffffffffc020260a <exit_range+0x186>
ffffffffc020265c:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc020265e:	e42a                	sd	a0,8(sp)
ffffffffc0202660:	fe7fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202664:	000db783          	ld	a5,0(s11)
ffffffffc0202668:	6522                	ld	a0,8(sp)
ffffffffc020266a:	4585                	li	a1,1
ffffffffc020266c:	739c                	ld	a5,32(a5)
ffffffffc020266e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202670:	fd1fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202674:	6602                	ld	a2,0(sp)
ffffffffc0202676:	000b0717          	auipc	a4,0xb0
ffffffffc020267a:	1d270713          	addi	a4,a4,466 # ffffffffc02b2848 <pages>
ffffffffc020267e:	6885                	lui	a7,0x1
ffffffffc0202680:	00080337          	lui	t1,0x80
ffffffffc0202684:	fff80e37          	lui	t3,0xfff80
ffffffffc0202688:	000b0817          	auipc	a6,0xb0
ffffffffc020268c:	1d080813          	addi	a6,a6,464 # ffffffffc02b2858 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202690:	0004b023          	sd	zero,0(s1)
ffffffffc0202694:	b7a5                	j	ffffffffc02025fc <exit_range+0x178>
ffffffffc0202696:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202698:	faffd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020269c:	000db783          	ld	a5,0(s11)
ffffffffc02026a0:	6502                	ld	a0,0(sp)
ffffffffc02026a2:	4585                	li	a1,1
ffffffffc02026a4:	739c                	ld	a5,32(a5)
ffffffffc02026a6:	9782                	jalr	a5
        intr_enable();
ffffffffc02026a8:	f99fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc02026ac:	000b0717          	auipc	a4,0xb0
ffffffffc02026b0:	19c70713          	addi	a4,a4,412 # ffffffffc02b2848 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02026b4:	00043023          	sd	zero,0(s0)
ffffffffc02026b8:	bfb5                	j	ffffffffc0202634 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02026ba:	00005697          	auipc	a3,0x5
ffffffffc02026be:	a1668693          	addi	a3,a3,-1514 # ffffffffc02070d0 <commands+0x770>
ffffffffc02026c2:	00004617          	auipc	a2,0x4
ffffffffc02026c6:	6ee60613          	addi	a2,a2,1774 # ffffffffc0206db0 <commands+0x450>
ffffffffc02026ca:	12000593          	li	a1,288
ffffffffc02026ce:	00005517          	auipc	a0,0x5
ffffffffc02026d2:	fba50513          	addi	a0,a0,-70 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc02026d6:	da5fd0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc02026da:	00005617          	auipc	a2,0x5
ffffffffc02026de:	b0e60613          	addi	a2,a2,-1266 # ffffffffc02071e8 <commands+0x888>
ffffffffc02026e2:	06900593          	li	a1,105
ffffffffc02026e6:	00005517          	auipc	a0,0x5
ffffffffc02026ea:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0207150 <commands+0x7f0>
ffffffffc02026ee:	d8dfd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc02026f2:	8e3ff0ef          	jal	ra,ffffffffc0201fd4 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc02026f6:	00005697          	auipc	a3,0x5
ffffffffc02026fa:	a1a68693          	addi	a3,a3,-1510 # ffffffffc0207110 <commands+0x7b0>
ffffffffc02026fe:	00004617          	auipc	a2,0x4
ffffffffc0202702:	6b260613          	addi	a2,a2,1714 # ffffffffc0206db0 <commands+0x450>
ffffffffc0202706:	12100593          	li	a1,289
ffffffffc020270a:	00005517          	auipc	a0,0x5
ffffffffc020270e:	f7e50513          	addi	a0,a0,-130 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0202712:	d69fd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0202716 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202716:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202718:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020271a:	ec26                	sd	s1,24(sp)
ffffffffc020271c:	f406                	sd	ra,40(sp)
ffffffffc020271e:	f022                	sd	s0,32(sp)
ffffffffc0202720:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202722:	9f7ff0ef          	jal	ra,ffffffffc0202118 <get_pte>
    if (ptep != NULL) {
ffffffffc0202726:	c511                	beqz	a0,ffffffffc0202732 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202728:	611c                	ld	a5,0(a0)
ffffffffc020272a:	842a                	mv	s0,a0
ffffffffc020272c:	0017f713          	andi	a4,a5,1
ffffffffc0202730:	e711                	bnez	a4,ffffffffc020273c <page_remove+0x26>
}
ffffffffc0202732:	70a2                	ld	ra,40(sp)
ffffffffc0202734:	7402                	ld	s0,32(sp)
ffffffffc0202736:	64e2                	ld	s1,24(sp)
ffffffffc0202738:	6145                	addi	sp,sp,48
ffffffffc020273a:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020273c:	078a                	slli	a5,a5,0x2
ffffffffc020273e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202740:	000b0717          	auipc	a4,0xb0
ffffffffc0202744:	10073703          	ld	a4,256(a4) # ffffffffc02b2840 <npage>
ffffffffc0202748:	06e7f363          	bgeu	a5,a4,ffffffffc02027ae <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc020274c:	fff80537          	lui	a0,0xfff80
ffffffffc0202750:	97aa                	add	a5,a5,a0
ffffffffc0202752:	079a                	slli	a5,a5,0x6
ffffffffc0202754:	000b0517          	auipc	a0,0xb0
ffffffffc0202758:	0f453503          	ld	a0,244(a0) # ffffffffc02b2848 <pages>
ffffffffc020275c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020275e:	411c                	lw	a5,0(a0)
ffffffffc0202760:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202764:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202766:	cb11                	beqz	a4,ffffffffc020277a <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202768:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020276c:	12048073          	sfence.vma	s1
}
ffffffffc0202770:	70a2                	ld	ra,40(sp)
ffffffffc0202772:	7402                	ld	s0,32(sp)
ffffffffc0202774:	64e2                	ld	s1,24(sp)
ffffffffc0202776:	6145                	addi	sp,sp,48
ffffffffc0202778:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020277a:	100027f3          	csrr	a5,sstatus
ffffffffc020277e:	8b89                	andi	a5,a5,2
ffffffffc0202780:	eb89                	bnez	a5,ffffffffc0202792 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0202782:	000b0797          	auipc	a5,0xb0
ffffffffc0202786:	0ce7b783          	ld	a5,206(a5) # ffffffffc02b2850 <pmm_manager>
ffffffffc020278a:	739c                	ld	a5,32(a5)
ffffffffc020278c:	4585                	li	a1,1
ffffffffc020278e:	9782                	jalr	a5
    if (flag) {
ffffffffc0202790:	bfe1                	j	ffffffffc0202768 <page_remove+0x52>
        intr_disable();
ffffffffc0202792:	e42a                	sd	a0,8(sp)
ffffffffc0202794:	eb3fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202798:	000b0797          	auipc	a5,0xb0
ffffffffc020279c:	0b87b783          	ld	a5,184(a5) # ffffffffc02b2850 <pmm_manager>
ffffffffc02027a0:	739c                	ld	a5,32(a5)
ffffffffc02027a2:	6522                	ld	a0,8(sp)
ffffffffc02027a4:	4585                	li	a1,1
ffffffffc02027a6:	9782                	jalr	a5
        intr_enable();
ffffffffc02027a8:	e99fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc02027ac:	bf75                	j	ffffffffc0202768 <page_remove+0x52>
ffffffffc02027ae:	827ff0ef          	jal	ra,ffffffffc0201fd4 <pa2page.part.0>

ffffffffc02027b2 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02027b2:	7139                	addi	sp,sp,-64
ffffffffc02027b4:	e852                	sd	s4,16(sp)
ffffffffc02027b6:	8a32                	mv	s4,a2
ffffffffc02027b8:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02027ba:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02027bc:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02027be:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02027c0:	f426                	sd	s1,40(sp)
ffffffffc02027c2:	fc06                	sd	ra,56(sp)
ffffffffc02027c4:	f04a                	sd	s2,32(sp)
ffffffffc02027c6:	ec4e                	sd	s3,24(sp)
ffffffffc02027c8:	e456                	sd	s5,8(sp)
ffffffffc02027ca:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02027cc:	94dff0ef          	jal	ra,ffffffffc0202118 <get_pte>
    if (ptep == NULL) {
ffffffffc02027d0:	c961                	beqz	a0,ffffffffc02028a0 <page_insert+0xee>
    page->ref += 1;
ffffffffc02027d2:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc02027d4:	611c                	ld	a5,0(a0)
ffffffffc02027d6:	89aa                	mv	s3,a0
ffffffffc02027d8:	0016871b          	addiw	a4,a3,1
ffffffffc02027dc:	c018                	sw	a4,0(s0)
ffffffffc02027de:	0017f713          	andi	a4,a5,1
ffffffffc02027e2:	ef05                	bnez	a4,ffffffffc020281a <page_insert+0x68>
    return page - pages + nbase;
ffffffffc02027e4:	000b0717          	auipc	a4,0xb0
ffffffffc02027e8:	06473703          	ld	a4,100(a4) # ffffffffc02b2848 <pages>
ffffffffc02027ec:	8c19                	sub	s0,s0,a4
ffffffffc02027ee:	000807b7          	lui	a5,0x80
ffffffffc02027f2:	8419                	srai	s0,s0,0x6
ffffffffc02027f4:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02027f6:	042a                	slli	s0,s0,0xa
ffffffffc02027f8:	8cc1                	or	s1,s1,s0
ffffffffc02027fa:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02027fe:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed8>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202802:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0202806:	4501                	li	a0,0
}
ffffffffc0202808:	70e2                	ld	ra,56(sp)
ffffffffc020280a:	7442                	ld	s0,48(sp)
ffffffffc020280c:	74a2                	ld	s1,40(sp)
ffffffffc020280e:	7902                	ld	s2,32(sp)
ffffffffc0202810:	69e2                	ld	s3,24(sp)
ffffffffc0202812:	6a42                	ld	s4,16(sp)
ffffffffc0202814:	6aa2                	ld	s5,8(sp)
ffffffffc0202816:	6121                	addi	sp,sp,64
ffffffffc0202818:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020281a:	078a                	slli	a5,a5,0x2
ffffffffc020281c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020281e:	000b0717          	auipc	a4,0xb0
ffffffffc0202822:	02273703          	ld	a4,34(a4) # ffffffffc02b2840 <npage>
ffffffffc0202826:	06e7ff63          	bgeu	a5,a4,ffffffffc02028a4 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc020282a:	000b0a97          	auipc	s5,0xb0
ffffffffc020282e:	01ea8a93          	addi	s5,s5,30 # ffffffffc02b2848 <pages>
ffffffffc0202832:	000ab703          	ld	a4,0(s5)
ffffffffc0202836:	fff80937          	lui	s2,0xfff80
ffffffffc020283a:	993e                	add	s2,s2,a5
ffffffffc020283c:	091a                	slli	s2,s2,0x6
ffffffffc020283e:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0202840:	01240c63          	beq	s0,s2,ffffffffc0202858 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0202844:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccd75c>
ffffffffc0202848:	fff7869b          	addiw	a3,a5,-1
ffffffffc020284c:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0202850:	c691                	beqz	a3,ffffffffc020285c <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202852:	120a0073          	sfence.vma	s4
}
ffffffffc0202856:	bf59                	j	ffffffffc02027ec <page_insert+0x3a>
ffffffffc0202858:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020285a:	bf49                	j	ffffffffc02027ec <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020285c:	100027f3          	csrr	a5,sstatus
ffffffffc0202860:	8b89                	andi	a5,a5,2
ffffffffc0202862:	ef91                	bnez	a5,ffffffffc020287e <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0202864:	000b0797          	auipc	a5,0xb0
ffffffffc0202868:	fec7b783          	ld	a5,-20(a5) # ffffffffc02b2850 <pmm_manager>
ffffffffc020286c:	739c                	ld	a5,32(a5)
ffffffffc020286e:	4585                	li	a1,1
ffffffffc0202870:	854a                	mv	a0,s2
ffffffffc0202872:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0202874:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202878:	120a0073          	sfence.vma	s4
ffffffffc020287c:	bf85                	j	ffffffffc02027ec <page_insert+0x3a>
        intr_disable();
ffffffffc020287e:	dc9fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202882:	000b0797          	auipc	a5,0xb0
ffffffffc0202886:	fce7b783          	ld	a5,-50(a5) # ffffffffc02b2850 <pmm_manager>
ffffffffc020288a:	739c                	ld	a5,32(a5)
ffffffffc020288c:	4585                	li	a1,1
ffffffffc020288e:	854a                	mv	a0,s2
ffffffffc0202890:	9782                	jalr	a5
        intr_enable();
ffffffffc0202892:	daffd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202896:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020289a:	120a0073          	sfence.vma	s4
ffffffffc020289e:	b7b9                	j	ffffffffc02027ec <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc02028a0:	5571                	li	a0,-4
ffffffffc02028a2:	b79d                	j	ffffffffc0202808 <page_insert+0x56>
ffffffffc02028a4:	f30ff0ef          	jal	ra,ffffffffc0201fd4 <pa2page.part.0>

ffffffffc02028a8 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02028a8:	00005797          	auipc	a5,0x5
ffffffffc02028ac:	d1078793          	addi	a5,a5,-752 # ffffffffc02075b8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02028b0:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc02028b2:	711d                	addi	sp,sp,-96
ffffffffc02028b4:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02028b6:	00005517          	auipc	a0,0x5
ffffffffc02028ba:	de250513          	addi	a0,a0,-542 # ffffffffc0207698 <default_pmm_manager+0xe0>
    pmm_manager = &default_pmm_manager;
ffffffffc02028be:	000b0b97          	auipc	s7,0xb0
ffffffffc02028c2:	f92b8b93          	addi	s7,s7,-110 # ffffffffc02b2850 <pmm_manager>
void pmm_init(void) {
ffffffffc02028c6:	ec86                	sd	ra,88(sp)
ffffffffc02028c8:	e4a6                	sd	s1,72(sp)
ffffffffc02028ca:	fc4e                	sd	s3,56(sp)
ffffffffc02028cc:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02028ce:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc02028d2:	e8a2                	sd	s0,80(sp)
ffffffffc02028d4:	e0ca                	sd	s2,64(sp)
ffffffffc02028d6:	f852                	sd	s4,48(sp)
ffffffffc02028d8:	f456                	sd	s5,40(sp)
ffffffffc02028da:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02028dc:	8a5fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pmm_manager->init();
ffffffffc02028e0:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02028e4:	000b0997          	auipc	s3,0xb0
ffffffffc02028e8:	f7498993          	addi	s3,s3,-140 # ffffffffc02b2858 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc02028ec:	000b0497          	auipc	s1,0xb0
ffffffffc02028f0:	f5448493          	addi	s1,s1,-172 # ffffffffc02b2840 <npage>
    pmm_manager->init();
ffffffffc02028f4:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02028f6:	000b0b17          	auipc	s6,0xb0
ffffffffc02028fa:	f52b0b13          	addi	s6,s6,-174 # ffffffffc02b2848 <pages>
    pmm_manager->init();
ffffffffc02028fe:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202900:	57f5                	li	a5,-3
ffffffffc0202902:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0202904:	00005517          	auipc	a0,0x5
ffffffffc0202908:	dac50513          	addi	a0,a0,-596 # ffffffffc02076b0 <default_pmm_manager+0xf8>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020290c:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc0202910:	871fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202914:	46c5                	li	a3,17
ffffffffc0202916:	06ee                	slli	a3,a3,0x1b
ffffffffc0202918:	40100613          	li	a2,1025
ffffffffc020291c:	07e005b7          	lui	a1,0x7e00
ffffffffc0202920:	16fd                	addi	a3,a3,-1
ffffffffc0202922:	0656                	slli	a2,a2,0x15
ffffffffc0202924:	00005517          	auipc	a0,0x5
ffffffffc0202928:	da450513          	addi	a0,a0,-604 # ffffffffc02076c8 <default_pmm_manager+0x110>
ffffffffc020292c:	855fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202930:	777d                	lui	a4,0xfffff
ffffffffc0202932:	000b1797          	auipc	a5,0xb1
ffffffffc0202936:	f7178793          	addi	a5,a5,-143 # ffffffffc02b38a3 <end+0xfff>
ffffffffc020293a:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020293c:	00088737          	lui	a4,0x88
ffffffffc0202940:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202942:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202946:	4701                	li	a4,0
ffffffffc0202948:	4585                	li	a1,1
ffffffffc020294a:	fff80837          	lui	a6,0xfff80
ffffffffc020294e:	a019                	j	ffffffffc0202954 <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc0202950:	000b3783          	ld	a5,0(s6)
ffffffffc0202954:	00671693          	slli	a3,a4,0x6
ffffffffc0202958:	97b6                	add	a5,a5,a3
ffffffffc020295a:	07a1                	addi	a5,a5,8
ffffffffc020295c:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202960:	6090                	ld	a2,0(s1)
ffffffffc0202962:	0705                	addi	a4,a4,1
ffffffffc0202964:	010607b3          	add	a5,a2,a6
ffffffffc0202968:	fef764e3          	bltu	a4,a5,ffffffffc0202950 <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020296c:	000b3503          	ld	a0,0(s6)
ffffffffc0202970:	079a                	slli	a5,a5,0x6
ffffffffc0202972:	c0200737          	lui	a4,0xc0200
ffffffffc0202976:	00f506b3          	add	a3,a0,a5
ffffffffc020297a:	60e6e563          	bltu	a3,a4,ffffffffc0202f84 <pmm_init+0x6dc>
ffffffffc020297e:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202982:	4745                	li	a4,17
ffffffffc0202984:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202986:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0202988:	4ae6e563          	bltu	a3,a4,ffffffffc0202e32 <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc020298c:	00005517          	auipc	a0,0x5
ffffffffc0202990:	d6450513          	addi	a0,a0,-668 # ffffffffc02076f0 <default_pmm_manager+0x138>
ffffffffc0202994:	fecfd0ef          	jal	ra,ffffffffc0200180 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202998:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020299c:	000b0917          	auipc	s2,0xb0
ffffffffc02029a0:	e9c90913          	addi	s2,s2,-356 # ffffffffc02b2838 <boot_pgdir>
    pmm_manager->check();
ffffffffc02029a4:	7b9c                	ld	a5,48(a5)
ffffffffc02029a6:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02029a8:	00005517          	auipc	a0,0x5
ffffffffc02029ac:	d6050513          	addi	a0,a0,-672 # ffffffffc0207708 <default_pmm_manager+0x150>
ffffffffc02029b0:	fd0fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02029b4:	00008697          	auipc	a3,0x8
ffffffffc02029b8:	64c68693          	addi	a3,a3,1612 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc02029bc:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02029c0:	c02007b7          	lui	a5,0xc0200
ffffffffc02029c4:	5cf6ec63          	bltu	a3,a5,ffffffffc0202f9c <pmm_init+0x6f4>
ffffffffc02029c8:	0009b783          	ld	a5,0(s3)
ffffffffc02029cc:	8e9d                	sub	a3,a3,a5
ffffffffc02029ce:	000b0797          	auipc	a5,0xb0
ffffffffc02029d2:	e6d7b123          	sd	a3,-414(a5) # ffffffffc02b2830 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02029d6:	100027f3          	csrr	a5,sstatus
ffffffffc02029da:	8b89                	andi	a5,a5,2
ffffffffc02029dc:	48079263          	bnez	a5,ffffffffc0202e60 <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc02029e0:	000bb783          	ld	a5,0(s7)
ffffffffc02029e4:	779c                	ld	a5,40(a5)
ffffffffc02029e6:	9782                	jalr	a5
ffffffffc02029e8:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02029ea:	6098                	ld	a4,0(s1)
ffffffffc02029ec:	c80007b7          	lui	a5,0xc8000
ffffffffc02029f0:	83b1                	srli	a5,a5,0xc
ffffffffc02029f2:	5ee7e163          	bltu	a5,a4,ffffffffc0202fd4 <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02029f6:	00093503          	ld	a0,0(s2)
ffffffffc02029fa:	5a050d63          	beqz	a0,ffffffffc0202fb4 <pmm_init+0x70c>
ffffffffc02029fe:	03451793          	slli	a5,a0,0x34
ffffffffc0202a02:	5a079963          	bnez	a5,ffffffffc0202fb4 <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202a06:	4601                	li	a2,0
ffffffffc0202a08:	4581                	li	a1,0
ffffffffc0202a0a:	8e1ff0ef          	jal	ra,ffffffffc02022ea <get_page>
ffffffffc0202a0e:	62051563          	bnez	a0,ffffffffc0203038 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0202a12:	4505                	li	a0,1
ffffffffc0202a14:	df8ff0ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc0202a18:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202a1a:	00093503          	ld	a0,0(s2)
ffffffffc0202a1e:	4681                	li	a3,0
ffffffffc0202a20:	4601                	li	a2,0
ffffffffc0202a22:	85d2                	mv	a1,s4
ffffffffc0202a24:	d8fff0ef          	jal	ra,ffffffffc02027b2 <page_insert>
ffffffffc0202a28:	5e051863          	bnez	a0,ffffffffc0203018 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202a2c:	00093503          	ld	a0,0(s2)
ffffffffc0202a30:	4601                	li	a2,0
ffffffffc0202a32:	4581                	li	a1,0
ffffffffc0202a34:	ee4ff0ef          	jal	ra,ffffffffc0202118 <get_pte>
ffffffffc0202a38:	5c050063          	beqz	a0,ffffffffc0202ff8 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc0202a3c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202a3e:	0017f713          	andi	a4,a5,1
ffffffffc0202a42:	5a070963          	beqz	a4,ffffffffc0202ff4 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0202a46:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202a48:	078a                	slli	a5,a5,0x2
ffffffffc0202a4a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a4c:	52e7fa63          	bgeu	a5,a4,ffffffffc0202f80 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a50:	000b3683          	ld	a3,0(s6)
ffffffffc0202a54:	fff80637          	lui	a2,0xfff80
ffffffffc0202a58:	97b2                	add	a5,a5,a2
ffffffffc0202a5a:	079a                	slli	a5,a5,0x6
ffffffffc0202a5c:	97b6                	add	a5,a5,a3
ffffffffc0202a5e:	10fa16e3          	bne	s4,a5,ffffffffc020336a <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc0202a62:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0202a66:	4785                	li	a5,1
ffffffffc0202a68:	12f69de3          	bne	a3,a5,ffffffffc02033a2 <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202a6c:	00093503          	ld	a0,0(s2)
ffffffffc0202a70:	77fd                	lui	a5,0xfffff
ffffffffc0202a72:	6114                	ld	a3,0(a0)
ffffffffc0202a74:	068a                	slli	a3,a3,0x2
ffffffffc0202a76:	8efd                	and	a3,a3,a5
ffffffffc0202a78:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202a7c:	10e677e3          	bgeu	a2,a4,ffffffffc020338a <pmm_init+0xae2>
ffffffffc0202a80:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202a84:	96e2                	add	a3,a3,s8
ffffffffc0202a86:	0006ba83          	ld	s5,0(a3)
ffffffffc0202a8a:	0a8a                	slli	s5,s5,0x2
ffffffffc0202a8c:	00fafab3          	and	s5,s5,a5
ffffffffc0202a90:	00cad793          	srli	a5,s5,0xc
ffffffffc0202a94:	62e7f263          	bgeu	a5,a4,ffffffffc02030b8 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202a98:	4601                	li	a2,0
ffffffffc0202a9a:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202a9c:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202a9e:	e7aff0ef          	jal	ra,ffffffffc0202118 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202aa2:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202aa4:	5f551a63          	bne	a0,s5,ffffffffc0203098 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc0202aa8:	4505                	li	a0,1
ffffffffc0202aaa:	d62ff0ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc0202aae:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202ab0:	00093503          	ld	a0,0(s2)
ffffffffc0202ab4:	46d1                	li	a3,20
ffffffffc0202ab6:	6605                	lui	a2,0x1
ffffffffc0202ab8:	85d6                	mv	a1,s5
ffffffffc0202aba:	cf9ff0ef          	jal	ra,ffffffffc02027b2 <page_insert>
ffffffffc0202abe:	58051d63          	bnez	a0,ffffffffc0203058 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202ac2:	00093503          	ld	a0,0(s2)
ffffffffc0202ac6:	4601                	li	a2,0
ffffffffc0202ac8:	6585                	lui	a1,0x1
ffffffffc0202aca:	e4eff0ef          	jal	ra,ffffffffc0202118 <get_pte>
ffffffffc0202ace:	0e050ae3          	beqz	a0,ffffffffc02033c2 <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc0202ad2:	611c                	ld	a5,0(a0)
ffffffffc0202ad4:	0107f713          	andi	a4,a5,16
ffffffffc0202ad8:	6e070d63          	beqz	a4,ffffffffc02031d2 <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc0202adc:	8b91                	andi	a5,a5,4
ffffffffc0202ade:	6a078a63          	beqz	a5,ffffffffc0203192 <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202ae2:	00093503          	ld	a0,0(s2)
ffffffffc0202ae6:	611c                	ld	a5,0(a0)
ffffffffc0202ae8:	8bc1                	andi	a5,a5,16
ffffffffc0202aea:	68078463          	beqz	a5,ffffffffc0203172 <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc0202aee:	000aa703          	lw	a4,0(s5)
ffffffffc0202af2:	4785                	li	a5,1
ffffffffc0202af4:	58f71263          	bne	a4,a5,ffffffffc0203078 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202af8:	4681                	li	a3,0
ffffffffc0202afa:	6605                	lui	a2,0x1
ffffffffc0202afc:	85d2                	mv	a1,s4
ffffffffc0202afe:	cb5ff0ef          	jal	ra,ffffffffc02027b2 <page_insert>
ffffffffc0202b02:	62051863          	bnez	a0,ffffffffc0203132 <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc0202b06:	000a2703          	lw	a4,0(s4)
ffffffffc0202b0a:	4789                	li	a5,2
ffffffffc0202b0c:	60f71363          	bne	a4,a5,ffffffffc0203112 <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc0202b10:	000aa783          	lw	a5,0(s5)
ffffffffc0202b14:	5c079f63          	bnez	a5,ffffffffc02030f2 <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202b18:	00093503          	ld	a0,0(s2)
ffffffffc0202b1c:	4601                	li	a2,0
ffffffffc0202b1e:	6585                	lui	a1,0x1
ffffffffc0202b20:	df8ff0ef          	jal	ra,ffffffffc0202118 <get_pte>
ffffffffc0202b24:	5a050763          	beqz	a0,ffffffffc02030d2 <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc0202b28:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202b2a:	00177793          	andi	a5,a4,1
ffffffffc0202b2e:	4c078363          	beqz	a5,ffffffffc0202ff4 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0202b32:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202b34:	00271793          	slli	a5,a4,0x2
ffffffffc0202b38:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b3a:	44d7f363          	bgeu	a5,a3,ffffffffc0202f80 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b3e:	000b3683          	ld	a3,0(s6)
ffffffffc0202b42:	fff80637          	lui	a2,0xfff80
ffffffffc0202b46:	97b2                	add	a5,a5,a2
ffffffffc0202b48:	079a                	slli	a5,a5,0x6
ffffffffc0202b4a:	97b6                	add	a5,a5,a3
ffffffffc0202b4c:	6efa1363          	bne	s4,a5,ffffffffc0203232 <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202b50:	8b41                	andi	a4,a4,16
ffffffffc0202b52:	6c071063          	bnez	a4,ffffffffc0203212 <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc0202b56:	00093503          	ld	a0,0(s2)
ffffffffc0202b5a:	4581                	li	a1,0
ffffffffc0202b5c:	bbbff0ef          	jal	ra,ffffffffc0202716 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202b60:	000a2703          	lw	a4,0(s4)
ffffffffc0202b64:	4785                	li	a5,1
ffffffffc0202b66:	68f71663          	bne	a4,a5,ffffffffc02031f2 <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc0202b6a:	000aa783          	lw	a5,0(s5)
ffffffffc0202b6e:	74079e63          	bnez	a5,ffffffffc02032ca <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202b72:	00093503          	ld	a0,0(s2)
ffffffffc0202b76:	6585                	lui	a1,0x1
ffffffffc0202b78:	b9fff0ef          	jal	ra,ffffffffc0202716 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202b7c:	000a2783          	lw	a5,0(s4)
ffffffffc0202b80:	72079563          	bnez	a5,ffffffffc02032aa <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc0202b84:	000aa783          	lw	a5,0(s5)
ffffffffc0202b88:	70079163          	bnez	a5,ffffffffc020328a <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202b8c:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202b90:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b92:	000a3683          	ld	a3,0(s4)
ffffffffc0202b96:	068a                	slli	a3,a3,0x2
ffffffffc0202b98:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b9a:	3ee6f363          	bgeu	a3,a4,ffffffffc0202f80 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b9e:	fff807b7          	lui	a5,0xfff80
ffffffffc0202ba2:	000b3503          	ld	a0,0(s6)
ffffffffc0202ba6:	96be                	add	a3,a3,a5
ffffffffc0202ba8:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0202baa:	00d507b3          	add	a5,a0,a3
ffffffffc0202bae:	4390                	lw	a2,0(a5)
ffffffffc0202bb0:	4785                	li	a5,1
ffffffffc0202bb2:	6af61c63          	bne	a2,a5,ffffffffc020326a <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc0202bb6:	8699                	srai	a3,a3,0x6
ffffffffc0202bb8:	000805b7          	lui	a1,0x80
ffffffffc0202bbc:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0202bbe:	00c69613          	slli	a2,a3,0xc
ffffffffc0202bc2:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202bc4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202bc6:	68e67663          	bgeu	a2,a4,ffffffffc0203252 <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202bca:	0009b603          	ld	a2,0(s3)
ffffffffc0202bce:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bd0:	629c                	ld	a5,0(a3)
ffffffffc0202bd2:	078a                	slli	a5,a5,0x2
ffffffffc0202bd4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202bd6:	3ae7f563          	bgeu	a5,a4,ffffffffc0202f80 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202bda:	8f8d                	sub	a5,a5,a1
ffffffffc0202bdc:	079a                	slli	a5,a5,0x6
ffffffffc0202bde:	953e                	add	a0,a0,a5
ffffffffc0202be0:	100027f3          	csrr	a5,sstatus
ffffffffc0202be4:	8b89                	andi	a5,a5,2
ffffffffc0202be6:	2c079763          	bnez	a5,ffffffffc0202eb4 <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc0202bea:	000bb783          	ld	a5,0(s7)
ffffffffc0202bee:	4585                	li	a1,1
ffffffffc0202bf0:	739c                	ld	a5,32(a5)
ffffffffc0202bf2:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bf4:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202bf8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bfa:	078a                	slli	a5,a5,0x2
ffffffffc0202bfc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202bfe:	38e7f163          	bgeu	a5,a4,ffffffffc0202f80 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c02:	000b3503          	ld	a0,0(s6)
ffffffffc0202c06:	fff80737          	lui	a4,0xfff80
ffffffffc0202c0a:	97ba                	add	a5,a5,a4
ffffffffc0202c0c:	079a                	slli	a5,a5,0x6
ffffffffc0202c0e:	953e                	add	a0,a0,a5
ffffffffc0202c10:	100027f3          	csrr	a5,sstatus
ffffffffc0202c14:	8b89                	andi	a5,a5,2
ffffffffc0202c16:	28079363          	bnez	a5,ffffffffc0202e9c <pmm_init+0x5f4>
ffffffffc0202c1a:	000bb783          	ld	a5,0(s7)
ffffffffc0202c1e:	4585                	li	a1,1
ffffffffc0202c20:	739c                	ld	a5,32(a5)
ffffffffc0202c22:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202c24:	00093783          	ld	a5,0(s2)
ffffffffc0202c28:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fccd75c>
  asm volatile("sfence.vma");
ffffffffc0202c2c:	12000073          	sfence.vma
ffffffffc0202c30:	100027f3          	csrr	a5,sstatus
ffffffffc0202c34:	8b89                	andi	a5,a5,2
ffffffffc0202c36:	24079963          	bnez	a5,ffffffffc0202e88 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c3a:	000bb783          	ld	a5,0(s7)
ffffffffc0202c3e:	779c                	ld	a5,40(a5)
ffffffffc0202c40:	9782                	jalr	a5
ffffffffc0202c42:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202c44:	71441363          	bne	s0,s4,ffffffffc020334a <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202c48:	00005517          	auipc	a0,0x5
ffffffffc0202c4c:	da850513          	addi	a0,a0,-600 # ffffffffc02079f0 <default_pmm_manager+0x438>
ffffffffc0202c50:	d30fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202c54:	100027f3          	csrr	a5,sstatus
ffffffffc0202c58:	8b89                	andi	a5,a5,2
ffffffffc0202c5a:	20079d63          	bnez	a5,ffffffffc0202e74 <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c5e:	000bb783          	ld	a5,0(s7)
ffffffffc0202c62:	779c                	ld	a5,40(a5)
ffffffffc0202c64:	9782                	jalr	a5
ffffffffc0202c66:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202c68:	6098                	ld	a4,0(s1)
ffffffffc0202c6a:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202c6e:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202c70:	00c71793          	slli	a5,a4,0xc
ffffffffc0202c74:	6a05                	lui	s4,0x1
ffffffffc0202c76:	02f47c63          	bgeu	s0,a5,ffffffffc0202cae <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202c7a:	00c45793          	srli	a5,s0,0xc
ffffffffc0202c7e:	00093503          	ld	a0,0(s2)
ffffffffc0202c82:	2ee7f263          	bgeu	a5,a4,ffffffffc0202f66 <pmm_init+0x6be>
ffffffffc0202c86:	0009b583          	ld	a1,0(s3)
ffffffffc0202c8a:	4601                	li	a2,0
ffffffffc0202c8c:	95a2                	add	a1,a1,s0
ffffffffc0202c8e:	c8aff0ef          	jal	ra,ffffffffc0202118 <get_pte>
ffffffffc0202c92:	2a050a63          	beqz	a0,ffffffffc0202f46 <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202c96:	611c                	ld	a5,0(a0)
ffffffffc0202c98:	078a                	slli	a5,a5,0x2
ffffffffc0202c9a:	0157f7b3          	and	a5,a5,s5
ffffffffc0202c9e:	28879463          	bne	a5,s0,ffffffffc0202f26 <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202ca2:	6098                	ld	a4,0(s1)
ffffffffc0202ca4:	9452                	add	s0,s0,s4
ffffffffc0202ca6:	00c71793          	slli	a5,a4,0xc
ffffffffc0202caa:	fcf468e3          	bltu	s0,a5,ffffffffc0202c7a <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202cae:	00093783          	ld	a5,0(s2)
ffffffffc0202cb2:	639c                	ld	a5,0(a5)
ffffffffc0202cb4:	66079b63          	bnez	a5,ffffffffc020332a <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc0202cb8:	4505                	li	a0,1
ffffffffc0202cba:	b52ff0ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc0202cbe:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202cc0:	00093503          	ld	a0,0(s2)
ffffffffc0202cc4:	4699                	li	a3,6
ffffffffc0202cc6:	10000613          	li	a2,256
ffffffffc0202cca:	85d6                	mv	a1,s5
ffffffffc0202ccc:	ae7ff0ef          	jal	ra,ffffffffc02027b2 <page_insert>
ffffffffc0202cd0:	62051d63          	bnez	a0,ffffffffc020330a <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc0202cd4:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd4c75c>
ffffffffc0202cd8:	4785                	li	a5,1
ffffffffc0202cda:	60f71863          	bne	a4,a5,ffffffffc02032ea <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202cde:	00093503          	ld	a0,0(s2)
ffffffffc0202ce2:	6405                	lui	s0,0x1
ffffffffc0202ce4:	4699                	li	a3,6
ffffffffc0202ce6:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ab0>
ffffffffc0202cea:	85d6                	mv	a1,s5
ffffffffc0202cec:	ac7ff0ef          	jal	ra,ffffffffc02027b2 <page_insert>
ffffffffc0202cf0:	46051163          	bnez	a0,ffffffffc0203152 <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc0202cf4:	000aa703          	lw	a4,0(s5)
ffffffffc0202cf8:	4789                	li	a5,2
ffffffffc0202cfa:	72f71463          	bne	a4,a5,ffffffffc0203422 <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202cfe:	00005597          	auipc	a1,0x5
ffffffffc0202d02:	e2a58593          	addi	a1,a1,-470 # ffffffffc0207b28 <default_pmm_manager+0x570>
ffffffffc0202d06:	10000513          	li	a0,256
ffffffffc0202d0a:	179030ef          	jal	ra,ffffffffc0206682 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202d0e:	10040593          	addi	a1,s0,256
ffffffffc0202d12:	10000513          	li	a0,256
ffffffffc0202d16:	17f030ef          	jal	ra,ffffffffc0206694 <strcmp>
ffffffffc0202d1a:	6e051463          	bnez	a0,ffffffffc0203402 <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc0202d1e:	000b3683          	ld	a3,0(s6)
ffffffffc0202d22:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202d26:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0202d28:	40da86b3          	sub	a3,s5,a3
ffffffffc0202d2c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202d2e:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202d30:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202d32:	8031                	srli	s0,s0,0xc
ffffffffc0202d34:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d38:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202d3a:	50f77c63          	bgeu	a4,a5,ffffffffc0203252 <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202d3e:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202d42:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202d46:	96be                	add	a3,a3,a5
ffffffffc0202d48:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202d4c:	101030ef          	jal	ra,ffffffffc020664c <strlen>
ffffffffc0202d50:	68051963          	bnez	a0,ffffffffc02033e2 <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202d54:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202d58:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d5a:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0202d5e:	068a                	slli	a3,a3,0x2
ffffffffc0202d60:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d62:	20f6ff63          	bgeu	a3,a5,ffffffffc0202f80 <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc0202d66:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d68:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202d6a:	4ef47463          	bgeu	s0,a5,ffffffffc0203252 <pmm_init+0x9aa>
ffffffffc0202d6e:	0009b403          	ld	s0,0(s3)
ffffffffc0202d72:	9436                	add	s0,s0,a3
ffffffffc0202d74:	100027f3          	csrr	a5,sstatus
ffffffffc0202d78:	8b89                	andi	a5,a5,2
ffffffffc0202d7a:	18079b63          	bnez	a5,ffffffffc0202f10 <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc0202d7e:	000bb783          	ld	a5,0(s7)
ffffffffc0202d82:	4585                	li	a1,1
ffffffffc0202d84:	8556                	mv	a0,s5
ffffffffc0202d86:	739c                	ld	a5,32(a5)
ffffffffc0202d88:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d8a:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202d8c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d8e:	078a                	slli	a5,a5,0x2
ffffffffc0202d90:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d92:	1ee7f763          	bgeu	a5,a4,ffffffffc0202f80 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d96:	000b3503          	ld	a0,0(s6)
ffffffffc0202d9a:	fff80737          	lui	a4,0xfff80
ffffffffc0202d9e:	97ba                	add	a5,a5,a4
ffffffffc0202da0:	079a                	slli	a5,a5,0x6
ffffffffc0202da2:	953e                	add	a0,a0,a5
ffffffffc0202da4:	100027f3          	csrr	a5,sstatus
ffffffffc0202da8:	8b89                	andi	a5,a5,2
ffffffffc0202daa:	14079763          	bnez	a5,ffffffffc0202ef8 <pmm_init+0x650>
ffffffffc0202dae:	000bb783          	ld	a5,0(s7)
ffffffffc0202db2:	4585                	li	a1,1
ffffffffc0202db4:	739c                	ld	a5,32(a5)
ffffffffc0202db6:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202db8:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202dbc:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202dbe:	078a                	slli	a5,a5,0x2
ffffffffc0202dc0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202dc2:	1ae7ff63          	bgeu	a5,a4,ffffffffc0202f80 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dc6:	000b3503          	ld	a0,0(s6)
ffffffffc0202dca:	fff80737          	lui	a4,0xfff80
ffffffffc0202dce:	97ba                	add	a5,a5,a4
ffffffffc0202dd0:	079a                	slli	a5,a5,0x6
ffffffffc0202dd2:	953e                	add	a0,a0,a5
ffffffffc0202dd4:	100027f3          	csrr	a5,sstatus
ffffffffc0202dd8:	8b89                	andi	a5,a5,2
ffffffffc0202dda:	10079363          	bnez	a5,ffffffffc0202ee0 <pmm_init+0x638>
ffffffffc0202dde:	000bb783          	ld	a5,0(s7)
ffffffffc0202de2:	4585                	li	a1,1
ffffffffc0202de4:	739c                	ld	a5,32(a5)
ffffffffc0202de6:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202de8:	00093783          	ld	a5,0(s2)
ffffffffc0202dec:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202df0:	12000073          	sfence.vma
ffffffffc0202df4:	100027f3          	csrr	a5,sstatus
ffffffffc0202df8:	8b89                	andi	a5,a5,2
ffffffffc0202dfa:	0c079963          	bnez	a5,ffffffffc0202ecc <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202dfe:	000bb783          	ld	a5,0(s7)
ffffffffc0202e02:	779c                	ld	a5,40(a5)
ffffffffc0202e04:	9782                	jalr	a5
ffffffffc0202e06:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202e08:	3a8c1563          	bne	s8,s0,ffffffffc02031b2 <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202e0c:	00005517          	auipc	a0,0x5
ffffffffc0202e10:	d9450513          	addi	a0,a0,-620 # ffffffffc0207ba0 <default_pmm_manager+0x5e8>
ffffffffc0202e14:	b6cfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0202e18:	6446                	ld	s0,80(sp)
ffffffffc0202e1a:	60e6                	ld	ra,88(sp)
ffffffffc0202e1c:	64a6                	ld	s1,72(sp)
ffffffffc0202e1e:	6906                	ld	s2,64(sp)
ffffffffc0202e20:	79e2                	ld	s3,56(sp)
ffffffffc0202e22:	7a42                	ld	s4,48(sp)
ffffffffc0202e24:	7aa2                	ld	s5,40(sp)
ffffffffc0202e26:	7b02                	ld	s6,32(sp)
ffffffffc0202e28:	6be2                	ld	s7,24(sp)
ffffffffc0202e2a:	6c42                	ld	s8,16(sp)
ffffffffc0202e2c:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0202e2e:	fddfe06f          	j	ffffffffc0201e0a <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202e32:	6785                	lui	a5,0x1
ffffffffc0202e34:	17fd                	addi	a5,a5,-1
ffffffffc0202e36:	96be                	add	a3,a3,a5
ffffffffc0202e38:	77fd                	lui	a5,0xfffff
ffffffffc0202e3a:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0202e3c:	00c7d693          	srli	a3,a5,0xc
ffffffffc0202e40:	14c6f063          	bgeu	a3,a2,ffffffffc0202f80 <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0202e44:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0202e48:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202e4a:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0202e4e:	6a10                	ld	a2,16(a2)
ffffffffc0202e50:	069a                	slli	a3,a3,0x6
ffffffffc0202e52:	00c7d593          	srli	a1,a5,0xc
ffffffffc0202e56:	9536                	add	a0,a0,a3
ffffffffc0202e58:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202e5a:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202e5e:	b63d                	j	ffffffffc020298c <pmm_init+0xe4>
        intr_disable();
ffffffffc0202e60:	fe6fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e64:	000bb783          	ld	a5,0(s7)
ffffffffc0202e68:	779c                	ld	a5,40(a5)
ffffffffc0202e6a:	9782                	jalr	a5
ffffffffc0202e6c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202e6e:	fd2fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202e72:	bea5                	j	ffffffffc02029ea <pmm_init+0x142>
        intr_disable();
ffffffffc0202e74:	fd2fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202e78:	000bb783          	ld	a5,0(s7)
ffffffffc0202e7c:	779c                	ld	a5,40(a5)
ffffffffc0202e7e:	9782                	jalr	a5
ffffffffc0202e80:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202e82:	fbefd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202e86:	b3cd                	j	ffffffffc0202c68 <pmm_init+0x3c0>
        intr_disable();
ffffffffc0202e88:	fbefd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202e8c:	000bb783          	ld	a5,0(s7)
ffffffffc0202e90:	779c                	ld	a5,40(a5)
ffffffffc0202e92:	9782                	jalr	a5
ffffffffc0202e94:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202e96:	faafd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202e9a:	b36d                	j	ffffffffc0202c44 <pmm_init+0x39c>
ffffffffc0202e9c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202e9e:	fa8fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202ea2:	000bb783          	ld	a5,0(s7)
ffffffffc0202ea6:	6522                	ld	a0,8(sp)
ffffffffc0202ea8:	4585                	li	a1,1
ffffffffc0202eaa:	739c                	ld	a5,32(a5)
ffffffffc0202eac:	9782                	jalr	a5
        intr_enable();
ffffffffc0202eae:	f92fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202eb2:	bb8d                	j	ffffffffc0202c24 <pmm_init+0x37c>
ffffffffc0202eb4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202eb6:	f90fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202eba:	000bb783          	ld	a5,0(s7)
ffffffffc0202ebe:	6522                	ld	a0,8(sp)
ffffffffc0202ec0:	4585                	li	a1,1
ffffffffc0202ec2:	739c                	ld	a5,32(a5)
ffffffffc0202ec4:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ec6:	f7afd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202eca:	b32d                	j	ffffffffc0202bf4 <pmm_init+0x34c>
        intr_disable();
ffffffffc0202ecc:	f7afd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ed0:	000bb783          	ld	a5,0(s7)
ffffffffc0202ed4:	779c                	ld	a5,40(a5)
ffffffffc0202ed6:	9782                	jalr	a5
ffffffffc0202ed8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202eda:	f66fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202ede:	b72d                	j	ffffffffc0202e08 <pmm_init+0x560>
ffffffffc0202ee0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202ee2:	f64fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202ee6:	000bb783          	ld	a5,0(s7)
ffffffffc0202eea:	6522                	ld	a0,8(sp)
ffffffffc0202eec:	4585                	li	a1,1
ffffffffc0202eee:	739c                	ld	a5,32(a5)
ffffffffc0202ef0:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ef2:	f4efd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202ef6:	bdcd                	j	ffffffffc0202de8 <pmm_init+0x540>
ffffffffc0202ef8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202efa:	f4cfd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202efe:	000bb783          	ld	a5,0(s7)
ffffffffc0202f02:	6522                	ld	a0,8(sp)
ffffffffc0202f04:	4585                	li	a1,1
ffffffffc0202f06:	739c                	ld	a5,32(a5)
ffffffffc0202f08:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f0a:	f36fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202f0e:	b56d                	j	ffffffffc0202db8 <pmm_init+0x510>
        intr_disable();
ffffffffc0202f10:	f36fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202f14:	000bb783          	ld	a5,0(s7)
ffffffffc0202f18:	4585                	li	a1,1
ffffffffc0202f1a:	8556                	mv	a0,s5
ffffffffc0202f1c:	739c                	ld	a5,32(a5)
ffffffffc0202f1e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f20:	f20fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202f24:	b59d                	j	ffffffffc0202d8a <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202f26:	00005697          	auipc	a3,0x5
ffffffffc0202f2a:	b2a68693          	addi	a3,a3,-1238 # ffffffffc0207a50 <default_pmm_manager+0x498>
ffffffffc0202f2e:	00004617          	auipc	a2,0x4
ffffffffc0202f32:	e8260613          	addi	a2,a2,-382 # ffffffffc0206db0 <commands+0x450>
ffffffffc0202f36:	22f00593          	li	a1,559
ffffffffc0202f3a:	00004517          	auipc	a0,0x4
ffffffffc0202f3e:	74e50513          	addi	a0,a0,1870 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0202f42:	d38fd0ef          	jal	ra,ffffffffc020047a <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202f46:	00005697          	auipc	a3,0x5
ffffffffc0202f4a:	aca68693          	addi	a3,a3,-1334 # ffffffffc0207a10 <default_pmm_manager+0x458>
ffffffffc0202f4e:	00004617          	auipc	a2,0x4
ffffffffc0202f52:	e6260613          	addi	a2,a2,-414 # ffffffffc0206db0 <commands+0x450>
ffffffffc0202f56:	22e00593          	li	a1,558
ffffffffc0202f5a:	00004517          	auipc	a0,0x4
ffffffffc0202f5e:	72e50513          	addi	a0,a0,1838 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0202f62:	d18fd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202f66:	86a2                	mv	a3,s0
ffffffffc0202f68:	00004617          	auipc	a2,0x4
ffffffffc0202f6c:	28060613          	addi	a2,a2,640 # ffffffffc02071e8 <commands+0x888>
ffffffffc0202f70:	22e00593          	li	a1,558
ffffffffc0202f74:	00004517          	auipc	a0,0x4
ffffffffc0202f78:	71450513          	addi	a0,a0,1812 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0202f7c:	cfefd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202f80:	854ff0ef          	jal	ra,ffffffffc0201fd4 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202f84:	00004617          	auipc	a2,0x4
ffffffffc0202f88:	6dc60613          	addi	a2,a2,1756 # ffffffffc0207660 <default_pmm_manager+0xa8>
ffffffffc0202f8c:	07f00593          	li	a1,127
ffffffffc0202f90:	00004517          	auipc	a0,0x4
ffffffffc0202f94:	6f850513          	addi	a0,a0,1784 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0202f98:	ce2fd0ef          	jal	ra,ffffffffc020047a <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202f9c:	00004617          	auipc	a2,0x4
ffffffffc0202fa0:	6c460613          	addi	a2,a2,1732 # ffffffffc0207660 <default_pmm_manager+0xa8>
ffffffffc0202fa4:	0c100593          	li	a1,193
ffffffffc0202fa8:	00004517          	auipc	a0,0x4
ffffffffc0202fac:	6e050513          	addi	a0,a0,1760 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0202fb0:	ccafd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202fb4:	00004697          	auipc	a3,0x4
ffffffffc0202fb8:	79468693          	addi	a3,a3,1940 # ffffffffc0207748 <default_pmm_manager+0x190>
ffffffffc0202fbc:	00004617          	auipc	a2,0x4
ffffffffc0202fc0:	df460613          	addi	a2,a2,-524 # ffffffffc0206db0 <commands+0x450>
ffffffffc0202fc4:	1f200593          	li	a1,498
ffffffffc0202fc8:	00004517          	auipc	a0,0x4
ffffffffc0202fcc:	6c050513          	addi	a0,a0,1728 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0202fd0:	caafd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202fd4:	00004697          	auipc	a3,0x4
ffffffffc0202fd8:	75468693          	addi	a3,a3,1876 # ffffffffc0207728 <default_pmm_manager+0x170>
ffffffffc0202fdc:	00004617          	auipc	a2,0x4
ffffffffc0202fe0:	dd460613          	addi	a2,a2,-556 # ffffffffc0206db0 <commands+0x450>
ffffffffc0202fe4:	1f100593          	li	a1,497
ffffffffc0202fe8:	00004517          	auipc	a0,0x4
ffffffffc0202fec:	6a050513          	addi	a0,a0,1696 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0202ff0:	c8afd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202ff4:	ffdfe0ef          	jal	ra,ffffffffc0201ff0 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202ff8:	00004697          	auipc	a3,0x4
ffffffffc0202ffc:	7e068693          	addi	a3,a3,2016 # ffffffffc02077d8 <default_pmm_manager+0x220>
ffffffffc0203000:	00004617          	auipc	a2,0x4
ffffffffc0203004:	db060613          	addi	a2,a2,-592 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203008:	1fa00593          	li	a1,506
ffffffffc020300c:	00004517          	auipc	a0,0x4
ffffffffc0203010:	67c50513          	addi	a0,a0,1660 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0203014:	c66fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203018:	00004697          	auipc	a3,0x4
ffffffffc020301c:	79068693          	addi	a3,a3,1936 # ffffffffc02077a8 <default_pmm_manager+0x1f0>
ffffffffc0203020:	00004617          	auipc	a2,0x4
ffffffffc0203024:	d9060613          	addi	a2,a2,-624 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203028:	1f700593          	li	a1,503
ffffffffc020302c:	00004517          	auipc	a0,0x4
ffffffffc0203030:	65c50513          	addi	a0,a0,1628 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0203034:	c46fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203038:	00004697          	auipc	a3,0x4
ffffffffc020303c:	74868693          	addi	a3,a3,1864 # ffffffffc0207780 <default_pmm_manager+0x1c8>
ffffffffc0203040:	00004617          	auipc	a2,0x4
ffffffffc0203044:	d7060613          	addi	a2,a2,-656 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203048:	1f300593          	li	a1,499
ffffffffc020304c:	00004517          	auipc	a0,0x4
ffffffffc0203050:	63c50513          	addi	a0,a0,1596 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0203054:	c26fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203058:	00005697          	auipc	a3,0x5
ffffffffc020305c:	80868693          	addi	a3,a3,-2040 # ffffffffc0207860 <default_pmm_manager+0x2a8>
ffffffffc0203060:	00004617          	auipc	a2,0x4
ffffffffc0203064:	d5060613          	addi	a2,a2,-688 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203068:	20300593          	li	a1,515
ffffffffc020306c:	00004517          	auipc	a0,0x4
ffffffffc0203070:	61c50513          	addi	a0,a0,1564 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0203074:	c06fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203078:	00005697          	auipc	a3,0x5
ffffffffc020307c:	88868693          	addi	a3,a3,-1912 # ffffffffc0207900 <default_pmm_manager+0x348>
ffffffffc0203080:	00004617          	auipc	a2,0x4
ffffffffc0203084:	d3060613          	addi	a2,a2,-720 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203088:	20800593          	li	a1,520
ffffffffc020308c:	00004517          	auipc	a0,0x4
ffffffffc0203090:	5fc50513          	addi	a0,a0,1532 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0203094:	be6fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203098:	00004697          	auipc	a3,0x4
ffffffffc020309c:	7a068693          	addi	a3,a3,1952 # ffffffffc0207838 <default_pmm_manager+0x280>
ffffffffc02030a0:	00004617          	auipc	a2,0x4
ffffffffc02030a4:	d1060613          	addi	a2,a2,-752 # ffffffffc0206db0 <commands+0x450>
ffffffffc02030a8:	20000593          	li	a1,512
ffffffffc02030ac:	00004517          	auipc	a0,0x4
ffffffffc02030b0:	5dc50513          	addi	a0,a0,1500 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc02030b4:	bc6fd0ef          	jal	ra,ffffffffc020047a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02030b8:	86d6                	mv	a3,s5
ffffffffc02030ba:	00004617          	auipc	a2,0x4
ffffffffc02030be:	12e60613          	addi	a2,a2,302 # ffffffffc02071e8 <commands+0x888>
ffffffffc02030c2:	1ff00593          	li	a1,511
ffffffffc02030c6:	00004517          	auipc	a0,0x4
ffffffffc02030ca:	5c250513          	addi	a0,a0,1474 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc02030ce:	bacfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02030d2:	00004697          	auipc	a3,0x4
ffffffffc02030d6:	7c668693          	addi	a3,a3,1990 # ffffffffc0207898 <default_pmm_manager+0x2e0>
ffffffffc02030da:	00004617          	auipc	a2,0x4
ffffffffc02030de:	cd660613          	addi	a2,a2,-810 # ffffffffc0206db0 <commands+0x450>
ffffffffc02030e2:	20d00593          	li	a1,525
ffffffffc02030e6:	00004517          	auipc	a0,0x4
ffffffffc02030ea:	5a250513          	addi	a0,a0,1442 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc02030ee:	b8cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02030f2:	00005697          	auipc	a3,0x5
ffffffffc02030f6:	86e68693          	addi	a3,a3,-1938 # ffffffffc0207960 <default_pmm_manager+0x3a8>
ffffffffc02030fa:	00004617          	auipc	a2,0x4
ffffffffc02030fe:	cb660613          	addi	a2,a2,-842 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203102:	20c00593          	li	a1,524
ffffffffc0203106:	00004517          	auipc	a0,0x4
ffffffffc020310a:	58250513          	addi	a0,a0,1410 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc020310e:	b6cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203112:	00005697          	auipc	a3,0x5
ffffffffc0203116:	83668693          	addi	a3,a3,-1994 # ffffffffc0207948 <default_pmm_manager+0x390>
ffffffffc020311a:	00004617          	auipc	a2,0x4
ffffffffc020311e:	c9660613          	addi	a2,a2,-874 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203122:	20b00593          	li	a1,523
ffffffffc0203126:	00004517          	auipc	a0,0x4
ffffffffc020312a:	56250513          	addi	a0,a0,1378 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc020312e:	b4cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203132:	00004697          	auipc	a3,0x4
ffffffffc0203136:	7e668693          	addi	a3,a3,2022 # ffffffffc0207918 <default_pmm_manager+0x360>
ffffffffc020313a:	00004617          	auipc	a2,0x4
ffffffffc020313e:	c7660613          	addi	a2,a2,-906 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203142:	20a00593          	li	a1,522
ffffffffc0203146:	00004517          	auipc	a0,0x4
ffffffffc020314a:	54250513          	addi	a0,a0,1346 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc020314e:	b2cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203152:	00005697          	auipc	a3,0x5
ffffffffc0203156:	97e68693          	addi	a3,a3,-1666 # ffffffffc0207ad0 <default_pmm_manager+0x518>
ffffffffc020315a:	00004617          	auipc	a2,0x4
ffffffffc020315e:	c5660613          	addi	a2,a2,-938 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203162:	23900593          	li	a1,569
ffffffffc0203166:	00004517          	auipc	a0,0x4
ffffffffc020316a:	52250513          	addi	a0,a0,1314 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc020316e:	b0cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203172:	00004697          	auipc	a3,0x4
ffffffffc0203176:	77668693          	addi	a3,a3,1910 # ffffffffc02078e8 <default_pmm_manager+0x330>
ffffffffc020317a:	00004617          	auipc	a2,0x4
ffffffffc020317e:	c3660613          	addi	a2,a2,-970 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203182:	20700593          	li	a1,519
ffffffffc0203186:	00004517          	auipc	a0,0x4
ffffffffc020318a:	50250513          	addi	a0,a0,1282 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc020318e:	aecfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203192:	00004697          	auipc	a3,0x4
ffffffffc0203196:	74668693          	addi	a3,a3,1862 # ffffffffc02078d8 <default_pmm_manager+0x320>
ffffffffc020319a:	00004617          	auipc	a2,0x4
ffffffffc020319e:	c1660613          	addi	a2,a2,-1002 # ffffffffc0206db0 <commands+0x450>
ffffffffc02031a2:	20600593          	li	a1,518
ffffffffc02031a6:	00004517          	auipc	a0,0x4
ffffffffc02031aa:	4e250513          	addi	a0,a0,1250 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc02031ae:	accfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02031b2:	00005697          	auipc	a3,0x5
ffffffffc02031b6:	81e68693          	addi	a3,a3,-2018 # ffffffffc02079d0 <default_pmm_manager+0x418>
ffffffffc02031ba:	00004617          	auipc	a2,0x4
ffffffffc02031be:	bf660613          	addi	a2,a2,-1034 # ffffffffc0206db0 <commands+0x450>
ffffffffc02031c2:	24a00593          	li	a1,586
ffffffffc02031c6:	00004517          	auipc	a0,0x4
ffffffffc02031ca:	4c250513          	addi	a0,a0,1218 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc02031ce:	aacfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*ptep & PTE_U);
ffffffffc02031d2:	00004697          	auipc	a3,0x4
ffffffffc02031d6:	6f668693          	addi	a3,a3,1782 # ffffffffc02078c8 <default_pmm_manager+0x310>
ffffffffc02031da:	00004617          	auipc	a2,0x4
ffffffffc02031de:	bd660613          	addi	a2,a2,-1066 # ffffffffc0206db0 <commands+0x450>
ffffffffc02031e2:	20500593          	li	a1,517
ffffffffc02031e6:	00004517          	auipc	a0,0x4
ffffffffc02031ea:	4a250513          	addi	a0,a0,1186 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc02031ee:	a8cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02031f2:	00004697          	auipc	a3,0x4
ffffffffc02031f6:	62e68693          	addi	a3,a3,1582 # ffffffffc0207820 <default_pmm_manager+0x268>
ffffffffc02031fa:	00004617          	auipc	a2,0x4
ffffffffc02031fe:	bb660613          	addi	a2,a2,-1098 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203202:	21200593          	li	a1,530
ffffffffc0203206:	00004517          	auipc	a0,0x4
ffffffffc020320a:	48250513          	addi	a0,a0,1154 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc020320e:	a6cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203212:	00004697          	auipc	a3,0x4
ffffffffc0203216:	76668693          	addi	a3,a3,1894 # ffffffffc0207978 <default_pmm_manager+0x3c0>
ffffffffc020321a:	00004617          	auipc	a2,0x4
ffffffffc020321e:	b9660613          	addi	a2,a2,-1130 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203222:	20f00593          	li	a1,527
ffffffffc0203226:	00004517          	auipc	a0,0x4
ffffffffc020322a:	46250513          	addi	a0,a0,1122 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc020322e:	a4cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203232:	00004697          	auipc	a3,0x4
ffffffffc0203236:	5d668693          	addi	a3,a3,1494 # ffffffffc0207808 <default_pmm_manager+0x250>
ffffffffc020323a:	00004617          	auipc	a2,0x4
ffffffffc020323e:	b7660613          	addi	a2,a2,-1162 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203242:	20e00593          	li	a1,526
ffffffffc0203246:	00004517          	auipc	a0,0x4
ffffffffc020324a:	44250513          	addi	a0,a0,1090 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc020324e:	a2cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0203252:	00004617          	auipc	a2,0x4
ffffffffc0203256:	f9660613          	addi	a2,a2,-106 # ffffffffc02071e8 <commands+0x888>
ffffffffc020325a:	06900593          	li	a1,105
ffffffffc020325e:	00004517          	auipc	a0,0x4
ffffffffc0203262:	ef250513          	addi	a0,a0,-270 # ffffffffc0207150 <commands+0x7f0>
ffffffffc0203266:	a14fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020326a:	00004697          	auipc	a3,0x4
ffffffffc020326e:	73e68693          	addi	a3,a3,1854 # ffffffffc02079a8 <default_pmm_manager+0x3f0>
ffffffffc0203272:	00004617          	auipc	a2,0x4
ffffffffc0203276:	b3e60613          	addi	a2,a2,-1218 # ffffffffc0206db0 <commands+0x450>
ffffffffc020327a:	21900593          	li	a1,537
ffffffffc020327e:	00004517          	auipc	a0,0x4
ffffffffc0203282:	40a50513          	addi	a0,a0,1034 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0203286:	9f4fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020328a:	00004697          	auipc	a3,0x4
ffffffffc020328e:	6d668693          	addi	a3,a3,1750 # ffffffffc0207960 <default_pmm_manager+0x3a8>
ffffffffc0203292:	00004617          	auipc	a2,0x4
ffffffffc0203296:	b1e60613          	addi	a2,a2,-1250 # ffffffffc0206db0 <commands+0x450>
ffffffffc020329a:	21700593          	li	a1,535
ffffffffc020329e:	00004517          	auipc	a0,0x4
ffffffffc02032a2:	3ea50513          	addi	a0,a0,1002 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc02032a6:	9d4fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02032aa:	00004697          	auipc	a3,0x4
ffffffffc02032ae:	6e668693          	addi	a3,a3,1766 # ffffffffc0207990 <default_pmm_manager+0x3d8>
ffffffffc02032b2:	00004617          	auipc	a2,0x4
ffffffffc02032b6:	afe60613          	addi	a2,a2,-1282 # ffffffffc0206db0 <commands+0x450>
ffffffffc02032ba:	21600593          	li	a1,534
ffffffffc02032be:	00004517          	auipc	a0,0x4
ffffffffc02032c2:	3ca50513          	addi	a0,a0,970 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc02032c6:	9b4fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02032ca:	00004697          	auipc	a3,0x4
ffffffffc02032ce:	69668693          	addi	a3,a3,1686 # ffffffffc0207960 <default_pmm_manager+0x3a8>
ffffffffc02032d2:	00004617          	auipc	a2,0x4
ffffffffc02032d6:	ade60613          	addi	a2,a2,-1314 # ffffffffc0206db0 <commands+0x450>
ffffffffc02032da:	21300593          	li	a1,531
ffffffffc02032de:	00004517          	auipc	a0,0x4
ffffffffc02032e2:	3aa50513          	addi	a0,a0,938 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc02032e6:	994fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p) == 1);
ffffffffc02032ea:	00004697          	auipc	a3,0x4
ffffffffc02032ee:	7ce68693          	addi	a3,a3,1998 # ffffffffc0207ab8 <default_pmm_manager+0x500>
ffffffffc02032f2:	00004617          	auipc	a2,0x4
ffffffffc02032f6:	abe60613          	addi	a2,a2,-1346 # ffffffffc0206db0 <commands+0x450>
ffffffffc02032fa:	23800593          	li	a1,568
ffffffffc02032fe:	00004517          	auipc	a0,0x4
ffffffffc0203302:	38a50513          	addi	a0,a0,906 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0203306:	974fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020330a:	00004697          	auipc	a3,0x4
ffffffffc020330e:	77668693          	addi	a3,a3,1910 # ffffffffc0207a80 <default_pmm_manager+0x4c8>
ffffffffc0203312:	00004617          	auipc	a2,0x4
ffffffffc0203316:	a9e60613          	addi	a2,a2,-1378 # ffffffffc0206db0 <commands+0x450>
ffffffffc020331a:	23700593          	li	a1,567
ffffffffc020331e:	00004517          	auipc	a0,0x4
ffffffffc0203322:	36a50513          	addi	a0,a0,874 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0203326:	954fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc020332a:	00004697          	auipc	a3,0x4
ffffffffc020332e:	73e68693          	addi	a3,a3,1854 # ffffffffc0207a68 <default_pmm_manager+0x4b0>
ffffffffc0203332:	00004617          	auipc	a2,0x4
ffffffffc0203336:	a7e60613          	addi	a2,a2,-1410 # ffffffffc0206db0 <commands+0x450>
ffffffffc020333a:	23300593          	li	a1,563
ffffffffc020333e:	00004517          	auipc	a0,0x4
ffffffffc0203342:	34a50513          	addi	a0,a0,842 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0203346:	934fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020334a:	00004697          	auipc	a3,0x4
ffffffffc020334e:	68668693          	addi	a3,a3,1670 # ffffffffc02079d0 <default_pmm_manager+0x418>
ffffffffc0203352:	00004617          	auipc	a2,0x4
ffffffffc0203356:	a5e60613          	addi	a2,a2,-1442 # ffffffffc0206db0 <commands+0x450>
ffffffffc020335a:	22100593          	li	a1,545
ffffffffc020335e:	00004517          	auipc	a0,0x4
ffffffffc0203362:	32a50513          	addi	a0,a0,810 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0203366:	914fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020336a:	00004697          	auipc	a3,0x4
ffffffffc020336e:	49e68693          	addi	a3,a3,1182 # ffffffffc0207808 <default_pmm_manager+0x250>
ffffffffc0203372:	00004617          	auipc	a2,0x4
ffffffffc0203376:	a3e60613          	addi	a2,a2,-1474 # ffffffffc0206db0 <commands+0x450>
ffffffffc020337a:	1fb00593          	li	a1,507
ffffffffc020337e:	00004517          	auipc	a0,0x4
ffffffffc0203382:	30a50513          	addi	a0,a0,778 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc0203386:	8f4fd0ef          	jal	ra,ffffffffc020047a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020338a:	00004617          	auipc	a2,0x4
ffffffffc020338e:	e5e60613          	addi	a2,a2,-418 # ffffffffc02071e8 <commands+0x888>
ffffffffc0203392:	1fe00593          	li	a1,510
ffffffffc0203396:	00004517          	auipc	a0,0x4
ffffffffc020339a:	2f250513          	addi	a0,a0,754 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc020339e:	8dcfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02033a2:	00004697          	auipc	a3,0x4
ffffffffc02033a6:	47e68693          	addi	a3,a3,1150 # ffffffffc0207820 <default_pmm_manager+0x268>
ffffffffc02033aa:	00004617          	auipc	a2,0x4
ffffffffc02033ae:	a0660613          	addi	a2,a2,-1530 # ffffffffc0206db0 <commands+0x450>
ffffffffc02033b2:	1fc00593          	li	a1,508
ffffffffc02033b6:	00004517          	auipc	a0,0x4
ffffffffc02033ba:	2d250513          	addi	a0,a0,722 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc02033be:	8bcfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02033c2:	00004697          	auipc	a3,0x4
ffffffffc02033c6:	4d668693          	addi	a3,a3,1238 # ffffffffc0207898 <default_pmm_manager+0x2e0>
ffffffffc02033ca:	00004617          	auipc	a2,0x4
ffffffffc02033ce:	9e660613          	addi	a2,a2,-1562 # ffffffffc0206db0 <commands+0x450>
ffffffffc02033d2:	20400593          	li	a1,516
ffffffffc02033d6:	00004517          	auipc	a0,0x4
ffffffffc02033da:	2b250513          	addi	a0,a0,690 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc02033de:	89cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02033e2:	00004697          	auipc	a3,0x4
ffffffffc02033e6:	79668693          	addi	a3,a3,1942 # ffffffffc0207b78 <default_pmm_manager+0x5c0>
ffffffffc02033ea:	00004617          	auipc	a2,0x4
ffffffffc02033ee:	9c660613          	addi	a2,a2,-1594 # ffffffffc0206db0 <commands+0x450>
ffffffffc02033f2:	24100593          	li	a1,577
ffffffffc02033f6:	00004517          	auipc	a0,0x4
ffffffffc02033fa:	29250513          	addi	a0,a0,658 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc02033fe:	87cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203402:	00004697          	auipc	a3,0x4
ffffffffc0203406:	73e68693          	addi	a3,a3,1854 # ffffffffc0207b40 <default_pmm_manager+0x588>
ffffffffc020340a:	00004617          	auipc	a2,0x4
ffffffffc020340e:	9a660613          	addi	a2,a2,-1626 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203412:	23e00593          	li	a1,574
ffffffffc0203416:	00004517          	auipc	a0,0x4
ffffffffc020341a:	27250513          	addi	a0,a0,626 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc020341e:	85cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203422:	00004697          	auipc	a3,0x4
ffffffffc0203426:	6ee68693          	addi	a3,a3,1774 # ffffffffc0207b10 <default_pmm_manager+0x558>
ffffffffc020342a:	00004617          	auipc	a2,0x4
ffffffffc020342e:	98660613          	addi	a2,a2,-1658 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203432:	23a00593          	li	a1,570
ffffffffc0203436:	00004517          	auipc	a0,0x4
ffffffffc020343a:	25250513          	addi	a0,a0,594 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc020343e:	83cfd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203442 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203442:	12058073          	sfence.vma	a1
}
ffffffffc0203446:	8082                	ret

ffffffffc0203448 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203448:	7179                	addi	sp,sp,-48
ffffffffc020344a:	e84a                	sd	s2,16(sp)
ffffffffc020344c:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020344e:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203450:	f022                	sd	s0,32(sp)
ffffffffc0203452:	ec26                	sd	s1,24(sp)
ffffffffc0203454:	e44e                	sd	s3,8(sp)
ffffffffc0203456:	f406                	sd	ra,40(sp)
ffffffffc0203458:	84ae                	mv	s1,a1
ffffffffc020345a:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020345c:	bb1fe0ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc0203460:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203462:	cd05                	beqz	a0,ffffffffc020349a <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203464:	85aa                	mv	a1,a0
ffffffffc0203466:	86ce                	mv	a3,s3
ffffffffc0203468:	8626                	mv	a2,s1
ffffffffc020346a:	854a                	mv	a0,s2
ffffffffc020346c:	b46ff0ef          	jal	ra,ffffffffc02027b2 <page_insert>
ffffffffc0203470:	ed0d                	bnez	a0,ffffffffc02034aa <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc0203472:	000af797          	auipc	a5,0xaf
ffffffffc0203476:	3fe7a783          	lw	a5,1022(a5) # ffffffffc02b2870 <swap_init_ok>
ffffffffc020347a:	c385                	beqz	a5,ffffffffc020349a <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc020347c:	000af517          	auipc	a0,0xaf
ffffffffc0203480:	3fc53503          	ld	a0,1020(a0) # ffffffffc02b2878 <check_mm_struct>
ffffffffc0203484:	c919                	beqz	a0,ffffffffc020349a <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203486:	4681                	li	a3,0
ffffffffc0203488:	8622                	mv	a2,s0
ffffffffc020348a:	85a6                	mv	a1,s1
ffffffffc020348c:	7e4000ef          	jal	ra,ffffffffc0203c70 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0203490:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0203492:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0203494:	4785                	li	a5,1
ffffffffc0203496:	04f71663          	bne	a4,a5,ffffffffc02034e2 <pgdir_alloc_page+0x9a>
}
ffffffffc020349a:	70a2                	ld	ra,40(sp)
ffffffffc020349c:	8522                	mv	a0,s0
ffffffffc020349e:	7402                	ld	s0,32(sp)
ffffffffc02034a0:	64e2                	ld	s1,24(sp)
ffffffffc02034a2:	6942                	ld	s2,16(sp)
ffffffffc02034a4:	69a2                	ld	s3,8(sp)
ffffffffc02034a6:	6145                	addi	sp,sp,48
ffffffffc02034a8:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02034aa:	100027f3          	csrr	a5,sstatus
ffffffffc02034ae:	8b89                	andi	a5,a5,2
ffffffffc02034b0:	eb99                	bnez	a5,ffffffffc02034c6 <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc02034b2:	000af797          	auipc	a5,0xaf
ffffffffc02034b6:	39e7b783          	ld	a5,926(a5) # ffffffffc02b2850 <pmm_manager>
ffffffffc02034ba:	739c                	ld	a5,32(a5)
ffffffffc02034bc:	8522                	mv	a0,s0
ffffffffc02034be:	4585                	li	a1,1
ffffffffc02034c0:	9782                	jalr	a5
            return NULL;
ffffffffc02034c2:	4401                	li	s0,0
ffffffffc02034c4:	bfd9                	j	ffffffffc020349a <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc02034c6:	980fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02034ca:	000af797          	auipc	a5,0xaf
ffffffffc02034ce:	3867b783          	ld	a5,902(a5) # ffffffffc02b2850 <pmm_manager>
ffffffffc02034d2:	739c                	ld	a5,32(a5)
ffffffffc02034d4:	8522                	mv	a0,s0
ffffffffc02034d6:	4585                	li	a1,1
ffffffffc02034d8:	9782                	jalr	a5
            return NULL;
ffffffffc02034da:	4401                	li	s0,0
        intr_enable();
ffffffffc02034dc:	964fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc02034e0:	bf6d                	j	ffffffffc020349a <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc02034e2:	00004697          	auipc	a3,0x4
ffffffffc02034e6:	6de68693          	addi	a3,a3,1758 # ffffffffc0207bc0 <default_pmm_manager+0x608>
ffffffffc02034ea:	00004617          	auipc	a2,0x4
ffffffffc02034ee:	8c660613          	addi	a2,a2,-1850 # ffffffffc0206db0 <commands+0x450>
ffffffffc02034f2:	1d200593          	li	a1,466
ffffffffc02034f6:	00004517          	auipc	a0,0x4
ffffffffc02034fa:	19250513          	addi	a0,a0,402 # ffffffffc0207688 <default_pmm_manager+0xd0>
ffffffffc02034fe:	f7dfc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203502 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0203502:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0203504:	00004617          	auipc	a2,0x4
ffffffffc0203508:	c5c60613          	addi	a2,a2,-932 # ffffffffc0207160 <commands+0x800>
ffffffffc020350c:	06200593          	li	a1,98
ffffffffc0203510:	00004517          	auipc	a0,0x4
ffffffffc0203514:	c4050513          	addi	a0,a0,-960 # ffffffffc0207150 <commands+0x7f0>
pa2page(uintptr_t pa) {
ffffffffc0203518:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020351a:	f61fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020351e <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020351e:	7135                	addi	sp,sp,-160
ffffffffc0203520:	ed06                	sd	ra,152(sp)
ffffffffc0203522:	e922                	sd	s0,144(sp)
ffffffffc0203524:	e526                	sd	s1,136(sp)
ffffffffc0203526:	e14a                	sd	s2,128(sp)
ffffffffc0203528:	fcce                	sd	s3,120(sp)
ffffffffc020352a:	f8d2                	sd	s4,112(sp)
ffffffffc020352c:	f4d6                	sd	s5,104(sp)
ffffffffc020352e:	f0da                	sd	s6,96(sp)
ffffffffc0203530:	ecde                	sd	s7,88(sp)
ffffffffc0203532:	e8e2                	sd	s8,80(sp)
ffffffffc0203534:	e4e6                	sd	s9,72(sp)
ffffffffc0203536:	e0ea                	sd	s10,64(sp)
ffffffffc0203538:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc020353a:	75c010ef          	jal	ra,ffffffffc0204c96 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020353e:	000af697          	auipc	a3,0xaf
ffffffffc0203542:	3226b683          	ld	a3,802(a3) # ffffffffc02b2860 <max_swap_offset>
ffffffffc0203546:	010007b7          	lui	a5,0x1000
ffffffffc020354a:	ff968713          	addi	a4,a3,-7
ffffffffc020354e:	17e1                	addi	a5,a5,-8
ffffffffc0203550:	42e7e663          	bltu	a5,a4,ffffffffc020397c <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0203554:	000a4797          	auipc	a5,0xa4
ffffffffc0203558:	da478793          	addi	a5,a5,-604 # ffffffffc02a72f8 <swap_manager_fifo>
     int r = sm->init();
ffffffffc020355c:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc020355e:	000afb97          	auipc	s7,0xaf
ffffffffc0203562:	30ab8b93          	addi	s7,s7,778 # ffffffffc02b2868 <sm>
ffffffffc0203566:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc020356a:	9702                	jalr	a4
ffffffffc020356c:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc020356e:	c10d                	beqz	a0,ffffffffc0203590 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0203570:	60ea                	ld	ra,152(sp)
ffffffffc0203572:	644a                	ld	s0,144(sp)
ffffffffc0203574:	64aa                	ld	s1,136(sp)
ffffffffc0203576:	79e6                	ld	s3,120(sp)
ffffffffc0203578:	7a46                	ld	s4,112(sp)
ffffffffc020357a:	7aa6                	ld	s5,104(sp)
ffffffffc020357c:	7b06                	ld	s6,96(sp)
ffffffffc020357e:	6be6                	ld	s7,88(sp)
ffffffffc0203580:	6c46                	ld	s8,80(sp)
ffffffffc0203582:	6ca6                	ld	s9,72(sp)
ffffffffc0203584:	6d06                	ld	s10,64(sp)
ffffffffc0203586:	7de2                	ld	s11,56(sp)
ffffffffc0203588:	854a                	mv	a0,s2
ffffffffc020358a:	690a                	ld	s2,128(sp)
ffffffffc020358c:	610d                	addi	sp,sp,160
ffffffffc020358e:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203590:	000bb783          	ld	a5,0(s7)
ffffffffc0203594:	00004517          	auipc	a0,0x4
ffffffffc0203598:	67450513          	addi	a0,a0,1652 # ffffffffc0207c08 <default_pmm_manager+0x650>
    return listelm->next;
ffffffffc020359c:	000ab417          	auipc	s0,0xab
ffffffffc02035a0:	1ac40413          	addi	s0,s0,428 # ffffffffc02ae748 <free_area>
ffffffffc02035a4:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02035a6:	4785                	li	a5,1
ffffffffc02035a8:	000af717          	auipc	a4,0xaf
ffffffffc02035ac:	2cf72423          	sw	a5,712(a4) # ffffffffc02b2870 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02035b0:	bd1fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02035b4:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02035b6:	4d01                	li	s10,0
ffffffffc02035b8:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02035ba:	34878163          	beq	a5,s0,ffffffffc02038fc <swap_init+0x3de>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02035be:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02035c2:	8b09                	andi	a4,a4,2
ffffffffc02035c4:	32070e63          	beqz	a4,ffffffffc0203900 <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc02035c8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02035cc:	679c                	ld	a5,8(a5)
ffffffffc02035ce:	2d85                	addiw	s11,s11,1
ffffffffc02035d0:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc02035d4:	fe8795e3          	bne	a5,s0,ffffffffc02035be <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc02035d8:	84ea                	mv	s1,s10
ffffffffc02035da:	b05fe0ef          	jal	ra,ffffffffc02020de <nr_free_pages>
ffffffffc02035de:	42951763          	bne	a0,s1,ffffffffc0203a0c <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02035e2:	866a                	mv	a2,s10
ffffffffc02035e4:	85ee                	mv	a1,s11
ffffffffc02035e6:	00004517          	auipc	a0,0x4
ffffffffc02035ea:	63a50513          	addi	a0,a0,1594 # ffffffffc0207c20 <default_pmm_manager+0x668>
ffffffffc02035ee:	b93fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02035f2:	42b000ef          	jal	ra,ffffffffc020421c <mm_create>
ffffffffc02035f6:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc02035f8:	46050a63          	beqz	a0,ffffffffc0203a6c <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02035fc:	000af797          	auipc	a5,0xaf
ffffffffc0203600:	27c78793          	addi	a5,a5,636 # ffffffffc02b2878 <check_mm_struct>
ffffffffc0203604:	6398                	ld	a4,0(a5)
ffffffffc0203606:	3e071363          	bnez	a4,ffffffffc02039ec <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020360a:	000af717          	auipc	a4,0xaf
ffffffffc020360e:	22e70713          	addi	a4,a4,558 # ffffffffc02b2838 <boot_pgdir>
ffffffffc0203612:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc0203616:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0203618:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020361c:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0203620:	42079663          	bnez	a5,ffffffffc0203a4c <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0203624:	6599                	lui	a1,0x6
ffffffffc0203626:	460d                	li	a2,3
ffffffffc0203628:	6505                	lui	a0,0x1
ffffffffc020362a:	43b000ef          	jal	ra,ffffffffc0204264 <vma_create>
ffffffffc020362e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0203630:	52050a63          	beqz	a0,ffffffffc0203b64 <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc0203634:	8556                	mv	a0,s5
ffffffffc0203636:	49d000ef          	jal	ra,ffffffffc02042d2 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020363a:	00004517          	auipc	a0,0x4
ffffffffc020363e:	65650513          	addi	a0,a0,1622 # ffffffffc0207c90 <default_pmm_manager+0x6d8>
ffffffffc0203642:	b3ffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0203646:	018ab503          	ld	a0,24(s5)
ffffffffc020364a:	4605                	li	a2,1
ffffffffc020364c:	6585                	lui	a1,0x1
ffffffffc020364e:	acbfe0ef          	jal	ra,ffffffffc0202118 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0203652:	4c050963          	beqz	a0,ffffffffc0203b24 <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203656:	00004517          	auipc	a0,0x4
ffffffffc020365a:	68a50513          	addi	a0,a0,1674 # ffffffffc0207ce0 <default_pmm_manager+0x728>
ffffffffc020365e:	000ab497          	auipc	s1,0xab
ffffffffc0203662:	12248493          	addi	s1,s1,290 # ffffffffc02ae780 <check_rp>
ffffffffc0203666:	b1bfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020366a:	000ab997          	auipc	s3,0xab
ffffffffc020366e:	13698993          	addi	s3,s3,310 # ffffffffc02ae7a0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203672:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0203674:	4505                	li	a0,1
ffffffffc0203676:	997fe0ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc020367a:	00aa3023          	sd	a0,0(s4)
          assert(check_rp[i] != NULL );
ffffffffc020367e:	2c050f63          	beqz	a0,ffffffffc020395c <swap_init+0x43e>
ffffffffc0203682:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0203684:	8b89                	andi	a5,a5,2
ffffffffc0203686:	34079363          	bnez	a5,ffffffffc02039cc <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020368a:	0a21                	addi	s4,s4,8
ffffffffc020368c:	ff3a14e3          	bne	s4,s3,ffffffffc0203674 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203690:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203692:	000aba17          	auipc	s4,0xab
ffffffffc0203696:	0eea0a13          	addi	s4,s4,238 # ffffffffc02ae780 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc020369a:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc020369c:	ec3e                	sd	a5,24(sp)
ffffffffc020369e:	641c                	ld	a5,8(s0)
ffffffffc02036a0:	e400                	sd	s0,8(s0)
ffffffffc02036a2:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02036a4:	481c                	lw	a5,16(s0)
ffffffffc02036a6:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc02036a8:	000ab797          	auipc	a5,0xab
ffffffffc02036ac:	0a07a823          	sw	zero,176(a5) # ffffffffc02ae758 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02036b0:	000a3503          	ld	a0,0(s4)
ffffffffc02036b4:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02036b6:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc02036b8:	9e7fe0ef          	jal	ra,ffffffffc020209e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02036bc:	ff3a1ae3          	bne	s4,s3,ffffffffc02036b0 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02036c0:	01042a03          	lw	s4,16(s0)
ffffffffc02036c4:	4791                	li	a5,4
ffffffffc02036c6:	42fa1f63          	bne	s4,a5,ffffffffc0203b04 <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02036ca:	00004517          	auipc	a0,0x4
ffffffffc02036ce:	69e50513          	addi	a0,a0,1694 # ffffffffc0207d68 <default_pmm_manager+0x7b0>
ffffffffc02036d2:	aaffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02036d6:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02036d8:	000af797          	auipc	a5,0xaf
ffffffffc02036dc:	1a07a423          	sw	zero,424(a5) # ffffffffc02b2880 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02036e0:	4629                	li	a2,10
ffffffffc02036e2:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
     assert(pgfault_num==1);
ffffffffc02036e6:	000af697          	auipc	a3,0xaf
ffffffffc02036ea:	19a6a683          	lw	a3,410(a3) # ffffffffc02b2880 <pgfault_num>
ffffffffc02036ee:	4585                	li	a1,1
ffffffffc02036f0:	000af797          	auipc	a5,0xaf
ffffffffc02036f4:	19078793          	addi	a5,a5,400 # ffffffffc02b2880 <pgfault_num>
ffffffffc02036f8:	54b69663          	bne	a3,a1,ffffffffc0203c44 <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02036fc:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0203700:	4398                	lw	a4,0(a5)
ffffffffc0203702:	2701                	sext.w	a4,a4
ffffffffc0203704:	3ed71063          	bne	a4,a3,ffffffffc0203ae4 <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203708:	6689                	lui	a3,0x2
ffffffffc020370a:	462d                	li	a2,11
ffffffffc020370c:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7bb0>
     assert(pgfault_num==2);
ffffffffc0203710:	4398                	lw	a4,0(a5)
ffffffffc0203712:	4589                	li	a1,2
ffffffffc0203714:	2701                	sext.w	a4,a4
ffffffffc0203716:	4ab71763          	bne	a4,a1,ffffffffc0203bc4 <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc020371a:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc020371e:	4394                	lw	a3,0(a5)
ffffffffc0203720:	2681                	sext.w	a3,a3
ffffffffc0203722:	4ce69163          	bne	a3,a4,ffffffffc0203be4 <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203726:	668d                	lui	a3,0x3
ffffffffc0203728:	4631                	li	a2,12
ffffffffc020372a:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb0>
     assert(pgfault_num==3);
ffffffffc020372e:	4398                	lw	a4,0(a5)
ffffffffc0203730:	458d                	li	a1,3
ffffffffc0203732:	2701                	sext.w	a4,a4
ffffffffc0203734:	4cb71863          	bne	a4,a1,ffffffffc0203c04 <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0203738:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc020373c:	4394                	lw	a3,0(a5)
ffffffffc020373e:	2681                	sext.w	a3,a3
ffffffffc0203740:	4ee69263          	bne	a3,a4,ffffffffc0203c24 <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203744:	6691                	lui	a3,0x4
ffffffffc0203746:	4635                	li	a2,13
ffffffffc0203748:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5bb0>
     assert(pgfault_num==4);
ffffffffc020374c:	4398                	lw	a4,0(a5)
ffffffffc020374e:	2701                	sext.w	a4,a4
ffffffffc0203750:	43471a63          	bne	a4,s4,ffffffffc0203b84 <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0203754:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0203758:	439c                	lw	a5,0(a5)
ffffffffc020375a:	2781                	sext.w	a5,a5
ffffffffc020375c:	44e79463          	bne	a5,a4,ffffffffc0203ba4 <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0203760:	481c                	lw	a5,16(s0)
ffffffffc0203762:	2c079563          	bnez	a5,ffffffffc0203a2c <swap_init+0x50e>
ffffffffc0203766:	000ab797          	auipc	a5,0xab
ffffffffc020376a:	03a78793          	addi	a5,a5,58 # ffffffffc02ae7a0 <swap_in_seq_no>
ffffffffc020376e:	000ab717          	auipc	a4,0xab
ffffffffc0203772:	05a70713          	addi	a4,a4,90 # ffffffffc02ae7c8 <swap_out_seq_no>
ffffffffc0203776:	000ab617          	auipc	a2,0xab
ffffffffc020377a:	05260613          	addi	a2,a2,82 # ffffffffc02ae7c8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc020377e:	56fd                	li	a3,-1
ffffffffc0203780:	c394                	sw	a3,0(a5)
ffffffffc0203782:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203784:	0791                	addi	a5,a5,4
ffffffffc0203786:	0711                	addi	a4,a4,4
ffffffffc0203788:	fec79ce3          	bne	a5,a2,ffffffffc0203780 <swap_init+0x262>
ffffffffc020378c:	000ab717          	auipc	a4,0xab
ffffffffc0203790:	fd470713          	addi	a4,a4,-44 # ffffffffc02ae760 <check_ptep>
ffffffffc0203794:	000ab697          	auipc	a3,0xab
ffffffffc0203798:	fec68693          	addi	a3,a3,-20 # ffffffffc02ae780 <check_rp>
ffffffffc020379c:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc020379e:	000afc17          	auipc	s8,0xaf
ffffffffc02037a2:	0a2c0c13          	addi	s8,s8,162 # ffffffffc02b2840 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02037a6:	000afc97          	auipc	s9,0xaf
ffffffffc02037aa:	0a2c8c93          	addi	s9,s9,162 # ffffffffc02b2848 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc02037ae:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02037b2:	4601                	li	a2,0
ffffffffc02037b4:	855a                	mv	a0,s6
ffffffffc02037b6:	e836                	sd	a3,16(sp)
ffffffffc02037b8:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc02037ba:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02037bc:	95dfe0ef          	jal	ra,ffffffffc0202118 <get_pte>
ffffffffc02037c0:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02037c2:	65a2                	ld	a1,8(sp)
ffffffffc02037c4:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02037c6:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc02037c8:	1c050663          	beqz	a0,ffffffffc0203994 <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02037cc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02037ce:	0017f613          	andi	a2,a5,1
ffffffffc02037d2:	1e060163          	beqz	a2,ffffffffc02039b4 <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc02037d6:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc02037da:	078a                	slli	a5,a5,0x2
ffffffffc02037dc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037de:	14c7f363          	bgeu	a5,a2,ffffffffc0203924 <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc02037e2:	00005617          	auipc	a2,0x5
ffffffffc02037e6:	66660613          	addi	a2,a2,1638 # ffffffffc0208e48 <nbase>
ffffffffc02037ea:	00063a03          	ld	s4,0(a2)
ffffffffc02037ee:	000cb603          	ld	a2,0(s9)
ffffffffc02037f2:	6288                	ld	a0,0(a3)
ffffffffc02037f4:	414787b3          	sub	a5,a5,s4
ffffffffc02037f8:	079a                	slli	a5,a5,0x6
ffffffffc02037fa:	97b2                	add	a5,a5,a2
ffffffffc02037fc:	14f51063          	bne	a0,a5,ffffffffc020393c <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203800:	6785                	lui	a5,0x1
ffffffffc0203802:	95be                	add	a1,a1,a5
ffffffffc0203804:	6795                	lui	a5,0x5
ffffffffc0203806:	0721                	addi	a4,a4,8
ffffffffc0203808:	06a1                	addi	a3,a3,8
ffffffffc020380a:	faf592e3          	bne	a1,a5,ffffffffc02037ae <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020380e:	00004517          	auipc	a0,0x4
ffffffffc0203812:	60250513          	addi	a0,a0,1538 # ffffffffc0207e10 <default_pmm_manager+0x858>
ffffffffc0203816:	96bfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = sm->check_swap();
ffffffffc020381a:	000bb783          	ld	a5,0(s7)
ffffffffc020381e:	7f9c                	ld	a5,56(a5)
ffffffffc0203820:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203822:	32051163          	bnez	a0,ffffffffc0203b44 <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc0203826:	77a2                	ld	a5,40(sp)
ffffffffc0203828:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc020382a:	67e2                	ld	a5,24(sp)
ffffffffc020382c:	e01c                	sd	a5,0(s0)
ffffffffc020382e:	7782                	ld	a5,32(sp)
ffffffffc0203830:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0203832:	6088                	ld	a0,0(s1)
ffffffffc0203834:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203836:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0203838:	867fe0ef          	jal	ra,ffffffffc020209e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020383c:	ff349be3          	bne	s1,s3,ffffffffc0203832 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0203840:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc0203844:	8556                	mv	a0,s5
ffffffffc0203846:	35d000ef          	jal	ra,ffffffffc02043a2 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020384a:	000af797          	auipc	a5,0xaf
ffffffffc020384e:	fee78793          	addi	a5,a5,-18 # ffffffffc02b2838 <boot_pgdir>
ffffffffc0203852:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203854:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc0203858:	000af697          	auipc	a3,0xaf
ffffffffc020385c:	0206b023          	sd	zero,32(a3) # ffffffffc02b2878 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203860:	639c                	ld	a5,0(a5)
ffffffffc0203862:	078a                	slli	a5,a5,0x2
ffffffffc0203864:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203866:	0ae7fd63          	bgeu	a5,a4,ffffffffc0203920 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc020386a:	414786b3          	sub	a3,a5,s4
ffffffffc020386e:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203870:	8699                	srai	a3,a3,0x6
ffffffffc0203872:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0203874:	00c69793          	slli	a5,a3,0xc
ffffffffc0203878:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc020387a:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc020387e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203880:	22e7f663          	bgeu	a5,a4,ffffffffc0203aac <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc0203884:	000af797          	auipc	a5,0xaf
ffffffffc0203888:	fd47b783          	ld	a5,-44(a5) # ffffffffc02b2858 <va_pa_offset>
ffffffffc020388c:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020388e:	629c                	ld	a5,0(a3)
ffffffffc0203890:	078a                	slli	a5,a5,0x2
ffffffffc0203892:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203894:	08e7f663          	bgeu	a5,a4,ffffffffc0203920 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203898:	414787b3          	sub	a5,a5,s4
ffffffffc020389c:	079a                	slli	a5,a5,0x6
ffffffffc020389e:	953e                	add	a0,a0,a5
ffffffffc02038a0:	4585                	li	a1,1
ffffffffc02038a2:	ffcfe0ef          	jal	ra,ffffffffc020209e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02038a6:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc02038aa:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc02038ae:	078a                	slli	a5,a5,0x2
ffffffffc02038b0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02038b2:	06e7f763          	bgeu	a5,a4,ffffffffc0203920 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc02038b6:	000cb503          	ld	a0,0(s9)
ffffffffc02038ba:	414787b3          	sub	a5,a5,s4
ffffffffc02038be:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc02038c0:	4585                	li	a1,1
ffffffffc02038c2:	953e                	add	a0,a0,a5
ffffffffc02038c4:	fdafe0ef          	jal	ra,ffffffffc020209e <free_pages>
     pgdir[0] = 0;
ffffffffc02038c8:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc02038cc:	12000073          	sfence.vma
    return listelm->next;
ffffffffc02038d0:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02038d2:	00878a63          	beq	a5,s0,ffffffffc02038e6 <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc02038d6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02038da:	679c                	ld	a5,8(a5)
ffffffffc02038dc:	3dfd                	addiw	s11,s11,-1
ffffffffc02038de:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02038e2:	fe879ae3          	bne	a5,s0,ffffffffc02038d6 <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc02038e6:	1c0d9f63          	bnez	s11,ffffffffc0203ac4 <swap_init+0x5a6>
     assert(total==0);
ffffffffc02038ea:	1a0d1163          	bnez	s10,ffffffffc0203a8c <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc02038ee:	00004517          	auipc	a0,0x4
ffffffffc02038f2:	57250513          	addi	a0,a0,1394 # ffffffffc0207e60 <default_pmm_manager+0x8a8>
ffffffffc02038f6:	88bfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc02038fa:	b99d                	j	ffffffffc0203570 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc02038fc:	4481                	li	s1,0
ffffffffc02038fe:	b9f1                	j	ffffffffc02035da <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc0203900:	00004697          	auipc	a3,0x4
ffffffffc0203904:	91068693          	addi	a3,a3,-1776 # ffffffffc0207210 <commands+0x8b0>
ffffffffc0203908:	00003617          	auipc	a2,0x3
ffffffffc020390c:	4a860613          	addi	a2,a2,1192 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203910:	0bc00593          	li	a1,188
ffffffffc0203914:	00004517          	auipc	a0,0x4
ffffffffc0203918:	2e450513          	addi	a0,a0,740 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc020391c:	b5ffc0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0203920:	be3ff0ef          	jal	ra,ffffffffc0203502 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0203924:	00004617          	auipc	a2,0x4
ffffffffc0203928:	83c60613          	addi	a2,a2,-1988 # ffffffffc0207160 <commands+0x800>
ffffffffc020392c:	06200593          	li	a1,98
ffffffffc0203930:	00004517          	auipc	a0,0x4
ffffffffc0203934:	82050513          	addi	a0,a0,-2016 # ffffffffc0207150 <commands+0x7f0>
ffffffffc0203938:	b43fc0ef          	jal	ra,ffffffffc020047a <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020393c:	00004697          	auipc	a3,0x4
ffffffffc0203940:	4ac68693          	addi	a3,a3,1196 # ffffffffc0207de8 <default_pmm_manager+0x830>
ffffffffc0203944:	00003617          	auipc	a2,0x3
ffffffffc0203948:	46c60613          	addi	a2,a2,1132 # ffffffffc0206db0 <commands+0x450>
ffffffffc020394c:	0fc00593          	li	a1,252
ffffffffc0203950:	00004517          	auipc	a0,0x4
ffffffffc0203954:	2a850513          	addi	a0,a0,680 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203958:	b23fc0ef          	jal	ra,ffffffffc020047a <__panic>
          assert(check_rp[i] != NULL );
ffffffffc020395c:	00004697          	auipc	a3,0x4
ffffffffc0203960:	3ac68693          	addi	a3,a3,940 # ffffffffc0207d08 <default_pmm_manager+0x750>
ffffffffc0203964:	00003617          	auipc	a2,0x3
ffffffffc0203968:	44c60613          	addi	a2,a2,1100 # ffffffffc0206db0 <commands+0x450>
ffffffffc020396c:	0dc00593          	li	a1,220
ffffffffc0203970:	00004517          	auipc	a0,0x4
ffffffffc0203974:	28850513          	addi	a0,a0,648 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203978:	b03fc0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020397c:	00004617          	auipc	a2,0x4
ffffffffc0203980:	25c60613          	addi	a2,a2,604 # ffffffffc0207bd8 <default_pmm_manager+0x620>
ffffffffc0203984:	02800593          	li	a1,40
ffffffffc0203988:	00004517          	auipc	a0,0x4
ffffffffc020398c:	27050513          	addi	a0,a0,624 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203990:	aebfc0ef          	jal	ra,ffffffffc020047a <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203994:	00004697          	auipc	a3,0x4
ffffffffc0203998:	43c68693          	addi	a3,a3,1084 # ffffffffc0207dd0 <default_pmm_manager+0x818>
ffffffffc020399c:	00003617          	auipc	a2,0x3
ffffffffc02039a0:	41460613          	addi	a2,a2,1044 # ffffffffc0206db0 <commands+0x450>
ffffffffc02039a4:	0fb00593          	li	a1,251
ffffffffc02039a8:	00004517          	auipc	a0,0x4
ffffffffc02039ac:	25050513          	addi	a0,a0,592 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc02039b0:	acbfc0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02039b4:	00003617          	auipc	a2,0x3
ffffffffc02039b8:	77460613          	addi	a2,a2,1908 # ffffffffc0207128 <commands+0x7c8>
ffffffffc02039bc:	07400593          	li	a1,116
ffffffffc02039c0:	00003517          	auipc	a0,0x3
ffffffffc02039c4:	79050513          	addi	a0,a0,1936 # ffffffffc0207150 <commands+0x7f0>
ffffffffc02039c8:	ab3fc0ef          	jal	ra,ffffffffc020047a <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02039cc:	00004697          	auipc	a3,0x4
ffffffffc02039d0:	35468693          	addi	a3,a3,852 # ffffffffc0207d20 <default_pmm_manager+0x768>
ffffffffc02039d4:	00003617          	auipc	a2,0x3
ffffffffc02039d8:	3dc60613          	addi	a2,a2,988 # ffffffffc0206db0 <commands+0x450>
ffffffffc02039dc:	0dd00593          	li	a1,221
ffffffffc02039e0:	00004517          	auipc	a0,0x4
ffffffffc02039e4:	21850513          	addi	a0,a0,536 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc02039e8:	a93fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(check_mm_struct == NULL);
ffffffffc02039ec:	00004697          	auipc	a3,0x4
ffffffffc02039f0:	26c68693          	addi	a3,a3,620 # ffffffffc0207c58 <default_pmm_manager+0x6a0>
ffffffffc02039f4:	00003617          	auipc	a2,0x3
ffffffffc02039f8:	3bc60613          	addi	a2,a2,956 # ffffffffc0206db0 <commands+0x450>
ffffffffc02039fc:	0c700593          	li	a1,199
ffffffffc0203a00:	00004517          	auipc	a0,0x4
ffffffffc0203a04:	1f850513          	addi	a0,a0,504 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203a08:	a73fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(total == nr_free_pages());
ffffffffc0203a0c:	00004697          	auipc	a3,0x4
ffffffffc0203a10:	82c68693          	addi	a3,a3,-2004 # ffffffffc0207238 <commands+0x8d8>
ffffffffc0203a14:	00003617          	auipc	a2,0x3
ffffffffc0203a18:	39c60613          	addi	a2,a2,924 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203a1c:	0bf00593          	li	a1,191
ffffffffc0203a20:	00004517          	auipc	a0,0x4
ffffffffc0203a24:	1d850513          	addi	a0,a0,472 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203a28:	a53fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert( nr_free == 0);         
ffffffffc0203a2c:	00004697          	auipc	a3,0x4
ffffffffc0203a30:	9b468693          	addi	a3,a3,-1612 # ffffffffc02073e0 <commands+0xa80>
ffffffffc0203a34:	00003617          	auipc	a2,0x3
ffffffffc0203a38:	37c60613          	addi	a2,a2,892 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203a3c:	0f300593          	li	a1,243
ffffffffc0203a40:	00004517          	auipc	a0,0x4
ffffffffc0203a44:	1b850513          	addi	a0,a0,440 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203a48:	a33fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203a4c:	00004697          	auipc	a3,0x4
ffffffffc0203a50:	22468693          	addi	a3,a3,548 # ffffffffc0207c70 <default_pmm_manager+0x6b8>
ffffffffc0203a54:	00003617          	auipc	a2,0x3
ffffffffc0203a58:	35c60613          	addi	a2,a2,860 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203a5c:	0cc00593          	li	a1,204
ffffffffc0203a60:	00004517          	auipc	a0,0x4
ffffffffc0203a64:	19850513          	addi	a0,a0,408 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203a68:	a13fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(mm != NULL);
ffffffffc0203a6c:	00004697          	auipc	a3,0x4
ffffffffc0203a70:	1dc68693          	addi	a3,a3,476 # ffffffffc0207c48 <default_pmm_manager+0x690>
ffffffffc0203a74:	00003617          	auipc	a2,0x3
ffffffffc0203a78:	33c60613          	addi	a2,a2,828 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203a7c:	0c400593          	li	a1,196
ffffffffc0203a80:	00004517          	auipc	a0,0x4
ffffffffc0203a84:	17850513          	addi	a0,a0,376 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203a88:	9f3fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(total==0);
ffffffffc0203a8c:	00004697          	auipc	a3,0x4
ffffffffc0203a90:	3c468693          	addi	a3,a3,964 # ffffffffc0207e50 <default_pmm_manager+0x898>
ffffffffc0203a94:	00003617          	auipc	a2,0x3
ffffffffc0203a98:	31c60613          	addi	a2,a2,796 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203a9c:	11e00593          	li	a1,286
ffffffffc0203aa0:	00004517          	auipc	a0,0x4
ffffffffc0203aa4:	15850513          	addi	a0,a0,344 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203aa8:	9d3fc0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0203aac:	00003617          	auipc	a2,0x3
ffffffffc0203ab0:	73c60613          	addi	a2,a2,1852 # ffffffffc02071e8 <commands+0x888>
ffffffffc0203ab4:	06900593          	li	a1,105
ffffffffc0203ab8:	00003517          	auipc	a0,0x3
ffffffffc0203abc:	69850513          	addi	a0,a0,1688 # ffffffffc0207150 <commands+0x7f0>
ffffffffc0203ac0:	9bbfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(count==0);
ffffffffc0203ac4:	00004697          	auipc	a3,0x4
ffffffffc0203ac8:	37c68693          	addi	a3,a3,892 # ffffffffc0207e40 <default_pmm_manager+0x888>
ffffffffc0203acc:	00003617          	auipc	a2,0x3
ffffffffc0203ad0:	2e460613          	addi	a2,a2,740 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203ad4:	11d00593          	li	a1,285
ffffffffc0203ad8:	00004517          	auipc	a0,0x4
ffffffffc0203adc:	12050513          	addi	a0,a0,288 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203ae0:	99bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==1);
ffffffffc0203ae4:	00004697          	auipc	a3,0x4
ffffffffc0203ae8:	2ac68693          	addi	a3,a3,684 # ffffffffc0207d90 <default_pmm_manager+0x7d8>
ffffffffc0203aec:	00003617          	auipc	a2,0x3
ffffffffc0203af0:	2c460613          	addi	a2,a2,708 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203af4:	09500593          	li	a1,149
ffffffffc0203af8:	00004517          	auipc	a0,0x4
ffffffffc0203afc:	10050513          	addi	a0,a0,256 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203b00:	97bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203b04:	00004697          	auipc	a3,0x4
ffffffffc0203b08:	23c68693          	addi	a3,a3,572 # ffffffffc0207d40 <default_pmm_manager+0x788>
ffffffffc0203b0c:	00003617          	auipc	a2,0x3
ffffffffc0203b10:	2a460613          	addi	a2,a2,676 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203b14:	0ea00593          	li	a1,234
ffffffffc0203b18:	00004517          	auipc	a0,0x4
ffffffffc0203b1c:	0e050513          	addi	a0,a0,224 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203b20:	95bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203b24:	00004697          	auipc	a3,0x4
ffffffffc0203b28:	1a468693          	addi	a3,a3,420 # ffffffffc0207cc8 <default_pmm_manager+0x710>
ffffffffc0203b2c:	00003617          	auipc	a2,0x3
ffffffffc0203b30:	28460613          	addi	a2,a2,644 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203b34:	0d700593          	li	a1,215
ffffffffc0203b38:	00004517          	auipc	a0,0x4
ffffffffc0203b3c:	0c050513          	addi	a0,a0,192 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203b40:	93bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(ret==0);
ffffffffc0203b44:	00004697          	auipc	a3,0x4
ffffffffc0203b48:	2f468693          	addi	a3,a3,756 # ffffffffc0207e38 <default_pmm_manager+0x880>
ffffffffc0203b4c:	00003617          	auipc	a2,0x3
ffffffffc0203b50:	26460613          	addi	a2,a2,612 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203b54:	10200593          	li	a1,258
ffffffffc0203b58:	00004517          	auipc	a0,0x4
ffffffffc0203b5c:	0a050513          	addi	a0,a0,160 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203b60:	91bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(vma != NULL);
ffffffffc0203b64:	00004697          	auipc	a3,0x4
ffffffffc0203b68:	11c68693          	addi	a3,a3,284 # ffffffffc0207c80 <default_pmm_manager+0x6c8>
ffffffffc0203b6c:	00003617          	auipc	a2,0x3
ffffffffc0203b70:	24460613          	addi	a2,a2,580 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203b74:	0cf00593          	li	a1,207
ffffffffc0203b78:	00004517          	auipc	a0,0x4
ffffffffc0203b7c:	08050513          	addi	a0,a0,128 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203b80:	8fbfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==4);
ffffffffc0203b84:	00004697          	auipc	a3,0x4
ffffffffc0203b88:	23c68693          	addi	a3,a3,572 # ffffffffc0207dc0 <default_pmm_manager+0x808>
ffffffffc0203b8c:	00003617          	auipc	a2,0x3
ffffffffc0203b90:	22460613          	addi	a2,a2,548 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203b94:	09f00593          	li	a1,159
ffffffffc0203b98:	00004517          	auipc	a0,0x4
ffffffffc0203b9c:	06050513          	addi	a0,a0,96 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203ba0:	8dbfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==4);
ffffffffc0203ba4:	00004697          	auipc	a3,0x4
ffffffffc0203ba8:	21c68693          	addi	a3,a3,540 # ffffffffc0207dc0 <default_pmm_manager+0x808>
ffffffffc0203bac:	00003617          	auipc	a2,0x3
ffffffffc0203bb0:	20460613          	addi	a2,a2,516 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203bb4:	0a100593          	li	a1,161
ffffffffc0203bb8:	00004517          	auipc	a0,0x4
ffffffffc0203bbc:	04050513          	addi	a0,a0,64 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203bc0:	8bbfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==2);
ffffffffc0203bc4:	00004697          	auipc	a3,0x4
ffffffffc0203bc8:	1dc68693          	addi	a3,a3,476 # ffffffffc0207da0 <default_pmm_manager+0x7e8>
ffffffffc0203bcc:	00003617          	auipc	a2,0x3
ffffffffc0203bd0:	1e460613          	addi	a2,a2,484 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203bd4:	09700593          	li	a1,151
ffffffffc0203bd8:	00004517          	auipc	a0,0x4
ffffffffc0203bdc:	02050513          	addi	a0,a0,32 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203be0:	89bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==2);
ffffffffc0203be4:	00004697          	auipc	a3,0x4
ffffffffc0203be8:	1bc68693          	addi	a3,a3,444 # ffffffffc0207da0 <default_pmm_manager+0x7e8>
ffffffffc0203bec:	00003617          	auipc	a2,0x3
ffffffffc0203bf0:	1c460613          	addi	a2,a2,452 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203bf4:	09900593          	li	a1,153
ffffffffc0203bf8:	00004517          	auipc	a0,0x4
ffffffffc0203bfc:	00050513          	mv	a0,a0
ffffffffc0203c00:	87bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==3);
ffffffffc0203c04:	00004697          	auipc	a3,0x4
ffffffffc0203c08:	1ac68693          	addi	a3,a3,428 # ffffffffc0207db0 <default_pmm_manager+0x7f8>
ffffffffc0203c0c:	00003617          	auipc	a2,0x3
ffffffffc0203c10:	1a460613          	addi	a2,a2,420 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203c14:	09b00593          	li	a1,155
ffffffffc0203c18:	00004517          	auipc	a0,0x4
ffffffffc0203c1c:	fe050513          	addi	a0,a0,-32 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203c20:	85bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==3);
ffffffffc0203c24:	00004697          	auipc	a3,0x4
ffffffffc0203c28:	18c68693          	addi	a3,a3,396 # ffffffffc0207db0 <default_pmm_manager+0x7f8>
ffffffffc0203c2c:	00003617          	auipc	a2,0x3
ffffffffc0203c30:	18460613          	addi	a2,a2,388 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203c34:	09d00593          	li	a1,157
ffffffffc0203c38:	00004517          	auipc	a0,0x4
ffffffffc0203c3c:	fc050513          	addi	a0,a0,-64 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203c40:	83bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==1);
ffffffffc0203c44:	00004697          	auipc	a3,0x4
ffffffffc0203c48:	14c68693          	addi	a3,a3,332 # ffffffffc0207d90 <default_pmm_manager+0x7d8>
ffffffffc0203c4c:	00003617          	auipc	a2,0x3
ffffffffc0203c50:	16460613          	addi	a2,a2,356 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203c54:	09300593          	li	a1,147
ffffffffc0203c58:	00004517          	auipc	a0,0x4
ffffffffc0203c5c:	fa050513          	addi	a0,a0,-96 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203c60:	81bfc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203c64 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203c64:	000af797          	auipc	a5,0xaf
ffffffffc0203c68:	c047b783          	ld	a5,-1020(a5) # ffffffffc02b2868 <sm>
ffffffffc0203c6c:	6b9c                	ld	a5,16(a5)
ffffffffc0203c6e:	8782                	jr	a5

ffffffffc0203c70 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203c70:	000af797          	auipc	a5,0xaf
ffffffffc0203c74:	bf87b783          	ld	a5,-1032(a5) # ffffffffc02b2868 <sm>
ffffffffc0203c78:	739c                	ld	a5,32(a5)
ffffffffc0203c7a:	8782                	jr	a5

ffffffffc0203c7c <swap_out>:
{
ffffffffc0203c7c:	711d                	addi	sp,sp,-96
ffffffffc0203c7e:	ec86                	sd	ra,88(sp)
ffffffffc0203c80:	e8a2                	sd	s0,80(sp)
ffffffffc0203c82:	e4a6                	sd	s1,72(sp)
ffffffffc0203c84:	e0ca                	sd	s2,64(sp)
ffffffffc0203c86:	fc4e                	sd	s3,56(sp)
ffffffffc0203c88:	f852                	sd	s4,48(sp)
ffffffffc0203c8a:	f456                	sd	s5,40(sp)
ffffffffc0203c8c:	f05a                	sd	s6,32(sp)
ffffffffc0203c8e:	ec5e                	sd	s7,24(sp)
ffffffffc0203c90:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203c92:	cde9                	beqz	a1,ffffffffc0203d6c <swap_out+0xf0>
ffffffffc0203c94:	8a2e                	mv	s4,a1
ffffffffc0203c96:	892a                	mv	s2,a0
ffffffffc0203c98:	8ab2                	mv	s5,a2
ffffffffc0203c9a:	4401                	li	s0,0
ffffffffc0203c9c:	000af997          	auipc	s3,0xaf
ffffffffc0203ca0:	bcc98993          	addi	s3,s3,-1076 # ffffffffc02b2868 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203ca4:	00004b17          	auipc	s6,0x4
ffffffffc0203ca8:	23cb0b13          	addi	s6,s6,572 # ffffffffc0207ee0 <default_pmm_manager+0x928>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203cac:	00004b97          	auipc	s7,0x4
ffffffffc0203cb0:	21cb8b93          	addi	s7,s7,540 # ffffffffc0207ec8 <default_pmm_manager+0x910>
ffffffffc0203cb4:	a825                	j	ffffffffc0203cec <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203cb6:	67a2                	ld	a5,8(sp)
ffffffffc0203cb8:	8626                	mv	a2,s1
ffffffffc0203cba:	85a2                	mv	a1,s0
ffffffffc0203cbc:	7f94                	ld	a3,56(a5)
ffffffffc0203cbe:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203cc0:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203cc2:	82b1                	srli	a3,a3,0xc
ffffffffc0203cc4:	0685                	addi	a3,a3,1
ffffffffc0203cc6:	cbafc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203cca:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203ccc:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203cce:	7d1c                	ld	a5,56(a0)
ffffffffc0203cd0:	83b1                	srli	a5,a5,0xc
ffffffffc0203cd2:	0785                	addi	a5,a5,1
ffffffffc0203cd4:	07a2                	slli	a5,a5,0x8
ffffffffc0203cd6:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203cda:	bc4fe0ef          	jal	ra,ffffffffc020209e <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203cde:	01893503          	ld	a0,24(s2)
ffffffffc0203ce2:	85a6                	mv	a1,s1
ffffffffc0203ce4:	f5eff0ef          	jal	ra,ffffffffc0203442 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203ce8:	048a0d63          	beq	s4,s0,ffffffffc0203d42 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203cec:	0009b783          	ld	a5,0(s3)
ffffffffc0203cf0:	8656                	mv	a2,s5
ffffffffc0203cf2:	002c                	addi	a1,sp,8
ffffffffc0203cf4:	7b9c                	ld	a5,48(a5)
ffffffffc0203cf6:	854a                	mv	a0,s2
ffffffffc0203cf8:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203cfa:	e12d                	bnez	a0,ffffffffc0203d5c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203cfc:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203cfe:	01893503          	ld	a0,24(s2)
ffffffffc0203d02:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203d04:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203d06:	85a6                	mv	a1,s1
ffffffffc0203d08:	c10fe0ef          	jal	ra,ffffffffc0202118 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203d0c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203d0e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203d10:	8b85                	andi	a5,a5,1
ffffffffc0203d12:	cfb9                	beqz	a5,ffffffffc0203d70 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203d14:	65a2                	ld	a1,8(sp)
ffffffffc0203d16:	7d9c                	ld	a5,56(a1)
ffffffffc0203d18:	83b1                	srli	a5,a5,0xc
ffffffffc0203d1a:	0785                	addi	a5,a5,1
ffffffffc0203d1c:	00879513          	slli	a0,a5,0x8
ffffffffc0203d20:	03c010ef          	jal	ra,ffffffffc0204d5c <swapfs_write>
ffffffffc0203d24:	d949                	beqz	a0,ffffffffc0203cb6 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203d26:	855e                	mv	a0,s7
ffffffffc0203d28:	c58fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203d2c:	0009b783          	ld	a5,0(s3)
ffffffffc0203d30:	6622                	ld	a2,8(sp)
ffffffffc0203d32:	4681                	li	a3,0
ffffffffc0203d34:	739c                	ld	a5,32(a5)
ffffffffc0203d36:	85a6                	mv	a1,s1
ffffffffc0203d38:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203d3a:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203d3c:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203d3e:	fa8a17e3          	bne	s4,s0,ffffffffc0203cec <swap_out+0x70>
}
ffffffffc0203d42:	60e6                	ld	ra,88(sp)
ffffffffc0203d44:	8522                	mv	a0,s0
ffffffffc0203d46:	6446                	ld	s0,80(sp)
ffffffffc0203d48:	64a6                	ld	s1,72(sp)
ffffffffc0203d4a:	6906                	ld	s2,64(sp)
ffffffffc0203d4c:	79e2                	ld	s3,56(sp)
ffffffffc0203d4e:	7a42                	ld	s4,48(sp)
ffffffffc0203d50:	7aa2                	ld	s5,40(sp)
ffffffffc0203d52:	7b02                	ld	s6,32(sp)
ffffffffc0203d54:	6be2                	ld	s7,24(sp)
ffffffffc0203d56:	6c42                	ld	s8,16(sp)
ffffffffc0203d58:	6125                	addi	sp,sp,96
ffffffffc0203d5a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203d5c:	85a2                	mv	a1,s0
ffffffffc0203d5e:	00004517          	auipc	a0,0x4
ffffffffc0203d62:	12250513          	addi	a0,a0,290 # ffffffffc0207e80 <default_pmm_manager+0x8c8>
ffffffffc0203d66:	c1afc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                  break;
ffffffffc0203d6a:	bfe1                	j	ffffffffc0203d42 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203d6c:	4401                	li	s0,0
ffffffffc0203d6e:	bfd1                	j	ffffffffc0203d42 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203d70:	00004697          	auipc	a3,0x4
ffffffffc0203d74:	14068693          	addi	a3,a3,320 # ffffffffc0207eb0 <default_pmm_manager+0x8f8>
ffffffffc0203d78:	00003617          	auipc	a2,0x3
ffffffffc0203d7c:	03860613          	addi	a2,a2,56 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203d80:	06800593          	li	a1,104
ffffffffc0203d84:	00004517          	auipc	a0,0x4
ffffffffc0203d88:	e7450513          	addi	a0,a0,-396 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203d8c:	eeefc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203d90 <swap_in>:
{
ffffffffc0203d90:	7179                	addi	sp,sp,-48
ffffffffc0203d92:	e84a                	sd	s2,16(sp)
ffffffffc0203d94:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203d96:	4505                	li	a0,1
{
ffffffffc0203d98:	ec26                	sd	s1,24(sp)
ffffffffc0203d9a:	e44e                	sd	s3,8(sp)
ffffffffc0203d9c:	f406                	sd	ra,40(sp)
ffffffffc0203d9e:	f022                	sd	s0,32(sp)
ffffffffc0203da0:	84ae                	mv	s1,a1
ffffffffc0203da2:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203da4:	a68fe0ef          	jal	ra,ffffffffc020200c <alloc_pages>
     assert(result!=NULL);
ffffffffc0203da8:	c129                	beqz	a0,ffffffffc0203dea <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203daa:	842a                	mv	s0,a0
ffffffffc0203dac:	01893503          	ld	a0,24(s2)
ffffffffc0203db0:	4601                	li	a2,0
ffffffffc0203db2:	85a6                	mv	a1,s1
ffffffffc0203db4:	b64fe0ef          	jal	ra,ffffffffc0202118 <get_pte>
ffffffffc0203db8:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203dba:	6108                	ld	a0,0(a0)
ffffffffc0203dbc:	85a2                	mv	a1,s0
ffffffffc0203dbe:	711000ef          	jal	ra,ffffffffc0204cce <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203dc2:	00093583          	ld	a1,0(s2)
ffffffffc0203dc6:	8626                	mv	a2,s1
ffffffffc0203dc8:	00004517          	auipc	a0,0x4
ffffffffc0203dcc:	16850513          	addi	a0,a0,360 # ffffffffc0207f30 <default_pmm_manager+0x978>
ffffffffc0203dd0:	81a1                	srli	a1,a1,0x8
ffffffffc0203dd2:	baefc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0203dd6:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203dd8:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203ddc:	7402                	ld	s0,32(sp)
ffffffffc0203dde:	64e2                	ld	s1,24(sp)
ffffffffc0203de0:	6942                	ld	s2,16(sp)
ffffffffc0203de2:	69a2                	ld	s3,8(sp)
ffffffffc0203de4:	4501                	li	a0,0
ffffffffc0203de6:	6145                	addi	sp,sp,48
ffffffffc0203de8:	8082                	ret
     assert(result!=NULL);
ffffffffc0203dea:	00004697          	auipc	a3,0x4
ffffffffc0203dee:	13668693          	addi	a3,a3,310 # ffffffffc0207f20 <default_pmm_manager+0x968>
ffffffffc0203df2:	00003617          	auipc	a2,0x3
ffffffffc0203df6:	fbe60613          	addi	a2,a2,-66 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203dfa:	07e00593          	li	a1,126
ffffffffc0203dfe:	00004517          	auipc	a0,0x4
ffffffffc0203e02:	dfa50513          	addi	a0,a0,-518 # ffffffffc0207bf8 <default_pmm_manager+0x640>
ffffffffc0203e06:	e74fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203e0a <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203e0a:	000ab797          	auipc	a5,0xab
ffffffffc0203e0e:	9e678793          	addi	a5,a5,-1562 # ffffffffc02ae7f0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203e12:	f51c                	sd	a5,40(a0)
ffffffffc0203e14:	e79c                	sd	a5,8(a5)
ffffffffc0203e16:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203e18:	4501                	li	a0,0
ffffffffc0203e1a:	8082                	ret

ffffffffc0203e1c <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203e1c:	4501                	li	a0,0
ffffffffc0203e1e:	8082                	ret

ffffffffc0203e20 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203e20:	4501                	li	a0,0
ffffffffc0203e22:	8082                	ret

ffffffffc0203e24 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203e24:	4501                	li	a0,0
ffffffffc0203e26:	8082                	ret

ffffffffc0203e28 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203e28:	711d                	addi	sp,sp,-96
ffffffffc0203e2a:	fc4e                	sd	s3,56(sp)
ffffffffc0203e2c:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203e2e:	00004517          	auipc	a0,0x4
ffffffffc0203e32:	14250513          	addi	a0,a0,322 # ffffffffc0207f70 <default_pmm_manager+0x9b8>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203e36:	698d                	lui	s3,0x3
ffffffffc0203e38:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203e3a:	e0ca                	sd	s2,64(sp)
ffffffffc0203e3c:	ec86                	sd	ra,88(sp)
ffffffffc0203e3e:	e8a2                	sd	s0,80(sp)
ffffffffc0203e40:	e4a6                	sd	s1,72(sp)
ffffffffc0203e42:	f456                	sd	s5,40(sp)
ffffffffc0203e44:	f05a                	sd	s6,32(sp)
ffffffffc0203e46:	ec5e                	sd	s7,24(sp)
ffffffffc0203e48:	e862                	sd	s8,16(sp)
ffffffffc0203e4a:	e466                	sd	s9,8(sp)
ffffffffc0203e4c:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203e4e:	b32fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203e52:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb0>
    assert(pgfault_num==4);
ffffffffc0203e56:	000af917          	auipc	s2,0xaf
ffffffffc0203e5a:	a2a92903          	lw	s2,-1494(s2) # ffffffffc02b2880 <pgfault_num>
ffffffffc0203e5e:	4791                	li	a5,4
ffffffffc0203e60:	14f91e63          	bne	s2,a5,ffffffffc0203fbc <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e64:	00004517          	auipc	a0,0x4
ffffffffc0203e68:	14c50513          	addi	a0,a0,332 # ffffffffc0207fb0 <default_pmm_manager+0x9f8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203e6c:	6a85                	lui	s5,0x1
ffffffffc0203e6e:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e70:	b10fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203e74:	000af417          	auipc	s0,0xaf
ffffffffc0203e78:	a0c40413          	addi	s0,s0,-1524 # ffffffffc02b2880 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203e7c:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
    assert(pgfault_num==4);
ffffffffc0203e80:	4004                	lw	s1,0(s0)
ffffffffc0203e82:	2481                	sext.w	s1,s1
ffffffffc0203e84:	2b249c63          	bne	s1,s2,ffffffffc020413c <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203e88:	00004517          	auipc	a0,0x4
ffffffffc0203e8c:	15050513          	addi	a0,a0,336 # ffffffffc0207fd8 <default_pmm_manager+0xa20>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203e90:	6b91                	lui	s7,0x4
ffffffffc0203e92:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203e94:	aecfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203e98:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5bb0>
    assert(pgfault_num==4);
ffffffffc0203e9c:	00042903          	lw	s2,0(s0)
ffffffffc0203ea0:	2901                	sext.w	s2,s2
ffffffffc0203ea2:	26991d63          	bne	s2,s1,ffffffffc020411c <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203ea6:	00004517          	auipc	a0,0x4
ffffffffc0203eaa:	15a50513          	addi	a0,a0,346 # ffffffffc0208000 <default_pmm_manager+0xa48>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203eae:	6c89                	lui	s9,0x2
ffffffffc0203eb0:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203eb2:	acefc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203eb6:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7bb0>
    assert(pgfault_num==4);
ffffffffc0203eba:	401c                	lw	a5,0(s0)
ffffffffc0203ebc:	2781                	sext.w	a5,a5
ffffffffc0203ebe:	23279f63          	bne	a5,s2,ffffffffc02040fc <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203ec2:	00004517          	auipc	a0,0x4
ffffffffc0203ec6:	16650513          	addi	a0,a0,358 # ffffffffc0208028 <default_pmm_manager+0xa70>
ffffffffc0203eca:	ab6fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203ece:	6795                	lui	a5,0x5
ffffffffc0203ed0:	4739                	li	a4,14
ffffffffc0203ed2:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb0>
    assert(pgfault_num==5);
ffffffffc0203ed6:	4004                	lw	s1,0(s0)
ffffffffc0203ed8:	4795                	li	a5,5
ffffffffc0203eda:	2481                	sext.w	s1,s1
ffffffffc0203edc:	20f49063          	bne	s1,a5,ffffffffc02040dc <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203ee0:	00004517          	auipc	a0,0x4
ffffffffc0203ee4:	12050513          	addi	a0,a0,288 # ffffffffc0208000 <default_pmm_manager+0xa48>
ffffffffc0203ee8:	a98fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203eec:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0203ef0:	401c                	lw	a5,0(s0)
ffffffffc0203ef2:	2781                	sext.w	a5,a5
ffffffffc0203ef4:	1c979463          	bne	a5,s1,ffffffffc02040bc <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203ef8:	00004517          	auipc	a0,0x4
ffffffffc0203efc:	0b850513          	addi	a0,a0,184 # ffffffffc0207fb0 <default_pmm_manager+0x9f8>
ffffffffc0203f00:	a80fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203f04:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203f08:	401c                	lw	a5,0(s0)
ffffffffc0203f0a:	4719                	li	a4,6
ffffffffc0203f0c:	2781                	sext.w	a5,a5
ffffffffc0203f0e:	18e79763          	bne	a5,a4,ffffffffc020409c <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203f12:	00004517          	auipc	a0,0x4
ffffffffc0203f16:	0ee50513          	addi	a0,a0,238 # ffffffffc0208000 <default_pmm_manager+0xa48>
ffffffffc0203f1a:	a66fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203f1e:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0203f22:	401c                	lw	a5,0(s0)
ffffffffc0203f24:	471d                	li	a4,7
ffffffffc0203f26:	2781                	sext.w	a5,a5
ffffffffc0203f28:	14e79a63          	bne	a5,a4,ffffffffc020407c <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203f2c:	00004517          	auipc	a0,0x4
ffffffffc0203f30:	04450513          	addi	a0,a0,68 # ffffffffc0207f70 <default_pmm_manager+0x9b8>
ffffffffc0203f34:	a4cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203f38:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203f3c:	401c                	lw	a5,0(s0)
ffffffffc0203f3e:	4721                	li	a4,8
ffffffffc0203f40:	2781                	sext.w	a5,a5
ffffffffc0203f42:	10e79d63          	bne	a5,a4,ffffffffc020405c <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203f46:	00004517          	auipc	a0,0x4
ffffffffc0203f4a:	09250513          	addi	a0,a0,146 # ffffffffc0207fd8 <default_pmm_manager+0xa20>
ffffffffc0203f4e:	a32fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203f52:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203f56:	401c                	lw	a5,0(s0)
ffffffffc0203f58:	4725                	li	a4,9
ffffffffc0203f5a:	2781                	sext.w	a5,a5
ffffffffc0203f5c:	0ee79063          	bne	a5,a4,ffffffffc020403c <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203f60:	00004517          	auipc	a0,0x4
ffffffffc0203f64:	0c850513          	addi	a0,a0,200 # ffffffffc0208028 <default_pmm_manager+0xa70>
ffffffffc0203f68:	a18fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203f6c:	6795                	lui	a5,0x5
ffffffffc0203f6e:	4739                	li	a4,14
ffffffffc0203f70:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb0>
    assert(pgfault_num==10);
ffffffffc0203f74:	4004                	lw	s1,0(s0)
ffffffffc0203f76:	47a9                	li	a5,10
ffffffffc0203f78:	2481                	sext.w	s1,s1
ffffffffc0203f7a:	0af49163          	bne	s1,a5,ffffffffc020401c <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203f7e:	00004517          	auipc	a0,0x4
ffffffffc0203f82:	03250513          	addi	a0,a0,50 # ffffffffc0207fb0 <default_pmm_manager+0x9f8>
ffffffffc0203f86:	9fafc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203f8a:	6785                	lui	a5,0x1
ffffffffc0203f8c:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0203f90:	06979663          	bne	a5,s1,ffffffffc0203ffc <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0203f94:	401c                	lw	a5,0(s0)
ffffffffc0203f96:	472d                	li	a4,11
ffffffffc0203f98:	2781                	sext.w	a5,a5
ffffffffc0203f9a:	04e79163          	bne	a5,a4,ffffffffc0203fdc <_fifo_check_swap+0x1b4>
}
ffffffffc0203f9e:	60e6                	ld	ra,88(sp)
ffffffffc0203fa0:	6446                	ld	s0,80(sp)
ffffffffc0203fa2:	64a6                	ld	s1,72(sp)
ffffffffc0203fa4:	6906                	ld	s2,64(sp)
ffffffffc0203fa6:	79e2                	ld	s3,56(sp)
ffffffffc0203fa8:	7a42                	ld	s4,48(sp)
ffffffffc0203faa:	7aa2                	ld	s5,40(sp)
ffffffffc0203fac:	7b02                	ld	s6,32(sp)
ffffffffc0203fae:	6be2                	ld	s7,24(sp)
ffffffffc0203fb0:	6c42                	ld	s8,16(sp)
ffffffffc0203fb2:	6ca2                	ld	s9,8(sp)
ffffffffc0203fb4:	6d02                	ld	s10,0(sp)
ffffffffc0203fb6:	4501                	li	a0,0
ffffffffc0203fb8:	6125                	addi	sp,sp,96
ffffffffc0203fba:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203fbc:	00004697          	auipc	a3,0x4
ffffffffc0203fc0:	e0468693          	addi	a3,a3,-508 # ffffffffc0207dc0 <default_pmm_manager+0x808>
ffffffffc0203fc4:	00003617          	auipc	a2,0x3
ffffffffc0203fc8:	dec60613          	addi	a2,a2,-532 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203fcc:	05100593          	li	a1,81
ffffffffc0203fd0:	00004517          	auipc	a0,0x4
ffffffffc0203fd4:	fc850513          	addi	a0,a0,-56 # ffffffffc0207f98 <default_pmm_manager+0x9e0>
ffffffffc0203fd8:	ca2fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==11);
ffffffffc0203fdc:	00004697          	auipc	a3,0x4
ffffffffc0203fe0:	0fc68693          	addi	a3,a3,252 # ffffffffc02080d8 <default_pmm_manager+0xb20>
ffffffffc0203fe4:	00003617          	auipc	a2,0x3
ffffffffc0203fe8:	dcc60613          	addi	a2,a2,-564 # ffffffffc0206db0 <commands+0x450>
ffffffffc0203fec:	07300593          	li	a1,115
ffffffffc0203ff0:	00004517          	auipc	a0,0x4
ffffffffc0203ff4:	fa850513          	addi	a0,a0,-88 # ffffffffc0207f98 <default_pmm_manager+0x9e0>
ffffffffc0203ff8:	c82fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203ffc:	00004697          	auipc	a3,0x4
ffffffffc0204000:	0b468693          	addi	a3,a3,180 # ffffffffc02080b0 <default_pmm_manager+0xaf8>
ffffffffc0204004:	00003617          	auipc	a2,0x3
ffffffffc0204008:	dac60613          	addi	a2,a2,-596 # ffffffffc0206db0 <commands+0x450>
ffffffffc020400c:	07100593          	li	a1,113
ffffffffc0204010:	00004517          	auipc	a0,0x4
ffffffffc0204014:	f8850513          	addi	a0,a0,-120 # ffffffffc0207f98 <default_pmm_manager+0x9e0>
ffffffffc0204018:	c62fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==10);
ffffffffc020401c:	00004697          	auipc	a3,0x4
ffffffffc0204020:	08468693          	addi	a3,a3,132 # ffffffffc02080a0 <default_pmm_manager+0xae8>
ffffffffc0204024:	00003617          	auipc	a2,0x3
ffffffffc0204028:	d8c60613          	addi	a2,a2,-628 # ffffffffc0206db0 <commands+0x450>
ffffffffc020402c:	06f00593          	li	a1,111
ffffffffc0204030:	00004517          	auipc	a0,0x4
ffffffffc0204034:	f6850513          	addi	a0,a0,-152 # ffffffffc0207f98 <default_pmm_manager+0x9e0>
ffffffffc0204038:	c42fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==9);
ffffffffc020403c:	00004697          	auipc	a3,0x4
ffffffffc0204040:	05468693          	addi	a3,a3,84 # ffffffffc0208090 <default_pmm_manager+0xad8>
ffffffffc0204044:	00003617          	auipc	a2,0x3
ffffffffc0204048:	d6c60613          	addi	a2,a2,-660 # ffffffffc0206db0 <commands+0x450>
ffffffffc020404c:	06c00593          	li	a1,108
ffffffffc0204050:	00004517          	auipc	a0,0x4
ffffffffc0204054:	f4850513          	addi	a0,a0,-184 # ffffffffc0207f98 <default_pmm_manager+0x9e0>
ffffffffc0204058:	c22fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==8);
ffffffffc020405c:	00004697          	auipc	a3,0x4
ffffffffc0204060:	02468693          	addi	a3,a3,36 # ffffffffc0208080 <default_pmm_manager+0xac8>
ffffffffc0204064:	00003617          	auipc	a2,0x3
ffffffffc0204068:	d4c60613          	addi	a2,a2,-692 # ffffffffc0206db0 <commands+0x450>
ffffffffc020406c:	06900593          	li	a1,105
ffffffffc0204070:	00004517          	auipc	a0,0x4
ffffffffc0204074:	f2850513          	addi	a0,a0,-216 # ffffffffc0207f98 <default_pmm_manager+0x9e0>
ffffffffc0204078:	c02fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==7);
ffffffffc020407c:	00004697          	auipc	a3,0x4
ffffffffc0204080:	ff468693          	addi	a3,a3,-12 # ffffffffc0208070 <default_pmm_manager+0xab8>
ffffffffc0204084:	00003617          	auipc	a2,0x3
ffffffffc0204088:	d2c60613          	addi	a2,a2,-724 # ffffffffc0206db0 <commands+0x450>
ffffffffc020408c:	06600593          	li	a1,102
ffffffffc0204090:	00004517          	auipc	a0,0x4
ffffffffc0204094:	f0850513          	addi	a0,a0,-248 # ffffffffc0207f98 <default_pmm_manager+0x9e0>
ffffffffc0204098:	be2fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==6);
ffffffffc020409c:	00004697          	auipc	a3,0x4
ffffffffc02040a0:	fc468693          	addi	a3,a3,-60 # ffffffffc0208060 <default_pmm_manager+0xaa8>
ffffffffc02040a4:	00003617          	auipc	a2,0x3
ffffffffc02040a8:	d0c60613          	addi	a2,a2,-756 # ffffffffc0206db0 <commands+0x450>
ffffffffc02040ac:	06300593          	li	a1,99
ffffffffc02040b0:	00004517          	auipc	a0,0x4
ffffffffc02040b4:	ee850513          	addi	a0,a0,-280 # ffffffffc0207f98 <default_pmm_manager+0x9e0>
ffffffffc02040b8:	bc2fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==5);
ffffffffc02040bc:	00004697          	auipc	a3,0x4
ffffffffc02040c0:	f9468693          	addi	a3,a3,-108 # ffffffffc0208050 <default_pmm_manager+0xa98>
ffffffffc02040c4:	00003617          	auipc	a2,0x3
ffffffffc02040c8:	cec60613          	addi	a2,a2,-788 # ffffffffc0206db0 <commands+0x450>
ffffffffc02040cc:	06000593          	li	a1,96
ffffffffc02040d0:	00004517          	auipc	a0,0x4
ffffffffc02040d4:	ec850513          	addi	a0,a0,-312 # ffffffffc0207f98 <default_pmm_manager+0x9e0>
ffffffffc02040d8:	ba2fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==5);
ffffffffc02040dc:	00004697          	auipc	a3,0x4
ffffffffc02040e0:	f7468693          	addi	a3,a3,-140 # ffffffffc0208050 <default_pmm_manager+0xa98>
ffffffffc02040e4:	00003617          	auipc	a2,0x3
ffffffffc02040e8:	ccc60613          	addi	a2,a2,-820 # ffffffffc0206db0 <commands+0x450>
ffffffffc02040ec:	05d00593          	li	a1,93
ffffffffc02040f0:	00004517          	auipc	a0,0x4
ffffffffc02040f4:	ea850513          	addi	a0,a0,-344 # ffffffffc0207f98 <default_pmm_manager+0x9e0>
ffffffffc02040f8:	b82fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc02040fc:	00004697          	auipc	a3,0x4
ffffffffc0204100:	cc468693          	addi	a3,a3,-828 # ffffffffc0207dc0 <default_pmm_manager+0x808>
ffffffffc0204104:	00003617          	auipc	a2,0x3
ffffffffc0204108:	cac60613          	addi	a2,a2,-852 # ffffffffc0206db0 <commands+0x450>
ffffffffc020410c:	05a00593          	li	a1,90
ffffffffc0204110:	00004517          	auipc	a0,0x4
ffffffffc0204114:	e8850513          	addi	a0,a0,-376 # ffffffffc0207f98 <default_pmm_manager+0x9e0>
ffffffffc0204118:	b62fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc020411c:	00004697          	auipc	a3,0x4
ffffffffc0204120:	ca468693          	addi	a3,a3,-860 # ffffffffc0207dc0 <default_pmm_manager+0x808>
ffffffffc0204124:	00003617          	auipc	a2,0x3
ffffffffc0204128:	c8c60613          	addi	a2,a2,-884 # ffffffffc0206db0 <commands+0x450>
ffffffffc020412c:	05700593          	li	a1,87
ffffffffc0204130:	00004517          	auipc	a0,0x4
ffffffffc0204134:	e6850513          	addi	a0,a0,-408 # ffffffffc0207f98 <default_pmm_manager+0x9e0>
ffffffffc0204138:	b42fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc020413c:	00004697          	auipc	a3,0x4
ffffffffc0204140:	c8468693          	addi	a3,a3,-892 # ffffffffc0207dc0 <default_pmm_manager+0x808>
ffffffffc0204144:	00003617          	auipc	a2,0x3
ffffffffc0204148:	c6c60613          	addi	a2,a2,-916 # ffffffffc0206db0 <commands+0x450>
ffffffffc020414c:	05400593          	li	a1,84
ffffffffc0204150:	00004517          	auipc	a0,0x4
ffffffffc0204154:	e4850513          	addi	a0,a0,-440 # ffffffffc0207f98 <default_pmm_manager+0x9e0>
ffffffffc0204158:	b22fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020415c <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020415c:	751c                	ld	a5,40(a0)
{
ffffffffc020415e:	1141                	addi	sp,sp,-16
ffffffffc0204160:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0204162:	cf91                	beqz	a5,ffffffffc020417e <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0204164:	ee0d                	bnez	a2,ffffffffc020419e <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0204166:	679c                	ld	a5,8(a5)
}
ffffffffc0204168:	60a2                	ld	ra,8(sp)
ffffffffc020416a:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc020416c:	6394                	ld	a3,0(a5)
ffffffffc020416e:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0204170:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0204174:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0204176:	e314                	sd	a3,0(a4)
ffffffffc0204178:	e19c                	sd	a5,0(a1)
}
ffffffffc020417a:	0141                	addi	sp,sp,16
ffffffffc020417c:	8082                	ret
         assert(head != NULL);
ffffffffc020417e:	00004697          	auipc	a3,0x4
ffffffffc0204182:	f6a68693          	addi	a3,a3,-150 # ffffffffc02080e8 <default_pmm_manager+0xb30>
ffffffffc0204186:	00003617          	auipc	a2,0x3
ffffffffc020418a:	c2a60613          	addi	a2,a2,-982 # ffffffffc0206db0 <commands+0x450>
ffffffffc020418e:	04100593          	li	a1,65
ffffffffc0204192:	00004517          	auipc	a0,0x4
ffffffffc0204196:	e0650513          	addi	a0,a0,-506 # ffffffffc0207f98 <default_pmm_manager+0x9e0>
ffffffffc020419a:	ae0fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(in_tick==0);
ffffffffc020419e:	00004697          	auipc	a3,0x4
ffffffffc02041a2:	f5a68693          	addi	a3,a3,-166 # ffffffffc02080f8 <default_pmm_manager+0xb40>
ffffffffc02041a6:	00003617          	auipc	a2,0x3
ffffffffc02041aa:	c0a60613          	addi	a2,a2,-1014 # ffffffffc0206db0 <commands+0x450>
ffffffffc02041ae:	04200593          	li	a1,66
ffffffffc02041b2:	00004517          	auipc	a0,0x4
ffffffffc02041b6:	de650513          	addi	a0,a0,-538 # ffffffffc0207f98 <default_pmm_manager+0x9e0>
ffffffffc02041ba:	ac0fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02041be <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02041be:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc02041c0:	cb91                	beqz	a5,ffffffffc02041d4 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02041c2:	6394                	ld	a3,0(a5)
ffffffffc02041c4:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc02041c8:	e398                	sd	a4,0(a5)
ffffffffc02041ca:	e698                	sd	a4,8(a3)
}
ffffffffc02041cc:	4501                	li	a0,0
    elm->next = next;
ffffffffc02041ce:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc02041d0:	f614                	sd	a3,40(a2)
ffffffffc02041d2:	8082                	ret
{
ffffffffc02041d4:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc02041d6:	00004697          	auipc	a3,0x4
ffffffffc02041da:	f3268693          	addi	a3,a3,-206 # ffffffffc0208108 <default_pmm_manager+0xb50>
ffffffffc02041de:	00003617          	auipc	a2,0x3
ffffffffc02041e2:	bd260613          	addi	a2,a2,-1070 # ffffffffc0206db0 <commands+0x450>
ffffffffc02041e6:	03200593          	li	a1,50
ffffffffc02041ea:	00004517          	auipc	a0,0x4
ffffffffc02041ee:	dae50513          	addi	a0,a0,-594 # ffffffffc0207f98 <default_pmm_manager+0x9e0>
{
ffffffffc02041f2:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02041f4:	a86fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02041f8 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02041f8:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02041fa:	00004697          	auipc	a3,0x4
ffffffffc02041fe:	f4668693          	addi	a3,a3,-186 # ffffffffc0208140 <default_pmm_manager+0xb88>
ffffffffc0204202:	00003617          	auipc	a2,0x3
ffffffffc0204206:	bae60613          	addi	a2,a2,-1106 # ffffffffc0206db0 <commands+0x450>
ffffffffc020420a:	06e00593          	li	a1,110
ffffffffc020420e:	00004517          	auipc	a0,0x4
ffffffffc0204212:	f5250513          	addi	a0,a0,-174 # ffffffffc0208160 <default_pmm_manager+0xba8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204216:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0204218:	a62fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020421c <mm_create>:
mm_create(void) {
ffffffffc020421c:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020421e:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0204222:	e022                	sd	s0,0(sp)
ffffffffc0204224:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0204226:	c09fd0ef          	jal	ra,ffffffffc0201e2e <kmalloc>
ffffffffc020422a:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc020422c:	c505                	beqz	a0,ffffffffc0204254 <mm_create+0x38>
    elm->prev = elm->next = elm;
ffffffffc020422e:	e408                	sd	a0,8(s0)
ffffffffc0204230:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0204232:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0204236:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020423a:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020423e:	000ae797          	auipc	a5,0xae
ffffffffc0204242:	6327a783          	lw	a5,1586(a5) # ffffffffc02b2870 <swap_init_ok>
ffffffffc0204246:	ef81                	bnez	a5,ffffffffc020425e <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc0204248:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc020424c:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0204250:	02043c23          	sd	zero,56(s0)
}
ffffffffc0204254:	60a2                	ld	ra,8(sp)
ffffffffc0204256:	8522                	mv	a0,s0
ffffffffc0204258:	6402                	ld	s0,0(sp)
ffffffffc020425a:	0141                	addi	sp,sp,16
ffffffffc020425c:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020425e:	a07ff0ef          	jal	ra,ffffffffc0203c64 <swap_init_mm>
ffffffffc0204262:	b7ed                	j	ffffffffc020424c <mm_create+0x30>

ffffffffc0204264 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204264:	1101                	addi	sp,sp,-32
ffffffffc0204266:	e04a                	sd	s2,0(sp)
ffffffffc0204268:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020426a:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020426e:	e822                	sd	s0,16(sp)
ffffffffc0204270:	e426                	sd	s1,8(sp)
ffffffffc0204272:	ec06                	sd	ra,24(sp)
ffffffffc0204274:	84ae                	mv	s1,a1
ffffffffc0204276:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204278:	bb7fd0ef          	jal	ra,ffffffffc0201e2e <kmalloc>
    if (vma != NULL) {
ffffffffc020427c:	c509                	beqz	a0,ffffffffc0204286 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020427e:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204282:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204284:	cd00                	sw	s0,24(a0)
}
ffffffffc0204286:	60e2                	ld	ra,24(sp)
ffffffffc0204288:	6442                	ld	s0,16(sp)
ffffffffc020428a:	64a2                	ld	s1,8(sp)
ffffffffc020428c:	6902                	ld	s2,0(sp)
ffffffffc020428e:	6105                	addi	sp,sp,32
ffffffffc0204290:	8082                	ret

ffffffffc0204292 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0204292:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0204294:	c505                	beqz	a0,ffffffffc02042bc <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0204296:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204298:	c501                	beqz	a0,ffffffffc02042a0 <find_vma+0xe>
ffffffffc020429a:	651c                	ld	a5,8(a0)
ffffffffc020429c:	02f5f263          	bgeu	a1,a5,ffffffffc02042c0 <find_vma+0x2e>
    return listelm->next;
ffffffffc02042a0:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc02042a2:	00f68d63          	beq	a3,a5,ffffffffc02042bc <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02042a6:	fe87b703          	ld	a4,-24(a5)
ffffffffc02042aa:	00e5e663          	bltu	a1,a4,ffffffffc02042b6 <find_vma+0x24>
ffffffffc02042ae:	ff07b703          	ld	a4,-16(a5)
ffffffffc02042b2:	00e5ec63          	bltu	a1,a4,ffffffffc02042ca <find_vma+0x38>
ffffffffc02042b6:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02042b8:	fef697e3          	bne	a3,a5,ffffffffc02042a6 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc02042bc:	4501                	li	a0,0
}
ffffffffc02042be:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02042c0:	691c                	ld	a5,16(a0)
ffffffffc02042c2:	fcf5ffe3          	bgeu	a1,a5,ffffffffc02042a0 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc02042c6:	ea88                	sd	a0,16(a3)
ffffffffc02042c8:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc02042ca:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc02042ce:	ea88                	sd	a0,16(a3)
ffffffffc02042d0:	8082                	ret

ffffffffc02042d2 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02042d2:	6590                	ld	a2,8(a1)
ffffffffc02042d4:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x8ba0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02042d8:	1141                	addi	sp,sp,-16
ffffffffc02042da:	e406                	sd	ra,8(sp)
ffffffffc02042dc:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02042de:	01066763          	bltu	a2,a6,ffffffffc02042ec <insert_vma_struct+0x1a>
ffffffffc02042e2:	a085                	j	ffffffffc0204342 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02042e4:	fe87b703          	ld	a4,-24(a5)
ffffffffc02042e8:	04e66863          	bltu	a2,a4,ffffffffc0204338 <insert_vma_struct+0x66>
ffffffffc02042ec:	86be                	mv	a3,a5
ffffffffc02042ee:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02042f0:	fef51ae3          	bne	a0,a5,ffffffffc02042e4 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02042f4:	02a68463          	beq	a3,a0,ffffffffc020431c <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02042f8:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02042fc:	fe86b883          	ld	a7,-24(a3)
ffffffffc0204300:	08e8f163          	bgeu	a7,a4,ffffffffc0204382 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0204304:	04e66f63          	bltu	a2,a4,ffffffffc0204362 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0204308:	00f50a63          	beq	a0,a5,ffffffffc020431c <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020430c:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0204310:	05076963          	bltu	a4,a6,ffffffffc0204362 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0204314:	ff07b603          	ld	a2,-16(a5)
ffffffffc0204318:	02c77363          	bgeu	a4,a2,ffffffffc020433e <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc020431c:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc020431e:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0204320:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0204324:	e390                	sd	a2,0(a5)
ffffffffc0204326:	e690                	sd	a2,8(a3)
}
ffffffffc0204328:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020432a:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc020432c:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc020432e:	0017079b          	addiw	a5,a4,1
ffffffffc0204332:	d11c                	sw	a5,32(a0)
}
ffffffffc0204334:	0141                	addi	sp,sp,16
ffffffffc0204336:	8082                	ret
    if (le_prev != list) {
ffffffffc0204338:	fca690e3          	bne	a3,a0,ffffffffc02042f8 <insert_vma_struct+0x26>
ffffffffc020433c:	bfd1                	j	ffffffffc0204310 <insert_vma_struct+0x3e>
ffffffffc020433e:	ebbff0ef          	jal	ra,ffffffffc02041f8 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204342:	00004697          	auipc	a3,0x4
ffffffffc0204346:	e2e68693          	addi	a3,a3,-466 # ffffffffc0208170 <default_pmm_manager+0xbb8>
ffffffffc020434a:	00003617          	auipc	a2,0x3
ffffffffc020434e:	a6660613          	addi	a2,a2,-1434 # ffffffffc0206db0 <commands+0x450>
ffffffffc0204352:	07500593          	li	a1,117
ffffffffc0204356:	00004517          	auipc	a0,0x4
ffffffffc020435a:	e0a50513          	addi	a0,a0,-502 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc020435e:	91cfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0204362:	00004697          	auipc	a3,0x4
ffffffffc0204366:	e4e68693          	addi	a3,a3,-434 # ffffffffc02081b0 <default_pmm_manager+0xbf8>
ffffffffc020436a:	00003617          	auipc	a2,0x3
ffffffffc020436e:	a4660613          	addi	a2,a2,-1466 # ffffffffc0206db0 <commands+0x450>
ffffffffc0204372:	06d00593          	li	a1,109
ffffffffc0204376:	00004517          	auipc	a0,0x4
ffffffffc020437a:	dea50513          	addi	a0,a0,-534 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc020437e:	8fcfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0204382:	00004697          	auipc	a3,0x4
ffffffffc0204386:	e0e68693          	addi	a3,a3,-498 # ffffffffc0208190 <default_pmm_manager+0xbd8>
ffffffffc020438a:	00003617          	auipc	a2,0x3
ffffffffc020438e:	a2660613          	addi	a2,a2,-1498 # ffffffffc0206db0 <commands+0x450>
ffffffffc0204392:	06c00593          	li	a1,108
ffffffffc0204396:	00004517          	auipc	a0,0x4
ffffffffc020439a:	dca50513          	addi	a0,a0,-566 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc020439e:	8dcfc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02043a2 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc02043a2:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc02043a4:	1141                	addi	sp,sp,-16
ffffffffc02043a6:	e406                	sd	ra,8(sp)
ffffffffc02043a8:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc02043aa:	e78d                	bnez	a5,ffffffffc02043d4 <mm_destroy+0x32>
ffffffffc02043ac:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02043ae:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02043b0:	00a40c63          	beq	s0,a0,ffffffffc02043c8 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02043b4:	6118                	ld	a4,0(a0)
ffffffffc02043b6:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc02043b8:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02043ba:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02043bc:	e398                	sd	a4,0(a5)
ffffffffc02043be:	b21fd0ef          	jal	ra,ffffffffc0201ede <kfree>
    return listelm->next;
ffffffffc02043c2:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02043c4:	fea418e3          	bne	s0,a0,ffffffffc02043b4 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc02043c8:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02043ca:	6402                	ld	s0,0(sp)
ffffffffc02043cc:	60a2                	ld	ra,8(sp)
ffffffffc02043ce:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc02043d0:	b0ffd06f          	j	ffffffffc0201ede <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02043d4:	00004697          	auipc	a3,0x4
ffffffffc02043d8:	dfc68693          	addi	a3,a3,-516 # ffffffffc02081d0 <default_pmm_manager+0xc18>
ffffffffc02043dc:	00003617          	auipc	a2,0x3
ffffffffc02043e0:	9d460613          	addi	a2,a2,-1580 # ffffffffc0206db0 <commands+0x450>
ffffffffc02043e4:	09500593          	li	a1,149
ffffffffc02043e8:	00004517          	auipc	a0,0x4
ffffffffc02043ec:	d7850513          	addi	a0,a0,-648 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc02043f0:	88afc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02043f4 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc02043f4:	7139                	addi	sp,sp,-64
ffffffffc02043f6:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02043f8:	6405                	lui	s0,0x1
ffffffffc02043fa:	147d                	addi	s0,s0,-1
ffffffffc02043fc:	77fd                	lui	a5,0xfffff
ffffffffc02043fe:	9622                	add	a2,a2,s0
ffffffffc0204400:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc0204402:	f426                	sd	s1,40(sp)
ffffffffc0204404:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204406:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc020440a:	f04a                	sd	s2,32(sp)
ffffffffc020440c:	ec4e                	sd	s3,24(sp)
ffffffffc020440e:	e852                	sd	s4,16(sp)
ffffffffc0204410:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc0204412:	002005b7          	lui	a1,0x200
ffffffffc0204416:	00f67433          	and	s0,a2,a5
ffffffffc020441a:	06b4e363          	bltu	s1,a1,ffffffffc0204480 <mm_map+0x8c>
ffffffffc020441e:	0684f163          	bgeu	s1,s0,ffffffffc0204480 <mm_map+0x8c>
ffffffffc0204422:	4785                	li	a5,1
ffffffffc0204424:	07fe                	slli	a5,a5,0x1f
ffffffffc0204426:	0487ed63          	bltu	a5,s0,ffffffffc0204480 <mm_map+0x8c>
ffffffffc020442a:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc020442c:	cd21                	beqz	a0,ffffffffc0204484 <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc020442e:	85a6                	mv	a1,s1
ffffffffc0204430:	8ab6                	mv	s5,a3
ffffffffc0204432:	8a3a                	mv	s4,a4
ffffffffc0204434:	e5fff0ef          	jal	ra,ffffffffc0204292 <find_vma>
ffffffffc0204438:	c501                	beqz	a0,ffffffffc0204440 <mm_map+0x4c>
ffffffffc020443a:	651c                	ld	a5,8(a0)
ffffffffc020443c:	0487e263          	bltu	a5,s0,ffffffffc0204480 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204440:	03000513          	li	a0,48
ffffffffc0204444:	9ebfd0ef          	jal	ra,ffffffffc0201e2e <kmalloc>
ffffffffc0204448:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc020444a:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc020444c:	02090163          	beqz	s2,ffffffffc020446e <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0204450:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0204452:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0204456:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc020445a:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc020445e:	85ca                	mv	a1,s2
ffffffffc0204460:	e73ff0ef          	jal	ra,ffffffffc02042d2 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0204464:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0204466:	000a0463          	beqz	s4,ffffffffc020446e <mm_map+0x7a>
        *vma_store = vma;
ffffffffc020446a:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc020446e:	70e2                	ld	ra,56(sp)
ffffffffc0204470:	7442                	ld	s0,48(sp)
ffffffffc0204472:	74a2                	ld	s1,40(sp)
ffffffffc0204474:	7902                	ld	s2,32(sp)
ffffffffc0204476:	69e2                	ld	s3,24(sp)
ffffffffc0204478:	6a42                	ld	s4,16(sp)
ffffffffc020447a:	6aa2                	ld	s5,8(sp)
ffffffffc020447c:	6121                	addi	sp,sp,64
ffffffffc020447e:	8082                	ret
        return -E_INVAL;
ffffffffc0204480:	5575                	li	a0,-3
ffffffffc0204482:	b7f5                	j	ffffffffc020446e <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc0204484:	00003697          	auipc	a3,0x3
ffffffffc0204488:	7c468693          	addi	a3,a3,1988 # ffffffffc0207c48 <default_pmm_manager+0x690>
ffffffffc020448c:	00003617          	auipc	a2,0x3
ffffffffc0204490:	92460613          	addi	a2,a2,-1756 # ffffffffc0206db0 <commands+0x450>
ffffffffc0204494:	0a800593          	li	a1,168
ffffffffc0204498:	00004517          	auipc	a0,0x4
ffffffffc020449c:	cc850513          	addi	a0,a0,-824 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc02044a0:	fdbfb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02044a4 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc02044a4:	7139                	addi	sp,sp,-64
ffffffffc02044a6:	fc06                	sd	ra,56(sp)
ffffffffc02044a8:	f822                	sd	s0,48(sp)
ffffffffc02044aa:	f426                	sd	s1,40(sp)
ffffffffc02044ac:	f04a                	sd	s2,32(sp)
ffffffffc02044ae:	ec4e                	sd	s3,24(sp)
ffffffffc02044b0:	e852                	sd	s4,16(sp)
ffffffffc02044b2:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc02044b4:	c52d                	beqz	a0,ffffffffc020451e <dup_mmap+0x7a>
ffffffffc02044b6:	892a                	mv	s2,a0
ffffffffc02044b8:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02044ba:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02044bc:	e595                	bnez	a1,ffffffffc02044e8 <dup_mmap+0x44>
ffffffffc02044be:	a085                	j	ffffffffc020451e <dup_mmap+0x7a>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02044c0:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc02044c2:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ee0>
        vma->vm_end = vm_end;
ffffffffc02044c6:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc02044ca:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc02044ce:	e05ff0ef          	jal	ra,ffffffffc02042d2 <insert_vma_struct>

        bool share = 0;
        //if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) return -E_NO_MEM;
        if (shared_read_state(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) return -E_NO_MEM;
ffffffffc02044d2:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc02044d6:	fe843603          	ld	a2,-24(s0)
ffffffffc02044da:	6c8c                	ld	a1,24(s1)
ffffffffc02044dc:	01893503          	ld	a0,24(s2)
ffffffffc02044e0:	4701                	li	a4,0
ffffffffc02044e2:	941fc0ef          	jal	ra,ffffffffc0200e22 <shared_read_state>
ffffffffc02044e6:	e105                	bnez	a0,ffffffffc0204506 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc02044e8:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc02044ea:	02848863          	beq	s1,s0,ffffffffc020451a <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044ee:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02044f2:	fe843a83          	ld	s5,-24(s0)
ffffffffc02044f6:	ff043a03          	ld	s4,-16(s0)
ffffffffc02044fa:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044fe:	931fd0ef          	jal	ra,ffffffffc0201e2e <kmalloc>
ffffffffc0204502:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc0204504:	fd55                	bnez	a0,ffffffffc02044c0 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0204506:	5571                	li	a0,-4
    }
    return 0;
}
ffffffffc0204508:	70e2                	ld	ra,56(sp)
ffffffffc020450a:	7442                	ld	s0,48(sp)
ffffffffc020450c:	74a2                	ld	s1,40(sp)
ffffffffc020450e:	7902                	ld	s2,32(sp)
ffffffffc0204510:	69e2                	ld	s3,24(sp)
ffffffffc0204512:	6a42                	ld	s4,16(sp)
ffffffffc0204514:	6aa2                	ld	s5,8(sp)
ffffffffc0204516:	6121                	addi	sp,sp,64
ffffffffc0204518:	8082                	ret
    return 0;
ffffffffc020451a:	4501                	li	a0,0
ffffffffc020451c:	b7f5                	j	ffffffffc0204508 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc020451e:	00004697          	auipc	a3,0x4
ffffffffc0204522:	cca68693          	addi	a3,a3,-822 # ffffffffc02081e8 <default_pmm_manager+0xc30>
ffffffffc0204526:	00003617          	auipc	a2,0x3
ffffffffc020452a:	88a60613          	addi	a2,a2,-1910 # ffffffffc0206db0 <commands+0x450>
ffffffffc020452e:	0c100593          	li	a1,193
ffffffffc0204532:	00004517          	auipc	a0,0x4
ffffffffc0204536:	c2e50513          	addi	a0,a0,-978 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc020453a:	f41fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020453e <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc020453e:	1101                	addi	sp,sp,-32
ffffffffc0204540:	ec06                	sd	ra,24(sp)
ffffffffc0204542:	e822                	sd	s0,16(sp)
ffffffffc0204544:	e426                	sd	s1,8(sp)
ffffffffc0204546:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204548:	c531                	beqz	a0,ffffffffc0204594 <exit_mmap+0x56>
ffffffffc020454a:	591c                	lw	a5,48(a0)
ffffffffc020454c:	84aa                	mv	s1,a0
ffffffffc020454e:	e3b9                	bnez	a5,ffffffffc0204594 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0204550:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir; // 获取进程页表
ffffffffc0204552:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) { // 遍历 mm->mmap_list 链表
ffffffffc0204556:	02850663          	beq	a0,s0,ffffffffc0204582 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end); // 解除该内存区域在页目录中的映射关系。这一步将虚拟地址范围从物理内存中解绑，释放相应的资源。
ffffffffc020455a:	ff043603          	ld	a2,-16(s0)
ffffffffc020455e:	fe843583          	ld	a1,-24(s0)
ffffffffc0204562:	854a                	mv	a0,s2
ffffffffc0204564:	ddbfd0ef          	jal	ra,ffffffffc020233e <unmap_range>
ffffffffc0204568:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) { // 遍历 mm->mmap_list 链表
ffffffffc020456a:	fe8498e3          	bne	s1,s0,ffffffffc020455a <exit_mmap+0x1c>
ffffffffc020456e:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) { // 再次遍历 mm->mmap_list 链表。
ffffffffc0204570:	00848c63          	beq	s1,s0,ffffffffc0204588 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end); // 释放和清理指定虚拟地址范围内的页表和页目录，从而回收内存资源。
ffffffffc0204574:	ff043603          	ld	a2,-16(s0)
ffffffffc0204578:	fe843583          	ld	a1,-24(s0)
ffffffffc020457c:	854a                	mv	a0,s2
ffffffffc020457e:	f07fd0ef          	jal	ra,ffffffffc0202484 <exit_range>
ffffffffc0204582:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) { // 再次遍历 mm->mmap_list 链表。
ffffffffc0204584:	fe8498e3          	bne	s1,s0,ffffffffc0204574 <exit_mmap+0x36>
    }
}
ffffffffc0204588:	60e2                	ld	ra,24(sp)
ffffffffc020458a:	6442                	ld	s0,16(sp)
ffffffffc020458c:	64a2                	ld	s1,8(sp)
ffffffffc020458e:	6902                	ld	s2,0(sp)
ffffffffc0204590:	6105                	addi	sp,sp,32
ffffffffc0204592:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204594:	00004697          	auipc	a3,0x4
ffffffffc0204598:	c7468693          	addi	a3,a3,-908 # ffffffffc0208208 <default_pmm_manager+0xc50>
ffffffffc020459c:	00003617          	auipc	a2,0x3
ffffffffc02045a0:	81460613          	addi	a2,a2,-2028 # ffffffffc0206db0 <commands+0x450>
ffffffffc02045a4:	0d600593          	li	a1,214
ffffffffc02045a8:	00004517          	auipc	a0,0x4
ffffffffc02045ac:	bb850513          	addi	a0,a0,-1096 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc02045b0:	ecbfb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02045b4 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02045b4:	7139                	addi	sp,sp,-64
ffffffffc02045b6:	f822                	sd	s0,48(sp)
ffffffffc02045b8:	f426                	sd	s1,40(sp)
ffffffffc02045ba:	fc06                	sd	ra,56(sp)
ffffffffc02045bc:	f04a                	sd	s2,32(sp)
ffffffffc02045be:	ec4e                	sd	s3,24(sp)
ffffffffc02045c0:	e852                	sd	s4,16(sp)
ffffffffc02045c2:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc02045c4:	c59ff0ef          	jal	ra,ffffffffc020421c <mm_create>
    assert(mm != NULL);
ffffffffc02045c8:	84aa                	mv	s1,a0
ffffffffc02045ca:	03200413          	li	s0,50
ffffffffc02045ce:	e919                	bnez	a0,ffffffffc02045e4 <vmm_init+0x30>
ffffffffc02045d0:	a991                	j	ffffffffc0204a24 <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc02045d2:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02045d4:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02045d6:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc02045da:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02045dc:	8526                	mv	a0,s1
ffffffffc02045de:	cf5ff0ef          	jal	ra,ffffffffc02042d2 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02045e2:	c80d                	beqz	s0,ffffffffc0204614 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02045e4:	03000513          	li	a0,48
ffffffffc02045e8:	847fd0ef          	jal	ra,ffffffffc0201e2e <kmalloc>
ffffffffc02045ec:	85aa                	mv	a1,a0
ffffffffc02045ee:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02045f2:	f165                	bnez	a0,ffffffffc02045d2 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc02045f4:	00003697          	auipc	a3,0x3
ffffffffc02045f8:	68c68693          	addi	a3,a3,1676 # ffffffffc0207c80 <default_pmm_manager+0x6c8>
ffffffffc02045fc:	00002617          	auipc	a2,0x2
ffffffffc0204600:	7b460613          	addi	a2,a2,1972 # ffffffffc0206db0 <commands+0x450>
ffffffffc0204604:	11300593          	li	a1,275
ffffffffc0204608:	00004517          	auipc	a0,0x4
ffffffffc020460c:	b5850513          	addi	a0,a0,-1192 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc0204610:	e6bfb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204614:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0204618:	1f900913          	li	s2,505
ffffffffc020461c:	a819                	j	ffffffffc0204632 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc020461e:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204620:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204622:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0204626:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204628:	8526                	mv	a0,s1
ffffffffc020462a:	ca9ff0ef          	jal	ra,ffffffffc02042d2 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020462e:	03240a63          	beq	s0,s2,ffffffffc0204662 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204632:	03000513          	li	a0,48
ffffffffc0204636:	ff8fd0ef          	jal	ra,ffffffffc0201e2e <kmalloc>
ffffffffc020463a:	85aa                	mv	a1,a0
ffffffffc020463c:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0204640:	fd79                	bnez	a0,ffffffffc020461e <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0204642:	00003697          	auipc	a3,0x3
ffffffffc0204646:	63e68693          	addi	a3,a3,1598 # ffffffffc0207c80 <default_pmm_manager+0x6c8>
ffffffffc020464a:	00002617          	auipc	a2,0x2
ffffffffc020464e:	76660613          	addi	a2,a2,1894 # ffffffffc0206db0 <commands+0x450>
ffffffffc0204652:	11900593          	li	a1,281
ffffffffc0204656:	00004517          	auipc	a0,0x4
ffffffffc020465a:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc020465e:	e1dfb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204662:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc0204664:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc0204666:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc020466a:	2cf48d63          	beq	s1,a5,ffffffffc0204944 <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020466e:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd4c744>
ffffffffc0204672:	ffe70613          	addi	a2,a4,-2
ffffffffc0204676:	24d61763          	bne	a2,a3,ffffffffc02048c4 <vmm_init+0x310>
ffffffffc020467a:	ff07b683          	ld	a3,-16(a5)
ffffffffc020467e:	24e69363          	bne	a3,a4,ffffffffc02048c4 <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc0204682:	0715                	addi	a4,a4,5
ffffffffc0204684:	679c                	ld	a5,8(a5)
ffffffffc0204686:	feb712e3          	bne	a4,a1,ffffffffc020466a <vmm_init+0xb6>
ffffffffc020468a:	4a1d                	li	s4,7
ffffffffc020468c:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020468e:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0204692:	85a2                	mv	a1,s0
ffffffffc0204694:	8526                	mv	a0,s1
ffffffffc0204696:	bfdff0ef          	jal	ra,ffffffffc0204292 <find_vma>
ffffffffc020469a:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc020469c:	30050463          	beqz	a0,ffffffffc02049a4 <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02046a0:	00140593          	addi	a1,s0,1
ffffffffc02046a4:	8526                	mv	a0,s1
ffffffffc02046a6:	bedff0ef          	jal	ra,ffffffffc0204292 <find_vma>
ffffffffc02046aa:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc02046ac:	2c050c63          	beqz	a0,ffffffffc0204984 <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02046b0:	85d2                	mv	a1,s4
ffffffffc02046b2:	8526                	mv	a0,s1
ffffffffc02046b4:	bdfff0ef          	jal	ra,ffffffffc0204292 <find_vma>
        assert(vma3 == NULL);
ffffffffc02046b8:	2a051663          	bnez	a0,ffffffffc0204964 <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02046bc:	00340593          	addi	a1,s0,3
ffffffffc02046c0:	8526                	mv	a0,s1
ffffffffc02046c2:	bd1ff0ef          	jal	ra,ffffffffc0204292 <find_vma>
        assert(vma4 == NULL);
ffffffffc02046c6:	30051f63          	bnez	a0,ffffffffc02049e4 <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02046ca:	00440593          	addi	a1,s0,4
ffffffffc02046ce:	8526                	mv	a0,s1
ffffffffc02046d0:	bc3ff0ef          	jal	ra,ffffffffc0204292 <find_vma>
        assert(vma5 == NULL);
ffffffffc02046d4:	2e051863          	bnez	a0,ffffffffc02049c4 <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02046d8:	00893783          	ld	a5,8(s2)
ffffffffc02046dc:	20879463          	bne	a5,s0,ffffffffc02048e4 <vmm_init+0x330>
ffffffffc02046e0:	01093783          	ld	a5,16(s2)
ffffffffc02046e4:	20fa1063          	bne	s4,a5,ffffffffc02048e4 <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02046e8:	0089b783          	ld	a5,8(s3)
ffffffffc02046ec:	20879c63          	bne	a5,s0,ffffffffc0204904 <vmm_init+0x350>
ffffffffc02046f0:	0109b783          	ld	a5,16(s3)
ffffffffc02046f4:	20fa1863          	bne	s4,a5,ffffffffc0204904 <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02046f8:	0415                	addi	s0,s0,5
ffffffffc02046fa:	0a15                	addi	s4,s4,5
ffffffffc02046fc:	f9541be3          	bne	s0,s5,ffffffffc0204692 <vmm_init+0xde>
ffffffffc0204700:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0204702:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0204704:	85a2                	mv	a1,s0
ffffffffc0204706:	8526                	mv	a0,s1
ffffffffc0204708:	b8bff0ef          	jal	ra,ffffffffc0204292 <find_vma>
ffffffffc020470c:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0204710:	c90d                	beqz	a0,ffffffffc0204742 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0204712:	6914                	ld	a3,16(a0)
ffffffffc0204714:	6510                	ld	a2,8(a0)
ffffffffc0204716:	00004517          	auipc	a0,0x4
ffffffffc020471a:	c1250513          	addi	a0,a0,-1006 # ffffffffc0208328 <default_pmm_manager+0xd70>
ffffffffc020471e:	a63fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0204722:	00004697          	auipc	a3,0x4
ffffffffc0204726:	c2e68693          	addi	a3,a3,-978 # ffffffffc0208350 <default_pmm_manager+0xd98>
ffffffffc020472a:	00002617          	auipc	a2,0x2
ffffffffc020472e:	68660613          	addi	a2,a2,1670 # ffffffffc0206db0 <commands+0x450>
ffffffffc0204732:	13b00593          	li	a1,315
ffffffffc0204736:	00004517          	auipc	a0,0x4
ffffffffc020473a:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc020473e:	d3dfb0ef          	jal	ra,ffffffffc020047a <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0204742:	147d                	addi	s0,s0,-1
ffffffffc0204744:	fd2410e3          	bne	s0,s2,ffffffffc0204704 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0204748:	8526                	mv	a0,s1
ffffffffc020474a:	c59ff0ef          	jal	ra,ffffffffc02043a2 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020474e:	00004517          	auipc	a0,0x4
ffffffffc0204752:	c1a50513          	addi	a0,a0,-998 # ffffffffc0208368 <default_pmm_manager+0xdb0>
ffffffffc0204756:	a2bfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020475a:	985fd0ef          	jal	ra,ffffffffc02020de <nr_free_pages>
ffffffffc020475e:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc0204760:	abdff0ef          	jal	ra,ffffffffc020421c <mm_create>
ffffffffc0204764:	000ae797          	auipc	a5,0xae
ffffffffc0204768:	10a7ba23          	sd	a0,276(a5) # ffffffffc02b2878 <check_mm_struct>
ffffffffc020476c:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc020476e:	28050b63          	beqz	a0,ffffffffc0204a04 <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204772:	000ae497          	auipc	s1,0xae
ffffffffc0204776:	0c64b483          	ld	s1,198(s1) # ffffffffc02b2838 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc020477a:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020477c:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc020477e:	2e079f63          	bnez	a5,ffffffffc0204a7c <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204782:	03000513          	li	a0,48
ffffffffc0204786:	ea8fd0ef          	jal	ra,ffffffffc0201e2e <kmalloc>
ffffffffc020478a:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc020478c:	18050c63          	beqz	a0,ffffffffc0204924 <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc0204790:	002007b7          	lui	a5,0x200
ffffffffc0204794:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc0204798:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020479a:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc020479c:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc02047a0:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02047a2:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc02047a6:	b2dff0ef          	jal	ra,ffffffffc02042d2 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02047aa:	10000593          	li	a1,256
ffffffffc02047ae:	8522                	mv	a0,s0
ffffffffc02047b0:	ae3ff0ef          	jal	ra,ffffffffc0204292 <find_vma>
ffffffffc02047b4:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc02047b8:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02047bc:	2ea99063          	bne	s3,a0,ffffffffc0204a9c <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc02047c0:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f4ed8>
    for (i = 0; i < 100; i ++) {
ffffffffc02047c4:	0785                	addi	a5,a5,1
ffffffffc02047c6:	fee79de3          	bne	a5,a4,ffffffffc02047c0 <vmm_init+0x20c>
        sum += i;
ffffffffc02047ca:	6705                	lui	a4,0x1
ffffffffc02047cc:	10000793          	li	a5,256
ffffffffc02047d0:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x885a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02047d4:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02047d8:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc02047dc:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc02047de:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02047e0:	fec79ce3          	bne	a5,a2,ffffffffc02047d8 <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc02047e4:	2e071863          	bnez	a4,ffffffffc0204ad4 <vmm_init+0x520>
    return pa2page(PDE_ADDR(pde));
ffffffffc02047e8:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02047ea:	000aea97          	auipc	s5,0xae
ffffffffc02047ee:	056a8a93          	addi	s5,s5,86 # ffffffffc02b2840 <npage>
ffffffffc02047f2:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02047f6:	078a                	slli	a5,a5,0x2
ffffffffc02047f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02047fa:	2cc7f163          	bgeu	a5,a2,ffffffffc0204abc <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc02047fe:	00004a17          	auipc	s4,0x4
ffffffffc0204802:	64aa3a03          	ld	s4,1610(s4) # ffffffffc0208e48 <nbase>
ffffffffc0204806:	414787b3          	sub	a5,a5,s4
ffffffffc020480a:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc020480c:	8799                	srai	a5,a5,0x6
ffffffffc020480e:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0204810:	00c79713          	slli	a4,a5,0xc
ffffffffc0204814:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204816:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020481a:	24c77563          	bgeu	a4,a2,ffffffffc0204a64 <vmm_init+0x4b0>
ffffffffc020481e:	000ae997          	auipc	s3,0xae
ffffffffc0204822:	03a9b983          	ld	s3,58(s3) # ffffffffc02b2858 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0204826:	4581                	li	a1,0
ffffffffc0204828:	8526                	mv	a0,s1
ffffffffc020482a:	99b6                	add	s3,s3,a3
ffffffffc020482c:	eebfd0ef          	jal	ra,ffffffffc0202716 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204830:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0204834:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204838:	078a                	slli	a5,a5,0x2
ffffffffc020483a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020483c:	28e7f063          	bgeu	a5,a4,ffffffffc0204abc <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0204840:	000ae997          	auipc	s3,0xae
ffffffffc0204844:	00898993          	addi	s3,s3,8 # ffffffffc02b2848 <pages>
ffffffffc0204848:	0009b503          	ld	a0,0(s3)
ffffffffc020484c:	414787b3          	sub	a5,a5,s4
ffffffffc0204850:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0204852:	953e                	add	a0,a0,a5
ffffffffc0204854:	4585                	li	a1,1
ffffffffc0204856:	849fd0ef          	jal	ra,ffffffffc020209e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020485a:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc020485c:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204860:	078a                	slli	a5,a5,0x2
ffffffffc0204862:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204864:	24e7fc63          	bgeu	a5,a4,ffffffffc0204abc <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0204868:	0009b503          	ld	a0,0(s3)
ffffffffc020486c:	414787b3          	sub	a5,a5,s4
ffffffffc0204870:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0204872:	4585                	li	a1,1
ffffffffc0204874:	953e                	add	a0,a0,a5
ffffffffc0204876:	829fd0ef          	jal	ra,ffffffffc020209e <free_pages>
    pgdir[0] = 0;
ffffffffc020487a:	0004b023          	sd	zero,0(s1)
  asm volatile("sfence.vma");
ffffffffc020487e:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc0204882:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0204884:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0204888:	b1bff0ef          	jal	ra,ffffffffc02043a2 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc020488c:	000ae797          	auipc	a5,0xae
ffffffffc0204890:	fe07b623          	sd	zero,-20(a5) # ffffffffc02b2878 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204894:	84bfd0ef          	jal	ra,ffffffffc02020de <nr_free_pages>
ffffffffc0204898:	1aa91663          	bne	s2,a0,ffffffffc0204a44 <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020489c:	00004517          	auipc	a0,0x4
ffffffffc02048a0:	b5c50513          	addi	a0,a0,-1188 # ffffffffc02083f8 <default_pmm_manager+0xe40>
ffffffffc02048a4:	8ddfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc02048a8:	7442                	ld	s0,48(sp)
ffffffffc02048aa:	70e2                	ld	ra,56(sp)
ffffffffc02048ac:	74a2                	ld	s1,40(sp)
ffffffffc02048ae:	7902                	ld	s2,32(sp)
ffffffffc02048b0:	69e2                	ld	s3,24(sp)
ffffffffc02048b2:	6a42                	ld	s4,16(sp)
ffffffffc02048b4:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02048b6:	00004517          	auipc	a0,0x4
ffffffffc02048ba:	b6250513          	addi	a0,a0,-1182 # ffffffffc0208418 <default_pmm_manager+0xe60>
}
ffffffffc02048be:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02048c0:	8c1fb06f          	j	ffffffffc0200180 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02048c4:	00004697          	auipc	a3,0x4
ffffffffc02048c8:	97c68693          	addi	a3,a3,-1668 # ffffffffc0208240 <default_pmm_manager+0xc88>
ffffffffc02048cc:	00002617          	auipc	a2,0x2
ffffffffc02048d0:	4e460613          	addi	a2,a2,1252 # ffffffffc0206db0 <commands+0x450>
ffffffffc02048d4:	12200593          	li	a1,290
ffffffffc02048d8:	00004517          	auipc	a0,0x4
ffffffffc02048dc:	88850513          	addi	a0,a0,-1912 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc02048e0:	b9bfb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02048e4:	00004697          	auipc	a3,0x4
ffffffffc02048e8:	9e468693          	addi	a3,a3,-1564 # ffffffffc02082c8 <default_pmm_manager+0xd10>
ffffffffc02048ec:	00002617          	auipc	a2,0x2
ffffffffc02048f0:	4c460613          	addi	a2,a2,1220 # ffffffffc0206db0 <commands+0x450>
ffffffffc02048f4:	13200593          	li	a1,306
ffffffffc02048f8:	00004517          	auipc	a0,0x4
ffffffffc02048fc:	86850513          	addi	a0,a0,-1944 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc0204900:	b7bfb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0204904:	00004697          	auipc	a3,0x4
ffffffffc0204908:	9f468693          	addi	a3,a3,-1548 # ffffffffc02082f8 <default_pmm_manager+0xd40>
ffffffffc020490c:	00002617          	auipc	a2,0x2
ffffffffc0204910:	4a460613          	addi	a2,a2,1188 # ffffffffc0206db0 <commands+0x450>
ffffffffc0204914:	13300593          	li	a1,307
ffffffffc0204918:	00004517          	auipc	a0,0x4
ffffffffc020491c:	84850513          	addi	a0,a0,-1976 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc0204920:	b5bfb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(vma != NULL);
ffffffffc0204924:	00003697          	auipc	a3,0x3
ffffffffc0204928:	35c68693          	addi	a3,a3,860 # ffffffffc0207c80 <default_pmm_manager+0x6c8>
ffffffffc020492c:	00002617          	auipc	a2,0x2
ffffffffc0204930:	48460613          	addi	a2,a2,1156 # ffffffffc0206db0 <commands+0x450>
ffffffffc0204934:	15200593          	li	a1,338
ffffffffc0204938:	00004517          	auipc	a0,0x4
ffffffffc020493c:	82850513          	addi	a0,a0,-2008 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc0204940:	b3bfb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0204944:	00004697          	auipc	a3,0x4
ffffffffc0204948:	8e468693          	addi	a3,a3,-1820 # ffffffffc0208228 <default_pmm_manager+0xc70>
ffffffffc020494c:	00002617          	auipc	a2,0x2
ffffffffc0204950:	46460613          	addi	a2,a2,1124 # ffffffffc0206db0 <commands+0x450>
ffffffffc0204954:	12000593          	li	a1,288
ffffffffc0204958:	00004517          	auipc	a0,0x4
ffffffffc020495c:	80850513          	addi	a0,a0,-2040 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc0204960:	b1bfb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma3 == NULL);
ffffffffc0204964:	00004697          	auipc	a3,0x4
ffffffffc0204968:	93468693          	addi	a3,a3,-1740 # ffffffffc0208298 <default_pmm_manager+0xce0>
ffffffffc020496c:	00002617          	auipc	a2,0x2
ffffffffc0204970:	44460613          	addi	a2,a2,1092 # ffffffffc0206db0 <commands+0x450>
ffffffffc0204974:	12c00593          	li	a1,300
ffffffffc0204978:	00003517          	auipc	a0,0x3
ffffffffc020497c:	7e850513          	addi	a0,a0,2024 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc0204980:	afbfb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma2 != NULL);
ffffffffc0204984:	00004697          	auipc	a3,0x4
ffffffffc0204988:	90468693          	addi	a3,a3,-1788 # ffffffffc0208288 <default_pmm_manager+0xcd0>
ffffffffc020498c:	00002617          	auipc	a2,0x2
ffffffffc0204990:	42460613          	addi	a2,a2,1060 # ffffffffc0206db0 <commands+0x450>
ffffffffc0204994:	12a00593          	li	a1,298
ffffffffc0204998:	00003517          	auipc	a0,0x3
ffffffffc020499c:	7c850513          	addi	a0,a0,1992 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc02049a0:	adbfb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma1 != NULL);
ffffffffc02049a4:	00004697          	auipc	a3,0x4
ffffffffc02049a8:	8d468693          	addi	a3,a3,-1836 # ffffffffc0208278 <default_pmm_manager+0xcc0>
ffffffffc02049ac:	00002617          	auipc	a2,0x2
ffffffffc02049b0:	40460613          	addi	a2,a2,1028 # ffffffffc0206db0 <commands+0x450>
ffffffffc02049b4:	12800593          	li	a1,296
ffffffffc02049b8:	00003517          	auipc	a0,0x3
ffffffffc02049bc:	7a850513          	addi	a0,a0,1960 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc02049c0:	abbfb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma5 == NULL);
ffffffffc02049c4:	00004697          	auipc	a3,0x4
ffffffffc02049c8:	8f468693          	addi	a3,a3,-1804 # ffffffffc02082b8 <default_pmm_manager+0xd00>
ffffffffc02049cc:	00002617          	auipc	a2,0x2
ffffffffc02049d0:	3e460613          	addi	a2,a2,996 # ffffffffc0206db0 <commands+0x450>
ffffffffc02049d4:	13000593          	li	a1,304
ffffffffc02049d8:	00003517          	auipc	a0,0x3
ffffffffc02049dc:	78850513          	addi	a0,a0,1928 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc02049e0:	a9bfb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma4 == NULL);
ffffffffc02049e4:	00004697          	auipc	a3,0x4
ffffffffc02049e8:	8c468693          	addi	a3,a3,-1852 # ffffffffc02082a8 <default_pmm_manager+0xcf0>
ffffffffc02049ec:	00002617          	auipc	a2,0x2
ffffffffc02049f0:	3c460613          	addi	a2,a2,964 # ffffffffc0206db0 <commands+0x450>
ffffffffc02049f4:	12e00593          	li	a1,302
ffffffffc02049f8:	00003517          	auipc	a0,0x3
ffffffffc02049fc:	76850513          	addi	a0,a0,1896 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc0204a00:	a7bfb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0204a04:	00004697          	auipc	a3,0x4
ffffffffc0204a08:	98468693          	addi	a3,a3,-1660 # ffffffffc0208388 <default_pmm_manager+0xdd0>
ffffffffc0204a0c:	00002617          	auipc	a2,0x2
ffffffffc0204a10:	3a460613          	addi	a2,a2,932 # ffffffffc0206db0 <commands+0x450>
ffffffffc0204a14:	14b00593          	li	a1,331
ffffffffc0204a18:	00003517          	auipc	a0,0x3
ffffffffc0204a1c:	74850513          	addi	a0,a0,1864 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc0204a20:	a5bfb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(mm != NULL);
ffffffffc0204a24:	00003697          	auipc	a3,0x3
ffffffffc0204a28:	22468693          	addi	a3,a3,548 # ffffffffc0207c48 <default_pmm_manager+0x690>
ffffffffc0204a2c:	00002617          	auipc	a2,0x2
ffffffffc0204a30:	38460613          	addi	a2,a2,900 # ffffffffc0206db0 <commands+0x450>
ffffffffc0204a34:	10c00593          	li	a1,268
ffffffffc0204a38:	00003517          	auipc	a0,0x3
ffffffffc0204a3c:	72850513          	addi	a0,a0,1832 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc0204a40:	a3bfb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204a44:	00004697          	auipc	a3,0x4
ffffffffc0204a48:	98c68693          	addi	a3,a3,-1652 # ffffffffc02083d0 <default_pmm_manager+0xe18>
ffffffffc0204a4c:	00002617          	auipc	a2,0x2
ffffffffc0204a50:	36460613          	addi	a2,a2,868 # ffffffffc0206db0 <commands+0x450>
ffffffffc0204a54:	17000593          	li	a1,368
ffffffffc0204a58:	00003517          	auipc	a0,0x3
ffffffffc0204a5c:	70850513          	addi	a0,a0,1800 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc0204a60:	a1bfb0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0204a64:	00002617          	auipc	a2,0x2
ffffffffc0204a68:	78460613          	addi	a2,a2,1924 # ffffffffc02071e8 <commands+0x888>
ffffffffc0204a6c:	06900593          	li	a1,105
ffffffffc0204a70:	00002517          	auipc	a0,0x2
ffffffffc0204a74:	6e050513          	addi	a0,a0,1760 # ffffffffc0207150 <commands+0x7f0>
ffffffffc0204a78:	a03fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204a7c:	00003697          	auipc	a3,0x3
ffffffffc0204a80:	1f468693          	addi	a3,a3,500 # ffffffffc0207c70 <default_pmm_manager+0x6b8>
ffffffffc0204a84:	00002617          	auipc	a2,0x2
ffffffffc0204a88:	32c60613          	addi	a2,a2,812 # ffffffffc0206db0 <commands+0x450>
ffffffffc0204a8c:	14f00593          	li	a1,335
ffffffffc0204a90:	00003517          	auipc	a0,0x3
ffffffffc0204a94:	6d050513          	addi	a0,a0,1744 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc0204a98:	9e3fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204a9c:	00004697          	auipc	a3,0x4
ffffffffc0204aa0:	90468693          	addi	a3,a3,-1788 # ffffffffc02083a0 <default_pmm_manager+0xde8>
ffffffffc0204aa4:	00002617          	auipc	a2,0x2
ffffffffc0204aa8:	30c60613          	addi	a2,a2,780 # ffffffffc0206db0 <commands+0x450>
ffffffffc0204aac:	15700593          	li	a1,343
ffffffffc0204ab0:	00003517          	auipc	a0,0x3
ffffffffc0204ab4:	6b050513          	addi	a0,a0,1712 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc0204ab8:	9c3fb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204abc:	00002617          	auipc	a2,0x2
ffffffffc0204ac0:	6a460613          	addi	a2,a2,1700 # ffffffffc0207160 <commands+0x800>
ffffffffc0204ac4:	06200593          	li	a1,98
ffffffffc0204ac8:	00002517          	auipc	a0,0x2
ffffffffc0204acc:	68850513          	addi	a0,a0,1672 # ffffffffc0207150 <commands+0x7f0>
ffffffffc0204ad0:	9abfb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(sum == 0);
ffffffffc0204ad4:	00004697          	auipc	a3,0x4
ffffffffc0204ad8:	8ec68693          	addi	a3,a3,-1812 # ffffffffc02083c0 <default_pmm_manager+0xe08>
ffffffffc0204adc:	00002617          	auipc	a2,0x2
ffffffffc0204ae0:	2d460613          	addi	a2,a2,724 # ffffffffc0206db0 <commands+0x450>
ffffffffc0204ae4:	16300593          	li	a1,355
ffffffffc0204ae8:	00003517          	auipc	a0,0x3
ffffffffc0204aec:	67850513          	addi	a0,a0,1656 # ffffffffc0208160 <default_pmm_manager+0xba8>
ffffffffc0204af0:	98bfb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204af4 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204af4:	7139                	addi	sp,sp,-64
ffffffffc0204af6:	f04a                	sd	s2,32(sp)
ffffffffc0204af8:	892e                	mv	s2,a1
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204afa:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204afc:	f822                	sd	s0,48(sp)
ffffffffc0204afe:	f426                	sd	s1,40(sp)
ffffffffc0204b00:	fc06                	sd	ra,56(sp)
ffffffffc0204b02:	ec4e                	sd	s3,24(sp)
ffffffffc0204b04:	8432                	mv	s0,a2
ffffffffc0204b06:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204b08:	f8aff0ef          	jal	ra,ffffffffc0204292 <find_vma>

    pgfault_num++;
ffffffffc0204b0c:	000ae797          	auipc	a5,0xae
ffffffffc0204b10:	d747a783          	lw	a5,-652(a5) # ffffffffc02b2880 <pgfault_num>
ffffffffc0204b14:	2785                	addiw	a5,a5,1
ffffffffc0204b16:	000ae717          	auipc	a4,0xae
ffffffffc0204b1a:	d6f72523          	sw	a5,-662(a4) # ffffffffc02b2880 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0204b1e:	c94d                	beqz	a0,ffffffffc0204bd0 <do_pgfault+0xdc>
ffffffffc0204b20:	651c                	ld	a5,8(a0)
ffffffffc0204b22:	0af46763          	bltu	s0,a5,ffffffffc0204bd0 <do_pgfault+0xdc>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204b26:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0204b28:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204b2a:	8b89                	andi	a5,a5,2
ffffffffc0204b2c:	e7ad                	bnez	a5,ffffffffc0204b96 <do_pgfault+0xa2>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204b2e:	767d                	lui	a2,0xfffff
    ret = -E_NO_MEM;

    pte_t *ptep=NULL;

    // COW
    if ((ptep = get_pte(mm->pgdir, addr, 0)) != NULL) 
ffffffffc0204b30:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204b32:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 0)) != NULL) 
ffffffffc0204b34:	85a2                	mv	a1,s0
ffffffffc0204b36:	4601                	li	a2,0
ffffffffc0204b38:	de0fd0ef          	jal	ra,ffffffffc0202118 <get_pte>
ffffffffc0204b3c:	c501                	beqz	a0,ffffffffc0204b44 <do_pgfault+0x50>
    {
        if((*ptep & PTE_V) & ~(*ptep & PTE_W)) 
ffffffffc0204b3e:	611c                	ld	a5,0(a0)
ffffffffc0204b40:	8b85                	andi	a5,a5,1
ffffffffc0204b42:	efa5                	bnez	a5,ffffffffc0204bba <do_pgfault+0xc6>
        }
    }

    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204b44:	6c88                	ld	a0,24(s1)
ffffffffc0204b46:	4605                	li	a2,1
ffffffffc0204b48:	85a2                	mv	a1,s0
ffffffffc0204b4a:	dcefd0ef          	jal	ra,ffffffffc0202118 <get_pte>
ffffffffc0204b4e:	c155                	beqz	a0,ffffffffc0204bf2 <do_pgfault+0xfe>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0204b50:	610c                	ld	a1,0(a0)
ffffffffc0204b52:	c5a1                	beqz	a1,ffffffffc0204b9a <do_pgfault+0xa6>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0204b54:	000ae797          	auipc	a5,0xae
ffffffffc0204b58:	d1c7a783          	lw	a5,-740(a5) # ffffffffc02b2870 <swap_init_ok>
ffffffffc0204b5c:	c3d9                	beqz	a5,ffffffffc0204be2 <do_pgfault+0xee>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm, addr, &page);
ffffffffc0204b5e:	85a2                	mv	a1,s0
ffffffffc0204b60:	0030                	addi	a2,sp,8
ffffffffc0204b62:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0204b64:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0204b66:	a2aff0ef          	jal	ra,ffffffffc0203d90 <swap_in>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc0204b6a:	65a2                	ld	a1,8(sp)
ffffffffc0204b6c:	6c88                	ld	a0,24(s1)
ffffffffc0204b6e:	86ce                	mv	a3,s3
ffffffffc0204b70:	8622                	mv	a2,s0
ffffffffc0204b72:	c41fd0ef          	jal	ra,ffffffffc02027b2 <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc0204b76:	6622                	ld	a2,8(sp)
ffffffffc0204b78:	4685                	li	a3,1
ffffffffc0204b7a:	85a2                	mv	a1,s0
ffffffffc0204b7c:	8526                	mv	a0,s1
ffffffffc0204b7e:	8f2ff0ef          	jal	ra,ffffffffc0203c70 <swap_map_swappable>

            page->pra_vaddr = addr;
ffffffffc0204b82:	67a2                	ld	a5,8(sp)
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc0204b84:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc0204b86:	ff80                	sd	s0,56(a5)
failed:
    return ret;
}
ffffffffc0204b88:	70e2                	ld	ra,56(sp)
ffffffffc0204b8a:	7442                	ld	s0,48(sp)
ffffffffc0204b8c:	74a2                	ld	s1,40(sp)
ffffffffc0204b8e:	7902                	ld	s2,32(sp)
ffffffffc0204b90:	69e2                	ld	s3,24(sp)
ffffffffc0204b92:	6121                	addi	sp,sp,64
ffffffffc0204b94:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204b96:	49dd                	li	s3,23
ffffffffc0204b98:	bf59                	j	ffffffffc0204b2e <do_pgfault+0x3a>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204b9a:	6c88                	ld	a0,24(s1)
ffffffffc0204b9c:	864e                	mv	a2,s3
ffffffffc0204b9e:	85a2                	mv	a1,s0
ffffffffc0204ba0:	8a9fe0ef          	jal	ra,ffffffffc0203448 <pgdir_alloc_page>
ffffffffc0204ba4:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0204ba6:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204ba8:	f3e5                	bnez	a5,ffffffffc0204b88 <do_pgfault+0x94>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204baa:	00004517          	auipc	a0,0x4
ffffffffc0204bae:	8d650513          	addi	a0,a0,-1834 # ffffffffc0208480 <default_pmm_manager+0xec8>
ffffffffc0204bb2:	dcefb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204bb6:	5571                	li	a0,-4
            goto failed;
ffffffffc0204bb8:	bfc1                	j	ffffffffc0204b88 <do_pgfault+0x94>
            return privated_write_state(mm, error_code, addr);
ffffffffc0204bba:	8622                	mv	a2,s0
}
ffffffffc0204bbc:	7442                	ld	s0,48(sp)
ffffffffc0204bbe:	70e2                	ld	ra,56(sp)
ffffffffc0204bc0:	69e2                	ld	s3,24(sp)
            return privated_write_state(mm, error_code, addr);
ffffffffc0204bc2:	85ca                	mv	a1,s2
ffffffffc0204bc4:	8526                	mv	a0,s1
}
ffffffffc0204bc6:	7902                	ld	s2,32(sp)
ffffffffc0204bc8:	74a2                	ld	s1,40(sp)
ffffffffc0204bca:	6121                	addi	sp,sp,64
            return privated_write_state(mm, error_code, addr);
ffffffffc0204bcc:	c00fc06f          	j	ffffffffc0200fcc <privated_write_state>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204bd0:	85a2                	mv	a1,s0
ffffffffc0204bd2:	00004517          	auipc	a0,0x4
ffffffffc0204bd6:	85e50513          	addi	a0,a0,-1954 # ffffffffc0208430 <default_pmm_manager+0xe78>
ffffffffc0204bda:	da6fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = -E_INVAL;
ffffffffc0204bde:	5575                	li	a0,-3
        goto failed;
ffffffffc0204be0:	b765                	j	ffffffffc0204b88 <do_pgfault+0x94>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204be2:	00004517          	auipc	a0,0x4
ffffffffc0204be6:	8c650513          	addi	a0,a0,-1850 # ffffffffc02084a8 <default_pmm_manager+0xef0>
ffffffffc0204bea:	d96fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204bee:	5571                	li	a0,-4
            goto failed;
ffffffffc0204bf0:	bf61                	j	ffffffffc0204b88 <do_pgfault+0x94>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204bf2:	00004517          	auipc	a0,0x4
ffffffffc0204bf6:	86e50513          	addi	a0,a0,-1938 # ffffffffc0208460 <default_pmm_manager+0xea8>
ffffffffc0204bfa:	d86fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204bfe:	5571                	li	a0,-4
        goto failed;
ffffffffc0204c00:	b761                	j	ffffffffc0204b88 <do_pgfault+0x94>

ffffffffc0204c02 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204c02:	7179                	addi	sp,sp,-48
ffffffffc0204c04:	f022                	sd	s0,32(sp)
ffffffffc0204c06:	f406                	sd	ra,40(sp)
ffffffffc0204c08:	ec26                	sd	s1,24(sp)
ffffffffc0204c0a:	e84a                	sd	s2,16(sp)
ffffffffc0204c0c:	e44e                	sd	s3,8(sp)
ffffffffc0204c0e:	e052                	sd	s4,0(sp)
ffffffffc0204c10:	842e                	mv	s0,a1
    //检查从addr开始长为len的一段内存能否被用户态程序访问
    if (mm != NULL) {
ffffffffc0204c12:	c135                	beqz	a0,ffffffffc0204c76 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204c14:	002007b7          	lui	a5,0x200
ffffffffc0204c18:	04f5e663          	bltu	a1,a5,ffffffffc0204c64 <user_mem_check+0x62>
ffffffffc0204c1c:	00c584b3          	add	s1,a1,a2
ffffffffc0204c20:	0495f263          	bgeu	a1,s1,ffffffffc0204c64 <user_mem_check+0x62>
ffffffffc0204c24:	4785                	li	a5,1
ffffffffc0204c26:	07fe                	slli	a5,a5,0x1f
ffffffffc0204c28:	0297ee63          	bltu	a5,s1,ffffffffc0204c64 <user_mem_check+0x62>
ffffffffc0204c2c:	892a                	mv	s2,a0
ffffffffc0204c2e:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204c30:	6a05                	lui	s4,0x1
ffffffffc0204c32:	a821                	j	ffffffffc0204c4a <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204c34:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204c38:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204c3a:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204c3c:	c685                	beqz	a3,ffffffffc0204c64 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204c3e:	c399                	beqz	a5,ffffffffc0204c44 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204c40:	02e46263          	bltu	s0,a4,ffffffffc0204c64 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204c44:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204c46:	04947663          	bgeu	s0,s1,ffffffffc0204c92 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204c4a:	85a2                	mv	a1,s0
ffffffffc0204c4c:	854a                	mv	a0,s2
ffffffffc0204c4e:	e44ff0ef          	jal	ra,ffffffffc0204292 <find_vma>
ffffffffc0204c52:	c909                	beqz	a0,ffffffffc0204c64 <user_mem_check+0x62>
ffffffffc0204c54:	6518                	ld	a4,8(a0)
ffffffffc0204c56:	00e46763          	bltu	s0,a4,ffffffffc0204c64 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204c5a:	4d1c                	lw	a5,24(a0)
ffffffffc0204c5c:	fc099ce3          	bnez	s3,ffffffffc0204c34 <user_mem_check+0x32>
ffffffffc0204c60:	8b85                	andi	a5,a5,1
ffffffffc0204c62:	f3ed                	bnez	a5,ffffffffc0204c44 <user_mem_check+0x42>
            return 0;
ffffffffc0204c64:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204c66:	70a2                	ld	ra,40(sp)
ffffffffc0204c68:	7402                	ld	s0,32(sp)
ffffffffc0204c6a:	64e2                	ld	s1,24(sp)
ffffffffc0204c6c:	6942                	ld	s2,16(sp)
ffffffffc0204c6e:	69a2                	ld	s3,8(sp)
ffffffffc0204c70:	6a02                	ld	s4,0(sp)
ffffffffc0204c72:	6145                	addi	sp,sp,48
ffffffffc0204c74:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204c76:	c02007b7          	lui	a5,0xc0200
ffffffffc0204c7a:	4501                	li	a0,0
ffffffffc0204c7c:	fef5e5e3          	bltu	a1,a5,ffffffffc0204c66 <user_mem_check+0x64>
ffffffffc0204c80:	962e                	add	a2,a2,a1
ffffffffc0204c82:	fec5f2e3          	bgeu	a1,a2,ffffffffc0204c66 <user_mem_check+0x64>
ffffffffc0204c86:	c8000537          	lui	a0,0xc8000
ffffffffc0204c8a:	0505                	addi	a0,a0,1
ffffffffc0204c8c:	00a63533          	sltu	a0,a2,a0
ffffffffc0204c90:	bfd9                	j	ffffffffc0204c66 <user_mem_check+0x64>
        return 1;
ffffffffc0204c92:	4505                	li	a0,1
ffffffffc0204c94:	bfc9                	j	ffffffffc0204c66 <user_mem_check+0x64>

ffffffffc0204c96 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204c96:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204c98:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204c9a:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204c9c:	951fb0ef          	jal	ra,ffffffffc02005ec <ide_device_valid>
ffffffffc0204ca0:	cd01                	beqz	a0,ffffffffc0204cb8 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204ca2:	4505                	li	a0,1
ffffffffc0204ca4:	94ffb0ef          	jal	ra,ffffffffc02005f2 <ide_device_size>
}
ffffffffc0204ca8:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204caa:	810d                	srli	a0,a0,0x3
ffffffffc0204cac:	000ae797          	auipc	a5,0xae
ffffffffc0204cb0:	baa7ba23          	sd	a0,-1100(a5) # ffffffffc02b2860 <max_swap_offset>
}
ffffffffc0204cb4:	0141                	addi	sp,sp,16
ffffffffc0204cb6:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204cb8:	00004617          	auipc	a2,0x4
ffffffffc0204cbc:	81860613          	addi	a2,a2,-2024 # ffffffffc02084d0 <default_pmm_manager+0xf18>
ffffffffc0204cc0:	45b5                	li	a1,13
ffffffffc0204cc2:	00004517          	auipc	a0,0x4
ffffffffc0204cc6:	82e50513          	addi	a0,a0,-2002 # ffffffffc02084f0 <default_pmm_manager+0xf38>
ffffffffc0204cca:	fb0fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204cce <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204cce:	1141                	addi	sp,sp,-16
ffffffffc0204cd0:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204cd2:	00855793          	srli	a5,a0,0x8
ffffffffc0204cd6:	cbb1                	beqz	a5,ffffffffc0204d2a <swapfs_read+0x5c>
ffffffffc0204cd8:	000ae717          	auipc	a4,0xae
ffffffffc0204cdc:	b8873703          	ld	a4,-1144(a4) # ffffffffc02b2860 <max_swap_offset>
ffffffffc0204ce0:	04e7f563          	bgeu	a5,a4,ffffffffc0204d2a <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204ce4:	000ae617          	auipc	a2,0xae
ffffffffc0204ce8:	b6463603          	ld	a2,-1180(a2) # ffffffffc02b2848 <pages>
ffffffffc0204cec:	8d91                	sub	a1,a1,a2
ffffffffc0204cee:	4065d613          	srai	a2,a1,0x6
ffffffffc0204cf2:	00004717          	auipc	a4,0x4
ffffffffc0204cf6:	15673703          	ld	a4,342(a4) # ffffffffc0208e48 <nbase>
ffffffffc0204cfa:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204cfc:	00c61713          	slli	a4,a2,0xc
ffffffffc0204d00:	8331                	srli	a4,a4,0xc
ffffffffc0204d02:	000ae697          	auipc	a3,0xae
ffffffffc0204d06:	b3e6b683          	ld	a3,-1218(a3) # ffffffffc02b2840 <npage>
ffffffffc0204d0a:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d0e:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204d10:	02d77963          	bgeu	a4,a3,ffffffffc0204d42 <swapfs_read+0x74>
}
ffffffffc0204d14:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d16:	000ae797          	auipc	a5,0xae
ffffffffc0204d1a:	b427b783          	ld	a5,-1214(a5) # ffffffffc02b2858 <va_pa_offset>
ffffffffc0204d1e:	46a1                	li	a3,8
ffffffffc0204d20:	963e                	add	a2,a2,a5
ffffffffc0204d22:	4505                	li	a0,1
}
ffffffffc0204d24:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d26:	8d3fb06f          	j	ffffffffc02005f8 <ide_read_secs>
ffffffffc0204d2a:	86aa                	mv	a3,a0
ffffffffc0204d2c:	00003617          	auipc	a2,0x3
ffffffffc0204d30:	7dc60613          	addi	a2,a2,2012 # ffffffffc0208508 <default_pmm_manager+0xf50>
ffffffffc0204d34:	45d1                	li	a1,20
ffffffffc0204d36:	00003517          	auipc	a0,0x3
ffffffffc0204d3a:	7ba50513          	addi	a0,a0,1978 # ffffffffc02084f0 <default_pmm_manager+0xf38>
ffffffffc0204d3e:	f3cfb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204d42:	86b2                	mv	a3,a2
ffffffffc0204d44:	06900593          	li	a1,105
ffffffffc0204d48:	00002617          	auipc	a2,0x2
ffffffffc0204d4c:	4a060613          	addi	a2,a2,1184 # ffffffffc02071e8 <commands+0x888>
ffffffffc0204d50:	00002517          	auipc	a0,0x2
ffffffffc0204d54:	40050513          	addi	a0,a0,1024 # ffffffffc0207150 <commands+0x7f0>
ffffffffc0204d58:	f22fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204d5c <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204d5c:	1141                	addi	sp,sp,-16
ffffffffc0204d5e:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d60:	00855793          	srli	a5,a0,0x8
ffffffffc0204d64:	cbb1                	beqz	a5,ffffffffc0204db8 <swapfs_write+0x5c>
ffffffffc0204d66:	000ae717          	auipc	a4,0xae
ffffffffc0204d6a:	afa73703          	ld	a4,-1286(a4) # ffffffffc02b2860 <max_swap_offset>
ffffffffc0204d6e:	04e7f563          	bgeu	a5,a4,ffffffffc0204db8 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204d72:	000ae617          	auipc	a2,0xae
ffffffffc0204d76:	ad663603          	ld	a2,-1322(a2) # ffffffffc02b2848 <pages>
ffffffffc0204d7a:	8d91                	sub	a1,a1,a2
ffffffffc0204d7c:	4065d613          	srai	a2,a1,0x6
ffffffffc0204d80:	00004717          	auipc	a4,0x4
ffffffffc0204d84:	0c873703          	ld	a4,200(a4) # ffffffffc0208e48 <nbase>
ffffffffc0204d88:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204d8a:	00c61713          	slli	a4,a2,0xc
ffffffffc0204d8e:	8331                	srli	a4,a4,0xc
ffffffffc0204d90:	000ae697          	auipc	a3,0xae
ffffffffc0204d94:	ab06b683          	ld	a3,-1360(a3) # ffffffffc02b2840 <npage>
ffffffffc0204d98:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d9c:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204d9e:	02d77963          	bgeu	a4,a3,ffffffffc0204dd0 <swapfs_write+0x74>
}
ffffffffc0204da2:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204da4:	000ae797          	auipc	a5,0xae
ffffffffc0204da8:	ab47b783          	ld	a5,-1356(a5) # ffffffffc02b2858 <va_pa_offset>
ffffffffc0204dac:	46a1                	li	a3,8
ffffffffc0204dae:	963e                	add	a2,a2,a5
ffffffffc0204db0:	4505                	li	a0,1
}
ffffffffc0204db2:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204db4:	869fb06f          	j	ffffffffc020061c <ide_write_secs>
ffffffffc0204db8:	86aa                	mv	a3,a0
ffffffffc0204dba:	00003617          	auipc	a2,0x3
ffffffffc0204dbe:	74e60613          	addi	a2,a2,1870 # ffffffffc0208508 <default_pmm_manager+0xf50>
ffffffffc0204dc2:	45e5                	li	a1,25
ffffffffc0204dc4:	00003517          	auipc	a0,0x3
ffffffffc0204dc8:	72c50513          	addi	a0,a0,1836 # ffffffffc02084f0 <default_pmm_manager+0xf38>
ffffffffc0204dcc:	eaefb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204dd0:	86b2                	mv	a3,a2
ffffffffc0204dd2:	06900593          	li	a1,105
ffffffffc0204dd6:	00002617          	auipc	a2,0x2
ffffffffc0204dda:	41260613          	addi	a2,a2,1042 # ffffffffc02071e8 <commands+0x888>
ffffffffc0204dde:	00002517          	auipc	a0,0x2
ffffffffc0204de2:	37250513          	addi	a0,a0,882 # ffffffffc0207150 <commands+0x7f0>
ffffffffc0204de6:	e94fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204dea <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204dea:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204dec:	9402                	jalr	s0

	jal do_exit
ffffffffc0204dee:	638000ef          	jal	ra,ffffffffc0205426 <do_exit>

ffffffffc0204df2 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204df2:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204df4:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204df8:	e022                	sd	s0,0(sp)
ffffffffc0204dfa:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204dfc:	832fd0ef          	jal	ra,ffffffffc0201e2e <kmalloc>
ffffffffc0204e00:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204e02:	cd21                	beqz	a0,ffffffffc0204e5a <alloc_proc+0x68>
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     * proc_struct中的以下字段（在LAB5中的添加）需要初始化
     *       uint32_t wait_state;                        // 等待状态
     *       struct proc_struct *cptr, *yptr, *optr;     // 进程之间的关系
     */
        proc->state        = PROC_UNINIT;
ffffffffc0204e04:	57fd                	li	a5,-1
ffffffffc0204e06:	1782                	slli	a5,a5,0x20
ffffffffc0204e08:	e11c                	sd	a5,0(a0)
        proc->runs         = 0; 
        proc->kstack       = 0;    
        proc->need_resched = 0;
        proc->parent       = NULL;
        proc->mm           = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204e0a:	07000613          	li	a2,112
ffffffffc0204e0e:	4581                	li	a1,0
        proc->runs         = 0; 
ffffffffc0204e10:	00052423          	sw	zero,8(a0)
        proc->kstack       = 0;    
ffffffffc0204e14:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204e18:	00053c23          	sd	zero,24(a0)
        proc->parent       = NULL;
ffffffffc0204e1c:	02053023          	sd	zero,32(a0)
        proc->mm           = NULL;
ffffffffc0204e20:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204e24:	03050513          	addi	a0,a0,48
ffffffffc0204e28:	0a1010ef          	jal	ra,ffffffffc02066c8 <memset>
        proc->tf           = NULL;
        proc->cr3          = boot_cr3;
ffffffffc0204e2c:	000ae797          	auipc	a5,0xae
ffffffffc0204e30:	a047b783          	ld	a5,-1532(a5) # ffffffffc02b2830 <boot_cr3>
        proc->tf           = NULL;
ffffffffc0204e34:	0a043023          	sd	zero,160(s0)
        proc->cr3          = boot_cr3;
ffffffffc0204e38:	f45c                	sd	a5,168(s0)
        proc->flags        = 0;
ffffffffc0204e3a:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, PROC_NAME_LEN+1);
ffffffffc0204e3e:	4641                	li	a2,16
ffffffffc0204e40:	4581                	li	a1,0
ffffffffc0204e42:	0b440513          	addi	a0,s0,180
ffffffffc0204e46:	083010ef          	jal	ra,ffffffffc02066c8 <memset>

        proc->wait_state   = 0;
ffffffffc0204e4a:	0e042623          	sw	zero,236(s0)
        proc->cptr         = NULL;
ffffffffc0204e4e:	0e043823          	sd	zero,240(s0)
        proc->yptr         = NULL;
ffffffffc0204e52:	0e043c23          	sd	zero,248(s0)
        proc->optr         = NULL;
ffffffffc0204e56:	10043023          	sd	zero,256(s0)
    }
    return proc;
}
ffffffffc0204e5a:	60a2                	ld	ra,8(sp)
ffffffffc0204e5c:	8522                	mv	a0,s0
ffffffffc0204e5e:	6402                	ld	s0,0(sp)
ffffffffc0204e60:	0141                	addi	sp,sp,16
ffffffffc0204e62:	8082                	ret

ffffffffc0204e64 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204e64:	000ae797          	auipc	a5,0xae
ffffffffc0204e68:	a247b783          	ld	a5,-1500(a5) # ffffffffc02b2888 <current>
ffffffffc0204e6c:	73c8                	ld	a0,160(a5)
ffffffffc0204e6e:	f09fb06f          	j	ffffffffc0200d76 <forkrets>

ffffffffc0204e72 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204e72:	000ae797          	auipc	a5,0xae
ffffffffc0204e76:	a167b783          	ld	a5,-1514(a5) # ffffffffc02b2888 <current>
ffffffffc0204e7a:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204e7c:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204e7e:	00003617          	auipc	a2,0x3
ffffffffc0204e82:	6aa60613          	addi	a2,a2,1706 # ffffffffc0208528 <default_pmm_manager+0xf70>
ffffffffc0204e86:	00003517          	auipc	a0,0x3
ffffffffc0204e8a:	6b250513          	addi	a0,a0,1714 # ffffffffc0208538 <default_pmm_manager+0xf80>
user_main(void *arg) {
ffffffffc0204e8e:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204e90:	af0fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0204e94:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204e98:	adc78793          	addi	a5,a5,-1316 # a970 <_binary_obj___user_forktest_out_size>
ffffffffc0204e9c:	e43e                	sd	a5,8(sp)
ffffffffc0204e9e:	00003517          	auipc	a0,0x3
ffffffffc0204ea2:	68a50513          	addi	a0,a0,1674 # ffffffffc0208528 <default_pmm_manager+0xf70>
ffffffffc0204ea6:	00046797          	auipc	a5,0x46
ffffffffc0204eaa:	86a78793          	addi	a5,a5,-1942 # ffffffffc024a710 <_binary_obj___user_forktest_out_start>
ffffffffc0204eae:	f03e                	sd	a5,32(sp)
ffffffffc0204eb0:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name); //                                                                   |
ffffffffc0204eb2:	e802                	sd	zero,16(sp)
ffffffffc0204eb4:	798010ef          	jal	ra,ffffffffc020664c <strlen>
ffffffffc0204eb8:	ec2a                	sd	a0,24(sp)
    asm volatile( //                                                                                        | 
ffffffffc0204eba:	4511                	li	a0,4
ffffffffc0204ebc:	55a2                	lw	a1,40(sp)
ffffffffc0204ebe:	4662                	lw	a2,24(sp)
ffffffffc0204ec0:	5682                	lw	a3,32(sp)
ffffffffc0204ec2:	4722                	lw	a4,8(sp)
ffffffffc0204ec4:	48a9                	li	a7,10
ffffffffc0204ec6:	9002                	ebreak
ffffffffc0204ec8:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204eca:	65c2                	ld	a1,16(sp)
ffffffffc0204ecc:	00003517          	auipc	a0,0x3
ffffffffc0204ed0:	69450513          	addi	a0,a0,1684 # ffffffffc0208560 <default_pmm_manager+0xfa8>
ffffffffc0204ed4:	aacfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
#else
    KERNEL_EXECVE(exit);
    // 执行 kern_execve("exit", _binary_obj___user_exit_out_start,_binary_obj___user_exit_out_size);
    // 实际上，就是加载了存储在这个位置的程序exit并在user_main这个进程里开始执行。这时user_main就从内核进程变成了用户进程。
#endif
    panic("user_main execve failed.\n");
ffffffffc0204ed8:	00003617          	auipc	a2,0x3
ffffffffc0204edc:	69860613          	addi	a2,a2,1688 # ffffffffc0208570 <default_pmm_manager+0xfb8>
ffffffffc0204ee0:	38200593          	li	a1,898
ffffffffc0204ee4:	00003517          	auipc	a0,0x3
ffffffffc0204ee8:	6ac50513          	addi	a0,a0,1708 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0204eec:	d8efb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204ef0 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204ef0:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204ef2:	1141                	addi	sp,sp,-16
ffffffffc0204ef4:	e406                	sd	ra,8(sp)
ffffffffc0204ef6:	c02007b7          	lui	a5,0xc0200
ffffffffc0204efa:	02f6ee63          	bltu	a3,a5,ffffffffc0204f36 <put_pgdir+0x46>
ffffffffc0204efe:	000ae517          	auipc	a0,0xae
ffffffffc0204f02:	95a53503          	ld	a0,-1702(a0) # ffffffffc02b2858 <va_pa_offset>
ffffffffc0204f06:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204f08:	82b1                	srli	a3,a3,0xc
ffffffffc0204f0a:	000ae797          	auipc	a5,0xae
ffffffffc0204f0e:	9367b783          	ld	a5,-1738(a5) # ffffffffc02b2840 <npage>
ffffffffc0204f12:	02f6fe63          	bgeu	a3,a5,ffffffffc0204f4e <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204f16:	00004517          	auipc	a0,0x4
ffffffffc0204f1a:	f3253503          	ld	a0,-206(a0) # ffffffffc0208e48 <nbase>
}
ffffffffc0204f1e:	60a2                	ld	ra,8(sp)
ffffffffc0204f20:	8e89                	sub	a3,a3,a0
ffffffffc0204f22:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204f24:	000ae517          	auipc	a0,0xae
ffffffffc0204f28:	92453503          	ld	a0,-1756(a0) # ffffffffc02b2848 <pages>
ffffffffc0204f2c:	4585                	li	a1,1
ffffffffc0204f2e:	9536                	add	a0,a0,a3
}
ffffffffc0204f30:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204f32:	96cfd06f          	j	ffffffffc020209e <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204f36:	00002617          	auipc	a2,0x2
ffffffffc0204f3a:	72a60613          	addi	a2,a2,1834 # ffffffffc0207660 <default_pmm_manager+0xa8>
ffffffffc0204f3e:	06e00593          	li	a1,110
ffffffffc0204f42:	00002517          	auipc	a0,0x2
ffffffffc0204f46:	20e50513          	addi	a0,a0,526 # ffffffffc0207150 <commands+0x7f0>
ffffffffc0204f4a:	d30fb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204f4e:	00002617          	auipc	a2,0x2
ffffffffc0204f52:	21260613          	addi	a2,a2,530 # ffffffffc0207160 <commands+0x800>
ffffffffc0204f56:	06200593          	li	a1,98
ffffffffc0204f5a:	00002517          	auipc	a0,0x2
ffffffffc0204f5e:	1f650513          	addi	a0,a0,502 # ffffffffc0207150 <commands+0x7f0>
ffffffffc0204f62:	d18fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204f66 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204f66:	7179                	addi	sp,sp,-48
ffffffffc0204f68:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204f6a:	000ae917          	auipc	s2,0xae
ffffffffc0204f6e:	91e90913          	addi	s2,s2,-1762 # ffffffffc02b2888 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204f72:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204f74:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204f78:	f406                	sd	ra,40(sp)
ffffffffc0204f7a:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc0204f7c:	02a48863          	beq	s1,a0,ffffffffc0204fac <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f80:	100027f3          	csrr	a5,sstatus
ffffffffc0204f84:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f86:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f88:	ef9d                	bnez	a5,ffffffffc0204fc6 <proc_run+0x60>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204f8a:	755c                	ld	a5,168(a0)
ffffffffc0204f8c:	577d                	li	a4,-1
ffffffffc0204f8e:	177e                	slli	a4,a4,0x3f
ffffffffc0204f90:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0204f92:	00a93023          	sd	a0,0(s2)
ffffffffc0204f96:	8fd9                	or	a5,a5,a4
ffffffffc0204f98:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc0204f9c:	03050593          	addi	a1,a0,48
ffffffffc0204fa0:	03048513          	addi	a0,s1,48
ffffffffc0204fa4:	04e010ef          	jal	ra,ffffffffc0205ff2 <switch_to>
    if (flag) {
ffffffffc0204fa8:	00099863          	bnez	s3,ffffffffc0204fb8 <proc_run+0x52>
}
ffffffffc0204fac:	70a2                	ld	ra,40(sp)
ffffffffc0204fae:	7482                	ld	s1,32(sp)
ffffffffc0204fb0:	6962                	ld	s2,24(sp)
ffffffffc0204fb2:	69c2                	ld	s3,16(sp)
ffffffffc0204fb4:	6145                	addi	sp,sp,48
ffffffffc0204fb6:	8082                	ret
ffffffffc0204fb8:	70a2                	ld	ra,40(sp)
ffffffffc0204fba:	7482                	ld	s1,32(sp)
ffffffffc0204fbc:	6962                	ld	s2,24(sp)
ffffffffc0204fbe:	69c2                	ld	s3,16(sp)
ffffffffc0204fc0:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204fc2:	e7efb06f          	j	ffffffffc0200640 <intr_enable>
ffffffffc0204fc6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204fc8:	e7efb0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0204fcc:	6522                	ld	a0,8(sp)
ffffffffc0204fce:	4985                	li	s3,1
ffffffffc0204fd0:	bf6d                	j	ffffffffc0204f8a <proc_run+0x24>

ffffffffc0204fd2 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204fd2:	7119                	addi	sp,sp,-128
ffffffffc0204fd4:	f0ca                	sd	s2,96(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204fd6:	000ae917          	auipc	s2,0xae
ffffffffc0204fda:	8ca90913          	addi	s2,s2,-1846 # ffffffffc02b28a0 <nr_process>
ffffffffc0204fde:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204fe2:	fc86                	sd	ra,120(sp)
ffffffffc0204fe4:	f8a2                	sd	s0,112(sp)
ffffffffc0204fe6:	f4a6                	sd	s1,104(sp)
ffffffffc0204fe8:	ecce                	sd	s3,88(sp)
ffffffffc0204fea:	e8d2                	sd	s4,80(sp)
ffffffffc0204fec:	e4d6                	sd	s5,72(sp)
ffffffffc0204fee:	e0da                	sd	s6,64(sp)
ffffffffc0204ff0:	fc5e                	sd	s7,56(sp)
ffffffffc0204ff2:	f862                	sd	s8,48(sp)
ffffffffc0204ff4:	f466                	sd	s9,40(sp)
ffffffffc0204ff6:	f06a                	sd	s10,32(sp)
ffffffffc0204ff8:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204ffa:	6785                	lui	a5,0x1
ffffffffc0204ffc:	32f75b63          	bge	a4,a5,ffffffffc0205332 <do_fork+0x360>
ffffffffc0205000:	8a2a                	mv	s4,a0
ffffffffc0205002:	89ae                	mv	s3,a1
ffffffffc0205004:	8432                	mv	s0,a2
    if((proc = alloc_proc()) == NULL) goto fork_out;
ffffffffc0205006:	dedff0ef          	jal	ra,ffffffffc0204df2 <alloc_proc>
ffffffffc020500a:	84aa                	mv	s1,a0
ffffffffc020500c:	30050463          	beqz	a0,ffffffffc0205314 <do_fork+0x342>
    proc->parent = current;
ffffffffc0205010:	000aec17          	auipc	s8,0xae
ffffffffc0205014:	878c0c13          	addi	s8,s8,-1928 # ffffffffc02b2888 <current>
ffffffffc0205018:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0); // 更新步骤1：将子进程的父进程设置为当前进程，确保当前进程的wait_state为0
ffffffffc020501c:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8ac4>
    proc->parent = current;
ffffffffc0205020:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0); // 更新步骤1：将子进程的父进程设置为当前进程，确保当前进程的wait_state为0
ffffffffc0205022:	30071d63          	bnez	a4,ffffffffc020533c <do_fork+0x36a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0205026:	4509                	li	a0,2
ffffffffc0205028:	fe5fc0ef          	jal	ra,ffffffffc020200c <alloc_pages>
    if (page != NULL) {
ffffffffc020502c:	2e050163          	beqz	a0,ffffffffc020530e <do_fork+0x33c>
    return page - pages + nbase;
ffffffffc0205030:	000aea97          	auipc	s5,0xae
ffffffffc0205034:	818a8a93          	addi	s5,s5,-2024 # ffffffffc02b2848 <pages>
ffffffffc0205038:	000ab683          	ld	a3,0(s5)
ffffffffc020503c:	00004b17          	auipc	s6,0x4
ffffffffc0205040:	e0cb0b13          	addi	s6,s6,-500 # ffffffffc0208e48 <nbase>
ffffffffc0205044:	000b3783          	ld	a5,0(s6)
ffffffffc0205048:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc020504c:	000adb97          	auipc	s7,0xad
ffffffffc0205050:	7f4b8b93          	addi	s7,s7,2036 # ffffffffc02b2840 <npage>
    return page - pages + nbase;
ffffffffc0205054:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205056:	5dfd                	li	s11,-1
ffffffffc0205058:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc020505c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020505e:	00cddd93          	srli	s11,s11,0xc
ffffffffc0205062:	01b6f633          	and	a2,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc0205066:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205068:	2ee67a63          	bgeu	a2,a4,ffffffffc020535c <do_fork+0x38a>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc020506c:	000c3603          	ld	a2,0(s8)
ffffffffc0205070:	000adc17          	auipc	s8,0xad
ffffffffc0205074:	7e8c0c13          	addi	s8,s8,2024 # ffffffffc02b2858 <va_pa_offset>
ffffffffc0205078:	000c3703          	ld	a4,0(s8)
ffffffffc020507c:	02863d03          	ld	s10,40(a2)
ffffffffc0205080:	e43e                	sd	a5,8(sp)
ffffffffc0205082:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0205084:	e894                	sd	a3,16(s1)
    if (oldmm == NULL) {
ffffffffc0205086:	020d0863          	beqz	s10,ffffffffc02050b6 <do_fork+0xe4>
    if (clone_flags & CLONE_VM) {
ffffffffc020508a:	100a7a13          	andi	s4,s4,256
ffffffffc020508e:	1c0a0163          	beqz	s4,ffffffffc0205250 <do_fork+0x27e>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205092:	030d2703          	lw	a4,48(s10)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205096:	018d3783          	ld	a5,24(s10)
ffffffffc020509a:	c02006b7          	lui	a3,0xc0200
ffffffffc020509e:	2705                	addiw	a4,a4,1
ffffffffc02050a0:	02ed2823          	sw	a4,48(s10)
    proc->mm = mm;
ffffffffc02050a4:	03a4b423          	sd	s10,40(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02050a8:	2ed7e263          	bltu	a5,a3,ffffffffc020538c <do_fork+0x3ba>
ffffffffc02050ac:	000c3703          	ld	a4,0(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02050b0:	6894                	ld	a3,16(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02050b2:	8f99                	sub	a5,a5,a4
ffffffffc02050b4:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02050b6:	6789                	lui	a5,0x2
ffffffffc02050b8:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd0>
ffffffffc02050bc:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc02050be:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02050c0:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc02050c2:	87b6                	mv	a5,a3
ffffffffc02050c4:	12040893          	addi	a7,s0,288
ffffffffc02050c8:	00063803          	ld	a6,0(a2)
ffffffffc02050cc:	6608                	ld	a0,8(a2)
ffffffffc02050ce:	6a0c                	ld	a1,16(a2)
ffffffffc02050d0:	6e18                	ld	a4,24(a2)
ffffffffc02050d2:	0107b023          	sd	a6,0(a5)
ffffffffc02050d6:	e788                	sd	a0,8(a5)
ffffffffc02050d8:	eb8c                	sd	a1,16(a5)
ffffffffc02050da:	ef98                	sd	a4,24(a5)
ffffffffc02050dc:	02060613          	addi	a2,a2,32
ffffffffc02050e0:	02078793          	addi	a5,a5,32
ffffffffc02050e4:	ff1612e3          	bne	a2,a7,ffffffffc02050c8 <do_fork+0xf6>
    proc->tf->gpr.a0 = 0;
ffffffffc02050e8:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02050ec:	12098f63          	beqz	s3,ffffffffc020522a <do_fork+0x258>
ffffffffc02050f0:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02050f4:	00000797          	auipc	a5,0x0
ffffffffc02050f8:	d7078793          	addi	a5,a5,-656 # ffffffffc0204e64 <forkret>
ffffffffc02050fc:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02050fe:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205100:	100027f3          	csrr	a5,sstatus
ffffffffc0205104:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205106:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205108:	14079063          	bnez	a5,ffffffffc0205248 <do_fork+0x276>
    if (++ last_pid >= MAX_PID) {
ffffffffc020510c:	000a2817          	auipc	a6,0xa2
ffffffffc0205110:	23480813          	addi	a6,a6,564 # ffffffffc02a7340 <last_pid.1>
ffffffffc0205114:	00082783          	lw	a5,0(a6)
ffffffffc0205118:	6709                	lui	a4,0x2
ffffffffc020511a:	0017851b          	addiw	a0,a5,1
ffffffffc020511e:	00a82023          	sw	a0,0(a6)
ffffffffc0205122:	08e55d63          	bge	a0,a4,ffffffffc02051bc <do_fork+0x1ea>
    if (last_pid >= next_safe) {
ffffffffc0205126:	000a2317          	auipc	t1,0xa2
ffffffffc020512a:	21e30313          	addi	t1,t1,542 # ffffffffc02a7344 <next_safe.0>
ffffffffc020512e:	00032783          	lw	a5,0(t1)
ffffffffc0205132:	000ad417          	auipc	s0,0xad
ffffffffc0205136:	6ce40413          	addi	s0,s0,1742 # ffffffffc02b2800 <proc_list>
ffffffffc020513a:	08f55963          	bge	a0,a5,ffffffffc02051cc <do_fork+0x1fa>
        proc->pid = get_pid();
ffffffffc020513e:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205140:	45a9                	li	a1,10
ffffffffc0205142:	2501                	sext.w	a0,a0
ffffffffc0205144:	104010ef          	jal	ra,ffffffffc0206248 <hash32>
ffffffffc0205148:	02051793          	slli	a5,a0,0x20
ffffffffc020514c:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205150:	000a9797          	auipc	a5,0xa9
ffffffffc0205154:	6b078793          	addi	a5,a5,1712 # ffffffffc02ae800 <hash_list>
ffffffffc0205158:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020515a:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020515c:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020515e:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc0205162:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0205164:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc0205166:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205168:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc020516a:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc020516e:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc0205170:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc0205172:	e21c                	sd	a5,0(a2)
ffffffffc0205174:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc0205176:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc0205178:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc020517a:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020517e:	10e4b023          	sd	a4,256(s1)
ffffffffc0205182:	c311                	beqz	a4,ffffffffc0205186 <do_fork+0x1b4>
        proc->optr->yptr = proc;
ffffffffc0205184:	ff64                	sd	s1,248(a4)
    nr_process ++;
ffffffffc0205186:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc020518a:	fae4                	sd	s1,240(a3)
    nr_process ++;
ffffffffc020518c:	2785                	addiw	a5,a5,1
ffffffffc020518e:	00f92023          	sw	a5,0(s2)
    if (flag) {
ffffffffc0205192:	18099363          	bnez	s3,ffffffffc0205318 <do_fork+0x346>
    wakeup_proc(proc);
ffffffffc0205196:	8526                	mv	a0,s1
ffffffffc0205198:	6c5000ef          	jal	ra,ffffffffc020605c <wakeup_proc>
    ret = proc->pid;
ffffffffc020519c:	40c8                	lw	a0,4(s1)
}
ffffffffc020519e:	70e6                	ld	ra,120(sp)
ffffffffc02051a0:	7446                	ld	s0,112(sp)
ffffffffc02051a2:	74a6                	ld	s1,104(sp)
ffffffffc02051a4:	7906                	ld	s2,96(sp)
ffffffffc02051a6:	69e6                	ld	s3,88(sp)
ffffffffc02051a8:	6a46                	ld	s4,80(sp)
ffffffffc02051aa:	6aa6                	ld	s5,72(sp)
ffffffffc02051ac:	6b06                	ld	s6,64(sp)
ffffffffc02051ae:	7be2                	ld	s7,56(sp)
ffffffffc02051b0:	7c42                	ld	s8,48(sp)
ffffffffc02051b2:	7ca2                	ld	s9,40(sp)
ffffffffc02051b4:	7d02                	ld	s10,32(sp)
ffffffffc02051b6:	6de2                	ld	s11,24(sp)
ffffffffc02051b8:	6109                	addi	sp,sp,128
ffffffffc02051ba:	8082                	ret
        last_pid = 1;
ffffffffc02051bc:	4785                	li	a5,1
ffffffffc02051be:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc02051c2:	4505                	li	a0,1
ffffffffc02051c4:	000a2317          	auipc	t1,0xa2
ffffffffc02051c8:	18030313          	addi	t1,t1,384 # ffffffffc02a7344 <next_safe.0>
    return listelm->next;
ffffffffc02051cc:	000ad417          	auipc	s0,0xad
ffffffffc02051d0:	63440413          	addi	s0,s0,1588 # ffffffffc02b2800 <proc_list>
ffffffffc02051d4:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc02051d8:	6789                	lui	a5,0x2
ffffffffc02051da:	00f32023          	sw	a5,0(t1)
ffffffffc02051de:	86aa                	mv	a3,a0
ffffffffc02051e0:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc02051e2:	6e89                	lui	t4,0x2
ffffffffc02051e4:	148e0263          	beq	t3,s0,ffffffffc0205328 <do_fork+0x356>
ffffffffc02051e8:	88ae                	mv	a7,a1
ffffffffc02051ea:	87f2                	mv	a5,t3
ffffffffc02051ec:	6609                	lui	a2,0x2
ffffffffc02051ee:	a811                	j	ffffffffc0205202 <do_fork+0x230>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc02051f0:	00e6d663          	bge	a3,a4,ffffffffc02051fc <do_fork+0x22a>
ffffffffc02051f4:	00c75463          	bge	a4,a2,ffffffffc02051fc <do_fork+0x22a>
ffffffffc02051f8:	863a                	mv	a2,a4
ffffffffc02051fa:	4885                	li	a7,1
ffffffffc02051fc:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02051fe:	00878d63          	beq	a5,s0,ffffffffc0205218 <do_fork+0x246>
            if (proc->pid == last_pid) {
ffffffffc0205202:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c74>
ffffffffc0205206:	fed715e3          	bne	a4,a3,ffffffffc02051f0 <do_fork+0x21e>
                if (++ last_pid >= next_safe) {
ffffffffc020520a:	2685                	addiw	a3,a3,1
ffffffffc020520c:	10c6d963          	bge	a3,a2,ffffffffc020531e <do_fork+0x34c>
ffffffffc0205210:	679c                	ld	a5,8(a5)
ffffffffc0205212:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc0205214:	fe8797e3          	bne	a5,s0,ffffffffc0205202 <do_fork+0x230>
ffffffffc0205218:	c581                	beqz	a1,ffffffffc0205220 <do_fork+0x24e>
ffffffffc020521a:	00d82023          	sw	a3,0(a6)
ffffffffc020521e:	8536                	mv	a0,a3
ffffffffc0205220:	f0088fe3          	beqz	a7,ffffffffc020513e <do_fork+0x16c>
ffffffffc0205224:	00c32023          	sw	a2,0(t1)
ffffffffc0205228:	bf19                	j	ffffffffc020513e <do_fork+0x16c>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020522a:	89b6                	mv	s3,a3
ffffffffc020522c:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205230:	00000797          	auipc	a5,0x0
ffffffffc0205234:	c3478793          	addi	a5,a5,-972 # ffffffffc0204e64 <forkret>
ffffffffc0205238:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020523a:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020523c:	100027f3          	csrr	a5,sstatus
ffffffffc0205240:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205242:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205244:	ec0784e3          	beqz	a5,ffffffffc020510c <do_fork+0x13a>
        intr_disable();
ffffffffc0205248:	bfefb0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc020524c:	4985                	li	s3,1
ffffffffc020524e:	bd7d                	j	ffffffffc020510c <do_fork+0x13a>
    if ((mm = mm_create()) == NULL) {
ffffffffc0205250:	fcdfe0ef          	jal	ra,ffffffffc020421c <mm_create>
ffffffffc0205254:	8caa                	mv	s9,a0
ffffffffc0205256:	c541                	beqz	a0,ffffffffc02052de <do_fork+0x30c>
    if ((page = alloc_page()) == NULL) {
ffffffffc0205258:	4505                	li	a0,1
ffffffffc020525a:	db3fc0ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc020525e:	cd2d                	beqz	a0,ffffffffc02052d8 <do_fork+0x306>
    return page - pages + nbase;
ffffffffc0205260:	000ab683          	ld	a3,0(s5)
ffffffffc0205264:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc0205266:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc020526a:	40d506b3          	sub	a3,a0,a3
ffffffffc020526e:	8699                	srai	a3,a3,0x6
ffffffffc0205270:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205272:	01b6fdb3          	and	s11,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc0205276:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205278:	0eedf263          	bgeu	s11,a4,ffffffffc020535c <do_fork+0x38a>
ffffffffc020527c:	000c3a03          	ld	s4,0(s8)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205280:	6605                	lui	a2,0x1
ffffffffc0205282:	000ad597          	auipc	a1,0xad
ffffffffc0205286:	5b65b583          	ld	a1,1462(a1) # ffffffffc02b2838 <boot_pgdir>
ffffffffc020528a:	9a36                	add	s4,s4,a3
ffffffffc020528c:	8552                	mv	a0,s4
ffffffffc020528e:	44c010ef          	jal	ra,ffffffffc02066da <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0205292:	038d0d93          	addi	s11,s10,56
    mm->pgdir = pgdir;
ffffffffc0205296:	014cbc23          	sd	s4,24(s9)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020529a:	4785                	li	a5,1
ffffffffc020529c:	40fdb7af          	amoor.d	a5,a5,(s11)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc02052a0:	8b85                	andi	a5,a5,1
ffffffffc02052a2:	4a05                	li	s4,1
ffffffffc02052a4:	c799                	beqz	a5,ffffffffc02052b2 <do_fork+0x2e0>
        schedule();
ffffffffc02052a6:	637000ef          	jal	ra,ffffffffc02060dc <schedule>
ffffffffc02052aa:	414db7af          	amoor.d	a5,s4,(s11)
    while (!try_lock(lock)) {
ffffffffc02052ae:	8b85                	andi	a5,a5,1
ffffffffc02052b0:	fbfd                	bnez	a5,ffffffffc02052a6 <do_fork+0x2d4>
        ret = dup_mmap(mm, oldmm);
ffffffffc02052b2:	85ea                	mv	a1,s10
ffffffffc02052b4:	8566                	mv	a0,s9
ffffffffc02052b6:	9eeff0ef          	jal	ra,ffffffffc02044a4 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02052ba:	57f9                	li	a5,-2
ffffffffc02052bc:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc02052c0:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc02052c2:	0e078e63          	beqz	a5,ffffffffc02053be <do_fork+0x3ec>
good_mm:
ffffffffc02052c6:	8d66                	mv	s10,s9
    if (ret != 0) {
ffffffffc02052c8:	dc0505e3          	beqz	a0,ffffffffc0205092 <do_fork+0xc0>
    exit_mmap(mm);
ffffffffc02052cc:	8566                	mv	a0,s9
ffffffffc02052ce:	a70ff0ef          	jal	ra,ffffffffc020453e <exit_mmap>
    put_pgdir(mm);
ffffffffc02052d2:	8566                	mv	a0,s9
ffffffffc02052d4:	c1dff0ef          	jal	ra,ffffffffc0204ef0 <put_pgdir>
    mm_destroy(mm);
ffffffffc02052d8:	8566                	mv	a0,s9
ffffffffc02052da:	8c8ff0ef          	jal	ra,ffffffffc02043a2 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02052de:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc02052e0:	c02007b7          	lui	a5,0xc0200
ffffffffc02052e4:	0cf6e163          	bltu	a3,a5,ffffffffc02053a6 <do_fork+0x3d4>
ffffffffc02052e8:	000c3783          	ld	a5,0(s8)
    if (PPN(pa) >= npage) {
ffffffffc02052ec:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc02052f0:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02052f4:	83b1                	srli	a5,a5,0xc
ffffffffc02052f6:	06e7ff63          	bgeu	a5,a4,ffffffffc0205374 <do_fork+0x3a2>
    return &pages[PPN(pa) - nbase];
ffffffffc02052fa:	000b3703          	ld	a4,0(s6)
ffffffffc02052fe:	000ab503          	ld	a0,0(s5)
ffffffffc0205302:	4589                	li	a1,2
ffffffffc0205304:	8f99                	sub	a5,a5,a4
ffffffffc0205306:	079a                	slli	a5,a5,0x6
ffffffffc0205308:	953e                	add	a0,a0,a5
ffffffffc020530a:	d95fc0ef          	jal	ra,ffffffffc020209e <free_pages>
    kfree(proc);
ffffffffc020530e:	8526                	mv	a0,s1
ffffffffc0205310:	bcffc0ef          	jal	ra,ffffffffc0201ede <kfree>
    ret = -E_NO_MEM;
ffffffffc0205314:	5571                	li	a0,-4
    return ret;
ffffffffc0205316:	b561                	j	ffffffffc020519e <do_fork+0x1cc>
        intr_enable();
ffffffffc0205318:	b28fb0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc020531c:	bdad                	j	ffffffffc0205196 <do_fork+0x1c4>
                    if (last_pid >= MAX_PID) {
ffffffffc020531e:	01d6c363          	blt	a3,t4,ffffffffc0205324 <do_fork+0x352>
                        last_pid = 1;
ffffffffc0205322:	4685                	li	a3,1
                    goto repeat;
ffffffffc0205324:	4585                	li	a1,1
ffffffffc0205326:	bd7d                	j	ffffffffc02051e4 <do_fork+0x212>
ffffffffc0205328:	c599                	beqz	a1,ffffffffc0205336 <do_fork+0x364>
ffffffffc020532a:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc020532e:	8536                	mv	a0,a3
ffffffffc0205330:	b539                	j	ffffffffc020513e <do_fork+0x16c>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205332:	556d                	li	a0,-5
ffffffffc0205334:	b5ad                	j	ffffffffc020519e <do_fork+0x1cc>
    return last_pid;
ffffffffc0205336:	00082503          	lw	a0,0(a6)
ffffffffc020533a:	b511                	j	ffffffffc020513e <do_fork+0x16c>
    assert(current->wait_state == 0); // 更新步骤1：将子进程的父进程设置为当前进程，确保当前进程的wait_state为0
ffffffffc020533c:	00003697          	auipc	a3,0x3
ffffffffc0205340:	26c68693          	addi	a3,a3,620 # ffffffffc02085a8 <default_pmm_manager+0xff0>
ffffffffc0205344:	00002617          	auipc	a2,0x2
ffffffffc0205348:	a6c60613          	addi	a2,a2,-1428 # ffffffffc0206db0 <commands+0x450>
ffffffffc020534c:	1ba00593          	li	a1,442
ffffffffc0205350:	00003517          	auipc	a0,0x3
ffffffffc0205354:	24050513          	addi	a0,a0,576 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205358:	922fb0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc020535c:	00002617          	auipc	a2,0x2
ffffffffc0205360:	e8c60613          	addi	a2,a2,-372 # ffffffffc02071e8 <commands+0x888>
ffffffffc0205364:	06900593          	li	a1,105
ffffffffc0205368:	00002517          	auipc	a0,0x2
ffffffffc020536c:	de850513          	addi	a0,a0,-536 # ffffffffc0207150 <commands+0x7f0>
ffffffffc0205370:	90afb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205374:	00002617          	auipc	a2,0x2
ffffffffc0205378:	dec60613          	addi	a2,a2,-532 # ffffffffc0207160 <commands+0x800>
ffffffffc020537c:	06200593          	li	a1,98
ffffffffc0205380:	00002517          	auipc	a0,0x2
ffffffffc0205384:	dd050513          	addi	a0,a0,-560 # ffffffffc0207150 <commands+0x7f0>
ffffffffc0205388:	8f2fb0ef          	jal	ra,ffffffffc020047a <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020538c:	86be                	mv	a3,a5
ffffffffc020538e:	00002617          	auipc	a2,0x2
ffffffffc0205392:	2d260613          	addi	a2,a2,722 # ffffffffc0207660 <default_pmm_manager+0xa8>
ffffffffc0205396:	16900593          	li	a1,361
ffffffffc020539a:	00003517          	auipc	a0,0x3
ffffffffc020539e:	1f650513          	addi	a0,a0,502 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc02053a2:	8d8fb0ef          	jal	ra,ffffffffc020047a <__panic>
    return pa2page(PADDR(kva));
ffffffffc02053a6:	00002617          	auipc	a2,0x2
ffffffffc02053aa:	2ba60613          	addi	a2,a2,698 # ffffffffc0207660 <default_pmm_manager+0xa8>
ffffffffc02053ae:	06e00593          	li	a1,110
ffffffffc02053b2:	00002517          	auipc	a0,0x2
ffffffffc02053b6:	d9e50513          	addi	a0,a0,-610 # ffffffffc0207150 <commands+0x7f0>
ffffffffc02053ba:	8c0fb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("Unlock failed.\n");
ffffffffc02053be:	00003617          	auipc	a2,0x3
ffffffffc02053c2:	20a60613          	addi	a2,a2,522 # ffffffffc02085c8 <default_pmm_manager+0x1010>
ffffffffc02053c6:	03100593          	li	a1,49
ffffffffc02053ca:	00003517          	auipc	a0,0x3
ffffffffc02053ce:	20e50513          	addi	a0,a0,526 # ffffffffc02085d8 <default_pmm_manager+0x1020>
ffffffffc02053d2:	8a8fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02053d6 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02053d6:	7129                	addi	sp,sp,-320
ffffffffc02053d8:	fa22                	sd	s0,304(sp)
ffffffffc02053da:	f626                	sd	s1,296(sp)
ffffffffc02053dc:	f24a                	sd	s2,288(sp)
ffffffffc02053de:	84ae                	mv	s1,a1
ffffffffc02053e0:	892a                	mv	s2,a0
ffffffffc02053e2:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053e4:	4581                	li	a1,0
ffffffffc02053e6:	12000613          	li	a2,288
ffffffffc02053ea:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02053ec:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053ee:	2da010ef          	jal	ra,ffffffffc02066c8 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02053f2:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02053f4:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02053f6:	100027f3          	csrr	a5,sstatus
ffffffffc02053fa:	edd7f793          	andi	a5,a5,-291
ffffffffc02053fe:	1207e793          	ori	a5,a5,288
ffffffffc0205402:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205404:	860a                	mv	a2,sp
ffffffffc0205406:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020540a:	00000797          	auipc	a5,0x0
ffffffffc020540e:	9e078793          	addi	a5,a5,-1568 # ffffffffc0204dea <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205412:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205414:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205416:	bbdff0ef          	jal	ra,ffffffffc0204fd2 <do_fork>
}
ffffffffc020541a:	70f2                	ld	ra,312(sp)
ffffffffc020541c:	7452                	ld	s0,304(sp)
ffffffffc020541e:	74b2                	ld	s1,296(sp)
ffffffffc0205420:	7912                	ld	s2,288(sp)
ffffffffc0205422:	6131                	addi	sp,sp,320
ffffffffc0205424:	8082                	ret

ffffffffc0205426 <do_exit>:
do_exit(int error_code) {
ffffffffc0205426:	7179                	addi	sp,sp,-48
ffffffffc0205428:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc020542a:	000ad417          	auipc	s0,0xad
ffffffffc020542e:	45e40413          	addi	s0,s0,1118 # ffffffffc02b2888 <current>
ffffffffc0205432:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc0205434:	f406                	sd	ra,40(sp)
ffffffffc0205436:	ec26                	sd	s1,24(sp)
ffffffffc0205438:	e84a                	sd	s2,16(sp)
ffffffffc020543a:	e44e                	sd	s3,8(sp)
ffffffffc020543c:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc020543e:	000ad717          	auipc	a4,0xad
ffffffffc0205442:	45273703          	ld	a4,1106(a4) # ffffffffc02b2890 <idleproc>
ffffffffc0205446:	0ce78c63          	beq	a5,a4,ffffffffc020551e <do_exit+0xf8>
    if (current == initproc) {
ffffffffc020544a:	000ad497          	auipc	s1,0xad
ffffffffc020544e:	44e48493          	addi	s1,s1,1102 # ffffffffc02b2898 <initproc>
ffffffffc0205452:	6098                	ld	a4,0(s1)
ffffffffc0205454:	0ee78b63          	beq	a5,a4,ffffffffc020554a <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc0205458:	0287b983          	ld	s3,40(a5)
ffffffffc020545c:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc020545e:	02098663          	beqz	s3,ffffffffc020548a <do_exit+0x64>
ffffffffc0205462:	000ad797          	auipc	a5,0xad
ffffffffc0205466:	3ce7b783          	ld	a5,974(a5) # ffffffffc02b2830 <boot_cr3>
ffffffffc020546a:	577d                	li	a4,-1
ffffffffc020546c:	177e                	slli	a4,a4,0x3f
ffffffffc020546e:	83b1                	srli	a5,a5,0xc
ffffffffc0205470:	8fd9                	or	a5,a5,a4
ffffffffc0205472:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205476:	0309a783          	lw	a5,48(s3)
ffffffffc020547a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020547e:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205482:	cb55                	beqz	a4,ffffffffc0205536 <do_exit+0x110>
        current->mm = NULL;
ffffffffc0205484:	601c                	ld	a5,0(s0)
ffffffffc0205486:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020548a:	601c                	ld	a5,0(s0)
ffffffffc020548c:	470d                	li	a4,3
ffffffffc020548e:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205490:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205494:	100027f3          	csrr	a5,sstatus
ffffffffc0205498:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020549a:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020549c:	e3f9                	bnez	a5,ffffffffc0205562 <do_exit+0x13c>
        proc = current->parent;
ffffffffc020549e:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02054a0:	800007b7          	lui	a5,0x80000
ffffffffc02054a4:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02054a6:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02054a8:	0ec52703          	lw	a4,236(a0)
ffffffffc02054ac:	0af70f63          	beq	a4,a5,ffffffffc020556a <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc02054b0:	6018                	ld	a4,0(s0)
ffffffffc02054b2:	7b7c                	ld	a5,240(a4)
ffffffffc02054b4:	c3a1                	beqz	a5,ffffffffc02054f4 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054b6:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054ba:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054bc:	0985                	addi	s3,s3,1
ffffffffc02054be:	a021                	j	ffffffffc02054c6 <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc02054c0:	6018                	ld	a4,0(s0)
ffffffffc02054c2:	7b7c                	ld	a5,240(a4)
ffffffffc02054c4:	cb85                	beqz	a5,ffffffffc02054f4 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc02054c6:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fd8>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02054ca:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc02054cc:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02054ce:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02054d0:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02054d4:	10e7b023          	sd	a4,256(a5)
ffffffffc02054d8:	c311                	beqz	a4,ffffffffc02054dc <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc02054da:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054dc:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02054de:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02054e0:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054e2:	fd271fe3          	bne	a4,s2,ffffffffc02054c0 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054e6:	0ec52783          	lw	a5,236(a0)
ffffffffc02054ea:	fd379be3          	bne	a5,s3,ffffffffc02054c0 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02054ee:	36f000ef          	jal	ra,ffffffffc020605c <wakeup_proc>
ffffffffc02054f2:	b7f9                	j	ffffffffc02054c0 <do_exit+0x9a>
    if (flag) {
ffffffffc02054f4:	020a1263          	bnez	s4,ffffffffc0205518 <do_exit+0xf2>
    schedule();
ffffffffc02054f8:	3e5000ef          	jal	ra,ffffffffc02060dc <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02054fc:	601c                	ld	a5,0(s0)
ffffffffc02054fe:	00003617          	auipc	a2,0x3
ffffffffc0205502:	11260613          	addi	a2,a2,274 # ffffffffc0208610 <default_pmm_manager+0x1058>
ffffffffc0205506:	21a00593          	li	a1,538
ffffffffc020550a:	43d4                	lw	a3,4(a5)
ffffffffc020550c:	00003517          	auipc	a0,0x3
ffffffffc0205510:	08450513          	addi	a0,a0,132 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205514:	f67fa0ef          	jal	ra,ffffffffc020047a <__panic>
        intr_enable();
ffffffffc0205518:	928fb0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc020551c:	bff1                	j	ffffffffc02054f8 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc020551e:	00003617          	auipc	a2,0x3
ffffffffc0205522:	0d260613          	addi	a2,a2,210 # ffffffffc02085f0 <default_pmm_manager+0x1038>
ffffffffc0205526:	1e000593          	li	a1,480
ffffffffc020552a:	00003517          	auipc	a0,0x3
ffffffffc020552e:	06650513          	addi	a0,a0,102 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205532:	f49fa0ef          	jal	ra,ffffffffc020047a <__panic>
            exit_mmap(mm);
ffffffffc0205536:	854e                	mv	a0,s3
ffffffffc0205538:	806ff0ef          	jal	ra,ffffffffc020453e <exit_mmap>
            put_pgdir(mm);
ffffffffc020553c:	854e                	mv	a0,s3
ffffffffc020553e:	9b3ff0ef          	jal	ra,ffffffffc0204ef0 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205542:	854e                	mv	a0,s3
ffffffffc0205544:	e5ffe0ef          	jal	ra,ffffffffc02043a2 <mm_destroy>
ffffffffc0205548:	bf35                	j	ffffffffc0205484 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc020554a:	00003617          	auipc	a2,0x3
ffffffffc020554e:	0b660613          	addi	a2,a2,182 # ffffffffc0208600 <default_pmm_manager+0x1048>
ffffffffc0205552:	1e300593          	li	a1,483
ffffffffc0205556:	00003517          	auipc	a0,0x3
ffffffffc020555a:	03a50513          	addi	a0,a0,58 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc020555e:	f1dfa0ef          	jal	ra,ffffffffc020047a <__panic>
        intr_disable();
ffffffffc0205562:	8e4fb0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0205566:	4a05                	li	s4,1
ffffffffc0205568:	bf1d                	j	ffffffffc020549e <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc020556a:	2f3000ef          	jal	ra,ffffffffc020605c <wakeup_proc>
ffffffffc020556e:	b789                	j	ffffffffc02054b0 <do_exit+0x8a>

ffffffffc0205570 <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc0205570:	715d                	addi	sp,sp,-80
ffffffffc0205572:	f84a                	sd	s2,48(sp)
ffffffffc0205574:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc0205576:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc020557a:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc020557c:	fc26                	sd	s1,56(sp)
ffffffffc020557e:	f052                	sd	s4,32(sp)
ffffffffc0205580:	ec56                	sd	s5,24(sp)
ffffffffc0205582:	e85a                	sd	s6,16(sp)
ffffffffc0205584:	e45e                	sd	s7,8(sp)
ffffffffc0205586:	e486                	sd	ra,72(sp)
ffffffffc0205588:	e0a2                	sd	s0,64(sp)
ffffffffc020558a:	84aa                	mv	s1,a0
ffffffffc020558c:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc020558e:	000adb97          	auipc	s7,0xad
ffffffffc0205592:	2fab8b93          	addi	s7,s7,762 # ffffffffc02b2888 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205596:	00050b1b          	sext.w	s6,a0
ffffffffc020559a:	fff50a9b          	addiw	s5,a0,-1
ffffffffc020559e:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc02055a0:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc02055a2:	ccbd                	beqz	s1,ffffffffc0205620 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02055a4:	0359e863          	bltu	s3,s5,ffffffffc02055d4 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02055a8:	45a9                	li	a1,10
ffffffffc02055aa:	855a                	mv	a0,s6
ffffffffc02055ac:	49d000ef          	jal	ra,ffffffffc0206248 <hash32>
ffffffffc02055b0:	02051793          	slli	a5,a0,0x20
ffffffffc02055b4:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02055b8:	000a9797          	auipc	a5,0xa9
ffffffffc02055bc:	24878793          	addi	a5,a5,584 # ffffffffc02ae800 <hash_list>
ffffffffc02055c0:	953e                	add	a0,a0,a5
ffffffffc02055c2:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc02055c4:	a029                	j	ffffffffc02055ce <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc02055c6:	f2c42783          	lw	a5,-212(s0)
ffffffffc02055ca:	02978163          	beq	a5,s1,ffffffffc02055ec <do_wait.part.0+0x7c>
ffffffffc02055ce:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc02055d0:	fe851be3          	bne	a0,s0,ffffffffc02055c6 <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc02055d4:	5579                	li	a0,-2
}
ffffffffc02055d6:	60a6                	ld	ra,72(sp)
ffffffffc02055d8:	6406                	ld	s0,64(sp)
ffffffffc02055da:	74e2                	ld	s1,56(sp)
ffffffffc02055dc:	7942                	ld	s2,48(sp)
ffffffffc02055de:	79a2                	ld	s3,40(sp)
ffffffffc02055e0:	7a02                	ld	s4,32(sp)
ffffffffc02055e2:	6ae2                	ld	s5,24(sp)
ffffffffc02055e4:	6b42                	ld	s6,16(sp)
ffffffffc02055e6:	6ba2                	ld	s7,8(sp)
ffffffffc02055e8:	6161                	addi	sp,sp,80
ffffffffc02055ea:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc02055ec:	000bb683          	ld	a3,0(s7)
ffffffffc02055f0:	f4843783          	ld	a5,-184(s0)
ffffffffc02055f4:	fed790e3          	bne	a5,a3,ffffffffc02055d4 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055f8:	f2842703          	lw	a4,-216(s0)
ffffffffc02055fc:	478d                	li	a5,3
ffffffffc02055fe:	0ef70b63          	beq	a4,a5,ffffffffc02056f4 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc0205602:	4785                	li	a5,1
ffffffffc0205604:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc0205606:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc020560a:	2d3000ef          	jal	ra,ffffffffc02060dc <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc020560e:	000bb783          	ld	a5,0(s7)
ffffffffc0205612:	0b07a783          	lw	a5,176(a5)
ffffffffc0205616:	8b85                	andi	a5,a5,1
ffffffffc0205618:	d7c9                	beqz	a5,ffffffffc02055a2 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc020561a:	555d                	li	a0,-9
ffffffffc020561c:	e0bff0ef          	jal	ra,ffffffffc0205426 <do_exit>
        proc = current->cptr;
ffffffffc0205620:	000bb683          	ld	a3,0(s7)
ffffffffc0205624:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205626:	d45d                	beqz	s0,ffffffffc02055d4 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205628:	470d                	li	a4,3
ffffffffc020562a:	a021                	j	ffffffffc0205632 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc020562c:	10043403          	ld	s0,256(s0)
ffffffffc0205630:	d869                	beqz	s0,ffffffffc0205602 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205632:	401c                	lw	a5,0(s0)
ffffffffc0205634:	fee79ce3          	bne	a5,a4,ffffffffc020562c <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205638:	000ad797          	auipc	a5,0xad
ffffffffc020563c:	2587b783          	ld	a5,600(a5) # ffffffffc02b2890 <idleproc>
ffffffffc0205640:	0c878963          	beq	a5,s0,ffffffffc0205712 <do_wait.part.0+0x1a2>
ffffffffc0205644:	000ad797          	auipc	a5,0xad
ffffffffc0205648:	2547b783          	ld	a5,596(a5) # ffffffffc02b2898 <initproc>
ffffffffc020564c:	0cf40363          	beq	s0,a5,ffffffffc0205712 <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc0205650:	000a0663          	beqz	s4,ffffffffc020565c <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc0205654:	0e842783          	lw	a5,232(s0)
ffffffffc0205658:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020565c:	100027f3          	csrr	a5,sstatus
ffffffffc0205660:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205662:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205664:	e7c1                	bnez	a5,ffffffffc02056ec <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205666:	6c70                	ld	a2,216(s0)
ffffffffc0205668:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc020566a:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc020566e:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0205670:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205672:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205674:	6470                	ld	a2,200(s0)
ffffffffc0205676:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0205678:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020567a:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc020567c:	c319                	beqz	a4,ffffffffc0205682 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc020567e:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc0205680:	7c7c                	ld	a5,248(s0)
ffffffffc0205682:	c3b5                	beqz	a5,ffffffffc02056e6 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc0205684:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc0205688:	000ad717          	auipc	a4,0xad
ffffffffc020568c:	21870713          	addi	a4,a4,536 # ffffffffc02b28a0 <nr_process>
ffffffffc0205690:	431c                	lw	a5,0(a4)
ffffffffc0205692:	37fd                	addiw	a5,a5,-1
ffffffffc0205694:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc0205696:	e5a9                	bnez	a1,ffffffffc02056e0 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205698:	6814                	ld	a3,16(s0)
ffffffffc020569a:	c02007b7          	lui	a5,0xc0200
ffffffffc020569e:	04f6ee63          	bltu	a3,a5,ffffffffc02056fa <do_wait.part.0+0x18a>
ffffffffc02056a2:	000ad797          	auipc	a5,0xad
ffffffffc02056a6:	1b67b783          	ld	a5,438(a5) # ffffffffc02b2858 <va_pa_offset>
ffffffffc02056aa:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02056ac:	82b1                	srli	a3,a3,0xc
ffffffffc02056ae:	000ad797          	auipc	a5,0xad
ffffffffc02056b2:	1927b783          	ld	a5,402(a5) # ffffffffc02b2840 <npage>
ffffffffc02056b6:	06f6fa63          	bgeu	a3,a5,ffffffffc020572a <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc02056ba:	00003517          	auipc	a0,0x3
ffffffffc02056be:	78e53503          	ld	a0,1934(a0) # ffffffffc0208e48 <nbase>
ffffffffc02056c2:	8e89                	sub	a3,a3,a0
ffffffffc02056c4:	069a                	slli	a3,a3,0x6
ffffffffc02056c6:	000ad517          	auipc	a0,0xad
ffffffffc02056ca:	18253503          	ld	a0,386(a0) # ffffffffc02b2848 <pages>
ffffffffc02056ce:	9536                	add	a0,a0,a3
ffffffffc02056d0:	4589                	li	a1,2
ffffffffc02056d2:	9cdfc0ef          	jal	ra,ffffffffc020209e <free_pages>
    kfree(proc);
ffffffffc02056d6:	8522                	mv	a0,s0
ffffffffc02056d8:	807fc0ef          	jal	ra,ffffffffc0201ede <kfree>
    return 0;
ffffffffc02056dc:	4501                	li	a0,0
ffffffffc02056de:	bde5                	j	ffffffffc02055d6 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc02056e0:	f61fa0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc02056e4:	bf55                	j	ffffffffc0205698 <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc02056e6:	701c                	ld	a5,32(s0)
ffffffffc02056e8:	fbf8                	sd	a4,240(a5)
ffffffffc02056ea:	bf79                	j	ffffffffc0205688 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc02056ec:	f5bfa0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc02056f0:	4585                	li	a1,1
ffffffffc02056f2:	bf95                	j	ffffffffc0205666 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02056f4:	f2840413          	addi	s0,s0,-216
ffffffffc02056f8:	b781                	j	ffffffffc0205638 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc02056fa:	00002617          	auipc	a2,0x2
ffffffffc02056fe:	f6660613          	addi	a2,a2,-154 # ffffffffc0207660 <default_pmm_manager+0xa8>
ffffffffc0205702:	06e00593          	li	a1,110
ffffffffc0205706:	00002517          	auipc	a0,0x2
ffffffffc020570a:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0207150 <commands+0x7f0>
ffffffffc020570e:	d6dfa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc0205712:	00003617          	auipc	a2,0x3
ffffffffc0205716:	f1e60613          	addi	a2,a2,-226 # ffffffffc0208630 <default_pmm_manager+0x1078>
ffffffffc020571a:	32500593          	li	a1,805
ffffffffc020571e:	00003517          	auipc	a0,0x3
ffffffffc0205722:	e7250513          	addi	a0,a0,-398 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205726:	d55fa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020572a:	00002617          	auipc	a2,0x2
ffffffffc020572e:	a3660613          	addi	a2,a2,-1482 # ffffffffc0207160 <commands+0x800>
ffffffffc0205732:	06200593          	li	a1,98
ffffffffc0205736:	00002517          	auipc	a0,0x2
ffffffffc020573a:	a1a50513          	addi	a0,a0,-1510 # ffffffffc0207150 <commands+0x7f0>
ffffffffc020573e:	d3dfa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205742 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0205742:	1141                	addi	sp,sp,-16
ffffffffc0205744:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205746:	999fc0ef          	jal	ra,ffffffffc02020de <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc020574a:	ee0fc0ef          	jal	ra,ffffffffc0201e2a <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc020574e:	4601                	li	a2,0
ffffffffc0205750:	4581                	li	a1,0
ffffffffc0205752:	fffff517          	auipc	a0,0xfffff
ffffffffc0205756:	72050513          	addi	a0,a0,1824 # ffffffffc0204e72 <user_main>
ffffffffc020575a:	c7dff0ef          	jal	ra,ffffffffc02053d6 <kernel_thread>
    if (pid <= 0) {
ffffffffc020575e:	00a04563          	bgtz	a0,ffffffffc0205768 <init_main+0x26>
ffffffffc0205762:	a071                	j	ffffffffc02057ee <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0205764:	179000ef          	jal	ra,ffffffffc02060dc <schedule>
    if (code_store != NULL) {
ffffffffc0205768:	4581                	li	a1,0
ffffffffc020576a:	4501                	li	a0,0
ffffffffc020576c:	e05ff0ef          	jal	ra,ffffffffc0205570 <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc0205770:	d975                	beqz	a0,ffffffffc0205764 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205772:	00003517          	auipc	a0,0x3
ffffffffc0205776:	efe50513          	addi	a0,a0,-258 # ffffffffc0208670 <default_pmm_manager+0x10b8>
ffffffffc020577a:	a07fa0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020577e:	000ad797          	auipc	a5,0xad
ffffffffc0205782:	11a7b783          	ld	a5,282(a5) # ffffffffc02b2898 <initproc>
ffffffffc0205786:	7bf8                	ld	a4,240(a5)
ffffffffc0205788:	e339                	bnez	a4,ffffffffc02057ce <init_main+0x8c>
ffffffffc020578a:	7ff8                	ld	a4,248(a5)
ffffffffc020578c:	e329                	bnez	a4,ffffffffc02057ce <init_main+0x8c>
ffffffffc020578e:	1007b703          	ld	a4,256(a5)
ffffffffc0205792:	ef15                	bnez	a4,ffffffffc02057ce <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0205794:	000ad697          	auipc	a3,0xad
ffffffffc0205798:	10c6a683          	lw	a3,268(a3) # ffffffffc02b28a0 <nr_process>
ffffffffc020579c:	4709                	li	a4,2
ffffffffc020579e:	0ae69463          	bne	a3,a4,ffffffffc0205846 <init_main+0x104>
    return listelm->next;
ffffffffc02057a2:	000ad697          	auipc	a3,0xad
ffffffffc02057a6:	05e68693          	addi	a3,a3,94 # ffffffffc02b2800 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02057aa:	6698                	ld	a4,8(a3)
ffffffffc02057ac:	0c878793          	addi	a5,a5,200
ffffffffc02057b0:	06f71b63          	bne	a4,a5,ffffffffc0205826 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02057b4:	629c                	ld	a5,0(a3)
ffffffffc02057b6:	04f71863          	bne	a4,a5,ffffffffc0205806 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc02057ba:	00003517          	auipc	a0,0x3
ffffffffc02057be:	f9e50513          	addi	a0,a0,-98 # ffffffffc0208758 <default_pmm_manager+0x11a0>
ffffffffc02057c2:	9bffa0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
}
ffffffffc02057c6:	60a2                	ld	ra,8(sp)
ffffffffc02057c8:	4501                	li	a0,0
ffffffffc02057ca:	0141                	addi	sp,sp,16
ffffffffc02057cc:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02057ce:	00003697          	auipc	a3,0x3
ffffffffc02057d2:	eca68693          	addi	a3,a3,-310 # ffffffffc0208698 <default_pmm_manager+0x10e0>
ffffffffc02057d6:	00001617          	auipc	a2,0x1
ffffffffc02057da:	5da60613          	addi	a2,a2,1498 # ffffffffc0206db0 <commands+0x450>
ffffffffc02057de:	39500593          	li	a1,917
ffffffffc02057e2:	00003517          	auipc	a0,0x3
ffffffffc02057e6:	dae50513          	addi	a0,a0,-594 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc02057ea:	c91fa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("create user_main failed.\n");
ffffffffc02057ee:	00003617          	auipc	a2,0x3
ffffffffc02057f2:	e6260613          	addi	a2,a2,-414 # ffffffffc0208650 <default_pmm_manager+0x1098>
ffffffffc02057f6:	38d00593          	li	a1,909
ffffffffc02057fa:	00003517          	auipc	a0,0x3
ffffffffc02057fe:	d9650513          	addi	a0,a0,-618 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205802:	c79fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205806:	00003697          	auipc	a3,0x3
ffffffffc020580a:	f2268693          	addi	a3,a3,-222 # ffffffffc0208728 <default_pmm_manager+0x1170>
ffffffffc020580e:	00001617          	auipc	a2,0x1
ffffffffc0205812:	5a260613          	addi	a2,a2,1442 # ffffffffc0206db0 <commands+0x450>
ffffffffc0205816:	39800593          	li	a1,920
ffffffffc020581a:	00003517          	auipc	a0,0x3
ffffffffc020581e:	d7650513          	addi	a0,a0,-650 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205822:	c59fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205826:	00003697          	auipc	a3,0x3
ffffffffc020582a:	ed268693          	addi	a3,a3,-302 # ffffffffc02086f8 <default_pmm_manager+0x1140>
ffffffffc020582e:	00001617          	auipc	a2,0x1
ffffffffc0205832:	58260613          	addi	a2,a2,1410 # ffffffffc0206db0 <commands+0x450>
ffffffffc0205836:	39700593          	li	a1,919
ffffffffc020583a:	00003517          	auipc	a0,0x3
ffffffffc020583e:	d5650513          	addi	a0,a0,-682 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205842:	c39fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_process == 2);
ffffffffc0205846:	00003697          	auipc	a3,0x3
ffffffffc020584a:	ea268693          	addi	a3,a3,-350 # ffffffffc02086e8 <default_pmm_manager+0x1130>
ffffffffc020584e:	00001617          	auipc	a2,0x1
ffffffffc0205852:	56260613          	addi	a2,a2,1378 # ffffffffc0206db0 <commands+0x450>
ffffffffc0205856:	39600593          	li	a1,918
ffffffffc020585a:	00003517          	auipc	a0,0x3
ffffffffc020585e:	d3650513          	addi	a0,a0,-714 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205862:	c19fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205866 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205866:	7171                	addi	sp,sp,-176
ffffffffc0205868:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020586a:	000add97          	auipc	s11,0xad
ffffffffc020586e:	01ed8d93          	addi	s11,s11,30 # ffffffffc02b2888 <current>
ffffffffc0205872:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205876:	e54e                	sd	s3,136(sp)
ffffffffc0205878:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020587a:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020587e:	e94a                	sd	s2,144(sp)
ffffffffc0205880:	f4de                	sd	s7,104(sp)
ffffffffc0205882:	892a                	mv	s2,a0
ffffffffc0205884:	8bb2                	mv	s7,a2
ffffffffc0205886:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) { //检查name的内存空间能否被访问
ffffffffc0205888:	862e                	mv	a2,a1
ffffffffc020588a:	4681                	li	a3,0
ffffffffc020588c:	85aa                	mv	a1,a0
ffffffffc020588e:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205890:	f506                	sd	ra,168(sp)
ffffffffc0205892:	f122                	sd	s0,160(sp)
ffffffffc0205894:	e152                	sd	s4,128(sp)
ffffffffc0205896:	fcd6                	sd	s5,120(sp)
ffffffffc0205898:	f8da                	sd	s6,112(sp)
ffffffffc020589a:	f0e2                	sd	s8,96(sp)
ffffffffc020589c:	ece6                	sd	s9,88(sp)
ffffffffc020589e:	e8ea                	sd	s10,80(sp)
ffffffffc02058a0:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) { //检查name的内存空间能否被访问
ffffffffc02058a2:	b60ff0ef          	jal	ra,ffffffffc0204c02 <user_mem_check>
ffffffffc02058a6:	40050863          	beqz	a0,ffffffffc0205cb6 <do_execve+0x450>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02058aa:	4641                	li	a2,16
ffffffffc02058ac:	4581                	li	a1,0
ffffffffc02058ae:	1808                	addi	a0,sp,48
ffffffffc02058b0:	619000ef          	jal	ra,ffffffffc02066c8 <memset>
    memcpy(local_name, name, len);
ffffffffc02058b4:	47bd                	li	a5,15
ffffffffc02058b6:	8626                	mv	a2,s1
ffffffffc02058b8:	1e97e063          	bltu	a5,s1,ffffffffc0205a98 <do_execve+0x232>
ffffffffc02058bc:	85ca                	mv	a1,s2
ffffffffc02058be:	1808                	addi	a0,sp,48
ffffffffc02058c0:	61b000ef          	jal	ra,ffffffffc02066da <memcpy>
    if (mm != NULL) {
ffffffffc02058c4:	1e098163          	beqz	s3,ffffffffc0205aa6 <do_execve+0x240>
        cputs("mm != NULL");
ffffffffc02058c8:	00002517          	auipc	a0,0x2
ffffffffc02058cc:	38050513          	addi	a0,a0,896 # ffffffffc0207c48 <default_pmm_manager+0x690>
ffffffffc02058d0:	8e9fa0ef          	jal	ra,ffffffffc02001b8 <cputs>
ffffffffc02058d4:	000ad797          	auipc	a5,0xad
ffffffffc02058d8:	f5c7b783          	ld	a5,-164(a5) # ffffffffc02b2830 <boot_cr3>
ffffffffc02058dc:	577d                	li	a4,-1
ffffffffc02058de:	177e                	slli	a4,a4,0x3f
ffffffffc02058e0:	83b1                	srli	a5,a5,0xc
ffffffffc02058e2:	8fd9                	or	a5,a5,a4
ffffffffc02058e4:	18079073          	csrw	satp,a5
ffffffffc02058e8:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b80>
ffffffffc02058ec:	fff7871b          	addiw	a4,a5,-1
ffffffffc02058f0:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc02058f4:	2c070263          	beqz	a4,ffffffffc0205bb8 <do_execve+0x352>
        current->mm = NULL;
ffffffffc02058f8:	000db783          	ld	a5,0(s11)
ffffffffc02058fc:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205900:	91dfe0ef          	jal	ra,ffffffffc020421c <mm_create>
ffffffffc0205904:	84aa                	mv	s1,a0
ffffffffc0205906:	1c050b63          	beqz	a0,ffffffffc0205adc <do_execve+0x276>
    if ((page = alloc_page()) == NULL) {
ffffffffc020590a:	4505                	li	a0,1
ffffffffc020590c:	f00fc0ef          	jal	ra,ffffffffc020200c <alloc_pages>
ffffffffc0205910:	3a050763          	beqz	a0,ffffffffc0205cbe <do_execve+0x458>
    return page - pages + nbase;
ffffffffc0205914:	000adc97          	auipc	s9,0xad
ffffffffc0205918:	f34c8c93          	addi	s9,s9,-204 # ffffffffc02b2848 <pages>
ffffffffc020591c:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc0205920:	000adc17          	auipc	s8,0xad
ffffffffc0205924:	f20c0c13          	addi	s8,s8,-224 # ffffffffc02b2840 <npage>
    return page - pages + nbase;
ffffffffc0205928:	00003717          	auipc	a4,0x3
ffffffffc020592c:	52073703          	ld	a4,1312(a4) # ffffffffc0208e48 <nbase>
ffffffffc0205930:	40d506b3          	sub	a3,a0,a3
ffffffffc0205934:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205936:	5afd                	li	s5,-1
ffffffffc0205938:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc020593c:	96ba                	add	a3,a3,a4
ffffffffc020593e:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205940:	00cad713          	srli	a4,s5,0xc
ffffffffc0205944:	ec3a                	sd	a4,24(sp)
ffffffffc0205946:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205948:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020594a:	36f77e63          	bgeu	a4,a5,ffffffffc0205cc6 <do_execve+0x460>
ffffffffc020594e:	000adb17          	auipc	s6,0xad
ffffffffc0205952:	f0ab0b13          	addi	s6,s6,-246 # ffffffffc02b2858 <va_pa_offset>
ffffffffc0205956:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc020595a:	6605                	lui	a2,0x1
ffffffffc020595c:	000ad597          	auipc	a1,0xad
ffffffffc0205960:	edc5b583          	ld	a1,-292(a1) # ffffffffc02b2838 <boot_pgdir>
ffffffffc0205964:	9936                	add	s2,s2,a3
ffffffffc0205966:	854a                	mv	a0,s2
ffffffffc0205968:	573000ef          	jal	ra,ffffffffc02066da <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc020596c:	7782                	ld	a5,32(sp)
ffffffffc020596e:	4398                	lw	a4,0(a5)
ffffffffc0205970:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0205974:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205978:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9457>
ffffffffc020597c:	14f71663          	bne	a4,a5,ffffffffc0205ac8 <do_execve+0x262>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205980:	7682                	ld	a3,32(sp)
ffffffffc0205982:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205986:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020598a:	00371793          	slli	a5,a4,0x3
ffffffffc020598e:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205990:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205992:	078e                	slli	a5,a5,0x3
ffffffffc0205994:	97ce                	add	a5,a5,s3
ffffffffc0205996:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0205998:	00f9fc63          	bgeu	s3,a5,ffffffffc02059b0 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc020599c:	0009a783          	lw	a5,0(s3)
ffffffffc02059a0:	4705                	li	a4,1
ffffffffc02059a2:	12e78f63          	beq	a5,a4,ffffffffc0205ae0 <do_execve+0x27a>
    for (; ph < ph_end; ph ++) {
ffffffffc02059a6:	77a2                	ld	a5,40(sp)
ffffffffc02059a8:	03898993          	addi	s3,s3,56
ffffffffc02059ac:	fef9e8e3          	bltu	s3,a5,ffffffffc020599c <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc02059b0:	4701                	li	a4,0
ffffffffc02059b2:	46ad                	li	a3,11
ffffffffc02059b4:	00100637          	lui	a2,0x100
ffffffffc02059b8:	7ff005b7          	lui	a1,0x7ff00
ffffffffc02059bc:	8526                	mv	a0,s1
ffffffffc02059be:	a37fe0ef          	jal	ra,ffffffffc02043f4 <mm_map>
ffffffffc02059c2:	8a2a                	mv	s4,a0
ffffffffc02059c4:	1e051063          	bnez	a0,ffffffffc0205ba4 <do_execve+0x33e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc02059c8:	6c88                	ld	a0,24(s1)
ffffffffc02059ca:	467d                	li	a2,31
ffffffffc02059cc:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02059d0:	a79fd0ef          	jal	ra,ffffffffc0203448 <pgdir_alloc_page>
ffffffffc02059d4:	38050163          	beqz	a0,ffffffffc0205d56 <do_execve+0x4f0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc02059d8:	6c88                	ld	a0,24(s1)
ffffffffc02059da:	467d                	li	a2,31
ffffffffc02059dc:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02059e0:	a69fd0ef          	jal	ra,ffffffffc0203448 <pgdir_alloc_page>
ffffffffc02059e4:	34050963          	beqz	a0,ffffffffc0205d36 <do_execve+0x4d0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc02059e8:	6c88                	ld	a0,24(s1)
ffffffffc02059ea:	467d                	li	a2,31
ffffffffc02059ec:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02059f0:	a59fd0ef          	jal	ra,ffffffffc0203448 <pgdir_alloc_page>
ffffffffc02059f4:	32050163          	beqz	a0,ffffffffc0205d16 <do_execve+0x4b0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc02059f8:	6c88                	ld	a0,24(s1)
ffffffffc02059fa:	467d                	li	a2,31
ffffffffc02059fc:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205a00:	a49fd0ef          	jal	ra,ffffffffc0203448 <pgdir_alloc_page>
ffffffffc0205a04:	2e050963          	beqz	a0,ffffffffc0205cf6 <do_execve+0x490>
    mm->mm_count += 1;
ffffffffc0205a08:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0205a0a:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205a0e:	6c94                	ld	a3,24(s1)
ffffffffc0205a10:	2785                	addiw	a5,a5,1
ffffffffc0205a12:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0205a14:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205a16:	c02007b7          	lui	a5,0xc0200
ffffffffc0205a1a:	2cf6e263          	bltu	a3,a5,ffffffffc0205cde <do_execve+0x478>
ffffffffc0205a1e:	000b3783          	ld	a5,0(s6)
ffffffffc0205a22:	577d                	li	a4,-1
ffffffffc0205a24:	177e                	slli	a4,a4,0x3f
ffffffffc0205a26:	8e9d                	sub	a3,a3,a5
ffffffffc0205a28:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205a2c:	f654                	sd	a3,168(a2)
ffffffffc0205a2e:	8fd9                	or	a5,a5,a4
ffffffffc0205a30:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205a34:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a36:	4581                	li	a1,0
ffffffffc0205a38:	12000613          	li	a2,288
ffffffffc0205a3c:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205a3e:	10043903          	ld	s2,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a42:	487000ef          	jal	ra,ffffffffc02066c8 <memset>
    tf->epc = elf->e_entry; // tf->epc应该是用户程序的入口点（sepc的值）
ffffffffc0205a46:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205a48:	000db483          	ld	s1,0(s11)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE); // tf->status应该适合用户程序（sstatus的值）
ffffffffc0205a4c:	edf97913          	andi	s2,s2,-289
    tf->epc = elf->e_entry; // tf->epc应该是用户程序的入口点（sepc的值）
ffffffffc0205a50:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP; // tf->gpr.sp应该是用户堆栈顶部（sp的值）
ffffffffc0205a52:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205a54:	0b448493          	addi	s1,s1,180
    tf->gpr.sp = USTACKTOP; // tf->gpr.sp应该是用户堆栈顶部（sp的值）
ffffffffc0205a58:	07fe                	slli	a5,a5,0x1f
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205a5a:	4641                	li	a2,16
ffffffffc0205a5c:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP; // tf->gpr.sp应该是用户堆栈顶部（sp的值）
ffffffffc0205a5e:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry; // tf->epc应该是用户程序的入口点（sepc的值）
ffffffffc0205a60:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE); // tf->status应该适合用户程序（sstatus的值）
ffffffffc0205a64:	11243023          	sd	s2,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205a68:	8526                	mv	a0,s1
ffffffffc0205a6a:	45f000ef          	jal	ra,ffffffffc02066c8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205a6e:	463d                	li	a2,15
ffffffffc0205a70:	180c                	addi	a1,sp,48
ffffffffc0205a72:	8526                	mv	a0,s1
ffffffffc0205a74:	467000ef          	jal	ra,ffffffffc02066da <memcpy>
}
ffffffffc0205a78:	70aa                	ld	ra,168(sp)
ffffffffc0205a7a:	740a                	ld	s0,160(sp)
ffffffffc0205a7c:	64ea                	ld	s1,152(sp)
ffffffffc0205a7e:	694a                	ld	s2,144(sp)
ffffffffc0205a80:	69aa                	ld	s3,136(sp)
ffffffffc0205a82:	7ae6                	ld	s5,120(sp)
ffffffffc0205a84:	7b46                	ld	s6,112(sp)
ffffffffc0205a86:	7ba6                	ld	s7,104(sp)
ffffffffc0205a88:	7c06                	ld	s8,96(sp)
ffffffffc0205a8a:	6ce6                	ld	s9,88(sp)
ffffffffc0205a8c:	6d46                	ld	s10,80(sp)
ffffffffc0205a8e:	6da6                	ld	s11,72(sp)
ffffffffc0205a90:	8552                	mv	a0,s4
ffffffffc0205a92:	6a0a                	ld	s4,128(sp)
ffffffffc0205a94:	614d                	addi	sp,sp,176
ffffffffc0205a96:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0205a98:	463d                	li	a2,15
ffffffffc0205a9a:	85ca                	mv	a1,s2
ffffffffc0205a9c:	1808                	addi	a0,sp,48
ffffffffc0205a9e:	43d000ef          	jal	ra,ffffffffc02066da <memcpy>
    if (mm != NULL) {
ffffffffc0205aa2:	e20993e3          	bnez	s3,ffffffffc02058c8 <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc0205aa6:	000db783          	ld	a5,0(s11)
ffffffffc0205aaa:	779c                	ld	a5,40(a5)
ffffffffc0205aac:	e4078ae3          	beqz	a5,ffffffffc0205900 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205ab0:	00003617          	auipc	a2,0x3
ffffffffc0205ab4:	cc860613          	addi	a2,a2,-824 # ffffffffc0208778 <default_pmm_manager+0x11c0>
ffffffffc0205ab8:	22800593          	li	a1,552
ffffffffc0205abc:	00003517          	auipc	a0,0x3
ffffffffc0205ac0:	ad450513          	addi	a0,a0,-1324 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205ac4:	9b7fa0ef          	jal	ra,ffffffffc020047a <__panic>
    put_pgdir(mm);
ffffffffc0205ac8:	8526                	mv	a0,s1
ffffffffc0205aca:	c26ff0ef          	jal	ra,ffffffffc0204ef0 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205ace:	8526                	mv	a0,s1
ffffffffc0205ad0:	8d3fe0ef          	jal	ra,ffffffffc02043a2 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205ad4:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc0205ad6:	8552                	mv	a0,s4
ffffffffc0205ad8:	94fff0ef          	jal	ra,ffffffffc0205426 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0205adc:	5a71                	li	s4,-4
ffffffffc0205ade:	bfe5                	j	ffffffffc0205ad6 <do_execve+0x270>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205ae0:	0289b603          	ld	a2,40(s3)
ffffffffc0205ae4:	0209b783          	ld	a5,32(s3)
ffffffffc0205ae8:	1cf66d63          	bltu	a2,a5,ffffffffc0205cc2 <do_execve+0x45c>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205aec:	0049a783          	lw	a5,4(s3)
ffffffffc0205af0:	0017f693          	andi	a3,a5,1
ffffffffc0205af4:	c291                	beqz	a3,ffffffffc0205af8 <do_execve+0x292>
ffffffffc0205af6:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205af8:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205afc:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205afe:	e779                	bnez	a4,ffffffffc0205bcc <do_execve+0x366>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205b00:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b02:	c781                	beqz	a5,ffffffffc0205b0a <do_execve+0x2a4>
ffffffffc0205b04:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205b08:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205b0a:	0026f793          	andi	a5,a3,2
ffffffffc0205b0e:	e3f1                	bnez	a5,ffffffffc0205bd2 <do_execve+0x36c>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205b10:	0046f793          	andi	a5,a3,4
ffffffffc0205b14:	c399                	beqz	a5,ffffffffc0205b1a <do_execve+0x2b4>
ffffffffc0205b16:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205b1a:	0109b583          	ld	a1,16(s3)
ffffffffc0205b1e:	4701                	li	a4,0
ffffffffc0205b20:	8526                	mv	a0,s1
ffffffffc0205b22:	8d3fe0ef          	jal	ra,ffffffffc02043f4 <mm_map>
ffffffffc0205b26:	8a2a                	mv	s4,a0
ffffffffc0205b28:	ed35                	bnez	a0,ffffffffc0205ba4 <do_execve+0x33e>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205b2a:	0109bb83          	ld	s7,16(s3)
ffffffffc0205b2e:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205b30:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205b34:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205b38:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205b3c:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205b3e:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205b40:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc0205b42:	054be963          	bltu	s7,s4,ffffffffc0205b94 <do_execve+0x32e>
ffffffffc0205b46:	aa95                	j	ffffffffc0205cba <do_execve+0x454>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205b48:	6785                	lui	a5,0x1
ffffffffc0205b4a:	415b8533          	sub	a0,s7,s5
ffffffffc0205b4e:	9abe                	add	s5,s5,a5
ffffffffc0205b50:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205b54:	015a7463          	bgeu	s4,s5,ffffffffc0205b5c <do_execve+0x2f6>
                size -= la - end;
ffffffffc0205b58:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0205b5c:	000cb683          	ld	a3,0(s9)
ffffffffc0205b60:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205b62:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205b66:	40d406b3          	sub	a3,s0,a3
ffffffffc0205b6a:	8699                	srai	a3,a3,0x6
ffffffffc0205b6c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205b6e:	67e2                	ld	a5,24(sp)
ffffffffc0205b70:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b74:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b76:	14b87863          	bgeu	a6,a1,ffffffffc0205cc6 <do_execve+0x460>
ffffffffc0205b7a:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b7e:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0205b80:	9bb2                	add	s7,s7,a2
ffffffffc0205b82:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b84:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205b86:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b88:	353000ef          	jal	ra,ffffffffc02066da <memcpy>
            start += size, from += size;
ffffffffc0205b8c:	6622                	ld	a2,8(sp)
ffffffffc0205b8e:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc0205b90:	054bf363          	bgeu	s7,s4,ffffffffc0205bd6 <do_execve+0x370>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205b94:	6c88                	ld	a0,24(s1)
ffffffffc0205b96:	866a                	mv	a2,s10
ffffffffc0205b98:	85d6                	mv	a1,s5
ffffffffc0205b9a:	8affd0ef          	jal	ra,ffffffffc0203448 <pgdir_alloc_page>
ffffffffc0205b9e:	842a                	mv	s0,a0
ffffffffc0205ba0:	f545                	bnez	a0,ffffffffc0205b48 <do_execve+0x2e2>
        ret = -E_NO_MEM;
ffffffffc0205ba2:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0205ba4:	8526                	mv	a0,s1
ffffffffc0205ba6:	999fe0ef          	jal	ra,ffffffffc020453e <exit_mmap>
    put_pgdir(mm);
ffffffffc0205baa:	8526                	mv	a0,s1
ffffffffc0205bac:	b44ff0ef          	jal	ra,ffffffffc0204ef0 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205bb0:	8526                	mv	a0,s1
ffffffffc0205bb2:	ff0fe0ef          	jal	ra,ffffffffc02043a2 <mm_destroy>
    return ret;
ffffffffc0205bb6:	b705                	j	ffffffffc0205ad6 <do_execve+0x270>
            exit_mmap(mm); // 释放当前进程的内存空间（解除映射，释放页表对应物理内存）
ffffffffc0205bb8:	854e                	mv	a0,s3
ffffffffc0205bba:	985fe0ef          	jal	ra,ffffffffc020453e <exit_mmap>
            put_pgdir(mm); // 释放当前进程的页目录表
ffffffffc0205bbe:	854e                	mv	a0,s3
ffffffffc0205bc0:	b30ff0ef          	jal	ra,ffffffffc0204ef0 <put_pgdir>
            mm_destroy(mm);// 销毁并释放内存管理结构体 mm_struct 及其内部字段
ffffffffc0205bc4:	854e                	mv	a0,s3
ffffffffc0205bc6:	fdcfe0ef          	jal	ra,ffffffffc02043a2 <mm_destroy>
ffffffffc0205bca:	b33d                	j	ffffffffc02058f8 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205bcc:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205bd0:	fb95                	bnez	a5,ffffffffc0205b04 <do_execve+0x29e>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205bd2:	4d5d                	li	s10,23
ffffffffc0205bd4:	bf35                	j	ffffffffc0205b10 <do_execve+0x2aa>
        end = ph->p_va + ph->p_memsz;
ffffffffc0205bd6:	0109b683          	ld	a3,16(s3)
ffffffffc0205bda:	0289b903          	ld	s2,40(s3)
ffffffffc0205bde:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc0205be0:	075bfd63          	bgeu	s7,s5,ffffffffc0205c5a <do_execve+0x3f4>
            if (start == end) {
ffffffffc0205be4:	dd7901e3          	beq	s2,s7,ffffffffc02059a6 <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205be8:	6785                	lui	a5,0x1
ffffffffc0205bea:	00fb8533          	add	a0,s7,a5
ffffffffc0205bee:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0205bf2:	41790a33          	sub	s4,s2,s7
            if (end < la) {
ffffffffc0205bf6:	0b597d63          	bgeu	s2,s5,ffffffffc0205cb0 <do_execve+0x44a>
    return page - pages + nbase;
ffffffffc0205bfa:	000cb683          	ld	a3,0(s9)
ffffffffc0205bfe:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205c00:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0205c04:	40d406b3          	sub	a3,s0,a3
ffffffffc0205c08:	8699                	srai	a3,a3,0x6
ffffffffc0205c0a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205c0c:	67e2                	ld	a5,24(sp)
ffffffffc0205c0e:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c12:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c14:	0ac5f963          	bgeu	a1,a2,ffffffffc0205cc6 <do_execve+0x460>
ffffffffc0205c18:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c1c:	8652                	mv	a2,s4
ffffffffc0205c1e:	4581                	li	a1,0
ffffffffc0205c20:	96c2                	add	a3,a3,a6
ffffffffc0205c22:	9536                	add	a0,a0,a3
ffffffffc0205c24:	2a5000ef          	jal	ra,ffffffffc02066c8 <memset>
            start += size;
ffffffffc0205c28:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205c2c:	03597463          	bgeu	s2,s5,ffffffffc0205c54 <do_execve+0x3ee>
ffffffffc0205c30:	d6e90be3          	beq	s2,a4,ffffffffc02059a6 <do_execve+0x140>
ffffffffc0205c34:	00003697          	auipc	a3,0x3
ffffffffc0205c38:	b6c68693          	addi	a3,a3,-1172 # ffffffffc02087a0 <default_pmm_manager+0x11e8>
ffffffffc0205c3c:	00001617          	auipc	a2,0x1
ffffffffc0205c40:	17460613          	addi	a2,a2,372 # ffffffffc0206db0 <commands+0x450>
ffffffffc0205c44:	27d00593          	li	a1,637
ffffffffc0205c48:	00003517          	auipc	a0,0x3
ffffffffc0205c4c:	94850513          	addi	a0,a0,-1720 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205c50:	82bfa0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0205c54:	ff5710e3          	bne	a4,s5,ffffffffc0205c34 <do_execve+0x3ce>
ffffffffc0205c58:	8bd6                	mv	s7,s5
        while (start < end) {
ffffffffc0205c5a:	d52bf6e3          	bgeu	s7,s2,ffffffffc02059a6 <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205c5e:	6c88                	ld	a0,24(s1)
ffffffffc0205c60:	866a                	mv	a2,s10
ffffffffc0205c62:	85d6                	mv	a1,s5
ffffffffc0205c64:	fe4fd0ef          	jal	ra,ffffffffc0203448 <pgdir_alloc_page>
ffffffffc0205c68:	842a                	mv	s0,a0
ffffffffc0205c6a:	dd05                	beqz	a0,ffffffffc0205ba2 <do_execve+0x33c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205c6c:	6785                	lui	a5,0x1
ffffffffc0205c6e:	415b8533          	sub	a0,s7,s5
ffffffffc0205c72:	9abe                	add	s5,s5,a5
ffffffffc0205c74:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205c78:	01597463          	bgeu	s2,s5,ffffffffc0205c80 <do_execve+0x41a>
                size -= la - end;
ffffffffc0205c7c:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0205c80:	000cb683          	ld	a3,0(s9)
ffffffffc0205c84:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205c86:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205c8a:	40d406b3          	sub	a3,s0,a3
ffffffffc0205c8e:	8699                	srai	a3,a3,0x6
ffffffffc0205c90:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205c92:	67e2                	ld	a5,24(sp)
ffffffffc0205c94:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c98:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c9a:	02b87663          	bgeu	a6,a1,ffffffffc0205cc6 <do_execve+0x460>
ffffffffc0205c9e:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205ca2:	4581                	li	a1,0
            start += size;
ffffffffc0205ca4:	9bb2                	add	s7,s7,a2
ffffffffc0205ca6:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205ca8:	9536                	add	a0,a0,a3
ffffffffc0205caa:	21f000ef          	jal	ra,ffffffffc02066c8 <memset>
ffffffffc0205cae:	b775                	j	ffffffffc0205c5a <do_execve+0x3f4>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205cb0:	417a8a33          	sub	s4,s5,s7
ffffffffc0205cb4:	b799                	j	ffffffffc0205bfa <do_execve+0x394>
        return -E_INVAL;
ffffffffc0205cb6:	5a75                	li	s4,-3
ffffffffc0205cb8:	b3c1                	j	ffffffffc0205a78 <do_execve+0x212>
        while (start < end) {
ffffffffc0205cba:	86de                	mv	a3,s7
ffffffffc0205cbc:	bf39                	j	ffffffffc0205bda <do_execve+0x374>
    int ret = -E_NO_MEM;
ffffffffc0205cbe:	5a71                	li	s4,-4
ffffffffc0205cc0:	bdc5                	j	ffffffffc0205bb0 <do_execve+0x34a>
            ret = -E_INVAL_ELF;
ffffffffc0205cc2:	5a61                	li	s4,-8
ffffffffc0205cc4:	b5c5                	j	ffffffffc0205ba4 <do_execve+0x33e>
ffffffffc0205cc6:	00001617          	auipc	a2,0x1
ffffffffc0205cca:	52260613          	addi	a2,a2,1314 # ffffffffc02071e8 <commands+0x888>
ffffffffc0205cce:	06900593          	li	a1,105
ffffffffc0205cd2:	00001517          	auipc	a0,0x1
ffffffffc0205cd6:	47e50513          	addi	a0,a0,1150 # ffffffffc0207150 <commands+0x7f0>
ffffffffc0205cda:	fa0fa0ef          	jal	ra,ffffffffc020047a <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205cde:	00002617          	auipc	a2,0x2
ffffffffc0205ce2:	98260613          	addi	a2,a2,-1662 # ffffffffc0207660 <default_pmm_manager+0xa8>
ffffffffc0205ce6:	29900593          	li	a1,665
ffffffffc0205cea:	00003517          	auipc	a0,0x3
ffffffffc0205cee:	8a650513          	addi	a0,a0,-1882 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205cf2:	f88fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cf6:	00003697          	auipc	a3,0x3
ffffffffc0205cfa:	bc268693          	addi	a3,a3,-1086 # ffffffffc02088b8 <default_pmm_manager+0x1300>
ffffffffc0205cfe:	00001617          	auipc	a2,0x1
ffffffffc0205d02:	0b260613          	addi	a2,a2,178 # ffffffffc0206db0 <commands+0x450>
ffffffffc0205d06:	29400593          	li	a1,660
ffffffffc0205d0a:	00003517          	auipc	a0,0x3
ffffffffc0205d0e:	88650513          	addi	a0,a0,-1914 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205d12:	f68fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205d16:	00003697          	auipc	a3,0x3
ffffffffc0205d1a:	b5a68693          	addi	a3,a3,-1190 # ffffffffc0208870 <default_pmm_manager+0x12b8>
ffffffffc0205d1e:	00001617          	auipc	a2,0x1
ffffffffc0205d22:	09260613          	addi	a2,a2,146 # ffffffffc0206db0 <commands+0x450>
ffffffffc0205d26:	29300593          	li	a1,659
ffffffffc0205d2a:	00003517          	auipc	a0,0x3
ffffffffc0205d2e:	86650513          	addi	a0,a0,-1946 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205d32:	f48fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205d36:	00003697          	auipc	a3,0x3
ffffffffc0205d3a:	af268693          	addi	a3,a3,-1294 # ffffffffc0208828 <default_pmm_manager+0x1270>
ffffffffc0205d3e:	00001617          	auipc	a2,0x1
ffffffffc0205d42:	07260613          	addi	a2,a2,114 # ffffffffc0206db0 <commands+0x450>
ffffffffc0205d46:	29200593          	li	a1,658
ffffffffc0205d4a:	00003517          	auipc	a0,0x3
ffffffffc0205d4e:	84650513          	addi	a0,a0,-1978 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205d52:	f28fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205d56:	00003697          	auipc	a3,0x3
ffffffffc0205d5a:	a8a68693          	addi	a3,a3,-1398 # ffffffffc02087e0 <default_pmm_manager+0x1228>
ffffffffc0205d5e:	00001617          	auipc	a2,0x1
ffffffffc0205d62:	05260613          	addi	a2,a2,82 # ffffffffc0206db0 <commands+0x450>
ffffffffc0205d66:	29100593          	li	a1,657
ffffffffc0205d6a:	00003517          	auipc	a0,0x3
ffffffffc0205d6e:	82650513          	addi	a0,a0,-2010 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205d72:	f08fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205d76 <do_yield>:
    current->need_resched = 1;
ffffffffc0205d76:	000ad797          	auipc	a5,0xad
ffffffffc0205d7a:	b127b783          	ld	a5,-1262(a5) # ffffffffc02b2888 <current>
ffffffffc0205d7e:	4705                	li	a4,1
ffffffffc0205d80:	ef98                	sd	a4,24(a5)
}
ffffffffc0205d82:	4501                	li	a0,0
ffffffffc0205d84:	8082                	ret

ffffffffc0205d86 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205d86:	1101                	addi	sp,sp,-32
ffffffffc0205d88:	e822                	sd	s0,16(sp)
ffffffffc0205d8a:	e426                	sd	s1,8(sp)
ffffffffc0205d8c:	ec06                	sd	ra,24(sp)
ffffffffc0205d8e:	842e                	mv	s0,a1
ffffffffc0205d90:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205d92:	c999                	beqz	a1,ffffffffc0205da8 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205d94:	000ad797          	auipc	a5,0xad
ffffffffc0205d98:	af47b783          	ld	a5,-1292(a5) # ffffffffc02b2888 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205d9c:	7788                	ld	a0,40(a5)
ffffffffc0205d9e:	4685                	li	a3,1
ffffffffc0205da0:	4611                	li	a2,4
ffffffffc0205da2:	e61fe0ef          	jal	ra,ffffffffc0204c02 <user_mem_check>
ffffffffc0205da6:	c909                	beqz	a0,ffffffffc0205db8 <do_wait+0x32>
ffffffffc0205da8:	85a2                	mv	a1,s0
}
ffffffffc0205daa:	6442                	ld	s0,16(sp)
ffffffffc0205dac:	60e2                	ld	ra,24(sp)
ffffffffc0205dae:	8526                	mv	a0,s1
ffffffffc0205db0:	64a2                	ld	s1,8(sp)
ffffffffc0205db2:	6105                	addi	sp,sp,32
ffffffffc0205db4:	fbcff06f          	j	ffffffffc0205570 <do_wait.part.0>
ffffffffc0205db8:	60e2                	ld	ra,24(sp)
ffffffffc0205dba:	6442                	ld	s0,16(sp)
ffffffffc0205dbc:	64a2                	ld	s1,8(sp)
ffffffffc0205dbe:	5575                	li	a0,-3
ffffffffc0205dc0:	6105                	addi	sp,sp,32
ffffffffc0205dc2:	8082                	ret

ffffffffc0205dc4 <do_kill>:
do_kill(int pid) {
ffffffffc0205dc4:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205dc6:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc0205dc8:	e406                	sd	ra,8(sp)
ffffffffc0205dca:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205dcc:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205dd0:	17f9                	addi	a5,a5,-2
ffffffffc0205dd2:	02e7e963          	bltu	a5,a4,ffffffffc0205e04 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205dd6:	842a                	mv	s0,a0
ffffffffc0205dd8:	45a9                	li	a1,10
ffffffffc0205dda:	2501                	sext.w	a0,a0
ffffffffc0205ddc:	46c000ef          	jal	ra,ffffffffc0206248 <hash32>
ffffffffc0205de0:	02051793          	slli	a5,a0,0x20
ffffffffc0205de4:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205de8:	000a9797          	auipc	a5,0xa9
ffffffffc0205dec:	a1878793          	addi	a5,a5,-1512 # ffffffffc02ae800 <hash_list>
ffffffffc0205df0:	953e                	add	a0,a0,a5
ffffffffc0205df2:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205df4:	a029                	j	ffffffffc0205dfe <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205df6:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205dfa:	00870b63          	beq	a4,s0,ffffffffc0205e10 <do_kill+0x4c>
ffffffffc0205dfe:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205e00:	fef51be3          	bne	a0,a5,ffffffffc0205df6 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205e04:	5475                	li	s0,-3
}
ffffffffc0205e06:	60a2                	ld	ra,8(sp)
ffffffffc0205e08:	8522                	mv	a0,s0
ffffffffc0205e0a:	6402                	ld	s0,0(sp)
ffffffffc0205e0c:	0141                	addi	sp,sp,16
ffffffffc0205e0e:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205e10:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205e14:	00177693          	andi	a3,a4,1
ffffffffc0205e18:	e295                	bnez	a3,ffffffffc0205e3c <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205e1a:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205e1c:	00176713          	ori	a4,a4,1
ffffffffc0205e20:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205e24:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205e26:	fe06d0e3          	bgez	a3,ffffffffc0205e06 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205e2a:	f2878513          	addi	a0,a5,-216
ffffffffc0205e2e:	22e000ef          	jal	ra,ffffffffc020605c <wakeup_proc>
}
ffffffffc0205e32:	60a2                	ld	ra,8(sp)
ffffffffc0205e34:	8522                	mv	a0,s0
ffffffffc0205e36:	6402                	ld	s0,0(sp)
ffffffffc0205e38:	0141                	addi	sp,sp,16
ffffffffc0205e3a:	8082                	ret
        return -E_KILLED;
ffffffffc0205e3c:	545d                	li	s0,-9
ffffffffc0205e3e:	b7e1                	j	ffffffffc0205e06 <do_kill+0x42>

ffffffffc0205e40 <proc_init>:


// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205e40:	1101                	addi	sp,sp,-32
ffffffffc0205e42:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205e44:	000ad797          	auipc	a5,0xad
ffffffffc0205e48:	9bc78793          	addi	a5,a5,-1604 # ffffffffc02b2800 <proc_list>
ffffffffc0205e4c:	ec06                	sd	ra,24(sp)
ffffffffc0205e4e:	e822                	sd	s0,16(sp)
ffffffffc0205e50:	e04a                	sd	s2,0(sp)
ffffffffc0205e52:	000a9497          	auipc	s1,0xa9
ffffffffc0205e56:	9ae48493          	addi	s1,s1,-1618 # ffffffffc02ae800 <hash_list>
ffffffffc0205e5a:	e79c                	sd	a5,8(a5)
ffffffffc0205e5c:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205e5e:	000ad717          	auipc	a4,0xad
ffffffffc0205e62:	9a270713          	addi	a4,a4,-1630 # ffffffffc02b2800 <proc_list>
ffffffffc0205e66:	87a6                	mv	a5,s1
ffffffffc0205e68:	e79c                	sd	a5,8(a5)
ffffffffc0205e6a:	e39c                	sd	a5,0(a5)
ffffffffc0205e6c:	07c1                	addi	a5,a5,16
ffffffffc0205e6e:	fef71de3          	bne	a4,a5,ffffffffc0205e68 <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205e72:	f81fe0ef          	jal	ra,ffffffffc0204df2 <alloc_proc>
ffffffffc0205e76:	000ad917          	auipc	s2,0xad
ffffffffc0205e7a:	a1a90913          	addi	s2,s2,-1510 # ffffffffc02b2890 <idleproc>
ffffffffc0205e7e:	00a93023          	sd	a0,0(s2)
ffffffffc0205e82:	0e050f63          	beqz	a0,ffffffffc0205f80 <proc_init+0x140>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205e86:	4789                	li	a5,2
ffffffffc0205e88:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e8a:	00003797          	auipc	a5,0x3
ffffffffc0205e8e:	17678793          	addi	a5,a5,374 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e92:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e96:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205e98:	4785                	li	a5,1
ffffffffc0205e9a:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e9c:	4641                	li	a2,16
ffffffffc0205e9e:	4581                	li	a1,0
ffffffffc0205ea0:	8522                	mv	a0,s0
ffffffffc0205ea2:	027000ef          	jal	ra,ffffffffc02066c8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205ea6:	463d                	li	a2,15
ffffffffc0205ea8:	00003597          	auipc	a1,0x3
ffffffffc0205eac:	a7058593          	addi	a1,a1,-1424 # ffffffffc0208918 <default_pmm_manager+0x1360>
ffffffffc0205eb0:	8522                	mv	a0,s0
ffffffffc0205eb2:	029000ef          	jal	ra,ffffffffc02066da <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205eb6:	000ad717          	auipc	a4,0xad
ffffffffc0205eba:	9ea70713          	addi	a4,a4,-1558 # ffffffffc02b28a0 <nr_process>
ffffffffc0205ebe:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205ec0:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ec4:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205ec6:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ec8:	4581                	li	a1,0
ffffffffc0205eca:	00000517          	auipc	a0,0x0
ffffffffc0205ece:	87850513          	addi	a0,a0,-1928 # ffffffffc0205742 <init_main>
    nr_process ++;
ffffffffc0205ed2:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205ed4:	000ad797          	auipc	a5,0xad
ffffffffc0205ed8:	9ad7ba23          	sd	a3,-1612(a5) # ffffffffc02b2888 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205edc:	cfaff0ef          	jal	ra,ffffffffc02053d6 <kernel_thread>
ffffffffc0205ee0:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0205ee2:	08a05363          	blez	a0,ffffffffc0205f68 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205ee6:	6789                	lui	a5,0x2
ffffffffc0205ee8:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205eec:	17f9                	addi	a5,a5,-2
ffffffffc0205eee:	2501                	sext.w	a0,a0
ffffffffc0205ef0:	02e7e363          	bltu	a5,a4,ffffffffc0205f16 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205ef4:	45a9                	li	a1,10
ffffffffc0205ef6:	352000ef          	jal	ra,ffffffffc0206248 <hash32>
ffffffffc0205efa:	02051793          	slli	a5,a0,0x20
ffffffffc0205efe:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205f02:	96a6                	add	a3,a3,s1
ffffffffc0205f04:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205f06:	a029                	j	ffffffffc0205f10 <proc_init+0xd0>
            if (proc->pid == pid) {
ffffffffc0205f08:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c84>
ffffffffc0205f0c:	04870b63          	beq	a4,s0,ffffffffc0205f62 <proc_init+0x122>
    return listelm->next;
ffffffffc0205f10:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205f12:	fef69be3          	bne	a3,a5,ffffffffc0205f08 <proc_init+0xc8>
    return NULL;
ffffffffc0205f16:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205f18:	0b478493          	addi	s1,a5,180
ffffffffc0205f1c:	4641                	li	a2,16
ffffffffc0205f1e:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205f20:	000ad417          	auipc	s0,0xad
ffffffffc0205f24:	97840413          	addi	s0,s0,-1672 # ffffffffc02b2898 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205f28:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205f2a:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205f2c:	79c000ef          	jal	ra,ffffffffc02066c8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205f30:	463d                	li	a2,15
ffffffffc0205f32:	00003597          	auipc	a1,0x3
ffffffffc0205f36:	a0e58593          	addi	a1,a1,-1522 # ffffffffc0208940 <default_pmm_manager+0x1388>
ffffffffc0205f3a:	8526                	mv	a0,s1
ffffffffc0205f3c:	79e000ef          	jal	ra,ffffffffc02066da <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205f40:	00093783          	ld	a5,0(s2)
ffffffffc0205f44:	cbb5                	beqz	a5,ffffffffc0205fb8 <proc_init+0x178>
ffffffffc0205f46:	43dc                	lw	a5,4(a5)
ffffffffc0205f48:	eba5                	bnez	a5,ffffffffc0205fb8 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205f4a:	601c                	ld	a5,0(s0)
ffffffffc0205f4c:	c7b1                	beqz	a5,ffffffffc0205f98 <proc_init+0x158>
ffffffffc0205f4e:	43d8                	lw	a4,4(a5)
ffffffffc0205f50:	4785                	li	a5,1
ffffffffc0205f52:	04f71363          	bne	a4,a5,ffffffffc0205f98 <proc_init+0x158>
}
ffffffffc0205f56:	60e2                	ld	ra,24(sp)
ffffffffc0205f58:	6442                	ld	s0,16(sp)
ffffffffc0205f5a:	64a2                	ld	s1,8(sp)
ffffffffc0205f5c:	6902                	ld	s2,0(sp)
ffffffffc0205f5e:	6105                	addi	sp,sp,32
ffffffffc0205f60:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205f62:	f2878793          	addi	a5,a5,-216
ffffffffc0205f66:	bf4d                	j	ffffffffc0205f18 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205f68:	00003617          	auipc	a2,0x3
ffffffffc0205f6c:	9b860613          	addi	a2,a2,-1608 # ffffffffc0208920 <default_pmm_manager+0x1368>
ffffffffc0205f70:	3b900593          	li	a1,953
ffffffffc0205f74:	00002517          	auipc	a0,0x2
ffffffffc0205f78:	61c50513          	addi	a0,a0,1564 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205f7c:	cfefa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205f80:	00003617          	auipc	a2,0x3
ffffffffc0205f84:	98060613          	addi	a2,a2,-1664 # ffffffffc0208900 <default_pmm_manager+0x1348>
ffffffffc0205f88:	3ab00593          	li	a1,939
ffffffffc0205f8c:	00002517          	auipc	a0,0x2
ffffffffc0205f90:	60450513          	addi	a0,a0,1540 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205f94:	ce6fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205f98:	00003697          	auipc	a3,0x3
ffffffffc0205f9c:	9d868693          	addi	a3,a3,-1576 # ffffffffc0208970 <default_pmm_manager+0x13b8>
ffffffffc0205fa0:	00001617          	auipc	a2,0x1
ffffffffc0205fa4:	e1060613          	addi	a2,a2,-496 # ffffffffc0206db0 <commands+0x450>
ffffffffc0205fa8:	3c000593          	li	a1,960
ffffffffc0205fac:	00002517          	auipc	a0,0x2
ffffffffc0205fb0:	5e450513          	addi	a0,a0,1508 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205fb4:	cc6fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205fb8:	00003697          	auipc	a3,0x3
ffffffffc0205fbc:	99068693          	addi	a3,a3,-1648 # ffffffffc0208948 <default_pmm_manager+0x1390>
ffffffffc0205fc0:	00001617          	auipc	a2,0x1
ffffffffc0205fc4:	df060613          	addi	a2,a2,-528 # ffffffffc0206db0 <commands+0x450>
ffffffffc0205fc8:	3bf00593          	li	a1,959
ffffffffc0205fcc:	00002517          	auipc	a0,0x2
ffffffffc0205fd0:	5c450513          	addi	a0,a0,1476 # ffffffffc0208590 <default_pmm_manager+0xfd8>
ffffffffc0205fd4:	ca6fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205fd8 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205fd8:	1141                	addi	sp,sp,-16
ffffffffc0205fda:	e022                	sd	s0,0(sp)
ffffffffc0205fdc:	e406                	sd	ra,8(sp)
ffffffffc0205fde:	000ad417          	auipc	s0,0xad
ffffffffc0205fe2:	8aa40413          	addi	s0,s0,-1878 # ffffffffc02b2888 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205fe6:	6018                	ld	a4,0(s0)
ffffffffc0205fe8:	6f1c                	ld	a5,24(a4)
ffffffffc0205fea:	dffd                	beqz	a5,ffffffffc0205fe8 <cpu_idle+0x10>
            schedule();
ffffffffc0205fec:	0f0000ef          	jal	ra,ffffffffc02060dc <schedule>
ffffffffc0205ff0:	bfdd                	j	ffffffffc0205fe6 <cpu_idle+0xe>

ffffffffc0205ff2 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205ff2:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205ff6:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205ffa:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205ffc:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205ffe:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0206002:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0206006:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc020600a:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc020600e:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0206012:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0206016:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc020601a:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc020601e:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0206022:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0206026:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc020602a:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc020602e:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0206030:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0206032:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0206036:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc020603a:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc020603e:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0206042:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0206046:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc020604a:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc020604e:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0206052:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0206056:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc020605a:	8082                	ret

ffffffffc020605c <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020605c:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc020605e:	1101                	addi	sp,sp,-32
ffffffffc0206060:	ec06                	sd	ra,24(sp)
ffffffffc0206062:	e822                	sd	s0,16(sp)
ffffffffc0206064:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206066:	478d                	li	a5,3
ffffffffc0206068:	04f70b63          	beq	a4,a5,ffffffffc02060be <wakeup_proc+0x62>
ffffffffc020606c:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020606e:	100027f3          	csrr	a5,sstatus
ffffffffc0206072:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0206074:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206076:	ef9d                	bnez	a5,ffffffffc02060b4 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0206078:	4789                	li	a5,2
ffffffffc020607a:	02f70163          	beq	a4,a5,ffffffffc020609c <wakeup_proc+0x40>
            proc->state = PROC_RUNNABLE;
ffffffffc020607e:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0206080:	0e042623          	sw	zero,236(s0)
    if (flag) {
ffffffffc0206084:	e491                	bnez	s1,ffffffffc0206090 <wakeup_proc+0x34>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206086:	60e2                	ld	ra,24(sp)
ffffffffc0206088:	6442                	ld	s0,16(sp)
ffffffffc020608a:	64a2                	ld	s1,8(sp)
ffffffffc020608c:	6105                	addi	sp,sp,32
ffffffffc020608e:	8082                	ret
ffffffffc0206090:	6442                	ld	s0,16(sp)
ffffffffc0206092:	60e2                	ld	ra,24(sp)
ffffffffc0206094:	64a2                	ld	s1,8(sp)
ffffffffc0206096:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0206098:	da8fa06f          	j	ffffffffc0200640 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc020609c:	00003617          	auipc	a2,0x3
ffffffffc02060a0:	93460613          	addi	a2,a2,-1740 # ffffffffc02089d0 <default_pmm_manager+0x1418>
ffffffffc02060a4:	45c9                	li	a1,18
ffffffffc02060a6:	00003517          	auipc	a0,0x3
ffffffffc02060aa:	91250513          	addi	a0,a0,-1774 # ffffffffc02089b8 <default_pmm_manager+0x1400>
ffffffffc02060ae:	c34fa0ef          	jal	ra,ffffffffc02004e2 <__warn>
ffffffffc02060b2:	bfc9                	j	ffffffffc0206084 <wakeup_proc+0x28>
        intr_disable();
ffffffffc02060b4:	d92fa0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc02060b8:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc02060ba:	4485                	li	s1,1
ffffffffc02060bc:	bf75                	j	ffffffffc0206078 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02060be:	00003697          	auipc	a3,0x3
ffffffffc02060c2:	8da68693          	addi	a3,a3,-1830 # ffffffffc0208998 <default_pmm_manager+0x13e0>
ffffffffc02060c6:	00001617          	auipc	a2,0x1
ffffffffc02060ca:	cea60613          	addi	a2,a2,-790 # ffffffffc0206db0 <commands+0x450>
ffffffffc02060ce:	45a5                	li	a1,9
ffffffffc02060d0:	00003517          	auipc	a0,0x3
ffffffffc02060d4:	8e850513          	addi	a0,a0,-1816 # ffffffffc02089b8 <default_pmm_manager+0x1400>
ffffffffc02060d8:	ba2fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02060dc <schedule>:

void
schedule(void) {
ffffffffc02060dc:	1141                	addi	sp,sp,-16
ffffffffc02060de:	e406                	sd	ra,8(sp)
ffffffffc02060e0:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02060e2:	100027f3          	csrr	a5,sstatus
ffffffffc02060e6:	8b89                	andi	a5,a5,2
ffffffffc02060e8:	4401                	li	s0,0
ffffffffc02060ea:	efbd                	bnez	a5,ffffffffc0206168 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02060ec:	000ac897          	auipc	a7,0xac
ffffffffc02060f0:	79c8b883          	ld	a7,1948(a7) # ffffffffc02b2888 <current>
ffffffffc02060f4:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02060f8:	000ac517          	auipc	a0,0xac
ffffffffc02060fc:	79853503          	ld	a0,1944(a0) # ffffffffc02b2890 <idleproc>
ffffffffc0206100:	04a88e63          	beq	a7,a0,ffffffffc020615c <schedule+0x80>
ffffffffc0206104:	0c888693          	addi	a3,a7,200
ffffffffc0206108:	000ac617          	auipc	a2,0xac
ffffffffc020610c:	6f860613          	addi	a2,a2,1784 # ffffffffc02b2800 <proc_list>
        le = last;
ffffffffc0206110:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0206112:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206114:	4809                	li	a6,2
ffffffffc0206116:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0206118:	00c78863          	beq	a5,a2,ffffffffc0206128 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc020611c:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0206120:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206124:	03070163          	beq	a4,a6,ffffffffc0206146 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0206128:	fef697e3          	bne	a3,a5,ffffffffc0206116 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020612c:	ed89                	bnez	a1,ffffffffc0206146 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc020612e:	451c                	lw	a5,8(a0)
ffffffffc0206130:	2785                	addiw	a5,a5,1
ffffffffc0206132:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0206134:	00a88463          	beq	a7,a0,ffffffffc020613c <schedule+0x60>
            proc_run(next);
ffffffffc0206138:	e2ffe0ef          	jal	ra,ffffffffc0204f66 <proc_run>
    if (flag) {
ffffffffc020613c:	e819                	bnez	s0,ffffffffc0206152 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020613e:	60a2                	ld	ra,8(sp)
ffffffffc0206140:	6402                	ld	s0,0(sp)
ffffffffc0206142:	0141                	addi	sp,sp,16
ffffffffc0206144:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206146:	4198                	lw	a4,0(a1)
ffffffffc0206148:	4789                	li	a5,2
ffffffffc020614a:	fef712e3          	bne	a4,a5,ffffffffc020612e <schedule+0x52>
ffffffffc020614e:	852e                	mv	a0,a1
ffffffffc0206150:	bff9                	j	ffffffffc020612e <schedule+0x52>
}
ffffffffc0206152:	6402                	ld	s0,0(sp)
ffffffffc0206154:	60a2                	ld	ra,8(sp)
ffffffffc0206156:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0206158:	ce8fa06f          	j	ffffffffc0200640 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020615c:	000ac617          	auipc	a2,0xac
ffffffffc0206160:	6a460613          	addi	a2,a2,1700 # ffffffffc02b2800 <proc_list>
ffffffffc0206164:	86b2                	mv	a3,a2
ffffffffc0206166:	b76d                	j	ffffffffc0206110 <schedule+0x34>
        intr_disable();
ffffffffc0206168:	cdefa0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc020616c:	4405                	li	s0,1
ffffffffc020616e:	bfbd                	j	ffffffffc02060ec <schedule+0x10>

ffffffffc0206170 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0206170:	000ac797          	auipc	a5,0xac
ffffffffc0206174:	7187b783          	ld	a5,1816(a5) # ffffffffc02b2888 <current>
}
ffffffffc0206178:	43c8                	lw	a0,4(a5)
ffffffffc020617a:	8082                	ret

ffffffffc020617c <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc020617c:	4501                	li	a0,0
ffffffffc020617e:	8082                	ret

ffffffffc0206180 <sys_putc>:
    cputchar(c);
ffffffffc0206180:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206182:	1141                	addi	sp,sp,-16
ffffffffc0206184:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0206186:	830fa0ef          	jal	ra,ffffffffc02001b6 <cputchar>
}
ffffffffc020618a:	60a2                	ld	ra,8(sp)
ffffffffc020618c:	4501                	li	a0,0
ffffffffc020618e:	0141                	addi	sp,sp,16
ffffffffc0206190:	8082                	ret

ffffffffc0206192 <sys_kill>:
    return do_kill(pid);
ffffffffc0206192:	4108                	lw	a0,0(a0)
ffffffffc0206194:	c31ff06f          	j	ffffffffc0205dc4 <do_kill>

ffffffffc0206198 <sys_yield>:
    return do_yield();
ffffffffc0206198:	bdfff06f          	j	ffffffffc0205d76 <do_yield>

ffffffffc020619c <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc020619c:	6d14                	ld	a3,24(a0)
ffffffffc020619e:	6910                	ld	a2,16(a0)
ffffffffc02061a0:	650c                	ld	a1,8(a0)
ffffffffc02061a2:	6108                	ld	a0,0(a0)
ffffffffc02061a4:	ec2ff06f          	j	ffffffffc0205866 <do_execve>

ffffffffc02061a8 <sys_wait>:
    return do_wait(pid, store);
ffffffffc02061a8:	650c                	ld	a1,8(a0)
ffffffffc02061aa:	4108                	lw	a0,0(a0)
ffffffffc02061ac:	bdbff06f          	j	ffffffffc0205d86 <do_wait>

ffffffffc02061b0 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02061b0:	000ac797          	auipc	a5,0xac
ffffffffc02061b4:	6d87b783          	ld	a5,1752(a5) # ffffffffc02b2888 <current>
ffffffffc02061b8:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02061ba:	4501                	li	a0,0
ffffffffc02061bc:	6a0c                	ld	a1,16(a2)
ffffffffc02061be:	e15fe06f          	j	ffffffffc0204fd2 <do_fork>

ffffffffc02061c2 <sys_exit>:
    return do_exit(error_code);
ffffffffc02061c2:	4108                	lw	a0,0(a0)
ffffffffc02061c4:	a62ff06f          	j	ffffffffc0205426 <do_exit>

ffffffffc02061c8 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02061c8:	715d                	addi	sp,sp,-80
ffffffffc02061ca:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02061cc:	000ac497          	auipc	s1,0xac
ffffffffc02061d0:	6bc48493          	addi	s1,s1,1724 # ffffffffc02b2888 <current>
ffffffffc02061d4:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02061d6:	e0a2                	sd	s0,64(sp)
ffffffffc02061d8:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02061da:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02061dc:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;//a0寄存器保存了系统调用编号
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02061de:	47fd                	li	a5,31
    int num = tf->gpr.a0;//a0寄存器保存了系统调用编号
ffffffffc02061e0:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02061e4:	0327ee63          	bltu	a5,s2,ffffffffc0206220 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02061e8:	00391713          	slli	a4,s2,0x3
ffffffffc02061ec:	00003797          	auipc	a5,0x3
ffffffffc02061f0:	84c78793          	addi	a5,a5,-1972 # ffffffffc0208a38 <syscalls>
ffffffffc02061f4:	97ba                	add	a5,a5,a4
ffffffffc02061f6:	639c                	ld	a5,0(a5)
ffffffffc02061f8:	c785                	beqz	a5,ffffffffc0206220 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02061fa:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02061fc:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02061fe:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0206200:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0206202:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0206204:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0206206:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0206208:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc020620a:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc020620c:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020620e:	0028                	addi	a0,sp,8
ffffffffc0206210:	9782                	jalr	a5
    }
    //如果执行到这里，说明传入的系统调用编号还没有被实现，就崩掉了。
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0206212:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206214:	e828                	sd	a0,80(s0)
}
ffffffffc0206216:	6406                	ld	s0,64(sp)
ffffffffc0206218:	74e2                	ld	s1,56(sp)
ffffffffc020621a:	7942                	ld	s2,48(sp)
ffffffffc020621c:	6161                	addi	sp,sp,80
ffffffffc020621e:	8082                	ret
    print_trapframe(tf);
ffffffffc0206220:	8522                	mv	a0,s0
ffffffffc0206222:	e12fa0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0206226:	609c                	ld	a5,0(s1)
ffffffffc0206228:	86ca                	mv	a3,s2
ffffffffc020622a:	00002617          	auipc	a2,0x2
ffffffffc020622e:	7c660613          	addi	a2,a2,1990 # ffffffffc02089f0 <default_pmm_manager+0x1438>
ffffffffc0206232:	43d8                	lw	a4,4(a5)
ffffffffc0206234:	06400593          	li	a1,100
ffffffffc0206238:	0b478793          	addi	a5,a5,180
ffffffffc020623c:	00002517          	auipc	a0,0x2
ffffffffc0206240:	7e450513          	addi	a0,a0,2020 # ffffffffc0208a20 <default_pmm_manager+0x1468>
ffffffffc0206244:	a36fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0206248 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0206248:	9e3707b7          	lui	a5,0x9e370
ffffffffc020624c:	2785                	addiw	a5,a5,1
ffffffffc020624e:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0206252:	02000793          	li	a5,32
ffffffffc0206256:	9f8d                	subw	a5,a5,a1
}
ffffffffc0206258:	00f5553b          	srlw	a0,a0,a5
ffffffffc020625c:	8082                	ret

ffffffffc020625e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020625e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206262:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0206264:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206268:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020626a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020626e:	f022                	sd	s0,32(sp)
ffffffffc0206270:	ec26                	sd	s1,24(sp)
ffffffffc0206272:	e84a                	sd	s2,16(sp)
ffffffffc0206274:	f406                	sd	ra,40(sp)
ffffffffc0206276:	e44e                	sd	s3,8(sp)
ffffffffc0206278:	84aa                	mv	s1,a0
ffffffffc020627a:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020627c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0206280:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0206282:	03067e63          	bgeu	a2,a6,ffffffffc02062be <printnum+0x60>
ffffffffc0206286:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0206288:	00805763          	blez	s0,ffffffffc0206296 <printnum+0x38>
ffffffffc020628c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020628e:	85ca                	mv	a1,s2
ffffffffc0206290:	854e                	mv	a0,s3
ffffffffc0206292:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0206294:	fc65                	bnez	s0,ffffffffc020628c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206296:	1a02                	slli	s4,s4,0x20
ffffffffc0206298:	00003797          	auipc	a5,0x3
ffffffffc020629c:	8a078793          	addi	a5,a5,-1888 # ffffffffc0208b38 <syscalls+0x100>
ffffffffc02062a0:	020a5a13          	srli	s4,s4,0x20
ffffffffc02062a4:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02062a6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02062a8:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02062ac:	70a2                	ld	ra,40(sp)
ffffffffc02062ae:	69a2                	ld	s3,8(sp)
ffffffffc02062b0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02062b2:	85ca                	mv	a1,s2
ffffffffc02062b4:	87a6                	mv	a5,s1
}
ffffffffc02062b6:	6942                	ld	s2,16(sp)
ffffffffc02062b8:	64e2                	ld	s1,24(sp)
ffffffffc02062ba:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02062bc:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02062be:	03065633          	divu	a2,a2,a6
ffffffffc02062c2:	8722                	mv	a4,s0
ffffffffc02062c4:	f9bff0ef          	jal	ra,ffffffffc020625e <printnum>
ffffffffc02062c8:	b7f9                	j	ffffffffc0206296 <printnum+0x38>

ffffffffc02062ca <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02062ca:	7119                	addi	sp,sp,-128
ffffffffc02062cc:	f4a6                	sd	s1,104(sp)
ffffffffc02062ce:	f0ca                	sd	s2,96(sp)
ffffffffc02062d0:	ecce                	sd	s3,88(sp)
ffffffffc02062d2:	e8d2                	sd	s4,80(sp)
ffffffffc02062d4:	e4d6                	sd	s5,72(sp)
ffffffffc02062d6:	e0da                	sd	s6,64(sp)
ffffffffc02062d8:	fc5e                	sd	s7,56(sp)
ffffffffc02062da:	f06a                	sd	s10,32(sp)
ffffffffc02062dc:	fc86                	sd	ra,120(sp)
ffffffffc02062de:	f8a2                	sd	s0,112(sp)
ffffffffc02062e0:	f862                	sd	s8,48(sp)
ffffffffc02062e2:	f466                	sd	s9,40(sp)
ffffffffc02062e4:	ec6e                	sd	s11,24(sp)
ffffffffc02062e6:	892a                	mv	s2,a0
ffffffffc02062e8:	84ae                	mv	s1,a1
ffffffffc02062ea:	8d32                	mv	s10,a2
ffffffffc02062ec:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062ee:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02062f2:	5b7d                	li	s6,-1
ffffffffc02062f4:	00003a97          	auipc	s5,0x3
ffffffffc02062f8:	870a8a93          	addi	s5,s5,-1936 # ffffffffc0208b64 <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02062fc:	00003b97          	auipc	s7,0x3
ffffffffc0206300:	a84b8b93          	addi	s7,s7,-1404 # ffffffffc0208d80 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206304:	000d4503          	lbu	a0,0(s10)
ffffffffc0206308:	001d0413          	addi	s0,s10,1
ffffffffc020630c:	01350a63          	beq	a0,s3,ffffffffc0206320 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0206310:	c121                	beqz	a0,ffffffffc0206350 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0206312:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206314:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0206316:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206318:	fff44503          	lbu	a0,-1(s0)
ffffffffc020631c:	ff351ae3          	bne	a0,s3,ffffffffc0206310 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206320:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0206324:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0206328:	4c81                	li	s9,0
ffffffffc020632a:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020632c:	5c7d                	li	s8,-1
ffffffffc020632e:	5dfd                	li	s11,-1
ffffffffc0206330:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0206334:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206336:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020633a:	0ff5f593          	zext.b	a1,a1
ffffffffc020633e:	00140d13          	addi	s10,s0,1
ffffffffc0206342:	04b56263          	bltu	a0,a1,ffffffffc0206386 <vprintfmt+0xbc>
ffffffffc0206346:	058a                	slli	a1,a1,0x2
ffffffffc0206348:	95d6                	add	a1,a1,s5
ffffffffc020634a:	4194                	lw	a3,0(a1)
ffffffffc020634c:	96d6                	add	a3,a3,s5
ffffffffc020634e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0206350:	70e6                	ld	ra,120(sp)
ffffffffc0206352:	7446                	ld	s0,112(sp)
ffffffffc0206354:	74a6                	ld	s1,104(sp)
ffffffffc0206356:	7906                	ld	s2,96(sp)
ffffffffc0206358:	69e6                	ld	s3,88(sp)
ffffffffc020635a:	6a46                	ld	s4,80(sp)
ffffffffc020635c:	6aa6                	ld	s5,72(sp)
ffffffffc020635e:	6b06                	ld	s6,64(sp)
ffffffffc0206360:	7be2                	ld	s7,56(sp)
ffffffffc0206362:	7c42                	ld	s8,48(sp)
ffffffffc0206364:	7ca2                	ld	s9,40(sp)
ffffffffc0206366:	7d02                	ld	s10,32(sp)
ffffffffc0206368:	6de2                	ld	s11,24(sp)
ffffffffc020636a:	6109                	addi	sp,sp,128
ffffffffc020636c:	8082                	ret
            padc = '0';
ffffffffc020636e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0206370:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206374:	846a                	mv	s0,s10
ffffffffc0206376:	00140d13          	addi	s10,s0,1
ffffffffc020637a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020637e:	0ff5f593          	zext.b	a1,a1
ffffffffc0206382:	fcb572e3          	bgeu	a0,a1,ffffffffc0206346 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0206386:	85a6                	mv	a1,s1
ffffffffc0206388:	02500513          	li	a0,37
ffffffffc020638c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020638e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206392:	8d22                	mv	s10,s0
ffffffffc0206394:	f73788e3          	beq	a5,s3,ffffffffc0206304 <vprintfmt+0x3a>
ffffffffc0206398:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020639c:	1d7d                	addi	s10,s10,-1
ffffffffc020639e:	ff379de3          	bne	a5,s3,ffffffffc0206398 <vprintfmt+0xce>
ffffffffc02063a2:	b78d                	j	ffffffffc0206304 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02063a4:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02063a8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063ac:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02063ae:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02063b2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02063b6:	02d86463          	bltu	a6,a3,ffffffffc02063de <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02063ba:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02063be:	002c169b          	slliw	a3,s8,0x2
ffffffffc02063c2:	0186873b          	addw	a4,a3,s8
ffffffffc02063c6:	0017171b          	slliw	a4,a4,0x1
ffffffffc02063ca:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02063cc:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02063d0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02063d2:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02063d6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02063da:	fed870e3          	bgeu	a6,a3,ffffffffc02063ba <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02063de:	f40ddce3          	bgez	s11,ffffffffc0206336 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02063e2:	8de2                	mv	s11,s8
ffffffffc02063e4:	5c7d                	li	s8,-1
ffffffffc02063e6:	bf81                	j	ffffffffc0206336 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02063e8:	fffdc693          	not	a3,s11
ffffffffc02063ec:	96fd                	srai	a3,a3,0x3f
ffffffffc02063ee:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063f2:	00144603          	lbu	a2,1(s0)
ffffffffc02063f6:	2d81                	sext.w	s11,s11
ffffffffc02063f8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02063fa:	bf35                	j	ffffffffc0206336 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02063fc:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206400:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206404:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206406:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0206408:	bfd9                	j	ffffffffc02063de <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020640a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020640c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206410:	01174463          	blt	a4,a7,ffffffffc0206418 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0206414:	1a088e63          	beqz	a7,ffffffffc02065d0 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0206418:	000a3603          	ld	a2,0(s4)
ffffffffc020641c:	46c1                	li	a3,16
ffffffffc020641e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0206420:	2781                	sext.w	a5,a5
ffffffffc0206422:	876e                	mv	a4,s11
ffffffffc0206424:	85a6                	mv	a1,s1
ffffffffc0206426:	854a                	mv	a0,s2
ffffffffc0206428:	e37ff0ef          	jal	ra,ffffffffc020625e <printnum>
            break;
ffffffffc020642c:	bde1                	j	ffffffffc0206304 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020642e:	000a2503          	lw	a0,0(s4)
ffffffffc0206432:	85a6                	mv	a1,s1
ffffffffc0206434:	0a21                	addi	s4,s4,8
ffffffffc0206436:	9902                	jalr	s2
            break;
ffffffffc0206438:	b5f1                	j	ffffffffc0206304 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020643a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020643c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206440:	01174463          	blt	a4,a7,ffffffffc0206448 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0206444:	18088163          	beqz	a7,ffffffffc02065c6 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0206448:	000a3603          	ld	a2,0(s4)
ffffffffc020644c:	46a9                	li	a3,10
ffffffffc020644e:	8a2e                	mv	s4,a1
ffffffffc0206450:	bfc1                	j	ffffffffc0206420 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206452:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0206456:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206458:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020645a:	bdf1                	j	ffffffffc0206336 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020645c:	85a6                	mv	a1,s1
ffffffffc020645e:	02500513          	li	a0,37
ffffffffc0206462:	9902                	jalr	s2
            break;
ffffffffc0206464:	b545                	j	ffffffffc0206304 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206466:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020646a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020646c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020646e:	b5e1                	j	ffffffffc0206336 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0206470:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206472:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206476:	01174463          	blt	a4,a7,ffffffffc020647e <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020647a:	14088163          	beqz	a7,ffffffffc02065bc <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020647e:	000a3603          	ld	a2,0(s4)
ffffffffc0206482:	46a1                	li	a3,8
ffffffffc0206484:	8a2e                	mv	s4,a1
ffffffffc0206486:	bf69                	j	ffffffffc0206420 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0206488:	03000513          	li	a0,48
ffffffffc020648c:	85a6                	mv	a1,s1
ffffffffc020648e:	e03e                	sd	a5,0(sp)
ffffffffc0206490:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0206492:	85a6                	mv	a1,s1
ffffffffc0206494:	07800513          	li	a0,120
ffffffffc0206498:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020649a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020649c:	6782                	ld	a5,0(sp)
ffffffffc020649e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02064a0:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02064a4:	bfb5                	j	ffffffffc0206420 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02064a6:	000a3403          	ld	s0,0(s4)
ffffffffc02064aa:	008a0713          	addi	a4,s4,8
ffffffffc02064ae:	e03a                	sd	a4,0(sp)
ffffffffc02064b0:	14040263          	beqz	s0,ffffffffc02065f4 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02064b4:	0fb05763          	blez	s11,ffffffffc02065a2 <vprintfmt+0x2d8>
ffffffffc02064b8:	02d00693          	li	a3,45
ffffffffc02064bc:	0cd79163          	bne	a5,a3,ffffffffc020657e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064c0:	00044783          	lbu	a5,0(s0)
ffffffffc02064c4:	0007851b          	sext.w	a0,a5
ffffffffc02064c8:	cf85                	beqz	a5,ffffffffc0206500 <vprintfmt+0x236>
ffffffffc02064ca:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02064ce:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064d2:	000c4563          	bltz	s8,ffffffffc02064dc <vprintfmt+0x212>
ffffffffc02064d6:	3c7d                	addiw	s8,s8,-1
ffffffffc02064d8:	036c0263          	beq	s8,s6,ffffffffc02064fc <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02064dc:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02064de:	0e0c8e63          	beqz	s9,ffffffffc02065da <vprintfmt+0x310>
ffffffffc02064e2:	3781                	addiw	a5,a5,-32
ffffffffc02064e4:	0ef47b63          	bgeu	s0,a5,ffffffffc02065da <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02064e8:	03f00513          	li	a0,63
ffffffffc02064ec:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064ee:	000a4783          	lbu	a5,0(s4)
ffffffffc02064f2:	3dfd                	addiw	s11,s11,-1
ffffffffc02064f4:	0a05                	addi	s4,s4,1
ffffffffc02064f6:	0007851b          	sext.w	a0,a5
ffffffffc02064fa:	ffe1                	bnez	a5,ffffffffc02064d2 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02064fc:	01b05963          	blez	s11,ffffffffc020650e <vprintfmt+0x244>
ffffffffc0206500:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206502:	85a6                	mv	a1,s1
ffffffffc0206504:	02000513          	li	a0,32
ffffffffc0206508:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020650a:	fe0d9be3          	bnez	s11,ffffffffc0206500 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020650e:	6a02                	ld	s4,0(sp)
ffffffffc0206510:	bbd5                	j	ffffffffc0206304 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206512:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206514:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0206518:	01174463          	blt	a4,a7,ffffffffc0206520 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020651c:	08088d63          	beqz	a7,ffffffffc02065b6 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0206520:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0206524:	0a044d63          	bltz	s0,ffffffffc02065de <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0206528:	8622                	mv	a2,s0
ffffffffc020652a:	8a66                	mv	s4,s9
ffffffffc020652c:	46a9                	li	a3,10
ffffffffc020652e:	bdcd                	j	ffffffffc0206420 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0206530:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206534:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0206536:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0206538:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020653c:	8fb5                	xor	a5,a5,a3
ffffffffc020653e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206542:	02d74163          	blt	a4,a3,ffffffffc0206564 <vprintfmt+0x29a>
ffffffffc0206546:	00369793          	slli	a5,a3,0x3
ffffffffc020654a:	97de                	add	a5,a5,s7
ffffffffc020654c:	639c                	ld	a5,0(a5)
ffffffffc020654e:	cb99                	beqz	a5,ffffffffc0206564 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206550:	86be                	mv	a3,a5
ffffffffc0206552:	00000617          	auipc	a2,0x0
ffffffffc0206556:	1ce60613          	addi	a2,a2,462 # ffffffffc0206720 <etext+0x2e>
ffffffffc020655a:	85a6                	mv	a1,s1
ffffffffc020655c:	854a                	mv	a0,s2
ffffffffc020655e:	0ce000ef          	jal	ra,ffffffffc020662c <printfmt>
ffffffffc0206562:	b34d                	j	ffffffffc0206304 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0206564:	00002617          	auipc	a2,0x2
ffffffffc0206568:	5f460613          	addi	a2,a2,1524 # ffffffffc0208b58 <syscalls+0x120>
ffffffffc020656c:	85a6                	mv	a1,s1
ffffffffc020656e:	854a                	mv	a0,s2
ffffffffc0206570:	0bc000ef          	jal	ra,ffffffffc020662c <printfmt>
ffffffffc0206574:	bb41                	j	ffffffffc0206304 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0206576:	00002417          	auipc	s0,0x2
ffffffffc020657a:	5da40413          	addi	s0,s0,1498 # ffffffffc0208b50 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020657e:	85e2                	mv	a1,s8
ffffffffc0206580:	8522                	mv	a0,s0
ffffffffc0206582:	e43e                	sd	a5,8(sp)
ffffffffc0206584:	0e2000ef          	jal	ra,ffffffffc0206666 <strnlen>
ffffffffc0206588:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020658c:	01b05b63          	blez	s11,ffffffffc02065a2 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0206590:	67a2                	ld	a5,8(sp)
ffffffffc0206592:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206596:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0206598:	85a6                	mv	a1,s1
ffffffffc020659a:	8552                	mv	a0,s4
ffffffffc020659c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020659e:	fe0d9ce3          	bnez	s11,ffffffffc0206596 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065a2:	00044783          	lbu	a5,0(s0)
ffffffffc02065a6:	00140a13          	addi	s4,s0,1
ffffffffc02065aa:	0007851b          	sext.w	a0,a5
ffffffffc02065ae:	d3a5                	beqz	a5,ffffffffc020650e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02065b0:	05e00413          	li	s0,94
ffffffffc02065b4:	bf39                	j	ffffffffc02064d2 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02065b6:	000a2403          	lw	s0,0(s4)
ffffffffc02065ba:	b7ad                	j	ffffffffc0206524 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02065bc:	000a6603          	lwu	a2,0(s4)
ffffffffc02065c0:	46a1                	li	a3,8
ffffffffc02065c2:	8a2e                	mv	s4,a1
ffffffffc02065c4:	bdb1                	j	ffffffffc0206420 <vprintfmt+0x156>
ffffffffc02065c6:	000a6603          	lwu	a2,0(s4)
ffffffffc02065ca:	46a9                	li	a3,10
ffffffffc02065cc:	8a2e                	mv	s4,a1
ffffffffc02065ce:	bd89                	j	ffffffffc0206420 <vprintfmt+0x156>
ffffffffc02065d0:	000a6603          	lwu	a2,0(s4)
ffffffffc02065d4:	46c1                	li	a3,16
ffffffffc02065d6:	8a2e                	mv	s4,a1
ffffffffc02065d8:	b5a1                	j	ffffffffc0206420 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02065da:	9902                	jalr	s2
ffffffffc02065dc:	bf09                	j	ffffffffc02064ee <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02065de:	85a6                	mv	a1,s1
ffffffffc02065e0:	02d00513          	li	a0,45
ffffffffc02065e4:	e03e                	sd	a5,0(sp)
ffffffffc02065e6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02065e8:	6782                	ld	a5,0(sp)
ffffffffc02065ea:	8a66                	mv	s4,s9
ffffffffc02065ec:	40800633          	neg	a2,s0
ffffffffc02065f0:	46a9                	li	a3,10
ffffffffc02065f2:	b53d                	j	ffffffffc0206420 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02065f4:	03b05163          	blez	s11,ffffffffc0206616 <vprintfmt+0x34c>
ffffffffc02065f8:	02d00693          	li	a3,45
ffffffffc02065fc:	f6d79de3          	bne	a5,a3,ffffffffc0206576 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0206600:	00002417          	auipc	s0,0x2
ffffffffc0206604:	55040413          	addi	s0,s0,1360 # ffffffffc0208b50 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206608:	02800793          	li	a5,40
ffffffffc020660c:	02800513          	li	a0,40
ffffffffc0206610:	00140a13          	addi	s4,s0,1
ffffffffc0206614:	bd6d                	j	ffffffffc02064ce <vprintfmt+0x204>
ffffffffc0206616:	00002a17          	auipc	s4,0x2
ffffffffc020661a:	53ba0a13          	addi	s4,s4,1339 # ffffffffc0208b51 <syscalls+0x119>
ffffffffc020661e:	02800513          	li	a0,40
ffffffffc0206622:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206626:	05e00413          	li	s0,94
ffffffffc020662a:	b565                	j	ffffffffc02064d2 <vprintfmt+0x208>

ffffffffc020662c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020662c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020662e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206632:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206634:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206636:	ec06                	sd	ra,24(sp)
ffffffffc0206638:	f83a                	sd	a4,48(sp)
ffffffffc020663a:	fc3e                	sd	a5,56(sp)
ffffffffc020663c:	e0c2                	sd	a6,64(sp)
ffffffffc020663e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0206640:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206642:	c89ff0ef          	jal	ra,ffffffffc02062ca <vprintfmt>
}
ffffffffc0206646:	60e2                	ld	ra,24(sp)
ffffffffc0206648:	6161                	addi	sp,sp,80
ffffffffc020664a:	8082                	ret

ffffffffc020664c <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020664c:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0206650:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0206652:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0206654:	cb81                	beqz	a5,ffffffffc0206664 <strlen+0x18>
        cnt ++;
ffffffffc0206656:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0206658:	00a707b3          	add	a5,a4,a0
ffffffffc020665c:	0007c783          	lbu	a5,0(a5)
ffffffffc0206660:	fbfd                	bnez	a5,ffffffffc0206656 <strlen+0xa>
ffffffffc0206662:	8082                	ret
    }
    return cnt;
}
ffffffffc0206664:	8082                	ret

ffffffffc0206666 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0206666:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206668:	e589                	bnez	a1,ffffffffc0206672 <strnlen+0xc>
ffffffffc020666a:	a811                	j	ffffffffc020667e <strnlen+0x18>
        cnt ++;
ffffffffc020666c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020666e:	00f58863          	beq	a1,a5,ffffffffc020667e <strnlen+0x18>
ffffffffc0206672:	00f50733          	add	a4,a0,a5
ffffffffc0206676:	00074703          	lbu	a4,0(a4)
ffffffffc020667a:	fb6d                	bnez	a4,ffffffffc020666c <strnlen+0x6>
ffffffffc020667c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020667e:	852e                	mv	a0,a1
ffffffffc0206680:	8082                	ret

ffffffffc0206682 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206682:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206684:	0005c703          	lbu	a4,0(a1)
ffffffffc0206688:	0785                	addi	a5,a5,1
ffffffffc020668a:	0585                	addi	a1,a1,1
ffffffffc020668c:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206690:	fb75                	bnez	a4,ffffffffc0206684 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206692:	8082                	ret

ffffffffc0206694 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206694:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206698:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020669c:	cb89                	beqz	a5,ffffffffc02066ae <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020669e:	0505                	addi	a0,a0,1
ffffffffc02066a0:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02066a2:	fee789e3          	beq	a5,a4,ffffffffc0206694 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02066a6:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02066aa:	9d19                	subw	a0,a0,a4
ffffffffc02066ac:	8082                	ret
ffffffffc02066ae:	4501                	li	a0,0
ffffffffc02066b0:	bfed                	j	ffffffffc02066aa <strcmp+0x16>

ffffffffc02066b2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02066b2:	00054783          	lbu	a5,0(a0)
ffffffffc02066b6:	c799                	beqz	a5,ffffffffc02066c4 <strchr+0x12>
        if (*s == c) {
ffffffffc02066b8:	00f58763          	beq	a1,a5,ffffffffc02066c6 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02066bc:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02066c0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02066c2:	fbfd                	bnez	a5,ffffffffc02066b8 <strchr+0x6>
    }
    return NULL;
ffffffffc02066c4:	4501                	li	a0,0
}
ffffffffc02066c6:	8082                	ret

ffffffffc02066c8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02066c8:	ca01                	beqz	a2,ffffffffc02066d8 <memset+0x10>
ffffffffc02066ca:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02066cc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02066ce:	0785                	addi	a5,a5,1
ffffffffc02066d0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02066d4:	fec79de3          	bne	a5,a2,ffffffffc02066ce <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02066d8:	8082                	ret

ffffffffc02066da <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02066da:	ca19                	beqz	a2,ffffffffc02066f0 <memcpy+0x16>
ffffffffc02066dc:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02066de:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02066e0:	0005c703          	lbu	a4,0(a1)
ffffffffc02066e4:	0585                	addi	a1,a1,1
ffffffffc02066e6:	0785                	addi	a5,a5,1
ffffffffc02066e8:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02066ec:	fec59ae3          	bne	a1,a2,ffffffffc02066e0 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02066f0:	8082                	ret
