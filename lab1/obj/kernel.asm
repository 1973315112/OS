
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	1b9000ef          	jal	ra,802009da <memset>

    cons_init();  // init the console
    80200026:	14e000ef          	jal	ra,80200174 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	9c658593          	addi	a1,a1,-1594 # 802009f0 <etext+0x4>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	9de50513          	addi	a0,a0,-1570 # 80200a10 <etext+0x24>
    8020003a:	034000ef          	jal	ra,8020006e <cprintf>

    print_kerninfo();
    8020003e:	066000ef          	jal	ra,802000a4 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	142000ef          	jal	ra,80200184 <idt_init>
    __asm__ __volatile__("mret");  // 触发非法指令异常
    80200046:	30200073          	mret
    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    8020004a:	0e8000ef          	jal	ra,80200132 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004e:	130000ef          	jal	ra,8020017e <intr_enable>
    
    while (1)
    80200052:	a001                	j	80200052 <kern_init+0x48>

0000000080200054 <cputch>:
    80200054:	1141                	addi	sp,sp,-16
    80200056:	e022                	sd	s0,0(sp)
    80200058:	e406                	sd	ra,8(sp)
    8020005a:	842e                	mv	s0,a1
    8020005c:	11a000ef          	jal	ra,80200176 <cons_putc>
    80200060:	401c                	lw	a5,0(s0)
    80200062:	60a2                	ld	ra,8(sp)
    80200064:	2785                	addiw	a5,a5,1
    80200066:	c01c                	sw	a5,0(s0)
    80200068:	6402                	ld	s0,0(sp)
    8020006a:	0141                	addi	sp,sp,16
    8020006c:	8082                	ret

000000008020006e <cprintf>:
    8020006e:	711d                	addi	sp,sp,-96
    80200070:	02810313          	addi	t1,sp,40 # 80204028 <end>
    80200074:	8e2a                	mv	t3,a0
    80200076:	f42e                	sd	a1,40(sp)
    80200078:	f832                	sd	a2,48(sp)
    8020007a:	fc36                	sd	a3,56(sp)
    8020007c:	00000517          	auipc	a0,0x0
    80200080:	fd850513          	addi	a0,a0,-40 # 80200054 <cputch>
    80200084:	004c                	addi	a1,sp,4
    80200086:	869a                	mv	a3,t1
    80200088:	8672                	mv	a2,t3
    8020008a:	ec06                	sd	ra,24(sp)
    8020008c:	e0ba                	sd	a4,64(sp)
    8020008e:	e4be                	sd	a5,72(sp)
    80200090:	e8c2                	sd	a6,80(sp)
    80200092:	ecc6                	sd	a7,88(sp)
    80200094:	e41a                	sd	t1,8(sp)
    80200096:	c202                	sw	zero,4(sp)
    80200098:	556000ef          	jal	ra,802005ee <vprintfmt>
    8020009c:	60e2                	ld	ra,24(sp)
    8020009e:	4512                	lw	a0,4(sp)
    802000a0:	6125                	addi	sp,sp,96
    802000a2:	8082                	ret

00000000802000a4 <print_kerninfo>:
    802000a4:	1141                	addi	sp,sp,-16
    802000a6:	00001517          	auipc	a0,0x1
    802000aa:	97250513          	addi	a0,a0,-1678 # 80200a18 <etext+0x2c>
    802000ae:	e406                	sd	ra,8(sp)
    802000b0:	fbfff0ef          	jal	ra,8020006e <cprintf>
    802000b4:	00000597          	auipc	a1,0x0
    802000b8:	f5658593          	addi	a1,a1,-170 # 8020000a <kern_init>
    802000bc:	00001517          	auipc	a0,0x1
    802000c0:	97c50513          	addi	a0,a0,-1668 # 80200a38 <etext+0x4c>
    802000c4:	fabff0ef          	jal	ra,8020006e <cprintf>
    802000c8:	00001597          	auipc	a1,0x1
    802000cc:	92458593          	addi	a1,a1,-1756 # 802009ec <etext>
    802000d0:	00001517          	auipc	a0,0x1
    802000d4:	98850513          	addi	a0,a0,-1656 # 80200a58 <etext+0x6c>
    802000d8:	f97ff0ef          	jal	ra,8020006e <cprintf>
    802000dc:	00004597          	auipc	a1,0x4
    802000e0:	f3458593          	addi	a1,a1,-204 # 80204010 <ticks>
    802000e4:	00001517          	auipc	a0,0x1
    802000e8:	99450513          	addi	a0,a0,-1644 # 80200a78 <etext+0x8c>
    802000ec:	f83ff0ef          	jal	ra,8020006e <cprintf>
    802000f0:	00004597          	auipc	a1,0x4
    802000f4:	f3858593          	addi	a1,a1,-200 # 80204028 <end>
    802000f8:	00001517          	auipc	a0,0x1
    802000fc:	9a050513          	addi	a0,a0,-1632 # 80200a98 <etext+0xac>
    80200100:	f6fff0ef          	jal	ra,8020006e <cprintf>
    80200104:	00004597          	auipc	a1,0x4
    80200108:	32358593          	addi	a1,a1,803 # 80204427 <end+0x3ff>
    8020010c:	00000797          	auipc	a5,0x0
    80200110:	efe78793          	addi	a5,a5,-258 # 8020000a <kern_init>
    80200114:	40f587b3          	sub	a5,a1,a5
    80200118:	43f7d593          	srai	a1,a5,0x3f
    8020011c:	60a2                	ld	ra,8(sp)
    8020011e:	3ff5f593          	andi	a1,a1,1023
    80200122:	95be                	add	a1,a1,a5
    80200124:	85a9                	srai	a1,a1,0xa
    80200126:	00001517          	auipc	a0,0x1
    8020012a:	99250513          	addi	a0,a0,-1646 # 80200ab8 <etext+0xcc>
    8020012e:	0141                	addi	sp,sp,16
    80200130:	bf3d                	j	8020006e <cprintf>

0000000080200132 <clock_init>:
    80200132:	1141                	addi	sp,sp,-16
    80200134:	e406                	sd	ra,8(sp)
    80200136:	02000793          	li	a5,32
    8020013a:	1047a7f3          	csrrs	a5,sie,a5
    8020013e:	c0102573          	rdtime	a0
    80200142:	67e1                	lui	a5,0x18
    80200144:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200148:	953e                	add	a0,a0,a5
    8020014a:	041000ef          	jal	ra,8020098a <sbi_set_timer>
    8020014e:	60a2                	ld	ra,8(sp)
    80200150:	00004797          	auipc	a5,0x4
    80200154:	ec07b023          	sd	zero,-320(a5) # 80204010 <ticks>
    80200158:	00001517          	auipc	a0,0x1
    8020015c:	99050513          	addi	a0,a0,-1648 # 80200ae8 <etext+0xfc>
    80200160:	0141                	addi	sp,sp,16
    80200162:	b731                	j	8020006e <cprintf>

0000000080200164 <clock_set_next_event>:
    80200164:	c0102573          	rdtime	a0
    80200168:	67e1                	lui	a5,0x18
    8020016a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    8020016e:	953e                	add	a0,a0,a5
    80200170:	01b0006f          	j	8020098a <sbi_set_timer>

0000000080200174 <cons_init>:
    80200174:	8082                	ret

0000000080200176 <cons_putc>:
    80200176:	0ff57513          	zext.b	a0,a0
    8020017a:	7f60006f          	j	80200970 <sbi_console_putchar>

000000008020017e <intr_enable>:
    8020017e:	100167f3          	csrrsi	a5,sstatus,2
    80200182:	8082                	ret

0000000080200184 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200184:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200188:	00000797          	auipc	a5,0x0
    8020018c:	34478793          	addi	a5,a5,836 # 802004cc <__alltraps>
    80200190:	10579073          	csrw	stvec,a5
}
    80200194:	8082                	ret

0000000080200196 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200196:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200198:	1141                	addi	sp,sp,-16
    8020019a:	e022                	sd	s0,0(sp)
    8020019c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019e:	00001517          	auipc	a0,0x1
    802001a2:	96a50513          	addi	a0,a0,-1686 # 80200b08 <etext+0x11c>
void print_regs(struct pushregs *gpr) {
    802001a6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a8:	ec7ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001ac:	640c                	ld	a1,8(s0)
    802001ae:	00001517          	auipc	a0,0x1
    802001b2:	97250513          	addi	a0,a0,-1678 # 80200b20 <etext+0x134>
    802001b6:	eb9ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001ba:	680c                	ld	a1,16(s0)
    802001bc:	00001517          	auipc	a0,0x1
    802001c0:	97c50513          	addi	a0,a0,-1668 # 80200b38 <etext+0x14c>
    802001c4:	eabff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c8:	6c0c                	ld	a1,24(s0)
    802001ca:	00001517          	auipc	a0,0x1
    802001ce:	98650513          	addi	a0,a0,-1658 # 80200b50 <etext+0x164>
    802001d2:	e9dff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d6:	700c                	ld	a1,32(s0)
    802001d8:	00001517          	auipc	a0,0x1
    802001dc:	99050513          	addi	a0,a0,-1648 # 80200b68 <etext+0x17c>
    802001e0:	e8fff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e4:	740c                	ld	a1,40(s0)
    802001e6:	00001517          	auipc	a0,0x1
    802001ea:	99a50513          	addi	a0,a0,-1638 # 80200b80 <etext+0x194>
    802001ee:	e81ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f2:	780c                	ld	a1,48(s0)
    802001f4:	00001517          	auipc	a0,0x1
    802001f8:	9a450513          	addi	a0,a0,-1628 # 80200b98 <etext+0x1ac>
    802001fc:	e73ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200200:	7c0c                	ld	a1,56(s0)
    80200202:	00001517          	auipc	a0,0x1
    80200206:	9ae50513          	addi	a0,a0,-1618 # 80200bb0 <etext+0x1c4>
    8020020a:	e65ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    8020020e:	602c                	ld	a1,64(s0)
    80200210:	00001517          	auipc	a0,0x1
    80200214:	9b850513          	addi	a0,a0,-1608 # 80200bc8 <etext+0x1dc>
    80200218:	e57ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020021c:	642c                	ld	a1,72(s0)
    8020021e:	00001517          	auipc	a0,0x1
    80200222:	9c250513          	addi	a0,a0,-1598 # 80200be0 <etext+0x1f4>
    80200226:	e49ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020022a:	682c                	ld	a1,80(s0)
    8020022c:	00001517          	auipc	a0,0x1
    80200230:	9cc50513          	addi	a0,a0,-1588 # 80200bf8 <etext+0x20c>
    80200234:	e3bff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200238:	6c2c                	ld	a1,88(s0)
    8020023a:	00001517          	auipc	a0,0x1
    8020023e:	9d650513          	addi	a0,a0,-1578 # 80200c10 <etext+0x224>
    80200242:	e2dff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200246:	702c                	ld	a1,96(s0)
    80200248:	00001517          	auipc	a0,0x1
    8020024c:	9e050513          	addi	a0,a0,-1568 # 80200c28 <etext+0x23c>
    80200250:	e1fff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200254:	742c                	ld	a1,104(s0)
    80200256:	00001517          	auipc	a0,0x1
    8020025a:	9ea50513          	addi	a0,a0,-1558 # 80200c40 <etext+0x254>
    8020025e:	e11ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200262:	782c                	ld	a1,112(s0)
    80200264:	00001517          	auipc	a0,0x1
    80200268:	9f450513          	addi	a0,a0,-1548 # 80200c58 <etext+0x26c>
    8020026c:	e03ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200270:	7c2c                	ld	a1,120(s0)
    80200272:	00001517          	auipc	a0,0x1
    80200276:	9fe50513          	addi	a0,a0,-1538 # 80200c70 <etext+0x284>
    8020027a:	df5ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020027e:	604c                	ld	a1,128(s0)
    80200280:	00001517          	auipc	a0,0x1
    80200284:	a0850513          	addi	a0,a0,-1528 # 80200c88 <etext+0x29c>
    80200288:	de7ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020028c:	644c                	ld	a1,136(s0)
    8020028e:	00001517          	auipc	a0,0x1
    80200292:	a1250513          	addi	a0,a0,-1518 # 80200ca0 <etext+0x2b4>
    80200296:	dd9ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020029a:	684c                	ld	a1,144(s0)
    8020029c:	00001517          	auipc	a0,0x1
    802002a0:	a1c50513          	addi	a0,a0,-1508 # 80200cb8 <etext+0x2cc>
    802002a4:	dcbff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a8:	6c4c                	ld	a1,152(s0)
    802002aa:	00001517          	auipc	a0,0x1
    802002ae:	a2650513          	addi	a0,a0,-1498 # 80200cd0 <etext+0x2e4>
    802002b2:	dbdff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b6:	704c                	ld	a1,160(s0)
    802002b8:	00001517          	auipc	a0,0x1
    802002bc:	a3050513          	addi	a0,a0,-1488 # 80200ce8 <etext+0x2fc>
    802002c0:	dafff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c4:	744c                	ld	a1,168(s0)
    802002c6:	00001517          	auipc	a0,0x1
    802002ca:	a3a50513          	addi	a0,a0,-1478 # 80200d00 <etext+0x314>
    802002ce:	da1ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d2:	784c                	ld	a1,176(s0)
    802002d4:	00001517          	auipc	a0,0x1
    802002d8:	a4450513          	addi	a0,a0,-1468 # 80200d18 <etext+0x32c>
    802002dc:	d93ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e0:	7c4c                	ld	a1,184(s0)
    802002e2:	00001517          	auipc	a0,0x1
    802002e6:	a4e50513          	addi	a0,a0,-1458 # 80200d30 <etext+0x344>
    802002ea:	d85ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002ee:	606c                	ld	a1,192(s0)
    802002f0:	00001517          	auipc	a0,0x1
    802002f4:	a5850513          	addi	a0,a0,-1448 # 80200d48 <etext+0x35c>
    802002f8:	d77ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002fc:	646c                	ld	a1,200(s0)
    802002fe:	00001517          	auipc	a0,0x1
    80200302:	a6250513          	addi	a0,a0,-1438 # 80200d60 <etext+0x374>
    80200306:	d69ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020030a:	686c                	ld	a1,208(s0)
    8020030c:	00001517          	auipc	a0,0x1
    80200310:	a6c50513          	addi	a0,a0,-1428 # 80200d78 <etext+0x38c>
    80200314:	d5bff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200318:	6c6c                	ld	a1,216(s0)
    8020031a:	00001517          	auipc	a0,0x1
    8020031e:	a7650513          	addi	a0,a0,-1418 # 80200d90 <etext+0x3a4>
    80200322:	d4dff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200326:	706c                	ld	a1,224(s0)
    80200328:	00001517          	auipc	a0,0x1
    8020032c:	a8050513          	addi	a0,a0,-1408 # 80200da8 <etext+0x3bc>
    80200330:	d3fff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200334:	746c                	ld	a1,232(s0)
    80200336:	00001517          	auipc	a0,0x1
    8020033a:	a8a50513          	addi	a0,a0,-1398 # 80200dc0 <etext+0x3d4>
    8020033e:	d31ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200342:	786c                	ld	a1,240(s0)
    80200344:	00001517          	auipc	a0,0x1
    80200348:	a9450513          	addi	a0,a0,-1388 # 80200dd8 <etext+0x3ec>
    8020034c:	d23ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200350:	7c6c                	ld	a1,248(s0)
}
    80200352:	6402                	ld	s0,0(sp)
    80200354:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200356:	00001517          	auipc	a0,0x1
    8020035a:	a9a50513          	addi	a0,a0,-1382 # 80200df0 <etext+0x404>
}
    8020035e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200360:	b339                	j	8020006e <cprintf>

0000000080200362 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200362:	1141                	addi	sp,sp,-16
    80200364:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200366:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200368:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    8020036a:	00001517          	auipc	a0,0x1
    8020036e:	a9e50513          	addi	a0,a0,-1378 # 80200e08 <etext+0x41c>
void print_trapframe(struct trapframe *tf) {
    80200372:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200374:	cfbff0ef          	jal	ra,8020006e <cprintf>
    print_regs(&tf->gpr);
    80200378:	8522                	mv	a0,s0
    8020037a:	e1dff0ef          	jal	ra,80200196 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    8020037e:	10043583          	ld	a1,256(s0)
    80200382:	00001517          	auipc	a0,0x1
    80200386:	a9e50513          	addi	a0,a0,-1378 # 80200e20 <etext+0x434>
    8020038a:	ce5ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    8020038e:	10843583          	ld	a1,264(s0)
    80200392:	00001517          	auipc	a0,0x1
    80200396:	aa650513          	addi	a0,a0,-1370 # 80200e38 <etext+0x44c>
    8020039a:	cd5ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    8020039e:	11043583          	ld	a1,272(s0)
    802003a2:	00001517          	auipc	a0,0x1
    802003a6:	aae50513          	addi	a0,a0,-1362 # 80200e50 <etext+0x464>
    802003aa:	cc5ff0ef          	jal	ra,8020006e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003ae:	11843583          	ld	a1,280(s0)
}
    802003b2:	6402                	ld	s0,0(sp)
    802003b4:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b6:	00001517          	auipc	a0,0x1
    802003ba:	ab250513          	addi	a0,a0,-1358 # 80200e68 <etext+0x47c>
}
    802003be:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c0:	b17d                	j	8020006e <cprintf>

00000000802003c2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c2:	11853783          	ld	a5,280(a0)
    802003c6:	472d                	li	a4,11
    802003c8:	0786                	slli	a5,a5,0x1
    802003ca:	8385                	srli	a5,a5,0x1
    802003cc:	06f76763          	bltu	a4,a5,8020043a <interrupt_handler+0x78>
    802003d0:	00001717          	auipc	a4,0x1
    802003d4:	b6070713          	addi	a4,a4,-1184 # 80200f30 <etext+0x544>
    802003d8:	078a                	slli	a5,a5,0x2
    802003da:	97ba                	add	a5,a5,a4
    802003dc:	439c                	lw	a5,0(a5)
    802003de:	97ba                	add	a5,a5,a4
    802003e0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003e2:	00001517          	auipc	a0,0x1
    802003e6:	afe50513          	addi	a0,a0,-1282 # 80200ee0 <etext+0x4f4>
    802003ea:	b151                	j	8020006e <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003ec:	00001517          	auipc	a0,0x1
    802003f0:	ad450513          	addi	a0,a0,-1324 # 80200ec0 <etext+0x4d4>
    802003f4:	b9ad                	j	8020006e <cprintf>
            cprintf("User software interrupt\n");
    802003f6:	00001517          	auipc	a0,0x1
    802003fa:	a8a50513          	addi	a0,a0,-1398 # 80200e80 <etext+0x494>
    802003fe:	b985                	j	8020006e <cprintf>
            cprintf("Supervisor software interrupt\n");
    80200400:	00001517          	auipc	a0,0x1
    80200404:	aa050513          	addi	a0,a0,-1376 # 80200ea0 <etext+0x4b4>
    80200408:	b19d                	j	8020006e <cprintf>
void interrupt_handler(struct trapframe *tf) {
    8020040a:	1141                	addi	sp,sp,-16
    8020040c:	e406                	sd	ra,8(sp)
             *(4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            //
            //cprintf("Supervisor timer interrupt\n");//不确定该行到底是否需要，暂时注释
            //(1)设置下次时钟中断
            clock_set_next_event();
    8020040e:	d57ff0ef          	jal	ra,80200164 <clock_set_next_event>
            //(2)计数器（ticks）加一
            ticks++;
    80200412:	00004797          	auipc	a5,0x4
    80200416:	bfe78793          	addi	a5,a5,-1026 # 80204010 <ticks>
    8020041a:	6398                	ld	a4,0(a5)
            //(3)计数器为100时，输出`100ticks`，num加一
            if(ticks==100)
    8020041c:	06400693          	li	a3,100
            ticks++;
    80200420:	0705                	addi	a4,a4,1
    80200422:	e398                	sd	a4,0(a5)
            if(ticks==100)
    80200424:	639c                	ld	a5,0(a5)
    80200426:	00d78b63          	beq	a5,a3,8020043c <interrupt_handler+0x7a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020042a:	60a2                	ld	ra,8(sp)
    8020042c:	0141                	addi	sp,sp,16
    8020042e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    80200430:	00001517          	auipc	a0,0x1
    80200434:	ae050513          	addi	a0,a0,-1312 # 80200f10 <etext+0x524>
    80200438:	b91d                	j	8020006e <cprintf>
            print_trapframe(tf);
    8020043a:	b725                	j	80200362 <print_trapframe>
                cprintf("100ticks\n");
    8020043c:	00001517          	auipc	a0,0x1
    80200440:	ac450513          	addi	a0,a0,-1340 # 80200f00 <etext+0x514>
    80200444:	c2bff0ef          	jal	ra,8020006e <cprintf>
                ticks=0;
    80200448:	00004797          	auipc	a5,0x4
    8020044c:	bc07b423          	sd	zero,-1080(a5) # 80204010 <ticks>
                num++;
    80200450:	00004797          	auipc	a5,0x4
    80200454:	bc878793          	addi	a5,a5,-1080 # 80204018 <num>
    80200458:	6398                	ld	a4,0(a5)
                if(num==10) sbi_shutdown();
    8020045a:	46a9                	li	a3,10
                num++;
    8020045c:	0705                	addi	a4,a4,1
    8020045e:	e398                	sd	a4,0(a5)
                if(num==10) sbi_shutdown();
    80200460:	639c                	ld	a5,0(a5)
    80200462:	fcd794e3          	bne	a5,a3,8020042a <interrupt_handler+0x68>
}
    80200466:	60a2                	ld	ra,8(sp)
    80200468:	0141                	addi	sp,sp,16
                if(num==10) sbi_shutdown();
    8020046a:	ab2d                	j	802009a4 <sbi_shutdown>

000000008020046c <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020046c:	11853783          	ld	a5,280(a0)
    80200470:	4709                	li	a4,2
    80200472:	00e78b63          	beq	a5,a4,80200488 <exception_handler+0x1c>
    80200476:	00f77863          	bgeu	a4,a5,80200486 <exception_handler+0x1a>
    8020047a:	17f5                	addi	a5,a5,-3
    8020047c:	4721                	li	a4,8
    8020047e:	00f77363          	bgeu	a4,a5,80200484 <exception_handler+0x18>
        case CAUSE_HYPERVISOR_ECALL:
            break;
        case CAUSE_MACHINE_ECALL:
            break;
        default:
            print_trapframe(tf);
    80200482:	b5c5                	j	80200362 <print_trapframe>
    80200484:	8082                	ret
    80200486:	8082                	ret
void exception_handler(struct trapframe *tf) {
    80200488:	1141                	addi	sp,sp,-16
    8020048a:	e022                	sd	s0,0(sp)
    8020048c:	842a                	mv	s0,a0
            cprintf("Exception type:Illegal instruction\n");
    8020048e:	00001517          	auipc	a0,0x1
    80200492:	ad250513          	addi	a0,a0,-1326 # 80200f60 <etext+0x574>
void exception_handler(struct trapframe *tf) {
    80200496:	e406                	sd	ra,8(sp)
            cprintf("Exception type:Illegal instruction\n");
    80200498:	bd7ff0ef          	jal	ra,8020006e <cprintf>
            cprintf("Illegal instruction at 0x%08x\n", tf->epc);
    8020049c:	10843583          	ld	a1,264(s0)
    802004a0:	00001517          	auipc	a0,0x1
    802004a4:	ae850513          	addi	a0,a0,-1304 # 80200f88 <etext+0x59c>
    802004a8:	bc7ff0ef          	jal	ra,8020006e <cprintf>
            tf->epc +=4;
    802004ac:	10843783          	ld	a5,264(s0)
            break;
    }
}
    802004b0:	60a2                	ld	ra,8(sp)
            tf->epc +=4;
    802004b2:	0791                	addi	a5,a5,4
    802004b4:	10f43423          	sd	a5,264(s0)
}
    802004b8:	6402                	ld	s0,0(sp)
    802004ba:	0141                	addi	sp,sp,16
    802004bc:	8082                	ret

00000000802004be <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    802004be:	11853783          	ld	a5,280(a0)
    802004c2:	0007c363          	bltz	a5,802004c8 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    802004c6:	b75d                	j	8020046c <exception_handler>
        interrupt_handler(tf);
    802004c8:	bded                	j	802003c2 <interrupt_handler>
	...

00000000802004cc <__alltraps>:
    802004cc:	14011073          	csrw	sscratch,sp
    802004d0:	712d                	addi	sp,sp,-288
    802004d2:	e002                	sd	zero,0(sp)
    802004d4:	e406                	sd	ra,8(sp)
    802004d6:	ec0e                	sd	gp,24(sp)
    802004d8:	f012                	sd	tp,32(sp)
    802004da:	f416                	sd	t0,40(sp)
    802004dc:	f81a                	sd	t1,48(sp)
    802004de:	fc1e                	sd	t2,56(sp)
    802004e0:	e0a2                	sd	s0,64(sp)
    802004e2:	e4a6                	sd	s1,72(sp)
    802004e4:	e8aa                	sd	a0,80(sp)
    802004e6:	ecae                	sd	a1,88(sp)
    802004e8:	f0b2                	sd	a2,96(sp)
    802004ea:	f4b6                	sd	a3,104(sp)
    802004ec:	f8ba                	sd	a4,112(sp)
    802004ee:	fcbe                	sd	a5,120(sp)
    802004f0:	e142                	sd	a6,128(sp)
    802004f2:	e546                	sd	a7,136(sp)
    802004f4:	e94a                	sd	s2,144(sp)
    802004f6:	ed4e                	sd	s3,152(sp)
    802004f8:	f152                	sd	s4,160(sp)
    802004fa:	f556                	sd	s5,168(sp)
    802004fc:	f95a                	sd	s6,176(sp)
    802004fe:	fd5e                	sd	s7,184(sp)
    80200500:	e1e2                	sd	s8,192(sp)
    80200502:	e5e6                	sd	s9,200(sp)
    80200504:	e9ea                	sd	s10,208(sp)
    80200506:	edee                	sd	s11,216(sp)
    80200508:	f1f2                	sd	t3,224(sp)
    8020050a:	f5f6                	sd	t4,232(sp)
    8020050c:	f9fa                	sd	t5,240(sp)
    8020050e:	fdfe                	sd	t6,248(sp)
    80200510:	14001473          	csrrw	s0,sscratch,zero
    80200514:	100024f3          	csrr	s1,sstatus
    80200518:	14102973          	csrr	s2,sepc
    8020051c:	143029f3          	csrr	s3,stval
    80200520:	14202a73          	csrr	s4,scause
    80200524:	e822                	sd	s0,16(sp)
    80200526:	e226                	sd	s1,256(sp)
    80200528:	e64a                	sd	s2,264(sp)
    8020052a:	ea4e                	sd	s3,272(sp)
    8020052c:	ee52                	sd	s4,280(sp)
    8020052e:	850a                	mv	a0,sp
    80200530:	f8fff0ef          	jal	ra,802004be <trap>

0000000080200534 <__trapret>:
    80200534:	6492                	ld	s1,256(sp)
    80200536:	6932                	ld	s2,264(sp)
    80200538:	10049073          	csrw	sstatus,s1
    8020053c:	14191073          	csrw	sepc,s2
    80200540:	60a2                	ld	ra,8(sp)
    80200542:	61e2                	ld	gp,24(sp)
    80200544:	7202                	ld	tp,32(sp)
    80200546:	72a2                	ld	t0,40(sp)
    80200548:	7342                	ld	t1,48(sp)
    8020054a:	73e2                	ld	t2,56(sp)
    8020054c:	6406                	ld	s0,64(sp)
    8020054e:	64a6                	ld	s1,72(sp)
    80200550:	6546                	ld	a0,80(sp)
    80200552:	65e6                	ld	a1,88(sp)
    80200554:	7606                	ld	a2,96(sp)
    80200556:	76a6                	ld	a3,104(sp)
    80200558:	7746                	ld	a4,112(sp)
    8020055a:	77e6                	ld	a5,120(sp)
    8020055c:	680a                	ld	a6,128(sp)
    8020055e:	68aa                	ld	a7,136(sp)
    80200560:	694a                	ld	s2,144(sp)
    80200562:	69ea                	ld	s3,152(sp)
    80200564:	7a0a                	ld	s4,160(sp)
    80200566:	7aaa                	ld	s5,168(sp)
    80200568:	7b4a                	ld	s6,176(sp)
    8020056a:	7bea                	ld	s7,184(sp)
    8020056c:	6c0e                	ld	s8,192(sp)
    8020056e:	6cae                	ld	s9,200(sp)
    80200570:	6d4e                	ld	s10,208(sp)
    80200572:	6dee                	ld	s11,216(sp)
    80200574:	7e0e                	ld	t3,224(sp)
    80200576:	7eae                	ld	t4,232(sp)
    80200578:	7f4e                	ld	t5,240(sp)
    8020057a:	7fee                	ld	t6,248(sp)
    8020057c:	6142                	ld	sp,16(sp)
    8020057e:	10200073          	sret

0000000080200582 <printnum>:
    80200582:	02069813          	slli	a6,a3,0x20
    80200586:	7179                	addi	sp,sp,-48
    80200588:	02085813          	srli	a6,a6,0x20
    8020058c:	e052                	sd	s4,0(sp)
    8020058e:	03067a33          	remu	s4,a2,a6
    80200592:	f022                	sd	s0,32(sp)
    80200594:	ec26                	sd	s1,24(sp)
    80200596:	e84a                	sd	s2,16(sp)
    80200598:	f406                	sd	ra,40(sp)
    8020059a:	e44e                	sd	s3,8(sp)
    8020059c:	84aa                	mv	s1,a0
    8020059e:	892e                	mv	s2,a1
    802005a0:	fff7041b          	addiw	s0,a4,-1
    802005a4:	2a01                	sext.w	s4,s4
    802005a6:	03067e63          	bgeu	a2,a6,802005e2 <printnum+0x60>
    802005aa:	89be                	mv	s3,a5
    802005ac:	00805763          	blez	s0,802005ba <printnum+0x38>
    802005b0:	347d                	addiw	s0,s0,-1
    802005b2:	85ca                	mv	a1,s2
    802005b4:	854e                	mv	a0,s3
    802005b6:	9482                	jalr	s1
    802005b8:	fc65                	bnez	s0,802005b0 <printnum+0x2e>
    802005ba:	1a02                	slli	s4,s4,0x20
    802005bc:	00001797          	auipc	a5,0x1
    802005c0:	9ec78793          	addi	a5,a5,-1556 # 80200fa8 <etext+0x5bc>
    802005c4:	020a5a13          	srli	s4,s4,0x20
    802005c8:	9a3e                	add	s4,s4,a5
    802005ca:	7402                	ld	s0,32(sp)
    802005cc:	000a4503          	lbu	a0,0(s4)
    802005d0:	70a2                	ld	ra,40(sp)
    802005d2:	69a2                	ld	s3,8(sp)
    802005d4:	6a02                	ld	s4,0(sp)
    802005d6:	85ca                	mv	a1,s2
    802005d8:	87a6                	mv	a5,s1
    802005da:	6942                	ld	s2,16(sp)
    802005dc:	64e2                	ld	s1,24(sp)
    802005de:	6145                	addi	sp,sp,48
    802005e0:	8782                	jr	a5
    802005e2:	03065633          	divu	a2,a2,a6
    802005e6:	8722                	mv	a4,s0
    802005e8:	f9bff0ef          	jal	ra,80200582 <printnum>
    802005ec:	b7f9                	j	802005ba <printnum+0x38>

00000000802005ee <vprintfmt>:
    802005ee:	7119                	addi	sp,sp,-128
    802005f0:	f4a6                	sd	s1,104(sp)
    802005f2:	f0ca                	sd	s2,96(sp)
    802005f4:	ecce                	sd	s3,88(sp)
    802005f6:	e8d2                	sd	s4,80(sp)
    802005f8:	e4d6                	sd	s5,72(sp)
    802005fa:	e0da                	sd	s6,64(sp)
    802005fc:	fc5e                	sd	s7,56(sp)
    802005fe:	f06a                	sd	s10,32(sp)
    80200600:	fc86                	sd	ra,120(sp)
    80200602:	f8a2                	sd	s0,112(sp)
    80200604:	f862                	sd	s8,48(sp)
    80200606:	f466                	sd	s9,40(sp)
    80200608:	ec6e                	sd	s11,24(sp)
    8020060a:	892a                	mv	s2,a0
    8020060c:	84ae                	mv	s1,a1
    8020060e:	8d32                	mv	s10,a2
    80200610:	8a36                	mv	s4,a3
    80200612:	02500993          	li	s3,37
    80200616:	5b7d                	li	s6,-1
    80200618:	00001a97          	auipc	s5,0x1
    8020061c:	9c4a8a93          	addi	s5,s5,-1596 # 80200fdc <etext+0x5f0>
    80200620:	00001b97          	auipc	s7,0x1
    80200624:	b98b8b93          	addi	s7,s7,-1128 # 802011b8 <error_string>
    80200628:	000d4503          	lbu	a0,0(s10)
    8020062c:	001d0413          	addi	s0,s10,1
    80200630:	01350a63          	beq	a0,s3,80200644 <vprintfmt+0x56>
    80200634:	c121                	beqz	a0,80200674 <vprintfmt+0x86>
    80200636:	85a6                	mv	a1,s1
    80200638:	0405                	addi	s0,s0,1
    8020063a:	9902                	jalr	s2
    8020063c:	fff44503          	lbu	a0,-1(s0)
    80200640:	ff351ae3          	bne	a0,s3,80200634 <vprintfmt+0x46>
    80200644:	00044603          	lbu	a2,0(s0)
    80200648:	02000793          	li	a5,32
    8020064c:	4c81                	li	s9,0
    8020064e:	4881                	li	a7,0
    80200650:	5c7d                	li	s8,-1
    80200652:	5dfd                	li	s11,-1
    80200654:	05500513          	li	a0,85
    80200658:	4825                	li	a6,9
    8020065a:	fdd6059b          	addiw	a1,a2,-35
    8020065e:	0ff5f593          	zext.b	a1,a1
    80200662:	00140d13          	addi	s10,s0,1
    80200666:	04b56263          	bltu	a0,a1,802006aa <vprintfmt+0xbc>
    8020066a:	058a                	slli	a1,a1,0x2
    8020066c:	95d6                	add	a1,a1,s5
    8020066e:	4194                	lw	a3,0(a1)
    80200670:	96d6                	add	a3,a3,s5
    80200672:	8682                	jr	a3
    80200674:	70e6                	ld	ra,120(sp)
    80200676:	7446                	ld	s0,112(sp)
    80200678:	74a6                	ld	s1,104(sp)
    8020067a:	7906                	ld	s2,96(sp)
    8020067c:	69e6                	ld	s3,88(sp)
    8020067e:	6a46                	ld	s4,80(sp)
    80200680:	6aa6                	ld	s5,72(sp)
    80200682:	6b06                	ld	s6,64(sp)
    80200684:	7be2                	ld	s7,56(sp)
    80200686:	7c42                	ld	s8,48(sp)
    80200688:	7ca2                	ld	s9,40(sp)
    8020068a:	7d02                	ld	s10,32(sp)
    8020068c:	6de2                	ld	s11,24(sp)
    8020068e:	6109                	addi	sp,sp,128
    80200690:	8082                	ret
    80200692:	87b2                	mv	a5,a2
    80200694:	00144603          	lbu	a2,1(s0)
    80200698:	846a                	mv	s0,s10
    8020069a:	00140d13          	addi	s10,s0,1
    8020069e:	fdd6059b          	addiw	a1,a2,-35
    802006a2:	0ff5f593          	zext.b	a1,a1
    802006a6:	fcb572e3          	bgeu	a0,a1,8020066a <vprintfmt+0x7c>
    802006aa:	85a6                	mv	a1,s1
    802006ac:	02500513          	li	a0,37
    802006b0:	9902                	jalr	s2
    802006b2:	fff44783          	lbu	a5,-1(s0)
    802006b6:	8d22                	mv	s10,s0
    802006b8:	f73788e3          	beq	a5,s3,80200628 <vprintfmt+0x3a>
    802006bc:	ffed4783          	lbu	a5,-2(s10)
    802006c0:	1d7d                	addi	s10,s10,-1
    802006c2:	ff379de3          	bne	a5,s3,802006bc <vprintfmt+0xce>
    802006c6:	b78d                	j	80200628 <vprintfmt+0x3a>
    802006c8:	fd060c1b          	addiw	s8,a2,-48
    802006cc:	00144603          	lbu	a2,1(s0)
    802006d0:	846a                	mv	s0,s10
    802006d2:	fd06069b          	addiw	a3,a2,-48
    802006d6:	0006059b          	sext.w	a1,a2
    802006da:	02d86463          	bltu	a6,a3,80200702 <vprintfmt+0x114>
    802006de:	00144603          	lbu	a2,1(s0)
    802006e2:	002c169b          	slliw	a3,s8,0x2
    802006e6:	0186873b          	addw	a4,a3,s8
    802006ea:	0017171b          	slliw	a4,a4,0x1
    802006ee:	9f2d                	addw	a4,a4,a1
    802006f0:	fd06069b          	addiw	a3,a2,-48
    802006f4:	0405                	addi	s0,s0,1
    802006f6:	fd070c1b          	addiw	s8,a4,-48
    802006fa:	0006059b          	sext.w	a1,a2
    802006fe:	fed870e3          	bgeu	a6,a3,802006de <vprintfmt+0xf0>
    80200702:	f40ddce3          	bgez	s11,8020065a <vprintfmt+0x6c>
    80200706:	8de2                	mv	s11,s8
    80200708:	5c7d                	li	s8,-1
    8020070a:	bf81                	j	8020065a <vprintfmt+0x6c>
    8020070c:	fffdc693          	not	a3,s11
    80200710:	96fd                	srai	a3,a3,0x3f
    80200712:	00ddfdb3          	and	s11,s11,a3
    80200716:	00144603          	lbu	a2,1(s0)
    8020071a:	2d81                	sext.w	s11,s11
    8020071c:	846a                	mv	s0,s10
    8020071e:	bf35                	j	8020065a <vprintfmt+0x6c>
    80200720:	000a2c03          	lw	s8,0(s4)
    80200724:	00144603          	lbu	a2,1(s0)
    80200728:	0a21                	addi	s4,s4,8
    8020072a:	846a                	mv	s0,s10
    8020072c:	bfd9                	j	80200702 <vprintfmt+0x114>
    8020072e:	4705                	li	a4,1
    80200730:	008a0593          	addi	a1,s4,8
    80200734:	01174463          	blt	a4,a7,8020073c <vprintfmt+0x14e>
    80200738:	1a088e63          	beqz	a7,802008f4 <vprintfmt+0x306>
    8020073c:	000a3603          	ld	a2,0(s4)
    80200740:	46c1                	li	a3,16
    80200742:	8a2e                	mv	s4,a1
    80200744:	2781                	sext.w	a5,a5
    80200746:	876e                	mv	a4,s11
    80200748:	85a6                	mv	a1,s1
    8020074a:	854a                	mv	a0,s2
    8020074c:	e37ff0ef          	jal	ra,80200582 <printnum>
    80200750:	bde1                	j	80200628 <vprintfmt+0x3a>
    80200752:	000a2503          	lw	a0,0(s4)
    80200756:	85a6                	mv	a1,s1
    80200758:	0a21                	addi	s4,s4,8
    8020075a:	9902                	jalr	s2
    8020075c:	b5f1                	j	80200628 <vprintfmt+0x3a>
    8020075e:	4705                	li	a4,1
    80200760:	008a0593          	addi	a1,s4,8
    80200764:	01174463          	blt	a4,a7,8020076c <vprintfmt+0x17e>
    80200768:	18088163          	beqz	a7,802008ea <vprintfmt+0x2fc>
    8020076c:	000a3603          	ld	a2,0(s4)
    80200770:	46a9                	li	a3,10
    80200772:	8a2e                	mv	s4,a1
    80200774:	bfc1                	j	80200744 <vprintfmt+0x156>
    80200776:	00144603          	lbu	a2,1(s0)
    8020077a:	4c85                	li	s9,1
    8020077c:	846a                	mv	s0,s10
    8020077e:	bdf1                	j	8020065a <vprintfmt+0x6c>
    80200780:	85a6                	mv	a1,s1
    80200782:	02500513          	li	a0,37
    80200786:	9902                	jalr	s2
    80200788:	b545                	j	80200628 <vprintfmt+0x3a>
    8020078a:	00144603          	lbu	a2,1(s0)
    8020078e:	2885                	addiw	a7,a7,1
    80200790:	846a                	mv	s0,s10
    80200792:	b5e1                	j	8020065a <vprintfmt+0x6c>
    80200794:	4705                	li	a4,1
    80200796:	008a0593          	addi	a1,s4,8
    8020079a:	01174463          	blt	a4,a7,802007a2 <vprintfmt+0x1b4>
    8020079e:	14088163          	beqz	a7,802008e0 <vprintfmt+0x2f2>
    802007a2:	000a3603          	ld	a2,0(s4)
    802007a6:	46a1                	li	a3,8
    802007a8:	8a2e                	mv	s4,a1
    802007aa:	bf69                	j	80200744 <vprintfmt+0x156>
    802007ac:	03000513          	li	a0,48
    802007b0:	85a6                	mv	a1,s1
    802007b2:	e03e                	sd	a5,0(sp)
    802007b4:	9902                	jalr	s2
    802007b6:	85a6                	mv	a1,s1
    802007b8:	07800513          	li	a0,120
    802007bc:	9902                	jalr	s2
    802007be:	0a21                	addi	s4,s4,8
    802007c0:	6782                	ld	a5,0(sp)
    802007c2:	46c1                	li	a3,16
    802007c4:	ff8a3603          	ld	a2,-8(s4)
    802007c8:	bfb5                	j	80200744 <vprintfmt+0x156>
    802007ca:	000a3403          	ld	s0,0(s4)
    802007ce:	008a0713          	addi	a4,s4,8
    802007d2:	e03a                	sd	a4,0(sp)
    802007d4:	14040263          	beqz	s0,80200918 <vprintfmt+0x32a>
    802007d8:	0fb05763          	blez	s11,802008c6 <vprintfmt+0x2d8>
    802007dc:	02d00693          	li	a3,45
    802007e0:	0cd79163          	bne	a5,a3,802008a2 <vprintfmt+0x2b4>
    802007e4:	00044783          	lbu	a5,0(s0)
    802007e8:	0007851b          	sext.w	a0,a5
    802007ec:	cf85                	beqz	a5,80200824 <vprintfmt+0x236>
    802007ee:	00140a13          	addi	s4,s0,1
    802007f2:	05e00413          	li	s0,94
    802007f6:	000c4563          	bltz	s8,80200800 <vprintfmt+0x212>
    802007fa:	3c7d                	addiw	s8,s8,-1
    802007fc:	036c0263          	beq	s8,s6,80200820 <vprintfmt+0x232>
    80200800:	85a6                	mv	a1,s1
    80200802:	0e0c8e63          	beqz	s9,802008fe <vprintfmt+0x310>
    80200806:	3781                	addiw	a5,a5,-32
    80200808:	0ef47b63          	bgeu	s0,a5,802008fe <vprintfmt+0x310>
    8020080c:	03f00513          	li	a0,63
    80200810:	9902                	jalr	s2
    80200812:	000a4783          	lbu	a5,0(s4)
    80200816:	3dfd                	addiw	s11,s11,-1
    80200818:	0a05                	addi	s4,s4,1
    8020081a:	0007851b          	sext.w	a0,a5
    8020081e:	ffe1                	bnez	a5,802007f6 <vprintfmt+0x208>
    80200820:	01b05963          	blez	s11,80200832 <vprintfmt+0x244>
    80200824:	3dfd                	addiw	s11,s11,-1
    80200826:	85a6                	mv	a1,s1
    80200828:	02000513          	li	a0,32
    8020082c:	9902                	jalr	s2
    8020082e:	fe0d9be3          	bnez	s11,80200824 <vprintfmt+0x236>
    80200832:	6a02                	ld	s4,0(sp)
    80200834:	bbd5                	j	80200628 <vprintfmt+0x3a>
    80200836:	4705                	li	a4,1
    80200838:	008a0c93          	addi	s9,s4,8
    8020083c:	01174463          	blt	a4,a7,80200844 <vprintfmt+0x256>
    80200840:	08088d63          	beqz	a7,802008da <vprintfmt+0x2ec>
    80200844:	000a3403          	ld	s0,0(s4)
    80200848:	0a044d63          	bltz	s0,80200902 <vprintfmt+0x314>
    8020084c:	8622                	mv	a2,s0
    8020084e:	8a66                	mv	s4,s9
    80200850:	46a9                	li	a3,10
    80200852:	bdcd                	j	80200744 <vprintfmt+0x156>
    80200854:	000a2783          	lw	a5,0(s4)
    80200858:	4719                	li	a4,6
    8020085a:	0a21                	addi	s4,s4,8
    8020085c:	41f7d69b          	sraiw	a3,a5,0x1f
    80200860:	8fb5                	xor	a5,a5,a3
    80200862:	40d786bb          	subw	a3,a5,a3
    80200866:	02d74163          	blt	a4,a3,80200888 <vprintfmt+0x29a>
    8020086a:	00369793          	slli	a5,a3,0x3
    8020086e:	97de                	add	a5,a5,s7
    80200870:	639c                	ld	a5,0(a5)
    80200872:	cb99                	beqz	a5,80200888 <vprintfmt+0x29a>
    80200874:	86be                	mv	a3,a5
    80200876:	00000617          	auipc	a2,0x0
    8020087a:	76260613          	addi	a2,a2,1890 # 80200fd8 <etext+0x5ec>
    8020087e:	85a6                	mv	a1,s1
    80200880:	854a                	mv	a0,s2
    80200882:	0ce000ef          	jal	ra,80200950 <printfmt>
    80200886:	b34d                	j	80200628 <vprintfmt+0x3a>
    80200888:	00000617          	auipc	a2,0x0
    8020088c:	74060613          	addi	a2,a2,1856 # 80200fc8 <etext+0x5dc>
    80200890:	85a6                	mv	a1,s1
    80200892:	854a                	mv	a0,s2
    80200894:	0bc000ef          	jal	ra,80200950 <printfmt>
    80200898:	bb41                	j	80200628 <vprintfmt+0x3a>
    8020089a:	00000417          	auipc	s0,0x0
    8020089e:	72640413          	addi	s0,s0,1830 # 80200fc0 <etext+0x5d4>
    802008a2:	85e2                	mv	a1,s8
    802008a4:	8522                	mv	a0,s0
    802008a6:	e43e                	sd	a5,8(sp)
    802008a8:	116000ef          	jal	ra,802009be <strnlen>
    802008ac:	40ad8dbb          	subw	s11,s11,a0
    802008b0:	01b05b63          	blez	s11,802008c6 <vprintfmt+0x2d8>
    802008b4:	67a2                	ld	a5,8(sp)
    802008b6:	00078a1b          	sext.w	s4,a5
    802008ba:	3dfd                	addiw	s11,s11,-1
    802008bc:	85a6                	mv	a1,s1
    802008be:	8552                	mv	a0,s4
    802008c0:	9902                	jalr	s2
    802008c2:	fe0d9ce3          	bnez	s11,802008ba <vprintfmt+0x2cc>
    802008c6:	00044783          	lbu	a5,0(s0)
    802008ca:	00140a13          	addi	s4,s0,1
    802008ce:	0007851b          	sext.w	a0,a5
    802008d2:	d3a5                	beqz	a5,80200832 <vprintfmt+0x244>
    802008d4:	05e00413          	li	s0,94
    802008d8:	bf39                	j	802007f6 <vprintfmt+0x208>
    802008da:	000a2403          	lw	s0,0(s4)
    802008de:	b7ad                	j	80200848 <vprintfmt+0x25a>
    802008e0:	000a6603          	lwu	a2,0(s4)
    802008e4:	46a1                	li	a3,8
    802008e6:	8a2e                	mv	s4,a1
    802008e8:	bdb1                	j	80200744 <vprintfmt+0x156>
    802008ea:	000a6603          	lwu	a2,0(s4)
    802008ee:	46a9                	li	a3,10
    802008f0:	8a2e                	mv	s4,a1
    802008f2:	bd89                	j	80200744 <vprintfmt+0x156>
    802008f4:	000a6603          	lwu	a2,0(s4)
    802008f8:	46c1                	li	a3,16
    802008fa:	8a2e                	mv	s4,a1
    802008fc:	b5a1                	j	80200744 <vprintfmt+0x156>
    802008fe:	9902                	jalr	s2
    80200900:	bf09                	j	80200812 <vprintfmt+0x224>
    80200902:	85a6                	mv	a1,s1
    80200904:	02d00513          	li	a0,45
    80200908:	e03e                	sd	a5,0(sp)
    8020090a:	9902                	jalr	s2
    8020090c:	6782                	ld	a5,0(sp)
    8020090e:	8a66                	mv	s4,s9
    80200910:	40800633          	neg	a2,s0
    80200914:	46a9                	li	a3,10
    80200916:	b53d                	j	80200744 <vprintfmt+0x156>
    80200918:	03b05163          	blez	s11,8020093a <vprintfmt+0x34c>
    8020091c:	02d00693          	li	a3,45
    80200920:	f6d79de3          	bne	a5,a3,8020089a <vprintfmt+0x2ac>
    80200924:	00000417          	auipc	s0,0x0
    80200928:	69c40413          	addi	s0,s0,1692 # 80200fc0 <etext+0x5d4>
    8020092c:	02800793          	li	a5,40
    80200930:	02800513          	li	a0,40
    80200934:	00140a13          	addi	s4,s0,1
    80200938:	bd6d                	j	802007f2 <vprintfmt+0x204>
    8020093a:	00000a17          	auipc	s4,0x0
    8020093e:	687a0a13          	addi	s4,s4,1671 # 80200fc1 <etext+0x5d5>
    80200942:	02800513          	li	a0,40
    80200946:	02800793          	li	a5,40
    8020094a:	05e00413          	li	s0,94
    8020094e:	b565                	j	802007f6 <vprintfmt+0x208>

0000000080200950 <printfmt>:
    80200950:	715d                	addi	sp,sp,-80
    80200952:	02810313          	addi	t1,sp,40
    80200956:	f436                	sd	a3,40(sp)
    80200958:	869a                	mv	a3,t1
    8020095a:	ec06                	sd	ra,24(sp)
    8020095c:	f83a                	sd	a4,48(sp)
    8020095e:	fc3e                	sd	a5,56(sp)
    80200960:	e0c2                	sd	a6,64(sp)
    80200962:	e4c6                	sd	a7,72(sp)
    80200964:	e41a                	sd	t1,8(sp)
    80200966:	c89ff0ef          	jal	ra,802005ee <vprintfmt>
    8020096a:	60e2                	ld	ra,24(sp)
    8020096c:	6161                	addi	sp,sp,80
    8020096e:	8082                	ret

0000000080200970 <sbi_console_putchar>:
    80200970:	4781                	li	a5,0
    80200972:	00003717          	auipc	a4,0x3
    80200976:	68e73703          	ld	a4,1678(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    8020097a:	88ba                	mv	a7,a4
    8020097c:	852a                	mv	a0,a0
    8020097e:	85be                	mv	a1,a5
    80200980:	863e                	mv	a2,a5
    80200982:	00000073          	ecall
    80200986:	87aa                	mv	a5,a0
    80200988:	8082                	ret

000000008020098a <sbi_set_timer>:
    8020098a:	4781                	li	a5,0
    8020098c:	00003717          	auipc	a4,0x3
    80200990:	69473703          	ld	a4,1684(a4) # 80204020 <SBI_SET_TIMER>
    80200994:	88ba                	mv	a7,a4
    80200996:	852a                	mv	a0,a0
    80200998:	85be                	mv	a1,a5
    8020099a:	863e                	mv	a2,a5
    8020099c:	00000073          	ecall
    802009a0:	87aa                	mv	a5,a0
    802009a2:	8082                	ret

00000000802009a4 <sbi_shutdown>:
    802009a4:	4781                	li	a5,0
    802009a6:	00003717          	auipc	a4,0x3
    802009aa:	66273703          	ld	a4,1634(a4) # 80204008 <SBI_SHUTDOWN>
    802009ae:	88ba                	mv	a7,a4
    802009b0:	853e                	mv	a0,a5
    802009b2:	85be                	mv	a1,a5
    802009b4:	863e                	mv	a2,a5
    802009b6:	00000073          	ecall
    802009ba:	87aa                	mv	a5,a0
    802009bc:	8082                	ret

00000000802009be <strnlen>:
    802009be:	4781                	li	a5,0
    802009c0:	e589                	bnez	a1,802009ca <strnlen+0xc>
    802009c2:	a811                	j	802009d6 <strnlen+0x18>
    802009c4:	0785                	addi	a5,a5,1
    802009c6:	00f58863          	beq	a1,a5,802009d6 <strnlen+0x18>
    802009ca:	00f50733          	add	a4,a0,a5
    802009ce:	00074703          	lbu	a4,0(a4)
    802009d2:	fb6d                	bnez	a4,802009c4 <strnlen+0x6>
    802009d4:	85be                	mv	a1,a5
    802009d6:	852e                	mv	a0,a1
    802009d8:	8082                	ret

00000000802009da <memset>:
    802009da:	ca01                	beqz	a2,802009ea <memset+0x10>
    802009dc:	962a                	add	a2,a2,a0
    802009de:	87aa                	mv	a5,a0
    802009e0:	0785                	addi	a5,a5,1
    802009e2:	feb78fa3          	sb	a1,-1(a5)
    802009e6:	fec79de3          	bne	a5,a2,802009e0 <memset+0x6>
    802009ea:	8082                	ret
