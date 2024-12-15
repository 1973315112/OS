
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
ffffffffc0200036:	2ce50513          	addi	a0,a0,718 # ffffffffc02a7300 <buf>
ffffffffc020003a:	000b3617          	auipc	a2,0xb3
ffffffffc020003e:	82260613          	addi	a2,a2,-2014 # ffffffffc02b285c <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	024060ef          	jal	ra,ffffffffc020606e <memset>
    cons_init();                // init the console
ffffffffc020004e:	55c000ef          	jal	ra,ffffffffc02005aa <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	44e58593          	addi	a1,a1,1102 # ffffffffc02064a0 <etext+0x4>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	46650513          	addi	a0,a0,1126 # ffffffffc02064c0 <etext+0x24>
ffffffffc0200062:	06a000ef          	jal	ra,ffffffffc02000cc <cprintf>

    print_kerninfo();
ffffffffc0200066:	24e000ef          	jal	ra,ffffffffc02002b4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	60b030ef          	jal	ra,ffffffffc0203e74 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5ae000ef          	jal	ra,ffffffffc020061c <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5b8000ef          	jal	ra,ffffffffc020062a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	452010ef          	jal	ra,ffffffffc02014c8 <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	3db050ef          	jal	ra,ffffffffc0205c54 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	4a8000ef          	jal	ra,ffffffffc0200526 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	1fe020ef          	jal	ra,ffffffffc0202280 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	4d2000ef          	jal	ra,ffffffffc0200558 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	594000ef          	jal	ra,ffffffffc020061e <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	55f050ef          	jal	ra,ffffffffc0205dec <cpu_idle>

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
ffffffffc020009a:	512000ef          	jal	ra,ffffffffc02005ac <cons_putc>
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
ffffffffc02000c0:	044060ef          	jal	ra,ffffffffc0206104 <vprintfmt>
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
ffffffffc02000ce:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
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
ffffffffc02000f6:	00e060ef          	jal	ra,ffffffffc0206104 <vprintfmt>
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
ffffffffc0200102:	a16d                	j	ffffffffc02005ac <cons_putc>

ffffffffc0200104 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200104:	1101                	addi	sp,sp,-32
ffffffffc0200106:	e822                	sd	s0,16(sp)
ffffffffc0200108:	ec06                	sd	ra,24(sp)
ffffffffc020010a:	e426                	sd	s1,8(sp)
ffffffffc020010c:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc020010e:	00054503          	lbu	a0,0(a0)
ffffffffc0200112:	c51d                	beqz	a0,ffffffffc0200140 <cputs+0x3c>
ffffffffc0200114:	0405                	addi	s0,s0,1
ffffffffc0200116:	4485                	li	s1,1
ffffffffc0200118:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020011a:	492000ef          	jal	ra,ffffffffc02005ac <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020011e:	00044503          	lbu	a0,0(s0)
ffffffffc0200122:	008487bb          	addw	a5,s1,s0
ffffffffc0200126:	0405                	addi	s0,s0,1
ffffffffc0200128:	f96d                	bnez	a0,ffffffffc020011a <cputs+0x16>
    (*cnt) ++;
ffffffffc020012a:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc020012e:	4529                	li	a0,10
ffffffffc0200130:	47c000ef          	jal	ra,ffffffffc02005ac <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200134:	60e2                	ld	ra,24(sp)
ffffffffc0200136:	8522                	mv	a0,s0
ffffffffc0200138:	6442                	ld	s0,16(sp)
ffffffffc020013a:	64a2                	ld	s1,8(sp)
ffffffffc020013c:	6105                	addi	sp,sp,32
ffffffffc020013e:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200140:	4405                	li	s0,1
ffffffffc0200142:	b7f5                	j	ffffffffc020012e <cputs+0x2a>

ffffffffc0200144 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200144:	1141                	addi	sp,sp,-16
ffffffffc0200146:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200148:	498000ef          	jal	ra,ffffffffc02005e0 <cons_getc>
ffffffffc020014c:	dd75                	beqz	a0,ffffffffc0200148 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020014e:	60a2                	ld	ra,8(sp)
ffffffffc0200150:	0141                	addi	sp,sp,16
ffffffffc0200152:	8082                	ret

ffffffffc0200154 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200154:	715d                	addi	sp,sp,-80
ffffffffc0200156:	e486                	sd	ra,72(sp)
ffffffffc0200158:	e0a6                	sd	s1,64(sp)
ffffffffc020015a:	fc4a                	sd	s2,56(sp)
ffffffffc020015c:	f84e                	sd	s3,48(sp)
ffffffffc020015e:	f452                	sd	s4,40(sp)
ffffffffc0200160:	f056                	sd	s5,32(sp)
ffffffffc0200162:	ec5a                	sd	s6,24(sp)
ffffffffc0200164:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0200166:	c901                	beqz	a0,ffffffffc0200176 <readline+0x22>
ffffffffc0200168:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020016a:	00006517          	auipc	a0,0x6
ffffffffc020016e:	35e50513          	addi	a0,a0,862 # ffffffffc02064c8 <etext+0x2c>
ffffffffc0200172:	f5bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
readline(const char *prompt) {
ffffffffc0200176:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200178:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020017a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020017c:	4aa9                	li	s5,10
ffffffffc020017e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200180:	000a7b97          	auipc	s7,0xa7
ffffffffc0200184:	180b8b93          	addi	s7,s7,384 # ffffffffc02a7300 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200188:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020018c:	fb9ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc0200190:	00054a63          	bltz	a0,ffffffffc02001a4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200194:	00a95a63          	bge	s2,a0,ffffffffc02001a8 <readline+0x54>
ffffffffc0200198:	029a5263          	bge	s4,s1,ffffffffc02001bc <readline+0x68>
        c = getchar();
ffffffffc020019c:	fa9ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc02001a0:	fe055ae3          	bgez	a0,ffffffffc0200194 <readline+0x40>
            return NULL;
ffffffffc02001a4:	4501                	li	a0,0
ffffffffc02001a6:	a091                	j	ffffffffc02001ea <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02001a8:	03351463          	bne	a0,s3,ffffffffc02001d0 <readline+0x7c>
ffffffffc02001ac:	e8a9                	bnez	s1,ffffffffc02001fe <readline+0xaa>
        c = getchar();
ffffffffc02001ae:	f97ff0ef          	jal	ra,ffffffffc0200144 <getchar>
        if (c < 0) {
ffffffffc02001b2:	fe0549e3          	bltz	a0,ffffffffc02001a4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001b6:	fea959e3          	bge	s2,a0,ffffffffc02001a8 <readline+0x54>
ffffffffc02001ba:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001bc:	e42a                	sd	a0,8(sp)
ffffffffc02001be:	f45ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i ++] = c;
ffffffffc02001c2:	6522                	ld	a0,8(sp)
ffffffffc02001c4:	009b87b3          	add	a5,s7,s1
ffffffffc02001c8:	2485                	addiw	s1,s1,1
ffffffffc02001ca:	00a78023          	sb	a0,0(a5)
ffffffffc02001ce:	bf7d                	j	ffffffffc020018c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02001d0:	01550463          	beq	a0,s5,ffffffffc02001d8 <readline+0x84>
ffffffffc02001d4:	fb651ce3          	bne	a0,s6,ffffffffc020018c <readline+0x38>
            cputchar(c);
ffffffffc02001d8:	f2bff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i] = '\0';
ffffffffc02001dc:	000a7517          	auipc	a0,0xa7
ffffffffc02001e0:	12450513          	addi	a0,a0,292 # ffffffffc02a7300 <buf>
ffffffffc02001e4:	94aa                	add	s1,s1,a0
ffffffffc02001e6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001ea:	60a6                	ld	ra,72(sp)
ffffffffc02001ec:	6486                	ld	s1,64(sp)
ffffffffc02001ee:	7962                	ld	s2,56(sp)
ffffffffc02001f0:	79c2                	ld	s3,48(sp)
ffffffffc02001f2:	7a22                	ld	s4,40(sp)
ffffffffc02001f4:	7a82                	ld	s5,32(sp)
ffffffffc02001f6:	6b62                	ld	s6,24(sp)
ffffffffc02001f8:	6bc2                	ld	s7,16(sp)
ffffffffc02001fa:	6161                	addi	sp,sp,80
ffffffffc02001fc:	8082                	ret
            cputchar(c);
ffffffffc02001fe:	4521                	li	a0,8
ffffffffc0200200:	f03ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            i --;
ffffffffc0200204:	34fd                	addiw	s1,s1,-1
ffffffffc0200206:	b759                	j	ffffffffc020018c <readline+0x38>

ffffffffc0200208 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200208:	000b2317          	auipc	t1,0xb2
ffffffffc020020c:	5c030313          	addi	t1,t1,1472 # ffffffffc02b27c8 <is_panic>
ffffffffc0200210:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200214:	715d                	addi	sp,sp,-80
ffffffffc0200216:	ec06                	sd	ra,24(sp)
ffffffffc0200218:	e822                	sd	s0,16(sp)
ffffffffc020021a:	f436                	sd	a3,40(sp)
ffffffffc020021c:	f83a                	sd	a4,48(sp)
ffffffffc020021e:	fc3e                	sd	a5,56(sp)
ffffffffc0200220:	e0c2                	sd	a6,64(sp)
ffffffffc0200222:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200224:	020e1a63          	bnez	t3,ffffffffc0200258 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200228:	4785                	li	a5,1
ffffffffc020022a:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020022e:	8432                	mv	s0,a2
ffffffffc0200230:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200232:	862e                	mv	a2,a1
ffffffffc0200234:	85aa                	mv	a1,a0
ffffffffc0200236:	00006517          	auipc	a0,0x6
ffffffffc020023a:	29a50513          	addi	a0,a0,666 # ffffffffc02064d0 <etext+0x34>
    va_start(ap, fmt);
ffffffffc020023e:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200240:	e8dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200244:	65a2                	ld	a1,8(sp)
ffffffffc0200246:	8522                	mv	a0,s0
ffffffffc0200248:	e65ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc020024c:	00008517          	auipc	a0,0x8
ffffffffc0200250:	d0450513          	addi	a0,a0,-764 # ffffffffc0207f50 <default_pmm_manager+0x3b8>
ffffffffc0200254:	e79ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200258:	4501                	li	a0,0
ffffffffc020025a:	4581                	li	a1,0
ffffffffc020025c:	4601                	li	a2,0
ffffffffc020025e:	48a1                	li	a7,8
ffffffffc0200260:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc0200264:	3c0000ef          	jal	ra,ffffffffc0200624 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200268:	4501                	li	a0,0
ffffffffc020026a:	174000ef          	jal	ra,ffffffffc02003de <kmonitor>
    while (1) {
ffffffffc020026e:	bfed                	j	ffffffffc0200268 <__panic+0x60>

ffffffffc0200270 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200270:	715d                	addi	sp,sp,-80
ffffffffc0200272:	832e                	mv	t1,a1
ffffffffc0200274:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200276:	85aa                	mv	a1,a0
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200278:	8432                	mv	s0,a2
ffffffffc020027a:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020027c:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc020027e:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200280:	00006517          	auipc	a0,0x6
ffffffffc0200284:	27050513          	addi	a0,a0,624 # ffffffffc02064f0 <etext+0x54>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200288:	ec06                	sd	ra,24(sp)
ffffffffc020028a:	f436                	sd	a3,40(sp)
ffffffffc020028c:	f83a                	sd	a4,48(sp)
ffffffffc020028e:	e0c2                	sd	a6,64(sp)
ffffffffc0200290:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200292:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200294:	e39ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200298:	65a2                	ld	a1,8(sp)
ffffffffc020029a:	8522                	mv	a0,s0
ffffffffc020029c:	e11ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc02002a0:	00008517          	auipc	a0,0x8
ffffffffc02002a4:	cb050513          	addi	a0,a0,-848 # ffffffffc0207f50 <default_pmm_manager+0x3b8>
ffffffffc02002a8:	e25ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    va_end(ap);
}
ffffffffc02002ac:	60e2                	ld	ra,24(sp)
ffffffffc02002ae:	6442                	ld	s0,16(sp)
ffffffffc02002b0:	6161                	addi	sp,sp,80
ffffffffc02002b2:	8082                	ret

ffffffffc02002b4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02002b4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002b6:	00006517          	auipc	a0,0x6
ffffffffc02002ba:	25a50513          	addi	a0,a0,602 # ffffffffc0206510 <etext+0x74>
void print_kerninfo(void) {
ffffffffc02002be:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002c0:	e0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002c4:	00000597          	auipc	a1,0x0
ffffffffc02002c8:	d6e58593          	addi	a1,a1,-658 # ffffffffc0200032 <kern_init>
ffffffffc02002cc:	00006517          	auipc	a0,0x6
ffffffffc02002d0:	26450513          	addi	a0,a0,612 # ffffffffc0206530 <etext+0x94>
ffffffffc02002d4:	df9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002d8:	00006597          	auipc	a1,0x6
ffffffffc02002dc:	1c458593          	addi	a1,a1,452 # ffffffffc020649c <etext>
ffffffffc02002e0:	00006517          	auipc	a0,0x6
ffffffffc02002e4:	27050513          	addi	a0,a0,624 # ffffffffc0206550 <etext+0xb4>
ffffffffc02002e8:	de5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002ec:	000a7597          	auipc	a1,0xa7
ffffffffc02002f0:	01458593          	addi	a1,a1,20 # ffffffffc02a7300 <buf>
ffffffffc02002f4:	00006517          	auipc	a0,0x6
ffffffffc02002f8:	27c50513          	addi	a0,a0,636 # ffffffffc0206570 <etext+0xd4>
ffffffffc02002fc:	dd1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200300:	000b2597          	auipc	a1,0xb2
ffffffffc0200304:	55c58593          	addi	a1,a1,1372 # ffffffffc02b285c <end>
ffffffffc0200308:	00006517          	auipc	a0,0x6
ffffffffc020030c:	28850513          	addi	a0,a0,648 # ffffffffc0206590 <etext+0xf4>
ffffffffc0200310:	dbdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200314:	000b3597          	auipc	a1,0xb3
ffffffffc0200318:	94758593          	addi	a1,a1,-1721 # ffffffffc02b2c5b <end+0x3ff>
ffffffffc020031c:	00000797          	auipc	a5,0x0
ffffffffc0200320:	d1678793          	addi	a5,a5,-746 # ffffffffc0200032 <kern_init>
ffffffffc0200324:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200328:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020032c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020032e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200332:	95be                	add	a1,a1,a5
ffffffffc0200334:	85a9                	srai	a1,a1,0xa
ffffffffc0200336:	00006517          	auipc	a0,0x6
ffffffffc020033a:	27a50513          	addi	a0,a0,634 # ffffffffc02065b0 <etext+0x114>
}
ffffffffc020033e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200340:	b371                	j	ffffffffc02000cc <cprintf>

ffffffffc0200342 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200342:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200344:	00006617          	auipc	a2,0x6
ffffffffc0200348:	29c60613          	addi	a2,a2,668 # ffffffffc02065e0 <etext+0x144>
ffffffffc020034c:	04d00593          	li	a1,77
ffffffffc0200350:	00006517          	auipc	a0,0x6
ffffffffc0200354:	2a850513          	addi	a0,a0,680 # ffffffffc02065f8 <etext+0x15c>
void print_stackframe(void) {
ffffffffc0200358:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020035a:	eafff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020035e <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020035e:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200360:	00006617          	auipc	a2,0x6
ffffffffc0200364:	2b060613          	addi	a2,a2,688 # ffffffffc0206610 <etext+0x174>
ffffffffc0200368:	00006597          	auipc	a1,0x6
ffffffffc020036c:	2c858593          	addi	a1,a1,712 # ffffffffc0206630 <etext+0x194>
ffffffffc0200370:	00006517          	auipc	a0,0x6
ffffffffc0200374:	2c850513          	addi	a0,a0,712 # ffffffffc0206638 <etext+0x19c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200378:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020037a:	d53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020037e:	00006617          	auipc	a2,0x6
ffffffffc0200382:	2ca60613          	addi	a2,a2,714 # ffffffffc0206648 <etext+0x1ac>
ffffffffc0200386:	00006597          	auipc	a1,0x6
ffffffffc020038a:	2ea58593          	addi	a1,a1,746 # ffffffffc0206670 <etext+0x1d4>
ffffffffc020038e:	00006517          	auipc	a0,0x6
ffffffffc0200392:	2aa50513          	addi	a0,a0,682 # ffffffffc0206638 <etext+0x19c>
ffffffffc0200396:	d37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020039a:	00006617          	auipc	a2,0x6
ffffffffc020039e:	2e660613          	addi	a2,a2,742 # ffffffffc0206680 <etext+0x1e4>
ffffffffc02003a2:	00006597          	auipc	a1,0x6
ffffffffc02003a6:	2fe58593          	addi	a1,a1,766 # ffffffffc02066a0 <etext+0x204>
ffffffffc02003aa:	00006517          	auipc	a0,0x6
ffffffffc02003ae:	28e50513          	addi	a0,a0,654 # ffffffffc0206638 <etext+0x19c>
ffffffffc02003b2:	d1bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    }
    return 0;
}
ffffffffc02003b6:	60a2                	ld	ra,8(sp)
ffffffffc02003b8:	4501                	li	a0,0
ffffffffc02003ba:	0141                	addi	sp,sp,16
ffffffffc02003bc:	8082                	ret

ffffffffc02003be <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003be:	1141                	addi	sp,sp,-16
ffffffffc02003c0:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003c2:	ef3ff0ef          	jal	ra,ffffffffc02002b4 <print_kerninfo>
    return 0;
}
ffffffffc02003c6:	60a2                	ld	ra,8(sp)
ffffffffc02003c8:	4501                	li	a0,0
ffffffffc02003ca:	0141                	addi	sp,sp,16
ffffffffc02003cc:	8082                	ret

ffffffffc02003ce <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003ce:	1141                	addi	sp,sp,-16
ffffffffc02003d0:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003d2:	f71ff0ef          	jal	ra,ffffffffc0200342 <print_stackframe>
    return 0;
}
ffffffffc02003d6:	60a2                	ld	ra,8(sp)
ffffffffc02003d8:	4501                	li	a0,0
ffffffffc02003da:	0141                	addi	sp,sp,16
ffffffffc02003dc:	8082                	ret

ffffffffc02003de <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02003de:	7115                	addi	sp,sp,-224
ffffffffc02003e0:	ed5e                	sd	s7,152(sp)
ffffffffc02003e2:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003e4:	00006517          	auipc	a0,0x6
ffffffffc02003e8:	2cc50513          	addi	a0,a0,716 # ffffffffc02066b0 <etext+0x214>
kmonitor(struct trapframe *tf) {
ffffffffc02003ec:	ed86                	sd	ra,216(sp)
ffffffffc02003ee:	e9a2                	sd	s0,208(sp)
ffffffffc02003f0:	e5a6                	sd	s1,200(sp)
ffffffffc02003f2:	e1ca                	sd	s2,192(sp)
ffffffffc02003f4:	fd4e                	sd	s3,184(sp)
ffffffffc02003f6:	f952                	sd	s4,176(sp)
ffffffffc02003f8:	f556                	sd	s5,168(sp)
ffffffffc02003fa:	f15a                	sd	s6,160(sp)
ffffffffc02003fc:	e962                	sd	s8,144(sp)
ffffffffc02003fe:	e566                	sd	s9,136(sp)
ffffffffc0200400:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200402:	ccbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200406:	00006517          	auipc	a0,0x6
ffffffffc020040a:	2d250513          	addi	a0,a0,722 # ffffffffc02066d8 <etext+0x23c>
ffffffffc020040e:	cbfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    if (tf != NULL) {
ffffffffc0200412:	000b8563          	beqz	s7,ffffffffc020041c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200416:	855e                	mv	a0,s7
ffffffffc0200418:	3fa000ef          	jal	ra,ffffffffc0200812 <print_trapframe>
ffffffffc020041c:	00006c17          	auipc	s8,0x6
ffffffffc0200420:	32cc0c13          	addi	s8,s8,812 # ffffffffc0206748 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200424:	00006917          	auipc	s2,0x6
ffffffffc0200428:	2dc90913          	addi	s2,s2,732 # ffffffffc0206700 <etext+0x264>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020042c:	00006497          	auipc	s1,0x6
ffffffffc0200430:	2dc48493          	addi	s1,s1,732 # ffffffffc0206708 <etext+0x26c>
        if (argc == MAXARGS - 1) {
ffffffffc0200434:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200436:	00006b17          	auipc	s6,0x6
ffffffffc020043a:	2dab0b13          	addi	s6,s6,730 # ffffffffc0206710 <etext+0x274>
        argv[argc ++] = buf;
ffffffffc020043e:	00006a17          	auipc	s4,0x6
ffffffffc0200442:	1f2a0a13          	addi	s4,s4,498 # ffffffffc0206630 <etext+0x194>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200446:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200448:	854a                	mv	a0,s2
ffffffffc020044a:	d0bff0ef          	jal	ra,ffffffffc0200154 <readline>
ffffffffc020044e:	842a                	mv	s0,a0
ffffffffc0200450:	dd65                	beqz	a0,ffffffffc0200448 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200452:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200456:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200458:	e1bd                	bnez	a1,ffffffffc02004be <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc020045a:	fe0c87e3          	beqz	s9,ffffffffc0200448 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020045e:	6582                	ld	a1,0(sp)
ffffffffc0200460:	00006d17          	auipc	s10,0x6
ffffffffc0200464:	2e8d0d13          	addi	s10,s10,744 # ffffffffc0206748 <commands>
        argv[argc ++] = buf;
ffffffffc0200468:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020046a:	4401                	li	s0,0
ffffffffc020046c:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020046e:	3cd050ef          	jal	ra,ffffffffc020603a <strcmp>
ffffffffc0200472:	c919                	beqz	a0,ffffffffc0200488 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200474:	2405                	addiw	s0,s0,1
ffffffffc0200476:	0b540063          	beq	s0,s5,ffffffffc0200516 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020047a:	000d3503          	ld	a0,0(s10)
ffffffffc020047e:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200480:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200482:	3b9050ef          	jal	ra,ffffffffc020603a <strcmp>
ffffffffc0200486:	f57d                	bnez	a0,ffffffffc0200474 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200488:	00141793          	slli	a5,s0,0x1
ffffffffc020048c:	97a2                	add	a5,a5,s0
ffffffffc020048e:	078e                	slli	a5,a5,0x3
ffffffffc0200490:	97e2                	add	a5,a5,s8
ffffffffc0200492:	6b9c                	ld	a5,16(a5)
ffffffffc0200494:	865e                	mv	a2,s7
ffffffffc0200496:	002c                	addi	a1,sp,8
ffffffffc0200498:	fffc851b          	addiw	a0,s9,-1
ffffffffc020049c:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020049e:	fa0555e3          	bgez	a0,ffffffffc0200448 <kmonitor+0x6a>
}
ffffffffc02004a2:	60ee                	ld	ra,216(sp)
ffffffffc02004a4:	644e                	ld	s0,208(sp)
ffffffffc02004a6:	64ae                	ld	s1,200(sp)
ffffffffc02004a8:	690e                	ld	s2,192(sp)
ffffffffc02004aa:	79ea                	ld	s3,184(sp)
ffffffffc02004ac:	7a4a                	ld	s4,176(sp)
ffffffffc02004ae:	7aaa                	ld	s5,168(sp)
ffffffffc02004b0:	7b0a                	ld	s6,160(sp)
ffffffffc02004b2:	6bea                	ld	s7,152(sp)
ffffffffc02004b4:	6c4a                	ld	s8,144(sp)
ffffffffc02004b6:	6caa                	ld	s9,136(sp)
ffffffffc02004b8:	6d0a                	ld	s10,128(sp)
ffffffffc02004ba:	612d                	addi	sp,sp,224
ffffffffc02004bc:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02004be:	8526                	mv	a0,s1
ffffffffc02004c0:	399050ef          	jal	ra,ffffffffc0206058 <strchr>
ffffffffc02004c4:	c901                	beqz	a0,ffffffffc02004d4 <kmonitor+0xf6>
ffffffffc02004c6:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02004ca:	00040023          	sb	zero,0(s0)
ffffffffc02004ce:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02004d0:	d5c9                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc02004d2:	b7f5                	j	ffffffffc02004be <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02004d4:	00044783          	lbu	a5,0(s0)
ffffffffc02004d8:	d3c9                	beqz	a5,ffffffffc020045a <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02004da:	033c8963          	beq	s9,s3,ffffffffc020050c <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02004de:	003c9793          	slli	a5,s9,0x3
ffffffffc02004e2:	0118                	addi	a4,sp,128
ffffffffc02004e4:	97ba                	add	a5,a5,a4
ffffffffc02004e6:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004ea:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02004ee:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004f0:	e591                	bnez	a1,ffffffffc02004fc <kmonitor+0x11e>
ffffffffc02004f2:	b7b5                	j	ffffffffc020045e <kmonitor+0x80>
ffffffffc02004f4:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02004f8:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004fa:	d1a5                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc02004fc:	8526                	mv	a0,s1
ffffffffc02004fe:	35b050ef          	jal	ra,ffffffffc0206058 <strchr>
ffffffffc0200502:	d96d                	beqz	a0,ffffffffc02004f4 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200504:	00044583          	lbu	a1,0(s0)
ffffffffc0200508:	d9a9                	beqz	a1,ffffffffc020045a <kmonitor+0x7c>
ffffffffc020050a:	bf55                	j	ffffffffc02004be <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020050c:	45c1                	li	a1,16
ffffffffc020050e:	855a                	mv	a0,s6
ffffffffc0200510:	bbdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0200514:	b7e9                	j	ffffffffc02004de <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200516:	6582                	ld	a1,0(sp)
ffffffffc0200518:	00006517          	auipc	a0,0x6
ffffffffc020051c:	21850513          	addi	a0,a0,536 # ffffffffc0206730 <etext+0x294>
ffffffffc0200520:	badff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
ffffffffc0200524:	b715                	j	ffffffffc0200448 <kmonitor+0x6a>

ffffffffc0200526 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200526:	8082                	ret

ffffffffc0200528 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200528:	00253513          	sltiu	a0,a0,2
ffffffffc020052c:	8082                	ret

ffffffffc020052e <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020052e:	03800513          	li	a0,56
ffffffffc0200532:	8082                	ret

ffffffffc0200534 <ide_write_secs>:
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200534:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200538:	000a7517          	auipc	a0,0xa7
ffffffffc020053c:	1c850513          	addi	a0,a0,456 # ffffffffc02a7700 <ide>
                   size_t nsecs) {
ffffffffc0200540:	1141                	addi	sp,sp,-16
ffffffffc0200542:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200544:	953e                	add	a0,a0,a5
ffffffffc0200546:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc020054a:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020054c:	335050ef          	jal	ra,ffffffffc0206080 <memcpy>
    return 0;
}
ffffffffc0200550:	60a2                	ld	ra,8(sp)
ffffffffc0200552:	4501                	li	a0,0
ffffffffc0200554:	0141                	addi	sp,sp,16
ffffffffc0200556:	8082                	ret

ffffffffc0200558 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200558:	67e1                	lui	a5,0x18
ffffffffc020055a:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd580>
ffffffffc020055e:	000b2717          	auipc	a4,0xb2
ffffffffc0200562:	26f73d23          	sd	a5,634(a4) # ffffffffc02b27d8 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200566:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020056a:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020056c:	953e                	add	a0,a0,a5
ffffffffc020056e:	4601                	li	a2,0
ffffffffc0200570:	4881                	li	a7,0
ffffffffc0200572:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200576:	02000793          	li	a5,32
ffffffffc020057a:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020057e:	00006517          	auipc	a0,0x6
ffffffffc0200582:	21250513          	addi	a0,a0,530 # ffffffffc0206790 <commands+0x48>
    ticks = 0;
ffffffffc0200586:	000b2797          	auipc	a5,0xb2
ffffffffc020058a:	2407b523          	sd	zero,586(a5) # ffffffffc02b27d0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020058e:	be3d                	j	ffffffffc02000cc <cprintf>

ffffffffc0200590 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200590:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200594:	000b2797          	auipc	a5,0xb2
ffffffffc0200598:	2447b783          	ld	a5,580(a5) # ffffffffc02b27d8 <timebase>
ffffffffc020059c:	953e                	add	a0,a0,a5
ffffffffc020059e:	4581                	li	a1,0
ffffffffc02005a0:	4601                	li	a2,0
ffffffffc02005a2:	4881                	li	a7,0
ffffffffc02005a4:	00000073          	ecall
ffffffffc02005a8:	8082                	ret

ffffffffc02005aa <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005aa:	8082                	ret

ffffffffc02005ac <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005ac:	100027f3          	csrr	a5,sstatus
ffffffffc02005b0:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005b2:	0ff57513          	zext.b	a0,a0
ffffffffc02005b6:	e799                	bnez	a5,ffffffffc02005c4 <cons_putc+0x18>
ffffffffc02005b8:	4581                	li	a1,0
ffffffffc02005ba:	4601                	li	a2,0
ffffffffc02005bc:	4885                	li	a7,1
ffffffffc02005be:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005c2:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005c4:	1101                	addi	sp,sp,-32
ffffffffc02005c6:	ec06                	sd	ra,24(sp)
ffffffffc02005c8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005ca:	05a000ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc02005ce:	6522                	ld	a0,8(sp)
ffffffffc02005d0:	4581                	li	a1,0
ffffffffc02005d2:	4601                	li	a2,0
ffffffffc02005d4:	4885                	li	a7,1
ffffffffc02005d6:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005da:	60e2                	ld	ra,24(sp)
ffffffffc02005dc:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005de:	a081                	j	ffffffffc020061e <intr_enable>

ffffffffc02005e0 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005e0:	100027f3          	csrr	a5,sstatus
ffffffffc02005e4:	8b89                	andi	a5,a5,2
ffffffffc02005e6:	eb89                	bnez	a5,ffffffffc02005f8 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005e8:	4501                	li	a0,0
ffffffffc02005ea:	4581                	li	a1,0
ffffffffc02005ec:	4601                	li	a2,0
ffffffffc02005ee:	4889                	li	a7,2
ffffffffc02005f0:	00000073          	ecall
ffffffffc02005f4:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005f6:	8082                	ret
int cons_getc(void) {
ffffffffc02005f8:	1101                	addi	sp,sp,-32
ffffffffc02005fa:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005fc:	028000ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc0200600:	4501                	li	a0,0
ffffffffc0200602:	4581                	li	a1,0
ffffffffc0200604:	4601                	li	a2,0
ffffffffc0200606:	4889                	li	a7,2
ffffffffc0200608:	00000073          	ecall
ffffffffc020060c:	2501                	sext.w	a0,a0
ffffffffc020060e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200610:	00e000ef          	jal	ra,ffffffffc020061e <intr_enable>
}
ffffffffc0200614:	60e2                	ld	ra,24(sp)
ffffffffc0200616:	6522                	ld	a0,8(sp)
ffffffffc0200618:	6105                	addi	sp,sp,32
ffffffffc020061a:	8082                	ret

ffffffffc020061c <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc020061c:	8082                	ret

ffffffffc020061e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020061e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200622:	8082                	ret

ffffffffc0200624 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200624:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200628:	8082                	ret

ffffffffc020062a <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020062a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020062e:	00000797          	auipc	a5,0x0
ffffffffc0200632:	65678793          	addi	a5,a5,1622 # ffffffffc0200c84 <__alltraps>
ffffffffc0200636:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020063a:	000407b7          	lui	a5,0x40
ffffffffc020063e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200642:	8082                	ret

ffffffffc0200644 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200644:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200646:	1141                	addi	sp,sp,-16
ffffffffc0200648:	e022                	sd	s0,0(sp)
ffffffffc020064a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020064c:	00006517          	auipc	a0,0x6
ffffffffc0200650:	16450513          	addi	a0,a0,356 # ffffffffc02067b0 <commands+0x68>
void print_regs(struct pushregs* gpr) {
ffffffffc0200654:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200656:	a77ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020065a:	640c                	ld	a1,8(s0)
ffffffffc020065c:	00006517          	auipc	a0,0x6
ffffffffc0200660:	16c50513          	addi	a0,a0,364 # ffffffffc02067c8 <commands+0x80>
ffffffffc0200664:	a69ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200668:	680c                	ld	a1,16(s0)
ffffffffc020066a:	00006517          	auipc	a0,0x6
ffffffffc020066e:	17650513          	addi	a0,a0,374 # ffffffffc02067e0 <commands+0x98>
ffffffffc0200672:	a5bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200676:	6c0c                	ld	a1,24(s0)
ffffffffc0200678:	00006517          	auipc	a0,0x6
ffffffffc020067c:	18050513          	addi	a0,a0,384 # ffffffffc02067f8 <commands+0xb0>
ffffffffc0200680:	a4dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200684:	700c                	ld	a1,32(s0)
ffffffffc0200686:	00006517          	auipc	a0,0x6
ffffffffc020068a:	18a50513          	addi	a0,a0,394 # ffffffffc0206810 <commands+0xc8>
ffffffffc020068e:	a3fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200692:	740c                	ld	a1,40(s0)
ffffffffc0200694:	00006517          	auipc	a0,0x6
ffffffffc0200698:	19450513          	addi	a0,a0,404 # ffffffffc0206828 <commands+0xe0>
ffffffffc020069c:	a31ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006a0:	780c                	ld	a1,48(s0)
ffffffffc02006a2:	00006517          	auipc	a0,0x6
ffffffffc02006a6:	19e50513          	addi	a0,a0,414 # ffffffffc0206840 <commands+0xf8>
ffffffffc02006aa:	a23ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006ae:	7c0c                	ld	a1,56(s0)
ffffffffc02006b0:	00006517          	auipc	a0,0x6
ffffffffc02006b4:	1a850513          	addi	a0,a0,424 # ffffffffc0206858 <commands+0x110>
ffffffffc02006b8:	a15ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006bc:	602c                	ld	a1,64(s0)
ffffffffc02006be:	00006517          	auipc	a0,0x6
ffffffffc02006c2:	1b250513          	addi	a0,a0,434 # ffffffffc0206870 <commands+0x128>
ffffffffc02006c6:	a07ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ca:	642c                	ld	a1,72(s0)
ffffffffc02006cc:	00006517          	auipc	a0,0x6
ffffffffc02006d0:	1bc50513          	addi	a0,a0,444 # ffffffffc0206888 <commands+0x140>
ffffffffc02006d4:	9f9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006d8:	682c                	ld	a1,80(s0)
ffffffffc02006da:	00006517          	auipc	a0,0x6
ffffffffc02006de:	1c650513          	addi	a0,a0,454 # ffffffffc02068a0 <commands+0x158>
ffffffffc02006e2:	9ebff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006e6:	6c2c                	ld	a1,88(s0)
ffffffffc02006e8:	00006517          	auipc	a0,0x6
ffffffffc02006ec:	1d050513          	addi	a0,a0,464 # ffffffffc02068b8 <commands+0x170>
ffffffffc02006f0:	9ddff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02006f4:	702c                	ld	a1,96(s0)
ffffffffc02006f6:	00006517          	auipc	a0,0x6
ffffffffc02006fa:	1da50513          	addi	a0,a0,474 # ffffffffc02068d0 <commands+0x188>
ffffffffc02006fe:	9cfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200702:	742c                	ld	a1,104(s0)
ffffffffc0200704:	00006517          	auipc	a0,0x6
ffffffffc0200708:	1e450513          	addi	a0,a0,484 # ffffffffc02068e8 <commands+0x1a0>
ffffffffc020070c:	9c1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200710:	782c                	ld	a1,112(s0)
ffffffffc0200712:	00006517          	auipc	a0,0x6
ffffffffc0200716:	1ee50513          	addi	a0,a0,494 # ffffffffc0206900 <commands+0x1b8>
ffffffffc020071a:	9b3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020071e:	7c2c                	ld	a1,120(s0)
ffffffffc0200720:	00006517          	auipc	a0,0x6
ffffffffc0200724:	1f850513          	addi	a0,a0,504 # ffffffffc0206918 <commands+0x1d0>
ffffffffc0200728:	9a5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020072c:	604c                	ld	a1,128(s0)
ffffffffc020072e:	00006517          	auipc	a0,0x6
ffffffffc0200732:	20250513          	addi	a0,a0,514 # ffffffffc0206930 <commands+0x1e8>
ffffffffc0200736:	997ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020073a:	644c                	ld	a1,136(s0)
ffffffffc020073c:	00006517          	auipc	a0,0x6
ffffffffc0200740:	20c50513          	addi	a0,a0,524 # ffffffffc0206948 <commands+0x200>
ffffffffc0200744:	989ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200748:	684c                	ld	a1,144(s0)
ffffffffc020074a:	00006517          	auipc	a0,0x6
ffffffffc020074e:	21650513          	addi	a0,a0,534 # ffffffffc0206960 <commands+0x218>
ffffffffc0200752:	97bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200756:	6c4c                	ld	a1,152(s0)
ffffffffc0200758:	00006517          	auipc	a0,0x6
ffffffffc020075c:	22050513          	addi	a0,a0,544 # ffffffffc0206978 <commands+0x230>
ffffffffc0200760:	96dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200764:	704c                	ld	a1,160(s0)
ffffffffc0200766:	00006517          	auipc	a0,0x6
ffffffffc020076a:	22a50513          	addi	a0,a0,554 # ffffffffc0206990 <commands+0x248>
ffffffffc020076e:	95fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200772:	744c                	ld	a1,168(s0)
ffffffffc0200774:	00006517          	auipc	a0,0x6
ffffffffc0200778:	23450513          	addi	a0,a0,564 # ffffffffc02069a8 <commands+0x260>
ffffffffc020077c:	951ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200780:	784c                	ld	a1,176(s0)
ffffffffc0200782:	00006517          	auipc	a0,0x6
ffffffffc0200786:	23e50513          	addi	a0,a0,574 # ffffffffc02069c0 <commands+0x278>
ffffffffc020078a:	943ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020078e:	7c4c                	ld	a1,184(s0)
ffffffffc0200790:	00006517          	auipc	a0,0x6
ffffffffc0200794:	24850513          	addi	a0,a0,584 # ffffffffc02069d8 <commands+0x290>
ffffffffc0200798:	935ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc020079c:	606c                	ld	a1,192(s0)
ffffffffc020079e:	00006517          	auipc	a0,0x6
ffffffffc02007a2:	25250513          	addi	a0,a0,594 # ffffffffc02069f0 <commands+0x2a8>
ffffffffc02007a6:	927ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007aa:	646c                	ld	a1,200(s0)
ffffffffc02007ac:	00006517          	auipc	a0,0x6
ffffffffc02007b0:	25c50513          	addi	a0,a0,604 # ffffffffc0206a08 <commands+0x2c0>
ffffffffc02007b4:	919ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007b8:	686c                	ld	a1,208(s0)
ffffffffc02007ba:	00006517          	auipc	a0,0x6
ffffffffc02007be:	26650513          	addi	a0,a0,614 # ffffffffc0206a20 <commands+0x2d8>
ffffffffc02007c2:	90bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007c6:	6c6c                	ld	a1,216(s0)
ffffffffc02007c8:	00006517          	auipc	a0,0x6
ffffffffc02007cc:	27050513          	addi	a0,a0,624 # ffffffffc0206a38 <commands+0x2f0>
ffffffffc02007d0:	8fdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007d4:	706c                	ld	a1,224(s0)
ffffffffc02007d6:	00006517          	auipc	a0,0x6
ffffffffc02007da:	27a50513          	addi	a0,a0,634 # ffffffffc0206a50 <commands+0x308>
ffffffffc02007de:	8efff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007e2:	746c                	ld	a1,232(s0)
ffffffffc02007e4:	00006517          	auipc	a0,0x6
ffffffffc02007e8:	28450513          	addi	a0,a0,644 # ffffffffc0206a68 <commands+0x320>
ffffffffc02007ec:	8e1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02007f0:	786c                	ld	a1,240(s0)
ffffffffc02007f2:	00006517          	auipc	a0,0x6
ffffffffc02007f6:	28e50513          	addi	a0,a0,654 # ffffffffc0206a80 <commands+0x338>
ffffffffc02007fa:	8d3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc02007fe:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200800:	6402                	ld	s0,0(sp)
ffffffffc0200802:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200804:	00006517          	auipc	a0,0x6
ffffffffc0200808:	29450513          	addi	a0,a0,660 # ffffffffc0206a98 <commands+0x350>
}
ffffffffc020080c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020080e:	8bfff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200812 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200812:	1141                	addi	sp,sp,-16
ffffffffc0200814:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200816:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200818:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020081a:	00006517          	auipc	a0,0x6
ffffffffc020081e:	29650513          	addi	a0,a0,662 # ffffffffc0206ab0 <commands+0x368>
print_trapframe(struct trapframe *tf) {
ffffffffc0200822:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200824:	8a9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200828:	8522                	mv	a0,s0
ffffffffc020082a:	e1bff0ef          	jal	ra,ffffffffc0200644 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020082e:	10043583          	ld	a1,256(s0)
ffffffffc0200832:	00006517          	auipc	a0,0x6
ffffffffc0200836:	29650513          	addi	a0,a0,662 # ffffffffc0206ac8 <commands+0x380>
ffffffffc020083a:	893ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020083e:	10843583          	ld	a1,264(s0)
ffffffffc0200842:	00006517          	auipc	a0,0x6
ffffffffc0200846:	29e50513          	addi	a0,a0,670 # ffffffffc0206ae0 <commands+0x398>
ffffffffc020084a:	883ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020084e:	11043583          	ld	a1,272(s0)
ffffffffc0200852:	00006517          	auipc	a0,0x6
ffffffffc0200856:	2a650513          	addi	a0,a0,678 # ffffffffc0206af8 <commands+0x3b0>
ffffffffc020085a:	873ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020085e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200862:	6402                	ld	s0,0(sp)
ffffffffc0200864:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200866:	00006517          	auipc	a0,0x6
ffffffffc020086a:	2a250513          	addi	a0,a0,674 # ffffffffc0206b08 <commands+0x3c0>
}
ffffffffc020086e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200870:	85dff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200874 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200874:	1101                	addi	sp,sp,-32
ffffffffc0200876:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc0200878:	000b2497          	auipc	s1,0xb2
ffffffffc020087c:	f6848493          	addi	s1,s1,-152 # ffffffffc02b27e0 <check_mm_struct>
ffffffffc0200880:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc0200882:	e822                	sd	s0,16(sp)
ffffffffc0200884:	ec06                	sd	ra,24(sp)
ffffffffc0200886:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc0200888:	cba5                	beqz	a5,ffffffffc02008f8 <pgfault_handler+0x84>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020088a:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020088e:	11053583          	ld	a1,272(a0)
ffffffffc0200892:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200896:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020089a:	c7a9                	beqz	a5,ffffffffc02008e4 <pgfault_handler+0x70>
ffffffffc020089c:	11843703          	ld	a4,280(s0)
ffffffffc02008a0:	47bd                	li	a5,15
ffffffffc02008a2:	05700693          	li	a3,87
ffffffffc02008a6:	00f70463          	beq	a4,a5,ffffffffc02008ae <pgfault_handler+0x3a>
ffffffffc02008aa:	05200693          	li	a3,82
ffffffffc02008ae:	00006517          	auipc	a0,0x6
ffffffffc02008b2:	27250513          	addi	a0,a0,626 # ffffffffc0206b20 <commands+0x3d8>
ffffffffc02008b6:	817ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008ba:	6088                	ld	a0,0(s1)
ffffffffc02008bc:	cd15                	beqz	a0,ffffffffc02008f8 <pgfault_handler+0x84>
        assert(current == idleproc);
ffffffffc02008be:	000b2717          	auipc	a4,0xb2
ffffffffc02008c2:	f8273703          	ld	a4,-126(a4) # ffffffffc02b2840 <current>
ffffffffc02008c6:	000b2797          	auipc	a5,0xb2
ffffffffc02008ca:	f827b783          	ld	a5,-126(a5) # ffffffffc02b2848 <idleproc>
ffffffffc02008ce:	04f71463          	bne	a4,a5,ffffffffc0200916 <pgfault_handler+0xa2>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return privated_write_state(mm, tf->cause, tf->tval);//do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008d2:	11043603          	ld	a2,272(s0)
ffffffffc02008d6:	11843583          	ld	a1,280(s0)
}
ffffffffc02008da:	6442                	ld	s0,16(sp)
ffffffffc02008dc:	60e2                	ld	ra,24(sp)
ffffffffc02008de:	64a2                	ld	s1,8(sp)
ffffffffc02008e0:	6105                	addi	sp,sp,32
    return privated_write_state(mm, tf->cause, tf->tval);//do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008e2:	ad5d                	j	ffffffffc0200f98 <privated_write_state>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008e4:	11843703          	ld	a4,280(s0)
ffffffffc02008e8:	47bd                	li	a5,15
ffffffffc02008ea:	05500613          	li	a2,85
ffffffffc02008ee:	05700693          	li	a3,87
ffffffffc02008f2:	faf71ce3          	bne	a4,a5,ffffffffc02008aa <pgfault_handler+0x36>
ffffffffc02008f6:	bf65                	j	ffffffffc02008ae <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc02008f8:	000b2797          	auipc	a5,0xb2
ffffffffc02008fc:	f487b783          	ld	a5,-184(a5) # ffffffffc02b2840 <current>
ffffffffc0200900:	cb9d                	beqz	a5,ffffffffc0200936 <pgfault_handler+0xc2>
    return privated_write_state(mm, tf->cause, tf->tval);//do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200902:	11043603          	ld	a2,272(s0)
ffffffffc0200906:	11843583          	ld	a1,280(s0)
}
ffffffffc020090a:	6442                	ld	s0,16(sp)
ffffffffc020090c:	60e2                	ld	ra,24(sp)
ffffffffc020090e:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200910:	7788                	ld	a0,40(a5)
}
ffffffffc0200912:	6105                	addi	sp,sp,32
    return privated_write_state(mm, tf->cause, tf->tval);//do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200914:	a551                	j	ffffffffc0200f98 <privated_write_state>
        assert(current == idleproc);
ffffffffc0200916:	00006697          	auipc	a3,0x6
ffffffffc020091a:	22a68693          	addi	a3,a3,554 # ffffffffc0206b40 <commands+0x3f8>
ffffffffc020091e:	00006617          	auipc	a2,0x6
ffffffffc0200922:	23a60613          	addi	a2,a2,570 # ffffffffc0206b58 <commands+0x410>
ffffffffc0200926:	06c00593          	li	a1,108
ffffffffc020092a:	00006517          	auipc	a0,0x6
ffffffffc020092e:	24650513          	addi	a0,a0,582 # ffffffffc0206b70 <commands+0x428>
ffffffffc0200932:	8d7ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            print_trapframe(tf);
ffffffffc0200936:	8522                	mv	a0,s0
ffffffffc0200938:	edbff0ef          	jal	ra,ffffffffc0200812 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020093c:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200940:	11043583          	ld	a1,272(s0)
ffffffffc0200944:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200948:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020094c:	e399                	bnez	a5,ffffffffc0200952 <pgfault_handler+0xde>
ffffffffc020094e:	05500613          	li	a2,85
ffffffffc0200952:	11843703          	ld	a4,280(s0)
ffffffffc0200956:	47bd                	li	a5,15
ffffffffc0200958:	02f70663          	beq	a4,a5,ffffffffc0200984 <pgfault_handler+0x110>
ffffffffc020095c:	05200693          	li	a3,82
ffffffffc0200960:	00006517          	auipc	a0,0x6
ffffffffc0200964:	1c050513          	addi	a0,a0,448 # ffffffffc0206b20 <commands+0x3d8>
ffffffffc0200968:	f64ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            panic("unhandled page fault.\n");
ffffffffc020096c:	00006617          	auipc	a2,0x6
ffffffffc0200970:	21c60613          	addi	a2,a2,540 # ffffffffc0206b88 <commands+0x440>
ffffffffc0200974:	07300593          	li	a1,115
ffffffffc0200978:	00006517          	auipc	a0,0x6
ffffffffc020097c:	1f850513          	addi	a0,a0,504 # ffffffffc0206b70 <commands+0x428>
ffffffffc0200980:	889ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200984:	05700693          	li	a3,87
ffffffffc0200988:	bfe1                	j	ffffffffc0200960 <pgfault_handler+0xec>

ffffffffc020098a <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020098a:	11853783          	ld	a5,280(a0)
ffffffffc020098e:	472d                	li	a4,11
ffffffffc0200990:	0786                	slli	a5,a5,0x1
ffffffffc0200992:	8385                	srli	a5,a5,0x1
ffffffffc0200994:	08f76363          	bltu	a4,a5,ffffffffc0200a1a <interrupt_handler+0x90>
ffffffffc0200998:	00006717          	auipc	a4,0x6
ffffffffc020099c:	2a870713          	addi	a4,a4,680 # ffffffffc0206c40 <commands+0x4f8>
ffffffffc02009a0:	078a                	slli	a5,a5,0x2
ffffffffc02009a2:	97ba                	add	a5,a5,a4
ffffffffc02009a4:	439c                	lw	a5,0(a5)
ffffffffc02009a6:	97ba                	add	a5,a5,a4
ffffffffc02009a8:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009aa:	00006517          	auipc	a0,0x6
ffffffffc02009ae:	25650513          	addi	a0,a0,598 # ffffffffc0206c00 <commands+0x4b8>
ffffffffc02009b2:	f1aff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009b6:	00006517          	auipc	a0,0x6
ffffffffc02009ba:	22a50513          	addi	a0,a0,554 # ffffffffc0206be0 <commands+0x498>
ffffffffc02009be:	f0eff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009c2:	00006517          	auipc	a0,0x6
ffffffffc02009c6:	1de50513          	addi	a0,a0,478 # ffffffffc0206ba0 <commands+0x458>
ffffffffc02009ca:	f02ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009ce:	00006517          	auipc	a0,0x6
ffffffffc02009d2:	1f250513          	addi	a0,a0,498 # ffffffffc0206bc0 <commands+0x478>
ffffffffc02009d6:	ef6ff06f          	j	ffffffffc02000cc <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02009da:	1141                	addi	sp,sp,-16
ffffffffc02009dc:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02009de:	bb3ff0ef          	jal	ra,ffffffffc0200590 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc02009e2:	000b2697          	auipc	a3,0xb2
ffffffffc02009e6:	dee68693          	addi	a3,a3,-530 # ffffffffc02b27d0 <ticks>
ffffffffc02009ea:	629c                	ld	a5,0(a3)
ffffffffc02009ec:	06400713          	li	a4,100
ffffffffc02009f0:	0785                	addi	a5,a5,1
ffffffffc02009f2:	02e7f733          	remu	a4,a5,a4
ffffffffc02009f6:	e29c                	sd	a5,0(a3)
ffffffffc02009f8:	eb01                	bnez	a4,ffffffffc0200a08 <interrupt_handler+0x7e>
ffffffffc02009fa:	000b2797          	auipc	a5,0xb2
ffffffffc02009fe:	e467b783          	ld	a5,-442(a5) # ffffffffc02b2840 <current>
ffffffffc0200a02:	c399                	beqz	a5,ffffffffc0200a08 <interrupt_handler+0x7e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc0200a04:	4705                	li	a4,1
ffffffffc0200a06:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a08:	60a2                	ld	ra,8(sp)
ffffffffc0200a0a:	0141                	addi	sp,sp,16
ffffffffc0200a0c:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a0e:	00006517          	auipc	a0,0x6
ffffffffc0200a12:	21250513          	addi	a0,a0,530 # ffffffffc0206c20 <commands+0x4d8>
ffffffffc0200a16:	eb6ff06f          	j	ffffffffc02000cc <cprintf>
            print_trapframe(tf);
ffffffffc0200a1a:	bbe5                	j	ffffffffc0200812 <print_trapframe>

ffffffffc0200a1c <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a1c:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a20:	1101                	addi	sp,sp,-32
ffffffffc0200a22:	e822                	sd	s0,16(sp)
ffffffffc0200a24:	ec06                	sd	ra,24(sp)
ffffffffc0200a26:	e426                	sd	s1,8(sp)
ffffffffc0200a28:	473d                	li	a4,15
ffffffffc0200a2a:	842a                	mv	s0,a0
ffffffffc0200a2c:	18f76563          	bltu	a4,a5,ffffffffc0200bb6 <exception_handler+0x19a>
ffffffffc0200a30:	00006717          	auipc	a4,0x6
ffffffffc0200a34:	3d870713          	addi	a4,a4,984 # ffffffffc0206e08 <commands+0x6c0>
ffffffffc0200a38:	078a                	slli	a5,a5,0x2
ffffffffc0200a3a:	97ba                	add	a5,a5,a4
ffffffffc0200a3c:	439c                	lw	a5,0(a5)
ffffffffc0200a3e:	97ba                	add	a5,a5,a4
ffffffffc0200a40:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a42:	00006517          	auipc	a0,0x6
ffffffffc0200a46:	31e50513          	addi	a0,a0,798 # ffffffffc0206d60 <commands+0x618>
ffffffffc0200a4a:	e82ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            tf->epc += 4;
ffffffffc0200a4e:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a52:	60e2                	ld	ra,24(sp)
ffffffffc0200a54:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a56:	0791                	addi	a5,a5,4
ffffffffc0200a58:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a5c:	6442                	ld	s0,16(sp)
ffffffffc0200a5e:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a60:	5120506f          	j	ffffffffc0205f72 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a64:	00006517          	auipc	a0,0x6
ffffffffc0200a68:	31c50513          	addi	a0,a0,796 # ffffffffc0206d80 <commands+0x638>
}
ffffffffc0200a6c:	6442                	ld	s0,16(sp)
ffffffffc0200a6e:	60e2                	ld	ra,24(sp)
ffffffffc0200a70:	64a2                	ld	s1,8(sp)
ffffffffc0200a72:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a74:	e58ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a78:	00006517          	auipc	a0,0x6
ffffffffc0200a7c:	32850513          	addi	a0,a0,808 # ffffffffc0206da0 <commands+0x658>
ffffffffc0200a80:	b7f5                	j	ffffffffc0200a6c <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a82:	00006517          	auipc	a0,0x6
ffffffffc0200a86:	33e50513          	addi	a0,a0,830 # ffffffffc0206dc0 <commands+0x678>
ffffffffc0200a8a:	b7cd                	j	ffffffffc0200a6c <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a8c:	00006517          	auipc	a0,0x6
ffffffffc0200a90:	34c50513          	addi	a0,a0,844 # ffffffffc0206dd8 <commands+0x690>
ffffffffc0200a94:	e38ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a98:	8522                	mv	a0,s0
ffffffffc0200a9a:	ddbff0ef          	jal	ra,ffffffffc0200874 <pgfault_handler>
ffffffffc0200a9e:	84aa                	mv	s1,a0
ffffffffc0200aa0:	12051d63          	bnez	a0,ffffffffc0200bda <exception_handler+0x1be>
}
ffffffffc0200aa4:	60e2                	ld	ra,24(sp)
ffffffffc0200aa6:	6442                	ld	s0,16(sp)
ffffffffc0200aa8:	64a2                	ld	s1,8(sp)
ffffffffc0200aaa:	6105                	addi	sp,sp,32
ffffffffc0200aac:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200aae:	00006517          	auipc	a0,0x6
ffffffffc0200ab2:	34250513          	addi	a0,a0,834 # ffffffffc0206df0 <commands+0x6a8>
ffffffffc0200ab6:	e16ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200aba:	8522                	mv	a0,s0
ffffffffc0200abc:	db9ff0ef          	jal	ra,ffffffffc0200874 <pgfault_handler>
ffffffffc0200ac0:	84aa                	mv	s1,a0
ffffffffc0200ac2:	d16d                	beqz	a0,ffffffffc0200aa4 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200ac4:	8522                	mv	a0,s0
ffffffffc0200ac6:	d4dff0ef          	jal	ra,ffffffffc0200812 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200aca:	86a6                	mv	a3,s1
ffffffffc0200acc:	00006617          	auipc	a2,0x6
ffffffffc0200ad0:	24460613          	addi	a2,a2,580 # ffffffffc0206d10 <commands+0x5c8>
ffffffffc0200ad4:	0f900593          	li	a1,249
ffffffffc0200ad8:	00006517          	auipc	a0,0x6
ffffffffc0200adc:	09850513          	addi	a0,a0,152 # ffffffffc0206b70 <commands+0x428>
ffffffffc0200ae0:	f28ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200ae4:	00006517          	auipc	a0,0x6
ffffffffc0200ae8:	18c50513          	addi	a0,a0,396 # ffffffffc0206c70 <commands+0x528>
ffffffffc0200aec:	b741                	j	ffffffffc0200a6c <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200aee:	00006517          	auipc	a0,0x6
ffffffffc0200af2:	1a250513          	addi	a0,a0,418 # ffffffffc0206c90 <commands+0x548>
ffffffffc0200af6:	bf9d                	j	ffffffffc0200a6c <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200af8:	00006517          	auipc	a0,0x6
ffffffffc0200afc:	1b850513          	addi	a0,a0,440 # ffffffffc0206cb0 <commands+0x568>
ffffffffc0200b00:	b7b5                	j	ffffffffc0200a6c <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b02:	00006517          	auipc	a0,0x6
ffffffffc0200b06:	1c650513          	addi	a0,a0,454 # ffffffffc0206cc8 <commands+0x580>
ffffffffc0200b0a:	dc2ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b0e:	6458                	ld	a4,136(s0)
ffffffffc0200b10:	47a9                	li	a5,10
ffffffffc0200b12:	f8f719e3          	bne	a4,a5,ffffffffc0200aa4 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b16:	10843783          	ld	a5,264(s0)
ffffffffc0200b1a:	0791                	addi	a5,a5,4
ffffffffc0200b1c:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b20:	452050ef          	jal	ra,ffffffffc0205f72 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b24:	000b2797          	auipc	a5,0xb2
ffffffffc0200b28:	d1c7b783          	ld	a5,-740(a5) # ffffffffc02b2840 <current>
ffffffffc0200b2c:	6b9c                	ld	a5,16(a5)
ffffffffc0200b2e:	8522                	mv	a0,s0
}
ffffffffc0200b30:	6442                	ld	s0,16(sp)
ffffffffc0200b32:	60e2                	ld	ra,24(sp)
ffffffffc0200b34:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b36:	6589                	lui	a1,0x2
ffffffffc0200b38:	95be                	add	a1,a1,a5
}
ffffffffc0200b3a:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b3c:	ac19                	j	ffffffffc0200d52 <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b3e:	00006517          	auipc	a0,0x6
ffffffffc0200b42:	19a50513          	addi	a0,a0,410 # ffffffffc0206cd8 <commands+0x590>
ffffffffc0200b46:	b71d                	j	ffffffffc0200a6c <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b48:	00006517          	auipc	a0,0x6
ffffffffc0200b4c:	1b050513          	addi	a0,a0,432 # ffffffffc0206cf8 <commands+0x5b0>
ffffffffc0200b50:	d7cff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b54:	8522                	mv	a0,s0
ffffffffc0200b56:	d1fff0ef          	jal	ra,ffffffffc0200874 <pgfault_handler>
ffffffffc0200b5a:	84aa                	mv	s1,a0
ffffffffc0200b5c:	d521                	beqz	a0,ffffffffc0200aa4 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b5e:	8522                	mv	a0,s0
ffffffffc0200b60:	cb3ff0ef          	jal	ra,ffffffffc0200812 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b64:	86a6                	mv	a3,s1
ffffffffc0200b66:	00006617          	auipc	a2,0x6
ffffffffc0200b6a:	1aa60613          	addi	a2,a2,426 # ffffffffc0206d10 <commands+0x5c8>
ffffffffc0200b6e:	0ce00593          	li	a1,206
ffffffffc0200b72:	00006517          	auipc	a0,0x6
ffffffffc0200b76:	ffe50513          	addi	a0,a0,-2 # ffffffffc0206b70 <commands+0x428>
ffffffffc0200b7a:	e8eff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200b7e:	00006517          	auipc	a0,0x6
ffffffffc0200b82:	1ca50513          	addi	a0,a0,458 # ffffffffc0206d48 <commands+0x600>
ffffffffc0200b86:	d46ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b8a:	8522                	mv	a0,s0
ffffffffc0200b8c:	ce9ff0ef          	jal	ra,ffffffffc0200874 <pgfault_handler>
ffffffffc0200b90:	84aa                	mv	s1,a0
ffffffffc0200b92:	f00509e3          	beqz	a0,ffffffffc0200aa4 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b96:	8522                	mv	a0,s0
ffffffffc0200b98:	c7bff0ef          	jal	ra,ffffffffc0200812 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b9c:	86a6                	mv	a3,s1
ffffffffc0200b9e:	00006617          	auipc	a2,0x6
ffffffffc0200ba2:	17260613          	addi	a2,a2,370 # ffffffffc0206d10 <commands+0x5c8>
ffffffffc0200ba6:	0d800593          	li	a1,216
ffffffffc0200baa:	00006517          	auipc	a0,0x6
ffffffffc0200bae:	fc650513          	addi	a0,a0,-58 # ffffffffc0206b70 <commands+0x428>
ffffffffc0200bb2:	e56ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            print_trapframe(tf);
ffffffffc0200bb6:	8522                	mv	a0,s0
}
ffffffffc0200bb8:	6442                	ld	s0,16(sp)
ffffffffc0200bba:	60e2                	ld	ra,24(sp)
ffffffffc0200bbc:	64a2                	ld	s1,8(sp)
ffffffffc0200bbe:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200bc0:	b989                	j	ffffffffc0200812 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200bc2:	00006617          	auipc	a2,0x6
ffffffffc0200bc6:	16e60613          	addi	a2,a2,366 # ffffffffc0206d30 <commands+0x5e8>
ffffffffc0200bca:	0d200593          	li	a1,210
ffffffffc0200bce:	00006517          	auipc	a0,0x6
ffffffffc0200bd2:	fa250513          	addi	a0,a0,-94 # ffffffffc0206b70 <commands+0x428>
ffffffffc0200bd6:	e32ff0ef          	jal	ra,ffffffffc0200208 <__panic>
                print_trapframe(tf);
ffffffffc0200bda:	8522                	mv	a0,s0
ffffffffc0200bdc:	c37ff0ef          	jal	ra,ffffffffc0200812 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200be0:	86a6                	mv	a3,s1
ffffffffc0200be2:	00006617          	auipc	a2,0x6
ffffffffc0200be6:	12e60613          	addi	a2,a2,302 # ffffffffc0206d10 <commands+0x5c8>
ffffffffc0200bea:	0f200593          	li	a1,242
ffffffffc0200bee:	00006517          	auipc	a0,0x6
ffffffffc0200bf2:	f8250513          	addi	a0,a0,-126 # ffffffffc0206b70 <commands+0x428>
ffffffffc0200bf6:	e12ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200bfa <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200bfa:	1101                	addi	sp,sp,-32
ffffffffc0200bfc:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200bfe:	000b2417          	auipc	s0,0xb2
ffffffffc0200c02:	c4240413          	addi	s0,s0,-958 # ffffffffc02b2840 <current>
ffffffffc0200c06:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c08:	ec06                	sd	ra,24(sp)
ffffffffc0200c0a:	e426                	sd	s1,8(sp)
ffffffffc0200c0c:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c0e:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c12:	cf1d                	beqz	a4,ffffffffc0200c50 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c14:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c18:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c1c:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c1e:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c22:	0206c463          	bltz	a3,ffffffffc0200c4a <trap+0x50>
        exception_handler(tf);
ffffffffc0200c26:	df7ff0ef          	jal	ra,ffffffffc0200a1c <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c2a:	601c                	ld	a5,0(s0)
ffffffffc0200c2c:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c30:	e499                	bnez	s1,ffffffffc0200c3e <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c32:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c36:	8b05                	andi	a4,a4,1
ffffffffc0200c38:	e329                	bnez	a4,ffffffffc0200c7a <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c3a:	6f9c                	ld	a5,24(a5)
ffffffffc0200c3c:	eb85                	bnez	a5,ffffffffc0200c6c <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c3e:	60e2                	ld	ra,24(sp)
ffffffffc0200c40:	6442                	ld	s0,16(sp)
ffffffffc0200c42:	64a2                	ld	s1,8(sp)
ffffffffc0200c44:	6902                	ld	s2,0(sp)
ffffffffc0200c46:	6105                	addi	sp,sp,32
ffffffffc0200c48:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c4a:	d41ff0ef          	jal	ra,ffffffffc020098a <interrupt_handler>
ffffffffc0200c4e:	bff1                	j	ffffffffc0200c2a <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c50:	0006c863          	bltz	a3,ffffffffc0200c60 <trap+0x66>
}
ffffffffc0200c54:	6442                	ld	s0,16(sp)
ffffffffc0200c56:	60e2                	ld	ra,24(sp)
ffffffffc0200c58:	64a2                	ld	s1,8(sp)
ffffffffc0200c5a:	6902                	ld	s2,0(sp)
ffffffffc0200c5c:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c5e:	bb7d                	j	ffffffffc0200a1c <exception_handler>
}
ffffffffc0200c60:	6442                	ld	s0,16(sp)
ffffffffc0200c62:	60e2                	ld	ra,24(sp)
ffffffffc0200c64:	64a2                	ld	s1,8(sp)
ffffffffc0200c66:	6902                	ld	s2,0(sp)
ffffffffc0200c68:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c6a:	b305                	j	ffffffffc020098a <interrupt_handler>
}
ffffffffc0200c6c:	6442                	ld	s0,16(sp)
ffffffffc0200c6e:	60e2                	ld	ra,24(sp)
ffffffffc0200c70:	64a2                	ld	s1,8(sp)
ffffffffc0200c72:	6902                	ld	s2,0(sp)
ffffffffc0200c74:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c76:	2100506f          	j	ffffffffc0205e86 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200c7a:	555d                	li	a0,-9
ffffffffc0200c7c:	5be040ef          	jal	ra,ffffffffc020523a <do_exit>
            if (current->need_resched) {
ffffffffc0200c80:	601c                	ld	a5,0(s0)
ffffffffc0200c82:	bf65                	j	ffffffffc0200c3a <trap+0x40>

ffffffffc0200c84 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200c84:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200c88:	00011463          	bnez	sp,ffffffffc0200c90 <__alltraps+0xc>
ffffffffc0200c8c:	14002173          	csrr	sp,sscratch
ffffffffc0200c90:	712d                	addi	sp,sp,-288
ffffffffc0200c92:	e002                	sd	zero,0(sp)
ffffffffc0200c94:	e406                	sd	ra,8(sp)
ffffffffc0200c96:	ec0e                	sd	gp,24(sp)
ffffffffc0200c98:	f012                	sd	tp,32(sp)
ffffffffc0200c9a:	f416                	sd	t0,40(sp)
ffffffffc0200c9c:	f81a                	sd	t1,48(sp)
ffffffffc0200c9e:	fc1e                	sd	t2,56(sp)
ffffffffc0200ca0:	e0a2                	sd	s0,64(sp)
ffffffffc0200ca2:	e4a6                	sd	s1,72(sp)
ffffffffc0200ca4:	e8aa                	sd	a0,80(sp)
ffffffffc0200ca6:	ecae                	sd	a1,88(sp)
ffffffffc0200ca8:	f0b2                	sd	a2,96(sp)
ffffffffc0200caa:	f4b6                	sd	a3,104(sp)
ffffffffc0200cac:	f8ba                	sd	a4,112(sp)
ffffffffc0200cae:	fcbe                	sd	a5,120(sp)
ffffffffc0200cb0:	e142                	sd	a6,128(sp)
ffffffffc0200cb2:	e546                	sd	a7,136(sp)
ffffffffc0200cb4:	e94a                	sd	s2,144(sp)
ffffffffc0200cb6:	ed4e                	sd	s3,152(sp)
ffffffffc0200cb8:	f152                	sd	s4,160(sp)
ffffffffc0200cba:	f556                	sd	s5,168(sp)
ffffffffc0200cbc:	f95a                	sd	s6,176(sp)
ffffffffc0200cbe:	fd5e                	sd	s7,184(sp)
ffffffffc0200cc0:	e1e2                	sd	s8,192(sp)
ffffffffc0200cc2:	e5e6                	sd	s9,200(sp)
ffffffffc0200cc4:	e9ea                	sd	s10,208(sp)
ffffffffc0200cc6:	edee                	sd	s11,216(sp)
ffffffffc0200cc8:	f1f2                	sd	t3,224(sp)
ffffffffc0200cca:	f5f6                	sd	t4,232(sp)
ffffffffc0200ccc:	f9fa                	sd	t5,240(sp)
ffffffffc0200cce:	fdfe                	sd	t6,248(sp)
ffffffffc0200cd0:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cd4:	100024f3          	csrr	s1,sstatus
ffffffffc0200cd8:	14102973          	csrr	s2,sepc
ffffffffc0200cdc:	143029f3          	csrr	s3,stval
ffffffffc0200ce0:	14202a73          	csrr	s4,scause
ffffffffc0200ce4:	e822                	sd	s0,16(sp)
ffffffffc0200ce6:	e226                	sd	s1,256(sp)
ffffffffc0200ce8:	e64a                	sd	s2,264(sp)
ffffffffc0200cea:	ea4e                	sd	s3,272(sp)
ffffffffc0200cec:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200cee:	850a                	mv	a0,sp
    jal trap
ffffffffc0200cf0:	f0bff0ef          	jal	ra,ffffffffc0200bfa <trap>

ffffffffc0200cf4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200cf4:	6492                	ld	s1,256(sp)
ffffffffc0200cf6:	6932                	ld	s2,264(sp)
ffffffffc0200cf8:	1004f413          	andi	s0,s1,256
ffffffffc0200cfc:	e401                	bnez	s0,ffffffffc0200d04 <__trapret+0x10>
ffffffffc0200cfe:	1200                	addi	s0,sp,288
ffffffffc0200d00:	14041073          	csrw	sscratch,s0
ffffffffc0200d04:	10049073          	csrw	sstatus,s1
ffffffffc0200d08:	14191073          	csrw	sepc,s2
ffffffffc0200d0c:	60a2                	ld	ra,8(sp)
ffffffffc0200d0e:	61e2                	ld	gp,24(sp)
ffffffffc0200d10:	7202                	ld	tp,32(sp)
ffffffffc0200d12:	72a2                	ld	t0,40(sp)
ffffffffc0200d14:	7342                	ld	t1,48(sp)
ffffffffc0200d16:	73e2                	ld	t2,56(sp)
ffffffffc0200d18:	6406                	ld	s0,64(sp)
ffffffffc0200d1a:	64a6                	ld	s1,72(sp)
ffffffffc0200d1c:	6546                	ld	a0,80(sp)
ffffffffc0200d1e:	65e6                	ld	a1,88(sp)
ffffffffc0200d20:	7606                	ld	a2,96(sp)
ffffffffc0200d22:	76a6                	ld	a3,104(sp)
ffffffffc0200d24:	7746                	ld	a4,112(sp)
ffffffffc0200d26:	77e6                	ld	a5,120(sp)
ffffffffc0200d28:	680a                	ld	a6,128(sp)
ffffffffc0200d2a:	68aa                	ld	a7,136(sp)
ffffffffc0200d2c:	694a                	ld	s2,144(sp)
ffffffffc0200d2e:	69ea                	ld	s3,152(sp)
ffffffffc0200d30:	7a0a                	ld	s4,160(sp)
ffffffffc0200d32:	7aaa                	ld	s5,168(sp)
ffffffffc0200d34:	7b4a                	ld	s6,176(sp)
ffffffffc0200d36:	7bea                	ld	s7,184(sp)
ffffffffc0200d38:	6c0e                	ld	s8,192(sp)
ffffffffc0200d3a:	6cae                	ld	s9,200(sp)
ffffffffc0200d3c:	6d4e                	ld	s10,208(sp)
ffffffffc0200d3e:	6dee                	ld	s11,216(sp)
ffffffffc0200d40:	7e0e                	ld	t3,224(sp)
ffffffffc0200d42:	7eae                	ld	t4,232(sp)
ffffffffc0200d44:	7f4e                	ld	t5,240(sp)
ffffffffc0200d46:	7fee                	ld	t6,248(sp)
ffffffffc0200d48:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d4a:	10200073          	sret

ffffffffc0200d4e <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d4e:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d50:	b755                	j	ffffffffc0200cf4 <__trapret>

ffffffffc0200d52 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d52:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd0>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d56:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d5a:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d5e:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d62:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d66:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d6a:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d6e:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d72:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d76:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200d78:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200d7a:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200d7c:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200d7e:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200d80:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200d82:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200d84:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200d86:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200d88:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200d8a:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200d8c:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200d8e:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200d90:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200d92:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200d94:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200d96:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200d98:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200d9a:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200d9c:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200d9e:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200da0:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200da2:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200da4:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200da6:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200da8:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200daa:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200dac:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dae:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200db0:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200db2:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200db4:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200db6:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200db8:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200dba:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200dbc:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200dbe:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200dc0:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dc2:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200dc4:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200dc6:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200dc8:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200dca:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200dcc:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200dce:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200dd0:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200dd2:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200dd4:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200dd6:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200dd8:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200dda:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200ddc:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200dde:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200de0:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200de2:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200de4:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200de6:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200de8:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200dea:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200dec:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200dee:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200df0:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200df2:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200df4:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200df6:	812e                	mv	sp,a1
ffffffffc0200df8:	bdf5                	j	ffffffffc0200cf4 <__trapret>

ffffffffc0200dfa <shared_read_state>:
#include <sync.h>
#include <vmm.h>
#include <riscv.h>

bool shared_read_state(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end,bool share)
{
ffffffffc0200dfa:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0200dfc:	00d667b3          	or	a5,a2,a3
{
ffffffffc0200e00:	ec86                	sd	ra,88(sp)
ffffffffc0200e02:	e8a2                	sd	s0,80(sp)
ffffffffc0200e04:	e4a6                	sd	s1,72(sp)
ffffffffc0200e06:	e0ca                	sd	s2,64(sp)
ffffffffc0200e08:	fc4e                	sd	s3,56(sp)
ffffffffc0200e0a:	f852                	sd	s4,48(sp)
ffffffffc0200e0c:	f456                	sd	s5,40(sp)
ffffffffc0200e0e:	f05a                	sd	s6,32(sp)
ffffffffc0200e10:	ec5e                	sd	s7,24(sp)
ffffffffc0200e12:	e862                	sd	s8,16(sp)
ffffffffc0200e14:	e466                	sd	s9,8(sp)
ffffffffc0200e16:	e06a                	sd	s10,0(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0200e18:	17d2                	slli	a5,a5,0x34
ffffffffc0200e1a:	16079063          	bnez	a5,ffffffffc0200f7a <shared_read_state+0x180>
    assert(USER_ACCESS(start, end));
ffffffffc0200e1e:	002007b7          	lui	a5,0x200
ffffffffc0200e22:	8d32                	mv	s10,a2
ffffffffc0200e24:	12f66063          	bltu	a2,a5,ffffffffc0200f44 <shared_read_state+0x14a>
ffffffffc0200e28:	84b6                	mv	s1,a3
ffffffffc0200e2a:	10d67d63          	bgeu	a2,a3,ffffffffc0200f44 <shared_read_state+0x14a>
ffffffffc0200e2e:	4785                	li	a5,1
ffffffffc0200e30:	07fe                	slli	a5,a5,0x1f
ffffffffc0200e32:	10d7e963          	bltu	a5,a3,ffffffffc0200f44 <shared_read_state+0x14a>
ffffffffc0200e36:	8a2a                	mv	s4,a0
ffffffffc0200e38:	892e                	mv	s2,a1
            assert(page != NULL);
            assert(npage != NULL);
            ret = page_insert(to, npage, start, perm);
            assert(ret == 0);
        }
        start += PGSIZE;
ffffffffc0200e3a:	6985                	lui	s3,0x1
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200e3c:	000b2b97          	auipc	s7,0xb2
ffffffffc0200e40:	9e4b8b93          	addi	s7,s7,-1564 # ffffffffc02b2820 <npage>
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200e44:	000b2b17          	auipc	s6,0xb2
ffffffffc0200e48:	9e4b0b13          	addi	s6,s6,-1564 # ffffffffc02b2828 <pages>
ffffffffc0200e4c:	00008a97          	auipc	s5,0x8
ffffffffc0200e50:	c44a8a93          	addi	s5,s5,-956 # ffffffffc0208a90 <nbase>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0200e54:	00200cb7          	lui	s9,0x200
ffffffffc0200e58:	ffe00c37          	lui	s8,0xffe00
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0200e5c:	4601                	li	a2,0
ffffffffc0200e5e:	85ea                	mv	a1,s10
ffffffffc0200e60:	854a                	mv	a0,s2
ffffffffc0200e62:	083020ef          	jal	ra,ffffffffc02036e4 <get_pte>
ffffffffc0200e66:	842a                	mv	s0,a0
        if (ptep == NULL) 
ffffffffc0200e68:	c941                	beqz	a0,ffffffffc0200ef8 <shared_read_state+0xfe>
        if (*ptep & PTE_V)
ffffffffc0200e6a:	611c                	ld	a5,0(a0)
ffffffffc0200e6c:	8b85                	andi	a5,a5,1
ffffffffc0200e6e:	e39d                	bnez	a5,ffffffffc0200e94 <shared_read_state+0x9a>
        start += PGSIZE;
ffffffffc0200e70:	9d4e                	add	s10,s10,s3
    } 
    while (start != 0 && start < end);
ffffffffc0200e72:	fe9d65e3          	bltu	s10,s1,ffffffffc0200e5c <shared_read_state+0x62>
    return 0;
ffffffffc0200e76:	4501                	li	a0,0
}
ffffffffc0200e78:	60e6                	ld	ra,88(sp)
ffffffffc0200e7a:	6446                	ld	s0,80(sp)
ffffffffc0200e7c:	64a6                	ld	s1,72(sp)
ffffffffc0200e7e:	6906                	ld	s2,64(sp)
ffffffffc0200e80:	79e2                	ld	s3,56(sp)
ffffffffc0200e82:	7a42                	ld	s4,48(sp)
ffffffffc0200e84:	7aa2                	ld	s5,40(sp)
ffffffffc0200e86:	7b02                	ld	s6,32(sp)
ffffffffc0200e88:	6be2                	ld	s7,24(sp)
ffffffffc0200e8a:	6c42                	ld	s8,16(sp)
ffffffffc0200e8c:	6ca2                	ld	s9,8(sp)
ffffffffc0200e8e:	6d02                	ld	s10,0(sp)
ffffffffc0200e90:	6125                	addi	sp,sp,96
ffffffffc0200e92:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) return -E_NO_MEM;
ffffffffc0200e94:	4605                	li	a2,1
ffffffffc0200e96:	85ea                	mv	a1,s10
ffffffffc0200e98:	8552                	mv	a0,s4
ffffffffc0200e9a:	04b020ef          	jal	ra,ffffffffc02036e4 <get_pte>
ffffffffc0200e9e:	c52d                	beqz	a0,ffffffffc0200f08 <shared_read_state+0x10e>
            uint32_t perm = (*ptep & PTE_USER & (~PTE_W));
ffffffffc0200ea0:	6018                	ld	a4,0(s0)
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
    if (!(pte & PTE_V)) {
ffffffffc0200ea2:	00177793          	andi	a5,a4,1
ffffffffc0200ea6:	01b77693          	andi	a3,a4,27
ffffffffc0200eaa:	cfc5                	beqz	a5,ffffffffc0200f62 <shared_read_state+0x168>
    if (PPN(pa) >= npage) {
ffffffffc0200eac:	000bb603          	ld	a2,0(s7)
        panic("pte2page called with invalid pte");
    }
    return pa2page(PTE_ADDR(pte));
ffffffffc0200eb0:	00271793          	slli	a5,a4,0x2
ffffffffc0200eb4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200eb6:	06c7fb63          	bgeu	a5,a2,ffffffffc0200f2c <shared_read_state+0x132>
    return &pages[PPN(pa) - nbase];
ffffffffc0200eba:	000ab603          	ld	a2,0(s5)
ffffffffc0200ebe:	000b3583          	ld	a1,0(s6)
            (*ptep) = *ptep & (~PTE_W); // 页面设置为只读
ffffffffc0200ec2:	9b6d                	andi	a4,a4,-5
ffffffffc0200ec4:	8f91                	sub	a5,a5,a2
ffffffffc0200ec6:	079a                	slli	a5,a5,0x6
ffffffffc0200ec8:	95be                	add	a1,a1,a5
ffffffffc0200eca:	e018                	sd	a4,0(s0)
            assert(page != NULL);
ffffffffc0200ecc:	c1a1                	beqz	a1,ffffffffc0200f0c <shared_read_state+0x112>
            ret = page_insert(to, npage, start, perm);
ffffffffc0200ece:	866a                	mv	a2,s10
ffffffffc0200ed0:	8552                	mv	a0,s4
ffffffffc0200ed2:	6ad020ef          	jal	ra,ffffffffc0203d7e <page_insert>
            assert(ret == 0);
ffffffffc0200ed6:	dd49                	beqz	a0,ffffffffc0200e70 <shared_read_state+0x76>
ffffffffc0200ed8:	00006697          	auipc	a3,0x6
ffffffffc0200edc:	03068693          	addi	a3,a3,48 # ffffffffc0206f08 <commands+0x7c0>
ffffffffc0200ee0:	00006617          	auipc	a2,0x6
ffffffffc0200ee4:	c7860613          	addi	a2,a2,-904 # ffffffffc0206b58 <commands+0x410>
ffffffffc0200ee8:	02e00593          	li	a1,46
ffffffffc0200eec:	00006517          	auipc	a0,0x6
ffffffffc0200ef0:	f8c50513          	addi	a0,a0,-116 # ffffffffc0206e78 <commands+0x730>
ffffffffc0200ef4:	b14ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0200ef8:	9d66                	add	s10,s10,s9
ffffffffc0200efa:	018d7d33          	and	s10,s10,s8
    while (start != 0 && start < end);
ffffffffc0200efe:	f60d0ce3          	beqz	s10,ffffffffc0200e76 <shared_read_state+0x7c>
ffffffffc0200f02:	f49d6de3          	bltu	s10,s1,ffffffffc0200e5c <shared_read_state+0x62>
ffffffffc0200f06:	bf85                	j	ffffffffc0200e76 <shared_read_state+0x7c>
            if ((nptep = get_pte(to, start, 1)) == NULL) return -E_NO_MEM;
ffffffffc0200f08:	5571                	li	a0,-4
ffffffffc0200f0a:	b7bd                	j	ffffffffc0200e78 <shared_read_state+0x7e>
            assert(page != NULL);
ffffffffc0200f0c:	00006697          	auipc	a3,0x6
ffffffffc0200f10:	fec68693          	addi	a3,a3,-20 # ffffffffc0206ef8 <commands+0x7b0>
ffffffffc0200f14:	00006617          	auipc	a2,0x6
ffffffffc0200f18:	c4460613          	addi	a2,a2,-956 # ffffffffc0206b58 <commands+0x410>
ffffffffc0200f1c:	02b00593          	li	a1,43
ffffffffc0200f20:	00006517          	auipc	a0,0x6
ffffffffc0200f24:	f5850513          	addi	a0,a0,-168 # ffffffffc0206e78 <commands+0x730>
ffffffffc0200f28:	ae0ff0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200f2c:	00006617          	auipc	a2,0x6
ffffffffc0200f30:	fac60613          	addi	a2,a2,-84 # ffffffffc0206ed8 <commands+0x790>
ffffffffc0200f34:	06200593          	li	a1,98
ffffffffc0200f38:	00006517          	auipc	a0,0x6
ffffffffc0200f3c:	f9050513          	addi	a0,a0,-112 # ffffffffc0206ec8 <commands+0x780>
ffffffffc0200f40:	ac8ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0200f44:	00006697          	auipc	a3,0x6
ffffffffc0200f48:	f4468693          	addi	a3,a3,-188 # ffffffffc0206e88 <commands+0x740>
ffffffffc0200f4c:	00006617          	auipc	a2,0x6
ffffffffc0200f50:	c0c60613          	addi	a2,a2,-1012 # ffffffffc0206b58 <commands+0x410>
ffffffffc0200f54:	45cd                	li	a1,19
ffffffffc0200f56:	00006517          	auipc	a0,0x6
ffffffffc0200f5a:	f2250513          	addi	a0,a0,-222 # ffffffffc0206e78 <commands+0x730>
ffffffffc0200f5e:	aaaff0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0200f62:	00006617          	auipc	a2,0x6
ffffffffc0200f66:	f3e60613          	addi	a2,a2,-194 # ffffffffc0206ea0 <commands+0x758>
ffffffffc0200f6a:	07400593          	li	a1,116
ffffffffc0200f6e:	00006517          	auipc	a0,0x6
ffffffffc0200f72:	f5a50513          	addi	a0,a0,-166 # ffffffffc0206ec8 <commands+0x780>
ffffffffc0200f76:	a92ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0200f7a:	00006697          	auipc	a3,0x6
ffffffffc0200f7e:	ece68693          	addi	a3,a3,-306 # ffffffffc0206e48 <commands+0x700>
ffffffffc0200f82:	00006617          	auipc	a2,0x6
ffffffffc0200f86:	bd660613          	addi	a2,a2,-1066 # ffffffffc0206b58 <commands+0x410>
ffffffffc0200f8a:	45c9                	li	a1,18
ffffffffc0200f8c:	00006517          	auipc	a0,0x6
ffffffffc0200f90:	eec50513          	addi	a0,a0,-276 # ffffffffc0206e78 <commands+0x730>
ffffffffc0200f94:	a74ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200f98 <privated_write_state>:

int privated_write_state(struct mm_struct *mm, uint_t error_code, uintptr_t addr)
{
ffffffffc0200f98:	715d                	addi	sp,sp,-80
ffffffffc0200f9a:	f84a                	sd	s2,48(sp)
ffffffffc0200f9c:	892a                	mv	s2,a0
    pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0200f9e:	6d08                	ld	a0,24(a0)
{
ffffffffc0200fa0:	fc26                	sd	s1,56(sp)
ffffffffc0200fa2:	84b2                	mv	s1,a2
    pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0200fa4:	85a6                	mv	a1,s1
ffffffffc0200fa6:	4601                	li	a2,0
{
ffffffffc0200fa8:	e486                	sd	ra,72(sp)
ffffffffc0200faa:	e0a2                	sd	s0,64(sp)
ffffffffc0200fac:	f44e                	sd	s3,40(sp)
ffffffffc0200fae:	f052                	sd	s4,32(sp)
ffffffffc0200fb0:	ec56                	sd	s5,24(sp)
ffffffffc0200fb2:	e85a                	sd	s6,16(sp)
ffffffffc0200fb4:	e45e                	sd	s7,8(sp)
ffffffffc0200fb6:	e062                	sd	s8,0(sp)
    pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0200fb8:	72c020ef          	jal	ra,ffffffffc02036e4 <get_pte>
    uint32_t perm = (*ptep & PTE_USER | PTE_W);
ffffffffc0200fbc:	611c                	ld	a5,0(a0)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE);
ffffffffc0200fbe:	75fd                	lui	a1,0xfffff
ffffffffc0200fc0:	8ced                	and	s1,s1,a1
    if (!(pte & PTE_V)) {
ffffffffc0200fc2:	0017f713          	andi	a4,a5,1
ffffffffc0200fc6:	12070763          	beqz	a4,ffffffffc02010f4 <privated_write_state+0x15c>
    if (PPN(pa) >= npage) {
ffffffffc0200fca:	000b2b97          	auipc	s7,0xb2
ffffffffc0200fce:	856b8b93          	addi	s7,s7,-1962 # ffffffffc02b2820 <npage>
ffffffffc0200fd2:	000bb703          	ld	a4,0(s7)
ffffffffc0200fd6:	01b7f993          	andi	s3,a5,27
    return pa2page(PTE_ADDR(pte));
ffffffffc0200fda:	078a                	slli	a5,a5,0x2
ffffffffc0200fdc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200fde:	0ee7ff63          	bgeu	a5,a4,ffffffffc02010dc <privated_write_state+0x144>
    return &pages[PPN(pa) - nbase];
ffffffffc0200fe2:	000b2c17          	auipc	s8,0xb2
ffffffffc0200fe6:	846c0c13          	addi	s8,s8,-1978 # ffffffffc02b2828 <pages>
ffffffffc0200fea:	000c3403          	ld	s0,0(s8)
ffffffffc0200fee:	00008b17          	auipc	s6,0x8
ffffffffc0200ff2:	aa2b3b03          	ld	s6,-1374(s6) # ffffffffc0208a90 <nbase>
ffffffffc0200ff6:	416787b3          	sub	a5,a5,s6
ffffffffc0200ffa:	8a2a                	mv	s4,a0
ffffffffc0200ffc:	079a                	slli	a5,a5,0x6
    struct Page *page = pte2page(*ptep);
    struct Page *npage = alloc_page();  // 分配新页面
ffffffffc0200ffe:	4505                	li	a0,1
ffffffffc0201000:	943e                	add	s0,s0,a5
ffffffffc0201002:	5d6020ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
    (*ptep) = *ptep | (PTE_W);          // 页面设置为可写
ffffffffc0201006:	000a3703          	ld	a4,0(s4)
    struct Page *npage = alloc_page();  // 分配新页面
ffffffffc020100a:	8aaa                	mv	s5,a0
    (*ptep) = *ptep | (PTE_W);          // 页面设置为可写
ffffffffc020100c:	00476713          	ori	a4,a4,4
ffffffffc0201010:	00ea3023          	sd	a4,0(s4)
    assert(page != NULL);
ffffffffc0201014:	c445                	beqz	s0,ffffffffc02010bc <privated_write_state+0x124>
    assert(npage != NULL);
ffffffffc0201016:	c159                	beqz	a0,ffffffffc020109c <privated_write_state+0x104>
    return page - pages + nbase;
ffffffffc0201018:	000c3703          	ld	a4,0(s8)
    return KADDR(page2pa(page));
ffffffffc020101c:	567d                	li	a2,-1
ffffffffc020101e:	000bb803          	ld	a6,0(s7)
    return page - pages + nbase;
ffffffffc0201022:	40e406b3          	sub	a3,s0,a4
ffffffffc0201026:	8699                	srai	a3,a3,0x6
ffffffffc0201028:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc020102a:	8231                	srli	a2,a2,0xc
ffffffffc020102c:	00c6f7b3          	and	a5,a3,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201030:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201032:	0507f963          	bgeu	a5,a6,ffffffffc0201084 <privated_write_state+0xec>
    return page - pages + nbase;
ffffffffc0201036:	40e507b3          	sub	a5,a0,a4
ffffffffc020103a:	8799                	srai	a5,a5,0x6
ffffffffc020103c:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc020103e:	000b1517          	auipc	a0,0xb1
ffffffffc0201042:	7fa53503          	ld	a0,2042(a0) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0201046:	8e7d                	and	a2,a2,a5
ffffffffc0201048:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020104c:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020104e:	03067a63          	bgeu	a2,a6,ffffffffc0201082 <privated_write_state+0xea>
    int ret = 0;
    uintptr_t* src_kvaddr = page2kva(page);
    uintptr_t* dst_kvaddr = page2kva(npage);
    memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc0201052:	6605                	lui	a2,0x1
ffffffffc0201054:	953e                	add	a0,a0,a5
ffffffffc0201056:	02a050ef          	jal	ra,ffffffffc0206080 <memcpy>
    ret = page_insert(mm->pgdir, npage, start, perm);
ffffffffc020105a:	0049e993          	ori	s3,s3,4
    return ret;
ffffffffc020105e:	6406                	ld	s0,64(sp)
    ret = page_insert(mm->pgdir, npage, start, perm);
ffffffffc0201060:	01893503          	ld	a0,24(s2)
ffffffffc0201064:	60a6                	ld	ra,72(sp)
ffffffffc0201066:	7942                	ld	s2,48(sp)
ffffffffc0201068:	7a02                	ld	s4,32(sp)
ffffffffc020106a:	6b42                	ld	s6,16(sp)
ffffffffc020106c:	6ba2                	ld	s7,8(sp)
ffffffffc020106e:	6c02                	ld	s8,0(sp)
    ret = page_insert(mm->pgdir, npage, start, perm);
ffffffffc0201070:	86ce                	mv	a3,s3
ffffffffc0201072:	8626                	mv	a2,s1
ffffffffc0201074:	79a2                	ld	s3,40(sp)
ffffffffc0201076:	74e2                	ld	s1,56(sp)
    ret = page_insert(mm->pgdir, npage, start, perm);
ffffffffc0201078:	85d6                	mv	a1,s5
ffffffffc020107a:	6ae2                	ld	s5,24(sp)
ffffffffc020107c:	6161                	addi	sp,sp,80
    ret = page_insert(mm->pgdir, npage, start, perm);
ffffffffc020107e:	5010206f          	j	ffffffffc0203d7e <page_insert>
ffffffffc0201082:	86be                	mv	a3,a5
ffffffffc0201084:	00006617          	auipc	a2,0x6
ffffffffc0201088:	ea460613          	addi	a2,a2,-348 # ffffffffc0206f28 <commands+0x7e0>
ffffffffc020108c:	06900593          	li	a1,105
ffffffffc0201090:	00006517          	auipc	a0,0x6
ffffffffc0201094:	e3850513          	addi	a0,a0,-456 # ffffffffc0206ec8 <commands+0x780>
ffffffffc0201098:	970ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(npage != NULL);
ffffffffc020109c:	00006697          	auipc	a3,0x6
ffffffffc02010a0:	e7c68693          	addi	a3,a3,-388 # ffffffffc0206f18 <commands+0x7d0>
ffffffffc02010a4:	00006617          	auipc	a2,0x6
ffffffffc02010a8:	ab460613          	addi	a2,a2,-1356 # ffffffffc0206b58 <commands+0x410>
ffffffffc02010ac:	03f00593          	li	a1,63
ffffffffc02010b0:	00006517          	auipc	a0,0x6
ffffffffc02010b4:	dc850513          	addi	a0,a0,-568 # ffffffffc0206e78 <commands+0x730>
ffffffffc02010b8:	950ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page != NULL);
ffffffffc02010bc:	00006697          	auipc	a3,0x6
ffffffffc02010c0:	e3c68693          	addi	a3,a3,-452 # ffffffffc0206ef8 <commands+0x7b0>
ffffffffc02010c4:	00006617          	auipc	a2,0x6
ffffffffc02010c8:	a9460613          	addi	a2,a2,-1388 # ffffffffc0206b58 <commands+0x410>
ffffffffc02010cc:	03e00593          	li	a1,62
ffffffffc02010d0:	00006517          	auipc	a0,0x6
ffffffffc02010d4:	da850513          	addi	a0,a0,-600 # ffffffffc0206e78 <commands+0x730>
ffffffffc02010d8:	930ff0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02010dc:	00006617          	auipc	a2,0x6
ffffffffc02010e0:	dfc60613          	addi	a2,a2,-516 # ffffffffc0206ed8 <commands+0x790>
ffffffffc02010e4:	06200593          	li	a1,98
ffffffffc02010e8:	00006517          	auipc	a0,0x6
ffffffffc02010ec:	de050513          	addi	a0,a0,-544 # ffffffffc0206ec8 <commands+0x780>
ffffffffc02010f0:	918ff0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02010f4:	00006617          	auipc	a2,0x6
ffffffffc02010f8:	dac60613          	addi	a2,a2,-596 # ffffffffc0206ea0 <commands+0x758>
ffffffffc02010fc:	07400593          	li	a1,116
ffffffffc0201100:	00006517          	auipc	a0,0x6
ffffffffc0201104:	dc850513          	addi	a0,a0,-568 # ffffffffc0206ec8 <commands+0x780>
ffffffffc0201108:	900ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020110c <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020110c:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020110e:	00006697          	auipc	a3,0x6
ffffffffc0201112:	e4268693          	addi	a3,a3,-446 # ffffffffc0206f50 <commands+0x808>
ffffffffc0201116:	00006617          	auipc	a2,0x6
ffffffffc020111a:	a4260613          	addi	a2,a2,-1470 # ffffffffc0206b58 <commands+0x410>
ffffffffc020111e:	06e00593          	li	a1,110
ffffffffc0201122:	00006517          	auipc	a0,0x6
ffffffffc0201126:	e4e50513          	addi	a0,a0,-434 # ffffffffc0206f70 <commands+0x828>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020112a:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020112c:	8dcff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201130 <mm_create>:
mm_create(void) {
ffffffffc0201130:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201132:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0201136:	e022                	sd	s0,0(sp)
ffffffffc0201138:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020113a:	783000ef          	jal	ra,ffffffffc02020bc <kmalloc>
ffffffffc020113e:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0201140:	c505                	beqz	a0,ffffffffc0201168 <mm_create+0x38>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201142:	e408                	sd	a0,8(s0)
ffffffffc0201144:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0201146:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020114a:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020114e:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201152:	000b1797          	auipc	a5,0xb1
ffffffffc0201156:	6b67a783          	lw	a5,1718(a5) # ffffffffc02b2808 <swap_init_ok>
ffffffffc020115a:	ef81                	bnez	a5,ffffffffc0201172 <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc020115c:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0201160:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0201164:	02043c23          	sd	zero,56(s0)
}
ffffffffc0201168:	60a2                	ld	ra,8(sp)
ffffffffc020116a:	8522                	mv	a0,s0
ffffffffc020116c:	6402                	ld	s0,0(sp)
ffffffffc020116e:	0141                	addi	sp,sp,16
ffffffffc0201170:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201172:	055010ef          	jal	ra,ffffffffc02029c6 <swap_init_mm>
ffffffffc0201176:	b7ed                	j	ffffffffc0201160 <mm_create+0x30>

ffffffffc0201178 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0201178:	1101                	addi	sp,sp,-32
ffffffffc020117a:	e04a                	sd	s2,0(sp)
ffffffffc020117c:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020117e:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0201182:	e822                	sd	s0,16(sp)
ffffffffc0201184:	e426                	sd	s1,8(sp)
ffffffffc0201186:	ec06                	sd	ra,24(sp)
ffffffffc0201188:	84ae                	mv	s1,a1
ffffffffc020118a:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020118c:	731000ef          	jal	ra,ffffffffc02020bc <kmalloc>
    if (vma != NULL) {
ffffffffc0201190:	c509                	beqz	a0,ffffffffc020119a <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0201192:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201196:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201198:	cd00                	sw	s0,24(a0)
}
ffffffffc020119a:	60e2                	ld	ra,24(sp)
ffffffffc020119c:	6442                	ld	s0,16(sp)
ffffffffc020119e:	64a2                	ld	s1,8(sp)
ffffffffc02011a0:	6902                	ld	s2,0(sp)
ffffffffc02011a2:	6105                	addi	sp,sp,32
ffffffffc02011a4:	8082                	ret

ffffffffc02011a6 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc02011a6:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc02011a8:	c505                	beqz	a0,ffffffffc02011d0 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc02011aa:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02011ac:	c501                	beqz	a0,ffffffffc02011b4 <find_vma+0xe>
ffffffffc02011ae:	651c                	ld	a5,8(a0)
ffffffffc02011b0:	02f5f263          	bgeu	a1,a5,ffffffffc02011d4 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02011b4:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc02011b6:	00f68d63          	beq	a3,a5,ffffffffc02011d0 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02011ba:	fe87b703          	ld	a4,-24(a5)
ffffffffc02011be:	00e5e663          	bltu	a1,a4,ffffffffc02011ca <find_vma+0x24>
ffffffffc02011c2:	ff07b703          	ld	a4,-16(a5)
ffffffffc02011c6:	00e5ec63          	bltu	a1,a4,ffffffffc02011de <find_vma+0x38>
ffffffffc02011ca:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02011cc:	fef697e3          	bne	a3,a5,ffffffffc02011ba <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc02011d0:	4501                	li	a0,0
}
ffffffffc02011d2:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02011d4:	691c                	ld	a5,16(a0)
ffffffffc02011d6:	fcf5ffe3          	bgeu	a1,a5,ffffffffc02011b4 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc02011da:	ea88                	sd	a0,16(a3)
ffffffffc02011dc:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc02011de:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc02011e2:	ea88                	sd	a0,16(a3)
ffffffffc02011e4:	8082                	ret

ffffffffc02011e6 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02011e6:	6590                	ld	a2,8(a1)
ffffffffc02011e8:	0105b803          	ld	a6,16(a1) # fffffffffffff010 <end+0x3fd4c7b4>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02011ec:	1141                	addi	sp,sp,-16
ffffffffc02011ee:	e406                	sd	ra,8(sp)
ffffffffc02011f0:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02011f2:	01066763          	bltu	a2,a6,ffffffffc0201200 <insert_vma_struct+0x1a>
ffffffffc02011f6:	a085                	j	ffffffffc0201256 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02011f8:	fe87b703          	ld	a4,-24(a5)
ffffffffc02011fc:	04e66863          	bltu	a2,a4,ffffffffc020124c <insert_vma_struct+0x66>
ffffffffc0201200:	86be                	mv	a3,a5
ffffffffc0201202:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0201204:	fef51ae3          	bne	a0,a5,ffffffffc02011f8 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0201208:	02a68463          	beq	a3,a0,ffffffffc0201230 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020120c:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201210:	fe86b883          	ld	a7,-24(a3)
ffffffffc0201214:	08e8f163          	bgeu	a7,a4,ffffffffc0201296 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201218:	04e66f63          	bltu	a2,a4,ffffffffc0201276 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc020121c:	00f50a63          	beq	a0,a5,ffffffffc0201230 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0201220:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201224:	05076963          	bltu	a4,a6,ffffffffc0201276 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0201228:	ff07b603          	ld	a2,-16(a5)
ffffffffc020122c:	02c77363          	bgeu	a4,a2,ffffffffc0201252 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0201230:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0201232:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0201234:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201238:	e390                	sd	a2,0(a5)
ffffffffc020123a:	e690                	sd	a2,8(a3)
}
ffffffffc020123c:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020123e:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0201240:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0201242:	0017079b          	addiw	a5,a4,1
ffffffffc0201246:	d11c                	sw	a5,32(a0)
}
ffffffffc0201248:	0141                	addi	sp,sp,16
ffffffffc020124a:	8082                	ret
    if (le_prev != list) {
ffffffffc020124c:	fca690e3          	bne	a3,a0,ffffffffc020120c <insert_vma_struct+0x26>
ffffffffc0201250:	bfd1                	j	ffffffffc0201224 <insert_vma_struct+0x3e>
ffffffffc0201252:	ebbff0ef          	jal	ra,ffffffffc020110c <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201256:	00006697          	auipc	a3,0x6
ffffffffc020125a:	d2a68693          	addi	a3,a3,-726 # ffffffffc0206f80 <commands+0x838>
ffffffffc020125e:	00006617          	auipc	a2,0x6
ffffffffc0201262:	8fa60613          	addi	a2,a2,-1798 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201266:	07500593          	li	a1,117
ffffffffc020126a:	00006517          	auipc	a0,0x6
ffffffffc020126e:	d0650513          	addi	a0,a0,-762 # ffffffffc0206f70 <commands+0x828>
ffffffffc0201272:	f97fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201276:	00006697          	auipc	a3,0x6
ffffffffc020127a:	d4a68693          	addi	a3,a3,-694 # ffffffffc0206fc0 <commands+0x878>
ffffffffc020127e:	00006617          	auipc	a2,0x6
ffffffffc0201282:	8da60613          	addi	a2,a2,-1830 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201286:	06d00593          	li	a1,109
ffffffffc020128a:	00006517          	auipc	a0,0x6
ffffffffc020128e:	ce650513          	addi	a0,a0,-794 # ffffffffc0206f70 <commands+0x828>
ffffffffc0201292:	f77fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201296:	00006697          	auipc	a3,0x6
ffffffffc020129a:	d0a68693          	addi	a3,a3,-758 # ffffffffc0206fa0 <commands+0x858>
ffffffffc020129e:	00006617          	auipc	a2,0x6
ffffffffc02012a2:	8ba60613          	addi	a2,a2,-1862 # ffffffffc0206b58 <commands+0x410>
ffffffffc02012a6:	06c00593          	li	a1,108
ffffffffc02012aa:	00006517          	auipc	a0,0x6
ffffffffc02012ae:	cc650513          	addi	a0,a0,-826 # ffffffffc0206f70 <commands+0x828>
ffffffffc02012b2:	f57fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02012b6 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc02012b6:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc02012b8:	1141                	addi	sp,sp,-16
ffffffffc02012ba:	e406                	sd	ra,8(sp)
ffffffffc02012bc:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc02012be:	e78d                	bnez	a5,ffffffffc02012e8 <mm_destroy+0x32>
ffffffffc02012c0:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02012c2:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02012c4:	00a40c63          	beq	s0,a0,ffffffffc02012dc <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02012c8:	6118                	ld	a4,0(a0)
ffffffffc02012ca:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc02012cc:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02012ce:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02012d0:	e398                	sd	a4,0(a5)
ffffffffc02012d2:	69b000ef          	jal	ra,ffffffffc020216c <kfree>
    return listelm->next;
ffffffffc02012d6:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02012d8:	fea418e3          	bne	s0,a0,ffffffffc02012c8 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc02012dc:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02012de:	6402                	ld	s0,0(sp)
ffffffffc02012e0:	60a2                	ld	ra,8(sp)
ffffffffc02012e2:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc02012e4:	6890006f          	j	ffffffffc020216c <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02012e8:	00006697          	auipc	a3,0x6
ffffffffc02012ec:	cf868693          	addi	a3,a3,-776 # ffffffffc0206fe0 <commands+0x898>
ffffffffc02012f0:	00006617          	auipc	a2,0x6
ffffffffc02012f4:	86860613          	addi	a2,a2,-1944 # ffffffffc0206b58 <commands+0x410>
ffffffffc02012f8:	09500593          	li	a1,149
ffffffffc02012fc:	00006517          	auipc	a0,0x6
ffffffffc0201300:	c7450513          	addi	a0,a0,-908 # ffffffffc0206f70 <commands+0x828>
ffffffffc0201304:	f05fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201308 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc0201308:	7139                	addi	sp,sp,-64
ffffffffc020130a:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020130c:	6405                	lui	s0,0x1
ffffffffc020130e:	147d                	addi	s0,s0,-1
ffffffffc0201310:	77fd                	lui	a5,0xfffff
ffffffffc0201312:	9622                	add	a2,a2,s0
ffffffffc0201314:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc0201316:	f426                	sd	s1,40(sp)
ffffffffc0201318:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020131a:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc020131e:	f04a                	sd	s2,32(sp)
ffffffffc0201320:	ec4e                	sd	s3,24(sp)
ffffffffc0201322:	e852                	sd	s4,16(sp)
ffffffffc0201324:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc0201326:	002005b7          	lui	a1,0x200
ffffffffc020132a:	00f67433          	and	s0,a2,a5
ffffffffc020132e:	06b4e363          	bltu	s1,a1,ffffffffc0201394 <mm_map+0x8c>
ffffffffc0201332:	0684f163          	bgeu	s1,s0,ffffffffc0201394 <mm_map+0x8c>
ffffffffc0201336:	4785                	li	a5,1
ffffffffc0201338:	07fe                	slli	a5,a5,0x1f
ffffffffc020133a:	0487ed63          	bltu	a5,s0,ffffffffc0201394 <mm_map+0x8c>
ffffffffc020133e:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0201340:	cd21                	beqz	a0,ffffffffc0201398 <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0201342:	85a6                	mv	a1,s1
ffffffffc0201344:	8ab6                	mv	s5,a3
ffffffffc0201346:	8a3a                	mv	s4,a4
ffffffffc0201348:	e5fff0ef          	jal	ra,ffffffffc02011a6 <find_vma>
ffffffffc020134c:	c501                	beqz	a0,ffffffffc0201354 <mm_map+0x4c>
ffffffffc020134e:	651c                	ld	a5,8(a0)
ffffffffc0201350:	0487e263          	bltu	a5,s0,ffffffffc0201394 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201354:	03000513          	li	a0,48
ffffffffc0201358:	565000ef          	jal	ra,ffffffffc02020bc <kmalloc>
ffffffffc020135c:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc020135e:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0201360:	02090163          	beqz	s2,ffffffffc0201382 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0201364:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0201366:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc020136a:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc020136e:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0201372:	85ca                	mv	a1,s2
ffffffffc0201374:	e73ff0ef          	jal	ra,ffffffffc02011e6 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0201378:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc020137a:	000a0463          	beqz	s4,ffffffffc0201382 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc020137e:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0201382:	70e2                	ld	ra,56(sp)
ffffffffc0201384:	7442                	ld	s0,48(sp)
ffffffffc0201386:	74a2                	ld	s1,40(sp)
ffffffffc0201388:	7902                	ld	s2,32(sp)
ffffffffc020138a:	69e2                	ld	s3,24(sp)
ffffffffc020138c:	6a42                	ld	s4,16(sp)
ffffffffc020138e:	6aa2                	ld	s5,8(sp)
ffffffffc0201390:	6121                	addi	sp,sp,64
ffffffffc0201392:	8082                	ret
        return -E_INVAL;
ffffffffc0201394:	5575                	li	a0,-3
ffffffffc0201396:	b7f5                	j	ffffffffc0201382 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc0201398:	00006697          	auipc	a3,0x6
ffffffffc020139c:	c6068693          	addi	a3,a3,-928 # ffffffffc0206ff8 <commands+0x8b0>
ffffffffc02013a0:	00005617          	auipc	a2,0x5
ffffffffc02013a4:	7b860613          	addi	a2,a2,1976 # ffffffffc0206b58 <commands+0x410>
ffffffffc02013a8:	0a800593          	li	a1,168
ffffffffc02013ac:	00006517          	auipc	a0,0x6
ffffffffc02013b0:	bc450513          	addi	a0,a0,-1084 # ffffffffc0206f70 <commands+0x828>
ffffffffc02013b4:	e55fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02013b8 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc02013b8:	7139                	addi	sp,sp,-64
ffffffffc02013ba:	fc06                	sd	ra,56(sp)
ffffffffc02013bc:	f822                	sd	s0,48(sp)
ffffffffc02013be:	f426                	sd	s1,40(sp)
ffffffffc02013c0:	f04a                	sd	s2,32(sp)
ffffffffc02013c2:	ec4e                	sd	s3,24(sp)
ffffffffc02013c4:	e852                	sd	s4,16(sp)
ffffffffc02013c6:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc02013c8:	c52d                	beqz	a0,ffffffffc0201432 <dup_mmap+0x7a>
ffffffffc02013ca:	892a                	mv	s2,a0
ffffffffc02013cc:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02013ce:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02013d0:	e595                	bnez	a1,ffffffffc02013fc <dup_mmap+0x44>
ffffffffc02013d2:	a085                	j	ffffffffc0201432 <dup_mmap+0x7a>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02013d4:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc02013d6:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ee8>
        vma->vm_end = vm_end;
ffffffffc02013da:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc02013de:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc02013e2:	e05ff0ef          	jal	ra,ffffffffc02011e6 <insert_vma_struct>

        bool share = 0;
        /*if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
            return -E_NO_MEM;
        }*/
        if (shared_read_state(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc02013e6:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc02013ea:	fe843603          	ld	a2,-24(s0)
ffffffffc02013ee:	6c8c                	ld	a1,24(s1)
ffffffffc02013f0:	01893503          	ld	a0,24(s2)
ffffffffc02013f4:	4701                	li	a4,0
ffffffffc02013f6:	a05ff0ef          	jal	ra,ffffffffc0200dfa <shared_read_state>
ffffffffc02013fa:	e105                	bnez	a0,ffffffffc020141a <dup_mmap+0x62>
    return listelm->prev;
ffffffffc02013fc:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc02013fe:	02848863          	beq	s1,s0,ffffffffc020142e <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201402:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0201406:	fe843a83          	ld	s5,-24(s0)
ffffffffc020140a:	ff043a03          	ld	s4,-16(s0)
ffffffffc020140e:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201412:	4ab000ef          	jal	ra,ffffffffc02020bc <kmalloc>
ffffffffc0201416:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc0201418:	fd55                	bnez	a0,ffffffffc02013d4 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc020141a:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc020141c:	70e2                	ld	ra,56(sp)
ffffffffc020141e:	7442                	ld	s0,48(sp)
ffffffffc0201420:	74a2                	ld	s1,40(sp)
ffffffffc0201422:	7902                	ld	s2,32(sp)
ffffffffc0201424:	69e2                	ld	s3,24(sp)
ffffffffc0201426:	6a42                	ld	s4,16(sp)
ffffffffc0201428:	6aa2                	ld	s5,8(sp)
ffffffffc020142a:	6121                	addi	sp,sp,64
ffffffffc020142c:	8082                	ret
    return 0;
ffffffffc020142e:	4501                	li	a0,0
ffffffffc0201430:	b7f5                	j	ffffffffc020141c <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0201432:	00006697          	auipc	a3,0x6
ffffffffc0201436:	bd668693          	addi	a3,a3,-1066 # ffffffffc0207008 <commands+0x8c0>
ffffffffc020143a:	00005617          	auipc	a2,0x5
ffffffffc020143e:	71e60613          	addi	a2,a2,1822 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201442:	0c100593          	li	a1,193
ffffffffc0201446:	00006517          	auipc	a0,0x6
ffffffffc020144a:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0206f70 <commands+0x828>
ffffffffc020144e:	dbbfe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201452 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0201452:	1101                	addi	sp,sp,-32
ffffffffc0201454:	ec06                	sd	ra,24(sp)
ffffffffc0201456:	e822                	sd	s0,16(sp)
ffffffffc0201458:	e426                	sd	s1,8(sp)
ffffffffc020145a:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020145c:	c531                	beqz	a0,ffffffffc02014a8 <exit_mmap+0x56>
ffffffffc020145e:	591c                	lw	a5,48(a0)
ffffffffc0201460:	84aa                	mv	s1,a0
ffffffffc0201462:	e3b9                	bnez	a5,ffffffffc02014a8 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0201464:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0201466:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc020146a:	02850663          	beq	a0,s0,ffffffffc0201496 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020146e:	ff043603          	ld	a2,-16(s0)
ffffffffc0201472:	fe843583          	ld	a1,-24(s0)
ffffffffc0201476:	854a                	mv	a0,s2
ffffffffc0201478:	492020ef          	jal	ra,ffffffffc020390a <unmap_range>
ffffffffc020147c:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc020147e:	fe8498e3          	bne	s1,s0,ffffffffc020146e <exit_mmap+0x1c>
ffffffffc0201482:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc0201484:	00848c63          	beq	s1,s0,ffffffffc020149c <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0201488:	ff043603          	ld	a2,-16(s0)
ffffffffc020148c:	fe843583          	ld	a1,-24(s0)
ffffffffc0201490:	854a                	mv	a0,s2
ffffffffc0201492:	5be020ef          	jal	ra,ffffffffc0203a50 <exit_range>
ffffffffc0201496:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0201498:	fe8498e3          	bne	s1,s0,ffffffffc0201488 <exit_mmap+0x36>
    }
}
ffffffffc020149c:	60e2                	ld	ra,24(sp)
ffffffffc020149e:	6442                	ld	s0,16(sp)
ffffffffc02014a0:	64a2                	ld	s1,8(sp)
ffffffffc02014a2:	6902                	ld	s2,0(sp)
ffffffffc02014a4:	6105                	addi	sp,sp,32
ffffffffc02014a6:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02014a8:	00006697          	auipc	a3,0x6
ffffffffc02014ac:	b8068693          	addi	a3,a3,-1152 # ffffffffc0207028 <commands+0x8e0>
ffffffffc02014b0:	00005617          	auipc	a2,0x5
ffffffffc02014b4:	6a860613          	addi	a2,a2,1704 # ffffffffc0206b58 <commands+0x410>
ffffffffc02014b8:	0da00593          	li	a1,218
ffffffffc02014bc:	00006517          	auipc	a0,0x6
ffffffffc02014c0:	ab450513          	addi	a0,a0,-1356 # ffffffffc0206f70 <commands+0x828>
ffffffffc02014c4:	d45fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02014c8 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02014c8:	7139                	addi	sp,sp,-64
ffffffffc02014ca:	f822                	sd	s0,48(sp)
ffffffffc02014cc:	f426                	sd	s1,40(sp)
ffffffffc02014ce:	fc06                	sd	ra,56(sp)
ffffffffc02014d0:	f04a                	sd	s2,32(sp)
ffffffffc02014d2:	ec4e                	sd	s3,24(sp)
ffffffffc02014d4:	e852                	sd	s4,16(sp)
ffffffffc02014d6:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc02014d8:	c59ff0ef          	jal	ra,ffffffffc0201130 <mm_create>
    assert(mm != NULL);
ffffffffc02014dc:	84aa                	mv	s1,a0
ffffffffc02014de:	03200413          	li	s0,50
ffffffffc02014e2:	e919                	bnez	a0,ffffffffc02014f8 <vmm_init+0x30>
ffffffffc02014e4:	a991                	j	ffffffffc0201938 <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc02014e6:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02014e8:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02014ea:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc02014ee:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02014f0:	8526                	mv	a0,s1
ffffffffc02014f2:	cf5ff0ef          	jal	ra,ffffffffc02011e6 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02014f6:	c80d                	beqz	s0,ffffffffc0201528 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02014f8:	03000513          	li	a0,48
ffffffffc02014fc:	3c1000ef          	jal	ra,ffffffffc02020bc <kmalloc>
ffffffffc0201500:	85aa                	mv	a1,a0
ffffffffc0201502:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0201506:	f165                	bnez	a0,ffffffffc02014e6 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0201508:	00006697          	auipc	a3,0x6
ffffffffc020150c:	d5868693          	addi	a3,a3,-680 # ffffffffc0207260 <commands+0xb18>
ffffffffc0201510:	00005617          	auipc	a2,0x5
ffffffffc0201514:	64860613          	addi	a2,a2,1608 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201518:	11700593          	li	a1,279
ffffffffc020151c:	00006517          	auipc	a0,0x6
ffffffffc0201520:	a5450513          	addi	a0,a0,-1452 # ffffffffc0206f70 <commands+0x828>
ffffffffc0201524:	ce5fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201528:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020152c:	1f900913          	li	s2,505
ffffffffc0201530:	a819                	j	ffffffffc0201546 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0201532:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201534:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201536:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020153a:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020153c:	8526                	mv	a0,s1
ffffffffc020153e:	ca9ff0ef          	jal	ra,ffffffffc02011e6 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201542:	03240a63          	beq	s0,s2,ffffffffc0201576 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201546:	03000513          	li	a0,48
ffffffffc020154a:	373000ef          	jal	ra,ffffffffc02020bc <kmalloc>
ffffffffc020154e:	85aa                	mv	a1,a0
ffffffffc0201550:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0201554:	fd79                	bnez	a0,ffffffffc0201532 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0201556:	00006697          	auipc	a3,0x6
ffffffffc020155a:	d0a68693          	addi	a3,a3,-758 # ffffffffc0207260 <commands+0xb18>
ffffffffc020155e:	00005617          	auipc	a2,0x5
ffffffffc0201562:	5fa60613          	addi	a2,a2,1530 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201566:	11d00593          	li	a1,285
ffffffffc020156a:	00006517          	auipc	a0,0x6
ffffffffc020156e:	a0650513          	addi	a0,a0,-1530 # ffffffffc0206f70 <commands+0x828>
ffffffffc0201572:	c97fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0201576:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc0201578:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc020157a:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc020157e:	2cf48d63          	beq	s1,a5,ffffffffc0201858 <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201582:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd4c78c>
ffffffffc0201586:	ffe70613          	addi	a2,a4,-2
ffffffffc020158a:	24d61763          	bne	a2,a3,ffffffffc02017d8 <vmm_init+0x310>
ffffffffc020158e:	ff07b683          	ld	a3,-16(a5)
ffffffffc0201592:	24e69363          	bne	a3,a4,ffffffffc02017d8 <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc0201596:	0715                	addi	a4,a4,5
ffffffffc0201598:	679c                	ld	a5,8(a5)
ffffffffc020159a:	feb712e3          	bne	a4,a1,ffffffffc020157e <vmm_init+0xb6>
ffffffffc020159e:	4a1d                	li	s4,7
ffffffffc02015a0:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02015a2:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02015a6:	85a2                	mv	a1,s0
ffffffffc02015a8:	8526                	mv	a0,s1
ffffffffc02015aa:	bfdff0ef          	jal	ra,ffffffffc02011a6 <find_vma>
ffffffffc02015ae:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc02015b0:	30050463          	beqz	a0,ffffffffc02018b8 <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02015b4:	00140593          	addi	a1,s0,1
ffffffffc02015b8:	8526                	mv	a0,s1
ffffffffc02015ba:	bedff0ef          	jal	ra,ffffffffc02011a6 <find_vma>
ffffffffc02015be:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc02015c0:	2c050c63          	beqz	a0,ffffffffc0201898 <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02015c4:	85d2                	mv	a1,s4
ffffffffc02015c6:	8526                	mv	a0,s1
ffffffffc02015c8:	bdfff0ef          	jal	ra,ffffffffc02011a6 <find_vma>
        assert(vma3 == NULL);
ffffffffc02015cc:	2a051663          	bnez	a0,ffffffffc0201878 <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02015d0:	00340593          	addi	a1,s0,3
ffffffffc02015d4:	8526                	mv	a0,s1
ffffffffc02015d6:	bd1ff0ef          	jal	ra,ffffffffc02011a6 <find_vma>
        assert(vma4 == NULL);
ffffffffc02015da:	30051f63          	bnez	a0,ffffffffc02018f8 <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02015de:	00440593          	addi	a1,s0,4
ffffffffc02015e2:	8526                	mv	a0,s1
ffffffffc02015e4:	bc3ff0ef          	jal	ra,ffffffffc02011a6 <find_vma>
        assert(vma5 == NULL);
ffffffffc02015e8:	2e051863          	bnez	a0,ffffffffc02018d8 <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02015ec:	00893783          	ld	a5,8(s2)
ffffffffc02015f0:	20879463          	bne	a5,s0,ffffffffc02017f8 <vmm_init+0x330>
ffffffffc02015f4:	01093783          	ld	a5,16(s2)
ffffffffc02015f8:	20fa1063          	bne	s4,a5,ffffffffc02017f8 <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02015fc:	0089b783          	ld	a5,8(s3) # 1008 <_binary_obj___user_faultread_out_size-0x8ba8>
ffffffffc0201600:	20879c63          	bne	a5,s0,ffffffffc0201818 <vmm_init+0x350>
ffffffffc0201604:	0109b783          	ld	a5,16(s3)
ffffffffc0201608:	20fa1863          	bne	s4,a5,ffffffffc0201818 <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020160c:	0415                	addi	s0,s0,5
ffffffffc020160e:	0a15                	addi	s4,s4,5
ffffffffc0201610:	f9541be3          	bne	s0,s5,ffffffffc02015a6 <vmm_init+0xde>
ffffffffc0201614:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0201616:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0201618:	85a2                	mv	a1,s0
ffffffffc020161a:	8526                	mv	a0,s1
ffffffffc020161c:	b8bff0ef          	jal	ra,ffffffffc02011a6 <find_vma>
ffffffffc0201620:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0201624:	c90d                	beqz	a0,ffffffffc0201656 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0201626:	6914                	ld	a3,16(a0)
ffffffffc0201628:	6510                	ld	a2,8(a0)
ffffffffc020162a:	00006517          	auipc	a0,0x6
ffffffffc020162e:	b1e50513          	addi	a0,a0,-1250 # ffffffffc0207148 <commands+0xa00>
ffffffffc0201632:	a9bfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0201636:	00006697          	auipc	a3,0x6
ffffffffc020163a:	b3a68693          	addi	a3,a3,-1222 # ffffffffc0207170 <commands+0xa28>
ffffffffc020163e:	00005617          	auipc	a2,0x5
ffffffffc0201642:	51a60613          	addi	a2,a2,1306 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201646:	13f00593          	li	a1,319
ffffffffc020164a:	00006517          	auipc	a0,0x6
ffffffffc020164e:	92650513          	addi	a0,a0,-1754 # ffffffffc0206f70 <commands+0x828>
ffffffffc0201652:	bb7fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0201656:	147d                	addi	s0,s0,-1
ffffffffc0201658:	fd2410e3          	bne	s0,s2,ffffffffc0201618 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc020165c:	8526                	mv	a0,s1
ffffffffc020165e:	c59ff0ef          	jal	ra,ffffffffc02012b6 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0201662:	00006517          	auipc	a0,0x6
ffffffffc0201666:	b2650513          	addi	a0,a0,-1242 # ffffffffc0207188 <commands+0xa40>
ffffffffc020166a:	a63fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020166e:	03c020ef          	jal	ra,ffffffffc02036aa <nr_free_pages>
ffffffffc0201672:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc0201674:	abdff0ef          	jal	ra,ffffffffc0201130 <mm_create>
ffffffffc0201678:	000b1797          	auipc	a5,0xb1
ffffffffc020167c:	16a7b423          	sd	a0,360(a5) # ffffffffc02b27e0 <check_mm_struct>
ffffffffc0201680:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc0201682:	28050b63          	beqz	a0,ffffffffc0201918 <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201686:	000b1497          	auipc	s1,0xb1
ffffffffc020168a:	1924b483          	ld	s1,402(s1) # ffffffffc02b2818 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc020168e:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201690:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0201692:	2e079f63          	bnez	a5,ffffffffc0201990 <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201696:	03000513          	li	a0,48
ffffffffc020169a:	223000ef          	jal	ra,ffffffffc02020bc <kmalloc>
ffffffffc020169e:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc02016a0:	18050c63          	beqz	a0,ffffffffc0201838 <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc02016a4:	002007b7          	lui	a5,0x200
ffffffffc02016a8:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc02016ac:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02016ae:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02016b0:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc02016b4:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02016b6:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc02016ba:	b2dff0ef          	jal	ra,ffffffffc02011e6 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02016be:	10000593          	li	a1,256
ffffffffc02016c2:	8522                	mv	a0,s0
ffffffffc02016c4:	ae3ff0ef          	jal	ra,ffffffffc02011a6 <find_vma>
ffffffffc02016c8:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc02016cc:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02016d0:	2ea99063          	bne	s3,a0,ffffffffc02019b0 <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc02016d4:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f4ee0>
    for (i = 0; i < 100; i ++) {
ffffffffc02016d8:	0785                	addi	a5,a5,1
ffffffffc02016da:	fee79de3          	bne	a5,a4,ffffffffc02016d4 <vmm_init+0x20c>
        sum += i;
ffffffffc02016de:	6705                	lui	a4,0x1
ffffffffc02016e0:	10000793          	li	a5,256
ffffffffc02016e4:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x885a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02016e8:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02016ec:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc02016f0:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc02016f2:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02016f4:	fec79ce3          	bne	a5,a2,ffffffffc02016ec <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc02016f8:	2e071863          	bnez	a4,ffffffffc02019e8 <vmm_init+0x520>
}

static inline struct Page *
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc02016fc:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02016fe:	000b1a97          	auipc	s5,0xb1
ffffffffc0201702:	122a8a93          	addi	s5,s5,290 # ffffffffc02b2820 <npage>
ffffffffc0201706:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020170a:	078a                	slli	a5,a5,0x2
ffffffffc020170c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020170e:	2cc7f163          	bgeu	a5,a2,ffffffffc02019d0 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0201712:	00007a17          	auipc	s4,0x7
ffffffffc0201716:	37ea3a03          	ld	s4,894(s4) # ffffffffc0208a90 <nbase>
ffffffffc020171a:	414787b3          	sub	a5,a5,s4
ffffffffc020171e:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc0201720:	8799                	srai	a5,a5,0x6
ffffffffc0201722:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0201724:	00c79713          	slli	a4,a5,0xc
ffffffffc0201728:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020172a:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020172e:	24c77563          	bgeu	a4,a2,ffffffffc0201978 <vmm_init+0x4b0>
ffffffffc0201732:	000b1997          	auipc	s3,0xb1
ffffffffc0201736:	1069b983          	ld	s3,262(s3) # ffffffffc02b2838 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc020173a:	4581                	li	a1,0
ffffffffc020173c:	8526                	mv	a0,s1
ffffffffc020173e:	99b6                	add	s3,s3,a3
ffffffffc0201740:	5a2020ef          	jal	ra,ffffffffc0203ce2 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201744:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0201748:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020174c:	078a                	slli	a5,a5,0x2
ffffffffc020174e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201750:	28e7f063          	bgeu	a5,a4,ffffffffc02019d0 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0201754:	000b1997          	auipc	s3,0xb1
ffffffffc0201758:	0d498993          	addi	s3,s3,212 # ffffffffc02b2828 <pages>
ffffffffc020175c:	0009b503          	ld	a0,0(s3)
ffffffffc0201760:	414787b3          	sub	a5,a5,s4
ffffffffc0201764:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0201766:	953e                	add	a0,a0,a5
ffffffffc0201768:	4585                	li	a1,1
ffffffffc020176a:	701010ef          	jal	ra,ffffffffc020366a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020176e:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0201770:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201774:	078a                	slli	a5,a5,0x2
ffffffffc0201776:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201778:	24e7fc63          	bgeu	a5,a4,ffffffffc02019d0 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc020177c:	0009b503          	ld	a0,0(s3)
ffffffffc0201780:	414787b3          	sub	a5,a5,s4
ffffffffc0201784:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201786:	4585                	li	a1,1
ffffffffc0201788:	953e                	add	a0,a0,a5
ffffffffc020178a:	6e1010ef          	jal	ra,ffffffffc020366a <free_pages>
    pgdir[0] = 0;
ffffffffc020178e:	0004b023          	sd	zero,0(s1)
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() {
  asm volatile("sfence.vma");
ffffffffc0201792:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc0201796:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0201798:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc020179c:	b1bff0ef          	jal	ra,ffffffffc02012b6 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc02017a0:	000b1797          	auipc	a5,0xb1
ffffffffc02017a4:	0407b023          	sd	zero,64(a5) # ffffffffc02b27e0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02017a8:	703010ef          	jal	ra,ffffffffc02036aa <nr_free_pages>
ffffffffc02017ac:	1aa91663          	bne	s2,a0,ffffffffc0201958 <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02017b0:	00006517          	auipc	a0,0x6
ffffffffc02017b4:	a7850513          	addi	a0,a0,-1416 # ffffffffc0207228 <commands+0xae0>
ffffffffc02017b8:	915fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02017bc:	7442                	ld	s0,48(sp)
ffffffffc02017be:	70e2                	ld	ra,56(sp)
ffffffffc02017c0:	74a2                	ld	s1,40(sp)
ffffffffc02017c2:	7902                	ld	s2,32(sp)
ffffffffc02017c4:	69e2                	ld	s3,24(sp)
ffffffffc02017c6:	6a42                	ld	s4,16(sp)
ffffffffc02017c8:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02017ca:	00006517          	auipc	a0,0x6
ffffffffc02017ce:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0207248 <commands+0xb00>
}
ffffffffc02017d2:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02017d4:	8f9fe06f          	j	ffffffffc02000cc <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02017d8:	00006697          	auipc	a3,0x6
ffffffffc02017dc:	88868693          	addi	a3,a3,-1912 # ffffffffc0207060 <commands+0x918>
ffffffffc02017e0:	00005617          	auipc	a2,0x5
ffffffffc02017e4:	37860613          	addi	a2,a2,888 # ffffffffc0206b58 <commands+0x410>
ffffffffc02017e8:	12600593          	li	a1,294
ffffffffc02017ec:	00005517          	auipc	a0,0x5
ffffffffc02017f0:	78450513          	addi	a0,a0,1924 # ffffffffc0206f70 <commands+0x828>
ffffffffc02017f4:	a15fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02017f8:	00006697          	auipc	a3,0x6
ffffffffc02017fc:	8f068693          	addi	a3,a3,-1808 # ffffffffc02070e8 <commands+0x9a0>
ffffffffc0201800:	00005617          	auipc	a2,0x5
ffffffffc0201804:	35860613          	addi	a2,a2,856 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201808:	13600593          	li	a1,310
ffffffffc020180c:	00005517          	auipc	a0,0x5
ffffffffc0201810:	76450513          	addi	a0,a0,1892 # ffffffffc0206f70 <commands+0x828>
ffffffffc0201814:	9f5fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201818:	00006697          	auipc	a3,0x6
ffffffffc020181c:	90068693          	addi	a3,a3,-1792 # ffffffffc0207118 <commands+0x9d0>
ffffffffc0201820:	00005617          	auipc	a2,0x5
ffffffffc0201824:	33860613          	addi	a2,a2,824 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201828:	13700593          	li	a1,311
ffffffffc020182c:	00005517          	auipc	a0,0x5
ffffffffc0201830:	74450513          	addi	a0,a0,1860 # ffffffffc0206f70 <commands+0x828>
ffffffffc0201834:	9d5fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(vma != NULL);
ffffffffc0201838:	00006697          	auipc	a3,0x6
ffffffffc020183c:	a2868693          	addi	a3,a3,-1496 # ffffffffc0207260 <commands+0xb18>
ffffffffc0201840:	00005617          	auipc	a2,0x5
ffffffffc0201844:	31860613          	addi	a2,a2,792 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201848:	15600593          	li	a1,342
ffffffffc020184c:	00005517          	auipc	a0,0x5
ffffffffc0201850:	72450513          	addi	a0,a0,1828 # ffffffffc0206f70 <commands+0x828>
ffffffffc0201854:	9b5fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201858:	00005697          	auipc	a3,0x5
ffffffffc020185c:	7f068693          	addi	a3,a3,2032 # ffffffffc0207048 <commands+0x900>
ffffffffc0201860:	00005617          	auipc	a2,0x5
ffffffffc0201864:	2f860613          	addi	a2,a2,760 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201868:	12400593          	li	a1,292
ffffffffc020186c:	00005517          	auipc	a0,0x5
ffffffffc0201870:	70450513          	addi	a0,a0,1796 # ffffffffc0206f70 <commands+0x828>
ffffffffc0201874:	995fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma3 == NULL);
ffffffffc0201878:	00006697          	auipc	a3,0x6
ffffffffc020187c:	84068693          	addi	a3,a3,-1984 # ffffffffc02070b8 <commands+0x970>
ffffffffc0201880:	00005617          	auipc	a2,0x5
ffffffffc0201884:	2d860613          	addi	a2,a2,728 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201888:	13000593          	li	a1,304
ffffffffc020188c:	00005517          	auipc	a0,0x5
ffffffffc0201890:	6e450513          	addi	a0,a0,1764 # ffffffffc0206f70 <commands+0x828>
ffffffffc0201894:	975fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2 != NULL);
ffffffffc0201898:	00006697          	auipc	a3,0x6
ffffffffc020189c:	81068693          	addi	a3,a3,-2032 # ffffffffc02070a8 <commands+0x960>
ffffffffc02018a0:	00005617          	auipc	a2,0x5
ffffffffc02018a4:	2b860613          	addi	a2,a2,696 # ffffffffc0206b58 <commands+0x410>
ffffffffc02018a8:	12e00593          	li	a1,302
ffffffffc02018ac:	00005517          	auipc	a0,0x5
ffffffffc02018b0:	6c450513          	addi	a0,a0,1732 # ffffffffc0206f70 <commands+0x828>
ffffffffc02018b4:	955fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1 != NULL);
ffffffffc02018b8:	00005697          	auipc	a3,0x5
ffffffffc02018bc:	7e068693          	addi	a3,a3,2016 # ffffffffc0207098 <commands+0x950>
ffffffffc02018c0:	00005617          	auipc	a2,0x5
ffffffffc02018c4:	29860613          	addi	a2,a2,664 # ffffffffc0206b58 <commands+0x410>
ffffffffc02018c8:	12c00593          	li	a1,300
ffffffffc02018cc:	00005517          	auipc	a0,0x5
ffffffffc02018d0:	6a450513          	addi	a0,a0,1700 # ffffffffc0206f70 <commands+0x828>
ffffffffc02018d4:	935fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma5 == NULL);
ffffffffc02018d8:	00006697          	auipc	a3,0x6
ffffffffc02018dc:	80068693          	addi	a3,a3,-2048 # ffffffffc02070d8 <commands+0x990>
ffffffffc02018e0:	00005617          	auipc	a2,0x5
ffffffffc02018e4:	27860613          	addi	a2,a2,632 # ffffffffc0206b58 <commands+0x410>
ffffffffc02018e8:	13400593          	li	a1,308
ffffffffc02018ec:	00005517          	auipc	a0,0x5
ffffffffc02018f0:	68450513          	addi	a0,a0,1668 # ffffffffc0206f70 <commands+0x828>
ffffffffc02018f4:	915fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma4 == NULL);
ffffffffc02018f8:	00005697          	auipc	a3,0x5
ffffffffc02018fc:	7d068693          	addi	a3,a3,2000 # ffffffffc02070c8 <commands+0x980>
ffffffffc0201900:	00005617          	auipc	a2,0x5
ffffffffc0201904:	25860613          	addi	a2,a2,600 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201908:	13200593          	li	a1,306
ffffffffc020190c:	00005517          	auipc	a0,0x5
ffffffffc0201910:	66450513          	addi	a0,a0,1636 # ffffffffc0206f70 <commands+0x828>
ffffffffc0201914:	8f5fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0201918:	00006697          	auipc	a3,0x6
ffffffffc020191c:	89068693          	addi	a3,a3,-1904 # ffffffffc02071a8 <commands+0xa60>
ffffffffc0201920:	00005617          	auipc	a2,0x5
ffffffffc0201924:	23860613          	addi	a2,a2,568 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201928:	14f00593          	li	a1,335
ffffffffc020192c:	00005517          	auipc	a0,0x5
ffffffffc0201930:	64450513          	addi	a0,a0,1604 # ffffffffc0206f70 <commands+0x828>
ffffffffc0201934:	8d5fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(mm != NULL);
ffffffffc0201938:	00005697          	auipc	a3,0x5
ffffffffc020193c:	6c068693          	addi	a3,a3,1728 # ffffffffc0206ff8 <commands+0x8b0>
ffffffffc0201940:	00005617          	auipc	a2,0x5
ffffffffc0201944:	21860613          	addi	a2,a2,536 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201948:	11000593          	li	a1,272
ffffffffc020194c:	00005517          	auipc	a0,0x5
ffffffffc0201950:	62450513          	addi	a0,a0,1572 # ffffffffc0206f70 <commands+0x828>
ffffffffc0201954:	8b5fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201958:	00006697          	auipc	a3,0x6
ffffffffc020195c:	8a868693          	addi	a3,a3,-1880 # ffffffffc0207200 <commands+0xab8>
ffffffffc0201960:	00005617          	auipc	a2,0x5
ffffffffc0201964:	1f860613          	addi	a2,a2,504 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201968:	17400593          	li	a1,372
ffffffffc020196c:	00005517          	auipc	a0,0x5
ffffffffc0201970:	60450513          	addi	a0,a0,1540 # ffffffffc0206f70 <commands+0x828>
ffffffffc0201974:	895fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201978:	00005617          	auipc	a2,0x5
ffffffffc020197c:	5b060613          	addi	a2,a2,1456 # ffffffffc0206f28 <commands+0x7e0>
ffffffffc0201980:	06900593          	li	a1,105
ffffffffc0201984:	00005517          	auipc	a0,0x5
ffffffffc0201988:	54450513          	addi	a0,a0,1348 # ffffffffc0206ec8 <commands+0x780>
ffffffffc020198c:	87dfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0201990:	00006697          	auipc	a3,0x6
ffffffffc0201994:	83068693          	addi	a3,a3,-2000 # ffffffffc02071c0 <commands+0xa78>
ffffffffc0201998:	00005617          	auipc	a2,0x5
ffffffffc020199c:	1c060613          	addi	a2,a2,448 # ffffffffc0206b58 <commands+0x410>
ffffffffc02019a0:	15300593          	li	a1,339
ffffffffc02019a4:	00005517          	auipc	a0,0x5
ffffffffc02019a8:	5cc50513          	addi	a0,a0,1484 # ffffffffc0206f70 <commands+0x828>
ffffffffc02019ac:	85dfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02019b0:	00006697          	auipc	a3,0x6
ffffffffc02019b4:	82068693          	addi	a3,a3,-2016 # ffffffffc02071d0 <commands+0xa88>
ffffffffc02019b8:	00005617          	auipc	a2,0x5
ffffffffc02019bc:	1a060613          	addi	a2,a2,416 # ffffffffc0206b58 <commands+0x410>
ffffffffc02019c0:	15b00593          	li	a1,347
ffffffffc02019c4:	00005517          	auipc	a0,0x5
ffffffffc02019c8:	5ac50513          	addi	a0,a0,1452 # ffffffffc0206f70 <commands+0x828>
ffffffffc02019cc:	83dfe0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02019d0:	00005617          	auipc	a2,0x5
ffffffffc02019d4:	50860613          	addi	a2,a2,1288 # ffffffffc0206ed8 <commands+0x790>
ffffffffc02019d8:	06200593          	li	a1,98
ffffffffc02019dc:	00005517          	auipc	a0,0x5
ffffffffc02019e0:	4ec50513          	addi	a0,a0,1260 # ffffffffc0206ec8 <commands+0x780>
ffffffffc02019e4:	825fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(sum == 0);
ffffffffc02019e8:	00006697          	auipc	a3,0x6
ffffffffc02019ec:	80868693          	addi	a3,a3,-2040 # ffffffffc02071f0 <commands+0xaa8>
ffffffffc02019f0:	00005617          	auipc	a2,0x5
ffffffffc02019f4:	16860613          	addi	a2,a2,360 # ffffffffc0206b58 <commands+0x410>
ffffffffc02019f8:	16700593          	li	a1,359
ffffffffc02019fc:	00005517          	auipc	a0,0x5
ffffffffc0201a00:	57450513          	addi	a0,a0,1396 # ffffffffc0206f70 <commands+0x828>
ffffffffc0201a04:	805fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201a08 <user_mem_check>:
failed:
    return ret;
}

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0201a08:	7179                	addi	sp,sp,-48
ffffffffc0201a0a:	f022                	sd	s0,32(sp)
ffffffffc0201a0c:	f406                	sd	ra,40(sp)
ffffffffc0201a0e:	ec26                	sd	s1,24(sp)
ffffffffc0201a10:	e84a                	sd	s2,16(sp)
ffffffffc0201a12:	e44e                	sd	s3,8(sp)
ffffffffc0201a14:	e052                	sd	s4,0(sp)
ffffffffc0201a16:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0201a18:	c135                	beqz	a0,ffffffffc0201a7c <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0201a1a:	002007b7          	lui	a5,0x200
ffffffffc0201a1e:	04f5e663          	bltu	a1,a5,ffffffffc0201a6a <user_mem_check+0x62>
ffffffffc0201a22:	00c584b3          	add	s1,a1,a2
ffffffffc0201a26:	0495f263          	bgeu	a1,s1,ffffffffc0201a6a <user_mem_check+0x62>
ffffffffc0201a2a:	4785                	li	a5,1
ffffffffc0201a2c:	07fe                	slli	a5,a5,0x1f
ffffffffc0201a2e:	0297ee63          	bltu	a5,s1,ffffffffc0201a6a <user_mem_check+0x62>
ffffffffc0201a32:	892a                	mv	s2,a0
ffffffffc0201a34:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0201a36:	6a05                	lui	s4,0x1
ffffffffc0201a38:	a821                	j	ffffffffc0201a50 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201a3a:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0201a3e:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0201a40:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201a42:	c685                	beqz	a3,ffffffffc0201a6a <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0201a44:	c399                	beqz	a5,ffffffffc0201a4a <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0201a46:	02e46263          	bltu	s0,a4,ffffffffc0201a6a <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0201a4a:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0201a4c:	04947663          	bgeu	s0,s1,ffffffffc0201a98 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0201a50:	85a2                	mv	a1,s0
ffffffffc0201a52:	854a                	mv	a0,s2
ffffffffc0201a54:	f52ff0ef          	jal	ra,ffffffffc02011a6 <find_vma>
ffffffffc0201a58:	c909                	beqz	a0,ffffffffc0201a6a <user_mem_check+0x62>
ffffffffc0201a5a:	6518                	ld	a4,8(a0)
ffffffffc0201a5c:	00e46763          	bltu	s0,a4,ffffffffc0201a6a <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201a60:	4d1c                	lw	a5,24(a0)
ffffffffc0201a62:	fc099ce3          	bnez	s3,ffffffffc0201a3a <user_mem_check+0x32>
ffffffffc0201a66:	8b85                	andi	a5,a5,1
ffffffffc0201a68:	f3ed                	bnez	a5,ffffffffc0201a4a <user_mem_check+0x42>
            return 0;
ffffffffc0201a6a:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0201a6c:	70a2                	ld	ra,40(sp)
ffffffffc0201a6e:	7402                	ld	s0,32(sp)
ffffffffc0201a70:	64e2                	ld	s1,24(sp)
ffffffffc0201a72:	6942                	ld	s2,16(sp)
ffffffffc0201a74:	69a2                	ld	s3,8(sp)
ffffffffc0201a76:	6a02                	ld	s4,0(sp)
ffffffffc0201a78:	6145                	addi	sp,sp,48
ffffffffc0201a7a:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0201a7c:	c02007b7          	lui	a5,0xc0200
ffffffffc0201a80:	4501                	li	a0,0
ffffffffc0201a82:	fef5e5e3          	bltu	a1,a5,ffffffffc0201a6c <user_mem_check+0x64>
ffffffffc0201a86:	962e                	add	a2,a2,a1
ffffffffc0201a88:	fec5f2e3          	bgeu	a1,a2,ffffffffc0201a6c <user_mem_check+0x64>
ffffffffc0201a8c:	c8000537          	lui	a0,0xc8000
ffffffffc0201a90:	0505                	addi	a0,a0,1
ffffffffc0201a92:	00a63533          	sltu	a0,a2,a0
ffffffffc0201a96:	bfd9                	j	ffffffffc0201a6c <user_mem_check+0x64>
        return 1;
ffffffffc0201a98:	4505                	li	a0,1
ffffffffc0201a9a:	bfc9                	j	ffffffffc0201a6c <user_mem_check+0x64>

ffffffffc0201a9c <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0201a9c:	000ad797          	auipc	a5,0xad
ffffffffc0201aa0:	c6478793          	addi	a5,a5,-924 # ffffffffc02ae700 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0201aa4:	f51c                	sd	a5,40(a0)
ffffffffc0201aa6:	e79c                	sd	a5,8(a5)
ffffffffc0201aa8:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0201aaa:	4501                	li	a0,0
ffffffffc0201aac:	8082                	ret

ffffffffc0201aae <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0201aae:	4501                	li	a0,0
ffffffffc0201ab0:	8082                	ret

ffffffffc0201ab2 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0201ab2:	4501                	li	a0,0
ffffffffc0201ab4:	8082                	ret

ffffffffc0201ab6 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0201ab6:	4501                	li	a0,0
ffffffffc0201ab8:	8082                	ret

ffffffffc0201aba <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0201aba:	711d                	addi	sp,sp,-96
ffffffffc0201abc:	fc4e                	sd	s3,56(sp)
ffffffffc0201abe:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201ac0:	00005517          	auipc	a0,0x5
ffffffffc0201ac4:	7b050513          	addi	a0,a0,1968 # ffffffffc0207270 <commands+0xb28>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201ac8:	698d                	lui	s3,0x3
ffffffffc0201aca:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0201acc:	e0ca                	sd	s2,64(sp)
ffffffffc0201ace:	ec86                	sd	ra,88(sp)
ffffffffc0201ad0:	e8a2                	sd	s0,80(sp)
ffffffffc0201ad2:	e4a6                	sd	s1,72(sp)
ffffffffc0201ad4:	f456                	sd	s5,40(sp)
ffffffffc0201ad6:	f05a                	sd	s6,32(sp)
ffffffffc0201ad8:	ec5e                	sd	s7,24(sp)
ffffffffc0201ada:	e862                	sd	s8,16(sp)
ffffffffc0201adc:	e466                	sd	s9,8(sp)
ffffffffc0201ade:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201ae0:	decfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201ae4:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb0>
    assert(pgfault_num==4);
ffffffffc0201ae8:	000b1917          	auipc	s2,0xb1
ffffffffc0201aec:	d0092903          	lw	s2,-768(s2) # ffffffffc02b27e8 <pgfault_num>
ffffffffc0201af0:	4791                	li	a5,4
ffffffffc0201af2:	14f91e63          	bne	s2,a5,ffffffffc0201c4e <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201af6:	00005517          	auipc	a0,0x5
ffffffffc0201afa:	7ca50513          	addi	a0,a0,1994 # ffffffffc02072c0 <commands+0xb78>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201afe:	6a85                	lui	s5,0x1
ffffffffc0201b00:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201b02:	dcafe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0201b06:	000b1417          	auipc	s0,0xb1
ffffffffc0201b0a:	ce240413          	addi	s0,s0,-798 # ffffffffc02b27e8 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201b0e:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
    assert(pgfault_num==4);
ffffffffc0201b12:	4004                	lw	s1,0(s0)
ffffffffc0201b14:	2481                	sext.w	s1,s1
ffffffffc0201b16:	2b249c63          	bne	s1,s2,ffffffffc0201dce <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201b1a:	00005517          	auipc	a0,0x5
ffffffffc0201b1e:	7ce50513          	addi	a0,a0,1998 # ffffffffc02072e8 <commands+0xba0>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201b22:	6b91                	lui	s7,0x4
ffffffffc0201b24:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201b26:	da6fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201b2a:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5bb0>
    assert(pgfault_num==4);
ffffffffc0201b2e:	00042903          	lw	s2,0(s0)
ffffffffc0201b32:	2901                	sext.w	s2,s2
ffffffffc0201b34:	26991d63          	bne	s2,s1,ffffffffc0201dae <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201b38:	00005517          	auipc	a0,0x5
ffffffffc0201b3c:	7d850513          	addi	a0,a0,2008 # ffffffffc0207310 <commands+0xbc8>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201b40:	6c89                	lui	s9,0x2
ffffffffc0201b42:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201b44:	d88fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201b48:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7bb0>
    assert(pgfault_num==4);
ffffffffc0201b4c:	401c                	lw	a5,0(s0)
ffffffffc0201b4e:	2781                	sext.w	a5,a5
ffffffffc0201b50:	23279f63          	bne	a5,s2,ffffffffc0201d8e <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201b54:	00005517          	auipc	a0,0x5
ffffffffc0201b58:	7e450513          	addi	a0,a0,2020 # ffffffffc0207338 <commands+0xbf0>
ffffffffc0201b5c:	d70fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201b60:	6795                	lui	a5,0x5
ffffffffc0201b62:	4739                	li	a4,14
ffffffffc0201b64:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb0>
    assert(pgfault_num==5);
ffffffffc0201b68:	4004                	lw	s1,0(s0)
ffffffffc0201b6a:	4795                	li	a5,5
ffffffffc0201b6c:	2481                	sext.w	s1,s1
ffffffffc0201b6e:	20f49063          	bne	s1,a5,ffffffffc0201d6e <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201b72:	00005517          	auipc	a0,0x5
ffffffffc0201b76:	79e50513          	addi	a0,a0,1950 # ffffffffc0207310 <commands+0xbc8>
ffffffffc0201b7a:	d52fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201b7e:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0201b82:	401c                	lw	a5,0(s0)
ffffffffc0201b84:	2781                	sext.w	a5,a5
ffffffffc0201b86:	1c979463          	bne	a5,s1,ffffffffc0201d4e <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201b8a:	00005517          	auipc	a0,0x5
ffffffffc0201b8e:	73650513          	addi	a0,a0,1846 # ffffffffc02072c0 <commands+0xb78>
ffffffffc0201b92:	d3afe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201b96:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0201b9a:	401c                	lw	a5,0(s0)
ffffffffc0201b9c:	4719                	li	a4,6
ffffffffc0201b9e:	2781                	sext.w	a5,a5
ffffffffc0201ba0:	18e79763          	bne	a5,a4,ffffffffc0201d2e <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201ba4:	00005517          	auipc	a0,0x5
ffffffffc0201ba8:	76c50513          	addi	a0,a0,1900 # ffffffffc0207310 <commands+0xbc8>
ffffffffc0201bac:	d20fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201bb0:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0201bb4:	401c                	lw	a5,0(s0)
ffffffffc0201bb6:	471d                	li	a4,7
ffffffffc0201bb8:	2781                	sext.w	a5,a5
ffffffffc0201bba:	14e79a63          	bne	a5,a4,ffffffffc0201d0e <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201bbe:	00005517          	auipc	a0,0x5
ffffffffc0201bc2:	6b250513          	addi	a0,a0,1714 # ffffffffc0207270 <commands+0xb28>
ffffffffc0201bc6:	d06fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201bca:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0201bce:	401c                	lw	a5,0(s0)
ffffffffc0201bd0:	4721                	li	a4,8
ffffffffc0201bd2:	2781                	sext.w	a5,a5
ffffffffc0201bd4:	10e79d63          	bne	a5,a4,ffffffffc0201cee <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201bd8:	00005517          	auipc	a0,0x5
ffffffffc0201bdc:	71050513          	addi	a0,a0,1808 # ffffffffc02072e8 <commands+0xba0>
ffffffffc0201be0:	cecfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201be4:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0201be8:	401c                	lw	a5,0(s0)
ffffffffc0201bea:	4725                	li	a4,9
ffffffffc0201bec:	2781                	sext.w	a5,a5
ffffffffc0201bee:	0ee79063          	bne	a5,a4,ffffffffc0201cce <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201bf2:	00005517          	auipc	a0,0x5
ffffffffc0201bf6:	74650513          	addi	a0,a0,1862 # ffffffffc0207338 <commands+0xbf0>
ffffffffc0201bfa:	cd2fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201bfe:	6795                	lui	a5,0x5
ffffffffc0201c00:	4739                	li	a4,14
ffffffffc0201c02:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb0>
    assert(pgfault_num==10);
ffffffffc0201c06:	4004                	lw	s1,0(s0)
ffffffffc0201c08:	47a9                	li	a5,10
ffffffffc0201c0a:	2481                	sext.w	s1,s1
ffffffffc0201c0c:	0af49163          	bne	s1,a5,ffffffffc0201cae <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201c10:	00005517          	auipc	a0,0x5
ffffffffc0201c14:	6b050513          	addi	a0,a0,1712 # ffffffffc02072c0 <commands+0xb78>
ffffffffc0201c18:	cb4fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201c1c:	6785                	lui	a5,0x1
ffffffffc0201c1e:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0201c22:	06979663          	bne	a5,s1,ffffffffc0201c8e <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0201c26:	401c                	lw	a5,0(s0)
ffffffffc0201c28:	472d                	li	a4,11
ffffffffc0201c2a:	2781                	sext.w	a5,a5
ffffffffc0201c2c:	04e79163          	bne	a5,a4,ffffffffc0201c6e <_fifo_check_swap+0x1b4>
}
ffffffffc0201c30:	60e6                	ld	ra,88(sp)
ffffffffc0201c32:	6446                	ld	s0,80(sp)
ffffffffc0201c34:	64a6                	ld	s1,72(sp)
ffffffffc0201c36:	6906                	ld	s2,64(sp)
ffffffffc0201c38:	79e2                	ld	s3,56(sp)
ffffffffc0201c3a:	7a42                	ld	s4,48(sp)
ffffffffc0201c3c:	7aa2                	ld	s5,40(sp)
ffffffffc0201c3e:	7b02                	ld	s6,32(sp)
ffffffffc0201c40:	6be2                	ld	s7,24(sp)
ffffffffc0201c42:	6c42                	ld	s8,16(sp)
ffffffffc0201c44:	6ca2                	ld	s9,8(sp)
ffffffffc0201c46:	6d02                	ld	s10,0(sp)
ffffffffc0201c48:	4501                	li	a0,0
ffffffffc0201c4a:	6125                	addi	sp,sp,96
ffffffffc0201c4c:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0201c4e:	00005697          	auipc	a3,0x5
ffffffffc0201c52:	64a68693          	addi	a3,a3,1610 # ffffffffc0207298 <commands+0xb50>
ffffffffc0201c56:	00005617          	auipc	a2,0x5
ffffffffc0201c5a:	f0260613          	addi	a2,a2,-254 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201c5e:	05100593          	li	a1,81
ffffffffc0201c62:	00005517          	auipc	a0,0x5
ffffffffc0201c66:	64650513          	addi	a0,a0,1606 # ffffffffc02072a8 <commands+0xb60>
ffffffffc0201c6a:	d9efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==11);
ffffffffc0201c6e:	00005697          	auipc	a3,0x5
ffffffffc0201c72:	77a68693          	addi	a3,a3,1914 # ffffffffc02073e8 <commands+0xca0>
ffffffffc0201c76:	00005617          	auipc	a2,0x5
ffffffffc0201c7a:	ee260613          	addi	a2,a2,-286 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201c7e:	07300593          	li	a1,115
ffffffffc0201c82:	00005517          	auipc	a0,0x5
ffffffffc0201c86:	62650513          	addi	a0,a0,1574 # ffffffffc02072a8 <commands+0xb60>
ffffffffc0201c8a:	d7efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201c8e:	00005697          	auipc	a3,0x5
ffffffffc0201c92:	73268693          	addi	a3,a3,1842 # ffffffffc02073c0 <commands+0xc78>
ffffffffc0201c96:	00005617          	auipc	a2,0x5
ffffffffc0201c9a:	ec260613          	addi	a2,a2,-318 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201c9e:	07100593          	li	a1,113
ffffffffc0201ca2:	00005517          	auipc	a0,0x5
ffffffffc0201ca6:	60650513          	addi	a0,a0,1542 # ffffffffc02072a8 <commands+0xb60>
ffffffffc0201caa:	d5efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==10);
ffffffffc0201cae:	00005697          	auipc	a3,0x5
ffffffffc0201cb2:	70268693          	addi	a3,a3,1794 # ffffffffc02073b0 <commands+0xc68>
ffffffffc0201cb6:	00005617          	auipc	a2,0x5
ffffffffc0201cba:	ea260613          	addi	a2,a2,-350 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201cbe:	06f00593          	li	a1,111
ffffffffc0201cc2:	00005517          	auipc	a0,0x5
ffffffffc0201cc6:	5e650513          	addi	a0,a0,1510 # ffffffffc02072a8 <commands+0xb60>
ffffffffc0201cca:	d3efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==9);
ffffffffc0201cce:	00005697          	auipc	a3,0x5
ffffffffc0201cd2:	6d268693          	addi	a3,a3,1746 # ffffffffc02073a0 <commands+0xc58>
ffffffffc0201cd6:	00005617          	auipc	a2,0x5
ffffffffc0201cda:	e8260613          	addi	a2,a2,-382 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201cde:	06c00593          	li	a1,108
ffffffffc0201ce2:	00005517          	auipc	a0,0x5
ffffffffc0201ce6:	5c650513          	addi	a0,a0,1478 # ffffffffc02072a8 <commands+0xb60>
ffffffffc0201cea:	d1efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==8);
ffffffffc0201cee:	00005697          	auipc	a3,0x5
ffffffffc0201cf2:	6a268693          	addi	a3,a3,1698 # ffffffffc0207390 <commands+0xc48>
ffffffffc0201cf6:	00005617          	auipc	a2,0x5
ffffffffc0201cfa:	e6260613          	addi	a2,a2,-414 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201cfe:	06900593          	li	a1,105
ffffffffc0201d02:	00005517          	auipc	a0,0x5
ffffffffc0201d06:	5a650513          	addi	a0,a0,1446 # ffffffffc02072a8 <commands+0xb60>
ffffffffc0201d0a:	cfefe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==7);
ffffffffc0201d0e:	00005697          	auipc	a3,0x5
ffffffffc0201d12:	67268693          	addi	a3,a3,1650 # ffffffffc0207380 <commands+0xc38>
ffffffffc0201d16:	00005617          	auipc	a2,0x5
ffffffffc0201d1a:	e4260613          	addi	a2,a2,-446 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201d1e:	06600593          	li	a1,102
ffffffffc0201d22:	00005517          	auipc	a0,0x5
ffffffffc0201d26:	58650513          	addi	a0,a0,1414 # ffffffffc02072a8 <commands+0xb60>
ffffffffc0201d2a:	cdefe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==6);
ffffffffc0201d2e:	00005697          	auipc	a3,0x5
ffffffffc0201d32:	64268693          	addi	a3,a3,1602 # ffffffffc0207370 <commands+0xc28>
ffffffffc0201d36:	00005617          	auipc	a2,0x5
ffffffffc0201d3a:	e2260613          	addi	a2,a2,-478 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201d3e:	06300593          	li	a1,99
ffffffffc0201d42:	00005517          	auipc	a0,0x5
ffffffffc0201d46:	56650513          	addi	a0,a0,1382 # ffffffffc02072a8 <commands+0xb60>
ffffffffc0201d4a:	cbefe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc0201d4e:	00005697          	auipc	a3,0x5
ffffffffc0201d52:	61268693          	addi	a3,a3,1554 # ffffffffc0207360 <commands+0xc18>
ffffffffc0201d56:	00005617          	auipc	a2,0x5
ffffffffc0201d5a:	e0260613          	addi	a2,a2,-510 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201d5e:	06000593          	li	a1,96
ffffffffc0201d62:	00005517          	auipc	a0,0x5
ffffffffc0201d66:	54650513          	addi	a0,a0,1350 # ffffffffc02072a8 <commands+0xb60>
ffffffffc0201d6a:	c9efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc0201d6e:	00005697          	auipc	a3,0x5
ffffffffc0201d72:	5f268693          	addi	a3,a3,1522 # ffffffffc0207360 <commands+0xc18>
ffffffffc0201d76:	00005617          	auipc	a2,0x5
ffffffffc0201d7a:	de260613          	addi	a2,a2,-542 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201d7e:	05d00593          	li	a1,93
ffffffffc0201d82:	00005517          	auipc	a0,0x5
ffffffffc0201d86:	52650513          	addi	a0,a0,1318 # ffffffffc02072a8 <commands+0xb60>
ffffffffc0201d8a:	c7efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0201d8e:	00005697          	auipc	a3,0x5
ffffffffc0201d92:	50a68693          	addi	a3,a3,1290 # ffffffffc0207298 <commands+0xb50>
ffffffffc0201d96:	00005617          	auipc	a2,0x5
ffffffffc0201d9a:	dc260613          	addi	a2,a2,-574 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201d9e:	05a00593          	li	a1,90
ffffffffc0201da2:	00005517          	auipc	a0,0x5
ffffffffc0201da6:	50650513          	addi	a0,a0,1286 # ffffffffc02072a8 <commands+0xb60>
ffffffffc0201daa:	c5efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0201dae:	00005697          	auipc	a3,0x5
ffffffffc0201db2:	4ea68693          	addi	a3,a3,1258 # ffffffffc0207298 <commands+0xb50>
ffffffffc0201db6:	00005617          	auipc	a2,0x5
ffffffffc0201dba:	da260613          	addi	a2,a2,-606 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201dbe:	05700593          	li	a1,87
ffffffffc0201dc2:	00005517          	auipc	a0,0x5
ffffffffc0201dc6:	4e650513          	addi	a0,a0,1254 # ffffffffc02072a8 <commands+0xb60>
ffffffffc0201dca:	c3efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0201dce:	00005697          	auipc	a3,0x5
ffffffffc0201dd2:	4ca68693          	addi	a3,a3,1226 # ffffffffc0207298 <commands+0xb50>
ffffffffc0201dd6:	00005617          	auipc	a2,0x5
ffffffffc0201dda:	d8260613          	addi	a2,a2,-638 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201dde:	05400593          	li	a1,84
ffffffffc0201de2:	00005517          	auipc	a0,0x5
ffffffffc0201de6:	4c650513          	addi	a0,a0,1222 # ffffffffc02072a8 <commands+0xb60>
ffffffffc0201dea:	c1efe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201dee <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201dee:	751c                	ld	a5,40(a0)
{
ffffffffc0201df0:	1141                	addi	sp,sp,-16
ffffffffc0201df2:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0201df4:	cf91                	beqz	a5,ffffffffc0201e10 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0201df6:	ee0d                	bnez	a2,ffffffffc0201e30 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0201df8:	679c                	ld	a5,8(a5)
}
ffffffffc0201dfa:	60a2                	ld	ra,8(sp)
ffffffffc0201dfc:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0201dfe:	6394                	ld	a3,0(a5)
ffffffffc0201e00:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0201e02:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0201e06:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0201e08:	e314                	sd	a3,0(a4)
ffffffffc0201e0a:	e19c                	sd	a5,0(a1)
}
ffffffffc0201e0c:	0141                	addi	sp,sp,16
ffffffffc0201e0e:	8082                	ret
         assert(head != NULL);
ffffffffc0201e10:	00005697          	auipc	a3,0x5
ffffffffc0201e14:	5e868693          	addi	a3,a3,1512 # ffffffffc02073f8 <commands+0xcb0>
ffffffffc0201e18:	00005617          	auipc	a2,0x5
ffffffffc0201e1c:	d4060613          	addi	a2,a2,-704 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201e20:	04100593          	li	a1,65
ffffffffc0201e24:	00005517          	auipc	a0,0x5
ffffffffc0201e28:	48450513          	addi	a0,a0,1156 # ffffffffc02072a8 <commands+0xb60>
ffffffffc0201e2c:	bdcfe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(in_tick==0);
ffffffffc0201e30:	00005697          	auipc	a3,0x5
ffffffffc0201e34:	5d868693          	addi	a3,a3,1496 # ffffffffc0207408 <commands+0xcc0>
ffffffffc0201e38:	00005617          	auipc	a2,0x5
ffffffffc0201e3c:	d2060613          	addi	a2,a2,-736 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201e40:	04200593          	li	a1,66
ffffffffc0201e44:	00005517          	auipc	a0,0x5
ffffffffc0201e48:	46450513          	addi	a0,a0,1124 # ffffffffc02072a8 <commands+0xb60>
ffffffffc0201e4c:	bbcfe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201e50 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201e50:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0201e52:	cb91                	beqz	a5,ffffffffc0201e66 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201e54:	6394                	ld	a3,0(a5)
ffffffffc0201e56:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc0201e5a:	e398                	sd	a4,0(a5)
ffffffffc0201e5c:	e698                	sd	a4,8(a3)
}
ffffffffc0201e5e:	4501                	li	a0,0
    elm->next = next;
ffffffffc0201e60:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0201e62:	f614                	sd	a3,40(a2)
ffffffffc0201e64:	8082                	ret
{
ffffffffc0201e66:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0201e68:	00005697          	auipc	a3,0x5
ffffffffc0201e6c:	5b068693          	addi	a3,a3,1456 # ffffffffc0207418 <commands+0xcd0>
ffffffffc0201e70:	00005617          	auipc	a2,0x5
ffffffffc0201e74:	ce860613          	addi	a2,a2,-792 # ffffffffc0206b58 <commands+0x410>
ffffffffc0201e78:	03200593          	li	a1,50
ffffffffc0201e7c:	00005517          	auipc	a0,0x5
ffffffffc0201e80:	42c50513          	addi	a0,a0,1068 # ffffffffc02072a8 <commands+0xb60>
{
ffffffffc0201e84:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0201e86:	b82fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201e8a <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201e8a:	c94d                	beqz	a0,ffffffffc0201f3c <slob_free+0xb2>
{
ffffffffc0201e8c:	1141                	addi	sp,sp,-16
ffffffffc0201e8e:	e022                	sd	s0,0(sp)
ffffffffc0201e90:	e406                	sd	ra,8(sp)
ffffffffc0201e92:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201e94:	e9c1                	bnez	a1,ffffffffc0201f24 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e96:	100027f3          	csrr	a5,sstatus
ffffffffc0201e9a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201e9c:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e9e:	ebd9                	bnez	a5,ffffffffc0201f34 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201ea0:	000a5617          	auipc	a2,0xa5
ffffffffc0201ea4:	45060613          	addi	a2,a2,1104 # ffffffffc02a72f0 <slobfree>
ffffffffc0201ea8:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201eaa:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201eac:	679c                	ld	a5,8(a5)
ffffffffc0201eae:	02877a63          	bgeu	a4,s0,ffffffffc0201ee2 <slob_free+0x58>
ffffffffc0201eb2:	00f46463          	bltu	s0,a5,ffffffffc0201eba <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201eb6:	fef76ae3          	bltu	a4,a5,ffffffffc0201eaa <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201eba:	400c                	lw	a1,0(s0)
ffffffffc0201ebc:	00459693          	slli	a3,a1,0x4
ffffffffc0201ec0:	96a2                	add	a3,a3,s0
ffffffffc0201ec2:	02d78a63          	beq	a5,a3,ffffffffc0201ef6 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201ec6:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201ec8:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201eca:	00469793          	slli	a5,a3,0x4
ffffffffc0201ece:	97ba                	add	a5,a5,a4
ffffffffc0201ed0:	02f40e63          	beq	s0,a5,ffffffffc0201f0c <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201ed4:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201ed6:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc0201ed8:	e129                	bnez	a0,ffffffffc0201f1a <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201eda:	60a2                	ld	ra,8(sp)
ffffffffc0201edc:	6402                	ld	s0,0(sp)
ffffffffc0201ede:	0141                	addi	sp,sp,16
ffffffffc0201ee0:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201ee2:	fcf764e3          	bltu	a4,a5,ffffffffc0201eaa <slob_free+0x20>
ffffffffc0201ee6:	fcf472e3          	bgeu	s0,a5,ffffffffc0201eaa <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc0201eea:	400c                	lw	a1,0(s0)
ffffffffc0201eec:	00459693          	slli	a3,a1,0x4
ffffffffc0201ef0:	96a2                	add	a3,a3,s0
ffffffffc0201ef2:	fcd79ae3          	bne	a5,a3,ffffffffc0201ec6 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201ef6:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201ef8:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201efa:	9db5                	addw	a1,a1,a3
ffffffffc0201efc:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc0201efe:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201f00:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201f02:	00469793          	slli	a5,a3,0x4
ffffffffc0201f06:	97ba                	add	a5,a5,a4
ffffffffc0201f08:	fcf416e3          	bne	s0,a5,ffffffffc0201ed4 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201f0c:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201f0e:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201f10:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201f12:	9ebd                	addw	a3,a3,a5
ffffffffc0201f14:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201f16:	e70c                	sd	a1,8(a4)
ffffffffc0201f18:	d169                	beqz	a0,ffffffffc0201eda <slob_free+0x50>
}
ffffffffc0201f1a:	6402                	ld	s0,0(sp)
ffffffffc0201f1c:	60a2                	ld	ra,8(sp)
ffffffffc0201f1e:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201f20:	efefe06f          	j	ffffffffc020061e <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201f24:	25bd                	addiw	a1,a1,15
ffffffffc0201f26:	8191                	srli	a1,a1,0x4
ffffffffc0201f28:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f2a:	100027f3          	csrr	a5,sstatus
ffffffffc0201f2e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201f30:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f32:	d7bd                	beqz	a5,ffffffffc0201ea0 <slob_free+0x16>
        intr_disable();
ffffffffc0201f34:	ef0fe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc0201f38:	4505                	li	a0,1
ffffffffc0201f3a:	b79d                	j	ffffffffc0201ea0 <slob_free+0x16>
ffffffffc0201f3c:	8082                	ret

ffffffffc0201f3e <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201f3e:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201f40:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201f42:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201f46:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201f48:	690010ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
  if(!page)
ffffffffc0201f4c:	c91d                	beqz	a0,ffffffffc0201f82 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201f4e:	000b1697          	auipc	a3,0xb1
ffffffffc0201f52:	8da6b683          	ld	a3,-1830(a3) # ffffffffc02b2828 <pages>
ffffffffc0201f56:	8d15                	sub	a0,a0,a3
ffffffffc0201f58:	8519                	srai	a0,a0,0x6
ffffffffc0201f5a:	00007697          	auipc	a3,0x7
ffffffffc0201f5e:	b366b683          	ld	a3,-1226(a3) # ffffffffc0208a90 <nbase>
ffffffffc0201f62:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201f64:	00c51793          	slli	a5,a0,0xc
ffffffffc0201f68:	83b1                	srli	a5,a5,0xc
ffffffffc0201f6a:	000b1717          	auipc	a4,0xb1
ffffffffc0201f6e:	8b673703          	ld	a4,-1866(a4) # ffffffffc02b2820 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f72:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201f74:	00e7fa63          	bgeu	a5,a4,ffffffffc0201f88 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201f78:	000b1697          	auipc	a3,0xb1
ffffffffc0201f7c:	8c06b683          	ld	a3,-1856(a3) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0201f80:	9536                	add	a0,a0,a3
}
ffffffffc0201f82:	60a2                	ld	ra,8(sp)
ffffffffc0201f84:	0141                	addi	sp,sp,16
ffffffffc0201f86:	8082                	ret
ffffffffc0201f88:	86aa                	mv	a3,a0
ffffffffc0201f8a:	00005617          	auipc	a2,0x5
ffffffffc0201f8e:	f9e60613          	addi	a2,a2,-98 # ffffffffc0206f28 <commands+0x7e0>
ffffffffc0201f92:	06900593          	li	a1,105
ffffffffc0201f96:	00005517          	auipc	a0,0x5
ffffffffc0201f9a:	f3250513          	addi	a0,a0,-206 # ffffffffc0206ec8 <commands+0x780>
ffffffffc0201f9e:	a6afe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201fa2 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201fa2:	1101                	addi	sp,sp,-32
ffffffffc0201fa4:	ec06                	sd	ra,24(sp)
ffffffffc0201fa6:	e822                	sd	s0,16(sp)
ffffffffc0201fa8:	e426                	sd	s1,8(sp)
ffffffffc0201faa:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201fac:	01050713          	addi	a4,a0,16
ffffffffc0201fb0:	6785                	lui	a5,0x1
ffffffffc0201fb2:	0cf77363          	bgeu	a4,a5,ffffffffc0202078 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201fb6:	00f50493          	addi	s1,a0,15
ffffffffc0201fba:	8091                	srli	s1,s1,0x4
ffffffffc0201fbc:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201fbe:	10002673          	csrr	a2,sstatus
ffffffffc0201fc2:	8a09                	andi	a2,a2,2
ffffffffc0201fc4:	e25d                	bnez	a2,ffffffffc020206a <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201fc6:	000a5917          	auipc	s2,0xa5
ffffffffc0201fca:	32a90913          	addi	s2,s2,810 # ffffffffc02a72f0 <slobfree>
ffffffffc0201fce:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201fd2:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201fd4:	4398                	lw	a4,0(a5)
ffffffffc0201fd6:	08975e63          	bge	a4,s1,ffffffffc0202072 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0201fda:	00f68b63          	beq	a3,a5,ffffffffc0201ff0 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201fde:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201fe0:	4018                	lw	a4,0(s0)
ffffffffc0201fe2:	02975a63          	bge	a4,s1,ffffffffc0202016 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0201fe6:	00093683          	ld	a3,0(s2)
ffffffffc0201fea:	87a2                	mv	a5,s0
ffffffffc0201fec:	fef699e3          	bne	a3,a5,ffffffffc0201fde <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0201ff0:	ee31                	bnez	a2,ffffffffc020204c <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201ff2:	4501                	li	a0,0
ffffffffc0201ff4:	f4bff0ef          	jal	ra,ffffffffc0201f3e <__slob_get_free_pages.constprop.0>
ffffffffc0201ff8:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201ffa:	cd05                	beqz	a0,ffffffffc0202032 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201ffc:	6585                	lui	a1,0x1
ffffffffc0201ffe:	e8dff0ef          	jal	ra,ffffffffc0201e8a <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202002:	10002673          	csrr	a2,sstatus
ffffffffc0202006:	8a09                	andi	a2,a2,2
ffffffffc0202008:	ee05                	bnez	a2,ffffffffc0202040 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc020200a:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020200e:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202010:	4018                	lw	a4,0(s0)
ffffffffc0202012:	fc974ae3          	blt	a4,s1,ffffffffc0201fe6 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0202016:	04e48763          	beq	s1,a4,ffffffffc0202064 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc020201a:	00449693          	slli	a3,s1,0x4
ffffffffc020201e:	96a2                	add	a3,a3,s0
ffffffffc0202020:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0202022:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0202024:	9f05                	subw	a4,a4,s1
ffffffffc0202026:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0202028:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc020202a:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc020202c:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0202030:	e20d                	bnez	a2,ffffffffc0202052 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0202032:	60e2                	ld	ra,24(sp)
ffffffffc0202034:	8522                	mv	a0,s0
ffffffffc0202036:	6442                	ld	s0,16(sp)
ffffffffc0202038:	64a2                	ld	s1,8(sp)
ffffffffc020203a:	6902                	ld	s2,0(sp)
ffffffffc020203c:	6105                	addi	sp,sp,32
ffffffffc020203e:	8082                	ret
        intr_disable();
ffffffffc0202040:	de4fe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
			cur = slobfree;
ffffffffc0202044:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0202048:	4605                	li	a2,1
ffffffffc020204a:	b7d1                	j	ffffffffc020200e <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc020204c:	dd2fe0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0202050:	b74d                	j	ffffffffc0201ff2 <slob_alloc.constprop.0+0x50>
ffffffffc0202052:	dccfe0ef          	jal	ra,ffffffffc020061e <intr_enable>
}
ffffffffc0202056:	60e2                	ld	ra,24(sp)
ffffffffc0202058:	8522                	mv	a0,s0
ffffffffc020205a:	6442                	ld	s0,16(sp)
ffffffffc020205c:	64a2                	ld	s1,8(sp)
ffffffffc020205e:	6902                	ld	s2,0(sp)
ffffffffc0202060:	6105                	addi	sp,sp,32
ffffffffc0202062:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0202064:	6418                	ld	a4,8(s0)
ffffffffc0202066:	e798                	sd	a4,8(a5)
ffffffffc0202068:	b7d1                	j	ffffffffc020202c <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc020206a:	dbafe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc020206e:	4605                	li	a2,1
ffffffffc0202070:	bf99                	j	ffffffffc0201fc6 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202072:	843e                	mv	s0,a5
ffffffffc0202074:	87b6                	mv	a5,a3
ffffffffc0202076:	b745                	j	ffffffffc0202016 <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0202078:	00005697          	auipc	a3,0x5
ffffffffc020207c:	3d868693          	addi	a3,a3,984 # ffffffffc0207450 <commands+0xd08>
ffffffffc0202080:	00005617          	auipc	a2,0x5
ffffffffc0202084:	ad860613          	addi	a2,a2,-1320 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202088:	06400593          	li	a1,100
ffffffffc020208c:	00005517          	auipc	a0,0x5
ffffffffc0202090:	3e450513          	addi	a0,a0,996 # ffffffffc0207470 <commands+0xd28>
ffffffffc0202094:	974fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202098 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0202098:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc020209a:	00005517          	auipc	a0,0x5
ffffffffc020209e:	3ee50513          	addi	a0,a0,1006 # ffffffffc0207488 <commands+0xd40>
kmalloc_init(void) {
ffffffffc02020a2:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc02020a4:	828fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02020a8:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02020aa:	00005517          	auipc	a0,0x5
ffffffffc02020ae:	3f650513          	addi	a0,a0,1014 # ffffffffc02074a0 <commands+0xd58>
}
ffffffffc02020b2:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02020b4:	818fe06f          	j	ffffffffc02000cc <cprintf>

ffffffffc02020b8 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc02020b8:	4501                	li	a0,0
ffffffffc02020ba:	8082                	ret

ffffffffc02020bc <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02020bc:	1101                	addi	sp,sp,-32
ffffffffc02020be:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02020c0:	6905                	lui	s2,0x1
{
ffffffffc02020c2:	e822                	sd	s0,16(sp)
ffffffffc02020c4:	ec06                	sd	ra,24(sp)
ffffffffc02020c6:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02020c8:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bc1>
{
ffffffffc02020cc:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02020ce:	04a7f963          	bgeu	a5,a0,ffffffffc0202120 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02020d2:	4561                	li	a0,24
ffffffffc02020d4:	ecfff0ef          	jal	ra,ffffffffc0201fa2 <slob_alloc.constprop.0>
ffffffffc02020d8:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02020da:	c929                	beqz	a0,ffffffffc020212c <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc02020dc:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02020e0:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc02020e2:	00f95763          	bge	s2,a5,ffffffffc02020f0 <kmalloc+0x34>
ffffffffc02020e6:	6705                	lui	a4,0x1
ffffffffc02020e8:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02020ea:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc02020ec:	fef74ee3          	blt	a4,a5,ffffffffc02020e8 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc02020f0:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02020f2:	e4dff0ef          	jal	ra,ffffffffc0201f3e <__slob_get_free_pages.constprop.0>
ffffffffc02020f6:	e488                	sd	a0,8(s1)
ffffffffc02020f8:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc02020fa:	c525                	beqz	a0,ffffffffc0202162 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02020fc:	100027f3          	csrr	a5,sstatus
ffffffffc0202100:	8b89                	andi	a5,a5,2
ffffffffc0202102:	ef8d                	bnez	a5,ffffffffc020213c <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0202104:	000b0797          	auipc	a5,0xb0
ffffffffc0202108:	6ec78793          	addi	a5,a5,1772 # ffffffffc02b27f0 <bigblocks>
ffffffffc020210c:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc020210e:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0202110:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0202112:	60e2                	ld	ra,24(sp)
ffffffffc0202114:	8522                	mv	a0,s0
ffffffffc0202116:	6442                	ld	s0,16(sp)
ffffffffc0202118:	64a2                	ld	s1,8(sp)
ffffffffc020211a:	6902                	ld	s2,0(sp)
ffffffffc020211c:	6105                	addi	sp,sp,32
ffffffffc020211e:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0202120:	0541                	addi	a0,a0,16
ffffffffc0202122:	e81ff0ef          	jal	ra,ffffffffc0201fa2 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0202126:	01050413          	addi	s0,a0,16
ffffffffc020212a:	f565                	bnez	a0,ffffffffc0202112 <kmalloc+0x56>
ffffffffc020212c:	4401                	li	s0,0
}
ffffffffc020212e:	60e2                	ld	ra,24(sp)
ffffffffc0202130:	8522                	mv	a0,s0
ffffffffc0202132:	6442                	ld	s0,16(sp)
ffffffffc0202134:	64a2                	ld	s1,8(sp)
ffffffffc0202136:	6902                	ld	s2,0(sp)
ffffffffc0202138:	6105                	addi	sp,sp,32
ffffffffc020213a:	8082                	ret
        intr_disable();
ffffffffc020213c:	ce8fe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
		bb->next = bigblocks;
ffffffffc0202140:	000b0797          	auipc	a5,0xb0
ffffffffc0202144:	6b078793          	addi	a5,a5,1712 # ffffffffc02b27f0 <bigblocks>
ffffffffc0202148:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc020214a:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc020214c:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc020214e:	cd0fe0ef          	jal	ra,ffffffffc020061e <intr_enable>
		return bb->pages;
ffffffffc0202152:	6480                	ld	s0,8(s1)
}
ffffffffc0202154:	60e2                	ld	ra,24(sp)
ffffffffc0202156:	64a2                	ld	s1,8(sp)
ffffffffc0202158:	8522                	mv	a0,s0
ffffffffc020215a:	6442                	ld	s0,16(sp)
ffffffffc020215c:	6902                	ld	s2,0(sp)
ffffffffc020215e:	6105                	addi	sp,sp,32
ffffffffc0202160:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0202162:	45e1                	li	a1,24
ffffffffc0202164:	8526                	mv	a0,s1
ffffffffc0202166:	d25ff0ef          	jal	ra,ffffffffc0201e8a <slob_free>
  return __kmalloc(size, 0);
ffffffffc020216a:	b765                	j	ffffffffc0202112 <kmalloc+0x56>

ffffffffc020216c <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc020216c:	c171                	beqz	a0,ffffffffc0202230 <kfree+0xc4>
{
ffffffffc020216e:	1101                	addi	sp,sp,-32
ffffffffc0202170:	e822                	sd	s0,16(sp)
ffffffffc0202172:	ec06                	sd	ra,24(sp)
ffffffffc0202174:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0202176:	03451793          	slli	a5,a0,0x34
ffffffffc020217a:	842a                	mv	s0,a0
ffffffffc020217c:	e3d9                	bnez	a5,ffffffffc0202202 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020217e:	100027f3          	csrr	a5,sstatus
ffffffffc0202182:	8b89                	andi	a5,a5,2
ffffffffc0202184:	ebc1                	bnez	a5,ffffffffc0202214 <kfree+0xa8>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202186:	000b0797          	auipc	a5,0xb0
ffffffffc020218a:	66a7b783          	ld	a5,1642(a5) # ffffffffc02b27f0 <bigblocks>
    return 0;
ffffffffc020218e:	4601                	li	a2,0
ffffffffc0202190:	cbad                	beqz	a5,ffffffffc0202202 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0202192:	000b0697          	auipc	a3,0xb0
ffffffffc0202196:	65e68693          	addi	a3,a3,1630 # ffffffffc02b27f0 <bigblocks>
ffffffffc020219a:	a021                	j	ffffffffc02021a2 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020219c:	01048693          	addi	a3,s1,16
ffffffffc02021a0:	c3a5                	beqz	a5,ffffffffc0202200 <kfree+0x94>
			if (bb->pages == block) {
ffffffffc02021a2:	6798                	ld	a4,8(a5)
ffffffffc02021a4:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc02021a6:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc02021a8:	fe871ae3          	bne	a4,s0,ffffffffc020219c <kfree+0x30>
				*last = bb->next;
ffffffffc02021ac:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc02021ae:	ee35                	bnez	a2,ffffffffc020222a <kfree+0xbe>
    return pa2page(PADDR(kva));
ffffffffc02021b0:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc02021b4:	4098                	lw	a4,0(s1)
ffffffffc02021b6:	08f46a63          	bltu	s0,a5,ffffffffc020224a <kfree+0xde>
ffffffffc02021ba:	000b0697          	auipc	a3,0xb0
ffffffffc02021be:	67e6b683          	ld	a3,1662(a3) # ffffffffc02b2838 <va_pa_offset>
ffffffffc02021c2:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc02021c4:	8031                	srli	s0,s0,0xc
ffffffffc02021c6:	000b0797          	auipc	a5,0xb0
ffffffffc02021ca:	65a7b783          	ld	a5,1626(a5) # ffffffffc02b2820 <npage>
ffffffffc02021ce:	06f47263          	bgeu	s0,a5,ffffffffc0202232 <kfree+0xc6>
    return &pages[PPN(pa) - nbase];
ffffffffc02021d2:	00007517          	auipc	a0,0x7
ffffffffc02021d6:	8be53503          	ld	a0,-1858(a0) # ffffffffc0208a90 <nbase>
ffffffffc02021da:	8c09                	sub	s0,s0,a0
ffffffffc02021dc:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc02021de:	000b0517          	auipc	a0,0xb0
ffffffffc02021e2:	64a53503          	ld	a0,1610(a0) # ffffffffc02b2828 <pages>
ffffffffc02021e6:	4585                	li	a1,1
ffffffffc02021e8:	9522                	add	a0,a0,s0
ffffffffc02021ea:	00e595bb          	sllw	a1,a1,a4
ffffffffc02021ee:	47c010ef          	jal	ra,ffffffffc020366a <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc02021f2:	6442                	ld	s0,16(sp)
ffffffffc02021f4:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02021f6:	8526                	mv	a0,s1
}
ffffffffc02021f8:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02021fa:	45e1                	li	a1,24
}
ffffffffc02021fc:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02021fe:	b171                	j	ffffffffc0201e8a <slob_free>
ffffffffc0202200:	e215                	bnez	a2,ffffffffc0202224 <kfree+0xb8>
ffffffffc0202202:	ff040513          	addi	a0,s0,-16
}
ffffffffc0202206:	6442                	ld	s0,16(sp)
ffffffffc0202208:	60e2                	ld	ra,24(sp)
ffffffffc020220a:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc020220c:	4581                	li	a1,0
}
ffffffffc020220e:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202210:	c7bff06f          	j	ffffffffc0201e8a <slob_free>
        intr_disable();
ffffffffc0202214:	c10fe0ef          	jal	ra,ffffffffc0200624 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202218:	000b0797          	auipc	a5,0xb0
ffffffffc020221c:	5d87b783          	ld	a5,1496(a5) # ffffffffc02b27f0 <bigblocks>
        return 1;
ffffffffc0202220:	4605                	li	a2,1
ffffffffc0202222:	fba5                	bnez	a5,ffffffffc0202192 <kfree+0x26>
        intr_enable();
ffffffffc0202224:	bfafe0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0202228:	bfe9                	j	ffffffffc0202202 <kfree+0x96>
ffffffffc020222a:	bf4fe0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc020222e:	b749                	j	ffffffffc02021b0 <kfree+0x44>
ffffffffc0202230:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0202232:	00005617          	auipc	a2,0x5
ffffffffc0202236:	ca660613          	addi	a2,a2,-858 # ffffffffc0206ed8 <commands+0x790>
ffffffffc020223a:	06200593          	li	a1,98
ffffffffc020223e:	00005517          	auipc	a0,0x5
ffffffffc0202242:	c8a50513          	addi	a0,a0,-886 # ffffffffc0206ec8 <commands+0x780>
ffffffffc0202246:	fc3fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020224a:	86a2                	mv	a3,s0
ffffffffc020224c:	00005617          	auipc	a2,0x5
ffffffffc0202250:	27460613          	addi	a2,a2,628 # ffffffffc02074c0 <commands+0xd78>
ffffffffc0202254:	06e00593          	li	a1,110
ffffffffc0202258:	00005517          	auipc	a0,0x5
ffffffffc020225c:	c7050513          	addi	a0,a0,-912 # ffffffffc0206ec8 <commands+0x780>
ffffffffc0202260:	fa9fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202264 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0202264:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202266:	00005617          	auipc	a2,0x5
ffffffffc020226a:	c7260613          	addi	a2,a2,-910 # ffffffffc0206ed8 <commands+0x790>
ffffffffc020226e:	06200593          	li	a1,98
ffffffffc0202272:	00005517          	auipc	a0,0x5
ffffffffc0202276:	c5650513          	addi	a0,a0,-938 # ffffffffc0206ec8 <commands+0x780>
pa2page(uintptr_t pa) {
ffffffffc020227a:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020227c:	f8dfd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202280 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202280:	7135                	addi	sp,sp,-160
ffffffffc0202282:	ed06                	sd	ra,152(sp)
ffffffffc0202284:	e922                	sd	s0,144(sp)
ffffffffc0202286:	e526                	sd	s1,136(sp)
ffffffffc0202288:	e14a                	sd	s2,128(sp)
ffffffffc020228a:	fcce                	sd	s3,120(sp)
ffffffffc020228c:	f8d2                	sd	s4,112(sp)
ffffffffc020228e:	f4d6                	sd	s5,104(sp)
ffffffffc0202290:	f0da                	sd	s6,96(sp)
ffffffffc0202292:	ecde                	sd	s7,88(sp)
ffffffffc0202294:	e8e2                	sd	s8,80(sp)
ffffffffc0202296:	e4e6                	sd	s9,72(sp)
ffffffffc0202298:	e0ea                	sd	s10,64(sp)
ffffffffc020229a:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc020229c:	033020ef          	jal	ra,ffffffffc0204ace <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02022a0:	000b0697          	auipc	a3,0xb0
ffffffffc02022a4:	5586b683          	ld	a3,1368(a3) # ffffffffc02b27f8 <max_swap_offset>
ffffffffc02022a8:	010007b7          	lui	a5,0x1000
ffffffffc02022ac:	ff968713          	addi	a4,a3,-7
ffffffffc02022b0:	17e1                	addi	a5,a5,-8
ffffffffc02022b2:	42e7e663          	bltu	a5,a4,ffffffffc02026de <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02022b6:	000a5797          	auipc	a5,0xa5
ffffffffc02022ba:	fea78793          	addi	a5,a5,-22 # ffffffffc02a72a0 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02022be:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02022c0:	000b0b97          	auipc	s7,0xb0
ffffffffc02022c4:	540b8b93          	addi	s7,s7,1344 # ffffffffc02b2800 <sm>
ffffffffc02022c8:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc02022cc:	9702                	jalr	a4
ffffffffc02022ce:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc02022d0:	c10d                	beqz	a0,ffffffffc02022f2 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02022d2:	60ea                	ld	ra,152(sp)
ffffffffc02022d4:	644a                	ld	s0,144(sp)
ffffffffc02022d6:	64aa                	ld	s1,136(sp)
ffffffffc02022d8:	79e6                	ld	s3,120(sp)
ffffffffc02022da:	7a46                	ld	s4,112(sp)
ffffffffc02022dc:	7aa6                	ld	s5,104(sp)
ffffffffc02022de:	7b06                	ld	s6,96(sp)
ffffffffc02022e0:	6be6                	ld	s7,88(sp)
ffffffffc02022e2:	6c46                	ld	s8,80(sp)
ffffffffc02022e4:	6ca6                	ld	s9,72(sp)
ffffffffc02022e6:	6d06                	ld	s10,64(sp)
ffffffffc02022e8:	7de2                	ld	s11,56(sp)
ffffffffc02022ea:	854a                	mv	a0,s2
ffffffffc02022ec:	690a                	ld	s2,128(sp)
ffffffffc02022ee:	610d                	addi	sp,sp,160
ffffffffc02022f0:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02022f2:	000bb783          	ld	a5,0(s7)
ffffffffc02022f6:	00005517          	auipc	a0,0x5
ffffffffc02022fa:	22250513          	addi	a0,a0,546 # ffffffffc0207518 <commands+0xdd0>
    return listelm->next;
ffffffffc02022fe:	000ac417          	auipc	s0,0xac
ffffffffc0202302:	4a240413          	addi	s0,s0,1186 # ffffffffc02ae7a0 <free_area>
ffffffffc0202306:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202308:	4785                	li	a5,1
ffffffffc020230a:	000b0717          	auipc	a4,0xb0
ffffffffc020230e:	4ef72f23          	sw	a5,1278(a4) # ffffffffc02b2808 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202312:	dbbfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0202316:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0202318:	4d01                	li	s10,0
ffffffffc020231a:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020231c:	34878163          	beq	a5,s0,ffffffffc020265e <swap_init+0x3de>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202320:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202324:	8b09                	andi	a4,a4,2
ffffffffc0202326:	32070e63          	beqz	a4,ffffffffc0202662 <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc020232a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020232e:	679c                	ld	a5,8(a5)
ffffffffc0202330:	2d85                	addiw	s11,s11,1
ffffffffc0202332:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202336:	fe8795e3          	bne	a5,s0,ffffffffc0202320 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc020233a:	84ea                	mv	s1,s10
ffffffffc020233c:	36e010ef          	jal	ra,ffffffffc02036aa <nr_free_pages>
ffffffffc0202340:	42951763          	bne	a0,s1,ffffffffc020276e <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202344:	866a                	mv	a2,s10
ffffffffc0202346:	85ee                	mv	a1,s11
ffffffffc0202348:	00005517          	auipc	a0,0x5
ffffffffc020234c:	21850513          	addi	a0,a0,536 # ffffffffc0207560 <commands+0xe18>
ffffffffc0202350:	d7dfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202354:	dddfe0ef          	jal	ra,ffffffffc0201130 <mm_create>
ffffffffc0202358:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc020235a:	46050a63          	beqz	a0,ffffffffc02027ce <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020235e:	000b0797          	auipc	a5,0xb0
ffffffffc0202362:	48278793          	addi	a5,a5,1154 # ffffffffc02b27e0 <check_mm_struct>
ffffffffc0202366:	6398                	ld	a4,0(a5)
ffffffffc0202368:	3e071363          	bnez	a4,ffffffffc020274e <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020236c:	000b0717          	auipc	a4,0xb0
ffffffffc0202370:	4ac70713          	addi	a4,a4,1196 # ffffffffc02b2818 <boot_pgdir>
ffffffffc0202374:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc0202378:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc020237a:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020237e:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202382:	42079663          	bnez	a5,ffffffffc02027ae <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202386:	6599                	lui	a1,0x6
ffffffffc0202388:	460d                	li	a2,3
ffffffffc020238a:	6505                	lui	a0,0x1
ffffffffc020238c:	dedfe0ef          	jal	ra,ffffffffc0201178 <vma_create>
ffffffffc0202390:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202392:	52050a63          	beqz	a0,ffffffffc02028c6 <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc0202396:	8556                	mv	a0,s5
ffffffffc0202398:	e4ffe0ef          	jal	ra,ffffffffc02011e6 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020239c:	00005517          	auipc	a0,0x5
ffffffffc02023a0:	20450513          	addi	a0,a0,516 # ffffffffc02075a0 <commands+0xe58>
ffffffffc02023a4:	d29fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02023a8:	018ab503          	ld	a0,24(s5)
ffffffffc02023ac:	4605                	li	a2,1
ffffffffc02023ae:	6585                	lui	a1,0x1
ffffffffc02023b0:	334010ef          	jal	ra,ffffffffc02036e4 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02023b4:	4c050963          	beqz	a0,ffffffffc0202886 <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02023b8:	00005517          	auipc	a0,0x5
ffffffffc02023bc:	23850513          	addi	a0,a0,568 # ffffffffc02075f0 <commands+0xea8>
ffffffffc02023c0:	000ac497          	auipc	s1,0xac
ffffffffc02023c4:	37048493          	addi	s1,s1,880 # ffffffffc02ae730 <check_rp>
ffffffffc02023c8:	d05fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02023cc:	000ac997          	auipc	s3,0xac
ffffffffc02023d0:	38498993          	addi	s3,s3,900 # ffffffffc02ae750 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02023d4:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc02023d6:	4505                	li	a0,1
ffffffffc02023d8:	200010ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc02023dc:	00aa3023          	sd	a0,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
          assert(check_rp[i] != NULL );
ffffffffc02023e0:	2c050f63          	beqz	a0,ffffffffc02026be <swap_init+0x43e>
ffffffffc02023e4:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02023e6:	8b89                	andi	a5,a5,2
ffffffffc02023e8:	34079363          	bnez	a5,ffffffffc020272e <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02023ec:	0a21                	addi	s4,s4,8
ffffffffc02023ee:	ff3a14e3          	bne	s4,s3,ffffffffc02023d6 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02023f2:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02023f4:	000aca17          	auipc	s4,0xac
ffffffffc02023f8:	33ca0a13          	addi	s4,s4,828 # ffffffffc02ae730 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc02023fc:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc02023fe:	ec3e                	sd	a5,24(sp)
ffffffffc0202400:	641c                	ld	a5,8(s0)
ffffffffc0202402:	e400                	sd	s0,8(s0)
ffffffffc0202404:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202406:	481c                	lw	a5,16(s0)
ffffffffc0202408:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc020240a:	000ac797          	auipc	a5,0xac
ffffffffc020240e:	3a07a323          	sw	zero,934(a5) # ffffffffc02ae7b0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202412:	000a3503          	ld	a0,0(s4)
ffffffffc0202416:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202418:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc020241a:	250010ef          	jal	ra,ffffffffc020366a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020241e:	ff3a1ae3          	bne	s4,s3,ffffffffc0202412 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202422:	01042a03          	lw	s4,16(s0)
ffffffffc0202426:	4791                	li	a5,4
ffffffffc0202428:	42fa1f63          	bne	s4,a5,ffffffffc0202866 <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020242c:	00005517          	auipc	a0,0x5
ffffffffc0202430:	24c50513          	addi	a0,a0,588 # ffffffffc0207678 <commands+0xf30>
ffffffffc0202434:	c99fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202438:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc020243a:	000b0797          	auipc	a5,0xb0
ffffffffc020243e:	3a07a723          	sw	zero,942(a5) # ffffffffc02b27e8 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202442:	4629                	li	a2,10
ffffffffc0202444:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
     assert(pgfault_num==1);
ffffffffc0202448:	000b0697          	auipc	a3,0xb0
ffffffffc020244c:	3a06a683          	lw	a3,928(a3) # ffffffffc02b27e8 <pgfault_num>
ffffffffc0202450:	4585                	li	a1,1
ffffffffc0202452:	000b0797          	auipc	a5,0xb0
ffffffffc0202456:	39678793          	addi	a5,a5,918 # ffffffffc02b27e8 <pgfault_num>
ffffffffc020245a:	54b69663          	bne	a3,a1,ffffffffc02029a6 <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc020245e:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0202462:	4398                	lw	a4,0(a5)
ffffffffc0202464:	2701                	sext.w	a4,a4
ffffffffc0202466:	3ed71063          	bne	a4,a3,ffffffffc0202846 <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc020246a:	6689                	lui	a3,0x2
ffffffffc020246c:	462d                	li	a2,11
ffffffffc020246e:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7bb0>
     assert(pgfault_num==2);
ffffffffc0202472:	4398                	lw	a4,0(a5)
ffffffffc0202474:	4589                	li	a1,2
ffffffffc0202476:	2701                	sext.w	a4,a4
ffffffffc0202478:	4ab71763          	bne	a4,a1,ffffffffc0202926 <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc020247c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202480:	4394                	lw	a3,0(a5)
ffffffffc0202482:	2681                	sext.w	a3,a3
ffffffffc0202484:	4ce69163          	bne	a3,a4,ffffffffc0202946 <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202488:	668d                	lui	a3,0x3
ffffffffc020248a:	4631                	li	a2,12
ffffffffc020248c:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb0>
     assert(pgfault_num==3);
ffffffffc0202490:	4398                	lw	a4,0(a5)
ffffffffc0202492:	458d                	li	a1,3
ffffffffc0202494:	2701                	sext.w	a4,a4
ffffffffc0202496:	4cb71863          	bne	a4,a1,ffffffffc0202966 <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc020249a:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc020249e:	4394                	lw	a3,0(a5)
ffffffffc02024a0:	2681                	sext.w	a3,a3
ffffffffc02024a2:	4ee69263          	bne	a3,a4,ffffffffc0202986 <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02024a6:	6691                	lui	a3,0x4
ffffffffc02024a8:	4635                	li	a2,13
ffffffffc02024aa:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5bb0>
     assert(pgfault_num==4);
ffffffffc02024ae:	4398                	lw	a4,0(a5)
ffffffffc02024b0:	2701                	sext.w	a4,a4
ffffffffc02024b2:	43471a63          	bne	a4,s4,ffffffffc02028e6 <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02024b6:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02024ba:	439c                	lw	a5,0(a5)
ffffffffc02024bc:	2781                	sext.w	a5,a5
ffffffffc02024be:	44e79463          	bne	a5,a4,ffffffffc0202906 <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02024c2:	481c                	lw	a5,16(s0)
ffffffffc02024c4:	2c079563          	bnez	a5,ffffffffc020278e <swap_init+0x50e>
ffffffffc02024c8:	000ac797          	auipc	a5,0xac
ffffffffc02024cc:	28878793          	addi	a5,a5,648 # ffffffffc02ae750 <swap_in_seq_no>
ffffffffc02024d0:	000ac717          	auipc	a4,0xac
ffffffffc02024d4:	2a870713          	addi	a4,a4,680 # ffffffffc02ae778 <swap_out_seq_no>
ffffffffc02024d8:	000ac617          	auipc	a2,0xac
ffffffffc02024dc:	2a060613          	addi	a2,a2,672 # ffffffffc02ae778 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02024e0:	56fd                	li	a3,-1
ffffffffc02024e2:	c394                	sw	a3,0(a5)
ffffffffc02024e4:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02024e6:	0791                	addi	a5,a5,4
ffffffffc02024e8:	0711                	addi	a4,a4,4
ffffffffc02024ea:	fec79ce3          	bne	a5,a2,ffffffffc02024e2 <swap_init+0x262>
ffffffffc02024ee:	000ac717          	auipc	a4,0xac
ffffffffc02024f2:	22270713          	addi	a4,a4,546 # ffffffffc02ae710 <check_ptep>
ffffffffc02024f6:	000ac697          	auipc	a3,0xac
ffffffffc02024fa:	23a68693          	addi	a3,a3,570 # ffffffffc02ae730 <check_rp>
ffffffffc02024fe:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202500:	000b0c17          	auipc	s8,0xb0
ffffffffc0202504:	320c0c13          	addi	s8,s8,800 # ffffffffc02b2820 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202508:	000b0c97          	auipc	s9,0xb0
ffffffffc020250c:	320c8c93          	addi	s9,s9,800 # ffffffffc02b2828 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202510:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202514:	4601                	li	a2,0
ffffffffc0202516:	855a                	mv	a0,s6
ffffffffc0202518:	e836                	sd	a3,16(sp)
ffffffffc020251a:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc020251c:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020251e:	1c6010ef          	jal	ra,ffffffffc02036e4 <get_pte>
ffffffffc0202522:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202524:	65a2                	ld	a1,8(sp)
ffffffffc0202526:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202528:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc020252a:	1c050663          	beqz	a0,ffffffffc02026f6 <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020252e:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202530:	0017f613          	andi	a2,a5,1
ffffffffc0202534:	1e060163          	beqz	a2,ffffffffc0202716 <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc0202538:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc020253c:	078a                	slli	a5,a5,0x2
ffffffffc020253e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202540:	14c7f363          	bgeu	a5,a2,ffffffffc0202686 <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc0202544:	00006617          	auipc	a2,0x6
ffffffffc0202548:	54c60613          	addi	a2,a2,1356 # ffffffffc0208a90 <nbase>
ffffffffc020254c:	00063a03          	ld	s4,0(a2)
ffffffffc0202550:	000cb603          	ld	a2,0(s9)
ffffffffc0202554:	6288                	ld	a0,0(a3)
ffffffffc0202556:	414787b3          	sub	a5,a5,s4
ffffffffc020255a:	079a                	slli	a5,a5,0x6
ffffffffc020255c:	97b2                	add	a5,a5,a2
ffffffffc020255e:	14f51063          	bne	a0,a5,ffffffffc020269e <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202562:	6785                	lui	a5,0x1
ffffffffc0202564:	95be                	add	a1,a1,a5
ffffffffc0202566:	6795                	lui	a5,0x5
ffffffffc0202568:	0721                	addi	a4,a4,8
ffffffffc020256a:	06a1                	addi	a3,a3,8
ffffffffc020256c:	faf592e3          	bne	a1,a5,ffffffffc0202510 <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202570:	00005517          	auipc	a0,0x5
ffffffffc0202574:	1b050513          	addi	a0,a0,432 # ffffffffc0207720 <commands+0xfd8>
ffffffffc0202578:	b55fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = sm->check_swap();
ffffffffc020257c:	000bb783          	ld	a5,0(s7)
ffffffffc0202580:	7f9c                	ld	a5,56(a5)
ffffffffc0202582:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202584:	32051163          	bnez	a0,ffffffffc02028a6 <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc0202588:	77a2                	ld	a5,40(sp)
ffffffffc020258a:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc020258c:	67e2                	ld	a5,24(sp)
ffffffffc020258e:	e01c                	sd	a5,0(s0)
ffffffffc0202590:	7782                	ld	a5,32(sp)
ffffffffc0202592:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202594:	6088                	ld	a0,0(s1)
ffffffffc0202596:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202598:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc020259a:	0d0010ef          	jal	ra,ffffffffc020366a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020259e:	ff349be3          	bne	s1,s3,ffffffffc0202594 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02025a2:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc02025a6:	8556                	mv	a0,s5
ffffffffc02025a8:	d0ffe0ef          	jal	ra,ffffffffc02012b6 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02025ac:	000b0797          	auipc	a5,0xb0
ffffffffc02025b0:	26c78793          	addi	a5,a5,620 # ffffffffc02b2818 <boot_pgdir>
ffffffffc02025b4:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02025b6:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc02025ba:	000b0697          	auipc	a3,0xb0
ffffffffc02025be:	2206b323          	sd	zero,550(a3) # ffffffffc02b27e0 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc02025c2:	639c                	ld	a5,0(a5)
ffffffffc02025c4:	078a                	slli	a5,a5,0x2
ffffffffc02025c6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025c8:	0ae7fd63          	bgeu	a5,a4,ffffffffc0202682 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc02025cc:	414786b3          	sub	a3,a5,s4
ffffffffc02025d0:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02025d2:	8699                	srai	a3,a3,0x6
ffffffffc02025d4:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02025d6:	00c69793          	slli	a5,a3,0xc
ffffffffc02025da:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02025dc:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc02025e0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02025e2:	22e7f663          	bgeu	a5,a4,ffffffffc020280e <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc02025e6:	000b0797          	auipc	a5,0xb0
ffffffffc02025ea:	2527b783          	ld	a5,594(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc02025ee:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02025f0:	629c                	ld	a5,0(a3)
ffffffffc02025f2:	078a                	slli	a5,a5,0x2
ffffffffc02025f4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025f6:	08e7f663          	bgeu	a5,a4,ffffffffc0202682 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc02025fa:	414787b3          	sub	a5,a5,s4
ffffffffc02025fe:	079a                	slli	a5,a5,0x6
ffffffffc0202600:	953e                	add	a0,a0,a5
ffffffffc0202602:	4585                	li	a1,1
ffffffffc0202604:	066010ef          	jal	ra,ffffffffc020366a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202608:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc020260c:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202610:	078a                	slli	a5,a5,0x2
ffffffffc0202612:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202614:	06e7f763          	bgeu	a5,a4,ffffffffc0202682 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0202618:	000cb503          	ld	a0,0(s9)
ffffffffc020261c:	414787b3          	sub	a5,a5,s4
ffffffffc0202620:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202622:	4585                	li	a1,1
ffffffffc0202624:	953e                	add	a0,a0,a5
ffffffffc0202626:	044010ef          	jal	ra,ffffffffc020366a <free_pages>
     pgdir[0] = 0;
ffffffffc020262a:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc020262e:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202632:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202634:	00878a63          	beq	a5,s0,ffffffffc0202648 <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202638:	ff87a703          	lw	a4,-8(a5)
ffffffffc020263c:	679c                	ld	a5,8(a5)
ffffffffc020263e:	3dfd                	addiw	s11,s11,-1
ffffffffc0202640:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202644:	fe879ae3          	bne	a5,s0,ffffffffc0202638 <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc0202648:	1c0d9f63          	bnez	s11,ffffffffc0202826 <swap_init+0x5a6>
     assert(total==0);
ffffffffc020264c:	1a0d1163          	bnez	s10,ffffffffc02027ee <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202650:	00005517          	auipc	a0,0x5
ffffffffc0202654:	12050513          	addi	a0,a0,288 # ffffffffc0207770 <commands+0x1028>
ffffffffc0202658:	a75fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc020265c:	b99d                	j	ffffffffc02022d2 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc020265e:	4481                	li	s1,0
ffffffffc0202660:	b9f1                	j	ffffffffc020233c <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc0202662:	00005697          	auipc	a3,0x5
ffffffffc0202666:	ece68693          	addi	a3,a3,-306 # ffffffffc0207530 <commands+0xde8>
ffffffffc020266a:	00004617          	auipc	a2,0x4
ffffffffc020266e:	4ee60613          	addi	a2,a2,1262 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202672:	0bc00593          	li	a1,188
ffffffffc0202676:	00005517          	auipc	a0,0x5
ffffffffc020267a:	e9250513          	addi	a0,a0,-366 # ffffffffc0207508 <commands+0xdc0>
ffffffffc020267e:	b8bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0202682:	be3ff0ef          	jal	ra,ffffffffc0202264 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc0202686:	00005617          	auipc	a2,0x5
ffffffffc020268a:	85260613          	addi	a2,a2,-1966 # ffffffffc0206ed8 <commands+0x790>
ffffffffc020268e:	06200593          	li	a1,98
ffffffffc0202692:	00005517          	auipc	a0,0x5
ffffffffc0202696:	83650513          	addi	a0,a0,-1994 # ffffffffc0206ec8 <commands+0x780>
ffffffffc020269a:	b6ffd0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020269e:	00005697          	auipc	a3,0x5
ffffffffc02026a2:	05a68693          	addi	a3,a3,90 # ffffffffc02076f8 <commands+0xfb0>
ffffffffc02026a6:	00004617          	auipc	a2,0x4
ffffffffc02026aa:	4b260613          	addi	a2,a2,1202 # ffffffffc0206b58 <commands+0x410>
ffffffffc02026ae:	0fc00593          	li	a1,252
ffffffffc02026b2:	00005517          	auipc	a0,0x5
ffffffffc02026b6:	e5650513          	addi	a0,a0,-426 # ffffffffc0207508 <commands+0xdc0>
ffffffffc02026ba:	b4ffd0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc02026be:	00005697          	auipc	a3,0x5
ffffffffc02026c2:	f5a68693          	addi	a3,a3,-166 # ffffffffc0207618 <commands+0xed0>
ffffffffc02026c6:	00004617          	auipc	a2,0x4
ffffffffc02026ca:	49260613          	addi	a2,a2,1170 # ffffffffc0206b58 <commands+0x410>
ffffffffc02026ce:	0dc00593          	li	a1,220
ffffffffc02026d2:	00005517          	auipc	a0,0x5
ffffffffc02026d6:	e3650513          	addi	a0,a0,-458 # ffffffffc0207508 <commands+0xdc0>
ffffffffc02026da:	b2ffd0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc02026de:	00005617          	auipc	a2,0x5
ffffffffc02026e2:	e0a60613          	addi	a2,a2,-502 # ffffffffc02074e8 <commands+0xda0>
ffffffffc02026e6:	02800593          	li	a1,40
ffffffffc02026ea:	00005517          	auipc	a0,0x5
ffffffffc02026ee:	e1e50513          	addi	a0,a0,-482 # ffffffffc0207508 <commands+0xdc0>
ffffffffc02026f2:	b17fd0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc02026f6:	00005697          	auipc	a3,0x5
ffffffffc02026fa:	fea68693          	addi	a3,a3,-22 # ffffffffc02076e0 <commands+0xf98>
ffffffffc02026fe:	00004617          	auipc	a2,0x4
ffffffffc0202702:	45a60613          	addi	a2,a2,1114 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202706:	0fb00593          	li	a1,251
ffffffffc020270a:	00005517          	auipc	a0,0x5
ffffffffc020270e:	dfe50513          	addi	a0,a0,-514 # ffffffffc0207508 <commands+0xdc0>
ffffffffc0202712:	af7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202716:	00004617          	auipc	a2,0x4
ffffffffc020271a:	78a60613          	addi	a2,a2,1930 # ffffffffc0206ea0 <commands+0x758>
ffffffffc020271e:	07400593          	li	a1,116
ffffffffc0202722:	00004517          	auipc	a0,0x4
ffffffffc0202726:	7a650513          	addi	a0,a0,1958 # ffffffffc0206ec8 <commands+0x780>
ffffffffc020272a:	adffd0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020272e:	00005697          	auipc	a3,0x5
ffffffffc0202732:	f0268693          	addi	a3,a3,-254 # ffffffffc0207630 <commands+0xee8>
ffffffffc0202736:	00004617          	auipc	a2,0x4
ffffffffc020273a:	42260613          	addi	a2,a2,1058 # ffffffffc0206b58 <commands+0x410>
ffffffffc020273e:	0dd00593          	li	a1,221
ffffffffc0202742:	00005517          	auipc	a0,0x5
ffffffffc0202746:	dc650513          	addi	a0,a0,-570 # ffffffffc0207508 <commands+0xdc0>
ffffffffc020274a:	abffd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc020274e:	00005697          	auipc	a3,0x5
ffffffffc0202752:	e3a68693          	addi	a3,a3,-454 # ffffffffc0207588 <commands+0xe40>
ffffffffc0202756:	00004617          	auipc	a2,0x4
ffffffffc020275a:	40260613          	addi	a2,a2,1026 # ffffffffc0206b58 <commands+0x410>
ffffffffc020275e:	0c700593          	li	a1,199
ffffffffc0202762:	00005517          	auipc	a0,0x5
ffffffffc0202766:	da650513          	addi	a0,a0,-602 # ffffffffc0207508 <commands+0xdc0>
ffffffffc020276a:	a9ffd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total == nr_free_pages());
ffffffffc020276e:	00005697          	auipc	a3,0x5
ffffffffc0202772:	dd268693          	addi	a3,a3,-558 # ffffffffc0207540 <commands+0xdf8>
ffffffffc0202776:	00004617          	auipc	a2,0x4
ffffffffc020277a:	3e260613          	addi	a2,a2,994 # ffffffffc0206b58 <commands+0x410>
ffffffffc020277e:	0bf00593          	li	a1,191
ffffffffc0202782:	00005517          	auipc	a0,0x5
ffffffffc0202786:	d8650513          	addi	a0,a0,-634 # ffffffffc0207508 <commands+0xdc0>
ffffffffc020278a:	a7ffd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert( nr_free == 0);         
ffffffffc020278e:	00005697          	auipc	a3,0x5
ffffffffc0202792:	f4268693          	addi	a3,a3,-190 # ffffffffc02076d0 <commands+0xf88>
ffffffffc0202796:	00004617          	auipc	a2,0x4
ffffffffc020279a:	3c260613          	addi	a2,a2,962 # ffffffffc0206b58 <commands+0x410>
ffffffffc020279e:	0f300593          	li	a1,243
ffffffffc02027a2:	00005517          	auipc	a0,0x5
ffffffffc02027a6:	d6650513          	addi	a0,a0,-666 # ffffffffc0207508 <commands+0xdc0>
ffffffffc02027aa:	a5ffd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgdir[0] == 0);
ffffffffc02027ae:	00005697          	auipc	a3,0x5
ffffffffc02027b2:	a1268693          	addi	a3,a3,-1518 # ffffffffc02071c0 <commands+0xa78>
ffffffffc02027b6:	00004617          	auipc	a2,0x4
ffffffffc02027ba:	3a260613          	addi	a2,a2,930 # ffffffffc0206b58 <commands+0x410>
ffffffffc02027be:	0cc00593          	li	a1,204
ffffffffc02027c2:	00005517          	auipc	a0,0x5
ffffffffc02027c6:	d4650513          	addi	a0,a0,-698 # ffffffffc0207508 <commands+0xdc0>
ffffffffc02027ca:	a3ffd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(mm != NULL);
ffffffffc02027ce:	00005697          	auipc	a3,0x5
ffffffffc02027d2:	82a68693          	addi	a3,a3,-2006 # ffffffffc0206ff8 <commands+0x8b0>
ffffffffc02027d6:	00004617          	auipc	a2,0x4
ffffffffc02027da:	38260613          	addi	a2,a2,898 # ffffffffc0206b58 <commands+0x410>
ffffffffc02027de:	0c400593          	li	a1,196
ffffffffc02027e2:	00005517          	auipc	a0,0x5
ffffffffc02027e6:	d2650513          	addi	a0,a0,-730 # ffffffffc0207508 <commands+0xdc0>
ffffffffc02027ea:	a1ffd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total==0);
ffffffffc02027ee:	00005697          	auipc	a3,0x5
ffffffffc02027f2:	f7268693          	addi	a3,a3,-142 # ffffffffc0207760 <commands+0x1018>
ffffffffc02027f6:	00004617          	auipc	a2,0x4
ffffffffc02027fa:	36260613          	addi	a2,a2,866 # ffffffffc0206b58 <commands+0x410>
ffffffffc02027fe:	11e00593          	li	a1,286
ffffffffc0202802:	00005517          	auipc	a0,0x5
ffffffffc0202806:	d0650513          	addi	a0,a0,-762 # ffffffffc0207508 <commands+0xdc0>
ffffffffc020280a:	9fffd0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc020280e:	00004617          	auipc	a2,0x4
ffffffffc0202812:	71a60613          	addi	a2,a2,1818 # ffffffffc0206f28 <commands+0x7e0>
ffffffffc0202816:	06900593          	li	a1,105
ffffffffc020281a:	00004517          	auipc	a0,0x4
ffffffffc020281e:	6ae50513          	addi	a0,a0,1710 # ffffffffc0206ec8 <commands+0x780>
ffffffffc0202822:	9e7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(count==0);
ffffffffc0202826:	00005697          	auipc	a3,0x5
ffffffffc020282a:	f2a68693          	addi	a3,a3,-214 # ffffffffc0207750 <commands+0x1008>
ffffffffc020282e:	00004617          	auipc	a2,0x4
ffffffffc0202832:	32a60613          	addi	a2,a2,810 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202836:	11d00593          	li	a1,285
ffffffffc020283a:	00005517          	auipc	a0,0x5
ffffffffc020283e:	cce50513          	addi	a0,a0,-818 # ffffffffc0207508 <commands+0xdc0>
ffffffffc0202842:	9c7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc0202846:	00005697          	auipc	a3,0x5
ffffffffc020284a:	e5a68693          	addi	a3,a3,-422 # ffffffffc02076a0 <commands+0xf58>
ffffffffc020284e:	00004617          	auipc	a2,0x4
ffffffffc0202852:	30a60613          	addi	a2,a2,778 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202856:	09500593          	li	a1,149
ffffffffc020285a:	00005517          	auipc	a0,0x5
ffffffffc020285e:	cae50513          	addi	a0,a0,-850 # ffffffffc0207508 <commands+0xdc0>
ffffffffc0202862:	9a7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202866:	00005697          	auipc	a3,0x5
ffffffffc020286a:	dea68693          	addi	a3,a3,-534 # ffffffffc0207650 <commands+0xf08>
ffffffffc020286e:	00004617          	auipc	a2,0x4
ffffffffc0202872:	2ea60613          	addi	a2,a2,746 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202876:	0ea00593          	li	a1,234
ffffffffc020287a:	00005517          	auipc	a0,0x5
ffffffffc020287e:	c8e50513          	addi	a0,a0,-882 # ffffffffc0207508 <commands+0xdc0>
ffffffffc0202882:	987fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202886:	00005697          	auipc	a3,0x5
ffffffffc020288a:	d5268693          	addi	a3,a3,-686 # ffffffffc02075d8 <commands+0xe90>
ffffffffc020288e:	00004617          	auipc	a2,0x4
ffffffffc0202892:	2ca60613          	addi	a2,a2,714 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202896:	0d700593          	li	a1,215
ffffffffc020289a:	00005517          	auipc	a0,0x5
ffffffffc020289e:	c6e50513          	addi	a0,a0,-914 # ffffffffc0207508 <commands+0xdc0>
ffffffffc02028a2:	967fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(ret==0);
ffffffffc02028a6:	00005697          	auipc	a3,0x5
ffffffffc02028aa:	ea268693          	addi	a3,a3,-350 # ffffffffc0207748 <commands+0x1000>
ffffffffc02028ae:	00004617          	auipc	a2,0x4
ffffffffc02028b2:	2aa60613          	addi	a2,a2,682 # ffffffffc0206b58 <commands+0x410>
ffffffffc02028b6:	10200593          	li	a1,258
ffffffffc02028ba:	00005517          	auipc	a0,0x5
ffffffffc02028be:	c4e50513          	addi	a0,a0,-946 # ffffffffc0207508 <commands+0xdc0>
ffffffffc02028c2:	947fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(vma != NULL);
ffffffffc02028c6:	00005697          	auipc	a3,0x5
ffffffffc02028ca:	99a68693          	addi	a3,a3,-1638 # ffffffffc0207260 <commands+0xb18>
ffffffffc02028ce:	00004617          	auipc	a2,0x4
ffffffffc02028d2:	28a60613          	addi	a2,a2,650 # ffffffffc0206b58 <commands+0x410>
ffffffffc02028d6:	0cf00593          	li	a1,207
ffffffffc02028da:	00005517          	auipc	a0,0x5
ffffffffc02028de:	c2e50513          	addi	a0,a0,-978 # ffffffffc0207508 <commands+0xdc0>
ffffffffc02028e2:	927fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc02028e6:	00005697          	auipc	a3,0x5
ffffffffc02028ea:	9b268693          	addi	a3,a3,-1614 # ffffffffc0207298 <commands+0xb50>
ffffffffc02028ee:	00004617          	auipc	a2,0x4
ffffffffc02028f2:	26a60613          	addi	a2,a2,618 # ffffffffc0206b58 <commands+0x410>
ffffffffc02028f6:	09f00593          	li	a1,159
ffffffffc02028fa:	00005517          	auipc	a0,0x5
ffffffffc02028fe:	c0e50513          	addi	a0,a0,-1010 # ffffffffc0207508 <commands+0xdc0>
ffffffffc0202902:	907fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc0202906:	00005697          	auipc	a3,0x5
ffffffffc020290a:	99268693          	addi	a3,a3,-1646 # ffffffffc0207298 <commands+0xb50>
ffffffffc020290e:	00004617          	auipc	a2,0x4
ffffffffc0202912:	24a60613          	addi	a2,a2,586 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202916:	0a100593          	li	a1,161
ffffffffc020291a:	00005517          	auipc	a0,0x5
ffffffffc020291e:	bee50513          	addi	a0,a0,-1042 # ffffffffc0207508 <commands+0xdc0>
ffffffffc0202922:	8e7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc0202926:	00005697          	auipc	a3,0x5
ffffffffc020292a:	d8a68693          	addi	a3,a3,-630 # ffffffffc02076b0 <commands+0xf68>
ffffffffc020292e:	00004617          	auipc	a2,0x4
ffffffffc0202932:	22a60613          	addi	a2,a2,554 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202936:	09700593          	li	a1,151
ffffffffc020293a:	00005517          	auipc	a0,0x5
ffffffffc020293e:	bce50513          	addi	a0,a0,-1074 # ffffffffc0207508 <commands+0xdc0>
ffffffffc0202942:	8c7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc0202946:	00005697          	auipc	a3,0x5
ffffffffc020294a:	d6a68693          	addi	a3,a3,-662 # ffffffffc02076b0 <commands+0xf68>
ffffffffc020294e:	00004617          	auipc	a2,0x4
ffffffffc0202952:	20a60613          	addi	a2,a2,522 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202956:	09900593          	li	a1,153
ffffffffc020295a:	00005517          	auipc	a0,0x5
ffffffffc020295e:	bae50513          	addi	a0,a0,-1106 # ffffffffc0207508 <commands+0xdc0>
ffffffffc0202962:	8a7fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc0202966:	00005697          	auipc	a3,0x5
ffffffffc020296a:	d5a68693          	addi	a3,a3,-678 # ffffffffc02076c0 <commands+0xf78>
ffffffffc020296e:	00004617          	auipc	a2,0x4
ffffffffc0202972:	1ea60613          	addi	a2,a2,490 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202976:	09b00593          	li	a1,155
ffffffffc020297a:	00005517          	auipc	a0,0x5
ffffffffc020297e:	b8e50513          	addi	a0,a0,-1138 # ffffffffc0207508 <commands+0xdc0>
ffffffffc0202982:	887fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc0202986:	00005697          	auipc	a3,0x5
ffffffffc020298a:	d3a68693          	addi	a3,a3,-710 # ffffffffc02076c0 <commands+0xf78>
ffffffffc020298e:	00004617          	auipc	a2,0x4
ffffffffc0202992:	1ca60613          	addi	a2,a2,458 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202996:	09d00593          	li	a1,157
ffffffffc020299a:	00005517          	auipc	a0,0x5
ffffffffc020299e:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0207508 <commands+0xdc0>
ffffffffc02029a2:	867fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc02029a6:	00005697          	auipc	a3,0x5
ffffffffc02029aa:	cfa68693          	addi	a3,a3,-774 # ffffffffc02076a0 <commands+0xf58>
ffffffffc02029ae:	00004617          	auipc	a2,0x4
ffffffffc02029b2:	1aa60613          	addi	a2,a2,426 # ffffffffc0206b58 <commands+0x410>
ffffffffc02029b6:	09300593          	li	a1,147
ffffffffc02029ba:	00005517          	auipc	a0,0x5
ffffffffc02029be:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0207508 <commands+0xdc0>
ffffffffc02029c2:	847fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02029c6 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02029c6:	000b0797          	auipc	a5,0xb0
ffffffffc02029ca:	e3a7b783          	ld	a5,-454(a5) # ffffffffc02b2800 <sm>
ffffffffc02029ce:	6b9c                	ld	a5,16(a5)
ffffffffc02029d0:	8782                	jr	a5

ffffffffc02029d2 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02029d2:	000b0797          	auipc	a5,0xb0
ffffffffc02029d6:	e2e7b783          	ld	a5,-466(a5) # ffffffffc02b2800 <sm>
ffffffffc02029da:	739c                	ld	a5,32(a5)
ffffffffc02029dc:	8782                	jr	a5

ffffffffc02029de <swap_out>:
{
ffffffffc02029de:	711d                	addi	sp,sp,-96
ffffffffc02029e0:	ec86                	sd	ra,88(sp)
ffffffffc02029e2:	e8a2                	sd	s0,80(sp)
ffffffffc02029e4:	e4a6                	sd	s1,72(sp)
ffffffffc02029e6:	e0ca                	sd	s2,64(sp)
ffffffffc02029e8:	fc4e                	sd	s3,56(sp)
ffffffffc02029ea:	f852                	sd	s4,48(sp)
ffffffffc02029ec:	f456                	sd	s5,40(sp)
ffffffffc02029ee:	f05a                	sd	s6,32(sp)
ffffffffc02029f0:	ec5e                	sd	s7,24(sp)
ffffffffc02029f2:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02029f4:	cde9                	beqz	a1,ffffffffc0202ace <swap_out+0xf0>
ffffffffc02029f6:	8a2e                	mv	s4,a1
ffffffffc02029f8:	892a                	mv	s2,a0
ffffffffc02029fa:	8ab2                	mv	s5,a2
ffffffffc02029fc:	4401                	li	s0,0
ffffffffc02029fe:	000b0997          	auipc	s3,0xb0
ffffffffc0202a02:	e0298993          	addi	s3,s3,-510 # ffffffffc02b2800 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202a06:	00005b17          	auipc	s6,0x5
ffffffffc0202a0a:	deab0b13          	addi	s6,s6,-534 # ffffffffc02077f0 <commands+0x10a8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202a0e:	00005b97          	auipc	s7,0x5
ffffffffc0202a12:	dcab8b93          	addi	s7,s7,-566 # ffffffffc02077d8 <commands+0x1090>
ffffffffc0202a16:	a825                	j	ffffffffc0202a4e <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202a18:	67a2                	ld	a5,8(sp)
ffffffffc0202a1a:	8626                	mv	a2,s1
ffffffffc0202a1c:	85a2                	mv	a1,s0
ffffffffc0202a1e:	7f94                	ld	a3,56(a5)
ffffffffc0202a20:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202a22:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202a24:	82b1                	srli	a3,a3,0xc
ffffffffc0202a26:	0685                	addi	a3,a3,1
ffffffffc0202a28:	ea4fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202a2c:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202a2e:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202a30:	7d1c                	ld	a5,56(a0)
ffffffffc0202a32:	83b1                	srli	a5,a5,0xc
ffffffffc0202a34:	0785                	addi	a5,a5,1
ffffffffc0202a36:	07a2                	slli	a5,a5,0x8
ffffffffc0202a38:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202a3c:	42f000ef          	jal	ra,ffffffffc020366a <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202a40:	01893503          	ld	a0,24(s2)
ffffffffc0202a44:	85a6                	mv	a1,s1
ffffffffc0202a46:	7c9010ef          	jal	ra,ffffffffc0204a0e <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202a4a:	048a0d63          	beq	s4,s0,ffffffffc0202aa4 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202a4e:	0009b783          	ld	a5,0(s3)
ffffffffc0202a52:	8656                	mv	a2,s5
ffffffffc0202a54:	002c                	addi	a1,sp,8
ffffffffc0202a56:	7b9c                	ld	a5,48(a5)
ffffffffc0202a58:	854a                	mv	a0,s2
ffffffffc0202a5a:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202a5c:	e12d                	bnez	a0,ffffffffc0202abe <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202a5e:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202a60:	01893503          	ld	a0,24(s2)
ffffffffc0202a64:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202a66:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202a68:	85a6                	mv	a1,s1
ffffffffc0202a6a:	47b000ef          	jal	ra,ffffffffc02036e4 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202a6e:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202a70:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202a72:	8b85                	andi	a5,a5,1
ffffffffc0202a74:	cfb9                	beqz	a5,ffffffffc0202ad2 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202a76:	65a2                	ld	a1,8(sp)
ffffffffc0202a78:	7d9c                	ld	a5,56(a1)
ffffffffc0202a7a:	83b1                	srli	a5,a5,0xc
ffffffffc0202a7c:	0785                	addi	a5,a5,1
ffffffffc0202a7e:	00879513          	slli	a0,a5,0x8
ffffffffc0202a82:	084020ef          	jal	ra,ffffffffc0204b06 <swapfs_write>
ffffffffc0202a86:	d949                	beqz	a0,ffffffffc0202a18 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202a88:	855e                	mv	a0,s7
ffffffffc0202a8a:	e42fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202a8e:	0009b783          	ld	a5,0(s3)
ffffffffc0202a92:	6622                	ld	a2,8(sp)
ffffffffc0202a94:	4681                	li	a3,0
ffffffffc0202a96:	739c                	ld	a5,32(a5)
ffffffffc0202a98:	85a6                	mv	a1,s1
ffffffffc0202a9a:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202a9c:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202a9e:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202aa0:	fa8a17e3          	bne	s4,s0,ffffffffc0202a4e <swap_out+0x70>
}
ffffffffc0202aa4:	60e6                	ld	ra,88(sp)
ffffffffc0202aa6:	8522                	mv	a0,s0
ffffffffc0202aa8:	6446                	ld	s0,80(sp)
ffffffffc0202aaa:	64a6                	ld	s1,72(sp)
ffffffffc0202aac:	6906                	ld	s2,64(sp)
ffffffffc0202aae:	79e2                	ld	s3,56(sp)
ffffffffc0202ab0:	7a42                	ld	s4,48(sp)
ffffffffc0202ab2:	7aa2                	ld	s5,40(sp)
ffffffffc0202ab4:	7b02                	ld	s6,32(sp)
ffffffffc0202ab6:	6be2                	ld	s7,24(sp)
ffffffffc0202ab8:	6c42                	ld	s8,16(sp)
ffffffffc0202aba:	6125                	addi	sp,sp,96
ffffffffc0202abc:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202abe:	85a2                	mv	a1,s0
ffffffffc0202ac0:	00005517          	auipc	a0,0x5
ffffffffc0202ac4:	cd050513          	addi	a0,a0,-816 # ffffffffc0207790 <commands+0x1048>
ffffffffc0202ac8:	e04fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                  break;
ffffffffc0202acc:	bfe1                	j	ffffffffc0202aa4 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202ace:	4401                	li	s0,0
ffffffffc0202ad0:	bfd1                	j	ffffffffc0202aa4 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202ad2:	00005697          	auipc	a3,0x5
ffffffffc0202ad6:	cee68693          	addi	a3,a3,-786 # ffffffffc02077c0 <commands+0x1078>
ffffffffc0202ada:	00004617          	auipc	a2,0x4
ffffffffc0202ade:	07e60613          	addi	a2,a2,126 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202ae2:	06800593          	li	a1,104
ffffffffc0202ae6:	00005517          	auipc	a0,0x5
ffffffffc0202aea:	a2250513          	addi	a0,a0,-1502 # ffffffffc0207508 <commands+0xdc0>
ffffffffc0202aee:	f1afd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202af2 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0202af2:	000ac797          	auipc	a5,0xac
ffffffffc0202af6:	cae78793          	addi	a5,a5,-850 # ffffffffc02ae7a0 <free_area>
ffffffffc0202afa:	e79c                	sd	a5,8(a5)
ffffffffc0202afc:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0202afe:	0007a823          	sw	zero,16(a5)
}
ffffffffc0202b02:	8082                	ret

ffffffffc0202b04 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0202b04:	000ac517          	auipc	a0,0xac
ffffffffc0202b08:	cac56503          	lwu	a0,-852(a0) # ffffffffc02ae7b0 <free_area+0x10>
ffffffffc0202b0c:	8082                	ret

ffffffffc0202b0e <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0202b0e:	715d                	addi	sp,sp,-80
ffffffffc0202b10:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0202b12:	000ac417          	auipc	s0,0xac
ffffffffc0202b16:	c8e40413          	addi	s0,s0,-882 # ffffffffc02ae7a0 <free_area>
ffffffffc0202b1a:	641c                	ld	a5,8(s0)
ffffffffc0202b1c:	e486                	sd	ra,72(sp)
ffffffffc0202b1e:	fc26                	sd	s1,56(sp)
ffffffffc0202b20:	f84a                	sd	s2,48(sp)
ffffffffc0202b22:	f44e                	sd	s3,40(sp)
ffffffffc0202b24:	f052                	sd	s4,32(sp)
ffffffffc0202b26:	ec56                	sd	s5,24(sp)
ffffffffc0202b28:	e85a                	sd	s6,16(sp)
ffffffffc0202b2a:	e45e                	sd	s7,8(sp)
ffffffffc0202b2c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202b2e:	2a878d63          	beq	a5,s0,ffffffffc0202de8 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0202b32:	4481                	li	s1,0
ffffffffc0202b34:	4901                	li	s2,0
ffffffffc0202b36:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202b3a:	8b09                	andi	a4,a4,2
ffffffffc0202b3c:	2a070a63          	beqz	a4,ffffffffc0202df0 <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0202b40:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202b44:	679c                	ld	a5,8(a5)
ffffffffc0202b46:	2905                	addiw	s2,s2,1
ffffffffc0202b48:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202b4a:	fe8796e3          	bne	a5,s0,ffffffffc0202b36 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0202b4e:	89a6                	mv	s3,s1
ffffffffc0202b50:	35b000ef          	jal	ra,ffffffffc02036aa <nr_free_pages>
ffffffffc0202b54:	6f351e63          	bne	a0,s3,ffffffffc0203250 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202b58:	4505                	li	a0,1
ffffffffc0202b5a:	27f000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202b5e:	8aaa                	mv	s5,a0
ffffffffc0202b60:	42050863          	beqz	a0,ffffffffc0202f90 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202b64:	4505                	li	a0,1
ffffffffc0202b66:	273000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202b6a:	89aa                	mv	s3,a0
ffffffffc0202b6c:	70050263          	beqz	a0,ffffffffc0203270 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202b70:	4505                	li	a0,1
ffffffffc0202b72:	267000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202b76:	8a2a                	mv	s4,a0
ffffffffc0202b78:	48050c63          	beqz	a0,ffffffffc0203010 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202b7c:	293a8a63          	beq	s5,s3,ffffffffc0202e10 <default_check+0x302>
ffffffffc0202b80:	28aa8863          	beq	s5,a0,ffffffffc0202e10 <default_check+0x302>
ffffffffc0202b84:	28a98663          	beq	s3,a0,ffffffffc0202e10 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202b88:	000aa783          	lw	a5,0(s5)
ffffffffc0202b8c:	2a079263          	bnez	a5,ffffffffc0202e30 <default_check+0x322>
ffffffffc0202b90:	0009a783          	lw	a5,0(s3)
ffffffffc0202b94:	28079e63          	bnez	a5,ffffffffc0202e30 <default_check+0x322>
ffffffffc0202b98:	411c                	lw	a5,0(a0)
ffffffffc0202b9a:	28079b63          	bnez	a5,ffffffffc0202e30 <default_check+0x322>
    return page - pages + nbase;
ffffffffc0202b9e:	000b0797          	auipc	a5,0xb0
ffffffffc0202ba2:	c8a7b783          	ld	a5,-886(a5) # ffffffffc02b2828 <pages>
ffffffffc0202ba6:	40fa8733          	sub	a4,s5,a5
ffffffffc0202baa:	00006617          	auipc	a2,0x6
ffffffffc0202bae:	ee663603          	ld	a2,-282(a2) # ffffffffc0208a90 <nbase>
ffffffffc0202bb2:	8719                	srai	a4,a4,0x6
ffffffffc0202bb4:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202bb6:	000b0697          	auipc	a3,0xb0
ffffffffc0202bba:	c6a6b683          	ld	a3,-918(a3) # ffffffffc02b2820 <npage>
ffffffffc0202bbe:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202bc0:	0732                	slli	a4,a4,0xc
ffffffffc0202bc2:	28d77763          	bgeu	a4,a3,ffffffffc0202e50 <default_check+0x342>
    return page - pages + nbase;
ffffffffc0202bc6:	40f98733          	sub	a4,s3,a5
ffffffffc0202bca:	8719                	srai	a4,a4,0x6
ffffffffc0202bcc:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202bce:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202bd0:	4cd77063          	bgeu	a4,a3,ffffffffc0203090 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0202bd4:	40f507b3          	sub	a5,a0,a5
ffffffffc0202bd8:	8799                	srai	a5,a5,0x6
ffffffffc0202bda:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202bdc:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202bde:	30d7f963          	bgeu	a5,a3,ffffffffc0202ef0 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0202be2:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202be4:	00043c03          	ld	s8,0(s0)
ffffffffc0202be8:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0202bec:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0202bf0:	e400                	sd	s0,8(s0)
ffffffffc0202bf2:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0202bf4:	000ac797          	auipc	a5,0xac
ffffffffc0202bf8:	ba07ae23          	sw	zero,-1092(a5) # ffffffffc02ae7b0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202bfc:	1dd000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202c00:	2c051863          	bnez	a0,ffffffffc0202ed0 <default_check+0x3c2>
    free_page(p0);
ffffffffc0202c04:	4585                	li	a1,1
ffffffffc0202c06:	8556                	mv	a0,s5
ffffffffc0202c08:	263000ef          	jal	ra,ffffffffc020366a <free_pages>
    free_page(p1);
ffffffffc0202c0c:	4585                	li	a1,1
ffffffffc0202c0e:	854e                	mv	a0,s3
ffffffffc0202c10:	25b000ef          	jal	ra,ffffffffc020366a <free_pages>
    free_page(p2);
ffffffffc0202c14:	4585                	li	a1,1
ffffffffc0202c16:	8552                	mv	a0,s4
ffffffffc0202c18:	253000ef          	jal	ra,ffffffffc020366a <free_pages>
    assert(nr_free == 3);
ffffffffc0202c1c:	4818                	lw	a4,16(s0)
ffffffffc0202c1e:	478d                	li	a5,3
ffffffffc0202c20:	28f71863          	bne	a4,a5,ffffffffc0202eb0 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202c24:	4505                	li	a0,1
ffffffffc0202c26:	1b3000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202c2a:	89aa                	mv	s3,a0
ffffffffc0202c2c:	26050263          	beqz	a0,ffffffffc0202e90 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202c30:	4505                	li	a0,1
ffffffffc0202c32:	1a7000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202c36:	8aaa                	mv	s5,a0
ffffffffc0202c38:	3a050c63          	beqz	a0,ffffffffc0202ff0 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202c3c:	4505                	li	a0,1
ffffffffc0202c3e:	19b000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202c42:	8a2a                	mv	s4,a0
ffffffffc0202c44:	38050663          	beqz	a0,ffffffffc0202fd0 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0202c48:	4505                	li	a0,1
ffffffffc0202c4a:	18f000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202c4e:	36051163          	bnez	a0,ffffffffc0202fb0 <default_check+0x4a2>
    free_page(p0);
ffffffffc0202c52:	4585                	li	a1,1
ffffffffc0202c54:	854e                	mv	a0,s3
ffffffffc0202c56:	215000ef          	jal	ra,ffffffffc020366a <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202c5a:	641c                	ld	a5,8(s0)
ffffffffc0202c5c:	20878a63          	beq	a5,s0,ffffffffc0202e70 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0202c60:	4505                	li	a0,1
ffffffffc0202c62:	177000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202c66:	30a99563          	bne	s3,a0,ffffffffc0202f70 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0202c6a:	4505                	li	a0,1
ffffffffc0202c6c:	16d000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202c70:	2e051063          	bnez	a0,ffffffffc0202f50 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0202c74:	481c                	lw	a5,16(s0)
ffffffffc0202c76:	2a079d63          	bnez	a5,ffffffffc0202f30 <default_check+0x422>
    free_page(p);
ffffffffc0202c7a:	854e                	mv	a0,s3
ffffffffc0202c7c:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202c7e:	01843023          	sd	s8,0(s0)
ffffffffc0202c82:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0202c86:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0202c8a:	1e1000ef          	jal	ra,ffffffffc020366a <free_pages>
    free_page(p1);
ffffffffc0202c8e:	4585                	li	a1,1
ffffffffc0202c90:	8556                	mv	a0,s5
ffffffffc0202c92:	1d9000ef          	jal	ra,ffffffffc020366a <free_pages>
    free_page(p2);
ffffffffc0202c96:	4585                	li	a1,1
ffffffffc0202c98:	8552                	mv	a0,s4
ffffffffc0202c9a:	1d1000ef          	jal	ra,ffffffffc020366a <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202c9e:	4515                	li	a0,5
ffffffffc0202ca0:	139000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202ca4:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202ca6:	26050563          	beqz	a0,ffffffffc0202f10 <default_check+0x402>
ffffffffc0202caa:	651c                	ld	a5,8(a0)
ffffffffc0202cac:	8385                	srli	a5,a5,0x1
ffffffffc0202cae:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0202cb0:	54079063          	bnez	a5,ffffffffc02031f0 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202cb4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202cb6:	00043b03          	ld	s6,0(s0)
ffffffffc0202cba:	00843a83          	ld	s5,8(s0)
ffffffffc0202cbe:	e000                	sd	s0,0(s0)
ffffffffc0202cc0:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0202cc2:	117000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202cc6:	50051563          	bnez	a0,ffffffffc02031d0 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202cca:	08098a13          	addi	s4,s3,128
ffffffffc0202cce:	8552                	mv	a0,s4
ffffffffc0202cd0:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202cd2:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0202cd6:	000ac797          	auipc	a5,0xac
ffffffffc0202cda:	ac07ad23          	sw	zero,-1318(a5) # ffffffffc02ae7b0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202cde:	18d000ef          	jal	ra,ffffffffc020366a <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0202ce2:	4511                	li	a0,4
ffffffffc0202ce4:	0f5000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202ce8:	4c051463          	bnez	a0,ffffffffc02031b0 <default_check+0x6a2>
ffffffffc0202cec:	0889b783          	ld	a5,136(s3)
ffffffffc0202cf0:	8385                	srli	a5,a5,0x1
ffffffffc0202cf2:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202cf4:	48078e63          	beqz	a5,ffffffffc0203190 <default_check+0x682>
ffffffffc0202cf8:	0909a703          	lw	a4,144(s3)
ffffffffc0202cfc:	478d                	li	a5,3
ffffffffc0202cfe:	48f71963          	bne	a4,a5,ffffffffc0203190 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202d02:	450d                	li	a0,3
ffffffffc0202d04:	0d5000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202d08:	8c2a                	mv	s8,a0
ffffffffc0202d0a:	46050363          	beqz	a0,ffffffffc0203170 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0202d0e:	4505                	li	a0,1
ffffffffc0202d10:	0c9000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202d14:	42051e63          	bnez	a0,ffffffffc0203150 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0202d18:	418a1c63          	bne	s4,s8,ffffffffc0203130 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0202d1c:	4585                	li	a1,1
ffffffffc0202d1e:	854e                	mv	a0,s3
ffffffffc0202d20:	14b000ef          	jal	ra,ffffffffc020366a <free_pages>
    free_pages(p1, 3);
ffffffffc0202d24:	458d                	li	a1,3
ffffffffc0202d26:	8552                	mv	a0,s4
ffffffffc0202d28:	143000ef          	jal	ra,ffffffffc020366a <free_pages>
ffffffffc0202d2c:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202d30:	04098c13          	addi	s8,s3,64
ffffffffc0202d34:	8385                	srli	a5,a5,0x1
ffffffffc0202d36:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202d38:	3c078c63          	beqz	a5,ffffffffc0203110 <default_check+0x602>
ffffffffc0202d3c:	0109a703          	lw	a4,16(s3)
ffffffffc0202d40:	4785                	li	a5,1
ffffffffc0202d42:	3cf71763          	bne	a4,a5,ffffffffc0203110 <default_check+0x602>
ffffffffc0202d46:	008a3783          	ld	a5,8(s4)
ffffffffc0202d4a:	8385                	srli	a5,a5,0x1
ffffffffc0202d4c:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202d4e:	3a078163          	beqz	a5,ffffffffc02030f0 <default_check+0x5e2>
ffffffffc0202d52:	010a2703          	lw	a4,16(s4)
ffffffffc0202d56:	478d                	li	a5,3
ffffffffc0202d58:	38f71c63          	bne	a4,a5,ffffffffc02030f0 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202d5c:	4505                	li	a0,1
ffffffffc0202d5e:	07b000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202d62:	36a99763          	bne	s3,a0,ffffffffc02030d0 <default_check+0x5c2>
    free_page(p0);
ffffffffc0202d66:	4585                	li	a1,1
ffffffffc0202d68:	103000ef          	jal	ra,ffffffffc020366a <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202d6c:	4509                	li	a0,2
ffffffffc0202d6e:	06b000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202d72:	32aa1f63          	bne	s4,a0,ffffffffc02030b0 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0202d76:	4589                	li	a1,2
ffffffffc0202d78:	0f3000ef          	jal	ra,ffffffffc020366a <free_pages>
    free_page(p2);
ffffffffc0202d7c:	4585                	li	a1,1
ffffffffc0202d7e:	8562                	mv	a0,s8
ffffffffc0202d80:	0eb000ef          	jal	ra,ffffffffc020366a <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202d84:	4515                	li	a0,5
ffffffffc0202d86:	053000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202d8a:	89aa                	mv	s3,a0
ffffffffc0202d8c:	48050263          	beqz	a0,ffffffffc0203210 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0202d90:	4505                	li	a0,1
ffffffffc0202d92:	047000ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0202d96:	2c051d63          	bnez	a0,ffffffffc0203070 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0202d9a:	481c                	lw	a5,16(s0)
ffffffffc0202d9c:	2a079a63          	bnez	a5,ffffffffc0203050 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0202da0:	4595                	li	a1,5
ffffffffc0202da2:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0202da4:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0202da8:	01643023          	sd	s6,0(s0)
ffffffffc0202dac:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0202db0:	0bb000ef          	jal	ra,ffffffffc020366a <free_pages>
    return listelm->next;
ffffffffc0202db4:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202db6:	00878963          	beq	a5,s0,ffffffffc0202dc8 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0202dba:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202dbe:	679c                	ld	a5,8(a5)
ffffffffc0202dc0:	397d                	addiw	s2,s2,-1
ffffffffc0202dc2:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202dc4:	fe879be3          	bne	a5,s0,ffffffffc0202dba <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0202dc8:	26091463          	bnez	s2,ffffffffc0203030 <default_check+0x522>
    assert(total == 0);
ffffffffc0202dcc:	46049263          	bnez	s1,ffffffffc0203230 <default_check+0x722>
}
ffffffffc0202dd0:	60a6                	ld	ra,72(sp)
ffffffffc0202dd2:	6406                	ld	s0,64(sp)
ffffffffc0202dd4:	74e2                	ld	s1,56(sp)
ffffffffc0202dd6:	7942                	ld	s2,48(sp)
ffffffffc0202dd8:	79a2                	ld	s3,40(sp)
ffffffffc0202dda:	7a02                	ld	s4,32(sp)
ffffffffc0202ddc:	6ae2                	ld	s5,24(sp)
ffffffffc0202dde:	6b42                	ld	s6,16(sp)
ffffffffc0202de0:	6ba2                	ld	s7,8(sp)
ffffffffc0202de2:	6c02                	ld	s8,0(sp)
ffffffffc0202de4:	6161                	addi	sp,sp,80
ffffffffc0202de6:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202de8:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0202dea:	4481                	li	s1,0
ffffffffc0202dec:	4901                	li	s2,0
ffffffffc0202dee:	b38d                	j	ffffffffc0202b50 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0202df0:	00004697          	auipc	a3,0x4
ffffffffc0202df4:	74068693          	addi	a3,a3,1856 # ffffffffc0207530 <commands+0xde8>
ffffffffc0202df8:	00004617          	auipc	a2,0x4
ffffffffc0202dfc:	d6060613          	addi	a2,a2,-672 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202e00:	0f000593          	li	a1,240
ffffffffc0202e04:	00005517          	auipc	a0,0x5
ffffffffc0202e08:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0207830 <commands+0x10e8>
ffffffffc0202e0c:	bfcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202e10:	00005697          	auipc	a3,0x5
ffffffffc0202e14:	a9868693          	addi	a3,a3,-1384 # ffffffffc02078a8 <commands+0x1160>
ffffffffc0202e18:	00004617          	auipc	a2,0x4
ffffffffc0202e1c:	d4060613          	addi	a2,a2,-704 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202e20:	0bd00593          	li	a1,189
ffffffffc0202e24:	00005517          	auipc	a0,0x5
ffffffffc0202e28:	a0c50513          	addi	a0,a0,-1524 # ffffffffc0207830 <commands+0x10e8>
ffffffffc0202e2c:	bdcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202e30:	00005697          	auipc	a3,0x5
ffffffffc0202e34:	aa068693          	addi	a3,a3,-1376 # ffffffffc02078d0 <commands+0x1188>
ffffffffc0202e38:	00004617          	auipc	a2,0x4
ffffffffc0202e3c:	d2060613          	addi	a2,a2,-736 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202e40:	0be00593          	li	a1,190
ffffffffc0202e44:	00005517          	auipc	a0,0x5
ffffffffc0202e48:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0207830 <commands+0x10e8>
ffffffffc0202e4c:	bbcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202e50:	00005697          	auipc	a3,0x5
ffffffffc0202e54:	ac068693          	addi	a3,a3,-1344 # ffffffffc0207910 <commands+0x11c8>
ffffffffc0202e58:	00004617          	auipc	a2,0x4
ffffffffc0202e5c:	d0060613          	addi	a2,a2,-768 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202e60:	0c000593          	li	a1,192
ffffffffc0202e64:	00005517          	auipc	a0,0x5
ffffffffc0202e68:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0207830 <commands+0x10e8>
ffffffffc0202e6c:	b9cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202e70:	00005697          	auipc	a3,0x5
ffffffffc0202e74:	b2868693          	addi	a3,a3,-1240 # ffffffffc0207998 <commands+0x1250>
ffffffffc0202e78:	00004617          	auipc	a2,0x4
ffffffffc0202e7c:	ce060613          	addi	a2,a2,-800 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202e80:	0d900593          	li	a1,217
ffffffffc0202e84:	00005517          	auipc	a0,0x5
ffffffffc0202e88:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0207830 <commands+0x10e8>
ffffffffc0202e8c:	b7cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202e90:	00005697          	auipc	a3,0x5
ffffffffc0202e94:	9b868693          	addi	a3,a3,-1608 # ffffffffc0207848 <commands+0x1100>
ffffffffc0202e98:	00004617          	auipc	a2,0x4
ffffffffc0202e9c:	cc060613          	addi	a2,a2,-832 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202ea0:	0d200593          	li	a1,210
ffffffffc0202ea4:	00005517          	auipc	a0,0x5
ffffffffc0202ea8:	98c50513          	addi	a0,a0,-1652 # ffffffffc0207830 <commands+0x10e8>
ffffffffc0202eac:	b5cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 3);
ffffffffc0202eb0:	00005697          	auipc	a3,0x5
ffffffffc0202eb4:	ad868693          	addi	a3,a3,-1320 # ffffffffc0207988 <commands+0x1240>
ffffffffc0202eb8:	00004617          	auipc	a2,0x4
ffffffffc0202ebc:	ca060613          	addi	a2,a2,-864 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202ec0:	0d000593          	li	a1,208
ffffffffc0202ec4:	00005517          	auipc	a0,0x5
ffffffffc0202ec8:	96c50513          	addi	a0,a0,-1684 # ffffffffc0207830 <commands+0x10e8>
ffffffffc0202ecc:	b3cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202ed0:	00005697          	auipc	a3,0x5
ffffffffc0202ed4:	aa068693          	addi	a3,a3,-1376 # ffffffffc0207970 <commands+0x1228>
ffffffffc0202ed8:	00004617          	auipc	a2,0x4
ffffffffc0202edc:	c8060613          	addi	a2,a2,-896 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202ee0:	0cb00593          	li	a1,203
ffffffffc0202ee4:	00005517          	auipc	a0,0x5
ffffffffc0202ee8:	94c50513          	addi	a0,a0,-1716 # ffffffffc0207830 <commands+0x10e8>
ffffffffc0202eec:	b1cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202ef0:	00005697          	auipc	a3,0x5
ffffffffc0202ef4:	a6068693          	addi	a3,a3,-1440 # ffffffffc0207950 <commands+0x1208>
ffffffffc0202ef8:	00004617          	auipc	a2,0x4
ffffffffc0202efc:	c6060613          	addi	a2,a2,-928 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202f00:	0c200593          	li	a1,194
ffffffffc0202f04:	00005517          	auipc	a0,0x5
ffffffffc0202f08:	92c50513          	addi	a0,a0,-1748 # ffffffffc0207830 <commands+0x10e8>
ffffffffc0202f0c:	afcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != NULL);
ffffffffc0202f10:	00005697          	auipc	a3,0x5
ffffffffc0202f14:	ac068693          	addi	a3,a3,-1344 # ffffffffc02079d0 <commands+0x1288>
ffffffffc0202f18:	00004617          	auipc	a2,0x4
ffffffffc0202f1c:	c4060613          	addi	a2,a2,-960 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202f20:	0f800593          	li	a1,248
ffffffffc0202f24:	00005517          	auipc	a0,0x5
ffffffffc0202f28:	90c50513          	addi	a0,a0,-1780 # ffffffffc0207830 <commands+0x10e8>
ffffffffc0202f2c:	adcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc0202f30:	00004697          	auipc	a3,0x4
ffffffffc0202f34:	7a068693          	addi	a3,a3,1952 # ffffffffc02076d0 <commands+0xf88>
ffffffffc0202f38:	00004617          	auipc	a2,0x4
ffffffffc0202f3c:	c2060613          	addi	a2,a2,-992 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202f40:	0df00593          	li	a1,223
ffffffffc0202f44:	00005517          	auipc	a0,0x5
ffffffffc0202f48:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0207830 <commands+0x10e8>
ffffffffc0202f4c:	abcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202f50:	00005697          	auipc	a3,0x5
ffffffffc0202f54:	a2068693          	addi	a3,a3,-1504 # ffffffffc0207970 <commands+0x1228>
ffffffffc0202f58:	00004617          	auipc	a2,0x4
ffffffffc0202f5c:	c0060613          	addi	a2,a2,-1024 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202f60:	0dd00593          	li	a1,221
ffffffffc0202f64:	00005517          	auipc	a0,0x5
ffffffffc0202f68:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0207830 <commands+0x10e8>
ffffffffc0202f6c:	a9cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202f70:	00005697          	auipc	a3,0x5
ffffffffc0202f74:	a4068693          	addi	a3,a3,-1472 # ffffffffc02079b0 <commands+0x1268>
ffffffffc0202f78:	00004617          	auipc	a2,0x4
ffffffffc0202f7c:	be060613          	addi	a2,a2,-1056 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202f80:	0dc00593          	li	a1,220
ffffffffc0202f84:	00005517          	auipc	a0,0x5
ffffffffc0202f88:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0207830 <commands+0x10e8>
ffffffffc0202f8c:	a7cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202f90:	00005697          	auipc	a3,0x5
ffffffffc0202f94:	8b868693          	addi	a3,a3,-1864 # ffffffffc0207848 <commands+0x1100>
ffffffffc0202f98:	00004617          	auipc	a2,0x4
ffffffffc0202f9c:	bc060613          	addi	a2,a2,-1088 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202fa0:	0b900593          	li	a1,185
ffffffffc0202fa4:	00005517          	auipc	a0,0x5
ffffffffc0202fa8:	88c50513          	addi	a0,a0,-1908 # ffffffffc0207830 <commands+0x10e8>
ffffffffc0202fac:	a5cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202fb0:	00005697          	auipc	a3,0x5
ffffffffc0202fb4:	9c068693          	addi	a3,a3,-1600 # ffffffffc0207970 <commands+0x1228>
ffffffffc0202fb8:	00004617          	auipc	a2,0x4
ffffffffc0202fbc:	ba060613          	addi	a2,a2,-1120 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202fc0:	0d600593          	li	a1,214
ffffffffc0202fc4:	00005517          	auipc	a0,0x5
ffffffffc0202fc8:	86c50513          	addi	a0,a0,-1940 # ffffffffc0207830 <commands+0x10e8>
ffffffffc0202fcc:	a3cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202fd0:	00005697          	auipc	a3,0x5
ffffffffc0202fd4:	8b868693          	addi	a3,a3,-1864 # ffffffffc0207888 <commands+0x1140>
ffffffffc0202fd8:	00004617          	auipc	a2,0x4
ffffffffc0202fdc:	b8060613          	addi	a2,a2,-1152 # ffffffffc0206b58 <commands+0x410>
ffffffffc0202fe0:	0d400593          	li	a1,212
ffffffffc0202fe4:	00005517          	auipc	a0,0x5
ffffffffc0202fe8:	84c50513          	addi	a0,a0,-1972 # ffffffffc0207830 <commands+0x10e8>
ffffffffc0202fec:	a1cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202ff0:	00005697          	auipc	a3,0x5
ffffffffc0202ff4:	87868693          	addi	a3,a3,-1928 # ffffffffc0207868 <commands+0x1120>
ffffffffc0202ff8:	00004617          	auipc	a2,0x4
ffffffffc0202ffc:	b6060613          	addi	a2,a2,-1184 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203000:	0d300593          	li	a1,211
ffffffffc0203004:	00005517          	auipc	a0,0x5
ffffffffc0203008:	82c50513          	addi	a0,a0,-2004 # ffffffffc0207830 <commands+0x10e8>
ffffffffc020300c:	9fcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203010:	00005697          	auipc	a3,0x5
ffffffffc0203014:	87868693          	addi	a3,a3,-1928 # ffffffffc0207888 <commands+0x1140>
ffffffffc0203018:	00004617          	auipc	a2,0x4
ffffffffc020301c:	b4060613          	addi	a2,a2,-1216 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203020:	0bb00593          	li	a1,187
ffffffffc0203024:	00005517          	auipc	a0,0x5
ffffffffc0203028:	80c50513          	addi	a0,a0,-2036 # ffffffffc0207830 <commands+0x10e8>
ffffffffc020302c:	9dcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(count == 0);
ffffffffc0203030:	00005697          	auipc	a3,0x5
ffffffffc0203034:	af068693          	addi	a3,a3,-1296 # ffffffffc0207b20 <commands+0x13d8>
ffffffffc0203038:	00004617          	auipc	a2,0x4
ffffffffc020303c:	b2060613          	addi	a2,a2,-1248 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203040:	12500593          	li	a1,293
ffffffffc0203044:	00004517          	auipc	a0,0x4
ffffffffc0203048:	7ec50513          	addi	a0,a0,2028 # ffffffffc0207830 <commands+0x10e8>
ffffffffc020304c:	9bcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc0203050:	00004697          	auipc	a3,0x4
ffffffffc0203054:	68068693          	addi	a3,a3,1664 # ffffffffc02076d0 <commands+0xf88>
ffffffffc0203058:	00004617          	auipc	a2,0x4
ffffffffc020305c:	b0060613          	addi	a2,a2,-1280 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203060:	11a00593          	li	a1,282
ffffffffc0203064:	00004517          	auipc	a0,0x4
ffffffffc0203068:	7cc50513          	addi	a0,a0,1996 # ffffffffc0207830 <commands+0x10e8>
ffffffffc020306c:	99cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203070:	00005697          	auipc	a3,0x5
ffffffffc0203074:	90068693          	addi	a3,a3,-1792 # ffffffffc0207970 <commands+0x1228>
ffffffffc0203078:	00004617          	auipc	a2,0x4
ffffffffc020307c:	ae060613          	addi	a2,a2,-1312 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203080:	11800593          	li	a1,280
ffffffffc0203084:	00004517          	auipc	a0,0x4
ffffffffc0203088:	7ac50513          	addi	a0,a0,1964 # ffffffffc0207830 <commands+0x10e8>
ffffffffc020308c:	97cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0203090:	00005697          	auipc	a3,0x5
ffffffffc0203094:	8a068693          	addi	a3,a3,-1888 # ffffffffc0207930 <commands+0x11e8>
ffffffffc0203098:	00004617          	auipc	a2,0x4
ffffffffc020309c:	ac060613          	addi	a2,a2,-1344 # ffffffffc0206b58 <commands+0x410>
ffffffffc02030a0:	0c100593          	li	a1,193
ffffffffc02030a4:	00004517          	auipc	a0,0x4
ffffffffc02030a8:	78c50513          	addi	a0,a0,1932 # ffffffffc0207830 <commands+0x10e8>
ffffffffc02030ac:	95cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02030b0:	00005697          	auipc	a3,0x5
ffffffffc02030b4:	a3068693          	addi	a3,a3,-1488 # ffffffffc0207ae0 <commands+0x1398>
ffffffffc02030b8:	00004617          	auipc	a2,0x4
ffffffffc02030bc:	aa060613          	addi	a2,a2,-1376 # ffffffffc0206b58 <commands+0x410>
ffffffffc02030c0:	11200593          	li	a1,274
ffffffffc02030c4:	00004517          	auipc	a0,0x4
ffffffffc02030c8:	76c50513          	addi	a0,a0,1900 # ffffffffc0207830 <commands+0x10e8>
ffffffffc02030cc:	93cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02030d0:	00005697          	auipc	a3,0x5
ffffffffc02030d4:	9f068693          	addi	a3,a3,-1552 # ffffffffc0207ac0 <commands+0x1378>
ffffffffc02030d8:	00004617          	auipc	a2,0x4
ffffffffc02030dc:	a8060613          	addi	a2,a2,-1408 # ffffffffc0206b58 <commands+0x410>
ffffffffc02030e0:	11000593          	li	a1,272
ffffffffc02030e4:	00004517          	auipc	a0,0x4
ffffffffc02030e8:	74c50513          	addi	a0,a0,1868 # ffffffffc0207830 <commands+0x10e8>
ffffffffc02030ec:	91cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02030f0:	00005697          	auipc	a3,0x5
ffffffffc02030f4:	9a868693          	addi	a3,a3,-1624 # ffffffffc0207a98 <commands+0x1350>
ffffffffc02030f8:	00004617          	auipc	a2,0x4
ffffffffc02030fc:	a6060613          	addi	a2,a2,-1440 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203100:	10e00593          	li	a1,270
ffffffffc0203104:	00004517          	auipc	a0,0x4
ffffffffc0203108:	72c50513          	addi	a0,a0,1836 # ffffffffc0207830 <commands+0x10e8>
ffffffffc020310c:	8fcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203110:	00005697          	auipc	a3,0x5
ffffffffc0203114:	96068693          	addi	a3,a3,-1696 # ffffffffc0207a70 <commands+0x1328>
ffffffffc0203118:	00004617          	auipc	a2,0x4
ffffffffc020311c:	a4060613          	addi	a2,a2,-1472 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203120:	10d00593          	li	a1,269
ffffffffc0203124:	00004517          	auipc	a0,0x4
ffffffffc0203128:	70c50513          	addi	a0,a0,1804 # ffffffffc0207830 <commands+0x10e8>
ffffffffc020312c:	8dcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0203130:	00005697          	auipc	a3,0x5
ffffffffc0203134:	93068693          	addi	a3,a3,-1744 # ffffffffc0207a60 <commands+0x1318>
ffffffffc0203138:	00004617          	auipc	a2,0x4
ffffffffc020313c:	a2060613          	addi	a2,a2,-1504 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203140:	10800593          	li	a1,264
ffffffffc0203144:	00004517          	auipc	a0,0x4
ffffffffc0203148:	6ec50513          	addi	a0,a0,1772 # ffffffffc0207830 <commands+0x10e8>
ffffffffc020314c:	8bcfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203150:	00005697          	auipc	a3,0x5
ffffffffc0203154:	82068693          	addi	a3,a3,-2016 # ffffffffc0207970 <commands+0x1228>
ffffffffc0203158:	00004617          	auipc	a2,0x4
ffffffffc020315c:	a0060613          	addi	a2,a2,-1536 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203160:	10700593          	li	a1,263
ffffffffc0203164:	00004517          	auipc	a0,0x4
ffffffffc0203168:	6cc50513          	addi	a0,a0,1740 # ffffffffc0207830 <commands+0x10e8>
ffffffffc020316c:	89cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203170:	00005697          	auipc	a3,0x5
ffffffffc0203174:	8d068693          	addi	a3,a3,-1840 # ffffffffc0207a40 <commands+0x12f8>
ffffffffc0203178:	00004617          	auipc	a2,0x4
ffffffffc020317c:	9e060613          	addi	a2,a2,-1568 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203180:	10600593          	li	a1,262
ffffffffc0203184:	00004517          	auipc	a0,0x4
ffffffffc0203188:	6ac50513          	addi	a0,a0,1708 # ffffffffc0207830 <commands+0x10e8>
ffffffffc020318c:	87cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203190:	00005697          	auipc	a3,0x5
ffffffffc0203194:	88068693          	addi	a3,a3,-1920 # ffffffffc0207a10 <commands+0x12c8>
ffffffffc0203198:	00004617          	auipc	a2,0x4
ffffffffc020319c:	9c060613          	addi	a2,a2,-1600 # ffffffffc0206b58 <commands+0x410>
ffffffffc02031a0:	10500593          	li	a1,261
ffffffffc02031a4:	00004517          	auipc	a0,0x4
ffffffffc02031a8:	68c50513          	addi	a0,a0,1676 # ffffffffc0207830 <commands+0x10e8>
ffffffffc02031ac:	85cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02031b0:	00005697          	auipc	a3,0x5
ffffffffc02031b4:	84868693          	addi	a3,a3,-1976 # ffffffffc02079f8 <commands+0x12b0>
ffffffffc02031b8:	00004617          	auipc	a2,0x4
ffffffffc02031bc:	9a060613          	addi	a2,a2,-1632 # ffffffffc0206b58 <commands+0x410>
ffffffffc02031c0:	10400593          	li	a1,260
ffffffffc02031c4:	00004517          	auipc	a0,0x4
ffffffffc02031c8:	66c50513          	addi	a0,a0,1644 # ffffffffc0207830 <commands+0x10e8>
ffffffffc02031cc:	83cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02031d0:	00004697          	auipc	a3,0x4
ffffffffc02031d4:	7a068693          	addi	a3,a3,1952 # ffffffffc0207970 <commands+0x1228>
ffffffffc02031d8:	00004617          	auipc	a2,0x4
ffffffffc02031dc:	98060613          	addi	a2,a2,-1664 # ffffffffc0206b58 <commands+0x410>
ffffffffc02031e0:	0fe00593          	li	a1,254
ffffffffc02031e4:	00004517          	auipc	a0,0x4
ffffffffc02031e8:	64c50513          	addi	a0,a0,1612 # ffffffffc0207830 <commands+0x10e8>
ffffffffc02031ec:	81cfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!PageProperty(p0));
ffffffffc02031f0:	00004697          	auipc	a3,0x4
ffffffffc02031f4:	7f068693          	addi	a3,a3,2032 # ffffffffc02079e0 <commands+0x1298>
ffffffffc02031f8:	00004617          	auipc	a2,0x4
ffffffffc02031fc:	96060613          	addi	a2,a2,-1696 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203200:	0f900593          	li	a1,249
ffffffffc0203204:	00004517          	auipc	a0,0x4
ffffffffc0203208:	62c50513          	addi	a0,a0,1580 # ffffffffc0207830 <commands+0x10e8>
ffffffffc020320c:	ffdfc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203210:	00005697          	auipc	a3,0x5
ffffffffc0203214:	8f068693          	addi	a3,a3,-1808 # ffffffffc0207b00 <commands+0x13b8>
ffffffffc0203218:	00004617          	auipc	a2,0x4
ffffffffc020321c:	94060613          	addi	a2,a2,-1728 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203220:	11700593          	li	a1,279
ffffffffc0203224:	00004517          	auipc	a0,0x4
ffffffffc0203228:	60c50513          	addi	a0,a0,1548 # ffffffffc0207830 <commands+0x10e8>
ffffffffc020322c:	fddfc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == 0);
ffffffffc0203230:	00005697          	auipc	a3,0x5
ffffffffc0203234:	90068693          	addi	a3,a3,-1792 # ffffffffc0207b30 <commands+0x13e8>
ffffffffc0203238:	00004617          	auipc	a2,0x4
ffffffffc020323c:	92060613          	addi	a2,a2,-1760 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203240:	12600593          	li	a1,294
ffffffffc0203244:	00004517          	auipc	a0,0x4
ffffffffc0203248:	5ec50513          	addi	a0,a0,1516 # ffffffffc0207830 <commands+0x10e8>
ffffffffc020324c:	fbdfc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == nr_free_pages());
ffffffffc0203250:	00004697          	auipc	a3,0x4
ffffffffc0203254:	2f068693          	addi	a3,a3,752 # ffffffffc0207540 <commands+0xdf8>
ffffffffc0203258:	00004617          	auipc	a2,0x4
ffffffffc020325c:	90060613          	addi	a2,a2,-1792 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203260:	0f300593          	li	a1,243
ffffffffc0203264:	00004517          	auipc	a0,0x4
ffffffffc0203268:	5cc50513          	addi	a0,a0,1484 # ffffffffc0207830 <commands+0x10e8>
ffffffffc020326c:	f9dfc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203270:	00004697          	auipc	a3,0x4
ffffffffc0203274:	5f868693          	addi	a3,a3,1528 # ffffffffc0207868 <commands+0x1120>
ffffffffc0203278:	00004617          	auipc	a2,0x4
ffffffffc020327c:	8e060613          	addi	a2,a2,-1824 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203280:	0ba00593          	li	a1,186
ffffffffc0203284:	00004517          	auipc	a0,0x4
ffffffffc0203288:	5ac50513          	addi	a0,a0,1452 # ffffffffc0207830 <commands+0x10e8>
ffffffffc020328c:	f7dfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203290 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0203290:	1141                	addi	sp,sp,-16
ffffffffc0203292:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203294:	14058463          	beqz	a1,ffffffffc02033dc <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0203298:	00659693          	slli	a3,a1,0x6
ffffffffc020329c:	96aa                	add	a3,a3,a0
ffffffffc020329e:	87aa                	mv	a5,a0
ffffffffc02032a0:	02d50263          	beq	a0,a3,ffffffffc02032c4 <default_free_pages+0x34>
ffffffffc02032a4:	6798                	ld	a4,8(a5)
ffffffffc02032a6:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02032a8:	10071a63          	bnez	a4,ffffffffc02033bc <default_free_pages+0x12c>
ffffffffc02032ac:	6798                	ld	a4,8(a5)
ffffffffc02032ae:	8b09                	andi	a4,a4,2
ffffffffc02032b0:	10071663          	bnez	a4,ffffffffc02033bc <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc02032b4:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc02032b8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02032bc:	04078793          	addi	a5,a5,64
ffffffffc02032c0:	fed792e3          	bne	a5,a3,ffffffffc02032a4 <default_free_pages+0x14>
    base->property = n;
ffffffffc02032c4:	2581                	sext.w	a1,a1
ffffffffc02032c6:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02032c8:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02032cc:	4789                	li	a5,2
ffffffffc02032ce:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02032d2:	000ab697          	auipc	a3,0xab
ffffffffc02032d6:	4ce68693          	addi	a3,a3,1230 # ffffffffc02ae7a0 <free_area>
ffffffffc02032da:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02032dc:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02032de:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02032e2:	9db9                	addw	a1,a1,a4
ffffffffc02032e4:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02032e6:	0ad78463          	beq	a5,a3,ffffffffc020338e <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc02032ea:	fe878713          	addi	a4,a5,-24
ffffffffc02032ee:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02032f2:	4581                	li	a1,0
            if (base < page) {
ffffffffc02032f4:	00e56a63          	bltu	a0,a4,ffffffffc0203308 <default_free_pages+0x78>
    return listelm->next;
ffffffffc02032f8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02032fa:	04d70c63          	beq	a4,a3,ffffffffc0203352 <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc02032fe:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203300:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0203304:	fee57ae3          	bgeu	a0,a4,ffffffffc02032f8 <default_free_pages+0x68>
ffffffffc0203308:	c199                	beqz	a1,ffffffffc020330e <default_free_pages+0x7e>
ffffffffc020330a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020330e:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203310:	e390                	sd	a2,0(a5)
ffffffffc0203312:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203314:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203316:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0203318:	00d70d63          	beq	a4,a3,ffffffffc0203332 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc020331c:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0203320:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0203324:	02059813          	slli	a6,a1,0x20
ffffffffc0203328:	01a85793          	srli	a5,a6,0x1a
ffffffffc020332c:	97b2                	add	a5,a5,a2
ffffffffc020332e:	02f50c63          	beq	a0,a5,ffffffffc0203366 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0203332:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0203334:	00d78c63          	beq	a5,a3,ffffffffc020334c <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0203338:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc020333a:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc020333e:	02061593          	slli	a1,a2,0x20
ffffffffc0203342:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0203346:	972a                	add	a4,a4,a0
ffffffffc0203348:	04e68a63          	beq	a3,a4,ffffffffc020339c <default_free_pages+0x10c>
}
ffffffffc020334c:	60a2                	ld	ra,8(sp)
ffffffffc020334e:	0141                	addi	sp,sp,16
ffffffffc0203350:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203352:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203354:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0203356:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203358:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020335a:	02d70763          	beq	a4,a3,ffffffffc0203388 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc020335e:	8832                	mv	a6,a2
ffffffffc0203360:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0203362:	87ba                	mv	a5,a4
ffffffffc0203364:	bf71                	j	ffffffffc0203300 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0203366:	491c                	lw	a5,16(a0)
ffffffffc0203368:	9dbd                	addw	a1,a1,a5
ffffffffc020336a:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020336e:	57f5                	li	a5,-3
ffffffffc0203370:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203374:	01853803          	ld	a6,24(a0)
ffffffffc0203378:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc020337a:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc020337c:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0203380:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0203382:	0105b023          	sd	a6,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0203386:	b77d                	j	ffffffffc0203334 <default_free_pages+0xa4>
ffffffffc0203388:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020338a:	873e                	mv	a4,a5
ffffffffc020338c:	bf41                	j	ffffffffc020331c <default_free_pages+0x8c>
}
ffffffffc020338e:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203390:	e390                	sd	a2,0(a5)
ffffffffc0203392:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203394:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203396:	ed1c                	sd	a5,24(a0)
ffffffffc0203398:	0141                	addi	sp,sp,16
ffffffffc020339a:	8082                	ret
            base->property += p->property;
ffffffffc020339c:	ff87a703          	lw	a4,-8(a5)
ffffffffc02033a0:	ff078693          	addi	a3,a5,-16
ffffffffc02033a4:	9e39                	addw	a2,a2,a4
ffffffffc02033a6:	c910                	sw	a2,16(a0)
ffffffffc02033a8:	5775                	li	a4,-3
ffffffffc02033aa:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02033ae:	6398                	ld	a4,0(a5)
ffffffffc02033b0:	679c                	ld	a5,8(a5)
}
ffffffffc02033b2:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02033b4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02033b6:	e398                	sd	a4,0(a5)
ffffffffc02033b8:	0141                	addi	sp,sp,16
ffffffffc02033ba:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02033bc:	00004697          	auipc	a3,0x4
ffffffffc02033c0:	78c68693          	addi	a3,a3,1932 # ffffffffc0207b48 <commands+0x1400>
ffffffffc02033c4:	00003617          	auipc	a2,0x3
ffffffffc02033c8:	79460613          	addi	a2,a2,1940 # ffffffffc0206b58 <commands+0x410>
ffffffffc02033cc:	08300593          	li	a1,131
ffffffffc02033d0:	00004517          	auipc	a0,0x4
ffffffffc02033d4:	46050513          	addi	a0,a0,1120 # ffffffffc0207830 <commands+0x10e8>
ffffffffc02033d8:	e31fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc02033dc:	00004697          	auipc	a3,0x4
ffffffffc02033e0:	76468693          	addi	a3,a3,1892 # ffffffffc0207b40 <commands+0x13f8>
ffffffffc02033e4:	00003617          	auipc	a2,0x3
ffffffffc02033e8:	77460613          	addi	a2,a2,1908 # ffffffffc0206b58 <commands+0x410>
ffffffffc02033ec:	08000593          	li	a1,128
ffffffffc02033f0:	00004517          	auipc	a0,0x4
ffffffffc02033f4:	44050513          	addi	a0,a0,1088 # ffffffffc0207830 <commands+0x10e8>
ffffffffc02033f8:	e11fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02033fc <default_alloc_pages>:
    assert(n > 0);
ffffffffc02033fc:	c941                	beqz	a0,ffffffffc020348c <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc02033fe:	000ab597          	auipc	a1,0xab
ffffffffc0203402:	3a258593          	addi	a1,a1,930 # ffffffffc02ae7a0 <free_area>
ffffffffc0203406:	0105a803          	lw	a6,16(a1)
ffffffffc020340a:	872a                	mv	a4,a0
ffffffffc020340c:	02081793          	slli	a5,a6,0x20
ffffffffc0203410:	9381                	srli	a5,a5,0x20
ffffffffc0203412:	00a7ee63          	bltu	a5,a0,ffffffffc020342e <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0203416:	87ae                	mv	a5,a1
ffffffffc0203418:	a801                	j	ffffffffc0203428 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020341a:	ff87a683          	lw	a3,-8(a5)
ffffffffc020341e:	02069613          	slli	a2,a3,0x20
ffffffffc0203422:	9201                	srli	a2,a2,0x20
ffffffffc0203424:	00e67763          	bgeu	a2,a4,ffffffffc0203432 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0203428:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020342a:	feb798e3          	bne	a5,a1,ffffffffc020341a <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020342e:	4501                	li	a0,0
}
ffffffffc0203430:	8082                	ret
    return listelm->prev;
ffffffffc0203432:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203436:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc020343a:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc020343e:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0203442:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0203446:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc020344a:	02c77863          	bgeu	a4,a2,ffffffffc020347a <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc020344e:	071a                	slli	a4,a4,0x6
ffffffffc0203450:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0203452:	41c686bb          	subw	a3,a3,t3
ffffffffc0203456:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203458:	00870613          	addi	a2,a4,8
ffffffffc020345c:	4689                	li	a3,2
ffffffffc020345e:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203462:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0203466:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc020346a:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc020346e:	e290                	sd	a2,0(a3)
ffffffffc0203470:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0203474:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0203476:	01173c23          	sd	a7,24(a4)
ffffffffc020347a:	41c8083b          	subw	a6,a6,t3
ffffffffc020347e:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203482:	5775                	li	a4,-3
ffffffffc0203484:	17c1                	addi	a5,a5,-16
ffffffffc0203486:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020348a:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020348c:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020348e:	00004697          	auipc	a3,0x4
ffffffffc0203492:	6b268693          	addi	a3,a3,1714 # ffffffffc0207b40 <commands+0x13f8>
ffffffffc0203496:	00003617          	auipc	a2,0x3
ffffffffc020349a:	6c260613          	addi	a2,a2,1730 # ffffffffc0206b58 <commands+0x410>
ffffffffc020349e:	06200593          	li	a1,98
ffffffffc02034a2:	00004517          	auipc	a0,0x4
ffffffffc02034a6:	38e50513          	addi	a0,a0,910 # ffffffffc0207830 <commands+0x10e8>
default_alloc_pages(size_t n) {
ffffffffc02034aa:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02034ac:	d5dfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02034b0 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02034b0:	1141                	addi	sp,sp,-16
ffffffffc02034b2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02034b4:	c5f1                	beqz	a1,ffffffffc0203580 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc02034b6:	00659693          	slli	a3,a1,0x6
ffffffffc02034ba:	96aa                	add	a3,a3,a0
ffffffffc02034bc:	87aa                	mv	a5,a0
ffffffffc02034be:	00d50f63          	beq	a0,a3,ffffffffc02034dc <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02034c2:	6798                	ld	a4,8(a5)
ffffffffc02034c4:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc02034c6:	cf49                	beqz	a4,ffffffffc0203560 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc02034c8:	0007a823          	sw	zero,16(a5)
ffffffffc02034cc:	0007b423          	sd	zero,8(a5)
ffffffffc02034d0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02034d4:	04078793          	addi	a5,a5,64
ffffffffc02034d8:	fed795e3          	bne	a5,a3,ffffffffc02034c2 <default_init_memmap+0x12>
    base->property = n;
ffffffffc02034dc:	2581                	sext.w	a1,a1
ffffffffc02034de:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02034e0:	4789                	li	a5,2
ffffffffc02034e2:	00850713          	addi	a4,a0,8
ffffffffc02034e6:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02034ea:	000ab697          	auipc	a3,0xab
ffffffffc02034ee:	2b668693          	addi	a3,a3,694 # ffffffffc02ae7a0 <free_area>
ffffffffc02034f2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02034f4:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02034f6:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02034fa:	9db9                	addw	a1,a1,a4
ffffffffc02034fc:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02034fe:	04d78a63          	beq	a5,a3,ffffffffc0203552 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0203502:	fe878713          	addi	a4,a5,-24
ffffffffc0203506:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020350a:	4581                	li	a1,0
            if (base < page) {
ffffffffc020350c:	00e56a63          	bltu	a0,a4,ffffffffc0203520 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0203510:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203512:	02d70263          	beq	a4,a3,ffffffffc0203536 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0203516:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203518:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020351c:	fee57ae3          	bgeu	a0,a4,ffffffffc0203510 <default_init_memmap+0x60>
ffffffffc0203520:	c199                	beqz	a1,ffffffffc0203526 <default_init_memmap+0x76>
ffffffffc0203522:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203526:	6398                	ld	a4,0(a5)
}
ffffffffc0203528:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020352a:	e390                	sd	a2,0(a5)
ffffffffc020352c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020352e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203530:	ed18                	sd	a4,24(a0)
ffffffffc0203532:	0141                	addi	sp,sp,16
ffffffffc0203534:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203536:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203538:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020353a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020353c:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020353e:	00d70663          	beq	a4,a3,ffffffffc020354a <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0203542:	8832                	mv	a6,a2
ffffffffc0203544:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0203546:	87ba                	mv	a5,a4
ffffffffc0203548:	bfc1                	j	ffffffffc0203518 <default_init_memmap+0x68>
}
ffffffffc020354a:	60a2                	ld	ra,8(sp)
ffffffffc020354c:	e290                	sd	a2,0(a3)
ffffffffc020354e:	0141                	addi	sp,sp,16
ffffffffc0203550:	8082                	ret
ffffffffc0203552:	60a2                	ld	ra,8(sp)
ffffffffc0203554:	e390                	sd	a2,0(a5)
ffffffffc0203556:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203558:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020355a:	ed1c                	sd	a5,24(a0)
ffffffffc020355c:	0141                	addi	sp,sp,16
ffffffffc020355e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0203560:	00004697          	auipc	a3,0x4
ffffffffc0203564:	61068693          	addi	a3,a3,1552 # ffffffffc0207b70 <commands+0x1428>
ffffffffc0203568:	00003617          	auipc	a2,0x3
ffffffffc020356c:	5f060613          	addi	a2,a2,1520 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203570:	04900593          	li	a1,73
ffffffffc0203574:	00004517          	auipc	a0,0x4
ffffffffc0203578:	2bc50513          	addi	a0,a0,700 # ffffffffc0207830 <commands+0x10e8>
ffffffffc020357c:	c8dfc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc0203580:	00004697          	auipc	a3,0x4
ffffffffc0203584:	5c068693          	addi	a3,a3,1472 # ffffffffc0207b40 <commands+0x13f8>
ffffffffc0203588:	00003617          	auipc	a2,0x3
ffffffffc020358c:	5d060613          	addi	a2,a2,1488 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203590:	04600593          	li	a1,70
ffffffffc0203594:	00004517          	auipc	a0,0x4
ffffffffc0203598:	29c50513          	addi	a0,a0,668 # ffffffffc0207830 <commands+0x10e8>
ffffffffc020359c:	c6dfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02035a0 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc02035a0:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02035a2:	00004617          	auipc	a2,0x4
ffffffffc02035a6:	93660613          	addi	a2,a2,-1738 # ffffffffc0206ed8 <commands+0x790>
ffffffffc02035aa:	06200593          	li	a1,98
ffffffffc02035ae:	00004517          	auipc	a0,0x4
ffffffffc02035b2:	91a50513          	addi	a0,a0,-1766 # ffffffffc0206ec8 <commands+0x780>
pa2page(uintptr_t pa) {
ffffffffc02035b6:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02035b8:	c51fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02035bc <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc02035bc:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02035be:	00004617          	auipc	a2,0x4
ffffffffc02035c2:	8e260613          	addi	a2,a2,-1822 # ffffffffc0206ea0 <commands+0x758>
ffffffffc02035c6:	07400593          	li	a1,116
ffffffffc02035ca:	00004517          	auipc	a0,0x4
ffffffffc02035ce:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0206ec8 <commands+0x780>
pte2page(pte_t pte) {
ffffffffc02035d2:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02035d4:	c35fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02035d8 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02035d8:	7139                	addi	sp,sp,-64
ffffffffc02035da:	f426                	sd	s1,40(sp)
ffffffffc02035dc:	f04a                	sd	s2,32(sp)
ffffffffc02035de:	ec4e                	sd	s3,24(sp)
ffffffffc02035e0:	e852                	sd	s4,16(sp)
ffffffffc02035e2:	e456                	sd	s5,8(sp)
ffffffffc02035e4:	e05a                	sd	s6,0(sp)
ffffffffc02035e6:	fc06                	sd	ra,56(sp)
ffffffffc02035e8:	f822                	sd	s0,48(sp)
ffffffffc02035ea:	84aa                	mv	s1,a0
ffffffffc02035ec:	000af917          	auipc	s2,0xaf
ffffffffc02035f0:	24490913          	addi	s2,s2,580 # ffffffffc02b2830 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02035f4:	4a05                	li	s4,1
ffffffffc02035f6:	000afa97          	auipc	s5,0xaf
ffffffffc02035fa:	212a8a93          	addi	s5,s5,530 # ffffffffc02b2808 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02035fe:	0005099b          	sext.w	s3,a0
ffffffffc0203602:	000afb17          	auipc	s6,0xaf
ffffffffc0203606:	1deb0b13          	addi	s6,s6,478 # ffffffffc02b27e0 <check_mm_struct>
ffffffffc020360a:	a01d                	j	ffffffffc0203630 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc020360c:	00093783          	ld	a5,0(s2)
ffffffffc0203610:	6f9c                	ld	a5,24(a5)
ffffffffc0203612:	9782                	jalr	a5
ffffffffc0203614:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0203616:	4601                	li	a2,0
ffffffffc0203618:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020361a:	ec0d                	bnez	s0,ffffffffc0203654 <alloc_pages+0x7c>
ffffffffc020361c:	029a6c63          	bltu	s4,s1,ffffffffc0203654 <alloc_pages+0x7c>
ffffffffc0203620:	000aa783          	lw	a5,0(s5)
ffffffffc0203624:	2781                	sext.w	a5,a5
ffffffffc0203626:	c79d                	beqz	a5,ffffffffc0203654 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0203628:	000b3503          	ld	a0,0(s6)
ffffffffc020362c:	bb2ff0ef          	jal	ra,ffffffffc02029de <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203630:	100027f3          	csrr	a5,sstatus
ffffffffc0203634:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0203636:	8526                	mv	a0,s1
ffffffffc0203638:	dbf1                	beqz	a5,ffffffffc020360c <alloc_pages+0x34>
        intr_disable();
ffffffffc020363a:	febfc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc020363e:	00093783          	ld	a5,0(s2)
ffffffffc0203642:	8526                	mv	a0,s1
ffffffffc0203644:	6f9c                	ld	a5,24(a5)
ffffffffc0203646:	9782                	jalr	a5
ffffffffc0203648:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020364a:	fd5fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc020364e:	4601                	li	a2,0
ffffffffc0203650:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0203652:	d469                	beqz	s0,ffffffffc020361c <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0203654:	70e2                	ld	ra,56(sp)
ffffffffc0203656:	8522                	mv	a0,s0
ffffffffc0203658:	7442                	ld	s0,48(sp)
ffffffffc020365a:	74a2                	ld	s1,40(sp)
ffffffffc020365c:	7902                	ld	s2,32(sp)
ffffffffc020365e:	69e2                	ld	s3,24(sp)
ffffffffc0203660:	6a42                	ld	s4,16(sp)
ffffffffc0203662:	6aa2                	ld	s5,8(sp)
ffffffffc0203664:	6b02                	ld	s6,0(sp)
ffffffffc0203666:	6121                	addi	sp,sp,64
ffffffffc0203668:	8082                	ret

ffffffffc020366a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020366a:	100027f3          	csrr	a5,sstatus
ffffffffc020366e:	8b89                	andi	a5,a5,2
ffffffffc0203670:	e799                	bnez	a5,ffffffffc020367e <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0203672:	000af797          	auipc	a5,0xaf
ffffffffc0203676:	1be7b783          	ld	a5,446(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc020367a:	739c                	ld	a5,32(a5)
ffffffffc020367c:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc020367e:	1101                	addi	sp,sp,-32
ffffffffc0203680:	ec06                	sd	ra,24(sp)
ffffffffc0203682:	e822                	sd	s0,16(sp)
ffffffffc0203684:	e426                	sd	s1,8(sp)
ffffffffc0203686:	842a                	mv	s0,a0
ffffffffc0203688:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020368a:	f9bfc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020368e:	000af797          	auipc	a5,0xaf
ffffffffc0203692:	1a27b783          	ld	a5,418(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0203696:	739c                	ld	a5,32(a5)
ffffffffc0203698:	85a6                	mv	a1,s1
ffffffffc020369a:	8522                	mv	a0,s0
ffffffffc020369c:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020369e:	6442                	ld	s0,16(sp)
ffffffffc02036a0:	60e2                	ld	ra,24(sp)
ffffffffc02036a2:	64a2                	ld	s1,8(sp)
ffffffffc02036a4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02036a6:	f79fc06f          	j	ffffffffc020061e <intr_enable>

ffffffffc02036aa <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02036aa:	100027f3          	csrr	a5,sstatus
ffffffffc02036ae:	8b89                	andi	a5,a5,2
ffffffffc02036b0:	e799                	bnez	a5,ffffffffc02036be <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02036b2:	000af797          	auipc	a5,0xaf
ffffffffc02036b6:	17e7b783          	ld	a5,382(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc02036ba:	779c                	ld	a5,40(a5)
ffffffffc02036bc:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02036be:	1141                	addi	sp,sp,-16
ffffffffc02036c0:	e406                	sd	ra,8(sp)
ffffffffc02036c2:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02036c4:	f61fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02036c8:	000af797          	auipc	a5,0xaf
ffffffffc02036cc:	1687b783          	ld	a5,360(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc02036d0:	779c                	ld	a5,40(a5)
ffffffffc02036d2:	9782                	jalr	a5
ffffffffc02036d4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02036d6:	f49fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02036da:	60a2                	ld	ra,8(sp)
ffffffffc02036dc:	8522                	mv	a0,s0
ffffffffc02036de:	6402                	ld	s0,0(sp)
ffffffffc02036e0:	0141                	addi	sp,sp,16
ffffffffc02036e2:	8082                	ret

ffffffffc02036e4 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02036e4:	01e5d793          	srli	a5,a1,0x1e
ffffffffc02036e8:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02036ec:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02036ee:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02036f0:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02036f2:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc02036f6:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02036f8:	f04a                	sd	s2,32(sp)
ffffffffc02036fa:	ec4e                	sd	s3,24(sp)
ffffffffc02036fc:	e852                	sd	s4,16(sp)
ffffffffc02036fe:	fc06                	sd	ra,56(sp)
ffffffffc0203700:	f822                	sd	s0,48(sp)
ffffffffc0203702:	e456                	sd	s5,8(sp)
ffffffffc0203704:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203706:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020370a:	892e                	mv	s2,a1
ffffffffc020370c:	89b2                	mv	s3,a2
ffffffffc020370e:	000afa17          	auipc	s4,0xaf
ffffffffc0203712:	112a0a13          	addi	s4,s4,274 # ffffffffc02b2820 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203716:	e7b5                	bnez	a5,ffffffffc0203782 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0203718:	12060b63          	beqz	a2,ffffffffc020384e <get_pte+0x16a>
ffffffffc020371c:	4505                	li	a0,1
ffffffffc020371e:	ebbff0ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0203722:	842a                	mv	s0,a0
ffffffffc0203724:	12050563          	beqz	a0,ffffffffc020384e <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0203728:	000afb17          	auipc	s6,0xaf
ffffffffc020372c:	100b0b13          	addi	s6,s6,256 # ffffffffc02b2828 <pages>
ffffffffc0203730:	000b3503          	ld	a0,0(s6)
ffffffffc0203734:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203738:	000afa17          	auipc	s4,0xaf
ffffffffc020373c:	0e8a0a13          	addi	s4,s4,232 # ffffffffc02b2820 <npage>
ffffffffc0203740:	40a40533          	sub	a0,s0,a0
ffffffffc0203744:	8519                	srai	a0,a0,0x6
ffffffffc0203746:	9556                	add	a0,a0,s5
ffffffffc0203748:	000a3703          	ld	a4,0(s4)
ffffffffc020374c:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0203750:	4685                	li	a3,1
ffffffffc0203752:	c014                	sw	a3,0(s0)
ffffffffc0203754:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203756:	0532                	slli	a0,a0,0xc
ffffffffc0203758:	14e7f263          	bgeu	a5,a4,ffffffffc020389c <get_pte+0x1b8>
ffffffffc020375c:	000af797          	auipc	a5,0xaf
ffffffffc0203760:	0dc7b783          	ld	a5,220(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0203764:	6605                	lui	a2,0x1
ffffffffc0203766:	4581                	li	a1,0
ffffffffc0203768:	953e                	add	a0,a0,a5
ffffffffc020376a:	105020ef          	jal	ra,ffffffffc020606e <memset>
    return page - pages + nbase;
ffffffffc020376e:	000b3683          	ld	a3,0(s6)
ffffffffc0203772:	40d406b3          	sub	a3,s0,a3
ffffffffc0203776:	8699                	srai	a3,a3,0x6
ffffffffc0203778:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020377a:	06aa                	slli	a3,a3,0xa
ffffffffc020377c:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0203780:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0203782:	77fd                	lui	a5,0xfffff
ffffffffc0203784:	068a                	slli	a3,a3,0x2
ffffffffc0203786:	000a3703          	ld	a4,0(s4)
ffffffffc020378a:	8efd                	and	a3,a3,a5
ffffffffc020378c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0203790:	0ce7f163          	bgeu	a5,a4,ffffffffc0203852 <get_pte+0x16e>
ffffffffc0203794:	000afa97          	auipc	s5,0xaf
ffffffffc0203798:	0a4a8a93          	addi	s5,s5,164 # ffffffffc02b2838 <va_pa_offset>
ffffffffc020379c:	000ab403          	ld	s0,0(s5)
ffffffffc02037a0:	01595793          	srli	a5,s2,0x15
ffffffffc02037a4:	1ff7f793          	andi	a5,a5,511
ffffffffc02037a8:	96a2                	add	a3,a3,s0
ffffffffc02037aa:	00379413          	slli	s0,a5,0x3
ffffffffc02037ae:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc02037b0:	6014                	ld	a3,0(s0)
ffffffffc02037b2:	0016f793          	andi	a5,a3,1
ffffffffc02037b6:	e3ad                	bnez	a5,ffffffffc0203818 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02037b8:	08098b63          	beqz	s3,ffffffffc020384e <get_pte+0x16a>
ffffffffc02037bc:	4505                	li	a0,1
ffffffffc02037be:	e1bff0ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc02037c2:	84aa                	mv	s1,a0
ffffffffc02037c4:	c549                	beqz	a0,ffffffffc020384e <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc02037c6:	000afb17          	auipc	s6,0xaf
ffffffffc02037ca:	062b0b13          	addi	s6,s6,98 # ffffffffc02b2828 <pages>
ffffffffc02037ce:	000b3503          	ld	a0,0(s6)
ffffffffc02037d2:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02037d6:	000a3703          	ld	a4,0(s4)
ffffffffc02037da:	40a48533          	sub	a0,s1,a0
ffffffffc02037de:	8519                	srai	a0,a0,0x6
ffffffffc02037e0:	954e                	add	a0,a0,s3
ffffffffc02037e2:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc02037e6:	4685                	li	a3,1
ffffffffc02037e8:	c094                	sw	a3,0(s1)
ffffffffc02037ea:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02037ec:	0532                	slli	a0,a0,0xc
ffffffffc02037ee:	08e7fa63          	bgeu	a5,a4,ffffffffc0203882 <get_pte+0x19e>
ffffffffc02037f2:	000ab783          	ld	a5,0(s5)
ffffffffc02037f6:	6605                	lui	a2,0x1
ffffffffc02037f8:	4581                	li	a1,0
ffffffffc02037fa:	953e                	add	a0,a0,a5
ffffffffc02037fc:	073020ef          	jal	ra,ffffffffc020606e <memset>
    return page - pages + nbase;
ffffffffc0203800:	000b3683          	ld	a3,0(s6)
ffffffffc0203804:	40d486b3          	sub	a3,s1,a3
ffffffffc0203808:	8699                	srai	a3,a3,0x6
ffffffffc020380a:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020380c:	06aa                	slli	a3,a3,0xa
ffffffffc020380e:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0203812:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0203814:	000a3703          	ld	a4,0(s4)
ffffffffc0203818:	068a                	slli	a3,a3,0x2
ffffffffc020381a:	757d                	lui	a0,0xfffff
ffffffffc020381c:	8ee9                	and	a3,a3,a0
ffffffffc020381e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0203822:	04e7f463          	bgeu	a5,a4,ffffffffc020386a <get_pte+0x186>
ffffffffc0203826:	000ab503          	ld	a0,0(s5)
ffffffffc020382a:	00c95913          	srli	s2,s2,0xc
ffffffffc020382e:	1ff97913          	andi	s2,s2,511
ffffffffc0203832:	96aa                	add	a3,a3,a0
ffffffffc0203834:	00391513          	slli	a0,s2,0x3
ffffffffc0203838:	9536                	add	a0,a0,a3
}
ffffffffc020383a:	70e2                	ld	ra,56(sp)
ffffffffc020383c:	7442                	ld	s0,48(sp)
ffffffffc020383e:	74a2                	ld	s1,40(sp)
ffffffffc0203840:	7902                	ld	s2,32(sp)
ffffffffc0203842:	69e2                	ld	s3,24(sp)
ffffffffc0203844:	6a42                	ld	s4,16(sp)
ffffffffc0203846:	6aa2                	ld	s5,8(sp)
ffffffffc0203848:	6b02                	ld	s6,0(sp)
ffffffffc020384a:	6121                	addi	sp,sp,64
ffffffffc020384c:	8082                	ret
            return NULL;
ffffffffc020384e:	4501                	li	a0,0
ffffffffc0203850:	b7ed                	j	ffffffffc020383a <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0203852:	00003617          	auipc	a2,0x3
ffffffffc0203856:	6d660613          	addi	a2,a2,1750 # ffffffffc0206f28 <commands+0x7e0>
ffffffffc020385a:	0e300593          	li	a1,227
ffffffffc020385e:	00004517          	auipc	a0,0x4
ffffffffc0203862:	37250513          	addi	a0,a0,882 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0203866:	9a3fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020386a:	00003617          	auipc	a2,0x3
ffffffffc020386e:	6be60613          	addi	a2,a2,1726 # ffffffffc0206f28 <commands+0x7e0>
ffffffffc0203872:	0ee00593          	li	a1,238
ffffffffc0203876:	00004517          	auipc	a0,0x4
ffffffffc020387a:	35a50513          	addi	a0,a0,858 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc020387e:	98bfc0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203882:	86aa                	mv	a3,a0
ffffffffc0203884:	00003617          	auipc	a2,0x3
ffffffffc0203888:	6a460613          	addi	a2,a2,1700 # ffffffffc0206f28 <commands+0x7e0>
ffffffffc020388c:	0eb00593          	li	a1,235
ffffffffc0203890:	00004517          	auipc	a0,0x4
ffffffffc0203894:	34050513          	addi	a0,a0,832 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0203898:	971fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020389c:	86aa                	mv	a3,a0
ffffffffc020389e:	00003617          	auipc	a2,0x3
ffffffffc02038a2:	68a60613          	addi	a2,a2,1674 # ffffffffc0206f28 <commands+0x7e0>
ffffffffc02038a6:	0df00593          	li	a1,223
ffffffffc02038aa:	00004517          	auipc	a0,0x4
ffffffffc02038ae:	32650513          	addi	a0,a0,806 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc02038b2:	957fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02038b6 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02038b6:	1141                	addi	sp,sp,-16
ffffffffc02038b8:	e022                	sd	s0,0(sp)
ffffffffc02038ba:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02038bc:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02038be:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02038c0:	e25ff0ef          	jal	ra,ffffffffc02036e4 <get_pte>
    if (ptep_store != NULL) {
ffffffffc02038c4:	c011                	beqz	s0,ffffffffc02038c8 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02038c6:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02038c8:	c511                	beqz	a0,ffffffffc02038d4 <get_page+0x1e>
ffffffffc02038ca:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02038cc:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02038ce:	0017f713          	andi	a4,a5,1
ffffffffc02038d2:	e709                	bnez	a4,ffffffffc02038dc <get_page+0x26>
}
ffffffffc02038d4:	60a2                	ld	ra,8(sp)
ffffffffc02038d6:	6402                	ld	s0,0(sp)
ffffffffc02038d8:	0141                	addi	sp,sp,16
ffffffffc02038da:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02038dc:	078a                	slli	a5,a5,0x2
ffffffffc02038de:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02038e0:	000af717          	auipc	a4,0xaf
ffffffffc02038e4:	f4073703          	ld	a4,-192(a4) # ffffffffc02b2820 <npage>
ffffffffc02038e8:	00e7ff63          	bgeu	a5,a4,ffffffffc0203906 <get_page+0x50>
ffffffffc02038ec:	60a2                	ld	ra,8(sp)
ffffffffc02038ee:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc02038f0:	fff80537          	lui	a0,0xfff80
ffffffffc02038f4:	97aa                	add	a5,a5,a0
ffffffffc02038f6:	079a                	slli	a5,a5,0x6
ffffffffc02038f8:	000af517          	auipc	a0,0xaf
ffffffffc02038fc:	f3053503          	ld	a0,-208(a0) # ffffffffc02b2828 <pages>
ffffffffc0203900:	953e                	add	a0,a0,a5
ffffffffc0203902:	0141                	addi	sp,sp,16
ffffffffc0203904:	8082                	ret
ffffffffc0203906:	c9bff0ef          	jal	ra,ffffffffc02035a0 <pa2page.part.0>

ffffffffc020390a <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020390a:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020390c:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203910:	f486                	sd	ra,104(sp)
ffffffffc0203912:	f0a2                	sd	s0,96(sp)
ffffffffc0203914:	eca6                	sd	s1,88(sp)
ffffffffc0203916:	e8ca                	sd	s2,80(sp)
ffffffffc0203918:	e4ce                	sd	s3,72(sp)
ffffffffc020391a:	e0d2                	sd	s4,64(sp)
ffffffffc020391c:	fc56                	sd	s5,56(sp)
ffffffffc020391e:	f85a                	sd	s6,48(sp)
ffffffffc0203920:	f45e                	sd	s7,40(sp)
ffffffffc0203922:	f062                	sd	s8,32(sp)
ffffffffc0203924:	ec66                	sd	s9,24(sp)
ffffffffc0203926:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203928:	17d2                	slli	a5,a5,0x34
ffffffffc020392a:	e3ed                	bnez	a5,ffffffffc0203a0c <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc020392c:	002007b7          	lui	a5,0x200
ffffffffc0203930:	842e                	mv	s0,a1
ffffffffc0203932:	0ef5ed63          	bltu	a1,a5,ffffffffc0203a2c <unmap_range+0x122>
ffffffffc0203936:	8932                	mv	s2,a2
ffffffffc0203938:	0ec5fa63          	bgeu	a1,a2,ffffffffc0203a2c <unmap_range+0x122>
ffffffffc020393c:	4785                	li	a5,1
ffffffffc020393e:	07fe                	slli	a5,a5,0x1f
ffffffffc0203940:	0ec7e663          	bltu	a5,a2,ffffffffc0203a2c <unmap_range+0x122>
ffffffffc0203944:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0203946:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203948:	000afc97          	auipc	s9,0xaf
ffffffffc020394c:	ed8c8c93          	addi	s9,s9,-296 # ffffffffc02b2820 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203950:	000afc17          	auipc	s8,0xaf
ffffffffc0203954:	ed8c0c13          	addi	s8,s8,-296 # ffffffffc02b2828 <pages>
ffffffffc0203958:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc020395c:	000afd17          	auipc	s10,0xaf
ffffffffc0203960:	ed4d0d13          	addi	s10,s10,-300 # ffffffffc02b2830 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203964:	00200b37          	lui	s6,0x200
ffffffffc0203968:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc020396c:	4601                	li	a2,0
ffffffffc020396e:	85a2                	mv	a1,s0
ffffffffc0203970:	854e                	mv	a0,s3
ffffffffc0203972:	d73ff0ef          	jal	ra,ffffffffc02036e4 <get_pte>
ffffffffc0203976:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0203978:	cd29                	beqz	a0,ffffffffc02039d2 <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc020397a:	611c                	ld	a5,0(a0)
ffffffffc020397c:	e395                	bnez	a5,ffffffffc02039a0 <unmap_range+0x96>
        start += PGSIZE;
ffffffffc020397e:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0203980:	ff2466e3          	bltu	s0,s2,ffffffffc020396c <unmap_range+0x62>
}
ffffffffc0203984:	70a6                	ld	ra,104(sp)
ffffffffc0203986:	7406                	ld	s0,96(sp)
ffffffffc0203988:	64e6                	ld	s1,88(sp)
ffffffffc020398a:	6946                	ld	s2,80(sp)
ffffffffc020398c:	69a6                	ld	s3,72(sp)
ffffffffc020398e:	6a06                	ld	s4,64(sp)
ffffffffc0203990:	7ae2                	ld	s5,56(sp)
ffffffffc0203992:	7b42                	ld	s6,48(sp)
ffffffffc0203994:	7ba2                	ld	s7,40(sp)
ffffffffc0203996:	7c02                	ld	s8,32(sp)
ffffffffc0203998:	6ce2                	ld	s9,24(sp)
ffffffffc020399a:	6d42                	ld	s10,16(sp)
ffffffffc020399c:	6165                	addi	sp,sp,112
ffffffffc020399e:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02039a0:	0017f713          	andi	a4,a5,1
ffffffffc02039a4:	df69                	beqz	a4,ffffffffc020397e <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc02039a6:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02039aa:	078a                	slli	a5,a5,0x2
ffffffffc02039ac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02039ae:	08e7ff63          	bgeu	a5,a4,ffffffffc0203a4c <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc02039b2:	000c3503          	ld	a0,0(s8)
ffffffffc02039b6:	97de                	add	a5,a5,s7
ffffffffc02039b8:	079a                	slli	a5,a5,0x6
ffffffffc02039ba:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02039bc:	411c                	lw	a5,0(a0)
ffffffffc02039be:	fff7871b          	addiw	a4,a5,-1
ffffffffc02039c2:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02039c4:	cf11                	beqz	a4,ffffffffc02039e0 <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02039c6:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02039ca:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02039ce:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02039d0:	bf45                	j	ffffffffc0203980 <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02039d2:	945a                	add	s0,s0,s6
ffffffffc02039d4:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc02039d8:	d455                	beqz	s0,ffffffffc0203984 <unmap_range+0x7a>
ffffffffc02039da:	f92469e3          	bltu	s0,s2,ffffffffc020396c <unmap_range+0x62>
ffffffffc02039de:	b75d                	j	ffffffffc0203984 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02039e0:	100027f3          	csrr	a5,sstatus
ffffffffc02039e4:	8b89                	andi	a5,a5,2
ffffffffc02039e6:	e799                	bnez	a5,ffffffffc02039f4 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc02039e8:	000d3783          	ld	a5,0(s10)
ffffffffc02039ec:	4585                	li	a1,1
ffffffffc02039ee:	739c                	ld	a5,32(a5)
ffffffffc02039f0:	9782                	jalr	a5
    if (flag) {
ffffffffc02039f2:	bfd1                	j	ffffffffc02039c6 <unmap_range+0xbc>
ffffffffc02039f4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02039f6:	c2ffc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc02039fa:	000d3783          	ld	a5,0(s10)
ffffffffc02039fe:	6522                	ld	a0,8(sp)
ffffffffc0203a00:	4585                	li	a1,1
ffffffffc0203a02:	739c                	ld	a5,32(a5)
ffffffffc0203a04:	9782                	jalr	a5
        intr_enable();
ffffffffc0203a06:	c19fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0203a0a:	bf75                	j	ffffffffc02039c6 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203a0c:	00003697          	auipc	a3,0x3
ffffffffc0203a10:	43c68693          	addi	a3,a3,1084 # ffffffffc0206e48 <commands+0x700>
ffffffffc0203a14:	00003617          	auipc	a2,0x3
ffffffffc0203a18:	14460613          	addi	a2,a2,324 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203a1c:	10f00593          	li	a1,271
ffffffffc0203a20:	00004517          	auipc	a0,0x4
ffffffffc0203a24:	1b050513          	addi	a0,a0,432 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0203a28:	fe0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203a2c:	00003697          	auipc	a3,0x3
ffffffffc0203a30:	45c68693          	addi	a3,a3,1116 # ffffffffc0206e88 <commands+0x740>
ffffffffc0203a34:	00003617          	auipc	a2,0x3
ffffffffc0203a38:	12460613          	addi	a2,a2,292 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203a3c:	11000593          	li	a1,272
ffffffffc0203a40:	00004517          	auipc	a0,0x4
ffffffffc0203a44:	19050513          	addi	a0,a0,400 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0203a48:	fc0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0203a4c:	b55ff0ef          	jal	ra,ffffffffc02035a0 <pa2page.part.0>

ffffffffc0203a50 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203a50:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203a52:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203a56:	fc86                	sd	ra,120(sp)
ffffffffc0203a58:	f8a2                	sd	s0,112(sp)
ffffffffc0203a5a:	f4a6                	sd	s1,104(sp)
ffffffffc0203a5c:	f0ca                	sd	s2,96(sp)
ffffffffc0203a5e:	ecce                	sd	s3,88(sp)
ffffffffc0203a60:	e8d2                	sd	s4,80(sp)
ffffffffc0203a62:	e4d6                	sd	s5,72(sp)
ffffffffc0203a64:	e0da                	sd	s6,64(sp)
ffffffffc0203a66:	fc5e                	sd	s7,56(sp)
ffffffffc0203a68:	f862                	sd	s8,48(sp)
ffffffffc0203a6a:	f466                	sd	s9,40(sp)
ffffffffc0203a6c:	f06a                	sd	s10,32(sp)
ffffffffc0203a6e:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203a70:	17d2                	slli	a5,a5,0x34
ffffffffc0203a72:	20079a63          	bnez	a5,ffffffffc0203c86 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc0203a76:	002007b7          	lui	a5,0x200
ffffffffc0203a7a:	24f5e463          	bltu	a1,a5,ffffffffc0203cc2 <exit_range+0x272>
ffffffffc0203a7e:	8ab2                	mv	s5,a2
ffffffffc0203a80:	24c5f163          	bgeu	a1,a2,ffffffffc0203cc2 <exit_range+0x272>
ffffffffc0203a84:	4785                	li	a5,1
ffffffffc0203a86:	07fe                	slli	a5,a5,0x1f
ffffffffc0203a88:	22c7ed63          	bltu	a5,a2,ffffffffc0203cc2 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0203a8c:	c00009b7          	lui	s3,0xc0000
ffffffffc0203a90:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0203a94:	ffe00937          	lui	s2,0xffe00
ffffffffc0203a98:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc0203a9c:	5cfd                	li	s9,-1
ffffffffc0203a9e:	8c2a                	mv	s8,a0
ffffffffc0203aa0:	0125f933          	and	s2,a1,s2
ffffffffc0203aa4:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc0203aa6:	000afd17          	auipc	s10,0xaf
ffffffffc0203aaa:	d7ad0d13          	addi	s10,s10,-646 # ffffffffc02b2820 <npage>
    return KADDR(page2pa(page));
ffffffffc0203aae:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0203ab2:	000af717          	auipc	a4,0xaf
ffffffffc0203ab6:	d7670713          	addi	a4,a4,-650 # ffffffffc02b2828 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc0203aba:	000afd97          	auipc	s11,0xaf
ffffffffc0203abe:	d76d8d93          	addi	s11,s11,-650 # ffffffffc02b2830 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0203ac2:	c0000437          	lui	s0,0xc0000
ffffffffc0203ac6:	944e                	add	s0,s0,s3
ffffffffc0203ac8:	8079                	srli	s0,s0,0x1e
ffffffffc0203aca:	1ff47413          	andi	s0,s0,511
ffffffffc0203ace:	040e                	slli	s0,s0,0x3
ffffffffc0203ad0:	9462                	add	s0,s0,s8
ffffffffc0203ad2:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ee0>
        if (pde1&PTE_V){
ffffffffc0203ad6:	001a7793          	andi	a5,s4,1
ffffffffc0203ada:	eb99                	bnez	a5,ffffffffc0203af0 <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc0203adc:	12098463          	beqz	s3,ffffffffc0203c04 <exit_range+0x1b4>
ffffffffc0203ae0:	400007b7          	lui	a5,0x40000
ffffffffc0203ae4:	97ce                	add	a5,a5,s3
ffffffffc0203ae6:	894e                	mv	s2,s3
ffffffffc0203ae8:	1159fe63          	bgeu	s3,s5,ffffffffc0203c04 <exit_range+0x1b4>
ffffffffc0203aec:	89be                	mv	s3,a5
ffffffffc0203aee:	bfd1                	j	ffffffffc0203ac2 <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc0203af0:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203af4:	0a0a                	slli	s4,s4,0x2
ffffffffc0203af6:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203afa:	1cfa7263          	bgeu	s4,a5,ffffffffc0203cbe <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203afe:	fff80637          	lui	a2,0xfff80
ffffffffc0203b02:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc0203b04:	000806b7          	lui	a3,0x80
ffffffffc0203b08:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0203b0a:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0203b0e:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203b10:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203b12:	18f5fa63          	bgeu	a1,a5,ffffffffc0203ca6 <exit_range+0x256>
ffffffffc0203b16:	000af817          	auipc	a6,0xaf
ffffffffc0203b1a:	d2280813          	addi	a6,a6,-734 # ffffffffc02b2838 <va_pa_offset>
ffffffffc0203b1e:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc0203b22:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0203b24:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0203b28:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc0203b2a:	00080337          	lui	t1,0x80
ffffffffc0203b2e:	6885                	lui	a7,0x1
ffffffffc0203b30:	a819                	j	ffffffffc0203b46 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc0203b32:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc0203b34:	002007b7          	lui	a5,0x200
ffffffffc0203b38:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0203b3a:	08090c63          	beqz	s2,ffffffffc0203bd2 <exit_range+0x182>
ffffffffc0203b3e:	09397a63          	bgeu	s2,s3,ffffffffc0203bd2 <exit_range+0x182>
ffffffffc0203b42:	0f597063          	bgeu	s2,s5,ffffffffc0203c22 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0203b46:	01595493          	srli	s1,s2,0x15
ffffffffc0203b4a:	1ff4f493          	andi	s1,s1,511
ffffffffc0203b4e:	048e                	slli	s1,s1,0x3
ffffffffc0203b50:	94da                	add	s1,s1,s6
ffffffffc0203b52:	609c                	ld	a5,0(s1)
                if (pde0&PTE_V) {
ffffffffc0203b54:	0017f693          	andi	a3,a5,1
ffffffffc0203b58:	dee9                	beqz	a3,ffffffffc0203b32 <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc0203b5a:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203b5e:	078a                	slli	a5,a5,0x2
ffffffffc0203b60:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b62:	14b7fe63          	bgeu	a5,a1,ffffffffc0203cbe <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b66:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc0203b68:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc0203b6c:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0203b70:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203b74:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203b76:	12bef863          	bgeu	t4,a1,ffffffffc0203ca6 <exit_range+0x256>
ffffffffc0203b7a:	00083783          	ld	a5,0(a6)
ffffffffc0203b7e:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0203b80:	011685b3          	add	a1,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc0203b84:	629c                	ld	a5,0(a3)
ffffffffc0203b86:	8b85                	andi	a5,a5,1
ffffffffc0203b88:	f7d5                	bnez	a5,ffffffffc0203b34 <exit_range+0xe4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0203b8a:	06a1                	addi	a3,a3,8
ffffffffc0203b8c:	fed59ce3          	bne	a1,a3,ffffffffc0203b84 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b90:	631c                	ld	a5,0(a4)
ffffffffc0203b92:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203b94:	100027f3          	csrr	a5,sstatus
ffffffffc0203b98:	8b89                	andi	a5,a5,2
ffffffffc0203b9a:	e7d9                	bnez	a5,ffffffffc0203c28 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc0203b9c:	000db783          	ld	a5,0(s11)
ffffffffc0203ba0:	4585                	li	a1,1
ffffffffc0203ba2:	e032                	sd	a2,0(sp)
ffffffffc0203ba4:	739c                	ld	a5,32(a5)
ffffffffc0203ba6:	9782                	jalr	a5
    if (flag) {
ffffffffc0203ba8:	6602                	ld	a2,0(sp)
ffffffffc0203baa:	000af817          	auipc	a6,0xaf
ffffffffc0203bae:	c8e80813          	addi	a6,a6,-882 # ffffffffc02b2838 <va_pa_offset>
ffffffffc0203bb2:	fff80e37          	lui	t3,0xfff80
ffffffffc0203bb6:	00080337          	lui	t1,0x80
ffffffffc0203bba:	6885                	lui	a7,0x1
ffffffffc0203bbc:	000af717          	auipc	a4,0xaf
ffffffffc0203bc0:	c6c70713          	addi	a4,a4,-916 # ffffffffc02b2828 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0203bc4:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc0203bc8:	002007b7          	lui	a5,0x200
ffffffffc0203bcc:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0203bce:	f60918e3          	bnez	s2,ffffffffc0203b3e <exit_range+0xee>
            if (free_pd0) {
ffffffffc0203bd2:	f00b85e3          	beqz	s7,ffffffffc0203adc <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc0203bd6:	000d3783          	ld	a5,0(s10)
ffffffffc0203bda:	0efa7263          	bgeu	s4,a5,ffffffffc0203cbe <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203bde:	6308                	ld	a0,0(a4)
ffffffffc0203be0:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203be2:	100027f3          	csrr	a5,sstatus
ffffffffc0203be6:	8b89                	andi	a5,a5,2
ffffffffc0203be8:	efad                	bnez	a5,ffffffffc0203c62 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc0203bea:	000db783          	ld	a5,0(s11)
ffffffffc0203bee:	4585                	li	a1,1
ffffffffc0203bf0:	739c                	ld	a5,32(a5)
ffffffffc0203bf2:	9782                	jalr	a5
ffffffffc0203bf4:	000af717          	auipc	a4,0xaf
ffffffffc0203bf8:	c3470713          	addi	a4,a4,-972 # ffffffffc02b2828 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0203bfc:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc0203c00:	ee0990e3          	bnez	s3,ffffffffc0203ae0 <exit_range+0x90>
}
ffffffffc0203c04:	70e6                	ld	ra,120(sp)
ffffffffc0203c06:	7446                	ld	s0,112(sp)
ffffffffc0203c08:	74a6                	ld	s1,104(sp)
ffffffffc0203c0a:	7906                	ld	s2,96(sp)
ffffffffc0203c0c:	69e6                	ld	s3,88(sp)
ffffffffc0203c0e:	6a46                	ld	s4,80(sp)
ffffffffc0203c10:	6aa6                	ld	s5,72(sp)
ffffffffc0203c12:	6b06                	ld	s6,64(sp)
ffffffffc0203c14:	7be2                	ld	s7,56(sp)
ffffffffc0203c16:	7c42                	ld	s8,48(sp)
ffffffffc0203c18:	7ca2                	ld	s9,40(sp)
ffffffffc0203c1a:	7d02                	ld	s10,32(sp)
ffffffffc0203c1c:	6de2                	ld	s11,24(sp)
ffffffffc0203c1e:	6109                	addi	sp,sp,128
ffffffffc0203c20:	8082                	ret
            if (free_pd0) {
ffffffffc0203c22:	ea0b8fe3          	beqz	s7,ffffffffc0203ae0 <exit_range+0x90>
ffffffffc0203c26:	bf45                	j	ffffffffc0203bd6 <exit_range+0x186>
ffffffffc0203c28:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0203c2a:	e42a                	sd	a0,8(sp)
ffffffffc0203c2c:	9f9fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203c30:	000db783          	ld	a5,0(s11)
ffffffffc0203c34:	6522                	ld	a0,8(sp)
ffffffffc0203c36:	4585                	li	a1,1
ffffffffc0203c38:	739c                	ld	a5,32(a5)
ffffffffc0203c3a:	9782                	jalr	a5
        intr_enable();
ffffffffc0203c3c:	9e3fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0203c40:	6602                	ld	a2,0(sp)
ffffffffc0203c42:	000af717          	auipc	a4,0xaf
ffffffffc0203c46:	be670713          	addi	a4,a4,-1050 # ffffffffc02b2828 <pages>
ffffffffc0203c4a:	6885                	lui	a7,0x1
ffffffffc0203c4c:	00080337          	lui	t1,0x80
ffffffffc0203c50:	fff80e37          	lui	t3,0xfff80
ffffffffc0203c54:	000af817          	auipc	a6,0xaf
ffffffffc0203c58:	be480813          	addi	a6,a6,-1052 # ffffffffc02b2838 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0203c5c:	0004b023          	sd	zero,0(s1)
ffffffffc0203c60:	b7a5                	j	ffffffffc0203bc8 <exit_range+0x178>
ffffffffc0203c62:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0203c64:	9c1fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203c68:	000db783          	ld	a5,0(s11)
ffffffffc0203c6c:	6502                	ld	a0,0(sp)
ffffffffc0203c6e:	4585                	li	a1,1
ffffffffc0203c70:	739c                	ld	a5,32(a5)
ffffffffc0203c72:	9782                	jalr	a5
        intr_enable();
ffffffffc0203c74:	9abfc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0203c78:	000af717          	auipc	a4,0xaf
ffffffffc0203c7c:	bb070713          	addi	a4,a4,-1104 # ffffffffc02b2828 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0203c80:	00043023          	sd	zero,0(s0)
ffffffffc0203c84:	bfb5                	j	ffffffffc0203c00 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203c86:	00003697          	auipc	a3,0x3
ffffffffc0203c8a:	1c268693          	addi	a3,a3,450 # ffffffffc0206e48 <commands+0x700>
ffffffffc0203c8e:	00003617          	auipc	a2,0x3
ffffffffc0203c92:	eca60613          	addi	a2,a2,-310 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203c96:	12000593          	li	a1,288
ffffffffc0203c9a:	00004517          	auipc	a0,0x4
ffffffffc0203c9e:	f3650513          	addi	a0,a0,-202 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0203ca2:	d66fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203ca6:	00003617          	auipc	a2,0x3
ffffffffc0203caa:	28260613          	addi	a2,a2,642 # ffffffffc0206f28 <commands+0x7e0>
ffffffffc0203cae:	06900593          	li	a1,105
ffffffffc0203cb2:	00003517          	auipc	a0,0x3
ffffffffc0203cb6:	21650513          	addi	a0,a0,534 # ffffffffc0206ec8 <commands+0x780>
ffffffffc0203cba:	d4efc0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0203cbe:	8e3ff0ef          	jal	ra,ffffffffc02035a0 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0203cc2:	00003697          	auipc	a3,0x3
ffffffffc0203cc6:	1c668693          	addi	a3,a3,454 # ffffffffc0206e88 <commands+0x740>
ffffffffc0203cca:	00003617          	auipc	a2,0x3
ffffffffc0203cce:	e8e60613          	addi	a2,a2,-370 # ffffffffc0206b58 <commands+0x410>
ffffffffc0203cd2:	12100593          	li	a1,289
ffffffffc0203cd6:	00004517          	auipc	a0,0x4
ffffffffc0203cda:	efa50513          	addi	a0,a0,-262 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0203cde:	d2afc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203ce2 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203ce2:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203ce4:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203ce6:	ec26                	sd	s1,24(sp)
ffffffffc0203ce8:	f406                	sd	ra,40(sp)
ffffffffc0203cea:	f022                	sd	s0,32(sp)
ffffffffc0203cec:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203cee:	9f7ff0ef          	jal	ra,ffffffffc02036e4 <get_pte>
    if (ptep != NULL) {
ffffffffc0203cf2:	c511                	beqz	a0,ffffffffc0203cfe <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203cf4:	611c                	ld	a5,0(a0)
ffffffffc0203cf6:	842a                	mv	s0,a0
ffffffffc0203cf8:	0017f713          	andi	a4,a5,1
ffffffffc0203cfc:	e711                	bnez	a4,ffffffffc0203d08 <page_remove+0x26>
}
ffffffffc0203cfe:	70a2                	ld	ra,40(sp)
ffffffffc0203d00:	7402                	ld	s0,32(sp)
ffffffffc0203d02:	64e2                	ld	s1,24(sp)
ffffffffc0203d04:	6145                	addi	sp,sp,48
ffffffffc0203d06:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203d08:	078a                	slli	a5,a5,0x2
ffffffffc0203d0a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203d0c:	000af717          	auipc	a4,0xaf
ffffffffc0203d10:	b1473703          	ld	a4,-1260(a4) # ffffffffc02b2820 <npage>
ffffffffc0203d14:	06e7f363          	bgeu	a5,a4,ffffffffc0203d7a <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d18:	fff80537          	lui	a0,0xfff80
ffffffffc0203d1c:	97aa                	add	a5,a5,a0
ffffffffc0203d1e:	079a                	slli	a5,a5,0x6
ffffffffc0203d20:	000af517          	auipc	a0,0xaf
ffffffffc0203d24:	b0853503          	ld	a0,-1272(a0) # ffffffffc02b2828 <pages>
ffffffffc0203d28:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0203d2a:	411c                	lw	a5,0(a0)
ffffffffc0203d2c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203d30:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203d32:	cb11                	beqz	a4,ffffffffc0203d46 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203d34:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203d38:	12048073          	sfence.vma	s1
}
ffffffffc0203d3c:	70a2                	ld	ra,40(sp)
ffffffffc0203d3e:	7402                	ld	s0,32(sp)
ffffffffc0203d40:	64e2                	ld	s1,24(sp)
ffffffffc0203d42:	6145                	addi	sp,sp,48
ffffffffc0203d44:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203d46:	100027f3          	csrr	a5,sstatus
ffffffffc0203d4a:	8b89                	andi	a5,a5,2
ffffffffc0203d4c:	eb89                	bnez	a5,ffffffffc0203d5e <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0203d4e:	000af797          	auipc	a5,0xaf
ffffffffc0203d52:	ae27b783          	ld	a5,-1310(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0203d56:	739c                	ld	a5,32(a5)
ffffffffc0203d58:	4585                	li	a1,1
ffffffffc0203d5a:	9782                	jalr	a5
    if (flag) {
ffffffffc0203d5c:	bfe1                	j	ffffffffc0203d34 <page_remove+0x52>
        intr_disable();
ffffffffc0203d5e:	e42a                	sd	a0,8(sp)
ffffffffc0203d60:	8c5fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc0203d64:	000af797          	auipc	a5,0xaf
ffffffffc0203d68:	acc7b783          	ld	a5,-1332(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0203d6c:	739c                	ld	a5,32(a5)
ffffffffc0203d6e:	6522                	ld	a0,8(sp)
ffffffffc0203d70:	4585                	li	a1,1
ffffffffc0203d72:	9782                	jalr	a5
        intr_enable();
ffffffffc0203d74:	8abfc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0203d78:	bf75                	j	ffffffffc0203d34 <page_remove+0x52>
ffffffffc0203d7a:	827ff0ef          	jal	ra,ffffffffc02035a0 <pa2page.part.0>

ffffffffc0203d7e <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203d7e:	7139                	addi	sp,sp,-64
ffffffffc0203d80:	e852                	sd	s4,16(sp)
ffffffffc0203d82:	8a32                	mv	s4,a2
ffffffffc0203d84:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203d86:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203d88:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203d8a:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203d8c:	f426                	sd	s1,40(sp)
ffffffffc0203d8e:	fc06                	sd	ra,56(sp)
ffffffffc0203d90:	f04a                	sd	s2,32(sp)
ffffffffc0203d92:	ec4e                	sd	s3,24(sp)
ffffffffc0203d94:	e456                	sd	s5,8(sp)
ffffffffc0203d96:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203d98:	94dff0ef          	jal	ra,ffffffffc02036e4 <get_pte>
    if (ptep == NULL) {
ffffffffc0203d9c:	c961                	beqz	a0,ffffffffc0203e6c <page_insert+0xee>
    page->ref += 1;
ffffffffc0203d9e:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0203da0:	611c                	ld	a5,0(a0)
ffffffffc0203da2:	89aa                	mv	s3,a0
ffffffffc0203da4:	0016871b          	addiw	a4,a3,1
ffffffffc0203da8:	c018                	sw	a4,0(s0)
ffffffffc0203daa:	0017f713          	andi	a4,a5,1
ffffffffc0203dae:	ef05                	bnez	a4,ffffffffc0203de6 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0203db0:	000af717          	auipc	a4,0xaf
ffffffffc0203db4:	a7873703          	ld	a4,-1416(a4) # ffffffffc02b2828 <pages>
ffffffffc0203db8:	8c19                	sub	s0,s0,a4
ffffffffc0203dba:	000807b7          	lui	a5,0x80
ffffffffc0203dbe:	8419                	srai	s0,s0,0x6
ffffffffc0203dc0:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203dc2:	042a                	slli	s0,s0,0xa
ffffffffc0203dc4:	8cc1                	or	s1,s1,s0
ffffffffc0203dc6:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0203dca:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ee0>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203dce:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0203dd2:	4501                	li	a0,0
}
ffffffffc0203dd4:	70e2                	ld	ra,56(sp)
ffffffffc0203dd6:	7442                	ld	s0,48(sp)
ffffffffc0203dd8:	74a2                	ld	s1,40(sp)
ffffffffc0203dda:	7902                	ld	s2,32(sp)
ffffffffc0203ddc:	69e2                	ld	s3,24(sp)
ffffffffc0203dde:	6a42                	ld	s4,16(sp)
ffffffffc0203de0:	6aa2                	ld	s5,8(sp)
ffffffffc0203de2:	6121                	addi	sp,sp,64
ffffffffc0203de4:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203de6:	078a                	slli	a5,a5,0x2
ffffffffc0203de8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203dea:	000af717          	auipc	a4,0xaf
ffffffffc0203dee:	a3673703          	ld	a4,-1482(a4) # ffffffffc02b2820 <npage>
ffffffffc0203df2:	06e7ff63          	bgeu	a5,a4,ffffffffc0203e70 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0203df6:	000afa97          	auipc	s5,0xaf
ffffffffc0203dfa:	a32a8a93          	addi	s5,s5,-1486 # ffffffffc02b2828 <pages>
ffffffffc0203dfe:	000ab703          	ld	a4,0(s5)
ffffffffc0203e02:	fff80937          	lui	s2,0xfff80
ffffffffc0203e06:	993e                	add	s2,s2,a5
ffffffffc0203e08:	091a                	slli	s2,s2,0x6
ffffffffc0203e0a:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0203e0c:	01240c63          	beq	s0,s2,ffffffffc0203e24 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0203e10:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccd7a4>
ffffffffc0203e14:	fff7869b          	addiw	a3,a5,-1
ffffffffc0203e18:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0203e1c:	c691                	beqz	a3,ffffffffc0203e28 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203e1e:	120a0073          	sfence.vma	s4
}
ffffffffc0203e22:	bf59                	j	ffffffffc0203db8 <page_insert+0x3a>
ffffffffc0203e24:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0203e26:	bf49                	j	ffffffffc0203db8 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203e28:	100027f3          	csrr	a5,sstatus
ffffffffc0203e2c:	8b89                	andi	a5,a5,2
ffffffffc0203e2e:	ef91                	bnez	a5,ffffffffc0203e4a <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0203e30:	000af797          	auipc	a5,0xaf
ffffffffc0203e34:	a007b783          	ld	a5,-1536(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0203e38:	739c                	ld	a5,32(a5)
ffffffffc0203e3a:	4585                	li	a1,1
ffffffffc0203e3c:	854a                	mv	a0,s2
ffffffffc0203e3e:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0203e40:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203e44:	120a0073          	sfence.vma	s4
ffffffffc0203e48:	bf85                	j	ffffffffc0203db8 <page_insert+0x3a>
        intr_disable();
ffffffffc0203e4a:	fdafc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203e4e:	000af797          	auipc	a5,0xaf
ffffffffc0203e52:	9e27b783          	ld	a5,-1566(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0203e56:	739c                	ld	a5,32(a5)
ffffffffc0203e58:	4585                	li	a1,1
ffffffffc0203e5a:	854a                	mv	a0,s2
ffffffffc0203e5c:	9782                	jalr	a5
        intr_enable();
ffffffffc0203e5e:	fc0fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0203e62:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203e66:	120a0073          	sfence.vma	s4
ffffffffc0203e6a:	b7b9                	j	ffffffffc0203db8 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0203e6c:	5571                	li	a0,-4
ffffffffc0203e6e:	b79d                	j	ffffffffc0203dd4 <page_insert+0x56>
ffffffffc0203e70:	f30ff0ef          	jal	ra,ffffffffc02035a0 <pa2page.part.0>

ffffffffc0203e74 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0203e74:	00004797          	auipc	a5,0x4
ffffffffc0203e78:	d2478793          	addi	a5,a5,-732 # ffffffffc0207b98 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203e7c:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0203e7e:	711d                	addi	sp,sp,-96
ffffffffc0203e80:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203e82:	00004517          	auipc	a0,0x4
ffffffffc0203e86:	d5e50513          	addi	a0,a0,-674 # ffffffffc0207be0 <default_pmm_manager+0x48>
    pmm_manager = &default_pmm_manager;
ffffffffc0203e8a:	000afb97          	auipc	s7,0xaf
ffffffffc0203e8e:	9a6b8b93          	addi	s7,s7,-1626 # ffffffffc02b2830 <pmm_manager>
void pmm_init(void) {
ffffffffc0203e92:	ec86                	sd	ra,88(sp)
ffffffffc0203e94:	e4a6                	sd	s1,72(sp)
ffffffffc0203e96:	fc4e                	sd	s3,56(sp)
ffffffffc0203e98:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0203e9a:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0203e9e:	e8a2                	sd	s0,80(sp)
ffffffffc0203ea0:	e0ca                	sd	s2,64(sp)
ffffffffc0203ea2:	f852                	sd	s4,48(sp)
ffffffffc0203ea4:	f456                	sd	s5,40(sp)
ffffffffc0203ea6:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203ea8:	a24fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pmm_manager->init();
ffffffffc0203eac:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203eb0:	000af997          	auipc	s3,0xaf
ffffffffc0203eb4:	98898993          	addi	s3,s3,-1656 # ffffffffc02b2838 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0203eb8:	000af497          	auipc	s1,0xaf
ffffffffc0203ebc:	96848493          	addi	s1,s1,-1688 # ffffffffc02b2820 <npage>
    pmm_manager->init();
ffffffffc0203ec0:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203ec2:	000afb17          	auipc	s6,0xaf
ffffffffc0203ec6:	966b0b13          	addi	s6,s6,-1690 # ffffffffc02b2828 <pages>
    pmm_manager->init();
ffffffffc0203eca:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203ecc:	57f5                	li	a5,-3
ffffffffc0203ece:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0203ed0:	00004517          	auipc	a0,0x4
ffffffffc0203ed4:	d2850513          	addi	a0,a0,-728 # ffffffffc0207bf8 <default_pmm_manager+0x60>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203ed8:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc0203edc:	9f0fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0203ee0:	46c5                	li	a3,17
ffffffffc0203ee2:	06ee                	slli	a3,a3,0x1b
ffffffffc0203ee4:	40100613          	li	a2,1025
ffffffffc0203ee8:	07e005b7          	lui	a1,0x7e00
ffffffffc0203eec:	16fd                	addi	a3,a3,-1
ffffffffc0203eee:	0656                	slli	a2,a2,0x15
ffffffffc0203ef0:	00004517          	auipc	a0,0x4
ffffffffc0203ef4:	d2050513          	addi	a0,a0,-736 # ffffffffc0207c10 <default_pmm_manager+0x78>
ffffffffc0203ef8:	9d4fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203efc:	777d                	lui	a4,0xfffff
ffffffffc0203efe:	000b0797          	auipc	a5,0xb0
ffffffffc0203f02:	95d78793          	addi	a5,a5,-1699 # ffffffffc02b385b <end+0xfff>
ffffffffc0203f06:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0203f08:	00088737          	lui	a4,0x88
ffffffffc0203f0c:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203f0e:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203f12:	4701                	li	a4,0
ffffffffc0203f14:	4585                	li	a1,1
ffffffffc0203f16:	fff80837          	lui	a6,0xfff80
ffffffffc0203f1a:	a019                	j	ffffffffc0203f20 <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc0203f1c:	000b3783          	ld	a5,0(s6)
ffffffffc0203f20:	00671693          	slli	a3,a4,0x6
ffffffffc0203f24:	97b6                	add	a5,a5,a3
ffffffffc0203f26:	07a1                	addi	a5,a5,8
ffffffffc0203f28:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203f2c:	6090                	ld	a2,0(s1)
ffffffffc0203f2e:	0705                	addi	a4,a4,1
ffffffffc0203f30:	010607b3          	add	a5,a2,a6
ffffffffc0203f34:	fef764e3          	bltu	a4,a5,ffffffffc0203f1c <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203f38:	000b3503          	ld	a0,0(s6)
ffffffffc0203f3c:	079a                	slli	a5,a5,0x6
ffffffffc0203f3e:	c0200737          	lui	a4,0xc0200
ffffffffc0203f42:	00f506b3          	add	a3,a0,a5
ffffffffc0203f46:	60e6e563          	bltu	a3,a4,ffffffffc0204550 <pmm_init+0x6dc>
ffffffffc0203f4a:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0203f4e:	4745                	li	a4,17
ffffffffc0203f50:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203f52:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0203f54:	4ae6e563          	bltu	a3,a4,ffffffffc02043fe <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0203f58:	00004517          	auipc	a0,0x4
ffffffffc0203f5c:	ce050513          	addi	a0,a0,-800 # ffffffffc0207c38 <default_pmm_manager+0xa0>
ffffffffc0203f60:	96cfc0ef          	jal	ra,ffffffffc02000cc <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0203f64:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203f68:	000af917          	auipc	s2,0xaf
ffffffffc0203f6c:	8b090913          	addi	s2,s2,-1872 # ffffffffc02b2818 <boot_pgdir>
    pmm_manager->check();
ffffffffc0203f70:	7b9c                	ld	a5,48(a5)
ffffffffc0203f72:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0203f74:	00004517          	auipc	a0,0x4
ffffffffc0203f78:	cdc50513          	addi	a0,a0,-804 # ffffffffc0207c50 <default_pmm_manager+0xb8>
ffffffffc0203f7c:	950fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203f80:	00007697          	auipc	a3,0x7
ffffffffc0203f84:	08068693          	addi	a3,a3,128 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0203f88:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203f8c:	c02007b7          	lui	a5,0xc0200
ffffffffc0203f90:	5cf6ec63          	bltu	a3,a5,ffffffffc0204568 <pmm_init+0x6f4>
ffffffffc0203f94:	0009b783          	ld	a5,0(s3)
ffffffffc0203f98:	8e9d                	sub	a3,a3,a5
ffffffffc0203f9a:	000af797          	auipc	a5,0xaf
ffffffffc0203f9e:	86d7bb23          	sd	a3,-1930(a5) # ffffffffc02b2810 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203fa2:	100027f3          	csrr	a5,sstatus
ffffffffc0203fa6:	8b89                	andi	a5,a5,2
ffffffffc0203fa8:	48079263          	bnez	a5,ffffffffc020442c <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203fac:	000bb783          	ld	a5,0(s7)
ffffffffc0203fb0:	779c                	ld	a5,40(a5)
ffffffffc0203fb2:	9782                	jalr	a5
ffffffffc0203fb4:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203fb6:	6098                	ld	a4,0(s1)
ffffffffc0203fb8:	c80007b7          	lui	a5,0xc8000
ffffffffc0203fbc:	83b1                	srli	a5,a5,0xc
ffffffffc0203fbe:	5ee7e163          	bltu	a5,a4,ffffffffc02045a0 <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203fc2:	00093503          	ld	a0,0(s2)
ffffffffc0203fc6:	5a050d63          	beqz	a0,ffffffffc0204580 <pmm_init+0x70c>
ffffffffc0203fca:	03451793          	slli	a5,a0,0x34
ffffffffc0203fce:	5a079963          	bnez	a5,ffffffffc0204580 <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203fd2:	4601                	li	a2,0
ffffffffc0203fd4:	4581                	li	a1,0
ffffffffc0203fd6:	8e1ff0ef          	jal	ra,ffffffffc02038b6 <get_page>
ffffffffc0203fda:	62051563          	bnez	a0,ffffffffc0204604 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0203fde:	4505                	li	a0,1
ffffffffc0203fe0:	df8ff0ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0203fe4:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203fe6:	00093503          	ld	a0,0(s2)
ffffffffc0203fea:	4681                	li	a3,0
ffffffffc0203fec:	4601                	li	a2,0
ffffffffc0203fee:	85d2                	mv	a1,s4
ffffffffc0203ff0:	d8fff0ef          	jal	ra,ffffffffc0203d7e <page_insert>
ffffffffc0203ff4:	5e051863          	bnez	a0,ffffffffc02045e4 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203ff8:	00093503          	ld	a0,0(s2)
ffffffffc0203ffc:	4601                	li	a2,0
ffffffffc0203ffe:	4581                	li	a1,0
ffffffffc0204000:	ee4ff0ef          	jal	ra,ffffffffc02036e4 <get_pte>
ffffffffc0204004:	5c050063          	beqz	a0,ffffffffc02045c4 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc0204008:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020400a:	0017f713          	andi	a4,a5,1
ffffffffc020400e:	5a070963          	beqz	a4,ffffffffc02045c0 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0204012:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0204014:	078a                	slli	a5,a5,0x2
ffffffffc0204016:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204018:	52e7fa63          	bgeu	a5,a4,ffffffffc020454c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020401c:	000b3683          	ld	a3,0(s6)
ffffffffc0204020:	fff80637          	lui	a2,0xfff80
ffffffffc0204024:	97b2                	add	a5,a5,a2
ffffffffc0204026:	079a                	slli	a5,a5,0x6
ffffffffc0204028:	97b6                	add	a5,a5,a3
ffffffffc020402a:	10fa16e3          	bne	s4,a5,ffffffffc0204936 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc020402e:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0204032:	4785                	li	a5,1
ffffffffc0204034:	12f69de3          	bne	a3,a5,ffffffffc020496e <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0204038:	00093503          	ld	a0,0(s2)
ffffffffc020403c:	77fd                	lui	a5,0xfffff
ffffffffc020403e:	6114                	ld	a3,0(a0)
ffffffffc0204040:	068a                	slli	a3,a3,0x2
ffffffffc0204042:	8efd                	and	a3,a3,a5
ffffffffc0204044:	00c6d613          	srli	a2,a3,0xc
ffffffffc0204048:	10e677e3          	bgeu	a2,a4,ffffffffc0204956 <pmm_init+0xae2>
ffffffffc020404c:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0204050:	96e2                	add	a3,a3,s8
ffffffffc0204052:	0006ba83          	ld	s5,0(a3)
ffffffffc0204056:	0a8a                	slli	s5,s5,0x2
ffffffffc0204058:	00fafab3          	and	s5,s5,a5
ffffffffc020405c:	00cad793          	srli	a5,s5,0xc
ffffffffc0204060:	62e7f263          	bgeu	a5,a4,ffffffffc0204684 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0204064:	4601                	li	a2,0
ffffffffc0204066:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0204068:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020406a:	e7aff0ef          	jal	ra,ffffffffc02036e4 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020406e:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0204070:	5f551a63          	bne	a0,s5,ffffffffc0204664 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc0204074:	4505                	li	a0,1
ffffffffc0204076:	d62ff0ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc020407a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020407c:	00093503          	ld	a0,0(s2)
ffffffffc0204080:	46d1                	li	a3,20
ffffffffc0204082:	6605                	lui	a2,0x1
ffffffffc0204084:	85d6                	mv	a1,s5
ffffffffc0204086:	cf9ff0ef          	jal	ra,ffffffffc0203d7e <page_insert>
ffffffffc020408a:	58051d63          	bnez	a0,ffffffffc0204624 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020408e:	00093503          	ld	a0,0(s2)
ffffffffc0204092:	4601                	li	a2,0
ffffffffc0204094:	6585                	lui	a1,0x1
ffffffffc0204096:	e4eff0ef          	jal	ra,ffffffffc02036e4 <get_pte>
ffffffffc020409a:	0e050ae3          	beqz	a0,ffffffffc020498e <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc020409e:	611c                	ld	a5,0(a0)
ffffffffc02040a0:	0107f713          	andi	a4,a5,16
ffffffffc02040a4:	6e070d63          	beqz	a4,ffffffffc020479e <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc02040a8:	8b91                	andi	a5,a5,4
ffffffffc02040aa:	6a078a63          	beqz	a5,ffffffffc020475e <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02040ae:	00093503          	ld	a0,0(s2)
ffffffffc02040b2:	611c                	ld	a5,0(a0)
ffffffffc02040b4:	8bc1                	andi	a5,a5,16
ffffffffc02040b6:	68078463          	beqz	a5,ffffffffc020473e <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc02040ba:	000aa703          	lw	a4,0(s5)
ffffffffc02040be:	4785                	li	a5,1
ffffffffc02040c0:	58f71263          	bne	a4,a5,ffffffffc0204644 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02040c4:	4681                	li	a3,0
ffffffffc02040c6:	6605                	lui	a2,0x1
ffffffffc02040c8:	85d2                	mv	a1,s4
ffffffffc02040ca:	cb5ff0ef          	jal	ra,ffffffffc0203d7e <page_insert>
ffffffffc02040ce:	62051863          	bnez	a0,ffffffffc02046fe <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc02040d2:	000a2703          	lw	a4,0(s4)
ffffffffc02040d6:	4789                	li	a5,2
ffffffffc02040d8:	60f71363          	bne	a4,a5,ffffffffc02046de <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc02040dc:	000aa783          	lw	a5,0(s5)
ffffffffc02040e0:	5c079f63          	bnez	a5,ffffffffc02046be <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02040e4:	00093503          	ld	a0,0(s2)
ffffffffc02040e8:	4601                	li	a2,0
ffffffffc02040ea:	6585                	lui	a1,0x1
ffffffffc02040ec:	df8ff0ef          	jal	ra,ffffffffc02036e4 <get_pte>
ffffffffc02040f0:	5a050763          	beqz	a0,ffffffffc020469e <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc02040f4:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02040f6:	00177793          	andi	a5,a4,1
ffffffffc02040fa:	4c078363          	beqz	a5,ffffffffc02045c0 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc02040fe:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0204100:	00271793          	slli	a5,a4,0x2
ffffffffc0204104:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204106:	44d7f363          	bgeu	a5,a3,ffffffffc020454c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020410a:	000b3683          	ld	a3,0(s6)
ffffffffc020410e:	fff80637          	lui	a2,0xfff80
ffffffffc0204112:	97b2                	add	a5,a5,a2
ffffffffc0204114:	079a                	slli	a5,a5,0x6
ffffffffc0204116:	97b6                	add	a5,a5,a3
ffffffffc0204118:	6efa1363          	bne	s4,a5,ffffffffc02047fe <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc020411c:	8b41                	andi	a4,a4,16
ffffffffc020411e:	6c071063          	bnez	a4,ffffffffc02047de <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc0204122:	00093503          	ld	a0,0(s2)
ffffffffc0204126:	4581                	li	a1,0
ffffffffc0204128:	bbbff0ef          	jal	ra,ffffffffc0203ce2 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020412c:	000a2703          	lw	a4,0(s4)
ffffffffc0204130:	4785                	li	a5,1
ffffffffc0204132:	68f71663          	bne	a4,a5,ffffffffc02047be <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc0204136:	000aa783          	lw	a5,0(s5)
ffffffffc020413a:	74079e63          	bnez	a5,ffffffffc0204896 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020413e:	00093503          	ld	a0,0(s2)
ffffffffc0204142:	6585                	lui	a1,0x1
ffffffffc0204144:	b9fff0ef          	jal	ra,ffffffffc0203ce2 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0204148:	000a2783          	lw	a5,0(s4)
ffffffffc020414c:	72079563          	bnez	a5,ffffffffc0204876 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc0204150:	000aa783          	lw	a5,0(s5)
ffffffffc0204154:	70079163          	bnez	a5,ffffffffc0204856 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0204158:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020415c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020415e:	000a3683          	ld	a3,0(s4)
ffffffffc0204162:	068a                	slli	a3,a3,0x2
ffffffffc0204164:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204166:	3ee6f363          	bgeu	a3,a4,ffffffffc020454c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020416a:	fff807b7          	lui	a5,0xfff80
ffffffffc020416e:	000b3503          	ld	a0,0(s6)
ffffffffc0204172:	96be                	add	a3,a3,a5
ffffffffc0204174:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0204176:	00d507b3          	add	a5,a0,a3
ffffffffc020417a:	4390                	lw	a2,0(a5)
ffffffffc020417c:	4785                	li	a5,1
ffffffffc020417e:	6af61c63          	bne	a2,a5,ffffffffc0204836 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc0204182:	8699                	srai	a3,a3,0x6
ffffffffc0204184:	000805b7          	lui	a1,0x80
ffffffffc0204188:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc020418a:	00c69613          	slli	a2,a3,0xc
ffffffffc020418e:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204190:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204192:	68e67663          	bgeu	a2,a4,ffffffffc020481e <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0204196:	0009b603          	ld	a2,0(s3)
ffffffffc020419a:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc020419c:	629c                	ld	a5,0(a3)
ffffffffc020419e:	078a                	slli	a5,a5,0x2
ffffffffc02041a0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02041a2:	3ae7f563          	bgeu	a5,a4,ffffffffc020454c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02041a6:	8f8d                	sub	a5,a5,a1
ffffffffc02041a8:	079a                	slli	a5,a5,0x6
ffffffffc02041aa:	953e                	add	a0,a0,a5
ffffffffc02041ac:	100027f3          	csrr	a5,sstatus
ffffffffc02041b0:	8b89                	andi	a5,a5,2
ffffffffc02041b2:	2c079763          	bnez	a5,ffffffffc0204480 <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc02041b6:	000bb783          	ld	a5,0(s7)
ffffffffc02041ba:	4585                	li	a1,1
ffffffffc02041bc:	739c                	ld	a5,32(a5)
ffffffffc02041be:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02041c0:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02041c4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02041c6:	078a                	slli	a5,a5,0x2
ffffffffc02041c8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02041ca:	38e7f163          	bgeu	a5,a4,ffffffffc020454c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02041ce:	000b3503          	ld	a0,0(s6)
ffffffffc02041d2:	fff80737          	lui	a4,0xfff80
ffffffffc02041d6:	97ba                	add	a5,a5,a4
ffffffffc02041d8:	079a                	slli	a5,a5,0x6
ffffffffc02041da:	953e                	add	a0,a0,a5
ffffffffc02041dc:	100027f3          	csrr	a5,sstatus
ffffffffc02041e0:	8b89                	andi	a5,a5,2
ffffffffc02041e2:	28079363          	bnez	a5,ffffffffc0204468 <pmm_init+0x5f4>
ffffffffc02041e6:	000bb783          	ld	a5,0(s7)
ffffffffc02041ea:	4585                	li	a1,1
ffffffffc02041ec:	739c                	ld	a5,32(a5)
ffffffffc02041ee:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02041f0:	00093783          	ld	a5,0(s2)
ffffffffc02041f4:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fccd7a4>
  asm volatile("sfence.vma");
ffffffffc02041f8:	12000073          	sfence.vma
ffffffffc02041fc:	100027f3          	csrr	a5,sstatus
ffffffffc0204200:	8b89                	andi	a5,a5,2
ffffffffc0204202:	24079963          	bnez	a5,ffffffffc0204454 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0204206:	000bb783          	ld	a5,0(s7)
ffffffffc020420a:	779c                	ld	a5,40(a5)
ffffffffc020420c:	9782                	jalr	a5
ffffffffc020420e:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0204210:	71441363          	bne	s0,s4,ffffffffc0204916 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0204214:	00004517          	auipc	a0,0x4
ffffffffc0204218:	d2450513          	addi	a0,a0,-732 # ffffffffc0207f38 <default_pmm_manager+0x3a0>
ffffffffc020421c:	eb1fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0204220:	100027f3          	csrr	a5,sstatus
ffffffffc0204224:	8b89                	andi	a5,a5,2
ffffffffc0204226:	20079d63          	bnez	a5,ffffffffc0204440 <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc020422a:	000bb783          	ld	a5,0(s7)
ffffffffc020422e:	779c                	ld	a5,40(a5)
ffffffffc0204230:	9782                	jalr	a5
ffffffffc0204232:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0204234:	6098                	ld	a4,0(s1)
ffffffffc0204236:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020423a:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020423c:	00c71793          	slli	a5,a4,0xc
ffffffffc0204240:	6a05                	lui	s4,0x1
ffffffffc0204242:	02f47c63          	bgeu	s0,a5,ffffffffc020427a <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0204246:	00c45793          	srli	a5,s0,0xc
ffffffffc020424a:	00093503          	ld	a0,0(s2)
ffffffffc020424e:	2ee7f263          	bgeu	a5,a4,ffffffffc0204532 <pmm_init+0x6be>
ffffffffc0204252:	0009b583          	ld	a1,0(s3)
ffffffffc0204256:	4601                	li	a2,0
ffffffffc0204258:	95a2                	add	a1,a1,s0
ffffffffc020425a:	c8aff0ef          	jal	ra,ffffffffc02036e4 <get_pte>
ffffffffc020425e:	2a050a63          	beqz	a0,ffffffffc0204512 <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0204262:	611c                	ld	a5,0(a0)
ffffffffc0204264:	078a                	slli	a5,a5,0x2
ffffffffc0204266:	0157f7b3          	and	a5,a5,s5
ffffffffc020426a:	28879463          	bne	a5,s0,ffffffffc02044f2 <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020426e:	6098                	ld	a4,0(s1)
ffffffffc0204270:	9452                	add	s0,s0,s4
ffffffffc0204272:	00c71793          	slli	a5,a4,0xc
ffffffffc0204276:	fcf468e3          	bltu	s0,a5,ffffffffc0204246 <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc020427a:	00093783          	ld	a5,0(s2)
ffffffffc020427e:	639c                	ld	a5,0(a5)
ffffffffc0204280:	66079b63          	bnez	a5,ffffffffc02048f6 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc0204284:	4505                	li	a0,1
ffffffffc0204286:	b52ff0ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc020428a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020428c:	00093503          	ld	a0,0(s2)
ffffffffc0204290:	4699                	li	a3,6
ffffffffc0204292:	10000613          	li	a2,256
ffffffffc0204296:	85d6                	mv	a1,s5
ffffffffc0204298:	ae7ff0ef          	jal	ra,ffffffffc0203d7e <page_insert>
ffffffffc020429c:	62051d63          	bnez	a0,ffffffffc02048d6 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc02042a0:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd4c7a4>
ffffffffc02042a4:	4785                	li	a5,1
ffffffffc02042a6:	60f71863          	bne	a4,a5,ffffffffc02048b6 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02042aa:	00093503          	ld	a0,0(s2)
ffffffffc02042ae:	6405                	lui	s0,0x1
ffffffffc02042b0:	4699                	li	a3,6
ffffffffc02042b2:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ab0>
ffffffffc02042b6:	85d6                	mv	a1,s5
ffffffffc02042b8:	ac7ff0ef          	jal	ra,ffffffffc0203d7e <page_insert>
ffffffffc02042bc:	46051163          	bnez	a0,ffffffffc020471e <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc02042c0:	000aa703          	lw	a4,0(s5)
ffffffffc02042c4:	4789                	li	a5,2
ffffffffc02042c6:	72f71463          	bne	a4,a5,ffffffffc02049ee <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02042ca:	00004597          	auipc	a1,0x4
ffffffffc02042ce:	da658593          	addi	a1,a1,-602 # ffffffffc0208070 <default_pmm_manager+0x4d8>
ffffffffc02042d2:	10000513          	li	a0,256
ffffffffc02042d6:	553010ef          	jal	ra,ffffffffc0206028 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02042da:	10040593          	addi	a1,s0,256
ffffffffc02042de:	10000513          	li	a0,256
ffffffffc02042e2:	559010ef          	jal	ra,ffffffffc020603a <strcmp>
ffffffffc02042e6:	6e051463          	bnez	a0,ffffffffc02049ce <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc02042ea:	000b3683          	ld	a3,0(s6)
ffffffffc02042ee:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc02042f2:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc02042f4:	40da86b3          	sub	a3,s5,a3
ffffffffc02042f8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02042fa:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc02042fc:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02042fe:	8031                	srli	s0,s0,0xc
ffffffffc0204300:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0204304:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204306:	50f77c63          	bgeu	a4,a5,ffffffffc020481e <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020430a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020430e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0204312:	96be                	add	a3,a3,a5
ffffffffc0204314:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0204318:	4db010ef          	jal	ra,ffffffffc0205ff2 <strlen>
ffffffffc020431c:	68051963          	bnez	a0,ffffffffc02049ae <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0204320:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204324:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204326:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc020432a:	068a                	slli	a3,a3,0x2
ffffffffc020432c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020432e:	20f6ff63          	bgeu	a3,a5,ffffffffc020454c <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc0204332:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204334:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204336:	4ef47463          	bgeu	s0,a5,ffffffffc020481e <pmm_init+0x9aa>
ffffffffc020433a:	0009b403          	ld	s0,0(s3)
ffffffffc020433e:	9436                	add	s0,s0,a3
ffffffffc0204340:	100027f3          	csrr	a5,sstatus
ffffffffc0204344:	8b89                	andi	a5,a5,2
ffffffffc0204346:	18079b63          	bnez	a5,ffffffffc02044dc <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc020434a:	000bb783          	ld	a5,0(s7)
ffffffffc020434e:	4585                	li	a1,1
ffffffffc0204350:	8556                	mv	a0,s5
ffffffffc0204352:	739c                	ld	a5,32(a5)
ffffffffc0204354:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0204356:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0204358:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020435a:	078a                	slli	a5,a5,0x2
ffffffffc020435c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020435e:	1ee7f763          	bgeu	a5,a4,ffffffffc020454c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0204362:	000b3503          	ld	a0,0(s6)
ffffffffc0204366:	fff80737          	lui	a4,0xfff80
ffffffffc020436a:	97ba                	add	a5,a5,a4
ffffffffc020436c:	079a                	slli	a5,a5,0x6
ffffffffc020436e:	953e                	add	a0,a0,a5
ffffffffc0204370:	100027f3          	csrr	a5,sstatus
ffffffffc0204374:	8b89                	andi	a5,a5,2
ffffffffc0204376:	14079763          	bnez	a5,ffffffffc02044c4 <pmm_init+0x650>
ffffffffc020437a:	000bb783          	ld	a5,0(s7)
ffffffffc020437e:	4585                	li	a1,1
ffffffffc0204380:	739c                	ld	a5,32(a5)
ffffffffc0204382:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0204384:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0204388:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020438a:	078a                	slli	a5,a5,0x2
ffffffffc020438c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020438e:	1ae7ff63          	bgeu	a5,a4,ffffffffc020454c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0204392:	000b3503          	ld	a0,0(s6)
ffffffffc0204396:	fff80737          	lui	a4,0xfff80
ffffffffc020439a:	97ba                	add	a5,a5,a4
ffffffffc020439c:	079a                	slli	a5,a5,0x6
ffffffffc020439e:	953e                	add	a0,a0,a5
ffffffffc02043a0:	100027f3          	csrr	a5,sstatus
ffffffffc02043a4:	8b89                	andi	a5,a5,2
ffffffffc02043a6:	10079363          	bnez	a5,ffffffffc02044ac <pmm_init+0x638>
ffffffffc02043aa:	000bb783          	ld	a5,0(s7)
ffffffffc02043ae:	4585                	li	a1,1
ffffffffc02043b0:	739c                	ld	a5,32(a5)
ffffffffc02043b2:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02043b4:	00093783          	ld	a5,0(s2)
ffffffffc02043b8:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02043bc:	12000073          	sfence.vma
ffffffffc02043c0:	100027f3          	csrr	a5,sstatus
ffffffffc02043c4:	8b89                	andi	a5,a5,2
ffffffffc02043c6:	0c079963          	bnez	a5,ffffffffc0204498 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc02043ca:	000bb783          	ld	a5,0(s7)
ffffffffc02043ce:	779c                	ld	a5,40(a5)
ffffffffc02043d0:	9782                	jalr	a5
ffffffffc02043d2:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02043d4:	3a8c1563          	bne	s8,s0,ffffffffc020477e <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02043d8:	00004517          	auipc	a0,0x4
ffffffffc02043dc:	d1050513          	addi	a0,a0,-752 # ffffffffc02080e8 <default_pmm_manager+0x550>
ffffffffc02043e0:	cedfb0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02043e4:	6446                	ld	s0,80(sp)
ffffffffc02043e6:	60e6                	ld	ra,88(sp)
ffffffffc02043e8:	64a6                	ld	s1,72(sp)
ffffffffc02043ea:	6906                	ld	s2,64(sp)
ffffffffc02043ec:	79e2                	ld	s3,56(sp)
ffffffffc02043ee:	7a42                	ld	s4,48(sp)
ffffffffc02043f0:	7aa2                	ld	s5,40(sp)
ffffffffc02043f2:	7b02                	ld	s6,32(sp)
ffffffffc02043f4:	6be2                	ld	s7,24(sp)
ffffffffc02043f6:	6c42                	ld	s8,16(sp)
ffffffffc02043f8:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc02043fa:	c9ffd06f          	j	ffffffffc0202098 <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02043fe:	6785                	lui	a5,0x1
ffffffffc0204400:	17fd                	addi	a5,a5,-1
ffffffffc0204402:	96be                	add	a3,a3,a5
ffffffffc0204404:	77fd                	lui	a5,0xfffff
ffffffffc0204406:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0204408:	00c7d693          	srli	a3,a5,0xc
ffffffffc020440c:	14c6f063          	bgeu	a3,a2,ffffffffc020454c <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0204410:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0204414:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0204416:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc020441a:	6a10                	ld	a2,16(a2)
ffffffffc020441c:	069a                	slli	a3,a3,0x6
ffffffffc020441e:	00c7d593          	srli	a1,a5,0xc
ffffffffc0204422:	9536                	add	a0,a0,a3
ffffffffc0204424:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0204426:	0009b583          	ld	a1,0(s3)
}
ffffffffc020442a:	b63d                	j	ffffffffc0203f58 <pmm_init+0xe4>
        intr_disable();
ffffffffc020442c:	9f8fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0204430:	000bb783          	ld	a5,0(s7)
ffffffffc0204434:	779c                	ld	a5,40(a5)
ffffffffc0204436:	9782                	jalr	a5
ffffffffc0204438:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020443a:	9e4fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc020443e:	bea5                	j	ffffffffc0203fb6 <pmm_init+0x142>
        intr_disable();
ffffffffc0204440:	9e4fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc0204444:	000bb783          	ld	a5,0(s7)
ffffffffc0204448:	779c                	ld	a5,40(a5)
ffffffffc020444a:	9782                	jalr	a5
ffffffffc020444c:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc020444e:	9d0fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0204452:	b3cd                	j	ffffffffc0204234 <pmm_init+0x3c0>
        intr_disable();
ffffffffc0204454:	9d0fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc0204458:	000bb783          	ld	a5,0(s7)
ffffffffc020445c:	779c                	ld	a5,40(a5)
ffffffffc020445e:	9782                	jalr	a5
ffffffffc0204460:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0204462:	9bcfc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0204466:	b36d                	j	ffffffffc0204210 <pmm_init+0x39c>
ffffffffc0204468:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020446a:	9bafc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020446e:	000bb783          	ld	a5,0(s7)
ffffffffc0204472:	6522                	ld	a0,8(sp)
ffffffffc0204474:	4585                	li	a1,1
ffffffffc0204476:	739c                	ld	a5,32(a5)
ffffffffc0204478:	9782                	jalr	a5
        intr_enable();
ffffffffc020447a:	9a4fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc020447e:	bb8d                	j	ffffffffc02041f0 <pmm_init+0x37c>
ffffffffc0204480:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204482:	9a2fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc0204486:	000bb783          	ld	a5,0(s7)
ffffffffc020448a:	6522                	ld	a0,8(sp)
ffffffffc020448c:	4585                	li	a1,1
ffffffffc020448e:	739c                	ld	a5,32(a5)
ffffffffc0204490:	9782                	jalr	a5
        intr_enable();
ffffffffc0204492:	98cfc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0204496:	b32d                	j	ffffffffc02041c0 <pmm_init+0x34c>
        intr_disable();
ffffffffc0204498:	98cfc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020449c:	000bb783          	ld	a5,0(s7)
ffffffffc02044a0:	779c                	ld	a5,40(a5)
ffffffffc02044a2:	9782                	jalr	a5
ffffffffc02044a4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02044a6:	978fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc02044aa:	b72d                	j	ffffffffc02043d4 <pmm_init+0x560>
ffffffffc02044ac:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02044ae:	976fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02044b2:	000bb783          	ld	a5,0(s7)
ffffffffc02044b6:	6522                	ld	a0,8(sp)
ffffffffc02044b8:	4585                	li	a1,1
ffffffffc02044ba:	739c                	ld	a5,32(a5)
ffffffffc02044bc:	9782                	jalr	a5
        intr_enable();
ffffffffc02044be:	960fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc02044c2:	bdcd                	j	ffffffffc02043b4 <pmm_init+0x540>
ffffffffc02044c4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02044c6:	95efc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc02044ca:	000bb783          	ld	a5,0(s7)
ffffffffc02044ce:	6522                	ld	a0,8(sp)
ffffffffc02044d0:	4585                	li	a1,1
ffffffffc02044d2:	739c                	ld	a5,32(a5)
ffffffffc02044d4:	9782                	jalr	a5
        intr_enable();
ffffffffc02044d6:	948fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc02044da:	b56d                	j	ffffffffc0204384 <pmm_init+0x510>
        intr_disable();
ffffffffc02044dc:	948fc0ef          	jal	ra,ffffffffc0200624 <intr_disable>
ffffffffc02044e0:	000bb783          	ld	a5,0(s7)
ffffffffc02044e4:	4585                	li	a1,1
ffffffffc02044e6:	8556                	mv	a0,s5
ffffffffc02044e8:	739c                	ld	a5,32(a5)
ffffffffc02044ea:	9782                	jalr	a5
        intr_enable();
ffffffffc02044ec:	932fc0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc02044f0:	b59d                	j	ffffffffc0204356 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02044f2:	00004697          	auipc	a3,0x4
ffffffffc02044f6:	aa668693          	addi	a3,a3,-1370 # ffffffffc0207f98 <default_pmm_manager+0x400>
ffffffffc02044fa:	00002617          	auipc	a2,0x2
ffffffffc02044fe:	65e60613          	addi	a2,a2,1630 # ffffffffc0206b58 <commands+0x410>
ffffffffc0204502:	23300593          	li	a1,563
ffffffffc0204506:	00003517          	auipc	a0,0x3
ffffffffc020450a:	6ca50513          	addi	a0,a0,1738 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc020450e:	cfbfb0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0204512:	00004697          	auipc	a3,0x4
ffffffffc0204516:	a4668693          	addi	a3,a3,-1466 # ffffffffc0207f58 <default_pmm_manager+0x3c0>
ffffffffc020451a:	00002617          	auipc	a2,0x2
ffffffffc020451e:	63e60613          	addi	a2,a2,1598 # ffffffffc0206b58 <commands+0x410>
ffffffffc0204522:	23200593          	li	a1,562
ffffffffc0204526:	00003517          	auipc	a0,0x3
ffffffffc020452a:	6aa50513          	addi	a0,a0,1706 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc020452e:	cdbfb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204532:	86a2                	mv	a3,s0
ffffffffc0204534:	00003617          	auipc	a2,0x3
ffffffffc0204538:	9f460613          	addi	a2,a2,-1548 # ffffffffc0206f28 <commands+0x7e0>
ffffffffc020453c:	23200593          	li	a1,562
ffffffffc0204540:	00003517          	auipc	a0,0x3
ffffffffc0204544:	69050513          	addi	a0,a0,1680 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0204548:	cc1fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc020454c:	854ff0ef          	jal	ra,ffffffffc02035a0 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0204550:	00003617          	auipc	a2,0x3
ffffffffc0204554:	f7060613          	addi	a2,a2,-144 # ffffffffc02074c0 <commands+0xd78>
ffffffffc0204558:	07f00593          	li	a1,127
ffffffffc020455c:	00003517          	auipc	a0,0x3
ffffffffc0204560:	67450513          	addi	a0,a0,1652 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0204564:	ca5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0204568:	00003617          	auipc	a2,0x3
ffffffffc020456c:	f5860613          	addi	a2,a2,-168 # ffffffffc02074c0 <commands+0xd78>
ffffffffc0204570:	0c100593          	li	a1,193
ffffffffc0204574:	00003517          	auipc	a0,0x3
ffffffffc0204578:	65c50513          	addi	a0,a0,1628 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc020457c:	c8dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0204580:	00003697          	auipc	a3,0x3
ffffffffc0204584:	71068693          	addi	a3,a3,1808 # ffffffffc0207c90 <default_pmm_manager+0xf8>
ffffffffc0204588:	00002617          	auipc	a2,0x2
ffffffffc020458c:	5d060613          	addi	a2,a2,1488 # ffffffffc0206b58 <commands+0x410>
ffffffffc0204590:	1f600593          	li	a1,502
ffffffffc0204594:	00003517          	auipc	a0,0x3
ffffffffc0204598:	63c50513          	addi	a0,a0,1596 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc020459c:	c6dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02045a0:	00003697          	auipc	a3,0x3
ffffffffc02045a4:	6d068693          	addi	a3,a3,1744 # ffffffffc0207c70 <default_pmm_manager+0xd8>
ffffffffc02045a8:	00002617          	auipc	a2,0x2
ffffffffc02045ac:	5b060613          	addi	a2,a2,1456 # ffffffffc0206b58 <commands+0x410>
ffffffffc02045b0:	1f500593          	li	a1,501
ffffffffc02045b4:	00003517          	auipc	a0,0x3
ffffffffc02045b8:	61c50513          	addi	a0,a0,1564 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc02045bc:	c4dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02045c0:	ffdfe0ef          	jal	ra,ffffffffc02035bc <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02045c4:	00003697          	auipc	a3,0x3
ffffffffc02045c8:	75c68693          	addi	a3,a3,1884 # ffffffffc0207d20 <default_pmm_manager+0x188>
ffffffffc02045cc:	00002617          	auipc	a2,0x2
ffffffffc02045d0:	58c60613          	addi	a2,a2,1420 # ffffffffc0206b58 <commands+0x410>
ffffffffc02045d4:	1fe00593          	li	a1,510
ffffffffc02045d8:	00003517          	auipc	a0,0x3
ffffffffc02045dc:	5f850513          	addi	a0,a0,1528 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc02045e0:	c29fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02045e4:	00003697          	auipc	a3,0x3
ffffffffc02045e8:	70c68693          	addi	a3,a3,1804 # ffffffffc0207cf0 <default_pmm_manager+0x158>
ffffffffc02045ec:	00002617          	auipc	a2,0x2
ffffffffc02045f0:	56c60613          	addi	a2,a2,1388 # ffffffffc0206b58 <commands+0x410>
ffffffffc02045f4:	1fb00593          	li	a1,507
ffffffffc02045f8:	00003517          	auipc	a0,0x3
ffffffffc02045fc:	5d850513          	addi	a0,a0,1496 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0204600:	c09fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0204604:	00003697          	auipc	a3,0x3
ffffffffc0204608:	6c468693          	addi	a3,a3,1732 # ffffffffc0207cc8 <default_pmm_manager+0x130>
ffffffffc020460c:	00002617          	auipc	a2,0x2
ffffffffc0204610:	54c60613          	addi	a2,a2,1356 # ffffffffc0206b58 <commands+0x410>
ffffffffc0204614:	1f700593          	li	a1,503
ffffffffc0204618:	00003517          	auipc	a0,0x3
ffffffffc020461c:	5b850513          	addi	a0,a0,1464 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0204620:	be9fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0204624:	00003697          	auipc	a3,0x3
ffffffffc0204628:	78468693          	addi	a3,a3,1924 # ffffffffc0207da8 <default_pmm_manager+0x210>
ffffffffc020462c:	00002617          	auipc	a2,0x2
ffffffffc0204630:	52c60613          	addi	a2,a2,1324 # ffffffffc0206b58 <commands+0x410>
ffffffffc0204634:	20700593          	li	a1,519
ffffffffc0204638:	00003517          	auipc	a0,0x3
ffffffffc020463c:	59850513          	addi	a0,a0,1432 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0204640:	bc9fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0204644:	00004697          	auipc	a3,0x4
ffffffffc0204648:	80468693          	addi	a3,a3,-2044 # ffffffffc0207e48 <default_pmm_manager+0x2b0>
ffffffffc020464c:	00002617          	auipc	a2,0x2
ffffffffc0204650:	50c60613          	addi	a2,a2,1292 # ffffffffc0206b58 <commands+0x410>
ffffffffc0204654:	20c00593          	li	a1,524
ffffffffc0204658:	00003517          	auipc	a0,0x3
ffffffffc020465c:	57850513          	addi	a0,a0,1400 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0204660:	ba9fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0204664:	00003697          	auipc	a3,0x3
ffffffffc0204668:	71c68693          	addi	a3,a3,1820 # ffffffffc0207d80 <default_pmm_manager+0x1e8>
ffffffffc020466c:	00002617          	auipc	a2,0x2
ffffffffc0204670:	4ec60613          	addi	a2,a2,1260 # ffffffffc0206b58 <commands+0x410>
ffffffffc0204674:	20400593          	li	a1,516
ffffffffc0204678:	00003517          	auipc	a0,0x3
ffffffffc020467c:	55850513          	addi	a0,a0,1368 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0204680:	b89fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0204684:	86d6                	mv	a3,s5
ffffffffc0204686:	00003617          	auipc	a2,0x3
ffffffffc020468a:	8a260613          	addi	a2,a2,-1886 # ffffffffc0206f28 <commands+0x7e0>
ffffffffc020468e:	20300593          	li	a1,515
ffffffffc0204692:	00003517          	auipc	a0,0x3
ffffffffc0204696:	53e50513          	addi	a0,a0,1342 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc020469a:	b6ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020469e:	00003697          	auipc	a3,0x3
ffffffffc02046a2:	74268693          	addi	a3,a3,1858 # ffffffffc0207de0 <default_pmm_manager+0x248>
ffffffffc02046a6:	00002617          	auipc	a2,0x2
ffffffffc02046aa:	4b260613          	addi	a2,a2,1202 # ffffffffc0206b58 <commands+0x410>
ffffffffc02046ae:	21100593          	li	a1,529
ffffffffc02046b2:	00003517          	auipc	a0,0x3
ffffffffc02046b6:	51e50513          	addi	a0,a0,1310 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc02046ba:	b4ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02046be:	00003697          	auipc	a3,0x3
ffffffffc02046c2:	7ea68693          	addi	a3,a3,2026 # ffffffffc0207ea8 <default_pmm_manager+0x310>
ffffffffc02046c6:	00002617          	auipc	a2,0x2
ffffffffc02046ca:	49260613          	addi	a2,a2,1170 # ffffffffc0206b58 <commands+0x410>
ffffffffc02046ce:	21000593          	li	a1,528
ffffffffc02046d2:	00003517          	auipc	a0,0x3
ffffffffc02046d6:	4fe50513          	addi	a0,a0,1278 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc02046da:	b2ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02046de:	00003697          	auipc	a3,0x3
ffffffffc02046e2:	7b268693          	addi	a3,a3,1970 # ffffffffc0207e90 <default_pmm_manager+0x2f8>
ffffffffc02046e6:	00002617          	auipc	a2,0x2
ffffffffc02046ea:	47260613          	addi	a2,a2,1138 # ffffffffc0206b58 <commands+0x410>
ffffffffc02046ee:	20f00593          	li	a1,527
ffffffffc02046f2:	00003517          	auipc	a0,0x3
ffffffffc02046f6:	4de50513          	addi	a0,a0,1246 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc02046fa:	b0ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02046fe:	00003697          	auipc	a3,0x3
ffffffffc0204702:	76268693          	addi	a3,a3,1890 # ffffffffc0207e60 <default_pmm_manager+0x2c8>
ffffffffc0204706:	00002617          	auipc	a2,0x2
ffffffffc020470a:	45260613          	addi	a2,a2,1106 # ffffffffc0206b58 <commands+0x410>
ffffffffc020470e:	20e00593          	li	a1,526
ffffffffc0204712:	00003517          	auipc	a0,0x3
ffffffffc0204716:	4be50513          	addi	a0,a0,1214 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc020471a:	aeffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020471e:	00004697          	auipc	a3,0x4
ffffffffc0204722:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0208018 <default_pmm_manager+0x480>
ffffffffc0204726:	00002617          	auipc	a2,0x2
ffffffffc020472a:	43260613          	addi	a2,a2,1074 # ffffffffc0206b58 <commands+0x410>
ffffffffc020472e:	23d00593          	li	a1,573
ffffffffc0204732:	00003517          	auipc	a0,0x3
ffffffffc0204736:	49e50513          	addi	a0,a0,1182 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc020473a:	acffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020473e:	00003697          	auipc	a3,0x3
ffffffffc0204742:	6f268693          	addi	a3,a3,1778 # ffffffffc0207e30 <default_pmm_manager+0x298>
ffffffffc0204746:	00002617          	auipc	a2,0x2
ffffffffc020474a:	41260613          	addi	a2,a2,1042 # ffffffffc0206b58 <commands+0x410>
ffffffffc020474e:	20b00593          	li	a1,523
ffffffffc0204752:	00003517          	auipc	a0,0x3
ffffffffc0204756:	47e50513          	addi	a0,a0,1150 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc020475a:	aaffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020475e:	00003697          	auipc	a3,0x3
ffffffffc0204762:	6c268693          	addi	a3,a3,1730 # ffffffffc0207e20 <default_pmm_manager+0x288>
ffffffffc0204766:	00002617          	auipc	a2,0x2
ffffffffc020476a:	3f260613          	addi	a2,a2,1010 # ffffffffc0206b58 <commands+0x410>
ffffffffc020476e:	20a00593          	li	a1,522
ffffffffc0204772:	00003517          	auipc	a0,0x3
ffffffffc0204776:	45e50513          	addi	a0,a0,1118 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc020477a:	a8ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020477e:	00003697          	auipc	a3,0x3
ffffffffc0204782:	79a68693          	addi	a3,a3,1946 # ffffffffc0207f18 <default_pmm_manager+0x380>
ffffffffc0204786:	00002617          	auipc	a2,0x2
ffffffffc020478a:	3d260613          	addi	a2,a2,978 # ffffffffc0206b58 <commands+0x410>
ffffffffc020478e:	24e00593          	li	a1,590
ffffffffc0204792:	00003517          	auipc	a0,0x3
ffffffffc0204796:	43e50513          	addi	a0,a0,1086 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc020479a:	a6ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020479e:	00003697          	auipc	a3,0x3
ffffffffc02047a2:	67268693          	addi	a3,a3,1650 # ffffffffc0207e10 <default_pmm_manager+0x278>
ffffffffc02047a6:	00002617          	auipc	a2,0x2
ffffffffc02047aa:	3b260613          	addi	a2,a2,946 # ffffffffc0206b58 <commands+0x410>
ffffffffc02047ae:	20900593          	li	a1,521
ffffffffc02047b2:	00003517          	auipc	a0,0x3
ffffffffc02047b6:	41e50513          	addi	a0,a0,1054 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc02047ba:	a4ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02047be:	00003697          	auipc	a3,0x3
ffffffffc02047c2:	5aa68693          	addi	a3,a3,1450 # ffffffffc0207d68 <default_pmm_manager+0x1d0>
ffffffffc02047c6:	00002617          	auipc	a2,0x2
ffffffffc02047ca:	39260613          	addi	a2,a2,914 # ffffffffc0206b58 <commands+0x410>
ffffffffc02047ce:	21600593          	li	a1,534
ffffffffc02047d2:	00003517          	auipc	a0,0x3
ffffffffc02047d6:	3fe50513          	addi	a0,a0,1022 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc02047da:	a2ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02047de:	00003697          	auipc	a3,0x3
ffffffffc02047e2:	6e268693          	addi	a3,a3,1762 # ffffffffc0207ec0 <default_pmm_manager+0x328>
ffffffffc02047e6:	00002617          	auipc	a2,0x2
ffffffffc02047ea:	37260613          	addi	a2,a2,882 # ffffffffc0206b58 <commands+0x410>
ffffffffc02047ee:	21300593          	li	a1,531
ffffffffc02047f2:	00003517          	auipc	a0,0x3
ffffffffc02047f6:	3de50513          	addi	a0,a0,990 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc02047fa:	a0ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02047fe:	00003697          	auipc	a3,0x3
ffffffffc0204802:	55268693          	addi	a3,a3,1362 # ffffffffc0207d50 <default_pmm_manager+0x1b8>
ffffffffc0204806:	00002617          	auipc	a2,0x2
ffffffffc020480a:	35260613          	addi	a2,a2,850 # ffffffffc0206b58 <commands+0x410>
ffffffffc020480e:	21200593          	li	a1,530
ffffffffc0204812:	00003517          	auipc	a0,0x3
ffffffffc0204816:	3be50513          	addi	a0,a0,958 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc020481a:	9effb0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc020481e:	00002617          	auipc	a2,0x2
ffffffffc0204822:	70a60613          	addi	a2,a2,1802 # ffffffffc0206f28 <commands+0x7e0>
ffffffffc0204826:	06900593          	li	a1,105
ffffffffc020482a:	00002517          	auipc	a0,0x2
ffffffffc020482e:	69e50513          	addi	a0,a0,1694 # ffffffffc0206ec8 <commands+0x780>
ffffffffc0204832:	9d7fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0204836:	00003697          	auipc	a3,0x3
ffffffffc020483a:	6ba68693          	addi	a3,a3,1722 # ffffffffc0207ef0 <default_pmm_manager+0x358>
ffffffffc020483e:	00002617          	auipc	a2,0x2
ffffffffc0204842:	31a60613          	addi	a2,a2,794 # ffffffffc0206b58 <commands+0x410>
ffffffffc0204846:	21d00593          	li	a1,541
ffffffffc020484a:	00003517          	auipc	a0,0x3
ffffffffc020484e:	38650513          	addi	a0,a0,902 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0204852:	9b7fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0204856:	00003697          	auipc	a3,0x3
ffffffffc020485a:	65268693          	addi	a3,a3,1618 # ffffffffc0207ea8 <default_pmm_manager+0x310>
ffffffffc020485e:	00002617          	auipc	a2,0x2
ffffffffc0204862:	2fa60613          	addi	a2,a2,762 # ffffffffc0206b58 <commands+0x410>
ffffffffc0204866:	21b00593          	li	a1,539
ffffffffc020486a:	00003517          	auipc	a0,0x3
ffffffffc020486e:	36650513          	addi	a0,a0,870 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0204872:	997fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0204876:	00003697          	auipc	a3,0x3
ffffffffc020487a:	66268693          	addi	a3,a3,1634 # ffffffffc0207ed8 <default_pmm_manager+0x340>
ffffffffc020487e:	00002617          	auipc	a2,0x2
ffffffffc0204882:	2da60613          	addi	a2,a2,730 # ffffffffc0206b58 <commands+0x410>
ffffffffc0204886:	21a00593          	li	a1,538
ffffffffc020488a:	00003517          	auipc	a0,0x3
ffffffffc020488e:	34650513          	addi	a0,a0,838 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0204892:	977fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0204896:	00003697          	auipc	a3,0x3
ffffffffc020489a:	61268693          	addi	a3,a3,1554 # ffffffffc0207ea8 <default_pmm_manager+0x310>
ffffffffc020489e:	00002617          	auipc	a2,0x2
ffffffffc02048a2:	2ba60613          	addi	a2,a2,698 # ffffffffc0206b58 <commands+0x410>
ffffffffc02048a6:	21700593          	li	a1,535
ffffffffc02048aa:	00003517          	auipc	a0,0x3
ffffffffc02048ae:	32650513          	addi	a0,a0,806 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc02048b2:	957fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 1);
ffffffffc02048b6:	00003697          	auipc	a3,0x3
ffffffffc02048ba:	74a68693          	addi	a3,a3,1866 # ffffffffc0208000 <default_pmm_manager+0x468>
ffffffffc02048be:	00002617          	auipc	a2,0x2
ffffffffc02048c2:	29a60613          	addi	a2,a2,666 # ffffffffc0206b58 <commands+0x410>
ffffffffc02048c6:	23c00593          	li	a1,572
ffffffffc02048ca:	00003517          	auipc	a0,0x3
ffffffffc02048ce:	30650513          	addi	a0,a0,774 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc02048d2:	937fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02048d6:	00003697          	auipc	a3,0x3
ffffffffc02048da:	6f268693          	addi	a3,a3,1778 # ffffffffc0207fc8 <default_pmm_manager+0x430>
ffffffffc02048de:	00002617          	auipc	a2,0x2
ffffffffc02048e2:	27a60613          	addi	a2,a2,634 # ffffffffc0206b58 <commands+0x410>
ffffffffc02048e6:	23b00593          	li	a1,571
ffffffffc02048ea:	00003517          	auipc	a0,0x3
ffffffffc02048ee:	2e650513          	addi	a0,a0,742 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc02048f2:	917fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02048f6:	00003697          	auipc	a3,0x3
ffffffffc02048fa:	6ba68693          	addi	a3,a3,1722 # ffffffffc0207fb0 <default_pmm_manager+0x418>
ffffffffc02048fe:	00002617          	auipc	a2,0x2
ffffffffc0204902:	25a60613          	addi	a2,a2,602 # ffffffffc0206b58 <commands+0x410>
ffffffffc0204906:	23700593          	li	a1,567
ffffffffc020490a:	00003517          	auipc	a0,0x3
ffffffffc020490e:	2c650513          	addi	a0,a0,710 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0204912:	8f7fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0204916:	00003697          	auipc	a3,0x3
ffffffffc020491a:	60268693          	addi	a3,a3,1538 # ffffffffc0207f18 <default_pmm_manager+0x380>
ffffffffc020491e:	00002617          	auipc	a2,0x2
ffffffffc0204922:	23a60613          	addi	a2,a2,570 # ffffffffc0206b58 <commands+0x410>
ffffffffc0204926:	22500593          	li	a1,549
ffffffffc020492a:	00003517          	auipc	a0,0x3
ffffffffc020492e:	2a650513          	addi	a0,a0,678 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0204932:	8d7fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0204936:	00003697          	auipc	a3,0x3
ffffffffc020493a:	41a68693          	addi	a3,a3,1050 # ffffffffc0207d50 <default_pmm_manager+0x1b8>
ffffffffc020493e:	00002617          	auipc	a2,0x2
ffffffffc0204942:	21a60613          	addi	a2,a2,538 # ffffffffc0206b58 <commands+0x410>
ffffffffc0204946:	1ff00593          	li	a1,511
ffffffffc020494a:	00003517          	auipc	a0,0x3
ffffffffc020494e:	28650513          	addi	a0,a0,646 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0204952:	8b7fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0204956:	00002617          	auipc	a2,0x2
ffffffffc020495a:	5d260613          	addi	a2,a2,1490 # ffffffffc0206f28 <commands+0x7e0>
ffffffffc020495e:	20200593          	li	a1,514
ffffffffc0204962:	00003517          	auipc	a0,0x3
ffffffffc0204966:	26e50513          	addi	a0,a0,622 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc020496a:	89ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020496e:	00003697          	auipc	a3,0x3
ffffffffc0204972:	3fa68693          	addi	a3,a3,1018 # ffffffffc0207d68 <default_pmm_manager+0x1d0>
ffffffffc0204976:	00002617          	auipc	a2,0x2
ffffffffc020497a:	1e260613          	addi	a2,a2,482 # ffffffffc0206b58 <commands+0x410>
ffffffffc020497e:	20000593          	li	a1,512
ffffffffc0204982:	00003517          	auipc	a0,0x3
ffffffffc0204986:	24e50513          	addi	a0,a0,590 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc020498a:	87ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020498e:	00003697          	auipc	a3,0x3
ffffffffc0204992:	45268693          	addi	a3,a3,1106 # ffffffffc0207de0 <default_pmm_manager+0x248>
ffffffffc0204996:	00002617          	auipc	a2,0x2
ffffffffc020499a:	1c260613          	addi	a2,a2,450 # ffffffffc0206b58 <commands+0x410>
ffffffffc020499e:	20800593          	li	a1,520
ffffffffc02049a2:	00003517          	auipc	a0,0x3
ffffffffc02049a6:	22e50513          	addi	a0,a0,558 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc02049aa:	85ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02049ae:	00003697          	auipc	a3,0x3
ffffffffc02049b2:	71268693          	addi	a3,a3,1810 # ffffffffc02080c0 <default_pmm_manager+0x528>
ffffffffc02049b6:	00002617          	auipc	a2,0x2
ffffffffc02049ba:	1a260613          	addi	a2,a2,418 # ffffffffc0206b58 <commands+0x410>
ffffffffc02049be:	24500593          	li	a1,581
ffffffffc02049c2:	00003517          	auipc	a0,0x3
ffffffffc02049c6:	20e50513          	addi	a0,a0,526 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc02049ca:	83ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02049ce:	00003697          	auipc	a3,0x3
ffffffffc02049d2:	6ba68693          	addi	a3,a3,1722 # ffffffffc0208088 <default_pmm_manager+0x4f0>
ffffffffc02049d6:	00002617          	auipc	a2,0x2
ffffffffc02049da:	18260613          	addi	a2,a2,386 # ffffffffc0206b58 <commands+0x410>
ffffffffc02049de:	24200593          	li	a1,578
ffffffffc02049e2:	00003517          	auipc	a0,0x3
ffffffffc02049e6:	1ee50513          	addi	a0,a0,494 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc02049ea:	81ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02049ee:	00003697          	auipc	a3,0x3
ffffffffc02049f2:	66a68693          	addi	a3,a3,1642 # ffffffffc0208058 <default_pmm_manager+0x4c0>
ffffffffc02049f6:	00002617          	auipc	a2,0x2
ffffffffc02049fa:	16260613          	addi	a2,a2,354 # ffffffffc0206b58 <commands+0x410>
ffffffffc02049fe:	23e00593          	li	a1,574
ffffffffc0204a02:	00003517          	auipc	a0,0x3
ffffffffc0204a06:	1ce50513          	addi	a0,a0,462 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0204a0a:	ffefb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204a0e <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0204a0e:	12058073          	sfence.vma	a1
}
ffffffffc0204a12:	8082                	ret

ffffffffc0204a14 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204a14:	7179                	addi	sp,sp,-48
ffffffffc0204a16:	e84a                	sd	s2,16(sp)
ffffffffc0204a18:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0204a1a:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204a1c:	f022                	sd	s0,32(sp)
ffffffffc0204a1e:	ec26                	sd	s1,24(sp)
ffffffffc0204a20:	e44e                	sd	s3,8(sp)
ffffffffc0204a22:	f406                	sd	ra,40(sp)
ffffffffc0204a24:	84ae                	mv	s1,a1
ffffffffc0204a26:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0204a28:	bb1fe0ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0204a2c:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0204a2e:	cd05                	beqz	a0,ffffffffc0204a66 <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0204a30:	85aa                	mv	a1,a0
ffffffffc0204a32:	86ce                	mv	a3,s3
ffffffffc0204a34:	8626                	mv	a2,s1
ffffffffc0204a36:	854a                	mv	a0,s2
ffffffffc0204a38:	b46ff0ef          	jal	ra,ffffffffc0203d7e <page_insert>
ffffffffc0204a3c:	ed0d                	bnez	a0,ffffffffc0204a76 <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc0204a3e:	000ae797          	auipc	a5,0xae
ffffffffc0204a42:	dca7a783          	lw	a5,-566(a5) # ffffffffc02b2808 <swap_init_ok>
ffffffffc0204a46:	c385                	beqz	a5,ffffffffc0204a66 <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc0204a48:	000ae517          	auipc	a0,0xae
ffffffffc0204a4c:	d9853503          	ld	a0,-616(a0) # ffffffffc02b27e0 <check_mm_struct>
ffffffffc0204a50:	c919                	beqz	a0,ffffffffc0204a66 <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0204a52:	4681                	li	a3,0
ffffffffc0204a54:	8622                	mv	a2,s0
ffffffffc0204a56:	85a6                	mv	a1,s1
ffffffffc0204a58:	f7bfd0ef          	jal	ra,ffffffffc02029d2 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0204a5c:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0204a5e:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0204a60:	4785                	li	a5,1
ffffffffc0204a62:	04f71663          	bne	a4,a5,ffffffffc0204aae <pgdir_alloc_page+0x9a>
}
ffffffffc0204a66:	70a2                	ld	ra,40(sp)
ffffffffc0204a68:	8522                	mv	a0,s0
ffffffffc0204a6a:	7402                	ld	s0,32(sp)
ffffffffc0204a6c:	64e2                	ld	s1,24(sp)
ffffffffc0204a6e:	6942                	ld	s2,16(sp)
ffffffffc0204a70:	69a2                	ld	s3,8(sp)
ffffffffc0204a72:	6145                	addi	sp,sp,48
ffffffffc0204a74:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204a76:	100027f3          	csrr	a5,sstatus
ffffffffc0204a7a:	8b89                	andi	a5,a5,2
ffffffffc0204a7c:	eb99                	bnez	a5,ffffffffc0204a92 <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc0204a7e:	000ae797          	auipc	a5,0xae
ffffffffc0204a82:	db27b783          	ld	a5,-590(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0204a86:	739c                	ld	a5,32(a5)
ffffffffc0204a88:	8522                	mv	a0,s0
ffffffffc0204a8a:	4585                	li	a1,1
ffffffffc0204a8c:	9782                	jalr	a5
            return NULL;
ffffffffc0204a8e:	4401                	li	s0,0
ffffffffc0204a90:	bfd9                	j	ffffffffc0204a66 <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc0204a92:	b93fb0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0204a96:	000ae797          	auipc	a5,0xae
ffffffffc0204a9a:	d9a7b783          	ld	a5,-614(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0204a9e:	739c                	ld	a5,32(a5)
ffffffffc0204aa0:	8522                	mv	a0,s0
ffffffffc0204aa2:	4585                	li	a1,1
ffffffffc0204aa4:	9782                	jalr	a5
            return NULL;
ffffffffc0204aa6:	4401                	li	s0,0
        intr_enable();
ffffffffc0204aa8:	b77fb0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0204aac:	bf6d                	j	ffffffffc0204a66 <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc0204aae:	00003697          	auipc	a3,0x3
ffffffffc0204ab2:	65a68693          	addi	a3,a3,1626 # ffffffffc0208108 <default_pmm_manager+0x570>
ffffffffc0204ab6:	00002617          	auipc	a2,0x2
ffffffffc0204aba:	0a260613          	addi	a2,a2,162 # ffffffffc0206b58 <commands+0x410>
ffffffffc0204abe:	1d600593          	li	a1,470
ffffffffc0204ac2:	00003517          	auipc	a0,0x3
ffffffffc0204ac6:	10e50513          	addi	a0,a0,270 # ffffffffc0207bd0 <default_pmm_manager+0x38>
ffffffffc0204aca:	f3efb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204ace <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204ace:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204ad0:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204ad2:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204ad4:	a55fb0ef          	jal	ra,ffffffffc0200528 <ide_device_valid>
ffffffffc0204ad8:	cd01                	beqz	a0,ffffffffc0204af0 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204ada:	4505                	li	a0,1
ffffffffc0204adc:	a53fb0ef          	jal	ra,ffffffffc020052e <ide_device_size>
}
ffffffffc0204ae0:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204ae2:	810d                	srli	a0,a0,0x3
ffffffffc0204ae4:	000ae797          	auipc	a5,0xae
ffffffffc0204ae8:	d0a7ba23          	sd	a0,-748(a5) # ffffffffc02b27f8 <max_swap_offset>
}
ffffffffc0204aec:	0141                	addi	sp,sp,16
ffffffffc0204aee:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204af0:	00003617          	auipc	a2,0x3
ffffffffc0204af4:	63060613          	addi	a2,a2,1584 # ffffffffc0208120 <default_pmm_manager+0x588>
ffffffffc0204af8:	45b5                	li	a1,13
ffffffffc0204afa:	00003517          	auipc	a0,0x3
ffffffffc0204afe:	64650513          	addi	a0,a0,1606 # ffffffffc0208140 <default_pmm_manager+0x5a8>
ffffffffc0204b02:	f06fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204b06 <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204b06:	1141                	addi	sp,sp,-16
ffffffffc0204b08:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b0a:	00855793          	srli	a5,a0,0x8
ffffffffc0204b0e:	cbb1                	beqz	a5,ffffffffc0204b62 <swapfs_write+0x5c>
ffffffffc0204b10:	000ae717          	auipc	a4,0xae
ffffffffc0204b14:	ce873703          	ld	a4,-792(a4) # ffffffffc02b27f8 <max_swap_offset>
ffffffffc0204b18:	04e7f563          	bgeu	a5,a4,ffffffffc0204b62 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204b1c:	000ae617          	auipc	a2,0xae
ffffffffc0204b20:	d0c63603          	ld	a2,-756(a2) # ffffffffc02b2828 <pages>
ffffffffc0204b24:	8d91                	sub	a1,a1,a2
ffffffffc0204b26:	4065d613          	srai	a2,a1,0x6
ffffffffc0204b2a:	00004717          	auipc	a4,0x4
ffffffffc0204b2e:	f6673703          	ld	a4,-154(a4) # ffffffffc0208a90 <nbase>
ffffffffc0204b32:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204b34:	00c61713          	slli	a4,a2,0xc
ffffffffc0204b38:	8331                	srli	a4,a4,0xc
ffffffffc0204b3a:	000ae697          	auipc	a3,0xae
ffffffffc0204b3e:	ce66b683          	ld	a3,-794(a3) # ffffffffc02b2820 <npage>
ffffffffc0204b42:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b46:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204b48:	02d77963          	bgeu	a4,a3,ffffffffc0204b7a <swapfs_write+0x74>
}
ffffffffc0204b4c:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b4e:	000ae797          	auipc	a5,0xae
ffffffffc0204b52:	cea7b783          	ld	a5,-790(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0204b56:	46a1                	li	a3,8
ffffffffc0204b58:	963e                	add	a2,a2,a5
ffffffffc0204b5a:	4505                	li	a0,1
}
ffffffffc0204b5c:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b5e:	9d7fb06f          	j	ffffffffc0200534 <ide_write_secs>
ffffffffc0204b62:	86aa                	mv	a3,a0
ffffffffc0204b64:	00003617          	auipc	a2,0x3
ffffffffc0204b68:	5f460613          	addi	a2,a2,1524 # ffffffffc0208158 <default_pmm_manager+0x5c0>
ffffffffc0204b6c:	45e5                	li	a1,25
ffffffffc0204b6e:	00003517          	auipc	a0,0x3
ffffffffc0204b72:	5d250513          	addi	a0,a0,1490 # ffffffffc0208140 <default_pmm_manager+0x5a8>
ffffffffc0204b76:	e92fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204b7a:	86b2                	mv	a3,a2
ffffffffc0204b7c:	06900593          	li	a1,105
ffffffffc0204b80:	00002617          	auipc	a2,0x2
ffffffffc0204b84:	3a860613          	addi	a2,a2,936 # ffffffffc0206f28 <commands+0x7e0>
ffffffffc0204b88:	00002517          	auipc	a0,0x2
ffffffffc0204b8c:	34050513          	addi	a0,a0,832 # ffffffffc0206ec8 <commands+0x780>
ffffffffc0204b90:	e78fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204b94 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204b94:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204b98:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204b9c:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204b9e:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204ba0:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204ba4:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204ba8:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204bac:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204bb0:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204bb4:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204bb8:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204bbc:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204bc0:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204bc4:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204bc8:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204bcc:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204bd0:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204bd2:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204bd4:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204bd8:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204bdc:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204be0:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204be4:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204be8:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204bec:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204bf0:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204bf4:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204bf8:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204bfc:	8082                	ret

ffffffffc0204bfe <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204bfe:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204c00:	9402                	jalr	s0

	jal do_exit
ffffffffc0204c02:	638000ef          	jal	ra,ffffffffc020523a <do_exit>

ffffffffc0204c06 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204c06:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204c08:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204c0c:	e022                	sd	s0,0(sp)
ffffffffc0204c0e:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204c10:	cacfd0ef          	jal	ra,ffffffffc02020bc <kmalloc>
ffffffffc0204c14:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204c16:	cd21                	beqz	a0,ffffffffc0204c6e <alloc_proc+0x68>
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     * proc_struct中的以下字段（在LAB5中的添加）需要初始化
     *       uint32_t wait_state;                        // 等待状态
     *       struct proc_struct *cptr, *yptr, *optr;     // 进程之间的关系
     */
        proc->state        = PROC_UNINIT;
ffffffffc0204c18:	57fd                	li	a5,-1
ffffffffc0204c1a:	1782                	slli	a5,a5,0x20
ffffffffc0204c1c:	e11c                	sd	a5,0(a0)
        proc->runs         = 0; 
        proc->kstack       = 0;    
        proc->need_resched = 0;
        proc->parent       = NULL;
        proc->mm           = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204c1e:	07000613          	li	a2,112
ffffffffc0204c22:	4581                	li	a1,0
        proc->runs         = 0; 
ffffffffc0204c24:	00052423          	sw	zero,8(a0)
        proc->kstack       = 0;    
ffffffffc0204c28:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204c2c:	00053c23          	sd	zero,24(a0)
        proc->parent       = NULL;
ffffffffc0204c30:	02053023          	sd	zero,32(a0)
        proc->mm           = NULL;
ffffffffc0204c34:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204c38:	03050513          	addi	a0,a0,48
ffffffffc0204c3c:	432010ef          	jal	ra,ffffffffc020606e <memset>
        proc->tf           = NULL;
        proc->cr3          = boot_cr3;
ffffffffc0204c40:	000ae797          	auipc	a5,0xae
ffffffffc0204c44:	bd07b783          	ld	a5,-1072(a5) # ffffffffc02b2810 <boot_cr3>
        proc->tf           = NULL;
ffffffffc0204c48:	0a043023          	sd	zero,160(s0)
        proc->cr3          = boot_cr3;
ffffffffc0204c4c:	f45c                	sd	a5,168(s0)
        proc->flags        = 0;
ffffffffc0204c4e:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, PROC_NAME_LEN+1);
ffffffffc0204c52:	4641                	li	a2,16
ffffffffc0204c54:	4581                	li	a1,0
ffffffffc0204c56:	0b440513          	addi	a0,s0,180
ffffffffc0204c5a:	414010ef          	jal	ra,ffffffffc020606e <memset>

        proc->wait_state   = 0;
ffffffffc0204c5e:	0e042623          	sw	zero,236(s0)
        proc->cptr         = NULL;
ffffffffc0204c62:	0e043823          	sd	zero,240(s0)
        proc->yptr         = NULL;
ffffffffc0204c66:	0e043c23          	sd	zero,248(s0)
        proc->optr         = NULL;
ffffffffc0204c6a:	10043023          	sd	zero,256(s0)
    }
    return proc;
}
ffffffffc0204c6e:	60a2                	ld	ra,8(sp)
ffffffffc0204c70:	8522                	mv	a0,s0
ffffffffc0204c72:	6402                	ld	s0,0(sp)
ffffffffc0204c74:	0141                	addi	sp,sp,16
ffffffffc0204c76:	8082                	ret

ffffffffc0204c78 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204c78:	000ae797          	auipc	a5,0xae
ffffffffc0204c7c:	bc87b783          	ld	a5,-1080(a5) # ffffffffc02b2840 <current>
ffffffffc0204c80:	73c8                	ld	a0,160(a5)
ffffffffc0204c82:	8ccfc06f          	j	ffffffffc0200d4e <forkrets>

ffffffffc0204c86 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204c86:	000ae797          	auipc	a5,0xae
ffffffffc0204c8a:	bba7b783          	ld	a5,-1094(a5) # ffffffffc02b2840 <current>
ffffffffc0204c8e:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204c90:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204c92:	00003617          	auipc	a2,0x3
ffffffffc0204c96:	4e660613          	addi	a2,a2,1254 # ffffffffc0208178 <default_pmm_manager+0x5e0>
ffffffffc0204c9a:	00003517          	auipc	a0,0x3
ffffffffc0204c9e:	4e650513          	addi	a0,a0,1254 # ffffffffc0208180 <default_pmm_manager+0x5e8>
user_main(void *arg) {
ffffffffc0204ca2:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204ca4:	c28fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0204ca8:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204cac:	47878793          	addi	a5,a5,1144 # b120 <_binary_obj___user_exit_out_size>
ffffffffc0204cb0:	e43e                	sd	a5,8(sp)
ffffffffc0204cb2:	00003517          	auipc	a0,0x3
ffffffffc0204cb6:	4c650513          	addi	a0,a0,1222 # ffffffffc0208178 <default_pmm_manager+0x5e0>
ffffffffc0204cba:	00030797          	auipc	a5,0x30
ffffffffc0204cbe:	61678793          	addi	a5,a5,1558 # ffffffffc02352d0 <_binary_obj___user_exit_out_start>
ffffffffc0204cc2:	f03e                	sd	a5,32(sp)
ffffffffc0204cc4:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204cc6:	e802                	sd	zero,16(sp)
ffffffffc0204cc8:	32a010ef          	jal	ra,ffffffffc0205ff2 <strlen>
ffffffffc0204ccc:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204cce:	4511                	li	a0,4
ffffffffc0204cd0:	55a2                	lw	a1,40(sp)
ffffffffc0204cd2:	4662                	lw	a2,24(sp)
ffffffffc0204cd4:	5682                	lw	a3,32(sp)
ffffffffc0204cd6:	4722                	lw	a4,8(sp)
ffffffffc0204cd8:	48a9                	li	a7,10
ffffffffc0204cda:	9002                	ebreak
ffffffffc0204cdc:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204cde:	65c2                	ld	a1,16(sp)
ffffffffc0204ce0:	00003517          	auipc	a0,0x3
ffffffffc0204ce4:	4c850513          	addi	a0,a0,1224 # ffffffffc02081a8 <default_pmm_manager+0x610>
ffffffffc0204ce8:	be4fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204cec:	00003617          	auipc	a2,0x3
ffffffffc0204cf0:	4cc60613          	addi	a2,a2,1228 # ffffffffc02081b8 <default_pmm_manager+0x620>
ffffffffc0204cf4:	35600593          	li	a1,854
ffffffffc0204cf8:	00003517          	auipc	a0,0x3
ffffffffc0204cfc:	4e050513          	addi	a0,a0,1248 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc0204d00:	d08fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204d04 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204d04:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204d06:	1141                	addi	sp,sp,-16
ffffffffc0204d08:	e406                	sd	ra,8(sp)
ffffffffc0204d0a:	c02007b7          	lui	a5,0xc0200
ffffffffc0204d0e:	02f6ee63          	bltu	a3,a5,ffffffffc0204d4a <put_pgdir+0x46>
ffffffffc0204d12:	000ae517          	auipc	a0,0xae
ffffffffc0204d16:	b2653503          	ld	a0,-1242(a0) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0204d1a:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204d1c:	82b1                	srli	a3,a3,0xc
ffffffffc0204d1e:	000ae797          	auipc	a5,0xae
ffffffffc0204d22:	b027b783          	ld	a5,-1278(a5) # ffffffffc02b2820 <npage>
ffffffffc0204d26:	02f6fe63          	bgeu	a3,a5,ffffffffc0204d62 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204d2a:	00004517          	auipc	a0,0x4
ffffffffc0204d2e:	d6653503          	ld	a0,-666(a0) # ffffffffc0208a90 <nbase>
}
ffffffffc0204d32:	60a2                	ld	ra,8(sp)
ffffffffc0204d34:	8e89                	sub	a3,a3,a0
ffffffffc0204d36:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204d38:	000ae517          	auipc	a0,0xae
ffffffffc0204d3c:	af053503          	ld	a0,-1296(a0) # ffffffffc02b2828 <pages>
ffffffffc0204d40:	4585                	li	a1,1
ffffffffc0204d42:	9536                	add	a0,a0,a3
}
ffffffffc0204d44:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204d46:	925fe06f          	j	ffffffffc020366a <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204d4a:	00002617          	auipc	a2,0x2
ffffffffc0204d4e:	77660613          	addi	a2,a2,1910 # ffffffffc02074c0 <commands+0xd78>
ffffffffc0204d52:	06e00593          	li	a1,110
ffffffffc0204d56:	00002517          	auipc	a0,0x2
ffffffffc0204d5a:	17250513          	addi	a0,a0,370 # ffffffffc0206ec8 <commands+0x780>
ffffffffc0204d5e:	caafb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204d62:	00002617          	auipc	a2,0x2
ffffffffc0204d66:	17660613          	addi	a2,a2,374 # ffffffffc0206ed8 <commands+0x790>
ffffffffc0204d6a:	06200593          	li	a1,98
ffffffffc0204d6e:	00002517          	auipc	a0,0x2
ffffffffc0204d72:	15a50513          	addi	a0,a0,346 # ffffffffc0206ec8 <commands+0x780>
ffffffffc0204d76:	c92fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204d7a <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204d7a:	7179                	addi	sp,sp,-48
ffffffffc0204d7c:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204d7e:	000ae917          	auipc	s2,0xae
ffffffffc0204d82:	ac290913          	addi	s2,s2,-1342 # ffffffffc02b2840 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204d86:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204d88:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204d8c:	f406                	sd	ra,40(sp)
ffffffffc0204d8e:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc0204d90:	02a48863          	beq	s1,a0,ffffffffc0204dc0 <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204d94:	100027f3          	csrr	a5,sstatus
ffffffffc0204d98:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204d9a:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204d9c:	ef9d                	bnez	a5,ffffffffc0204dda <proc_run+0x60>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204d9e:	755c                	ld	a5,168(a0)
ffffffffc0204da0:	577d                	li	a4,-1
ffffffffc0204da2:	177e                	slli	a4,a4,0x3f
ffffffffc0204da4:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0204da6:	00a93023          	sd	a0,0(s2)
ffffffffc0204daa:	8fd9                	or	a5,a5,a4
ffffffffc0204dac:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc0204db0:	03050593          	addi	a1,a0,48
ffffffffc0204db4:	03048513          	addi	a0,s1,48
ffffffffc0204db8:	dddff0ef          	jal	ra,ffffffffc0204b94 <switch_to>
    if (flag) {
ffffffffc0204dbc:	00099863          	bnez	s3,ffffffffc0204dcc <proc_run+0x52>
}
ffffffffc0204dc0:	70a2                	ld	ra,40(sp)
ffffffffc0204dc2:	7482                	ld	s1,32(sp)
ffffffffc0204dc4:	6962                	ld	s2,24(sp)
ffffffffc0204dc6:	69c2                	ld	s3,16(sp)
ffffffffc0204dc8:	6145                	addi	sp,sp,48
ffffffffc0204dca:	8082                	ret
ffffffffc0204dcc:	70a2                	ld	ra,40(sp)
ffffffffc0204dce:	7482                	ld	s1,32(sp)
ffffffffc0204dd0:	6962                	ld	s2,24(sp)
ffffffffc0204dd2:	69c2                	ld	s3,16(sp)
ffffffffc0204dd4:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204dd6:	849fb06f          	j	ffffffffc020061e <intr_enable>
ffffffffc0204dda:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204ddc:	849fb0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc0204de0:	6522                	ld	a0,8(sp)
ffffffffc0204de2:	4985                	li	s3,1
ffffffffc0204de4:	bf6d                	j	ffffffffc0204d9e <proc_run+0x24>

ffffffffc0204de6 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204de6:	7119                	addi	sp,sp,-128
ffffffffc0204de8:	f0ca                	sd	s2,96(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204dea:	000ae917          	auipc	s2,0xae
ffffffffc0204dee:	a6e90913          	addi	s2,s2,-1426 # ffffffffc02b2858 <nr_process>
ffffffffc0204df2:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204df6:	fc86                	sd	ra,120(sp)
ffffffffc0204df8:	f8a2                	sd	s0,112(sp)
ffffffffc0204dfa:	f4a6                	sd	s1,104(sp)
ffffffffc0204dfc:	ecce                	sd	s3,88(sp)
ffffffffc0204dfe:	e8d2                	sd	s4,80(sp)
ffffffffc0204e00:	e4d6                	sd	s5,72(sp)
ffffffffc0204e02:	e0da                	sd	s6,64(sp)
ffffffffc0204e04:	fc5e                	sd	s7,56(sp)
ffffffffc0204e06:	f862                	sd	s8,48(sp)
ffffffffc0204e08:	f466                	sd	s9,40(sp)
ffffffffc0204e0a:	f06a                	sd	s10,32(sp)
ffffffffc0204e0c:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204e0e:	6785                	lui	a5,0x1
ffffffffc0204e10:	32f75b63          	bge	a4,a5,ffffffffc0205146 <do_fork+0x360>
ffffffffc0204e14:	8a2a                	mv	s4,a0
ffffffffc0204e16:	89ae                	mv	s3,a1
ffffffffc0204e18:	8432                	mv	s0,a2
    if((proc = alloc_proc()) == NULL) goto fork_out;
ffffffffc0204e1a:	dedff0ef          	jal	ra,ffffffffc0204c06 <alloc_proc>
ffffffffc0204e1e:	84aa                	mv	s1,a0
ffffffffc0204e20:	30050463          	beqz	a0,ffffffffc0205128 <do_fork+0x342>
    proc->parent = current;
ffffffffc0204e24:	000aec17          	auipc	s8,0xae
ffffffffc0204e28:	a1cc0c13          	addi	s8,s8,-1508 # ffffffffc02b2840 <current>
ffffffffc0204e2c:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0); // 更新步骤1：将子进程的父进程设置为当前进程，确保当前进程的wait_state为0
ffffffffc0204e30:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8ac4>
    proc->parent = current;
ffffffffc0204e34:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0); // 更新步骤1：将子进程的父进程设置为当前进程，确保当前进程的wait_state为0
ffffffffc0204e36:	30071d63          	bnez	a4,ffffffffc0205150 <do_fork+0x36a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204e3a:	4509                	li	a0,2
ffffffffc0204e3c:	f9cfe0ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
    if (page != NULL) {
ffffffffc0204e40:	2e050163          	beqz	a0,ffffffffc0205122 <do_fork+0x33c>
    return page - pages + nbase;
ffffffffc0204e44:	000aea97          	auipc	s5,0xae
ffffffffc0204e48:	9e4a8a93          	addi	s5,s5,-1564 # ffffffffc02b2828 <pages>
ffffffffc0204e4c:	000ab683          	ld	a3,0(s5)
ffffffffc0204e50:	00004b17          	auipc	s6,0x4
ffffffffc0204e54:	c40b0b13          	addi	s6,s6,-960 # ffffffffc0208a90 <nbase>
ffffffffc0204e58:	000b3783          	ld	a5,0(s6)
ffffffffc0204e5c:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204e60:	000aeb97          	auipc	s7,0xae
ffffffffc0204e64:	9c0b8b93          	addi	s7,s7,-1600 # ffffffffc02b2820 <npage>
    return page - pages + nbase;
ffffffffc0204e68:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204e6a:	5dfd                	li	s11,-1
ffffffffc0204e6c:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc0204e70:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204e72:	00cddd93          	srli	s11,s11,0xc
ffffffffc0204e76:	01b6f633          	and	a2,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e7a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e7c:	2ee67a63          	bgeu	a2,a4,ffffffffc0205170 <do_fork+0x38a>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204e80:	000c3603          	ld	a2,0(s8)
ffffffffc0204e84:	000aec17          	auipc	s8,0xae
ffffffffc0204e88:	9b4c0c13          	addi	s8,s8,-1612 # ffffffffc02b2838 <va_pa_offset>
ffffffffc0204e8c:	000c3703          	ld	a4,0(s8)
ffffffffc0204e90:	02863d03          	ld	s10,40(a2)
ffffffffc0204e94:	e43e                	sd	a5,8(sp)
ffffffffc0204e96:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204e98:	e894                	sd	a3,16(s1)
    if (oldmm == NULL) {
ffffffffc0204e9a:	020d0863          	beqz	s10,ffffffffc0204eca <do_fork+0xe4>
    if (clone_flags & CLONE_VM) {
ffffffffc0204e9e:	100a7a13          	andi	s4,s4,256
ffffffffc0204ea2:	1c0a0163          	beqz	s4,ffffffffc0205064 <do_fork+0x27e>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0204ea6:	030d2703          	lw	a4,48(s10)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204eaa:	018d3783          	ld	a5,24(s10)
ffffffffc0204eae:	c02006b7          	lui	a3,0xc0200
ffffffffc0204eb2:	2705                	addiw	a4,a4,1
ffffffffc0204eb4:	02ed2823          	sw	a4,48(s10)
    proc->mm = mm;
ffffffffc0204eb8:	03a4b423          	sd	s10,40(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204ebc:	2ed7e263          	bltu	a5,a3,ffffffffc02051a0 <do_fork+0x3ba>
ffffffffc0204ec0:	000c3703          	ld	a4,0(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204ec4:	6894                	ld	a3,16(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204ec6:	8f99                	sub	a5,a5,a4
ffffffffc0204ec8:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204eca:	6789                	lui	a5,0x2
ffffffffc0204ecc:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd0>
ffffffffc0204ed0:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204ed2:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204ed4:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc0204ed6:	87b6                	mv	a5,a3
ffffffffc0204ed8:	12040893          	addi	a7,s0,288
ffffffffc0204edc:	00063803          	ld	a6,0(a2)
ffffffffc0204ee0:	6608                	ld	a0,8(a2)
ffffffffc0204ee2:	6a0c                	ld	a1,16(a2)
ffffffffc0204ee4:	6e18                	ld	a4,24(a2)
ffffffffc0204ee6:	0107b023          	sd	a6,0(a5)
ffffffffc0204eea:	e788                	sd	a0,8(a5)
ffffffffc0204eec:	eb8c                	sd	a1,16(a5)
ffffffffc0204eee:	ef98                	sd	a4,24(a5)
ffffffffc0204ef0:	02060613          	addi	a2,a2,32
ffffffffc0204ef4:	02078793          	addi	a5,a5,32
ffffffffc0204ef8:	ff1612e3          	bne	a2,a7,ffffffffc0204edc <do_fork+0xf6>
    proc->tf->gpr.a0 = 0;
ffffffffc0204efc:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204f00:	12098f63          	beqz	s3,ffffffffc020503e <do_fork+0x258>
ffffffffc0204f04:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204f08:	00000797          	auipc	a5,0x0
ffffffffc0204f0c:	d7078793          	addi	a5,a5,-656 # ffffffffc0204c78 <forkret>
ffffffffc0204f10:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204f12:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f14:	100027f3          	csrr	a5,sstatus
ffffffffc0204f18:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f1a:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f1c:	14079063          	bnez	a5,ffffffffc020505c <do_fork+0x276>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204f20:	000a2817          	auipc	a6,0xa2
ffffffffc0204f24:	3d880813          	addi	a6,a6,984 # ffffffffc02a72f8 <last_pid.1>
ffffffffc0204f28:	00082783          	lw	a5,0(a6)
ffffffffc0204f2c:	6709                	lui	a4,0x2
ffffffffc0204f2e:	0017851b          	addiw	a0,a5,1
ffffffffc0204f32:	00a82023          	sw	a0,0(a6)
ffffffffc0204f36:	08e55d63          	bge	a0,a4,ffffffffc0204fd0 <do_fork+0x1ea>
    if (last_pid >= next_safe) {
ffffffffc0204f3a:	000a2317          	auipc	t1,0xa2
ffffffffc0204f3e:	3c230313          	addi	t1,t1,962 # ffffffffc02a72fc <next_safe.0>
ffffffffc0204f42:	00032783          	lw	a5,0(t1)
ffffffffc0204f46:	000ae417          	auipc	s0,0xae
ffffffffc0204f4a:	87240413          	addi	s0,s0,-1934 # ffffffffc02b27b8 <proc_list>
ffffffffc0204f4e:	08f55963          	bge	a0,a5,ffffffffc0204fe0 <do_fork+0x1fa>
        proc->pid = get_pid();
ffffffffc0204f52:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204f54:	45a9                	li	a1,10
ffffffffc0204f56:	2501                	sext.w	a0,a0
ffffffffc0204f58:	52e010ef          	jal	ra,ffffffffc0206486 <hash32>
ffffffffc0204f5c:	02051793          	slli	a5,a0,0x20
ffffffffc0204f60:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204f64:	000aa797          	auipc	a5,0xaa
ffffffffc0204f68:	85478793          	addi	a5,a5,-1964 # ffffffffc02ae7b8 <hash_list>
ffffffffc0204f6c:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204f6e:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204f70:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204f72:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc0204f76:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204f78:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc0204f7a:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204f7c:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204f7e:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc0204f82:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc0204f84:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc0204f86:	e21c                	sd	a5,0(a2)
ffffffffc0204f88:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc0204f8a:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc0204f8c:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc0204f8e:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204f92:	10e4b023          	sd	a4,256(s1)
ffffffffc0204f96:	c311                	beqz	a4,ffffffffc0204f9a <do_fork+0x1b4>
        proc->optr->yptr = proc;
ffffffffc0204f98:	ff64                	sd	s1,248(a4)
    nr_process ++;
ffffffffc0204f9a:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc0204f9e:	fae4                	sd	s1,240(a3)
    nr_process ++;
ffffffffc0204fa0:	2785                	addiw	a5,a5,1
ffffffffc0204fa2:	00f92023          	sw	a5,0(s2)
    if (flag) {
ffffffffc0204fa6:	18099363          	bnez	s3,ffffffffc020512c <do_fork+0x346>
    wakeup_proc(proc);
ffffffffc0204faa:	8526                	mv	a0,s1
ffffffffc0204fac:	65b000ef          	jal	ra,ffffffffc0205e06 <wakeup_proc>
    ret = proc->pid;
ffffffffc0204fb0:	40c8                	lw	a0,4(s1)
}
ffffffffc0204fb2:	70e6                	ld	ra,120(sp)
ffffffffc0204fb4:	7446                	ld	s0,112(sp)
ffffffffc0204fb6:	74a6                	ld	s1,104(sp)
ffffffffc0204fb8:	7906                	ld	s2,96(sp)
ffffffffc0204fba:	69e6                	ld	s3,88(sp)
ffffffffc0204fbc:	6a46                	ld	s4,80(sp)
ffffffffc0204fbe:	6aa6                	ld	s5,72(sp)
ffffffffc0204fc0:	6b06                	ld	s6,64(sp)
ffffffffc0204fc2:	7be2                	ld	s7,56(sp)
ffffffffc0204fc4:	7c42                	ld	s8,48(sp)
ffffffffc0204fc6:	7ca2                	ld	s9,40(sp)
ffffffffc0204fc8:	7d02                	ld	s10,32(sp)
ffffffffc0204fca:	6de2                	ld	s11,24(sp)
ffffffffc0204fcc:	6109                	addi	sp,sp,128
ffffffffc0204fce:	8082                	ret
        last_pid = 1;
ffffffffc0204fd0:	4785                	li	a5,1
ffffffffc0204fd2:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0204fd6:	4505                	li	a0,1
ffffffffc0204fd8:	000a2317          	auipc	t1,0xa2
ffffffffc0204fdc:	32430313          	addi	t1,t1,804 # ffffffffc02a72fc <next_safe.0>
    return listelm->next;
ffffffffc0204fe0:	000ad417          	auipc	s0,0xad
ffffffffc0204fe4:	7d840413          	addi	s0,s0,2008 # ffffffffc02b27b8 <proc_list>
ffffffffc0204fe8:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc0204fec:	6789                	lui	a5,0x2
ffffffffc0204fee:	00f32023          	sw	a5,0(t1)
ffffffffc0204ff2:	86aa                	mv	a3,a0
ffffffffc0204ff4:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc0204ff6:	6e89                	lui	t4,0x2
ffffffffc0204ff8:	148e0263          	beq	t3,s0,ffffffffc020513c <do_fork+0x356>
ffffffffc0204ffc:	88ae                	mv	a7,a1
ffffffffc0204ffe:	87f2                	mv	a5,t3
ffffffffc0205000:	6609                	lui	a2,0x2
ffffffffc0205002:	a811                	j	ffffffffc0205016 <do_fork+0x230>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205004:	00e6d663          	bge	a3,a4,ffffffffc0205010 <do_fork+0x22a>
ffffffffc0205008:	00c75463          	bge	a4,a2,ffffffffc0205010 <do_fork+0x22a>
ffffffffc020500c:	863a                	mv	a2,a4
ffffffffc020500e:	4885                	li	a7,1
ffffffffc0205010:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205012:	00878d63          	beq	a5,s0,ffffffffc020502c <do_fork+0x246>
            if (proc->pid == last_pid) {
ffffffffc0205016:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c74>
ffffffffc020501a:	fed715e3          	bne	a4,a3,ffffffffc0205004 <do_fork+0x21e>
                if (++ last_pid >= next_safe) {
ffffffffc020501e:	2685                	addiw	a3,a3,1
ffffffffc0205020:	10c6d963          	bge	a3,a2,ffffffffc0205132 <do_fork+0x34c>
ffffffffc0205024:	679c                	ld	a5,8(a5)
ffffffffc0205026:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc0205028:	fe8797e3          	bne	a5,s0,ffffffffc0205016 <do_fork+0x230>
ffffffffc020502c:	c581                	beqz	a1,ffffffffc0205034 <do_fork+0x24e>
ffffffffc020502e:	00d82023          	sw	a3,0(a6)
ffffffffc0205032:	8536                	mv	a0,a3
ffffffffc0205034:	f0088fe3          	beqz	a7,ffffffffc0204f52 <do_fork+0x16c>
ffffffffc0205038:	00c32023          	sw	a2,0(t1)
ffffffffc020503c:	bf19                	j	ffffffffc0204f52 <do_fork+0x16c>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020503e:	89b6                	mv	s3,a3
ffffffffc0205040:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205044:	00000797          	auipc	a5,0x0
ffffffffc0205048:	c3478793          	addi	a5,a5,-972 # ffffffffc0204c78 <forkret>
ffffffffc020504c:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020504e:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205050:	100027f3          	csrr	a5,sstatus
ffffffffc0205054:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205056:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205058:	ec0784e3          	beqz	a5,ffffffffc0204f20 <do_fork+0x13a>
        intr_disable();
ffffffffc020505c:	dc8fb0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc0205060:	4985                	li	s3,1
ffffffffc0205062:	bd7d                	j	ffffffffc0204f20 <do_fork+0x13a>
    if ((mm = mm_create()) == NULL) {
ffffffffc0205064:	8ccfc0ef          	jal	ra,ffffffffc0201130 <mm_create>
ffffffffc0205068:	8caa                	mv	s9,a0
ffffffffc020506a:	c541                	beqz	a0,ffffffffc02050f2 <do_fork+0x30c>
    if ((page = alloc_page()) == NULL) {
ffffffffc020506c:	4505                	li	a0,1
ffffffffc020506e:	d6afe0ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0205072:	cd2d                	beqz	a0,ffffffffc02050ec <do_fork+0x306>
    return page - pages + nbase;
ffffffffc0205074:	000ab683          	ld	a3,0(s5)
ffffffffc0205078:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc020507a:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc020507e:	40d506b3          	sub	a3,a0,a3
ffffffffc0205082:	8699                	srai	a3,a3,0x6
ffffffffc0205084:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205086:	01b6fdb3          	and	s11,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc020508a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020508c:	0eedf263          	bgeu	s11,a4,ffffffffc0205170 <do_fork+0x38a>
ffffffffc0205090:	000c3a03          	ld	s4,0(s8)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205094:	6605                	lui	a2,0x1
ffffffffc0205096:	000ad597          	auipc	a1,0xad
ffffffffc020509a:	7825b583          	ld	a1,1922(a1) # ffffffffc02b2818 <boot_pgdir>
ffffffffc020509e:	9a36                	add	s4,s4,a3
ffffffffc02050a0:	8552                	mv	a0,s4
ffffffffc02050a2:	7df000ef          	jal	ra,ffffffffc0206080 <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc02050a6:	038d0d93          	addi	s11,s10,56
    mm->pgdir = pgdir;
ffffffffc02050aa:	014cbc23          	sd	s4,24(s9)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02050ae:	4785                	li	a5,1
ffffffffc02050b0:	40fdb7af          	amoor.d	a5,a5,(s11)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc02050b4:	8b85                	andi	a5,a5,1
ffffffffc02050b6:	4a05                	li	s4,1
ffffffffc02050b8:	c799                	beqz	a5,ffffffffc02050c6 <do_fork+0x2e0>
        schedule();
ffffffffc02050ba:	5cd000ef          	jal	ra,ffffffffc0205e86 <schedule>
ffffffffc02050be:	414db7af          	amoor.d	a5,s4,(s11)
    while (!try_lock(lock)) {
ffffffffc02050c2:	8b85                	andi	a5,a5,1
ffffffffc02050c4:	fbfd                	bnez	a5,ffffffffc02050ba <do_fork+0x2d4>
        ret = dup_mmap(mm, oldmm);
ffffffffc02050c6:	85ea                	mv	a1,s10
ffffffffc02050c8:	8566                	mv	a0,s9
ffffffffc02050ca:	aeefc0ef          	jal	ra,ffffffffc02013b8 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02050ce:	57f9                	li	a5,-2
ffffffffc02050d0:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc02050d4:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc02050d6:	0e078e63          	beqz	a5,ffffffffc02051d2 <do_fork+0x3ec>
good_mm:
ffffffffc02050da:	8d66                	mv	s10,s9
    if (ret != 0) {
ffffffffc02050dc:	dc0505e3          	beqz	a0,ffffffffc0204ea6 <do_fork+0xc0>
    exit_mmap(mm);
ffffffffc02050e0:	8566                	mv	a0,s9
ffffffffc02050e2:	b70fc0ef          	jal	ra,ffffffffc0201452 <exit_mmap>
    put_pgdir(mm);
ffffffffc02050e6:	8566                	mv	a0,s9
ffffffffc02050e8:	c1dff0ef          	jal	ra,ffffffffc0204d04 <put_pgdir>
    mm_destroy(mm);
ffffffffc02050ec:	8566                	mv	a0,s9
ffffffffc02050ee:	9c8fc0ef          	jal	ra,ffffffffc02012b6 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02050f2:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc02050f4:	c02007b7          	lui	a5,0xc0200
ffffffffc02050f8:	0cf6e163          	bltu	a3,a5,ffffffffc02051ba <do_fork+0x3d4>
ffffffffc02050fc:	000c3783          	ld	a5,0(s8)
    if (PPN(pa) >= npage) {
ffffffffc0205100:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc0205104:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205108:	83b1                	srli	a5,a5,0xc
ffffffffc020510a:	06e7ff63          	bgeu	a5,a4,ffffffffc0205188 <do_fork+0x3a2>
    return &pages[PPN(pa) - nbase];
ffffffffc020510e:	000b3703          	ld	a4,0(s6)
ffffffffc0205112:	000ab503          	ld	a0,0(s5)
ffffffffc0205116:	4589                	li	a1,2
ffffffffc0205118:	8f99                	sub	a5,a5,a4
ffffffffc020511a:	079a                	slli	a5,a5,0x6
ffffffffc020511c:	953e                	add	a0,a0,a5
ffffffffc020511e:	d4cfe0ef          	jal	ra,ffffffffc020366a <free_pages>
    kfree(proc);
ffffffffc0205122:	8526                	mv	a0,s1
ffffffffc0205124:	848fd0ef          	jal	ra,ffffffffc020216c <kfree>
    ret = -E_NO_MEM;
ffffffffc0205128:	5571                	li	a0,-4
    return ret;
ffffffffc020512a:	b561                	j	ffffffffc0204fb2 <do_fork+0x1cc>
        intr_enable();
ffffffffc020512c:	cf2fb0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0205130:	bdad                	j	ffffffffc0204faa <do_fork+0x1c4>
                    if (last_pid >= MAX_PID) {
ffffffffc0205132:	01d6c363          	blt	a3,t4,ffffffffc0205138 <do_fork+0x352>
                        last_pid = 1;
ffffffffc0205136:	4685                	li	a3,1
                    goto repeat;
ffffffffc0205138:	4585                	li	a1,1
ffffffffc020513a:	bd7d                	j	ffffffffc0204ff8 <do_fork+0x212>
ffffffffc020513c:	c599                	beqz	a1,ffffffffc020514a <do_fork+0x364>
ffffffffc020513e:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc0205142:	8536                	mv	a0,a3
ffffffffc0205144:	b539                	j	ffffffffc0204f52 <do_fork+0x16c>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205146:	556d                	li	a0,-5
ffffffffc0205148:	b5ad                	j	ffffffffc0204fb2 <do_fork+0x1cc>
    return last_pid;
ffffffffc020514a:	00082503          	lw	a0,0(a6)
ffffffffc020514e:	b511                	j	ffffffffc0204f52 <do_fork+0x16c>
    assert(current->wait_state == 0); // 更新步骤1：将子进程的父进程设置为当前进程，确保当前进程的wait_state为0
ffffffffc0205150:	00003697          	auipc	a3,0x3
ffffffffc0205154:	0a068693          	addi	a3,a3,160 # ffffffffc02081f0 <default_pmm_manager+0x658>
ffffffffc0205158:	00002617          	auipc	a2,0x2
ffffffffc020515c:	a0060613          	addi	a2,a2,-1536 # ffffffffc0206b58 <commands+0x410>
ffffffffc0205160:	1ba00593          	li	a1,442
ffffffffc0205164:	00003517          	auipc	a0,0x3
ffffffffc0205168:	07450513          	addi	a0,a0,116 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc020516c:	89cfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0205170:	00002617          	auipc	a2,0x2
ffffffffc0205174:	db860613          	addi	a2,a2,-584 # ffffffffc0206f28 <commands+0x7e0>
ffffffffc0205178:	06900593          	li	a1,105
ffffffffc020517c:	00002517          	auipc	a0,0x2
ffffffffc0205180:	d4c50513          	addi	a0,a0,-692 # ffffffffc0206ec8 <commands+0x780>
ffffffffc0205184:	884fb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205188:	00002617          	auipc	a2,0x2
ffffffffc020518c:	d5060613          	addi	a2,a2,-688 # ffffffffc0206ed8 <commands+0x790>
ffffffffc0205190:	06200593          	li	a1,98
ffffffffc0205194:	00002517          	auipc	a0,0x2
ffffffffc0205198:	d3450513          	addi	a0,a0,-716 # ffffffffc0206ec8 <commands+0x780>
ffffffffc020519c:	86cfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02051a0:	86be                	mv	a3,a5
ffffffffc02051a2:	00002617          	auipc	a2,0x2
ffffffffc02051a6:	31e60613          	addi	a2,a2,798 # ffffffffc02074c0 <commands+0xd78>
ffffffffc02051aa:	16900593          	li	a1,361
ffffffffc02051ae:	00003517          	auipc	a0,0x3
ffffffffc02051b2:	02a50513          	addi	a0,a0,42 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc02051b6:	852fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02051ba:	00002617          	auipc	a2,0x2
ffffffffc02051be:	30660613          	addi	a2,a2,774 # ffffffffc02074c0 <commands+0xd78>
ffffffffc02051c2:	06e00593          	li	a1,110
ffffffffc02051c6:	00002517          	auipc	a0,0x2
ffffffffc02051ca:	d0250513          	addi	a0,a0,-766 # ffffffffc0206ec8 <commands+0x780>
ffffffffc02051ce:	83afb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("Unlock failed.\n");
ffffffffc02051d2:	00003617          	auipc	a2,0x3
ffffffffc02051d6:	03e60613          	addi	a2,a2,62 # ffffffffc0208210 <default_pmm_manager+0x678>
ffffffffc02051da:	03100593          	li	a1,49
ffffffffc02051de:	00003517          	auipc	a0,0x3
ffffffffc02051e2:	04250513          	addi	a0,a0,66 # ffffffffc0208220 <default_pmm_manager+0x688>
ffffffffc02051e6:	822fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02051ea <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02051ea:	7129                	addi	sp,sp,-320
ffffffffc02051ec:	fa22                	sd	s0,304(sp)
ffffffffc02051ee:	f626                	sd	s1,296(sp)
ffffffffc02051f0:	f24a                	sd	s2,288(sp)
ffffffffc02051f2:	84ae                	mv	s1,a1
ffffffffc02051f4:	892a                	mv	s2,a0
ffffffffc02051f6:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02051f8:	4581                	li	a1,0
ffffffffc02051fa:	12000613          	li	a2,288
ffffffffc02051fe:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205200:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205202:	66d000ef          	jal	ra,ffffffffc020606e <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205206:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205208:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020520a:	100027f3          	csrr	a5,sstatus
ffffffffc020520e:	edd7f793          	andi	a5,a5,-291
ffffffffc0205212:	1207e793          	ori	a5,a5,288
ffffffffc0205216:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205218:	860a                	mv	a2,sp
ffffffffc020521a:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020521e:	00000797          	auipc	a5,0x0
ffffffffc0205222:	9e078793          	addi	a5,a5,-1568 # ffffffffc0204bfe <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205226:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205228:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020522a:	bbdff0ef          	jal	ra,ffffffffc0204de6 <do_fork>
}
ffffffffc020522e:	70f2                	ld	ra,312(sp)
ffffffffc0205230:	7452                	ld	s0,304(sp)
ffffffffc0205232:	74b2                	ld	s1,296(sp)
ffffffffc0205234:	7912                	ld	s2,288(sp)
ffffffffc0205236:	6131                	addi	sp,sp,320
ffffffffc0205238:	8082                	ret

ffffffffc020523a <do_exit>:
do_exit(int error_code) {
ffffffffc020523a:	7179                	addi	sp,sp,-48
ffffffffc020523c:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc020523e:	000ad417          	auipc	s0,0xad
ffffffffc0205242:	60240413          	addi	s0,s0,1538 # ffffffffc02b2840 <current>
ffffffffc0205246:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc0205248:	f406                	sd	ra,40(sp)
ffffffffc020524a:	ec26                	sd	s1,24(sp)
ffffffffc020524c:	e84a                	sd	s2,16(sp)
ffffffffc020524e:	e44e                	sd	s3,8(sp)
ffffffffc0205250:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc0205252:	000ad717          	auipc	a4,0xad
ffffffffc0205256:	5f673703          	ld	a4,1526(a4) # ffffffffc02b2848 <idleproc>
ffffffffc020525a:	0ce78c63          	beq	a5,a4,ffffffffc0205332 <do_exit+0xf8>
    if (current == initproc) {
ffffffffc020525e:	000ad497          	auipc	s1,0xad
ffffffffc0205262:	5f248493          	addi	s1,s1,1522 # ffffffffc02b2850 <initproc>
ffffffffc0205266:	6098                	ld	a4,0(s1)
ffffffffc0205268:	0ee78b63          	beq	a5,a4,ffffffffc020535e <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc020526c:	0287b983          	ld	s3,40(a5)
ffffffffc0205270:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc0205272:	02098663          	beqz	s3,ffffffffc020529e <do_exit+0x64>
ffffffffc0205276:	000ad797          	auipc	a5,0xad
ffffffffc020527a:	59a7b783          	ld	a5,1434(a5) # ffffffffc02b2810 <boot_cr3>
ffffffffc020527e:	577d                	li	a4,-1
ffffffffc0205280:	177e                	slli	a4,a4,0x3f
ffffffffc0205282:	83b1                	srli	a5,a5,0xc
ffffffffc0205284:	8fd9                	or	a5,a5,a4
ffffffffc0205286:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc020528a:	0309a783          	lw	a5,48(s3)
ffffffffc020528e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205292:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205296:	cb55                	beqz	a4,ffffffffc020534a <do_exit+0x110>
        current->mm = NULL;
ffffffffc0205298:	601c                	ld	a5,0(s0)
ffffffffc020529a:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020529e:	601c                	ld	a5,0(s0)
ffffffffc02052a0:	470d                	li	a4,3
ffffffffc02052a2:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc02052a4:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02052a8:	100027f3          	csrr	a5,sstatus
ffffffffc02052ac:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02052ae:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02052b0:	e3f9                	bnez	a5,ffffffffc0205376 <do_exit+0x13c>
        proc = current->parent;
ffffffffc02052b2:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02052b4:	800007b7          	lui	a5,0x80000
ffffffffc02052b8:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02052ba:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02052bc:	0ec52703          	lw	a4,236(a0)
ffffffffc02052c0:	0af70f63          	beq	a4,a5,ffffffffc020537e <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc02052c4:	6018                	ld	a4,0(s0)
ffffffffc02052c6:	7b7c                	ld	a5,240(a4)
ffffffffc02052c8:	c3a1                	beqz	a5,ffffffffc0205308 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02052ca:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02052ce:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02052d0:	0985                	addi	s3,s3,1
ffffffffc02052d2:	a021                	j	ffffffffc02052da <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc02052d4:	6018                	ld	a4,0(s0)
ffffffffc02052d6:	7b7c                	ld	a5,240(a4)
ffffffffc02052d8:	cb85                	beqz	a5,ffffffffc0205308 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc02052da:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fe0>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02052de:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc02052e0:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02052e2:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02052e4:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02052e8:	10e7b023          	sd	a4,256(a5)
ffffffffc02052ec:	c311                	beqz	a4,ffffffffc02052f0 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc02052ee:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02052f0:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02052f2:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02052f4:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02052f6:	fd271fe3          	bne	a4,s2,ffffffffc02052d4 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02052fa:	0ec52783          	lw	a5,236(a0)
ffffffffc02052fe:	fd379be3          	bne	a5,s3,ffffffffc02052d4 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0205302:	305000ef          	jal	ra,ffffffffc0205e06 <wakeup_proc>
ffffffffc0205306:	b7f9                	j	ffffffffc02052d4 <do_exit+0x9a>
    if (flag) {
ffffffffc0205308:	020a1263          	bnez	s4,ffffffffc020532c <do_exit+0xf2>
    schedule();
ffffffffc020530c:	37b000ef          	jal	ra,ffffffffc0205e86 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205310:	601c                	ld	a5,0(s0)
ffffffffc0205312:	00003617          	auipc	a2,0x3
ffffffffc0205316:	f4660613          	addi	a2,a2,-186 # ffffffffc0208258 <default_pmm_manager+0x6c0>
ffffffffc020531a:	20700593          	li	a1,519
ffffffffc020531e:	43d4                	lw	a3,4(a5)
ffffffffc0205320:	00003517          	auipc	a0,0x3
ffffffffc0205324:	eb850513          	addi	a0,a0,-328 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc0205328:	ee1fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_enable();
ffffffffc020532c:	af2fb0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc0205330:	bff1                	j	ffffffffc020530c <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc0205332:	00003617          	auipc	a2,0x3
ffffffffc0205336:	f0660613          	addi	a2,a2,-250 # ffffffffc0208238 <default_pmm_manager+0x6a0>
ffffffffc020533a:	1db00593          	li	a1,475
ffffffffc020533e:	00003517          	auipc	a0,0x3
ffffffffc0205342:	e9a50513          	addi	a0,a0,-358 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc0205346:	ec3fa0ef          	jal	ra,ffffffffc0200208 <__panic>
            exit_mmap(mm);
ffffffffc020534a:	854e                	mv	a0,s3
ffffffffc020534c:	906fc0ef          	jal	ra,ffffffffc0201452 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205350:	854e                	mv	a0,s3
ffffffffc0205352:	9b3ff0ef          	jal	ra,ffffffffc0204d04 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205356:	854e                	mv	a0,s3
ffffffffc0205358:	f5ffb0ef          	jal	ra,ffffffffc02012b6 <mm_destroy>
ffffffffc020535c:	bf35                	j	ffffffffc0205298 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc020535e:	00003617          	auipc	a2,0x3
ffffffffc0205362:	eea60613          	addi	a2,a2,-278 # ffffffffc0208248 <default_pmm_manager+0x6b0>
ffffffffc0205366:	1de00593          	li	a1,478
ffffffffc020536a:	00003517          	auipc	a0,0x3
ffffffffc020536e:	e6e50513          	addi	a0,a0,-402 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc0205372:	e97fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_disable();
ffffffffc0205376:	aaefb0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc020537a:	4a05                	li	s4,1
ffffffffc020537c:	bf1d                	j	ffffffffc02052b2 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc020537e:	289000ef          	jal	ra,ffffffffc0205e06 <wakeup_proc>
ffffffffc0205382:	b789                	j	ffffffffc02052c4 <do_exit+0x8a>

ffffffffc0205384 <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc0205384:	715d                	addi	sp,sp,-80
ffffffffc0205386:	f84a                	sd	s2,48(sp)
ffffffffc0205388:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc020538a:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc020538e:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc0205390:	fc26                	sd	s1,56(sp)
ffffffffc0205392:	f052                	sd	s4,32(sp)
ffffffffc0205394:	ec56                	sd	s5,24(sp)
ffffffffc0205396:	e85a                	sd	s6,16(sp)
ffffffffc0205398:	e45e                	sd	s7,8(sp)
ffffffffc020539a:	e486                	sd	ra,72(sp)
ffffffffc020539c:	e0a2                	sd	s0,64(sp)
ffffffffc020539e:	84aa                	mv	s1,a0
ffffffffc02053a0:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc02053a2:	000adb97          	auipc	s7,0xad
ffffffffc02053a6:	49eb8b93          	addi	s7,s7,1182 # ffffffffc02b2840 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02053aa:	00050b1b          	sext.w	s6,a0
ffffffffc02053ae:	fff50a9b          	addiw	s5,a0,-1
ffffffffc02053b2:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc02053b4:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc02053b6:	ccbd                	beqz	s1,ffffffffc0205434 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02053b8:	0359e863          	bltu	s3,s5,ffffffffc02053e8 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02053bc:	45a9                	li	a1,10
ffffffffc02053be:	855a                	mv	a0,s6
ffffffffc02053c0:	0c6010ef          	jal	ra,ffffffffc0206486 <hash32>
ffffffffc02053c4:	02051793          	slli	a5,a0,0x20
ffffffffc02053c8:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02053cc:	000a9797          	auipc	a5,0xa9
ffffffffc02053d0:	3ec78793          	addi	a5,a5,1004 # ffffffffc02ae7b8 <hash_list>
ffffffffc02053d4:	953e                	add	a0,a0,a5
ffffffffc02053d6:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc02053d8:	a029                	j	ffffffffc02053e2 <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc02053da:	f2c42783          	lw	a5,-212(s0)
ffffffffc02053de:	02978163          	beq	a5,s1,ffffffffc0205400 <do_wait.part.0+0x7c>
ffffffffc02053e2:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc02053e4:	fe851be3          	bne	a0,s0,ffffffffc02053da <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc02053e8:	5579                	li	a0,-2
}
ffffffffc02053ea:	60a6                	ld	ra,72(sp)
ffffffffc02053ec:	6406                	ld	s0,64(sp)
ffffffffc02053ee:	74e2                	ld	s1,56(sp)
ffffffffc02053f0:	7942                	ld	s2,48(sp)
ffffffffc02053f2:	79a2                	ld	s3,40(sp)
ffffffffc02053f4:	7a02                	ld	s4,32(sp)
ffffffffc02053f6:	6ae2                	ld	s5,24(sp)
ffffffffc02053f8:	6b42                	ld	s6,16(sp)
ffffffffc02053fa:	6ba2                	ld	s7,8(sp)
ffffffffc02053fc:	6161                	addi	sp,sp,80
ffffffffc02053fe:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc0205400:	000bb683          	ld	a3,0(s7)
ffffffffc0205404:	f4843783          	ld	a5,-184(s0)
ffffffffc0205408:	fed790e3          	bne	a5,a3,ffffffffc02053e8 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020540c:	f2842703          	lw	a4,-216(s0)
ffffffffc0205410:	478d                	li	a5,3
ffffffffc0205412:	0ef70b63          	beq	a4,a5,ffffffffc0205508 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc0205416:	4785                	li	a5,1
ffffffffc0205418:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc020541a:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc020541e:	269000ef          	jal	ra,ffffffffc0205e86 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205422:	000bb783          	ld	a5,0(s7)
ffffffffc0205426:	0b07a783          	lw	a5,176(a5)
ffffffffc020542a:	8b85                	andi	a5,a5,1
ffffffffc020542c:	d7c9                	beqz	a5,ffffffffc02053b6 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc020542e:	555d                	li	a0,-9
ffffffffc0205430:	e0bff0ef          	jal	ra,ffffffffc020523a <do_exit>
        proc = current->cptr;
ffffffffc0205434:	000bb683          	ld	a3,0(s7)
ffffffffc0205438:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc020543a:	d45d                	beqz	s0,ffffffffc02053e8 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020543c:	470d                	li	a4,3
ffffffffc020543e:	a021                	j	ffffffffc0205446 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205440:	10043403          	ld	s0,256(s0)
ffffffffc0205444:	d869                	beqz	s0,ffffffffc0205416 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205446:	401c                	lw	a5,0(s0)
ffffffffc0205448:	fee79ce3          	bne	a5,a4,ffffffffc0205440 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc020544c:	000ad797          	auipc	a5,0xad
ffffffffc0205450:	3fc7b783          	ld	a5,1020(a5) # ffffffffc02b2848 <idleproc>
ffffffffc0205454:	0c878963          	beq	a5,s0,ffffffffc0205526 <do_wait.part.0+0x1a2>
ffffffffc0205458:	000ad797          	auipc	a5,0xad
ffffffffc020545c:	3f87b783          	ld	a5,1016(a5) # ffffffffc02b2850 <initproc>
ffffffffc0205460:	0cf40363          	beq	s0,a5,ffffffffc0205526 <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc0205464:	000a0663          	beqz	s4,ffffffffc0205470 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc0205468:	0e842783          	lw	a5,232(s0)
ffffffffc020546c:	00fa2023          	sw	a5,0(s4)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205470:	100027f3          	csrr	a5,sstatus
ffffffffc0205474:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205476:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205478:	e7c1                	bnez	a5,ffffffffc0205500 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc020547a:	6c70                	ld	a2,216(s0)
ffffffffc020547c:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc020547e:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc0205482:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0205484:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205486:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205488:	6470                	ld	a2,200(s0)
ffffffffc020548a:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc020548c:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020548e:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc0205490:	c319                	beqz	a4,ffffffffc0205496 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc0205492:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc0205494:	7c7c                	ld	a5,248(s0)
ffffffffc0205496:	c3b5                	beqz	a5,ffffffffc02054fa <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc0205498:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc020549c:	000ad717          	auipc	a4,0xad
ffffffffc02054a0:	3bc70713          	addi	a4,a4,956 # ffffffffc02b2858 <nr_process>
ffffffffc02054a4:	431c                	lw	a5,0(a4)
ffffffffc02054a6:	37fd                	addiw	a5,a5,-1
ffffffffc02054a8:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc02054aa:	e5a9                	bnez	a1,ffffffffc02054f4 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02054ac:	6814                	ld	a3,16(s0)
ffffffffc02054ae:	c02007b7          	lui	a5,0xc0200
ffffffffc02054b2:	04f6ee63          	bltu	a3,a5,ffffffffc020550e <do_wait.part.0+0x18a>
ffffffffc02054b6:	000ad797          	auipc	a5,0xad
ffffffffc02054ba:	3827b783          	ld	a5,898(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc02054be:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02054c0:	82b1                	srli	a3,a3,0xc
ffffffffc02054c2:	000ad797          	auipc	a5,0xad
ffffffffc02054c6:	35e7b783          	ld	a5,862(a5) # ffffffffc02b2820 <npage>
ffffffffc02054ca:	06f6fa63          	bgeu	a3,a5,ffffffffc020553e <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc02054ce:	00003517          	auipc	a0,0x3
ffffffffc02054d2:	5c253503          	ld	a0,1474(a0) # ffffffffc0208a90 <nbase>
ffffffffc02054d6:	8e89                	sub	a3,a3,a0
ffffffffc02054d8:	069a                	slli	a3,a3,0x6
ffffffffc02054da:	000ad517          	auipc	a0,0xad
ffffffffc02054de:	34e53503          	ld	a0,846(a0) # ffffffffc02b2828 <pages>
ffffffffc02054e2:	9536                	add	a0,a0,a3
ffffffffc02054e4:	4589                	li	a1,2
ffffffffc02054e6:	984fe0ef          	jal	ra,ffffffffc020366a <free_pages>
    kfree(proc);
ffffffffc02054ea:	8522                	mv	a0,s0
ffffffffc02054ec:	c81fc0ef          	jal	ra,ffffffffc020216c <kfree>
    return 0;
ffffffffc02054f0:	4501                	li	a0,0
ffffffffc02054f2:	bde5                	j	ffffffffc02053ea <do_wait.part.0+0x66>
        intr_enable();
ffffffffc02054f4:	92afb0ef          	jal	ra,ffffffffc020061e <intr_enable>
ffffffffc02054f8:	bf55                	j	ffffffffc02054ac <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc02054fa:	701c                	ld	a5,32(s0)
ffffffffc02054fc:	fbf8                	sd	a4,240(a5)
ffffffffc02054fe:	bf79                	j	ffffffffc020549c <do_wait.part.0+0x118>
        intr_disable();
ffffffffc0205500:	924fb0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc0205504:	4585                	li	a1,1
ffffffffc0205506:	bf95                	j	ffffffffc020547a <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205508:	f2840413          	addi	s0,s0,-216
ffffffffc020550c:	b781                	j	ffffffffc020544c <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc020550e:	00002617          	auipc	a2,0x2
ffffffffc0205512:	fb260613          	addi	a2,a2,-78 # ffffffffc02074c0 <commands+0xd78>
ffffffffc0205516:	06e00593          	li	a1,110
ffffffffc020551a:	00002517          	auipc	a0,0x2
ffffffffc020551e:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0206ec8 <commands+0x780>
ffffffffc0205522:	ce7fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc0205526:	00003617          	auipc	a2,0x3
ffffffffc020552a:	d5260613          	addi	a2,a2,-686 # ffffffffc0208278 <default_pmm_manager+0x6e0>
ffffffffc020552e:	30400593          	li	a1,772
ffffffffc0205532:	00003517          	auipc	a0,0x3
ffffffffc0205536:	ca650513          	addi	a0,a0,-858 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc020553a:	ccffa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020553e:	00002617          	auipc	a2,0x2
ffffffffc0205542:	99a60613          	addi	a2,a2,-1638 # ffffffffc0206ed8 <commands+0x790>
ffffffffc0205546:	06200593          	li	a1,98
ffffffffc020554a:	00002517          	auipc	a0,0x2
ffffffffc020554e:	97e50513          	addi	a0,a0,-1666 # ffffffffc0206ec8 <commands+0x780>
ffffffffc0205552:	cb7fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205556 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0205556:	1141                	addi	sp,sp,-16
ffffffffc0205558:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020555a:	950fe0ef          	jal	ra,ffffffffc02036aa <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc020555e:	b5bfc0ef          	jal	ra,ffffffffc02020b8 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0205562:	4601                	li	a2,0
ffffffffc0205564:	4581                	li	a1,0
ffffffffc0205566:	fffff517          	auipc	a0,0xfffff
ffffffffc020556a:	72050513          	addi	a0,a0,1824 # ffffffffc0204c86 <user_main>
ffffffffc020556e:	c7dff0ef          	jal	ra,ffffffffc02051ea <kernel_thread>
    if (pid <= 0) {
ffffffffc0205572:	00a04563          	bgtz	a0,ffffffffc020557c <init_main+0x26>
ffffffffc0205576:	a071                	j	ffffffffc0205602 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0205578:	10f000ef          	jal	ra,ffffffffc0205e86 <schedule>
    if (code_store != NULL) {
ffffffffc020557c:	4581                	li	a1,0
ffffffffc020557e:	4501                	li	a0,0
ffffffffc0205580:	e05ff0ef          	jal	ra,ffffffffc0205384 <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc0205584:	d975                	beqz	a0,ffffffffc0205578 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205586:	00003517          	auipc	a0,0x3
ffffffffc020558a:	d3250513          	addi	a0,a0,-718 # ffffffffc02082b8 <default_pmm_manager+0x720>
ffffffffc020558e:	b3ffa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205592:	000ad797          	auipc	a5,0xad
ffffffffc0205596:	2be7b783          	ld	a5,702(a5) # ffffffffc02b2850 <initproc>
ffffffffc020559a:	7bf8                	ld	a4,240(a5)
ffffffffc020559c:	e339                	bnez	a4,ffffffffc02055e2 <init_main+0x8c>
ffffffffc020559e:	7ff8                	ld	a4,248(a5)
ffffffffc02055a0:	e329                	bnez	a4,ffffffffc02055e2 <init_main+0x8c>
ffffffffc02055a2:	1007b703          	ld	a4,256(a5)
ffffffffc02055a6:	ef15                	bnez	a4,ffffffffc02055e2 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc02055a8:	000ad697          	auipc	a3,0xad
ffffffffc02055ac:	2b06a683          	lw	a3,688(a3) # ffffffffc02b2858 <nr_process>
ffffffffc02055b0:	4709                	li	a4,2
ffffffffc02055b2:	0ae69463          	bne	a3,a4,ffffffffc020565a <init_main+0x104>
    return listelm->next;
ffffffffc02055b6:	000ad697          	auipc	a3,0xad
ffffffffc02055ba:	20268693          	addi	a3,a3,514 # ffffffffc02b27b8 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02055be:	6698                	ld	a4,8(a3)
ffffffffc02055c0:	0c878793          	addi	a5,a5,200
ffffffffc02055c4:	06f71b63          	bne	a4,a5,ffffffffc020563a <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02055c8:	629c                	ld	a5,0(a3)
ffffffffc02055ca:	04f71863          	bne	a4,a5,ffffffffc020561a <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc02055ce:	00003517          	auipc	a0,0x3
ffffffffc02055d2:	dd250513          	addi	a0,a0,-558 # ffffffffc02083a0 <default_pmm_manager+0x808>
ffffffffc02055d6:	af7fa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
}
ffffffffc02055da:	60a2                	ld	ra,8(sp)
ffffffffc02055dc:	4501                	li	a0,0
ffffffffc02055de:	0141                	addi	sp,sp,16
ffffffffc02055e0:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02055e2:	00003697          	auipc	a3,0x3
ffffffffc02055e6:	cfe68693          	addi	a3,a3,-770 # ffffffffc02082e0 <default_pmm_manager+0x748>
ffffffffc02055ea:	00001617          	auipc	a2,0x1
ffffffffc02055ee:	56e60613          	addi	a2,a2,1390 # ffffffffc0206b58 <commands+0x410>
ffffffffc02055f2:	36900593          	li	a1,873
ffffffffc02055f6:	00003517          	auipc	a0,0x3
ffffffffc02055fa:	be250513          	addi	a0,a0,-1054 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc02055fe:	c0bfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("create user_main failed.\n");
ffffffffc0205602:	00003617          	auipc	a2,0x3
ffffffffc0205606:	c9660613          	addi	a2,a2,-874 # ffffffffc0208298 <default_pmm_manager+0x700>
ffffffffc020560a:	36100593          	li	a1,865
ffffffffc020560e:	00003517          	auipc	a0,0x3
ffffffffc0205612:	bca50513          	addi	a0,a0,-1078 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc0205616:	bf3fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020561a:	00003697          	auipc	a3,0x3
ffffffffc020561e:	d5668693          	addi	a3,a3,-682 # ffffffffc0208370 <default_pmm_manager+0x7d8>
ffffffffc0205622:	00001617          	auipc	a2,0x1
ffffffffc0205626:	53660613          	addi	a2,a2,1334 # ffffffffc0206b58 <commands+0x410>
ffffffffc020562a:	36c00593          	li	a1,876
ffffffffc020562e:	00003517          	auipc	a0,0x3
ffffffffc0205632:	baa50513          	addi	a0,a0,-1110 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc0205636:	bd3fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020563a:	00003697          	auipc	a3,0x3
ffffffffc020563e:	d0668693          	addi	a3,a3,-762 # ffffffffc0208340 <default_pmm_manager+0x7a8>
ffffffffc0205642:	00001617          	auipc	a2,0x1
ffffffffc0205646:	51660613          	addi	a2,a2,1302 # ffffffffc0206b58 <commands+0x410>
ffffffffc020564a:	36b00593          	li	a1,875
ffffffffc020564e:	00003517          	auipc	a0,0x3
ffffffffc0205652:	b8a50513          	addi	a0,a0,-1142 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc0205656:	bb3fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_process == 2);
ffffffffc020565a:	00003697          	auipc	a3,0x3
ffffffffc020565e:	cd668693          	addi	a3,a3,-810 # ffffffffc0208330 <default_pmm_manager+0x798>
ffffffffc0205662:	00001617          	auipc	a2,0x1
ffffffffc0205666:	4f660613          	addi	a2,a2,1270 # ffffffffc0206b58 <commands+0x410>
ffffffffc020566a:	36a00593          	li	a1,874
ffffffffc020566e:	00003517          	auipc	a0,0x3
ffffffffc0205672:	b6a50513          	addi	a0,a0,-1174 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc0205676:	b93fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020567a <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020567a:	7171                	addi	sp,sp,-176
ffffffffc020567c:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020567e:	000add97          	auipc	s11,0xad
ffffffffc0205682:	1c2d8d93          	addi	s11,s11,450 # ffffffffc02b2840 <current>
ffffffffc0205686:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020568a:	e54e                	sd	s3,136(sp)
ffffffffc020568c:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020568e:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205692:	e94a                	sd	s2,144(sp)
ffffffffc0205694:	f4de                	sd	s7,104(sp)
ffffffffc0205696:	892a                	mv	s2,a0
ffffffffc0205698:	8bb2                	mv	s7,a2
ffffffffc020569a:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020569c:	862e                	mv	a2,a1
ffffffffc020569e:	4681                	li	a3,0
ffffffffc02056a0:	85aa                	mv	a1,a0
ffffffffc02056a2:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02056a4:	f506                	sd	ra,168(sp)
ffffffffc02056a6:	f122                	sd	s0,160(sp)
ffffffffc02056a8:	e152                	sd	s4,128(sp)
ffffffffc02056aa:	fcd6                	sd	s5,120(sp)
ffffffffc02056ac:	f8da                	sd	s6,112(sp)
ffffffffc02056ae:	f0e2                	sd	s8,96(sp)
ffffffffc02056b0:	ece6                	sd	s9,88(sp)
ffffffffc02056b2:	e8ea                	sd	s10,80(sp)
ffffffffc02056b4:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02056b6:	b52fc0ef          	jal	ra,ffffffffc0201a08 <user_mem_check>
ffffffffc02056ba:	40050863          	beqz	a0,ffffffffc0205aca <do_execve+0x450>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02056be:	4641                	li	a2,16
ffffffffc02056c0:	4581                	li	a1,0
ffffffffc02056c2:	1808                	addi	a0,sp,48
ffffffffc02056c4:	1ab000ef          	jal	ra,ffffffffc020606e <memset>
    memcpy(local_name, name, len);
ffffffffc02056c8:	47bd                	li	a5,15
ffffffffc02056ca:	8626                	mv	a2,s1
ffffffffc02056cc:	1e97e063          	bltu	a5,s1,ffffffffc02058ac <do_execve+0x232>
ffffffffc02056d0:	85ca                	mv	a1,s2
ffffffffc02056d2:	1808                	addi	a0,sp,48
ffffffffc02056d4:	1ad000ef          	jal	ra,ffffffffc0206080 <memcpy>
    if (mm != NULL) {
ffffffffc02056d8:	1e098163          	beqz	s3,ffffffffc02058ba <do_execve+0x240>
        cputs("mm != NULL");
ffffffffc02056dc:	00002517          	auipc	a0,0x2
ffffffffc02056e0:	91c50513          	addi	a0,a0,-1764 # ffffffffc0206ff8 <commands+0x8b0>
ffffffffc02056e4:	a21fa0ef          	jal	ra,ffffffffc0200104 <cputs>
ffffffffc02056e8:	000ad797          	auipc	a5,0xad
ffffffffc02056ec:	1287b783          	ld	a5,296(a5) # ffffffffc02b2810 <boot_cr3>
ffffffffc02056f0:	577d                	li	a4,-1
ffffffffc02056f2:	177e                	slli	a4,a4,0x3f
ffffffffc02056f4:	83b1                	srli	a5,a5,0xc
ffffffffc02056f6:	8fd9                	or	a5,a5,a4
ffffffffc02056f8:	18079073          	csrw	satp,a5
ffffffffc02056fc:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b80>
ffffffffc0205700:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205704:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205708:	2c070263          	beqz	a4,ffffffffc02059cc <do_execve+0x352>
        current->mm = NULL;
ffffffffc020570c:	000db783          	ld	a5,0(s11)
ffffffffc0205710:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205714:	a1dfb0ef          	jal	ra,ffffffffc0201130 <mm_create>
ffffffffc0205718:	84aa                	mv	s1,a0
ffffffffc020571a:	1c050b63          	beqz	a0,ffffffffc02058f0 <do_execve+0x276>
    if ((page = alloc_page()) == NULL) {
ffffffffc020571e:	4505                	li	a0,1
ffffffffc0205720:	eb9fd0ef          	jal	ra,ffffffffc02035d8 <alloc_pages>
ffffffffc0205724:	3a050763          	beqz	a0,ffffffffc0205ad2 <do_execve+0x458>
    return page - pages + nbase;
ffffffffc0205728:	000adc97          	auipc	s9,0xad
ffffffffc020572c:	100c8c93          	addi	s9,s9,256 # ffffffffc02b2828 <pages>
ffffffffc0205730:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc0205734:	000adc17          	auipc	s8,0xad
ffffffffc0205738:	0ecc0c13          	addi	s8,s8,236 # ffffffffc02b2820 <npage>
    return page - pages + nbase;
ffffffffc020573c:	00003717          	auipc	a4,0x3
ffffffffc0205740:	35473703          	ld	a4,852(a4) # ffffffffc0208a90 <nbase>
ffffffffc0205744:	40d506b3          	sub	a3,a0,a3
ffffffffc0205748:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020574a:	5afd                	li	s5,-1
ffffffffc020574c:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc0205750:	96ba                	add	a3,a3,a4
ffffffffc0205752:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205754:	00cad713          	srli	a4,s5,0xc
ffffffffc0205758:	ec3a                	sd	a4,24(sp)
ffffffffc020575a:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020575c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020575e:	36f77e63          	bgeu	a4,a5,ffffffffc0205ada <do_execve+0x460>
ffffffffc0205762:	000adb17          	auipc	s6,0xad
ffffffffc0205766:	0d6b0b13          	addi	s6,s6,214 # ffffffffc02b2838 <va_pa_offset>
ffffffffc020576a:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc020576e:	6605                	lui	a2,0x1
ffffffffc0205770:	000ad597          	auipc	a1,0xad
ffffffffc0205774:	0a85b583          	ld	a1,168(a1) # ffffffffc02b2818 <boot_pgdir>
ffffffffc0205778:	9936                	add	s2,s2,a3
ffffffffc020577a:	854a                	mv	a0,s2
ffffffffc020577c:	105000ef          	jal	ra,ffffffffc0206080 <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205780:	7782                	ld	a5,32(sp)
ffffffffc0205782:	4398                	lw	a4,0(a5)
ffffffffc0205784:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0205788:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc020578c:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b945f>
ffffffffc0205790:	14f71663          	bne	a4,a5,ffffffffc02058dc <do_execve+0x262>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205794:	7682                	ld	a3,32(sp)
ffffffffc0205796:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020579a:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020579e:	00371793          	slli	a5,a4,0x3
ffffffffc02057a2:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02057a4:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02057a6:	078e                	slli	a5,a5,0x3
ffffffffc02057a8:	97ce                	add	a5,a5,s3
ffffffffc02057aa:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc02057ac:	00f9fc63          	bgeu	s3,a5,ffffffffc02057c4 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc02057b0:	0009a783          	lw	a5,0(s3)
ffffffffc02057b4:	4705                	li	a4,1
ffffffffc02057b6:	12e78f63          	beq	a5,a4,ffffffffc02058f4 <do_execve+0x27a>
    for (; ph < ph_end; ph ++) {
ffffffffc02057ba:	77a2                	ld	a5,40(sp)
ffffffffc02057bc:	03898993          	addi	s3,s3,56
ffffffffc02057c0:	fef9e8e3          	bltu	s3,a5,ffffffffc02057b0 <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc02057c4:	4701                	li	a4,0
ffffffffc02057c6:	46ad                	li	a3,11
ffffffffc02057c8:	00100637          	lui	a2,0x100
ffffffffc02057cc:	7ff005b7          	lui	a1,0x7ff00
ffffffffc02057d0:	8526                	mv	a0,s1
ffffffffc02057d2:	b37fb0ef          	jal	ra,ffffffffc0201308 <mm_map>
ffffffffc02057d6:	8a2a                	mv	s4,a0
ffffffffc02057d8:	1e051063          	bnez	a0,ffffffffc02059b8 <do_execve+0x33e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc02057dc:	6c88                	ld	a0,24(s1)
ffffffffc02057de:	467d                	li	a2,31
ffffffffc02057e0:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02057e4:	a30ff0ef          	jal	ra,ffffffffc0204a14 <pgdir_alloc_page>
ffffffffc02057e8:	38050163          	beqz	a0,ffffffffc0205b6a <do_execve+0x4f0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc02057ec:	6c88                	ld	a0,24(s1)
ffffffffc02057ee:	467d                	li	a2,31
ffffffffc02057f0:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02057f4:	a20ff0ef          	jal	ra,ffffffffc0204a14 <pgdir_alloc_page>
ffffffffc02057f8:	34050963          	beqz	a0,ffffffffc0205b4a <do_execve+0x4d0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc02057fc:	6c88                	ld	a0,24(s1)
ffffffffc02057fe:	467d                	li	a2,31
ffffffffc0205800:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205804:	a10ff0ef          	jal	ra,ffffffffc0204a14 <pgdir_alloc_page>
ffffffffc0205808:	32050163          	beqz	a0,ffffffffc0205b2a <do_execve+0x4b0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc020580c:	6c88                	ld	a0,24(s1)
ffffffffc020580e:	467d                	li	a2,31
ffffffffc0205810:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205814:	a00ff0ef          	jal	ra,ffffffffc0204a14 <pgdir_alloc_page>
ffffffffc0205818:	2e050963          	beqz	a0,ffffffffc0205b0a <do_execve+0x490>
    mm->mm_count += 1;
ffffffffc020581c:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc020581e:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205822:	6c94                	ld	a3,24(s1)
ffffffffc0205824:	2785                	addiw	a5,a5,1
ffffffffc0205826:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0205828:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc020582a:	c02007b7          	lui	a5,0xc0200
ffffffffc020582e:	2cf6e263          	bltu	a3,a5,ffffffffc0205af2 <do_execve+0x478>
ffffffffc0205832:	000b3783          	ld	a5,0(s6)
ffffffffc0205836:	577d                	li	a4,-1
ffffffffc0205838:	177e                	slli	a4,a4,0x3f
ffffffffc020583a:	8e9d                	sub	a3,a3,a5
ffffffffc020583c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205840:	f654                	sd	a3,168(a2)
ffffffffc0205842:	8fd9                	or	a5,a5,a4
ffffffffc0205844:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205848:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc020584a:	4581                	li	a1,0
ffffffffc020584c:	12000613          	li	a2,288
ffffffffc0205850:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205852:	10043903          	ld	s2,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205856:	019000ef          	jal	ra,ffffffffc020606e <memset>
    tf->epc = elf->e_entry; // tf->epc应该是用户程序的入口点（sepc的值）
ffffffffc020585a:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020585c:	000db483          	ld	s1,0(s11)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE); // tf->status应该适合用户程序（sstatus的值）
ffffffffc0205860:	edf97913          	andi	s2,s2,-289
    tf->epc = elf->e_entry; // tf->epc应该是用户程序的入口点（sepc的值）
ffffffffc0205864:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP; // tf->gpr.sp应该是用户堆栈顶部（sp的值）
ffffffffc0205866:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205868:	0b448493          	addi	s1,s1,180
    tf->gpr.sp = USTACKTOP; // tf->gpr.sp应该是用户堆栈顶部（sp的值）
ffffffffc020586c:	07fe                	slli	a5,a5,0x1f
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020586e:	4641                	li	a2,16
ffffffffc0205870:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP; // tf->gpr.sp应该是用户堆栈顶部（sp的值）
ffffffffc0205872:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry; // tf->epc应该是用户程序的入口点（sepc的值）
ffffffffc0205874:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE); // tf->status应该适合用户程序（sstatus的值）
ffffffffc0205878:	11243023          	sd	s2,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020587c:	8526                	mv	a0,s1
ffffffffc020587e:	7f0000ef          	jal	ra,ffffffffc020606e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205882:	463d                	li	a2,15
ffffffffc0205884:	180c                	addi	a1,sp,48
ffffffffc0205886:	8526                	mv	a0,s1
ffffffffc0205888:	7f8000ef          	jal	ra,ffffffffc0206080 <memcpy>
}
ffffffffc020588c:	70aa                	ld	ra,168(sp)
ffffffffc020588e:	740a                	ld	s0,160(sp)
ffffffffc0205890:	64ea                	ld	s1,152(sp)
ffffffffc0205892:	694a                	ld	s2,144(sp)
ffffffffc0205894:	69aa                	ld	s3,136(sp)
ffffffffc0205896:	7ae6                	ld	s5,120(sp)
ffffffffc0205898:	7b46                	ld	s6,112(sp)
ffffffffc020589a:	7ba6                	ld	s7,104(sp)
ffffffffc020589c:	7c06                	ld	s8,96(sp)
ffffffffc020589e:	6ce6                	ld	s9,88(sp)
ffffffffc02058a0:	6d46                	ld	s10,80(sp)
ffffffffc02058a2:	6da6                	ld	s11,72(sp)
ffffffffc02058a4:	8552                	mv	a0,s4
ffffffffc02058a6:	6a0a                	ld	s4,128(sp)
ffffffffc02058a8:	614d                	addi	sp,sp,176
ffffffffc02058aa:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc02058ac:	463d                	li	a2,15
ffffffffc02058ae:	85ca                	mv	a1,s2
ffffffffc02058b0:	1808                	addi	a0,sp,48
ffffffffc02058b2:	7ce000ef          	jal	ra,ffffffffc0206080 <memcpy>
    if (mm != NULL) {
ffffffffc02058b6:	e20993e3          	bnez	s3,ffffffffc02056dc <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc02058ba:	000db783          	ld	a5,0(s11)
ffffffffc02058be:	779c                	ld	a5,40(a5)
ffffffffc02058c0:	e4078ae3          	beqz	a5,ffffffffc0205714 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02058c4:	00003617          	auipc	a2,0x3
ffffffffc02058c8:	afc60613          	addi	a2,a2,-1284 # ffffffffc02083c0 <default_pmm_manager+0x828>
ffffffffc02058cc:	21100593          	li	a1,529
ffffffffc02058d0:	00003517          	auipc	a0,0x3
ffffffffc02058d4:	90850513          	addi	a0,a0,-1784 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc02058d8:	931fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    put_pgdir(mm);
ffffffffc02058dc:	8526                	mv	a0,s1
ffffffffc02058de:	c26ff0ef          	jal	ra,ffffffffc0204d04 <put_pgdir>
    mm_destroy(mm);
ffffffffc02058e2:	8526                	mv	a0,s1
ffffffffc02058e4:	9d3fb0ef          	jal	ra,ffffffffc02012b6 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02058e8:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc02058ea:	8552                	mv	a0,s4
ffffffffc02058ec:	94fff0ef          	jal	ra,ffffffffc020523a <do_exit>
    int ret = -E_NO_MEM;
ffffffffc02058f0:	5a71                	li	s4,-4
ffffffffc02058f2:	bfe5                	j	ffffffffc02058ea <do_execve+0x270>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc02058f4:	0289b603          	ld	a2,40(s3)
ffffffffc02058f8:	0209b783          	ld	a5,32(s3)
ffffffffc02058fc:	1cf66d63          	bltu	a2,a5,ffffffffc0205ad6 <do_execve+0x45c>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205900:	0049a783          	lw	a5,4(s3)
ffffffffc0205904:	0017f693          	andi	a3,a5,1
ffffffffc0205908:	c291                	beqz	a3,ffffffffc020590c <do_execve+0x292>
ffffffffc020590a:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc020590c:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205910:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205912:	e779                	bnez	a4,ffffffffc02059e0 <do_execve+0x366>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205914:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205916:	c781                	beqz	a5,ffffffffc020591e <do_execve+0x2a4>
ffffffffc0205918:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc020591c:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc020591e:	0026f793          	andi	a5,a3,2
ffffffffc0205922:	e3f1                	bnez	a5,ffffffffc02059e6 <do_execve+0x36c>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205924:	0046f793          	andi	a5,a3,4
ffffffffc0205928:	c399                	beqz	a5,ffffffffc020592e <do_execve+0x2b4>
ffffffffc020592a:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc020592e:	0109b583          	ld	a1,16(s3)
ffffffffc0205932:	4701                	li	a4,0
ffffffffc0205934:	8526                	mv	a0,s1
ffffffffc0205936:	9d3fb0ef          	jal	ra,ffffffffc0201308 <mm_map>
ffffffffc020593a:	8a2a                	mv	s4,a0
ffffffffc020593c:	ed35                	bnez	a0,ffffffffc02059b8 <do_execve+0x33e>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc020593e:	0109bb83          	ld	s7,16(s3)
ffffffffc0205942:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205944:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205948:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc020594c:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205950:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205952:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205954:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc0205956:	054be963          	bltu	s7,s4,ffffffffc02059a8 <do_execve+0x32e>
ffffffffc020595a:	aa95                	j	ffffffffc0205ace <do_execve+0x454>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc020595c:	6785                	lui	a5,0x1
ffffffffc020595e:	415b8533          	sub	a0,s7,s5
ffffffffc0205962:	9abe                	add	s5,s5,a5
ffffffffc0205964:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205968:	015a7463          	bgeu	s4,s5,ffffffffc0205970 <do_execve+0x2f6>
                size -= la - end;
ffffffffc020596c:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0205970:	000cb683          	ld	a3,0(s9)
ffffffffc0205974:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205976:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc020597a:	40d406b3          	sub	a3,s0,a3
ffffffffc020597e:	8699                	srai	a3,a3,0x6
ffffffffc0205980:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205982:	67e2                	ld	a5,24(sp)
ffffffffc0205984:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205988:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020598a:	14b87863          	bgeu	a6,a1,ffffffffc0205ada <do_execve+0x460>
ffffffffc020598e:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205992:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0205994:	9bb2                	add	s7,s7,a2
ffffffffc0205996:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205998:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc020599a:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc020599c:	6e4000ef          	jal	ra,ffffffffc0206080 <memcpy>
            start += size, from += size;
ffffffffc02059a0:	6622                	ld	a2,8(sp)
ffffffffc02059a2:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc02059a4:	054bf363          	bgeu	s7,s4,ffffffffc02059ea <do_execve+0x370>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc02059a8:	6c88                	ld	a0,24(s1)
ffffffffc02059aa:	866a                	mv	a2,s10
ffffffffc02059ac:	85d6                	mv	a1,s5
ffffffffc02059ae:	866ff0ef          	jal	ra,ffffffffc0204a14 <pgdir_alloc_page>
ffffffffc02059b2:	842a                	mv	s0,a0
ffffffffc02059b4:	f545                	bnez	a0,ffffffffc020595c <do_execve+0x2e2>
        ret = -E_NO_MEM;
ffffffffc02059b6:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc02059b8:	8526                	mv	a0,s1
ffffffffc02059ba:	a99fb0ef          	jal	ra,ffffffffc0201452 <exit_mmap>
    put_pgdir(mm);
ffffffffc02059be:	8526                	mv	a0,s1
ffffffffc02059c0:	b44ff0ef          	jal	ra,ffffffffc0204d04 <put_pgdir>
    mm_destroy(mm);
ffffffffc02059c4:	8526                	mv	a0,s1
ffffffffc02059c6:	8f1fb0ef          	jal	ra,ffffffffc02012b6 <mm_destroy>
    return ret;
ffffffffc02059ca:	b705                	j	ffffffffc02058ea <do_execve+0x270>
            exit_mmap(mm);
ffffffffc02059cc:	854e                	mv	a0,s3
ffffffffc02059ce:	a85fb0ef          	jal	ra,ffffffffc0201452 <exit_mmap>
            put_pgdir(mm);
ffffffffc02059d2:	854e                	mv	a0,s3
ffffffffc02059d4:	b30ff0ef          	jal	ra,ffffffffc0204d04 <put_pgdir>
            mm_destroy(mm);
ffffffffc02059d8:	854e                	mv	a0,s3
ffffffffc02059da:	8ddfb0ef          	jal	ra,ffffffffc02012b6 <mm_destroy>
ffffffffc02059de:	b33d                	j	ffffffffc020570c <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02059e0:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc02059e4:	fb95                	bnez	a5,ffffffffc0205918 <do_execve+0x29e>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc02059e6:	4d5d                	li	s10,23
ffffffffc02059e8:	bf35                	j	ffffffffc0205924 <do_execve+0x2aa>
        end = ph->p_va + ph->p_memsz;
ffffffffc02059ea:	0109b683          	ld	a3,16(s3)
ffffffffc02059ee:	0289b903          	ld	s2,40(s3)
ffffffffc02059f2:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc02059f4:	075bfd63          	bgeu	s7,s5,ffffffffc0205a6e <do_execve+0x3f4>
            if (start == end) {
ffffffffc02059f8:	dd7901e3          	beq	s2,s7,ffffffffc02057ba <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc02059fc:	6785                	lui	a5,0x1
ffffffffc02059fe:	00fb8533          	add	a0,s7,a5
ffffffffc0205a02:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0205a06:	41790a33          	sub	s4,s2,s7
            if (end < la) {
ffffffffc0205a0a:	0b597d63          	bgeu	s2,s5,ffffffffc0205ac4 <do_execve+0x44a>
    return page - pages + nbase;
ffffffffc0205a0e:	000cb683          	ld	a3,0(s9)
ffffffffc0205a12:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205a14:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0205a18:	40d406b3          	sub	a3,s0,a3
ffffffffc0205a1c:	8699                	srai	a3,a3,0x6
ffffffffc0205a1e:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205a20:	67e2                	ld	a5,24(sp)
ffffffffc0205a22:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205a26:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205a28:	0ac5f963          	bgeu	a1,a2,ffffffffc0205ada <do_execve+0x460>
ffffffffc0205a2c:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205a30:	8652                	mv	a2,s4
ffffffffc0205a32:	4581                	li	a1,0
ffffffffc0205a34:	96c2                	add	a3,a3,a6
ffffffffc0205a36:	9536                	add	a0,a0,a3
ffffffffc0205a38:	636000ef          	jal	ra,ffffffffc020606e <memset>
            start += size;
ffffffffc0205a3c:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205a40:	03597463          	bgeu	s2,s5,ffffffffc0205a68 <do_execve+0x3ee>
ffffffffc0205a44:	d6e90be3          	beq	s2,a4,ffffffffc02057ba <do_execve+0x140>
ffffffffc0205a48:	00003697          	auipc	a3,0x3
ffffffffc0205a4c:	9a068693          	addi	a3,a3,-1632 # ffffffffc02083e8 <default_pmm_manager+0x850>
ffffffffc0205a50:	00001617          	auipc	a2,0x1
ffffffffc0205a54:	10860613          	addi	a2,a2,264 # ffffffffc0206b58 <commands+0x410>
ffffffffc0205a58:	26600593          	li	a1,614
ffffffffc0205a5c:	00002517          	auipc	a0,0x2
ffffffffc0205a60:	77c50513          	addi	a0,a0,1916 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc0205a64:	fa4fa0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0205a68:	ff5710e3          	bne	a4,s5,ffffffffc0205a48 <do_execve+0x3ce>
ffffffffc0205a6c:	8bd6                	mv	s7,s5
        while (start < end) {
ffffffffc0205a6e:	d52bf6e3          	bgeu	s7,s2,ffffffffc02057ba <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205a72:	6c88                	ld	a0,24(s1)
ffffffffc0205a74:	866a                	mv	a2,s10
ffffffffc0205a76:	85d6                	mv	a1,s5
ffffffffc0205a78:	f9dfe0ef          	jal	ra,ffffffffc0204a14 <pgdir_alloc_page>
ffffffffc0205a7c:	842a                	mv	s0,a0
ffffffffc0205a7e:	dd05                	beqz	a0,ffffffffc02059b6 <do_execve+0x33c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205a80:	6785                	lui	a5,0x1
ffffffffc0205a82:	415b8533          	sub	a0,s7,s5
ffffffffc0205a86:	9abe                	add	s5,s5,a5
ffffffffc0205a88:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205a8c:	01597463          	bgeu	s2,s5,ffffffffc0205a94 <do_execve+0x41a>
                size -= la - end;
ffffffffc0205a90:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0205a94:	000cb683          	ld	a3,0(s9)
ffffffffc0205a98:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205a9a:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205a9e:	40d406b3          	sub	a3,s0,a3
ffffffffc0205aa2:	8699                	srai	a3,a3,0x6
ffffffffc0205aa4:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205aa6:	67e2                	ld	a5,24(sp)
ffffffffc0205aa8:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205aac:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205aae:	02b87663          	bgeu	a6,a1,ffffffffc0205ada <do_execve+0x460>
ffffffffc0205ab2:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205ab6:	4581                	li	a1,0
            start += size;
ffffffffc0205ab8:	9bb2                	add	s7,s7,a2
ffffffffc0205aba:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205abc:	9536                	add	a0,a0,a3
ffffffffc0205abe:	5b0000ef          	jal	ra,ffffffffc020606e <memset>
ffffffffc0205ac2:	b775                	j	ffffffffc0205a6e <do_execve+0x3f4>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205ac4:	417a8a33          	sub	s4,s5,s7
ffffffffc0205ac8:	b799                	j	ffffffffc0205a0e <do_execve+0x394>
        return -E_INVAL;
ffffffffc0205aca:	5a75                	li	s4,-3
ffffffffc0205acc:	b3c1                	j	ffffffffc020588c <do_execve+0x212>
        while (start < end) {
ffffffffc0205ace:	86de                	mv	a3,s7
ffffffffc0205ad0:	bf39                	j	ffffffffc02059ee <do_execve+0x374>
    int ret = -E_NO_MEM;
ffffffffc0205ad2:	5a71                	li	s4,-4
ffffffffc0205ad4:	bdc5                	j	ffffffffc02059c4 <do_execve+0x34a>
            ret = -E_INVAL_ELF;
ffffffffc0205ad6:	5a61                	li	s4,-8
ffffffffc0205ad8:	b5c5                	j	ffffffffc02059b8 <do_execve+0x33e>
ffffffffc0205ada:	00001617          	auipc	a2,0x1
ffffffffc0205ade:	44e60613          	addi	a2,a2,1102 # ffffffffc0206f28 <commands+0x7e0>
ffffffffc0205ae2:	06900593          	li	a1,105
ffffffffc0205ae6:	00001517          	auipc	a0,0x1
ffffffffc0205aea:	3e250513          	addi	a0,a0,994 # ffffffffc0206ec8 <commands+0x780>
ffffffffc0205aee:	f1afa0ef          	jal	ra,ffffffffc0200208 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205af2:	00002617          	auipc	a2,0x2
ffffffffc0205af6:	9ce60613          	addi	a2,a2,-1586 # ffffffffc02074c0 <commands+0xd78>
ffffffffc0205afa:	28100593          	li	a1,641
ffffffffc0205afe:	00002517          	auipc	a0,0x2
ffffffffc0205b02:	6da50513          	addi	a0,a0,1754 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc0205b06:	f02fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b0a:	00003697          	auipc	a3,0x3
ffffffffc0205b0e:	9f668693          	addi	a3,a3,-1546 # ffffffffc0208500 <default_pmm_manager+0x968>
ffffffffc0205b12:	00001617          	auipc	a2,0x1
ffffffffc0205b16:	04660613          	addi	a2,a2,70 # ffffffffc0206b58 <commands+0x410>
ffffffffc0205b1a:	27c00593          	li	a1,636
ffffffffc0205b1e:	00002517          	auipc	a0,0x2
ffffffffc0205b22:	6ba50513          	addi	a0,a0,1722 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc0205b26:	ee2fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b2a:	00003697          	auipc	a3,0x3
ffffffffc0205b2e:	98e68693          	addi	a3,a3,-1650 # ffffffffc02084b8 <default_pmm_manager+0x920>
ffffffffc0205b32:	00001617          	auipc	a2,0x1
ffffffffc0205b36:	02660613          	addi	a2,a2,38 # ffffffffc0206b58 <commands+0x410>
ffffffffc0205b3a:	27b00593          	li	a1,635
ffffffffc0205b3e:	00002517          	auipc	a0,0x2
ffffffffc0205b42:	69a50513          	addi	a0,a0,1690 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc0205b46:	ec2fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b4a:	00003697          	auipc	a3,0x3
ffffffffc0205b4e:	92668693          	addi	a3,a3,-1754 # ffffffffc0208470 <default_pmm_manager+0x8d8>
ffffffffc0205b52:	00001617          	auipc	a2,0x1
ffffffffc0205b56:	00660613          	addi	a2,a2,6 # ffffffffc0206b58 <commands+0x410>
ffffffffc0205b5a:	27a00593          	li	a1,634
ffffffffc0205b5e:	00002517          	auipc	a0,0x2
ffffffffc0205b62:	67a50513          	addi	a0,a0,1658 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc0205b66:	ea2fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205b6a:	00003697          	auipc	a3,0x3
ffffffffc0205b6e:	8be68693          	addi	a3,a3,-1858 # ffffffffc0208428 <default_pmm_manager+0x890>
ffffffffc0205b72:	00001617          	auipc	a2,0x1
ffffffffc0205b76:	fe660613          	addi	a2,a2,-26 # ffffffffc0206b58 <commands+0x410>
ffffffffc0205b7a:	27900593          	li	a1,633
ffffffffc0205b7e:	00002517          	auipc	a0,0x2
ffffffffc0205b82:	65a50513          	addi	a0,a0,1626 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc0205b86:	e82fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205b8a <do_yield>:
    current->need_resched = 1;
ffffffffc0205b8a:	000ad797          	auipc	a5,0xad
ffffffffc0205b8e:	cb67b783          	ld	a5,-842(a5) # ffffffffc02b2840 <current>
ffffffffc0205b92:	4705                	li	a4,1
ffffffffc0205b94:	ef98                	sd	a4,24(a5)
}
ffffffffc0205b96:	4501                	li	a0,0
ffffffffc0205b98:	8082                	ret

ffffffffc0205b9a <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205b9a:	1101                	addi	sp,sp,-32
ffffffffc0205b9c:	e822                	sd	s0,16(sp)
ffffffffc0205b9e:	e426                	sd	s1,8(sp)
ffffffffc0205ba0:	ec06                	sd	ra,24(sp)
ffffffffc0205ba2:	842e                	mv	s0,a1
ffffffffc0205ba4:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205ba6:	c999                	beqz	a1,ffffffffc0205bbc <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205ba8:	000ad797          	auipc	a5,0xad
ffffffffc0205bac:	c987b783          	ld	a5,-872(a5) # ffffffffc02b2840 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205bb0:	7788                	ld	a0,40(a5)
ffffffffc0205bb2:	4685                	li	a3,1
ffffffffc0205bb4:	4611                	li	a2,4
ffffffffc0205bb6:	e53fb0ef          	jal	ra,ffffffffc0201a08 <user_mem_check>
ffffffffc0205bba:	c909                	beqz	a0,ffffffffc0205bcc <do_wait+0x32>
ffffffffc0205bbc:	85a2                	mv	a1,s0
}
ffffffffc0205bbe:	6442                	ld	s0,16(sp)
ffffffffc0205bc0:	60e2                	ld	ra,24(sp)
ffffffffc0205bc2:	8526                	mv	a0,s1
ffffffffc0205bc4:	64a2                	ld	s1,8(sp)
ffffffffc0205bc6:	6105                	addi	sp,sp,32
ffffffffc0205bc8:	fbcff06f          	j	ffffffffc0205384 <do_wait.part.0>
ffffffffc0205bcc:	60e2                	ld	ra,24(sp)
ffffffffc0205bce:	6442                	ld	s0,16(sp)
ffffffffc0205bd0:	64a2                	ld	s1,8(sp)
ffffffffc0205bd2:	5575                	li	a0,-3
ffffffffc0205bd4:	6105                	addi	sp,sp,32
ffffffffc0205bd6:	8082                	ret

ffffffffc0205bd8 <do_kill>:
do_kill(int pid) {
ffffffffc0205bd8:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205bda:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc0205bdc:	e406                	sd	ra,8(sp)
ffffffffc0205bde:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205be0:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205be4:	17f9                	addi	a5,a5,-2
ffffffffc0205be6:	02e7e963          	bltu	a5,a4,ffffffffc0205c18 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205bea:	842a                	mv	s0,a0
ffffffffc0205bec:	45a9                	li	a1,10
ffffffffc0205bee:	2501                	sext.w	a0,a0
ffffffffc0205bf0:	097000ef          	jal	ra,ffffffffc0206486 <hash32>
ffffffffc0205bf4:	02051793          	slli	a5,a0,0x20
ffffffffc0205bf8:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205bfc:	000a9797          	auipc	a5,0xa9
ffffffffc0205c00:	bbc78793          	addi	a5,a5,-1092 # ffffffffc02ae7b8 <hash_list>
ffffffffc0205c04:	953e                	add	a0,a0,a5
ffffffffc0205c06:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205c08:	a029                	j	ffffffffc0205c12 <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205c0a:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205c0e:	00870b63          	beq	a4,s0,ffffffffc0205c24 <do_kill+0x4c>
ffffffffc0205c12:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205c14:	fef51be3          	bne	a0,a5,ffffffffc0205c0a <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205c18:	5475                	li	s0,-3
}
ffffffffc0205c1a:	60a2                	ld	ra,8(sp)
ffffffffc0205c1c:	8522                	mv	a0,s0
ffffffffc0205c1e:	6402                	ld	s0,0(sp)
ffffffffc0205c20:	0141                	addi	sp,sp,16
ffffffffc0205c22:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205c24:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205c28:	00177693          	andi	a3,a4,1
ffffffffc0205c2c:	e295                	bnez	a3,ffffffffc0205c50 <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205c2e:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205c30:	00176713          	ori	a4,a4,1
ffffffffc0205c34:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205c38:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205c3a:	fe06d0e3          	bgez	a3,ffffffffc0205c1a <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205c3e:	f2878513          	addi	a0,a5,-216
ffffffffc0205c42:	1c4000ef          	jal	ra,ffffffffc0205e06 <wakeup_proc>
}
ffffffffc0205c46:	60a2                	ld	ra,8(sp)
ffffffffc0205c48:	8522                	mv	a0,s0
ffffffffc0205c4a:	6402                	ld	s0,0(sp)
ffffffffc0205c4c:	0141                	addi	sp,sp,16
ffffffffc0205c4e:	8082                	ret
        return -E_KILLED;
ffffffffc0205c50:	545d                	li	s0,-9
ffffffffc0205c52:	b7e1                	j	ffffffffc0205c1a <do_kill+0x42>

ffffffffc0205c54 <proc_init>:


// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205c54:	1101                	addi	sp,sp,-32
ffffffffc0205c56:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205c58:	000ad797          	auipc	a5,0xad
ffffffffc0205c5c:	b6078793          	addi	a5,a5,-1184 # ffffffffc02b27b8 <proc_list>
ffffffffc0205c60:	ec06                	sd	ra,24(sp)
ffffffffc0205c62:	e822                	sd	s0,16(sp)
ffffffffc0205c64:	e04a                	sd	s2,0(sp)
ffffffffc0205c66:	000a9497          	auipc	s1,0xa9
ffffffffc0205c6a:	b5248493          	addi	s1,s1,-1198 # ffffffffc02ae7b8 <hash_list>
ffffffffc0205c6e:	e79c                	sd	a5,8(a5)
ffffffffc0205c70:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205c72:	000ad717          	auipc	a4,0xad
ffffffffc0205c76:	b4670713          	addi	a4,a4,-1210 # ffffffffc02b27b8 <proc_list>
ffffffffc0205c7a:	87a6                	mv	a5,s1
ffffffffc0205c7c:	e79c                	sd	a5,8(a5)
ffffffffc0205c7e:	e39c                	sd	a5,0(a5)
ffffffffc0205c80:	07c1                	addi	a5,a5,16
ffffffffc0205c82:	fef71de3          	bne	a4,a5,ffffffffc0205c7c <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205c86:	f81fe0ef          	jal	ra,ffffffffc0204c06 <alloc_proc>
ffffffffc0205c8a:	000ad917          	auipc	s2,0xad
ffffffffc0205c8e:	bbe90913          	addi	s2,s2,-1090 # ffffffffc02b2848 <idleproc>
ffffffffc0205c92:	00a93023          	sd	a0,0(s2)
ffffffffc0205c96:	0e050f63          	beqz	a0,ffffffffc0205d94 <proc_init+0x140>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205c9a:	4789                	li	a5,2
ffffffffc0205c9c:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205c9e:	00003797          	auipc	a5,0x3
ffffffffc0205ca2:	36278793          	addi	a5,a5,866 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205ca6:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205caa:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205cac:	4785                	li	a5,1
ffffffffc0205cae:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205cb0:	4641                	li	a2,16
ffffffffc0205cb2:	4581                	li	a1,0
ffffffffc0205cb4:	8522                	mv	a0,s0
ffffffffc0205cb6:	3b8000ef          	jal	ra,ffffffffc020606e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205cba:	463d                	li	a2,15
ffffffffc0205cbc:	00003597          	auipc	a1,0x3
ffffffffc0205cc0:	8a458593          	addi	a1,a1,-1884 # ffffffffc0208560 <default_pmm_manager+0x9c8>
ffffffffc0205cc4:	8522                	mv	a0,s0
ffffffffc0205cc6:	3ba000ef          	jal	ra,ffffffffc0206080 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205cca:	000ad717          	auipc	a4,0xad
ffffffffc0205cce:	b8e70713          	addi	a4,a4,-1138 # ffffffffc02b2858 <nr_process>
ffffffffc0205cd2:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205cd4:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205cd8:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205cda:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205cdc:	4581                	li	a1,0
ffffffffc0205cde:	00000517          	auipc	a0,0x0
ffffffffc0205ce2:	87850513          	addi	a0,a0,-1928 # ffffffffc0205556 <init_main>
    nr_process ++;
ffffffffc0205ce6:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205ce8:	000ad797          	auipc	a5,0xad
ffffffffc0205cec:	b4d7bc23          	sd	a3,-1192(a5) # ffffffffc02b2840 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205cf0:	cfaff0ef          	jal	ra,ffffffffc02051ea <kernel_thread>
ffffffffc0205cf4:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0205cf6:	08a05363          	blez	a0,ffffffffc0205d7c <proc_init+0x128>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205cfa:	6789                	lui	a5,0x2
ffffffffc0205cfc:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205d00:	17f9                	addi	a5,a5,-2
ffffffffc0205d02:	2501                	sext.w	a0,a0
ffffffffc0205d04:	02e7e363          	bltu	a5,a4,ffffffffc0205d2a <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205d08:	45a9                	li	a1,10
ffffffffc0205d0a:	77c000ef          	jal	ra,ffffffffc0206486 <hash32>
ffffffffc0205d0e:	02051793          	slli	a5,a0,0x20
ffffffffc0205d12:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205d16:	96a6                	add	a3,a3,s1
ffffffffc0205d18:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205d1a:	a029                	j	ffffffffc0205d24 <proc_init+0xd0>
            if (proc->pid == pid) {
ffffffffc0205d1c:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c84>
ffffffffc0205d20:	04870b63          	beq	a4,s0,ffffffffc0205d76 <proc_init+0x122>
    return listelm->next;
ffffffffc0205d24:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205d26:	fef69be3          	bne	a3,a5,ffffffffc0205d1c <proc_init+0xc8>
    return NULL;
ffffffffc0205d2a:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205d2c:	0b478493          	addi	s1,a5,180
ffffffffc0205d30:	4641                	li	a2,16
ffffffffc0205d32:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205d34:	000ad417          	auipc	s0,0xad
ffffffffc0205d38:	b1c40413          	addi	s0,s0,-1252 # ffffffffc02b2850 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205d3c:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205d3e:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205d40:	32e000ef          	jal	ra,ffffffffc020606e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205d44:	463d                	li	a2,15
ffffffffc0205d46:	00003597          	auipc	a1,0x3
ffffffffc0205d4a:	84258593          	addi	a1,a1,-1982 # ffffffffc0208588 <default_pmm_manager+0x9f0>
ffffffffc0205d4e:	8526                	mv	a0,s1
ffffffffc0205d50:	330000ef          	jal	ra,ffffffffc0206080 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205d54:	00093783          	ld	a5,0(s2)
ffffffffc0205d58:	cbb5                	beqz	a5,ffffffffc0205dcc <proc_init+0x178>
ffffffffc0205d5a:	43dc                	lw	a5,4(a5)
ffffffffc0205d5c:	eba5                	bnez	a5,ffffffffc0205dcc <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205d5e:	601c                	ld	a5,0(s0)
ffffffffc0205d60:	c7b1                	beqz	a5,ffffffffc0205dac <proc_init+0x158>
ffffffffc0205d62:	43d8                	lw	a4,4(a5)
ffffffffc0205d64:	4785                	li	a5,1
ffffffffc0205d66:	04f71363          	bne	a4,a5,ffffffffc0205dac <proc_init+0x158>
}
ffffffffc0205d6a:	60e2                	ld	ra,24(sp)
ffffffffc0205d6c:	6442                	ld	s0,16(sp)
ffffffffc0205d6e:	64a2                	ld	s1,8(sp)
ffffffffc0205d70:	6902                	ld	s2,0(sp)
ffffffffc0205d72:	6105                	addi	sp,sp,32
ffffffffc0205d74:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205d76:	f2878793          	addi	a5,a5,-216
ffffffffc0205d7a:	bf4d                	j	ffffffffc0205d2c <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205d7c:	00002617          	auipc	a2,0x2
ffffffffc0205d80:	7ec60613          	addi	a2,a2,2028 # ffffffffc0208568 <default_pmm_manager+0x9d0>
ffffffffc0205d84:	38d00593          	li	a1,909
ffffffffc0205d88:	00002517          	auipc	a0,0x2
ffffffffc0205d8c:	45050513          	addi	a0,a0,1104 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc0205d90:	c78fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205d94:	00002617          	auipc	a2,0x2
ffffffffc0205d98:	7b460613          	addi	a2,a2,1972 # ffffffffc0208548 <default_pmm_manager+0x9b0>
ffffffffc0205d9c:	37f00593          	li	a1,895
ffffffffc0205da0:	00002517          	auipc	a0,0x2
ffffffffc0205da4:	43850513          	addi	a0,a0,1080 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc0205da8:	c60fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205dac:	00003697          	auipc	a3,0x3
ffffffffc0205db0:	80c68693          	addi	a3,a3,-2036 # ffffffffc02085b8 <default_pmm_manager+0xa20>
ffffffffc0205db4:	00001617          	auipc	a2,0x1
ffffffffc0205db8:	da460613          	addi	a2,a2,-604 # ffffffffc0206b58 <commands+0x410>
ffffffffc0205dbc:	39400593          	li	a1,916
ffffffffc0205dc0:	00002517          	auipc	a0,0x2
ffffffffc0205dc4:	41850513          	addi	a0,a0,1048 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc0205dc8:	c40fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205dcc:	00002697          	auipc	a3,0x2
ffffffffc0205dd0:	7c468693          	addi	a3,a3,1988 # ffffffffc0208590 <default_pmm_manager+0x9f8>
ffffffffc0205dd4:	00001617          	auipc	a2,0x1
ffffffffc0205dd8:	d8460613          	addi	a2,a2,-636 # ffffffffc0206b58 <commands+0x410>
ffffffffc0205ddc:	39300593          	li	a1,915
ffffffffc0205de0:	00002517          	auipc	a0,0x2
ffffffffc0205de4:	3f850513          	addi	a0,a0,1016 # ffffffffc02081d8 <default_pmm_manager+0x640>
ffffffffc0205de8:	c20fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205dec <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205dec:	1141                	addi	sp,sp,-16
ffffffffc0205dee:	e022                	sd	s0,0(sp)
ffffffffc0205df0:	e406                	sd	ra,8(sp)
ffffffffc0205df2:	000ad417          	auipc	s0,0xad
ffffffffc0205df6:	a4e40413          	addi	s0,s0,-1458 # ffffffffc02b2840 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205dfa:	6018                	ld	a4,0(s0)
ffffffffc0205dfc:	6f1c                	ld	a5,24(a4)
ffffffffc0205dfe:	dffd                	beqz	a5,ffffffffc0205dfc <cpu_idle+0x10>
            schedule();
ffffffffc0205e00:	086000ef          	jal	ra,ffffffffc0205e86 <schedule>
ffffffffc0205e04:	bfdd                	j	ffffffffc0205dfa <cpu_idle+0xe>

ffffffffc0205e06 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205e06:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205e08:	1101                	addi	sp,sp,-32
ffffffffc0205e0a:	ec06                	sd	ra,24(sp)
ffffffffc0205e0c:	e822                	sd	s0,16(sp)
ffffffffc0205e0e:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205e10:	478d                	li	a5,3
ffffffffc0205e12:	04f70b63          	beq	a4,a5,ffffffffc0205e68 <wakeup_proc+0x62>
ffffffffc0205e16:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205e18:	100027f3          	csrr	a5,sstatus
ffffffffc0205e1c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205e1e:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205e20:	ef9d                	bnez	a5,ffffffffc0205e5e <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205e22:	4789                	li	a5,2
ffffffffc0205e24:	02f70163          	beq	a4,a5,ffffffffc0205e46 <wakeup_proc+0x40>
            proc->state = PROC_RUNNABLE;
ffffffffc0205e28:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0205e2a:	0e042623          	sw	zero,236(s0)
    if (flag) {
ffffffffc0205e2e:	e491                	bnez	s1,ffffffffc0205e3a <wakeup_proc+0x34>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205e30:	60e2                	ld	ra,24(sp)
ffffffffc0205e32:	6442                	ld	s0,16(sp)
ffffffffc0205e34:	64a2                	ld	s1,8(sp)
ffffffffc0205e36:	6105                	addi	sp,sp,32
ffffffffc0205e38:	8082                	ret
ffffffffc0205e3a:	6442                	ld	s0,16(sp)
ffffffffc0205e3c:	60e2                	ld	ra,24(sp)
ffffffffc0205e3e:	64a2                	ld	s1,8(sp)
ffffffffc0205e40:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205e42:	fdcfa06f          	j	ffffffffc020061e <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205e46:	00002617          	auipc	a2,0x2
ffffffffc0205e4a:	7d260613          	addi	a2,a2,2002 # ffffffffc0208618 <default_pmm_manager+0xa80>
ffffffffc0205e4e:	45c9                	li	a1,18
ffffffffc0205e50:	00002517          	auipc	a0,0x2
ffffffffc0205e54:	7b050513          	addi	a0,a0,1968 # ffffffffc0208600 <default_pmm_manager+0xa68>
ffffffffc0205e58:	c18fa0ef          	jal	ra,ffffffffc0200270 <__warn>
ffffffffc0205e5c:	bfc9                	j	ffffffffc0205e2e <wakeup_proc+0x28>
        intr_disable();
ffffffffc0205e5e:	fc6fa0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205e62:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0205e64:	4485                	li	s1,1
ffffffffc0205e66:	bf75                	j	ffffffffc0205e22 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205e68:	00002697          	auipc	a3,0x2
ffffffffc0205e6c:	77868693          	addi	a3,a3,1912 # ffffffffc02085e0 <default_pmm_manager+0xa48>
ffffffffc0205e70:	00001617          	auipc	a2,0x1
ffffffffc0205e74:	ce860613          	addi	a2,a2,-792 # ffffffffc0206b58 <commands+0x410>
ffffffffc0205e78:	45a5                	li	a1,9
ffffffffc0205e7a:	00002517          	auipc	a0,0x2
ffffffffc0205e7e:	78650513          	addi	a0,a0,1926 # ffffffffc0208600 <default_pmm_manager+0xa68>
ffffffffc0205e82:	b86fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205e86 <schedule>:

void
schedule(void) {
ffffffffc0205e86:	1141                	addi	sp,sp,-16
ffffffffc0205e88:	e406                	sd	ra,8(sp)
ffffffffc0205e8a:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205e8c:	100027f3          	csrr	a5,sstatus
ffffffffc0205e90:	8b89                	andi	a5,a5,2
ffffffffc0205e92:	4401                	li	s0,0
ffffffffc0205e94:	efbd                	bnez	a5,ffffffffc0205f12 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205e96:	000ad897          	auipc	a7,0xad
ffffffffc0205e9a:	9aa8b883          	ld	a7,-1622(a7) # ffffffffc02b2840 <current>
ffffffffc0205e9e:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205ea2:	000ad517          	auipc	a0,0xad
ffffffffc0205ea6:	9a653503          	ld	a0,-1626(a0) # ffffffffc02b2848 <idleproc>
ffffffffc0205eaa:	04a88e63          	beq	a7,a0,ffffffffc0205f06 <schedule+0x80>
ffffffffc0205eae:	0c888693          	addi	a3,a7,200
ffffffffc0205eb2:	000ad617          	auipc	a2,0xad
ffffffffc0205eb6:	90660613          	addi	a2,a2,-1786 # ffffffffc02b27b8 <proc_list>
        le = last;
ffffffffc0205eba:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205ebc:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205ebe:	4809                	li	a6,2
ffffffffc0205ec0:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205ec2:	00c78863          	beq	a5,a2,ffffffffc0205ed2 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205ec6:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205eca:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205ece:	03070163          	beq	a4,a6,ffffffffc0205ef0 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0205ed2:	fef697e3          	bne	a3,a5,ffffffffc0205ec0 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205ed6:	ed89                	bnez	a1,ffffffffc0205ef0 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0205ed8:	451c                	lw	a5,8(a0)
ffffffffc0205eda:	2785                	addiw	a5,a5,1
ffffffffc0205edc:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0205ede:	00a88463          	beq	a7,a0,ffffffffc0205ee6 <schedule+0x60>
            proc_run(next);
ffffffffc0205ee2:	e99fe0ef          	jal	ra,ffffffffc0204d7a <proc_run>
    if (flag) {
ffffffffc0205ee6:	e819                	bnez	s0,ffffffffc0205efc <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205ee8:	60a2                	ld	ra,8(sp)
ffffffffc0205eea:	6402                	ld	s0,0(sp)
ffffffffc0205eec:	0141                	addi	sp,sp,16
ffffffffc0205eee:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205ef0:	4198                	lw	a4,0(a1)
ffffffffc0205ef2:	4789                	li	a5,2
ffffffffc0205ef4:	fef712e3          	bne	a4,a5,ffffffffc0205ed8 <schedule+0x52>
ffffffffc0205ef8:	852e                	mv	a0,a1
ffffffffc0205efa:	bff9                	j	ffffffffc0205ed8 <schedule+0x52>
}
ffffffffc0205efc:	6402                	ld	s0,0(sp)
ffffffffc0205efe:	60a2                	ld	ra,8(sp)
ffffffffc0205f00:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0205f02:	f1cfa06f          	j	ffffffffc020061e <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205f06:	000ad617          	auipc	a2,0xad
ffffffffc0205f0a:	8b260613          	addi	a2,a2,-1870 # ffffffffc02b27b8 <proc_list>
ffffffffc0205f0e:	86b2                	mv	a3,a2
ffffffffc0205f10:	b76d                	j	ffffffffc0205eba <schedule+0x34>
        intr_disable();
ffffffffc0205f12:	f12fa0ef          	jal	ra,ffffffffc0200624 <intr_disable>
        return 1;
ffffffffc0205f16:	4405                	li	s0,1
ffffffffc0205f18:	bfbd                	j	ffffffffc0205e96 <schedule+0x10>

ffffffffc0205f1a <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205f1a:	000ad797          	auipc	a5,0xad
ffffffffc0205f1e:	9267b783          	ld	a5,-1754(a5) # ffffffffc02b2840 <current>
}
ffffffffc0205f22:	43c8                	lw	a0,4(a5)
ffffffffc0205f24:	8082                	ret

ffffffffc0205f26 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205f26:	4501                	li	a0,0
ffffffffc0205f28:	8082                	ret

ffffffffc0205f2a <sys_putc>:
    cputchar(c);
ffffffffc0205f2a:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205f2c:	1141                	addi	sp,sp,-16
ffffffffc0205f2e:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205f30:	9d2fa0ef          	jal	ra,ffffffffc0200102 <cputchar>
}
ffffffffc0205f34:	60a2                	ld	ra,8(sp)
ffffffffc0205f36:	4501                	li	a0,0
ffffffffc0205f38:	0141                	addi	sp,sp,16
ffffffffc0205f3a:	8082                	ret

ffffffffc0205f3c <sys_kill>:
    return do_kill(pid);
ffffffffc0205f3c:	4108                	lw	a0,0(a0)
ffffffffc0205f3e:	c9bff06f          	j	ffffffffc0205bd8 <do_kill>

ffffffffc0205f42 <sys_yield>:
    return do_yield();
ffffffffc0205f42:	c49ff06f          	j	ffffffffc0205b8a <do_yield>

ffffffffc0205f46 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205f46:	6d14                	ld	a3,24(a0)
ffffffffc0205f48:	6910                	ld	a2,16(a0)
ffffffffc0205f4a:	650c                	ld	a1,8(a0)
ffffffffc0205f4c:	6108                	ld	a0,0(a0)
ffffffffc0205f4e:	f2cff06f          	j	ffffffffc020567a <do_execve>

ffffffffc0205f52 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205f52:	650c                	ld	a1,8(a0)
ffffffffc0205f54:	4108                	lw	a0,0(a0)
ffffffffc0205f56:	c45ff06f          	j	ffffffffc0205b9a <do_wait>

ffffffffc0205f5a <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0205f5a:	000ad797          	auipc	a5,0xad
ffffffffc0205f5e:	8e67b783          	ld	a5,-1818(a5) # ffffffffc02b2840 <current>
ffffffffc0205f62:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205f64:	4501                	li	a0,0
ffffffffc0205f66:	6a0c                	ld	a1,16(a2)
ffffffffc0205f68:	e7ffe06f          	j	ffffffffc0204de6 <do_fork>

ffffffffc0205f6c <sys_exit>:
    return do_exit(error_code);
ffffffffc0205f6c:	4108                	lw	a0,0(a0)
ffffffffc0205f6e:	accff06f          	j	ffffffffc020523a <do_exit>

ffffffffc0205f72 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0205f72:	715d                	addi	sp,sp,-80
ffffffffc0205f74:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205f76:	000ad497          	auipc	s1,0xad
ffffffffc0205f7a:	8ca48493          	addi	s1,s1,-1846 # ffffffffc02b2840 <current>
ffffffffc0205f7e:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0205f80:	e0a2                	sd	s0,64(sp)
ffffffffc0205f82:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205f84:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0205f86:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205f88:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc0205f8a:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205f8e:	0327ee63          	bltu	a5,s2,ffffffffc0205fca <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0205f92:	00391713          	slli	a4,s2,0x3
ffffffffc0205f96:	00002797          	auipc	a5,0x2
ffffffffc0205f9a:	6ea78793          	addi	a5,a5,1770 # ffffffffc0208680 <syscalls>
ffffffffc0205f9e:	97ba                	add	a5,a5,a4
ffffffffc0205fa0:	639c                	ld	a5,0(a5)
ffffffffc0205fa2:	c785                	beqz	a5,ffffffffc0205fca <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0205fa4:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0205fa6:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0205fa8:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0205faa:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0205fac:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0205fae:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0205fb0:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0205fb2:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0205fb4:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0205fb6:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205fb8:	0028                	addi	a0,sp,8
ffffffffc0205fba:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205fbc:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205fbe:	e828                	sd	a0,80(s0)
}
ffffffffc0205fc0:	6406                	ld	s0,64(sp)
ffffffffc0205fc2:	74e2                	ld	s1,56(sp)
ffffffffc0205fc4:	7942                	ld	s2,48(sp)
ffffffffc0205fc6:	6161                	addi	sp,sp,80
ffffffffc0205fc8:	8082                	ret
    print_trapframe(tf);
ffffffffc0205fca:	8522                	mv	a0,s0
ffffffffc0205fcc:	847fa0ef          	jal	ra,ffffffffc0200812 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205fd0:	609c                	ld	a5,0(s1)
ffffffffc0205fd2:	86ca                	mv	a3,s2
ffffffffc0205fd4:	00002617          	auipc	a2,0x2
ffffffffc0205fd8:	66460613          	addi	a2,a2,1636 # ffffffffc0208638 <default_pmm_manager+0xaa0>
ffffffffc0205fdc:	43d8                	lw	a4,4(a5)
ffffffffc0205fde:	06200593          	li	a1,98
ffffffffc0205fe2:	0b478793          	addi	a5,a5,180
ffffffffc0205fe6:	00002517          	auipc	a0,0x2
ffffffffc0205fea:	68250513          	addi	a0,a0,1666 # ffffffffc0208668 <default_pmm_manager+0xad0>
ffffffffc0205fee:	a1afa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205ff2 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0205ff2:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0205ff6:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0205ff8:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0205ffa:	cb81                	beqz	a5,ffffffffc020600a <strlen+0x18>
        cnt ++;
ffffffffc0205ffc:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0205ffe:	00a707b3          	add	a5,a4,a0
ffffffffc0206002:	0007c783          	lbu	a5,0(a5)
ffffffffc0206006:	fbfd                	bnez	a5,ffffffffc0205ffc <strlen+0xa>
ffffffffc0206008:	8082                	ret
    }
    return cnt;
}
ffffffffc020600a:	8082                	ret

ffffffffc020600c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020600c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020600e:	e589                	bnez	a1,ffffffffc0206018 <strnlen+0xc>
ffffffffc0206010:	a811                	j	ffffffffc0206024 <strnlen+0x18>
        cnt ++;
ffffffffc0206012:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206014:	00f58863          	beq	a1,a5,ffffffffc0206024 <strnlen+0x18>
ffffffffc0206018:	00f50733          	add	a4,a0,a5
ffffffffc020601c:	00074703          	lbu	a4,0(a4)
ffffffffc0206020:	fb6d                	bnez	a4,ffffffffc0206012 <strnlen+0x6>
ffffffffc0206022:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0206024:	852e                	mv	a0,a1
ffffffffc0206026:	8082                	ret

ffffffffc0206028 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206028:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020602a:	0005c703          	lbu	a4,0(a1)
ffffffffc020602e:	0785                	addi	a5,a5,1
ffffffffc0206030:	0585                	addi	a1,a1,1
ffffffffc0206032:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206036:	fb75                	bnez	a4,ffffffffc020602a <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206038:	8082                	ret

ffffffffc020603a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020603a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020603e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206042:	cb89                	beqz	a5,ffffffffc0206054 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0206044:	0505                	addi	a0,a0,1
ffffffffc0206046:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206048:	fee789e3          	beq	a5,a4,ffffffffc020603a <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020604c:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0206050:	9d19                	subw	a0,a0,a4
ffffffffc0206052:	8082                	ret
ffffffffc0206054:	4501                	li	a0,0
ffffffffc0206056:	bfed                	j	ffffffffc0206050 <strcmp+0x16>

ffffffffc0206058 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0206058:	00054783          	lbu	a5,0(a0)
ffffffffc020605c:	c799                	beqz	a5,ffffffffc020606a <strchr+0x12>
        if (*s == c) {
ffffffffc020605e:	00f58763          	beq	a1,a5,ffffffffc020606c <strchr+0x14>
    while (*s != '\0') {
ffffffffc0206062:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0206066:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0206068:	fbfd                	bnez	a5,ffffffffc020605e <strchr+0x6>
    }
    return NULL;
ffffffffc020606a:	4501                	li	a0,0
}
ffffffffc020606c:	8082                	ret

ffffffffc020606e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020606e:	ca01                	beqz	a2,ffffffffc020607e <memset+0x10>
ffffffffc0206070:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0206072:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0206074:	0785                	addi	a5,a5,1
ffffffffc0206076:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020607a:	fec79de3          	bne	a5,a2,ffffffffc0206074 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020607e:	8082                	ret

ffffffffc0206080 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0206080:	ca19                	beqz	a2,ffffffffc0206096 <memcpy+0x16>
ffffffffc0206082:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0206084:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0206086:	0005c703          	lbu	a4,0(a1)
ffffffffc020608a:	0585                	addi	a1,a1,1
ffffffffc020608c:	0785                	addi	a5,a5,1
ffffffffc020608e:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0206092:	fec59ae3          	bne	a1,a2,ffffffffc0206086 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0206096:	8082                	ret

ffffffffc0206098 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0206098:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020609c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020609e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02060a2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02060a4:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02060a8:	f022                	sd	s0,32(sp)
ffffffffc02060aa:	ec26                	sd	s1,24(sp)
ffffffffc02060ac:	e84a                	sd	s2,16(sp)
ffffffffc02060ae:	f406                	sd	ra,40(sp)
ffffffffc02060b0:	e44e                	sd	s3,8(sp)
ffffffffc02060b2:	84aa                	mv	s1,a0
ffffffffc02060b4:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02060b6:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02060ba:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02060bc:	03067e63          	bgeu	a2,a6,ffffffffc02060f8 <printnum+0x60>
ffffffffc02060c0:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02060c2:	00805763          	blez	s0,ffffffffc02060d0 <printnum+0x38>
ffffffffc02060c6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02060c8:	85ca                	mv	a1,s2
ffffffffc02060ca:	854e                	mv	a0,s3
ffffffffc02060cc:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02060ce:	fc65                	bnez	s0,ffffffffc02060c6 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02060d0:	1a02                	slli	s4,s4,0x20
ffffffffc02060d2:	00002797          	auipc	a5,0x2
ffffffffc02060d6:	6ae78793          	addi	a5,a5,1710 # ffffffffc0208780 <syscalls+0x100>
ffffffffc02060da:	020a5a13          	srli	s4,s4,0x20
ffffffffc02060de:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02060e0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02060e2:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02060e6:	70a2                	ld	ra,40(sp)
ffffffffc02060e8:	69a2                	ld	s3,8(sp)
ffffffffc02060ea:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02060ec:	85ca                	mv	a1,s2
ffffffffc02060ee:	87a6                	mv	a5,s1
}
ffffffffc02060f0:	6942                	ld	s2,16(sp)
ffffffffc02060f2:	64e2                	ld	s1,24(sp)
ffffffffc02060f4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02060f6:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02060f8:	03065633          	divu	a2,a2,a6
ffffffffc02060fc:	8722                	mv	a4,s0
ffffffffc02060fe:	f9bff0ef          	jal	ra,ffffffffc0206098 <printnum>
ffffffffc0206102:	b7f9                	j	ffffffffc02060d0 <printnum+0x38>

ffffffffc0206104 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206104:	7119                	addi	sp,sp,-128
ffffffffc0206106:	f4a6                	sd	s1,104(sp)
ffffffffc0206108:	f0ca                	sd	s2,96(sp)
ffffffffc020610a:	ecce                	sd	s3,88(sp)
ffffffffc020610c:	e8d2                	sd	s4,80(sp)
ffffffffc020610e:	e4d6                	sd	s5,72(sp)
ffffffffc0206110:	e0da                	sd	s6,64(sp)
ffffffffc0206112:	fc5e                	sd	s7,56(sp)
ffffffffc0206114:	f06a                	sd	s10,32(sp)
ffffffffc0206116:	fc86                	sd	ra,120(sp)
ffffffffc0206118:	f8a2                	sd	s0,112(sp)
ffffffffc020611a:	f862                	sd	s8,48(sp)
ffffffffc020611c:	f466                	sd	s9,40(sp)
ffffffffc020611e:	ec6e                	sd	s11,24(sp)
ffffffffc0206120:	892a                	mv	s2,a0
ffffffffc0206122:	84ae                	mv	s1,a1
ffffffffc0206124:	8d32                	mv	s10,a2
ffffffffc0206126:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206128:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020612c:	5b7d                	li	s6,-1
ffffffffc020612e:	00002a97          	auipc	s5,0x2
ffffffffc0206132:	67ea8a93          	addi	s5,s5,1662 # ffffffffc02087ac <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206136:	00003b97          	auipc	s7,0x3
ffffffffc020613a:	892b8b93          	addi	s7,s7,-1902 # ffffffffc02089c8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020613e:	000d4503          	lbu	a0,0(s10)
ffffffffc0206142:	001d0413          	addi	s0,s10,1
ffffffffc0206146:	01350a63          	beq	a0,s3,ffffffffc020615a <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020614a:	c121                	beqz	a0,ffffffffc020618a <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020614c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020614e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0206150:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206152:	fff44503          	lbu	a0,-1(s0)
ffffffffc0206156:	ff351ae3          	bne	a0,s3,ffffffffc020614a <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020615a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020615e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0206162:	4c81                	li	s9,0
ffffffffc0206164:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0206166:	5c7d                	li	s8,-1
ffffffffc0206168:	5dfd                	li	s11,-1
ffffffffc020616a:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020616e:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206170:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0206174:	0ff5f593          	zext.b	a1,a1
ffffffffc0206178:	00140d13          	addi	s10,s0,1
ffffffffc020617c:	04b56263          	bltu	a0,a1,ffffffffc02061c0 <vprintfmt+0xbc>
ffffffffc0206180:	058a                	slli	a1,a1,0x2
ffffffffc0206182:	95d6                	add	a1,a1,s5
ffffffffc0206184:	4194                	lw	a3,0(a1)
ffffffffc0206186:	96d6                	add	a3,a3,s5
ffffffffc0206188:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020618a:	70e6                	ld	ra,120(sp)
ffffffffc020618c:	7446                	ld	s0,112(sp)
ffffffffc020618e:	74a6                	ld	s1,104(sp)
ffffffffc0206190:	7906                	ld	s2,96(sp)
ffffffffc0206192:	69e6                	ld	s3,88(sp)
ffffffffc0206194:	6a46                	ld	s4,80(sp)
ffffffffc0206196:	6aa6                	ld	s5,72(sp)
ffffffffc0206198:	6b06                	ld	s6,64(sp)
ffffffffc020619a:	7be2                	ld	s7,56(sp)
ffffffffc020619c:	7c42                	ld	s8,48(sp)
ffffffffc020619e:	7ca2                	ld	s9,40(sp)
ffffffffc02061a0:	7d02                	ld	s10,32(sp)
ffffffffc02061a2:	6de2                	ld	s11,24(sp)
ffffffffc02061a4:	6109                	addi	sp,sp,128
ffffffffc02061a6:	8082                	ret
            padc = '0';
ffffffffc02061a8:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02061aa:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02061ae:	846a                	mv	s0,s10
ffffffffc02061b0:	00140d13          	addi	s10,s0,1
ffffffffc02061b4:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02061b8:	0ff5f593          	zext.b	a1,a1
ffffffffc02061bc:	fcb572e3          	bgeu	a0,a1,ffffffffc0206180 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02061c0:	85a6                	mv	a1,s1
ffffffffc02061c2:	02500513          	li	a0,37
ffffffffc02061c6:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02061c8:	fff44783          	lbu	a5,-1(s0)
ffffffffc02061cc:	8d22                	mv	s10,s0
ffffffffc02061ce:	f73788e3          	beq	a5,s3,ffffffffc020613e <vprintfmt+0x3a>
ffffffffc02061d2:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02061d6:	1d7d                	addi	s10,s10,-1
ffffffffc02061d8:	ff379de3          	bne	a5,s3,ffffffffc02061d2 <vprintfmt+0xce>
ffffffffc02061dc:	b78d                	j	ffffffffc020613e <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02061de:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02061e2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02061e6:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02061e8:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02061ec:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02061f0:	02d86463          	bltu	a6,a3,ffffffffc0206218 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02061f4:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02061f8:	002c169b          	slliw	a3,s8,0x2
ffffffffc02061fc:	0186873b          	addw	a4,a3,s8
ffffffffc0206200:	0017171b          	slliw	a4,a4,0x1
ffffffffc0206204:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0206206:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020620a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020620c:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0206210:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206214:	fed870e3          	bgeu	a6,a3,ffffffffc02061f4 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0206218:	f40ddce3          	bgez	s11,ffffffffc0206170 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020621c:	8de2                	mv	s11,s8
ffffffffc020621e:	5c7d                	li	s8,-1
ffffffffc0206220:	bf81                	j	ffffffffc0206170 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0206222:	fffdc693          	not	a3,s11
ffffffffc0206226:	96fd                	srai	a3,a3,0x3f
ffffffffc0206228:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020622c:	00144603          	lbu	a2,1(s0)
ffffffffc0206230:	2d81                	sext.w	s11,s11
ffffffffc0206232:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206234:	bf35                	j	ffffffffc0206170 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0206236:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020623a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020623e:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206240:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0206242:	bfd9                	j	ffffffffc0206218 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0206244:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206246:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020624a:	01174463          	blt	a4,a7,ffffffffc0206252 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020624e:	1a088e63          	beqz	a7,ffffffffc020640a <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0206252:	000a3603          	ld	a2,0(s4)
ffffffffc0206256:	46c1                	li	a3,16
ffffffffc0206258:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020625a:	2781                	sext.w	a5,a5
ffffffffc020625c:	876e                	mv	a4,s11
ffffffffc020625e:	85a6                	mv	a1,s1
ffffffffc0206260:	854a                	mv	a0,s2
ffffffffc0206262:	e37ff0ef          	jal	ra,ffffffffc0206098 <printnum>
            break;
ffffffffc0206266:	bde1                	j	ffffffffc020613e <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0206268:	000a2503          	lw	a0,0(s4)
ffffffffc020626c:	85a6                	mv	a1,s1
ffffffffc020626e:	0a21                	addi	s4,s4,8
ffffffffc0206270:	9902                	jalr	s2
            break;
ffffffffc0206272:	b5f1                	j	ffffffffc020613e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206274:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206276:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020627a:	01174463          	blt	a4,a7,ffffffffc0206282 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020627e:	18088163          	beqz	a7,ffffffffc0206400 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0206282:	000a3603          	ld	a2,0(s4)
ffffffffc0206286:	46a9                	li	a3,10
ffffffffc0206288:	8a2e                	mv	s4,a1
ffffffffc020628a:	bfc1                	j	ffffffffc020625a <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020628c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0206290:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206292:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206294:	bdf1                	j	ffffffffc0206170 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0206296:	85a6                	mv	a1,s1
ffffffffc0206298:	02500513          	li	a0,37
ffffffffc020629c:	9902                	jalr	s2
            break;
ffffffffc020629e:	b545                	j	ffffffffc020613e <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062a0:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02062a4:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062a6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02062a8:	b5e1                	j	ffffffffc0206170 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02062aa:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02062ac:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02062b0:	01174463          	blt	a4,a7,ffffffffc02062b8 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02062b4:	14088163          	beqz	a7,ffffffffc02063f6 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02062b8:	000a3603          	ld	a2,0(s4)
ffffffffc02062bc:	46a1                	li	a3,8
ffffffffc02062be:	8a2e                	mv	s4,a1
ffffffffc02062c0:	bf69                	j	ffffffffc020625a <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02062c2:	03000513          	li	a0,48
ffffffffc02062c6:	85a6                	mv	a1,s1
ffffffffc02062c8:	e03e                	sd	a5,0(sp)
ffffffffc02062ca:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02062cc:	85a6                	mv	a1,s1
ffffffffc02062ce:	07800513          	li	a0,120
ffffffffc02062d2:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02062d4:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02062d6:	6782                	ld	a5,0(sp)
ffffffffc02062d8:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02062da:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02062de:	bfb5                	j	ffffffffc020625a <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02062e0:	000a3403          	ld	s0,0(s4)
ffffffffc02062e4:	008a0713          	addi	a4,s4,8
ffffffffc02062e8:	e03a                	sd	a4,0(sp)
ffffffffc02062ea:	14040263          	beqz	s0,ffffffffc020642e <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02062ee:	0fb05763          	blez	s11,ffffffffc02063dc <vprintfmt+0x2d8>
ffffffffc02062f2:	02d00693          	li	a3,45
ffffffffc02062f6:	0cd79163          	bne	a5,a3,ffffffffc02063b8 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02062fa:	00044783          	lbu	a5,0(s0)
ffffffffc02062fe:	0007851b          	sext.w	a0,a5
ffffffffc0206302:	cf85                	beqz	a5,ffffffffc020633a <vprintfmt+0x236>
ffffffffc0206304:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206308:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020630c:	000c4563          	bltz	s8,ffffffffc0206316 <vprintfmt+0x212>
ffffffffc0206310:	3c7d                	addiw	s8,s8,-1
ffffffffc0206312:	036c0263          	beq	s8,s6,ffffffffc0206336 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0206316:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206318:	0e0c8e63          	beqz	s9,ffffffffc0206414 <vprintfmt+0x310>
ffffffffc020631c:	3781                	addiw	a5,a5,-32
ffffffffc020631e:	0ef47b63          	bgeu	s0,a5,ffffffffc0206414 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0206322:	03f00513          	li	a0,63
ffffffffc0206326:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206328:	000a4783          	lbu	a5,0(s4)
ffffffffc020632c:	3dfd                	addiw	s11,s11,-1
ffffffffc020632e:	0a05                	addi	s4,s4,1
ffffffffc0206330:	0007851b          	sext.w	a0,a5
ffffffffc0206334:	ffe1                	bnez	a5,ffffffffc020630c <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0206336:	01b05963          	blez	s11,ffffffffc0206348 <vprintfmt+0x244>
ffffffffc020633a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020633c:	85a6                	mv	a1,s1
ffffffffc020633e:	02000513          	li	a0,32
ffffffffc0206342:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206344:	fe0d9be3          	bnez	s11,ffffffffc020633a <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206348:	6a02                	ld	s4,0(sp)
ffffffffc020634a:	bbd5                	j	ffffffffc020613e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020634c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020634e:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0206352:	01174463          	blt	a4,a7,ffffffffc020635a <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0206356:	08088d63          	beqz	a7,ffffffffc02063f0 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020635a:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020635e:	0a044d63          	bltz	s0,ffffffffc0206418 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0206362:	8622                	mv	a2,s0
ffffffffc0206364:	8a66                	mv	s4,s9
ffffffffc0206366:	46a9                	li	a3,10
ffffffffc0206368:	bdcd                	j	ffffffffc020625a <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020636a:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020636e:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0206370:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0206372:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0206376:	8fb5                	xor	a5,a5,a3
ffffffffc0206378:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020637c:	02d74163          	blt	a4,a3,ffffffffc020639e <vprintfmt+0x29a>
ffffffffc0206380:	00369793          	slli	a5,a3,0x3
ffffffffc0206384:	97de                	add	a5,a5,s7
ffffffffc0206386:	639c                	ld	a5,0(a5)
ffffffffc0206388:	cb99                	beqz	a5,ffffffffc020639e <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020638a:	86be                	mv	a3,a5
ffffffffc020638c:	00000617          	auipc	a2,0x0
ffffffffc0206390:	13c60613          	addi	a2,a2,316 # ffffffffc02064c8 <etext+0x2c>
ffffffffc0206394:	85a6                	mv	a1,s1
ffffffffc0206396:	854a                	mv	a0,s2
ffffffffc0206398:	0ce000ef          	jal	ra,ffffffffc0206466 <printfmt>
ffffffffc020639c:	b34d                	j	ffffffffc020613e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020639e:	00002617          	auipc	a2,0x2
ffffffffc02063a2:	40260613          	addi	a2,a2,1026 # ffffffffc02087a0 <syscalls+0x120>
ffffffffc02063a6:	85a6                	mv	a1,s1
ffffffffc02063a8:	854a                	mv	a0,s2
ffffffffc02063aa:	0bc000ef          	jal	ra,ffffffffc0206466 <printfmt>
ffffffffc02063ae:	bb41                	j	ffffffffc020613e <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02063b0:	00002417          	auipc	s0,0x2
ffffffffc02063b4:	3e840413          	addi	s0,s0,1000 # ffffffffc0208798 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02063b8:	85e2                	mv	a1,s8
ffffffffc02063ba:	8522                	mv	a0,s0
ffffffffc02063bc:	e43e                	sd	a5,8(sp)
ffffffffc02063be:	c4fff0ef          	jal	ra,ffffffffc020600c <strnlen>
ffffffffc02063c2:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02063c6:	01b05b63          	blez	s11,ffffffffc02063dc <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02063ca:	67a2                	ld	a5,8(sp)
ffffffffc02063cc:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02063d0:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02063d2:	85a6                	mv	a1,s1
ffffffffc02063d4:	8552                	mv	a0,s4
ffffffffc02063d6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02063d8:	fe0d9ce3          	bnez	s11,ffffffffc02063d0 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02063dc:	00044783          	lbu	a5,0(s0)
ffffffffc02063e0:	00140a13          	addi	s4,s0,1
ffffffffc02063e4:	0007851b          	sext.w	a0,a5
ffffffffc02063e8:	d3a5                	beqz	a5,ffffffffc0206348 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02063ea:	05e00413          	li	s0,94
ffffffffc02063ee:	bf39                	j	ffffffffc020630c <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02063f0:	000a2403          	lw	s0,0(s4)
ffffffffc02063f4:	b7ad                	j	ffffffffc020635e <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02063f6:	000a6603          	lwu	a2,0(s4)
ffffffffc02063fa:	46a1                	li	a3,8
ffffffffc02063fc:	8a2e                	mv	s4,a1
ffffffffc02063fe:	bdb1                	j	ffffffffc020625a <vprintfmt+0x156>
ffffffffc0206400:	000a6603          	lwu	a2,0(s4)
ffffffffc0206404:	46a9                	li	a3,10
ffffffffc0206406:	8a2e                	mv	s4,a1
ffffffffc0206408:	bd89                	j	ffffffffc020625a <vprintfmt+0x156>
ffffffffc020640a:	000a6603          	lwu	a2,0(s4)
ffffffffc020640e:	46c1                	li	a3,16
ffffffffc0206410:	8a2e                	mv	s4,a1
ffffffffc0206412:	b5a1                	j	ffffffffc020625a <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0206414:	9902                	jalr	s2
ffffffffc0206416:	bf09                	j	ffffffffc0206328 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0206418:	85a6                	mv	a1,s1
ffffffffc020641a:	02d00513          	li	a0,45
ffffffffc020641e:	e03e                	sd	a5,0(sp)
ffffffffc0206420:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0206422:	6782                	ld	a5,0(sp)
ffffffffc0206424:	8a66                	mv	s4,s9
ffffffffc0206426:	40800633          	neg	a2,s0
ffffffffc020642a:	46a9                	li	a3,10
ffffffffc020642c:	b53d                	j	ffffffffc020625a <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020642e:	03b05163          	blez	s11,ffffffffc0206450 <vprintfmt+0x34c>
ffffffffc0206432:	02d00693          	li	a3,45
ffffffffc0206436:	f6d79de3          	bne	a5,a3,ffffffffc02063b0 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020643a:	00002417          	auipc	s0,0x2
ffffffffc020643e:	35e40413          	addi	s0,s0,862 # ffffffffc0208798 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206442:	02800793          	li	a5,40
ffffffffc0206446:	02800513          	li	a0,40
ffffffffc020644a:	00140a13          	addi	s4,s0,1
ffffffffc020644e:	bd6d                	j	ffffffffc0206308 <vprintfmt+0x204>
ffffffffc0206450:	00002a17          	auipc	s4,0x2
ffffffffc0206454:	349a0a13          	addi	s4,s4,841 # ffffffffc0208799 <syscalls+0x119>
ffffffffc0206458:	02800513          	li	a0,40
ffffffffc020645c:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206460:	05e00413          	li	s0,94
ffffffffc0206464:	b565                	j	ffffffffc020630c <vprintfmt+0x208>

ffffffffc0206466 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206466:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0206468:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020646c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020646e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206470:	ec06                	sd	ra,24(sp)
ffffffffc0206472:	f83a                	sd	a4,48(sp)
ffffffffc0206474:	fc3e                	sd	a5,56(sp)
ffffffffc0206476:	e0c2                	sd	a6,64(sp)
ffffffffc0206478:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020647a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020647c:	c89ff0ef          	jal	ra,ffffffffc0206104 <vprintfmt>
}
ffffffffc0206480:	60e2                	ld	ra,24(sp)
ffffffffc0206482:	6161                	addi	sp,sp,80
ffffffffc0206484:	8082                	ret

ffffffffc0206486 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0206486:	9e3707b7          	lui	a5,0x9e370
ffffffffc020648a:	2785                	addiw	a5,a5,1
ffffffffc020648c:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0206490:	02000793          	li	a5,32
ffffffffc0206494:	9f8d                	subw	a5,a5,a1
}
ffffffffc0206496:	00f5553b          	srlw	a0,a0,a5
ffffffffc020649a:	8082                	ret
