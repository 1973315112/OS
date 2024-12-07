
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
ffffffffc020004a:	400040ef          	jal	ra,ffffffffc020444a <memset>

    cons_init();                // 初始化命令行
ffffffffc020004e:	4fc000ef          	jal	ra,ffffffffc020054a <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00005597          	auipc	a1,0x5
ffffffffc0200056:	84e58593          	addi	a1,a1,-1970 # ffffffffc02048a0 <etext+0x4>
ffffffffc020005a:	00005517          	auipc	a0,0x5
ffffffffc020005e:	86650513          	addi	a0,a0,-1946 # ffffffffc02048c0 <etext+0x24>
ffffffffc0200062:	06a000ef          	jal	ra,ffffffffc02000cc <cprintf>

    print_kerninfo();           // 打印核心信息
ffffffffc0200066:	1be000ef          	jal	ra,ffffffffc0200224 <print_kerninfo>
    // grade_backtrace();
    pmm_init();                 // 初始化物理内存管理器
ffffffffc020006a:	61f020ef          	jal	ra,ffffffffc0202e88 <pmm_init>

    pic_init();                 // 初始化中断控制器(本次的新增)
ffffffffc020006e:	54e000ef          	jal	ra,ffffffffc02005bc <pic_init>
    
    idt_init();                 // 初始化中断描述符表
ffffffffc0200072:	5c8000ef          	jal	ra,ffffffffc020063a <idt_init>
    vmm_init();                 // 初始化虚拟内存管理器
ffffffffc0200076:	392010ef          	jal	ra,ffffffffc0201408 <vmm_init>
    
    proc_init();                // 初始化进程表(本次的重点)
ffffffffc020007a:	024040ef          	jal	ra,ffffffffc020409e <proc_init>
    
    ide_init();                 // 初始化磁盘设备
ffffffffc020007e:	424000ef          	jal	ra,ffffffffc02004a2 <ide_init>
    swap_init();                // 初始化页面交换机制
ffffffffc0200082:	6de020ef          	jal	ra,ffffffffc0202760 <swap_init>
    clock_init();               // 初始化时钟中断
ffffffffc0200086:	472000ef          	jal	ra,ffffffffc02004f8 <clock_init>
    intr_enable();              // 启用中断请求
ffffffffc020008a:	534000ef          	jal	ra,ffffffffc02005be <intr_enable>
    
    cpu_idle();                 // 运行空闲进程(本次的重点)
ffffffffc020008e:	25e040ef          	jal	ra,ffffffffc02042ec <cpu_idle>

ffffffffc0200092 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200092:	1141                	addi	sp,sp,-16
ffffffffc0200094:	e022                	sd	s0,0(sp)
ffffffffc0200096:	e406                	sd	ra,8(sp)
ffffffffc0200098:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009a:	4b2000ef          	jal	ra,ffffffffc020054c <cons_putc>
    (*cnt) ++;
ffffffffc020009e:	401c                	lw	a5,0(s0)
}
ffffffffc02000a0:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a2:	2785                	addiw	a5,a5,1
ffffffffc02000a4:	c01c                	sw	a5,0(s0)
}
ffffffffc02000a6:	6402                	ld	s0,0(sp)
ffffffffc02000a8:	0141                	addi	sp,sp,16
ffffffffc02000aa:	8082                	ret

ffffffffc02000ac <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ac:	1101                	addi	sp,sp,-32
ffffffffc02000ae:	862a                	mv	a2,a0
ffffffffc02000b0:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	00000517          	auipc	a0,0x0
ffffffffc02000b6:	fe050513          	addi	a0,a0,-32 # ffffffffc0200092 <cputch>
ffffffffc02000ba:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000bc:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000be:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	444040ef          	jal	ra,ffffffffc0204504 <vprintfmt>
    return cnt;
}
ffffffffc02000c4:	60e2                	ld	ra,24(sp)
ffffffffc02000c6:	4532                	lw	a0,12(sp)
ffffffffc02000c8:	6105                	addi	sp,sp,32
ffffffffc02000ca:	8082                	ret

ffffffffc02000cc <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000cc:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000ce:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d2:	8e2a                	mv	t3,a0
ffffffffc02000d4:	f42e                	sd	a1,40(sp)
ffffffffc02000d6:	f832                	sd	a2,48(sp)
ffffffffc02000d8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000da:	00000517          	auipc	a0,0x0
ffffffffc02000de:	fb850513          	addi	a0,a0,-72 # ffffffffc0200092 <cputch>
ffffffffc02000e2:	004c                	addi	a1,sp,4
ffffffffc02000e4:	869a                	mv	a3,t1
ffffffffc02000e6:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000e8:	ec06                	sd	ra,24(sp)
ffffffffc02000ea:	e0ba                	sd	a4,64(sp)
ffffffffc02000ec:	e4be                	sd	a5,72(sp)
ffffffffc02000ee:	e8c2                	sd	a6,80(sp)
ffffffffc02000f0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f6:	40e040ef          	jal	ra,ffffffffc0204504 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fa:	60e2                	ld	ra,24(sp)
ffffffffc02000fc:	4512                	lw	a0,4(sp)
ffffffffc02000fe:	6125                	addi	sp,sp,96
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200102:	a1a9                	j	ffffffffc020054c <cons_putc>

ffffffffc0200104 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200104:	1141                	addi	sp,sp,-16
ffffffffc0200106:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200108:	478000ef          	jal	ra,ffffffffc0200580 <cons_getc>
ffffffffc020010c:	dd75                	beqz	a0,ffffffffc0200108 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020010e:	60a2                	ld	ra,8(sp)
ffffffffc0200110:	0141                	addi	sp,sp,16
ffffffffc0200112:	8082                	ret

ffffffffc0200114 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200114:	715d                	addi	sp,sp,-80
ffffffffc0200116:	e486                	sd	ra,72(sp)
ffffffffc0200118:	e0a6                	sd	s1,64(sp)
ffffffffc020011a:	fc4a                	sd	s2,56(sp)
ffffffffc020011c:	f84e                	sd	s3,48(sp)
ffffffffc020011e:	f452                	sd	s4,40(sp)
ffffffffc0200120:	f056                	sd	s5,32(sp)
ffffffffc0200122:	ec5a                	sd	s6,24(sp)
ffffffffc0200124:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0200126:	c901                	beqz	a0,ffffffffc0200136 <readline+0x22>
ffffffffc0200128:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020012a:	00004517          	auipc	a0,0x4
ffffffffc020012e:	79e50513          	addi	a0,a0,1950 # ffffffffc02048c8 <etext+0x2c>
ffffffffc0200132:	f9bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
readline(const char *prompt) {
ffffffffc0200136:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200138:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020013a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020013c:	4aa9                	li	s5,10
ffffffffc020013e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200140:	0000ab97          	auipc	s7,0xa
ffffffffc0200144:	f08b8b93          	addi	s7,s7,-248 # ffffffffc020a048 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200148:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020014c:	fb9ff0ef          	jal	ra,ffffffffc0200104 <getchar>
        if (c < 0) {
ffffffffc0200150:	00054a63          	bltz	a0,ffffffffc0200164 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200154:	00a95a63          	bge	s2,a0,ffffffffc0200168 <readline+0x54>
ffffffffc0200158:	029a5263          	bge	s4,s1,ffffffffc020017c <readline+0x68>
        c = getchar();
ffffffffc020015c:	fa9ff0ef          	jal	ra,ffffffffc0200104 <getchar>
        if (c < 0) {
ffffffffc0200160:	fe055ae3          	bgez	a0,ffffffffc0200154 <readline+0x40>
            return NULL;
ffffffffc0200164:	4501                	li	a0,0
ffffffffc0200166:	a091                	j	ffffffffc02001aa <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0200168:	03351463          	bne	a0,s3,ffffffffc0200190 <readline+0x7c>
ffffffffc020016c:	e8a9                	bnez	s1,ffffffffc02001be <readline+0xaa>
        c = getchar();
ffffffffc020016e:	f97ff0ef          	jal	ra,ffffffffc0200104 <getchar>
        if (c < 0) {
ffffffffc0200172:	fe0549e3          	bltz	a0,ffffffffc0200164 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200176:	fea959e3          	bge	s2,a0,ffffffffc0200168 <readline+0x54>
ffffffffc020017a:	4481                	li	s1,0
            cputchar(c);
ffffffffc020017c:	e42a                	sd	a0,8(sp)
ffffffffc020017e:	f85ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i ++] = c;
ffffffffc0200182:	6522                	ld	a0,8(sp)
ffffffffc0200184:	009b87b3          	add	a5,s7,s1
ffffffffc0200188:	2485                	addiw	s1,s1,1
ffffffffc020018a:	00a78023          	sb	a0,0(a5)
ffffffffc020018e:	bf7d                	j	ffffffffc020014c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0200190:	01550463          	beq	a0,s5,ffffffffc0200198 <readline+0x84>
ffffffffc0200194:	fb651ce3          	bne	a0,s6,ffffffffc020014c <readline+0x38>
            cputchar(c);
ffffffffc0200198:	f6bff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i] = '\0';
ffffffffc020019c:	0000a517          	auipc	a0,0xa
ffffffffc02001a0:	eac50513          	addi	a0,a0,-340 # ffffffffc020a048 <buf>
ffffffffc02001a4:	94aa                	add	s1,s1,a0
ffffffffc02001a6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001aa:	60a6                	ld	ra,72(sp)
ffffffffc02001ac:	6486                	ld	s1,64(sp)
ffffffffc02001ae:	7962                	ld	s2,56(sp)
ffffffffc02001b0:	79c2                	ld	s3,48(sp)
ffffffffc02001b2:	7a22                	ld	s4,40(sp)
ffffffffc02001b4:	7a82                	ld	s5,32(sp)
ffffffffc02001b6:	6b62                	ld	s6,24(sp)
ffffffffc02001b8:	6bc2                	ld	s7,16(sp)
ffffffffc02001ba:	6161                	addi	sp,sp,80
ffffffffc02001bc:	8082                	ret
            cputchar(c);
ffffffffc02001be:	4521                	li	a0,8
ffffffffc02001c0:	f43ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            i --;
ffffffffc02001c4:	34fd                	addiw	s1,s1,-1
ffffffffc02001c6:	b759                	j	ffffffffc020014c <readline+0x38>

ffffffffc02001c8 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001c8:	00015317          	auipc	t1,0x15
ffffffffc02001cc:	45030313          	addi	t1,t1,1104 # ffffffffc0215618 <is_panic>
ffffffffc02001d0:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001d4:	715d                	addi	sp,sp,-80
ffffffffc02001d6:	ec06                	sd	ra,24(sp)
ffffffffc02001d8:	e822                	sd	s0,16(sp)
ffffffffc02001da:	f436                	sd	a3,40(sp)
ffffffffc02001dc:	f83a                	sd	a4,48(sp)
ffffffffc02001de:	fc3e                	sd	a5,56(sp)
ffffffffc02001e0:	e0c2                	sd	a6,64(sp)
ffffffffc02001e2:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001e4:	020e1a63          	bnez	t3,ffffffffc0200218 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02001e8:	4785                	li	a5,1
ffffffffc02001ea:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02001ee:	8432                	mv	s0,a2
ffffffffc02001f0:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001f2:	862e                	mv	a2,a1
ffffffffc02001f4:	85aa                	mv	a1,a0
ffffffffc02001f6:	00004517          	auipc	a0,0x4
ffffffffc02001fa:	6da50513          	addi	a0,a0,1754 # ffffffffc02048d0 <etext+0x34>
    va_start(ap, fmt);
ffffffffc02001fe:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200200:	ecdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200204:	65a2                	ld	a1,8(sp)
ffffffffc0200206:	8522                	mv	a0,s0
ffffffffc0200208:	ea5ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc020020c:	00006517          	auipc	a0,0x6
ffffffffc0200210:	0ac50513          	addi	a0,a0,172 # ffffffffc02062b8 <buddy_system_pmm_manager+0xd38>
ffffffffc0200214:	eb9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200218:	3ac000ef          	jal	ra,ffffffffc02005c4 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020021c:	4501                	li	a0,0
ffffffffc020021e:	130000ef          	jal	ra,ffffffffc020034e <kmonitor>
    while (1) {
ffffffffc0200222:	bfed                	j	ffffffffc020021c <__panic+0x54>

ffffffffc0200224 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200224:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200226:	00004517          	auipc	a0,0x4
ffffffffc020022a:	6ca50513          	addi	a0,a0,1738 # ffffffffc02048f0 <etext+0x54>
void print_kerninfo(void) {
ffffffffc020022e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200230:	e9dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200234:	00000597          	auipc	a1,0x0
ffffffffc0200238:	dfe58593          	addi	a1,a1,-514 # ffffffffc0200032 <kern_init>
ffffffffc020023c:	00004517          	auipc	a0,0x4
ffffffffc0200240:	6d450513          	addi	a0,a0,1748 # ffffffffc0204910 <etext+0x74>
ffffffffc0200244:	e89ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200248:	00004597          	auipc	a1,0x4
ffffffffc020024c:	65458593          	addi	a1,a1,1620 # ffffffffc020489c <etext>
ffffffffc0200250:	00004517          	auipc	a0,0x4
ffffffffc0200254:	6e050513          	addi	a0,a0,1760 # ffffffffc0204930 <etext+0x94>
ffffffffc0200258:	e75ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020025c:	0000a597          	auipc	a1,0xa
ffffffffc0200260:	dec58593          	addi	a1,a1,-532 # ffffffffc020a048 <buf>
ffffffffc0200264:	00004517          	auipc	a0,0x4
ffffffffc0200268:	6ec50513          	addi	a0,a0,1772 # ffffffffc0204950 <etext+0xb4>
ffffffffc020026c:	e61ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200270:	00015597          	auipc	a1,0x15
ffffffffc0200274:	43c58593          	addi	a1,a1,1084 # ffffffffc02156ac <end>
ffffffffc0200278:	00004517          	auipc	a0,0x4
ffffffffc020027c:	6f850513          	addi	a0,a0,1784 # ffffffffc0204970 <etext+0xd4>
ffffffffc0200280:	e4dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200284:	00016597          	auipc	a1,0x16
ffffffffc0200288:	82758593          	addi	a1,a1,-2009 # ffffffffc0215aab <end+0x3ff>
ffffffffc020028c:	00000797          	auipc	a5,0x0
ffffffffc0200290:	da678793          	addi	a5,a5,-602 # ffffffffc0200032 <kern_init>
ffffffffc0200294:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200298:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020029c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020029e:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002a2:	95be                	add	a1,a1,a5
ffffffffc02002a4:	85a9                	srai	a1,a1,0xa
ffffffffc02002a6:	00004517          	auipc	a0,0x4
ffffffffc02002aa:	6ea50513          	addi	a0,a0,1770 # ffffffffc0204990 <etext+0xf4>
}
ffffffffc02002ae:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002b0:	bd31                	j	ffffffffc02000cc <cprintf>

ffffffffc02002b2 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002b2:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002b4:	00004617          	auipc	a2,0x4
ffffffffc02002b8:	70c60613          	addi	a2,a2,1804 # ffffffffc02049c0 <etext+0x124>
ffffffffc02002bc:	04d00593          	li	a1,77
ffffffffc02002c0:	00004517          	auipc	a0,0x4
ffffffffc02002c4:	71850513          	addi	a0,a0,1816 # ffffffffc02049d8 <etext+0x13c>
void print_stackframe(void) {
ffffffffc02002c8:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002ca:	effff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02002ce <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002ce:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002d0:	00004617          	auipc	a2,0x4
ffffffffc02002d4:	72060613          	addi	a2,a2,1824 # ffffffffc02049f0 <etext+0x154>
ffffffffc02002d8:	00004597          	auipc	a1,0x4
ffffffffc02002dc:	73858593          	addi	a1,a1,1848 # ffffffffc0204a10 <etext+0x174>
ffffffffc02002e0:	00004517          	auipc	a0,0x4
ffffffffc02002e4:	73850513          	addi	a0,a0,1848 # ffffffffc0204a18 <etext+0x17c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e8:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002ea:	de3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc02002ee:	00004617          	auipc	a2,0x4
ffffffffc02002f2:	73a60613          	addi	a2,a2,1850 # ffffffffc0204a28 <etext+0x18c>
ffffffffc02002f6:	00004597          	auipc	a1,0x4
ffffffffc02002fa:	75a58593          	addi	a1,a1,1882 # ffffffffc0204a50 <etext+0x1b4>
ffffffffc02002fe:	00004517          	auipc	a0,0x4
ffffffffc0200302:	71a50513          	addi	a0,a0,1818 # ffffffffc0204a18 <etext+0x17c>
ffffffffc0200306:	dc7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020030a:	00004617          	auipc	a2,0x4
ffffffffc020030e:	75660613          	addi	a2,a2,1878 # ffffffffc0204a60 <etext+0x1c4>
ffffffffc0200312:	00004597          	auipc	a1,0x4
ffffffffc0200316:	76e58593          	addi	a1,a1,1902 # ffffffffc0204a80 <etext+0x1e4>
ffffffffc020031a:	00004517          	auipc	a0,0x4
ffffffffc020031e:	6fe50513          	addi	a0,a0,1790 # ffffffffc0204a18 <etext+0x17c>
ffffffffc0200322:	dabff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    }
    return 0;
}
ffffffffc0200326:	60a2                	ld	ra,8(sp)
ffffffffc0200328:	4501                	li	a0,0
ffffffffc020032a:	0141                	addi	sp,sp,16
ffffffffc020032c:	8082                	ret

ffffffffc020032e <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020032e:	1141                	addi	sp,sp,-16
ffffffffc0200330:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200332:	ef3ff0ef          	jal	ra,ffffffffc0200224 <print_kerninfo>
    return 0;
}
ffffffffc0200336:	60a2                	ld	ra,8(sp)
ffffffffc0200338:	4501                	li	a0,0
ffffffffc020033a:	0141                	addi	sp,sp,16
ffffffffc020033c:	8082                	ret

ffffffffc020033e <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020033e:	1141                	addi	sp,sp,-16
ffffffffc0200340:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200342:	f71ff0ef          	jal	ra,ffffffffc02002b2 <print_stackframe>
    return 0;
}
ffffffffc0200346:	60a2                	ld	ra,8(sp)
ffffffffc0200348:	4501                	li	a0,0
ffffffffc020034a:	0141                	addi	sp,sp,16
ffffffffc020034c:	8082                	ret

ffffffffc020034e <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020034e:	7115                	addi	sp,sp,-224
ffffffffc0200350:	ed5e                	sd	s7,152(sp)
ffffffffc0200352:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200354:	00004517          	auipc	a0,0x4
ffffffffc0200358:	73c50513          	addi	a0,a0,1852 # ffffffffc0204a90 <etext+0x1f4>
kmonitor(struct trapframe *tf) {
ffffffffc020035c:	ed86                	sd	ra,216(sp)
ffffffffc020035e:	e9a2                	sd	s0,208(sp)
ffffffffc0200360:	e5a6                	sd	s1,200(sp)
ffffffffc0200362:	e1ca                	sd	s2,192(sp)
ffffffffc0200364:	fd4e                	sd	s3,184(sp)
ffffffffc0200366:	f952                	sd	s4,176(sp)
ffffffffc0200368:	f556                	sd	s5,168(sp)
ffffffffc020036a:	f15a                	sd	s6,160(sp)
ffffffffc020036c:	e962                	sd	s8,144(sp)
ffffffffc020036e:	e566                	sd	s9,136(sp)
ffffffffc0200370:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200372:	d5bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200376:	00004517          	auipc	a0,0x4
ffffffffc020037a:	74250513          	addi	a0,a0,1858 # ffffffffc0204ab8 <etext+0x21c>
ffffffffc020037e:	d4fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    if (tf != NULL) {
ffffffffc0200382:	000b8563          	beqz	s7,ffffffffc020038c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200386:	855e                	mv	a0,s7
ffffffffc0200388:	49a000ef          	jal	ra,ffffffffc0200822 <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020038c:	4501                	li	a0,0
ffffffffc020038e:	4581                	li	a1,0
ffffffffc0200390:	4601                	li	a2,0
ffffffffc0200392:	48a1                	li	a7,8
ffffffffc0200394:	00000073          	ecall
ffffffffc0200398:	00004c17          	auipc	s8,0x4
ffffffffc020039c:	790c0c13          	addi	s8,s8,1936 # ffffffffc0204b28 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003a0:	00004917          	auipc	s2,0x4
ffffffffc02003a4:	74090913          	addi	s2,s2,1856 # ffffffffc0204ae0 <etext+0x244>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a8:	00004497          	auipc	s1,0x4
ffffffffc02003ac:	74048493          	addi	s1,s1,1856 # ffffffffc0204ae8 <etext+0x24c>
        if (argc == MAXARGS - 1) {
ffffffffc02003b0:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003b2:	00004b17          	auipc	s6,0x4
ffffffffc02003b6:	73eb0b13          	addi	s6,s6,1854 # ffffffffc0204af0 <etext+0x254>
        argv[argc ++] = buf;
ffffffffc02003ba:	00004a17          	auipc	s4,0x4
ffffffffc02003be:	656a0a13          	addi	s4,s4,1622 # ffffffffc0204a10 <etext+0x174>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003c2:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003c4:	854a                	mv	a0,s2
ffffffffc02003c6:	d4fff0ef          	jal	ra,ffffffffc0200114 <readline>
ffffffffc02003ca:	842a                	mv	s0,a0
ffffffffc02003cc:	dd65                	beqz	a0,ffffffffc02003c4 <kmonitor+0x76>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ce:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003d2:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003d4:	e1bd                	bnez	a1,ffffffffc020043a <kmonitor+0xec>
    if (argc == 0) {
ffffffffc02003d6:	fe0c87e3          	beqz	s9,ffffffffc02003c4 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003da:	6582                	ld	a1,0(sp)
ffffffffc02003dc:	00004d17          	auipc	s10,0x4
ffffffffc02003e0:	74cd0d13          	addi	s10,s10,1868 # ffffffffc0204b28 <commands>
        argv[argc ++] = buf;
ffffffffc02003e4:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e6:	4401                	li	s0,0
ffffffffc02003e8:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ea:	02c040ef          	jal	ra,ffffffffc0204416 <strcmp>
ffffffffc02003ee:	c919                	beqz	a0,ffffffffc0200404 <kmonitor+0xb6>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003f0:	2405                	addiw	s0,s0,1
ffffffffc02003f2:	0b540063          	beq	s0,s5,ffffffffc0200492 <kmonitor+0x144>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f6:	000d3503          	ld	a0,0(s10)
ffffffffc02003fa:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003fc:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003fe:	018040ef          	jal	ra,ffffffffc0204416 <strcmp>
ffffffffc0200402:	f57d                	bnez	a0,ffffffffc02003f0 <kmonitor+0xa2>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200404:	00141793          	slli	a5,s0,0x1
ffffffffc0200408:	97a2                	add	a5,a5,s0
ffffffffc020040a:	078e                	slli	a5,a5,0x3
ffffffffc020040c:	97e2                	add	a5,a5,s8
ffffffffc020040e:	6b9c                	ld	a5,16(a5)
ffffffffc0200410:	865e                	mv	a2,s7
ffffffffc0200412:	002c                	addi	a1,sp,8
ffffffffc0200414:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200418:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020041a:	fa0555e3          	bgez	a0,ffffffffc02003c4 <kmonitor+0x76>
}
ffffffffc020041e:	60ee                	ld	ra,216(sp)
ffffffffc0200420:	644e                	ld	s0,208(sp)
ffffffffc0200422:	64ae                	ld	s1,200(sp)
ffffffffc0200424:	690e                	ld	s2,192(sp)
ffffffffc0200426:	79ea                	ld	s3,184(sp)
ffffffffc0200428:	7a4a                	ld	s4,176(sp)
ffffffffc020042a:	7aaa                	ld	s5,168(sp)
ffffffffc020042c:	7b0a                	ld	s6,160(sp)
ffffffffc020042e:	6bea                	ld	s7,152(sp)
ffffffffc0200430:	6c4a                	ld	s8,144(sp)
ffffffffc0200432:	6caa                	ld	s9,136(sp)
ffffffffc0200434:	6d0a                	ld	s10,128(sp)
ffffffffc0200436:	612d                	addi	sp,sp,224
ffffffffc0200438:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020043a:	8526                	mv	a0,s1
ffffffffc020043c:	7f9030ef          	jal	ra,ffffffffc0204434 <strchr>
ffffffffc0200440:	c901                	beqz	a0,ffffffffc0200450 <kmonitor+0x102>
ffffffffc0200442:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200446:	00040023          	sb	zero,0(s0)
ffffffffc020044a:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020044c:	d5c9                	beqz	a1,ffffffffc02003d6 <kmonitor+0x88>
ffffffffc020044e:	b7f5                	j	ffffffffc020043a <kmonitor+0xec>
        if (*buf == '\0') {
ffffffffc0200450:	00044783          	lbu	a5,0(s0)
ffffffffc0200454:	d3c9                	beqz	a5,ffffffffc02003d6 <kmonitor+0x88>
        if (argc == MAXARGS - 1) {
ffffffffc0200456:	033c8963          	beq	s9,s3,ffffffffc0200488 <kmonitor+0x13a>
        argv[argc ++] = buf;
ffffffffc020045a:	003c9793          	slli	a5,s9,0x3
ffffffffc020045e:	0118                	addi	a4,sp,128
ffffffffc0200460:	97ba                	add	a5,a5,a4
ffffffffc0200462:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200466:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020046a:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020046c:	e591                	bnez	a1,ffffffffc0200478 <kmonitor+0x12a>
ffffffffc020046e:	b7b5                	j	ffffffffc02003da <kmonitor+0x8c>
ffffffffc0200470:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200474:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200476:	d1a5                	beqz	a1,ffffffffc02003d6 <kmonitor+0x88>
ffffffffc0200478:	8526                	mv	a0,s1
ffffffffc020047a:	7bb030ef          	jal	ra,ffffffffc0204434 <strchr>
ffffffffc020047e:	d96d                	beqz	a0,ffffffffc0200470 <kmonitor+0x122>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200480:	00044583          	lbu	a1,0(s0)
ffffffffc0200484:	d9a9                	beqz	a1,ffffffffc02003d6 <kmonitor+0x88>
ffffffffc0200486:	bf55                	j	ffffffffc020043a <kmonitor+0xec>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200488:	45c1                	li	a1,16
ffffffffc020048a:	855a                	mv	a0,s6
ffffffffc020048c:	c41ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0200490:	b7e9                	j	ffffffffc020045a <kmonitor+0x10c>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200492:	6582                	ld	a1,0(sp)
ffffffffc0200494:	00004517          	auipc	a0,0x4
ffffffffc0200498:	67c50513          	addi	a0,a0,1660 # ffffffffc0204b10 <etext+0x274>
ffffffffc020049c:	c31ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
ffffffffc02004a0:	b715                	j	ffffffffc02003c4 <kmonitor+0x76>

ffffffffc02004a2 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02004a2:	8082                	ret

ffffffffc02004a4 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02004a4:	00253513          	sltiu	a0,a0,2
ffffffffc02004a8:	8082                	ret

ffffffffc02004aa <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02004aa:	03800513          	li	a0,56
ffffffffc02004ae:	8082                	ret

ffffffffc02004b0 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b0:	0000a797          	auipc	a5,0xa
ffffffffc02004b4:	f9878793          	addi	a5,a5,-104 # ffffffffc020a448 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02004b8:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004bc:	1141                	addi	sp,sp,-16
ffffffffc02004be:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004c0:	95be                	add	a1,a1,a5
ffffffffc02004c2:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004c6:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004c8:	795030ef          	jal	ra,ffffffffc020445c <memcpy>
    return 0;
}
ffffffffc02004cc:	60a2                	ld	ra,8(sp)
ffffffffc02004ce:	4501                	li	a0,0
ffffffffc02004d0:	0141                	addi	sp,sp,16
ffffffffc02004d2:	8082                	ret

ffffffffc02004d4 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc02004d4:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d8:	0000a517          	auipc	a0,0xa
ffffffffc02004dc:	f7050513          	addi	a0,a0,-144 # ffffffffc020a448 <ide>
                   size_t nsecs) {
ffffffffc02004e0:	1141                	addi	sp,sp,-16
ffffffffc02004e2:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e4:	953e                	add	a0,a0,a5
ffffffffc02004e6:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004ea:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004ec:	771030ef          	jal	ra,ffffffffc020445c <memcpy>
    return 0;
}
ffffffffc02004f0:	60a2                	ld	ra,8(sp)
ffffffffc02004f2:	4501                	li	a0,0
ffffffffc02004f4:	0141                	addi	sp,sp,16
ffffffffc02004f6:	8082                	ret

ffffffffc02004f8 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004f8:	67e1                	lui	a5,0x18
ffffffffc02004fa:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02004fe:	00015717          	auipc	a4,0x15
ffffffffc0200502:	12f73523          	sd	a5,298(a4) # ffffffffc0215628 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200506:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020050a:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020050c:	953e                	add	a0,a0,a5
ffffffffc020050e:	4601                	li	a2,0
ffffffffc0200510:	4881                	li	a7,0
ffffffffc0200512:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200516:	02000793          	li	a5,32
ffffffffc020051a:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020051e:	00004517          	auipc	a0,0x4
ffffffffc0200522:	65250513          	addi	a0,a0,1618 # ffffffffc0204b70 <commands+0x48>
    ticks = 0;
ffffffffc0200526:	00015797          	auipc	a5,0x15
ffffffffc020052a:	0e07bd23          	sd	zero,250(a5) # ffffffffc0215620 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020052e:	be79                	j	ffffffffc02000cc <cprintf>

ffffffffc0200530 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200530:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200534:	00015797          	auipc	a5,0x15
ffffffffc0200538:	0f47b783          	ld	a5,244(a5) # ffffffffc0215628 <timebase>
ffffffffc020053c:	953e                	add	a0,a0,a5
ffffffffc020053e:	4581                	li	a1,0
ffffffffc0200540:	4601                	li	a2,0
ffffffffc0200542:	4881                	li	a7,0
ffffffffc0200544:	00000073          	ecall
ffffffffc0200548:	8082                	ret

ffffffffc020054a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020054a:	8082                	ret

ffffffffc020054c <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020054c:	100027f3          	csrr	a5,sstatus
ffffffffc0200550:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200552:	0ff57513          	zext.b	a0,a0
ffffffffc0200556:	e799                	bnez	a5,ffffffffc0200564 <cons_putc+0x18>
ffffffffc0200558:	4581                	li	a1,0
ffffffffc020055a:	4601                	li	a2,0
ffffffffc020055c:	4885                	li	a7,1
ffffffffc020055e:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200562:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200564:	1101                	addi	sp,sp,-32
ffffffffc0200566:	ec06                	sd	ra,24(sp)
ffffffffc0200568:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020056a:	05a000ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc020056e:	6522                	ld	a0,8(sp)
ffffffffc0200570:	4581                	li	a1,0
ffffffffc0200572:	4601                	li	a2,0
ffffffffc0200574:	4885                	li	a7,1
ffffffffc0200576:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc020057a:	60e2                	ld	ra,24(sp)
ffffffffc020057c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020057e:	a081                	j	ffffffffc02005be <intr_enable>

ffffffffc0200580 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200580:	100027f3          	csrr	a5,sstatus
ffffffffc0200584:	8b89                	andi	a5,a5,2
ffffffffc0200586:	eb89                	bnez	a5,ffffffffc0200598 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200588:	4501                	li	a0,0
ffffffffc020058a:	4581                	li	a1,0
ffffffffc020058c:	4601                	li	a2,0
ffffffffc020058e:	4889                	li	a7,2
ffffffffc0200590:	00000073          	ecall
ffffffffc0200594:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200596:	8082                	ret
int cons_getc(void) {
ffffffffc0200598:	1101                	addi	sp,sp,-32
ffffffffc020059a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020059c:	028000ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc02005a0:	4501                	li	a0,0
ffffffffc02005a2:	4581                	li	a1,0
ffffffffc02005a4:	4601                	li	a2,0
ffffffffc02005a6:	4889                	li	a7,2
ffffffffc02005a8:	00000073          	ecall
ffffffffc02005ac:	2501                	sext.w	a0,a0
ffffffffc02005ae:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005b0:	00e000ef          	jal	ra,ffffffffc02005be <intr_enable>
}
ffffffffc02005b4:	60e2                	ld	ra,24(sp)
ffffffffc02005b6:	6522                	ld	a0,8(sp)
ffffffffc02005b8:	6105                	addi	sp,sp,32
ffffffffc02005ba:	8082                	ret

ffffffffc02005bc <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005bc:	8082                	ret

ffffffffc02005be <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005be:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005c2:	8082                	ret

ffffffffc02005c4 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005c4:	100177f3          	csrrci	a5,sstatus,2
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
ffffffffc02005fe:	59650513          	addi	a0,a0,1430 # ffffffffc0204b90 <commands+0x68>
ffffffffc0200602:	acbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200606:	00015517          	auipc	a0,0x15
ffffffffc020060a:	02a53503          	ld	a0,42(a0) # ffffffffc0215630 <check_mm_struct>
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
ffffffffc020061e:	3be0106f          	j	ffffffffc02019dc <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200622:	00004617          	auipc	a2,0x4
ffffffffc0200626:	58e60613          	addi	a2,a2,1422 # ffffffffc0204bb0 <commands+0x88>
ffffffffc020062a:	06200593          	li	a1,98
ffffffffc020062e:	00004517          	auipc	a0,0x4
ffffffffc0200632:	59a50513          	addi	a0,a0,1434 # ffffffffc0204bc8 <commands+0xa0>
ffffffffc0200636:	b93ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

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
ffffffffc0200660:	58450513          	addi	a0,a0,1412 # ffffffffc0204be0 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200664:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200666:	a67ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020066a:	640c                	ld	a1,8(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	58c50513          	addi	a0,a0,1420 # ffffffffc0204bf8 <commands+0xd0>
ffffffffc0200674:	a59ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200678:	680c                	ld	a1,16(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	59650513          	addi	a0,a0,1430 # ffffffffc0204c10 <commands+0xe8>
ffffffffc0200682:	a4bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200686:	6c0c                	ld	a1,24(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	5a050513          	addi	a0,a0,1440 # ffffffffc0204c28 <commands+0x100>
ffffffffc0200690:	a3dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200694:	700c                	ld	a1,32(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	5aa50513          	addi	a0,a0,1450 # ffffffffc0204c40 <commands+0x118>
ffffffffc020069e:	a2fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006a2:	740c                	ld	a1,40(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	5b450513          	addi	a0,a0,1460 # ffffffffc0204c58 <commands+0x130>
ffffffffc02006ac:	a21ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006b0:	780c                	ld	a1,48(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	5be50513          	addi	a0,a0,1470 # ffffffffc0204c70 <commands+0x148>
ffffffffc02006ba:	a13ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006be:	7c0c                	ld	a1,56(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	5c850513          	addi	a0,a0,1480 # ffffffffc0204c88 <commands+0x160>
ffffffffc02006c8:	a05ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006cc:	602c                	ld	a1,64(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	5d250513          	addi	a0,a0,1490 # ffffffffc0204ca0 <commands+0x178>
ffffffffc02006d6:	9f7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006da:	642c                	ld	a1,72(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	5dc50513          	addi	a0,a0,1500 # ffffffffc0204cb8 <commands+0x190>
ffffffffc02006e4:	9e9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006e8:	682c                	ld	a1,80(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	5e650513          	addi	a0,a0,1510 # ffffffffc0204cd0 <commands+0x1a8>
ffffffffc02006f2:	9dbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006f6:	6c2c                	ld	a1,88(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	5f050513          	addi	a0,a0,1520 # ffffffffc0204ce8 <commands+0x1c0>
ffffffffc0200700:	9cdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200704:	702c                	ld	a1,96(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	5fa50513          	addi	a0,a0,1530 # ffffffffc0204d00 <commands+0x1d8>
ffffffffc020070e:	9bfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200712:	742c                	ld	a1,104(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	60450513          	addi	a0,a0,1540 # ffffffffc0204d18 <commands+0x1f0>
ffffffffc020071c:	9b1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200720:	782c                	ld	a1,112(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	60e50513          	addi	a0,a0,1550 # ffffffffc0204d30 <commands+0x208>
ffffffffc020072a:	9a3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020072e:	7c2c                	ld	a1,120(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	61850513          	addi	a0,a0,1560 # ffffffffc0204d48 <commands+0x220>
ffffffffc0200738:	995ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020073c:	604c                	ld	a1,128(s0)
ffffffffc020073e:	00004517          	auipc	a0,0x4
ffffffffc0200742:	62250513          	addi	a0,a0,1570 # ffffffffc0204d60 <commands+0x238>
ffffffffc0200746:	987ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020074a:	644c                	ld	a1,136(s0)
ffffffffc020074c:	00004517          	auipc	a0,0x4
ffffffffc0200750:	62c50513          	addi	a0,a0,1580 # ffffffffc0204d78 <commands+0x250>
ffffffffc0200754:	979ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200758:	684c                	ld	a1,144(s0)
ffffffffc020075a:	00004517          	auipc	a0,0x4
ffffffffc020075e:	63650513          	addi	a0,a0,1590 # ffffffffc0204d90 <commands+0x268>
ffffffffc0200762:	96bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200766:	6c4c                	ld	a1,152(s0)
ffffffffc0200768:	00004517          	auipc	a0,0x4
ffffffffc020076c:	64050513          	addi	a0,a0,1600 # ffffffffc0204da8 <commands+0x280>
ffffffffc0200770:	95dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200774:	704c                	ld	a1,160(s0)
ffffffffc0200776:	00004517          	auipc	a0,0x4
ffffffffc020077a:	64a50513          	addi	a0,a0,1610 # ffffffffc0204dc0 <commands+0x298>
ffffffffc020077e:	94fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200782:	744c                	ld	a1,168(s0)
ffffffffc0200784:	00004517          	auipc	a0,0x4
ffffffffc0200788:	65450513          	addi	a0,a0,1620 # ffffffffc0204dd8 <commands+0x2b0>
ffffffffc020078c:	941ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200790:	784c                	ld	a1,176(s0)
ffffffffc0200792:	00004517          	auipc	a0,0x4
ffffffffc0200796:	65e50513          	addi	a0,a0,1630 # ffffffffc0204df0 <commands+0x2c8>
ffffffffc020079a:	933ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020079e:	7c4c                	ld	a1,184(s0)
ffffffffc02007a0:	00004517          	auipc	a0,0x4
ffffffffc02007a4:	66850513          	addi	a0,a0,1640 # ffffffffc0204e08 <commands+0x2e0>
ffffffffc02007a8:	925ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007ac:	606c                	ld	a1,192(s0)
ffffffffc02007ae:	00004517          	auipc	a0,0x4
ffffffffc02007b2:	67250513          	addi	a0,a0,1650 # ffffffffc0204e20 <commands+0x2f8>
ffffffffc02007b6:	917ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ba:	646c                	ld	a1,200(s0)
ffffffffc02007bc:	00004517          	auipc	a0,0x4
ffffffffc02007c0:	67c50513          	addi	a0,a0,1660 # ffffffffc0204e38 <commands+0x310>
ffffffffc02007c4:	909ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007c8:	686c                	ld	a1,208(s0)
ffffffffc02007ca:	00004517          	auipc	a0,0x4
ffffffffc02007ce:	68650513          	addi	a0,a0,1670 # ffffffffc0204e50 <commands+0x328>
ffffffffc02007d2:	8fbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007d6:	6c6c                	ld	a1,216(s0)
ffffffffc02007d8:	00004517          	auipc	a0,0x4
ffffffffc02007dc:	69050513          	addi	a0,a0,1680 # ffffffffc0204e68 <commands+0x340>
ffffffffc02007e0:	8edff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007e4:	706c                	ld	a1,224(s0)
ffffffffc02007e6:	00004517          	auipc	a0,0x4
ffffffffc02007ea:	69a50513          	addi	a0,a0,1690 # ffffffffc0204e80 <commands+0x358>
ffffffffc02007ee:	8dfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007f2:	746c                	ld	a1,232(s0)
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	6a450513          	addi	a0,a0,1700 # ffffffffc0204e98 <commands+0x370>
ffffffffc02007fc:	8d1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200800:	786c                	ld	a1,240(s0)
ffffffffc0200802:	00004517          	auipc	a0,0x4
ffffffffc0200806:	6ae50513          	addi	a0,a0,1710 # ffffffffc0204eb0 <commands+0x388>
ffffffffc020080a:	8c3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020080e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200810:	6402                	ld	s0,0(sp)
ffffffffc0200812:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200814:	00004517          	auipc	a0,0x4
ffffffffc0200818:	6b450513          	addi	a0,a0,1716 # ffffffffc0204ec8 <commands+0x3a0>
}
ffffffffc020081c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020081e:	8afff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200822 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200822:	1141                	addi	sp,sp,-16
ffffffffc0200824:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200826:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200828:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020082a:	00004517          	auipc	a0,0x4
ffffffffc020082e:	6b650513          	addi	a0,a0,1718 # ffffffffc0204ee0 <commands+0x3b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200832:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200834:	899ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200838:	8522                	mv	a0,s0
ffffffffc020083a:	e1bff0ef          	jal	ra,ffffffffc0200654 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020083e:	10043583          	ld	a1,256(s0)
ffffffffc0200842:	00004517          	auipc	a0,0x4
ffffffffc0200846:	6b650513          	addi	a0,a0,1718 # ffffffffc0204ef8 <commands+0x3d0>
ffffffffc020084a:	883ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020084e:	10843583          	ld	a1,264(s0)
ffffffffc0200852:	00004517          	auipc	a0,0x4
ffffffffc0200856:	6be50513          	addi	a0,a0,1726 # ffffffffc0204f10 <commands+0x3e8>
ffffffffc020085a:	873ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020085e:	11043583          	ld	a1,272(s0)
ffffffffc0200862:	00004517          	auipc	a0,0x4
ffffffffc0200866:	6c650513          	addi	a0,a0,1734 # ffffffffc0204f28 <commands+0x400>
ffffffffc020086a:	863ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020086e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200872:	6402                	ld	s0,0(sp)
ffffffffc0200874:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200876:	00004517          	auipc	a0,0x4
ffffffffc020087a:	6ca50513          	addi	a0,a0,1738 # ffffffffc0204f40 <commands+0x418>
}
ffffffffc020087e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200880:	84dff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200884 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200884:	11853783          	ld	a5,280(a0)
ffffffffc0200888:	472d                	li	a4,11
ffffffffc020088a:	0786                	slli	a5,a5,0x1
ffffffffc020088c:	8385                	srli	a5,a5,0x1
ffffffffc020088e:	06f76c63          	bltu	a4,a5,ffffffffc0200906 <interrupt_handler+0x82>
ffffffffc0200892:	00004717          	auipc	a4,0x4
ffffffffc0200896:	77670713          	addi	a4,a4,1910 # ffffffffc0205008 <commands+0x4e0>
ffffffffc020089a:	078a                	slli	a5,a5,0x2
ffffffffc020089c:	97ba                	add	a5,a5,a4
ffffffffc020089e:	439c                	lw	a5,0(a5)
ffffffffc02008a0:	97ba                	add	a5,a5,a4
ffffffffc02008a2:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	71450513          	addi	a0,a0,1812 # ffffffffc0204fb8 <commands+0x490>
ffffffffc02008ac:	821ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008b0:	00004517          	auipc	a0,0x4
ffffffffc02008b4:	6e850513          	addi	a0,a0,1768 # ffffffffc0204f98 <commands+0x470>
ffffffffc02008b8:	815ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008bc:	00004517          	auipc	a0,0x4
ffffffffc02008c0:	69c50513          	addi	a0,a0,1692 # ffffffffc0204f58 <commands+0x430>
ffffffffc02008c4:	809ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008c8:	00004517          	auipc	a0,0x4
ffffffffc02008cc:	6b050513          	addi	a0,a0,1712 # ffffffffc0204f78 <commands+0x450>
ffffffffc02008d0:	ffcff06f          	j	ffffffffc02000cc <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008d4:	1141                	addi	sp,sp,-16
ffffffffc02008d6:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02008d8:	c59ff0ef          	jal	ra,ffffffffc0200530 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02008dc:	00015697          	auipc	a3,0x15
ffffffffc02008e0:	d4468693          	addi	a3,a3,-700 # ffffffffc0215620 <ticks>
ffffffffc02008e4:	629c                	ld	a5,0(a3)
ffffffffc02008e6:	06400713          	li	a4,100
ffffffffc02008ea:	0785                	addi	a5,a5,1
ffffffffc02008ec:	02e7f733          	remu	a4,a5,a4
ffffffffc02008f0:	e29c                	sd	a5,0(a3)
ffffffffc02008f2:	cb19                	beqz	a4,ffffffffc0200908 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008f4:	60a2                	ld	ra,8(sp)
ffffffffc02008f6:	0141                	addi	sp,sp,16
ffffffffc02008f8:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc02008fa:	00004517          	auipc	a0,0x4
ffffffffc02008fe:	6ee50513          	addi	a0,a0,1774 # ffffffffc0204fe8 <commands+0x4c0>
ffffffffc0200902:	fcaff06f          	j	ffffffffc02000cc <cprintf>
            print_trapframe(tf);
ffffffffc0200906:	bf31                	j	ffffffffc0200822 <print_trapframe>
}
ffffffffc0200908:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020090a:	06400593          	li	a1,100
ffffffffc020090e:	00004517          	auipc	a0,0x4
ffffffffc0200912:	6ca50513          	addi	a0,a0,1738 # ffffffffc0204fd8 <commands+0x4b0>
}
ffffffffc0200916:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200918:	fb4ff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc020091c <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020091c:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200920:	1101                	addi	sp,sp,-32
ffffffffc0200922:	e822                	sd	s0,16(sp)
ffffffffc0200924:	ec06                	sd	ra,24(sp)
ffffffffc0200926:	e426                	sd	s1,8(sp)
ffffffffc0200928:	473d                	li	a4,15
ffffffffc020092a:	842a                	mv	s0,a0
ffffffffc020092c:	14f76a63          	bltu	a4,a5,ffffffffc0200a80 <exception_handler+0x164>
ffffffffc0200930:	00005717          	auipc	a4,0x5
ffffffffc0200934:	8c070713          	addi	a4,a4,-1856 # ffffffffc02051f0 <commands+0x6c8>
ffffffffc0200938:	078a                	slli	a5,a5,0x2
ffffffffc020093a:	97ba                	add	a5,a5,a4
ffffffffc020093c:	439c                	lw	a5,0(a5)
ffffffffc020093e:	97ba                	add	a5,a5,a4
ffffffffc0200940:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200942:	00005517          	auipc	a0,0x5
ffffffffc0200946:	89650513          	addi	a0,a0,-1898 # ffffffffc02051d8 <commands+0x6b0>
ffffffffc020094a:	f82ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020094e:	8522                	mv	a0,s0
ffffffffc0200950:	c7bff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc0200954:	84aa                	mv	s1,a0
ffffffffc0200956:	12051b63          	bnez	a0,ffffffffc0200a8c <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020095a:	60e2                	ld	ra,24(sp)
ffffffffc020095c:	6442                	ld	s0,16(sp)
ffffffffc020095e:	64a2                	ld	s1,8(sp)
ffffffffc0200960:	6105                	addi	sp,sp,32
ffffffffc0200962:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200964:	00004517          	auipc	a0,0x4
ffffffffc0200968:	6d450513          	addi	a0,a0,1748 # ffffffffc0205038 <commands+0x510>
}
ffffffffc020096c:	6442                	ld	s0,16(sp)
ffffffffc020096e:	60e2                	ld	ra,24(sp)
ffffffffc0200970:	64a2                	ld	s1,8(sp)
ffffffffc0200972:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200974:	f58ff06f          	j	ffffffffc02000cc <cprintf>
ffffffffc0200978:	00004517          	auipc	a0,0x4
ffffffffc020097c:	6e050513          	addi	a0,a0,1760 # ffffffffc0205058 <commands+0x530>
ffffffffc0200980:	b7f5                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200982:	00004517          	auipc	a0,0x4
ffffffffc0200986:	6f650513          	addi	a0,a0,1782 # ffffffffc0205078 <commands+0x550>
ffffffffc020098a:	b7cd                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc020098c:	00004517          	auipc	a0,0x4
ffffffffc0200990:	70450513          	addi	a0,a0,1796 # ffffffffc0205090 <commands+0x568>
ffffffffc0200994:	bfe1                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc0200996:	00004517          	auipc	a0,0x4
ffffffffc020099a:	70a50513          	addi	a0,a0,1802 # ffffffffc02050a0 <commands+0x578>
ffffffffc020099e:	b7f9                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02009a0:	00004517          	auipc	a0,0x4
ffffffffc02009a4:	72050513          	addi	a0,a0,1824 # ffffffffc02050c0 <commands+0x598>
ffffffffc02009a8:	f24ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009ac:	8522                	mv	a0,s0
ffffffffc02009ae:	c1dff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc02009b2:	84aa                	mv	s1,a0
ffffffffc02009b4:	d15d                	beqz	a0,ffffffffc020095a <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009b6:	8522                	mv	a0,s0
ffffffffc02009b8:	e6bff0ef          	jal	ra,ffffffffc0200822 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009bc:	86a6                	mv	a3,s1
ffffffffc02009be:	00004617          	auipc	a2,0x4
ffffffffc02009c2:	71a60613          	addi	a2,a2,1818 # ffffffffc02050d8 <commands+0x5b0>
ffffffffc02009c6:	0b300593          	li	a1,179
ffffffffc02009ca:	00004517          	auipc	a0,0x4
ffffffffc02009ce:	1fe50513          	addi	a0,a0,510 # ffffffffc0204bc8 <commands+0xa0>
ffffffffc02009d2:	ff6ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009d6:	00004517          	auipc	a0,0x4
ffffffffc02009da:	72250513          	addi	a0,a0,1826 # ffffffffc02050f8 <commands+0x5d0>
ffffffffc02009de:	b779                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02009e0:	00004517          	auipc	a0,0x4
ffffffffc02009e4:	73050513          	addi	a0,a0,1840 # ffffffffc0205110 <commands+0x5e8>
ffffffffc02009e8:	ee4ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009ec:	8522                	mv	a0,s0
ffffffffc02009ee:	bddff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc02009f2:	84aa                	mv	s1,a0
ffffffffc02009f4:	d13d                	beqz	a0,ffffffffc020095a <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009f6:	8522                	mv	a0,s0
ffffffffc02009f8:	e2bff0ef          	jal	ra,ffffffffc0200822 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009fc:	86a6                	mv	a3,s1
ffffffffc02009fe:	00004617          	auipc	a2,0x4
ffffffffc0200a02:	6da60613          	addi	a2,a2,1754 # ffffffffc02050d8 <commands+0x5b0>
ffffffffc0200a06:	0bd00593          	li	a1,189
ffffffffc0200a0a:	00004517          	auipc	a0,0x4
ffffffffc0200a0e:	1be50513          	addi	a0,a0,446 # ffffffffc0204bc8 <commands+0xa0>
ffffffffc0200a12:	fb6ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a16:	00004517          	auipc	a0,0x4
ffffffffc0200a1a:	71250513          	addi	a0,a0,1810 # ffffffffc0205128 <commands+0x600>
ffffffffc0200a1e:	b7b9                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a20:	00004517          	auipc	a0,0x4
ffffffffc0200a24:	72850513          	addi	a0,a0,1832 # ffffffffc0205148 <commands+0x620>
ffffffffc0200a28:	b791                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a2a:	00004517          	auipc	a0,0x4
ffffffffc0200a2e:	73e50513          	addi	a0,a0,1854 # ffffffffc0205168 <commands+0x640>
ffffffffc0200a32:	bf2d                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a34:	00004517          	auipc	a0,0x4
ffffffffc0200a38:	75450513          	addi	a0,a0,1876 # ffffffffc0205188 <commands+0x660>
ffffffffc0200a3c:	bf05                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a3e:	00004517          	auipc	a0,0x4
ffffffffc0200a42:	76a50513          	addi	a0,a0,1898 # ffffffffc02051a8 <commands+0x680>
ffffffffc0200a46:	b71d                	j	ffffffffc020096c <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a48:	00004517          	auipc	a0,0x4
ffffffffc0200a4c:	77850513          	addi	a0,a0,1912 # ffffffffc02051c0 <commands+0x698>
ffffffffc0200a50:	e7cff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a54:	8522                	mv	a0,s0
ffffffffc0200a56:	b75ff0ef          	jal	ra,ffffffffc02005ca <pgfault_handler>
ffffffffc0200a5a:	84aa                	mv	s1,a0
ffffffffc0200a5c:	ee050fe3          	beqz	a0,ffffffffc020095a <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a60:	8522                	mv	a0,s0
ffffffffc0200a62:	dc1ff0ef          	jal	ra,ffffffffc0200822 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a66:	86a6                	mv	a3,s1
ffffffffc0200a68:	00004617          	auipc	a2,0x4
ffffffffc0200a6c:	67060613          	addi	a2,a2,1648 # ffffffffc02050d8 <commands+0x5b0>
ffffffffc0200a70:	0d300593          	li	a1,211
ffffffffc0200a74:	00004517          	auipc	a0,0x4
ffffffffc0200a78:	15450513          	addi	a0,a0,340 # ffffffffc0204bc8 <commands+0xa0>
ffffffffc0200a7c:	f4cff0ef          	jal	ra,ffffffffc02001c8 <__panic>
            print_trapframe(tf);
ffffffffc0200a80:	8522                	mv	a0,s0
}
ffffffffc0200a82:	6442                	ld	s0,16(sp)
ffffffffc0200a84:	60e2                	ld	ra,24(sp)
ffffffffc0200a86:	64a2                	ld	s1,8(sp)
ffffffffc0200a88:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a8a:	bb61                	j	ffffffffc0200822 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a8c:	8522                	mv	a0,s0
ffffffffc0200a8e:	d95ff0ef          	jal	ra,ffffffffc0200822 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a92:	86a6                	mv	a3,s1
ffffffffc0200a94:	00004617          	auipc	a2,0x4
ffffffffc0200a98:	64460613          	addi	a2,a2,1604 # ffffffffc02050d8 <commands+0x5b0>
ffffffffc0200a9c:	0da00593          	li	a1,218
ffffffffc0200aa0:	00004517          	auipc	a0,0x4
ffffffffc0200aa4:	12850513          	addi	a0,a0,296 # ffffffffc0204bc8 <commands+0xa0>
ffffffffc0200aa8:	f20ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0200aac <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200aac:	11853783          	ld	a5,280(a0)
ffffffffc0200ab0:	0007c363          	bltz	a5,ffffffffc0200ab6 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200ab4:	b5a5                	j	ffffffffc020091c <exception_handler>
        interrupt_handler(tf);
ffffffffc0200ab6:	b3f9                	j	ffffffffc0200884 <interrupt_handler>

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
ffffffffc0200b1a:	f93ff0ef          	jal	ra,ffffffffc0200aac <trap>

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
ffffffffc0200b98:	69c50513          	addi	a0,a0,1692 # ffffffffc0205230 <commands+0x708>
{
ffffffffc0200b9c:	f406                	sd	ra,40(sp)
ffffffffc0200b9e:	f022                	sd	s0,32(sp)
ffffffffc0200ba0:	ec26                	sd	s1,24(sp)
ffffffffc0200ba2:	e84a                	sd	s2,16(sp)
ffffffffc0200ba4:	e44e                	sd	s3,8(sp)
    cprintf("################################################################################\n");
ffffffffc0200ba6:	d26ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
	cprintf("[自检程序]启动buddy_system内存管理器的启动自检程序\n");
ffffffffc0200baa:	00004517          	auipc	a0,0x4
ffffffffc0200bae:	6de50513          	addi	a0,a0,1758 # ffffffffc0205288 <commands+0x760>
ffffffffc0200bb2:	d1aff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int all_pages = nr_free_pages();
ffffffffc0200bb6:	6e1010ef          	jal	ra,ffffffffc0202a96 <nr_free_pages>
    struct Page* p0, *p1, *p2, *p3;
    // 分配过大的页数
    assert(alloc_pages(all_pages + 1) == NULL);
ffffffffc0200bba:	2505                	addiw	a0,a0,1
ffffffffc0200bbc:	609010ef          	jal	ra,ffffffffc02029c4 <alloc_pages>
ffffffffc0200bc0:	26051d63          	bnez	a0,ffffffffc0200e3a <buddy_system_check+0x2a8>
    // 分配两个组页
    p0 = alloc_pages(1);
ffffffffc0200bc4:	4505                	li	a0,1
ffffffffc0200bc6:	5ff010ef          	jal	ra,ffffffffc02029c4 <alloc_pages>
ffffffffc0200bca:	842a                	mv	s0,a0
    test_print(p0,16);//1
    assert(p0 != NULL);
ffffffffc0200bcc:	24050763          	beqz	a0,ffffffffc0200e1a <buddy_system_check+0x288>
    p1 = alloc_pages(2);
ffffffffc0200bd0:	4509                	li	a0,2
ffffffffc0200bd2:	5f3010ef          	jal	ra,ffffffffc02029c4 <alloc_pages>
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
ffffffffc0200c06:	5bf010ef          	jal	ra,ffffffffc02029c4 <alloc_pages>
    test_print(p0,16);//3
    assert(p2 == p0 + 1);
ffffffffc0200c0a:	04040793          	addi	a5,s0,64
    p2 = alloc_pages(1);
ffffffffc0200c0e:	89aa                	mv	s3,a0
    assert(p2 == p0 + 1);
ffffffffc0200c10:	18f51563          	bne	a0,a5,ffffffffc0200d9a <buddy_system_check+0x208>
    p3 = alloc_pages(8);
ffffffffc0200c14:	4521                	li	a0,8
ffffffffc0200c16:	5af010ef          	jal	ra,ffffffffc02029c4 <alloc_pages>
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
ffffffffc0200c44:	613010ef          	jal	ra,ffffffffc0202a56 <free_pages>
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
ffffffffc0200c66:	5f1010ef          	jal	ra,ffffffffc0202a56 <free_pages>
    test_print(p0,16);//6
    free_pages(p2, 1);
ffffffffc0200c6a:	854e                	mv	a0,s3
ffffffffc0200c6c:	4585                	li	a1,1
ffffffffc0200c6e:	5e9010ef          	jal	ra,ffffffffc0202a56 <free_pages>
    test_print(p0,16);//7
    // 回收后再分配
    p2 = alloc_pages(3);
ffffffffc0200c72:	450d                	li	a0,3
ffffffffc0200c74:	551010ef          	jal	ra,ffffffffc02029c4 <alloc_pages>
    test_print(p0,16);//8
    assert(p2 == p0);
ffffffffc0200c78:	16a41163          	bne	s0,a0,ffffffffc0200dda <buddy_system_check+0x248>
    free_pages(p2, 3);//9
ffffffffc0200c7c:	458d                	li	a1,3
ffffffffc0200c7e:	5d9010ef          	jal	ra,ffffffffc0202a56 <free_pages>
    assert((p2 + 2)->ref == 0);
ffffffffc0200c82:	08042783          	lw	a5,128(s0)
ffffffffc0200c86:	12079a63          	bnez	a5,ffffffffc0200dba <buddy_system_check+0x228>
    test_print(p0,16);//10
    //assert(nr_free_pages() == all_pages >> 1);
    p1 = alloc_pages(129);
ffffffffc0200c8a:	08100513          	li	a0,129
ffffffffc0200c8e:	537010ef          	jal	ra,ffffffffc02029c4 <alloc_pages>
    test_print(p0,16);//11
    assert(p1 == p0 + 256);
ffffffffc0200c92:	6791                	lui	a5,0x4
ffffffffc0200c94:	943e                	add	s0,s0,a5
ffffffffc0200c96:	1c851263          	bne	a0,s0,ffffffffc0200e5a <buddy_system_check+0x2c8>
    //free_pages(p1, 256);
    free_pages(p1, 129);//参考代码适配
ffffffffc0200c9a:	08100593          	li	a1,129
ffffffffc0200c9e:	5b9010ef          	jal	ra,ffffffffc0202a56 <free_pages>
    test_print(p0,16);//12
    free_pages(p3, 8);
ffffffffc0200ca2:	45a1                	li	a1,8
ffffffffc0200ca4:	854a                	mv	a0,s2
ffffffffc0200ca6:	5b1010ef          	jal	ra,ffffffffc0202a56 <free_pages>
    test_print(p0,16);//13
    cprintf("[自检程序]退出buddy_system内存管理器的启动自检程序\n");
ffffffffc0200caa:	00004517          	auipc	a0,0x4
ffffffffc0200cae:	7d650513          	addi	a0,a0,2006 # ffffffffc0205480 <commands+0x958>
ffffffffc0200cb2:	c1aff0ef          	jal	ra,ffffffffc02000cc <cprintf>
	cprintf("[自检程序]buddy_system内存管理器的工作正常\n");
ffffffffc0200cb6:	00005517          	auipc	a0,0x5
ffffffffc0200cba:	81250513          	addi	a0,a0,-2030 # ffffffffc02054c8 <commands+0x9a0>
ffffffffc0200cbe:	c0eff0ef          	jal	ra,ffffffffc02000cc <cprintf>
	cprintf("################################################################################\n");
}
ffffffffc0200cc2:	7402                	ld	s0,32(sp)
ffffffffc0200cc4:	70a2                	ld	ra,40(sp)
ffffffffc0200cc6:	64e2                	ld	s1,24(sp)
ffffffffc0200cc8:	6942                	ld	s2,16(sp)
ffffffffc0200cca:	69a2                	ld	s3,8(sp)
	cprintf("################################################################################\n");
ffffffffc0200ccc:	00004517          	auipc	a0,0x4
ffffffffc0200cd0:	56450513          	addi	a0,a0,1380 # ffffffffc0205230 <commands+0x708>
}
ffffffffc0200cd4:	6145                	addi	sp,sp,48
	cprintf("################################################################################\n");
ffffffffc0200cd6:	bf6ff06f          	j	ffffffffc02000cc <cprintf>
    assert(!PageProperty(p3) && !PageProperty(p3 + 7) && PageProperty(p3 + 8));
ffffffffc0200cda:	00004697          	auipc	a3,0x4
ffffffffc0200cde:	6e668693          	addi	a3,a3,1766 # ffffffffc02053c0 <commands+0x898>
ffffffffc0200ce2:	00004617          	auipc	a2,0x4
ffffffffc0200ce6:	61660613          	addi	a2,a2,1558 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0200cea:	13800593          	li	a1,312
ffffffffc0200cee:	00004517          	auipc	a0,0x4
ffffffffc0200cf2:	62250513          	addi	a0,a0,1570 # ffffffffc0205310 <commands+0x7e8>
ffffffffc0200cf6:	cd2ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(!PageReserved(p1) && !PageProperty(p1));
ffffffffc0200cfa:	00004697          	auipc	a3,0x4
ffffffffc0200cfe:	67e68693          	addi	a3,a3,1662 # ffffffffc0205378 <commands+0x850>
ffffffffc0200d02:	00004617          	auipc	a2,0x4
ffffffffc0200d06:	5f660613          	addi	a2,a2,1526 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0200d0a:	13000593          	li	a1,304
ffffffffc0200d0e:	00004517          	auipc	a0,0x4
ffffffffc0200d12:	60250513          	addi	a0,a0,1538 # ffffffffc0205310 <commands+0x7e8>
ffffffffc0200d16:	cb2ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(!PageReserved(p0) && !PageProperty(p0));
ffffffffc0200d1a:	00004697          	auipc	a3,0x4
ffffffffc0200d1e:	63668693          	addi	a3,a3,1590 # ffffffffc0205350 <commands+0x828>
ffffffffc0200d22:	00004617          	auipc	a2,0x4
ffffffffc0200d26:	5d660613          	addi	a2,a2,1494 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0200d2a:	12f00593          	li	a1,303
ffffffffc0200d2e:	00004517          	auipc	a0,0x4
ffffffffc0200d32:	5e250513          	addi	a0,a0,1506 # ffffffffc0205310 <commands+0x7e8>
ffffffffc0200d36:	c92ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(PageProperty(p1) && !PageProperty(p1 + 1));
ffffffffc0200d3a:	00004697          	auipc	a3,0x4
ffffffffc0200d3e:	6ce68693          	addi	a3,a3,1742 # ffffffffc0205408 <commands+0x8e0>
ffffffffc0200d42:	00004617          	auipc	a2,0x4
ffffffffc0200d46:	5b660613          	addi	a2,a2,1462 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0200d4a:	13d00593          	li	a1,317
ffffffffc0200d4e:	00004517          	auipc	a0,0x4
ffffffffc0200d52:	5c250513          	addi	a0,a0,1474 # ffffffffc0205310 <commands+0x7e8>
ffffffffc0200d56:	c72ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p1->ref == 0);
ffffffffc0200d5a:	00004697          	auipc	a3,0x4
ffffffffc0200d5e:	6de68693          	addi	a3,a3,1758 # ffffffffc0205438 <commands+0x910>
ffffffffc0200d62:	00004617          	auipc	a2,0x4
ffffffffc0200d66:	59660613          	addi	a2,a2,1430 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0200d6a:	13e00593          	li	a1,318
ffffffffc0200d6e:	00004517          	auipc	a0,0x4
ffffffffc0200d72:	5a250513          	addi	a0,a0,1442 # ffffffffc0205310 <commands+0x7e8>
ffffffffc0200d76:	c52ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p3 == p0 + 8);
ffffffffc0200d7a:	00004697          	auipc	a3,0x4
ffffffffc0200d7e:	63668693          	addi	a3,a3,1590 # ffffffffc02053b0 <commands+0x888>
ffffffffc0200d82:	00004617          	auipc	a2,0x4
ffffffffc0200d86:	57660613          	addi	a2,a2,1398 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0200d8a:	13700593          	li	a1,311
ffffffffc0200d8e:	00004517          	auipc	a0,0x4
ffffffffc0200d92:	58250513          	addi	a0,a0,1410 # ffffffffc0205310 <commands+0x7e8>
ffffffffc0200d96:	c32ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p2 == p0 + 1);
ffffffffc0200d9a:	00004697          	auipc	a3,0x4
ffffffffc0200d9e:	60668693          	addi	a3,a3,1542 # ffffffffc02053a0 <commands+0x878>
ffffffffc0200da2:	00004617          	auipc	a2,0x4
ffffffffc0200da6:	55660613          	addi	a2,a2,1366 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0200daa:	13400593          	li	a1,308
ffffffffc0200dae:	00004517          	auipc	a0,0x4
ffffffffc0200db2:	56250513          	addi	a0,a0,1378 # ffffffffc0205310 <commands+0x7e8>
ffffffffc0200db6:	c12ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p2 + 2)->ref == 0);
ffffffffc0200dba:	00004697          	auipc	a3,0x4
ffffffffc0200dbe:	69e68693          	addi	a3,a3,1694 # ffffffffc0205458 <commands+0x930>
ffffffffc0200dc2:	00004617          	auipc	a2,0x4
ffffffffc0200dc6:	53660613          	addi	a2,a2,1334 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0200dca:	14800593          	li	a1,328
ffffffffc0200dce:	00004517          	auipc	a0,0x4
ffffffffc0200dd2:	54250513          	addi	a0,a0,1346 # ffffffffc0205310 <commands+0x7e8>
ffffffffc0200dd6:	bf2ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p2 == p0);
ffffffffc0200dda:	00004697          	auipc	a3,0x4
ffffffffc0200dde:	66e68693          	addi	a3,a3,1646 # ffffffffc0205448 <commands+0x920>
ffffffffc0200de2:	00004617          	auipc	a2,0x4
ffffffffc0200de6:	51660613          	addi	a2,a2,1302 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0200dea:	14600593          	li	a1,326
ffffffffc0200dee:	00004517          	auipc	a0,0x4
ffffffffc0200df2:	52250513          	addi	a0,a0,1314 # ffffffffc0205310 <commands+0x7e8>
ffffffffc0200df6:	bd2ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p1 == p0 + 2);
ffffffffc0200dfa:	00004697          	auipc	a3,0x4
ffffffffc0200dfe:	54668693          	addi	a3,a3,1350 # ffffffffc0205340 <commands+0x818>
ffffffffc0200e02:	00004617          	auipc	a2,0x4
ffffffffc0200e06:	4f660613          	addi	a2,a2,1270 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0200e0a:	12e00593          	li	a1,302
ffffffffc0200e0e:	00004517          	auipc	a0,0x4
ffffffffc0200e12:	50250513          	addi	a0,a0,1282 # ffffffffc0205310 <commands+0x7e8>
ffffffffc0200e16:	bb2ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p0 != NULL);
ffffffffc0200e1a:	00004697          	auipc	a3,0x4
ffffffffc0200e1e:	51668693          	addi	a3,a3,1302 # ffffffffc0205330 <commands+0x808>
ffffffffc0200e22:	00004617          	auipc	a2,0x4
ffffffffc0200e26:	4d660613          	addi	a2,a2,1238 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0200e2a:	12b00593          	li	a1,299
ffffffffc0200e2e:	00004517          	auipc	a0,0x4
ffffffffc0200e32:	4e250513          	addi	a0,a0,1250 # ffffffffc0205310 <commands+0x7e8>
ffffffffc0200e36:	b92ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_pages(all_pages + 1) == NULL);
ffffffffc0200e3a:	00004697          	auipc	a3,0x4
ffffffffc0200e3e:	49668693          	addi	a3,a3,1174 # ffffffffc02052d0 <commands+0x7a8>
ffffffffc0200e42:	00004617          	auipc	a2,0x4
ffffffffc0200e46:	4b660613          	addi	a2,a2,1206 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0200e4a:	12700593          	li	a1,295
ffffffffc0200e4e:	00004517          	auipc	a0,0x4
ffffffffc0200e52:	4c250513          	addi	a0,a0,1218 # ffffffffc0205310 <commands+0x7e8>
ffffffffc0200e56:	b72ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p1 == p0 + 256);
ffffffffc0200e5a:	00004697          	auipc	a3,0x4
ffffffffc0200e5e:	61668693          	addi	a3,a3,1558 # ffffffffc0205470 <commands+0x948>
ffffffffc0200e62:	00004617          	auipc	a2,0x4
ffffffffc0200e66:	49660613          	addi	a2,a2,1174 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0200e6a:	14d00593          	li	a1,333
ffffffffc0200e6e:	00004517          	auipc	a0,0x4
ffffffffc0200e72:	4a250513          	addi	a0,a0,1186 # ffffffffc0205310 <commands+0x7e8>
ffffffffc0200e76:	b52ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

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
ffffffffc0200eac:	66068693          	addi	a3,a3,1632 # ffffffffc0205508 <commands+0x9e0>
ffffffffc0200eb0:	00004617          	auipc	a2,0x4
ffffffffc0200eb4:	44860613          	addi	a2,a2,1096 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0200eb8:	04200593          	li	a1,66
ffffffffc0200ebc:	00004517          	auipc	a0,0x4
ffffffffc0200ec0:	45450513          	addi	a0,a0,1108 # ffffffffc0205310 <commands+0x7e8>
{
ffffffffc0200ec4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200ec6:	b02ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

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
ffffffffc0200fc6:	54e68693          	addi	a3,a3,1358 # ffffffffc0205510 <commands+0x9e8>
ffffffffc0200fca:	00004617          	auipc	a2,0x4
ffffffffc0200fce:	32e60613          	addi	a2,a2,814 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0200fd2:	0d600593          	li	a1,214
ffffffffc0200fd6:	00004517          	auipc	a0,0x4
ffffffffc0200fda:	33a50513          	addi	a0,a0,826 # ffffffffc0205310 <commands+0x7e8>
ffffffffc0200fde:	9eaff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(n > 0);
ffffffffc0200fe2:	00004697          	auipc	a3,0x4
ffffffffc0200fe6:	52668693          	addi	a3,a3,1318 # ffffffffc0205508 <commands+0x9e0>
ffffffffc0200fea:	00004617          	auipc	a2,0x4
ffffffffc0200fee:	30e60613          	addi	a2,a2,782 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0200ff2:	0cf00593          	li	a1,207
ffffffffc0200ff6:	00004517          	auipc	a0,0x4
ffffffffc0200ffa:	31a50513          	addi	a0,a0,794 # ffffffffc0205310 <commands+0x7e8>
ffffffffc0200ffe:	9caff0ef          	jal	ra,ffffffffc02001c8 <__panic>

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
ffffffffc0201160:	3ac68693          	addi	a3,a3,940 # ffffffffc0205508 <commands+0x9e0>
ffffffffc0201164:	00004617          	auipc	a2,0x4
ffffffffc0201168:	19460613          	addi	a2,a2,404 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020116c:	09400593          	li	a1,148
ffffffffc0201170:	00004517          	auipc	a0,0x4
ffffffffc0201174:	1a050513          	addi	a0,a0,416 # ffffffffc0205310 <commands+0x7e8>
ffffffffc0201178:	850ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

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
ffffffffc0201278:	2c468693          	addi	a3,a3,708 # ffffffffc0205538 <commands+0xa10>
ffffffffc020127c:	00004617          	auipc	a2,0x4
ffffffffc0201280:	07c60613          	addi	a2,a2,124 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201284:	06b00593          	li	a1,107
ffffffffc0201288:	00004517          	auipc	a0,0x4
ffffffffc020128c:	08850513          	addi	a0,a0,136 # ffffffffc0205310 <commands+0x7e8>
ffffffffc0201290:	f39fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(free_tree != NULL);
ffffffffc0201294:	00004697          	auipc	a3,0x4
ffffffffc0201298:	2b468693          	addi	a3,a3,692 # ffffffffc0205548 <commands+0xa20>
ffffffffc020129c:	00004617          	auipc	a2,0x4
ffffffffc02012a0:	05c60613          	addi	a2,a2,92 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02012a4:	07900593          	li	a1,121
ffffffffc02012a8:	00004517          	auipc	a0,0x4
ffffffffc02012ac:	06850513          	addi	a0,a0,104 # ffffffffc0205310 <commands+0x7e8>
ffffffffc02012b0:	f19fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(n > 0);
ffffffffc02012b4:	00004697          	auipc	a3,0x4
ffffffffc02012b8:	25468693          	addi	a3,a3,596 # ffffffffc0205508 <commands+0x9e0>
ffffffffc02012bc:	00004617          	auipc	a2,0x4
ffffffffc02012c0:	03c60613          	addi	a2,a2,60 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02012c4:	06300593          	li	a1,99
ffffffffc02012c8:	00004517          	auipc	a0,0x4
ffffffffc02012cc:	04850513          	addi	a0,a0,72 # ffffffffc0205310 <commands+0x7e8>
ffffffffc02012d0:	ef9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02012d4 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02012d4:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02012d6:	00004697          	auipc	a3,0x4
ffffffffc02012da:	2e268693          	addi	a3,a3,738 # ffffffffc02055b8 <buddy_system_pmm_manager+0x38>
ffffffffc02012de:	00004617          	auipc	a2,0x4
ffffffffc02012e2:	01a60613          	addi	a2,a2,26 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02012e6:	07e00593          	li	a1,126
ffffffffc02012ea:	00004517          	auipc	a0,0x4
ffffffffc02012ee:	2ee50513          	addi	a0,a0,750 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02012f2:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02012f4:	ed5fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02012f8 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc02012f8:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc02012fa:	c505                	beqz	a0,ffffffffc0201322 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc02012fc:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02012fe:	c501                	beqz	a0,ffffffffc0201306 <find_vma+0xe>
ffffffffc0201300:	651c                	ld	a5,8(a0)
ffffffffc0201302:	02f5f263          	bgeu	a1,a5,ffffffffc0201326 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0201306:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0201308:	00f68d63          	beq	a3,a5,ffffffffc0201322 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc020130c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201310:	00e5e663          	bltu	a1,a4,ffffffffc020131c <find_vma+0x24>
ffffffffc0201314:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201318:	00e5ec63          	bltu	a1,a4,ffffffffc0201330 <find_vma+0x38>
ffffffffc020131c:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020131e:	fef697e3          	bne	a3,a5,ffffffffc020130c <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0201322:	4501                	li	a0,0
}
ffffffffc0201324:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201326:	691c                	ld	a5,16(a0)
ffffffffc0201328:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0201306 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc020132c:	ea88                	sd	a0,16(a3)
ffffffffc020132e:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0201330:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0201334:	ea88                	sd	a0,16(a3)
ffffffffc0201336:	8082                	ret

ffffffffc0201338 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201338:	6590                	ld	a2,8(a1)
ffffffffc020133a:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020133e:	1141                	addi	sp,sp,-16
ffffffffc0201340:	e406                	sd	ra,8(sp)
ffffffffc0201342:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201344:	01066763          	bltu	a2,a6,ffffffffc0201352 <insert_vma_struct+0x1a>
ffffffffc0201348:	a085                	j	ffffffffc02013a8 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020134a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020134e:	04e66863          	bltu	a2,a4,ffffffffc020139e <insert_vma_struct+0x66>
ffffffffc0201352:	86be                	mv	a3,a5
ffffffffc0201354:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0201356:	fef51ae3          	bne	a0,a5,ffffffffc020134a <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc020135a:	02a68463          	beq	a3,a0,ffffffffc0201382 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020135e:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201362:	fe86b883          	ld	a7,-24(a3)
ffffffffc0201366:	08e8f163          	bgeu	a7,a4,ffffffffc02013e8 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020136a:	04e66f63          	bltu	a2,a4,ffffffffc02013c8 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc020136e:	00f50a63          	beq	a0,a5,ffffffffc0201382 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0201372:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201376:	05076963          	bltu	a4,a6,ffffffffc02013c8 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc020137a:	ff07b603          	ld	a2,-16(a5)
ffffffffc020137e:	02c77363          	bgeu	a4,a2,ffffffffc02013a4 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0201382:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0201384:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0201386:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020138a:	e390                	sd	a2,0(a5)
ffffffffc020138c:	e690                	sd	a2,8(a3)
}
ffffffffc020138e:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0201390:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0201392:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0201394:	0017079b          	addiw	a5,a4,1
ffffffffc0201398:	d11c                	sw	a5,32(a0)
}
ffffffffc020139a:	0141                	addi	sp,sp,16
ffffffffc020139c:	8082                	ret
    if (le_prev != list) {
ffffffffc020139e:	fca690e3          	bne	a3,a0,ffffffffc020135e <insert_vma_struct+0x26>
ffffffffc02013a2:	bfd1                	j	ffffffffc0201376 <insert_vma_struct+0x3e>
ffffffffc02013a4:	f31ff0ef          	jal	ra,ffffffffc02012d4 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02013a8:	00004697          	auipc	a3,0x4
ffffffffc02013ac:	24068693          	addi	a3,a3,576 # ffffffffc02055e8 <buddy_system_pmm_manager+0x68>
ffffffffc02013b0:	00004617          	auipc	a2,0x4
ffffffffc02013b4:	f4860613          	addi	a2,a2,-184 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02013b8:	08500593          	li	a1,133
ffffffffc02013bc:	00004517          	auipc	a0,0x4
ffffffffc02013c0:	21c50513          	addi	a0,a0,540 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc02013c4:	e05fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02013c8:	00004697          	auipc	a3,0x4
ffffffffc02013cc:	26068693          	addi	a3,a3,608 # ffffffffc0205628 <buddy_system_pmm_manager+0xa8>
ffffffffc02013d0:	00004617          	auipc	a2,0x4
ffffffffc02013d4:	f2860613          	addi	a2,a2,-216 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02013d8:	07d00593          	li	a1,125
ffffffffc02013dc:	00004517          	auipc	a0,0x4
ffffffffc02013e0:	1fc50513          	addi	a0,a0,508 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc02013e4:	de5fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02013e8:	00004697          	auipc	a3,0x4
ffffffffc02013ec:	22068693          	addi	a3,a3,544 # ffffffffc0205608 <buddy_system_pmm_manager+0x88>
ffffffffc02013f0:	00004617          	auipc	a2,0x4
ffffffffc02013f4:	f0860613          	addi	a2,a2,-248 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02013f8:	07c00593          	li	a1,124
ffffffffc02013fc:	00004517          	auipc	a0,0x4
ffffffffc0201400:	1dc50513          	addi	a0,a0,476 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc0201404:	dc5fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201408 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0201408:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020140a:	03000513          	li	a0,48
vmm_init(void) {
ffffffffc020140e:	fc06                	sd	ra,56(sp)
ffffffffc0201410:	f822                	sd	s0,48(sp)
ffffffffc0201412:	f426                	sd	s1,40(sp)
ffffffffc0201414:	f04a                	sd	s2,32(sp)
ffffffffc0201416:	ec4e                	sd	s3,24(sp)
ffffffffc0201418:	e852                	sd	s4,16(sp)
ffffffffc020141a:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020141c:	7a5000ef          	jal	ra,ffffffffc02023c0 <kmalloc>
    if (mm != NULL) {
ffffffffc0201420:	58050e63          	beqz	a0,ffffffffc02019bc <vmm_init+0x5b4>
    elm->prev = elm->next = elm;
ffffffffc0201424:	e508                	sd	a0,8(a0)
ffffffffc0201426:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0201428:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020142c:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201430:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201434:	00014797          	auipc	a5,0x14
ffffffffc0201438:	2247a783          	lw	a5,548(a5) # ffffffffc0215658 <swap_init_ok>
ffffffffc020143c:	84aa                	mv	s1,a0
ffffffffc020143e:	e7b9                	bnez	a5,ffffffffc020148c <vmm_init+0x84>
        else mm->sm_priv = NULL;
ffffffffc0201440:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc0201444:	03200413          	li	s0,50
ffffffffc0201448:	a811                	j	ffffffffc020145c <vmm_init+0x54>
        vma->vm_start = vm_start;
ffffffffc020144a:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc020144c:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020144e:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0201452:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201454:	8526                	mv	a0,s1
ffffffffc0201456:	ee3ff0ef          	jal	ra,ffffffffc0201338 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc020145a:	cc05                	beqz	s0,ffffffffc0201492 <vmm_init+0x8a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020145c:	03000513          	li	a0,48
ffffffffc0201460:	761000ef          	jal	ra,ffffffffc02023c0 <kmalloc>
ffffffffc0201464:	85aa                	mv	a1,a0
ffffffffc0201466:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc020146a:	f165                	bnez	a0,ffffffffc020144a <vmm_init+0x42>
        assert(vma != NULL);
ffffffffc020146c:	00004697          	auipc	a3,0x4
ffffffffc0201470:	43468693          	addi	a3,a3,1076 # ffffffffc02058a0 <buddy_system_pmm_manager+0x320>
ffffffffc0201474:	00004617          	auipc	a2,0x4
ffffffffc0201478:	e8460613          	addi	a2,a2,-380 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020147c:	0c900593          	li	a1,201
ffffffffc0201480:	00004517          	auipc	a0,0x4
ffffffffc0201484:	15850513          	addi	a0,a0,344 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc0201488:	d41fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020148c:	35a010ef          	jal	ra,ffffffffc02027e6 <swap_init_mm>
ffffffffc0201490:	bf55                	j	ffffffffc0201444 <vmm_init+0x3c>
ffffffffc0201492:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201496:	1f900913          	li	s2,505
ffffffffc020149a:	a819                	j	ffffffffc02014b0 <vmm_init+0xa8>
        vma->vm_start = vm_start;
ffffffffc020149c:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc020149e:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02014a0:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02014a4:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02014a6:	8526                	mv	a0,s1
ffffffffc02014a8:	e91ff0ef          	jal	ra,ffffffffc0201338 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02014ac:	03240a63          	beq	s0,s2,ffffffffc02014e0 <vmm_init+0xd8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02014b0:	03000513          	li	a0,48
ffffffffc02014b4:	70d000ef          	jal	ra,ffffffffc02023c0 <kmalloc>
ffffffffc02014b8:	85aa                	mv	a1,a0
ffffffffc02014ba:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02014be:	fd79                	bnez	a0,ffffffffc020149c <vmm_init+0x94>
        assert(vma != NULL);
ffffffffc02014c0:	00004697          	auipc	a3,0x4
ffffffffc02014c4:	3e068693          	addi	a3,a3,992 # ffffffffc02058a0 <buddy_system_pmm_manager+0x320>
ffffffffc02014c8:	00004617          	auipc	a2,0x4
ffffffffc02014cc:	e3060613          	addi	a2,a2,-464 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02014d0:	0cf00593          	li	a1,207
ffffffffc02014d4:	00004517          	auipc	a0,0x4
ffffffffc02014d8:	10450513          	addi	a0,a0,260 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc02014dc:	cedfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return listelm->next;
ffffffffc02014e0:	649c                	ld	a5,8(s1)
ffffffffc02014e2:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02014e4:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02014e8:	30f48e63          	beq	s1,a5,ffffffffc0201804 <vmm_init+0x3fc>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02014ec:	fe87b683          	ld	a3,-24(a5)
ffffffffc02014f0:	ffe70613          	addi	a2,a4,-2
ffffffffc02014f4:	2ad61863          	bne	a2,a3,ffffffffc02017a4 <vmm_init+0x39c>
ffffffffc02014f8:	ff07b683          	ld	a3,-16(a5)
ffffffffc02014fc:	2ae69463          	bne	a3,a4,ffffffffc02017a4 <vmm_init+0x39c>
    for (i = 1; i <= step2; i ++) {
ffffffffc0201500:	0715                	addi	a4,a4,5
ffffffffc0201502:	679c                	ld	a5,8(a5)
ffffffffc0201504:	feb712e3          	bne	a4,a1,ffffffffc02014e8 <vmm_init+0xe0>
ffffffffc0201508:	4a1d                	li	s4,7
ffffffffc020150a:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020150c:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0201510:	85a2                	mv	a1,s0
ffffffffc0201512:	8526                	mv	a0,s1
ffffffffc0201514:	de5ff0ef          	jal	ra,ffffffffc02012f8 <find_vma>
ffffffffc0201518:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc020151a:	34050563          	beqz	a0,ffffffffc0201864 <vmm_init+0x45c>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020151e:	00140593          	addi	a1,s0,1
ffffffffc0201522:	8526                	mv	a0,s1
ffffffffc0201524:	dd5ff0ef          	jal	ra,ffffffffc02012f8 <find_vma>
ffffffffc0201528:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020152a:	34050d63          	beqz	a0,ffffffffc0201884 <vmm_init+0x47c>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020152e:	85d2                	mv	a1,s4
ffffffffc0201530:	8526                	mv	a0,s1
ffffffffc0201532:	dc7ff0ef          	jal	ra,ffffffffc02012f8 <find_vma>
        assert(vma3 == NULL);
ffffffffc0201536:	36051763          	bnez	a0,ffffffffc02018a4 <vmm_init+0x49c>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020153a:	00340593          	addi	a1,s0,3
ffffffffc020153e:	8526                	mv	a0,s1
ffffffffc0201540:	db9ff0ef          	jal	ra,ffffffffc02012f8 <find_vma>
        assert(vma4 == NULL);
ffffffffc0201544:	2e051063          	bnez	a0,ffffffffc0201824 <vmm_init+0x41c>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0201548:	00440593          	addi	a1,s0,4
ffffffffc020154c:	8526                	mv	a0,s1
ffffffffc020154e:	dabff0ef          	jal	ra,ffffffffc02012f8 <find_vma>
        assert(vma5 == NULL);
ffffffffc0201552:	2e051963          	bnez	a0,ffffffffc0201844 <vmm_init+0x43c>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201556:	00893783          	ld	a5,8(s2)
ffffffffc020155a:	26879563          	bne	a5,s0,ffffffffc02017c4 <vmm_init+0x3bc>
ffffffffc020155e:	01093783          	ld	a5,16(s2)
ffffffffc0201562:	27479163          	bne	a5,s4,ffffffffc02017c4 <vmm_init+0x3bc>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201566:	0089b783          	ld	a5,8(s3)
ffffffffc020156a:	26879d63          	bne	a5,s0,ffffffffc02017e4 <vmm_init+0x3dc>
ffffffffc020156e:	0109b783          	ld	a5,16(s3)
ffffffffc0201572:	27479963          	bne	a5,s4,ffffffffc02017e4 <vmm_init+0x3dc>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201576:	0415                	addi	s0,s0,5
ffffffffc0201578:	0a15                	addi	s4,s4,5
ffffffffc020157a:	f9541be3          	bne	s0,s5,ffffffffc0201510 <vmm_init+0x108>
ffffffffc020157e:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0201580:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0201582:	85a2                	mv	a1,s0
ffffffffc0201584:	8526                	mv	a0,s1
ffffffffc0201586:	d73ff0ef          	jal	ra,ffffffffc02012f8 <find_vma>
ffffffffc020158a:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc020158e:	c90d                	beqz	a0,ffffffffc02015c0 <vmm_init+0x1b8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0201590:	6914                	ld	a3,16(a0)
ffffffffc0201592:	6510                	ld	a2,8(a0)
ffffffffc0201594:	00004517          	auipc	a0,0x4
ffffffffc0201598:	1b450513          	addi	a0,a0,436 # ffffffffc0205748 <buddy_system_pmm_manager+0x1c8>
ffffffffc020159c:	b31fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02015a0:	00004697          	auipc	a3,0x4
ffffffffc02015a4:	1d068693          	addi	a3,a3,464 # ffffffffc0205770 <buddy_system_pmm_manager+0x1f0>
ffffffffc02015a8:	00004617          	auipc	a2,0x4
ffffffffc02015ac:	d5060613          	addi	a2,a2,-688 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02015b0:	0f100593          	li	a1,241
ffffffffc02015b4:	00004517          	auipc	a0,0x4
ffffffffc02015b8:	02450513          	addi	a0,a0,36 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc02015bc:	c0dfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc02015c0:	147d                	addi	s0,s0,-1
ffffffffc02015c2:	fd2410e3          	bne	s0,s2,ffffffffc0201582 <vmm_init+0x17a>
ffffffffc02015c6:	a801                	j	ffffffffc02015d6 <vmm_init+0x1ce>
    __list_del(listelm->prev, listelm->next);
ffffffffc02015c8:	6118                	ld	a4,0(a0)
ffffffffc02015ca:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc02015cc:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02015ce:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02015d0:	e398                	sd	a4,0(a5)
ffffffffc02015d2:	5f1000ef          	jal	ra,ffffffffc02023c2 <kfree>
    return listelm->next;
ffffffffc02015d6:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc02015d8:	fea498e3          	bne	s1,a0,ffffffffc02015c8 <vmm_init+0x1c0>
    kfree(mm); //kfree mm
ffffffffc02015dc:	8526                	mv	a0,s1
ffffffffc02015de:	5e5000ef          	jal	ra,ffffffffc02023c2 <kfree>
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02015e2:	00004517          	auipc	a0,0x4
ffffffffc02015e6:	1a650513          	addi	a0,a0,422 # ffffffffc0205788 <buddy_system_pmm_manager+0x208>
ffffffffc02015ea:	ae3fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02015ee:	4a8010ef          	jal	ra,ffffffffc0202a96 <nr_free_pages>
ffffffffc02015f2:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02015f4:	03000513          	li	a0,48
ffffffffc02015f8:	5c9000ef          	jal	ra,ffffffffc02023c0 <kmalloc>
ffffffffc02015fc:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02015fe:	2c050363          	beqz	a0,ffffffffc02018c4 <vmm_init+0x4bc>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201602:	00014797          	auipc	a5,0x14
ffffffffc0201606:	0567a783          	lw	a5,86(a5) # ffffffffc0215658 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc020160a:	e508                	sd	a0,8(a0)
ffffffffc020160c:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc020160e:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0201612:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201616:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020161a:	18079263          	bnez	a5,ffffffffc020179e <vmm_init+0x396>
        else mm->sm_priv = NULL;
ffffffffc020161e:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();
    assert(check_mm_struct != NULL);

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201622:	00014917          	auipc	s2,0x14
ffffffffc0201626:	04693903          	ld	s2,70(s2) # ffffffffc0215668 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc020162a:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc020162e:	00014717          	auipc	a4,0x14
ffffffffc0201632:	00873123          	sd	s0,2(a4) # ffffffffc0215630 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201636:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc020163a:	36079163          	bnez	a5,ffffffffc020199c <vmm_init+0x594>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020163e:	03000513          	li	a0,48
ffffffffc0201642:	57f000ef          	jal	ra,ffffffffc02023c0 <kmalloc>
ffffffffc0201646:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0201648:	2a050263          	beqz	a0,ffffffffc02018ec <vmm_init+0x4e4>
        vma->vm_end = vm_end;
ffffffffc020164c:	002007b7          	lui	a5,0x200
ffffffffc0201650:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc0201654:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0201656:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0201658:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc020165c:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc020165e:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc0201662:	cd7ff0ef          	jal	ra,ffffffffc0201338 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0201666:	10000593          	li	a1,256
ffffffffc020166a:	8522                	mv	a0,s0
ffffffffc020166c:	c8dff0ef          	jal	ra,ffffffffc02012f8 <find_vma>
ffffffffc0201670:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0201674:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0201678:	28a99a63          	bne	s3,a0,ffffffffc020190c <vmm_init+0x504>
        *(char *)(addr + i) = i;
ffffffffc020167c:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0201680:	0785                	addi	a5,a5,1
ffffffffc0201682:	fee79de3          	bne	a5,a4,ffffffffc020167c <vmm_init+0x274>
        sum += i;
ffffffffc0201686:	6705                	lui	a4,0x1
ffffffffc0201688:	10000793          	li	a5,256
ffffffffc020168c:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0201690:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0201694:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0201698:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc020169a:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc020169c:	fec79ce3          	bne	a5,a2,ffffffffc0201694 <vmm_init+0x28c>
    }
    assert(sum == 0);
ffffffffc02016a0:	28071663          	bnez	a4,ffffffffc020192c <vmm_init+0x524>
    return pa2page(PDE_ADDR(pde));
ffffffffc02016a4:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02016a8:	00014a97          	auipc	s5,0x14
ffffffffc02016ac:	fc8a8a93          	addi	s5,s5,-56 # ffffffffc0215670 <npage>
ffffffffc02016b0:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02016b4:	078a                	slli	a5,a5,0x2
ffffffffc02016b6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02016b8:	28c7fa63          	bgeu	a5,a2,ffffffffc020194c <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc02016bc:	00005a17          	auipc	s4,0x5
ffffffffc02016c0:	21ca3a03          	ld	s4,540(s4) # ffffffffc02068d8 <nbase>
ffffffffc02016c4:	414787b3          	sub	a5,a5,s4
ffffffffc02016c8:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc02016ca:	8799                	srai	a5,a5,0x6
ffffffffc02016cc:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc02016ce:	00c79713          	slli	a4,a5,0xc
ffffffffc02016d2:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02016d4:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02016d8:	28c77663          	bgeu	a4,a2,ffffffffc0201964 <vmm_init+0x55c>
ffffffffc02016dc:	00014997          	auipc	s3,0x14
ffffffffc02016e0:	fac9b983          	ld	s3,-84(s3) # ffffffffc0215688 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02016e4:	4581                	li	a1,0
ffffffffc02016e6:	854a                	mv	a0,s2
ffffffffc02016e8:	99b6                	add	s3,s3,a3
ffffffffc02016ea:	60c010ef          	jal	ra,ffffffffc0202cf6 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02016ee:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02016f2:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02016f6:	078a                	slli	a5,a5,0x2
ffffffffc02016f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02016fa:	24e7f963          	bgeu	a5,a4,ffffffffc020194c <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc02016fe:	00014997          	auipc	s3,0x14
ffffffffc0201702:	f7a98993          	addi	s3,s3,-134 # ffffffffc0215678 <pages>
ffffffffc0201706:	0009b503          	ld	a0,0(s3)
ffffffffc020170a:	414787b3          	sub	a5,a5,s4
ffffffffc020170e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0201710:	953e                	add	a0,a0,a5
ffffffffc0201712:	4585                	li	a1,1
ffffffffc0201714:	342010ef          	jal	ra,ffffffffc0202a56 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201718:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020171c:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201720:	078a                	slli	a5,a5,0x2
ffffffffc0201722:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201724:	22e7f463          	bgeu	a5,a4,ffffffffc020194c <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0201728:	0009b503          	ld	a0,0(s3)
ffffffffc020172c:	414787b3          	sub	a5,a5,s4
ffffffffc0201730:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201732:	4585                	li	a1,1
ffffffffc0201734:	953e                	add	a0,a0,a5
ffffffffc0201736:	320010ef          	jal	ra,ffffffffc0202a56 <free_pages>
    pgdir[0] = 0;
ffffffffc020173a:	00093023          	sd	zero,0(s2)
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() {
  asm volatile("sfence.vma");
ffffffffc020173e:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0201742:	6408                	ld	a0,8(s0)
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0201744:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201748:	00a40c63          	beq	s0,a0,ffffffffc0201760 <vmm_init+0x358>
    __list_del(listelm->prev, listelm->next);
ffffffffc020174c:	6118                	ld	a4,0(a0)
ffffffffc020174e:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0201750:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0201752:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201754:	e398                	sd	a4,0(a5)
ffffffffc0201756:	46d000ef          	jal	ra,ffffffffc02023c2 <kfree>
    return listelm->next;
ffffffffc020175a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020175c:	fea418e3          	bne	s0,a0,ffffffffc020174c <vmm_init+0x344>
    kfree(mm); //kfree mm
ffffffffc0201760:	8522                	mv	a0,s0
ffffffffc0201762:	461000ef          	jal	ra,ffffffffc02023c2 <kfree>
    mm_destroy(mm);
    check_mm_struct = NULL;
ffffffffc0201766:	00014797          	auipc	a5,0x14
ffffffffc020176a:	ec07b523          	sd	zero,-310(a5) # ffffffffc0215630 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020176e:	328010ef          	jal	ra,ffffffffc0202a96 <nr_free_pages>
ffffffffc0201772:	20a49563          	bne	s1,a0,ffffffffc020197c <vmm_init+0x574>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0201776:	00004517          	auipc	a0,0x4
ffffffffc020177a:	0f250513          	addi	a0,a0,242 # ffffffffc0205868 <buddy_system_pmm_manager+0x2e8>
ffffffffc020177e:	94ffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0201782:	7442                	ld	s0,48(sp)
ffffffffc0201784:	70e2                	ld	ra,56(sp)
ffffffffc0201786:	74a2                	ld	s1,40(sp)
ffffffffc0201788:	7902                	ld	s2,32(sp)
ffffffffc020178a:	69e2                	ld	s3,24(sp)
ffffffffc020178c:	6a42                	ld	s4,16(sp)
ffffffffc020178e:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201790:	00004517          	auipc	a0,0x4
ffffffffc0201794:	0f850513          	addi	a0,a0,248 # ffffffffc0205888 <buddy_system_pmm_manager+0x308>
}
ffffffffc0201798:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc020179a:	933fe06f          	j	ffffffffc02000cc <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020179e:	048010ef          	jal	ra,ffffffffc02027e6 <swap_init_mm>
ffffffffc02017a2:	b541                	j	ffffffffc0201622 <vmm_init+0x21a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02017a4:	00004697          	auipc	a3,0x4
ffffffffc02017a8:	ebc68693          	addi	a3,a3,-324 # ffffffffc0205660 <buddy_system_pmm_manager+0xe0>
ffffffffc02017ac:	00004617          	auipc	a2,0x4
ffffffffc02017b0:	b4c60613          	addi	a2,a2,-1204 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02017b4:	0d800593          	li	a1,216
ffffffffc02017b8:	00004517          	auipc	a0,0x4
ffffffffc02017bc:	e2050513          	addi	a0,a0,-480 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc02017c0:	a09fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02017c4:	00004697          	auipc	a3,0x4
ffffffffc02017c8:	f2468693          	addi	a3,a3,-220 # ffffffffc02056e8 <buddy_system_pmm_manager+0x168>
ffffffffc02017cc:	00004617          	auipc	a2,0x4
ffffffffc02017d0:	b2c60613          	addi	a2,a2,-1236 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02017d4:	0e800593          	li	a1,232
ffffffffc02017d8:	00004517          	auipc	a0,0x4
ffffffffc02017dc:	e0050513          	addi	a0,a0,-512 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc02017e0:	9e9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02017e4:	00004697          	auipc	a3,0x4
ffffffffc02017e8:	f3468693          	addi	a3,a3,-204 # ffffffffc0205718 <buddy_system_pmm_manager+0x198>
ffffffffc02017ec:	00004617          	auipc	a2,0x4
ffffffffc02017f0:	b0c60613          	addi	a2,a2,-1268 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02017f4:	0e900593          	li	a1,233
ffffffffc02017f8:	00004517          	auipc	a0,0x4
ffffffffc02017fc:	de050513          	addi	a0,a0,-544 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc0201800:	9c9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201804:	00004697          	auipc	a3,0x4
ffffffffc0201808:	e4468693          	addi	a3,a3,-444 # ffffffffc0205648 <buddy_system_pmm_manager+0xc8>
ffffffffc020180c:	00004617          	auipc	a2,0x4
ffffffffc0201810:	aec60613          	addi	a2,a2,-1300 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201814:	0d600593          	li	a1,214
ffffffffc0201818:	00004517          	auipc	a0,0x4
ffffffffc020181c:	dc050513          	addi	a0,a0,-576 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc0201820:	9a9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma4 == NULL);
ffffffffc0201824:	00004697          	auipc	a3,0x4
ffffffffc0201828:	ea468693          	addi	a3,a3,-348 # ffffffffc02056c8 <buddy_system_pmm_manager+0x148>
ffffffffc020182c:	00004617          	auipc	a2,0x4
ffffffffc0201830:	acc60613          	addi	a2,a2,-1332 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201834:	0e400593          	li	a1,228
ffffffffc0201838:	00004517          	auipc	a0,0x4
ffffffffc020183c:	da050513          	addi	a0,a0,-608 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc0201840:	989fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma5 == NULL);
ffffffffc0201844:	00004697          	auipc	a3,0x4
ffffffffc0201848:	e9468693          	addi	a3,a3,-364 # ffffffffc02056d8 <buddy_system_pmm_manager+0x158>
ffffffffc020184c:	00004617          	auipc	a2,0x4
ffffffffc0201850:	aac60613          	addi	a2,a2,-1364 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201854:	0e600593          	li	a1,230
ffffffffc0201858:	00004517          	auipc	a0,0x4
ffffffffc020185c:	d8050513          	addi	a0,a0,-640 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc0201860:	969fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma1 != NULL);
ffffffffc0201864:	00004697          	auipc	a3,0x4
ffffffffc0201868:	e3468693          	addi	a3,a3,-460 # ffffffffc0205698 <buddy_system_pmm_manager+0x118>
ffffffffc020186c:	00004617          	auipc	a2,0x4
ffffffffc0201870:	a8c60613          	addi	a2,a2,-1396 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201874:	0de00593          	li	a1,222
ffffffffc0201878:	00004517          	auipc	a0,0x4
ffffffffc020187c:	d6050513          	addi	a0,a0,-672 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc0201880:	949fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma2 != NULL);
ffffffffc0201884:	00004697          	auipc	a3,0x4
ffffffffc0201888:	e2468693          	addi	a3,a3,-476 # ffffffffc02056a8 <buddy_system_pmm_manager+0x128>
ffffffffc020188c:	00004617          	auipc	a2,0x4
ffffffffc0201890:	a6c60613          	addi	a2,a2,-1428 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201894:	0e000593          	li	a1,224
ffffffffc0201898:	00004517          	auipc	a0,0x4
ffffffffc020189c:	d4050513          	addi	a0,a0,-704 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc02018a0:	929fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma3 == NULL);
ffffffffc02018a4:	00004697          	auipc	a3,0x4
ffffffffc02018a8:	e1468693          	addi	a3,a3,-492 # ffffffffc02056b8 <buddy_system_pmm_manager+0x138>
ffffffffc02018ac:	00004617          	auipc	a2,0x4
ffffffffc02018b0:	a4c60613          	addi	a2,a2,-1460 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02018b4:	0e200593          	li	a1,226
ffffffffc02018b8:	00004517          	auipc	a0,0x4
ffffffffc02018bc:	d2050513          	addi	a0,a0,-736 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc02018c0:	909fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02018c4:	00004697          	auipc	a3,0x4
ffffffffc02018c8:	fec68693          	addi	a3,a3,-20 # ffffffffc02058b0 <buddy_system_pmm_manager+0x330>
ffffffffc02018cc:	00004617          	auipc	a2,0x4
ffffffffc02018d0:	a2c60613          	addi	a2,a2,-1492 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02018d4:	10100593          	li	a1,257
ffffffffc02018d8:	00004517          	auipc	a0,0x4
ffffffffc02018dc:	d0050513          	addi	a0,a0,-768 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
    check_mm_struct = mm_create();
ffffffffc02018e0:	00014797          	auipc	a5,0x14
ffffffffc02018e4:	d407b823          	sd	zero,-688(a5) # ffffffffc0215630 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc02018e8:	8e1fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(vma != NULL);
ffffffffc02018ec:	00004697          	auipc	a3,0x4
ffffffffc02018f0:	fb468693          	addi	a3,a3,-76 # ffffffffc02058a0 <buddy_system_pmm_manager+0x320>
ffffffffc02018f4:	00004617          	auipc	a2,0x4
ffffffffc02018f8:	a0460613          	addi	a2,a2,-1532 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02018fc:	10800593          	li	a1,264
ffffffffc0201900:	00004517          	auipc	a0,0x4
ffffffffc0201904:	cd850513          	addi	a0,a0,-808 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc0201908:	8c1fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc020190c:	00004697          	auipc	a3,0x4
ffffffffc0201910:	eac68693          	addi	a3,a3,-340 # ffffffffc02057b8 <buddy_system_pmm_manager+0x238>
ffffffffc0201914:	00004617          	auipc	a2,0x4
ffffffffc0201918:	9e460613          	addi	a2,a2,-1564 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020191c:	10d00593          	li	a1,269
ffffffffc0201920:	00004517          	auipc	a0,0x4
ffffffffc0201924:	cb850513          	addi	a0,a0,-840 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc0201928:	8a1fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(sum == 0);
ffffffffc020192c:	00004697          	auipc	a3,0x4
ffffffffc0201930:	eac68693          	addi	a3,a3,-340 # ffffffffc02057d8 <buddy_system_pmm_manager+0x258>
ffffffffc0201934:	00004617          	auipc	a2,0x4
ffffffffc0201938:	9c460613          	addi	a2,a2,-1596 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020193c:	11700593          	li	a1,279
ffffffffc0201940:	00004517          	auipc	a0,0x4
ffffffffc0201944:	c9850513          	addi	a0,a0,-872 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc0201948:	881fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020194c:	00004617          	auipc	a2,0x4
ffffffffc0201950:	e9c60613          	addi	a2,a2,-356 # ffffffffc02057e8 <buddy_system_pmm_manager+0x268>
ffffffffc0201954:	06200593          	li	a1,98
ffffffffc0201958:	00004517          	auipc	a0,0x4
ffffffffc020195c:	eb050513          	addi	a0,a0,-336 # ffffffffc0205808 <buddy_system_pmm_manager+0x288>
ffffffffc0201960:	869fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201964:	00004617          	auipc	a2,0x4
ffffffffc0201968:	eb460613          	addi	a2,a2,-332 # ffffffffc0205818 <buddy_system_pmm_manager+0x298>
ffffffffc020196c:	06900593          	li	a1,105
ffffffffc0201970:	00004517          	auipc	a0,0x4
ffffffffc0201974:	e9850513          	addi	a0,a0,-360 # ffffffffc0205808 <buddy_system_pmm_manager+0x288>
ffffffffc0201978:	851fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020197c:	00004697          	auipc	a3,0x4
ffffffffc0201980:	ec468693          	addi	a3,a3,-316 # ffffffffc0205840 <buddy_system_pmm_manager+0x2c0>
ffffffffc0201984:	00004617          	auipc	a2,0x4
ffffffffc0201988:	97460613          	addi	a2,a2,-1676 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020198c:	12400593          	li	a1,292
ffffffffc0201990:	00004517          	auipc	a0,0x4
ffffffffc0201994:	c4850513          	addi	a0,a0,-952 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc0201998:	831fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgdir[0] == 0);
ffffffffc020199c:	00004697          	auipc	a3,0x4
ffffffffc02019a0:	e0c68693          	addi	a3,a3,-500 # ffffffffc02057a8 <buddy_system_pmm_manager+0x228>
ffffffffc02019a4:	00004617          	auipc	a2,0x4
ffffffffc02019a8:	95460613          	addi	a2,a2,-1708 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02019ac:	10500593          	li	a1,261
ffffffffc02019b0:	00004517          	auipc	a0,0x4
ffffffffc02019b4:	c2850513          	addi	a0,a0,-984 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc02019b8:	811fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(mm != NULL);
ffffffffc02019bc:	00004697          	auipc	a3,0x4
ffffffffc02019c0:	f0c68693          	addi	a3,a3,-244 # ffffffffc02058c8 <buddy_system_pmm_manager+0x348>
ffffffffc02019c4:	00004617          	auipc	a2,0x4
ffffffffc02019c8:	93460613          	addi	a2,a2,-1740 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02019cc:	0c200593          	li	a1,194
ffffffffc02019d0:	00004517          	auipc	a0,0x4
ffffffffc02019d4:	c0850513          	addi	a0,a0,-1016 # ffffffffc02055d8 <buddy_system_pmm_manager+0x58>
ffffffffc02019d8:	ff0fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02019dc <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc02019dc:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02019de:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc02019e0:	f022                	sd	s0,32(sp)
ffffffffc02019e2:	ec26                	sd	s1,24(sp)
ffffffffc02019e4:	f406                	sd	ra,40(sp)
ffffffffc02019e6:	e84a                	sd	s2,16(sp)
ffffffffc02019e8:	8432                	mv	s0,a2
ffffffffc02019ea:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02019ec:	90dff0ef          	jal	ra,ffffffffc02012f8 <find_vma>

    pgfault_num++;
ffffffffc02019f0:	00014797          	auipc	a5,0x14
ffffffffc02019f4:	c487a783          	lw	a5,-952(a5) # ffffffffc0215638 <pgfault_num>
ffffffffc02019f8:	2785                	addiw	a5,a5,1
ffffffffc02019fa:	00014717          	auipc	a4,0x14
ffffffffc02019fe:	c2f72f23          	sw	a5,-962(a4) # ffffffffc0215638 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201a02:	c541                	beqz	a0,ffffffffc0201a8a <do_pgfault+0xae>
ffffffffc0201a04:	651c                	ld	a5,8(a0)
ffffffffc0201a06:	08f46263          	bltu	s0,a5,ffffffffc0201a8a <do_pgfault+0xae>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201a0a:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0201a0c:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201a0e:	8b89                	andi	a5,a5,2
ffffffffc0201a10:	ebb9                	bnez	a5,ffffffffc0201a66 <do_pgfault+0x8a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201a12:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201a14:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201a16:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201a18:	4605                	li	a2,1
ffffffffc0201a1a:	85a2                	mv	a1,s0
ffffffffc0201a1c:	0b4010ef          	jal	ra,ffffffffc0202ad0 <get_pte>
ffffffffc0201a20:	c551                	beqz	a0,ffffffffc0201aac <do_pgfault+0xd0>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0201a22:	610c                	ld	a1,0(a0)
ffffffffc0201a24:	c1b9                	beqz	a1,ffffffffc0201a6a <do_pgfault+0x8e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) 
ffffffffc0201a26:	00014797          	auipc	a5,0x14
ffffffffc0201a2a:	c327a783          	lw	a5,-974(a5) # ffffffffc0215658 <swap_init_ok>
ffffffffc0201a2e:	c7bd                	beqz	a5,ffffffffc0201a9c <do_pgfault+0xc0>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）根据mm和addr，尝试将右侧磁盘页面的内容放入页面管理的内存中。
            //(2) 根据mm、addr和page，设置物理addr<--->虚拟(logical)addr的映射
            //(3) 使页面可交换。
            swap_in(mm, addr, &page);
ffffffffc0201a30:	85a2                	mv	a1,s0
ffffffffc0201a32:	0030                	addi	a2,sp,8
ffffffffc0201a34:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0201a36:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0201a38:	6db000ef          	jal	ra,ffffffffc0202912 <swap_in>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc0201a3c:	65a2                	ld	a1,8(sp)
ffffffffc0201a3e:	6c88                	ld	a0,24(s1)
ffffffffc0201a40:	86ca                	mv	a3,s2
ffffffffc0201a42:	8622                	mv	a2,s0
ffffffffc0201a44:	34e010ef          	jal	ra,ffffffffc0202d92 <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc0201a48:	6622                	ld	a2,8(sp)
ffffffffc0201a4a:	4685                	li	a3,1
ffffffffc0201a4c:	85a2                	mv	a1,s0
ffffffffc0201a4e:	8526                	mv	a0,s1
ffffffffc0201a50:	5a3000ef          	jal	ra,ffffffffc02027f2 <swap_map_swappable>
            
            page->pra_vaddr = addr;  //必须等待前几条设置好权限才能写这行
ffffffffc0201a54:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0201a56:	4501                	li	a0,0
            page->pra_vaddr = addr;  //必须等待前几条设置好权限才能写这行
ffffffffc0201a58:	ff80                	sd	s0,56(a5)
failed:
    return ret;
ffffffffc0201a5a:	70a2                	ld	ra,40(sp)
ffffffffc0201a5c:	7402                	ld	s0,32(sp)
ffffffffc0201a5e:	64e2                	ld	s1,24(sp)
ffffffffc0201a60:	6942                	ld	s2,16(sp)
ffffffffc0201a62:	6145                	addi	sp,sp,48
ffffffffc0201a64:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0201a66:	495d                	li	s2,23
ffffffffc0201a68:	b76d                	j	ffffffffc0201a12 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201a6a:	6c88                	ld	a0,24(s1)
ffffffffc0201a6c:	864a                	mv	a2,s2
ffffffffc0201a6e:	85a2                	mv	a1,s0
ffffffffc0201a70:	7d1010ef          	jal	ra,ffffffffc0203a40 <pgdir_alloc_page>
ffffffffc0201a74:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0201a76:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201a78:	f3ed                	bnez	a5,ffffffffc0201a5a <do_pgfault+0x7e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0201a7a:	00004517          	auipc	a0,0x4
ffffffffc0201a7e:	eae50513          	addi	a0,a0,-338 # ffffffffc0205928 <buddy_system_pmm_manager+0x3a8>
ffffffffc0201a82:	e4afe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201a86:	5571                	li	a0,-4
            goto failed;
ffffffffc0201a88:	bfc9                	j	ffffffffc0201a5a <do_pgfault+0x7e>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0201a8a:	85a2                	mv	a1,s0
ffffffffc0201a8c:	00004517          	auipc	a0,0x4
ffffffffc0201a90:	e4c50513          	addi	a0,a0,-436 # ffffffffc02058d8 <buddy_system_pmm_manager+0x358>
ffffffffc0201a94:	e38fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = -E_INVAL;
ffffffffc0201a98:	5575                	li	a0,-3
        goto failed;
ffffffffc0201a9a:	b7c1                	j	ffffffffc0201a5a <do_pgfault+0x7e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0201a9c:	00004517          	auipc	a0,0x4
ffffffffc0201aa0:	eb450513          	addi	a0,a0,-332 # ffffffffc0205950 <buddy_system_pmm_manager+0x3d0>
ffffffffc0201aa4:	e28fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201aa8:	5571                	li	a0,-4
            goto failed;
ffffffffc0201aaa:	bf45                	j	ffffffffc0201a5a <do_pgfault+0x7e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0201aac:	00004517          	auipc	a0,0x4
ffffffffc0201ab0:	e5c50513          	addi	a0,a0,-420 # ffffffffc0205908 <buddy_system_pmm_manager+0x388>
ffffffffc0201ab4:	e18fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201ab8:	5571                	li	a0,-4
        goto failed;
ffffffffc0201aba:	b745                	j	ffffffffc0201a5a <do_pgfault+0x7e>

ffffffffc0201abc <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0201abc:	00010797          	auipc	a5,0x10
ffffffffc0201ac0:	9ac78793          	addi	a5,a5,-1620 # ffffffffc0211468 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0201ac4:	f51c                	sd	a5,40(a0)
ffffffffc0201ac6:	e79c                	sd	a5,8(a5)
ffffffffc0201ac8:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0201aca:	4501                	li	a0,0
ffffffffc0201acc:	8082                	ret

ffffffffc0201ace <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0201ace:	4501                	li	a0,0
ffffffffc0201ad0:	8082                	ret

ffffffffc0201ad2 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0201ad2:	4501                	li	a0,0
ffffffffc0201ad4:	8082                	ret

ffffffffc0201ad6 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0201ad6:	4501                	li	a0,0
ffffffffc0201ad8:	8082                	ret

ffffffffc0201ada <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0201ada:	711d                	addi	sp,sp,-96
ffffffffc0201adc:	fc4e                	sd	s3,56(sp)
ffffffffc0201ade:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201ae0:	00004517          	auipc	a0,0x4
ffffffffc0201ae4:	e9850513          	addi	a0,a0,-360 # ffffffffc0205978 <buddy_system_pmm_manager+0x3f8>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201ae8:	698d                	lui	s3,0x3
ffffffffc0201aea:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0201aec:	e0ca                	sd	s2,64(sp)
ffffffffc0201aee:	ec86                	sd	ra,88(sp)
ffffffffc0201af0:	e8a2                	sd	s0,80(sp)
ffffffffc0201af2:	e4a6                	sd	s1,72(sp)
ffffffffc0201af4:	f456                	sd	s5,40(sp)
ffffffffc0201af6:	f05a                	sd	s6,32(sp)
ffffffffc0201af8:	ec5e                	sd	s7,24(sp)
ffffffffc0201afa:	e862                	sd	s8,16(sp)
ffffffffc0201afc:	e466                	sd	s9,8(sp)
ffffffffc0201afe:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201b00:	dccfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201b04:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0201b08:	00014917          	auipc	s2,0x14
ffffffffc0201b0c:	b3092903          	lw	s2,-1232(s2) # ffffffffc0215638 <pgfault_num>
ffffffffc0201b10:	4791                	li	a5,4
ffffffffc0201b12:	14f91e63          	bne	s2,a5,ffffffffc0201c6e <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201b16:	00004517          	auipc	a0,0x4
ffffffffc0201b1a:	eb250513          	addi	a0,a0,-334 # ffffffffc02059c8 <buddy_system_pmm_manager+0x448>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201b1e:	6a85                	lui	s5,0x1
ffffffffc0201b20:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201b22:	daafe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0201b26:	00014417          	auipc	s0,0x14
ffffffffc0201b2a:	b1240413          	addi	s0,s0,-1262 # ffffffffc0215638 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201b2e:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0201b32:	4004                	lw	s1,0(s0)
ffffffffc0201b34:	2481                	sext.w	s1,s1
ffffffffc0201b36:	2b249c63          	bne	s1,s2,ffffffffc0201dee <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201b3a:	00004517          	auipc	a0,0x4
ffffffffc0201b3e:	eb650513          	addi	a0,a0,-330 # ffffffffc02059f0 <buddy_system_pmm_manager+0x470>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201b42:	6b91                	lui	s7,0x4
ffffffffc0201b44:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201b46:	d86fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201b4a:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0201b4e:	00042903          	lw	s2,0(s0)
ffffffffc0201b52:	2901                	sext.w	s2,s2
ffffffffc0201b54:	26991d63          	bne	s2,s1,ffffffffc0201dce <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201b58:	00004517          	auipc	a0,0x4
ffffffffc0201b5c:	ec050513          	addi	a0,a0,-320 # ffffffffc0205a18 <buddy_system_pmm_manager+0x498>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201b60:	6c89                	lui	s9,0x2
ffffffffc0201b62:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201b64:	d68fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201b68:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0201b6c:	401c                	lw	a5,0(s0)
ffffffffc0201b6e:	2781                	sext.w	a5,a5
ffffffffc0201b70:	23279f63          	bne	a5,s2,ffffffffc0201dae <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201b74:	00004517          	auipc	a0,0x4
ffffffffc0201b78:	ecc50513          	addi	a0,a0,-308 # ffffffffc0205a40 <buddy_system_pmm_manager+0x4c0>
ffffffffc0201b7c:	d50fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201b80:	6795                	lui	a5,0x5
ffffffffc0201b82:	4739                	li	a4,14
ffffffffc0201b84:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0201b88:	4004                	lw	s1,0(s0)
ffffffffc0201b8a:	4795                	li	a5,5
ffffffffc0201b8c:	2481                	sext.w	s1,s1
ffffffffc0201b8e:	20f49063          	bne	s1,a5,ffffffffc0201d8e <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201b92:	00004517          	auipc	a0,0x4
ffffffffc0201b96:	e8650513          	addi	a0,a0,-378 # ffffffffc0205a18 <buddy_system_pmm_manager+0x498>
ffffffffc0201b9a:	d32fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201b9e:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0201ba2:	401c                	lw	a5,0(s0)
ffffffffc0201ba4:	2781                	sext.w	a5,a5
ffffffffc0201ba6:	1c979463          	bne	a5,s1,ffffffffc0201d6e <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201baa:	00004517          	auipc	a0,0x4
ffffffffc0201bae:	e1e50513          	addi	a0,a0,-482 # ffffffffc02059c8 <buddy_system_pmm_manager+0x448>
ffffffffc0201bb2:	d1afe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201bb6:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0201bba:	401c                	lw	a5,0(s0)
ffffffffc0201bbc:	4719                	li	a4,6
ffffffffc0201bbe:	2781                	sext.w	a5,a5
ffffffffc0201bc0:	18e79763          	bne	a5,a4,ffffffffc0201d4e <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201bc4:	00004517          	auipc	a0,0x4
ffffffffc0201bc8:	e5450513          	addi	a0,a0,-428 # ffffffffc0205a18 <buddy_system_pmm_manager+0x498>
ffffffffc0201bcc:	d00fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201bd0:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0201bd4:	401c                	lw	a5,0(s0)
ffffffffc0201bd6:	471d                	li	a4,7
ffffffffc0201bd8:	2781                	sext.w	a5,a5
ffffffffc0201bda:	14e79a63          	bne	a5,a4,ffffffffc0201d2e <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201bde:	00004517          	auipc	a0,0x4
ffffffffc0201be2:	d9a50513          	addi	a0,a0,-614 # ffffffffc0205978 <buddy_system_pmm_manager+0x3f8>
ffffffffc0201be6:	ce6fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201bea:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0201bee:	401c                	lw	a5,0(s0)
ffffffffc0201bf0:	4721                	li	a4,8
ffffffffc0201bf2:	2781                	sext.w	a5,a5
ffffffffc0201bf4:	10e79d63          	bne	a5,a4,ffffffffc0201d0e <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201bf8:	00004517          	auipc	a0,0x4
ffffffffc0201bfc:	df850513          	addi	a0,a0,-520 # ffffffffc02059f0 <buddy_system_pmm_manager+0x470>
ffffffffc0201c00:	cccfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201c04:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0201c08:	401c                	lw	a5,0(s0)
ffffffffc0201c0a:	4725                	li	a4,9
ffffffffc0201c0c:	2781                	sext.w	a5,a5
ffffffffc0201c0e:	0ee79063          	bne	a5,a4,ffffffffc0201cee <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201c12:	00004517          	auipc	a0,0x4
ffffffffc0201c16:	e2e50513          	addi	a0,a0,-466 # ffffffffc0205a40 <buddy_system_pmm_manager+0x4c0>
ffffffffc0201c1a:	cb2fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201c1e:	6795                	lui	a5,0x5
ffffffffc0201c20:	4739                	li	a4,14
ffffffffc0201c22:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0201c26:	4004                	lw	s1,0(s0)
ffffffffc0201c28:	47a9                	li	a5,10
ffffffffc0201c2a:	2481                	sext.w	s1,s1
ffffffffc0201c2c:	0af49163          	bne	s1,a5,ffffffffc0201cce <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201c30:	00004517          	auipc	a0,0x4
ffffffffc0201c34:	d9850513          	addi	a0,a0,-616 # ffffffffc02059c8 <buddy_system_pmm_manager+0x448>
ffffffffc0201c38:	c94fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201c3c:	6785                	lui	a5,0x1
ffffffffc0201c3e:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201c42:	06979663          	bne	a5,s1,ffffffffc0201cae <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0201c46:	401c                	lw	a5,0(s0)
ffffffffc0201c48:	472d                	li	a4,11
ffffffffc0201c4a:	2781                	sext.w	a5,a5
ffffffffc0201c4c:	04e79163          	bne	a5,a4,ffffffffc0201c8e <_fifo_check_swap+0x1b4>
}
ffffffffc0201c50:	60e6                	ld	ra,88(sp)
ffffffffc0201c52:	6446                	ld	s0,80(sp)
ffffffffc0201c54:	64a6                	ld	s1,72(sp)
ffffffffc0201c56:	6906                	ld	s2,64(sp)
ffffffffc0201c58:	79e2                	ld	s3,56(sp)
ffffffffc0201c5a:	7a42                	ld	s4,48(sp)
ffffffffc0201c5c:	7aa2                	ld	s5,40(sp)
ffffffffc0201c5e:	7b02                	ld	s6,32(sp)
ffffffffc0201c60:	6be2                	ld	s7,24(sp)
ffffffffc0201c62:	6c42                	ld	s8,16(sp)
ffffffffc0201c64:	6ca2                	ld	s9,8(sp)
ffffffffc0201c66:	6d02                	ld	s10,0(sp)
ffffffffc0201c68:	4501                	li	a0,0
ffffffffc0201c6a:	6125                	addi	sp,sp,96
ffffffffc0201c6c:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0201c6e:	00004697          	auipc	a3,0x4
ffffffffc0201c72:	d3268693          	addi	a3,a3,-718 # ffffffffc02059a0 <buddy_system_pmm_manager+0x420>
ffffffffc0201c76:	00003617          	auipc	a2,0x3
ffffffffc0201c7a:	68260613          	addi	a2,a2,1666 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201c7e:	05100593          	li	a1,81
ffffffffc0201c82:	00004517          	auipc	a0,0x4
ffffffffc0201c86:	d2e50513          	addi	a0,a0,-722 # ffffffffc02059b0 <buddy_system_pmm_manager+0x430>
ffffffffc0201c8a:	d3efe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==11);
ffffffffc0201c8e:	00004697          	auipc	a3,0x4
ffffffffc0201c92:	e6268693          	addi	a3,a3,-414 # ffffffffc0205af0 <buddy_system_pmm_manager+0x570>
ffffffffc0201c96:	00003617          	auipc	a2,0x3
ffffffffc0201c9a:	66260613          	addi	a2,a2,1634 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201c9e:	07300593          	li	a1,115
ffffffffc0201ca2:	00004517          	auipc	a0,0x4
ffffffffc0201ca6:	d0e50513          	addi	a0,a0,-754 # ffffffffc02059b0 <buddy_system_pmm_manager+0x430>
ffffffffc0201caa:	d1efe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201cae:	00004697          	auipc	a3,0x4
ffffffffc0201cb2:	e1a68693          	addi	a3,a3,-486 # ffffffffc0205ac8 <buddy_system_pmm_manager+0x548>
ffffffffc0201cb6:	00003617          	auipc	a2,0x3
ffffffffc0201cba:	64260613          	addi	a2,a2,1602 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201cbe:	07100593          	li	a1,113
ffffffffc0201cc2:	00004517          	auipc	a0,0x4
ffffffffc0201cc6:	cee50513          	addi	a0,a0,-786 # ffffffffc02059b0 <buddy_system_pmm_manager+0x430>
ffffffffc0201cca:	cfefe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==10);
ffffffffc0201cce:	00004697          	auipc	a3,0x4
ffffffffc0201cd2:	dea68693          	addi	a3,a3,-534 # ffffffffc0205ab8 <buddy_system_pmm_manager+0x538>
ffffffffc0201cd6:	00003617          	auipc	a2,0x3
ffffffffc0201cda:	62260613          	addi	a2,a2,1570 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201cde:	06f00593          	li	a1,111
ffffffffc0201ce2:	00004517          	auipc	a0,0x4
ffffffffc0201ce6:	cce50513          	addi	a0,a0,-818 # ffffffffc02059b0 <buddy_system_pmm_manager+0x430>
ffffffffc0201cea:	cdefe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==9);
ffffffffc0201cee:	00004697          	auipc	a3,0x4
ffffffffc0201cf2:	dba68693          	addi	a3,a3,-582 # ffffffffc0205aa8 <buddy_system_pmm_manager+0x528>
ffffffffc0201cf6:	00003617          	auipc	a2,0x3
ffffffffc0201cfa:	60260613          	addi	a2,a2,1538 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201cfe:	06c00593          	li	a1,108
ffffffffc0201d02:	00004517          	auipc	a0,0x4
ffffffffc0201d06:	cae50513          	addi	a0,a0,-850 # ffffffffc02059b0 <buddy_system_pmm_manager+0x430>
ffffffffc0201d0a:	cbefe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==8);
ffffffffc0201d0e:	00004697          	auipc	a3,0x4
ffffffffc0201d12:	d8a68693          	addi	a3,a3,-630 # ffffffffc0205a98 <buddy_system_pmm_manager+0x518>
ffffffffc0201d16:	00003617          	auipc	a2,0x3
ffffffffc0201d1a:	5e260613          	addi	a2,a2,1506 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201d1e:	06900593          	li	a1,105
ffffffffc0201d22:	00004517          	auipc	a0,0x4
ffffffffc0201d26:	c8e50513          	addi	a0,a0,-882 # ffffffffc02059b0 <buddy_system_pmm_manager+0x430>
ffffffffc0201d2a:	c9efe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==7);
ffffffffc0201d2e:	00004697          	auipc	a3,0x4
ffffffffc0201d32:	d5a68693          	addi	a3,a3,-678 # ffffffffc0205a88 <buddy_system_pmm_manager+0x508>
ffffffffc0201d36:	00003617          	auipc	a2,0x3
ffffffffc0201d3a:	5c260613          	addi	a2,a2,1474 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201d3e:	06600593          	li	a1,102
ffffffffc0201d42:	00004517          	auipc	a0,0x4
ffffffffc0201d46:	c6e50513          	addi	a0,a0,-914 # ffffffffc02059b0 <buddy_system_pmm_manager+0x430>
ffffffffc0201d4a:	c7efe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==6);
ffffffffc0201d4e:	00004697          	auipc	a3,0x4
ffffffffc0201d52:	d2a68693          	addi	a3,a3,-726 # ffffffffc0205a78 <buddy_system_pmm_manager+0x4f8>
ffffffffc0201d56:	00003617          	auipc	a2,0x3
ffffffffc0201d5a:	5a260613          	addi	a2,a2,1442 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201d5e:	06300593          	li	a1,99
ffffffffc0201d62:	00004517          	auipc	a0,0x4
ffffffffc0201d66:	c4e50513          	addi	a0,a0,-946 # ffffffffc02059b0 <buddy_system_pmm_manager+0x430>
ffffffffc0201d6a:	c5efe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==5);
ffffffffc0201d6e:	00004697          	auipc	a3,0x4
ffffffffc0201d72:	cfa68693          	addi	a3,a3,-774 # ffffffffc0205a68 <buddy_system_pmm_manager+0x4e8>
ffffffffc0201d76:	00003617          	auipc	a2,0x3
ffffffffc0201d7a:	58260613          	addi	a2,a2,1410 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201d7e:	06000593          	li	a1,96
ffffffffc0201d82:	00004517          	auipc	a0,0x4
ffffffffc0201d86:	c2e50513          	addi	a0,a0,-978 # ffffffffc02059b0 <buddy_system_pmm_manager+0x430>
ffffffffc0201d8a:	c3efe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==5);
ffffffffc0201d8e:	00004697          	auipc	a3,0x4
ffffffffc0201d92:	cda68693          	addi	a3,a3,-806 # ffffffffc0205a68 <buddy_system_pmm_manager+0x4e8>
ffffffffc0201d96:	00003617          	auipc	a2,0x3
ffffffffc0201d9a:	56260613          	addi	a2,a2,1378 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201d9e:	05d00593          	li	a1,93
ffffffffc0201da2:	00004517          	auipc	a0,0x4
ffffffffc0201da6:	c0e50513          	addi	a0,a0,-1010 # ffffffffc02059b0 <buddy_system_pmm_manager+0x430>
ffffffffc0201daa:	c1efe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==4);
ffffffffc0201dae:	00004697          	auipc	a3,0x4
ffffffffc0201db2:	bf268693          	addi	a3,a3,-1038 # ffffffffc02059a0 <buddy_system_pmm_manager+0x420>
ffffffffc0201db6:	00003617          	auipc	a2,0x3
ffffffffc0201dba:	54260613          	addi	a2,a2,1346 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201dbe:	05a00593          	li	a1,90
ffffffffc0201dc2:	00004517          	auipc	a0,0x4
ffffffffc0201dc6:	bee50513          	addi	a0,a0,-1042 # ffffffffc02059b0 <buddy_system_pmm_manager+0x430>
ffffffffc0201dca:	bfefe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==4);
ffffffffc0201dce:	00004697          	auipc	a3,0x4
ffffffffc0201dd2:	bd268693          	addi	a3,a3,-1070 # ffffffffc02059a0 <buddy_system_pmm_manager+0x420>
ffffffffc0201dd6:	00003617          	auipc	a2,0x3
ffffffffc0201dda:	52260613          	addi	a2,a2,1314 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201dde:	05700593          	li	a1,87
ffffffffc0201de2:	00004517          	auipc	a0,0x4
ffffffffc0201de6:	bce50513          	addi	a0,a0,-1074 # ffffffffc02059b0 <buddy_system_pmm_manager+0x430>
ffffffffc0201dea:	bdefe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==4);
ffffffffc0201dee:	00004697          	auipc	a3,0x4
ffffffffc0201df2:	bb268693          	addi	a3,a3,-1102 # ffffffffc02059a0 <buddy_system_pmm_manager+0x420>
ffffffffc0201df6:	00003617          	auipc	a2,0x3
ffffffffc0201dfa:	50260613          	addi	a2,a2,1282 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201dfe:	05400593          	li	a1,84
ffffffffc0201e02:	00004517          	auipc	a0,0x4
ffffffffc0201e06:	bae50513          	addi	a0,a0,-1106 # ffffffffc02059b0 <buddy_system_pmm_manager+0x430>
ffffffffc0201e0a:	bbefe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201e0e <_fifo_swap_out_victim>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201e0e:	751c                	ld	a5,40(a0)
{
ffffffffc0201e10:	1141                	addi	sp,sp,-16
ffffffffc0201e12:	e406                	sd	ra,8(sp)
    assert(head != NULL);
ffffffffc0201e14:	cf91                	beqz	a5,ffffffffc0201e30 <_fifo_swap_out_victim+0x22>
    assert(in_tick==0);
ffffffffc0201e16:	ee0d                	bnez	a2,ffffffffc0201e50 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0201e18:	679c                	ld	a5,8(a5)
}
ffffffffc0201e1a:	60a2                	ld	ra,8(sp)
ffffffffc0201e1c:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0201e1e:	6394                	ld	a3,0(a5)
ffffffffc0201e20:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0201e22:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0201e26:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0201e28:	e314                	sd	a3,0(a4)
ffffffffc0201e2a:	e19c                	sd	a5,0(a1)
}
ffffffffc0201e2c:	0141                	addi	sp,sp,16
ffffffffc0201e2e:	8082                	ret
    assert(head != NULL);
ffffffffc0201e30:	00004697          	auipc	a3,0x4
ffffffffc0201e34:	cd068693          	addi	a3,a3,-816 # ffffffffc0205b00 <buddy_system_pmm_manager+0x580>
ffffffffc0201e38:	00003617          	auipc	a2,0x3
ffffffffc0201e3c:	4c060613          	addi	a2,a2,1216 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201e40:	04100593          	li	a1,65
ffffffffc0201e44:	00004517          	auipc	a0,0x4
ffffffffc0201e48:	b6c50513          	addi	a0,a0,-1172 # ffffffffc02059b0 <buddy_system_pmm_manager+0x430>
ffffffffc0201e4c:	b7cfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(in_tick==0);
ffffffffc0201e50:	00004697          	auipc	a3,0x4
ffffffffc0201e54:	cc068693          	addi	a3,a3,-832 # ffffffffc0205b10 <buddy_system_pmm_manager+0x590>
ffffffffc0201e58:	00003617          	auipc	a2,0x3
ffffffffc0201e5c:	4a060613          	addi	a2,a2,1184 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201e60:	04200593          	li	a1,66
ffffffffc0201e64:	00004517          	auipc	a0,0x4
ffffffffc0201e68:	b4c50513          	addi	a0,a0,-1204 # ffffffffc02059b0 <buddy_system_pmm_manager+0x430>
ffffffffc0201e6c:	b5cfe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201e70 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201e70:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0201e72:	cb91                	beqz	a5,ffffffffc0201e86 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201e74:	6394                	ld	a3,0(a5)
ffffffffc0201e76:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc0201e7a:	e398                	sd	a4,0(a5)
ffffffffc0201e7c:	e698                	sd	a4,8(a3)
}
ffffffffc0201e7e:	4501                	li	a0,0
    elm->next = next;
ffffffffc0201e80:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0201e82:	f614                	sd	a3,40(a2)
ffffffffc0201e84:	8082                	ret
{
ffffffffc0201e86:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0201e88:	00004697          	auipc	a3,0x4
ffffffffc0201e8c:	c9868693          	addi	a3,a3,-872 # ffffffffc0205b20 <buddy_system_pmm_manager+0x5a0>
ffffffffc0201e90:	00003617          	auipc	a2,0x3
ffffffffc0201e94:	46860613          	addi	a2,a2,1128 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201e98:	03200593          	li	a1,50
ffffffffc0201e9c:	00004517          	auipc	a0,0x4
ffffffffc0201ea0:	b1450513          	addi	a0,a0,-1260 # ffffffffc02059b0 <buddy_system_pmm_manager+0x430>
{
ffffffffc0201ea4:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0201ea6:	b22fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201eaa <log2.part.0>:
/*
 * 功能:n=2^m次幂，求m
 * 参数：
 * @n:      2^m次幂(n>0)
 */
static size_t log2(size_t n) 
ffffffffc0201eaa:	1141                	addi	sp,sp,-16
{
	assert(n > 0);
ffffffffc0201eac:	00003697          	auipc	a3,0x3
ffffffffc0201eb0:	65c68693          	addi	a3,a3,1628 # ffffffffc0205508 <commands+0x9e0>
ffffffffc0201eb4:	00003617          	auipc	a2,0x3
ffffffffc0201eb8:	44460613          	addi	a2,a2,1092 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0201ebc:	1bc00593          	li	a1,444
ffffffffc0201ec0:	00004517          	auipc	a0,0x4
ffffffffc0201ec4:	c9850513          	addi	a0,a0,-872 # ffffffffc0205b58 <buddy_system_pmm_manager+0x5d8>
static size_t log2(size_t n) 
ffffffffc0201ec8:	e406                	sd	ra,8(sp)
	assert(n > 0);
ffffffffc0201eca:	afefe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201ece <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201ece:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201ed0:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201ed2:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201ed6:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201ed8:	2ed000ef          	jal	ra,ffffffffc02029c4 <alloc_pages>
  if(!page) return NULL;
ffffffffc0201edc:	c91d                	beqz	a0,ffffffffc0201f12 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201ede:	00013697          	auipc	a3,0x13
ffffffffc0201ee2:	79a6b683          	ld	a3,1946(a3) # ffffffffc0215678 <pages>
ffffffffc0201ee6:	8d15                	sub	a0,a0,a3
ffffffffc0201ee8:	8519                	srai	a0,a0,0x6
ffffffffc0201eea:	00005697          	auipc	a3,0x5
ffffffffc0201eee:	9ee6b683          	ld	a3,-1554(a3) # ffffffffc02068d8 <nbase>
ffffffffc0201ef2:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201ef4:	00c51793          	slli	a5,a0,0xc
ffffffffc0201ef8:	83b1                	srli	a5,a5,0xc
ffffffffc0201efa:	00013717          	auipc	a4,0x13
ffffffffc0201efe:	77673703          	ld	a4,1910(a4) # ffffffffc0215670 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f02:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201f04:	00e7fa63          	bgeu	a5,a4,ffffffffc0201f18 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201f08:	00013697          	auipc	a3,0x13
ffffffffc0201f0c:	7806b683          	ld	a3,1920(a3) # ffffffffc0215688 <va_pa_offset>
ffffffffc0201f10:	9536                	add	a0,a0,a3
}
ffffffffc0201f12:	60a2                	ld	ra,8(sp)
ffffffffc0201f14:	0141                	addi	sp,sp,16
ffffffffc0201f16:	8082                	ret
ffffffffc0201f18:	86aa                	mv	a3,a0
ffffffffc0201f1a:	00004617          	auipc	a2,0x4
ffffffffc0201f1e:	8fe60613          	addi	a2,a2,-1794 # ffffffffc0205818 <buddy_system_pmm_manager+0x298>
ffffffffc0201f22:	06900593          	li	a1,105
ffffffffc0201f26:	00004517          	auipc	a0,0x4
ffffffffc0201f2a:	8e250513          	addi	a0,a0,-1822 # ffffffffc0205808 <buddy_system_pmm_manager+0x288>
ffffffffc0201f2e:	a9afe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201f32 <slub_alloc.constprop.0>:
 *		@size :请求分配的内存的大小(包括首部，因此>=16,且已规范为2^n）
 *		@gfp  :位掩码，用于表示内存分配的各种选项和限制(这里可能一般为0)
 *		@align:指定分配的内存块需要对齐的边界(这里可能一般为0)
 * 注意:暂时未考虑对齐问题(待改进)
 */
static void* slub_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201f32:	7179                	addi	sp,sp,-48
ffffffffc0201f34:	f406                	sd	ra,40(sp)
ffffffffc0201f36:	f022                	sd	s0,32(sp)
ffffffffc0201f38:	ec26                	sd	s1,24(sp)
ffffffffc0201f3a:	e84a                	sd	s2,16(sp)
{
	//cprintf("[调试信息]进入slub_alloc()\n");
	assert(size < PAGE_SIZE);
ffffffffc0201f3c:	6785                	lui	a5,0x1
ffffffffc0201f3e:	10f57e63          	bgeu	a0,a5,ffffffffc020205a <slub_alloc.constprop.0+0x128>
    size_t m = -1;
ffffffffc0201f42:	57fd                	li	a5,-1
	assert(n > 0);
ffffffffc0201f44:	12050b63          	beqz	a0,ffffffffc020207a <slub_alloc.constprop.0+0x148>
		n=(n>>1);
ffffffffc0201f48:	8105                	srli	a0,a0,0x1
		m++;
ffffffffc0201f4a:	0785                	addi	a5,a5,1
	while(n>0)
ffffffffc0201f4c:	fd75                	bnez	a0,ffffffffc0201f48 <slub_alloc.constprop.0+0x16>
//----------------------------变量声明----------------------------
	slub_t* slub      = Slubs+(log2(size)-Slubs_min_order); // 获取对应的slub
ffffffffc0201f4e:	079a                	slli	a5,a5,0x6
ffffffffc0201f50:	0000f417          	auipc	s0,0xf
ffffffffc0201f54:	3a840413          	addi	s0,s0,936 # ffffffffc02112f8 <ide+0x6eb0>
ffffffffc0201f58:	943e                	add	s0,s0,a5
	size_t  slub_size = slub->size;					        // 当前slub管理的size大小	
ffffffffc0201f5a:	6004                	ld	s1,0(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f5c:	100027f3          	csrr	a5,sstatus
ffffffffc0201f60:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201f62:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f64:	ebad                	bnez	a5,ffffffffc0201fd6 <slub_alloc.constprop.0+0xa4>
	struct slub_cache_waiting*  wait = &(slub->wait);  		// slub内存管理器的等待缓冲区
	struct slub_cache_working*  work = &(slub->work);  		// slub内存管理器的工作缓冲区
//----------------------------上锁----------------------------
	spin_lock_irqsave(&slob_lock, flags);
//----------------------------工作缓冲区缺失----------------------------
	if(work->freelist == NULL)
ffffffffc0201f66:	7c08                	ld	a0,56(s0)
ffffffffc0201f68:	c529                	beqz	a0,ffffffffc0201fb2 <slub_alloc.constprop.0+0x80>
		}		
	}
//----------------------------工作缓冲区非空:获取空闲内存块(现在可以保证工作区非空)----------------------------
	assert(work->freelist != NULL);
	//cprintf("[调试信息]工作缓冲区非空\n");
	page = (object*)work->pages;   		// slub工作缓冲区的物理页
ffffffffc0201f6a:	781c                	ld	a5,48(s0)
	// 处理freelist链表的空闲内存块链表(围绕取下的cur空闲内存块节点)
	cur = work->freelist;
	work->freelist = work->freelist->state.next_free;
	// 处理连续物理页节点
	page->nfree--;
ffffffffc0201f6c:	6798                	ld	a4,8(a5)
	work->freelist = work->freelist->state.next_free;
ffffffffc0201f6e:	6114                	ld	a3,0(a0)
	page->nfree--;
ffffffffc0201f70:	177d                	addi	a4,a4,-1
	work->freelist = work->freelist->state.next_free;
ffffffffc0201f72:	fc14                	sd	a3,56(s0)
	page->nfree--;
ffffffffc0201f74:	e798                	sd	a4,8(a5)
	page->first_free = work->freelist;  //可以考虑注释这一行，改为将page->nfree==0时直接设为NULL(因为没有维护的必要)	
ffffffffc0201f76:	eb94                	sd	a3,16(a5)
	// 处理取下的cur空闲内存块节点
	cur->state.size = slub_size; // 当内存块节点使用时，使用其state.size记录大小以便释放
ffffffffc0201f78:	e104                	sd	s1,0(a0)
//----------------------------连续物理页节点已满:将工作区物理页节点转移到等待缓冲区full链表----------------------------
	if(page->nfree==0) 
ffffffffc0201f7a:	eb11                	bnez	a4,ffffffffc0201f8e <slub_alloc.constprop.0+0x5c>
	{
		//cprintf("[调试信息]连续物理页节点已满\n");
		//page->first_free = NULL;
		assert(work->freelist==NULL && page->first_free==NULL);
ffffffffc0201f7c:	eed9                	bnez	a3,ffffffffc020201a <slub_alloc.constprop.0+0xe8>
		// 处理连续物理页节点
		page->next_head = wait->full;
		// 处理等待缓冲区
		wait->nr_slabs++;
ffffffffc0201f7e:	6c18                	ld	a4,24(s0)
		page->next_head = wait->full;
ffffffffc0201f80:	7414                	ld	a3,40(s0)
		wait->nr_slabs++;
ffffffffc0201f82:	0705                	addi	a4,a4,1
		page->next_head = wait->full;
ffffffffc0201f84:	ef94                	sd	a3,24(a5)
		wait->nr_slabs++;
ffffffffc0201f86:	ec18                	sd	a4,24(s0)
		wait->full = page;	
ffffffffc0201f88:	f41c                	sd	a5,40(s0)
		// 处理工作缓冲区
		work->pages    = NULL;
ffffffffc0201f8a:	02043823          	sd	zero,48(s0)
    if (flag) {
ffffffffc0201f8e:	00091863          	bnez	s2,ffffffffc0201f9e <slub_alloc.constprop.0+0x6c>
	}
//----------------------------解锁----------------------------
	spin_unlock_irqrestore(&slob_lock, flags);
	//cprintf("[调试信息]退出slub_alloc(),分配的内存地址为%x\n",cur);
	return cur;
}
ffffffffc0201f92:	70a2                	ld	ra,40(sp)
ffffffffc0201f94:	7402                	ld	s0,32(sp)
ffffffffc0201f96:	64e2                	ld	s1,24(sp)
ffffffffc0201f98:	6942                	ld	s2,16(sp)
ffffffffc0201f9a:	6145                	addi	sp,sp,48
ffffffffc0201f9c:	8082                	ret
ffffffffc0201f9e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201fa0:	e1efe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0201fa4:	70a2                	ld	ra,40(sp)
ffffffffc0201fa6:	7402                	ld	s0,32(sp)
ffffffffc0201fa8:	6522                	ld	a0,8(sp)
ffffffffc0201faa:	64e2                	ld	s1,24(sp)
ffffffffc0201fac:	6942                	ld	s2,16(sp)
ffffffffc0201fae:	6145                	addi	sp,sp,48
ffffffffc0201fb0:	8082                	ret
		if(wait->nr_partial > 0)
ffffffffc0201fb2:	6818                	ld	a4,16(s0)
ffffffffc0201fb4:	c70d                	beqz	a4,ffffffffc0201fde <slub_alloc.constprop.0+0xac>
			cur = wait->partial;
ffffffffc0201fb6:	701c                	ld	a5,32(s0)
			wait->nr_slabs  --;
ffffffffc0201fb8:	6c14                	ld	a3,24(s0)
			wait->nr_partial--;
ffffffffc0201fba:	177d                	addi	a4,a4,-1
			wait->partial  = cur->next_head;
ffffffffc0201fbc:	6f90                	ld	a2,24(a5)
			work->freelist = cur->first_free;
ffffffffc0201fbe:	6b88                	ld	a0,16(a5)
			wait->nr_slabs  --;
ffffffffc0201fc0:	16fd                	addi	a3,a3,-1
			wait->partial  = cur->next_head;
ffffffffc0201fc2:	f010                	sd	a2,32(s0)
			cur->next_head = NULL;
ffffffffc0201fc4:	0007bc23          	sd	zero,24(a5) # 1018 <kern_entry-0xffffffffc01fefe8>
			wait->nr_partial--;
ffffffffc0201fc8:	e818                	sd	a4,16(s0)
			wait->nr_slabs  --;
ffffffffc0201fca:	ec14                	sd	a3,24(s0)
			work->pages    = (void*)cur;
ffffffffc0201fcc:	f81c                	sd	a5,48(s0)
			work->freelist = cur->first_free;
ffffffffc0201fce:	fc08                	sd	a0,56(s0)
	assert(work->freelist != NULL);
ffffffffc0201fd0:	c52d                	beqz	a0,ffffffffc020203a <slub_alloc.constprop.0+0x108>
	page->nfree--;
ffffffffc0201fd2:	6798                	ld	a4,8(a5)
ffffffffc0201fd4:	bf69                	j	ffffffffc0201f6e <slub_alloc.constprop.0+0x3c>
        intr_disable();
ffffffffc0201fd6:	deefe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        return 1;
ffffffffc0201fda:	4905                	li	s2,1
ffffffffc0201fdc:	b769                	j	ffffffffc0201f66 <slub_alloc.constprop.0+0x34>
			cur = (object *)__slob_get_free_page(gfp); // 分配一页内存(可以通用，和slob无关)
ffffffffc0201fde:	4501                	li	a0,0
ffffffffc0201fe0:	eefff0ef          	jal	ra,ffffffffc0201ece <__slob_get_free_pages.constprop.0>
			if (!cur) 
ffffffffc0201fe4:	d54d                	beqz	a0,ffffffffc0201f8e <slub_alloc.constprop.0+0x5c>
			for(void *prev = (void*)cur,*now = prev+slub_size,*finish = prev+PAGE_SIZE; now<finish ; prev = now,now += slub_size)
ffffffffc0201fe6:	6685                	lui	a3,0x1
ffffffffc0201fe8:	009507b3          	add	a5,a0,s1
ffffffffc0201fec:	96aa                	add	a3,a3,a0
ffffffffc0201fee:	872a                	mv	a4,a0
ffffffffc0201ff0:	00d7f763          	bgeu	a5,a3,ffffffffc0201ffe <slub_alloc.constprop.0+0xcc>
				((object*)prev)->state.next_free = now;
ffffffffc0201ff4:	e31c                	sd	a5,0(a4)
			for(void *prev = (void*)cur,*now = prev+slub_size,*finish = prev+PAGE_SIZE; now<finish ; prev = now,now += slub_size)
ffffffffc0201ff6:	97a6                	add	a5,a5,s1
ffffffffc0201ff8:	9726                	add	a4,a4,s1
ffffffffc0201ffa:	fed7ede3          	bltu	a5,a3,ffffffffc0201ff4 <slub_alloc.constprop.0+0xc2>
			((object*)(((void*)cur)+PAGE_SIZE-slub_size))->state.next_free = NULL;
ffffffffc0201ffe:	6785                	lui	a5,0x1
			cur->nfree      = PAGE_SIZE/slub_size;
ffffffffc0202000:	0297d733          	divu	a4,a5,s1
			((object*)(((void*)cur)+PAGE_SIZE-slub_size))->state.next_free = NULL;
ffffffffc0202004:	8f85                	sub	a5,a5,s1
ffffffffc0202006:	97aa                	add	a5,a5,a0
ffffffffc0202008:	0007b023          	sd	zero,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
			cur->next_head  = NULL;
ffffffffc020200c:	00053c23          	sd	zero,24(a0)
			cur->first_free = cur;
ffffffffc0202010:	e908                	sd	a0,16(a0)
			work->pages     = (void*)cur;
ffffffffc0202012:	87aa                	mv	a5,a0
			cur->nfree      = PAGE_SIZE/slub_size;
ffffffffc0202014:	e518                	sd	a4,8(a0)
			work->pages     = (void*)cur;
ffffffffc0202016:	f808                	sd	a0,48(s0)
			work->freelist  = cur;
ffffffffc0202018:	bf99                	j	ffffffffc0201f6e <slub_alloc.constprop.0+0x3c>
		assert(work->freelist==NULL && page->first_free==NULL);
ffffffffc020201a:	00004697          	auipc	a3,0x4
ffffffffc020201e:	b8668693          	addi	a3,a3,-1146 # ffffffffc0205ba0 <buddy_system_pmm_manager+0x620>
ffffffffc0202022:	00003617          	auipc	a2,0x3
ffffffffc0202026:	2d660613          	addi	a2,a2,726 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020202a:	21c00593          	li	a1,540
ffffffffc020202e:	00004517          	auipc	a0,0x4
ffffffffc0202032:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0205b58 <buddy_system_pmm_manager+0x5d8>
ffffffffc0202036:	992fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
	assert(work->freelist != NULL);
ffffffffc020203a:	00004697          	auipc	a3,0x4
ffffffffc020203e:	b4e68693          	addi	a3,a3,-1202 # ffffffffc0205b88 <buddy_system_pmm_manager+0x608>
ffffffffc0202042:	00003617          	auipc	a2,0x3
ffffffffc0202046:	2b660613          	addi	a2,a2,694 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020204a:	20c00593          	li	a1,524
ffffffffc020204e:	00004517          	auipc	a0,0x4
ffffffffc0202052:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0205b58 <buddy_system_pmm_manager+0x5d8>
ffffffffc0202056:	972fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
	assert(size < PAGE_SIZE);
ffffffffc020205a:	00004697          	auipc	a3,0x4
ffffffffc020205e:	b1668693          	addi	a3,a3,-1258 # ffffffffc0205b70 <buddy_system_pmm_manager+0x5f0>
ffffffffc0202062:	00003617          	auipc	a2,0x3
ffffffffc0202066:	29660613          	addi	a2,a2,662 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020206a:	1d100593          	li	a1,465
ffffffffc020206e:	00004517          	auipc	a0,0x4
ffffffffc0202072:	aea50513          	addi	a0,a0,-1302 # ffffffffc0205b58 <buddy_system_pmm_manager+0x5d8>
ffffffffc0202076:	952fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc020207a:	e31ff0ef          	jal	ra,ffffffffc0201eaa <log2.part.0>

ffffffffc020207e <slub_free.part.0>:
 * 参数:
 * 		@block:slob单链表的节点
 *		@size :请求释放的内存的大小 
 * 注意:目前当一页为空时会被立即释放，可能影响效率（有待改进）
 */
static void slub_free(void* block, int size)
ffffffffc020207e:	7139                	addi	sp,sp,-64
ffffffffc0202080:	fc06                	sd	ra,56(sp)
ffffffffc0202082:	f826                	sd	s1,48(sp)
ffffffffc0202084:	f44a                	sd	s2,40(sp)
ffffffffc0202086:	f04e                	sd	s3,32(sp)
ffffffffc0202088:	ec52                	sd	s4,24(sp)
ffffffffc020208a:	57fd                	li	a5,-1
	assert(n > 0);
ffffffffc020208c:	1c058a63          	beqz	a1,ffffffffc0202260 <slub_free.part.0+0x1e2>
		n=(n>>1);
ffffffffc0202090:	8185                	srli	a1,a1,0x1
		m++;
ffffffffc0202092:	0785                	addi	a5,a5,1
	while(n>0)
ffffffffc0202094:	fdf5                	bnez	a1,ffffffffc0202090 <slub_free.part.0+0x12>
{
	//cprintf("[调试信息]进入slub_free(),释放的内存地址为%x,请求释放的内存的大小为%d\n",block,size);
	if (!block) return;
//----------------------------变量声明----------------------------
	slub_t* slub      = Slubs+(log2(size)-Slubs_min_order);	// 获取对应的slub
ffffffffc0202096:	079a                	slli	a5,a5,0x6
ffffffffc0202098:	0000f917          	auipc	s2,0xf
ffffffffc020209c:	26090913          	addi	s2,s2,608 # ffffffffc02112f8 <ide+0x6eb0>
ffffffffc02020a0:	993e                	add	s2,s2,a5
	size_t slub_size                 = slub->size;			// 当前slub管理的size大小	
ffffffffc02020a2:	00093a03          	ld	s4,0(s2)
	object* b = (object *)block;							// 需要释放的object节点
	unsigned long flags = 0;								// 自旋锁参数
	struct slub_cache_waiting*  wait = &(slub->wait);	    // slub内存管理器的等待缓冲区
	struct slub_cache_working*  work = &(slub->work);       // slub内存管理器的工作缓冲区
	object* page                =(object*)work->pages;		// slub工作缓冲区的物理页
ffffffffc02020a6:	03093483          	ld	s1,48(s2)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02020aa:	10002773          	csrr	a4,sstatus
ffffffffc02020ae:	8b09                	andi	a4,a4,2
    return 0;
ffffffffc02020b0:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02020b2:	ef5d                	bnez	a4,ffffffffc0202170 <slub_free.part.0+0xf2>
//----------------------------上锁----------------------------
	spin_lock_irqsave(&slob_lock, flags);
//----------------------------尝试释放到工作缓冲区----------------------------
	//cprintf("[调试信息]尝试释放到工作缓冲区\n");
	if( page!=NULL && page<=block && block<(work->pages+PAGE_SIZE) ) 
ffffffffc02020b4:	c099                	beqz	s1,ffffffffc02020ba <slub_free.part.0+0x3c>
ffffffffc02020b6:	04957263          	bgeu	a0,s1,ffffffffc02020fa <slub_free.part.0+0x7c>
		spin_unlock_irqrestore(&slob_lock, flags);
		return;
	}
//----------------------------尝试释放到等待缓冲区的full链表----------------------------
	//cprintf("[调试信息]尝试释放到等待缓冲区的full链表\n");
	for(object *prev=NULL,*cur=wait->full;cur!=NULL;prev=cur,cur=cur->next_head)
ffffffffc02020ba:	02893783          	ld	a5,40(s2)
ffffffffc02020be:	cf91                	beqz	a5,ffffffffc02020da <slub_free.part.0+0x5c>
ffffffffc02020c0:	4681                	li	a3,0
	{
		if(cur<=block && block<(((void*)cur)+PAGE_SIZE))
ffffffffc02020c2:	6605                	lui	a2,0x1
ffffffffc02020c4:	00f56663          	bltu	a0,a5,ffffffffc02020d0 <slub_free.part.0+0x52>
ffffffffc02020c8:	00c78733          	add	a4,a5,a2
ffffffffc02020cc:	06e56263          	bltu	a0,a4,ffffffffc0202130 <slub_free.part.0+0xb2>
	for(object *prev=NULL,*cur=wait->full;cur!=NULL;prev=cur,cur=cur->next_head)
ffffffffc02020d0:	6f98                	ld	a4,24(a5)
ffffffffc02020d2:	86be                	mv	a3,a5
ffffffffc02020d4:	c319                	beqz	a4,ffffffffc02020da <slub_free.part.0+0x5c>
ffffffffc02020d6:	87ba                	mv	a5,a4
ffffffffc02020d8:	b7f5                	j	ffffffffc02020c4 <slub_free.part.0+0x46>
			return;
		}
	}
//----------------------------尝试释放到等待缓冲区的partial链表----------------------------
	//cprintf("[调试信息]尝试释放到等待缓冲区的partial链表\n");
	for(object *prev=NULL,*cur=wait->partial;cur!=NULL;prev=cur,cur=cur->next_head)
ffffffffc02020da:	02093683          	ld	a3,32(s2)
ffffffffc02020de:	c2a1                	beqz	a3,ffffffffc020211e <slub_free.part.0+0xa0>
ffffffffc02020e0:	4601                	li	a2,0
	{
		if(cur<=block && block<(((void*)cur)+PAGE_SIZE))
ffffffffc02020e2:	6585                	lui	a1,0x1
ffffffffc02020e4:	00d56663          	bltu	a0,a3,ffffffffc02020f0 <slub_free.part.0+0x72>
ffffffffc02020e8:	00b68733          	add	a4,a3,a1
ffffffffc02020ec:	08e56b63          	bltu	a0,a4,ffffffffc0202182 <slub_free.part.0+0x104>
	for(object *prev=NULL,*cur=wait->partial;cur!=NULL;prev=cur,cur=cur->next_head)
ffffffffc02020f0:	6e98                	ld	a4,24(a3)
ffffffffc02020f2:	8636                	mv	a2,a3
ffffffffc02020f4:	c70d                	beqz	a4,ffffffffc020211e <slub_free.part.0+0xa0>
ffffffffc02020f6:	86ba                	mv	a3,a4
ffffffffc02020f8:	b7f5                	j	ffffffffc02020e4 <slub_free.part.0+0x66>
	if( page!=NULL && page<=block && block<(work->pages+PAGE_SIZE) ) 
ffffffffc02020fa:	03093783          	ld	a5,48(s2)
ffffffffc02020fe:	6705                	lui	a4,0x1
ffffffffc0202100:	97ba                	add	a5,a5,a4
ffffffffc0202102:	faf57ce3          	bgeu	a0,a5,ffffffffc02020ba <slub_free.part.0+0x3c>
		page->nfree++;
ffffffffc0202106:	649c                	ld	a5,8(s1)
		b->state.next_free = work->freelist;
ffffffffc0202108:	03893683          	ld	a3,56(s2)
		page->nfree++;
ffffffffc020210c:	0785                	addi	a5,a5,1
		if(page->nfree*slub_size==PAGE_SIZE)
ffffffffc020210e:	02fa0a33          	mul	s4,s4,a5
		b->state.next_free = work->freelist;
ffffffffc0202112:	e114                	sd	a3,0(a0)
		work->freelist = b;
ffffffffc0202114:	02a93c23          	sd	a0,56(s2)
		page->nfree++;
ffffffffc0202118:	e49c                	sd	a5,8(s1)
		if(page->nfree*slub_size==PAGE_SIZE)
ffffffffc020211a:	0cea0d63          	beq	s4,a4,ffffffffc02021f4 <slub_free.part.0+0x176>
    if (flag) {
ffffffffc020211e:	04099163          	bnez	s3,ffffffffc0202160 <slub_free.part.0+0xe2>
		}
	}	
//----------------------------解锁(原则上不会到这，以防万一)----------------------------
	spin_unlock_irqrestore(&slob_lock, flags);
	return;
}
ffffffffc0202122:	70e2                	ld	ra,56(sp)
ffffffffc0202124:	74c2                	ld	s1,48(sp)
ffffffffc0202126:	7922                	ld	s2,40(sp)
ffffffffc0202128:	7982                	ld	s3,32(sp)
ffffffffc020212a:	6a62                	ld	s4,24(sp)
ffffffffc020212c:	6121                	addi	sp,sp,64
ffffffffc020212e:	8082                	ret
			assert(cur->first_free==NULL);
ffffffffc0202130:	6b98                	ld	a4,16(a5)
ffffffffc0202132:	12071963          	bnez	a4,ffffffffc0202264 <slub_free.part.0+0x1e6>
			cur->nfree++;
ffffffffc0202136:	6790                	ld	a2,8(a5)
			wait->nr_partial++;
ffffffffc0202138:	01093703          	ld	a4,16(s2)
			b->state.next_free = cur->first_free;
ffffffffc020213c:	00053023          	sd	zero,0(a0)
			cur->nfree++;
ffffffffc0202140:	0605                	addi	a2,a2,1
			wait->nr_partial++;
ffffffffc0202142:	0705                	addi	a4,a4,1
			cur->first_free = b;
ffffffffc0202144:	eb88                	sd	a0,16(a5)
			cur->nfree++;
ffffffffc0202146:	e790                	sd	a2,8(a5)
			wait->nr_partial++;
ffffffffc0202148:	00e93823          	sd	a4,16(s2)
			if(prev==NULL) wait->full      = cur->next_head; //cur为第一个的情况
ffffffffc020214c:	6f98                	ld	a4,24(a5)
ffffffffc020214e:	c69d                	beqz	a3,ffffffffc020217c <slub_free.part.0+0xfe>
			else           prev->next_head = cur->next_head;
ffffffffc0202150:	ee98                	sd	a4,24(a3)
			cur->next_head = wait->partial;
ffffffffc0202152:	02093703          	ld	a4,32(s2)
ffffffffc0202156:	ef98                	sd	a4,24(a5)
			wait->partial  = cur;
ffffffffc0202158:	02f93023          	sd	a5,32(s2)
ffffffffc020215c:	fc0983e3          	beqz	s3,ffffffffc0202122 <slub_free.part.0+0xa4>
}
ffffffffc0202160:	70e2                	ld	ra,56(sp)
ffffffffc0202162:	74c2                	ld	s1,48(sp)
ffffffffc0202164:	7922                	ld	s2,40(sp)
ffffffffc0202166:	7982                	ld	s3,32(sp)
ffffffffc0202168:	6a62                	ld	s4,24(sp)
ffffffffc020216a:	6121                	addi	sp,sp,64
        intr_enable();
ffffffffc020216c:	c52fe06f          	j	ffffffffc02005be <intr_enable>
ffffffffc0202170:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202172:	c52fe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        return 1;
ffffffffc0202176:	6522                	ld	a0,8(sp)
ffffffffc0202178:	4985                	li	s3,1
ffffffffc020217a:	bf2d                	j	ffffffffc02020b4 <slub_free.part.0+0x36>
			if(prev==NULL) wait->full      = cur->next_head; //cur为第一个的情况
ffffffffc020217c:	02e93423          	sd	a4,40(s2)
ffffffffc0202180:	bfc9                	j	ffffffffc0202152 <slub_free.part.0+0xd4>
			cur->nfree++;
ffffffffc0202182:	669c                	ld	a5,8(a3)
			b->state.next_free = cur->first_free;
ffffffffc0202184:	6a98                	ld	a4,16(a3)
			cur->nfree++;
ffffffffc0202186:	0785                	addi	a5,a5,1
			if(cur->nfree*slub_size==PAGE_SIZE)
ffffffffc0202188:	02fa0a33          	mul	s4,s4,a5
			b->state.next_free = cur->first_free;
ffffffffc020218c:	e118                	sd	a4,0(a0)
			cur->first_free = b;
ffffffffc020218e:	ea88                	sd	a0,16(a3)
			cur->nfree++;
ffffffffc0202190:	e69c                	sd	a5,8(a3)
			if(cur->nfree*slub_size==PAGE_SIZE)
ffffffffc0202192:	f8ba16e3          	bne	s4,a1,ffffffffc020211e <slub_free.part.0+0xa0>
				if(prev==NULL) wait->partial   = cur->next_head; //cur为第一个的情况
ffffffffc0202196:	6e9c                	ld	a5,24(a3)
ffffffffc0202198:	c645                	beqz	a2,ffffffffc0202240 <slub_free.part.0+0x1c2>
				else           prev->next_head = cur->next_head;
ffffffffc020219a:	ee1c                	sd	a5,24(a2)
    return pa2page(PADDR(kva));
ffffffffc020219c:	c02007b7          	lui	a5,0xc0200
ffffffffc02021a0:	0ef6ee63          	bltu	a3,a5,ffffffffc020229c <slub_free.part.0+0x21e>
ffffffffc02021a4:	00013797          	auipc	a5,0x13
ffffffffc02021a8:	4e47b783          	ld	a5,1252(a5) # ffffffffc0215688 <va_pa_offset>
ffffffffc02021ac:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02021b0:	83b1                	srli	a5,a5,0xc
ffffffffc02021b2:	00013717          	auipc	a4,0x13
ffffffffc02021b6:	4be73703          	ld	a4,1214(a4) # ffffffffc0215670 <npage>
ffffffffc02021ba:	0ce7f563          	bgeu	a5,a4,ffffffffc0202284 <slub_free.part.0+0x206>
    return &pages[PPN(pa) - nbase];
ffffffffc02021be:	00004717          	auipc	a4,0x4
ffffffffc02021c2:	71a73703          	ld	a4,1818(a4) # ffffffffc02068d8 <nbase>
ffffffffc02021c6:	8f99                	sub	a5,a5,a4
ffffffffc02021c8:	079a                	slli	a5,a5,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc02021ca:	00013517          	auipc	a0,0x13
ffffffffc02021ce:	4ae53503          	ld	a0,1198(a0) # ffffffffc0215678 <pages>
ffffffffc02021d2:	953e                	add	a0,a0,a5
ffffffffc02021d4:	4585                	li	a1,1
ffffffffc02021d6:	081000ef          	jal	ra,ffffffffc0202a56 <free_pages>
				wait->nr_partial--;
ffffffffc02021da:	01093703          	ld	a4,16(s2)
				wait->nr_slabs  --;
ffffffffc02021de:	01893783          	ld	a5,24(s2)
				wait->nr_partial--;
ffffffffc02021e2:	177d                	addi	a4,a4,-1
				wait->nr_slabs  --;
ffffffffc02021e4:	17fd                	addi	a5,a5,-1
				wait->nr_partial--;
ffffffffc02021e6:	00e93823          	sd	a4,16(s2)
				wait->nr_slabs  --;
ffffffffc02021ea:	00f93c23          	sd	a5,24(s2)
    if (flag) {
ffffffffc02021ee:	f2098ae3          	beqz	s3,ffffffffc0202122 <slub_free.part.0+0xa4>
ffffffffc02021f2:	b7bd                	j	ffffffffc0202160 <slub_free.part.0+0xe2>
    return pa2page(PADDR(kva));
ffffffffc02021f4:	c02007b7          	lui	a5,0xc0200
ffffffffc02021f8:	04f4e763          	bltu	s1,a5,ffffffffc0202246 <slub_free.part.0+0x1c8>
ffffffffc02021fc:	00013717          	auipc	a4,0x13
ffffffffc0202200:	48c73703          	ld	a4,1164(a4) # ffffffffc0215688 <va_pa_offset>
ffffffffc0202204:	40e48733          	sub	a4,s1,a4
    if (PPN(pa) >= npage) {
ffffffffc0202208:	8331                	srli	a4,a4,0xc
ffffffffc020220a:	00013797          	auipc	a5,0x13
ffffffffc020220e:	4667b783          	ld	a5,1126(a5) # ffffffffc0215670 <npage>
ffffffffc0202212:	06f77963          	bgeu	a4,a5,ffffffffc0202284 <slub_free.part.0+0x206>
    return &pages[PPN(pa) - nbase];
ffffffffc0202216:	00004797          	auipc	a5,0x4
ffffffffc020221a:	6c27b783          	ld	a5,1730(a5) # ffffffffc02068d8 <nbase>
ffffffffc020221e:	8f1d                	sub	a4,a4,a5
ffffffffc0202220:	071a                	slli	a4,a4,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc0202222:	00013517          	auipc	a0,0x13
ffffffffc0202226:	45653503          	ld	a0,1110(a0) # ffffffffc0215678 <pages>
ffffffffc020222a:	4585                	li	a1,1
ffffffffc020222c:	953a                	add	a0,a0,a4
ffffffffc020222e:	029000ef          	jal	ra,ffffffffc0202a56 <free_pages>
			work->freelist = NULL;
ffffffffc0202232:	02093c23          	sd	zero,56(s2)
			work->pages    = NULL;
ffffffffc0202236:	02093823          	sd	zero,48(s2)
ffffffffc020223a:	ee0984e3          	beqz	s3,ffffffffc0202122 <slub_free.part.0+0xa4>
ffffffffc020223e:	b70d                	j	ffffffffc0202160 <slub_free.part.0+0xe2>
				if(prev==NULL) wait->partial   = cur->next_head; //cur为第一个的情况
ffffffffc0202240:	02f93023          	sd	a5,32(s2)
ffffffffc0202244:	bfa1                	j	ffffffffc020219c <slub_free.part.0+0x11e>
    return pa2page(PADDR(kva));
ffffffffc0202246:	86a6                	mv	a3,s1
ffffffffc0202248:	00004617          	auipc	a2,0x4
ffffffffc020224c:	98860613          	addi	a2,a2,-1656 # ffffffffc0205bd0 <buddy_system_pmm_manager+0x650>
ffffffffc0202250:	06e00593          	li	a1,110
ffffffffc0202254:	00003517          	auipc	a0,0x3
ffffffffc0202258:	5b450513          	addi	a0,a0,1460 # ffffffffc0205808 <buddy_system_pmm_manager+0x288>
ffffffffc020225c:	f6dfd0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0202260:	c4bff0ef          	jal	ra,ffffffffc0201eaa <log2.part.0>
			assert(cur->first_free==NULL);
ffffffffc0202264:	00004697          	auipc	a3,0x4
ffffffffc0202268:	99468693          	addi	a3,a3,-1644 # ffffffffc0205bf8 <buddy_system_pmm_manager+0x678>
ffffffffc020226c:	00003617          	auipc	a2,0x3
ffffffffc0202270:	08c60613          	addi	a2,a2,140 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0202274:	26100593          	li	a1,609
ffffffffc0202278:	00004517          	auipc	a0,0x4
ffffffffc020227c:	8e050513          	addi	a0,a0,-1824 # ffffffffc0205b58 <buddy_system_pmm_manager+0x5d8>
ffffffffc0202280:	f49fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202284:	00003617          	auipc	a2,0x3
ffffffffc0202288:	56460613          	addi	a2,a2,1380 # ffffffffc02057e8 <buddy_system_pmm_manager+0x268>
ffffffffc020228c:	06200593          	li	a1,98
ffffffffc0202290:	00003517          	auipc	a0,0x3
ffffffffc0202294:	57850513          	addi	a0,a0,1400 # ffffffffc0205808 <buddy_system_pmm_manager+0x288>
ffffffffc0202298:	f31fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020229c:	00004617          	auipc	a2,0x4
ffffffffc02022a0:	93460613          	addi	a2,a2,-1740 # ffffffffc0205bd0 <buddy_system_pmm_manager+0x650>
ffffffffc02022a4:	06e00593          	li	a1,110
ffffffffc02022a8:	00003517          	auipc	a0,0x3
ffffffffc02022ac:	56050513          	addi	a0,a0,1376 # ffffffffc0205808 <buddy_system_pmm_manager+0x288>
ffffffffc02022b0:	f19fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02022b4 <__kmalloc.constprop.0>:
 * 功能:分配内存
 * 参数:
 *     @size:请求分配的内存的大小
 *     @gfp :位掩码，用于表示内存分配的各种选项和限制。(这里可能一般为0)
 */
static void *__kmalloc(size_t size, gfp_t gfp)
ffffffffc02022b4:	7179                	addi	sp,sp,-48
ffffffffc02022b6:	f406                	sd	ra,40(sp)
ffffffffc02022b8:	f022                	sd	s0,32(sp)
ffffffffc02022ba:	ec26                	sd	s1,24(sp)
ffffffffc02022bc:	e84a                	sd	s2,16(sp)
ffffffffc02022be:	e44e                	sd	s3,8(sp)
{
	if(size<=0) return NULL;
ffffffffc02022c0:	cd49                	beqz	a0,ffffffffc020235a <__kmalloc.constprop.0+0xa6>
    assert(n > 0);
ffffffffc02022c2:	5781                	li	a5,-32
ffffffffc02022c4:	842a                	mv	s0,a0
ffffffffc02022c6:	0cf50d63          	beq	a0,a5,ffffffffc02023a0 <__kmalloc.constprop.0+0xec>
    n--; 
ffffffffc02022ca:	057d                	addi	a0,a0,31
    n |= n >> 1;  
ffffffffc02022cc:	00155793          	srli	a5,a0,0x1
ffffffffc02022d0:	8d5d                	or	a0,a0,a5
    n |= n >> 2;  
ffffffffc02022d2:	00255793          	srli	a5,a0,0x2
ffffffffc02022d6:	8d5d                	or	a0,a0,a5
    n |= n >> 4;  
ffffffffc02022d8:	00455793          	srli	a5,a0,0x4
ffffffffc02022dc:	8d5d                	or	a0,a0,a5
    n |= n >> 8;  
ffffffffc02022de:	00855793          	srli	a5,a0,0x8
ffffffffc02022e2:	8d5d                	or	a0,a0,a5
    n |= n >> 16;
ffffffffc02022e4:	01055793          	srli	a5,a0,0x10
ffffffffc02022e8:	8d5d                	or	a0,a0,a5
    n |= n >> 32;  
ffffffffc02022ea:	02055793          	srli	a5,a0,0x20
ffffffffc02022ee:	8d5d                	or	a0,a0,a5
    n++;
ffffffffc02022f0:	0505                	addi	a0,a0,1
		}		
	}
	if(USING_SLUB) 
	{
		size_t up_size = up_to_2_power(size+SLUB_UNIT);		// 向上取整后的大小(Byte)
		if (up_size < PAGE_SIZE) 							// 如果小于1页(包括头部)
ffffffffc02022f2:	6905                	lui	s2,0x1
ffffffffc02022f4:	05256e63          	bltu	a0,s2,ffffffffc0202350 <__kmalloc.constprop.0+0x9c>
		if (!bb) return 0;
	}
	if(USING_SLUB) 	// 使用slub分配器分配一个单向链表节点(>=1页)
	{
		size_t up_size = up_to_2_power(sizeof(bigblock_t)+SLUB_UNIT);		// 向上取整后的大小(Byte)
		bb = slub_alloc(up_size, gfp, 0);
ffffffffc02022f8:	04000513          	li	a0,64
ffffffffc02022fc:	c37ff0ef          	jal	ra,ffffffffc0201f32 <slub_alloc.constprop.0>
ffffffffc0202300:	84aa                	mv	s1,a0
		if (!bb) return 0;
ffffffffc0202302:	cd21                	beqz	a0,ffffffffc020235a <__kmalloc.constprop.0+0xa6>
		bb = (bigblock_t*)((void*)bb+SLUB_UNIT);
	}
	

	bb->order = find_order(size);
ffffffffc0202304:	0004079b          	sext.w	a5,s0
		bb = (bigblock_t*)((void*)bb+SLUB_UNIT);
ffffffffc0202308:	02050993          	addi	s3,a0,32
	int order = 0;
ffffffffc020230c:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc020230e:	00f95763          	bge	s2,a5,ffffffffc020231c <__kmalloc.constprop.0+0x68>
ffffffffc0202312:	6705                	lui	a4,0x1
ffffffffc0202314:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0202316:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0202318:	fef74ee3          	blt	a4,a5,ffffffffc0202314 <__kmalloc.constprop.0+0x60>
	bb->order = find_order(size);
ffffffffc020231c:	d088                	sw	a0,32(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc020231e:	bb1ff0ef          	jal	ra,ffffffffc0201ece <__slob_get_free_pages.constprop.0>
ffffffffc0202322:	f488                	sd	a0,40(s1)
ffffffffc0202324:	842a                	mv	s0,a0

	if (bb->pages) 
ffffffffc0202326:	c925                	beqz	a0,ffffffffc0202396 <__kmalloc.constprop.0+0xe2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202328:	100027f3          	csrr	a5,sstatus
ffffffffc020232c:	8b89                	andi	a5,a5,2
ffffffffc020232e:	ef9d                	bnez	a5,ffffffffc020236c <__kmalloc.constprop.0+0xb8>
	{
		spin_lock_irqsave(&block_lock, flags);
		bb->next = bigblocks;
ffffffffc0202330:	00013797          	auipc	a5,0x13
ffffffffc0202334:	31078793          	addi	a5,a5,784 # ffffffffc0215640 <bigblocks>
ffffffffc0202338:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc020233a:	0137b023          	sd	s3,0(a5)
		bb->next = bigblocks;
ffffffffc020233e:	f898                	sd	a4,48(s1)
	if(USING_SLUB) 
	{
		slub_free((object *)bb - 1, (size_t)((object *)bb-1)->state.size); 
	}
	return 0;
}
ffffffffc0202340:	70a2                	ld	ra,40(sp)
ffffffffc0202342:	8522                	mv	a0,s0
ffffffffc0202344:	7402                	ld	s0,32(sp)
ffffffffc0202346:	64e2                	ld	s1,24(sp)
ffffffffc0202348:	6942                	ld	s2,16(sp)
ffffffffc020234a:	69a2                	ld	s3,8(sp)
ffffffffc020234c:	6145                	addi	sp,sp,48
ffffffffc020234e:	8082                	ret
			object* m = slub_alloc(up_size, gfp, 0); 				// 使用slub分配器分配内存
ffffffffc0202350:	be3ff0ef          	jal	ra,ffffffffc0201f32 <slub_alloc.constprop.0>
			return m ? (void *)(m + 1) : 0;					// 如果分配到了返回指针，否则返回NULL			
ffffffffc0202354:	02050413          	addi	s0,a0,32
ffffffffc0202358:	f565                	bnez	a0,ffffffffc0202340 <__kmalloc.constprop.0+0x8c>
	if(size<=0) return NULL;
ffffffffc020235a:	4401                	li	s0,0
}
ffffffffc020235c:	70a2                	ld	ra,40(sp)
ffffffffc020235e:	8522                	mv	a0,s0
ffffffffc0202360:	7402                	ld	s0,32(sp)
ffffffffc0202362:	64e2                	ld	s1,24(sp)
ffffffffc0202364:	6942                	ld	s2,16(sp)
ffffffffc0202366:	69a2                	ld	s3,8(sp)
ffffffffc0202368:	6145                	addi	sp,sp,48
ffffffffc020236a:	8082                	ret
        intr_disable();
ffffffffc020236c:	a58fe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
		bb->next = bigblocks;
ffffffffc0202370:	00013797          	auipc	a5,0x13
ffffffffc0202374:	2d078793          	addi	a5,a5,720 # ffffffffc0215640 <bigblocks>
ffffffffc0202378:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc020237a:	0137b023          	sd	s3,0(a5)
		bb->next = bigblocks;
ffffffffc020237e:	f898                	sd	a4,48(s1)
        intr_enable();
ffffffffc0202380:	a3efe0ef          	jal	ra,ffffffffc02005be <intr_enable>
		return bb->pages;
ffffffffc0202384:	7480                	ld	s0,40(s1)
}
ffffffffc0202386:	70a2                	ld	ra,40(sp)
ffffffffc0202388:	64e2                	ld	s1,24(sp)
ffffffffc020238a:	8522                	mv	a0,s0
ffffffffc020238c:	7402                	ld	s0,32(sp)
ffffffffc020238e:	6942                	ld	s2,16(sp)
ffffffffc0202390:	69a2                	ld	s3,8(sp)
ffffffffc0202392:	6145                	addi	sp,sp,48
ffffffffc0202394:	8082                	ret
	if (!block) return;
ffffffffc0202396:	408c                	lw	a1,0(s1)
ffffffffc0202398:	8526                	mv	a0,s1
ffffffffc020239a:	ce5ff0ef          	jal	ra,ffffffffc020207e <slub_free.part.0>
	return 0;
ffffffffc020239e:	b74d                	j	ffffffffc0202340 <__kmalloc.constprop.0+0x8c>
    assert(n > 0);
ffffffffc02023a0:	00003697          	auipc	a3,0x3
ffffffffc02023a4:	16868693          	addi	a3,a3,360 # ffffffffc0205508 <commands+0x9e0>
ffffffffc02023a8:	00003617          	auipc	a2,0x3
ffffffffc02023ac:	f5060613          	addi	a2,a2,-176 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02023b0:	1a900593          	li	a1,425
ffffffffc02023b4:	00003517          	auipc	a0,0x3
ffffffffc02023b8:	7a450513          	addi	a0,a0,1956 # ffffffffc0205b58 <buddy_system_pmm_manager+0x5d8>
ffffffffc02023bc:	e0dfd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02023c0 <kmalloc>:
 *     @size:请求分配的内存的大小
 * 注意:这是分配内存对外的接口
 */
void* kmalloc(size_t size)
{
	return __kmalloc(size, 0);
ffffffffc02023c0:	bdd5                	j	ffffffffc02022b4 <__kmalloc.constprop.0>

ffffffffc02023c2 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block) return;
ffffffffc02023c2:	c569                	beqz	a0,ffffffffc020248c <kfree+0xca>
{
ffffffffc02023c4:	1101                	addi	sp,sp,-32
ffffffffc02023c6:	e822                	sd	s0,16(sp)
ffffffffc02023c8:	ec06                	sd	ra,24(sp)
ffffffffc02023ca:	e426                	sd	s1,8(sp)

	if (!((unsigned long)block & (PAGE_SIZE-1))) // 如果是与页对齐的(即可能为按页分配的)
ffffffffc02023cc:	03451793          	slli	a5,a0,0x34
ffffffffc02023d0:	842a                	mv	s0,a0
ffffffffc02023d2:	e7c9                	bnez	a5,ffffffffc020245c <kfree+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02023d4:	100027f3          	csrr	a5,sstatus
ffffffffc02023d8:	8b89                	andi	a5,a5,2
ffffffffc02023da:	ebd9                	bnez	a5,ffffffffc0202470 <kfree+0xae>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) // 遍历链表(似乎尾节点缺乏显示初始化为NULL)
ffffffffc02023dc:	00013797          	auipc	a5,0x13
ffffffffc02023e0:	2647b783          	ld	a5,612(a5) # ffffffffc0215640 <bigblocks>
    return 0;
ffffffffc02023e4:	4601                	li	a2,0
ffffffffc02023e6:	cbbd                	beqz	a5,ffffffffc020245c <kfree+0x9a>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc02023e8:	00013697          	auipc	a3,0x13
ffffffffc02023ec:	25868693          	addi	a3,a3,600 # ffffffffc0215640 <bigblocks>
ffffffffc02023f0:	a021                	j	ffffffffc02023f8 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) // 遍历链表(似乎尾节点缺乏显示初始化为NULL)
ffffffffc02023f2:	01048693          	addi	a3,s1,16
ffffffffc02023f6:	c3b5                	beqz	a5,ffffffffc020245a <kfree+0x98>
		{
			if (bb->pages == block) // 如果在链表里
ffffffffc02023f8:	6798                	ld	a4,8(a5)
ffffffffc02023fa:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc02023fc:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) // 如果在链表里
ffffffffc02023fe:	fe871ae3          	bne	a4,s0,ffffffffc02023f2 <kfree+0x30>
				*last = bb->next;
ffffffffc0202402:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0202404:	e249                	bnez	a2,ffffffffc0202486 <kfree+0xc4>
ffffffffc0202406:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc020240a:	4098                	lw	a4,0(s1)
ffffffffc020240c:	08f46d63          	bltu	s0,a5,ffffffffc02024a6 <kfree+0xe4>
ffffffffc0202410:	00013697          	auipc	a3,0x13
ffffffffc0202414:	2786b683          	ld	a3,632(a3) # ffffffffc0215688 <va_pa_offset>
ffffffffc0202418:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc020241a:	8031                	srli	s0,s0,0xc
ffffffffc020241c:	00013797          	auipc	a5,0x13
ffffffffc0202420:	2547b783          	ld	a5,596(a5) # ffffffffc0215670 <npage>
ffffffffc0202424:	06f47563          	bgeu	s0,a5,ffffffffc020248e <kfree+0xcc>
    return &pages[PPN(pa) - nbase];
ffffffffc0202428:	00004517          	auipc	a0,0x4
ffffffffc020242c:	4b053503          	ld	a0,1200(a0) # ffffffffc02068d8 <nbase>
ffffffffc0202430:	8c09                	sub	s0,s0,a0
ffffffffc0202432:	041a                	slli	s0,s0,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc0202434:	00013517          	auipc	a0,0x13
ffffffffc0202438:	24453503          	ld	a0,580(a0) # ffffffffc0215678 <pages>
ffffffffc020243c:	4585                	li	a1,1
ffffffffc020243e:	9522                	add	a0,a0,s0
ffffffffc0202440:	00e595bb          	sllw	a1,a1,a4
ffffffffc0202444:	612000ef          	jal	ra,ffffffffc0202a56 <free_pages>
	
	// 释放小于1页的
    if(USING_SLOB) slob_free((slob_t *)block - 1, 0); 
	if(USING_SLUB) slub_free((object *)block - 1, (size_t)((object*)block-1)->state.size); 
	return;
}
ffffffffc0202448:	6442                	ld	s0,16(sp)
ffffffffc020244a:	fe04a583          	lw	a1,-32(s1)
ffffffffc020244e:	60e2                	ld	ra,24(sp)
ffffffffc0202450:	8526                	mv	a0,s1
ffffffffc0202452:	64a2                	ld	s1,8(sp)
ffffffffc0202454:	6105                	addi	sp,sp,32
ffffffffc0202456:	c29ff06f          	j	ffffffffc020207e <slub_free.part.0>
ffffffffc020245a:	e21d                	bnez	a2,ffffffffc0202480 <kfree+0xbe>
	if (!block) return;
ffffffffc020245c:	fe042583          	lw	a1,-32(s0)
ffffffffc0202460:	fe040513          	addi	a0,s0,-32
}
ffffffffc0202464:	6442                	ld	s0,16(sp)
ffffffffc0202466:	60e2                	ld	ra,24(sp)
ffffffffc0202468:	64a2                	ld	s1,8(sp)
ffffffffc020246a:	6105                	addi	sp,sp,32
ffffffffc020246c:	c13ff06f          	j	ffffffffc020207e <slub_free.part.0>
        intr_disable();
ffffffffc0202470:	954fe0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) // 遍历链表(似乎尾节点缺乏显示初始化为NULL)
ffffffffc0202474:	00013797          	auipc	a5,0x13
ffffffffc0202478:	1cc7b783          	ld	a5,460(a5) # ffffffffc0215640 <bigblocks>
        return 1;
ffffffffc020247c:	4605                	li	a2,1
ffffffffc020247e:	f7ad                	bnez	a5,ffffffffc02023e8 <kfree+0x26>
        intr_enable();
ffffffffc0202480:	93efe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0202484:	bfe1                	j	ffffffffc020245c <kfree+0x9a>
ffffffffc0202486:	938fe0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc020248a:	bfb5                	j	ffffffffc0202406 <kfree+0x44>
ffffffffc020248c:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc020248e:	00003617          	auipc	a2,0x3
ffffffffc0202492:	35a60613          	addi	a2,a2,858 # ffffffffc02057e8 <buddy_system_pmm_manager+0x268>
ffffffffc0202496:	06200593          	li	a1,98
ffffffffc020249a:	00003517          	auipc	a0,0x3
ffffffffc020249e:	36e50513          	addi	a0,a0,878 # ffffffffc0205808 <buddy_system_pmm_manager+0x288>
ffffffffc02024a2:	d27fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02024a6:	86a2                	mv	a3,s0
ffffffffc02024a8:	00003617          	auipc	a2,0x3
ffffffffc02024ac:	72860613          	addi	a2,a2,1832 # ffffffffc0205bd0 <buddy_system_pmm_manager+0x650>
ffffffffc02024b0:	06e00593          	li	a1,110
ffffffffc02024b4:	00003517          	auipc	a0,0x3
ffffffffc02024b8:	35450513          	addi	a0,a0,852 # ffffffffc0205808 <buddy_system_pmm_manager+0x288>
ffffffffc02024bc:	d0dfd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02024c0 <slub_init>:
{
ffffffffc02024c0:	715d                	addi	sp,sp,-80
	cprintf("use SLUB allocator\n");
ffffffffc02024c2:	00003517          	auipc	a0,0x3
ffffffffc02024c6:	74e50513          	addi	a0,a0,1870 # ffffffffc0205c10 <buddy_system_pmm_manager+0x690>
{
ffffffffc02024ca:	e0a2                	sd	s0,64(sp)
ffffffffc02024cc:	e486                	sd	ra,72(sp)
ffffffffc02024ce:	fc26                	sd	s1,56(sp)
ffffffffc02024d0:	f84a                	sd	s2,48(sp)
ffffffffc02024d2:	f44e                	sd	s3,40(sp)
ffffffffc02024d4:	f052                	sd	s4,32(sp)
ffffffffc02024d6:	ec56                	sd	s5,24(sp)
ffffffffc02024d8:	e85a                	sd	s6,16(sp)
ffffffffc02024da:	e45e                	sd	s7,8(sp)
ffffffffc02024dc:	e062                	sd	s8,0(sp)
ffffffffc02024de:	0000f417          	auipc	s0,0xf
ffffffffc02024e2:	f9a40413          	addi	s0,s0,-102 # ffffffffc0211478 <Slubs>
	cprintf("use SLUB allocator\n");
ffffffffc02024e6:	be7fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
	for(int i=0,size=(1<<Slubs_min_order);i<Slubs_size;i++,size=(size<<1)) // 遍历初始化Slubs
ffffffffc02024ea:	87a2                	mv	a5,s0
ffffffffc02024ec:	0000f617          	auipc	a2,0xf
ffffffffc02024f0:	10c60613          	addi	a2,a2,268 # ffffffffc02115f8 <hash_list>
ffffffffc02024f4:	04000713          	li	a4,64
		Slubs[i].obj_size        = size-SLUB_UNIT;
ffffffffc02024f8:	fe070693          	addi	a3,a4,-32 # fe0 <kern_entry-0xffffffffc01ff020>
		Slubs[i].size            = size;
ffffffffc02024fc:	e398                	sd	a4,0(a5)
		Slubs[i].obj_size        = size-SLUB_UNIT;
ffffffffc02024fe:	e794                	sd	a3,8(a5)
		Slubs[i].wait.nr_partial = 0;
ffffffffc0202500:	0007b823          	sd	zero,16(a5)
		Slubs[i].wait.nr_slabs   = 0;
ffffffffc0202504:	0007bc23          	sd	zero,24(a5)
		Slubs[i].wait.partial    = NULL;
ffffffffc0202508:	0207b023          	sd	zero,32(a5)
		Slubs[i].wait.full       = NULL;
ffffffffc020250c:	0207b423          	sd	zero,40(a5)
		Slubs[i].work.freelist   = NULL;
ffffffffc0202510:	0207bc23          	sd	zero,56(a5)
		Slubs[i].work.pages 	 = NULL;
ffffffffc0202514:	0207b823          	sd	zero,48(a5)
	for(int i=0,size=(1<<Slubs_min_order);i<Slubs_size;i++,size=(size<<1)) // 遍历初始化Slubs
ffffffffc0202518:	04078793          	addi	a5,a5,64
ffffffffc020251c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0202520:	fcc79ce3          	bne	a5,a2,ffffffffc02024f8 <slub_init+0x38>
	cprintf("################################################################################\n");
ffffffffc0202524:	00003517          	auipc	a0,0x3
ffffffffc0202528:	d0c50513          	addi	a0,a0,-756 # ffffffffc0205230 <commands+0x708>
ffffffffc020252c:	ba1fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
	cprintf("[自检程序]启动slub内存管理器的启动自检程序\n");
ffffffffc0202530:	00003517          	auipc	a0,0x3
ffffffffc0202534:	6f850513          	addi	a0,a0,1784 # ffffffffc0205c28 <buddy_system_pmm_manager+0x6a8>
ffffffffc0202538:	b95fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
	assert(Slubs[i].size==up_size && size<=Slubs[i].obj_size);
ffffffffc020253c:	10043703          	ld	a4,256(s0)
ffffffffc0202540:	40000793          	li	a5,1024
ffffffffc0202544:	16f71263          	bne	a4,a5,ffffffffc02026a8 <slub_init+0x1e8>
ffffffffc0202548:	10843703          	ld	a4,264(s0)
ffffffffc020254c:	38300793          	li	a5,899
ffffffffc0202550:	14e7fc63          	bgeu	a5,a4,ffffffffc02026a8 <slub_init+0x1e8>
	return __kmalloc(size, 0);
ffffffffc0202554:	38400513          	li	a0,900
ffffffffc0202558:	d5dff0ef          	jal	ra,ffffffffc02022b4 <__kmalloc.constprop.0>
	assert(Slubs[i].work.pages!=NULL);
ffffffffc020255c:	13043783          	ld	a5,304(s0)
	return __kmalloc(size, 0);
ffffffffc0202560:	8baa                	mv	s7,a0
	assert(Slubs[i].work.pages!=NULL);
ffffffffc0202562:	1c078363          	beqz	a5,ffffffffc0202728 <slub_init+0x268>
	return __kmalloc(size, 0);
ffffffffc0202566:	38400513          	li	a0,900
ffffffffc020256a:	d4bff0ef          	jal	ra,ffffffffc02022b4 <__kmalloc.constprop.0>
ffffffffc020256e:	8a2a                	mv	s4,a0
ffffffffc0202570:	38400513          	li	a0,900
ffffffffc0202574:	d41ff0ef          	jal	ra,ffffffffc02022b4 <__kmalloc.constprop.0>
ffffffffc0202578:	89aa                	mv	s3,a0
ffffffffc020257a:	38400513          	li	a0,900
ffffffffc020257e:	d37ff0ef          	jal	ra,ffffffffc02022b4 <__kmalloc.constprop.0>
	assert(x1+up_size==x2&&x2+up_size==x3&&x3+up_size==x4);
ffffffffc0202582:	400b8793          	addi	a5,s7,1024
	return __kmalloc(size, 0);
ffffffffc0202586:	8b2a                	mv	s6,a0
	assert(x1+up_size==x2&&x2+up_size==x3&&x3+up_size==x4);
ffffffffc0202588:	16fa1063          	bne	s4,a5,ffffffffc02026e8 <slub_init+0x228>
ffffffffc020258c:	400a0793          	addi	a5,s4,1024
ffffffffc0202590:	14f99c63          	bne	s3,a5,ffffffffc02026e8 <slub_init+0x228>
ffffffffc0202594:	40098793          	addi	a5,s3,1024
ffffffffc0202598:	14f51863          	bne	a0,a5,ffffffffc02026e8 <slub_init+0x228>
	return __kmalloc(size, 0);
ffffffffc020259c:	38400513          	li	a0,900
ffffffffc02025a0:	d15ff0ef          	jal	ra,ffffffffc02022b4 <__kmalloc.constprop.0>
	kfree(y1);				// 工作区释放后为空(释放物理页）
ffffffffc02025a4:	e1fff0ef          	jal	ra,ffffffffc02023c2 <kfree>
	return __kmalloc(size, 0);
ffffffffc02025a8:	38400513          	li	a0,900
ffffffffc02025ac:	d09ff0ef          	jal	ra,ffffffffc02022b4 <__kmalloc.constprop.0>
ffffffffc02025b0:	8c2a                	mv	s8,a0
ffffffffc02025b2:	38400513          	li	a0,900
ffffffffc02025b6:	cffff0ef          	jal	ra,ffffffffc02022b4 <__kmalloc.constprop.0>
ffffffffc02025ba:	892a                	mv	s2,a0
ffffffffc02025bc:	38400513          	li	a0,900
ffffffffc02025c0:	cf5ff0ef          	jal	ra,ffffffffc02022b4 <__kmalloc.constprop.0>
ffffffffc02025c4:	84aa                	mv	s1,a0
ffffffffc02025c6:	38400513          	li	a0,900
ffffffffc02025ca:	cebff0ef          	jal	ra,ffffffffc02022b4 <__kmalloc.constprop.0>
	assert(y1+up_size==y2&&y2+up_size==y3&&y3+up_size==y4);
ffffffffc02025ce:	400c0793          	addi	a5,s8,1024
	return __kmalloc(size, 0);
ffffffffc02025d2:	8aaa                	mv	s5,a0
	assert(y1+up_size==y2&&y2+up_size==y3&&y3+up_size==y4);
ffffffffc02025d4:	0ef91a63          	bne	s2,a5,ffffffffc02026c8 <slub_init+0x208>
ffffffffc02025d8:	40090793          	addi	a5,s2,1024 # 1400 <kern_entry-0xffffffffc01fec00>
ffffffffc02025dc:	0ef49663          	bne	s1,a5,ffffffffc02026c8 <slub_init+0x208>
ffffffffc02025e0:	40048793          	addi	a5,s1,1024
ffffffffc02025e4:	0ef51263          	bne	a0,a5,ffffffffc02026c8 <slub_init+0x208>
	kfree(y1);				// 等待区full链表释放(放入等待区partial链表)
ffffffffc02025e8:	8562                	mv	a0,s8
ffffffffc02025ea:	dd9ff0ef          	jal	ra,ffffffffc02023c2 <kfree>
	kfree(x1);				// 等待区full链表释放(放入等待区partial链表)
ffffffffc02025ee:	855e                	mv	a0,s7
ffffffffc02025f0:	dd3ff0ef          	jal	ra,ffffffffc02023c2 <kfree>
	kfree(x2);				// 等待区partial链表释放
ffffffffc02025f4:	8552                	mv	a0,s4
ffffffffc02025f6:	dcdff0ef          	jal	ra,ffffffffc02023c2 <kfree>
	kfree(x3);				// 等待区partial链表释放
ffffffffc02025fa:	854e                	mv	a0,s3
ffffffffc02025fc:	dc7ff0ef          	jal	ra,ffffffffc02023c2 <kfree>
	kfree(x4);				// 等待区partial链表释放为空(释放物理页）
ffffffffc0202600:	855a                	mv	a0,s6
ffffffffc0202602:	dc1ff0ef          	jal	ra,ffffffffc02023c2 <kfree>
	kfree(y2);				// 等待区full链表释放(放入等待区partial链表)
ffffffffc0202606:	854a                	mv	a0,s2
ffffffffc0202608:	dbbff0ef          	jal	ra,ffffffffc02023c2 <kfree>
	return __kmalloc(size, 0);
ffffffffc020260c:	38400513          	li	a0,900
ffffffffc0202610:	ca5ff0ef          	jal	ra,ffffffffc02022b4 <__kmalloc.constprop.0>
	kfree(y2);				// 工作区释放                                                     
ffffffffc0202614:	dafff0ef          	jal	ra,ffffffffc02023c2 <kfree>
	kfree(y3);				// 工作区释放
ffffffffc0202618:	8526                	mv	a0,s1
ffffffffc020261a:	da9ff0ef          	jal	ra,ffffffffc02023c2 <kfree>
	kfree(y4);				// 工作区释放后为空(释放物理页）
ffffffffc020261e:	8556                	mv	a0,s5
ffffffffc0202620:	da3ff0ef          	jal	ra,ffffffffc02023c2 <kfree>
	assert(Slubs[i].work.pages==NULL);
ffffffffc0202624:	13043783          	ld	a5,304(s0)
ffffffffc0202628:	0e079063          	bnez	a5,ffffffffc0202708 <slub_init+0x248>
	return __kmalloc(size, 0);
ffffffffc020262c:	6505                	lui	a0,0x1
ffffffffc020262e:	c87ff0ef          	jal	ra,ffffffffc02022b4 <__kmalloc.constprop.0>
	kfree(x1);
ffffffffc0202632:	d91ff0ef          	jal	ra,ffffffffc02023c2 <kfree>
	return __kmalloc(size, 0);
ffffffffc0202636:	6505                	lui	a0,0x1
ffffffffc0202638:	c7dff0ef          	jal	ra,ffffffffc02022b4 <__kmalloc.constprop.0>
ffffffffc020263c:	89aa                	mv	s3,a0
ffffffffc020263e:	6505                	lui	a0,0x1
ffffffffc0202640:	c75ff0ef          	jal	ra,ffffffffc02022b4 <__kmalloc.constprop.0>
ffffffffc0202644:	892a                	mv	s2,a0
ffffffffc0202646:	6509                	lui	a0,0x2
ffffffffc0202648:	c6dff0ef          	jal	ra,ffffffffc02022b4 <__kmalloc.constprop.0>
ffffffffc020264c:	84aa                	mv	s1,a0
ffffffffc020264e:	6551                	lui	a0,0x14
ffffffffc0202650:	c65ff0ef          	jal	ra,ffffffffc02022b4 <__kmalloc.constprop.0>
ffffffffc0202654:	842a                	mv	s0,a0
	kfree(x1);
ffffffffc0202656:	854e                	mv	a0,s3
ffffffffc0202658:	d6bff0ef          	jal	ra,ffffffffc02023c2 <kfree>
	kfree(x2);
ffffffffc020265c:	854a                	mv	a0,s2
ffffffffc020265e:	d65ff0ef          	jal	ra,ffffffffc02023c2 <kfree>
	kfree(x3);
ffffffffc0202662:	8526                	mv	a0,s1
ffffffffc0202664:	d5fff0ef          	jal	ra,ffffffffc02023c2 <kfree>
	kfree(x4);
ffffffffc0202668:	8522                	mv	a0,s0
ffffffffc020266a:	d59ff0ef          	jal	ra,ffffffffc02023c2 <kfree>
	cprintf("[自检程序]退出slub内存管理器的启动自检程序\n");
ffffffffc020266e:	00003517          	auipc	a0,0x3
ffffffffc0202672:	6d250513          	addi	a0,a0,1746 # ffffffffc0205d40 <buddy_system_pmm_manager+0x7c0>
ffffffffc0202676:	a57fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
	cprintf("[自检程序]slub内存管理器的工作正常\n");
ffffffffc020267a:	00003517          	auipc	a0,0x3
ffffffffc020267e:	70650513          	addi	a0,a0,1798 # ffffffffc0205d80 <buddy_system_pmm_manager+0x800>
ffffffffc0202682:	a4bfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0202686:	6406                	ld	s0,64(sp)
ffffffffc0202688:	60a6                	ld	ra,72(sp)
ffffffffc020268a:	74e2                	ld	s1,56(sp)
ffffffffc020268c:	7942                	ld	s2,48(sp)
ffffffffc020268e:	79a2                	ld	s3,40(sp)
ffffffffc0202690:	7a02                	ld	s4,32(sp)
ffffffffc0202692:	6ae2                	ld	s5,24(sp)
ffffffffc0202694:	6b42                	ld	s6,16(sp)
ffffffffc0202696:	6ba2                	ld	s7,8(sp)
ffffffffc0202698:	6c02                	ld	s8,0(sp)
	cprintf("################################################################################\n");
ffffffffc020269a:	00003517          	auipc	a0,0x3
ffffffffc020269e:	b9650513          	addi	a0,a0,-1130 # ffffffffc0205230 <commands+0x708>
}
ffffffffc02026a2:	6161                	addi	sp,sp,80
	cprintf("################################################################################\n");
ffffffffc02026a4:	a29fd06f          	j	ffffffffc02000cc <cprintf>
	assert(Slubs[i].size==up_size && size<=Slubs[i].obj_size);
ffffffffc02026a8:	00003697          	auipc	a3,0x3
ffffffffc02026ac:	5c068693          	addi	a3,a3,1472 # ffffffffc0205c68 <buddy_system_pmm_manager+0x6e8>
ffffffffc02026b0:	00003617          	auipc	a2,0x3
ffffffffc02026b4:	c4860613          	addi	a2,a2,-952 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02026b8:	2e500593          	li	a1,741
ffffffffc02026bc:	00003517          	auipc	a0,0x3
ffffffffc02026c0:	49c50513          	addi	a0,a0,1180 # ffffffffc0205b58 <buddy_system_pmm_manager+0x5d8>
ffffffffc02026c4:	b05fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
	assert(y1+up_size==y2&&y2+up_size==y3&&y3+up_size==y4);
ffffffffc02026c8:	00003697          	auipc	a3,0x3
ffffffffc02026cc:	62868693          	addi	a3,a3,1576 # ffffffffc0205cf0 <buddy_system_pmm_manager+0x770>
ffffffffc02026d0:	00003617          	auipc	a2,0x3
ffffffffc02026d4:	c2860613          	addi	a2,a2,-984 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02026d8:	2fb00593          	li	a1,763
ffffffffc02026dc:	00003517          	auipc	a0,0x3
ffffffffc02026e0:	47c50513          	addi	a0,a0,1148 # ffffffffc0205b58 <buddy_system_pmm_manager+0x5d8>
ffffffffc02026e4:	ae5fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
	assert(x1+up_size==x2&&x2+up_size==x3&&x3+up_size==x4);
ffffffffc02026e8:	00003697          	auipc	a3,0x3
ffffffffc02026ec:	5d868693          	addi	a3,a3,1496 # ffffffffc0205cc0 <buddy_system_pmm_manager+0x740>
ffffffffc02026f0:	00003617          	auipc	a2,0x3
ffffffffc02026f4:	c0860613          	addi	a2,a2,-1016 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02026f8:	2ee00593          	li	a1,750
ffffffffc02026fc:	00003517          	auipc	a0,0x3
ffffffffc0202700:	45c50513          	addi	a0,a0,1116 # ffffffffc0205b58 <buddy_system_pmm_manager+0x5d8>
ffffffffc0202704:	ac5fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
	assert(Slubs[i].work.pages==NULL);
ffffffffc0202708:	00003697          	auipc	a3,0x3
ffffffffc020270c:	61868693          	addi	a3,a3,1560 # ffffffffc0205d20 <buddy_system_pmm_manager+0x7a0>
ffffffffc0202710:	00003617          	auipc	a2,0x3
ffffffffc0202714:	be860613          	addi	a2,a2,-1048 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0202718:	30c00593          	li	a1,780
ffffffffc020271c:	00003517          	auipc	a0,0x3
ffffffffc0202720:	43c50513          	addi	a0,a0,1084 # ffffffffc0205b58 <buddy_system_pmm_manager+0x5d8>
ffffffffc0202724:	aa5fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
	assert(Slubs[i].work.pages!=NULL);
ffffffffc0202728:	00003697          	auipc	a3,0x3
ffffffffc020272c:	57868693          	addi	a3,a3,1400 # ffffffffc0205ca0 <buddy_system_pmm_manager+0x720>
ffffffffc0202730:	00003617          	auipc	a2,0x3
ffffffffc0202734:	bc860613          	addi	a2,a2,-1080 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0202738:	2e800593          	li	a1,744
ffffffffc020273c:	00003517          	auipc	a0,0x3
ffffffffc0202740:	41c50513          	addi	a0,a0,1052 # ffffffffc0205b58 <buddy_system_pmm_manager+0x5d8>
ffffffffc0202744:	a85fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202748 <kmalloc_init>:
{
ffffffffc0202748:	1141                	addi	sp,sp,-16
ffffffffc020274a:	e406                	sd	ra,8(sp)
	if(USING_SLUB) slub_init();
ffffffffc020274c:	d75ff0ef          	jal	ra,ffffffffc02024c0 <slub_init>
}
ffffffffc0202750:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0202752:	00003517          	auipc	a0,0x3
ffffffffc0202756:	66650513          	addi	a0,a0,1638 # ffffffffc0205db8 <buddy_system_pmm_manager+0x838>
}
ffffffffc020275a:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc020275c:	971fd06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0202760 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202760:	1101                	addi	sp,sp,-32
ffffffffc0202762:	ec06                	sd	ra,24(sp)
ffffffffc0202764:	e822                	sd	s0,16(sp)
ffffffffc0202766:	e426                	sd	s1,8(sp)
     swapfs_init();
ffffffffc0202768:	390010ef          	jal	ra,ffffffffc0203af8 <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020276c:	00013697          	auipc	a3,0x13
ffffffffc0202770:	edc6b683          	ld	a3,-292(a3) # ffffffffc0215648 <max_swap_offset>
ffffffffc0202774:	010007b7          	lui	a5,0x1000
ffffffffc0202778:	ff968713          	addi	a4,a3,-7
ffffffffc020277c:	17e1                	addi	a5,a5,-8
ffffffffc020277e:	04e7e863          	bltu	a5,a4,ffffffffc02027ce <swap_init+0x6e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0202782:	00008797          	auipc	a5,0x8
ffffffffc0202786:	87e78793          	addi	a5,a5,-1922 # ffffffffc020a000 <swap_manager_fifo>
     int r = sm->init();
ffffffffc020278a:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc020278c:	00013497          	auipc	s1,0x13
ffffffffc0202790:	ec448493          	addi	s1,s1,-316 # ffffffffc0215650 <sm>
ffffffffc0202794:	e09c                	sd	a5,0(s1)
     int r = sm->init();
ffffffffc0202796:	9702                	jalr	a4
ffffffffc0202798:	842a                	mv	s0,a0
     
     if (r == 0)
ffffffffc020279a:	c519                	beqz	a0,ffffffffc02027a8 <swap_init+0x48>
          cprintf("SWAP: manager = %s\n", sm->name);
          //check_swap();  //这个测试程序针对链表型内存管理器，使用伙伴管理时应注释掉
     }

     return r;
}
ffffffffc020279c:	60e2                	ld	ra,24(sp)
ffffffffc020279e:	8522                	mv	a0,s0
ffffffffc02027a0:	6442                	ld	s0,16(sp)
ffffffffc02027a2:	64a2                	ld	s1,8(sp)
ffffffffc02027a4:	6105                	addi	sp,sp,32
ffffffffc02027a6:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02027a8:	609c                	ld	a5,0(s1)
ffffffffc02027aa:	00003517          	auipc	a0,0x3
ffffffffc02027ae:	65e50513          	addi	a0,a0,1630 # ffffffffc0205e08 <buddy_system_pmm_manager+0x888>
ffffffffc02027b2:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02027b4:	4785                	li	a5,1
ffffffffc02027b6:	00013717          	auipc	a4,0x13
ffffffffc02027ba:	eaf72123          	sw	a5,-350(a4) # ffffffffc0215658 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02027be:	90ffd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02027c2:	60e2                	ld	ra,24(sp)
ffffffffc02027c4:	8522                	mv	a0,s0
ffffffffc02027c6:	6442                	ld	s0,16(sp)
ffffffffc02027c8:	64a2                	ld	s1,8(sp)
ffffffffc02027ca:	6105                	addi	sp,sp,32
ffffffffc02027cc:	8082                	ret
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc02027ce:	00003617          	auipc	a2,0x3
ffffffffc02027d2:	60a60613          	addi	a2,a2,1546 # ffffffffc0205dd8 <buddy_system_pmm_manager+0x858>
ffffffffc02027d6:	02a00593          	li	a1,42
ffffffffc02027da:	00003517          	auipc	a0,0x3
ffffffffc02027de:	61e50513          	addi	a0,a0,1566 # ffffffffc0205df8 <buddy_system_pmm_manager+0x878>
ffffffffc02027e2:	9e7fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02027e6 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
     return sm->init_mm(mm);
ffffffffc02027e6:	00013797          	auipc	a5,0x13
ffffffffc02027ea:	e6a7b783          	ld	a5,-406(a5) # ffffffffc0215650 <sm>
ffffffffc02027ee:	6b9c                	ld	a5,16(a5)
ffffffffc02027f0:	8782                	jr	a5

ffffffffc02027f2 <swap_map_swappable>:
}

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02027f2:	00013797          	auipc	a5,0x13
ffffffffc02027f6:	e5e7b783          	ld	a5,-418(a5) # ffffffffc0215650 <sm>
ffffffffc02027fa:	739c                	ld	a5,32(a5)
ffffffffc02027fc:	8782                	jr	a5

ffffffffc02027fe <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
ffffffffc02027fe:	711d                	addi	sp,sp,-96
ffffffffc0202800:	ec86                	sd	ra,88(sp)
ffffffffc0202802:	e8a2                	sd	s0,80(sp)
ffffffffc0202804:	e4a6                	sd	s1,72(sp)
ffffffffc0202806:	e0ca                	sd	s2,64(sp)
ffffffffc0202808:	fc4e                	sd	s3,56(sp)
ffffffffc020280a:	f852                	sd	s4,48(sp)
ffffffffc020280c:	f456                	sd	s5,40(sp)
ffffffffc020280e:	f05a                	sd	s6,32(sp)
ffffffffc0202810:	ec5e                	sd	s7,24(sp)
ffffffffc0202812:	e862                	sd	s8,16(sp)
     int i;
     for (i = 0; i != n; ++ i)
ffffffffc0202814:	cde9                	beqz	a1,ffffffffc02028ee <swap_out+0xf0>
ffffffffc0202816:	8a2e                	mv	s4,a1
ffffffffc0202818:	892a                	mv	s2,a0
ffffffffc020281a:	8ab2                	mv	s5,a2
ffffffffc020281c:	4401                	li	s0,0
ffffffffc020281e:	00013997          	auipc	s3,0x13
ffffffffc0202822:	e3298993          	addi	s3,s3,-462 # ffffffffc0215650 <sm>
                    cprintf("SWAP: failed to save\n");
                    sm->map_swappable(mm, v, page, 0);
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202826:	00003b17          	auipc	s6,0x3
ffffffffc020282a:	65ab0b13          	addi	s6,s6,1626 # ffffffffc0205e80 <buddy_system_pmm_manager+0x900>
                    cprintf("SWAP: failed to save\n");
ffffffffc020282e:	00003b97          	auipc	s7,0x3
ffffffffc0202832:	63ab8b93          	addi	s7,s7,1594 # ffffffffc0205e68 <buddy_system_pmm_manager+0x8e8>
ffffffffc0202836:	a825                	j	ffffffffc020286e <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202838:	67a2                	ld	a5,8(sp)
ffffffffc020283a:	8626                	mv	a2,s1
ffffffffc020283c:	85a2                	mv	a1,s0
ffffffffc020283e:	7f94                	ld	a3,56(a5)
ffffffffc0202840:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202842:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202844:	82b1                	srli	a3,a3,0xc
ffffffffc0202846:	0685                	addi	a3,a3,1
ffffffffc0202848:	885fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020284c:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc020284e:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202850:	7d1c                	ld	a5,56(a0)
ffffffffc0202852:	83b1                	srli	a5,a5,0xc
ffffffffc0202854:	0785                	addi	a5,a5,1
ffffffffc0202856:	07a2                	slli	a5,a5,0x8
ffffffffc0202858:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc020285c:	1fa000ef          	jal	ra,ffffffffc0202a56 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202860:	01893503          	ld	a0,24(s2)
ffffffffc0202864:	85a6                	mv	a1,s1
ffffffffc0202866:	1d4010ef          	jal	ra,ffffffffc0203a3a <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc020286a:	048a0d63          	beq	s4,s0,ffffffffc02028c4 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020286e:	0009b783          	ld	a5,0(s3)
ffffffffc0202872:	8656                	mv	a2,s5
ffffffffc0202874:	002c                	addi	a1,sp,8
ffffffffc0202876:	7b9c                	ld	a5,48(a5)
ffffffffc0202878:	854a                	mv	a0,s2
ffffffffc020287a:	9782                	jalr	a5
          if (r != 0) {
ffffffffc020287c:	e12d                	bnez	a0,ffffffffc02028de <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc020287e:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202880:	01893503          	ld	a0,24(s2)
ffffffffc0202884:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202886:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202888:	85a6                	mv	a1,s1
ffffffffc020288a:	246000ef          	jal	ra,ffffffffc0202ad0 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc020288e:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202890:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202892:	8b85                	andi	a5,a5,1
ffffffffc0202894:	cfb9                	beqz	a5,ffffffffc02028f2 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202896:	65a2                	ld	a1,8(sp)
ffffffffc0202898:	7d9c                	ld	a5,56(a1)
ffffffffc020289a:	83b1                	srli	a5,a5,0xc
ffffffffc020289c:	0785                	addi	a5,a5,1
ffffffffc020289e:	00879513          	slli	a0,a5,0x8
ffffffffc02028a2:	31c010ef          	jal	ra,ffffffffc0203bbe <swapfs_write>
ffffffffc02028a6:	d949                	beqz	a0,ffffffffc0202838 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc02028a8:	855e                	mv	a0,s7
ffffffffc02028aa:	823fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02028ae:	0009b783          	ld	a5,0(s3)
ffffffffc02028b2:	6622                	ld	a2,8(sp)
ffffffffc02028b4:	4681                	li	a3,0
ffffffffc02028b6:	739c                	ld	a5,32(a5)
ffffffffc02028b8:	85a6                	mv	a1,s1
ffffffffc02028ba:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc02028bc:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02028be:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc02028c0:	fa8a17e3          	bne	s4,s0,ffffffffc020286e <swap_out+0x70>
     }
     return i;
}
ffffffffc02028c4:	60e6                	ld	ra,88(sp)
ffffffffc02028c6:	8522                	mv	a0,s0
ffffffffc02028c8:	6446                	ld	s0,80(sp)
ffffffffc02028ca:	64a6                	ld	s1,72(sp)
ffffffffc02028cc:	6906                	ld	s2,64(sp)
ffffffffc02028ce:	79e2                	ld	s3,56(sp)
ffffffffc02028d0:	7a42                	ld	s4,48(sp)
ffffffffc02028d2:	7aa2                	ld	s5,40(sp)
ffffffffc02028d4:	7b02                	ld	s6,32(sp)
ffffffffc02028d6:	6be2                	ld	s7,24(sp)
ffffffffc02028d8:	6c42                	ld	s8,16(sp)
ffffffffc02028da:	6125                	addi	sp,sp,96
ffffffffc02028dc:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02028de:	85a2                	mv	a1,s0
ffffffffc02028e0:	00003517          	auipc	a0,0x3
ffffffffc02028e4:	54050513          	addi	a0,a0,1344 # ffffffffc0205e20 <buddy_system_pmm_manager+0x8a0>
ffffffffc02028e8:	fe4fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                  break;
ffffffffc02028ec:	bfe1                	j	ffffffffc02028c4 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02028ee:	4401                	li	s0,0
ffffffffc02028f0:	bfd1                	j	ffffffffc02028c4 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02028f2:	00003697          	auipc	a3,0x3
ffffffffc02028f6:	55e68693          	addi	a3,a3,1374 # ffffffffc0205e50 <buddy_system_pmm_manager+0x8d0>
ffffffffc02028fa:	00003617          	auipc	a2,0x3
ffffffffc02028fe:	9fe60613          	addi	a2,a2,-1538 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0202902:	06900593          	li	a1,105
ffffffffc0202906:	00003517          	auipc	a0,0x3
ffffffffc020290a:	4f250513          	addi	a0,a0,1266 # ffffffffc0205df8 <buddy_system_pmm_manager+0x878>
ffffffffc020290e:	8bbfd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202912 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
ffffffffc0202912:	7179                	addi	sp,sp,-48
ffffffffc0202914:	e84a                	sd	s2,16(sp)
ffffffffc0202916:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202918:	4505                	li	a0,1
{
ffffffffc020291a:	ec26                	sd	s1,24(sp)
ffffffffc020291c:	e44e                	sd	s3,8(sp)
ffffffffc020291e:	f406                	sd	ra,40(sp)
ffffffffc0202920:	f022                	sd	s0,32(sp)
ffffffffc0202922:	84ae                	mv	s1,a1
ffffffffc0202924:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202926:	09e000ef          	jal	ra,ffffffffc02029c4 <alloc_pages>
     assert(result!=NULL);
ffffffffc020292a:	c129                	beqz	a0,ffffffffc020296c <swap_in+0x5a>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020292c:	842a                	mv	s0,a0
ffffffffc020292e:	01893503          	ld	a0,24(s2)
ffffffffc0202932:	4601                	li	a2,0
ffffffffc0202934:	85a6                	mv	a1,s1
ffffffffc0202936:	19a000ef          	jal	ra,ffffffffc0202ad0 <get_pte>
ffffffffc020293a:	892a                	mv	s2,a0
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020293c:	6108                	ld	a0,0(a0)
ffffffffc020293e:	85a2                	mv	a1,s0
ffffffffc0202940:	1f0010ef          	jal	ra,ffffffffc0203b30 <swapfs_read>
     {
        assert(r!=0);
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202944:	00093583          	ld	a1,0(s2)
ffffffffc0202948:	8626                	mv	a2,s1
ffffffffc020294a:	00003517          	auipc	a0,0x3
ffffffffc020294e:	58650513          	addi	a0,a0,1414 # ffffffffc0205ed0 <buddy_system_pmm_manager+0x950>
ffffffffc0202952:	81a1                	srli	a1,a1,0x8
ffffffffc0202954:	f78fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     *ptr_result=result;
     return 0;
}
ffffffffc0202958:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc020295a:	0089b023          	sd	s0,0(s3)
}
ffffffffc020295e:	7402                	ld	s0,32(sp)
ffffffffc0202960:	64e2                	ld	s1,24(sp)
ffffffffc0202962:	6942                	ld	s2,16(sp)
ffffffffc0202964:	69a2                	ld	s3,8(sp)
ffffffffc0202966:	4501                	li	a0,0
ffffffffc0202968:	6145                	addi	sp,sp,48
ffffffffc020296a:	8082                	ret
     assert(result!=NULL);
ffffffffc020296c:	00003697          	auipc	a3,0x3
ffffffffc0202970:	55468693          	addi	a3,a3,1364 # ffffffffc0205ec0 <buddy_system_pmm_manager+0x940>
ffffffffc0202974:	00003617          	auipc	a2,0x3
ffffffffc0202978:	98460613          	addi	a2,a2,-1660 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020297c:	07f00593          	li	a1,127
ffffffffc0202980:	00003517          	auipc	a0,0x3
ffffffffc0202984:	47850513          	addi	a0,a0,1144 # ffffffffc0205df8 <buddy_system_pmm_manager+0x878>
ffffffffc0202988:	841fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020298c <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc020298c:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc020298e:	00003617          	auipc	a2,0x3
ffffffffc0202992:	e5a60613          	addi	a2,a2,-422 # ffffffffc02057e8 <buddy_system_pmm_manager+0x268>
ffffffffc0202996:	06200593          	li	a1,98
ffffffffc020299a:	00003517          	auipc	a0,0x3
ffffffffc020299e:	e6e50513          	addi	a0,a0,-402 # ffffffffc0205808 <buddy_system_pmm_manager+0x288>
pa2page(uintptr_t pa) {
ffffffffc02029a2:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02029a4:	825fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02029a8 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc02029a8:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02029aa:	00003617          	auipc	a2,0x3
ffffffffc02029ae:	56660613          	addi	a2,a2,1382 # ffffffffc0205f10 <buddy_system_pmm_manager+0x990>
ffffffffc02029b2:	07400593          	li	a1,116
ffffffffc02029b6:	00003517          	auipc	a0,0x3
ffffffffc02029ba:	e5250513          	addi	a0,a0,-430 # ffffffffc0205808 <buddy_system_pmm_manager+0x288>
pte2page(pte_t pte) {
ffffffffc02029be:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02029c0:	809fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02029c4 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02029c4:	7139                	addi	sp,sp,-64
ffffffffc02029c6:	f426                	sd	s1,40(sp)
ffffffffc02029c8:	f04a                	sd	s2,32(sp)
ffffffffc02029ca:	ec4e                	sd	s3,24(sp)
ffffffffc02029cc:	e852                	sd	s4,16(sp)
ffffffffc02029ce:	e456                	sd	s5,8(sp)
ffffffffc02029d0:	e05a                	sd	s6,0(sp)
ffffffffc02029d2:	fc06                	sd	ra,56(sp)
ffffffffc02029d4:	f822                	sd	s0,48(sp)
ffffffffc02029d6:	84aa                	mv	s1,a0
ffffffffc02029d8:	00013917          	auipc	s2,0x13
ffffffffc02029dc:	ca890913          	addi	s2,s2,-856 # ffffffffc0215680 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02029e0:	4a05                	li	s4,1
ffffffffc02029e2:	00013a97          	auipc	s5,0x13
ffffffffc02029e6:	c76a8a93          	addi	s5,s5,-906 # ffffffffc0215658 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02029ea:	0005099b          	sext.w	s3,a0
ffffffffc02029ee:	00013b17          	auipc	s6,0x13
ffffffffc02029f2:	c42b0b13          	addi	s6,s6,-958 # ffffffffc0215630 <check_mm_struct>
ffffffffc02029f6:	a01d                	j	ffffffffc0202a1c <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc02029f8:	00093783          	ld	a5,0(s2)
ffffffffc02029fc:	6f9c                	ld	a5,24(a5)
ffffffffc02029fe:	9782                	jalr	a5
ffffffffc0202a00:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a02:	4601                	li	a2,0
ffffffffc0202a04:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a06:	ec0d                	bnez	s0,ffffffffc0202a40 <alloc_pages+0x7c>
ffffffffc0202a08:	029a6c63          	bltu	s4,s1,ffffffffc0202a40 <alloc_pages+0x7c>
ffffffffc0202a0c:	000aa783          	lw	a5,0(s5)
ffffffffc0202a10:	2781                	sext.w	a5,a5
ffffffffc0202a12:	c79d                	beqz	a5,ffffffffc0202a40 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a14:	000b3503          	ld	a0,0(s6)
ffffffffc0202a18:	de7ff0ef          	jal	ra,ffffffffc02027fe <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202a1c:	100027f3          	csrr	a5,sstatus
ffffffffc0202a20:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0202a22:	8526                	mv	a0,s1
ffffffffc0202a24:	dbf1                	beqz	a5,ffffffffc02029f8 <alloc_pages+0x34>
        intr_disable();
ffffffffc0202a26:	b9ffd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0202a2a:	00093783          	ld	a5,0(s2)
ffffffffc0202a2e:	8526                	mv	a0,s1
ffffffffc0202a30:	6f9c                	ld	a5,24(a5)
ffffffffc0202a32:	9782                	jalr	a5
ffffffffc0202a34:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202a36:	b89fd0ef          	jal	ra,ffffffffc02005be <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a3a:	4601                	li	a2,0
ffffffffc0202a3c:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a3e:	d469                	beqz	s0,ffffffffc0202a08 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0202a40:	70e2                	ld	ra,56(sp)
ffffffffc0202a42:	8522                	mv	a0,s0
ffffffffc0202a44:	7442                	ld	s0,48(sp)
ffffffffc0202a46:	74a2                	ld	s1,40(sp)
ffffffffc0202a48:	7902                	ld	s2,32(sp)
ffffffffc0202a4a:	69e2                	ld	s3,24(sp)
ffffffffc0202a4c:	6a42                	ld	s4,16(sp)
ffffffffc0202a4e:	6aa2                	ld	s5,8(sp)
ffffffffc0202a50:	6b02                	ld	s6,0(sp)
ffffffffc0202a52:	6121                	addi	sp,sp,64
ffffffffc0202a54:	8082                	ret

ffffffffc0202a56 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202a56:	100027f3          	csrr	a5,sstatus
ffffffffc0202a5a:	8b89                	andi	a5,a5,2
ffffffffc0202a5c:	e799                	bnez	a5,ffffffffc0202a6a <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0202a5e:	00013797          	auipc	a5,0x13
ffffffffc0202a62:	c227b783          	ld	a5,-990(a5) # ffffffffc0215680 <pmm_manager>
ffffffffc0202a66:	739c                	ld	a5,32(a5)
ffffffffc0202a68:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0202a6a:	1101                	addi	sp,sp,-32
ffffffffc0202a6c:	ec06                	sd	ra,24(sp)
ffffffffc0202a6e:	e822                	sd	s0,16(sp)
ffffffffc0202a70:	e426                	sd	s1,8(sp)
ffffffffc0202a72:	842a                	mv	s0,a0
ffffffffc0202a74:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202a76:	b4ffd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202a7a:	00013797          	auipc	a5,0x13
ffffffffc0202a7e:	c067b783          	ld	a5,-1018(a5) # ffffffffc0215680 <pmm_manager>
ffffffffc0202a82:	739c                	ld	a5,32(a5)
ffffffffc0202a84:	85a6                	mv	a1,s1
ffffffffc0202a86:	8522                	mv	a0,s0
ffffffffc0202a88:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0202a8a:	6442                	ld	s0,16(sp)
ffffffffc0202a8c:	60e2                	ld	ra,24(sp)
ffffffffc0202a8e:	64a2                	ld	s1,8(sp)
ffffffffc0202a90:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202a92:	b2dfd06f          	j	ffffffffc02005be <intr_enable>

ffffffffc0202a96 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202a96:	100027f3          	csrr	a5,sstatus
ffffffffc0202a9a:	8b89                	andi	a5,a5,2
ffffffffc0202a9c:	e799                	bnez	a5,ffffffffc0202aaa <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0202a9e:	00013797          	auipc	a5,0x13
ffffffffc0202aa2:	be27b783          	ld	a5,-1054(a5) # ffffffffc0215680 <pmm_manager>
ffffffffc0202aa6:	779c                	ld	a5,40(a5)
ffffffffc0202aa8:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0202aaa:	1141                	addi	sp,sp,-16
ffffffffc0202aac:	e406                	sd	ra,8(sp)
ffffffffc0202aae:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0202ab0:	b15fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ab4:	00013797          	auipc	a5,0x13
ffffffffc0202ab8:	bcc7b783          	ld	a5,-1076(a5) # ffffffffc0215680 <pmm_manager>
ffffffffc0202abc:	779c                	ld	a5,40(a5)
ffffffffc0202abe:	9782                	jalr	a5
ffffffffc0202ac0:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202ac2:	afdfd0ef          	jal	ra,ffffffffc02005be <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202ac6:	60a2                	ld	ra,8(sp)
ffffffffc0202ac8:	8522                	mv	a0,s0
ffffffffc0202aca:	6402                	ld	s0,0(sp)
ffffffffc0202acc:	0141                	addi	sp,sp,16
ffffffffc0202ace:	8082                	ret

ffffffffc0202ad0 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202ad0:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202ad4:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202ad8:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202ada:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202adc:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202ade:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202ae2:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202ae4:	f04a                	sd	s2,32(sp)
ffffffffc0202ae6:	ec4e                	sd	s3,24(sp)
ffffffffc0202ae8:	e852                	sd	s4,16(sp)
ffffffffc0202aea:	fc06                	sd	ra,56(sp)
ffffffffc0202aec:	f822                	sd	s0,48(sp)
ffffffffc0202aee:	e456                	sd	s5,8(sp)
ffffffffc0202af0:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202af2:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202af6:	892e                	mv	s2,a1
ffffffffc0202af8:	89b2                	mv	s3,a2
ffffffffc0202afa:	00013a17          	auipc	s4,0x13
ffffffffc0202afe:	b76a0a13          	addi	s4,s4,-1162 # ffffffffc0215670 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202b02:	e7b5                	bnez	a5,ffffffffc0202b6e <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202b04:	12060b63          	beqz	a2,ffffffffc0202c3a <get_pte+0x16a>
ffffffffc0202b08:	4505                	li	a0,1
ffffffffc0202b0a:	ebbff0ef          	jal	ra,ffffffffc02029c4 <alloc_pages>
ffffffffc0202b0e:	842a                	mv	s0,a0
ffffffffc0202b10:	12050563          	beqz	a0,ffffffffc0202c3a <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0202b14:	00013b17          	auipc	s6,0x13
ffffffffc0202b18:	b64b0b13          	addi	s6,s6,-1180 # ffffffffc0215678 <pages>
ffffffffc0202b1c:	000b3503          	ld	a0,0(s6)
ffffffffc0202b20:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202b24:	00013a17          	auipc	s4,0x13
ffffffffc0202b28:	b4ca0a13          	addi	s4,s4,-1204 # ffffffffc0215670 <npage>
ffffffffc0202b2c:	40a40533          	sub	a0,s0,a0
ffffffffc0202b30:	8519                	srai	a0,a0,0x6
ffffffffc0202b32:	9556                	add	a0,a0,s5
ffffffffc0202b34:	000a3703          	ld	a4,0(s4)
ffffffffc0202b38:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0202b3c:	4685                	li	a3,1
ffffffffc0202b3e:	c014                	sw	a3,0(s0)
ffffffffc0202b40:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b42:	0532                	slli	a0,a0,0xc
ffffffffc0202b44:	14e7f263          	bgeu	a5,a4,ffffffffc0202c88 <get_pte+0x1b8>
ffffffffc0202b48:	00013797          	auipc	a5,0x13
ffffffffc0202b4c:	b407b783          	ld	a5,-1216(a5) # ffffffffc0215688 <va_pa_offset>
ffffffffc0202b50:	6605                	lui	a2,0x1
ffffffffc0202b52:	4581                	li	a1,0
ffffffffc0202b54:	953e                	add	a0,a0,a5
ffffffffc0202b56:	0f5010ef          	jal	ra,ffffffffc020444a <memset>
    return page - pages + nbase;
ffffffffc0202b5a:	000b3683          	ld	a3,0(s6)
ffffffffc0202b5e:	40d406b3          	sub	a3,s0,a3
ffffffffc0202b62:	8699                	srai	a3,a3,0x6
ffffffffc0202b64:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202b66:	06aa                	slli	a3,a3,0xa
ffffffffc0202b68:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202b6c:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202b6e:	77fd                	lui	a5,0xfffff
ffffffffc0202b70:	068a                	slli	a3,a3,0x2
ffffffffc0202b72:	000a3703          	ld	a4,0(s4)
ffffffffc0202b76:	8efd                	and	a3,a3,a5
ffffffffc0202b78:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202b7c:	0ce7f163          	bgeu	a5,a4,ffffffffc0202c3e <get_pte+0x16e>
ffffffffc0202b80:	00013a97          	auipc	s5,0x13
ffffffffc0202b84:	b08a8a93          	addi	s5,s5,-1272 # ffffffffc0215688 <va_pa_offset>
ffffffffc0202b88:	000ab403          	ld	s0,0(s5)
ffffffffc0202b8c:	01595793          	srli	a5,s2,0x15
ffffffffc0202b90:	1ff7f793          	andi	a5,a5,511
ffffffffc0202b94:	96a2                	add	a3,a3,s0
ffffffffc0202b96:	00379413          	slli	s0,a5,0x3
ffffffffc0202b9a:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0202b9c:	6014                	ld	a3,0(s0)
ffffffffc0202b9e:	0016f793          	andi	a5,a3,1
ffffffffc0202ba2:	e3ad                	bnez	a5,ffffffffc0202c04 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202ba4:	08098b63          	beqz	s3,ffffffffc0202c3a <get_pte+0x16a>
ffffffffc0202ba8:	4505                	li	a0,1
ffffffffc0202baa:	e1bff0ef          	jal	ra,ffffffffc02029c4 <alloc_pages>
ffffffffc0202bae:	84aa                	mv	s1,a0
ffffffffc0202bb0:	c549                	beqz	a0,ffffffffc0202c3a <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0202bb2:	00013b17          	auipc	s6,0x13
ffffffffc0202bb6:	ac6b0b13          	addi	s6,s6,-1338 # ffffffffc0215678 <pages>
ffffffffc0202bba:	000b3503          	ld	a0,0(s6)
ffffffffc0202bbe:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202bc2:	000a3703          	ld	a4,0(s4)
ffffffffc0202bc6:	40a48533          	sub	a0,s1,a0
ffffffffc0202bca:	8519                	srai	a0,a0,0x6
ffffffffc0202bcc:	954e                	add	a0,a0,s3
ffffffffc0202bce:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0202bd2:	4685                	li	a3,1
ffffffffc0202bd4:	c094                	sw	a3,0(s1)
ffffffffc0202bd6:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202bd8:	0532                	slli	a0,a0,0xc
ffffffffc0202bda:	08e7fa63          	bgeu	a5,a4,ffffffffc0202c6e <get_pte+0x19e>
ffffffffc0202bde:	000ab783          	ld	a5,0(s5)
ffffffffc0202be2:	6605                	lui	a2,0x1
ffffffffc0202be4:	4581                	li	a1,0
ffffffffc0202be6:	953e                	add	a0,a0,a5
ffffffffc0202be8:	063010ef          	jal	ra,ffffffffc020444a <memset>
    return page - pages + nbase;
ffffffffc0202bec:	000b3683          	ld	a3,0(s6)
ffffffffc0202bf0:	40d486b3          	sub	a3,s1,a3
ffffffffc0202bf4:	8699                	srai	a3,a3,0x6
ffffffffc0202bf6:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202bf8:	06aa                	slli	a3,a3,0xa
ffffffffc0202bfa:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202bfe:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202c00:	000a3703          	ld	a4,0(s4)
ffffffffc0202c04:	068a                	slli	a3,a3,0x2
ffffffffc0202c06:	757d                	lui	a0,0xfffff
ffffffffc0202c08:	8ee9                	and	a3,a3,a0
ffffffffc0202c0a:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202c0e:	04e7f463          	bgeu	a5,a4,ffffffffc0202c56 <get_pte+0x186>
ffffffffc0202c12:	000ab503          	ld	a0,0(s5)
ffffffffc0202c16:	00c95913          	srli	s2,s2,0xc
ffffffffc0202c1a:	1ff97913          	andi	s2,s2,511
ffffffffc0202c1e:	96aa                	add	a3,a3,a0
ffffffffc0202c20:	00391513          	slli	a0,s2,0x3
ffffffffc0202c24:	9536                	add	a0,a0,a3
}
ffffffffc0202c26:	70e2                	ld	ra,56(sp)
ffffffffc0202c28:	7442                	ld	s0,48(sp)
ffffffffc0202c2a:	74a2                	ld	s1,40(sp)
ffffffffc0202c2c:	7902                	ld	s2,32(sp)
ffffffffc0202c2e:	69e2                	ld	s3,24(sp)
ffffffffc0202c30:	6a42                	ld	s4,16(sp)
ffffffffc0202c32:	6aa2                	ld	s5,8(sp)
ffffffffc0202c34:	6b02                	ld	s6,0(sp)
ffffffffc0202c36:	6121                	addi	sp,sp,64
ffffffffc0202c38:	8082                	ret
            return NULL;
ffffffffc0202c3a:	4501                	li	a0,0
ffffffffc0202c3c:	b7ed                	j	ffffffffc0202c26 <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202c3e:	00003617          	auipc	a2,0x3
ffffffffc0202c42:	bda60613          	addi	a2,a2,-1062 # ffffffffc0205818 <buddy_system_pmm_manager+0x298>
ffffffffc0202c46:	0f500593          	li	a1,245
ffffffffc0202c4a:	00003517          	auipc	a0,0x3
ffffffffc0202c4e:	2ee50513          	addi	a0,a0,750 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc0202c52:	d76fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202c56:	00003617          	auipc	a2,0x3
ffffffffc0202c5a:	bc260613          	addi	a2,a2,-1086 # ffffffffc0205818 <buddy_system_pmm_manager+0x298>
ffffffffc0202c5e:	10000593          	li	a1,256
ffffffffc0202c62:	00003517          	auipc	a0,0x3
ffffffffc0202c66:	2d650513          	addi	a0,a0,726 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc0202c6a:	d5efd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202c6e:	86aa                	mv	a3,a0
ffffffffc0202c70:	00003617          	auipc	a2,0x3
ffffffffc0202c74:	ba860613          	addi	a2,a2,-1112 # ffffffffc0205818 <buddy_system_pmm_manager+0x298>
ffffffffc0202c78:	0fd00593          	li	a1,253
ffffffffc0202c7c:	00003517          	auipc	a0,0x3
ffffffffc0202c80:	2bc50513          	addi	a0,a0,700 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc0202c84:	d44fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202c88:	86aa                	mv	a3,a0
ffffffffc0202c8a:	00003617          	auipc	a2,0x3
ffffffffc0202c8e:	b8e60613          	addi	a2,a2,-1138 # ffffffffc0205818 <buddy_system_pmm_manager+0x298>
ffffffffc0202c92:	0f200593          	li	a1,242
ffffffffc0202c96:	00003517          	auipc	a0,0x3
ffffffffc0202c9a:	2a250513          	addi	a0,a0,674 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc0202c9e:	d2afd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202ca2 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202ca2:	1141                	addi	sp,sp,-16
ffffffffc0202ca4:	e022                	sd	s0,0(sp)
ffffffffc0202ca6:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202ca8:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202caa:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202cac:	e25ff0ef          	jal	ra,ffffffffc0202ad0 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202cb0:	c011                	beqz	s0,ffffffffc0202cb4 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202cb2:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202cb4:	c511                	beqz	a0,ffffffffc0202cc0 <get_page+0x1e>
ffffffffc0202cb6:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202cb8:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202cba:	0017f713          	andi	a4,a5,1
ffffffffc0202cbe:	e709                	bnez	a4,ffffffffc0202cc8 <get_page+0x26>
}
ffffffffc0202cc0:	60a2                	ld	ra,8(sp)
ffffffffc0202cc2:	6402                	ld	s0,0(sp)
ffffffffc0202cc4:	0141                	addi	sp,sp,16
ffffffffc0202cc6:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202cc8:	078a                	slli	a5,a5,0x2
ffffffffc0202cca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ccc:	00013717          	auipc	a4,0x13
ffffffffc0202cd0:	9a473703          	ld	a4,-1628(a4) # ffffffffc0215670 <npage>
ffffffffc0202cd4:	00e7ff63          	bgeu	a5,a4,ffffffffc0202cf2 <get_page+0x50>
ffffffffc0202cd8:	60a2                	ld	ra,8(sp)
ffffffffc0202cda:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0202cdc:	fff80537          	lui	a0,0xfff80
ffffffffc0202ce0:	97aa                	add	a5,a5,a0
ffffffffc0202ce2:	079a                	slli	a5,a5,0x6
ffffffffc0202ce4:	00013517          	auipc	a0,0x13
ffffffffc0202ce8:	99453503          	ld	a0,-1644(a0) # ffffffffc0215678 <pages>
ffffffffc0202cec:	953e                	add	a0,a0,a5
ffffffffc0202cee:	0141                	addi	sp,sp,16
ffffffffc0202cf0:	8082                	ret
ffffffffc0202cf2:	c9bff0ef          	jal	ra,ffffffffc020298c <pa2page.part.0>

ffffffffc0202cf6 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202cf6:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202cf8:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202cfa:	ec26                	sd	s1,24(sp)
ffffffffc0202cfc:	f406                	sd	ra,40(sp)
ffffffffc0202cfe:	f022                	sd	s0,32(sp)
ffffffffc0202d00:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d02:	dcfff0ef          	jal	ra,ffffffffc0202ad0 <get_pte>
    if (ptep != NULL) {
ffffffffc0202d06:	c511                	beqz	a0,ffffffffc0202d12 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202d08:	611c                	ld	a5,0(a0)
ffffffffc0202d0a:	842a                	mv	s0,a0
ffffffffc0202d0c:	0017f713          	andi	a4,a5,1
ffffffffc0202d10:	e711                	bnez	a4,ffffffffc0202d1c <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0202d12:	70a2                	ld	ra,40(sp)
ffffffffc0202d14:	7402                	ld	s0,32(sp)
ffffffffc0202d16:	64e2                	ld	s1,24(sp)
ffffffffc0202d18:	6145                	addi	sp,sp,48
ffffffffc0202d1a:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202d1c:	078a                	slli	a5,a5,0x2
ffffffffc0202d1e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d20:	00013717          	auipc	a4,0x13
ffffffffc0202d24:	95073703          	ld	a4,-1712(a4) # ffffffffc0215670 <npage>
ffffffffc0202d28:	06e7f363          	bgeu	a5,a4,ffffffffc0202d8e <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d2c:	fff80537          	lui	a0,0xfff80
ffffffffc0202d30:	97aa                	add	a5,a5,a0
ffffffffc0202d32:	079a                	slli	a5,a5,0x6
ffffffffc0202d34:	00013517          	auipc	a0,0x13
ffffffffc0202d38:	94453503          	ld	a0,-1724(a0) # ffffffffc0215678 <pages>
ffffffffc0202d3c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202d3e:	411c                	lw	a5,0(a0)
ffffffffc0202d40:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202d44:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202d46:	cb11                	beqz	a4,ffffffffc0202d5a <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202d48:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202d4c:	12048073          	sfence.vma	s1
}
ffffffffc0202d50:	70a2                	ld	ra,40(sp)
ffffffffc0202d52:	7402                	ld	s0,32(sp)
ffffffffc0202d54:	64e2                	ld	s1,24(sp)
ffffffffc0202d56:	6145                	addi	sp,sp,48
ffffffffc0202d58:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202d5a:	100027f3          	csrr	a5,sstatus
ffffffffc0202d5e:	8b89                	andi	a5,a5,2
ffffffffc0202d60:	eb89                	bnez	a5,ffffffffc0202d72 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0202d62:	00013797          	auipc	a5,0x13
ffffffffc0202d66:	91e7b783          	ld	a5,-1762(a5) # ffffffffc0215680 <pmm_manager>
ffffffffc0202d6a:	739c                	ld	a5,32(a5)
ffffffffc0202d6c:	4585                	li	a1,1
ffffffffc0202d6e:	9782                	jalr	a5
    if (flag) {
ffffffffc0202d70:	bfe1                	j	ffffffffc0202d48 <page_remove+0x52>
        intr_disable();
ffffffffc0202d72:	e42a                	sd	a0,8(sp)
ffffffffc0202d74:	851fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0202d78:	00013797          	auipc	a5,0x13
ffffffffc0202d7c:	9087b783          	ld	a5,-1784(a5) # ffffffffc0215680 <pmm_manager>
ffffffffc0202d80:	739c                	ld	a5,32(a5)
ffffffffc0202d82:	6522                	ld	a0,8(sp)
ffffffffc0202d84:	4585                	li	a1,1
ffffffffc0202d86:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d88:	837fd0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0202d8c:	bf75                	j	ffffffffc0202d48 <page_remove+0x52>
ffffffffc0202d8e:	bffff0ef          	jal	ra,ffffffffc020298c <pa2page.part.0>

ffffffffc0202d92 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202d92:	7139                	addi	sp,sp,-64
ffffffffc0202d94:	e852                	sd	s4,16(sp)
ffffffffc0202d96:	8a32                	mv	s4,a2
ffffffffc0202d98:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202d9a:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202d9c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202d9e:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202da0:	f426                	sd	s1,40(sp)
ffffffffc0202da2:	fc06                	sd	ra,56(sp)
ffffffffc0202da4:	f04a                	sd	s2,32(sp)
ffffffffc0202da6:	ec4e                	sd	s3,24(sp)
ffffffffc0202da8:	e456                	sd	s5,8(sp)
ffffffffc0202daa:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202dac:	d25ff0ef          	jal	ra,ffffffffc0202ad0 <get_pte>
    if (ptep == NULL) {
ffffffffc0202db0:	c961                	beqz	a0,ffffffffc0202e80 <page_insert+0xee>
    page->ref += 1;
ffffffffc0202db2:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0202db4:	611c                	ld	a5,0(a0)
ffffffffc0202db6:	89aa                	mv	s3,a0
ffffffffc0202db8:	0016871b          	addiw	a4,a3,1
ffffffffc0202dbc:	c018                	sw	a4,0(s0)
ffffffffc0202dbe:	0017f713          	andi	a4,a5,1
ffffffffc0202dc2:	ef05                	bnez	a4,ffffffffc0202dfa <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0202dc4:	00013717          	auipc	a4,0x13
ffffffffc0202dc8:	8b473703          	ld	a4,-1868(a4) # ffffffffc0215678 <pages>
ffffffffc0202dcc:	8c19                	sub	s0,s0,a4
ffffffffc0202dce:	000807b7          	lui	a5,0x80
ffffffffc0202dd2:	8419                	srai	s0,s0,0x6
ffffffffc0202dd4:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202dd6:	042a                	slli	s0,s0,0xa
ffffffffc0202dd8:	8cc1                	or	s1,s1,s0
ffffffffc0202dda:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202dde:	0099b023          	sd	s1,0(s3) # 80000 <kern_entry-0xffffffffc0180000>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202de2:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0202de6:	4501                	li	a0,0
}
ffffffffc0202de8:	70e2                	ld	ra,56(sp)
ffffffffc0202dea:	7442                	ld	s0,48(sp)
ffffffffc0202dec:	74a2                	ld	s1,40(sp)
ffffffffc0202dee:	7902                	ld	s2,32(sp)
ffffffffc0202df0:	69e2                	ld	s3,24(sp)
ffffffffc0202df2:	6a42                	ld	s4,16(sp)
ffffffffc0202df4:	6aa2                	ld	s5,8(sp)
ffffffffc0202df6:	6121                	addi	sp,sp,64
ffffffffc0202df8:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202dfa:	078a                	slli	a5,a5,0x2
ffffffffc0202dfc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202dfe:	00013717          	auipc	a4,0x13
ffffffffc0202e02:	87273703          	ld	a4,-1934(a4) # ffffffffc0215670 <npage>
ffffffffc0202e06:	06e7ff63          	bgeu	a5,a4,ffffffffc0202e84 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e0a:	00013a97          	auipc	s5,0x13
ffffffffc0202e0e:	86ea8a93          	addi	s5,s5,-1938 # ffffffffc0215678 <pages>
ffffffffc0202e12:	000ab703          	ld	a4,0(s5)
ffffffffc0202e16:	fff80937          	lui	s2,0xfff80
ffffffffc0202e1a:	993e                	add	s2,s2,a5
ffffffffc0202e1c:	091a                	slli	s2,s2,0x6
ffffffffc0202e1e:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0202e20:	01240c63          	beq	s0,s2,ffffffffc0202e38 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0202e24:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fd6a954>
ffffffffc0202e28:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202e2c:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0202e30:	c691                	beqz	a3,ffffffffc0202e3c <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202e32:	120a0073          	sfence.vma	s4
}
ffffffffc0202e36:	bf59                	j	ffffffffc0202dcc <page_insert+0x3a>
ffffffffc0202e38:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202e3a:	bf49                	j	ffffffffc0202dcc <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202e3c:	100027f3          	csrr	a5,sstatus
ffffffffc0202e40:	8b89                	andi	a5,a5,2
ffffffffc0202e42:	ef91                	bnez	a5,ffffffffc0202e5e <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0202e44:	00013797          	auipc	a5,0x13
ffffffffc0202e48:	83c7b783          	ld	a5,-1988(a5) # ffffffffc0215680 <pmm_manager>
ffffffffc0202e4c:	739c                	ld	a5,32(a5)
ffffffffc0202e4e:	4585                	li	a1,1
ffffffffc0202e50:	854a                	mv	a0,s2
ffffffffc0202e52:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0202e54:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202e58:	120a0073          	sfence.vma	s4
ffffffffc0202e5c:	bf85                	j	ffffffffc0202dcc <page_insert+0x3a>
        intr_disable();
ffffffffc0202e5e:	f66fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202e62:	00013797          	auipc	a5,0x13
ffffffffc0202e66:	81e7b783          	ld	a5,-2018(a5) # ffffffffc0215680 <pmm_manager>
ffffffffc0202e6a:	739c                	ld	a5,32(a5)
ffffffffc0202e6c:	4585                	li	a1,1
ffffffffc0202e6e:	854a                	mv	a0,s2
ffffffffc0202e70:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e72:	f4cfd0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0202e76:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202e7a:	120a0073          	sfence.vma	s4
ffffffffc0202e7e:	b7b9                	j	ffffffffc0202dcc <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0202e80:	5571                	li	a0,-4
ffffffffc0202e82:	b79d                	j	ffffffffc0202de8 <page_insert+0x56>
ffffffffc0202e84:	b09ff0ef          	jal	ra,ffffffffc020298c <pa2page.part.0>

ffffffffc0202e88 <pmm_init>:
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0202e88:	00002797          	auipc	a5,0x2
ffffffffc0202e8c:	6f878793          	addi	a5,a5,1784 # ffffffffc0205580 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202e90:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202e92:	711d                	addi	sp,sp,-96
ffffffffc0202e94:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202e96:	00003517          	auipc	a0,0x3
ffffffffc0202e9a:	0b250513          	addi	a0,a0,178 # ffffffffc0205f48 <buddy_system_pmm_manager+0x9c8>
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0202e9e:	00012b97          	auipc	s7,0x12
ffffffffc0202ea2:	7e2b8b93          	addi	s7,s7,2018 # ffffffffc0215680 <pmm_manager>
void pmm_init(void) {
ffffffffc0202ea6:	ec86                	sd	ra,88(sp)
ffffffffc0202ea8:	e4a6                	sd	s1,72(sp)
ffffffffc0202eaa:	fc4e                	sd	s3,56(sp)
ffffffffc0202eac:	f05a                	sd	s6,32(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0202eae:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0202eb2:	e8a2                	sd	s0,80(sp)
ffffffffc0202eb4:	e0ca                	sd	s2,64(sp)
ffffffffc0202eb6:	f852                	sd	s4,48(sp)
ffffffffc0202eb8:	f456                	sd	s5,40(sp)
ffffffffc0202eba:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202ebc:	a10fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pmm_manager->init();
ffffffffc0202ec0:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;                           // 虚拟地址到物理地址的偏移量
ffffffffc0202ec4:	00012997          	auipc	s3,0x12
ffffffffc0202ec8:	7c498993          	addi	s3,s3,1988 # ffffffffc0215688 <va_pa_offset>
    npage = maxpa / PGSIZE;     // 物理页的页数
ffffffffc0202ecc:	00012497          	auipc	s1,0x12
ffffffffc0202ed0:	7a448493          	addi	s1,s1,1956 # ffffffffc0215670 <npage>
    pmm_manager->init();
ffffffffc0202ed4:	679c                	ld	a5,8(a5)
    pages = pages_begin;
ffffffffc0202ed6:	00012b17          	auipc	s6,0x12
ffffffffc0202eda:	7a2b0b13          	addi	s6,s6,1954 # ffffffffc0215678 <pages>
    pmm_manager->init();
ffffffffc0202ede:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;                           // 虚拟地址到物理地址的偏移量
ffffffffc0202ee0:	57f5                	li	a5,-3
ffffffffc0202ee2:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0202ee4:	00003517          	auipc	a0,0x3
ffffffffc0202ee8:	07c50513          	addi	a0,a0,124 # ffffffffc0205f60 <buddy_system_pmm_manager+0x9e0>
    va_pa_offset = KERNBASE - 0x80200000;                           // 虚拟地址到物理地址的偏移量
ffffffffc0202eec:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc0202ef0:	9dcfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin, mem_end - 1);
ffffffffc0202ef4:	46c5                	li	a3,17
ffffffffc0202ef6:	06ee                	slli	a3,a3,0x1b
ffffffffc0202ef8:	40100613          	li	a2,1025
ffffffffc0202efc:	16fd                	addi	a3,a3,-1
ffffffffc0202efe:	0656                	slli	a2,a2,0x15
ffffffffc0202f00:	07e005b7          	lui	a1,0x7e00
ffffffffc0202f04:	00003517          	auipc	a0,0x3
ffffffffc0202f08:	07450513          	addi	a0,a0,116 # ffffffffc0205f78 <buddy_system_pmm_manager+0x9f8>
ffffffffc0202f0c:	9c0fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    size_t* tree_begin = (size_t *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202f10:	767d                	lui	a2,0xfffff
ffffffffc0202f12:	00013717          	auipc	a4,0x13
ffffffffc0202f16:	79970713          	addi	a4,a4,1945 # ffffffffc02166ab <end+0xfff>
ffffffffc0202f1a:	8f71                	and	a4,a4,a2
    size_t* tree_end = tree_begin+tree_size;
ffffffffc0202f1c:	000807b7          	lui	a5,0x80
    struct Page* pages_begin = (struct Page*)ROUNDUP(tree_end, PGSIZE);
ffffffffc0202f20:	6685                	lui	a3,0x1
    size_t* tree_end = tree_begin+tree_size;
ffffffffc0202f22:	97ba                	add	a5,a5,a4
    struct Page* pages_begin = (struct Page*)ROUNDUP(tree_end, PGSIZE);
ffffffffc0202f24:	16fd                	addi	a3,a3,-1
ffffffffc0202f26:	97b6                	add	a5,a5,a3
    npage = maxpa / PGSIZE;     // 物理页的页数
ffffffffc0202f28:	000886b7          	lui	a3,0x88
ffffffffc0202f2c:	e094                	sd	a3,0(s1)
    free_area.free_tree = tree_begin;
ffffffffc0202f2e:	0000e697          	auipc	a3,0xe
ffffffffc0202f32:	52e6b123          	sd	a4,1314(a3) # ffffffffc0211450 <free_area+0x8>
    struct Page* pages_begin = (struct Page*)ROUNDUP(tree_end, PGSIZE);
ffffffffc0202f36:	8ff1                	and	a5,a5,a2
    struct Page* page_end    = pages_begin+page_num;
ffffffffc0202f38:	002006b7          	lui	a3,0x200
ffffffffc0202f3c:	96be                	add	a3,a3,a5
    pages = pages_begin;
ffffffffc0202f3e:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) 
ffffffffc0202f42:	4701                	li	a4,0
ffffffffc0202f44:	4585                	li	a1,1
ffffffffc0202f46:	fff80837          	lui	a6,0xfff80
ffffffffc0202f4a:	a019                	j	ffffffffc0202f50 <pmm_init+0xc8>
        SetPageReserved(pages + i); //在kern/mm/memlayout.h定义的(将该bit设为1，为内核保留页面)
ffffffffc0202f4c:	000b3783          	ld	a5,0(s6)
ffffffffc0202f50:	00671613          	slli	a2,a4,0x6
ffffffffc0202f54:	97b2                	add	a5,a5,a2
ffffffffc0202f56:	07a1                	addi	a5,a5,8
ffffffffc0202f58:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) 
ffffffffc0202f5c:	609c                	ld	a5,0(s1)
ffffffffc0202f5e:	0705                	addi	a4,a4,1
ffffffffc0202f60:	01078633          	add	a2,a5,a6
ffffffffc0202f64:	fec764e3          	bltu	a4,a2,ffffffffc0202f4c <pmm_init+0xc4>
    uintptr_t freemem = PADDR(page_end);
ffffffffc0202f68:	c0200737          	lui	a4,0xc0200
ffffffffc0202f6c:	60e6e863          	bltu	a3,a4,ffffffffc020357c <pmm_init+0x6f4>
ffffffffc0202f70:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202f74:	4645                	li	a2,17
ffffffffc0202f76:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR(page_end);
ffffffffc0202f78:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0202f7a:	4ac6e563          	bltu	a3,a2,ffffffffc0203424 <pmm_init+0x59c>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202f7e:	00003517          	auipc	a0,0x3
ffffffffc0202f82:	02250513          	addi	a0,a0,34 # ffffffffc0205fa0 <buddy_system_pmm_manager+0xa20>
ffffffffc0202f86:	946fd0ef          	jal	ra,ffffffffc02000cc <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202f8a:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202f8e:	00012917          	auipc	s2,0x12
ffffffffc0202f92:	6da90913          	addi	s2,s2,1754 # ffffffffc0215668 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202f96:	7b9c                	ld	a5,48(a5)
ffffffffc0202f98:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202f9a:	00003517          	auipc	a0,0x3
ffffffffc0202f9e:	01e50513          	addi	a0,a0,30 # ffffffffc0205fb8 <buddy_system_pmm_manager+0xa38>
ffffffffc0202fa2:	92afd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202fa6:	00006697          	auipc	a3,0x6
ffffffffc0202faa:	05a68693          	addi	a3,a3,90 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0202fae:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202fb2:	c02007b7          	lui	a5,0xc0200
ffffffffc0202fb6:	5cf6ef63          	bltu	a3,a5,ffffffffc0203594 <pmm_init+0x70c>
ffffffffc0202fba:	0009b783          	ld	a5,0(s3)
ffffffffc0202fbe:	8e9d                	sub	a3,a3,a5
ffffffffc0202fc0:	00012797          	auipc	a5,0x12
ffffffffc0202fc4:	6ad7b023          	sd	a3,1696(a5) # ffffffffc0215660 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202fc8:	100027f3          	csrr	a5,sstatus
ffffffffc0202fcc:	8b89                	andi	a5,a5,2
ffffffffc0202fce:	48079563          	bnez	a5,ffffffffc0203458 <pmm_init+0x5d0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202fd2:	000bb783          	ld	a5,0(s7)
ffffffffc0202fd6:	779c                	ld	a5,40(a5)
ffffffffc0202fd8:	9782                	jalr	a5
ffffffffc0202fda:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202fdc:	6098                	ld	a4,0(s1)
ffffffffc0202fde:	c80007b7          	lui	a5,0xc8000
ffffffffc0202fe2:	83b1                	srli	a5,a5,0xc
ffffffffc0202fe4:	5ee7e463          	bltu	a5,a4,ffffffffc02035cc <pmm_init+0x744>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202fe8:	00093503          	ld	a0,0(s2)
ffffffffc0202fec:	5c050063          	beqz	a0,ffffffffc02035ac <pmm_init+0x724>
ffffffffc0202ff0:	03451793          	slli	a5,a0,0x34
ffffffffc0202ff4:	5a079c63          	bnez	a5,ffffffffc02035ac <pmm_init+0x724>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202ff8:	4601                	li	a2,0
ffffffffc0202ffa:	4581                	li	a1,0
ffffffffc0202ffc:	ca7ff0ef          	jal	ra,ffffffffc0202ca2 <get_page>
ffffffffc0203000:	62051863          	bnez	a0,ffffffffc0203630 <pmm_init+0x7a8>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0203004:	4505                	li	a0,1
ffffffffc0203006:	9bfff0ef          	jal	ra,ffffffffc02029c4 <alloc_pages>
ffffffffc020300a:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020300c:	00093503          	ld	a0,0(s2)
ffffffffc0203010:	4681                	li	a3,0
ffffffffc0203012:	4601                	li	a2,0
ffffffffc0203014:	85d2                	mv	a1,s4
ffffffffc0203016:	d7dff0ef          	jal	ra,ffffffffc0202d92 <page_insert>
ffffffffc020301a:	5e051b63          	bnez	a0,ffffffffc0203610 <pmm_init+0x788>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020301e:	00093503          	ld	a0,0(s2)
ffffffffc0203022:	4601                	li	a2,0
ffffffffc0203024:	4581                	li	a1,0
ffffffffc0203026:	aabff0ef          	jal	ra,ffffffffc0202ad0 <get_pte>
ffffffffc020302a:	5c050363          	beqz	a0,ffffffffc02035f0 <pmm_init+0x768>
    assert(pte2page(*ptep) == p1);
ffffffffc020302e:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203030:	0017f713          	andi	a4,a5,1
ffffffffc0203034:	5a070c63          	beqz	a4,ffffffffc02035ec <pmm_init+0x764>
    if (PPN(pa) >= npage) {
ffffffffc0203038:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020303a:	078a                	slli	a5,a5,0x2
ffffffffc020303c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020303e:	52e7fd63          	bgeu	a5,a4,ffffffffc0203578 <pmm_init+0x6f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0203042:	000b3683          	ld	a3,0(s6)
ffffffffc0203046:	fff80637          	lui	a2,0xfff80
ffffffffc020304a:	97b2                	add	a5,a5,a2
ffffffffc020304c:	079a                	slli	a5,a5,0x6
ffffffffc020304e:	97b6                	add	a5,a5,a3
ffffffffc0203050:	10fa19e3          	bne	s4,a5,ffffffffc0203962 <pmm_init+0xada>
    assert(page_ref(p1) == 1);
ffffffffc0203054:	000a2683          	lw	a3,0(s4)
ffffffffc0203058:	4785                	li	a5,1
ffffffffc020305a:	14f690e3          	bne	a3,a5,ffffffffc020399a <pmm_init+0xb12>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020305e:	00093503          	ld	a0,0(s2)
ffffffffc0203062:	77fd                	lui	a5,0xfffff
ffffffffc0203064:	6114                	ld	a3,0(a0)
ffffffffc0203066:	068a                	slli	a3,a3,0x2
ffffffffc0203068:	8efd                	and	a3,a3,a5
ffffffffc020306a:	00c6d613          	srli	a2,a3,0xc
ffffffffc020306e:	10e67ae3          	bgeu	a2,a4,ffffffffc0203982 <pmm_init+0xafa>
ffffffffc0203072:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203076:	96e2                	add	a3,a3,s8
ffffffffc0203078:	0006ba83          	ld	s5,0(a3)
ffffffffc020307c:	0a8a                	slli	s5,s5,0x2
ffffffffc020307e:	00fafab3          	and	s5,s5,a5
ffffffffc0203082:	00cad793          	srli	a5,s5,0xc
ffffffffc0203086:	62e7f563          	bgeu	a5,a4,ffffffffc02036b0 <pmm_init+0x828>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020308a:	4601                	li	a2,0
ffffffffc020308c:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020308e:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203090:	a41ff0ef          	jal	ra,ffffffffc0202ad0 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203094:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203096:	5f551d63          	bne	a0,s5,ffffffffc0203690 <pmm_init+0x808>

    p2 = alloc_page();
ffffffffc020309a:	4505                	li	a0,1
ffffffffc020309c:	929ff0ef          	jal	ra,ffffffffc02029c4 <alloc_pages>
ffffffffc02030a0:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02030a2:	00093503          	ld	a0,0(s2)
ffffffffc02030a6:	46d1                	li	a3,20
ffffffffc02030a8:	6605                	lui	a2,0x1
ffffffffc02030aa:	85d6                	mv	a1,s5
ffffffffc02030ac:	ce7ff0ef          	jal	ra,ffffffffc0202d92 <page_insert>
ffffffffc02030b0:	5a051063          	bnez	a0,ffffffffc0203650 <pmm_init+0x7c8>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02030b4:	00093503          	ld	a0,0(s2)
ffffffffc02030b8:	4601                	li	a2,0
ffffffffc02030ba:	6585                	lui	a1,0x1
ffffffffc02030bc:	a15ff0ef          	jal	ra,ffffffffc0202ad0 <get_pte>
ffffffffc02030c0:	0e050de3          	beqz	a0,ffffffffc02039ba <pmm_init+0xb32>
    assert(*ptep & PTE_U);
ffffffffc02030c4:	611c                	ld	a5,0(a0)
ffffffffc02030c6:	0107f713          	andi	a4,a5,16
ffffffffc02030ca:	70070063          	beqz	a4,ffffffffc02037ca <pmm_init+0x942>
    assert(*ptep & PTE_W);
ffffffffc02030ce:	8b91                	andi	a5,a5,4
ffffffffc02030d0:	6a078d63          	beqz	a5,ffffffffc020378a <pmm_init+0x902>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02030d4:	00093503          	ld	a0,0(s2)
ffffffffc02030d8:	611c                	ld	a5,0(a0)
ffffffffc02030da:	8bc1                	andi	a5,a5,16
ffffffffc02030dc:	68078763          	beqz	a5,ffffffffc020376a <pmm_init+0x8e2>
    assert(page_ref(p2) == 1);
ffffffffc02030e0:	000aa703          	lw	a4,0(s5)
ffffffffc02030e4:	4785                	li	a5,1
ffffffffc02030e6:	58f71563          	bne	a4,a5,ffffffffc0203670 <pmm_init+0x7e8>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02030ea:	4681                	li	a3,0
ffffffffc02030ec:	6605                	lui	a2,0x1
ffffffffc02030ee:	85d2                	mv	a1,s4
ffffffffc02030f0:	ca3ff0ef          	jal	ra,ffffffffc0202d92 <page_insert>
ffffffffc02030f4:	62051b63          	bnez	a0,ffffffffc020372a <pmm_init+0x8a2>
    assert(page_ref(p1) == 2);
ffffffffc02030f8:	000a2703          	lw	a4,0(s4)
ffffffffc02030fc:	4789                	li	a5,2
ffffffffc02030fe:	60f71663          	bne	a4,a5,ffffffffc020370a <pmm_init+0x882>
    assert(page_ref(p2) == 0);
ffffffffc0203102:	000aa783          	lw	a5,0(s5)
ffffffffc0203106:	5e079263          	bnez	a5,ffffffffc02036ea <pmm_init+0x862>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020310a:	00093503          	ld	a0,0(s2)
ffffffffc020310e:	4601                	li	a2,0
ffffffffc0203110:	6585                	lui	a1,0x1
ffffffffc0203112:	9bfff0ef          	jal	ra,ffffffffc0202ad0 <get_pte>
ffffffffc0203116:	5a050a63          	beqz	a0,ffffffffc02036ca <pmm_init+0x842>
    assert(pte2page(*ptep) == p1);
ffffffffc020311a:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020311c:	00177793          	andi	a5,a4,1
ffffffffc0203120:	4c078663          	beqz	a5,ffffffffc02035ec <pmm_init+0x764>
    if (PPN(pa) >= npage) {
ffffffffc0203124:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203126:	00271793          	slli	a5,a4,0x2
ffffffffc020312a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020312c:	44d7f663          	bgeu	a5,a3,ffffffffc0203578 <pmm_init+0x6f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0203130:	000b3683          	ld	a3,0(s6)
ffffffffc0203134:	fff80637          	lui	a2,0xfff80
ffffffffc0203138:	97b2                	add	a5,a5,a2
ffffffffc020313a:	079a                	slli	a5,a5,0x6
ffffffffc020313c:	97b6                	add	a5,a5,a3
ffffffffc020313e:	6efa1663          	bne	s4,a5,ffffffffc020382a <pmm_init+0x9a2>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203142:	8b41                	andi	a4,a4,16
ffffffffc0203144:	6c071363          	bnez	a4,ffffffffc020380a <pmm_init+0x982>

    page_remove(boot_pgdir, 0x0);
ffffffffc0203148:	00093503          	ld	a0,0(s2)
ffffffffc020314c:	4581                	li	a1,0
ffffffffc020314e:	ba9ff0ef          	jal	ra,ffffffffc0202cf6 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0203152:	000a2703          	lw	a4,0(s4)
ffffffffc0203156:	4785                	li	a5,1
ffffffffc0203158:	68f71963          	bne	a4,a5,ffffffffc02037ea <pmm_init+0x962>
    assert(page_ref(p2) == 0);
ffffffffc020315c:	000aa783          	lw	a5,0(s5)
ffffffffc0203160:	76079163          	bnez	a5,ffffffffc02038c2 <pmm_init+0xa3a>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0203164:	00093503          	ld	a0,0(s2)
ffffffffc0203168:	6585                	lui	a1,0x1
ffffffffc020316a:	b8dff0ef          	jal	ra,ffffffffc0202cf6 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020316e:	000a2783          	lw	a5,0(s4)
ffffffffc0203172:	72079863          	bnez	a5,ffffffffc02038a2 <pmm_init+0xa1a>
    assert(page_ref(p2) == 0);
ffffffffc0203176:	000aa783          	lw	a5,0(s5)
ffffffffc020317a:	70079463          	bnez	a5,ffffffffc0203882 <pmm_init+0x9fa>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020317e:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203182:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203184:	000a3683          	ld	a3,0(s4)
ffffffffc0203188:	068a                	slli	a3,a3,0x2
ffffffffc020318a:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020318c:	3ee6f663          	bgeu	a3,a4,ffffffffc0203578 <pmm_init+0x6f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0203190:	fff807b7          	lui	a5,0xfff80
ffffffffc0203194:	000b3503          	ld	a0,0(s6)
ffffffffc0203198:	96be                	add	a3,a3,a5
ffffffffc020319a:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc020319c:	00d507b3          	add	a5,a0,a3
ffffffffc02031a0:	4390                	lw	a2,0(a5)
ffffffffc02031a2:	4785                	li	a5,1
ffffffffc02031a4:	6af61f63          	bne	a2,a5,ffffffffc0203862 <pmm_init+0x9da>
    return page - pages + nbase;
ffffffffc02031a8:	8699                	srai	a3,a3,0x6
ffffffffc02031aa:	000805b7          	lui	a1,0x80
ffffffffc02031ae:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc02031b0:	00c69613          	slli	a2,a3,0xc
ffffffffc02031b4:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02031b6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02031b8:	68e67963          	bgeu	a2,a4,ffffffffc020384a <pmm_init+0x9c2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02031bc:	0009b603          	ld	a2,0(s3)
ffffffffc02031c0:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc02031c2:	629c                	ld	a5,0(a3)
ffffffffc02031c4:	078a                	slli	a5,a5,0x2
ffffffffc02031c6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031c8:	3ae7f863          	bgeu	a5,a4,ffffffffc0203578 <pmm_init+0x6f0>
    return &pages[PPN(pa) - nbase];
ffffffffc02031cc:	8f8d                	sub	a5,a5,a1
ffffffffc02031ce:	079a                	slli	a5,a5,0x6
ffffffffc02031d0:	953e                	add	a0,a0,a5
ffffffffc02031d2:	100027f3          	csrr	a5,sstatus
ffffffffc02031d6:	8b89                	andi	a5,a5,2
ffffffffc02031d8:	2c079a63          	bnez	a5,ffffffffc02034ac <pmm_init+0x624>
        pmm_manager->free_pages(base, n);
ffffffffc02031dc:	000bb783          	ld	a5,0(s7)
ffffffffc02031e0:	4585                	li	a1,1
ffffffffc02031e2:	739c                	ld	a5,32(a5)
ffffffffc02031e4:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02031e6:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02031ea:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02031ec:	078a                	slli	a5,a5,0x2
ffffffffc02031ee:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031f0:	38e7f463          	bgeu	a5,a4,ffffffffc0203578 <pmm_init+0x6f0>
    return &pages[PPN(pa) - nbase];
ffffffffc02031f4:	000b3503          	ld	a0,0(s6)
ffffffffc02031f8:	fff80737          	lui	a4,0xfff80
ffffffffc02031fc:	97ba                	add	a5,a5,a4
ffffffffc02031fe:	079a                	slli	a5,a5,0x6
ffffffffc0203200:	953e                	add	a0,a0,a5
ffffffffc0203202:	100027f3          	csrr	a5,sstatus
ffffffffc0203206:	8b89                	andi	a5,a5,2
ffffffffc0203208:	28079663          	bnez	a5,ffffffffc0203494 <pmm_init+0x60c>
ffffffffc020320c:	000bb783          	ld	a5,0(s7)
ffffffffc0203210:	4585                	li	a1,1
ffffffffc0203212:	739c                	ld	a5,32(a5)
ffffffffc0203214:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0203216:	00093783          	ld	a5,0(s2)
ffffffffc020321a:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fd6a954>
  asm volatile("sfence.vma");
ffffffffc020321e:	12000073          	sfence.vma
ffffffffc0203222:	100027f3          	csrr	a5,sstatus
ffffffffc0203226:	8b89                	andi	a5,a5,2
ffffffffc0203228:	24079c63          	bnez	a5,ffffffffc0203480 <pmm_init+0x5f8>
        ret = pmm_manager->nr_free_pages();
ffffffffc020322c:	000bb783          	ld	a5,0(s7)
ffffffffc0203230:	779c                	ld	a5,40(a5)
ffffffffc0203232:	9782                	jalr	a5
ffffffffc0203234:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0203236:	71441663          	bne	s0,s4,ffffffffc0203942 <pmm_init+0xaba>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020323a:	00003517          	auipc	a0,0x3
ffffffffc020323e:	06650513          	addi	a0,a0,102 # ffffffffc02062a0 <buddy_system_pmm_manager+0xd20>
ffffffffc0203242:	e8bfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0203246:	100027f3          	csrr	a5,sstatus
ffffffffc020324a:	8b89                	andi	a5,a5,2
ffffffffc020324c:	22079063          	bnez	a5,ffffffffc020346c <pmm_init+0x5e4>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203250:	000bb783          	ld	a5,0(s7)
ffffffffc0203254:	779c                	ld	a5,40(a5)
ffffffffc0203256:	9782                	jalr	a5
ffffffffc0203258:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020325a:	6098                	ld	a4,0(s1)
ffffffffc020325c:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203260:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203262:	00c71793          	slli	a5,a4,0xc
ffffffffc0203266:	6a05                	lui	s4,0x1
ffffffffc0203268:	02f47c63          	bgeu	s0,a5,ffffffffc02032a0 <pmm_init+0x418>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020326c:	00c45793          	srli	a5,s0,0xc
ffffffffc0203270:	00093503          	ld	a0,0(s2)
ffffffffc0203274:	2ee7f563          	bgeu	a5,a4,ffffffffc020355e <pmm_init+0x6d6>
ffffffffc0203278:	0009b583          	ld	a1,0(s3)
ffffffffc020327c:	4601                	li	a2,0
ffffffffc020327e:	95a2                	add	a1,a1,s0
ffffffffc0203280:	851ff0ef          	jal	ra,ffffffffc0202ad0 <get_pte>
ffffffffc0203284:	2a050d63          	beqz	a0,ffffffffc020353e <pmm_init+0x6b6>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203288:	611c                	ld	a5,0(a0)
ffffffffc020328a:	078a                	slli	a5,a5,0x2
ffffffffc020328c:	0157f7b3          	and	a5,a5,s5
ffffffffc0203290:	28879763          	bne	a5,s0,ffffffffc020351e <pmm_init+0x696>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203294:	6098                	ld	a4,0(s1)
ffffffffc0203296:	9452                	add	s0,s0,s4
ffffffffc0203298:	00c71793          	slli	a5,a4,0xc
ffffffffc020329c:	fcf468e3          	bltu	s0,a5,ffffffffc020326c <pmm_init+0x3e4>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc02032a0:	00093783          	ld	a5,0(s2)
ffffffffc02032a4:	639c                	ld	a5,0(a5)
ffffffffc02032a6:	66079e63          	bnez	a5,ffffffffc0203922 <pmm_init+0xa9a>

    struct Page *p;
    p = alloc_page();
ffffffffc02032aa:	4505                	li	a0,1
ffffffffc02032ac:	f18ff0ef          	jal	ra,ffffffffc02029c4 <alloc_pages>
ffffffffc02032b0:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02032b2:	00093503          	ld	a0,0(s2)
ffffffffc02032b6:	4699                	li	a3,6
ffffffffc02032b8:	10000613          	li	a2,256
ffffffffc02032bc:	85d6                	mv	a1,s5
ffffffffc02032be:	ad5ff0ef          	jal	ra,ffffffffc0202d92 <page_insert>
ffffffffc02032c2:	64051063          	bnez	a0,ffffffffc0203902 <pmm_init+0xa7a>
    assert(page_ref(p) == 1);
ffffffffc02032c6:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fde9954>
ffffffffc02032ca:	4785                	li	a5,1
ffffffffc02032cc:	60f71b63          	bne	a4,a5,ffffffffc02038e2 <pmm_init+0xa5a>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02032d0:	00093503          	ld	a0,0(s2)
ffffffffc02032d4:	6405                	lui	s0,0x1
ffffffffc02032d6:	4699                	li	a3,6
ffffffffc02032d8:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc02032dc:	85d6                	mv	a1,s5
ffffffffc02032de:	ab5ff0ef          	jal	ra,ffffffffc0202d92 <page_insert>
ffffffffc02032e2:	46051463          	bnez	a0,ffffffffc020374a <pmm_init+0x8c2>
    assert(page_ref(p) == 2);
ffffffffc02032e6:	000aa703          	lw	a4,0(s5)
ffffffffc02032ea:	4789                	li	a5,2
ffffffffc02032ec:	72f71763          	bne	a4,a5,ffffffffc0203a1a <pmm_init+0xb92>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02032f0:	00003597          	auipc	a1,0x3
ffffffffc02032f4:	0e858593          	addi	a1,a1,232 # ffffffffc02063d8 <buddy_system_pmm_manager+0xe58>
ffffffffc02032f8:	10000513          	li	a0,256
ffffffffc02032fc:	108010ef          	jal	ra,ffffffffc0204404 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203300:	10040593          	addi	a1,s0,256
ffffffffc0203304:	10000513          	li	a0,256
ffffffffc0203308:	10e010ef          	jal	ra,ffffffffc0204416 <strcmp>
ffffffffc020330c:	6e051763          	bnez	a0,ffffffffc02039fa <pmm_init+0xb72>
    return page - pages + nbase;
ffffffffc0203310:	000b3683          	ld	a3,0(s6)
ffffffffc0203314:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0203318:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc020331a:	40da86b3          	sub	a3,s5,a3
ffffffffc020331e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0203320:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0203322:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0203324:	8031                	srli	s0,s0,0xc
ffffffffc0203326:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc020332a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020332c:	50f77f63          	bgeu	a4,a5,ffffffffc020384a <pmm_init+0x9c2>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203330:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203334:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203338:	96be                	add	a3,a3,a5
ffffffffc020333a:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020333e:	090010ef          	jal	ra,ffffffffc02043ce <strlen>
ffffffffc0203342:	68051c63          	bnez	a0,ffffffffc02039da <pmm_init+0xb52>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203346:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020334a:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020334c:	000a3683          	ld	a3,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203350:	068a                	slli	a3,a3,0x2
ffffffffc0203352:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203354:	22f6f263          	bgeu	a3,a5,ffffffffc0203578 <pmm_init+0x6f0>
    return KADDR(page2pa(page));
ffffffffc0203358:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020335a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020335c:	4ef47763          	bgeu	s0,a5,ffffffffc020384a <pmm_init+0x9c2>
ffffffffc0203360:	0009b403          	ld	s0,0(s3)
ffffffffc0203364:	9436                	add	s0,s0,a3
ffffffffc0203366:	100027f3          	csrr	a5,sstatus
ffffffffc020336a:	8b89                	andi	a5,a5,2
ffffffffc020336c:	18079e63          	bnez	a5,ffffffffc0203508 <pmm_init+0x680>
        pmm_manager->free_pages(base, n);
ffffffffc0203370:	000bb783          	ld	a5,0(s7)
ffffffffc0203374:	4585                	li	a1,1
ffffffffc0203376:	8556                	mv	a0,s5
ffffffffc0203378:	739c                	ld	a5,32(a5)
ffffffffc020337a:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020337c:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020337e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203380:	078a                	slli	a5,a5,0x2
ffffffffc0203382:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203384:	1ee7fa63          	bgeu	a5,a4,ffffffffc0203578 <pmm_init+0x6f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0203388:	000b3503          	ld	a0,0(s6)
ffffffffc020338c:	fff80737          	lui	a4,0xfff80
ffffffffc0203390:	97ba                	add	a5,a5,a4
ffffffffc0203392:	079a                	slli	a5,a5,0x6
ffffffffc0203394:	953e                	add	a0,a0,a5
ffffffffc0203396:	100027f3          	csrr	a5,sstatus
ffffffffc020339a:	8b89                	andi	a5,a5,2
ffffffffc020339c:	14079a63          	bnez	a5,ffffffffc02034f0 <pmm_init+0x668>
ffffffffc02033a0:	000bb783          	ld	a5,0(s7)
ffffffffc02033a4:	4585                	li	a1,1
ffffffffc02033a6:	739c                	ld	a5,32(a5)
ffffffffc02033a8:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02033aa:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02033ae:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02033b0:	078a                	slli	a5,a5,0x2
ffffffffc02033b2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033b4:	1ce7f263          	bgeu	a5,a4,ffffffffc0203578 <pmm_init+0x6f0>
    return &pages[PPN(pa) - nbase];
ffffffffc02033b8:	000b3503          	ld	a0,0(s6)
ffffffffc02033bc:	fff80737          	lui	a4,0xfff80
ffffffffc02033c0:	97ba                	add	a5,a5,a4
ffffffffc02033c2:	079a                	slli	a5,a5,0x6
ffffffffc02033c4:	953e                	add	a0,a0,a5
ffffffffc02033c6:	100027f3          	csrr	a5,sstatus
ffffffffc02033ca:	8b89                	andi	a5,a5,2
ffffffffc02033cc:	10079663          	bnez	a5,ffffffffc02034d8 <pmm_init+0x650>
ffffffffc02033d0:	000bb783          	ld	a5,0(s7)
ffffffffc02033d4:	4585                	li	a1,1
ffffffffc02033d6:	739c                	ld	a5,32(a5)
ffffffffc02033d8:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02033da:	00093783          	ld	a5,0(s2)
ffffffffc02033de:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02033e2:	12000073          	sfence.vma
ffffffffc02033e6:	100027f3          	csrr	a5,sstatus
ffffffffc02033ea:	8b89                	andi	a5,a5,2
ffffffffc02033ec:	0c079c63          	bnez	a5,ffffffffc02034c4 <pmm_init+0x63c>
        ret = pmm_manager->nr_free_pages();
ffffffffc02033f0:	000bb783          	ld	a5,0(s7)
ffffffffc02033f4:	779c                	ld	a5,40(a5)
ffffffffc02033f6:	9782                	jalr	a5
ffffffffc02033f8:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02033fa:	3a8c1863          	bne	s8,s0,ffffffffc02037aa <pmm_init+0x922>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02033fe:	00003517          	auipc	a0,0x3
ffffffffc0203402:	05250513          	addi	a0,a0,82 # ffffffffc0206450 <buddy_system_pmm_manager+0xed0>
ffffffffc0203406:	cc7fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc020340a:	6446                	ld	s0,80(sp)
ffffffffc020340c:	60e6                	ld	ra,88(sp)
ffffffffc020340e:	64a6                	ld	s1,72(sp)
ffffffffc0203410:	6906                	ld	s2,64(sp)
ffffffffc0203412:	79e2                	ld	s3,56(sp)
ffffffffc0203414:	7a42                	ld	s4,48(sp)
ffffffffc0203416:	7aa2                	ld	s5,40(sp)
ffffffffc0203418:	7b02                	ld	s6,32(sp)
ffffffffc020341a:	6be2                	ld	s7,24(sp)
ffffffffc020341c:	6c42                	ld	s8,16(sp)
ffffffffc020341e:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0203420:	b28ff06f          	j	ffffffffc0202748 <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0203424:	6705                	lui	a4,0x1
ffffffffc0203426:	177d                	addi	a4,a4,-1
ffffffffc0203428:	96ba                	add	a3,a3,a4
ffffffffc020342a:	777d                	lui	a4,0xfffff
ffffffffc020342c:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc020342e:	00c75693          	srli	a3,a4,0xc
ffffffffc0203432:	14f6f363          	bgeu	a3,a5,ffffffffc0203578 <pmm_init+0x6f0>
    pmm_manager->init_memmap(base, n);
ffffffffc0203436:	000bb583          	ld	a1,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc020343a:	000b3503          	ld	a0,0(s6)
ffffffffc020343e:	010687b3          	add	a5,a3,a6
ffffffffc0203442:	6994                	ld	a3,16(a1)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203444:	40e60733          	sub	a4,a2,a4
ffffffffc0203448:	079a                	slli	a5,a5,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc020344a:	00c75593          	srli	a1,a4,0xc
ffffffffc020344e:	953e                	add	a0,a0,a5
ffffffffc0203450:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0203452:	0009b583          	ld	a1,0(s3)
}
ffffffffc0203456:	b625                	j	ffffffffc0202f7e <pmm_init+0xf6>
        intr_disable();
ffffffffc0203458:	96cfd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020345c:	000bb783          	ld	a5,0(s7)
ffffffffc0203460:	779c                	ld	a5,40(a5)
ffffffffc0203462:	9782                	jalr	a5
ffffffffc0203464:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203466:	958fd0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc020346a:	be8d                	j	ffffffffc0202fdc <pmm_init+0x154>
        intr_disable();
ffffffffc020346c:	958fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0203470:	000bb783          	ld	a5,0(s7)
ffffffffc0203474:	779c                	ld	a5,40(a5)
ffffffffc0203476:	9782                	jalr	a5
ffffffffc0203478:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc020347a:	944fd0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc020347e:	bbf1                	j	ffffffffc020325a <pmm_init+0x3d2>
        intr_disable();
ffffffffc0203480:	944fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc0203484:	000bb783          	ld	a5,0(s7)
ffffffffc0203488:	779c                	ld	a5,40(a5)
ffffffffc020348a:	9782                	jalr	a5
ffffffffc020348c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020348e:	930fd0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203492:	b355                	j	ffffffffc0203236 <pmm_init+0x3ae>
ffffffffc0203494:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203496:	92efd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020349a:	000bb783          	ld	a5,0(s7)
ffffffffc020349e:	6522                	ld	a0,8(sp)
ffffffffc02034a0:	4585                	li	a1,1
ffffffffc02034a2:	739c                	ld	a5,32(a5)
ffffffffc02034a4:	9782                	jalr	a5
        intr_enable();
ffffffffc02034a6:	918fd0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc02034aa:	b3b5                	j	ffffffffc0203216 <pmm_init+0x38e>
ffffffffc02034ac:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02034ae:	916fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc02034b2:	000bb783          	ld	a5,0(s7)
ffffffffc02034b6:	6522                	ld	a0,8(sp)
ffffffffc02034b8:	4585                	li	a1,1
ffffffffc02034ba:	739c                	ld	a5,32(a5)
ffffffffc02034bc:	9782                	jalr	a5
        intr_enable();
ffffffffc02034be:	900fd0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc02034c2:	b315                	j	ffffffffc02031e6 <pmm_init+0x35e>
        intr_disable();
ffffffffc02034c4:	900fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02034c8:	000bb783          	ld	a5,0(s7)
ffffffffc02034cc:	779c                	ld	a5,40(a5)
ffffffffc02034ce:	9782                	jalr	a5
ffffffffc02034d0:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02034d2:	8ecfd0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc02034d6:	b715                	j	ffffffffc02033fa <pmm_init+0x572>
ffffffffc02034d8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02034da:	8eafd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02034de:	000bb783          	ld	a5,0(s7)
ffffffffc02034e2:	6522                	ld	a0,8(sp)
ffffffffc02034e4:	4585                	li	a1,1
ffffffffc02034e6:	739c                	ld	a5,32(a5)
ffffffffc02034e8:	9782                	jalr	a5
        intr_enable();
ffffffffc02034ea:	8d4fd0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc02034ee:	b5f5                	j	ffffffffc02033da <pmm_init+0x552>
ffffffffc02034f0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02034f2:	8d2fd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc02034f6:	000bb783          	ld	a5,0(s7)
ffffffffc02034fa:	6522                	ld	a0,8(sp)
ffffffffc02034fc:	4585                	li	a1,1
ffffffffc02034fe:	739c                	ld	a5,32(a5)
ffffffffc0203500:	9782                	jalr	a5
        intr_enable();
ffffffffc0203502:	8bcfd0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203506:	b555                	j	ffffffffc02033aa <pmm_init+0x522>
        intr_disable();
ffffffffc0203508:	8bcfd0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
ffffffffc020350c:	000bb783          	ld	a5,0(s7)
ffffffffc0203510:	4585                	li	a1,1
ffffffffc0203512:	8556                	mv	a0,s5
ffffffffc0203514:	739c                	ld	a5,32(a5)
ffffffffc0203516:	9782                	jalr	a5
        intr_enable();
ffffffffc0203518:	8a6fd0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc020351c:	b585                	j	ffffffffc020337c <pmm_init+0x4f4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020351e:	00003697          	auipc	a3,0x3
ffffffffc0203522:	de268693          	addi	a3,a3,-542 # ffffffffc0206300 <buddy_system_pmm_manager+0xd80>
ffffffffc0203526:	00002617          	auipc	a2,0x2
ffffffffc020352a:	dd260613          	addi	a2,a2,-558 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020352e:	1af00593          	li	a1,431
ffffffffc0203532:	00003517          	auipc	a0,0x3
ffffffffc0203536:	a0650513          	addi	a0,a0,-1530 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc020353a:	c8ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020353e:	00003697          	auipc	a3,0x3
ffffffffc0203542:	d8268693          	addi	a3,a3,-638 # ffffffffc02062c0 <buddy_system_pmm_manager+0xd40>
ffffffffc0203546:	00002617          	auipc	a2,0x2
ffffffffc020354a:	db260613          	addi	a2,a2,-590 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020354e:	1ae00593          	li	a1,430
ffffffffc0203552:	00003517          	auipc	a0,0x3
ffffffffc0203556:	9e650513          	addi	a0,a0,-1562 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc020355a:	c6ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc020355e:	86a2                	mv	a3,s0
ffffffffc0203560:	00002617          	auipc	a2,0x2
ffffffffc0203564:	2b860613          	addi	a2,a2,696 # ffffffffc0205818 <buddy_system_pmm_manager+0x298>
ffffffffc0203568:	1ae00593          	li	a1,430
ffffffffc020356c:	00003517          	auipc	a0,0x3
ffffffffc0203570:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc0203574:	c55fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0203578:	c14ff0ef          	jal	ra,ffffffffc020298c <pa2page.part.0>
    uintptr_t freemem = PADDR(page_end);
ffffffffc020357c:	00002617          	auipc	a2,0x2
ffffffffc0203580:	65460613          	addi	a2,a2,1620 # ffffffffc0205bd0 <buddy_system_pmm_manager+0x650>
ffffffffc0203584:	08e00593          	li	a1,142
ffffffffc0203588:	00003517          	auipc	a0,0x3
ffffffffc020358c:	9b050513          	addi	a0,a0,-1616 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc0203590:	c39fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203594:	00002617          	auipc	a2,0x2
ffffffffc0203598:	63c60613          	addi	a2,a2,1596 # ffffffffc0205bd0 <buddy_system_pmm_manager+0x650>
ffffffffc020359c:	0d400593          	li	a1,212
ffffffffc02035a0:	00003517          	auipc	a0,0x3
ffffffffc02035a4:	99850513          	addi	a0,a0,-1640 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc02035a8:	c21fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02035ac:	00003697          	auipc	a3,0x3
ffffffffc02035b0:	a4c68693          	addi	a3,a3,-1460 # ffffffffc0205ff8 <buddy_system_pmm_manager+0xa78>
ffffffffc02035b4:	00002617          	auipc	a2,0x2
ffffffffc02035b8:	d4460613          	addi	a2,a2,-700 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02035bc:	17200593          	li	a1,370
ffffffffc02035c0:	00003517          	auipc	a0,0x3
ffffffffc02035c4:	97850513          	addi	a0,a0,-1672 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc02035c8:	c01fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02035cc:	00003697          	auipc	a3,0x3
ffffffffc02035d0:	a0c68693          	addi	a3,a3,-1524 # ffffffffc0205fd8 <buddy_system_pmm_manager+0xa58>
ffffffffc02035d4:	00002617          	auipc	a2,0x2
ffffffffc02035d8:	d2460613          	addi	a2,a2,-732 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02035dc:	17100593          	li	a1,369
ffffffffc02035e0:	00003517          	auipc	a0,0x3
ffffffffc02035e4:	95850513          	addi	a0,a0,-1704 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc02035e8:	be1fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc02035ec:	bbcff0ef          	jal	ra,ffffffffc02029a8 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02035f0:	00003697          	auipc	a3,0x3
ffffffffc02035f4:	a9868693          	addi	a3,a3,-1384 # ffffffffc0206088 <buddy_system_pmm_manager+0xb08>
ffffffffc02035f8:	00002617          	auipc	a2,0x2
ffffffffc02035fc:	d0060613          	addi	a2,a2,-768 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0203600:	17a00593          	li	a1,378
ffffffffc0203604:	00003517          	auipc	a0,0x3
ffffffffc0203608:	93450513          	addi	a0,a0,-1740 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc020360c:	bbdfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203610:	00003697          	auipc	a3,0x3
ffffffffc0203614:	a4868693          	addi	a3,a3,-1464 # ffffffffc0206058 <buddy_system_pmm_manager+0xad8>
ffffffffc0203618:	00002617          	auipc	a2,0x2
ffffffffc020361c:	ce060613          	addi	a2,a2,-800 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0203620:	17700593          	li	a1,375
ffffffffc0203624:	00003517          	auipc	a0,0x3
ffffffffc0203628:	91450513          	addi	a0,a0,-1772 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc020362c:	b9dfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203630:	00003697          	auipc	a3,0x3
ffffffffc0203634:	a0068693          	addi	a3,a3,-1536 # ffffffffc0206030 <buddy_system_pmm_manager+0xab0>
ffffffffc0203638:	00002617          	auipc	a2,0x2
ffffffffc020363c:	cc060613          	addi	a2,a2,-832 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0203640:	17300593          	li	a1,371
ffffffffc0203644:	00003517          	auipc	a0,0x3
ffffffffc0203648:	8f450513          	addi	a0,a0,-1804 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc020364c:	b7dfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203650:	00003697          	auipc	a3,0x3
ffffffffc0203654:	ac068693          	addi	a3,a3,-1344 # ffffffffc0206110 <buddy_system_pmm_manager+0xb90>
ffffffffc0203658:	00002617          	auipc	a2,0x2
ffffffffc020365c:	ca060613          	addi	a2,a2,-864 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0203660:	18300593          	li	a1,387
ffffffffc0203664:	00003517          	auipc	a0,0x3
ffffffffc0203668:	8d450513          	addi	a0,a0,-1836 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc020366c:	b5dfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203670:	00003697          	auipc	a3,0x3
ffffffffc0203674:	b4068693          	addi	a3,a3,-1216 # ffffffffc02061b0 <buddy_system_pmm_manager+0xc30>
ffffffffc0203678:	00002617          	auipc	a2,0x2
ffffffffc020367c:	c8060613          	addi	a2,a2,-896 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0203680:	18800593          	li	a1,392
ffffffffc0203684:	00003517          	auipc	a0,0x3
ffffffffc0203688:	8b450513          	addi	a0,a0,-1868 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc020368c:	b3dfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203690:	00003697          	auipc	a3,0x3
ffffffffc0203694:	a5868693          	addi	a3,a3,-1448 # ffffffffc02060e8 <buddy_system_pmm_manager+0xb68>
ffffffffc0203698:	00002617          	auipc	a2,0x2
ffffffffc020369c:	c6060613          	addi	a2,a2,-928 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02036a0:	18000593          	li	a1,384
ffffffffc02036a4:	00003517          	auipc	a0,0x3
ffffffffc02036a8:	89450513          	addi	a0,a0,-1900 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc02036ac:	b1dfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02036b0:	86d6                	mv	a3,s5
ffffffffc02036b2:	00002617          	auipc	a2,0x2
ffffffffc02036b6:	16660613          	addi	a2,a2,358 # ffffffffc0205818 <buddy_system_pmm_manager+0x298>
ffffffffc02036ba:	17f00593          	li	a1,383
ffffffffc02036be:	00003517          	auipc	a0,0x3
ffffffffc02036c2:	87a50513          	addi	a0,a0,-1926 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc02036c6:	b03fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02036ca:	00003697          	auipc	a3,0x3
ffffffffc02036ce:	a7e68693          	addi	a3,a3,-1410 # ffffffffc0206148 <buddy_system_pmm_manager+0xbc8>
ffffffffc02036d2:	00002617          	auipc	a2,0x2
ffffffffc02036d6:	c2660613          	addi	a2,a2,-986 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02036da:	18d00593          	li	a1,397
ffffffffc02036de:	00003517          	auipc	a0,0x3
ffffffffc02036e2:	85a50513          	addi	a0,a0,-1958 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc02036e6:	ae3fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02036ea:	00003697          	auipc	a3,0x3
ffffffffc02036ee:	b2668693          	addi	a3,a3,-1242 # ffffffffc0206210 <buddy_system_pmm_manager+0xc90>
ffffffffc02036f2:	00002617          	auipc	a2,0x2
ffffffffc02036f6:	c0660613          	addi	a2,a2,-1018 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02036fa:	18c00593          	li	a1,396
ffffffffc02036fe:	00003517          	auipc	a0,0x3
ffffffffc0203702:	83a50513          	addi	a0,a0,-1990 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc0203706:	ac3fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020370a:	00003697          	auipc	a3,0x3
ffffffffc020370e:	aee68693          	addi	a3,a3,-1298 # ffffffffc02061f8 <buddy_system_pmm_manager+0xc78>
ffffffffc0203712:	00002617          	auipc	a2,0x2
ffffffffc0203716:	be660613          	addi	a2,a2,-1050 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020371a:	18b00593          	li	a1,395
ffffffffc020371e:	00003517          	auipc	a0,0x3
ffffffffc0203722:	81a50513          	addi	a0,a0,-2022 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc0203726:	aa3fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020372a:	00003697          	auipc	a3,0x3
ffffffffc020372e:	a9e68693          	addi	a3,a3,-1378 # ffffffffc02061c8 <buddy_system_pmm_manager+0xc48>
ffffffffc0203732:	00002617          	auipc	a2,0x2
ffffffffc0203736:	bc660613          	addi	a2,a2,-1082 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020373a:	18a00593          	li	a1,394
ffffffffc020373e:	00002517          	auipc	a0,0x2
ffffffffc0203742:	7fa50513          	addi	a0,a0,2042 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc0203746:	a83fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020374a:	00003697          	auipc	a3,0x3
ffffffffc020374e:	c3668693          	addi	a3,a3,-970 # ffffffffc0206380 <buddy_system_pmm_manager+0xe00>
ffffffffc0203752:	00002617          	auipc	a2,0x2
ffffffffc0203756:	ba660613          	addi	a2,a2,-1114 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020375a:	1b800593          	li	a1,440
ffffffffc020375e:	00002517          	auipc	a0,0x2
ffffffffc0203762:	7da50513          	addi	a0,a0,2010 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc0203766:	a63fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020376a:	00003697          	auipc	a3,0x3
ffffffffc020376e:	a2e68693          	addi	a3,a3,-1490 # ffffffffc0206198 <buddy_system_pmm_manager+0xc18>
ffffffffc0203772:	00002617          	auipc	a2,0x2
ffffffffc0203776:	b8660613          	addi	a2,a2,-1146 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020377a:	18700593          	li	a1,391
ffffffffc020377e:	00002517          	auipc	a0,0x2
ffffffffc0203782:	7ba50513          	addi	a0,a0,1978 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc0203786:	a43fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020378a:	00003697          	auipc	a3,0x3
ffffffffc020378e:	9fe68693          	addi	a3,a3,-1538 # ffffffffc0206188 <buddy_system_pmm_manager+0xc08>
ffffffffc0203792:	00002617          	auipc	a2,0x2
ffffffffc0203796:	b6660613          	addi	a2,a2,-1178 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020379a:	18600593          	li	a1,390
ffffffffc020379e:	00002517          	auipc	a0,0x2
ffffffffc02037a2:	79a50513          	addi	a0,a0,1946 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc02037a6:	a23fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02037aa:	00003697          	auipc	a3,0x3
ffffffffc02037ae:	ad668693          	addi	a3,a3,-1322 # ffffffffc0206280 <buddy_system_pmm_manager+0xd00>
ffffffffc02037b2:	00002617          	auipc	a2,0x2
ffffffffc02037b6:	b4660613          	addi	a2,a2,-1210 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02037ba:	1c900593          	li	a1,457
ffffffffc02037be:	00002517          	auipc	a0,0x2
ffffffffc02037c2:	77a50513          	addi	a0,a0,1914 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc02037c6:	a03fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02037ca:	00003697          	auipc	a3,0x3
ffffffffc02037ce:	9ae68693          	addi	a3,a3,-1618 # ffffffffc0206178 <buddy_system_pmm_manager+0xbf8>
ffffffffc02037d2:	00002617          	auipc	a2,0x2
ffffffffc02037d6:	b2660613          	addi	a2,a2,-1242 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02037da:	18500593          	li	a1,389
ffffffffc02037de:	00002517          	auipc	a0,0x2
ffffffffc02037e2:	75a50513          	addi	a0,a0,1882 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc02037e6:	9e3fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02037ea:	00003697          	auipc	a3,0x3
ffffffffc02037ee:	8e668693          	addi	a3,a3,-1818 # ffffffffc02060d0 <buddy_system_pmm_manager+0xb50>
ffffffffc02037f2:	00002617          	auipc	a2,0x2
ffffffffc02037f6:	b0660613          	addi	a2,a2,-1274 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02037fa:	19200593          	li	a1,402
ffffffffc02037fe:	00002517          	auipc	a0,0x2
ffffffffc0203802:	73a50513          	addi	a0,a0,1850 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc0203806:	9c3fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020380a:	00003697          	auipc	a3,0x3
ffffffffc020380e:	a1e68693          	addi	a3,a3,-1506 # ffffffffc0206228 <buddy_system_pmm_manager+0xca8>
ffffffffc0203812:	00002617          	auipc	a2,0x2
ffffffffc0203816:	ae660613          	addi	a2,a2,-1306 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020381a:	18f00593          	li	a1,399
ffffffffc020381e:	00002517          	auipc	a0,0x2
ffffffffc0203822:	71a50513          	addi	a0,a0,1818 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc0203826:	9a3fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020382a:	00003697          	auipc	a3,0x3
ffffffffc020382e:	88e68693          	addi	a3,a3,-1906 # ffffffffc02060b8 <buddy_system_pmm_manager+0xb38>
ffffffffc0203832:	00002617          	auipc	a2,0x2
ffffffffc0203836:	ac660613          	addi	a2,a2,-1338 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020383a:	18e00593          	li	a1,398
ffffffffc020383e:	00002517          	auipc	a0,0x2
ffffffffc0203842:	6fa50513          	addi	a0,a0,1786 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc0203846:	983fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc020384a:	00002617          	auipc	a2,0x2
ffffffffc020384e:	fce60613          	addi	a2,a2,-50 # ffffffffc0205818 <buddy_system_pmm_manager+0x298>
ffffffffc0203852:	06900593          	li	a1,105
ffffffffc0203856:	00002517          	auipc	a0,0x2
ffffffffc020385a:	fb250513          	addi	a0,a0,-78 # ffffffffc0205808 <buddy_system_pmm_manager+0x288>
ffffffffc020385e:	96bfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203862:	00003697          	auipc	a3,0x3
ffffffffc0203866:	9f668693          	addi	a3,a3,-1546 # ffffffffc0206258 <buddy_system_pmm_manager+0xcd8>
ffffffffc020386a:	00002617          	auipc	a2,0x2
ffffffffc020386e:	a8e60613          	addi	a2,a2,-1394 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0203872:	19900593          	li	a1,409
ffffffffc0203876:	00002517          	auipc	a0,0x2
ffffffffc020387a:	6c250513          	addi	a0,a0,1730 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc020387e:	94bfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203882:	00003697          	auipc	a3,0x3
ffffffffc0203886:	98e68693          	addi	a3,a3,-1650 # ffffffffc0206210 <buddy_system_pmm_manager+0xc90>
ffffffffc020388a:	00002617          	auipc	a2,0x2
ffffffffc020388e:	a6e60613          	addi	a2,a2,-1426 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0203892:	19700593          	li	a1,407
ffffffffc0203896:	00002517          	auipc	a0,0x2
ffffffffc020389a:	6a250513          	addi	a0,a0,1698 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc020389e:	92bfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02038a2:	00003697          	auipc	a3,0x3
ffffffffc02038a6:	99e68693          	addi	a3,a3,-1634 # ffffffffc0206240 <buddy_system_pmm_manager+0xcc0>
ffffffffc02038aa:	00002617          	auipc	a2,0x2
ffffffffc02038ae:	a4e60613          	addi	a2,a2,-1458 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02038b2:	19600593          	li	a1,406
ffffffffc02038b6:	00002517          	auipc	a0,0x2
ffffffffc02038ba:	68250513          	addi	a0,a0,1666 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc02038be:	90bfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02038c2:	00003697          	auipc	a3,0x3
ffffffffc02038c6:	94e68693          	addi	a3,a3,-1714 # ffffffffc0206210 <buddy_system_pmm_manager+0xc90>
ffffffffc02038ca:	00002617          	auipc	a2,0x2
ffffffffc02038ce:	a2e60613          	addi	a2,a2,-1490 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02038d2:	19300593          	li	a1,403
ffffffffc02038d6:	00002517          	auipc	a0,0x2
ffffffffc02038da:	66250513          	addi	a0,a0,1634 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc02038de:	8ebfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p) == 1);
ffffffffc02038e2:	00003697          	auipc	a3,0x3
ffffffffc02038e6:	a8668693          	addi	a3,a3,-1402 # ffffffffc0206368 <buddy_system_pmm_manager+0xde8>
ffffffffc02038ea:	00002617          	auipc	a2,0x2
ffffffffc02038ee:	a0e60613          	addi	a2,a2,-1522 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02038f2:	1b700593          	li	a1,439
ffffffffc02038f6:	00002517          	auipc	a0,0x2
ffffffffc02038fa:	64250513          	addi	a0,a0,1602 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc02038fe:	8cbfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203902:	00003697          	auipc	a3,0x3
ffffffffc0203906:	a2e68693          	addi	a3,a3,-1490 # ffffffffc0206330 <buddy_system_pmm_manager+0xdb0>
ffffffffc020390a:	00002617          	auipc	a2,0x2
ffffffffc020390e:	9ee60613          	addi	a2,a2,-1554 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0203912:	1b600593          	li	a1,438
ffffffffc0203916:	00002517          	auipc	a0,0x2
ffffffffc020391a:	62250513          	addi	a0,a0,1570 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc020391e:	8abfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203922:	00003697          	auipc	a3,0x3
ffffffffc0203926:	9f668693          	addi	a3,a3,-1546 # ffffffffc0206318 <buddy_system_pmm_manager+0xd98>
ffffffffc020392a:	00002617          	auipc	a2,0x2
ffffffffc020392e:	9ce60613          	addi	a2,a2,-1586 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0203932:	1b200593          	li	a1,434
ffffffffc0203936:	00002517          	auipc	a0,0x2
ffffffffc020393a:	60250513          	addi	a0,a0,1538 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc020393e:	88bfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203942:	00003697          	auipc	a3,0x3
ffffffffc0203946:	93e68693          	addi	a3,a3,-1730 # ffffffffc0206280 <buddy_system_pmm_manager+0xd00>
ffffffffc020394a:	00002617          	auipc	a2,0x2
ffffffffc020394e:	9ae60613          	addi	a2,a2,-1618 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0203952:	1a100593          	li	a1,417
ffffffffc0203956:	00002517          	auipc	a0,0x2
ffffffffc020395a:	5e250513          	addi	a0,a0,1506 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc020395e:	86bfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203962:	00002697          	auipc	a3,0x2
ffffffffc0203966:	75668693          	addi	a3,a3,1878 # ffffffffc02060b8 <buddy_system_pmm_manager+0xb38>
ffffffffc020396a:	00002617          	auipc	a2,0x2
ffffffffc020396e:	98e60613          	addi	a2,a2,-1650 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0203972:	17b00593          	li	a1,379
ffffffffc0203976:	00002517          	auipc	a0,0x2
ffffffffc020397a:	5c250513          	addi	a0,a0,1474 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc020397e:	84bfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203982:	00002617          	auipc	a2,0x2
ffffffffc0203986:	e9660613          	addi	a2,a2,-362 # ffffffffc0205818 <buddy_system_pmm_manager+0x298>
ffffffffc020398a:	17e00593          	li	a1,382
ffffffffc020398e:	00002517          	auipc	a0,0x2
ffffffffc0203992:	5aa50513          	addi	a0,a0,1450 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc0203996:	833fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020399a:	00002697          	auipc	a3,0x2
ffffffffc020399e:	73668693          	addi	a3,a3,1846 # ffffffffc02060d0 <buddy_system_pmm_manager+0xb50>
ffffffffc02039a2:	00002617          	auipc	a2,0x2
ffffffffc02039a6:	95660613          	addi	a2,a2,-1706 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02039aa:	17c00593          	li	a1,380
ffffffffc02039ae:	00002517          	auipc	a0,0x2
ffffffffc02039b2:	58a50513          	addi	a0,a0,1418 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc02039b6:	813fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02039ba:	00002697          	auipc	a3,0x2
ffffffffc02039be:	78e68693          	addi	a3,a3,1934 # ffffffffc0206148 <buddy_system_pmm_manager+0xbc8>
ffffffffc02039c2:	00002617          	auipc	a2,0x2
ffffffffc02039c6:	93660613          	addi	a2,a2,-1738 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02039ca:	18400593          	li	a1,388
ffffffffc02039ce:	00002517          	auipc	a0,0x2
ffffffffc02039d2:	56a50513          	addi	a0,a0,1386 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc02039d6:	ff2fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02039da:	00003697          	auipc	a3,0x3
ffffffffc02039de:	a4e68693          	addi	a3,a3,-1458 # ffffffffc0206428 <buddy_system_pmm_manager+0xea8>
ffffffffc02039e2:	00002617          	auipc	a2,0x2
ffffffffc02039e6:	91660613          	addi	a2,a2,-1770 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02039ea:	1c000593          	li	a1,448
ffffffffc02039ee:	00002517          	auipc	a0,0x2
ffffffffc02039f2:	54a50513          	addi	a0,a0,1354 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc02039f6:	fd2fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02039fa:	00003697          	auipc	a3,0x3
ffffffffc02039fe:	9f668693          	addi	a3,a3,-1546 # ffffffffc02063f0 <buddy_system_pmm_manager+0xe70>
ffffffffc0203a02:	00002617          	auipc	a2,0x2
ffffffffc0203a06:	8f660613          	addi	a2,a2,-1802 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0203a0a:	1bd00593          	li	a1,445
ffffffffc0203a0e:	00002517          	auipc	a0,0x2
ffffffffc0203a12:	52a50513          	addi	a0,a0,1322 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc0203a16:	fb2fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203a1a:	00003697          	auipc	a3,0x3
ffffffffc0203a1e:	9a668693          	addi	a3,a3,-1626 # ffffffffc02063c0 <buddy_system_pmm_manager+0xe40>
ffffffffc0203a22:	00002617          	auipc	a2,0x2
ffffffffc0203a26:	8d660613          	addi	a2,a2,-1834 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0203a2a:	1b900593          	li	a1,441
ffffffffc0203a2e:	00002517          	auipc	a0,0x2
ffffffffc0203a32:	50a50513          	addi	a0,a0,1290 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc0203a36:	f92fc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203a3a <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203a3a:	12058073          	sfence.vma	a1
}
ffffffffc0203a3e:	8082                	ret

ffffffffc0203a40 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203a40:	7179                	addi	sp,sp,-48
ffffffffc0203a42:	e84a                	sd	s2,16(sp)
ffffffffc0203a44:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203a46:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203a48:	f022                	sd	s0,32(sp)
ffffffffc0203a4a:	ec26                	sd	s1,24(sp)
ffffffffc0203a4c:	e44e                	sd	s3,8(sp)
ffffffffc0203a4e:	f406                	sd	ra,40(sp)
ffffffffc0203a50:	84ae                	mv	s1,a1
ffffffffc0203a52:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203a54:	f71fe0ef          	jal	ra,ffffffffc02029c4 <alloc_pages>
ffffffffc0203a58:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203a5a:	cd09                	beqz	a0,ffffffffc0203a74 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203a5c:	85aa                	mv	a1,a0
ffffffffc0203a5e:	86ce                	mv	a3,s3
ffffffffc0203a60:	8626                	mv	a2,s1
ffffffffc0203a62:	854a                	mv	a0,s2
ffffffffc0203a64:	b2eff0ef          	jal	ra,ffffffffc0202d92 <page_insert>
ffffffffc0203a68:	ed21                	bnez	a0,ffffffffc0203ac0 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0203a6a:	00012797          	auipc	a5,0x12
ffffffffc0203a6e:	bee7a783          	lw	a5,-1042(a5) # ffffffffc0215658 <swap_init_ok>
ffffffffc0203a72:	eb89                	bnez	a5,ffffffffc0203a84 <pgdir_alloc_page+0x44>
}
ffffffffc0203a74:	70a2                	ld	ra,40(sp)
ffffffffc0203a76:	8522                	mv	a0,s0
ffffffffc0203a78:	7402                	ld	s0,32(sp)
ffffffffc0203a7a:	64e2                	ld	s1,24(sp)
ffffffffc0203a7c:	6942                	ld	s2,16(sp)
ffffffffc0203a7e:	69a2                	ld	s3,8(sp)
ffffffffc0203a80:	6145                	addi	sp,sp,48
ffffffffc0203a82:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203a84:	4681                	li	a3,0
ffffffffc0203a86:	8622                	mv	a2,s0
ffffffffc0203a88:	85a6                	mv	a1,s1
ffffffffc0203a8a:	00012517          	auipc	a0,0x12
ffffffffc0203a8e:	ba653503          	ld	a0,-1114(a0) # ffffffffc0215630 <check_mm_struct>
ffffffffc0203a92:	d61fe0ef          	jal	ra,ffffffffc02027f2 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0203a96:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0203a98:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0203a9a:	4785                	li	a5,1
ffffffffc0203a9c:	fcf70ce3          	beq	a4,a5,ffffffffc0203a74 <pgdir_alloc_page+0x34>
ffffffffc0203aa0:	00003697          	auipc	a3,0x3
ffffffffc0203aa4:	9d068693          	addi	a3,a3,-1584 # ffffffffc0206470 <buddy_system_pmm_manager+0xef0>
ffffffffc0203aa8:	00002617          	auipc	a2,0x2
ffffffffc0203aac:	85060613          	addi	a2,a2,-1968 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc0203ab0:	15900593          	li	a1,345
ffffffffc0203ab4:	00002517          	auipc	a0,0x2
ffffffffc0203ab8:	48450513          	addi	a0,a0,1156 # ffffffffc0205f38 <buddy_system_pmm_manager+0x9b8>
ffffffffc0203abc:	f0cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203ac0:	100027f3          	csrr	a5,sstatus
ffffffffc0203ac4:	8b89                	andi	a5,a5,2
ffffffffc0203ac6:	eb99                	bnez	a5,ffffffffc0203adc <pgdir_alloc_page+0x9c>
        pmm_manager->free_pages(base, n);
ffffffffc0203ac8:	00012797          	auipc	a5,0x12
ffffffffc0203acc:	bb87b783          	ld	a5,-1096(a5) # ffffffffc0215680 <pmm_manager>
ffffffffc0203ad0:	739c                	ld	a5,32(a5)
ffffffffc0203ad2:	8522                	mv	a0,s0
ffffffffc0203ad4:	4585                	li	a1,1
ffffffffc0203ad6:	9782                	jalr	a5
            return NULL;
ffffffffc0203ad8:	4401                	li	s0,0
ffffffffc0203ada:	bf69                	j	ffffffffc0203a74 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0203adc:	ae9fc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203ae0:	00012797          	auipc	a5,0x12
ffffffffc0203ae4:	ba07b783          	ld	a5,-1120(a5) # ffffffffc0215680 <pmm_manager>
ffffffffc0203ae8:	739c                	ld	a5,32(a5)
ffffffffc0203aea:	8522                	mv	a0,s0
ffffffffc0203aec:	4585                	li	a1,1
ffffffffc0203aee:	9782                	jalr	a5
            return NULL;
ffffffffc0203af0:	4401                	li	s0,0
        intr_enable();
ffffffffc0203af2:	acdfc0ef          	jal	ra,ffffffffc02005be <intr_enable>
ffffffffc0203af6:	bfbd                	j	ffffffffc0203a74 <pgdir_alloc_page+0x34>

ffffffffc0203af8 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203af8:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203afa:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203afc:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203afe:	9a7fc0ef          	jal	ra,ffffffffc02004a4 <ide_device_valid>
ffffffffc0203b02:	cd01                	beqz	a0,ffffffffc0203b1a <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203b04:	4505                	li	a0,1
ffffffffc0203b06:	9a5fc0ef          	jal	ra,ffffffffc02004aa <ide_device_size>
}
ffffffffc0203b0a:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203b0c:	810d                	srli	a0,a0,0x3
ffffffffc0203b0e:	00012797          	auipc	a5,0x12
ffffffffc0203b12:	b2a7bd23          	sd	a0,-1222(a5) # ffffffffc0215648 <max_swap_offset>
}
ffffffffc0203b16:	0141                	addi	sp,sp,16
ffffffffc0203b18:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203b1a:	00003617          	auipc	a2,0x3
ffffffffc0203b1e:	96e60613          	addi	a2,a2,-1682 # ffffffffc0206488 <buddy_system_pmm_manager+0xf08>
ffffffffc0203b22:	45b5                	li	a1,13
ffffffffc0203b24:	00003517          	auipc	a0,0x3
ffffffffc0203b28:	98450513          	addi	a0,a0,-1660 # ffffffffc02064a8 <buddy_system_pmm_manager+0xf28>
ffffffffc0203b2c:	e9cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203b30 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203b30:	1141                	addi	sp,sp,-16
ffffffffc0203b32:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203b34:	00855793          	srli	a5,a0,0x8
ffffffffc0203b38:	cbb1                	beqz	a5,ffffffffc0203b8c <swapfs_read+0x5c>
ffffffffc0203b3a:	00012717          	auipc	a4,0x12
ffffffffc0203b3e:	b0e73703          	ld	a4,-1266(a4) # ffffffffc0215648 <max_swap_offset>
ffffffffc0203b42:	04e7f563          	bgeu	a5,a4,ffffffffc0203b8c <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0203b46:	00012617          	auipc	a2,0x12
ffffffffc0203b4a:	b3263603          	ld	a2,-1230(a2) # ffffffffc0215678 <pages>
ffffffffc0203b4e:	8d91                	sub	a1,a1,a2
ffffffffc0203b50:	4065d613          	srai	a2,a1,0x6
ffffffffc0203b54:	00003717          	auipc	a4,0x3
ffffffffc0203b58:	d8473703          	ld	a4,-636(a4) # ffffffffc02068d8 <nbase>
ffffffffc0203b5c:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0203b5e:	00c61713          	slli	a4,a2,0xc
ffffffffc0203b62:	8331                	srli	a4,a4,0xc
ffffffffc0203b64:	00012697          	auipc	a3,0x12
ffffffffc0203b68:	b0c6b683          	ld	a3,-1268(a3) # ffffffffc0215670 <npage>
ffffffffc0203b6c:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203b70:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0203b72:	02d77963          	bgeu	a4,a3,ffffffffc0203ba4 <swapfs_read+0x74>
}
ffffffffc0203b76:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203b78:	00012797          	auipc	a5,0x12
ffffffffc0203b7c:	b107b783          	ld	a5,-1264(a5) # ffffffffc0215688 <va_pa_offset>
ffffffffc0203b80:	46a1                	li	a3,8
ffffffffc0203b82:	963e                	add	a2,a2,a5
ffffffffc0203b84:	4505                	li	a0,1
}
ffffffffc0203b86:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203b88:	929fc06f          	j	ffffffffc02004b0 <ide_read_secs>
ffffffffc0203b8c:	86aa                	mv	a3,a0
ffffffffc0203b8e:	00003617          	auipc	a2,0x3
ffffffffc0203b92:	93260613          	addi	a2,a2,-1742 # ffffffffc02064c0 <buddy_system_pmm_manager+0xf40>
ffffffffc0203b96:	45d1                	li	a1,20
ffffffffc0203b98:	00003517          	auipc	a0,0x3
ffffffffc0203b9c:	91050513          	addi	a0,a0,-1776 # ffffffffc02064a8 <buddy_system_pmm_manager+0xf28>
ffffffffc0203ba0:	e28fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0203ba4:	86b2                	mv	a3,a2
ffffffffc0203ba6:	06900593          	li	a1,105
ffffffffc0203baa:	00002617          	auipc	a2,0x2
ffffffffc0203bae:	c6e60613          	addi	a2,a2,-914 # ffffffffc0205818 <buddy_system_pmm_manager+0x298>
ffffffffc0203bb2:	00002517          	auipc	a0,0x2
ffffffffc0203bb6:	c5650513          	addi	a0,a0,-938 # ffffffffc0205808 <buddy_system_pmm_manager+0x288>
ffffffffc0203bba:	e0efc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203bbe <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203bbe:	1141                	addi	sp,sp,-16
ffffffffc0203bc0:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203bc2:	00855793          	srli	a5,a0,0x8
ffffffffc0203bc6:	cbb1                	beqz	a5,ffffffffc0203c1a <swapfs_write+0x5c>
ffffffffc0203bc8:	00012717          	auipc	a4,0x12
ffffffffc0203bcc:	a8073703          	ld	a4,-1408(a4) # ffffffffc0215648 <max_swap_offset>
ffffffffc0203bd0:	04e7f563          	bgeu	a5,a4,ffffffffc0203c1a <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0203bd4:	00012617          	auipc	a2,0x12
ffffffffc0203bd8:	aa463603          	ld	a2,-1372(a2) # ffffffffc0215678 <pages>
ffffffffc0203bdc:	8d91                	sub	a1,a1,a2
ffffffffc0203bde:	4065d613          	srai	a2,a1,0x6
ffffffffc0203be2:	00003717          	auipc	a4,0x3
ffffffffc0203be6:	cf673703          	ld	a4,-778(a4) # ffffffffc02068d8 <nbase>
ffffffffc0203bea:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0203bec:	00c61713          	slli	a4,a2,0xc
ffffffffc0203bf0:	8331                	srli	a4,a4,0xc
ffffffffc0203bf2:	00012697          	auipc	a3,0x12
ffffffffc0203bf6:	a7e6b683          	ld	a3,-1410(a3) # ffffffffc0215670 <npage>
ffffffffc0203bfa:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203bfe:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0203c00:	02d77963          	bgeu	a4,a3,ffffffffc0203c32 <swapfs_write+0x74>
}
ffffffffc0203c04:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c06:	00012797          	auipc	a5,0x12
ffffffffc0203c0a:	a827b783          	ld	a5,-1406(a5) # ffffffffc0215688 <va_pa_offset>
ffffffffc0203c0e:	46a1                	li	a3,8
ffffffffc0203c10:	963e                	add	a2,a2,a5
ffffffffc0203c12:	4505                	li	a0,1
}
ffffffffc0203c14:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c16:	8bffc06f          	j	ffffffffc02004d4 <ide_write_secs>
ffffffffc0203c1a:	86aa                	mv	a3,a0
ffffffffc0203c1c:	00003617          	auipc	a2,0x3
ffffffffc0203c20:	8a460613          	addi	a2,a2,-1884 # ffffffffc02064c0 <buddy_system_pmm_manager+0xf40>
ffffffffc0203c24:	45e5                	li	a1,25
ffffffffc0203c26:	00003517          	auipc	a0,0x3
ffffffffc0203c2a:	88250513          	addi	a0,a0,-1918 # ffffffffc02064a8 <buddy_system_pmm_manager+0xf28>
ffffffffc0203c2e:	d9afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0203c32:	86b2                	mv	a3,a2
ffffffffc0203c34:	06900593          	li	a1,105
ffffffffc0203c38:	00002617          	auipc	a2,0x2
ffffffffc0203c3c:	be060613          	addi	a2,a2,-1056 # ffffffffc0205818 <buddy_system_pmm_manager+0x298>
ffffffffc0203c40:	00002517          	auipc	a0,0x2
ffffffffc0203c44:	bc850513          	addi	a0,a0,-1080 # ffffffffc0205808 <buddy_system_pmm_manager+0x288>
ffffffffc0203c48:	d80fc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203c4c <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0203c4c:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0203c50:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0203c54:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0203c56:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0203c58:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0203c5c:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0203c60:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0203c64:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0203c68:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0203c6c:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0203c70:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0203c74:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0203c78:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0203c7c:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0203c80:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0203c84:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0203c88:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0203c8a:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0203c8c:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0203c90:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0203c94:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0203c98:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0203c9c:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0203ca0:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0203ca4:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0203ca8:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0203cac:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0203cb0:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0203cb4:	8082                	ret

ffffffffc0203cb6 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203cb6:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203cb8:	9402                	jalr	s0

	jal do_exit
ffffffffc0203cba:	3c8000ef          	jal	ra,ffffffffc0204082 <do_exit>

ffffffffc0203cbe <alloc_proc>:
/* 
 * alloc_proc - alloc a proc_struct and init all fields of proc_struct
 * 功能:创建一个proc_struct并初始化proc_struct的所有成员变量
 */
static struct proc_struct *
alloc_proc(void) {
ffffffffc0203cbe:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203cc0:	0e800513          	li	a0,232
alloc_proc(void) {
ffffffffc0203cc4:	e022                	sd	s0,0(sp)
ffffffffc0203cc6:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203cc8:	ef8fe0ef          	jal	ra,ffffffffc02023c0 <kmalloc>
ffffffffc0203ccc:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0203cce:	c521                	beqz	a0,ffffffffc0203d16 <alloc_proc+0x58>
     *       uint32_t flags;                             // 进程标志
     *       char name[PROC_NAME_LEN + 1];               // 进程名称
     */
    //注:初始化是指产生一个空的结构体(或许与c不允许在定义初始化默认值有关),两个memset初始化的变量参考自proc_init()
    //   附注:初始化的具体严格要求参考proc_init()的相关检查语句。
    proc->state        = PROC_UNINIT;
ffffffffc0203cd0:	57fd                	li	a5,-1
ffffffffc0203cd2:	1782                	slli	a5,a5,0x20
ffffffffc0203cd4:	e11c                	sd	a5,0(a0)
    proc->runs         = 0; 
    proc->kstack       = 0;    
    proc->need_resched = 0;
    proc->parent       = NULL;
    proc->mm           = NULL;
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0203cd6:	07000613          	li	a2,112
ffffffffc0203cda:	4581                	li	a1,0
    proc->runs         = 0; 
ffffffffc0203cdc:	00052423          	sw	zero,8(a0)
    proc->kstack       = 0;    
ffffffffc0203ce0:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc0203ce4:	00052c23          	sw	zero,24(a0)
    proc->parent       = NULL;
ffffffffc0203ce8:	02053023          	sd	zero,32(a0)
    proc->mm           = NULL;
ffffffffc0203cec:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0203cf0:	03050513          	addi	a0,a0,48
ffffffffc0203cf4:	756000ef          	jal	ra,ffffffffc020444a <memset>
    proc->tf           = NULL;
    proc->cr3          = boot_cr3;
ffffffffc0203cf8:	00012797          	auipc	a5,0x12
ffffffffc0203cfc:	9687b783          	ld	a5,-1688(a5) # ffffffffc0215660 <boot_cr3>
    proc->tf           = NULL;
ffffffffc0203d00:	0a043023          	sd	zero,160(s0)
    proc->cr3          = boot_cr3;
ffffffffc0203d04:	f45c                	sd	a5,168(s0)
    proc->flags        = 0;
ffffffffc0203d06:	0a042823          	sw	zero,176(s0)
    memset(proc->name, 0, PROC_NAME_LEN+1);                      
ffffffffc0203d0a:	4641                	li	a2,16
ffffffffc0203d0c:	4581                	li	a1,0
ffffffffc0203d0e:	0b440513          	addi	a0,s0,180
ffffffffc0203d12:	738000ef          	jal	ra,ffffffffc020444a <memset>
//################################################################################
    }
    return proc;
}
ffffffffc0203d16:	60a2                	ld	ra,8(sp)
ffffffffc0203d18:	8522                	mv	a0,s0
ffffffffc0203d1a:	6402                	ld	s0,0(sp)
ffffffffc0203d1c:	0141                	addi	sp,sp,16
ffffffffc0203d1e:	8082                	ret

ffffffffc0203d20 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0203d20:	00012797          	auipc	a5,0x12
ffffffffc0203d24:	9707b783          	ld	a5,-1680(a5) # ffffffffc0215690 <current>
ffffffffc0203d28:	73c8                	ld	a0,160(a5)
ffffffffc0203d2a:	e43fc06f          	j	ffffffffc0200b6c <forkrets>

ffffffffc0203d2e <init_main>:

/* init_main - the second kernel thread used to create user_main kernel threads
 * 功能:用于创建第二个内核线程user_main
 */
static int
init_main(void *arg) {
ffffffffc0203d2e:	7179                	addi	sp,sp,-48
ffffffffc0203d30:	ec26                	sd	s1,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc0203d32:	00012497          	auipc	s1,0x12
ffffffffc0203d36:	8c648493          	addi	s1,s1,-1850 # ffffffffc02155f8 <name.2>
init_main(void *arg) {
ffffffffc0203d3a:	f022                	sd	s0,32(sp)
ffffffffc0203d3c:	e84a                	sd	s2,16(sp)
ffffffffc0203d3e:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0203d40:	00012917          	auipc	s2,0x12
ffffffffc0203d44:	95093903          	ld	s2,-1712(s2) # ffffffffc0215690 <current>
    memset(name, 0, sizeof(name));
ffffffffc0203d48:	4641                	li	a2,16
ffffffffc0203d4a:	4581                	li	a1,0
ffffffffc0203d4c:	8526                	mv	a0,s1
init_main(void *arg) {
ffffffffc0203d4e:	f406                	sd	ra,40(sp)
ffffffffc0203d50:	e44e                	sd	s3,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0203d52:	00492983          	lw	s3,4(s2)
    memset(name, 0, sizeof(name));
ffffffffc0203d56:	6f4000ef          	jal	ra,ffffffffc020444a <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0203d5a:	0b490593          	addi	a1,s2,180
ffffffffc0203d5e:	463d                	li	a2,15
ffffffffc0203d60:	8526                	mv	a0,s1
ffffffffc0203d62:	6fa000ef          	jal	ra,ffffffffc020445c <memcpy>
ffffffffc0203d66:	862a                	mv	a2,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0203d68:	85ce                	mv	a1,s3
ffffffffc0203d6a:	00002517          	auipc	a0,0x2
ffffffffc0203d6e:	77650513          	addi	a0,a0,1910 # ffffffffc02064e0 <buddy_system_pmm_manager+0xf60>
ffffffffc0203d72:	b5afc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc0203d76:	85a2                	mv	a1,s0
ffffffffc0203d78:	00002517          	auipc	a0,0x2
ffffffffc0203d7c:	79050513          	addi	a0,a0,1936 # ffffffffc0206508 <buddy_system_pmm_manager+0xf88>
ffffffffc0203d80:	b4cfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc0203d84:	00002517          	auipc	a0,0x2
ffffffffc0203d88:	79450513          	addi	a0,a0,1940 # ffffffffc0206518 <buddy_system_pmm_manager+0xf98>
ffffffffc0203d8c:	b40fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
}
ffffffffc0203d90:	70a2                	ld	ra,40(sp)
ffffffffc0203d92:	7402                	ld	s0,32(sp)
ffffffffc0203d94:	64e2                	ld	s1,24(sp)
ffffffffc0203d96:	6942                	ld	s2,16(sp)
ffffffffc0203d98:	69a2                	ld	s3,8(sp)
ffffffffc0203d9a:	4501                	li	a0,0
ffffffffc0203d9c:	6145                	addi	sp,sp,48
ffffffffc0203d9e:	8082                	ret

ffffffffc0203da0 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0203da0:	7179                	addi	sp,sp,-48
ffffffffc0203da2:	ec4a                	sd	s2,24(sp)
    if (proc != current) 
ffffffffc0203da4:	00012917          	auipc	s2,0x12
ffffffffc0203da8:	8ec90913          	addi	s2,s2,-1812 # ffffffffc0215690 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0203dac:	f026                	sd	s1,32(sp)
    if (proc != current) 
ffffffffc0203dae:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0203db2:	f406                	sd	ra,40(sp)
ffffffffc0203db4:	e84e                	sd	s3,16(sp)
    if (proc != current) 
ffffffffc0203db6:	02a48963          	beq	s1,a0,ffffffffc0203de8 <proc_run+0x48>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203dba:	100027f3          	csrr	a5,sstatus
ffffffffc0203dbe:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203dc0:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203dc2:	e3a1                	bnez	a5,ffffffffc0203e02 <proc_run+0x62>
            lcr3(proc->cr3);
ffffffffc0203dc4:	755c                	ld	a5,168(a0)

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc0203dc6:	80000737          	lui	a4,0x80000
            current = proc;
ffffffffc0203dca:	00a93023          	sd	a0,0(s2)
ffffffffc0203dce:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc0203dd2:	8fd9                	or	a5,a5,a4
ffffffffc0203dd4:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc0203dd8:	03050593          	addi	a1,a0,48
ffffffffc0203ddc:	03048513          	addi	a0,s1,48
ffffffffc0203de0:	e6dff0ef          	jal	ra,ffffffffc0203c4c <switch_to>
    if (flag) {
ffffffffc0203de4:	00099863          	bnez	s3,ffffffffc0203df4 <proc_run+0x54>
}
ffffffffc0203de8:	70a2                	ld	ra,40(sp)
ffffffffc0203dea:	7482                	ld	s1,32(sp)
ffffffffc0203dec:	6962                	ld	s2,24(sp)
ffffffffc0203dee:	69c2                	ld	s3,16(sp)
ffffffffc0203df0:	6145                	addi	sp,sp,48
ffffffffc0203df2:	8082                	ret
ffffffffc0203df4:	70a2                	ld	ra,40(sp)
ffffffffc0203df6:	7482                	ld	s1,32(sp)
ffffffffc0203df8:	6962                	ld	s2,24(sp)
ffffffffc0203dfa:	69c2                	ld	s3,16(sp)
ffffffffc0203dfc:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0203dfe:	fc0fc06f          	j	ffffffffc02005be <intr_enable>
ffffffffc0203e02:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203e04:	fc0fc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        return 1;
ffffffffc0203e08:	6522                	ld	a0,8(sp)
ffffffffc0203e0a:	4985                	li	s3,1
ffffffffc0203e0c:	bf65                	j	ffffffffc0203dc4 <proc_run+0x24>

ffffffffc0203e0e <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0203e0e:	7179                	addi	sp,sp,-48
ffffffffc0203e10:	e44e                	sd	s3,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0203e12:	00012997          	auipc	s3,0x12
ffffffffc0203e16:	89698993          	addi	s3,s3,-1898 # ffffffffc02156a8 <nr_process>
ffffffffc0203e1a:	0009a703          	lw	a4,0(s3)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0203e1e:	f406                	sd	ra,40(sp)
ffffffffc0203e20:	f022                	sd	s0,32(sp)
ffffffffc0203e22:	ec26                	sd	s1,24(sp)
ffffffffc0203e24:	e84a                	sd	s2,16(sp)
ffffffffc0203e26:	e052                	sd	s4,0(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0203e28:	6785                	lui	a5,0x1
ffffffffc0203e2a:	1cf75363          	bge	a4,a5,ffffffffc0203ff0 <do_fork+0x1e2>
ffffffffc0203e2e:	892e                	mv	s2,a1
ffffffffc0203e30:	8432                	mv	s0,a2
    proc=alloc_proc();//1
ffffffffc0203e32:	e8dff0ef          	jal	ra,ffffffffc0203cbe <alloc_proc>
    if (++ last_pid >= MAX_PID) {
ffffffffc0203e36:	00006897          	auipc	a7,0x6
ffffffffc0203e3a:	20a88893          	addi	a7,a7,522 # ffffffffc020a040 <last_pid.1>
ffffffffc0203e3e:	0008a783          	lw	a5,0(a7)
    proc->parent=current;
ffffffffc0203e42:	00012a17          	auipc	s4,0x12
ffffffffc0203e46:	84ea0a13          	addi	s4,s4,-1970 # ffffffffc0215690 <current>
ffffffffc0203e4a:	000a3703          	ld	a4,0(s4)
    if (++ last_pid >= MAX_PID) {
ffffffffc0203e4e:	0017881b          	addiw	a6,a5,1
ffffffffc0203e52:	0108a023          	sw	a6,0(a7)
    proc->parent=current;
ffffffffc0203e56:	f118                	sd	a4,32(a0)
    if (++ last_pid >= MAX_PID) {
ffffffffc0203e58:	6789                	lui	a5,0x2
    proc=alloc_proc();//1
ffffffffc0203e5a:	84aa                	mv	s1,a0
    if (++ last_pid >= MAX_PID) {
ffffffffc0203e5c:	10f85763          	bge	a6,a5,ffffffffc0203f6a <do_fork+0x15c>
    if (last_pid >= next_safe) {
ffffffffc0203e60:	00006e17          	auipc	t3,0x6
ffffffffc0203e64:	1e4e0e13          	addi	t3,t3,484 # ffffffffc020a044 <next_safe.0>
ffffffffc0203e68:	000e2783          	lw	a5,0(t3)
ffffffffc0203e6c:	10f85763          	bge	a6,a5,ffffffffc0203f7a <do_fork+0x16c>
    proc->pid=get_pid();
ffffffffc0203e70:	0104a223          	sw	a6,4(s1)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0203e74:	4509                	li	a0,2
ffffffffc0203e76:	b4ffe0ef          	jal	ra,ffffffffc02029c4 <alloc_pages>
    if (page != NULL) {
ffffffffc0203e7a:	cd0d                	beqz	a0,ffffffffc0203eb4 <do_fork+0xa6>
    return page - pages + nbase;
ffffffffc0203e7c:	00011697          	auipc	a3,0x11
ffffffffc0203e80:	7fc6b683          	ld	a3,2044(a3) # ffffffffc0215678 <pages>
ffffffffc0203e84:	40d506b3          	sub	a3,a0,a3
ffffffffc0203e88:	8699                	srai	a3,a3,0x6
ffffffffc0203e8a:	00003517          	auipc	a0,0x3
ffffffffc0203e8e:	a4e53503          	ld	a0,-1458(a0) # ffffffffc02068d8 <nbase>
ffffffffc0203e92:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0203e94:	00c69793          	slli	a5,a3,0xc
ffffffffc0203e98:	83b1                	srli	a5,a5,0xc
ffffffffc0203e9a:	00011717          	auipc	a4,0x11
ffffffffc0203e9e:	7d673703          	ld	a4,2006(a4) # ffffffffc0215670 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0203ea2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203ea4:	16e7fb63          	bgeu	a5,a4,ffffffffc020401a <do_fork+0x20c>
ffffffffc0203ea8:	00011797          	auipc	a5,0x11
ffffffffc0203eac:	7e07b783          	ld	a5,2016(a5) # ffffffffc0215688 <va_pa_offset>
ffffffffc0203eb0:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0203eb2:	e894                	sd	a3,16(s1)
    assert(current->mm == NULL);
ffffffffc0203eb4:	000a3783          	ld	a5,0(s4)
ffffffffc0203eb8:	779c                	ld	a5,40(a5)
ffffffffc0203eba:	14079063          	bnez	a5,ffffffffc0203ffa <do_fork+0x1ec>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0203ebe:	6898                	ld	a4,16(s1)
ffffffffc0203ec0:	6789                	lui	a5,0x2
ffffffffc0203ec2:	ee078793          	addi	a5,a5,-288 # 1ee0 <kern_entry-0xffffffffc01fe120>
ffffffffc0203ec6:	973e                	add	a4,a4,a5
    *(proc->tf) = *tf;
ffffffffc0203ec8:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0203eca:	f0d8                	sd	a4,160(s1)
    *(proc->tf) = *tf;
ffffffffc0203ecc:	87ba                	mv	a5,a4
ffffffffc0203ece:	12040893          	addi	a7,s0,288
ffffffffc0203ed2:	00063803          	ld	a6,0(a2)
ffffffffc0203ed6:	6608                	ld	a0,8(a2)
ffffffffc0203ed8:	6a0c                	ld	a1,16(a2)
ffffffffc0203eda:	6e14                	ld	a3,24(a2)
ffffffffc0203edc:	0107b023          	sd	a6,0(a5)
ffffffffc0203ee0:	e788                	sd	a0,8(a5)
ffffffffc0203ee2:	eb8c                	sd	a1,16(a5)
ffffffffc0203ee4:	ef94                	sd	a3,24(a5)
ffffffffc0203ee6:	02060613          	addi	a2,a2,32
ffffffffc0203eea:	02078793          	addi	a5,a5,32
ffffffffc0203eee:	ff1612e3          	bne	a2,a7,ffffffffc0203ed2 <do_fork+0xc4>
    proc->tf->gpr.a0 = 0;
ffffffffc0203ef2:	04073823          	sd	zero,80(a4)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0203ef6:	0e090163          	beqz	s2,ffffffffc0203fd8 <do_fork+0x1ca>
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0203efa:	40c8                	lw	a0,4(s1)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0203efc:	00000797          	auipc	a5,0x0
ffffffffc0203f00:	e2478793          	addi	a5,a5,-476 # ffffffffc0203d20 <forkret>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0203f04:	01273823          	sd	s2,16(a4)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0203f08:	45a9                	li	a1,10
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0203f0a:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0203f0c:	fc98                	sd	a4,56(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0203f0e:	179000ef          	jal	ra,ffffffffc0204886 <hash32>
ffffffffc0203f12:	02051793          	slli	a5,a0,0x20
ffffffffc0203f16:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0203f1a:	0000d797          	auipc	a5,0xd
ffffffffc0203f1e:	6de78793          	addi	a5,a5,1758 # ffffffffc02115f8 <hash_list>
ffffffffc0203f22:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0203f24:	6514                	ld	a3,8(a0)
ffffffffc0203f26:	0d848793          	addi	a5,s1,216
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203f2a:	00011717          	auipc	a4,0x11
ffffffffc0203f2e:	6de70713          	addi	a4,a4,1758 # ffffffffc0215608 <proc_list>
    prev->next = next->prev = elm;
ffffffffc0203f32:	e29c                	sd	a5,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203f34:	6310                	ld	a2,0(a4)
    prev->next = next->prev = elm;
ffffffffc0203f36:	e51c                	sd	a5,8(a0)
    nr_process+=1;
ffffffffc0203f38:	0009a783          	lw	a5,0(s3)
    elm->next = next;
ffffffffc0203f3c:	f0f4                	sd	a3,224(s1)
    elm->prev = prev;
ffffffffc0203f3e:	ece8                	sd	a0,216(s1)
    list_add_before(&proc_list,&proc->list_link);
ffffffffc0203f40:	0c848693          	addi	a3,s1,200
    prev->next = next->prev = elm;
ffffffffc0203f44:	e614                	sd	a3,8(a2)
    nr_process+=1;
ffffffffc0203f46:	2785                	addiw	a5,a5,1
    wakeup_proc(proc);//6
ffffffffc0203f48:	8526                	mv	a0,s1
    elm->next = next;
ffffffffc0203f4a:	e8f8                	sd	a4,208(s1)
    elm->prev = prev;
ffffffffc0203f4c:	e4f0                	sd	a2,200(s1)
    prev->next = next->prev = elm;
ffffffffc0203f4e:	e314                	sd	a3,0(a4)
    nr_process+=1;
ffffffffc0203f50:	00f9a023          	sw	a5,0(s3)
    wakeup_proc(proc);//6
ffffffffc0203f54:	3b4000ef          	jal	ra,ffffffffc0204308 <wakeup_proc>
    ret=proc->pid;
ffffffffc0203f58:	40c8                	lw	a0,4(s1)
}
ffffffffc0203f5a:	70a2                	ld	ra,40(sp)
ffffffffc0203f5c:	7402                	ld	s0,32(sp)
ffffffffc0203f5e:	64e2                	ld	s1,24(sp)
ffffffffc0203f60:	6942                	ld	s2,16(sp)
ffffffffc0203f62:	69a2                	ld	s3,8(sp)
ffffffffc0203f64:	6a02                	ld	s4,0(sp)
ffffffffc0203f66:	6145                	addi	sp,sp,48
ffffffffc0203f68:	8082                	ret
        last_pid = 1;
ffffffffc0203f6a:	4785                	li	a5,1
ffffffffc0203f6c:	00f8a023          	sw	a5,0(a7)
        goto inside;
ffffffffc0203f70:	4805                	li	a6,1
ffffffffc0203f72:	00006e17          	auipc	t3,0x6
ffffffffc0203f76:	0d2e0e13          	addi	t3,t3,210 # ffffffffc020a044 <next_safe.0>
    return listelm->next;
ffffffffc0203f7a:	00011617          	auipc	a2,0x11
ffffffffc0203f7e:	68e60613          	addi	a2,a2,1678 # ffffffffc0215608 <proc_list>
ffffffffc0203f82:	00863e83          	ld	t4,8(a2)
        next_safe = MAX_PID;
ffffffffc0203f86:	6789                	lui	a5,0x2
ffffffffc0203f88:	00fe2023          	sw	a5,0(t3)
ffffffffc0203f8c:	86c2                	mv	a3,a6
ffffffffc0203f8e:	4501                	li	a0,0
        while ((le = list_next(le)) != list) {
ffffffffc0203f90:	6f09                	lui	t5,0x2
ffffffffc0203f92:	04ce8a63          	beq	t4,a2,ffffffffc0203fe6 <do_fork+0x1d8>
ffffffffc0203f96:	832a                	mv	t1,a0
ffffffffc0203f98:	87f6                	mv	a5,t4
ffffffffc0203f9a:	6589                	lui	a1,0x2
ffffffffc0203f9c:	a811                	j	ffffffffc0203fb0 <do_fork+0x1a2>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0203f9e:	00e6d663          	bge	a3,a4,ffffffffc0203faa <do_fork+0x19c>
ffffffffc0203fa2:	00b75463          	bge	a4,a1,ffffffffc0203faa <do_fork+0x19c>
ffffffffc0203fa6:	85ba                	mv	a1,a4
ffffffffc0203fa8:	4305                	li	t1,1
ffffffffc0203faa:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0203fac:	00c78d63          	beq	a5,a2,ffffffffc0203fc6 <do_fork+0x1b8>
            if (proc->pid == last_pid) {
ffffffffc0203fb0:	f3c7a703          	lw	a4,-196(a5) # 1f3c <kern_entry-0xffffffffc01fe0c4>
ffffffffc0203fb4:	fee695e3          	bne	a3,a4,ffffffffc0203f9e <do_fork+0x190>
                if (++ last_pid >= next_safe) {
ffffffffc0203fb8:	2685                	addiw	a3,a3,1
ffffffffc0203fba:	02b6d163          	bge	a3,a1,ffffffffc0203fdc <do_fork+0x1ce>
ffffffffc0203fbe:	679c                	ld	a5,8(a5)
ffffffffc0203fc0:	4505                	li	a0,1
        while ((le = list_next(le)) != list) {
ffffffffc0203fc2:	fec797e3          	bne	a5,a2,ffffffffc0203fb0 <do_fork+0x1a2>
ffffffffc0203fc6:	c501                	beqz	a0,ffffffffc0203fce <do_fork+0x1c0>
ffffffffc0203fc8:	00d8a023          	sw	a3,0(a7)
ffffffffc0203fcc:	8836                	mv	a6,a3
ffffffffc0203fce:	ea0301e3          	beqz	t1,ffffffffc0203e70 <do_fork+0x62>
ffffffffc0203fd2:	00be2023          	sw	a1,0(t3)
ffffffffc0203fd6:	bd69                	j	ffffffffc0203e70 <do_fork+0x62>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0203fd8:	893a                	mv	s2,a4
ffffffffc0203fda:	b705                	j	ffffffffc0203efa <do_fork+0xec>
                    if (last_pid >= MAX_PID) {
ffffffffc0203fdc:	01e6c363          	blt	a3,t5,ffffffffc0203fe2 <do_fork+0x1d4>
                        last_pid = 1;
ffffffffc0203fe0:	4685                	li	a3,1
                    goto repeat;
ffffffffc0203fe2:	4505                	li	a0,1
ffffffffc0203fe4:	b77d                	j	ffffffffc0203f92 <do_fork+0x184>
ffffffffc0203fe6:	c519                	beqz	a0,ffffffffc0203ff4 <do_fork+0x1e6>
ffffffffc0203fe8:	00d8a023          	sw	a3,0(a7)
    return last_pid;
ffffffffc0203fec:	8836                	mv	a6,a3
ffffffffc0203fee:	b549                	j	ffffffffc0203e70 <do_fork+0x62>
    int ret = -E_NO_FREE_PROC;
ffffffffc0203ff0:	556d                	li	a0,-5
    return ret;
ffffffffc0203ff2:	b7a5                	j	ffffffffc0203f5a <do_fork+0x14c>
    return last_pid;
ffffffffc0203ff4:	0008a803          	lw	a6,0(a7)
ffffffffc0203ff8:	bda5                	j	ffffffffc0203e70 <do_fork+0x62>
    assert(current->mm == NULL);
ffffffffc0203ffa:	00002697          	auipc	a3,0x2
ffffffffc0203ffe:	53e68693          	addi	a3,a3,1342 # ffffffffc0206538 <buddy_system_pmm_manager+0xfb8>
ffffffffc0204002:	00001617          	auipc	a2,0x1
ffffffffc0204006:	2f660613          	addi	a2,a2,758 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020400a:	12600593          	li	a1,294
ffffffffc020400e:	00002517          	auipc	a0,0x2
ffffffffc0204012:	54250513          	addi	a0,a0,1346 # ffffffffc0206550 <buddy_system_pmm_manager+0xfd0>
ffffffffc0204016:	9b2fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc020401a:	00001617          	auipc	a2,0x1
ffffffffc020401e:	7fe60613          	addi	a2,a2,2046 # ffffffffc0205818 <buddy_system_pmm_manager+0x298>
ffffffffc0204022:	06900593          	li	a1,105
ffffffffc0204026:	00001517          	auipc	a0,0x1
ffffffffc020402a:	7e250513          	addi	a0,a0,2018 # ffffffffc0205808 <buddy_system_pmm_manager+0x288>
ffffffffc020402e:	99afc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0204032 <kernel_thread>:
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0204032:	7129                	addi	sp,sp,-320
ffffffffc0204034:	fa22                	sd	s0,304(sp)
ffffffffc0204036:	f626                	sd	s1,296(sp)
ffffffffc0204038:	f24a                	sd	s2,288(sp)
ffffffffc020403a:	84ae                	mv	s1,a1
ffffffffc020403c:	892a                	mv	s2,a0
ffffffffc020403e:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204040:	4581                	li	a1,0
ffffffffc0204042:	12000613          	li	a2,288
ffffffffc0204046:	850a                	mv	a0,sp
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0204048:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020404a:	400000ef          	jal	ra,ffffffffc020444a <memset>
    tf.gpr.s0 = (uintptr_t)fn; // s0 寄存器保存函数指针
ffffffffc020404e:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg; // s1 寄存器保存函数参数
ffffffffc0204050:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204052:	100027f3          	csrr	a5,sstatus
ffffffffc0204056:	edd7f793          	andi	a5,a5,-291
ffffffffc020405a:	1207e793          	ori	a5,a5,288
ffffffffc020405e:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204060:	860a                	mv	a2,sp
ffffffffc0204062:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204066:	00000797          	auipc	a5,0x0
ffffffffc020406a:	c5078793          	addi	a5,a5,-944 # ffffffffc0203cb6 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020406e:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204070:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204072:	d9dff0ef          	jal	ra,ffffffffc0203e0e <do_fork>
}
ffffffffc0204076:	70f2                	ld	ra,312(sp)
ffffffffc0204078:	7452                	ld	s0,304(sp)
ffffffffc020407a:	74b2                	ld	s1,296(sp)
ffffffffc020407c:	7912                	ld	s2,288(sp)
ffffffffc020407e:	6131                	addi	sp,sp,320
ffffffffc0204080:	8082                	ret

ffffffffc0204082 <do_exit>:
do_exit(int error_code) {
ffffffffc0204082:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc0204084:	00002617          	auipc	a2,0x2
ffffffffc0204088:	4e460613          	addi	a2,a2,1252 # ffffffffc0206568 <buddy_system_pmm_manager+0xfe8>
ffffffffc020408c:	18500593          	li	a1,389
ffffffffc0204090:	00002517          	auipc	a0,0x2
ffffffffc0204094:	4c050513          	addi	a0,a0,1216 # ffffffffc0206550 <buddy_system_pmm_manager+0xfd0>
do_exit(int error_code) {
ffffffffc0204098:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc020409a:	92efc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020409e <proc_init>:
/* proc_init - set up the first kernel thread idleproc "idle" by itself and 
 *           - create the second kernel thread init_main
 * 功能:第一个内核线程<空闲线程(idleproc)>将自己的状态设为空闲，并创建第二个内核线程init_main
 */
void
proc_init(void) {
ffffffffc020409e:	7179                	addi	sp,sp,-48
ffffffffc02040a0:	ec26                	sd	s1,24(sp)
    elm->prev = elm->next = elm;
ffffffffc02040a2:	00011797          	auipc	a5,0x11
ffffffffc02040a6:	56678793          	addi	a5,a5,1382 # ffffffffc0215608 <proc_list>
ffffffffc02040aa:	f406                	sd	ra,40(sp)
ffffffffc02040ac:	f022                	sd	s0,32(sp)
ffffffffc02040ae:	e84a                	sd	s2,16(sp)
ffffffffc02040b0:	e44e                	sd	s3,8(sp)
ffffffffc02040b2:	0000d497          	auipc	s1,0xd
ffffffffc02040b6:	54648493          	addi	s1,s1,1350 # ffffffffc02115f8 <hash_list>
ffffffffc02040ba:	e79c                	sd	a5,8(a5)
ffffffffc02040bc:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc02040be:	00011717          	auipc	a4,0x11
ffffffffc02040c2:	53a70713          	addi	a4,a4,1338 # ffffffffc02155f8 <name.2>
ffffffffc02040c6:	87a6                	mv	a5,s1
ffffffffc02040c8:	e79c                	sd	a5,8(a5)
ffffffffc02040ca:	e39c                	sd	a5,0(a5)
ffffffffc02040cc:	07c1                	addi	a5,a5,16
ffffffffc02040ce:	fef71de3          	bne	a4,a5,ffffffffc02040c8 <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02040d2:	bedff0ef          	jal	ra,ffffffffc0203cbe <alloc_proc>
ffffffffc02040d6:	00011917          	auipc	s2,0x11
ffffffffc02040da:	5c290913          	addi	s2,s2,1474 # ffffffffc0215698 <idleproc>
ffffffffc02040de:	00a93023          	sd	a0,0(s2)
ffffffffc02040e2:	18050d63          	beqz	a0,ffffffffc020427c <proc_init+0x1de>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02040e6:	07000513          	li	a0,112
ffffffffc02040ea:	ad6fe0ef          	jal	ra,ffffffffc02023c0 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02040ee:	07000613          	li	a2,112
ffffffffc02040f2:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02040f4:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02040f6:	354000ef          	jal	ra,ffffffffc020444a <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc02040fa:	00093503          	ld	a0,0(s2)
ffffffffc02040fe:	85a2                	mv	a1,s0
ffffffffc0204100:	07000613          	li	a2,112
ffffffffc0204104:	03050513          	addi	a0,a0,48
ffffffffc0204108:	36c000ef          	jal	ra,ffffffffc0204474 <memcmp>
ffffffffc020410c:	89aa                	mv	s3,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc020410e:	453d                	li	a0,15
ffffffffc0204110:	ab0fe0ef          	jal	ra,ffffffffc02023c0 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204114:	463d                	li	a2,15
ffffffffc0204116:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc0204118:	842a                	mv	s0,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc020411a:	330000ef          	jal	ra,ffffffffc020444a <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc020411e:	00093503          	ld	a0,0(s2)
ffffffffc0204122:	463d                	li	a2,15
ffffffffc0204124:	85a2                	mv	a1,s0
ffffffffc0204126:	0b450513          	addi	a0,a0,180
ffffffffc020412a:	34a000ef          	jal	ra,ffffffffc0204474 <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc020412e:	00093783          	ld	a5,0(s2)
ffffffffc0204132:	00011717          	auipc	a4,0x11
ffffffffc0204136:	52e73703          	ld	a4,1326(a4) # ffffffffc0215660 <boot_cr3>
ffffffffc020413a:	77d4                	ld	a3,168(a5)
ffffffffc020413c:	0ee68463          	beq	a3,a4,ffffffffc0204224 <proc_init+0x186>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0204140:	4709                	li	a4,2
ffffffffc0204142:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204144:	00003717          	auipc	a4,0x3
ffffffffc0204148:	ebc70713          	addi	a4,a4,-324 # ffffffffc0207000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020414c:	0b478413          	addi	s0,a5,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204150:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc0204152:	4705                	li	a4,1
ffffffffc0204154:	cf98                	sw	a4,24(a5)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204156:	4641                	li	a2,16
ffffffffc0204158:	4581                	li	a1,0
ffffffffc020415a:	8522                	mv	a0,s0
ffffffffc020415c:	2ee000ef          	jal	ra,ffffffffc020444a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204160:	463d                	li	a2,15
ffffffffc0204162:	00002597          	auipc	a1,0x2
ffffffffc0204166:	44e58593          	addi	a1,a1,1102 # ffffffffc02065b0 <buddy_system_pmm_manager+0x1030>
ffffffffc020416a:	8522                	mv	a0,s0
ffffffffc020416c:	2f0000ef          	jal	ra,ffffffffc020445c <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0204170:	00011717          	auipc	a4,0x11
ffffffffc0204174:	53870713          	addi	a4,a4,1336 # ffffffffc02156a8 <nr_process>
ffffffffc0204178:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc020417a:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020417e:	4601                	li	a2,0
    nr_process ++;
ffffffffc0204180:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204182:	00002597          	auipc	a1,0x2
ffffffffc0204186:	43658593          	addi	a1,a1,1078 # ffffffffc02065b8 <buddy_system_pmm_manager+0x1038>
ffffffffc020418a:	00000517          	auipc	a0,0x0
ffffffffc020418e:	ba450513          	addi	a0,a0,-1116 # ffffffffc0203d2e <init_main>
    nr_process ++;
ffffffffc0204192:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0204194:	00011797          	auipc	a5,0x11
ffffffffc0204198:	4ed7be23          	sd	a3,1276(a5) # ffffffffc0215690 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020419c:	e97ff0ef          	jal	ra,ffffffffc0204032 <kernel_thread>
ffffffffc02041a0:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc02041a2:	0ea05963          	blez	a0,ffffffffc0204294 <proc_init+0x1f6>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02041a6:	6789                	lui	a5,0x2
ffffffffc02041a8:	fff5071b          	addiw	a4,a0,-1
ffffffffc02041ac:	17f9                	addi	a5,a5,-2
ffffffffc02041ae:	2501                	sext.w	a0,a0
ffffffffc02041b0:	02e7e363          	bltu	a5,a4,ffffffffc02041d6 <proc_init+0x138>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02041b4:	45a9                	li	a1,10
ffffffffc02041b6:	6d0000ef          	jal	ra,ffffffffc0204886 <hash32>
ffffffffc02041ba:	02051793          	slli	a5,a0,0x20
ffffffffc02041be:	01c7d693          	srli	a3,a5,0x1c
ffffffffc02041c2:	96a6                	add	a3,a3,s1
ffffffffc02041c4:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc02041c6:	a029                	j	ffffffffc02041d0 <proc_init+0x132>
            if (proc->pid == pid) {
ffffffffc02041c8:	f2c7a703          	lw	a4,-212(a5) # 1f2c <kern_entry-0xffffffffc01fe0d4>
ffffffffc02041cc:	0a870563          	beq	a4,s0,ffffffffc0204276 <proc_init+0x1d8>
    return listelm->next;
ffffffffc02041d0:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02041d2:	fef69be3          	bne	a3,a5,ffffffffc02041c8 <proc_init+0x12a>
    return NULL;
ffffffffc02041d6:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02041d8:	0b478493          	addi	s1,a5,180
ffffffffc02041dc:	4641                	li	a2,16
ffffffffc02041de:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc02041e0:	00011417          	auipc	s0,0x11
ffffffffc02041e4:	4c040413          	addi	s0,s0,1216 # ffffffffc02156a0 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02041e8:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc02041ea:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02041ec:	25e000ef          	jal	ra,ffffffffc020444a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02041f0:	463d                	li	a2,15
ffffffffc02041f2:	00002597          	auipc	a1,0x2
ffffffffc02041f6:	3f658593          	addi	a1,a1,1014 # ffffffffc02065e8 <buddy_system_pmm_manager+0x1068>
ffffffffc02041fa:	8526                	mv	a0,s1
ffffffffc02041fc:	260000ef          	jal	ra,ffffffffc020445c <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204200:	00093783          	ld	a5,0(s2)
ffffffffc0204204:	c7e1                	beqz	a5,ffffffffc02042cc <proc_init+0x22e>
ffffffffc0204206:	43dc                	lw	a5,4(a5)
ffffffffc0204208:	e3f1                	bnez	a5,ffffffffc02042cc <proc_init+0x22e>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020420a:	601c                	ld	a5,0(s0)
ffffffffc020420c:	c3c5                	beqz	a5,ffffffffc02042ac <proc_init+0x20e>
ffffffffc020420e:	43d8                	lw	a4,4(a5)
ffffffffc0204210:	4785                	li	a5,1
ffffffffc0204212:	08f71d63          	bne	a4,a5,ffffffffc02042ac <proc_init+0x20e>
}
ffffffffc0204216:	70a2                	ld	ra,40(sp)
ffffffffc0204218:	7402                	ld	s0,32(sp)
ffffffffc020421a:	64e2                	ld	s1,24(sp)
ffffffffc020421c:	6942                	ld	s2,16(sp)
ffffffffc020421e:	69a2                	ld	s3,8(sp)
ffffffffc0204220:	6145                	addi	sp,sp,48
ffffffffc0204222:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc0204224:	73d8                	ld	a4,160(a5)
ffffffffc0204226:	ff09                	bnez	a4,ffffffffc0204140 <proc_init+0xa2>
ffffffffc0204228:	f0099ce3          	bnez	s3,ffffffffc0204140 <proc_init+0xa2>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc020422c:	6394                	ld	a3,0(a5)
ffffffffc020422e:	577d                	li	a4,-1
ffffffffc0204230:	1702                	slli	a4,a4,0x20
ffffffffc0204232:	f0e697e3          	bne	a3,a4,ffffffffc0204140 <proc_init+0xa2>
ffffffffc0204236:	4798                	lw	a4,8(a5)
ffffffffc0204238:	f00714e3          	bnez	a4,ffffffffc0204140 <proc_init+0xa2>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc020423c:	6b98                	ld	a4,16(a5)
ffffffffc020423e:	f00711e3          	bnez	a4,ffffffffc0204140 <proc_init+0xa2>
ffffffffc0204242:	4f98                	lw	a4,24(a5)
ffffffffc0204244:	2701                	sext.w	a4,a4
ffffffffc0204246:	ee071de3          	bnez	a4,ffffffffc0204140 <proc_init+0xa2>
ffffffffc020424a:	7398                	ld	a4,32(a5)
ffffffffc020424c:	ee071ae3          	bnez	a4,ffffffffc0204140 <proc_init+0xa2>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc0204250:	7798                	ld	a4,40(a5)
ffffffffc0204252:	ee0717e3          	bnez	a4,ffffffffc0204140 <proc_init+0xa2>
ffffffffc0204256:	0b07a703          	lw	a4,176(a5)
ffffffffc020425a:	8d59                	or	a0,a0,a4
ffffffffc020425c:	0005071b          	sext.w	a4,a0
ffffffffc0204260:	ee0710e3          	bnez	a4,ffffffffc0204140 <proc_init+0xa2>
        cprintf("alloc_proc() correct!\n");
ffffffffc0204264:	00002517          	auipc	a0,0x2
ffffffffc0204268:	33450513          	addi	a0,a0,820 # ffffffffc0206598 <buddy_system_pmm_manager+0x1018>
ffffffffc020426c:	e61fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    idleproc->pid = 0;
ffffffffc0204270:	00093783          	ld	a5,0(s2)
ffffffffc0204274:	b5f1                	j	ffffffffc0204140 <proc_init+0xa2>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204276:	f2878793          	addi	a5,a5,-216
ffffffffc020427a:	bfb9                	j	ffffffffc02041d8 <proc_init+0x13a>
        panic("cannot alloc idleproc.\n");
ffffffffc020427c:	00002617          	auipc	a2,0x2
ffffffffc0204280:	30460613          	addi	a2,a2,772 # ffffffffc0206580 <buddy_system_pmm_manager+0x1000>
ffffffffc0204284:	1a100593          	li	a1,417
ffffffffc0204288:	00002517          	auipc	a0,0x2
ffffffffc020428c:	2c850513          	addi	a0,a0,712 # ffffffffc0206550 <buddy_system_pmm_manager+0xfd0>
ffffffffc0204290:	f39fb0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("create init_main failed.\n");
ffffffffc0204294:	00002617          	auipc	a2,0x2
ffffffffc0204298:	33460613          	addi	a2,a2,820 # ffffffffc02065c8 <buddy_system_pmm_manager+0x1048>
ffffffffc020429c:	1c100593          	li	a1,449
ffffffffc02042a0:	00002517          	auipc	a0,0x2
ffffffffc02042a4:	2b050513          	addi	a0,a0,688 # ffffffffc0206550 <buddy_system_pmm_manager+0xfd0>
ffffffffc02042a8:	f21fb0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02042ac:	00002697          	auipc	a3,0x2
ffffffffc02042b0:	36c68693          	addi	a3,a3,876 # ffffffffc0206618 <buddy_system_pmm_manager+0x1098>
ffffffffc02042b4:	00001617          	auipc	a2,0x1
ffffffffc02042b8:	04460613          	addi	a2,a2,68 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02042bc:	1c800593          	li	a1,456
ffffffffc02042c0:	00002517          	auipc	a0,0x2
ffffffffc02042c4:	29050513          	addi	a0,a0,656 # ffffffffc0206550 <buddy_system_pmm_manager+0xfd0>
ffffffffc02042c8:	f01fb0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02042cc:	00002697          	auipc	a3,0x2
ffffffffc02042d0:	32468693          	addi	a3,a3,804 # ffffffffc02065f0 <buddy_system_pmm_manager+0x1070>
ffffffffc02042d4:	00001617          	auipc	a2,0x1
ffffffffc02042d8:	02460613          	addi	a2,a2,36 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc02042dc:	1c700593          	li	a1,455
ffffffffc02042e0:	00002517          	auipc	a0,0x2
ffffffffc02042e4:	27050513          	addi	a0,a0,624 # ffffffffc0206550 <buddy_system_pmm_manager+0xfd0>
ffffffffc02042e8:	ee1fb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02042ec <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc02042ec:	1141                	addi	sp,sp,-16
ffffffffc02042ee:	e022                	sd	s0,0(sp)
ffffffffc02042f0:	e406                	sd	ra,8(sp)
ffffffffc02042f2:	00011417          	auipc	s0,0x11
ffffffffc02042f6:	39e40413          	addi	s0,s0,926 # ffffffffc0215690 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc02042fa:	6018                	ld	a4,0(s0)
ffffffffc02042fc:	4f1c                	lw	a5,24(a4)
ffffffffc02042fe:	2781                	sext.w	a5,a5
ffffffffc0204300:	dff5                	beqz	a5,ffffffffc02042fc <cpu_idle+0x10>
            schedule();
ffffffffc0204302:	038000ef          	jal	ra,ffffffffc020433a <schedule>
ffffffffc0204306:	bfd5                	j	ffffffffc02042fa <cpu_idle+0xe>

ffffffffc0204308 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204308:	411c                	lw	a5,0(a0)
ffffffffc020430a:	4705                	li	a4,1
ffffffffc020430c:	37f9                	addiw	a5,a5,-2
ffffffffc020430e:	00f77563          	bgeu	a4,a5,ffffffffc0204318 <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc0204312:	4789                	li	a5,2
ffffffffc0204314:	c11c                	sw	a5,0(a0)
ffffffffc0204316:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204318:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020431a:	00002697          	auipc	a3,0x2
ffffffffc020431e:	32668693          	addi	a3,a3,806 # ffffffffc0206640 <buddy_system_pmm_manager+0x10c0>
ffffffffc0204322:	00001617          	auipc	a2,0x1
ffffffffc0204326:	fd660613          	addi	a2,a2,-42 # ffffffffc02052f8 <commands+0x7d0>
ffffffffc020432a:	45a5                	li	a1,9
ffffffffc020432c:	00002517          	auipc	a0,0x2
ffffffffc0204330:	35450513          	addi	a0,a0,852 # ffffffffc0206680 <buddy_system_pmm_manager+0x1100>
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204334:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204336:	e93fb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020433a <schedule>:
}

void
schedule(void) {
ffffffffc020433a:	1141                	addi	sp,sp,-16
ffffffffc020433c:	e406                	sd	ra,8(sp)
ffffffffc020433e:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204340:	100027f3          	csrr	a5,sstatus
ffffffffc0204344:	8b89                	andi	a5,a5,2
ffffffffc0204346:	4401                	li	s0,0
ffffffffc0204348:	efbd                	bnez	a5,ffffffffc02043c6 <schedule+0x8c>
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        // 1．设置当前内核线程current->need_resched为0
        current->need_resched = 0;
ffffffffc020434a:	00011897          	auipc	a7,0x11
ffffffffc020434e:	3468b883          	ld	a7,838(a7) # ffffffffc0215690 <current>
ffffffffc0204352:	0008ac23          	sw	zero,24(a7)
        //  2．在proc_list队列中查找下一个处于“就绪”态的线程或进程next
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204356:	00011517          	auipc	a0,0x11
ffffffffc020435a:	34253503          	ld	a0,834(a0) # ffffffffc0215698 <idleproc>
ffffffffc020435e:	04a88e63          	beq	a7,a0,ffffffffc02043ba <schedule+0x80>
ffffffffc0204362:	0c888693          	addi	a3,a7,200
ffffffffc0204366:	00011617          	auipc	a2,0x11
ffffffffc020436a:	2a260613          	addi	a2,a2,674 # ffffffffc0215608 <proc_list>
        le = last;
ffffffffc020436e:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0204370:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204372:	4809                	li	a6,2
ffffffffc0204374:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0204376:	00c78863          	beq	a5,a2,ffffffffc0204386 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc020437a:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc020437e:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204382:	03070163          	beq	a4,a6,ffffffffc02043a4 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0204386:	fef697e3          	bne	a3,a5,ffffffffc0204374 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020438a:	ed89                	bnez	a1,ffffffffc02043a4 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc020438c:	451c                	lw	a5,8(a0)
ffffffffc020438e:	2785                	addiw	a5,a5,1
ffffffffc0204390:	c51c                	sw	a5,8(a0)
        // 3．找到这样的进程后，就调用proc_run函数，保存当前进程current的执行现场（进程上下文），恢复新进程的执行现场，完成进程切换。
        if (next != current) {
ffffffffc0204392:	00a88463          	beq	a7,a0,ffffffffc020439a <schedule+0x60>
            proc_run(next);
ffffffffc0204396:	a0bff0ef          	jal	ra,ffffffffc0203da0 <proc_run>
    if (flag) {
ffffffffc020439a:	e819                	bnez	s0,ffffffffc02043b0 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020439c:	60a2                	ld	ra,8(sp)
ffffffffc020439e:	6402                	ld	s0,0(sp)
ffffffffc02043a0:	0141                	addi	sp,sp,16
ffffffffc02043a2:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02043a4:	4198                	lw	a4,0(a1)
ffffffffc02043a6:	4789                	li	a5,2
ffffffffc02043a8:	fef712e3          	bne	a4,a5,ffffffffc020438c <schedule+0x52>
ffffffffc02043ac:	852e                	mv	a0,a1
ffffffffc02043ae:	bff9                	j	ffffffffc020438c <schedule+0x52>
}
ffffffffc02043b0:	6402                	ld	s0,0(sp)
ffffffffc02043b2:	60a2                	ld	ra,8(sp)
ffffffffc02043b4:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02043b6:	a08fc06f          	j	ffffffffc02005be <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02043ba:	00011617          	auipc	a2,0x11
ffffffffc02043be:	24e60613          	addi	a2,a2,590 # ffffffffc0215608 <proc_list>
ffffffffc02043c2:	86b2                	mv	a3,a2
ffffffffc02043c4:	b76d                	j	ffffffffc020436e <schedule+0x34>
        intr_disable();
ffffffffc02043c6:	9fefc0ef          	jal	ra,ffffffffc02005c4 <intr_disable>
        return 1;
ffffffffc02043ca:	4405                	li	s0,1
ffffffffc02043cc:	bfbd                	j	ffffffffc020434a <schedule+0x10>

ffffffffc02043ce <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02043ce:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02043d2:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02043d4:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02043d6:	cb81                	beqz	a5,ffffffffc02043e6 <strlen+0x18>
        cnt ++;
ffffffffc02043d8:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02043da:	00a707b3          	add	a5,a4,a0
ffffffffc02043de:	0007c783          	lbu	a5,0(a5)
ffffffffc02043e2:	fbfd                	bnez	a5,ffffffffc02043d8 <strlen+0xa>
ffffffffc02043e4:	8082                	ret
    }
    return cnt;
}
ffffffffc02043e6:	8082                	ret

ffffffffc02043e8 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02043e8:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02043ea:	e589                	bnez	a1,ffffffffc02043f4 <strnlen+0xc>
ffffffffc02043ec:	a811                	j	ffffffffc0204400 <strnlen+0x18>
        cnt ++;
ffffffffc02043ee:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02043f0:	00f58863          	beq	a1,a5,ffffffffc0204400 <strnlen+0x18>
ffffffffc02043f4:	00f50733          	add	a4,a0,a5
ffffffffc02043f8:	00074703          	lbu	a4,0(a4)
ffffffffc02043fc:	fb6d                	bnez	a4,ffffffffc02043ee <strnlen+0x6>
ffffffffc02043fe:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0204400:	852e                	mv	a0,a1
ffffffffc0204402:	8082                	ret

ffffffffc0204404 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204404:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204406:	0005c703          	lbu	a4,0(a1)
ffffffffc020440a:	0785                	addi	a5,a5,1
ffffffffc020440c:	0585                	addi	a1,a1,1
ffffffffc020440e:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204412:	fb75                	bnez	a4,ffffffffc0204406 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204414:	8082                	ret

ffffffffc0204416 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204416:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020441a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020441e:	cb89                	beqz	a5,ffffffffc0204430 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0204420:	0505                	addi	a0,a0,1
ffffffffc0204422:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204424:	fee789e3          	beq	a5,a4,ffffffffc0204416 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204428:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020442c:	9d19                	subw	a0,a0,a4
ffffffffc020442e:	8082                	ret
ffffffffc0204430:	4501                	li	a0,0
ffffffffc0204432:	bfed                	j	ffffffffc020442c <strcmp+0x16>

ffffffffc0204434 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204434:	00054783          	lbu	a5,0(a0)
ffffffffc0204438:	c799                	beqz	a5,ffffffffc0204446 <strchr+0x12>
        if (*s == c) {
ffffffffc020443a:	00f58763          	beq	a1,a5,ffffffffc0204448 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020443e:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0204442:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204444:	fbfd                	bnez	a5,ffffffffc020443a <strchr+0x6>
    }
    return NULL;
ffffffffc0204446:	4501                	li	a0,0
}
ffffffffc0204448:	8082                	ret

ffffffffc020444a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020444a:	ca01                	beqz	a2,ffffffffc020445a <memset+0x10>
ffffffffc020444c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020444e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204450:	0785                	addi	a5,a5,1
ffffffffc0204452:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204456:	fec79de3          	bne	a5,a2,ffffffffc0204450 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020445a:	8082                	ret

ffffffffc020445c <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020445c:	ca19                	beqz	a2,ffffffffc0204472 <memcpy+0x16>
ffffffffc020445e:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204460:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204462:	0005c703          	lbu	a4,0(a1)
ffffffffc0204466:	0585                	addi	a1,a1,1
ffffffffc0204468:	0785                	addi	a5,a5,1
ffffffffc020446a:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020446e:	fec59ae3          	bne	a1,a2,ffffffffc0204462 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204472:	8082                	ret

ffffffffc0204474 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204474:	c205                	beqz	a2,ffffffffc0204494 <memcmp+0x20>
ffffffffc0204476:	962e                	add	a2,a2,a1
ffffffffc0204478:	a019                	j	ffffffffc020447e <memcmp+0xa>
ffffffffc020447a:	00c58d63          	beq	a1,a2,ffffffffc0204494 <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc020447e:	00054783          	lbu	a5,0(a0)
ffffffffc0204482:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204486:	0505                	addi	a0,a0,1
ffffffffc0204488:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc020448a:	fee788e3          	beq	a5,a4,ffffffffc020447a <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020448e:	40e7853b          	subw	a0,a5,a4
ffffffffc0204492:	8082                	ret
    }
    return 0;
ffffffffc0204494:	4501                	li	a0,0
}
ffffffffc0204496:	8082                	ret

ffffffffc0204498 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204498:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020449c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020449e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02044a2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02044a4:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02044a8:	f022                	sd	s0,32(sp)
ffffffffc02044aa:	ec26                	sd	s1,24(sp)
ffffffffc02044ac:	e84a                	sd	s2,16(sp)
ffffffffc02044ae:	f406                	sd	ra,40(sp)
ffffffffc02044b0:	e44e                	sd	s3,8(sp)
ffffffffc02044b2:	84aa                	mv	s1,a0
ffffffffc02044b4:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02044b6:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02044ba:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02044bc:	03067e63          	bgeu	a2,a6,ffffffffc02044f8 <printnum+0x60>
ffffffffc02044c0:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02044c2:	00805763          	blez	s0,ffffffffc02044d0 <printnum+0x38>
ffffffffc02044c6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02044c8:	85ca                	mv	a1,s2
ffffffffc02044ca:	854e                	mv	a0,s3
ffffffffc02044cc:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02044ce:	fc65                	bnez	s0,ffffffffc02044c6 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02044d0:	1a02                	slli	s4,s4,0x20
ffffffffc02044d2:	00002797          	auipc	a5,0x2
ffffffffc02044d6:	1c678793          	addi	a5,a5,454 # ffffffffc0206698 <buddy_system_pmm_manager+0x1118>
ffffffffc02044da:	020a5a13          	srli	s4,s4,0x20
ffffffffc02044de:	9a3e                	add	s4,s4,a5
}
ffffffffc02044e0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02044e2:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02044e6:	70a2                	ld	ra,40(sp)
ffffffffc02044e8:	69a2                	ld	s3,8(sp)
ffffffffc02044ea:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02044ec:	85ca                	mv	a1,s2
ffffffffc02044ee:	87a6                	mv	a5,s1
}
ffffffffc02044f0:	6942                	ld	s2,16(sp)
ffffffffc02044f2:	64e2                	ld	s1,24(sp)
ffffffffc02044f4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02044f6:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02044f8:	03065633          	divu	a2,a2,a6
ffffffffc02044fc:	8722                	mv	a4,s0
ffffffffc02044fe:	f9bff0ef          	jal	ra,ffffffffc0204498 <printnum>
ffffffffc0204502:	b7f9                	j	ffffffffc02044d0 <printnum+0x38>

ffffffffc0204504 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204504:	7119                	addi	sp,sp,-128
ffffffffc0204506:	f4a6                	sd	s1,104(sp)
ffffffffc0204508:	f0ca                	sd	s2,96(sp)
ffffffffc020450a:	ecce                	sd	s3,88(sp)
ffffffffc020450c:	e8d2                	sd	s4,80(sp)
ffffffffc020450e:	e4d6                	sd	s5,72(sp)
ffffffffc0204510:	e0da                	sd	s6,64(sp)
ffffffffc0204512:	fc5e                	sd	s7,56(sp)
ffffffffc0204514:	f06a                	sd	s10,32(sp)
ffffffffc0204516:	fc86                	sd	ra,120(sp)
ffffffffc0204518:	f8a2                	sd	s0,112(sp)
ffffffffc020451a:	f862                	sd	s8,48(sp)
ffffffffc020451c:	f466                	sd	s9,40(sp)
ffffffffc020451e:	ec6e                	sd	s11,24(sp)
ffffffffc0204520:	892a                	mv	s2,a0
ffffffffc0204522:	84ae                	mv	s1,a1
ffffffffc0204524:	8d32                	mv	s10,a2
ffffffffc0204526:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204528:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020452c:	5b7d                	li	s6,-1
ffffffffc020452e:	00002a97          	auipc	s5,0x2
ffffffffc0204532:	196a8a93          	addi	s5,s5,406 # ffffffffc02066c4 <buddy_system_pmm_manager+0x1144>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204536:	00002b97          	auipc	s7,0x2
ffffffffc020453a:	36ab8b93          	addi	s7,s7,874 # ffffffffc02068a0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020453e:	000d4503          	lbu	a0,0(s10)
ffffffffc0204542:	001d0413          	addi	s0,s10,1
ffffffffc0204546:	01350a63          	beq	a0,s3,ffffffffc020455a <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020454a:	c121                	beqz	a0,ffffffffc020458a <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020454c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020454e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204550:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204552:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204556:	ff351ae3          	bne	a0,s3,ffffffffc020454a <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020455a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020455e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204562:	4c81                	li	s9,0
ffffffffc0204564:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0204566:	5c7d                	li	s8,-1
ffffffffc0204568:	5dfd                	li	s11,-1
ffffffffc020456a:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020456e:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204570:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204574:	0ff5f593          	zext.b	a1,a1
ffffffffc0204578:	00140d13          	addi	s10,s0,1
ffffffffc020457c:	04b56263          	bltu	a0,a1,ffffffffc02045c0 <vprintfmt+0xbc>
ffffffffc0204580:	058a                	slli	a1,a1,0x2
ffffffffc0204582:	95d6                	add	a1,a1,s5
ffffffffc0204584:	4194                	lw	a3,0(a1)
ffffffffc0204586:	96d6                	add	a3,a3,s5
ffffffffc0204588:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020458a:	70e6                	ld	ra,120(sp)
ffffffffc020458c:	7446                	ld	s0,112(sp)
ffffffffc020458e:	74a6                	ld	s1,104(sp)
ffffffffc0204590:	7906                	ld	s2,96(sp)
ffffffffc0204592:	69e6                	ld	s3,88(sp)
ffffffffc0204594:	6a46                	ld	s4,80(sp)
ffffffffc0204596:	6aa6                	ld	s5,72(sp)
ffffffffc0204598:	6b06                	ld	s6,64(sp)
ffffffffc020459a:	7be2                	ld	s7,56(sp)
ffffffffc020459c:	7c42                	ld	s8,48(sp)
ffffffffc020459e:	7ca2                	ld	s9,40(sp)
ffffffffc02045a0:	7d02                	ld	s10,32(sp)
ffffffffc02045a2:	6de2                	ld	s11,24(sp)
ffffffffc02045a4:	6109                	addi	sp,sp,128
ffffffffc02045a6:	8082                	ret
            padc = '0';
ffffffffc02045a8:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02045aa:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02045ae:	846a                	mv	s0,s10
ffffffffc02045b0:	00140d13          	addi	s10,s0,1
ffffffffc02045b4:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02045b8:	0ff5f593          	zext.b	a1,a1
ffffffffc02045bc:	fcb572e3          	bgeu	a0,a1,ffffffffc0204580 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02045c0:	85a6                	mv	a1,s1
ffffffffc02045c2:	02500513          	li	a0,37
ffffffffc02045c6:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02045c8:	fff44783          	lbu	a5,-1(s0)
ffffffffc02045cc:	8d22                	mv	s10,s0
ffffffffc02045ce:	f73788e3          	beq	a5,s3,ffffffffc020453e <vprintfmt+0x3a>
ffffffffc02045d2:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02045d6:	1d7d                	addi	s10,s10,-1
ffffffffc02045d8:	ff379de3          	bne	a5,s3,ffffffffc02045d2 <vprintfmt+0xce>
ffffffffc02045dc:	b78d                	j	ffffffffc020453e <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02045de:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02045e2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02045e6:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02045e8:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02045ec:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02045f0:	02d86463          	bltu	a6,a3,ffffffffc0204618 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02045f4:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02045f8:	002c169b          	slliw	a3,s8,0x2
ffffffffc02045fc:	0186873b          	addw	a4,a3,s8
ffffffffc0204600:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204604:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0204606:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020460a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020460c:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204610:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204614:	fed870e3          	bgeu	a6,a3,ffffffffc02045f4 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204618:	f40ddce3          	bgez	s11,ffffffffc0204570 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020461c:	8de2                	mv	s11,s8
ffffffffc020461e:	5c7d                	li	s8,-1
ffffffffc0204620:	bf81                	j	ffffffffc0204570 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0204622:	fffdc693          	not	a3,s11
ffffffffc0204626:	96fd                	srai	a3,a3,0x3f
ffffffffc0204628:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020462c:	00144603          	lbu	a2,1(s0)
ffffffffc0204630:	2d81                	sext.w	s11,s11
ffffffffc0204632:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204634:	bf35                	j	ffffffffc0204570 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0204636:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020463a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020463e:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204640:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204642:	bfd9                	j	ffffffffc0204618 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0204644:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204646:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020464a:	01174463          	blt	a4,a7,ffffffffc0204652 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020464e:	1a088e63          	beqz	a7,ffffffffc020480a <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204652:	000a3603          	ld	a2,0(s4)
ffffffffc0204656:	46c1                	li	a3,16
ffffffffc0204658:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020465a:	2781                	sext.w	a5,a5
ffffffffc020465c:	876e                	mv	a4,s11
ffffffffc020465e:	85a6                	mv	a1,s1
ffffffffc0204660:	854a                	mv	a0,s2
ffffffffc0204662:	e37ff0ef          	jal	ra,ffffffffc0204498 <printnum>
            break;
ffffffffc0204666:	bde1                	j	ffffffffc020453e <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204668:	000a2503          	lw	a0,0(s4)
ffffffffc020466c:	85a6                	mv	a1,s1
ffffffffc020466e:	0a21                	addi	s4,s4,8
ffffffffc0204670:	9902                	jalr	s2
            break;
ffffffffc0204672:	b5f1                	j	ffffffffc020453e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204674:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204676:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020467a:	01174463          	blt	a4,a7,ffffffffc0204682 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020467e:	18088163          	beqz	a7,ffffffffc0204800 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0204682:	000a3603          	ld	a2,0(s4)
ffffffffc0204686:	46a9                	li	a3,10
ffffffffc0204688:	8a2e                	mv	s4,a1
ffffffffc020468a:	bfc1                	j	ffffffffc020465a <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020468c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204690:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204692:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204694:	bdf1                	j	ffffffffc0204570 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0204696:	85a6                	mv	a1,s1
ffffffffc0204698:	02500513          	li	a0,37
ffffffffc020469c:	9902                	jalr	s2
            break;
ffffffffc020469e:	b545                	j	ffffffffc020453e <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02046a0:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02046a4:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02046a6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02046a8:	b5e1                	j	ffffffffc0204570 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02046aa:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02046ac:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02046b0:	01174463          	blt	a4,a7,ffffffffc02046b8 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02046b4:	14088163          	beqz	a7,ffffffffc02047f6 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02046b8:	000a3603          	ld	a2,0(s4)
ffffffffc02046bc:	46a1                	li	a3,8
ffffffffc02046be:	8a2e                	mv	s4,a1
ffffffffc02046c0:	bf69                	j	ffffffffc020465a <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02046c2:	03000513          	li	a0,48
ffffffffc02046c6:	85a6                	mv	a1,s1
ffffffffc02046c8:	e03e                	sd	a5,0(sp)
ffffffffc02046ca:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02046cc:	85a6                	mv	a1,s1
ffffffffc02046ce:	07800513          	li	a0,120
ffffffffc02046d2:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02046d4:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02046d6:	6782                	ld	a5,0(sp)
ffffffffc02046d8:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02046da:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02046de:	bfb5                	j	ffffffffc020465a <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02046e0:	000a3403          	ld	s0,0(s4)
ffffffffc02046e4:	008a0713          	addi	a4,s4,8
ffffffffc02046e8:	e03a                	sd	a4,0(sp)
ffffffffc02046ea:	14040263          	beqz	s0,ffffffffc020482e <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02046ee:	0fb05763          	blez	s11,ffffffffc02047dc <vprintfmt+0x2d8>
ffffffffc02046f2:	02d00693          	li	a3,45
ffffffffc02046f6:	0cd79163          	bne	a5,a3,ffffffffc02047b8 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02046fa:	00044783          	lbu	a5,0(s0)
ffffffffc02046fe:	0007851b          	sext.w	a0,a5
ffffffffc0204702:	cf85                	beqz	a5,ffffffffc020473a <vprintfmt+0x236>
ffffffffc0204704:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204708:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020470c:	000c4563          	bltz	s8,ffffffffc0204716 <vprintfmt+0x212>
ffffffffc0204710:	3c7d                	addiw	s8,s8,-1
ffffffffc0204712:	036c0263          	beq	s8,s6,ffffffffc0204736 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204716:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204718:	0e0c8e63          	beqz	s9,ffffffffc0204814 <vprintfmt+0x310>
ffffffffc020471c:	3781                	addiw	a5,a5,-32
ffffffffc020471e:	0ef47b63          	bgeu	s0,a5,ffffffffc0204814 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0204722:	03f00513          	li	a0,63
ffffffffc0204726:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204728:	000a4783          	lbu	a5,0(s4)
ffffffffc020472c:	3dfd                	addiw	s11,s11,-1
ffffffffc020472e:	0a05                	addi	s4,s4,1
ffffffffc0204730:	0007851b          	sext.w	a0,a5
ffffffffc0204734:	ffe1                	bnez	a5,ffffffffc020470c <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204736:	01b05963          	blez	s11,ffffffffc0204748 <vprintfmt+0x244>
ffffffffc020473a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020473c:	85a6                	mv	a1,s1
ffffffffc020473e:	02000513          	li	a0,32
ffffffffc0204742:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204744:	fe0d9be3          	bnez	s11,ffffffffc020473a <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204748:	6a02                	ld	s4,0(sp)
ffffffffc020474a:	bbd5                	j	ffffffffc020453e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020474c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020474e:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0204752:	01174463          	blt	a4,a7,ffffffffc020475a <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204756:	08088d63          	beqz	a7,ffffffffc02047f0 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020475a:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020475e:	0a044d63          	bltz	s0,ffffffffc0204818 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0204762:	8622                	mv	a2,s0
ffffffffc0204764:	8a66                	mv	s4,s9
ffffffffc0204766:	46a9                	li	a3,10
ffffffffc0204768:	bdcd                	j	ffffffffc020465a <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020476a:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020476e:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204770:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0204772:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204776:	8fb5                	xor	a5,a5,a3
ffffffffc0204778:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020477c:	02d74163          	blt	a4,a3,ffffffffc020479e <vprintfmt+0x29a>
ffffffffc0204780:	00369793          	slli	a5,a3,0x3
ffffffffc0204784:	97de                	add	a5,a5,s7
ffffffffc0204786:	639c                	ld	a5,0(a5)
ffffffffc0204788:	cb99                	beqz	a5,ffffffffc020479e <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020478a:	86be                	mv	a3,a5
ffffffffc020478c:	00000617          	auipc	a2,0x0
ffffffffc0204790:	13c60613          	addi	a2,a2,316 # ffffffffc02048c8 <etext+0x2c>
ffffffffc0204794:	85a6                	mv	a1,s1
ffffffffc0204796:	854a                	mv	a0,s2
ffffffffc0204798:	0ce000ef          	jal	ra,ffffffffc0204866 <printfmt>
ffffffffc020479c:	b34d                	j	ffffffffc020453e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020479e:	00002617          	auipc	a2,0x2
ffffffffc02047a2:	f1a60613          	addi	a2,a2,-230 # ffffffffc02066b8 <buddy_system_pmm_manager+0x1138>
ffffffffc02047a6:	85a6                	mv	a1,s1
ffffffffc02047a8:	854a                	mv	a0,s2
ffffffffc02047aa:	0bc000ef          	jal	ra,ffffffffc0204866 <printfmt>
ffffffffc02047ae:	bb41                	j	ffffffffc020453e <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02047b0:	00002417          	auipc	s0,0x2
ffffffffc02047b4:	f0040413          	addi	s0,s0,-256 # ffffffffc02066b0 <buddy_system_pmm_manager+0x1130>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02047b8:	85e2                	mv	a1,s8
ffffffffc02047ba:	8522                	mv	a0,s0
ffffffffc02047bc:	e43e                	sd	a5,8(sp)
ffffffffc02047be:	c2bff0ef          	jal	ra,ffffffffc02043e8 <strnlen>
ffffffffc02047c2:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02047c6:	01b05b63          	blez	s11,ffffffffc02047dc <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02047ca:	67a2                	ld	a5,8(sp)
ffffffffc02047cc:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02047d0:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02047d2:	85a6                	mv	a1,s1
ffffffffc02047d4:	8552                	mv	a0,s4
ffffffffc02047d6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02047d8:	fe0d9ce3          	bnez	s11,ffffffffc02047d0 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02047dc:	00044783          	lbu	a5,0(s0)
ffffffffc02047e0:	00140a13          	addi	s4,s0,1
ffffffffc02047e4:	0007851b          	sext.w	a0,a5
ffffffffc02047e8:	d3a5                	beqz	a5,ffffffffc0204748 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02047ea:	05e00413          	li	s0,94
ffffffffc02047ee:	bf39                	j	ffffffffc020470c <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02047f0:	000a2403          	lw	s0,0(s4)
ffffffffc02047f4:	b7ad                	j	ffffffffc020475e <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02047f6:	000a6603          	lwu	a2,0(s4)
ffffffffc02047fa:	46a1                	li	a3,8
ffffffffc02047fc:	8a2e                	mv	s4,a1
ffffffffc02047fe:	bdb1                	j	ffffffffc020465a <vprintfmt+0x156>
ffffffffc0204800:	000a6603          	lwu	a2,0(s4)
ffffffffc0204804:	46a9                	li	a3,10
ffffffffc0204806:	8a2e                	mv	s4,a1
ffffffffc0204808:	bd89                	j	ffffffffc020465a <vprintfmt+0x156>
ffffffffc020480a:	000a6603          	lwu	a2,0(s4)
ffffffffc020480e:	46c1                	li	a3,16
ffffffffc0204810:	8a2e                	mv	s4,a1
ffffffffc0204812:	b5a1                	j	ffffffffc020465a <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204814:	9902                	jalr	s2
ffffffffc0204816:	bf09                	j	ffffffffc0204728 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204818:	85a6                	mv	a1,s1
ffffffffc020481a:	02d00513          	li	a0,45
ffffffffc020481e:	e03e                	sd	a5,0(sp)
ffffffffc0204820:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204822:	6782                	ld	a5,0(sp)
ffffffffc0204824:	8a66                	mv	s4,s9
ffffffffc0204826:	40800633          	neg	a2,s0
ffffffffc020482a:	46a9                	li	a3,10
ffffffffc020482c:	b53d                	j	ffffffffc020465a <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020482e:	03b05163          	blez	s11,ffffffffc0204850 <vprintfmt+0x34c>
ffffffffc0204832:	02d00693          	li	a3,45
ffffffffc0204836:	f6d79de3          	bne	a5,a3,ffffffffc02047b0 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020483a:	00002417          	auipc	s0,0x2
ffffffffc020483e:	e7640413          	addi	s0,s0,-394 # ffffffffc02066b0 <buddy_system_pmm_manager+0x1130>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204842:	02800793          	li	a5,40
ffffffffc0204846:	02800513          	li	a0,40
ffffffffc020484a:	00140a13          	addi	s4,s0,1
ffffffffc020484e:	bd6d                	j	ffffffffc0204708 <vprintfmt+0x204>
ffffffffc0204850:	00002a17          	auipc	s4,0x2
ffffffffc0204854:	e61a0a13          	addi	s4,s4,-415 # ffffffffc02066b1 <buddy_system_pmm_manager+0x1131>
ffffffffc0204858:	02800513          	li	a0,40
ffffffffc020485c:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204860:	05e00413          	li	s0,94
ffffffffc0204864:	b565                	j	ffffffffc020470c <vprintfmt+0x208>

ffffffffc0204866 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204866:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204868:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020486c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020486e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204870:	ec06                	sd	ra,24(sp)
ffffffffc0204872:	f83a                	sd	a4,48(sp)
ffffffffc0204874:	fc3e                	sd	a5,56(sp)
ffffffffc0204876:	e0c2                	sd	a6,64(sp)
ffffffffc0204878:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020487a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020487c:	c89ff0ef          	jal	ra,ffffffffc0204504 <vprintfmt>
}
ffffffffc0204880:	60e2                	ld	ra,24(sp)
ffffffffc0204882:	6161                	addi	sp,sp,80
ffffffffc0204884:	8082                	ret

ffffffffc0204886 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204886:	9e3707b7          	lui	a5,0x9e370
ffffffffc020488a:	2785                	addiw	a5,a5,1
ffffffffc020488c:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0204890:	02000793          	li	a5,32
ffffffffc0204894:	9f8d                	subw	a5,a5,a1
}
ffffffffc0204896:	00f5553b          	srlw	a0,a0,a5
ffffffffc020489a:	8082                	ret
