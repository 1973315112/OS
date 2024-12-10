
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
ffffffffc020004a:	150060ef          	jal	ra,ffffffffc020619a <memset>
    cons_init();                // init the console
ffffffffc020004e:	580000ef          	jal	ra,ffffffffc02005ce <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	57658593          	addi	a1,a1,1398 # ffffffffc02065c8 <etext>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	58e50513          	addi	a0,a0,1422 # ffffffffc02065e8 <etext+0x20>
ffffffffc0200062:	06a000ef          	jal	ra,ffffffffc02000cc <cprintf>

    print_kerninfo();
ffffffffc0200066:	24e000ef          	jal	ra,ffffffffc02002b4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	479030ef          	jal	ra,ffffffffc0203ce2 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5d2000ef          	jal	ra,ffffffffc0200640 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5dc000ef          	jal	ra,ffffffffc020064e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	168010ef          	jal	ra,ffffffffc02011de <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	507050ef          	jal	ra,ffffffffc0205d80 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	4a8000ef          	jal	ra,ffffffffc0200526 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	7f3010ef          	jal	ra,ffffffffc0202074 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	4f6000ef          	jal	ra,ffffffffc020057c <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	5b8000ef          	jal	ra,ffffffffc0200642 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	68b050ef          	jal	ra,ffffffffc0205f18 <cpu_idle>

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
ffffffffc020009a:	536000ef          	jal	ra,ffffffffc02005d0 <cons_putc>
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
ffffffffc02000c0:	170060ef          	jal	ra,ffffffffc0206230 <vprintfmt>
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
ffffffffc02000f6:	13a060ef          	jal	ra,ffffffffc0206230 <vprintfmt>
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
ffffffffc0200102:	a1f9                	j	ffffffffc02005d0 <cons_putc>

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
ffffffffc020011a:	4b6000ef          	jal	ra,ffffffffc02005d0 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020011e:	00044503          	lbu	a0,0(s0)
ffffffffc0200122:	008487bb          	addw	a5,s1,s0
ffffffffc0200126:	0405                	addi	s0,s0,1
ffffffffc0200128:	f96d                	bnez	a0,ffffffffc020011a <cputs+0x16>
    (*cnt) ++;
ffffffffc020012a:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc020012e:	4529                	li	a0,10
ffffffffc0200130:	4a0000ef          	jal	ra,ffffffffc02005d0 <cons_putc>
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
ffffffffc0200148:	4bc000ef          	jal	ra,ffffffffc0200604 <cons_getc>
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
ffffffffc020016e:	48650513          	addi	a0,a0,1158 # ffffffffc02065f0 <etext+0x28>
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
ffffffffc020023a:	3c250513          	addi	a0,a0,962 # ffffffffc02065f8 <etext+0x30>
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
ffffffffc0200250:	edc50513          	addi	a0,a0,-292 # ffffffffc0208128 <default_pmm_manager+0x400>
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
ffffffffc0200264:	3e4000ef          	jal	ra,ffffffffc0200648 <intr_disable>
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
ffffffffc0200284:	39850513          	addi	a0,a0,920 # ffffffffc0206618 <etext+0x50>
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
ffffffffc02002a4:	e8850513          	addi	a0,a0,-376 # ffffffffc0208128 <default_pmm_manager+0x400>
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
ffffffffc02002ba:	38250513          	addi	a0,a0,898 # ffffffffc0206638 <etext+0x70>
void print_kerninfo(void) {
ffffffffc02002be:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002c0:	e0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002c4:	00000597          	auipc	a1,0x0
ffffffffc02002c8:	d6e58593          	addi	a1,a1,-658 # ffffffffc0200032 <kern_init>
ffffffffc02002cc:	00006517          	auipc	a0,0x6
ffffffffc02002d0:	38c50513          	addi	a0,a0,908 # ffffffffc0206658 <etext+0x90>
ffffffffc02002d4:	df9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002d8:	00006597          	auipc	a1,0x6
ffffffffc02002dc:	2f058593          	addi	a1,a1,752 # ffffffffc02065c8 <etext>
ffffffffc02002e0:	00006517          	auipc	a0,0x6
ffffffffc02002e4:	39850513          	addi	a0,a0,920 # ffffffffc0206678 <etext+0xb0>
ffffffffc02002e8:	de5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002ec:	000a7597          	auipc	a1,0xa7
ffffffffc02002f0:	01458593          	addi	a1,a1,20 # ffffffffc02a7300 <buf>
ffffffffc02002f4:	00006517          	auipc	a0,0x6
ffffffffc02002f8:	3a450513          	addi	a0,a0,932 # ffffffffc0206698 <etext+0xd0>
ffffffffc02002fc:	dd1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200300:	000b2597          	auipc	a1,0xb2
ffffffffc0200304:	55c58593          	addi	a1,a1,1372 # ffffffffc02b285c <end>
ffffffffc0200308:	00006517          	auipc	a0,0x6
ffffffffc020030c:	3b050513          	addi	a0,a0,944 # ffffffffc02066b8 <etext+0xf0>
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
ffffffffc020033a:	3a250513          	addi	a0,a0,930 # ffffffffc02066d8 <etext+0x110>
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
ffffffffc0200348:	3c460613          	addi	a2,a2,964 # ffffffffc0206708 <etext+0x140>
ffffffffc020034c:	04d00593          	li	a1,77
ffffffffc0200350:	00006517          	auipc	a0,0x6
ffffffffc0200354:	3d050513          	addi	a0,a0,976 # ffffffffc0206720 <etext+0x158>
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
ffffffffc0200364:	3d860613          	addi	a2,a2,984 # ffffffffc0206738 <etext+0x170>
ffffffffc0200368:	00006597          	auipc	a1,0x6
ffffffffc020036c:	3f058593          	addi	a1,a1,1008 # ffffffffc0206758 <etext+0x190>
ffffffffc0200370:	00006517          	auipc	a0,0x6
ffffffffc0200374:	3f050513          	addi	a0,a0,1008 # ffffffffc0206760 <etext+0x198>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200378:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020037a:	d53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020037e:	00006617          	auipc	a2,0x6
ffffffffc0200382:	3f260613          	addi	a2,a2,1010 # ffffffffc0206770 <etext+0x1a8>
ffffffffc0200386:	00006597          	auipc	a1,0x6
ffffffffc020038a:	41258593          	addi	a1,a1,1042 # ffffffffc0206798 <etext+0x1d0>
ffffffffc020038e:	00006517          	auipc	a0,0x6
ffffffffc0200392:	3d250513          	addi	a0,a0,978 # ffffffffc0206760 <etext+0x198>
ffffffffc0200396:	d37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020039a:	00006617          	auipc	a2,0x6
ffffffffc020039e:	40e60613          	addi	a2,a2,1038 # ffffffffc02067a8 <etext+0x1e0>
ffffffffc02003a2:	00006597          	auipc	a1,0x6
ffffffffc02003a6:	42658593          	addi	a1,a1,1062 # ffffffffc02067c8 <etext+0x200>
ffffffffc02003aa:	00006517          	auipc	a0,0x6
ffffffffc02003ae:	3b650513          	addi	a0,a0,950 # ffffffffc0206760 <etext+0x198>
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
ffffffffc02003e8:	3f450513          	addi	a0,a0,1012 # ffffffffc02067d8 <etext+0x210>
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
ffffffffc020040a:	3fa50513          	addi	a0,a0,1018 # ffffffffc0206800 <etext+0x238>
ffffffffc020040e:	cbfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    if (tf != NULL) {
ffffffffc0200412:	000b8563          	beqz	s7,ffffffffc020041c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200416:	855e                	mv	a0,s7
ffffffffc0200418:	41e000ef          	jal	ra,ffffffffc0200836 <print_trapframe>
ffffffffc020041c:	00006c17          	auipc	s8,0x6
ffffffffc0200420:	454c0c13          	addi	s8,s8,1108 # ffffffffc0206870 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200424:	00006917          	auipc	s2,0x6
ffffffffc0200428:	40490913          	addi	s2,s2,1028 # ffffffffc0206828 <etext+0x260>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020042c:	00006497          	auipc	s1,0x6
ffffffffc0200430:	40448493          	addi	s1,s1,1028 # ffffffffc0206830 <etext+0x268>
        if (argc == MAXARGS - 1) {
ffffffffc0200434:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200436:	00006b17          	auipc	s6,0x6
ffffffffc020043a:	402b0b13          	addi	s6,s6,1026 # ffffffffc0206838 <etext+0x270>
        argv[argc ++] = buf;
ffffffffc020043e:	00006a17          	auipc	s4,0x6
ffffffffc0200442:	31aa0a13          	addi	s4,s4,794 # ffffffffc0206758 <etext+0x190>
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
ffffffffc0200464:	410d0d13          	addi	s10,s10,1040 # ffffffffc0206870 <commands>
        argv[argc ++] = buf;
ffffffffc0200468:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020046a:	4401                	li	s0,0
ffffffffc020046c:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020046e:	4f9050ef          	jal	ra,ffffffffc0206166 <strcmp>
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
ffffffffc0200482:	4e5050ef          	jal	ra,ffffffffc0206166 <strcmp>
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
ffffffffc02004c0:	4c5050ef          	jal	ra,ffffffffc0206184 <strchr>
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
ffffffffc02004fe:	487050ef          	jal	ra,ffffffffc0206184 <strchr>
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
ffffffffc020051c:	34050513          	addi	a0,a0,832 # ffffffffc0206858 <etext+0x290>
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

ffffffffc0200534 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200534:	000a7797          	auipc	a5,0xa7
ffffffffc0200538:	1cc78793          	addi	a5,a5,460 # ffffffffc02a7700 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc020053c:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200540:	1141                	addi	sp,sp,-16
ffffffffc0200542:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200544:	95be                	add	a1,a1,a5
ffffffffc0200546:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020054a:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020054c:	461050ef          	jal	ra,ffffffffc02061ac <memcpy>
    return 0;
}
ffffffffc0200550:	60a2                	ld	ra,8(sp)
ffffffffc0200552:	4501                	li	a0,0
ffffffffc0200554:	0141                	addi	sp,sp,16
ffffffffc0200556:	8082                	ret

ffffffffc0200558 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200558:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020055c:	000a7517          	auipc	a0,0xa7
ffffffffc0200560:	1a450513          	addi	a0,a0,420 # ffffffffc02a7700 <ide>
                   size_t nsecs) {
ffffffffc0200564:	1141                	addi	sp,sp,-16
ffffffffc0200566:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200568:	953e                	add	a0,a0,a5
ffffffffc020056a:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc020056e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200570:	43d050ef          	jal	ra,ffffffffc02061ac <memcpy>
    return 0;
}
ffffffffc0200574:	60a2                	ld	ra,8(sp)
ffffffffc0200576:	4501                	li	a0,0
ffffffffc0200578:	0141                	addi	sp,sp,16
ffffffffc020057a:	8082                	ret

ffffffffc020057c <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020057c:	67e1                	lui	a5,0x18
ffffffffc020057e:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd580>
ffffffffc0200582:	000b2717          	auipc	a4,0xb2
ffffffffc0200586:	24f73b23          	sd	a5,598(a4) # ffffffffc02b27d8 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020058a:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020058e:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200590:	953e                	add	a0,a0,a5
ffffffffc0200592:	4601                	li	a2,0
ffffffffc0200594:	4881                	li	a7,0
ffffffffc0200596:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020059a:	02000793          	li	a5,32
ffffffffc020059e:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02005a2:	00006517          	auipc	a0,0x6
ffffffffc02005a6:	31650513          	addi	a0,a0,790 # ffffffffc02068b8 <commands+0x48>
    ticks = 0;
ffffffffc02005aa:	000b2797          	auipc	a5,0xb2
ffffffffc02005ae:	2207b323          	sd	zero,550(a5) # ffffffffc02b27d0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02005b2:	be29                	j	ffffffffc02000cc <cprintf>

ffffffffc02005b4 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02005b4:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02005b8:	000b2797          	auipc	a5,0xb2
ffffffffc02005bc:	2207b783          	ld	a5,544(a5) # ffffffffc02b27d8 <timebase>
ffffffffc02005c0:	953e                	add	a0,a0,a5
ffffffffc02005c2:	4581                	li	a1,0
ffffffffc02005c4:	4601                	li	a2,0
ffffffffc02005c6:	4881                	li	a7,0
ffffffffc02005c8:	00000073          	ecall
ffffffffc02005cc:	8082                	ret

ffffffffc02005ce <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005d0:	100027f3          	csrr	a5,sstatus
ffffffffc02005d4:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005d6:	0ff57513          	zext.b	a0,a0
ffffffffc02005da:	e799                	bnez	a5,ffffffffc02005e8 <cons_putc+0x18>
ffffffffc02005dc:	4581                	li	a1,0
ffffffffc02005de:	4601                	li	a2,0
ffffffffc02005e0:	4885                	li	a7,1
ffffffffc02005e2:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005e6:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005e8:	1101                	addi	sp,sp,-32
ffffffffc02005ea:	ec06                	sd	ra,24(sp)
ffffffffc02005ec:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005ee:	05a000ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02005f2:	6522                	ld	a0,8(sp)
ffffffffc02005f4:	4581                	li	a1,0
ffffffffc02005f6:	4601                	li	a2,0
ffffffffc02005f8:	4885                	li	a7,1
ffffffffc02005fa:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005fe:	60e2                	ld	ra,24(sp)
ffffffffc0200600:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200602:	a081                	j	ffffffffc0200642 <intr_enable>

ffffffffc0200604 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200604:	100027f3          	csrr	a5,sstatus
ffffffffc0200608:	8b89                	andi	a5,a5,2
ffffffffc020060a:	eb89                	bnez	a5,ffffffffc020061c <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020060c:	4501                	li	a0,0
ffffffffc020060e:	4581                	li	a1,0
ffffffffc0200610:	4601                	li	a2,0
ffffffffc0200612:	4889                	li	a7,2
ffffffffc0200614:	00000073          	ecall
ffffffffc0200618:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020061a:	8082                	ret
int cons_getc(void) {
ffffffffc020061c:	1101                	addi	sp,sp,-32
ffffffffc020061e:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200620:	028000ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0200624:	4501                	li	a0,0
ffffffffc0200626:	4581                	li	a1,0
ffffffffc0200628:	4601                	li	a2,0
ffffffffc020062a:	4889                	li	a7,2
ffffffffc020062c:	00000073          	ecall
ffffffffc0200630:	2501                	sext.w	a0,a0
ffffffffc0200632:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200634:	00e000ef          	jal	ra,ffffffffc0200642 <intr_enable>
}
ffffffffc0200638:	60e2                	ld	ra,24(sp)
ffffffffc020063a:	6522                	ld	a0,8(sp)
ffffffffc020063c:	6105                	addi	sp,sp,32
ffffffffc020063e:	8082                	ret

ffffffffc0200640 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200640:	8082                	ret

ffffffffc0200642 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200642:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200646:	8082                	ret

ffffffffc0200648 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200648:	100177f3          	csrrci	a5,sstatus,2
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
ffffffffc0200674:	26850513          	addi	a0,a0,616 # ffffffffc02068d8 <commands+0x68>
void print_regs(struct pushregs* gpr) {
ffffffffc0200678:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067a:	a53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020067e:	640c                	ld	a1,8(s0)
ffffffffc0200680:	00006517          	auipc	a0,0x6
ffffffffc0200684:	27050513          	addi	a0,a0,624 # ffffffffc02068f0 <commands+0x80>
ffffffffc0200688:	a45ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020068c:	680c                	ld	a1,16(s0)
ffffffffc020068e:	00006517          	auipc	a0,0x6
ffffffffc0200692:	27a50513          	addi	a0,a0,634 # ffffffffc0206908 <commands+0x98>
ffffffffc0200696:	a37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069a:	6c0c                	ld	a1,24(s0)
ffffffffc020069c:	00006517          	auipc	a0,0x6
ffffffffc02006a0:	28450513          	addi	a0,a0,644 # ffffffffc0206920 <commands+0xb0>
ffffffffc02006a4:	a29ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a8:	700c                	ld	a1,32(s0)
ffffffffc02006aa:	00006517          	auipc	a0,0x6
ffffffffc02006ae:	28e50513          	addi	a0,a0,654 # ffffffffc0206938 <commands+0xc8>
ffffffffc02006b2:	a1bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b6:	740c                	ld	a1,40(s0)
ffffffffc02006b8:	00006517          	auipc	a0,0x6
ffffffffc02006bc:	29850513          	addi	a0,a0,664 # ffffffffc0206950 <commands+0xe0>
ffffffffc02006c0:	a0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c4:	780c                	ld	a1,48(s0)
ffffffffc02006c6:	00006517          	auipc	a0,0x6
ffffffffc02006ca:	2a250513          	addi	a0,a0,674 # ffffffffc0206968 <commands+0xf8>
ffffffffc02006ce:	9ffff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d2:	7c0c                	ld	a1,56(s0)
ffffffffc02006d4:	00006517          	auipc	a0,0x6
ffffffffc02006d8:	2ac50513          	addi	a0,a0,684 # ffffffffc0206980 <commands+0x110>
ffffffffc02006dc:	9f1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e0:	602c                	ld	a1,64(s0)
ffffffffc02006e2:	00006517          	auipc	a0,0x6
ffffffffc02006e6:	2b650513          	addi	a0,a0,694 # ffffffffc0206998 <commands+0x128>
ffffffffc02006ea:	9e3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ee:	642c                	ld	a1,72(s0)
ffffffffc02006f0:	00006517          	auipc	a0,0x6
ffffffffc02006f4:	2c050513          	addi	a0,a0,704 # ffffffffc02069b0 <commands+0x140>
ffffffffc02006f8:	9d5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006fc:	682c                	ld	a1,80(s0)
ffffffffc02006fe:	00006517          	auipc	a0,0x6
ffffffffc0200702:	2ca50513          	addi	a0,a0,714 # ffffffffc02069c8 <commands+0x158>
ffffffffc0200706:	9c7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070a:	6c2c                	ld	a1,88(s0)
ffffffffc020070c:	00006517          	auipc	a0,0x6
ffffffffc0200710:	2d450513          	addi	a0,a0,724 # ffffffffc02069e0 <commands+0x170>
ffffffffc0200714:	9b9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200718:	702c                	ld	a1,96(s0)
ffffffffc020071a:	00006517          	auipc	a0,0x6
ffffffffc020071e:	2de50513          	addi	a0,a0,734 # ffffffffc02069f8 <commands+0x188>
ffffffffc0200722:	9abff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200726:	742c                	ld	a1,104(s0)
ffffffffc0200728:	00006517          	auipc	a0,0x6
ffffffffc020072c:	2e850513          	addi	a0,a0,744 # ffffffffc0206a10 <commands+0x1a0>
ffffffffc0200730:	99dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200734:	782c                	ld	a1,112(s0)
ffffffffc0200736:	00006517          	auipc	a0,0x6
ffffffffc020073a:	2f250513          	addi	a0,a0,754 # ffffffffc0206a28 <commands+0x1b8>
ffffffffc020073e:	98fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200742:	7c2c                	ld	a1,120(s0)
ffffffffc0200744:	00006517          	auipc	a0,0x6
ffffffffc0200748:	2fc50513          	addi	a0,a0,764 # ffffffffc0206a40 <commands+0x1d0>
ffffffffc020074c:	981ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200750:	604c                	ld	a1,128(s0)
ffffffffc0200752:	00006517          	auipc	a0,0x6
ffffffffc0200756:	30650513          	addi	a0,a0,774 # ffffffffc0206a58 <commands+0x1e8>
ffffffffc020075a:	973ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020075e:	644c                	ld	a1,136(s0)
ffffffffc0200760:	00006517          	auipc	a0,0x6
ffffffffc0200764:	31050513          	addi	a0,a0,784 # ffffffffc0206a70 <commands+0x200>
ffffffffc0200768:	965ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020076c:	684c                	ld	a1,144(s0)
ffffffffc020076e:	00006517          	auipc	a0,0x6
ffffffffc0200772:	31a50513          	addi	a0,a0,794 # ffffffffc0206a88 <commands+0x218>
ffffffffc0200776:	957ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077a:	6c4c                	ld	a1,152(s0)
ffffffffc020077c:	00006517          	auipc	a0,0x6
ffffffffc0200780:	32450513          	addi	a0,a0,804 # ffffffffc0206aa0 <commands+0x230>
ffffffffc0200784:	949ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200788:	704c                	ld	a1,160(s0)
ffffffffc020078a:	00006517          	auipc	a0,0x6
ffffffffc020078e:	32e50513          	addi	a0,a0,814 # ffffffffc0206ab8 <commands+0x248>
ffffffffc0200792:	93bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200796:	744c                	ld	a1,168(s0)
ffffffffc0200798:	00006517          	auipc	a0,0x6
ffffffffc020079c:	33850513          	addi	a0,a0,824 # ffffffffc0206ad0 <commands+0x260>
ffffffffc02007a0:	92dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a4:	784c                	ld	a1,176(s0)
ffffffffc02007a6:	00006517          	auipc	a0,0x6
ffffffffc02007aa:	34250513          	addi	a0,a0,834 # ffffffffc0206ae8 <commands+0x278>
ffffffffc02007ae:	91fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b2:	7c4c                	ld	a1,184(s0)
ffffffffc02007b4:	00006517          	auipc	a0,0x6
ffffffffc02007b8:	34c50513          	addi	a0,a0,844 # ffffffffc0206b00 <commands+0x290>
ffffffffc02007bc:	911ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c0:	606c                	ld	a1,192(s0)
ffffffffc02007c2:	00006517          	auipc	a0,0x6
ffffffffc02007c6:	35650513          	addi	a0,a0,854 # ffffffffc0206b18 <commands+0x2a8>
ffffffffc02007ca:	903ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ce:	646c                	ld	a1,200(s0)
ffffffffc02007d0:	00006517          	auipc	a0,0x6
ffffffffc02007d4:	36050513          	addi	a0,a0,864 # ffffffffc0206b30 <commands+0x2c0>
ffffffffc02007d8:	8f5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007dc:	686c                	ld	a1,208(s0)
ffffffffc02007de:	00006517          	auipc	a0,0x6
ffffffffc02007e2:	36a50513          	addi	a0,a0,874 # ffffffffc0206b48 <commands+0x2d8>
ffffffffc02007e6:	8e7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ea:	6c6c                	ld	a1,216(s0)
ffffffffc02007ec:	00006517          	auipc	a0,0x6
ffffffffc02007f0:	37450513          	addi	a0,a0,884 # ffffffffc0206b60 <commands+0x2f0>
ffffffffc02007f4:	8d9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f8:	706c                	ld	a1,224(s0)
ffffffffc02007fa:	00006517          	auipc	a0,0x6
ffffffffc02007fe:	37e50513          	addi	a0,a0,894 # ffffffffc0206b78 <commands+0x308>
ffffffffc0200802:	8cbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200806:	746c                	ld	a1,232(s0)
ffffffffc0200808:	00006517          	auipc	a0,0x6
ffffffffc020080c:	38850513          	addi	a0,a0,904 # ffffffffc0206b90 <commands+0x320>
ffffffffc0200810:	8bdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200814:	786c                	ld	a1,240(s0)
ffffffffc0200816:	00006517          	auipc	a0,0x6
ffffffffc020081a:	39250513          	addi	a0,a0,914 # ffffffffc0206ba8 <commands+0x338>
ffffffffc020081e:	8afff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200824:	6402                	ld	s0,0(sp)
ffffffffc0200826:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200828:	00006517          	auipc	a0,0x6
ffffffffc020082c:	39850513          	addi	a0,a0,920 # ffffffffc0206bc0 <commands+0x350>
}
ffffffffc0200830:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200832:	89bff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200836 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200836:	1141                	addi	sp,sp,-16
ffffffffc0200838:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020083a:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc020083c:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020083e:	00006517          	auipc	a0,0x6
ffffffffc0200842:	39a50513          	addi	a0,a0,922 # ffffffffc0206bd8 <commands+0x368>
print_trapframe(struct trapframe *tf) {
ffffffffc0200846:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200848:	885ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    print_regs(&tf->gpr);
ffffffffc020084c:	8522                	mv	a0,s0
ffffffffc020084e:	e1bff0ef          	jal	ra,ffffffffc0200668 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200852:	10043583          	ld	a1,256(s0)
ffffffffc0200856:	00006517          	auipc	a0,0x6
ffffffffc020085a:	39a50513          	addi	a0,a0,922 # ffffffffc0206bf0 <commands+0x380>
ffffffffc020085e:	86fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200862:	10843583          	ld	a1,264(s0)
ffffffffc0200866:	00006517          	auipc	a0,0x6
ffffffffc020086a:	3a250513          	addi	a0,a0,930 # ffffffffc0206c08 <commands+0x398>
ffffffffc020086e:	85fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200872:	11043583          	ld	a1,272(s0)
ffffffffc0200876:	00006517          	auipc	a0,0x6
ffffffffc020087a:	3aa50513          	addi	a0,a0,938 # ffffffffc0206c20 <commands+0x3b0>
ffffffffc020087e:	84fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200882:	11843583          	ld	a1,280(s0)
}
ffffffffc0200886:	6402                	ld	s0,0(sp)
ffffffffc0200888:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088a:	00006517          	auipc	a0,0x6
ffffffffc020088e:	3a650513          	addi	a0,a0,934 # ffffffffc0206c30 <commands+0x3c0>
}
ffffffffc0200892:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200894:	839ff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200898 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200898:	1101                	addi	sp,sp,-32
ffffffffc020089a:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc020089c:	000b2497          	auipc	s1,0xb2
ffffffffc02008a0:	f4448493          	addi	s1,s1,-188 # ffffffffc02b27e0 <check_mm_struct>
ffffffffc02008a4:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a6:	e822                	sd	s0,16(sp)
ffffffffc02008a8:	ec06                	sd	ra,24(sp)
ffffffffc02008aa:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008ac:	cbad                	beqz	a5,ffffffffc020091e <pgfault_handler+0x86>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ae:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008b2:	11053583          	ld	a1,272(a0)
ffffffffc02008b6:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ba:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008be:	c7b1                	beqz	a5,ffffffffc020090a <pgfault_handler+0x72>
ffffffffc02008c0:	11843703          	ld	a4,280(s0)
ffffffffc02008c4:	47bd                	li	a5,15
ffffffffc02008c6:	05700693          	li	a3,87
ffffffffc02008ca:	00f70463          	beq	a4,a5,ffffffffc02008d2 <pgfault_handler+0x3a>
ffffffffc02008ce:	05200693          	li	a3,82
ffffffffc02008d2:	00006517          	auipc	a0,0x6
ffffffffc02008d6:	37650513          	addi	a0,a0,886 # ffffffffc0206c48 <commands+0x3d8>
ffffffffc02008da:	ff2ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008de:	6088                	ld	a0,0(s1)
ffffffffc02008e0:	cd1d                	beqz	a0,ffffffffc020091e <pgfault_handler+0x86>
        assert(current == idleproc);
ffffffffc02008e2:	000b2717          	auipc	a4,0xb2
ffffffffc02008e6:	f5e73703          	ld	a4,-162(a4) # ffffffffc02b2840 <current>
ffffffffc02008ea:	000b2797          	auipc	a5,0xb2
ffffffffc02008ee:	f5e7b783          	ld	a5,-162(a5) # ffffffffc02b2848 <idleproc>
ffffffffc02008f2:	04f71663          	bne	a4,a5,ffffffffc020093e <pgfault_handler+0xa6>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008f6:	11043603          	ld	a2,272(s0)
ffffffffc02008fa:	11843583          	ld	a1,280(s0)
}
ffffffffc02008fe:	6442                	ld	s0,16(sp)
ffffffffc0200900:	60e2                	ld	ra,24(sp)
ffffffffc0200902:	64a2                	ld	s1,8(sp)
ffffffffc0200904:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200906:	6190006f          	j	ffffffffc020171e <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020090a:	11843703          	ld	a4,280(s0)
ffffffffc020090e:	47bd                	li	a5,15
ffffffffc0200910:	05500613          	li	a2,85
ffffffffc0200914:	05700693          	li	a3,87
ffffffffc0200918:	faf71be3          	bne	a4,a5,ffffffffc02008ce <pgfault_handler+0x36>
ffffffffc020091c:	bf5d                	j	ffffffffc02008d2 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020091e:	000b2797          	auipc	a5,0xb2
ffffffffc0200922:	f227b783          	ld	a5,-222(a5) # ffffffffc02b2840 <current>
ffffffffc0200926:	cf85                	beqz	a5,ffffffffc020095e <pgfault_handler+0xc6>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200928:	11043603          	ld	a2,272(s0)
ffffffffc020092c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200930:	6442                	ld	s0,16(sp)
ffffffffc0200932:	60e2                	ld	ra,24(sp)
ffffffffc0200934:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200936:	7788                	ld	a0,40(a5)
}
ffffffffc0200938:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020093a:	5e50006f          	j	ffffffffc020171e <do_pgfault>
        assert(current == idleproc);
ffffffffc020093e:	00006697          	auipc	a3,0x6
ffffffffc0200942:	32a68693          	addi	a3,a3,810 # ffffffffc0206c68 <commands+0x3f8>
ffffffffc0200946:	00006617          	auipc	a2,0x6
ffffffffc020094a:	33a60613          	addi	a2,a2,826 # ffffffffc0206c80 <commands+0x410>
ffffffffc020094e:	06b00593          	li	a1,107
ffffffffc0200952:	00006517          	auipc	a0,0x6
ffffffffc0200956:	34650513          	addi	a0,a0,838 # ffffffffc0206c98 <commands+0x428>
ffffffffc020095a:	8afff0ef          	jal	ra,ffffffffc0200208 <__panic>
            print_trapframe(tf);
ffffffffc020095e:	8522                	mv	a0,s0
ffffffffc0200960:	ed7ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200964:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200968:	11043583          	ld	a1,272(s0)
ffffffffc020096c:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200970:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200974:	e399                	bnez	a5,ffffffffc020097a <pgfault_handler+0xe2>
ffffffffc0200976:	05500613          	li	a2,85
ffffffffc020097a:	11843703          	ld	a4,280(s0)
ffffffffc020097e:	47bd                	li	a5,15
ffffffffc0200980:	02f70663          	beq	a4,a5,ffffffffc02009ac <pgfault_handler+0x114>
ffffffffc0200984:	05200693          	li	a3,82
ffffffffc0200988:	00006517          	auipc	a0,0x6
ffffffffc020098c:	2c050513          	addi	a0,a0,704 # ffffffffc0206c48 <commands+0x3d8>
ffffffffc0200990:	f3cff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200994:	00006617          	auipc	a2,0x6
ffffffffc0200998:	31c60613          	addi	a2,a2,796 # ffffffffc0206cb0 <commands+0x440>
ffffffffc020099c:	07200593          	li	a1,114
ffffffffc02009a0:	00006517          	auipc	a0,0x6
ffffffffc02009a4:	2f850513          	addi	a0,a0,760 # ffffffffc0206c98 <commands+0x428>
ffffffffc02009a8:	861ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009ac:	05700693          	li	a3,87
ffffffffc02009b0:	bfe1                	j	ffffffffc0200988 <pgfault_handler+0xf0>

ffffffffc02009b2 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009b2:	11853783          	ld	a5,280(a0)
ffffffffc02009b6:	472d                	li	a4,11
ffffffffc02009b8:	0786                	slli	a5,a5,0x1
ffffffffc02009ba:	8385                	srli	a5,a5,0x1
ffffffffc02009bc:	08f76363          	bltu	a4,a5,ffffffffc0200a42 <interrupt_handler+0x90>
ffffffffc02009c0:	00006717          	auipc	a4,0x6
ffffffffc02009c4:	3a870713          	addi	a4,a4,936 # ffffffffc0206d68 <commands+0x4f8>
ffffffffc02009c8:	078a                	slli	a5,a5,0x2
ffffffffc02009ca:	97ba                	add	a5,a5,a4
ffffffffc02009cc:	439c                	lw	a5,0(a5)
ffffffffc02009ce:	97ba                	add	a5,a5,a4
ffffffffc02009d0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009d2:	00006517          	auipc	a0,0x6
ffffffffc02009d6:	35650513          	addi	a0,a0,854 # ffffffffc0206d28 <commands+0x4b8>
ffffffffc02009da:	ef2ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009de:	00006517          	auipc	a0,0x6
ffffffffc02009e2:	32a50513          	addi	a0,a0,810 # ffffffffc0206d08 <commands+0x498>
ffffffffc02009e6:	ee6ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009ea:	00006517          	auipc	a0,0x6
ffffffffc02009ee:	2de50513          	addi	a0,a0,734 # ffffffffc0206cc8 <commands+0x458>
ffffffffc02009f2:	edaff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009f6:	00006517          	auipc	a0,0x6
ffffffffc02009fa:	2f250513          	addi	a0,a0,754 # ffffffffc0206ce8 <commands+0x478>
ffffffffc02009fe:	eceff06f          	j	ffffffffc02000cc <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a02:	1141                	addi	sp,sp,-16
ffffffffc0200a04:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200a06:	bafff0ef          	jal	ra,ffffffffc02005b4 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a0a:	000b2697          	auipc	a3,0xb2
ffffffffc0200a0e:	dc668693          	addi	a3,a3,-570 # ffffffffc02b27d0 <ticks>
ffffffffc0200a12:	629c                	ld	a5,0(a3)
ffffffffc0200a14:	06400713          	li	a4,100
ffffffffc0200a18:	0785                	addi	a5,a5,1
ffffffffc0200a1a:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a1e:	e29c                	sd	a5,0(a3)
ffffffffc0200a20:	eb01                	bnez	a4,ffffffffc0200a30 <interrupt_handler+0x7e>
ffffffffc0200a22:	000b2797          	auipc	a5,0xb2
ffffffffc0200a26:	e1e7b783          	ld	a5,-482(a5) # ffffffffc02b2840 <current>
ffffffffc0200a2a:	c399                	beqz	a5,ffffffffc0200a30 <interrupt_handler+0x7e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc0200a2c:	4705                	li	a4,1
ffffffffc0200a2e:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a30:	60a2                	ld	ra,8(sp)
ffffffffc0200a32:	0141                	addi	sp,sp,16
ffffffffc0200a34:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a36:	00006517          	auipc	a0,0x6
ffffffffc0200a3a:	31250513          	addi	a0,a0,786 # ffffffffc0206d48 <commands+0x4d8>
ffffffffc0200a3e:	e8eff06f          	j	ffffffffc02000cc <cprintf>
            print_trapframe(tf);
ffffffffc0200a42:	bbd5                	j	ffffffffc0200836 <print_trapframe>

ffffffffc0200a44 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a44:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a48:	1101                	addi	sp,sp,-32
ffffffffc0200a4a:	e822                	sd	s0,16(sp)
ffffffffc0200a4c:	ec06                	sd	ra,24(sp)
ffffffffc0200a4e:	e426                	sd	s1,8(sp)
ffffffffc0200a50:	473d                	li	a4,15
ffffffffc0200a52:	842a                	mv	s0,a0
ffffffffc0200a54:	18f76563          	bltu	a4,a5,ffffffffc0200bde <exception_handler+0x19a>
ffffffffc0200a58:	00006717          	auipc	a4,0x6
ffffffffc0200a5c:	4d870713          	addi	a4,a4,1240 # ffffffffc0206f30 <commands+0x6c0>
ffffffffc0200a60:	078a                	slli	a5,a5,0x2
ffffffffc0200a62:	97ba                	add	a5,a5,a4
ffffffffc0200a64:	439c                	lw	a5,0(a5)
ffffffffc0200a66:	97ba                	add	a5,a5,a4
ffffffffc0200a68:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a6a:	00006517          	auipc	a0,0x6
ffffffffc0200a6e:	41e50513          	addi	a0,a0,1054 # ffffffffc0206e88 <commands+0x618>
ffffffffc0200a72:	e5aff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            tf->epc += 4;
ffffffffc0200a76:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a7a:	60e2                	ld	ra,24(sp)
ffffffffc0200a7c:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a7e:	0791                	addi	a5,a5,4
ffffffffc0200a80:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a84:	6442                	ld	s0,16(sp)
ffffffffc0200a86:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a88:	6160506f          	j	ffffffffc020609e <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a8c:	00006517          	auipc	a0,0x6
ffffffffc0200a90:	41c50513          	addi	a0,a0,1052 # ffffffffc0206ea8 <commands+0x638>
}
ffffffffc0200a94:	6442                	ld	s0,16(sp)
ffffffffc0200a96:	60e2                	ld	ra,24(sp)
ffffffffc0200a98:	64a2                	ld	s1,8(sp)
ffffffffc0200a9a:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a9c:	e30ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200aa0:	00006517          	auipc	a0,0x6
ffffffffc0200aa4:	42850513          	addi	a0,a0,1064 # ffffffffc0206ec8 <commands+0x658>
ffffffffc0200aa8:	b7f5                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200aaa:	00006517          	auipc	a0,0x6
ffffffffc0200aae:	43e50513          	addi	a0,a0,1086 # ffffffffc0206ee8 <commands+0x678>
ffffffffc0200ab2:	b7cd                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ab4:	00006517          	auipc	a0,0x6
ffffffffc0200ab8:	44c50513          	addi	a0,a0,1100 # ffffffffc0206f00 <commands+0x690>
ffffffffc0200abc:	e10ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ac0:	8522                	mv	a0,s0
ffffffffc0200ac2:	dd7ff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200ac6:	84aa                	mv	s1,a0
ffffffffc0200ac8:	12051d63          	bnez	a0,ffffffffc0200c02 <exception_handler+0x1be>
}
ffffffffc0200acc:	60e2                	ld	ra,24(sp)
ffffffffc0200ace:	6442                	ld	s0,16(sp)
ffffffffc0200ad0:	64a2                	ld	s1,8(sp)
ffffffffc0200ad2:	6105                	addi	sp,sp,32
ffffffffc0200ad4:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200ad6:	00006517          	auipc	a0,0x6
ffffffffc0200ada:	44250513          	addi	a0,a0,1090 # ffffffffc0206f18 <commands+0x6a8>
ffffffffc0200ade:	deeff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae2:	8522                	mv	a0,s0
ffffffffc0200ae4:	db5ff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200ae8:	84aa                	mv	s1,a0
ffffffffc0200aea:	d16d                	beqz	a0,ffffffffc0200acc <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200aec:	8522                	mv	a0,s0
ffffffffc0200aee:	d49ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200af2:	86a6                	mv	a3,s1
ffffffffc0200af4:	00006617          	auipc	a2,0x6
ffffffffc0200af8:	34460613          	addi	a2,a2,836 # ffffffffc0206e38 <commands+0x5c8>
ffffffffc0200afc:	0f800593          	li	a1,248
ffffffffc0200b00:	00006517          	auipc	a0,0x6
ffffffffc0200b04:	19850513          	addi	a0,a0,408 # ffffffffc0206c98 <commands+0x428>
ffffffffc0200b08:	f00ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b0c:	00006517          	auipc	a0,0x6
ffffffffc0200b10:	28c50513          	addi	a0,a0,652 # ffffffffc0206d98 <commands+0x528>
ffffffffc0200b14:	b741                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b16:	00006517          	auipc	a0,0x6
ffffffffc0200b1a:	2a250513          	addi	a0,a0,674 # ffffffffc0206db8 <commands+0x548>
ffffffffc0200b1e:	bf9d                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b20:	00006517          	auipc	a0,0x6
ffffffffc0200b24:	2b850513          	addi	a0,a0,696 # ffffffffc0206dd8 <commands+0x568>
ffffffffc0200b28:	b7b5                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b2a:	00006517          	auipc	a0,0x6
ffffffffc0200b2e:	2c650513          	addi	a0,a0,710 # ffffffffc0206df0 <commands+0x580>
ffffffffc0200b32:	d9aff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b36:	6458                	ld	a4,136(s0)
ffffffffc0200b38:	47a9                	li	a5,10
ffffffffc0200b3a:	f8f719e3          	bne	a4,a5,ffffffffc0200acc <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b3e:	10843783          	ld	a5,264(s0)
ffffffffc0200b42:	0791                	addi	a5,a5,4
ffffffffc0200b44:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b48:	556050ef          	jal	ra,ffffffffc020609e <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b4c:	000b2797          	auipc	a5,0xb2
ffffffffc0200b50:	cf47b783          	ld	a5,-780(a5) # ffffffffc02b2840 <current>
ffffffffc0200b54:	6b9c                	ld	a5,16(a5)
ffffffffc0200b56:	8522                	mv	a0,s0
}
ffffffffc0200b58:	6442                	ld	s0,16(sp)
ffffffffc0200b5a:	60e2                	ld	ra,24(sp)
ffffffffc0200b5c:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b5e:	6589                	lui	a1,0x2
ffffffffc0200b60:	95be                	add	a1,a1,a5
}
ffffffffc0200b62:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b64:	ac19                	j	ffffffffc0200d7a <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b66:	00006517          	auipc	a0,0x6
ffffffffc0200b6a:	29a50513          	addi	a0,a0,666 # ffffffffc0206e00 <commands+0x590>
ffffffffc0200b6e:	b71d                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b70:	00006517          	auipc	a0,0x6
ffffffffc0200b74:	2b050513          	addi	a0,a0,688 # ffffffffc0206e20 <commands+0x5b0>
ffffffffc0200b78:	d54ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b7c:	8522                	mv	a0,s0
ffffffffc0200b7e:	d1bff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200b82:	84aa                	mv	s1,a0
ffffffffc0200b84:	d521                	beqz	a0,ffffffffc0200acc <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b86:	8522                	mv	a0,s0
ffffffffc0200b88:	cafff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b8c:	86a6                	mv	a3,s1
ffffffffc0200b8e:	00006617          	auipc	a2,0x6
ffffffffc0200b92:	2aa60613          	addi	a2,a2,682 # ffffffffc0206e38 <commands+0x5c8>
ffffffffc0200b96:	0cd00593          	li	a1,205
ffffffffc0200b9a:	00006517          	auipc	a0,0x6
ffffffffc0200b9e:	0fe50513          	addi	a0,a0,254 # ffffffffc0206c98 <commands+0x428>
ffffffffc0200ba2:	e66ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200ba6:	00006517          	auipc	a0,0x6
ffffffffc0200baa:	2ca50513          	addi	a0,a0,714 # ffffffffc0206e70 <commands+0x600>
ffffffffc0200bae:	d1eff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bb2:	8522                	mv	a0,s0
ffffffffc0200bb4:	ce5ff0ef          	jal	ra,ffffffffc0200898 <pgfault_handler>
ffffffffc0200bb8:	84aa                	mv	s1,a0
ffffffffc0200bba:	f00509e3          	beqz	a0,ffffffffc0200acc <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bbe:	8522                	mv	a0,s0
ffffffffc0200bc0:	c77ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bc4:	86a6                	mv	a3,s1
ffffffffc0200bc6:	00006617          	auipc	a2,0x6
ffffffffc0200bca:	27260613          	addi	a2,a2,626 # ffffffffc0206e38 <commands+0x5c8>
ffffffffc0200bce:	0d700593          	li	a1,215
ffffffffc0200bd2:	00006517          	auipc	a0,0x6
ffffffffc0200bd6:	0c650513          	addi	a0,a0,198 # ffffffffc0206c98 <commands+0x428>
ffffffffc0200bda:	e2eff0ef          	jal	ra,ffffffffc0200208 <__panic>
            print_trapframe(tf);
ffffffffc0200bde:	8522                	mv	a0,s0
}
ffffffffc0200be0:	6442                	ld	s0,16(sp)
ffffffffc0200be2:	60e2                	ld	ra,24(sp)
ffffffffc0200be4:	64a2                	ld	s1,8(sp)
ffffffffc0200be6:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200be8:	b1b9                	j	ffffffffc0200836 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200bea:	00006617          	auipc	a2,0x6
ffffffffc0200bee:	26e60613          	addi	a2,a2,622 # ffffffffc0206e58 <commands+0x5e8>
ffffffffc0200bf2:	0d100593          	li	a1,209
ffffffffc0200bf6:	00006517          	auipc	a0,0x6
ffffffffc0200bfa:	0a250513          	addi	a0,a0,162 # ffffffffc0206c98 <commands+0x428>
ffffffffc0200bfe:	e0aff0ef          	jal	ra,ffffffffc0200208 <__panic>
                print_trapframe(tf);
ffffffffc0200c02:	8522                	mv	a0,s0
ffffffffc0200c04:	c33ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c08:	86a6                	mv	a3,s1
ffffffffc0200c0a:	00006617          	auipc	a2,0x6
ffffffffc0200c0e:	22e60613          	addi	a2,a2,558 # ffffffffc0206e38 <commands+0x5c8>
ffffffffc0200c12:	0f100593          	li	a1,241
ffffffffc0200c16:	00006517          	auipc	a0,0x6
ffffffffc0200c1a:	08250513          	addi	a0,a0,130 # ffffffffc0206c98 <commands+0x428>
ffffffffc0200c1e:	deaff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200c22 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c22:	1101                	addi	sp,sp,-32
ffffffffc0200c24:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c26:	000b2417          	auipc	s0,0xb2
ffffffffc0200c2a:	c1a40413          	addi	s0,s0,-998 # ffffffffc02b2840 <current>
ffffffffc0200c2e:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c30:	ec06                	sd	ra,24(sp)
ffffffffc0200c32:	e426                	sd	s1,8(sp)
ffffffffc0200c34:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c36:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c3a:	cf1d                	beqz	a4,ffffffffc0200c78 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c3c:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c40:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c44:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c46:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c4a:	0206c463          	bltz	a3,ffffffffc0200c72 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c4e:	df7ff0ef          	jal	ra,ffffffffc0200a44 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c52:	601c                	ld	a5,0(s0)
ffffffffc0200c54:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c58:	e499                	bnez	s1,ffffffffc0200c66 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c5a:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c5e:	8b05                	andi	a4,a4,1
ffffffffc0200c60:	e329                	bnez	a4,ffffffffc0200ca2 <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c62:	6f9c                	ld	a5,24(a5)
ffffffffc0200c64:	eb85                	bnez	a5,ffffffffc0200c94 <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c66:	60e2                	ld	ra,24(sp)
ffffffffc0200c68:	6442                	ld	s0,16(sp)
ffffffffc0200c6a:	64a2                	ld	s1,8(sp)
ffffffffc0200c6c:	6902                	ld	s2,0(sp)
ffffffffc0200c6e:	6105                	addi	sp,sp,32
ffffffffc0200c70:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c72:	d41ff0ef          	jal	ra,ffffffffc02009b2 <interrupt_handler>
ffffffffc0200c76:	bff1                	j	ffffffffc0200c52 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c78:	0006c863          	bltz	a3,ffffffffc0200c88 <trap+0x66>
}
ffffffffc0200c7c:	6442                	ld	s0,16(sp)
ffffffffc0200c7e:	60e2                	ld	ra,24(sp)
ffffffffc0200c80:	64a2                	ld	s1,8(sp)
ffffffffc0200c82:	6902                	ld	s2,0(sp)
ffffffffc0200c84:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c86:	bb7d                	j	ffffffffc0200a44 <exception_handler>
}
ffffffffc0200c88:	6442                	ld	s0,16(sp)
ffffffffc0200c8a:	60e2                	ld	ra,24(sp)
ffffffffc0200c8c:	64a2                	ld	s1,8(sp)
ffffffffc0200c8e:	6902                	ld	s2,0(sp)
ffffffffc0200c90:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c92:	b305                	j	ffffffffc02009b2 <interrupt_handler>
}
ffffffffc0200c94:	6442                	ld	s0,16(sp)
ffffffffc0200c96:	60e2                	ld	ra,24(sp)
ffffffffc0200c98:	64a2                	ld	s1,8(sp)
ffffffffc0200c9a:	6902                	ld	s2,0(sp)
ffffffffc0200c9c:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c9e:	3140506f          	j	ffffffffc0205fb2 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200ca2:	555d                	li	a0,-9
ffffffffc0200ca4:	6c2040ef          	jal	ra,ffffffffc0205366 <do_exit>
            if (current->need_resched) {
ffffffffc0200ca8:	601c                	ld	a5,0(s0)
ffffffffc0200caa:	bf65                	j	ffffffffc0200c62 <trap+0x40>

ffffffffc0200cac <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
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
ffffffffc0200d18:	f0bff0ef          	jal	ra,ffffffffc0200c22 <trap>

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

ffffffffc0200e22 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200e22:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200e24:	00006697          	auipc	a3,0x6
ffffffffc0200e28:	14c68693          	addi	a3,a3,332 # ffffffffc0206f70 <commands+0x700>
ffffffffc0200e2c:	00006617          	auipc	a2,0x6
ffffffffc0200e30:	e5460613          	addi	a2,a2,-428 # ffffffffc0206c80 <commands+0x410>
ffffffffc0200e34:	06d00593          	li	a1,109
ffffffffc0200e38:	00006517          	auipc	a0,0x6
ffffffffc0200e3c:	15850513          	addi	a0,a0,344 # ffffffffc0206f90 <commands+0x720>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200e40:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200e42:	bc6ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200e46 <mm_create>:
mm_create(void) {
ffffffffc0200e46:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e48:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0200e4c:	e022                	sd	s0,0(sp)
ffffffffc0200e4e:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e50:	062010ef          	jal	ra,ffffffffc0201eb2 <kmalloc>
ffffffffc0200e54:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200e56:	c505                	beqz	a0,ffffffffc0200e7e <mm_create+0x38>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e58:	e408                	sd	a0,8(s0)
ffffffffc0200e5a:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200e5c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200e60:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200e64:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200e68:	000b2797          	auipc	a5,0xb2
ffffffffc0200e6c:	9a07a783          	lw	a5,-1632(a5) # ffffffffc02b2808 <swap_init_ok>
ffffffffc0200e70:	ef81                	bnez	a5,ffffffffc0200e88 <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc0200e72:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0200e76:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0200e7a:	02043c23          	sd	zero,56(s0)
}
ffffffffc0200e7e:	60a2                	ld	ra,8(sp)
ffffffffc0200e80:	8522                	mv	a0,s0
ffffffffc0200e82:	6402                	ld	s0,0(sp)
ffffffffc0200e84:	0141                	addi	sp,sp,16
ffffffffc0200e86:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200e88:	133010ef          	jal	ra,ffffffffc02027ba <swap_init_mm>
ffffffffc0200e8c:	b7ed                	j	ffffffffc0200e76 <mm_create+0x30>

ffffffffc0200e8e <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200e8e:	1101                	addi	sp,sp,-32
ffffffffc0200e90:	e04a                	sd	s2,0(sp)
ffffffffc0200e92:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200e94:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200e98:	e822                	sd	s0,16(sp)
ffffffffc0200e9a:	e426                	sd	s1,8(sp)
ffffffffc0200e9c:	ec06                	sd	ra,24(sp)
ffffffffc0200e9e:	84ae                	mv	s1,a1
ffffffffc0200ea0:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200ea2:	010010ef          	jal	ra,ffffffffc0201eb2 <kmalloc>
    if (vma != NULL) {
ffffffffc0200ea6:	c509                	beqz	a0,ffffffffc0200eb0 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200ea8:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200eac:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200eae:	cd00                	sw	s0,24(a0)
}
ffffffffc0200eb0:	60e2                	ld	ra,24(sp)
ffffffffc0200eb2:	6442                	ld	s0,16(sp)
ffffffffc0200eb4:	64a2                	ld	s1,8(sp)
ffffffffc0200eb6:	6902                	ld	s2,0(sp)
ffffffffc0200eb8:	6105                	addi	sp,sp,32
ffffffffc0200eba:	8082                	ret

ffffffffc0200ebc <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0200ebc:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0200ebe:	c505                	beqz	a0,ffffffffc0200ee6 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0200ec0:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200ec2:	c501                	beqz	a0,ffffffffc0200eca <find_vma+0xe>
ffffffffc0200ec4:	651c                	ld	a5,8(a0)
ffffffffc0200ec6:	02f5f263          	bgeu	a1,a5,ffffffffc0200eea <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200eca:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0200ecc:	00f68d63          	beq	a3,a5,ffffffffc0200ee6 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200ed0:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200ed4:	00e5e663          	bltu	a1,a4,ffffffffc0200ee0 <find_vma+0x24>
ffffffffc0200ed8:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200edc:	00e5ec63          	bltu	a1,a4,ffffffffc0200ef4 <find_vma+0x38>
ffffffffc0200ee0:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200ee2:	fef697e3          	bne	a3,a5,ffffffffc0200ed0 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0200ee6:	4501                	li	a0,0
}
ffffffffc0200ee8:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200eea:	691c                	ld	a5,16(a0)
ffffffffc0200eec:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0200eca <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0200ef0:	ea88                	sd	a0,16(a3)
ffffffffc0200ef2:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0200ef4:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0200ef8:	ea88                	sd	a0,16(a3)
ffffffffc0200efa:	8082                	ret

ffffffffc0200efc <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200efc:	6590                	ld	a2,8(a1)
ffffffffc0200efe:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200f02:	1141                	addi	sp,sp,-16
ffffffffc0200f04:	e406                	sd	ra,8(sp)
ffffffffc0200f06:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f08:	01066763          	bltu	a2,a6,ffffffffc0200f16 <insert_vma_struct+0x1a>
ffffffffc0200f0c:	a085                	j	ffffffffc0200f6c <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200f0e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200f12:	04e66863          	bltu	a2,a4,ffffffffc0200f62 <insert_vma_struct+0x66>
ffffffffc0200f16:	86be                	mv	a3,a5
ffffffffc0200f18:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0200f1a:	fef51ae3          	bne	a0,a5,ffffffffc0200f0e <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200f1e:	02a68463          	beq	a3,a0,ffffffffc0200f46 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200f22:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200f26:	fe86b883          	ld	a7,-24(a3)
ffffffffc0200f2a:	08e8f163          	bgeu	a7,a4,ffffffffc0200fac <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f2e:	04e66f63          	bltu	a2,a4,ffffffffc0200f8c <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0200f32:	00f50a63          	beq	a0,a5,ffffffffc0200f46 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200f36:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f3a:	05076963          	bltu	a4,a6,ffffffffc0200f8c <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0200f3e:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200f42:	02c77363          	bgeu	a4,a2,ffffffffc0200f68 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200f46:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0200f48:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200f4a:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200f4e:	e390                	sd	a2,0(a5)
ffffffffc0200f50:	e690                	sd	a2,8(a3)
}
ffffffffc0200f52:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200f54:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200f56:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0200f58:	0017079b          	addiw	a5,a4,1
ffffffffc0200f5c:	d11c                	sw	a5,32(a0)
}
ffffffffc0200f5e:	0141                	addi	sp,sp,16
ffffffffc0200f60:	8082                	ret
    if (le_prev != list) {
ffffffffc0200f62:	fca690e3          	bne	a3,a0,ffffffffc0200f22 <insert_vma_struct+0x26>
ffffffffc0200f66:	bfd1                	j	ffffffffc0200f3a <insert_vma_struct+0x3e>
ffffffffc0200f68:	ebbff0ef          	jal	ra,ffffffffc0200e22 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f6c:	00006697          	auipc	a3,0x6
ffffffffc0200f70:	03468693          	addi	a3,a3,52 # ffffffffc0206fa0 <commands+0x730>
ffffffffc0200f74:	00006617          	auipc	a2,0x6
ffffffffc0200f78:	d0c60613          	addi	a2,a2,-756 # ffffffffc0206c80 <commands+0x410>
ffffffffc0200f7c:	07400593          	li	a1,116
ffffffffc0200f80:	00006517          	auipc	a0,0x6
ffffffffc0200f84:	01050513          	addi	a0,a0,16 # ffffffffc0206f90 <commands+0x720>
ffffffffc0200f88:	a80ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f8c:	00006697          	auipc	a3,0x6
ffffffffc0200f90:	05468693          	addi	a3,a3,84 # ffffffffc0206fe0 <commands+0x770>
ffffffffc0200f94:	00006617          	auipc	a2,0x6
ffffffffc0200f98:	cec60613          	addi	a2,a2,-788 # ffffffffc0206c80 <commands+0x410>
ffffffffc0200f9c:	06c00593          	li	a1,108
ffffffffc0200fa0:	00006517          	auipc	a0,0x6
ffffffffc0200fa4:	ff050513          	addi	a0,a0,-16 # ffffffffc0206f90 <commands+0x720>
ffffffffc0200fa8:	a60ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200fac:	00006697          	auipc	a3,0x6
ffffffffc0200fb0:	01468693          	addi	a3,a3,20 # ffffffffc0206fc0 <commands+0x750>
ffffffffc0200fb4:	00006617          	auipc	a2,0x6
ffffffffc0200fb8:	ccc60613          	addi	a2,a2,-820 # ffffffffc0206c80 <commands+0x410>
ffffffffc0200fbc:	06b00593          	li	a1,107
ffffffffc0200fc0:	00006517          	auipc	a0,0x6
ffffffffc0200fc4:	fd050513          	addi	a0,a0,-48 # ffffffffc0206f90 <commands+0x720>
ffffffffc0200fc8:	a40ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200fcc <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0200fcc:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0200fce:	1141                	addi	sp,sp,-16
ffffffffc0200fd0:	e406                	sd	ra,8(sp)
ffffffffc0200fd2:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0200fd4:	e78d                	bnez	a5,ffffffffc0200ffe <mm_destroy+0x32>
ffffffffc0200fd6:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200fd8:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200fda:	00a40c63          	beq	s0,a0,ffffffffc0200ff2 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200fde:	6118                	ld	a4,0(a0)
ffffffffc0200fe0:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0200fe2:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200fe4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200fe6:	e398                	sd	a4,0(a5)
ffffffffc0200fe8:	77b000ef          	jal	ra,ffffffffc0201f62 <kfree>
    return listelm->next;
ffffffffc0200fec:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200fee:	fea418e3          	bne	s0,a0,ffffffffc0200fde <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0200ff2:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0200ff4:	6402                	ld	s0,0(sp)
ffffffffc0200ff6:	60a2                	ld	ra,8(sp)
ffffffffc0200ff8:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0200ffa:	7690006f          	j	ffffffffc0201f62 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0200ffe:	00006697          	auipc	a3,0x6
ffffffffc0201002:	00268693          	addi	a3,a3,2 # ffffffffc0207000 <commands+0x790>
ffffffffc0201006:	00006617          	auipc	a2,0x6
ffffffffc020100a:	c7a60613          	addi	a2,a2,-902 # ffffffffc0206c80 <commands+0x410>
ffffffffc020100e:	09400593          	li	a1,148
ffffffffc0201012:	00006517          	auipc	a0,0x6
ffffffffc0201016:	f7e50513          	addi	a0,a0,-130 # ffffffffc0206f90 <commands+0x720>
ffffffffc020101a:	9eeff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020101e <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc020101e:	7139                	addi	sp,sp,-64
ffffffffc0201020:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0201022:	6405                	lui	s0,0x1
ffffffffc0201024:	147d                	addi	s0,s0,-1
ffffffffc0201026:	77fd                	lui	a5,0xfffff
ffffffffc0201028:	9622                	add	a2,a2,s0
ffffffffc020102a:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc020102c:	f426                	sd	s1,40(sp)
ffffffffc020102e:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0201030:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc0201034:	f04a                	sd	s2,32(sp)
ffffffffc0201036:	ec4e                	sd	s3,24(sp)
ffffffffc0201038:	e852                	sd	s4,16(sp)
ffffffffc020103a:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc020103c:	002005b7          	lui	a1,0x200
ffffffffc0201040:	00f67433          	and	s0,a2,a5
ffffffffc0201044:	06b4e363          	bltu	s1,a1,ffffffffc02010aa <mm_map+0x8c>
ffffffffc0201048:	0684f163          	bgeu	s1,s0,ffffffffc02010aa <mm_map+0x8c>
ffffffffc020104c:	4785                	li	a5,1
ffffffffc020104e:	07fe                	slli	a5,a5,0x1f
ffffffffc0201050:	0487ed63          	bltu	a5,s0,ffffffffc02010aa <mm_map+0x8c>
ffffffffc0201054:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0201056:	cd21                	beqz	a0,ffffffffc02010ae <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0201058:	85a6                	mv	a1,s1
ffffffffc020105a:	8ab6                	mv	s5,a3
ffffffffc020105c:	8a3a                	mv	s4,a4
ffffffffc020105e:	e5fff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
ffffffffc0201062:	c501                	beqz	a0,ffffffffc020106a <mm_map+0x4c>
ffffffffc0201064:	651c                	ld	a5,8(a0)
ffffffffc0201066:	0487e263          	bltu	a5,s0,ffffffffc02010aa <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020106a:	03000513          	li	a0,48
ffffffffc020106e:	645000ef          	jal	ra,ffffffffc0201eb2 <kmalloc>
ffffffffc0201072:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0201074:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0201076:	02090163          	beqz	s2,ffffffffc0201098 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc020107a:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc020107c:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0201080:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0201084:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0201088:	85ca                	mv	a1,s2
ffffffffc020108a:	e73ff0ef          	jal	ra,ffffffffc0200efc <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020108e:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0201090:	000a0463          	beqz	s4,ffffffffc0201098 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0201094:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0201098:	70e2                	ld	ra,56(sp)
ffffffffc020109a:	7442                	ld	s0,48(sp)
ffffffffc020109c:	74a2                	ld	s1,40(sp)
ffffffffc020109e:	7902                	ld	s2,32(sp)
ffffffffc02010a0:	69e2                	ld	s3,24(sp)
ffffffffc02010a2:	6a42                	ld	s4,16(sp)
ffffffffc02010a4:	6aa2                	ld	s5,8(sp)
ffffffffc02010a6:	6121                	addi	sp,sp,64
ffffffffc02010a8:	8082                	ret
        return -E_INVAL;
ffffffffc02010aa:	5575                	li	a0,-3
ffffffffc02010ac:	b7f5                	j	ffffffffc0201098 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc02010ae:	00006697          	auipc	a3,0x6
ffffffffc02010b2:	f6a68693          	addi	a3,a3,-150 # ffffffffc0207018 <commands+0x7a8>
ffffffffc02010b6:	00006617          	auipc	a2,0x6
ffffffffc02010ba:	bca60613          	addi	a2,a2,-1078 # ffffffffc0206c80 <commands+0x410>
ffffffffc02010be:	0a700593          	li	a1,167
ffffffffc02010c2:	00006517          	auipc	a0,0x6
ffffffffc02010c6:	ece50513          	addi	a0,a0,-306 # ffffffffc0206f90 <commands+0x720>
ffffffffc02010ca:	93eff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02010ce <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc02010ce:	7139                	addi	sp,sp,-64
ffffffffc02010d0:	fc06                	sd	ra,56(sp)
ffffffffc02010d2:	f822                	sd	s0,48(sp)
ffffffffc02010d4:	f426                	sd	s1,40(sp)
ffffffffc02010d6:	f04a                	sd	s2,32(sp)
ffffffffc02010d8:	ec4e                	sd	s3,24(sp)
ffffffffc02010da:	e852                	sd	s4,16(sp)
ffffffffc02010dc:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc02010de:	c52d                	beqz	a0,ffffffffc0201148 <dup_mmap+0x7a>
ffffffffc02010e0:	892a                	mv	s2,a0
ffffffffc02010e2:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02010e4:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02010e6:	e595                	bnez	a1,ffffffffc0201112 <dup_mmap+0x44>
ffffffffc02010e8:	a085                	j	ffffffffc0201148 <dup_mmap+0x7a>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02010ea:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc02010ec:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ee8>
        vma->vm_end = vm_end;
ffffffffc02010f0:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc02010f4:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc02010f8:	e05ff0ef          	jal	ra,ffffffffc0200efc <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc02010fc:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc0201100:	fe843603          	ld	a2,-24(s0)
ffffffffc0201104:	6c8c                	ld	a1,24(s1)
ffffffffc0201106:	01893503          	ld	a0,24(s2)
ffffffffc020110a:	4701                	li	a4,0
ffffffffc020110c:	770030ef          	jal	ra,ffffffffc020487c <copy_range>
ffffffffc0201110:	e105                	bnez	a0,ffffffffc0201130 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc0201112:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc0201114:	02848863          	beq	s1,s0,ffffffffc0201144 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201118:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc020111c:	fe843a83          	ld	s5,-24(s0)
ffffffffc0201120:	ff043a03          	ld	s4,-16(s0)
ffffffffc0201124:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201128:	58b000ef          	jal	ra,ffffffffc0201eb2 <kmalloc>
ffffffffc020112c:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc020112e:	fd55                	bnez	a0,ffffffffc02010ea <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0201130:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0201132:	70e2                	ld	ra,56(sp)
ffffffffc0201134:	7442                	ld	s0,48(sp)
ffffffffc0201136:	74a2                	ld	s1,40(sp)
ffffffffc0201138:	7902                	ld	s2,32(sp)
ffffffffc020113a:	69e2                	ld	s3,24(sp)
ffffffffc020113c:	6a42                	ld	s4,16(sp)
ffffffffc020113e:	6aa2                	ld	s5,8(sp)
ffffffffc0201140:	6121                	addi	sp,sp,64
ffffffffc0201142:	8082                	ret
    return 0;
ffffffffc0201144:	4501                	li	a0,0
ffffffffc0201146:	b7f5                	j	ffffffffc0201132 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0201148:	00006697          	auipc	a3,0x6
ffffffffc020114c:	ee068693          	addi	a3,a3,-288 # ffffffffc0207028 <commands+0x7b8>
ffffffffc0201150:	00006617          	auipc	a2,0x6
ffffffffc0201154:	b3060613          	addi	a2,a2,-1232 # ffffffffc0206c80 <commands+0x410>
ffffffffc0201158:	0c000593          	li	a1,192
ffffffffc020115c:	00006517          	auipc	a0,0x6
ffffffffc0201160:	e3450513          	addi	a0,a0,-460 # ffffffffc0206f90 <commands+0x720>
ffffffffc0201164:	8a4ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201168 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0201168:	1101                	addi	sp,sp,-32
ffffffffc020116a:	ec06                	sd	ra,24(sp)
ffffffffc020116c:	e822                	sd	s0,16(sp)
ffffffffc020116e:	e426                	sd	s1,8(sp)
ffffffffc0201170:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0201172:	c531                	beqz	a0,ffffffffc02011be <exit_mmap+0x56>
ffffffffc0201174:	591c                	lw	a5,48(a0)
ffffffffc0201176:	84aa                	mv	s1,a0
ffffffffc0201178:	e3b9                	bnez	a5,ffffffffc02011be <exit_mmap+0x56>
    return listelm->next;
ffffffffc020117a:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc020117c:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0201180:	02850663          	beq	a0,s0,ffffffffc02011ac <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0201184:	ff043603          	ld	a2,-16(s0)
ffffffffc0201188:	fe843583          	ld	a1,-24(s0)
ffffffffc020118c:	854a                	mv	a0,s2
ffffffffc020118e:	5ea020ef          	jal	ra,ffffffffc0203778 <unmap_range>
ffffffffc0201192:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0201194:	fe8498e3          	bne	s1,s0,ffffffffc0201184 <exit_mmap+0x1c>
ffffffffc0201198:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc020119a:	00848c63          	beq	s1,s0,ffffffffc02011b2 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020119e:	ff043603          	ld	a2,-16(s0)
ffffffffc02011a2:	fe843583          	ld	a1,-24(s0)
ffffffffc02011a6:	854a                	mv	a0,s2
ffffffffc02011a8:	716020ef          	jal	ra,ffffffffc02038be <exit_range>
ffffffffc02011ac:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02011ae:	fe8498e3          	bne	s1,s0,ffffffffc020119e <exit_mmap+0x36>
    }
}
ffffffffc02011b2:	60e2                	ld	ra,24(sp)
ffffffffc02011b4:	6442                	ld	s0,16(sp)
ffffffffc02011b6:	64a2                	ld	s1,8(sp)
ffffffffc02011b8:	6902                	ld	s2,0(sp)
ffffffffc02011ba:	6105                	addi	sp,sp,32
ffffffffc02011bc:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02011be:	00006697          	auipc	a3,0x6
ffffffffc02011c2:	e8a68693          	addi	a3,a3,-374 # ffffffffc0207048 <commands+0x7d8>
ffffffffc02011c6:	00006617          	auipc	a2,0x6
ffffffffc02011ca:	aba60613          	addi	a2,a2,-1350 # ffffffffc0206c80 <commands+0x410>
ffffffffc02011ce:	0d600593          	li	a1,214
ffffffffc02011d2:	00006517          	auipc	a0,0x6
ffffffffc02011d6:	dbe50513          	addi	a0,a0,-578 # ffffffffc0206f90 <commands+0x720>
ffffffffc02011da:	82eff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02011de <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02011de:	7139                	addi	sp,sp,-64
ffffffffc02011e0:	f822                	sd	s0,48(sp)
ffffffffc02011e2:	f426                	sd	s1,40(sp)
ffffffffc02011e4:	fc06                	sd	ra,56(sp)
ffffffffc02011e6:	f04a                	sd	s2,32(sp)
ffffffffc02011e8:	ec4e                	sd	s3,24(sp)
ffffffffc02011ea:	e852                	sd	s4,16(sp)
ffffffffc02011ec:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc02011ee:	c59ff0ef          	jal	ra,ffffffffc0200e46 <mm_create>
    assert(mm != NULL);
ffffffffc02011f2:	84aa                	mv	s1,a0
ffffffffc02011f4:	03200413          	li	s0,50
ffffffffc02011f8:	e919                	bnez	a0,ffffffffc020120e <vmm_init+0x30>
ffffffffc02011fa:	a991                	j	ffffffffc020164e <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc02011fc:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02011fe:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201200:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0201204:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201206:	8526                	mv	a0,s1
ffffffffc0201208:	cf5ff0ef          	jal	ra,ffffffffc0200efc <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc020120c:	c80d                	beqz	s0,ffffffffc020123e <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020120e:	03000513          	li	a0,48
ffffffffc0201212:	4a1000ef          	jal	ra,ffffffffc0201eb2 <kmalloc>
ffffffffc0201216:	85aa                	mv	a1,a0
ffffffffc0201218:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc020121c:	f165                	bnez	a0,ffffffffc02011fc <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc020121e:	00006697          	auipc	a3,0x6
ffffffffc0201222:	0ba68693          	addi	a3,a3,186 # ffffffffc02072d8 <commands+0xa68>
ffffffffc0201226:	00006617          	auipc	a2,0x6
ffffffffc020122a:	a5a60613          	addi	a2,a2,-1446 # ffffffffc0206c80 <commands+0x410>
ffffffffc020122e:	11300593          	li	a1,275
ffffffffc0201232:	00006517          	auipc	a0,0x6
ffffffffc0201236:	d5e50513          	addi	a0,a0,-674 # ffffffffc0206f90 <commands+0x720>
ffffffffc020123a:	fcffe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc020123e:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201242:	1f900913          	li	s2,505
ffffffffc0201246:	a819                	j	ffffffffc020125c <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0201248:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc020124a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020124c:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201250:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201252:	8526                	mv	a0,s1
ffffffffc0201254:	ca9ff0ef          	jal	ra,ffffffffc0200efc <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201258:	03240a63          	beq	s0,s2,ffffffffc020128c <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020125c:	03000513          	li	a0,48
ffffffffc0201260:	453000ef          	jal	ra,ffffffffc0201eb2 <kmalloc>
ffffffffc0201264:	85aa                	mv	a1,a0
ffffffffc0201266:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc020126a:	fd79                	bnez	a0,ffffffffc0201248 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc020126c:	00006697          	auipc	a3,0x6
ffffffffc0201270:	06c68693          	addi	a3,a3,108 # ffffffffc02072d8 <commands+0xa68>
ffffffffc0201274:	00006617          	auipc	a2,0x6
ffffffffc0201278:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0206c80 <commands+0x410>
ffffffffc020127c:	11900593          	li	a1,281
ffffffffc0201280:	00006517          	auipc	a0,0x6
ffffffffc0201284:	d1050513          	addi	a0,a0,-752 # ffffffffc0206f90 <commands+0x720>
ffffffffc0201288:	f81fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc020128c:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc020128e:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc0201290:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0201294:	2cf48d63          	beq	s1,a5,ffffffffc020156e <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201298:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd4c78c>
ffffffffc020129c:	ffe70613          	addi	a2,a4,-2
ffffffffc02012a0:	24d61763          	bne	a2,a3,ffffffffc02014ee <vmm_init+0x310>
ffffffffc02012a4:	ff07b683          	ld	a3,-16(a5)
ffffffffc02012a8:	24e69363          	bne	a3,a4,ffffffffc02014ee <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc02012ac:	0715                	addi	a4,a4,5
ffffffffc02012ae:	679c                	ld	a5,8(a5)
ffffffffc02012b0:	feb712e3          	bne	a4,a1,ffffffffc0201294 <vmm_init+0xb6>
ffffffffc02012b4:	4a1d                	li	s4,7
ffffffffc02012b6:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02012b8:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02012bc:	85a2                	mv	a1,s0
ffffffffc02012be:	8526                	mv	a0,s1
ffffffffc02012c0:	bfdff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
ffffffffc02012c4:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc02012c6:	30050463          	beqz	a0,ffffffffc02015ce <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02012ca:	00140593          	addi	a1,s0,1
ffffffffc02012ce:	8526                	mv	a0,s1
ffffffffc02012d0:	bedff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
ffffffffc02012d4:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc02012d6:	2c050c63          	beqz	a0,ffffffffc02015ae <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02012da:	85d2                	mv	a1,s4
ffffffffc02012dc:	8526                	mv	a0,s1
ffffffffc02012de:	bdfff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
        assert(vma3 == NULL);
ffffffffc02012e2:	2a051663          	bnez	a0,ffffffffc020158e <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02012e6:	00340593          	addi	a1,s0,3
ffffffffc02012ea:	8526                	mv	a0,s1
ffffffffc02012ec:	bd1ff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
        assert(vma4 == NULL);
ffffffffc02012f0:	30051f63          	bnez	a0,ffffffffc020160e <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02012f4:	00440593          	addi	a1,s0,4
ffffffffc02012f8:	8526                	mv	a0,s1
ffffffffc02012fa:	bc3ff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
        assert(vma5 == NULL);
ffffffffc02012fe:	2e051863          	bnez	a0,ffffffffc02015ee <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201302:	00893783          	ld	a5,8(s2)
ffffffffc0201306:	20879463          	bne	a5,s0,ffffffffc020150e <vmm_init+0x330>
ffffffffc020130a:	01093783          	ld	a5,16(s2)
ffffffffc020130e:	20fa1063          	bne	s4,a5,ffffffffc020150e <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201312:	0089b783          	ld	a5,8(s3)
ffffffffc0201316:	20879c63          	bne	a5,s0,ffffffffc020152e <vmm_init+0x350>
ffffffffc020131a:	0109b783          	ld	a5,16(s3)
ffffffffc020131e:	20fa1863          	bne	s4,a5,ffffffffc020152e <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201322:	0415                	addi	s0,s0,5
ffffffffc0201324:	0a15                	addi	s4,s4,5
ffffffffc0201326:	f9541be3          	bne	s0,s5,ffffffffc02012bc <vmm_init+0xde>
ffffffffc020132a:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc020132c:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020132e:	85a2                	mv	a1,s0
ffffffffc0201330:	8526                	mv	a0,s1
ffffffffc0201332:	b8bff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
ffffffffc0201336:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc020133a:	c90d                	beqz	a0,ffffffffc020136c <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc020133c:	6914                	ld	a3,16(a0)
ffffffffc020133e:	6510                	ld	a2,8(a0)
ffffffffc0201340:	00006517          	auipc	a0,0x6
ffffffffc0201344:	e2850513          	addi	a0,a0,-472 # ffffffffc0207168 <commands+0x8f8>
ffffffffc0201348:	d85fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc020134c:	00006697          	auipc	a3,0x6
ffffffffc0201350:	e4468693          	addi	a3,a3,-444 # ffffffffc0207190 <commands+0x920>
ffffffffc0201354:	00006617          	auipc	a2,0x6
ffffffffc0201358:	92c60613          	addi	a2,a2,-1748 # ffffffffc0206c80 <commands+0x410>
ffffffffc020135c:	13b00593          	li	a1,315
ffffffffc0201360:	00006517          	auipc	a0,0x6
ffffffffc0201364:	c3050513          	addi	a0,a0,-976 # ffffffffc0206f90 <commands+0x720>
ffffffffc0201368:	ea1fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc020136c:	147d                	addi	s0,s0,-1
ffffffffc020136e:	fd2410e3          	bne	s0,s2,ffffffffc020132e <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0201372:	8526                	mv	a0,s1
ffffffffc0201374:	c59ff0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0201378:	00006517          	auipc	a0,0x6
ffffffffc020137c:	e3050513          	addi	a0,a0,-464 # ffffffffc02071a8 <commands+0x938>
ffffffffc0201380:	d4dfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201384:	194020ef          	jal	ra,ffffffffc0203518 <nr_free_pages>
ffffffffc0201388:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc020138a:	abdff0ef          	jal	ra,ffffffffc0200e46 <mm_create>
ffffffffc020138e:	000b1797          	auipc	a5,0xb1
ffffffffc0201392:	44a7b923          	sd	a0,1106(a5) # ffffffffc02b27e0 <check_mm_struct>
ffffffffc0201396:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc0201398:	28050b63          	beqz	a0,ffffffffc020162e <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020139c:	000b1497          	auipc	s1,0xb1
ffffffffc02013a0:	47c4b483          	ld	s1,1148(s1) # ffffffffc02b2818 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc02013a4:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013a6:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02013a8:	2e079f63          	bnez	a5,ffffffffc02016a6 <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02013ac:	03000513          	li	a0,48
ffffffffc02013b0:	303000ef          	jal	ra,ffffffffc0201eb2 <kmalloc>
ffffffffc02013b4:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc02013b6:	18050c63          	beqz	a0,ffffffffc020154e <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc02013ba:	002007b7          	lui	a5,0x200
ffffffffc02013be:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc02013c2:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02013c4:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02013c6:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc02013ca:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02013cc:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc02013d0:	b2dff0ef          	jal	ra,ffffffffc0200efc <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02013d4:	10000593          	li	a1,256
ffffffffc02013d8:	8522                	mv	a0,s0
ffffffffc02013da:	ae3ff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
ffffffffc02013de:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc02013e2:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02013e6:	2ea99063          	bne	s3,a0,ffffffffc02016c6 <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc02013ea:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f4ee0>
    for (i = 0; i < 100; i ++) {
ffffffffc02013ee:	0785                	addi	a5,a5,1
ffffffffc02013f0:	fee79de3          	bne	a5,a4,ffffffffc02013ea <vmm_init+0x20c>
        sum += i;
ffffffffc02013f4:	6705                	lui	a4,0x1
ffffffffc02013f6:	10000793          	li	a5,256
ffffffffc02013fa:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x885a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02013fe:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0201402:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0201406:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0201408:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc020140a:	fec79ce3          	bne	a5,a2,ffffffffc0201402 <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc020140e:	2e071863          	bnez	a4,ffffffffc02016fe <vmm_init+0x520>
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0201412:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0201414:	000b1a97          	auipc	s5,0xb1
ffffffffc0201418:	40ca8a93          	addi	s5,s5,1036 # ffffffffc02b2820 <npage>
ffffffffc020141c:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201420:	078a                	slli	a5,a5,0x2
ffffffffc0201422:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201424:	2cc7f163          	bgeu	a5,a2,ffffffffc02016e6 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0201428:	00008a17          	auipc	s4,0x8
ffffffffc020142c:	878a3a03          	ld	s4,-1928(s4) # ffffffffc0208ca0 <nbase>
ffffffffc0201430:	414787b3          	sub	a5,a5,s4
ffffffffc0201434:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc0201436:	8799                	srai	a5,a5,0x6
ffffffffc0201438:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc020143a:	00c79713          	slli	a4,a5,0xc
ffffffffc020143e:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201440:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0201444:	24c77563          	bgeu	a4,a2,ffffffffc020168e <vmm_init+0x4b0>
ffffffffc0201448:	000b1997          	auipc	s3,0xb1
ffffffffc020144c:	3f09b983          	ld	s3,1008(s3) # ffffffffc02b2838 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0201450:	4581                	li	a1,0
ffffffffc0201452:	8526                	mv	a0,s1
ffffffffc0201454:	99b6                	add	s3,s3,a3
ffffffffc0201456:	6fa020ef          	jal	ra,ffffffffc0203b50 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020145a:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc020145e:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201462:	078a                	slli	a5,a5,0x2
ffffffffc0201464:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201466:	28e7f063          	bgeu	a5,a4,ffffffffc02016e6 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc020146a:	000b1997          	auipc	s3,0xb1
ffffffffc020146e:	3be98993          	addi	s3,s3,958 # ffffffffc02b2828 <pages>
ffffffffc0201472:	0009b503          	ld	a0,0(s3)
ffffffffc0201476:	414787b3          	sub	a5,a5,s4
ffffffffc020147a:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc020147c:	953e                	add	a0,a0,a5
ffffffffc020147e:	4585                	li	a1,1
ffffffffc0201480:	058020ef          	jal	ra,ffffffffc02034d8 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201484:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0201486:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020148a:	078a                	slli	a5,a5,0x2
ffffffffc020148c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020148e:	24e7fc63          	bgeu	a5,a4,ffffffffc02016e6 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0201492:	0009b503          	ld	a0,0(s3)
ffffffffc0201496:	414787b3          	sub	a5,a5,s4
ffffffffc020149a:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020149c:	4585                	li	a1,1
ffffffffc020149e:	953e                	add	a0,a0,a5
ffffffffc02014a0:	038020ef          	jal	ra,ffffffffc02034d8 <free_pages>
    pgdir[0] = 0;
ffffffffc02014a4:	0004b023          	sd	zero,0(s1)
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() {
  asm volatile("sfence.vma");
ffffffffc02014a8:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc02014ac:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc02014ae:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc02014b2:	b1bff0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
    check_mm_struct = NULL;
ffffffffc02014b6:	000b1797          	auipc	a5,0xb1
ffffffffc02014ba:	3207b523          	sd	zero,810(a5) # ffffffffc02b27e0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02014be:	05a020ef          	jal	ra,ffffffffc0203518 <nr_free_pages>
ffffffffc02014c2:	1aa91663          	bne	s2,a0,ffffffffc020166e <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02014c6:	00006517          	auipc	a0,0x6
ffffffffc02014ca:	dda50513          	addi	a0,a0,-550 # ffffffffc02072a0 <commands+0xa30>
ffffffffc02014ce:	bfffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02014d2:	7442                	ld	s0,48(sp)
ffffffffc02014d4:	70e2                	ld	ra,56(sp)
ffffffffc02014d6:	74a2                	ld	s1,40(sp)
ffffffffc02014d8:	7902                	ld	s2,32(sp)
ffffffffc02014da:	69e2                	ld	s3,24(sp)
ffffffffc02014dc:	6a42                	ld	s4,16(sp)
ffffffffc02014de:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02014e0:	00006517          	auipc	a0,0x6
ffffffffc02014e4:	de050513          	addi	a0,a0,-544 # ffffffffc02072c0 <commands+0xa50>
}
ffffffffc02014e8:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02014ea:	be3fe06f          	j	ffffffffc02000cc <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02014ee:	00006697          	auipc	a3,0x6
ffffffffc02014f2:	b9268693          	addi	a3,a3,-1134 # ffffffffc0207080 <commands+0x810>
ffffffffc02014f6:	00005617          	auipc	a2,0x5
ffffffffc02014fa:	78a60613          	addi	a2,a2,1930 # ffffffffc0206c80 <commands+0x410>
ffffffffc02014fe:	12200593          	li	a1,290
ffffffffc0201502:	00006517          	auipc	a0,0x6
ffffffffc0201506:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0206f90 <commands+0x720>
ffffffffc020150a:	cfffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020150e:	00006697          	auipc	a3,0x6
ffffffffc0201512:	bfa68693          	addi	a3,a3,-1030 # ffffffffc0207108 <commands+0x898>
ffffffffc0201516:	00005617          	auipc	a2,0x5
ffffffffc020151a:	76a60613          	addi	a2,a2,1898 # ffffffffc0206c80 <commands+0x410>
ffffffffc020151e:	13200593          	li	a1,306
ffffffffc0201522:	00006517          	auipc	a0,0x6
ffffffffc0201526:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0206f90 <commands+0x720>
ffffffffc020152a:	cdffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020152e:	00006697          	auipc	a3,0x6
ffffffffc0201532:	c0a68693          	addi	a3,a3,-1014 # ffffffffc0207138 <commands+0x8c8>
ffffffffc0201536:	00005617          	auipc	a2,0x5
ffffffffc020153a:	74a60613          	addi	a2,a2,1866 # ffffffffc0206c80 <commands+0x410>
ffffffffc020153e:	13300593          	li	a1,307
ffffffffc0201542:	00006517          	auipc	a0,0x6
ffffffffc0201546:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0206f90 <commands+0x720>
ffffffffc020154a:	cbffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(vma != NULL);
ffffffffc020154e:	00006697          	auipc	a3,0x6
ffffffffc0201552:	d8a68693          	addi	a3,a3,-630 # ffffffffc02072d8 <commands+0xa68>
ffffffffc0201556:	00005617          	auipc	a2,0x5
ffffffffc020155a:	72a60613          	addi	a2,a2,1834 # ffffffffc0206c80 <commands+0x410>
ffffffffc020155e:	15200593          	li	a1,338
ffffffffc0201562:	00006517          	auipc	a0,0x6
ffffffffc0201566:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0206f90 <commands+0x720>
ffffffffc020156a:	c9ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020156e:	00006697          	auipc	a3,0x6
ffffffffc0201572:	afa68693          	addi	a3,a3,-1286 # ffffffffc0207068 <commands+0x7f8>
ffffffffc0201576:	00005617          	auipc	a2,0x5
ffffffffc020157a:	70a60613          	addi	a2,a2,1802 # ffffffffc0206c80 <commands+0x410>
ffffffffc020157e:	12000593          	li	a1,288
ffffffffc0201582:	00006517          	auipc	a0,0x6
ffffffffc0201586:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0206f90 <commands+0x720>
ffffffffc020158a:	c7ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma3 == NULL);
ffffffffc020158e:	00006697          	auipc	a3,0x6
ffffffffc0201592:	b4a68693          	addi	a3,a3,-1206 # ffffffffc02070d8 <commands+0x868>
ffffffffc0201596:	00005617          	auipc	a2,0x5
ffffffffc020159a:	6ea60613          	addi	a2,a2,1770 # ffffffffc0206c80 <commands+0x410>
ffffffffc020159e:	12c00593          	li	a1,300
ffffffffc02015a2:	00006517          	auipc	a0,0x6
ffffffffc02015a6:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0206f90 <commands+0x720>
ffffffffc02015aa:	c5ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2 != NULL);
ffffffffc02015ae:	00006697          	auipc	a3,0x6
ffffffffc02015b2:	b1a68693          	addi	a3,a3,-1254 # ffffffffc02070c8 <commands+0x858>
ffffffffc02015b6:	00005617          	auipc	a2,0x5
ffffffffc02015ba:	6ca60613          	addi	a2,a2,1738 # ffffffffc0206c80 <commands+0x410>
ffffffffc02015be:	12a00593          	li	a1,298
ffffffffc02015c2:	00006517          	auipc	a0,0x6
ffffffffc02015c6:	9ce50513          	addi	a0,a0,-1586 # ffffffffc0206f90 <commands+0x720>
ffffffffc02015ca:	c3ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1 != NULL);
ffffffffc02015ce:	00006697          	auipc	a3,0x6
ffffffffc02015d2:	aea68693          	addi	a3,a3,-1302 # ffffffffc02070b8 <commands+0x848>
ffffffffc02015d6:	00005617          	auipc	a2,0x5
ffffffffc02015da:	6aa60613          	addi	a2,a2,1706 # ffffffffc0206c80 <commands+0x410>
ffffffffc02015de:	12800593          	li	a1,296
ffffffffc02015e2:	00006517          	auipc	a0,0x6
ffffffffc02015e6:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0206f90 <commands+0x720>
ffffffffc02015ea:	c1ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma5 == NULL);
ffffffffc02015ee:	00006697          	auipc	a3,0x6
ffffffffc02015f2:	b0a68693          	addi	a3,a3,-1270 # ffffffffc02070f8 <commands+0x888>
ffffffffc02015f6:	00005617          	auipc	a2,0x5
ffffffffc02015fa:	68a60613          	addi	a2,a2,1674 # ffffffffc0206c80 <commands+0x410>
ffffffffc02015fe:	13000593          	li	a1,304
ffffffffc0201602:	00006517          	auipc	a0,0x6
ffffffffc0201606:	98e50513          	addi	a0,a0,-1650 # ffffffffc0206f90 <commands+0x720>
ffffffffc020160a:	bfffe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma4 == NULL);
ffffffffc020160e:	00006697          	auipc	a3,0x6
ffffffffc0201612:	ada68693          	addi	a3,a3,-1318 # ffffffffc02070e8 <commands+0x878>
ffffffffc0201616:	00005617          	auipc	a2,0x5
ffffffffc020161a:	66a60613          	addi	a2,a2,1642 # ffffffffc0206c80 <commands+0x410>
ffffffffc020161e:	12e00593          	li	a1,302
ffffffffc0201622:	00006517          	auipc	a0,0x6
ffffffffc0201626:	96e50513          	addi	a0,a0,-1682 # ffffffffc0206f90 <commands+0x720>
ffffffffc020162a:	bdffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020162e:	00006697          	auipc	a3,0x6
ffffffffc0201632:	b9a68693          	addi	a3,a3,-1126 # ffffffffc02071c8 <commands+0x958>
ffffffffc0201636:	00005617          	auipc	a2,0x5
ffffffffc020163a:	64a60613          	addi	a2,a2,1610 # ffffffffc0206c80 <commands+0x410>
ffffffffc020163e:	14b00593          	li	a1,331
ffffffffc0201642:	00006517          	auipc	a0,0x6
ffffffffc0201646:	94e50513          	addi	a0,a0,-1714 # ffffffffc0206f90 <commands+0x720>
ffffffffc020164a:	bbffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(mm != NULL);
ffffffffc020164e:	00006697          	auipc	a3,0x6
ffffffffc0201652:	9ca68693          	addi	a3,a3,-1590 # ffffffffc0207018 <commands+0x7a8>
ffffffffc0201656:	00005617          	auipc	a2,0x5
ffffffffc020165a:	62a60613          	addi	a2,a2,1578 # ffffffffc0206c80 <commands+0x410>
ffffffffc020165e:	10c00593          	li	a1,268
ffffffffc0201662:	00006517          	auipc	a0,0x6
ffffffffc0201666:	92e50513          	addi	a0,a0,-1746 # ffffffffc0206f90 <commands+0x720>
ffffffffc020166a:	b9ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020166e:	00006697          	auipc	a3,0x6
ffffffffc0201672:	c0a68693          	addi	a3,a3,-1014 # ffffffffc0207278 <commands+0xa08>
ffffffffc0201676:	00005617          	auipc	a2,0x5
ffffffffc020167a:	60a60613          	addi	a2,a2,1546 # ffffffffc0206c80 <commands+0x410>
ffffffffc020167e:	17000593          	li	a1,368
ffffffffc0201682:	00006517          	auipc	a0,0x6
ffffffffc0201686:	90e50513          	addi	a0,a0,-1778 # ffffffffc0206f90 <commands+0x720>
ffffffffc020168a:	b7ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc020168e:	00006617          	auipc	a2,0x6
ffffffffc0201692:	bc260613          	addi	a2,a2,-1086 # ffffffffc0207250 <commands+0x9e0>
ffffffffc0201696:	06900593          	li	a1,105
ffffffffc020169a:	00006517          	auipc	a0,0x6
ffffffffc020169e:	ba650513          	addi	a0,a0,-1114 # ffffffffc0207240 <commands+0x9d0>
ffffffffc02016a2:	b67fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02016a6:	00006697          	auipc	a3,0x6
ffffffffc02016aa:	b3a68693          	addi	a3,a3,-1222 # ffffffffc02071e0 <commands+0x970>
ffffffffc02016ae:	00005617          	auipc	a2,0x5
ffffffffc02016b2:	5d260613          	addi	a2,a2,1490 # ffffffffc0206c80 <commands+0x410>
ffffffffc02016b6:	14f00593          	li	a1,335
ffffffffc02016ba:	00006517          	auipc	a0,0x6
ffffffffc02016be:	8d650513          	addi	a0,a0,-1834 # ffffffffc0206f90 <commands+0x720>
ffffffffc02016c2:	b47fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02016c6:	00006697          	auipc	a3,0x6
ffffffffc02016ca:	b2a68693          	addi	a3,a3,-1238 # ffffffffc02071f0 <commands+0x980>
ffffffffc02016ce:	00005617          	auipc	a2,0x5
ffffffffc02016d2:	5b260613          	addi	a2,a2,1458 # ffffffffc0206c80 <commands+0x410>
ffffffffc02016d6:	15700593          	li	a1,343
ffffffffc02016da:	00006517          	auipc	a0,0x6
ffffffffc02016de:	8b650513          	addi	a0,a0,-1866 # ffffffffc0206f90 <commands+0x720>
ffffffffc02016e2:	b27fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02016e6:	00006617          	auipc	a2,0x6
ffffffffc02016ea:	b3a60613          	addi	a2,a2,-1222 # ffffffffc0207220 <commands+0x9b0>
ffffffffc02016ee:	06200593          	li	a1,98
ffffffffc02016f2:	00006517          	auipc	a0,0x6
ffffffffc02016f6:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0207240 <commands+0x9d0>
ffffffffc02016fa:	b0ffe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(sum == 0);
ffffffffc02016fe:	00006697          	auipc	a3,0x6
ffffffffc0201702:	b1268693          	addi	a3,a3,-1262 # ffffffffc0207210 <commands+0x9a0>
ffffffffc0201706:	00005617          	auipc	a2,0x5
ffffffffc020170a:	57a60613          	addi	a2,a2,1402 # ffffffffc0206c80 <commands+0x410>
ffffffffc020170e:	16300593          	li	a1,355
ffffffffc0201712:	00006517          	auipc	a0,0x6
ffffffffc0201716:	87e50513          	addi	a0,a0,-1922 # ffffffffc0206f90 <commands+0x720>
ffffffffc020171a:	aeffe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020171e <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020171e:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0201720:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201722:	f022                	sd	s0,32(sp)
ffffffffc0201724:	ec26                	sd	s1,24(sp)
ffffffffc0201726:	f406                	sd	ra,40(sp)
ffffffffc0201728:	e84a                	sd	s2,16(sp)
ffffffffc020172a:	8432                	mv	s0,a2
ffffffffc020172c:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020172e:	f8eff0ef          	jal	ra,ffffffffc0200ebc <find_vma>

    pgfault_num++;
ffffffffc0201732:	000b1797          	auipc	a5,0xb1
ffffffffc0201736:	0b67a783          	lw	a5,182(a5) # ffffffffc02b27e8 <pgfault_num>
ffffffffc020173a:	2785                	addiw	a5,a5,1
ffffffffc020173c:	000b1717          	auipc	a4,0xb1
ffffffffc0201740:	0af72623          	sw	a5,172(a4) # ffffffffc02b27e8 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201744:	c541                	beqz	a0,ffffffffc02017cc <do_pgfault+0xae>
ffffffffc0201746:	651c                	ld	a5,8(a0)
ffffffffc0201748:	08f46263          	bltu	s0,a5,ffffffffc02017cc <do_pgfault+0xae>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020174c:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020174e:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201750:	8b89                	andi	a5,a5,2
ffffffffc0201752:	ebb9                	bnez	a5,ffffffffc02017a8 <do_pgfault+0x8a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201754:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201756:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201758:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc020175a:	4605                	li	a2,1
ffffffffc020175c:	85a2                	mv	a1,s0
ffffffffc020175e:	5f5010ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc0201762:	c551                	beqz	a0,ffffffffc02017ee <do_pgfault+0xd0>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0201764:	610c                	ld	a1,0(a0)
ffffffffc0201766:	c1b9                	beqz	a1,ffffffffc02017ac <do_pgfault+0x8e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0201768:	000b1797          	auipc	a5,0xb1
ffffffffc020176c:	0a07a783          	lw	a5,160(a5) # ffffffffc02b2808 <swap_init_ok>
ffffffffc0201770:	c7bd                	beqz	a5,ffffffffc02017de <do_pgfault+0xc0>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm, addr, &page);
ffffffffc0201772:	85a2                	mv	a1,s0
ffffffffc0201774:	0030                	addi	a2,sp,8
ffffffffc0201776:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0201778:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc020177a:	16c010ef          	jal	ra,ffffffffc02028e6 <swap_in>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc020177e:	65a2                	ld	a1,8(sp)
ffffffffc0201780:	6c88                	ld	a0,24(s1)
ffffffffc0201782:	86ca                	mv	a3,s2
ffffffffc0201784:	8622                	mv	a2,s0
ffffffffc0201786:	466020ef          	jal	ra,ffffffffc0203bec <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc020178a:	6622                	ld	a2,8(sp)
ffffffffc020178c:	4685                	li	a3,1
ffffffffc020178e:	85a2                	mv	a1,s0
ffffffffc0201790:	8526                	mv	a0,s1
ffffffffc0201792:	034010ef          	jal	ra,ffffffffc02027c6 <swap_map_swappable>

            page->pra_vaddr = addr;
ffffffffc0201796:	67a2                	ld	a5,8(sp)
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc0201798:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc020179a:	ff80                	sd	s0,56(a5)
failed:
    return ret;
}
ffffffffc020179c:	70a2                	ld	ra,40(sp)
ffffffffc020179e:	7402                	ld	s0,32(sp)
ffffffffc02017a0:	64e2                	ld	s1,24(sp)
ffffffffc02017a2:	6942                	ld	s2,16(sp)
ffffffffc02017a4:	6145                	addi	sp,sp,48
ffffffffc02017a6:	8082                	ret
        perm |= READ_WRITE;
ffffffffc02017a8:	495d                	li	s2,23
ffffffffc02017aa:	b76d                	j	ffffffffc0201754 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02017ac:	6c88                	ld	a0,24(s1)
ffffffffc02017ae:	864a                	mv	a2,s2
ffffffffc02017b0:	85a2                	mv	a1,s0
ffffffffc02017b2:	300030ef          	jal	ra,ffffffffc0204ab2 <pgdir_alloc_page>
ffffffffc02017b6:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc02017b8:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02017ba:	f3ed                	bnez	a5,ffffffffc020179c <do_pgfault+0x7e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02017bc:	00006517          	auipc	a0,0x6
ffffffffc02017c0:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0207338 <commands+0xac8>
ffffffffc02017c4:	909fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02017c8:	5571                	li	a0,-4
            goto failed;
ffffffffc02017ca:	bfc9                	j	ffffffffc020179c <do_pgfault+0x7e>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc02017cc:	85a2                	mv	a1,s0
ffffffffc02017ce:	00006517          	auipc	a0,0x6
ffffffffc02017d2:	b1a50513          	addi	a0,a0,-1254 # ffffffffc02072e8 <commands+0xa78>
ffffffffc02017d6:	8f7fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = -E_INVAL;
ffffffffc02017da:	5575                	li	a0,-3
        goto failed;
ffffffffc02017dc:	b7c1                	j	ffffffffc020179c <do_pgfault+0x7e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02017de:	00006517          	auipc	a0,0x6
ffffffffc02017e2:	b8250513          	addi	a0,a0,-1150 # ffffffffc0207360 <commands+0xaf0>
ffffffffc02017e6:	8e7fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02017ea:	5571                	li	a0,-4
            goto failed;
ffffffffc02017ec:	bf45                	j	ffffffffc020179c <do_pgfault+0x7e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc02017ee:	00006517          	auipc	a0,0x6
ffffffffc02017f2:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0207318 <commands+0xaa8>
ffffffffc02017f6:	8d7fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02017fa:	5571                	li	a0,-4
        goto failed;
ffffffffc02017fc:	b745                	j	ffffffffc020179c <do_pgfault+0x7e>

ffffffffc02017fe <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc02017fe:	7179                	addi	sp,sp,-48
ffffffffc0201800:	f022                	sd	s0,32(sp)
ffffffffc0201802:	f406                	sd	ra,40(sp)
ffffffffc0201804:	ec26                	sd	s1,24(sp)
ffffffffc0201806:	e84a                	sd	s2,16(sp)
ffffffffc0201808:	e44e                	sd	s3,8(sp)
ffffffffc020180a:	e052                	sd	s4,0(sp)
ffffffffc020180c:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc020180e:	c135                	beqz	a0,ffffffffc0201872 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0201810:	002007b7          	lui	a5,0x200
ffffffffc0201814:	04f5e663          	bltu	a1,a5,ffffffffc0201860 <user_mem_check+0x62>
ffffffffc0201818:	00c584b3          	add	s1,a1,a2
ffffffffc020181c:	0495f263          	bgeu	a1,s1,ffffffffc0201860 <user_mem_check+0x62>
ffffffffc0201820:	4785                	li	a5,1
ffffffffc0201822:	07fe                	slli	a5,a5,0x1f
ffffffffc0201824:	0297ee63          	bltu	a5,s1,ffffffffc0201860 <user_mem_check+0x62>
ffffffffc0201828:	892a                	mv	s2,a0
ffffffffc020182a:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc020182c:	6a05                	lui	s4,0x1
ffffffffc020182e:	a821                	j	ffffffffc0201846 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201830:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0201834:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0201836:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201838:	c685                	beqz	a3,ffffffffc0201860 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc020183a:	c399                	beqz	a5,ffffffffc0201840 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc020183c:	02e46263          	bltu	s0,a4,ffffffffc0201860 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0201840:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0201842:	04947663          	bgeu	s0,s1,ffffffffc020188e <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0201846:	85a2                	mv	a1,s0
ffffffffc0201848:	854a                	mv	a0,s2
ffffffffc020184a:	e72ff0ef          	jal	ra,ffffffffc0200ebc <find_vma>
ffffffffc020184e:	c909                	beqz	a0,ffffffffc0201860 <user_mem_check+0x62>
ffffffffc0201850:	6518                	ld	a4,8(a0)
ffffffffc0201852:	00e46763          	bltu	s0,a4,ffffffffc0201860 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201856:	4d1c                	lw	a5,24(a0)
ffffffffc0201858:	fc099ce3          	bnez	s3,ffffffffc0201830 <user_mem_check+0x32>
ffffffffc020185c:	8b85                	andi	a5,a5,1
ffffffffc020185e:	f3ed                	bnez	a5,ffffffffc0201840 <user_mem_check+0x42>
            return 0;
ffffffffc0201860:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0201862:	70a2                	ld	ra,40(sp)
ffffffffc0201864:	7402                	ld	s0,32(sp)
ffffffffc0201866:	64e2                	ld	s1,24(sp)
ffffffffc0201868:	6942                	ld	s2,16(sp)
ffffffffc020186a:	69a2                	ld	s3,8(sp)
ffffffffc020186c:	6a02                	ld	s4,0(sp)
ffffffffc020186e:	6145                	addi	sp,sp,48
ffffffffc0201870:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0201872:	c02007b7          	lui	a5,0xc0200
ffffffffc0201876:	4501                	li	a0,0
ffffffffc0201878:	fef5e5e3          	bltu	a1,a5,ffffffffc0201862 <user_mem_check+0x64>
ffffffffc020187c:	962e                	add	a2,a2,a1
ffffffffc020187e:	fec5f2e3          	bgeu	a1,a2,ffffffffc0201862 <user_mem_check+0x64>
ffffffffc0201882:	c8000537          	lui	a0,0xc8000
ffffffffc0201886:	0505                	addi	a0,a0,1
ffffffffc0201888:	00a63533          	sltu	a0,a2,a0
ffffffffc020188c:	bfd9                	j	ffffffffc0201862 <user_mem_check+0x64>
        return 1;
ffffffffc020188e:	4505                	li	a0,1
ffffffffc0201890:	bfc9                	j	ffffffffc0201862 <user_mem_check+0x64>

ffffffffc0201892 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0201892:	000ad797          	auipc	a5,0xad
ffffffffc0201896:	e6e78793          	addi	a5,a5,-402 # ffffffffc02ae700 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc020189a:	f51c                	sd	a5,40(a0)
ffffffffc020189c:	e79c                	sd	a5,8(a5)
ffffffffc020189e:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02018a0:	4501                	li	a0,0
ffffffffc02018a2:	8082                	ret

ffffffffc02018a4 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc02018a4:	4501                	li	a0,0
ffffffffc02018a6:	8082                	ret

ffffffffc02018a8 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02018a8:	4501                	li	a0,0
ffffffffc02018aa:	8082                	ret

ffffffffc02018ac <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02018ac:	4501                	li	a0,0
ffffffffc02018ae:	8082                	ret

ffffffffc02018b0 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc02018b0:	711d                	addi	sp,sp,-96
ffffffffc02018b2:	fc4e                	sd	s3,56(sp)
ffffffffc02018b4:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02018b6:	00006517          	auipc	a0,0x6
ffffffffc02018ba:	ad250513          	addi	a0,a0,-1326 # ffffffffc0207388 <commands+0xb18>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02018be:	698d                	lui	s3,0x3
ffffffffc02018c0:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02018c2:	e0ca                	sd	s2,64(sp)
ffffffffc02018c4:	ec86                	sd	ra,88(sp)
ffffffffc02018c6:	e8a2                	sd	s0,80(sp)
ffffffffc02018c8:	e4a6                	sd	s1,72(sp)
ffffffffc02018ca:	f456                	sd	s5,40(sp)
ffffffffc02018cc:	f05a                	sd	s6,32(sp)
ffffffffc02018ce:	ec5e                	sd	s7,24(sp)
ffffffffc02018d0:	e862                	sd	s8,16(sp)
ffffffffc02018d2:	e466                	sd	s9,8(sp)
ffffffffc02018d4:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02018d6:	ff6fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02018da:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb0>
    assert(pgfault_num==4);
ffffffffc02018de:	000b1917          	auipc	s2,0xb1
ffffffffc02018e2:	f0a92903          	lw	s2,-246(s2) # ffffffffc02b27e8 <pgfault_num>
ffffffffc02018e6:	4791                	li	a5,4
ffffffffc02018e8:	14f91e63          	bne	s2,a5,ffffffffc0201a44 <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02018ec:	00006517          	auipc	a0,0x6
ffffffffc02018f0:	aec50513          	addi	a0,a0,-1300 # ffffffffc02073d8 <commands+0xb68>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02018f4:	6a85                	lui	s5,0x1
ffffffffc02018f6:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02018f8:	fd4fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc02018fc:	000b1417          	auipc	s0,0xb1
ffffffffc0201900:	eec40413          	addi	s0,s0,-276 # ffffffffc02b27e8 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201904:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
    assert(pgfault_num==4);
ffffffffc0201908:	4004                	lw	s1,0(s0)
ffffffffc020190a:	2481                	sext.w	s1,s1
ffffffffc020190c:	2b249c63          	bne	s1,s2,ffffffffc0201bc4 <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201910:	00006517          	auipc	a0,0x6
ffffffffc0201914:	af050513          	addi	a0,a0,-1296 # ffffffffc0207400 <commands+0xb90>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201918:	6b91                	lui	s7,0x4
ffffffffc020191a:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020191c:	fb0fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201920:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5bb0>
    assert(pgfault_num==4);
ffffffffc0201924:	00042903          	lw	s2,0(s0)
ffffffffc0201928:	2901                	sext.w	s2,s2
ffffffffc020192a:	26991d63          	bne	s2,s1,ffffffffc0201ba4 <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020192e:	00006517          	auipc	a0,0x6
ffffffffc0201932:	afa50513          	addi	a0,a0,-1286 # ffffffffc0207428 <commands+0xbb8>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201936:	6c89                	lui	s9,0x2
ffffffffc0201938:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020193a:	f92fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020193e:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7bb0>
    assert(pgfault_num==4);
ffffffffc0201942:	401c                	lw	a5,0(s0)
ffffffffc0201944:	2781                	sext.w	a5,a5
ffffffffc0201946:	23279f63          	bne	a5,s2,ffffffffc0201b84 <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc020194a:	00006517          	auipc	a0,0x6
ffffffffc020194e:	b0650513          	addi	a0,a0,-1274 # ffffffffc0207450 <commands+0xbe0>
ffffffffc0201952:	f7afe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201956:	6795                	lui	a5,0x5
ffffffffc0201958:	4739                	li	a4,14
ffffffffc020195a:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb0>
    assert(pgfault_num==5);
ffffffffc020195e:	4004                	lw	s1,0(s0)
ffffffffc0201960:	4795                	li	a5,5
ffffffffc0201962:	2481                	sext.w	s1,s1
ffffffffc0201964:	20f49063          	bne	s1,a5,ffffffffc0201b64 <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201968:	00006517          	auipc	a0,0x6
ffffffffc020196c:	ac050513          	addi	a0,a0,-1344 # ffffffffc0207428 <commands+0xbb8>
ffffffffc0201970:	f5cfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201974:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0201978:	401c                	lw	a5,0(s0)
ffffffffc020197a:	2781                	sext.w	a5,a5
ffffffffc020197c:	1c979463          	bne	a5,s1,ffffffffc0201b44 <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201980:	00006517          	auipc	a0,0x6
ffffffffc0201984:	a5850513          	addi	a0,a0,-1448 # ffffffffc02073d8 <commands+0xb68>
ffffffffc0201988:	f44fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020198c:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0201990:	401c                	lw	a5,0(s0)
ffffffffc0201992:	4719                	li	a4,6
ffffffffc0201994:	2781                	sext.w	a5,a5
ffffffffc0201996:	18e79763          	bne	a5,a4,ffffffffc0201b24 <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020199a:	00006517          	auipc	a0,0x6
ffffffffc020199e:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0207428 <commands+0xbb8>
ffffffffc02019a2:	f2afe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02019a6:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc02019aa:	401c                	lw	a5,0(s0)
ffffffffc02019ac:	471d                	li	a4,7
ffffffffc02019ae:	2781                	sext.w	a5,a5
ffffffffc02019b0:	14e79a63          	bne	a5,a4,ffffffffc0201b04 <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02019b4:	00006517          	auipc	a0,0x6
ffffffffc02019b8:	9d450513          	addi	a0,a0,-1580 # ffffffffc0207388 <commands+0xb18>
ffffffffc02019bc:	f10fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02019c0:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02019c4:	401c                	lw	a5,0(s0)
ffffffffc02019c6:	4721                	li	a4,8
ffffffffc02019c8:	2781                	sext.w	a5,a5
ffffffffc02019ca:	10e79d63          	bne	a5,a4,ffffffffc0201ae4 <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02019ce:	00006517          	auipc	a0,0x6
ffffffffc02019d2:	a3250513          	addi	a0,a0,-1486 # ffffffffc0207400 <commands+0xb90>
ffffffffc02019d6:	ef6fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02019da:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02019de:	401c                	lw	a5,0(s0)
ffffffffc02019e0:	4725                	li	a4,9
ffffffffc02019e2:	2781                	sext.w	a5,a5
ffffffffc02019e4:	0ee79063          	bne	a5,a4,ffffffffc0201ac4 <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02019e8:	00006517          	auipc	a0,0x6
ffffffffc02019ec:	a6850513          	addi	a0,a0,-1432 # ffffffffc0207450 <commands+0xbe0>
ffffffffc02019f0:	edcfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02019f4:	6795                	lui	a5,0x5
ffffffffc02019f6:	4739                	li	a4,14
ffffffffc02019f8:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb0>
    assert(pgfault_num==10);
ffffffffc02019fc:	4004                	lw	s1,0(s0)
ffffffffc02019fe:	47a9                	li	a5,10
ffffffffc0201a00:	2481                	sext.w	s1,s1
ffffffffc0201a02:	0af49163          	bne	s1,a5,ffffffffc0201aa4 <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201a06:	00006517          	auipc	a0,0x6
ffffffffc0201a0a:	9d250513          	addi	a0,a0,-1582 # ffffffffc02073d8 <commands+0xb68>
ffffffffc0201a0e:	ebefe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201a12:	6785                	lui	a5,0x1
ffffffffc0201a14:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0201a18:	06979663          	bne	a5,s1,ffffffffc0201a84 <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0201a1c:	401c                	lw	a5,0(s0)
ffffffffc0201a1e:	472d                	li	a4,11
ffffffffc0201a20:	2781                	sext.w	a5,a5
ffffffffc0201a22:	04e79163          	bne	a5,a4,ffffffffc0201a64 <_fifo_check_swap+0x1b4>
}
ffffffffc0201a26:	60e6                	ld	ra,88(sp)
ffffffffc0201a28:	6446                	ld	s0,80(sp)
ffffffffc0201a2a:	64a6                	ld	s1,72(sp)
ffffffffc0201a2c:	6906                	ld	s2,64(sp)
ffffffffc0201a2e:	79e2                	ld	s3,56(sp)
ffffffffc0201a30:	7a42                	ld	s4,48(sp)
ffffffffc0201a32:	7aa2                	ld	s5,40(sp)
ffffffffc0201a34:	7b02                	ld	s6,32(sp)
ffffffffc0201a36:	6be2                	ld	s7,24(sp)
ffffffffc0201a38:	6c42                	ld	s8,16(sp)
ffffffffc0201a3a:	6ca2                	ld	s9,8(sp)
ffffffffc0201a3c:	6d02                	ld	s10,0(sp)
ffffffffc0201a3e:	4501                	li	a0,0
ffffffffc0201a40:	6125                	addi	sp,sp,96
ffffffffc0201a42:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0201a44:	00006697          	auipc	a3,0x6
ffffffffc0201a48:	96c68693          	addi	a3,a3,-1684 # ffffffffc02073b0 <commands+0xb40>
ffffffffc0201a4c:	00005617          	auipc	a2,0x5
ffffffffc0201a50:	23460613          	addi	a2,a2,564 # ffffffffc0206c80 <commands+0x410>
ffffffffc0201a54:	05100593          	li	a1,81
ffffffffc0201a58:	00006517          	auipc	a0,0x6
ffffffffc0201a5c:	96850513          	addi	a0,a0,-1688 # ffffffffc02073c0 <commands+0xb50>
ffffffffc0201a60:	fa8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==11);
ffffffffc0201a64:	00006697          	auipc	a3,0x6
ffffffffc0201a68:	a9c68693          	addi	a3,a3,-1380 # ffffffffc0207500 <commands+0xc90>
ffffffffc0201a6c:	00005617          	auipc	a2,0x5
ffffffffc0201a70:	21460613          	addi	a2,a2,532 # ffffffffc0206c80 <commands+0x410>
ffffffffc0201a74:	07300593          	li	a1,115
ffffffffc0201a78:	00006517          	auipc	a0,0x6
ffffffffc0201a7c:	94850513          	addi	a0,a0,-1720 # ffffffffc02073c0 <commands+0xb50>
ffffffffc0201a80:	f88fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201a84:	00006697          	auipc	a3,0x6
ffffffffc0201a88:	a5468693          	addi	a3,a3,-1452 # ffffffffc02074d8 <commands+0xc68>
ffffffffc0201a8c:	00005617          	auipc	a2,0x5
ffffffffc0201a90:	1f460613          	addi	a2,a2,500 # ffffffffc0206c80 <commands+0x410>
ffffffffc0201a94:	07100593          	li	a1,113
ffffffffc0201a98:	00006517          	auipc	a0,0x6
ffffffffc0201a9c:	92850513          	addi	a0,a0,-1752 # ffffffffc02073c0 <commands+0xb50>
ffffffffc0201aa0:	f68fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==10);
ffffffffc0201aa4:	00006697          	auipc	a3,0x6
ffffffffc0201aa8:	a2468693          	addi	a3,a3,-1500 # ffffffffc02074c8 <commands+0xc58>
ffffffffc0201aac:	00005617          	auipc	a2,0x5
ffffffffc0201ab0:	1d460613          	addi	a2,a2,468 # ffffffffc0206c80 <commands+0x410>
ffffffffc0201ab4:	06f00593          	li	a1,111
ffffffffc0201ab8:	00006517          	auipc	a0,0x6
ffffffffc0201abc:	90850513          	addi	a0,a0,-1784 # ffffffffc02073c0 <commands+0xb50>
ffffffffc0201ac0:	f48fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==9);
ffffffffc0201ac4:	00006697          	auipc	a3,0x6
ffffffffc0201ac8:	9f468693          	addi	a3,a3,-1548 # ffffffffc02074b8 <commands+0xc48>
ffffffffc0201acc:	00005617          	auipc	a2,0x5
ffffffffc0201ad0:	1b460613          	addi	a2,a2,436 # ffffffffc0206c80 <commands+0x410>
ffffffffc0201ad4:	06c00593          	li	a1,108
ffffffffc0201ad8:	00006517          	auipc	a0,0x6
ffffffffc0201adc:	8e850513          	addi	a0,a0,-1816 # ffffffffc02073c0 <commands+0xb50>
ffffffffc0201ae0:	f28fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==8);
ffffffffc0201ae4:	00006697          	auipc	a3,0x6
ffffffffc0201ae8:	9c468693          	addi	a3,a3,-1596 # ffffffffc02074a8 <commands+0xc38>
ffffffffc0201aec:	00005617          	auipc	a2,0x5
ffffffffc0201af0:	19460613          	addi	a2,a2,404 # ffffffffc0206c80 <commands+0x410>
ffffffffc0201af4:	06900593          	li	a1,105
ffffffffc0201af8:	00006517          	auipc	a0,0x6
ffffffffc0201afc:	8c850513          	addi	a0,a0,-1848 # ffffffffc02073c0 <commands+0xb50>
ffffffffc0201b00:	f08fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==7);
ffffffffc0201b04:	00006697          	auipc	a3,0x6
ffffffffc0201b08:	99468693          	addi	a3,a3,-1644 # ffffffffc0207498 <commands+0xc28>
ffffffffc0201b0c:	00005617          	auipc	a2,0x5
ffffffffc0201b10:	17460613          	addi	a2,a2,372 # ffffffffc0206c80 <commands+0x410>
ffffffffc0201b14:	06600593          	li	a1,102
ffffffffc0201b18:	00006517          	auipc	a0,0x6
ffffffffc0201b1c:	8a850513          	addi	a0,a0,-1880 # ffffffffc02073c0 <commands+0xb50>
ffffffffc0201b20:	ee8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==6);
ffffffffc0201b24:	00006697          	auipc	a3,0x6
ffffffffc0201b28:	96468693          	addi	a3,a3,-1692 # ffffffffc0207488 <commands+0xc18>
ffffffffc0201b2c:	00005617          	auipc	a2,0x5
ffffffffc0201b30:	15460613          	addi	a2,a2,340 # ffffffffc0206c80 <commands+0x410>
ffffffffc0201b34:	06300593          	li	a1,99
ffffffffc0201b38:	00006517          	auipc	a0,0x6
ffffffffc0201b3c:	88850513          	addi	a0,a0,-1912 # ffffffffc02073c0 <commands+0xb50>
ffffffffc0201b40:	ec8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc0201b44:	00006697          	auipc	a3,0x6
ffffffffc0201b48:	93468693          	addi	a3,a3,-1740 # ffffffffc0207478 <commands+0xc08>
ffffffffc0201b4c:	00005617          	auipc	a2,0x5
ffffffffc0201b50:	13460613          	addi	a2,a2,308 # ffffffffc0206c80 <commands+0x410>
ffffffffc0201b54:	06000593          	li	a1,96
ffffffffc0201b58:	00006517          	auipc	a0,0x6
ffffffffc0201b5c:	86850513          	addi	a0,a0,-1944 # ffffffffc02073c0 <commands+0xb50>
ffffffffc0201b60:	ea8fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc0201b64:	00006697          	auipc	a3,0x6
ffffffffc0201b68:	91468693          	addi	a3,a3,-1772 # ffffffffc0207478 <commands+0xc08>
ffffffffc0201b6c:	00005617          	auipc	a2,0x5
ffffffffc0201b70:	11460613          	addi	a2,a2,276 # ffffffffc0206c80 <commands+0x410>
ffffffffc0201b74:	05d00593          	li	a1,93
ffffffffc0201b78:	00006517          	auipc	a0,0x6
ffffffffc0201b7c:	84850513          	addi	a0,a0,-1976 # ffffffffc02073c0 <commands+0xb50>
ffffffffc0201b80:	e88fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0201b84:	00006697          	auipc	a3,0x6
ffffffffc0201b88:	82c68693          	addi	a3,a3,-2004 # ffffffffc02073b0 <commands+0xb40>
ffffffffc0201b8c:	00005617          	auipc	a2,0x5
ffffffffc0201b90:	0f460613          	addi	a2,a2,244 # ffffffffc0206c80 <commands+0x410>
ffffffffc0201b94:	05a00593          	li	a1,90
ffffffffc0201b98:	00006517          	auipc	a0,0x6
ffffffffc0201b9c:	82850513          	addi	a0,a0,-2008 # ffffffffc02073c0 <commands+0xb50>
ffffffffc0201ba0:	e68fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0201ba4:	00006697          	auipc	a3,0x6
ffffffffc0201ba8:	80c68693          	addi	a3,a3,-2036 # ffffffffc02073b0 <commands+0xb40>
ffffffffc0201bac:	00005617          	auipc	a2,0x5
ffffffffc0201bb0:	0d460613          	addi	a2,a2,212 # ffffffffc0206c80 <commands+0x410>
ffffffffc0201bb4:	05700593          	li	a1,87
ffffffffc0201bb8:	00006517          	auipc	a0,0x6
ffffffffc0201bbc:	80850513          	addi	a0,a0,-2040 # ffffffffc02073c0 <commands+0xb50>
ffffffffc0201bc0:	e48fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0201bc4:	00005697          	auipc	a3,0x5
ffffffffc0201bc8:	7ec68693          	addi	a3,a3,2028 # ffffffffc02073b0 <commands+0xb40>
ffffffffc0201bcc:	00005617          	auipc	a2,0x5
ffffffffc0201bd0:	0b460613          	addi	a2,a2,180 # ffffffffc0206c80 <commands+0x410>
ffffffffc0201bd4:	05400593          	li	a1,84
ffffffffc0201bd8:	00005517          	auipc	a0,0x5
ffffffffc0201bdc:	7e850513          	addi	a0,a0,2024 # ffffffffc02073c0 <commands+0xb50>
ffffffffc0201be0:	e28fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201be4 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201be4:	751c                	ld	a5,40(a0)
{
ffffffffc0201be6:	1141                	addi	sp,sp,-16
ffffffffc0201be8:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0201bea:	cf91                	beqz	a5,ffffffffc0201c06 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0201bec:	ee0d                	bnez	a2,ffffffffc0201c26 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0201bee:	679c                	ld	a5,8(a5)
}
ffffffffc0201bf0:	60a2                	ld	ra,8(sp)
ffffffffc0201bf2:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0201bf4:	6394                	ld	a3,0(a5)
ffffffffc0201bf6:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0201bf8:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0201bfc:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0201bfe:	e314                	sd	a3,0(a4)
ffffffffc0201c00:	e19c                	sd	a5,0(a1)
}
ffffffffc0201c02:	0141                	addi	sp,sp,16
ffffffffc0201c04:	8082                	ret
         assert(head != NULL);
ffffffffc0201c06:	00006697          	auipc	a3,0x6
ffffffffc0201c0a:	90a68693          	addi	a3,a3,-1782 # ffffffffc0207510 <commands+0xca0>
ffffffffc0201c0e:	00005617          	auipc	a2,0x5
ffffffffc0201c12:	07260613          	addi	a2,a2,114 # ffffffffc0206c80 <commands+0x410>
ffffffffc0201c16:	04100593          	li	a1,65
ffffffffc0201c1a:	00005517          	auipc	a0,0x5
ffffffffc0201c1e:	7a650513          	addi	a0,a0,1958 # ffffffffc02073c0 <commands+0xb50>
ffffffffc0201c22:	de6fe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(in_tick==0);
ffffffffc0201c26:	00006697          	auipc	a3,0x6
ffffffffc0201c2a:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0207520 <commands+0xcb0>
ffffffffc0201c2e:	00005617          	auipc	a2,0x5
ffffffffc0201c32:	05260613          	addi	a2,a2,82 # ffffffffc0206c80 <commands+0x410>
ffffffffc0201c36:	04200593          	li	a1,66
ffffffffc0201c3a:	00005517          	auipc	a0,0x5
ffffffffc0201c3e:	78650513          	addi	a0,a0,1926 # ffffffffc02073c0 <commands+0xb50>
ffffffffc0201c42:	dc6fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201c46 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201c46:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0201c48:	cb91                	beqz	a5,ffffffffc0201c5c <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201c4a:	6394                	ld	a3,0(a5)
ffffffffc0201c4c:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc0201c50:	e398                	sd	a4,0(a5)
ffffffffc0201c52:	e698                	sd	a4,8(a3)
}
ffffffffc0201c54:	4501                	li	a0,0
    elm->next = next;
ffffffffc0201c56:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0201c58:	f614                	sd	a3,40(a2)
ffffffffc0201c5a:	8082                	ret
{
ffffffffc0201c5c:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0201c5e:	00006697          	auipc	a3,0x6
ffffffffc0201c62:	8d268693          	addi	a3,a3,-1838 # ffffffffc0207530 <commands+0xcc0>
ffffffffc0201c66:	00005617          	auipc	a2,0x5
ffffffffc0201c6a:	01a60613          	addi	a2,a2,26 # ffffffffc0206c80 <commands+0x410>
ffffffffc0201c6e:	03200593          	li	a1,50
ffffffffc0201c72:	00005517          	auipc	a0,0x5
ffffffffc0201c76:	74e50513          	addi	a0,a0,1870 # ffffffffc02073c0 <commands+0xb50>
{
ffffffffc0201c7a:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0201c7c:	d8cfe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201c80 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201c80:	c94d                	beqz	a0,ffffffffc0201d32 <slob_free+0xb2>
{
ffffffffc0201c82:	1141                	addi	sp,sp,-16
ffffffffc0201c84:	e022                	sd	s0,0(sp)
ffffffffc0201c86:	e406                	sd	ra,8(sp)
ffffffffc0201c88:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201c8a:	e9c1                	bnez	a1,ffffffffc0201d1a <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c8c:	100027f3          	csrr	a5,sstatus
ffffffffc0201c90:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201c92:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c94:	ebd9                	bnez	a5,ffffffffc0201d2a <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201c96:	000a5617          	auipc	a2,0xa5
ffffffffc0201c9a:	65a60613          	addi	a2,a2,1626 # ffffffffc02a72f0 <slobfree>
ffffffffc0201c9e:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201ca0:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201ca2:	679c                	ld	a5,8(a5)
ffffffffc0201ca4:	02877a63          	bgeu	a4,s0,ffffffffc0201cd8 <slob_free+0x58>
ffffffffc0201ca8:	00f46463          	bltu	s0,a5,ffffffffc0201cb0 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201cac:	fef76ae3          	bltu	a4,a5,ffffffffc0201ca0 <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201cb0:	400c                	lw	a1,0(s0)
ffffffffc0201cb2:	00459693          	slli	a3,a1,0x4
ffffffffc0201cb6:	96a2                	add	a3,a3,s0
ffffffffc0201cb8:	02d78a63          	beq	a5,a3,ffffffffc0201cec <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201cbc:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201cbe:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201cc0:	00469793          	slli	a5,a3,0x4
ffffffffc0201cc4:	97ba                	add	a5,a5,a4
ffffffffc0201cc6:	02f40e63          	beq	s0,a5,ffffffffc0201d02 <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201cca:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201ccc:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc0201cce:	e129                	bnez	a0,ffffffffc0201d10 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201cd0:	60a2                	ld	ra,8(sp)
ffffffffc0201cd2:	6402                	ld	s0,0(sp)
ffffffffc0201cd4:	0141                	addi	sp,sp,16
ffffffffc0201cd6:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201cd8:	fcf764e3          	bltu	a4,a5,ffffffffc0201ca0 <slob_free+0x20>
ffffffffc0201cdc:	fcf472e3          	bgeu	s0,a5,ffffffffc0201ca0 <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc0201ce0:	400c                	lw	a1,0(s0)
ffffffffc0201ce2:	00459693          	slli	a3,a1,0x4
ffffffffc0201ce6:	96a2                	add	a3,a3,s0
ffffffffc0201ce8:	fcd79ae3          	bne	a5,a3,ffffffffc0201cbc <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201cec:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201cee:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201cf0:	9db5                	addw	a1,a1,a3
ffffffffc0201cf2:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc0201cf4:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201cf6:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201cf8:	00469793          	slli	a5,a3,0x4
ffffffffc0201cfc:	97ba                	add	a5,a5,a4
ffffffffc0201cfe:	fcf416e3          	bne	s0,a5,ffffffffc0201cca <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201d02:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201d04:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201d06:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201d08:	9ebd                	addw	a3,a3,a5
ffffffffc0201d0a:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201d0c:	e70c                	sd	a1,8(a4)
ffffffffc0201d0e:	d169                	beqz	a0,ffffffffc0201cd0 <slob_free+0x50>
}
ffffffffc0201d10:	6402                	ld	s0,0(sp)
ffffffffc0201d12:	60a2                	ld	ra,8(sp)
ffffffffc0201d14:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201d16:	92dfe06f          	j	ffffffffc0200642 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201d1a:	25bd                	addiw	a1,a1,15
ffffffffc0201d1c:	8191                	srli	a1,a1,0x4
ffffffffc0201d1e:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d20:	100027f3          	csrr	a5,sstatus
ffffffffc0201d24:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201d26:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d28:	d7bd                	beqz	a5,ffffffffc0201c96 <slob_free+0x16>
        intr_disable();
ffffffffc0201d2a:	91ffe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0201d2e:	4505                	li	a0,1
ffffffffc0201d30:	b79d                	j	ffffffffc0201c96 <slob_free+0x16>
ffffffffc0201d32:	8082                	ret

ffffffffc0201d34 <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201d34:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201d36:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201d38:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201d3c:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201d3e:	708010ef          	jal	ra,ffffffffc0203446 <alloc_pages>
  if(!page)
ffffffffc0201d42:	c91d                	beqz	a0,ffffffffc0201d78 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201d44:	000b1697          	auipc	a3,0xb1
ffffffffc0201d48:	ae46b683          	ld	a3,-1308(a3) # ffffffffc02b2828 <pages>
ffffffffc0201d4c:	8d15                	sub	a0,a0,a3
ffffffffc0201d4e:	8519                	srai	a0,a0,0x6
ffffffffc0201d50:	00007697          	auipc	a3,0x7
ffffffffc0201d54:	f506b683          	ld	a3,-176(a3) # ffffffffc0208ca0 <nbase>
ffffffffc0201d58:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201d5a:	00c51793          	slli	a5,a0,0xc
ffffffffc0201d5e:	83b1                	srli	a5,a5,0xc
ffffffffc0201d60:	000b1717          	auipc	a4,0xb1
ffffffffc0201d64:	ac073703          	ld	a4,-1344(a4) # ffffffffc02b2820 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201d68:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201d6a:	00e7fa63          	bgeu	a5,a4,ffffffffc0201d7e <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201d6e:	000b1697          	auipc	a3,0xb1
ffffffffc0201d72:	aca6b683          	ld	a3,-1334(a3) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0201d76:	9536                	add	a0,a0,a3
}
ffffffffc0201d78:	60a2                	ld	ra,8(sp)
ffffffffc0201d7a:	0141                	addi	sp,sp,16
ffffffffc0201d7c:	8082                	ret
ffffffffc0201d7e:	86aa                	mv	a3,a0
ffffffffc0201d80:	00005617          	auipc	a2,0x5
ffffffffc0201d84:	4d060613          	addi	a2,a2,1232 # ffffffffc0207250 <commands+0x9e0>
ffffffffc0201d88:	06900593          	li	a1,105
ffffffffc0201d8c:	00005517          	auipc	a0,0x5
ffffffffc0201d90:	4b450513          	addi	a0,a0,1204 # ffffffffc0207240 <commands+0x9d0>
ffffffffc0201d94:	c74fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201d98 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201d98:	1101                	addi	sp,sp,-32
ffffffffc0201d9a:	ec06                	sd	ra,24(sp)
ffffffffc0201d9c:	e822                	sd	s0,16(sp)
ffffffffc0201d9e:	e426                	sd	s1,8(sp)
ffffffffc0201da0:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201da2:	01050713          	addi	a4,a0,16
ffffffffc0201da6:	6785                	lui	a5,0x1
ffffffffc0201da8:	0cf77363          	bgeu	a4,a5,ffffffffc0201e6e <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201dac:	00f50493          	addi	s1,a0,15
ffffffffc0201db0:	8091                	srli	s1,s1,0x4
ffffffffc0201db2:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201db4:	10002673          	csrr	a2,sstatus
ffffffffc0201db8:	8a09                	andi	a2,a2,2
ffffffffc0201dba:	e25d                	bnez	a2,ffffffffc0201e60 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201dbc:	000a5917          	auipc	s2,0xa5
ffffffffc0201dc0:	53490913          	addi	s2,s2,1332 # ffffffffc02a72f0 <slobfree>
ffffffffc0201dc4:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201dc8:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201dca:	4398                	lw	a4,0(a5)
ffffffffc0201dcc:	08975e63          	bge	a4,s1,ffffffffc0201e68 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0201dd0:	00f68b63          	beq	a3,a5,ffffffffc0201de6 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201dd4:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201dd6:	4018                	lw	a4,0(s0)
ffffffffc0201dd8:	02975a63          	bge	a4,s1,ffffffffc0201e0c <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0201ddc:	00093683          	ld	a3,0(s2)
ffffffffc0201de0:	87a2                	mv	a5,s0
ffffffffc0201de2:	fef699e3          	bne	a3,a5,ffffffffc0201dd4 <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0201de6:	ee31                	bnez	a2,ffffffffc0201e42 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201de8:	4501                	li	a0,0
ffffffffc0201dea:	f4bff0ef          	jal	ra,ffffffffc0201d34 <__slob_get_free_pages.constprop.0>
ffffffffc0201dee:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201df0:	cd05                	beqz	a0,ffffffffc0201e28 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201df2:	6585                	lui	a1,0x1
ffffffffc0201df4:	e8dff0ef          	jal	ra,ffffffffc0201c80 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201df8:	10002673          	csrr	a2,sstatus
ffffffffc0201dfc:	8a09                	andi	a2,a2,2
ffffffffc0201dfe:	ee05                	bnez	a2,ffffffffc0201e36 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201e00:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201e04:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201e06:	4018                	lw	a4,0(s0)
ffffffffc0201e08:	fc974ae3          	blt	a4,s1,ffffffffc0201ddc <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201e0c:	04e48763          	beq	s1,a4,ffffffffc0201e5a <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201e10:	00449693          	slli	a3,s1,0x4
ffffffffc0201e14:	96a2                	add	a3,a3,s0
ffffffffc0201e16:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201e18:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201e1a:	9f05                	subw	a4,a4,s1
ffffffffc0201e1c:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201e1e:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201e20:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201e22:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0201e26:	e20d                	bnez	a2,ffffffffc0201e48 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201e28:	60e2                	ld	ra,24(sp)
ffffffffc0201e2a:	8522                	mv	a0,s0
ffffffffc0201e2c:	6442                	ld	s0,16(sp)
ffffffffc0201e2e:	64a2                	ld	s1,8(sp)
ffffffffc0201e30:	6902                	ld	s2,0(sp)
ffffffffc0201e32:	6105                	addi	sp,sp,32
ffffffffc0201e34:	8082                	ret
        intr_disable();
ffffffffc0201e36:	813fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
			cur = slobfree;
ffffffffc0201e3a:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201e3e:	4605                	li	a2,1
ffffffffc0201e40:	b7d1                	j	ffffffffc0201e04 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201e42:	801fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0201e46:	b74d                	j	ffffffffc0201de8 <slob_alloc.constprop.0+0x50>
ffffffffc0201e48:	ffafe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
}
ffffffffc0201e4c:	60e2                	ld	ra,24(sp)
ffffffffc0201e4e:	8522                	mv	a0,s0
ffffffffc0201e50:	6442                	ld	s0,16(sp)
ffffffffc0201e52:	64a2                	ld	s1,8(sp)
ffffffffc0201e54:	6902                	ld	s2,0(sp)
ffffffffc0201e56:	6105                	addi	sp,sp,32
ffffffffc0201e58:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201e5a:	6418                	ld	a4,8(s0)
ffffffffc0201e5c:	e798                	sd	a4,8(a5)
ffffffffc0201e5e:	b7d1                	j	ffffffffc0201e22 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201e60:	fe8fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0201e64:	4605                	li	a2,1
ffffffffc0201e66:	bf99                	j	ffffffffc0201dbc <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201e68:	843e                	mv	s0,a5
ffffffffc0201e6a:	87b6                	mv	a5,a3
ffffffffc0201e6c:	b745                	j	ffffffffc0201e0c <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201e6e:	00005697          	auipc	a3,0x5
ffffffffc0201e72:	6fa68693          	addi	a3,a3,1786 # ffffffffc0207568 <commands+0xcf8>
ffffffffc0201e76:	00005617          	auipc	a2,0x5
ffffffffc0201e7a:	e0a60613          	addi	a2,a2,-502 # ffffffffc0206c80 <commands+0x410>
ffffffffc0201e7e:	06400593          	li	a1,100
ffffffffc0201e82:	00005517          	auipc	a0,0x5
ffffffffc0201e86:	70650513          	addi	a0,a0,1798 # ffffffffc0207588 <commands+0xd18>
ffffffffc0201e8a:	b7efe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201e8e <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201e8e:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201e90:	00005517          	auipc	a0,0x5
ffffffffc0201e94:	71050513          	addi	a0,a0,1808 # ffffffffc02075a0 <commands+0xd30>
kmalloc_init(void) {
ffffffffc0201e98:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201e9a:	a32fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201e9e:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201ea0:	00005517          	auipc	a0,0x5
ffffffffc0201ea4:	71850513          	addi	a0,a0,1816 # ffffffffc02075b8 <commands+0xd48>
}
ffffffffc0201ea8:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201eaa:	a22fe06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0201eae <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201eae:	4501                	li	a0,0
ffffffffc0201eb0:	8082                	ret

ffffffffc0201eb2 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201eb2:	1101                	addi	sp,sp,-32
ffffffffc0201eb4:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201eb6:	6905                	lui	s2,0x1
{
ffffffffc0201eb8:	e822                	sd	s0,16(sp)
ffffffffc0201eba:	ec06                	sd	ra,24(sp)
ffffffffc0201ebc:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201ebe:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bc1>
{
ffffffffc0201ec2:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201ec4:	04a7f963          	bgeu	a5,a0,ffffffffc0201f16 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201ec8:	4561                	li	a0,24
ffffffffc0201eca:	ecfff0ef          	jal	ra,ffffffffc0201d98 <slob_alloc.constprop.0>
ffffffffc0201ece:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201ed0:	c929                	beqz	a0,ffffffffc0201f22 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201ed2:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201ed6:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201ed8:	00f95763          	bge	s2,a5,ffffffffc0201ee6 <kmalloc+0x34>
ffffffffc0201edc:	6705                	lui	a4,0x1
ffffffffc0201ede:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201ee0:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201ee2:	fef74ee3          	blt	a4,a5,ffffffffc0201ede <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201ee6:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201ee8:	e4dff0ef          	jal	ra,ffffffffc0201d34 <__slob_get_free_pages.constprop.0>
ffffffffc0201eec:	e488                	sd	a0,8(s1)
ffffffffc0201eee:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201ef0:	c525                	beqz	a0,ffffffffc0201f58 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ef2:	100027f3          	csrr	a5,sstatus
ffffffffc0201ef6:	8b89                	andi	a5,a5,2
ffffffffc0201ef8:	ef8d                	bnez	a5,ffffffffc0201f32 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201efa:	000b1797          	auipc	a5,0xb1
ffffffffc0201efe:	8f678793          	addi	a5,a5,-1802 # ffffffffc02b27f0 <bigblocks>
ffffffffc0201f02:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201f04:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201f06:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201f08:	60e2                	ld	ra,24(sp)
ffffffffc0201f0a:	8522                	mv	a0,s0
ffffffffc0201f0c:	6442                	ld	s0,16(sp)
ffffffffc0201f0e:	64a2                	ld	s1,8(sp)
ffffffffc0201f10:	6902                	ld	s2,0(sp)
ffffffffc0201f12:	6105                	addi	sp,sp,32
ffffffffc0201f14:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201f16:	0541                	addi	a0,a0,16
ffffffffc0201f18:	e81ff0ef          	jal	ra,ffffffffc0201d98 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201f1c:	01050413          	addi	s0,a0,16
ffffffffc0201f20:	f565                	bnez	a0,ffffffffc0201f08 <kmalloc+0x56>
ffffffffc0201f22:	4401                	li	s0,0
}
ffffffffc0201f24:	60e2                	ld	ra,24(sp)
ffffffffc0201f26:	8522                	mv	a0,s0
ffffffffc0201f28:	6442                	ld	s0,16(sp)
ffffffffc0201f2a:	64a2                	ld	s1,8(sp)
ffffffffc0201f2c:	6902                	ld	s2,0(sp)
ffffffffc0201f2e:	6105                	addi	sp,sp,32
ffffffffc0201f30:	8082                	ret
        intr_disable();
ffffffffc0201f32:	f16fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201f36:	000b1797          	auipc	a5,0xb1
ffffffffc0201f3a:	8ba78793          	addi	a5,a5,-1862 # ffffffffc02b27f0 <bigblocks>
ffffffffc0201f3e:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201f40:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201f42:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201f44:	efefe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
		return bb->pages;
ffffffffc0201f48:	6480                	ld	s0,8(s1)
}
ffffffffc0201f4a:	60e2                	ld	ra,24(sp)
ffffffffc0201f4c:	64a2                	ld	s1,8(sp)
ffffffffc0201f4e:	8522                	mv	a0,s0
ffffffffc0201f50:	6442                	ld	s0,16(sp)
ffffffffc0201f52:	6902                	ld	s2,0(sp)
ffffffffc0201f54:	6105                	addi	sp,sp,32
ffffffffc0201f56:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201f58:	45e1                	li	a1,24
ffffffffc0201f5a:	8526                	mv	a0,s1
ffffffffc0201f5c:	d25ff0ef          	jal	ra,ffffffffc0201c80 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201f60:	b765                	j	ffffffffc0201f08 <kmalloc+0x56>

ffffffffc0201f62 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201f62:	c169                	beqz	a0,ffffffffc0202024 <kfree+0xc2>
{
ffffffffc0201f64:	1101                	addi	sp,sp,-32
ffffffffc0201f66:	e822                	sd	s0,16(sp)
ffffffffc0201f68:	ec06                	sd	ra,24(sp)
ffffffffc0201f6a:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201f6c:	03451793          	slli	a5,a0,0x34
ffffffffc0201f70:	842a                	mv	s0,a0
ffffffffc0201f72:	e3d9                	bnez	a5,ffffffffc0201ff8 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f74:	100027f3          	csrr	a5,sstatus
ffffffffc0201f78:	8b89                	andi	a5,a5,2
ffffffffc0201f7a:	e7d9                	bnez	a5,ffffffffc0202008 <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201f7c:	000b1797          	auipc	a5,0xb1
ffffffffc0201f80:	8747b783          	ld	a5,-1932(a5) # ffffffffc02b27f0 <bigblocks>
    return 0;
ffffffffc0201f84:	4601                	li	a2,0
ffffffffc0201f86:	cbad                	beqz	a5,ffffffffc0201ff8 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201f88:	000b1697          	auipc	a3,0xb1
ffffffffc0201f8c:	86868693          	addi	a3,a3,-1944 # ffffffffc02b27f0 <bigblocks>
ffffffffc0201f90:	a021                	j	ffffffffc0201f98 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201f92:	01048693          	addi	a3,s1,16
ffffffffc0201f96:	c3a5                	beqz	a5,ffffffffc0201ff6 <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201f98:	6798                	ld	a4,8(a5)
ffffffffc0201f9a:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0201f9c:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0201f9e:	fe871ae3          	bne	a4,s0,ffffffffc0201f92 <kfree+0x30>
				*last = bb->next;
ffffffffc0201fa2:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201fa4:	ee2d                	bnez	a2,ffffffffc020201e <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201fa6:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201faa:	4098                	lw	a4,0(s1)
ffffffffc0201fac:	08f46963          	bltu	s0,a5,ffffffffc020203e <kfree+0xdc>
ffffffffc0201fb0:	000b1697          	auipc	a3,0xb1
ffffffffc0201fb4:	8886b683          	ld	a3,-1912(a3) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0201fb8:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201fba:	8031                	srli	s0,s0,0xc
ffffffffc0201fbc:	000b1797          	auipc	a5,0xb1
ffffffffc0201fc0:	8647b783          	ld	a5,-1948(a5) # ffffffffc02b2820 <npage>
ffffffffc0201fc4:	06f47163          	bgeu	s0,a5,ffffffffc0202026 <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fc8:	00007517          	auipc	a0,0x7
ffffffffc0201fcc:	cd853503          	ld	a0,-808(a0) # ffffffffc0208ca0 <nbase>
ffffffffc0201fd0:	8c09                	sub	s0,s0,a0
ffffffffc0201fd2:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201fd4:	000b1517          	auipc	a0,0xb1
ffffffffc0201fd8:	85453503          	ld	a0,-1964(a0) # ffffffffc02b2828 <pages>
ffffffffc0201fdc:	4585                	li	a1,1
ffffffffc0201fde:	9522                	add	a0,a0,s0
ffffffffc0201fe0:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201fe4:	4f4010ef          	jal	ra,ffffffffc02034d8 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201fe8:	6442                	ld	s0,16(sp)
ffffffffc0201fea:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201fec:	8526                	mv	a0,s1
}
ffffffffc0201fee:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ff0:	45e1                	li	a1,24
}
ffffffffc0201ff2:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201ff4:	b171                	j	ffffffffc0201c80 <slob_free>
ffffffffc0201ff6:	e20d                	bnez	a2,ffffffffc0202018 <kfree+0xb6>
ffffffffc0201ff8:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201ffc:	6442                	ld	s0,16(sp)
ffffffffc0201ffe:	60e2                	ld	ra,24(sp)
ffffffffc0202000:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202002:	4581                	li	a1,0
}
ffffffffc0202004:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202006:	b9ad                	j	ffffffffc0201c80 <slob_free>
        intr_disable();
ffffffffc0202008:	e40fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020200c:	000b0797          	auipc	a5,0xb0
ffffffffc0202010:	7e47b783          	ld	a5,2020(a5) # ffffffffc02b27f0 <bigblocks>
        return 1;
ffffffffc0202014:	4605                	li	a2,1
ffffffffc0202016:	fbad                	bnez	a5,ffffffffc0201f88 <kfree+0x26>
        intr_enable();
ffffffffc0202018:	e2afe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020201c:	bff1                	j	ffffffffc0201ff8 <kfree+0x96>
ffffffffc020201e:	e24fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0202022:	b751                	j	ffffffffc0201fa6 <kfree+0x44>
ffffffffc0202024:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0202026:	00005617          	auipc	a2,0x5
ffffffffc020202a:	1fa60613          	addi	a2,a2,506 # ffffffffc0207220 <commands+0x9b0>
ffffffffc020202e:	06200593          	li	a1,98
ffffffffc0202032:	00005517          	auipc	a0,0x5
ffffffffc0202036:	20e50513          	addi	a0,a0,526 # ffffffffc0207240 <commands+0x9d0>
ffffffffc020203a:	9cefe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020203e:	86a2                	mv	a3,s0
ffffffffc0202040:	00005617          	auipc	a2,0x5
ffffffffc0202044:	59860613          	addi	a2,a2,1432 # ffffffffc02075d8 <commands+0xd68>
ffffffffc0202048:	06e00593          	li	a1,110
ffffffffc020204c:	00005517          	auipc	a0,0x5
ffffffffc0202050:	1f450513          	addi	a0,a0,500 # ffffffffc0207240 <commands+0x9d0>
ffffffffc0202054:	9b4fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202058 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0202058:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc020205a:	00005617          	auipc	a2,0x5
ffffffffc020205e:	1c660613          	addi	a2,a2,454 # ffffffffc0207220 <commands+0x9b0>
ffffffffc0202062:	06200593          	li	a1,98
ffffffffc0202066:	00005517          	auipc	a0,0x5
ffffffffc020206a:	1da50513          	addi	a0,a0,474 # ffffffffc0207240 <commands+0x9d0>
pa2page(uintptr_t pa) {
ffffffffc020206e:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202070:	998fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202074 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202074:	7135                	addi	sp,sp,-160
ffffffffc0202076:	ed06                	sd	ra,152(sp)
ffffffffc0202078:	e922                	sd	s0,144(sp)
ffffffffc020207a:	e526                	sd	s1,136(sp)
ffffffffc020207c:	e14a                	sd	s2,128(sp)
ffffffffc020207e:	fcce                	sd	s3,120(sp)
ffffffffc0202080:	f8d2                	sd	s4,112(sp)
ffffffffc0202082:	f4d6                	sd	s5,104(sp)
ffffffffc0202084:	f0da                	sd	s6,96(sp)
ffffffffc0202086:	ecde                	sd	s7,88(sp)
ffffffffc0202088:	e8e2                	sd	s8,80(sp)
ffffffffc020208a:	e4e6                	sd	s9,72(sp)
ffffffffc020208c:	e0ea                	sd	s10,64(sp)
ffffffffc020208e:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202090:	2dd020ef          	jal	ra,ffffffffc0204b6c <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202094:	000b0697          	auipc	a3,0xb0
ffffffffc0202098:	7646b683          	ld	a3,1892(a3) # ffffffffc02b27f8 <max_swap_offset>
ffffffffc020209c:	010007b7          	lui	a5,0x1000
ffffffffc02020a0:	ff968713          	addi	a4,a3,-7
ffffffffc02020a4:	17e1                	addi	a5,a5,-8
ffffffffc02020a6:	42e7e663          	bltu	a5,a4,ffffffffc02024d2 <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02020aa:	000a5797          	auipc	a5,0xa5
ffffffffc02020ae:	1f678793          	addi	a5,a5,502 # ffffffffc02a72a0 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02020b2:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02020b4:	000b0b97          	auipc	s7,0xb0
ffffffffc02020b8:	74cb8b93          	addi	s7,s7,1868 # ffffffffc02b2800 <sm>
ffffffffc02020bc:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc02020c0:	9702                	jalr	a4
ffffffffc02020c2:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc02020c4:	c10d                	beqz	a0,ffffffffc02020e6 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02020c6:	60ea                	ld	ra,152(sp)
ffffffffc02020c8:	644a                	ld	s0,144(sp)
ffffffffc02020ca:	64aa                	ld	s1,136(sp)
ffffffffc02020cc:	79e6                	ld	s3,120(sp)
ffffffffc02020ce:	7a46                	ld	s4,112(sp)
ffffffffc02020d0:	7aa6                	ld	s5,104(sp)
ffffffffc02020d2:	7b06                	ld	s6,96(sp)
ffffffffc02020d4:	6be6                	ld	s7,88(sp)
ffffffffc02020d6:	6c46                	ld	s8,80(sp)
ffffffffc02020d8:	6ca6                	ld	s9,72(sp)
ffffffffc02020da:	6d06                	ld	s10,64(sp)
ffffffffc02020dc:	7de2                	ld	s11,56(sp)
ffffffffc02020de:	854a                	mv	a0,s2
ffffffffc02020e0:	690a                	ld	s2,128(sp)
ffffffffc02020e2:	610d                	addi	sp,sp,160
ffffffffc02020e4:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02020e6:	000bb783          	ld	a5,0(s7)
ffffffffc02020ea:	00005517          	auipc	a0,0x5
ffffffffc02020ee:	54650513          	addi	a0,a0,1350 # ffffffffc0207630 <commands+0xdc0>
    return listelm->next;
ffffffffc02020f2:	000ac417          	auipc	s0,0xac
ffffffffc02020f6:	6ae40413          	addi	s0,s0,1710 # ffffffffc02ae7a0 <free_area>
ffffffffc02020fa:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02020fc:	4785                	li	a5,1
ffffffffc02020fe:	000b0717          	auipc	a4,0xb0
ffffffffc0202102:	70f72523          	sw	a5,1802(a4) # ffffffffc02b2808 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202106:	fc7fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020210a:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc020210c:	4d01                	li	s10,0
ffffffffc020210e:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202110:	34878163          	beq	a5,s0,ffffffffc0202452 <swap_init+0x3de>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202114:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202118:	8b09                	andi	a4,a4,2
ffffffffc020211a:	32070e63          	beqz	a4,ffffffffc0202456 <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc020211e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202122:	679c                	ld	a5,8(a5)
ffffffffc0202124:	2d85                	addiw	s11,s11,1
ffffffffc0202126:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc020212a:	fe8795e3          	bne	a5,s0,ffffffffc0202114 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc020212e:	84ea                	mv	s1,s10
ffffffffc0202130:	3e8010ef          	jal	ra,ffffffffc0203518 <nr_free_pages>
ffffffffc0202134:	42951763          	bne	a0,s1,ffffffffc0202562 <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202138:	866a                	mv	a2,s10
ffffffffc020213a:	85ee                	mv	a1,s11
ffffffffc020213c:	00005517          	auipc	a0,0x5
ffffffffc0202140:	53c50513          	addi	a0,a0,1340 # ffffffffc0207678 <commands+0xe08>
ffffffffc0202144:	f89fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202148:	cfffe0ef          	jal	ra,ffffffffc0200e46 <mm_create>
ffffffffc020214c:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc020214e:	46050a63          	beqz	a0,ffffffffc02025c2 <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202152:	000b0797          	auipc	a5,0xb0
ffffffffc0202156:	68e78793          	addi	a5,a5,1678 # ffffffffc02b27e0 <check_mm_struct>
ffffffffc020215a:	6398                	ld	a4,0(a5)
ffffffffc020215c:	3e071363          	bnez	a4,ffffffffc0202542 <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202160:	000b0717          	auipc	a4,0xb0
ffffffffc0202164:	6b870713          	addi	a4,a4,1720 # ffffffffc02b2818 <boot_pgdir>
ffffffffc0202168:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc020216c:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc020216e:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202172:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202176:	42079663          	bnez	a5,ffffffffc02025a2 <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc020217a:	6599                	lui	a1,0x6
ffffffffc020217c:	460d                	li	a2,3
ffffffffc020217e:	6505                	lui	a0,0x1
ffffffffc0202180:	d0ffe0ef          	jal	ra,ffffffffc0200e8e <vma_create>
ffffffffc0202184:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202186:	52050a63          	beqz	a0,ffffffffc02026ba <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc020218a:	8556                	mv	a0,s5
ffffffffc020218c:	d71fe0ef          	jal	ra,ffffffffc0200efc <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202190:	00005517          	auipc	a0,0x5
ffffffffc0202194:	52850513          	addi	a0,a0,1320 # ffffffffc02076b8 <commands+0xe48>
ffffffffc0202198:	f35fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc020219c:	018ab503          	ld	a0,24(s5)
ffffffffc02021a0:	4605                	li	a2,1
ffffffffc02021a2:	6585                	lui	a1,0x1
ffffffffc02021a4:	3ae010ef          	jal	ra,ffffffffc0203552 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02021a8:	4c050963          	beqz	a0,ffffffffc020267a <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02021ac:	00005517          	auipc	a0,0x5
ffffffffc02021b0:	55c50513          	addi	a0,a0,1372 # ffffffffc0207708 <commands+0xe98>
ffffffffc02021b4:	000ac497          	auipc	s1,0xac
ffffffffc02021b8:	57c48493          	addi	s1,s1,1404 # ffffffffc02ae730 <check_rp>
ffffffffc02021bc:	f11fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02021c0:	000ac997          	auipc	s3,0xac
ffffffffc02021c4:	59098993          	addi	s3,s3,1424 # ffffffffc02ae750 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02021c8:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc02021ca:	4505                	li	a0,1
ffffffffc02021cc:	27a010ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc02021d0:	00aa3023          	sd	a0,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
          assert(check_rp[i] != NULL );
ffffffffc02021d4:	2c050f63          	beqz	a0,ffffffffc02024b2 <swap_init+0x43e>
ffffffffc02021d8:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02021da:	8b89                	andi	a5,a5,2
ffffffffc02021dc:	34079363          	bnez	a5,ffffffffc0202522 <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02021e0:	0a21                	addi	s4,s4,8
ffffffffc02021e2:	ff3a14e3          	bne	s4,s3,ffffffffc02021ca <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02021e6:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02021e8:	000aca17          	auipc	s4,0xac
ffffffffc02021ec:	548a0a13          	addi	s4,s4,1352 # ffffffffc02ae730 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc02021f0:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc02021f2:	ec3e                	sd	a5,24(sp)
ffffffffc02021f4:	641c                	ld	a5,8(s0)
ffffffffc02021f6:	e400                	sd	s0,8(s0)
ffffffffc02021f8:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02021fa:	481c                	lw	a5,16(s0)
ffffffffc02021fc:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc02021fe:	000ac797          	auipc	a5,0xac
ffffffffc0202202:	5a07a923          	sw	zero,1458(a5) # ffffffffc02ae7b0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202206:	000a3503          	ld	a0,0(s4)
ffffffffc020220a:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020220c:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc020220e:	2ca010ef          	jal	ra,ffffffffc02034d8 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202212:	ff3a1ae3          	bne	s4,s3,ffffffffc0202206 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202216:	01042a03          	lw	s4,16(s0)
ffffffffc020221a:	4791                	li	a5,4
ffffffffc020221c:	42fa1f63          	bne	s4,a5,ffffffffc020265a <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202220:	00005517          	auipc	a0,0x5
ffffffffc0202224:	57050513          	addi	a0,a0,1392 # ffffffffc0207790 <commands+0xf20>
ffffffffc0202228:	ea5fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020222c:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc020222e:	000b0797          	auipc	a5,0xb0
ffffffffc0202232:	5a07ad23          	sw	zero,1466(a5) # ffffffffc02b27e8 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202236:	4629                	li	a2,10
ffffffffc0202238:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
     assert(pgfault_num==1);
ffffffffc020223c:	000b0697          	auipc	a3,0xb0
ffffffffc0202240:	5ac6a683          	lw	a3,1452(a3) # ffffffffc02b27e8 <pgfault_num>
ffffffffc0202244:	4585                	li	a1,1
ffffffffc0202246:	000b0797          	auipc	a5,0xb0
ffffffffc020224a:	5a278793          	addi	a5,a5,1442 # ffffffffc02b27e8 <pgfault_num>
ffffffffc020224e:	54b69663          	bne	a3,a1,ffffffffc020279a <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202252:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0202256:	4398                	lw	a4,0(a5)
ffffffffc0202258:	2701                	sext.w	a4,a4
ffffffffc020225a:	3ed71063          	bne	a4,a3,ffffffffc020263a <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc020225e:	6689                	lui	a3,0x2
ffffffffc0202260:	462d                	li	a2,11
ffffffffc0202262:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7bb0>
     assert(pgfault_num==2);
ffffffffc0202266:	4398                	lw	a4,0(a5)
ffffffffc0202268:	4589                	li	a1,2
ffffffffc020226a:	2701                	sext.w	a4,a4
ffffffffc020226c:	4ab71763          	bne	a4,a1,ffffffffc020271a <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202270:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202274:	4394                	lw	a3,0(a5)
ffffffffc0202276:	2681                	sext.w	a3,a3
ffffffffc0202278:	4ce69163          	bne	a3,a4,ffffffffc020273a <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc020227c:	668d                	lui	a3,0x3
ffffffffc020227e:	4631                	li	a2,12
ffffffffc0202280:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb0>
     assert(pgfault_num==3);
ffffffffc0202284:	4398                	lw	a4,0(a5)
ffffffffc0202286:	458d                	li	a1,3
ffffffffc0202288:	2701                	sext.w	a4,a4
ffffffffc020228a:	4cb71863          	bne	a4,a1,ffffffffc020275a <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc020228e:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202292:	4394                	lw	a3,0(a5)
ffffffffc0202294:	2681                	sext.w	a3,a3
ffffffffc0202296:	4ee69263          	bne	a3,a4,ffffffffc020277a <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc020229a:	6691                	lui	a3,0x4
ffffffffc020229c:	4635                	li	a2,13
ffffffffc020229e:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5bb0>
     assert(pgfault_num==4);
ffffffffc02022a2:	4398                	lw	a4,0(a5)
ffffffffc02022a4:	2701                	sext.w	a4,a4
ffffffffc02022a6:	43471a63          	bne	a4,s4,ffffffffc02026da <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02022aa:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02022ae:	439c                	lw	a5,0(a5)
ffffffffc02022b0:	2781                	sext.w	a5,a5
ffffffffc02022b2:	44e79463          	bne	a5,a4,ffffffffc02026fa <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02022b6:	481c                	lw	a5,16(s0)
ffffffffc02022b8:	2c079563          	bnez	a5,ffffffffc0202582 <swap_init+0x50e>
ffffffffc02022bc:	000ac797          	auipc	a5,0xac
ffffffffc02022c0:	49478793          	addi	a5,a5,1172 # ffffffffc02ae750 <swap_in_seq_no>
ffffffffc02022c4:	000ac717          	auipc	a4,0xac
ffffffffc02022c8:	4b470713          	addi	a4,a4,1204 # ffffffffc02ae778 <swap_out_seq_no>
ffffffffc02022cc:	000ac617          	auipc	a2,0xac
ffffffffc02022d0:	4ac60613          	addi	a2,a2,1196 # ffffffffc02ae778 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02022d4:	56fd                	li	a3,-1
ffffffffc02022d6:	c394                	sw	a3,0(a5)
ffffffffc02022d8:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02022da:	0791                	addi	a5,a5,4
ffffffffc02022dc:	0711                	addi	a4,a4,4
ffffffffc02022de:	fec79ce3          	bne	a5,a2,ffffffffc02022d6 <swap_init+0x262>
ffffffffc02022e2:	000ac717          	auipc	a4,0xac
ffffffffc02022e6:	42e70713          	addi	a4,a4,1070 # ffffffffc02ae710 <check_ptep>
ffffffffc02022ea:	000ac697          	auipc	a3,0xac
ffffffffc02022ee:	44668693          	addi	a3,a3,1094 # ffffffffc02ae730 <check_rp>
ffffffffc02022f2:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc02022f4:	000b0c17          	auipc	s8,0xb0
ffffffffc02022f8:	52cc0c13          	addi	s8,s8,1324 # ffffffffc02b2820 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02022fc:	000b0c97          	auipc	s9,0xb0
ffffffffc0202300:	52cc8c93          	addi	s9,s9,1324 # ffffffffc02b2828 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202304:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202308:	4601                	li	a2,0
ffffffffc020230a:	855a                	mv	a0,s6
ffffffffc020230c:	e836                	sd	a3,16(sp)
ffffffffc020230e:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0202310:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202312:	240010ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc0202316:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202318:	65a2                	ld	a1,8(sp)
ffffffffc020231a:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020231c:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc020231e:	1c050663          	beqz	a0,ffffffffc02024ea <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202322:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202324:	0017f613          	andi	a2,a5,1
ffffffffc0202328:	1e060163          	beqz	a2,ffffffffc020250a <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc020232c:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202330:	078a                	slli	a5,a5,0x2
ffffffffc0202332:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202334:	14c7f363          	bgeu	a5,a2,ffffffffc020247a <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc0202338:	00007617          	auipc	a2,0x7
ffffffffc020233c:	96860613          	addi	a2,a2,-1688 # ffffffffc0208ca0 <nbase>
ffffffffc0202340:	00063a03          	ld	s4,0(a2)
ffffffffc0202344:	000cb603          	ld	a2,0(s9)
ffffffffc0202348:	6288                	ld	a0,0(a3)
ffffffffc020234a:	414787b3          	sub	a5,a5,s4
ffffffffc020234e:	079a                	slli	a5,a5,0x6
ffffffffc0202350:	97b2                	add	a5,a5,a2
ffffffffc0202352:	14f51063          	bne	a0,a5,ffffffffc0202492 <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202356:	6785                	lui	a5,0x1
ffffffffc0202358:	95be                	add	a1,a1,a5
ffffffffc020235a:	6795                	lui	a5,0x5
ffffffffc020235c:	0721                	addi	a4,a4,8
ffffffffc020235e:	06a1                	addi	a3,a3,8
ffffffffc0202360:	faf592e3          	bne	a1,a5,ffffffffc0202304 <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202364:	00005517          	auipc	a0,0x5
ffffffffc0202368:	4fc50513          	addi	a0,a0,1276 # ffffffffc0207860 <commands+0xff0>
ffffffffc020236c:	d61fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = sm->check_swap();
ffffffffc0202370:	000bb783          	ld	a5,0(s7)
ffffffffc0202374:	7f9c                	ld	a5,56(a5)
ffffffffc0202376:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202378:	32051163          	bnez	a0,ffffffffc020269a <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc020237c:	77a2                	ld	a5,40(sp)
ffffffffc020237e:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0202380:	67e2                	ld	a5,24(sp)
ffffffffc0202382:	e01c                	sd	a5,0(s0)
ffffffffc0202384:	7782                	ld	a5,32(sp)
ffffffffc0202386:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202388:	6088                	ld	a0,0(s1)
ffffffffc020238a:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020238c:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc020238e:	14a010ef          	jal	ra,ffffffffc02034d8 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202392:	ff349be3          	bne	s1,s3,ffffffffc0202388 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0202396:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc020239a:	8556                	mv	a0,s5
ffffffffc020239c:	c31fe0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02023a0:	000b0797          	auipc	a5,0xb0
ffffffffc02023a4:	47878793          	addi	a5,a5,1144 # ffffffffc02b2818 <boot_pgdir>
ffffffffc02023a8:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02023aa:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc02023ae:	000b0697          	auipc	a3,0xb0
ffffffffc02023b2:	4206b923          	sd	zero,1074(a3) # ffffffffc02b27e0 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc02023b6:	639c                	ld	a5,0(a5)
ffffffffc02023b8:	078a                	slli	a5,a5,0x2
ffffffffc02023ba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023bc:	0ae7fd63          	bgeu	a5,a4,ffffffffc0202476 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc02023c0:	414786b3          	sub	a3,a5,s4
ffffffffc02023c4:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02023c6:	8699                	srai	a3,a3,0x6
ffffffffc02023c8:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02023ca:	00c69793          	slli	a5,a3,0xc
ffffffffc02023ce:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02023d0:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc02023d4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023d6:	22e7f663          	bgeu	a5,a4,ffffffffc0202602 <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc02023da:	000b0797          	auipc	a5,0xb0
ffffffffc02023de:	45e7b783          	ld	a5,1118(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc02023e2:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02023e4:	629c                	ld	a5,0(a3)
ffffffffc02023e6:	078a                	slli	a5,a5,0x2
ffffffffc02023e8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023ea:	08e7f663          	bgeu	a5,a4,ffffffffc0202476 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc02023ee:	414787b3          	sub	a5,a5,s4
ffffffffc02023f2:	079a                	slli	a5,a5,0x6
ffffffffc02023f4:	953e                	add	a0,a0,a5
ffffffffc02023f6:	4585                	li	a1,1
ffffffffc02023f8:	0e0010ef          	jal	ra,ffffffffc02034d8 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02023fc:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202400:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202404:	078a                	slli	a5,a5,0x2
ffffffffc0202406:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202408:	06e7f763          	bgeu	a5,a4,ffffffffc0202476 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc020240c:	000cb503          	ld	a0,0(s9)
ffffffffc0202410:	414787b3          	sub	a5,a5,s4
ffffffffc0202414:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202416:	4585                	li	a1,1
ffffffffc0202418:	953e                	add	a0,a0,a5
ffffffffc020241a:	0be010ef          	jal	ra,ffffffffc02034d8 <free_pages>
     pgdir[0] = 0;
ffffffffc020241e:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202422:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202426:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202428:	00878a63          	beq	a5,s0,ffffffffc020243c <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc020242c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202430:	679c                	ld	a5,8(a5)
ffffffffc0202432:	3dfd                	addiw	s11,s11,-1
ffffffffc0202434:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202438:	fe879ae3          	bne	a5,s0,ffffffffc020242c <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc020243c:	1c0d9f63          	bnez	s11,ffffffffc020261a <swap_init+0x5a6>
     assert(total==0);
ffffffffc0202440:	1a0d1163          	bnez	s10,ffffffffc02025e2 <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202444:	00005517          	auipc	a0,0x5
ffffffffc0202448:	46c50513          	addi	a0,a0,1132 # ffffffffc02078b0 <commands+0x1040>
ffffffffc020244c:	c81fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0202450:	b99d                	j	ffffffffc02020c6 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202452:	4481                	li	s1,0
ffffffffc0202454:	b9f1                	j	ffffffffc0202130 <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc0202456:	00005697          	auipc	a3,0x5
ffffffffc020245a:	1f268693          	addi	a3,a3,498 # ffffffffc0207648 <commands+0xdd8>
ffffffffc020245e:	00005617          	auipc	a2,0x5
ffffffffc0202462:	82260613          	addi	a2,a2,-2014 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202466:	0bc00593          	li	a1,188
ffffffffc020246a:	00005517          	auipc	a0,0x5
ffffffffc020246e:	1b650513          	addi	a0,a0,438 # ffffffffc0207620 <commands+0xdb0>
ffffffffc0202472:	d97fd0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0202476:	be3ff0ef          	jal	ra,ffffffffc0202058 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc020247a:	00005617          	auipc	a2,0x5
ffffffffc020247e:	da660613          	addi	a2,a2,-602 # ffffffffc0207220 <commands+0x9b0>
ffffffffc0202482:	06200593          	li	a1,98
ffffffffc0202486:	00005517          	auipc	a0,0x5
ffffffffc020248a:	dba50513          	addi	a0,a0,-582 # ffffffffc0207240 <commands+0x9d0>
ffffffffc020248e:	d7bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202492:	00005697          	auipc	a3,0x5
ffffffffc0202496:	3a668693          	addi	a3,a3,934 # ffffffffc0207838 <commands+0xfc8>
ffffffffc020249a:	00004617          	auipc	a2,0x4
ffffffffc020249e:	7e660613          	addi	a2,a2,2022 # ffffffffc0206c80 <commands+0x410>
ffffffffc02024a2:	0fc00593          	li	a1,252
ffffffffc02024a6:	00005517          	auipc	a0,0x5
ffffffffc02024aa:	17a50513          	addi	a0,a0,378 # ffffffffc0207620 <commands+0xdb0>
ffffffffc02024ae:	d5bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc02024b2:	00005697          	auipc	a3,0x5
ffffffffc02024b6:	27e68693          	addi	a3,a3,638 # ffffffffc0207730 <commands+0xec0>
ffffffffc02024ba:	00004617          	auipc	a2,0x4
ffffffffc02024be:	7c660613          	addi	a2,a2,1990 # ffffffffc0206c80 <commands+0x410>
ffffffffc02024c2:	0dc00593          	li	a1,220
ffffffffc02024c6:	00005517          	auipc	a0,0x5
ffffffffc02024ca:	15a50513          	addi	a0,a0,346 # ffffffffc0207620 <commands+0xdb0>
ffffffffc02024ce:	d3bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc02024d2:	00005617          	auipc	a2,0x5
ffffffffc02024d6:	12e60613          	addi	a2,a2,302 # ffffffffc0207600 <commands+0xd90>
ffffffffc02024da:	02800593          	li	a1,40
ffffffffc02024de:	00005517          	auipc	a0,0x5
ffffffffc02024e2:	14250513          	addi	a0,a0,322 # ffffffffc0207620 <commands+0xdb0>
ffffffffc02024e6:	d23fd0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc02024ea:	00005697          	auipc	a3,0x5
ffffffffc02024ee:	30e68693          	addi	a3,a3,782 # ffffffffc02077f8 <commands+0xf88>
ffffffffc02024f2:	00004617          	auipc	a2,0x4
ffffffffc02024f6:	78e60613          	addi	a2,a2,1934 # ffffffffc0206c80 <commands+0x410>
ffffffffc02024fa:	0fb00593          	li	a1,251
ffffffffc02024fe:	00005517          	auipc	a0,0x5
ffffffffc0202502:	12250513          	addi	a0,a0,290 # ffffffffc0207620 <commands+0xdb0>
ffffffffc0202506:	d03fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020250a:	00005617          	auipc	a2,0x5
ffffffffc020250e:	30660613          	addi	a2,a2,774 # ffffffffc0207810 <commands+0xfa0>
ffffffffc0202512:	07400593          	li	a1,116
ffffffffc0202516:	00005517          	auipc	a0,0x5
ffffffffc020251a:	d2a50513          	addi	a0,a0,-726 # ffffffffc0207240 <commands+0x9d0>
ffffffffc020251e:	cebfd0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202522:	00005697          	auipc	a3,0x5
ffffffffc0202526:	22668693          	addi	a3,a3,550 # ffffffffc0207748 <commands+0xed8>
ffffffffc020252a:	00004617          	auipc	a2,0x4
ffffffffc020252e:	75660613          	addi	a2,a2,1878 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202532:	0dd00593          	li	a1,221
ffffffffc0202536:	00005517          	auipc	a0,0x5
ffffffffc020253a:	0ea50513          	addi	a0,a0,234 # ffffffffc0207620 <commands+0xdb0>
ffffffffc020253e:	ccbfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202542:	00005697          	auipc	a3,0x5
ffffffffc0202546:	15e68693          	addi	a3,a3,350 # ffffffffc02076a0 <commands+0xe30>
ffffffffc020254a:	00004617          	auipc	a2,0x4
ffffffffc020254e:	73660613          	addi	a2,a2,1846 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202552:	0c700593          	li	a1,199
ffffffffc0202556:	00005517          	auipc	a0,0x5
ffffffffc020255a:	0ca50513          	addi	a0,a0,202 # ffffffffc0207620 <commands+0xdb0>
ffffffffc020255e:	cabfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202562:	00005697          	auipc	a3,0x5
ffffffffc0202566:	0f668693          	addi	a3,a3,246 # ffffffffc0207658 <commands+0xde8>
ffffffffc020256a:	00004617          	auipc	a2,0x4
ffffffffc020256e:	71660613          	addi	a2,a2,1814 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202572:	0bf00593          	li	a1,191
ffffffffc0202576:	00005517          	auipc	a0,0x5
ffffffffc020257a:	0aa50513          	addi	a0,a0,170 # ffffffffc0207620 <commands+0xdb0>
ffffffffc020257e:	c8bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert( nr_free == 0);         
ffffffffc0202582:	00005697          	auipc	a3,0x5
ffffffffc0202586:	26668693          	addi	a3,a3,614 # ffffffffc02077e8 <commands+0xf78>
ffffffffc020258a:	00004617          	auipc	a2,0x4
ffffffffc020258e:	6f660613          	addi	a2,a2,1782 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202592:	0f300593          	li	a1,243
ffffffffc0202596:	00005517          	auipc	a0,0x5
ffffffffc020259a:	08a50513          	addi	a0,a0,138 # ffffffffc0207620 <commands+0xdb0>
ffffffffc020259e:	c6bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgdir[0] == 0);
ffffffffc02025a2:	00005697          	auipc	a3,0x5
ffffffffc02025a6:	c3e68693          	addi	a3,a3,-962 # ffffffffc02071e0 <commands+0x970>
ffffffffc02025aa:	00004617          	auipc	a2,0x4
ffffffffc02025ae:	6d660613          	addi	a2,a2,1750 # ffffffffc0206c80 <commands+0x410>
ffffffffc02025b2:	0cc00593          	li	a1,204
ffffffffc02025b6:	00005517          	auipc	a0,0x5
ffffffffc02025ba:	06a50513          	addi	a0,a0,106 # ffffffffc0207620 <commands+0xdb0>
ffffffffc02025be:	c4bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(mm != NULL);
ffffffffc02025c2:	00005697          	auipc	a3,0x5
ffffffffc02025c6:	a5668693          	addi	a3,a3,-1450 # ffffffffc0207018 <commands+0x7a8>
ffffffffc02025ca:	00004617          	auipc	a2,0x4
ffffffffc02025ce:	6b660613          	addi	a2,a2,1718 # ffffffffc0206c80 <commands+0x410>
ffffffffc02025d2:	0c400593          	li	a1,196
ffffffffc02025d6:	00005517          	auipc	a0,0x5
ffffffffc02025da:	04a50513          	addi	a0,a0,74 # ffffffffc0207620 <commands+0xdb0>
ffffffffc02025de:	c2bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total==0);
ffffffffc02025e2:	00005697          	auipc	a3,0x5
ffffffffc02025e6:	2be68693          	addi	a3,a3,702 # ffffffffc02078a0 <commands+0x1030>
ffffffffc02025ea:	00004617          	auipc	a2,0x4
ffffffffc02025ee:	69660613          	addi	a2,a2,1686 # ffffffffc0206c80 <commands+0x410>
ffffffffc02025f2:	11e00593          	li	a1,286
ffffffffc02025f6:	00005517          	auipc	a0,0x5
ffffffffc02025fa:	02a50513          	addi	a0,a0,42 # ffffffffc0207620 <commands+0xdb0>
ffffffffc02025fe:	c0bfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202602:	00005617          	auipc	a2,0x5
ffffffffc0202606:	c4e60613          	addi	a2,a2,-946 # ffffffffc0207250 <commands+0x9e0>
ffffffffc020260a:	06900593          	li	a1,105
ffffffffc020260e:	00005517          	auipc	a0,0x5
ffffffffc0202612:	c3250513          	addi	a0,a0,-974 # ffffffffc0207240 <commands+0x9d0>
ffffffffc0202616:	bf3fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(count==0);
ffffffffc020261a:	00005697          	auipc	a3,0x5
ffffffffc020261e:	27668693          	addi	a3,a3,630 # ffffffffc0207890 <commands+0x1020>
ffffffffc0202622:	00004617          	auipc	a2,0x4
ffffffffc0202626:	65e60613          	addi	a2,a2,1630 # ffffffffc0206c80 <commands+0x410>
ffffffffc020262a:	11d00593          	li	a1,285
ffffffffc020262e:	00005517          	auipc	a0,0x5
ffffffffc0202632:	ff250513          	addi	a0,a0,-14 # ffffffffc0207620 <commands+0xdb0>
ffffffffc0202636:	bd3fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc020263a:	00005697          	auipc	a3,0x5
ffffffffc020263e:	17e68693          	addi	a3,a3,382 # ffffffffc02077b8 <commands+0xf48>
ffffffffc0202642:	00004617          	auipc	a2,0x4
ffffffffc0202646:	63e60613          	addi	a2,a2,1598 # ffffffffc0206c80 <commands+0x410>
ffffffffc020264a:	09500593          	li	a1,149
ffffffffc020264e:	00005517          	auipc	a0,0x5
ffffffffc0202652:	fd250513          	addi	a0,a0,-46 # ffffffffc0207620 <commands+0xdb0>
ffffffffc0202656:	bb3fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020265a:	00005697          	auipc	a3,0x5
ffffffffc020265e:	10e68693          	addi	a3,a3,270 # ffffffffc0207768 <commands+0xef8>
ffffffffc0202662:	00004617          	auipc	a2,0x4
ffffffffc0202666:	61e60613          	addi	a2,a2,1566 # ffffffffc0206c80 <commands+0x410>
ffffffffc020266a:	0ea00593          	li	a1,234
ffffffffc020266e:	00005517          	auipc	a0,0x5
ffffffffc0202672:	fb250513          	addi	a0,a0,-78 # ffffffffc0207620 <commands+0xdb0>
ffffffffc0202676:	b93fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc020267a:	00005697          	auipc	a3,0x5
ffffffffc020267e:	07668693          	addi	a3,a3,118 # ffffffffc02076f0 <commands+0xe80>
ffffffffc0202682:	00004617          	auipc	a2,0x4
ffffffffc0202686:	5fe60613          	addi	a2,a2,1534 # ffffffffc0206c80 <commands+0x410>
ffffffffc020268a:	0d700593          	li	a1,215
ffffffffc020268e:	00005517          	auipc	a0,0x5
ffffffffc0202692:	f9250513          	addi	a0,a0,-110 # ffffffffc0207620 <commands+0xdb0>
ffffffffc0202696:	b73fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(ret==0);
ffffffffc020269a:	00005697          	auipc	a3,0x5
ffffffffc020269e:	1ee68693          	addi	a3,a3,494 # ffffffffc0207888 <commands+0x1018>
ffffffffc02026a2:	00004617          	auipc	a2,0x4
ffffffffc02026a6:	5de60613          	addi	a2,a2,1502 # ffffffffc0206c80 <commands+0x410>
ffffffffc02026aa:	10200593          	li	a1,258
ffffffffc02026ae:	00005517          	auipc	a0,0x5
ffffffffc02026b2:	f7250513          	addi	a0,a0,-142 # ffffffffc0207620 <commands+0xdb0>
ffffffffc02026b6:	b53fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(vma != NULL);
ffffffffc02026ba:	00005697          	auipc	a3,0x5
ffffffffc02026be:	c1e68693          	addi	a3,a3,-994 # ffffffffc02072d8 <commands+0xa68>
ffffffffc02026c2:	00004617          	auipc	a2,0x4
ffffffffc02026c6:	5be60613          	addi	a2,a2,1470 # ffffffffc0206c80 <commands+0x410>
ffffffffc02026ca:	0cf00593          	li	a1,207
ffffffffc02026ce:	00005517          	auipc	a0,0x5
ffffffffc02026d2:	f5250513          	addi	a0,a0,-174 # ffffffffc0207620 <commands+0xdb0>
ffffffffc02026d6:	b33fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc02026da:	00005697          	auipc	a3,0x5
ffffffffc02026de:	cd668693          	addi	a3,a3,-810 # ffffffffc02073b0 <commands+0xb40>
ffffffffc02026e2:	00004617          	auipc	a2,0x4
ffffffffc02026e6:	59e60613          	addi	a2,a2,1438 # ffffffffc0206c80 <commands+0x410>
ffffffffc02026ea:	09f00593          	li	a1,159
ffffffffc02026ee:	00005517          	auipc	a0,0x5
ffffffffc02026f2:	f3250513          	addi	a0,a0,-206 # ffffffffc0207620 <commands+0xdb0>
ffffffffc02026f6:	b13fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc02026fa:	00005697          	auipc	a3,0x5
ffffffffc02026fe:	cb668693          	addi	a3,a3,-842 # ffffffffc02073b0 <commands+0xb40>
ffffffffc0202702:	00004617          	auipc	a2,0x4
ffffffffc0202706:	57e60613          	addi	a2,a2,1406 # ffffffffc0206c80 <commands+0x410>
ffffffffc020270a:	0a100593          	li	a1,161
ffffffffc020270e:	00005517          	auipc	a0,0x5
ffffffffc0202712:	f1250513          	addi	a0,a0,-238 # ffffffffc0207620 <commands+0xdb0>
ffffffffc0202716:	af3fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc020271a:	00005697          	auipc	a3,0x5
ffffffffc020271e:	0ae68693          	addi	a3,a3,174 # ffffffffc02077c8 <commands+0xf58>
ffffffffc0202722:	00004617          	auipc	a2,0x4
ffffffffc0202726:	55e60613          	addi	a2,a2,1374 # ffffffffc0206c80 <commands+0x410>
ffffffffc020272a:	09700593          	li	a1,151
ffffffffc020272e:	00005517          	auipc	a0,0x5
ffffffffc0202732:	ef250513          	addi	a0,a0,-270 # ffffffffc0207620 <commands+0xdb0>
ffffffffc0202736:	ad3fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc020273a:	00005697          	auipc	a3,0x5
ffffffffc020273e:	08e68693          	addi	a3,a3,142 # ffffffffc02077c8 <commands+0xf58>
ffffffffc0202742:	00004617          	auipc	a2,0x4
ffffffffc0202746:	53e60613          	addi	a2,a2,1342 # ffffffffc0206c80 <commands+0x410>
ffffffffc020274a:	09900593          	li	a1,153
ffffffffc020274e:	00005517          	auipc	a0,0x5
ffffffffc0202752:	ed250513          	addi	a0,a0,-302 # ffffffffc0207620 <commands+0xdb0>
ffffffffc0202756:	ab3fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc020275a:	00005697          	auipc	a3,0x5
ffffffffc020275e:	07e68693          	addi	a3,a3,126 # ffffffffc02077d8 <commands+0xf68>
ffffffffc0202762:	00004617          	auipc	a2,0x4
ffffffffc0202766:	51e60613          	addi	a2,a2,1310 # ffffffffc0206c80 <commands+0x410>
ffffffffc020276a:	09b00593          	li	a1,155
ffffffffc020276e:	00005517          	auipc	a0,0x5
ffffffffc0202772:	eb250513          	addi	a0,a0,-334 # ffffffffc0207620 <commands+0xdb0>
ffffffffc0202776:	a93fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc020277a:	00005697          	auipc	a3,0x5
ffffffffc020277e:	05e68693          	addi	a3,a3,94 # ffffffffc02077d8 <commands+0xf68>
ffffffffc0202782:	00004617          	auipc	a2,0x4
ffffffffc0202786:	4fe60613          	addi	a2,a2,1278 # ffffffffc0206c80 <commands+0x410>
ffffffffc020278a:	09d00593          	li	a1,157
ffffffffc020278e:	00005517          	auipc	a0,0x5
ffffffffc0202792:	e9250513          	addi	a0,a0,-366 # ffffffffc0207620 <commands+0xdb0>
ffffffffc0202796:	a73fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc020279a:	00005697          	auipc	a3,0x5
ffffffffc020279e:	01e68693          	addi	a3,a3,30 # ffffffffc02077b8 <commands+0xf48>
ffffffffc02027a2:	00004617          	auipc	a2,0x4
ffffffffc02027a6:	4de60613          	addi	a2,a2,1246 # ffffffffc0206c80 <commands+0x410>
ffffffffc02027aa:	09300593          	li	a1,147
ffffffffc02027ae:	00005517          	auipc	a0,0x5
ffffffffc02027b2:	e7250513          	addi	a0,a0,-398 # ffffffffc0207620 <commands+0xdb0>
ffffffffc02027b6:	a53fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02027ba <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02027ba:	000b0797          	auipc	a5,0xb0
ffffffffc02027be:	0467b783          	ld	a5,70(a5) # ffffffffc02b2800 <sm>
ffffffffc02027c2:	6b9c                	ld	a5,16(a5)
ffffffffc02027c4:	8782                	jr	a5

ffffffffc02027c6 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02027c6:	000b0797          	auipc	a5,0xb0
ffffffffc02027ca:	03a7b783          	ld	a5,58(a5) # ffffffffc02b2800 <sm>
ffffffffc02027ce:	739c                	ld	a5,32(a5)
ffffffffc02027d0:	8782                	jr	a5

ffffffffc02027d2 <swap_out>:
{
ffffffffc02027d2:	711d                	addi	sp,sp,-96
ffffffffc02027d4:	ec86                	sd	ra,88(sp)
ffffffffc02027d6:	e8a2                	sd	s0,80(sp)
ffffffffc02027d8:	e4a6                	sd	s1,72(sp)
ffffffffc02027da:	e0ca                	sd	s2,64(sp)
ffffffffc02027dc:	fc4e                	sd	s3,56(sp)
ffffffffc02027de:	f852                	sd	s4,48(sp)
ffffffffc02027e0:	f456                	sd	s5,40(sp)
ffffffffc02027e2:	f05a                	sd	s6,32(sp)
ffffffffc02027e4:	ec5e                	sd	s7,24(sp)
ffffffffc02027e6:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02027e8:	cde9                	beqz	a1,ffffffffc02028c2 <swap_out+0xf0>
ffffffffc02027ea:	8a2e                	mv	s4,a1
ffffffffc02027ec:	892a                	mv	s2,a0
ffffffffc02027ee:	8ab2                	mv	s5,a2
ffffffffc02027f0:	4401                	li	s0,0
ffffffffc02027f2:	000b0997          	auipc	s3,0xb0
ffffffffc02027f6:	00e98993          	addi	s3,s3,14 # ffffffffc02b2800 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02027fa:	00005b17          	auipc	s6,0x5
ffffffffc02027fe:	136b0b13          	addi	s6,s6,310 # ffffffffc0207930 <commands+0x10c0>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202802:	00005b97          	auipc	s7,0x5
ffffffffc0202806:	116b8b93          	addi	s7,s7,278 # ffffffffc0207918 <commands+0x10a8>
ffffffffc020280a:	a825                	j	ffffffffc0202842 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020280c:	67a2                	ld	a5,8(sp)
ffffffffc020280e:	8626                	mv	a2,s1
ffffffffc0202810:	85a2                	mv	a1,s0
ffffffffc0202812:	7f94                	ld	a3,56(a5)
ffffffffc0202814:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202816:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202818:	82b1                	srli	a3,a3,0xc
ffffffffc020281a:	0685                	addi	a3,a3,1
ffffffffc020281c:	8b1fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202820:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202822:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202824:	7d1c                	ld	a5,56(a0)
ffffffffc0202826:	83b1                	srli	a5,a5,0xc
ffffffffc0202828:	0785                	addi	a5,a5,1
ffffffffc020282a:	07a2                	slli	a5,a5,0x8
ffffffffc020282c:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202830:	4a9000ef          	jal	ra,ffffffffc02034d8 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202834:	01893503          	ld	a0,24(s2)
ffffffffc0202838:	85a6                	mv	a1,s1
ffffffffc020283a:	272020ef          	jal	ra,ffffffffc0204aac <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc020283e:	048a0d63          	beq	s4,s0,ffffffffc0202898 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202842:	0009b783          	ld	a5,0(s3)
ffffffffc0202846:	8656                	mv	a2,s5
ffffffffc0202848:	002c                	addi	a1,sp,8
ffffffffc020284a:	7b9c                	ld	a5,48(a5)
ffffffffc020284c:	854a                	mv	a0,s2
ffffffffc020284e:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202850:	e12d                	bnez	a0,ffffffffc02028b2 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202852:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202854:	01893503          	ld	a0,24(s2)
ffffffffc0202858:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc020285a:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020285c:	85a6                	mv	a1,s1
ffffffffc020285e:	4f5000ef          	jal	ra,ffffffffc0203552 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202862:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202864:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202866:	8b85                	andi	a5,a5,1
ffffffffc0202868:	cfb9                	beqz	a5,ffffffffc02028c6 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc020286a:	65a2                	ld	a1,8(sp)
ffffffffc020286c:	7d9c                	ld	a5,56(a1)
ffffffffc020286e:	83b1                	srli	a5,a5,0xc
ffffffffc0202870:	0785                	addi	a5,a5,1
ffffffffc0202872:	00879513          	slli	a0,a5,0x8
ffffffffc0202876:	3bc020ef          	jal	ra,ffffffffc0204c32 <swapfs_write>
ffffffffc020287a:	d949                	beqz	a0,ffffffffc020280c <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc020287c:	855e                	mv	a0,s7
ffffffffc020287e:	84ffd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202882:	0009b783          	ld	a5,0(s3)
ffffffffc0202886:	6622                	ld	a2,8(sp)
ffffffffc0202888:	4681                	li	a3,0
ffffffffc020288a:	739c                	ld	a5,32(a5)
ffffffffc020288c:	85a6                	mv	a1,s1
ffffffffc020288e:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202890:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202892:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202894:	fa8a17e3          	bne	s4,s0,ffffffffc0202842 <swap_out+0x70>
}
ffffffffc0202898:	60e6                	ld	ra,88(sp)
ffffffffc020289a:	8522                	mv	a0,s0
ffffffffc020289c:	6446                	ld	s0,80(sp)
ffffffffc020289e:	64a6                	ld	s1,72(sp)
ffffffffc02028a0:	6906                	ld	s2,64(sp)
ffffffffc02028a2:	79e2                	ld	s3,56(sp)
ffffffffc02028a4:	7a42                	ld	s4,48(sp)
ffffffffc02028a6:	7aa2                	ld	s5,40(sp)
ffffffffc02028a8:	7b02                	ld	s6,32(sp)
ffffffffc02028aa:	6be2                	ld	s7,24(sp)
ffffffffc02028ac:	6c42                	ld	s8,16(sp)
ffffffffc02028ae:	6125                	addi	sp,sp,96
ffffffffc02028b0:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02028b2:	85a2                	mv	a1,s0
ffffffffc02028b4:	00005517          	auipc	a0,0x5
ffffffffc02028b8:	01c50513          	addi	a0,a0,28 # ffffffffc02078d0 <commands+0x1060>
ffffffffc02028bc:	811fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                  break;
ffffffffc02028c0:	bfe1                	j	ffffffffc0202898 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02028c2:	4401                	li	s0,0
ffffffffc02028c4:	bfd1                	j	ffffffffc0202898 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02028c6:	00005697          	auipc	a3,0x5
ffffffffc02028ca:	03a68693          	addi	a3,a3,58 # ffffffffc0207900 <commands+0x1090>
ffffffffc02028ce:	00004617          	auipc	a2,0x4
ffffffffc02028d2:	3b260613          	addi	a2,a2,946 # ffffffffc0206c80 <commands+0x410>
ffffffffc02028d6:	06800593          	li	a1,104
ffffffffc02028da:	00005517          	auipc	a0,0x5
ffffffffc02028de:	d4650513          	addi	a0,a0,-698 # ffffffffc0207620 <commands+0xdb0>
ffffffffc02028e2:	927fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02028e6 <swap_in>:
{
ffffffffc02028e6:	7179                	addi	sp,sp,-48
ffffffffc02028e8:	e84a                	sd	s2,16(sp)
ffffffffc02028ea:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02028ec:	4505                	li	a0,1
{
ffffffffc02028ee:	ec26                	sd	s1,24(sp)
ffffffffc02028f0:	e44e                	sd	s3,8(sp)
ffffffffc02028f2:	f406                	sd	ra,40(sp)
ffffffffc02028f4:	f022                	sd	s0,32(sp)
ffffffffc02028f6:	84ae                	mv	s1,a1
ffffffffc02028f8:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02028fa:	34d000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
     assert(result!=NULL);
ffffffffc02028fe:	c129                	beqz	a0,ffffffffc0202940 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202900:	842a                	mv	s0,a0
ffffffffc0202902:	01893503          	ld	a0,24(s2)
ffffffffc0202906:	4601                	li	a2,0
ffffffffc0202908:	85a6                	mv	a1,s1
ffffffffc020290a:	449000ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc020290e:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0202910:	6108                	ld	a0,0(a0)
ffffffffc0202912:	85a2                	mv	a1,s0
ffffffffc0202914:	290020ef          	jal	ra,ffffffffc0204ba4 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202918:	00093583          	ld	a1,0(s2)
ffffffffc020291c:	8626                	mv	a2,s1
ffffffffc020291e:	00005517          	auipc	a0,0x5
ffffffffc0202922:	06250513          	addi	a0,a0,98 # ffffffffc0207980 <commands+0x1110>
ffffffffc0202926:	81a1                	srli	a1,a1,0x8
ffffffffc0202928:	fa4fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc020292c:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc020292e:	0089b023          	sd	s0,0(s3)
}
ffffffffc0202932:	7402                	ld	s0,32(sp)
ffffffffc0202934:	64e2                	ld	s1,24(sp)
ffffffffc0202936:	6942                	ld	s2,16(sp)
ffffffffc0202938:	69a2                	ld	s3,8(sp)
ffffffffc020293a:	4501                	li	a0,0
ffffffffc020293c:	6145                	addi	sp,sp,48
ffffffffc020293e:	8082                	ret
     assert(result!=NULL);
ffffffffc0202940:	00005697          	auipc	a3,0x5
ffffffffc0202944:	03068693          	addi	a3,a3,48 # ffffffffc0207970 <commands+0x1100>
ffffffffc0202948:	00004617          	auipc	a2,0x4
ffffffffc020294c:	33860613          	addi	a2,a2,824 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202950:	07e00593          	li	a1,126
ffffffffc0202954:	00005517          	auipc	a0,0x5
ffffffffc0202958:	ccc50513          	addi	a0,a0,-820 # ffffffffc0207620 <commands+0xdb0>
ffffffffc020295c:	8adfd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202960 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0202960:	000ac797          	auipc	a5,0xac
ffffffffc0202964:	e4078793          	addi	a5,a5,-448 # ffffffffc02ae7a0 <free_area>
ffffffffc0202968:	e79c                	sd	a5,8(a5)
ffffffffc020296a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020296c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0202970:	8082                	ret

ffffffffc0202972 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0202972:	000ac517          	auipc	a0,0xac
ffffffffc0202976:	e3e56503          	lwu	a0,-450(a0) # ffffffffc02ae7b0 <free_area+0x10>
ffffffffc020297a:	8082                	ret

ffffffffc020297c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc020297c:	715d                	addi	sp,sp,-80
ffffffffc020297e:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0202980:	000ac417          	auipc	s0,0xac
ffffffffc0202984:	e2040413          	addi	s0,s0,-480 # ffffffffc02ae7a0 <free_area>
ffffffffc0202988:	641c                	ld	a5,8(s0)
ffffffffc020298a:	e486                	sd	ra,72(sp)
ffffffffc020298c:	fc26                	sd	s1,56(sp)
ffffffffc020298e:	f84a                	sd	s2,48(sp)
ffffffffc0202990:	f44e                	sd	s3,40(sp)
ffffffffc0202992:	f052                	sd	s4,32(sp)
ffffffffc0202994:	ec56                	sd	s5,24(sp)
ffffffffc0202996:	e85a                	sd	s6,16(sp)
ffffffffc0202998:	e45e                	sd	s7,8(sp)
ffffffffc020299a:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020299c:	2a878d63          	beq	a5,s0,ffffffffc0202c56 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc02029a0:	4481                	li	s1,0
ffffffffc02029a2:	4901                	li	s2,0
ffffffffc02029a4:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02029a8:	8b09                	andi	a4,a4,2
ffffffffc02029aa:	2a070a63          	beqz	a4,ffffffffc0202c5e <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc02029ae:	ff87a703          	lw	a4,-8(a5)
ffffffffc02029b2:	679c                	ld	a5,8(a5)
ffffffffc02029b4:	2905                	addiw	s2,s2,1
ffffffffc02029b6:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02029b8:	fe8796e3          	bne	a5,s0,ffffffffc02029a4 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc02029bc:	89a6                	mv	s3,s1
ffffffffc02029be:	35b000ef          	jal	ra,ffffffffc0203518 <nr_free_pages>
ffffffffc02029c2:	6f351e63          	bne	a0,s3,ffffffffc02030be <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02029c6:	4505                	li	a0,1
ffffffffc02029c8:	27f000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc02029cc:	8aaa                	mv	s5,a0
ffffffffc02029ce:	42050863          	beqz	a0,ffffffffc0202dfe <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02029d2:	4505                	li	a0,1
ffffffffc02029d4:	273000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc02029d8:	89aa                	mv	s3,a0
ffffffffc02029da:	70050263          	beqz	a0,ffffffffc02030de <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02029de:	4505                	li	a0,1
ffffffffc02029e0:	267000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc02029e4:	8a2a                	mv	s4,a0
ffffffffc02029e6:	48050c63          	beqz	a0,ffffffffc0202e7e <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02029ea:	293a8a63          	beq	s5,s3,ffffffffc0202c7e <default_check+0x302>
ffffffffc02029ee:	28aa8863          	beq	s5,a0,ffffffffc0202c7e <default_check+0x302>
ffffffffc02029f2:	28a98663          	beq	s3,a0,ffffffffc0202c7e <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02029f6:	000aa783          	lw	a5,0(s5)
ffffffffc02029fa:	2a079263          	bnez	a5,ffffffffc0202c9e <default_check+0x322>
ffffffffc02029fe:	0009a783          	lw	a5,0(s3)
ffffffffc0202a02:	28079e63          	bnez	a5,ffffffffc0202c9e <default_check+0x322>
ffffffffc0202a06:	411c                	lw	a5,0(a0)
ffffffffc0202a08:	28079b63          	bnez	a5,ffffffffc0202c9e <default_check+0x322>
    return page - pages + nbase;
ffffffffc0202a0c:	000b0797          	auipc	a5,0xb0
ffffffffc0202a10:	e1c7b783          	ld	a5,-484(a5) # ffffffffc02b2828 <pages>
ffffffffc0202a14:	40fa8733          	sub	a4,s5,a5
ffffffffc0202a18:	00006617          	auipc	a2,0x6
ffffffffc0202a1c:	28863603          	ld	a2,648(a2) # ffffffffc0208ca0 <nbase>
ffffffffc0202a20:	8719                	srai	a4,a4,0x6
ffffffffc0202a22:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202a24:	000b0697          	auipc	a3,0xb0
ffffffffc0202a28:	dfc6b683          	ld	a3,-516(a3) # ffffffffc02b2820 <npage>
ffffffffc0202a2c:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a2e:	0732                	slli	a4,a4,0xc
ffffffffc0202a30:	28d77763          	bgeu	a4,a3,ffffffffc0202cbe <default_check+0x342>
    return page - pages + nbase;
ffffffffc0202a34:	40f98733          	sub	a4,s3,a5
ffffffffc0202a38:	8719                	srai	a4,a4,0x6
ffffffffc0202a3a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a3c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202a3e:	4cd77063          	bgeu	a4,a3,ffffffffc0202efe <default_check+0x582>
    return page - pages + nbase;
ffffffffc0202a42:	40f507b3          	sub	a5,a0,a5
ffffffffc0202a46:	8799                	srai	a5,a5,0x6
ffffffffc0202a48:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a4a:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202a4c:	30d7f963          	bgeu	a5,a3,ffffffffc0202d5e <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0202a50:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202a52:	00043c03          	ld	s8,0(s0)
ffffffffc0202a56:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0202a5a:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0202a5e:	e400                	sd	s0,8(s0)
ffffffffc0202a60:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0202a62:	000ac797          	auipc	a5,0xac
ffffffffc0202a66:	d407a723          	sw	zero,-690(a5) # ffffffffc02ae7b0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202a6a:	1dd000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202a6e:	2c051863          	bnez	a0,ffffffffc0202d3e <default_check+0x3c2>
    free_page(p0);
ffffffffc0202a72:	4585                	li	a1,1
ffffffffc0202a74:	8556                	mv	a0,s5
ffffffffc0202a76:	263000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    free_page(p1);
ffffffffc0202a7a:	4585                	li	a1,1
ffffffffc0202a7c:	854e                	mv	a0,s3
ffffffffc0202a7e:	25b000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    free_page(p2);
ffffffffc0202a82:	4585                	li	a1,1
ffffffffc0202a84:	8552                	mv	a0,s4
ffffffffc0202a86:	253000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    assert(nr_free == 3);
ffffffffc0202a8a:	4818                	lw	a4,16(s0)
ffffffffc0202a8c:	478d                	li	a5,3
ffffffffc0202a8e:	28f71863          	bne	a4,a5,ffffffffc0202d1e <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202a92:	4505                	li	a0,1
ffffffffc0202a94:	1b3000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202a98:	89aa                	mv	s3,a0
ffffffffc0202a9a:	26050263          	beqz	a0,ffffffffc0202cfe <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202a9e:	4505                	li	a0,1
ffffffffc0202aa0:	1a7000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202aa4:	8aaa                	mv	s5,a0
ffffffffc0202aa6:	3a050c63          	beqz	a0,ffffffffc0202e5e <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202aaa:	4505                	li	a0,1
ffffffffc0202aac:	19b000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202ab0:	8a2a                	mv	s4,a0
ffffffffc0202ab2:	38050663          	beqz	a0,ffffffffc0202e3e <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0202ab6:	4505                	li	a0,1
ffffffffc0202ab8:	18f000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202abc:	36051163          	bnez	a0,ffffffffc0202e1e <default_check+0x4a2>
    free_page(p0);
ffffffffc0202ac0:	4585                	li	a1,1
ffffffffc0202ac2:	854e                	mv	a0,s3
ffffffffc0202ac4:	215000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202ac8:	641c                	ld	a5,8(s0)
ffffffffc0202aca:	20878a63          	beq	a5,s0,ffffffffc0202cde <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0202ace:	4505                	li	a0,1
ffffffffc0202ad0:	177000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202ad4:	30a99563          	bne	s3,a0,ffffffffc0202dde <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0202ad8:	4505                	li	a0,1
ffffffffc0202ada:	16d000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202ade:	2e051063          	bnez	a0,ffffffffc0202dbe <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0202ae2:	481c                	lw	a5,16(s0)
ffffffffc0202ae4:	2a079d63          	bnez	a5,ffffffffc0202d9e <default_check+0x422>
    free_page(p);
ffffffffc0202ae8:	854e                	mv	a0,s3
ffffffffc0202aea:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202aec:	01843023          	sd	s8,0(s0)
ffffffffc0202af0:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0202af4:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0202af8:	1e1000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    free_page(p1);
ffffffffc0202afc:	4585                	li	a1,1
ffffffffc0202afe:	8556                	mv	a0,s5
ffffffffc0202b00:	1d9000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    free_page(p2);
ffffffffc0202b04:	4585                	li	a1,1
ffffffffc0202b06:	8552                	mv	a0,s4
ffffffffc0202b08:	1d1000ef          	jal	ra,ffffffffc02034d8 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202b0c:	4515                	li	a0,5
ffffffffc0202b0e:	139000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202b12:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202b14:	26050563          	beqz	a0,ffffffffc0202d7e <default_check+0x402>
ffffffffc0202b18:	651c                	ld	a5,8(a0)
ffffffffc0202b1a:	8385                	srli	a5,a5,0x1
ffffffffc0202b1c:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0202b1e:	54079063          	bnez	a5,ffffffffc020305e <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202b22:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202b24:	00043b03          	ld	s6,0(s0)
ffffffffc0202b28:	00843a83          	ld	s5,8(s0)
ffffffffc0202b2c:	e000                	sd	s0,0(s0)
ffffffffc0202b2e:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0202b30:	117000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202b34:	50051563          	bnez	a0,ffffffffc020303e <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202b38:	08098a13          	addi	s4,s3,128
ffffffffc0202b3c:	8552                	mv	a0,s4
ffffffffc0202b3e:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202b40:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0202b44:	000ac797          	auipc	a5,0xac
ffffffffc0202b48:	c607a623          	sw	zero,-916(a5) # ffffffffc02ae7b0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202b4c:	18d000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0202b50:	4511                	li	a0,4
ffffffffc0202b52:	0f5000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202b56:	4c051463          	bnez	a0,ffffffffc020301e <default_check+0x6a2>
ffffffffc0202b5a:	0889b783          	ld	a5,136(s3)
ffffffffc0202b5e:	8385                	srli	a5,a5,0x1
ffffffffc0202b60:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202b62:	48078e63          	beqz	a5,ffffffffc0202ffe <default_check+0x682>
ffffffffc0202b66:	0909a703          	lw	a4,144(s3)
ffffffffc0202b6a:	478d                	li	a5,3
ffffffffc0202b6c:	48f71963          	bne	a4,a5,ffffffffc0202ffe <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202b70:	450d                	li	a0,3
ffffffffc0202b72:	0d5000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202b76:	8c2a                	mv	s8,a0
ffffffffc0202b78:	46050363          	beqz	a0,ffffffffc0202fde <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0202b7c:	4505                	li	a0,1
ffffffffc0202b7e:	0c9000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202b82:	42051e63          	bnez	a0,ffffffffc0202fbe <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0202b86:	418a1c63          	bne	s4,s8,ffffffffc0202f9e <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0202b8a:	4585                	li	a1,1
ffffffffc0202b8c:	854e                	mv	a0,s3
ffffffffc0202b8e:	14b000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    free_pages(p1, 3);
ffffffffc0202b92:	458d                	li	a1,3
ffffffffc0202b94:	8552                	mv	a0,s4
ffffffffc0202b96:	143000ef          	jal	ra,ffffffffc02034d8 <free_pages>
ffffffffc0202b9a:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202b9e:	04098c13          	addi	s8,s3,64
ffffffffc0202ba2:	8385                	srli	a5,a5,0x1
ffffffffc0202ba4:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202ba6:	3c078c63          	beqz	a5,ffffffffc0202f7e <default_check+0x602>
ffffffffc0202baa:	0109a703          	lw	a4,16(s3)
ffffffffc0202bae:	4785                	li	a5,1
ffffffffc0202bb0:	3cf71763          	bne	a4,a5,ffffffffc0202f7e <default_check+0x602>
ffffffffc0202bb4:	008a3783          	ld	a5,8(s4)
ffffffffc0202bb8:	8385                	srli	a5,a5,0x1
ffffffffc0202bba:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202bbc:	3a078163          	beqz	a5,ffffffffc0202f5e <default_check+0x5e2>
ffffffffc0202bc0:	010a2703          	lw	a4,16(s4)
ffffffffc0202bc4:	478d                	li	a5,3
ffffffffc0202bc6:	38f71c63          	bne	a4,a5,ffffffffc0202f5e <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202bca:	4505                	li	a0,1
ffffffffc0202bcc:	07b000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202bd0:	36a99763          	bne	s3,a0,ffffffffc0202f3e <default_check+0x5c2>
    free_page(p0);
ffffffffc0202bd4:	4585                	li	a1,1
ffffffffc0202bd6:	103000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202bda:	4509                	li	a0,2
ffffffffc0202bdc:	06b000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202be0:	32aa1f63          	bne	s4,a0,ffffffffc0202f1e <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0202be4:	4589                	li	a1,2
ffffffffc0202be6:	0f3000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    free_page(p2);
ffffffffc0202bea:	4585                	li	a1,1
ffffffffc0202bec:	8562                	mv	a0,s8
ffffffffc0202bee:	0eb000ef          	jal	ra,ffffffffc02034d8 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202bf2:	4515                	li	a0,5
ffffffffc0202bf4:	053000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202bf8:	89aa                	mv	s3,a0
ffffffffc0202bfa:	48050263          	beqz	a0,ffffffffc020307e <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0202bfe:	4505                	li	a0,1
ffffffffc0202c00:	047000ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0202c04:	2c051d63          	bnez	a0,ffffffffc0202ede <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0202c08:	481c                	lw	a5,16(s0)
ffffffffc0202c0a:	2a079a63          	bnez	a5,ffffffffc0202ebe <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0202c0e:	4595                	li	a1,5
ffffffffc0202c10:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0202c12:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0202c16:	01643023          	sd	s6,0(s0)
ffffffffc0202c1a:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0202c1e:	0bb000ef          	jal	ra,ffffffffc02034d8 <free_pages>
    return listelm->next;
ffffffffc0202c22:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202c24:	00878963          	beq	a5,s0,ffffffffc0202c36 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0202c28:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202c2c:	679c                	ld	a5,8(a5)
ffffffffc0202c2e:	397d                	addiw	s2,s2,-1
ffffffffc0202c30:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202c32:	fe879be3          	bne	a5,s0,ffffffffc0202c28 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0202c36:	26091463          	bnez	s2,ffffffffc0202e9e <default_check+0x522>
    assert(total == 0);
ffffffffc0202c3a:	46049263          	bnez	s1,ffffffffc020309e <default_check+0x722>
}
ffffffffc0202c3e:	60a6                	ld	ra,72(sp)
ffffffffc0202c40:	6406                	ld	s0,64(sp)
ffffffffc0202c42:	74e2                	ld	s1,56(sp)
ffffffffc0202c44:	7942                	ld	s2,48(sp)
ffffffffc0202c46:	79a2                	ld	s3,40(sp)
ffffffffc0202c48:	7a02                	ld	s4,32(sp)
ffffffffc0202c4a:	6ae2                	ld	s5,24(sp)
ffffffffc0202c4c:	6b42                	ld	s6,16(sp)
ffffffffc0202c4e:	6ba2                	ld	s7,8(sp)
ffffffffc0202c50:	6c02                	ld	s8,0(sp)
ffffffffc0202c52:	6161                	addi	sp,sp,80
ffffffffc0202c54:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202c56:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0202c58:	4481                	li	s1,0
ffffffffc0202c5a:	4901                	li	s2,0
ffffffffc0202c5c:	b38d                	j	ffffffffc02029be <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0202c5e:	00005697          	auipc	a3,0x5
ffffffffc0202c62:	9ea68693          	addi	a3,a3,-1558 # ffffffffc0207648 <commands+0xdd8>
ffffffffc0202c66:	00004617          	auipc	a2,0x4
ffffffffc0202c6a:	01a60613          	addi	a2,a2,26 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202c6e:	0f000593          	li	a1,240
ffffffffc0202c72:	00005517          	auipc	a0,0x5
ffffffffc0202c76:	d4e50513          	addi	a0,a0,-690 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202c7a:	d8efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202c7e:	00005697          	auipc	a3,0x5
ffffffffc0202c82:	dba68693          	addi	a3,a3,-582 # ffffffffc0207a38 <commands+0x11c8>
ffffffffc0202c86:	00004617          	auipc	a2,0x4
ffffffffc0202c8a:	ffa60613          	addi	a2,a2,-6 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202c8e:	0bd00593          	li	a1,189
ffffffffc0202c92:	00005517          	auipc	a0,0x5
ffffffffc0202c96:	d2e50513          	addi	a0,a0,-722 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202c9a:	d6efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202c9e:	00005697          	auipc	a3,0x5
ffffffffc0202ca2:	dc268693          	addi	a3,a3,-574 # ffffffffc0207a60 <commands+0x11f0>
ffffffffc0202ca6:	00004617          	auipc	a2,0x4
ffffffffc0202caa:	fda60613          	addi	a2,a2,-38 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202cae:	0be00593          	li	a1,190
ffffffffc0202cb2:	00005517          	auipc	a0,0x5
ffffffffc0202cb6:	d0e50513          	addi	a0,a0,-754 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202cba:	d4efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202cbe:	00005697          	auipc	a3,0x5
ffffffffc0202cc2:	de268693          	addi	a3,a3,-542 # ffffffffc0207aa0 <commands+0x1230>
ffffffffc0202cc6:	00004617          	auipc	a2,0x4
ffffffffc0202cca:	fba60613          	addi	a2,a2,-70 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202cce:	0c000593          	li	a1,192
ffffffffc0202cd2:	00005517          	auipc	a0,0x5
ffffffffc0202cd6:	cee50513          	addi	a0,a0,-786 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202cda:	d2efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202cde:	00005697          	auipc	a3,0x5
ffffffffc0202ce2:	e4a68693          	addi	a3,a3,-438 # ffffffffc0207b28 <commands+0x12b8>
ffffffffc0202ce6:	00004617          	auipc	a2,0x4
ffffffffc0202cea:	f9a60613          	addi	a2,a2,-102 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202cee:	0d900593          	li	a1,217
ffffffffc0202cf2:	00005517          	auipc	a0,0x5
ffffffffc0202cf6:	cce50513          	addi	a0,a0,-818 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202cfa:	d0efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202cfe:	00005697          	auipc	a3,0x5
ffffffffc0202d02:	cda68693          	addi	a3,a3,-806 # ffffffffc02079d8 <commands+0x1168>
ffffffffc0202d06:	00004617          	auipc	a2,0x4
ffffffffc0202d0a:	f7a60613          	addi	a2,a2,-134 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202d0e:	0d200593          	li	a1,210
ffffffffc0202d12:	00005517          	auipc	a0,0x5
ffffffffc0202d16:	cae50513          	addi	a0,a0,-850 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202d1a:	ceefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 3);
ffffffffc0202d1e:	00005697          	auipc	a3,0x5
ffffffffc0202d22:	dfa68693          	addi	a3,a3,-518 # ffffffffc0207b18 <commands+0x12a8>
ffffffffc0202d26:	00004617          	auipc	a2,0x4
ffffffffc0202d2a:	f5a60613          	addi	a2,a2,-166 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202d2e:	0d000593          	li	a1,208
ffffffffc0202d32:	00005517          	auipc	a0,0x5
ffffffffc0202d36:	c8e50513          	addi	a0,a0,-882 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202d3a:	ccefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202d3e:	00005697          	auipc	a3,0x5
ffffffffc0202d42:	dc268693          	addi	a3,a3,-574 # ffffffffc0207b00 <commands+0x1290>
ffffffffc0202d46:	00004617          	auipc	a2,0x4
ffffffffc0202d4a:	f3a60613          	addi	a2,a2,-198 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202d4e:	0cb00593          	li	a1,203
ffffffffc0202d52:	00005517          	auipc	a0,0x5
ffffffffc0202d56:	c6e50513          	addi	a0,a0,-914 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202d5a:	caefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202d5e:	00005697          	auipc	a3,0x5
ffffffffc0202d62:	d8268693          	addi	a3,a3,-638 # ffffffffc0207ae0 <commands+0x1270>
ffffffffc0202d66:	00004617          	auipc	a2,0x4
ffffffffc0202d6a:	f1a60613          	addi	a2,a2,-230 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202d6e:	0c200593          	li	a1,194
ffffffffc0202d72:	00005517          	auipc	a0,0x5
ffffffffc0202d76:	c4e50513          	addi	a0,a0,-946 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202d7a:	c8efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != NULL);
ffffffffc0202d7e:	00005697          	auipc	a3,0x5
ffffffffc0202d82:	de268693          	addi	a3,a3,-542 # ffffffffc0207b60 <commands+0x12f0>
ffffffffc0202d86:	00004617          	auipc	a2,0x4
ffffffffc0202d8a:	efa60613          	addi	a2,a2,-262 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202d8e:	0f800593          	li	a1,248
ffffffffc0202d92:	00005517          	auipc	a0,0x5
ffffffffc0202d96:	c2e50513          	addi	a0,a0,-978 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202d9a:	c6efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc0202d9e:	00005697          	auipc	a3,0x5
ffffffffc0202da2:	a4a68693          	addi	a3,a3,-1462 # ffffffffc02077e8 <commands+0xf78>
ffffffffc0202da6:	00004617          	auipc	a2,0x4
ffffffffc0202daa:	eda60613          	addi	a2,a2,-294 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202dae:	0df00593          	li	a1,223
ffffffffc0202db2:	00005517          	auipc	a0,0x5
ffffffffc0202db6:	c0e50513          	addi	a0,a0,-1010 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202dba:	c4efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202dbe:	00005697          	auipc	a3,0x5
ffffffffc0202dc2:	d4268693          	addi	a3,a3,-702 # ffffffffc0207b00 <commands+0x1290>
ffffffffc0202dc6:	00004617          	auipc	a2,0x4
ffffffffc0202dca:	eba60613          	addi	a2,a2,-326 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202dce:	0dd00593          	li	a1,221
ffffffffc0202dd2:	00005517          	auipc	a0,0x5
ffffffffc0202dd6:	bee50513          	addi	a0,a0,-1042 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202dda:	c2efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202dde:	00005697          	auipc	a3,0x5
ffffffffc0202de2:	d6268693          	addi	a3,a3,-670 # ffffffffc0207b40 <commands+0x12d0>
ffffffffc0202de6:	00004617          	auipc	a2,0x4
ffffffffc0202dea:	e9a60613          	addi	a2,a2,-358 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202dee:	0dc00593          	li	a1,220
ffffffffc0202df2:	00005517          	auipc	a0,0x5
ffffffffc0202df6:	bce50513          	addi	a0,a0,-1074 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202dfa:	c0efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202dfe:	00005697          	auipc	a3,0x5
ffffffffc0202e02:	bda68693          	addi	a3,a3,-1062 # ffffffffc02079d8 <commands+0x1168>
ffffffffc0202e06:	00004617          	auipc	a2,0x4
ffffffffc0202e0a:	e7a60613          	addi	a2,a2,-390 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202e0e:	0b900593          	li	a1,185
ffffffffc0202e12:	00005517          	auipc	a0,0x5
ffffffffc0202e16:	bae50513          	addi	a0,a0,-1106 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202e1a:	beefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202e1e:	00005697          	auipc	a3,0x5
ffffffffc0202e22:	ce268693          	addi	a3,a3,-798 # ffffffffc0207b00 <commands+0x1290>
ffffffffc0202e26:	00004617          	auipc	a2,0x4
ffffffffc0202e2a:	e5a60613          	addi	a2,a2,-422 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202e2e:	0d600593          	li	a1,214
ffffffffc0202e32:	00005517          	auipc	a0,0x5
ffffffffc0202e36:	b8e50513          	addi	a0,a0,-1138 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202e3a:	bcefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202e3e:	00005697          	auipc	a3,0x5
ffffffffc0202e42:	bda68693          	addi	a3,a3,-1062 # ffffffffc0207a18 <commands+0x11a8>
ffffffffc0202e46:	00004617          	auipc	a2,0x4
ffffffffc0202e4a:	e3a60613          	addi	a2,a2,-454 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202e4e:	0d400593          	li	a1,212
ffffffffc0202e52:	00005517          	auipc	a0,0x5
ffffffffc0202e56:	b6e50513          	addi	a0,a0,-1170 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202e5a:	baefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202e5e:	00005697          	auipc	a3,0x5
ffffffffc0202e62:	b9a68693          	addi	a3,a3,-1126 # ffffffffc02079f8 <commands+0x1188>
ffffffffc0202e66:	00004617          	auipc	a2,0x4
ffffffffc0202e6a:	e1a60613          	addi	a2,a2,-486 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202e6e:	0d300593          	li	a1,211
ffffffffc0202e72:	00005517          	auipc	a0,0x5
ffffffffc0202e76:	b4e50513          	addi	a0,a0,-1202 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202e7a:	b8efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202e7e:	00005697          	auipc	a3,0x5
ffffffffc0202e82:	b9a68693          	addi	a3,a3,-1126 # ffffffffc0207a18 <commands+0x11a8>
ffffffffc0202e86:	00004617          	auipc	a2,0x4
ffffffffc0202e8a:	dfa60613          	addi	a2,a2,-518 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202e8e:	0bb00593          	li	a1,187
ffffffffc0202e92:	00005517          	auipc	a0,0x5
ffffffffc0202e96:	b2e50513          	addi	a0,a0,-1234 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202e9a:	b6efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(count == 0);
ffffffffc0202e9e:	00005697          	auipc	a3,0x5
ffffffffc0202ea2:	e1268693          	addi	a3,a3,-494 # ffffffffc0207cb0 <commands+0x1440>
ffffffffc0202ea6:	00004617          	auipc	a2,0x4
ffffffffc0202eaa:	dda60613          	addi	a2,a2,-550 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202eae:	12500593          	li	a1,293
ffffffffc0202eb2:	00005517          	auipc	a0,0x5
ffffffffc0202eb6:	b0e50513          	addi	a0,a0,-1266 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202eba:	b4efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc0202ebe:	00005697          	auipc	a3,0x5
ffffffffc0202ec2:	92a68693          	addi	a3,a3,-1750 # ffffffffc02077e8 <commands+0xf78>
ffffffffc0202ec6:	00004617          	auipc	a2,0x4
ffffffffc0202eca:	dba60613          	addi	a2,a2,-582 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202ece:	11a00593          	li	a1,282
ffffffffc0202ed2:	00005517          	auipc	a0,0x5
ffffffffc0202ed6:	aee50513          	addi	a0,a0,-1298 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202eda:	b2efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202ede:	00005697          	auipc	a3,0x5
ffffffffc0202ee2:	c2268693          	addi	a3,a3,-990 # ffffffffc0207b00 <commands+0x1290>
ffffffffc0202ee6:	00004617          	auipc	a2,0x4
ffffffffc0202eea:	d9a60613          	addi	a2,a2,-614 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202eee:	11800593          	li	a1,280
ffffffffc0202ef2:	00005517          	auipc	a0,0x5
ffffffffc0202ef6:	ace50513          	addi	a0,a0,-1330 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202efa:	b0efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202efe:	00005697          	auipc	a3,0x5
ffffffffc0202f02:	bc268693          	addi	a3,a3,-1086 # ffffffffc0207ac0 <commands+0x1250>
ffffffffc0202f06:	00004617          	auipc	a2,0x4
ffffffffc0202f0a:	d7a60613          	addi	a2,a2,-646 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202f0e:	0c100593          	li	a1,193
ffffffffc0202f12:	00005517          	auipc	a0,0x5
ffffffffc0202f16:	aae50513          	addi	a0,a0,-1362 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202f1a:	aeefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202f1e:	00005697          	auipc	a3,0x5
ffffffffc0202f22:	d5268693          	addi	a3,a3,-686 # ffffffffc0207c70 <commands+0x1400>
ffffffffc0202f26:	00004617          	auipc	a2,0x4
ffffffffc0202f2a:	d5a60613          	addi	a2,a2,-678 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202f2e:	11200593          	li	a1,274
ffffffffc0202f32:	00005517          	auipc	a0,0x5
ffffffffc0202f36:	a8e50513          	addi	a0,a0,-1394 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202f3a:	acefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202f3e:	00005697          	auipc	a3,0x5
ffffffffc0202f42:	d1268693          	addi	a3,a3,-750 # ffffffffc0207c50 <commands+0x13e0>
ffffffffc0202f46:	00004617          	auipc	a2,0x4
ffffffffc0202f4a:	d3a60613          	addi	a2,a2,-710 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202f4e:	11000593          	li	a1,272
ffffffffc0202f52:	00005517          	auipc	a0,0x5
ffffffffc0202f56:	a6e50513          	addi	a0,a0,-1426 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202f5a:	aaefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202f5e:	00005697          	auipc	a3,0x5
ffffffffc0202f62:	cca68693          	addi	a3,a3,-822 # ffffffffc0207c28 <commands+0x13b8>
ffffffffc0202f66:	00004617          	auipc	a2,0x4
ffffffffc0202f6a:	d1a60613          	addi	a2,a2,-742 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202f6e:	10e00593          	li	a1,270
ffffffffc0202f72:	00005517          	auipc	a0,0x5
ffffffffc0202f76:	a4e50513          	addi	a0,a0,-1458 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202f7a:	a8efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202f7e:	00005697          	auipc	a3,0x5
ffffffffc0202f82:	c8268693          	addi	a3,a3,-894 # ffffffffc0207c00 <commands+0x1390>
ffffffffc0202f86:	00004617          	auipc	a2,0x4
ffffffffc0202f8a:	cfa60613          	addi	a2,a2,-774 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202f8e:	10d00593          	li	a1,269
ffffffffc0202f92:	00005517          	auipc	a0,0x5
ffffffffc0202f96:	a2e50513          	addi	a0,a0,-1490 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202f9a:	a6efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0202f9e:	00005697          	auipc	a3,0x5
ffffffffc0202fa2:	c5268693          	addi	a3,a3,-942 # ffffffffc0207bf0 <commands+0x1380>
ffffffffc0202fa6:	00004617          	auipc	a2,0x4
ffffffffc0202faa:	cda60613          	addi	a2,a2,-806 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202fae:	10800593          	li	a1,264
ffffffffc0202fb2:	00005517          	auipc	a0,0x5
ffffffffc0202fb6:	a0e50513          	addi	a0,a0,-1522 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202fba:	a4efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202fbe:	00005697          	auipc	a3,0x5
ffffffffc0202fc2:	b4268693          	addi	a3,a3,-1214 # ffffffffc0207b00 <commands+0x1290>
ffffffffc0202fc6:	00004617          	auipc	a2,0x4
ffffffffc0202fca:	cba60613          	addi	a2,a2,-838 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202fce:	10700593          	li	a1,263
ffffffffc0202fd2:	00005517          	auipc	a0,0x5
ffffffffc0202fd6:	9ee50513          	addi	a0,a0,-1554 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202fda:	a2efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202fde:	00005697          	auipc	a3,0x5
ffffffffc0202fe2:	bf268693          	addi	a3,a3,-1038 # ffffffffc0207bd0 <commands+0x1360>
ffffffffc0202fe6:	00004617          	auipc	a2,0x4
ffffffffc0202fea:	c9a60613          	addi	a2,a2,-870 # ffffffffc0206c80 <commands+0x410>
ffffffffc0202fee:	10600593          	li	a1,262
ffffffffc0202ff2:	00005517          	auipc	a0,0x5
ffffffffc0202ff6:	9ce50513          	addi	a0,a0,-1586 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0202ffa:	a0efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202ffe:	00005697          	auipc	a3,0x5
ffffffffc0203002:	ba268693          	addi	a3,a3,-1118 # ffffffffc0207ba0 <commands+0x1330>
ffffffffc0203006:	00004617          	auipc	a2,0x4
ffffffffc020300a:	c7a60613          	addi	a2,a2,-902 # ffffffffc0206c80 <commands+0x410>
ffffffffc020300e:	10500593          	li	a1,261
ffffffffc0203012:	00005517          	auipc	a0,0x5
ffffffffc0203016:	9ae50513          	addi	a0,a0,-1618 # ffffffffc02079c0 <commands+0x1150>
ffffffffc020301a:	9eefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020301e:	00005697          	auipc	a3,0x5
ffffffffc0203022:	b6a68693          	addi	a3,a3,-1174 # ffffffffc0207b88 <commands+0x1318>
ffffffffc0203026:	00004617          	auipc	a2,0x4
ffffffffc020302a:	c5a60613          	addi	a2,a2,-934 # ffffffffc0206c80 <commands+0x410>
ffffffffc020302e:	10400593          	li	a1,260
ffffffffc0203032:	00005517          	auipc	a0,0x5
ffffffffc0203036:	98e50513          	addi	a0,a0,-1650 # ffffffffc02079c0 <commands+0x1150>
ffffffffc020303a:	9cefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020303e:	00005697          	auipc	a3,0x5
ffffffffc0203042:	ac268693          	addi	a3,a3,-1342 # ffffffffc0207b00 <commands+0x1290>
ffffffffc0203046:	00004617          	auipc	a2,0x4
ffffffffc020304a:	c3a60613          	addi	a2,a2,-966 # ffffffffc0206c80 <commands+0x410>
ffffffffc020304e:	0fe00593          	li	a1,254
ffffffffc0203052:	00005517          	auipc	a0,0x5
ffffffffc0203056:	96e50513          	addi	a0,a0,-1682 # ffffffffc02079c0 <commands+0x1150>
ffffffffc020305a:	9aefd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!PageProperty(p0));
ffffffffc020305e:	00005697          	auipc	a3,0x5
ffffffffc0203062:	b1268693          	addi	a3,a3,-1262 # ffffffffc0207b70 <commands+0x1300>
ffffffffc0203066:	00004617          	auipc	a2,0x4
ffffffffc020306a:	c1a60613          	addi	a2,a2,-998 # ffffffffc0206c80 <commands+0x410>
ffffffffc020306e:	0f900593          	li	a1,249
ffffffffc0203072:	00005517          	auipc	a0,0x5
ffffffffc0203076:	94e50513          	addi	a0,a0,-1714 # ffffffffc02079c0 <commands+0x1150>
ffffffffc020307a:	98efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020307e:	00005697          	auipc	a3,0x5
ffffffffc0203082:	c1268693          	addi	a3,a3,-1006 # ffffffffc0207c90 <commands+0x1420>
ffffffffc0203086:	00004617          	auipc	a2,0x4
ffffffffc020308a:	bfa60613          	addi	a2,a2,-1030 # ffffffffc0206c80 <commands+0x410>
ffffffffc020308e:	11700593          	li	a1,279
ffffffffc0203092:	00005517          	auipc	a0,0x5
ffffffffc0203096:	92e50513          	addi	a0,a0,-1746 # ffffffffc02079c0 <commands+0x1150>
ffffffffc020309a:	96efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == 0);
ffffffffc020309e:	00005697          	auipc	a3,0x5
ffffffffc02030a2:	c2268693          	addi	a3,a3,-990 # ffffffffc0207cc0 <commands+0x1450>
ffffffffc02030a6:	00004617          	auipc	a2,0x4
ffffffffc02030aa:	bda60613          	addi	a2,a2,-1062 # ffffffffc0206c80 <commands+0x410>
ffffffffc02030ae:	12600593          	li	a1,294
ffffffffc02030b2:	00005517          	auipc	a0,0x5
ffffffffc02030b6:	90e50513          	addi	a0,a0,-1778 # ffffffffc02079c0 <commands+0x1150>
ffffffffc02030ba:	94efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == nr_free_pages());
ffffffffc02030be:	00004697          	auipc	a3,0x4
ffffffffc02030c2:	59a68693          	addi	a3,a3,1434 # ffffffffc0207658 <commands+0xde8>
ffffffffc02030c6:	00004617          	auipc	a2,0x4
ffffffffc02030ca:	bba60613          	addi	a2,a2,-1094 # ffffffffc0206c80 <commands+0x410>
ffffffffc02030ce:	0f300593          	li	a1,243
ffffffffc02030d2:	00005517          	auipc	a0,0x5
ffffffffc02030d6:	8ee50513          	addi	a0,a0,-1810 # ffffffffc02079c0 <commands+0x1150>
ffffffffc02030da:	92efd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02030de:	00005697          	auipc	a3,0x5
ffffffffc02030e2:	91a68693          	addi	a3,a3,-1766 # ffffffffc02079f8 <commands+0x1188>
ffffffffc02030e6:	00004617          	auipc	a2,0x4
ffffffffc02030ea:	b9a60613          	addi	a2,a2,-1126 # ffffffffc0206c80 <commands+0x410>
ffffffffc02030ee:	0ba00593          	li	a1,186
ffffffffc02030f2:	00005517          	auipc	a0,0x5
ffffffffc02030f6:	8ce50513          	addi	a0,a0,-1842 # ffffffffc02079c0 <commands+0x1150>
ffffffffc02030fa:	90efd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02030fe <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02030fe:	1141                	addi	sp,sp,-16
ffffffffc0203100:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203102:	14058463          	beqz	a1,ffffffffc020324a <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0203106:	00659693          	slli	a3,a1,0x6
ffffffffc020310a:	96aa                	add	a3,a3,a0
ffffffffc020310c:	87aa                	mv	a5,a0
ffffffffc020310e:	02d50263          	beq	a0,a3,ffffffffc0203132 <default_free_pages+0x34>
ffffffffc0203112:	6798                	ld	a4,8(a5)
ffffffffc0203114:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203116:	10071a63          	bnez	a4,ffffffffc020322a <default_free_pages+0x12c>
ffffffffc020311a:	6798                	ld	a4,8(a5)
ffffffffc020311c:	8b09                	andi	a4,a4,2
ffffffffc020311e:	10071663          	bnez	a4,ffffffffc020322a <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0203122:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0203126:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020312a:	04078793          	addi	a5,a5,64
ffffffffc020312e:	fed792e3          	bne	a5,a3,ffffffffc0203112 <default_free_pages+0x14>
    base->property = n;
ffffffffc0203132:	2581                	sext.w	a1,a1
ffffffffc0203134:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0203136:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020313a:	4789                	li	a5,2
ffffffffc020313c:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0203140:	000ab697          	auipc	a3,0xab
ffffffffc0203144:	66068693          	addi	a3,a3,1632 # ffffffffc02ae7a0 <free_area>
ffffffffc0203148:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020314a:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020314c:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0203150:	9db9                	addw	a1,a1,a4
ffffffffc0203152:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0203154:	0ad78463          	beq	a5,a3,ffffffffc02031fc <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc0203158:	fe878713          	addi	a4,a5,-24
ffffffffc020315c:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203160:	4581                	li	a1,0
            if (base < page) {
ffffffffc0203162:	00e56a63          	bltu	a0,a4,ffffffffc0203176 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0203166:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203168:	04d70c63          	beq	a4,a3,ffffffffc02031c0 <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc020316c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020316e:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0203172:	fee57ae3          	bgeu	a0,a4,ffffffffc0203166 <default_free_pages+0x68>
ffffffffc0203176:	c199                	beqz	a1,ffffffffc020317c <default_free_pages+0x7e>
ffffffffc0203178:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020317c:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc020317e:	e390                	sd	a2,0(a5)
ffffffffc0203180:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203182:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203184:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0203186:	00d70d63          	beq	a4,a3,ffffffffc02031a0 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc020318a:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc020318e:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0203192:	02059813          	slli	a6,a1,0x20
ffffffffc0203196:	01a85793          	srli	a5,a6,0x1a
ffffffffc020319a:	97b2                	add	a5,a5,a2
ffffffffc020319c:	02f50c63          	beq	a0,a5,ffffffffc02031d4 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc02031a0:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02031a2:	00d78c63          	beq	a5,a3,ffffffffc02031ba <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc02031a6:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc02031a8:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc02031ac:	02061593          	slli	a1,a2,0x20
ffffffffc02031b0:	01a5d713          	srli	a4,a1,0x1a
ffffffffc02031b4:	972a                	add	a4,a4,a0
ffffffffc02031b6:	04e68a63          	beq	a3,a4,ffffffffc020320a <default_free_pages+0x10c>
}
ffffffffc02031ba:	60a2                	ld	ra,8(sp)
ffffffffc02031bc:	0141                	addi	sp,sp,16
ffffffffc02031be:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02031c0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02031c2:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02031c4:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02031c6:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02031c8:	02d70763          	beq	a4,a3,ffffffffc02031f6 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc02031cc:	8832                	mv	a6,a2
ffffffffc02031ce:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02031d0:	87ba                	mv	a5,a4
ffffffffc02031d2:	bf71                	j	ffffffffc020316e <default_free_pages+0x70>
            p->property += base->property;
ffffffffc02031d4:	491c                	lw	a5,16(a0)
ffffffffc02031d6:	9dbd                	addw	a1,a1,a5
ffffffffc02031d8:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02031dc:	57f5                	li	a5,-3
ffffffffc02031de:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02031e2:	01853803          	ld	a6,24(a0)
ffffffffc02031e6:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc02031e8:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc02031ea:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc02031ee:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc02031f0:	0105b023          	sd	a6,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc02031f4:	b77d                	j	ffffffffc02031a2 <default_free_pages+0xa4>
ffffffffc02031f6:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02031f8:	873e                	mv	a4,a5
ffffffffc02031fa:	bf41                	j	ffffffffc020318a <default_free_pages+0x8c>
}
ffffffffc02031fc:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02031fe:	e390                	sd	a2,0(a5)
ffffffffc0203200:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203202:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203204:	ed1c                	sd	a5,24(a0)
ffffffffc0203206:	0141                	addi	sp,sp,16
ffffffffc0203208:	8082                	ret
            base->property += p->property;
ffffffffc020320a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020320e:	ff078693          	addi	a3,a5,-16
ffffffffc0203212:	9e39                	addw	a2,a2,a4
ffffffffc0203214:	c910                	sw	a2,16(a0)
ffffffffc0203216:	5775                	li	a4,-3
ffffffffc0203218:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020321c:	6398                	ld	a4,0(a5)
ffffffffc020321e:	679c                	ld	a5,8(a5)
}
ffffffffc0203220:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0203222:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203224:	e398                	sd	a4,0(a5)
ffffffffc0203226:	0141                	addi	sp,sp,16
ffffffffc0203228:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020322a:	00005697          	auipc	a3,0x5
ffffffffc020322e:	aae68693          	addi	a3,a3,-1362 # ffffffffc0207cd8 <commands+0x1468>
ffffffffc0203232:	00004617          	auipc	a2,0x4
ffffffffc0203236:	a4e60613          	addi	a2,a2,-1458 # ffffffffc0206c80 <commands+0x410>
ffffffffc020323a:	08300593          	li	a1,131
ffffffffc020323e:	00004517          	auipc	a0,0x4
ffffffffc0203242:	78250513          	addi	a0,a0,1922 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0203246:	fc3fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc020324a:	00005697          	auipc	a3,0x5
ffffffffc020324e:	a8668693          	addi	a3,a3,-1402 # ffffffffc0207cd0 <commands+0x1460>
ffffffffc0203252:	00004617          	auipc	a2,0x4
ffffffffc0203256:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0206c80 <commands+0x410>
ffffffffc020325a:	08000593          	li	a1,128
ffffffffc020325e:	00004517          	auipc	a0,0x4
ffffffffc0203262:	76250513          	addi	a0,a0,1890 # ffffffffc02079c0 <commands+0x1150>
ffffffffc0203266:	fa3fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020326a <default_alloc_pages>:
    assert(n > 0);
ffffffffc020326a:	c941                	beqz	a0,ffffffffc02032fa <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc020326c:	000ab597          	auipc	a1,0xab
ffffffffc0203270:	53458593          	addi	a1,a1,1332 # ffffffffc02ae7a0 <free_area>
ffffffffc0203274:	0105a803          	lw	a6,16(a1)
ffffffffc0203278:	872a                	mv	a4,a0
ffffffffc020327a:	02081793          	slli	a5,a6,0x20
ffffffffc020327e:	9381                	srli	a5,a5,0x20
ffffffffc0203280:	00a7ee63          	bltu	a5,a0,ffffffffc020329c <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0203284:	87ae                	mv	a5,a1
ffffffffc0203286:	a801                	j	ffffffffc0203296 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0203288:	ff87a683          	lw	a3,-8(a5)
ffffffffc020328c:	02069613          	slli	a2,a3,0x20
ffffffffc0203290:	9201                	srli	a2,a2,0x20
ffffffffc0203292:	00e67763          	bgeu	a2,a4,ffffffffc02032a0 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0203296:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203298:	feb798e3          	bne	a5,a1,ffffffffc0203288 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020329c:	4501                	li	a0,0
}
ffffffffc020329e:	8082                	ret
    return listelm->prev;
ffffffffc02032a0:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02032a4:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02032a8:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc02032ac:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc02032b0:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02032b4:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02032b8:	02c77863          	bgeu	a4,a2,ffffffffc02032e8 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc02032bc:	071a                	slli	a4,a4,0x6
ffffffffc02032be:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02032c0:	41c686bb          	subw	a3,a3,t3
ffffffffc02032c4:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02032c6:	00870613          	addi	a2,a4,8
ffffffffc02032ca:	4689                	li	a3,2
ffffffffc02032cc:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02032d0:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02032d4:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc02032d8:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02032dc:	e290                	sd	a2,0(a3)
ffffffffc02032de:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02032e2:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02032e4:	01173c23          	sd	a7,24(a4)
ffffffffc02032e8:	41c8083b          	subw	a6,a6,t3
ffffffffc02032ec:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02032f0:	5775                	li	a4,-3
ffffffffc02032f2:	17c1                	addi	a5,a5,-16
ffffffffc02032f4:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02032f8:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02032fa:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02032fc:	00005697          	auipc	a3,0x5
ffffffffc0203300:	9d468693          	addi	a3,a3,-1580 # ffffffffc0207cd0 <commands+0x1460>
ffffffffc0203304:	00004617          	auipc	a2,0x4
ffffffffc0203308:	97c60613          	addi	a2,a2,-1668 # ffffffffc0206c80 <commands+0x410>
ffffffffc020330c:	06200593          	li	a1,98
ffffffffc0203310:	00004517          	auipc	a0,0x4
ffffffffc0203314:	6b050513          	addi	a0,a0,1712 # ffffffffc02079c0 <commands+0x1150>
default_alloc_pages(size_t n) {
ffffffffc0203318:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020331a:	eeffc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020331e <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020331e:	1141                	addi	sp,sp,-16
ffffffffc0203320:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203322:	c5f1                	beqz	a1,ffffffffc02033ee <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0203324:	00659693          	slli	a3,a1,0x6
ffffffffc0203328:	96aa                	add	a3,a3,a0
ffffffffc020332a:	87aa                	mv	a5,a0
ffffffffc020332c:	00d50f63          	beq	a0,a3,ffffffffc020334a <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203330:	6798                	ld	a4,8(a5)
ffffffffc0203332:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc0203334:	cf49                	beqz	a4,ffffffffc02033ce <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0203336:	0007a823          	sw	zero,16(a5)
ffffffffc020333a:	0007b423          	sd	zero,8(a5)
ffffffffc020333e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203342:	04078793          	addi	a5,a5,64
ffffffffc0203346:	fed795e3          	bne	a5,a3,ffffffffc0203330 <default_init_memmap+0x12>
    base->property = n;
ffffffffc020334a:	2581                	sext.w	a1,a1
ffffffffc020334c:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020334e:	4789                	li	a5,2
ffffffffc0203350:	00850713          	addi	a4,a0,8
ffffffffc0203354:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0203358:	000ab697          	auipc	a3,0xab
ffffffffc020335c:	44868693          	addi	a3,a3,1096 # ffffffffc02ae7a0 <free_area>
ffffffffc0203360:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203362:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0203364:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0203368:	9db9                	addw	a1,a1,a4
ffffffffc020336a:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020336c:	04d78a63          	beq	a5,a3,ffffffffc02033c0 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0203370:	fe878713          	addi	a4,a5,-24
ffffffffc0203374:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203378:	4581                	li	a1,0
            if (base < page) {
ffffffffc020337a:	00e56a63          	bltu	a0,a4,ffffffffc020338e <default_init_memmap+0x70>
    return listelm->next;
ffffffffc020337e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203380:	02d70263          	beq	a4,a3,ffffffffc02033a4 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0203384:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203386:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020338a:	fee57ae3          	bgeu	a0,a4,ffffffffc020337e <default_init_memmap+0x60>
ffffffffc020338e:	c199                	beqz	a1,ffffffffc0203394 <default_init_memmap+0x76>
ffffffffc0203390:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203394:	6398                	ld	a4,0(a5)
}
ffffffffc0203396:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203398:	e390                	sd	a2,0(a5)
ffffffffc020339a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020339c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020339e:	ed18                	sd	a4,24(a0)
ffffffffc02033a0:	0141                	addi	sp,sp,16
ffffffffc02033a2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02033a4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02033a6:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02033a8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02033aa:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02033ac:	00d70663          	beq	a4,a3,ffffffffc02033b8 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc02033b0:	8832                	mv	a6,a2
ffffffffc02033b2:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02033b4:	87ba                	mv	a5,a4
ffffffffc02033b6:	bfc1                	j	ffffffffc0203386 <default_init_memmap+0x68>
}
ffffffffc02033b8:	60a2                	ld	ra,8(sp)
ffffffffc02033ba:	e290                	sd	a2,0(a3)
ffffffffc02033bc:	0141                	addi	sp,sp,16
ffffffffc02033be:	8082                	ret
ffffffffc02033c0:	60a2                	ld	ra,8(sp)
ffffffffc02033c2:	e390                	sd	a2,0(a5)
ffffffffc02033c4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02033c6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02033c8:	ed1c                	sd	a5,24(a0)
ffffffffc02033ca:	0141                	addi	sp,sp,16
ffffffffc02033cc:	8082                	ret
        assert(PageReserved(p));
ffffffffc02033ce:	00005697          	auipc	a3,0x5
ffffffffc02033d2:	93268693          	addi	a3,a3,-1742 # ffffffffc0207d00 <commands+0x1490>
ffffffffc02033d6:	00004617          	auipc	a2,0x4
ffffffffc02033da:	8aa60613          	addi	a2,a2,-1878 # ffffffffc0206c80 <commands+0x410>
ffffffffc02033de:	04900593          	li	a1,73
ffffffffc02033e2:	00004517          	auipc	a0,0x4
ffffffffc02033e6:	5de50513          	addi	a0,a0,1502 # ffffffffc02079c0 <commands+0x1150>
ffffffffc02033ea:	e1ffc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc02033ee:	00005697          	auipc	a3,0x5
ffffffffc02033f2:	8e268693          	addi	a3,a3,-1822 # ffffffffc0207cd0 <commands+0x1460>
ffffffffc02033f6:	00004617          	auipc	a2,0x4
ffffffffc02033fa:	88a60613          	addi	a2,a2,-1910 # ffffffffc0206c80 <commands+0x410>
ffffffffc02033fe:	04600593          	li	a1,70
ffffffffc0203402:	00004517          	auipc	a0,0x4
ffffffffc0203406:	5be50513          	addi	a0,a0,1470 # ffffffffc02079c0 <commands+0x1150>
ffffffffc020340a:	dfffc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020340e <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc020340e:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0203410:	00004617          	auipc	a2,0x4
ffffffffc0203414:	e1060613          	addi	a2,a2,-496 # ffffffffc0207220 <commands+0x9b0>
ffffffffc0203418:	06200593          	li	a1,98
ffffffffc020341c:	00004517          	auipc	a0,0x4
ffffffffc0203420:	e2450513          	addi	a0,a0,-476 # ffffffffc0207240 <commands+0x9d0>
pa2page(uintptr_t pa) {
ffffffffc0203424:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0203426:	de3fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020342a <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc020342a:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc020342c:	00004617          	auipc	a2,0x4
ffffffffc0203430:	3e460613          	addi	a2,a2,996 # ffffffffc0207810 <commands+0xfa0>
ffffffffc0203434:	07400593          	li	a1,116
ffffffffc0203438:	00004517          	auipc	a0,0x4
ffffffffc020343c:	e0850513          	addi	a0,a0,-504 # ffffffffc0207240 <commands+0x9d0>
pte2page(pte_t pte) {
ffffffffc0203440:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0203442:	dc7fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203446 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0203446:	7139                	addi	sp,sp,-64
ffffffffc0203448:	f426                	sd	s1,40(sp)
ffffffffc020344a:	f04a                	sd	s2,32(sp)
ffffffffc020344c:	ec4e                	sd	s3,24(sp)
ffffffffc020344e:	e852                	sd	s4,16(sp)
ffffffffc0203450:	e456                	sd	s5,8(sp)
ffffffffc0203452:	e05a                	sd	s6,0(sp)
ffffffffc0203454:	fc06                	sd	ra,56(sp)
ffffffffc0203456:	f822                	sd	s0,48(sp)
ffffffffc0203458:	84aa                	mv	s1,a0
ffffffffc020345a:	000af917          	auipc	s2,0xaf
ffffffffc020345e:	3d690913          	addi	s2,s2,982 # ffffffffc02b2830 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0203462:	4a05                	li	s4,1
ffffffffc0203464:	000afa97          	auipc	s5,0xaf
ffffffffc0203468:	3a4a8a93          	addi	s5,s5,932 # ffffffffc02b2808 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc020346c:	0005099b          	sext.w	s3,a0
ffffffffc0203470:	000afb17          	auipc	s6,0xaf
ffffffffc0203474:	370b0b13          	addi	s6,s6,880 # ffffffffc02b27e0 <check_mm_struct>
ffffffffc0203478:	a01d                	j	ffffffffc020349e <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc020347a:	00093783          	ld	a5,0(s2)
ffffffffc020347e:	6f9c                	ld	a5,24(a5)
ffffffffc0203480:	9782                	jalr	a5
ffffffffc0203482:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0203484:	4601                	li	a2,0
ffffffffc0203486:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0203488:	ec0d                	bnez	s0,ffffffffc02034c2 <alloc_pages+0x7c>
ffffffffc020348a:	029a6c63          	bltu	s4,s1,ffffffffc02034c2 <alloc_pages+0x7c>
ffffffffc020348e:	000aa783          	lw	a5,0(s5)
ffffffffc0203492:	2781                	sext.w	a5,a5
ffffffffc0203494:	c79d                	beqz	a5,ffffffffc02034c2 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0203496:	000b3503          	ld	a0,0(s6)
ffffffffc020349a:	b38ff0ef          	jal	ra,ffffffffc02027d2 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020349e:	100027f3          	csrr	a5,sstatus
ffffffffc02034a2:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc02034a4:	8526                	mv	a0,s1
ffffffffc02034a6:	dbf1                	beqz	a5,ffffffffc020347a <alloc_pages+0x34>
        intr_disable();
ffffffffc02034a8:	9a0fd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02034ac:	00093783          	ld	a5,0(s2)
ffffffffc02034b0:	8526                	mv	a0,s1
ffffffffc02034b2:	6f9c                	ld	a5,24(a5)
ffffffffc02034b4:	9782                	jalr	a5
ffffffffc02034b6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02034b8:	98afd0ef          	jal	ra,ffffffffc0200642 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc02034bc:	4601                	li	a2,0
ffffffffc02034be:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02034c0:	d469                	beqz	s0,ffffffffc020348a <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc02034c2:	70e2                	ld	ra,56(sp)
ffffffffc02034c4:	8522                	mv	a0,s0
ffffffffc02034c6:	7442                	ld	s0,48(sp)
ffffffffc02034c8:	74a2                	ld	s1,40(sp)
ffffffffc02034ca:	7902                	ld	s2,32(sp)
ffffffffc02034cc:	69e2                	ld	s3,24(sp)
ffffffffc02034ce:	6a42                	ld	s4,16(sp)
ffffffffc02034d0:	6aa2                	ld	s5,8(sp)
ffffffffc02034d2:	6b02                	ld	s6,0(sp)
ffffffffc02034d4:	6121                	addi	sp,sp,64
ffffffffc02034d6:	8082                	ret

ffffffffc02034d8 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02034d8:	100027f3          	csrr	a5,sstatus
ffffffffc02034dc:	8b89                	andi	a5,a5,2
ffffffffc02034de:	e799                	bnez	a5,ffffffffc02034ec <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02034e0:	000af797          	auipc	a5,0xaf
ffffffffc02034e4:	3507b783          	ld	a5,848(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc02034e8:	739c                	ld	a5,32(a5)
ffffffffc02034ea:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02034ec:	1101                	addi	sp,sp,-32
ffffffffc02034ee:	ec06                	sd	ra,24(sp)
ffffffffc02034f0:	e822                	sd	s0,16(sp)
ffffffffc02034f2:	e426                	sd	s1,8(sp)
ffffffffc02034f4:	842a                	mv	s0,a0
ffffffffc02034f6:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02034f8:	950fd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02034fc:	000af797          	auipc	a5,0xaf
ffffffffc0203500:	3347b783          	ld	a5,820(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0203504:	739c                	ld	a5,32(a5)
ffffffffc0203506:	85a6                	mv	a1,s1
ffffffffc0203508:	8522                	mv	a0,s0
ffffffffc020350a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020350c:	6442                	ld	s0,16(sp)
ffffffffc020350e:	60e2                	ld	ra,24(sp)
ffffffffc0203510:	64a2                	ld	s1,8(sp)
ffffffffc0203512:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203514:	92efd06f          	j	ffffffffc0200642 <intr_enable>

ffffffffc0203518 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203518:	100027f3          	csrr	a5,sstatus
ffffffffc020351c:	8b89                	andi	a5,a5,2
ffffffffc020351e:	e799                	bnez	a5,ffffffffc020352c <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0203520:	000af797          	auipc	a5,0xaf
ffffffffc0203524:	3107b783          	ld	a5,784(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0203528:	779c                	ld	a5,40(a5)
ffffffffc020352a:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc020352c:	1141                	addi	sp,sp,-16
ffffffffc020352e:	e406                	sd	ra,8(sp)
ffffffffc0203530:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0203532:	916fd0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203536:	000af797          	auipc	a5,0xaf
ffffffffc020353a:	2fa7b783          	ld	a5,762(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc020353e:	779c                	ld	a5,40(a5)
ffffffffc0203540:	9782                	jalr	a5
ffffffffc0203542:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203544:	8fefd0ef          	jal	ra,ffffffffc0200642 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0203548:	60a2                	ld	ra,8(sp)
ffffffffc020354a:	8522                	mv	a0,s0
ffffffffc020354c:	6402                	ld	s0,0(sp)
ffffffffc020354e:	0141                	addi	sp,sp,16
ffffffffc0203550:	8082                	ret

ffffffffc0203552 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0203552:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0203556:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020355a:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020355c:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020355e:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0203560:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203564:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203566:	f04a                	sd	s2,32(sp)
ffffffffc0203568:	ec4e                	sd	s3,24(sp)
ffffffffc020356a:	e852                	sd	s4,16(sp)
ffffffffc020356c:	fc06                	sd	ra,56(sp)
ffffffffc020356e:	f822                	sd	s0,48(sp)
ffffffffc0203570:	e456                	sd	s5,8(sp)
ffffffffc0203572:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203574:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203578:	892e                	mv	s2,a1
ffffffffc020357a:	89b2                	mv	s3,a2
ffffffffc020357c:	000afa17          	auipc	s4,0xaf
ffffffffc0203580:	2a4a0a13          	addi	s4,s4,676 # ffffffffc02b2820 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203584:	e7b5                	bnez	a5,ffffffffc02035f0 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0203586:	12060b63          	beqz	a2,ffffffffc02036bc <get_pte+0x16a>
ffffffffc020358a:	4505                	li	a0,1
ffffffffc020358c:	ebbff0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0203590:	842a                	mv	s0,a0
ffffffffc0203592:	12050563          	beqz	a0,ffffffffc02036bc <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0203596:	000afb17          	auipc	s6,0xaf
ffffffffc020359a:	292b0b13          	addi	s6,s6,658 # ffffffffc02b2828 <pages>
ffffffffc020359e:	000b3503          	ld	a0,0(s6)
ffffffffc02035a2:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02035a6:	000afa17          	auipc	s4,0xaf
ffffffffc02035aa:	27aa0a13          	addi	s4,s4,634 # ffffffffc02b2820 <npage>
ffffffffc02035ae:	40a40533          	sub	a0,s0,a0
ffffffffc02035b2:	8519                	srai	a0,a0,0x6
ffffffffc02035b4:	9556                	add	a0,a0,s5
ffffffffc02035b6:	000a3703          	ld	a4,0(s4)
ffffffffc02035ba:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc02035be:	4685                	li	a3,1
ffffffffc02035c0:	c014                	sw	a3,0(s0)
ffffffffc02035c2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02035c4:	0532                	slli	a0,a0,0xc
ffffffffc02035c6:	14e7f263          	bgeu	a5,a4,ffffffffc020370a <get_pte+0x1b8>
ffffffffc02035ca:	000af797          	auipc	a5,0xaf
ffffffffc02035ce:	26e7b783          	ld	a5,622(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc02035d2:	6605                	lui	a2,0x1
ffffffffc02035d4:	4581                	li	a1,0
ffffffffc02035d6:	953e                	add	a0,a0,a5
ffffffffc02035d8:	3c3020ef          	jal	ra,ffffffffc020619a <memset>
    return page - pages + nbase;
ffffffffc02035dc:	000b3683          	ld	a3,0(s6)
ffffffffc02035e0:	40d406b3          	sub	a3,s0,a3
ffffffffc02035e4:	8699                	srai	a3,a3,0x6
ffffffffc02035e6:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02035e8:	06aa                	slli	a3,a3,0xa
ffffffffc02035ea:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02035ee:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02035f0:	77fd                	lui	a5,0xfffff
ffffffffc02035f2:	068a                	slli	a3,a3,0x2
ffffffffc02035f4:	000a3703          	ld	a4,0(s4)
ffffffffc02035f8:	8efd                	and	a3,a3,a5
ffffffffc02035fa:	00c6d793          	srli	a5,a3,0xc
ffffffffc02035fe:	0ce7f163          	bgeu	a5,a4,ffffffffc02036c0 <get_pte+0x16e>
ffffffffc0203602:	000afa97          	auipc	s5,0xaf
ffffffffc0203606:	236a8a93          	addi	s5,s5,566 # ffffffffc02b2838 <va_pa_offset>
ffffffffc020360a:	000ab403          	ld	s0,0(s5)
ffffffffc020360e:	01595793          	srli	a5,s2,0x15
ffffffffc0203612:	1ff7f793          	andi	a5,a5,511
ffffffffc0203616:	96a2                	add	a3,a3,s0
ffffffffc0203618:	00379413          	slli	s0,a5,0x3
ffffffffc020361c:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc020361e:	6014                	ld	a3,0(s0)
ffffffffc0203620:	0016f793          	andi	a5,a3,1
ffffffffc0203624:	e3ad                	bnez	a5,ffffffffc0203686 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0203626:	08098b63          	beqz	s3,ffffffffc02036bc <get_pte+0x16a>
ffffffffc020362a:	4505                	li	a0,1
ffffffffc020362c:	e1bff0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0203630:	84aa                	mv	s1,a0
ffffffffc0203632:	c549                	beqz	a0,ffffffffc02036bc <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0203634:	000afb17          	auipc	s6,0xaf
ffffffffc0203638:	1f4b0b13          	addi	s6,s6,500 # ffffffffc02b2828 <pages>
ffffffffc020363c:	000b3503          	ld	a0,0(s6)
ffffffffc0203640:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203644:	000a3703          	ld	a4,0(s4)
ffffffffc0203648:	40a48533          	sub	a0,s1,a0
ffffffffc020364c:	8519                	srai	a0,a0,0x6
ffffffffc020364e:	954e                	add	a0,a0,s3
ffffffffc0203650:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0203654:	4685                	li	a3,1
ffffffffc0203656:	c094                	sw	a3,0(s1)
ffffffffc0203658:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020365a:	0532                	slli	a0,a0,0xc
ffffffffc020365c:	08e7fa63          	bgeu	a5,a4,ffffffffc02036f0 <get_pte+0x19e>
ffffffffc0203660:	000ab783          	ld	a5,0(s5)
ffffffffc0203664:	6605                	lui	a2,0x1
ffffffffc0203666:	4581                	li	a1,0
ffffffffc0203668:	953e                	add	a0,a0,a5
ffffffffc020366a:	331020ef          	jal	ra,ffffffffc020619a <memset>
    return page - pages + nbase;
ffffffffc020366e:	000b3683          	ld	a3,0(s6)
ffffffffc0203672:	40d486b3          	sub	a3,s1,a3
ffffffffc0203676:	8699                	srai	a3,a3,0x6
ffffffffc0203678:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020367a:	06aa                	slli	a3,a3,0xa
ffffffffc020367c:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0203680:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0203682:	000a3703          	ld	a4,0(s4)
ffffffffc0203686:	068a                	slli	a3,a3,0x2
ffffffffc0203688:	757d                	lui	a0,0xfffff
ffffffffc020368a:	8ee9                	and	a3,a3,a0
ffffffffc020368c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0203690:	04e7f463          	bgeu	a5,a4,ffffffffc02036d8 <get_pte+0x186>
ffffffffc0203694:	000ab503          	ld	a0,0(s5)
ffffffffc0203698:	00c95913          	srli	s2,s2,0xc
ffffffffc020369c:	1ff97913          	andi	s2,s2,511
ffffffffc02036a0:	96aa                	add	a3,a3,a0
ffffffffc02036a2:	00391513          	slli	a0,s2,0x3
ffffffffc02036a6:	9536                	add	a0,a0,a3
}
ffffffffc02036a8:	70e2                	ld	ra,56(sp)
ffffffffc02036aa:	7442                	ld	s0,48(sp)
ffffffffc02036ac:	74a2                	ld	s1,40(sp)
ffffffffc02036ae:	7902                	ld	s2,32(sp)
ffffffffc02036b0:	69e2                	ld	s3,24(sp)
ffffffffc02036b2:	6a42                	ld	s4,16(sp)
ffffffffc02036b4:	6aa2                	ld	s5,8(sp)
ffffffffc02036b6:	6b02                	ld	s6,0(sp)
ffffffffc02036b8:	6121                	addi	sp,sp,64
ffffffffc02036ba:	8082                	ret
            return NULL;
ffffffffc02036bc:	4501                	li	a0,0
ffffffffc02036be:	b7ed                	j	ffffffffc02036a8 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02036c0:	00004617          	auipc	a2,0x4
ffffffffc02036c4:	b9060613          	addi	a2,a2,-1136 # ffffffffc0207250 <commands+0x9e0>
ffffffffc02036c8:	0e300593          	li	a1,227
ffffffffc02036cc:	00004517          	auipc	a0,0x4
ffffffffc02036d0:	69450513          	addi	a0,a0,1684 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02036d4:	b35fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02036d8:	00004617          	auipc	a2,0x4
ffffffffc02036dc:	b7860613          	addi	a2,a2,-1160 # ffffffffc0207250 <commands+0x9e0>
ffffffffc02036e0:	0ee00593          	li	a1,238
ffffffffc02036e4:	00004517          	auipc	a0,0x4
ffffffffc02036e8:	67c50513          	addi	a0,a0,1660 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02036ec:	b1dfc0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02036f0:	86aa                	mv	a3,a0
ffffffffc02036f2:	00004617          	auipc	a2,0x4
ffffffffc02036f6:	b5e60613          	addi	a2,a2,-1186 # ffffffffc0207250 <commands+0x9e0>
ffffffffc02036fa:	0eb00593          	li	a1,235
ffffffffc02036fe:	00004517          	auipc	a0,0x4
ffffffffc0203702:	66250513          	addi	a0,a0,1634 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0203706:	b03fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020370a:	86aa                	mv	a3,a0
ffffffffc020370c:	00004617          	auipc	a2,0x4
ffffffffc0203710:	b4460613          	addi	a2,a2,-1212 # ffffffffc0207250 <commands+0x9e0>
ffffffffc0203714:	0df00593          	li	a1,223
ffffffffc0203718:	00004517          	auipc	a0,0x4
ffffffffc020371c:	64850513          	addi	a0,a0,1608 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0203720:	ae9fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203724 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0203724:	1141                	addi	sp,sp,-16
ffffffffc0203726:	e022                	sd	s0,0(sp)
ffffffffc0203728:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020372a:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020372c:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020372e:	e25ff0ef          	jal	ra,ffffffffc0203552 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0203732:	c011                	beqz	s0,ffffffffc0203736 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0203734:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0203736:	c511                	beqz	a0,ffffffffc0203742 <get_page+0x1e>
ffffffffc0203738:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020373a:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020373c:	0017f713          	andi	a4,a5,1
ffffffffc0203740:	e709                	bnez	a4,ffffffffc020374a <get_page+0x26>
}
ffffffffc0203742:	60a2                	ld	ra,8(sp)
ffffffffc0203744:	6402                	ld	s0,0(sp)
ffffffffc0203746:	0141                	addi	sp,sp,16
ffffffffc0203748:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020374a:	078a                	slli	a5,a5,0x2
ffffffffc020374c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020374e:	000af717          	auipc	a4,0xaf
ffffffffc0203752:	0d273703          	ld	a4,210(a4) # ffffffffc02b2820 <npage>
ffffffffc0203756:	00e7ff63          	bgeu	a5,a4,ffffffffc0203774 <get_page+0x50>
ffffffffc020375a:	60a2                	ld	ra,8(sp)
ffffffffc020375c:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc020375e:	fff80537          	lui	a0,0xfff80
ffffffffc0203762:	97aa                	add	a5,a5,a0
ffffffffc0203764:	079a                	slli	a5,a5,0x6
ffffffffc0203766:	000af517          	auipc	a0,0xaf
ffffffffc020376a:	0c253503          	ld	a0,194(a0) # ffffffffc02b2828 <pages>
ffffffffc020376e:	953e                	add	a0,a0,a5
ffffffffc0203770:	0141                	addi	sp,sp,16
ffffffffc0203772:	8082                	ret
ffffffffc0203774:	c9bff0ef          	jal	ra,ffffffffc020340e <pa2page.part.0>

ffffffffc0203778 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203778:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020377a:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020377e:	f486                	sd	ra,104(sp)
ffffffffc0203780:	f0a2                	sd	s0,96(sp)
ffffffffc0203782:	eca6                	sd	s1,88(sp)
ffffffffc0203784:	e8ca                	sd	s2,80(sp)
ffffffffc0203786:	e4ce                	sd	s3,72(sp)
ffffffffc0203788:	e0d2                	sd	s4,64(sp)
ffffffffc020378a:	fc56                	sd	s5,56(sp)
ffffffffc020378c:	f85a                	sd	s6,48(sp)
ffffffffc020378e:	f45e                	sd	s7,40(sp)
ffffffffc0203790:	f062                	sd	s8,32(sp)
ffffffffc0203792:	ec66                	sd	s9,24(sp)
ffffffffc0203794:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203796:	17d2                	slli	a5,a5,0x34
ffffffffc0203798:	e3ed                	bnez	a5,ffffffffc020387a <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc020379a:	002007b7          	lui	a5,0x200
ffffffffc020379e:	842e                	mv	s0,a1
ffffffffc02037a0:	0ef5ed63          	bltu	a1,a5,ffffffffc020389a <unmap_range+0x122>
ffffffffc02037a4:	8932                	mv	s2,a2
ffffffffc02037a6:	0ec5fa63          	bgeu	a1,a2,ffffffffc020389a <unmap_range+0x122>
ffffffffc02037aa:	4785                	li	a5,1
ffffffffc02037ac:	07fe                	slli	a5,a5,0x1f
ffffffffc02037ae:	0ec7e663          	bltu	a5,a2,ffffffffc020389a <unmap_range+0x122>
ffffffffc02037b2:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02037b4:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02037b6:	000afc97          	auipc	s9,0xaf
ffffffffc02037ba:	06ac8c93          	addi	s9,s9,106 # ffffffffc02b2820 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02037be:	000afc17          	auipc	s8,0xaf
ffffffffc02037c2:	06ac0c13          	addi	s8,s8,106 # ffffffffc02b2828 <pages>
ffffffffc02037c6:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc02037ca:	000afd17          	auipc	s10,0xaf
ffffffffc02037ce:	066d0d13          	addi	s10,s10,102 # ffffffffc02b2830 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02037d2:	00200b37          	lui	s6,0x200
ffffffffc02037d6:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02037da:	4601                	li	a2,0
ffffffffc02037dc:	85a2                	mv	a1,s0
ffffffffc02037de:	854e                	mv	a0,s3
ffffffffc02037e0:	d73ff0ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc02037e4:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02037e6:	cd29                	beqz	a0,ffffffffc0203840 <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc02037e8:	611c                	ld	a5,0(a0)
ffffffffc02037ea:	e395                	bnez	a5,ffffffffc020380e <unmap_range+0x96>
        start += PGSIZE;
ffffffffc02037ec:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02037ee:	ff2466e3          	bltu	s0,s2,ffffffffc02037da <unmap_range+0x62>
}
ffffffffc02037f2:	70a6                	ld	ra,104(sp)
ffffffffc02037f4:	7406                	ld	s0,96(sp)
ffffffffc02037f6:	64e6                	ld	s1,88(sp)
ffffffffc02037f8:	6946                	ld	s2,80(sp)
ffffffffc02037fa:	69a6                	ld	s3,72(sp)
ffffffffc02037fc:	6a06                	ld	s4,64(sp)
ffffffffc02037fe:	7ae2                	ld	s5,56(sp)
ffffffffc0203800:	7b42                	ld	s6,48(sp)
ffffffffc0203802:	7ba2                	ld	s7,40(sp)
ffffffffc0203804:	7c02                	ld	s8,32(sp)
ffffffffc0203806:	6ce2                	ld	s9,24(sp)
ffffffffc0203808:	6d42                	ld	s10,16(sp)
ffffffffc020380a:	6165                	addi	sp,sp,112
ffffffffc020380c:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020380e:	0017f713          	andi	a4,a5,1
ffffffffc0203812:	df69                	beqz	a4,ffffffffc02037ec <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc0203814:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203818:	078a                	slli	a5,a5,0x2
ffffffffc020381a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020381c:	08e7ff63          	bgeu	a5,a4,ffffffffc02038ba <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0203820:	000c3503          	ld	a0,0(s8)
ffffffffc0203824:	97de                	add	a5,a5,s7
ffffffffc0203826:	079a                	slli	a5,a5,0x6
ffffffffc0203828:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020382a:	411c                	lw	a5,0(a0)
ffffffffc020382c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203830:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203832:	cf11                	beqz	a4,ffffffffc020384e <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203834:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203838:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020383c:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc020383e:	bf45                	j	ffffffffc02037ee <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203840:	945a                	add	s0,s0,s6
ffffffffc0203842:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0203846:	d455                	beqz	s0,ffffffffc02037f2 <unmap_range+0x7a>
ffffffffc0203848:	f92469e3          	bltu	s0,s2,ffffffffc02037da <unmap_range+0x62>
ffffffffc020384c:	b75d                	j	ffffffffc02037f2 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020384e:	100027f3          	csrr	a5,sstatus
ffffffffc0203852:	8b89                	andi	a5,a5,2
ffffffffc0203854:	e799                	bnez	a5,ffffffffc0203862 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc0203856:	000d3783          	ld	a5,0(s10)
ffffffffc020385a:	4585                	li	a1,1
ffffffffc020385c:	739c                	ld	a5,32(a5)
ffffffffc020385e:	9782                	jalr	a5
    if (flag) {
ffffffffc0203860:	bfd1                	j	ffffffffc0203834 <unmap_range+0xbc>
ffffffffc0203862:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203864:	de5fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0203868:	000d3783          	ld	a5,0(s10)
ffffffffc020386c:	6522                	ld	a0,8(sp)
ffffffffc020386e:	4585                	li	a1,1
ffffffffc0203870:	739c                	ld	a5,32(a5)
ffffffffc0203872:	9782                	jalr	a5
        intr_enable();
ffffffffc0203874:	dcffc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203878:	bf75                	j	ffffffffc0203834 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020387a:	00004697          	auipc	a3,0x4
ffffffffc020387e:	4f668693          	addi	a3,a3,1270 # ffffffffc0207d70 <default_pmm_manager+0x48>
ffffffffc0203882:	00003617          	auipc	a2,0x3
ffffffffc0203886:	3fe60613          	addi	a2,a2,1022 # ffffffffc0206c80 <commands+0x410>
ffffffffc020388a:	10f00593          	li	a1,271
ffffffffc020388e:	00004517          	auipc	a0,0x4
ffffffffc0203892:	4d250513          	addi	a0,a0,1234 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0203896:	973fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020389a:	00004697          	auipc	a3,0x4
ffffffffc020389e:	50668693          	addi	a3,a3,1286 # ffffffffc0207da0 <default_pmm_manager+0x78>
ffffffffc02038a2:	00003617          	auipc	a2,0x3
ffffffffc02038a6:	3de60613          	addi	a2,a2,990 # ffffffffc0206c80 <commands+0x410>
ffffffffc02038aa:	11000593          	li	a1,272
ffffffffc02038ae:	00004517          	auipc	a0,0x4
ffffffffc02038b2:	4b250513          	addi	a0,a0,1202 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02038b6:	953fc0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02038ba:	b55ff0ef          	jal	ra,ffffffffc020340e <pa2page.part.0>

ffffffffc02038be <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02038be:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02038c0:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02038c4:	fc86                	sd	ra,120(sp)
ffffffffc02038c6:	f8a2                	sd	s0,112(sp)
ffffffffc02038c8:	f4a6                	sd	s1,104(sp)
ffffffffc02038ca:	f0ca                	sd	s2,96(sp)
ffffffffc02038cc:	ecce                	sd	s3,88(sp)
ffffffffc02038ce:	e8d2                	sd	s4,80(sp)
ffffffffc02038d0:	e4d6                	sd	s5,72(sp)
ffffffffc02038d2:	e0da                	sd	s6,64(sp)
ffffffffc02038d4:	fc5e                	sd	s7,56(sp)
ffffffffc02038d6:	f862                	sd	s8,48(sp)
ffffffffc02038d8:	f466                	sd	s9,40(sp)
ffffffffc02038da:	f06a                	sd	s10,32(sp)
ffffffffc02038dc:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02038de:	17d2                	slli	a5,a5,0x34
ffffffffc02038e0:	20079a63          	bnez	a5,ffffffffc0203af4 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc02038e4:	002007b7          	lui	a5,0x200
ffffffffc02038e8:	24f5e463          	bltu	a1,a5,ffffffffc0203b30 <exit_range+0x272>
ffffffffc02038ec:	8ab2                	mv	s5,a2
ffffffffc02038ee:	24c5f163          	bgeu	a1,a2,ffffffffc0203b30 <exit_range+0x272>
ffffffffc02038f2:	4785                	li	a5,1
ffffffffc02038f4:	07fe                	slli	a5,a5,0x1f
ffffffffc02038f6:	22c7ed63          	bltu	a5,a2,ffffffffc0203b30 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02038fa:	c00009b7          	lui	s3,0xc0000
ffffffffc02038fe:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0203902:	ffe00937          	lui	s2,0xffe00
ffffffffc0203906:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc020390a:	5cfd                	li	s9,-1
ffffffffc020390c:	8c2a                	mv	s8,a0
ffffffffc020390e:	0125f933          	and	s2,a1,s2
ffffffffc0203912:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc0203914:	000afd17          	auipc	s10,0xaf
ffffffffc0203918:	f0cd0d13          	addi	s10,s10,-244 # ffffffffc02b2820 <npage>
    return KADDR(page2pa(page));
ffffffffc020391c:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0203920:	000af717          	auipc	a4,0xaf
ffffffffc0203924:	f0870713          	addi	a4,a4,-248 # ffffffffc02b2828 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc0203928:	000afd97          	auipc	s11,0xaf
ffffffffc020392c:	f08d8d93          	addi	s11,s11,-248 # ffffffffc02b2830 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0203930:	c0000437          	lui	s0,0xc0000
ffffffffc0203934:	944e                	add	s0,s0,s3
ffffffffc0203936:	8079                	srli	s0,s0,0x1e
ffffffffc0203938:	1ff47413          	andi	s0,s0,511
ffffffffc020393c:	040e                	slli	s0,s0,0x3
ffffffffc020393e:	9462                	add	s0,s0,s8
ffffffffc0203940:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ee0>
        if (pde1&PTE_V){
ffffffffc0203944:	001a7793          	andi	a5,s4,1
ffffffffc0203948:	eb99                	bnez	a5,ffffffffc020395e <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc020394a:	12098463          	beqz	s3,ffffffffc0203a72 <exit_range+0x1b4>
ffffffffc020394e:	400007b7          	lui	a5,0x40000
ffffffffc0203952:	97ce                	add	a5,a5,s3
ffffffffc0203954:	894e                	mv	s2,s3
ffffffffc0203956:	1159fe63          	bgeu	s3,s5,ffffffffc0203a72 <exit_range+0x1b4>
ffffffffc020395a:	89be                	mv	s3,a5
ffffffffc020395c:	bfd1                	j	ffffffffc0203930 <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc020395e:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203962:	0a0a                	slli	s4,s4,0x2
ffffffffc0203964:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203968:	1cfa7263          	bgeu	s4,a5,ffffffffc0203b2c <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc020396c:	fff80637          	lui	a2,0xfff80
ffffffffc0203970:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc0203972:	000806b7          	lui	a3,0x80
ffffffffc0203976:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0203978:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc020397c:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc020397e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203980:	18f5fa63          	bgeu	a1,a5,ffffffffc0203b14 <exit_range+0x256>
ffffffffc0203984:	000af817          	auipc	a6,0xaf
ffffffffc0203988:	eb480813          	addi	a6,a6,-332 # ffffffffc02b2838 <va_pa_offset>
ffffffffc020398c:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc0203990:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0203992:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0203996:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc0203998:	00080337          	lui	t1,0x80
ffffffffc020399c:	6885                	lui	a7,0x1
ffffffffc020399e:	a819                	j	ffffffffc02039b4 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc02039a0:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc02039a2:	002007b7          	lui	a5,0x200
ffffffffc02039a6:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02039a8:	08090c63          	beqz	s2,ffffffffc0203a40 <exit_range+0x182>
ffffffffc02039ac:	09397a63          	bgeu	s2,s3,ffffffffc0203a40 <exit_range+0x182>
ffffffffc02039b0:	0f597063          	bgeu	s2,s5,ffffffffc0203a90 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02039b4:	01595493          	srli	s1,s2,0x15
ffffffffc02039b8:	1ff4f493          	andi	s1,s1,511
ffffffffc02039bc:	048e                	slli	s1,s1,0x3
ffffffffc02039be:	94da                	add	s1,s1,s6
ffffffffc02039c0:	609c                	ld	a5,0(s1)
                if (pde0&PTE_V) {
ffffffffc02039c2:	0017f693          	andi	a3,a5,1
ffffffffc02039c6:	dee9                	beqz	a3,ffffffffc02039a0 <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc02039c8:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02039cc:	078a                	slli	a5,a5,0x2
ffffffffc02039ce:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02039d0:	14b7fe63          	bgeu	a5,a1,ffffffffc0203b2c <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02039d4:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc02039d6:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc02039da:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02039de:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02039e2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02039e4:	12bef863          	bgeu	t4,a1,ffffffffc0203b14 <exit_range+0x256>
ffffffffc02039e8:	00083783          	ld	a5,0(a6)
ffffffffc02039ec:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02039ee:	011685b3          	add	a1,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc02039f2:	629c                	ld	a5,0(a3)
ffffffffc02039f4:	8b85                	andi	a5,a5,1
ffffffffc02039f6:	f7d5                	bnez	a5,ffffffffc02039a2 <exit_range+0xe4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02039f8:	06a1                	addi	a3,a3,8
ffffffffc02039fa:	fed59ce3          	bne	a1,a3,ffffffffc02039f2 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc02039fe:	631c                	ld	a5,0(a4)
ffffffffc0203a00:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203a02:	100027f3          	csrr	a5,sstatus
ffffffffc0203a06:	8b89                	andi	a5,a5,2
ffffffffc0203a08:	e7d9                	bnez	a5,ffffffffc0203a96 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc0203a0a:	000db783          	ld	a5,0(s11)
ffffffffc0203a0e:	4585                	li	a1,1
ffffffffc0203a10:	e032                	sd	a2,0(sp)
ffffffffc0203a12:	739c                	ld	a5,32(a5)
ffffffffc0203a14:	9782                	jalr	a5
    if (flag) {
ffffffffc0203a16:	6602                	ld	a2,0(sp)
ffffffffc0203a18:	000af817          	auipc	a6,0xaf
ffffffffc0203a1c:	e2080813          	addi	a6,a6,-480 # ffffffffc02b2838 <va_pa_offset>
ffffffffc0203a20:	fff80e37          	lui	t3,0xfff80
ffffffffc0203a24:	00080337          	lui	t1,0x80
ffffffffc0203a28:	6885                	lui	a7,0x1
ffffffffc0203a2a:	000af717          	auipc	a4,0xaf
ffffffffc0203a2e:	dfe70713          	addi	a4,a4,-514 # ffffffffc02b2828 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0203a32:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc0203a36:	002007b7          	lui	a5,0x200
ffffffffc0203a3a:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0203a3c:	f60918e3          	bnez	s2,ffffffffc02039ac <exit_range+0xee>
            if (free_pd0) {
ffffffffc0203a40:	f00b85e3          	beqz	s7,ffffffffc020394a <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc0203a44:	000d3783          	ld	a5,0(s10)
ffffffffc0203a48:	0efa7263          	bgeu	s4,a5,ffffffffc0203b2c <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a4c:	6308                	ld	a0,0(a4)
ffffffffc0203a4e:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203a50:	100027f3          	csrr	a5,sstatus
ffffffffc0203a54:	8b89                	andi	a5,a5,2
ffffffffc0203a56:	efad                	bnez	a5,ffffffffc0203ad0 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc0203a58:	000db783          	ld	a5,0(s11)
ffffffffc0203a5c:	4585                	li	a1,1
ffffffffc0203a5e:	739c                	ld	a5,32(a5)
ffffffffc0203a60:	9782                	jalr	a5
ffffffffc0203a62:	000af717          	auipc	a4,0xaf
ffffffffc0203a66:	dc670713          	addi	a4,a4,-570 # ffffffffc02b2828 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0203a6a:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc0203a6e:	ee0990e3          	bnez	s3,ffffffffc020394e <exit_range+0x90>
}
ffffffffc0203a72:	70e6                	ld	ra,120(sp)
ffffffffc0203a74:	7446                	ld	s0,112(sp)
ffffffffc0203a76:	74a6                	ld	s1,104(sp)
ffffffffc0203a78:	7906                	ld	s2,96(sp)
ffffffffc0203a7a:	69e6                	ld	s3,88(sp)
ffffffffc0203a7c:	6a46                	ld	s4,80(sp)
ffffffffc0203a7e:	6aa6                	ld	s5,72(sp)
ffffffffc0203a80:	6b06                	ld	s6,64(sp)
ffffffffc0203a82:	7be2                	ld	s7,56(sp)
ffffffffc0203a84:	7c42                	ld	s8,48(sp)
ffffffffc0203a86:	7ca2                	ld	s9,40(sp)
ffffffffc0203a88:	7d02                	ld	s10,32(sp)
ffffffffc0203a8a:	6de2                	ld	s11,24(sp)
ffffffffc0203a8c:	6109                	addi	sp,sp,128
ffffffffc0203a8e:	8082                	ret
            if (free_pd0) {
ffffffffc0203a90:	ea0b8fe3          	beqz	s7,ffffffffc020394e <exit_range+0x90>
ffffffffc0203a94:	bf45                	j	ffffffffc0203a44 <exit_range+0x186>
ffffffffc0203a96:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0203a98:	e42a                	sd	a0,8(sp)
ffffffffc0203a9a:	baffc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203a9e:	000db783          	ld	a5,0(s11)
ffffffffc0203aa2:	6522                	ld	a0,8(sp)
ffffffffc0203aa4:	4585                	li	a1,1
ffffffffc0203aa6:	739c                	ld	a5,32(a5)
ffffffffc0203aa8:	9782                	jalr	a5
        intr_enable();
ffffffffc0203aaa:	b99fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203aae:	6602                	ld	a2,0(sp)
ffffffffc0203ab0:	000af717          	auipc	a4,0xaf
ffffffffc0203ab4:	d7870713          	addi	a4,a4,-648 # ffffffffc02b2828 <pages>
ffffffffc0203ab8:	6885                	lui	a7,0x1
ffffffffc0203aba:	00080337          	lui	t1,0x80
ffffffffc0203abe:	fff80e37          	lui	t3,0xfff80
ffffffffc0203ac2:	000af817          	auipc	a6,0xaf
ffffffffc0203ac6:	d7680813          	addi	a6,a6,-650 # ffffffffc02b2838 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0203aca:	0004b023          	sd	zero,0(s1)
ffffffffc0203ace:	b7a5                	j	ffffffffc0203a36 <exit_range+0x178>
ffffffffc0203ad0:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0203ad2:	b77fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203ad6:	000db783          	ld	a5,0(s11)
ffffffffc0203ada:	6502                	ld	a0,0(sp)
ffffffffc0203adc:	4585                	li	a1,1
ffffffffc0203ade:	739c                	ld	a5,32(a5)
ffffffffc0203ae0:	9782                	jalr	a5
        intr_enable();
ffffffffc0203ae2:	b61fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203ae6:	000af717          	auipc	a4,0xaf
ffffffffc0203aea:	d4270713          	addi	a4,a4,-702 # ffffffffc02b2828 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0203aee:	00043023          	sd	zero,0(s0)
ffffffffc0203af2:	bfb5                	j	ffffffffc0203a6e <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203af4:	00004697          	auipc	a3,0x4
ffffffffc0203af8:	27c68693          	addi	a3,a3,636 # ffffffffc0207d70 <default_pmm_manager+0x48>
ffffffffc0203afc:	00003617          	auipc	a2,0x3
ffffffffc0203b00:	18460613          	addi	a2,a2,388 # ffffffffc0206c80 <commands+0x410>
ffffffffc0203b04:	12000593          	li	a1,288
ffffffffc0203b08:	00004517          	auipc	a0,0x4
ffffffffc0203b0c:	25850513          	addi	a0,a0,600 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0203b10:	ef8fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203b14:	00003617          	auipc	a2,0x3
ffffffffc0203b18:	73c60613          	addi	a2,a2,1852 # ffffffffc0207250 <commands+0x9e0>
ffffffffc0203b1c:	06900593          	li	a1,105
ffffffffc0203b20:	00003517          	auipc	a0,0x3
ffffffffc0203b24:	72050513          	addi	a0,a0,1824 # ffffffffc0207240 <commands+0x9d0>
ffffffffc0203b28:	ee0fc0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0203b2c:	8e3ff0ef          	jal	ra,ffffffffc020340e <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0203b30:	00004697          	auipc	a3,0x4
ffffffffc0203b34:	27068693          	addi	a3,a3,624 # ffffffffc0207da0 <default_pmm_manager+0x78>
ffffffffc0203b38:	00003617          	auipc	a2,0x3
ffffffffc0203b3c:	14860613          	addi	a2,a2,328 # ffffffffc0206c80 <commands+0x410>
ffffffffc0203b40:	12100593          	li	a1,289
ffffffffc0203b44:	00004517          	auipc	a0,0x4
ffffffffc0203b48:	21c50513          	addi	a0,a0,540 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0203b4c:	ebcfc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203b50 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203b50:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203b52:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203b54:	ec26                	sd	s1,24(sp)
ffffffffc0203b56:	f406                	sd	ra,40(sp)
ffffffffc0203b58:	f022                	sd	s0,32(sp)
ffffffffc0203b5a:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203b5c:	9f7ff0ef          	jal	ra,ffffffffc0203552 <get_pte>
    if (ptep != NULL) {
ffffffffc0203b60:	c511                	beqz	a0,ffffffffc0203b6c <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203b62:	611c                	ld	a5,0(a0)
ffffffffc0203b64:	842a                	mv	s0,a0
ffffffffc0203b66:	0017f713          	andi	a4,a5,1
ffffffffc0203b6a:	e711                	bnez	a4,ffffffffc0203b76 <page_remove+0x26>
}
ffffffffc0203b6c:	70a2                	ld	ra,40(sp)
ffffffffc0203b6e:	7402                	ld	s0,32(sp)
ffffffffc0203b70:	64e2                	ld	s1,24(sp)
ffffffffc0203b72:	6145                	addi	sp,sp,48
ffffffffc0203b74:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203b76:	078a                	slli	a5,a5,0x2
ffffffffc0203b78:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b7a:	000af717          	auipc	a4,0xaf
ffffffffc0203b7e:	ca673703          	ld	a4,-858(a4) # ffffffffc02b2820 <npage>
ffffffffc0203b82:	06e7f363          	bgeu	a5,a4,ffffffffc0203be8 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b86:	fff80537          	lui	a0,0xfff80
ffffffffc0203b8a:	97aa                	add	a5,a5,a0
ffffffffc0203b8c:	079a                	slli	a5,a5,0x6
ffffffffc0203b8e:	000af517          	auipc	a0,0xaf
ffffffffc0203b92:	c9a53503          	ld	a0,-870(a0) # ffffffffc02b2828 <pages>
ffffffffc0203b96:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0203b98:	411c                	lw	a5,0(a0)
ffffffffc0203b9a:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203b9e:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203ba0:	cb11                	beqz	a4,ffffffffc0203bb4 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203ba2:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203ba6:	12048073          	sfence.vma	s1
}
ffffffffc0203baa:	70a2                	ld	ra,40(sp)
ffffffffc0203bac:	7402                	ld	s0,32(sp)
ffffffffc0203bae:	64e2                	ld	s1,24(sp)
ffffffffc0203bb0:	6145                	addi	sp,sp,48
ffffffffc0203bb2:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203bb4:	100027f3          	csrr	a5,sstatus
ffffffffc0203bb8:	8b89                	andi	a5,a5,2
ffffffffc0203bba:	eb89                	bnez	a5,ffffffffc0203bcc <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0203bbc:	000af797          	auipc	a5,0xaf
ffffffffc0203bc0:	c747b783          	ld	a5,-908(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0203bc4:	739c                	ld	a5,32(a5)
ffffffffc0203bc6:	4585                	li	a1,1
ffffffffc0203bc8:	9782                	jalr	a5
    if (flag) {
ffffffffc0203bca:	bfe1                	j	ffffffffc0203ba2 <page_remove+0x52>
        intr_disable();
ffffffffc0203bcc:	e42a                	sd	a0,8(sp)
ffffffffc0203bce:	a7bfc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0203bd2:	000af797          	auipc	a5,0xaf
ffffffffc0203bd6:	c5e7b783          	ld	a5,-930(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0203bda:	739c                	ld	a5,32(a5)
ffffffffc0203bdc:	6522                	ld	a0,8(sp)
ffffffffc0203bde:	4585                	li	a1,1
ffffffffc0203be0:	9782                	jalr	a5
        intr_enable();
ffffffffc0203be2:	a61fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203be6:	bf75                	j	ffffffffc0203ba2 <page_remove+0x52>
ffffffffc0203be8:	827ff0ef          	jal	ra,ffffffffc020340e <pa2page.part.0>

ffffffffc0203bec <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203bec:	7139                	addi	sp,sp,-64
ffffffffc0203bee:	e852                	sd	s4,16(sp)
ffffffffc0203bf0:	8a32                	mv	s4,a2
ffffffffc0203bf2:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203bf4:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203bf6:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203bf8:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203bfa:	f426                	sd	s1,40(sp)
ffffffffc0203bfc:	fc06                	sd	ra,56(sp)
ffffffffc0203bfe:	f04a                	sd	s2,32(sp)
ffffffffc0203c00:	ec4e                	sd	s3,24(sp)
ffffffffc0203c02:	e456                	sd	s5,8(sp)
ffffffffc0203c04:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203c06:	94dff0ef          	jal	ra,ffffffffc0203552 <get_pte>
    if (ptep == NULL) {
ffffffffc0203c0a:	c961                	beqz	a0,ffffffffc0203cda <page_insert+0xee>
    page->ref += 1;
ffffffffc0203c0c:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0203c0e:	611c                	ld	a5,0(a0)
ffffffffc0203c10:	89aa                	mv	s3,a0
ffffffffc0203c12:	0016871b          	addiw	a4,a3,1
ffffffffc0203c16:	c018                	sw	a4,0(s0)
ffffffffc0203c18:	0017f713          	andi	a4,a5,1
ffffffffc0203c1c:	ef05                	bnez	a4,ffffffffc0203c54 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0203c1e:	000af717          	auipc	a4,0xaf
ffffffffc0203c22:	c0a73703          	ld	a4,-1014(a4) # ffffffffc02b2828 <pages>
ffffffffc0203c26:	8c19                	sub	s0,s0,a4
ffffffffc0203c28:	000807b7          	lui	a5,0x80
ffffffffc0203c2c:	8419                	srai	s0,s0,0x6
ffffffffc0203c2e:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203c30:	042a                	slli	s0,s0,0xa
ffffffffc0203c32:	8cc1                	or	s1,s1,s0
ffffffffc0203c34:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0203c38:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ee0>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203c3c:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0203c40:	4501                	li	a0,0
}
ffffffffc0203c42:	70e2                	ld	ra,56(sp)
ffffffffc0203c44:	7442                	ld	s0,48(sp)
ffffffffc0203c46:	74a2                	ld	s1,40(sp)
ffffffffc0203c48:	7902                	ld	s2,32(sp)
ffffffffc0203c4a:	69e2                	ld	s3,24(sp)
ffffffffc0203c4c:	6a42                	ld	s4,16(sp)
ffffffffc0203c4e:	6aa2                	ld	s5,8(sp)
ffffffffc0203c50:	6121                	addi	sp,sp,64
ffffffffc0203c52:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203c54:	078a                	slli	a5,a5,0x2
ffffffffc0203c56:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c58:	000af717          	auipc	a4,0xaf
ffffffffc0203c5c:	bc873703          	ld	a4,-1080(a4) # ffffffffc02b2820 <npage>
ffffffffc0203c60:	06e7ff63          	bgeu	a5,a4,ffffffffc0203cde <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c64:	000afa97          	auipc	s5,0xaf
ffffffffc0203c68:	bc4a8a93          	addi	s5,s5,-1084 # ffffffffc02b2828 <pages>
ffffffffc0203c6c:	000ab703          	ld	a4,0(s5)
ffffffffc0203c70:	fff80937          	lui	s2,0xfff80
ffffffffc0203c74:	993e                	add	s2,s2,a5
ffffffffc0203c76:	091a                	slli	s2,s2,0x6
ffffffffc0203c78:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0203c7a:	01240c63          	beq	s0,s2,ffffffffc0203c92 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0203c7e:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccd7a4>
ffffffffc0203c82:	fff7869b          	addiw	a3,a5,-1
ffffffffc0203c86:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0203c8a:	c691                	beqz	a3,ffffffffc0203c96 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203c8c:	120a0073          	sfence.vma	s4
}
ffffffffc0203c90:	bf59                	j	ffffffffc0203c26 <page_insert+0x3a>
ffffffffc0203c92:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0203c94:	bf49                	j	ffffffffc0203c26 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203c96:	100027f3          	csrr	a5,sstatus
ffffffffc0203c9a:	8b89                	andi	a5,a5,2
ffffffffc0203c9c:	ef91                	bnez	a5,ffffffffc0203cb8 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0203c9e:	000af797          	auipc	a5,0xaf
ffffffffc0203ca2:	b927b783          	ld	a5,-1134(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0203ca6:	739c                	ld	a5,32(a5)
ffffffffc0203ca8:	4585                	li	a1,1
ffffffffc0203caa:	854a                	mv	a0,s2
ffffffffc0203cac:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0203cae:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203cb2:	120a0073          	sfence.vma	s4
ffffffffc0203cb6:	bf85                	j	ffffffffc0203c26 <page_insert+0x3a>
        intr_disable();
ffffffffc0203cb8:	991fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203cbc:	000af797          	auipc	a5,0xaf
ffffffffc0203cc0:	b747b783          	ld	a5,-1164(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0203cc4:	739c                	ld	a5,32(a5)
ffffffffc0203cc6:	4585                	li	a1,1
ffffffffc0203cc8:	854a                	mv	a0,s2
ffffffffc0203cca:	9782                	jalr	a5
        intr_enable();
ffffffffc0203ccc:	977fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203cd0:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203cd4:	120a0073          	sfence.vma	s4
ffffffffc0203cd8:	b7b9                	j	ffffffffc0203c26 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0203cda:	5571                	li	a0,-4
ffffffffc0203cdc:	b79d                	j	ffffffffc0203c42 <page_insert+0x56>
ffffffffc0203cde:	f30ff0ef          	jal	ra,ffffffffc020340e <pa2page.part.0>

ffffffffc0203ce2 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0203ce2:	00004797          	auipc	a5,0x4
ffffffffc0203ce6:	04678793          	addi	a5,a5,70 # ffffffffc0207d28 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203cea:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0203cec:	711d                	addi	sp,sp,-96
ffffffffc0203cee:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203cf0:	00004517          	auipc	a0,0x4
ffffffffc0203cf4:	0c850513          	addi	a0,a0,200 # ffffffffc0207db8 <default_pmm_manager+0x90>
    pmm_manager = &default_pmm_manager;
ffffffffc0203cf8:	000afb97          	auipc	s7,0xaf
ffffffffc0203cfc:	b38b8b93          	addi	s7,s7,-1224 # ffffffffc02b2830 <pmm_manager>
void pmm_init(void) {
ffffffffc0203d00:	ec86                	sd	ra,88(sp)
ffffffffc0203d02:	e4a6                	sd	s1,72(sp)
ffffffffc0203d04:	fc4e                	sd	s3,56(sp)
ffffffffc0203d06:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0203d08:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0203d0c:	e8a2                	sd	s0,80(sp)
ffffffffc0203d0e:	e0ca                	sd	s2,64(sp)
ffffffffc0203d10:	f852                	sd	s4,48(sp)
ffffffffc0203d12:	f456                	sd	s5,40(sp)
ffffffffc0203d14:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203d16:	bb6fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pmm_manager->init();
ffffffffc0203d1a:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203d1e:	000af997          	auipc	s3,0xaf
ffffffffc0203d22:	b1a98993          	addi	s3,s3,-1254 # ffffffffc02b2838 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0203d26:	000af497          	auipc	s1,0xaf
ffffffffc0203d2a:	afa48493          	addi	s1,s1,-1286 # ffffffffc02b2820 <npage>
    pmm_manager->init();
ffffffffc0203d2e:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203d30:	000afb17          	auipc	s6,0xaf
ffffffffc0203d34:	af8b0b13          	addi	s6,s6,-1288 # ffffffffc02b2828 <pages>
    pmm_manager->init();
ffffffffc0203d38:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203d3a:	57f5                	li	a5,-3
ffffffffc0203d3c:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0203d3e:	00004517          	auipc	a0,0x4
ffffffffc0203d42:	09250513          	addi	a0,a0,146 # ffffffffc0207dd0 <default_pmm_manager+0xa8>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203d46:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc0203d4a:	b82fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0203d4e:	46c5                	li	a3,17
ffffffffc0203d50:	06ee                	slli	a3,a3,0x1b
ffffffffc0203d52:	40100613          	li	a2,1025
ffffffffc0203d56:	07e005b7          	lui	a1,0x7e00
ffffffffc0203d5a:	16fd                	addi	a3,a3,-1
ffffffffc0203d5c:	0656                	slli	a2,a2,0x15
ffffffffc0203d5e:	00004517          	auipc	a0,0x4
ffffffffc0203d62:	08a50513          	addi	a0,a0,138 # ffffffffc0207de8 <default_pmm_manager+0xc0>
ffffffffc0203d66:	b66fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203d6a:	777d                	lui	a4,0xfffff
ffffffffc0203d6c:	000b0797          	auipc	a5,0xb0
ffffffffc0203d70:	aef78793          	addi	a5,a5,-1297 # ffffffffc02b385b <end+0xfff>
ffffffffc0203d74:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0203d76:	00088737          	lui	a4,0x88
ffffffffc0203d7a:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203d7c:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203d80:	4701                	li	a4,0
ffffffffc0203d82:	4585                	li	a1,1
ffffffffc0203d84:	fff80837          	lui	a6,0xfff80
ffffffffc0203d88:	a019                	j	ffffffffc0203d8e <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc0203d8a:	000b3783          	ld	a5,0(s6)
ffffffffc0203d8e:	00671693          	slli	a3,a4,0x6
ffffffffc0203d92:	97b6                	add	a5,a5,a3
ffffffffc0203d94:	07a1                	addi	a5,a5,8
ffffffffc0203d96:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203d9a:	6090                	ld	a2,0(s1)
ffffffffc0203d9c:	0705                	addi	a4,a4,1
ffffffffc0203d9e:	010607b3          	add	a5,a2,a6
ffffffffc0203da2:	fef764e3          	bltu	a4,a5,ffffffffc0203d8a <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203da6:	000b3503          	ld	a0,0(s6)
ffffffffc0203daa:	079a                	slli	a5,a5,0x6
ffffffffc0203dac:	c0200737          	lui	a4,0xc0200
ffffffffc0203db0:	00f506b3          	add	a3,a0,a5
ffffffffc0203db4:	60e6e563          	bltu	a3,a4,ffffffffc02043be <pmm_init+0x6dc>
ffffffffc0203db8:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0203dbc:	4745                	li	a4,17
ffffffffc0203dbe:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203dc0:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0203dc2:	4ae6e563          	bltu	a3,a4,ffffffffc020426c <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0203dc6:	00004517          	auipc	a0,0x4
ffffffffc0203dca:	04a50513          	addi	a0,a0,74 # ffffffffc0207e10 <default_pmm_manager+0xe8>
ffffffffc0203dce:	afefc0ef          	jal	ra,ffffffffc02000cc <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0203dd2:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203dd6:	000af917          	auipc	s2,0xaf
ffffffffc0203dda:	a4290913          	addi	s2,s2,-1470 # ffffffffc02b2818 <boot_pgdir>
    pmm_manager->check();
ffffffffc0203dde:	7b9c                	ld	a5,48(a5)
ffffffffc0203de0:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0203de2:	00004517          	auipc	a0,0x4
ffffffffc0203de6:	04650513          	addi	a0,a0,70 # ffffffffc0207e28 <default_pmm_manager+0x100>
ffffffffc0203dea:	ae2fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203dee:	00007697          	auipc	a3,0x7
ffffffffc0203df2:	21268693          	addi	a3,a3,530 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0203df6:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203dfa:	c02007b7          	lui	a5,0xc0200
ffffffffc0203dfe:	5cf6ec63          	bltu	a3,a5,ffffffffc02043d6 <pmm_init+0x6f4>
ffffffffc0203e02:	0009b783          	ld	a5,0(s3)
ffffffffc0203e06:	8e9d                	sub	a3,a3,a5
ffffffffc0203e08:	000af797          	auipc	a5,0xaf
ffffffffc0203e0c:	a0d7b423          	sd	a3,-1528(a5) # ffffffffc02b2810 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203e10:	100027f3          	csrr	a5,sstatus
ffffffffc0203e14:	8b89                	andi	a5,a5,2
ffffffffc0203e16:	48079263          	bnez	a5,ffffffffc020429a <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203e1a:	000bb783          	ld	a5,0(s7)
ffffffffc0203e1e:	779c                	ld	a5,40(a5)
ffffffffc0203e20:	9782                	jalr	a5
ffffffffc0203e22:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203e24:	6098                	ld	a4,0(s1)
ffffffffc0203e26:	c80007b7          	lui	a5,0xc8000
ffffffffc0203e2a:	83b1                	srli	a5,a5,0xc
ffffffffc0203e2c:	5ee7e163          	bltu	a5,a4,ffffffffc020440e <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203e30:	00093503          	ld	a0,0(s2)
ffffffffc0203e34:	5a050d63          	beqz	a0,ffffffffc02043ee <pmm_init+0x70c>
ffffffffc0203e38:	03451793          	slli	a5,a0,0x34
ffffffffc0203e3c:	5a079963          	bnez	a5,ffffffffc02043ee <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203e40:	4601                	li	a2,0
ffffffffc0203e42:	4581                	li	a1,0
ffffffffc0203e44:	8e1ff0ef          	jal	ra,ffffffffc0203724 <get_page>
ffffffffc0203e48:	62051563          	bnez	a0,ffffffffc0204472 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0203e4c:	4505                	li	a0,1
ffffffffc0203e4e:	df8ff0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0203e52:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203e54:	00093503          	ld	a0,0(s2)
ffffffffc0203e58:	4681                	li	a3,0
ffffffffc0203e5a:	4601                	li	a2,0
ffffffffc0203e5c:	85d2                	mv	a1,s4
ffffffffc0203e5e:	d8fff0ef          	jal	ra,ffffffffc0203bec <page_insert>
ffffffffc0203e62:	5e051863          	bnez	a0,ffffffffc0204452 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203e66:	00093503          	ld	a0,0(s2)
ffffffffc0203e6a:	4601                	li	a2,0
ffffffffc0203e6c:	4581                	li	a1,0
ffffffffc0203e6e:	ee4ff0ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc0203e72:	5c050063          	beqz	a0,ffffffffc0204432 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc0203e76:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203e78:	0017f713          	andi	a4,a5,1
ffffffffc0203e7c:	5a070963          	beqz	a4,ffffffffc020442e <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0203e80:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203e82:	078a                	slli	a5,a5,0x2
ffffffffc0203e84:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203e86:	52e7fa63          	bgeu	a5,a4,ffffffffc02043ba <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203e8a:	000b3683          	ld	a3,0(s6)
ffffffffc0203e8e:	fff80637          	lui	a2,0xfff80
ffffffffc0203e92:	97b2                	add	a5,a5,a2
ffffffffc0203e94:	079a                	slli	a5,a5,0x6
ffffffffc0203e96:	97b6                	add	a5,a5,a3
ffffffffc0203e98:	10fa16e3          	bne	s4,a5,ffffffffc02047a4 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc0203e9c:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0203ea0:	4785                	li	a5,1
ffffffffc0203ea2:	12f69de3          	bne	a3,a5,ffffffffc02047dc <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203ea6:	00093503          	ld	a0,0(s2)
ffffffffc0203eaa:	77fd                	lui	a5,0xfffff
ffffffffc0203eac:	6114                	ld	a3,0(a0)
ffffffffc0203eae:	068a                	slli	a3,a3,0x2
ffffffffc0203eb0:	8efd                	and	a3,a3,a5
ffffffffc0203eb2:	00c6d613          	srli	a2,a3,0xc
ffffffffc0203eb6:	10e677e3          	bgeu	a2,a4,ffffffffc02047c4 <pmm_init+0xae2>
ffffffffc0203eba:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203ebe:	96e2                	add	a3,a3,s8
ffffffffc0203ec0:	0006ba83          	ld	s5,0(a3)
ffffffffc0203ec4:	0a8a                	slli	s5,s5,0x2
ffffffffc0203ec6:	00fafab3          	and	s5,s5,a5
ffffffffc0203eca:	00cad793          	srli	a5,s5,0xc
ffffffffc0203ece:	62e7f263          	bgeu	a5,a4,ffffffffc02044f2 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203ed2:	4601                	li	a2,0
ffffffffc0203ed4:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203ed6:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203ed8:	e7aff0ef          	jal	ra,ffffffffc0203552 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203edc:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203ede:	5f551a63          	bne	a0,s5,ffffffffc02044d2 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc0203ee2:	4505                	li	a0,1
ffffffffc0203ee4:	d62ff0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0203ee8:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203eea:	00093503          	ld	a0,0(s2)
ffffffffc0203eee:	46d1                	li	a3,20
ffffffffc0203ef0:	6605                	lui	a2,0x1
ffffffffc0203ef2:	85d6                	mv	a1,s5
ffffffffc0203ef4:	cf9ff0ef          	jal	ra,ffffffffc0203bec <page_insert>
ffffffffc0203ef8:	58051d63          	bnez	a0,ffffffffc0204492 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203efc:	00093503          	ld	a0,0(s2)
ffffffffc0203f00:	4601                	li	a2,0
ffffffffc0203f02:	6585                	lui	a1,0x1
ffffffffc0203f04:	e4eff0ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc0203f08:	0e050ae3          	beqz	a0,ffffffffc02047fc <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc0203f0c:	611c                	ld	a5,0(a0)
ffffffffc0203f0e:	0107f713          	andi	a4,a5,16
ffffffffc0203f12:	6e070d63          	beqz	a4,ffffffffc020460c <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc0203f16:	8b91                	andi	a5,a5,4
ffffffffc0203f18:	6a078a63          	beqz	a5,ffffffffc02045cc <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203f1c:	00093503          	ld	a0,0(s2)
ffffffffc0203f20:	611c                	ld	a5,0(a0)
ffffffffc0203f22:	8bc1                	andi	a5,a5,16
ffffffffc0203f24:	68078463          	beqz	a5,ffffffffc02045ac <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc0203f28:	000aa703          	lw	a4,0(s5)
ffffffffc0203f2c:	4785                	li	a5,1
ffffffffc0203f2e:	58f71263          	bne	a4,a5,ffffffffc02044b2 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203f32:	4681                	li	a3,0
ffffffffc0203f34:	6605                	lui	a2,0x1
ffffffffc0203f36:	85d2                	mv	a1,s4
ffffffffc0203f38:	cb5ff0ef          	jal	ra,ffffffffc0203bec <page_insert>
ffffffffc0203f3c:	62051863          	bnez	a0,ffffffffc020456c <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc0203f40:	000a2703          	lw	a4,0(s4)
ffffffffc0203f44:	4789                	li	a5,2
ffffffffc0203f46:	60f71363          	bne	a4,a5,ffffffffc020454c <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc0203f4a:	000aa783          	lw	a5,0(s5)
ffffffffc0203f4e:	5c079f63          	bnez	a5,ffffffffc020452c <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203f52:	00093503          	ld	a0,0(s2)
ffffffffc0203f56:	4601                	li	a2,0
ffffffffc0203f58:	6585                	lui	a1,0x1
ffffffffc0203f5a:	df8ff0ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc0203f5e:	5a050763          	beqz	a0,ffffffffc020450c <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc0203f62:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203f64:	00177793          	andi	a5,a4,1
ffffffffc0203f68:	4c078363          	beqz	a5,ffffffffc020442e <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0203f6c:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203f6e:	00271793          	slli	a5,a4,0x2
ffffffffc0203f72:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203f74:	44d7f363          	bgeu	a5,a3,ffffffffc02043ba <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203f78:	000b3683          	ld	a3,0(s6)
ffffffffc0203f7c:	fff80637          	lui	a2,0xfff80
ffffffffc0203f80:	97b2                	add	a5,a5,a2
ffffffffc0203f82:	079a                	slli	a5,a5,0x6
ffffffffc0203f84:	97b6                	add	a5,a5,a3
ffffffffc0203f86:	6efa1363          	bne	s4,a5,ffffffffc020466c <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203f8a:	8b41                	andi	a4,a4,16
ffffffffc0203f8c:	6c071063          	bnez	a4,ffffffffc020464c <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc0203f90:	00093503          	ld	a0,0(s2)
ffffffffc0203f94:	4581                	li	a1,0
ffffffffc0203f96:	bbbff0ef          	jal	ra,ffffffffc0203b50 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0203f9a:	000a2703          	lw	a4,0(s4)
ffffffffc0203f9e:	4785                	li	a5,1
ffffffffc0203fa0:	68f71663          	bne	a4,a5,ffffffffc020462c <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc0203fa4:	000aa783          	lw	a5,0(s5)
ffffffffc0203fa8:	74079e63          	bnez	a5,ffffffffc0204704 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0203fac:	00093503          	ld	a0,0(s2)
ffffffffc0203fb0:	6585                	lui	a1,0x1
ffffffffc0203fb2:	b9fff0ef          	jal	ra,ffffffffc0203b50 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0203fb6:	000a2783          	lw	a5,0(s4)
ffffffffc0203fba:	72079563          	bnez	a5,ffffffffc02046e4 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc0203fbe:	000aa783          	lw	a5,0(s5)
ffffffffc0203fc2:	70079163          	bnez	a5,ffffffffc02046c4 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203fc6:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203fca:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203fcc:	000a3683          	ld	a3,0(s4)
ffffffffc0203fd0:	068a                	slli	a3,a3,0x2
ffffffffc0203fd2:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203fd4:	3ee6f363          	bgeu	a3,a4,ffffffffc02043ba <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203fd8:	fff807b7          	lui	a5,0xfff80
ffffffffc0203fdc:	000b3503          	ld	a0,0(s6)
ffffffffc0203fe0:	96be                	add	a3,a3,a5
ffffffffc0203fe2:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0203fe4:	00d507b3          	add	a5,a0,a3
ffffffffc0203fe8:	4390                	lw	a2,0(a5)
ffffffffc0203fea:	4785                	li	a5,1
ffffffffc0203fec:	6af61c63          	bne	a2,a5,ffffffffc02046a4 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc0203ff0:	8699                	srai	a3,a3,0x6
ffffffffc0203ff2:	000805b7          	lui	a1,0x80
ffffffffc0203ff6:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0203ff8:	00c69613          	slli	a2,a3,0xc
ffffffffc0203ffc:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203ffe:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204000:	68e67663          	bgeu	a2,a4,ffffffffc020468c <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0204004:	0009b603          	ld	a2,0(s3)
ffffffffc0204008:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc020400a:	629c                	ld	a5,0(a3)
ffffffffc020400c:	078a                	slli	a5,a5,0x2
ffffffffc020400e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204010:	3ae7f563          	bgeu	a5,a4,ffffffffc02043ba <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0204014:	8f8d                	sub	a5,a5,a1
ffffffffc0204016:	079a                	slli	a5,a5,0x6
ffffffffc0204018:	953e                	add	a0,a0,a5
ffffffffc020401a:	100027f3          	csrr	a5,sstatus
ffffffffc020401e:	8b89                	andi	a5,a5,2
ffffffffc0204020:	2c079763          	bnez	a5,ffffffffc02042ee <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc0204024:	000bb783          	ld	a5,0(s7)
ffffffffc0204028:	4585                	li	a1,1
ffffffffc020402a:	739c                	ld	a5,32(a5)
ffffffffc020402c:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020402e:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0204032:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204034:	078a                	slli	a5,a5,0x2
ffffffffc0204036:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204038:	38e7f163          	bgeu	a5,a4,ffffffffc02043ba <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020403c:	000b3503          	ld	a0,0(s6)
ffffffffc0204040:	fff80737          	lui	a4,0xfff80
ffffffffc0204044:	97ba                	add	a5,a5,a4
ffffffffc0204046:	079a                	slli	a5,a5,0x6
ffffffffc0204048:	953e                	add	a0,a0,a5
ffffffffc020404a:	100027f3          	csrr	a5,sstatus
ffffffffc020404e:	8b89                	andi	a5,a5,2
ffffffffc0204050:	28079363          	bnez	a5,ffffffffc02042d6 <pmm_init+0x5f4>
ffffffffc0204054:	000bb783          	ld	a5,0(s7)
ffffffffc0204058:	4585                	li	a1,1
ffffffffc020405a:	739c                	ld	a5,32(a5)
ffffffffc020405c:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc020405e:	00093783          	ld	a5,0(s2)
ffffffffc0204062:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fccd7a4>
  asm volatile("sfence.vma");
ffffffffc0204066:	12000073          	sfence.vma
ffffffffc020406a:	100027f3          	csrr	a5,sstatus
ffffffffc020406e:	8b89                	andi	a5,a5,2
ffffffffc0204070:	24079963          	bnez	a5,ffffffffc02042c2 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0204074:	000bb783          	ld	a5,0(s7)
ffffffffc0204078:	779c                	ld	a5,40(a5)
ffffffffc020407a:	9782                	jalr	a5
ffffffffc020407c:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc020407e:	71441363          	bne	s0,s4,ffffffffc0204784 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0204082:	00004517          	auipc	a0,0x4
ffffffffc0204086:	08e50513          	addi	a0,a0,142 # ffffffffc0208110 <default_pmm_manager+0x3e8>
ffffffffc020408a:	842fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020408e:	100027f3          	csrr	a5,sstatus
ffffffffc0204092:	8b89                	andi	a5,a5,2
ffffffffc0204094:	20079d63          	bnez	a5,ffffffffc02042ae <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc0204098:	000bb783          	ld	a5,0(s7)
ffffffffc020409c:	779c                	ld	a5,40(a5)
ffffffffc020409e:	9782                	jalr	a5
ffffffffc02040a0:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02040a2:	6098                	ld	a4,0(s1)
ffffffffc02040a4:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02040a8:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02040aa:	00c71793          	slli	a5,a4,0xc
ffffffffc02040ae:	6a05                	lui	s4,0x1
ffffffffc02040b0:	02f47c63          	bgeu	s0,a5,ffffffffc02040e8 <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02040b4:	00c45793          	srli	a5,s0,0xc
ffffffffc02040b8:	00093503          	ld	a0,0(s2)
ffffffffc02040bc:	2ee7f263          	bgeu	a5,a4,ffffffffc02043a0 <pmm_init+0x6be>
ffffffffc02040c0:	0009b583          	ld	a1,0(s3)
ffffffffc02040c4:	4601                	li	a2,0
ffffffffc02040c6:	95a2                	add	a1,a1,s0
ffffffffc02040c8:	c8aff0ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc02040cc:	2a050a63          	beqz	a0,ffffffffc0204380 <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02040d0:	611c                	ld	a5,0(a0)
ffffffffc02040d2:	078a                	slli	a5,a5,0x2
ffffffffc02040d4:	0157f7b3          	and	a5,a5,s5
ffffffffc02040d8:	28879463          	bne	a5,s0,ffffffffc0204360 <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02040dc:	6098                	ld	a4,0(s1)
ffffffffc02040de:	9452                	add	s0,s0,s4
ffffffffc02040e0:	00c71793          	slli	a5,a4,0xc
ffffffffc02040e4:	fcf468e3          	bltu	s0,a5,ffffffffc02040b4 <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02040e8:	00093783          	ld	a5,0(s2)
ffffffffc02040ec:	639c                	ld	a5,0(a5)
ffffffffc02040ee:	66079b63          	bnez	a5,ffffffffc0204764 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc02040f2:	4505                	li	a0,1
ffffffffc02040f4:	b52ff0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc02040f8:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02040fa:	00093503          	ld	a0,0(s2)
ffffffffc02040fe:	4699                	li	a3,6
ffffffffc0204100:	10000613          	li	a2,256
ffffffffc0204104:	85d6                	mv	a1,s5
ffffffffc0204106:	ae7ff0ef          	jal	ra,ffffffffc0203bec <page_insert>
ffffffffc020410a:	62051d63          	bnez	a0,ffffffffc0204744 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc020410e:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd4c7a4>
ffffffffc0204112:	4785                	li	a5,1
ffffffffc0204114:	60f71863          	bne	a4,a5,ffffffffc0204724 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0204118:	00093503          	ld	a0,0(s2)
ffffffffc020411c:	6405                	lui	s0,0x1
ffffffffc020411e:	4699                	li	a3,6
ffffffffc0204120:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ab0>
ffffffffc0204124:	85d6                	mv	a1,s5
ffffffffc0204126:	ac7ff0ef          	jal	ra,ffffffffc0203bec <page_insert>
ffffffffc020412a:	46051163          	bnez	a0,ffffffffc020458c <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc020412e:	000aa703          	lw	a4,0(s5)
ffffffffc0204132:	4789                	li	a5,2
ffffffffc0204134:	72f71463          	bne	a4,a5,ffffffffc020485c <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0204138:	00004597          	auipc	a1,0x4
ffffffffc020413c:	11058593          	addi	a1,a1,272 # ffffffffc0208248 <default_pmm_manager+0x520>
ffffffffc0204140:	10000513          	li	a0,256
ffffffffc0204144:	010020ef          	jal	ra,ffffffffc0206154 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0204148:	10040593          	addi	a1,s0,256
ffffffffc020414c:	10000513          	li	a0,256
ffffffffc0204150:	016020ef          	jal	ra,ffffffffc0206166 <strcmp>
ffffffffc0204154:	6e051463          	bnez	a0,ffffffffc020483c <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc0204158:	000b3683          	ld	a3,0(s6)
ffffffffc020415c:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0204160:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0204162:	40da86b3          	sub	a3,s5,a3
ffffffffc0204166:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204168:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc020416a:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020416c:	8031                	srli	s0,s0,0xc
ffffffffc020416e:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0204172:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204174:	50f77c63          	bgeu	a4,a5,ffffffffc020468c <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0204178:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020417c:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0204180:	96be                	add	a3,a3,a5
ffffffffc0204182:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0204186:	799010ef          	jal	ra,ffffffffc020611e <strlen>
ffffffffc020418a:	68051963          	bnez	a0,ffffffffc020481c <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020418e:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204192:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204194:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0204198:	068a                	slli	a3,a3,0x2
ffffffffc020419a:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020419c:	20f6ff63          	bgeu	a3,a5,ffffffffc02043ba <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc02041a0:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02041a2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02041a4:	4ef47463          	bgeu	s0,a5,ffffffffc020468c <pmm_init+0x9aa>
ffffffffc02041a8:	0009b403          	ld	s0,0(s3)
ffffffffc02041ac:	9436                	add	s0,s0,a3
ffffffffc02041ae:	100027f3          	csrr	a5,sstatus
ffffffffc02041b2:	8b89                	andi	a5,a5,2
ffffffffc02041b4:	18079b63          	bnez	a5,ffffffffc020434a <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc02041b8:	000bb783          	ld	a5,0(s7)
ffffffffc02041bc:	4585                	li	a1,1
ffffffffc02041be:	8556                	mv	a0,s5
ffffffffc02041c0:	739c                	ld	a5,32(a5)
ffffffffc02041c2:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02041c4:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02041c6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02041c8:	078a                	slli	a5,a5,0x2
ffffffffc02041ca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02041cc:	1ee7f763          	bgeu	a5,a4,ffffffffc02043ba <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02041d0:	000b3503          	ld	a0,0(s6)
ffffffffc02041d4:	fff80737          	lui	a4,0xfff80
ffffffffc02041d8:	97ba                	add	a5,a5,a4
ffffffffc02041da:	079a                	slli	a5,a5,0x6
ffffffffc02041dc:	953e                	add	a0,a0,a5
ffffffffc02041de:	100027f3          	csrr	a5,sstatus
ffffffffc02041e2:	8b89                	andi	a5,a5,2
ffffffffc02041e4:	14079763          	bnez	a5,ffffffffc0204332 <pmm_init+0x650>
ffffffffc02041e8:	000bb783          	ld	a5,0(s7)
ffffffffc02041ec:	4585                	li	a1,1
ffffffffc02041ee:	739c                	ld	a5,32(a5)
ffffffffc02041f0:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02041f2:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02041f6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02041f8:	078a                	slli	a5,a5,0x2
ffffffffc02041fa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02041fc:	1ae7ff63          	bgeu	a5,a4,ffffffffc02043ba <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0204200:	000b3503          	ld	a0,0(s6)
ffffffffc0204204:	fff80737          	lui	a4,0xfff80
ffffffffc0204208:	97ba                	add	a5,a5,a4
ffffffffc020420a:	079a                	slli	a5,a5,0x6
ffffffffc020420c:	953e                	add	a0,a0,a5
ffffffffc020420e:	100027f3          	csrr	a5,sstatus
ffffffffc0204212:	8b89                	andi	a5,a5,2
ffffffffc0204214:	10079363          	bnez	a5,ffffffffc020431a <pmm_init+0x638>
ffffffffc0204218:	000bb783          	ld	a5,0(s7)
ffffffffc020421c:	4585                	li	a1,1
ffffffffc020421e:	739c                	ld	a5,32(a5)
ffffffffc0204220:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0204222:	00093783          	ld	a5,0(s2)
ffffffffc0204226:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc020422a:	12000073          	sfence.vma
ffffffffc020422e:	100027f3          	csrr	a5,sstatus
ffffffffc0204232:	8b89                	andi	a5,a5,2
ffffffffc0204234:	0c079963          	bnez	a5,ffffffffc0204306 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc0204238:	000bb783          	ld	a5,0(s7)
ffffffffc020423c:	779c                	ld	a5,40(a5)
ffffffffc020423e:	9782                	jalr	a5
ffffffffc0204240:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0204242:	3a8c1563          	bne	s8,s0,ffffffffc02045ec <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0204246:	00004517          	auipc	a0,0x4
ffffffffc020424a:	07a50513          	addi	a0,a0,122 # ffffffffc02082c0 <default_pmm_manager+0x598>
ffffffffc020424e:	e7ffb0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0204252:	6446                	ld	s0,80(sp)
ffffffffc0204254:	60e6                	ld	ra,88(sp)
ffffffffc0204256:	64a6                	ld	s1,72(sp)
ffffffffc0204258:	6906                	ld	s2,64(sp)
ffffffffc020425a:	79e2                	ld	s3,56(sp)
ffffffffc020425c:	7a42                	ld	s4,48(sp)
ffffffffc020425e:	7aa2                	ld	s5,40(sp)
ffffffffc0204260:	7b02                	ld	s6,32(sp)
ffffffffc0204262:	6be2                	ld	s7,24(sp)
ffffffffc0204264:	6c42                	ld	s8,16(sp)
ffffffffc0204266:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0204268:	c27fd06f          	j	ffffffffc0201e8e <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020426c:	6785                	lui	a5,0x1
ffffffffc020426e:	17fd                	addi	a5,a5,-1
ffffffffc0204270:	96be                	add	a3,a3,a5
ffffffffc0204272:	77fd                	lui	a5,0xfffff
ffffffffc0204274:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0204276:	00c7d693          	srli	a3,a5,0xc
ffffffffc020427a:	14c6f063          	bgeu	a3,a2,ffffffffc02043ba <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc020427e:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0204282:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0204284:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0204288:	6a10                	ld	a2,16(a2)
ffffffffc020428a:	069a                	slli	a3,a3,0x6
ffffffffc020428c:	00c7d593          	srli	a1,a5,0xc
ffffffffc0204290:	9536                	add	a0,a0,a3
ffffffffc0204292:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0204294:	0009b583          	ld	a1,0(s3)
}
ffffffffc0204298:	b63d                	j	ffffffffc0203dc6 <pmm_init+0xe4>
        intr_disable();
ffffffffc020429a:	baefc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020429e:	000bb783          	ld	a5,0(s7)
ffffffffc02042a2:	779c                	ld	a5,40(a5)
ffffffffc02042a4:	9782                	jalr	a5
ffffffffc02042a6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02042a8:	b9afc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02042ac:	bea5                	j	ffffffffc0203e24 <pmm_init+0x142>
        intr_disable();
ffffffffc02042ae:	b9afc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02042b2:	000bb783          	ld	a5,0(s7)
ffffffffc02042b6:	779c                	ld	a5,40(a5)
ffffffffc02042b8:	9782                	jalr	a5
ffffffffc02042ba:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02042bc:	b86fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02042c0:	b3cd                	j	ffffffffc02040a2 <pmm_init+0x3c0>
        intr_disable();
ffffffffc02042c2:	b86fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02042c6:	000bb783          	ld	a5,0(s7)
ffffffffc02042ca:	779c                	ld	a5,40(a5)
ffffffffc02042cc:	9782                	jalr	a5
ffffffffc02042ce:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02042d0:	b72fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02042d4:	b36d                	j	ffffffffc020407e <pmm_init+0x39c>
ffffffffc02042d6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02042d8:	b70fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02042dc:	000bb783          	ld	a5,0(s7)
ffffffffc02042e0:	6522                	ld	a0,8(sp)
ffffffffc02042e2:	4585                	li	a1,1
ffffffffc02042e4:	739c                	ld	a5,32(a5)
ffffffffc02042e6:	9782                	jalr	a5
        intr_enable();
ffffffffc02042e8:	b5afc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02042ec:	bb8d                	j	ffffffffc020405e <pmm_init+0x37c>
ffffffffc02042ee:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02042f0:	b58fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02042f4:	000bb783          	ld	a5,0(s7)
ffffffffc02042f8:	6522                	ld	a0,8(sp)
ffffffffc02042fa:	4585                	li	a1,1
ffffffffc02042fc:	739c                	ld	a5,32(a5)
ffffffffc02042fe:	9782                	jalr	a5
        intr_enable();
ffffffffc0204300:	b42fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204304:	b32d                	j	ffffffffc020402e <pmm_init+0x34c>
        intr_disable();
ffffffffc0204306:	b42fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020430a:	000bb783          	ld	a5,0(s7)
ffffffffc020430e:	779c                	ld	a5,40(a5)
ffffffffc0204310:	9782                	jalr	a5
ffffffffc0204312:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0204314:	b2efc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204318:	b72d                	j	ffffffffc0204242 <pmm_init+0x560>
ffffffffc020431a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020431c:	b2cfc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0204320:	000bb783          	ld	a5,0(s7)
ffffffffc0204324:	6522                	ld	a0,8(sp)
ffffffffc0204326:	4585                	li	a1,1
ffffffffc0204328:	739c                	ld	a5,32(a5)
ffffffffc020432a:	9782                	jalr	a5
        intr_enable();
ffffffffc020432c:	b16fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204330:	bdcd                	j	ffffffffc0204222 <pmm_init+0x540>
ffffffffc0204332:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204334:	b14fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0204338:	000bb783          	ld	a5,0(s7)
ffffffffc020433c:	6522                	ld	a0,8(sp)
ffffffffc020433e:	4585                	li	a1,1
ffffffffc0204340:	739c                	ld	a5,32(a5)
ffffffffc0204342:	9782                	jalr	a5
        intr_enable();
ffffffffc0204344:	afefc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204348:	b56d                	j	ffffffffc02041f2 <pmm_init+0x510>
        intr_disable();
ffffffffc020434a:	afefc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc020434e:	000bb783          	ld	a5,0(s7)
ffffffffc0204352:	4585                	li	a1,1
ffffffffc0204354:	8556                	mv	a0,s5
ffffffffc0204356:	739c                	ld	a5,32(a5)
ffffffffc0204358:	9782                	jalr	a5
        intr_enable();
ffffffffc020435a:	ae8fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020435e:	b59d                	j	ffffffffc02041c4 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0204360:	00004697          	auipc	a3,0x4
ffffffffc0204364:	e1068693          	addi	a3,a3,-496 # ffffffffc0208170 <default_pmm_manager+0x448>
ffffffffc0204368:	00003617          	auipc	a2,0x3
ffffffffc020436c:	91860613          	addi	a2,a2,-1768 # ffffffffc0206c80 <commands+0x410>
ffffffffc0204370:	23300593          	li	a1,563
ffffffffc0204374:	00004517          	auipc	a0,0x4
ffffffffc0204378:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc020437c:	e8dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0204380:	00004697          	auipc	a3,0x4
ffffffffc0204384:	db068693          	addi	a3,a3,-592 # ffffffffc0208130 <default_pmm_manager+0x408>
ffffffffc0204388:	00003617          	auipc	a2,0x3
ffffffffc020438c:	8f860613          	addi	a2,a2,-1800 # ffffffffc0206c80 <commands+0x410>
ffffffffc0204390:	23200593          	li	a1,562
ffffffffc0204394:	00004517          	auipc	a0,0x4
ffffffffc0204398:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc020439c:	e6dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02043a0:	86a2                	mv	a3,s0
ffffffffc02043a2:	00003617          	auipc	a2,0x3
ffffffffc02043a6:	eae60613          	addi	a2,a2,-338 # ffffffffc0207250 <commands+0x9e0>
ffffffffc02043aa:	23200593          	li	a1,562
ffffffffc02043ae:	00004517          	auipc	a0,0x4
ffffffffc02043b2:	9b250513          	addi	a0,a0,-1614 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02043b6:	e53fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02043ba:	854ff0ef          	jal	ra,ffffffffc020340e <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02043be:	00003617          	auipc	a2,0x3
ffffffffc02043c2:	21a60613          	addi	a2,a2,538 # ffffffffc02075d8 <commands+0xd68>
ffffffffc02043c6:	07f00593          	li	a1,127
ffffffffc02043ca:	00004517          	auipc	a0,0x4
ffffffffc02043ce:	99650513          	addi	a0,a0,-1642 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02043d2:	e37fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02043d6:	00003617          	auipc	a2,0x3
ffffffffc02043da:	20260613          	addi	a2,a2,514 # ffffffffc02075d8 <commands+0xd68>
ffffffffc02043de:	0c100593          	li	a1,193
ffffffffc02043e2:	00004517          	auipc	a0,0x4
ffffffffc02043e6:	97e50513          	addi	a0,a0,-1666 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02043ea:	e1ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02043ee:	00004697          	auipc	a3,0x4
ffffffffc02043f2:	a7a68693          	addi	a3,a3,-1414 # ffffffffc0207e68 <default_pmm_manager+0x140>
ffffffffc02043f6:	00003617          	auipc	a2,0x3
ffffffffc02043fa:	88a60613          	addi	a2,a2,-1910 # ffffffffc0206c80 <commands+0x410>
ffffffffc02043fe:	1f600593          	li	a1,502
ffffffffc0204402:	00004517          	auipc	a0,0x4
ffffffffc0204406:	95e50513          	addi	a0,a0,-1698 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc020440a:	dfffb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020440e:	00004697          	auipc	a3,0x4
ffffffffc0204412:	a3a68693          	addi	a3,a3,-1478 # ffffffffc0207e48 <default_pmm_manager+0x120>
ffffffffc0204416:	00003617          	auipc	a2,0x3
ffffffffc020441a:	86a60613          	addi	a2,a2,-1942 # ffffffffc0206c80 <commands+0x410>
ffffffffc020441e:	1f500593          	li	a1,501
ffffffffc0204422:	00004517          	auipc	a0,0x4
ffffffffc0204426:	93e50513          	addi	a0,a0,-1730 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc020442a:	ddffb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc020442e:	ffdfe0ef          	jal	ra,ffffffffc020342a <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0204432:	00004697          	auipc	a3,0x4
ffffffffc0204436:	ac668693          	addi	a3,a3,-1338 # ffffffffc0207ef8 <default_pmm_manager+0x1d0>
ffffffffc020443a:	00003617          	auipc	a2,0x3
ffffffffc020443e:	84660613          	addi	a2,a2,-1978 # ffffffffc0206c80 <commands+0x410>
ffffffffc0204442:	1fe00593          	li	a1,510
ffffffffc0204446:	00004517          	auipc	a0,0x4
ffffffffc020444a:	91a50513          	addi	a0,a0,-1766 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc020444e:	dbbfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0204452:	00004697          	auipc	a3,0x4
ffffffffc0204456:	a7668693          	addi	a3,a3,-1418 # ffffffffc0207ec8 <default_pmm_manager+0x1a0>
ffffffffc020445a:	00003617          	auipc	a2,0x3
ffffffffc020445e:	82660613          	addi	a2,a2,-2010 # ffffffffc0206c80 <commands+0x410>
ffffffffc0204462:	1fb00593          	li	a1,507
ffffffffc0204466:	00004517          	auipc	a0,0x4
ffffffffc020446a:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc020446e:	d9bfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0204472:	00004697          	auipc	a3,0x4
ffffffffc0204476:	a2e68693          	addi	a3,a3,-1490 # ffffffffc0207ea0 <default_pmm_manager+0x178>
ffffffffc020447a:	00003617          	auipc	a2,0x3
ffffffffc020447e:	80660613          	addi	a2,a2,-2042 # ffffffffc0206c80 <commands+0x410>
ffffffffc0204482:	1f700593          	li	a1,503
ffffffffc0204486:	00004517          	auipc	a0,0x4
ffffffffc020448a:	8da50513          	addi	a0,a0,-1830 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc020448e:	d7bfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0204492:	00004697          	auipc	a3,0x4
ffffffffc0204496:	aee68693          	addi	a3,a3,-1298 # ffffffffc0207f80 <default_pmm_manager+0x258>
ffffffffc020449a:	00002617          	auipc	a2,0x2
ffffffffc020449e:	7e660613          	addi	a2,a2,2022 # ffffffffc0206c80 <commands+0x410>
ffffffffc02044a2:	20700593          	li	a1,519
ffffffffc02044a6:	00004517          	auipc	a0,0x4
ffffffffc02044aa:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02044ae:	d5bfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02044b2:	00004697          	auipc	a3,0x4
ffffffffc02044b6:	b6e68693          	addi	a3,a3,-1170 # ffffffffc0208020 <default_pmm_manager+0x2f8>
ffffffffc02044ba:	00002617          	auipc	a2,0x2
ffffffffc02044be:	7c660613          	addi	a2,a2,1990 # ffffffffc0206c80 <commands+0x410>
ffffffffc02044c2:	20c00593          	li	a1,524
ffffffffc02044c6:	00004517          	auipc	a0,0x4
ffffffffc02044ca:	89a50513          	addi	a0,a0,-1894 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02044ce:	d3bfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02044d2:	00004697          	auipc	a3,0x4
ffffffffc02044d6:	a8668693          	addi	a3,a3,-1402 # ffffffffc0207f58 <default_pmm_manager+0x230>
ffffffffc02044da:	00002617          	auipc	a2,0x2
ffffffffc02044de:	7a660613          	addi	a2,a2,1958 # ffffffffc0206c80 <commands+0x410>
ffffffffc02044e2:	20400593          	li	a1,516
ffffffffc02044e6:	00004517          	auipc	a0,0x4
ffffffffc02044ea:	87a50513          	addi	a0,a0,-1926 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02044ee:	d1bfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02044f2:	86d6                	mv	a3,s5
ffffffffc02044f4:	00003617          	auipc	a2,0x3
ffffffffc02044f8:	d5c60613          	addi	a2,a2,-676 # ffffffffc0207250 <commands+0x9e0>
ffffffffc02044fc:	20300593          	li	a1,515
ffffffffc0204500:	00004517          	auipc	a0,0x4
ffffffffc0204504:	86050513          	addi	a0,a0,-1952 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204508:	d01fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020450c:	00004697          	auipc	a3,0x4
ffffffffc0204510:	aac68693          	addi	a3,a3,-1364 # ffffffffc0207fb8 <default_pmm_manager+0x290>
ffffffffc0204514:	00002617          	auipc	a2,0x2
ffffffffc0204518:	76c60613          	addi	a2,a2,1900 # ffffffffc0206c80 <commands+0x410>
ffffffffc020451c:	21100593          	li	a1,529
ffffffffc0204520:	00004517          	auipc	a0,0x4
ffffffffc0204524:	84050513          	addi	a0,a0,-1984 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204528:	ce1fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020452c:	00004697          	auipc	a3,0x4
ffffffffc0204530:	b5468693          	addi	a3,a3,-1196 # ffffffffc0208080 <default_pmm_manager+0x358>
ffffffffc0204534:	00002617          	auipc	a2,0x2
ffffffffc0204538:	74c60613          	addi	a2,a2,1868 # ffffffffc0206c80 <commands+0x410>
ffffffffc020453c:	21000593          	li	a1,528
ffffffffc0204540:	00004517          	auipc	a0,0x4
ffffffffc0204544:	82050513          	addi	a0,a0,-2016 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204548:	cc1fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020454c:	00004697          	auipc	a3,0x4
ffffffffc0204550:	b1c68693          	addi	a3,a3,-1252 # ffffffffc0208068 <default_pmm_manager+0x340>
ffffffffc0204554:	00002617          	auipc	a2,0x2
ffffffffc0204558:	72c60613          	addi	a2,a2,1836 # ffffffffc0206c80 <commands+0x410>
ffffffffc020455c:	20f00593          	li	a1,527
ffffffffc0204560:	00004517          	auipc	a0,0x4
ffffffffc0204564:	80050513          	addi	a0,a0,-2048 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204568:	ca1fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020456c:	00004697          	auipc	a3,0x4
ffffffffc0204570:	acc68693          	addi	a3,a3,-1332 # ffffffffc0208038 <default_pmm_manager+0x310>
ffffffffc0204574:	00002617          	auipc	a2,0x2
ffffffffc0204578:	70c60613          	addi	a2,a2,1804 # ffffffffc0206c80 <commands+0x410>
ffffffffc020457c:	20e00593          	li	a1,526
ffffffffc0204580:	00003517          	auipc	a0,0x3
ffffffffc0204584:	7e050513          	addi	a0,a0,2016 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204588:	c81fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020458c:	00004697          	auipc	a3,0x4
ffffffffc0204590:	c6468693          	addi	a3,a3,-924 # ffffffffc02081f0 <default_pmm_manager+0x4c8>
ffffffffc0204594:	00002617          	auipc	a2,0x2
ffffffffc0204598:	6ec60613          	addi	a2,a2,1772 # ffffffffc0206c80 <commands+0x410>
ffffffffc020459c:	23d00593          	li	a1,573
ffffffffc02045a0:	00003517          	auipc	a0,0x3
ffffffffc02045a4:	7c050513          	addi	a0,a0,1984 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02045a8:	c61fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02045ac:	00004697          	auipc	a3,0x4
ffffffffc02045b0:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0208008 <default_pmm_manager+0x2e0>
ffffffffc02045b4:	00002617          	auipc	a2,0x2
ffffffffc02045b8:	6cc60613          	addi	a2,a2,1740 # ffffffffc0206c80 <commands+0x410>
ffffffffc02045bc:	20b00593          	li	a1,523
ffffffffc02045c0:	00003517          	auipc	a0,0x3
ffffffffc02045c4:	7a050513          	addi	a0,a0,1952 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02045c8:	c41fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02045cc:	00004697          	auipc	a3,0x4
ffffffffc02045d0:	a2c68693          	addi	a3,a3,-1492 # ffffffffc0207ff8 <default_pmm_manager+0x2d0>
ffffffffc02045d4:	00002617          	auipc	a2,0x2
ffffffffc02045d8:	6ac60613          	addi	a2,a2,1708 # ffffffffc0206c80 <commands+0x410>
ffffffffc02045dc:	20a00593          	li	a1,522
ffffffffc02045e0:	00003517          	auipc	a0,0x3
ffffffffc02045e4:	78050513          	addi	a0,a0,1920 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02045e8:	c21fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02045ec:	00004697          	auipc	a3,0x4
ffffffffc02045f0:	b0468693          	addi	a3,a3,-1276 # ffffffffc02080f0 <default_pmm_manager+0x3c8>
ffffffffc02045f4:	00002617          	auipc	a2,0x2
ffffffffc02045f8:	68c60613          	addi	a2,a2,1676 # ffffffffc0206c80 <commands+0x410>
ffffffffc02045fc:	24e00593          	li	a1,590
ffffffffc0204600:	00003517          	auipc	a0,0x3
ffffffffc0204604:	76050513          	addi	a0,a0,1888 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204608:	c01fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020460c:	00004697          	auipc	a3,0x4
ffffffffc0204610:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0207fe8 <default_pmm_manager+0x2c0>
ffffffffc0204614:	00002617          	auipc	a2,0x2
ffffffffc0204618:	66c60613          	addi	a2,a2,1644 # ffffffffc0206c80 <commands+0x410>
ffffffffc020461c:	20900593          	li	a1,521
ffffffffc0204620:	00003517          	auipc	a0,0x3
ffffffffc0204624:	74050513          	addi	a0,a0,1856 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204628:	be1fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020462c:	00004697          	auipc	a3,0x4
ffffffffc0204630:	91468693          	addi	a3,a3,-1772 # ffffffffc0207f40 <default_pmm_manager+0x218>
ffffffffc0204634:	00002617          	auipc	a2,0x2
ffffffffc0204638:	64c60613          	addi	a2,a2,1612 # ffffffffc0206c80 <commands+0x410>
ffffffffc020463c:	21600593          	li	a1,534
ffffffffc0204640:	00003517          	auipc	a0,0x3
ffffffffc0204644:	72050513          	addi	a0,a0,1824 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204648:	bc1fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020464c:	00004697          	auipc	a3,0x4
ffffffffc0204650:	a4c68693          	addi	a3,a3,-1460 # ffffffffc0208098 <default_pmm_manager+0x370>
ffffffffc0204654:	00002617          	auipc	a2,0x2
ffffffffc0204658:	62c60613          	addi	a2,a2,1580 # ffffffffc0206c80 <commands+0x410>
ffffffffc020465c:	21300593          	li	a1,531
ffffffffc0204660:	00003517          	auipc	a0,0x3
ffffffffc0204664:	70050513          	addi	a0,a0,1792 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204668:	ba1fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020466c:	00004697          	auipc	a3,0x4
ffffffffc0204670:	8bc68693          	addi	a3,a3,-1860 # ffffffffc0207f28 <default_pmm_manager+0x200>
ffffffffc0204674:	00002617          	auipc	a2,0x2
ffffffffc0204678:	60c60613          	addi	a2,a2,1548 # ffffffffc0206c80 <commands+0x410>
ffffffffc020467c:	21200593          	li	a1,530
ffffffffc0204680:	00003517          	auipc	a0,0x3
ffffffffc0204684:	6e050513          	addi	a0,a0,1760 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204688:	b81fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc020468c:	00003617          	auipc	a2,0x3
ffffffffc0204690:	bc460613          	addi	a2,a2,-1084 # ffffffffc0207250 <commands+0x9e0>
ffffffffc0204694:	06900593          	li	a1,105
ffffffffc0204698:	00003517          	auipc	a0,0x3
ffffffffc020469c:	ba850513          	addi	a0,a0,-1112 # ffffffffc0207240 <commands+0x9d0>
ffffffffc02046a0:	b69fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02046a4:	00004697          	auipc	a3,0x4
ffffffffc02046a8:	a2468693          	addi	a3,a3,-1500 # ffffffffc02080c8 <default_pmm_manager+0x3a0>
ffffffffc02046ac:	00002617          	auipc	a2,0x2
ffffffffc02046b0:	5d460613          	addi	a2,a2,1492 # ffffffffc0206c80 <commands+0x410>
ffffffffc02046b4:	21d00593          	li	a1,541
ffffffffc02046b8:	00003517          	auipc	a0,0x3
ffffffffc02046bc:	6a850513          	addi	a0,a0,1704 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02046c0:	b49fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02046c4:	00004697          	auipc	a3,0x4
ffffffffc02046c8:	9bc68693          	addi	a3,a3,-1604 # ffffffffc0208080 <default_pmm_manager+0x358>
ffffffffc02046cc:	00002617          	auipc	a2,0x2
ffffffffc02046d0:	5b460613          	addi	a2,a2,1460 # ffffffffc0206c80 <commands+0x410>
ffffffffc02046d4:	21b00593          	li	a1,539
ffffffffc02046d8:	00003517          	auipc	a0,0x3
ffffffffc02046dc:	68850513          	addi	a0,a0,1672 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02046e0:	b29fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02046e4:	00004697          	auipc	a3,0x4
ffffffffc02046e8:	9cc68693          	addi	a3,a3,-1588 # ffffffffc02080b0 <default_pmm_manager+0x388>
ffffffffc02046ec:	00002617          	auipc	a2,0x2
ffffffffc02046f0:	59460613          	addi	a2,a2,1428 # ffffffffc0206c80 <commands+0x410>
ffffffffc02046f4:	21a00593          	li	a1,538
ffffffffc02046f8:	00003517          	auipc	a0,0x3
ffffffffc02046fc:	66850513          	addi	a0,a0,1640 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204700:	b09fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0204704:	00004697          	auipc	a3,0x4
ffffffffc0204708:	97c68693          	addi	a3,a3,-1668 # ffffffffc0208080 <default_pmm_manager+0x358>
ffffffffc020470c:	00002617          	auipc	a2,0x2
ffffffffc0204710:	57460613          	addi	a2,a2,1396 # ffffffffc0206c80 <commands+0x410>
ffffffffc0204714:	21700593          	li	a1,535
ffffffffc0204718:	00003517          	auipc	a0,0x3
ffffffffc020471c:	64850513          	addi	a0,a0,1608 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204720:	ae9fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0204724:	00004697          	auipc	a3,0x4
ffffffffc0204728:	ab468693          	addi	a3,a3,-1356 # ffffffffc02081d8 <default_pmm_manager+0x4b0>
ffffffffc020472c:	00002617          	auipc	a2,0x2
ffffffffc0204730:	55460613          	addi	a2,a2,1364 # ffffffffc0206c80 <commands+0x410>
ffffffffc0204734:	23c00593          	li	a1,572
ffffffffc0204738:	00003517          	auipc	a0,0x3
ffffffffc020473c:	62850513          	addi	a0,a0,1576 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204740:	ac9fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0204744:	00004697          	auipc	a3,0x4
ffffffffc0204748:	a5c68693          	addi	a3,a3,-1444 # ffffffffc02081a0 <default_pmm_manager+0x478>
ffffffffc020474c:	00002617          	auipc	a2,0x2
ffffffffc0204750:	53460613          	addi	a2,a2,1332 # ffffffffc0206c80 <commands+0x410>
ffffffffc0204754:	23b00593          	li	a1,571
ffffffffc0204758:	00003517          	auipc	a0,0x3
ffffffffc020475c:	60850513          	addi	a0,a0,1544 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204760:	aa9fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0204764:	00004697          	auipc	a3,0x4
ffffffffc0204768:	a2468693          	addi	a3,a3,-1500 # ffffffffc0208188 <default_pmm_manager+0x460>
ffffffffc020476c:	00002617          	auipc	a2,0x2
ffffffffc0204770:	51460613          	addi	a2,a2,1300 # ffffffffc0206c80 <commands+0x410>
ffffffffc0204774:	23700593          	li	a1,567
ffffffffc0204778:	00003517          	auipc	a0,0x3
ffffffffc020477c:	5e850513          	addi	a0,a0,1512 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204780:	a89fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0204784:	00004697          	auipc	a3,0x4
ffffffffc0204788:	96c68693          	addi	a3,a3,-1684 # ffffffffc02080f0 <default_pmm_manager+0x3c8>
ffffffffc020478c:	00002617          	auipc	a2,0x2
ffffffffc0204790:	4f460613          	addi	a2,a2,1268 # ffffffffc0206c80 <commands+0x410>
ffffffffc0204794:	22500593          	li	a1,549
ffffffffc0204798:	00003517          	auipc	a0,0x3
ffffffffc020479c:	5c850513          	addi	a0,a0,1480 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02047a0:	a69fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02047a4:	00003697          	auipc	a3,0x3
ffffffffc02047a8:	78468693          	addi	a3,a3,1924 # ffffffffc0207f28 <default_pmm_manager+0x200>
ffffffffc02047ac:	00002617          	auipc	a2,0x2
ffffffffc02047b0:	4d460613          	addi	a2,a2,1236 # ffffffffc0206c80 <commands+0x410>
ffffffffc02047b4:	1ff00593          	li	a1,511
ffffffffc02047b8:	00003517          	auipc	a0,0x3
ffffffffc02047bc:	5a850513          	addi	a0,a0,1448 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02047c0:	a49fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02047c4:	00003617          	auipc	a2,0x3
ffffffffc02047c8:	a8c60613          	addi	a2,a2,-1396 # ffffffffc0207250 <commands+0x9e0>
ffffffffc02047cc:	20200593          	li	a1,514
ffffffffc02047d0:	00003517          	auipc	a0,0x3
ffffffffc02047d4:	59050513          	addi	a0,a0,1424 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02047d8:	a31fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02047dc:	00003697          	auipc	a3,0x3
ffffffffc02047e0:	76468693          	addi	a3,a3,1892 # ffffffffc0207f40 <default_pmm_manager+0x218>
ffffffffc02047e4:	00002617          	auipc	a2,0x2
ffffffffc02047e8:	49c60613          	addi	a2,a2,1180 # ffffffffc0206c80 <commands+0x410>
ffffffffc02047ec:	20000593          	li	a1,512
ffffffffc02047f0:	00003517          	auipc	a0,0x3
ffffffffc02047f4:	57050513          	addi	a0,a0,1392 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02047f8:	a11fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02047fc:	00003697          	auipc	a3,0x3
ffffffffc0204800:	7bc68693          	addi	a3,a3,1980 # ffffffffc0207fb8 <default_pmm_manager+0x290>
ffffffffc0204804:	00002617          	auipc	a2,0x2
ffffffffc0204808:	47c60613          	addi	a2,a2,1148 # ffffffffc0206c80 <commands+0x410>
ffffffffc020480c:	20800593          	li	a1,520
ffffffffc0204810:	00003517          	auipc	a0,0x3
ffffffffc0204814:	55050513          	addi	a0,a0,1360 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204818:	9f1fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020481c:	00004697          	auipc	a3,0x4
ffffffffc0204820:	a7c68693          	addi	a3,a3,-1412 # ffffffffc0208298 <default_pmm_manager+0x570>
ffffffffc0204824:	00002617          	auipc	a2,0x2
ffffffffc0204828:	45c60613          	addi	a2,a2,1116 # ffffffffc0206c80 <commands+0x410>
ffffffffc020482c:	24500593          	li	a1,581
ffffffffc0204830:	00003517          	auipc	a0,0x3
ffffffffc0204834:	53050513          	addi	a0,a0,1328 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204838:	9d1fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020483c:	00004697          	auipc	a3,0x4
ffffffffc0204840:	a2468693          	addi	a3,a3,-1500 # ffffffffc0208260 <default_pmm_manager+0x538>
ffffffffc0204844:	00002617          	auipc	a2,0x2
ffffffffc0204848:	43c60613          	addi	a2,a2,1084 # ffffffffc0206c80 <commands+0x410>
ffffffffc020484c:	24200593          	li	a1,578
ffffffffc0204850:	00003517          	auipc	a0,0x3
ffffffffc0204854:	51050513          	addi	a0,a0,1296 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204858:	9b1fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020485c:	00004697          	auipc	a3,0x4
ffffffffc0204860:	9d468693          	addi	a3,a3,-1580 # ffffffffc0208230 <default_pmm_manager+0x508>
ffffffffc0204864:	00002617          	auipc	a2,0x2
ffffffffc0204868:	41c60613          	addi	a2,a2,1052 # ffffffffc0206c80 <commands+0x410>
ffffffffc020486c:	23e00593          	li	a1,574
ffffffffc0204870:	00003517          	auipc	a0,0x3
ffffffffc0204874:	4f050513          	addi	a0,a0,1264 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204878:	991fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020487c <copy_range>:
               bool share) {
ffffffffc020487c:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020487e:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc0204882:	f486                	sd	ra,104(sp)
ffffffffc0204884:	f0a2                	sd	s0,96(sp)
ffffffffc0204886:	eca6                	sd	s1,88(sp)
ffffffffc0204888:	e8ca                	sd	s2,80(sp)
ffffffffc020488a:	e4ce                	sd	s3,72(sp)
ffffffffc020488c:	e0d2                	sd	s4,64(sp)
ffffffffc020488e:	fc56                	sd	s5,56(sp)
ffffffffc0204890:	f85a                	sd	s6,48(sp)
ffffffffc0204892:	f45e                	sd	s7,40(sp)
ffffffffc0204894:	f062                	sd	s8,32(sp)
ffffffffc0204896:	ec66                	sd	s9,24(sp)
ffffffffc0204898:	e86a                	sd	s10,16(sp)
ffffffffc020489a:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020489c:	17d2                	slli	a5,a5,0x34
ffffffffc020489e:	1e079763          	bnez	a5,ffffffffc0204a8c <copy_range+0x210>
    assert(USER_ACCESS(start, end));
ffffffffc02048a2:	002007b7          	lui	a5,0x200
ffffffffc02048a6:	8432                	mv	s0,a2
ffffffffc02048a8:	16f66a63          	bltu	a2,a5,ffffffffc0204a1c <copy_range+0x1a0>
ffffffffc02048ac:	8936                	mv	s2,a3
ffffffffc02048ae:	16d67763          	bgeu	a2,a3,ffffffffc0204a1c <copy_range+0x1a0>
ffffffffc02048b2:	4785                	li	a5,1
ffffffffc02048b4:	07fe                	slli	a5,a5,0x1f
ffffffffc02048b6:	16d7e363          	bltu	a5,a3,ffffffffc0204a1c <copy_range+0x1a0>
ffffffffc02048ba:	5b7d                	li	s6,-1
ffffffffc02048bc:	8aaa                	mv	s5,a0
ffffffffc02048be:	89ae                	mv	s3,a1
        start += PGSIZE;
ffffffffc02048c0:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02048c2:	000aec97          	auipc	s9,0xae
ffffffffc02048c6:	f5ec8c93          	addi	s9,s9,-162 # ffffffffc02b2820 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02048ca:	000aec17          	auipc	s8,0xae
ffffffffc02048ce:	f5ec0c13          	addi	s8,s8,-162 # ffffffffc02b2828 <pages>
    return page - pages + nbase;
ffffffffc02048d2:	00080bb7          	lui	s7,0x80
    return KADDR(page2pa(page));
ffffffffc02048d6:	00cb5b13          	srli	s6,s6,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02048da:	4601                	li	a2,0
ffffffffc02048dc:	85a2                	mv	a1,s0
ffffffffc02048de:	854e                	mv	a0,s3
ffffffffc02048e0:	c73fe0ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc02048e4:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02048e6:	c175                	beqz	a0,ffffffffc02049ca <copy_range+0x14e>
        if (*ptep & PTE_V) {
ffffffffc02048e8:	611c                	ld	a5,0(a0)
ffffffffc02048ea:	8b85                	andi	a5,a5,1
ffffffffc02048ec:	e785                	bnez	a5,ffffffffc0204914 <copy_range+0x98>
        start += PGSIZE;
ffffffffc02048ee:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02048f0:	ff2465e3          	bltu	s0,s2,ffffffffc02048da <copy_range+0x5e>
    return 0;
ffffffffc02048f4:	4501                	li	a0,0
}
ffffffffc02048f6:	70a6                	ld	ra,104(sp)
ffffffffc02048f8:	7406                	ld	s0,96(sp)
ffffffffc02048fa:	64e6                	ld	s1,88(sp)
ffffffffc02048fc:	6946                	ld	s2,80(sp)
ffffffffc02048fe:	69a6                	ld	s3,72(sp)
ffffffffc0204900:	6a06                	ld	s4,64(sp)
ffffffffc0204902:	7ae2                	ld	s5,56(sp)
ffffffffc0204904:	7b42                	ld	s6,48(sp)
ffffffffc0204906:	7ba2                	ld	s7,40(sp)
ffffffffc0204908:	7c02                	ld	s8,32(sp)
ffffffffc020490a:	6ce2                	ld	s9,24(sp)
ffffffffc020490c:	6d42                	ld	s10,16(sp)
ffffffffc020490e:	6da2                	ld	s11,8(sp)
ffffffffc0204910:	6165                	addi	sp,sp,112
ffffffffc0204912:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0204914:	4605                	li	a2,1
ffffffffc0204916:	85a2                	mv	a1,s0
ffffffffc0204918:	8556                	mv	a0,s5
ffffffffc020491a:	c39fe0ef          	jal	ra,ffffffffc0203552 <get_pte>
ffffffffc020491e:	c161                	beqz	a0,ffffffffc02049de <copy_range+0x162>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0204920:	609c                	ld	a5,0(s1)
    if (!(pte & PTE_V)) {
ffffffffc0204922:	0017f713          	andi	a4,a5,1
ffffffffc0204926:	01f7f493          	andi	s1,a5,31
ffffffffc020492a:	14070563          	beqz	a4,ffffffffc0204a74 <copy_range+0x1f8>
    if (PPN(pa) >= npage) {
ffffffffc020492e:	000cb683          	ld	a3,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0204932:	078a                	slli	a5,a5,0x2
ffffffffc0204934:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204938:	12d77263          	bgeu	a4,a3,ffffffffc0204a5c <copy_range+0x1e0>
    return &pages[PPN(pa) - nbase];
ffffffffc020493c:	000c3783          	ld	a5,0(s8)
ffffffffc0204940:	fff806b7          	lui	a3,0xfff80
ffffffffc0204944:	9736                	add	a4,a4,a3
ffffffffc0204946:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc0204948:	4505                	li	a0,1
ffffffffc020494a:	00e78db3          	add	s11,a5,a4
ffffffffc020494e:	af9fe0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0204952:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc0204954:	0a0d8463          	beqz	s11,ffffffffc02049fc <copy_range+0x180>
            assert(npage != NULL);
ffffffffc0204958:	c175                	beqz	a0,ffffffffc0204a3c <copy_range+0x1c0>
    return page - pages + nbase;
ffffffffc020495a:	000c3703          	ld	a4,0(s8)
    return KADDR(page2pa(page));
ffffffffc020495e:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0204962:	40ed86b3          	sub	a3,s11,a4
ffffffffc0204966:	8699                	srai	a3,a3,0x6
ffffffffc0204968:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc020496a:	0166f7b3          	and	a5,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc020496e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204970:	06c7fa63          	bgeu	a5,a2,ffffffffc02049e4 <copy_range+0x168>
    return page - pages + nbase;
ffffffffc0204974:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc0204978:	000ae717          	auipc	a4,0xae
ffffffffc020497c:	ec070713          	addi	a4,a4,-320 # ffffffffc02b2838 <va_pa_offset>
ffffffffc0204980:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc0204982:	8799                	srai	a5,a5,0x6
ffffffffc0204984:	97de                	add	a5,a5,s7
    return KADDR(page2pa(page));
ffffffffc0204986:	0167f733          	and	a4,a5,s6
ffffffffc020498a:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020498e:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0204990:	04c77963          	bgeu	a4,a2,ffffffffc02049e2 <copy_range+0x166>
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc0204994:	6605                	lui	a2,0x1
ffffffffc0204996:	953e                	add	a0,a0,a5
ffffffffc0204998:	015010ef          	jal	ra,ffffffffc02061ac <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc020499c:	86a6                	mv	a3,s1
ffffffffc020499e:	8622                	mv	a2,s0
ffffffffc02049a0:	85ea                	mv	a1,s10
ffffffffc02049a2:	8556                	mv	a0,s5
ffffffffc02049a4:	a48ff0ef          	jal	ra,ffffffffc0203bec <page_insert>
            assert(ret == 0);
ffffffffc02049a8:	d139                	beqz	a0,ffffffffc02048ee <copy_range+0x72>
ffffffffc02049aa:	00004697          	auipc	a3,0x4
ffffffffc02049ae:	95668693          	addi	a3,a3,-1706 # ffffffffc0208300 <default_pmm_manager+0x5d8>
ffffffffc02049b2:	00002617          	auipc	a2,0x2
ffffffffc02049b6:	2ce60613          	addi	a2,a2,718 # ffffffffc0206c80 <commands+0x410>
ffffffffc02049ba:	19700593          	li	a1,407
ffffffffc02049be:	00003517          	auipc	a0,0x3
ffffffffc02049c2:	3a250513          	addi	a0,a0,930 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc02049c6:	843fb0ef          	jal	ra,ffffffffc0200208 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02049ca:	00200637          	lui	a2,0x200
ffffffffc02049ce:	9432                	add	s0,s0,a2
ffffffffc02049d0:	ffe00637          	lui	a2,0xffe00
ffffffffc02049d4:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc02049d6:	dc19                	beqz	s0,ffffffffc02048f4 <copy_range+0x78>
ffffffffc02049d8:	f12461e3          	bltu	s0,s2,ffffffffc02048da <copy_range+0x5e>
ffffffffc02049dc:	bf21                	j	ffffffffc02048f4 <copy_range+0x78>
                return -E_NO_MEM;
ffffffffc02049de:	5571                	li	a0,-4
ffffffffc02049e0:	bf19                	j	ffffffffc02048f6 <copy_range+0x7a>
ffffffffc02049e2:	86be                	mv	a3,a5
ffffffffc02049e4:	00003617          	auipc	a2,0x3
ffffffffc02049e8:	86c60613          	addi	a2,a2,-1940 # ffffffffc0207250 <commands+0x9e0>
ffffffffc02049ec:	06900593          	li	a1,105
ffffffffc02049f0:	00003517          	auipc	a0,0x3
ffffffffc02049f4:	85050513          	addi	a0,a0,-1968 # ffffffffc0207240 <commands+0x9d0>
ffffffffc02049f8:	811fb0ef          	jal	ra,ffffffffc0200208 <__panic>
            assert(page != NULL);
ffffffffc02049fc:	00004697          	auipc	a3,0x4
ffffffffc0204a00:	8e468693          	addi	a3,a3,-1820 # ffffffffc02082e0 <default_pmm_manager+0x5b8>
ffffffffc0204a04:	00002617          	auipc	a2,0x2
ffffffffc0204a08:	27c60613          	addi	a2,a2,636 # ffffffffc0206c80 <commands+0x410>
ffffffffc0204a0c:	17200593          	li	a1,370
ffffffffc0204a10:	00003517          	auipc	a0,0x3
ffffffffc0204a14:	35050513          	addi	a0,a0,848 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204a18:	ff0fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0204a1c:	00003697          	auipc	a3,0x3
ffffffffc0204a20:	38468693          	addi	a3,a3,900 # ffffffffc0207da0 <default_pmm_manager+0x78>
ffffffffc0204a24:	00002617          	auipc	a2,0x2
ffffffffc0204a28:	25c60613          	addi	a2,a2,604 # ffffffffc0206c80 <commands+0x410>
ffffffffc0204a2c:	15e00593          	li	a1,350
ffffffffc0204a30:	00003517          	auipc	a0,0x3
ffffffffc0204a34:	33050513          	addi	a0,a0,816 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204a38:	fd0fb0ef          	jal	ra,ffffffffc0200208 <__panic>
            assert(npage != NULL);
ffffffffc0204a3c:	00004697          	auipc	a3,0x4
ffffffffc0204a40:	8b468693          	addi	a3,a3,-1868 # ffffffffc02082f0 <default_pmm_manager+0x5c8>
ffffffffc0204a44:	00002617          	auipc	a2,0x2
ffffffffc0204a48:	23c60613          	addi	a2,a2,572 # ffffffffc0206c80 <commands+0x410>
ffffffffc0204a4c:	17300593          	li	a1,371
ffffffffc0204a50:	00003517          	auipc	a0,0x3
ffffffffc0204a54:	31050513          	addi	a0,a0,784 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204a58:	fb0fb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204a5c:	00002617          	auipc	a2,0x2
ffffffffc0204a60:	7c460613          	addi	a2,a2,1988 # ffffffffc0207220 <commands+0x9b0>
ffffffffc0204a64:	06200593          	li	a1,98
ffffffffc0204a68:	00002517          	auipc	a0,0x2
ffffffffc0204a6c:	7d850513          	addi	a0,a0,2008 # ffffffffc0207240 <commands+0x9d0>
ffffffffc0204a70:	f98fb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0204a74:	00003617          	auipc	a2,0x3
ffffffffc0204a78:	d9c60613          	addi	a2,a2,-612 # ffffffffc0207810 <commands+0xfa0>
ffffffffc0204a7c:	07400593          	li	a1,116
ffffffffc0204a80:	00002517          	auipc	a0,0x2
ffffffffc0204a84:	7c050513          	addi	a0,a0,1984 # ffffffffc0207240 <commands+0x9d0>
ffffffffc0204a88:	f80fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0204a8c:	00003697          	auipc	a3,0x3
ffffffffc0204a90:	2e468693          	addi	a3,a3,740 # ffffffffc0207d70 <default_pmm_manager+0x48>
ffffffffc0204a94:	00002617          	auipc	a2,0x2
ffffffffc0204a98:	1ec60613          	addi	a2,a2,492 # ffffffffc0206c80 <commands+0x410>
ffffffffc0204a9c:	15d00593          	li	a1,349
ffffffffc0204aa0:	00003517          	auipc	a0,0x3
ffffffffc0204aa4:	2c050513          	addi	a0,a0,704 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204aa8:	f60fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204aac <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0204aac:	12058073          	sfence.vma	a1
}
ffffffffc0204ab0:	8082                	ret

ffffffffc0204ab2 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204ab2:	7179                	addi	sp,sp,-48
ffffffffc0204ab4:	e84a                	sd	s2,16(sp)
ffffffffc0204ab6:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0204ab8:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204aba:	f022                	sd	s0,32(sp)
ffffffffc0204abc:	ec26                	sd	s1,24(sp)
ffffffffc0204abe:	e44e                	sd	s3,8(sp)
ffffffffc0204ac0:	f406                	sd	ra,40(sp)
ffffffffc0204ac2:	84ae                	mv	s1,a1
ffffffffc0204ac4:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0204ac6:	981fe0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0204aca:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0204acc:	cd05                	beqz	a0,ffffffffc0204b04 <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0204ace:	85aa                	mv	a1,a0
ffffffffc0204ad0:	86ce                	mv	a3,s3
ffffffffc0204ad2:	8626                	mv	a2,s1
ffffffffc0204ad4:	854a                	mv	a0,s2
ffffffffc0204ad6:	916ff0ef          	jal	ra,ffffffffc0203bec <page_insert>
ffffffffc0204ada:	ed0d                	bnez	a0,ffffffffc0204b14 <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc0204adc:	000ae797          	auipc	a5,0xae
ffffffffc0204ae0:	d2c7a783          	lw	a5,-724(a5) # ffffffffc02b2808 <swap_init_ok>
ffffffffc0204ae4:	c385                	beqz	a5,ffffffffc0204b04 <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc0204ae6:	000ae517          	auipc	a0,0xae
ffffffffc0204aea:	cfa53503          	ld	a0,-774(a0) # ffffffffc02b27e0 <check_mm_struct>
ffffffffc0204aee:	c919                	beqz	a0,ffffffffc0204b04 <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0204af0:	4681                	li	a3,0
ffffffffc0204af2:	8622                	mv	a2,s0
ffffffffc0204af4:	85a6                	mv	a1,s1
ffffffffc0204af6:	cd1fd0ef          	jal	ra,ffffffffc02027c6 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0204afa:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0204afc:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0204afe:	4785                	li	a5,1
ffffffffc0204b00:	04f71663          	bne	a4,a5,ffffffffc0204b4c <pgdir_alloc_page+0x9a>
}
ffffffffc0204b04:	70a2                	ld	ra,40(sp)
ffffffffc0204b06:	8522                	mv	a0,s0
ffffffffc0204b08:	7402                	ld	s0,32(sp)
ffffffffc0204b0a:	64e2                	ld	s1,24(sp)
ffffffffc0204b0c:	6942                	ld	s2,16(sp)
ffffffffc0204b0e:	69a2                	ld	s3,8(sp)
ffffffffc0204b10:	6145                	addi	sp,sp,48
ffffffffc0204b12:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204b14:	100027f3          	csrr	a5,sstatus
ffffffffc0204b18:	8b89                	andi	a5,a5,2
ffffffffc0204b1a:	eb99                	bnez	a5,ffffffffc0204b30 <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc0204b1c:	000ae797          	auipc	a5,0xae
ffffffffc0204b20:	d147b783          	ld	a5,-748(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0204b24:	739c                	ld	a5,32(a5)
ffffffffc0204b26:	8522                	mv	a0,s0
ffffffffc0204b28:	4585                	li	a1,1
ffffffffc0204b2a:	9782                	jalr	a5
            return NULL;
ffffffffc0204b2c:	4401                	li	s0,0
ffffffffc0204b2e:	bfd9                	j	ffffffffc0204b04 <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc0204b30:	b19fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0204b34:	000ae797          	auipc	a5,0xae
ffffffffc0204b38:	cfc7b783          	ld	a5,-772(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0204b3c:	739c                	ld	a5,32(a5)
ffffffffc0204b3e:	8522                	mv	a0,s0
ffffffffc0204b40:	4585                	li	a1,1
ffffffffc0204b42:	9782                	jalr	a5
            return NULL;
ffffffffc0204b44:	4401                	li	s0,0
        intr_enable();
ffffffffc0204b46:	afdfb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204b4a:	bf6d                	j	ffffffffc0204b04 <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc0204b4c:	00003697          	auipc	a3,0x3
ffffffffc0204b50:	7c468693          	addi	a3,a3,1988 # ffffffffc0208310 <default_pmm_manager+0x5e8>
ffffffffc0204b54:	00002617          	auipc	a2,0x2
ffffffffc0204b58:	12c60613          	addi	a2,a2,300 # ffffffffc0206c80 <commands+0x410>
ffffffffc0204b5c:	1d600593          	li	a1,470
ffffffffc0204b60:	00003517          	auipc	a0,0x3
ffffffffc0204b64:	20050513          	addi	a0,a0,512 # ffffffffc0207d60 <default_pmm_manager+0x38>
ffffffffc0204b68:	ea0fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204b6c <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204b6c:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b6e:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b70:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b72:	9b7fb0ef          	jal	ra,ffffffffc0200528 <ide_device_valid>
ffffffffc0204b76:	cd01                	beqz	a0,ffffffffc0204b8e <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b78:	4505                	li	a0,1
ffffffffc0204b7a:	9b5fb0ef          	jal	ra,ffffffffc020052e <ide_device_size>
}
ffffffffc0204b7e:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b80:	810d                	srli	a0,a0,0x3
ffffffffc0204b82:	000ae797          	auipc	a5,0xae
ffffffffc0204b86:	c6a7bb23          	sd	a0,-906(a5) # ffffffffc02b27f8 <max_swap_offset>
}
ffffffffc0204b8a:	0141                	addi	sp,sp,16
ffffffffc0204b8c:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204b8e:	00003617          	auipc	a2,0x3
ffffffffc0204b92:	79a60613          	addi	a2,a2,1946 # ffffffffc0208328 <default_pmm_manager+0x600>
ffffffffc0204b96:	45b5                	li	a1,13
ffffffffc0204b98:	00003517          	auipc	a0,0x3
ffffffffc0204b9c:	7b050513          	addi	a0,a0,1968 # ffffffffc0208348 <default_pmm_manager+0x620>
ffffffffc0204ba0:	e68fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204ba4 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204ba4:	1141                	addi	sp,sp,-16
ffffffffc0204ba6:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204ba8:	00855793          	srli	a5,a0,0x8
ffffffffc0204bac:	cbb1                	beqz	a5,ffffffffc0204c00 <swapfs_read+0x5c>
ffffffffc0204bae:	000ae717          	auipc	a4,0xae
ffffffffc0204bb2:	c4a73703          	ld	a4,-950(a4) # ffffffffc02b27f8 <max_swap_offset>
ffffffffc0204bb6:	04e7f563          	bgeu	a5,a4,ffffffffc0204c00 <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204bba:	000ae617          	auipc	a2,0xae
ffffffffc0204bbe:	c6e63603          	ld	a2,-914(a2) # ffffffffc02b2828 <pages>
ffffffffc0204bc2:	8d91                	sub	a1,a1,a2
ffffffffc0204bc4:	4065d613          	srai	a2,a1,0x6
ffffffffc0204bc8:	00004717          	auipc	a4,0x4
ffffffffc0204bcc:	0d873703          	ld	a4,216(a4) # ffffffffc0208ca0 <nbase>
ffffffffc0204bd0:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204bd2:	00c61713          	slli	a4,a2,0xc
ffffffffc0204bd6:	8331                	srli	a4,a4,0xc
ffffffffc0204bd8:	000ae697          	auipc	a3,0xae
ffffffffc0204bdc:	c486b683          	ld	a3,-952(a3) # ffffffffc02b2820 <npage>
ffffffffc0204be0:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204be4:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204be6:	02d77963          	bgeu	a4,a3,ffffffffc0204c18 <swapfs_read+0x74>
}
ffffffffc0204bea:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bec:	000ae797          	auipc	a5,0xae
ffffffffc0204bf0:	c4c7b783          	ld	a5,-948(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0204bf4:	46a1                	li	a3,8
ffffffffc0204bf6:	963e                	add	a2,a2,a5
ffffffffc0204bf8:	4505                	li	a0,1
}
ffffffffc0204bfa:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bfc:	939fb06f          	j	ffffffffc0200534 <ide_read_secs>
ffffffffc0204c00:	86aa                	mv	a3,a0
ffffffffc0204c02:	00003617          	auipc	a2,0x3
ffffffffc0204c06:	75e60613          	addi	a2,a2,1886 # ffffffffc0208360 <default_pmm_manager+0x638>
ffffffffc0204c0a:	45d1                	li	a1,20
ffffffffc0204c0c:	00003517          	auipc	a0,0x3
ffffffffc0204c10:	73c50513          	addi	a0,a0,1852 # ffffffffc0208348 <default_pmm_manager+0x620>
ffffffffc0204c14:	df4fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204c18:	86b2                	mv	a3,a2
ffffffffc0204c1a:	06900593          	li	a1,105
ffffffffc0204c1e:	00002617          	auipc	a2,0x2
ffffffffc0204c22:	63260613          	addi	a2,a2,1586 # ffffffffc0207250 <commands+0x9e0>
ffffffffc0204c26:	00002517          	auipc	a0,0x2
ffffffffc0204c2a:	61a50513          	addi	a0,a0,1562 # ffffffffc0207240 <commands+0x9d0>
ffffffffc0204c2e:	ddafb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204c32 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204c32:	1141                	addi	sp,sp,-16
ffffffffc0204c34:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c36:	00855793          	srli	a5,a0,0x8
ffffffffc0204c3a:	cbb1                	beqz	a5,ffffffffc0204c8e <swapfs_write+0x5c>
ffffffffc0204c3c:	000ae717          	auipc	a4,0xae
ffffffffc0204c40:	bbc73703          	ld	a4,-1092(a4) # ffffffffc02b27f8 <max_swap_offset>
ffffffffc0204c44:	04e7f563          	bgeu	a5,a4,ffffffffc0204c8e <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204c48:	000ae617          	auipc	a2,0xae
ffffffffc0204c4c:	be063603          	ld	a2,-1056(a2) # ffffffffc02b2828 <pages>
ffffffffc0204c50:	8d91                	sub	a1,a1,a2
ffffffffc0204c52:	4065d613          	srai	a2,a1,0x6
ffffffffc0204c56:	00004717          	auipc	a4,0x4
ffffffffc0204c5a:	04a73703          	ld	a4,74(a4) # ffffffffc0208ca0 <nbase>
ffffffffc0204c5e:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204c60:	00c61713          	slli	a4,a2,0xc
ffffffffc0204c64:	8331                	srli	a4,a4,0xc
ffffffffc0204c66:	000ae697          	auipc	a3,0xae
ffffffffc0204c6a:	bba6b683          	ld	a3,-1094(a3) # ffffffffc02b2820 <npage>
ffffffffc0204c6e:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c72:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c74:	02d77963          	bgeu	a4,a3,ffffffffc0204ca6 <swapfs_write+0x74>
}
ffffffffc0204c78:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c7a:	000ae797          	auipc	a5,0xae
ffffffffc0204c7e:	bbe7b783          	ld	a5,-1090(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0204c82:	46a1                	li	a3,8
ffffffffc0204c84:	963e                	add	a2,a2,a5
ffffffffc0204c86:	4505                	li	a0,1
}
ffffffffc0204c88:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c8a:	8cffb06f          	j	ffffffffc0200558 <ide_write_secs>
ffffffffc0204c8e:	86aa                	mv	a3,a0
ffffffffc0204c90:	00003617          	auipc	a2,0x3
ffffffffc0204c94:	6d060613          	addi	a2,a2,1744 # ffffffffc0208360 <default_pmm_manager+0x638>
ffffffffc0204c98:	45e5                	li	a1,25
ffffffffc0204c9a:	00003517          	auipc	a0,0x3
ffffffffc0204c9e:	6ae50513          	addi	a0,a0,1710 # ffffffffc0208348 <default_pmm_manager+0x620>
ffffffffc0204ca2:	d66fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204ca6:	86b2                	mv	a3,a2
ffffffffc0204ca8:	06900593          	li	a1,105
ffffffffc0204cac:	00002617          	auipc	a2,0x2
ffffffffc0204cb0:	5a460613          	addi	a2,a2,1444 # ffffffffc0207250 <commands+0x9e0>
ffffffffc0204cb4:	00002517          	auipc	a0,0x2
ffffffffc0204cb8:	58c50513          	addi	a0,a0,1420 # ffffffffc0207240 <commands+0x9d0>
ffffffffc0204cbc:	d4cfb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204cc0 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204cc0:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204cc4:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204cc8:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204cca:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204ccc:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204cd0:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204cd4:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204cd8:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204cdc:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204ce0:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204ce4:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204ce8:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204cec:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204cf0:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204cf4:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204cf8:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204cfc:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204cfe:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204d00:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204d04:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204d08:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204d0c:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204d10:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204d14:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204d18:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204d1c:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204d20:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204d24:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204d28:	8082                	ret

ffffffffc0204d2a <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204d2a:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204d2c:	9402                	jalr	s0

	jal do_exit
ffffffffc0204d2e:	638000ef          	jal	ra,ffffffffc0205366 <do_exit>

ffffffffc0204d32 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204d32:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d34:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204d38:	e022                	sd	s0,0(sp)
ffffffffc0204d3a:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d3c:	976fd0ef          	jal	ra,ffffffffc0201eb2 <kmalloc>
ffffffffc0204d40:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204d42:	cd21                	beqz	a0,ffffffffc0204d9a <alloc_proc+0x68>
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     * proc_struct中的以下字段（在LAB5中的添加）需要初始化
     *       uint32_t wait_state;                        // 等待状态
     *       struct proc_struct *cptr, *yptr, *optr;     // 进程之间的关系
     */
        proc->state        = PROC_UNINIT;
ffffffffc0204d44:	57fd                	li	a5,-1
ffffffffc0204d46:	1782                	slli	a5,a5,0x20
ffffffffc0204d48:	e11c                	sd	a5,0(a0)
        proc->runs         = 0; 
        proc->kstack       = 0;    
        proc->need_resched = 0;
        proc->parent       = NULL;
        proc->mm           = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204d4a:	07000613          	li	a2,112
ffffffffc0204d4e:	4581                	li	a1,0
        proc->runs         = 0; 
ffffffffc0204d50:	00052423          	sw	zero,8(a0)
        proc->kstack       = 0;    
ffffffffc0204d54:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204d58:	00053c23          	sd	zero,24(a0)
        proc->parent       = NULL;
ffffffffc0204d5c:	02053023          	sd	zero,32(a0)
        proc->mm           = NULL;
ffffffffc0204d60:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204d64:	03050513          	addi	a0,a0,48
ffffffffc0204d68:	432010ef          	jal	ra,ffffffffc020619a <memset>
        proc->tf           = NULL;
        proc->cr3          = boot_cr3;
ffffffffc0204d6c:	000ae797          	auipc	a5,0xae
ffffffffc0204d70:	aa47b783          	ld	a5,-1372(a5) # ffffffffc02b2810 <boot_cr3>
        proc->tf           = NULL;
ffffffffc0204d74:	0a043023          	sd	zero,160(s0)
        proc->cr3          = boot_cr3;
ffffffffc0204d78:	f45c                	sd	a5,168(s0)
        proc->flags        = 0;
ffffffffc0204d7a:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, PROC_NAME_LEN+1);
ffffffffc0204d7e:	4641                	li	a2,16
ffffffffc0204d80:	4581                	li	a1,0
ffffffffc0204d82:	0b440513          	addi	a0,s0,180
ffffffffc0204d86:	414010ef          	jal	ra,ffffffffc020619a <memset>

        proc->wait_state   = 0;
ffffffffc0204d8a:	0e042623          	sw	zero,236(s0)
        proc->cptr         = NULL;
ffffffffc0204d8e:	0e043823          	sd	zero,240(s0)
        proc->yptr         = NULL;
ffffffffc0204d92:	0e043c23          	sd	zero,248(s0)
        proc->optr         = NULL;
ffffffffc0204d96:	10043023          	sd	zero,256(s0)
    }
    return proc;
}
ffffffffc0204d9a:	60a2                	ld	ra,8(sp)
ffffffffc0204d9c:	8522                	mv	a0,s0
ffffffffc0204d9e:	6402                	ld	s0,0(sp)
ffffffffc0204da0:	0141                	addi	sp,sp,16
ffffffffc0204da2:	8082                	ret

ffffffffc0204da4 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204da4:	000ae797          	auipc	a5,0xae
ffffffffc0204da8:	a9c7b783          	ld	a5,-1380(a5) # ffffffffc02b2840 <current>
ffffffffc0204dac:	73c8                	ld	a0,160(a5)
ffffffffc0204dae:	fc9fb06f          	j	ffffffffc0200d76 <forkrets>

ffffffffc0204db2 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204db2:	000ae797          	auipc	a5,0xae
ffffffffc0204db6:	a8e7b783          	ld	a5,-1394(a5) # ffffffffc02b2840 <current>
ffffffffc0204dba:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204dbc:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204dbe:	00003617          	auipc	a2,0x3
ffffffffc0204dc2:	5c260613          	addi	a2,a2,1474 # ffffffffc0208380 <default_pmm_manager+0x658>
ffffffffc0204dc6:	00003517          	auipc	a0,0x3
ffffffffc0204dca:	5ca50513          	addi	a0,a0,1482 # ffffffffc0208390 <default_pmm_manager+0x668>
user_main(void *arg) {
ffffffffc0204dce:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204dd0:	afcfb0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0204dd4:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204dd8:	b9478793          	addi	a5,a5,-1132 # a968 <_binary_obj___user_forktest_out_size>
ffffffffc0204ddc:	e43e                	sd	a5,8(sp)
ffffffffc0204dde:	00003517          	auipc	a0,0x3
ffffffffc0204de2:	5a250513          	addi	a0,a0,1442 # ffffffffc0208380 <default_pmm_manager+0x658>
ffffffffc0204de6:	0008e797          	auipc	a5,0x8e
ffffffffc0204dea:	db278793          	addi	a5,a5,-590 # ffffffffc0292b98 <_binary_obj___user_forktest_out_start>
ffffffffc0204dee:	f03e                	sd	a5,32(sp)
ffffffffc0204df0:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204df2:	e802                	sd	zero,16(sp)
ffffffffc0204df4:	32a010ef          	jal	ra,ffffffffc020611e <strlen>
ffffffffc0204df8:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204dfa:	4511                	li	a0,4
ffffffffc0204dfc:	55a2                	lw	a1,40(sp)
ffffffffc0204dfe:	4662                	lw	a2,24(sp)
ffffffffc0204e00:	5682                	lw	a3,32(sp)
ffffffffc0204e02:	4722                	lw	a4,8(sp)
ffffffffc0204e04:	48a9                	li	a7,10
ffffffffc0204e06:	9002                	ebreak
ffffffffc0204e08:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204e0a:	65c2                	ld	a1,16(sp)
ffffffffc0204e0c:	00003517          	auipc	a0,0x3
ffffffffc0204e10:	5ac50513          	addi	a0,a0,1452 # ffffffffc02083b8 <default_pmm_manager+0x690>
ffffffffc0204e14:	ab8fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204e18:	00003617          	auipc	a2,0x3
ffffffffc0204e1c:	5b060613          	addi	a2,a2,1456 # ffffffffc02083c8 <default_pmm_manager+0x6a0>
ffffffffc0204e20:	35600593          	li	a1,854
ffffffffc0204e24:	00003517          	auipc	a0,0x3
ffffffffc0204e28:	5c450513          	addi	a0,a0,1476 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0204e2c:	bdcfb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204e30 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204e30:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204e32:	1141                	addi	sp,sp,-16
ffffffffc0204e34:	e406                	sd	ra,8(sp)
ffffffffc0204e36:	c02007b7          	lui	a5,0xc0200
ffffffffc0204e3a:	02f6ee63          	bltu	a3,a5,ffffffffc0204e76 <put_pgdir+0x46>
ffffffffc0204e3e:	000ae517          	auipc	a0,0xae
ffffffffc0204e42:	9fa53503          	ld	a0,-1542(a0) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0204e46:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204e48:	82b1                	srli	a3,a3,0xc
ffffffffc0204e4a:	000ae797          	auipc	a5,0xae
ffffffffc0204e4e:	9d67b783          	ld	a5,-1578(a5) # ffffffffc02b2820 <npage>
ffffffffc0204e52:	02f6fe63          	bgeu	a3,a5,ffffffffc0204e8e <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204e56:	00004517          	auipc	a0,0x4
ffffffffc0204e5a:	e4a53503          	ld	a0,-438(a0) # ffffffffc0208ca0 <nbase>
}
ffffffffc0204e5e:	60a2                	ld	ra,8(sp)
ffffffffc0204e60:	8e89                	sub	a3,a3,a0
ffffffffc0204e62:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204e64:	000ae517          	auipc	a0,0xae
ffffffffc0204e68:	9c453503          	ld	a0,-1596(a0) # ffffffffc02b2828 <pages>
ffffffffc0204e6c:	4585                	li	a1,1
ffffffffc0204e6e:	9536                	add	a0,a0,a3
}
ffffffffc0204e70:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204e72:	e66fe06f          	j	ffffffffc02034d8 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204e76:	00002617          	auipc	a2,0x2
ffffffffc0204e7a:	76260613          	addi	a2,a2,1890 # ffffffffc02075d8 <commands+0xd68>
ffffffffc0204e7e:	06e00593          	li	a1,110
ffffffffc0204e82:	00002517          	auipc	a0,0x2
ffffffffc0204e86:	3be50513          	addi	a0,a0,958 # ffffffffc0207240 <commands+0x9d0>
ffffffffc0204e8a:	b7efb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204e8e:	00002617          	auipc	a2,0x2
ffffffffc0204e92:	39260613          	addi	a2,a2,914 # ffffffffc0207220 <commands+0x9b0>
ffffffffc0204e96:	06200593          	li	a1,98
ffffffffc0204e9a:	00002517          	auipc	a0,0x2
ffffffffc0204e9e:	3a650513          	addi	a0,a0,934 # ffffffffc0207240 <commands+0x9d0>
ffffffffc0204ea2:	b66fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204ea6 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204ea6:	7179                	addi	sp,sp,-48
ffffffffc0204ea8:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204eaa:	000ae917          	auipc	s2,0xae
ffffffffc0204eae:	99690913          	addi	s2,s2,-1642 # ffffffffc02b2840 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204eb2:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204eb4:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204eb8:	f406                	sd	ra,40(sp)
ffffffffc0204eba:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc0204ebc:	02a48863          	beq	s1,a0,ffffffffc0204eec <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204ec0:	100027f3          	csrr	a5,sstatus
ffffffffc0204ec4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204ec6:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204ec8:	ef9d                	bnez	a5,ffffffffc0204f06 <proc_run+0x60>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204eca:	755c                	ld	a5,168(a0)
ffffffffc0204ecc:	577d                	li	a4,-1
ffffffffc0204ece:	177e                	slli	a4,a4,0x3f
ffffffffc0204ed0:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0204ed2:	00a93023          	sd	a0,0(s2)
ffffffffc0204ed6:	8fd9                	or	a5,a5,a4
ffffffffc0204ed8:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc0204edc:	03050593          	addi	a1,a0,48
ffffffffc0204ee0:	03048513          	addi	a0,s1,48
ffffffffc0204ee4:	dddff0ef          	jal	ra,ffffffffc0204cc0 <switch_to>
    if (flag) {
ffffffffc0204ee8:	00099863          	bnez	s3,ffffffffc0204ef8 <proc_run+0x52>
}
ffffffffc0204eec:	70a2                	ld	ra,40(sp)
ffffffffc0204eee:	7482                	ld	s1,32(sp)
ffffffffc0204ef0:	6962                	ld	s2,24(sp)
ffffffffc0204ef2:	69c2                	ld	s3,16(sp)
ffffffffc0204ef4:	6145                	addi	sp,sp,48
ffffffffc0204ef6:	8082                	ret
ffffffffc0204ef8:	70a2                	ld	ra,40(sp)
ffffffffc0204efa:	7482                	ld	s1,32(sp)
ffffffffc0204efc:	6962                	ld	s2,24(sp)
ffffffffc0204efe:	69c2                	ld	s3,16(sp)
ffffffffc0204f00:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204f02:	f40fb06f          	j	ffffffffc0200642 <intr_enable>
ffffffffc0204f06:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204f08:	f40fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0204f0c:	6522                	ld	a0,8(sp)
ffffffffc0204f0e:	4985                	li	s3,1
ffffffffc0204f10:	bf6d                	j	ffffffffc0204eca <proc_run+0x24>

ffffffffc0204f12 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204f12:	7119                	addi	sp,sp,-128
ffffffffc0204f14:	f0ca                	sd	s2,96(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204f16:	000ae917          	auipc	s2,0xae
ffffffffc0204f1a:	94290913          	addi	s2,s2,-1726 # ffffffffc02b2858 <nr_process>
ffffffffc0204f1e:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204f22:	fc86                	sd	ra,120(sp)
ffffffffc0204f24:	f8a2                	sd	s0,112(sp)
ffffffffc0204f26:	f4a6                	sd	s1,104(sp)
ffffffffc0204f28:	ecce                	sd	s3,88(sp)
ffffffffc0204f2a:	e8d2                	sd	s4,80(sp)
ffffffffc0204f2c:	e4d6                	sd	s5,72(sp)
ffffffffc0204f2e:	e0da                	sd	s6,64(sp)
ffffffffc0204f30:	fc5e                	sd	s7,56(sp)
ffffffffc0204f32:	f862                	sd	s8,48(sp)
ffffffffc0204f34:	f466                	sd	s9,40(sp)
ffffffffc0204f36:	f06a                	sd	s10,32(sp)
ffffffffc0204f38:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204f3a:	6785                	lui	a5,0x1
ffffffffc0204f3c:	32f75b63          	bge	a4,a5,ffffffffc0205272 <do_fork+0x360>
ffffffffc0204f40:	8a2a                	mv	s4,a0
ffffffffc0204f42:	89ae                	mv	s3,a1
ffffffffc0204f44:	8432                	mv	s0,a2
    if((proc = alloc_proc()) == NULL) goto fork_out;
ffffffffc0204f46:	dedff0ef          	jal	ra,ffffffffc0204d32 <alloc_proc>
ffffffffc0204f4a:	84aa                	mv	s1,a0
ffffffffc0204f4c:	30050463          	beqz	a0,ffffffffc0205254 <do_fork+0x342>
    proc->parent = current;
ffffffffc0204f50:	000aec17          	auipc	s8,0xae
ffffffffc0204f54:	8f0c0c13          	addi	s8,s8,-1808 # ffffffffc02b2840 <current>
ffffffffc0204f58:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0); // 更新步骤1：将子进程的父进程设置为当前进程，确保当前进程的wait_state为0
ffffffffc0204f5c:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8ac4>
    proc->parent = current;
ffffffffc0204f60:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0); // 更新步骤1：将子进程的父进程设置为当前进程，确保当前进程的wait_state为0
ffffffffc0204f62:	30071d63          	bnez	a4,ffffffffc020527c <do_fork+0x36a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204f66:	4509                	li	a0,2
ffffffffc0204f68:	cdefe0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
    if (page != NULL) {
ffffffffc0204f6c:	2e050163          	beqz	a0,ffffffffc020524e <do_fork+0x33c>
    return page - pages + nbase;
ffffffffc0204f70:	000aea97          	auipc	s5,0xae
ffffffffc0204f74:	8b8a8a93          	addi	s5,s5,-1864 # ffffffffc02b2828 <pages>
ffffffffc0204f78:	000ab683          	ld	a3,0(s5)
ffffffffc0204f7c:	00004b17          	auipc	s6,0x4
ffffffffc0204f80:	d24b0b13          	addi	s6,s6,-732 # ffffffffc0208ca0 <nbase>
ffffffffc0204f84:	000b3783          	ld	a5,0(s6)
ffffffffc0204f88:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204f8c:	000aeb97          	auipc	s7,0xae
ffffffffc0204f90:	894b8b93          	addi	s7,s7,-1900 # ffffffffc02b2820 <npage>
    return page - pages + nbase;
ffffffffc0204f94:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204f96:	5dfd                	li	s11,-1
ffffffffc0204f98:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc0204f9c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204f9e:	00cddd93          	srli	s11,s11,0xc
ffffffffc0204fa2:	01b6f633          	and	a2,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc0204fa6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204fa8:	2ee67a63          	bgeu	a2,a4,ffffffffc020529c <do_fork+0x38a>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204fac:	000c3603          	ld	a2,0(s8)
ffffffffc0204fb0:	000aec17          	auipc	s8,0xae
ffffffffc0204fb4:	888c0c13          	addi	s8,s8,-1912 # ffffffffc02b2838 <va_pa_offset>
ffffffffc0204fb8:	000c3703          	ld	a4,0(s8)
ffffffffc0204fbc:	02863d03          	ld	s10,40(a2)
ffffffffc0204fc0:	e43e                	sd	a5,8(sp)
ffffffffc0204fc2:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204fc4:	e894                	sd	a3,16(s1)
    if (oldmm == NULL) {
ffffffffc0204fc6:	020d0863          	beqz	s10,ffffffffc0204ff6 <do_fork+0xe4>
    if (clone_flags & CLONE_VM) {
ffffffffc0204fca:	100a7a13          	andi	s4,s4,256
ffffffffc0204fce:	1c0a0163          	beqz	s4,ffffffffc0205190 <do_fork+0x27e>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0204fd2:	030d2703          	lw	a4,48(s10)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204fd6:	018d3783          	ld	a5,24(s10)
ffffffffc0204fda:	c02006b7          	lui	a3,0xc0200
ffffffffc0204fde:	2705                	addiw	a4,a4,1
ffffffffc0204fe0:	02ed2823          	sw	a4,48(s10)
    proc->mm = mm;
ffffffffc0204fe4:	03a4b423          	sd	s10,40(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204fe8:	2ed7e263          	bltu	a5,a3,ffffffffc02052cc <do_fork+0x3ba>
ffffffffc0204fec:	000c3703          	ld	a4,0(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204ff0:	6894                	ld	a3,16(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204ff2:	8f99                	sub	a5,a5,a4
ffffffffc0204ff4:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204ff6:	6789                	lui	a5,0x2
ffffffffc0204ff8:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd0>
ffffffffc0204ffc:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204ffe:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205000:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc0205002:	87b6                	mv	a5,a3
ffffffffc0205004:	12040893          	addi	a7,s0,288
ffffffffc0205008:	00063803          	ld	a6,0(a2)
ffffffffc020500c:	6608                	ld	a0,8(a2)
ffffffffc020500e:	6a0c                	ld	a1,16(a2)
ffffffffc0205010:	6e18                	ld	a4,24(a2)
ffffffffc0205012:	0107b023          	sd	a6,0(a5)
ffffffffc0205016:	e788                	sd	a0,8(a5)
ffffffffc0205018:	eb8c                	sd	a1,16(a5)
ffffffffc020501a:	ef98                	sd	a4,24(a5)
ffffffffc020501c:	02060613          	addi	a2,a2,32
ffffffffc0205020:	02078793          	addi	a5,a5,32
ffffffffc0205024:	ff1612e3          	bne	a2,a7,ffffffffc0205008 <do_fork+0xf6>
    proc->tf->gpr.a0 = 0;
ffffffffc0205028:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020502c:	12098f63          	beqz	s3,ffffffffc020516a <do_fork+0x258>
ffffffffc0205030:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205034:	00000797          	auipc	a5,0x0
ffffffffc0205038:	d7078793          	addi	a5,a5,-656 # ffffffffc0204da4 <forkret>
ffffffffc020503c:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020503e:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205040:	100027f3          	csrr	a5,sstatus
ffffffffc0205044:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205046:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205048:	14079063          	bnez	a5,ffffffffc0205188 <do_fork+0x276>
    if (++ last_pid >= MAX_PID) {
ffffffffc020504c:	000a2817          	auipc	a6,0xa2
ffffffffc0205050:	2ac80813          	addi	a6,a6,684 # ffffffffc02a72f8 <last_pid.1>
ffffffffc0205054:	00082783          	lw	a5,0(a6)
ffffffffc0205058:	6709                	lui	a4,0x2
ffffffffc020505a:	0017851b          	addiw	a0,a5,1
ffffffffc020505e:	00a82023          	sw	a0,0(a6)
ffffffffc0205062:	08e55d63          	bge	a0,a4,ffffffffc02050fc <do_fork+0x1ea>
    if (last_pid >= next_safe) {
ffffffffc0205066:	000a2317          	auipc	t1,0xa2
ffffffffc020506a:	29630313          	addi	t1,t1,662 # ffffffffc02a72fc <next_safe.0>
ffffffffc020506e:	00032783          	lw	a5,0(t1)
ffffffffc0205072:	000ad417          	auipc	s0,0xad
ffffffffc0205076:	74640413          	addi	s0,s0,1862 # ffffffffc02b27b8 <proc_list>
ffffffffc020507a:	08f55963          	bge	a0,a5,ffffffffc020510c <do_fork+0x1fa>
        proc->pid = get_pid();
ffffffffc020507e:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205080:	45a9                	li	a1,10
ffffffffc0205082:	2501                	sext.w	a0,a0
ffffffffc0205084:	52e010ef          	jal	ra,ffffffffc02065b2 <hash32>
ffffffffc0205088:	02051793          	slli	a5,a0,0x20
ffffffffc020508c:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205090:	000a9797          	auipc	a5,0xa9
ffffffffc0205094:	72878793          	addi	a5,a5,1832 # ffffffffc02ae7b8 <hash_list>
ffffffffc0205098:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020509a:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020509c:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020509e:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc02050a2:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02050a4:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc02050a6:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02050a8:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02050aa:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc02050ae:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc02050b0:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc02050b2:	e21c                	sd	a5,0(a2)
ffffffffc02050b4:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc02050b6:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc02050b8:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc02050ba:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02050be:	10e4b023          	sd	a4,256(s1)
ffffffffc02050c2:	c311                	beqz	a4,ffffffffc02050c6 <do_fork+0x1b4>
        proc->optr->yptr = proc;
ffffffffc02050c4:	ff64                	sd	s1,248(a4)
    nr_process ++;
ffffffffc02050c6:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc02050ca:	fae4                	sd	s1,240(a3)
    nr_process ++;
ffffffffc02050cc:	2785                	addiw	a5,a5,1
ffffffffc02050ce:	00f92023          	sw	a5,0(s2)
    if (flag) {
ffffffffc02050d2:	18099363          	bnez	s3,ffffffffc0205258 <do_fork+0x346>
    wakeup_proc(proc);
ffffffffc02050d6:	8526                	mv	a0,s1
ffffffffc02050d8:	65b000ef          	jal	ra,ffffffffc0205f32 <wakeup_proc>
    ret = proc->pid;
ffffffffc02050dc:	40c8                	lw	a0,4(s1)
}
ffffffffc02050de:	70e6                	ld	ra,120(sp)
ffffffffc02050e0:	7446                	ld	s0,112(sp)
ffffffffc02050e2:	74a6                	ld	s1,104(sp)
ffffffffc02050e4:	7906                	ld	s2,96(sp)
ffffffffc02050e6:	69e6                	ld	s3,88(sp)
ffffffffc02050e8:	6a46                	ld	s4,80(sp)
ffffffffc02050ea:	6aa6                	ld	s5,72(sp)
ffffffffc02050ec:	6b06                	ld	s6,64(sp)
ffffffffc02050ee:	7be2                	ld	s7,56(sp)
ffffffffc02050f0:	7c42                	ld	s8,48(sp)
ffffffffc02050f2:	7ca2                	ld	s9,40(sp)
ffffffffc02050f4:	7d02                	ld	s10,32(sp)
ffffffffc02050f6:	6de2                	ld	s11,24(sp)
ffffffffc02050f8:	6109                	addi	sp,sp,128
ffffffffc02050fa:	8082                	ret
        last_pid = 1;
ffffffffc02050fc:	4785                	li	a5,1
ffffffffc02050fe:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0205102:	4505                	li	a0,1
ffffffffc0205104:	000a2317          	auipc	t1,0xa2
ffffffffc0205108:	1f830313          	addi	t1,t1,504 # ffffffffc02a72fc <next_safe.0>
    return listelm->next;
ffffffffc020510c:	000ad417          	auipc	s0,0xad
ffffffffc0205110:	6ac40413          	addi	s0,s0,1708 # ffffffffc02b27b8 <proc_list>
ffffffffc0205114:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc0205118:	6789                	lui	a5,0x2
ffffffffc020511a:	00f32023          	sw	a5,0(t1)
ffffffffc020511e:	86aa                	mv	a3,a0
ffffffffc0205120:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc0205122:	6e89                	lui	t4,0x2
ffffffffc0205124:	148e0263          	beq	t3,s0,ffffffffc0205268 <do_fork+0x356>
ffffffffc0205128:	88ae                	mv	a7,a1
ffffffffc020512a:	87f2                	mv	a5,t3
ffffffffc020512c:	6609                	lui	a2,0x2
ffffffffc020512e:	a811                	j	ffffffffc0205142 <do_fork+0x230>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205130:	00e6d663          	bge	a3,a4,ffffffffc020513c <do_fork+0x22a>
ffffffffc0205134:	00c75463          	bge	a4,a2,ffffffffc020513c <do_fork+0x22a>
ffffffffc0205138:	863a                	mv	a2,a4
ffffffffc020513a:	4885                	li	a7,1
ffffffffc020513c:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020513e:	00878d63          	beq	a5,s0,ffffffffc0205158 <do_fork+0x246>
            if (proc->pid == last_pid) {
ffffffffc0205142:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c74>
ffffffffc0205146:	fed715e3          	bne	a4,a3,ffffffffc0205130 <do_fork+0x21e>
                if (++ last_pid >= next_safe) {
ffffffffc020514a:	2685                	addiw	a3,a3,1
ffffffffc020514c:	10c6d963          	bge	a3,a2,ffffffffc020525e <do_fork+0x34c>
ffffffffc0205150:	679c                	ld	a5,8(a5)
ffffffffc0205152:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc0205154:	fe8797e3          	bne	a5,s0,ffffffffc0205142 <do_fork+0x230>
ffffffffc0205158:	c581                	beqz	a1,ffffffffc0205160 <do_fork+0x24e>
ffffffffc020515a:	00d82023          	sw	a3,0(a6)
ffffffffc020515e:	8536                	mv	a0,a3
ffffffffc0205160:	f0088fe3          	beqz	a7,ffffffffc020507e <do_fork+0x16c>
ffffffffc0205164:	00c32023          	sw	a2,0(t1)
ffffffffc0205168:	bf19                	j	ffffffffc020507e <do_fork+0x16c>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020516a:	89b6                	mv	s3,a3
ffffffffc020516c:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205170:	00000797          	auipc	a5,0x0
ffffffffc0205174:	c3478793          	addi	a5,a5,-972 # ffffffffc0204da4 <forkret>
ffffffffc0205178:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020517a:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020517c:	100027f3          	csrr	a5,sstatus
ffffffffc0205180:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205182:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205184:	ec0784e3          	beqz	a5,ffffffffc020504c <do_fork+0x13a>
        intr_disable();
ffffffffc0205188:	cc0fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc020518c:	4985                	li	s3,1
ffffffffc020518e:	bd7d                	j	ffffffffc020504c <do_fork+0x13a>
    if ((mm = mm_create()) == NULL) {
ffffffffc0205190:	cb7fb0ef          	jal	ra,ffffffffc0200e46 <mm_create>
ffffffffc0205194:	8caa                	mv	s9,a0
ffffffffc0205196:	c541                	beqz	a0,ffffffffc020521e <do_fork+0x30c>
    if ((page = alloc_page()) == NULL) {
ffffffffc0205198:	4505                	li	a0,1
ffffffffc020519a:	aacfe0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc020519e:	cd2d                	beqz	a0,ffffffffc0205218 <do_fork+0x306>
    return page - pages + nbase;
ffffffffc02051a0:	000ab683          	ld	a3,0(s5)
ffffffffc02051a4:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc02051a6:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc02051aa:	40d506b3          	sub	a3,a0,a3
ffffffffc02051ae:	8699                	srai	a3,a3,0x6
ffffffffc02051b0:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02051b2:	01b6fdb3          	and	s11,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc02051b6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02051b8:	0eedf263          	bgeu	s11,a4,ffffffffc020529c <do_fork+0x38a>
ffffffffc02051bc:	000c3a03          	ld	s4,0(s8)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc02051c0:	6605                	lui	a2,0x1
ffffffffc02051c2:	000ad597          	auipc	a1,0xad
ffffffffc02051c6:	6565b583          	ld	a1,1622(a1) # ffffffffc02b2818 <boot_pgdir>
ffffffffc02051ca:	9a36                	add	s4,s4,a3
ffffffffc02051cc:	8552                	mv	a0,s4
ffffffffc02051ce:	7df000ef          	jal	ra,ffffffffc02061ac <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc02051d2:	038d0d93          	addi	s11,s10,56
    mm->pgdir = pgdir;
ffffffffc02051d6:	014cbc23          	sd	s4,24(s9)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02051da:	4785                	li	a5,1
ffffffffc02051dc:	40fdb7af          	amoor.d	a5,a5,(s11)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc02051e0:	8b85                	andi	a5,a5,1
ffffffffc02051e2:	4a05                	li	s4,1
ffffffffc02051e4:	c799                	beqz	a5,ffffffffc02051f2 <do_fork+0x2e0>
        schedule();
ffffffffc02051e6:	5cd000ef          	jal	ra,ffffffffc0205fb2 <schedule>
ffffffffc02051ea:	414db7af          	amoor.d	a5,s4,(s11)
    while (!try_lock(lock)) {
ffffffffc02051ee:	8b85                	andi	a5,a5,1
ffffffffc02051f0:	fbfd                	bnez	a5,ffffffffc02051e6 <do_fork+0x2d4>
        ret = dup_mmap(mm, oldmm);
ffffffffc02051f2:	85ea                	mv	a1,s10
ffffffffc02051f4:	8566                	mv	a0,s9
ffffffffc02051f6:	ed9fb0ef          	jal	ra,ffffffffc02010ce <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02051fa:	57f9                	li	a5,-2
ffffffffc02051fc:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc0205200:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0205202:	0e078e63          	beqz	a5,ffffffffc02052fe <do_fork+0x3ec>
good_mm:
ffffffffc0205206:	8d66                	mv	s10,s9
    if (ret != 0) {
ffffffffc0205208:	dc0505e3          	beqz	a0,ffffffffc0204fd2 <do_fork+0xc0>
    exit_mmap(mm);
ffffffffc020520c:	8566                	mv	a0,s9
ffffffffc020520e:	f5bfb0ef          	jal	ra,ffffffffc0201168 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205212:	8566                	mv	a0,s9
ffffffffc0205214:	c1dff0ef          	jal	ra,ffffffffc0204e30 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205218:	8566                	mv	a0,s9
ffffffffc020521a:	db3fb0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020521e:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc0205220:	c02007b7          	lui	a5,0xc0200
ffffffffc0205224:	0cf6e163          	bltu	a3,a5,ffffffffc02052e6 <do_fork+0x3d4>
ffffffffc0205228:	000c3783          	ld	a5,0(s8)
    if (PPN(pa) >= npage) {
ffffffffc020522c:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc0205230:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205234:	83b1                	srli	a5,a5,0xc
ffffffffc0205236:	06e7ff63          	bgeu	a5,a4,ffffffffc02052b4 <do_fork+0x3a2>
    return &pages[PPN(pa) - nbase];
ffffffffc020523a:	000b3703          	ld	a4,0(s6)
ffffffffc020523e:	000ab503          	ld	a0,0(s5)
ffffffffc0205242:	4589                	li	a1,2
ffffffffc0205244:	8f99                	sub	a5,a5,a4
ffffffffc0205246:	079a                	slli	a5,a5,0x6
ffffffffc0205248:	953e                	add	a0,a0,a5
ffffffffc020524a:	a8efe0ef          	jal	ra,ffffffffc02034d8 <free_pages>
    kfree(proc);
ffffffffc020524e:	8526                	mv	a0,s1
ffffffffc0205250:	d13fc0ef          	jal	ra,ffffffffc0201f62 <kfree>
    ret = -E_NO_MEM;
ffffffffc0205254:	5571                	li	a0,-4
    return ret;
ffffffffc0205256:	b561                	j	ffffffffc02050de <do_fork+0x1cc>
        intr_enable();
ffffffffc0205258:	beafb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020525c:	bdad                	j	ffffffffc02050d6 <do_fork+0x1c4>
                    if (last_pid >= MAX_PID) {
ffffffffc020525e:	01d6c363          	blt	a3,t4,ffffffffc0205264 <do_fork+0x352>
                        last_pid = 1;
ffffffffc0205262:	4685                	li	a3,1
                    goto repeat;
ffffffffc0205264:	4585                	li	a1,1
ffffffffc0205266:	bd7d                	j	ffffffffc0205124 <do_fork+0x212>
ffffffffc0205268:	c599                	beqz	a1,ffffffffc0205276 <do_fork+0x364>
ffffffffc020526a:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc020526e:	8536                	mv	a0,a3
ffffffffc0205270:	b539                	j	ffffffffc020507e <do_fork+0x16c>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205272:	556d                	li	a0,-5
ffffffffc0205274:	b5ad                	j	ffffffffc02050de <do_fork+0x1cc>
    return last_pid;
ffffffffc0205276:	00082503          	lw	a0,0(a6)
ffffffffc020527a:	b511                	j	ffffffffc020507e <do_fork+0x16c>
    assert(current->wait_state == 0); // 更新步骤1：将子进程的父进程设置为当前进程，确保当前进程的wait_state为0
ffffffffc020527c:	00003697          	auipc	a3,0x3
ffffffffc0205280:	18468693          	addi	a3,a3,388 # ffffffffc0208400 <default_pmm_manager+0x6d8>
ffffffffc0205284:	00002617          	auipc	a2,0x2
ffffffffc0205288:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0206c80 <commands+0x410>
ffffffffc020528c:	1ba00593          	li	a1,442
ffffffffc0205290:	00003517          	auipc	a0,0x3
ffffffffc0205294:	15850513          	addi	a0,a0,344 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0205298:	f71fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc020529c:	00002617          	auipc	a2,0x2
ffffffffc02052a0:	fb460613          	addi	a2,a2,-76 # ffffffffc0207250 <commands+0x9e0>
ffffffffc02052a4:	06900593          	li	a1,105
ffffffffc02052a8:	00002517          	auipc	a0,0x2
ffffffffc02052ac:	f9850513          	addi	a0,a0,-104 # ffffffffc0207240 <commands+0x9d0>
ffffffffc02052b0:	f59fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02052b4:	00002617          	auipc	a2,0x2
ffffffffc02052b8:	f6c60613          	addi	a2,a2,-148 # ffffffffc0207220 <commands+0x9b0>
ffffffffc02052bc:	06200593          	li	a1,98
ffffffffc02052c0:	00002517          	auipc	a0,0x2
ffffffffc02052c4:	f8050513          	addi	a0,a0,-128 # ffffffffc0207240 <commands+0x9d0>
ffffffffc02052c8:	f41fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02052cc:	86be                	mv	a3,a5
ffffffffc02052ce:	00002617          	auipc	a2,0x2
ffffffffc02052d2:	30a60613          	addi	a2,a2,778 # ffffffffc02075d8 <commands+0xd68>
ffffffffc02052d6:	16900593          	li	a1,361
ffffffffc02052da:	00003517          	auipc	a0,0x3
ffffffffc02052de:	10e50513          	addi	a0,a0,270 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc02052e2:	f27fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02052e6:	00002617          	auipc	a2,0x2
ffffffffc02052ea:	2f260613          	addi	a2,a2,754 # ffffffffc02075d8 <commands+0xd68>
ffffffffc02052ee:	06e00593          	li	a1,110
ffffffffc02052f2:	00002517          	auipc	a0,0x2
ffffffffc02052f6:	f4e50513          	addi	a0,a0,-178 # ffffffffc0207240 <commands+0x9d0>
ffffffffc02052fa:	f0ffa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("Unlock failed.\n");
ffffffffc02052fe:	00003617          	auipc	a2,0x3
ffffffffc0205302:	12260613          	addi	a2,a2,290 # ffffffffc0208420 <default_pmm_manager+0x6f8>
ffffffffc0205306:	03100593          	li	a1,49
ffffffffc020530a:	00003517          	auipc	a0,0x3
ffffffffc020530e:	12650513          	addi	a0,a0,294 # ffffffffc0208430 <default_pmm_manager+0x708>
ffffffffc0205312:	ef7fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205316 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205316:	7129                	addi	sp,sp,-320
ffffffffc0205318:	fa22                	sd	s0,304(sp)
ffffffffc020531a:	f626                	sd	s1,296(sp)
ffffffffc020531c:	f24a                	sd	s2,288(sp)
ffffffffc020531e:	84ae                	mv	s1,a1
ffffffffc0205320:	892a                	mv	s2,a0
ffffffffc0205322:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205324:	4581                	li	a1,0
ffffffffc0205326:	12000613          	li	a2,288
ffffffffc020532a:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020532c:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020532e:	66d000ef          	jal	ra,ffffffffc020619a <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205332:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205334:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205336:	100027f3          	csrr	a5,sstatus
ffffffffc020533a:	edd7f793          	andi	a5,a5,-291
ffffffffc020533e:	1207e793          	ori	a5,a5,288
ffffffffc0205342:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205344:	860a                	mv	a2,sp
ffffffffc0205346:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020534a:	00000797          	auipc	a5,0x0
ffffffffc020534e:	9e078793          	addi	a5,a5,-1568 # ffffffffc0204d2a <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205352:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205354:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205356:	bbdff0ef          	jal	ra,ffffffffc0204f12 <do_fork>
}
ffffffffc020535a:	70f2                	ld	ra,312(sp)
ffffffffc020535c:	7452                	ld	s0,304(sp)
ffffffffc020535e:	74b2                	ld	s1,296(sp)
ffffffffc0205360:	7912                	ld	s2,288(sp)
ffffffffc0205362:	6131                	addi	sp,sp,320
ffffffffc0205364:	8082                	ret

ffffffffc0205366 <do_exit>:
do_exit(int error_code) {
ffffffffc0205366:	7179                	addi	sp,sp,-48
ffffffffc0205368:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc020536a:	000ad417          	auipc	s0,0xad
ffffffffc020536e:	4d640413          	addi	s0,s0,1238 # ffffffffc02b2840 <current>
ffffffffc0205372:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc0205374:	f406                	sd	ra,40(sp)
ffffffffc0205376:	ec26                	sd	s1,24(sp)
ffffffffc0205378:	e84a                	sd	s2,16(sp)
ffffffffc020537a:	e44e                	sd	s3,8(sp)
ffffffffc020537c:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc020537e:	000ad717          	auipc	a4,0xad
ffffffffc0205382:	4ca73703          	ld	a4,1226(a4) # ffffffffc02b2848 <idleproc>
ffffffffc0205386:	0ce78c63          	beq	a5,a4,ffffffffc020545e <do_exit+0xf8>
    if (current == initproc) {
ffffffffc020538a:	000ad497          	auipc	s1,0xad
ffffffffc020538e:	4c648493          	addi	s1,s1,1222 # ffffffffc02b2850 <initproc>
ffffffffc0205392:	6098                	ld	a4,0(s1)
ffffffffc0205394:	0ee78b63          	beq	a5,a4,ffffffffc020548a <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc0205398:	0287b983          	ld	s3,40(a5)
ffffffffc020539c:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc020539e:	02098663          	beqz	s3,ffffffffc02053ca <do_exit+0x64>
ffffffffc02053a2:	000ad797          	auipc	a5,0xad
ffffffffc02053a6:	46e7b783          	ld	a5,1134(a5) # ffffffffc02b2810 <boot_cr3>
ffffffffc02053aa:	577d                	li	a4,-1
ffffffffc02053ac:	177e                	slli	a4,a4,0x3f
ffffffffc02053ae:	83b1                	srli	a5,a5,0xc
ffffffffc02053b0:	8fd9                	or	a5,a5,a4
ffffffffc02053b2:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02053b6:	0309a783          	lw	a5,48(s3)
ffffffffc02053ba:	fff7871b          	addiw	a4,a5,-1
ffffffffc02053be:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc02053c2:	cb55                	beqz	a4,ffffffffc0205476 <do_exit+0x110>
        current->mm = NULL;
ffffffffc02053c4:	601c                	ld	a5,0(s0)
ffffffffc02053c6:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02053ca:	601c                	ld	a5,0(s0)
ffffffffc02053cc:	470d                	li	a4,3
ffffffffc02053ce:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc02053d0:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02053d4:	100027f3          	csrr	a5,sstatus
ffffffffc02053d8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02053da:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02053dc:	e3f9                	bnez	a5,ffffffffc02054a2 <do_exit+0x13c>
        proc = current->parent;
ffffffffc02053de:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02053e0:	800007b7          	lui	a5,0x80000
ffffffffc02053e4:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02053e6:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02053e8:	0ec52703          	lw	a4,236(a0)
ffffffffc02053ec:	0af70f63          	beq	a4,a5,ffffffffc02054aa <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc02053f0:	6018                	ld	a4,0(s0)
ffffffffc02053f2:	7b7c                	ld	a5,240(a4)
ffffffffc02053f4:	c3a1                	beqz	a5,ffffffffc0205434 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02053f6:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02053fa:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02053fc:	0985                	addi	s3,s3,1
ffffffffc02053fe:	a021                	j	ffffffffc0205406 <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc0205400:	6018                	ld	a4,0(s0)
ffffffffc0205402:	7b7c                	ld	a5,240(a4)
ffffffffc0205404:	cb85                	beqz	a5,ffffffffc0205434 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc0205406:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fe0>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020540a:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc020540c:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020540e:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0205410:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205414:	10e7b023          	sd	a4,256(a5)
ffffffffc0205418:	c311                	beqz	a4,ffffffffc020541c <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc020541a:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020541c:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc020541e:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0205420:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205422:	fd271fe3          	bne	a4,s2,ffffffffc0205400 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205426:	0ec52783          	lw	a5,236(a0)
ffffffffc020542a:	fd379be3          	bne	a5,s3,ffffffffc0205400 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc020542e:	305000ef          	jal	ra,ffffffffc0205f32 <wakeup_proc>
ffffffffc0205432:	b7f9                	j	ffffffffc0205400 <do_exit+0x9a>
    if (flag) {
ffffffffc0205434:	020a1263          	bnez	s4,ffffffffc0205458 <do_exit+0xf2>
    schedule();
ffffffffc0205438:	37b000ef          	jal	ra,ffffffffc0205fb2 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc020543c:	601c                	ld	a5,0(s0)
ffffffffc020543e:	00003617          	auipc	a2,0x3
ffffffffc0205442:	02a60613          	addi	a2,a2,42 # ffffffffc0208468 <default_pmm_manager+0x740>
ffffffffc0205446:	20700593          	li	a1,519
ffffffffc020544a:	43d4                	lw	a3,4(a5)
ffffffffc020544c:	00003517          	auipc	a0,0x3
ffffffffc0205450:	f9c50513          	addi	a0,a0,-100 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0205454:	db5fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_enable();
ffffffffc0205458:	9eafb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020545c:	bff1                	j	ffffffffc0205438 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc020545e:	00003617          	auipc	a2,0x3
ffffffffc0205462:	fea60613          	addi	a2,a2,-22 # ffffffffc0208448 <default_pmm_manager+0x720>
ffffffffc0205466:	1db00593          	li	a1,475
ffffffffc020546a:	00003517          	auipc	a0,0x3
ffffffffc020546e:	f7e50513          	addi	a0,a0,-130 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0205472:	d97fa0ef          	jal	ra,ffffffffc0200208 <__panic>
            exit_mmap(mm);
ffffffffc0205476:	854e                	mv	a0,s3
ffffffffc0205478:	cf1fb0ef          	jal	ra,ffffffffc0201168 <exit_mmap>
            put_pgdir(mm);
ffffffffc020547c:	854e                	mv	a0,s3
ffffffffc020547e:	9b3ff0ef          	jal	ra,ffffffffc0204e30 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205482:	854e                	mv	a0,s3
ffffffffc0205484:	b49fb0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
ffffffffc0205488:	bf35                	j	ffffffffc02053c4 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc020548a:	00003617          	auipc	a2,0x3
ffffffffc020548e:	fce60613          	addi	a2,a2,-50 # ffffffffc0208458 <default_pmm_manager+0x730>
ffffffffc0205492:	1de00593          	li	a1,478
ffffffffc0205496:	00003517          	auipc	a0,0x3
ffffffffc020549a:	f5250513          	addi	a0,a0,-174 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc020549e:	d6bfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_disable();
ffffffffc02054a2:	9a6fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc02054a6:	4a05                	li	s4,1
ffffffffc02054a8:	bf1d                	j	ffffffffc02053de <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc02054aa:	289000ef          	jal	ra,ffffffffc0205f32 <wakeup_proc>
ffffffffc02054ae:	b789                	j	ffffffffc02053f0 <do_exit+0x8a>

ffffffffc02054b0 <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc02054b0:	715d                	addi	sp,sp,-80
ffffffffc02054b2:	f84a                	sd	s2,48(sp)
ffffffffc02054b4:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc02054b6:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc02054ba:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc02054bc:	fc26                	sd	s1,56(sp)
ffffffffc02054be:	f052                	sd	s4,32(sp)
ffffffffc02054c0:	ec56                	sd	s5,24(sp)
ffffffffc02054c2:	e85a                	sd	s6,16(sp)
ffffffffc02054c4:	e45e                	sd	s7,8(sp)
ffffffffc02054c6:	e486                	sd	ra,72(sp)
ffffffffc02054c8:	e0a2                	sd	s0,64(sp)
ffffffffc02054ca:	84aa                	mv	s1,a0
ffffffffc02054cc:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc02054ce:	000adb97          	auipc	s7,0xad
ffffffffc02054d2:	372b8b93          	addi	s7,s7,882 # ffffffffc02b2840 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02054d6:	00050b1b          	sext.w	s6,a0
ffffffffc02054da:	fff50a9b          	addiw	s5,a0,-1
ffffffffc02054de:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc02054e0:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc02054e2:	ccbd                	beqz	s1,ffffffffc0205560 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02054e4:	0359e863          	bltu	s3,s5,ffffffffc0205514 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02054e8:	45a9                	li	a1,10
ffffffffc02054ea:	855a                	mv	a0,s6
ffffffffc02054ec:	0c6010ef          	jal	ra,ffffffffc02065b2 <hash32>
ffffffffc02054f0:	02051793          	slli	a5,a0,0x20
ffffffffc02054f4:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02054f8:	000a9797          	auipc	a5,0xa9
ffffffffc02054fc:	2c078793          	addi	a5,a5,704 # ffffffffc02ae7b8 <hash_list>
ffffffffc0205500:	953e                	add	a0,a0,a5
ffffffffc0205502:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205504:	a029                	j	ffffffffc020550e <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc0205506:	f2c42783          	lw	a5,-212(s0)
ffffffffc020550a:	02978163          	beq	a5,s1,ffffffffc020552c <do_wait.part.0+0x7c>
ffffffffc020550e:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc0205510:	fe851be3          	bne	a0,s0,ffffffffc0205506 <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc0205514:	5579                	li	a0,-2
}
ffffffffc0205516:	60a6                	ld	ra,72(sp)
ffffffffc0205518:	6406                	ld	s0,64(sp)
ffffffffc020551a:	74e2                	ld	s1,56(sp)
ffffffffc020551c:	7942                	ld	s2,48(sp)
ffffffffc020551e:	79a2                	ld	s3,40(sp)
ffffffffc0205520:	7a02                	ld	s4,32(sp)
ffffffffc0205522:	6ae2                	ld	s5,24(sp)
ffffffffc0205524:	6b42                	ld	s6,16(sp)
ffffffffc0205526:	6ba2                	ld	s7,8(sp)
ffffffffc0205528:	6161                	addi	sp,sp,80
ffffffffc020552a:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc020552c:	000bb683          	ld	a3,0(s7)
ffffffffc0205530:	f4843783          	ld	a5,-184(s0)
ffffffffc0205534:	fed790e3          	bne	a5,a3,ffffffffc0205514 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205538:	f2842703          	lw	a4,-216(s0)
ffffffffc020553c:	478d                	li	a5,3
ffffffffc020553e:	0ef70b63          	beq	a4,a5,ffffffffc0205634 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc0205542:	4785                	li	a5,1
ffffffffc0205544:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc0205546:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc020554a:	269000ef          	jal	ra,ffffffffc0205fb2 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc020554e:	000bb783          	ld	a5,0(s7)
ffffffffc0205552:	0b07a783          	lw	a5,176(a5)
ffffffffc0205556:	8b85                	andi	a5,a5,1
ffffffffc0205558:	d7c9                	beqz	a5,ffffffffc02054e2 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc020555a:	555d                	li	a0,-9
ffffffffc020555c:	e0bff0ef          	jal	ra,ffffffffc0205366 <do_exit>
        proc = current->cptr;
ffffffffc0205560:	000bb683          	ld	a3,0(s7)
ffffffffc0205564:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205566:	d45d                	beqz	s0,ffffffffc0205514 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205568:	470d                	li	a4,3
ffffffffc020556a:	a021                	j	ffffffffc0205572 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc020556c:	10043403          	ld	s0,256(s0)
ffffffffc0205570:	d869                	beqz	s0,ffffffffc0205542 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205572:	401c                	lw	a5,0(s0)
ffffffffc0205574:	fee79ce3          	bne	a5,a4,ffffffffc020556c <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205578:	000ad797          	auipc	a5,0xad
ffffffffc020557c:	2d07b783          	ld	a5,720(a5) # ffffffffc02b2848 <idleproc>
ffffffffc0205580:	0c878963          	beq	a5,s0,ffffffffc0205652 <do_wait.part.0+0x1a2>
ffffffffc0205584:	000ad797          	auipc	a5,0xad
ffffffffc0205588:	2cc7b783          	ld	a5,716(a5) # ffffffffc02b2850 <initproc>
ffffffffc020558c:	0cf40363          	beq	s0,a5,ffffffffc0205652 <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc0205590:	000a0663          	beqz	s4,ffffffffc020559c <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc0205594:	0e842783          	lw	a5,232(s0)
ffffffffc0205598:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020559c:	100027f3          	csrr	a5,sstatus
ffffffffc02055a0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02055a2:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055a4:	e7c1                	bnez	a5,ffffffffc020562c <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02055a6:	6c70                	ld	a2,216(s0)
ffffffffc02055a8:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc02055aa:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc02055ae:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02055b0:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055b2:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02055b4:	6470                	ld	a2,200(s0)
ffffffffc02055b6:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02055b8:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055ba:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc02055bc:	c319                	beqz	a4,ffffffffc02055c2 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc02055be:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc02055c0:	7c7c                	ld	a5,248(s0)
ffffffffc02055c2:	c3b5                	beqz	a5,ffffffffc0205626 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc02055c4:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc02055c8:	000ad717          	auipc	a4,0xad
ffffffffc02055cc:	29070713          	addi	a4,a4,656 # ffffffffc02b2858 <nr_process>
ffffffffc02055d0:	431c                	lw	a5,0(a4)
ffffffffc02055d2:	37fd                	addiw	a5,a5,-1
ffffffffc02055d4:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc02055d6:	e5a9                	bnez	a1,ffffffffc0205620 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02055d8:	6814                	ld	a3,16(s0)
ffffffffc02055da:	c02007b7          	lui	a5,0xc0200
ffffffffc02055de:	04f6ee63          	bltu	a3,a5,ffffffffc020563a <do_wait.part.0+0x18a>
ffffffffc02055e2:	000ad797          	auipc	a5,0xad
ffffffffc02055e6:	2567b783          	ld	a5,598(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc02055ea:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02055ec:	82b1                	srli	a3,a3,0xc
ffffffffc02055ee:	000ad797          	auipc	a5,0xad
ffffffffc02055f2:	2327b783          	ld	a5,562(a5) # ffffffffc02b2820 <npage>
ffffffffc02055f6:	06f6fa63          	bgeu	a3,a5,ffffffffc020566a <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc02055fa:	00003517          	auipc	a0,0x3
ffffffffc02055fe:	6a653503          	ld	a0,1702(a0) # ffffffffc0208ca0 <nbase>
ffffffffc0205602:	8e89                	sub	a3,a3,a0
ffffffffc0205604:	069a                	slli	a3,a3,0x6
ffffffffc0205606:	000ad517          	auipc	a0,0xad
ffffffffc020560a:	22253503          	ld	a0,546(a0) # ffffffffc02b2828 <pages>
ffffffffc020560e:	9536                	add	a0,a0,a3
ffffffffc0205610:	4589                	li	a1,2
ffffffffc0205612:	ec7fd0ef          	jal	ra,ffffffffc02034d8 <free_pages>
    kfree(proc);
ffffffffc0205616:	8522                	mv	a0,s0
ffffffffc0205618:	94bfc0ef          	jal	ra,ffffffffc0201f62 <kfree>
    return 0;
ffffffffc020561c:	4501                	li	a0,0
ffffffffc020561e:	bde5                	j	ffffffffc0205516 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc0205620:	822fb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0205624:	bf55                	j	ffffffffc02055d8 <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc0205626:	701c                	ld	a5,32(s0)
ffffffffc0205628:	fbf8                	sd	a4,240(a5)
ffffffffc020562a:	bf79                	j	ffffffffc02055c8 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc020562c:	81cfb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0205630:	4585                	li	a1,1
ffffffffc0205632:	bf95                	j	ffffffffc02055a6 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205634:	f2840413          	addi	s0,s0,-216
ffffffffc0205638:	b781                	j	ffffffffc0205578 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc020563a:	00002617          	auipc	a2,0x2
ffffffffc020563e:	f9e60613          	addi	a2,a2,-98 # ffffffffc02075d8 <commands+0xd68>
ffffffffc0205642:	06e00593          	li	a1,110
ffffffffc0205646:	00002517          	auipc	a0,0x2
ffffffffc020564a:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0207240 <commands+0x9d0>
ffffffffc020564e:	bbbfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc0205652:	00003617          	auipc	a2,0x3
ffffffffc0205656:	e3660613          	addi	a2,a2,-458 # ffffffffc0208488 <default_pmm_manager+0x760>
ffffffffc020565a:	30400593          	li	a1,772
ffffffffc020565e:	00003517          	auipc	a0,0x3
ffffffffc0205662:	d8a50513          	addi	a0,a0,-630 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0205666:	ba3fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020566a:	00002617          	auipc	a2,0x2
ffffffffc020566e:	bb660613          	addi	a2,a2,-1098 # ffffffffc0207220 <commands+0x9b0>
ffffffffc0205672:	06200593          	li	a1,98
ffffffffc0205676:	00002517          	auipc	a0,0x2
ffffffffc020567a:	bca50513          	addi	a0,a0,-1078 # ffffffffc0207240 <commands+0x9d0>
ffffffffc020567e:	b8bfa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205682 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0205682:	1141                	addi	sp,sp,-16
ffffffffc0205684:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205686:	e93fd0ef          	jal	ra,ffffffffc0203518 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc020568a:	825fc0ef          	jal	ra,ffffffffc0201eae <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc020568e:	4601                	li	a2,0
ffffffffc0205690:	4581                	li	a1,0
ffffffffc0205692:	fffff517          	auipc	a0,0xfffff
ffffffffc0205696:	72050513          	addi	a0,a0,1824 # ffffffffc0204db2 <user_main>
ffffffffc020569a:	c7dff0ef          	jal	ra,ffffffffc0205316 <kernel_thread>
    if (pid <= 0) {
ffffffffc020569e:	00a04563          	bgtz	a0,ffffffffc02056a8 <init_main+0x26>
ffffffffc02056a2:	a071                	j	ffffffffc020572e <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc02056a4:	10f000ef          	jal	ra,ffffffffc0205fb2 <schedule>
    if (code_store != NULL) {
ffffffffc02056a8:	4581                	li	a1,0
ffffffffc02056aa:	4501                	li	a0,0
ffffffffc02056ac:	e05ff0ef          	jal	ra,ffffffffc02054b0 <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc02056b0:	d975                	beqz	a0,ffffffffc02056a4 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02056b2:	00003517          	auipc	a0,0x3
ffffffffc02056b6:	e1650513          	addi	a0,a0,-490 # ffffffffc02084c8 <default_pmm_manager+0x7a0>
ffffffffc02056ba:	a13fa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02056be:	000ad797          	auipc	a5,0xad
ffffffffc02056c2:	1927b783          	ld	a5,402(a5) # ffffffffc02b2850 <initproc>
ffffffffc02056c6:	7bf8                	ld	a4,240(a5)
ffffffffc02056c8:	e339                	bnez	a4,ffffffffc020570e <init_main+0x8c>
ffffffffc02056ca:	7ff8                	ld	a4,248(a5)
ffffffffc02056cc:	e329                	bnez	a4,ffffffffc020570e <init_main+0x8c>
ffffffffc02056ce:	1007b703          	ld	a4,256(a5)
ffffffffc02056d2:	ef15                	bnez	a4,ffffffffc020570e <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc02056d4:	000ad697          	auipc	a3,0xad
ffffffffc02056d8:	1846a683          	lw	a3,388(a3) # ffffffffc02b2858 <nr_process>
ffffffffc02056dc:	4709                	li	a4,2
ffffffffc02056de:	0ae69463          	bne	a3,a4,ffffffffc0205786 <init_main+0x104>
    return listelm->next;
ffffffffc02056e2:	000ad697          	auipc	a3,0xad
ffffffffc02056e6:	0d668693          	addi	a3,a3,214 # ffffffffc02b27b8 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02056ea:	6698                	ld	a4,8(a3)
ffffffffc02056ec:	0c878793          	addi	a5,a5,200
ffffffffc02056f0:	06f71b63          	bne	a4,a5,ffffffffc0205766 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02056f4:	629c                	ld	a5,0(a3)
ffffffffc02056f6:	04f71863          	bne	a4,a5,ffffffffc0205746 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc02056fa:	00003517          	auipc	a0,0x3
ffffffffc02056fe:	eb650513          	addi	a0,a0,-330 # ffffffffc02085b0 <default_pmm_manager+0x888>
ffffffffc0205702:	9cbfa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
}
ffffffffc0205706:	60a2                	ld	ra,8(sp)
ffffffffc0205708:	4501                	li	a0,0
ffffffffc020570a:	0141                	addi	sp,sp,16
ffffffffc020570c:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020570e:	00003697          	auipc	a3,0x3
ffffffffc0205712:	de268693          	addi	a3,a3,-542 # ffffffffc02084f0 <default_pmm_manager+0x7c8>
ffffffffc0205716:	00001617          	auipc	a2,0x1
ffffffffc020571a:	56a60613          	addi	a2,a2,1386 # ffffffffc0206c80 <commands+0x410>
ffffffffc020571e:	36900593          	li	a1,873
ffffffffc0205722:	00003517          	auipc	a0,0x3
ffffffffc0205726:	cc650513          	addi	a0,a0,-826 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc020572a:	adffa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("create user_main failed.\n");
ffffffffc020572e:	00003617          	auipc	a2,0x3
ffffffffc0205732:	d7a60613          	addi	a2,a2,-646 # ffffffffc02084a8 <default_pmm_manager+0x780>
ffffffffc0205736:	36100593          	li	a1,865
ffffffffc020573a:	00003517          	auipc	a0,0x3
ffffffffc020573e:	cae50513          	addi	a0,a0,-850 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0205742:	ac7fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205746:	00003697          	auipc	a3,0x3
ffffffffc020574a:	e3a68693          	addi	a3,a3,-454 # ffffffffc0208580 <default_pmm_manager+0x858>
ffffffffc020574e:	00001617          	auipc	a2,0x1
ffffffffc0205752:	53260613          	addi	a2,a2,1330 # ffffffffc0206c80 <commands+0x410>
ffffffffc0205756:	36c00593          	li	a1,876
ffffffffc020575a:	00003517          	auipc	a0,0x3
ffffffffc020575e:	c8e50513          	addi	a0,a0,-882 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0205762:	aa7fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205766:	00003697          	auipc	a3,0x3
ffffffffc020576a:	dea68693          	addi	a3,a3,-534 # ffffffffc0208550 <default_pmm_manager+0x828>
ffffffffc020576e:	00001617          	auipc	a2,0x1
ffffffffc0205772:	51260613          	addi	a2,a2,1298 # ffffffffc0206c80 <commands+0x410>
ffffffffc0205776:	36b00593          	li	a1,875
ffffffffc020577a:	00003517          	auipc	a0,0x3
ffffffffc020577e:	c6e50513          	addi	a0,a0,-914 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0205782:	a87fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_process == 2);
ffffffffc0205786:	00003697          	auipc	a3,0x3
ffffffffc020578a:	dba68693          	addi	a3,a3,-582 # ffffffffc0208540 <default_pmm_manager+0x818>
ffffffffc020578e:	00001617          	auipc	a2,0x1
ffffffffc0205792:	4f260613          	addi	a2,a2,1266 # ffffffffc0206c80 <commands+0x410>
ffffffffc0205796:	36a00593          	li	a1,874
ffffffffc020579a:	00003517          	auipc	a0,0x3
ffffffffc020579e:	c4e50513          	addi	a0,a0,-946 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc02057a2:	a67fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02057a6 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057a6:	7171                	addi	sp,sp,-176
ffffffffc02057a8:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02057aa:	000add97          	auipc	s11,0xad
ffffffffc02057ae:	096d8d93          	addi	s11,s11,150 # ffffffffc02b2840 <current>
ffffffffc02057b2:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057b6:	e54e                	sd	s3,136(sp)
ffffffffc02057b8:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02057ba:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057be:	e94a                	sd	s2,144(sp)
ffffffffc02057c0:	f4de                	sd	s7,104(sp)
ffffffffc02057c2:	892a                	mv	s2,a0
ffffffffc02057c4:	8bb2                	mv	s7,a2
ffffffffc02057c6:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02057c8:	862e                	mv	a2,a1
ffffffffc02057ca:	4681                	li	a3,0
ffffffffc02057cc:	85aa                	mv	a1,a0
ffffffffc02057ce:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057d0:	f506                	sd	ra,168(sp)
ffffffffc02057d2:	f122                	sd	s0,160(sp)
ffffffffc02057d4:	e152                	sd	s4,128(sp)
ffffffffc02057d6:	fcd6                	sd	s5,120(sp)
ffffffffc02057d8:	f8da                	sd	s6,112(sp)
ffffffffc02057da:	f0e2                	sd	s8,96(sp)
ffffffffc02057dc:	ece6                	sd	s9,88(sp)
ffffffffc02057de:	e8ea                	sd	s10,80(sp)
ffffffffc02057e0:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02057e2:	81cfc0ef          	jal	ra,ffffffffc02017fe <user_mem_check>
ffffffffc02057e6:	40050863          	beqz	a0,ffffffffc0205bf6 <do_execve+0x450>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02057ea:	4641                	li	a2,16
ffffffffc02057ec:	4581                	li	a1,0
ffffffffc02057ee:	1808                	addi	a0,sp,48
ffffffffc02057f0:	1ab000ef          	jal	ra,ffffffffc020619a <memset>
    memcpy(local_name, name, len);
ffffffffc02057f4:	47bd                	li	a5,15
ffffffffc02057f6:	8626                	mv	a2,s1
ffffffffc02057f8:	1e97e063          	bltu	a5,s1,ffffffffc02059d8 <do_execve+0x232>
ffffffffc02057fc:	85ca                	mv	a1,s2
ffffffffc02057fe:	1808                	addi	a0,sp,48
ffffffffc0205800:	1ad000ef          	jal	ra,ffffffffc02061ac <memcpy>
    if (mm != NULL) {
ffffffffc0205804:	1e098163          	beqz	s3,ffffffffc02059e6 <do_execve+0x240>
        cputs("mm != NULL");
ffffffffc0205808:	00002517          	auipc	a0,0x2
ffffffffc020580c:	81050513          	addi	a0,a0,-2032 # ffffffffc0207018 <commands+0x7a8>
ffffffffc0205810:	8f5fa0ef          	jal	ra,ffffffffc0200104 <cputs>
ffffffffc0205814:	000ad797          	auipc	a5,0xad
ffffffffc0205818:	ffc7b783          	ld	a5,-4(a5) # ffffffffc02b2810 <boot_cr3>
ffffffffc020581c:	577d                	li	a4,-1
ffffffffc020581e:	177e                	slli	a4,a4,0x3f
ffffffffc0205820:	83b1                	srli	a5,a5,0xc
ffffffffc0205822:	8fd9                	or	a5,a5,a4
ffffffffc0205824:	18079073          	csrw	satp,a5
ffffffffc0205828:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b80>
ffffffffc020582c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205830:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205834:	2c070263          	beqz	a4,ffffffffc0205af8 <do_execve+0x352>
        current->mm = NULL;
ffffffffc0205838:	000db783          	ld	a5,0(s11)
ffffffffc020583c:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205840:	e06fb0ef          	jal	ra,ffffffffc0200e46 <mm_create>
ffffffffc0205844:	84aa                	mv	s1,a0
ffffffffc0205846:	1c050b63          	beqz	a0,ffffffffc0205a1c <do_execve+0x276>
    if ((page = alloc_page()) == NULL) {
ffffffffc020584a:	4505                	li	a0,1
ffffffffc020584c:	bfbfd0ef          	jal	ra,ffffffffc0203446 <alloc_pages>
ffffffffc0205850:	3a050763          	beqz	a0,ffffffffc0205bfe <do_execve+0x458>
    return page - pages + nbase;
ffffffffc0205854:	000adc97          	auipc	s9,0xad
ffffffffc0205858:	fd4c8c93          	addi	s9,s9,-44 # ffffffffc02b2828 <pages>
ffffffffc020585c:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc0205860:	000adc17          	auipc	s8,0xad
ffffffffc0205864:	fc0c0c13          	addi	s8,s8,-64 # ffffffffc02b2820 <npage>
    return page - pages + nbase;
ffffffffc0205868:	00003717          	auipc	a4,0x3
ffffffffc020586c:	43873703          	ld	a4,1080(a4) # ffffffffc0208ca0 <nbase>
ffffffffc0205870:	40d506b3          	sub	a3,a0,a3
ffffffffc0205874:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205876:	5afd                	li	s5,-1
ffffffffc0205878:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc020587c:	96ba                	add	a3,a3,a4
ffffffffc020587e:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205880:	00cad713          	srli	a4,s5,0xc
ffffffffc0205884:	ec3a                	sd	a4,24(sp)
ffffffffc0205886:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205888:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020588a:	36f77e63          	bgeu	a4,a5,ffffffffc0205c06 <do_execve+0x460>
ffffffffc020588e:	000adb17          	auipc	s6,0xad
ffffffffc0205892:	faab0b13          	addi	s6,s6,-86 # ffffffffc02b2838 <va_pa_offset>
ffffffffc0205896:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc020589a:	6605                	lui	a2,0x1
ffffffffc020589c:	000ad597          	auipc	a1,0xad
ffffffffc02058a0:	f7c5b583          	ld	a1,-132(a1) # ffffffffc02b2818 <boot_pgdir>
ffffffffc02058a4:	9936                	add	s2,s2,a3
ffffffffc02058a6:	854a                	mv	a0,s2
ffffffffc02058a8:	105000ef          	jal	ra,ffffffffc02061ac <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02058ac:	7782                	ld	a5,32(sp)
ffffffffc02058ae:	4398                	lw	a4,0(a5)
ffffffffc02058b0:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc02058b4:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02058b8:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b945f>
ffffffffc02058bc:	14f71663          	bne	a4,a5,ffffffffc0205a08 <do_execve+0x262>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02058c0:	7682                	ld	a3,32(sp)
ffffffffc02058c2:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02058c6:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02058ca:	00371793          	slli	a5,a4,0x3
ffffffffc02058ce:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02058d0:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02058d2:	078e                	slli	a5,a5,0x3
ffffffffc02058d4:	97ce                	add	a5,a5,s3
ffffffffc02058d6:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc02058d8:	00f9fc63          	bgeu	s3,a5,ffffffffc02058f0 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc02058dc:	0009a783          	lw	a5,0(s3)
ffffffffc02058e0:	4705                	li	a4,1
ffffffffc02058e2:	12e78f63          	beq	a5,a4,ffffffffc0205a20 <do_execve+0x27a>
    for (; ph < ph_end; ph ++) {
ffffffffc02058e6:	77a2                	ld	a5,40(sp)
ffffffffc02058e8:	03898993          	addi	s3,s3,56
ffffffffc02058ec:	fef9e8e3          	bltu	s3,a5,ffffffffc02058dc <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc02058f0:	4701                	li	a4,0
ffffffffc02058f2:	46ad                	li	a3,11
ffffffffc02058f4:	00100637          	lui	a2,0x100
ffffffffc02058f8:	7ff005b7          	lui	a1,0x7ff00
ffffffffc02058fc:	8526                	mv	a0,s1
ffffffffc02058fe:	f20fb0ef          	jal	ra,ffffffffc020101e <mm_map>
ffffffffc0205902:	8a2a                	mv	s4,a0
ffffffffc0205904:	1e051063          	bnez	a0,ffffffffc0205ae4 <do_execve+0x33e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205908:	6c88                	ld	a0,24(s1)
ffffffffc020590a:	467d                	li	a2,31
ffffffffc020590c:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205910:	9a2ff0ef          	jal	ra,ffffffffc0204ab2 <pgdir_alloc_page>
ffffffffc0205914:	38050163          	beqz	a0,ffffffffc0205c96 <do_execve+0x4f0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205918:	6c88                	ld	a0,24(s1)
ffffffffc020591a:	467d                	li	a2,31
ffffffffc020591c:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205920:	992ff0ef          	jal	ra,ffffffffc0204ab2 <pgdir_alloc_page>
ffffffffc0205924:	34050963          	beqz	a0,ffffffffc0205c76 <do_execve+0x4d0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205928:	6c88                	ld	a0,24(s1)
ffffffffc020592a:	467d                	li	a2,31
ffffffffc020592c:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205930:	982ff0ef          	jal	ra,ffffffffc0204ab2 <pgdir_alloc_page>
ffffffffc0205934:	32050163          	beqz	a0,ffffffffc0205c56 <do_execve+0x4b0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205938:	6c88                	ld	a0,24(s1)
ffffffffc020593a:	467d                	li	a2,31
ffffffffc020593c:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205940:	972ff0ef          	jal	ra,ffffffffc0204ab2 <pgdir_alloc_page>
ffffffffc0205944:	2e050963          	beqz	a0,ffffffffc0205c36 <do_execve+0x490>
    mm->mm_count += 1;
ffffffffc0205948:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc020594a:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc020594e:	6c94                	ld	a3,24(s1)
ffffffffc0205950:	2785                	addiw	a5,a5,1
ffffffffc0205952:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0205954:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205956:	c02007b7          	lui	a5,0xc0200
ffffffffc020595a:	2cf6e263          	bltu	a3,a5,ffffffffc0205c1e <do_execve+0x478>
ffffffffc020595e:	000b3783          	ld	a5,0(s6)
ffffffffc0205962:	577d                	li	a4,-1
ffffffffc0205964:	177e                	slli	a4,a4,0x3f
ffffffffc0205966:	8e9d                	sub	a3,a3,a5
ffffffffc0205968:	00c6d793          	srli	a5,a3,0xc
ffffffffc020596c:	f654                	sd	a3,168(a2)
ffffffffc020596e:	8fd9                	or	a5,a5,a4
ffffffffc0205970:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205974:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205976:	4581                	li	a1,0
ffffffffc0205978:	12000613          	li	a2,288
ffffffffc020597c:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc020597e:	10043903          	ld	s2,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205982:	019000ef          	jal	ra,ffffffffc020619a <memset>
    tf->epc = elf->e_entry; // tf->epc应该是用户程序的入口点（sepc的值）
ffffffffc0205986:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205988:	000db483          	ld	s1,0(s11)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE); // tf->status应该适合用户程序（sstatus的值）
ffffffffc020598c:	edf97913          	andi	s2,s2,-289
    tf->epc = elf->e_entry; // tf->epc应该是用户程序的入口点（sepc的值）
ffffffffc0205990:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP; // tf->gpr.sp应该是用户堆栈顶部（sp的值）
ffffffffc0205992:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205994:	0b448493          	addi	s1,s1,180
    tf->gpr.sp = USTACKTOP; // tf->gpr.sp应该是用户堆栈顶部（sp的值）
ffffffffc0205998:	07fe                	slli	a5,a5,0x1f
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020599a:	4641                	li	a2,16
ffffffffc020599c:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP; // tf->gpr.sp应该是用户堆栈顶部（sp的值）
ffffffffc020599e:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry; // tf->epc应该是用户程序的入口点（sepc的值）
ffffffffc02059a0:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE); // tf->status应该适合用户程序（sstatus的值）
ffffffffc02059a4:	11243023          	sd	s2,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02059a8:	8526                	mv	a0,s1
ffffffffc02059aa:	7f0000ef          	jal	ra,ffffffffc020619a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02059ae:	463d                	li	a2,15
ffffffffc02059b0:	180c                	addi	a1,sp,48
ffffffffc02059b2:	8526                	mv	a0,s1
ffffffffc02059b4:	7f8000ef          	jal	ra,ffffffffc02061ac <memcpy>
}
ffffffffc02059b8:	70aa                	ld	ra,168(sp)
ffffffffc02059ba:	740a                	ld	s0,160(sp)
ffffffffc02059bc:	64ea                	ld	s1,152(sp)
ffffffffc02059be:	694a                	ld	s2,144(sp)
ffffffffc02059c0:	69aa                	ld	s3,136(sp)
ffffffffc02059c2:	7ae6                	ld	s5,120(sp)
ffffffffc02059c4:	7b46                	ld	s6,112(sp)
ffffffffc02059c6:	7ba6                	ld	s7,104(sp)
ffffffffc02059c8:	7c06                	ld	s8,96(sp)
ffffffffc02059ca:	6ce6                	ld	s9,88(sp)
ffffffffc02059cc:	6d46                	ld	s10,80(sp)
ffffffffc02059ce:	6da6                	ld	s11,72(sp)
ffffffffc02059d0:	8552                	mv	a0,s4
ffffffffc02059d2:	6a0a                	ld	s4,128(sp)
ffffffffc02059d4:	614d                	addi	sp,sp,176
ffffffffc02059d6:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc02059d8:	463d                	li	a2,15
ffffffffc02059da:	85ca                	mv	a1,s2
ffffffffc02059dc:	1808                	addi	a0,sp,48
ffffffffc02059de:	7ce000ef          	jal	ra,ffffffffc02061ac <memcpy>
    if (mm != NULL) {
ffffffffc02059e2:	e20993e3          	bnez	s3,ffffffffc0205808 <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc02059e6:	000db783          	ld	a5,0(s11)
ffffffffc02059ea:	779c                	ld	a5,40(a5)
ffffffffc02059ec:	e4078ae3          	beqz	a5,ffffffffc0205840 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02059f0:	00003617          	auipc	a2,0x3
ffffffffc02059f4:	be060613          	addi	a2,a2,-1056 # ffffffffc02085d0 <default_pmm_manager+0x8a8>
ffffffffc02059f8:	21100593          	li	a1,529
ffffffffc02059fc:	00003517          	auipc	a0,0x3
ffffffffc0205a00:	9ec50513          	addi	a0,a0,-1556 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0205a04:	805fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    put_pgdir(mm);
ffffffffc0205a08:	8526                	mv	a0,s1
ffffffffc0205a0a:	c26ff0ef          	jal	ra,ffffffffc0204e30 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205a0e:	8526                	mv	a0,s1
ffffffffc0205a10:	dbcfb0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205a14:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc0205a16:	8552                	mv	a0,s4
ffffffffc0205a18:	94fff0ef          	jal	ra,ffffffffc0205366 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0205a1c:	5a71                	li	s4,-4
ffffffffc0205a1e:	bfe5                	j	ffffffffc0205a16 <do_execve+0x270>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205a20:	0289b603          	ld	a2,40(s3)
ffffffffc0205a24:	0209b783          	ld	a5,32(s3)
ffffffffc0205a28:	1cf66d63          	bltu	a2,a5,ffffffffc0205c02 <do_execve+0x45c>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a2c:	0049a783          	lw	a5,4(s3)
ffffffffc0205a30:	0017f693          	andi	a3,a5,1
ffffffffc0205a34:	c291                	beqz	a3,ffffffffc0205a38 <do_execve+0x292>
ffffffffc0205a36:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a38:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a3c:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a3e:	e779                	bnez	a4,ffffffffc0205b0c <do_execve+0x366>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a40:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a42:	c781                	beqz	a5,ffffffffc0205a4a <do_execve+0x2a4>
ffffffffc0205a44:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a48:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205a4a:	0026f793          	andi	a5,a3,2
ffffffffc0205a4e:	e3f1                	bnez	a5,ffffffffc0205b12 <do_execve+0x36c>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205a50:	0046f793          	andi	a5,a3,4
ffffffffc0205a54:	c399                	beqz	a5,ffffffffc0205a5a <do_execve+0x2b4>
ffffffffc0205a56:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205a5a:	0109b583          	ld	a1,16(s3)
ffffffffc0205a5e:	4701                	li	a4,0
ffffffffc0205a60:	8526                	mv	a0,s1
ffffffffc0205a62:	dbcfb0ef          	jal	ra,ffffffffc020101e <mm_map>
ffffffffc0205a66:	8a2a                	mv	s4,a0
ffffffffc0205a68:	ed35                	bnez	a0,ffffffffc0205ae4 <do_execve+0x33e>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a6a:	0109bb83          	ld	s7,16(s3)
ffffffffc0205a6e:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205a70:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a74:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a78:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a7c:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205a7e:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a80:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc0205a82:	054be963          	bltu	s7,s4,ffffffffc0205ad4 <do_execve+0x32e>
ffffffffc0205a86:	aa95                	j	ffffffffc0205bfa <do_execve+0x454>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205a88:	6785                	lui	a5,0x1
ffffffffc0205a8a:	415b8533          	sub	a0,s7,s5
ffffffffc0205a8e:	9abe                	add	s5,s5,a5
ffffffffc0205a90:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205a94:	015a7463          	bgeu	s4,s5,ffffffffc0205a9c <do_execve+0x2f6>
                size -= la - end;
ffffffffc0205a98:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0205a9c:	000cb683          	ld	a3,0(s9)
ffffffffc0205aa0:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205aa2:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205aa6:	40d406b3          	sub	a3,s0,a3
ffffffffc0205aaa:	8699                	srai	a3,a3,0x6
ffffffffc0205aac:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205aae:	67e2                	ld	a5,24(sp)
ffffffffc0205ab0:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205ab4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205ab6:	14b87863          	bgeu	a6,a1,ffffffffc0205c06 <do_execve+0x460>
ffffffffc0205aba:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205abe:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0205ac0:	9bb2                	add	s7,s7,a2
ffffffffc0205ac2:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205ac4:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205ac6:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205ac8:	6e4000ef          	jal	ra,ffffffffc02061ac <memcpy>
            start += size, from += size;
ffffffffc0205acc:	6622                	ld	a2,8(sp)
ffffffffc0205ace:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc0205ad0:	054bf363          	bgeu	s7,s4,ffffffffc0205b16 <do_execve+0x370>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205ad4:	6c88                	ld	a0,24(s1)
ffffffffc0205ad6:	866a                	mv	a2,s10
ffffffffc0205ad8:	85d6                	mv	a1,s5
ffffffffc0205ada:	fd9fe0ef          	jal	ra,ffffffffc0204ab2 <pgdir_alloc_page>
ffffffffc0205ade:	842a                	mv	s0,a0
ffffffffc0205ae0:	f545                	bnez	a0,ffffffffc0205a88 <do_execve+0x2e2>
        ret = -E_NO_MEM;
ffffffffc0205ae2:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0205ae4:	8526                	mv	a0,s1
ffffffffc0205ae6:	e82fb0ef          	jal	ra,ffffffffc0201168 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205aea:	8526                	mv	a0,s1
ffffffffc0205aec:	b44ff0ef          	jal	ra,ffffffffc0204e30 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205af0:	8526                	mv	a0,s1
ffffffffc0205af2:	cdafb0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
    return ret;
ffffffffc0205af6:	b705                	j	ffffffffc0205a16 <do_execve+0x270>
            exit_mmap(mm);
ffffffffc0205af8:	854e                	mv	a0,s3
ffffffffc0205afa:	e6efb0ef          	jal	ra,ffffffffc0201168 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205afe:	854e                	mv	a0,s3
ffffffffc0205b00:	b30ff0ef          	jal	ra,ffffffffc0204e30 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205b04:	854e                	mv	a0,s3
ffffffffc0205b06:	cc6fb0ef          	jal	ra,ffffffffc0200fcc <mm_destroy>
ffffffffc0205b0a:	b33d                	j	ffffffffc0205838 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b0c:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b10:	fb95                	bnez	a5,ffffffffc0205a44 <do_execve+0x29e>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205b12:	4d5d                	li	s10,23
ffffffffc0205b14:	bf35                	j	ffffffffc0205a50 <do_execve+0x2aa>
        end = ph->p_va + ph->p_memsz;
ffffffffc0205b16:	0109b683          	ld	a3,16(s3)
ffffffffc0205b1a:	0289b903          	ld	s2,40(s3)
ffffffffc0205b1e:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc0205b20:	075bfd63          	bgeu	s7,s5,ffffffffc0205b9a <do_execve+0x3f4>
            if (start == end) {
ffffffffc0205b24:	dd7901e3          	beq	s2,s7,ffffffffc02058e6 <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b28:	6785                	lui	a5,0x1
ffffffffc0205b2a:	00fb8533          	add	a0,s7,a5
ffffffffc0205b2e:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0205b32:	41790a33          	sub	s4,s2,s7
            if (end < la) {
ffffffffc0205b36:	0b597d63          	bgeu	s2,s5,ffffffffc0205bf0 <do_execve+0x44a>
    return page - pages + nbase;
ffffffffc0205b3a:	000cb683          	ld	a3,0(s9)
ffffffffc0205b3e:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205b40:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0205b44:	40d406b3          	sub	a3,s0,a3
ffffffffc0205b48:	8699                	srai	a3,a3,0x6
ffffffffc0205b4a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205b4c:	67e2                	ld	a5,24(sp)
ffffffffc0205b4e:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b52:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b54:	0ac5f963          	bgeu	a1,a2,ffffffffc0205c06 <do_execve+0x460>
ffffffffc0205b58:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205b5c:	8652                	mv	a2,s4
ffffffffc0205b5e:	4581                	li	a1,0
ffffffffc0205b60:	96c2                	add	a3,a3,a6
ffffffffc0205b62:	9536                	add	a0,a0,a3
ffffffffc0205b64:	636000ef          	jal	ra,ffffffffc020619a <memset>
            start += size;
ffffffffc0205b68:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205b6c:	03597463          	bgeu	s2,s5,ffffffffc0205b94 <do_execve+0x3ee>
ffffffffc0205b70:	d6e90be3          	beq	s2,a4,ffffffffc02058e6 <do_execve+0x140>
ffffffffc0205b74:	00003697          	auipc	a3,0x3
ffffffffc0205b78:	a8468693          	addi	a3,a3,-1404 # ffffffffc02085f8 <default_pmm_manager+0x8d0>
ffffffffc0205b7c:	00001617          	auipc	a2,0x1
ffffffffc0205b80:	10460613          	addi	a2,a2,260 # ffffffffc0206c80 <commands+0x410>
ffffffffc0205b84:	26600593          	li	a1,614
ffffffffc0205b88:	00003517          	auipc	a0,0x3
ffffffffc0205b8c:	86050513          	addi	a0,a0,-1952 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0205b90:	e78fa0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0205b94:	ff5710e3          	bne	a4,s5,ffffffffc0205b74 <do_execve+0x3ce>
ffffffffc0205b98:	8bd6                	mv	s7,s5
        while (start < end) {
ffffffffc0205b9a:	d52bf6e3          	bgeu	s7,s2,ffffffffc02058e6 <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205b9e:	6c88                	ld	a0,24(s1)
ffffffffc0205ba0:	866a                	mv	a2,s10
ffffffffc0205ba2:	85d6                	mv	a1,s5
ffffffffc0205ba4:	f0ffe0ef          	jal	ra,ffffffffc0204ab2 <pgdir_alloc_page>
ffffffffc0205ba8:	842a                	mv	s0,a0
ffffffffc0205baa:	dd05                	beqz	a0,ffffffffc0205ae2 <do_execve+0x33c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205bac:	6785                	lui	a5,0x1
ffffffffc0205bae:	415b8533          	sub	a0,s7,s5
ffffffffc0205bb2:	9abe                	add	s5,s5,a5
ffffffffc0205bb4:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205bb8:	01597463          	bgeu	s2,s5,ffffffffc0205bc0 <do_execve+0x41a>
                size -= la - end;
ffffffffc0205bbc:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0205bc0:	000cb683          	ld	a3,0(s9)
ffffffffc0205bc4:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205bc6:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205bca:	40d406b3          	sub	a3,s0,a3
ffffffffc0205bce:	8699                	srai	a3,a3,0x6
ffffffffc0205bd0:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205bd2:	67e2                	ld	a5,24(sp)
ffffffffc0205bd4:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205bd8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205bda:	02b87663          	bgeu	a6,a1,ffffffffc0205c06 <do_execve+0x460>
ffffffffc0205bde:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205be2:	4581                	li	a1,0
            start += size;
ffffffffc0205be4:	9bb2                	add	s7,s7,a2
ffffffffc0205be6:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205be8:	9536                	add	a0,a0,a3
ffffffffc0205bea:	5b0000ef          	jal	ra,ffffffffc020619a <memset>
ffffffffc0205bee:	b775                	j	ffffffffc0205b9a <do_execve+0x3f4>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205bf0:	417a8a33          	sub	s4,s5,s7
ffffffffc0205bf4:	b799                	j	ffffffffc0205b3a <do_execve+0x394>
        return -E_INVAL;
ffffffffc0205bf6:	5a75                	li	s4,-3
ffffffffc0205bf8:	b3c1                	j	ffffffffc02059b8 <do_execve+0x212>
        while (start < end) {
ffffffffc0205bfa:	86de                	mv	a3,s7
ffffffffc0205bfc:	bf39                	j	ffffffffc0205b1a <do_execve+0x374>
    int ret = -E_NO_MEM;
ffffffffc0205bfe:	5a71                	li	s4,-4
ffffffffc0205c00:	bdc5                	j	ffffffffc0205af0 <do_execve+0x34a>
            ret = -E_INVAL_ELF;
ffffffffc0205c02:	5a61                	li	s4,-8
ffffffffc0205c04:	b5c5                	j	ffffffffc0205ae4 <do_execve+0x33e>
ffffffffc0205c06:	00001617          	auipc	a2,0x1
ffffffffc0205c0a:	64a60613          	addi	a2,a2,1610 # ffffffffc0207250 <commands+0x9e0>
ffffffffc0205c0e:	06900593          	li	a1,105
ffffffffc0205c12:	00001517          	auipc	a0,0x1
ffffffffc0205c16:	62e50513          	addi	a0,a0,1582 # ffffffffc0207240 <commands+0x9d0>
ffffffffc0205c1a:	deefa0ef          	jal	ra,ffffffffc0200208 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205c1e:	00002617          	auipc	a2,0x2
ffffffffc0205c22:	9ba60613          	addi	a2,a2,-1606 # ffffffffc02075d8 <commands+0xd68>
ffffffffc0205c26:	28100593          	li	a1,641
ffffffffc0205c2a:	00002517          	auipc	a0,0x2
ffffffffc0205c2e:	7be50513          	addi	a0,a0,1982 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0205c32:	dd6fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c36:	00003697          	auipc	a3,0x3
ffffffffc0205c3a:	ada68693          	addi	a3,a3,-1318 # ffffffffc0208710 <default_pmm_manager+0x9e8>
ffffffffc0205c3e:	00001617          	auipc	a2,0x1
ffffffffc0205c42:	04260613          	addi	a2,a2,66 # ffffffffc0206c80 <commands+0x410>
ffffffffc0205c46:	27c00593          	li	a1,636
ffffffffc0205c4a:	00002517          	auipc	a0,0x2
ffffffffc0205c4e:	79e50513          	addi	a0,a0,1950 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0205c52:	db6fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c56:	00003697          	auipc	a3,0x3
ffffffffc0205c5a:	a7268693          	addi	a3,a3,-1422 # ffffffffc02086c8 <default_pmm_manager+0x9a0>
ffffffffc0205c5e:	00001617          	auipc	a2,0x1
ffffffffc0205c62:	02260613          	addi	a2,a2,34 # ffffffffc0206c80 <commands+0x410>
ffffffffc0205c66:	27b00593          	li	a1,635
ffffffffc0205c6a:	00002517          	auipc	a0,0x2
ffffffffc0205c6e:	77e50513          	addi	a0,a0,1918 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0205c72:	d96fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c76:	00003697          	auipc	a3,0x3
ffffffffc0205c7a:	a0a68693          	addi	a3,a3,-1526 # ffffffffc0208680 <default_pmm_manager+0x958>
ffffffffc0205c7e:	00001617          	auipc	a2,0x1
ffffffffc0205c82:	00260613          	addi	a2,a2,2 # ffffffffc0206c80 <commands+0x410>
ffffffffc0205c86:	27a00593          	li	a1,634
ffffffffc0205c8a:	00002517          	auipc	a0,0x2
ffffffffc0205c8e:	75e50513          	addi	a0,a0,1886 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0205c92:	d76fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205c96:	00003697          	auipc	a3,0x3
ffffffffc0205c9a:	9a268693          	addi	a3,a3,-1630 # ffffffffc0208638 <default_pmm_manager+0x910>
ffffffffc0205c9e:	00001617          	auipc	a2,0x1
ffffffffc0205ca2:	fe260613          	addi	a2,a2,-30 # ffffffffc0206c80 <commands+0x410>
ffffffffc0205ca6:	27900593          	li	a1,633
ffffffffc0205caa:	00002517          	auipc	a0,0x2
ffffffffc0205cae:	73e50513          	addi	a0,a0,1854 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0205cb2:	d56fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205cb6 <do_yield>:
    current->need_resched = 1;
ffffffffc0205cb6:	000ad797          	auipc	a5,0xad
ffffffffc0205cba:	b8a7b783          	ld	a5,-1142(a5) # ffffffffc02b2840 <current>
ffffffffc0205cbe:	4705                	li	a4,1
ffffffffc0205cc0:	ef98                	sd	a4,24(a5)
}
ffffffffc0205cc2:	4501                	li	a0,0
ffffffffc0205cc4:	8082                	ret

ffffffffc0205cc6 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205cc6:	1101                	addi	sp,sp,-32
ffffffffc0205cc8:	e822                	sd	s0,16(sp)
ffffffffc0205cca:	e426                	sd	s1,8(sp)
ffffffffc0205ccc:	ec06                	sd	ra,24(sp)
ffffffffc0205cce:	842e                	mv	s0,a1
ffffffffc0205cd0:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205cd2:	c999                	beqz	a1,ffffffffc0205ce8 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205cd4:	000ad797          	auipc	a5,0xad
ffffffffc0205cd8:	b6c7b783          	ld	a5,-1172(a5) # ffffffffc02b2840 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205cdc:	7788                	ld	a0,40(a5)
ffffffffc0205cde:	4685                	li	a3,1
ffffffffc0205ce0:	4611                	li	a2,4
ffffffffc0205ce2:	b1dfb0ef          	jal	ra,ffffffffc02017fe <user_mem_check>
ffffffffc0205ce6:	c909                	beqz	a0,ffffffffc0205cf8 <do_wait+0x32>
ffffffffc0205ce8:	85a2                	mv	a1,s0
}
ffffffffc0205cea:	6442                	ld	s0,16(sp)
ffffffffc0205cec:	60e2                	ld	ra,24(sp)
ffffffffc0205cee:	8526                	mv	a0,s1
ffffffffc0205cf0:	64a2                	ld	s1,8(sp)
ffffffffc0205cf2:	6105                	addi	sp,sp,32
ffffffffc0205cf4:	fbcff06f          	j	ffffffffc02054b0 <do_wait.part.0>
ffffffffc0205cf8:	60e2                	ld	ra,24(sp)
ffffffffc0205cfa:	6442                	ld	s0,16(sp)
ffffffffc0205cfc:	64a2                	ld	s1,8(sp)
ffffffffc0205cfe:	5575                	li	a0,-3
ffffffffc0205d00:	6105                	addi	sp,sp,32
ffffffffc0205d02:	8082                	ret

ffffffffc0205d04 <do_kill>:
do_kill(int pid) {
ffffffffc0205d04:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205d06:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc0205d08:	e406                	sd	ra,8(sp)
ffffffffc0205d0a:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205d0c:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205d10:	17f9                	addi	a5,a5,-2
ffffffffc0205d12:	02e7e963          	bltu	a5,a4,ffffffffc0205d44 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205d16:	842a                	mv	s0,a0
ffffffffc0205d18:	45a9                	li	a1,10
ffffffffc0205d1a:	2501                	sext.w	a0,a0
ffffffffc0205d1c:	097000ef          	jal	ra,ffffffffc02065b2 <hash32>
ffffffffc0205d20:	02051793          	slli	a5,a0,0x20
ffffffffc0205d24:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205d28:	000a9797          	auipc	a5,0xa9
ffffffffc0205d2c:	a9078793          	addi	a5,a5,-1392 # ffffffffc02ae7b8 <hash_list>
ffffffffc0205d30:	953e                	add	a0,a0,a5
ffffffffc0205d32:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205d34:	a029                	j	ffffffffc0205d3e <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205d36:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205d3a:	00870b63          	beq	a4,s0,ffffffffc0205d50 <do_kill+0x4c>
ffffffffc0205d3e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205d40:	fef51be3          	bne	a0,a5,ffffffffc0205d36 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205d44:	5475                	li	s0,-3
}
ffffffffc0205d46:	60a2                	ld	ra,8(sp)
ffffffffc0205d48:	8522                	mv	a0,s0
ffffffffc0205d4a:	6402                	ld	s0,0(sp)
ffffffffc0205d4c:	0141                	addi	sp,sp,16
ffffffffc0205d4e:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205d50:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205d54:	00177693          	andi	a3,a4,1
ffffffffc0205d58:	e295                	bnez	a3,ffffffffc0205d7c <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d5a:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205d5c:	00176713          	ori	a4,a4,1
ffffffffc0205d60:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205d64:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d66:	fe06d0e3          	bgez	a3,ffffffffc0205d46 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205d6a:	f2878513          	addi	a0,a5,-216
ffffffffc0205d6e:	1c4000ef          	jal	ra,ffffffffc0205f32 <wakeup_proc>
}
ffffffffc0205d72:	60a2                	ld	ra,8(sp)
ffffffffc0205d74:	8522                	mv	a0,s0
ffffffffc0205d76:	6402                	ld	s0,0(sp)
ffffffffc0205d78:	0141                	addi	sp,sp,16
ffffffffc0205d7a:	8082                	ret
        return -E_KILLED;
ffffffffc0205d7c:	545d                	li	s0,-9
ffffffffc0205d7e:	b7e1                	j	ffffffffc0205d46 <do_kill+0x42>

ffffffffc0205d80 <proc_init>:


// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205d80:	1101                	addi	sp,sp,-32
ffffffffc0205d82:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205d84:	000ad797          	auipc	a5,0xad
ffffffffc0205d88:	a3478793          	addi	a5,a5,-1484 # ffffffffc02b27b8 <proc_list>
ffffffffc0205d8c:	ec06                	sd	ra,24(sp)
ffffffffc0205d8e:	e822                	sd	s0,16(sp)
ffffffffc0205d90:	e04a                	sd	s2,0(sp)
ffffffffc0205d92:	000a9497          	auipc	s1,0xa9
ffffffffc0205d96:	a2648493          	addi	s1,s1,-1498 # ffffffffc02ae7b8 <hash_list>
ffffffffc0205d9a:	e79c                	sd	a5,8(a5)
ffffffffc0205d9c:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205d9e:	000ad717          	auipc	a4,0xad
ffffffffc0205da2:	a1a70713          	addi	a4,a4,-1510 # ffffffffc02b27b8 <proc_list>
ffffffffc0205da6:	87a6                	mv	a5,s1
ffffffffc0205da8:	e79c                	sd	a5,8(a5)
ffffffffc0205daa:	e39c                	sd	a5,0(a5)
ffffffffc0205dac:	07c1                	addi	a5,a5,16
ffffffffc0205dae:	fef71de3          	bne	a4,a5,ffffffffc0205da8 <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205db2:	f81fe0ef          	jal	ra,ffffffffc0204d32 <alloc_proc>
ffffffffc0205db6:	000ad917          	auipc	s2,0xad
ffffffffc0205dba:	a9290913          	addi	s2,s2,-1390 # ffffffffc02b2848 <idleproc>
ffffffffc0205dbe:	00a93023          	sd	a0,0(s2)
ffffffffc0205dc2:	0e050f63          	beqz	a0,ffffffffc0205ec0 <proc_init+0x140>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205dc6:	4789                	li	a5,2
ffffffffc0205dc8:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205dca:	00003797          	auipc	a5,0x3
ffffffffc0205dce:	23678793          	addi	a5,a5,566 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205dd2:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205dd6:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205dd8:	4785                	li	a5,1
ffffffffc0205dda:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205ddc:	4641                	li	a2,16
ffffffffc0205dde:	4581                	li	a1,0
ffffffffc0205de0:	8522                	mv	a0,s0
ffffffffc0205de2:	3b8000ef          	jal	ra,ffffffffc020619a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205de6:	463d                	li	a2,15
ffffffffc0205de8:	00003597          	auipc	a1,0x3
ffffffffc0205dec:	98858593          	addi	a1,a1,-1656 # ffffffffc0208770 <default_pmm_manager+0xa48>
ffffffffc0205df0:	8522                	mv	a0,s0
ffffffffc0205df2:	3ba000ef          	jal	ra,ffffffffc02061ac <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205df6:	000ad717          	auipc	a4,0xad
ffffffffc0205dfa:	a6270713          	addi	a4,a4,-1438 # ffffffffc02b2858 <nr_process>
ffffffffc0205dfe:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205e00:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e04:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205e06:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e08:	4581                	li	a1,0
ffffffffc0205e0a:	00000517          	auipc	a0,0x0
ffffffffc0205e0e:	87850513          	addi	a0,a0,-1928 # ffffffffc0205682 <init_main>
    nr_process ++;
ffffffffc0205e12:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205e14:	000ad797          	auipc	a5,0xad
ffffffffc0205e18:	a2d7b623          	sd	a3,-1492(a5) # ffffffffc02b2840 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e1c:	cfaff0ef          	jal	ra,ffffffffc0205316 <kernel_thread>
ffffffffc0205e20:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0205e22:	08a05363          	blez	a0,ffffffffc0205ea8 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205e26:	6789                	lui	a5,0x2
ffffffffc0205e28:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205e2c:	17f9                	addi	a5,a5,-2
ffffffffc0205e2e:	2501                	sext.w	a0,a0
ffffffffc0205e30:	02e7e363          	bltu	a5,a4,ffffffffc0205e56 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205e34:	45a9                	li	a1,10
ffffffffc0205e36:	77c000ef          	jal	ra,ffffffffc02065b2 <hash32>
ffffffffc0205e3a:	02051793          	slli	a5,a0,0x20
ffffffffc0205e3e:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205e42:	96a6                	add	a3,a3,s1
ffffffffc0205e44:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205e46:	a029                	j	ffffffffc0205e50 <proc_init+0xd0>
            if (proc->pid == pid) {
ffffffffc0205e48:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c84>
ffffffffc0205e4c:	04870b63          	beq	a4,s0,ffffffffc0205ea2 <proc_init+0x122>
    return listelm->next;
ffffffffc0205e50:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205e52:	fef69be3          	bne	a3,a5,ffffffffc0205e48 <proc_init+0xc8>
    return NULL;
ffffffffc0205e56:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e58:	0b478493          	addi	s1,a5,180
ffffffffc0205e5c:	4641                	li	a2,16
ffffffffc0205e5e:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205e60:	000ad417          	auipc	s0,0xad
ffffffffc0205e64:	9f040413          	addi	s0,s0,-1552 # ffffffffc02b2850 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e68:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205e6a:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e6c:	32e000ef          	jal	ra,ffffffffc020619a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205e70:	463d                	li	a2,15
ffffffffc0205e72:	00003597          	auipc	a1,0x3
ffffffffc0205e76:	92658593          	addi	a1,a1,-1754 # ffffffffc0208798 <default_pmm_manager+0xa70>
ffffffffc0205e7a:	8526                	mv	a0,s1
ffffffffc0205e7c:	330000ef          	jal	ra,ffffffffc02061ac <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e80:	00093783          	ld	a5,0(s2)
ffffffffc0205e84:	cbb5                	beqz	a5,ffffffffc0205ef8 <proc_init+0x178>
ffffffffc0205e86:	43dc                	lw	a5,4(a5)
ffffffffc0205e88:	eba5                	bnez	a5,ffffffffc0205ef8 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e8a:	601c                	ld	a5,0(s0)
ffffffffc0205e8c:	c7b1                	beqz	a5,ffffffffc0205ed8 <proc_init+0x158>
ffffffffc0205e8e:	43d8                	lw	a4,4(a5)
ffffffffc0205e90:	4785                	li	a5,1
ffffffffc0205e92:	04f71363          	bne	a4,a5,ffffffffc0205ed8 <proc_init+0x158>
}
ffffffffc0205e96:	60e2                	ld	ra,24(sp)
ffffffffc0205e98:	6442                	ld	s0,16(sp)
ffffffffc0205e9a:	64a2                	ld	s1,8(sp)
ffffffffc0205e9c:	6902                	ld	s2,0(sp)
ffffffffc0205e9e:	6105                	addi	sp,sp,32
ffffffffc0205ea0:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205ea2:	f2878793          	addi	a5,a5,-216
ffffffffc0205ea6:	bf4d                	j	ffffffffc0205e58 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205ea8:	00003617          	auipc	a2,0x3
ffffffffc0205eac:	8d060613          	addi	a2,a2,-1840 # ffffffffc0208778 <default_pmm_manager+0xa50>
ffffffffc0205eb0:	38d00593          	li	a1,909
ffffffffc0205eb4:	00002517          	auipc	a0,0x2
ffffffffc0205eb8:	53450513          	addi	a0,a0,1332 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0205ebc:	b4cfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205ec0:	00003617          	auipc	a2,0x3
ffffffffc0205ec4:	89860613          	addi	a2,a2,-1896 # ffffffffc0208758 <default_pmm_manager+0xa30>
ffffffffc0205ec8:	37f00593          	li	a1,895
ffffffffc0205ecc:	00002517          	auipc	a0,0x2
ffffffffc0205ed0:	51c50513          	addi	a0,a0,1308 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0205ed4:	b34fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205ed8:	00003697          	auipc	a3,0x3
ffffffffc0205edc:	8f068693          	addi	a3,a3,-1808 # ffffffffc02087c8 <default_pmm_manager+0xaa0>
ffffffffc0205ee0:	00001617          	auipc	a2,0x1
ffffffffc0205ee4:	da060613          	addi	a2,a2,-608 # ffffffffc0206c80 <commands+0x410>
ffffffffc0205ee8:	39400593          	li	a1,916
ffffffffc0205eec:	00002517          	auipc	a0,0x2
ffffffffc0205ef0:	4fc50513          	addi	a0,a0,1276 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0205ef4:	b14fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205ef8:	00003697          	auipc	a3,0x3
ffffffffc0205efc:	8a868693          	addi	a3,a3,-1880 # ffffffffc02087a0 <default_pmm_manager+0xa78>
ffffffffc0205f00:	00001617          	auipc	a2,0x1
ffffffffc0205f04:	d8060613          	addi	a2,a2,-640 # ffffffffc0206c80 <commands+0x410>
ffffffffc0205f08:	39300593          	li	a1,915
ffffffffc0205f0c:	00002517          	auipc	a0,0x2
ffffffffc0205f10:	4dc50513          	addi	a0,a0,1244 # ffffffffc02083e8 <default_pmm_manager+0x6c0>
ffffffffc0205f14:	af4fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205f18 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205f18:	1141                	addi	sp,sp,-16
ffffffffc0205f1a:	e022                	sd	s0,0(sp)
ffffffffc0205f1c:	e406                	sd	ra,8(sp)
ffffffffc0205f1e:	000ad417          	auipc	s0,0xad
ffffffffc0205f22:	92240413          	addi	s0,s0,-1758 # ffffffffc02b2840 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205f26:	6018                	ld	a4,0(s0)
ffffffffc0205f28:	6f1c                	ld	a5,24(a4)
ffffffffc0205f2a:	dffd                	beqz	a5,ffffffffc0205f28 <cpu_idle+0x10>
            schedule();
ffffffffc0205f2c:	086000ef          	jal	ra,ffffffffc0205fb2 <schedule>
ffffffffc0205f30:	bfdd                	j	ffffffffc0205f26 <cpu_idle+0xe>

ffffffffc0205f32 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f32:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205f34:	1101                	addi	sp,sp,-32
ffffffffc0205f36:	ec06                	sd	ra,24(sp)
ffffffffc0205f38:	e822                	sd	s0,16(sp)
ffffffffc0205f3a:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f3c:	478d                	li	a5,3
ffffffffc0205f3e:	04f70b63          	beq	a4,a5,ffffffffc0205f94 <wakeup_proc+0x62>
ffffffffc0205f42:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f44:	100027f3          	csrr	a5,sstatus
ffffffffc0205f48:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205f4a:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f4c:	ef9d                	bnez	a5,ffffffffc0205f8a <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205f4e:	4789                	li	a5,2
ffffffffc0205f50:	02f70163          	beq	a4,a5,ffffffffc0205f72 <wakeup_proc+0x40>
            proc->state = PROC_RUNNABLE;
ffffffffc0205f54:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0205f56:	0e042623          	sw	zero,236(s0)
    if (flag) {
ffffffffc0205f5a:	e491                	bnez	s1,ffffffffc0205f66 <wakeup_proc+0x34>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205f5c:	60e2                	ld	ra,24(sp)
ffffffffc0205f5e:	6442                	ld	s0,16(sp)
ffffffffc0205f60:	64a2                	ld	s1,8(sp)
ffffffffc0205f62:	6105                	addi	sp,sp,32
ffffffffc0205f64:	8082                	ret
ffffffffc0205f66:	6442                	ld	s0,16(sp)
ffffffffc0205f68:	60e2                	ld	ra,24(sp)
ffffffffc0205f6a:	64a2                	ld	s1,8(sp)
ffffffffc0205f6c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205f6e:	ed4fa06f          	j	ffffffffc0200642 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205f72:	00003617          	auipc	a2,0x3
ffffffffc0205f76:	8b660613          	addi	a2,a2,-1866 # ffffffffc0208828 <default_pmm_manager+0xb00>
ffffffffc0205f7a:	45c9                	li	a1,18
ffffffffc0205f7c:	00003517          	auipc	a0,0x3
ffffffffc0205f80:	89450513          	addi	a0,a0,-1900 # ffffffffc0208810 <default_pmm_manager+0xae8>
ffffffffc0205f84:	aecfa0ef          	jal	ra,ffffffffc0200270 <__warn>
ffffffffc0205f88:	bfc9                	j	ffffffffc0205f5a <wakeup_proc+0x28>
        intr_disable();
ffffffffc0205f8a:	ebefa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205f8e:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0205f90:	4485                	li	s1,1
ffffffffc0205f92:	bf75                	j	ffffffffc0205f4e <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f94:	00003697          	auipc	a3,0x3
ffffffffc0205f98:	85c68693          	addi	a3,a3,-1956 # ffffffffc02087f0 <default_pmm_manager+0xac8>
ffffffffc0205f9c:	00001617          	auipc	a2,0x1
ffffffffc0205fa0:	ce460613          	addi	a2,a2,-796 # ffffffffc0206c80 <commands+0x410>
ffffffffc0205fa4:	45a5                	li	a1,9
ffffffffc0205fa6:	00003517          	auipc	a0,0x3
ffffffffc0205faa:	86a50513          	addi	a0,a0,-1942 # ffffffffc0208810 <default_pmm_manager+0xae8>
ffffffffc0205fae:	a5afa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205fb2 <schedule>:

void
schedule(void) {
ffffffffc0205fb2:	1141                	addi	sp,sp,-16
ffffffffc0205fb4:	e406                	sd	ra,8(sp)
ffffffffc0205fb6:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205fb8:	100027f3          	csrr	a5,sstatus
ffffffffc0205fbc:	8b89                	andi	a5,a5,2
ffffffffc0205fbe:	4401                	li	s0,0
ffffffffc0205fc0:	efbd                	bnez	a5,ffffffffc020603e <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205fc2:	000ad897          	auipc	a7,0xad
ffffffffc0205fc6:	87e8b883          	ld	a7,-1922(a7) # ffffffffc02b2840 <current>
ffffffffc0205fca:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205fce:	000ad517          	auipc	a0,0xad
ffffffffc0205fd2:	87a53503          	ld	a0,-1926(a0) # ffffffffc02b2848 <idleproc>
ffffffffc0205fd6:	04a88e63          	beq	a7,a0,ffffffffc0206032 <schedule+0x80>
ffffffffc0205fda:	0c888693          	addi	a3,a7,200
ffffffffc0205fde:	000ac617          	auipc	a2,0xac
ffffffffc0205fe2:	7da60613          	addi	a2,a2,2010 # ffffffffc02b27b8 <proc_list>
        le = last;
ffffffffc0205fe6:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205fe8:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205fea:	4809                	li	a6,2
ffffffffc0205fec:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205fee:	00c78863          	beq	a5,a2,ffffffffc0205ffe <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205ff2:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205ff6:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205ffa:	03070163          	beq	a4,a6,ffffffffc020601c <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0205ffe:	fef697e3          	bne	a3,a5,ffffffffc0205fec <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206002:	ed89                	bnez	a1,ffffffffc020601c <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0206004:	451c                	lw	a5,8(a0)
ffffffffc0206006:	2785                	addiw	a5,a5,1
ffffffffc0206008:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc020600a:	00a88463          	beq	a7,a0,ffffffffc0206012 <schedule+0x60>
            proc_run(next);
ffffffffc020600e:	e99fe0ef          	jal	ra,ffffffffc0204ea6 <proc_run>
    if (flag) {
ffffffffc0206012:	e819                	bnez	s0,ffffffffc0206028 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206014:	60a2                	ld	ra,8(sp)
ffffffffc0206016:	6402                	ld	s0,0(sp)
ffffffffc0206018:	0141                	addi	sp,sp,16
ffffffffc020601a:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020601c:	4198                	lw	a4,0(a1)
ffffffffc020601e:	4789                	li	a5,2
ffffffffc0206020:	fef712e3          	bne	a4,a5,ffffffffc0206004 <schedule+0x52>
ffffffffc0206024:	852e                	mv	a0,a1
ffffffffc0206026:	bff9                	j	ffffffffc0206004 <schedule+0x52>
}
ffffffffc0206028:	6402                	ld	s0,0(sp)
ffffffffc020602a:	60a2                	ld	ra,8(sp)
ffffffffc020602c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020602e:	e14fa06f          	j	ffffffffc0200642 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206032:	000ac617          	auipc	a2,0xac
ffffffffc0206036:	78660613          	addi	a2,a2,1926 # ffffffffc02b27b8 <proc_list>
ffffffffc020603a:	86b2                	mv	a3,a2
ffffffffc020603c:	b76d                	j	ffffffffc0205fe6 <schedule+0x34>
        intr_disable();
ffffffffc020603e:	e0afa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0206042:	4405                	li	s0,1
ffffffffc0206044:	bfbd                	j	ffffffffc0205fc2 <schedule+0x10>

ffffffffc0206046 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0206046:	000ac797          	auipc	a5,0xac
ffffffffc020604a:	7fa7b783          	ld	a5,2042(a5) # ffffffffc02b2840 <current>
}
ffffffffc020604e:	43c8                	lw	a0,4(a5)
ffffffffc0206050:	8082                	ret

ffffffffc0206052 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206052:	4501                	li	a0,0
ffffffffc0206054:	8082                	ret

ffffffffc0206056 <sys_putc>:
    cputchar(c);
ffffffffc0206056:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206058:	1141                	addi	sp,sp,-16
ffffffffc020605a:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc020605c:	8a6fa0ef          	jal	ra,ffffffffc0200102 <cputchar>
}
ffffffffc0206060:	60a2                	ld	ra,8(sp)
ffffffffc0206062:	4501                	li	a0,0
ffffffffc0206064:	0141                	addi	sp,sp,16
ffffffffc0206066:	8082                	ret

ffffffffc0206068 <sys_kill>:
    return do_kill(pid);
ffffffffc0206068:	4108                	lw	a0,0(a0)
ffffffffc020606a:	c9bff06f          	j	ffffffffc0205d04 <do_kill>

ffffffffc020606e <sys_yield>:
    return do_yield();
ffffffffc020606e:	c49ff06f          	j	ffffffffc0205cb6 <do_yield>

ffffffffc0206072 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0206072:	6d14                	ld	a3,24(a0)
ffffffffc0206074:	6910                	ld	a2,16(a0)
ffffffffc0206076:	650c                	ld	a1,8(a0)
ffffffffc0206078:	6108                	ld	a0,0(a0)
ffffffffc020607a:	f2cff06f          	j	ffffffffc02057a6 <do_execve>

ffffffffc020607e <sys_wait>:
    return do_wait(pid, store);
ffffffffc020607e:	650c                	ld	a1,8(a0)
ffffffffc0206080:	4108                	lw	a0,0(a0)
ffffffffc0206082:	c45ff06f          	j	ffffffffc0205cc6 <do_wait>

ffffffffc0206086 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0206086:	000ac797          	auipc	a5,0xac
ffffffffc020608a:	7ba7b783          	ld	a5,1978(a5) # ffffffffc02b2840 <current>
ffffffffc020608e:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0206090:	4501                	li	a0,0
ffffffffc0206092:	6a0c                	ld	a1,16(a2)
ffffffffc0206094:	e7ffe06f          	j	ffffffffc0204f12 <do_fork>

ffffffffc0206098 <sys_exit>:
    return do_exit(error_code);
ffffffffc0206098:	4108                	lw	a0,0(a0)
ffffffffc020609a:	accff06f          	j	ffffffffc0205366 <do_exit>

ffffffffc020609e <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc020609e:	715d                	addi	sp,sp,-80
ffffffffc02060a0:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060a2:	000ac497          	auipc	s1,0xac
ffffffffc02060a6:	79e48493          	addi	s1,s1,1950 # ffffffffc02b2840 <current>
ffffffffc02060aa:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02060ac:	e0a2                	sd	s0,64(sp)
ffffffffc02060ae:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060b0:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02060b2:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060b4:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02060b6:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060ba:	0327ee63          	bltu	a5,s2,ffffffffc02060f6 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02060be:	00391713          	slli	a4,s2,0x3
ffffffffc02060c2:	00002797          	auipc	a5,0x2
ffffffffc02060c6:	7ce78793          	addi	a5,a5,1998 # ffffffffc0208890 <syscalls>
ffffffffc02060ca:	97ba                	add	a5,a5,a4
ffffffffc02060cc:	639c                	ld	a5,0(a5)
ffffffffc02060ce:	c785                	beqz	a5,ffffffffc02060f6 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02060d0:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02060d2:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02060d4:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02060d6:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02060d8:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02060da:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02060dc:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02060de:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02060e0:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02060e2:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02060e4:	0028                	addi	a0,sp,8
ffffffffc02060e6:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02060e8:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02060ea:	e828                	sd	a0,80(s0)
}
ffffffffc02060ec:	6406                	ld	s0,64(sp)
ffffffffc02060ee:	74e2                	ld	s1,56(sp)
ffffffffc02060f0:	7942                	ld	s2,48(sp)
ffffffffc02060f2:	6161                	addi	sp,sp,80
ffffffffc02060f4:	8082                	ret
    print_trapframe(tf);
ffffffffc02060f6:	8522                	mv	a0,s0
ffffffffc02060f8:	f3efa0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02060fc:	609c                	ld	a5,0(s1)
ffffffffc02060fe:	86ca                	mv	a3,s2
ffffffffc0206100:	00002617          	auipc	a2,0x2
ffffffffc0206104:	74860613          	addi	a2,a2,1864 # ffffffffc0208848 <default_pmm_manager+0xb20>
ffffffffc0206108:	43d8                	lw	a4,4(a5)
ffffffffc020610a:	06200593          	li	a1,98
ffffffffc020610e:	0b478793          	addi	a5,a5,180
ffffffffc0206112:	00002517          	auipc	a0,0x2
ffffffffc0206116:	76650513          	addi	a0,a0,1894 # ffffffffc0208878 <default_pmm_manager+0xb50>
ffffffffc020611a:	8eefa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020611e <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020611e:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0206122:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0206124:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0206126:	cb81                	beqz	a5,ffffffffc0206136 <strlen+0x18>
        cnt ++;
ffffffffc0206128:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc020612a:	00a707b3          	add	a5,a4,a0
ffffffffc020612e:	0007c783          	lbu	a5,0(a5)
ffffffffc0206132:	fbfd                	bnez	a5,ffffffffc0206128 <strlen+0xa>
ffffffffc0206134:	8082                	ret
    }
    return cnt;
}
ffffffffc0206136:	8082                	ret

ffffffffc0206138 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0206138:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020613a:	e589                	bnez	a1,ffffffffc0206144 <strnlen+0xc>
ffffffffc020613c:	a811                	j	ffffffffc0206150 <strnlen+0x18>
        cnt ++;
ffffffffc020613e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206140:	00f58863          	beq	a1,a5,ffffffffc0206150 <strnlen+0x18>
ffffffffc0206144:	00f50733          	add	a4,a0,a5
ffffffffc0206148:	00074703          	lbu	a4,0(a4)
ffffffffc020614c:	fb6d                	bnez	a4,ffffffffc020613e <strnlen+0x6>
ffffffffc020614e:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0206150:	852e                	mv	a0,a1
ffffffffc0206152:	8082                	ret

ffffffffc0206154 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206154:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206156:	0005c703          	lbu	a4,0(a1)
ffffffffc020615a:	0785                	addi	a5,a5,1
ffffffffc020615c:	0585                	addi	a1,a1,1
ffffffffc020615e:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206162:	fb75                	bnez	a4,ffffffffc0206156 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206164:	8082                	ret

ffffffffc0206166 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206166:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020616a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020616e:	cb89                	beqz	a5,ffffffffc0206180 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0206170:	0505                	addi	a0,a0,1
ffffffffc0206172:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206174:	fee789e3          	beq	a5,a4,ffffffffc0206166 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206178:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020617c:	9d19                	subw	a0,a0,a4
ffffffffc020617e:	8082                	ret
ffffffffc0206180:	4501                	li	a0,0
ffffffffc0206182:	bfed                	j	ffffffffc020617c <strcmp+0x16>

ffffffffc0206184 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0206184:	00054783          	lbu	a5,0(a0)
ffffffffc0206188:	c799                	beqz	a5,ffffffffc0206196 <strchr+0x12>
        if (*s == c) {
ffffffffc020618a:	00f58763          	beq	a1,a5,ffffffffc0206198 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020618e:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0206192:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0206194:	fbfd                	bnez	a5,ffffffffc020618a <strchr+0x6>
    }
    return NULL;
ffffffffc0206196:	4501                	li	a0,0
}
ffffffffc0206198:	8082                	ret

ffffffffc020619a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020619a:	ca01                	beqz	a2,ffffffffc02061aa <memset+0x10>
ffffffffc020619c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020619e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02061a0:	0785                	addi	a5,a5,1
ffffffffc02061a2:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02061a6:	fec79de3          	bne	a5,a2,ffffffffc02061a0 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02061aa:	8082                	ret

ffffffffc02061ac <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02061ac:	ca19                	beqz	a2,ffffffffc02061c2 <memcpy+0x16>
ffffffffc02061ae:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02061b0:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02061b2:	0005c703          	lbu	a4,0(a1)
ffffffffc02061b6:	0585                	addi	a1,a1,1
ffffffffc02061b8:	0785                	addi	a5,a5,1
ffffffffc02061ba:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02061be:	fec59ae3          	bne	a1,a2,ffffffffc02061b2 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02061c2:	8082                	ret

ffffffffc02061c4 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02061c4:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02061c8:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02061ca:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02061ce:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02061d0:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02061d4:	f022                	sd	s0,32(sp)
ffffffffc02061d6:	ec26                	sd	s1,24(sp)
ffffffffc02061d8:	e84a                	sd	s2,16(sp)
ffffffffc02061da:	f406                	sd	ra,40(sp)
ffffffffc02061dc:	e44e                	sd	s3,8(sp)
ffffffffc02061de:	84aa                	mv	s1,a0
ffffffffc02061e0:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02061e2:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02061e6:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02061e8:	03067e63          	bgeu	a2,a6,ffffffffc0206224 <printnum+0x60>
ffffffffc02061ec:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02061ee:	00805763          	blez	s0,ffffffffc02061fc <printnum+0x38>
ffffffffc02061f2:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02061f4:	85ca                	mv	a1,s2
ffffffffc02061f6:	854e                	mv	a0,s3
ffffffffc02061f8:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02061fa:	fc65                	bnez	s0,ffffffffc02061f2 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02061fc:	1a02                	slli	s4,s4,0x20
ffffffffc02061fe:	00002797          	auipc	a5,0x2
ffffffffc0206202:	79278793          	addi	a5,a5,1938 # ffffffffc0208990 <syscalls+0x100>
ffffffffc0206206:	020a5a13          	srli	s4,s4,0x20
ffffffffc020620a:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc020620c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020620e:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206212:	70a2                	ld	ra,40(sp)
ffffffffc0206214:	69a2                	ld	s3,8(sp)
ffffffffc0206216:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206218:	85ca                	mv	a1,s2
ffffffffc020621a:	87a6                	mv	a5,s1
}
ffffffffc020621c:	6942                	ld	s2,16(sp)
ffffffffc020621e:	64e2                	ld	s1,24(sp)
ffffffffc0206220:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206222:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206224:	03065633          	divu	a2,a2,a6
ffffffffc0206228:	8722                	mv	a4,s0
ffffffffc020622a:	f9bff0ef          	jal	ra,ffffffffc02061c4 <printnum>
ffffffffc020622e:	b7f9                	j	ffffffffc02061fc <printnum+0x38>

ffffffffc0206230 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206230:	7119                	addi	sp,sp,-128
ffffffffc0206232:	f4a6                	sd	s1,104(sp)
ffffffffc0206234:	f0ca                	sd	s2,96(sp)
ffffffffc0206236:	ecce                	sd	s3,88(sp)
ffffffffc0206238:	e8d2                	sd	s4,80(sp)
ffffffffc020623a:	e4d6                	sd	s5,72(sp)
ffffffffc020623c:	e0da                	sd	s6,64(sp)
ffffffffc020623e:	fc5e                	sd	s7,56(sp)
ffffffffc0206240:	f06a                	sd	s10,32(sp)
ffffffffc0206242:	fc86                	sd	ra,120(sp)
ffffffffc0206244:	f8a2                	sd	s0,112(sp)
ffffffffc0206246:	f862                	sd	s8,48(sp)
ffffffffc0206248:	f466                	sd	s9,40(sp)
ffffffffc020624a:	ec6e                	sd	s11,24(sp)
ffffffffc020624c:	892a                	mv	s2,a0
ffffffffc020624e:	84ae                	mv	s1,a1
ffffffffc0206250:	8d32                	mv	s10,a2
ffffffffc0206252:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206254:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0206258:	5b7d                	li	s6,-1
ffffffffc020625a:	00002a97          	auipc	s5,0x2
ffffffffc020625e:	762a8a93          	addi	s5,s5,1890 # ffffffffc02089bc <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206262:	00003b97          	auipc	s7,0x3
ffffffffc0206266:	976b8b93          	addi	s7,s7,-1674 # ffffffffc0208bd8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020626a:	000d4503          	lbu	a0,0(s10)
ffffffffc020626e:	001d0413          	addi	s0,s10,1
ffffffffc0206272:	01350a63          	beq	a0,s3,ffffffffc0206286 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0206276:	c121                	beqz	a0,ffffffffc02062b6 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0206278:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020627a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020627c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020627e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0206282:	ff351ae3          	bne	a0,s3,ffffffffc0206276 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206286:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020628a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020628e:	4c81                	li	s9,0
ffffffffc0206290:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0206292:	5c7d                	li	s8,-1
ffffffffc0206294:	5dfd                	li	s11,-1
ffffffffc0206296:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020629a:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020629c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02062a0:	0ff5f593          	zext.b	a1,a1
ffffffffc02062a4:	00140d13          	addi	s10,s0,1
ffffffffc02062a8:	04b56263          	bltu	a0,a1,ffffffffc02062ec <vprintfmt+0xbc>
ffffffffc02062ac:	058a                	slli	a1,a1,0x2
ffffffffc02062ae:	95d6                	add	a1,a1,s5
ffffffffc02062b0:	4194                	lw	a3,0(a1)
ffffffffc02062b2:	96d6                	add	a3,a3,s5
ffffffffc02062b4:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02062b6:	70e6                	ld	ra,120(sp)
ffffffffc02062b8:	7446                	ld	s0,112(sp)
ffffffffc02062ba:	74a6                	ld	s1,104(sp)
ffffffffc02062bc:	7906                	ld	s2,96(sp)
ffffffffc02062be:	69e6                	ld	s3,88(sp)
ffffffffc02062c0:	6a46                	ld	s4,80(sp)
ffffffffc02062c2:	6aa6                	ld	s5,72(sp)
ffffffffc02062c4:	6b06                	ld	s6,64(sp)
ffffffffc02062c6:	7be2                	ld	s7,56(sp)
ffffffffc02062c8:	7c42                	ld	s8,48(sp)
ffffffffc02062ca:	7ca2                	ld	s9,40(sp)
ffffffffc02062cc:	7d02                	ld	s10,32(sp)
ffffffffc02062ce:	6de2                	ld	s11,24(sp)
ffffffffc02062d0:	6109                	addi	sp,sp,128
ffffffffc02062d2:	8082                	ret
            padc = '0';
ffffffffc02062d4:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02062d6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062da:	846a                	mv	s0,s10
ffffffffc02062dc:	00140d13          	addi	s10,s0,1
ffffffffc02062e0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02062e4:	0ff5f593          	zext.b	a1,a1
ffffffffc02062e8:	fcb572e3          	bgeu	a0,a1,ffffffffc02062ac <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02062ec:	85a6                	mv	a1,s1
ffffffffc02062ee:	02500513          	li	a0,37
ffffffffc02062f2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02062f4:	fff44783          	lbu	a5,-1(s0)
ffffffffc02062f8:	8d22                	mv	s10,s0
ffffffffc02062fa:	f73788e3          	beq	a5,s3,ffffffffc020626a <vprintfmt+0x3a>
ffffffffc02062fe:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0206302:	1d7d                	addi	s10,s10,-1
ffffffffc0206304:	ff379de3          	bne	a5,s3,ffffffffc02062fe <vprintfmt+0xce>
ffffffffc0206308:	b78d                	j	ffffffffc020626a <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020630a:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020630e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206312:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0206314:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0206318:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020631c:	02d86463          	bltu	a6,a3,ffffffffc0206344 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0206320:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0206324:	002c169b          	slliw	a3,s8,0x2
ffffffffc0206328:	0186873b          	addw	a4,a3,s8
ffffffffc020632c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0206330:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0206332:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0206336:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0206338:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020633c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206340:	fed870e3          	bgeu	a6,a3,ffffffffc0206320 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0206344:	f40ddce3          	bgez	s11,ffffffffc020629c <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0206348:	8de2                	mv	s11,s8
ffffffffc020634a:	5c7d                	li	s8,-1
ffffffffc020634c:	bf81                	j	ffffffffc020629c <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020634e:	fffdc693          	not	a3,s11
ffffffffc0206352:	96fd                	srai	a3,a3,0x3f
ffffffffc0206354:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206358:	00144603          	lbu	a2,1(s0)
ffffffffc020635c:	2d81                	sext.w	s11,s11
ffffffffc020635e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206360:	bf35                	j	ffffffffc020629c <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0206362:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206366:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020636a:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020636c:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020636e:	bfd9                	j	ffffffffc0206344 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0206370:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206372:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206376:	01174463          	blt	a4,a7,ffffffffc020637e <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020637a:	1a088e63          	beqz	a7,ffffffffc0206536 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020637e:	000a3603          	ld	a2,0(s4)
ffffffffc0206382:	46c1                	li	a3,16
ffffffffc0206384:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0206386:	2781                	sext.w	a5,a5
ffffffffc0206388:	876e                	mv	a4,s11
ffffffffc020638a:	85a6                	mv	a1,s1
ffffffffc020638c:	854a                	mv	a0,s2
ffffffffc020638e:	e37ff0ef          	jal	ra,ffffffffc02061c4 <printnum>
            break;
ffffffffc0206392:	bde1                	j	ffffffffc020626a <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0206394:	000a2503          	lw	a0,0(s4)
ffffffffc0206398:	85a6                	mv	a1,s1
ffffffffc020639a:	0a21                	addi	s4,s4,8
ffffffffc020639c:	9902                	jalr	s2
            break;
ffffffffc020639e:	b5f1                	j	ffffffffc020626a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02063a0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02063a2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02063a6:	01174463          	blt	a4,a7,ffffffffc02063ae <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02063aa:	18088163          	beqz	a7,ffffffffc020652c <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02063ae:	000a3603          	ld	a2,0(s4)
ffffffffc02063b2:	46a9                	li	a3,10
ffffffffc02063b4:	8a2e                	mv	s4,a1
ffffffffc02063b6:	bfc1                	j	ffffffffc0206386 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063b8:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02063bc:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063be:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02063c0:	bdf1                	j	ffffffffc020629c <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02063c2:	85a6                	mv	a1,s1
ffffffffc02063c4:	02500513          	li	a0,37
ffffffffc02063c8:	9902                	jalr	s2
            break;
ffffffffc02063ca:	b545                	j	ffffffffc020626a <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063cc:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02063d0:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063d2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02063d4:	b5e1                	j	ffffffffc020629c <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02063d6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02063d8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02063dc:	01174463          	blt	a4,a7,ffffffffc02063e4 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02063e0:	14088163          	beqz	a7,ffffffffc0206522 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02063e4:	000a3603          	ld	a2,0(s4)
ffffffffc02063e8:	46a1                	li	a3,8
ffffffffc02063ea:	8a2e                	mv	s4,a1
ffffffffc02063ec:	bf69                	j	ffffffffc0206386 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02063ee:	03000513          	li	a0,48
ffffffffc02063f2:	85a6                	mv	a1,s1
ffffffffc02063f4:	e03e                	sd	a5,0(sp)
ffffffffc02063f6:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02063f8:	85a6                	mv	a1,s1
ffffffffc02063fa:	07800513          	li	a0,120
ffffffffc02063fe:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206400:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0206402:	6782                	ld	a5,0(sp)
ffffffffc0206404:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206406:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020640a:	bfb5                	j	ffffffffc0206386 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020640c:	000a3403          	ld	s0,0(s4)
ffffffffc0206410:	008a0713          	addi	a4,s4,8
ffffffffc0206414:	e03a                	sd	a4,0(sp)
ffffffffc0206416:	14040263          	beqz	s0,ffffffffc020655a <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020641a:	0fb05763          	blez	s11,ffffffffc0206508 <vprintfmt+0x2d8>
ffffffffc020641e:	02d00693          	li	a3,45
ffffffffc0206422:	0cd79163          	bne	a5,a3,ffffffffc02064e4 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206426:	00044783          	lbu	a5,0(s0)
ffffffffc020642a:	0007851b          	sext.w	a0,a5
ffffffffc020642e:	cf85                	beqz	a5,ffffffffc0206466 <vprintfmt+0x236>
ffffffffc0206430:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206434:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206438:	000c4563          	bltz	s8,ffffffffc0206442 <vprintfmt+0x212>
ffffffffc020643c:	3c7d                	addiw	s8,s8,-1
ffffffffc020643e:	036c0263          	beq	s8,s6,ffffffffc0206462 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0206442:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206444:	0e0c8e63          	beqz	s9,ffffffffc0206540 <vprintfmt+0x310>
ffffffffc0206448:	3781                	addiw	a5,a5,-32
ffffffffc020644a:	0ef47b63          	bgeu	s0,a5,ffffffffc0206540 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020644e:	03f00513          	li	a0,63
ffffffffc0206452:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206454:	000a4783          	lbu	a5,0(s4)
ffffffffc0206458:	3dfd                	addiw	s11,s11,-1
ffffffffc020645a:	0a05                	addi	s4,s4,1
ffffffffc020645c:	0007851b          	sext.w	a0,a5
ffffffffc0206460:	ffe1                	bnez	a5,ffffffffc0206438 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0206462:	01b05963          	blez	s11,ffffffffc0206474 <vprintfmt+0x244>
ffffffffc0206466:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206468:	85a6                	mv	a1,s1
ffffffffc020646a:	02000513          	li	a0,32
ffffffffc020646e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206470:	fe0d9be3          	bnez	s11,ffffffffc0206466 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206474:	6a02                	ld	s4,0(sp)
ffffffffc0206476:	bbd5                	j	ffffffffc020626a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206478:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020647a:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020647e:	01174463          	blt	a4,a7,ffffffffc0206486 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0206482:	08088d63          	beqz	a7,ffffffffc020651c <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0206486:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020648a:	0a044d63          	bltz	s0,ffffffffc0206544 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020648e:	8622                	mv	a2,s0
ffffffffc0206490:	8a66                	mv	s4,s9
ffffffffc0206492:	46a9                	li	a3,10
ffffffffc0206494:	bdcd                	j	ffffffffc0206386 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0206496:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020649a:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc020649c:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020649e:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02064a2:	8fb5                	xor	a5,a5,a3
ffffffffc02064a4:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02064a8:	02d74163          	blt	a4,a3,ffffffffc02064ca <vprintfmt+0x29a>
ffffffffc02064ac:	00369793          	slli	a5,a3,0x3
ffffffffc02064b0:	97de                	add	a5,a5,s7
ffffffffc02064b2:	639c                	ld	a5,0(a5)
ffffffffc02064b4:	cb99                	beqz	a5,ffffffffc02064ca <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02064b6:	86be                	mv	a3,a5
ffffffffc02064b8:	00000617          	auipc	a2,0x0
ffffffffc02064bc:	13860613          	addi	a2,a2,312 # ffffffffc02065f0 <etext+0x28>
ffffffffc02064c0:	85a6                	mv	a1,s1
ffffffffc02064c2:	854a                	mv	a0,s2
ffffffffc02064c4:	0ce000ef          	jal	ra,ffffffffc0206592 <printfmt>
ffffffffc02064c8:	b34d                	j	ffffffffc020626a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02064ca:	00002617          	auipc	a2,0x2
ffffffffc02064ce:	4e660613          	addi	a2,a2,1254 # ffffffffc02089b0 <syscalls+0x120>
ffffffffc02064d2:	85a6                	mv	a1,s1
ffffffffc02064d4:	854a                	mv	a0,s2
ffffffffc02064d6:	0bc000ef          	jal	ra,ffffffffc0206592 <printfmt>
ffffffffc02064da:	bb41                	j	ffffffffc020626a <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02064dc:	00002417          	auipc	s0,0x2
ffffffffc02064e0:	4cc40413          	addi	s0,s0,1228 # ffffffffc02089a8 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02064e4:	85e2                	mv	a1,s8
ffffffffc02064e6:	8522                	mv	a0,s0
ffffffffc02064e8:	e43e                	sd	a5,8(sp)
ffffffffc02064ea:	c4fff0ef          	jal	ra,ffffffffc0206138 <strnlen>
ffffffffc02064ee:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02064f2:	01b05b63          	blez	s11,ffffffffc0206508 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02064f6:	67a2                	ld	a5,8(sp)
ffffffffc02064f8:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02064fc:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02064fe:	85a6                	mv	a1,s1
ffffffffc0206500:	8552                	mv	a0,s4
ffffffffc0206502:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206504:	fe0d9ce3          	bnez	s11,ffffffffc02064fc <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206508:	00044783          	lbu	a5,0(s0)
ffffffffc020650c:	00140a13          	addi	s4,s0,1
ffffffffc0206510:	0007851b          	sext.w	a0,a5
ffffffffc0206514:	d3a5                	beqz	a5,ffffffffc0206474 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206516:	05e00413          	li	s0,94
ffffffffc020651a:	bf39                	j	ffffffffc0206438 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020651c:	000a2403          	lw	s0,0(s4)
ffffffffc0206520:	b7ad                	j	ffffffffc020648a <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0206522:	000a6603          	lwu	a2,0(s4)
ffffffffc0206526:	46a1                	li	a3,8
ffffffffc0206528:	8a2e                	mv	s4,a1
ffffffffc020652a:	bdb1                	j	ffffffffc0206386 <vprintfmt+0x156>
ffffffffc020652c:	000a6603          	lwu	a2,0(s4)
ffffffffc0206530:	46a9                	li	a3,10
ffffffffc0206532:	8a2e                	mv	s4,a1
ffffffffc0206534:	bd89                	j	ffffffffc0206386 <vprintfmt+0x156>
ffffffffc0206536:	000a6603          	lwu	a2,0(s4)
ffffffffc020653a:	46c1                	li	a3,16
ffffffffc020653c:	8a2e                	mv	s4,a1
ffffffffc020653e:	b5a1                	j	ffffffffc0206386 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0206540:	9902                	jalr	s2
ffffffffc0206542:	bf09                	j	ffffffffc0206454 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0206544:	85a6                	mv	a1,s1
ffffffffc0206546:	02d00513          	li	a0,45
ffffffffc020654a:	e03e                	sd	a5,0(sp)
ffffffffc020654c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020654e:	6782                	ld	a5,0(sp)
ffffffffc0206550:	8a66                	mv	s4,s9
ffffffffc0206552:	40800633          	neg	a2,s0
ffffffffc0206556:	46a9                	li	a3,10
ffffffffc0206558:	b53d                	j	ffffffffc0206386 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020655a:	03b05163          	blez	s11,ffffffffc020657c <vprintfmt+0x34c>
ffffffffc020655e:	02d00693          	li	a3,45
ffffffffc0206562:	f6d79de3          	bne	a5,a3,ffffffffc02064dc <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0206566:	00002417          	auipc	s0,0x2
ffffffffc020656a:	44240413          	addi	s0,s0,1090 # ffffffffc02089a8 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020656e:	02800793          	li	a5,40
ffffffffc0206572:	02800513          	li	a0,40
ffffffffc0206576:	00140a13          	addi	s4,s0,1
ffffffffc020657a:	bd6d                	j	ffffffffc0206434 <vprintfmt+0x204>
ffffffffc020657c:	00002a17          	auipc	s4,0x2
ffffffffc0206580:	42da0a13          	addi	s4,s4,1069 # ffffffffc02089a9 <syscalls+0x119>
ffffffffc0206584:	02800513          	li	a0,40
ffffffffc0206588:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020658c:	05e00413          	li	s0,94
ffffffffc0206590:	b565                	j	ffffffffc0206438 <vprintfmt+0x208>

ffffffffc0206592 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206592:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0206594:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206598:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020659a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020659c:	ec06                	sd	ra,24(sp)
ffffffffc020659e:	f83a                	sd	a4,48(sp)
ffffffffc02065a0:	fc3e                	sd	a5,56(sp)
ffffffffc02065a2:	e0c2                	sd	a6,64(sp)
ffffffffc02065a4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02065a6:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02065a8:	c89ff0ef          	jal	ra,ffffffffc0206230 <vprintfmt>
}
ffffffffc02065ac:	60e2                	ld	ra,24(sp)
ffffffffc02065ae:	6161                	addi	sp,sp,80
ffffffffc02065b0:	8082                	ret

ffffffffc02065b2 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02065b2:	9e3707b7          	lui	a5,0x9e370
ffffffffc02065b6:	2785                	addiw	a5,a5,1
ffffffffc02065b8:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc02065bc:	02000793          	li	a5,32
ffffffffc02065c0:	9f8d                	subw	a5,a5,a1
}
ffffffffc02065c2:	00f5553b          	srlw	a0,a0,a5
ffffffffc02065c6:	8082                	ret
