
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
ffffffffc020004a:	27e060ef          	jal	ra,ffffffffc02062c8 <memset>
    cons_init();                // init the console
ffffffffc020004e:	580000ef          	jal	ra,ffffffffc02005ce <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	6a658593          	addi	a1,a1,1702 # ffffffffc02066f8 <etext+0x2>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	6be50513          	addi	a0,a0,1726 # ffffffffc0206718 <etext+0x22>
ffffffffc0200062:	06a000ef          	jal	ra,ffffffffc02000cc <cprintf>

    print_kerninfo();
ffffffffc0200066:	24e000ef          	jal	ra,ffffffffc02002b4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	7d7030ef          	jal	ra,ffffffffc0204040 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5d2000ef          	jal	ra,ffffffffc0200640 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5dc000ef          	jal	ra,ffffffffc020064e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	494010ef          	jal	ra,ffffffffc020150a <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	635050ef          	jal	ra,ffffffffc0205eae <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	4a8000ef          	jal	ra,ffffffffc0200526 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	350020ef          	jal	ra,ffffffffc02023d2 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	4f6000ef          	jal	ra,ffffffffc020057c <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	5b8000ef          	jal	ra,ffffffffc0200642 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	7b9050ef          	jal	ra,ffffffffc0206046 <cpu_idle>

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
ffffffffc02000c0:	29e060ef          	jal	ra,ffffffffc020635e <vprintfmt>
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
ffffffffc02000f6:	268060ef          	jal	ra,ffffffffc020635e <vprintfmt>
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
ffffffffc020016e:	5b650513          	addi	a0,a0,1462 # ffffffffc0206720 <etext+0x2a>
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
ffffffffc020023a:	4f250513          	addi	a0,a0,1266 # ffffffffc0206728 <etext+0x32>
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
ffffffffc0200250:	0b450513          	addi	a0,a0,180 # ffffffffc0208300 <default_pmm_manager+0x3b8>
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
ffffffffc0200284:	4c850513          	addi	a0,a0,1224 # ffffffffc0206748 <etext+0x52>
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
ffffffffc02002a4:	06050513          	addi	a0,a0,96 # ffffffffc0208300 <default_pmm_manager+0x3b8>
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
ffffffffc02002ba:	4b250513          	addi	a0,a0,1202 # ffffffffc0206768 <etext+0x72>
void print_kerninfo(void) {
ffffffffc02002be:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002c0:	e0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002c4:	00000597          	auipc	a1,0x0
ffffffffc02002c8:	d6e58593          	addi	a1,a1,-658 # ffffffffc0200032 <kern_init>
ffffffffc02002cc:	00006517          	auipc	a0,0x6
ffffffffc02002d0:	4bc50513          	addi	a0,a0,1212 # ffffffffc0206788 <etext+0x92>
ffffffffc02002d4:	df9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002d8:	00006597          	auipc	a1,0x6
ffffffffc02002dc:	41e58593          	addi	a1,a1,1054 # ffffffffc02066f6 <etext>
ffffffffc02002e0:	00006517          	auipc	a0,0x6
ffffffffc02002e4:	4c850513          	addi	a0,a0,1224 # ffffffffc02067a8 <etext+0xb2>
ffffffffc02002e8:	de5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002ec:	000a7597          	auipc	a1,0xa7
ffffffffc02002f0:	01458593          	addi	a1,a1,20 # ffffffffc02a7300 <buf>
ffffffffc02002f4:	00006517          	auipc	a0,0x6
ffffffffc02002f8:	4d450513          	addi	a0,a0,1236 # ffffffffc02067c8 <etext+0xd2>
ffffffffc02002fc:	dd1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200300:	000b2597          	auipc	a1,0xb2
ffffffffc0200304:	55c58593          	addi	a1,a1,1372 # ffffffffc02b285c <end>
ffffffffc0200308:	00006517          	auipc	a0,0x6
ffffffffc020030c:	4e050513          	addi	a0,a0,1248 # ffffffffc02067e8 <etext+0xf2>
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
ffffffffc020033a:	4d250513          	addi	a0,a0,1234 # ffffffffc0206808 <etext+0x112>
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
ffffffffc0200348:	4f460613          	addi	a2,a2,1268 # ffffffffc0206838 <etext+0x142>
ffffffffc020034c:	04d00593          	li	a1,77
ffffffffc0200350:	00006517          	auipc	a0,0x6
ffffffffc0200354:	50050513          	addi	a0,a0,1280 # ffffffffc0206850 <etext+0x15a>
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
ffffffffc0200364:	50860613          	addi	a2,a2,1288 # ffffffffc0206868 <etext+0x172>
ffffffffc0200368:	00006597          	auipc	a1,0x6
ffffffffc020036c:	52058593          	addi	a1,a1,1312 # ffffffffc0206888 <etext+0x192>
ffffffffc0200370:	00006517          	auipc	a0,0x6
ffffffffc0200374:	52050513          	addi	a0,a0,1312 # ffffffffc0206890 <etext+0x19a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200378:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020037a:	d53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020037e:	00006617          	auipc	a2,0x6
ffffffffc0200382:	52260613          	addi	a2,a2,1314 # ffffffffc02068a0 <etext+0x1aa>
ffffffffc0200386:	00006597          	auipc	a1,0x6
ffffffffc020038a:	54258593          	addi	a1,a1,1346 # ffffffffc02068c8 <etext+0x1d2>
ffffffffc020038e:	00006517          	auipc	a0,0x6
ffffffffc0200392:	50250513          	addi	a0,a0,1282 # ffffffffc0206890 <etext+0x19a>
ffffffffc0200396:	d37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020039a:	00006617          	auipc	a2,0x6
ffffffffc020039e:	53e60613          	addi	a2,a2,1342 # ffffffffc02068d8 <etext+0x1e2>
ffffffffc02003a2:	00006597          	auipc	a1,0x6
ffffffffc02003a6:	55658593          	addi	a1,a1,1366 # ffffffffc02068f8 <etext+0x202>
ffffffffc02003aa:	00006517          	auipc	a0,0x6
ffffffffc02003ae:	4e650513          	addi	a0,a0,1254 # ffffffffc0206890 <etext+0x19a>
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
ffffffffc02003e8:	52450513          	addi	a0,a0,1316 # ffffffffc0206908 <etext+0x212>
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
ffffffffc020040a:	52a50513          	addi	a0,a0,1322 # ffffffffc0206930 <etext+0x23a>
ffffffffc020040e:	cbfff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    if (tf != NULL) {
ffffffffc0200412:	000b8563          	beqz	s7,ffffffffc020041c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200416:	855e                	mv	a0,s7
ffffffffc0200418:	41e000ef          	jal	ra,ffffffffc0200836 <print_trapframe>
ffffffffc020041c:	00006c17          	auipc	s8,0x6
ffffffffc0200420:	584c0c13          	addi	s8,s8,1412 # ffffffffc02069a0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200424:	00006917          	auipc	s2,0x6
ffffffffc0200428:	53490913          	addi	s2,s2,1332 # ffffffffc0206958 <etext+0x262>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020042c:	00006497          	auipc	s1,0x6
ffffffffc0200430:	53448493          	addi	s1,s1,1332 # ffffffffc0206960 <etext+0x26a>
        if (argc == MAXARGS - 1) {
ffffffffc0200434:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200436:	00006b17          	auipc	s6,0x6
ffffffffc020043a:	532b0b13          	addi	s6,s6,1330 # ffffffffc0206968 <etext+0x272>
        argv[argc ++] = buf;
ffffffffc020043e:	00006a17          	auipc	s4,0x6
ffffffffc0200442:	44aa0a13          	addi	s4,s4,1098 # ffffffffc0206888 <etext+0x192>
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
ffffffffc0200464:	540d0d13          	addi	s10,s10,1344 # ffffffffc02069a0 <commands>
        argv[argc ++] = buf;
ffffffffc0200468:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020046a:	4401                	li	s0,0
ffffffffc020046c:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020046e:	627050ef          	jal	ra,ffffffffc0206294 <strcmp>
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
ffffffffc0200482:	613050ef          	jal	ra,ffffffffc0206294 <strcmp>
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
ffffffffc02004c0:	5f3050ef          	jal	ra,ffffffffc02062b2 <strchr>
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
ffffffffc02004fe:	5b5050ef          	jal	ra,ffffffffc02062b2 <strchr>
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
ffffffffc020051c:	47050513          	addi	a0,a0,1136 # ffffffffc0206988 <etext+0x292>
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
ffffffffc020054c:	58f050ef          	jal	ra,ffffffffc02062da <memcpy>
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
ffffffffc0200570:	56b050ef          	jal	ra,ffffffffc02062da <memcpy>
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
ffffffffc02005a6:	44650513          	addi	a0,a0,1094 # ffffffffc02069e8 <commands+0x48>
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
ffffffffc0200674:	39850513          	addi	a0,a0,920 # ffffffffc0206a08 <commands+0x68>
void print_regs(struct pushregs* gpr) {
ffffffffc0200678:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067a:	a53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020067e:	640c                	ld	a1,8(s0)
ffffffffc0200680:	00006517          	auipc	a0,0x6
ffffffffc0200684:	3a050513          	addi	a0,a0,928 # ffffffffc0206a20 <commands+0x80>
ffffffffc0200688:	a45ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020068c:	680c                	ld	a1,16(s0)
ffffffffc020068e:	00006517          	auipc	a0,0x6
ffffffffc0200692:	3aa50513          	addi	a0,a0,938 # ffffffffc0206a38 <commands+0x98>
ffffffffc0200696:	a37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069a:	6c0c                	ld	a1,24(s0)
ffffffffc020069c:	00006517          	auipc	a0,0x6
ffffffffc02006a0:	3b450513          	addi	a0,a0,948 # ffffffffc0206a50 <commands+0xb0>
ffffffffc02006a4:	a29ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a8:	700c                	ld	a1,32(s0)
ffffffffc02006aa:	00006517          	auipc	a0,0x6
ffffffffc02006ae:	3be50513          	addi	a0,a0,958 # ffffffffc0206a68 <commands+0xc8>
ffffffffc02006b2:	a1bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b6:	740c                	ld	a1,40(s0)
ffffffffc02006b8:	00006517          	auipc	a0,0x6
ffffffffc02006bc:	3c850513          	addi	a0,a0,968 # ffffffffc0206a80 <commands+0xe0>
ffffffffc02006c0:	a0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c4:	780c                	ld	a1,48(s0)
ffffffffc02006c6:	00006517          	auipc	a0,0x6
ffffffffc02006ca:	3d250513          	addi	a0,a0,978 # ffffffffc0206a98 <commands+0xf8>
ffffffffc02006ce:	9ffff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d2:	7c0c                	ld	a1,56(s0)
ffffffffc02006d4:	00006517          	auipc	a0,0x6
ffffffffc02006d8:	3dc50513          	addi	a0,a0,988 # ffffffffc0206ab0 <commands+0x110>
ffffffffc02006dc:	9f1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e0:	602c                	ld	a1,64(s0)
ffffffffc02006e2:	00006517          	auipc	a0,0x6
ffffffffc02006e6:	3e650513          	addi	a0,a0,998 # ffffffffc0206ac8 <commands+0x128>
ffffffffc02006ea:	9e3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ee:	642c                	ld	a1,72(s0)
ffffffffc02006f0:	00006517          	auipc	a0,0x6
ffffffffc02006f4:	3f050513          	addi	a0,a0,1008 # ffffffffc0206ae0 <commands+0x140>
ffffffffc02006f8:	9d5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006fc:	682c                	ld	a1,80(s0)
ffffffffc02006fe:	00006517          	auipc	a0,0x6
ffffffffc0200702:	3fa50513          	addi	a0,a0,1018 # ffffffffc0206af8 <commands+0x158>
ffffffffc0200706:	9c7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070a:	6c2c                	ld	a1,88(s0)
ffffffffc020070c:	00006517          	auipc	a0,0x6
ffffffffc0200710:	40450513          	addi	a0,a0,1028 # ffffffffc0206b10 <commands+0x170>
ffffffffc0200714:	9b9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200718:	702c                	ld	a1,96(s0)
ffffffffc020071a:	00006517          	auipc	a0,0x6
ffffffffc020071e:	40e50513          	addi	a0,a0,1038 # ffffffffc0206b28 <commands+0x188>
ffffffffc0200722:	9abff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200726:	742c                	ld	a1,104(s0)
ffffffffc0200728:	00006517          	auipc	a0,0x6
ffffffffc020072c:	41850513          	addi	a0,a0,1048 # ffffffffc0206b40 <commands+0x1a0>
ffffffffc0200730:	99dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200734:	782c                	ld	a1,112(s0)
ffffffffc0200736:	00006517          	auipc	a0,0x6
ffffffffc020073a:	42250513          	addi	a0,a0,1058 # ffffffffc0206b58 <commands+0x1b8>
ffffffffc020073e:	98fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200742:	7c2c                	ld	a1,120(s0)
ffffffffc0200744:	00006517          	auipc	a0,0x6
ffffffffc0200748:	42c50513          	addi	a0,a0,1068 # ffffffffc0206b70 <commands+0x1d0>
ffffffffc020074c:	981ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200750:	604c                	ld	a1,128(s0)
ffffffffc0200752:	00006517          	auipc	a0,0x6
ffffffffc0200756:	43650513          	addi	a0,a0,1078 # ffffffffc0206b88 <commands+0x1e8>
ffffffffc020075a:	973ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020075e:	644c                	ld	a1,136(s0)
ffffffffc0200760:	00006517          	auipc	a0,0x6
ffffffffc0200764:	44050513          	addi	a0,a0,1088 # ffffffffc0206ba0 <commands+0x200>
ffffffffc0200768:	965ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020076c:	684c                	ld	a1,144(s0)
ffffffffc020076e:	00006517          	auipc	a0,0x6
ffffffffc0200772:	44a50513          	addi	a0,a0,1098 # ffffffffc0206bb8 <commands+0x218>
ffffffffc0200776:	957ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077a:	6c4c                	ld	a1,152(s0)
ffffffffc020077c:	00006517          	auipc	a0,0x6
ffffffffc0200780:	45450513          	addi	a0,a0,1108 # ffffffffc0206bd0 <commands+0x230>
ffffffffc0200784:	949ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200788:	704c                	ld	a1,160(s0)
ffffffffc020078a:	00006517          	auipc	a0,0x6
ffffffffc020078e:	45e50513          	addi	a0,a0,1118 # ffffffffc0206be8 <commands+0x248>
ffffffffc0200792:	93bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200796:	744c                	ld	a1,168(s0)
ffffffffc0200798:	00006517          	auipc	a0,0x6
ffffffffc020079c:	46850513          	addi	a0,a0,1128 # ffffffffc0206c00 <commands+0x260>
ffffffffc02007a0:	92dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a4:	784c                	ld	a1,176(s0)
ffffffffc02007a6:	00006517          	auipc	a0,0x6
ffffffffc02007aa:	47250513          	addi	a0,a0,1138 # ffffffffc0206c18 <commands+0x278>
ffffffffc02007ae:	91fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b2:	7c4c                	ld	a1,184(s0)
ffffffffc02007b4:	00006517          	auipc	a0,0x6
ffffffffc02007b8:	47c50513          	addi	a0,a0,1148 # ffffffffc0206c30 <commands+0x290>
ffffffffc02007bc:	911ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c0:	606c                	ld	a1,192(s0)
ffffffffc02007c2:	00006517          	auipc	a0,0x6
ffffffffc02007c6:	48650513          	addi	a0,a0,1158 # ffffffffc0206c48 <commands+0x2a8>
ffffffffc02007ca:	903ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ce:	646c                	ld	a1,200(s0)
ffffffffc02007d0:	00006517          	auipc	a0,0x6
ffffffffc02007d4:	49050513          	addi	a0,a0,1168 # ffffffffc0206c60 <commands+0x2c0>
ffffffffc02007d8:	8f5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007dc:	686c                	ld	a1,208(s0)
ffffffffc02007de:	00006517          	auipc	a0,0x6
ffffffffc02007e2:	49a50513          	addi	a0,a0,1178 # ffffffffc0206c78 <commands+0x2d8>
ffffffffc02007e6:	8e7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ea:	6c6c                	ld	a1,216(s0)
ffffffffc02007ec:	00006517          	auipc	a0,0x6
ffffffffc02007f0:	4a450513          	addi	a0,a0,1188 # ffffffffc0206c90 <commands+0x2f0>
ffffffffc02007f4:	8d9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f8:	706c                	ld	a1,224(s0)
ffffffffc02007fa:	00006517          	auipc	a0,0x6
ffffffffc02007fe:	4ae50513          	addi	a0,a0,1198 # ffffffffc0206ca8 <commands+0x308>
ffffffffc0200802:	8cbff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200806:	746c                	ld	a1,232(s0)
ffffffffc0200808:	00006517          	auipc	a0,0x6
ffffffffc020080c:	4b850513          	addi	a0,a0,1208 # ffffffffc0206cc0 <commands+0x320>
ffffffffc0200810:	8bdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200814:	786c                	ld	a1,240(s0)
ffffffffc0200816:	00006517          	auipc	a0,0x6
ffffffffc020081a:	4c250513          	addi	a0,a0,1218 # ffffffffc0206cd8 <commands+0x338>
ffffffffc020081e:	8afff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200824:	6402                	ld	s0,0(sp)
ffffffffc0200826:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200828:	00006517          	auipc	a0,0x6
ffffffffc020082c:	4c850513          	addi	a0,a0,1224 # ffffffffc0206cf0 <commands+0x350>
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
ffffffffc0200842:	4ca50513          	addi	a0,a0,1226 # ffffffffc0206d08 <commands+0x368>
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
ffffffffc020085a:	4ca50513          	addi	a0,a0,1226 # ffffffffc0206d20 <commands+0x380>
ffffffffc020085e:	86fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200862:	10843583          	ld	a1,264(s0)
ffffffffc0200866:	00006517          	auipc	a0,0x6
ffffffffc020086a:	4d250513          	addi	a0,a0,1234 # ffffffffc0206d38 <commands+0x398>
ffffffffc020086e:	85fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200872:	11043583          	ld	a1,272(s0)
ffffffffc0200876:	00006517          	auipc	a0,0x6
ffffffffc020087a:	4da50513          	addi	a0,a0,1242 # ffffffffc0206d50 <commands+0x3b0>
ffffffffc020087e:	84fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200882:	11843583          	ld	a1,280(s0)
}
ffffffffc0200886:	6402                	ld	s0,0(sp)
ffffffffc0200888:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088a:	00006517          	auipc	a0,0x6
ffffffffc020088e:	4d650513          	addi	a0,a0,1238 # ffffffffc0206d60 <commands+0x3c0>
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
ffffffffc02008d6:	4a650513          	addi	a0,a0,1190 # ffffffffc0206d78 <commands+0x3d8>
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
ffffffffc0200906:	1440106f          	j	ffffffffc0201a4a <do_pgfault>
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
ffffffffc020093a:	1100106f          	j	ffffffffc0201a4a <do_pgfault>
        assert(current == idleproc);
ffffffffc020093e:	00006697          	auipc	a3,0x6
ffffffffc0200942:	45a68693          	addi	a3,a3,1114 # ffffffffc0206d98 <commands+0x3f8>
ffffffffc0200946:	00006617          	auipc	a2,0x6
ffffffffc020094a:	46a60613          	addi	a2,a2,1130 # ffffffffc0206db0 <commands+0x410>
ffffffffc020094e:	06b00593          	li	a1,107
ffffffffc0200952:	00006517          	auipc	a0,0x6
ffffffffc0200956:	47650513          	addi	a0,a0,1142 # ffffffffc0206dc8 <commands+0x428>
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
ffffffffc020098c:	3f050513          	addi	a0,a0,1008 # ffffffffc0206d78 <commands+0x3d8>
ffffffffc0200990:	f3cff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200994:	00006617          	auipc	a2,0x6
ffffffffc0200998:	44c60613          	addi	a2,a2,1100 # ffffffffc0206de0 <commands+0x440>
ffffffffc020099c:	07200593          	li	a1,114
ffffffffc02009a0:	00006517          	auipc	a0,0x6
ffffffffc02009a4:	42850513          	addi	a0,a0,1064 # ffffffffc0206dc8 <commands+0x428>
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
ffffffffc02009c4:	4d870713          	addi	a4,a4,1240 # ffffffffc0206e98 <commands+0x4f8>
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
ffffffffc02009d6:	48650513          	addi	a0,a0,1158 # ffffffffc0206e58 <commands+0x4b8>
ffffffffc02009da:	ef2ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009de:	00006517          	auipc	a0,0x6
ffffffffc02009e2:	45a50513          	addi	a0,a0,1114 # ffffffffc0206e38 <commands+0x498>
ffffffffc02009e6:	ee6ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009ea:	00006517          	auipc	a0,0x6
ffffffffc02009ee:	40e50513          	addi	a0,a0,1038 # ffffffffc0206df8 <commands+0x458>
ffffffffc02009f2:	edaff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009f6:	00006517          	auipc	a0,0x6
ffffffffc02009fa:	42250513          	addi	a0,a0,1058 # ffffffffc0206e18 <commands+0x478>
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
ffffffffc0200a3a:	44250513          	addi	a0,a0,1090 # ffffffffc0206e78 <commands+0x4d8>
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
ffffffffc0200a5c:	60870713          	addi	a4,a4,1544 # ffffffffc0207060 <commands+0x6c0>
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
ffffffffc0200a6e:	54e50513          	addi	a0,a0,1358 # ffffffffc0206fb8 <commands+0x618>
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
ffffffffc0200a88:	7440506f          	j	ffffffffc02061cc <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a8c:	00006517          	auipc	a0,0x6
ffffffffc0200a90:	54c50513          	addi	a0,a0,1356 # ffffffffc0206fd8 <commands+0x638>
}
ffffffffc0200a94:	6442                	ld	s0,16(sp)
ffffffffc0200a96:	60e2                	ld	ra,24(sp)
ffffffffc0200a98:	64a2                	ld	s1,8(sp)
ffffffffc0200a9a:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a9c:	e30ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200aa0:	00006517          	auipc	a0,0x6
ffffffffc0200aa4:	55850513          	addi	a0,a0,1368 # ffffffffc0206ff8 <commands+0x658>
ffffffffc0200aa8:	b7f5                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200aaa:	00006517          	auipc	a0,0x6
ffffffffc0200aae:	56e50513          	addi	a0,a0,1390 # ffffffffc0207018 <commands+0x678>
ffffffffc0200ab2:	b7cd                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ab4:	00006517          	auipc	a0,0x6
ffffffffc0200ab8:	57c50513          	addi	a0,a0,1404 # ffffffffc0207030 <commands+0x690>
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
ffffffffc0200ada:	57250513          	addi	a0,a0,1394 # ffffffffc0207048 <commands+0x6a8>
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
ffffffffc0200af8:	47460613          	addi	a2,a2,1140 # ffffffffc0206f68 <commands+0x5c8>
ffffffffc0200afc:	0f800593          	li	a1,248
ffffffffc0200b00:	00006517          	auipc	a0,0x6
ffffffffc0200b04:	2c850513          	addi	a0,a0,712 # ffffffffc0206dc8 <commands+0x428>
ffffffffc0200b08:	f00ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b0c:	00006517          	auipc	a0,0x6
ffffffffc0200b10:	3bc50513          	addi	a0,a0,956 # ffffffffc0206ec8 <commands+0x528>
ffffffffc0200b14:	b741                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b16:	00006517          	auipc	a0,0x6
ffffffffc0200b1a:	3d250513          	addi	a0,a0,978 # ffffffffc0206ee8 <commands+0x548>
ffffffffc0200b1e:	bf9d                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b20:	00006517          	auipc	a0,0x6
ffffffffc0200b24:	3e850513          	addi	a0,a0,1000 # ffffffffc0206f08 <commands+0x568>
ffffffffc0200b28:	b7b5                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b2a:	00006517          	auipc	a0,0x6
ffffffffc0200b2e:	3f650513          	addi	a0,a0,1014 # ffffffffc0206f20 <commands+0x580>
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
ffffffffc0200b48:	684050ef          	jal	ra,ffffffffc02061cc <syscall>
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
ffffffffc0200b6a:	3ca50513          	addi	a0,a0,970 # ffffffffc0206f30 <commands+0x590>
ffffffffc0200b6e:	b71d                	j	ffffffffc0200a94 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b70:	00006517          	auipc	a0,0x6
ffffffffc0200b74:	3e050513          	addi	a0,a0,992 # ffffffffc0206f50 <commands+0x5b0>
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
ffffffffc0200b92:	3da60613          	addi	a2,a2,986 # ffffffffc0206f68 <commands+0x5c8>
ffffffffc0200b96:	0cd00593          	li	a1,205
ffffffffc0200b9a:	00006517          	auipc	a0,0x6
ffffffffc0200b9e:	22e50513          	addi	a0,a0,558 # ffffffffc0206dc8 <commands+0x428>
ffffffffc0200ba2:	e66ff0ef          	jal	ra,ffffffffc0200208 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200ba6:	00006517          	auipc	a0,0x6
ffffffffc0200baa:	3fa50513          	addi	a0,a0,1018 # ffffffffc0206fa0 <commands+0x600>
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
ffffffffc0200bca:	3a260613          	addi	a2,a2,930 # ffffffffc0206f68 <commands+0x5c8>
ffffffffc0200bce:	0d700593          	li	a1,215
ffffffffc0200bd2:	00006517          	auipc	a0,0x6
ffffffffc0200bd6:	1f650513          	addi	a0,a0,502 # ffffffffc0206dc8 <commands+0x428>
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
ffffffffc0200bee:	39e60613          	addi	a2,a2,926 # ffffffffc0206f88 <commands+0x5e8>
ffffffffc0200bf2:	0d100593          	li	a1,209
ffffffffc0200bf6:	00006517          	auipc	a0,0x6
ffffffffc0200bfa:	1d250513          	addi	a0,a0,466 # ffffffffc0206dc8 <commands+0x428>
ffffffffc0200bfe:	e0aff0ef          	jal	ra,ffffffffc0200208 <__panic>
                print_trapframe(tf);
ffffffffc0200c02:	8522                	mv	a0,s0
ffffffffc0200c04:	c33ff0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c08:	86a6                	mv	a3,s1
ffffffffc0200c0a:	00006617          	auipc	a2,0x6
ffffffffc0200c0e:	35e60613          	addi	a2,a2,862 # ffffffffc0206f68 <commands+0x5c8>
ffffffffc0200c12:	0f100593          	li	a1,241
ffffffffc0200c16:	00006517          	auipc	a0,0x6
ffffffffc0200c1a:	1b250513          	addi	a0,a0,434 # ffffffffc0206dc8 <commands+0x428>
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
ffffffffc0200c9e:	4420506f          	j	ffffffffc02060e0 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200ca2:	555d                	li	a0,-9
ffffffffc0200ca4:	7f0040ef          	jal	ra,ffffffffc0205494 <do_exit>
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
ffffffffc0200e2c:	27850513          	addi	a0,a0,632 # ffffffffc02070a0 <commands+0x700>
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
ffffffffc0200e4c:	a80ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
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
ffffffffc0200e74:	9b0b8b93          	addi	s7,s7,-1616 # ffffffffc02b2820 <npage>
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200e78:	000b2b17          	auipc	s6,0xb2
ffffffffc0200e7c:	9b0b0b13          	addi	s6,s6,-1616 # ffffffffc02b2828 <pages>
ffffffffc0200e80:	00008a97          	auipc	s5,0x8
ffffffffc0200e84:	fc8a8a93          	addi	s5,s5,-56 # ffffffffc0208e48 <nbase>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0200e88:	00200cb7          	lui	s9,0x200
ffffffffc0200e8c:	ffe00c37          	lui	s8,0xffe00
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0200e90:	4601                	li	a2,0
ffffffffc0200e92:	85ea                	mv	a1,s10
ffffffffc0200e94:	854a                	mv	a0,s2
ffffffffc0200e96:	21b020ef          	jal	ra,ffffffffc02038b0 <get_pte>
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
ffffffffc0200ece:	1e3020ef          	jal	ra,ffffffffc02038b0 <get_pte>
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
ffffffffc0200f06:	044030ef          	jal	ra,ffffffffc0203f4a <page_insert>
            assert(ret == 0);
ffffffffc0200f0a:	dd49                	beqz	a0,ffffffffc0200ea4 <shared_read_state+0x82>
ffffffffc0200f0c:	00006697          	auipc	a3,0x6
ffffffffc0200f10:	28468693          	addi	a3,a3,644 # ffffffffc0207190 <commands+0x7f0>
ffffffffc0200f14:	00006617          	auipc	a2,0x6
ffffffffc0200f18:	e9c60613          	addi	a2,a2,-356 # ffffffffc0206db0 <commands+0x410>
ffffffffc0200f1c:	02f00593          	li	a1,47
ffffffffc0200f20:	00006517          	auipc	a0,0x6
ffffffffc0200f24:	1e050513          	addi	a0,a0,480 # ffffffffc0207100 <commands+0x760>
ffffffffc0200f28:	ae0ff0ef          	jal	ra,ffffffffc0200208 <__panic>
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
ffffffffc0200f44:	24068693          	addi	a3,a3,576 # ffffffffc0207180 <commands+0x7e0>
ffffffffc0200f48:	00006617          	auipc	a2,0x6
ffffffffc0200f4c:	e6860613          	addi	a2,a2,-408 # ffffffffc0206db0 <commands+0x410>
ffffffffc0200f50:	02c00593          	li	a1,44
ffffffffc0200f54:	00006517          	auipc	a0,0x6
ffffffffc0200f58:	1ac50513          	addi	a0,a0,428 # ffffffffc0207100 <commands+0x760>
ffffffffc0200f5c:	aacff0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200f60:	00006617          	auipc	a2,0x6
ffffffffc0200f64:	20060613          	addi	a2,a2,512 # ffffffffc0207160 <commands+0x7c0>
ffffffffc0200f68:	06200593          	li	a1,98
ffffffffc0200f6c:	00006517          	auipc	a0,0x6
ffffffffc0200f70:	1e450513          	addi	a0,a0,484 # ffffffffc0207150 <commands+0x7b0>
ffffffffc0200f74:	a94ff0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0200f78:	00006697          	auipc	a3,0x6
ffffffffc0200f7c:	19868693          	addi	a3,a3,408 # ffffffffc0207110 <commands+0x770>
ffffffffc0200f80:	00006617          	auipc	a2,0x6
ffffffffc0200f84:	e3060613          	addi	a2,a2,-464 # ffffffffc0206db0 <commands+0x410>
ffffffffc0200f88:	45d1                	li	a1,20
ffffffffc0200f8a:	00006517          	auipc	a0,0x6
ffffffffc0200f8e:	17650513          	addi	a0,a0,374 # ffffffffc0207100 <commands+0x760>
ffffffffc0200f92:	a76ff0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0200f96:	00006617          	auipc	a2,0x6
ffffffffc0200f9a:	19260613          	addi	a2,a2,402 # ffffffffc0207128 <commands+0x788>
ffffffffc0200f9e:	07400593          	li	a1,116
ffffffffc0200fa2:	00006517          	auipc	a0,0x6
ffffffffc0200fa6:	1ae50513          	addi	a0,a0,430 # ffffffffc0207150 <commands+0x7b0>
ffffffffc0200faa:	a5eff0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0200fae:	00006697          	auipc	a3,0x6
ffffffffc0200fb2:	12268693          	addi	a3,a3,290 # ffffffffc02070d0 <commands+0x730>
ffffffffc0200fb6:	00006617          	auipc	a2,0x6
ffffffffc0200fba:	dfa60613          	addi	a2,a2,-518 # ffffffffc0206db0 <commands+0x410>
ffffffffc0200fbe:	45cd                	li	a1,19
ffffffffc0200fc0:	00006517          	auipc	a0,0x6
ffffffffc0200fc4:	14050513          	addi	a0,a0,320 # ffffffffc0207100 <commands+0x760>
ffffffffc0200fc8:	a40ff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0200fcc <privated_write_state>:

int privated_write_state(struct mm_struct *mm, uint_t error_code, uintptr_t addr)
{
ffffffffc0200fcc:	715d                	addi	sp,sp,-80
ffffffffc0200fce:	f84a                	sd	s2,48(sp)
ffffffffc0200fd0:	892a                	mv	s2,a0
    cprintf("COW:由共享只读状态变为私有可写状态\n");
ffffffffc0200fd2:	00006517          	auipc	a0,0x6
ffffffffc0200fd6:	1ce50513          	addi	a0,a0,462 # ffffffffc02071a0 <commands+0x800>
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
ffffffffc0200fee:	8deff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0200ff2:	01893503          	ld	a0,24(s2)
ffffffffc0200ff6:	85a6                	mv	a1,s1
ffffffffc0200ff8:	4601                	li	a2,0
ffffffffc0200ffa:	0b7020ef          	jal	ra,ffffffffc02038b0 <get_pte>
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
ffffffffc0201010:	814b8b93          	addi	s7,s7,-2028 # ffffffffc02b2820 <npage>
ffffffffc0201014:	000bb703          	ld	a4,0(s7)
ffffffffc0201018:	01b7f993          	andi	s3,a5,27
    return pa2page(PTE_ADDR(pte));
ffffffffc020101c:	078a                	slli	a5,a5,0x2
ffffffffc020101e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201020:	0ee7ff63          	bgeu	a5,a4,ffffffffc020111e <privated_write_state+0x152>
    return &pages[PPN(pa) - nbase];
ffffffffc0201024:	000b2c17          	auipc	s8,0xb2
ffffffffc0201028:	804c0c13          	addi	s8,s8,-2044 # ffffffffc02b2828 <pages>
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
ffffffffc0201044:	760020ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
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
ffffffffc0201084:	7b853503          	ld	a0,1976(a0) # ffffffffc02b2838 <va_pa_offset>
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
ffffffffc0201098:	242050ef          	jal	ra,ffffffffc02062da <memcpy>
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
ffffffffc02010c0:	68b0206f          	j	ffffffffc0203f4a <page_insert>
ffffffffc02010c4:	86be                	mv	a3,a5
ffffffffc02010c6:	00006617          	auipc	a2,0x6
ffffffffc02010ca:	12260613          	addi	a2,a2,290 # ffffffffc02071e8 <commands+0x848>
ffffffffc02010ce:	06900593          	li	a1,105
ffffffffc02010d2:	00006517          	auipc	a0,0x6
ffffffffc02010d6:	07e50513          	addi	a0,a0,126 # ffffffffc0207150 <commands+0x7b0>
ffffffffc02010da:	92eff0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(npage != NULL);
ffffffffc02010de:	00006697          	auipc	a3,0x6
ffffffffc02010e2:	0fa68693          	addi	a3,a3,250 # ffffffffc02071d8 <commands+0x838>
ffffffffc02010e6:	00006617          	auipc	a2,0x6
ffffffffc02010ea:	cca60613          	addi	a2,a2,-822 # ffffffffc0206db0 <commands+0x410>
ffffffffc02010ee:	04100593          	li	a1,65
ffffffffc02010f2:	00006517          	auipc	a0,0x6
ffffffffc02010f6:	00e50513          	addi	a0,a0,14 # ffffffffc0207100 <commands+0x760>
ffffffffc02010fa:	90eff0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page != NULL);
ffffffffc02010fe:	00006697          	auipc	a3,0x6
ffffffffc0201102:	08268693          	addi	a3,a3,130 # ffffffffc0207180 <commands+0x7e0>
ffffffffc0201106:	00006617          	auipc	a2,0x6
ffffffffc020110a:	caa60613          	addi	a2,a2,-854 # ffffffffc0206db0 <commands+0x410>
ffffffffc020110e:	04000593          	li	a1,64
ffffffffc0201112:	00006517          	auipc	a0,0x6
ffffffffc0201116:	fee50513          	addi	a0,a0,-18 # ffffffffc0207100 <commands+0x760>
ffffffffc020111a:	8eeff0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020111e:	00006617          	auipc	a2,0x6
ffffffffc0201122:	04260613          	addi	a2,a2,66 # ffffffffc0207160 <commands+0x7c0>
ffffffffc0201126:	06200593          	li	a1,98
ffffffffc020112a:	00006517          	auipc	a0,0x6
ffffffffc020112e:	02650513          	addi	a0,a0,38 # ffffffffc0207150 <commands+0x7b0>
ffffffffc0201132:	8d6ff0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201136:	00006617          	auipc	a2,0x6
ffffffffc020113a:	ff260613          	addi	a2,a2,-14 # ffffffffc0207128 <commands+0x788>
ffffffffc020113e:	07400593          	li	a1,116
ffffffffc0201142:	00006517          	auipc	a0,0x6
ffffffffc0201146:	00e50513          	addi	a0,a0,14 # ffffffffc0207150 <commands+0x7b0>
ffffffffc020114a:	8beff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020114e <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020114e:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0201150:	00006697          	auipc	a3,0x6
ffffffffc0201154:	0c068693          	addi	a3,a3,192 # ffffffffc0207210 <commands+0x870>
ffffffffc0201158:	00006617          	auipc	a2,0x6
ffffffffc020115c:	c5860613          	addi	a2,a2,-936 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201160:	06e00593          	li	a1,110
ffffffffc0201164:	00006517          	auipc	a0,0x6
ffffffffc0201168:	0cc50513          	addi	a0,a0,204 # ffffffffc0207230 <commands+0x890>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020116c:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020116e:	89aff0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201172 <mm_create>:
mm_create(void) {
ffffffffc0201172:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201174:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0201178:	e022                	sd	s0,0(sp)
ffffffffc020117a:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020117c:	090010ef          	jal	ra,ffffffffc020220c <kmalloc>
ffffffffc0201180:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0201182:	c505                	beqz	a0,ffffffffc02011aa <mm_create+0x38>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201184:	e408                	sd	a0,8(s0)
ffffffffc0201186:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0201188:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020118c:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201190:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201194:	000b1797          	auipc	a5,0xb1
ffffffffc0201198:	6747a783          	lw	a5,1652(a5) # ffffffffc02b2808 <swap_init_ok>
ffffffffc020119c:	ef81                	bnez	a5,ffffffffc02011b4 <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc020119e:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc02011a2:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc02011a6:	02043c23          	sd	zero,56(s0)
}
ffffffffc02011aa:	60a2                	ld	ra,8(sp)
ffffffffc02011ac:	8522                	mv	a0,s0
ffffffffc02011ae:	6402                	ld	s0,0(sp)
ffffffffc02011b0:	0141                	addi	sp,sp,16
ffffffffc02011b2:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02011b4:	165010ef          	jal	ra,ffffffffc0202b18 <swap_init_mm>
ffffffffc02011b8:	b7ed                	j	ffffffffc02011a2 <mm_create+0x30>

ffffffffc02011ba <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02011ba:	1101                	addi	sp,sp,-32
ffffffffc02011bc:	e04a                	sd	s2,0(sp)
ffffffffc02011be:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02011c0:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02011c4:	e822                	sd	s0,16(sp)
ffffffffc02011c6:	e426                	sd	s1,8(sp)
ffffffffc02011c8:	ec06                	sd	ra,24(sp)
ffffffffc02011ca:	84ae                	mv	s1,a1
ffffffffc02011cc:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02011ce:	03e010ef          	jal	ra,ffffffffc020220c <kmalloc>
    if (vma != NULL) {
ffffffffc02011d2:	c509                	beqz	a0,ffffffffc02011dc <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02011d4:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02011d8:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02011da:	cd00                	sw	s0,24(a0)
}
ffffffffc02011dc:	60e2                	ld	ra,24(sp)
ffffffffc02011de:	6442                	ld	s0,16(sp)
ffffffffc02011e0:	64a2                	ld	s1,8(sp)
ffffffffc02011e2:	6902                	ld	s2,0(sp)
ffffffffc02011e4:	6105                	addi	sp,sp,32
ffffffffc02011e6:	8082                	ret

ffffffffc02011e8 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc02011e8:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc02011ea:	c505                	beqz	a0,ffffffffc0201212 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc02011ec:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02011ee:	c501                	beqz	a0,ffffffffc02011f6 <find_vma+0xe>
ffffffffc02011f0:	651c                	ld	a5,8(a0)
ffffffffc02011f2:	02f5f263          	bgeu	a1,a5,ffffffffc0201216 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02011f6:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc02011f8:	00f68d63          	beq	a3,a5,ffffffffc0201212 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02011fc:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201200:	00e5e663          	bltu	a1,a4,ffffffffc020120c <find_vma+0x24>
ffffffffc0201204:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201208:	00e5ec63          	bltu	a1,a4,ffffffffc0201220 <find_vma+0x38>
ffffffffc020120c:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020120e:	fef697e3          	bne	a3,a5,ffffffffc02011fc <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0201212:	4501                	li	a0,0
}
ffffffffc0201214:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201216:	691c                	ld	a5,16(a0)
ffffffffc0201218:	fcf5ffe3          	bgeu	a1,a5,ffffffffc02011f6 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc020121c:	ea88                	sd	a0,16(a3)
ffffffffc020121e:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0201220:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0201224:	ea88                	sd	a0,16(a3)
ffffffffc0201226:	8082                	ret

ffffffffc0201228 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201228:	6590                	ld	a2,8(a1)
ffffffffc020122a:	0105b803          	ld	a6,16(a1) # fffffffffffff010 <end+0x3fd4c7b4>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020122e:	1141                	addi	sp,sp,-16
ffffffffc0201230:	e406                	sd	ra,8(sp)
ffffffffc0201232:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201234:	01066763          	bltu	a2,a6,ffffffffc0201242 <insert_vma_struct+0x1a>
ffffffffc0201238:	a085                	j	ffffffffc0201298 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020123a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020123e:	04e66863          	bltu	a2,a4,ffffffffc020128e <insert_vma_struct+0x66>
ffffffffc0201242:	86be                	mv	a3,a5
ffffffffc0201244:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0201246:	fef51ae3          	bne	a0,a5,ffffffffc020123a <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc020124a:	02a68463          	beq	a3,a0,ffffffffc0201272 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020124e:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201252:	fe86b883          	ld	a7,-24(a3)
ffffffffc0201256:	08e8f163          	bgeu	a7,a4,ffffffffc02012d8 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020125a:	04e66f63          	bltu	a2,a4,ffffffffc02012b8 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc020125e:	00f50a63          	beq	a0,a5,ffffffffc0201272 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0201262:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201266:	05076963          	bltu	a4,a6,ffffffffc02012b8 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc020126a:	ff07b603          	ld	a2,-16(a5)
ffffffffc020126e:	02c77363          	bgeu	a4,a2,ffffffffc0201294 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0201272:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0201274:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0201276:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020127a:	e390                	sd	a2,0(a5)
ffffffffc020127c:	e690                	sd	a2,8(a3)
}
ffffffffc020127e:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0201280:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0201282:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0201284:	0017079b          	addiw	a5,a4,1
ffffffffc0201288:	d11c                	sw	a5,32(a0)
}
ffffffffc020128a:	0141                	addi	sp,sp,16
ffffffffc020128c:	8082                	ret
    if (le_prev != list) {
ffffffffc020128e:	fca690e3          	bne	a3,a0,ffffffffc020124e <insert_vma_struct+0x26>
ffffffffc0201292:	bfd1                	j	ffffffffc0201266 <insert_vma_struct+0x3e>
ffffffffc0201294:	ebbff0ef          	jal	ra,ffffffffc020114e <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201298:	00006697          	auipc	a3,0x6
ffffffffc020129c:	fa868693          	addi	a3,a3,-88 # ffffffffc0207240 <commands+0x8a0>
ffffffffc02012a0:	00006617          	auipc	a2,0x6
ffffffffc02012a4:	b1060613          	addi	a2,a2,-1264 # ffffffffc0206db0 <commands+0x410>
ffffffffc02012a8:	07500593          	li	a1,117
ffffffffc02012ac:	00006517          	auipc	a0,0x6
ffffffffc02012b0:	f8450513          	addi	a0,a0,-124 # ffffffffc0207230 <commands+0x890>
ffffffffc02012b4:	f55fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02012b8:	00006697          	auipc	a3,0x6
ffffffffc02012bc:	fc868693          	addi	a3,a3,-56 # ffffffffc0207280 <commands+0x8e0>
ffffffffc02012c0:	00006617          	auipc	a2,0x6
ffffffffc02012c4:	af060613          	addi	a2,a2,-1296 # ffffffffc0206db0 <commands+0x410>
ffffffffc02012c8:	06d00593          	li	a1,109
ffffffffc02012cc:	00006517          	auipc	a0,0x6
ffffffffc02012d0:	f6450513          	addi	a0,a0,-156 # ffffffffc0207230 <commands+0x890>
ffffffffc02012d4:	f35fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02012d8:	00006697          	auipc	a3,0x6
ffffffffc02012dc:	f8868693          	addi	a3,a3,-120 # ffffffffc0207260 <commands+0x8c0>
ffffffffc02012e0:	00006617          	auipc	a2,0x6
ffffffffc02012e4:	ad060613          	addi	a2,a2,-1328 # ffffffffc0206db0 <commands+0x410>
ffffffffc02012e8:	06c00593          	li	a1,108
ffffffffc02012ec:	00006517          	auipc	a0,0x6
ffffffffc02012f0:	f4450513          	addi	a0,a0,-188 # ffffffffc0207230 <commands+0x890>
ffffffffc02012f4:	f15fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02012f8 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc02012f8:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc02012fa:	1141                	addi	sp,sp,-16
ffffffffc02012fc:	e406                	sd	ra,8(sp)
ffffffffc02012fe:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0201300:	e78d                	bnez	a5,ffffffffc020132a <mm_destroy+0x32>
ffffffffc0201302:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0201304:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0201306:	00a40c63          	beq	s0,a0,ffffffffc020131e <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020130a:	6118                	ld	a4,0(a0)
ffffffffc020130c:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc020130e:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201310:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201312:	e398                	sd	a4,0(a5)
ffffffffc0201314:	7a9000ef          	jal	ra,ffffffffc02022bc <kfree>
    return listelm->next;
ffffffffc0201318:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020131a:	fea418e3          	bne	s0,a0,ffffffffc020130a <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc020131e:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0201320:	6402                	ld	s0,0(sp)
ffffffffc0201322:	60a2                	ld	ra,8(sp)
ffffffffc0201324:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0201326:	7970006f          	j	ffffffffc02022bc <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020132a:	00006697          	auipc	a3,0x6
ffffffffc020132e:	f7668693          	addi	a3,a3,-138 # ffffffffc02072a0 <commands+0x900>
ffffffffc0201332:	00006617          	auipc	a2,0x6
ffffffffc0201336:	a7e60613          	addi	a2,a2,-1410 # ffffffffc0206db0 <commands+0x410>
ffffffffc020133a:	09500593          	li	a1,149
ffffffffc020133e:	00006517          	auipc	a0,0x6
ffffffffc0201342:	ef250513          	addi	a0,a0,-270 # ffffffffc0207230 <commands+0x890>
ffffffffc0201346:	ec3fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020134a <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc020134a:	7139                	addi	sp,sp,-64
ffffffffc020134c:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020134e:	6405                	lui	s0,0x1
ffffffffc0201350:	147d                	addi	s0,s0,-1
ffffffffc0201352:	77fd                	lui	a5,0xfffff
ffffffffc0201354:	9622                	add	a2,a2,s0
ffffffffc0201356:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc0201358:	f426                	sd	s1,40(sp)
ffffffffc020135a:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020135c:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc0201360:	f04a                	sd	s2,32(sp)
ffffffffc0201362:	ec4e                	sd	s3,24(sp)
ffffffffc0201364:	e852                	sd	s4,16(sp)
ffffffffc0201366:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc0201368:	002005b7          	lui	a1,0x200
ffffffffc020136c:	00f67433          	and	s0,a2,a5
ffffffffc0201370:	06b4e363          	bltu	s1,a1,ffffffffc02013d6 <mm_map+0x8c>
ffffffffc0201374:	0684f163          	bgeu	s1,s0,ffffffffc02013d6 <mm_map+0x8c>
ffffffffc0201378:	4785                	li	a5,1
ffffffffc020137a:	07fe                	slli	a5,a5,0x1f
ffffffffc020137c:	0487ed63          	bltu	a5,s0,ffffffffc02013d6 <mm_map+0x8c>
ffffffffc0201380:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0201382:	cd21                	beqz	a0,ffffffffc02013da <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0201384:	85a6                	mv	a1,s1
ffffffffc0201386:	8ab6                	mv	s5,a3
ffffffffc0201388:	8a3a                	mv	s4,a4
ffffffffc020138a:	e5fff0ef          	jal	ra,ffffffffc02011e8 <find_vma>
ffffffffc020138e:	c501                	beqz	a0,ffffffffc0201396 <mm_map+0x4c>
ffffffffc0201390:	651c                	ld	a5,8(a0)
ffffffffc0201392:	0487e263          	bltu	a5,s0,ffffffffc02013d6 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201396:	03000513          	li	a0,48
ffffffffc020139a:	673000ef          	jal	ra,ffffffffc020220c <kmalloc>
ffffffffc020139e:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02013a0:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc02013a2:	02090163          	beqz	s2,ffffffffc02013c4 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02013a6:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02013a8:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02013ac:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02013b0:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02013b4:	85ca                	mv	a1,s2
ffffffffc02013b6:	e73ff0ef          	jal	ra,ffffffffc0201228 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc02013ba:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc02013bc:	000a0463          	beqz	s4,ffffffffc02013c4 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc02013c0:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc02013c4:	70e2                	ld	ra,56(sp)
ffffffffc02013c6:	7442                	ld	s0,48(sp)
ffffffffc02013c8:	74a2                	ld	s1,40(sp)
ffffffffc02013ca:	7902                	ld	s2,32(sp)
ffffffffc02013cc:	69e2                	ld	s3,24(sp)
ffffffffc02013ce:	6a42                	ld	s4,16(sp)
ffffffffc02013d0:	6aa2                	ld	s5,8(sp)
ffffffffc02013d2:	6121                	addi	sp,sp,64
ffffffffc02013d4:	8082                	ret
        return -E_INVAL;
ffffffffc02013d6:	5575                	li	a0,-3
ffffffffc02013d8:	b7f5                	j	ffffffffc02013c4 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc02013da:	00006697          	auipc	a3,0x6
ffffffffc02013de:	ede68693          	addi	a3,a3,-290 # ffffffffc02072b8 <commands+0x918>
ffffffffc02013e2:	00006617          	auipc	a2,0x6
ffffffffc02013e6:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0206db0 <commands+0x410>
ffffffffc02013ea:	0a800593          	li	a1,168
ffffffffc02013ee:	00006517          	auipc	a0,0x6
ffffffffc02013f2:	e4250513          	addi	a0,a0,-446 # ffffffffc0207230 <commands+0x890>
ffffffffc02013f6:	e13fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02013fa <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc02013fa:	7139                	addi	sp,sp,-64
ffffffffc02013fc:	fc06                	sd	ra,56(sp)
ffffffffc02013fe:	f822                	sd	s0,48(sp)
ffffffffc0201400:	f426                	sd	s1,40(sp)
ffffffffc0201402:	f04a                	sd	s2,32(sp)
ffffffffc0201404:	ec4e                	sd	s3,24(sp)
ffffffffc0201406:	e852                	sd	s4,16(sp)
ffffffffc0201408:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc020140a:	c52d                	beqz	a0,ffffffffc0201474 <dup_mmap+0x7a>
ffffffffc020140c:	892a                	mv	s2,a0
ffffffffc020140e:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0201410:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0201412:	e595                	bnez	a1,ffffffffc020143e <dup_mmap+0x44>
ffffffffc0201414:	a085                	j	ffffffffc0201474 <dup_mmap+0x7a>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0201416:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc0201418:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ee8>
        vma->vm_end = vm_end;
ffffffffc020141c:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0201420:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0201424:	e05ff0ef          	jal	ra,ffffffffc0201228 <insert_vma_struct>

        bool share = 0;
        //if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) return -E_NO_MEM;
        if (shared_read_state(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) return -E_NO_MEM;
ffffffffc0201428:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc020142c:	fe843603          	ld	a2,-24(s0)
ffffffffc0201430:	6c8c                	ld	a1,24(s1)
ffffffffc0201432:	01893503          	ld	a0,24(s2)
ffffffffc0201436:	4701                	li	a4,0
ffffffffc0201438:	9ebff0ef          	jal	ra,ffffffffc0200e22 <shared_read_state>
ffffffffc020143c:	e105                	bnez	a0,ffffffffc020145c <dup_mmap+0x62>
    return listelm->prev;
ffffffffc020143e:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc0201440:	02848863          	beq	s1,s0,ffffffffc0201470 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201444:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0201448:	fe843a83          	ld	s5,-24(s0)
ffffffffc020144c:	ff043a03          	ld	s4,-16(s0)
ffffffffc0201450:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201454:	5b9000ef          	jal	ra,ffffffffc020220c <kmalloc>
ffffffffc0201458:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc020145a:	fd55                	bnez	a0,ffffffffc0201416 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc020145c:	5571                	li	a0,-4
    }
    return 0;
}
ffffffffc020145e:	70e2                	ld	ra,56(sp)
ffffffffc0201460:	7442                	ld	s0,48(sp)
ffffffffc0201462:	74a2                	ld	s1,40(sp)
ffffffffc0201464:	7902                	ld	s2,32(sp)
ffffffffc0201466:	69e2                	ld	s3,24(sp)
ffffffffc0201468:	6a42                	ld	s4,16(sp)
ffffffffc020146a:	6aa2                	ld	s5,8(sp)
ffffffffc020146c:	6121                	addi	sp,sp,64
ffffffffc020146e:	8082                	ret
    return 0;
ffffffffc0201470:	4501                	li	a0,0
ffffffffc0201472:	b7f5                	j	ffffffffc020145e <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0201474:	00006697          	auipc	a3,0x6
ffffffffc0201478:	e5468693          	addi	a3,a3,-428 # ffffffffc02072c8 <commands+0x928>
ffffffffc020147c:	00006617          	auipc	a2,0x6
ffffffffc0201480:	93460613          	addi	a2,a2,-1740 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201484:	0c100593          	li	a1,193
ffffffffc0201488:	00006517          	auipc	a0,0x6
ffffffffc020148c:	da850513          	addi	a0,a0,-600 # ffffffffc0207230 <commands+0x890>
ffffffffc0201490:	d79fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201494 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0201494:	1101                	addi	sp,sp,-32
ffffffffc0201496:	ec06                	sd	ra,24(sp)
ffffffffc0201498:	e822                	sd	s0,16(sp)
ffffffffc020149a:	e426                	sd	s1,8(sp)
ffffffffc020149c:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020149e:	c531                	beqz	a0,ffffffffc02014ea <exit_mmap+0x56>
ffffffffc02014a0:	591c                	lw	a5,48(a0)
ffffffffc02014a2:	84aa                	mv	s1,a0
ffffffffc02014a4:	e3b9                	bnez	a5,ffffffffc02014ea <exit_mmap+0x56>
    return listelm->next;
ffffffffc02014a6:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02014a8:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc02014ac:	02850663          	beq	a0,s0,ffffffffc02014d8 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02014b0:	ff043603          	ld	a2,-16(s0)
ffffffffc02014b4:	fe843583          	ld	a1,-24(s0)
ffffffffc02014b8:	854a                	mv	a0,s2
ffffffffc02014ba:	61c020ef          	jal	ra,ffffffffc0203ad6 <unmap_range>
ffffffffc02014be:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02014c0:	fe8498e3          	bne	s1,s0,ffffffffc02014b0 <exit_mmap+0x1c>
ffffffffc02014c4:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc02014c6:	00848c63          	beq	s1,s0,ffffffffc02014de <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02014ca:	ff043603          	ld	a2,-16(s0)
ffffffffc02014ce:	fe843583          	ld	a1,-24(s0)
ffffffffc02014d2:	854a                	mv	a0,s2
ffffffffc02014d4:	748020ef          	jal	ra,ffffffffc0203c1c <exit_range>
ffffffffc02014d8:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02014da:	fe8498e3          	bne	s1,s0,ffffffffc02014ca <exit_mmap+0x36>
    }
}
ffffffffc02014de:	60e2                	ld	ra,24(sp)
ffffffffc02014e0:	6442                	ld	s0,16(sp)
ffffffffc02014e2:	64a2                	ld	s1,8(sp)
ffffffffc02014e4:	6902                	ld	s2,0(sp)
ffffffffc02014e6:	6105                	addi	sp,sp,32
ffffffffc02014e8:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02014ea:	00006697          	auipc	a3,0x6
ffffffffc02014ee:	dfe68693          	addi	a3,a3,-514 # ffffffffc02072e8 <commands+0x948>
ffffffffc02014f2:	00006617          	auipc	a2,0x6
ffffffffc02014f6:	8be60613          	addi	a2,a2,-1858 # ffffffffc0206db0 <commands+0x410>
ffffffffc02014fa:	0d600593          	li	a1,214
ffffffffc02014fe:	00006517          	auipc	a0,0x6
ffffffffc0201502:	d3250513          	addi	a0,a0,-718 # ffffffffc0207230 <commands+0x890>
ffffffffc0201506:	d03fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020150a <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020150a:	7139                	addi	sp,sp,-64
ffffffffc020150c:	f822                	sd	s0,48(sp)
ffffffffc020150e:	f426                	sd	s1,40(sp)
ffffffffc0201510:	fc06                	sd	ra,56(sp)
ffffffffc0201512:	f04a                	sd	s2,32(sp)
ffffffffc0201514:	ec4e                	sd	s3,24(sp)
ffffffffc0201516:	e852                	sd	s4,16(sp)
ffffffffc0201518:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc020151a:	c59ff0ef          	jal	ra,ffffffffc0201172 <mm_create>
    assert(mm != NULL);
ffffffffc020151e:	84aa                	mv	s1,a0
ffffffffc0201520:	03200413          	li	s0,50
ffffffffc0201524:	e919                	bnez	a0,ffffffffc020153a <vmm_init+0x30>
ffffffffc0201526:	a991                	j	ffffffffc020197a <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc0201528:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc020152a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020152c:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0201530:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201532:	8526                	mv	a0,s1
ffffffffc0201534:	cf5ff0ef          	jal	ra,ffffffffc0201228 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0201538:	c80d                	beqz	s0,ffffffffc020156a <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020153a:	03000513          	li	a0,48
ffffffffc020153e:	4cf000ef          	jal	ra,ffffffffc020220c <kmalloc>
ffffffffc0201542:	85aa                	mv	a1,a0
ffffffffc0201544:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0201548:	f165                	bnez	a0,ffffffffc0201528 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc020154a:	00006697          	auipc	a3,0x6
ffffffffc020154e:	fd668693          	addi	a3,a3,-42 # ffffffffc0207520 <commands+0xb80>
ffffffffc0201552:	00006617          	auipc	a2,0x6
ffffffffc0201556:	85e60613          	addi	a2,a2,-1954 # ffffffffc0206db0 <commands+0x410>
ffffffffc020155a:	11300593          	li	a1,275
ffffffffc020155e:	00006517          	auipc	a0,0x6
ffffffffc0201562:	cd250513          	addi	a0,a0,-814 # ffffffffc0207230 <commands+0x890>
ffffffffc0201566:	ca3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc020156a:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020156e:	1f900913          	li	s2,505
ffffffffc0201572:	a819                	j	ffffffffc0201588 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0201574:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201576:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201578:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020157c:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020157e:	8526                	mv	a0,s1
ffffffffc0201580:	ca9ff0ef          	jal	ra,ffffffffc0201228 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201584:	03240a63          	beq	s0,s2,ffffffffc02015b8 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201588:	03000513          	li	a0,48
ffffffffc020158c:	481000ef          	jal	ra,ffffffffc020220c <kmalloc>
ffffffffc0201590:	85aa                	mv	a1,a0
ffffffffc0201592:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0201596:	fd79                	bnez	a0,ffffffffc0201574 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0201598:	00006697          	auipc	a3,0x6
ffffffffc020159c:	f8868693          	addi	a3,a3,-120 # ffffffffc0207520 <commands+0xb80>
ffffffffc02015a0:	00006617          	auipc	a2,0x6
ffffffffc02015a4:	81060613          	addi	a2,a2,-2032 # ffffffffc0206db0 <commands+0x410>
ffffffffc02015a8:	11900593          	li	a1,281
ffffffffc02015ac:	00006517          	auipc	a0,0x6
ffffffffc02015b0:	c8450513          	addi	a0,a0,-892 # ffffffffc0207230 <commands+0x890>
ffffffffc02015b4:	c55fe0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02015b8:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc02015ba:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc02015bc:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02015c0:	2cf48d63          	beq	s1,a5,ffffffffc020189a <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02015c4:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd4c78c>
ffffffffc02015c8:	ffe70613          	addi	a2,a4,-2
ffffffffc02015cc:	24d61763          	bne	a2,a3,ffffffffc020181a <vmm_init+0x310>
ffffffffc02015d0:	ff07b683          	ld	a3,-16(a5)
ffffffffc02015d4:	24e69363          	bne	a3,a4,ffffffffc020181a <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc02015d8:	0715                	addi	a4,a4,5
ffffffffc02015da:	679c                	ld	a5,8(a5)
ffffffffc02015dc:	feb712e3          	bne	a4,a1,ffffffffc02015c0 <vmm_init+0xb6>
ffffffffc02015e0:	4a1d                	li	s4,7
ffffffffc02015e2:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02015e4:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02015e8:	85a2                	mv	a1,s0
ffffffffc02015ea:	8526                	mv	a0,s1
ffffffffc02015ec:	bfdff0ef          	jal	ra,ffffffffc02011e8 <find_vma>
ffffffffc02015f0:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc02015f2:	30050463          	beqz	a0,ffffffffc02018fa <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02015f6:	00140593          	addi	a1,s0,1
ffffffffc02015fa:	8526                	mv	a0,s1
ffffffffc02015fc:	bedff0ef          	jal	ra,ffffffffc02011e8 <find_vma>
ffffffffc0201600:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0201602:	2c050c63          	beqz	a0,ffffffffc02018da <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0201606:	85d2                	mv	a1,s4
ffffffffc0201608:	8526                	mv	a0,s1
ffffffffc020160a:	bdfff0ef          	jal	ra,ffffffffc02011e8 <find_vma>
        assert(vma3 == NULL);
ffffffffc020160e:	2a051663          	bnez	a0,ffffffffc02018ba <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0201612:	00340593          	addi	a1,s0,3
ffffffffc0201616:	8526                	mv	a0,s1
ffffffffc0201618:	bd1ff0ef          	jal	ra,ffffffffc02011e8 <find_vma>
        assert(vma4 == NULL);
ffffffffc020161c:	30051f63          	bnez	a0,ffffffffc020193a <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0201620:	00440593          	addi	a1,s0,4
ffffffffc0201624:	8526                	mv	a0,s1
ffffffffc0201626:	bc3ff0ef          	jal	ra,ffffffffc02011e8 <find_vma>
        assert(vma5 == NULL);
ffffffffc020162a:	2e051863          	bnez	a0,ffffffffc020191a <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020162e:	00893783          	ld	a5,8(s2)
ffffffffc0201632:	20879463          	bne	a5,s0,ffffffffc020183a <vmm_init+0x330>
ffffffffc0201636:	01093783          	ld	a5,16(s2)
ffffffffc020163a:	20fa1063          	bne	s4,a5,ffffffffc020183a <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020163e:	0089b783          	ld	a5,8(s3) # 1008 <_binary_obj___user_faultread_out_size-0x8ba8>
ffffffffc0201642:	20879c63          	bne	a5,s0,ffffffffc020185a <vmm_init+0x350>
ffffffffc0201646:	0109b783          	ld	a5,16(s3)
ffffffffc020164a:	20fa1863          	bne	s4,a5,ffffffffc020185a <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020164e:	0415                	addi	s0,s0,5
ffffffffc0201650:	0a15                	addi	s4,s4,5
ffffffffc0201652:	f9541be3          	bne	s0,s5,ffffffffc02015e8 <vmm_init+0xde>
ffffffffc0201656:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0201658:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020165a:	85a2                	mv	a1,s0
ffffffffc020165c:	8526                	mv	a0,s1
ffffffffc020165e:	b8bff0ef          	jal	ra,ffffffffc02011e8 <find_vma>
ffffffffc0201662:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0201666:	c90d                	beqz	a0,ffffffffc0201698 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0201668:	6914                	ld	a3,16(a0)
ffffffffc020166a:	6510                	ld	a2,8(a0)
ffffffffc020166c:	00006517          	auipc	a0,0x6
ffffffffc0201670:	d9c50513          	addi	a0,a0,-612 # ffffffffc0207408 <commands+0xa68>
ffffffffc0201674:	a59fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0201678:	00006697          	auipc	a3,0x6
ffffffffc020167c:	db868693          	addi	a3,a3,-584 # ffffffffc0207430 <commands+0xa90>
ffffffffc0201680:	00005617          	auipc	a2,0x5
ffffffffc0201684:	73060613          	addi	a2,a2,1840 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201688:	13b00593          	li	a1,315
ffffffffc020168c:	00006517          	auipc	a0,0x6
ffffffffc0201690:	ba450513          	addi	a0,a0,-1116 # ffffffffc0207230 <commands+0x890>
ffffffffc0201694:	b75fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0201698:	147d                	addi	s0,s0,-1
ffffffffc020169a:	fd2410e3          	bne	s0,s2,ffffffffc020165a <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc020169e:	8526                	mv	a0,s1
ffffffffc02016a0:	c59ff0ef          	jal	ra,ffffffffc02012f8 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02016a4:	00006517          	auipc	a0,0x6
ffffffffc02016a8:	da450513          	addi	a0,a0,-604 # ffffffffc0207448 <commands+0xaa8>
ffffffffc02016ac:	a21fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02016b0:	1c6020ef          	jal	ra,ffffffffc0203876 <nr_free_pages>
ffffffffc02016b4:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc02016b6:	abdff0ef          	jal	ra,ffffffffc0201172 <mm_create>
ffffffffc02016ba:	000b1797          	auipc	a5,0xb1
ffffffffc02016be:	12a7b323          	sd	a0,294(a5) # ffffffffc02b27e0 <check_mm_struct>
ffffffffc02016c2:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc02016c4:	28050b63          	beqz	a0,ffffffffc020195a <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02016c8:	000b1497          	auipc	s1,0xb1
ffffffffc02016cc:	1504b483          	ld	s1,336(s1) # ffffffffc02b2818 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc02016d0:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02016d2:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02016d4:	2e079f63          	bnez	a5,ffffffffc02019d2 <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02016d8:	03000513          	li	a0,48
ffffffffc02016dc:	331000ef          	jal	ra,ffffffffc020220c <kmalloc>
ffffffffc02016e0:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc02016e2:	18050c63          	beqz	a0,ffffffffc020187a <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc02016e6:	002007b7          	lui	a5,0x200
ffffffffc02016ea:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc02016ee:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02016f0:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02016f2:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc02016f6:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02016f8:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc02016fc:	b2dff0ef          	jal	ra,ffffffffc0201228 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0201700:	10000593          	li	a1,256
ffffffffc0201704:	8522                	mv	a0,s0
ffffffffc0201706:	ae3ff0ef          	jal	ra,ffffffffc02011e8 <find_vma>
ffffffffc020170a:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc020170e:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0201712:	2ea99063          	bne	s3,a0,ffffffffc02019f2 <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc0201716:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f4ee0>
    for (i = 0; i < 100; i ++) {
ffffffffc020171a:	0785                	addi	a5,a5,1
ffffffffc020171c:	fee79de3          	bne	a5,a4,ffffffffc0201716 <vmm_init+0x20c>
        sum += i;
ffffffffc0201720:	6705                	lui	a4,0x1
ffffffffc0201722:	10000793          	li	a5,256
ffffffffc0201726:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x885a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc020172a:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020172e:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0201732:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0201734:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0201736:	fec79ce3          	bne	a5,a2,ffffffffc020172e <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc020173a:	2e071863          	bnez	a4,ffffffffc0201a2a <vmm_init+0x520>
}

static inline struct Page *
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc020173e:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0201740:	000b1a97          	auipc	s5,0xb1
ffffffffc0201744:	0e0a8a93          	addi	s5,s5,224 # ffffffffc02b2820 <npage>
ffffffffc0201748:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020174c:	078a                	slli	a5,a5,0x2
ffffffffc020174e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201750:	2cc7f163          	bgeu	a5,a2,ffffffffc0201a12 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0201754:	00007a17          	auipc	s4,0x7
ffffffffc0201758:	6f4a3a03          	ld	s4,1780(s4) # ffffffffc0208e48 <nbase>
ffffffffc020175c:	414787b3          	sub	a5,a5,s4
ffffffffc0201760:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc0201762:	8799                	srai	a5,a5,0x6
ffffffffc0201764:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0201766:	00c79713          	slli	a4,a5,0xc
ffffffffc020176a:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020176c:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0201770:	24c77563          	bgeu	a4,a2,ffffffffc02019ba <vmm_init+0x4b0>
ffffffffc0201774:	000b1997          	auipc	s3,0xb1
ffffffffc0201778:	0c49b983          	ld	s3,196(s3) # ffffffffc02b2838 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc020177c:	4581                	li	a1,0
ffffffffc020177e:	8526                	mv	a0,s1
ffffffffc0201780:	99b6                	add	s3,s3,a3
ffffffffc0201782:	72c020ef          	jal	ra,ffffffffc0203eae <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201786:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc020178a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020178e:	078a                	slli	a5,a5,0x2
ffffffffc0201790:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201792:	28e7f063          	bgeu	a5,a4,ffffffffc0201a12 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0201796:	000b1997          	auipc	s3,0xb1
ffffffffc020179a:	09298993          	addi	s3,s3,146 # ffffffffc02b2828 <pages>
ffffffffc020179e:	0009b503          	ld	a0,0(s3)
ffffffffc02017a2:	414787b3          	sub	a5,a5,s4
ffffffffc02017a6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02017a8:	953e                	add	a0,a0,a5
ffffffffc02017aa:	4585                	li	a1,1
ffffffffc02017ac:	08a020ef          	jal	ra,ffffffffc0203836 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02017b0:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02017b2:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02017b6:	078a                	slli	a5,a5,0x2
ffffffffc02017b8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02017ba:	24e7fc63          	bgeu	a5,a4,ffffffffc0201a12 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc02017be:	0009b503          	ld	a0,0(s3)
ffffffffc02017c2:	414787b3          	sub	a5,a5,s4
ffffffffc02017c6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02017c8:	4585                	li	a1,1
ffffffffc02017ca:	953e                	add	a0,a0,a5
ffffffffc02017cc:	06a020ef          	jal	ra,ffffffffc0203836 <free_pages>
    pgdir[0] = 0;
ffffffffc02017d0:	0004b023          	sd	zero,0(s1)
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() {
  asm volatile("sfence.vma");
ffffffffc02017d4:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc02017d8:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc02017da:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc02017de:	b1bff0ef          	jal	ra,ffffffffc02012f8 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc02017e2:	000b1797          	auipc	a5,0xb1
ffffffffc02017e6:	fe07bf23          	sd	zero,-2(a5) # ffffffffc02b27e0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02017ea:	08c020ef          	jal	ra,ffffffffc0203876 <nr_free_pages>
ffffffffc02017ee:	1aa91663          	bne	s2,a0,ffffffffc020199a <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02017f2:	00006517          	auipc	a0,0x6
ffffffffc02017f6:	cf650513          	addi	a0,a0,-778 # ffffffffc02074e8 <commands+0xb48>
ffffffffc02017fa:	8d3fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02017fe:	7442                	ld	s0,48(sp)
ffffffffc0201800:	70e2                	ld	ra,56(sp)
ffffffffc0201802:	74a2                	ld	s1,40(sp)
ffffffffc0201804:	7902                	ld	s2,32(sp)
ffffffffc0201806:	69e2                	ld	s3,24(sp)
ffffffffc0201808:	6a42                	ld	s4,16(sp)
ffffffffc020180a:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020180c:	00006517          	auipc	a0,0x6
ffffffffc0201810:	cfc50513          	addi	a0,a0,-772 # ffffffffc0207508 <commands+0xb68>
}
ffffffffc0201814:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201816:	8b7fe06f          	j	ffffffffc02000cc <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020181a:	00006697          	auipc	a3,0x6
ffffffffc020181e:	b0668693          	addi	a3,a3,-1274 # ffffffffc0207320 <commands+0x980>
ffffffffc0201822:	00005617          	auipc	a2,0x5
ffffffffc0201826:	58e60613          	addi	a2,a2,1422 # ffffffffc0206db0 <commands+0x410>
ffffffffc020182a:	12200593          	li	a1,290
ffffffffc020182e:	00006517          	auipc	a0,0x6
ffffffffc0201832:	a0250513          	addi	a0,a0,-1534 # ffffffffc0207230 <commands+0x890>
ffffffffc0201836:	9d3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020183a:	00006697          	auipc	a3,0x6
ffffffffc020183e:	b6e68693          	addi	a3,a3,-1170 # ffffffffc02073a8 <commands+0xa08>
ffffffffc0201842:	00005617          	auipc	a2,0x5
ffffffffc0201846:	56e60613          	addi	a2,a2,1390 # ffffffffc0206db0 <commands+0x410>
ffffffffc020184a:	13200593          	li	a1,306
ffffffffc020184e:	00006517          	auipc	a0,0x6
ffffffffc0201852:	9e250513          	addi	a0,a0,-1566 # ffffffffc0207230 <commands+0x890>
ffffffffc0201856:	9b3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020185a:	00006697          	auipc	a3,0x6
ffffffffc020185e:	b7e68693          	addi	a3,a3,-1154 # ffffffffc02073d8 <commands+0xa38>
ffffffffc0201862:	00005617          	auipc	a2,0x5
ffffffffc0201866:	54e60613          	addi	a2,a2,1358 # ffffffffc0206db0 <commands+0x410>
ffffffffc020186a:	13300593          	li	a1,307
ffffffffc020186e:	00006517          	auipc	a0,0x6
ffffffffc0201872:	9c250513          	addi	a0,a0,-1598 # ffffffffc0207230 <commands+0x890>
ffffffffc0201876:	993fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(vma != NULL);
ffffffffc020187a:	00006697          	auipc	a3,0x6
ffffffffc020187e:	ca668693          	addi	a3,a3,-858 # ffffffffc0207520 <commands+0xb80>
ffffffffc0201882:	00005617          	auipc	a2,0x5
ffffffffc0201886:	52e60613          	addi	a2,a2,1326 # ffffffffc0206db0 <commands+0x410>
ffffffffc020188a:	15200593          	li	a1,338
ffffffffc020188e:	00006517          	auipc	a0,0x6
ffffffffc0201892:	9a250513          	addi	a0,a0,-1630 # ffffffffc0207230 <commands+0x890>
ffffffffc0201896:	973fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020189a:	00006697          	auipc	a3,0x6
ffffffffc020189e:	a6e68693          	addi	a3,a3,-1426 # ffffffffc0207308 <commands+0x968>
ffffffffc02018a2:	00005617          	auipc	a2,0x5
ffffffffc02018a6:	50e60613          	addi	a2,a2,1294 # ffffffffc0206db0 <commands+0x410>
ffffffffc02018aa:	12000593          	li	a1,288
ffffffffc02018ae:	00006517          	auipc	a0,0x6
ffffffffc02018b2:	98250513          	addi	a0,a0,-1662 # ffffffffc0207230 <commands+0x890>
ffffffffc02018b6:	953fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma3 == NULL);
ffffffffc02018ba:	00006697          	auipc	a3,0x6
ffffffffc02018be:	abe68693          	addi	a3,a3,-1346 # ffffffffc0207378 <commands+0x9d8>
ffffffffc02018c2:	00005617          	auipc	a2,0x5
ffffffffc02018c6:	4ee60613          	addi	a2,a2,1262 # ffffffffc0206db0 <commands+0x410>
ffffffffc02018ca:	12c00593          	li	a1,300
ffffffffc02018ce:	00006517          	auipc	a0,0x6
ffffffffc02018d2:	96250513          	addi	a0,a0,-1694 # ffffffffc0207230 <commands+0x890>
ffffffffc02018d6:	933fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma2 != NULL);
ffffffffc02018da:	00006697          	auipc	a3,0x6
ffffffffc02018de:	a8e68693          	addi	a3,a3,-1394 # ffffffffc0207368 <commands+0x9c8>
ffffffffc02018e2:	00005617          	auipc	a2,0x5
ffffffffc02018e6:	4ce60613          	addi	a2,a2,1230 # ffffffffc0206db0 <commands+0x410>
ffffffffc02018ea:	12a00593          	li	a1,298
ffffffffc02018ee:	00006517          	auipc	a0,0x6
ffffffffc02018f2:	94250513          	addi	a0,a0,-1726 # ffffffffc0207230 <commands+0x890>
ffffffffc02018f6:	913fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma1 != NULL);
ffffffffc02018fa:	00006697          	auipc	a3,0x6
ffffffffc02018fe:	a5e68693          	addi	a3,a3,-1442 # ffffffffc0207358 <commands+0x9b8>
ffffffffc0201902:	00005617          	auipc	a2,0x5
ffffffffc0201906:	4ae60613          	addi	a2,a2,1198 # ffffffffc0206db0 <commands+0x410>
ffffffffc020190a:	12800593          	li	a1,296
ffffffffc020190e:	00006517          	auipc	a0,0x6
ffffffffc0201912:	92250513          	addi	a0,a0,-1758 # ffffffffc0207230 <commands+0x890>
ffffffffc0201916:	8f3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma5 == NULL);
ffffffffc020191a:	00006697          	auipc	a3,0x6
ffffffffc020191e:	a7e68693          	addi	a3,a3,-1410 # ffffffffc0207398 <commands+0x9f8>
ffffffffc0201922:	00005617          	auipc	a2,0x5
ffffffffc0201926:	48e60613          	addi	a2,a2,1166 # ffffffffc0206db0 <commands+0x410>
ffffffffc020192a:	13000593          	li	a1,304
ffffffffc020192e:	00006517          	auipc	a0,0x6
ffffffffc0201932:	90250513          	addi	a0,a0,-1790 # ffffffffc0207230 <commands+0x890>
ffffffffc0201936:	8d3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert(vma4 == NULL);
ffffffffc020193a:	00006697          	auipc	a3,0x6
ffffffffc020193e:	a4e68693          	addi	a3,a3,-1458 # ffffffffc0207388 <commands+0x9e8>
ffffffffc0201942:	00005617          	auipc	a2,0x5
ffffffffc0201946:	46e60613          	addi	a2,a2,1134 # ffffffffc0206db0 <commands+0x410>
ffffffffc020194a:	12e00593          	li	a1,302
ffffffffc020194e:	00006517          	auipc	a0,0x6
ffffffffc0201952:	8e250513          	addi	a0,a0,-1822 # ffffffffc0207230 <commands+0x890>
ffffffffc0201956:	8b3fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020195a:	00006697          	auipc	a3,0x6
ffffffffc020195e:	b0e68693          	addi	a3,a3,-1266 # ffffffffc0207468 <commands+0xac8>
ffffffffc0201962:	00005617          	auipc	a2,0x5
ffffffffc0201966:	44e60613          	addi	a2,a2,1102 # ffffffffc0206db0 <commands+0x410>
ffffffffc020196a:	14b00593          	li	a1,331
ffffffffc020196e:	00006517          	auipc	a0,0x6
ffffffffc0201972:	8c250513          	addi	a0,a0,-1854 # ffffffffc0207230 <commands+0x890>
ffffffffc0201976:	893fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(mm != NULL);
ffffffffc020197a:	00006697          	auipc	a3,0x6
ffffffffc020197e:	93e68693          	addi	a3,a3,-1730 # ffffffffc02072b8 <commands+0x918>
ffffffffc0201982:	00005617          	auipc	a2,0x5
ffffffffc0201986:	42e60613          	addi	a2,a2,1070 # ffffffffc0206db0 <commands+0x410>
ffffffffc020198a:	10c00593          	li	a1,268
ffffffffc020198e:	00006517          	auipc	a0,0x6
ffffffffc0201992:	8a250513          	addi	a0,a0,-1886 # ffffffffc0207230 <commands+0x890>
ffffffffc0201996:	873fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020199a:	00006697          	auipc	a3,0x6
ffffffffc020199e:	b2668693          	addi	a3,a3,-1242 # ffffffffc02074c0 <commands+0xb20>
ffffffffc02019a2:	00005617          	auipc	a2,0x5
ffffffffc02019a6:	40e60613          	addi	a2,a2,1038 # ffffffffc0206db0 <commands+0x410>
ffffffffc02019aa:	17000593          	li	a1,368
ffffffffc02019ae:	00006517          	auipc	a0,0x6
ffffffffc02019b2:	88250513          	addi	a0,a0,-1918 # ffffffffc0207230 <commands+0x890>
ffffffffc02019b6:	853fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc02019ba:	00006617          	auipc	a2,0x6
ffffffffc02019be:	82e60613          	addi	a2,a2,-2002 # ffffffffc02071e8 <commands+0x848>
ffffffffc02019c2:	06900593          	li	a1,105
ffffffffc02019c6:	00005517          	auipc	a0,0x5
ffffffffc02019ca:	78a50513          	addi	a0,a0,1930 # ffffffffc0207150 <commands+0x7b0>
ffffffffc02019ce:	83bfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02019d2:	00006697          	auipc	a3,0x6
ffffffffc02019d6:	aae68693          	addi	a3,a3,-1362 # ffffffffc0207480 <commands+0xae0>
ffffffffc02019da:	00005617          	auipc	a2,0x5
ffffffffc02019de:	3d660613          	addi	a2,a2,982 # ffffffffc0206db0 <commands+0x410>
ffffffffc02019e2:	14f00593          	li	a1,335
ffffffffc02019e6:	00006517          	auipc	a0,0x6
ffffffffc02019ea:	84a50513          	addi	a0,a0,-1974 # ffffffffc0207230 <commands+0x890>
ffffffffc02019ee:	81bfe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02019f2:	00006697          	auipc	a3,0x6
ffffffffc02019f6:	a9e68693          	addi	a3,a3,-1378 # ffffffffc0207490 <commands+0xaf0>
ffffffffc02019fa:	00005617          	auipc	a2,0x5
ffffffffc02019fe:	3b660613          	addi	a2,a2,950 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201a02:	15700593          	li	a1,343
ffffffffc0201a06:	00006517          	auipc	a0,0x6
ffffffffc0201a0a:	82a50513          	addi	a0,a0,-2006 # ffffffffc0207230 <commands+0x890>
ffffffffc0201a0e:	ffafe0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201a12:	00005617          	auipc	a2,0x5
ffffffffc0201a16:	74e60613          	addi	a2,a2,1870 # ffffffffc0207160 <commands+0x7c0>
ffffffffc0201a1a:	06200593          	li	a1,98
ffffffffc0201a1e:	00005517          	auipc	a0,0x5
ffffffffc0201a22:	73250513          	addi	a0,a0,1842 # ffffffffc0207150 <commands+0x7b0>
ffffffffc0201a26:	fe2fe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(sum == 0);
ffffffffc0201a2a:	00006697          	auipc	a3,0x6
ffffffffc0201a2e:	a8668693          	addi	a3,a3,-1402 # ffffffffc02074b0 <commands+0xb10>
ffffffffc0201a32:	00005617          	auipc	a2,0x5
ffffffffc0201a36:	37e60613          	addi	a2,a2,894 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201a3a:	16300593          	li	a1,355
ffffffffc0201a3e:	00005517          	auipc	a0,0x5
ffffffffc0201a42:	7f250513          	addi	a0,a0,2034 # ffffffffc0207230 <commands+0x890>
ffffffffc0201a46:	fc2fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201a4a <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201a4a:	7139                	addi	sp,sp,-64
ffffffffc0201a4c:	f04a                	sd	s2,32(sp)
ffffffffc0201a4e:	892e                	mv	s2,a1
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0201a50:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201a52:	f822                	sd	s0,48(sp)
ffffffffc0201a54:	f426                	sd	s1,40(sp)
ffffffffc0201a56:	fc06                	sd	ra,56(sp)
ffffffffc0201a58:	ec4e                	sd	s3,24(sp)
ffffffffc0201a5a:	8432                	mv	s0,a2
ffffffffc0201a5c:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0201a5e:	f8aff0ef          	jal	ra,ffffffffc02011e8 <find_vma>

    pgfault_num++;
ffffffffc0201a62:	000b1797          	auipc	a5,0xb1
ffffffffc0201a66:	d867a783          	lw	a5,-634(a5) # ffffffffc02b27e8 <pgfault_num>
ffffffffc0201a6a:	2785                	addiw	a5,a5,1
ffffffffc0201a6c:	000b1717          	auipc	a4,0xb1
ffffffffc0201a70:	d6f72e23          	sw	a5,-644(a4) # ffffffffc02b27e8 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201a74:	c94d                	beqz	a0,ffffffffc0201b26 <do_pgfault+0xdc>
ffffffffc0201a76:	651c                	ld	a5,8(a0)
ffffffffc0201a78:	0af46763          	bltu	s0,a5,ffffffffc0201b26 <do_pgfault+0xdc>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201a7c:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0201a7e:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201a80:	8b89                	andi	a5,a5,2
ffffffffc0201a82:	e7ad                	bnez	a5,ffffffffc0201aec <do_pgfault+0xa2>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201a84:	767d                	lui	a2,0xfffff
    ret = -E_NO_MEM;

    pte_t *ptep=NULL;

    // COW
    if ((ptep = get_pte(mm->pgdir, addr, 0)) != NULL) 
ffffffffc0201a86:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201a88:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 0)) != NULL) 
ffffffffc0201a8a:	85a2                	mv	a1,s0
ffffffffc0201a8c:	4601                	li	a2,0
ffffffffc0201a8e:	623010ef          	jal	ra,ffffffffc02038b0 <get_pte>
ffffffffc0201a92:	c501                	beqz	a0,ffffffffc0201a9a <do_pgfault+0x50>
    {
        if((*ptep & PTE_V) & ~(*ptep & PTE_W)) 
ffffffffc0201a94:	611c                	ld	a5,0(a0)
ffffffffc0201a96:	8b85                	andi	a5,a5,1
ffffffffc0201a98:	efa5                	bnez	a5,ffffffffc0201b10 <do_pgfault+0xc6>
        }
    }

    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201a9a:	6c88                	ld	a0,24(s1)
ffffffffc0201a9c:	4605                	li	a2,1
ffffffffc0201a9e:	85a2                	mv	a1,s0
ffffffffc0201aa0:	611010ef          	jal	ra,ffffffffc02038b0 <get_pte>
ffffffffc0201aa4:	c155                	beqz	a0,ffffffffc0201b48 <do_pgfault+0xfe>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0201aa6:	610c                	ld	a1,0(a0)
ffffffffc0201aa8:	c5a1                	beqz	a1,ffffffffc0201af0 <do_pgfault+0xa6>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0201aaa:	000b1797          	auipc	a5,0xb1
ffffffffc0201aae:	d5e7a783          	lw	a5,-674(a5) # ffffffffc02b2808 <swap_init_ok>
ffffffffc0201ab2:	c3d9                	beqz	a5,ffffffffc0201b38 <do_pgfault+0xee>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm, addr, &page);
ffffffffc0201ab4:	85a2                	mv	a1,s0
ffffffffc0201ab6:	0030                	addi	a2,sp,8
ffffffffc0201ab8:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0201aba:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0201abc:	188010ef          	jal	ra,ffffffffc0202c44 <swap_in>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc0201ac0:	65a2                	ld	a1,8(sp)
ffffffffc0201ac2:	6c88                	ld	a0,24(s1)
ffffffffc0201ac4:	86ce                	mv	a3,s3
ffffffffc0201ac6:	8622                	mv	a2,s0
ffffffffc0201ac8:	482020ef          	jal	ra,ffffffffc0203f4a <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc0201acc:	6622                	ld	a2,8(sp)
ffffffffc0201ace:	4685                	li	a3,1
ffffffffc0201ad0:	85a2                	mv	a1,s0
ffffffffc0201ad2:	8526                	mv	a0,s1
ffffffffc0201ad4:	050010ef          	jal	ra,ffffffffc0202b24 <swap_map_swappable>

            page->pra_vaddr = addr;
ffffffffc0201ad8:	67a2                	ld	a5,8(sp)
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc0201ada:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc0201adc:	ff80                	sd	s0,56(a5)
failed:
    return ret;
}
ffffffffc0201ade:	70e2                	ld	ra,56(sp)
ffffffffc0201ae0:	7442                	ld	s0,48(sp)
ffffffffc0201ae2:	74a2                	ld	s1,40(sp)
ffffffffc0201ae4:	7902                	ld	s2,32(sp)
ffffffffc0201ae6:	69e2                	ld	s3,24(sp)
ffffffffc0201ae8:	6121                	addi	sp,sp,64
ffffffffc0201aea:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0201aec:	49dd                	li	s3,23
ffffffffc0201aee:	bf59                	j	ffffffffc0201a84 <do_pgfault+0x3a>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201af0:	6c88                	ld	a0,24(s1)
ffffffffc0201af2:	864e                	mv	a2,s3
ffffffffc0201af4:	85a2                	mv	a1,s0
ffffffffc0201af6:	0ea030ef          	jal	ra,ffffffffc0204be0 <pgdir_alloc_page>
ffffffffc0201afa:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0201afc:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201afe:	f3e5                	bnez	a5,ffffffffc0201ade <do_pgfault+0x94>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0201b00:	00006517          	auipc	a0,0x6
ffffffffc0201b04:	a8050513          	addi	a0,a0,-1408 # ffffffffc0207580 <commands+0xbe0>
ffffffffc0201b08:	dc4fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201b0c:	5571                	li	a0,-4
            goto failed;
ffffffffc0201b0e:	bfc1                	j	ffffffffc0201ade <do_pgfault+0x94>
            return privated_write_state(mm, error_code, addr);
ffffffffc0201b10:	8622                	mv	a2,s0
}
ffffffffc0201b12:	7442                	ld	s0,48(sp)
ffffffffc0201b14:	70e2                	ld	ra,56(sp)
ffffffffc0201b16:	69e2                	ld	s3,24(sp)
            return privated_write_state(mm, error_code, addr);
ffffffffc0201b18:	85ca                	mv	a1,s2
ffffffffc0201b1a:	8526                	mv	a0,s1
}
ffffffffc0201b1c:	7902                	ld	s2,32(sp)
ffffffffc0201b1e:	74a2                	ld	s1,40(sp)
ffffffffc0201b20:	6121                	addi	sp,sp,64
            return privated_write_state(mm, error_code, addr);
ffffffffc0201b22:	caaff06f          	j	ffffffffc0200fcc <privated_write_state>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0201b26:	85a2                	mv	a1,s0
ffffffffc0201b28:	00006517          	auipc	a0,0x6
ffffffffc0201b2c:	a0850513          	addi	a0,a0,-1528 # ffffffffc0207530 <commands+0xb90>
ffffffffc0201b30:	d9cfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = -E_INVAL;
ffffffffc0201b34:	5575                	li	a0,-3
        goto failed;
ffffffffc0201b36:	b765                	j	ffffffffc0201ade <do_pgfault+0x94>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0201b38:	00006517          	auipc	a0,0x6
ffffffffc0201b3c:	a7050513          	addi	a0,a0,-1424 # ffffffffc02075a8 <commands+0xc08>
ffffffffc0201b40:	d8cfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201b44:	5571                	li	a0,-4
            goto failed;
ffffffffc0201b46:	bf61                	j	ffffffffc0201ade <do_pgfault+0x94>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0201b48:	00006517          	auipc	a0,0x6
ffffffffc0201b4c:	a1850513          	addi	a0,a0,-1512 # ffffffffc0207560 <commands+0xbc0>
ffffffffc0201b50:	d7cfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201b54:	5571                	li	a0,-4
        goto failed;
ffffffffc0201b56:	b761                	j	ffffffffc0201ade <do_pgfault+0x94>

ffffffffc0201b58 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0201b58:	7179                	addi	sp,sp,-48
ffffffffc0201b5a:	f022                	sd	s0,32(sp)
ffffffffc0201b5c:	f406                	sd	ra,40(sp)
ffffffffc0201b5e:	ec26                	sd	s1,24(sp)
ffffffffc0201b60:	e84a                	sd	s2,16(sp)
ffffffffc0201b62:	e44e                	sd	s3,8(sp)
ffffffffc0201b64:	e052                	sd	s4,0(sp)
ffffffffc0201b66:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0201b68:	c135                	beqz	a0,ffffffffc0201bcc <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0201b6a:	002007b7          	lui	a5,0x200
ffffffffc0201b6e:	04f5e663          	bltu	a1,a5,ffffffffc0201bba <user_mem_check+0x62>
ffffffffc0201b72:	00c584b3          	add	s1,a1,a2
ffffffffc0201b76:	0495f263          	bgeu	a1,s1,ffffffffc0201bba <user_mem_check+0x62>
ffffffffc0201b7a:	4785                	li	a5,1
ffffffffc0201b7c:	07fe                	slli	a5,a5,0x1f
ffffffffc0201b7e:	0297ee63          	bltu	a5,s1,ffffffffc0201bba <user_mem_check+0x62>
ffffffffc0201b82:	892a                	mv	s2,a0
ffffffffc0201b84:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0201b86:	6a05                	lui	s4,0x1
ffffffffc0201b88:	a821                	j	ffffffffc0201ba0 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201b8a:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0201b8e:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0201b90:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201b92:	c685                	beqz	a3,ffffffffc0201bba <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0201b94:	c399                	beqz	a5,ffffffffc0201b9a <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0201b96:	02e46263          	bltu	s0,a4,ffffffffc0201bba <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0201b9a:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0201b9c:	04947663          	bgeu	s0,s1,ffffffffc0201be8 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0201ba0:	85a2                	mv	a1,s0
ffffffffc0201ba2:	854a                	mv	a0,s2
ffffffffc0201ba4:	e44ff0ef          	jal	ra,ffffffffc02011e8 <find_vma>
ffffffffc0201ba8:	c909                	beqz	a0,ffffffffc0201bba <user_mem_check+0x62>
ffffffffc0201baa:	6518                	ld	a4,8(a0)
ffffffffc0201bac:	00e46763          	bltu	s0,a4,ffffffffc0201bba <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201bb0:	4d1c                	lw	a5,24(a0)
ffffffffc0201bb2:	fc099ce3          	bnez	s3,ffffffffc0201b8a <user_mem_check+0x32>
ffffffffc0201bb6:	8b85                	andi	a5,a5,1
ffffffffc0201bb8:	f3ed                	bnez	a5,ffffffffc0201b9a <user_mem_check+0x42>
            return 0;
ffffffffc0201bba:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0201bbc:	70a2                	ld	ra,40(sp)
ffffffffc0201bbe:	7402                	ld	s0,32(sp)
ffffffffc0201bc0:	64e2                	ld	s1,24(sp)
ffffffffc0201bc2:	6942                	ld	s2,16(sp)
ffffffffc0201bc4:	69a2                	ld	s3,8(sp)
ffffffffc0201bc6:	6a02                	ld	s4,0(sp)
ffffffffc0201bc8:	6145                	addi	sp,sp,48
ffffffffc0201bca:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0201bcc:	c02007b7          	lui	a5,0xc0200
ffffffffc0201bd0:	4501                	li	a0,0
ffffffffc0201bd2:	fef5e5e3          	bltu	a1,a5,ffffffffc0201bbc <user_mem_check+0x64>
ffffffffc0201bd6:	962e                	add	a2,a2,a1
ffffffffc0201bd8:	fec5f2e3          	bgeu	a1,a2,ffffffffc0201bbc <user_mem_check+0x64>
ffffffffc0201bdc:	c8000537          	lui	a0,0xc8000
ffffffffc0201be0:	0505                	addi	a0,a0,1
ffffffffc0201be2:	00a63533          	sltu	a0,a2,a0
ffffffffc0201be6:	bfd9                	j	ffffffffc0201bbc <user_mem_check+0x64>
        return 1;
ffffffffc0201be8:	4505                	li	a0,1
ffffffffc0201bea:	bfc9                	j	ffffffffc0201bbc <user_mem_check+0x64>

ffffffffc0201bec <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0201bec:	000ad797          	auipc	a5,0xad
ffffffffc0201bf0:	b1478793          	addi	a5,a5,-1260 # ffffffffc02ae700 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0201bf4:	f51c                	sd	a5,40(a0)
ffffffffc0201bf6:	e79c                	sd	a5,8(a5)
ffffffffc0201bf8:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0201bfa:	4501                	li	a0,0
ffffffffc0201bfc:	8082                	ret

ffffffffc0201bfe <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0201bfe:	4501                	li	a0,0
ffffffffc0201c00:	8082                	ret

ffffffffc0201c02 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0201c02:	4501                	li	a0,0
ffffffffc0201c04:	8082                	ret

ffffffffc0201c06 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0201c06:	4501                	li	a0,0
ffffffffc0201c08:	8082                	ret

ffffffffc0201c0a <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0201c0a:	711d                	addi	sp,sp,-96
ffffffffc0201c0c:	fc4e                	sd	s3,56(sp)
ffffffffc0201c0e:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201c10:	00006517          	auipc	a0,0x6
ffffffffc0201c14:	9c050513          	addi	a0,a0,-1600 # ffffffffc02075d0 <commands+0xc30>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201c18:	698d                	lui	s3,0x3
ffffffffc0201c1a:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0201c1c:	e0ca                	sd	s2,64(sp)
ffffffffc0201c1e:	ec86                	sd	ra,88(sp)
ffffffffc0201c20:	e8a2                	sd	s0,80(sp)
ffffffffc0201c22:	e4a6                	sd	s1,72(sp)
ffffffffc0201c24:	f456                	sd	s5,40(sp)
ffffffffc0201c26:	f05a                	sd	s6,32(sp)
ffffffffc0201c28:	ec5e                	sd	s7,24(sp)
ffffffffc0201c2a:	e862                	sd	s8,16(sp)
ffffffffc0201c2c:	e466                	sd	s9,8(sp)
ffffffffc0201c2e:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201c30:	c9cfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201c34:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb0>
    assert(pgfault_num==4);
ffffffffc0201c38:	000b1917          	auipc	s2,0xb1
ffffffffc0201c3c:	bb092903          	lw	s2,-1104(s2) # ffffffffc02b27e8 <pgfault_num>
ffffffffc0201c40:	4791                	li	a5,4
ffffffffc0201c42:	14f91e63          	bne	s2,a5,ffffffffc0201d9e <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201c46:	00006517          	auipc	a0,0x6
ffffffffc0201c4a:	9da50513          	addi	a0,a0,-1574 # ffffffffc0207620 <commands+0xc80>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201c4e:	6a85                	lui	s5,0x1
ffffffffc0201c50:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201c52:	c7afe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0201c56:	000b1417          	auipc	s0,0xb1
ffffffffc0201c5a:	b9240413          	addi	s0,s0,-1134 # ffffffffc02b27e8 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201c5e:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
    assert(pgfault_num==4);
ffffffffc0201c62:	4004                	lw	s1,0(s0)
ffffffffc0201c64:	2481                	sext.w	s1,s1
ffffffffc0201c66:	2b249c63          	bne	s1,s2,ffffffffc0201f1e <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201c6a:	00006517          	auipc	a0,0x6
ffffffffc0201c6e:	9de50513          	addi	a0,a0,-1570 # ffffffffc0207648 <commands+0xca8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201c72:	6b91                	lui	s7,0x4
ffffffffc0201c74:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201c76:	c56fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201c7a:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5bb0>
    assert(pgfault_num==4);
ffffffffc0201c7e:	00042903          	lw	s2,0(s0)
ffffffffc0201c82:	2901                	sext.w	s2,s2
ffffffffc0201c84:	26991d63          	bne	s2,s1,ffffffffc0201efe <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201c88:	00006517          	auipc	a0,0x6
ffffffffc0201c8c:	9e850513          	addi	a0,a0,-1560 # ffffffffc0207670 <commands+0xcd0>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201c90:	6c89                	lui	s9,0x2
ffffffffc0201c92:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201c94:	c38fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201c98:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7bb0>
    assert(pgfault_num==4);
ffffffffc0201c9c:	401c                	lw	a5,0(s0)
ffffffffc0201c9e:	2781                	sext.w	a5,a5
ffffffffc0201ca0:	23279f63          	bne	a5,s2,ffffffffc0201ede <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201ca4:	00006517          	auipc	a0,0x6
ffffffffc0201ca8:	9f450513          	addi	a0,a0,-1548 # ffffffffc0207698 <commands+0xcf8>
ffffffffc0201cac:	c20fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201cb0:	6795                	lui	a5,0x5
ffffffffc0201cb2:	4739                	li	a4,14
ffffffffc0201cb4:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb0>
    assert(pgfault_num==5);
ffffffffc0201cb8:	4004                	lw	s1,0(s0)
ffffffffc0201cba:	4795                	li	a5,5
ffffffffc0201cbc:	2481                	sext.w	s1,s1
ffffffffc0201cbe:	20f49063          	bne	s1,a5,ffffffffc0201ebe <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201cc2:	00006517          	auipc	a0,0x6
ffffffffc0201cc6:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0207670 <commands+0xcd0>
ffffffffc0201cca:	c02fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201cce:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0201cd2:	401c                	lw	a5,0(s0)
ffffffffc0201cd4:	2781                	sext.w	a5,a5
ffffffffc0201cd6:	1c979463          	bne	a5,s1,ffffffffc0201e9e <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201cda:	00006517          	auipc	a0,0x6
ffffffffc0201cde:	94650513          	addi	a0,a0,-1722 # ffffffffc0207620 <commands+0xc80>
ffffffffc0201ce2:	beafe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201ce6:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0201cea:	401c                	lw	a5,0(s0)
ffffffffc0201cec:	4719                	li	a4,6
ffffffffc0201cee:	2781                	sext.w	a5,a5
ffffffffc0201cf0:	18e79763          	bne	a5,a4,ffffffffc0201e7e <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201cf4:	00006517          	auipc	a0,0x6
ffffffffc0201cf8:	97c50513          	addi	a0,a0,-1668 # ffffffffc0207670 <commands+0xcd0>
ffffffffc0201cfc:	bd0fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201d00:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0201d04:	401c                	lw	a5,0(s0)
ffffffffc0201d06:	471d                	li	a4,7
ffffffffc0201d08:	2781                	sext.w	a5,a5
ffffffffc0201d0a:	14e79a63          	bne	a5,a4,ffffffffc0201e5e <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201d0e:	00006517          	auipc	a0,0x6
ffffffffc0201d12:	8c250513          	addi	a0,a0,-1854 # ffffffffc02075d0 <commands+0xc30>
ffffffffc0201d16:	bb6fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201d1a:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0201d1e:	401c                	lw	a5,0(s0)
ffffffffc0201d20:	4721                	li	a4,8
ffffffffc0201d22:	2781                	sext.w	a5,a5
ffffffffc0201d24:	10e79d63          	bne	a5,a4,ffffffffc0201e3e <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201d28:	00006517          	auipc	a0,0x6
ffffffffc0201d2c:	92050513          	addi	a0,a0,-1760 # ffffffffc0207648 <commands+0xca8>
ffffffffc0201d30:	b9cfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201d34:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0201d38:	401c                	lw	a5,0(s0)
ffffffffc0201d3a:	4725                	li	a4,9
ffffffffc0201d3c:	2781                	sext.w	a5,a5
ffffffffc0201d3e:	0ee79063          	bne	a5,a4,ffffffffc0201e1e <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201d42:	00006517          	auipc	a0,0x6
ffffffffc0201d46:	95650513          	addi	a0,a0,-1706 # ffffffffc0207698 <commands+0xcf8>
ffffffffc0201d4a:	b82fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201d4e:	6795                	lui	a5,0x5
ffffffffc0201d50:	4739                	li	a4,14
ffffffffc0201d52:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bb0>
    assert(pgfault_num==10);
ffffffffc0201d56:	4004                	lw	s1,0(s0)
ffffffffc0201d58:	47a9                	li	a5,10
ffffffffc0201d5a:	2481                	sext.w	s1,s1
ffffffffc0201d5c:	0af49163          	bne	s1,a5,ffffffffc0201dfe <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201d60:	00006517          	auipc	a0,0x6
ffffffffc0201d64:	8c050513          	addi	a0,a0,-1856 # ffffffffc0207620 <commands+0xc80>
ffffffffc0201d68:	b64fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201d6c:	6785                	lui	a5,0x1
ffffffffc0201d6e:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0201d72:	06979663          	bne	a5,s1,ffffffffc0201dde <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0201d76:	401c                	lw	a5,0(s0)
ffffffffc0201d78:	472d                	li	a4,11
ffffffffc0201d7a:	2781                	sext.w	a5,a5
ffffffffc0201d7c:	04e79163          	bne	a5,a4,ffffffffc0201dbe <_fifo_check_swap+0x1b4>
}
ffffffffc0201d80:	60e6                	ld	ra,88(sp)
ffffffffc0201d82:	6446                	ld	s0,80(sp)
ffffffffc0201d84:	64a6                	ld	s1,72(sp)
ffffffffc0201d86:	6906                	ld	s2,64(sp)
ffffffffc0201d88:	79e2                	ld	s3,56(sp)
ffffffffc0201d8a:	7a42                	ld	s4,48(sp)
ffffffffc0201d8c:	7aa2                	ld	s5,40(sp)
ffffffffc0201d8e:	7b02                	ld	s6,32(sp)
ffffffffc0201d90:	6be2                	ld	s7,24(sp)
ffffffffc0201d92:	6c42                	ld	s8,16(sp)
ffffffffc0201d94:	6ca2                	ld	s9,8(sp)
ffffffffc0201d96:	6d02                	ld	s10,0(sp)
ffffffffc0201d98:	4501                	li	a0,0
ffffffffc0201d9a:	6125                	addi	sp,sp,96
ffffffffc0201d9c:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0201d9e:	00006697          	auipc	a3,0x6
ffffffffc0201da2:	85a68693          	addi	a3,a3,-1958 # ffffffffc02075f8 <commands+0xc58>
ffffffffc0201da6:	00005617          	auipc	a2,0x5
ffffffffc0201daa:	00a60613          	addi	a2,a2,10 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201dae:	05100593          	li	a1,81
ffffffffc0201db2:	00006517          	auipc	a0,0x6
ffffffffc0201db6:	85650513          	addi	a0,a0,-1962 # ffffffffc0207608 <commands+0xc68>
ffffffffc0201dba:	c4efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==11);
ffffffffc0201dbe:	00006697          	auipc	a3,0x6
ffffffffc0201dc2:	98a68693          	addi	a3,a3,-1654 # ffffffffc0207748 <commands+0xda8>
ffffffffc0201dc6:	00005617          	auipc	a2,0x5
ffffffffc0201dca:	fea60613          	addi	a2,a2,-22 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201dce:	07300593          	li	a1,115
ffffffffc0201dd2:	00006517          	auipc	a0,0x6
ffffffffc0201dd6:	83650513          	addi	a0,a0,-1994 # ffffffffc0207608 <commands+0xc68>
ffffffffc0201dda:	c2efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201dde:	00006697          	auipc	a3,0x6
ffffffffc0201de2:	94268693          	addi	a3,a3,-1726 # ffffffffc0207720 <commands+0xd80>
ffffffffc0201de6:	00005617          	auipc	a2,0x5
ffffffffc0201dea:	fca60613          	addi	a2,a2,-54 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201dee:	07100593          	li	a1,113
ffffffffc0201df2:	00006517          	auipc	a0,0x6
ffffffffc0201df6:	81650513          	addi	a0,a0,-2026 # ffffffffc0207608 <commands+0xc68>
ffffffffc0201dfa:	c0efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==10);
ffffffffc0201dfe:	00006697          	auipc	a3,0x6
ffffffffc0201e02:	91268693          	addi	a3,a3,-1774 # ffffffffc0207710 <commands+0xd70>
ffffffffc0201e06:	00005617          	auipc	a2,0x5
ffffffffc0201e0a:	faa60613          	addi	a2,a2,-86 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201e0e:	06f00593          	li	a1,111
ffffffffc0201e12:	00005517          	auipc	a0,0x5
ffffffffc0201e16:	7f650513          	addi	a0,a0,2038 # ffffffffc0207608 <commands+0xc68>
ffffffffc0201e1a:	beefe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==9);
ffffffffc0201e1e:	00006697          	auipc	a3,0x6
ffffffffc0201e22:	8e268693          	addi	a3,a3,-1822 # ffffffffc0207700 <commands+0xd60>
ffffffffc0201e26:	00005617          	auipc	a2,0x5
ffffffffc0201e2a:	f8a60613          	addi	a2,a2,-118 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201e2e:	06c00593          	li	a1,108
ffffffffc0201e32:	00005517          	auipc	a0,0x5
ffffffffc0201e36:	7d650513          	addi	a0,a0,2006 # ffffffffc0207608 <commands+0xc68>
ffffffffc0201e3a:	bcefe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==8);
ffffffffc0201e3e:	00006697          	auipc	a3,0x6
ffffffffc0201e42:	8b268693          	addi	a3,a3,-1870 # ffffffffc02076f0 <commands+0xd50>
ffffffffc0201e46:	00005617          	auipc	a2,0x5
ffffffffc0201e4a:	f6a60613          	addi	a2,a2,-150 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201e4e:	06900593          	li	a1,105
ffffffffc0201e52:	00005517          	auipc	a0,0x5
ffffffffc0201e56:	7b650513          	addi	a0,a0,1974 # ffffffffc0207608 <commands+0xc68>
ffffffffc0201e5a:	baefe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==7);
ffffffffc0201e5e:	00006697          	auipc	a3,0x6
ffffffffc0201e62:	88268693          	addi	a3,a3,-1918 # ffffffffc02076e0 <commands+0xd40>
ffffffffc0201e66:	00005617          	auipc	a2,0x5
ffffffffc0201e6a:	f4a60613          	addi	a2,a2,-182 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201e6e:	06600593          	li	a1,102
ffffffffc0201e72:	00005517          	auipc	a0,0x5
ffffffffc0201e76:	79650513          	addi	a0,a0,1942 # ffffffffc0207608 <commands+0xc68>
ffffffffc0201e7a:	b8efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==6);
ffffffffc0201e7e:	00006697          	auipc	a3,0x6
ffffffffc0201e82:	85268693          	addi	a3,a3,-1966 # ffffffffc02076d0 <commands+0xd30>
ffffffffc0201e86:	00005617          	auipc	a2,0x5
ffffffffc0201e8a:	f2a60613          	addi	a2,a2,-214 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201e8e:	06300593          	li	a1,99
ffffffffc0201e92:	00005517          	auipc	a0,0x5
ffffffffc0201e96:	77650513          	addi	a0,a0,1910 # ffffffffc0207608 <commands+0xc68>
ffffffffc0201e9a:	b6efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc0201e9e:	00006697          	auipc	a3,0x6
ffffffffc0201ea2:	82268693          	addi	a3,a3,-2014 # ffffffffc02076c0 <commands+0xd20>
ffffffffc0201ea6:	00005617          	auipc	a2,0x5
ffffffffc0201eaa:	f0a60613          	addi	a2,a2,-246 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201eae:	06000593          	li	a1,96
ffffffffc0201eb2:	00005517          	auipc	a0,0x5
ffffffffc0201eb6:	75650513          	addi	a0,a0,1878 # ffffffffc0207608 <commands+0xc68>
ffffffffc0201eba:	b4efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==5);
ffffffffc0201ebe:	00006697          	auipc	a3,0x6
ffffffffc0201ec2:	80268693          	addi	a3,a3,-2046 # ffffffffc02076c0 <commands+0xd20>
ffffffffc0201ec6:	00005617          	auipc	a2,0x5
ffffffffc0201eca:	eea60613          	addi	a2,a2,-278 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201ece:	05d00593          	li	a1,93
ffffffffc0201ed2:	00005517          	auipc	a0,0x5
ffffffffc0201ed6:	73650513          	addi	a0,a0,1846 # ffffffffc0207608 <commands+0xc68>
ffffffffc0201eda:	b2efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0201ede:	00005697          	auipc	a3,0x5
ffffffffc0201ee2:	71a68693          	addi	a3,a3,1818 # ffffffffc02075f8 <commands+0xc58>
ffffffffc0201ee6:	00005617          	auipc	a2,0x5
ffffffffc0201eea:	eca60613          	addi	a2,a2,-310 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201eee:	05a00593          	li	a1,90
ffffffffc0201ef2:	00005517          	auipc	a0,0x5
ffffffffc0201ef6:	71650513          	addi	a0,a0,1814 # ffffffffc0207608 <commands+0xc68>
ffffffffc0201efa:	b0efe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0201efe:	00005697          	auipc	a3,0x5
ffffffffc0201f02:	6fa68693          	addi	a3,a3,1786 # ffffffffc02075f8 <commands+0xc58>
ffffffffc0201f06:	00005617          	auipc	a2,0x5
ffffffffc0201f0a:	eaa60613          	addi	a2,a2,-342 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201f0e:	05700593          	li	a1,87
ffffffffc0201f12:	00005517          	auipc	a0,0x5
ffffffffc0201f16:	6f650513          	addi	a0,a0,1782 # ffffffffc0207608 <commands+0xc68>
ffffffffc0201f1a:	aeefe0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgfault_num==4);
ffffffffc0201f1e:	00005697          	auipc	a3,0x5
ffffffffc0201f22:	6da68693          	addi	a3,a3,1754 # ffffffffc02075f8 <commands+0xc58>
ffffffffc0201f26:	00005617          	auipc	a2,0x5
ffffffffc0201f2a:	e8a60613          	addi	a2,a2,-374 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201f2e:	05400593          	li	a1,84
ffffffffc0201f32:	00005517          	auipc	a0,0x5
ffffffffc0201f36:	6d650513          	addi	a0,a0,1750 # ffffffffc0207608 <commands+0xc68>
ffffffffc0201f3a:	acefe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201f3e <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201f3e:	751c                	ld	a5,40(a0)
{
ffffffffc0201f40:	1141                	addi	sp,sp,-16
ffffffffc0201f42:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0201f44:	cf91                	beqz	a5,ffffffffc0201f60 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0201f46:	ee0d                	bnez	a2,ffffffffc0201f80 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0201f48:	679c                	ld	a5,8(a5)
}
ffffffffc0201f4a:	60a2                	ld	ra,8(sp)
ffffffffc0201f4c:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0201f4e:	6394                	ld	a3,0(a5)
ffffffffc0201f50:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0201f52:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0201f56:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0201f58:	e314                	sd	a3,0(a4)
ffffffffc0201f5a:	e19c                	sd	a5,0(a1)
}
ffffffffc0201f5c:	0141                	addi	sp,sp,16
ffffffffc0201f5e:	8082                	ret
         assert(head != NULL);
ffffffffc0201f60:	00005697          	auipc	a3,0x5
ffffffffc0201f64:	7f868693          	addi	a3,a3,2040 # ffffffffc0207758 <commands+0xdb8>
ffffffffc0201f68:	00005617          	auipc	a2,0x5
ffffffffc0201f6c:	e4860613          	addi	a2,a2,-440 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201f70:	04100593          	li	a1,65
ffffffffc0201f74:	00005517          	auipc	a0,0x5
ffffffffc0201f78:	69450513          	addi	a0,a0,1684 # ffffffffc0207608 <commands+0xc68>
ffffffffc0201f7c:	a8cfe0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(in_tick==0);
ffffffffc0201f80:	00005697          	auipc	a3,0x5
ffffffffc0201f84:	7e868693          	addi	a3,a3,2024 # ffffffffc0207768 <commands+0xdc8>
ffffffffc0201f88:	00005617          	auipc	a2,0x5
ffffffffc0201f8c:	e2860613          	addi	a2,a2,-472 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201f90:	04200593          	li	a1,66
ffffffffc0201f94:	00005517          	auipc	a0,0x5
ffffffffc0201f98:	67450513          	addi	a0,a0,1652 # ffffffffc0207608 <commands+0xc68>
ffffffffc0201f9c:	a6cfe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201fa0 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201fa0:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0201fa2:	cb91                	beqz	a5,ffffffffc0201fb6 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201fa4:	6394                	ld	a3,0(a5)
ffffffffc0201fa6:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc0201faa:	e398                	sd	a4,0(a5)
ffffffffc0201fac:	e698                	sd	a4,8(a3)
}
ffffffffc0201fae:	4501                	li	a0,0
    elm->next = next;
ffffffffc0201fb0:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0201fb2:	f614                	sd	a3,40(a2)
ffffffffc0201fb4:	8082                	ret
{
ffffffffc0201fb6:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0201fb8:	00005697          	auipc	a3,0x5
ffffffffc0201fbc:	7c068693          	addi	a3,a3,1984 # ffffffffc0207778 <commands+0xdd8>
ffffffffc0201fc0:	00005617          	auipc	a2,0x5
ffffffffc0201fc4:	df060613          	addi	a2,a2,-528 # ffffffffc0206db0 <commands+0x410>
ffffffffc0201fc8:	03200593          	li	a1,50
ffffffffc0201fcc:	00005517          	auipc	a0,0x5
ffffffffc0201fd0:	63c50513          	addi	a0,a0,1596 # ffffffffc0207608 <commands+0xc68>
{
ffffffffc0201fd4:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0201fd6:	a32fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0201fda <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201fda:	c94d                	beqz	a0,ffffffffc020208c <slob_free+0xb2>
{
ffffffffc0201fdc:	1141                	addi	sp,sp,-16
ffffffffc0201fde:	e022                	sd	s0,0(sp)
ffffffffc0201fe0:	e406                	sd	ra,8(sp)
ffffffffc0201fe2:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201fe4:	e9c1                	bnez	a1,ffffffffc0202074 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201fe6:	100027f3          	csrr	a5,sstatus
ffffffffc0201fea:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201fec:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201fee:	ebd9                	bnez	a5,ffffffffc0202084 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201ff0:	000a5617          	auipc	a2,0xa5
ffffffffc0201ff4:	30060613          	addi	a2,a2,768 # ffffffffc02a72f0 <slobfree>
ffffffffc0201ff8:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201ffa:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201ffc:	679c                	ld	a5,8(a5)
ffffffffc0201ffe:	02877a63          	bgeu	a4,s0,ffffffffc0202032 <slob_free+0x58>
ffffffffc0202002:	00f46463          	bltu	s0,a5,ffffffffc020200a <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202006:	fef76ae3          	bltu	a4,a5,ffffffffc0201ffa <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc020200a:	400c                	lw	a1,0(s0)
ffffffffc020200c:	00459693          	slli	a3,a1,0x4
ffffffffc0202010:	96a2                	add	a3,a3,s0
ffffffffc0202012:	02d78a63          	beq	a5,a3,ffffffffc0202046 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0202016:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0202018:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc020201a:	00469793          	slli	a5,a3,0x4
ffffffffc020201e:	97ba                	add	a5,a5,a4
ffffffffc0202020:	02f40e63          	beq	s0,a5,ffffffffc020205c <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0202024:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0202026:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc0202028:	e129                	bnez	a0,ffffffffc020206a <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc020202a:	60a2                	ld	ra,8(sp)
ffffffffc020202c:	6402                	ld	s0,0(sp)
ffffffffc020202e:	0141                	addi	sp,sp,16
ffffffffc0202030:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202032:	fcf764e3          	bltu	a4,a5,ffffffffc0201ffa <slob_free+0x20>
ffffffffc0202036:	fcf472e3          	bgeu	s0,a5,ffffffffc0201ffa <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc020203a:	400c                	lw	a1,0(s0)
ffffffffc020203c:	00459693          	slli	a3,a1,0x4
ffffffffc0202040:	96a2                	add	a3,a3,s0
ffffffffc0202042:	fcd79ae3          	bne	a5,a3,ffffffffc0202016 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0202046:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0202048:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc020204a:	9db5                	addw	a1,a1,a3
ffffffffc020204c:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc020204e:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0202050:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0202052:	00469793          	slli	a5,a3,0x4
ffffffffc0202056:	97ba                	add	a5,a5,a4
ffffffffc0202058:	fcf416e3          	bne	s0,a5,ffffffffc0202024 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc020205c:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc020205e:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0202060:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0202062:	9ebd                	addw	a3,a3,a5
ffffffffc0202064:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0202066:	e70c                	sd	a1,8(a4)
ffffffffc0202068:	d169                	beqz	a0,ffffffffc020202a <slob_free+0x50>
}
ffffffffc020206a:	6402                	ld	s0,0(sp)
ffffffffc020206c:	60a2                	ld	ra,8(sp)
ffffffffc020206e:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0202070:	dd2fe06f          	j	ffffffffc0200642 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0202074:	25bd                	addiw	a1,a1,15
ffffffffc0202076:	8191                	srli	a1,a1,0x4
ffffffffc0202078:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020207a:	100027f3          	csrr	a5,sstatus
ffffffffc020207e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0202080:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202082:	d7bd                	beqz	a5,ffffffffc0201ff0 <slob_free+0x16>
        intr_disable();
ffffffffc0202084:	dc4fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0202088:	4505                	li	a0,1
ffffffffc020208a:	b79d                	j	ffffffffc0201ff0 <slob_free+0x16>
ffffffffc020208c:	8082                	ret

ffffffffc020208e <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc020208e:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202090:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202092:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202096:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202098:	70c010ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
  if(!page)
ffffffffc020209c:	c91d                	beqz	a0,ffffffffc02020d2 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc020209e:	000b0697          	auipc	a3,0xb0
ffffffffc02020a2:	78a6b683          	ld	a3,1930(a3) # ffffffffc02b2828 <pages>
ffffffffc02020a6:	8d15                	sub	a0,a0,a3
ffffffffc02020a8:	8519                	srai	a0,a0,0x6
ffffffffc02020aa:	00007697          	auipc	a3,0x7
ffffffffc02020ae:	d9e6b683          	ld	a3,-610(a3) # ffffffffc0208e48 <nbase>
ffffffffc02020b2:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc02020b4:	00c51793          	slli	a5,a0,0xc
ffffffffc02020b8:	83b1                	srli	a5,a5,0xc
ffffffffc02020ba:	000b0717          	auipc	a4,0xb0
ffffffffc02020be:	76673703          	ld	a4,1894(a4) # ffffffffc02b2820 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc02020c2:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02020c4:	00e7fa63          	bgeu	a5,a4,ffffffffc02020d8 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02020c8:	000b0697          	auipc	a3,0xb0
ffffffffc02020cc:	7706b683          	ld	a3,1904(a3) # ffffffffc02b2838 <va_pa_offset>
ffffffffc02020d0:	9536                	add	a0,a0,a3
}
ffffffffc02020d2:	60a2                	ld	ra,8(sp)
ffffffffc02020d4:	0141                	addi	sp,sp,16
ffffffffc02020d6:	8082                	ret
ffffffffc02020d8:	86aa                	mv	a3,a0
ffffffffc02020da:	00005617          	auipc	a2,0x5
ffffffffc02020de:	10e60613          	addi	a2,a2,270 # ffffffffc02071e8 <commands+0x848>
ffffffffc02020e2:	06900593          	li	a1,105
ffffffffc02020e6:	00005517          	auipc	a0,0x5
ffffffffc02020ea:	06a50513          	addi	a0,a0,106 # ffffffffc0207150 <commands+0x7b0>
ffffffffc02020ee:	91afe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02020f2 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02020f2:	1101                	addi	sp,sp,-32
ffffffffc02020f4:	ec06                	sd	ra,24(sp)
ffffffffc02020f6:	e822                	sd	s0,16(sp)
ffffffffc02020f8:	e426                	sd	s1,8(sp)
ffffffffc02020fa:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02020fc:	01050713          	addi	a4,a0,16
ffffffffc0202100:	6785                	lui	a5,0x1
ffffffffc0202102:	0cf77363          	bgeu	a4,a5,ffffffffc02021c8 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0202106:	00f50493          	addi	s1,a0,15
ffffffffc020210a:	8091                	srli	s1,s1,0x4
ffffffffc020210c:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020210e:	10002673          	csrr	a2,sstatus
ffffffffc0202112:	8a09                	andi	a2,a2,2
ffffffffc0202114:	e25d                	bnez	a2,ffffffffc02021ba <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0202116:	000a5917          	auipc	s2,0xa5
ffffffffc020211a:	1da90913          	addi	s2,s2,474 # ffffffffc02a72f0 <slobfree>
ffffffffc020211e:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202122:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202124:	4398                	lw	a4,0(a5)
ffffffffc0202126:	08975e63          	bge	a4,s1,ffffffffc02021c2 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc020212a:	00f68b63          	beq	a3,a5,ffffffffc0202140 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020212e:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202130:	4018                	lw	a4,0(s0)
ffffffffc0202132:	02975a63          	bge	a4,s1,ffffffffc0202166 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0202136:	00093683          	ld	a3,0(s2)
ffffffffc020213a:	87a2                	mv	a5,s0
ffffffffc020213c:	fef699e3          	bne	a3,a5,ffffffffc020212e <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0202140:	ee31                	bnez	a2,ffffffffc020219c <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0202142:	4501                	li	a0,0
ffffffffc0202144:	f4bff0ef          	jal	ra,ffffffffc020208e <__slob_get_free_pages.constprop.0>
ffffffffc0202148:	842a                	mv	s0,a0
			if (!cur)
ffffffffc020214a:	cd05                	beqz	a0,ffffffffc0202182 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc020214c:	6585                	lui	a1,0x1
ffffffffc020214e:	e8dff0ef          	jal	ra,ffffffffc0201fda <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202152:	10002673          	csrr	a2,sstatus
ffffffffc0202156:	8a09                	andi	a2,a2,2
ffffffffc0202158:	ee05                	bnez	a2,ffffffffc0202190 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc020215a:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020215e:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202160:	4018                	lw	a4,0(s0)
ffffffffc0202162:	fc974ae3          	blt	a4,s1,ffffffffc0202136 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0202166:	04e48763          	beq	s1,a4,ffffffffc02021b4 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc020216a:	00449693          	slli	a3,s1,0x4
ffffffffc020216e:	96a2                	add	a3,a3,s0
ffffffffc0202170:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0202172:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0202174:	9f05                	subw	a4,a4,s1
ffffffffc0202176:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0202178:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc020217a:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc020217c:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0202180:	e20d                	bnez	a2,ffffffffc02021a2 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0202182:	60e2                	ld	ra,24(sp)
ffffffffc0202184:	8522                	mv	a0,s0
ffffffffc0202186:	6442                	ld	s0,16(sp)
ffffffffc0202188:	64a2                	ld	s1,8(sp)
ffffffffc020218a:	6902                	ld	s2,0(sp)
ffffffffc020218c:	6105                	addi	sp,sp,32
ffffffffc020218e:	8082                	ret
        intr_disable();
ffffffffc0202190:	cb8fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
			cur = slobfree;
ffffffffc0202194:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0202198:	4605                	li	a2,1
ffffffffc020219a:	b7d1                	j	ffffffffc020215e <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc020219c:	ca6fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02021a0:	b74d                	j	ffffffffc0202142 <slob_alloc.constprop.0+0x50>
ffffffffc02021a2:	ca0fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
}
ffffffffc02021a6:	60e2                	ld	ra,24(sp)
ffffffffc02021a8:	8522                	mv	a0,s0
ffffffffc02021aa:	6442                	ld	s0,16(sp)
ffffffffc02021ac:	64a2                	ld	s1,8(sp)
ffffffffc02021ae:	6902                	ld	s2,0(sp)
ffffffffc02021b0:	6105                	addi	sp,sp,32
ffffffffc02021b2:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc02021b4:	6418                	ld	a4,8(s0)
ffffffffc02021b6:	e798                	sd	a4,8(a5)
ffffffffc02021b8:	b7d1                	j	ffffffffc020217c <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc02021ba:	c8efe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc02021be:	4605                	li	a2,1
ffffffffc02021c0:	bf99                	j	ffffffffc0202116 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02021c2:	843e                	mv	s0,a5
ffffffffc02021c4:	87b6                	mv	a5,a3
ffffffffc02021c6:	b745                	j	ffffffffc0202166 <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02021c8:	00005697          	auipc	a3,0x5
ffffffffc02021cc:	5e868693          	addi	a3,a3,1512 # ffffffffc02077b0 <commands+0xe10>
ffffffffc02021d0:	00005617          	auipc	a2,0x5
ffffffffc02021d4:	be060613          	addi	a2,a2,-1056 # ffffffffc0206db0 <commands+0x410>
ffffffffc02021d8:	06400593          	li	a1,100
ffffffffc02021dc:	00005517          	auipc	a0,0x5
ffffffffc02021e0:	5f450513          	addi	a0,a0,1524 # ffffffffc02077d0 <commands+0xe30>
ffffffffc02021e4:	824fe0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02021e8 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc02021e8:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc02021ea:	00005517          	auipc	a0,0x5
ffffffffc02021ee:	5fe50513          	addi	a0,a0,1534 # ffffffffc02077e8 <commands+0xe48>
kmalloc_init(void) {
ffffffffc02021f2:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc02021f4:	ed9fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02021f8:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02021fa:	00005517          	auipc	a0,0x5
ffffffffc02021fe:	60650513          	addi	a0,a0,1542 # ffffffffc0207800 <commands+0xe60>
}
ffffffffc0202202:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0202204:	ec9fd06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0202208 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0202208:	4501                	li	a0,0
ffffffffc020220a:	8082                	ret

ffffffffc020220c <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc020220c:	1101                	addi	sp,sp,-32
ffffffffc020220e:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0202210:	6905                	lui	s2,0x1
{
ffffffffc0202212:	e822                	sd	s0,16(sp)
ffffffffc0202214:	ec06                	sd	ra,24(sp)
ffffffffc0202216:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0202218:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bc1>
{
ffffffffc020221c:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020221e:	04a7f963          	bgeu	a5,a0,ffffffffc0202270 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0202222:	4561                	li	a0,24
ffffffffc0202224:	ecfff0ef          	jal	ra,ffffffffc02020f2 <slob_alloc.constprop.0>
ffffffffc0202228:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc020222a:	c929                	beqz	a0,ffffffffc020227c <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc020222c:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0202230:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0202232:	00f95763          	bge	s2,a5,ffffffffc0202240 <kmalloc+0x34>
ffffffffc0202236:	6705                	lui	a4,0x1
ffffffffc0202238:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc020223a:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc020223c:	fef74ee3          	blt	a4,a5,ffffffffc0202238 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0202240:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0202242:	e4dff0ef          	jal	ra,ffffffffc020208e <__slob_get_free_pages.constprop.0>
ffffffffc0202246:	e488                	sd	a0,8(s1)
ffffffffc0202248:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc020224a:	c525                	beqz	a0,ffffffffc02022b2 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020224c:	100027f3          	csrr	a5,sstatus
ffffffffc0202250:	8b89                	andi	a5,a5,2
ffffffffc0202252:	ef8d                	bnez	a5,ffffffffc020228c <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0202254:	000b0797          	auipc	a5,0xb0
ffffffffc0202258:	59c78793          	addi	a5,a5,1436 # ffffffffc02b27f0 <bigblocks>
ffffffffc020225c:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc020225e:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0202260:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0202262:	60e2                	ld	ra,24(sp)
ffffffffc0202264:	8522                	mv	a0,s0
ffffffffc0202266:	6442                	ld	s0,16(sp)
ffffffffc0202268:	64a2                	ld	s1,8(sp)
ffffffffc020226a:	6902                	ld	s2,0(sp)
ffffffffc020226c:	6105                	addi	sp,sp,32
ffffffffc020226e:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0202270:	0541                	addi	a0,a0,16
ffffffffc0202272:	e81ff0ef          	jal	ra,ffffffffc02020f2 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0202276:	01050413          	addi	s0,a0,16
ffffffffc020227a:	f565                	bnez	a0,ffffffffc0202262 <kmalloc+0x56>
ffffffffc020227c:	4401                	li	s0,0
}
ffffffffc020227e:	60e2                	ld	ra,24(sp)
ffffffffc0202280:	8522                	mv	a0,s0
ffffffffc0202282:	6442                	ld	s0,16(sp)
ffffffffc0202284:	64a2                	ld	s1,8(sp)
ffffffffc0202286:	6902                	ld	s2,0(sp)
ffffffffc0202288:	6105                	addi	sp,sp,32
ffffffffc020228a:	8082                	ret
        intr_disable();
ffffffffc020228c:	bbcfe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
		bb->next = bigblocks;
ffffffffc0202290:	000b0797          	auipc	a5,0xb0
ffffffffc0202294:	56078793          	addi	a5,a5,1376 # ffffffffc02b27f0 <bigblocks>
ffffffffc0202298:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc020229a:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc020229c:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc020229e:	ba4fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
		return bb->pages;
ffffffffc02022a2:	6480                	ld	s0,8(s1)
}
ffffffffc02022a4:	60e2                	ld	ra,24(sp)
ffffffffc02022a6:	64a2                	ld	s1,8(sp)
ffffffffc02022a8:	8522                	mv	a0,s0
ffffffffc02022aa:	6442                	ld	s0,16(sp)
ffffffffc02022ac:	6902                	ld	s2,0(sp)
ffffffffc02022ae:	6105                	addi	sp,sp,32
ffffffffc02022b0:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc02022b2:	45e1                	li	a1,24
ffffffffc02022b4:	8526                	mv	a0,s1
ffffffffc02022b6:	d25ff0ef          	jal	ra,ffffffffc0201fda <slob_free>
  return __kmalloc(size, 0);
ffffffffc02022ba:	b765                	j	ffffffffc0202262 <kmalloc+0x56>

ffffffffc02022bc <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc02022bc:	c179                	beqz	a0,ffffffffc0202382 <kfree+0xc6>
{
ffffffffc02022be:	1101                	addi	sp,sp,-32
ffffffffc02022c0:	e822                	sd	s0,16(sp)
ffffffffc02022c2:	ec06                	sd	ra,24(sp)
ffffffffc02022c4:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc02022c6:	03451793          	slli	a5,a0,0x34
ffffffffc02022ca:	842a                	mv	s0,a0
ffffffffc02022cc:	e7c1                	bnez	a5,ffffffffc0202354 <kfree+0x98>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02022ce:	100027f3          	csrr	a5,sstatus
ffffffffc02022d2:	8b89                	andi	a5,a5,2
ffffffffc02022d4:	ebc9                	bnez	a5,ffffffffc0202366 <kfree+0xaa>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02022d6:	000b0797          	auipc	a5,0xb0
ffffffffc02022da:	51a7b783          	ld	a5,1306(a5) # ffffffffc02b27f0 <bigblocks>
    return 0;
ffffffffc02022de:	4601                	li	a2,0
ffffffffc02022e0:	cbb5                	beqz	a5,ffffffffc0202354 <kfree+0x98>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc02022e2:	000b0697          	auipc	a3,0xb0
ffffffffc02022e6:	50e68693          	addi	a3,a3,1294 # ffffffffc02b27f0 <bigblocks>
ffffffffc02022ea:	a021                	j	ffffffffc02022f2 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02022ec:	01048693          	addi	a3,s1,16
ffffffffc02022f0:	c3ad                	beqz	a5,ffffffffc0202352 <kfree+0x96>
			if (bb->pages == block) {
ffffffffc02022f2:	6798                	ld	a4,8(a5)
ffffffffc02022f4:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc02022f6:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc02022f8:	fe871ae3          	bne	a4,s0,ffffffffc02022ec <kfree+0x30>
				*last = bb->next;
ffffffffc02022fc:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc02022fe:	ee3d                	bnez	a2,ffffffffc020237c <kfree+0xc0>
    return pa2page(PADDR(kva));
ffffffffc0202300:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0202304:	4098                	lw	a4,0(s1)
ffffffffc0202306:	08f46b63          	bltu	s0,a5,ffffffffc020239c <kfree+0xe0>
ffffffffc020230a:	000b0697          	auipc	a3,0xb0
ffffffffc020230e:	52e6b683          	ld	a3,1326(a3) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0202312:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0202314:	8031                	srli	s0,s0,0xc
ffffffffc0202316:	000b0797          	auipc	a5,0xb0
ffffffffc020231a:	50a7b783          	ld	a5,1290(a5) # ffffffffc02b2820 <npage>
ffffffffc020231e:	06f47363          	bgeu	s0,a5,ffffffffc0202384 <kfree+0xc8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202322:	00007517          	auipc	a0,0x7
ffffffffc0202326:	b2653503          	ld	a0,-1242(a0) # ffffffffc0208e48 <nbase>
ffffffffc020232a:	8c09                	sub	s0,s0,a0
ffffffffc020232c:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc020232e:	000b0517          	auipc	a0,0xb0
ffffffffc0202332:	4fa53503          	ld	a0,1274(a0) # ffffffffc02b2828 <pages>
ffffffffc0202336:	4585                	li	a1,1
ffffffffc0202338:	9522                	add	a0,a0,s0
ffffffffc020233a:	00e595bb          	sllw	a1,a1,a4
ffffffffc020233e:	4f8010ef          	jal	ra,ffffffffc0203836 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0202342:	6442                	ld	s0,16(sp)
ffffffffc0202344:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202346:	8526                	mv	a0,s1
}
ffffffffc0202348:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc020234a:	45e1                	li	a1,24
}
ffffffffc020234c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020234e:	c8dff06f          	j	ffffffffc0201fda <slob_free>
ffffffffc0202352:	e215                	bnez	a2,ffffffffc0202376 <kfree+0xba>
ffffffffc0202354:	ff040513          	addi	a0,s0,-16
}
ffffffffc0202358:	6442                	ld	s0,16(sp)
ffffffffc020235a:	60e2                	ld	ra,24(sp)
ffffffffc020235c:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc020235e:	4581                	li	a1,0
}
ffffffffc0202360:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202362:	c79ff06f          	j	ffffffffc0201fda <slob_free>
        intr_disable();
ffffffffc0202366:	ae2fe0ef          	jal	ra,ffffffffc0200648 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020236a:	000b0797          	auipc	a5,0xb0
ffffffffc020236e:	4867b783          	ld	a5,1158(a5) # ffffffffc02b27f0 <bigblocks>
        return 1;
ffffffffc0202372:	4605                	li	a2,1
ffffffffc0202374:	f7bd                	bnez	a5,ffffffffc02022e2 <kfree+0x26>
        intr_enable();
ffffffffc0202376:	accfe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020237a:	bfe9                	j	ffffffffc0202354 <kfree+0x98>
ffffffffc020237c:	ac6fe0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0202380:	b741                	j	ffffffffc0202300 <kfree+0x44>
ffffffffc0202382:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0202384:	00005617          	auipc	a2,0x5
ffffffffc0202388:	ddc60613          	addi	a2,a2,-548 # ffffffffc0207160 <commands+0x7c0>
ffffffffc020238c:	06200593          	li	a1,98
ffffffffc0202390:	00005517          	auipc	a0,0x5
ffffffffc0202394:	dc050513          	addi	a0,a0,-576 # ffffffffc0207150 <commands+0x7b0>
ffffffffc0202398:	e71fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020239c:	86a2                	mv	a3,s0
ffffffffc020239e:	00005617          	auipc	a2,0x5
ffffffffc02023a2:	48260613          	addi	a2,a2,1154 # ffffffffc0207820 <commands+0xe80>
ffffffffc02023a6:	06e00593          	li	a1,110
ffffffffc02023aa:	00005517          	auipc	a0,0x5
ffffffffc02023ae:	da650513          	addi	a0,a0,-602 # ffffffffc0207150 <commands+0x7b0>
ffffffffc02023b2:	e57fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02023b6 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc02023b6:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02023b8:	00005617          	auipc	a2,0x5
ffffffffc02023bc:	da860613          	addi	a2,a2,-600 # ffffffffc0207160 <commands+0x7c0>
ffffffffc02023c0:	06200593          	li	a1,98
ffffffffc02023c4:	00005517          	auipc	a0,0x5
ffffffffc02023c8:	d8c50513          	addi	a0,a0,-628 # ffffffffc0207150 <commands+0x7b0>
pa2page(uintptr_t pa) {
ffffffffc02023cc:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02023ce:	e3bfd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02023d2 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02023d2:	7135                	addi	sp,sp,-160
ffffffffc02023d4:	ed06                	sd	ra,152(sp)
ffffffffc02023d6:	e922                	sd	s0,144(sp)
ffffffffc02023d8:	e526                	sd	s1,136(sp)
ffffffffc02023da:	e14a                	sd	s2,128(sp)
ffffffffc02023dc:	fcce                	sd	s3,120(sp)
ffffffffc02023de:	f8d2                	sd	s4,112(sp)
ffffffffc02023e0:	f4d6                	sd	s5,104(sp)
ffffffffc02023e2:	f0da                	sd	s6,96(sp)
ffffffffc02023e4:	ecde                	sd	s7,88(sp)
ffffffffc02023e6:	e8e2                	sd	s8,80(sp)
ffffffffc02023e8:	e4e6                	sd	s9,72(sp)
ffffffffc02023ea:	e0ea                	sd	s10,64(sp)
ffffffffc02023ec:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02023ee:	0ad020ef          	jal	ra,ffffffffc0204c9a <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02023f2:	000b0697          	auipc	a3,0xb0
ffffffffc02023f6:	4066b683          	ld	a3,1030(a3) # ffffffffc02b27f8 <max_swap_offset>
ffffffffc02023fa:	010007b7          	lui	a5,0x1000
ffffffffc02023fe:	ff968713          	addi	a4,a3,-7
ffffffffc0202402:	17e1                	addi	a5,a5,-8
ffffffffc0202404:	42e7e663          	bltu	a5,a4,ffffffffc0202830 <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0202408:	000a5797          	auipc	a5,0xa5
ffffffffc020240c:	e9878793          	addi	a5,a5,-360 # ffffffffc02a72a0 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202410:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202412:	000b0b97          	auipc	s7,0xb0
ffffffffc0202416:	3eeb8b93          	addi	s7,s7,1006 # ffffffffc02b2800 <sm>
ffffffffc020241a:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc020241e:	9702                	jalr	a4
ffffffffc0202420:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc0202422:	c10d                	beqz	a0,ffffffffc0202444 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202424:	60ea                	ld	ra,152(sp)
ffffffffc0202426:	644a                	ld	s0,144(sp)
ffffffffc0202428:	64aa                	ld	s1,136(sp)
ffffffffc020242a:	79e6                	ld	s3,120(sp)
ffffffffc020242c:	7a46                	ld	s4,112(sp)
ffffffffc020242e:	7aa6                	ld	s5,104(sp)
ffffffffc0202430:	7b06                	ld	s6,96(sp)
ffffffffc0202432:	6be6                	ld	s7,88(sp)
ffffffffc0202434:	6c46                	ld	s8,80(sp)
ffffffffc0202436:	6ca6                	ld	s9,72(sp)
ffffffffc0202438:	6d06                	ld	s10,64(sp)
ffffffffc020243a:	7de2                	ld	s11,56(sp)
ffffffffc020243c:	854a                	mv	a0,s2
ffffffffc020243e:	690a                	ld	s2,128(sp)
ffffffffc0202440:	610d                	addi	sp,sp,160
ffffffffc0202442:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202444:	000bb783          	ld	a5,0(s7)
ffffffffc0202448:	00005517          	auipc	a0,0x5
ffffffffc020244c:	43050513          	addi	a0,a0,1072 # ffffffffc0207878 <commands+0xed8>
    return listelm->next;
ffffffffc0202450:	000ac417          	auipc	s0,0xac
ffffffffc0202454:	35040413          	addi	s0,s0,848 # ffffffffc02ae7a0 <free_area>
ffffffffc0202458:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc020245a:	4785                	li	a5,1
ffffffffc020245c:	000b0717          	auipc	a4,0xb0
ffffffffc0202460:	3af72623          	sw	a5,940(a4) # ffffffffc02b2808 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202464:	c69fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0202468:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc020246a:	4d01                	li	s10,0
ffffffffc020246c:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020246e:	34878163          	beq	a5,s0,ffffffffc02027b0 <swap_init+0x3de>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202472:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202476:	8b09                	andi	a4,a4,2
ffffffffc0202478:	32070e63          	beqz	a4,ffffffffc02027b4 <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc020247c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202480:	679c                	ld	a5,8(a5)
ffffffffc0202482:	2d85                	addiw	s11,s11,1
ffffffffc0202484:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202488:	fe8795e3          	bne	a5,s0,ffffffffc0202472 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc020248c:	84ea                	mv	s1,s10
ffffffffc020248e:	3e8010ef          	jal	ra,ffffffffc0203876 <nr_free_pages>
ffffffffc0202492:	42951763          	bne	a0,s1,ffffffffc02028c0 <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202496:	866a                	mv	a2,s10
ffffffffc0202498:	85ee                	mv	a1,s11
ffffffffc020249a:	00005517          	auipc	a0,0x5
ffffffffc020249e:	42650513          	addi	a0,a0,1062 # ffffffffc02078c0 <commands+0xf20>
ffffffffc02024a2:	c2bfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02024a6:	ccdfe0ef          	jal	ra,ffffffffc0201172 <mm_create>
ffffffffc02024aa:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc02024ac:	46050a63          	beqz	a0,ffffffffc0202920 <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02024b0:	000b0797          	auipc	a5,0xb0
ffffffffc02024b4:	33078793          	addi	a5,a5,816 # ffffffffc02b27e0 <check_mm_struct>
ffffffffc02024b8:	6398                	ld	a4,0(a5)
ffffffffc02024ba:	3e071363          	bnez	a4,ffffffffc02028a0 <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02024be:	000b0717          	auipc	a4,0xb0
ffffffffc02024c2:	35a70713          	addi	a4,a4,858 # ffffffffc02b2818 <boot_pgdir>
ffffffffc02024c6:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc02024ca:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc02024cc:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02024d0:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02024d4:	42079663          	bnez	a5,ffffffffc0202900 <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02024d8:	6599                	lui	a1,0x6
ffffffffc02024da:	460d                	li	a2,3
ffffffffc02024dc:	6505                	lui	a0,0x1
ffffffffc02024de:	cddfe0ef          	jal	ra,ffffffffc02011ba <vma_create>
ffffffffc02024e2:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02024e4:	52050a63          	beqz	a0,ffffffffc0202a18 <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc02024e8:	8556                	mv	a0,s5
ffffffffc02024ea:	d3ffe0ef          	jal	ra,ffffffffc0201228 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02024ee:	00005517          	auipc	a0,0x5
ffffffffc02024f2:	41250513          	addi	a0,a0,1042 # ffffffffc0207900 <commands+0xf60>
ffffffffc02024f6:	bd7fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02024fa:	018ab503          	ld	a0,24(s5)
ffffffffc02024fe:	4605                	li	a2,1
ffffffffc0202500:	6585                	lui	a1,0x1
ffffffffc0202502:	3ae010ef          	jal	ra,ffffffffc02038b0 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202506:	4c050963          	beqz	a0,ffffffffc02029d8 <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc020250a:	00005517          	auipc	a0,0x5
ffffffffc020250e:	44650513          	addi	a0,a0,1094 # ffffffffc0207950 <commands+0xfb0>
ffffffffc0202512:	000ac497          	auipc	s1,0xac
ffffffffc0202516:	21e48493          	addi	s1,s1,542 # ffffffffc02ae730 <check_rp>
ffffffffc020251a:	bb3fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020251e:	000ac997          	auipc	s3,0xac
ffffffffc0202522:	23298993          	addi	s3,s3,562 # ffffffffc02ae750 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202526:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0202528:	4505                	li	a0,1
ffffffffc020252a:	27a010ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc020252e:	00aa3023          	sd	a0,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
          assert(check_rp[i] != NULL );
ffffffffc0202532:	2c050f63          	beqz	a0,ffffffffc0202810 <swap_init+0x43e>
ffffffffc0202536:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202538:	8b89                	andi	a5,a5,2
ffffffffc020253a:	34079363          	bnez	a5,ffffffffc0202880 <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020253e:	0a21                	addi	s4,s4,8
ffffffffc0202540:	ff3a14e3          	bne	s4,s3,ffffffffc0202528 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202544:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202546:	000aca17          	auipc	s4,0xac
ffffffffc020254a:	1eaa0a13          	addi	s4,s4,490 # ffffffffc02ae730 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc020254e:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc0202550:	ec3e                	sd	a5,24(sp)
ffffffffc0202552:	641c                	ld	a5,8(s0)
ffffffffc0202554:	e400                	sd	s0,8(s0)
ffffffffc0202556:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202558:	481c                	lw	a5,16(s0)
ffffffffc020255a:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc020255c:	000ac797          	auipc	a5,0xac
ffffffffc0202560:	2407aa23          	sw	zero,596(a5) # ffffffffc02ae7b0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202564:	000a3503          	ld	a0,0(s4)
ffffffffc0202568:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020256a:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc020256c:	2ca010ef          	jal	ra,ffffffffc0203836 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202570:	ff3a1ae3          	bne	s4,s3,ffffffffc0202564 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202574:	01042a03          	lw	s4,16(s0)
ffffffffc0202578:	4791                	li	a5,4
ffffffffc020257a:	42fa1f63          	bne	s4,a5,ffffffffc02029b8 <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020257e:	00005517          	auipc	a0,0x5
ffffffffc0202582:	45a50513          	addi	a0,a0,1114 # ffffffffc02079d8 <commands+0x1038>
ffffffffc0202586:	b47fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020258a:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc020258c:	000b0797          	auipc	a5,0xb0
ffffffffc0202590:	2407ae23          	sw	zero,604(a5) # ffffffffc02b27e8 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202594:	4629                	li	a2,10
ffffffffc0202596:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
     assert(pgfault_num==1);
ffffffffc020259a:	000b0697          	auipc	a3,0xb0
ffffffffc020259e:	24e6a683          	lw	a3,590(a3) # ffffffffc02b27e8 <pgfault_num>
ffffffffc02025a2:	4585                	li	a1,1
ffffffffc02025a4:	000b0797          	auipc	a5,0xb0
ffffffffc02025a8:	24478793          	addi	a5,a5,580 # ffffffffc02b27e8 <pgfault_num>
ffffffffc02025ac:	54b69663          	bne	a3,a1,ffffffffc0202af8 <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02025b0:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc02025b4:	4398                	lw	a4,0(a5)
ffffffffc02025b6:	2701                	sext.w	a4,a4
ffffffffc02025b8:	3ed71063          	bne	a4,a3,ffffffffc0202998 <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02025bc:	6689                	lui	a3,0x2
ffffffffc02025be:	462d                	li	a2,11
ffffffffc02025c0:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7bb0>
     assert(pgfault_num==2);
ffffffffc02025c4:	4398                	lw	a4,0(a5)
ffffffffc02025c6:	4589                	li	a1,2
ffffffffc02025c8:	2701                	sext.w	a4,a4
ffffffffc02025ca:	4ab71763          	bne	a4,a1,ffffffffc0202a78 <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02025ce:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02025d2:	4394                	lw	a3,0(a5)
ffffffffc02025d4:	2681                	sext.w	a3,a3
ffffffffc02025d6:	4ce69163          	bne	a3,a4,ffffffffc0202a98 <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02025da:	668d                	lui	a3,0x3
ffffffffc02025dc:	4631                	li	a2,12
ffffffffc02025de:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6bb0>
     assert(pgfault_num==3);
ffffffffc02025e2:	4398                	lw	a4,0(a5)
ffffffffc02025e4:	458d                	li	a1,3
ffffffffc02025e6:	2701                	sext.w	a4,a4
ffffffffc02025e8:	4cb71863          	bne	a4,a1,ffffffffc0202ab8 <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02025ec:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02025f0:	4394                	lw	a3,0(a5)
ffffffffc02025f2:	2681                	sext.w	a3,a3
ffffffffc02025f4:	4ee69263          	bne	a3,a4,ffffffffc0202ad8 <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02025f8:	6691                	lui	a3,0x4
ffffffffc02025fa:	4635                	li	a2,13
ffffffffc02025fc:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5bb0>
     assert(pgfault_num==4);
ffffffffc0202600:	4398                	lw	a4,0(a5)
ffffffffc0202602:	2701                	sext.w	a4,a4
ffffffffc0202604:	43471a63          	bne	a4,s4,ffffffffc0202a38 <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202608:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc020260c:	439c                	lw	a5,0(a5)
ffffffffc020260e:	2781                	sext.w	a5,a5
ffffffffc0202610:	44e79463          	bne	a5,a4,ffffffffc0202a58 <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202614:	481c                	lw	a5,16(s0)
ffffffffc0202616:	2c079563          	bnez	a5,ffffffffc02028e0 <swap_init+0x50e>
ffffffffc020261a:	000ac797          	auipc	a5,0xac
ffffffffc020261e:	13678793          	addi	a5,a5,310 # ffffffffc02ae750 <swap_in_seq_no>
ffffffffc0202622:	000ac717          	auipc	a4,0xac
ffffffffc0202626:	15670713          	addi	a4,a4,342 # ffffffffc02ae778 <swap_out_seq_no>
ffffffffc020262a:	000ac617          	auipc	a2,0xac
ffffffffc020262e:	14e60613          	addi	a2,a2,334 # ffffffffc02ae778 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202632:	56fd                	li	a3,-1
ffffffffc0202634:	c394                	sw	a3,0(a5)
ffffffffc0202636:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202638:	0791                	addi	a5,a5,4
ffffffffc020263a:	0711                	addi	a4,a4,4
ffffffffc020263c:	fec79ce3          	bne	a5,a2,ffffffffc0202634 <swap_init+0x262>
ffffffffc0202640:	000ac717          	auipc	a4,0xac
ffffffffc0202644:	0d070713          	addi	a4,a4,208 # ffffffffc02ae710 <check_ptep>
ffffffffc0202648:	000ac697          	auipc	a3,0xac
ffffffffc020264c:	0e868693          	addi	a3,a3,232 # ffffffffc02ae730 <check_rp>
ffffffffc0202650:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202652:	000b0c17          	auipc	s8,0xb0
ffffffffc0202656:	1cec0c13          	addi	s8,s8,462 # ffffffffc02b2820 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020265a:	000b0c97          	auipc	s9,0xb0
ffffffffc020265e:	1cec8c93          	addi	s9,s9,462 # ffffffffc02b2828 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202662:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202666:	4601                	li	a2,0
ffffffffc0202668:	855a                	mv	a0,s6
ffffffffc020266a:	e836                	sd	a3,16(sp)
ffffffffc020266c:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc020266e:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202670:	240010ef          	jal	ra,ffffffffc02038b0 <get_pte>
ffffffffc0202674:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202676:	65a2                	ld	a1,8(sp)
ffffffffc0202678:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020267a:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc020267c:	1c050663          	beqz	a0,ffffffffc0202848 <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202680:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202682:	0017f613          	andi	a2,a5,1
ffffffffc0202686:	1e060163          	beqz	a2,ffffffffc0202868 <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc020268a:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc020268e:	078a                	slli	a5,a5,0x2
ffffffffc0202690:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202692:	14c7f363          	bgeu	a5,a2,ffffffffc02027d8 <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc0202696:	00006617          	auipc	a2,0x6
ffffffffc020269a:	7b260613          	addi	a2,a2,1970 # ffffffffc0208e48 <nbase>
ffffffffc020269e:	00063a03          	ld	s4,0(a2)
ffffffffc02026a2:	000cb603          	ld	a2,0(s9)
ffffffffc02026a6:	6288                	ld	a0,0(a3)
ffffffffc02026a8:	414787b3          	sub	a5,a5,s4
ffffffffc02026ac:	079a                	slli	a5,a5,0x6
ffffffffc02026ae:	97b2                	add	a5,a5,a2
ffffffffc02026b0:	14f51063          	bne	a0,a5,ffffffffc02027f0 <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02026b4:	6785                	lui	a5,0x1
ffffffffc02026b6:	95be                	add	a1,a1,a5
ffffffffc02026b8:	6795                	lui	a5,0x5
ffffffffc02026ba:	0721                	addi	a4,a4,8
ffffffffc02026bc:	06a1                	addi	a3,a3,8
ffffffffc02026be:	faf592e3          	bne	a1,a5,ffffffffc0202662 <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02026c2:	00005517          	auipc	a0,0x5
ffffffffc02026c6:	3be50513          	addi	a0,a0,958 # ffffffffc0207a80 <commands+0x10e0>
ffffffffc02026ca:	a03fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = sm->check_swap();
ffffffffc02026ce:	000bb783          	ld	a5,0(s7)
ffffffffc02026d2:	7f9c                	ld	a5,56(a5)
ffffffffc02026d4:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02026d6:	32051163          	bnez	a0,ffffffffc02029f8 <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc02026da:	77a2                	ld	a5,40(sp)
ffffffffc02026dc:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc02026de:	67e2                	ld	a5,24(sp)
ffffffffc02026e0:	e01c                	sd	a5,0(s0)
ffffffffc02026e2:	7782                	ld	a5,32(sp)
ffffffffc02026e4:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02026e6:	6088                	ld	a0,0(s1)
ffffffffc02026e8:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02026ea:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc02026ec:	14a010ef          	jal	ra,ffffffffc0203836 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02026f0:	ff349be3          	bne	s1,s3,ffffffffc02026e6 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02026f4:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc02026f8:	8556                	mv	a0,s5
ffffffffc02026fa:	bfffe0ef          	jal	ra,ffffffffc02012f8 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02026fe:	000b0797          	auipc	a5,0xb0
ffffffffc0202702:	11a78793          	addi	a5,a5,282 # ffffffffc02b2818 <boot_pgdir>
ffffffffc0202706:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202708:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc020270c:	000b0697          	auipc	a3,0xb0
ffffffffc0202710:	0c06ba23          	sd	zero,212(a3) # ffffffffc02b27e0 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202714:	639c                	ld	a5,0(a5)
ffffffffc0202716:	078a                	slli	a5,a5,0x2
ffffffffc0202718:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020271a:	0ae7fd63          	bgeu	a5,a4,ffffffffc02027d4 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc020271e:	414786b3          	sub	a3,a5,s4
ffffffffc0202722:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202724:	8699                	srai	a3,a3,0x6
ffffffffc0202726:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0202728:	00c69793          	slli	a5,a3,0xc
ffffffffc020272c:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc020272e:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc0202732:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202734:	22e7f663          	bgeu	a5,a4,ffffffffc0202960 <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc0202738:	000b0797          	auipc	a5,0xb0
ffffffffc020273c:	1007b783          	ld	a5,256(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0202740:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202742:	629c                	ld	a5,0(a3)
ffffffffc0202744:	078a                	slli	a5,a5,0x2
ffffffffc0202746:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202748:	08e7f663          	bgeu	a5,a4,ffffffffc02027d4 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc020274c:	414787b3          	sub	a5,a5,s4
ffffffffc0202750:	079a                	slli	a5,a5,0x6
ffffffffc0202752:	953e                	add	a0,a0,a5
ffffffffc0202754:	4585                	li	a1,1
ffffffffc0202756:	0e0010ef          	jal	ra,ffffffffc0203836 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020275a:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc020275e:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202762:	078a                	slli	a5,a5,0x2
ffffffffc0202764:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202766:	06e7f763          	bgeu	a5,a4,ffffffffc02027d4 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc020276a:	000cb503          	ld	a0,0(s9)
ffffffffc020276e:	414787b3          	sub	a5,a5,s4
ffffffffc0202772:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202774:	4585                	li	a1,1
ffffffffc0202776:	953e                	add	a0,a0,a5
ffffffffc0202778:	0be010ef          	jal	ra,ffffffffc0203836 <free_pages>
     pgdir[0] = 0;
ffffffffc020277c:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202780:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202784:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202786:	00878a63          	beq	a5,s0,ffffffffc020279a <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc020278a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020278e:	679c                	ld	a5,8(a5)
ffffffffc0202790:	3dfd                	addiw	s11,s11,-1
ffffffffc0202792:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202796:	fe879ae3          	bne	a5,s0,ffffffffc020278a <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc020279a:	1c0d9f63          	bnez	s11,ffffffffc0202978 <swap_init+0x5a6>
     assert(total==0);
ffffffffc020279e:	1a0d1163          	bnez	s10,ffffffffc0202940 <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc02027a2:	00005517          	auipc	a0,0x5
ffffffffc02027a6:	32e50513          	addi	a0,a0,814 # ffffffffc0207ad0 <commands+0x1130>
ffffffffc02027aa:	923fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02027ae:	b99d                	j	ffffffffc0202424 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc02027b0:	4481                	li	s1,0
ffffffffc02027b2:	b9f1                	j	ffffffffc020248e <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc02027b4:	00005697          	auipc	a3,0x5
ffffffffc02027b8:	0dc68693          	addi	a3,a3,220 # ffffffffc0207890 <commands+0xef0>
ffffffffc02027bc:	00004617          	auipc	a2,0x4
ffffffffc02027c0:	5f460613          	addi	a2,a2,1524 # ffffffffc0206db0 <commands+0x410>
ffffffffc02027c4:	0bc00593          	li	a1,188
ffffffffc02027c8:	00005517          	auipc	a0,0x5
ffffffffc02027cc:	0a050513          	addi	a0,a0,160 # ffffffffc0207868 <commands+0xec8>
ffffffffc02027d0:	a39fd0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02027d4:	be3ff0ef          	jal	ra,ffffffffc02023b6 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc02027d8:	00005617          	auipc	a2,0x5
ffffffffc02027dc:	98860613          	addi	a2,a2,-1656 # ffffffffc0207160 <commands+0x7c0>
ffffffffc02027e0:	06200593          	li	a1,98
ffffffffc02027e4:	00005517          	auipc	a0,0x5
ffffffffc02027e8:	96c50513          	addi	a0,a0,-1684 # ffffffffc0207150 <commands+0x7b0>
ffffffffc02027ec:	a1dfd0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02027f0:	00005697          	auipc	a3,0x5
ffffffffc02027f4:	26868693          	addi	a3,a3,616 # ffffffffc0207a58 <commands+0x10b8>
ffffffffc02027f8:	00004617          	auipc	a2,0x4
ffffffffc02027fc:	5b860613          	addi	a2,a2,1464 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202800:	0fc00593          	li	a1,252
ffffffffc0202804:	00005517          	auipc	a0,0x5
ffffffffc0202808:	06450513          	addi	a0,a0,100 # ffffffffc0207868 <commands+0xec8>
ffffffffc020280c:	9fdfd0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202810:	00005697          	auipc	a3,0x5
ffffffffc0202814:	16868693          	addi	a3,a3,360 # ffffffffc0207978 <commands+0xfd8>
ffffffffc0202818:	00004617          	auipc	a2,0x4
ffffffffc020281c:	59860613          	addi	a2,a2,1432 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202820:	0dc00593          	li	a1,220
ffffffffc0202824:	00005517          	auipc	a0,0x5
ffffffffc0202828:	04450513          	addi	a0,a0,68 # ffffffffc0207868 <commands+0xec8>
ffffffffc020282c:	9ddfd0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202830:	00005617          	auipc	a2,0x5
ffffffffc0202834:	01860613          	addi	a2,a2,24 # ffffffffc0207848 <commands+0xea8>
ffffffffc0202838:	02800593          	li	a1,40
ffffffffc020283c:	00005517          	auipc	a0,0x5
ffffffffc0202840:	02c50513          	addi	a0,a0,44 # ffffffffc0207868 <commands+0xec8>
ffffffffc0202844:	9c5fd0ef          	jal	ra,ffffffffc0200208 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202848:	00005697          	auipc	a3,0x5
ffffffffc020284c:	1f868693          	addi	a3,a3,504 # ffffffffc0207a40 <commands+0x10a0>
ffffffffc0202850:	00004617          	auipc	a2,0x4
ffffffffc0202854:	56060613          	addi	a2,a2,1376 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202858:	0fb00593          	li	a1,251
ffffffffc020285c:	00005517          	auipc	a0,0x5
ffffffffc0202860:	00c50513          	addi	a0,a0,12 # ffffffffc0207868 <commands+0xec8>
ffffffffc0202864:	9a5fd0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202868:	00005617          	auipc	a2,0x5
ffffffffc020286c:	8c060613          	addi	a2,a2,-1856 # ffffffffc0207128 <commands+0x788>
ffffffffc0202870:	07400593          	li	a1,116
ffffffffc0202874:	00005517          	auipc	a0,0x5
ffffffffc0202878:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0207150 <commands+0x7b0>
ffffffffc020287c:	98dfd0ef          	jal	ra,ffffffffc0200208 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202880:	00005697          	auipc	a3,0x5
ffffffffc0202884:	11068693          	addi	a3,a3,272 # ffffffffc0207990 <commands+0xff0>
ffffffffc0202888:	00004617          	auipc	a2,0x4
ffffffffc020288c:	52860613          	addi	a2,a2,1320 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202890:	0dd00593          	li	a1,221
ffffffffc0202894:	00005517          	auipc	a0,0x5
ffffffffc0202898:	fd450513          	addi	a0,a0,-44 # ffffffffc0207868 <commands+0xec8>
ffffffffc020289c:	96dfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc02028a0:	00005697          	auipc	a3,0x5
ffffffffc02028a4:	04868693          	addi	a3,a3,72 # ffffffffc02078e8 <commands+0xf48>
ffffffffc02028a8:	00004617          	auipc	a2,0x4
ffffffffc02028ac:	50860613          	addi	a2,a2,1288 # ffffffffc0206db0 <commands+0x410>
ffffffffc02028b0:	0c700593          	li	a1,199
ffffffffc02028b4:	00005517          	auipc	a0,0x5
ffffffffc02028b8:	fb450513          	addi	a0,a0,-76 # ffffffffc0207868 <commands+0xec8>
ffffffffc02028bc:	94dfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total == nr_free_pages());
ffffffffc02028c0:	00005697          	auipc	a3,0x5
ffffffffc02028c4:	fe068693          	addi	a3,a3,-32 # ffffffffc02078a0 <commands+0xf00>
ffffffffc02028c8:	00004617          	auipc	a2,0x4
ffffffffc02028cc:	4e860613          	addi	a2,a2,1256 # ffffffffc0206db0 <commands+0x410>
ffffffffc02028d0:	0bf00593          	li	a1,191
ffffffffc02028d4:	00005517          	auipc	a0,0x5
ffffffffc02028d8:	f9450513          	addi	a0,a0,-108 # ffffffffc0207868 <commands+0xec8>
ffffffffc02028dc:	92dfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert( nr_free == 0);         
ffffffffc02028e0:	00005697          	auipc	a3,0x5
ffffffffc02028e4:	15068693          	addi	a3,a3,336 # ffffffffc0207a30 <commands+0x1090>
ffffffffc02028e8:	00004617          	auipc	a2,0x4
ffffffffc02028ec:	4c860613          	addi	a2,a2,1224 # ffffffffc0206db0 <commands+0x410>
ffffffffc02028f0:	0f300593          	li	a1,243
ffffffffc02028f4:	00005517          	auipc	a0,0x5
ffffffffc02028f8:	f7450513          	addi	a0,a0,-140 # ffffffffc0207868 <commands+0xec8>
ffffffffc02028fc:	90dfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202900:	00005697          	auipc	a3,0x5
ffffffffc0202904:	b8068693          	addi	a3,a3,-1152 # ffffffffc0207480 <commands+0xae0>
ffffffffc0202908:	00004617          	auipc	a2,0x4
ffffffffc020290c:	4a860613          	addi	a2,a2,1192 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202910:	0cc00593          	li	a1,204
ffffffffc0202914:	00005517          	auipc	a0,0x5
ffffffffc0202918:	f5450513          	addi	a0,a0,-172 # ffffffffc0207868 <commands+0xec8>
ffffffffc020291c:	8edfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(mm != NULL);
ffffffffc0202920:	00005697          	auipc	a3,0x5
ffffffffc0202924:	99868693          	addi	a3,a3,-1640 # ffffffffc02072b8 <commands+0x918>
ffffffffc0202928:	00004617          	auipc	a2,0x4
ffffffffc020292c:	48860613          	addi	a2,a2,1160 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202930:	0c400593          	li	a1,196
ffffffffc0202934:	00005517          	auipc	a0,0x5
ffffffffc0202938:	f3450513          	addi	a0,a0,-204 # ffffffffc0207868 <commands+0xec8>
ffffffffc020293c:	8cdfd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(total==0);
ffffffffc0202940:	00005697          	auipc	a3,0x5
ffffffffc0202944:	18068693          	addi	a3,a3,384 # ffffffffc0207ac0 <commands+0x1120>
ffffffffc0202948:	00004617          	auipc	a2,0x4
ffffffffc020294c:	46860613          	addi	a2,a2,1128 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202950:	11e00593          	li	a1,286
ffffffffc0202954:	00005517          	auipc	a0,0x5
ffffffffc0202958:	f1450513          	addi	a0,a0,-236 # ffffffffc0207868 <commands+0xec8>
ffffffffc020295c:	8adfd0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202960:	00005617          	auipc	a2,0x5
ffffffffc0202964:	88860613          	addi	a2,a2,-1912 # ffffffffc02071e8 <commands+0x848>
ffffffffc0202968:	06900593          	li	a1,105
ffffffffc020296c:	00004517          	auipc	a0,0x4
ffffffffc0202970:	7e450513          	addi	a0,a0,2020 # ffffffffc0207150 <commands+0x7b0>
ffffffffc0202974:	895fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(count==0);
ffffffffc0202978:	00005697          	auipc	a3,0x5
ffffffffc020297c:	13868693          	addi	a3,a3,312 # ffffffffc0207ab0 <commands+0x1110>
ffffffffc0202980:	00004617          	auipc	a2,0x4
ffffffffc0202984:	43060613          	addi	a2,a2,1072 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202988:	11d00593          	li	a1,285
ffffffffc020298c:	00005517          	auipc	a0,0x5
ffffffffc0202990:	edc50513          	addi	a0,a0,-292 # ffffffffc0207868 <commands+0xec8>
ffffffffc0202994:	875fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc0202998:	00005697          	auipc	a3,0x5
ffffffffc020299c:	06868693          	addi	a3,a3,104 # ffffffffc0207a00 <commands+0x1060>
ffffffffc02029a0:	00004617          	auipc	a2,0x4
ffffffffc02029a4:	41060613          	addi	a2,a2,1040 # ffffffffc0206db0 <commands+0x410>
ffffffffc02029a8:	09500593          	li	a1,149
ffffffffc02029ac:	00005517          	auipc	a0,0x5
ffffffffc02029b0:	ebc50513          	addi	a0,a0,-324 # ffffffffc0207868 <commands+0xec8>
ffffffffc02029b4:	855fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02029b8:	00005697          	auipc	a3,0x5
ffffffffc02029bc:	ff868693          	addi	a3,a3,-8 # ffffffffc02079b0 <commands+0x1010>
ffffffffc02029c0:	00004617          	auipc	a2,0x4
ffffffffc02029c4:	3f060613          	addi	a2,a2,1008 # ffffffffc0206db0 <commands+0x410>
ffffffffc02029c8:	0ea00593          	li	a1,234
ffffffffc02029cc:	00005517          	auipc	a0,0x5
ffffffffc02029d0:	e9c50513          	addi	a0,a0,-356 # ffffffffc0207868 <commands+0xec8>
ffffffffc02029d4:	835fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02029d8:	00005697          	auipc	a3,0x5
ffffffffc02029dc:	f6068693          	addi	a3,a3,-160 # ffffffffc0207938 <commands+0xf98>
ffffffffc02029e0:	00004617          	auipc	a2,0x4
ffffffffc02029e4:	3d060613          	addi	a2,a2,976 # ffffffffc0206db0 <commands+0x410>
ffffffffc02029e8:	0d700593          	li	a1,215
ffffffffc02029ec:	00005517          	auipc	a0,0x5
ffffffffc02029f0:	e7c50513          	addi	a0,a0,-388 # ffffffffc0207868 <commands+0xec8>
ffffffffc02029f4:	815fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(ret==0);
ffffffffc02029f8:	00005697          	auipc	a3,0x5
ffffffffc02029fc:	0b068693          	addi	a3,a3,176 # ffffffffc0207aa8 <commands+0x1108>
ffffffffc0202a00:	00004617          	auipc	a2,0x4
ffffffffc0202a04:	3b060613          	addi	a2,a2,944 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202a08:	10200593          	li	a1,258
ffffffffc0202a0c:	00005517          	auipc	a0,0x5
ffffffffc0202a10:	e5c50513          	addi	a0,a0,-420 # ffffffffc0207868 <commands+0xec8>
ffffffffc0202a14:	ff4fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(vma != NULL);
ffffffffc0202a18:	00005697          	auipc	a3,0x5
ffffffffc0202a1c:	b0868693          	addi	a3,a3,-1272 # ffffffffc0207520 <commands+0xb80>
ffffffffc0202a20:	00004617          	auipc	a2,0x4
ffffffffc0202a24:	39060613          	addi	a2,a2,912 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202a28:	0cf00593          	li	a1,207
ffffffffc0202a2c:	00005517          	auipc	a0,0x5
ffffffffc0202a30:	e3c50513          	addi	a0,a0,-452 # ffffffffc0207868 <commands+0xec8>
ffffffffc0202a34:	fd4fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc0202a38:	00005697          	auipc	a3,0x5
ffffffffc0202a3c:	bc068693          	addi	a3,a3,-1088 # ffffffffc02075f8 <commands+0xc58>
ffffffffc0202a40:	00004617          	auipc	a2,0x4
ffffffffc0202a44:	37060613          	addi	a2,a2,880 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202a48:	09f00593          	li	a1,159
ffffffffc0202a4c:	00005517          	auipc	a0,0x5
ffffffffc0202a50:	e1c50513          	addi	a0,a0,-484 # ffffffffc0207868 <commands+0xec8>
ffffffffc0202a54:	fb4fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==4);
ffffffffc0202a58:	00005697          	auipc	a3,0x5
ffffffffc0202a5c:	ba068693          	addi	a3,a3,-1120 # ffffffffc02075f8 <commands+0xc58>
ffffffffc0202a60:	00004617          	auipc	a2,0x4
ffffffffc0202a64:	35060613          	addi	a2,a2,848 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202a68:	0a100593          	li	a1,161
ffffffffc0202a6c:	00005517          	auipc	a0,0x5
ffffffffc0202a70:	dfc50513          	addi	a0,a0,-516 # ffffffffc0207868 <commands+0xec8>
ffffffffc0202a74:	f94fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc0202a78:	00005697          	auipc	a3,0x5
ffffffffc0202a7c:	f9868693          	addi	a3,a3,-104 # ffffffffc0207a10 <commands+0x1070>
ffffffffc0202a80:	00004617          	auipc	a2,0x4
ffffffffc0202a84:	33060613          	addi	a2,a2,816 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202a88:	09700593          	li	a1,151
ffffffffc0202a8c:	00005517          	auipc	a0,0x5
ffffffffc0202a90:	ddc50513          	addi	a0,a0,-548 # ffffffffc0207868 <commands+0xec8>
ffffffffc0202a94:	f74fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==2);
ffffffffc0202a98:	00005697          	auipc	a3,0x5
ffffffffc0202a9c:	f7868693          	addi	a3,a3,-136 # ffffffffc0207a10 <commands+0x1070>
ffffffffc0202aa0:	00004617          	auipc	a2,0x4
ffffffffc0202aa4:	31060613          	addi	a2,a2,784 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202aa8:	09900593          	li	a1,153
ffffffffc0202aac:	00005517          	auipc	a0,0x5
ffffffffc0202ab0:	dbc50513          	addi	a0,a0,-580 # ffffffffc0207868 <commands+0xec8>
ffffffffc0202ab4:	f54fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc0202ab8:	00005697          	auipc	a3,0x5
ffffffffc0202abc:	f6868693          	addi	a3,a3,-152 # ffffffffc0207a20 <commands+0x1080>
ffffffffc0202ac0:	00004617          	auipc	a2,0x4
ffffffffc0202ac4:	2f060613          	addi	a2,a2,752 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202ac8:	09b00593          	li	a1,155
ffffffffc0202acc:	00005517          	auipc	a0,0x5
ffffffffc0202ad0:	d9c50513          	addi	a0,a0,-612 # ffffffffc0207868 <commands+0xec8>
ffffffffc0202ad4:	f34fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==3);
ffffffffc0202ad8:	00005697          	auipc	a3,0x5
ffffffffc0202adc:	f4868693          	addi	a3,a3,-184 # ffffffffc0207a20 <commands+0x1080>
ffffffffc0202ae0:	00004617          	auipc	a2,0x4
ffffffffc0202ae4:	2d060613          	addi	a2,a2,720 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202ae8:	09d00593          	li	a1,157
ffffffffc0202aec:	00005517          	auipc	a0,0x5
ffffffffc0202af0:	d7c50513          	addi	a0,a0,-644 # ffffffffc0207868 <commands+0xec8>
ffffffffc0202af4:	f14fd0ef          	jal	ra,ffffffffc0200208 <__panic>
     assert(pgfault_num==1);
ffffffffc0202af8:	00005697          	auipc	a3,0x5
ffffffffc0202afc:	f0868693          	addi	a3,a3,-248 # ffffffffc0207a00 <commands+0x1060>
ffffffffc0202b00:	00004617          	auipc	a2,0x4
ffffffffc0202b04:	2b060613          	addi	a2,a2,688 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202b08:	09300593          	li	a1,147
ffffffffc0202b0c:	00005517          	auipc	a0,0x5
ffffffffc0202b10:	d5c50513          	addi	a0,a0,-676 # ffffffffc0207868 <commands+0xec8>
ffffffffc0202b14:	ef4fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202b18 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202b18:	000b0797          	auipc	a5,0xb0
ffffffffc0202b1c:	ce87b783          	ld	a5,-792(a5) # ffffffffc02b2800 <sm>
ffffffffc0202b20:	6b9c                	ld	a5,16(a5)
ffffffffc0202b22:	8782                	jr	a5

ffffffffc0202b24 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202b24:	000b0797          	auipc	a5,0xb0
ffffffffc0202b28:	cdc7b783          	ld	a5,-804(a5) # ffffffffc02b2800 <sm>
ffffffffc0202b2c:	739c                	ld	a5,32(a5)
ffffffffc0202b2e:	8782                	jr	a5

ffffffffc0202b30 <swap_out>:
{
ffffffffc0202b30:	711d                	addi	sp,sp,-96
ffffffffc0202b32:	ec86                	sd	ra,88(sp)
ffffffffc0202b34:	e8a2                	sd	s0,80(sp)
ffffffffc0202b36:	e4a6                	sd	s1,72(sp)
ffffffffc0202b38:	e0ca                	sd	s2,64(sp)
ffffffffc0202b3a:	fc4e                	sd	s3,56(sp)
ffffffffc0202b3c:	f852                	sd	s4,48(sp)
ffffffffc0202b3e:	f456                	sd	s5,40(sp)
ffffffffc0202b40:	f05a                	sd	s6,32(sp)
ffffffffc0202b42:	ec5e                	sd	s7,24(sp)
ffffffffc0202b44:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202b46:	cde9                	beqz	a1,ffffffffc0202c20 <swap_out+0xf0>
ffffffffc0202b48:	8a2e                	mv	s4,a1
ffffffffc0202b4a:	892a                	mv	s2,a0
ffffffffc0202b4c:	8ab2                	mv	s5,a2
ffffffffc0202b4e:	4401                	li	s0,0
ffffffffc0202b50:	000b0997          	auipc	s3,0xb0
ffffffffc0202b54:	cb098993          	addi	s3,s3,-848 # ffffffffc02b2800 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202b58:	00005b17          	auipc	s6,0x5
ffffffffc0202b5c:	ff8b0b13          	addi	s6,s6,-8 # ffffffffc0207b50 <commands+0x11b0>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202b60:	00005b97          	auipc	s7,0x5
ffffffffc0202b64:	fd8b8b93          	addi	s7,s7,-40 # ffffffffc0207b38 <commands+0x1198>
ffffffffc0202b68:	a825                	j	ffffffffc0202ba0 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202b6a:	67a2                	ld	a5,8(sp)
ffffffffc0202b6c:	8626                	mv	a2,s1
ffffffffc0202b6e:	85a2                	mv	a1,s0
ffffffffc0202b70:	7f94                	ld	a3,56(a5)
ffffffffc0202b72:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202b74:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202b76:	82b1                	srli	a3,a3,0xc
ffffffffc0202b78:	0685                	addi	a3,a3,1
ffffffffc0202b7a:	d52fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202b7e:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202b80:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202b82:	7d1c                	ld	a5,56(a0)
ffffffffc0202b84:	83b1                	srli	a5,a5,0xc
ffffffffc0202b86:	0785                	addi	a5,a5,1
ffffffffc0202b88:	07a2                	slli	a5,a5,0x8
ffffffffc0202b8a:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202b8e:	4a9000ef          	jal	ra,ffffffffc0203836 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202b92:	01893503          	ld	a0,24(s2)
ffffffffc0202b96:	85a6                	mv	a1,s1
ffffffffc0202b98:	042020ef          	jal	ra,ffffffffc0204bda <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202b9c:	048a0d63          	beq	s4,s0,ffffffffc0202bf6 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202ba0:	0009b783          	ld	a5,0(s3)
ffffffffc0202ba4:	8656                	mv	a2,s5
ffffffffc0202ba6:	002c                	addi	a1,sp,8
ffffffffc0202ba8:	7b9c                	ld	a5,48(a5)
ffffffffc0202baa:	854a                	mv	a0,s2
ffffffffc0202bac:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202bae:	e12d                	bnez	a0,ffffffffc0202c10 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202bb0:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202bb2:	01893503          	ld	a0,24(s2)
ffffffffc0202bb6:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202bb8:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202bba:	85a6                	mv	a1,s1
ffffffffc0202bbc:	4f5000ef          	jal	ra,ffffffffc02038b0 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202bc0:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202bc2:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202bc4:	8b85                	andi	a5,a5,1
ffffffffc0202bc6:	cfb9                	beqz	a5,ffffffffc0202c24 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202bc8:	65a2                	ld	a1,8(sp)
ffffffffc0202bca:	7d9c                	ld	a5,56(a1)
ffffffffc0202bcc:	83b1                	srli	a5,a5,0xc
ffffffffc0202bce:	0785                	addi	a5,a5,1
ffffffffc0202bd0:	00879513          	slli	a0,a5,0x8
ffffffffc0202bd4:	18c020ef          	jal	ra,ffffffffc0204d60 <swapfs_write>
ffffffffc0202bd8:	d949                	beqz	a0,ffffffffc0202b6a <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202bda:	855e                	mv	a0,s7
ffffffffc0202bdc:	cf0fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202be0:	0009b783          	ld	a5,0(s3)
ffffffffc0202be4:	6622                	ld	a2,8(sp)
ffffffffc0202be6:	4681                	li	a3,0
ffffffffc0202be8:	739c                	ld	a5,32(a5)
ffffffffc0202bea:	85a6                	mv	a1,s1
ffffffffc0202bec:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202bee:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202bf0:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202bf2:	fa8a17e3          	bne	s4,s0,ffffffffc0202ba0 <swap_out+0x70>
}
ffffffffc0202bf6:	60e6                	ld	ra,88(sp)
ffffffffc0202bf8:	8522                	mv	a0,s0
ffffffffc0202bfa:	6446                	ld	s0,80(sp)
ffffffffc0202bfc:	64a6                	ld	s1,72(sp)
ffffffffc0202bfe:	6906                	ld	s2,64(sp)
ffffffffc0202c00:	79e2                	ld	s3,56(sp)
ffffffffc0202c02:	7a42                	ld	s4,48(sp)
ffffffffc0202c04:	7aa2                	ld	s5,40(sp)
ffffffffc0202c06:	7b02                	ld	s6,32(sp)
ffffffffc0202c08:	6be2                	ld	s7,24(sp)
ffffffffc0202c0a:	6c42                	ld	s8,16(sp)
ffffffffc0202c0c:	6125                	addi	sp,sp,96
ffffffffc0202c0e:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202c10:	85a2                	mv	a1,s0
ffffffffc0202c12:	00005517          	auipc	a0,0x5
ffffffffc0202c16:	ede50513          	addi	a0,a0,-290 # ffffffffc0207af0 <commands+0x1150>
ffffffffc0202c1a:	cb2fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
                  break;
ffffffffc0202c1e:	bfe1                	j	ffffffffc0202bf6 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202c20:	4401                	li	s0,0
ffffffffc0202c22:	bfd1                	j	ffffffffc0202bf6 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202c24:	00005697          	auipc	a3,0x5
ffffffffc0202c28:	efc68693          	addi	a3,a3,-260 # ffffffffc0207b20 <commands+0x1180>
ffffffffc0202c2c:	00004617          	auipc	a2,0x4
ffffffffc0202c30:	18460613          	addi	a2,a2,388 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202c34:	06800593          	li	a1,104
ffffffffc0202c38:	00005517          	auipc	a0,0x5
ffffffffc0202c3c:	c3050513          	addi	a0,a0,-976 # ffffffffc0207868 <commands+0xec8>
ffffffffc0202c40:	dc8fd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202c44 <swap_in>:
{
ffffffffc0202c44:	7179                	addi	sp,sp,-48
ffffffffc0202c46:	e84a                	sd	s2,16(sp)
ffffffffc0202c48:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202c4a:	4505                	li	a0,1
{
ffffffffc0202c4c:	ec26                	sd	s1,24(sp)
ffffffffc0202c4e:	e44e                	sd	s3,8(sp)
ffffffffc0202c50:	f406                	sd	ra,40(sp)
ffffffffc0202c52:	f022                	sd	s0,32(sp)
ffffffffc0202c54:	84ae                	mv	s1,a1
ffffffffc0202c56:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202c58:	34d000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
     assert(result!=NULL);
ffffffffc0202c5c:	c129                	beqz	a0,ffffffffc0202c9e <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202c5e:	842a                	mv	s0,a0
ffffffffc0202c60:	01893503          	ld	a0,24(s2)
ffffffffc0202c64:	4601                	li	a2,0
ffffffffc0202c66:	85a6                	mv	a1,s1
ffffffffc0202c68:	449000ef          	jal	ra,ffffffffc02038b0 <get_pte>
ffffffffc0202c6c:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0202c6e:	6108                	ld	a0,0(a0)
ffffffffc0202c70:	85a2                	mv	a1,s0
ffffffffc0202c72:	060020ef          	jal	ra,ffffffffc0204cd2 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202c76:	00093583          	ld	a1,0(s2)
ffffffffc0202c7a:	8626                	mv	a2,s1
ffffffffc0202c7c:	00005517          	auipc	a0,0x5
ffffffffc0202c80:	f2450513          	addi	a0,a0,-220 # ffffffffc0207ba0 <commands+0x1200>
ffffffffc0202c84:	81a1                	srli	a1,a1,0x8
ffffffffc0202c86:	c46fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0202c8a:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0202c8c:	0089b023          	sd	s0,0(s3)
}
ffffffffc0202c90:	7402                	ld	s0,32(sp)
ffffffffc0202c92:	64e2                	ld	s1,24(sp)
ffffffffc0202c94:	6942                	ld	s2,16(sp)
ffffffffc0202c96:	69a2                	ld	s3,8(sp)
ffffffffc0202c98:	4501                	li	a0,0
ffffffffc0202c9a:	6145                	addi	sp,sp,48
ffffffffc0202c9c:	8082                	ret
     assert(result!=NULL);
ffffffffc0202c9e:	00005697          	auipc	a3,0x5
ffffffffc0202ca2:	ef268693          	addi	a3,a3,-270 # ffffffffc0207b90 <commands+0x11f0>
ffffffffc0202ca6:	00004617          	auipc	a2,0x4
ffffffffc0202caa:	10a60613          	addi	a2,a2,266 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202cae:	07e00593          	li	a1,126
ffffffffc0202cb2:	00005517          	auipc	a0,0x5
ffffffffc0202cb6:	bb650513          	addi	a0,a0,-1098 # ffffffffc0207868 <commands+0xec8>
ffffffffc0202cba:	d4efd0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0202cbe <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0202cbe:	000ac797          	auipc	a5,0xac
ffffffffc0202cc2:	ae278793          	addi	a5,a5,-1310 # ffffffffc02ae7a0 <free_area>
ffffffffc0202cc6:	e79c                	sd	a5,8(a5)
ffffffffc0202cc8:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0202cca:	0007a823          	sw	zero,16(a5)
}
ffffffffc0202cce:	8082                	ret

ffffffffc0202cd0 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0202cd0:	000ac517          	auipc	a0,0xac
ffffffffc0202cd4:	ae056503          	lwu	a0,-1312(a0) # ffffffffc02ae7b0 <free_area+0x10>
ffffffffc0202cd8:	8082                	ret

ffffffffc0202cda <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0202cda:	715d                	addi	sp,sp,-80
ffffffffc0202cdc:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0202cde:	000ac417          	auipc	s0,0xac
ffffffffc0202ce2:	ac240413          	addi	s0,s0,-1342 # ffffffffc02ae7a0 <free_area>
ffffffffc0202ce6:	641c                	ld	a5,8(s0)
ffffffffc0202ce8:	e486                	sd	ra,72(sp)
ffffffffc0202cea:	fc26                	sd	s1,56(sp)
ffffffffc0202cec:	f84a                	sd	s2,48(sp)
ffffffffc0202cee:	f44e                	sd	s3,40(sp)
ffffffffc0202cf0:	f052                	sd	s4,32(sp)
ffffffffc0202cf2:	ec56                	sd	s5,24(sp)
ffffffffc0202cf4:	e85a                	sd	s6,16(sp)
ffffffffc0202cf6:	e45e                	sd	s7,8(sp)
ffffffffc0202cf8:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202cfa:	2a878d63          	beq	a5,s0,ffffffffc0202fb4 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0202cfe:	4481                	li	s1,0
ffffffffc0202d00:	4901                	li	s2,0
ffffffffc0202d02:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202d06:	8b09                	andi	a4,a4,2
ffffffffc0202d08:	2a070a63          	beqz	a4,ffffffffc0202fbc <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0202d0c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202d10:	679c                	ld	a5,8(a5)
ffffffffc0202d12:	2905                	addiw	s2,s2,1
ffffffffc0202d14:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202d16:	fe8796e3          	bne	a5,s0,ffffffffc0202d02 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0202d1a:	89a6                	mv	s3,s1
ffffffffc0202d1c:	35b000ef          	jal	ra,ffffffffc0203876 <nr_free_pages>
ffffffffc0202d20:	6f351e63          	bne	a0,s3,ffffffffc020341c <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202d24:	4505                	li	a0,1
ffffffffc0202d26:	27f000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202d2a:	8aaa                	mv	s5,a0
ffffffffc0202d2c:	42050863          	beqz	a0,ffffffffc020315c <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202d30:	4505                	li	a0,1
ffffffffc0202d32:	273000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202d36:	89aa                	mv	s3,a0
ffffffffc0202d38:	70050263          	beqz	a0,ffffffffc020343c <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202d3c:	4505                	li	a0,1
ffffffffc0202d3e:	267000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202d42:	8a2a                	mv	s4,a0
ffffffffc0202d44:	48050c63          	beqz	a0,ffffffffc02031dc <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202d48:	293a8a63          	beq	s5,s3,ffffffffc0202fdc <default_check+0x302>
ffffffffc0202d4c:	28aa8863          	beq	s5,a0,ffffffffc0202fdc <default_check+0x302>
ffffffffc0202d50:	28a98663          	beq	s3,a0,ffffffffc0202fdc <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202d54:	000aa783          	lw	a5,0(s5)
ffffffffc0202d58:	2a079263          	bnez	a5,ffffffffc0202ffc <default_check+0x322>
ffffffffc0202d5c:	0009a783          	lw	a5,0(s3)
ffffffffc0202d60:	28079e63          	bnez	a5,ffffffffc0202ffc <default_check+0x322>
ffffffffc0202d64:	411c                	lw	a5,0(a0)
ffffffffc0202d66:	28079b63          	bnez	a5,ffffffffc0202ffc <default_check+0x322>
    return page - pages + nbase;
ffffffffc0202d6a:	000b0797          	auipc	a5,0xb0
ffffffffc0202d6e:	abe7b783          	ld	a5,-1346(a5) # ffffffffc02b2828 <pages>
ffffffffc0202d72:	40fa8733          	sub	a4,s5,a5
ffffffffc0202d76:	00006617          	auipc	a2,0x6
ffffffffc0202d7a:	0d263603          	ld	a2,210(a2) # ffffffffc0208e48 <nbase>
ffffffffc0202d7e:	8719                	srai	a4,a4,0x6
ffffffffc0202d80:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202d82:	000b0697          	auipc	a3,0xb0
ffffffffc0202d86:	a9e6b683          	ld	a3,-1378(a3) # ffffffffc02b2820 <npage>
ffffffffc0202d8a:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d8c:	0732                	slli	a4,a4,0xc
ffffffffc0202d8e:	28d77763          	bgeu	a4,a3,ffffffffc020301c <default_check+0x342>
    return page - pages + nbase;
ffffffffc0202d92:	40f98733          	sub	a4,s3,a5
ffffffffc0202d96:	8719                	srai	a4,a4,0x6
ffffffffc0202d98:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d9a:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202d9c:	4cd77063          	bgeu	a4,a3,ffffffffc020325c <default_check+0x582>
    return page - pages + nbase;
ffffffffc0202da0:	40f507b3          	sub	a5,a0,a5
ffffffffc0202da4:	8799                	srai	a5,a5,0x6
ffffffffc0202da6:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202da8:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202daa:	30d7f963          	bgeu	a5,a3,ffffffffc02030bc <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0202dae:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202db0:	00043c03          	ld	s8,0(s0)
ffffffffc0202db4:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0202db8:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0202dbc:	e400                	sd	s0,8(s0)
ffffffffc0202dbe:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0202dc0:	000ac797          	auipc	a5,0xac
ffffffffc0202dc4:	9e07a823          	sw	zero,-1552(a5) # ffffffffc02ae7b0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202dc8:	1dd000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202dcc:	2c051863          	bnez	a0,ffffffffc020309c <default_check+0x3c2>
    free_page(p0);
ffffffffc0202dd0:	4585                	li	a1,1
ffffffffc0202dd2:	8556                	mv	a0,s5
ffffffffc0202dd4:	263000ef          	jal	ra,ffffffffc0203836 <free_pages>
    free_page(p1);
ffffffffc0202dd8:	4585                	li	a1,1
ffffffffc0202dda:	854e                	mv	a0,s3
ffffffffc0202ddc:	25b000ef          	jal	ra,ffffffffc0203836 <free_pages>
    free_page(p2);
ffffffffc0202de0:	4585                	li	a1,1
ffffffffc0202de2:	8552                	mv	a0,s4
ffffffffc0202de4:	253000ef          	jal	ra,ffffffffc0203836 <free_pages>
    assert(nr_free == 3);
ffffffffc0202de8:	4818                	lw	a4,16(s0)
ffffffffc0202dea:	478d                	li	a5,3
ffffffffc0202dec:	28f71863          	bne	a4,a5,ffffffffc020307c <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202df0:	4505                	li	a0,1
ffffffffc0202df2:	1b3000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202df6:	89aa                	mv	s3,a0
ffffffffc0202df8:	26050263          	beqz	a0,ffffffffc020305c <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202dfc:	4505                	li	a0,1
ffffffffc0202dfe:	1a7000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202e02:	8aaa                	mv	s5,a0
ffffffffc0202e04:	3a050c63          	beqz	a0,ffffffffc02031bc <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202e08:	4505                	li	a0,1
ffffffffc0202e0a:	19b000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202e0e:	8a2a                	mv	s4,a0
ffffffffc0202e10:	38050663          	beqz	a0,ffffffffc020319c <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0202e14:	4505                	li	a0,1
ffffffffc0202e16:	18f000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202e1a:	36051163          	bnez	a0,ffffffffc020317c <default_check+0x4a2>
    free_page(p0);
ffffffffc0202e1e:	4585                	li	a1,1
ffffffffc0202e20:	854e                	mv	a0,s3
ffffffffc0202e22:	215000ef          	jal	ra,ffffffffc0203836 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202e26:	641c                	ld	a5,8(s0)
ffffffffc0202e28:	20878a63          	beq	a5,s0,ffffffffc020303c <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0202e2c:	4505                	li	a0,1
ffffffffc0202e2e:	177000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202e32:	30a99563          	bne	s3,a0,ffffffffc020313c <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0202e36:	4505                	li	a0,1
ffffffffc0202e38:	16d000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202e3c:	2e051063          	bnez	a0,ffffffffc020311c <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0202e40:	481c                	lw	a5,16(s0)
ffffffffc0202e42:	2a079d63          	bnez	a5,ffffffffc02030fc <default_check+0x422>
    free_page(p);
ffffffffc0202e46:	854e                	mv	a0,s3
ffffffffc0202e48:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202e4a:	01843023          	sd	s8,0(s0)
ffffffffc0202e4e:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0202e52:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0202e56:	1e1000ef          	jal	ra,ffffffffc0203836 <free_pages>
    free_page(p1);
ffffffffc0202e5a:	4585                	li	a1,1
ffffffffc0202e5c:	8556                	mv	a0,s5
ffffffffc0202e5e:	1d9000ef          	jal	ra,ffffffffc0203836 <free_pages>
    free_page(p2);
ffffffffc0202e62:	4585                	li	a1,1
ffffffffc0202e64:	8552                	mv	a0,s4
ffffffffc0202e66:	1d1000ef          	jal	ra,ffffffffc0203836 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202e6a:	4515                	li	a0,5
ffffffffc0202e6c:	139000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202e70:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202e72:	26050563          	beqz	a0,ffffffffc02030dc <default_check+0x402>
ffffffffc0202e76:	651c                	ld	a5,8(a0)
ffffffffc0202e78:	8385                	srli	a5,a5,0x1
ffffffffc0202e7a:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0202e7c:	54079063          	bnez	a5,ffffffffc02033bc <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202e80:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202e82:	00043b03          	ld	s6,0(s0)
ffffffffc0202e86:	00843a83          	ld	s5,8(s0)
ffffffffc0202e8a:	e000                	sd	s0,0(s0)
ffffffffc0202e8c:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0202e8e:	117000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202e92:	50051563          	bnez	a0,ffffffffc020339c <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202e96:	08098a13          	addi	s4,s3,128
ffffffffc0202e9a:	8552                	mv	a0,s4
ffffffffc0202e9c:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202e9e:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0202ea2:	000ac797          	auipc	a5,0xac
ffffffffc0202ea6:	9007a723          	sw	zero,-1778(a5) # ffffffffc02ae7b0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202eaa:	18d000ef          	jal	ra,ffffffffc0203836 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0202eae:	4511                	li	a0,4
ffffffffc0202eb0:	0f5000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202eb4:	4c051463          	bnez	a0,ffffffffc020337c <default_check+0x6a2>
ffffffffc0202eb8:	0889b783          	ld	a5,136(s3)
ffffffffc0202ebc:	8385                	srli	a5,a5,0x1
ffffffffc0202ebe:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202ec0:	48078e63          	beqz	a5,ffffffffc020335c <default_check+0x682>
ffffffffc0202ec4:	0909a703          	lw	a4,144(s3)
ffffffffc0202ec8:	478d                	li	a5,3
ffffffffc0202eca:	48f71963          	bne	a4,a5,ffffffffc020335c <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202ece:	450d                	li	a0,3
ffffffffc0202ed0:	0d5000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202ed4:	8c2a                	mv	s8,a0
ffffffffc0202ed6:	46050363          	beqz	a0,ffffffffc020333c <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0202eda:	4505                	li	a0,1
ffffffffc0202edc:	0c9000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202ee0:	42051e63          	bnez	a0,ffffffffc020331c <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0202ee4:	418a1c63          	bne	s4,s8,ffffffffc02032fc <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0202ee8:	4585                	li	a1,1
ffffffffc0202eea:	854e                	mv	a0,s3
ffffffffc0202eec:	14b000ef          	jal	ra,ffffffffc0203836 <free_pages>
    free_pages(p1, 3);
ffffffffc0202ef0:	458d                	li	a1,3
ffffffffc0202ef2:	8552                	mv	a0,s4
ffffffffc0202ef4:	143000ef          	jal	ra,ffffffffc0203836 <free_pages>
ffffffffc0202ef8:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202efc:	04098c13          	addi	s8,s3,64
ffffffffc0202f00:	8385                	srli	a5,a5,0x1
ffffffffc0202f02:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202f04:	3c078c63          	beqz	a5,ffffffffc02032dc <default_check+0x602>
ffffffffc0202f08:	0109a703          	lw	a4,16(s3)
ffffffffc0202f0c:	4785                	li	a5,1
ffffffffc0202f0e:	3cf71763          	bne	a4,a5,ffffffffc02032dc <default_check+0x602>
ffffffffc0202f12:	008a3783          	ld	a5,8(s4)
ffffffffc0202f16:	8385                	srli	a5,a5,0x1
ffffffffc0202f18:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202f1a:	3a078163          	beqz	a5,ffffffffc02032bc <default_check+0x5e2>
ffffffffc0202f1e:	010a2703          	lw	a4,16(s4)
ffffffffc0202f22:	478d                	li	a5,3
ffffffffc0202f24:	38f71c63          	bne	a4,a5,ffffffffc02032bc <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202f28:	4505                	li	a0,1
ffffffffc0202f2a:	07b000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202f2e:	36a99763          	bne	s3,a0,ffffffffc020329c <default_check+0x5c2>
    free_page(p0);
ffffffffc0202f32:	4585                	li	a1,1
ffffffffc0202f34:	103000ef          	jal	ra,ffffffffc0203836 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202f38:	4509                	li	a0,2
ffffffffc0202f3a:	06b000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202f3e:	32aa1f63          	bne	s4,a0,ffffffffc020327c <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0202f42:	4589                	li	a1,2
ffffffffc0202f44:	0f3000ef          	jal	ra,ffffffffc0203836 <free_pages>
    free_page(p2);
ffffffffc0202f48:	4585                	li	a1,1
ffffffffc0202f4a:	8562                	mv	a0,s8
ffffffffc0202f4c:	0eb000ef          	jal	ra,ffffffffc0203836 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202f50:	4515                	li	a0,5
ffffffffc0202f52:	053000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202f56:	89aa                	mv	s3,a0
ffffffffc0202f58:	48050263          	beqz	a0,ffffffffc02033dc <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0202f5c:	4505                	li	a0,1
ffffffffc0202f5e:	047000ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0202f62:	2c051d63          	bnez	a0,ffffffffc020323c <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0202f66:	481c                	lw	a5,16(s0)
ffffffffc0202f68:	2a079a63          	bnez	a5,ffffffffc020321c <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0202f6c:	4595                	li	a1,5
ffffffffc0202f6e:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0202f70:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0202f74:	01643023          	sd	s6,0(s0)
ffffffffc0202f78:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0202f7c:	0bb000ef          	jal	ra,ffffffffc0203836 <free_pages>
    return listelm->next;
ffffffffc0202f80:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202f82:	00878963          	beq	a5,s0,ffffffffc0202f94 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0202f86:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202f8a:	679c                	ld	a5,8(a5)
ffffffffc0202f8c:	397d                	addiw	s2,s2,-1
ffffffffc0202f8e:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202f90:	fe879be3          	bne	a5,s0,ffffffffc0202f86 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0202f94:	26091463          	bnez	s2,ffffffffc02031fc <default_check+0x522>
    assert(total == 0);
ffffffffc0202f98:	46049263          	bnez	s1,ffffffffc02033fc <default_check+0x722>
}
ffffffffc0202f9c:	60a6                	ld	ra,72(sp)
ffffffffc0202f9e:	6406                	ld	s0,64(sp)
ffffffffc0202fa0:	74e2                	ld	s1,56(sp)
ffffffffc0202fa2:	7942                	ld	s2,48(sp)
ffffffffc0202fa4:	79a2                	ld	s3,40(sp)
ffffffffc0202fa6:	7a02                	ld	s4,32(sp)
ffffffffc0202fa8:	6ae2                	ld	s5,24(sp)
ffffffffc0202faa:	6b42                	ld	s6,16(sp)
ffffffffc0202fac:	6ba2                	ld	s7,8(sp)
ffffffffc0202fae:	6c02                	ld	s8,0(sp)
ffffffffc0202fb0:	6161                	addi	sp,sp,80
ffffffffc0202fb2:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202fb4:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0202fb6:	4481                	li	s1,0
ffffffffc0202fb8:	4901                	li	s2,0
ffffffffc0202fba:	b38d                	j	ffffffffc0202d1c <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0202fbc:	00005697          	auipc	a3,0x5
ffffffffc0202fc0:	8d468693          	addi	a3,a3,-1836 # ffffffffc0207890 <commands+0xef0>
ffffffffc0202fc4:	00004617          	auipc	a2,0x4
ffffffffc0202fc8:	dec60613          	addi	a2,a2,-532 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202fcc:	0f000593          	li	a1,240
ffffffffc0202fd0:	00005517          	auipc	a0,0x5
ffffffffc0202fd4:	c1050513          	addi	a0,a0,-1008 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0202fd8:	a30fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202fdc:	00005697          	auipc	a3,0x5
ffffffffc0202fe0:	c7c68693          	addi	a3,a3,-900 # ffffffffc0207c58 <commands+0x12b8>
ffffffffc0202fe4:	00004617          	auipc	a2,0x4
ffffffffc0202fe8:	dcc60613          	addi	a2,a2,-564 # ffffffffc0206db0 <commands+0x410>
ffffffffc0202fec:	0bd00593          	li	a1,189
ffffffffc0202ff0:	00005517          	auipc	a0,0x5
ffffffffc0202ff4:	bf050513          	addi	a0,a0,-1040 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0202ff8:	a10fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202ffc:	00005697          	auipc	a3,0x5
ffffffffc0203000:	c8468693          	addi	a3,a3,-892 # ffffffffc0207c80 <commands+0x12e0>
ffffffffc0203004:	00004617          	auipc	a2,0x4
ffffffffc0203008:	dac60613          	addi	a2,a2,-596 # ffffffffc0206db0 <commands+0x410>
ffffffffc020300c:	0be00593          	li	a1,190
ffffffffc0203010:	00005517          	auipc	a0,0x5
ffffffffc0203014:	bd050513          	addi	a0,a0,-1072 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203018:	9f0fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020301c:	00005697          	auipc	a3,0x5
ffffffffc0203020:	ca468693          	addi	a3,a3,-860 # ffffffffc0207cc0 <commands+0x1320>
ffffffffc0203024:	00004617          	auipc	a2,0x4
ffffffffc0203028:	d8c60613          	addi	a2,a2,-628 # ffffffffc0206db0 <commands+0x410>
ffffffffc020302c:	0c000593          	li	a1,192
ffffffffc0203030:	00005517          	auipc	a0,0x5
ffffffffc0203034:	bb050513          	addi	a0,a0,-1104 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203038:	9d0fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!list_empty(&free_list));
ffffffffc020303c:	00005697          	auipc	a3,0x5
ffffffffc0203040:	d0c68693          	addi	a3,a3,-756 # ffffffffc0207d48 <commands+0x13a8>
ffffffffc0203044:	00004617          	auipc	a2,0x4
ffffffffc0203048:	d6c60613          	addi	a2,a2,-660 # ffffffffc0206db0 <commands+0x410>
ffffffffc020304c:	0d900593          	li	a1,217
ffffffffc0203050:	00005517          	auipc	a0,0x5
ffffffffc0203054:	b9050513          	addi	a0,a0,-1136 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203058:	9b0fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020305c:	00005697          	auipc	a3,0x5
ffffffffc0203060:	b9c68693          	addi	a3,a3,-1124 # ffffffffc0207bf8 <commands+0x1258>
ffffffffc0203064:	00004617          	auipc	a2,0x4
ffffffffc0203068:	d4c60613          	addi	a2,a2,-692 # ffffffffc0206db0 <commands+0x410>
ffffffffc020306c:	0d200593          	li	a1,210
ffffffffc0203070:	00005517          	auipc	a0,0x5
ffffffffc0203074:	b7050513          	addi	a0,a0,-1168 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203078:	990fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 3);
ffffffffc020307c:	00005697          	auipc	a3,0x5
ffffffffc0203080:	cbc68693          	addi	a3,a3,-836 # ffffffffc0207d38 <commands+0x1398>
ffffffffc0203084:	00004617          	auipc	a2,0x4
ffffffffc0203088:	d2c60613          	addi	a2,a2,-724 # ffffffffc0206db0 <commands+0x410>
ffffffffc020308c:	0d000593          	li	a1,208
ffffffffc0203090:	00005517          	auipc	a0,0x5
ffffffffc0203094:	b5050513          	addi	a0,a0,-1200 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203098:	970fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020309c:	00005697          	auipc	a3,0x5
ffffffffc02030a0:	c8468693          	addi	a3,a3,-892 # ffffffffc0207d20 <commands+0x1380>
ffffffffc02030a4:	00004617          	auipc	a2,0x4
ffffffffc02030a8:	d0c60613          	addi	a2,a2,-756 # ffffffffc0206db0 <commands+0x410>
ffffffffc02030ac:	0cb00593          	li	a1,203
ffffffffc02030b0:	00005517          	auipc	a0,0x5
ffffffffc02030b4:	b3050513          	addi	a0,a0,-1232 # ffffffffc0207be0 <commands+0x1240>
ffffffffc02030b8:	950fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02030bc:	00005697          	auipc	a3,0x5
ffffffffc02030c0:	c4468693          	addi	a3,a3,-956 # ffffffffc0207d00 <commands+0x1360>
ffffffffc02030c4:	00004617          	auipc	a2,0x4
ffffffffc02030c8:	cec60613          	addi	a2,a2,-788 # ffffffffc0206db0 <commands+0x410>
ffffffffc02030cc:	0c200593          	li	a1,194
ffffffffc02030d0:	00005517          	auipc	a0,0x5
ffffffffc02030d4:	b1050513          	addi	a0,a0,-1264 # ffffffffc0207be0 <commands+0x1240>
ffffffffc02030d8:	930fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 != NULL);
ffffffffc02030dc:	00005697          	auipc	a3,0x5
ffffffffc02030e0:	ca468693          	addi	a3,a3,-860 # ffffffffc0207d80 <commands+0x13e0>
ffffffffc02030e4:	00004617          	auipc	a2,0x4
ffffffffc02030e8:	ccc60613          	addi	a2,a2,-820 # ffffffffc0206db0 <commands+0x410>
ffffffffc02030ec:	0f800593          	li	a1,248
ffffffffc02030f0:	00005517          	auipc	a0,0x5
ffffffffc02030f4:	af050513          	addi	a0,a0,-1296 # ffffffffc0207be0 <commands+0x1240>
ffffffffc02030f8:	910fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc02030fc:	00005697          	auipc	a3,0x5
ffffffffc0203100:	93468693          	addi	a3,a3,-1740 # ffffffffc0207a30 <commands+0x1090>
ffffffffc0203104:	00004617          	auipc	a2,0x4
ffffffffc0203108:	cac60613          	addi	a2,a2,-852 # ffffffffc0206db0 <commands+0x410>
ffffffffc020310c:	0df00593          	li	a1,223
ffffffffc0203110:	00005517          	auipc	a0,0x5
ffffffffc0203114:	ad050513          	addi	a0,a0,-1328 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203118:	8f0fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020311c:	00005697          	auipc	a3,0x5
ffffffffc0203120:	c0468693          	addi	a3,a3,-1020 # ffffffffc0207d20 <commands+0x1380>
ffffffffc0203124:	00004617          	auipc	a2,0x4
ffffffffc0203128:	c8c60613          	addi	a2,a2,-884 # ffffffffc0206db0 <commands+0x410>
ffffffffc020312c:	0dd00593          	li	a1,221
ffffffffc0203130:	00005517          	auipc	a0,0x5
ffffffffc0203134:	ab050513          	addi	a0,a0,-1360 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203138:	8d0fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020313c:	00005697          	auipc	a3,0x5
ffffffffc0203140:	c2468693          	addi	a3,a3,-988 # ffffffffc0207d60 <commands+0x13c0>
ffffffffc0203144:	00004617          	auipc	a2,0x4
ffffffffc0203148:	c6c60613          	addi	a2,a2,-916 # ffffffffc0206db0 <commands+0x410>
ffffffffc020314c:	0dc00593          	li	a1,220
ffffffffc0203150:	00005517          	auipc	a0,0x5
ffffffffc0203154:	a9050513          	addi	a0,a0,-1392 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203158:	8b0fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020315c:	00005697          	auipc	a3,0x5
ffffffffc0203160:	a9c68693          	addi	a3,a3,-1380 # ffffffffc0207bf8 <commands+0x1258>
ffffffffc0203164:	00004617          	auipc	a2,0x4
ffffffffc0203168:	c4c60613          	addi	a2,a2,-948 # ffffffffc0206db0 <commands+0x410>
ffffffffc020316c:	0b900593          	li	a1,185
ffffffffc0203170:	00005517          	auipc	a0,0x5
ffffffffc0203174:	a7050513          	addi	a0,a0,-1424 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203178:	890fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020317c:	00005697          	auipc	a3,0x5
ffffffffc0203180:	ba468693          	addi	a3,a3,-1116 # ffffffffc0207d20 <commands+0x1380>
ffffffffc0203184:	00004617          	auipc	a2,0x4
ffffffffc0203188:	c2c60613          	addi	a2,a2,-980 # ffffffffc0206db0 <commands+0x410>
ffffffffc020318c:	0d600593          	li	a1,214
ffffffffc0203190:	00005517          	auipc	a0,0x5
ffffffffc0203194:	a5050513          	addi	a0,a0,-1456 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203198:	870fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020319c:	00005697          	auipc	a3,0x5
ffffffffc02031a0:	a9c68693          	addi	a3,a3,-1380 # ffffffffc0207c38 <commands+0x1298>
ffffffffc02031a4:	00004617          	auipc	a2,0x4
ffffffffc02031a8:	c0c60613          	addi	a2,a2,-1012 # ffffffffc0206db0 <commands+0x410>
ffffffffc02031ac:	0d400593          	li	a1,212
ffffffffc02031b0:	00005517          	auipc	a0,0x5
ffffffffc02031b4:	a3050513          	addi	a0,a0,-1488 # ffffffffc0207be0 <commands+0x1240>
ffffffffc02031b8:	850fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02031bc:	00005697          	auipc	a3,0x5
ffffffffc02031c0:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0207c18 <commands+0x1278>
ffffffffc02031c4:	00004617          	auipc	a2,0x4
ffffffffc02031c8:	bec60613          	addi	a2,a2,-1044 # ffffffffc0206db0 <commands+0x410>
ffffffffc02031cc:	0d300593          	li	a1,211
ffffffffc02031d0:	00005517          	auipc	a0,0x5
ffffffffc02031d4:	a1050513          	addi	a0,a0,-1520 # ffffffffc0207be0 <commands+0x1240>
ffffffffc02031d8:	830fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02031dc:	00005697          	auipc	a3,0x5
ffffffffc02031e0:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0207c38 <commands+0x1298>
ffffffffc02031e4:	00004617          	auipc	a2,0x4
ffffffffc02031e8:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0206db0 <commands+0x410>
ffffffffc02031ec:	0bb00593          	li	a1,187
ffffffffc02031f0:	00005517          	auipc	a0,0x5
ffffffffc02031f4:	9f050513          	addi	a0,a0,-1552 # ffffffffc0207be0 <commands+0x1240>
ffffffffc02031f8:	810fd0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(count == 0);
ffffffffc02031fc:	00005697          	auipc	a3,0x5
ffffffffc0203200:	cd468693          	addi	a3,a3,-812 # ffffffffc0207ed0 <commands+0x1530>
ffffffffc0203204:	00004617          	auipc	a2,0x4
ffffffffc0203208:	bac60613          	addi	a2,a2,-1108 # ffffffffc0206db0 <commands+0x410>
ffffffffc020320c:	12500593          	li	a1,293
ffffffffc0203210:	00005517          	auipc	a0,0x5
ffffffffc0203214:	9d050513          	addi	a0,a0,-1584 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203218:	ff1fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free == 0);
ffffffffc020321c:	00005697          	auipc	a3,0x5
ffffffffc0203220:	81468693          	addi	a3,a3,-2028 # ffffffffc0207a30 <commands+0x1090>
ffffffffc0203224:	00004617          	auipc	a2,0x4
ffffffffc0203228:	b8c60613          	addi	a2,a2,-1140 # ffffffffc0206db0 <commands+0x410>
ffffffffc020322c:	11a00593          	li	a1,282
ffffffffc0203230:	00005517          	auipc	a0,0x5
ffffffffc0203234:	9b050513          	addi	a0,a0,-1616 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203238:	fd1fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020323c:	00005697          	auipc	a3,0x5
ffffffffc0203240:	ae468693          	addi	a3,a3,-1308 # ffffffffc0207d20 <commands+0x1380>
ffffffffc0203244:	00004617          	auipc	a2,0x4
ffffffffc0203248:	b6c60613          	addi	a2,a2,-1172 # ffffffffc0206db0 <commands+0x410>
ffffffffc020324c:	11800593          	li	a1,280
ffffffffc0203250:	00005517          	auipc	a0,0x5
ffffffffc0203254:	99050513          	addi	a0,a0,-1648 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203258:	fb1fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020325c:	00005697          	auipc	a3,0x5
ffffffffc0203260:	a8468693          	addi	a3,a3,-1404 # ffffffffc0207ce0 <commands+0x1340>
ffffffffc0203264:	00004617          	auipc	a2,0x4
ffffffffc0203268:	b4c60613          	addi	a2,a2,-1204 # ffffffffc0206db0 <commands+0x410>
ffffffffc020326c:	0c100593          	li	a1,193
ffffffffc0203270:	00005517          	auipc	a0,0x5
ffffffffc0203274:	97050513          	addi	a0,a0,-1680 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203278:	f91fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020327c:	00005697          	auipc	a3,0x5
ffffffffc0203280:	c1468693          	addi	a3,a3,-1004 # ffffffffc0207e90 <commands+0x14f0>
ffffffffc0203284:	00004617          	auipc	a2,0x4
ffffffffc0203288:	b2c60613          	addi	a2,a2,-1236 # ffffffffc0206db0 <commands+0x410>
ffffffffc020328c:	11200593          	li	a1,274
ffffffffc0203290:	00005517          	auipc	a0,0x5
ffffffffc0203294:	95050513          	addi	a0,a0,-1712 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203298:	f71fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020329c:	00005697          	auipc	a3,0x5
ffffffffc02032a0:	bd468693          	addi	a3,a3,-1068 # ffffffffc0207e70 <commands+0x14d0>
ffffffffc02032a4:	00004617          	auipc	a2,0x4
ffffffffc02032a8:	b0c60613          	addi	a2,a2,-1268 # ffffffffc0206db0 <commands+0x410>
ffffffffc02032ac:	11000593          	li	a1,272
ffffffffc02032b0:	00005517          	auipc	a0,0x5
ffffffffc02032b4:	93050513          	addi	a0,a0,-1744 # ffffffffc0207be0 <commands+0x1240>
ffffffffc02032b8:	f51fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02032bc:	00005697          	auipc	a3,0x5
ffffffffc02032c0:	b8c68693          	addi	a3,a3,-1140 # ffffffffc0207e48 <commands+0x14a8>
ffffffffc02032c4:	00004617          	auipc	a2,0x4
ffffffffc02032c8:	aec60613          	addi	a2,a2,-1300 # ffffffffc0206db0 <commands+0x410>
ffffffffc02032cc:	10e00593          	li	a1,270
ffffffffc02032d0:	00005517          	auipc	a0,0x5
ffffffffc02032d4:	91050513          	addi	a0,a0,-1776 # ffffffffc0207be0 <commands+0x1240>
ffffffffc02032d8:	f31fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02032dc:	00005697          	auipc	a3,0x5
ffffffffc02032e0:	b4468693          	addi	a3,a3,-1212 # ffffffffc0207e20 <commands+0x1480>
ffffffffc02032e4:	00004617          	auipc	a2,0x4
ffffffffc02032e8:	acc60613          	addi	a2,a2,-1332 # ffffffffc0206db0 <commands+0x410>
ffffffffc02032ec:	10d00593          	li	a1,269
ffffffffc02032f0:	00005517          	auipc	a0,0x5
ffffffffc02032f4:	8f050513          	addi	a0,a0,-1808 # ffffffffc0207be0 <commands+0x1240>
ffffffffc02032f8:	f11fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02032fc:	00005697          	auipc	a3,0x5
ffffffffc0203300:	b1468693          	addi	a3,a3,-1260 # ffffffffc0207e10 <commands+0x1470>
ffffffffc0203304:	00004617          	auipc	a2,0x4
ffffffffc0203308:	aac60613          	addi	a2,a2,-1364 # ffffffffc0206db0 <commands+0x410>
ffffffffc020330c:	10800593          	li	a1,264
ffffffffc0203310:	00005517          	auipc	a0,0x5
ffffffffc0203314:	8d050513          	addi	a0,a0,-1840 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203318:	ef1fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020331c:	00005697          	auipc	a3,0x5
ffffffffc0203320:	a0468693          	addi	a3,a3,-1532 # ffffffffc0207d20 <commands+0x1380>
ffffffffc0203324:	00004617          	auipc	a2,0x4
ffffffffc0203328:	a8c60613          	addi	a2,a2,-1396 # ffffffffc0206db0 <commands+0x410>
ffffffffc020332c:	10700593          	li	a1,263
ffffffffc0203330:	00005517          	auipc	a0,0x5
ffffffffc0203334:	8b050513          	addi	a0,a0,-1872 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203338:	ed1fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020333c:	00005697          	auipc	a3,0x5
ffffffffc0203340:	ab468693          	addi	a3,a3,-1356 # ffffffffc0207df0 <commands+0x1450>
ffffffffc0203344:	00004617          	auipc	a2,0x4
ffffffffc0203348:	a6c60613          	addi	a2,a2,-1428 # ffffffffc0206db0 <commands+0x410>
ffffffffc020334c:	10600593          	li	a1,262
ffffffffc0203350:	00005517          	auipc	a0,0x5
ffffffffc0203354:	89050513          	addi	a0,a0,-1904 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203358:	eb1fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020335c:	00005697          	auipc	a3,0x5
ffffffffc0203360:	a6468693          	addi	a3,a3,-1436 # ffffffffc0207dc0 <commands+0x1420>
ffffffffc0203364:	00004617          	auipc	a2,0x4
ffffffffc0203368:	a4c60613          	addi	a2,a2,-1460 # ffffffffc0206db0 <commands+0x410>
ffffffffc020336c:	10500593          	li	a1,261
ffffffffc0203370:	00005517          	auipc	a0,0x5
ffffffffc0203374:	87050513          	addi	a0,a0,-1936 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203378:	e91fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020337c:	00005697          	auipc	a3,0x5
ffffffffc0203380:	a2c68693          	addi	a3,a3,-1492 # ffffffffc0207da8 <commands+0x1408>
ffffffffc0203384:	00004617          	auipc	a2,0x4
ffffffffc0203388:	a2c60613          	addi	a2,a2,-1492 # ffffffffc0206db0 <commands+0x410>
ffffffffc020338c:	10400593          	li	a1,260
ffffffffc0203390:	00005517          	auipc	a0,0x5
ffffffffc0203394:	85050513          	addi	a0,a0,-1968 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203398:	e71fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020339c:	00005697          	auipc	a3,0x5
ffffffffc02033a0:	98468693          	addi	a3,a3,-1660 # ffffffffc0207d20 <commands+0x1380>
ffffffffc02033a4:	00004617          	auipc	a2,0x4
ffffffffc02033a8:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0206db0 <commands+0x410>
ffffffffc02033ac:	0fe00593          	li	a1,254
ffffffffc02033b0:	00005517          	auipc	a0,0x5
ffffffffc02033b4:	83050513          	addi	a0,a0,-2000 # ffffffffc0207be0 <commands+0x1240>
ffffffffc02033b8:	e51fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(!PageProperty(p0));
ffffffffc02033bc:	00005697          	auipc	a3,0x5
ffffffffc02033c0:	9d468693          	addi	a3,a3,-1580 # ffffffffc0207d90 <commands+0x13f0>
ffffffffc02033c4:	00004617          	auipc	a2,0x4
ffffffffc02033c8:	9ec60613          	addi	a2,a2,-1556 # ffffffffc0206db0 <commands+0x410>
ffffffffc02033cc:	0f900593          	li	a1,249
ffffffffc02033d0:	00005517          	auipc	a0,0x5
ffffffffc02033d4:	81050513          	addi	a0,a0,-2032 # ffffffffc0207be0 <commands+0x1240>
ffffffffc02033d8:	e31fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02033dc:	00005697          	auipc	a3,0x5
ffffffffc02033e0:	ad468693          	addi	a3,a3,-1324 # ffffffffc0207eb0 <commands+0x1510>
ffffffffc02033e4:	00004617          	auipc	a2,0x4
ffffffffc02033e8:	9cc60613          	addi	a2,a2,-1588 # ffffffffc0206db0 <commands+0x410>
ffffffffc02033ec:	11700593          	li	a1,279
ffffffffc02033f0:	00004517          	auipc	a0,0x4
ffffffffc02033f4:	7f050513          	addi	a0,a0,2032 # ffffffffc0207be0 <commands+0x1240>
ffffffffc02033f8:	e11fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == 0);
ffffffffc02033fc:	00005697          	auipc	a3,0x5
ffffffffc0203400:	ae468693          	addi	a3,a3,-1308 # ffffffffc0207ee0 <commands+0x1540>
ffffffffc0203404:	00004617          	auipc	a2,0x4
ffffffffc0203408:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0206db0 <commands+0x410>
ffffffffc020340c:	12600593          	li	a1,294
ffffffffc0203410:	00004517          	auipc	a0,0x4
ffffffffc0203414:	7d050513          	addi	a0,a0,2000 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203418:	df1fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(total == nr_free_pages());
ffffffffc020341c:	00004697          	auipc	a3,0x4
ffffffffc0203420:	48468693          	addi	a3,a3,1156 # ffffffffc02078a0 <commands+0xf00>
ffffffffc0203424:	00004617          	auipc	a2,0x4
ffffffffc0203428:	98c60613          	addi	a2,a2,-1652 # ffffffffc0206db0 <commands+0x410>
ffffffffc020342c:	0f300593          	li	a1,243
ffffffffc0203430:	00004517          	auipc	a0,0x4
ffffffffc0203434:	7b050513          	addi	a0,a0,1968 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203438:	dd1fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020343c:	00004697          	auipc	a3,0x4
ffffffffc0203440:	7dc68693          	addi	a3,a3,2012 # ffffffffc0207c18 <commands+0x1278>
ffffffffc0203444:	00004617          	auipc	a2,0x4
ffffffffc0203448:	96c60613          	addi	a2,a2,-1684 # ffffffffc0206db0 <commands+0x410>
ffffffffc020344c:	0ba00593          	li	a1,186
ffffffffc0203450:	00004517          	auipc	a0,0x4
ffffffffc0203454:	79050513          	addi	a0,a0,1936 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203458:	db1fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020345c <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc020345c:	1141                	addi	sp,sp,-16
ffffffffc020345e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203460:	14058463          	beqz	a1,ffffffffc02035a8 <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0203464:	00659693          	slli	a3,a1,0x6
ffffffffc0203468:	96aa                	add	a3,a3,a0
ffffffffc020346a:	87aa                	mv	a5,a0
ffffffffc020346c:	02d50263          	beq	a0,a3,ffffffffc0203490 <default_free_pages+0x34>
ffffffffc0203470:	6798                	ld	a4,8(a5)
ffffffffc0203472:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203474:	10071a63          	bnez	a4,ffffffffc0203588 <default_free_pages+0x12c>
ffffffffc0203478:	6798                	ld	a4,8(a5)
ffffffffc020347a:	8b09                	andi	a4,a4,2
ffffffffc020347c:	10071663          	bnez	a4,ffffffffc0203588 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0203480:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0203484:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203488:	04078793          	addi	a5,a5,64
ffffffffc020348c:	fed792e3          	bne	a5,a3,ffffffffc0203470 <default_free_pages+0x14>
    base->property = n;
ffffffffc0203490:	2581                	sext.w	a1,a1
ffffffffc0203492:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0203494:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203498:	4789                	li	a5,2
ffffffffc020349a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020349e:	000ab697          	auipc	a3,0xab
ffffffffc02034a2:	30268693          	addi	a3,a3,770 # ffffffffc02ae7a0 <free_area>
ffffffffc02034a6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02034a8:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02034aa:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02034ae:	9db9                	addw	a1,a1,a4
ffffffffc02034b0:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02034b2:	0ad78463          	beq	a5,a3,ffffffffc020355a <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc02034b6:	fe878713          	addi	a4,a5,-24
ffffffffc02034ba:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02034be:	4581                	li	a1,0
            if (base < page) {
ffffffffc02034c0:	00e56a63          	bltu	a0,a4,ffffffffc02034d4 <default_free_pages+0x78>
    return listelm->next;
ffffffffc02034c4:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02034c6:	04d70c63          	beq	a4,a3,ffffffffc020351e <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc02034ca:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02034cc:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02034d0:	fee57ae3          	bgeu	a0,a4,ffffffffc02034c4 <default_free_pages+0x68>
ffffffffc02034d4:	c199                	beqz	a1,ffffffffc02034da <default_free_pages+0x7e>
ffffffffc02034d6:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02034da:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc02034dc:	e390                	sd	a2,0(a5)
ffffffffc02034de:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02034e0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02034e2:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc02034e4:	00d70d63          	beq	a4,a3,ffffffffc02034fe <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc02034e8:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc02034ec:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc02034f0:	02059813          	slli	a6,a1,0x20
ffffffffc02034f4:	01a85793          	srli	a5,a6,0x1a
ffffffffc02034f8:	97b2                	add	a5,a5,a2
ffffffffc02034fa:	02f50c63          	beq	a0,a5,ffffffffc0203532 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc02034fe:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0203500:	00d78c63          	beq	a5,a3,ffffffffc0203518 <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0203504:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0203506:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc020350a:	02061593          	slli	a1,a2,0x20
ffffffffc020350e:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0203512:	972a                	add	a4,a4,a0
ffffffffc0203514:	04e68a63          	beq	a3,a4,ffffffffc0203568 <default_free_pages+0x10c>
}
ffffffffc0203518:	60a2                	ld	ra,8(sp)
ffffffffc020351a:	0141                	addi	sp,sp,16
ffffffffc020351c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020351e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203520:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0203522:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203524:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203526:	02d70763          	beq	a4,a3,ffffffffc0203554 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc020352a:	8832                	mv	a6,a2
ffffffffc020352c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020352e:	87ba                	mv	a5,a4
ffffffffc0203530:	bf71                	j	ffffffffc02034cc <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0203532:	491c                	lw	a5,16(a0)
ffffffffc0203534:	9dbd                	addw	a1,a1,a5
ffffffffc0203536:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020353a:	57f5                	li	a5,-3
ffffffffc020353c:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203540:	01853803          	ld	a6,24(a0)
ffffffffc0203544:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0203546:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0203548:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc020354c:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc020354e:	0105b023          	sd	a6,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0203552:	b77d                	j	ffffffffc0203500 <default_free_pages+0xa4>
ffffffffc0203554:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203556:	873e                	mv	a4,a5
ffffffffc0203558:	bf41                	j	ffffffffc02034e8 <default_free_pages+0x8c>
}
ffffffffc020355a:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020355c:	e390                	sd	a2,0(a5)
ffffffffc020355e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203560:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203562:	ed1c                	sd	a5,24(a0)
ffffffffc0203564:	0141                	addi	sp,sp,16
ffffffffc0203566:	8082                	ret
            base->property += p->property;
ffffffffc0203568:	ff87a703          	lw	a4,-8(a5)
ffffffffc020356c:	ff078693          	addi	a3,a5,-16
ffffffffc0203570:	9e39                	addw	a2,a2,a4
ffffffffc0203572:	c910                	sw	a2,16(a0)
ffffffffc0203574:	5775                	li	a4,-3
ffffffffc0203576:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020357a:	6398                	ld	a4,0(a5)
ffffffffc020357c:	679c                	ld	a5,8(a5)
}
ffffffffc020357e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0203580:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203582:	e398                	sd	a4,0(a5)
ffffffffc0203584:	0141                	addi	sp,sp,16
ffffffffc0203586:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203588:	00005697          	auipc	a3,0x5
ffffffffc020358c:	97068693          	addi	a3,a3,-1680 # ffffffffc0207ef8 <commands+0x1558>
ffffffffc0203590:	00004617          	auipc	a2,0x4
ffffffffc0203594:	82060613          	addi	a2,a2,-2016 # ffffffffc0206db0 <commands+0x410>
ffffffffc0203598:	08300593          	li	a1,131
ffffffffc020359c:	00004517          	auipc	a0,0x4
ffffffffc02035a0:	64450513          	addi	a0,a0,1604 # ffffffffc0207be0 <commands+0x1240>
ffffffffc02035a4:	c65fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc02035a8:	00005697          	auipc	a3,0x5
ffffffffc02035ac:	94868693          	addi	a3,a3,-1720 # ffffffffc0207ef0 <commands+0x1550>
ffffffffc02035b0:	00004617          	auipc	a2,0x4
ffffffffc02035b4:	80060613          	addi	a2,a2,-2048 # ffffffffc0206db0 <commands+0x410>
ffffffffc02035b8:	08000593          	li	a1,128
ffffffffc02035bc:	00004517          	auipc	a0,0x4
ffffffffc02035c0:	62450513          	addi	a0,a0,1572 # ffffffffc0207be0 <commands+0x1240>
ffffffffc02035c4:	c45fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02035c8 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02035c8:	c941                	beqz	a0,ffffffffc0203658 <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc02035ca:	000ab597          	auipc	a1,0xab
ffffffffc02035ce:	1d658593          	addi	a1,a1,470 # ffffffffc02ae7a0 <free_area>
ffffffffc02035d2:	0105a803          	lw	a6,16(a1)
ffffffffc02035d6:	872a                	mv	a4,a0
ffffffffc02035d8:	02081793          	slli	a5,a6,0x20
ffffffffc02035dc:	9381                	srli	a5,a5,0x20
ffffffffc02035de:	00a7ee63          	bltu	a5,a0,ffffffffc02035fa <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02035e2:	87ae                	mv	a5,a1
ffffffffc02035e4:	a801                	j	ffffffffc02035f4 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02035e6:	ff87a683          	lw	a3,-8(a5)
ffffffffc02035ea:	02069613          	slli	a2,a3,0x20
ffffffffc02035ee:	9201                	srli	a2,a2,0x20
ffffffffc02035f0:	00e67763          	bgeu	a2,a4,ffffffffc02035fe <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02035f4:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02035f6:	feb798e3          	bne	a5,a1,ffffffffc02035e6 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02035fa:	4501                	li	a0,0
}
ffffffffc02035fc:	8082                	ret
    return listelm->prev;
ffffffffc02035fe:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203602:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0203606:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc020360a:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc020360e:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0203612:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0203616:	02c77863          	bgeu	a4,a2,ffffffffc0203646 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc020361a:	071a                	slli	a4,a4,0x6
ffffffffc020361c:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc020361e:	41c686bb          	subw	a3,a3,t3
ffffffffc0203622:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203624:	00870613          	addi	a2,a4,8
ffffffffc0203628:	4689                	li	a3,2
ffffffffc020362a:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc020362e:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0203632:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0203636:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc020363a:	e290                	sd	a2,0(a3)
ffffffffc020363c:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0203640:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0203642:	01173c23          	sd	a7,24(a4)
ffffffffc0203646:	41c8083b          	subw	a6,a6,t3
ffffffffc020364a:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020364e:	5775                	li	a4,-3
ffffffffc0203650:	17c1                	addi	a5,a5,-16
ffffffffc0203652:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0203656:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0203658:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020365a:	00005697          	auipc	a3,0x5
ffffffffc020365e:	89668693          	addi	a3,a3,-1898 # ffffffffc0207ef0 <commands+0x1550>
ffffffffc0203662:	00003617          	auipc	a2,0x3
ffffffffc0203666:	74e60613          	addi	a2,a2,1870 # ffffffffc0206db0 <commands+0x410>
ffffffffc020366a:	06200593          	li	a1,98
ffffffffc020366e:	00004517          	auipc	a0,0x4
ffffffffc0203672:	57250513          	addi	a0,a0,1394 # ffffffffc0207be0 <commands+0x1240>
default_alloc_pages(size_t n) {
ffffffffc0203676:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203678:	b91fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020367c <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020367c:	1141                	addi	sp,sp,-16
ffffffffc020367e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203680:	c5f1                	beqz	a1,ffffffffc020374c <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0203682:	00659693          	slli	a3,a1,0x6
ffffffffc0203686:	96aa                	add	a3,a3,a0
ffffffffc0203688:	87aa                	mv	a5,a0
ffffffffc020368a:	00d50f63          	beq	a0,a3,ffffffffc02036a8 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020368e:	6798                	ld	a4,8(a5)
ffffffffc0203690:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc0203692:	cf49                	beqz	a4,ffffffffc020372c <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0203694:	0007a823          	sw	zero,16(a5)
ffffffffc0203698:	0007b423          	sd	zero,8(a5)
ffffffffc020369c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02036a0:	04078793          	addi	a5,a5,64
ffffffffc02036a4:	fed795e3          	bne	a5,a3,ffffffffc020368e <default_init_memmap+0x12>
    base->property = n;
ffffffffc02036a8:	2581                	sext.w	a1,a1
ffffffffc02036aa:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02036ac:	4789                	li	a5,2
ffffffffc02036ae:	00850713          	addi	a4,a0,8
ffffffffc02036b2:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02036b6:	000ab697          	auipc	a3,0xab
ffffffffc02036ba:	0ea68693          	addi	a3,a3,234 # ffffffffc02ae7a0 <free_area>
ffffffffc02036be:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02036c0:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02036c2:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02036c6:	9db9                	addw	a1,a1,a4
ffffffffc02036c8:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02036ca:	04d78a63          	beq	a5,a3,ffffffffc020371e <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc02036ce:	fe878713          	addi	a4,a5,-24
ffffffffc02036d2:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02036d6:	4581                	li	a1,0
            if (base < page) {
ffffffffc02036d8:	00e56a63          	bltu	a0,a4,ffffffffc02036ec <default_init_memmap+0x70>
    return listelm->next;
ffffffffc02036dc:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02036de:	02d70263          	beq	a4,a3,ffffffffc0203702 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc02036e2:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02036e4:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02036e8:	fee57ae3          	bgeu	a0,a4,ffffffffc02036dc <default_init_memmap+0x60>
ffffffffc02036ec:	c199                	beqz	a1,ffffffffc02036f2 <default_init_memmap+0x76>
ffffffffc02036ee:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02036f2:	6398                	ld	a4,0(a5)
}
ffffffffc02036f4:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02036f6:	e390                	sd	a2,0(a5)
ffffffffc02036f8:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02036fa:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02036fc:	ed18                	sd	a4,24(a0)
ffffffffc02036fe:	0141                	addi	sp,sp,16
ffffffffc0203700:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203702:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203704:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0203706:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203708:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020370a:	00d70663          	beq	a4,a3,ffffffffc0203716 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc020370e:	8832                	mv	a6,a2
ffffffffc0203710:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0203712:	87ba                	mv	a5,a4
ffffffffc0203714:	bfc1                	j	ffffffffc02036e4 <default_init_memmap+0x68>
}
ffffffffc0203716:	60a2                	ld	ra,8(sp)
ffffffffc0203718:	e290                	sd	a2,0(a3)
ffffffffc020371a:	0141                	addi	sp,sp,16
ffffffffc020371c:	8082                	ret
ffffffffc020371e:	60a2                	ld	ra,8(sp)
ffffffffc0203720:	e390                	sd	a2,0(a5)
ffffffffc0203722:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203724:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203726:	ed1c                	sd	a5,24(a0)
ffffffffc0203728:	0141                	addi	sp,sp,16
ffffffffc020372a:	8082                	ret
        assert(PageReserved(p));
ffffffffc020372c:	00004697          	auipc	a3,0x4
ffffffffc0203730:	7f468693          	addi	a3,a3,2036 # ffffffffc0207f20 <commands+0x1580>
ffffffffc0203734:	00003617          	auipc	a2,0x3
ffffffffc0203738:	67c60613          	addi	a2,a2,1660 # ffffffffc0206db0 <commands+0x410>
ffffffffc020373c:	04900593          	li	a1,73
ffffffffc0203740:	00004517          	auipc	a0,0x4
ffffffffc0203744:	4a050513          	addi	a0,a0,1184 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203748:	ac1fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(n > 0);
ffffffffc020374c:	00004697          	auipc	a3,0x4
ffffffffc0203750:	7a468693          	addi	a3,a3,1956 # ffffffffc0207ef0 <commands+0x1550>
ffffffffc0203754:	00003617          	auipc	a2,0x3
ffffffffc0203758:	65c60613          	addi	a2,a2,1628 # ffffffffc0206db0 <commands+0x410>
ffffffffc020375c:	04600593          	li	a1,70
ffffffffc0203760:	00004517          	auipc	a0,0x4
ffffffffc0203764:	48050513          	addi	a0,a0,1152 # ffffffffc0207be0 <commands+0x1240>
ffffffffc0203768:	aa1fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020376c <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc020376c:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc020376e:	00004617          	auipc	a2,0x4
ffffffffc0203772:	9f260613          	addi	a2,a2,-1550 # ffffffffc0207160 <commands+0x7c0>
ffffffffc0203776:	06200593          	li	a1,98
ffffffffc020377a:	00004517          	auipc	a0,0x4
ffffffffc020377e:	9d650513          	addi	a0,a0,-1578 # ffffffffc0207150 <commands+0x7b0>
pa2page(uintptr_t pa) {
ffffffffc0203782:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0203784:	a85fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203788 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc0203788:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc020378a:	00004617          	auipc	a2,0x4
ffffffffc020378e:	99e60613          	addi	a2,a2,-1634 # ffffffffc0207128 <commands+0x788>
ffffffffc0203792:	07400593          	li	a1,116
ffffffffc0203796:	00004517          	auipc	a0,0x4
ffffffffc020379a:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0207150 <commands+0x7b0>
pte2page(pte_t pte) {
ffffffffc020379e:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02037a0:	a69fc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02037a4 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02037a4:	7139                	addi	sp,sp,-64
ffffffffc02037a6:	f426                	sd	s1,40(sp)
ffffffffc02037a8:	f04a                	sd	s2,32(sp)
ffffffffc02037aa:	ec4e                	sd	s3,24(sp)
ffffffffc02037ac:	e852                	sd	s4,16(sp)
ffffffffc02037ae:	e456                	sd	s5,8(sp)
ffffffffc02037b0:	e05a                	sd	s6,0(sp)
ffffffffc02037b2:	fc06                	sd	ra,56(sp)
ffffffffc02037b4:	f822                	sd	s0,48(sp)
ffffffffc02037b6:	84aa                	mv	s1,a0
ffffffffc02037b8:	000af917          	auipc	s2,0xaf
ffffffffc02037bc:	07890913          	addi	s2,s2,120 # ffffffffc02b2830 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02037c0:	4a05                	li	s4,1
ffffffffc02037c2:	000afa97          	auipc	s5,0xaf
ffffffffc02037c6:	046a8a93          	addi	s5,s5,70 # ffffffffc02b2808 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02037ca:	0005099b          	sext.w	s3,a0
ffffffffc02037ce:	000afb17          	auipc	s6,0xaf
ffffffffc02037d2:	012b0b13          	addi	s6,s6,18 # ffffffffc02b27e0 <check_mm_struct>
ffffffffc02037d6:	a01d                	j	ffffffffc02037fc <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc02037d8:	00093783          	ld	a5,0(s2)
ffffffffc02037dc:	6f9c                	ld	a5,24(a5)
ffffffffc02037de:	9782                	jalr	a5
ffffffffc02037e0:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc02037e2:	4601                	li	a2,0
ffffffffc02037e4:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02037e6:	ec0d                	bnez	s0,ffffffffc0203820 <alloc_pages+0x7c>
ffffffffc02037e8:	029a6c63          	bltu	s4,s1,ffffffffc0203820 <alloc_pages+0x7c>
ffffffffc02037ec:	000aa783          	lw	a5,0(s5)
ffffffffc02037f0:	2781                	sext.w	a5,a5
ffffffffc02037f2:	c79d                	beqz	a5,ffffffffc0203820 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc02037f4:	000b3503          	ld	a0,0(s6)
ffffffffc02037f8:	b38ff0ef          	jal	ra,ffffffffc0202b30 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02037fc:	100027f3          	csrr	a5,sstatus
ffffffffc0203800:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0203802:	8526                	mv	a0,s1
ffffffffc0203804:	dbf1                	beqz	a5,ffffffffc02037d8 <alloc_pages+0x34>
        intr_disable();
ffffffffc0203806:	e43fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc020380a:	00093783          	ld	a5,0(s2)
ffffffffc020380e:	8526                	mv	a0,s1
ffffffffc0203810:	6f9c                	ld	a5,24(a5)
ffffffffc0203812:	9782                	jalr	a5
ffffffffc0203814:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203816:	e2dfc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc020381a:	4601                	li	a2,0
ffffffffc020381c:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020381e:	d469                	beqz	s0,ffffffffc02037e8 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0203820:	70e2                	ld	ra,56(sp)
ffffffffc0203822:	8522                	mv	a0,s0
ffffffffc0203824:	7442                	ld	s0,48(sp)
ffffffffc0203826:	74a2                	ld	s1,40(sp)
ffffffffc0203828:	7902                	ld	s2,32(sp)
ffffffffc020382a:	69e2                	ld	s3,24(sp)
ffffffffc020382c:	6a42                	ld	s4,16(sp)
ffffffffc020382e:	6aa2                	ld	s5,8(sp)
ffffffffc0203830:	6b02                	ld	s6,0(sp)
ffffffffc0203832:	6121                	addi	sp,sp,64
ffffffffc0203834:	8082                	ret

ffffffffc0203836 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203836:	100027f3          	csrr	a5,sstatus
ffffffffc020383a:	8b89                	andi	a5,a5,2
ffffffffc020383c:	e799                	bnez	a5,ffffffffc020384a <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc020383e:	000af797          	auipc	a5,0xaf
ffffffffc0203842:	ff27b783          	ld	a5,-14(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0203846:	739c                	ld	a5,32(a5)
ffffffffc0203848:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc020384a:	1101                	addi	sp,sp,-32
ffffffffc020384c:	ec06                	sd	ra,24(sp)
ffffffffc020384e:	e822                	sd	s0,16(sp)
ffffffffc0203850:	e426                	sd	s1,8(sp)
ffffffffc0203852:	842a                	mv	s0,a0
ffffffffc0203854:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0203856:	df3fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020385a:	000af797          	auipc	a5,0xaf
ffffffffc020385e:	fd67b783          	ld	a5,-42(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0203862:	739c                	ld	a5,32(a5)
ffffffffc0203864:	85a6                	mv	a1,s1
ffffffffc0203866:	8522                	mv	a0,s0
ffffffffc0203868:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020386a:	6442                	ld	s0,16(sp)
ffffffffc020386c:	60e2                	ld	ra,24(sp)
ffffffffc020386e:	64a2                	ld	s1,8(sp)
ffffffffc0203870:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203872:	dd1fc06f          	j	ffffffffc0200642 <intr_enable>

ffffffffc0203876 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203876:	100027f3          	csrr	a5,sstatus
ffffffffc020387a:	8b89                	andi	a5,a5,2
ffffffffc020387c:	e799                	bnez	a5,ffffffffc020388a <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020387e:	000af797          	auipc	a5,0xaf
ffffffffc0203882:	fb27b783          	ld	a5,-78(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0203886:	779c                	ld	a5,40(a5)
ffffffffc0203888:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc020388a:	1141                	addi	sp,sp,-16
ffffffffc020388c:	e406                	sd	ra,8(sp)
ffffffffc020388e:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0203890:	db9fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203894:	000af797          	auipc	a5,0xaf
ffffffffc0203898:	f9c7b783          	ld	a5,-100(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc020389c:	779c                	ld	a5,40(a5)
ffffffffc020389e:	9782                	jalr	a5
ffffffffc02038a0:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02038a2:	da1fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02038a6:	60a2                	ld	ra,8(sp)
ffffffffc02038a8:	8522                	mv	a0,s0
ffffffffc02038aa:	6402                	ld	s0,0(sp)
ffffffffc02038ac:	0141                	addi	sp,sp,16
ffffffffc02038ae:	8082                	ret

ffffffffc02038b0 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02038b0:	01e5d793          	srli	a5,a1,0x1e
ffffffffc02038b4:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02038b8:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02038ba:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02038bc:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02038be:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc02038c2:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02038c4:	f04a                	sd	s2,32(sp)
ffffffffc02038c6:	ec4e                	sd	s3,24(sp)
ffffffffc02038c8:	e852                	sd	s4,16(sp)
ffffffffc02038ca:	fc06                	sd	ra,56(sp)
ffffffffc02038cc:	f822                	sd	s0,48(sp)
ffffffffc02038ce:	e456                	sd	s5,8(sp)
ffffffffc02038d0:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02038d2:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02038d6:	892e                	mv	s2,a1
ffffffffc02038d8:	89b2                	mv	s3,a2
ffffffffc02038da:	000afa17          	auipc	s4,0xaf
ffffffffc02038de:	f46a0a13          	addi	s4,s4,-186 # ffffffffc02b2820 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc02038e2:	e7b5                	bnez	a5,ffffffffc020394e <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02038e4:	12060b63          	beqz	a2,ffffffffc0203a1a <get_pte+0x16a>
ffffffffc02038e8:	4505                	li	a0,1
ffffffffc02038ea:	ebbff0ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc02038ee:	842a                	mv	s0,a0
ffffffffc02038f0:	12050563          	beqz	a0,ffffffffc0203a1a <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc02038f4:	000afb17          	auipc	s6,0xaf
ffffffffc02038f8:	f34b0b13          	addi	s6,s6,-204 # ffffffffc02b2828 <pages>
ffffffffc02038fc:	000b3503          	ld	a0,0(s6)
ffffffffc0203900:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203904:	000afa17          	auipc	s4,0xaf
ffffffffc0203908:	f1ca0a13          	addi	s4,s4,-228 # ffffffffc02b2820 <npage>
ffffffffc020390c:	40a40533          	sub	a0,s0,a0
ffffffffc0203910:	8519                	srai	a0,a0,0x6
ffffffffc0203912:	9556                	add	a0,a0,s5
ffffffffc0203914:	000a3703          	ld	a4,0(s4)
ffffffffc0203918:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc020391c:	4685                	li	a3,1
ffffffffc020391e:	c014                	sw	a3,0(s0)
ffffffffc0203920:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203922:	0532                	slli	a0,a0,0xc
ffffffffc0203924:	14e7f263          	bgeu	a5,a4,ffffffffc0203a68 <get_pte+0x1b8>
ffffffffc0203928:	000af797          	auipc	a5,0xaf
ffffffffc020392c:	f107b783          	ld	a5,-240(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0203930:	6605                	lui	a2,0x1
ffffffffc0203932:	4581                	li	a1,0
ffffffffc0203934:	953e                	add	a0,a0,a5
ffffffffc0203936:	193020ef          	jal	ra,ffffffffc02062c8 <memset>
    return page - pages + nbase;
ffffffffc020393a:	000b3683          	ld	a3,0(s6)
ffffffffc020393e:	40d406b3          	sub	a3,s0,a3
ffffffffc0203942:	8699                	srai	a3,a3,0x6
ffffffffc0203944:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203946:	06aa                	slli	a3,a3,0xa
ffffffffc0203948:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020394c:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020394e:	77fd                	lui	a5,0xfffff
ffffffffc0203950:	068a                	slli	a3,a3,0x2
ffffffffc0203952:	000a3703          	ld	a4,0(s4)
ffffffffc0203956:	8efd                	and	a3,a3,a5
ffffffffc0203958:	00c6d793          	srli	a5,a3,0xc
ffffffffc020395c:	0ce7f163          	bgeu	a5,a4,ffffffffc0203a1e <get_pte+0x16e>
ffffffffc0203960:	000afa97          	auipc	s5,0xaf
ffffffffc0203964:	ed8a8a93          	addi	s5,s5,-296 # ffffffffc02b2838 <va_pa_offset>
ffffffffc0203968:	000ab403          	ld	s0,0(s5)
ffffffffc020396c:	01595793          	srli	a5,s2,0x15
ffffffffc0203970:	1ff7f793          	andi	a5,a5,511
ffffffffc0203974:	96a2                	add	a3,a3,s0
ffffffffc0203976:	00379413          	slli	s0,a5,0x3
ffffffffc020397a:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc020397c:	6014                	ld	a3,0(s0)
ffffffffc020397e:	0016f793          	andi	a5,a3,1
ffffffffc0203982:	e3ad                	bnez	a5,ffffffffc02039e4 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0203984:	08098b63          	beqz	s3,ffffffffc0203a1a <get_pte+0x16a>
ffffffffc0203988:	4505                	li	a0,1
ffffffffc020398a:	e1bff0ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc020398e:	84aa                	mv	s1,a0
ffffffffc0203990:	c549                	beqz	a0,ffffffffc0203a1a <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0203992:	000afb17          	auipc	s6,0xaf
ffffffffc0203996:	e96b0b13          	addi	s6,s6,-362 # ffffffffc02b2828 <pages>
ffffffffc020399a:	000b3503          	ld	a0,0(s6)
ffffffffc020399e:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02039a2:	000a3703          	ld	a4,0(s4)
ffffffffc02039a6:	40a48533          	sub	a0,s1,a0
ffffffffc02039aa:	8519                	srai	a0,a0,0x6
ffffffffc02039ac:	954e                	add	a0,a0,s3
ffffffffc02039ae:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc02039b2:	4685                	li	a3,1
ffffffffc02039b4:	c094                	sw	a3,0(s1)
ffffffffc02039b6:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02039b8:	0532                	slli	a0,a0,0xc
ffffffffc02039ba:	08e7fa63          	bgeu	a5,a4,ffffffffc0203a4e <get_pte+0x19e>
ffffffffc02039be:	000ab783          	ld	a5,0(s5)
ffffffffc02039c2:	6605                	lui	a2,0x1
ffffffffc02039c4:	4581                	li	a1,0
ffffffffc02039c6:	953e                	add	a0,a0,a5
ffffffffc02039c8:	101020ef          	jal	ra,ffffffffc02062c8 <memset>
    return page - pages + nbase;
ffffffffc02039cc:	000b3683          	ld	a3,0(s6)
ffffffffc02039d0:	40d486b3          	sub	a3,s1,a3
ffffffffc02039d4:	8699                	srai	a3,a3,0x6
ffffffffc02039d6:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02039d8:	06aa                	slli	a3,a3,0xa
ffffffffc02039da:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02039de:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02039e0:	000a3703          	ld	a4,0(s4)
ffffffffc02039e4:	068a                	slli	a3,a3,0x2
ffffffffc02039e6:	757d                	lui	a0,0xfffff
ffffffffc02039e8:	8ee9                	and	a3,a3,a0
ffffffffc02039ea:	00c6d793          	srli	a5,a3,0xc
ffffffffc02039ee:	04e7f463          	bgeu	a5,a4,ffffffffc0203a36 <get_pte+0x186>
ffffffffc02039f2:	000ab503          	ld	a0,0(s5)
ffffffffc02039f6:	00c95913          	srli	s2,s2,0xc
ffffffffc02039fa:	1ff97913          	andi	s2,s2,511
ffffffffc02039fe:	96aa                	add	a3,a3,a0
ffffffffc0203a00:	00391513          	slli	a0,s2,0x3
ffffffffc0203a04:	9536                	add	a0,a0,a3
}
ffffffffc0203a06:	70e2                	ld	ra,56(sp)
ffffffffc0203a08:	7442                	ld	s0,48(sp)
ffffffffc0203a0a:	74a2                	ld	s1,40(sp)
ffffffffc0203a0c:	7902                	ld	s2,32(sp)
ffffffffc0203a0e:	69e2                	ld	s3,24(sp)
ffffffffc0203a10:	6a42                	ld	s4,16(sp)
ffffffffc0203a12:	6aa2                	ld	s5,8(sp)
ffffffffc0203a14:	6b02                	ld	s6,0(sp)
ffffffffc0203a16:	6121                	addi	sp,sp,64
ffffffffc0203a18:	8082                	ret
            return NULL;
ffffffffc0203a1a:	4501                	li	a0,0
ffffffffc0203a1c:	b7ed                	j	ffffffffc0203a06 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0203a1e:	00003617          	auipc	a2,0x3
ffffffffc0203a22:	7ca60613          	addi	a2,a2,1994 # ffffffffc02071e8 <commands+0x848>
ffffffffc0203a26:	0e300593          	li	a1,227
ffffffffc0203a2a:	00004517          	auipc	a0,0x4
ffffffffc0203a2e:	55650513          	addi	a0,a0,1366 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0203a32:	fd6fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0203a36:	00003617          	auipc	a2,0x3
ffffffffc0203a3a:	7b260613          	addi	a2,a2,1970 # ffffffffc02071e8 <commands+0x848>
ffffffffc0203a3e:	0ee00593          	li	a1,238
ffffffffc0203a42:	00004517          	auipc	a0,0x4
ffffffffc0203a46:	53e50513          	addi	a0,a0,1342 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0203a4a:	fbefc0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203a4e:	86aa                	mv	a3,a0
ffffffffc0203a50:	00003617          	auipc	a2,0x3
ffffffffc0203a54:	79860613          	addi	a2,a2,1944 # ffffffffc02071e8 <commands+0x848>
ffffffffc0203a58:	0eb00593          	li	a1,235
ffffffffc0203a5c:	00004517          	auipc	a0,0x4
ffffffffc0203a60:	52450513          	addi	a0,a0,1316 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0203a64:	fa4fc0ef          	jal	ra,ffffffffc0200208 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203a68:	86aa                	mv	a3,a0
ffffffffc0203a6a:	00003617          	auipc	a2,0x3
ffffffffc0203a6e:	77e60613          	addi	a2,a2,1918 # ffffffffc02071e8 <commands+0x848>
ffffffffc0203a72:	0df00593          	li	a1,223
ffffffffc0203a76:	00004517          	auipc	a0,0x4
ffffffffc0203a7a:	50a50513          	addi	a0,a0,1290 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0203a7e:	f8afc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203a82 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0203a82:	1141                	addi	sp,sp,-16
ffffffffc0203a84:	e022                	sd	s0,0(sp)
ffffffffc0203a86:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203a88:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0203a8a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203a8c:	e25ff0ef          	jal	ra,ffffffffc02038b0 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0203a90:	c011                	beqz	s0,ffffffffc0203a94 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0203a92:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0203a94:	c511                	beqz	a0,ffffffffc0203aa0 <get_page+0x1e>
ffffffffc0203a96:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0203a98:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0203a9a:	0017f713          	andi	a4,a5,1
ffffffffc0203a9e:	e709                	bnez	a4,ffffffffc0203aa8 <get_page+0x26>
}
ffffffffc0203aa0:	60a2                	ld	ra,8(sp)
ffffffffc0203aa2:	6402                	ld	s0,0(sp)
ffffffffc0203aa4:	0141                	addi	sp,sp,16
ffffffffc0203aa6:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203aa8:	078a                	slli	a5,a5,0x2
ffffffffc0203aaa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203aac:	000af717          	auipc	a4,0xaf
ffffffffc0203ab0:	d7473703          	ld	a4,-652(a4) # ffffffffc02b2820 <npage>
ffffffffc0203ab4:	00e7ff63          	bgeu	a5,a4,ffffffffc0203ad2 <get_page+0x50>
ffffffffc0203ab8:	60a2                	ld	ra,8(sp)
ffffffffc0203aba:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0203abc:	fff80537          	lui	a0,0xfff80
ffffffffc0203ac0:	97aa                	add	a5,a5,a0
ffffffffc0203ac2:	079a                	slli	a5,a5,0x6
ffffffffc0203ac4:	000af517          	auipc	a0,0xaf
ffffffffc0203ac8:	d6453503          	ld	a0,-668(a0) # ffffffffc02b2828 <pages>
ffffffffc0203acc:	953e                	add	a0,a0,a5
ffffffffc0203ace:	0141                	addi	sp,sp,16
ffffffffc0203ad0:	8082                	ret
ffffffffc0203ad2:	c9bff0ef          	jal	ra,ffffffffc020376c <pa2page.part.0>

ffffffffc0203ad6 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203ad6:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203ad8:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203adc:	f486                	sd	ra,104(sp)
ffffffffc0203ade:	f0a2                	sd	s0,96(sp)
ffffffffc0203ae0:	eca6                	sd	s1,88(sp)
ffffffffc0203ae2:	e8ca                	sd	s2,80(sp)
ffffffffc0203ae4:	e4ce                	sd	s3,72(sp)
ffffffffc0203ae6:	e0d2                	sd	s4,64(sp)
ffffffffc0203ae8:	fc56                	sd	s5,56(sp)
ffffffffc0203aea:	f85a                	sd	s6,48(sp)
ffffffffc0203aec:	f45e                	sd	s7,40(sp)
ffffffffc0203aee:	f062                	sd	s8,32(sp)
ffffffffc0203af0:	ec66                	sd	s9,24(sp)
ffffffffc0203af2:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203af4:	17d2                	slli	a5,a5,0x34
ffffffffc0203af6:	e3ed                	bnez	a5,ffffffffc0203bd8 <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc0203af8:	002007b7          	lui	a5,0x200
ffffffffc0203afc:	842e                	mv	s0,a1
ffffffffc0203afe:	0ef5ed63          	bltu	a1,a5,ffffffffc0203bf8 <unmap_range+0x122>
ffffffffc0203b02:	8932                	mv	s2,a2
ffffffffc0203b04:	0ec5fa63          	bgeu	a1,a2,ffffffffc0203bf8 <unmap_range+0x122>
ffffffffc0203b08:	4785                	li	a5,1
ffffffffc0203b0a:	07fe                	slli	a5,a5,0x1f
ffffffffc0203b0c:	0ec7e663          	bltu	a5,a2,ffffffffc0203bf8 <unmap_range+0x122>
ffffffffc0203b10:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0203b12:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203b14:	000afc97          	auipc	s9,0xaf
ffffffffc0203b18:	d0cc8c93          	addi	s9,s9,-756 # ffffffffc02b2820 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b1c:	000afc17          	auipc	s8,0xaf
ffffffffc0203b20:	d0cc0c13          	addi	s8,s8,-756 # ffffffffc02b2828 <pages>
ffffffffc0203b24:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc0203b28:	000afd17          	auipc	s10,0xaf
ffffffffc0203b2c:	d08d0d13          	addi	s10,s10,-760 # ffffffffc02b2830 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203b30:	00200b37          	lui	s6,0x200
ffffffffc0203b34:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0203b38:	4601                	li	a2,0
ffffffffc0203b3a:	85a2                	mv	a1,s0
ffffffffc0203b3c:	854e                	mv	a0,s3
ffffffffc0203b3e:	d73ff0ef          	jal	ra,ffffffffc02038b0 <get_pte>
ffffffffc0203b42:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0203b44:	cd29                	beqz	a0,ffffffffc0203b9e <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc0203b46:	611c                	ld	a5,0(a0)
ffffffffc0203b48:	e395                	bnez	a5,ffffffffc0203b6c <unmap_range+0x96>
        start += PGSIZE;
ffffffffc0203b4a:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0203b4c:	ff2466e3          	bltu	s0,s2,ffffffffc0203b38 <unmap_range+0x62>
}
ffffffffc0203b50:	70a6                	ld	ra,104(sp)
ffffffffc0203b52:	7406                	ld	s0,96(sp)
ffffffffc0203b54:	64e6                	ld	s1,88(sp)
ffffffffc0203b56:	6946                	ld	s2,80(sp)
ffffffffc0203b58:	69a6                	ld	s3,72(sp)
ffffffffc0203b5a:	6a06                	ld	s4,64(sp)
ffffffffc0203b5c:	7ae2                	ld	s5,56(sp)
ffffffffc0203b5e:	7b42                	ld	s6,48(sp)
ffffffffc0203b60:	7ba2                	ld	s7,40(sp)
ffffffffc0203b62:	7c02                	ld	s8,32(sp)
ffffffffc0203b64:	6ce2                	ld	s9,24(sp)
ffffffffc0203b66:	6d42                	ld	s10,16(sp)
ffffffffc0203b68:	6165                	addi	sp,sp,112
ffffffffc0203b6a:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203b6c:	0017f713          	andi	a4,a5,1
ffffffffc0203b70:	df69                	beqz	a4,ffffffffc0203b4a <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc0203b72:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203b76:	078a                	slli	a5,a5,0x2
ffffffffc0203b78:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203b7a:	08e7ff63          	bgeu	a5,a4,ffffffffc0203c18 <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b7e:	000c3503          	ld	a0,0(s8)
ffffffffc0203b82:	97de                	add	a5,a5,s7
ffffffffc0203b84:	079a                	slli	a5,a5,0x6
ffffffffc0203b86:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0203b88:	411c                	lw	a5,0(a0)
ffffffffc0203b8a:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203b8e:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203b90:	cf11                	beqz	a4,ffffffffc0203bac <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203b92:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203b96:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0203b9a:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0203b9c:	bf45                	j	ffffffffc0203b4c <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203b9e:	945a                	add	s0,s0,s6
ffffffffc0203ba0:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0203ba4:	d455                	beqz	s0,ffffffffc0203b50 <unmap_range+0x7a>
ffffffffc0203ba6:	f92469e3          	bltu	s0,s2,ffffffffc0203b38 <unmap_range+0x62>
ffffffffc0203baa:	b75d                	j	ffffffffc0203b50 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203bac:	100027f3          	csrr	a5,sstatus
ffffffffc0203bb0:	8b89                	andi	a5,a5,2
ffffffffc0203bb2:	e799                	bnez	a5,ffffffffc0203bc0 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc0203bb4:	000d3783          	ld	a5,0(s10)
ffffffffc0203bb8:	4585                	li	a1,1
ffffffffc0203bba:	739c                	ld	a5,32(a5)
ffffffffc0203bbc:	9782                	jalr	a5
    if (flag) {
ffffffffc0203bbe:	bfd1                	j	ffffffffc0203b92 <unmap_range+0xbc>
ffffffffc0203bc0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203bc2:	a87fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0203bc6:	000d3783          	ld	a5,0(s10)
ffffffffc0203bca:	6522                	ld	a0,8(sp)
ffffffffc0203bcc:	4585                	li	a1,1
ffffffffc0203bce:	739c                	ld	a5,32(a5)
ffffffffc0203bd0:	9782                	jalr	a5
        intr_enable();
ffffffffc0203bd2:	a71fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203bd6:	bf75                	j	ffffffffc0203b92 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203bd8:	00003697          	auipc	a3,0x3
ffffffffc0203bdc:	4f868693          	addi	a3,a3,1272 # ffffffffc02070d0 <commands+0x730>
ffffffffc0203be0:	00003617          	auipc	a2,0x3
ffffffffc0203be4:	1d060613          	addi	a2,a2,464 # ffffffffc0206db0 <commands+0x410>
ffffffffc0203be8:	10f00593          	li	a1,271
ffffffffc0203bec:	00004517          	auipc	a0,0x4
ffffffffc0203bf0:	39450513          	addi	a0,a0,916 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0203bf4:	e14fc0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203bf8:	00003697          	auipc	a3,0x3
ffffffffc0203bfc:	51868693          	addi	a3,a3,1304 # ffffffffc0207110 <commands+0x770>
ffffffffc0203c00:	00003617          	auipc	a2,0x3
ffffffffc0203c04:	1b060613          	addi	a2,a2,432 # ffffffffc0206db0 <commands+0x410>
ffffffffc0203c08:	11000593          	li	a1,272
ffffffffc0203c0c:	00004517          	auipc	a0,0x4
ffffffffc0203c10:	37450513          	addi	a0,a0,884 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0203c14:	df4fc0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0203c18:	b55ff0ef          	jal	ra,ffffffffc020376c <pa2page.part.0>

ffffffffc0203c1c <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203c1c:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203c1e:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203c22:	fc86                	sd	ra,120(sp)
ffffffffc0203c24:	f8a2                	sd	s0,112(sp)
ffffffffc0203c26:	f4a6                	sd	s1,104(sp)
ffffffffc0203c28:	f0ca                	sd	s2,96(sp)
ffffffffc0203c2a:	ecce                	sd	s3,88(sp)
ffffffffc0203c2c:	e8d2                	sd	s4,80(sp)
ffffffffc0203c2e:	e4d6                	sd	s5,72(sp)
ffffffffc0203c30:	e0da                	sd	s6,64(sp)
ffffffffc0203c32:	fc5e                	sd	s7,56(sp)
ffffffffc0203c34:	f862                	sd	s8,48(sp)
ffffffffc0203c36:	f466                	sd	s9,40(sp)
ffffffffc0203c38:	f06a                	sd	s10,32(sp)
ffffffffc0203c3a:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203c3c:	17d2                	slli	a5,a5,0x34
ffffffffc0203c3e:	20079a63          	bnez	a5,ffffffffc0203e52 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc0203c42:	002007b7          	lui	a5,0x200
ffffffffc0203c46:	24f5e463          	bltu	a1,a5,ffffffffc0203e8e <exit_range+0x272>
ffffffffc0203c4a:	8ab2                	mv	s5,a2
ffffffffc0203c4c:	24c5f163          	bgeu	a1,a2,ffffffffc0203e8e <exit_range+0x272>
ffffffffc0203c50:	4785                	li	a5,1
ffffffffc0203c52:	07fe                	slli	a5,a5,0x1f
ffffffffc0203c54:	22c7ed63          	bltu	a5,a2,ffffffffc0203e8e <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0203c58:	c00009b7          	lui	s3,0xc0000
ffffffffc0203c5c:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0203c60:	ffe00937          	lui	s2,0xffe00
ffffffffc0203c64:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc0203c68:	5cfd                	li	s9,-1
ffffffffc0203c6a:	8c2a                	mv	s8,a0
ffffffffc0203c6c:	0125f933          	and	s2,a1,s2
ffffffffc0203c70:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc0203c72:	000afd17          	auipc	s10,0xaf
ffffffffc0203c76:	baed0d13          	addi	s10,s10,-1106 # ffffffffc02b2820 <npage>
    return KADDR(page2pa(page));
ffffffffc0203c7a:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0203c7e:	000af717          	auipc	a4,0xaf
ffffffffc0203c82:	baa70713          	addi	a4,a4,-1110 # ffffffffc02b2828 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc0203c86:	000afd97          	auipc	s11,0xaf
ffffffffc0203c8a:	baad8d93          	addi	s11,s11,-1110 # ffffffffc02b2830 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0203c8e:	c0000437          	lui	s0,0xc0000
ffffffffc0203c92:	944e                	add	s0,s0,s3
ffffffffc0203c94:	8079                	srli	s0,s0,0x1e
ffffffffc0203c96:	1ff47413          	andi	s0,s0,511
ffffffffc0203c9a:	040e                	slli	s0,s0,0x3
ffffffffc0203c9c:	9462                	add	s0,s0,s8
ffffffffc0203c9e:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ee0>
        if (pde1&PTE_V){
ffffffffc0203ca2:	001a7793          	andi	a5,s4,1
ffffffffc0203ca6:	eb99                	bnez	a5,ffffffffc0203cbc <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc0203ca8:	12098463          	beqz	s3,ffffffffc0203dd0 <exit_range+0x1b4>
ffffffffc0203cac:	400007b7          	lui	a5,0x40000
ffffffffc0203cb0:	97ce                	add	a5,a5,s3
ffffffffc0203cb2:	894e                	mv	s2,s3
ffffffffc0203cb4:	1159fe63          	bgeu	s3,s5,ffffffffc0203dd0 <exit_range+0x1b4>
ffffffffc0203cb8:	89be                	mv	s3,a5
ffffffffc0203cba:	bfd1                	j	ffffffffc0203c8e <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc0203cbc:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203cc0:	0a0a                	slli	s4,s4,0x2
ffffffffc0203cc2:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203cc6:	1cfa7263          	bgeu	s4,a5,ffffffffc0203e8a <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203cca:	fff80637          	lui	a2,0xfff80
ffffffffc0203cce:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc0203cd0:	000806b7          	lui	a3,0x80
ffffffffc0203cd4:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0203cd6:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0203cda:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203cdc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203cde:	18f5fa63          	bgeu	a1,a5,ffffffffc0203e72 <exit_range+0x256>
ffffffffc0203ce2:	000af817          	auipc	a6,0xaf
ffffffffc0203ce6:	b5680813          	addi	a6,a6,-1194 # ffffffffc02b2838 <va_pa_offset>
ffffffffc0203cea:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc0203cee:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0203cf0:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0203cf4:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc0203cf6:	00080337          	lui	t1,0x80
ffffffffc0203cfa:	6885                	lui	a7,0x1
ffffffffc0203cfc:	a819                	j	ffffffffc0203d12 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc0203cfe:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc0203d00:	002007b7          	lui	a5,0x200
ffffffffc0203d04:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0203d06:	08090c63          	beqz	s2,ffffffffc0203d9e <exit_range+0x182>
ffffffffc0203d0a:	09397a63          	bgeu	s2,s3,ffffffffc0203d9e <exit_range+0x182>
ffffffffc0203d0e:	0f597063          	bgeu	s2,s5,ffffffffc0203dee <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0203d12:	01595493          	srli	s1,s2,0x15
ffffffffc0203d16:	1ff4f493          	andi	s1,s1,511
ffffffffc0203d1a:	048e                	slli	s1,s1,0x3
ffffffffc0203d1c:	94da                	add	s1,s1,s6
ffffffffc0203d1e:	609c                	ld	a5,0(s1)
                if (pde0&PTE_V) {
ffffffffc0203d20:	0017f693          	andi	a3,a5,1
ffffffffc0203d24:	dee9                	beqz	a3,ffffffffc0203cfe <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc0203d26:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203d2a:	078a                	slli	a5,a5,0x2
ffffffffc0203d2c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203d2e:	14b7fe63          	bgeu	a5,a1,ffffffffc0203e8a <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d32:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc0203d34:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc0203d38:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0203d3c:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d40:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203d42:	12bef863          	bgeu	t4,a1,ffffffffc0203e72 <exit_range+0x256>
ffffffffc0203d46:	00083783          	ld	a5,0(a6)
ffffffffc0203d4a:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0203d4c:	011685b3          	add	a1,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc0203d50:	629c                	ld	a5,0(a3)
ffffffffc0203d52:	8b85                	andi	a5,a5,1
ffffffffc0203d54:	f7d5                	bnez	a5,ffffffffc0203d00 <exit_range+0xe4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0203d56:	06a1                	addi	a3,a3,8
ffffffffc0203d58:	fed59ce3          	bne	a1,a3,ffffffffc0203d50 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d5c:	631c                	ld	a5,0(a4)
ffffffffc0203d5e:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203d60:	100027f3          	csrr	a5,sstatus
ffffffffc0203d64:	8b89                	andi	a5,a5,2
ffffffffc0203d66:	e7d9                	bnez	a5,ffffffffc0203df4 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc0203d68:	000db783          	ld	a5,0(s11)
ffffffffc0203d6c:	4585                	li	a1,1
ffffffffc0203d6e:	e032                	sd	a2,0(sp)
ffffffffc0203d70:	739c                	ld	a5,32(a5)
ffffffffc0203d72:	9782                	jalr	a5
    if (flag) {
ffffffffc0203d74:	6602                	ld	a2,0(sp)
ffffffffc0203d76:	000af817          	auipc	a6,0xaf
ffffffffc0203d7a:	ac280813          	addi	a6,a6,-1342 # ffffffffc02b2838 <va_pa_offset>
ffffffffc0203d7e:	fff80e37          	lui	t3,0xfff80
ffffffffc0203d82:	00080337          	lui	t1,0x80
ffffffffc0203d86:	6885                	lui	a7,0x1
ffffffffc0203d88:	000af717          	auipc	a4,0xaf
ffffffffc0203d8c:	aa070713          	addi	a4,a4,-1376 # ffffffffc02b2828 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0203d90:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc0203d94:	002007b7          	lui	a5,0x200
ffffffffc0203d98:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0203d9a:	f60918e3          	bnez	s2,ffffffffc0203d0a <exit_range+0xee>
            if (free_pd0) {
ffffffffc0203d9e:	f00b85e3          	beqz	s7,ffffffffc0203ca8 <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc0203da2:	000d3783          	ld	a5,0(s10)
ffffffffc0203da6:	0efa7263          	bgeu	s4,a5,ffffffffc0203e8a <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203daa:	6308                	ld	a0,0(a4)
ffffffffc0203dac:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203dae:	100027f3          	csrr	a5,sstatus
ffffffffc0203db2:	8b89                	andi	a5,a5,2
ffffffffc0203db4:	efad                	bnez	a5,ffffffffc0203e2e <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc0203db6:	000db783          	ld	a5,0(s11)
ffffffffc0203dba:	4585                	li	a1,1
ffffffffc0203dbc:	739c                	ld	a5,32(a5)
ffffffffc0203dbe:	9782                	jalr	a5
ffffffffc0203dc0:	000af717          	auipc	a4,0xaf
ffffffffc0203dc4:	a6870713          	addi	a4,a4,-1432 # ffffffffc02b2828 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0203dc8:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc0203dcc:	ee0990e3          	bnez	s3,ffffffffc0203cac <exit_range+0x90>
}
ffffffffc0203dd0:	70e6                	ld	ra,120(sp)
ffffffffc0203dd2:	7446                	ld	s0,112(sp)
ffffffffc0203dd4:	74a6                	ld	s1,104(sp)
ffffffffc0203dd6:	7906                	ld	s2,96(sp)
ffffffffc0203dd8:	69e6                	ld	s3,88(sp)
ffffffffc0203dda:	6a46                	ld	s4,80(sp)
ffffffffc0203ddc:	6aa6                	ld	s5,72(sp)
ffffffffc0203dde:	6b06                	ld	s6,64(sp)
ffffffffc0203de0:	7be2                	ld	s7,56(sp)
ffffffffc0203de2:	7c42                	ld	s8,48(sp)
ffffffffc0203de4:	7ca2                	ld	s9,40(sp)
ffffffffc0203de6:	7d02                	ld	s10,32(sp)
ffffffffc0203de8:	6de2                	ld	s11,24(sp)
ffffffffc0203dea:	6109                	addi	sp,sp,128
ffffffffc0203dec:	8082                	ret
            if (free_pd0) {
ffffffffc0203dee:	ea0b8fe3          	beqz	s7,ffffffffc0203cac <exit_range+0x90>
ffffffffc0203df2:	bf45                	j	ffffffffc0203da2 <exit_range+0x186>
ffffffffc0203df4:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0203df6:	e42a                	sd	a0,8(sp)
ffffffffc0203df8:	851fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203dfc:	000db783          	ld	a5,0(s11)
ffffffffc0203e00:	6522                	ld	a0,8(sp)
ffffffffc0203e02:	4585                	li	a1,1
ffffffffc0203e04:	739c                	ld	a5,32(a5)
ffffffffc0203e06:	9782                	jalr	a5
        intr_enable();
ffffffffc0203e08:	83bfc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203e0c:	6602                	ld	a2,0(sp)
ffffffffc0203e0e:	000af717          	auipc	a4,0xaf
ffffffffc0203e12:	a1a70713          	addi	a4,a4,-1510 # ffffffffc02b2828 <pages>
ffffffffc0203e16:	6885                	lui	a7,0x1
ffffffffc0203e18:	00080337          	lui	t1,0x80
ffffffffc0203e1c:	fff80e37          	lui	t3,0xfff80
ffffffffc0203e20:	000af817          	auipc	a6,0xaf
ffffffffc0203e24:	a1880813          	addi	a6,a6,-1512 # ffffffffc02b2838 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0203e28:	0004b023          	sd	zero,0(s1)
ffffffffc0203e2c:	b7a5                	j	ffffffffc0203d94 <exit_range+0x178>
ffffffffc0203e2e:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0203e30:	819fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203e34:	000db783          	ld	a5,0(s11)
ffffffffc0203e38:	6502                	ld	a0,0(sp)
ffffffffc0203e3a:	4585                	li	a1,1
ffffffffc0203e3c:	739c                	ld	a5,32(a5)
ffffffffc0203e3e:	9782                	jalr	a5
        intr_enable();
ffffffffc0203e40:	803fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203e44:	000af717          	auipc	a4,0xaf
ffffffffc0203e48:	9e470713          	addi	a4,a4,-1564 # ffffffffc02b2828 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0203e4c:	00043023          	sd	zero,0(s0)
ffffffffc0203e50:	bfb5                	j	ffffffffc0203dcc <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203e52:	00003697          	auipc	a3,0x3
ffffffffc0203e56:	27e68693          	addi	a3,a3,638 # ffffffffc02070d0 <commands+0x730>
ffffffffc0203e5a:	00003617          	auipc	a2,0x3
ffffffffc0203e5e:	f5660613          	addi	a2,a2,-170 # ffffffffc0206db0 <commands+0x410>
ffffffffc0203e62:	12000593          	li	a1,288
ffffffffc0203e66:	00004517          	auipc	a0,0x4
ffffffffc0203e6a:	11a50513          	addi	a0,a0,282 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0203e6e:	b9afc0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203e72:	00003617          	auipc	a2,0x3
ffffffffc0203e76:	37660613          	addi	a2,a2,886 # ffffffffc02071e8 <commands+0x848>
ffffffffc0203e7a:	06900593          	li	a1,105
ffffffffc0203e7e:	00003517          	auipc	a0,0x3
ffffffffc0203e82:	2d250513          	addi	a0,a0,722 # ffffffffc0207150 <commands+0x7b0>
ffffffffc0203e86:	b82fc0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0203e8a:	8e3ff0ef          	jal	ra,ffffffffc020376c <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0203e8e:	00003697          	auipc	a3,0x3
ffffffffc0203e92:	28268693          	addi	a3,a3,642 # ffffffffc0207110 <commands+0x770>
ffffffffc0203e96:	00003617          	auipc	a2,0x3
ffffffffc0203e9a:	f1a60613          	addi	a2,a2,-230 # ffffffffc0206db0 <commands+0x410>
ffffffffc0203e9e:	12100593          	li	a1,289
ffffffffc0203ea2:	00004517          	auipc	a0,0x4
ffffffffc0203ea6:	0de50513          	addi	a0,a0,222 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0203eaa:	b5efc0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0203eae <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203eae:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203eb0:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203eb2:	ec26                	sd	s1,24(sp)
ffffffffc0203eb4:	f406                	sd	ra,40(sp)
ffffffffc0203eb6:	f022                	sd	s0,32(sp)
ffffffffc0203eb8:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203eba:	9f7ff0ef          	jal	ra,ffffffffc02038b0 <get_pte>
    if (ptep != NULL) {
ffffffffc0203ebe:	c511                	beqz	a0,ffffffffc0203eca <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203ec0:	611c                	ld	a5,0(a0)
ffffffffc0203ec2:	842a                	mv	s0,a0
ffffffffc0203ec4:	0017f713          	andi	a4,a5,1
ffffffffc0203ec8:	e711                	bnez	a4,ffffffffc0203ed4 <page_remove+0x26>
}
ffffffffc0203eca:	70a2                	ld	ra,40(sp)
ffffffffc0203ecc:	7402                	ld	s0,32(sp)
ffffffffc0203ece:	64e2                	ld	s1,24(sp)
ffffffffc0203ed0:	6145                	addi	sp,sp,48
ffffffffc0203ed2:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203ed4:	078a                	slli	a5,a5,0x2
ffffffffc0203ed6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203ed8:	000af717          	auipc	a4,0xaf
ffffffffc0203edc:	94873703          	ld	a4,-1720(a4) # ffffffffc02b2820 <npage>
ffffffffc0203ee0:	06e7f363          	bgeu	a5,a4,ffffffffc0203f46 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0203ee4:	fff80537          	lui	a0,0xfff80
ffffffffc0203ee8:	97aa                	add	a5,a5,a0
ffffffffc0203eea:	079a                	slli	a5,a5,0x6
ffffffffc0203eec:	000af517          	auipc	a0,0xaf
ffffffffc0203ef0:	93c53503          	ld	a0,-1732(a0) # ffffffffc02b2828 <pages>
ffffffffc0203ef4:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0203ef6:	411c                	lw	a5,0(a0)
ffffffffc0203ef8:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203efc:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203efe:	cb11                	beqz	a4,ffffffffc0203f12 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203f00:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203f04:	12048073          	sfence.vma	s1
}
ffffffffc0203f08:	70a2                	ld	ra,40(sp)
ffffffffc0203f0a:	7402                	ld	s0,32(sp)
ffffffffc0203f0c:	64e2                	ld	s1,24(sp)
ffffffffc0203f0e:	6145                	addi	sp,sp,48
ffffffffc0203f10:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203f12:	100027f3          	csrr	a5,sstatus
ffffffffc0203f16:	8b89                	andi	a5,a5,2
ffffffffc0203f18:	eb89                	bnez	a5,ffffffffc0203f2a <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0203f1a:	000af797          	auipc	a5,0xaf
ffffffffc0203f1e:	9167b783          	ld	a5,-1770(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0203f22:	739c                	ld	a5,32(a5)
ffffffffc0203f24:	4585                	li	a1,1
ffffffffc0203f26:	9782                	jalr	a5
    if (flag) {
ffffffffc0203f28:	bfe1                	j	ffffffffc0203f00 <page_remove+0x52>
        intr_disable();
ffffffffc0203f2a:	e42a                	sd	a0,8(sp)
ffffffffc0203f2c:	f1cfc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0203f30:	000af797          	auipc	a5,0xaf
ffffffffc0203f34:	9007b783          	ld	a5,-1792(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0203f38:	739c                	ld	a5,32(a5)
ffffffffc0203f3a:	6522                	ld	a0,8(sp)
ffffffffc0203f3c:	4585                	li	a1,1
ffffffffc0203f3e:	9782                	jalr	a5
        intr_enable();
ffffffffc0203f40:	f02fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0203f44:	bf75                	j	ffffffffc0203f00 <page_remove+0x52>
ffffffffc0203f46:	827ff0ef          	jal	ra,ffffffffc020376c <pa2page.part.0>

ffffffffc0203f4a <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203f4a:	7139                	addi	sp,sp,-64
ffffffffc0203f4c:	e852                	sd	s4,16(sp)
ffffffffc0203f4e:	8a32                	mv	s4,a2
ffffffffc0203f50:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203f52:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203f54:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203f56:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203f58:	f426                	sd	s1,40(sp)
ffffffffc0203f5a:	fc06                	sd	ra,56(sp)
ffffffffc0203f5c:	f04a                	sd	s2,32(sp)
ffffffffc0203f5e:	ec4e                	sd	s3,24(sp)
ffffffffc0203f60:	e456                	sd	s5,8(sp)
ffffffffc0203f62:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203f64:	94dff0ef          	jal	ra,ffffffffc02038b0 <get_pte>
    if (ptep == NULL) {
ffffffffc0203f68:	c961                	beqz	a0,ffffffffc0204038 <page_insert+0xee>
    page->ref += 1;
ffffffffc0203f6a:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0203f6c:	611c                	ld	a5,0(a0)
ffffffffc0203f6e:	89aa                	mv	s3,a0
ffffffffc0203f70:	0016871b          	addiw	a4,a3,1
ffffffffc0203f74:	c018                	sw	a4,0(s0)
ffffffffc0203f76:	0017f713          	andi	a4,a5,1
ffffffffc0203f7a:	ef05                	bnez	a4,ffffffffc0203fb2 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0203f7c:	000af717          	auipc	a4,0xaf
ffffffffc0203f80:	8ac73703          	ld	a4,-1876(a4) # ffffffffc02b2828 <pages>
ffffffffc0203f84:	8c19                	sub	s0,s0,a4
ffffffffc0203f86:	000807b7          	lui	a5,0x80
ffffffffc0203f8a:	8419                	srai	s0,s0,0x6
ffffffffc0203f8c:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203f8e:	042a                	slli	s0,s0,0xa
ffffffffc0203f90:	8cc1                	or	s1,s1,s0
ffffffffc0203f92:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0203f96:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ee0>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203f9a:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0203f9e:	4501                	li	a0,0
}
ffffffffc0203fa0:	70e2                	ld	ra,56(sp)
ffffffffc0203fa2:	7442                	ld	s0,48(sp)
ffffffffc0203fa4:	74a2                	ld	s1,40(sp)
ffffffffc0203fa6:	7902                	ld	s2,32(sp)
ffffffffc0203fa8:	69e2                	ld	s3,24(sp)
ffffffffc0203faa:	6a42                	ld	s4,16(sp)
ffffffffc0203fac:	6aa2                	ld	s5,8(sp)
ffffffffc0203fae:	6121                	addi	sp,sp,64
ffffffffc0203fb0:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203fb2:	078a                	slli	a5,a5,0x2
ffffffffc0203fb4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203fb6:	000af717          	auipc	a4,0xaf
ffffffffc0203fba:	86a73703          	ld	a4,-1942(a4) # ffffffffc02b2820 <npage>
ffffffffc0203fbe:	06e7ff63          	bgeu	a5,a4,ffffffffc020403c <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0203fc2:	000afa97          	auipc	s5,0xaf
ffffffffc0203fc6:	866a8a93          	addi	s5,s5,-1946 # ffffffffc02b2828 <pages>
ffffffffc0203fca:	000ab703          	ld	a4,0(s5)
ffffffffc0203fce:	fff80937          	lui	s2,0xfff80
ffffffffc0203fd2:	993e                	add	s2,s2,a5
ffffffffc0203fd4:	091a                	slli	s2,s2,0x6
ffffffffc0203fd6:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0203fd8:	01240c63          	beq	s0,s2,ffffffffc0203ff0 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0203fdc:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccd7a4>
ffffffffc0203fe0:	fff7869b          	addiw	a3,a5,-1
ffffffffc0203fe4:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0203fe8:	c691                	beqz	a3,ffffffffc0203ff4 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203fea:	120a0073          	sfence.vma	s4
}
ffffffffc0203fee:	bf59                	j	ffffffffc0203f84 <page_insert+0x3a>
ffffffffc0203ff0:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0203ff2:	bf49                	j	ffffffffc0203f84 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203ff4:	100027f3          	csrr	a5,sstatus
ffffffffc0203ff8:	8b89                	andi	a5,a5,2
ffffffffc0203ffa:	ef91                	bnez	a5,ffffffffc0204016 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0203ffc:	000af797          	auipc	a5,0xaf
ffffffffc0204000:	8347b783          	ld	a5,-1996(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0204004:	739c                	ld	a5,32(a5)
ffffffffc0204006:	4585                	li	a1,1
ffffffffc0204008:	854a                	mv	a0,s2
ffffffffc020400a:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc020400c:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0204010:	120a0073          	sfence.vma	s4
ffffffffc0204014:	bf85                	j	ffffffffc0203f84 <page_insert+0x3a>
        intr_disable();
ffffffffc0204016:	e32fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020401a:	000af797          	auipc	a5,0xaf
ffffffffc020401e:	8167b783          	ld	a5,-2026(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0204022:	739c                	ld	a5,32(a5)
ffffffffc0204024:	4585                	li	a1,1
ffffffffc0204026:	854a                	mv	a0,s2
ffffffffc0204028:	9782                	jalr	a5
        intr_enable();
ffffffffc020402a:	e18fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020402e:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0204032:	120a0073          	sfence.vma	s4
ffffffffc0204036:	b7b9                	j	ffffffffc0203f84 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0204038:	5571                	li	a0,-4
ffffffffc020403a:	b79d                	j	ffffffffc0203fa0 <page_insert+0x56>
ffffffffc020403c:	f30ff0ef          	jal	ra,ffffffffc020376c <pa2page.part.0>

ffffffffc0204040 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0204040:	00004797          	auipc	a5,0x4
ffffffffc0204044:	f0878793          	addi	a5,a5,-248 # ffffffffc0207f48 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0204048:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020404a:	711d                	addi	sp,sp,-96
ffffffffc020404c:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020404e:	00004517          	auipc	a0,0x4
ffffffffc0204052:	f4250513          	addi	a0,a0,-190 # ffffffffc0207f90 <default_pmm_manager+0x48>
    pmm_manager = &default_pmm_manager;
ffffffffc0204056:	000aeb97          	auipc	s7,0xae
ffffffffc020405a:	7dab8b93          	addi	s7,s7,2010 # ffffffffc02b2830 <pmm_manager>
void pmm_init(void) {
ffffffffc020405e:	ec86                	sd	ra,88(sp)
ffffffffc0204060:	e4a6                	sd	s1,72(sp)
ffffffffc0204062:	fc4e                	sd	s3,56(sp)
ffffffffc0204064:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0204066:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc020406a:	e8a2                	sd	s0,80(sp)
ffffffffc020406c:	e0ca                	sd	s2,64(sp)
ffffffffc020406e:	f852                	sd	s4,48(sp)
ffffffffc0204070:	f456                	sd	s5,40(sp)
ffffffffc0204072:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0204074:	858fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pmm_manager->init();
ffffffffc0204078:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020407c:	000ae997          	auipc	s3,0xae
ffffffffc0204080:	7bc98993          	addi	s3,s3,1980 # ffffffffc02b2838 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0204084:	000ae497          	auipc	s1,0xae
ffffffffc0204088:	79c48493          	addi	s1,s1,1948 # ffffffffc02b2820 <npage>
    pmm_manager->init();
ffffffffc020408c:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020408e:	000aeb17          	auipc	s6,0xae
ffffffffc0204092:	79ab0b13          	addi	s6,s6,1946 # ffffffffc02b2828 <pages>
    pmm_manager->init();
ffffffffc0204096:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0204098:	57f5                	li	a5,-3
ffffffffc020409a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020409c:	00004517          	auipc	a0,0x4
ffffffffc02040a0:	f0c50513          	addi	a0,a0,-244 # ffffffffc0207fa8 <default_pmm_manager+0x60>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02040a4:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc02040a8:	824fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02040ac:	46c5                	li	a3,17
ffffffffc02040ae:	06ee                	slli	a3,a3,0x1b
ffffffffc02040b0:	40100613          	li	a2,1025
ffffffffc02040b4:	07e005b7          	lui	a1,0x7e00
ffffffffc02040b8:	16fd                	addi	a3,a3,-1
ffffffffc02040ba:	0656                	slli	a2,a2,0x15
ffffffffc02040bc:	00004517          	auipc	a0,0x4
ffffffffc02040c0:	f0450513          	addi	a0,a0,-252 # ffffffffc0207fc0 <default_pmm_manager+0x78>
ffffffffc02040c4:	808fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02040c8:	777d                	lui	a4,0xfffff
ffffffffc02040ca:	000af797          	auipc	a5,0xaf
ffffffffc02040ce:	79178793          	addi	a5,a5,1937 # ffffffffc02b385b <end+0xfff>
ffffffffc02040d2:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02040d4:	00088737          	lui	a4,0x88
ffffffffc02040d8:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02040da:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02040de:	4701                	li	a4,0
ffffffffc02040e0:	4585                	li	a1,1
ffffffffc02040e2:	fff80837          	lui	a6,0xfff80
ffffffffc02040e6:	a019                	j	ffffffffc02040ec <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc02040e8:	000b3783          	ld	a5,0(s6)
ffffffffc02040ec:	00671693          	slli	a3,a4,0x6
ffffffffc02040f0:	97b6                	add	a5,a5,a3
ffffffffc02040f2:	07a1                	addi	a5,a5,8
ffffffffc02040f4:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02040f8:	6090                	ld	a2,0(s1)
ffffffffc02040fa:	0705                	addi	a4,a4,1
ffffffffc02040fc:	010607b3          	add	a5,a2,a6
ffffffffc0204100:	fef764e3          	bltu	a4,a5,ffffffffc02040e8 <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0204104:	000b3503          	ld	a0,0(s6)
ffffffffc0204108:	079a                	slli	a5,a5,0x6
ffffffffc020410a:	c0200737          	lui	a4,0xc0200
ffffffffc020410e:	00f506b3          	add	a3,a0,a5
ffffffffc0204112:	60e6e563          	bltu	a3,a4,ffffffffc020471c <pmm_init+0x6dc>
ffffffffc0204116:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc020411a:	4745                	li	a4,17
ffffffffc020411c:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020411e:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0204120:	4ae6e563          	bltu	a3,a4,ffffffffc02045ca <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0204124:	00004517          	auipc	a0,0x4
ffffffffc0204128:	ec450513          	addi	a0,a0,-316 # ffffffffc0207fe8 <default_pmm_manager+0xa0>
ffffffffc020412c:	fa1fb0ef          	jal	ra,ffffffffc02000cc <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0204130:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0204134:	000ae917          	auipc	s2,0xae
ffffffffc0204138:	6e490913          	addi	s2,s2,1764 # ffffffffc02b2818 <boot_pgdir>
    pmm_manager->check();
ffffffffc020413c:	7b9c                	ld	a5,48(a5)
ffffffffc020413e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0204140:	00004517          	auipc	a0,0x4
ffffffffc0204144:	ec050513          	addi	a0,a0,-320 # ffffffffc0208000 <default_pmm_manager+0xb8>
ffffffffc0204148:	f85fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020414c:	00007697          	auipc	a3,0x7
ffffffffc0204150:	eb468693          	addi	a3,a3,-332 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0204154:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0204158:	c02007b7          	lui	a5,0xc0200
ffffffffc020415c:	5cf6ec63          	bltu	a3,a5,ffffffffc0204734 <pmm_init+0x6f4>
ffffffffc0204160:	0009b783          	ld	a5,0(s3)
ffffffffc0204164:	8e9d                	sub	a3,a3,a5
ffffffffc0204166:	000ae797          	auipc	a5,0xae
ffffffffc020416a:	6ad7b523          	sd	a3,1706(a5) # ffffffffc02b2810 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020416e:	100027f3          	csrr	a5,sstatus
ffffffffc0204172:	8b89                	andi	a5,a5,2
ffffffffc0204174:	48079263          	bnez	a5,ffffffffc02045f8 <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0204178:	000bb783          	ld	a5,0(s7)
ffffffffc020417c:	779c                	ld	a5,40(a5)
ffffffffc020417e:	9782                	jalr	a5
ffffffffc0204180:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0204182:	6098                	ld	a4,0(s1)
ffffffffc0204184:	c80007b7          	lui	a5,0xc8000
ffffffffc0204188:	83b1                	srli	a5,a5,0xc
ffffffffc020418a:	5ee7e163          	bltu	a5,a4,ffffffffc020476c <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020418e:	00093503          	ld	a0,0(s2)
ffffffffc0204192:	5a050d63          	beqz	a0,ffffffffc020474c <pmm_init+0x70c>
ffffffffc0204196:	03451793          	slli	a5,a0,0x34
ffffffffc020419a:	5a079963          	bnez	a5,ffffffffc020474c <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020419e:	4601                	li	a2,0
ffffffffc02041a0:	4581                	li	a1,0
ffffffffc02041a2:	8e1ff0ef          	jal	ra,ffffffffc0203a82 <get_page>
ffffffffc02041a6:	62051563          	bnez	a0,ffffffffc02047d0 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02041aa:	4505                	li	a0,1
ffffffffc02041ac:	df8ff0ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc02041b0:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02041b2:	00093503          	ld	a0,0(s2)
ffffffffc02041b6:	4681                	li	a3,0
ffffffffc02041b8:	4601                	li	a2,0
ffffffffc02041ba:	85d2                	mv	a1,s4
ffffffffc02041bc:	d8fff0ef          	jal	ra,ffffffffc0203f4a <page_insert>
ffffffffc02041c0:	5e051863          	bnez	a0,ffffffffc02047b0 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02041c4:	00093503          	ld	a0,0(s2)
ffffffffc02041c8:	4601                	li	a2,0
ffffffffc02041ca:	4581                	li	a1,0
ffffffffc02041cc:	ee4ff0ef          	jal	ra,ffffffffc02038b0 <get_pte>
ffffffffc02041d0:	5c050063          	beqz	a0,ffffffffc0204790 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc02041d4:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02041d6:	0017f713          	andi	a4,a5,1
ffffffffc02041da:	5a070963          	beqz	a4,ffffffffc020478c <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc02041de:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02041e0:	078a                	slli	a5,a5,0x2
ffffffffc02041e2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02041e4:	52e7fa63          	bgeu	a5,a4,ffffffffc0204718 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02041e8:	000b3683          	ld	a3,0(s6)
ffffffffc02041ec:	fff80637          	lui	a2,0xfff80
ffffffffc02041f0:	97b2                	add	a5,a5,a2
ffffffffc02041f2:	079a                	slli	a5,a5,0x6
ffffffffc02041f4:	97b6                	add	a5,a5,a3
ffffffffc02041f6:	10fa16e3          	bne	s4,a5,ffffffffc0204b02 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc02041fa:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc02041fe:	4785                	li	a5,1
ffffffffc0204200:	12f69de3          	bne	a3,a5,ffffffffc0204b3a <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0204204:	00093503          	ld	a0,0(s2)
ffffffffc0204208:	77fd                	lui	a5,0xfffff
ffffffffc020420a:	6114                	ld	a3,0(a0)
ffffffffc020420c:	068a                	slli	a3,a3,0x2
ffffffffc020420e:	8efd                	and	a3,a3,a5
ffffffffc0204210:	00c6d613          	srli	a2,a3,0xc
ffffffffc0204214:	10e677e3          	bgeu	a2,a4,ffffffffc0204b22 <pmm_init+0xae2>
ffffffffc0204218:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020421c:	96e2                	add	a3,a3,s8
ffffffffc020421e:	0006ba83          	ld	s5,0(a3)
ffffffffc0204222:	0a8a                	slli	s5,s5,0x2
ffffffffc0204224:	00fafab3          	and	s5,s5,a5
ffffffffc0204228:	00cad793          	srli	a5,s5,0xc
ffffffffc020422c:	62e7f263          	bgeu	a5,a4,ffffffffc0204850 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0204230:	4601                	li	a2,0
ffffffffc0204232:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0204234:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0204236:	e7aff0ef          	jal	ra,ffffffffc02038b0 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020423a:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020423c:	5f551a63          	bne	a0,s5,ffffffffc0204830 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc0204240:	4505                	li	a0,1
ffffffffc0204242:	d62ff0ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0204246:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0204248:	00093503          	ld	a0,0(s2)
ffffffffc020424c:	46d1                	li	a3,20
ffffffffc020424e:	6605                	lui	a2,0x1
ffffffffc0204250:	85d6                	mv	a1,s5
ffffffffc0204252:	cf9ff0ef          	jal	ra,ffffffffc0203f4a <page_insert>
ffffffffc0204256:	58051d63          	bnez	a0,ffffffffc02047f0 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020425a:	00093503          	ld	a0,0(s2)
ffffffffc020425e:	4601                	li	a2,0
ffffffffc0204260:	6585                	lui	a1,0x1
ffffffffc0204262:	e4eff0ef          	jal	ra,ffffffffc02038b0 <get_pte>
ffffffffc0204266:	0e050ae3          	beqz	a0,ffffffffc0204b5a <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc020426a:	611c                	ld	a5,0(a0)
ffffffffc020426c:	0107f713          	andi	a4,a5,16
ffffffffc0204270:	6e070d63          	beqz	a4,ffffffffc020496a <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc0204274:	8b91                	andi	a5,a5,4
ffffffffc0204276:	6a078a63          	beqz	a5,ffffffffc020492a <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020427a:	00093503          	ld	a0,0(s2)
ffffffffc020427e:	611c                	ld	a5,0(a0)
ffffffffc0204280:	8bc1                	andi	a5,a5,16
ffffffffc0204282:	68078463          	beqz	a5,ffffffffc020490a <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc0204286:	000aa703          	lw	a4,0(s5)
ffffffffc020428a:	4785                	li	a5,1
ffffffffc020428c:	58f71263          	bne	a4,a5,ffffffffc0204810 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0204290:	4681                	li	a3,0
ffffffffc0204292:	6605                	lui	a2,0x1
ffffffffc0204294:	85d2                	mv	a1,s4
ffffffffc0204296:	cb5ff0ef          	jal	ra,ffffffffc0203f4a <page_insert>
ffffffffc020429a:	62051863          	bnez	a0,ffffffffc02048ca <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc020429e:	000a2703          	lw	a4,0(s4)
ffffffffc02042a2:	4789                	li	a5,2
ffffffffc02042a4:	60f71363          	bne	a4,a5,ffffffffc02048aa <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc02042a8:	000aa783          	lw	a5,0(s5)
ffffffffc02042ac:	5c079f63          	bnez	a5,ffffffffc020488a <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02042b0:	00093503          	ld	a0,0(s2)
ffffffffc02042b4:	4601                	li	a2,0
ffffffffc02042b6:	6585                	lui	a1,0x1
ffffffffc02042b8:	df8ff0ef          	jal	ra,ffffffffc02038b0 <get_pte>
ffffffffc02042bc:	5a050763          	beqz	a0,ffffffffc020486a <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc02042c0:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02042c2:	00177793          	andi	a5,a4,1
ffffffffc02042c6:	4c078363          	beqz	a5,ffffffffc020478c <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc02042ca:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02042cc:	00271793          	slli	a5,a4,0x2
ffffffffc02042d0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02042d2:	44d7f363          	bgeu	a5,a3,ffffffffc0204718 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02042d6:	000b3683          	ld	a3,0(s6)
ffffffffc02042da:	fff80637          	lui	a2,0xfff80
ffffffffc02042de:	97b2                	add	a5,a5,a2
ffffffffc02042e0:	079a                	slli	a5,a5,0x6
ffffffffc02042e2:	97b6                	add	a5,a5,a3
ffffffffc02042e4:	6efa1363          	bne	s4,a5,ffffffffc02049ca <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc02042e8:	8b41                	andi	a4,a4,16
ffffffffc02042ea:	6c071063          	bnez	a4,ffffffffc02049aa <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc02042ee:	00093503          	ld	a0,0(s2)
ffffffffc02042f2:	4581                	li	a1,0
ffffffffc02042f4:	bbbff0ef          	jal	ra,ffffffffc0203eae <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02042f8:	000a2703          	lw	a4,0(s4)
ffffffffc02042fc:	4785                	li	a5,1
ffffffffc02042fe:	68f71663          	bne	a4,a5,ffffffffc020498a <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc0204302:	000aa783          	lw	a5,0(s5)
ffffffffc0204306:	74079e63          	bnez	a5,ffffffffc0204a62 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020430a:	00093503          	ld	a0,0(s2)
ffffffffc020430e:	6585                	lui	a1,0x1
ffffffffc0204310:	b9fff0ef          	jal	ra,ffffffffc0203eae <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0204314:	000a2783          	lw	a5,0(s4)
ffffffffc0204318:	72079563          	bnez	a5,ffffffffc0204a42 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc020431c:	000aa783          	lw	a5,0(s5)
ffffffffc0204320:	70079163          	bnez	a5,ffffffffc0204a22 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0204324:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204328:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020432a:	000a3683          	ld	a3,0(s4)
ffffffffc020432e:	068a                	slli	a3,a3,0x2
ffffffffc0204330:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204332:	3ee6f363          	bgeu	a3,a4,ffffffffc0204718 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0204336:	fff807b7          	lui	a5,0xfff80
ffffffffc020433a:	000b3503          	ld	a0,0(s6)
ffffffffc020433e:	96be                	add	a3,a3,a5
ffffffffc0204340:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0204342:	00d507b3          	add	a5,a0,a3
ffffffffc0204346:	4390                	lw	a2,0(a5)
ffffffffc0204348:	4785                	li	a5,1
ffffffffc020434a:	6af61c63          	bne	a2,a5,ffffffffc0204a02 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc020434e:	8699                	srai	a3,a3,0x6
ffffffffc0204350:	000805b7          	lui	a1,0x80
ffffffffc0204354:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0204356:	00c69613          	slli	a2,a3,0xc
ffffffffc020435a:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020435c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020435e:	68e67663          	bgeu	a2,a4,ffffffffc02049ea <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0204362:	0009b603          	ld	a2,0(s3)
ffffffffc0204366:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc0204368:	629c                	ld	a5,0(a3)
ffffffffc020436a:	078a                	slli	a5,a5,0x2
ffffffffc020436c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020436e:	3ae7f563          	bgeu	a5,a4,ffffffffc0204718 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0204372:	8f8d                	sub	a5,a5,a1
ffffffffc0204374:	079a                	slli	a5,a5,0x6
ffffffffc0204376:	953e                	add	a0,a0,a5
ffffffffc0204378:	100027f3          	csrr	a5,sstatus
ffffffffc020437c:	8b89                	andi	a5,a5,2
ffffffffc020437e:	2c079763          	bnez	a5,ffffffffc020464c <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc0204382:	000bb783          	ld	a5,0(s7)
ffffffffc0204386:	4585                	li	a1,1
ffffffffc0204388:	739c                	ld	a5,32(a5)
ffffffffc020438a:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020438c:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0204390:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204392:	078a                	slli	a5,a5,0x2
ffffffffc0204394:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204396:	38e7f163          	bgeu	a5,a4,ffffffffc0204718 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020439a:	000b3503          	ld	a0,0(s6)
ffffffffc020439e:	fff80737          	lui	a4,0xfff80
ffffffffc02043a2:	97ba                	add	a5,a5,a4
ffffffffc02043a4:	079a                	slli	a5,a5,0x6
ffffffffc02043a6:	953e                	add	a0,a0,a5
ffffffffc02043a8:	100027f3          	csrr	a5,sstatus
ffffffffc02043ac:	8b89                	andi	a5,a5,2
ffffffffc02043ae:	28079363          	bnez	a5,ffffffffc0204634 <pmm_init+0x5f4>
ffffffffc02043b2:	000bb783          	ld	a5,0(s7)
ffffffffc02043b6:	4585                	li	a1,1
ffffffffc02043b8:	739c                	ld	a5,32(a5)
ffffffffc02043ba:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02043bc:	00093783          	ld	a5,0(s2)
ffffffffc02043c0:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fccd7a4>
  asm volatile("sfence.vma");
ffffffffc02043c4:	12000073          	sfence.vma
ffffffffc02043c8:	100027f3          	csrr	a5,sstatus
ffffffffc02043cc:	8b89                	andi	a5,a5,2
ffffffffc02043ce:	24079963          	bnez	a5,ffffffffc0204620 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc02043d2:	000bb783          	ld	a5,0(s7)
ffffffffc02043d6:	779c                	ld	a5,40(a5)
ffffffffc02043d8:	9782                	jalr	a5
ffffffffc02043da:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02043dc:	71441363          	bne	s0,s4,ffffffffc0204ae2 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02043e0:	00004517          	auipc	a0,0x4
ffffffffc02043e4:	f0850513          	addi	a0,a0,-248 # ffffffffc02082e8 <default_pmm_manager+0x3a0>
ffffffffc02043e8:	ce5fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc02043ec:	100027f3          	csrr	a5,sstatus
ffffffffc02043f0:	8b89                	andi	a5,a5,2
ffffffffc02043f2:	20079d63          	bnez	a5,ffffffffc020460c <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc02043f6:	000bb783          	ld	a5,0(s7)
ffffffffc02043fa:	779c                	ld	a5,40(a5)
ffffffffc02043fc:	9782                	jalr	a5
ffffffffc02043fe:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0204400:	6098                	ld	a4,0(s1)
ffffffffc0204402:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0204406:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0204408:	00c71793          	slli	a5,a4,0xc
ffffffffc020440c:	6a05                	lui	s4,0x1
ffffffffc020440e:	02f47c63          	bgeu	s0,a5,ffffffffc0204446 <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0204412:	00c45793          	srli	a5,s0,0xc
ffffffffc0204416:	00093503          	ld	a0,0(s2)
ffffffffc020441a:	2ee7f263          	bgeu	a5,a4,ffffffffc02046fe <pmm_init+0x6be>
ffffffffc020441e:	0009b583          	ld	a1,0(s3)
ffffffffc0204422:	4601                	li	a2,0
ffffffffc0204424:	95a2                	add	a1,a1,s0
ffffffffc0204426:	c8aff0ef          	jal	ra,ffffffffc02038b0 <get_pte>
ffffffffc020442a:	2a050a63          	beqz	a0,ffffffffc02046de <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020442e:	611c                	ld	a5,0(a0)
ffffffffc0204430:	078a                	slli	a5,a5,0x2
ffffffffc0204432:	0157f7b3          	and	a5,a5,s5
ffffffffc0204436:	28879463          	bne	a5,s0,ffffffffc02046be <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020443a:	6098                	ld	a4,0(s1)
ffffffffc020443c:	9452                	add	s0,s0,s4
ffffffffc020443e:	00c71793          	slli	a5,a4,0xc
ffffffffc0204442:	fcf468e3          	bltu	s0,a5,ffffffffc0204412 <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0204446:	00093783          	ld	a5,0(s2)
ffffffffc020444a:	639c                	ld	a5,0(a5)
ffffffffc020444c:	66079b63          	bnez	a5,ffffffffc0204ac2 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc0204450:	4505                	li	a0,1
ffffffffc0204452:	b52ff0ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0204456:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0204458:	00093503          	ld	a0,0(s2)
ffffffffc020445c:	4699                	li	a3,6
ffffffffc020445e:	10000613          	li	a2,256
ffffffffc0204462:	85d6                	mv	a1,s5
ffffffffc0204464:	ae7ff0ef          	jal	ra,ffffffffc0203f4a <page_insert>
ffffffffc0204468:	62051d63          	bnez	a0,ffffffffc0204aa2 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc020446c:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd4c7a4>
ffffffffc0204470:	4785                	li	a5,1
ffffffffc0204472:	60f71863          	bne	a4,a5,ffffffffc0204a82 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0204476:	00093503          	ld	a0,0(s2)
ffffffffc020447a:	6405                	lui	s0,0x1
ffffffffc020447c:	4699                	li	a3,6
ffffffffc020447e:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ab0>
ffffffffc0204482:	85d6                	mv	a1,s5
ffffffffc0204484:	ac7ff0ef          	jal	ra,ffffffffc0203f4a <page_insert>
ffffffffc0204488:	46051163          	bnez	a0,ffffffffc02048ea <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc020448c:	000aa703          	lw	a4,0(s5)
ffffffffc0204490:	4789                	li	a5,2
ffffffffc0204492:	72f71463          	bne	a4,a5,ffffffffc0204bba <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0204496:	00004597          	auipc	a1,0x4
ffffffffc020449a:	f8a58593          	addi	a1,a1,-118 # ffffffffc0208420 <default_pmm_manager+0x4d8>
ffffffffc020449e:	10000513          	li	a0,256
ffffffffc02044a2:	5e1010ef          	jal	ra,ffffffffc0206282 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02044a6:	10040593          	addi	a1,s0,256
ffffffffc02044aa:	10000513          	li	a0,256
ffffffffc02044ae:	5e7010ef          	jal	ra,ffffffffc0206294 <strcmp>
ffffffffc02044b2:	6e051463          	bnez	a0,ffffffffc0204b9a <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc02044b6:	000b3683          	ld	a3,0(s6)
ffffffffc02044ba:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc02044be:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc02044c0:	40da86b3          	sub	a3,s5,a3
ffffffffc02044c4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02044c6:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc02044c8:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02044ca:	8031                	srli	s0,s0,0xc
ffffffffc02044cc:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc02044d0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02044d2:	50f77c63          	bgeu	a4,a5,ffffffffc02049ea <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02044d6:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02044da:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02044de:	96be                	add	a3,a3,a5
ffffffffc02044e0:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02044e4:	569010ef          	jal	ra,ffffffffc020624c <strlen>
ffffffffc02044e8:	68051963          	bnez	a0,ffffffffc0204b7a <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02044ec:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02044f0:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02044f2:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc02044f6:	068a                	slli	a3,a3,0x2
ffffffffc02044f8:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02044fa:	20f6ff63          	bgeu	a3,a5,ffffffffc0204718 <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc02044fe:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204500:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204502:	4ef47463          	bgeu	s0,a5,ffffffffc02049ea <pmm_init+0x9aa>
ffffffffc0204506:	0009b403          	ld	s0,0(s3)
ffffffffc020450a:	9436                	add	s0,s0,a3
ffffffffc020450c:	100027f3          	csrr	a5,sstatus
ffffffffc0204510:	8b89                	andi	a5,a5,2
ffffffffc0204512:	18079b63          	bnez	a5,ffffffffc02046a8 <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc0204516:	000bb783          	ld	a5,0(s7)
ffffffffc020451a:	4585                	li	a1,1
ffffffffc020451c:	8556                	mv	a0,s5
ffffffffc020451e:	739c                	ld	a5,32(a5)
ffffffffc0204520:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0204522:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0204524:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204526:	078a                	slli	a5,a5,0x2
ffffffffc0204528:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020452a:	1ee7f763          	bgeu	a5,a4,ffffffffc0204718 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020452e:	000b3503          	ld	a0,0(s6)
ffffffffc0204532:	fff80737          	lui	a4,0xfff80
ffffffffc0204536:	97ba                	add	a5,a5,a4
ffffffffc0204538:	079a                	slli	a5,a5,0x6
ffffffffc020453a:	953e                	add	a0,a0,a5
ffffffffc020453c:	100027f3          	csrr	a5,sstatus
ffffffffc0204540:	8b89                	andi	a5,a5,2
ffffffffc0204542:	14079763          	bnez	a5,ffffffffc0204690 <pmm_init+0x650>
ffffffffc0204546:	000bb783          	ld	a5,0(s7)
ffffffffc020454a:	4585                	li	a1,1
ffffffffc020454c:	739c                	ld	a5,32(a5)
ffffffffc020454e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0204550:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0204554:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204556:	078a                	slli	a5,a5,0x2
ffffffffc0204558:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020455a:	1ae7ff63          	bgeu	a5,a4,ffffffffc0204718 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020455e:	000b3503          	ld	a0,0(s6)
ffffffffc0204562:	fff80737          	lui	a4,0xfff80
ffffffffc0204566:	97ba                	add	a5,a5,a4
ffffffffc0204568:	079a                	slli	a5,a5,0x6
ffffffffc020456a:	953e                	add	a0,a0,a5
ffffffffc020456c:	100027f3          	csrr	a5,sstatus
ffffffffc0204570:	8b89                	andi	a5,a5,2
ffffffffc0204572:	10079363          	bnez	a5,ffffffffc0204678 <pmm_init+0x638>
ffffffffc0204576:	000bb783          	ld	a5,0(s7)
ffffffffc020457a:	4585                	li	a1,1
ffffffffc020457c:	739c                	ld	a5,32(a5)
ffffffffc020457e:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0204580:	00093783          	ld	a5,0(s2)
ffffffffc0204584:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0204588:	12000073          	sfence.vma
ffffffffc020458c:	100027f3          	csrr	a5,sstatus
ffffffffc0204590:	8b89                	andi	a5,a5,2
ffffffffc0204592:	0c079963          	bnez	a5,ffffffffc0204664 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc0204596:	000bb783          	ld	a5,0(s7)
ffffffffc020459a:	779c                	ld	a5,40(a5)
ffffffffc020459c:	9782                	jalr	a5
ffffffffc020459e:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02045a0:	3a8c1563          	bne	s8,s0,ffffffffc020494a <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02045a4:	00004517          	auipc	a0,0x4
ffffffffc02045a8:	ef450513          	addi	a0,a0,-268 # ffffffffc0208498 <default_pmm_manager+0x550>
ffffffffc02045ac:	b21fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02045b0:	6446                	ld	s0,80(sp)
ffffffffc02045b2:	60e6                	ld	ra,88(sp)
ffffffffc02045b4:	64a6                	ld	s1,72(sp)
ffffffffc02045b6:	6906                	ld	s2,64(sp)
ffffffffc02045b8:	79e2                	ld	s3,56(sp)
ffffffffc02045ba:	7a42                	ld	s4,48(sp)
ffffffffc02045bc:	7aa2                	ld	s5,40(sp)
ffffffffc02045be:	7b02                	ld	s6,32(sp)
ffffffffc02045c0:	6be2                	ld	s7,24(sp)
ffffffffc02045c2:	6c42                	ld	s8,16(sp)
ffffffffc02045c4:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc02045c6:	c23fd06f          	j	ffffffffc02021e8 <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02045ca:	6785                	lui	a5,0x1
ffffffffc02045cc:	17fd                	addi	a5,a5,-1
ffffffffc02045ce:	96be                	add	a3,a3,a5
ffffffffc02045d0:	77fd                	lui	a5,0xfffff
ffffffffc02045d2:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc02045d4:	00c7d693          	srli	a3,a5,0xc
ffffffffc02045d8:	14c6f063          	bgeu	a3,a2,ffffffffc0204718 <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc02045dc:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc02045e0:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02045e2:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc02045e6:	6a10                	ld	a2,16(a2)
ffffffffc02045e8:	069a                	slli	a3,a3,0x6
ffffffffc02045ea:	00c7d593          	srli	a1,a5,0xc
ffffffffc02045ee:	9536                	add	a0,a0,a3
ffffffffc02045f0:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc02045f2:	0009b583          	ld	a1,0(s3)
}
ffffffffc02045f6:	b63d                	j	ffffffffc0204124 <pmm_init+0xe4>
        intr_disable();
ffffffffc02045f8:	850fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02045fc:	000bb783          	ld	a5,0(s7)
ffffffffc0204600:	779c                	ld	a5,40(a5)
ffffffffc0204602:	9782                	jalr	a5
ffffffffc0204604:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0204606:	83cfc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020460a:	bea5                	j	ffffffffc0204182 <pmm_init+0x142>
        intr_disable();
ffffffffc020460c:	83cfc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0204610:	000bb783          	ld	a5,0(s7)
ffffffffc0204614:	779c                	ld	a5,40(a5)
ffffffffc0204616:	9782                	jalr	a5
ffffffffc0204618:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc020461a:	828fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020461e:	b3cd                	j	ffffffffc0204400 <pmm_init+0x3c0>
        intr_disable();
ffffffffc0204620:	828fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0204624:	000bb783          	ld	a5,0(s7)
ffffffffc0204628:	779c                	ld	a5,40(a5)
ffffffffc020462a:	9782                	jalr	a5
ffffffffc020462c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020462e:	814fc0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204632:	b36d                	j	ffffffffc02043dc <pmm_init+0x39c>
ffffffffc0204634:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204636:	812fc0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020463a:	000bb783          	ld	a5,0(s7)
ffffffffc020463e:	6522                	ld	a0,8(sp)
ffffffffc0204640:	4585                	li	a1,1
ffffffffc0204642:	739c                	ld	a5,32(a5)
ffffffffc0204644:	9782                	jalr	a5
        intr_enable();
ffffffffc0204646:	ffdfb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020464a:	bb8d                	j	ffffffffc02043bc <pmm_init+0x37c>
ffffffffc020464c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020464e:	ffbfb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0204652:	000bb783          	ld	a5,0(s7)
ffffffffc0204656:	6522                	ld	a0,8(sp)
ffffffffc0204658:	4585                	li	a1,1
ffffffffc020465a:	739c                	ld	a5,32(a5)
ffffffffc020465c:	9782                	jalr	a5
        intr_enable();
ffffffffc020465e:	fe5fb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204662:	b32d                	j	ffffffffc020438c <pmm_init+0x34c>
        intr_disable();
ffffffffc0204664:	fe5fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0204668:	000bb783          	ld	a5,0(s7)
ffffffffc020466c:	779c                	ld	a5,40(a5)
ffffffffc020466e:	9782                	jalr	a5
ffffffffc0204670:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0204672:	fd1fb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204676:	b72d                	j	ffffffffc02045a0 <pmm_init+0x560>
ffffffffc0204678:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020467a:	fcffb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020467e:	000bb783          	ld	a5,0(s7)
ffffffffc0204682:	6522                	ld	a0,8(sp)
ffffffffc0204684:	4585                	li	a1,1
ffffffffc0204686:	739c                	ld	a5,32(a5)
ffffffffc0204688:	9782                	jalr	a5
        intr_enable();
ffffffffc020468a:	fb9fb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020468e:	bdcd                	j	ffffffffc0204580 <pmm_init+0x540>
ffffffffc0204690:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204692:	fb7fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc0204696:	000bb783          	ld	a5,0(s7)
ffffffffc020469a:	6522                	ld	a0,8(sp)
ffffffffc020469c:	4585                	li	a1,1
ffffffffc020469e:	739c                	ld	a5,32(a5)
ffffffffc02046a0:	9782                	jalr	a5
        intr_enable();
ffffffffc02046a2:	fa1fb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02046a6:	b56d                	j	ffffffffc0204550 <pmm_init+0x510>
        intr_disable();
ffffffffc02046a8:	fa1fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
ffffffffc02046ac:	000bb783          	ld	a5,0(s7)
ffffffffc02046b0:	4585                	li	a1,1
ffffffffc02046b2:	8556                	mv	a0,s5
ffffffffc02046b4:	739c                	ld	a5,32(a5)
ffffffffc02046b6:	9782                	jalr	a5
        intr_enable();
ffffffffc02046b8:	f8bfb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc02046bc:	b59d                	j	ffffffffc0204522 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02046be:	00004697          	auipc	a3,0x4
ffffffffc02046c2:	c8a68693          	addi	a3,a3,-886 # ffffffffc0208348 <default_pmm_manager+0x400>
ffffffffc02046c6:	00002617          	auipc	a2,0x2
ffffffffc02046ca:	6ea60613          	addi	a2,a2,1770 # ffffffffc0206db0 <commands+0x410>
ffffffffc02046ce:	23300593          	li	a1,563
ffffffffc02046d2:	00004517          	auipc	a0,0x4
ffffffffc02046d6:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc02046da:	b2ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02046de:	00004697          	auipc	a3,0x4
ffffffffc02046e2:	c2a68693          	addi	a3,a3,-982 # ffffffffc0208308 <default_pmm_manager+0x3c0>
ffffffffc02046e6:	00002617          	auipc	a2,0x2
ffffffffc02046ea:	6ca60613          	addi	a2,a2,1738 # ffffffffc0206db0 <commands+0x410>
ffffffffc02046ee:	23200593          	li	a1,562
ffffffffc02046f2:	00004517          	auipc	a0,0x4
ffffffffc02046f6:	88e50513          	addi	a0,a0,-1906 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc02046fa:	b0ffb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc02046fe:	86a2                	mv	a3,s0
ffffffffc0204700:	00003617          	auipc	a2,0x3
ffffffffc0204704:	ae860613          	addi	a2,a2,-1304 # ffffffffc02071e8 <commands+0x848>
ffffffffc0204708:	23200593          	li	a1,562
ffffffffc020470c:	00004517          	auipc	a0,0x4
ffffffffc0204710:	87450513          	addi	a0,a0,-1932 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204714:	af5fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204718:	854ff0ef          	jal	ra,ffffffffc020376c <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020471c:	00003617          	auipc	a2,0x3
ffffffffc0204720:	10460613          	addi	a2,a2,260 # ffffffffc0207820 <commands+0xe80>
ffffffffc0204724:	07f00593          	li	a1,127
ffffffffc0204728:	00004517          	auipc	a0,0x4
ffffffffc020472c:	85850513          	addi	a0,a0,-1960 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204730:	ad9fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0204734:	00003617          	auipc	a2,0x3
ffffffffc0204738:	0ec60613          	addi	a2,a2,236 # ffffffffc0207820 <commands+0xe80>
ffffffffc020473c:	0c100593          	li	a1,193
ffffffffc0204740:	00004517          	auipc	a0,0x4
ffffffffc0204744:	84050513          	addi	a0,a0,-1984 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204748:	ac1fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020474c:	00004697          	auipc	a3,0x4
ffffffffc0204750:	8f468693          	addi	a3,a3,-1804 # ffffffffc0208040 <default_pmm_manager+0xf8>
ffffffffc0204754:	00002617          	auipc	a2,0x2
ffffffffc0204758:	65c60613          	addi	a2,a2,1628 # ffffffffc0206db0 <commands+0x410>
ffffffffc020475c:	1f600593          	li	a1,502
ffffffffc0204760:	00004517          	auipc	a0,0x4
ffffffffc0204764:	82050513          	addi	a0,a0,-2016 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204768:	aa1fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020476c:	00004697          	auipc	a3,0x4
ffffffffc0204770:	8b468693          	addi	a3,a3,-1868 # ffffffffc0208020 <default_pmm_manager+0xd8>
ffffffffc0204774:	00002617          	auipc	a2,0x2
ffffffffc0204778:	63c60613          	addi	a2,a2,1596 # ffffffffc0206db0 <commands+0x410>
ffffffffc020477c:	1f500593          	li	a1,501
ffffffffc0204780:	00004517          	auipc	a0,0x4
ffffffffc0204784:	80050513          	addi	a0,a0,-2048 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204788:	a81fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc020478c:	ffdfe0ef          	jal	ra,ffffffffc0203788 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0204790:	00004697          	auipc	a3,0x4
ffffffffc0204794:	94068693          	addi	a3,a3,-1728 # ffffffffc02080d0 <default_pmm_manager+0x188>
ffffffffc0204798:	00002617          	auipc	a2,0x2
ffffffffc020479c:	61860613          	addi	a2,a2,1560 # ffffffffc0206db0 <commands+0x410>
ffffffffc02047a0:	1fe00593          	li	a1,510
ffffffffc02047a4:	00003517          	auipc	a0,0x3
ffffffffc02047a8:	7dc50513          	addi	a0,a0,2012 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc02047ac:	a5dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02047b0:	00004697          	auipc	a3,0x4
ffffffffc02047b4:	8f068693          	addi	a3,a3,-1808 # ffffffffc02080a0 <default_pmm_manager+0x158>
ffffffffc02047b8:	00002617          	auipc	a2,0x2
ffffffffc02047bc:	5f860613          	addi	a2,a2,1528 # ffffffffc0206db0 <commands+0x410>
ffffffffc02047c0:	1fb00593          	li	a1,507
ffffffffc02047c4:	00003517          	auipc	a0,0x3
ffffffffc02047c8:	7bc50513          	addi	a0,a0,1980 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc02047cc:	a3dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02047d0:	00004697          	auipc	a3,0x4
ffffffffc02047d4:	8a868693          	addi	a3,a3,-1880 # ffffffffc0208078 <default_pmm_manager+0x130>
ffffffffc02047d8:	00002617          	auipc	a2,0x2
ffffffffc02047dc:	5d860613          	addi	a2,a2,1496 # ffffffffc0206db0 <commands+0x410>
ffffffffc02047e0:	1f700593          	li	a1,503
ffffffffc02047e4:	00003517          	auipc	a0,0x3
ffffffffc02047e8:	79c50513          	addi	a0,a0,1948 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc02047ec:	a1dfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02047f0:	00004697          	auipc	a3,0x4
ffffffffc02047f4:	96868693          	addi	a3,a3,-1688 # ffffffffc0208158 <default_pmm_manager+0x210>
ffffffffc02047f8:	00002617          	auipc	a2,0x2
ffffffffc02047fc:	5b860613          	addi	a2,a2,1464 # ffffffffc0206db0 <commands+0x410>
ffffffffc0204800:	20700593          	li	a1,519
ffffffffc0204804:	00003517          	auipc	a0,0x3
ffffffffc0204808:	77c50513          	addi	a0,a0,1916 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc020480c:	9fdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0204810:	00004697          	auipc	a3,0x4
ffffffffc0204814:	9e868693          	addi	a3,a3,-1560 # ffffffffc02081f8 <default_pmm_manager+0x2b0>
ffffffffc0204818:	00002617          	auipc	a2,0x2
ffffffffc020481c:	59860613          	addi	a2,a2,1432 # ffffffffc0206db0 <commands+0x410>
ffffffffc0204820:	20c00593          	li	a1,524
ffffffffc0204824:	00003517          	auipc	a0,0x3
ffffffffc0204828:	75c50513          	addi	a0,a0,1884 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc020482c:	9ddfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0204830:	00004697          	auipc	a3,0x4
ffffffffc0204834:	90068693          	addi	a3,a3,-1792 # ffffffffc0208130 <default_pmm_manager+0x1e8>
ffffffffc0204838:	00002617          	auipc	a2,0x2
ffffffffc020483c:	57860613          	addi	a2,a2,1400 # ffffffffc0206db0 <commands+0x410>
ffffffffc0204840:	20400593          	li	a1,516
ffffffffc0204844:	00003517          	auipc	a0,0x3
ffffffffc0204848:	73c50513          	addi	a0,a0,1852 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc020484c:	9bdfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0204850:	86d6                	mv	a3,s5
ffffffffc0204852:	00003617          	auipc	a2,0x3
ffffffffc0204856:	99660613          	addi	a2,a2,-1642 # ffffffffc02071e8 <commands+0x848>
ffffffffc020485a:	20300593          	li	a1,515
ffffffffc020485e:	00003517          	auipc	a0,0x3
ffffffffc0204862:	72250513          	addi	a0,a0,1826 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204866:	9a3fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020486a:	00004697          	auipc	a3,0x4
ffffffffc020486e:	92668693          	addi	a3,a3,-1754 # ffffffffc0208190 <default_pmm_manager+0x248>
ffffffffc0204872:	00002617          	auipc	a2,0x2
ffffffffc0204876:	53e60613          	addi	a2,a2,1342 # ffffffffc0206db0 <commands+0x410>
ffffffffc020487a:	21100593          	li	a1,529
ffffffffc020487e:	00003517          	auipc	a0,0x3
ffffffffc0204882:	70250513          	addi	a0,a0,1794 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204886:	983fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020488a:	00004697          	auipc	a3,0x4
ffffffffc020488e:	9ce68693          	addi	a3,a3,-1586 # ffffffffc0208258 <default_pmm_manager+0x310>
ffffffffc0204892:	00002617          	auipc	a2,0x2
ffffffffc0204896:	51e60613          	addi	a2,a2,1310 # ffffffffc0206db0 <commands+0x410>
ffffffffc020489a:	21000593          	li	a1,528
ffffffffc020489e:	00003517          	auipc	a0,0x3
ffffffffc02048a2:	6e250513          	addi	a0,a0,1762 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc02048a6:	963fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02048aa:	00004697          	auipc	a3,0x4
ffffffffc02048ae:	99668693          	addi	a3,a3,-1642 # ffffffffc0208240 <default_pmm_manager+0x2f8>
ffffffffc02048b2:	00002617          	auipc	a2,0x2
ffffffffc02048b6:	4fe60613          	addi	a2,a2,1278 # ffffffffc0206db0 <commands+0x410>
ffffffffc02048ba:	20f00593          	li	a1,527
ffffffffc02048be:	00003517          	auipc	a0,0x3
ffffffffc02048c2:	6c250513          	addi	a0,a0,1730 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc02048c6:	943fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02048ca:	00004697          	auipc	a3,0x4
ffffffffc02048ce:	94668693          	addi	a3,a3,-1722 # ffffffffc0208210 <default_pmm_manager+0x2c8>
ffffffffc02048d2:	00002617          	auipc	a2,0x2
ffffffffc02048d6:	4de60613          	addi	a2,a2,1246 # ffffffffc0206db0 <commands+0x410>
ffffffffc02048da:	20e00593          	li	a1,526
ffffffffc02048de:	00003517          	auipc	a0,0x3
ffffffffc02048e2:	6a250513          	addi	a0,a0,1698 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc02048e6:	923fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02048ea:	00004697          	auipc	a3,0x4
ffffffffc02048ee:	ade68693          	addi	a3,a3,-1314 # ffffffffc02083c8 <default_pmm_manager+0x480>
ffffffffc02048f2:	00002617          	auipc	a2,0x2
ffffffffc02048f6:	4be60613          	addi	a2,a2,1214 # ffffffffc0206db0 <commands+0x410>
ffffffffc02048fa:	23d00593          	li	a1,573
ffffffffc02048fe:	00003517          	auipc	a0,0x3
ffffffffc0204902:	68250513          	addi	a0,a0,1666 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204906:	903fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020490a:	00004697          	auipc	a3,0x4
ffffffffc020490e:	8d668693          	addi	a3,a3,-1834 # ffffffffc02081e0 <default_pmm_manager+0x298>
ffffffffc0204912:	00002617          	auipc	a2,0x2
ffffffffc0204916:	49e60613          	addi	a2,a2,1182 # ffffffffc0206db0 <commands+0x410>
ffffffffc020491a:	20b00593          	li	a1,523
ffffffffc020491e:	00003517          	auipc	a0,0x3
ffffffffc0204922:	66250513          	addi	a0,a0,1634 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204926:	8e3fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020492a:	00004697          	auipc	a3,0x4
ffffffffc020492e:	8a668693          	addi	a3,a3,-1882 # ffffffffc02081d0 <default_pmm_manager+0x288>
ffffffffc0204932:	00002617          	auipc	a2,0x2
ffffffffc0204936:	47e60613          	addi	a2,a2,1150 # ffffffffc0206db0 <commands+0x410>
ffffffffc020493a:	20a00593          	li	a1,522
ffffffffc020493e:	00003517          	auipc	a0,0x3
ffffffffc0204942:	64250513          	addi	a0,a0,1602 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204946:	8c3fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020494a:	00004697          	auipc	a3,0x4
ffffffffc020494e:	97e68693          	addi	a3,a3,-1666 # ffffffffc02082c8 <default_pmm_manager+0x380>
ffffffffc0204952:	00002617          	auipc	a2,0x2
ffffffffc0204956:	45e60613          	addi	a2,a2,1118 # ffffffffc0206db0 <commands+0x410>
ffffffffc020495a:	24e00593          	li	a1,590
ffffffffc020495e:	00003517          	auipc	a0,0x3
ffffffffc0204962:	62250513          	addi	a0,a0,1570 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204966:	8a3fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020496a:	00004697          	auipc	a3,0x4
ffffffffc020496e:	85668693          	addi	a3,a3,-1962 # ffffffffc02081c0 <default_pmm_manager+0x278>
ffffffffc0204972:	00002617          	auipc	a2,0x2
ffffffffc0204976:	43e60613          	addi	a2,a2,1086 # ffffffffc0206db0 <commands+0x410>
ffffffffc020497a:	20900593          	li	a1,521
ffffffffc020497e:	00003517          	auipc	a0,0x3
ffffffffc0204982:	60250513          	addi	a0,a0,1538 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204986:	883fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020498a:	00003697          	auipc	a3,0x3
ffffffffc020498e:	78e68693          	addi	a3,a3,1934 # ffffffffc0208118 <default_pmm_manager+0x1d0>
ffffffffc0204992:	00002617          	auipc	a2,0x2
ffffffffc0204996:	41e60613          	addi	a2,a2,1054 # ffffffffc0206db0 <commands+0x410>
ffffffffc020499a:	21600593          	li	a1,534
ffffffffc020499e:	00003517          	auipc	a0,0x3
ffffffffc02049a2:	5e250513          	addi	a0,a0,1506 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc02049a6:	863fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02049aa:	00004697          	auipc	a3,0x4
ffffffffc02049ae:	8c668693          	addi	a3,a3,-1850 # ffffffffc0208270 <default_pmm_manager+0x328>
ffffffffc02049b2:	00002617          	auipc	a2,0x2
ffffffffc02049b6:	3fe60613          	addi	a2,a2,1022 # ffffffffc0206db0 <commands+0x410>
ffffffffc02049ba:	21300593          	li	a1,531
ffffffffc02049be:	00003517          	auipc	a0,0x3
ffffffffc02049c2:	5c250513          	addi	a0,a0,1474 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc02049c6:	843fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02049ca:	00003697          	auipc	a3,0x3
ffffffffc02049ce:	73668693          	addi	a3,a3,1846 # ffffffffc0208100 <default_pmm_manager+0x1b8>
ffffffffc02049d2:	00002617          	auipc	a2,0x2
ffffffffc02049d6:	3de60613          	addi	a2,a2,990 # ffffffffc0206db0 <commands+0x410>
ffffffffc02049da:	21200593          	li	a1,530
ffffffffc02049de:	00003517          	auipc	a0,0x3
ffffffffc02049e2:	5a250513          	addi	a0,a0,1442 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc02049e6:	823fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc02049ea:	00002617          	auipc	a2,0x2
ffffffffc02049ee:	7fe60613          	addi	a2,a2,2046 # ffffffffc02071e8 <commands+0x848>
ffffffffc02049f2:	06900593          	li	a1,105
ffffffffc02049f6:	00002517          	auipc	a0,0x2
ffffffffc02049fa:	75a50513          	addi	a0,a0,1882 # ffffffffc0207150 <commands+0x7b0>
ffffffffc02049fe:	80bfb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0204a02:	00004697          	auipc	a3,0x4
ffffffffc0204a06:	89e68693          	addi	a3,a3,-1890 # ffffffffc02082a0 <default_pmm_manager+0x358>
ffffffffc0204a0a:	00002617          	auipc	a2,0x2
ffffffffc0204a0e:	3a660613          	addi	a2,a2,934 # ffffffffc0206db0 <commands+0x410>
ffffffffc0204a12:	21d00593          	li	a1,541
ffffffffc0204a16:	00003517          	auipc	a0,0x3
ffffffffc0204a1a:	56a50513          	addi	a0,a0,1386 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204a1e:	feafb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0204a22:	00004697          	auipc	a3,0x4
ffffffffc0204a26:	83668693          	addi	a3,a3,-1994 # ffffffffc0208258 <default_pmm_manager+0x310>
ffffffffc0204a2a:	00002617          	auipc	a2,0x2
ffffffffc0204a2e:	38660613          	addi	a2,a2,902 # ffffffffc0206db0 <commands+0x410>
ffffffffc0204a32:	21b00593          	li	a1,539
ffffffffc0204a36:	00003517          	auipc	a0,0x3
ffffffffc0204a3a:	54a50513          	addi	a0,a0,1354 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204a3e:	fcafb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0204a42:	00004697          	auipc	a3,0x4
ffffffffc0204a46:	84668693          	addi	a3,a3,-1978 # ffffffffc0208288 <default_pmm_manager+0x340>
ffffffffc0204a4a:	00002617          	auipc	a2,0x2
ffffffffc0204a4e:	36660613          	addi	a2,a2,870 # ffffffffc0206db0 <commands+0x410>
ffffffffc0204a52:	21a00593          	li	a1,538
ffffffffc0204a56:	00003517          	auipc	a0,0x3
ffffffffc0204a5a:	52a50513          	addi	a0,a0,1322 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204a5e:	faafb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0204a62:	00003697          	auipc	a3,0x3
ffffffffc0204a66:	7f668693          	addi	a3,a3,2038 # ffffffffc0208258 <default_pmm_manager+0x310>
ffffffffc0204a6a:	00002617          	auipc	a2,0x2
ffffffffc0204a6e:	34660613          	addi	a2,a2,838 # ffffffffc0206db0 <commands+0x410>
ffffffffc0204a72:	21700593          	li	a1,535
ffffffffc0204a76:	00003517          	auipc	a0,0x3
ffffffffc0204a7a:	50a50513          	addi	a0,a0,1290 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204a7e:	f8afb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0204a82:	00004697          	auipc	a3,0x4
ffffffffc0204a86:	92e68693          	addi	a3,a3,-1746 # ffffffffc02083b0 <default_pmm_manager+0x468>
ffffffffc0204a8a:	00002617          	auipc	a2,0x2
ffffffffc0204a8e:	32660613          	addi	a2,a2,806 # ffffffffc0206db0 <commands+0x410>
ffffffffc0204a92:	23c00593          	li	a1,572
ffffffffc0204a96:	00003517          	auipc	a0,0x3
ffffffffc0204a9a:	4ea50513          	addi	a0,a0,1258 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204a9e:	f6afb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0204aa2:	00004697          	auipc	a3,0x4
ffffffffc0204aa6:	8d668693          	addi	a3,a3,-1834 # ffffffffc0208378 <default_pmm_manager+0x430>
ffffffffc0204aaa:	00002617          	auipc	a2,0x2
ffffffffc0204aae:	30660613          	addi	a2,a2,774 # ffffffffc0206db0 <commands+0x410>
ffffffffc0204ab2:	23b00593          	li	a1,571
ffffffffc0204ab6:	00003517          	auipc	a0,0x3
ffffffffc0204aba:	4ca50513          	addi	a0,a0,1226 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204abe:	f4afb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0204ac2:	00004697          	auipc	a3,0x4
ffffffffc0204ac6:	89e68693          	addi	a3,a3,-1890 # ffffffffc0208360 <default_pmm_manager+0x418>
ffffffffc0204aca:	00002617          	auipc	a2,0x2
ffffffffc0204ace:	2e660613          	addi	a2,a2,742 # ffffffffc0206db0 <commands+0x410>
ffffffffc0204ad2:	23700593          	li	a1,567
ffffffffc0204ad6:	00003517          	auipc	a0,0x3
ffffffffc0204ada:	4aa50513          	addi	a0,a0,1194 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204ade:	f2afb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0204ae2:	00003697          	auipc	a3,0x3
ffffffffc0204ae6:	7e668693          	addi	a3,a3,2022 # ffffffffc02082c8 <default_pmm_manager+0x380>
ffffffffc0204aea:	00002617          	auipc	a2,0x2
ffffffffc0204aee:	2c660613          	addi	a2,a2,710 # ffffffffc0206db0 <commands+0x410>
ffffffffc0204af2:	22500593          	li	a1,549
ffffffffc0204af6:	00003517          	auipc	a0,0x3
ffffffffc0204afa:	48a50513          	addi	a0,a0,1162 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204afe:	f0afb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0204b02:	00003697          	auipc	a3,0x3
ffffffffc0204b06:	5fe68693          	addi	a3,a3,1534 # ffffffffc0208100 <default_pmm_manager+0x1b8>
ffffffffc0204b0a:	00002617          	auipc	a2,0x2
ffffffffc0204b0e:	2a660613          	addi	a2,a2,678 # ffffffffc0206db0 <commands+0x410>
ffffffffc0204b12:	1ff00593          	li	a1,511
ffffffffc0204b16:	00003517          	auipc	a0,0x3
ffffffffc0204b1a:	46a50513          	addi	a0,a0,1130 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204b1e:	eeafb0ef          	jal	ra,ffffffffc0200208 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0204b22:	00002617          	auipc	a2,0x2
ffffffffc0204b26:	6c660613          	addi	a2,a2,1734 # ffffffffc02071e8 <commands+0x848>
ffffffffc0204b2a:	20200593          	li	a1,514
ffffffffc0204b2e:	00003517          	auipc	a0,0x3
ffffffffc0204b32:	45250513          	addi	a0,a0,1106 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204b36:	ed2fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0204b3a:	00003697          	auipc	a3,0x3
ffffffffc0204b3e:	5de68693          	addi	a3,a3,1502 # ffffffffc0208118 <default_pmm_manager+0x1d0>
ffffffffc0204b42:	00002617          	auipc	a2,0x2
ffffffffc0204b46:	26e60613          	addi	a2,a2,622 # ffffffffc0206db0 <commands+0x410>
ffffffffc0204b4a:	20000593          	li	a1,512
ffffffffc0204b4e:	00003517          	auipc	a0,0x3
ffffffffc0204b52:	43250513          	addi	a0,a0,1074 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204b56:	eb2fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0204b5a:	00003697          	auipc	a3,0x3
ffffffffc0204b5e:	63668693          	addi	a3,a3,1590 # ffffffffc0208190 <default_pmm_manager+0x248>
ffffffffc0204b62:	00002617          	auipc	a2,0x2
ffffffffc0204b66:	24e60613          	addi	a2,a2,590 # ffffffffc0206db0 <commands+0x410>
ffffffffc0204b6a:	20800593          	li	a1,520
ffffffffc0204b6e:	00003517          	auipc	a0,0x3
ffffffffc0204b72:	41250513          	addi	a0,a0,1042 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204b76:	e92fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0204b7a:	00004697          	auipc	a3,0x4
ffffffffc0204b7e:	8f668693          	addi	a3,a3,-1802 # ffffffffc0208470 <default_pmm_manager+0x528>
ffffffffc0204b82:	00002617          	auipc	a2,0x2
ffffffffc0204b86:	22e60613          	addi	a2,a2,558 # ffffffffc0206db0 <commands+0x410>
ffffffffc0204b8a:	24500593          	li	a1,581
ffffffffc0204b8e:	00003517          	auipc	a0,0x3
ffffffffc0204b92:	3f250513          	addi	a0,a0,1010 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204b96:	e72fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0204b9a:	00004697          	auipc	a3,0x4
ffffffffc0204b9e:	89e68693          	addi	a3,a3,-1890 # ffffffffc0208438 <default_pmm_manager+0x4f0>
ffffffffc0204ba2:	00002617          	auipc	a2,0x2
ffffffffc0204ba6:	20e60613          	addi	a2,a2,526 # ffffffffc0206db0 <commands+0x410>
ffffffffc0204baa:	24200593          	li	a1,578
ffffffffc0204bae:	00003517          	auipc	a0,0x3
ffffffffc0204bb2:	3d250513          	addi	a0,a0,978 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204bb6:	e52fb0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0204bba:	00004697          	auipc	a3,0x4
ffffffffc0204bbe:	84e68693          	addi	a3,a3,-1970 # ffffffffc0208408 <default_pmm_manager+0x4c0>
ffffffffc0204bc2:	00002617          	auipc	a2,0x2
ffffffffc0204bc6:	1ee60613          	addi	a2,a2,494 # ffffffffc0206db0 <commands+0x410>
ffffffffc0204bca:	23e00593          	li	a1,574
ffffffffc0204bce:	00003517          	auipc	a0,0x3
ffffffffc0204bd2:	3b250513          	addi	a0,a0,946 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204bd6:	e32fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204bda <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0204bda:	12058073          	sfence.vma	a1
}
ffffffffc0204bde:	8082                	ret

ffffffffc0204be0 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204be0:	7179                	addi	sp,sp,-48
ffffffffc0204be2:	e84a                	sd	s2,16(sp)
ffffffffc0204be4:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0204be6:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204be8:	f022                	sd	s0,32(sp)
ffffffffc0204bea:	ec26                	sd	s1,24(sp)
ffffffffc0204bec:	e44e                	sd	s3,8(sp)
ffffffffc0204bee:	f406                	sd	ra,40(sp)
ffffffffc0204bf0:	84ae                	mv	s1,a1
ffffffffc0204bf2:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0204bf4:	bb1fe0ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc0204bf8:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0204bfa:	cd05                	beqz	a0,ffffffffc0204c32 <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0204bfc:	85aa                	mv	a1,a0
ffffffffc0204bfe:	86ce                	mv	a3,s3
ffffffffc0204c00:	8626                	mv	a2,s1
ffffffffc0204c02:	854a                	mv	a0,s2
ffffffffc0204c04:	b46ff0ef          	jal	ra,ffffffffc0203f4a <page_insert>
ffffffffc0204c08:	ed0d                	bnez	a0,ffffffffc0204c42 <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc0204c0a:	000ae797          	auipc	a5,0xae
ffffffffc0204c0e:	bfe7a783          	lw	a5,-1026(a5) # ffffffffc02b2808 <swap_init_ok>
ffffffffc0204c12:	c385                	beqz	a5,ffffffffc0204c32 <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc0204c14:	000ae517          	auipc	a0,0xae
ffffffffc0204c18:	bcc53503          	ld	a0,-1076(a0) # ffffffffc02b27e0 <check_mm_struct>
ffffffffc0204c1c:	c919                	beqz	a0,ffffffffc0204c32 <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0204c1e:	4681                	li	a3,0
ffffffffc0204c20:	8622                	mv	a2,s0
ffffffffc0204c22:	85a6                	mv	a1,s1
ffffffffc0204c24:	f01fd0ef          	jal	ra,ffffffffc0202b24 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0204c28:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0204c2a:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0204c2c:	4785                	li	a5,1
ffffffffc0204c2e:	04f71663          	bne	a4,a5,ffffffffc0204c7a <pgdir_alloc_page+0x9a>
}
ffffffffc0204c32:	70a2                	ld	ra,40(sp)
ffffffffc0204c34:	8522                	mv	a0,s0
ffffffffc0204c36:	7402                	ld	s0,32(sp)
ffffffffc0204c38:	64e2                	ld	s1,24(sp)
ffffffffc0204c3a:	6942                	ld	s2,16(sp)
ffffffffc0204c3c:	69a2                	ld	s3,8(sp)
ffffffffc0204c3e:	6145                	addi	sp,sp,48
ffffffffc0204c40:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204c42:	100027f3          	csrr	a5,sstatus
ffffffffc0204c46:	8b89                	andi	a5,a5,2
ffffffffc0204c48:	eb99                	bnez	a5,ffffffffc0204c5e <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc0204c4a:	000ae797          	auipc	a5,0xae
ffffffffc0204c4e:	be67b783          	ld	a5,-1050(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0204c52:	739c                	ld	a5,32(a5)
ffffffffc0204c54:	8522                	mv	a0,s0
ffffffffc0204c56:	4585                	li	a1,1
ffffffffc0204c58:	9782                	jalr	a5
            return NULL;
ffffffffc0204c5a:	4401                	li	s0,0
ffffffffc0204c5c:	bfd9                	j	ffffffffc0204c32 <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc0204c5e:	9ebfb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0204c62:	000ae797          	auipc	a5,0xae
ffffffffc0204c66:	bce7b783          	ld	a5,-1074(a5) # ffffffffc02b2830 <pmm_manager>
ffffffffc0204c6a:	739c                	ld	a5,32(a5)
ffffffffc0204c6c:	8522                	mv	a0,s0
ffffffffc0204c6e:	4585                	li	a1,1
ffffffffc0204c70:	9782                	jalr	a5
            return NULL;
ffffffffc0204c72:	4401                	li	s0,0
        intr_enable();
ffffffffc0204c74:	9cffb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0204c78:	bf6d                	j	ffffffffc0204c32 <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc0204c7a:	00004697          	auipc	a3,0x4
ffffffffc0204c7e:	83e68693          	addi	a3,a3,-1986 # ffffffffc02084b8 <default_pmm_manager+0x570>
ffffffffc0204c82:	00002617          	auipc	a2,0x2
ffffffffc0204c86:	12e60613          	addi	a2,a2,302 # ffffffffc0206db0 <commands+0x410>
ffffffffc0204c8a:	1d600593          	li	a1,470
ffffffffc0204c8e:	00003517          	auipc	a0,0x3
ffffffffc0204c92:	2f250513          	addi	a0,a0,754 # ffffffffc0207f80 <default_pmm_manager+0x38>
ffffffffc0204c96:	d72fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204c9a <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204c9a:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204c9c:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204c9e:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204ca0:	889fb0ef          	jal	ra,ffffffffc0200528 <ide_device_valid>
ffffffffc0204ca4:	cd01                	beqz	a0,ffffffffc0204cbc <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204ca6:	4505                	li	a0,1
ffffffffc0204ca8:	887fb0ef          	jal	ra,ffffffffc020052e <ide_device_size>
}
ffffffffc0204cac:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204cae:	810d                	srli	a0,a0,0x3
ffffffffc0204cb0:	000ae797          	auipc	a5,0xae
ffffffffc0204cb4:	b4a7b423          	sd	a0,-1208(a5) # ffffffffc02b27f8 <max_swap_offset>
}
ffffffffc0204cb8:	0141                	addi	sp,sp,16
ffffffffc0204cba:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204cbc:	00004617          	auipc	a2,0x4
ffffffffc0204cc0:	81460613          	addi	a2,a2,-2028 # ffffffffc02084d0 <default_pmm_manager+0x588>
ffffffffc0204cc4:	45b5                	li	a1,13
ffffffffc0204cc6:	00004517          	auipc	a0,0x4
ffffffffc0204cca:	82a50513          	addi	a0,a0,-2006 # ffffffffc02084f0 <default_pmm_manager+0x5a8>
ffffffffc0204cce:	d3afb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204cd2 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204cd2:	1141                	addi	sp,sp,-16
ffffffffc0204cd4:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204cd6:	00855793          	srli	a5,a0,0x8
ffffffffc0204cda:	cbb1                	beqz	a5,ffffffffc0204d2e <swapfs_read+0x5c>
ffffffffc0204cdc:	000ae717          	auipc	a4,0xae
ffffffffc0204ce0:	b1c73703          	ld	a4,-1252(a4) # ffffffffc02b27f8 <max_swap_offset>
ffffffffc0204ce4:	04e7f563          	bgeu	a5,a4,ffffffffc0204d2e <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204ce8:	000ae617          	auipc	a2,0xae
ffffffffc0204cec:	b4063603          	ld	a2,-1216(a2) # ffffffffc02b2828 <pages>
ffffffffc0204cf0:	8d91                	sub	a1,a1,a2
ffffffffc0204cf2:	4065d613          	srai	a2,a1,0x6
ffffffffc0204cf6:	00004717          	auipc	a4,0x4
ffffffffc0204cfa:	15273703          	ld	a4,338(a4) # ffffffffc0208e48 <nbase>
ffffffffc0204cfe:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204d00:	00c61713          	slli	a4,a2,0xc
ffffffffc0204d04:	8331                	srli	a4,a4,0xc
ffffffffc0204d06:	000ae697          	auipc	a3,0xae
ffffffffc0204d0a:	b1a6b683          	ld	a3,-1254(a3) # ffffffffc02b2820 <npage>
ffffffffc0204d0e:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d12:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204d14:	02d77963          	bgeu	a4,a3,ffffffffc0204d46 <swapfs_read+0x74>
}
ffffffffc0204d18:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d1a:	000ae797          	auipc	a5,0xae
ffffffffc0204d1e:	b1e7b783          	ld	a5,-1250(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0204d22:	46a1                	li	a3,8
ffffffffc0204d24:	963e                	add	a2,a2,a5
ffffffffc0204d26:	4505                	li	a0,1
}
ffffffffc0204d28:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d2a:	80bfb06f          	j	ffffffffc0200534 <ide_read_secs>
ffffffffc0204d2e:	86aa                	mv	a3,a0
ffffffffc0204d30:	00003617          	auipc	a2,0x3
ffffffffc0204d34:	7d860613          	addi	a2,a2,2008 # ffffffffc0208508 <default_pmm_manager+0x5c0>
ffffffffc0204d38:	45d1                	li	a1,20
ffffffffc0204d3a:	00003517          	auipc	a0,0x3
ffffffffc0204d3e:	7b650513          	addi	a0,a0,1974 # ffffffffc02084f0 <default_pmm_manager+0x5a8>
ffffffffc0204d42:	cc6fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204d46:	86b2                	mv	a3,a2
ffffffffc0204d48:	06900593          	li	a1,105
ffffffffc0204d4c:	00002617          	auipc	a2,0x2
ffffffffc0204d50:	49c60613          	addi	a2,a2,1180 # ffffffffc02071e8 <commands+0x848>
ffffffffc0204d54:	00002517          	auipc	a0,0x2
ffffffffc0204d58:	3fc50513          	addi	a0,a0,1020 # ffffffffc0207150 <commands+0x7b0>
ffffffffc0204d5c:	cacfb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204d60 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204d60:	1141                	addi	sp,sp,-16
ffffffffc0204d62:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d64:	00855793          	srli	a5,a0,0x8
ffffffffc0204d68:	cbb1                	beqz	a5,ffffffffc0204dbc <swapfs_write+0x5c>
ffffffffc0204d6a:	000ae717          	auipc	a4,0xae
ffffffffc0204d6e:	a8e73703          	ld	a4,-1394(a4) # ffffffffc02b27f8 <max_swap_offset>
ffffffffc0204d72:	04e7f563          	bgeu	a5,a4,ffffffffc0204dbc <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204d76:	000ae617          	auipc	a2,0xae
ffffffffc0204d7a:	ab263603          	ld	a2,-1358(a2) # ffffffffc02b2828 <pages>
ffffffffc0204d7e:	8d91                	sub	a1,a1,a2
ffffffffc0204d80:	4065d613          	srai	a2,a1,0x6
ffffffffc0204d84:	00004717          	auipc	a4,0x4
ffffffffc0204d88:	0c473703          	ld	a4,196(a4) # ffffffffc0208e48 <nbase>
ffffffffc0204d8c:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204d8e:	00c61713          	slli	a4,a2,0xc
ffffffffc0204d92:	8331                	srli	a4,a4,0xc
ffffffffc0204d94:	000ae697          	auipc	a3,0xae
ffffffffc0204d98:	a8c6b683          	ld	a3,-1396(a3) # ffffffffc02b2820 <npage>
ffffffffc0204d9c:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204da0:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204da2:	02d77963          	bgeu	a4,a3,ffffffffc0204dd4 <swapfs_write+0x74>
}
ffffffffc0204da6:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204da8:	000ae797          	auipc	a5,0xae
ffffffffc0204dac:	a907b783          	ld	a5,-1392(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0204db0:	46a1                	li	a3,8
ffffffffc0204db2:	963e                	add	a2,a2,a5
ffffffffc0204db4:	4505                	li	a0,1
}
ffffffffc0204db6:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204db8:	fa0fb06f          	j	ffffffffc0200558 <ide_write_secs>
ffffffffc0204dbc:	86aa                	mv	a3,a0
ffffffffc0204dbe:	00003617          	auipc	a2,0x3
ffffffffc0204dc2:	74a60613          	addi	a2,a2,1866 # ffffffffc0208508 <default_pmm_manager+0x5c0>
ffffffffc0204dc6:	45e5                	li	a1,25
ffffffffc0204dc8:	00003517          	auipc	a0,0x3
ffffffffc0204dcc:	72850513          	addi	a0,a0,1832 # ffffffffc02084f0 <default_pmm_manager+0x5a8>
ffffffffc0204dd0:	c38fb0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0204dd4:	86b2                	mv	a3,a2
ffffffffc0204dd6:	06900593          	li	a1,105
ffffffffc0204dda:	00002617          	auipc	a2,0x2
ffffffffc0204dde:	40e60613          	addi	a2,a2,1038 # ffffffffc02071e8 <commands+0x848>
ffffffffc0204de2:	00002517          	auipc	a0,0x2
ffffffffc0204de6:	36e50513          	addi	a0,a0,878 # ffffffffc0207150 <commands+0x7b0>
ffffffffc0204dea:	c1efb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204dee <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204dee:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204df2:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204df6:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204df8:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204dfa:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204dfe:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204e02:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204e06:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204e0a:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204e0e:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204e12:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204e16:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204e1a:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204e1e:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204e22:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204e26:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204e2a:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204e2c:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204e2e:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204e32:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204e36:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204e3a:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204e3e:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204e42:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204e46:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204e4a:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204e4e:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204e52:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204e56:	8082                	ret

ffffffffc0204e58 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204e58:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204e5a:	9402                	jalr	s0

	jal do_exit
ffffffffc0204e5c:	638000ef          	jal	ra,ffffffffc0205494 <do_exit>

ffffffffc0204e60 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204e60:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204e62:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204e66:	e022                	sd	s0,0(sp)
ffffffffc0204e68:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204e6a:	ba2fd0ef          	jal	ra,ffffffffc020220c <kmalloc>
ffffffffc0204e6e:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204e70:	cd21                	beqz	a0,ffffffffc0204ec8 <alloc_proc+0x68>
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     * proc_struct中的以下字段（在LAB5中的添加）需要初始化
     *       uint32_t wait_state;                        // 等待状态
     *       struct proc_struct *cptr, *yptr, *optr;     // 进程之间的关系
     */
        proc->state        = PROC_UNINIT;
ffffffffc0204e72:	57fd                	li	a5,-1
ffffffffc0204e74:	1782                	slli	a5,a5,0x20
ffffffffc0204e76:	e11c                	sd	a5,0(a0)
        proc->runs         = 0; 
        proc->kstack       = 0;    
        proc->need_resched = 0;
        proc->parent       = NULL;
        proc->mm           = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204e78:	07000613          	li	a2,112
ffffffffc0204e7c:	4581                	li	a1,0
        proc->runs         = 0; 
ffffffffc0204e7e:	00052423          	sw	zero,8(a0)
        proc->kstack       = 0;    
ffffffffc0204e82:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204e86:	00053c23          	sd	zero,24(a0)
        proc->parent       = NULL;
ffffffffc0204e8a:	02053023          	sd	zero,32(a0)
        proc->mm           = NULL;
ffffffffc0204e8e:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204e92:	03050513          	addi	a0,a0,48
ffffffffc0204e96:	432010ef          	jal	ra,ffffffffc02062c8 <memset>
        proc->tf           = NULL;
        proc->cr3          = boot_cr3;
ffffffffc0204e9a:	000ae797          	auipc	a5,0xae
ffffffffc0204e9e:	9767b783          	ld	a5,-1674(a5) # ffffffffc02b2810 <boot_cr3>
        proc->tf           = NULL;
ffffffffc0204ea2:	0a043023          	sd	zero,160(s0)
        proc->cr3          = boot_cr3;
ffffffffc0204ea6:	f45c                	sd	a5,168(s0)
        proc->flags        = 0;
ffffffffc0204ea8:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, PROC_NAME_LEN+1);
ffffffffc0204eac:	4641                	li	a2,16
ffffffffc0204eae:	4581                	li	a1,0
ffffffffc0204eb0:	0b440513          	addi	a0,s0,180
ffffffffc0204eb4:	414010ef          	jal	ra,ffffffffc02062c8 <memset>

        proc->wait_state   = 0;
ffffffffc0204eb8:	0e042623          	sw	zero,236(s0)
        proc->cptr         = NULL;
ffffffffc0204ebc:	0e043823          	sd	zero,240(s0)
        proc->yptr         = NULL;
ffffffffc0204ec0:	0e043c23          	sd	zero,248(s0)
        proc->optr         = NULL;
ffffffffc0204ec4:	10043023          	sd	zero,256(s0)
    }
    return proc;
}
ffffffffc0204ec8:	60a2                	ld	ra,8(sp)
ffffffffc0204eca:	8522                	mv	a0,s0
ffffffffc0204ecc:	6402                	ld	s0,0(sp)
ffffffffc0204ece:	0141                	addi	sp,sp,16
ffffffffc0204ed0:	8082                	ret

ffffffffc0204ed2 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204ed2:	000ae797          	auipc	a5,0xae
ffffffffc0204ed6:	96e7b783          	ld	a5,-1682(a5) # ffffffffc02b2840 <current>
ffffffffc0204eda:	73c8                	ld	a0,160(a5)
ffffffffc0204edc:	e9bfb06f          	j	ffffffffc0200d76 <forkrets>

ffffffffc0204ee0 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204ee0:	000ae797          	auipc	a5,0xae
ffffffffc0204ee4:	9607b783          	ld	a5,-1696(a5) # ffffffffc02b2840 <current>
ffffffffc0204ee8:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204eea:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204eec:	00003617          	auipc	a2,0x3
ffffffffc0204ef0:	63c60613          	addi	a2,a2,1596 # ffffffffc0208528 <default_pmm_manager+0x5e0>
ffffffffc0204ef4:	00003517          	auipc	a0,0x3
ffffffffc0204ef8:	64450513          	addi	a0,a0,1604 # ffffffffc0208538 <default_pmm_manager+0x5f0>
user_main(void *arg) {
ffffffffc0204efc:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204efe:	9cefb0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0204f02:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204f06:	a6678793          	addi	a5,a5,-1434 # a968 <_binary_obj___user_forktest_out_size>
ffffffffc0204f0a:	e43e                	sd	a5,8(sp)
ffffffffc0204f0c:	00003517          	auipc	a0,0x3
ffffffffc0204f10:	61c50513          	addi	a0,a0,1564 # ffffffffc0208528 <default_pmm_manager+0x5e0>
ffffffffc0204f14:	0008e797          	auipc	a5,0x8e
ffffffffc0204f18:	c8478793          	addi	a5,a5,-892 # ffffffffc0292b98 <_binary_obj___user_forktest_out_start>
ffffffffc0204f1c:	f03e                	sd	a5,32(sp)
ffffffffc0204f1e:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204f20:	e802                	sd	zero,16(sp)
ffffffffc0204f22:	32a010ef          	jal	ra,ffffffffc020624c <strlen>
ffffffffc0204f26:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204f28:	4511                	li	a0,4
ffffffffc0204f2a:	55a2                	lw	a1,40(sp)
ffffffffc0204f2c:	4662                	lw	a2,24(sp)
ffffffffc0204f2e:	5682                	lw	a3,32(sp)
ffffffffc0204f30:	4722                	lw	a4,8(sp)
ffffffffc0204f32:	48a9                	li	a7,10
ffffffffc0204f34:	9002                	ebreak
ffffffffc0204f36:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204f38:	65c2                	ld	a1,16(sp)
ffffffffc0204f3a:	00003517          	auipc	a0,0x3
ffffffffc0204f3e:	62650513          	addi	a0,a0,1574 # ffffffffc0208560 <default_pmm_manager+0x618>
ffffffffc0204f42:	98afb0ef          	jal	ra,ffffffffc02000cc <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204f46:	00003617          	auipc	a2,0x3
ffffffffc0204f4a:	62a60613          	addi	a2,a2,1578 # ffffffffc0208570 <default_pmm_manager+0x628>
ffffffffc0204f4e:	35600593          	li	a1,854
ffffffffc0204f52:	00003517          	auipc	a0,0x3
ffffffffc0204f56:	63e50513          	addi	a0,a0,1598 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc0204f5a:	aaefb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204f5e <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204f5e:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204f60:	1141                	addi	sp,sp,-16
ffffffffc0204f62:	e406                	sd	ra,8(sp)
ffffffffc0204f64:	c02007b7          	lui	a5,0xc0200
ffffffffc0204f68:	02f6ee63          	bltu	a3,a5,ffffffffc0204fa4 <put_pgdir+0x46>
ffffffffc0204f6c:	000ae517          	auipc	a0,0xae
ffffffffc0204f70:	8cc53503          	ld	a0,-1844(a0) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0204f74:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204f76:	82b1                	srli	a3,a3,0xc
ffffffffc0204f78:	000ae797          	auipc	a5,0xae
ffffffffc0204f7c:	8a87b783          	ld	a5,-1880(a5) # ffffffffc02b2820 <npage>
ffffffffc0204f80:	02f6fe63          	bgeu	a3,a5,ffffffffc0204fbc <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204f84:	00004517          	auipc	a0,0x4
ffffffffc0204f88:	ec453503          	ld	a0,-316(a0) # ffffffffc0208e48 <nbase>
}
ffffffffc0204f8c:	60a2                	ld	ra,8(sp)
ffffffffc0204f8e:	8e89                	sub	a3,a3,a0
ffffffffc0204f90:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204f92:	000ae517          	auipc	a0,0xae
ffffffffc0204f96:	89653503          	ld	a0,-1898(a0) # ffffffffc02b2828 <pages>
ffffffffc0204f9a:	4585                	li	a1,1
ffffffffc0204f9c:	9536                	add	a0,a0,a3
}
ffffffffc0204f9e:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204fa0:	897fe06f          	j	ffffffffc0203836 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204fa4:	00003617          	auipc	a2,0x3
ffffffffc0204fa8:	87c60613          	addi	a2,a2,-1924 # ffffffffc0207820 <commands+0xe80>
ffffffffc0204fac:	06e00593          	li	a1,110
ffffffffc0204fb0:	00002517          	auipc	a0,0x2
ffffffffc0204fb4:	1a050513          	addi	a0,a0,416 # ffffffffc0207150 <commands+0x7b0>
ffffffffc0204fb8:	a50fb0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204fbc:	00002617          	auipc	a2,0x2
ffffffffc0204fc0:	1a460613          	addi	a2,a2,420 # ffffffffc0207160 <commands+0x7c0>
ffffffffc0204fc4:	06200593          	li	a1,98
ffffffffc0204fc8:	00002517          	auipc	a0,0x2
ffffffffc0204fcc:	18850513          	addi	a0,a0,392 # ffffffffc0207150 <commands+0x7b0>
ffffffffc0204fd0:	a38fb0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0204fd4 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204fd4:	7179                	addi	sp,sp,-48
ffffffffc0204fd6:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204fd8:	000ae917          	auipc	s2,0xae
ffffffffc0204fdc:	86890913          	addi	s2,s2,-1944 # ffffffffc02b2840 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204fe0:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204fe2:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204fe6:	f406                	sd	ra,40(sp)
ffffffffc0204fe8:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc0204fea:	02a48863          	beq	s1,a0,ffffffffc020501a <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204fee:	100027f3          	csrr	a5,sstatus
ffffffffc0204ff2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204ff4:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204ff6:	ef9d                	bnez	a5,ffffffffc0205034 <proc_run+0x60>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204ff8:	755c                	ld	a5,168(a0)
ffffffffc0204ffa:	577d                	li	a4,-1
ffffffffc0204ffc:	177e                	slli	a4,a4,0x3f
ffffffffc0204ffe:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0205000:	00a93023          	sd	a0,0(s2)
ffffffffc0205004:	8fd9                	or	a5,a5,a4
ffffffffc0205006:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc020500a:	03050593          	addi	a1,a0,48
ffffffffc020500e:	03048513          	addi	a0,s1,48
ffffffffc0205012:	dddff0ef          	jal	ra,ffffffffc0204dee <switch_to>
    if (flag) {
ffffffffc0205016:	00099863          	bnez	s3,ffffffffc0205026 <proc_run+0x52>
}
ffffffffc020501a:	70a2                	ld	ra,40(sp)
ffffffffc020501c:	7482                	ld	s1,32(sp)
ffffffffc020501e:	6962                	ld	s2,24(sp)
ffffffffc0205020:	69c2                	ld	s3,16(sp)
ffffffffc0205022:	6145                	addi	sp,sp,48
ffffffffc0205024:	8082                	ret
ffffffffc0205026:	70a2                	ld	ra,40(sp)
ffffffffc0205028:	7482                	ld	s1,32(sp)
ffffffffc020502a:	6962                	ld	s2,24(sp)
ffffffffc020502c:	69c2                	ld	s3,16(sp)
ffffffffc020502e:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0205030:	e12fb06f          	j	ffffffffc0200642 <intr_enable>
ffffffffc0205034:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205036:	e12fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc020503a:	6522                	ld	a0,8(sp)
ffffffffc020503c:	4985                	li	s3,1
ffffffffc020503e:	bf6d                	j	ffffffffc0204ff8 <proc_run+0x24>

ffffffffc0205040 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0205040:	7119                	addi	sp,sp,-128
ffffffffc0205042:	f0ca                	sd	s2,96(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0205044:	000ae917          	auipc	s2,0xae
ffffffffc0205048:	81490913          	addi	s2,s2,-2028 # ffffffffc02b2858 <nr_process>
ffffffffc020504c:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0205050:	fc86                	sd	ra,120(sp)
ffffffffc0205052:	f8a2                	sd	s0,112(sp)
ffffffffc0205054:	f4a6                	sd	s1,104(sp)
ffffffffc0205056:	ecce                	sd	s3,88(sp)
ffffffffc0205058:	e8d2                	sd	s4,80(sp)
ffffffffc020505a:	e4d6                	sd	s5,72(sp)
ffffffffc020505c:	e0da                	sd	s6,64(sp)
ffffffffc020505e:	fc5e                	sd	s7,56(sp)
ffffffffc0205060:	f862                	sd	s8,48(sp)
ffffffffc0205062:	f466                	sd	s9,40(sp)
ffffffffc0205064:	f06a                	sd	s10,32(sp)
ffffffffc0205066:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0205068:	6785                	lui	a5,0x1
ffffffffc020506a:	32f75b63          	bge	a4,a5,ffffffffc02053a0 <do_fork+0x360>
ffffffffc020506e:	8a2a                	mv	s4,a0
ffffffffc0205070:	89ae                	mv	s3,a1
ffffffffc0205072:	8432                	mv	s0,a2
    if((proc = alloc_proc()) == NULL) goto fork_out;
ffffffffc0205074:	dedff0ef          	jal	ra,ffffffffc0204e60 <alloc_proc>
ffffffffc0205078:	84aa                	mv	s1,a0
ffffffffc020507a:	30050463          	beqz	a0,ffffffffc0205382 <do_fork+0x342>
    proc->parent = current;
ffffffffc020507e:	000adc17          	auipc	s8,0xad
ffffffffc0205082:	7c2c0c13          	addi	s8,s8,1986 # ffffffffc02b2840 <current>
ffffffffc0205086:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0); // 更新步骤1：将子进程的父进程设置为当前进程，确保当前进程的wait_state为0
ffffffffc020508a:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8ac4>
    proc->parent = current;
ffffffffc020508e:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0); // 更新步骤1：将子进程的父进程设置为当前进程，确保当前进程的wait_state为0
ffffffffc0205090:	30071d63          	bnez	a4,ffffffffc02053aa <do_fork+0x36a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0205094:	4509                	li	a0,2
ffffffffc0205096:	f0efe0ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
    if (page != NULL) {
ffffffffc020509a:	2e050163          	beqz	a0,ffffffffc020537c <do_fork+0x33c>
    return page - pages + nbase;
ffffffffc020509e:	000ada97          	auipc	s5,0xad
ffffffffc02050a2:	78aa8a93          	addi	s5,s5,1930 # ffffffffc02b2828 <pages>
ffffffffc02050a6:	000ab683          	ld	a3,0(s5)
ffffffffc02050aa:	00004b17          	auipc	s6,0x4
ffffffffc02050ae:	d9eb0b13          	addi	s6,s6,-610 # ffffffffc0208e48 <nbase>
ffffffffc02050b2:	000b3783          	ld	a5,0(s6)
ffffffffc02050b6:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc02050ba:	000adb97          	auipc	s7,0xad
ffffffffc02050be:	766b8b93          	addi	s7,s7,1894 # ffffffffc02b2820 <npage>
    return page - pages + nbase;
ffffffffc02050c2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02050c4:	5dfd                	li	s11,-1
ffffffffc02050c6:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc02050ca:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02050cc:	00cddd93          	srli	s11,s11,0xc
ffffffffc02050d0:	01b6f633          	and	a2,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc02050d4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02050d6:	2ee67a63          	bgeu	a2,a4,ffffffffc02053ca <do_fork+0x38a>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc02050da:	000c3603          	ld	a2,0(s8)
ffffffffc02050de:	000adc17          	auipc	s8,0xad
ffffffffc02050e2:	75ac0c13          	addi	s8,s8,1882 # ffffffffc02b2838 <va_pa_offset>
ffffffffc02050e6:	000c3703          	ld	a4,0(s8)
ffffffffc02050ea:	02863d03          	ld	s10,40(a2)
ffffffffc02050ee:	e43e                	sd	a5,8(sp)
ffffffffc02050f0:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02050f2:	e894                	sd	a3,16(s1)
    if (oldmm == NULL) {
ffffffffc02050f4:	020d0863          	beqz	s10,ffffffffc0205124 <do_fork+0xe4>
    if (clone_flags & CLONE_VM) {
ffffffffc02050f8:	100a7a13          	andi	s4,s4,256
ffffffffc02050fc:	1c0a0163          	beqz	s4,ffffffffc02052be <do_fork+0x27e>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205100:	030d2703          	lw	a4,48(s10)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205104:	018d3783          	ld	a5,24(s10)
ffffffffc0205108:	c02006b7          	lui	a3,0xc0200
ffffffffc020510c:	2705                	addiw	a4,a4,1
ffffffffc020510e:	02ed2823          	sw	a4,48(s10)
    proc->mm = mm;
ffffffffc0205112:	03a4b423          	sd	s10,40(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205116:	2ed7e263          	bltu	a5,a3,ffffffffc02053fa <do_fork+0x3ba>
ffffffffc020511a:	000c3703          	ld	a4,0(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020511e:	6894                	ld	a3,16(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205120:	8f99                	sub	a5,a5,a4
ffffffffc0205122:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205124:	6789                	lui	a5,0x2
ffffffffc0205126:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd0>
ffffffffc020512a:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc020512c:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020512e:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc0205130:	87b6                	mv	a5,a3
ffffffffc0205132:	12040893          	addi	a7,s0,288
ffffffffc0205136:	00063803          	ld	a6,0(a2)
ffffffffc020513a:	6608                	ld	a0,8(a2)
ffffffffc020513c:	6a0c                	ld	a1,16(a2)
ffffffffc020513e:	6e18                	ld	a4,24(a2)
ffffffffc0205140:	0107b023          	sd	a6,0(a5)
ffffffffc0205144:	e788                	sd	a0,8(a5)
ffffffffc0205146:	eb8c                	sd	a1,16(a5)
ffffffffc0205148:	ef98                	sd	a4,24(a5)
ffffffffc020514a:	02060613          	addi	a2,a2,32
ffffffffc020514e:	02078793          	addi	a5,a5,32
ffffffffc0205152:	ff1612e3          	bne	a2,a7,ffffffffc0205136 <do_fork+0xf6>
    proc->tf->gpr.a0 = 0;
ffffffffc0205156:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020515a:	12098f63          	beqz	s3,ffffffffc0205298 <do_fork+0x258>
ffffffffc020515e:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205162:	00000797          	auipc	a5,0x0
ffffffffc0205166:	d7078793          	addi	a5,a5,-656 # ffffffffc0204ed2 <forkret>
ffffffffc020516a:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020516c:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020516e:	100027f3          	csrr	a5,sstatus
ffffffffc0205172:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205174:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205176:	14079063          	bnez	a5,ffffffffc02052b6 <do_fork+0x276>
    if (++ last_pid >= MAX_PID) {
ffffffffc020517a:	000a2817          	auipc	a6,0xa2
ffffffffc020517e:	17e80813          	addi	a6,a6,382 # ffffffffc02a72f8 <last_pid.1>
ffffffffc0205182:	00082783          	lw	a5,0(a6)
ffffffffc0205186:	6709                	lui	a4,0x2
ffffffffc0205188:	0017851b          	addiw	a0,a5,1
ffffffffc020518c:	00a82023          	sw	a0,0(a6)
ffffffffc0205190:	08e55d63          	bge	a0,a4,ffffffffc020522a <do_fork+0x1ea>
    if (last_pid >= next_safe) {
ffffffffc0205194:	000a2317          	auipc	t1,0xa2
ffffffffc0205198:	16830313          	addi	t1,t1,360 # ffffffffc02a72fc <next_safe.0>
ffffffffc020519c:	00032783          	lw	a5,0(t1)
ffffffffc02051a0:	000ad417          	auipc	s0,0xad
ffffffffc02051a4:	61840413          	addi	s0,s0,1560 # ffffffffc02b27b8 <proc_list>
ffffffffc02051a8:	08f55963          	bge	a0,a5,ffffffffc020523a <do_fork+0x1fa>
        proc->pid = get_pid();
ffffffffc02051ac:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02051ae:	45a9                	li	a1,10
ffffffffc02051b0:	2501                	sext.w	a0,a0
ffffffffc02051b2:	52e010ef          	jal	ra,ffffffffc02066e0 <hash32>
ffffffffc02051b6:	02051793          	slli	a5,a0,0x20
ffffffffc02051ba:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02051be:	000a9797          	auipc	a5,0xa9
ffffffffc02051c2:	5fa78793          	addi	a5,a5,1530 # ffffffffc02ae7b8 <hash_list>
ffffffffc02051c6:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02051c8:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051ca:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02051cc:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc02051d0:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02051d2:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc02051d4:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051d6:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02051d8:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc02051dc:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc02051de:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc02051e0:	e21c                	sd	a5,0(a2)
ffffffffc02051e2:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc02051e4:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc02051e6:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc02051e8:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051ec:	10e4b023          	sd	a4,256(s1)
ffffffffc02051f0:	c311                	beqz	a4,ffffffffc02051f4 <do_fork+0x1b4>
        proc->optr->yptr = proc;
ffffffffc02051f2:	ff64                	sd	s1,248(a4)
    nr_process ++;
ffffffffc02051f4:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc02051f8:	fae4                	sd	s1,240(a3)
    nr_process ++;
ffffffffc02051fa:	2785                	addiw	a5,a5,1
ffffffffc02051fc:	00f92023          	sw	a5,0(s2)
    if (flag) {
ffffffffc0205200:	18099363          	bnez	s3,ffffffffc0205386 <do_fork+0x346>
    wakeup_proc(proc);
ffffffffc0205204:	8526                	mv	a0,s1
ffffffffc0205206:	65b000ef          	jal	ra,ffffffffc0206060 <wakeup_proc>
    ret = proc->pid;
ffffffffc020520a:	40c8                	lw	a0,4(s1)
}
ffffffffc020520c:	70e6                	ld	ra,120(sp)
ffffffffc020520e:	7446                	ld	s0,112(sp)
ffffffffc0205210:	74a6                	ld	s1,104(sp)
ffffffffc0205212:	7906                	ld	s2,96(sp)
ffffffffc0205214:	69e6                	ld	s3,88(sp)
ffffffffc0205216:	6a46                	ld	s4,80(sp)
ffffffffc0205218:	6aa6                	ld	s5,72(sp)
ffffffffc020521a:	6b06                	ld	s6,64(sp)
ffffffffc020521c:	7be2                	ld	s7,56(sp)
ffffffffc020521e:	7c42                	ld	s8,48(sp)
ffffffffc0205220:	7ca2                	ld	s9,40(sp)
ffffffffc0205222:	7d02                	ld	s10,32(sp)
ffffffffc0205224:	6de2                	ld	s11,24(sp)
ffffffffc0205226:	6109                	addi	sp,sp,128
ffffffffc0205228:	8082                	ret
        last_pid = 1;
ffffffffc020522a:	4785                	li	a5,1
ffffffffc020522c:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0205230:	4505                	li	a0,1
ffffffffc0205232:	000a2317          	auipc	t1,0xa2
ffffffffc0205236:	0ca30313          	addi	t1,t1,202 # ffffffffc02a72fc <next_safe.0>
    return listelm->next;
ffffffffc020523a:	000ad417          	auipc	s0,0xad
ffffffffc020523e:	57e40413          	addi	s0,s0,1406 # ffffffffc02b27b8 <proc_list>
ffffffffc0205242:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc0205246:	6789                	lui	a5,0x2
ffffffffc0205248:	00f32023          	sw	a5,0(t1)
ffffffffc020524c:	86aa                	mv	a3,a0
ffffffffc020524e:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc0205250:	6e89                	lui	t4,0x2
ffffffffc0205252:	148e0263          	beq	t3,s0,ffffffffc0205396 <do_fork+0x356>
ffffffffc0205256:	88ae                	mv	a7,a1
ffffffffc0205258:	87f2                	mv	a5,t3
ffffffffc020525a:	6609                	lui	a2,0x2
ffffffffc020525c:	a811                	j	ffffffffc0205270 <do_fork+0x230>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc020525e:	00e6d663          	bge	a3,a4,ffffffffc020526a <do_fork+0x22a>
ffffffffc0205262:	00c75463          	bge	a4,a2,ffffffffc020526a <do_fork+0x22a>
ffffffffc0205266:	863a                	mv	a2,a4
ffffffffc0205268:	4885                	li	a7,1
ffffffffc020526a:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020526c:	00878d63          	beq	a5,s0,ffffffffc0205286 <do_fork+0x246>
            if (proc->pid == last_pid) {
ffffffffc0205270:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c74>
ffffffffc0205274:	fed715e3          	bne	a4,a3,ffffffffc020525e <do_fork+0x21e>
                if (++ last_pid >= next_safe) {
ffffffffc0205278:	2685                	addiw	a3,a3,1
ffffffffc020527a:	10c6d963          	bge	a3,a2,ffffffffc020538c <do_fork+0x34c>
ffffffffc020527e:	679c                	ld	a5,8(a5)
ffffffffc0205280:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc0205282:	fe8797e3          	bne	a5,s0,ffffffffc0205270 <do_fork+0x230>
ffffffffc0205286:	c581                	beqz	a1,ffffffffc020528e <do_fork+0x24e>
ffffffffc0205288:	00d82023          	sw	a3,0(a6)
ffffffffc020528c:	8536                	mv	a0,a3
ffffffffc020528e:	f0088fe3          	beqz	a7,ffffffffc02051ac <do_fork+0x16c>
ffffffffc0205292:	00c32023          	sw	a2,0(t1)
ffffffffc0205296:	bf19                	j	ffffffffc02051ac <do_fork+0x16c>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205298:	89b6                	mv	s3,a3
ffffffffc020529a:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020529e:	00000797          	auipc	a5,0x0
ffffffffc02052a2:	c3478793          	addi	a5,a5,-972 # ffffffffc0204ed2 <forkret>
ffffffffc02052a6:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02052a8:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02052aa:	100027f3          	csrr	a5,sstatus
ffffffffc02052ae:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02052b0:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02052b2:	ec0784e3          	beqz	a5,ffffffffc020517a <do_fork+0x13a>
        intr_disable();
ffffffffc02052b6:	b92fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc02052ba:	4985                	li	s3,1
ffffffffc02052bc:	bd7d                	j	ffffffffc020517a <do_fork+0x13a>
    if ((mm = mm_create()) == NULL) {
ffffffffc02052be:	eb5fb0ef          	jal	ra,ffffffffc0201172 <mm_create>
ffffffffc02052c2:	8caa                	mv	s9,a0
ffffffffc02052c4:	c541                	beqz	a0,ffffffffc020534c <do_fork+0x30c>
    if ((page = alloc_page()) == NULL) {
ffffffffc02052c6:	4505                	li	a0,1
ffffffffc02052c8:	cdcfe0ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc02052cc:	cd2d                	beqz	a0,ffffffffc0205346 <do_fork+0x306>
    return page - pages + nbase;
ffffffffc02052ce:	000ab683          	ld	a3,0(s5)
ffffffffc02052d2:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc02052d4:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc02052d8:	40d506b3          	sub	a3,a0,a3
ffffffffc02052dc:	8699                	srai	a3,a3,0x6
ffffffffc02052de:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02052e0:	01b6fdb3          	and	s11,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc02052e4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02052e6:	0eedf263          	bgeu	s11,a4,ffffffffc02053ca <do_fork+0x38a>
ffffffffc02052ea:	000c3a03          	ld	s4,0(s8)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc02052ee:	6605                	lui	a2,0x1
ffffffffc02052f0:	000ad597          	auipc	a1,0xad
ffffffffc02052f4:	5285b583          	ld	a1,1320(a1) # ffffffffc02b2818 <boot_pgdir>
ffffffffc02052f8:	9a36                	add	s4,s4,a3
ffffffffc02052fa:	8552                	mv	a0,s4
ffffffffc02052fc:	7df000ef          	jal	ra,ffffffffc02062da <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0205300:	038d0d93          	addi	s11,s10,56
    mm->pgdir = pgdir;
ffffffffc0205304:	014cbc23          	sd	s4,24(s9)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0205308:	4785                	li	a5,1
ffffffffc020530a:	40fdb7af          	amoor.d	a5,a5,(s11)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc020530e:	8b85                	andi	a5,a5,1
ffffffffc0205310:	4a05                	li	s4,1
ffffffffc0205312:	c799                	beqz	a5,ffffffffc0205320 <do_fork+0x2e0>
        schedule();
ffffffffc0205314:	5cd000ef          	jal	ra,ffffffffc02060e0 <schedule>
ffffffffc0205318:	414db7af          	amoor.d	a5,s4,(s11)
    while (!try_lock(lock)) {
ffffffffc020531c:	8b85                	andi	a5,a5,1
ffffffffc020531e:	fbfd                	bnez	a5,ffffffffc0205314 <do_fork+0x2d4>
        ret = dup_mmap(mm, oldmm);
ffffffffc0205320:	85ea                	mv	a1,s10
ffffffffc0205322:	8566                	mv	a0,s9
ffffffffc0205324:	8d6fc0ef          	jal	ra,ffffffffc02013fa <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0205328:	57f9                	li	a5,-2
ffffffffc020532a:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc020532e:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0205330:	0e078e63          	beqz	a5,ffffffffc020542c <do_fork+0x3ec>
good_mm:
ffffffffc0205334:	8d66                	mv	s10,s9
    if (ret != 0) {
ffffffffc0205336:	dc0505e3          	beqz	a0,ffffffffc0205100 <do_fork+0xc0>
    exit_mmap(mm);
ffffffffc020533a:	8566                	mv	a0,s9
ffffffffc020533c:	958fc0ef          	jal	ra,ffffffffc0201494 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205340:	8566                	mv	a0,s9
ffffffffc0205342:	c1dff0ef          	jal	ra,ffffffffc0204f5e <put_pgdir>
    mm_destroy(mm);
ffffffffc0205346:	8566                	mv	a0,s9
ffffffffc0205348:	fb1fb0ef          	jal	ra,ffffffffc02012f8 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020534c:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc020534e:	c02007b7          	lui	a5,0xc0200
ffffffffc0205352:	0cf6e163          	bltu	a3,a5,ffffffffc0205414 <do_fork+0x3d4>
ffffffffc0205356:	000c3783          	ld	a5,0(s8)
    if (PPN(pa) >= npage) {
ffffffffc020535a:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc020535e:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205362:	83b1                	srli	a5,a5,0xc
ffffffffc0205364:	06e7ff63          	bgeu	a5,a4,ffffffffc02053e2 <do_fork+0x3a2>
    return &pages[PPN(pa) - nbase];
ffffffffc0205368:	000b3703          	ld	a4,0(s6)
ffffffffc020536c:	000ab503          	ld	a0,0(s5)
ffffffffc0205370:	4589                	li	a1,2
ffffffffc0205372:	8f99                	sub	a5,a5,a4
ffffffffc0205374:	079a                	slli	a5,a5,0x6
ffffffffc0205376:	953e                	add	a0,a0,a5
ffffffffc0205378:	cbefe0ef          	jal	ra,ffffffffc0203836 <free_pages>
    kfree(proc);
ffffffffc020537c:	8526                	mv	a0,s1
ffffffffc020537e:	f3ffc0ef          	jal	ra,ffffffffc02022bc <kfree>
    ret = -E_NO_MEM;
ffffffffc0205382:	5571                	li	a0,-4
    return ret;
ffffffffc0205384:	b561                	j	ffffffffc020520c <do_fork+0x1cc>
        intr_enable();
ffffffffc0205386:	abcfb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020538a:	bdad                	j	ffffffffc0205204 <do_fork+0x1c4>
                    if (last_pid >= MAX_PID) {
ffffffffc020538c:	01d6c363          	blt	a3,t4,ffffffffc0205392 <do_fork+0x352>
                        last_pid = 1;
ffffffffc0205390:	4685                	li	a3,1
                    goto repeat;
ffffffffc0205392:	4585                	li	a1,1
ffffffffc0205394:	bd7d                	j	ffffffffc0205252 <do_fork+0x212>
ffffffffc0205396:	c599                	beqz	a1,ffffffffc02053a4 <do_fork+0x364>
ffffffffc0205398:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc020539c:	8536                	mv	a0,a3
ffffffffc020539e:	b539                	j	ffffffffc02051ac <do_fork+0x16c>
    int ret = -E_NO_FREE_PROC;
ffffffffc02053a0:	556d                	li	a0,-5
ffffffffc02053a2:	b5ad                	j	ffffffffc020520c <do_fork+0x1cc>
    return last_pid;
ffffffffc02053a4:	00082503          	lw	a0,0(a6)
ffffffffc02053a8:	b511                	j	ffffffffc02051ac <do_fork+0x16c>
    assert(current->wait_state == 0); // 更新步骤1：将子进程的父进程设置为当前进程，确保当前进程的wait_state为0
ffffffffc02053aa:	00003697          	auipc	a3,0x3
ffffffffc02053ae:	1fe68693          	addi	a3,a3,510 # ffffffffc02085a8 <default_pmm_manager+0x660>
ffffffffc02053b2:	00002617          	auipc	a2,0x2
ffffffffc02053b6:	9fe60613          	addi	a2,a2,-1538 # ffffffffc0206db0 <commands+0x410>
ffffffffc02053ba:	1ba00593          	li	a1,442
ffffffffc02053be:	00003517          	auipc	a0,0x3
ffffffffc02053c2:	1d250513          	addi	a0,a0,466 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc02053c6:	e43fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    return KADDR(page2pa(page));
ffffffffc02053ca:	00002617          	auipc	a2,0x2
ffffffffc02053ce:	e1e60613          	addi	a2,a2,-482 # ffffffffc02071e8 <commands+0x848>
ffffffffc02053d2:	06900593          	li	a1,105
ffffffffc02053d6:	00002517          	auipc	a0,0x2
ffffffffc02053da:	d7a50513          	addi	a0,a0,-646 # ffffffffc0207150 <commands+0x7b0>
ffffffffc02053de:	e2bfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02053e2:	00002617          	auipc	a2,0x2
ffffffffc02053e6:	d7e60613          	addi	a2,a2,-642 # ffffffffc0207160 <commands+0x7c0>
ffffffffc02053ea:	06200593          	li	a1,98
ffffffffc02053ee:	00002517          	auipc	a0,0x2
ffffffffc02053f2:	d6250513          	addi	a0,a0,-670 # ffffffffc0207150 <commands+0x7b0>
ffffffffc02053f6:	e13fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02053fa:	86be                	mv	a3,a5
ffffffffc02053fc:	00002617          	auipc	a2,0x2
ffffffffc0205400:	42460613          	addi	a2,a2,1060 # ffffffffc0207820 <commands+0xe80>
ffffffffc0205404:	16900593          	li	a1,361
ffffffffc0205408:	00003517          	auipc	a0,0x3
ffffffffc020540c:	18850513          	addi	a0,a0,392 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc0205410:	df9fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205414:	00002617          	auipc	a2,0x2
ffffffffc0205418:	40c60613          	addi	a2,a2,1036 # ffffffffc0207820 <commands+0xe80>
ffffffffc020541c:	06e00593          	li	a1,110
ffffffffc0205420:	00002517          	auipc	a0,0x2
ffffffffc0205424:	d3050513          	addi	a0,a0,-720 # ffffffffc0207150 <commands+0x7b0>
ffffffffc0205428:	de1fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("Unlock failed.\n");
ffffffffc020542c:	00003617          	auipc	a2,0x3
ffffffffc0205430:	19c60613          	addi	a2,a2,412 # ffffffffc02085c8 <default_pmm_manager+0x680>
ffffffffc0205434:	03100593          	li	a1,49
ffffffffc0205438:	00003517          	auipc	a0,0x3
ffffffffc020543c:	1a050513          	addi	a0,a0,416 # ffffffffc02085d8 <default_pmm_manager+0x690>
ffffffffc0205440:	dc9fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205444 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205444:	7129                	addi	sp,sp,-320
ffffffffc0205446:	fa22                	sd	s0,304(sp)
ffffffffc0205448:	f626                	sd	s1,296(sp)
ffffffffc020544a:	f24a                	sd	s2,288(sp)
ffffffffc020544c:	84ae                	mv	s1,a1
ffffffffc020544e:	892a                	mv	s2,a0
ffffffffc0205450:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205452:	4581                	li	a1,0
ffffffffc0205454:	12000613          	li	a2,288
ffffffffc0205458:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020545a:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020545c:	66d000ef          	jal	ra,ffffffffc02062c8 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205460:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205462:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205464:	100027f3          	csrr	a5,sstatus
ffffffffc0205468:	edd7f793          	andi	a5,a5,-291
ffffffffc020546c:	1207e793          	ori	a5,a5,288
ffffffffc0205470:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205472:	860a                	mv	a2,sp
ffffffffc0205474:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205478:	00000797          	auipc	a5,0x0
ffffffffc020547c:	9e078793          	addi	a5,a5,-1568 # ffffffffc0204e58 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205480:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205482:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205484:	bbdff0ef          	jal	ra,ffffffffc0205040 <do_fork>
}
ffffffffc0205488:	70f2                	ld	ra,312(sp)
ffffffffc020548a:	7452                	ld	s0,304(sp)
ffffffffc020548c:	74b2                	ld	s1,296(sp)
ffffffffc020548e:	7912                	ld	s2,288(sp)
ffffffffc0205490:	6131                	addi	sp,sp,320
ffffffffc0205492:	8082                	ret

ffffffffc0205494 <do_exit>:
do_exit(int error_code) {
ffffffffc0205494:	7179                	addi	sp,sp,-48
ffffffffc0205496:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc0205498:	000ad417          	auipc	s0,0xad
ffffffffc020549c:	3a840413          	addi	s0,s0,936 # ffffffffc02b2840 <current>
ffffffffc02054a0:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc02054a2:	f406                	sd	ra,40(sp)
ffffffffc02054a4:	ec26                	sd	s1,24(sp)
ffffffffc02054a6:	e84a                	sd	s2,16(sp)
ffffffffc02054a8:	e44e                	sd	s3,8(sp)
ffffffffc02054aa:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc02054ac:	000ad717          	auipc	a4,0xad
ffffffffc02054b0:	39c73703          	ld	a4,924(a4) # ffffffffc02b2848 <idleproc>
ffffffffc02054b4:	0ce78c63          	beq	a5,a4,ffffffffc020558c <do_exit+0xf8>
    if (current == initproc) {
ffffffffc02054b8:	000ad497          	auipc	s1,0xad
ffffffffc02054bc:	39848493          	addi	s1,s1,920 # ffffffffc02b2850 <initproc>
ffffffffc02054c0:	6098                	ld	a4,0(s1)
ffffffffc02054c2:	0ee78b63          	beq	a5,a4,ffffffffc02055b8 <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc02054c6:	0287b983          	ld	s3,40(a5)
ffffffffc02054ca:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc02054cc:	02098663          	beqz	s3,ffffffffc02054f8 <do_exit+0x64>
ffffffffc02054d0:	000ad797          	auipc	a5,0xad
ffffffffc02054d4:	3407b783          	ld	a5,832(a5) # ffffffffc02b2810 <boot_cr3>
ffffffffc02054d8:	577d                	li	a4,-1
ffffffffc02054da:	177e                	slli	a4,a4,0x3f
ffffffffc02054dc:	83b1                	srli	a5,a5,0xc
ffffffffc02054de:	8fd9                	or	a5,a5,a4
ffffffffc02054e0:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02054e4:	0309a783          	lw	a5,48(s3)
ffffffffc02054e8:	fff7871b          	addiw	a4,a5,-1
ffffffffc02054ec:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc02054f0:	cb55                	beqz	a4,ffffffffc02055a4 <do_exit+0x110>
        current->mm = NULL;
ffffffffc02054f2:	601c                	ld	a5,0(s0)
ffffffffc02054f4:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02054f8:	601c                	ld	a5,0(s0)
ffffffffc02054fa:	470d                	li	a4,3
ffffffffc02054fc:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc02054fe:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205502:	100027f3          	csrr	a5,sstatus
ffffffffc0205506:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205508:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020550a:	e3f9                	bnez	a5,ffffffffc02055d0 <do_exit+0x13c>
        proc = current->parent;
ffffffffc020550c:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc020550e:	800007b7          	lui	a5,0x80000
ffffffffc0205512:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0205514:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205516:	0ec52703          	lw	a4,236(a0)
ffffffffc020551a:	0af70f63          	beq	a4,a5,ffffffffc02055d8 <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc020551e:	6018                	ld	a4,0(s0)
ffffffffc0205520:	7b7c                	ld	a5,240(a4)
ffffffffc0205522:	c3a1                	beqz	a5,ffffffffc0205562 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205524:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205528:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020552a:	0985                	addi	s3,s3,1
ffffffffc020552c:	a021                	j	ffffffffc0205534 <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc020552e:	6018                	ld	a4,0(s0)
ffffffffc0205530:	7b7c                	ld	a5,240(a4)
ffffffffc0205532:	cb85                	beqz	a5,ffffffffc0205562 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc0205534:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fe0>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205538:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc020553a:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020553c:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc020553e:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205542:	10e7b023          	sd	a4,256(a5)
ffffffffc0205546:	c311                	beqz	a4,ffffffffc020554a <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc0205548:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020554a:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc020554c:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc020554e:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205550:	fd271fe3          	bne	a4,s2,ffffffffc020552e <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205554:	0ec52783          	lw	a5,236(a0)
ffffffffc0205558:	fd379be3          	bne	a5,s3,ffffffffc020552e <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc020555c:	305000ef          	jal	ra,ffffffffc0206060 <wakeup_proc>
ffffffffc0205560:	b7f9                	j	ffffffffc020552e <do_exit+0x9a>
    if (flag) {
ffffffffc0205562:	020a1263          	bnez	s4,ffffffffc0205586 <do_exit+0xf2>
    schedule();
ffffffffc0205566:	37b000ef          	jal	ra,ffffffffc02060e0 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc020556a:	601c                	ld	a5,0(s0)
ffffffffc020556c:	00003617          	auipc	a2,0x3
ffffffffc0205570:	0a460613          	addi	a2,a2,164 # ffffffffc0208610 <default_pmm_manager+0x6c8>
ffffffffc0205574:	20700593          	li	a1,519
ffffffffc0205578:	43d4                	lw	a3,4(a5)
ffffffffc020557a:	00003517          	auipc	a0,0x3
ffffffffc020557e:	01650513          	addi	a0,a0,22 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc0205582:	c87fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_enable();
ffffffffc0205586:	8bcfb0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc020558a:	bff1                	j	ffffffffc0205566 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc020558c:	00003617          	auipc	a2,0x3
ffffffffc0205590:	06460613          	addi	a2,a2,100 # ffffffffc02085f0 <default_pmm_manager+0x6a8>
ffffffffc0205594:	1db00593          	li	a1,475
ffffffffc0205598:	00003517          	auipc	a0,0x3
ffffffffc020559c:	ff850513          	addi	a0,a0,-8 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc02055a0:	c69fa0ef          	jal	ra,ffffffffc0200208 <__panic>
            exit_mmap(mm);
ffffffffc02055a4:	854e                	mv	a0,s3
ffffffffc02055a6:	eeffb0ef          	jal	ra,ffffffffc0201494 <exit_mmap>
            put_pgdir(mm);
ffffffffc02055aa:	854e                	mv	a0,s3
ffffffffc02055ac:	9b3ff0ef          	jal	ra,ffffffffc0204f5e <put_pgdir>
            mm_destroy(mm);
ffffffffc02055b0:	854e                	mv	a0,s3
ffffffffc02055b2:	d47fb0ef          	jal	ra,ffffffffc02012f8 <mm_destroy>
ffffffffc02055b6:	bf35                	j	ffffffffc02054f2 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc02055b8:	00003617          	auipc	a2,0x3
ffffffffc02055bc:	04860613          	addi	a2,a2,72 # ffffffffc0208600 <default_pmm_manager+0x6b8>
ffffffffc02055c0:	1de00593          	li	a1,478
ffffffffc02055c4:	00003517          	auipc	a0,0x3
ffffffffc02055c8:	fcc50513          	addi	a0,a0,-52 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc02055cc:	c3dfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        intr_disable();
ffffffffc02055d0:	878fb0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc02055d4:	4a05                	li	s4,1
ffffffffc02055d6:	bf1d                	j	ffffffffc020550c <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc02055d8:	289000ef          	jal	ra,ffffffffc0206060 <wakeup_proc>
ffffffffc02055dc:	b789                	j	ffffffffc020551e <do_exit+0x8a>

ffffffffc02055de <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc02055de:	715d                	addi	sp,sp,-80
ffffffffc02055e0:	f84a                	sd	s2,48(sp)
ffffffffc02055e2:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc02055e4:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc02055e8:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc02055ea:	fc26                	sd	s1,56(sp)
ffffffffc02055ec:	f052                	sd	s4,32(sp)
ffffffffc02055ee:	ec56                	sd	s5,24(sp)
ffffffffc02055f0:	e85a                	sd	s6,16(sp)
ffffffffc02055f2:	e45e                	sd	s7,8(sp)
ffffffffc02055f4:	e486                	sd	ra,72(sp)
ffffffffc02055f6:	e0a2                	sd	s0,64(sp)
ffffffffc02055f8:	84aa                	mv	s1,a0
ffffffffc02055fa:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc02055fc:	000adb97          	auipc	s7,0xad
ffffffffc0205600:	244b8b93          	addi	s7,s7,580 # ffffffffc02b2840 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205604:	00050b1b          	sext.w	s6,a0
ffffffffc0205608:	fff50a9b          	addiw	s5,a0,-1
ffffffffc020560c:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc020560e:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc0205610:	ccbd                	beqz	s1,ffffffffc020568e <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205612:	0359e863          	bltu	s3,s5,ffffffffc0205642 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205616:	45a9                	li	a1,10
ffffffffc0205618:	855a                	mv	a0,s6
ffffffffc020561a:	0c6010ef          	jal	ra,ffffffffc02066e0 <hash32>
ffffffffc020561e:	02051793          	slli	a5,a0,0x20
ffffffffc0205622:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205626:	000a9797          	auipc	a5,0xa9
ffffffffc020562a:	19278793          	addi	a5,a5,402 # ffffffffc02ae7b8 <hash_list>
ffffffffc020562e:	953e                	add	a0,a0,a5
ffffffffc0205630:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205632:	a029                	j	ffffffffc020563c <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc0205634:	f2c42783          	lw	a5,-212(s0)
ffffffffc0205638:	02978163          	beq	a5,s1,ffffffffc020565a <do_wait.part.0+0x7c>
ffffffffc020563c:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc020563e:	fe851be3          	bne	a0,s0,ffffffffc0205634 <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc0205642:	5579                	li	a0,-2
}
ffffffffc0205644:	60a6                	ld	ra,72(sp)
ffffffffc0205646:	6406                	ld	s0,64(sp)
ffffffffc0205648:	74e2                	ld	s1,56(sp)
ffffffffc020564a:	7942                	ld	s2,48(sp)
ffffffffc020564c:	79a2                	ld	s3,40(sp)
ffffffffc020564e:	7a02                	ld	s4,32(sp)
ffffffffc0205650:	6ae2                	ld	s5,24(sp)
ffffffffc0205652:	6b42                	ld	s6,16(sp)
ffffffffc0205654:	6ba2                	ld	s7,8(sp)
ffffffffc0205656:	6161                	addi	sp,sp,80
ffffffffc0205658:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc020565a:	000bb683          	ld	a3,0(s7)
ffffffffc020565e:	f4843783          	ld	a5,-184(s0)
ffffffffc0205662:	fed790e3          	bne	a5,a3,ffffffffc0205642 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205666:	f2842703          	lw	a4,-216(s0)
ffffffffc020566a:	478d                	li	a5,3
ffffffffc020566c:	0ef70b63          	beq	a4,a5,ffffffffc0205762 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc0205670:	4785                	li	a5,1
ffffffffc0205672:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc0205674:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc0205678:	269000ef          	jal	ra,ffffffffc02060e0 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc020567c:	000bb783          	ld	a5,0(s7)
ffffffffc0205680:	0b07a783          	lw	a5,176(a5)
ffffffffc0205684:	8b85                	andi	a5,a5,1
ffffffffc0205686:	d7c9                	beqz	a5,ffffffffc0205610 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc0205688:	555d                	li	a0,-9
ffffffffc020568a:	e0bff0ef          	jal	ra,ffffffffc0205494 <do_exit>
        proc = current->cptr;
ffffffffc020568e:	000bb683          	ld	a3,0(s7)
ffffffffc0205692:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205694:	d45d                	beqz	s0,ffffffffc0205642 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205696:	470d                	li	a4,3
ffffffffc0205698:	a021                	j	ffffffffc02056a0 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc020569a:	10043403          	ld	s0,256(s0)
ffffffffc020569e:	d869                	beqz	s0,ffffffffc0205670 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02056a0:	401c                	lw	a5,0(s0)
ffffffffc02056a2:	fee79ce3          	bne	a5,a4,ffffffffc020569a <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc02056a6:	000ad797          	auipc	a5,0xad
ffffffffc02056aa:	1a27b783          	ld	a5,418(a5) # ffffffffc02b2848 <idleproc>
ffffffffc02056ae:	0c878963          	beq	a5,s0,ffffffffc0205780 <do_wait.part.0+0x1a2>
ffffffffc02056b2:	000ad797          	auipc	a5,0xad
ffffffffc02056b6:	19e7b783          	ld	a5,414(a5) # ffffffffc02b2850 <initproc>
ffffffffc02056ba:	0cf40363          	beq	s0,a5,ffffffffc0205780 <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc02056be:	000a0663          	beqz	s4,ffffffffc02056ca <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc02056c2:	0e842783          	lw	a5,232(s0)
ffffffffc02056c6:	00fa2023          	sw	a5,0(s4)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02056ca:	100027f3          	csrr	a5,sstatus
ffffffffc02056ce:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02056d0:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02056d2:	e7c1                	bnez	a5,ffffffffc020575a <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02056d4:	6c70                	ld	a2,216(s0)
ffffffffc02056d6:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc02056d8:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc02056dc:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02056de:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02056e0:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02056e2:	6470                	ld	a2,200(s0)
ffffffffc02056e4:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02056e6:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02056e8:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc02056ea:	c319                	beqz	a4,ffffffffc02056f0 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc02056ec:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc02056ee:	7c7c                	ld	a5,248(s0)
ffffffffc02056f0:	c3b5                	beqz	a5,ffffffffc0205754 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc02056f2:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc02056f6:	000ad717          	auipc	a4,0xad
ffffffffc02056fa:	16270713          	addi	a4,a4,354 # ffffffffc02b2858 <nr_process>
ffffffffc02056fe:	431c                	lw	a5,0(a4)
ffffffffc0205700:	37fd                	addiw	a5,a5,-1
ffffffffc0205702:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc0205704:	e5a9                	bnez	a1,ffffffffc020574e <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205706:	6814                	ld	a3,16(s0)
ffffffffc0205708:	c02007b7          	lui	a5,0xc0200
ffffffffc020570c:	04f6ee63          	bltu	a3,a5,ffffffffc0205768 <do_wait.part.0+0x18a>
ffffffffc0205710:	000ad797          	auipc	a5,0xad
ffffffffc0205714:	1287b783          	ld	a5,296(a5) # ffffffffc02b2838 <va_pa_offset>
ffffffffc0205718:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc020571a:	82b1                	srli	a3,a3,0xc
ffffffffc020571c:	000ad797          	auipc	a5,0xad
ffffffffc0205720:	1047b783          	ld	a5,260(a5) # ffffffffc02b2820 <npage>
ffffffffc0205724:	06f6fa63          	bgeu	a3,a5,ffffffffc0205798 <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0205728:	00003517          	auipc	a0,0x3
ffffffffc020572c:	72053503          	ld	a0,1824(a0) # ffffffffc0208e48 <nbase>
ffffffffc0205730:	8e89                	sub	a3,a3,a0
ffffffffc0205732:	069a                	slli	a3,a3,0x6
ffffffffc0205734:	000ad517          	auipc	a0,0xad
ffffffffc0205738:	0f453503          	ld	a0,244(a0) # ffffffffc02b2828 <pages>
ffffffffc020573c:	9536                	add	a0,a0,a3
ffffffffc020573e:	4589                	li	a1,2
ffffffffc0205740:	8f6fe0ef          	jal	ra,ffffffffc0203836 <free_pages>
    kfree(proc);
ffffffffc0205744:	8522                	mv	a0,s0
ffffffffc0205746:	b77fc0ef          	jal	ra,ffffffffc02022bc <kfree>
    return 0;
ffffffffc020574a:	4501                	li	a0,0
ffffffffc020574c:	bde5                	j	ffffffffc0205644 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc020574e:	ef5fa0ef          	jal	ra,ffffffffc0200642 <intr_enable>
ffffffffc0205752:	bf55                	j	ffffffffc0205706 <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc0205754:	701c                	ld	a5,32(s0)
ffffffffc0205756:	fbf8                	sd	a4,240(a5)
ffffffffc0205758:	bf79                	j	ffffffffc02056f6 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc020575a:	eeffa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc020575e:	4585                	li	a1,1
ffffffffc0205760:	bf95                	j	ffffffffc02056d4 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205762:	f2840413          	addi	s0,s0,-216
ffffffffc0205766:	b781                	j	ffffffffc02056a6 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc0205768:	00002617          	auipc	a2,0x2
ffffffffc020576c:	0b860613          	addi	a2,a2,184 # ffffffffc0207820 <commands+0xe80>
ffffffffc0205770:	06e00593          	li	a1,110
ffffffffc0205774:	00002517          	auipc	a0,0x2
ffffffffc0205778:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0207150 <commands+0x7b0>
ffffffffc020577c:	a8dfa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc0205780:	00003617          	auipc	a2,0x3
ffffffffc0205784:	eb060613          	addi	a2,a2,-336 # ffffffffc0208630 <default_pmm_manager+0x6e8>
ffffffffc0205788:	30400593          	li	a1,772
ffffffffc020578c:	00003517          	auipc	a0,0x3
ffffffffc0205790:	e0450513          	addi	a0,a0,-508 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc0205794:	a75fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205798:	00002617          	auipc	a2,0x2
ffffffffc020579c:	9c860613          	addi	a2,a2,-1592 # ffffffffc0207160 <commands+0x7c0>
ffffffffc02057a0:	06200593          	li	a1,98
ffffffffc02057a4:	00002517          	auipc	a0,0x2
ffffffffc02057a8:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0207150 <commands+0x7b0>
ffffffffc02057ac:	a5dfa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02057b0 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02057b0:	1141                	addi	sp,sp,-16
ffffffffc02057b2:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02057b4:	8c2fe0ef          	jal	ra,ffffffffc0203876 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02057b8:	a51fc0ef          	jal	ra,ffffffffc0202208 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02057bc:	4601                	li	a2,0
ffffffffc02057be:	4581                	li	a1,0
ffffffffc02057c0:	fffff517          	auipc	a0,0xfffff
ffffffffc02057c4:	72050513          	addi	a0,a0,1824 # ffffffffc0204ee0 <user_main>
ffffffffc02057c8:	c7dff0ef          	jal	ra,ffffffffc0205444 <kernel_thread>
    if (pid <= 0) {
ffffffffc02057cc:	00a04563          	bgtz	a0,ffffffffc02057d6 <init_main+0x26>
ffffffffc02057d0:	a071                	j	ffffffffc020585c <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc02057d2:	10f000ef          	jal	ra,ffffffffc02060e0 <schedule>
    if (code_store != NULL) {
ffffffffc02057d6:	4581                	li	a1,0
ffffffffc02057d8:	4501                	li	a0,0
ffffffffc02057da:	e05ff0ef          	jal	ra,ffffffffc02055de <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc02057de:	d975                	beqz	a0,ffffffffc02057d2 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02057e0:	00003517          	auipc	a0,0x3
ffffffffc02057e4:	e9050513          	addi	a0,a0,-368 # ffffffffc0208670 <default_pmm_manager+0x728>
ffffffffc02057e8:	8e5fa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02057ec:	000ad797          	auipc	a5,0xad
ffffffffc02057f0:	0647b783          	ld	a5,100(a5) # ffffffffc02b2850 <initproc>
ffffffffc02057f4:	7bf8                	ld	a4,240(a5)
ffffffffc02057f6:	e339                	bnez	a4,ffffffffc020583c <init_main+0x8c>
ffffffffc02057f8:	7ff8                	ld	a4,248(a5)
ffffffffc02057fa:	e329                	bnez	a4,ffffffffc020583c <init_main+0x8c>
ffffffffc02057fc:	1007b703          	ld	a4,256(a5)
ffffffffc0205800:	ef15                	bnez	a4,ffffffffc020583c <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0205802:	000ad697          	auipc	a3,0xad
ffffffffc0205806:	0566a683          	lw	a3,86(a3) # ffffffffc02b2858 <nr_process>
ffffffffc020580a:	4709                	li	a4,2
ffffffffc020580c:	0ae69463          	bne	a3,a4,ffffffffc02058b4 <init_main+0x104>
    return listelm->next;
ffffffffc0205810:	000ad697          	auipc	a3,0xad
ffffffffc0205814:	fa868693          	addi	a3,a3,-88 # ffffffffc02b27b8 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205818:	6698                	ld	a4,8(a3)
ffffffffc020581a:	0c878793          	addi	a5,a5,200
ffffffffc020581e:	06f71b63          	bne	a4,a5,ffffffffc0205894 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205822:	629c                	ld	a5,0(a3)
ffffffffc0205824:	04f71863          	bne	a4,a5,ffffffffc0205874 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0205828:	00003517          	auipc	a0,0x3
ffffffffc020582c:	f3050513          	addi	a0,a0,-208 # ffffffffc0208758 <default_pmm_manager+0x810>
ffffffffc0205830:	89dfa0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
}
ffffffffc0205834:	60a2                	ld	ra,8(sp)
ffffffffc0205836:	4501                	li	a0,0
ffffffffc0205838:	0141                	addi	sp,sp,16
ffffffffc020583a:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020583c:	00003697          	auipc	a3,0x3
ffffffffc0205840:	e5c68693          	addi	a3,a3,-420 # ffffffffc0208698 <default_pmm_manager+0x750>
ffffffffc0205844:	00001617          	auipc	a2,0x1
ffffffffc0205848:	56c60613          	addi	a2,a2,1388 # ffffffffc0206db0 <commands+0x410>
ffffffffc020584c:	36900593          	li	a1,873
ffffffffc0205850:	00003517          	auipc	a0,0x3
ffffffffc0205854:	d4050513          	addi	a0,a0,-704 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc0205858:	9b1fa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("create user_main failed.\n");
ffffffffc020585c:	00003617          	auipc	a2,0x3
ffffffffc0205860:	df460613          	addi	a2,a2,-524 # ffffffffc0208650 <default_pmm_manager+0x708>
ffffffffc0205864:	36100593          	li	a1,865
ffffffffc0205868:	00003517          	auipc	a0,0x3
ffffffffc020586c:	d2850513          	addi	a0,a0,-728 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc0205870:	999fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205874:	00003697          	auipc	a3,0x3
ffffffffc0205878:	eb468693          	addi	a3,a3,-332 # ffffffffc0208728 <default_pmm_manager+0x7e0>
ffffffffc020587c:	00001617          	auipc	a2,0x1
ffffffffc0205880:	53460613          	addi	a2,a2,1332 # ffffffffc0206db0 <commands+0x410>
ffffffffc0205884:	36c00593          	li	a1,876
ffffffffc0205888:	00003517          	auipc	a0,0x3
ffffffffc020588c:	d0850513          	addi	a0,a0,-760 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc0205890:	979fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205894:	00003697          	auipc	a3,0x3
ffffffffc0205898:	e6468693          	addi	a3,a3,-412 # ffffffffc02086f8 <default_pmm_manager+0x7b0>
ffffffffc020589c:	00001617          	auipc	a2,0x1
ffffffffc02058a0:	51460613          	addi	a2,a2,1300 # ffffffffc0206db0 <commands+0x410>
ffffffffc02058a4:	36b00593          	li	a1,875
ffffffffc02058a8:	00003517          	auipc	a0,0x3
ffffffffc02058ac:	ce850513          	addi	a0,a0,-792 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc02058b0:	959fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(nr_process == 2);
ffffffffc02058b4:	00003697          	auipc	a3,0x3
ffffffffc02058b8:	e3468693          	addi	a3,a3,-460 # ffffffffc02086e8 <default_pmm_manager+0x7a0>
ffffffffc02058bc:	00001617          	auipc	a2,0x1
ffffffffc02058c0:	4f460613          	addi	a2,a2,1268 # ffffffffc0206db0 <commands+0x410>
ffffffffc02058c4:	36a00593          	li	a1,874
ffffffffc02058c8:	00003517          	auipc	a0,0x3
ffffffffc02058cc:	cc850513          	addi	a0,a0,-824 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc02058d0:	939fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02058d4 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02058d4:	7171                	addi	sp,sp,-176
ffffffffc02058d6:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02058d8:	000add97          	auipc	s11,0xad
ffffffffc02058dc:	f68d8d93          	addi	s11,s11,-152 # ffffffffc02b2840 <current>
ffffffffc02058e0:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02058e4:	e54e                	sd	s3,136(sp)
ffffffffc02058e6:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02058e8:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02058ec:	e94a                	sd	s2,144(sp)
ffffffffc02058ee:	f4de                	sd	s7,104(sp)
ffffffffc02058f0:	892a                	mv	s2,a0
ffffffffc02058f2:	8bb2                	mv	s7,a2
ffffffffc02058f4:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02058f6:	862e                	mv	a2,a1
ffffffffc02058f8:	4681                	li	a3,0
ffffffffc02058fa:	85aa                	mv	a1,a0
ffffffffc02058fc:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02058fe:	f506                	sd	ra,168(sp)
ffffffffc0205900:	f122                	sd	s0,160(sp)
ffffffffc0205902:	e152                	sd	s4,128(sp)
ffffffffc0205904:	fcd6                	sd	s5,120(sp)
ffffffffc0205906:	f8da                	sd	s6,112(sp)
ffffffffc0205908:	f0e2                	sd	s8,96(sp)
ffffffffc020590a:	ece6                	sd	s9,88(sp)
ffffffffc020590c:	e8ea                	sd	s10,80(sp)
ffffffffc020590e:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205910:	a48fc0ef          	jal	ra,ffffffffc0201b58 <user_mem_check>
ffffffffc0205914:	40050863          	beqz	a0,ffffffffc0205d24 <do_execve+0x450>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0205918:	4641                	li	a2,16
ffffffffc020591a:	4581                	li	a1,0
ffffffffc020591c:	1808                	addi	a0,sp,48
ffffffffc020591e:	1ab000ef          	jal	ra,ffffffffc02062c8 <memset>
    memcpy(local_name, name, len);
ffffffffc0205922:	47bd                	li	a5,15
ffffffffc0205924:	8626                	mv	a2,s1
ffffffffc0205926:	1e97e063          	bltu	a5,s1,ffffffffc0205b06 <do_execve+0x232>
ffffffffc020592a:	85ca                	mv	a1,s2
ffffffffc020592c:	1808                	addi	a0,sp,48
ffffffffc020592e:	1ad000ef          	jal	ra,ffffffffc02062da <memcpy>
    if (mm != NULL) {
ffffffffc0205932:	1e098163          	beqz	s3,ffffffffc0205b14 <do_execve+0x240>
        cputs("mm != NULL");
ffffffffc0205936:	00002517          	auipc	a0,0x2
ffffffffc020593a:	98250513          	addi	a0,a0,-1662 # ffffffffc02072b8 <commands+0x918>
ffffffffc020593e:	fc6fa0ef          	jal	ra,ffffffffc0200104 <cputs>
ffffffffc0205942:	000ad797          	auipc	a5,0xad
ffffffffc0205946:	ece7b783          	ld	a5,-306(a5) # ffffffffc02b2810 <boot_cr3>
ffffffffc020594a:	577d                	li	a4,-1
ffffffffc020594c:	177e                	slli	a4,a4,0x3f
ffffffffc020594e:	83b1                	srli	a5,a5,0xc
ffffffffc0205950:	8fd9                	or	a5,a5,a4
ffffffffc0205952:	18079073          	csrw	satp,a5
ffffffffc0205956:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b80>
ffffffffc020595a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020595e:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205962:	2c070263          	beqz	a4,ffffffffc0205c26 <do_execve+0x352>
        current->mm = NULL;
ffffffffc0205966:	000db783          	ld	a5,0(s11)
ffffffffc020596a:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc020596e:	805fb0ef          	jal	ra,ffffffffc0201172 <mm_create>
ffffffffc0205972:	84aa                	mv	s1,a0
ffffffffc0205974:	1c050b63          	beqz	a0,ffffffffc0205b4a <do_execve+0x276>
    if ((page = alloc_page()) == NULL) {
ffffffffc0205978:	4505                	li	a0,1
ffffffffc020597a:	e2bfd0ef          	jal	ra,ffffffffc02037a4 <alloc_pages>
ffffffffc020597e:	3a050763          	beqz	a0,ffffffffc0205d2c <do_execve+0x458>
    return page - pages + nbase;
ffffffffc0205982:	000adc97          	auipc	s9,0xad
ffffffffc0205986:	ea6c8c93          	addi	s9,s9,-346 # ffffffffc02b2828 <pages>
ffffffffc020598a:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc020598e:	000adc17          	auipc	s8,0xad
ffffffffc0205992:	e92c0c13          	addi	s8,s8,-366 # ffffffffc02b2820 <npage>
    return page - pages + nbase;
ffffffffc0205996:	00003717          	auipc	a4,0x3
ffffffffc020599a:	4b273703          	ld	a4,1202(a4) # ffffffffc0208e48 <nbase>
ffffffffc020599e:	40d506b3          	sub	a3,a0,a3
ffffffffc02059a2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02059a4:	5afd                	li	s5,-1
ffffffffc02059a6:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc02059aa:	96ba                	add	a3,a3,a4
ffffffffc02059ac:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc02059ae:	00cad713          	srli	a4,s5,0xc
ffffffffc02059b2:	ec3a                	sd	a4,24(sp)
ffffffffc02059b4:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02059b6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02059b8:	36f77e63          	bgeu	a4,a5,ffffffffc0205d34 <do_execve+0x460>
ffffffffc02059bc:	000adb17          	auipc	s6,0xad
ffffffffc02059c0:	e7cb0b13          	addi	s6,s6,-388 # ffffffffc02b2838 <va_pa_offset>
ffffffffc02059c4:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc02059c8:	6605                	lui	a2,0x1
ffffffffc02059ca:	000ad597          	auipc	a1,0xad
ffffffffc02059ce:	e4e5b583          	ld	a1,-434(a1) # ffffffffc02b2818 <boot_pgdir>
ffffffffc02059d2:	9936                	add	s2,s2,a3
ffffffffc02059d4:	854a                	mv	a0,s2
ffffffffc02059d6:	105000ef          	jal	ra,ffffffffc02062da <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02059da:	7782                	ld	a5,32(sp)
ffffffffc02059dc:	4398                	lw	a4,0(a5)
ffffffffc02059de:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc02059e2:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02059e6:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b945f>
ffffffffc02059ea:	14f71663          	bne	a4,a5,ffffffffc0205b36 <do_execve+0x262>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02059ee:	7682                	ld	a3,32(sp)
ffffffffc02059f0:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02059f4:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02059f8:	00371793          	slli	a5,a4,0x3
ffffffffc02059fc:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02059fe:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205a00:	078e                	slli	a5,a5,0x3
ffffffffc0205a02:	97ce                	add	a5,a5,s3
ffffffffc0205a04:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0205a06:	00f9fc63          	bgeu	s3,a5,ffffffffc0205a1e <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205a0a:	0009a783          	lw	a5,0(s3)
ffffffffc0205a0e:	4705                	li	a4,1
ffffffffc0205a10:	12e78f63          	beq	a5,a4,ffffffffc0205b4e <do_execve+0x27a>
    for (; ph < ph_end; ph ++) {
ffffffffc0205a14:	77a2                	ld	a5,40(sp)
ffffffffc0205a16:	03898993          	addi	s3,s3,56
ffffffffc0205a1a:	fef9e8e3          	bltu	s3,a5,ffffffffc0205a0a <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205a1e:	4701                	li	a4,0
ffffffffc0205a20:	46ad                	li	a3,11
ffffffffc0205a22:	00100637          	lui	a2,0x100
ffffffffc0205a26:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205a2a:	8526                	mv	a0,s1
ffffffffc0205a2c:	91ffb0ef          	jal	ra,ffffffffc020134a <mm_map>
ffffffffc0205a30:	8a2a                	mv	s4,a0
ffffffffc0205a32:	1e051063          	bnez	a0,ffffffffc0205c12 <do_execve+0x33e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205a36:	6c88                	ld	a0,24(s1)
ffffffffc0205a38:	467d                	li	a2,31
ffffffffc0205a3a:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205a3e:	9a2ff0ef          	jal	ra,ffffffffc0204be0 <pgdir_alloc_page>
ffffffffc0205a42:	38050163          	beqz	a0,ffffffffc0205dc4 <do_execve+0x4f0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a46:	6c88                	ld	a0,24(s1)
ffffffffc0205a48:	467d                	li	a2,31
ffffffffc0205a4a:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205a4e:	992ff0ef          	jal	ra,ffffffffc0204be0 <pgdir_alloc_page>
ffffffffc0205a52:	34050963          	beqz	a0,ffffffffc0205da4 <do_execve+0x4d0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a56:	6c88                	ld	a0,24(s1)
ffffffffc0205a58:	467d                	li	a2,31
ffffffffc0205a5a:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205a5e:	982ff0ef          	jal	ra,ffffffffc0204be0 <pgdir_alloc_page>
ffffffffc0205a62:	32050163          	beqz	a0,ffffffffc0205d84 <do_execve+0x4b0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a66:	6c88                	ld	a0,24(s1)
ffffffffc0205a68:	467d                	li	a2,31
ffffffffc0205a6a:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205a6e:	972ff0ef          	jal	ra,ffffffffc0204be0 <pgdir_alloc_page>
ffffffffc0205a72:	2e050963          	beqz	a0,ffffffffc0205d64 <do_execve+0x490>
    mm->mm_count += 1;
ffffffffc0205a76:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0205a78:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205a7c:	6c94                	ld	a3,24(s1)
ffffffffc0205a7e:	2785                	addiw	a5,a5,1
ffffffffc0205a80:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0205a82:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205a84:	c02007b7          	lui	a5,0xc0200
ffffffffc0205a88:	2cf6e263          	bltu	a3,a5,ffffffffc0205d4c <do_execve+0x478>
ffffffffc0205a8c:	000b3783          	ld	a5,0(s6)
ffffffffc0205a90:	577d                	li	a4,-1
ffffffffc0205a92:	177e                	slli	a4,a4,0x3f
ffffffffc0205a94:	8e9d                	sub	a3,a3,a5
ffffffffc0205a96:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205a9a:	f654                	sd	a3,168(a2)
ffffffffc0205a9c:	8fd9                	or	a5,a5,a4
ffffffffc0205a9e:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205aa2:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205aa4:	4581                	li	a1,0
ffffffffc0205aa6:	12000613          	li	a2,288
ffffffffc0205aaa:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205aac:	10043903          	ld	s2,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205ab0:	019000ef          	jal	ra,ffffffffc02062c8 <memset>
    tf->epc = elf->e_entry; // tf->epc应该是用户程序的入口点（sepc的值）
ffffffffc0205ab4:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205ab6:	000db483          	ld	s1,0(s11)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE); // tf->status应该适合用户程序（sstatus的值）
ffffffffc0205aba:	edf97913          	andi	s2,s2,-289
    tf->epc = elf->e_entry; // tf->epc应该是用户程序的入口点（sepc的值）
ffffffffc0205abe:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP; // tf->gpr.sp应该是用户堆栈顶部（sp的值）
ffffffffc0205ac0:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205ac2:	0b448493          	addi	s1,s1,180
    tf->gpr.sp = USTACKTOP; // tf->gpr.sp应该是用户堆栈顶部（sp的值）
ffffffffc0205ac6:	07fe                	slli	a5,a5,0x1f
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205ac8:	4641                	li	a2,16
ffffffffc0205aca:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP; // tf->gpr.sp应该是用户堆栈顶部（sp的值）
ffffffffc0205acc:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry; // tf->epc应该是用户程序的入口点（sepc的值）
ffffffffc0205ace:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE); // tf->status应该适合用户程序（sstatus的值）
ffffffffc0205ad2:	11243023          	sd	s2,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205ad6:	8526                	mv	a0,s1
ffffffffc0205ad8:	7f0000ef          	jal	ra,ffffffffc02062c8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205adc:	463d                	li	a2,15
ffffffffc0205ade:	180c                	addi	a1,sp,48
ffffffffc0205ae0:	8526                	mv	a0,s1
ffffffffc0205ae2:	7f8000ef          	jal	ra,ffffffffc02062da <memcpy>
}
ffffffffc0205ae6:	70aa                	ld	ra,168(sp)
ffffffffc0205ae8:	740a                	ld	s0,160(sp)
ffffffffc0205aea:	64ea                	ld	s1,152(sp)
ffffffffc0205aec:	694a                	ld	s2,144(sp)
ffffffffc0205aee:	69aa                	ld	s3,136(sp)
ffffffffc0205af0:	7ae6                	ld	s5,120(sp)
ffffffffc0205af2:	7b46                	ld	s6,112(sp)
ffffffffc0205af4:	7ba6                	ld	s7,104(sp)
ffffffffc0205af6:	7c06                	ld	s8,96(sp)
ffffffffc0205af8:	6ce6                	ld	s9,88(sp)
ffffffffc0205afa:	6d46                	ld	s10,80(sp)
ffffffffc0205afc:	6da6                	ld	s11,72(sp)
ffffffffc0205afe:	8552                	mv	a0,s4
ffffffffc0205b00:	6a0a                	ld	s4,128(sp)
ffffffffc0205b02:	614d                	addi	sp,sp,176
ffffffffc0205b04:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0205b06:	463d                	li	a2,15
ffffffffc0205b08:	85ca                	mv	a1,s2
ffffffffc0205b0a:	1808                	addi	a0,sp,48
ffffffffc0205b0c:	7ce000ef          	jal	ra,ffffffffc02062da <memcpy>
    if (mm != NULL) {
ffffffffc0205b10:	e20993e3          	bnez	s3,ffffffffc0205936 <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc0205b14:	000db783          	ld	a5,0(s11)
ffffffffc0205b18:	779c                	ld	a5,40(a5)
ffffffffc0205b1a:	e4078ae3          	beqz	a5,ffffffffc020596e <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205b1e:	00003617          	auipc	a2,0x3
ffffffffc0205b22:	c5a60613          	addi	a2,a2,-934 # ffffffffc0208778 <default_pmm_manager+0x830>
ffffffffc0205b26:	21100593          	li	a1,529
ffffffffc0205b2a:	00003517          	auipc	a0,0x3
ffffffffc0205b2e:	a6650513          	addi	a0,a0,-1434 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc0205b32:	ed6fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    put_pgdir(mm);
ffffffffc0205b36:	8526                	mv	a0,s1
ffffffffc0205b38:	c26ff0ef          	jal	ra,ffffffffc0204f5e <put_pgdir>
    mm_destroy(mm);
ffffffffc0205b3c:	8526                	mv	a0,s1
ffffffffc0205b3e:	fbafb0ef          	jal	ra,ffffffffc02012f8 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205b42:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc0205b44:	8552                	mv	a0,s4
ffffffffc0205b46:	94fff0ef          	jal	ra,ffffffffc0205494 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0205b4a:	5a71                	li	s4,-4
ffffffffc0205b4c:	bfe5                	j	ffffffffc0205b44 <do_execve+0x270>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205b4e:	0289b603          	ld	a2,40(s3)
ffffffffc0205b52:	0209b783          	ld	a5,32(s3)
ffffffffc0205b56:	1cf66d63          	bltu	a2,a5,ffffffffc0205d30 <do_execve+0x45c>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205b5a:	0049a783          	lw	a5,4(s3)
ffffffffc0205b5e:	0017f693          	andi	a3,a5,1
ffffffffc0205b62:	c291                	beqz	a3,ffffffffc0205b66 <do_execve+0x292>
ffffffffc0205b64:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b66:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b6a:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b6c:	e779                	bnez	a4,ffffffffc0205c3a <do_execve+0x366>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205b6e:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b70:	c781                	beqz	a5,ffffffffc0205b78 <do_execve+0x2a4>
ffffffffc0205b72:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205b76:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205b78:	0026f793          	andi	a5,a3,2
ffffffffc0205b7c:	e3f1                	bnez	a5,ffffffffc0205c40 <do_execve+0x36c>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205b7e:	0046f793          	andi	a5,a3,4
ffffffffc0205b82:	c399                	beqz	a5,ffffffffc0205b88 <do_execve+0x2b4>
ffffffffc0205b84:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205b88:	0109b583          	ld	a1,16(s3)
ffffffffc0205b8c:	4701                	li	a4,0
ffffffffc0205b8e:	8526                	mv	a0,s1
ffffffffc0205b90:	fbafb0ef          	jal	ra,ffffffffc020134a <mm_map>
ffffffffc0205b94:	8a2a                	mv	s4,a0
ffffffffc0205b96:	ed35                	bnez	a0,ffffffffc0205c12 <do_execve+0x33e>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205b98:	0109bb83          	ld	s7,16(s3)
ffffffffc0205b9c:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205b9e:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205ba2:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205ba6:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205baa:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205bac:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205bae:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc0205bb0:	054be963          	bltu	s7,s4,ffffffffc0205c02 <do_execve+0x32e>
ffffffffc0205bb4:	aa95                	j	ffffffffc0205d28 <do_execve+0x454>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205bb6:	6785                	lui	a5,0x1
ffffffffc0205bb8:	415b8533          	sub	a0,s7,s5
ffffffffc0205bbc:	9abe                	add	s5,s5,a5
ffffffffc0205bbe:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205bc2:	015a7463          	bgeu	s4,s5,ffffffffc0205bca <do_execve+0x2f6>
                size -= la - end;
ffffffffc0205bc6:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0205bca:	000cb683          	ld	a3,0(s9)
ffffffffc0205bce:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205bd0:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205bd4:	40d406b3          	sub	a3,s0,a3
ffffffffc0205bd8:	8699                	srai	a3,a3,0x6
ffffffffc0205bda:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205bdc:	67e2                	ld	a5,24(sp)
ffffffffc0205bde:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205be2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205be4:	14b87863          	bgeu	a6,a1,ffffffffc0205d34 <do_execve+0x460>
ffffffffc0205be8:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205bec:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0205bee:	9bb2                	add	s7,s7,a2
ffffffffc0205bf0:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205bf2:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205bf4:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205bf6:	6e4000ef          	jal	ra,ffffffffc02062da <memcpy>
            start += size, from += size;
ffffffffc0205bfa:	6622                	ld	a2,8(sp)
ffffffffc0205bfc:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc0205bfe:	054bf363          	bgeu	s7,s4,ffffffffc0205c44 <do_execve+0x370>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205c02:	6c88                	ld	a0,24(s1)
ffffffffc0205c04:	866a                	mv	a2,s10
ffffffffc0205c06:	85d6                	mv	a1,s5
ffffffffc0205c08:	fd9fe0ef          	jal	ra,ffffffffc0204be0 <pgdir_alloc_page>
ffffffffc0205c0c:	842a                	mv	s0,a0
ffffffffc0205c0e:	f545                	bnez	a0,ffffffffc0205bb6 <do_execve+0x2e2>
        ret = -E_NO_MEM;
ffffffffc0205c10:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0205c12:	8526                	mv	a0,s1
ffffffffc0205c14:	881fb0ef          	jal	ra,ffffffffc0201494 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205c18:	8526                	mv	a0,s1
ffffffffc0205c1a:	b44ff0ef          	jal	ra,ffffffffc0204f5e <put_pgdir>
    mm_destroy(mm);
ffffffffc0205c1e:	8526                	mv	a0,s1
ffffffffc0205c20:	ed8fb0ef          	jal	ra,ffffffffc02012f8 <mm_destroy>
    return ret;
ffffffffc0205c24:	b705                	j	ffffffffc0205b44 <do_execve+0x270>
            exit_mmap(mm);
ffffffffc0205c26:	854e                	mv	a0,s3
ffffffffc0205c28:	86dfb0ef          	jal	ra,ffffffffc0201494 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205c2c:	854e                	mv	a0,s3
ffffffffc0205c2e:	b30ff0ef          	jal	ra,ffffffffc0204f5e <put_pgdir>
            mm_destroy(mm);
ffffffffc0205c32:	854e                	mv	a0,s3
ffffffffc0205c34:	ec4fb0ef          	jal	ra,ffffffffc02012f8 <mm_destroy>
ffffffffc0205c38:	b33d                	j	ffffffffc0205966 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205c3a:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205c3e:	fb95                	bnez	a5,ffffffffc0205b72 <do_execve+0x29e>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205c40:	4d5d                	li	s10,23
ffffffffc0205c42:	bf35                	j	ffffffffc0205b7e <do_execve+0x2aa>
        end = ph->p_va + ph->p_memsz;
ffffffffc0205c44:	0109b683          	ld	a3,16(s3)
ffffffffc0205c48:	0289b903          	ld	s2,40(s3)
ffffffffc0205c4c:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc0205c4e:	075bfd63          	bgeu	s7,s5,ffffffffc0205cc8 <do_execve+0x3f4>
            if (start == end) {
ffffffffc0205c52:	dd7901e3          	beq	s2,s7,ffffffffc0205a14 <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c56:	6785                	lui	a5,0x1
ffffffffc0205c58:	00fb8533          	add	a0,s7,a5
ffffffffc0205c5c:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0205c60:	41790a33          	sub	s4,s2,s7
            if (end < la) {
ffffffffc0205c64:	0b597d63          	bgeu	s2,s5,ffffffffc0205d1e <do_execve+0x44a>
    return page - pages + nbase;
ffffffffc0205c68:	000cb683          	ld	a3,0(s9)
ffffffffc0205c6c:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205c6e:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0205c72:	40d406b3          	sub	a3,s0,a3
ffffffffc0205c76:	8699                	srai	a3,a3,0x6
ffffffffc0205c78:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205c7a:	67e2                	ld	a5,24(sp)
ffffffffc0205c7c:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c80:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c82:	0ac5f963          	bgeu	a1,a2,ffffffffc0205d34 <do_execve+0x460>
ffffffffc0205c86:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c8a:	8652                	mv	a2,s4
ffffffffc0205c8c:	4581                	li	a1,0
ffffffffc0205c8e:	96c2                	add	a3,a3,a6
ffffffffc0205c90:	9536                	add	a0,a0,a3
ffffffffc0205c92:	636000ef          	jal	ra,ffffffffc02062c8 <memset>
            start += size;
ffffffffc0205c96:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205c9a:	03597463          	bgeu	s2,s5,ffffffffc0205cc2 <do_execve+0x3ee>
ffffffffc0205c9e:	d6e90be3          	beq	s2,a4,ffffffffc0205a14 <do_execve+0x140>
ffffffffc0205ca2:	00003697          	auipc	a3,0x3
ffffffffc0205ca6:	afe68693          	addi	a3,a3,-1282 # ffffffffc02087a0 <default_pmm_manager+0x858>
ffffffffc0205caa:	00001617          	auipc	a2,0x1
ffffffffc0205cae:	10660613          	addi	a2,a2,262 # ffffffffc0206db0 <commands+0x410>
ffffffffc0205cb2:	26600593          	li	a1,614
ffffffffc0205cb6:	00003517          	auipc	a0,0x3
ffffffffc0205cba:	8da50513          	addi	a0,a0,-1830 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc0205cbe:	d4afa0ef          	jal	ra,ffffffffc0200208 <__panic>
ffffffffc0205cc2:	ff5710e3          	bne	a4,s5,ffffffffc0205ca2 <do_execve+0x3ce>
ffffffffc0205cc6:	8bd6                	mv	s7,s5
        while (start < end) {
ffffffffc0205cc8:	d52bf6e3          	bgeu	s7,s2,ffffffffc0205a14 <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205ccc:	6c88                	ld	a0,24(s1)
ffffffffc0205cce:	866a                	mv	a2,s10
ffffffffc0205cd0:	85d6                	mv	a1,s5
ffffffffc0205cd2:	f0ffe0ef          	jal	ra,ffffffffc0204be0 <pgdir_alloc_page>
ffffffffc0205cd6:	842a                	mv	s0,a0
ffffffffc0205cd8:	dd05                	beqz	a0,ffffffffc0205c10 <do_execve+0x33c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205cda:	6785                	lui	a5,0x1
ffffffffc0205cdc:	415b8533          	sub	a0,s7,s5
ffffffffc0205ce0:	9abe                	add	s5,s5,a5
ffffffffc0205ce2:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205ce6:	01597463          	bgeu	s2,s5,ffffffffc0205cee <do_execve+0x41a>
                size -= la - end;
ffffffffc0205cea:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0205cee:	000cb683          	ld	a3,0(s9)
ffffffffc0205cf2:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205cf4:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205cf8:	40d406b3          	sub	a3,s0,a3
ffffffffc0205cfc:	8699                	srai	a3,a3,0x6
ffffffffc0205cfe:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205d00:	67e2                	ld	a5,24(sp)
ffffffffc0205d02:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205d06:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205d08:	02b87663          	bgeu	a6,a1,ffffffffc0205d34 <do_execve+0x460>
ffffffffc0205d0c:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205d10:	4581                	li	a1,0
            start += size;
ffffffffc0205d12:	9bb2                	add	s7,s7,a2
ffffffffc0205d14:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205d16:	9536                	add	a0,a0,a3
ffffffffc0205d18:	5b0000ef          	jal	ra,ffffffffc02062c8 <memset>
ffffffffc0205d1c:	b775                	j	ffffffffc0205cc8 <do_execve+0x3f4>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205d1e:	417a8a33          	sub	s4,s5,s7
ffffffffc0205d22:	b799                	j	ffffffffc0205c68 <do_execve+0x394>
        return -E_INVAL;
ffffffffc0205d24:	5a75                	li	s4,-3
ffffffffc0205d26:	b3c1                	j	ffffffffc0205ae6 <do_execve+0x212>
        while (start < end) {
ffffffffc0205d28:	86de                	mv	a3,s7
ffffffffc0205d2a:	bf39                	j	ffffffffc0205c48 <do_execve+0x374>
    int ret = -E_NO_MEM;
ffffffffc0205d2c:	5a71                	li	s4,-4
ffffffffc0205d2e:	bdc5                	j	ffffffffc0205c1e <do_execve+0x34a>
            ret = -E_INVAL_ELF;
ffffffffc0205d30:	5a61                	li	s4,-8
ffffffffc0205d32:	b5c5                	j	ffffffffc0205c12 <do_execve+0x33e>
ffffffffc0205d34:	00001617          	auipc	a2,0x1
ffffffffc0205d38:	4b460613          	addi	a2,a2,1204 # ffffffffc02071e8 <commands+0x848>
ffffffffc0205d3c:	06900593          	li	a1,105
ffffffffc0205d40:	00001517          	auipc	a0,0x1
ffffffffc0205d44:	41050513          	addi	a0,a0,1040 # ffffffffc0207150 <commands+0x7b0>
ffffffffc0205d48:	cc0fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205d4c:	00002617          	auipc	a2,0x2
ffffffffc0205d50:	ad460613          	addi	a2,a2,-1324 # ffffffffc0207820 <commands+0xe80>
ffffffffc0205d54:	28100593          	li	a1,641
ffffffffc0205d58:	00003517          	auipc	a0,0x3
ffffffffc0205d5c:	83850513          	addi	a0,a0,-1992 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc0205d60:	ca8fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205d64:	00003697          	auipc	a3,0x3
ffffffffc0205d68:	b5468693          	addi	a3,a3,-1196 # ffffffffc02088b8 <default_pmm_manager+0x970>
ffffffffc0205d6c:	00001617          	auipc	a2,0x1
ffffffffc0205d70:	04460613          	addi	a2,a2,68 # ffffffffc0206db0 <commands+0x410>
ffffffffc0205d74:	27c00593          	li	a1,636
ffffffffc0205d78:	00003517          	auipc	a0,0x3
ffffffffc0205d7c:	81850513          	addi	a0,a0,-2024 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc0205d80:	c88fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205d84:	00003697          	auipc	a3,0x3
ffffffffc0205d88:	aec68693          	addi	a3,a3,-1300 # ffffffffc0208870 <default_pmm_manager+0x928>
ffffffffc0205d8c:	00001617          	auipc	a2,0x1
ffffffffc0205d90:	02460613          	addi	a2,a2,36 # ffffffffc0206db0 <commands+0x410>
ffffffffc0205d94:	27b00593          	li	a1,635
ffffffffc0205d98:	00002517          	auipc	a0,0x2
ffffffffc0205d9c:	7f850513          	addi	a0,a0,2040 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc0205da0:	c68fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205da4:	00003697          	auipc	a3,0x3
ffffffffc0205da8:	a8468693          	addi	a3,a3,-1404 # ffffffffc0208828 <default_pmm_manager+0x8e0>
ffffffffc0205dac:	00001617          	auipc	a2,0x1
ffffffffc0205db0:	00460613          	addi	a2,a2,4 # ffffffffc0206db0 <commands+0x410>
ffffffffc0205db4:	27a00593          	li	a1,634
ffffffffc0205db8:	00002517          	auipc	a0,0x2
ffffffffc0205dbc:	7d850513          	addi	a0,a0,2008 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc0205dc0:	c48fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205dc4:	00003697          	auipc	a3,0x3
ffffffffc0205dc8:	a1c68693          	addi	a3,a3,-1508 # ffffffffc02087e0 <default_pmm_manager+0x898>
ffffffffc0205dcc:	00001617          	auipc	a2,0x1
ffffffffc0205dd0:	fe460613          	addi	a2,a2,-28 # ffffffffc0206db0 <commands+0x410>
ffffffffc0205dd4:	27900593          	li	a1,633
ffffffffc0205dd8:	00002517          	auipc	a0,0x2
ffffffffc0205ddc:	7b850513          	addi	a0,a0,1976 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc0205de0:	c28fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0205de4 <do_yield>:
    current->need_resched = 1;
ffffffffc0205de4:	000ad797          	auipc	a5,0xad
ffffffffc0205de8:	a5c7b783          	ld	a5,-1444(a5) # ffffffffc02b2840 <current>
ffffffffc0205dec:	4705                	li	a4,1
ffffffffc0205dee:	ef98                	sd	a4,24(a5)
}
ffffffffc0205df0:	4501                	li	a0,0
ffffffffc0205df2:	8082                	ret

ffffffffc0205df4 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205df4:	1101                	addi	sp,sp,-32
ffffffffc0205df6:	e822                	sd	s0,16(sp)
ffffffffc0205df8:	e426                	sd	s1,8(sp)
ffffffffc0205dfa:	ec06                	sd	ra,24(sp)
ffffffffc0205dfc:	842e                	mv	s0,a1
ffffffffc0205dfe:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205e00:	c999                	beqz	a1,ffffffffc0205e16 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205e02:	000ad797          	auipc	a5,0xad
ffffffffc0205e06:	a3e7b783          	ld	a5,-1474(a5) # ffffffffc02b2840 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205e0a:	7788                	ld	a0,40(a5)
ffffffffc0205e0c:	4685                	li	a3,1
ffffffffc0205e0e:	4611                	li	a2,4
ffffffffc0205e10:	d49fb0ef          	jal	ra,ffffffffc0201b58 <user_mem_check>
ffffffffc0205e14:	c909                	beqz	a0,ffffffffc0205e26 <do_wait+0x32>
ffffffffc0205e16:	85a2                	mv	a1,s0
}
ffffffffc0205e18:	6442                	ld	s0,16(sp)
ffffffffc0205e1a:	60e2                	ld	ra,24(sp)
ffffffffc0205e1c:	8526                	mv	a0,s1
ffffffffc0205e1e:	64a2                	ld	s1,8(sp)
ffffffffc0205e20:	6105                	addi	sp,sp,32
ffffffffc0205e22:	fbcff06f          	j	ffffffffc02055de <do_wait.part.0>
ffffffffc0205e26:	60e2                	ld	ra,24(sp)
ffffffffc0205e28:	6442                	ld	s0,16(sp)
ffffffffc0205e2a:	64a2                	ld	s1,8(sp)
ffffffffc0205e2c:	5575                	li	a0,-3
ffffffffc0205e2e:	6105                	addi	sp,sp,32
ffffffffc0205e30:	8082                	ret

ffffffffc0205e32 <do_kill>:
do_kill(int pid) {
ffffffffc0205e32:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205e34:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc0205e36:	e406                	sd	ra,8(sp)
ffffffffc0205e38:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205e3a:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205e3e:	17f9                	addi	a5,a5,-2
ffffffffc0205e40:	02e7e963          	bltu	a5,a4,ffffffffc0205e72 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205e44:	842a                	mv	s0,a0
ffffffffc0205e46:	45a9                	li	a1,10
ffffffffc0205e48:	2501                	sext.w	a0,a0
ffffffffc0205e4a:	097000ef          	jal	ra,ffffffffc02066e0 <hash32>
ffffffffc0205e4e:	02051793          	slli	a5,a0,0x20
ffffffffc0205e52:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205e56:	000a9797          	auipc	a5,0xa9
ffffffffc0205e5a:	96278793          	addi	a5,a5,-1694 # ffffffffc02ae7b8 <hash_list>
ffffffffc0205e5e:	953e                	add	a0,a0,a5
ffffffffc0205e60:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205e62:	a029                	j	ffffffffc0205e6c <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205e64:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205e68:	00870b63          	beq	a4,s0,ffffffffc0205e7e <do_kill+0x4c>
ffffffffc0205e6c:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205e6e:	fef51be3          	bne	a0,a5,ffffffffc0205e64 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205e72:	5475                	li	s0,-3
}
ffffffffc0205e74:	60a2                	ld	ra,8(sp)
ffffffffc0205e76:	8522                	mv	a0,s0
ffffffffc0205e78:	6402                	ld	s0,0(sp)
ffffffffc0205e7a:	0141                	addi	sp,sp,16
ffffffffc0205e7c:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205e7e:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205e82:	00177693          	andi	a3,a4,1
ffffffffc0205e86:	e295                	bnez	a3,ffffffffc0205eaa <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205e88:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205e8a:	00176713          	ori	a4,a4,1
ffffffffc0205e8e:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205e92:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205e94:	fe06d0e3          	bgez	a3,ffffffffc0205e74 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205e98:	f2878513          	addi	a0,a5,-216
ffffffffc0205e9c:	1c4000ef          	jal	ra,ffffffffc0206060 <wakeup_proc>
}
ffffffffc0205ea0:	60a2                	ld	ra,8(sp)
ffffffffc0205ea2:	8522                	mv	a0,s0
ffffffffc0205ea4:	6402                	ld	s0,0(sp)
ffffffffc0205ea6:	0141                	addi	sp,sp,16
ffffffffc0205ea8:	8082                	ret
        return -E_KILLED;
ffffffffc0205eaa:	545d                	li	s0,-9
ffffffffc0205eac:	b7e1                	j	ffffffffc0205e74 <do_kill+0x42>

ffffffffc0205eae <proc_init>:


// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205eae:	1101                	addi	sp,sp,-32
ffffffffc0205eb0:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205eb2:	000ad797          	auipc	a5,0xad
ffffffffc0205eb6:	90678793          	addi	a5,a5,-1786 # ffffffffc02b27b8 <proc_list>
ffffffffc0205eba:	ec06                	sd	ra,24(sp)
ffffffffc0205ebc:	e822                	sd	s0,16(sp)
ffffffffc0205ebe:	e04a                	sd	s2,0(sp)
ffffffffc0205ec0:	000a9497          	auipc	s1,0xa9
ffffffffc0205ec4:	8f848493          	addi	s1,s1,-1800 # ffffffffc02ae7b8 <hash_list>
ffffffffc0205ec8:	e79c                	sd	a5,8(a5)
ffffffffc0205eca:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205ecc:	000ad717          	auipc	a4,0xad
ffffffffc0205ed0:	8ec70713          	addi	a4,a4,-1812 # ffffffffc02b27b8 <proc_list>
ffffffffc0205ed4:	87a6                	mv	a5,s1
ffffffffc0205ed6:	e79c                	sd	a5,8(a5)
ffffffffc0205ed8:	e39c                	sd	a5,0(a5)
ffffffffc0205eda:	07c1                	addi	a5,a5,16
ffffffffc0205edc:	fef71de3          	bne	a4,a5,ffffffffc0205ed6 <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205ee0:	f81fe0ef          	jal	ra,ffffffffc0204e60 <alloc_proc>
ffffffffc0205ee4:	000ad917          	auipc	s2,0xad
ffffffffc0205ee8:	96490913          	addi	s2,s2,-1692 # ffffffffc02b2848 <idleproc>
ffffffffc0205eec:	00a93023          	sd	a0,0(s2)
ffffffffc0205ef0:	0e050f63          	beqz	a0,ffffffffc0205fee <proc_init+0x140>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205ef4:	4789                	li	a5,2
ffffffffc0205ef6:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205ef8:	00003797          	auipc	a5,0x3
ffffffffc0205efc:	10878793          	addi	a5,a5,264 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205f00:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205f04:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205f06:	4785                	li	a5,1
ffffffffc0205f08:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205f0a:	4641                	li	a2,16
ffffffffc0205f0c:	4581                	li	a1,0
ffffffffc0205f0e:	8522                	mv	a0,s0
ffffffffc0205f10:	3b8000ef          	jal	ra,ffffffffc02062c8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205f14:	463d                	li	a2,15
ffffffffc0205f16:	00003597          	auipc	a1,0x3
ffffffffc0205f1a:	a0258593          	addi	a1,a1,-1534 # ffffffffc0208918 <default_pmm_manager+0x9d0>
ffffffffc0205f1e:	8522                	mv	a0,s0
ffffffffc0205f20:	3ba000ef          	jal	ra,ffffffffc02062da <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205f24:	000ad717          	auipc	a4,0xad
ffffffffc0205f28:	93470713          	addi	a4,a4,-1740 # ffffffffc02b2858 <nr_process>
ffffffffc0205f2c:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205f2e:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205f32:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205f34:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205f36:	4581                	li	a1,0
ffffffffc0205f38:	00000517          	auipc	a0,0x0
ffffffffc0205f3c:	87850513          	addi	a0,a0,-1928 # ffffffffc02057b0 <init_main>
    nr_process ++;
ffffffffc0205f40:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205f42:	000ad797          	auipc	a5,0xad
ffffffffc0205f46:	8ed7bf23          	sd	a3,-1794(a5) # ffffffffc02b2840 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205f4a:	cfaff0ef          	jal	ra,ffffffffc0205444 <kernel_thread>
ffffffffc0205f4e:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0205f50:	08a05363          	blez	a0,ffffffffc0205fd6 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205f54:	6789                	lui	a5,0x2
ffffffffc0205f56:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205f5a:	17f9                	addi	a5,a5,-2
ffffffffc0205f5c:	2501                	sext.w	a0,a0
ffffffffc0205f5e:	02e7e363          	bltu	a5,a4,ffffffffc0205f84 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205f62:	45a9                	li	a1,10
ffffffffc0205f64:	77c000ef          	jal	ra,ffffffffc02066e0 <hash32>
ffffffffc0205f68:	02051793          	slli	a5,a0,0x20
ffffffffc0205f6c:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205f70:	96a6                	add	a3,a3,s1
ffffffffc0205f72:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205f74:	a029                	j	ffffffffc0205f7e <proc_init+0xd0>
            if (proc->pid == pid) {
ffffffffc0205f76:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c84>
ffffffffc0205f7a:	04870b63          	beq	a4,s0,ffffffffc0205fd0 <proc_init+0x122>
    return listelm->next;
ffffffffc0205f7e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205f80:	fef69be3          	bne	a3,a5,ffffffffc0205f76 <proc_init+0xc8>
    return NULL;
ffffffffc0205f84:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205f86:	0b478493          	addi	s1,a5,180
ffffffffc0205f8a:	4641                	li	a2,16
ffffffffc0205f8c:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205f8e:	000ad417          	auipc	s0,0xad
ffffffffc0205f92:	8c240413          	addi	s0,s0,-1854 # ffffffffc02b2850 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205f96:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205f98:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205f9a:	32e000ef          	jal	ra,ffffffffc02062c8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205f9e:	463d                	li	a2,15
ffffffffc0205fa0:	00003597          	auipc	a1,0x3
ffffffffc0205fa4:	9a058593          	addi	a1,a1,-1632 # ffffffffc0208940 <default_pmm_manager+0x9f8>
ffffffffc0205fa8:	8526                	mv	a0,s1
ffffffffc0205faa:	330000ef          	jal	ra,ffffffffc02062da <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205fae:	00093783          	ld	a5,0(s2)
ffffffffc0205fb2:	cbb5                	beqz	a5,ffffffffc0206026 <proc_init+0x178>
ffffffffc0205fb4:	43dc                	lw	a5,4(a5)
ffffffffc0205fb6:	eba5                	bnez	a5,ffffffffc0206026 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205fb8:	601c                	ld	a5,0(s0)
ffffffffc0205fba:	c7b1                	beqz	a5,ffffffffc0206006 <proc_init+0x158>
ffffffffc0205fbc:	43d8                	lw	a4,4(a5)
ffffffffc0205fbe:	4785                	li	a5,1
ffffffffc0205fc0:	04f71363          	bne	a4,a5,ffffffffc0206006 <proc_init+0x158>
}
ffffffffc0205fc4:	60e2                	ld	ra,24(sp)
ffffffffc0205fc6:	6442                	ld	s0,16(sp)
ffffffffc0205fc8:	64a2                	ld	s1,8(sp)
ffffffffc0205fca:	6902                	ld	s2,0(sp)
ffffffffc0205fcc:	6105                	addi	sp,sp,32
ffffffffc0205fce:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205fd0:	f2878793          	addi	a5,a5,-216
ffffffffc0205fd4:	bf4d                	j	ffffffffc0205f86 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205fd6:	00003617          	auipc	a2,0x3
ffffffffc0205fda:	94a60613          	addi	a2,a2,-1718 # ffffffffc0208920 <default_pmm_manager+0x9d8>
ffffffffc0205fde:	38d00593          	li	a1,909
ffffffffc0205fe2:	00002517          	auipc	a0,0x2
ffffffffc0205fe6:	5ae50513          	addi	a0,a0,1454 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc0205fea:	a1efa0ef          	jal	ra,ffffffffc0200208 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205fee:	00003617          	auipc	a2,0x3
ffffffffc0205ff2:	91260613          	addi	a2,a2,-1774 # ffffffffc0208900 <default_pmm_manager+0x9b8>
ffffffffc0205ff6:	37f00593          	li	a1,895
ffffffffc0205ffa:	00002517          	auipc	a0,0x2
ffffffffc0205ffe:	59650513          	addi	a0,a0,1430 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc0206002:	a06fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0206006:	00003697          	auipc	a3,0x3
ffffffffc020600a:	96a68693          	addi	a3,a3,-1686 # ffffffffc0208970 <default_pmm_manager+0xa28>
ffffffffc020600e:	00001617          	auipc	a2,0x1
ffffffffc0206012:	da260613          	addi	a2,a2,-606 # ffffffffc0206db0 <commands+0x410>
ffffffffc0206016:	39400593          	li	a1,916
ffffffffc020601a:	00002517          	auipc	a0,0x2
ffffffffc020601e:	57650513          	addi	a0,a0,1398 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc0206022:	9e6fa0ef          	jal	ra,ffffffffc0200208 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0206026:	00003697          	auipc	a3,0x3
ffffffffc020602a:	92268693          	addi	a3,a3,-1758 # ffffffffc0208948 <default_pmm_manager+0xa00>
ffffffffc020602e:	00001617          	auipc	a2,0x1
ffffffffc0206032:	d8260613          	addi	a2,a2,-638 # ffffffffc0206db0 <commands+0x410>
ffffffffc0206036:	39300593          	li	a1,915
ffffffffc020603a:	00002517          	auipc	a0,0x2
ffffffffc020603e:	55650513          	addi	a0,a0,1366 # ffffffffc0208590 <default_pmm_manager+0x648>
ffffffffc0206042:	9c6fa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc0206046 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0206046:	1141                	addi	sp,sp,-16
ffffffffc0206048:	e022                	sd	s0,0(sp)
ffffffffc020604a:	e406                	sd	ra,8(sp)
ffffffffc020604c:	000ac417          	auipc	s0,0xac
ffffffffc0206050:	7f440413          	addi	s0,s0,2036 # ffffffffc02b2840 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0206054:	6018                	ld	a4,0(s0)
ffffffffc0206056:	6f1c                	ld	a5,24(a4)
ffffffffc0206058:	dffd                	beqz	a5,ffffffffc0206056 <cpu_idle+0x10>
            schedule();
ffffffffc020605a:	086000ef          	jal	ra,ffffffffc02060e0 <schedule>
ffffffffc020605e:	bfdd                	j	ffffffffc0206054 <cpu_idle+0xe>

ffffffffc0206060 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206060:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0206062:	1101                	addi	sp,sp,-32
ffffffffc0206064:	ec06                	sd	ra,24(sp)
ffffffffc0206066:	e822                	sd	s0,16(sp)
ffffffffc0206068:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020606a:	478d                	li	a5,3
ffffffffc020606c:	04f70b63          	beq	a4,a5,ffffffffc02060c2 <wakeup_proc+0x62>
ffffffffc0206070:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206072:	100027f3          	csrr	a5,sstatus
ffffffffc0206076:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0206078:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020607a:	ef9d                	bnez	a5,ffffffffc02060b8 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc020607c:	4789                	li	a5,2
ffffffffc020607e:	02f70163          	beq	a4,a5,ffffffffc02060a0 <wakeup_proc+0x40>
            proc->state = PROC_RUNNABLE;
ffffffffc0206082:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0206084:	0e042623          	sw	zero,236(s0)
    if (flag) {
ffffffffc0206088:	e491                	bnez	s1,ffffffffc0206094 <wakeup_proc+0x34>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020608a:	60e2                	ld	ra,24(sp)
ffffffffc020608c:	6442                	ld	s0,16(sp)
ffffffffc020608e:	64a2                	ld	s1,8(sp)
ffffffffc0206090:	6105                	addi	sp,sp,32
ffffffffc0206092:	8082                	ret
ffffffffc0206094:	6442                	ld	s0,16(sp)
ffffffffc0206096:	60e2                	ld	ra,24(sp)
ffffffffc0206098:	64a2                	ld	s1,8(sp)
ffffffffc020609a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020609c:	da6fa06f          	j	ffffffffc0200642 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc02060a0:	00003617          	auipc	a2,0x3
ffffffffc02060a4:	93060613          	addi	a2,a2,-1744 # ffffffffc02089d0 <default_pmm_manager+0xa88>
ffffffffc02060a8:	45c9                	li	a1,18
ffffffffc02060aa:	00003517          	auipc	a0,0x3
ffffffffc02060ae:	90e50513          	addi	a0,a0,-1778 # ffffffffc02089b8 <default_pmm_manager+0xa70>
ffffffffc02060b2:	9befa0ef          	jal	ra,ffffffffc0200270 <__warn>
ffffffffc02060b6:	bfc9                	j	ffffffffc0206088 <wakeup_proc+0x28>
        intr_disable();
ffffffffc02060b8:	d90fa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc02060bc:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc02060be:	4485                	li	s1,1
ffffffffc02060c0:	bf75                	j	ffffffffc020607c <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02060c2:	00003697          	auipc	a3,0x3
ffffffffc02060c6:	8d668693          	addi	a3,a3,-1834 # ffffffffc0208998 <default_pmm_manager+0xa50>
ffffffffc02060ca:	00001617          	auipc	a2,0x1
ffffffffc02060ce:	ce660613          	addi	a2,a2,-794 # ffffffffc0206db0 <commands+0x410>
ffffffffc02060d2:	45a5                	li	a1,9
ffffffffc02060d4:	00003517          	auipc	a0,0x3
ffffffffc02060d8:	8e450513          	addi	a0,a0,-1820 # ffffffffc02089b8 <default_pmm_manager+0xa70>
ffffffffc02060dc:	92cfa0ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc02060e0 <schedule>:

void
schedule(void) {
ffffffffc02060e0:	1141                	addi	sp,sp,-16
ffffffffc02060e2:	e406                	sd	ra,8(sp)
ffffffffc02060e4:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02060e6:	100027f3          	csrr	a5,sstatus
ffffffffc02060ea:	8b89                	andi	a5,a5,2
ffffffffc02060ec:	4401                	li	s0,0
ffffffffc02060ee:	efbd                	bnez	a5,ffffffffc020616c <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02060f0:	000ac897          	auipc	a7,0xac
ffffffffc02060f4:	7508b883          	ld	a7,1872(a7) # ffffffffc02b2840 <current>
ffffffffc02060f8:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02060fc:	000ac517          	auipc	a0,0xac
ffffffffc0206100:	74c53503          	ld	a0,1868(a0) # ffffffffc02b2848 <idleproc>
ffffffffc0206104:	04a88e63          	beq	a7,a0,ffffffffc0206160 <schedule+0x80>
ffffffffc0206108:	0c888693          	addi	a3,a7,200
ffffffffc020610c:	000ac617          	auipc	a2,0xac
ffffffffc0206110:	6ac60613          	addi	a2,a2,1708 # ffffffffc02b27b8 <proc_list>
        le = last;
ffffffffc0206114:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0206116:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206118:	4809                	li	a6,2
ffffffffc020611a:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc020611c:	00c78863          	beq	a5,a2,ffffffffc020612c <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206120:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0206124:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206128:	03070163          	beq	a4,a6,ffffffffc020614a <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc020612c:	fef697e3          	bne	a3,a5,ffffffffc020611a <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206130:	ed89                	bnez	a1,ffffffffc020614a <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0206132:	451c                	lw	a5,8(a0)
ffffffffc0206134:	2785                	addiw	a5,a5,1
ffffffffc0206136:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0206138:	00a88463          	beq	a7,a0,ffffffffc0206140 <schedule+0x60>
            proc_run(next);
ffffffffc020613c:	e99fe0ef          	jal	ra,ffffffffc0204fd4 <proc_run>
    if (flag) {
ffffffffc0206140:	e819                	bnez	s0,ffffffffc0206156 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206142:	60a2                	ld	ra,8(sp)
ffffffffc0206144:	6402                	ld	s0,0(sp)
ffffffffc0206146:	0141                	addi	sp,sp,16
ffffffffc0206148:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020614a:	4198                	lw	a4,0(a1)
ffffffffc020614c:	4789                	li	a5,2
ffffffffc020614e:	fef712e3          	bne	a4,a5,ffffffffc0206132 <schedule+0x52>
ffffffffc0206152:	852e                	mv	a0,a1
ffffffffc0206154:	bff9                	j	ffffffffc0206132 <schedule+0x52>
}
ffffffffc0206156:	6402                	ld	s0,0(sp)
ffffffffc0206158:	60a2                	ld	ra,8(sp)
ffffffffc020615a:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020615c:	ce6fa06f          	j	ffffffffc0200642 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206160:	000ac617          	auipc	a2,0xac
ffffffffc0206164:	65860613          	addi	a2,a2,1624 # ffffffffc02b27b8 <proc_list>
ffffffffc0206168:	86b2                	mv	a3,a2
ffffffffc020616a:	b76d                	j	ffffffffc0206114 <schedule+0x34>
        intr_disable();
ffffffffc020616c:	cdcfa0ef          	jal	ra,ffffffffc0200648 <intr_disable>
        return 1;
ffffffffc0206170:	4405                	li	s0,1
ffffffffc0206172:	bfbd                	j	ffffffffc02060f0 <schedule+0x10>

ffffffffc0206174 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0206174:	000ac797          	auipc	a5,0xac
ffffffffc0206178:	6cc7b783          	ld	a5,1740(a5) # ffffffffc02b2840 <current>
}
ffffffffc020617c:	43c8                	lw	a0,4(a5)
ffffffffc020617e:	8082                	ret

ffffffffc0206180 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206180:	4501                	li	a0,0
ffffffffc0206182:	8082                	ret

ffffffffc0206184 <sys_putc>:
    cputchar(c);
ffffffffc0206184:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206186:	1141                	addi	sp,sp,-16
ffffffffc0206188:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc020618a:	f79f90ef          	jal	ra,ffffffffc0200102 <cputchar>
}
ffffffffc020618e:	60a2                	ld	ra,8(sp)
ffffffffc0206190:	4501                	li	a0,0
ffffffffc0206192:	0141                	addi	sp,sp,16
ffffffffc0206194:	8082                	ret

ffffffffc0206196 <sys_kill>:
    return do_kill(pid);
ffffffffc0206196:	4108                	lw	a0,0(a0)
ffffffffc0206198:	c9bff06f          	j	ffffffffc0205e32 <do_kill>

ffffffffc020619c <sys_yield>:
    return do_yield();
ffffffffc020619c:	c49ff06f          	j	ffffffffc0205de4 <do_yield>

ffffffffc02061a0 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02061a0:	6d14                	ld	a3,24(a0)
ffffffffc02061a2:	6910                	ld	a2,16(a0)
ffffffffc02061a4:	650c                	ld	a1,8(a0)
ffffffffc02061a6:	6108                	ld	a0,0(a0)
ffffffffc02061a8:	f2cff06f          	j	ffffffffc02058d4 <do_execve>

ffffffffc02061ac <sys_wait>:
    return do_wait(pid, store);
ffffffffc02061ac:	650c                	ld	a1,8(a0)
ffffffffc02061ae:	4108                	lw	a0,0(a0)
ffffffffc02061b0:	c45ff06f          	j	ffffffffc0205df4 <do_wait>

ffffffffc02061b4 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02061b4:	000ac797          	auipc	a5,0xac
ffffffffc02061b8:	68c7b783          	ld	a5,1676(a5) # ffffffffc02b2840 <current>
ffffffffc02061bc:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02061be:	4501                	li	a0,0
ffffffffc02061c0:	6a0c                	ld	a1,16(a2)
ffffffffc02061c2:	e7ffe06f          	j	ffffffffc0205040 <do_fork>

ffffffffc02061c6 <sys_exit>:
    return do_exit(error_code);
ffffffffc02061c6:	4108                	lw	a0,0(a0)
ffffffffc02061c8:	accff06f          	j	ffffffffc0205494 <do_exit>

ffffffffc02061cc <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02061cc:	715d                	addi	sp,sp,-80
ffffffffc02061ce:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02061d0:	000ac497          	auipc	s1,0xac
ffffffffc02061d4:	67048493          	addi	s1,s1,1648 # ffffffffc02b2840 <current>
ffffffffc02061d8:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02061da:	e0a2                	sd	s0,64(sp)
ffffffffc02061dc:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02061de:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02061e0:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02061e2:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02061e4:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02061e8:	0327ee63          	bltu	a5,s2,ffffffffc0206224 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02061ec:	00391713          	slli	a4,s2,0x3
ffffffffc02061f0:	00003797          	auipc	a5,0x3
ffffffffc02061f4:	84878793          	addi	a5,a5,-1976 # ffffffffc0208a38 <syscalls>
ffffffffc02061f8:	97ba                	add	a5,a5,a4
ffffffffc02061fa:	639c                	ld	a5,0(a5)
ffffffffc02061fc:	c785                	beqz	a5,ffffffffc0206224 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02061fe:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0206200:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0206202:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0206204:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0206206:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0206208:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc020620a:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc020620c:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc020620e:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0206210:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206212:	0028                	addi	a0,sp,8
ffffffffc0206214:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0206216:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206218:	e828                	sd	a0,80(s0)
}
ffffffffc020621a:	6406                	ld	s0,64(sp)
ffffffffc020621c:	74e2                	ld	s1,56(sp)
ffffffffc020621e:	7942                	ld	s2,48(sp)
ffffffffc0206220:	6161                	addi	sp,sp,80
ffffffffc0206222:	8082                	ret
    print_trapframe(tf);
ffffffffc0206224:	8522                	mv	a0,s0
ffffffffc0206226:	e10fa0ef          	jal	ra,ffffffffc0200836 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc020622a:	609c                	ld	a5,0(s1)
ffffffffc020622c:	86ca                	mv	a3,s2
ffffffffc020622e:	00002617          	auipc	a2,0x2
ffffffffc0206232:	7c260613          	addi	a2,a2,1986 # ffffffffc02089f0 <default_pmm_manager+0xaa8>
ffffffffc0206236:	43d8                	lw	a4,4(a5)
ffffffffc0206238:	06200593          	li	a1,98
ffffffffc020623c:	0b478793          	addi	a5,a5,180
ffffffffc0206240:	00002517          	auipc	a0,0x2
ffffffffc0206244:	7e050513          	addi	a0,a0,2016 # ffffffffc0208a20 <default_pmm_manager+0xad8>
ffffffffc0206248:	fc1f90ef          	jal	ra,ffffffffc0200208 <__panic>

ffffffffc020624c <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020624c:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0206250:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0206252:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0206254:	cb81                	beqz	a5,ffffffffc0206264 <strlen+0x18>
        cnt ++;
ffffffffc0206256:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0206258:	00a707b3          	add	a5,a4,a0
ffffffffc020625c:	0007c783          	lbu	a5,0(a5)
ffffffffc0206260:	fbfd                	bnez	a5,ffffffffc0206256 <strlen+0xa>
ffffffffc0206262:	8082                	ret
    }
    return cnt;
}
ffffffffc0206264:	8082                	ret

ffffffffc0206266 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0206266:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206268:	e589                	bnez	a1,ffffffffc0206272 <strnlen+0xc>
ffffffffc020626a:	a811                	j	ffffffffc020627e <strnlen+0x18>
        cnt ++;
ffffffffc020626c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020626e:	00f58863          	beq	a1,a5,ffffffffc020627e <strnlen+0x18>
ffffffffc0206272:	00f50733          	add	a4,a0,a5
ffffffffc0206276:	00074703          	lbu	a4,0(a4)
ffffffffc020627a:	fb6d                	bnez	a4,ffffffffc020626c <strnlen+0x6>
ffffffffc020627c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020627e:	852e                	mv	a0,a1
ffffffffc0206280:	8082                	ret

ffffffffc0206282 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206282:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206284:	0005c703          	lbu	a4,0(a1)
ffffffffc0206288:	0785                	addi	a5,a5,1
ffffffffc020628a:	0585                	addi	a1,a1,1
ffffffffc020628c:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206290:	fb75                	bnez	a4,ffffffffc0206284 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206292:	8082                	ret

ffffffffc0206294 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206294:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206298:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020629c:	cb89                	beqz	a5,ffffffffc02062ae <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020629e:	0505                	addi	a0,a0,1
ffffffffc02062a0:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02062a2:	fee789e3          	beq	a5,a4,ffffffffc0206294 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02062a6:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02062aa:	9d19                	subw	a0,a0,a4
ffffffffc02062ac:	8082                	ret
ffffffffc02062ae:	4501                	li	a0,0
ffffffffc02062b0:	bfed                	j	ffffffffc02062aa <strcmp+0x16>

ffffffffc02062b2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02062b2:	00054783          	lbu	a5,0(a0)
ffffffffc02062b6:	c799                	beqz	a5,ffffffffc02062c4 <strchr+0x12>
        if (*s == c) {
ffffffffc02062b8:	00f58763          	beq	a1,a5,ffffffffc02062c6 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02062bc:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02062c0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02062c2:	fbfd                	bnez	a5,ffffffffc02062b8 <strchr+0x6>
    }
    return NULL;
ffffffffc02062c4:	4501                	li	a0,0
}
ffffffffc02062c6:	8082                	ret

ffffffffc02062c8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02062c8:	ca01                	beqz	a2,ffffffffc02062d8 <memset+0x10>
ffffffffc02062ca:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02062cc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02062ce:	0785                	addi	a5,a5,1
ffffffffc02062d0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02062d4:	fec79de3          	bne	a5,a2,ffffffffc02062ce <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02062d8:	8082                	ret

ffffffffc02062da <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02062da:	ca19                	beqz	a2,ffffffffc02062f0 <memcpy+0x16>
ffffffffc02062dc:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02062de:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02062e0:	0005c703          	lbu	a4,0(a1)
ffffffffc02062e4:	0585                	addi	a1,a1,1
ffffffffc02062e6:	0785                	addi	a5,a5,1
ffffffffc02062e8:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02062ec:	fec59ae3          	bne	a1,a2,ffffffffc02062e0 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02062f0:	8082                	ret

ffffffffc02062f2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02062f2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02062f6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02062f8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02062fc:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02062fe:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206302:	f022                	sd	s0,32(sp)
ffffffffc0206304:	ec26                	sd	s1,24(sp)
ffffffffc0206306:	e84a                	sd	s2,16(sp)
ffffffffc0206308:	f406                	sd	ra,40(sp)
ffffffffc020630a:	e44e                	sd	s3,8(sp)
ffffffffc020630c:	84aa                	mv	s1,a0
ffffffffc020630e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0206310:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0206314:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0206316:	03067e63          	bgeu	a2,a6,ffffffffc0206352 <printnum+0x60>
ffffffffc020631a:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020631c:	00805763          	blez	s0,ffffffffc020632a <printnum+0x38>
ffffffffc0206320:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0206322:	85ca                	mv	a1,s2
ffffffffc0206324:	854e                	mv	a0,s3
ffffffffc0206326:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0206328:	fc65                	bnez	s0,ffffffffc0206320 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020632a:	1a02                	slli	s4,s4,0x20
ffffffffc020632c:	00003797          	auipc	a5,0x3
ffffffffc0206330:	80c78793          	addi	a5,a5,-2036 # ffffffffc0208b38 <syscalls+0x100>
ffffffffc0206334:	020a5a13          	srli	s4,s4,0x20
ffffffffc0206338:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc020633a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020633c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206340:	70a2                	ld	ra,40(sp)
ffffffffc0206342:	69a2                	ld	s3,8(sp)
ffffffffc0206344:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206346:	85ca                	mv	a1,s2
ffffffffc0206348:	87a6                	mv	a5,s1
}
ffffffffc020634a:	6942                	ld	s2,16(sp)
ffffffffc020634c:	64e2                	ld	s1,24(sp)
ffffffffc020634e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206350:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206352:	03065633          	divu	a2,a2,a6
ffffffffc0206356:	8722                	mv	a4,s0
ffffffffc0206358:	f9bff0ef          	jal	ra,ffffffffc02062f2 <printnum>
ffffffffc020635c:	b7f9                	j	ffffffffc020632a <printnum+0x38>

ffffffffc020635e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020635e:	7119                	addi	sp,sp,-128
ffffffffc0206360:	f4a6                	sd	s1,104(sp)
ffffffffc0206362:	f0ca                	sd	s2,96(sp)
ffffffffc0206364:	ecce                	sd	s3,88(sp)
ffffffffc0206366:	e8d2                	sd	s4,80(sp)
ffffffffc0206368:	e4d6                	sd	s5,72(sp)
ffffffffc020636a:	e0da                	sd	s6,64(sp)
ffffffffc020636c:	fc5e                	sd	s7,56(sp)
ffffffffc020636e:	f06a                	sd	s10,32(sp)
ffffffffc0206370:	fc86                	sd	ra,120(sp)
ffffffffc0206372:	f8a2                	sd	s0,112(sp)
ffffffffc0206374:	f862                	sd	s8,48(sp)
ffffffffc0206376:	f466                	sd	s9,40(sp)
ffffffffc0206378:	ec6e                	sd	s11,24(sp)
ffffffffc020637a:	892a                	mv	s2,a0
ffffffffc020637c:	84ae                	mv	s1,a1
ffffffffc020637e:	8d32                	mv	s10,a2
ffffffffc0206380:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206382:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0206386:	5b7d                	li	s6,-1
ffffffffc0206388:	00002a97          	auipc	s5,0x2
ffffffffc020638c:	7dca8a93          	addi	s5,s5,2012 # ffffffffc0208b64 <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206390:	00003b97          	auipc	s7,0x3
ffffffffc0206394:	9f0b8b93          	addi	s7,s7,-1552 # ffffffffc0208d80 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206398:	000d4503          	lbu	a0,0(s10)
ffffffffc020639c:	001d0413          	addi	s0,s10,1
ffffffffc02063a0:	01350a63          	beq	a0,s3,ffffffffc02063b4 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02063a4:	c121                	beqz	a0,ffffffffc02063e4 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02063a6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02063a8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02063aa:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02063ac:	fff44503          	lbu	a0,-1(s0)
ffffffffc02063b0:	ff351ae3          	bne	a0,s3,ffffffffc02063a4 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063b4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02063b8:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02063bc:	4c81                	li	s9,0
ffffffffc02063be:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02063c0:	5c7d                	li	s8,-1
ffffffffc02063c2:	5dfd                	li	s11,-1
ffffffffc02063c4:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02063c8:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063ca:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02063ce:	0ff5f593          	zext.b	a1,a1
ffffffffc02063d2:	00140d13          	addi	s10,s0,1
ffffffffc02063d6:	04b56263          	bltu	a0,a1,ffffffffc020641a <vprintfmt+0xbc>
ffffffffc02063da:	058a                	slli	a1,a1,0x2
ffffffffc02063dc:	95d6                	add	a1,a1,s5
ffffffffc02063de:	4194                	lw	a3,0(a1)
ffffffffc02063e0:	96d6                	add	a3,a3,s5
ffffffffc02063e2:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02063e4:	70e6                	ld	ra,120(sp)
ffffffffc02063e6:	7446                	ld	s0,112(sp)
ffffffffc02063e8:	74a6                	ld	s1,104(sp)
ffffffffc02063ea:	7906                	ld	s2,96(sp)
ffffffffc02063ec:	69e6                	ld	s3,88(sp)
ffffffffc02063ee:	6a46                	ld	s4,80(sp)
ffffffffc02063f0:	6aa6                	ld	s5,72(sp)
ffffffffc02063f2:	6b06                	ld	s6,64(sp)
ffffffffc02063f4:	7be2                	ld	s7,56(sp)
ffffffffc02063f6:	7c42                	ld	s8,48(sp)
ffffffffc02063f8:	7ca2                	ld	s9,40(sp)
ffffffffc02063fa:	7d02                	ld	s10,32(sp)
ffffffffc02063fc:	6de2                	ld	s11,24(sp)
ffffffffc02063fe:	6109                	addi	sp,sp,128
ffffffffc0206400:	8082                	ret
            padc = '0';
ffffffffc0206402:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0206404:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206408:	846a                	mv	s0,s10
ffffffffc020640a:	00140d13          	addi	s10,s0,1
ffffffffc020640e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0206412:	0ff5f593          	zext.b	a1,a1
ffffffffc0206416:	fcb572e3          	bgeu	a0,a1,ffffffffc02063da <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020641a:	85a6                	mv	a1,s1
ffffffffc020641c:	02500513          	li	a0,37
ffffffffc0206420:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0206422:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206426:	8d22                	mv	s10,s0
ffffffffc0206428:	f73788e3          	beq	a5,s3,ffffffffc0206398 <vprintfmt+0x3a>
ffffffffc020642c:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0206430:	1d7d                	addi	s10,s10,-1
ffffffffc0206432:	ff379de3          	bne	a5,s3,ffffffffc020642c <vprintfmt+0xce>
ffffffffc0206436:	b78d                	j	ffffffffc0206398 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0206438:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020643c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206440:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0206442:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0206446:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020644a:	02d86463          	bltu	a6,a3,ffffffffc0206472 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020644e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0206452:	002c169b          	slliw	a3,s8,0x2
ffffffffc0206456:	0186873b          	addw	a4,a3,s8
ffffffffc020645a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020645e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0206460:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0206464:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0206466:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020646a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020646e:	fed870e3          	bgeu	a6,a3,ffffffffc020644e <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0206472:	f40ddce3          	bgez	s11,ffffffffc02063ca <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0206476:	8de2                	mv	s11,s8
ffffffffc0206478:	5c7d                	li	s8,-1
ffffffffc020647a:	bf81                	j	ffffffffc02063ca <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020647c:	fffdc693          	not	a3,s11
ffffffffc0206480:	96fd                	srai	a3,a3,0x3f
ffffffffc0206482:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206486:	00144603          	lbu	a2,1(s0)
ffffffffc020648a:	2d81                	sext.w	s11,s11
ffffffffc020648c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020648e:	bf35                	j	ffffffffc02063ca <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0206490:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206494:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206498:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020649a:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020649c:	bfd9                	j	ffffffffc0206472 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020649e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02064a0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02064a4:	01174463          	blt	a4,a7,ffffffffc02064ac <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02064a8:	1a088e63          	beqz	a7,ffffffffc0206664 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02064ac:	000a3603          	ld	a2,0(s4)
ffffffffc02064b0:	46c1                	li	a3,16
ffffffffc02064b2:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02064b4:	2781                	sext.w	a5,a5
ffffffffc02064b6:	876e                	mv	a4,s11
ffffffffc02064b8:	85a6                	mv	a1,s1
ffffffffc02064ba:	854a                	mv	a0,s2
ffffffffc02064bc:	e37ff0ef          	jal	ra,ffffffffc02062f2 <printnum>
            break;
ffffffffc02064c0:	bde1                	j	ffffffffc0206398 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02064c2:	000a2503          	lw	a0,0(s4)
ffffffffc02064c6:	85a6                	mv	a1,s1
ffffffffc02064c8:	0a21                	addi	s4,s4,8
ffffffffc02064ca:	9902                	jalr	s2
            break;
ffffffffc02064cc:	b5f1                	j	ffffffffc0206398 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02064ce:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02064d0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02064d4:	01174463          	blt	a4,a7,ffffffffc02064dc <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02064d8:	18088163          	beqz	a7,ffffffffc020665a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02064dc:	000a3603          	ld	a2,0(s4)
ffffffffc02064e0:	46a9                	li	a3,10
ffffffffc02064e2:	8a2e                	mv	s4,a1
ffffffffc02064e4:	bfc1                	j	ffffffffc02064b4 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064e6:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02064ea:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064ec:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02064ee:	bdf1                	j	ffffffffc02063ca <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02064f0:	85a6                	mv	a1,s1
ffffffffc02064f2:	02500513          	li	a0,37
ffffffffc02064f6:	9902                	jalr	s2
            break;
ffffffffc02064f8:	b545                	j	ffffffffc0206398 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064fa:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02064fe:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206500:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206502:	b5e1                	j	ffffffffc02063ca <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0206504:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206506:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020650a:	01174463          	blt	a4,a7,ffffffffc0206512 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020650e:	14088163          	beqz	a7,ffffffffc0206650 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0206512:	000a3603          	ld	a2,0(s4)
ffffffffc0206516:	46a1                	li	a3,8
ffffffffc0206518:	8a2e                	mv	s4,a1
ffffffffc020651a:	bf69                	j	ffffffffc02064b4 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020651c:	03000513          	li	a0,48
ffffffffc0206520:	85a6                	mv	a1,s1
ffffffffc0206522:	e03e                	sd	a5,0(sp)
ffffffffc0206524:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0206526:	85a6                	mv	a1,s1
ffffffffc0206528:	07800513          	li	a0,120
ffffffffc020652c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020652e:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0206530:	6782                	ld	a5,0(sp)
ffffffffc0206532:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206534:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0206538:	bfb5                	j	ffffffffc02064b4 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020653a:	000a3403          	ld	s0,0(s4)
ffffffffc020653e:	008a0713          	addi	a4,s4,8
ffffffffc0206542:	e03a                	sd	a4,0(sp)
ffffffffc0206544:	14040263          	beqz	s0,ffffffffc0206688 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0206548:	0fb05763          	blez	s11,ffffffffc0206636 <vprintfmt+0x2d8>
ffffffffc020654c:	02d00693          	li	a3,45
ffffffffc0206550:	0cd79163          	bne	a5,a3,ffffffffc0206612 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206554:	00044783          	lbu	a5,0(s0)
ffffffffc0206558:	0007851b          	sext.w	a0,a5
ffffffffc020655c:	cf85                	beqz	a5,ffffffffc0206594 <vprintfmt+0x236>
ffffffffc020655e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206562:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206566:	000c4563          	bltz	s8,ffffffffc0206570 <vprintfmt+0x212>
ffffffffc020656a:	3c7d                	addiw	s8,s8,-1
ffffffffc020656c:	036c0263          	beq	s8,s6,ffffffffc0206590 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0206570:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206572:	0e0c8e63          	beqz	s9,ffffffffc020666e <vprintfmt+0x310>
ffffffffc0206576:	3781                	addiw	a5,a5,-32
ffffffffc0206578:	0ef47b63          	bgeu	s0,a5,ffffffffc020666e <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020657c:	03f00513          	li	a0,63
ffffffffc0206580:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206582:	000a4783          	lbu	a5,0(s4)
ffffffffc0206586:	3dfd                	addiw	s11,s11,-1
ffffffffc0206588:	0a05                	addi	s4,s4,1
ffffffffc020658a:	0007851b          	sext.w	a0,a5
ffffffffc020658e:	ffe1                	bnez	a5,ffffffffc0206566 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0206590:	01b05963          	blez	s11,ffffffffc02065a2 <vprintfmt+0x244>
ffffffffc0206594:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206596:	85a6                	mv	a1,s1
ffffffffc0206598:	02000513          	li	a0,32
ffffffffc020659c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020659e:	fe0d9be3          	bnez	s11,ffffffffc0206594 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02065a2:	6a02                	ld	s4,0(sp)
ffffffffc02065a4:	bbd5                	j	ffffffffc0206398 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02065a6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02065a8:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02065ac:	01174463          	blt	a4,a7,ffffffffc02065b4 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02065b0:	08088d63          	beqz	a7,ffffffffc020664a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02065b4:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02065b8:	0a044d63          	bltz	s0,ffffffffc0206672 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02065bc:	8622                	mv	a2,s0
ffffffffc02065be:	8a66                	mv	s4,s9
ffffffffc02065c0:	46a9                	li	a3,10
ffffffffc02065c2:	bdcd                	j	ffffffffc02064b4 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02065c4:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02065c8:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02065ca:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02065cc:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02065d0:	8fb5                	xor	a5,a5,a3
ffffffffc02065d2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02065d6:	02d74163          	blt	a4,a3,ffffffffc02065f8 <vprintfmt+0x29a>
ffffffffc02065da:	00369793          	slli	a5,a3,0x3
ffffffffc02065de:	97de                	add	a5,a5,s7
ffffffffc02065e0:	639c                	ld	a5,0(a5)
ffffffffc02065e2:	cb99                	beqz	a5,ffffffffc02065f8 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02065e4:	86be                	mv	a3,a5
ffffffffc02065e6:	00000617          	auipc	a2,0x0
ffffffffc02065ea:	13a60613          	addi	a2,a2,314 # ffffffffc0206720 <etext+0x2a>
ffffffffc02065ee:	85a6                	mv	a1,s1
ffffffffc02065f0:	854a                	mv	a0,s2
ffffffffc02065f2:	0ce000ef          	jal	ra,ffffffffc02066c0 <printfmt>
ffffffffc02065f6:	b34d                	j	ffffffffc0206398 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02065f8:	00002617          	auipc	a2,0x2
ffffffffc02065fc:	56060613          	addi	a2,a2,1376 # ffffffffc0208b58 <syscalls+0x120>
ffffffffc0206600:	85a6                	mv	a1,s1
ffffffffc0206602:	854a                	mv	a0,s2
ffffffffc0206604:	0bc000ef          	jal	ra,ffffffffc02066c0 <printfmt>
ffffffffc0206608:	bb41                	j	ffffffffc0206398 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020660a:	00002417          	auipc	s0,0x2
ffffffffc020660e:	54640413          	addi	s0,s0,1350 # ffffffffc0208b50 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206612:	85e2                	mv	a1,s8
ffffffffc0206614:	8522                	mv	a0,s0
ffffffffc0206616:	e43e                	sd	a5,8(sp)
ffffffffc0206618:	c4fff0ef          	jal	ra,ffffffffc0206266 <strnlen>
ffffffffc020661c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0206620:	01b05b63          	blez	s11,ffffffffc0206636 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0206624:	67a2                	ld	a5,8(sp)
ffffffffc0206626:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020662a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020662c:	85a6                	mv	a1,s1
ffffffffc020662e:	8552                	mv	a0,s4
ffffffffc0206630:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206632:	fe0d9ce3          	bnez	s11,ffffffffc020662a <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206636:	00044783          	lbu	a5,0(s0)
ffffffffc020663a:	00140a13          	addi	s4,s0,1
ffffffffc020663e:	0007851b          	sext.w	a0,a5
ffffffffc0206642:	d3a5                	beqz	a5,ffffffffc02065a2 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206644:	05e00413          	li	s0,94
ffffffffc0206648:	bf39                	j	ffffffffc0206566 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020664a:	000a2403          	lw	s0,0(s4)
ffffffffc020664e:	b7ad                	j	ffffffffc02065b8 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0206650:	000a6603          	lwu	a2,0(s4)
ffffffffc0206654:	46a1                	li	a3,8
ffffffffc0206656:	8a2e                	mv	s4,a1
ffffffffc0206658:	bdb1                	j	ffffffffc02064b4 <vprintfmt+0x156>
ffffffffc020665a:	000a6603          	lwu	a2,0(s4)
ffffffffc020665e:	46a9                	li	a3,10
ffffffffc0206660:	8a2e                	mv	s4,a1
ffffffffc0206662:	bd89                	j	ffffffffc02064b4 <vprintfmt+0x156>
ffffffffc0206664:	000a6603          	lwu	a2,0(s4)
ffffffffc0206668:	46c1                	li	a3,16
ffffffffc020666a:	8a2e                	mv	s4,a1
ffffffffc020666c:	b5a1                	j	ffffffffc02064b4 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020666e:	9902                	jalr	s2
ffffffffc0206670:	bf09                	j	ffffffffc0206582 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0206672:	85a6                	mv	a1,s1
ffffffffc0206674:	02d00513          	li	a0,45
ffffffffc0206678:	e03e                	sd	a5,0(sp)
ffffffffc020667a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020667c:	6782                	ld	a5,0(sp)
ffffffffc020667e:	8a66                	mv	s4,s9
ffffffffc0206680:	40800633          	neg	a2,s0
ffffffffc0206684:	46a9                	li	a3,10
ffffffffc0206686:	b53d                	j	ffffffffc02064b4 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0206688:	03b05163          	blez	s11,ffffffffc02066aa <vprintfmt+0x34c>
ffffffffc020668c:	02d00693          	li	a3,45
ffffffffc0206690:	f6d79de3          	bne	a5,a3,ffffffffc020660a <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0206694:	00002417          	auipc	s0,0x2
ffffffffc0206698:	4bc40413          	addi	s0,s0,1212 # ffffffffc0208b50 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020669c:	02800793          	li	a5,40
ffffffffc02066a0:	02800513          	li	a0,40
ffffffffc02066a4:	00140a13          	addi	s4,s0,1
ffffffffc02066a8:	bd6d                	j	ffffffffc0206562 <vprintfmt+0x204>
ffffffffc02066aa:	00002a17          	auipc	s4,0x2
ffffffffc02066ae:	4a7a0a13          	addi	s4,s4,1191 # ffffffffc0208b51 <syscalls+0x119>
ffffffffc02066b2:	02800513          	li	a0,40
ffffffffc02066b6:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02066ba:	05e00413          	li	s0,94
ffffffffc02066be:	b565                	j	ffffffffc0206566 <vprintfmt+0x208>

ffffffffc02066c0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02066c0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02066c2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02066c6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02066c8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02066ca:	ec06                	sd	ra,24(sp)
ffffffffc02066cc:	f83a                	sd	a4,48(sp)
ffffffffc02066ce:	fc3e                	sd	a5,56(sp)
ffffffffc02066d0:	e0c2                	sd	a6,64(sp)
ffffffffc02066d2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02066d4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02066d6:	c89ff0ef          	jal	ra,ffffffffc020635e <vprintfmt>
}
ffffffffc02066da:	60e2                	ld	ra,24(sp)
ffffffffc02066dc:	6161                	addi	sp,sp,80
ffffffffc02066de:	8082                	ret

ffffffffc02066e0 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02066e0:	9e3707b7          	lui	a5,0x9e370
ffffffffc02066e4:	2785                	addiw	a5,a5,1
ffffffffc02066e6:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc02066ea:	02000793          	li	a5,32
ffffffffc02066ee:	9f8d                	subw	a5,a5,a1
}
ffffffffc02066f0:	00f5553b          	srlw	a0,a0,a5
ffffffffc02066f4:	8082                	ret
