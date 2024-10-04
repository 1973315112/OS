
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
ffffffffc0200036:	02e50513          	addi	a0,a0,46 # ffffffffc020a060 <buf>
ffffffffc020003a:	00015617          	auipc	a2,0x15
ffffffffc020003e:	59260613          	addi	a2,a2,1426 # ffffffffc02155cc <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	1d5040ef          	jal	ra,ffffffffc0204a1e <memset>

    cons_init();                // 初始化命令行
ffffffffc020004e:	508000ef          	jal	ra,ffffffffc0200556 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00005597          	auipc	a1,0x5
ffffffffc0200056:	e1e58593          	addi	a1,a1,-482 # ffffffffc0204e70 <etext>
ffffffffc020005a:	00005517          	auipc	a0,0x5
ffffffffc020005e:	e3650513          	addi	a0,a0,-458 # ffffffffc0204e90 <etext+0x20>
ffffffffc0200062:	076000ef          	jal	ra,ffffffffc02000d8 <cprintf>

    print_kerninfo();           // 打印核心信息
ffffffffc0200066:	1ca000ef          	jal	ra,ffffffffc0200230 <print_kerninfo>
    // grade_backtrace();
    pmm_init();                 // 初始化物理内存管理器
ffffffffc020006a:	408030ef          	jal	ra,ffffffffc0203472 <pmm_init>

    pic_init();                 // 初始化中断控制器(本次的新增)
ffffffffc020006e:	55a000ef          	jal	ra,ffffffffc02005c8 <pic_init>
    
    idt_init();                 // 初始化中断描述符表
ffffffffc0200072:	5d4000ef          	jal	ra,ffffffffc0200646 <idt_init>
    vmm_init();                 // 初始化虚拟内存管理器
ffffffffc0200076:	4e1000ef          	jal	ra,ffffffffc0200d56 <vmm_init>
    
    proc_init();                // 初始化进程表(本次的重点)
ffffffffc020007a:	5f8040ef          	jal	ra,ffffffffc0204672 <proc_init>
    
    ide_init();                 // 初始化磁盘设备
ffffffffc020007e:	430000ef          	jal	ra,ffffffffc02004ae <ide_init>
    swap_init();                // 初始化页面交换机制
ffffffffc0200082:	367010ef          	jal	ra,ffffffffc0201be8 <swap_init>
    clock_init();               // 初始化时钟中断
ffffffffc0200086:	47e000ef          	jal	ra,ffffffffc0200504 <clock_init>
    intr_enable();              // 启用中断请求
ffffffffc020008a:	540000ef          	jal	ra,ffffffffc02005ca <intr_enable>
    cprintf("-------------------------here0----------------------\n");
ffffffffc020008e:	00005517          	auipc	a0,0x5
ffffffffc0200092:	e0a50513          	addi	a0,a0,-502 # ffffffffc0204e98 <etext+0x28>
ffffffffc0200096:	042000ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cpu_idle();                 // 运行空闲进程(本次的新增)
ffffffffc020009a:	027040ef          	jal	ra,ffffffffc02048c0 <cpu_idle>

ffffffffc020009e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020009e:	1141                	addi	sp,sp,-16
ffffffffc02000a0:	e022                	sd	s0,0(sp)
ffffffffc02000a2:	e406                	sd	ra,8(sp)
ffffffffc02000a4:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc02000a6:	4b2000ef          	jal	ra,ffffffffc0200558 <cons_putc>
    (*cnt) ++;
ffffffffc02000aa:	401c                	lw	a5,0(s0)
}
ffffffffc02000ac:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000ae:	2785                	addiw	a5,a5,1
ffffffffc02000b0:	c01c                	sw	a5,0(s0)
}
ffffffffc02000b2:	6402                	ld	s0,0(sp)
ffffffffc02000b4:	0141                	addi	sp,sp,16
ffffffffc02000b6:	8082                	ret

ffffffffc02000b8 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000b8:	1101                	addi	sp,sp,-32
ffffffffc02000ba:	862a                	mv	a2,a0
ffffffffc02000bc:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000be:	00000517          	auipc	a0,0x0
ffffffffc02000c2:	fe050513          	addi	a0,a0,-32 # ffffffffc020009e <cputch>
ffffffffc02000c6:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000c8:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ca:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000cc:	20d040ef          	jal	ra,ffffffffc0204ad8 <vprintfmt>
    return cnt;
}
ffffffffc02000d0:	60e2                	ld	ra,24(sp)
ffffffffc02000d2:	4532                	lw	a0,12(sp)
ffffffffc02000d4:	6105                	addi	sp,sp,32
ffffffffc02000d6:	8082                	ret

ffffffffc02000d8 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000d8:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000da:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000de:	8e2a                	mv	t3,a0
ffffffffc02000e0:	f42e                	sd	a1,40(sp)
ffffffffc02000e2:	f832                	sd	a2,48(sp)
ffffffffc02000e4:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e6:	00000517          	auipc	a0,0x0
ffffffffc02000ea:	fb850513          	addi	a0,a0,-72 # ffffffffc020009e <cputch>
ffffffffc02000ee:	004c                	addi	a1,sp,4
ffffffffc02000f0:	869a                	mv	a3,t1
ffffffffc02000f2:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000f4:	ec06                	sd	ra,24(sp)
ffffffffc02000f6:	e0ba                	sd	a4,64(sp)
ffffffffc02000f8:	e4be                	sd	a5,72(sp)
ffffffffc02000fa:	e8c2                	sd	a6,80(sp)
ffffffffc02000fc:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000fe:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc0200100:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200102:	1d7040ef          	jal	ra,ffffffffc0204ad8 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc0200106:	60e2                	ld	ra,24(sp)
ffffffffc0200108:	4512                	lw	a0,4(sp)
ffffffffc020010a:	6125                	addi	sp,sp,96
ffffffffc020010c:	8082                	ret

ffffffffc020010e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc020010e:	a1a9                	j	ffffffffc0200558 <cons_putc>

ffffffffc0200110 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200110:	1141                	addi	sp,sp,-16
ffffffffc0200112:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200114:	478000ef          	jal	ra,ffffffffc020058c <cons_getc>
ffffffffc0200118:	dd75                	beqz	a0,ffffffffc0200114 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020011a:	60a2                	ld	ra,8(sp)
ffffffffc020011c:	0141                	addi	sp,sp,16
ffffffffc020011e:	8082                	ret

ffffffffc0200120 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200120:	715d                	addi	sp,sp,-80
ffffffffc0200122:	e486                	sd	ra,72(sp)
ffffffffc0200124:	e0a6                	sd	s1,64(sp)
ffffffffc0200126:	fc4a                	sd	s2,56(sp)
ffffffffc0200128:	f84e                	sd	s3,48(sp)
ffffffffc020012a:	f452                	sd	s4,40(sp)
ffffffffc020012c:	f056                	sd	s5,32(sp)
ffffffffc020012e:	ec5a                	sd	s6,24(sp)
ffffffffc0200130:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0200132:	c901                	beqz	a0,ffffffffc0200142 <readline+0x22>
ffffffffc0200134:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0200136:	00005517          	auipc	a0,0x5
ffffffffc020013a:	d9a50513          	addi	a0,a0,-614 # ffffffffc0204ed0 <etext+0x60>
ffffffffc020013e:	f9bff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
readline(const char *prompt) {
ffffffffc0200142:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200144:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0200146:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200148:	4aa9                	li	s5,10
ffffffffc020014a:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020014c:	0000ab97          	auipc	s7,0xa
ffffffffc0200150:	f14b8b93          	addi	s7,s7,-236 # ffffffffc020a060 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200154:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0200158:	fb9ff0ef          	jal	ra,ffffffffc0200110 <getchar>
        if (c < 0) {
ffffffffc020015c:	00054a63          	bltz	a0,ffffffffc0200170 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200160:	00a95a63          	bge	s2,a0,ffffffffc0200174 <readline+0x54>
ffffffffc0200164:	029a5263          	bge	s4,s1,ffffffffc0200188 <readline+0x68>
        c = getchar();
ffffffffc0200168:	fa9ff0ef          	jal	ra,ffffffffc0200110 <getchar>
        if (c < 0) {
ffffffffc020016c:	fe055ae3          	bgez	a0,ffffffffc0200160 <readline+0x40>
            return NULL;
ffffffffc0200170:	4501                	li	a0,0
ffffffffc0200172:	a091                	j	ffffffffc02001b6 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0200174:	03351463          	bne	a0,s3,ffffffffc020019c <readline+0x7c>
ffffffffc0200178:	e8a9                	bnez	s1,ffffffffc02001ca <readline+0xaa>
        c = getchar();
ffffffffc020017a:	f97ff0ef          	jal	ra,ffffffffc0200110 <getchar>
        if (c < 0) {
ffffffffc020017e:	fe0549e3          	bltz	a0,ffffffffc0200170 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200182:	fea959e3          	bge	s2,a0,ffffffffc0200174 <readline+0x54>
ffffffffc0200186:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200188:	e42a                	sd	a0,8(sp)
ffffffffc020018a:	f85ff0ef          	jal	ra,ffffffffc020010e <cputchar>
            buf[i ++] = c;
ffffffffc020018e:	6522                	ld	a0,8(sp)
ffffffffc0200190:	009b87b3          	add	a5,s7,s1
ffffffffc0200194:	2485                	addiw	s1,s1,1
ffffffffc0200196:	00a78023          	sb	a0,0(a5)
ffffffffc020019a:	bf7d                	j	ffffffffc0200158 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020019c:	01550463          	beq	a0,s5,ffffffffc02001a4 <readline+0x84>
ffffffffc02001a0:	fb651ce3          	bne	a0,s6,ffffffffc0200158 <readline+0x38>
            cputchar(c);
ffffffffc02001a4:	f6bff0ef          	jal	ra,ffffffffc020010e <cputchar>
            buf[i] = '\0';
ffffffffc02001a8:	0000a517          	auipc	a0,0xa
ffffffffc02001ac:	eb850513          	addi	a0,a0,-328 # ffffffffc020a060 <buf>
ffffffffc02001b0:	94aa                	add	s1,s1,a0
ffffffffc02001b2:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001b6:	60a6                	ld	ra,72(sp)
ffffffffc02001b8:	6486                	ld	s1,64(sp)
ffffffffc02001ba:	7962                	ld	s2,56(sp)
ffffffffc02001bc:	79c2                	ld	s3,48(sp)
ffffffffc02001be:	7a22                	ld	s4,40(sp)
ffffffffc02001c0:	7a82                	ld	s5,32(sp)
ffffffffc02001c2:	6b62                	ld	s6,24(sp)
ffffffffc02001c4:	6bc2                	ld	s7,16(sp)
ffffffffc02001c6:	6161                	addi	sp,sp,80
ffffffffc02001c8:	8082                	ret
            cputchar(c);
ffffffffc02001ca:	4521                	li	a0,8
ffffffffc02001cc:	f43ff0ef          	jal	ra,ffffffffc020010e <cputchar>
            i --;
ffffffffc02001d0:	34fd                	addiw	s1,s1,-1
ffffffffc02001d2:	b759                	j	ffffffffc0200158 <readline+0x38>

ffffffffc02001d4 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001d4:	00015317          	auipc	t1,0x15
ffffffffc02001d8:	36430313          	addi	t1,t1,868 # ffffffffc0215538 <is_panic>
ffffffffc02001dc:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001e0:	715d                	addi	sp,sp,-80
ffffffffc02001e2:	ec06                	sd	ra,24(sp)
ffffffffc02001e4:	e822                	sd	s0,16(sp)
ffffffffc02001e6:	f436                	sd	a3,40(sp)
ffffffffc02001e8:	f83a                	sd	a4,48(sp)
ffffffffc02001ea:	fc3e                	sd	a5,56(sp)
ffffffffc02001ec:	e0c2                	sd	a6,64(sp)
ffffffffc02001ee:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001f0:	020e1a63          	bnez	t3,ffffffffc0200224 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02001f4:	4785                	li	a5,1
ffffffffc02001f6:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02001fa:	8432                	mv	s0,a2
ffffffffc02001fc:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001fe:	862e                	mv	a2,a1
ffffffffc0200200:	85aa                	mv	a1,a0
ffffffffc0200202:	00005517          	auipc	a0,0x5
ffffffffc0200206:	cd650513          	addi	a0,a0,-810 # ffffffffc0204ed8 <etext+0x68>
    va_start(ap, fmt);
ffffffffc020020a:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020020c:	ecdff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200210:	65a2                	ld	a1,8(sp)
ffffffffc0200212:	8522                	mv	a0,s0
ffffffffc0200214:	ea5ff0ef          	jal	ra,ffffffffc02000b8 <vcprintf>
    cprintf("\n");
ffffffffc0200218:	00006517          	auipc	a0,0x6
ffffffffc020021c:	75050513          	addi	a0,a0,1872 # ffffffffc0206968 <default_pmm_manager+0x3b8>
ffffffffc0200220:	eb9ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200224:	3ac000ef          	jal	ra,ffffffffc02005d0 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200228:	4501                	li	a0,0
ffffffffc020022a:	130000ef          	jal	ra,ffffffffc020035a <kmonitor>
    while (1) {
ffffffffc020022e:	bfed                	j	ffffffffc0200228 <__panic+0x54>

ffffffffc0200230 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200230:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200232:	00005517          	auipc	a0,0x5
ffffffffc0200236:	cc650513          	addi	a0,a0,-826 # ffffffffc0204ef8 <etext+0x88>
void print_kerninfo(void) {
ffffffffc020023a:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020023c:	e9dff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200240:	00000597          	auipc	a1,0x0
ffffffffc0200244:	df258593          	addi	a1,a1,-526 # ffffffffc0200032 <kern_init>
ffffffffc0200248:	00005517          	auipc	a0,0x5
ffffffffc020024c:	cd050513          	addi	a0,a0,-816 # ffffffffc0204f18 <etext+0xa8>
ffffffffc0200250:	e89ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200254:	00005597          	auipc	a1,0x5
ffffffffc0200258:	c1c58593          	addi	a1,a1,-996 # ffffffffc0204e70 <etext>
ffffffffc020025c:	00005517          	auipc	a0,0x5
ffffffffc0200260:	cdc50513          	addi	a0,a0,-804 # ffffffffc0204f38 <etext+0xc8>
ffffffffc0200264:	e75ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200268:	0000a597          	auipc	a1,0xa
ffffffffc020026c:	df858593          	addi	a1,a1,-520 # ffffffffc020a060 <buf>
ffffffffc0200270:	00005517          	auipc	a0,0x5
ffffffffc0200274:	ce850513          	addi	a0,a0,-792 # ffffffffc0204f58 <etext+0xe8>
ffffffffc0200278:	e61ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020027c:	00015597          	auipc	a1,0x15
ffffffffc0200280:	35058593          	addi	a1,a1,848 # ffffffffc02155cc <end>
ffffffffc0200284:	00005517          	auipc	a0,0x5
ffffffffc0200288:	cf450513          	addi	a0,a0,-780 # ffffffffc0204f78 <etext+0x108>
ffffffffc020028c:	e4dff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200290:	00015597          	auipc	a1,0x15
ffffffffc0200294:	73b58593          	addi	a1,a1,1851 # ffffffffc02159cb <end+0x3ff>
ffffffffc0200298:	00000797          	auipc	a5,0x0
ffffffffc020029c:	d9a78793          	addi	a5,a5,-614 # ffffffffc0200032 <kern_init>
ffffffffc02002a0:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a4:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02002a8:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002aa:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002ae:	95be                	add	a1,a1,a5
ffffffffc02002b0:	85a9                	srai	a1,a1,0xa
ffffffffc02002b2:	00005517          	auipc	a0,0x5
ffffffffc02002b6:	ce650513          	addi	a0,a0,-794 # ffffffffc0204f98 <etext+0x128>
}
ffffffffc02002ba:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002bc:	bd31                	j	ffffffffc02000d8 <cprintf>

ffffffffc02002be <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002be:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002c0:	00005617          	auipc	a2,0x5
ffffffffc02002c4:	d0860613          	addi	a2,a2,-760 # ffffffffc0204fc8 <etext+0x158>
ffffffffc02002c8:	04d00593          	li	a1,77
ffffffffc02002cc:	00005517          	auipc	a0,0x5
ffffffffc02002d0:	d1450513          	addi	a0,a0,-748 # ffffffffc0204fe0 <etext+0x170>
void print_stackframe(void) {
ffffffffc02002d4:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002d6:	effff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02002da <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002da:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002dc:	00005617          	auipc	a2,0x5
ffffffffc02002e0:	d1c60613          	addi	a2,a2,-740 # ffffffffc0204ff8 <etext+0x188>
ffffffffc02002e4:	00005597          	auipc	a1,0x5
ffffffffc02002e8:	d3458593          	addi	a1,a1,-716 # ffffffffc0205018 <etext+0x1a8>
ffffffffc02002ec:	00005517          	auipc	a0,0x5
ffffffffc02002f0:	d3450513          	addi	a0,a0,-716 # ffffffffc0205020 <etext+0x1b0>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002f4:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002f6:	de3ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
ffffffffc02002fa:	00005617          	auipc	a2,0x5
ffffffffc02002fe:	d3660613          	addi	a2,a2,-714 # ffffffffc0205030 <etext+0x1c0>
ffffffffc0200302:	00005597          	auipc	a1,0x5
ffffffffc0200306:	d5658593          	addi	a1,a1,-682 # ffffffffc0205058 <etext+0x1e8>
ffffffffc020030a:	00005517          	auipc	a0,0x5
ffffffffc020030e:	d1650513          	addi	a0,a0,-746 # ffffffffc0205020 <etext+0x1b0>
ffffffffc0200312:	dc7ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
ffffffffc0200316:	00005617          	auipc	a2,0x5
ffffffffc020031a:	d5260613          	addi	a2,a2,-686 # ffffffffc0205068 <etext+0x1f8>
ffffffffc020031e:	00005597          	auipc	a1,0x5
ffffffffc0200322:	d6a58593          	addi	a1,a1,-662 # ffffffffc0205088 <etext+0x218>
ffffffffc0200326:	00005517          	auipc	a0,0x5
ffffffffc020032a:	cfa50513          	addi	a0,a0,-774 # ffffffffc0205020 <etext+0x1b0>
ffffffffc020032e:	dabff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    }
    return 0;
}
ffffffffc0200332:	60a2                	ld	ra,8(sp)
ffffffffc0200334:	4501                	li	a0,0
ffffffffc0200336:	0141                	addi	sp,sp,16
ffffffffc0200338:	8082                	ret

ffffffffc020033a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020033a:	1141                	addi	sp,sp,-16
ffffffffc020033c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020033e:	ef3ff0ef          	jal	ra,ffffffffc0200230 <print_kerninfo>
    return 0;
}
ffffffffc0200342:	60a2                	ld	ra,8(sp)
ffffffffc0200344:	4501                	li	a0,0
ffffffffc0200346:	0141                	addi	sp,sp,16
ffffffffc0200348:	8082                	ret

ffffffffc020034a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020034a:	1141                	addi	sp,sp,-16
ffffffffc020034c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020034e:	f71ff0ef          	jal	ra,ffffffffc02002be <print_stackframe>
    return 0;
}
ffffffffc0200352:	60a2                	ld	ra,8(sp)
ffffffffc0200354:	4501                	li	a0,0
ffffffffc0200356:	0141                	addi	sp,sp,16
ffffffffc0200358:	8082                	ret

ffffffffc020035a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020035a:	7115                	addi	sp,sp,-224
ffffffffc020035c:	ed5e                	sd	s7,152(sp)
ffffffffc020035e:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200360:	00005517          	auipc	a0,0x5
ffffffffc0200364:	d3850513          	addi	a0,a0,-712 # ffffffffc0205098 <etext+0x228>
kmonitor(struct trapframe *tf) {
ffffffffc0200368:	ed86                	sd	ra,216(sp)
ffffffffc020036a:	e9a2                	sd	s0,208(sp)
ffffffffc020036c:	e5a6                	sd	s1,200(sp)
ffffffffc020036e:	e1ca                	sd	s2,192(sp)
ffffffffc0200370:	fd4e                	sd	s3,184(sp)
ffffffffc0200372:	f952                	sd	s4,176(sp)
ffffffffc0200374:	f556                	sd	s5,168(sp)
ffffffffc0200376:	f15a                	sd	s6,160(sp)
ffffffffc0200378:	e962                	sd	s8,144(sp)
ffffffffc020037a:	e566                	sd	s9,136(sp)
ffffffffc020037c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020037e:	d5bff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200382:	00005517          	auipc	a0,0x5
ffffffffc0200386:	d3e50513          	addi	a0,a0,-706 # ffffffffc02050c0 <etext+0x250>
ffffffffc020038a:	d4fff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    if (tf != NULL) {
ffffffffc020038e:	000b8563          	beqz	s7,ffffffffc0200398 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200392:	855e                	mv	a0,s7
ffffffffc0200394:	49a000ef          	jal	ra,ffffffffc020082e <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200398:	4501                	li	a0,0
ffffffffc020039a:	4581                	li	a1,0
ffffffffc020039c:	4601                	li	a2,0
ffffffffc020039e:	48a1                	li	a7,8
ffffffffc02003a0:	00000073          	ecall
ffffffffc02003a4:	00005c17          	auipc	s8,0x5
ffffffffc02003a8:	d8cc0c13          	addi	s8,s8,-628 # ffffffffc0205130 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003ac:	00005917          	auipc	s2,0x5
ffffffffc02003b0:	d3c90913          	addi	s2,s2,-708 # ffffffffc02050e8 <etext+0x278>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b4:	00005497          	auipc	s1,0x5
ffffffffc02003b8:	d3c48493          	addi	s1,s1,-708 # ffffffffc02050f0 <etext+0x280>
        if (argc == MAXARGS - 1) {
ffffffffc02003bc:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003be:	00005b17          	auipc	s6,0x5
ffffffffc02003c2:	d3ab0b13          	addi	s6,s6,-710 # ffffffffc02050f8 <etext+0x288>
        argv[argc ++] = buf;
ffffffffc02003c6:	00005a17          	auipc	s4,0x5
ffffffffc02003ca:	c52a0a13          	addi	s4,s4,-942 # ffffffffc0205018 <etext+0x1a8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ce:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003d0:	854a                	mv	a0,s2
ffffffffc02003d2:	d4fff0ef          	jal	ra,ffffffffc0200120 <readline>
ffffffffc02003d6:	842a                	mv	s0,a0
ffffffffc02003d8:	dd65                	beqz	a0,ffffffffc02003d0 <kmonitor+0x76>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003da:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003de:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003e0:	e1bd                	bnez	a1,ffffffffc0200446 <kmonitor+0xec>
    if (argc == 0) {
ffffffffc02003e2:	fe0c87e3          	beqz	s9,ffffffffc02003d0 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003e6:	6582                	ld	a1,0(sp)
ffffffffc02003e8:	00005d17          	auipc	s10,0x5
ffffffffc02003ec:	d48d0d13          	addi	s10,s10,-696 # ffffffffc0205130 <commands>
        argv[argc ++] = buf;
ffffffffc02003f0:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003f2:	4401                	li	s0,0
ffffffffc02003f4:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f6:	5f4040ef          	jal	ra,ffffffffc02049ea <strcmp>
ffffffffc02003fa:	c919                	beqz	a0,ffffffffc0200410 <kmonitor+0xb6>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003fc:	2405                	addiw	s0,s0,1
ffffffffc02003fe:	0b540063          	beq	s0,s5,ffffffffc020049e <kmonitor+0x144>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200402:	000d3503          	ld	a0,0(s10)
ffffffffc0200406:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200408:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020040a:	5e0040ef          	jal	ra,ffffffffc02049ea <strcmp>
ffffffffc020040e:	f57d                	bnez	a0,ffffffffc02003fc <kmonitor+0xa2>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200410:	00141793          	slli	a5,s0,0x1
ffffffffc0200414:	97a2                	add	a5,a5,s0
ffffffffc0200416:	078e                	slli	a5,a5,0x3
ffffffffc0200418:	97e2                	add	a5,a5,s8
ffffffffc020041a:	6b9c                	ld	a5,16(a5)
ffffffffc020041c:	865e                	mv	a2,s7
ffffffffc020041e:	002c                	addi	a1,sp,8
ffffffffc0200420:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200424:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200426:	fa0555e3          	bgez	a0,ffffffffc02003d0 <kmonitor+0x76>
}
ffffffffc020042a:	60ee                	ld	ra,216(sp)
ffffffffc020042c:	644e                	ld	s0,208(sp)
ffffffffc020042e:	64ae                	ld	s1,200(sp)
ffffffffc0200430:	690e                	ld	s2,192(sp)
ffffffffc0200432:	79ea                	ld	s3,184(sp)
ffffffffc0200434:	7a4a                	ld	s4,176(sp)
ffffffffc0200436:	7aaa                	ld	s5,168(sp)
ffffffffc0200438:	7b0a                	ld	s6,160(sp)
ffffffffc020043a:	6bea                	ld	s7,152(sp)
ffffffffc020043c:	6c4a                	ld	s8,144(sp)
ffffffffc020043e:	6caa                	ld	s9,136(sp)
ffffffffc0200440:	6d0a                	ld	s10,128(sp)
ffffffffc0200442:	612d                	addi	sp,sp,224
ffffffffc0200444:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200446:	8526                	mv	a0,s1
ffffffffc0200448:	5c0040ef          	jal	ra,ffffffffc0204a08 <strchr>
ffffffffc020044c:	c901                	beqz	a0,ffffffffc020045c <kmonitor+0x102>
ffffffffc020044e:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200452:	00040023          	sb	zero,0(s0)
ffffffffc0200456:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200458:	d5c9                	beqz	a1,ffffffffc02003e2 <kmonitor+0x88>
ffffffffc020045a:	b7f5                	j	ffffffffc0200446 <kmonitor+0xec>
        if (*buf == '\0') {
ffffffffc020045c:	00044783          	lbu	a5,0(s0)
ffffffffc0200460:	d3c9                	beqz	a5,ffffffffc02003e2 <kmonitor+0x88>
        if (argc == MAXARGS - 1) {
ffffffffc0200462:	033c8963          	beq	s9,s3,ffffffffc0200494 <kmonitor+0x13a>
        argv[argc ++] = buf;
ffffffffc0200466:	003c9793          	slli	a5,s9,0x3
ffffffffc020046a:	0118                	addi	a4,sp,128
ffffffffc020046c:	97ba                	add	a5,a5,a4
ffffffffc020046e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200472:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200476:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200478:	e591                	bnez	a1,ffffffffc0200484 <kmonitor+0x12a>
ffffffffc020047a:	b7b5                	j	ffffffffc02003e6 <kmonitor+0x8c>
ffffffffc020047c:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200480:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200482:	d1a5                	beqz	a1,ffffffffc02003e2 <kmonitor+0x88>
ffffffffc0200484:	8526                	mv	a0,s1
ffffffffc0200486:	582040ef          	jal	ra,ffffffffc0204a08 <strchr>
ffffffffc020048a:	d96d                	beqz	a0,ffffffffc020047c <kmonitor+0x122>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020048c:	00044583          	lbu	a1,0(s0)
ffffffffc0200490:	d9a9                	beqz	a1,ffffffffc02003e2 <kmonitor+0x88>
ffffffffc0200492:	bf55                	j	ffffffffc0200446 <kmonitor+0xec>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200494:	45c1                	li	a1,16
ffffffffc0200496:	855a                	mv	a0,s6
ffffffffc0200498:	c41ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
ffffffffc020049c:	b7e9                	j	ffffffffc0200466 <kmonitor+0x10c>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020049e:	6582                	ld	a1,0(sp)
ffffffffc02004a0:	00005517          	auipc	a0,0x5
ffffffffc02004a4:	c7850513          	addi	a0,a0,-904 # ffffffffc0205118 <etext+0x2a8>
ffffffffc02004a8:	c31ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    return 0;
ffffffffc02004ac:	b715                	j	ffffffffc02003d0 <kmonitor+0x76>

ffffffffc02004ae <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02004ae:	8082                	ret

ffffffffc02004b0 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02004b0:	00253513          	sltiu	a0,a0,2
ffffffffc02004b4:	8082                	ret

ffffffffc02004b6 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02004b6:	03800513          	li	a0,56
ffffffffc02004ba:	8082                	ret

ffffffffc02004bc <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004bc:	0000a797          	auipc	a5,0xa
ffffffffc02004c0:	fa478793          	addi	a5,a5,-92 # ffffffffc020a460 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02004c4:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004c8:	1141                	addi	sp,sp,-16
ffffffffc02004ca:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004cc:	95be                	add	a1,a1,a5
ffffffffc02004ce:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004d2:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004d4:	55c040ef          	jal	ra,ffffffffc0204a30 <memcpy>
    return 0;
}
ffffffffc02004d8:	60a2                	ld	ra,8(sp)
ffffffffc02004da:	4501                	li	a0,0
ffffffffc02004dc:	0141                	addi	sp,sp,16
ffffffffc02004de:	8082                	ret

ffffffffc02004e0 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc02004e0:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e4:	0000a517          	auipc	a0,0xa
ffffffffc02004e8:	f7c50513          	addi	a0,a0,-132 # ffffffffc020a460 <ide>
                   size_t nsecs) {
ffffffffc02004ec:	1141                	addi	sp,sp,-16
ffffffffc02004ee:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004f0:	953e                	add	a0,a0,a5
ffffffffc02004f2:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004f6:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004f8:	538040ef          	jal	ra,ffffffffc0204a30 <memcpy>
    return 0;
}
ffffffffc02004fc:	60a2                	ld	ra,8(sp)
ffffffffc02004fe:	4501                	li	a0,0
ffffffffc0200500:	0141                	addi	sp,sp,16
ffffffffc0200502:	8082                	ret

ffffffffc0200504 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200504:	67e1                	lui	a5,0x18
ffffffffc0200506:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020050a:	00015717          	auipc	a4,0x15
ffffffffc020050e:	02f73f23          	sd	a5,62(a4) # ffffffffc0215548 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200512:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200516:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200518:	953e                	add	a0,a0,a5
ffffffffc020051a:	4601                	li	a2,0
ffffffffc020051c:	4881                	li	a7,0
ffffffffc020051e:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200522:	02000793          	li	a5,32
ffffffffc0200526:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020052a:	00005517          	auipc	a0,0x5
ffffffffc020052e:	c4e50513          	addi	a0,a0,-946 # ffffffffc0205178 <commands+0x48>
    ticks = 0;
ffffffffc0200532:	00015797          	auipc	a5,0x15
ffffffffc0200536:	0007b723          	sd	zero,14(a5) # ffffffffc0215540 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020053a:	be79                	j	ffffffffc02000d8 <cprintf>

ffffffffc020053c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020053c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200540:	00015797          	auipc	a5,0x15
ffffffffc0200544:	0087b783          	ld	a5,8(a5) # ffffffffc0215548 <timebase>
ffffffffc0200548:	953e                	add	a0,a0,a5
ffffffffc020054a:	4581                	li	a1,0
ffffffffc020054c:	4601                	li	a2,0
ffffffffc020054e:	4881                	li	a7,0
ffffffffc0200550:	00000073          	ecall
ffffffffc0200554:	8082                	ret

ffffffffc0200556 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200556:	8082                	ret

ffffffffc0200558 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200558:	100027f3          	csrr	a5,sstatus
ffffffffc020055c:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020055e:	0ff57513          	zext.b	a0,a0
ffffffffc0200562:	e799                	bnez	a5,ffffffffc0200570 <cons_putc+0x18>
ffffffffc0200564:	4581                	li	a1,0
ffffffffc0200566:	4601                	li	a2,0
ffffffffc0200568:	4885                	li	a7,1
ffffffffc020056a:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020056e:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200570:	1101                	addi	sp,sp,-32
ffffffffc0200572:	ec06                	sd	ra,24(sp)
ffffffffc0200574:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200576:	05a000ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc020057a:	6522                	ld	a0,8(sp)
ffffffffc020057c:	4581                	li	a1,0
ffffffffc020057e:	4601                	li	a2,0
ffffffffc0200580:	4885                	li	a7,1
ffffffffc0200582:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200586:	60e2                	ld	ra,24(sp)
ffffffffc0200588:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020058a:	a081                	j	ffffffffc02005ca <intr_enable>

ffffffffc020058c <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020058c:	100027f3          	csrr	a5,sstatus
ffffffffc0200590:	8b89                	andi	a5,a5,2
ffffffffc0200592:	eb89                	bnez	a5,ffffffffc02005a4 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200594:	4501                	li	a0,0
ffffffffc0200596:	4581                	li	a1,0
ffffffffc0200598:	4601                	li	a2,0
ffffffffc020059a:	4889                	li	a7,2
ffffffffc020059c:	00000073          	ecall
ffffffffc02005a0:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005a2:	8082                	ret
int cons_getc(void) {
ffffffffc02005a4:	1101                	addi	sp,sp,-32
ffffffffc02005a6:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005a8:	028000ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc02005ac:	4501                	li	a0,0
ffffffffc02005ae:	4581                	li	a1,0
ffffffffc02005b0:	4601                	li	a2,0
ffffffffc02005b2:	4889                	li	a7,2
ffffffffc02005b4:	00000073          	ecall
ffffffffc02005b8:	2501                	sext.w	a0,a0
ffffffffc02005ba:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005bc:	00e000ef          	jal	ra,ffffffffc02005ca <intr_enable>
}
ffffffffc02005c0:	60e2                	ld	ra,24(sp)
ffffffffc02005c2:	6522                	ld	a0,8(sp)
ffffffffc02005c4:	6105                	addi	sp,sp,32
ffffffffc02005c6:	8082                	ret

ffffffffc02005c8 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005c8:	8082                	ret

ffffffffc02005ca <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005ca:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005d0:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005d4:	8082                	ret

ffffffffc02005d6 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005d6:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005da:	1141                	addi	sp,sp,-16
ffffffffc02005dc:	e022                	sd	s0,0(sp)
ffffffffc02005de:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005e0:	1007f793          	andi	a5,a5,256
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005e4:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005e8:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005ea:	05500613          	li	a2,85
ffffffffc02005ee:	c399                	beqz	a5,ffffffffc02005f4 <pgfault_handler+0x1e>
ffffffffc02005f0:	04b00613          	li	a2,75
ffffffffc02005f4:	11843703          	ld	a4,280(s0)
ffffffffc02005f8:	47bd                	li	a5,15
ffffffffc02005fa:	05700693          	li	a3,87
ffffffffc02005fe:	00f70463          	beq	a4,a5,ffffffffc0200606 <pgfault_handler+0x30>
ffffffffc0200602:	05200693          	li	a3,82
ffffffffc0200606:	00005517          	auipc	a0,0x5
ffffffffc020060a:	b9250513          	addi	a0,a0,-1134 # ffffffffc0205198 <commands+0x68>
ffffffffc020060e:	acbff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200612:	00015517          	auipc	a0,0x15
ffffffffc0200616:	f3e53503          	ld	a0,-194(a0) # ffffffffc0215550 <check_mm_struct>
ffffffffc020061a:	c911                	beqz	a0,ffffffffc020062e <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020061c:	11043603          	ld	a2,272(s0)
ffffffffc0200620:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200624:	6402                	ld	s0,0(sp)
ffffffffc0200626:	60a2                	ld	ra,8(sp)
ffffffffc0200628:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020062a:	5010006f          	j	ffffffffc020132a <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020062e:	00005617          	auipc	a2,0x5
ffffffffc0200632:	b8a60613          	addi	a2,a2,-1142 # ffffffffc02051b8 <commands+0x88>
ffffffffc0200636:	06200593          	li	a1,98
ffffffffc020063a:	00005517          	auipc	a0,0x5
ffffffffc020063e:	b9650513          	addi	a0,a0,-1130 # ffffffffc02051d0 <commands+0xa0>
ffffffffc0200642:	b93ff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0200646 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200646:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020064a:	00000797          	auipc	a5,0x0
ffffffffc020064e:	47a78793          	addi	a5,a5,1146 # ffffffffc0200ac4 <__alltraps>
ffffffffc0200652:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200656:	000407b7          	lui	a5,0x40
ffffffffc020065a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020065e:	8082                	ret

ffffffffc0200660 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200660:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200662:	1141                	addi	sp,sp,-16
ffffffffc0200664:	e022                	sd	s0,0(sp)
ffffffffc0200666:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200668:	00005517          	auipc	a0,0x5
ffffffffc020066c:	b8050513          	addi	a0,a0,-1152 # ffffffffc02051e8 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200670:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200672:	a67ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200676:	640c                	ld	a1,8(s0)
ffffffffc0200678:	00005517          	auipc	a0,0x5
ffffffffc020067c:	b8850513          	addi	a0,a0,-1144 # ffffffffc0205200 <commands+0xd0>
ffffffffc0200680:	a59ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200684:	680c                	ld	a1,16(s0)
ffffffffc0200686:	00005517          	auipc	a0,0x5
ffffffffc020068a:	b9250513          	addi	a0,a0,-1134 # ffffffffc0205218 <commands+0xe8>
ffffffffc020068e:	a4bff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200692:	6c0c                	ld	a1,24(s0)
ffffffffc0200694:	00005517          	auipc	a0,0x5
ffffffffc0200698:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0205230 <commands+0x100>
ffffffffc020069c:	a3dff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a0:	700c                	ld	a1,32(s0)
ffffffffc02006a2:	00005517          	auipc	a0,0x5
ffffffffc02006a6:	ba650513          	addi	a0,a0,-1114 # ffffffffc0205248 <commands+0x118>
ffffffffc02006aa:	a2fff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ae:	740c                	ld	a1,40(s0)
ffffffffc02006b0:	00005517          	auipc	a0,0x5
ffffffffc02006b4:	bb050513          	addi	a0,a0,-1104 # ffffffffc0205260 <commands+0x130>
ffffffffc02006b8:	a21ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006bc:	780c                	ld	a1,48(s0)
ffffffffc02006be:	00005517          	auipc	a0,0x5
ffffffffc02006c2:	bba50513          	addi	a0,a0,-1094 # ffffffffc0205278 <commands+0x148>
ffffffffc02006c6:	a13ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006ca:	7c0c                	ld	a1,56(s0)
ffffffffc02006cc:	00005517          	auipc	a0,0x5
ffffffffc02006d0:	bc450513          	addi	a0,a0,-1084 # ffffffffc0205290 <commands+0x160>
ffffffffc02006d4:	a05ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006d8:	602c                	ld	a1,64(s0)
ffffffffc02006da:	00005517          	auipc	a0,0x5
ffffffffc02006de:	bce50513          	addi	a0,a0,-1074 # ffffffffc02052a8 <commands+0x178>
ffffffffc02006e2:	9f7ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006e6:	642c                	ld	a1,72(s0)
ffffffffc02006e8:	00005517          	auipc	a0,0x5
ffffffffc02006ec:	bd850513          	addi	a0,a0,-1064 # ffffffffc02052c0 <commands+0x190>
ffffffffc02006f0:	9e9ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006f4:	682c                	ld	a1,80(s0)
ffffffffc02006f6:	00005517          	auipc	a0,0x5
ffffffffc02006fa:	be250513          	addi	a0,a0,-1054 # ffffffffc02052d8 <commands+0x1a8>
ffffffffc02006fe:	9dbff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200702:	6c2c                	ld	a1,88(s0)
ffffffffc0200704:	00005517          	auipc	a0,0x5
ffffffffc0200708:	bec50513          	addi	a0,a0,-1044 # ffffffffc02052f0 <commands+0x1c0>
ffffffffc020070c:	9cdff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200710:	702c                	ld	a1,96(s0)
ffffffffc0200712:	00005517          	auipc	a0,0x5
ffffffffc0200716:	bf650513          	addi	a0,a0,-1034 # ffffffffc0205308 <commands+0x1d8>
ffffffffc020071a:	9bfff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020071e:	742c                	ld	a1,104(s0)
ffffffffc0200720:	00005517          	auipc	a0,0x5
ffffffffc0200724:	c0050513          	addi	a0,a0,-1024 # ffffffffc0205320 <commands+0x1f0>
ffffffffc0200728:	9b1ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020072c:	782c                	ld	a1,112(s0)
ffffffffc020072e:	00005517          	auipc	a0,0x5
ffffffffc0200732:	c0a50513          	addi	a0,a0,-1014 # ffffffffc0205338 <commands+0x208>
ffffffffc0200736:	9a3ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020073a:	7c2c                	ld	a1,120(s0)
ffffffffc020073c:	00005517          	auipc	a0,0x5
ffffffffc0200740:	c1450513          	addi	a0,a0,-1004 # ffffffffc0205350 <commands+0x220>
ffffffffc0200744:	995ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200748:	604c                	ld	a1,128(s0)
ffffffffc020074a:	00005517          	auipc	a0,0x5
ffffffffc020074e:	c1e50513          	addi	a0,a0,-994 # ffffffffc0205368 <commands+0x238>
ffffffffc0200752:	987ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200756:	644c                	ld	a1,136(s0)
ffffffffc0200758:	00005517          	auipc	a0,0x5
ffffffffc020075c:	c2850513          	addi	a0,a0,-984 # ffffffffc0205380 <commands+0x250>
ffffffffc0200760:	979ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200764:	684c                	ld	a1,144(s0)
ffffffffc0200766:	00005517          	auipc	a0,0x5
ffffffffc020076a:	c3250513          	addi	a0,a0,-974 # ffffffffc0205398 <commands+0x268>
ffffffffc020076e:	96bff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200772:	6c4c                	ld	a1,152(s0)
ffffffffc0200774:	00005517          	auipc	a0,0x5
ffffffffc0200778:	c3c50513          	addi	a0,a0,-964 # ffffffffc02053b0 <commands+0x280>
ffffffffc020077c:	95dff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200780:	704c                	ld	a1,160(s0)
ffffffffc0200782:	00005517          	auipc	a0,0x5
ffffffffc0200786:	c4650513          	addi	a0,a0,-954 # ffffffffc02053c8 <commands+0x298>
ffffffffc020078a:	94fff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020078e:	744c                	ld	a1,168(s0)
ffffffffc0200790:	00005517          	auipc	a0,0x5
ffffffffc0200794:	c5050513          	addi	a0,a0,-944 # ffffffffc02053e0 <commands+0x2b0>
ffffffffc0200798:	941ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc020079c:	784c                	ld	a1,176(s0)
ffffffffc020079e:	00005517          	auipc	a0,0x5
ffffffffc02007a2:	c5a50513          	addi	a0,a0,-934 # ffffffffc02053f8 <commands+0x2c8>
ffffffffc02007a6:	933ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007aa:	7c4c                	ld	a1,184(s0)
ffffffffc02007ac:	00005517          	auipc	a0,0x5
ffffffffc02007b0:	c6450513          	addi	a0,a0,-924 # ffffffffc0205410 <commands+0x2e0>
ffffffffc02007b4:	925ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007b8:	606c                	ld	a1,192(s0)
ffffffffc02007ba:	00005517          	auipc	a0,0x5
ffffffffc02007be:	c6e50513          	addi	a0,a0,-914 # ffffffffc0205428 <commands+0x2f8>
ffffffffc02007c2:	917ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007c6:	646c                	ld	a1,200(s0)
ffffffffc02007c8:	00005517          	auipc	a0,0x5
ffffffffc02007cc:	c7850513          	addi	a0,a0,-904 # ffffffffc0205440 <commands+0x310>
ffffffffc02007d0:	909ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007d4:	686c                	ld	a1,208(s0)
ffffffffc02007d6:	00005517          	auipc	a0,0x5
ffffffffc02007da:	c8250513          	addi	a0,a0,-894 # ffffffffc0205458 <commands+0x328>
ffffffffc02007de:	8fbff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007e2:	6c6c                	ld	a1,216(s0)
ffffffffc02007e4:	00005517          	auipc	a0,0x5
ffffffffc02007e8:	c8c50513          	addi	a0,a0,-884 # ffffffffc0205470 <commands+0x340>
ffffffffc02007ec:	8edff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f0:	706c                	ld	a1,224(s0)
ffffffffc02007f2:	00005517          	auipc	a0,0x5
ffffffffc02007f6:	c9650513          	addi	a0,a0,-874 # ffffffffc0205488 <commands+0x358>
ffffffffc02007fa:	8dfff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007fe:	746c                	ld	a1,232(s0)
ffffffffc0200800:	00005517          	auipc	a0,0x5
ffffffffc0200804:	ca050513          	addi	a0,a0,-864 # ffffffffc02054a0 <commands+0x370>
ffffffffc0200808:	8d1ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020080c:	786c                	ld	a1,240(s0)
ffffffffc020080e:	00005517          	auipc	a0,0x5
ffffffffc0200812:	caa50513          	addi	a0,a0,-854 # ffffffffc02054b8 <commands+0x388>
ffffffffc0200816:	8c3ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020081a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020081c:	6402                	ld	s0,0(sp)
ffffffffc020081e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200820:	00005517          	auipc	a0,0x5
ffffffffc0200824:	cb050513          	addi	a0,a0,-848 # ffffffffc02054d0 <commands+0x3a0>
}
ffffffffc0200828:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082a:	8afff06f          	j	ffffffffc02000d8 <cprintf>

ffffffffc020082e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020082e:	1141                	addi	sp,sp,-16
ffffffffc0200830:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200832:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200834:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200836:	00005517          	auipc	a0,0x5
ffffffffc020083a:	cb250513          	addi	a0,a0,-846 # ffffffffc02054e8 <commands+0x3b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020083e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200840:	899ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200844:	8522                	mv	a0,s0
ffffffffc0200846:	e1bff0ef          	jal	ra,ffffffffc0200660 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020084a:	10043583          	ld	a1,256(s0)
ffffffffc020084e:	00005517          	auipc	a0,0x5
ffffffffc0200852:	cb250513          	addi	a0,a0,-846 # ffffffffc0205500 <commands+0x3d0>
ffffffffc0200856:	883ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020085a:	10843583          	ld	a1,264(s0)
ffffffffc020085e:	00005517          	auipc	a0,0x5
ffffffffc0200862:	cba50513          	addi	a0,a0,-838 # ffffffffc0205518 <commands+0x3e8>
ffffffffc0200866:	873ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020086a:	11043583          	ld	a1,272(s0)
ffffffffc020086e:	00005517          	auipc	a0,0x5
ffffffffc0200872:	cc250513          	addi	a0,a0,-830 # ffffffffc0205530 <commands+0x400>
ffffffffc0200876:	863ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020087a:	11843583          	ld	a1,280(s0)
}
ffffffffc020087e:	6402                	ld	s0,0(sp)
ffffffffc0200880:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200882:	00005517          	auipc	a0,0x5
ffffffffc0200886:	cc650513          	addi	a0,a0,-826 # ffffffffc0205548 <commands+0x418>
}
ffffffffc020088a:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088c:	84dff06f          	j	ffffffffc02000d8 <cprintf>

ffffffffc0200890 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200890:	11853783          	ld	a5,280(a0)
ffffffffc0200894:	472d                	li	a4,11
ffffffffc0200896:	0786                	slli	a5,a5,0x1
ffffffffc0200898:	8385                	srli	a5,a5,0x1
ffffffffc020089a:	06f76c63          	bltu	a4,a5,ffffffffc0200912 <interrupt_handler+0x82>
ffffffffc020089e:	00005717          	auipc	a4,0x5
ffffffffc02008a2:	d7270713          	addi	a4,a4,-654 # ffffffffc0205610 <commands+0x4e0>
ffffffffc02008a6:	078a                	slli	a5,a5,0x2
ffffffffc02008a8:	97ba                	add	a5,a5,a4
ffffffffc02008aa:	439c                	lw	a5,0(a5)
ffffffffc02008ac:	97ba                	add	a5,a5,a4
ffffffffc02008ae:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02008b0:	00005517          	auipc	a0,0x5
ffffffffc02008b4:	d1050513          	addi	a0,a0,-752 # ffffffffc02055c0 <commands+0x490>
ffffffffc02008b8:	821ff06f          	j	ffffffffc02000d8 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008bc:	00005517          	auipc	a0,0x5
ffffffffc02008c0:	ce450513          	addi	a0,a0,-796 # ffffffffc02055a0 <commands+0x470>
ffffffffc02008c4:	815ff06f          	j	ffffffffc02000d8 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008c8:	00005517          	auipc	a0,0x5
ffffffffc02008cc:	c9850513          	addi	a0,a0,-872 # ffffffffc0205560 <commands+0x430>
ffffffffc02008d0:	809ff06f          	j	ffffffffc02000d8 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008d4:	00005517          	auipc	a0,0x5
ffffffffc02008d8:	cac50513          	addi	a0,a0,-852 # ffffffffc0205580 <commands+0x450>
ffffffffc02008dc:	ffcff06f          	j	ffffffffc02000d8 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008e0:	1141                	addi	sp,sp,-16
ffffffffc02008e2:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02008e4:	c59ff0ef          	jal	ra,ffffffffc020053c <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02008e8:	00015697          	auipc	a3,0x15
ffffffffc02008ec:	c5868693          	addi	a3,a3,-936 # ffffffffc0215540 <ticks>
ffffffffc02008f0:	629c                	ld	a5,0(a3)
ffffffffc02008f2:	06400713          	li	a4,100
ffffffffc02008f6:	0785                	addi	a5,a5,1
ffffffffc02008f8:	02e7f733          	remu	a4,a5,a4
ffffffffc02008fc:	e29c                	sd	a5,0(a3)
ffffffffc02008fe:	cb19                	beqz	a4,ffffffffc0200914 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200900:	60a2                	ld	ra,8(sp)
ffffffffc0200902:	0141                	addi	sp,sp,16
ffffffffc0200904:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200906:	00005517          	auipc	a0,0x5
ffffffffc020090a:	cea50513          	addi	a0,a0,-790 # ffffffffc02055f0 <commands+0x4c0>
ffffffffc020090e:	fcaff06f          	j	ffffffffc02000d8 <cprintf>
            print_trapframe(tf);
ffffffffc0200912:	bf31                	j	ffffffffc020082e <print_trapframe>
}
ffffffffc0200914:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200916:	06400593          	li	a1,100
ffffffffc020091a:	00005517          	auipc	a0,0x5
ffffffffc020091e:	cc650513          	addi	a0,a0,-826 # ffffffffc02055e0 <commands+0x4b0>
}
ffffffffc0200922:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200924:	fb4ff06f          	j	ffffffffc02000d8 <cprintf>

ffffffffc0200928 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200928:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020092c:	1101                	addi	sp,sp,-32
ffffffffc020092e:	e822                	sd	s0,16(sp)
ffffffffc0200930:	ec06                	sd	ra,24(sp)
ffffffffc0200932:	e426                	sd	s1,8(sp)
ffffffffc0200934:	473d                	li	a4,15
ffffffffc0200936:	842a                	mv	s0,a0
ffffffffc0200938:	14f76a63          	bltu	a4,a5,ffffffffc0200a8c <exception_handler+0x164>
ffffffffc020093c:	00005717          	auipc	a4,0x5
ffffffffc0200940:	ebc70713          	addi	a4,a4,-324 # ffffffffc02057f8 <commands+0x6c8>
ffffffffc0200944:	078a                	slli	a5,a5,0x2
ffffffffc0200946:	97ba                	add	a5,a5,a4
ffffffffc0200948:	439c                	lw	a5,0(a5)
ffffffffc020094a:	97ba                	add	a5,a5,a4
ffffffffc020094c:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020094e:	00005517          	auipc	a0,0x5
ffffffffc0200952:	e9250513          	addi	a0,a0,-366 # ffffffffc02057e0 <commands+0x6b0>
ffffffffc0200956:	f82ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020095a:	8522                	mv	a0,s0
ffffffffc020095c:	c7bff0ef          	jal	ra,ffffffffc02005d6 <pgfault_handler>
ffffffffc0200960:	84aa                	mv	s1,a0
ffffffffc0200962:	12051b63          	bnez	a0,ffffffffc0200a98 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200966:	60e2                	ld	ra,24(sp)
ffffffffc0200968:	6442                	ld	s0,16(sp)
ffffffffc020096a:	64a2                	ld	s1,8(sp)
ffffffffc020096c:	6105                	addi	sp,sp,32
ffffffffc020096e:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200970:	00005517          	auipc	a0,0x5
ffffffffc0200974:	cd050513          	addi	a0,a0,-816 # ffffffffc0205640 <commands+0x510>
}
ffffffffc0200978:	6442                	ld	s0,16(sp)
ffffffffc020097a:	60e2                	ld	ra,24(sp)
ffffffffc020097c:	64a2                	ld	s1,8(sp)
ffffffffc020097e:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200980:	f58ff06f          	j	ffffffffc02000d8 <cprintf>
ffffffffc0200984:	00005517          	auipc	a0,0x5
ffffffffc0200988:	cdc50513          	addi	a0,a0,-804 # ffffffffc0205660 <commands+0x530>
ffffffffc020098c:	b7f5                	j	ffffffffc0200978 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc020098e:	00005517          	auipc	a0,0x5
ffffffffc0200992:	cf250513          	addi	a0,a0,-782 # ffffffffc0205680 <commands+0x550>
ffffffffc0200996:	b7cd                	j	ffffffffc0200978 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200998:	00005517          	auipc	a0,0x5
ffffffffc020099c:	d0050513          	addi	a0,a0,-768 # ffffffffc0205698 <commands+0x568>
ffffffffc02009a0:	bfe1                	j	ffffffffc0200978 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02009a2:	00005517          	auipc	a0,0x5
ffffffffc02009a6:	d0650513          	addi	a0,a0,-762 # ffffffffc02056a8 <commands+0x578>
ffffffffc02009aa:	b7f9                	j	ffffffffc0200978 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02009ac:	00005517          	auipc	a0,0x5
ffffffffc02009b0:	d1c50513          	addi	a0,a0,-740 # ffffffffc02056c8 <commands+0x598>
ffffffffc02009b4:	f24ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009b8:	8522                	mv	a0,s0
ffffffffc02009ba:	c1dff0ef          	jal	ra,ffffffffc02005d6 <pgfault_handler>
ffffffffc02009be:	84aa                	mv	s1,a0
ffffffffc02009c0:	d15d                	beqz	a0,ffffffffc0200966 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009c2:	8522                	mv	a0,s0
ffffffffc02009c4:	e6bff0ef          	jal	ra,ffffffffc020082e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009c8:	86a6                	mv	a3,s1
ffffffffc02009ca:	00005617          	auipc	a2,0x5
ffffffffc02009ce:	d1660613          	addi	a2,a2,-746 # ffffffffc02056e0 <commands+0x5b0>
ffffffffc02009d2:	0b300593          	li	a1,179
ffffffffc02009d6:	00004517          	auipc	a0,0x4
ffffffffc02009da:	7fa50513          	addi	a0,a0,2042 # ffffffffc02051d0 <commands+0xa0>
ffffffffc02009de:	ff6ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009e2:	00005517          	auipc	a0,0x5
ffffffffc02009e6:	d1e50513          	addi	a0,a0,-738 # ffffffffc0205700 <commands+0x5d0>
ffffffffc02009ea:	b779                	j	ffffffffc0200978 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02009ec:	00005517          	auipc	a0,0x5
ffffffffc02009f0:	d2c50513          	addi	a0,a0,-724 # ffffffffc0205718 <commands+0x5e8>
ffffffffc02009f4:	ee4ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009f8:	8522                	mv	a0,s0
ffffffffc02009fa:	bddff0ef          	jal	ra,ffffffffc02005d6 <pgfault_handler>
ffffffffc02009fe:	84aa                	mv	s1,a0
ffffffffc0200a00:	d13d                	beqz	a0,ffffffffc0200966 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a02:	8522                	mv	a0,s0
ffffffffc0200a04:	e2bff0ef          	jal	ra,ffffffffc020082e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a08:	86a6                	mv	a3,s1
ffffffffc0200a0a:	00005617          	auipc	a2,0x5
ffffffffc0200a0e:	cd660613          	addi	a2,a2,-810 # ffffffffc02056e0 <commands+0x5b0>
ffffffffc0200a12:	0bd00593          	li	a1,189
ffffffffc0200a16:	00004517          	auipc	a0,0x4
ffffffffc0200a1a:	7ba50513          	addi	a0,a0,1978 # ffffffffc02051d0 <commands+0xa0>
ffffffffc0200a1e:	fb6ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a22:	00005517          	auipc	a0,0x5
ffffffffc0200a26:	d0e50513          	addi	a0,a0,-754 # ffffffffc0205730 <commands+0x600>
ffffffffc0200a2a:	b7b9                	j	ffffffffc0200978 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a2c:	00005517          	auipc	a0,0x5
ffffffffc0200a30:	d2450513          	addi	a0,a0,-732 # ffffffffc0205750 <commands+0x620>
ffffffffc0200a34:	b791                	j	ffffffffc0200978 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a36:	00005517          	auipc	a0,0x5
ffffffffc0200a3a:	d3a50513          	addi	a0,a0,-710 # ffffffffc0205770 <commands+0x640>
ffffffffc0200a3e:	bf2d                	j	ffffffffc0200978 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a40:	00005517          	auipc	a0,0x5
ffffffffc0200a44:	d5050513          	addi	a0,a0,-688 # ffffffffc0205790 <commands+0x660>
ffffffffc0200a48:	bf05                	j	ffffffffc0200978 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a4a:	00005517          	auipc	a0,0x5
ffffffffc0200a4e:	d6650513          	addi	a0,a0,-666 # ffffffffc02057b0 <commands+0x680>
ffffffffc0200a52:	b71d                	j	ffffffffc0200978 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a54:	00005517          	auipc	a0,0x5
ffffffffc0200a58:	d7450513          	addi	a0,a0,-652 # ffffffffc02057c8 <commands+0x698>
ffffffffc0200a5c:	e7cff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a60:	8522                	mv	a0,s0
ffffffffc0200a62:	b75ff0ef          	jal	ra,ffffffffc02005d6 <pgfault_handler>
ffffffffc0200a66:	84aa                	mv	s1,a0
ffffffffc0200a68:	ee050fe3          	beqz	a0,ffffffffc0200966 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a6c:	8522                	mv	a0,s0
ffffffffc0200a6e:	dc1ff0ef          	jal	ra,ffffffffc020082e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a72:	86a6                	mv	a3,s1
ffffffffc0200a74:	00005617          	auipc	a2,0x5
ffffffffc0200a78:	c6c60613          	addi	a2,a2,-916 # ffffffffc02056e0 <commands+0x5b0>
ffffffffc0200a7c:	0d300593          	li	a1,211
ffffffffc0200a80:	00004517          	auipc	a0,0x4
ffffffffc0200a84:	75050513          	addi	a0,a0,1872 # ffffffffc02051d0 <commands+0xa0>
ffffffffc0200a88:	f4cff0ef          	jal	ra,ffffffffc02001d4 <__panic>
            print_trapframe(tf);
ffffffffc0200a8c:	8522                	mv	a0,s0
}
ffffffffc0200a8e:	6442                	ld	s0,16(sp)
ffffffffc0200a90:	60e2                	ld	ra,24(sp)
ffffffffc0200a92:	64a2                	ld	s1,8(sp)
ffffffffc0200a94:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a96:	bb61                	j	ffffffffc020082e <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a98:	8522                	mv	a0,s0
ffffffffc0200a9a:	d95ff0ef          	jal	ra,ffffffffc020082e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a9e:	86a6                	mv	a3,s1
ffffffffc0200aa0:	00005617          	auipc	a2,0x5
ffffffffc0200aa4:	c4060613          	addi	a2,a2,-960 # ffffffffc02056e0 <commands+0x5b0>
ffffffffc0200aa8:	0da00593          	li	a1,218
ffffffffc0200aac:	00004517          	auipc	a0,0x4
ffffffffc0200ab0:	72450513          	addi	a0,a0,1828 # ffffffffc02051d0 <commands+0xa0>
ffffffffc0200ab4:	f20ff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0200ab8 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200ab8:	11853783          	ld	a5,280(a0)
ffffffffc0200abc:	0007c363          	bltz	a5,ffffffffc0200ac2 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200ac0:	b5a5                	j	ffffffffc0200928 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200ac2:	b3f9                	j	ffffffffc0200890 <interrupt_handler>

ffffffffc0200ac4 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ac4:	14011073          	csrw	sscratch,sp
ffffffffc0200ac8:	712d                	addi	sp,sp,-288
ffffffffc0200aca:	e406                	sd	ra,8(sp)
ffffffffc0200acc:	ec0e                	sd	gp,24(sp)
ffffffffc0200ace:	f012                	sd	tp,32(sp)
ffffffffc0200ad0:	f416                	sd	t0,40(sp)
ffffffffc0200ad2:	f81a                	sd	t1,48(sp)
ffffffffc0200ad4:	fc1e                	sd	t2,56(sp)
ffffffffc0200ad6:	e0a2                	sd	s0,64(sp)
ffffffffc0200ad8:	e4a6                	sd	s1,72(sp)
ffffffffc0200ada:	e8aa                	sd	a0,80(sp)
ffffffffc0200adc:	ecae                	sd	a1,88(sp)
ffffffffc0200ade:	f0b2                	sd	a2,96(sp)
ffffffffc0200ae0:	f4b6                	sd	a3,104(sp)
ffffffffc0200ae2:	f8ba                	sd	a4,112(sp)
ffffffffc0200ae4:	fcbe                	sd	a5,120(sp)
ffffffffc0200ae6:	e142                	sd	a6,128(sp)
ffffffffc0200ae8:	e546                	sd	a7,136(sp)
ffffffffc0200aea:	e94a                	sd	s2,144(sp)
ffffffffc0200aec:	ed4e                	sd	s3,152(sp)
ffffffffc0200aee:	f152                	sd	s4,160(sp)
ffffffffc0200af0:	f556                	sd	s5,168(sp)
ffffffffc0200af2:	f95a                	sd	s6,176(sp)
ffffffffc0200af4:	fd5e                	sd	s7,184(sp)
ffffffffc0200af6:	e1e2                	sd	s8,192(sp)
ffffffffc0200af8:	e5e6                	sd	s9,200(sp)
ffffffffc0200afa:	e9ea                	sd	s10,208(sp)
ffffffffc0200afc:	edee                	sd	s11,216(sp)
ffffffffc0200afe:	f1f2                	sd	t3,224(sp)
ffffffffc0200b00:	f5f6                	sd	t4,232(sp)
ffffffffc0200b02:	f9fa                	sd	t5,240(sp)
ffffffffc0200b04:	fdfe                	sd	t6,248(sp)
ffffffffc0200b06:	14002473          	csrr	s0,sscratch
ffffffffc0200b0a:	100024f3          	csrr	s1,sstatus
ffffffffc0200b0e:	14102973          	csrr	s2,sepc
ffffffffc0200b12:	143029f3          	csrr	s3,stval
ffffffffc0200b16:	14202a73          	csrr	s4,scause
ffffffffc0200b1a:	e822                	sd	s0,16(sp)
ffffffffc0200b1c:	e226                	sd	s1,256(sp)
ffffffffc0200b1e:	e64a                	sd	s2,264(sp)
ffffffffc0200b20:	ea4e                	sd	s3,272(sp)
ffffffffc0200b22:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b24:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b26:	f93ff0ef          	jal	ra,ffffffffc0200ab8 <trap>

ffffffffc0200b2a <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b2a:	6492                	ld	s1,256(sp)
ffffffffc0200b2c:	6932                	ld	s2,264(sp)
ffffffffc0200b2e:	10049073          	csrw	sstatus,s1
ffffffffc0200b32:	14191073          	csrw	sepc,s2
ffffffffc0200b36:	60a2                	ld	ra,8(sp)
ffffffffc0200b38:	61e2                	ld	gp,24(sp)
ffffffffc0200b3a:	7202                	ld	tp,32(sp)
ffffffffc0200b3c:	72a2                	ld	t0,40(sp)
ffffffffc0200b3e:	7342                	ld	t1,48(sp)
ffffffffc0200b40:	73e2                	ld	t2,56(sp)
ffffffffc0200b42:	6406                	ld	s0,64(sp)
ffffffffc0200b44:	64a6                	ld	s1,72(sp)
ffffffffc0200b46:	6546                	ld	a0,80(sp)
ffffffffc0200b48:	65e6                	ld	a1,88(sp)
ffffffffc0200b4a:	7606                	ld	a2,96(sp)
ffffffffc0200b4c:	76a6                	ld	a3,104(sp)
ffffffffc0200b4e:	7746                	ld	a4,112(sp)
ffffffffc0200b50:	77e6                	ld	a5,120(sp)
ffffffffc0200b52:	680a                	ld	a6,128(sp)
ffffffffc0200b54:	68aa                	ld	a7,136(sp)
ffffffffc0200b56:	694a                	ld	s2,144(sp)
ffffffffc0200b58:	69ea                	ld	s3,152(sp)
ffffffffc0200b5a:	7a0a                	ld	s4,160(sp)
ffffffffc0200b5c:	7aaa                	ld	s5,168(sp)
ffffffffc0200b5e:	7b4a                	ld	s6,176(sp)
ffffffffc0200b60:	7bea                	ld	s7,184(sp)
ffffffffc0200b62:	6c0e                	ld	s8,192(sp)
ffffffffc0200b64:	6cae                	ld	s9,200(sp)
ffffffffc0200b66:	6d4e                	ld	s10,208(sp)
ffffffffc0200b68:	6dee                	ld	s11,216(sp)
ffffffffc0200b6a:	7e0e                	ld	t3,224(sp)
ffffffffc0200b6c:	7eae                	ld	t4,232(sp)
ffffffffc0200b6e:	7f4e                	ld	t5,240(sp)
ffffffffc0200b70:	7fee                	ld	t6,248(sp)
ffffffffc0200b72:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200b74:	10200073          	sret

ffffffffc0200b78 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200b78:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200b7a:	bf45                	j	ffffffffc0200b2a <__trapret>
	...

ffffffffc0200b7e <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200b7e:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200b80:	00005697          	auipc	a3,0x5
ffffffffc0200b84:	cb868693          	addi	a3,a3,-840 # ffffffffc0205838 <commands+0x708>
ffffffffc0200b88:	00005617          	auipc	a2,0x5
ffffffffc0200b8c:	cd060613          	addi	a2,a2,-816 # ffffffffc0205858 <commands+0x728>
ffffffffc0200b90:	07e00593          	li	a1,126
ffffffffc0200b94:	00005517          	auipc	a0,0x5
ffffffffc0200b98:	cdc50513          	addi	a0,a0,-804 # ffffffffc0205870 <commands+0x740>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200b9c:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200b9e:	e36ff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0200ba2 <mm_create>:
mm_create(void) {
ffffffffc0200ba2:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200ba4:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0200ba8:	e022                	sd	s0,0(sp)
ffffffffc0200baa:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200bac:	67b000ef          	jal	ra,ffffffffc0201a26 <kmalloc>
ffffffffc0200bb0:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200bb2:	c105                	beqz	a0,ffffffffc0200bd2 <mm_create+0x30>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200bb4:	e408                	sd	a0,8(s0)
ffffffffc0200bb6:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200bb8:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200bbc:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200bc0:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200bc4:	00015797          	auipc	a5,0x15
ffffffffc0200bc8:	9b47a783          	lw	a5,-1612(a5) # ffffffffc0215578 <swap_init_ok>
ffffffffc0200bcc:	eb81                	bnez	a5,ffffffffc0200bdc <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc0200bce:	02053423          	sd	zero,40(a0)
}
ffffffffc0200bd2:	60a2                	ld	ra,8(sp)
ffffffffc0200bd4:	8522                	mv	a0,s0
ffffffffc0200bd6:	6402                	ld	s0,0(sp)
ffffffffc0200bd8:	0141                	addi	sp,sp,16
ffffffffc0200bda:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200bdc:	746010ef          	jal	ra,ffffffffc0202322 <swap_init_mm>
}
ffffffffc0200be0:	60a2                	ld	ra,8(sp)
ffffffffc0200be2:	8522                	mv	a0,s0
ffffffffc0200be4:	6402                	ld	s0,0(sp)
ffffffffc0200be6:	0141                	addi	sp,sp,16
ffffffffc0200be8:	8082                	ret

ffffffffc0200bea <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200bea:	1101                	addi	sp,sp,-32
ffffffffc0200bec:	e04a                	sd	s2,0(sp)
ffffffffc0200bee:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200bf0:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200bf4:	e822                	sd	s0,16(sp)
ffffffffc0200bf6:	e426                	sd	s1,8(sp)
ffffffffc0200bf8:	ec06                	sd	ra,24(sp)
ffffffffc0200bfa:	84ae                	mv	s1,a1
ffffffffc0200bfc:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200bfe:	629000ef          	jal	ra,ffffffffc0201a26 <kmalloc>
    if (vma != NULL) {
ffffffffc0200c02:	c509                	beqz	a0,ffffffffc0200c0c <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200c04:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200c08:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200c0a:	cd00                	sw	s0,24(a0)
}
ffffffffc0200c0c:	60e2                	ld	ra,24(sp)
ffffffffc0200c0e:	6442                	ld	s0,16(sp)
ffffffffc0200c10:	64a2                	ld	s1,8(sp)
ffffffffc0200c12:	6902                	ld	s2,0(sp)
ffffffffc0200c14:	6105                	addi	sp,sp,32
ffffffffc0200c16:	8082                	ret

ffffffffc0200c18 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0200c18:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0200c1a:	c505                	beqz	a0,ffffffffc0200c42 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0200c1c:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200c1e:	c501                	beqz	a0,ffffffffc0200c26 <find_vma+0xe>
ffffffffc0200c20:	651c                	ld	a5,8(a0)
ffffffffc0200c22:	02f5f263          	bgeu	a1,a5,ffffffffc0200c46 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200c26:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0200c28:	00f68d63          	beq	a3,a5,ffffffffc0200c42 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200c2c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200c30:	00e5e663          	bltu	a1,a4,ffffffffc0200c3c <find_vma+0x24>
ffffffffc0200c34:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200c38:	00e5ec63          	bltu	a1,a4,ffffffffc0200c50 <find_vma+0x38>
ffffffffc0200c3c:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200c3e:	fef697e3          	bne	a3,a5,ffffffffc0200c2c <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0200c42:	4501                	li	a0,0
}
ffffffffc0200c44:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200c46:	691c                	ld	a5,16(a0)
ffffffffc0200c48:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0200c26 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0200c4c:	ea88                	sd	a0,16(a3)
ffffffffc0200c4e:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0200c50:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0200c54:	ea88                	sd	a0,16(a3)
ffffffffc0200c56:	8082                	ret

ffffffffc0200c58 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200c58:	6590                	ld	a2,8(a1)
ffffffffc0200c5a:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200c5e:	1141                	addi	sp,sp,-16
ffffffffc0200c60:	e406                	sd	ra,8(sp)
ffffffffc0200c62:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200c64:	01066763          	bltu	a2,a6,ffffffffc0200c72 <insert_vma_struct+0x1a>
ffffffffc0200c68:	a085                	j	ffffffffc0200cc8 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200c6a:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200c6e:	04e66863          	bltu	a2,a4,ffffffffc0200cbe <insert_vma_struct+0x66>
ffffffffc0200c72:	86be                	mv	a3,a5
ffffffffc0200c74:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0200c76:	fef51ae3          	bne	a0,a5,ffffffffc0200c6a <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200c7a:	02a68463          	beq	a3,a0,ffffffffc0200ca2 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200c7e:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200c82:	fe86b883          	ld	a7,-24(a3)
ffffffffc0200c86:	08e8f163          	bgeu	a7,a4,ffffffffc0200d08 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200c8a:	04e66f63          	bltu	a2,a4,ffffffffc0200ce8 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0200c8e:	00f50a63          	beq	a0,a5,ffffffffc0200ca2 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200c92:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200c96:	05076963          	bltu	a4,a6,ffffffffc0200ce8 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0200c9a:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200c9e:	02c77363          	bgeu	a4,a2,ffffffffc0200cc4 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200ca2:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0200ca4:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200ca6:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200caa:	e390                	sd	a2,0(a5)
ffffffffc0200cac:	e690                	sd	a2,8(a3)
}
ffffffffc0200cae:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200cb0:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200cb2:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0200cb4:	0017079b          	addiw	a5,a4,1
ffffffffc0200cb8:	d11c                	sw	a5,32(a0)
}
ffffffffc0200cba:	0141                	addi	sp,sp,16
ffffffffc0200cbc:	8082                	ret
    if (le_prev != list) {
ffffffffc0200cbe:	fca690e3          	bne	a3,a0,ffffffffc0200c7e <insert_vma_struct+0x26>
ffffffffc0200cc2:	bfd1                	j	ffffffffc0200c96 <insert_vma_struct+0x3e>
ffffffffc0200cc4:	ebbff0ef          	jal	ra,ffffffffc0200b7e <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200cc8:	00005697          	auipc	a3,0x5
ffffffffc0200ccc:	bb868693          	addi	a3,a3,-1096 # ffffffffc0205880 <commands+0x750>
ffffffffc0200cd0:	00005617          	auipc	a2,0x5
ffffffffc0200cd4:	b8860613          	addi	a2,a2,-1144 # ffffffffc0205858 <commands+0x728>
ffffffffc0200cd8:	08500593          	li	a1,133
ffffffffc0200cdc:	00005517          	auipc	a0,0x5
ffffffffc0200ce0:	b9450513          	addi	a0,a0,-1132 # ffffffffc0205870 <commands+0x740>
ffffffffc0200ce4:	cf0ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200ce8:	00005697          	auipc	a3,0x5
ffffffffc0200cec:	bd868693          	addi	a3,a3,-1064 # ffffffffc02058c0 <commands+0x790>
ffffffffc0200cf0:	00005617          	auipc	a2,0x5
ffffffffc0200cf4:	b6860613          	addi	a2,a2,-1176 # ffffffffc0205858 <commands+0x728>
ffffffffc0200cf8:	07d00593          	li	a1,125
ffffffffc0200cfc:	00005517          	auipc	a0,0x5
ffffffffc0200d00:	b7450513          	addi	a0,a0,-1164 # ffffffffc0205870 <commands+0x740>
ffffffffc0200d04:	cd0ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200d08:	00005697          	auipc	a3,0x5
ffffffffc0200d0c:	b9868693          	addi	a3,a3,-1128 # ffffffffc02058a0 <commands+0x770>
ffffffffc0200d10:	00005617          	auipc	a2,0x5
ffffffffc0200d14:	b4860613          	addi	a2,a2,-1208 # ffffffffc0205858 <commands+0x728>
ffffffffc0200d18:	07c00593          	li	a1,124
ffffffffc0200d1c:	00005517          	auipc	a0,0x5
ffffffffc0200d20:	b5450513          	addi	a0,a0,-1196 # ffffffffc0205870 <commands+0x740>
ffffffffc0200d24:	cb0ff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0200d28 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0200d28:	1141                	addi	sp,sp,-16
ffffffffc0200d2a:	e022                	sd	s0,0(sp)
ffffffffc0200d2c:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200d2e:	6508                	ld	a0,8(a0)
ffffffffc0200d30:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200d32:	00a40c63          	beq	s0,a0,ffffffffc0200d4a <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d36:	6118                	ld	a4,0(a0)
ffffffffc0200d38:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0200d3a:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200d3c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200d3e:	e398                	sd	a4,0(a5)
ffffffffc0200d40:	597000ef          	jal	ra,ffffffffc0201ad6 <kfree>
    return listelm->next;
ffffffffc0200d44:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200d46:	fea418e3          	bne	s0,a0,ffffffffc0200d36 <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0200d4a:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0200d4c:	6402                	ld	s0,0(sp)
ffffffffc0200d4e:	60a2                	ld	ra,8(sp)
ffffffffc0200d50:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0200d52:	5850006f          	j	ffffffffc0201ad6 <kfree>

ffffffffc0200d56 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0200d56:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200d58:	03000513          	li	a0,48
vmm_init(void) {
ffffffffc0200d5c:	fc06                	sd	ra,56(sp)
ffffffffc0200d5e:	f822                	sd	s0,48(sp)
ffffffffc0200d60:	f426                	sd	s1,40(sp)
ffffffffc0200d62:	f04a                	sd	s2,32(sp)
ffffffffc0200d64:	ec4e                	sd	s3,24(sp)
ffffffffc0200d66:	e852                	sd	s4,16(sp)
ffffffffc0200d68:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200d6a:	4bd000ef          	jal	ra,ffffffffc0201a26 <kmalloc>
    if (mm != NULL) {
ffffffffc0200d6e:	58050e63          	beqz	a0,ffffffffc020130a <vmm_init+0x5b4>
    elm->prev = elm->next = elm;
ffffffffc0200d72:	e508                	sd	a0,8(a0)
ffffffffc0200d74:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200d76:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200d7a:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200d7e:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200d82:	00014797          	auipc	a5,0x14
ffffffffc0200d86:	7f67a783          	lw	a5,2038(a5) # ffffffffc0215578 <swap_init_ok>
ffffffffc0200d8a:	84aa                	mv	s1,a0
ffffffffc0200d8c:	e7b9                	bnez	a5,ffffffffc0200dda <vmm_init+0x84>
        else mm->sm_priv = NULL;
ffffffffc0200d8e:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc0200d92:	03200413          	li	s0,50
ffffffffc0200d96:	a811                	j	ffffffffc0200daa <vmm_init+0x54>
        vma->vm_start = vm_start;
ffffffffc0200d98:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200d9a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200d9c:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0200da0:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200da2:	8526                	mv	a0,s1
ffffffffc0200da4:	eb5ff0ef          	jal	ra,ffffffffc0200c58 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0200da8:	cc05                	beqz	s0,ffffffffc0200de0 <vmm_init+0x8a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200daa:	03000513          	li	a0,48
ffffffffc0200dae:	479000ef          	jal	ra,ffffffffc0201a26 <kmalloc>
ffffffffc0200db2:	85aa                	mv	a1,a0
ffffffffc0200db4:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200db8:	f165                	bnez	a0,ffffffffc0200d98 <vmm_init+0x42>
        assert(vma != NULL);
ffffffffc0200dba:	00005697          	auipc	a3,0x5
ffffffffc0200dbe:	d7e68693          	addi	a3,a3,-642 # ffffffffc0205b38 <commands+0xa08>
ffffffffc0200dc2:	00005617          	auipc	a2,0x5
ffffffffc0200dc6:	a9660613          	addi	a2,a2,-1386 # ffffffffc0205858 <commands+0x728>
ffffffffc0200dca:	0c900593          	li	a1,201
ffffffffc0200dce:	00005517          	auipc	a0,0x5
ffffffffc0200dd2:	aa250513          	addi	a0,a0,-1374 # ffffffffc0205870 <commands+0x740>
ffffffffc0200dd6:	bfeff0ef          	jal	ra,ffffffffc02001d4 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200dda:	548010ef          	jal	ra,ffffffffc0202322 <swap_init_mm>
ffffffffc0200dde:	bf55                	j	ffffffffc0200d92 <vmm_init+0x3c>
ffffffffc0200de0:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200de4:	1f900913          	li	s2,505
ffffffffc0200de8:	a819                	j	ffffffffc0200dfe <vmm_init+0xa8>
        vma->vm_start = vm_start;
ffffffffc0200dea:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200dec:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200dee:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200df2:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200df4:	8526                	mv	a0,s1
ffffffffc0200df6:	e63ff0ef          	jal	ra,ffffffffc0200c58 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200dfa:	03240a63          	beq	s0,s2,ffffffffc0200e2e <vmm_init+0xd8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200dfe:	03000513          	li	a0,48
ffffffffc0200e02:	425000ef          	jal	ra,ffffffffc0201a26 <kmalloc>
ffffffffc0200e06:	85aa                	mv	a1,a0
ffffffffc0200e08:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200e0c:	fd79                	bnez	a0,ffffffffc0200dea <vmm_init+0x94>
        assert(vma != NULL);
ffffffffc0200e0e:	00005697          	auipc	a3,0x5
ffffffffc0200e12:	d2a68693          	addi	a3,a3,-726 # ffffffffc0205b38 <commands+0xa08>
ffffffffc0200e16:	00005617          	auipc	a2,0x5
ffffffffc0200e1a:	a4260613          	addi	a2,a2,-1470 # ffffffffc0205858 <commands+0x728>
ffffffffc0200e1e:	0cf00593          	li	a1,207
ffffffffc0200e22:	00005517          	auipc	a0,0x5
ffffffffc0200e26:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0205870 <commands+0x740>
ffffffffc0200e2a:	baaff0ef          	jal	ra,ffffffffc02001d4 <__panic>
    return listelm->next;
ffffffffc0200e2e:	649c                	ld	a5,8(s1)
ffffffffc0200e30:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0200e32:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0200e36:	30f48e63          	beq	s1,a5,ffffffffc0201152 <vmm_init+0x3fc>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0200e3a:	fe87b683          	ld	a3,-24(a5)
ffffffffc0200e3e:	ffe70613          	addi	a2,a4,-2
ffffffffc0200e42:	2ad61863          	bne	a2,a3,ffffffffc02010f2 <vmm_init+0x39c>
ffffffffc0200e46:	ff07b683          	ld	a3,-16(a5)
ffffffffc0200e4a:	2ae69463          	bne	a3,a4,ffffffffc02010f2 <vmm_init+0x39c>
    for (i = 1; i <= step2; i ++) {
ffffffffc0200e4e:	0715                	addi	a4,a4,5
ffffffffc0200e50:	679c                	ld	a5,8(a5)
ffffffffc0200e52:	feb712e3          	bne	a4,a1,ffffffffc0200e36 <vmm_init+0xe0>
ffffffffc0200e56:	4a1d                	li	s4,7
ffffffffc0200e58:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200e5a:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0200e5e:	85a2                	mv	a1,s0
ffffffffc0200e60:	8526                	mv	a0,s1
ffffffffc0200e62:	db7ff0ef          	jal	ra,ffffffffc0200c18 <find_vma>
ffffffffc0200e66:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0200e68:	34050563          	beqz	a0,ffffffffc02011b2 <vmm_init+0x45c>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0200e6c:	00140593          	addi	a1,s0,1
ffffffffc0200e70:	8526                	mv	a0,s1
ffffffffc0200e72:	da7ff0ef          	jal	ra,ffffffffc0200c18 <find_vma>
ffffffffc0200e76:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0200e78:	34050d63          	beqz	a0,ffffffffc02011d2 <vmm_init+0x47c>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0200e7c:	85d2                	mv	a1,s4
ffffffffc0200e7e:	8526                	mv	a0,s1
ffffffffc0200e80:	d99ff0ef          	jal	ra,ffffffffc0200c18 <find_vma>
        assert(vma3 == NULL);
ffffffffc0200e84:	36051763          	bnez	a0,ffffffffc02011f2 <vmm_init+0x49c>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0200e88:	00340593          	addi	a1,s0,3
ffffffffc0200e8c:	8526                	mv	a0,s1
ffffffffc0200e8e:	d8bff0ef          	jal	ra,ffffffffc0200c18 <find_vma>
        assert(vma4 == NULL);
ffffffffc0200e92:	2e051063          	bnez	a0,ffffffffc0201172 <vmm_init+0x41c>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0200e96:	00440593          	addi	a1,s0,4
ffffffffc0200e9a:	8526                	mv	a0,s1
ffffffffc0200e9c:	d7dff0ef          	jal	ra,ffffffffc0200c18 <find_vma>
        assert(vma5 == NULL);
ffffffffc0200ea0:	2e051963          	bnez	a0,ffffffffc0201192 <vmm_init+0x43c>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0200ea4:	00893783          	ld	a5,8(s2)
ffffffffc0200ea8:	26879563          	bne	a5,s0,ffffffffc0201112 <vmm_init+0x3bc>
ffffffffc0200eac:	01093783          	ld	a5,16(s2)
ffffffffc0200eb0:	27479163          	bne	a5,s4,ffffffffc0201112 <vmm_init+0x3bc>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0200eb4:	0089b783          	ld	a5,8(s3)
ffffffffc0200eb8:	26879d63          	bne	a5,s0,ffffffffc0201132 <vmm_init+0x3dc>
ffffffffc0200ebc:	0109b783          	ld	a5,16(s3)
ffffffffc0200ec0:	27479963          	bne	a5,s4,ffffffffc0201132 <vmm_init+0x3dc>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200ec4:	0415                	addi	s0,s0,5
ffffffffc0200ec6:	0a15                	addi	s4,s4,5
ffffffffc0200ec8:	f9541be3          	bne	s0,s5,ffffffffc0200e5e <vmm_init+0x108>
ffffffffc0200ecc:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0200ece:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0200ed0:	85a2                	mv	a1,s0
ffffffffc0200ed2:	8526                	mv	a0,s1
ffffffffc0200ed4:	d45ff0ef          	jal	ra,ffffffffc0200c18 <find_vma>
ffffffffc0200ed8:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0200edc:	c90d                	beqz	a0,ffffffffc0200f0e <vmm_init+0x1b8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0200ede:	6914                	ld	a3,16(a0)
ffffffffc0200ee0:	6510                	ld	a2,8(a0)
ffffffffc0200ee2:	00005517          	auipc	a0,0x5
ffffffffc0200ee6:	afe50513          	addi	a0,a0,-1282 # ffffffffc02059e0 <commands+0x8b0>
ffffffffc0200eea:	9eeff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0200eee:	00005697          	auipc	a3,0x5
ffffffffc0200ef2:	b1a68693          	addi	a3,a3,-1254 # ffffffffc0205a08 <commands+0x8d8>
ffffffffc0200ef6:	00005617          	auipc	a2,0x5
ffffffffc0200efa:	96260613          	addi	a2,a2,-1694 # ffffffffc0205858 <commands+0x728>
ffffffffc0200efe:	0f100593          	li	a1,241
ffffffffc0200f02:	00005517          	auipc	a0,0x5
ffffffffc0200f06:	96e50513          	addi	a0,a0,-1682 # ffffffffc0205870 <commands+0x740>
ffffffffc0200f0a:	acaff0ef          	jal	ra,ffffffffc02001d4 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0200f0e:	147d                	addi	s0,s0,-1
ffffffffc0200f10:	fd2410e3          	bne	s0,s2,ffffffffc0200ed0 <vmm_init+0x17a>
ffffffffc0200f14:	a801                	j	ffffffffc0200f24 <vmm_init+0x1ce>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200f16:	6118                	ld	a4,0(a0)
ffffffffc0200f18:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0200f1a:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0200f1c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200f1e:	e398                	sd	a4,0(a5)
ffffffffc0200f20:	3b7000ef          	jal	ra,ffffffffc0201ad6 <kfree>
    return listelm->next;
ffffffffc0200f24:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0200f26:	fea498e3          	bne	s1,a0,ffffffffc0200f16 <vmm_init+0x1c0>
    kfree(mm); //kfree mm
ffffffffc0200f2a:	8526                	mv	a0,s1
ffffffffc0200f2c:	3ab000ef          	jal	ra,ffffffffc0201ad6 <kfree>
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0200f30:	00005517          	auipc	a0,0x5
ffffffffc0200f34:	af050513          	addi	a0,a0,-1296 # ffffffffc0205a20 <commands+0x8f0>
ffffffffc0200f38:	9a0ff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200f3c:	144020ef          	jal	ra,ffffffffc0203080 <nr_free_pages>
ffffffffc0200f40:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200f42:	03000513          	li	a0,48
ffffffffc0200f46:	2e1000ef          	jal	ra,ffffffffc0201a26 <kmalloc>
ffffffffc0200f4a:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200f4c:	2c050363          	beqz	a0,ffffffffc0201212 <vmm_init+0x4bc>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200f50:	00014797          	auipc	a5,0x14
ffffffffc0200f54:	6287a783          	lw	a5,1576(a5) # ffffffffc0215578 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0200f58:	e508                	sd	a0,8(a0)
ffffffffc0200f5a:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200f5c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200f60:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200f64:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200f68:	18079263          	bnez	a5,ffffffffc02010ec <vmm_init+0x396>
        else mm->sm_priv = NULL;
ffffffffc0200f6c:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();
    assert(check_mm_struct != NULL);

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200f70:	00014917          	auipc	s2,0x14
ffffffffc0200f74:	61893903          	ld	s2,1560(s2) # ffffffffc0215588 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0200f78:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0200f7c:	00014717          	auipc	a4,0x14
ffffffffc0200f80:	5c873a23          	sd	s0,1492(a4) # ffffffffc0215550 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200f84:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0200f88:	36079163          	bnez	a5,ffffffffc02012ea <vmm_init+0x594>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200f8c:	03000513          	li	a0,48
ffffffffc0200f90:	297000ef          	jal	ra,ffffffffc0201a26 <kmalloc>
ffffffffc0200f94:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0200f96:	2a050263          	beqz	a0,ffffffffc020123a <vmm_init+0x4e4>
        vma->vm_end = vm_end;
ffffffffc0200f9a:	002007b7          	lui	a5,0x200
ffffffffc0200f9e:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc0200fa2:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0200fa4:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0200fa6:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc0200faa:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0200fac:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc0200fb0:	ca9ff0ef          	jal	ra,ffffffffc0200c58 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0200fb4:	10000593          	li	a1,256
ffffffffc0200fb8:	8522                	mv	a0,s0
ffffffffc0200fba:	c5fff0ef          	jal	ra,ffffffffc0200c18 <find_vma>
ffffffffc0200fbe:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0200fc2:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0200fc6:	28a99a63          	bne	s3,a0,ffffffffc020125a <vmm_init+0x504>
        *(char *)(addr + i) = i;
ffffffffc0200fca:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0200fce:	0785                	addi	a5,a5,1
ffffffffc0200fd0:	fee79de3          	bne	a5,a4,ffffffffc0200fca <vmm_init+0x274>
        sum += i;
ffffffffc0200fd4:	6705                	lui	a4,0x1
ffffffffc0200fd6:	10000793          	li	a5,256
ffffffffc0200fda:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0200fde:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0200fe2:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0200fe6:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0200fe8:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0200fea:	fec79ce3          	bne	a5,a2,ffffffffc0200fe2 <vmm_init+0x28c>
    }
    assert(sum == 0);
ffffffffc0200fee:	28071663          	bnez	a4,ffffffffc020127a <vmm_init+0x524>
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0200ff2:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0200ff6:	00014a97          	auipc	s5,0x14
ffffffffc0200ffa:	59aa8a93          	addi	s5,s5,1434 # ffffffffc0215590 <npage>
ffffffffc0200ffe:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201002:	078a                	slli	a5,a5,0x2
ffffffffc0201004:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201006:	28c7fa63          	bgeu	a5,a2,ffffffffc020129a <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc020100a:	00006a17          	auipc	s4,0x6
ffffffffc020100e:	f7ea3a03          	ld	s4,-130(s4) # ffffffffc0206f88 <nbase>
ffffffffc0201012:	414787b3          	sub	a5,a5,s4
ffffffffc0201016:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc0201018:	8799                	srai	a5,a5,0x6
ffffffffc020101a:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc020101c:	00c79713          	slli	a4,a5,0xc
ffffffffc0201020:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201022:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0201026:	28c77663          	bgeu	a4,a2,ffffffffc02012b2 <vmm_init+0x55c>
ffffffffc020102a:	00014997          	auipc	s3,0x14
ffffffffc020102e:	57e9b983          	ld	s3,1406(s3) # ffffffffc02155a8 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0201032:	4581                	li	a1,0
ffffffffc0201034:	854a                	mv	a0,s2
ffffffffc0201036:	99b6                	add	s3,s3,a3
ffffffffc0201038:	2a8020ef          	jal	ra,ffffffffc02032e0 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020103c:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0201040:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201044:	078a                	slli	a5,a5,0x2
ffffffffc0201046:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201048:	24e7f963          	bgeu	a5,a4,ffffffffc020129a <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc020104c:	00014997          	auipc	s3,0x14
ffffffffc0201050:	54c98993          	addi	s3,s3,1356 # ffffffffc0215598 <pages>
ffffffffc0201054:	0009b503          	ld	a0,0(s3)
ffffffffc0201058:	414787b3          	sub	a5,a5,s4
ffffffffc020105c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc020105e:	953e                	add	a0,a0,a5
ffffffffc0201060:	4585                	li	a1,1
ffffffffc0201062:	7df010ef          	jal	ra,ffffffffc0203040 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201066:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020106a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020106e:	078a                	slli	a5,a5,0x2
ffffffffc0201070:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201072:	22e7f463          	bgeu	a5,a4,ffffffffc020129a <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0201076:	0009b503          	ld	a0,0(s3)
ffffffffc020107a:	414787b3          	sub	a5,a5,s4
ffffffffc020107e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201080:	4585                	li	a1,1
ffffffffc0201082:	953e                	add	a0,a0,a5
ffffffffc0201084:	7bd010ef          	jal	ra,ffffffffc0203040 <free_pages>
    pgdir[0] = 0;
ffffffffc0201088:	00093023          	sd	zero,0(s2)
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() {
  asm volatile("sfence.vma");
ffffffffc020108c:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0201090:	6408                	ld	a0,8(s0)
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0201092:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201096:	00a40c63          	beq	s0,a0,ffffffffc02010ae <vmm_init+0x358>
    __list_del(listelm->prev, listelm->next);
ffffffffc020109a:	6118                	ld	a4,0(a0)
ffffffffc020109c:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc020109e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02010a0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02010a2:	e398                	sd	a4,0(a5)
ffffffffc02010a4:	233000ef          	jal	ra,ffffffffc0201ad6 <kfree>
    return listelm->next;
ffffffffc02010a8:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02010aa:	fea418e3          	bne	s0,a0,ffffffffc020109a <vmm_init+0x344>
    kfree(mm); //kfree mm
ffffffffc02010ae:	8522                	mv	a0,s0
ffffffffc02010b0:	227000ef          	jal	ra,ffffffffc0201ad6 <kfree>
    mm_destroy(mm);
    check_mm_struct = NULL;
ffffffffc02010b4:	00014797          	auipc	a5,0x14
ffffffffc02010b8:	4807be23          	sd	zero,1180(a5) # ffffffffc0215550 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02010bc:	7c5010ef          	jal	ra,ffffffffc0203080 <nr_free_pages>
ffffffffc02010c0:	20a49563          	bne	s1,a0,ffffffffc02012ca <vmm_init+0x574>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02010c4:	00005517          	auipc	a0,0x5
ffffffffc02010c8:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0205b00 <commands+0x9d0>
ffffffffc02010cc:	80cff0ef          	jal	ra,ffffffffc02000d8 <cprintf>
}
ffffffffc02010d0:	7442                	ld	s0,48(sp)
ffffffffc02010d2:	70e2                	ld	ra,56(sp)
ffffffffc02010d4:	74a2                	ld	s1,40(sp)
ffffffffc02010d6:	7902                	ld	s2,32(sp)
ffffffffc02010d8:	69e2                	ld	s3,24(sp)
ffffffffc02010da:	6a42                	ld	s4,16(sp)
ffffffffc02010dc:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02010de:	00005517          	auipc	a0,0x5
ffffffffc02010e2:	a4250513          	addi	a0,a0,-1470 # ffffffffc0205b20 <commands+0x9f0>
}
ffffffffc02010e6:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02010e8:	ff1fe06f          	j	ffffffffc02000d8 <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02010ec:	236010ef          	jal	ra,ffffffffc0202322 <swap_init_mm>
ffffffffc02010f0:	b541                	j	ffffffffc0200f70 <vmm_init+0x21a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02010f2:	00005697          	auipc	a3,0x5
ffffffffc02010f6:	80668693          	addi	a3,a3,-2042 # ffffffffc02058f8 <commands+0x7c8>
ffffffffc02010fa:	00004617          	auipc	a2,0x4
ffffffffc02010fe:	75e60613          	addi	a2,a2,1886 # ffffffffc0205858 <commands+0x728>
ffffffffc0201102:	0d800593          	li	a1,216
ffffffffc0201106:	00004517          	auipc	a0,0x4
ffffffffc020110a:	76a50513          	addi	a0,a0,1898 # ffffffffc0205870 <commands+0x740>
ffffffffc020110e:	8c6ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201112:	00005697          	auipc	a3,0x5
ffffffffc0201116:	86e68693          	addi	a3,a3,-1938 # ffffffffc0205980 <commands+0x850>
ffffffffc020111a:	00004617          	auipc	a2,0x4
ffffffffc020111e:	73e60613          	addi	a2,a2,1854 # ffffffffc0205858 <commands+0x728>
ffffffffc0201122:	0e800593          	li	a1,232
ffffffffc0201126:	00004517          	auipc	a0,0x4
ffffffffc020112a:	74a50513          	addi	a0,a0,1866 # ffffffffc0205870 <commands+0x740>
ffffffffc020112e:	8a6ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201132:	00005697          	auipc	a3,0x5
ffffffffc0201136:	87e68693          	addi	a3,a3,-1922 # ffffffffc02059b0 <commands+0x880>
ffffffffc020113a:	00004617          	auipc	a2,0x4
ffffffffc020113e:	71e60613          	addi	a2,a2,1822 # ffffffffc0205858 <commands+0x728>
ffffffffc0201142:	0e900593          	li	a1,233
ffffffffc0201146:	00004517          	auipc	a0,0x4
ffffffffc020114a:	72a50513          	addi	a0,a0,1834 # ffffffffc0205870 <commands+0x740>
ffffffffc020114e:	886ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201152:	00004697          	auipc	a3,0x4
ffffffffc0201156:	78e68693          	addi	a3,a3,1934 # ffffffffc02058e0 <commands+0x7b0>
ffffffffc020115a:	00004617          	auipc	a2,0x4
ffffffffc020115e:	6fe60613          	addi	a2,a2,1790 # ffffffffc0205858 <commands+0x728>
ffffffffc0201162:	0d600593          	li	a1,214
ffffffffc0201166:	00004517          	auipc	a0,0x4
ffffffffc020116a:	70a50513          	addi	a0,a0,1802 # ffffffffc0205870 <commands+0x740>
ffffffffc020116e:	866ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma4 == NULL);
ffffffffc0201172:	00004697          	auipc	a3,0x4
ffffffffc0201176:	7ee68693          	addi	a3,a3,2030 # ffffffffc0205960 <commands+0x830>
ffffffffc020117a:	00004617          	auipc	a2,0x4
ffffffffc020117e:	6de60613          	addi	a2,a2,1758 # ffffffffc0205858 <commands+0x728>
ffffffffc0201182:	0e400593          	li	a1,228
ffffffffc0201186:	00004517          	auipc	a0,0x4
ffffffffc020118a:	6ea50513          	addi	a0,a0,1770 # ffffffffc0205870 <commands+0x740>
ffffffffc020118e:	846ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma5 == NULL);
ffffffffc0201192:	00004697          	auipc	a3,0x4
ffffffffc0201196:	7de68693          	addi	a3,a3,2014 # ffffffffc0205970 <commands+0x840>
ffffffffc020119a:	00004617          	auipc	a2,0x4
ffffffffc020119e:	6be60613          	addi	a2,a2,1726 # ffffffffc0205858 <commands+0x728>
ffffffffc02011a2:	0e600593          	li	a1,230
ffffffffc02011a6:	00004517          	auipc	a0,0x4
ffffffffc02011aa:	6ca50513          	addi	a0,a0,1738 # ffffffffc0205870 <commands+0x740>
ffffffffc02011ae:	826ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma1 != NULL);
ffffffffc02011b2:	00004697          	auipc	a3,0x4
ffffffffc02011b6:	77e68693          	addi	a3,a3,1918 # ffffffffc0205930 <commands+0x800>
ffffffffc02011ba:	00004617          	auipc	a2,0x4
ffffffffc02011be:	69e60613          	addi	a2,a2,1694 # ffffffffc0205858 <commands+0x728>
ffffffffc02011c2:	0de00593          	li	a1,222
ffffffffc02011c6:	00004517          	auipc	a0,0x4
ffffffffc02011ca:	6aa50513          	addi	a0,a0,1706 # ffffffffc0205870 <commands+0x740>
ffffffffc02011ce:	806ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma2 != NULL);
ffffffffc02011d2:	00004697          	auipc	a3,0x4
ffffffffc02011d6:	76e68693          	addi	a3,a3,1902 # ffffffffc0205940 <commands+0x810>
ffffffffc02011da:	00004617          	auipc	a2,0x4
ffffffffc02011de:	67e60613          	addi	a2,a2,1662 # ffffffffc0205858 <commands+0x728>
ffffffffc02011e2:	0e000593          	li	a1,224
ffffffffc02011e6:	00004517          	auipc	a0,0x4
ffffffffc02011ea:	68a50513          	addi	a0,a0,1674 # ffffffffc0205870 <commands+0x740>
ffffffffc02011ee:	fe7fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma3 == NULL);
ffffffffc02011f2:	00004697          	auipc	a3,0x4
ffffffffc02011f6:	75e68693          	addi	a3,a3,1886 # ffffffffc0205950 <commands+0x820>
ffffffffc02011fa:	00004617          	auipc	a2,0x4
ffffffffc02011fe:	65e60613          	addi	a2,a2,1630 # ffffffffc0205858 <commands+0x728>
ffffffffc0201202:	0e200593          	li	a1,226
ffffffffc0201206:	00004517          	auipc	a0,0x4
ffffffffc020120a:	66a50513          	addi	a0,a0,1642 # ffffffffc0205870 <commands+0x740>
ffffffffc020120e:	fc7fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0201212:	00005697          	auipc	a3,0x5
ffffffffc0201216:	93668693          	addi	a3,a3,-1738 # ffffffffc0205b48 <commands+0xa18>
ffffffffc020121a:	00004617          	auipc	a2,0x4
ffffffffc020121e:	63e60613          	addi	a2,a2,1598 # ffffffffc0205858 <commands+0x728>
ffffffffc0201222:	10100593          	li	a1,257
ffffffffc0201226:	00004517          	auipc	a0,0x4
ffffffffc020122a:	64a50513          	addi	a0,a0,1610 # ffffffffc0205870 <commands+0x740>
    check_mm_struct = mm_create();
ffffffffc020122e:	00014797          	auipc	a5,0x14
ffffffffc0201232:	3207b123          	sd	zero,802(a5) # ffffffffc0215550 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0201236:	f9ffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(vma != NULL);
ffffffffc020123a:	00005697          	auipc	a3,0x5
ffffffffc020123e:	8fe68693          	addi	a3,a3,-1794 # ffffffffc0205b38 <commands+0xa08>
ffffffffc0201242:	00004617          	auipc	a2,0x4
ffffffffc0201246:	61660613          	addi	a2,a2,1558 # ffffffffc0205858 <commands+0x728>
ffffffffc020124a:	10800593          	li	a1,264
ffffffffc020124e:	00004517          	auipc	a0,0x4
ffffffffc0201252:	62250513          	addi	a0,a0,1570 # ffffffffc0205870 <commands+0x740>
ffffffffc0201256:	f7ffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc020125a:	00004697          	auipc	a3,0x4
ffffffffc020125e:	7f668693          	addi	a3,a3,2038 # ffffffffc0205a50 <commands+0x920>
ffffffffc0201262:	00004617          	auipc	a2,0x4
ffffffffc0201266:	5f660613          	addi	a2,a2,1526 # ffffffffc0205858 <commands+0x728>
ffffffffc020126a:	10d00593          	li	a1,269
ffffffffc020126e:	00004517          	auipc	a0,0x4
ffffffffc0201272:	60250513          	addi	a0,a0,1538 # ffffffffc0205870 <commands+0x740>
ffffffffc0201276:	f5ffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(sum == 0);
ffffffffc020127a:	00004697          	auipc	a3,0x4
ffffffffc020127e:	7f668693          	addi	a3,a3,2038 # ffffffffc0205a70 <commands+0x940>
ffffffffc0201282:	00004617          	auipc	a2,0x4
ffffffffc0201286:	5d660613          	addi	a2,a2,1494 # ffffffffc0205858 <commands+0x728>
ffffffffc020128a:	11700593          	li	a1,279
ffffffffc020128e:	00004517          	auipc	a0,0x4
ffffffffc0201292:	5e250513          	addi	a0,a0,1506 # ffffffffc0205870 <commands+0x740>
ffffffffc0201296:	f3ffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020129a:	00004617          	auipc	a2,0x4
ffffffffc020129e:	7e660613          	addi	a2,a2,2022 # ffffffffc0205a80 <commands+0x950>
ffffffffc02012a2:	06200593          	li	a1,98
ffffffffc02012a6:	00004517          	auipc	a0,0x4
ffffffffc02012aa:	7fa50513          	addi	a0,a0,2042 # ffffffffc0205aa0 <commands+0x970>
ffffffffc02012ae:	f27fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    return KADDR(page2pa(page));
ffffffffc02012b2:	00004617          	auipc	a2,0x4
ffffffffc02012b6:	7fe60613          	addi	a2,a2,2046 # ffffffffc0205ab0 <commands+0x980>
ffffffffc02012ba:	06900593          	li	a1,105
ffffffffc02012be:	00004517          	auipc	a0,0x4
ffffffffc02012c2:	7e250513          	addi	a0,a0,2018 # ffffffffc0205aa0 <commands+0x970>
ffffffffc02012c6:	f0ffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02012ca:	00005697          	auipc	a3,0x5
ffffffffc02012ce:	80e68693          	addi	a3,a3,-2034 # ffffffffc0205ad8 <commands+0x9a8>
ffffffffc02012d2:	00004617          	auipc	a2,0x4
ffffffffc02012d6:	58660613          	addi	a2,a2,1414 # ffffffffc0205858 <commands+0x728>
ffffffffc02012da:	12400593          	li	a1,292
ffffffffc02012de:	00004517          	auipc	a0,0x4
ffffffffc02012e2:	59250513          	addi	a0,a0,1426 # ffffffffc0205870 <commands+0x740>
ffffffffc02012e6:	eeffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02012ea:	00004697          	auipc	a3,0x4
ffffffffc02012ee:	75668693          	addi	a3,a3,1878 # ffffffffc0205a40 <commands+0x910>
ffffffffc02012f2:	00004617          	auipc	a2,0x4
ffffffffc02012f6:	56660613          	addi	a2,a2,1382 # ffffffffc0205858 <commands+0x728>
ffffffffc02012fa:	10500593          	li	a1,261
ffffffffc02012fe:	00004517          	auipc	a0,0x4
ffffffffc0201302:	57250513          	addi	a0,a0,1394 # ffffffffc0205870 <commands+0x740>
ffffffffc0201306:	ecffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(mm != NULL);
ffffffffc020130a:	00005697          	auipc	a3,0x5
ffffffffc020130e:	85668693          	addi	a3,a3,-1962 # ffffffffc0205b60 <commands+0xa30>
ffffffffc0201312:	00004617          	auipc	a2,0x4
ffffffffc0201316:	54660613          	addi	a2,a2,1350 # ffffffffc0205858 <commands+0x728>
ffffffffc020131a:	0c200593          	li	a1,194
ffffffffc020131e:	00004517          	auipc	a0,0x4
ffffffffc0201322:	55250513          	addi	a0,a0,1362 # ffffffffc0205870 <commands+0x740>
ffffffffc0201326:	eaffe0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc020132a <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc020132a:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020132c:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc020132e:	f022                	sd	s0,32(sp)
ffffffffc0201330:	ec26                	sd	s1,24(sp)
ffffffffc0201332:	f406                	sd	ra,40(sp)
ffffffffc0201334:	e84a                	sd	s2,16(sp)
ffffffffc0201336:	8432                	mv	s0,a2
ffffffffc0201338:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020133a:	8dfff0ef          	jal	ra,ffffffffc0200c18 <find_vma>

    pgfault_num++;
ffffffffc020133e:	00014797          	auipc	a5,0x14
ffffffffc0201342:	21a7a783          	lw	a5,538(a5) # ffffffffc0215558 <pgfault_num>
ffffffffc0201346:	2785                	addiw	a5,a5,1
ffffffffc0201348:	00014717          	auipc	a4,0x14
ffffffffc020134c:	20f72823          	sw	a5,528(a4) # ffffffffc0215558 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201350:	c541                	beqz	a0,ffffffffc02013d8 <do_pgfault+0xae>
ffffffffc0201352:	651c                	ld	a5,8(a0)
ffffffffc0201354:	08f46263          	bltu	s0,a5,ffffffffc02013d8 <do_pgfault+0xae>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201358:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020135a:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020135c:	8b89                	andi	a5,a5,2
ffffffffc020135e:	ebb9                	bnez	a5,ffffffffc02013b4 <do_pgfault+0x8a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201360:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201362:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201364:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201366:	4605                	li	a2,1
ffffffffc0201368:	85a2                	mv	a1,s0
ffffffffc020136a:	551010ef          	jal	ra,ffffffffc02030ba <get_pte>
ffffffffc020136e:	c551                	beqz	a0,ffffffffc02013fa <do_pgfault+0xd0>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0201370:	610c                	ld	a1,0(a0)
ffffffffc0201372:	c1b9                	beqz	a1,ffffffffc02013b8 <do_pgfault+0x8e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) 
ffffffffc0201374:	00014797          	auipc	a5,0x14
ffffffffc0201378:	2047a783          	lw	a5,516(a5) # ffffffffc0215578 <swap_init_ok>
ffffffffc020137c:	c7bd                	beqz	a5,ffffffffc02013ea <do_pgfault+0xc0>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）根据mm和addr，尝试将右侧磁盘页面的内容放入页面管理的内存中。
            //(2) 根据mm、addr和page，设置物理addr<--->虚拟(logical)addr的映射
            //(3) 使页面可交换。
            swap_in(mm, addr, &page);
ffffffffc020137e:	85a2                	mv	a1,s0
ffffffffc0201380:	0030                	addi	a2,sp,8
ffffffffc0201382:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0201384:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0201386:	0c8010ef          	jal	ra,ffffffffc020244e <swap_in>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc020138a:	65a2                	ld	a1,8(sp)
ffffffffc020138c:	6c88                	ld	a0,24(s1)
ffffffffc020138e:	86ca                	mv	a3,s2
ffffffffc0201390:	8622                	mv	a2,s0
ffffffffc0201392:	7eb010ef          	jal	ra,ffffffffc020337c <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc0201396:	6622                	ld	a2,8(sp)
ffffffffc0201398:	4685                	li	a3,1
ffffffffc020139a:	85a2                	mv	a1,s0
ffffffffc020139c:	8526                	mv	a0,s1
ffffffffc020139e:	791000ef          	jal	ra,ffffffffc020232e <swap_map_swappable>
            
            page->pra_vaddr = addr;  //必须等待前几条设置好权限才能写这行
ffffffffc02013a2:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc02013a4:	4501                	li	a0,0
            page->pra_vaddr = addr;  //必须等待前几条设置好权限才能写这行
ffffffffc02013a6:	ff80                	sd	s0,56(a5)
failed:
    return ret;
ffffffffc02013a8:	70a2                	ld	ra,40(sp)
ffffffffc02013aa:	7402                	ld	s0,32(sp)
ffffffffc02013ac:	64e2                	ld	s1,24(sp)
ffffffffc02013ae:	6942                	ld	s2,16(sp)
ffffffffc02013b0:	6145                	addi	sp,sp,48
ffffffffc02013b2:	8082                	ret
        perm |= READ_WRITE;
ffffffffc02013b4:	495d                	li	s2,23
ffffffffc02013b6:	b76d                	j	ffffffffc0201360 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02013b8:	6c88                	ld	a0,24(s1)
ffffffffc02013ba:	864a                	mv	a2,s2
ffffffffc02013bc:	85a2                	mv	a1,s0
ffffffffc02013be:	455020ef          	jal	ra,ffffffffc0204012 <pgdir_alloc_page>
ffffffffc02013c2:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc02013c4:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02013c6:	f3ed                	bnez	a5,ffffffffc02013a8 <do_pgfault+0x7e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02013c8:	00004517          	auipc	a0,0x4
ffffffffc02013cc:	7f850513          	addi	a0,a0,2040 # ffffffffc0205bc0 <commands+0xa90>
ffffffffc02013d0:	d09fe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    ret = -E_NO_MEM;
ffffffffc02013d4:	5571                	li	a0,-4
            goto failed;
ffffffffc02013d6:	bfc9                	j	ffffffffc02013a8 <do_pgfault+0x7e>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc02013d8:	85a2                	mv	a1,s0
ffffffffc02013da:	00004517          	auipc	a0,0x4
ffffffffc02013de:	79650513          	addi	a0,a0,1942 # ffffffffc0205b70 <commands+0xa40>
ffffffffc02013e2:	cf7fe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    int ret = -E_INVAL;
ffffffffc02013e6:	5575                	li	a0,-3
        goto failed;
ffffffffc02013e8:	b7c1                	j	ffffffffc02013a8 <do_pgfault+0x7e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02013ea:	00004517          	auipc	a0,0x4
ffffffffc02013ee:	7fe50513          	addi	a0,a0,2046 # ffffffffc0205be8 <commands+0xab8>
ffffffffc02013f2:	ce7fe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    ret = -E_NO_MEM;
ffffffffc02013f6:	5571                	li	a0,-4
            goto failed;
ffffffffc02013f8:	bf45                	j	ffffffffc02013a8 <do_pgfault+0x7e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc02013fa:	00004517          	auipc	a0,0x4
ffffffffc02013fe:	7a650513          	addi	a0,a0,1958 # ffffffffc0205ba0 <commands+0xa70>
ffffffffc0201402:	cd7fe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201406:	5571                	li	a0,-4
        goto failed;
ffffffffc0201408:	b745                	j	ffffffffc02013a8 <do_pgfault+0x7e>

ffffffffc020140a <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020140a:	00010797          	auipc	a5,0x10
ffffffffc020140e:	05678793          	addi	a5,a5,86 # ffffffffc0211460 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0201412:	f51c                	sd	a5,40(a0)
ffffffffc0201414:	e79c                	sd	a5,8(a5)
ffffffffc0201416:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0201418:	4501                	li	a0,0
ffffffffc020141a:	8082                	ret

ffffffffc020141c <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc020141c:	4501                	li	a0,0
ffffffffc020141e:	8082                	ret

ffffffffc0201420 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0201420:	4501                	li	a0,0
ffffffffc0201422:	8082                	ret

ffffffffc0201424 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0201424:	4501                	li	a0,0
ffffffffc0201426:	8082                	ret

ffffffffc0201428 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0201428:	711d                	addi	sp,sp,-96
ffffffffc020142a:	fc4e                	sd	s3,56(sp)
ffffffffc020142c:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020142e:	00004517          	auipc	a0,0x4
ffffffffc0201432:	7e250513          	addi	a0,a0,2018 # ffffffffc0205c10 <commands+0xae0>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201436:	698d                	lui	s3,0x3
ffffffffc0201438:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc020143a:	e0ca                	sd	s2,64(sp)
ffffffffc020143c:	ec86                	sd	ra,88(sp)
ffffffffc020143e:	e8a2                	sd	s0,80(sp)
ffffffffc0201440:	e4a6                	sd	s1,72(sp)
ffffffffc0201442:	f456                	sd	s5,40(sp)
ffffffffc0201444:	f05a                	sd	s6,32(sp)
ffffffffc0201446:	ec5e                	sd	s7,24(sp)
ffffffffc0201448:	e862                	sd	s8,16(sp)
ffffffffc020144a:	e466                	sd	s9,8(sp)
ffffffffc020144c:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020144e:	c8bfe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201452:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0201456:	00014917          	auipc	s2,0x14
ffffffffc020145a:	10292903          	lw	s2,258(s2) # ffffffffc0215558 <pgfault_num>
ffffffffc020145e:	4791                	li	a5,4
ffffffffc0201460:	14f91e63          	bne	s2,a5,ffffffffc02015bc <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201464:	00004517          	auipc	a0,0x4
ffffffffc0201468:	7fc50513          	addi	a0,a0,2044 # ffffffffc0205c60 <commands+0xb30>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020146c:	6a85                	lui	s5,0x1
ffffffffc020146e:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201470:	c69fe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
ffffffffc0201474:	00014417          	auipc	s0,0x14
ffffffffc0201478:	0e440413          	addi	s0,s0,228 # ffffffffc0215558 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020147c:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0201480:	4004                	lw	s1,0(s0)
ffffffffc0201482:	2481                	sext.w	s1,s1
ffffffffc0201484:	2b249c63          	bne	s1,s2,ffffffffc020173c <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201488:	00005517          	auipc	a0,0x5
ffffffffc020148c:	80050513          	addi	a0,a0,-2048 # ffffffffc0205c88 <commands+0xb58>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201490:	6b91                	lui	s7,0x4
ffffffffc0201492:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201494:	c45fe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201498:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc020149c:	00042903          	lw	s2,0(s0)
ffffffffc02014a0:	2901                	sext.w	s2,s2
ffffffffc02014a2:	26991d63          	bne	s2,s1,ffffffffc020171c <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02014a6:	00005517          	auipc	a0,0x5
ffffffffc02014aa:	80a50513          	addi	a0,a0,-2038 # ffffffffc0205cb0 <commands+0xb80>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02014ae:	6c89                	lui	s9,0x2
ffffffffc02014b0:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02014b2:	c27fe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02014b6:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02014ba:	401c                	lw	a5,0(s0)
ffffffffc02014bc:	2781                	sext.w	a5,a5
ffffffffc02014be:	23279f63          	bne	a5,s2,ffffffffc02016fc <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02014c2:	00005517          	auipc	a0,0x5
ffffffffc02014c6:	81650513          	addi	a0,a0,-2026 # ffffffffc0205cd8 <commands+0xba8>
ffffffffc02014ca:	c0ffe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02014ce:	6795                	lui	a5,0x5
ffffffffc02014d0:	4739                	li	a4,14
ffffffffc02014d2:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02014d6:	4004                	lw	s1,0(s0)
ffffffffc02014d8:	4795                	li	a5,5
ffffffffc02014da:	2481                	sext.w	s1,s1
ffffffffc02014dc:	20f49063          	bne	s1,a5,ffffffffc02016dc <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02014e0:	00004517          	auipc	a0,0x4
ffffffffc02014e4:	7d050513          	addi	a0,a0,2000 # ffffffffc0205cb0 <commands+0xb80>
ffffffffc02014e8:	bf1fe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02014ec:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc02014f0:	401c                	lw	a5,0(s0)
ffffffffc02014f2:	2781                	sext.w	a5,a5
ffffffffc02014f4:	1c979463          	bne	a5,s1,ffffffffc02016bc <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02014f8:	00004517          	auipc	a0,0x4
ffffffffc02014fc:	76850513          	addi	a0,a0,1896 # ffffffffc0205c60 <commands+0xb30>
ffffffffc0201500:	bd9fe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201504:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0201508:	401c                	lw	a5,0(s0)
ffffffffc020150a:	4719                	li	a4,6
ffffffffc020150c:	2781                	sext.w	a5,a5
ffffffffc020150e:	18e79763          	bne	a5,a4,ffffffffc020169c <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201512:	00004517          	auipc	a0,0x4
ffffffffc0201516:	79e50513          	addi	a0,a0,1950 # ffffffffc0205cb0 <commands+0xb80>
ffffffffc020151a:	bbffe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020151e:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0201522:	401c                	lw	a5,0(s0)
ffffffffc0201524:	471d                	li	a4,7
ffffffffc0201526:	2781                	sext.w	a5,a5
ffffffffc0201528:	14e79a63          	bne	a5,a4,ffffffffc020167c <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020152c:	00004517          	auipc	a0,0x4
ffffffffc0201530:	6e450513          	addi	a0,a0,1764 # ffffffffc0205c10 <commands+0xae0>
ffffffffc0201534:	ba5fe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201538:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc020153c:	401c                	lw	a5,0(s0)
ffffffffc020153e:	4721                	li	a4,8
ffffffffc0201540:	2781                	sext.w	a5,a5
ffffffffc0201542:	10e79d63          	bne	a5,a4,ffffffffc020165c <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201546:	00004517          	auipc	a0,0x4
ffffffffc020154a:	74250513          	addi	a0,a0,1858 # ffffffffc0205c88 <commands+0xb58>
ffffffffc020154e:	b8bfe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201552:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0201556:	401c                	lw	a5,0(s0)
ffffffffc0201558:	4725                	li	a4,9
ffffffffc020155a:	2781                	sext.w	a5,a5
ffffffffc020155c:	0ee79063          	bne	a5,a4,ffffffffc020163c <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201560:	00004517          	auipc	a0,0x4
ffffffffc0201564:	77850513          	addi	a0,a0,1912 # ffffffffc0205cd8 <commands+0xba8>
ffffffffc0201568:	b71fe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020156c:	6795                	lui	a5,0x5
ffffffffc020156e:	4739                	li	a4,14
ffffffffc0201570:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0201574:	4004                	lw	s1,0(s0)
ffffffffc0201576:	47a9                	li	a5,10
ffffffffc0201578:	2481                	sext.w	s1,s1
ffffffffc020157a:	0af49163          	bne	s1,a5,ffffffffc020161c <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020157e:	00004517          	auipc	a0,0x4
ffffffffc0201582:	6e250513          	addi	a0,a0,1762 # ffffffffc0205c60 <commands+0xb30>
ffffffffc0201586:	b53fe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020158a:	6785                	lui	a5,0x1
ffffffffc020158c:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201590:	06979663          	bne	a5,s1,ffffffffc02015fc <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0201594:	401c                	lw	a5,0(s0)
ffffffffc0201596:	472d                	li	a4,11
ffffffffc0201598:	2781                	sext.w	a5,a5
ffffffffc020159a:	04e79163          	bne	a5,a4,ffffffffc02015dc <_fifo_check_swap+0x1b4>
}
ffffffffc020159e:	60e6                	ld	ra,88(sp)
ffffffffc02015a0:	6446                	ld	s0,80(sp)
ffffffffc02015a2:	64a6                	ld	s1,72(sp)
ffffffffc02015a4:	6906                	ld	s2,64(sp)
ffffffffc02015a6:	79e2                	ld	s3,56(sp)
ffffffffc02015a8:	7a42                	ld	s4,48(sp)
ffffffffc02015aa:	7aa2                	ld	s5,40(sp)
ffffffffc02015ac:	7b02                	ld	s6,32(sp)
ffffffffc02015ae:	6be2                	ld	s7,24(sp)
ffffffffc02015b0:	6c42                	ld	s8,16(sp)
ffffffffc02015b2:	6ca2                	ld	s9,8(sp)
ffffffffc02015b4:	6d02                	ld	s10,0(sp)
ffffffffc02015b6:	4501                	li	a0,0
ffffffffc02015b8:	6125                	addi	sp,sp,96
ffffffffc02015ba:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02015bc:	00004697          	auipc	a3,0x4
ffffffffc02015c0:	67c68693          	addi	a3,a3,1660 # ffffffffc0205c38 <commands+0xb08>
ffffffffc02015c4:	00004617          	auipc	a2,0x4
ffffffffc02015c8:	29460613          	addi	a2,a2,660 # ffffffffc0205858 <commands+0x728>
ffffffffc02015cc:	05100593          	li	a1,81
ffffffffc02015d0:	00004517          	auipc	a0,0x4
ffffffffc02015d4:	67850513          	addi	a0,a0,1656 # ffffffffc0205c48 <commands+0xb18>
ffffffffc02015d8:	bfdfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==11);
ffffffffc02015dc:	00004697          	auipc	a3,0x4
ffffffffc02015e0:	7ac68693          	addi	a3,a3,1964 # ffffffffc0205d88 <commands+0xc58>
ffffffffc02015e4:	00004617          	auipc	a2,0x4
ffffffffc02015e8:	27460613          	addi	a2,a2,628 # ffffffffc0205858 <commands+0x728>
ffffffffc02015ec:	07300593          	li	a1,115
ffffffffc02015f0:	00004517          	auipc	a0,0x4
ffffffffc02015f4:	65850513          	addi	a0,a0,1624 # ffffffffc0205c48 <commands+0xb18>
ffffffffc02015f8:	bddfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02015fc:	00004697          	auipc	a3,0x4
ffffffffc0201600:	76468693          	addi	a3,a3,1892 # ffffffffc0205d60 <commands+0xc30>
ffffffffc0201604:	00004617          	auipc	a2,0x4
ffffffffc0201608:	25460613          	addi	a2,a2,596 # ffffffffc0205858 <commands+0x728>
ffffffffc020160c:	07100593          	li	a1,113
ffffffffc0201610:	00004517          	auipc	a0,0x4
ffffffffc0201614:	63850513          	addi	a0,a0,1592 # ffffffffc0205c48 <commands+0xb18>
ffffffffc0201618:	bbdfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==10);
ffffffffc020161c:	00004697          	auipc	a3,0x4
ffffffffc0201620:	73468693          	addi	a3,a3,1844 # ffffffffc0205d50 <commands+0xc20>
ffffffffc0201624:	00004617          	auipc	a2,0x4
ffffffffc0201628:	23460613          	addi	a2,a2,564 # ffffffffc0205858 <commands+0x728>
ffffffffc020162c:	06f00593          	li	a1,111
ffffffffc0201630:	00004517          	auipc	a0,0x4
ffffffffc0201634:	61850513          	addi	a0,a0,1560 # ffffffffc0205c48 <commands+0xb18>
ffffffffc0201638:	b9dfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==9);
ffffffffc020163c:	00004697          	auipc	a3,0x4
ffffffffc0201640:	70468693          	addi	a3,a3,1796 # ffffffffc0205d40 <commands+0xc10>
ffffffffc0201644:	00004617          	auipc	a2,0x4
ffffffffc0201648:	21460613          	addi	a2,a2,532 # ffffffffc0205858 <commands+0x728>
ffffffffc020164c:	06c00593          	li	a1,108
ffffffffc0201650:	00004517          	auipc	a0,0x4
ffffffffc0201654:	5f850513          	addi	a0,a0,1528 # ffffffffc0205c48 <commands+0xb18>
ffffffffc0201658:	b7dfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==8);
ffffffffc020165c:	00004697          	auipc	a3,0x4
ffffffffc0201660:	6d468693          	addi	a3,a3,1748 # ffffffffc0205d30 <commands+0xc00>
ffffffffc0201664:	00004617          	auipc	a2,0x4
ffffffffc0201668:	1f460613          	addi	a2,a2,500 # ffffffffc0205858 <commands+0x728>
ffffffffc020166c:	06900593          	li	a1,105
ffffffffc0201670:	00004517          	auipc	a0,0x4
ffffffffc0201674:	5d850513          	addi	a0,a0,1496 # ffffffffc0205c48 <commands+0xb18>
ffffffffc0201678:	b5dfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==7);
ffffffffc020167c:	00004697          	auipc	a3,0x4
ffffffffc0201680:	6a468693          	addi	a3,a3,1700 # ffffffffc0205d20 <commands+0xbf0>
ffffffffc0201684:	00004617          	auipc	a2,0x4
ffffffffc0201688:	1d460613          	addi	a2,a2,468 # ffffffffc0205858 <commands+0x728>
ffffffffc020168c:	06600593          	li	a1,102
ffffffffc0201690:	00004517          	auipc	a0,0x4
ffffffffc0201694:	5b850513          	addi	a0,a0,1464 # ffffffffc0205c48 <commands+0xb18>
ffffffffc0201698:	b3dfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==6);
ffffffffc020169c:	00004697          	auipc	a3,0x4
ffffffffc02016a0:	67468693          	addi	a3,a3,1652 # ffffffffc0205d10 <commands+0xbe0>
ffffffffc02016a4:	00004617          	auipc	a2,0x4
ffffffffc02016a8:	1b460613          	addi	a2,a2,436 # ffffffffc0205858 <commands+0x728>
ffffffffc02016ac:	06300593          	li	a1,99
ffffffffc02016b0:	00004517          	auipc	a0,0x4
ffffffffc02016b4:	59850513          	addi	a0,a0,1432 # ffffffffc0205c48 <commands+0xb18>
ffffffffc02016b8:	b1dfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==5);
ffffffffc02016bc:	00004697          	auipc	a3,0x4
ffffffffc02016c0:	64468693          	addi	a3,a3,1604 # ffffffffc0205d00 <commands+0xbd0>
ffffffffc02016c4:	00004617          	auipc	a2,0x4
ffffffffc02016c8:	19460613          	addi	a2,a2,404 # ffffffffc0205858 <commands+0x728>
ffffffffc02016cc:	06000593          	li	a1,96
ffffffffc02016d0:	00004517          	auipc	a0,0x4
ffffffffc02016d4:	57850513          	addi	a0,a0,1400 # ffffffffc0205c48 <commands+0xb18>
ffffffffc02016d8:	afdfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==5);
ffffffffc02016dc:	00004697          	auipc	a3,0x4
ffffffffc02016e0:	62468693          	addi	a3,a3,1572 # ffffffffc0205d00 <commands+0xbd0>
ffffffffc02016e4:	00004617          	auipc	a2,0x4
ffffffffc02016e8:	17460613          	addi	a2,a2,372 # ffffffffc0205858 <commands+0x728>
ffffffffc02016ec:	05d00593          	li	a1,93
ffffffffc02016f0:	00004517          	auipc	a0,0x4
ffffffffc02016f4:	55850513          	addi	a0,a0,1368 # ffffffffc0205c48 <commands+0xb18>
ffffffffc02016f8:	addfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==4);
ffffffffc02016fc:	00004697          	auipc	a3,0x4
ffffffffc0201700:	53c68693          	addi	a3,a3,1340 # ffffffffc0205c38 <commands+0xb08>
ffffffffc0201704:	00004617          	auipc	a2,0x4
ffffffffc0201708:	15460613          	addi	a2,a2,340 # ffffffffc0205858 <commands+0x728>
ffffffffc020170c:	05a00593          	li	a1,90
ffffffffc0201710:	00004517          	auipc	a0,0x4
ffffffffc0201714:	53850513          	addi	a0,a0,1336 # ffffffffc0205c48 <commands+0xb18>
ffffffffc0201718:	abdfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==4);
ffffffffc020171c:	00004697          	auipc	a3,0x4
ffffffffc0201720:	51c68693          	addi	a3,a3,1308 # ffffffffc0205c38 <commands+0xb08>
ffffffffc0201724:	00004617          	auipc	a2,0x4
ffffffffc0201728:	13460613          	addi	a2,a2,308 # ffffffffc0205858 <commands+0x728>
ffffffffc020172c:	05700593          	li	a1,87
ffffffffc0201730:	00004517          	auipc	a0,0x4
ffffffffc0201734:	51850513          	addi	a0,a0,1304 # ffffffffc0205c48 <commands+0xb18>
ffffffffc0201738:	a9dfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==4);
ffffffffc020173c:	00004697          	auipc	a3,0x4
ffffffffc0201740:	4fc68693          	addi	a3,a3,1276 # ffffffffc0205c38 <commands+0xb08>
ffffffffc0201744:	00004617          	auipc	a2,0x4
ffffffffc0201748:	11460613          	addi	a2,a2,276 # ffffffffc0205858 <commands+0x728>
ffffffffc020174c:	05400593          	li	a1,84
ffffffffc0201750:	00004517          	auipc	a0,0x4
ffffffffc0201754:	4f850513          	addi	a0,a0,1272 # ffffffffc0205c48 <commands+0xb18>
ffffffffc0201758:	a7dfe0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc020175c <_fifo_swap_out_victim>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020175c:	751c                	ld	a5,40(a0)
{
ffffffffc020175e:	1141                	addi	sp,sp,-16
ffffffffc0201760:	e406                	sd	ra,8(sp)
    assert(head != NULL);
ffffffffc0201762:	cf91                	beqz	a5,ffffffffc020177e <_fifo_swap_out_victim+0x22>
    assert(in_tick==0);
ffffffffc0201764:	ee0d                	bnez	a2,ffffffffc020179e <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0201766:	679c                	ld	a5,8(a5)
}
ffffffffc0201768:	60a2                	ld	ra,8(sp)
ffffffffc020176a:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc020176c:	6394                	ld	a3,0(a5)
ffffffffc020176e:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0201770:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0201774:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0201776:	e314                	sd	a3,0(a4)
ffffffffc0201778:	e19c                	sd	a5,0(a1)
}
ffffffffc020177a:	0141                	addi	sp,sp,16
ffffffffc020177c:	8082                	ret
    assert(head != NULL);
ffffffffc020177e:	00004697          	auipc	a3,0x4
ffffffffc0201782:	61a68693          	addi	a3,a3,1562 # ffffffffc0205d98 <commands+0xc68>
ffffffffc0201786:	00004617          	auipc	a2,0x4
ffffffffc020178a:	0d260613          	addi	a2,a2,210 # ffffffffc0205858 <commands+0x728>
ffffffffc020178e:	04100593          	li	a1,65
ffffffffc0201792:	00004517          	auipc	a0,0x4
ffffffffc0201796:	4b650513          	addi	a0,a0,1206 # ffffffffc0205c48 <commands+0xb18>
ffffffffc020179a:	a3bfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(in_tick==0);
ffffffffc020179e:	00004697          	auipc	a3,0x4
ffffffffc02017a2:	60a68693          	addi	a3,a3,1546 # ffffffffc0205da8 <commands+0xc78>
ffffffffc02017a6:	00004617          	auipc	a2,0x4
ffffffffc02017aa:	0b260613          	addi	a2,a2,178 # ffffffffc0205858 <commands+0x728>
ffffffffc02017ae:	04200593          	li	a1,66
ffffffffc02017b2:	00004517          	auipc	a0,0x4
ffffffffc02017b6:	49650513          	addi	a0,a0,1174 # ffffffffc0205c48 <commands+0xb18>
ffffffffc02017ba:	a1bfe0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02017be <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02017be:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc02017c0:	cb91                	beqz	a5,ffffffffc02017d4 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02017c2:	6394                	ld	a3,0(a5)
ffffffffc02017c4:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc02017c8:	e398                	sd	a4,0(a5)
ffffffffc02017ca:	e698                	sd	a4,8(a3)
}
ffffffffc02017cc:	4501                	li	a0,0
    elm->next = next;
ffffffffc02017ce:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc02017d0:	f614                	sd	a3,40(a2)
ffffffffc02017d2:	8082                	ret
{
ffffffffc02017d4:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc02017d6:	00004697          	auipc	a3,0x4
ffffffffc02017da:	5e268693          	addi	a3,a3,1506 # ffffffffc0205db8 <commands+0xc88>
ffffffffc02017de:	00004617          	auipc	a2,0x4
ffffffffc02017e2:	07a60613          	addi	a2,a2,122 # ffffffffc0205858 <commands+0x728>
ffffffffc02017e6:	03200593          	li	a1,50
ffffffffc02017ea:	00004517          	auipc	a0,0x4
ffffffffc02017ee:	45e50513          	addi	a0,a0,1118 # ffffffffc0205c48 <commands+0xb18>
{
ffffffffc02017f2:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02017f4:	9e1fe0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02017f8 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02017f8:	c94d                	beqz	a0,ffffffffc02018aa <slob_free+0xb2>
{
ffffffffc02017fa:	1141                	addi	sp,sp,-16
ffffffffc02017fc:	e022                	sd	s0,0(sp)
ffffffffc02017fe:	e406                	sd	ra,8(sp)
ffffffffc0201800:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201802:	e9c1                	bnez	a1,ffffffffc0201892 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201804:	100027f3          	csrr	a5,sstatus
ffffffffc0201808:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020180a:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020180c:	ebd9                	bnez	a5,ffffffffc02018a2 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020180e:	00009617          	auipc	a2,0x9
ffffffffc0201812:	84260613          	addi	a2,a2,-1982 # ffffffffc020a050 <slobfree>
ffffffffc0201816:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201818:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020181a:	679c                	ld	a5,8(a5)
ffffffffc020181c:	02877a63          	bgeu	a4,s0,ffffffffc0201850 <slob_free+0x58>
ffffffffc0201820:	00f46463          	bltu	s0,a5,ffffffffc0201828 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201824:	fef76ae3          	bltu	a4,a5,ffffffffc0201818 <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201828:	400c                	lw	a1,0(s0)
ffffffffc020182a:	00459693          	slli	a3,a1,0x4
ffffffffc020182e:	96a2                	add	a3,a3,s0
ffffffffc0201830:	02d78a63          	beq	a5,a3,ffffffffc0201864 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201834:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201836:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201838:	00469793          	slli	a5,a3,0x4
ffffffffc020183c:	97ba                	add	a5,a5,a4
ffffffffc020183e:	02f40e63          	beq	s0,a5,ffffffffc020187a <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201842:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201844:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc0201846:	e129                	bnez	a0,ffffffffc0201888 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201848:	60a2                	ld	ra,8(sp)
ffffffffc020184a:	6402                	ld	s0,0(sp)
ffffffffc020184c:	0141                	addi	sp,sp,16
ffffffffc020184e:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201850:	fcf764e3          	bltu	a4,a5,ffffffffc0201818 <slob_free+0x20>
ffffffffc0201854:	fcf472e3          	bgeu	s0,a5,ffffffffc0201818 <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc0201858:	400c                	lw	a1,0(s0)
ffffffffc020185a:	00459693          	slli	a3,a1,0x4
ffffffffc020185e:	96a2                	add	a3,a3,s0
ffffffffc0201860:	fcd79ae3          	bne	a5,a3,ffffffffc0201834 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201864:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201866:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201868:	9db5                	addw	a1,a1,a3
ffffffffc020186a:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc020186c:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc020186e:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201870:	00469793          	slli	a5,a3,0x4
ffffffffc0201874:	97ba                	add	a5,a5,a4
ffffffffc0201876:	fcf416e3          	bne	s0,a5,ffffffffc0201842 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc020187a:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc020187c:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc020187e:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201880:	9ebd                	addw	a3,a3,a5
ffffffffc0201882:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201884:	e70c                	sd	a1,8(a4)
ffffffffc0201886:	d169                	beqz	a0,ffffffffc0201848 <slob_free+0x50>
}
ffffffffc0201888:	6402                	ld	s0,0(sp)
ffffffffc020188a:	60a2                	ld	ra,8(sp)
ffffffffc020188c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020188e:	d3dfe06f          	j	ffffffffc02005ca <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201892:	25bd                	addiw	a1,a1,15
ffffffffc0201894:	8191                	srli	a1,a1,0x4
ffffffffc0201896:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201898:	100027f3          	csrr	a5,sstatus
ffffffffc020189c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020189e:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018a0:	d7bd                	beqz	a5,ffffffffc020180e <slob_free+0x16>
        intr_disable();
ffffffffc02018a2:	d2ffe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        return 1;
ffffffffc02018a6:	4505                	li	a0,1
ffffffffc02018a8:	b79d                	j	ffffffffc020180e <slob_free+0x16>
ffffffffc02018aa:	8082                	ret

ffffffffc02018ac <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc02018ac:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02018ae:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc02018b0:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02018b4:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc02018b6:	6f8010ef          	jal	ra,ffffffffc0202fae <alloc_pages>
  if(!page)
ffffffffc02018ba:	c91d                	beqz	a0,ffffffffc02018f0 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc02018bc:	00014697          	auipc	a3,0x14
ffffffffc02018c0:	cdc6b683          	ld	a3,-804(a3) # ffffffffc0215598 <pages>
ffffffffc02018c4:	8d15                	sub	a0,a0,a3
ffffffffc02018c6:	8519                	srai	a0,a0,0x6
ffffffffc02018c8:	00005697          	auipc	a3,0x5
ffffffffc02018cc:	6c06b683          	ld	a3,1728(a3) # ffffffffc0206f88 <nbase>
ffffffffc02018d0:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc02018d2:	00c51793          	slli	a5,a0,0xc
ffffffffc02018d6:	83b1                	srli	a5,a5,0xc
ffffffffc02018d8:	00014717          	auipc	a4,0x14
ffffffffc02018dc:	cb873703          	ld	a4,-840(a4) # ffffffffc0215590 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc02018e0:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02018e2:	00e7fa63          	bgeu	a5,a4,ffffffffc02018f6 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02018e6:	00014697          	auipc	a3,0x14
ffffffffc02018ea:	cc26b683          	ld	a3,-830(a3) # ffffffffc02155a8 <va_pa_offset>
ffffffffc02018ee:	9536                	add	a0,a0,a3
}
ffffffffc02018f0:	60a2                	ld	ra,8(sp)
ffffffffc02018f2:	0141                	addi	sp,sp,16
ffffffffc02018f4:	8082                	ret
ffffffffc02018f6:	86aa                	mv	a3,a0
ffffffffc02018f8:	00004617          	auipc	a2,0x4
ffffffffc02018fc:	1b860613          	addi	a2,a2,440 # ffffffffc0205ab0 <commands+0x980>
ffffffffc0201900:	06900593          	li	a1,105
ffffffffc0201904:	00004517          	auipc	a0,0x4
ffffffffc0201908:	19c50513          	addi	a0,a0,412 # ffffffffc0205aa0 <commands+0x970>
ffffffffc020190c:	8c9fe0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0201910 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201910:	1101                	addi	sp,sp,-32
ffffffffc0201912:	ec06                	sd	ra,24(sp)
ffffffffc0201914:	e822                	sd	s0,16(sp)
ffffffffc0201916:	e426                	sd	s1,8(sp)
ffffffffc0201918:	e04a                	sd	s2,0(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc020191a:	01050713          	addi	a4,a0,16
ffffffffc020191e:	6785                	lui	a5,0x1
ffffffffc0201920:	0cf77363          	bgeu	a4,a5,ffffffffc02019e6 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201924:	00f50493          	addi	s1,a0,15
ffffffffc0201928:	8091                	srli	s1,s1,0x4
ffffffffc020192a:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020192c:	10002673          	csrr	a2,sstatus
ffffffffc0201930:	8a09                	andi	a2,a2,2
ffffffffc0201932:	e25d                	bnez	a2,ffffffffc02019d8 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201934:	00008917          	auipc	s2,0x8
ffffffffc0201938:	71c90913          	addi	s2,s2,1820 # ffffffffc020a050 <slobfree>
ffffffffc020193c:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201940:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201942:	4398                	lw	a4,0(a5)
ffffffffc0201944:	08975e63          	bge	a4,s1,ffffffffc02019e0 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0201948:	00d78b63          	beq	a5,a3,ffffffffc020195e <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020194c:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020194e:	4018                	lw	a4,0(s0)
ffffffffc0201950:	02975a63          	bge	a4,s1,ffffffffc0201984 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0201954:	00093683          	ld	a3,0(s2)
ffffffffc0201958:	87a2                	mv	a5,s0
ffffffffc020195a:	fed799e3          	bne	a5,a3,ffffffffc020194c <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc020195e:	ee31                	bnez	a2,ffffffffc02019ba <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201960:	4501                	li	a0,0
ffffffffc0201962:	f4bff0ef          	jal	ra,ffffffffc02018ac <__slob_get_free_pages.constprop.0>
ffffffffc0201966:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201968:	cd05                	beqz	a0,ffffffffc02019a0 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc020196a:	6585                	lui	a1,0x1
ffffffffc020196c:	e8dff0ef          	jal	ra,ffffffffc02017f8 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201970:	10002673          	csrr	a2,sstatus
ffffffffc0201974:	8a09                	andi	a2,a2,2
ffffffffc0201976:	ee05                	bnez	a2,ffffffffc02019ae <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201978:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020197c:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020197e:	4018                	lw	a4,0(s0)
ffffffffc0201980:	fc974ae3          	blt	a4,s1,ffffffffc0201954 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201984:	04e48763          	beq	s1,a4,ffffffffc02019d2 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201988:	00449693          	slli	a3,s1,0x4
ffffffffc020198c:	96a2                	add	a3,a3,s0
ffffffffc020198e:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201990:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201992:	9f05                	subw	a4,a4,s1
ffffffffc0201994:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201996:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201998:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc020199a:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc020199e:	e20d                	bnez	a2,ffffffffc02019c0 <slob_alloc.constprop.0+0xb0>
}
ffffffffc02019a0:	60e2                	ld	ra,24(sp)
ffffffffc02019a2:	8522                	mv	a0,s0
ffffffffc02019a4:	6442                	ld	s0,16(sp)
ffffffffc02019a6:	64a2                	ld	s1,8(sp)
ffffffffc02019a8:	6902                	ld	s2,0(sp)
ffffffffc02019aa:	6105                	addi	sp,sp,32
ffffffffc02019ac:	8082                	ret
        intr_disable();
ffffffffc02019ae:	c23fe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
			cur = slobfree;
ffffffffc02019b2:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc02019b6:	4605                	li	a2,1
ffffffffc02019b8:	b7d1                	j	ffffffffc020197c <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc02019ba:	c11fe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc02019be:	b74d                	j	ffffffffc0201960 <slob_alloc.constprop.0+0x50>
ffffffffc02019c0:	c0bfe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
}
ffffffffc02019c4:	60e2                	ld	ra,24(sp)
ffffffffc02019c6:	8522                	mv	a0,s0
ffffffffc02019c8:	6442                	ld	s0,16(sp)
ffffffffc02019ca:	64a2                	ld	s1,8(sp)
ffffffffc02019cc:	6902                	ld	s2,0(sp)
ffffffffc02019ce:	6105                	addi	sp,sp,32
ffffffffc02019d0:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc02019d2:	6418                	ld	a4,8(s0)
ffffffffc02019d4:	e798                	sd	a4,8(a5)
ffffffffc02019d6:	b7d1                	j	ffffffffc020199a <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc02019d8:	bf9fe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        return 1;
ffffffffc02019dc:	4605                	li	a2,1
ffffffffc02019de:	bf99                	j	ffffffffc0201934 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02019e0:	843e                	mv	s0,a5
ffffffffc02019e2:	87b6                	mv	a5,a3
ffffffffc02019e4:	b745                	j	ffffffffc0201984 <slob_alloc.constprop.0+0x74>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02019e6:	00004697          	auipc	a3,0x4
ffffffffc02019ea:	40a68693          	addi	a3,a3,1034 # ffffffffc0205df0 <commands+0xcc0>
ffffffffc02019ee:	00004617          	auipc	a2,0x4
ffffffffc02019f2:	e6a60613          	addi	a2,a2,-406 # ffffffffc0205858 <commands+0x728>
ffffffffc02019f6:	06300593          	li	a1,99
ffffffffc02019fa:	00004517          	auipc	a0,0x4
ffffffffc02019fe:	41650513          	addi	a0,a0,1046 # ffffffffc0205e10 <commands+0xce0>
ffffffffc0201a02:	fd2fe0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0201a06 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201a06:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201a08:	00004517          	auipc	a0,0x4
ffffffffc0201a0c:	42050513          	addi	a0,a0,1056 # ffffffffc0205e28 <commands+0xcf8>
kmalloc_init(void) {
ffffffffc0201a10:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201a12:	ec6fe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201a16:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201a18:	00004517          	auipc	a0,0x4
ffffffffc0201a1c:	42850513          	addi	a0,a0,1064 # ffffffffc0205e40 <commands+0xd10>
}
ffffffffc0201a20:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201a22:	eb6fe06f          	j	ffffffffc02000d8 <cprintf>

ffffffffc0201a26 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201a26:	1101                	addi	sp,sp,-32
ffffffffc0201a28:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201a2a:	6905                	lui	s2,0x1
{
ffffffffc0201a2c:	e822                	sd	s0,16(sp)
ffffffffc0201a2e:	ec06                	sd	ra,24(sp)
ffffffffc0201a30:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201a32:	fef90793          	addi	a5,s2,-17 # fef <kern_entry-0xffffffffc01ff011>
{
ffffffffc0201a36:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201a38:	04a7f963          	bgeu	a5,a0,ffffffffc0201a8a <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201a3c:	4561                	li	a0,24
ffffffffc0201a3e:	ed3ff0ef          	jal	ra,ffffffffc0201910 <slob_alloc.constprop.0>
ffffffffc0201a42:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201a44:	c929                	beqz	a0,ffffffffc0201a96 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201a46:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201a4a:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201a4c:	00f95763          	bge	s2,a5,ffffffffc0201a5a <kmalloc+0x34>
ffffffffc0201a50:	6705                	lui	a4,0x1
ffffffffc0201a52:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201a54:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201a56:	fef74ee3          	blt	a4,a5,ffffffffc0201a52 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201a5a:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201a5c:	e51ff0ef          	jal	ra,ffffffffc02018ac <__slob_get_free_pages.constprop.0>
ffffffffc0201a60:	e488                	sd	a0,8(s1)
ffffffffc0201a62:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201a64:	c525                	beqz	a0,ffffffffc0201acc <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a66:	100027f3          	csrr	a5,sstatus
ffffffffc0201a6a:	8b89                	andi	a5,a5,2
ffffffffc0201a6c:	ef8d                	bnez	a5,ffffffffc0201aa6 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201a6e:	00014797          	auipc	a5,0x14
ffffffffc0201a72:	af278793          	addi	a5,a5,-1294 # ffffffffc0215560 <bigblocks>
ffffffffc0201a76:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201a78:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201a7a:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201a7c:	60e2                	ld	ra,24(sp)
ffffffffc0201a7e:	8522                	mv	a0,s0
ffffffffc0201a80:	6442                	ld	s0,16(sp)
ffffffffc0201a82:	64a2                	ld	s1,8(sp)
ffffffffc0201a84:	6902                	ld	s2,0(sp)
ffffffffc0201a86:	6105                	addi	sp,sp,32
ffffffffc0201a88:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201a8a:	0541                	addi	a0,a0,16
ffffffffc0201a8c:	e85ff0ef          	jal	ra,ffffffffc0201910 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201a90:	01050413          	addi	s0,a0,16
ffffffffc0201a94:	f565                	bnez	a0,ffffffffc0201a7c <kmalloc+0x56>
ffffffffc0201a96:	4401                	li	s0,0
}
ffffffffc0201a98:	60e2                	ld	ra,24(sp)
ffffffffc0201a9a:	8522                	mv	a0,s0
ffffffffc0201a9c:	6442                	ld	s0,16(sp)
ffffffffc0201a9e:	64a2                	ld	s1,8(sp)
ffffffffc0201aa0:	6902                	ld	s2,0(sp)
ffffffffc0201aa2:	6105                	addi	sp,sp,32
ffffffffc0201aa4:	8082                	ret
        intr_disable();
ffffffffc0201aa6:	b2bfe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201aaa:	00014797          	auipc	a5,0x14
ffffffffc0201aae:	ab678793          	addi	a5,a5,-1354 # ffffffffc0215560 <bigblocks>
ffffffffc0201ab2:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201ab4:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201ab6:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201ab8:	b13fe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
		return bb->pages;
ffffffffc0201abc:	6480                	ld	s0,8(s1)
}
ffffffffc0201abe:	60e2                	ld	ra,24(sp)
ffffffffc0201ac0:	64a2                	ld	s1,8(sp)
ffffffffc0201ac2:	8522                	mv	a0,s0
ffffffffc0201ac4:	6442                	ld	s0,16(sp)
ffffffffc0201ac6:	6902                	ld	s2,0(sp)
ffffffffc0201ac8:	6105                	addi	sp,sp,32
ffffffffc0201aca:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201acc:	45e1                	li	a1,24
ffffffffc0201ace:	8526                	mv	a0,s1
ffffffffc0201ad0:	d29ff0ef          	jal	ra,ffffffffc02017f8 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201ad4:	b765                	j	ffffffffc0201a7c <kmalloc+0x56>

ffffffffc0201ad6 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201ad6:	c169                	beqz	a0,ffffffffc0201b98 <kfree+0xc2>
{
ffffffffc0201ad8:	1101                	addi	sp,sp,-32
ffffffffc0201ada:	e822                	sd	s0,16(sp)
ffffffffc0201adc:	ec06                	sd	ra,24(sp)
ffffffffc0201ade:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201ae0:	03451793          	slli	a5,a0,0x34
ffffffffc0201ae4:	842a                	mv	s0,a0
ffffffffc0201ae6:	e3d9                	bnez	a5,ffffffffc0201b6c <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ae8:	100027f3          	csrr	a5,sstatus
ffffffffc0201aec:	8b89                	andi	a5,a5,2
ffffffffc0201aee:	e7d9                	bnez	a5,ffffffffc0201b7c <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201af0:	00014797          	auipc	a5,0x14
ffffffffc0201af4:	a707b783          	ld	a5,-1424(a5) # ffffffffc0215560 <bigblocks>
    return 0;
ffffffffc0201af8:	4601                	li	a2,0
ffffffffc0201afa:	cbad                	beqz	a5,ffffffffc0201b6c <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201afc:	00014697          	auipc	a3,0x14
ffffffffc0201b00:	a6468693          	addi	a3,a3,-1436 # ffffffffc0215560 <bigblocks>
ffffffffc0201b04:	a021                	j	ffffffffc0201b0c <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201b06:	01048693          	addi	a3,s1,16
ffffffffc0201b0a:	c3a5                	beqz	a5,ffffffffc0201b6a <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201b0c:	6798                	ld	a4,8(a5)
ffffffffc0201b0e:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0201b10:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0201b12:	fe871ae3          	bne	a4,s0,ffffffffc0201b06 <kfree+0x30>
				*last = bb->next;
ffffffffc0201b16:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201b18:	ee2d                	bnez	a2,ffffffffc0201b92 <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201b1a:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201b1e:	4098                	lw	a4,0(s1)
ffffffffc0201b20:	08f46963          	bltu	s0,a5,ffffffffc0201bb2 <kfree+0xdc>
ffffffffc0201b24:	00014697          	auipc	a3,0x14
ffffffffc0201b28:	a846b683          	ld	a3,-1404(a3) # ffffffffc02155a8 <va_pa_offset>
ffffffffc0201b2c:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201b2e:	8031                	srli	s0,s0,0xc
ffffffffc0201b30:	00014797          	auipc	a5,0x14
ffffffffc0201b34:	a607b783          	ld	a5,-1440(a5) # ffffffffc0215590 <npage>
ffffffffc0201b38:	06f47163          	bgeu	s0,a5,ffffffffc0201b9a <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b3c:	00005517          	auipc	a0,0x5
ffffffffc0201b40:	44c53503          	ld	a0,1100(a0) # ffffffffc0206f88 <nbase>
ffffffffc0201b44:	8c09                	sub	s0,s0,a0
ffffffffc0201b46:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201b48:	00014517          	auipc	a0,0x14
ffffffffc0201b4c:	a5053503          	ld	a0,-1456(a0) # ffffffffc0215598 <pages>
ffffffffc0201b50:	4585                	li	a1,1
ffffffffc0201b52:	9522                	add	a0,a0,s0
ffffffffc0201b54:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201b58:	4e8010ef          	jal	ra,ffffffffc0203040 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201b5c:	6442                	ld	s0,16(sp)
ffffffffc0201b5e:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b60:	8526                	mv	a0,s1
}
ffffffffc0201b62:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b64:	45e1                	li	a1,24
}
ffffffffc0201b66:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b68:	b941                	j	ffffffffc02017f8 <slob_free>
ffffffffc0201b6a:	e20d                	bnez	a2,ffffffffc0201b8c <kfree+0xb6>
ffffffffc0201b6c:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201b70:	6442                	ld	s0,16(sp)
ffffffffc0201b72:	60e2                	ld	ra,24(sp)
ffffffffc0201b74:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b76:	4581                	li	a1,0
}
ffffffffc0201b78:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b7a:	b9bd                	j	ffffffffc02017f8 <slob_free>
        intr_disable();
ffffffffc0201b7c:	a55fe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201b80:	00014797          	auipc	a5,0x14
ffffffffc0201b84:	9e07b783          	ld	a5,-1568(a5) # ffffffffc0215560 <bigblocks>
        return 1;
ffffffffc0201b88:	4605                	li	a2,1
ffffffffc0201b8a:	fbad                	bnez	a5,ffffffffc0201afc <kfree+0x26>
        intr_enable();
ffffffffc0201b8c:	a3ffe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0201b90:	bff1                	j	ffffffffc0201b6c <kfree+0x96>
ffffffffc0201b92:	a39fe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0201b96:	b751                	j	ffffffffc0201b1a <kfree+0x44>
ffffffffc0201b98:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201b9a:	00004617          	auipc	a2,0x4
ffffffffc0201b9e:	ee660613          	addi	a2,a2,-282 # ffffffffc0205a80 <commands+0x950>
ffffffffc0201ba2:	06200593          	li	a1,98
ffffffffc0201ba6:	00004517          	auipc	a0,0x4
ffffffffc0201baa:	efa50513          	addi	a0,a0,-262 # ffffffffc0205aa0 <commands+0x970>
ffffffffc0201bae:	e26fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201bb2:	86a2                	mv	a3,s0
ffffffffc0201bb4:	00004617          	auipc	a2,0x4
ffffffffc0201bb8:	2ac60613          	addi	a2,a2,684 # ffffffffc0205e60 <commands+0xd30>
ffffffffc0201bbc:	06e00593          	li	a1,110
ffffffffc0201bc0:	00004517          	auipc	a0,0x4
ffffffffc0201bc4:	ee050513          	addi	a0,a0,-288 # ffffffffc0205aa0 <commands+0x970>
ffffffffc0201bc8:	e0cfe0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0201bcc <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0201bcc:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201bce:	00004617          	auipc	a2,0x4
ffffffffc0201bd2:	eb260613          	addi	a2,a2,-334 # ffffffffc0205a80 <commands+0x950>
ffffffffc0201bd6:	06200593          	li	a1,98
ffffffffc0201bda:	00004517          	auipc	a0,0x4
ffffffffc0201bde:	ec650513          	addi	a0,a0,-314 # ffffffffc0205aa0 <commands+0x970>
pa2page(uintptr_t pa) {
ffffffffc0201be2:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201be4:	df0fe0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0201be8 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0201be8:	7135                	addi	sp,sp,-160
ffffffffc0201bea:	ed06                	sd	ra,152(sp)
ffffffffc0201bec:	e922                	sd	s0,144(sp)
ffffffffc0201bee:	e526                	sd	s1,136(sp)
ffffffffc0201bf0:	e14a                	sd	s2,128(sp)
ffffffffc0201bf2:	fcce                	sd	s3,120(sp)
ffffffffc0201bf4:	f8d2                	sd	s4,112(sp)
ffffffffc0201bf6:	f4d6                	sd	s5,104(sp)
ffffffffc0201bf8:	f0da                	sd	s6,96(sp)
ffffffffc0201bfa:	ecde                	sd	s7,88(sp)
ffffffffc0201bfc:	e8e2                	sd	s8,80(sp)
ffffffffc0201bfe:	e4e6                	sd	s9,72(sp)
ffffffffc0201c00:	e0ea                	sd	s10,64(sp)
ffffffffc0201c02:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0201c04:	4c6020ef          	jal	ra,ffffffffc02040ca <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0201c08:	00014697          	auipc	a3,0x14
ffffffffc0201c0c:	9606b683          	ld	a3,-1696(a3) # ffffffffc0215568 <max_swap_offset>
ffffffffc0201c10:	010007b7          	lui	a5,0x1000
ffffffffc0201c14:	ff968713          	addi	a4,a3,-7
ffffffffc0201c18:	17e1                	addi	a5,a5,-8
ffffffffc0201c1a:	42e7e063          	bltu	a5,a4,ffffffffc020203a <swap_init+0x452>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0201c1e:	00008797          	auipc	a5,0x8
ffffffffc0201c22:	3e278793          	addi	a5,a5,994 # ffffffffc020a000 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0201c26:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0201c28:	00014b97          	auipc	s7,0x14
ffffffffc0201c2c:	948b8b93          	addi	s7,s7,-1720 # ffffffffc0215570 <sm>
ffffffffc0201c30:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc0201c34:	9702                	jalr	a4
ffffffffc0201c36:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc0201c38:	c10d                	beqz	a0,ffffffffc0201c5a <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0201c3a:	60ea                	ld	ra,152(sp)
ffffffffc0201c3c:	644a                	ld	s0,144(sp)
ffffffffc0201c3e:	64aa                	ld	s1,136(sp)
ffffffffc0201c40:	79e6                	ld	s3,120(sp)
ffffffffc0201c42:	7a46                	ld	s4,112(sp)
ffffffffc0201c44:	7aa6                	ld	s5,104(sp)
ffffffffc0201c46:	7b06                	ld	s6,96(sp)
ffffffffc0201c48:	6be6                	ld	s7,88(sp)
ffffffffc0201c4a:	6c46                	ld	s8,80(sp)
ffffffffc0201c4c:	6ca6                	ld	s9,72(sp)
ffffffffc0201c4e:	6d06                	ld	s10,64(sp)
ffffffffc0201c50:	7de2                	ld	s11,56(sp)
ffffffffc0201c52:	854a                	mv	a0,s2
ffffffffc0201c54:	690a                	ld	s2,128(sp)
ffffffffc0201c56:	610d                	addi	sp,sp,160
ffffffffc0201c58:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201c5a:	000bb783          	ld	a5,0(s7)
ffffffffc0201c5e:	00004517          	auipc	a0,0x4
ffffffffc0201c62:	25a50513          	addi	a0,a0,602 # ffffffffc0205eb8 <commands+0xd88>
    return listelm->next;
ffffffffc0201c66:	00010417          	auipc	s0,0x10
ffffffffc0201c6a:	89a40413          	addi	s0,s0,-1894 # ffffffffc0211500 <free_area>
ffffffffc0201c6e:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0201c70:	4785                	li	a5,1
ffffffffc0201c72:	00014717          	auipc	a4,0x14
ffffffffc0201c76:	90f72323          	sw	a5,-1786(a4) # ffffffffc0215578 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201c7a:	c5efe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
ffffffffc0201c7e:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0201c80:	4d01                	li	s10,0
ffffffffc0201c82:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201c84:	32878b63          	beq	a5,s0,ffffffffc0201fba <swap_init+0x3d2>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201c88:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201c8c:	8b09                	andi	a4,a4,2
ffffffffc0201c8e:	32070863          	beqz	a4,ffffffffc0201fbe <swap_init+0x3d6>
        count ++, total += p->property;
ffffffffc0201c92:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201c96:	679c                	ld	a5,8(a5)
ffffffffc0201c98:	2d85                	addiw	s11,s11,1
ffffffffc0201c9a:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201c9e:	fe8795e3          	bne	a5,s0,ffffffffc0201c88 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0201ca2:	84ea                	mv	s1,s10
ffffffffc0201ca4:	3dc010ef          	jal	ra,ffffffffc0203080 <nr_free_pages>
ffffffffc0201ca8:	42951163          	bne	a0,s1,ffffffffc02020ca <swap_init+0x4e2>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0201cac:	866a                	mv	a2,s10
ffffffffc0201cae:	85ee                	mv	a1,s11
ffffffffc0201cb0:	00004517          	auipc	a0,0x4
ffffffffc0201cb4:	25050513          	addi	a0,a0,592 # ffffffffc0205f00 <commands+0xdd0>
ffffffffc0201cb8:	c20fe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0201cbc:	ee7fe0ef          	jal	ra,ffffffffc0200ba2 <mm_create>
ffffffffc0201cc0:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0201cc2:	46050463          	beqz	a0,ffffffffc020212a <swap_init+0x542>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0201cc6:	00014797          	auipc	a5,0x14
ffffffffc0201cca:	88a78793          	addi	a5,a5,-1910 # ffffffffc0215550 <check_mm_struct>
ffffffffc0201cce:	6398                	ld	a4,0(a5)
ffffffffc0201cd0:	3c071d63          	bnez	a4,ffffffffc02020aa <swap_init+0x4c2>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201cd4:	00014717          	auipc	a4,0x14
ffffffffc0201cd8:	8b470713          	addi	a4,a4,-1868 # ffffffffc0215588 <boot_pgdir>
ffffffffc0201cdc:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc0201ce0:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0201ce2:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201ce6:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0201cea:	42079063          	bnez	a5,ffffffffc020210a <swap_init+0x522>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0201cee:	6599                	lui	a1,0x6
ffffffffc0201cf0:	460d                	li	a2,3
ffffffffc0201cf2:	6505                	lui	a0,0x1
ffffffffc0201cf4:	ef7fe0ef          	jal	ra,ffffffffc0200bea <vma_create>
ffffffffc0201cf8:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0201cfa:	52050463          	beqz	a0,ffffffffc0202222 <swap_init+0x63a>

     insert_vma_struct(mm, vma);
ffffffffc0201cfe:	8556                	mv	a0,s5
ffffffffc0201d00:	f59fe0ef          	jal	ra,ffffffffc0200c58 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0201d04:	00004517          	auipc	a0,0x4
ffffffffc0201d08:	23c50513          	addi	a0,a0,572 # ffffffffc0205f40 <commands+0xe10>
ffffffffc0201d0c:	bccfe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0201d10:	018ab503          	ld	a0,24(s5)
ffffffffc0201d14:	4605                	li	a2,1
ffffffffc0201d16:	6585                	lui	a1,0x1
ffffffffc0201d18:	3a2010ef          	jal	ra,ffffffffc02030ba <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0201d1c:	4c050363          	beqz	a0,ffffffffc02021e2 <swap_init+0x5fa>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201d20:	00004517          	auipc	a0,0x4
ffffffffc0201d24:	27050513          	addi	a0,a0,624 # ffffffffc0205f90 <commands+0xe60>
ffffffffc0201d28:	0000f497          	auipc	s1,0xf
ffffffffc0201d2c:	76848493          	addi	s1,s1,1896 # ffffffffc0211490 <check_rp>
ffffffffc0201d30:	ba8fe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201d34:	0000f997          	auipc	s3,0xf
ffffffffc0201d38:	77c98993          	addi	s3,s3,1916 # ffffffffc02114b0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201d3c:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0201d3e:	4505                	li	a0,1
ffffffffc0201d40:	26e010ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc0201d44:	00aa3023          	sd	a0,0(s4)
          assert(check_rp[i] != NULL );
ffffffffc0201d48:	2c050963          	beqz	a0,ffffffffc020201a <swap_init+0x432>
ffffffffc0201d4c:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0201d4e:	8b89                	andi	a5,a5,2
ffffffffc0201d50:	32079d63          	bnez	a5,ffffffffc020208a <swap_init+0x4a2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201d54:	0a21                	addi	s4,s4,8
ffffffffc0201d56:	ff3a14e3          	bne	s4,s3,ffffffffc0201d3e <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0201d5a:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0201d5c:	0000fa17          	auipc	s4,0xf
ffffffffc0201d60:	734a0a13          	addi	s4,s4,1844 # ffffffffc0211490 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc0201d64:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc0201d66:	ec3e                	sd	a5,24(sp)
ffffffffc0201d68:	641c                	ld	a5,8(s0)
ffffffffc0201d6a:	e400                	sd	s0,8(s0)
ffffffffc0201d6c:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0201d6e:	481c                	lw	a5,16(s0)
ffffffffc0201d70:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0201d72:	0000f797          	auipc	a5,0xf
ffffffffc0201d76:	7807af23          	sw	zero,1950(a5) # ffffffffc0211510 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0201d7a:	000a3503          	ld	a0,0(s4)
ffffffffc0201d7e:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201d80:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0201d82:	2be010ef          	jal	ra,ffffffffc0203040 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201d86:	ff3a1ae3          	bne	s4,s3,ffffffffc0201d7a <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201d8a:	01042a03          	lw	s4,16(s0)
ffffffffc0201d8e:	4791                	li	a5,4
ffffffffc0201d90:	42fa1963          	bne	s4,a5,ffffffffc02021c2 <swap_init+0x5da>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0201d94:	00004517          	auipc	a0,0x4
ffffffffc0201d98:	28450513          	addi	a0,a0,644 # ffffffffc0206018 <commands+0xee8>
ffffffffc0201d9c:	b3cfe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201da0:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0201da2:	00013797          	auipc	a5,0x13
ffffffffc0201da6:	7a07ab23          	sw	zero,1974(a5) # ffffffffc0215558 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201daa:	4629                	li	a2,10
ffffffffc0201dac:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0201db0:	00013697          	auipc	a3,0x13
ffffffffc0201db4:	7a86a683          	lw	a3,1960(a3) # ffffffffc0215558 <pgfault_num>
ffffffffc0201db8:	4585                	li	a1,1
ffffffffc0201dba:	00013797          	auipc	a5,0x13
ffffffffc0201dbe:	79e78793          	addi	a5,a5,1950 # ffffffffc0215558 <pgfault_num>
ffffffffc0201dc2:	54b69063          	bne	a3,a1,ffffffffc0202302 <swap_init+0x71a>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0201dc6:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0201dca:	4398                	lw	a4,0(a5)
ffffffffc0201dcc:	2701                	sext.w	a4,a4
ffffffffc0201dce:	3cd71a63          	bne	a4,a3,ffffffffc02021a2 <swap_init+0x5ba>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201dd2:	6689                	lui	a3,0x2
ffffffffc0201dd4:	462d                	li	a2,11
ffffffffc0201dd6:	00c68023          	sb	a2,0(a3) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0201dda:	4398                	lw	a4,0(a5)
ffffffffc0201ddc:	4589                	li	a1,2
ffffffffc0201dde:	2701                	sext.w	a4,a4
ffffffffc0201de0:	4ab71163          	bne	a4,a1,ffffffffc0202282 <swap_init+0x69a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0201de4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0201de8:	4394                	lw	a3,0(a5)
ffffffffc0201dea:	2681                	sext.w	a3,a3
ffffffffc0201dec:	4ae69b63          	bne	a3,a4,ffffffffc02022a2 <swap_init+0x6ba>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201df0:	668d                	lui	a3,0x3
ffffffffc0201df2:	4631                	li	a2,12
ffffffffc0201df4:	00c68023          	sb	a2,0(a3) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0201df8:	4398                	lw	a4,0(a5)
ffffffffc0201dfa:	458d                	li	a1,3
ffffffffc0201dfc:	2701                	sext.w	a4,a4
ffffffffc0201dfe:	4cb71263          	bne	a4,a1,ffffffffc02022c2 <swap_init+0x6da>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0201e02:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0201e06:	4394                	lw	a3,0(a5)
ffffffffc0201e08:	2681                	sext.w	a3,a3
ffffffffc0201e0a:	4ce69c63          	bne	a3,a4,ffffffffc02022e2 <swap_init+0x6fa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201e0e:	6691                	lui	a3,0x4
ffffffffc0201e10:	4635                	li	a2,13
ffffffffc0201e12:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0201e16:	4398                	lw	a4,0(a5)
ffffffffc0201e18:	2701                	sext.w	a4,a4
ffffffffc0201e1a:	43471463          	bne	a4,s4,ffffffffc0202242 <swap_init+0x65a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0201e1e:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0201e22:	439c                	lw	a5,0(a5)
ffffffffc0201e24:	2781                	sext.w	a5,a5
ffffffffc0201e26:	42e79e63          	bne	a5,a4,ffffffffc0202262 <swap_init+0x67a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0201e2a:	481c                	lw	a5,16(s0)
ffffffffc0201e2c:	2a079f63          	bnez	a5,ffffffffc02020ea <swap_init+0x502>
ffffffffc0201e30:	0000f797          	auipc	a5,0xf
ffffffffc0201e34:	68078793          	addi	a5,a5,1664 # ffffffffc02114b0 <swap_in_seq_no>
ffffffffc0201e38:	0000f717          	auipc	a4,0xf
ffffffffc0201e3c:	6a070713          	addi	a4,a4,1696 # ffffffffc02114d8 <swap_out_seq_no>
ffffffffc0201e40:	0000f617          	auipc	a2,0xf
ffffffffc0201e44:	69860613          	addi	a2,a2,1688 # ffffffffc02114d8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0201e48:	56fd                	li	a3,-1
ffffffffc0201e4a:	c394                	sw	a3,0(a5)
ffffffffc0201e4c:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201e4e:	0791                	addi	a5,a5,4
ffffffffc0201e50:	0711                	addi	a4,a4,4
ffffffffc0201e52:	fec79ce3          	bne	a5,a2,ffffffffc0201e4a <swap_init+0x262>
ffffffffc0201e56:	0000f717          	auipc	a4,0xf
ffffffffc0201e5a:	61a70713          	addi	a4,a4,1562 # ffffffffc0211470 <check_ptep>
ffffffffc0201e5e:	0000f697          	auipc	a3,0xf
ffffffffc0201e62:	63268693          	addi	a3,a3,1586 # ffffffffc0211490 <check_rp>
ffffffffc0201e66:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0201e68:	00013c17          	auipc	s8,0x13
ffffffffc0201e6c:	728c0c13          	addi	s8,s8,1832 # ffffffffc0215590 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e70:	00013c97          	auipc	s9,0x13
ffffffffc0201e74:	728c8c93          	addi	s9,s9,1832 # ffffffffc0215598 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0201e78:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201e7c:	4601                	li	a2,0
ffffffffc0201e7e:	855a                	mv	a0,s6
ffffffffc0201e80:	e836                	sd	a3,16(sp)
ffffffffc0201e82:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0201e84:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201e86:	234010ef          	jal	ra,ffffffffc02030ba <get_pte>
ffffffffc0201e8a:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0201e8c:	65a2                	ld	a1,8(sp)
ffffffffc0201e8e:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201e90:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0201e92:	1c050063          	beqz	a0,ffffffffc0202052 <swap_init+0x46a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201e96:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201e98:	0017f613          	andi	a2,a5,1
ffffffffc0201e9c:	1c060b63          	beqz	a2,ffffffffc0202072 <swap_init+0x48a>
    if (PPN(pa) >= npage) {
ffffffffc0201ea0:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ea4:	078a                	slli	a5,a5,0x2
ffffffffc0201ea6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ea8:	12c7fd63          	bgeu	a5,a2,ffffffffc0201fe2 <swap_init+0x3fa>
    return &pages[PPN(pa) - nbase];
ffffffffc0201eac:	00005617          	auipc	a2,0x5
ffffffffc0201eb0:	0dc60613          	addi	a2,a2,220 # ffffffffc0206f88 <nbase>
ffffffffc0201eb4:	00063a03          	ld	s4,0(a2)
ffffffffc0201eb8:	000cb603          	ld	a2,0(s9)
ffffffffc0201ebc:	6288                	ld	a0,0(a3)
ffffffffc0201ebe:	414787b3          	sub	a5,a5,s4
ffffffffc0201ec2:	079a                	slli	a5,a5,0x6
ffffffffc0201ec4:	97b2                	add	a5,a5,a2
ffffffffc0201ec6:	12f51a63          	bne	a0,a5,ffffffffc0201ffa <swap_init+0x412>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201eca:	6785                	lui	a5,0x1
ffffffffc0201ecc:	95be                	add	a1,a1,a5
ffffffffc0201ece:	6795                	lui	a5,0x5
ffffffffc0201ed0:	0721                	addi	a4,a4,8
ffffffffc0201ed2:	06a1                	addi	a3,a3,8
ffffffffc0201ed4:	faf592e3          	bne	a1,a5,ffffffffc0201e78 <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0201ed8:	00004517          	auipc	a0,0x4
ffffffffc0201edc:	21050513          	addi	a0,a0,528 # ffffffffc02060e8 <commands+0xfb8>
ffffffffc0201ee0:	9f8fe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    int ret = sm->check_swap();
ffffffffc0201ee4:	000bb783          	ld	a5,0(s7)
ffffffffc0201ee8:	7f9c                	ld	a5,56(a5)
ffffffffc0201eea:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0201eec:	30051b63          	bnez	a0,ffffffffc0202202 <swap_init+0x61a>

     nr_free = nr_free_store;
ffffffffc0201ef0:	77a2                	ld	a5,40(sp)
ffffffffc0201ef2:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0201ef4:	67e2                	ld	a5,24(sp)
ffffffffc0201ef6:	e01c                	sd	a5,0(s0)
ffffffffc0201ef8:	7782                	ld	a5,32(sp)
ffffffffc0201efa:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0201efc:	6088                	ld	a0,0(s1)
ffffffffc0201efe:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201f00:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0201f02:	13e010ef          	jal	ra,ffffffffc0203040 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201f06:	ff349be3          	bne	s1,s3,ffffffffc0201efc <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0201f0a:	8556                	mv	a0,s5
ffffffffc0201f0c:	e1dfe0ef          	jal	ra,ffffffffc0200d28 <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201f10:	00013797          	auipc	a5,0x13
ffffffffc0201f14:	67878793          	addi	a5,a5,1656 # ffffffffc0215588 <boot_pgdir>
ffffffffc0201f18:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201f1a:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f1e:	639c                	ld	a5,0(a5)
ffffffffc0201f20:	078a                	slli	a5,a5,0x2
ffffffffc0201f22:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f24:	0ae7fd63          	bgeu	a5,a4,ffffffffc0201fde <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f28:	414786b3          	sub	a3,a5,s4
ffffffffc0201f2c:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0201f2e:	8699                	srai	a3,a3,0x6
ffffffffc0201f30:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0201f32:	00c69793          	slli	a5,a3,0xc
ffffffffc0201f36:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0201f38:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f3c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201f3e:	22e7f663          	bgeu	a5,a4,ffffffffc020216a <swap_init+0x582>
     free_page(pde2page(pd0[0]));
ffffffffc0201f42:	00013797          	auipc	a5,0x13
ffffffffc0201f46:	6667b783          	ld	a5,1638(a5) # ffffffffc02155a8 <va_pa_offset>
ffffffffc0201f4a:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f4c:	629c                	ld	a5,0(a3)
ffffffffc0201f4e:	078a                	slli	a5,a5,0x2
ffffffffc0201f50:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f52:	08e7f663          	bgeu	a5,a4,ffffffffc0201fde <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f56:	414787b3          	sub	a5,a5,s4
ffffffffc0201f5a:	079a                	slli	a5,a5,0x6
ffffffffc0201f5c:	953e                	add	a0,a0,a5
ffffffffc0201f5e:	4585                	li	a1,1
ffffffffc0201f60:	0e0010ef          	jal	ra,ffffffffc0203040 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f64:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201f68:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f6c:	078a                	slli	a5,a5,0x2
ffffffffc0201f6e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f70:	06e7f763          	bgeu	a5,a4,ffffffffc0201fde <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f74:	000cb503          	ld	a0,0(s9)
ffffffffc0201f78:	414787b3          	sub	a5,a5,s4
ffffffffc0201f7c:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0201f7e:	4585                	li	a1,1
ffffffffc0201f80:	953e                	add	a0,a0,a5
ffffffffc0201f82:	0be010ef          	jal	ra,ffffffffc0203040 <free_pages>
     pgdir[0] = 0;
ffffffffc0201f86:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0201f8a:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0201f8e:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201f90:	00878a63          	beq	a5,s0,ffffffffc0201fa4 <swap_init+0x3bc>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201f94:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201f98:	679c                	ld	a5,8(a5)
ffffffffc0201f9a:	3dfd                	addiw	s11,s11,-1
ffffffffc0201f9c:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201fa0:	fe879ae3          	bne	a5,s0,ffffffffc0201f94 <swap_init+0x3ac>
     }
     assert(count==0);
ffffffffc0201fa4:	1c0d9f63          	bnez	s11,ffffffffc0202182 <swap_init+0x59a>
     assert(total==0);
ffffffffc0201fa8:	1a0d1163          	bnez	s10,ffffffffc020214a <swap_init+0x562>

     cprintf("check_swap() succeeded!\n");
ffffffffc0201fac:	00004517          	auipc	a0,0x4
ffffffffc0201fb0:	18c50513          	addi	a0,a0,396 # ffffffffc0206138 <commands+0x1008>
ffffffffc0201fb4:	924fe0ef          	jal	ra,ffffffffc02000d8 <cprintf>
}
ffffffffc0201fb8:	b149                	j	ffffffffc0201c3a <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201fba:	4481                	li	s1,0
ffffffffc0201fbc:	b1e5                	j	ffffffffc0201ca4 <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc0201fbe:	00004697          	auipc	a3,0x4
ffffffffc0201fc2:	f1268693          	addi	a3,a3,-238 # ffffffffc0205ed0 <commands+0xda0>
ffffffffc0201fc6:	00004617          	auipc	a2,0x4
ffffffffc0201fca:	89260613          	addi	a2,a2,-1902 # ffffffffc0205858 <commands+0x728>
ffffffffc0201fce:	0bd00593          	li	a1,189
ffffffffc0201fd2:	00004517          	auipc	a0,0x4
ffffffffc0201fd6:	ed650513          	addi	a0,a0,-298 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc0201fda:	9fafe0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc0201fde:	befff0ef          	jal	ra,ffffffffc0201bcc <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0201fe2:	00004617          	auipc	a2,0x4
ffffffffc0201fe6:	a9e60613          	addi	a2,a2,-1378 # ffffffffc0205a80 <commands+0x950>
ffffffffc0201fea:	06200593          	li	a1,98
ffffffffc0201fee:	00004517          	auipc	a0,0x4
ffffffffc0201ff2:	ab250513          	addi	a0,a0,-1358 # ffffffffc0205aa0 <commands+0x970>
ffffffffc0201ff6:	9defe0ef          	jal	ra,ffffffffc02001d4 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201ffa:	00004697          	auipc	a3,0x4
ffffffffc0201ffe:	0c668693          	addi	a3,a3,198 # ffffffffc02060c0 <commands+0xf90>
ffffffffc0202002:	00004617          	auipc	a2,0x4
ffffffffc0202006:	85660613          	addi	a2,a2,-1962 # ffffffffc0205858 <commands+0x728>
ffffffffc020200a:	0fd00593          	li	a1,253
ffffffffc020200e:	00004517          	auipc	a0,0x4
ffffffffc0202012:	e9a50513          	addi	a0,a0,-358 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc0202016:	9befe0ef          	jal	ra,ffffffffc02001d4 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc020201a:	00004697          	auipc	a3,0x4
ffffffffc020201e:	f9e68693          	addi	a3,a3,-98 # ffffffffc0205fb8 <commands+0xe88>
ffffffffc0202022:	00004617          	auipc	a2,0x4
ffffffffc0202026:	83660613          	addi	a2,a2,-1994 # ffffffffc0205858 <commands+0x728>
ffffffffc020202a:	0dd00593          	li	a1,221
ffffffffc020202e:	00004517          	auipc	a0,0x4
ffffffffc0202032:	e7a50513          	addi	a0,a0,-390 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc0202036:	99efe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020203a:	00004617          	auipc	a2,0x4
ffffffffc020203e:	e4e60613          	addi	a2,a2,-434 # ffffffffc0205e88 <commands+0xd58>
ffffffffc0202042:	02a00593          	li	a1,42
ffffffffc0202046:	00004517          	auipc	a0,0x4
ffffffffc020204a:	e6250513          	addi	a0,a0,-414 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc020204e:	986fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202052:	00004697          	auipc	a3,0x4
ffffffffc0202056:	02e68693          	addi	a3,a3,46 # ffffffffc0206080 <commands+0xf50>
ffffffffc020205a:	00003617          	auipc	a2,0x3
ffffffffc020205e:	7fe60613          	addi	a2,a2,2046 # ffffffffc0205858 <commands+0x728>
ffffffffc0202062:	0fc00593          	li	a1,252
ffffffffc0202066:	00004517          	auipc	a0,0x4
ffffffffc020206a:	e4250513          	addi	a0,a0,-446 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc020206e:	966fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202072:	00004617          	auipc	a2,0x4
ffffffffc0202076:	02660613          	addi	a2,a2,38 # ffffffffc0206098 <commands+0xf68>
ffffffffc020207a:	07400593          	li	a1,116
ffffffffc020207e:	00004517          	auipc	a0,0x4
ffffffffc0202082:	a2250513          	addi	a0,a0,-1502 # ffffffffc0205aa0 <commands+0x970>
ffffffffc0202086:	94efe0ef          	jal	ra,ffffffffc02001d4 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020208a:	00004697          	auipc	a3,0x4
ffffffffc020208e:	f4668693          	addi	a3,a3,-186 # ffffffffc0205fd0 <commands+0xea0>
ffffffffc0202092:	00003617          	auipc	a2,0x3
ffffffffc0202096:	7c660613          	addi	a2,a2,1990 # ffffffffc0205858 <commands+0x728>
ffffffffc020209a:	0de00593          	li	a1,222
ffffffffc020209e:	00004517          	auipc	a0,0x4
ffffffffc02020a2:	e0a50513          	addi	a0,a0,-502 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc02020a6:	92efe0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc02020aa:	00004697          	auipc	a3,0x4
ffffffffc02020ae:	e7e68693          	addi	a3,a3,-386 # ffffffffc0205f28 <commands+0xdf8>
ffffffffc02020b2:	00003617          	auipc	a2,0x3
ffffffffc02020b6:	7a660613          	addi	a2,a2,1958 # ffffffffc0205858 <commands+0x728>
ffffffffc02020ba:	0c800593          	li	a1,200
ffffffffc02020be:	00004517          	auipc	a0,0x4
ffffffffc02020c2:	dea50513          	addi	a0,a0,-534 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc02020c6:	90efe0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(total == nr_free_pages());
ffffffffc02020ca:	00004697          	auipc	a3,0x4
ffffffffc02020ce:	e1668693          	addi	a3,a3,-490 # ffffffffc0205ee0 <commands+0xdb0>
ffffffffc02020d2:	00003617          	auipc	a2,0x3
ffffffffc02020d6:	78660613          	addi	a2,a2,1926 # ffffffffc0205858 <commands+0x728>
ffffffffc02020da:	0c000593          	li	a1,192
ffffffffc02020de:	00004517          	auipc	a0,0x4
ffffffffc02020e2:	dca50513          	addi	a0,a0,-566 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc02020e6:	8eefe0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert( nr_free == 0);         
ffffffffc02020ea:	00004697          	auipc	a3,0x4
ffffffffc02020ee:	f8668693          	addi	a3,a3,-122 # ffffffffc0206070 <commands+0xf40>
ffffffffc02020f2:	00003617          	auipc	a2,0x3
ffffffffc02020f6:	76660613          	addi	a2,a2,1894 # ffffffffc0205858 <commands+0x728>
ffffffffc02020fa:	0f400593          	li	a1,244
ffffffffc02020fe:	00004517          	auipc	a0,0x4
ffffffffc0202102:	daa50513          	addi	a0,a0,-598 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc0202106:	8cefe0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgdir[0] == 0);
ffffffffc020210a:	00004697          	auipc	a3,0x4
ffffffffc020210e:	93668693          	addi	a3,a3,-1738 # ffffffffc0205a40 <commands+0x910>
ffffffffc0202112:	00003617          	auipc	a2,0x3
ffffffffc0202116:	74660613          	addi	a2,a2,1862 # ffffffffc0205858 <commands+0x728>
ffffffffc020211a:	0cd00593          	li	a1,205
ffffffffc020211e:	00004517          	auipc	a0,0x4
ffffffffc0202122:	d8a50513          	addi	a0,a0,-630 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc0202126:	8aefe0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(mm != NULL);
ffffffffc020212a:	00004697          	auipc	a3,0x4
ffffffffc020212e:	a3668693          	addi	a3,a3,-1482 # ffffffffc0205b60 <commands+0xa30>
ffffffffc0202132:	00003617          	auipc	a2,0x3
ffffffffc0202136:	72660613          	addi	a2,a2,1830 # ffffffffc0205858 <commands+0x728>
ffffffffc020213a:	0c500593          	li	a1,197
ffffffffc020213e:	00004517          	auipc	a0,0x4
ffffffffc0202142:	d6a50513          	addi	a0,a0,-662 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc0202146:	88efe0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(total==0);
ffffffffc020214a:	00004697          	auipc	a3,0x4
ffffffffc020214e:	fde68693          	addi	a3,a3,-34 # ffffffffc0206128 <commands+0xff8>
ffffffffc0202152:	00003617          	auipc	a2,0x3
ffffffffc0202156:	70660613          	addi	a2,a2,1798 # ffffffffc0205858 <commands+0x728>
ffffffffc020215a:	11d00593          	li	a1,285
ffffffffc020215e:	00004517          	auipc	a0,0x4
ffffffffc0202162:	d4a50513          	addi	a0,a0,-694 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc0202166:	86efe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    return KADDR(page2pa(page));
ffffffffc020216a:	00004617          	auipc	a2,0x4
ffffffffc020216e:	94660613          	addi	a2,a2,-1722 # ffffffffc0205ab0 <commands+0x980>
ffffffffc0202172:	06900593          	li	a1,105
ffffffffc0202176:	00004517          	auipc	a0,0x4
ffffffffc020217a:	92a50513          	addi	a0,a0,-1750 # ffffffffc0205aa0 <commands+0x970>
ffffffffc020217e:	856fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(count==0);
ffffffffc0202182:	00004697          	auipc	a3,0x4
ffffffffc0202186:	f9668693          	addi	a3,a3,-106 # ffffffffc0206118 <commands+0xfe8>
ffffffffc020218a:	00003617          	auipc	a2,0x3
ffffffffc020218e:	6ce60613          	addi	a2,a2,1742 # ffffffffc0205858 <commands+0x728>
ffffffffc0202192:	11c00593          	li	a1,284
ffffffffc0202196:	00004517          	auipc	a0,0x4
ffffffffc020219a:	d1250513          	addi	a0,a0,-750 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc020219e:	836fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==1);
ffffffffc02021a2:	00004697          	auipc	a3,0x4
ffffffffc02021a6:	e9e68693          	addi	a3,a3,-354 # ffffffffc0206040 <commands+0xf10>
ffffffffc02021aa:	00003617          	auipc	a2,0x3
ffffffffc02021ae:	6ae60613          	addi	a2,a2,1710 # ffffffffc0205858 <commands+0x728>
ffffffffc02021b2:	09600593          	li	a1,150
ffffffffc02021b6:	00004517          	auipc	a0,0x4
ffffffffc02021ba:	cf250513          	addi	a0,a0,-782 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc02021be:	816fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02021c2:	00004697          	auipc	a3,0x4
ffffffffc02021c6:	e2e68693          	addi	a3,a3,-466 # ffffffffc0205ff0 <commands+0xec0>
ffffffffc02021ca:	00003617          	auipc	a2,0x3
ffffffffc02021ce:	68e60613          	addi	a2,a2,1678 # ffffffffc0205858 <commands+0x728>
ffffffffc02021d2:	0eb00593          	li	a1,235
ffffffffc02021d6:	00004517          	auipc	a0,0x4
ffffffffc02021da:	cd250513          	addi	a0,a0,-814 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc02021de:	ff7fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02021e2:	00004697          	auipc	a3,0x4
ffffffffc02021e6:	d9668693          	addi	a3,a3,-618 # ffffffffc0205f78 <commands+0xe48>
ffffffffc02021ea:	00003617          	auipc	a2,0x3
ffffffffc02021ee:	66e60613          	addi	a2,a2,1646 # ffffffffc0205858 <commands+0x728>
ffffffffc02021f2:	0d800593          	li	a1,216
ffffffffc02021f6:	00004517          	auipc	a0,0x4
ffffffffc02021fa:	cb250513          	addi	a0,a0,-846 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc02021fe:	fd7fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(ret==0);
ffffffffc0202202:	00004697          	auipc	a3,0x4
ffffffffc0202206:	f0e68693          	addi	a3,a3,-242 # ffffffffc0206110 <commands+0xfe0>
ffffffffc020220a:	00003617          	auipc	a2,0x3
ffffffffc020220e:	64e60613          	addi	a2,a2,1614 # ffffffffc0205858 <commands+0x728>
ffffffffc0202212:	10300593          	li	a1,259
ffffffffc0202216:	00004517          	auipc	a0,0x4
ffffffffc020221a:	c9250513          	addi	a0,a0,-878 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc020221e:	fb7fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(vma != NULL);
ffffffffc0202222:	00004697          	auipc	a3,0x4
ffffffffc0202226:	91668693          	addi	a3,a3,-1770 # ffffffffc0205b38 <commands+0xa08>
ffffffffc020222a:	00003617          	auipc	a2,0x3
ffffffffc020222e:	62e60613          	addi	a2,a2,1582 # ffffffffc0205858 <commands+0x728>
ffffffffc0202232:	0d000593          	li	a1,208
ffffffffc0202236:	00004517          	auipc	a0,0x4
ffffffffc020223a:	c7250513          	addi	a0,a0,-910 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc020223e:	f97fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==4);
ffffffffc0202242:	00004697          	auipc	a3,0x4
ffffffffc0202246:	9f668693          	addi	a3,a3,-1546 # ffffffffc0205c38 <commands+0xb08>
ffffffffc020224a:	00003617          	auipc	a2,0x3
ffffffffc020224e:	60e60613          	addi	a2,a2,1550 # ffffffffc0205858 <commands+0x728>
ffffffffc0202252:	0a000593          	li	a1,160
ffffffffc0202256:	00004517          	auipc	a0,0x4
ffffffffc020225a:	c5250513          	addi	a0,a0,-942 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc020225e:	f77fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==4);
ffffffffc0202262:	00004697          	auipc	a3,0x4
ffffffffc0202266:	9d668693          	addi	a3,a3,-1578 # ffffffffc0205c38 <commands+0xb08>
ffffffffc020226a:	00003617          	auipc	a2,0x3
ffffffffc020226e:	5ee60613          	addi	a2,a2,1518 # ffffffffc0205858 <commands+0x728>
ffffffffc0202272:	0a200593          	li	a1,162
ffffffffc0202276:	00004517          	auipc	a0,0x4
ffffffffc020227a:	c3250513          	addi	a0,a0,-974 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc020227e:	f57fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==2);
ffffffffc0202282:	00004697          	auipc	a3,0x4
ffffffffc0202286:	dce68693          	addi	a3,a3,-562 # ffffffffc0206050 <commands+0xf20>
ffffffffc020228a:	00003617          	auipc	a2,0x3
ffffffffc020228e:	5ce60613          	addi	a2,a2,1486 # ffffffffc0205858 <commands+0x728>
ffffffffc0202292:	09800593          	li	a1,152
ffffffffc0202296:	00004517          	auipc	a0,0x4
ffffffffc020229a:	c1250513          	addi	a0,a0,-1006 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc020229e:	f37fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==2);
ffffffffc02022a2:	00004697          	auipc	a3,0x4
ffffffffc02022a6:	dae68693          	addi	a3,a3,-594 # ffffffffc0206050 <commands+0xf20>
ffffffffc02022aa:	00003617          	auipc	a2,0x3
ffffffffc02022ae:	5ae60613          	addi	a2,a2,1454 # ffffffffc0205858 <commands+0x728>
ffffffffc02022b2:	09a00593          	li	a1,154
ffffffffc02022b6:	00004517          	auipc	a0,0x4
ffffffffc02022ba:	bf250513          	addi	a0,a0,-1038 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc02022be:	f17fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==3);
ffffffffc02022c2:	00004697          	auipc	a3,0x4
ffffffffc02022c6:	d9e68693          	addi	a3,a3,-610 # ffffffffc0206060 <commands+0xf30>
ffffffffc02022ca:	00003617          	auipc	a2,0x3
ffffffffc02022ce:	58e60613          	addi	a2,a2,1422 # ffffffffc0205858 <commands+0x728>
ffffffffc02022d2:	09c00593          	li	a1,156
ffffffffc02022d6:	00004517          	auipc	a0,0x4
ffffffffc02022da:	bd250513          	addi	a0,a0,-1070 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc02022de:	ef7fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==3);
ffffffffc02022e2:	00004697          	auipc	a3,0x4
ffffffffc02022e6:	d7e68693          	addi	a3,a3,-642 # ffffffffc0206060 <commands+0xf30>
ffffffffc02022ea:	00003617          	auipc	a2,0x3
ffffffffc02022ee:	56e60613          	addi	a2,a2,1390 # ffffffffc0205858 <commands+0x728>
ffffffffc02022f2:	09e00593          	li	a1,158
ffffffffc02022f6:	00004517          	auipc	a0,0x4
ffffffffc02022fa:	bb250513          	addi	a0,a0,-1102 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc02022fe:	ed7fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==1);
ffffffffc0202302:	00004697          	auipc	a3,0x4
ffffffffc0202306:	d3e68693          	addi	a3,a3,-706 # ffffffffc0206040 <commands+0xf10>
ffffffffc020230a:	00003617          	auipc	a2,0x3
ffffffffc020230e:	54e60613          	addi	a2,a2,1358 # ffffffffc0205858 <commands+0x728>
ffffffffc0202312:	09400593          	li	a1,148
ffffffffc0202316:	00004517          	auipc	a0,0x4
ffffffffc020231a:	b9250513          	addi	a0,a0,-1134 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc020231e:	eb7fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0202322 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202322:	00013797          	auipc	a5,0x13
ffffffffc0202326:	24e7b783          	ld	a5,590(a5) # ffffffffc0215570 <sm>
ffffffffc020232a:	6b9c                	ld	a5,16(a5)
ffffffffc020232c:	8782                	jr	a5

ffffffffc020232e <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc020232e:	00013797          	auipc	a5,0x13
ffffffffc0202332:	2427b783          	ld	a5,578(a5) # ffffffffc0215570 <sm>
ffffffffc0202336:	739c                	ld	a5,32(a5)
ffffffffc0202338:	8782                	jr	a5

ffffffffc020233a <swap_out>:
{
ffffffffc020233a:	711d                	addi	sp,sp,-96
ffffffffc020233c:	ec86                	sd	ra,88(sp)
ffffffffc020233e:	e8a2                	sd	s0,80(sp)
ffffffffc0202340:	e4a6                	sd	s1,72(sp)
ffffffffc0202342:	e0ca                	sd	s2,64(sp)
ffffffffc0202344:	fc4e                	sd	s3,56(sp)
ffffffffc0202346:	f852                	sd	s4,48(sp)
ffffffffc0202348:	f456                	sd	s5,40(sp)
ffffffffc020234a:	f05a                	sd	s6,32(sp)
ffffffffc020234c:	ec5e                	sd	s7,24(sp)
ffffffffc020234e:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202350:	cde9                	beqz	a1,ffffffffc020242a <swap_out+0xf0>
ffffffffc0202352:	8a2e                	mv	s4,a1
ffffffffc0202354:	892a                	mv	s2,a0
ffffffffc0202356:	8ab2                	mv	s5,a2
ffffffffc0202358:	4401                	li	s0,0
ffffffffc020235a:	00013997          	auipc	s3,0x13
ffffffffc020235e:	21698993          	addi	s3,s3,534 # ffffffffc0215570 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202362:	00004b17          	auipc	s6,0x4
ffffffffc0202366:	e56b0b13          	addi	s6,s6,-426 # ffffffffc02061b8 <commands+0x1088>
                    cprintf("SWAP: failed to save\n");
ffffffffc020236a:	00004b97          	auipc	s7,0x4
ffffffffc020236e:	e36b8b93          	addi	s7,s7,-458 # ffffffffc02061a0 <commands+0x1070>
ffffffffc0202372:	a825                	j	ffffffffc02023aa <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202374:	67a2                	ld	a5,8(sp)
ffffffffc0202376:	8626                	mv	a2,s1
ffffffffc0202378:	85a2                	mv	a1,s0
ffffffffc020237a:	7f94                	ld	a3,56(a5)
ffffffffc020237c:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc020237e:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202380:	82b1                	srli	a3,a3,0xc
ffffffffc0202382:	0685                	addi	a3,a3,1
ffffffffc0202384:	d55fd0ef          	jal	ra,ffffffffc02000d8 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202388:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc020238a:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020238c:	7d1c                	ld	a5,56(a0)
ffffffffc020238e:	83b1                	srli	a5,a5,0xc
ffffffffc0202390:	0785                	addi	a5,a5,1
ffffffffc0202392:	07a2                	slli	a5,a5,0x8
ffffffffc0202394:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202398:	4a9000ef          	jal	ra,ffffffffc0203040 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc020239c:	01893503          	ld	a0,24(s2)
ffffffffc02023a0:	85a6                	mv	a1,s1
ffffffffc02023a2:	46b010ef          	jal	ra,ffffffffc020400c <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc02023a6:	048a0d63          	beq	s4,s0,ffffffffc0202400 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc02023aa:	0009b783          	ld	a5,0(s3)
ffffffffc02023ae:	8656                	mv	a2,s5
ffffffffc02023b0:	002c                	addi	a1,sp,8
ffffffffc02023b2:	7b9c                	ld	a5,48(a5)
ffffffffc02023b4:	854a                	mv	a0,s2
ffffffffc02023b6:	9782                	jalr	a5
          if (r != 0) {
ffffffffc02023b8:	e12d                	bnez	a0,ffffffffc020241a <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc02023ba:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02023bc:	01893503          	ld	a0,24(s2)
ffffffffc02023c0:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc02023c2:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02023c4:	85a6                	mv	a1,s1
ffffffffc02023c6:	4f5000ef          	jal	ra,ffffffffc02030ba <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc02023ca:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02023cc:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc02023ce:	8b85                	andi	a5,a5,1
ffffffffc02023d0:	cfb9                	beqz	a5,ffffffffc020242e <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc02023d2:	65a2                	ld	a1,8(sp)
ffffffffc02023d4:	7d9c                	ld	a5,56(a1)
ffffffffc02023d6:	83b1                	srli	a5,a5,0xc
ffffffffc02023d8:	0785                	addi	a5,a5,1
ffffffffc02023da:	00879513          	slli	a0,a5,0x8
ffffffffc02023de:	5b3010ef          	jal	ra,ffffffffc0204190 <swapfs_write>
ffffffffc02023e2:	d949                	beqz	a0,ffffffffc0202374 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc02023e4:	855e                	mv	a0,s7
ffffffffc02023e6:	cf3fd0ef          	jal	ra,ffffffffc02000d8 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02023ea:	0009b783          	ld	a5,0(s3)
ffffffffc02023ee:	6622                	ld	a2,8(sp)
ffffffffc02023f0:	4681                	li	a3,0
ffffffffc02023f2:	739c                	ld	a5,32(a5)
ffffffffc02023f4:	85a6                	mv	a1,s1
ffffffffc02023f6:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc02023f8:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02023fa:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc02023fc:	fa8a17e3          	bne	s4,s0,ffffffffc02023aa <swap_out+0x70>
}
ffffffffc0202400:	60e6                	ld	ra,88(sp)
ffffffffc0202402:	8522                	mv	a0,s0
ffffffffc0202404:	6446                	ld	s0,80(sp)
ffffffffc0202406:	64a6                	ld	s1,72(sp)
ffffffffc0202408:	6906                	ld	s2,64(sp)
ffffffffc020240a:	79e2                	ld	s3,56(sp)
ffffffffc020240c:	7a42                	ld	s4,48(sp)
ffffffffc020240e:	7aa2                	ld	s5,40(sp)
ffffffffc0202410:	7b02                	ld	s6,32(sp)
ffffffffc0202412:	6be2                	ld	s7,24(sp)
ffffffffc0202414:	6c42                	ld	s8,16(sp)
ffffffffc0202416:	6125                	addi	sp,sp,96
ffffffffc0202418:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc020241a:	85a2                	mv	a1,s0
ffffffffc020241c:	00004517          	auipc	a0,0x4
ffffffffc0202420:	d3c50513          	addi	a0,a0,-708 # ffffffffc0206158 <commands+0x1028>
ffffffffc0202424:	cb5fd0ef          	jal	ra,ffffffffc02000d8 <cprintf>
                  break;
ffffffffc0202428:	bfe1                	j	ffffffffc0202400 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc020242a:	4401                	li	s0,0
ffffffffc020242c:	bfd1                	j	ffffffffc0202400 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc020242e:	00004697          	auipc	a3,0x4
ffffffffc0202432:	d5a68693          	addi	a3,a3,-678 # ffffffffc0206188 <commands+0x1058>
ffffffffc0202436:	00003617          	auipc	a2,0x3
ffffffffc020243a:	42260613          	addi	a2,a2,1058 # ffffffffc0205858 <commands+0x728>
ffffffffc020243e:	06900593          	li	a1,105
ffffffffc0202442:	00004517          	auipc	a0,0x4
ffffffffc0202446:	a6650513          	addi	a0,a0,-1434 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc020244a:	d8bfd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc020244e <swap_in>:
{
ffffffffc020244e:	7179                	addi	sp,sp,-48
ffffffffc0202450:	e84a                	sd	s2,16(sp)
ffffffffc0202452:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202454:	4505                	li	a0,1
{
ffffffffc0202456:	ec26                	sd	s1,24(sp)
ffffffffc0202458:	e44e                	sd	s3,8(sp)
ffffffffc020245a:	f406                	sd	ra,40(sp)
ffffffffc020245c:	f022                	sd	s0,32(sp)
ffffffffc020245e:	84ae                	mv	s1,a1
ffffffffc0202460:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202462:	34d000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
     assert(result!=NULL);
ffffffffc0202466:	c129                	beqz	a0,ffffffffc02024a8 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202468:	842a                	mv	s0,a0
ffffffffc020246a:	01893503          	ld	a0,24(s2)
ffffffffc020246e:	4601                	li	a2,0
ffffffffc0202470:	85a6                	mv	a1,s1
ffffffffc0202472:	449000ef          	jal	ra,ffffffffc02030ba <get_pte>
ffffffffc0202476:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0202478:	6108                	ld	a0,0(a0)
ffffffffc020247a:	85a2                	mv	a1,s0
ffffffffc020247c:	487010ef          	jal	ra,ffffffffc0204102 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202480:	00093583          	ld	a1,0(s2)
ffffffffc0202484:	8626                	mv	a2,s1
ffffffffc0202486:	00004517          	auipc	a0,0x4
ffffffffc020248a:	d8250513          	addi	a0,a0,-638 # ffffffffc0206208 <commands+0x10d8>
ffffffffc020248e:	81a1                	srli	a1,a1,0x8
ffffffffc0202490:	c49fd0ef          	jal	ra,ffffffffc02000d8 <cprintf>
}
ffffffffc0202494:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0202496:	0089b023          	sd	s0,0(s3)
}
ffffffffc020249a:	7402                	ld	s0,32(sp)
ffffffffc020249c:	64e2                	ld	s1,24(sp)
ffffffffc020249e:	6942                	ld	s2,16(sp)
ffffffffc02024a0:	69a2                	ld	s3,8(sp)
ffffffffc02024a2:	4501                	li	a0,0
ffffffffc02024a4:	6145                	addi	sp,sp,48
ffffffffc02024a6:	8082                	ret
     assert(result!=NULL);
ffffffffc02024a8:	00004697          	auipc	a3,0x4
ffffffffc02024ac:	d5068693          	addi	a3,a3,-688 # ffffffffc02061f8 <commands+0x10c8>
ffffffffc02024b0:	00003617          	auipc	a2,0x3
ffffffffc02024b4:	3a860613          	addi	a2,a2,936 # ffffffffc0205858 <commands+0x728>
ffffffffc02024b8:	07f00593          	li	a1,127
ffffffffc02024bc:	00004517          	auipc	a0,0x4
ffffffffc02024c0:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0205ea8 <commands+0xd78>
ffffffffc02024c4:	d11fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02024c8 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc02024c8:	0000f797          	auipc	a5,0xf
ffffffffc02024cc:	03878793          	addi	a5,a5,56 # ffffffffc0211500 <free_area>
ffffffffc02024d0:	e79c                	sd	a5,8(a5)
ffffffffc02024d2:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc02024d4:	0007a823          	sw	zero,16(a5)
}
ffffffffc02024d8:	8082                	ret

ffffffffc02024da <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02024da:	0000f517          	auipc	a0,0xf
ffffffffc02024de:	03656503          	lwu	a0,54(a0) # ffffffffc0211510 <free_area+0x10>
ffffffffc02024e2:	8082                	ret

ffffffffc02024e4 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc02024e4:	715d                	addi	sp,sp,-80
ffffffffc02024e6:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc02024e8:	0000f417          	auipc	s0,0xf
ffffffffc02024ec:	01840413          	addi	s0,s0,24 # ffffffffc0211500 <free_area>
ffffffffc02024f0:	641c                	ld	a5,8(s0)
ffffffffc02024f2:	e486                	sd	ra,72(sp)
ffffffffc02024f4:	fc26                	sd	s1,56(sp)
ffffffffc02024f6:	f84a                	sd	s2,48(sp)
ffffffffc02024f8:	f44e                	sd	s3,40(sp)
ffffffffc02024fa:	f052                	sd	s4,32(sp)
ffffffffc02024fc:	ec56                	sd	s5,24(sp)
ffffffffc02024fe:	e85a                	sd	s6,16(sp)
ffffffffc0202500:	e45e                	sd	s7,8(sp)
ffffffffc0202502:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202504:	2a878d63          	beq	a5,s0,ffffffffc02027be <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0202508:	4481                	li	s1,0
ffffffffc020250a:	4901                	li	s2,0
ffffffffc020250c:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202510:	8b09                	andi	a4,a4,2
ffffffffc0202512:	2a070a63          	beqz	a4,ffffffffc02027c6 <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0202516:	ff87a703          	lw	a4,-8(a5)
ffffffffc020251a:	679c                	ld	a5,8(a5)
ffffffffc020251c:	2905                	addiw	s2,s2,1
ffffffffc020251e:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202520:	fe8796e3          	bne	a5,s0,ffffffffc020250c <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0202524:	89a6                	mv	s3,s1
ffffffffc0202526:	35b000ef          	jal	ra,ffffffffc0203080 <nr_free_pages>
ffffffffc020252a:	6f351e63          	bne	a0,s3,ffffffffc0202c26 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020252e:	4505                	li	a0,1
ffffffffc0202530:	27f000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc0202534:	8aaa                	mv	s5,a0
ffffffffc0202536:	42050863          	beqz	a0,ffffffffc0202966 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020253a:	4505                	li	a0,1
ffffffffc020253c:	273000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc0202540:	89aa                	mv	s3,a0
ffffffffc0202542:	70050263          	beqz	a0,ffffffffc0202c46 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202546:	4505                	li	a0,1
ffffffffc0202548:	267000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc020254c:	8a2a                	mv	s4,a0
ffffffffc020254e:	48050c63          	beqz	a0,ffffffffc02029e6 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202552:	293a8a63          	beq	s5,s3,ffffffffc02027e6 <default_check+0x302>
ffffffffc0202556:	28aa8863          	beq	s5,a0,ffffffffc02027e6 <default_check+0x302>
ffffffffc020255a:	28a98663          	beq	s3,a0,ffffffffc02027e6 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020255e:	000aa783          	lw	a5,0(s5)
ffffffffc0202562:	2a079263          	bnez	a5,ffffffffc0202806 <default_check+0x322>
ffffffffc0202566:	0009a783          	lw	a5,0(s3)
ffffffffc020256a:	28079e63          	bnez	a5,ffffffffc0202806 <default_check+0x322>
ffffffffc020256e:	411c                	lw	a5,0(a0)
ffffffffc0202570:	28079b63          	bnez	a5,ffffffffc0202806 <default_check+0x322>
    return page - pages + nbase;
ffffffffc0202574:	00013797          	auipc	a5,0x13
ffffffffc0202578:	0247b783          	ld	a5,36(a5) # ffffffffc0215598 <pages>
ffffffffc020257c:	40fa8733          	sub	a4,s5,a5
ffffffffc0202580:	00005617          	auipc	a2,0x5
ffffffffc0202584:	a0863603          	ld	a2,-1528(a2) # ffffffffc0206f88 <nbase>
ffffffffc0202588:	8719                	srai	a4,a4,0x6
ffffffffc020258a:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020258c:	00013697          	auipc	a3,0x13
ffffffffc0202590:	0046b683          	ld	a3,4(a3) # ffffffffc0215590 <npage>
ffffffffc0202594:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202596:	0732                	slli	a4,a4,0xc
ffffffffc0202598:	28d77763          	bgeu	a4,a3,ffffffffc0202826 <default_check+0x342>
    return page - pages + nbase;
ffffffffc020259c:	40f98733          	sub	a4,s3,a5
ffffffffc02025a0:	8719                	srai	a4,a4,0x6
ffffffffc02025a2:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02025a4:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02025a6:	4cd77063          	bgeu	a4,a3,ffffffffc0202a66 <default_check+0x582>
    return page - pages + nbase;
ffffffffc02025aa:	40f507b3          	sub	a5,a0,a5
ffffffffc02025ae:	8799                	srai	a5,a5,0x6
ffffffffc02025b0:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02025b2:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02025b4:	30d7f963          	bgeu	a5,a3,ffffffffc02028c6 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc02025b8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02025ba:	00043c03          	ld	s8,0(s0)
ffffffffc02025be:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc02025c2:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc02025c6:	e400                	sd	s0,8(s0)
ffffffffc02025c8:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc02025ca:	0000f797          	auipc	a5,0xf
ffffffffc02025ce:	f407a323          	sw	zero,-186(a5) # ffffffffc0211510 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02025d2:	1dd000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc02025d6:	2c051863          	bnez	a0,ffffffffc02028a6 <default_check+0x3c2>
    free_page(p0);
ffffffffc02025da:	4585                	li	a1,1
ffffffffc02025dc:	8556                	mv	a0,s5
ffffffffc02025de:	263000ef          	jal	ra,ffffffffc0203040 <free_pages>
    free_page(p1);
ffffffffc02025e2:	4585                	li	a1,1
ffffffffc02025e4:	854e                	mv	a0,s3
ffffffffc02025e6:	25b000ef          	jal	ra,ffffffffc0203040 <free_pages>
    free_page(p2);
ffffffffc02025ea:	4585                	li	a1,1
ffffffffc02025ec:	8552                	mv	a0,s4
ffffffffc02025ee:	253000ef          	jal	ra,ffffffffc0203040 <free_pages>
    assert(nr_free == 3);
ffffffffc02025f2:	4818                	lw	a4,16(s0)
ffffffffc02025f4:	478d                	li	a5,3
ffffffffc02025f6:	28f71863          	bne	a4,a5,ffffffffc0202886 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02025fa:	4505                	li	a0,1
ffffffffc02025fc:	1b3000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc0202600:	89aa                	mv	s3,a0
ffffffffc0202602:	26050263          	beqz	a0,ffffffffc0202866 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202606:	4505                	li	a0,1
ffffffffc0202608:	1a7000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc020260c:	8aaa                	mv	s5,a0
ffffffffc020260e:	3a050c63          	beqz	a0,ffffffffc02029c6 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202612:	4505                	li	a0,1
ffffffffc0202614:	19b000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc0202618:	8a2a                	mv	s4,a0
ffffffffc020261a:	38050663          	beqz	a0,ffffffffc02029a6 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc020261e:	4505                	li	a0,1
ffffffffc0202620:	18f000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc0202624:	36051163          	bnez	a0,ffffffffc0202986 <default_check+0x4a2>
    free_page(p0);
ffffffffc0202628:	4585                	li	a1,1
ffffffffc020262a:	854e                	mv	a0,s3
ffffffffc020262c:	215000ef          	jal	ra,ffffffffc0203040 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202630:	641c                	ld	a5,8(s0)
ffffffffc0202632:	20878a63          	beq	a5,s0,ffffffffc0202846 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0202636:	4505                	li	a0,1
ffffffffc0202638:	177000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc020263c:	30a99563          	bne	s3,a0,ffffffffc0202946 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0202640:	4505                	li	a0,1
ffffffffc0202642:	16d000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc0202646:	2e051063          	bnez	a0,ffffffffc0202926 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc020264a:	481c                	lw	a5,16(s0)
ffffffffc020264c:	2a079d63          	bnez	a5,ffffffffc0202906 <default_check+0x422>
    free_page(p);
ffffffffc0202650:	854e                	mv	a0,s3
ffffffffc0202652:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202654:	01843023          	sd	s8,0(s0)
ffffffffc0202658:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc020265c:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0202660:	1e1000ef          	jal	ra,ffffffffc0203040 <free_pages>
    free_page(p1);
ffffffffc0202664:	4585                	li	a1,1
ffffffffc0202666:	8556                	mv	a0,s5
ffffffffc0202668:	1d9000ef          	jal	ra,ffffffffc0203040 <free_pages>
    free_page(p2);
ffffffffc020266c:	4585                	li	a1,1
ffffffffc020266e:	8552                	mv	a0,s4
ffffffffc0202670:	1d1000ef          	jal	ra,ffffffffc0203040 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202674:	4515                	li	a0,5
ffffffffc0202676:	139000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc020267a:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020267c:	26050563          	beqz	a0,ffffffffc02028e6 <default_check+0x402>
ffffffffc0202680:	651c                	ld	a5,8(a0)
ffffffffc0202682:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0202684:	8b85                	andi	a5,a5,1
ffffffffc0202686:	54079063          	bnez	a5,ffffffffc0202bc6 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc020268a:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020268c:	00043b03          	ld	s6,0(s0)
ffffffffc0202690:	00843a83          	ld	s5,8(s0)
ffffffffc0202694:	e000                	sd	s0,0(s0)
ffffffffc0202696:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0202698:	117000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc020269c:	50051563          	bnez	a0,ffffffffc0202ba6 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02026a0:	08098a13          	addi	s4,s3,128
ffffffffc02026a4:	8552                	mv	a0,s4
ffffffffc02026a6:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02026a8:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc02026ac:	0000f797          	auipc	a5,0xf
ffffffffc02026b0:	e607a223          	sw	zero,-412(a5) # ffffffffc0211510 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02026b4:	18d000ef          	jal	ra,ffffffffc0203040 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02026b8:	4511                	li	a0,4
ffffffffc02026ba:	0f5000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc02026be:	4c051463          	bnez	a0,ffffffffc0202b86 <default_check+0x6a2>
ffffffffc02026c2:	0889b783          	ld	a5,136(s3)
ffffffffc02026c6:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02026c8:	8b85                	andi	a5,a5,1
ffffffffc02026ca:	48078e63          	beqz	a5,ffffffffc0202b66 <default_check+0x682>
ffffffffc02026ce:	0909a703          	lw	a4,144(s3)
ffffffffc02026d2:	478d                	li	a5,3
ffffffffc02026d4:	48f71963          	bne	a4,a5,ffffffffc0202b66 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02026d8:	450d                	li	a0,3
ffffffffc02026da:	0d5000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc02026de:	8c2a                	mv	s8,a0
ffffffffc02026e0:	46050363          	beqz	a0,ffffffffc0202b46 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc02026e4:	4505                	li	a0,1
ffffffffc02026e6:	0c9000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc02026ea:	42051e63          	bnez	a0,ffffffffc0202b26 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc02026ee:	418a1c63          	bne	s4,s8,ffffffffc0202b06 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02026f2:	4585                	li	a1,1
ffffffffc02026f4:	854e                	mv	a0,s3
ffffffffc02026f6:	14b000ef          	jal	ra,ffffffffc0203040 <free_pages>
    free_pages(p1, 3);
ffffffffc02026fa:	458d                	li	a1,3
ffffffffc02026fc:	8552                	mv	a0,s4
ffffffffc02026fe:	143000ef          	jal	ra,ffffffffc0203040 <free_pages>
ffffffffc0202702:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202706:	04098c13          	addi	s8,s3,64
ffffffffc020270a:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020270c:	8b85                	andi	a5,a5,1
ffffffffc020270e:	3c078c63          	beqz	a5,ffffffffc0202ae6 <default_check+0x602>
ffffffffc0202712:	0109a703          	lw	a4,16(s3)
ffffffffc0202716:	4785                	li	a5,1
ffffffffc0202718:	3cf71763          	bne	a4,a5,ffffffffc0202ae6 <default_check+0x602>
ffffffffc020271c:	008a3783          	ld	a5,8(s4)
ffffffffc0202720:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202722:	8b85                	andi	a5,a5,1
ffffffffc0202724:	3a078163          	beqz	a5,ffffffffc0202ac6 <default_check+0x5e2>
ffffffffc0202728:	010a2703          	lw	a4,16(s4)
ffffffffc020272c:	478d                	li	a5,3
ffffffffc020272e:	38f71c63          	bne	a4,a5,ffffffffc0202ac6 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202732:	4505                	li	a0,1
ffffffffc0202734:	07b000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc0202738:	36a99763          	bne	s3,a0,ffffffffc0202aa6 <default_check+0x5c2>
    free_page(p0);
ffffffffc020273c:	4585                	li	a1,1
ffffffffc020273e:	103000ef          	jal	ra,ffffffffc0203040 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202742:	4509                	li	a0,2
ffffffffc0202744:	06b000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc0202748:	32aa1f63          	bne	s4,a0,ffffffffc0202a86 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc020274c:	4589                	li	a1,2
ffffffffc020274e:	0f3000ef          	jal	ra,ffffffffc0203040 <free_pages>
    free_page(p2);
ffffffffc0202752:	4585                	li	a1,1
ffffffffc0202754:	8562                	mv	a0,s8
ffffffffc0202756:	0eb000ef          	jal	ra,ffffffffc0203040 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020275a:	4515                	li	a0,5
ffffffffc020275c:	053000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc0202760:	89aa                	mv	s3,a0
ffffffffc0202762:	48050263          	beqz	a0,ffffffffc0202be6 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0202766:	4505                	li	a0,1
ffffffffc0202768:	047000ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc020276c:	2c051d63          	bnez	a0,ffffffffc0202a46 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0202770:	481c                	lw	a5,16(s0)
ffffffffc0202772:	2a079a63          	bnez	a5,ffffffffc0202a26 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0202776:	4595                	li	a1,5
ffffffffc0202778:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020277a:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc020277e:	01643023          	sd	s6,0(s0)
ffffffffc0202782:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0202786:	0bb000ef          	jal	ra,ffffffffc0203040 <free_pages>
    return listelm->next;
ffffffffc020278a:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020278c:	00878963          	beq	a5,s0,ffffffffc020279e <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0202790:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202794:	679c                	ld	a5,8(a5)
ffffffffc0202796:	397d                	addiw	s2,s2,-1
ffffffffc0202798:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020279a:	fe879be3          	bne	a5,s0,ffffffffc0202790 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc020279e:	26091463          	bnez	s2,ffffffffc0202a06 <default_check+0x522>
    assert(total == 0);
ffffffffc02027a2:	46049263          	bnez	s1,ffffffffc0202c06 <default_check+0x722>
}
ffffffffc02027a6:	60a6                	ld	ra,72(sp)
ffffffffc02027a8:	6406                	ld	s0,64(sp)
ffffffffc02027aa:	74e2                	ld	s1,56(sp)
ffffffffc02027ac:	7942                	ld	s2,48(sp)
ffffffffc02027ae:	79a2                	ld	s3,40(sp)
ffffffffc02027b0:	7a02                	ld	s4,32(sp)
ffffffffc02027b2:	6ae2                	ld	s5,24(sp)
ffffffffc02027b4:	6b42                	ld	s6,16(sp)
ffffffffc02027b6:	6ba2                	ld	s7,8(sp)
ffffffffc02027b8:	6c02                	ld	s8,0(sp)
ffffffffc02027ba:	6161                	addi	sp,sp,80
ffffffffc02027bc:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02027be:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02027c0:	4481                	li	s1,0
ffffffffc02027c2:	4901                	li	s2,0
ffffffffc02027c4:	b38d                	j	ffffffffc0202526 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc02027c6:	00003697          	auipc	a3,0x3
ffffffffc02027ca:	70a68693          	addi	a3,a3,1802 # ffffffffc0205ed0 <commands+0xda0>
ffffffffc02027ce:	00003617          	auipc	a2,0x3
ffffffffc02027d2:	08a60613          	addi	a2,a2,138 # ffffffffc0205858 <commands+0x728>
ffffffffc02027d6:	0f000593          	li	a1,240
ffffffffc02027da:	00004517          	auipc	a0,0x4
ffffffffc02027de:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0206248 <commands+0x1118>
ffffffffc02027e2:	9f3fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02027e6:	00004697          	auipc	a3,0x4
ffffffffc02027ea:	ada68693          	addi	a3,a3,-1318 # ffffffffc02062c0 <commands+0x1190>
ffffffffc02027ee:	00003617          	auipc	a2,0x3
ffffffffc02027f2:	06a60613          	addi	a2,a2,106 # ffffffffc0205858 <commands+0x728>
ffffffffc02027f6:	0bd00593          	li	a1,189
ffffffffc02027fa:	00004517          	auipc	a0,0x4
ffffffffc02027fe:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202802:	9d3fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202806:	00004697          	auipc	a3,0x4
ffffffffc020280a:	ae268693          	addi	a3,a3,-1310 # ffffffffc02062e8 <commands+0x11b8>
ffffffffc020280e:	00003617          	auipc	a2,0x3
ffffffffc0202812:	04a60613          	addi	a2,a2,74 # ffffffffc0205858 <commands+0x728>
ffffffffc0202816:	0be00593          	li	a1,190
ffffffffc020281a:	00004517          	auipc	a0,0x4
ffffffffc020281e:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202822:	9b3fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202826:	00004697          	auipc	a3,0x4
ffffffffc020282a:	b0268693          	addi	a3,a3,-1278 # ffffffffc0206328 <commands+0x11f8>
ffffffffc020282e:	00003617          	auipc	a2,0x3
ffffffffc0202832:	02a60613          	addi	a2,a2,42 # ffffffffc0205858 <commands+0x728>
ffffffffc0202836:	0c000593          	li	a1,192
ffffffffc020283a:	00004517          	auipc	a0,0x4
ffffffffc020283e:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202842:	993fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202846:	00004697          	auipc	a3,0x4
ffffffffc020284a:	b6a68693          	addi	a3,a3,-1174 # ffffffffc02063b0 <commands+0x1280>
ffffffffc020284e:	00003617          	auipc	a2,0x3
ffffffffc0202852:	00a60613          	addi	a2,a2,10 # ffffffffc0205858 <commands+0x728>
ffffffffc0202856:	0d900593          	li	a1,217
ffffffffc020285a:	00004517          	auipc	a0,0x4
ffffffffc020285e:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202862:	973fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202866:	00004697          	auipc	a3,0x4
ffffffffc020286a:	9fa68693          	addi	a3,a3,-1542 # ffffffffc0206260 <commands+0x1130>
ffffffffc020286e:	00003617          	auipc	a2,0x3
ffffffffc0202872:	fea60613          	addi	a2,a2,-22 # ffffffffc0205858 <commands+0x728>
ffffffffc0202876:	0d200593          	li	a1,210
ffffffffc020287a:	00004517          	auipc	a0,0x4
ffffffffc020287e:	9ce50513          	addi	a0,a0,-1586 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202882:	953fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free == 3);
ffffffffc0202886:	00004697          	auipc	a3,0x4
ffffffffc020288a:	b1a68693          	addi	a3,a3,-1254 # ffffffffc02063a0 <commands+0x1270>
ffffffffc020288e:	00003617          	auipc	a2,0x3
ffffffffc0202892:	fca60613          	addi	a2,a2,-54 # ffffffffc0205858 <commands+0x728>
ffffffffc0202896:	0d000593          	li	a1,208
ffffffffc020289a:	00004517          	auipc	a0,0x4
ffffffffc020289e:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0206248 <commands+0x1118>
ffffffffc02028a2:	933fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02028a6:	00004697          	auipc	a3,0x4
ffffffffc02028aa:	ae268693          	addi	a3,a3,-1310 # ffffffffc0206388 <commands+0x1258>
ffffffffc02028ae:	00003617          	auipc	a2,0x3
ffffffffc02028b2:	faa60613          	addi	a2,a2,-86 # ffffffffc0205858 <commands+0x728>
ffffffffc02028b6:	0cb00593          	li	a1,203
ffffffffc02028ba:	00004517          	auipc	a0,0x4
ffffffffc02028be:	98e50513          	addi	a0,a0,-1650 # ffffffffc0206248 <commands+0x1118>
ffffffffc02028c2:	913fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02028c6:	00004697          	auipc	a3,0x4
ffffffffc02028ca:	aa268693          	addi	a3,a3,-1374 # ffffffffc0206368 <commands+0x1238>
ffffffffc02028ce:	00003617          	auipc	a2,0x3
ffffffffc02028d2:	f8a60613          	addi	a2,a2,-118 # ffffffffc0205858 <commands+0x728>
ffffffffc02028d6:	0c200593          	li	a1,194
ffffffffc02028da:	00004517          	auipc	a0,0x4
ffffffffc02028de:	96e50513          	addi	a0,a0,-1682 # ffffffffc0206248 <commands+0x1118>
ffffffffc02028e2:	8f3fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(p0 != NULL);
ffffffffc02028e6:	00004697          	auipc	a3,0x4
ffffffffc02028ea:	b0268693          	addi	a3,a3,-1278 # ffffffffc02063e8 <commands+0x12b8>
ffffffffc02028ee:	00003617          	auipc	a2,0x3
ffffffffc02028f2:	f6a60613          	addi	a2,a2,-150 # ffffffffc0205858 <commands+0x728>
ffffffffc02028f6:	0f800593          	li	a1,248
ffffffffc02028fa:	00004517          	auipc	a0,0x4
ffffffffc02028fe:	94e50513          	addi	a0,a0,-1714 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202902:	8d3fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free == 0);
ffffffffc0202906:	00003697          	auipc	a3,0x3
ffffffffc020290a:	76a68693          	addi	a3,a3,1898 # ffffffffc0206070 <commands+0xf40>
ffffffffc020290e:	00003617          	auipc	a2,0x3
ffffffffc0202912:	f4a60613          	addi	a2,a2,-182 # ffffffffc0205858 <commands+0x728>
ffffffffc0202916:	0df00593          	li	a1,223
ffffffffc020291a:	00004517          	auipc	a0,0x4
ffffffffc020291e:	92e50513          	addi	a0,a0,-1746 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202922:	8b3fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202926:	00004697          	auipc	a3,0x4
ffffffffc020292a:	a6268693          	addi	a3,a3,-1438 # ffffffffc0206388 <commands+0x1258>
ffffffffc020292e:	00003617          	auipc	a2,0x3
ffffffffc0202932:	f2a60613          	addi	a2,a2,-214 # ffffffffc0205858 <commands+0x728>
ffffffffc0202936:	0dd00593          	li	a1,221
ffffffffc020293a:	00004517          	auipc	a0,0x4
ffffffffc020293e:	90e50513          	addi	a0,a0,-1778 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202942:	893fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202946:	00004697          	auipc	a3,0x4
ffffffffc020294a:	a8268693          	addi	a3,a3,-1406 # ffffffffc02063c8 <commands+0x1298>
ffffffffc020294e:	00003617          	auipc	a2,0x3
ffffffffc0202952:	f0a60613          	addi	a2,a2,-246 # ffffffffc0205858 <commands+0x728>
ffffffffc0202956:	0dc00593          	li	a1,220
ffffffffc020295a:	00004517          	auipc	a0,0x4
ffffffffc020295e:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202962:	873fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202966:	00004697          	auipc	a3,0x4
ffffffffc020296a:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0206260 <commands+0x1130>
ffffffffc020296e:	00003617          	auipc	a2,0x3
ffffffffc0202972:	eea60613          	addi	a2,a2,-278 # ffffffffc0205858 <commands+0x728>
ffffffffc0202976:	0b900593          	li	a1,185
ffffffffc020297a:	00004517          	auipc	a0,0x4
ffffffffc020297e:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202982:	853fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202986:	00004697          	auipc	a3,0x4
ffffffffc020298a:	a0268693          	addi	a3,a3,-1534 # ffffffffc0206388 <commands+0x1258>
ffffffffc020298e:	00003617          	auipc	a2,0x3
ffffffffc0202992:	eca60613          	addi	a2,a2,-310 # ffffffffc0205858 <commands+0x728>
ffffffffc0202996:	0d600593          	li	a1,214
ffffffffc020299a:	00004517          	auipc	a0,0x4
ffffffffc020299e:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0206248 <commands+0x1118>
ffffffffc02029a2:	833fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02029a6:	00004697          	auipc	a3,0x4
ffffffffc02029aa:	8fa68693          	addi	a3,a3,-1798 # ffffffffc02062a0 <commands+0x1170>
ffffffffc02029ae:	00003617          	auipc	a2,0x3
ffffffffc02029b2:	eaa60613          	addi	a2,a2,-342 # ffffffffc0205858 <commands+0x728>
ffffffffc02029b6:	0d400593          	li	a1,212
ffffffffc02029ba:	00004517          	auipc	a0,0x4
ffffffffc02029be:	88e50513          	addi	a0,a0,-1906 # ffffffffc0206248 <commands+0x1118>
ffffffffc02029c2:	813fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02029c6:	00004697          	auipc	a3,0x4
ffffffffc02029ca:	8ba68693          	addi	a3,a3,-1862 # ffffffffc0206280 <commands+0x1150>
ffffffffc02029ce:	00003617          	auipc	a2,0x3
ffffffffc02029d2:	e8a60613          	addi	a2,a2,-374 # ffffffffc0205858 <commands+0x728>
ffffffffc02029d6:	0d300593          	li	a1,211
ffffffffc02029da:	00004517          	auipc	a0,0x4
ffffffffc02029de:	86e50513          	addi	a0,a0,-1938 # ffffffffc0206248 <commands+0x1118>
ffffffffc02029e2:	ff2fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02029e6:	00004697          	auipc	a3,0x4
ffffffffc02029ea:	8ba68693          	addi	a3,a3,-1862 # ffffffffc02062a0 <commands+0x1170>
ffffffffc02029ee:	00003617          	auipc	a2,0x3
ffffffffc02029f2:	e6a60613          	addi	a2,a2,-406 # ffffffffc0205858 <commands+0x728>
ffffffffc02029f6:	0bb00593          	li	a1,187
ffffffffc02029fa:	00004517          	auipc	a0,0x4
ffffffffc02029fe:	84e50513          	addi	a0,a0,-1970 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202a02:	fd2fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(count == 0);
ffffffffc0202a06:	00004697          	auipc	a3,0x4
ffffffffc0202a0a:	b3268693          	addi	a3,a3,-1230 # ffffffffc0206538 <commands+0x1408>
ffffffffc0202a0e:	00003617          	auipc	a2,0x3
ffffffffc0202a12:	e4a60613          	addi	a2,a2,-438 # ffffffffc0205858 <commands+0x728>
ffffffffc0202a16:	12500593          	li	a1,293
ffffffffc0202a1a:	00004517          	auipc	a0,0x4
ffffffffc0202a1e:	82e50513          	addi	a0,a0,-2002 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202a22:	fb2fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free == 0);
ffffffffc0202a26:	00003697          	auipc	a3,0x3
ffffffffc0202a2a:	64a68693          	addi	a3,a3,1610 # ffffffffc0206070 <commands+0xf40>
ffffffffc0202a2e:	00003617          	auipc	a2,0x3
ffffffffc0202a32:	e2a60613          	addi	a2,a2,-470 # ffffffffc0205858 <commands+0x728>
ffffffffc0202a36:	11a00593          	li	a1,282
ffffffffc0202a3a:	00004517          	auipc	a0,0x4
ffffffffc0202a3e:	80e50513          	addi	a0,a0,-2034 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202a42:	f92fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202a46:	00004697          	auipc	a3,0x4
ffffffffc0202a4a:	94268693          	addi	a3,a3,-1726 # ffffffffc0206388 <commands+0x1258>
ffffffffc0202a4e:	00003617          	auipc	a2,0x3
ffffffffc0202a52:	e0a60613          	addi	a2,a2,-502 # ffffffffc0205858 <commands+0x728>
ffffffffc0202a56:	11800593          	li	a1,280
ffffffffc0202a5a:	00003517          	auipc	a0,0x3
ffffffffc0202a5e:	7ee50513          	addi	a0,a0,2030 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202a62:	f72fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202a66:	00004697          	auipc	a3,0x4
ffffffffc0202a6a:	8e268693          	addi	a3,a3,-1822 # ffffffffc0206348 <commands+0x1218>
ffffffffc0202a6e:	00003617          	auipc	a2,0x3
ffffffffc0202a72:	dea60613          	addi	a2,a2,-534 # ffffffffc0205858 <commands+0x728>
ffffffffc0202a76:	0c100593          	li	a1,193
ffffffffc0202a7a:	00003517          	auipc	a0,0x3
ffffffffc0202a7e:	7ce50513          	addi	a0,a0,1998 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202a82:	f52fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202a86:	00004697          	auipc	a3,0x4
ffffffffc0202a8a:	a7268693          	addi	a3,a3,-1422 # ffffffffc02064f8 <commands+0x13c8>
ffffffffc0202a8e:	00003617          	auipc	a2,0x3
ffffffffc0202a92:	dca60613          	addi	a2,a2,-566 # ffffffffc0205858 <commands+0x728>
ffffffffc0202a96:	11200593          	li	a1,274
ffffffffc0202a9a:	00003517          	auipc	a0,0x3
ffffffffc0202a9e:	7ae50513          	addi	a0,a0,1966 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202aa2:	f32fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202aa6:	00004697          	auipc	a3,0x4
ffffffffc0202aaa:	a3268693          	addi	a3,a3,-1486 # ffffffffc02064d8 <commands+0x13a8>
ffffffffc0202aae:	00003617          	auipc	a2,0x3
ffffffffc0202ab2:	daa60613          	addi	a2,a2,-598 # ffffffffc0205858 <commands+0x728>
ffffffffc0202ab6:	11000593          	li	a1,272
ffffffffc0202aba:	00003517          	auipc	a0,0x3
ffffffffc0202abe:	78e50513          	addi	a0,a0,1934 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202ac2:	f12fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202ac6:	00004697          	auipc	a3,0x4
ffffffffc0202aca:	9ea68693          	addi	a3,a3,-1558 # ffffffffc02064b0 <commands+0x1380>
ffffffffc0202ace:	00003617          	auipc	a2,0x3
ffffffffc0202ad2:	d8a60613          	addi	a2,a2,-630 # ffffffffc0205858 <commands+0x728>
ffffffffc0202ad6:	10e00593          	li	a1,270
ffffffffc0202ada:	00003517          	auipc	a0,0x3
ffffffffc0202ade:	76e50513          	addi	a0,a0,1902 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202ae2:	ef2fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202ae6:	00004697          	auipc	a3,0x4
ffffffffc0202aea:	9a268693          	addi	a3,a3,-1630 # ffffffffc0206488 <commands+0x1358>
ffffffffc0202aee:	00003617          	auipc	a2,0x3
ffffffffc0202af2:	d6a60613          	addi	a2,a2,-662 # ffffffffc0205858 <commands+0x728>
ffffffffc0202af6:	10d00593          	li	a1,269
ffffffffc0202afa:	00003517          	auipc	a0,0x3
ffffffffc0202afe:	74e50513          	addi	a0,a0,1870 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202b02:	ed2fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0202b06:	00004697          	auipc	a3,0x4
ffffffffc0202b0a:	97268693          	addi	a3,a3,-1678 # ffffffffc0206478 <commands+0x1348>
ffffffffc0202b0e:	00003617          	auipc	a2,0x3
ffffffffc0202b12:	d4a60613          	addi	a2,a2,-694 # ffffffffc0205858 <commands+0x728>
ffffffffc0202b16:	10800593          	li	a1,264
ffffffffc0202b1a:	00003517          	auipc	a0,0x3
ffffffffc0202b1e:	72e50513          	addi	a0,a0,1838 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202b22:	eb2fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202b26:	00004697          	auipc	a3,0x4
ffffffffc0202b2a:	86268693          	addi	a3,a3,-1950 # ffffffffc0206388 <commands+0x1258>
ffffffffc0202b2e:	00003617          	auipc	a2,0x3
ffffffffc0202b32:	d2a60613          	addi	a2,a2,-726 # ffffffffc0205858 <commands+0x728>
ffffffffc0202b36:	10700593          	li	a1,263
ffffffffc0202b3a:	00003517          	auipc	a0,0x3
ffffffffc0202b3e:	70e50513          	addi	a0,a0,1806 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202b42:	e92fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202b46:	00004697          	auipc	a3,0x4
ffffffffc0202b4a:	91268693          	addi	a3,a3,-1774 # ffffffffc0206458 <commands+0x1328>
ffffffffc0202b4e:	00003617          	auipc	a2,0x3
ffffffffc0202b52:	d0a60613          	addi	a2,a2,-758 # ffffffffc0205858 <commands+0x728>
ffffffffc0202b56:	10600593          	li	a1,262
ffffffffc0202b5a:	00003517          	auipc	a0,0x3
ffffffffc0202b5e:	6ee50513          	addi	a0,a0,1774 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202b62:	e72fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202b66:	00004697          	auipc	a3,0x4
ffffffffc0202b6a:	8c268693          	addi	a3,a3,-1854 # ffffffffc0206428 <commands+0x12f8>
ffffffffc0202b6e:	00003617          	auipc	a2,0x3
ffffffffc0202b72:	cea60613          	addi	a2,a2,-790 # ffffffffc0205858 <commands+0x728>
ffffffffc0202b76:	10500593          	li	a1,261
ffffffffc0202b7a:	00003517          	auipc	a0,0x3
ffffffffc0202b7e:	6ce50513          	addi	a0,a0,1742 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202b82:	e52fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202b86:	00004697          	auipc	a3,0x4
ffffffffc0202b8a:	88a68693          	addi	a3,a3,-1910 # ffffffffc0206410 <commands+0x12e0>
ffffffffc0202b8e:	00003617          	auipc	a2,0x3
ffffffffc0202b92:	cca60613          	addi	a2,a2,-822 # ffffffffc0205858 <commands+0x728>
ffffffffc0202b96:	10400593          	li	a1,260
ffffffffc0202b9a:	00003517          	auipc	a0,0x3
ffffffffc0202b9e:	6ae50513          	addi	a0,a0,1710 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202ba2:	e32fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202ba6:	00003697          	auipc	a3,0x3
ffffffffc0202baa:	7e268693          	addi	a3,a3,2018 # ffffffffc0206388 <commands+0x1258>
ffffffffc0202bae:	00003617          	auipc	a2,0x3
ffffffffc0202bb2:	caa60613          	addi	a2,a2,-854 # ffffffffc0205858 <commands+0x728>
ffffffffc0202bb6:	0fe00593          	li	a1,254
ffffffffc0202bba:	00003517          	auipc	a0,0x3
ffffffffc0202bbe:	68e50513          	addi	a0,a0,1678 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202bc2:	e12fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(!PageProperty(p0));
ffffffffc0202bc6:	00004697          	auipc	a3,0x4
ffffffffc0202bca:	83268693          	addi	a3,a3,-1998 # ffffffffc02063f8 <commands+0x12c8>
ffffffffc0202bce:	00003617          	auipc	a2,0x3
ffffffffc0202bd2:	c8a60613          	addi	a2,a2,-886 # ffffffffc0205858 <commands+0x728>
ffffffffc0202bd6:	0f900593          	li	a1,249
ffffffffc0202bda:	00003517          	auipc	a0,0x3
ffffffffc0202bde:	66e50513          	addi	a0,a0,1646 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202be2:	df2fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202be6:	00004697          	auipc	a3,0x4
ffffffffc0202bea:	93268693          	addi	a3,a3,-1742 # ffffffffc0206518 <commands+0x13e8>
ffffffffc0202bee:	00003617          	auipc	a2,0x3
ffffffffc0202bf2:	c6a60613          	addi	a2,a2,-918 # ffffffffc0205858 <commands+0x728>
ffffffffc0202bf6:	11700593          	li	a1,279
ffffffffc0202bfa:	00003517          	auipc	a0,0x3
ffffffffc0202bfe:	64e50513          	addi	a0,a0,1614 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202c02:	dd2fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(total == 0);
ffffffffc0202c06:	00004697          	auipc	a3,0x4
ffffffffc0202c0a:	94268693          	addi	a3,a3,-1726 # ffffffffc0206548 <commands+0x1418>
ffffffffc0202c0e:	00003617          	auipc	a2,0x3
ffffffffc0202c12:	c4a60613          	addi	a2,a2,-950 # ffffffffc0205858 <commands+0x728>
ffffffffc0202c16:	12600593          	li	a1,294
ffffffffc0202c1a:	00003517          	auipc	a0,0x3
ffffffffc0202c1e:	62e50513          	addi	a0,a0,1582 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202c22:	db2fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(total == nr_free_pages());
ffffffffc0202c26:	00003697          	auipc	a3,0x3
ffffffffc0202c2a:	2ba68693          	addi	a3,a3,698 # ffffffffc0205ee0 <commands+0xdb0>
ffffffffc0202c2e:	00003617          	auipc	a2,0x3
ffffffffc0202c32:	c2a60613          	addi	a2,a2,-982 # ffffffffc0205858 <commands+0x728>
ffffffffc0202c36:	0f300593          	li	a1,243
ffffffffc0202c3a:	00003517          	auipc	a0,0x3
ffffffffc0202c3e:	60e50513          	addi	a0,a0,1550 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202c42:	d92fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202c46:	00003697          	auipc	a3,0x3
ffffffffc0202c4a:	63a68693          	addi	a3,a3,1594 # ffffffffc0206280 <commands+0x1150>
ffffffffc0202c4e:	00003617          	auipc	a2,0x3
ffffffffc0202c52:	c0a60613          	addi	a2,a2,-1014 # ffffffffc0205858 <commands+0x728>
ffffffffc0202c56:	0ba00593          	li	a1,186
ffffffffc0202c5a:	00003517          	auipc	a0,0x3
ffffffffc0202c5e:	5ee50513          	addi	a0,a0,1518 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202c62:	d72fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0202c66 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0202c66:	1141                	addi	sp,sp,-16
ffffffffc0202c68:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202c6a:	14058463          	beqz	a1,ffffffffc0202db2 <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0202c6e:	00659693          	slli	a3,a1,0x6
ffffffffc0202c72:	96aa                	add	a3,a3,a0
ffffffffc0202c74:	87aa                	mv	a5,a0
ffffffffc0202c76:	02d50263          	beq	a0,a3,ffffffffc0202c9a <default_free_pages+0x34>
ffffffffc0202c7a:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202c7c:	8b05                	andi	a4,a4,1
ffffffffc0202c7e:	10071a63          	bnez	a4,ffffffffc0202d92 <default_free_pages+0x12c>
ffffffffc0202c82:	6798                	ld	a4,8(a5)
ffffffffc0202c84:	8b09                	andi	a4,a4,2
ffffffffc0202c86:	10071663          	bnez	a4,ffffffffc0202d92 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0202c8a:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0202c8e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202c92:	04078793          	addi	a5,a5,64
ffffffffc0202c96:	fed792e3          	bne	a5,a3,ffffffffc0202c7a <default_free_pages+0x14>
    base->property = n;
ffffffffc0202c9a:	2581                	sext.w	a1,a1
ffffffffc0202c9c:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0202c9e:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202ca2:	4789                	li	a5,2
ffffffffc0202ca4:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0202ca8:	0000f697          	auipc	a3,0xf
ffffffffc0202cac:	85868693          	addi	a3,a3,-1960 # ffffffffc0211500 <free_area>
ffffffffc0202cb0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202cb2:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202cb4:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0202cb8:	9db9                	addw	a1,a1,a4
ffffffffc0202cba:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202cbc:	0ad78463          	beq	a5,a3,ffffffffc0202d64 <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc0202cc0:	fe878713          	addi	a4,a5,-24
ffffffffc0202cc4:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202cc8:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202cca:	00e56a63          	bltu	a0,a4,ffffffffc0202cde <default_free_pages+0x78>
    return listelm->next;
ffffffffc0202cce:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202cd0:	04d70c63          	beq	a4,a3,ffffffffc0202d28 <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc0202cd4:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202cd6:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0202cda:	fee57ae3          	bgeu	a0,a4,ffffffffc0202cce <default_free_pages+0x68>
ffffffffc0202cde:	c199                	beqz	a1,ffffffffc0202ce4 <default_free_pages+0x7e>
ffffffffc0202ce0:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202ce4:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0202ce6:	e390                	sd	a2,0(a5)
ffffffffc0202ce8:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202cea:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202cec:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0202cee:	00d70d63          	beq	a4,a3,ffffffffc0202d08 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc0202cf2:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0202cf6:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0202cfa:	02059813          	slli	a6,a1,0x20
ffffffffc0202cfe:	01a85793          	srli	a5,a6,0x1a
ffffffffc0202d02:	97b2                	add	a5,a5,a2
ffffffffc0202d04:	02f50c63          	beq	a0,a5,ffffffffc0202d3c <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0202d08:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0202d0a:	00d78c63          	beq	a5,a3,ffffffffc0202d22 <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0202d0e:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0202d10:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc0202d14:	02061593          	slli	a1,a2,0x20
ffffffffc0202d18:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0202d1c:	972a                	add	a4,a4,a0
ffffffffc0202d1e:	04e68a63          	beq	a3,a4,ffffffffc0202d72 <default_free_pages+0x10c>
}
ffffffffc0202d22:	60a2                	ld	ra,8(sp)
ffffffffc0202d24:	0141                	addi	sp,sp,16
ffffffffc0202d26:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202d28:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202d2a:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0202d2c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202d2e:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202d30:	02d70763          	beq	a4,a3,ffffffffc0202d5e <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0202d34:	8832                	mv	a6,a2
ffffffffc0202d36:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0202d38:	87ba                	mv	a5,a4
ffffffffc0202d3a:	bf71                	j	ffffffffc0202cd6 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0202d3c:	491c                	lw	a5,16(a0)
ffffffffc0202d3e:	9dbd                	addw	a1,a1,a5
ffffffffc0202d40:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202d44:	57f5                	li	a5,-3
ffffffffc0202d46:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202d4a:	01853803          	ld	a6,24(a0)
ffffffffc0202d4e:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0202d50:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0202d52:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0202d56:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0202d58:	0105b023          	sd	a6,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0202d5c:	b77d                	j	ffffffffc0202d0a <default_free_pages+0xa4>
ffffffffc0202d5e:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202d60:	873e                	mv	a4,a5
ffffffffc0202d62:	bf41                	j	ffffffffc0202cf2 <default_free_pages+0x8c>
}
ffffffffc0202d64:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202d66:	e390                	sd	a2,0(a5)
ffffffffc0202d68:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202d6a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202d6c:	ed1c                	sd	a5,24(a0)
ffffffffc0202d6e:	0141                	addi	sp,sp,16
ffffffffc0202d70:	8082                	ret
            base->property += p->property;
ffffffffc0202d72:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202d76:	ff078693          	addi	a3,a5,-16
ffffffffc0202d7a:	9e39                	addw	a2,a2,a4
ffffffffc0202d7c:	c910                	sw	a2,16(a0)
ffffffffc0202d7e:	5775                	li	a4,-3
ffffffffc0202d80:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202d84:	6398                	ld	a4,0(a5)
ffffffffc0202d86:	679c                	ld	a5,8(a5)
}
ffffffffc0202d88:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0202d8a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202d8c:	e398                	sd	a4,0(a5)
ffffffffc0202d8e:	0141                	addi	sp,sp,16
ffffffffc0202d90:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202d92:	00003697          	auipc	a3,0x3
ffffffffc0202d96:	7ce68693          	addi	a3,a3,1998 # ffffffffc0206560 <commands+0x1430>
ffffffffc0202d9a:	00003617          	auipc	a2,0x3
ffffffffc0202d9e:	abe60613          	addi	a2,a2,-1346 # ffffffffc0205858 <commands+0x728>
ffffffffc0202da2:	08300593          	li	a1,131
ffffffffc0202da6:	00003517          	auipc	a0,0x3
ffffffffc0202daa:	4a250513          	addi	a0,a0,1186 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202dae:	c26fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(n > 0);
ffffffffc0202db2:	00003697          	auipc	a3,0x3
ffffffffc0202db6:	7a668693          	addi	a3,a3,1958 # ffffffffc0206558 <commands+0x1428>
ffffffffc0202dba:	00003617          	auipc	a2,0x3
ffffffffc0202dbe:	a9e60613          	addi	a2,a2,-1378 # ffffffffc0205858 <commands+0x728>
ffffffffc0202dc2:	08000593          	li	a1,128
ffffffffc0202dc6:	00003517          	auipc	a0,0x3
ffffffffc0202dca:	48250513          	addi	a0,a0,1154 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202dce:	c06fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0202dd2 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0202dd2:	c941                	beqz	a0,ffffffffc0202e62 <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc0202dd4:	0000e597          	auipc	a1,0xe
ffffffffc0202dd8:	72c58593          	addi	a1,a1,1836 # ffffffffc0211500 <free_area>
ffffffffc0202ddc:	0105a803          	lw	a6,16(a1)
ffffffffc0202de0:	872a                	mv	a4,a0
ffffffffc0202de2:	02081793          	slli	a5,a6,0x20
ffffffffc0202de6:	9381                	srli	a5,a5,0x20
ffffffffc0202de8:	00a7ee63          	bltu	a5,a0,ffffffffc0202e04 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0202dec:	87ae                	mv	a5,a1
ffffffffc0202dee:	a801                	j	ffffffffc0202dfe <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0202df0:	ff87a683          	lw	a3,-8(a5)
ffffffffc0202df4:	02069613          	slli	a2,a3,0x20
ffffffffc0202df8:	9201                	srli	a2,a2,0x20
ffffffffc0202dfa:	00e67763          	bgeu	a2,a4,ffffffffc0202e08 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0202dfe:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202e00:	feb798e3          	bne	a5,a1,ffffffffc0202df0 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0202e04:	4501                	li	a0,0
}
ffffffffc0202e06:	8082                	ret
    return listelm->prev;
ffffffffc0202e08:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202e0c:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0202e10:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0202e14:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0202e18:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0202e1c:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0202e20:	02c77863          	bgeu	a4,a2,ffffffffc0202e50 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0202e24:	071a                	slli	a4,a4,0x6
ffffffffc0202e26:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0202e28:	41c686bb          	subw	a3,a3,t3
ffffffffc0202e2c:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202e2e:	00870613          	addi	a2,a4,8
ffffffffc0202e32:	4689                	li	a3,2
ffffffffc0202e34:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0202e38:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0202e3c:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0202e40:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0202e44:	e290                	sd	a2,0(a3)
ffffffffc0202e46:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0202e4a:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0202e4c:	01173c23          	sd	a7,24(a4)
ffffffffc0202e50:	41c8083b          	subw	a6,a6,t3
ffffffffc0202e54:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202e58:	5775                	li	a4,-3
ffffffffc0202e5a:	17c1                	addi	a5,a5,-16
ffffffffc0202e5c:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0202e60:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0202e62:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202e64:	00003697          	auipc	a3,0x3
ffffffffc0202e68:	6f468693          	addi	a3,a3,1780 # ffffffffc0206558 <commands+0x1428>
ffffffffc0202e6c:	00003617          	auipc	a2,0x3
ffffffffc0202e70:	9ec60613          	addi	a2,a2,-1556 # ffffffffc0205858 <commands+0x728>
ffffffffc0202e74:	06200593          	li	a1,98
ffffffffc0202e78:	00003517          	auipc	a0,0x3
ffffffffc0202e7c:	3d050513          	addi	a0,a0,976 # ffffffffc0206248 <commands+0x1118>
default_alloc_pages(size_t n) {
ffffffffc0202e80:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202e82:	b52fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0202e86 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0202e86:	1141                	addi	sp,sp,-16
ffffffffc0202e88:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202e8a:	c5f1                	beqz	a1,ffffffffc0202f56 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0202e8c:	00659693          	slli	a3,a1,0x6
ffffffffc0202e90:	96aa                	add	a3,a3,a0
ffffffffc0202e92:	87aa                	mv	a5,a0
ffffffffc0202e94:	00d50f63          	beq	a0,a3,ffffffffc0202eb2 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202e98:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0202e9a:	8b05                	andi	a4,a4,1
ffffffffc0202e9c:	cf49                	beqz	a4,ffffffffc0202f36 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0202e9e:	0007a823          	sw	zero,16(a5)
ffffffffc0202ea2:	0007b423          	sd	zero,8(a5)
ffffffffc0202ea6:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202eaa:	04078793          	addi	a5,a5,64
ffffffffc0202eae:	fed795e3          	bne	a5,a3,ffffffffc0202e98 <default_init_memmap+0x12>
    base->property = n;
ffffffffc0202eb2:	2581                	sext.w	a1,a1
ffffffffc0202eb4:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202eb6:	4789                	li	a5,2
ffffffffc0202eb8:	00850713          	addi	a4,a0,8
ffffffffc0202ebc:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0202ec0:	0000e697          	auipc	a3,0xe
ffffffffc0202ec4:	64068693          	addi	a3,a3,1600 # ffffffffc0211500 <free_area>
ffffffffc0202ec8:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202eca:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202ecc:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0202ed0:	9db9                	addw	a1,a1,a4
ffffffffc0202ed2:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202ed4:	04d78a63          	beq	a5,a3,ffffffffc0202f28 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0202ed8:	fe878713          	addi	a4,a5,-24
ffffffffc0202edc:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202ee0:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202ee2:	00e56a63          	bltu	a0,a4,ffffffffc0202ef6 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0202ee6:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202ee8:	02d70263          	beq	a4,a3,ffffffffc0202f0c <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0202eec:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202eee:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0202ef2:	fee57ae3          	bgeu	a0,a4,ffffffffc0202ee6 <default_init_memmap+0x60>
ffffffffc0202ef6:	c199                	beqz	a1,ffffffffc0202efc <default_init_memmap+0x76>
ffffffffc0202ef8:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202efc:	6398                	ld	a4,0(a5)
}
ffffffffc0202efe:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202f00:	e390                	sd	a2,0(a5)
ffffffffc0202f02:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202f04:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202f06:	ed18                	sd	a4,24(a0)
ffffffffc0202f08:	0141                	addi	sp,sp,16
ffffffffc0202f0a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202f0c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202f0e:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0202f10:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202f12:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202f14:	00d70663          	beq	a4,a3,ffffffffc0202f20 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0202f18:	8832                	mv	a6,a2
ffffffffc0202f1a:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0202f1c:	87ba                	mv	a5,a4
ffffffffc0202f1e:	bfc1                	j	ffffffffc0202eee <default_init_memmap+0x68>
}
ffffffffc0202f20:	60a2                	ld	ra,8(sp)
ffffffffc0202f22:	e290                	sd	a2,0(a3)
ffffffffc0202f24:	0141                	addi	sp,sp,16
ffffffffc0202f26:	8082                	ret
ffffffffc0202f28:	60a2                	ld	ra,8(sp)
ffffffffc0202f2a:	e390                	sd	a2,0(a5)
ffffffffc0202f2c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202f2e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202f30:	ed1c                	sd	a5,24(a0)
ffffffffc0202f32:	0141                	addi	sp,sp,16
ffffffffc0202f34:	8082                	ret
        assert(PageReserved(p));
ffffffffc0202f36:	00003697          	auipc	a3,0x3
ffffffffc0202f3a:	65268693          	addi	a3,a3,1618 # ffffffffc0206588 <commands+0x1458>
ffffffffc0202f3e:	00003617          	auipc	a2,0x3
ffffffffc0202f42:	91a60613          	addi	a2,a2,-1766 # ffffffffc0205858 <commands+0x728>
ffffffffc0202f46:	04900593          	li	a1,73
ffffffffc0202f4a:	00003517          	auipc	a0,0x3
ffffffffc0202f4e:	2fe50513          	addi	a0,a0,766 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202f52:	a82fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(n > 0);
ffffffffc0202f56:	00003697          	auipc	a3,0x3
ffffffffc0202f5a:	60268693          	addi	a3,a3,1538 # ffffffffc0206558 <commands+0x1428>
ffffffffc0202f5e:	00003617          	auipc	a2,0x3
ffffffffc0202f62:	8fa60613          	addi	a2,a2,-1798 # ffffffffc0205858 <commands+0x728>
ffffffffc0202f66:	04600593          	li	a1,70
ffffffffc0202f6a:	00003517          	auipc	a0,0x3
ffffffffc0202f6e:	2de50513          	addi	a0,a0,734 # ffffffffc0206248 <commands+0x1118>
ffffffffc0202f72:	a62fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0202f76 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0202f76:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202f78:	00003617          	auipc	a2,0x3
ffffffffc0202f7c:	b0860613          	addi	a2,a2,-1272 # ffffffffc0205a80 <commands+0x950>
ffffffffc0202f80:	06200593          	li	a1,98
ffffffffc0202f84:	00003517          	auipc	a0,0x3
ffffffffc0202f88:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0205aa0 <commands+0x970>
pa2page(uintptr_t pa) {
ffffffffc0202f8c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202f8e:	a46fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0202f92 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc0202f92:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0202f94:	00003617          	auipc	a2,0x3
ffffffffc0202f98:	10460613          	addi	a2,a2,260 # ffffffffc0206098 <commands+0xf68>
ffffffffc0202f9c:	07400593          	li	a1,116
ffffffffc0202fa0:	00003517          	auipc	a0,0x3
ffffffffc0202fa4:	b0050513          	addi	a0,a0,-1280 # ffffffffc0205aa0 <commands+0x970>
pte2page(pte_t pte) {
ffffffffc0202fa8:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0202faa:	a2afd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0202fae <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0202fae:	7139                	addi	sp,sp,-64
ffffffffc0202fb0:	f426                	sd	s1,40(sp)
ffffffffc0202fb2:	f04a                	sd	s2,32(sp)
ffffffffc0202fb4:	ec4e                	sd	s3,24(sp)
ffffffffc0202fb6:	e852                	sd	s4,16(sp)
ffffffffc0202fb8:	e456                	sd	s5,8(sp)
ffffffffc0202fba:	e05a                	sd	s6,0(sp)
ffffffffc0202fbc:	fc06                	sd	ra,56(sp)
ffffffffc0202fbe:	f822                	sd	s0,48(sp)
ffffffffc0202fc0:	84aa                	mv	s1,a0
ffffffffc0202fc2:	00012917          	auipc	s2,0x12
ffffffffc0202fc6:	5de90913          	addi	s2,s2,1502 # ffffffffc02155a0 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202fca:	4a05                	li	s4,1
ffffffffc0202fcc:	00012a97          	auipc	s5,0x12
ffffffffc0202fd0:	5aca8a93          	addi	s5,s5,1452 # ffffffffc0215578 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0202fd4:	0005099b          	sext.w	s3,a0
ffffffffc0202fd8:	00012b17          	auipc	s6,0x12
ffffffffc0202fdc:	578b0b13          	addi	s6,s6,1400 # ffffffffc0215550 <check_mm_struct>
ffffffffc0202fe0:	a01d                	j	ffffffffc0203006 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0202fe2:	00093783          	ld	a5,0(s2)
ffffffffc0202fe6:	6f9c                	ld	a5,24(a5)
ffffffffc0202fe8:	9782                	jalr	a5
ffffffffc0202fea:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0202fec:	4601                	li	a2,0
ffffffffc0202fee:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202ff0:	ec0d                	bnez	s0,ffffffffc020302a <alloc_pages+0x7c>
ffffffffc0202ff2:	029a6c63          	bltu	s4,s1,ffffffffc020302a <alloc_pages+0x7c>
ffffffffc0202ff6:	000aa783          	lw	a5,0(s5)
ffffffffc0202ffa:	2781                	sext.w	a5,a5
ffffffffc0202ffc:	c79d                	beqz	a5,ffffffffc020302a <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202ffe:	000b3503          	ld	a0,0(s6)
ffffffffc0203002:	b38ff0ef          	jal	ra,ffffffffc020233a <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203006:	100027f3          	csrr	a5,sstatus
ffffffffc020300a:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc020300c:	8526                	mv	a0,s1
ffffffffc020300e:	dbf1                	beqz	a5,ffffffffc0202fe2 <alloc_pages+0x34>
        intr_disable();
ffffffffc0203010:	dc0fd0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc0203014:	00093783          	ld	a5,0(s2)
ffffffffc0203018:	8526                	mv	a0,s1
ffffffffc020301a:	6f9c                	ld	a5,24(a5)
ffffffffc020301c:	9782                	jalr	a5
ffffffffc020301e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203020:	daafd0ef          	jal	ra,ffffffffc02005ca <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0203024:	4601                	li	a2,0
ffffffffc0203026:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0203028:	d469                	beqz	s0,ffffffffc0202ff2 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020302a:	70e2                	ld	ra,56(sp)
ffffffffc020302c:	8522                	mv	a0,s0
ffffffffc020302e:	7442                	ld	s0,48(sp)
ffffffffc0203030:	74a2                	ld	s1,40(sp)
ffffffffc0203032:	7902                	ld	s2,32(sp)
ffffffffc0203034:	69e2                	ld	s3,24(sp)
ffffffffc0203036:	6a42                	ld	s4,16(sp)
ffffffffc0203038:	6aa2                	ld	s5,8(sp)
ffffffffc020303a:	6b02                	ld	s6,0(sp)
ffffffffc020303c:	6121                	addi	sp,sp,64
ffffffffc020303e:	8082                	ret

ffffffffc0203040 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203040:	100027f3          	csrr	a5,sstatus
ffffffffc0203044:	8b89                	andi	a5,a5,2
ffffffffc0203046:	e799                	bnez	a5,ffffffffc0203054 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0203048:	00012797          	auipc	a5,0x12
ffffffffc020304c:	5587b783          	ld	a5,1368(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc0203050:	739c                	ld	a5,32(a5)
ffffffffc0203052:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0203054:	1101                	addi	sp,sp,-32
ffffffffc0203056:	ec06                	sd	ra,24(sp)
ffffffffc0203058:	e822                	sd	s0,16(sp)
ffffffffc020305a:	e426                	sd	s1,8(sp)
ffffffffc020305c:	842a                	mv	s0,a0
ffffffffc020305e:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0203060:	d70fd0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203064:	00012797          	auipc	a5,0x12
ffffffffc0203068:	53c7b783          	ld	a5,1340(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc020306c:	739c                	ld	a5,32(a5)
ffffffffc020306e:	85a6                	mv	a1,s1
ffffffffc0203070:	8522                	mv	a0,s0
ffffffffc0203072:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0203074:	6442                	ld	s0,16(sp)
ffffffffc0203076:	60e2                	ld	ra,24(sp)
ffffffffc0203078:	64a2                	ld	s1,8(sp)
ffffffffc020307a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020307c:	d4efd06f          	j	ffffffffc02005ca <intr_enable>

ffffffffc0203080 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203080:	100027f3          	csrr	a5,sstatus
ffffffffc0203084:	8b89                	andi	a5,a5,2
ffffffffc0203086:	e799                	bnez	a5,ffffffffc0203094 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0203088:	00012797          	auipc	a5,0x12
ffffffffc020308c:	5187b783          	ld	a5,1304(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc0203090:	779c                	ld	a5,40(a5)
ffffffffc0203092:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0203094:	1141                	addi	sp,sp,-16
ffffffffc0203096:	e406                	sd	ra,8(sp)
ffffffffc0203098:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020309a:	d36fd0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020309e:	00012797          	auipc	a5,0x12
ffffffffc02030a2:	5027b783          	ld	a5,1282(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc02030a6:	779c                	ld	a5,40(a5)
ffffffffc02030a8:	9782                	jalr	a5
ffffffffc02030aa:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02030ac:	d1efd0ef          	jal	ra,ffffffffc02005ca <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02030b0:	60a2                	ld	ra,8(sp)
ffffffffc02030b2:	8522                	mv	a0,s0
ffffffffc02030b4:	6402                	ld	s0,0(sp)
ffffffffc02030b6:	0141                	addi	sp,sp,16
ffffffffc02030b8:	8082                	ret

ffffffffc02030ba <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02030ba:	01e5d793          	srli	a5,a1,0x1e
ffffffffc02030be:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02030c2:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02030c4:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02030c6:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02030c8:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc02030cc:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02030ce:	f04a                	sd	s2,32(sp)
ffffffffc02030d0:	ec4e                	sd	s3,24(sp)
ffffffffc02030d2:	e852                	sd	s4,16(sp)
ffffffffc02030d4:	fc06                	sd	ra,56(sp)
ffffffffc02030d6:	f822                	sd	s0,48(sp)
ffffffffc02030d8:	e456                	sd	s5,8(sp)
ffffffffc02030da:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02030dc:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02030e0:	892e                	mv	s2,a1
ffffffffc02030e2:	89b2                	mv	s3,a2
ffffffffc02030e4:	00012a17          	auipc	s4,0x12
ffffffffc02030e8:	4aca0a13          	addi	s4,s4,1196 # ffffffffc0215590 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc02030ec:	e7b5                	bnez	a5,ffffffffc0203158 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02030ee:	12060b63          	beqz	a2,ffffffffc0203224 <get_pte+0x16a>
ffffffffc02030f2:	4505                	li	a0,1
ffffffffc02030f4:	ebbff0ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc02030f8:	842a                	mv	s0,a0
ffffffffc02030fa:	12050563          	beqz	a0,ffffffffc0203224 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc02030fe:	00012b17          	auipc	s6,0x12
ffffffffc0203102:	49ab0b13          	addi	s6,s6,1178 # ffffffffc0215598 <pages>
ffffffffc0203106:	000b3503          	ld	a0,0(s6)
ffffffffc020310a:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020310e:	00012a17          	auipc	s4,0x12
ffffffffc0203112:	482a0a13          	addi	s4,s4,1154 # ffffffffc0215590 <npage>
ffffffffc0203116:	40a40533          	sub	a0,s0,a0
ffffffffc020311a:	8519                	srai	a0,a0,0x6
ffffffffc020311c:	9556                	add	a0,a0,s5
ffffffffc020311e:	000a3703          	ld	a4,0(s4)
ffffffffc0203122:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0203126:	4685                	li	a3,1
ffffffffc0203128:	c014                	sw	a3,0(s0)
ffffffffc020312a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020312c:	0532                	slli	a0,a0,0xc
ffffffffc020312e:	14e7f263          	bgeu	a5,a4,ffffffffc0203272 <get_pte+0x1b8>
ffffffffc0203132:	00012797          	auipc	a5,0x12
ffffffffc0203136:	4767b783          	ld	a5,1142(a5) # ffffffffc02155a8 <va_pa_offset>
ffffffffc020313a:	6605                	lui	a2,0x1
ffffffffc020313c:	4581                	li	a1,0
ffffffffc020313e:	953e                	add	a0,a0,a5
ffffffffc0203140:	0df010ef          	jal	ra,ffffffffc0204a1e <memset>
    return page - pages + nbase;
ffffffffc0203144:	000b3683          	ld	a3,0(s6)
ffffffffc0203148:	40d406b3          	sub	a3,s0,a3
ffffffffc020314c:	8699                	srai	a3,a3,0x6
ffffffffc020314e:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203150:	06aa                	slli	a3,a3,0xa
ffffffffc0203152:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0203156:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0203158:	77fd                	lui	a5,0xfffff
ffffffffc020315a:	068a                	slli	a3,a3,0x2
ffffffffc020315c:	000a3703          	ld	a4,0(s4)
ffffffffc0203160:	8efd                	and	a3,a3,a5
ffffffffc0203162:	00c6d793          	srli	a5,a3,0xc
ffffffffc0203166:	0ce7f163          	bgeu	a5,a4,ffffffffc0203228 <get_pte+0x16e>
ffffffffc020316a:	00012a97          	auipc	s5,0x12
ffffffffc020316e:	43ea8a93          	addi	s5,s5,1086 # ffffffffc02155a8 <va_pa_offset>
ffffffffc0203172:	000ab403          	ld	s0,0(s5)
ffffffffc0203176:	01595793          	srli	a5,s2,0x15
ffffffffc020317a:	1ff7f793          	andi	a5,a5,511
ffffffffc020317e:	96a2                	add	a3,a3,s0
ffffffffc0203180:	00379413          	slli	s0,a5,0x3
ffffffffc0203184:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0203186:	6014                	ld	a3,0(s0)
ffffffffc0203188:	0016f793          	andi	a5,a3,1
ffffffffc020318c:	e3ad                	bnez	a5,ffffffffc02031ee <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc020318e:	08098b63          	beqz	s3,ffffffffc0203224 <get_pte+0x16a>
ffffffffc0203192:	4505                	li	a0,1
ffffffffc0203194:	e1bff0ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc0203198:	84aa                	mv	s1,a0
ffffffffc020319a:	c549                	beqz	a0,ffffffffc0203224 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc020319c:	00012b17          	auipc	s6,0x12
ffffffffc02031a0:	3fcb0b13          	addi	s6,s6,1020 # ffffffffc0215598 <pages>
ffffffffc02031a4:	000b3503          	ld	a0,0(s6)
ffffffffc02031a8:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02031ac:	000a3703          	ld	a4,0(s4)
ffffffffc02031b0:	40a48533          	sub	a0,s1,a0
ffffffffc02031b4:	8519                	srai	a0,a0,0x6
ffffffffc02031b6:	954e                	add	a0,a0,s3
ffffffffc02031b8:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc02031bc:	4685                	li	a3,1
ffffffffc02031be:	c094                	sw	a3,0(s1)
ffffffffc02031c0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02031c2:	0532                	slli	a0,a0,0xc
ffffffffc02031c4:	08e7fa63          	bgeu	a5,a4,ffffffffc0203258 <get_pte+0x19e>
ffffffffc02031c8:	000ab783          	ld	a5,0(s5)
ffffffffc02031cc:	6605                	lui	a2,0x1
ffffffffc02031ce:	4581                	li	a1,0
ffffffffc02031d0:	953e                	add	a0,a0,a5
ffffffffc02031d2:	04d010ef          	jal	ra,ffffffffc0204a1e <memset>
    return page - pages + nbase;
ffffffffc02031d6:	000b3683          	ld	a3,0(s6)
ffffffffc02031da:	40d486b3          	sub	a3,s1,a3
ffffffffc02031de:	8699                	srai	a3,a3,0x6
ffffffffc02031e0:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02031e2:	06aa                	slli	a3,a3,0xa
ffffffffc02031e4:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02031e8:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02031ea:	000a3703          	ld	a4,0(s4)
ffffffffc02031ee:	068a                	slli	a3,a3,0x2
ffffffffc02031f0:	757d                	lui	a0,0xfffff
ffffffffc02031f2:	8ee9                	and	a3,a3,a0
ffffffffc02031f4:	00c6d793          	srli	a5,a3,0xc
ffffffffc02031f8:	04e7f463          	bgeu	a5,a4,ffffffffc0203240 <get_pte+0x186>
ffffffffc02031fc:	000ab503          	ld	a0,0(s5)
ffffffffc0203200:	00c95913          	srli	s2,s2,0xc
ffffffffc0203204:	1ff97913          	andi	s2,s2,511
ffffffffc0203208:	96aa                	add	a3,a3,a0
ffffffffc020320a:	00391513          	slli	a0,s2,0x3
ffffffffc020320e:	9536                	add	a0,a0,a3
}
ffffffffc0203210:	70e2                	ld	ra,56(sp)
ffffffffc0203212:	7442                	ld	s0,48(sp)
ffffffffc0203214:	74a2                	ld	s1,40(sp)
ffffffffc0203216:	7902                	ld	s2,32(sp)
ffffffffc0203218:	69e2                	ld	s3,24(sp)
ffffffffc020321a:	6a42                	ld	s4,16(sp)
ffffffffc020321c:	6aa2                	ld	s5,8(sp)
ffffffffc020321e:	6b02                	ld	s6,0(sp)
ffffffffc0203220:	6121                	addi	sp,sp,64
ffffffffc0203222:	8082                	ret
            return NULL;
ffffffffc0203224:	4501                	li	a0,0
ffffffffc0203226:	b7ed                	j	ffffffffc0203210 <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0203228:	00003617          	auipc	a2,0x3
ffffffffc020322c:	88860613          	addi	a2,a2,-1912 # ffffffffc0205ab0 <commands+0x980>
ffffffffc0203230:	0e400593          	li	a1,228
ffffffffc0203234:	00003517          	auipc	a0,0x3
ffffffffc0203238:	3b450513          	addi	a0,a0,948 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc020323c:	f99fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0203240:	00003617          	auipc	a2,0x3
ffffffffc0203244:	87060613          	addi	a2,a2,-1936 # ffffffffc0205ab0 <commands+0x980>
ffffffffc0203248:	0ef00593          	li	a1,239
ffffffffc020324c:	00003517          	auipc	a0,0x3
ffffffffc0203250:	39c50513          	addi	a0,a0,924 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203254:	f81fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203258:	86aa                	mv	a3,a0
ffffffffc020325a:	00003617          	auipc	a2,0x3
ffffffffc020325e:	85660613          	addi	a2,a2,-1962 # ffffffffc0205ab0 <commands+0x980>
ffffffffc0203262:	0ec00593          	li	a1,236
ffffffffc0203266:	00003517          	auipc	a0,0x3
ffffffffc020326a:	38250513          	addi	a0,a0,898 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc020326e:	f67fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203272:	86aa                	mv	a3,a0
ffffffffc0203274:	00003617          	auipc	a2,0x3
ffffffffc0203278:	83c60613          	addi	a2,a2,-1988 # ffffffffc0205ab0 <commands+0x980>
ffffffffc020327c:	0e100593          	li	a1,225
ffffffffc0203280:	00003517          	auipc	a0,0x3
ffffffffc0203284:	36850513          	addi	a0,a0,872 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203288:	f4dfc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc020328c <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020328c:	1141                	addi	sp,sp,-16
ffffffffc020328e:	e022                	sd	s0,0(sp)
ffffffffc0203290:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203292:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0203294:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203296:	e25ff0ef          	jal	ra,ffffffffc02030ba <get_pte>
    if (ptep_store != NULL) {
ffffffffc020329a:	c011                	beqz	s0,ffffffffc020329e <get_page+0x12>
        *ptep_store = ptep;
ffffffffc020329c:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020329e:	c511                	beqz	a0,ffffffffc02032aa <get_page+0x1e>
ffffffffc02032a0:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02032a2:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02032a4:	0017f713          	andi	a4,a5,1
ffffffffc02032a8:	e709                	bnez	a4,ffffffffc02032b2 <get_page+0x26>
}
ffffffffc02032aa:	60a2                	ld	ra,8(sp)
ffffffffc02032ac:	6402                	ld	s0,0(sp)
ffffffffc02032ae:	0141                	addi	sp,sp,16
ffffffffc02032b0:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02032b2:	078a                	slli	a5,a5,0x2
ffffffffc02032b4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02032b6:	00012717          	auipc	a4,0x12
ffffffffc02032ba:	2da73703          	ld	a4,730(a4) # ffffffffc0215590 <npage>
ffffffffc02032be:	00e7ff63          	bgeu	a5,a4,ffffffffc02032dc <get_page+0x50>
ffffffffc02032c2:	60a2                	ld	ra,8(sp)
ffffffffc02032c4:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc02032c6:	fff80537          	lui	a0,0xfff80
ffffffffc02032ca:	97aa                	add	a5,a5,a0
ffffffffc02032cc:	079a                	slli	a5,a5,0x6
ffffffffc02032ce:	00012517          	auipc	a0,0x12
ffffffffc02032d2:	2ca53503          	ld	a0,714(a0) # ffffffffc0215598 <pages>
ffffffffc02032d6:	953e                	add	a0,a0,a5
ffffffffc02032d8:	0141                	addi	sp,sp,16
ffffffffc02032da:	8082                	ret
ffffffffc02032dc:	c9bff0ef          	jal	ra,ffffffffc0202f76 <pa2page.part.0>

ffffffffc02032e0 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02032e0:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02032e2:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02032e4:	ec26                	sd	s1,24(sp)
ffffffffc02032e6:	f406                	sd	ra,40(sp)
ffffffffc02032e8:	f022                	sd	s0,32(sp)
ffffffffc02032ea:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02032ec:	dcfff0ef          	jal	ra,ffffffffc02030ba <get_pte>
    if (ptep != NULL) {
ffffffffc02032f0:	c511                	beqz	a0,ffffffffc02032fc <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02032f2:	611c                	ld	a5,0(a0)
ffffffffc02032f4:	842a                	mv	s0,a0
ffffffffc02032f6:	0017f713          	andi	a4,a5,1
ffffffffc02032fa:	e711                	bnez	a4,ffffffffc0203306 <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc02032fc:	70a2                	ld	ra,40(sp)
ffffffffc02032fe:	7402                	ld	s0,32(sp)
ffffffffc0203300:	64e2                	ld	s1,24(sp)
ffffffffc0203302:	6145                	addi	sp,sp,48
ffffffffc0203304:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203306:	078a                	slli	a5,a5,0x2
ffffffffc0203308:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020330a:	00012717          	auipc	a4,0x12
ffffffffc020330e:	28673703          	ld	a4,646(a4) # ffffffffc0215590 <npage>
ffffffffc0203312:	06e7f363          	bgeu	a5,a4,ffffffffc0203378 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0203316:	fff80537          	lui	a0,0xfff80
ffffffffc020331a:	97aa                	add	a5,a5,a0
ffffffffc020331c:	079a                	slli	a5,a5,0x6
ffffffffc020331e:	00012517          	auipc	a0,0x12
ffffffffc0203322:	27a53503          	ld	a0,634(a0) # ffffffffc0215598 <pages>
ffffffffc0203326:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0203328:	411c                	lw	a5,0(a0)
ffffffffc020332a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020332e:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203330:	cb11                	beqz	a4,ffffffffc0203344 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203332:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203336:	12048073          	sfence.vma	s1
}
ffffffffc020333a:	70a2                	ld	ra,40(sp)
ffffffffc020333c:	7402                	ld	s0,32(sp)
ffffffffc020333e:	64e2                	ld	s1,24(sp)
ffffffffc0203340:	6145                	addi	sp,sp,48
ffffffffc0203342:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203344:	100027f3          	csrr	a5,sstatus
ffffffffc0203348:	8b89                	andi	a5,a5,2
ffffffffc020334a:	eb89                	bnez	a5,ffffffffc020335c <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc020334c:	00012797          	auipc	a5,0x12
ffffffffc0203350:	2547b783          	ld	a5,596(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc0203354:	739c                	ld	a5,32(a5)
ffffffffc0203356:	4585                	li	a1,1
ffffffffc0203358:	9782                	jalr	a5
    if (flag) {
ffffffffc020335a:	bfe1                	j	ffffffffc0203332 <page_remove+0x52>
        intr_disable();
ffffffffc020335c:	e42a                	sd	a0,8(sp)
ffffffffc020335e:	a72fd0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc0203362:	00012797          	auipc	a5,0x12
ffffffffc0203366:	23e7b783          	ld	a5,574(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc020336a:	739c                	ld	a5,32(a5)
ffffffffc020336c:	6522                	ld	a0,8(sp)
ffffffffc020336e:	4585                	li	a1,1
ffffffffc0203370:	9782                	jalr	a5
        intr_enable();
ffffffffc0203372:	a58fd0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0203376:	bf75                	j	ffffffffc0203332 <page_remove+0x52>
ffffffffc0203378:	bffff0ef          	jal	ra,ffffffffc0202f76 <pa2page.part.0>

ffffffffc020337c <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020337c:	7139                	addi	sp,sp,-64
ffffffffc020337e:	e852                	sd	s4,16(sp)
ffffffffc0203380:	8a32                	mv	s4,a2
ffffffffc0203382:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203384:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203386:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203388:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020338a:	f426                	sd	s1,40(sp)
ffffffffc020338c:	fc06                	sd	ra,56(sp)
ffffffffc020338e:	f04a                	sd	s2,32(sp)
ffffffffc0203390:	ec4e                	sd	s3,24(sp)
ffffffffc0203392:	e456                	sd	s5,8(sp)
ffffffffc0203394:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203396:	d25ff0ef          	jal	ra,ffffffffc02030ba <get_pte>
    if (ptep == NULL) {
ffffffffc020339a:	c961                	beqz	a0,ffffffffc020346a <page_insert+0xee>
    page->ref += 1;
ffffffffc020339c:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc020339e:	611c                	ld	a5,0(a0)
ffffffffc02033a0:	89aa                	mv	s3,a0
ffffffffc02033a2:	0016871b          	addiw	a4,a3,1
ffffffffc02033a6:	c018                	sw	a4,0(s0)
ffffffffc02033a8:	0017f713          	andi	a4,a5,1
ffffffffc02033ac:	ef05                	bnez	a4,ffffffffc02033e4 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc02033ae:	00012717          	auipc	a4,0x12
ffffffffc02033b2:	1ea73703          	ld	a4,490(a4) # ffffffffc0215598 <pages>
ffffffffc02033b6:	8c19                	sub	s0,s0,a4
ffffffffc02033b8:	000807b7          	lui	a5,0x80
ffffffffc02033bc:	8419                	srai	s0,s0,0x6
ffffffffc02033be:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02033c0:	042a                	slli	s0,s0,0xa
ffffffffc02033c2:	8cc1                	or	s1,s1,s0
ffffffffc02033c4:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02033c8:	0099b023          	sd	s1,0(s3) # 80000 <kern_entry-0xffffffffc0180000>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02033cc:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc02033d0:	4501                	li	a0,0
}
ffffffffc02033d2:	70e2                	ld	ra,56(sp)
ffffffffc02033d4:	7442                	ld	s0,48(sp)
ffffffffc02033d6:	74a2                	ld	s1,40(sp)
ffffffffc02033d8:	7902                	ld	s2,32(sp)
ffffffffc02033da:	69e2                	ld	s3,24(sp)
ffffffffc02033dc:	6a42                	ld	s4,16(sp)
ffffffffc02033de:	6aa2                	ld	s5,8(sp)
ffffffffc02033e0:	6121                	addi	sp,sp,64
ffffffffc02033e2:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02033e4:	078a                	slli	a5,a5,0x2
ffffffffc02033e6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033e8:	00012717          	auipc	a4,0x12
ffffffffc02033ec:	1a873703          	ld	a4,424(a4) # ffffffffc0215590 <npage>
ffffffffc02033f0:	06e7ff63          	bgeu	a5,a4,ffffffffc020346e <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02033f4:	00012a97          	auipc	s5,0x12
ffffffffc02033f8:	1a4a8a93          	addi	s5,s5,420 # ffffffffc0215598 <pages>
ffffffffc02033fc:	000ab703          	ld	a4,0(s5)
ffffffffc0203400:	fff80937          	lui	s2,0xfff80
ffffffffc0203404:	993e                	add	s2,s2,a5
ffffffffc0203406:	091a                	slli	s2,s2,0x6
ffffffffc0203408:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc020340a:	01240c63          	beq	s0,s2,ffffffffc0203422 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc020340e:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fd6aa34>
ffffffffc0203412:	fff7869b          	addiw	a3,a5,-1
ffffffffc0203416:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc020341a:	c691                	beqz	a3,ffffffffc0203426 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020341c:	120a0073          	sfence.vma	s4
}
ffffffffc0203420:	bf59                	j	ffffffffc02033b6 <page_insert+0x3a>
ffffffffc0203422:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0203424:	bf49                	j	ffffffffc02033b6 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203426:	100027f3          	csrr	a5,sstatus
ffffffffc020342a:	8b89                	andi	a5,a5,2
ffffffffc020342c:	ef91                	bnez	a5,ffffffffc0203448 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc020342e:	00012797          	auipc	a5,0x12
ffffffffc0203432:	1727b783          	ld	a5,370(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc0203436:	739c                	ld	a5,32(a5)
ffffffffc0203438:	4585                	li	a1,1
ffffffffc020343a:	854a                	mv	a0,s2
ffffffffc020343c:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc020343e:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203442:	120a0073          	sfence.vma	s4
ffffffffc0203446:	bf85                	j	ffffffffc02033b6 <page_insert+0x3a>
        intr_disable();
ffffffffc0203448:	988fd0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020344c:	00012797          	auipc	a5,0x12
ffffffffc0203450:	1547b783          	ld	a5,340(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc0203454:	739c                	ld	a5,32(a5)
ffffffffc0203456:	4585                	li	a1,1
ffffffffc0203458:	854a                	mv	a0,s2
ffffffffc020345a:	9782                	jalr	a5
        intr_enable();
ffffffffc020345c:	96efd0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0203460:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203464:	120a0073          	sfence.vma	s4
ffffffffc0203468:	b7b9                	j	ffffffffc02033b6 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020346a:	5571                	li	a0,-4
ffffffffc020346c:	b79d                	j	ffffffffc02033d2 <page_insert+0x56>
ffffffffc020346e:	b09ff0ef          	jal	ra,ffffffffc0202f76 <pa2page.part.0>

ffffffffc0203472 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0203472:	00003797          	auipc	a5,0x3
ffffffffc0203476:	13e78793          	addi	a5,a5,318 # ffffffffc02065b0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020347a:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020347c:	711d                	addi	sp,sp,-96
ffffffffc020347e:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203480:	00003517          	auipc	a0,0x3
ffffffffc0203484:	17850513          	addi	a0,a0,376 # ffffffffc02065f8 <default_pmm_manager+0x48>
    pmm_manager = &default_pmm_manager;
ffffffffc0203488:	00012b97          	auipc	s7,0x12
ffffffffc020348c:	118b8b93          	addi	s7,s7,280 # ffffffffc02155a0 <pmm_manager>
void pmm_init(void) {
ffffffffc0203490:	ec86                	sd	ra,88(sp)
ffffffffc0203492:	e4a6                	sd	s1,72(sp)
ffffffffc0203494:	fc4e                	sd	s3,56(sp)
ffffffffc0203496:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0203498:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc020349c:	e8a2                	sd	s0,80(sp)
ffffffffc020349e:	e0ca                	sd	s2,64(sp)
ffffffffc02034a0:	f852                	sd	s4,48(sp)
ffffffffc02034a2:	f456                	sd	s5,40(sp)
ffffffffc02034a4:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02034a6:	c33fc0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    pmm_manager->init();
ffffffffc02034aa:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02034ae:	00012997          	auipc	s3,0x12
ffffffffc02034b2:	0fa98993          	addi	s3,s3,250 # ffffffffc02155a8 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc02034b6:	00012497          	auipc	s1,0x12
ffffffffc02034ba:	0da48493          	addi	s1,s1,218 # ffffffffc0215590 <npage>
    pmm_manager->init();
ffffffffc02034be:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02034c0:	00012b17          	auipc	s6,0x12
ffffffffc02034c4:	0d8b0b13          	addi	s6,s6,216 # ffffffffc0215598 <pages>
    pmm_manager->init();
ffffffffc02034c8:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02034ca:	57f5                	li	a5,-3
ffffffffc02034cc:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02034ce:	00003517          	auipc	a0,0x3
ffffffffc02034d2:	14250513          	addi	a0,a0,322 # ffffffffc0206610 <default_pmm_manager+0x60>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02034d6:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc02034da:	bfffc0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02034de:	46c5                	li	a3,17
ffffffffc02034e0:	06ee                	slli	a3,a3,0x1b
ffffffffc02034e2:	40100613          	li	a2,1025
ffffffffc02034e6:	07e005b7          	lui	a1,0x7e00
ffffffffc02034ea:	16fd                	addi	a3,a3,-1
ffffffffc02034ec:	0656                	slli	a2,a2,0x15
ffffffffc02034ee:	00003517          	auipc	a0,0x3
ffffffffc02034f2:	13a50513          	addi	a0,a0,314 # ffffffffc0206628 <default_pmm_manager+0x78>
ffffffffc02034f6:	be3fc0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02034fa:	777d                	lui	a4,0xfffff
ffffffffc02034fc:	00013797          	auipc	a5,0x13
ffffffffc0203500:	0cf78793          	addi	a5,a5,207 # ffffffffc02165cb <end+0xfff>
ffffffffc0203504:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0203506:	00088737          	lui	a4,0x88
ffffffffc020350a:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020350c:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203510:	4701                	li	a4,0
ffffffffc0203512:	4585                	li	a1,1
ffffffffc0203514:	fff80837          	lui	a6,0xfff80
ffffffffc0203518:	a019                	j	ffffffffc020351e <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc020351a:	000b3783          	ld	a5,0(s6)
ffffffffc020351e:	00671693          	slli	a3,a4,0x6
ffffffffc0203522:	97b6                	add	a5,a5,a3
ffffffffc0203524:	07a1                	addi	a5,a5,8
ffffffffc0203526:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020352a:	6090                	ld	a2,0(s1)
ffffffffc020352c:	0705                	addi	a4,a4,1
ffffffffc020352e:	010607b3          	add	a5,a2,a6
ffffffffc0203532:	fef764e3          	bltu	a4,a5,ffffffffc020351a <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203536:	000b3503          	ld	a0,0(s6)
ffffffffc020353a:	079a                	slli	a5,a5,0x6
ffffffffc020353c:	c0200737          	lui	a4,0xc0200
ffffffffc0203540:	00f506b3          	add	a3,a0,a5
ffffffffc0203544:	60e6e563          	bltu	a3,a4,ffffffffc0203b4e <pmm_init+0x6dc>
ffffffffc0203548:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc020354c:	4745                	li	a4,17
ffffffffc020354e:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203550:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0203552:	4ae6e563          	bltu	a3,a4,ffffffffc02039fc <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0203556:	00003517          	auipc	a0,0x3
ffffffffc020355a:	0fa50513          	addi	a0,a0,250 # ffffffffc0206650 <default_pmm_manager+0xa0>
ffffffffc020355e:	b7bfc0ef          	jal	ra,ffffffffc02000d8 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0203562:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203566:	00012917          	auipc	s2,0x12
ffffffffc020356a:	02290913          	addi	s2,s2,34 # ffffffffc0215588 <boot_pgdir>
    pmm_manager->check();
ffffffffc020356e:	7b9c                	ld	a5,48(a5)
ffffffffc0203570:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0203572:	00003517          	auipc	a0,0x3
ffffffffc0203576:	0f650513          	addi	a0,a0,246 # ffffffffc0206668 <default_pmm_manager+0xb8>
ffffffffc020357a:	b5ffc0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020357e:	00006697          	auipc	a3,0x6
ffffffffc0203582:	a8268693          	addi	a3,a3,-1406 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0203586:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020358a:	c02007b7          	lui	a5,0xc0200
ffffffffc020358e:	5cf6ec63          	bltu	a3,a5,ffffffffc0203b66 <pmm_init+0x6f4>
ffffffffc0203592:	0009b783          	ld	a5,0(s3)
ffffffffc0203596:	8e9d                	sub	a3,a3,a5
ffffffffc0203598:	00012797          	auipc	a5,0x12
ffffffffc020359c:	fed7b423          	sd	a3,-24(a5) # ffffffffc0215580 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02035a0:	100027f3          	csrr	a5,sstatus
ffffffffc02035a4:	8b89                	andi	a5,a5,2
ffffffffc02035a6:	48079263          	bnez	a5,ffffffffc0203a2a <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc02035aa:	000bb783          	ld	a5,0(s7)
ffffffffc02035ae:	779c                	ld	a5,40(a5)
ffffffffc02035b0:	9782                	jalr	a5
ffffffffc02035b2:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02035b4:	6098                	ld	a4,0(s1)
ffffffffc02035b6:	c80007b7          	lui	a5,0xc8000
ffffffffc02035ba:	83b1                	srli	a5,a5,0xc
ffffffffc02035bc:	5ee7e163          	bltu	a5,a4,ffffffffc0203b9e <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02035c0:	00093503          	ld	a0,0(s2)
ffffffffc02035c4:	5a050d63          	beqz	a0,ffffffffc0203b7e <pmm_init+0x70c>
ffffffffc02035c8:	03451793          	slli	a5,a0,0x34
ffffffffc02035cc:	5a079963          	bnez	a5,ffffffffc0203b7e <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02035d0:	4601                	li	a2,0
ffffffffc02035d2:	4581                	li	a1,0
ffffffffc02035d4:	cb9ff0ef          	jal	ra,ffffffffc020328c <get_page>
ffffffffc02035d8:	62051563          	bnez	a0,ffffffffc0203c02 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02035dc:	4505                	li	a0,1
ffffffffc02035de:	9d1ff0ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc02035e2:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02035e4:	00093503          	ld	a0,0(s2)
ffffffffc02035e8:	4681                	li	a3,0
ffffffffc02035ea:	4601                	li	a2,0
ffffffffc02035ec:	85d2                	mv	a1,s4
ffffffffc02035ee:	d8fff0ef          	jal	ra,ffffffffc020337c <page_insert>
ffffffffc02035f2:	5e051863          	bnez	a0,ffffffffc0203be2 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02035f6:	00093503          	ld	a0,0(s2)
ffffffffc02035fa:	4601                	li	a2,0
ffffffffc02035fc:	4581                	li	a1,0
ffffffffc02035fe:	abdff0ef          	jal	ra,ffffffffc02030ba <get_pte>
ffffffffc0203602:	5c050063          	beqz	a0,ffffffffc0203bc2 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc0203606:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203608:	0017f713          	andi	a4,a5,1
ffffffffc020360c:	5a070963          	beqz	a4,ffffffffc0203bbe <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0203610:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203612:	078a                	slli	a5,a5,0x2
ffffffffc0203614:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203616:	52e7fa63          	bgeu	a5,a4,ffffffffc0203b4a <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020361a:	000b3683          	ld	a3,0(s6)
ffffffffc020361e:	fff80637          	lui	a2,0xfff80
ffffffffc0203622:	97b2                	add	a5,a5,a2
ffffffffc0203624:	079a                	slli	a5,a5,0x6
ffffffffc0203626:	97b6                	add	a5,a5,a3
ffffffffc0203628:	10fa16e3          	bne	s4,a5,ffffffffc0203f34 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc020362c:	000a2683          	lw	a3,0(s4)
ffffffffc0203630:	4785                	li	a5,1
ffffffffc0203632:	12f69de3          	bne	a3,a5,ffffffffc0203f6c <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203636:	00093503          	ld	a0,0(s2)
ffffffffc020363a:	77fd                	lui	a5,0xfffff
ffffffffc020363c:	6114                	ld	a3,0(a0)
ffffffffc020363e:	068a                	slli	a3,a3,0x2
ffffffffc0203640:	8efd                	and	a3,a3,a5
ffffffffc0203642:	00c6d613          	srli	a2,a3,0xc
ffffffffc0203646:	10e677e3          	bgeu	a2,a4,ffffffffc0203f54 <pmm_init+0xae2>
ffffffffc020364a:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020364e:	96e2                	add	a3,a3,s8
ffffffffc0203650:	0006ba83          	ld	s5,0(a3)
ffffffffc0203654:	0a8a                	slli	s5,s5,0x2
ffffffffc0203656:	00fafab3          	and	s5,s5,a5
ffffffffc020365a:	00cad793          	srli	a5,s5,0xc
ffffffffc020365e:	62e7f263          	bgeu	a5,a4,ffffffffc0203c82 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203662:	4601                	li	a2,0
ffffffffc0203664:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203666:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203668:	a53ff0ef          	jal	ra,ffffffffc02030ba <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020366c:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020366e:	5f551a63          	bne	a0,s5,ffffffffc0203c62 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc0203672:	4505                	li	a0,1
ffffffffc0203674:	93bff0ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc0203678:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020367a:	00093503          	ld	a0,0(s2)
ffffffffc020367e:	46d1                	li	a3,20
ffffffffc0203680:	6605                	lui	a2,0x1
ffffffffc0203682:	85d6                	mv	a1,s5
ffffffffc0203684:	cf9ff0ef          	jal	ra,ffffffffc020337c <page_insert>
ffffffffc0203688:	58051d63          	bnez	a0,ffffffffc0203c22 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020368c:	00093503          	ld	a0,0(s2)
ffffffffc0203690:	4601                	li	a2,0
ffffffffc0203692:	6585                	lui	a1,0x1
ffffffffc0203694:	a27ff0ef          	jal	ra,ffffffffc02030ba <get_pte>
ffffffffc0203698:	0e050ae3          	beqz	a0,ffffffffc0203f8c <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc020369c:	611c                	ld	a5,0(a0)
ffffffffc020369e:	0107f713          	andi	a4,a5,16
ffffffffc02036a2:	6e070d63          	beqz	a4,ffffffffc0203d9c <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc02036a6:	8b91                	andi	a5,a5,4
ffffffffc02036a8:	6a078a63          	beqz	a5,ffffffffc0203d5c <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02036ac:	00093503          	ld	a0,0(s2)
ffffffffc02036b0:	611c                	ld	a5,0(a0)
ffffffffc02036b2:	8bc1                	andi	a5,a5,16
ffffffffc02036b4:	68078463          	beqz	a5,ffffffffc0203d3c <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc02036b8:	000aa703          	lw	a4,0(s5)
ffffffffc02036bc:	4785                	li	a5,1
ffffffffc02036be:	58f71263          	bne	a4,a5,ffffffffc0203c42 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02036c2:	4681                	li	a3,0
ffffffffc02036c4:	6605                	lui	a2,0x1
ffffffffc02036c6:	85d2                	mv	a1,s4
ffffffffc02036c8:	cb5ff0ef          	jal	ra,ffffffffc020337c <page_insert>
ffffffffc02036cc:	62051863          	bnez	a0,ffffffffc0203cfc <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc02036d0:	000a2703          	lw	a4,0(s4)
ffffffffc02036d4:	4789                	li	a5,2
ffffffffc02036d6:	60f71363          	bne	a4,a5,ffffffffc0203cdc <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc02036da:	000aa783          	lw	a5,0(s5)
ffffffffc02036de:	5c079f63          	bnez	a5,ffffffffc0203cbc <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02036e2:	00093503          	ld	a0,0(s2)
ffffffffc02036e6:	4601                	li	a2,0
ffffffffc02036e8:	6585                	lui	a1,0x1
ffffffffc02036ea:	9d1ff0ef          	jal	ra,ffffffffc02030ba <get_pte>
ffffffffc02036ee:	5a050763          	beqz	a0,ffffffffc0203c9c <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc02036f2:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02036f4:	00177793          	andi	a5,a4,1
ffffffffc02036f8:	4c078363          	beqz	a5,ffffffffc0203bbe <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc02036fc:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02036fe:	00271793          	slli	a5,a4,0x2
ffffffffc0203702:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203704:	44d7f363          	bgeu	a5,a3,ffffffffc0203b4a <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203708:	000b3683          	ld	a3,0(s6)
ffffffffc020370c:	fff80637          	lui	a2,0xfff80
ffffffffc0203710:	97b2                	add	a5,a5,a2
ffffffffc0203712:	079a                	slli	a5,a5,0x6
ffffffffc0203714:	97b6                	add	a5,a5,a3
ffffffffc0203716:	6efa1363          	bne	s4,a5,ffffffffc0203dfc <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc020371a:	8b41                	andi	a4,a4,16
ffffffffc020371c:	6c071063          	bnez	a4,ffffffffc0203ddc <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc0203720:	00093503          	ld	a0,0(s2)
ffffffffc0203724:	4581                	li	a1,0
ffffffffc0203726:	bbbff0ef          	jal	ra,ffffffffc02032e0 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020372a:	000a2703          	lw	a4,0(s4)
ffffffffc020372e:	4785                	li	a5,1
ffffffffc0203730:	68f71663          	bne	a4,a5,ffffffffc0203dbc <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc0203734:	000aa783          	lw	a5,0(s5)
ffffffffc0203738:	74079e63          	bnez	a5,ffffffffc0203e94 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020373c:	00093503          	ld	a0,0(s2)
ffffffffc0203740:	6585                	lui	a1,0x1
ffffffffc0203742:	b9fff0ef          	jal	ra,ffffffffc02032e0 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0203746:	000a2783          	lw	a5,0(s4)
ffffffffc020374a:	72079563          	bnez	a5,ffffffffc0203e74 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc020374e:	000aa783          	lw	a5,0(s5)
ffffffffc0203752:	70079163          	bnez	a5,ffffffffc0203e54 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203756:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020375a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020375c:	000a3683          	ld	a3,0(s4)
ffffffffc0203760:	068a                	slli	a3,a3,0x2
ffffffffc0203762:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203764:	3ee6f363          	bgeu	a3,a4,ffffffffc0203b4a <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203768:	fff807b7          	lui	a5,0xfff80
ffffffffc020376c:	000b3503          	ld	a0,0(s6)
ffffffffc0203770:	96be                	add	a3,a3,a5
ffffffffc0203772:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0203774:	00d507b3          	add	a5,a0,a3
ffffffffc0203778:	4390                	lw	a2,0(a5)
ffffffffc020377a:	4785                	li	a5,1
ffffffffc020377c:	6af61c63          	bne	a2,a5,ffffffffc0203e34 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc0203780:	8699                	srai	a3,a3,0x6
ffffffffc0203782:	000805b7          	lui	a1,0x80
ffffffffc0203786:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0203788:	00c69613          	slli	a2,a3,0xc
ffffffffc020378c:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020378e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203790:	68e67663          	bgeu	a2,a4,ffffffffc0203e1c <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0203794:	0009b603          	ld	a2,0(s3)
ffffffffc0203798:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc020379a:	629c                	ld	a5,0(a3)
ffffffffc020379c:	078a                	slli	a5,a5,0x2
ffffffffc020379e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037a0:	3ae7f563          	bgeu	a5,a4,ffffffffc0203b4a <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02037a4:	8f8d                	sub	a5,a5,a1
ffffffffc02037a6:	079a                	slli	a5,a5,0x6
ffffffffc02037a8:	953e                	add	a0,a0,a5
ffffffffc02037aa:	100027f3          	csrr	a5,sstatus
ffffffffc02037ae:	8b89                	andi	a5,a5,2
ffffffffc02037b0:	2c079763          	bnez	a5,ffffffffc0203a7e <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc02037b4:	000bb783          	ld	a5,0(s7)
ffffffffc02037b8:	4585                	li	a1,1
ffffffffc02037ba:	739c                	ld	a5,32(a5)
ffffffffc02037bc:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02037be:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02037c2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02037c4:	078a                	slli	a5,a5,0x2
ffffffffc02037c6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037c8:	38e7f163          	bgeu	a5,a4,ffffffffc0203b4a <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02037cc:	000b3503          	ld	a0,0(s6)
ffffffffc02037d0:	fff80737          	lui	a4,0xfff80
ffffffffc02037d4:	97ba                	add	a5,a5,a4
ffffffffc02037d6:	079a                	slli	a5,a5,0x6
ffffffffc02037d8:	953e                	add	a0,a0,a5
ffffffffc02037da:	100027f3          	csrr	a5,sstatus
ffffffffc02037de:	8b89                	andi	a5,a5,2
ffffffffc02037e0:	28079363          	bnez	a5,ffffffffc0203a66 <pmm_init+0x5f4>
ffffffffc02037e4:	000bb783          	ld	a5,0(s7)
ffffffffc02037e8:	4585                	li	a1,1
ffffffffc02037ea:	739c                	ld	a5,32(a5)
ffffffffc02037ec:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02037ee:	00093783          	ld	a5,0(s2)
ffffffffc02037f2:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fd6aa34>
  asm volatile("sfence.vma");
ffffffffc02037f6:	12000073          	sfence.vma
ffffffffc02037fa:	100027f3          	csrr	a5,sstatus
ffffffffc02037fe:	8b89                	andi	a5,a5,2
ffffffffc0203800:	24079963          	bnez	a5,ffffffffc0203a52 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203804:	000bb783          	ld	a5,0(s7)
ffffffffc0203808:	779c                	ld	a5,40(a5)
ffffffffc020380a:	9782                	jalr	a5
ffffffffc020380c:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc020380e:	71441363          	bne	s0,s4,ffffffffc0203f14 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0203812:	00003517          	auipc	a0,0x3
ffffffffc0203816:	13e50513          	addi	a0,a0,318 # ffffffffc0206950 <default_pmm_manager+0x3a0>
ffffffffc020381a:	8bffc0ef          	jal	ra,ffffffffc02000d8 <cprintf>
ffffffffc020381e:	100027f3          	csrr	a5,sstatus
ffffffffc0203822:	8b89                	andi	a5,a5,2
ffffffffc0203824:	20079d63          	bnez	a5,ffffffffc0203a3e <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203828:	000bb783          	ld	a5,0(s7)
ffffffffc020382c:	779c                	ld	a5,40(a5)
ffffffffc020382e:	9782                	jalr	a5
ffffffffc0203830:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203832:	6098                	ld	a4,0(s1)
ffffffffc0203834:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203838:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020383a:	00c71793          	slli	a5,a4,0xc
ffffffffc020383e:	6a05                	lui	s4,0x1
ffffffffc0203840:	02f47c63          	bgeu	s0,a5,ffffffffc0203878 <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203844:	00c45793          	srli	a5,s0,0xc
ffffffffc0203848:	00093503          	ld	a0,0(s2)
ffffffffc020384c:	2ee7f263          	bgeu	a5,a4,ffffffffc0203b30 <pmm_init+0x6be>
ffffffffc0203850:	0009b583          	ld	a1,0(s3)
ffffffffc0203854:	4601                	li	a2,0
ffffffffc0203856:	95a2                	add	a1,a1,s0
ffffffffc0203858:	863ff0ef          	jal	ra,ffffffffc02030ba <get_pte>
ffffffffc020385c:	2a050a63          	beqz	a0,ffffffffc0203b10 <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203860:	611c                	ld	a5,0(a0)
ffffffffc0203862:	078a                	slli	a5,a5,0x2
ffffffffc0203864:	0157f7b3          	and	a5,a5,s5
ffffffffc0203868:	28879463          	bne	a5,s0,ffffffffc0203af0 <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020386c:	6098                	ld	a4,0(s1)
ffffffffc020386e:	9452                	add	s0,s0,s4
ffffffffc0203870:	00c71793          	slli	a5,a4,0xc
ffffffffc0203874:	fcf468e3          	bltu	s0,a5,ffffffffc0203844 <pmm_init+0x3d2>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc0203878:	00093783          	ld	a5,0(s2)
ffffffffc020387c:	639c                	ld	a5,0(a5)
ffffffffc020387e:	66079b63          	bnez	a5,ffffffffc0203ef4 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc0203882:	4505                	li	a0,1
ffffffffc0203884:	f2aff0ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc0203888:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020388a:	00093503          	ld	a0,0(s2)
ffffffffc020388e:	4699                	li	a3,6
ffffffffc0203890:	10000613          	li	a2,256
ffffffffc0203894:	85d6                	mv	a1,s5
ffffffffc0203896:	ae7ff0ef          	jal	ra,ffffffffc020337c <page_insert>
ffffffffc020389a:	62051d63          	bnez	a0,ffffffffc0203ed4 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc020389e:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fde9a34>
ffffffffc02038a2:	4785                	li	a5,1
ffffffffc02038a4:	60f71863          	bne	a4,a5,ffffffffc0203eb4 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02038a8:	00093503          	ld	a0,0(s2)
ffffffffc02038ac:	6405                	lui	s0,0x1
ffffffffc02038ae:	4699                	li	a3,6
ffffffffc02038b0:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc02038b4:	85d6                	mv	a1,s5
ffffffffc02038b6:	ac7ff0ef          	jal	ra,ffffffffc020337c <page_insert>
ffffffffc02038ba:	46051163          	bnez	a0,ffffffffc0203d1c <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc02038be:	000aa703          	lw	a4,0(s5)
ffffffffc02038c2:	4789                	li	a5,2
ffffffffc02038c4:	72f71463          	bne	a4,a5,ffffffffc0203fec <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02038c8:	00003597          	auipc	a1,0x3
ffffffffc02038cc:	1c058593          	addi	a1,a1,448 # ffffffffc0206a88 <default_pmm_manager+0x4d8>
ffffffffc02038d0:	10000513          	li	a0,256
ffffffffc02038d4:	104010ef          	jal	ra,ffffffffc02049d8 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02038d8:	10040593          	addi	a1,s0,256
ffffffffc02038dc:	10000513          	li	a0,256
ffffffffc02038e0:	10a010ef          	jal	ra,ffffffffc02049ea <strcmp>
ffffffffc02038e4:	6e051463          	bnez	a0,ffffffffc0203fcc <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc02038e8:	000b3683          	ld	a3,0(s6)
ffffffffc02038ec:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc02038f0:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc02038f2:	40da86b3          	sub	a3,s5,a3
ffffffffc02038f6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02038f8:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc02038fa:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02038fc:	8031                	srli	s0,s0,0xc
ffffffffc02038fe:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203902:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203904:	50f77c63          	bgeu	a4,a5,ffffffffc0203e1c <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203908:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020390c:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203910:	96be                	add	a3,a3,a5
ffffffffc0203912:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203916:	08c010ef          	jal	ra,ffffffffc02049a2 <strlen>
ffffffffc020391a:	68051963          	bnez	a0,ffffffffc0203fac <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020391e:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203922:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203924:	000a3683          	ld	a3,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203928:	068a                	slli	a3,a3,0x2
ffffffffc020392a:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020392c:	20f6ff63          	bgeu	a3,a5,ffffffffc0203b4a <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc0203930:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203932:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203934:	4ef47463          	bgeu	s0,a5,ffffffffc0203e1c <pmm_init+0x9aa>
ffffffffc0203938:	0009b403          	ld	s0,0(s3)
ffffffffc020393c:	9436                	add	s0,s0,a3
ffffffffc020393e:	100027f3          	csrr	a5,sstatus
ffffffffc0203942:	8b89                	andi	a5,a5,2
ffffffffc0203944:	18079b63          	bnez	a5,ffffffffc0203ada <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc0203948:	000bb783          	ld	a5,0(s7)
ffffffffc020394c:	4585                	li	a1,1
ffffffffc020394e:	8556                	mv	a0,s5
ffffffffc0203950:	739c                	ld	a5,32(a5)
ffffffffc0203952:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203954:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203956:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203958:	078a                	slli	a5,a5,0x2
ffffffffc020395a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020395c:	1ee7f763          	bgeu	a5,a4,ffffffffc0203b4a <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203960:	000b3503          	ld	a0,0(s6)
ffffffffc0203964:	fff80737          	lui	a4,0xfff80
ffffffffc0203968:	97ba                	add	a5,a5,a4
ffffffffc020396a:	079a                	slli	a5,a5,0x6
ffffffffc020396c:	953e                	add	a0,a0,a5
ffffffffc020396e:	100027f3          	csrr	a5,sstatus
ffffffffc0203972:	8b89                	andi	a5,a5,2
ffffffffc0203974:	14079763          	bnez	a5,ffffffffc0203ac2 <pmm_init+0x650>
ffffffffc0203978:	000bb783          	ld	a5,0(s7)
ffffffffc020397c:	4585                	li	a1,1
ffffffffc020397e:	739c                	ld	a5,32(a5)
ffffffffc0203980:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203982:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0203986:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203988:	078a                	slli	a5,a5,0x2
ffffffffc020398a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020398c:	1ae7ff63          	bgeu	a5,a4,ffffffffc0203b4a <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203990:	000b3503          	ld	a0,0(s6)
ffffffffc0203994:	fff80737          	lui	a4,0xfff80
ffffffffc0203998:	97ba                	add	a5,a5,a4
ffffffffc020399a:	079a                	slli	a5,a5,0x6
ffffffffc020399c:	953e                	add	a0,a0,a5
ffffffffc020399e:	100027f3          	csrr	a5,sstatus
ffffffffc02039a2:	8b89                	andi	a5,a5,2
ffffffffc02039a4:	10079363          	bnez	a5,ffffffffc0203aaa <pmm_init+0x638>
ffffffffc02039a8:	000bb783          	ld	a5,0(s7)
ffffffffc02039ac:	4585                	li	a1,1
ffffffffc02039ae:	739c                	ld	a5,32(a5)
ffffffffc02039b0:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02039b2:	00093783          	ld	a5,0(s2)
ffffffffc02039b6:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02039ba:	12000073          	sfence.vma
ffffffffc02039be:	100027f3          	csrr	a5,sstatus
ffffffffc02039c2:	8b89                	andi	a5,a5,2
ffffffffc02039c4:	0c079963          	bnez	a5,ffffffffc0203a96 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc02039c8:	000bb783          	ld	a5,0(s7)
ffffffffc02039cc:	779c                	ld	a5,40(a5)
ffffffffc02039ce:	9782                	jalr	a5
ffffffffc02039d0:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02039d2:	3a8c1563          	bne	s8,s0,ffffffffc0203d7c <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02039d6:	00003517          	auipc	a0,0x3
ffffffffc02039da:	12a50513          	addi	a0,a0,298 # ffffffffc0206b00 <default_pmm_manager+0x550>
ffffffffc02039de:	efafc0ef          	jal	ra,ffffffffc02000d8 <cprintf>
}
ffffffffc02039e2:	6446                	ld	s0,80(sp)
ffffffffc02039e4:	60e6                	ld	ra,88(sp)
ffffffffc02039e6:	64a6                	ld	s1,72(sp)
ffffffffc02039e8:	6906                	ld	s2,64(sp)
ffffffffc02039ea:	79e2                	ld	s3,56(sp)
ffffffffc02039ec:	7a42                	ld	s4,48(sp)
ffffffffc02039ee:	7aa2                	ld	s5,40(sp)
ffffffffc02039f0:	7b02                	ld	s6,32(sp)
ffffffffc02039f2:	6be2                	ld	s7,24(sp)
ffffffffc02039f4:	6c42                	ld	s8,16(sp)
ffffffffc02039f6:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc02039f8:	80efe06f          	j	ffffffffc0201a06 <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02039fc:	6785                	lui	a5,0x1
ffffffffc02039fe:	17fd                	addi	a5,a5,-1
ffffffffc0203a00:	96be                	add	a3,a3,a5
ffffffffc0203a02:	77fd                	lui	a5,0xfffff
ffffffffc0203a04:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0203a06:	00c7d693          	srli	a3,a5,0xc
ffffffffc0203a0a:	14c6f063          	bgeu	a3,a2,ffffffffc0203b4a <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0203a0e:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0203a12:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203a14:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0203a18:	6a10                	ld	a2,16(a2)
ffffffffc0203a1a:	069a                	slli	a3,a3,0x6
ffffffffc0203a1c:	00c7d593          	srli	a1,a5,0xc
ffffffffc0203a20:	9536                	add	a0,a0,a3
ffffffffc0203a22:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0203a24:	0009b583          	ld	a1,0(s3)
}
ffffffffc0203a28:	b63d                	j	ffffffffc0203556 <pmm_init+0xe4>
        intr_disable();
ffffffffc0203a2a:	ba7fc0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203a2e:	000bb783          	ld	a5,0(s7)
ffffffffc0203a32:	779c                	ld	a5,40(a5)
ffffffffc0203a34:	9782                	jalr	a5
ffffffffc0203a36:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203a38:	b93fc0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0203a3c:	bea5                	j	ffffffffc02035b4 <pmm_init+0x142>
        intr_disable();
ffffffffc0203a3e:	b93fc0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc0203a42:	000bb783          	ld	a5,0(s7)
ffffffffc0203a46:	779c                	ld	a5,40(a5)
ffffffffc0203a48:	9782                	jalr	a5
ffffffffc0203a4a:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0203a4c:	b7ffc0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0203a50:	b3cd                	j	ffffffffc0203832 <pmm_init+0x3c0>
        intr_disable();
ffffffffc0203a52:	b7ffc0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc0203a56:	000bb783          	ld	a5,0(s7)
ffffffffc0203a5a:	779c                	ld	a5,40(a5)
ffffffffc0203a5c:	9782                	jalr	a5
ffffffffc0203a5e:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0203a60:	b6bfc0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0203a64:	b36d                	j	ffffffffc020380e <pmm_init+0x39c>
ffffffffc0203a66:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203a68:	b69fc0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203a6c:	000bb783          	ld	a5,0(s7)
ffffffffc0203a70:	6522                	ld	a0,8(sp)
ffffffffc0203a72:	4585                	li	a1,1
ffffffffc0203a74:	739c                	ld	a5,32(a5)
ffffffffc0203a76:	9782                	jalr	a5
        intr_enable();
ffffffffc0203a78:	b53fc0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0203a7c:	bb8d                	j	ffffffffc02037ee <pmm_init+0x37c>
ffffffffc0203a7e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203a80:	b51fc0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc0203a84:	000bb783          	ld	a5,0(s7)
ffffffffc0203a88:	6522                	ld	a0,8(sp)
ffffffffc0203a8a:	4585                	li	a1,1
ffffffffc0203a8c:	739c                	ld	a5,32(a5)
ffffffffc0203a8e:	9782                	jalr	a5
        intr_enable();
ffffffffc0203a90:	b3bfc0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0203a94:	b32d                	j	ffffffffc02037be <pmm_init+0x34c>
        intr_disable();
ffffffffc0203a96:	b3bfc0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203a9a:	000bb783          	ld	a5,0(s7)
ffffffffc0203a9e:	779c                	ld	a5,40(a5)
ffffffffc0203aa0:	9782                	jalr	a5
ffffffffc0203aa2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203aa4:	b27fc0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0203aa8:	b72d                	j	ffffffffc02039d2 <pmm_init+0x560>
ffffffffc0203aaa:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203aac:	b25fc0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203ab0:	000bb783          	ld	a5,0(s7)
ffffffffc0203ab4:	6522                	ld	a0,8(sp)
ffffffffc0203ab6:	4585                	li	a1,1
ffffffffc0203ab8:	739c                	ld	a5,32(a5)
ffffffffc0203aba:	9782                	jalr	a5
        intr_enable();
ffffffffc0203abc:	b0ffc0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0203ac0:	bdcd                	j	ffffffffc02039b2 <pmm_init+0x540>
ffffffffc0203ac2:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203ac4:	b0dfc0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc0203ac8:	000bb783          	ld	a5,0(s7)
ffffffffc0203acc:	6522                	ld	a0,8(sp)
ffffffffc0203ace:	4585                	li	a1,1
ffffffffc0203ad0:	739c                	ld	a5,32(a5)
ffffffffc0203ad2:	9782                	jalr	a5
        intr_enable();
ffffffffc0203ad4:	af7fc0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0203ad8:	b56d                	j	ffffffffc0203982 <pmm_init+0x510>
        intr_disable();
ffffffffc0203ada:	af7fc0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc0203ade:	000bb783          	ld	a5,0(s7)
ffffffffc0203ae2:	4585                	li	a1,1
ffffffffc0203ae4:	8556                	mv	a0,s5
ffffffffc0203ae6:	739c                	ld	a5,32(a5)
ffffffffc0203ae8:	9782                	jalr	a5
        intr_enable();
ffffffffc0203aea:	ae1fc0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0203aee:	b59d                	j	ffffffffc0203954 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203af0:	00003697          	auipc	a3,0x3
ffffffffc0203af4:	ec068693          	addi	a3,a3,-320 # ffffffffc02069b0 <default_pmm_manager+0x400>
ffffffffc0203af8:	00002617          	auipc	a2,0x2
ffffffffc0203afc:	d6060613          	addi	a2,a2,-672 # ffffffffc0205858 <commands+0x728>
ffffffffc0203b00:	19e00593          	li	a1,414
ffffffffc0203b04:	00003517          	auipc	a0,0x3
ffffffffc0203b08:	ae450513          	addi	a0,a0,-1308 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203b0c:	ec8fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203b10:	00003697          	auipc	a3,0x3
ffffffffc0203b14:	e6068693          	addi	a3,a3,-416 # ffffffffc0206970 <default_pmm_manager+0x3c0>
ffffffffc0203b18:	00002617          	auipc	a2,0x2
ffffffffc0203b1c:	d4060613          	addi	a2,a2,-704 # ffffffffc0205858 <commands+0x728>
ffffffffc0203b20:	19d00593          	li	a1,413
ffffffffc0203b24:	00003517          	auipc	a0,0x3
ffffffffc0203b28:	ac450513          	addi	a0,a0,-1340 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203b2c:	ea8fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc0203b30:	86a2                	mv	a3,s0
ffffffffc0203b32:	00002617          	auipc	a2,0x2
ffffffffc0203b36:	f7e60613          	addi	a2,a2,-130 # ffffffffc0205ab0 <commands+0x980>
ffffffffc0203b3a:	19d00593          	li	a1,413
ffffffffc0203b3e:	00003517          	auipc	a0,0x3
ffffffffc0203b42:	aaa50513          	addi	a0,a0,-1366 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203b46:	e8efc0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc0203b4a:	c2cff0ef          	jal	ra,ffffffffc0202f76 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203b4e:	00002617          	auipc	a2,0x2
ffffffffc0203b52:	31260613          	addi	a2,a2,786 # ffffffffc0205e60 <commands+0xd30>
ffffffffc0203b56:	07f00593          	li	a1,127
ffffffffc0203b5a:	00003517          	auipc	a0,0x3
ffffffffc0203b5e:	a8e50513          	addi	a0,a0,-1394 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203b62:	e72fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203b66:	00002617          	auipc	a2,0x2
ffffffffc0203b6a:	2fa60613          	addi	a2,a2,762 # ffffffffc0205e60 <commands+0xd30>
ffffffffc0203b6e:	0c300593          	li	a1,195
ffffffffc0203b72:	00003517          	auipc	a0,0x3
ffffffffc0203b76:	a7650513          	addi	a0,a0,-1418 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203b7a:	e5afc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203b7e:	00003697          	auipc	a3,0x3
ffffffffc0203b82:	b2a68693          	addi	a3,a3,-1238 # ffffffffc02066a8 <default_pmm_manager+0xf8>
ffffffffc0203b86:	00002617          	auipc	a2,0x2
ffffffffc0203b8a:	cd260613          	addi	a2,a2,-814 # ffffffffc0205858 <commands+0x728>
ffffffffc0203b8e:	16100593          	li	a1,353
ffffffffc0203b92:	00003517          	auipc	a0,0x3
ffffffffc0203b96:	a5650513          	addi	a0,a0,-1450 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203b9a:	e3afc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203b9e:	00003697          	auipc	a3,0x3
ffffffffc0203ba2:	aea68693          	addi	a3,a3,-1302 # ffffffffc0206688 <default_pmm_manager+0xd8>
ffffffffc0203ba6:	00002617          	auipc	a2,0x2
ffffffffc0203baa:	cb260613          	addi	a2,a2,-846 # ffffffffc0205858 <commands+0x728>
ffffffffc0203bae:	16000593          	li	a1,352
ffffffffc0203bb2:	00003517          	auipc	a0,0x3
ffffffffc0203bb6:	a3650513          	addi	a0,a0,-1482 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203bba:	e1afc0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc0203bbe:	bd4ff0ef          	jal	ra,ffffffffc0202f92 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203bc2:	00003697          	auipc	a3,0x3
ffffffffc0203bc6:	b7668693          	addi	a3,a3,-1162 # ffffffffc0206738 <default_pmm_manager+0x188>
ffffffffc0203bca:	00002617          	auipc	a2,0x2
ffffffffc0203bce:	c8e60613          	addi	a2,a2,-882 # ffffffffc0205858 <commands+0x728>
ffffffffc0203bd2:	16900593          	li	a1,361
ffffffffc0203bd6:	00003517          	auipc	a0,0x3
ffffffffc0203bda:	a1250513          	addi	a0,a0,-1518 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203bde:	df6fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203be2:	00003697          	auipc	a3,0x3
ffffffffc0203be6:	b2668693          	addi	a3,a3,-1242 # ffffffffc0206708 <default_pmm_manager+0x158>
ffffffffc0203bea:	00002617          	auipc	a2,0x2
ffffffffc0203bee:	c6e60613          	addi	a2,a2,-914 # ffffffffc0205858 <commands+0x728>
ffffffffc0203bf2:	16600593          	li	a1,358
ffffffffc0203bf6:	00003517          	auipc	a0,0x3
ffffffffc0203bfa:	9f250513          	addi	a0,a0,-1550 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203bfe:	dd6fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203c02:	00003697          	auipc	a3,0x3
ffffffffc0203c06:	ade68693          	addi	a3,a3,-1314 # ffffffffc02066e0 <default_pmm_manager+0x130>
ffffffffc0203c0a:	00002617          	auipc	a2,0x2
ffffffffc0203c0e:	c4e60613          	addi	a2,a2,-946 # ffffffffc0205858 <commands+0x728>
ffffffffc0203c12:	16200593          	li	a1,354
ffffffffc0203c16:	00003517          	auipc	a0,0x3
ffffffffc0203c1a:	9d250513          	addi	a0,a0,-1582 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203c1e:	db6fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203c22:	00003697          	auipc	a3,0x3
ffffffffc0203c26:	b9e68693          	addi	a3,a3,-1122 # ffffffffc02067c0 <default_pmm_manager+0x210>
ffffffffc0203c2a:	00002617          	auipc	a2,0x2
ffffffffc0203c2e:	c2e60613          	addi	a2,a2,-978 # ffffffffc0205858 <commands+0x728>
ffffffffc0203c32:	17200593          	li	a1,370
ffffffffc0203c36:	00003517          	auipc	a0,0x3
ffffffffc0203c3a:	9b250513          	addi	a0,a0,-1614 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203c3e:	d96fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203c42:	00003697          	auipc	a3,0x3
ffffffffc0203c46:	c1e68693          	addi	a3,a3,-994 # ffffffffc0206860 <default_pmm_manager+0x2b0>
ffffffffc0203c4a:	00002617          	auipc	a2,0x2
ffffffffc0203c4e:	c0e60613          	addi	a2,a2,-1010 # ffffffffc0205858 <commands+0x728>
ffffffffc0203c52:	17700593          	li	a1,375
ffffffffc0203c56:	00003517          	auipc	a0,0x3
ffffffffc0203c5a:	99250513          	addi	a0,a0,-1646 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203c5e:	d76fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203c62:	00003697          	auipc	a3,0x3
ffffffffc0203c66:	b3668693          	addi	a3,a3,-1226 # ffffffffc0206798 <default_pmm_manager+0x1e8>
ffffffffc0203c6a:	00002617          	auipc	a2,0x2
ffffffffc0203c6e:	bee60613          	addi	a2,a2,-1042 # ffffffffc0205858 <commands+0x728>
ffffffffc0203c72:	16f00593          	li	a1,367
ffffffffc0203c76:	00003517          	auipc	a0,0x3
ffffffffc0203c7a:	97250513          	addi	a0,a0,-1678 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203c7e:	d56fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203c82:	86d6                	mv	a3,s5
ffffffffc0203c84:	00002617          	auipc	a2,0x2
ffffffffc0203c88:	e2c60613          	addi	a2,a2,-468 # ffffffffc0205ab0 <commands+0x980>
ffffffffc0203c8c:	16e00593          	li	a1,366
ffffffffc0203c90:	00003517          	auipc	a0,0x3
ffffffffc0203c94:	95850513          	addi	a0,a0,-1704 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203c98:	d3cfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203c9c:	00003697          	auipc	a3,0x3
ffffffffc0203ca0:	b5c68693          	addi	a3,a3,-1188 # ffffffffc02067f8 <default_pmm_manager+0x248>
ffffffffc0203ca4:	00002617          	auipc	a2,0x2
ffffffffc0203ca8:	bb460613          	addi	a2,a2,-1100 # ffffffffc0205858 <commands+0x728>
ffffffffc0203cac:	17c00593          	li	a1,380
ffffffffc0203cb0:	00003517          	auipc	a0,0x3
ffffffffc0203cb4:	93850513          	addi	a0,a0,-1736 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203cb8:	d1cfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203cbc:	00003697          	auipc	a3,0x3
ffffffffc0203cc0:	c0468693          	addi	a3,a3,-1020 # ffffffffc02068c0 <default_pmm_manager+0x310>
ffffffffc0203cc4:	00002617          	auipc	a2,0x2
ffffffffc0203cc8:	b9460613          	addi	a2,a2,-1132 # ffffffffc0205858 <commands+0x728>
ffffffffc0203ccc:	17b00593          	li	a1,379
ffffffffc0203cd0:	00003517          	auipc	a0,0x3
ffffffffc0203cd4:	91850513          	addi	a0,a0,-1768 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203cd8:	cfcfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203cdc:	00003697          	auipc	a3,0x3
ffffffffc0203ce0:	bcc68693          	addi	a3,a3,-1076 # ffffffffc02068a8 <default_pmm_manager+0x2f8>
ffffffffc0203ce4:	00002617          	auipc	a2,0x2
ffffffffc0203ce8:	b7460613          	addi	a2,a2,-1164 # ffffffffc0205858 <commands+0x728>
ffffffffc0203cec:	17a00593          	li	a1,378
ffffffffc0203cf0:	00003517          	auipc	a0,0x3
ffffffffc0203cf4:	8f850513          	addi	a0,a0,-1800 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203cf8:	cdcfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203cfc:	00003697          	auipc	a3,0x3
ffffffffc0203d00:	b7c68693          	addi	a3,a3,-1156 # ffffffffc0206878 <default_pmm_manager+0x2c8>
ffffffffc0203d04:	00002617          	auipc	a2,0x2
ffffffffc0203d08:	b5460613          	addi	a2,a2,-1196 # ffffffffc0205858 <commands+0x728>
ffffffffc0203d0c:	17900593          	li	a1,377
ffffffffc0203d10:	00003517          	auipc	a0,0x3
ffffffffc0203d14:	8d850513          	addi	a0,a0,-1832 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203d18:	cbcfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203d1c:	00003697          	auipc	a3,0x3
ffffffffc0203d20:	d1468693          	addi	a3,a3,-748 # ffffffffc0206a30 <default_pmm_manager+0x480>
ffffffffc0203d24:	00002617          	auipc	a2,0x2
ffffffffc0203d28:	b3460613          	addi	a2,a2,-1228 # ffffffffc0205858 <commands+0x728>
ffffffffc0203d2c:	1a700593          	li	a1,423
ffffffffc0203d30:	00003517          	auipc	a0,0x3
ffffffffc0203d34:	8b850513          	addi	a0,a0,-1864 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203d38:	c9cfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203d3c:	00003697          	auipc	a3,0x3
ffffffffc0203d40:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0206848 <default_pmm_manager+0x298>
ffffffffc0203d44:	00002617          	auipc	a2,0x2
ffffffffc0203d48:	b1460613          	addi	a2,a2,-1260 # ffffffffc0205858 <commands+0x728>
ffffffffc0203d4c:	17600593          	li	a1,374
ffffffffc0203d50:	00003517          	auipc	a0,0x3
ffffffffc0203d54:	89850513          	addi	a0,a0,-1896 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203d58:	c7cfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203d5c:	00003697          	auipc	a3,0x3
ffffffffc0203d60:	adc68693          	addi	a3,a3,-1316 # ffffffffc0206838 <default_pmm_manager+0x288>
ffffffffc0203d64:	00002617          	auipc	a2,0x2
ffffffffc0203d68:	af460613          	addi	a2,a2,-1292 # ffffffffc0205858 <commands+0x728>
ffffffffc0203d6c:	17500593          	li	a1,373
ffffffffc0203d70:	00003517          	auipc	a0,0x3
ffffffffc0203d74:	87850513          	addi	a0,a0,-1928 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203d78:	c5cfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203d7c:	00003697          	auipc	a3,0x3
ffffffffc0203d80:	bb468693          	addi	a3,a3,-1100 # ffffffffc0206930 <default_pmm_manager+0x380>
ffffffffc0203d84:	00002617          	auipc	a2,0x2
ffffffffc0203d88:	ad460613          	addi	a2,a2,-1324 # ffffffffc0205858 <commands+0x728>
ffffffffc0203d8c:	1b800593          	li	a1,440
ffffffffc0203d90:	00003517          	auipc	a0,0x3
ffffffffc0203d94:	85850513          	addi	a0,a0,-1960 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203d98:	c3cfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203d9c:	00003697          	auipc	a3,0x3
ffffffffc0203da0:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0206828 <default_pmm_manager+0x278>
ffffffffc0203da4:	00002617          	auipc	a2,0x2
ffffffffc0203da8:	ab460613          	addi	a2,a2,-1356 # ffffffffc0205858 <commands+0x728>
ffffffffc0203dac:	17400593          	li	a1,372
ffffffffc0203db0:	00003517          	auipc	a0,0x3
ffffffffc0203db4:	83850513          	addi	a0,a0,-1992 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203db8:	c1cfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203dbc:	00003697          	auipc	a3,0x3
ffffffffc0203dc0:	9c468693          	addi	a3,a3,-1596 # ffffffffc0206780 <default_pmm_manager+0x1d0>
ffffffffc0203dc4:	00002617          	auipc	a2,0x2
ffffffffc0203dc8:	a9460613          	addi	a2,a2,-1388 # ffffffffc0205858 <commands+0x728>
ffffffffc0203dcc:	18100593          	li	a1,385
ffffffffc0203dd0:	00003517          	auipc	a0,0x3
ffffffffc0203dd4:	81850513          	addi	a0,a0,-2024 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203dd8:	bfcfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203ddc:	00003697          	auipc	a3,0x3
ffffffffc0203de0:	afc68693          	addi	a3,a3,-1284 # ffffffffc02068d8 <default_pmm_manager+0x328>
ffffffffc0203de4:	00002617          	auipc	a2,0x2
ffffffffc0203de8:	a7460613          	addi	a2,a2,-1420 # ffffffffc0205858 <commands+0x728>
ffffffffc0203dec:	17e00593          	li	a1,382
ffffffffc0203df0:	00002517          	auipc	a0,0x2
ffffffffc0203df4:	7f850513          	addi	a0,a0,2040 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203df8:	bdcfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203dfc:	00003697          	auipc	a3,0x3
ffffffffc0203e00:	96c68693          	addi	a3,a3,-1684 # ffffffffc0206768 <default_pmm_manager+0x1b8>
ffffffffc0203e04:	00002617          	auipc	a2,0x2
ffffffffc0203e08:	a5460613          	addi	a2,a2,-1452 # ffffffffc0205858 <commands+0x728>
ffffffffc0203e0c:	17d00593          	li	a1,381
ffffffffc0203e10:	00002517          	auipc	a0,0x2
ffffffffc0203e14:	7d850513          	addi	a0,a0,2008 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203e18:	bbcfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203e1c:	00002617          	auipc	a2,0x2
ffffffffc0203e20:	c9460613          	addi	a2,a2,-876 # ffffffffc0205ab0 <commands+0x980>
ffffffffc0203e24:	06900593          	li	a1,105
ffffffffc0203e28:	00002517          	auipc	a0,0x2
ffffffffc0203e2c:	c7850513          	addi	a0,a0,-904 # ffffffffc0205aa0 <commands+0x970>
ffffffffc0203e30:	ba4fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203e34:	00003697          	auipc	a3,0x3
ffffffffc0203e38:	ad468693          	addi	a3,a3,-1324 # ffffffffc0206908 <default_pmm_manager+0x358>
ffffffffc0203e3c:	00002617          	auipc	a2,0x2
ffffffffc0203e40:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0205858 <commands+0x728>
ffffffffc0203e44:	18800593          	li	a1,392
ffffffffc0203e48:	00002517          	auipc	a0,0x2
ffffffffc0203e4c:	7a050513          	addi	a0,a0,1952 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203e50:	b84fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203e54:	00003697          	auipc	a3,0x3
ffffffffc0203e58:	a6c68693          	addi	a3,a3,-1428 # ffffffffc02068c0 <default_pmm_manager+0x310>
ffffffffc0203e5c:	00002617          	auipc	a2,0x2
ffffffffc0203e60:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0205858 <commands+0x728>
ffffffffc0203e64:	18600593          	li	a1,390
ffffffffc0203e68:	00002517          	auipc	a0,0x2
ffffffffc0203e6c:	78050513          	addi	a0,a0,1920 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203e70:	b64fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203e74:	00003697          	auipc	a3,0x3
ffffffffc0203e78:	a7c68693          	addi	a3,a3,-1412 # ffffffffc02068f0 <default_pmm_manager+0x340>
ffffffffc0203e7c:	00002617          	auipc	a2,0x2
ffffffffc0203e80:	9dc60613          	addi	a2,a2,-1572 # ffffffffc0205858 <commands+0x728>
ffffffffc0203e84:	18500593          	li	a1,389
ffffffffc0203e88:	00002517          	auipc	a0,0x2
ffffffffc0203e8c:	76050513          	addi	a0,a0,1888 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203e90:	b44fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203e94:	00003697          	auipc	a3,0x3
ffffffffc0203e98:	a2c68693          	addi	a3,a3,-1492 # ffffffffc02068c0 <default_pmm_manager+0x310>
ffffffffc0203e9c:	00002617          	auipc	a2,0x2
ffffffffc0203ea0:	9bc60613          	addi	a2,a2,-1604 # ffffffffc0205858 <commands+0x728>
ffffffffc0203ea4:	18200593          	li	a1,386
ffffffffc0203ea8:	00002517          	auipc	a0,0x2
ffffffffc0203eac:	74050513          	addi	a0,a0,1856 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203eb0:	b24fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203eb4:	00003697          	auipc	a3,0x3
ffffffffc0203eb8:	b6468693          	addi	a3,a3,-1180 # ffffffffc0206a18 <default_pmm_manager+0x468>
ffffffffc0203ebc:	00002617          	auipc	a2,0x2
ffffffffc0203ec0:	99c60613          	addi	a2,a2,-1636 # ffffffffc0205858 <commands+0x728>
ffffffffc0203ec4:	1a600593          	li	a1,422
ffffffffc0203ec8:	00002517          	auipc	a0,0x2
ffffffffc0203ecc:	72050513          	addi	a0,a0,1824 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203ed0:	b04fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203ed4:	00003697          	auipc	a3,0x3
ffffffffc0203ed8:	b0c68693          	addi	a3,a3,-1268 # ffffffffc02069e0 <default_pmm_manager+0x430>
ffffffffc0203edc:	00002617          	auipc	a2,0x2
ffffffffc0203ee0:	97c60613          	addi	a2,a2,-1668 # ffffffffc0205858 <commands+0x728>
ffffffffc0203ee4:	1a500593          	li	a1,421
ffffffffc0203ee8:	00002517          	auipc	a0,0x2
ffffffffc0203eec:	70050513          	addi	a0,a0,1792 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203ef0:	ae4fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203ef4:	00003697          	auipc	a3,0x3
ffffffffc0203ef8:	ad468693          	addi	a3,a3,-1324 # ffffffffc02069c8 <default_pmm_manager+0x418>
ffffffffc0203efc:	00002617          	auipc	a2,0x2
ffffffffc0203f00:	95c60613          	addi	a2,a2,-1700 # ffffffffc0205858 <commands+0x728>
ffffffffc0203f04:	1a100593          	li	a1,417
ffffffffc0203f08:	00002517          	auipc	a0,0x2
ffffffffc0203f0c:	6e050513          	addi	a0,a0,1760 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203f10:	ac4fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203f14:	00003697          	auipc	a3,0x3
ffffffffc0203f18:	a1c68693          	addi	a3,a3,-1508 # ffffffffc0206930 <default_pmm_manager+0x380>
ffffffffc0203f1c:	00002617          	auipc	a2,0x2
ffffffffc0203f20:	93c60613          	addi	a2,a2,-1732 # ffffffffc0205858 <commands+0x728>
ffffffffc0203f24:	19000593          	li	a1,400
ffffffffc0203f28:	00002517          	auipc	a0,0x2
ffffffffc0203f2c:	6c050513          	addi	a0,a0,1728 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203f30:	aa4fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203f34:	00003697          	auipc	a3,0x3
ffffffffc0203f38:	83468693          	addi	a3,a3,-1996 # ffffffffc0206768 <default_pmm_manager+0x1b8>
ffffffffc0203f3c:	00002617          	auipc	a2,0x2
ffffffffc0203f40:	91c60613          	addi	a2,a2,-1764 # ffffffffc0205858 <commands+0x728>
ffffffffc0203f44:	16a00593          	li	a1,362
ffffffffc0203f48:	00002517          	auipc	a0,0x2
ffffffffc0203f4c:	6a050513          	addi	a0,a0,1696 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203f50:	a84fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203f54:	00002617          	auipc	a2,0x2
ffffffffc0203f58:	b5c60613          	addi	a2,a2,-1188 # ffffffffc0205ab0 <commands+0x980>
ffffffffc0203f5c:	16d00593          	li	a1,365
ffffffffc0203f60:	00002517          	auipc	a0,0x2
ffffffffc0203f64:	68850513          	addi	a0,a0,1672 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203f68:	a6cfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203f6c:	00003697          	auipc	a3,0x3
ffffffffc0203f70:	81468693          	addi	a3,a3,-2028 # ffffffffc0206780 <default_pmm_manager+0x1d0>
ffffffffc0203f74:	00002617          	auipc	a2,0x2
ffffffffc0203f78:	8e460613          	addi	a2,a2,-1820 # ffffffffc0205858 <commands+0x728>
ffffffffc0203f7c:	16b00593          	li	a1,363
ffffffffc0203f80:	00002517          	auipc	a0,0x2
ffffffffc0203f84:	66850513          	addi	a0,a0,1640 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203f88:	a4cfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203f8c:	00003697          	auipc	a3,0x3
ffffffffc0203f90:	86c68693          	addi	a3,a3,-1940 # ffffffffc02067f8 <default_pmm_manager+0x248>
ffffffffc0203f94:	00002617          	auipc	a2,0x2
ffffffffc0203f98:	8c460613          	addi	a2,a2,-1852 # ffffffffc0205858 <commands+0x728>
ffffffffc0203f9c:	17300593          	li	a1,371
ffffffffc0203fa0:	00002517          	auipc	a0,0x2
ffffffffc0203fa4:	64850513          	addi	a0,a0,1608 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203fa8:	a2cfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203fac:	00003697          	auipc	a3,0x3
ffffffffc0203fb0:	b2c68693          	addi	a3,a3,-1236 # ffffffffc0206ad8 <default_pmm_manager+0x528>
ffffffffc0203fb4:	00002617          	auipc	a2,0x2
ffffffffc0203fb8:	8a460613          	addi	a2,a2,-1884 # ffffffffc0205858 <commands+0x728>
ffffffffc0203fbc:	1af00593          	li	a1,431
ffffffffc0203fc0:	00002517          	auipc	a0,0x2
ffffffffc0203fc4:	62850513          	addi	a0,a0,1576 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203fc8:	a0cfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203fcc:	00003697          	auipc	a3,0x3
ffffffffc0203fd0:	ad468693          	addi	a3,a3,-1324 # ffffffffc0206aa0 <default_pmm_manager+0x4f0>
ffffffffc0203fd4:	00002617          	auipc	a2,0x2
ffffffffc0203fd8:	88460613          	addi	a2,a2,-1916 # ffffffffc0205858 <commands+0x728>
ffffffffc0203fdc:	1ac00593          	li	a1,428
ffffffffc0203fe0:	00002517          	auipc	a0,0x2
ffffffffc0203fe4:	60850513          	addi	a0,a0,1544 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0203fe8:	9ecfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203fec:	00003697          	auipc	a3,0x3
ffffffffc0203ff0:	a8468693          	addi	a3,a3,-1404 # ffffffffc0206a70 <default_pmm_manager+0x4c0>
ffffffffc0203ff4:	00002617          	auipc	a2,0x2
ffffffffc0203ff8:	86460613          	addi	a2,a2,-1948 # ffffffffc0205858 <commands+0x728>
ffffffffc0203ffc:	1a800593          	li	a1,424
ffffffffc0204000:	00002517          	auipc	a0,0x2
ffffffffc0204004:	5e850513          	addi	a0,a0,1512 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc0204008:	9ccfc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc020400c <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020400c:	12058073          	sfence.vma	a1
}
ffffffffc0204010:	8082                	ret

ffffffffc0204012 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204012:	7179                	addi	sp,sp,-48
ffffffffc0204014:	e84a                	sd	s2,16(sp)
ffffffffc0204016:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0204018:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020401a:	f022                	sd	s0,32(sp)
ffffffffc020401c:	ec26                	sd	s1,24(sp)
ffffffffc020401e:	e44e                	sd	s3,8(sp)
ffffffffc0204020:	f406                	sd	ra,40(sp)
ffffffffc0204022:	84ae                	mv	s1,a1
ffffffffc0204024:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0204026:	f89fe0ef          	jal	ra,ffffffffc0202fae <alloc_pages>
ffffffffc020402a:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc020402c:	cd09                	beqz	a0,ffffffffc0204046 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc020402e:	85aa                	mv	a1,a0
ffffffffc0204030:	86ce                	mv	a3,s3
ffffffffc0204032:	8626                	mv	a2,s1
ffffffffc0204034:	854a                	mv	a0,s2
ffffffffc0204036:	b46ff0ef          	jal	ra,ffffffffc020337c <page_insert>
ffffffffc020403a:	ed21                	bnez	a0,ffffffffc0204092 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc020403c:	00011797          	auipc	a5,0x11
ffffffffc0204040:	53c7a783          	lw	a5,1340(a5) # ffffffffc0215578 <swap_init_ok>
ffffffffc0204044:	eb89                	bnez	a5,ffffffffc0204056 <pgdir_alloc_page+0x44>
}
ffffffffc0204046:	70a2                	ld	ra,40(sp)
ffffffffc0204048:	8522                	mv	a0,s0
ffffffffc020404a:	7402                	ld	s0,32(sp)
ffffffffc020404c:	64e2                	ld	s1,24(sp)
ffffffffc020404e:	6942                	ld	s2,16(sp)
ffffffffc0204050:	69a2                	ld	s3,8(sp)
ffffffffc0204052:	6145                	addi	sp,sp,48
ffffffffc0204054:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0204056:	4681                	li	a3,0
ffffffffc0204058:	8622                	mv	a2,s0
ffffffffc020405a:	85a6                	mv	a1,s1
ffffffffc020405c:	00011517          	auipc	a0,0x11
ffffffffc0204060:	4f453503          	ld	a0,1268(a0) # ffffffffc0215550 <check_mm_struct>
ffffffffc0204064:	acafe0ef          	jal	ra,ffffffffc020232e <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0204068:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc020406a:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc020406c:	4785                	li	a5,1
ffffffffc020406e:	fcf70ce3          	beq	a4,a5,ffffffffc0204046 <pgdir_alloc_page+0x34>
ffffffffc0204072:	00003697          	auipc	a3,0x3
ffffffffc0204076:	aae68693          	addi	a3,a3,-1362 # ffffffffc0206b20 <default_pmm_manager+0x570>
ffffffffc020407a:	00001617          	auipc	a2,0x1
ffffffffc020407e:	7de60613          	addi	a2,a2,2014 # ffffffffc0205858 <commands+0x728>
ffffffffc0204082:	14800593          	li	a1,328
ffffffffc0204086:	00002517          	auipc	a0,0x2
ffffffffc020408a:	56250513          	addi	a0,a0,1378 # ffffffffc02065e8 <default_pmm_manager+0x38>
ffffffffc020408e:	946fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204092:	100027f3          	csrr	a5,sstatus
ffffffffc0204096:	8b89                	andi	a5,a5,2
ffffffffc0204098:	eb99                	bnez	a5,ffffffffc02040ae <pgdir_alloc_page+0x9c>
        pmm_manager->free_pages(base, n);
ffffffffc020409a:	00011797          	auipc	a5,0x11
ffffffffc020409e:	5067b783          	ld	a5,1286(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc02040a2:	739c                	ld	a5,32(a5)
ffffffffc02040a4:	8522                	mv	a0,s0
ffffffffc02040a6:	4585                	li	a1,1
ffffffffc02040a8:	9782                	jalr	a5
            return NULL;
ffffffffc02040aa:	4401                	li	s0,0
ffffffffc02040ac:	bf69                	j	ffffffffc0204046 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc02040ae:	d22fc0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02040b2:	00011797          	auipc	a5,0x11
ffffffffc02040b6:	4ee7b783          	ld	a5,1262(a5) # ffffffffc02155a0 <pmm_manager>
ffffffffc02040ba:	739c                	ld	a5,32(a5)
ffffffffc02040bc:	8522                	mv	a0,s0
ffffffffc02040be:	4585                	li	a1,1
ffffffffc02040c0:	9782                	jalr	a5
            return NULL;
ffffffffc02040c2:	4401                	li	s0,0
        intr_enable();
ffffffffc02040c4:	d06fc0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc02040c8:	bfbd                	j	ffffffffc0204046 <pgdir_alloc_page+0x34>

ffffffffc02040ca <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc02040ca:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc02040cc:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc02040ce:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc02040d0:	be0fc0ef          	jal	ra,ffffffffc02004b0 <ide_device_valid>
ffffffffc02040d4:	cd01                	beqz	a0,ffffffffc02040ec <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02040d6:	4505                	li	a0,1
ffffffffc02040d8:	bdefc0ef          	jal	ra,ffffffffc02004b6 <ide_device_size>
}
ffffffffc02040dc:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02040de:	810d                	srli	a0,a0,0x3
ffffffffc02040e0:	00011797          	auipc	a5,0x11
ffffffffc02040e4:	48a7b423          	sd	a0,1160(a5) # ffffffffc0215568 <max_swap_offset>
}
ffffffffc02040e8:	0141                	addi	sp,sp,16
ffffffffc02040ea:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc02040ec:	00003617          	auipc	a2,0x3
ffffffffc02040f0:	a4c60613          	addi	a2,a2,-1460 # ffffffffc0206b38 <default_pmm_manager+0x588>
ffffffffc02040f4:	45b5                	li	a1,13
ffffffffc02040f6:	00003517          	auipc	a0,0x3
ffffffffc02040fa:	a6250513          	addi	a0,a0,-1438 # ffffffffc0206b58 <default_pmm_manager+0x5a8>
ffffffffc02040fe:	8d6fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0204102 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204102:	1141                	addi	sp,sp,-16
ffffffffc0204104:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204106:	00855793          	srli	a5,a0,0x8
ffffffffc020410a:	cbb1                	beqz	a5,ffffffffc020415e <swapfs_read+0x5c>
ffffffffc020410c:	00011717          	auipc	a4,0x11
ffffffffc0204110:	45c73703          	ld	a4,1116(a4) # ffffffffc0215568 <max_swap_offset>
ffffffffc0204114:	04e7f563          	bgeu	a5,a4,ffffffffc020415e <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204118:	00011617          	auipc	a2,0x11
ffffffffc020411c:	48063603          	ld	a2,1152(a2) # ffffffffc0215598 <pages>
ffffffffc0204120:	8d91                	sub	a1,a1,a2
ffffffffc0204122:	4065d613          	srai	a2,a1,0x6
ffffffffc0204126:	00003717          	auipc	a4,0x3
ffffffffc020412a:	e6273703          	ld	a4,-414(a4) # ffffffffc0206f88 <nbase>
ffffffffc020412e:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204130:	00c61713          	slli	a4,a2,0xc
ffffffffc0204134:	8331                	srli	a4,a4,0xc
ffffffffc0204136:	00011697          	auipc	a3,0x11
ffffffffc020413a:	45a6b683          	ld	a3,1114(a3) # ffffffffc0215590 <npage>
ffffffffc020413e:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204142:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204144:	02d77963          	bgeu	a4,a3,ffffffffc0204176 <swapfs_read+0x74>
}
ffffffffc0204148:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020414a:	00011797          	auipc	a5,0x11
ffffffffc020414e:	45e7b783          	ld	a5,1118(a5) # ffffffffc02155a8 <va_pa_offset>
ffffffffc0204152:	46a1                	li	a3,8
ffffffffc0204154:	963e                	add	a2,a2,a5
ffffffffc0204156:	4505                	li	a0,1
}
ffffffffc0204158:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020415a:	b62fc06f          	j	ffffffffc02004bc <ide_read_secs>
ffffffffc020415e:	86aa                	mv	a3,a0
ffffffffc0204160:	00003617          	auipc	a2,0x3
ffffffffc0204164:	a1060613          	addi	a2,a2,-1520 # ffffffffc0206b70 <default_pmm_manager+0x5c0>
ffffffffc0204168:	45d1                	li	a1,20
ffffffffc020416a:	00003517          	auipc	a0,0x3
ffffffffc020416e:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0206b58 <default_pmm_manager+0x5a8>
ffffffffc0204172:	862fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc0204176:	86b2                	mv	a3,a2
ffffffffc0204178:	06900593          	li	a1,105
ffffffffc020417c:	00002617          	auipc	a2,0x2
ffffffffc0204180:	93460613          	addi	a2,a2,-1740 # ffffffffc0205ab0 <commands+0x980>
ffffffffc0204184:	00002517          	auipc	a0,0x2
ffffffffc0204188:	91c50513          	addi	a0,a0,-1764 # ffffffffc0205aa0 <commands+0x970>
ffffffffc020418c:	848fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0204190 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204190:	1141                	addi	sp,sp,-16
ffffffffc0204192:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204194:	00855793          	srli	a5,a0,0x8
ffffffffc0204198:	cbb1                	beqz	a5,ffffffffc02041ec <swapfs_write+0x5c>
ffffffffc020419a:	00011717          	auipc	a4,0x11
ffffffffc020419e:	3ce73703          	ld	a4,974(a4) # ffffffffc0215568 <max_swap_offset>
ffffffffc02041a2:	04e7f563          	bgeu	a5,a4,ffffffffc02041ec <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc02041a6:	00011617          	auipc	a2,0x11
ffffffffc02041aa:	3f263603          	ld	a2,1010(a2) # ffffffffc0215598 <pages>
ffffffffc02041ae:	8d91                	sub	a1,a1,a2
ffffffffc02041b0:	4065d613          	srai	a2,a1,0x6
ffffffffc02041b4:	00003717          	auipc	a4,0x3
ffffffffc02041b8:	dd473703          	ld	a4,-556(a4) # ffffffffc0206f88 <nbase>
ffffffffc02041bc:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc02041be:	00c61713          	slli	a4,a2,0xc
ffffffffc02041c2:	8331                	srli	a4,a4,0xc
ffffffffc02041c4:	00011697          	auipc	a3,0x11
ffffffffc02041c8:	3cc6b683          	ld	a3,972(a3) # ffffffffc0215590 <npage>
ffffffffc02041cc:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc02041d0:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc02041d2:	02d77963          	bgeu	a4,a3,ffffffffc0204204 <swapfs_write+0x74>
}
ffffffffc02041d6:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02041d8:	00011797          	auipc	a5,0x11
ffffffffc02041dc:	3d07b783          	ld	a5,976(a5) # ffffffffc02155a8 <va_pa_offset>
ffffffffc02041e0:	46a1                	li	a3,8
ffffffffc02041e2:	963e                	add	a2,a2,a5
ffffffffc02041e4:	4505                	li	a0,1
}
ffffffffc02041e6:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02041e8:	af8fc06f          	j	ffffffffc02004e0 <ide_write_secs>
ffffffffc02041ec:	86aa                	mv	a3,a0
ffffffffc02041ee:	00003617          	auipc	a2,0x3
ffffffffc02041f2:	98260613          	addi	a2,a2,-1662 # ffffffffc0206b70 <default_pmm_manager+0x5c0>
ffffffffc02041f6:	45e5                	li	a1,25
ffffffffc02041f8:	00003517          	auipc	a0,0x3
ffffffffc02041fc:	96050513          	addi	a0,a0,-1696 # ffffffffc0206b58 <default_pmm_manager+0x5a8>
ffffffffc0204200:	fd5fb0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc0204204:	86b2                	mv	a3,a2
ffffffffc0204206:	06900593          	li	a1,105
ffffffffc020420a:	00002617          	auipc	a2,0x2
ffffffffc020420e:	8a660613          	addi	a2,a2,-1882 # ffffffffc0205ab0 <commands+0x980>
ffffffffc0204212:	00002517          	auipc	a0,0x2
ffffffffc0204216:	88e50513          	addi	a0,a0,-1906 # ffffffffc0205aa0 <commands+0x970>
ffffffffc020421a:	fbbfb0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc020421e <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc020421e:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204222:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204226:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204228:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc020422a:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc020422e:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204232:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204236:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc020423a:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc020423e:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204242:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204246:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc020424a:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc020424e:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204252:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204256:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc020425a:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc020425c:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc020425e:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204262:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204266:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc020426a:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc020426e:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204272:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204276:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc020427a:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc020427e:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204282:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204286:	8082                	ret

ffffffffc0204288 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204288:	8526                	mv	a0,s1
	jalr s0
ffffffffc020428a:	9402                	jalr	s0

	jal do_exit
ffffffffc020428c:	3ca000ef          	jal	ra,ffffffffc0204656 <do_exit>

ffffffffc0204290 <alloc_proc>:
/* 
 * alloc_proc - alloc a proc_struct and init all fields of proc_struct
 * 功能:创建一个proc_struct并初始化proc_struct的所有成员变量
 */
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204290:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204292:	0e800513          	li	a0,232
alloc_proc(void) {
ffffffffc0204296:	e022                	sd	s0,0(sp)
ffffffffc0204298:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc020429a:	f8cfd0ef          	jal	ra,ffffffffc0201a26 <kmalloc>
ffffffffc020429e:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc02042a0:	c521                	beqz	a0,ffffffffc02042e8 <alloc_proc+0x58>
     *       uint32_t flags;                             // 进程标志
     *       char name[PROC_NAME_LEN + 1];               // 进程名称
     */
    //注:初始化是指产生一个空的结构体(或许与c不允许在定义初始化默认值有关),两个memset初始化的变量参考自proc_init()
    //   附注:初始化的具体严格要求参考proc_init()的相关检查语句。
    proc->state        = PROC_UNINIT;
ffffffffc02042a2:	57fd                	li	a5,-1
ffffffffc02042a4:	1782                	slli	a5,a5,0x20
ffffffffc02042a6:	e11c                	sd	a5,0(a0)
    proc->runs         = 0; 
    proc->kstack       = 0;    
    proc->need_resched = 0;
    proc->parent       = NULL;
    proc->mm           = NULL;
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc02042a8:	07000613          	li	a2,112
ffffffffc02042ac:	4581                	li	a1,0
    proc->runs         = 0; 
ffffffffc02042ae:	00052423          	sw	zero,8(a0)
    proc->kstack       = 0;    
ffffffffc02042b2:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc02042b6:	00052c23          	sw	zero,24(a0)
    proc->parent       = NULL;
ffffffffc02042ba:	02053023          	sd	zero,32(a0)
    proc->mm           = NULL;
ffffffffc02042be:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc02042c2:	03050513          	addi	a0,a0,48
ffffffffc02042c6:	758000ef          	jal	ra,ffffffffc0204a1e <memset>
    proc->tf           = NULL;
    proc->cr3          = boot_cr3;
ffffffffc02042ca:	00011797          	auipc	a5,0x11
ffffffffc02042ce:	2b67b783          	ld	a5,694(a5) # ffffffffc0215580 <boot_cr3>
    proc->tf           = NULL;
ffffffffc02042d2:	0a043023          	sd	zero,160(s0)
    proc->cr3          = boot_cr3;
ffffffffc02042d6:	f45c                	sd	a5,168(s0)
    proc->flags        = 0;
ffffffffc02042d8:	0a042823          	sw	zero,176(s0)
    memset(proc->name, 0, PROC_NAME_LEN+1);                      
ffffffffc02042dc:	4641                	li	a2,16
ffffffffc02042de:	4581                	li	a1,0
ffffffffc02042e0:	0b440513          	addi	a0,s0,180
ffffffffc02042e4:	73a000ef          	jal	ra,ffffffffc0204a1e <memset>
//################################################################################
    }
    return proc;
}
ffffffffc02042e8:	60a2                	ld	ra,8(sp)
ffffffffc02042ea:	8522                	mv	a0,s0
ffffffffc02042ec:	6402                	ld	s0,0(sp)
ffffffffc02042ee:	0141                	addi	sp,sp,16
ffffffffc02042f0:	8082                	ret

ffffffffc02042f2 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc02042f2:	00011797          	auipc	a5,0x11
ffffffffc02042f6:	2be7b783          	ld	a5,702(a5) # ffffffffc02155b0 <current>
ffffffffc02042fa:	73c8                	ld	a0,160(a5)
ffffffffc02042fc:	87dfc06f          	j	ffffffffc0200b78 <forkrets>

ffffffffc0204300 <init_main>:

/* init_main - the second kernel thread used to create user_main kernel threads
 * 功能:用于创建第二个内核线程user_main
 */
static int
init_main(void *arg) {
ffffffffc0204300:	7179                	addi	sp,sp,-48
ffffffffc0204302:	ec26                	sd	s1,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc0204304:	00011497          	auipc	s1,0x11
ffffffffc0204308:	21448493          	addi	s1,s1,532 # ffffffffc0215518 <name.2>
init_main(void *arg) {
ffffffffc020430c:	f022                	sd	s0,32(sp)
ffffffffc020430e:	e84a                	sd	s2,16(sp)
ffffffffc0204310:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204312:	00011917          	auipc	s2,0x11
ffffffffc0204316:	29e93903          	ld	s2,670(s2) # ffffffffc02155b0 <current>
    memset(name, 0, sizeof(name));
ffffffffc020431a:	4641                	li	a2,16
ffffffffc020431c:	4581                	li	a1,0
ffffffffc020431e:	8526                	mv	a0,s1
init_main(void *arg) {
ffffffffc0204320:	f406                	sd	ra,40(sp)
ffffffffc0204322:	e44e                	sd	s3,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204324:	00492983          	lw	s3,4(s2)
    memset(name, 0, sizeof(name));
ffffffffc0204328:	6f6000ef          	jal	ra,ffffffffc0204a1e <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020432c:	0b490593          	addi	a1,s2,180
ffffffffc0204330:	463d                	li	a2,15
ffffffffc0204332:	8526                	mv	a0,s1
ffffffffc0204334:	6fc000ef          	jal	ra,ffffffffc0204a30 <memcpy>
ffffffffc0204338:	862a                	mv	a2,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020433a:	85ce                	mv	a1,s3
ffffffffc020433c:	00003517          	auipc	a0,0x3
ffffffffc0204340:	85450513          	addi	a0,a0,-1964 # ffffffffc0206b90 <default_pmm_manager+0x5e0>
ffffffffc0204344:	d95fb0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc0204348:	85a2                	mv	a1,s0
ffffffffc020434a:	00003517          	auipc	a0,0x3
ffffffffc020434e:	86e50513          	addi	a0,a0,-1938 # ffffffffc0206bb8 <default_pmm_manager+0x608>
ffffffffc0204352:	d87fb0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc0204356:	00003517          	auipc	a0,0x3
ffffffffc020435a:	87250513          	addi	a0,a0,-1934 # ffffffffc0206bc8 <default_pmm_manager+0x618>
ffffffffc020435e:	d7bfb0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    return 0;
}
ffffffffc0204362:	70a2                	ld	ra,40(sp)
ffffffffc0204364:	7402                	ld	s0,32(sp)
ffffffffc0204366:	64e2                	ld	s1,24(sp)
ffffffffc0204368:	6942                	ld	s2,16(sp)
ffffffffc020436a:	69a2                	ld	s3,8(sp)
ffffffffc020436c:	4501                	li	a0,0
ffffffffc020436e:	6145                	addi	sp,sp,48
ffffffffc0204370:	8082                	ret

ffffffffc0204372 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204372:	7179                	addi	sp,sp,-48
ffffffffc0204374:	ec26                	sd	s1,24(sp)
    if (proc != current) 
ffffffffc0204376:	00011497          	auipc	s1,0x11
ffffffffc020437a:	23a48493          	addi	s1,s1,570 # ffffffffc02155b0 <current>
proc_run(struct proc_struct *proc) {
ffffffffc020437e:	e84a                	sd	s2,16(sp)
    if (proc != current) 
ffffffffc0204380:	0004b903          	ld	s2,0(s1)
proc_run(struct proc_struct *proc) {
ffffffffc0204384:	f406                	sd	ra,40(sp)
ffffffffc0204386:	f022                	sd	s0,32(sp)
ffffffffc0204388:	e44e                	sd	s3,8(sp)
    if (proc != current) 
ffffffffc020438a:	02a90963          	beq	s2,a0,ffffffffc02043bc <proc_run+0x4a>
ffffffffc020438e:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204390:	100027f3          	csrr	a5,sstatus
ffffffffc0204394:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204396:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204398:	e3a9                	bnez	a5,ffffffffc02043da <proc_run+0x68>
        lcr3(proc->cr3);                              // 修改CR3寄存器的值
ffffffffc020439a:	745c                	ld	a5,168(s0)

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc020439c:	80000737          	lui	a4,0x80000
ffffffffc02043a0:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc02043a4:	8fd9                	or	a5,a5,a4
ffffffffc02043a6:	18079073          	csrw	satp,a5
        switch_to(&from->context,&proc->context);     // 两个进程之间的上下文切换
ffffffffc02043aa:	03040593          	addi	a1,s0,48
ffffffffc02043ae:	03090513          	addi	a0,s2,48
        current = proc;                               // 必须写在下一行之前(原因待研究)
ffffffffc02043b2:	e080                	sd	s0,0(s1)
        switch_to(&from->context,&proc->context);     // 两个进程之间的上下文切换
ffffffffc02043b4:	e6bff0ef          	jal	ra,ffffffffc020421e <switch_to>
    if (flag) {
ffffffffc02043b8:	00099963          	bnez	s3,ffffffffc02043ca <proc_run+0x58>
}
ffffffffc02043bc:	70a2                	ld	ra,40(sp)
ffffffffc02043be:	7402                	ld	s0,32(sp)
ffffffffc02043c0:	64e2                	ld	s1,24(sp)
ffffffffc02043c2:	6942                	ld	s2,16(sp)
ffffffffc02043c4:	69a2                	ld	s3,8(sp)
ffffffffc02043c6:	6145                	addi	sp,sp,48
ffffffffc02043c8:	8082                	ret
ffffffffc02043ca:	7402                	ld	s0,32(sp)
ffffffffc02043cc:	70a2                	ld	ra,40(sp)
ffffffffc02043ce:	64e2                	ld	s1,24(sp)
ffffffffc02043d0:	6942                	ld	s2,16(sp)
ffffffffc02043d2:	69a2                	ld	s3,8(sp)
ffffffffc02043d4:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc02043d6:	9f4fc06f          	j	ffffffffc02005ca <intr_enable>
        intr_disable();
ffffffffc02043da:	9f6fc0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        return 1;
ffffffffc02043de:	4985                	li	s3,1
ffffffffc02043e0:	bf6d                	j	ffffffffc020439a <proc_run+0x28>

ffffffffc02043e2 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02043e2:	7179                	addi	sp,sp,-48
ffffffffc02043e4:	e44e                	sd	s3,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02043e6:	00011997          	auipc	s3,0x11
ffffffffc02043ea:	1e298993          	addi	s3,s3,482 # ffffffffc02155c8 <nr_process>
ffffffffc02043ee:	0009a703          	lw	a4,0(s3)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02043f2:	f406                	sd	ra,40(sp)
ffffffffc02043f4:	f022                	sd	s0,32(sp)
ffffffffc02043f6:	ec26                	sd	s1,24(sp)
ffffffffc02043f8:	e84a                	sd	s2,16(sp)
ffffffffc02043fa:	e052                	sd	s4,0(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02043fc:	6785                	lui	a5,0x1
ffffffffc02043fe:	1cf75363          	bge	a4,a5,ffffffffc02045c4 <do_fork+0x1e2>
ffffffffc0204402:	892e                	mv	s2,a1
ffffffffc0204404:	8432                	mv	s0,a2
    proc = alloc_proc();                 //1.调用alloc_proc来分配proc_struct
ffffffffc0204406:	e8bff0ef          	jal	ra,ffffffffc0204290 <alloc_proc>
    if (++ last_pid >= MAX_PID) {
ffffffffc020440a:	00006897          	auipc	a7,0x6
ffffffffc020440e:	c4e88893          	addi	a7,a7,-946 # ffffffffc020a058 <last_pid.1>
ffffffffc0204412:	0008a783          	lw	a5,0(a7)
    proc->parent = current;
ffffffffc0204416:	00011a17          	auipc	s4,0x11
ffffffffc020441a:	19aa0a13          	addi	s4,s4,410 # ffffffffc02155b0 <current>
ffffffffc020441e:	000a3703          	ld	a4,0(s4)
    if (++ last_pid >= MAX_PID) {
ffffffffc0204422:	0017881b          	addiw	a6,a5,1
ffffffffc0204426:	0108a023          	sw	a6,0(a7)
    proc->parent = current;
ffffffffc020442a:	f118                	sd	a4,32(a0)
    if (++ last_pid >= MAX_PID) {
ffffffffc020442c:	6789                	lui	a5,0x2
    proc = alloc_proc();                 //1.调用alloc_proc来分配proc_struct
ffffffffc020442e:	84aa                	mv	s1,a0
    if (++ last_pid >= MAX_PID) {
ffffffffc0204430:	10f85763          	bge	a6,a5,ffffffffc020453e <do_fork+0x15c>
    if (last_pid >= next_safe) {
ffffffffc0204434:	00006e17          	auipc	t3,0x6
ffffffffc0204438:	c28e0e13          	addi	t3,t3,-984 # ffffffffc020a05c <next_safe.0>
ffffffffc020443c:	000e2783          	lw	a5,0(t3)
ffffffffc0204440:	10f85763          	bge	a6,a5,ffffffffc020454e <do_fork+0x16c>
    proc->pid = get_pid();
ffffffffc0204444:	0104a223          	sw	a6,4(s1)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204448:	4509                	li	a0,2
ffffffffc020444a:	b65fe0ef          	jal	ra,ffffffffc0202fae <alloc_pages>
    if (page != NULL) {
ffffffffc020444e:	cd0d                	beqz	a0,ffffffffc0204488 <do_fork+0xa6>
    return page - pages + nbase;
ffffffffc0204450:	00011697          	auipc	a3,0x11
ffffffffc0204454:	1486b683          	ld	a3,328(a3) # ffffffffc0215598 <pages>
ffffffffc0204458:	40d506b3          	sub	a3,a0,a3
ffffffffc020445c:	8699                	srai	a3,a3,0x6
ffffffffc020445e:	00003517          	auipc	a0,0x3
ffffffffc0204462:	b2a53503          	ld	a0,-1238(a0) # ffffffffc0206f88 <nbase>
ffffffffc0204466:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0204468:	00c69793          	slli	a5,a3,0xc
ffffffffc020446c:	83b1                	srli	a5,a5,0xc
ffffffffc020446e:	00011717          	auipc	a4,0x11
ffffffffc0204472:	12273703          	ld	a4,290(a4) # ffffffffc0215590 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0204476:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204478:	16e7fb63          	bgeu	a5,a4,ffffffffc02045ee <do_fork+0x20c>
ffffffffc020447c:	00011797          	auipc	a5,0x11
ffffffffc0204480:	12c7b783          	ld	a5,300(a5) # ffffffffc02155a8 <va_pa_offset>
ffffffffc0204484:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204486:	e894                	sd	a3,16(s1)
    assert(current->mm == NULL);
ffffffffc0204488:	000a3783          	ld	a5,0(s4)
ffffffffc020448c:	779c                	ld	a5,40(a5)
ffffffffc020448e:	14079063          	bnez	a5,ffffffffc02045ce <do_fork+0x1ec>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204492:	6898                	ld	a4,16(s1)
ffffffffc0204494:	6789                	lui	a5,0x2
ffffffffc0204496:	ee078793          	addi	a5,a5,-288 # 1ee0 <kern_entry-0xffffffffc01fe120>
ffffffffc020449a:	973e                	add	a4,a4,a5
    *(proc->tf) = *tf;
ffffffffc020449c:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc020449e:	f0d8                	sd	a4,160(s1)
    *(proc->tf) = *tf;
ffffffffc02044a0:	87ba                	mv	a5,a4
ffffffffc02044a2:	12040893          	addi	a7,s0,288
ffffffffc02044a6:	00063803          	ld	a6,0(a2)
ffffffffc02044aa:	6608                	ld	a0,8(a2)
ffffffffc02044ac:	6a0c                	ld	a1,16(a2)
ffffffffc02044ae:	6e14                	ld	a3,24(a2)
ffffffffc02044b0:	0107b023          	sd	a6,0(a5)
ffffffffc02044b4:	e788                	sd	a0,8(a5)
ffffffffc02044b6:	eb8c                	sd	a1,16(a5)
ffffffffc02044b8:	ef94                	sd	a3,24(a5)
ffffffffc02044ba:	02060613          	addi	a2,a2,32
ffffffffc02044be:	02078793          	addi	a5,a5,32
ffffffffc02044c2:	ff1612e3          	bne	a2,a7,ffffffffc02044a6 <do_fork+0xc4>
    proc->tf->gpr.a0 = 0;
ffffffffc02044c6:	04073823          	sd	zero,80(a4)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02044ca:	0e090163          	beqz	s2,ffffffffc02045ac <do_fork+0x1ca>
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02044ce:	40c8                	lw	a0,4(s1)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02044d0:	00000797          	auipc	a5,0x0
ffffffffc02044d4:	e2278793          	addi	a5,a5,-478 # ffffffffc02042f2 <forkret>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02044d8:	01273823          	sd	s2,16(a4)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02044dc:	45a9                	li	a1,10
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02044de:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02044e0:	fc98                	sd	a4,56(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02044e2:	179000ef          	jal	ra,ffffffffc0204e5a <hash32>
ffffffffc02044e6:	02051793          	slli	a5,a0,0x20
ffffffffc02044ea:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02044ee:	0000d797          	auipc	a5,0xd
ffffffffc02044f2:	02a78793          	addi	a5,a5,42 # ffffffffc0211518 <hash_list>
ffffffffc02044f6:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02044f8:	6514                	ld	a3,8(a0)
ffffffffc02044fa:	0d848793          	addi	a5,s1,216
    __list_add(elm, listelm->prev, listelm);
ffffffffc02044fe:	00011717          	auipc	a4,0x11
ffffffffc0204502:	02a70713          	addi	a4,a4,42 # ffffffffc0215528 <proc_list>
    prev->next = next->prev = elm;
ffffffffc0204506:	e29c                	sd	a5,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204508:	6310                	ld	a2,0(a4)
    prev->next = next->prev = elm;
ffffffffc020450a:	e51c                	sd	a5,8(a0)
    nr_process++;
ffffffffc020450c:	0009a783          	lw	a5,0(s3)
    elm->next = next;
ffffffffc0204510:	f0f4                	sd	a3,224(s1)
    elm->prev = prev;
ffffffffc0204512:	ece8                	sd	a0,216(s1)
    list_add_before(&proc_list,&proc->list_link); 
ffffffffc0204514:	0c848693          	addi	a3,s1,200
    prev->next = next->prev = elm;
ffffffffc0204518:	e614                	sd	a3,8(a2)
    nr_process++;
ffffffffc020451a:	2785                	addiw	a5,a5,1
    wakeup_proc(proc);//6.调用wakeup_proc将新的子进程的状态设为RUNNABLE
ffffffffc020451c:	8526                	mv	a0,s1
    elm->next = next;
ffffffffc020451e:	e8f8                	sd	a4,208(s1)
    elm->prev = prev;
ffffffffc0204520:	e4f0                	sd	a2,200(s1)
    prev->next = next->prev = elm;
ffffffffc0204522:	e314                	sd	a3,0(a4)
    nr_process++;
ffffffffc0204524:	00f9a023          	sw	a5,0(s3)
    wakeup_proc(proc);//6.调用wakeup_proc将新的子进程的状态设为RUNNABLE
ffffffffc0204528:	3b4000ef          	jal	ra,ffffffffc02048dc <wakeup_proc>
    ret = proc->pid;
ffffffffc020452c:	40c8                	lw	a0,4(s1)
}
ffffffffc020452e:	70a2                	ld	ra,40(sp)
ffffffffc0204530:	7402                	ld	s0,32(sp)
ffffffffc0204532:	64e2                	ld	s1,24(sp)
ffffffffc0204534:	6942                	ld	s2,16(sp)
ffffffffc0204536:	69a2                	ld	s3,8(sp)
ffffffffc0204538:	6a02                	ld	s4,0(sp)
ffffffffc020453a:	6145                	addi	sp,sp,48
ffffffffc020453c:	8082                	ret
        last_pid = 1;
ffffffffc020453e:	4785                	li	a5,1
ffffffffc0204540:	00f8a023          	sw	a5,0(a7)
        goto inside;
ffffffffc0204544:	4805                	li	a6,1
ffffffffc0204546:	00006e17          	auipc	t3,0x6
ffffffffc020454a:	b16e0e13          	addi	t3,t3,-1258 # ffffffffc020a05c <next_safe.0>
    return listelm->next;
ffffffffc020454e:	00011617          	auipc	a2,0x11
ffffffffc0204552:	fda60613          	addi	a2,a2,-38 # ffffffffc0215528 <proc_list>
ffffffffc0204556:	00863e83          	ld	t4,8(a2)
        next_safe = MAX_PID;
ffffffffc020455a:	6789                	lui	a5,0x2
ffffffffc020455c:	00fe2023          	sw	a5,0(t3)
ffffffffc0204560:	86c2                	mv	a3,a6
ffffffffc0204562:	4501                	li	a0,0
        while ((le = list_next(le)) != list) {
ffffffffc0204564:	6f09                	lui	t5,0x2
ffffffffc0204566:	04ce8a63          	beq	t4,a2,ffffffffc02045ba <do_fork+0x1d8>
ffffffffc020456a:	832a                	mv	t1,a0
ffffffffc020456c:	87f6                	mv	a5,t4
ffffffffc020456e:	6589                	lui	a1,0x2
ffffffffc0204570:	a811                	j	ffffffffc0204584 <do_fork+0x1a2>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0204572:	00e6d663          	bge	a3,a4,ffffffffc020457e <do_fork+0x19c>
ffffffffc0204576:	00b75463          	bge	a4,a1,ffffffffc020457e <do_fork+0x19c>
ffffffffc020457a:	85ba                	mv	a1,a4
ffffffffc020457c:	4305                	li	t1,1
ffffffffc020457e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204580:	00c78d63          	beq	a5,a2,ffffffffc020459a <do_fork+0x1b8>
            if (proc->pid == last_pid) {
ffffffffc0204584:	f3c7a703          	lw	a4,-196(a5) # 1f3c <kern_entry-0xffffffffc01fe0c4>
ffffffffc0204588:	fee695e3          	bne	a3,a4,ffffffffc0204572 <do_fork+0x190>
                if (++ last_pid >= next_safe) {
ffffffffc020458c:	2685                	addiw	a3,a3,1
ffffffffc020458e:	02b6d163          	bge	a3,a1,ffffffffc02045b0 <do_fork+0x1ce>
ffffffffc0204592:	679c                	ld	a5,8(a5)
ffffffffc0204594:	4505                	li	a0,1
        while ((le = list_next(le)) != list) {
ffffffffc0204596:	fec797e3          	bne	a5,a2,ffffffffc0204584 <do_fork+0x1a2>
ffffffffc020459a:	c501                	beqz	a0,ffffffffc02045a2 <do_fork+0x1c0>
ffffffffc020459c:	00d8a023          	sw	a3,0(a7)
ffffffffc02045a0:	8836                	mv	a6,a3
ffffffffc02045a2:	ea0301e3          	beqz	t1,ffffffffc0204444 <do_fork+0x62>
ffffffffc02045a6:	00be2023          	sw	a1,0(t3)
ffffffffc02045aa:	bd69                	j	ffffffffc0204444 <do_fork+0x62>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02045ac:	893a                	mv	s2,a4
ffffffffc02045ae:	b705                	j	ffffffffc02044ce <do_fork+0xec>
                    if (last_pid >= MAX_PID) {
ffffffffc02045b0:	01e6c363          	blt	a3,t5,ffffffffc02045b6 <do_fork+0x1d4>
                        last_pid = 1;
ffffffffc02045b4:	4685                	li	a3,1
                    goto repeat;
ffffffffc02045b6:	4505                	li	a0,1
ffffffffc02045b8:	b77d                	j	ffffffffc0204566 <do_fork+0x184>
ffffffffc02045ba:	c519                	beqz	a0,ffffffffc02045c8 <do_fork+0x1e6>
ffffffffc02045bc:	00d8a023          	sw	a3,0(a7)
    return last_pid;
ffffffffc02045c0:	8836                	mv	a6,a3
ffffffffc02045c2:	b549                	j	ffffffffc0204444 <do_fork+0x62>
    int ret = -E_NO_FREE_PROC;
ffffffffc02045c4:	556d                	li	a0,-5
    return ret;
ffffffffc02045c6:	b7a5                	j	ffffffffc020452e <do_fork+0x14c>
    return last_pid;
ffffffffc02045c8:	0008a803          	lw	a6,0(a7)
ffffffffc02045cc:	bda5                	j	ffffffffc0204444 <do_fork+0x62>
    assert(current->mm == NULL);
ffffffffc02045ce:	00002697          	auipc	a3,0x2
ffffffffc02045d2:	61a68693          	addi	a3,a3,1562 # ffffffffc0206be8 <default_pmm_manager+0x638>
ffffffffc02045d6:	00001617          	auipc	a2,0x1
ffffffffc02045da:	28260613          	addi	a2,a2,642 # ffffffffc0205858 <commands+0x728>
ffffffffc02045de:	11900593          	li	a1,281
ffffffffc02045e2:	00002517          	auipc	a0,0x2
ffffffffc02045e6:	61e50513          	addi	a0,a0,1566 # ffffffffc0206c00 <default_pmm_manager+0x650>
ffffffffc02045ea:	bebfb0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc02045ee:	00001617          	auipc	a2,0x1
ffffffffc02045f2:	4c260613          	addi	a2,a2,1218 # ffffffffc0205ab0 <commands+0x980>
ffffffffc02045f6:	06900593          	li	a1,105
ffffffffc02045fa:	00001517          	auipc	a0,0x1
ffffffffc02045fe:	4a650513          	addi	a0,a0,1190 # ffffffffc0205aa0 <commands+0x970>
ffffffffc0204602:	bd3fb0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0204606 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0204606:	7129                	addi	sp,sp,-320
ffffffffc0204608:	fa22                	sd	s0,304(sp)
ffffffffc020460a:	f626                	sd	s1,296(sp)
ffffffffc020460c:	f24a                	sd	s2,288(sp)
ffffffffc020460e:	84ae                	mv	s1,a1
ffffffffc0204610:	892a                	mv	s2,a0
ffffffffc0204612:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204614:	4581                	li	a1,0
ffffffffc0204616:	12000613          	li	a2,288
ffffffffc020461a:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020461c:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020461e:	400000ef          	jal	ra,ffffffffc0204a1e <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0204622:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0204624:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204626:	100027f3          	csrr	a5,sstatus
ffffffffc020462a:	edd7f793          	andi	a5,a5,-291
ffffffffc020462e:	1207e793          	ori	a5,a5,288
ffffffffc0204632:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204634:	860a                	mv	a2,sp
ffffffffc0204636:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020463a:	00000797          	auipc	a5,0x0
ffffffffc020463e:	c4e78793          	addi	a5,a5,-946 # ffffffffc0204288 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204642:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204644:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204646:	d9dff0ef          	jal	ra,ffffffffc02043e2 <do_fork>
}
ffffffffc020464a:	70f2                	ld	ra,312(sp)
ffffffffc020464c:	7452                	ld	s0,304(sp)
ffffffffc020464e:	74b2                	ld	s1,296(sp)
ffffffffc0204650:	7912                	ld	s2,288(sp)
ffffffffc0204652:	6131                	addi	sp,sp,320
ffffffffc0204654:	8082                	ret

ffffffffc0204656 <do_exit>:
do_exit(int error_code) {
ffffffffc0204656:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc0204658:	00002617          	auipc	a2,0x2
ffffffffc020465c:	5c060613          	addi	a2,a2,1472 # ffffffffc0206c18 <default_pmm_manager+0x668>
ffffffffc0204660:	17d00593          	li	a1,381
ffffffffc0204664:	00002517          	auipc	a0,0x2
ffffffffc0204668:	59c50513          	addi	a0,a0,1436 # ffffffffc0206c00 <default_pmm_manager+0x650>
do_exit(int error_code) {
ffffffffc020466c:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc020466e:	b67fb0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0204672 <proc_init>:
/* proc_init - set up the first kernel thread idleproc "idle" by itself and 
 *           - create the second kernel thread init_main
 * 功能:第一个内核线程<空闲线程(idleproc)>将自己的状态设为空闲，并创建第二个内核线程init_main
 */
void
proc_init(void) {
ffffffffc0204672:	7179                	addi	sp,sp,-48
ffffffffc0204674:	ec26                	sd	s1,24(sp)
    elm->prev = elm->next = elm;
ffffffffc0204676:	00011797          	auipc	a5,0x11
ffffffffc020467a:	eb278793          	addi	a5,a5,-334 # ffffffffc0215528 <proc_list>
ffffffffc020467e:	f406                	sd	ra,40(sp)
ffffffffc0204680:	f022                	sd	s0,32(sp)
ffffffffc0204682:	e84a                	sd	s2,16(sp)
ffffffffc0204684:	e44e                	sd	s3,8(sp)
ffffffffc0204686:	0000d497          	auipc	s1,0xd
ffffffffc020468a:	e9248493          	addi	s1,s1,-366 # ffffffffc0211518 <hash_list>
ffffffffc020468e:	e79c                	sd	a5,8(a5)
ffffffffc0204690:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0204692:	00011717          	auipc	a4,0x11
ffffffffc0204696:	e8670713          	addi	a4,a4,-378 # ffffffffc0215518 <name.2>
ffffffffc020469a:	87a6                	mv	a5,s1
ffffffffc020469c:	e79c                	sd	a5,8(a5)
ffffffffc020469e:	e39c                	sd	a5,0(a5)
ffffffffc02046a0:	07c1                	addi	a5,a5,16
ffffffffc02046a2:	fef71de3          	bne	a4,a5,ffffffffc020469c <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02046a6:	bebff0ef          	jal	ra,ffffffffc0204290 <alloc_proc>
ffffffffc02046aa:	00011917          	auipc	s2,0x11
ffffffffc02046ae:	f0e90913          	addi	s2,s2,-242 # ffffffffc02155b8 <idleproc>
ffffffffc02046b2:	00a93023          	sd	a0,0(s2)
ffffffffc02046b6:	18050d63          	beqz	a0,ffffffffc0204850 <proc_init+0x1de>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02046ba:	07000513          	li	a0,112
ffffffffc02046be:	b68fd0ef          	jal	ra,ffffffffc0201a26 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02046c2:	07000613          	li	a2,112
ffffffffc02046c6:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02046c8:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02046ca:	354000ef          	jal	ra,ffffffffc0204a1e <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc02046ce:	00093503          	ld	a0,0(s2)
ffffffffc02046d2:	85a2                	mv	a1,s0
ffffffffc02046d4:	07000613          	li	a2,112
ffffffffc02046d8:	03050513          	addi	a0,a0,48
ffffffffc02046dc:	36c000ef          	jal	ra,ffffffffc0204a48 <memcmp>
ffffffffc02046e0:	89aa                	mv	s3,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02046e2:	453d                	li	a0,15
ffffffffc02046e4:	b42fd0ef          	jal	ra,ffffffffc0201a26 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02046e8:	463d                	li	a2,15
ffffffffc02046ea:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02046ec:	842a                	mv	s0,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02046ee:	330000ef          	jal	ra,ffffffffc0204a1e <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc02046f2:	00093503          	ld	a0,0(s2)
ffffffffc02046f6:	463d                	li	a2,15
ffffffffc02046f8:	85a2                	mv	a1,s0
ffffffffc02046fa:	0b450513          	addi	a0,a0,180
ffffffffc02046fe:	34a000ef          	jal	ra,ffffffffc0204a48 <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc0204702:	00093783          	ld	a5,0(s2)
ffffffffc0204706:	00011717          	auipc	a4,0x11
ffffffffc020470a:	e7a73703          	ld	a4,-390(a4) # ffffffffc0215580 <boot_cr3>
ffffffffc020470e:	77d4                	ld	a3,168(a5)
ffffffffc0204710:	0ee68463          	beq	a3,a4,ffffffffc02047f8 <proc_init+0x186>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0204714:	4709                	li	a4,2
ffffffffc0204716:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204718:	00003717          	auipc	a4,0x3
ffffffffc020471c:	8e870713          	addi	a4,a4,-1816 # ffffffffc0207000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204720:	0b478413          	addi	s0,a5,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204724:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc0204726:	4705                	li	a4,1
ffffffffc0204728:	cf98                	sw	a4,24(a5)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020472a:	4641                	li	a2,16
ffffffffc020472c:	4581                	li	a1,0
ffffffffc020472e:	8522                	mv	a0,s0
ffffffffc0204730:	2ee000ef          	jal	ra,ffffffffc0204a1e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204734:	463d                	li	a2,15
ffffffffc0204736:	00002597          	auipc	a1,0x2
ffffffffc020473a:	52a58593          	addi	a1,a1,1322 # ffffffffc0206c60 <default_pmm_manager+0x6b0>
ffffffffc020473e:	8522                	mv	a0,s0
ffffffffc0204740:	2f0000ef          	jal	ra,ffffffffc0204a30 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0204744:	00011717          	auipc	a4,0x11
ffffffffc0204748:	e8470713          	addi	a4,a4,-380 # ffffffffc02155c8 <nr_process>
ffffffffc020474c:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc020474e:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204752:	4601                	li	a2,0
    nr_process ++;
ffffffffc0204754:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204756:	00002597          	auipc	a1,0x2
ffffffffc020475a:	51258593          	addi	a1,a1,1298 # ffffffffc0206c68 <default_pmm_manager+0x6b8>
ffffffffc020475e:	00000517          	auipc	a0,0x0
ffffffffc0204762:	ba250513          	addi	a0,a0,-1118 # ffffffffc0204300 <init_main>
    nr_process ++;
ffffffffc0204766:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0204768:	00011797          	auipc	a5,0x11
ffffffffc020476c:	e4d7b423          	sd	a3,-440(a5) # ffffffffc02155b0 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204770:	e97ff0ef          	jal	ra,ffffffffc0204606 <kernel_thread>
ffffffffc0204774:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0204776:	0ea05963          	blez	a0,ffffffffc0204868 <proc_init+0x1f6>
    if (0 < pid && pid < MAX_PID) {
ffffffffc020477a:	6789                	lui	a5,0x2
ffffffffc020477c:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204780:	17f9                	addi	a5,a5,-2
ffffffffc0204782:	2501                	sext.w	a0,a0
ffffffffc0204784:	02e7e363          	bltu	a5,a4,ffffffffc02047aa <proc_init+0x138>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204788:	45a9                	li	a1,10
ffffffffc020478a:	6d0000ef          	jal	ra,ffffffffc0204e5a <hash32>
ffffffffc020478e:	02051793          	slli	a5,a0,0x20
ffffffffc0204792:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204796:	96a6                	add	a3,a3,s1
ffffffffc0204798:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc020479a:	a029                	j	ffffffffc02047a4 <proc_init+0x132>
            if (proc->pid == pid) {
ffffffffc020479c:	f2c7a703          	lw	a4,-212(a5) # 1f2c <kern_entry-0xffffffffc01fe0d4>
ffffffffc02047a0:	0a870563          	beq	a4,s0,ffffffffc020484a <proc_init+0x1d8>
    return listelm->next;
ffffffffc02047a4:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02047a6:	fef69be3          	bne	a3,a5,ffffffffc020479c <proc_init+0x12a>
    return NULL;
ffffffffc02047aa:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02047ac:	0b478493          	addi	s1,a5,180
ffffffffc02047b0:	4641                	li	a2,16
ffffffffc02047b2:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc02047b4:	00011417          	auipc	s0,0x11
ffffffffc02047b8:	e0c40413          	addi	s0,s0,-500 # ffffffffc02155c0 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02047bc:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc02047be:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02047c0:	25e000ef          	jal	ra,ffffffffc0204a1e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02047c4:	463d                	li	a2,15
ffffffffc02047c6:	00002597          	auipc	a1,0x2
ffffffffc02047ca:	4d258593          	addi	a1,a1,1234 # ffffffffc0206c98 <default_pmm_manager+0x6e8>
ffffffffc02047ce:	8526                	mv	a0,s1
ffffffffc02047d0:	260000ef          	jal	ra,ffffffffc0204a30 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02047d4:	00093783          	ld	a5,0(s2)
ffffffffc02047d8:	c7e1                	beqz	a5,ffffffffc02048a0 <proc_init+0x22e>
ffffffffc02047da:	43dc                	lw	a5,4(a5)
ffffffffc02047dc:	e3f1                	bnez	a5,ffffffffc02048a0 <proc_init+0x22e>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02047de:	601c                	ld	a5,0(s0)
ffffffffc02047e0:	c3c5                	beqz	a5,ffffffffc0204880 <proc_init+0x20e>
ffffffffc02047e2:	43d8                	lw	a4,4(a5)
ffffffffc02047e4:	4785                	li	a5,1
ffffffffc02047e6:	08f71d63          	bne	a4,a5,ffffffffc0204880 <proc_init+0x20e>
}
ffffffffc02047ea:	70a2                	ld	ra,40(sp)
ffffffffc02047ec:	7402                	ld	s0,32(sp)
ffffffffc02047ee:	64e2                	ld	s1,24(sp)
ffffffffc02047f0:	6942                	ld	s2,16(sp)
ffffffffc02047f2:	69a2                	ld	s3,8(sp)
ffffffffc02047f4:	6145                	addi	sp,sp,48
ffffffffc02047f6:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02047f8:	73d8                	ld	a4,160(a5)
ffffffffc02047fa:	ff09                	bnez	a4,ffffffffc0204714 <proc_init+0xa2>
ffffffffc02047fc:	f0099ce3          	bnez	s3,ffffffffc0204714 <proc_init+0xa2>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc0204800:	6394                	ld	a3,0(a5)
ffffffffc0204802:	577d                	li	a4,-1
ffffffffc0204804:	1702                	slli	a4,a4,0x20
ffffffffc0204806:	f0e697e3          	bne	a3,a4,ffffffffc0204714 <proc_init+0xa2>
ffffffffc020480a:	4798                	lw	a4,8(a5)
ffffffffc020480c:	f00714e3          	bnez	a4,ffffffffc0204714 <proc_init+0xa2>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc0204810:	6b98                	ld	a4,16(a5)
ffffffffc0204812:	f00711e3          	bnez	a4,ffffffffc0204714 <proc_init+0xa2>
ffffffffc0204816:	4f98                	lw	a4,24(a5)
ffffffffc0204818:	2701                	sext.w	a4,a4
ffffffffc020481a:	ee071de3          	bnez	a4,ffffffffc0204714 <proc_init+0xa2>
ffffffffc020481e:	7398                	ld	a4,32(a5)
ffffffffc0204820:	ee071ae3          	bnez	a4,ffffffffc0204714 <proc_init+0xa2>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc0204824:	7798                	ld	a4,40(a5)
ffffffffc0204826:	ee0717e3          	bnez	a4,ffffffffc0204714 <proc_init+0xa2>
ffffffffc020482a:	0b07a703          	lw	a4,176(a5)
ffffffffc020482e:	8d59                	or	a0,a0,a4
ffffffffc0204830:	0005071b          	sext.w	a4,a0
ffffffffc0204834:	ee0710e3          	bnez	a4,ffffffffc0204714 <proc_init+0xa2>
        cprintf("alloc_proc() correct!\n");
ffffffffc0204838:	00002517          	auipc	a0,0x2
ffffffffc020483c:	41050513          	addi	a0,a0,1040 # ffffffffc0206c48 <default_pmm_manager+0x698>
ffffffffc0204840:	899fb0ef          	jal	ra,ffffffffc02000d8 <cprintf>
    idleproc->pid = 0;
ffffffffc0204844:	00093783          	ld	a5,0(s2)
ffffffffc0204848:	b5f1                	j	ffffffffc0204714 <proc_init+0xa2>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020484a:	f2878793          	addi	a5,a5,-216
ffffffffc020484e:	bfb9                	j	ffffffffc02047ac <proc_init+0x13a>
        panic("cannot alloc idleproc.\n");
ffffffffc0204850:	00002617          	auipc	a2,0x2
ffffffffc0204854:	3e060613          	addi	a2,a2,992 # ffffffffc0206c30 <default_pmm_manager+0x680>
ffffffffc0204858:	19900593          	li	a1,409
ffffffffc020485c:	00002517          	auipc	a0,0x2
ffffffffc0204860:	3a450513          	addi	a0,a0,932 # ffffffffc0206c00 <default_pmm_manager+0x650>
ffffffffc0204864:	971fb0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("create init_main failed.\n");
ffffffffc0204868:	00002617          	auipc	a2,0x2
ffffffffc020486c:	41060613          	addi	a2,a2,1040 # ffffffffc0206c78 <default_pmm_manager+0x6c8>
ffffffffc0204870:	1b900593          	li	a1,441
ffffffffc0204874:	00002517          	auipc	a0,0x2
ffffffffc0204878:	38c50513          	addi	a0,a0,908 # ffffffffc0206c00 <default_pmm_manager+0x650>
ffffffffc020487c:	959fb0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204880:	00002697          	auipc	a3,0x2
ffffffffc0204884:	44868693          	addi	a3,a3,1096 # ffffffffc0206cc8 <default_pmm_manager+0x718>
ffffffffc0204888:	00001617          	auipc	a2,0x1
ffffffffc020488c:	fd060613          	addi	a2,a2,-48 # ffffffffc0205858 <commands+0x728>
ffffffffc0204890:	1c000593          	li	a1,448
ffffffffc0204894:	00002517          	auipc	a0,0x2
ffffffffc0204898:	36c50513          	addi	a0,a0,876 # ffffffffc0206c00 <default_pmm_manager+0x650>
ffffffffc020489c:	939fb0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02048a0:	00002697          	auipc	a3,0x2
ffffffffc02048a4:	40068693          	addi	a3,a3,1024 # ffffffffc0206ca0 <default_pmm_manager+0x6f0>
ffffffffc02048a8:	00001617          	auipc	a2,0x1
ffffffffc02048ac:	fb060613          	addi	a2,a2,-80 # ffffffffc0205858 <commands+0x728>
ffffffffc02048b0:	1bf00593          	li	a1,447
ffffffffc02048b4:	00002517          	auipc	a0,0x2
ffffffffc02048b8:	34c50513          	addi	a0,a0,844 # ffffffffc0206c00 <default_pmm_manager+0x650>
ffffffffc02048bc:	919fb0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02048c0 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc02048c0:	1141                	addi	sp,sp,-16
ffffffffc02048c2:	e022                	sd	s0,0(sp)
ffffffffc02048c4:	e406                	sd	ra,8(sp)
ffffffffc02048c6:	00011417          	auipc	s0,0x11
ffffffffc02048ca:	cea40413          	addi	s0,s0,-790 # ffffffffc02155b0 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc02048ce:	6018                	ld	a4,0(s0)
ffffffffc02048d0:	4f1c                	lw	a5,24(a4)
ffffffffc02048d2:	2781                	sext.w	a5,a5
ffffffffc02048d4:	dff5                	beqz	a5,ffffffffc02048d0 <cpu_idle+0x10>
            schedule();
ffffffffc02048d6:	038000ef          	jal	ra,ffffffffc020490e <schedule>
ffffffffc02048da:	bfd5                	j	ffffffffc02048ce <cpu_idle+0xe>

ffffffffc02048dc <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc02048dc:	411c                	lw	a5,0(a0)
ffffffffc02048de:	4705                	li	a4,1
ffffffffc02048e0:	37f9                	addiw	a5,a5,-2
ffffffffc02048e2:	00f77563          	bgeu	a4,a5,ffffffffc02048ec <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc02048e6:	4789                	li	a5,2
ffffffffc02048e8:	c11c                	sw	a5,0(a0)
ffffffffc02048ea:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc02048ec:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc02048ee:	00002697          	auipc	a3,0x2
ffffffffc02048f2:	40268693          	addi	a3,a3,1026 # ffffffffc0206cf0 <default_pmm_manager+0x740>
ffffffffc02048f6:	00001617          	auipc	a2,0x1
ffffffffc02048fa:	f6260613          	addi	a2,a2,-158 # ffffffffc0205858 <commands+0x728>
ffffffffc02048fe:	45a5                	li	a1,9
ffffffffc0204900:	00002517          	auipc	a0,0x2
ffffffffc0204904:	43050513          	addi	a0,a0,1072 # ffffffffc0206d30 <default_pmm_manager+0x780>
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204908:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020490a:	8cbfb0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc020490e <schedule>:
}

void
schedule(void) {
ffffffffc020490e:	1141                	addi	sp,sp,-16
ffffffffc0204910:	e406                	sd	ra,8(sp)
ffffffffc0204912:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204914:	100027f3          	csrr	a5,sstatus
ffffffffc0204918:	8b89                	andi	a5,a5,2
ffffffffc020491a:	4401                	li	s0,0
ffffffffc020491c:	efbd                	bnez	a5,ffffffffc020499a <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc020491e:	00011897          	auipc	a7,0x11
ffffffffc0204922:	c928b883          	ld	a7,-878(a7) # ffffffffc02155b0 <current>
ffffffffc0204926:	0008ac23          	sw	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020492a:	00011517          	auipc	a0,0x11
ffffffffc020492e:	c8e53503          	ld	a0,-882(a0) # ffffffffc02155b8 <idleproc>
ffffffffc0204932:	04a88e63          	beq	a7,a0,ffffffffc020498e <schedule+0x80>
ffffffffc0204936:	0c888693          	addi	a3,a7,200
ffffffffc020493a:	00011617          	auipc	a2,0x11
ffffffffc020493e:	bee60613          	addi	a2,a2,-1042 # ffffffffc0215528 <proc_list>
        le = last;
ffffffffc0204942:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0204944:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204946:	4809                	li	a6,2
ffffffffc0204948:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc020494a:	00c78863          	beq	a5,a2,ffffffffc020495a <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc020494e:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0204952:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204956:	03070163          	beq	a4,a6,ffffffffc0204978 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc020495a:	fef697e3          	bne	a3,a5,ffffffffc0204948 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020495e:	ed89                	bnez	a1,ffffffffc0204978 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0204960:	451c                	lw	a5,8(a0)
ffffffffc0204962:	2785                	addiw	a5,a5,1
ffffffffc0204964:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0204966:	00a88463          	beq	a7,a0,ffffffffc020496e <schedule+0x60>
            proc_run(next);
ffffffffc020496a:	a09ff0ef          	jal	ra,ffffffffc0204372 <proc_run>
    if (flag) {
ffffffffc020496e:	e819                	bnez	s0,ffffffffc0204984 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0204970:	60a2                	ld	ra,8(sp)
ffffffffc0204972:	6402                	ld	s0,0(sp)
ffffffffc0204974:	0141                	addi	sp,sp,16
ffffffffc0204976:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204978:	4198                	lw	a4,0(a1)
ffffffffc020497a:	4789                	li	a5,2
ffffffffc020497c:	fef712e3          	bne	a4,a5,ffffffffc0204960 <schedule+0x52>
ffffffffc0204980:	852e                	mv	a0,a1
ffffffffc0204982:	bff9                	j	ffffffffc0204960 <schedule+0x52>
}
ffffffffc0204984:	6402                	ld	s0,0(sp)
ffffffffc0204986:	60a2                	ld	ra,8(sp)
ffffffffc0204988:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020498a:	c41fb06f          	j	ffffffffc02005ca <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020498e:	00011617          	auipc	a2,0x11
ffffffffc0204992:	b9a60613          	addi	a2,a2,-1126 # ffffffffc0215528 <proc_list>
ffffffffc0204996:	86b2                	mv	a3,a2
ffffffffc0204998:	b76d                	j	ffffffffc0204942 <schedule+0x34>
        intr_disable();
ffffffffc020499a:	c37fb0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        return 1;
ffffffffc020499e:	4405                	li	s0,1
ffffffffc02049a0:	bfbd                	j	ffffffffc020491e <schedule+0x10>

ffffffffc02049a2 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02049a2:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02049a6:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02049a8:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02049aa:	cb81                	beqz	a5,ffffffffc02049ba <strlen+0x18>
        cnt ++;
ffffffffc02049ac:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02049ae:	00a707b3          	add	a5,a4,a0
ffffffffc02049b2:	0007c783          	lbu	a5,0(a5)
ffffffffc02049b6:	fbfd                	bnez	a5,ffffffffc02049ac <strlen+0xa>
ffffffffc02049b8:	8082                	ret
    }
    return cnt;
}
ffffffffc02049ba:	8082                	ret

ffffffffc02049bc <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02049bc:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02049be:	e589                	bnez	a1,ffffffffc02049c8 <strnlen+0xc>
ffffffffc02049c0:	a811                	j	ffffffffc02049d4 <strnlen+0x18>
        cnt ++;
ffffffffc02049c2:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02049c4:	00f58863          	beq	a1,a5,ffffffffc02049d4 <strnlen+0x18>
ffffffffc02049c8:	00f50733          	add	a4,a0,a5
ffffffffc02049cc:	00074703          	lbu	a4,0(a4)
ffffffffc02049d0:	fb6d                	bnez	a4,ffffffffc02049c2 <strnlen+0x6>
ffffffffc02049d2:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02049d4:	852e                	mv	a0,a1
ffffffffc02049d6:	8082                	ret

ffffffffc02049d8 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02049d8:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02049da:	0005c703          	lbu	a4,0(a1)
ffffffffc02049de:	0785                	addi	a5,a5,1
ffffffffc02049e0:	0585                	addi	a1,a1,1
ffffffffc02049e2:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02049e6:	fb75                	bnez	a4,ffffffffc02049da <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02049e8:	8082                	ret

ffffffffc02049ea <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02049ea:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02049ee:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02049f2:	cb89                	beqz	a5,ffffffffc0204a04 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02049f4:	0505                	addi	a0,a0,1
ffffffffc02049f6:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02049f8:	fee789e3          	beq	a5,a4,ffffffffc02049ea <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02049fc:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204a00:	9d19                	subw	a0,a0,a4
ffffffffc0204a02:	8082                	ret
ffffffffc0204a04:	4501                	li	a0,0
ffffffffc0204a06:	bfed                	j	ffffffffc0204a00 <strcmp+0x16>

ffffffffc0204a08 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204a08:	00054783          	lbu	a5,0(a0)
ffffffffc0204a0c:	c799                	beqz	a5,ffffffffc0204a1a <strchr+0x12>
        if (*s == c) {
ffffffffc0204a0e:	00f58763          	beq	a1,a5,ffffffffc0204a1c <strchr+0x14>
    while (*s != '\0') {
ffffffffc0204a12:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0204a16:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204a18:	fbfd                	bnez	a5,ffffffffc0204a0e <strchr+0x6>
    }
    return NULL;
ffffffffc0204a1a:	4501                	li	a0,0
}
ffffffffc0204a1c:	8082                	ret

ffffffffc0204a1e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204a1e:	ca01                	beqz	a2,ffffffffc0204a2e <memset+0x10>
ffffffffc0204a20:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204a22:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204a24:	0785                	addi	a5,a5,1
ffffffffc0204a26:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204a2a:	fec79de3          	bne	a5,a2,ffffffffc0204a24 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204a2e:	8082                	ret

ffffffffc0204a30 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204a30:	ca19                	beqz	a2,ffffffffc0204a46 <memcpy+0x16>
ffffffffc0204a32:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204a34:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204a36:	0005c703          	lbu	a4,0(a1)
ffffffffc0204a3a:	0585                	addi	a1,a1,1
ffffffffc0204a3c:	0785                	addi	a5,a5,1
ffffffffc0204a3e:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204a42:	fec59ae3          	bne	a1,a2,ffffffffc0204a36 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204a46:	8082                	ret

ffffffffc0204a48 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204a48:	c205                	beqz	a2,ffffffffc0204a68 <memcmp+0x20>
ffffffffc0204a4a:	962e                	add	a2,a2,a1
ffffffffc0204a4c:	a019                	j	ffffffffc0204a52 <memcmp+0xa>
ffffffffc0204a4e:	00c58d63          	beq	a1,a2,ffffffffc0204a68 <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc0204a52:	00054783          	lbu	a5,0(a0)
ffffffffc0204a56:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204a5a:	0505                	addi	a0,a0,1
ffffffffc0204a5c:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc0204a5e:	fee788e3          	beq	a5,a4,ffffffffc0204a4e <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204a62:	40e7853b          	subw	a0,a5,a4
ffffffffc0204a66:	8082                	ret
    }
    return 0;
ffffffffc0204a68:	4501                	li	a0,0
}
ffffffffc0204a6a:	8082                	ret

ffffffffc0204a6c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204a6c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204a70:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204a72:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204a76:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204a78:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204a7c:	f022                	sd	s0,32(sp)
ffffffffc0204a7e:	ec26                	sd	s1,24(sp)
ffffffffc0204a80:	e84a                	sd	s2,16(sp)
ffffffffc0204a82:	f406                	sd	ra,40(sp)
ffffffffc0204a84:	e44e                	sd	s3,8(sp)
ffffffffc0204a86:	84aa                	mv	s1,a0
ffffffffc0204a88:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204a8a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204a8e:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0204a90:	03067e63          	bgeu	a2,a6,ffffffffc0204acc <printnum+0x60>
ffffffffc0204a94:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0204a96:	00805763          	blez	s0,ffffffffc0204aa4 <printnum+0x38>
ffffffffc0204a9a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204a9c:	85ca                	mv	a1,s2
ffffffffc0204a9e:	854e                	mv	a0,s3
ffffffffc0204aa0:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204aa2:	fc65                	bnez	s0,ffffffffc0204a9a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204aa4:	1a02                	slli	s4,s4,0x20
ffffffffc0204aa6:	00002797          	auipc	a5,0x2
ffffffffc0204aaa:	2a278793          	addi	a5,a5,674 # ffffffffc0206d48 <default_pmm_manager+0x798>
ffffffffc0204aae:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204ab2:	9a3e                	add	s4,s4,a5
}
ffffffffc0204ab4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204ab6:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204aba:	70a2                	ld	ra,40(sp)
ffffffffc0204abc:	69a2                	ld	s3,8(sp)
ffffffffc0204abe:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204ac0:	85ca                	mv	a1,s2
ffffffffc0204ac2:	87a6                	mv	a5,s1
}
ffffffffc0204ac4:	6942                	ld	s2,16(sp)
ffffffffc0204ac6:	64e2                	ld	s1,24(sp)
ffffffffc0204ac8:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204aca:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204acc:	03065633          	divu	a2,a2,a6
ffffffffc0204ad0:	8722                	mv	a4,s0
ffffffffc0204ad2:	f9bff0ef          	jal	ra,ffffffffc0204a6c <printnum>
ffffffffc0204ad6:	b7f9                	j	ffffffffc0204aa4 <printnum+0x38>

ffffffffc0204ad8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204ad8:	7119                	addi	sp,sp,-128
ffffffffc0204ada:	f4a6                	sd	s1,104(sp)
ffffffffc0204adc:	f0ca                	sd	s2,96(sp)
ffffffffc0204ade:	ecce                	sd	s3,88(sp)
ffffffffc0204ae0:	e8d2                	sd	s4,80(sp)
ffffffffc0204ae2:	e4d6                	sd	s5,72(sp)
ffffffffc0204ae4:	e0da                	sd	s6,64(sp)
ffffffffc0204ae6:	fc5e                	sd	s7,56(sp)
ffffffffc0204ae8:	f06a                	sd	s10,32(sp)
ffffffffc0204aea:	fc86                	sd	ra,120(sp)
ffffffffc0204aec:	f8a2                	sd	s0,112(sp)
ffffffffc0204aee:	f862                	sd	s8,48(sp)
ffffffffc0204af0:	f466                	sd	s9,40(sp)
ffffffffc0204af2:	ec6e                	sd	s11,24(sp)
ffffffffc0204af4:	892a                	mv	s2,a0
ffffffffc0204af6:	84ae                	mv	s1,a1
ffffffffc0204af8:	8d32                	mv	s10,a2
ffffffffc0204afa:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204afc:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204b00:	5b7d                	li	s6,-1
ffffffffc0204b02:	00002a97          	auipc	s5,0x2
ffffffffc0204b06:	272a8a93          	addi	s5,s5,626 # ffffffffc0206d74 <default_pmm_manager+0x7c4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204b0a:	00002b97          	auipc	s7,0x2
ffffffffc0204b0e:	446b8b93          	addi	s7,s7,1094 # ffffffffc0206f50 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b12:	000d4503          	lbu	a0,0(s10)
ffffffffc0204b16:	001d0413          	addi	s0,s10,1
ffffffffc0204b1a:	01350a63          	beq	a0,s3,ffffffffc0204b2e <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204b1e:	c121                	beqz	a0,ffffffffc0204b5e <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204b20:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b22:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204b24:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b26:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204b2a:	ff351ae3          	bne	a0,s3,ffffffffc0204b1e <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b2e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204b32:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204b36:	4c81                	li	s9,0
ffffffffc0204b38:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0204b3a:	5c7d                	li	s8,-1
ffffffffc0204b3c:	5dfd                	li	s11,-1
ffffffffc0204b3e:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0204b42:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b44:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204b48:	0ff5f593          	zext.b	a1,a1
ffffffffc0204b4c:	00140d13          	addi	s10,s0,1
ffffffffc0204b50:	04b56263          	bltu	a0,a1,ffffffffc0204b94 <vprintfmt+0xbc>
ffffffffc0204b54:	058a                	slli	a1,a1,0x2
ffffffffc0204b56:	95d6                	add	a1,a1,s5
ffffffffc0204b58:	4194                	lw	a3,0(a1)
ffffffffc0204b5a:	96d6                	add	a3,a3,s5
ffffffffc0204b5c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204b5e:	70e6                	ld	ra,120(sp)
ffffffffc0204b60:	7446                	ld	s0,112(sp)
ffffffffc0204b62:	74a6                	ld	s1,104(sp)
ffffffffc0204b64:	7906                	ld	s2,96(sp)
ffffffffc0204b66:	69e6                	ld	s3,88(sp)
ffffffffc0204b68:	6a46                	ld	s4,80(sp)
ffffffffc0204b6a:	6aa6                	ld	s5,72(sp)
ffffffffc0204b6c:	6b06                	ld	s6,64(sp)
ffffffffc0204b6e:	7be2                	ld	s7,56(sp)
ffffffffc0204b70:	7c42                	ld	s8,48(sp)
ffffffffc0204b72:	7ca2                	ld	s9,40(sp)
ffffffffc0204b74:	7d02                	ld	s10,32(sp)
ffffffffc0204b76:	6de2                	ld	s11,24(sp)
ffffffffc0204b78:	6109                	addi	sp,sp,128
ffffffffc0204b7a:	8082                	ret
            padc = '0';
ffffffffc0204b7c:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0204b7e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b82:	846a                	mv	s0,s10
ffffffffc0204b84:	00140d13          	addi	s10,s0,1
ffffffffc0204b88:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204b8c:	0ff5f593          	zext.b	a1,a1
ffffffffc0204b90:	fcb572e3          	bgeu	a0,a1,ffffffffc0204b54 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0204b94:	85a6                	mv	a1,s1
ffffffffc0204b96:	02500513          	li	a0,37
ffffffffc0204b9a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204b9c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204ba0:	8d22                	mv	s10,s0
ffffffffc0204ba2:	f73788e3          	beq	a5,s3,ffffffffc0204b12 <vprintfmt+0x3a>
ffffffffc0204ba6:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0204baa:	1d7d                	addi	s10,s10,-1
ffffffffc0204bac:	ff379de3          	bne	a5,s3,ffffffffc0204ba6 <vprintfmt+0xce>
ffffffffc0204bb0:	b78d                	j	ffffffffc0204b12 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204bb2:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0204bb6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bba:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204bbc:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204bc0:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204bc4:	02d86463          	bltu	a6,a3,ffffffffc0204bec <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0204bc8:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204bcc:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204bd0:	0186873b          	addw	a4,a3,s8
ffffffffc0204bd4:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204bd8:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0204bda:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204bde:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204be0:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204be4:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204be8:	fed870e3          	bgeu	a6,a3,ffffffffc0204bc8 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204bec:	f40ddce3          	bgez	s11,ffffffffc0204b44 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204bf0:	8de2                	mv	s11,s8
ffffffffc0204bf2:	5c7d                	li	s8,-1
ffffffffc0204bf4:	bf81                	j	ffffffffc0204b44 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0204bf6:	fffdc693          	not	a3,s11
ffffffffc0204bfa:	96fd                	srai	a3,a3,0x3f
ffffffffc0204bfc:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c00:	00144603          	lbu	a2,1(s0)
ffffffffc0204c04:	2d81                	sext.w	s11,s11
ffffffffc0204c06:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204c08:	bf35                	j	ffffffffc0204b44 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0204c0a:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c0e:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204c12:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c14:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204c16:	bfd9                	j	ffffffffc0204bec <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0204c18:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204c1a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204c1e:	01174463          	blt	a4,a7,ffffffffc0204c26 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204c22:	1a088e63          	beqz	a7,ffffffffc0204dde <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204c26:	000a3603          	ld	a2,0(s4)
ffffffffc0204c2a:	46c1                	li	a3,16
ffffffffc0204c2c:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204c2e:	2781                	sext.w	a5,a5
ffffffffc0204c30:	876e                	mv	a4,s11
ffffffffc0204c32:	85a6                	mv	a1,s1
ffffffffc0204c34:	854a                	mv	a0,s2
ffffffffc0204c36:	e37ff0ef          	jal	ra,ffffffffc0204a6c <printnum>
            break;
ffffffffc0204c3a:	bde1                	j	ffffffffc0204b12 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204c3c:	000a2503          	lw	a0,0(s4)
ffffffffc0204c40:	85a6                	mv	a1,s1
ffffffffc0204c42:	0a21                	addi	s4,s4,8
ffffffffc0204c44:	9902                	jalr	s2
            break;
ffffffffc0204c46:	b5f1                	j	ffffffffc0204b12 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204c48:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204c4a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204c4e:	01174463          	blt	a4,a7,ffffffffc0204c56 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0204c52:	18088163          	beqz	a7,ffffffffc0204dd4 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0204c56:	000a3603          	ld	a2,0(s4)
ffffffffc0204c5a:	46a9                	li	a3,10
ffffffffc0204c5c:	8a2e                	mv	s4,a1
ffffffffc0204c5e:	bfc1                	j	ffffffffc0204c2e <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c60:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204c64:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c66:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204c68:	bdf1                	j	ffffffffc0204b44 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0204c6a:	85a6                	mv	a1,s1
ffffffffc0204c6c:	02500513          	li	a0,37
ffffffffc0204c70:	9902                	jalr	s2
            break;
ffffffffc0204c72:	b545                	j	ffffffffc0204b12 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c74:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0204c78:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c7a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204c7c:	b5e1                	j	ffffffffc0204b44 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204c7e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204c80:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204c84:	01174463          	blt	a4,a7,ffffffffc0204c8c <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0204c88:	14088163          	beqz	a7,ffffffffc0204dca <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0204c8c:	000a3603          	ld	a2,0(s4)
ffffffffc0204c90:	46a1                	li	a3,8
ffffffffc0204c92:	8a2e                	mv	s4,a1
ffffffffc0204c94:	bf69                	j	ffffffffc0204c2e <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0204c96:	03000513          	li	a0,48
ffffffffc0204c9a:	85a6                	mv	a1,s1
ffffffffc0204c9c:	e03e                	sd	a5,0(sp)
ffffffffc0204c9e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204ca0:	85a6                	mv	a1,s1
ffffffffc0204ca2:	07800513          	li	a0,120
ffffffffc0204ca6:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204ca8:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0204caa:	6782                	ld	a5,0(sp)
ffffffffc0204cac:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204cae:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204cb2:	bfb5                	j	ffffffffc0204c2e <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204cb4:	000a3403          	ld	s0,0(s4)
ffffffffc0204cb8:	008a0713          	addi	a4,s4,8
ffffffffc0204cbc:	e03a                	sd	a4,0(sp)
ffffffffc0204cbe:	14040263          	beqz	s0,ffffffffc0204e02 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204cc2:	0fb05763          	blez	s11,ffffffffc0204db0 <vprintfmt+0x2d8>
ffffffffc0204cc6:	02d00693          	li	a3,45
ffffffffc0204cca:	0cd79163          	bne	a5,a3,ffffffffc0204d8c <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204cce:	00044783          	lbu	a5,0(s0)
ffffffffc0204cd2:	0007851b          	sext.w	a0,a5
ffffffffc0204cd6:	cf85                	beqz	a5,ffffffffc0204d0e <vprintfmt+0x236>
ffffffffc0204cd8:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204cdc:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204ce0:	000c4563          	bltz	s8,ffffffffc0204cea <vprintfmt+0x212>
ffffffffc0204ce4:	3c7d                	addiw	s8,s8,-1
ffffffffc0204ce6:	036c0263          	beq	s8,s6,ffffffffc0204d0a <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204cea:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204cec:	0e0c8e63          	beqz	s9,ffffffffc0204de8 <vprintfmt+0x310>
ffffffffc0204cf0:	3781                	addiw	a5,a5,-32
ffffffffc0204cf2:	0ef47b63          	bgeu	s0,a5,ffffffffc0204de8 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0204cf6:	03f00513          	li	a0,63
ffffffffc0204cfa:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204cfc:	000a4783          	lbu	a5,0(s4)
ffffffffc0204d00:	3dfd                	addiw	s11,s11,-1
ffffffffc0204d02:	0a05                	addi	s4,s4,1
ffffffffc0204d04:	0007851b          	sext.w	a0,a5
ffffffffc0204d08:	ffe1                	bnez	a5,ffffffffc0204ce0 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204d0a:	01b05963          	blez	s11,ffffffffc0204d1c <vprintfmt+0x244>
ffffffffc0204d0e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204d10:	85a6                	mv	a1,s1
ffffffffc0204d12:	02000513          	li	a0,32
ffffffffc0204d16:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204d18:	fe0d9be3          	bnez	s11,ffffffffc0204d0e <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204d1c:	6a02                	ld	s4,0(sp)
ffffffffc0204d1e:	bbd5                	j	ffffffffc0204b12 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204d20:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204d22:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0204d26:	01174463          	blt	a4,a7,ffffffffc0204d2e <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204d2a:	08088d63          	beqz	a7,ffffffffc0204dc4 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204d2e:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204d32:	0a044d63          	bltz	s0,ffffffffc0204dec <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0204d36:	8622                	mv	a2,s0
ffffffffc0204d38:	8a66                	mv	s4,s9
ffffffffc0204d3a:	46a9                	li	a3,10
ffffffffc0204d3c:	bdcd                	j	ffffffffc0204c2e <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204d3e:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204d42:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204d44:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0204d46:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204d4a:	8fb5                	xor	a5,a5,a3
ffffffffc0204d4c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204d50:	02d74163          	blt	a4,a3,ffffffffc0204d72 <vprintfmt+0x29a>
ffffffffc0204d54:	00369793          	slli	a5,a3,0x3
ffffffffc0204d58:	97de                	add	a5,a5,s7
ffffffffc0204d5a:	639c                	ld	a5,0(a5)
ffffffffc0204d5c:	cb99                	beqz	a5,ffffffffc0204d72 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204d5e:	86be                	mv	a3,a5
ffffffffc0204d60:	00000617          	auipc	a2,0x0
ffffffffc0204d64:	17060613          	addi	a2,a2,368 # ffffffffc0204ed0 <etext+0x60>
ffffffffc0204d68:	85a6                	mv	a1,s1
ffffffffc0204d6a:	854a                	mv	a0,s2
ffffffffc0204d6c:	0ce000ef          	jal	ra,ffffffffc0204e3a <printfmt>
ffffffffc0204d70:	b34d                	j	ffffffffc0204b12 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204d72:	00002617          	auipc	a2,0x2
ffffffffc0204d76:	ff660613          	addi	a2,a2,-10 # ffffffffc0206d68 <default_pmm_manager+0x7b8>
ffffffffc0204d7a:	85a6                	mv	a1,s1
ffffffffc0204d7c:	854a                	mv	a0,s2
ffffffffc0204d7e:	0bc000ef          	jal	ra,ffffffffc0204e3a <printfmt>
ffffffffc0204d82:	bb41                	j	ffffffffc0204b12 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204d84:	00002417          	auipc	s0,0x2
ffffffffc0204d88:	fdc40413          	addi	s0,s0,-36 # ffffffffc0206d60 <default_pmm_manager+0x7b0>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204d8c:	85e2                	mv	a1,s8
ffffffffc0204d8e:	8522                	mv	a0,s0
ffffffffc0204d90:	e43e                	sd	a5,8(sp)
ffffffffc0204d92:	c2bff0ef          	jal	ra,ffffffffc02049bc <strnlen>
ffffffffc0204d96:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204d9a:	01b05b63          	blez	s11,ffffffffc0204db0 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204d9e:	67a2                	ld	a5,8(sp)
ffffffffc0204da0:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204da4:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204da6:	85a6                	mv	a1,s1
ffffffffc0204da8:	8552                	mv	a0,s4
ffffffffc0204daa:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204dac:	fe0d9ce3          	bnez	s11,ffffffffc0204da4 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204db0:	00044783          	lbu	a5,0(s0)
ffffffffc0204db4:	00140a13          	addi	s4,s0,1
ffffffffc0204db8:	0007851b          	sext.w	a0,a5
ffffffffc0204dbc:	d3a5                	beqz	a5,ffffffffc0204d1c <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204dbe:	05e00413          	li	s0,94
ffffffffc0204dc2:	bf39                	j	ffffffffc0204ce0 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204dc4:	000a2403          	lw	s0,0(s4)
ffffffffc0204dc8:	b7ad                	j	ffffffffc0204d32 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0204dca:	000a6603          	lwu	a2,0(s4)
ffffffffc0204dce:	46a1                	li	a3,8
ffffffffc0204dd0:	8a2e                	mv	s4,a1
ffffffffc0204dd2:	bdb1                	j	ffffffffc0204c2e <vprintfmt+0x156>
ffffffffc0204dd4:	000a6603          	lwu	a2,0(s4)
ffffffffc0204dd8:	46a9                	li	a3,10
ffffffffc0204dda:	8a2e                	mv	s4,a1
ffffffffc0204ddc:	bd89                	j	ffffffffc0204c2e <vprintfmt+0x156>
ffffffffc0204dde:	000a6603          	lwu	a2,0(s4)
ffffffffc0204de2:	46c1                	li	a3,16
ffffffffc0204de4:	8a2e                	mv	s4,a1
ffffffffc0204de6:	b5a1                	j	ffffffffc0204c2e <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204de8:	9902                	jalr	s2
ffffffffc0204dea:	bf09                	j	ffffffffc0204cfc <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204dec:	85a6                	mv	a1,s1
ffffffffc0204dee:	02d00513          	li	a0,45
ffffffffc0204df2:	e03e                	sd	a5,0(sp)
ffffffffc0204df4:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204df6:	6782                	ld	a5,0(sp)
ffffffffc0204df8:	8a66                	mv	s4,s9
ffffffffc0204dfa:	40800633          	neg	a2,s0
ffffffffc0204dfe:	46a9                	li	a3,10
ffffffffc0204e00:	b53d                	j	ffffffffc0204c2e <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204e02:	03b05163          	blez	s11,ffffffffc0204e24 <vprintfmt+0x34c>
ffffffffc0204e06:	02d00693          	li	a3,45
ffffffffc0204e0a:	f6d79de3          	bne	a5,a3,ffffffffc0204d84 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204e0e:	00002417          	auipc	s0,0x2
ffffffffc0204e12:	f5240413          	addi	s0,s0,-174 # ffffffffc0206d60 <default_pmm_manager+0x7b0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204e16:	02800793          	li	a5,40
ffffffffc0204e1a:	02800513          	li	a0,40
ffffffffc0204e1e:	00140a13          	addi	s4,s0,1
ffffffffc0204e22:	bd6d                	j	ffffffffc0204cdc <vprintfmt+0x204>
ffffffffc0204e24:	00002a17          	auipc	s4,0x2
ffffffffc0204e28:	f3da0a13          	addi	s4,s4,-195 # ffffffffc0206d61 <default_pmm_manager+0x7b1>
ffffffffc0204e2c:	02800513          	li	a0,40
ffffffffc0204e30:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204e34:	05e00413          	li	s0,94
ffffffffc0204e38:	b565                	j	ffffffffc0204ce0 <vprintfmt+0x208>

ffffffffc0204e3a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e3a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204e3c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e40:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204e42:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e44:	ec06                	sd	ra,24(sp)
ffffffffc0204e46:	f83a                	sd	a4,48(sp)
ffffffffc0204e48:	fc3e                	sd	a5,56(sp)
ffffffffc0204e4a:	e0c2                	sd	a6,64(sp)
ffffffffc0204e4c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204e4e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204e50:	c89ff0ef          	jal	ra,ffffffffc0204ad8 <vprintfmt>
}
ffffffffc0204e54:	60e2                	ld	ra,24(sp)
ffffffffc0204e56:	6161                	addi	sp,sp,80
ffffffffc0204e58:	8082                	ret

ffffffffc0204e5a <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204e5a:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204e5e:	2785                	addiw	a5,a5,1
ffffffffc0204e60:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0204e64:	02000793          	li	a5,32
ffffffffc0204e68:	9f8d                	subw	a5,a5,a1
}
ffffffffc0204e6a:	00f5553b          	srlw	a0,a0,a5
ffffffffc0204e6e:	8082                	ret
