
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
    80200026:	150000ef          	jal	ra,80200176 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	9c658593          	addi	a1,a1,-1594 # 802009f0 <etext+0x4>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	9de50513          	addi	a0,a0,-1570 # 80200a10 <etext+0x24>
    8020003a:	036000ef          	jal	ra,80200070 <cprintf>

    print_kerninfo();
    8020003e:	068000ef          	jal	ra,802000a6 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	144000ef          	jal	ra,80200186 <idt_init>
    __asm__ __volatile__("ebreak");//触发断点异宗
    80200046:	9002                	ebreak
    __asm__ __volatile__("mret");  // 触发非法指令异常
    80200048:	30200073          	mret
    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    8020004c:	0e8000ef          	jal	ra,80200134 <clock_init>

    intr_enable();  // enable irq interrupt
    80200050:	130000ef          	jal	ra,80200180 <intr_enable>
    
    while (1)
    80200054:	a001                	j	80200054 <kern_init+0x4a>

0000000080200056 <cputch>:
    80200056:	1141                	addi	sp,sp,-16
    80200058:	e022                	sd	s0,0(sp)
    8020005a:	e406                	sd	ra,8(sp)
    8020005c:	842e                	mv	s0,a1
    8020005e:	11a000ef          	jal	ra,80200178 <cons_putc>
    80200062:	401c                	lw	a5,0(s0)
    80200064:	60a2                	ld	ra,8(sp)
    80200066:	2785                	addiw	a5,a5,1
    80200068:	c01c                	sw	a5,0(s0)
    8020006a:	6402                	ld	s0,0(sp)
    8020006c:	0141                	addi	sp,sp,16
    8020006e:	8082                	ret

0000000080200070 <cprintf>:
    80200070:	711d                	addi	sp,sp,-96
    80200072:	02810313          	addi	t1,sp,40 # 80204028 <end>
    80200076:	8e2a                	mv	t3,a0
    80200078:	f42e                	sd	a1,40(sp)
    8020007a:	f832                	sd	a2,48(sp)
    8020007c:	fc36                	sd	a3,56(sp)
    8020007e:	00000517          	auipc	a0,0x0
    80200082:	fd850513          	addi	a0,a0,-40 # 80200056 <cputch>
    80200086:	004c                	addi	a1,sp,4
    80200088:	869a                	mv	a3,t1
    8020008a:	8672                	mv	a2,t3
    8020008c:	ec06                	sd	ra,24(sp)
    8020008e:	e0ba                	sd	a4,64(sp)
    80200090:	e4be                	sd	a5,72(sp)
    80200092:	e8c2                	sd	a6,80(sp)
    80200094:	ecc6                	sd	a7,88(sp)
    80200096:	e41a                	sd	t1,8(sp)
    80200098:	c202                	sw	zero,4(sp)
    8020009a:	554000ef          	jal	ra,802005ee <vprintfmt>
    8020009e:	60e2                	ld	ra,24(sp)
    802000a0:	4512                	lw	a0,4(sp)
    802000a2:	6125                	addi	sp,sp,96
    802000a4:	8082                	ret

00000000802000a6 <print_kerninfo>:
    802000a6:	1141                	addi	sp,sp,-16
    802000a8:	00001517          	auipc	a0,0x1
    802000ac:	97050513          	addi	a0,a0,-1680 # 80200a18 <etext+0x2c>
    802000b0:	e406                	sd	ra,8(sp)
    802000b2:	fbfff0ef          	jal	ra,80200070 <cprintf>
    802000b6:	00000597          	auipc	a1,0x0
    802000ba:	f5458593          	addi	a1,a1,-172 # 8020000a <kern_init>
    802000be:	00001517          	auipc	a0,0x1
    802000c2:	97a50513          	addi	a0,a0,-1670 # 80200a38 <etext+0x4c>
    802000c6:	fabff0ef          	jal	ra,80200070 <cprintf>
    802000ca:	00001597          	auipc	a1,0x1
    802000ce:	92258593          	addi	a1,a1,-1758 # 802009ec <etext>
    802000d2:	00001517          	auipc	a0,0x1
    802000d6:	98650513          	addi	a0,a0,-1658 # 80200a58 <etext+0x6c>
    802000da:	f97ff0ef          	jal	ra,80200070 <cprintf>
    802000de:	00004597          	auipc	a1,0x4
    802000e2:	f3258593          	addi	a1,a1,-206 # 80204010 <ticks>
    802000e6:	00001517          	auipc	a0,0x1
    802000ea:	99250513          	addi	a0,a0,-1646 # 80200a78 <etext+0x8c>
    802000ee:	f83ff0ef          	jal	ra,80200070 <cprintf>
    802000f2:	00004597          	auipc	a1,0x4
    802000f6:	f3658593          	addi	a1,a1,-202 # 80204028 <end>
    802000fa:	00001517          	auipc	a0,0x1
    802000fe:	99e50513          	addi	a0,a0,-1634 # 80200a98 <etext+0xac>
    80200102:	f6fff0ef          	jal	ra,80200070 <cprintf>
    80200106:	00004597          	auipc	a1,0x4
    8020010a:	32158593          	addi	a1,a1,801 # 80204427 <end+0x3ff>
    8020010e:	00000797          	auipc	a5,0x0
    80200112:	efc78793          	addi	a5,a5,-260 # 8020000a <kern_init>
    80200116:	40f587b3          	sub	a5,a1,a5
    8020011a:	43f7d593          	srai	a1,a5,0x3f
    8020011e:	60a2                	ld	ra,8(sp)
    80200120:	3ff5f593          	andi	a1,a1,1023
    80200124:	95be                	add	a1,a1,a5
    80200126:	85a9                	srai	a1,a1,0xa
    80200128:	00001517          	auipc	a0,0x1
    8020012c:	99050513          	addi	a0,a0,-1648 # 80200ab8 <etext+0xcc>
    80200130:	0141                	addi	sp,sp,16
    80200132:	bf3d                	j	80200070 <cprintf>

0000000080200134 <clock_init>:
    80200134:	1141                	addi	sp,sp,-16
    80200136:	e406                	sd	ra,8(sp)
    80200138:	02000793          	li	a5,32
    8020013c:	1047a7f3          	csrrs	a5,sie,a5
    80200140:	c0102573          	rdtime	a0
    80200144:	67e1                	lui	a5,0x18
    80200146:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    8020014a:	953e                	add	a0,a0,a5
    8020014c:	03f000ef          	jal	ra,8020098a <sbi_set_timer>
    80200150:	60a2                	ld	ra,8(sp)
    80200152:	00004797          	auipc	a5,0x4
    80200156:	ea07bf23          	sd	zero,-322(a5) # 80204010 <ticks>
    8020015a:	00001517          	auipc	a0,0x1
    8020015e:	98e50513          	addi	a0,a0,-1650 # 80200ae8 <etext+0xfc>
    80200162:	0141                	addi	sp,sp,16
    80200164:	b731                	j	80200070 <cprintf>

0000000080200166 <clock_set_next_event>:
    80200166:	c0102573          	rdtime	a0
    8020016a:	67e1                	lui	a5,0x18
    8020016c:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200170:	953e                	add	a0,a0,a5
    80200172:	0190006f          	j	8020098a <sbi_set_timer>

0000000080200176 <cons_init>:
    80200176:	8082                	ret

0000000080200178 <cons_putc>:
    80200178:	0ff57513          	zext.b	a0,a0
    8020017c:	7f40006f          	j	80200970 <sbi_console_putchar>

0000000080200180 <intr_enable>:
    80200180:	100167f3          	csrrsi	a5,sstatus,2
    80200184:	8082                	ret

0000000080200186 <idt_init>:
    80200186:	14005073          	csrwi	sscratch,0
    8020018a:	00000797          	auipc	a5,0x0
    8020018e:	34278793          	addi	a5,a5,834 # 802004cc <__alltraps>
    80200192:	10579073          	csrw	stvec,a5
    80200196:	8082                	ret

0000000080200198 <print_regs>:
    80200198:	610c                	ld	a1,0(a0)
    8020019a:	1141                	addi	sp,sp,-16
    8020019c:	e022                	sd	s0,0(sp)
    8020019e:	842a                	mv	s0,a0
    802001a0:	00001517          	auipc	a0,0x1
    802001a4:	96850513          	addi	a0,a0,-1688 # 80200b08 <etext+0x11c>
    802001a8:	e406                	sd	ra,8(sp)
    802001aa:	ec7ff0ef          	jal	ra,80200070 <cprintf>
    802001ae:	640c                	ld	a1,8(s0)
    802001b0:	00001517          	auipc	a0,0x1
    802001b4:	97050513          	addi	a0,a0,-1680 # 80200b20 <etext+0x134>
    802001b8:	eb9ff0ef          	jal	ra,80200070 <cprintf>
    802001bc:	680c                	ld	a1,16(s0)
    802001be:	00001517          	auipc	a0,0x1
    802001c2:	97a50513          	addi	a0,a0,-1670 # 80200b38 <etext+0x14c>
    802001c6:	eabff0ef          	jal	ra,80200070 <cprintf>
    802001ca:	6c0c                	ld	a1,24(s0)
    802001cc:	00001517          	auipc	a0,0x1
    802001d0:	98450513          	addi	a0,a0,-1660 # 80200b50 <etext+0x164>
    802001d4:	e9dff0ef          	jal	ra,80200070 <cprintf>
    802001d8:	700c                	ld	a1,32(s0)
    802001da:	00001517          	auipc	a0,0x1
    802001de:	98e50513          	addi	a0,a0,-1650 # 80200b68 <etext+0x17c>
    802001e2:	e8fff0ef          	jal	ra,80200070 <cprintf>
    802001e6:	740c                	ld	a1,40(s0)
    802001e8:	00001517          	auipc	a0,0x1
    802001ec:	99850513          	addi	a0,a0,-1640 # 80200b80 <etext+0x194>
    802001f0:	e81ff0ef          	jal	ra,80200070 <cprintf>
    802001f4:	780c                	ld	a1,48(s0)
    802001f6:	00001517          	auipc	a0,0x1
    802001fa:	9a250513          	addi	a0,a0,-1630 # 80200b98 <etext+0x1ac>
    802001fe:	e73ff0ef          	jal	ra,80200070 <cprintf>
    80200202:	7c0c                	ld	a1,56(s0)
    80200204:	00001517          	auipc	a0,0x1
    80200208:	9ac50513          	addi	a0,a0,-1620 # 80200bb0 <etext+0x1c4>
    8020020c:	e65ff0ef          	jal	ra,80200070 <cprintf>
    80200210:	602c                	ld	a1,64(s0)
    80200212:	00001517          	auipc	a0,0x1
    80200216:	9b650513          	addi	a0,a0,-1610 # 80200bc8 <etext+0x1dc>
    8020021a:	e57ff0ef          	jal	ra,80200070 <cprintf>
    8020021e:	642c                	ld	a1,72(s0)
    80200220:	00001517          	auipc	a0,0x1
    80200224:	9c050513          	addi	a0,a0,-1600 # 80200be0 <etext+0x1f4>
    80200228:	e49ff0ef          	jal	ra,80200070 <cprintf>
    8020022c:	682c                	ld	a1,80(s0)
    8020022e:	00001517          	auipc	a0,0x1
    80200232:	9ca50513          	addi	a0,a0,-1590 # 80200bf8 <etext+0x20c>
    80200236:	e3bff0ef          	jal	ra,80200070 <cprintf>
    8020023a:	6c2c                	ld	a1,88(s0)
    8020023c:	00001517          	auipc	a0,0x1
    80200240:	9d450513          	addi	a0,a0,-1580 # 80200c10 <etext+0x224>
    80200244:	e2dff0ef          	jal	ra,80200070 <cprintf>
    80200248:	702c                	ld	a1,96(s0)
    8020024a:	00001517          	auipc	a0,0x1
    8020024e:	9de50513          	addi	a0,a0,-1570 # 80200c28 <etext+0x23c>
    80200252:	e1fff0ef          	jal	ra,80200070 <cprintf>
    80200256:	742c                	ld	a1,104(s0)
    80200258:	00001517          	auipc	a0,0x1
    8020025c:	9e850513          	addi	a0,a0,-1560 # 80200c40 <etext+0x254>
    80200260:	e11ff0ef          	jal	ra,80200070 <cprintf>
    80200264:	782c                	ld	a1,112(s0)
    80200266:	00001517          	auipc	a0,0x1
    8020026a:	9f250513          	addi	a0,a0,-1550 # 80200c58 <etext+0x26c>
    8020026e:	e03ff0ef          	jal	ra,80200070 <cprintf>
    80200272:	7c2c                	ld	a1,120(s0)
    80200274:	00001517          	auipc	a0,0x1
    80200278:	9fc50513          	addi	a0,a0,-1540 # 80200c70 <etext+0x284>
    8020027c:	df5ff0ef          	jal	ra,80200070 <cprintf>
    80200280:	604c                	ld	a1,128(s0)
    80200282:	00001517          	auipc	a0,0x1
    80200286:	a0650513          	addi	a0,a0,-1530 # 80200c88 <etext+0x29c>
    8020028a:	de7ff0ef          	jal	ra,80200070 <cprintf>
    8020028e:	644c                	ld	a1,136(s0)
    80200290:	00001517          	auipc	a0,0x1
    80200294:	a1050513          	addi	a0,a0,-1520 # 80200ca0 <etext+0x2b4>
    80200298:	dd9ff0ef          	jal	ra,80200070 <cprintf>
    8020029c:	684c                	ld	a1,144(s0)
    8020029e:	00001517          	auipc	a0,0x1
    802002a2:	a1a50513          	addi	a0,a0,-1510 # 80200cb8 <etext+0x2cc>
    802002a6:	dcbff0ef          	jal	ra,80200070 <cprintf>
    802002aa:	6c4c                	ld	a1,152(s0)
    802002ac:	00001517          	auipc	a0,0x1
    802002b0:	a2450513          	addi	a0,a0,-1500 # 80200cd0 <etext+0x2e4>
    802002b4:	dbdff0ef          	jal	ra,80200070 <cprintf>
    802002b8:	704c                	ld	a1,160(s0)
    802002ba:	00001517          	auipc	a0,0x1
    802002be:	a2e50513          	addi	a0,a0,-1490 # 80200ce8 <etext+0x2fc>
    802002c2:	dafff0ef          	jal	ra,80200070 <cprintf>
    802002c6:	744c                	ld	a1,168(s0)
    802002c8:	00001517          	auipc	a0,0x1
    802002cc:	a3850513          	addi	a0,a0,-1480 # 80200d00 <etext+0x314>
    802002d0:	da1ff0ef          	jal	ra,80200070 <cprintf>
    802002d4:	784c                	ld	a1,176(s0)
    802002d6:	00001517          	auipc	a0,0x1
    802002da:	a4250513          	addi	a0,a0,-1470 # 80200d18 <etext+0x32c>
    802002de:	d93ff0ef          	jal	ra,80200070 <cprintf>
    802002e2:	7c4c                	ld	a1,184(s0)
    802002e4:	00001517          	auipc	a0,0x1
    802002e8:	a4c50513          	addi	a0,a0,-1460 # 80200d30 <etext+0x344>
    802002ec:	d85ff0ef          	jal	ra,80200070 <cprintf>
    802002f0:	606c                	ld	a1,192(s0)
    802002f2:	00001517          	auipc	a0,0x1
    802002f6:	a5650513          	addi	a0,a0,-1450 # 80200d48 <etext+0x35c>
    802002fa:	d77ff0ef          	jal	ra,80200070 <cprintf>
    802002fe:	646c                	ld	a1,200(s0)
    80200300:	00001517          	auipc	a0,0x1
    80200304:	a6050513          	addi	a0,a0,-1440 # 80200d60 <etext+0x374>
    80200308:	d69ff0ef          	jal	ra,80200070 <cprintf>
    8020030c:	686c                	ld	a1,208(s0)
    8020030e:	00001517          	auipc	a0,0x1
    80200312:	a6a50513          	addi	a0,a0,-1430 # 80200d78 <etext+0x38c>
    80200316:	d5bff0ef          	jal	ra,80200070 <cprintf>
    8020031a:	6c6c                	ld	a1,216(s0)
    8020031c:	00001517          	auipc	a0,0x1
    80200320:	a7450513          	addi	a0,a0,-1420 # 80200d90 <etext+0x3a4>
    80200324:	d4dff0ef          	jal	ra,80200070 <cprintf>
    80200328:	706c                	ld	a1,224(s0)
    8020032a:	00001517          	auipc	a0,0x1
    8020032e:	a7e50513          	addi	a0,a0,-1410 # 80200da8 <etext+0x3bc>
    80200332:	d3fff0ef          	jal	ra,80200070 <cprintf>
    80200336:	746c                	ld	a1,232(s0)
    80200338:	00001517          	auipc	a0,0x1
    8020033c:	a8850513          	addi	a0,a0,-1400 # 80200dc0 <etext+0x3d4>
    80200340:	d31ff0ef          	jal	ra,80200070 <cprintf>
    80200344:	786c                	ld	a1,240(s0)
    80200346:	00001517          	auipc	a0,0x1
    8020034a:	a9250513          	addi	a0,a0,-1390 # 80200dd8 <etext+0x3ec>
    8020034e:	d23ff0ef          	jal	ra,80200070 <cprintf>
    80200352:	7c6c                	ld	a1,248(s0)
    80200354:	6402                	ld	s0,0(sp)
    80200356:	60a2                	ld	ra,8(sp)
    80200358:	00001517          	auipc	a0,0x1
    8020035c:	a9850513          	addi	a0,a0,-1384 # 80200df0 <etext+0x404>
    80200360:	0141                	addi	sp,sp,16
    80200362:	b339                	j	80200070 <cprintf>

0000000080200364 <print_trapframe>:
    80200364:	1141                	addi	sp,sp,-16
    80200366:	e022                	sd	s0,0(sp)
    80200368:	85aa                	mv	a1,a0
    8020036a:	842a                	mv	s0,a0
    8020036c:	00001517          	auipc	a0,0x1
    80200370:	a9c50513          	addi	a0,a0,-1380 # 80200e08 <etext+0x41c>
    80200374:	e406                	sd	ra,8(sp)
    80200376:	cfbff0ef          	jal	ra,80200070 <cprintf>
    8020037a:	8522                	mv	a0,s0
    8020037c:	e1dff0ef          	jal	ra,80200198 <print_regs>
    80200380:	10043583          	ld	a1,256(s0)
    80200384:	00001517          	auipc	a0,0x1
    80200388:	a9c50513          	addi	a0,a0,-1380 # 80200e20 <etext+0x434>
    8020038c:	ce5ff0ef          	jal	ra,80200070 <cprintf>
    80200390:	10843583          	ld	a1,264(s0)
    80200394:	00001517          	auipc	a0,0x1
    80200398:	aa450513          	addi	a0,a0,-1372 # 80200e38 <etext+0x44c>
    8020039c:	cd5ff0ef          	jal	ra,80200070 <cprintf>
    802003a0:	11043583          	ld	a1,272(s0)
    802003a4:	00001517          	auipc	a0,0x1
    802003a8:	aac50513          	addi	a0,a0,-1364 # 80200e50 <etext+0x464>
    802003ac:	cc5ff0ef          	jal	ra,80200070 <cprintf>
    802003b0:	11843583          	ld	a1,280(s0)
    802003b4:	6402                	ld	s0,0(sp)
    802003b6:	60a2                	ld	ra,8(sp)
    802003b8:	00001517          	auipc	a0,0x1
    802003bc:	ab050513          	addi	a0,a0,-1360 # 80200e68 <etext+0x47c>
    802003c0:	0141                	addi	sp,sp,16
    802003c2:	b17d                	j	80200070 <cprintf>

00000000802003c4 <interrupt_handler>:
    802003c4:	11853783          	ld	a5,280(a0)
    802003c8:	472d                	li	a4,11
    802003ca:	0786                	slli	a5,a5,0x1
    802003cc:	8385                	srli	a5,a5,0x1
    802003ce:	06f76763          	bltu	a4,a5,8020043c <interrupt_handler+0x78>
    802003d2:	00001717          	auipc	a4,0x1
    802003d6:	b5e70713          	addi	a4,a4,-1186 # 80200f30 <etext+0x544>
    802003da:	078a                	slli	a5,a5,0x2
    802003dc:	97ba                	add	a5,a5,a4
    802003de:	439c                	lw	a5,0(a5)
    802003e0:	97ba                	add	a5,a5,a4
    802003e2:	8782                	jr	a5
    802003e4:	00001517          	auipc	a0,0x1
    802003e8:	afc50513          	addi	a0,a0,-1284 # 80200ee0 <etext+0x4f4>
    802003ec:	b151                	j	80200070 <cprintf>
    802003ee:	00001517          	auipc	a0,0x1
    802003f2:	ad250513          	addi	a0,a0,-1326 # 80200ec0 <etext+0x4d4>
    802003f6:	b9ad                	j	80200070 <cprintf>
    802003f8:	00001517          	auipc	a0,0x1
    802003fc:	a8850513          	addi	a0,a0,-1400 # 80200e80 <etext+0x494>
    80200400:	b985                	j	80200070 <cprintf>
    80200402:	00001517          	auipc	a0,0x1
    80200406:	a9e50513          	addi	a0,a0,-1378 # 80200ea0 <etext+0x4b4>
    8020040a:	b19d                	j	80200070 <cprintf>
    8020040c:	1141                	addi	sp,sp,-16
    8020040e:	e406                	sd	ra,8(sp)
    80200410:	d57ff0ef          	jal	ra,80200166 <clock_set_next_event>
    80200414:	00004797          	auipc	a5,0x4
    80200418:	bfc78793          	addi	a5,a5,-1028 # 80204010 <ticks>
    8020041c:	6398                	ld	a4,0(a5)
    8020041e:	06400693          	li	a3,100
    80200422:	0705                	addi	a4,a4,1
    80200424:	e398                	sd	a4,0(a5)
    80200426:	639c                	ld	a5,0(a5)
    80200428:	00d78b63          	beq	a5,a3,8020043e <interrupt_handler+0x7a>
    8020042c:	60a2                	ld	ra,8(sp)
    8020042e:	0141                	addi	sp,sp,16
    80200430:	8082                	ret
    80200432:	00001517          	auipc	a0,0x1
    80200436:	ade50513          	addi	a0,a0,-1314 # 80200f10 <etext+0x524>
    8020043a:	b91d                	j	80200070 <cprintf>
    8020043c:	b725                	j	80200364 <print_trapframe>
    8020043e:	00001517          	auipc	a0,0x1
    80200442:	ac250513          	addi	a0,a0,-1342 # 80200f00 <etext+0x514>
    80200446:	c2bff0ef          	jal	ra,80200070 <cprintf>
    8020044a:	00004797          	auipc	a5,0x4
    8020044e:	bc07b323          	sd	zero,-1082(a5) # 80204010 <ticks>
    80200452:	00004797          	auipc	a5,0x4
    80200456:	bc678793          	addi	a5,a5,-1082 # 80204018 <num>
    8020045a:	6398                	ld	a4,0(a5)
    8020045c:	46a9                	li	a3,10
    8020045e:	0705                	addi	a4,a4,1
    80200460:	e398                	sd	a4,0(a5)
    80200462:	639c                	ld	a5,0(a5)
    80200464:	fcd794e3          	bne	a5,a3,8020042c <interrupt_handler+0x68>
    80200468:	60a2                	ld	ra,8(sp)
    8020046a:	0141                	addi	sp,sp,16
    8020046c:	ab25                	j	802009a4 <sbi_shutdown>

000000008020046e <exception_handler>:
    8020046e:	11853783          	ld	a5,280(a0)
    80200472:	4709                	li	a4,2
    80200474:	00e78b63          	beq	a5,a4,8020048a <exception_handler+0x1c>
    80200478:	00f77863          	bgeu	a4,a5,80200488 <exception_handler+0x1a>
    8020047c:	17f5                	addi	a5,a5,-3
    8020047e:	4721                	li	a4,8
    80200480:	00f77363          	bgeu	a4,a5,80200486 <exception_handler+0x18>
    80200484:	b5c5                	j	80200364 <print_trapframe>
    80200486:	8082                	ret
    80200488:	8082                	ret
    8020048a:	1141                	addi	sp,sp,-16
    8020048c:	e022                	sd	s0,0(sp)
    8020048e:	842a                	mv	s0,a0
    80200490:	00001517          	auipc	a0,0x1
    80200494:	ad050513          	addi	a0,a0,-1328 # 80200f60 <etext+0x574>
    80200498:	e406                	sd	ra,8(sp)
    8020049a:	bd7ff0ef          	jal	ra,80200070 <cprintf>
    8020049e:	10843583          	ld	a1,264(s0)
    802004a2:	00001517          	auipc	a0,0x1
    802004a6:	ae650513          	addi	a0,a0,-1306 # 80200f88 <etext+0x59c>
    802004aa:	bc7ff0ef          	jal	ra,80200070 <cprintf>
    802004ae:	10843783          	ld	a5,264(s0)
    802004b2:	60a2                	ld	ra,8(sp)
    802004b4:	0791                	addi	a5,a5,4
    802004b6:	10f43423          	sd	a5,264(s0)
    802004ba:	6402                	ld	s0,0(sp)
    802004bc:	0141                	addi	sp,sp,16
    802004be:	8082                	ret

00000000802004c0 <trap>:
    802004c0:	11853783          	ld	a5,280(a0)
    802004c4:	0007c363          	bltz	a5,802004ca <trap+0xa>
    802004c8:	b75d                	j	8020046e <exception_handler>
    802004ca:	bded                	j	802003c4 <interrupt_handler>

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
    80200530:	f91ff0ef          	jal	ra,802004c0 <trap>

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
