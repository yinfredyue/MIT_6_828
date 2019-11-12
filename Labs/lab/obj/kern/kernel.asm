
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 72 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010004a:	81 c3 be 12 01 00    	add    $0x112be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 18 07 ff ff    	lea    -0xf8e8(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 e6 09 00 00       	call   f0100a49 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7f 2b                	jg     f0100095 <test_backtrace+0x55>
		test_backtrace(x-1);
	else
		mon_backtrace(0, 0, 0);
f010006a:	83 ec 04             	sub    $0x4,%esp
f010006d:	6a 00                	push   $0x0
f010006f:	6a 00                	push   $0x0
f0100071:	6a 00                	push   $0x0
f0100073:	e8 0b 08 00 00       	call   f0100883 <mon_backtrace>
f0100078:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007b:	83 ec 08             	sub    $0x8,%esp
f010007e:	56                   	push   %esi
f010007f:	8d 83 34 07 ff ff    	lea    -0xf8cc(%ebx),%eax
f0100085:	50                   	push   %eax
f0100086:	e8 be 09 00 00       	call   f0100a49 <cprintf>
}
f010008b:	83 c4 10             	add    $0x10,%esp
f010008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100091:	5b                   	pop    %ebx
f0100092:	5e                   	pop    %esi
f0100093:	5d                   	pop    %ebp
f0100094:	c3                   	ret    
		test_backtrace(x-1);
f0100095:	83 ec 0c             	sub    $0xc,%esp
f0100098:	8d 46 ff             	lea    -0x1(%esi),%eax
f010009b:	50                   	push   %eax
f010009c:	e8 9f ff ff ff       	call   f0100040 <test_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d5                	jmp    f010007b <test_backtrace+0x3b>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 0a 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 56 12 01 00    	add    $0x11256,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000be:	c7 c0 a0 36 11 f0    	mov    $0xf01136a0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 0e 15 00 00       	call   f01015dd <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 3d 05 00 00       	call   f0100611 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 4f 07 ff ff    	lea    -0xf8b1(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 61 09 00 00       	call   f0100a49 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
f01000f4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 8c 07 00 00       	call   f010088d <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <i386_init+0x51>

f0100106 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100106:	55                   	push   %ebp
f0100107:	89 e5                	mov    %esp,%ebp
f0100109:	57                   	push   %edi
f010010a:	56                   	push   %esi
f010010b:	53                   	push   %ebx
f010010c:	83 ec 0c             	sub    $0xc,%esp
f010010f:	e8 a8 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100114:	81 c3 f4 11 01 00    	add    $0x111f4,%ebx
f010011a:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f010011d:	c7 c0 a4 36 11 f0    	mov    $0xf01136a4,%eax
f0100123:	83 38 00             	cmpl   $0x0,(%eax)
f0100126:	74 0f                	je     f0100137 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100128:	83 ec 0c             	sub    $0xc,%esp
f010012b:	6a 00                	push   $0x0
f010012d:	e8 5b 07 00 00       	call   f010088d <monitor>
f0100132:	83 c4 10             	add    $0x10,%esp
f0100135:	eb f1                	jmp    f0100128 <_panic+0x22>
	panicstr = fmt;
f0100137:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100139:	fa                   	cli    
f010013a:	fc                   	cld    
	va_start(ap, fmt);
f010013b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010013e:	83 ec 04             	sub    $0x4,%esp
f0100141:	ff 75 0c             	pushl  0xc(%ebp)
f0100144:	ff 75 08             	pushl  0x8(%ebp)
f0100147:	8d 83 6a 07 ff ff    	lea    -0xf896(%ebx),%eax
f010014d:	50                   	push   %eax
f010014e:	e8 f6 08 00 00       	call   f0100a49 <cprintf>
	vcprintf(fmt, ap);
f0100153:	83 c4 08             	add    $0x8,%esp
f0100156:	56                   	push   %esi
f0100157:	57                   	push   %edi
f0100158:	e8 b5 08 00 00       	call   f0100a12 <vcprintf>
	cprintf("\n");
f010015d:	8d 83 a6 07 ff ff    	lea    -0xf85a(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 de 08 00 00       	call   f0100a49 <cprintf>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb b8                	jmp    f0100128 <_panic+0x22>

f0100170 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	56                   	push   %esi
f0100174:	53                   	push   %ebx
f0100175:	e8 42 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010017a:	81 c3 8e 11 01 00    	add    $0x1118e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	pushl  0xc(%ebp)
f0100189:	ff 75 08             	pushl  0x8(%ebp)
f010018c:	8d 83 82 07 ff ff    	lea    -0xf87e(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 b1 08 00 00       	call   f0100a49 <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	pushl  0x10(%ebp)
f010019f:	e8 6e 08 00 00       	call   f0100a12 <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 a6 07 ff ff    	lea    -0xf85a(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 97 08 00 00       	call   f0100a49 <cprintf>
	va_end(ap);
}
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5e                   	pop    %esi
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <__x86.get_pc_thunk.bx>:
f01001bc:	8b 1c 24             	mov    (%esp),%ebx
f01001bf:	c3                   	ret    

f01001c0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001c0:	55                   	push   %ebp
f01001c1:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c9:	a8 01                	test   $0x1,%al
f01001cb:	74 0b                	je     f01001d8 <serial_proc_data+0x18>
f01001cd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d3:	0f b6 c0             	movzbl %al,%eax
}
f01001d6:	5d                   	pop    %ebp
f01001d7:	c3                   	ret    
		return -1;
f01001d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001dd:	eb f7                	jmp    f01001d6 <serial_proc_data+0x16>

f01001df <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001df:	55                   	push   %ebp
f01001e0:	89 e5                	mov    %esp,%ebp
f01001e2:	56                   	push   %esi
f01001e3:	53                   	push   %ebx
f01001e4:	e8 d3 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01001e9:	81 c3 1f 11 01 00    	add    $0x1111f,%ebx
f01001ef:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01001f1:	ff d6                	call   *%esi
f01001f3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f6:	74 2e                	je     f0100226 <cons_intr+0x47>
		if (c == 0)
f01001f8:	85 c0                	test   %eax,%eax
f01001fa:	74 f5                	je     f01001f1 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001fc:	8b 8b 7c 1f 00 00    	mov    0x1f7c(%ebx),%ecx
f0100202:	8d 51 01             	lea    0x1(%ecx),%edx
f0100205:	89 93 7c 1f 00 00    	mov    %edx,0x1f7c(%ebx)
f010020b:	88 84 0b 78 1d 00 00 	mov    %al,0x1d78(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100212:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100218:	75 d7                	jne    f01001f1 <cons_intr+0x12>
			cons.wpos = 0;
f010021a:	c7 83 7c 1f 00 00 00 	movl   $0x0,0x1f7c(%ebx)
f0100221:	00 00 00 
f0100224:	eb cb                	jmp    f01001f1 <cons_intr+0x12>
	}
}
f0100226:	5b                   	pop    %ebx
f0100227:	5e                   	pop    %esi
f0100228:	5d                   	pop    %ebp
f0100229:	c3                   	ret    

f010022a <kbd_proc_data>:
{
f010022a:	55                   	push   %ebp
f010022b:	89 e5                	mov    %esp,%ebp
f010022d:	56                   	push   %esi
f010022e:	53                   	push   %ebx
f010022f:	e8 88 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100234:	81 c3 d4 10 01 00    	add    $0x110d4,%ebx
f010023a:	ba 64 00 00 00       	mov    $0x64,%edx
f010023f:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100240:	a8 01                	test   $0x1,%al
f0100242:	0f 84 06 01 00 00    	je     f010034e <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f0100248:	a8 20                	test   $0x20,%al
f010024a:	0f 85 05 01 00 00    	jne    f0100355 <kbd_proc_data+0x12b>
f0100250:	ba 60 00 00 00       	mov    $0x60,%edx
f0100255:	ec                   	in     (%dx),%al
f0100256:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100258:	3c e0                	cmp    $0xe0,%al
f010025a:	0f 84 93 00 00 00    	je     f01002f3 <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f0100260:	84 c0                	test   %al,%al
f0100262:	0f 88 a0 00 00 00    	js     f0100308 <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f0100268:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010026e:	f6 c1 40             	test   $0x40,%cl
f0100271:	74 0e                	je     f0100281 <kbd_proc_data+0x57>
		data |= 0x80;
f0100273:	83 c8 80             	or     $0xffffff80,%eax
f0100276:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100278:	83 e1 bf             	and    $0xffffffbf,%ecx
f010027b:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f0100281:	0f b6 d2             	movzbl %dl,%edx
f0100284:	0f b6 84 13 d8 08 ff 	movzbl -0xf728(%ebx,%edx,1),%eax
f010028b:	ff 
f010028c:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f0100292:	0f b6 8c 13 d8 07 ff 	movzbl -0xf828(%ebx,%edx,1),%ecx
f0100299:	ff 
f010029a:	31 c8                	xor    %ecx,%eax
f010029c:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002a2:	89 c1                	mov    %eax,%ecx
f01002a4:	83 e1 03             	and    $0x3,%ecx
f01002a7:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002ae:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002b2:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002b5:	a8 08                	test   $0x8,%al
f01002b7:	74 0d                	je     f01002c6 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f01002b9:	89 f2                	mov    %esi,%edx
f01002bb:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002be:	83 f9 19             	cmp    $0x19,%ecx
f01002c1:	77 7a                	ja     f010033d <kbd_proc_data+0x113>
			c += 'A' - 'a';
f01002c3:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002c6:	f7 d0                	not    %eax
f01002c8:	a8 06                	test   $0x6,%al
f01002ca:	75 33                	jne    f01002ff <kbd_proc_data+0xd5>
f01002cc:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002d2:	75 2b                	jne    f01002ff <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f01002d4:	83 ec 0c             	sub    $0xc,%esp
f01002d7:	8d 83 9c 07 ff ff    	lea    -0xf864(%ebx),%eax
f01002dd:	50                   	push   %eax
f01002de:	e8 66 07 00 00       	call   f0100a49 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e3:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e8:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ed:	ee                   	out    %al,(%dx)
f01002ee:	83 c4 10             	add    $0x10,%esp
f01002f1:	eb 0c                	jmp    f01002ff <kbd_proc_data+0xd5>
		shift |= E0ESC;
f01002f3:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002fa:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002ff:	89 f0                	mov    %esi,%eax
f0100301:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100304:	5b                   	pop    %ebx
f0100305:	5e                   	pop    %esi
f0100306:	5d                   	pop    %ebp
f0100307:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100308:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010030e:	89 ce                	mov    %ecx,%esi
f0100310:	83 e6 40             	and    $0x40,%esi
f0100313:	83 e0 7f             	and    $0x7f,%eax
f0100316:	85 f6                	test   %esi,%esi
f0100318:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010031b:	0f b6 d2             	movzbl %dl,%edx
f010031e:	0f b6 84 13 d8 08 ff 	movzbl -0xf728(%ebx,%edx,1),%eax
f0100325:	ff 
f0100326:	83 c8 40             	or     $0x40,%eax
f0100329:	0f b6 c0             	movzbl %al,%eax
f010032c:	f7 d0                	not    %eax
f010032e:	21 c8                	and    %ecx,%eax
f0100330:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f0100336:	be 00 00 00 00       	mov    $0x0,%esi
f010033b:	eb c2                	jmp    f01002ff <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f010033d:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100340:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100343:	83 fa 1a             	cmp    $0x1a,%edx
f0100346:	0f 42 f1             	cmovb  %ecx,%esi
f0100349:	e9 78 ff ff ff       	jmp    f01002c6 <kbd_proc_data+0x9c>
		return -1;
f010034e:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100353:	eb aa                	jmp    f01002ff <kbd_proc_data+0xd5>
		return -1;
f0100355:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010035a:	eb a3                	jmp    f01002ff <kbd_proc_data+0xd5>

f010035c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010035c:	55                   	push   %ebp
f010035d:	89 e5                	mov    %esp,%ebp
f010035f:	57                   	push   %edi
f0100360:	56                   	push   %esi
f0100361:	53                   	push   %ebx
f0100362:	83 ec 1c             	sub    $0x1c,%esp
f0100365:	e8 52 fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010036a:	81 c3 9e 0f 01 00    	add    $0x10f9e,%ebx
f0100370:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100373:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100378:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010037d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100382:	eb 09                	jmp    f010038d <cons_putc+0x31>
f0100384:	89 ca                	mov    %ecx,%edx
f0100386:	ec                   	in     (%dx),%al
f0100387:	ec                   	in     (%dx),%al
f0100388:	ec                   	in     (%dx),%al
f0100389:	ec                   	in     (%dx),%al
	     i++)
f010038a:	83 c6 01             	add    $0x1,%esi
f010038d:	89 fa                	mov    %edi,%edx
f010038f:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100390:	a8 20                	test   $0x20,%al
f0100392:	75 08                	jne    f010039c <cons_putc+0x40>
f0100394:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010039a:	7e e8                	jle    f0100384 <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f010039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010039f:	89 f8                	mov    %edi,%eax
f01003a1:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003a9:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003aa:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003af:	bf 79 03 00 00       	mov    $0x379,%edi
f01003b4:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003b9:	eb 09                	jmp    f01003c4 <cons_putc+0x68>
f01003bb:	89 ca                	mov    %ecx,%edx
f01003bd:	ec                   	in     (%dx),%al
f01003be:	ec                   	in     (%dx),%al
f01003bf:	ec                   	in     (%dx),%al
f01003c0:	ec                   	in     (%dx),%al
f01003c1:	83 c6 01             	add    $0x1,%esi
f01003c4:	89 fa                	mov    %edi,%edx
f01003c6:	ec                   	in     (%dx),%al
f01003c7:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003cd:	7f 04                	jg     f01003d3 <cons_putc+0x77>
f01003cf:	84 c0                	test   %al,%al
f01003d1:	79 e8                	jns    f01003bb <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d3:	ba 78 03 00 00       	mov    $0x378,%edx
f01003d8:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003dc:	ee                   	out    %al,(%dx)
f01003dd:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003e7:	ee                   	out    %al,(%dx)
f01003e8:	b8 08 00 00 00       	mov    $0x8,%eax
f01003ed:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003f1:	89 fa                	mov    %edi,%edx
f01003f3:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003f9:	89 f8                	mov    %edi,%eax
f01003fb:	80 cc 07             	or     $0x7,%ah
f01003fe:	85 d2                	test   %edx,%edx
f0100400:	0f 45 c7             	cmovne %edi,%eax
f0100403:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100406:	0f b6 c0             	movzbl %al,%eax
f0100409:	83 f8 09             	cmp    $0x9,%eax
f010040c:	0f 84 b9 00 00 00    	je     f01004cb <cons_putc+0x16f>
f0100412:	83 f8 09             	cmp    $0x9,%eax
f0100415:	7e 74                	jle    f010048b <cons_putc+0x12f>
f0100417:	83 f8 0a             	cmp    $0xa,%eax
f010041a:	0f 84 9e 00 00 00    	je     f01004be <cons_putc+0x162>
f0100420:	83 f8 0d             	cmp    $0xd,%eax
f0100423:	0f 85 d9 00 00 00    	jne    f0100502 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100429:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100430:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100436:	c1 e8 16             	shr    $0x16,%eax
f0100439:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010043c:	c1 e0 04             	shl    $0x4,%eax
f010043f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100446:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f010044d:	cf 07 
f010044f:	0f 87 d4 00 00 00    	ja     f0100529 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100455:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f010045b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100460:	89 ca                	mov    %ecx,%edx
f0100462:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100463:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f010046a:	8d 71 01             	lea    0x1(%ecx),%esi
f010046d:	89 d8                	mov    %ebx,%eax
f010046f:	66 c1 e8 08          	shr    $0x8,%ax
f0100473:	89 f2                	mov    %esi,%edx
f0100475:	ee                   	out    %al,(%dx)
f0100476:	b8 0f 00 00 00       	mov    $0xf,%eax
f010047b:	89 ca                	mov    %ecx,%edx
f010047d:	ee                   	out    %al,(%dx)
f010047e:	89 d8                	mov    %ebx,%eax
f0100480:	89 f2                	mov    %esi,%edx
f0100482:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100483:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100486:	5b                   	pop    %ebx
f0100487:	5e                   	pop    %esi
f0100488:	5f                   	pop    %edi
f0100489:	5d                   	pop    %ebp
f010048a:	c3                   	ret    
	switch (c & 0xff) {
f010048b:	83 f8 08             	cmp    $0x8,%eax
f010048e:	75 72                	jne    f0100502 <cons_putc+0x1a6>
		if (crt_pos > 0) {
f0100490:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100497:	66 85 c0             	test   %ax,%ax
f010049a:	74 b9                	je     f0100455 <cons_putc+0xf9>
			crt_pos--;
f010049c:	83 e8 01             	sub    $0x1,%eax
f010049f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a6:	0f b7 c0             	movzwl %ax,%eax
f01004a9:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004ad:	b2 00                	mov    $0x0,%dl
f01004af:	83 ca 20             	or     $0x20,%edx
f01004b2:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f01004b8:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004bc:	eb 88                	jmp    f0100446 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f01004be:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f01004c5:	50 
f01004c6:	e9 5e ff ff ff       	jmp    f0100429 <cons_putc+0xcd>
		cons_putc(' ');
f01004cb:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d0:	e8 87 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004d5:	b8 20 00 00 00       	mov    $0x20,%eax
f01004da:	e8 7d fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004df:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e4:	e8 73 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004e9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ee:	e8 69 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f8:	e8 5f fe ff ff       	call   f010035c <cons_putc>
f01004fd:	e9 44 ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100502:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100509:	8d 50 01             	lea    0x1(%eax),%edx
f010050c:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f0100513:	0f b7 c0             	movzwl %ax,%eax
f0100516:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010051c:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100520:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100524:	e9 1d ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100529:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f010052f:	83 ec 04             	sub    $0x4,%esp
f0100532:	68 00 0f 00 00       	push   $0xf00
f0100537:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010053d:	52                   	push   %edx
f010053e:	50                   	push   %eax
f010053f:	e8 e6 10 00 00       	call   f010162a <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100544:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010054a:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100550:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100556:	83 c4 10             	add    $0x10,%esp
f0100559:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010055e:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100561:	39 d0                	cmp    %edx,%eax
f0100563:	75 f4                	jne    f0100559 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100565:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f010056c:	50 
f010056d:	e9 e3 fe ff ff       	jmp    f0100455 <cons_putc+0xf9>

f0100572 <serial_intr>:
{
f0100572:	e8 e7 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f0100577:	05 91 0d 01 00       	add    $0x10d91,%eax
	if (serial_exists)
f010057c:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100583:	75 02                	jne    f0100587 <serial_intr+0x15>
f0100585:	f3 c3                	repz ret 
{
f0100587:	55                   	push   %ebp
f0100588:	89 e5                	mov    %esp,%ebp
f010058a:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010058d:	8d 80 b8 ee fe ff    	lea    -0x11148(%eax),%eax
f0100593:	e8 47 fc ff ff       	call   f01001df <cons_intr>
}
f0100598:	c9                   	leave  
f0100599:	c3                   	ret    

f010059a <kbd_intr>:
{
f010059a:	55                   	push   %ebp
f010059b:	89 e5                	mov    %esp,%ebp
f010059d:	83 ec 08             	sub    $0x8,%esp
f01005a0:	e8 b9 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f01005a5:	05 63 0d 01 00       	add    $0x10d63,%eax
	cons_intr(kbd_proc_data);
f01005aa:	8d 80 22 ef fe ff    	lea    -0x110de(%eax),%eax
f01005b0:	e8 2a fc ff ff       	call   f01001df <cons_intr>
}
f01005b5:	c9                   	leave  
f01005b6:	c3                   	ret    

f01005b7 <cons_getc>:
{
f01005b7:	55                   	push   %ebp
f01005b8:	89 e5                	mov    %esp,%ebp
f01005ba:	53                   	push   %ebx
f01005bb:	83 ec 04             	sub    $0x4,%esp
f01005be:	e8 f9 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005c3:	81 c3 45 0d 01 00    	add    $0x10d45,%ebx
	serial_intr();
f01005c9:	e8 a4 ff ff ff       	call   f0100572 <serial_intr>
	kbd_intr();
f01005ce:	e8 c7 ff ff ff       	call   f010059a <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005d3:	8b 93 78 1f 00 00    	mov    0x1f78(%ebx),%edx
	return 0;
f01005d9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005de:	3b 93 7c 1f 00 00    	cmp    0x1f7c(%ebx),%edx
f01005e4:	74 19                	je     f01005ff <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f01005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
f01005e9:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
f01005ef:	0f b6 84 13 78 1d 00 	movzbl 0x1d78(%ebx,%edx,1),%eax
f01005f6:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005f7:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005fd:	74 06                	je     f0100605 <cons_getc+0x4e>
}
f01005ff:	83 c4 04             	add    $0x4,%esp
f0100602:	5b                   	pop    %ebx
f0100603:	5d                   	pop    %ebp
f0100604:	c3                   	ret    
			cons.rpos = 0;
f0100605:	c7 83 78 1f 00 00 00 	movl   $0x0,0x1f78(%ebx)
f010060c:	00 00 00 
f010060f:	eb ee                	jmp    f01005ff <cons_getc+0x48>

f0100611 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100611:	55                   	push   %ebp
f0100612:	89 e5                	mov    %esp,%ebp
f0100614:	57                   	push   %edi
f0100615:	56                   	push   %esi
f0100616:	53                   	push   %ebx
f0100617:	83 ec 1c             	sub    $0x1c,%esp
f010061a:	e8 9d fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010061f:	81 c3 e9 0c 01 00    	add    $0x10ce9,%ebx
	was = *cp;
f0100625:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010062c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100633:	5a a5 
	if (*cp != 0xA55A) {
f0100635:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010063c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100640:	0f 84 bc 00 00 00    	je     f0100702 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100646:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f010064d:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100650:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100657:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f010065d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100662:	89 fa                	mov    %edi,%edx
f0100664:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100665:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100668:	89 ca                	mov    %ecx,%edx
f010066a:	ec                   	in     (%dx),%al
f010066b:	0f b6 f0             	movzbl %al,%esi
f010066e:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100671:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100676:	89 fa                	mov    %edi,%edx
f0100678:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100679:	89 ca                	mov    %ecx,%edx
f010067b:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010067f:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f0100685:	0f b6 c0             	movzbl %al,%eax
f0100688:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010068a:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100691:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100696:	89 c8                	mov    %ecx,%eax
f0100698:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010069d:	ee                   	out    %al,(%dx)
f010069e:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006a3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a8:	89 fa                	mov    %edi,%edx
f01006aa:	ee                   	out    %al,(%dx)
f01006ab:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006b0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006b5:	ee                   	out    %al,(%dx)
f01006b6:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006bb:	89 c8                	mov    %ecx,%eax
f01006bd:	89 f2                	mov    %esi,%edx
f01006bf:	ee                   	out    %al,(%dx)
f01006c0:	b8 03 00 00 00       	mov    $0x3,%eax
f01006c5:	89 fa                	mov    %edi,%edx
f01006c7:	ee                   	out    %al,(%dx)
f01006c8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006cd:	89 c8                	mov    %ecx,%eax
f01006cf:	ee                   	out    %al,(%dx)
f01006d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01006d5:	89 f2                	mov    %esi,%edx
f01006d7:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d8:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006dd:	ec                   	in     (%dx),%al
f01006de:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006e0:	3c ff                	cmp    $0xff,%al
f01006e2:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f01006e9:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006ee:	ec                   	in     (%dx),%al
f01006ef:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006f4:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006f5:	80 f9 ff             	cmp    $0xff,%cl
f01006f8:	74 25                	je     f010071f <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006fd:	5b                   	pop    %ebx
f01006fe:	5e                   	pop    %esi
f01006ff:	5f                   	pop    %edi
f0100700:	5d                   	pop    %ebp
f0100701:	c3                   	ret    
		*cp = was;
f0100702:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100709:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f0100710:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100713:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f010071a:	e9 38 ff ff ff       	jmp    f0100657 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f010071f:	83 ec 0c             	sub    $0xc,%esp
f0100722:	8d 83 a8 07 ff ff    	lea    -0xf858(%ebx),%eax
f0100728:	50                   	push   %eax
f0100729:	e8 1b 03 00 00       	call   f0100a49 <cprintf>
f010072e:	83 c4 10             	add    $0x10,%esp
}
f0100731:	eb c7                	jmp    f01006fa <cons_init+0xe9>

f0100733 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100733:	55                   	push   %ebp
f0100734:	89 e5                	mov    %esp,%ebp
f0100736:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100739:	8b 45 08             	mov    0x8(%ebp),%eax
f010073c:	e8 1b fc ff ff       	call   f010035c <cons_putc>
}
f0100741:	c9                   	leave  
f0100742:	c3                   	ret    

f0100743 <getchar>:

int
getchar(void)
{
f0100743:	55                   	push   %ebp
f0100744:	89 e5                	mov    %esp,%ebp
f0100746:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100749:	e8 69 fe ff ff       	call   f01005b7 <cons_getc>
f010074e:	85 c0                	test   %eax,%eax
f0100750:	74 f7                	je     f0100749 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100752:	c9                   	leave  
f0100753:	c3                   	ret    

f0100754 <iscons>:

int
iscons(int fdnum)
{
f0100754:	55                   	push   %ebp
f0100755:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100757:	b8 01 00 00 00       	mov    $0x1,%eax
f010075c:	5d                   	pop    %ebp
f010075d:	c3                   	ret    

f010075e <__x86.get_pc_thunk.ax>:
f010075e:	8b 04 24             	mov    (%esp),%eax
f0100761:	c3                   	ret    

f0100762 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100762:	55                   	push   %ebp
f0100763:	89 e5                	mov    %esp,%ebp
f0100765:	56                   	push   %esi
f0100766:	53                   	push   %ebx
f0100767:	e8 50 fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010076c:	81 c3 9c 0b 01 00    	add    $0x10b9c,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100772:	83 ec 04             	sub    $0x4,%esp
f0100775:	8d 83 d8 09 ff ff    	lea    -0xf628(%ebx),%eax
f010077b:	50                   	push   %eax
f010077c:	8d 83 f6 09 ff ff    	lea    -0xf60a(%ebx),%eax
f0100782:	50                   	push   %eax
f0100783:	8d b3 fb 09 ff ff    	lea    -0xf605(%ebx),%esi
f0100789:	56                   	push   %esi
f010078a:	e8 ba 02 00 00       	call   f0100a49 <cprintf>
f010078f:	83 c4 0c             	add    $0xc,%esp
f0100792:	8d 83 64 0a ff ff    	lea    -0xf59c(%ebx),%eax
f0100798:	50                   	push   %eax
f0100799:	8d 83 04 0a ff ff    	lea    -0xf5fc(%ebx),%eax
f010079f:	50                   	push   %eax
f01007a0:	56                   	push   %esi
f01007a1:	e8 a3 02 00 00       	call   f0100a49 <cprintf>
	return 0;
}
f01007a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007ae:	5b                   	pop    %ebx
f01007af:	5e                   	pop    %esi
f01007b0:	5d                   	pop    %ebp
f01007b1:	c3                   	ret    

f01007b2 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007b2:	55                   	push   %ebp
f01007b3:	89 e5                	mov    %esp,%ebp
f01007b5:	57                   	push   %edi
f01007b6:	56                   	push   %esi
f01007b7:	53                   	push   %ebx
f01007b8:	83 ec 18             	sub    $0x18,%esp
f01007bb:	e8 fc f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007c0:	81 c3 48 0b 01 00    	add    $0x10b48,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007c6:	8d 83 0d 0a ff ff    	lea    -0xf5f3(%ebx),%eax
f01007cc:	50                   	push   %eax
f01007cd:	e8 77 02 00 00       	call   f0100a49 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007d2:	83 c4 08             	add    $0x8,%esp
f01007d5:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007db:	8d 83 8c 0a ff ff    	lea    -0xf574(%ebx),%eax
f01007e1:	50                   	push   %eax
f01007e2:	e8 62 02 00 00       	call   f0100a49 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e7:	83 c4 0c             	add    $0xc,%esp
f01007ea:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007f0:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007f6:	50                   	push   %eax
f01007f7:	57                   	push   %edi
f01007f8:	8d 83 b4 0a ff ff    	lea    -0xf54c(%ebx),%eax
f01007fe:	50                   	push   %eax
f01007ff:	e8 45 02 00 00       	call   f0100a49 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100804:	83 c4 0c             	add    $0xc,%esp
f0100807:	c7 c0 19 1a 10 f0    	mov    $0xf0101a19,%eax
f010080d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100813:	52                   	push   %edx
f0100814:	50                   	push   %eax
f0100815:	8d 83 d8 0a ff ff    	lea    -0xf528(%ebx),%eax
f010081b:	50                   	push   %eax
f010081c:	e8 28 02 00 00       	call   f0100a49 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100821:	83 c4 0c             	add    $0xc,%esp
f0100824:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f010082a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100830:	52                   	push   %edx
f0100831:	50                   	push   %eax
f0100832:	8d 83 fc 0a ff ff    	lea    -0xf504(%ebx),%eax
f0100838:	50                   	push   %eax
f0100839:	e8 0b 02 00 00       	call   f0100a49 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010083e:	83 c4 0c             	add    $0xc,%esp
f0100841:	c7 c6 a0 36 11 f0    	mov    $0xf01136a0,%esi
f0100847:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010084d:	50                   	push   %eax
f010084e:	56                   	push   %esi
f010084f:	8d 83 20 0b ff ff    	lea    -0xf4e0(%ebx),%eax
f0100855:	50                   	push   %eax
f0100856:	e8 ee 01 00 00       	call   f0100a49 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010085b:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010085e:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f0100864:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100866:	c1 fe 0a             	sar    $0xa,%esi
f0100869:	56                   	push   %esi
f010086a:	8d 83 44 0b ff ff    	lea    -0xf4bc(%ebx),%eax
f0100870:	50                   	push   %eax
f0100871:	e8 d3 01 00 00       	call   f0100a49 <cprintf>
	return 0;
}
f0100876:	b8 00 00 00 00       	mov    $0x0,%eax
f010087b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010087e:	5b                   	pop    %ebx
f010087f:	5e                   	pop    %esi
f0100880:	5f                   	pop    %edi
f0100881:	5d                   	pop    %ebp
f0100882:	c3                   	ret    

f0100883 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100883:	55                   	push   %ebp
f0100884:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100886:	b8 00 00 00 00       	mov    $0x0,%eax
f010088b:	5d                   	pop    %ebp
f010088c:	c3                   	ret    

f010088d <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010088d:	55                   	push   %ebp
f010088e:	89 e5                	mov    %esp,%ebp
f0100890:	57                   	push   %edi
f0100891:	56                   	push   %esi
f0100892:	53                   	push   %ebx
f0100893:	83 ec 68             	sub    $0x68,%esp
f0100896:	e8 21 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010089b:	81 c3 6d 0a 01 00    	add    $0x10a6d,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008a1:	8d 83 70 0b ff ff    	lea    -0xf490(%ebx),%eax
f01008a7:	50                   	push   %eax
f01008a8:	e8 9c 01 00 00       	call   f0100a49 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008ad:	8d 83 94 0b ff ff    	lea    -0xf46c(%ebx),%eax
f01008b3:	89 04 24             	mov    %eax,(%esp)
f01008b6:	e8 8e 01 00 00       	call   f0100a49 <cprintf>
f01008bb:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f01008be:	8d bb 2a 0a ff ff    	lea    -0xf5d6(%ebx),%edi
f01008c4:	eb 4a                	jmp    f0100910 <monitor+0x83>
f01008c6:	83 ec 08             	sub    $0x8,%esp
f01008c9:	0f be c0             	movsbl %al,%eax
f01008cc:	50                   	push   %eax
f01008cd:	57                   	push   %edi
f01008ce:	e8 cd 0c 00 00       	call   f01015a0 <strchr>
f01008d3:	83 c4 10             	add    $0x10,%esp
f01008d6:	85 c0                	test   %eax,%eax
f01008d8:	74 08                	je     f01008e2 <monitor+0x55>
			*buf++ = 0;
f01008da:	c6 06 00             	movb   $0x0,(%esi)
f01008dd:	8d 76 01             	lea    0x1(%esi),%esi
f01008e0:	eb 79                	jmp    f010095b <monitor+0xce>
		if (*buf == 0)
f01008e2:	80 3e 00             	cmpb   $0x0,(%esi)
f01008e5:	74 7f                	je     f0100966 <monitor+0xd9>
		if (argc == MAXARGS-1) {
f01008e7:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01008eb:	74 0f                	je     f01008fc <monitor+0x6f>
		argv[argc++] = buf;
f01008ed:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01008f0:	8d 48 01             	lea    0x1(%eax),%ecx
f01008f3:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01008f6:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f01008fa:	eb 44                	jmp    f0100940 <monitor+0xb3>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008fc:	83 ec 08             	sub    $0x8,%esp
f01008ff:	6a 10                	push   $0x10
f0100901:	8d 83 2f 0a ff ff    	lea    -0xf5d1(%ebx),%eax
f0100907:	50                   	push   %eax
f0100908:	e8 3c 01 00 00       	call   f0100a49 <cprintf>
f010090d:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100910:	8d 83 26 0a ff ff    	lea    -0xf5da(%ebx),%eax
f0100916:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100919:	83 ec 0c             	sub    $0xc,%esp
f010091c:	ff 75 a4             	pushl  -0x5c(%ebp)
f010091f:	e8 44 0a 00 00       	call   f0101368 <readline>
f0100924:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100926:	83 c4 10             	add    $0x10,%esp
f0100929:	85 c0                	test   %eax,%eax
f010092b:	74 ec                	je     f0100919 <monitor+0x8c>
	argv[argc] = 0;
f010092d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100934:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f010093b:	eb 1e                	jmp    f010095b <monitor+0xce>
			buf++;
f010093d:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100940:	0f b6 06             	movzbl (%esi),%eax
f0100943:	84 c0                	test   %al,%al
f0100945:	74 14                	je     f010095b <monitor+0xce>
f0100947:	83 ec 08             	sub    $0x8,%esp
f010094a:	0f be c0             	movsbl %al,%eax
f010094d:	50                   	push   %eax
f010094e:	57                   	push   %edi
f010094f:	e8 4c 0c 00 00       	call   f01015a0 <strchr>
f0100954:	83 c4 10             	add    $0x10,%esp
f0100957:	85 c0                	test   %eax,%eax
f0100959:	74 e2                	je     f010093d <monitor+0xb0>
		while (*buf && strchr(WHITESPACE, *buf))
f010095b:	0f b6 06             	movzbl (%esi),%eax
f010095e:	84 c0                	test   %al,%al
f0100960:	0f 85 60 ff ff ff    	jne    f01008c6 <monitor+0x39>
	argv[argc] = 0;
f0100966:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100969:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100970:	00 
	if (argc == 0)
f0100971:	85 c0                	test   %eax,%eax
f0100973:	74 9b                	je     f0100910 <monitor+0x83>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100975:	83 ec 08             	sub    $0x8,%esp
f0100978:	8d 83 f6 09 ff ff    	lea    -0xf60a(%ebx),%eax
f010097e:	50                   	push   %eax
f010097f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100982:	e8 bb 0b 00 00       	call   f0101542 <strcmp>
f0100987:	83 c4 10             	add    $0x10,%esp
f010098a:	85 c0                	test   %eax,%eax
f010098c:	74 38                	je     f01009c6 <monitor+0x139>
f010098e:	83 ec 08             	sub    $0x8,%esp
f0100991:	8d 83 04 0a ff ff    	lea    -0xf5fc(%ebx),%eax
f0100997:	50                   	push   %eax
f0100998:	ff 75 a8             	pushl  -0x58(%ebp)
f010099b:	e8 a2 0b 00 00       	call   f0101542 <strcmp>
f01009a0:	83 c4 10             	add    $0x10,%esp
f01009a3:	85 c0                	test   %eax,%eax
f01009a5:	74 1a                	je     f01009c1 <monitor+0x134>
	cprintf("Unknown command '%s'\n", argv[0]);
f01009a7:	83 ec 08             	sub    $0x8,%esp
f01009aa:	ff 75 a8             	pushl  -0x58(%ebp)
f01009ad:	8d 83 4c 0a ff ff    	lea    -0xf5b4(%ebx),%eax
f01009b3:	50                   	push   %eax
f01009b4:	e8 90 00 00 00       	call   f0100a49 <cprintf>
f01009b9:	83 c4 10             	add    $0x10,%esp
f01009bc:	e9 4f ff ff ff       	jmp    f0100910 <monitor+0x83>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009c1:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f01009c6:	83 ec 04             	sub    $0x4,%esp
f01009c9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01009cc:	ff 75 08             	pushl  0x8(%ebp)
f01009cf:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01009d2:	52                   	push   %edx
f01009d3:	ff 75 a4             	pushl  -0x5c(%ebp)
f01009d6:	ff 94 83 10 1d 00 00 	call   *0x1d10(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f01009dd:	83 c4 10             	add    $0x10,%esp
f01009e0:	85 c0                	test   %eax,%eax
f01009e2:	0f 89 28 ff ff ff    	jns    f0100910 <monitor+0x83>
				break;
	}
}
f01009e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009eb:	5b                   	pop    %ebx
f01009ec:	5e                   	pop    %esi
f01009ed:	5f                   	pop    %edi
f01009ee:	5d                   	pop    %ebp
f01009ef:	c3                   	ret    

f01009f0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01009f0:	55                   	push   %ebp
f01009f1:	89 e5                	mov    %esp,%ebp
f01009f3:	53                   	push   %ebx
f01009f4:	83 ec 10             	sub    $0x10,%esp
f01009f7:	e8 c0 f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01009fc:	81 c3 0c 09 01 00    	add    $0x1090c,%ebx
	cputchar(ch);
f0100a02:	ff 75 08             	pushl  0x8(%ebp)
f0100a05:	e8 29 fd ff ff       	call   f0100733 <cputchar>
	*cnt++;
}
f0100a0a:	83 c4 10             	add    $0x10,%esp
f0100a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a10:	c9                   	leave  
f0100a11:	c3                   	ret    

f0100a12 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100a12:	55                   	push   %ebp
f0100a13:	89 e5                	mov    %esp,%ebp
f0100a15:	53                   	push   %ebx
f0100a16:	83 ec 14             	sub    $0x14,%esp
f0100a19:	e8 9e f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100a1e:	81 c3 ea 08 01 00    	add    $0x108ea,%ebx
	int cnt = 0;
f0100a24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100a2b:	ff 75 0c             	pushl  0xc(%ebp)
f0100a2e:	ff 75 08             	pushl  0x8(%ebp)
f0100a31:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100a34:	50                   	push   %eax
f0100a35:	8d 83 e8 f6 fe ff    	lea    -0x10918(%ebx),%eax
f0100a3b:	50                   	push   %eax
f0100a3c:	e8 1c 04 00 00       	call   f0100e5d <vprintfmt>
	return cnt;
}
f0100a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a47:	c9                   	leave  
f0100a48:	c3                   	ret    

f0100a49 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100a49:	55                   	push   %ebp
f0100a4a:	89 e5                	mov    %esp,%ebp
f0100a4c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100a4f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100a52:	50                   	push   %eax
f0100a53:	ff 75 08             	pushl  0x8(%ebp)
f0100a56:	e8 b7 ff ff ff       	call   f0100a12 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100a5b:	c9                   	leave  
f0100a5c:	c3                   	ret    

f0100a5d <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100a5d:	55                   	push   %ebp
f0100a5e:	89 e5                	mov    %esp,%ebp
f0100a60:	57                   	push   %edi
f0100a61:	56                   	push   %esi
f0100a62:	53                   	push   %ebx
f0100a63:	83 ec 14             	sub    $0x14,%esp
f0100a66:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100a69:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100a6c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100a6f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100a72:	8b 32                	mov    (%edx),%esi
f0100a74:	8b 01                	mov    (%ecx),%eax
f0100a76:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a79:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100a80:	eb 2f                	jmp    f0100ab1 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100a82:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100a85:	39 c6                	cmp    %eax,%esi
f0100a87:	7f 49                	jg     f0100ad2 <stab_binsearch+0x75>
f0100a89:	0f b6 0a             	movzbl (%edx),%ecx
f0100a8c:	83 ea 0c             	sub    $0xc,%edx
f0100a8f:	39 f9                	cmp    %edi,%ecx
f0100a91:	75 ef                	jne    f0100a82 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100a93:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a96:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a99:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100a9d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100aa0:	73 35                	jae    f0100ad7 <stab_binsearch+0x7a>
			*region_left = m;
f0100aa2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100aa5:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0100aa7:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0100aaa:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100ab1:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0100ab4:	7f 4e                	jg     f0100b04 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0100ab6:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100ab9:	01 f0                	add    %esi,%eax
f0100abb:	89 c3                	mov    %eax,%ebx
f0100abd:	c1 eb 1f             	shr    $0x1f,%ebx
f0100ac0:	01 c3                	add    %eax,%ebx
f0100ac2:	d1 fb                	sar    %ebx
f0100ac4:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ac7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100aca:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100ace:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100ad0:	eb b3                	jmp    f0100a85 <stab_binsearch+0x28>
			l = true_m + 1;
f0100ad2:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100ad5:	eb da                	jmp    f0100ab1 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100ad7:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100ada:	76 14                	jbe    f0100af0 <stab_binsearch+0x93>
			*region_right = m - 1;
f0100adc:	83 e8 01             	sub    $0x1,%eax
f0100adf:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100ae2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100ae5:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100ae7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100aee:	eb c1                	jmp    f0100ab1 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100af0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100af3:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100af5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100af9:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0100afb:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b02:	eb ad                	jmp    f0100ab1 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100b04:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100b08:	74 16                	je     f0100b20 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b0d:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100b0f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b12:	8b 0e                	mov    (%esi),%ecx
f0100b14:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b17:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100b1a:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100b1e:	eb 12                	jmp    f0100b32 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0100b20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b23:	8b 00                	mov    (%eax),%eax
f0100b25:	83 e8 01             	sub    $0x1,%eax
f0100b28:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100b2b:	89 07                	mov    %eax,(%edi)
f0100b2d:	eb 16                	jmp    f0100b45 <stab_binsearch+0xe8>
		     l--)
f0100b2f:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100b32:	39 c1                	cmp    %eax,%ecx
f0100b34:	7d 0a                	jge    f0100b40 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0100b36:	0f b6 1a             	movzbl (%edx),%ebx
f0100b39:	83 ea 0c             	sub    $0xc,%edx
f0100b3c:	39 fb                	cmp    %edi,%ebx
f0100b3e:	75 ef                	jne    f0100b2f <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0100b40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b43:	89 07                	mov    %eax,(%edi)
	}
}
f0100b45:	83 c4 14             	add    $0x14,%esp
f0100b48:	5b                   	pop    %ebx
f0100b49:	5e                   	pop    %esi
f0100b4a:	5f                   	pop    %edi
f0100b4b:	5d                   	pop    %ebp
f0100b4c:	c3                   	ret    

f0100b4d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100b4d:	55                   	push   %ebp
f0100b4e:	89 e5                	mov    %esp,%ebp
f0100b50:	57                   	push   %edi
f0100b51:	56                   	push   %esi
f0100b52:	53                   	push   %ebx
f0100b53:	83 ec 2c             	sub    $0x2c,%esp
f0100b56:	e8 fa 01 00 00       	call   f0100d55 <__x86.get_pc_thunk.cx>
f0100b5b:	81 c1 ad 07 01 00    	add    $0x107ad,%ecx
f0100b61:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100b64:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100b67:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100b6a:	8d 81 bc 0b ff ff    	lea    -0xf444(%ecx),%eax
f0100b70:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0100b72:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0100b79:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f0100b7c:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0100b83:	89 5f 10             	mov    %ebx,0x10(%edi)
	info->eip_fn_narg = 0;
f0100b86:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100b8d:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0100b93:	0f 86 f4 00 00 00    	jbe    f0100c8d <debuginfo_eip+0x140>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b99:	c7 c0 a5 5c 10 f0    	mov    $0xf0105ca5,%eax
f0100b9f:	39 81 fc ff ff ff    	cmp    %eax,-0x4(%ecx)
f0100ba5:	0f 86 88 01 00 00    	jbe    f0100d33 <debuginfo_eip+0x1e6>
f0100bab:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0100bae:	c7 c0 ec 75 10 f0    	mov    $0xf01075ec,%eax
f0100bb4:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100bb8:	0f 85 7c 01 00 00    	jne    f0100d3a <debuginfo_eip+0x1ed>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100bbe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100bc5:	c7 c0 e0 20 10 f0    	mov    $0xf01020e0,%eax
f0100bcb:	c7 c2 a4 5c 10 f0    	mov    $0xf0105ca4,%edx
f0100bd1:	29 c2                	sub    %eax,%edx
f0100bd3:	c1 fa 02             	sar    $0x2,%edx
f0100bd6:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100bdc:	83 ea 01             	sub    $0x1,%edx
f0100bdf:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100be2:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100be5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100be8:	83 ec 08             	sub    $0x8,%esp
f0100beb:	53                   	push   %ebx
f0100bec:	6a 64                	push   $0x64
f0100bee:	e8 6a fe ff ff       	call   f0100a5d <stab_binsearch>
	if (lfile == 0)
f0100bf3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bf6:	83 c4 10             	add    $0x10,%esp
f0100bf9:	85 c0                	test   %eax,%eax
f0100bfb:	0f 84 40 01 00 00    	je     f0100d41 <debuginfo_eip+0x1f4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100c01:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100c04:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c07:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100c0a:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100c0d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c10:	83 ec 08             	sub    $0x8,%esp
f0100c13:	53                   	push   %ebx
f0100c14:	6a 24                	push   $0x24
f0100c16:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0100c19:	c7 c0 e0 20 10 f0    	mov    $0xf01020e0,%eax
f0100c1f:	e8 39 fe ff ff       	call   f0100a5d <stab_binsearch>

	if (lfun <= rfun) {
f0100c24:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0100c27:	83 c4 10             	add    $0x10,%esp
f0100c2a:	3b 75 d8             	cmp    -0x28(%ebp),%esi
f0100c2d:	7f 79                	jg     f0100ca8 <debuginfo_eip+0x15b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100c2f:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100c32:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c35:	c7 c2 e0 20 10 f0    	mov    $0xf01020e0,%edx
f0100c3b:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f0100c3e:	8b 11                	mov    (%ecx),%edx
f0100c40:	c7 c0 ec 75 10 f0    	mov    $0xf01075ec,%eax
f0100c46:	81 e8 a5 5c 10 f0    	sub    $0xf0105ca5,%eax
f0100c4c:	39 c2                	cmp    %eax,%edx
f0100c4e:	73 09                	jae    f0100c59 <debuginfo_eip+0x10c>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100c50:	81 c2 a5 5c 10 f0    	add    $0xf0105ca5,%edx
f0100c56:	89 57 08             	mov    %edx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100c59:	8b 41 08             	mov    0x8(%ecx),%eax
f0100c5c:	89 47 10             	mov    %eax,0x10(%edi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100c5f:	83 ec 08             	sub    $0x8,%esp
f0100c62:	6a 3a                	push   $0x3a
f0100c64:	ff 77 08             	pushl  0x8(%edi)
f0100c67:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c6a:	e8 52 09 00 00       	call   f01015c1 <strfind>
f0100c6f:	2b 47 08             	sub    0x8(%edi),%eax
f0100c72:	89 47 0c             	mov    %eax,0xc(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c75:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100c78:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100c7b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100c7e:	c7 c2 e0 20 10 f0    	mov    $0xf01020e0,%edx
f0100c84:	8d 44 82 04          	lea    0x4(%edx,%eax,4),%eax
f0100c88:	83 c4 10             	add    $0x10,%esp
f0100c8b:	eb 29                	jmp    f0100cb6 <debuginfo_eip+0x169>
  	        panic("User address");
f0100c8d:	83 ec 04             	sub    $0x4,%esp
f0100c90:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c93:	8d 83 c6 0b ff ff    	lea    -0xf43a(%ebx),%eax
f0100c99:	50                   	push   %eax
f0100c9a:	6a 7f                	push   $0x7f
f0100c9c:	8d 83 d3 0b ff ff    	lea    -0xf42d(%ebx),%eax
f0100ca2:	50                   	push   %eax
f0100ca3:	e8 5e f4 ff ff       	call   f0100106 <_panic>
		info->eip_fn_addr = addr;
f0100ca8:	89 5f 10             	mov    %ebx,0x10(%edi)
		lline = lfile;
f0100cab:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100cae:	eb af                	jmp    f0100c5f <debuginfo_eip+0x112>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100cb0:	83 ee 01             	sub    $0x1,%esi
f0100cb3:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100cb6:	39 f3                	cmp    %esi,%ebx
f0100cb8:	7f 3a                	jg     f0100cf4 <debuginfo_eip+0x1a7>
	       && stabs[lline].n_type != N_SOL
f0100cba:	0f b6 10             	movzbl (%eax),%edx
f0100cbd:	80 fa 84             	cmp    $0x84,%dl
f0100cc0:	74 0b                	je     f0100ccd <debuginfo_eip+0x180>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100cc2:	80 fa 64             	cmp    $0x64,%dl
f0100cc5:	75 e9                	jne    f0100cb0 <debuginfo_eip+0x163>
f0100cc7:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100ccb:	74 e3                	je     f0100cb0 <debuginfo_eip+0x163>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100ccd:	8d 14 76             	lea    (%esi,%esi,2),%edx
f0100cd0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100cd3:	c7 c0 e0 20 10 f0    	mov    $0xf01020e0,%eax
f0100cd9:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100cdc:	c7 c0 ec 75 10 f0    	mov    $0xf01075ec,%eax
f0100ce2:	81 e8 a5 5c 10 f0    	sub    $0xf0105ca5,%eax
f0100ce8:	39 c2                	cmp    %eax,%edx
f0100cea:	73 08                	jae    f0100cf4 <debuginfo_eip+0x1a7>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100cec:	81 c2 a5 5c 10 f0    	add    $0xf0105ca5,%edx
f0100cf2:	89 17                	mov    %edx,(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100cf4:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100cf7:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cfa:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100cff:	39 cb                	cmp    %ecx,%ebx
f0100d01:	7d 4a                	jge    f0100d4d <debuginfo_eip+0x200>
		for (lline = lfun + 1;
f0100d03:	8d 53 01             	lea    0x1(%ebx),%edx
f0100d06:	8d 1c 5b             	lea    (%ebx,%ebx,2),%ebx
f0100d09:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d0c:	c7 c0 e0 20 10 f0    	mov    $0xf01020e0,%eax
f0100d12:	8d 44 98 10          	lea    0x10(%eax,%ebx,4),%eax
f0100d16:	eb 07                	jmp    f0100d1f <debuginfo_eip+0x1d2>
			info->eip_fn_narg++;
f0100d18:	83 47 14 01          	addl   $0x1,0x14(%edi)
		     lline++)
f0100d1c:	83 c2 01             	add    $0x1,%edx
		for (lline = lfun + 1;
f0100d1f:	39 d1                	cmp    %edx,%ecx
f0100d21:	74 25                	je     f0100d48 <debuginfo_eip+0x1fb>
f0100d23:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100d26:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0100d2a:	74 ec                	je     f0100d18 <debuginfo_eip+0x1cb>
	return 0;
f0100d2c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d31:	eb 1a                	jmp    f0100d4d <debuginfo_eip+0x200>
		return -1;
f0100d33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d38:	eb 13                	jmp    f0100d4d <debuginfo_eip+0x200>
f0100d3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d3f:	eb 0c                	jmp    f0100d4d <debuginfo_eip+0x200>
		return -1;
f0100d41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d46:	eb 05                	jmp    f0100d4d <debuginfo_eip+0x200>
	return 0;
f0100d48:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d50:	5b                   	pop    %ebx
f0100d51:	5e                   	pop    %esi
f0100d52:	5f                   	pop    %edi
f0100d53:	5d                   	pop    %ebp
f0100d54:	c3                   	ret    

f0100d55 <__x86.get_pc_thunk.cx>:
f0100d55:	8b 0c 24             	mov    (%esp),%ecx
f0100d58:	c3                   	ret    

f0100d59 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100d59:	55                   	push   %ebp
f0100d5a:	89 e5                	mov    %esp,%ebp
f0100d5c:	57                   	push   %edi
f0100d5d:	56                   	push   %esi
f0100d5e:	53                   	push   %ebx
f0100d5f:	83 ec 2c             	sub    $0x2c,%esp
f0100d62:	e8 ee ff ff ff       	call   f0100d55 <__x86.get_pc_thunk.cx>
f0100d67:	81 c1 a1 05 01 00    	add    $0x105a1,%ecx
f0100d6d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100d70:	89 c7                	mov    %eax,%edi
f0100d72:	89 d6                	mov    %edx,%esi
f0100d74:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d77:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d7a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d7d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100d80:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100d83:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100d88:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0100d8b:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0100d8e:	39 d3                	cmp    %edx,%ebx
f0100d90:	72 09                	jb     f0100d9b <printnum+0x42>
f0100d92:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100d95:	0f 87 83 00 00 00    	ja     f0100e1e <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100d9b:	83 ec 0c             	sub    $0xc,%esp
f0100d9e:	ff 75 18             	pushl  0x18(%ebp)
f0100da1:	8b 45 14             	mov    0x14(%ebp),%eax
f0100da4:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100da7:	53                   	push   %ebx
f0100da8:	ff 75 10             	pushl  0x10(%ebp)
f0100dab:	83 ec 08             	sub    $0x8,%esp
f0100dae:	ff 75 dc             	pushl  -0x24(%ebp)
f0100db1:	ff 75 d8             	pushl  -0x28(%ebp)
f0100db4:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100db7:	ff 75 d0             	pushl  -0x30(%ebp)
f0100dba:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100dbd:	e8 1e 0a 00 00       	call   f01017e0 <__udivdi3>
f0100dc2:	83 c4 18             	add    $0x18,%esp
f0100dc5:	52                   	push   %edx
f0100dc6:	50                   	push   %eax
f0100dc7:	89 f2                	mov    %esi,%edx
f0100dc9:	89 f8                	mov    %edi,%eax
f0100dcb:	e8 89 ff ff ff       	call   f0100d59 <printnum>
f0100dd0:	83 c4 20             	add    $0x20,%esp
f0100dd3:	eb 13                	jmp    f0100de8 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100dd5:	83 ec 08             	sub    $0x8,%esp
f0100dd8:	56                   	push   %esi
f0100dd9:	ff 75 18             	pushl  0x18(%ebp)
f0100ddc:	ff d7                	call   *%edi
f0100dde:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100de1:	83 eb 01             	sub    $0x1,%ebx
f0100de4:	85 db                	test   %ebx,%ebx
f0100de6:	7f ed                	jg     f0100dd5 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100de8:	83 ec 08             	sub    $0x8,%esp
f0100deb:	56                   	push   %esi
f0100dec:	83 ec 04             	sub    $0x4,%esp
f0100def:	ff 75 dc             	pushl  -0x24(%ebp)
f0100df2:	ff 75 d8             	pushl  -0x28(%ebp)
f0100df5:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100df8:	ff 75 d0             	pushl  -0x30(%ebp)
f0100dfb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100dfe:	89 f3                	mov    %esi,%ebx
f0100e00:	e8 fb 0a 00 00       	call   f0101900 <__umoddi3>
f0100e05:	83 c4 14             	add    $0x14,%esp
f0100e08:	0f be 84 06 e1 0b ff 	movsbl -0xf41f(%esi,%eax,1),%eax
f0100e0f:	ff 
f0100e10:	50                   	push   %eax
f0100e11:	ff d7                	call   *%edi
}
f0100e13:	83 c4 10             	add    $0x10,%esp
f0100e16:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e19:	5b                   	pop    %ebx
f0100e1a:	5e                   	pop    %esi
f0100e1b:	5f                   	pop    %edi
f0100e1c:	5d                   	pop    %ebp
f0100e1d:	c3                   	ret    
f0100e1e:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100e21:	eb be                	jmp    f0100de1 <printnum+0x88>

f0100e23 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100e23:	55                   	push   %ebp
f0100e24:	89 e5                	mov    %esp,%ebp
f0100e26:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100e29:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100e2d:	8b 10                	mov    (%eax),%edx
f0100e2f:	3b 50 04             	cmp    0x4(%eax),%edx
f0100e32:	73 0a                	jae    f0100e3e <sprintputch+0x1b>
		*b->buf++ = ch;
f0100e34:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100e37:	89 08                	mov    %ecx,(%eax)
f0100e39:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e3c:	88 02                	mov    %al,(%edx)
}
f0100e3e:	5d                   	pop    %ebp
f0100e3f:	c3                   	ret    

f0100e40 <printfmt>:
{
f0100e40:	55                   	push   %ebp
f0100e41:	89 e5                	mov    %esp,%ebp
f0100e43:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100e46:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100e49:	50                   	push   %eax
f0100e4a:	ff 75 10             	pushl  0x10(%ebp)
f0100e4d:	ff 75 0c             	pushl  0xc(%ebp)
f0100e50:	ff 75 08             	pushl  0x8(%ebp)
f0100e53:	e8 05 00 00 00       	call   f0100e5d <vprintfmt>
}
f0100e58:	83 c4 10             	add    $0x10,%esp
f0100e5b:	c9                   	leave  
f0100e5c:	c3                   	ret    

f0100e5d <vprintfmt>:
{
f0100e5d:	55                   	push   %ebp
f0100e5e:	89 e5                	mov    %esp,%ebp
f0100e60:	57                   	push   %edi
f0100e61:	56                   	push   %esi
f0100e62:	53                   	push   %ebx
f0100e63:	83 ec 2c             	sub    $0x2c,%esp
f0100e66:	e8 51 f3 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100e6b:	81 c3 9d 04 01 00    	add    $0x1049d,%ebx
f0100e71:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100e74:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100e77:	e9 63 03 00 00       	jmp    f01011df <.L34+0x40>
		padc = ' ';
f0100e7c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0100e80:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0100e87:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0100e8e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0100e95:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e9a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100e9d:	8d 47 01             	lea    0x1(%edi),%eax
f0100ea0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100ea3:	0f b6 17             	movzbl (%edi),%edx
f0100ea6:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100ea9:	3c 55                	cmp    $0x55,%al
f0100eab:	0f 87 15 04 00 00    	ja     f01012c6 <.L22>
f0100eb1:	0f b6 c0             	movzbl %al,%eax
f0100eb4:	89 d9                	mov    %ebx,%ecx
f0100eb6:	03 8c 83 70 0c ff ff 	add    -0xf390(%ebx,%eax,4),%ecx
f0100ebd:	ff e1                	jmp    *%ecx

f0100ebf <.L70>:
f0100ebf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0100ec2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0100ec6:	eb d5                	jmp    f0100e9d <vprintfmt+0x40>

f0100ec8 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f0100ec8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0100ecb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100ecf:	eb cc                	jmp    f0100e9d <vprintfmt+0x40>

f0100ed1 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f0100ed1:	0f b6 d2             	movzbl %dl,%edx
f0100ed4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0100ed7:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f0100edc:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100edf:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0100ee3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0100ee6:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100ee9:	83 f9 09             	cmp    $0x9,%ecx
f0100eec:	77 55                	ja     f0100f43 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f0100eee:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0100ef1:	eb e9                	jmp    f0100edc <.L29+0xb>

f0100ef3 <.L26>:
			precision = va_arg(ap, int);
f0100ef3:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ef6:	8b 00                	mov    (%eax),%eax
f0100ef8:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100efb:	8b 45 14             	mov    0x14(%ebp),%eax
f0100efe:	8d 40 04             	lea    0x4(%eax),%eax
f0100f01:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f04:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0100f07:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f0b:	79 90                	jns    f0100e9d <vprintfmt+0x40>
				width = precision, precision = -1;
f0100f0d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0100f10:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f13:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0100f1a:	eb 81                	jmp    f0100e9d <vprintfmt+0x40>

f0100f1c <.L27>:
f0100f1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f1f:	85 c0                	test   %eax,%eax
f0100f21:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f26:	0f 49 d0             	cmovns %eax,%edx
f0100f29:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f2c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f2f:	e9 69 ff ff ff       	jmp    f0100e9d <vprintfmt+0x40>

f0100f34 <.L23>:
f0100f34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0100f37:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100f3e:	e9 5a ff ff ff       	jmp    f0100e9d <vprintfmt+0x40>
f0100f43:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100f46:	eb bf                	jmp    f0100f07 <.L26+0x14>

f0100f48 <.L33>:
			lflag++;
f0100f48:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f4c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0100f4f:	e9 49 ff ff ff       	jmp    f0100e9d <vprintfmt+0x40>

f0100f54 <.L30>:
			putch(va_arg(ap, int), putdat);
f0100f54:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f57:	8d 78 04             	lea    0x4(%eax),%edi
f0100f5a:	83 ec 08             	sub    $0x8,%esp
f0100f5d:	56                   	push   %esi
f0100f5e:	ff 30                	pushl  (%eax)
f0100f60:	ff 55 08             	call   *0x8(%ebp)
			break;
f0100f63:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0100f66:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0100f69:	e9 6e 02 00 00       	jmp    f01011dc <.L34+0x3d>

f0100f6e <.L32>:
			err = va_arg(ap, int);
f0100f6e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f71:	8d 78 04             	lea    0x4(%eax),%edi
f0100f74:	8b 00                	mov    (%eax),%eax
f0100f76:	99                   	cltd   
f0100f77:	31 d0                	xor    %edx,%eax
f0100f79:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f7b:	83 f8 06             	cmp    $0x6,%eax
f0100f7e:	7f 27                	jg     f0100fa7 <.L32+0x39>
f0100f80:	8b 94 83 20 1d 00 00 	mov    0x1d20(%ebx,%eax,4),%edx
f0100f87:	85 d2                	test   %edx,%edx
f0100f89:	74 1c                	je     f0100fa7 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f0100f8b:	52                   	push   %edx
f0100f8c:	8d 83 02 0c ff ff    	lea    -0xf3fe(%ebx),%eax
f0100f92:	50                   	push   %eax
f0100f93:	56                   	push   %esi
f0100f94:	ff 75 08             	pushl  0x8(%ebp)
f0100f97:	e8 a4 fe ff ff       	call   f0100e40 <printfmt>
f0100f9c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100f9f:	89 7d 14             	mov    %edi,0x14(%ebp)
f0100fa2:	e9 35 02 00 00       	jmp    f01011dc <.L34+0x3d>
				printfmt(putch, putdat, "error %d", err);
f0100fa7:	50                   	push   %eax
f0100fa8:	8d 83 f9 0b ff ff    	lea    -0xf407(%ebx),%eax
f0100fae:	50                   	push   %eax
f0100faf:	56                   	push   %esi
f0100fb0:	ff 75 08             	pushl  0x8(%ebp)
f0100fb3:	e8 88 fe ff ff       	call   f0100e40 <printfmt>
f0100fb8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100fbb:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0100fbe:	e9 19 02 00 00       	jmp    f01011dc <.L34+0x3d>

f0100fc3 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f0100fc3:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fc6:	83 c0 04             	add    $0x4,%eax
f0100fc9:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100fcc:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fcf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100fd1:	85 ff                	test   %edi,%edi
f0100fd3:	8d 83 f2 0b ff ff    	lea    -0xf40e(%ebx),%eax
f0100fd9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100fdc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100fe0:	0f 8e b5 00 00 00    	jle    f010109b <.L36+0xd8>
f0100fe6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100fea:	75 08                	jne    f0100ff4 <.L36+0x31>
f0100fec:	89 75 0c             	mov    %esi,0xc(%ebp)
f0100fef:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0100ff2:	eb 6d                	jmp    f0101061 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100ff4:	83 ec 08             	sub    $0x8,%esp
f0100ff7:	ff 75 cc             	pushl  -0x34(%ebp)
f0100ffa:	57                   	push   %edi
f0100ffb:	e8 7d 04 00 00       	call   f010147d <strnlen>
f0101000:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101003:	29 c2                	sub    %eax,%edx
f0101005:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0101008:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010100b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010100f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101012:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101015:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0101017:	eb 10                	jmp    f0101029 <.L36+0x66>
					putch(padc, putdat);
f0101019:	83 ec 08             	sub    $0x8,%esp
f010101c:	56                   	push   %esi
f010101d:	ff 75 e0             	pushl  -0x20(%ebp)
f0101020:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101023:	83 ef 01             	sub    $0x1,%edi
f0101026:	83 c4 10             	add    $0x10,%esp
f0101029:	85 ff                	test   %edi,%edi
f010102b:	7f ec                	jg     f0101019 <.L36+0x56>
f010102d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101030:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0101033:	85 d2                	test   %edx,%edx
f0101035:	b8 00 00 00 00       	mov    $0x0,%eax
f010103a:	0f 49 c2             	cmovns %edx,%eax
f010103d:	29 c2                	sub    %eax,%edx
f010103f:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101042:	89 75 0c             	mov    %esi,0xc(%ebp)
f0101045:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101048:	eb 17                	jmp    f0101061 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f010104a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010104e:	75 30                	jne    f0101080 <.L36+0xbd>
					putch(ch, putdat);
f0101050:	83 ec 08             	sub    $0x8,%esp
f0101053:	ff 75 0c             	pushl  0xc(%ebp)
f0101056:	50                   	push   %eax
f0101057:	ff 55 08             	call   *0x8(%ebp)
f010105a:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010105d:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f0101061:	83 c7 01             	add    $0x1,%edi
f0101064:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0101068:	0f be c2             	movsbl %dl,%eax
f010106b:	85 c0                	test   %eax,%eax
f010106d:	74 52                	je     f01010c1 <.L36+0xfe>
f010106f:	85 f6                	test   %esi,%esi
f0101071:	78 d7                	js     f010104a <.L36+0x87>
f0101073:	83 ee 01             	sub    $0x1,%esi
f0101076:	79 d2                	jns    f010104a <.L36+0x87>
f0101078:	8b 75 0c             	mov    0xc(%ebp),%esi
f010107b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010107e:	eb 32                	jmp    f01010b2 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f0101080:	0f be d2             	movsbl %dl,%edx
f0101083:	83 ea 20             	sub    $0x20,%edx
f0101086:	83 fa 5e             	cmp    $0x5e,%edx
f0101089:	76 c5                	jbe    f0101050 <.L36+0x8d>
					putch('?', putdat);
f010108b:	83 ec 08             	sub    $0x8,%esp
f010108e:	ff 75 0c             	pushl  0xc(%ebp)
f0101091:	6a 3f                	push   $0x3f
f0101093:	ff 55 08             	call   *0x8(%ebp)
f0101096:	83 c4 10             	add    $0x10,%esp
f0101099:	eb c2                	jmp    f010105d <.L36+0x9a>
f010109b:	89 75 0c             	mov    %esi,0xc(%ebp)
f010109e:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01010a1:	eb be                	jmp    f0101061 <.L36+0x9e>
				putch(' ', putdat);
f01010a3:	83 ec 08             	sub    $0x8,%esp
f01010a6:	56                   	push   %esi
f01010a7:	6a 20                	push   $0x20
f01010a9:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f01010ac:	83 ef 01             	sub    $0x1,%edi
f01010af:	83 c4 10             	add    $0x10,%esp
f01010b2:	85 ff                	test   %edi,%edi
f01010b4:	7f ed                	jg     f01010a3 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f01010b6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01010b9:	89 45 14             	mov    %eax,0x14(%ebp)
f01010bc:	e9 1b 01 00 00       	jmp    f01011dc <.L34+0x3d>
f01010c1:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01010c4:	8b 75 0c             	mov    0xc(%ebp),%esi
f01010c7:	eb e9                	jmp    f01010b2 <.L36+0xef>

f01010c9 <.L31>:
f01010c9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01010cc:	83 f9 01             	cmp    $0x1,%ecx
f01010cf:	7e 40                	jle    f0101111 <.L31+0x48>
		return va_arg(*ap, long long);
f01010d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01010d4:	8b 50 04             	mov    0x4(%eax),%edx
f01010d7:	8b 00                	mov    (%eax),%eax
f01010d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01010df:	8b 45 14             	mov    0x14(%ebp),%eax
f01010e2:	8d 40 08             	lea    0x8(%eax),%eax
f01010e5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01010e8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01010ec:	79 55                	jns    f0101143 <.L31+0x7a>
				putch('-', putdat);
f01010ee:	83 ec 08             	sub    $0x8,%esp
f01010f1:	56                   	push   %esi
f01010f2:	6a 2d                	push   $0x2d
f01010f4:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01010f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01010fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01010fd:	f7 da                	neg    %edx
f01010ff:	83 d1 00             	adc    $0x0,%ecx
f0101102:	f7 d9                	neg    %ecx
f0101104:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101107:	b8 0a 00 00 00       	mov    $0xa,%eax
f010110c:	e9 b0 00 00 00       	jmp    f01011c1 <.L34+0x22>
	else if (lflag)
f0101111:	85 c9                	test   %ecx,%ecx
f0101113:	75 17                	jne    f010112c <.L31+0x63>
		return va_arg(*ap, int);
f0101115:	8b 45 14             	mov    0x14(%ebp),%eax
f0101118:	8b 00                	mov    (%eax),%eax
f010111a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010111d:	99                   	cltd   
f010111e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101121:	8b 45 14             	mov    0x14(%ebp),%eax
f0101124:	8d 40 04             	lea    0x4(%eax),%eax
f0101127:	89 45 14             	mov    %eax,0x14(%ebp)
f010112a:	eb bc                	jmp    f01010e8 <.L31+0x1f>
		return va_arg(*ap, long);
f010112c:	8b 45 14             	mov    0x14(%ebp),%eax
f010112f:	8b 00                	mov    (%eax),%eax
f0101131:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101134:	99                   	cltd   
f0101135:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101138:	8b 45 14             	mov    0x14(%ebp),%eax
f010113b:	8d 40 04             	lea    0x4(%eax),%eax
f010113e:	89 45 14             	mov    %eax,0x14(%ebp)
f0101141:	eb a5                	jmp    f01010e8 <.L31+0x1f>
			num = getint(&ap, lflag);
f0101143:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101146:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0101149:	b8 0a 00 00 00       	mov    $0xa,%eax
f010114e:	eb 71                	jmp    f01011c1 <.L34+0x22>

f0101150 <.L37>:
f0101150:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0101153:	83 f9 01             	cmp    $0x1,%ecx
f0101156:	7e 15                	jle    f010116d <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
f0101158:	8b 45 14             	mov    0x14(%ebp),%eax
f010115b:	8b 10                	mov    (%eax),%edx
f010115d:	8b 48 04             	mov    0x4(%eax),%ecx
f0101160:	8d 40 08             	lea    0x8(%eax),%eax
f0101163:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101166:	b8 0a 00 00 00       	mov    $0xa,%eax
f010116b:	eb 54                	jmp    f01011c1 <.L34+0x22>
	else if (lflag)
f010116d:	85 c9                	test   %ecx,%ecx
f010116f:	75 17                	jne    f0101188 <.L37+0x38>
		return va_arg(*ap, unsigned int);
f0101171:	8b 45 14             	mov    0x14(%ebp),%eax
f0101174:	8b 10                	mov    (%eax),%edx
f0101176:	b9 00 00 00 00       	mov    $0x0,%ecx
f010117b:	8d 40 04             	lea    0x4(%eax),%eax
f010117e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101181:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101186:	eb 39                	jmp    f01011c1 <.L34+0x22>
		return va_arg(*ap, unsigned long);
f0101188:	8b 45 14             	mov    0x14(%ebp),%eax
f010118b:	8b 10                	mov    (%eax),%edx
f010118d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101192:	8d 40 04             	lea    0x4(%eax),%eax
f0101195:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101198:	b8 0a 00 00 00       	mov    $0xa,%eax
f010119d:	eb 22                	jmp    f01011c1 <.L34+0x22>

f010119f <.L34>:
f010119f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01011a2:	83 f9 01             	cmp    $0x1,%ecx
f01011a5:	7e 5d                	jle    f0101204 <.L34+0x65>
		return va_arg(*ap, long long);
f01011a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01011aa:	8b 50 04             	mov    0x4(%eax),%edx
f01011ad:	8b 00                	mov    (%eax),%eax
f01011af:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01011b2:	8d 49 08             	lea    0x8(%ecx),%ecx
f01011b5:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
f01011b8:	89 d1                	mov    %edx,%ecx
f01011ba:	89 c2                	mov    %eax,%edx
			base = 8;
f01011bc:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
f01011c1:	83 ec 0c             	sub    $0xc,%esp
f01011c4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01011c8:	57                   	push   %edi
f01011c9:	ff 75 e0             	pushl  -0x20(%ebp)
f01011cc:	50                   	push   %eax
f01011cd:	51                   	push   %ecx
f01011ce:	52                   	push   %edx
f01011cf:	89 f2                	mov    %esi,%edx
f01011d1:	8b 45 08             	mov    0x8(%ebp),%eax
f01011d4:	e8 80 fb ff ff       	call   f0100d59 <printnum>
			break;
f01011d9:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01011dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01011df:	83 c7 01             	add    $0x1,%edi
f01011e2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01011e6:	83 f8 25             	cmp    $0x25,%eax
f01011e9:	0f 84 8d fc ff ff    	je     f0100e7c <vprintfmt+0x1f>
			if (ch == '\0')
f01011ef:	85 c0                	test   %eax,%eax
f01011f1:	0f 84 f0 00 00 00    	je     f01012e7 <.L22+0x21>
			putch(ch, putdat);
f01011f7:	83 ec 08             	sub    $0x8,%esp
f01011fa:	56                   	push   %esi
f01011fb:	50                   	push   %eax
f01011fc:	ff 55 08             	call   *0x8(%ebp)
f01011ff:	83 c4 10             	add    $0x10,%esp
f0101202:	eb db                	jmp    f01011df <.L34+0x40>
	else if (lflag)
f0101204:	85 c9                	test   %ecx,%ecx
f0101206:	75 13                	jne    f010121b <.L34+0x7c>
		return va_arg(*ap, int);
f0101208:	8b 45 14             	mov    0x14(%ebp),%eax
f010120b:	8b 10                	mov    (%eax),%edx
f010120d:	89 d0                	mov    %edx,%eax
f010120f:	99                   	cltd   
f0101210:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0101213:	8d 49 04             	lea    0x4(%ecx),%ecx
f0101216:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0101219:	eb 9d                	jmp    f01011b8 <.L34+0x19>
		return va_arg(*ap, long);
f010121b:	8b 45 14             	mov    0x14(%ebp),%eax
f010121e:	8b 10                	mov    (%eax),%edx
f0101220:	89 d0                	mov    %edx,%eax
f0101222:	99                   	cltd   
f0101223:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0101226:	8d 49 04             	lea    0x4(%ecx),%ecx
f0101229:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010122c:	eb 8a                	jmp    f01011b8 <.L34+0x19>

f010122e <.L35>:
			putch('0', putdat);
f010122e:	83 ec 08             	sub    $0x8,%esp
f0101231:	56                   	push   %esi
f0101232:	6a 30                	push   $0x30
f0101234:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101237:	83 c4 08             	add    $0x8,%esp
f010123a:	56                   	push   %esi
f010123b:	6a 78                	push   $0x78
f010123d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0101240:	8b 45 14             	mov    0x14(%ebp),%eax
f0101243:	8b 10                	mov    (%eax),%edx
f0101245:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010124a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010124d:	8d 40 04             	lea    0x4(%eax),%eax
f0101250:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101253:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0101258:	e9 64 ff ff ff       	jmp    f01011c1 <.L34+0x22>

f010125d <.L38>:
f010125d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0101260:	83 f9 01             	cmp    $0x1,%ecx
f0101263:	7e 18                	jle    f010127d <.L38+0x20>
		return va_arg(*ap, unsigned long long);
f0101265:	8b 45 14             	mov    0x14(%ebp),%eax
f0101268:	8b 10                	mov    (%eax),%edx
f010126a:	8b 48 04             	mov    0x4(%eax),%ecx
f010126d:	8d 40 08             	lea    0x8(%eax),%eax
f0101270:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101273:	b8 10 00 00 00       	mov    $0x10,%eax
f0101278:	e9 44 ff ff ff       	jmp    f01011c1 <.L34+0x22>
	else if (lflag)
f010127d:	85 c9                	test   %ecx,%ecx
f010127f:	75 1a                	jne    f010129b <.L38+0x3e>
		return va_arg(*ap, unsigned int);
f0101281:	8b 45 14             	mov    0x14(%ebp),%eax
f0101284:	8b 10                	mov    (%eax),%edx
f0101286:	b9 00 00 00 00       	mov    $0x0,%ecx
f010128b:	8d 40 04             	lea    0x4(%eax),%eax
f010128e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101291:	b8 10 00 00 00       	mov    $0x10,%eax
f0101296:	e9 26 ff ff ff       	jmp    f01011c1 <.L34+0x22>
		return va_arg(*ap, unsigned long);
f010129b:	8b 45 14             	mov    0x14(%ebp),%eax
f010129e:	8b 10                	mov    (%eax),%edx
f01012a0:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012a5:	8d 40 04             	lea    0x4(%eax),%eax
f01012a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01012ab:	b8 10 00 00 00       	mov    $0x10,%eax
f01012b0:	e9 0c ff ff ff       	jmp    f01011c1 <.L34+0x22>

f01012b5 <.L25>:
			putch(ch, putdat);
f01012b5:	83 ec 08             	sub    $0x8,%esp
f01012b8:	56                   	push   %esi
f01012b9:	6a 25                	push   $0x25
f01012bb:	ff 55 08             	call   *0x8(%ebp)
			break;
f01012be:	83 c4 10             	add    $0x10,%esp
f01012c1:	e9 16 ff ff ff       	jmp    f01011dc <.L34+0x3d>

f01012c6 <.L22>:
			putch('%', putdat);
f01012c6:	83 ec 08             	sub    $0x8,%esp
f01012c9:	56                   	push   %esi
f01012ca:	6a 25                	push   $0x25
f01012cc:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01012cf:	83 c4 10             	add    $0x10,%esp
f01012d2:	89 f8                	mov    %edi,%eax
f01012d4:	eb 03                	jmp    f01012d9 <.L22+0x13>
f01012d6:	83 e8 01             	sub    $0x1,%eax
f01012d9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01012dd:	75 f7                	jne    f01012d6 <.L22+0x10>
f01012df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01012e2:	e9 f5 fe ff ff       	jmp    f01011dc <.L34+0x3d>
}
f01012e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012ea:	5b                   	pop    %ebx
f01012eb:	5e                   	pop    %esi
f01012ec:	5f                   	pop    %edi
f01012ed:	5d                   	pop    %ebp
f01012ee:	c3                   	ret    

f01012ef <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01012ef:	55                   	push   %ebp
f01012f0:	89 e5                	mov    %esp,%ebp
f01012f2:	53                   	push   %ebx
f01012f3:	83 ec 14             	sub    $0x14,%esp
f01012f6:	e8 c1 ee ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01012fb:	81 c3 0d 00 01 00    	add    $0x1000d,%ebx
f0101301:	8b 45 08             	mov    0x8(%ebp),%eax
f0101304:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101307:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010130a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010130e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101311:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101318:	85 c0                	test   %eax,%eax
f010131a:	74 2b                	je     f0101347 <vsnprintf+0x58>
f010131c:	85 d2                	test   %edx,%edx
f010131e:	7e 27                	jle    f0101347 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101320:	ff 75 14             	pushl  0x14(%ebp)
f0101323:	ff 75 10             	pushl  0x10(%ebp)
f0101326:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101329:	50                   	push   %eax
f010132a:	8d 83 1b fb fe ff    	lea    -0x104e5(%ebx),%eax
f0101330:	50                   	push   %eax
f0101331:	e8 27 fb ff ff       	call   f0100e5d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101336:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101339:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010133c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010133f:	83 c4 10             	add    $0x10,%esp
}
f0101342:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101345:	c9                   	leave  
f0101346:	c3                   	ret    
		return -E_INVAL;
f0101347:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010134c:	eb f4                	jmp    f0101342 <vsnprintf+0x53>

f010134e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010134e:	55                   	push   %ebp
f010134f:	89 e5                	mov    %esp,%ebp
f0101351:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101354:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101357:	50                   	push   %eax
f0101358:	ff 75 10             	pushl  0x10(%ebp)
f010135b:	ff 75 0c             	pushl  0xc(%ebp)
f010135e:	ff 75 08             	pushl  0x8(%ebp)
f0101361:	e8 89 ff ff ff       	call   f01012ef <vsnprintf>
	va_end(ap);

	return rc;
}
f0101366:	c9                   	leave  
f0101367:	c3                   	ret    

f0101368 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101368:	55                   	push   %ebp
f0101369:	89 e5                	mov    %esp,%ebp
f010136b:	57                   	push   %edi
f010136c:	56                   	push   %esi
f010136d:	53                   	push   %ebx
f010136e:	83 ec 1c             	sub    $0x1c,%esp
f0101371:	e8 46 ee ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0101376:	81 c3 92 ff 00 00    	add    $0xff92,%ebx
f010137c:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010137f:	85 c0                	test   %eax,%eax
f0101381:	74 13                	je     f0101396 <readline+0x2e>
		cprintf("%s", prompt);
f0101383:	83 ec 08             	sub    $0x8,%esp
f0101386:	50                   	push   %eax
f0101387:	8d 83 02 0c ff ff    	lea    -0xf3fe(%ebx),%eax
f010138d:	50                   	push   %eax
f010138e:	e8 b6 f6 ff ff       	call   f0100a49 <cprintf>
f0101393:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101396:	83 ec 0c             	sub    $0xc,%esp
f0101399:	6a 00                	push   $0x0
f010139b:	e8 b4 f3 ff ff       	call   f0100754 <iscons>
f01013a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01013a3:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01013a6:	bf 00 00 00 00       	mov    $0x0,%edi
f01013ab:	eb 46                	jmp    f01013f3 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01013ad:	83 ec 08             	sub    $0x8,%esp
f01013b0:	50                   	push   %eax
f01013b1:	8d 83 c8 0d ff ff    	lea    -0xf238(%ebx),%eax
f01013b7:	50                   	push   %eax
f01013b8:	e8 8c f6 ff ff       	call   f0100a49 <cprintf>
			return NULL;
f01013bd:	83 c4 10             	add    $0x10,%esp
f01013c0:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01013c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013c8:	5b                   	pop    %ebx
f01013c9:	5e                   	pop    %esi
f01013ca:	5f                   	pop    %edi
f01013cb:	5d                   	pop    %ebp
f01013cc:	c3                   	ret    
			if (echoing)
f01013cd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01013d1:	75 05                	jne    f01013d8 <readline+0x70>
			i--;
f01013d3:	83 ef 01             	sub    $0x1,%edi
f01013d6:	eb 1b                	jmp    f01013f3 <readline+0x8b>
				cputchar('\b');
f01013d8:	83 ec 0c             	sub    $0xc,%esp
f01013db:	6a 08                	push   $0x8
f01013dd:	e8 51 f3 ff ff       	call   f0100733 <cputchar>
f01013e2:	83 c4 10             	add    $0x10,%esp
f01013e5:	eb ec                	jmp    f01013d3 <readline+0x6b>
			buf[i++] = c;
f01013e7:	89 f0                	mov    %esi,%eax
f01013e9:	88 84 3b 98 1f 00 00 	mov    %al,0x1f98(%ebx,%edi,1)
f01013f0:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01013f3:	e8 4b f3 ff ff       	call   f0100743 <getchar>
f01013f8:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01013fa:	85 c0                	test   %eax,%eax
f01013fc:	78 af                	js     f01013ad <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01013fe:	83 f8 08             	cmp    $0x8,%eax
f0101401:	0f 94 c2             	sete   %dl
f0101404:	83 f8 7f             	cmp    $0x7f,%eax
f0101407:	0f 94 c0             	sete   %al
f010140a:	08 c2                	or     %al,%dl
f010140c:	74 04                	je     f0101412 <readline+0xaa>
f010140e:	85 ff                	test   %edi,%edi
f0101410:	7f bb                	jg     f01013cd <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101412:	83 fe 1f             	cmp    $0x1f,%esi
f0101415:	7e 1c                	jle    f0101433 <readline+0xcb>
f0101417:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f010141d:	7f 14                	jg     f0101433 <readline+0xcb>
			if (echoing)
f010141f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101423:	74 c2                	je     f01013e7 <readline+0x7f>
				cputchar(c);
f0101425:	83 ec 0c             	sub    $0xc,%esp
f0101428:	56                   	push   %esi
f0101429:	e8 05 f3 ff ff       	call   f0100733 <cputchar>
f010142e:	83 c4 10             	add    $0x10,%esp
f0101431:	eb b4                	jmp    f01013e7 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f0101433:	83 fe 0a             	cmp    $0xa,%esi
f0101436:	74 05                	je     f010143d <readline+0xd5>
f0101438:	83 fe 0d             	cmp    $0xd,%esi
f010143b:	75 b6                	jne    f01013f3 <readline+0x8b>
			if (echoing)
f010143d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101441:	75 13                	jne    f0101456 <readline+0xee>
			buf[i] = 0;
f0101443:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f010144a:	00 
			return buf;
f010144b:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f0101451:	e9 6f ff ff ff       	jmp    f01013c5 <readline+0x5d>
				cputchar('\n');
f0101456:	83 ec 0c             	sub    $0xc,%esp
f0101459:	6a 0a                	push   $0xa
f010145b:	e8 d3 f2 ff ff       	call   f0100733 <cputchar>
f0101460:	83 c4 10             	add    $0x10,%esp
f0101463:	eb de                	jmp    f0101443 <readline+0xdb>

f0101465 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101465:	55                   	push   %ebp
f0101466:	89 e5                	mov    %esp,%ebp
f0101468:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010146b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101470:	eb 03                	jmp    f0101475 <strlen+0x10>
		n++;
f0101472:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0101475:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101479:	75 f7                	jne    f0101472 <strlen+0xd>
	return n;
}
f010147b:	5d                   	pop    %ebp
f010147c:	c3                   	ret    

f010147d <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010147d:	55                   	push   %ebp
f010147e:	89 e5                	mov    %esp,%ebp
f0101480:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101483:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101486:	b8 00 00 00 00       	mov    $0x0,%eax
f010148b:	eb 03                	jmp    f0101490 <strnlen+0x13>
		n++;
f010148d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101490:	39 d0                	cmp    %edx,%eax
f0101492:	74 06                	je     f010149a <strnlen+0x1d>
f0101494:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101498:	75 f3                	jne    f010148d <strnlen+0x10>
	return n;
}
f010149a:	5d                   	pop    %ebp
f010149b:	c3                   	ret    

f010149c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010149c:	55                   	push   %ebp
f010149d:	89 e5                	mov    %esp,%ebp
f010149f:	53                   	push   %ebx
f01014a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01014a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01014a6:	89 c2                	mov    %eax,%edx
f01014a8:	83 c1 01             	add    $0x1,%ecx
f01014ab:	83 c2 01             	add    $0x1,%edx
f01014ae:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01014b2:	88 5a ff             	mov    %bl,-0x1(%edx)
f01014b5:	84 db                	test   %bl,%bl
f01014b7:	75 ef                	jne    f01014a8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01014b9:	5b                   	pop    %ebx
f01014ba:	5d                   	pop    %ebp
f01014bb:	c3                   	ret    

f01014bc <strcat>:

char *
strcat(char *dst, const char *src)
{
f01014bc:	55                   	push   %ebp
f01014bd:	89 e5                	mov    %esp,%ebp
f01014bf:	53                   	push   %ebx
f01014c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01014c3:	53                   	push   %ebx
f01014c4:	e8 9c ff ff ff       	call   f0101465 <strlen>
f01014c9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01014cc:	ff 75 0c             	pushl  0xc(%ebp)
f01014cf:	01 d8                	add    %ebx,%eax
f01014d1:	50                   	push   %eax
f01014d2:	e8 c5 ff ff ff       	call   f010149c <strcpy>
	return dst;
}
f01014d7:	89 d8                	mov    %ebx,%eax
f01014d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014dc:	c9                   	leave  
f01014dd:	c3                   	ret    

f01014de <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01014de:	55                   	push   %ebp
f01014df:	89 e5                	mov    %esp,%ebp
f01014e1:	56                   	push   %esi
f01014e2:	53                   	push   %ebx
f01014e3:	8b 75 08             	mov    0x8(%ebp),%esi
f01014e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01014e9:	89 f3                	mov    %esi,%ebx
f01014eb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01014ee:	89 f2                	mov    %esi,%edx
f01014f0:	eb 0f                	jmp    f0101501 <strncpy+0x23>
		*dst++ = *src;
f01014f2:	83 c2 01             	add    $0x1,%edx
f01014f5:	0f b6 01             	movzbl (%ecx),%eax
f01014f8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01014fb:	80 39 01             	cmpb   $0x1,(%ecx)
f01014fe:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0101501:	39 da                	cmp    %ebx,%edx
f0101503:	75 ed                	jne    f01014f2 <strncpy+0x14>
	}
	return ret;
}
f0101505:	89 f0                	mov    %esi,%eax
f0101507:	5b                   	pop    %ebx
f0101508:	5e                   	pop    %esi
f0101509:	5d                   	pop    %ebp
f010150a:	c3                   	ret    

f010150b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010150b:	55                   	push   %ebp
f010150c:	89 e5                	mov    %esp,%ebp
f010150e:	56                   	push   %esi
f010150f:	53                   	push   %ebx
f0101510:	8b 75 08             	mov    0x8(%ebp),%esi
f0101513:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101516:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0101519:	89 f0                	mov    %esi,%eax
f010151b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010151f:	85 c9                	test   %ecx,%ecx
f0101521:	75 0b                	jne    f010152e <strlcpy+0x23>
f0101523:	eb 17                	jmp    f010153c <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101525:	83 c2 01             	add    $0x1,%edx
f0101528:	83 c0 01             	add    $0x1,%eax
f010152b:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f010152e:	39 d8                	cmp    %ebx,%eax
f0101530:	74 07                	je     f0101539 <strlcpy+0x2e>
f0101532:	0f b6 0a             	movzbl (%edx),%ecx
f0101535:	84 c9                	test   %cl,%cl
f0101537:	75 ec                	jne    f0101525 <strlcpy+0x1a>
		*dst = '\0';
f0101539:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010153c:	29 f0                	sub    %esi,%eax
}
f010153e:	5b                   	pop    %ebx
f010153f:	5e                   	pop    %esi
f0101540:	5d                   	pop    %ebp
f0101541:	c3                   	ret    

f0101542 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101542:	55                   	push   %ebp
f0101543:	89 e5                	mov    %esp,%ebp
f0101545:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101548:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010154b:	eb 06                	jmp    f0101553 <strcmp+0x11>
		p++, q++;
f010154d:	83 c1 01             	add    $0x1,%ecx
f0101550:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0101553:	0f b6 01             	movzbl (%ecx),%eax
f0101556:	84 c0                	test   %al,%al
f0101558:	74 04                	je     f010155e <strcmp+0x1c>
f010155a:	3a 02                	cmp    (%edx),%al
f010155c:	74 ef                	je     f010154d <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010155e:	0f b6 c0             	movzbl %al,%eax
f0101561:	0f b6 12             	movzbl (%edx),%edx
f0101564:	29 d0                	sub    %edx,%eax
}
f0101566:	5d                   	pop    %ebp
f0101567:	c3                   	ret    

f0101568 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101568:	55                   	push   %ebp
f0101569:	89 e5                	mov    %esp,%ebp
f010156b:	53                   	push   %ebx
f010156c:	8b 45 08             	mov    0x8(%ebp),%eax
f010156f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101572:	89 c3                	mov    %eax,%ebx
f0101574:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101577:	eb 06                	jmp    f010157f <strncmp+0x17>
		n--, p++, q++;
f0101579:	83 c0 01             	add    $0x1,%eax
f010157c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f010157f:	39 d8                	cmp    %ebx,%eax
f0101581:	74 16                	je     f0101599 <strncmp+0x31>
f0101583:	0f b6 08             	movzbl (%eax),%ecx
f0101586:	84 c9                	test   %cl,%cl
f0101588:	74 04                	je     f010158e <strncmp+0x26>
f010158a:	3a 0a                	cmp    (%edx),%cl
f010158c:	74 eb                	je     f0101579 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010158e:	0f b6 00             	movzbl (%eax),%eax
f0101591:	0f b6 12             	movzbl (%edx),%edx
f0101594:	29 d0                	sub    %edx,%eax
}
f0101596:	5b                   	pop    %ebx
f0101597:	5d                   	pop    %ebp
f0101598:	c3                   	ret    
		return 0;
f0101599:	b8 00 00 00 00       	mov    $0x0,%eax
f010159e:	eb f6                	jmp    f0101596 <strncmp+0x2e>

f01015a0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01015a0:	55                   	push   %ebp
f01015a1:	89 e5                	mov    %esp,%ebp
f01015a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01015a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01015aa:	0f b6 10             	movzbl (%eax),%edx
f01015ad:	84 d2                	test   %dl,%dl
f01015af:	74 09                	je     f01015ba <strchr+0x1a>
		if (*s == c)
f01015b1:	38 ca                	cmp    %cl,%dl
f01015b3:	74 0a                	je     f01015bf <strchr+0x1f>
	for (; *s; s++)
f01015b5:	83 c0 01             	add    $0x1,%eax
f01015b8:	eb f0                	jmp    f01015aa <strchr+0xa>
			return (char *) s;
	return 0;
f01015ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01015bf:	5d                   	pop    %ebp
f01015c0:	c3                   	ret    

f01015c1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01015c1:	55                   	push   %ebp
f01015c2:	89 e5                	mov    %esp,%ebp
f01015c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01015c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01015cb:	eb 03                	jmp    f01015d0 <strfind+0xf>
f01015cd:	83 c0 01             	add    $0x1,%eax
f01015d0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01015d3:	38 ca                	cmp    %cl,%dl
f01015d5:	74 04                	je     f01015db <strfind+0x1a>
f01015d7:	84 d2                	test   %dl,%dl
f01015d9:	75 f2                	jne    f01015cd <strfind+0xc>
			break;
	return (char *) s;
}
f01015db:	5d                   	pop    %ebp
f01015dc:	c3                   	ret    

f01015dd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01015dd:	55                   	push   %ebp
f01015de:	89 e5                	mov    %esp,%ebp
f01015e0:	57                   	push   %edi
f01015e1:	56                   	push   %esi
f01015e2:	53                   	push   %ebx
f01015e3:	8b 7d 08             	mov    0x8(%ebp),%edi
f01015e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01015e9:	85 c9                	test   %ecx,%ecx
f01015eb:	74 13                	je     f0101600 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01015ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01015f3:	75 05                	jne    f01015fa <memset+0x1d>
f01015f5:	f6 c1 03             	test   $0x3,%cl
f01015f8:	74 0d                	je     f0101607 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01015fa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015fd:	fc                   	cld    
f01015fe:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101600:	89 f8                	mov    %edi,%eax
f0101602:	5b                   	pop    %ebx
f0101603:	5e                   	pop    %esi
f0101604:	5f                   	pop    %edi
f0101605:	5d                   	pop    %ebp
f0101606:	c3                   	ret    
		c &= 0xFF;
f0101607:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010160b:	89 d3                	mov    %edx,%ebx
f010160d:	c1 e3 08             	shl    $0x8,%ebx
f0101610:	89 d0                	mov    %edx,%eax
f0101612:	c1 e0 18             	shl    $0x18,%eax
f0101615:	89 d6                	mov    %edx,%esi
f0101617:	c1 e6 10             	shl    $0x10,%esi
f010161a:	09 f0                	or     %esi,%eax
f010161c:	09 c2                	or     %eax,%edx
f010161e:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0101620:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0101623:	89 d0                	mov    %edx,%eax
f0101625:	fc                   	cld    
f0101626:	f3 ab                	rep stos %eax,%es:(%edi)
f0101628:	eb d6                	jmp    f0101600 <memset+0x23>

f010162a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010162a:	55                   	push   %ebp
f010162b:	89 e5                	mov    %esp,%ebp
f010162d:	57                   	push   %edi
f010162e:	56                   	push   %esi
f010162f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101632:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101635:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101638:	39 c6                	cmp    %eax,%esi
f010163a:	73 35                	jae    f0101671 <memmove+0x47>
f010163c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010163f:	39 c2                	cmp    %eax,%edx
f0101641:	76 2e                	jbe    f0101671 <memmove+0x47>
		s += n;
		d += n;
f0101643:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101646:	89 d6                	mov    %edx,%esi
f0101648:	09 fe                	or     %edi,%esi
f010164a:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101650:	74 0c                	je     f010165e <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101652:	83 ef 01             	sub    $0x1,%edi
f0101655:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101658:	fd                   	std    
f0101659:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010165b:	fc                   	cld    
f010165c:	eb 21                	jmp    f010167f <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010165e:	f6 c1 03             	test   $0x3,%cl
f0101661:	75 ef                	jne    f0101652 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101663:	83 ef 04             	sub    $0x4,%edi
f0101666:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101669:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010166c:	fd                   	std    
f010166d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010166f:	eb ea                	jmp    f010165b <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101671:	89 f2                	mov    %esi,%edx
f0101673:	09 c2                	or     %eax,%edx
f0101675:	f6 c2 03             	test   $0x3,%dl
f0101678:	74 09                	je     f0101683 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010167a:	89 c7                	mov    %eax,%edi
f010167c:	fc                   	cld    
f010167d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010167f:	5e                   	pop    %esi
f0101680:	5f                   	pop    %edi
f0101681:	5d                   	pop    %ebp
f0101682:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101683:	f6 c1 03             	test   $0x3,%cl
f0101686:	75 f2                	jne    f010167a <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101688:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010168b:	89 c7                	mov    %eax,%edi
f010168d:	fc                   	cld    
f010168e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101690:	eb ed                	jmp    f010167f <memmove+0x55>

f0101692 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101692:	55                   	push   %ebp
f0101693:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101695:	ff 75 10             	pushl  0x10(%ebp)
f0101698:	ff 75 0c             	pushl  0xc(%ebp)
f010169b:	ff 75 08             	pushl  0x8(%ebp)
f010169e:	e8 87 ff ff ff       	call   f010162a <memmove>
}
f01016a3:	c9                   	leave  
f01016a4:	c3                   	ret    

f01016a5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01016a5:	55                   	push   %ebp
f01016a6:	89 e5                	mov    %esp,%ebp
f01016a8:	56                   	push   %esi
f01016a9:	53                   	push   %ebx
f01016aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01016ad:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016b0:	89 c6                	mov    %eax,%esi
f01016b2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01016b5:	39 f0                	cmp    %esi,%eax
f01016b7:	74 1c                	je     f01016d5 <memcmp+0x30>
		if (*s1 != *s2)
f01016b9:	0f b6 08             	movzbl (%eax),%ecx
f01016bc:	0f b6 1a             	movzbl (%edx),%ebx
f01016bf:	38 d9                	cmp    %bl,%cl
f01016c1:	75 08                	jne    f01016cb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01016c3:	83 c0 01             	add    $0x1,%eax
f01016c6:	83 c2 01             	add    $0x1,%edx
f01016c9:	eb ea                	jmp    f01016b5 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01016cb:	0f b6 c1             	movzbl %cl,%eax
f01016ce:	0f b6 db             	movzbl %bl,%ebx
f01016d1:	29 d8                	sub    %ebx,%eax
f01016d3:	eb 05                	jmp    f01016da <memcmp+0x35>
	}

	return 0;
f01016d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01016da:	5b                   	pop    %ebx
f01016db:	5e                   	pop    %esi
f01016dc:	5d                   	pop    %ebp
f01016dd:	c3                   	ret    

f01016de <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01016de:	55                   	push   %ebp
f01016df:	89 e5                	mov    %esp,%ebp
f01016e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01016e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01016e7:	89 c2                	mov    %eax,%edx
f01016e9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01016ec:	39 d0                	cmp    %edx,%eax
f01016ee:	73 09                	jae    f01016f9 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f01016f0:	38 08                	cmp    %cl,(%eax)
f01016f2:	74 05                	je     f01016f9 <memfind+0x1b>
	for (; s < ends; s++)
f01016f4:	83 c0 01             	add    $0x1,%eax
f01016f7:	eb f3                	jmp    f01016ec <memfind+0xe>
			break;
	return (void *) s;
}
f01016f9:	5d                   	pop    %ebp
f01016fa:	c3                   	ret    

f01016fb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01016fb:	55                   	push   %ebp
f01016fc:	89 e5                	mov    %esp,%ebp
f01016fe:	57                   	push   %edi
f01016ff:	56                   	push   %esi
f0101700:	53                   	push   %ebx
f0101701:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101704:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101707:	eb 03                	jmp    f010170c <strtol+0x11>
		s++;
f0101709:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f010170c:	0f b6 01             	movzbl (%ecx),%eax
f010170f:	3c 20                	cmp    $0x20,%al
f0101711:	74 f6                	je     f0101709 <strtol+0xe>
f0101713:	3c 09                	cmp    $0x9,%al
f0101715:	74 f2                	je     f0101709 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0101717:	3c 2b                	cmp    $0x2b,%al
f0101719:	74 2e                	je     f0101749 <strtol+0x4e>
	int neg = 0;
f010171b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101720:	3c 2d                	cmp    $0x2d,%al
f0101722:	74 2f                	je     f0101753 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101724:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010172a:	75 05                	jne    f0101731 <strtol+0x36>
f010172c:	80 39 30             	cmpb   $0x30,(%ecx)
f010172f:	74 2c                	je     f010175d <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101731:	85 db                	test   %ebx,%ebx
f0101733:	75 0a                	jne    f010173f <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101735:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f010173a:	80 39 30             	cmpb   $0x30,(%ecx)
f010173d:	74 28                	je     f0101767 <strtol+0x6c>
		base = 10;
f010173f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101744:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101747:	eb 50                	jmp    f0101799 <strtol+0x9e>
		s++;
f0101749:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f010174c:	bf 00 00 00 00       	mov    $0x0,%edi
f0101751:	eb d1                	jmp    f0101724 <strtol+0x29>
		s++, neg = 1;
f0101753:	83 c1 01             	add    $0x1,%ecx
f0101756:	bf 01 00 00 00       	mov    $0x1,%edi
f010175b:	eb c7                	jmp    f0101724 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010175d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101761:	74 0e                	je     f0101771 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0101763:	85 db                	test   %ebx,%ebx
f0101765:	75 d8                	jne    f010173f <strtol+0x44>
		s++, base = 8;
f0101767:	83 c1 01             	add    $0x1,%ecx
f010176a:	bb 08 00 00 00       	mov    $0x8,%ebx
f010176f:	eb ce                	jmp    f010173f <strtol+0x44>
		s += 2, base = 16;
f0101771:	83 c1 02             	add    $0x2,%ecx
f0101774:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101779:	eb c4                	jmp    f010173f <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f010177b:	8d 72 9f             	lea    -0x61(%edx),%esi
f010177e:	89 f3                	mov    %esi,%ebx
f0101780:	80 fb 19             	cmp    $0x19,%bl
f0101783:	77 29                	ja     f01017ae <strtol+0xb3>
			dig = *s - 'a' + 10;
f0101785:	0f be d2             	movsbl %dl,%edx
f0101788:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010178b:	3b 55 10             	cmp    0x10(%ebp),%edx
f010178e:	7d 30                	jge    f01017c0 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0101790:	83 c1 01             	add    $0x1,%ecx
f0101793:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101797:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101799:	0f b6 11             	movzbl (%ecx),%edx
f010179c:	8d 72 d0             	lea    -0x30(%edx),%esi
f010179f:	89 f3                	mov    %esi,%ebx
f01017a1:	80 fb 09             	cmp    $0x9,%bl
f01017a4:	77 d5                	ja     f010177b <strtol+0x80>
			dig = *s - '0';
f01017a6:	0f be d2             	movsbl %dl,%edx
f01017a9:	83 ea 30             	sub    $0x30,%edx
f01017ac:	eb dd                	jmp    f010178b <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f01017ae:	8d 72 bf             	lea    -0x41(%edx),%esi
f01017b1:	89 f3                	mov    %esi,%ebx
f01017b3:	80 fb 19             	cmp    $0x19,%bl
f01017b6:	77 08                	ja     f01017c0 <strtol+0xc5>
			dig = *s - 'A' + 10;
f01017b8:	0f be d2             	movsbl %dl,%edx
f01017bb:	83 ea 37             	sub    $0x37,%edx
f01017be:	eb cb                	jmp    f010178b <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f01017c0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01017c4:	74 05                	je     f01017cb <strtol+0xd0>
		*endptr = (char *) s;
f01017c6:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017c9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01017cb:	89 c2                	mov    %eax,%edx
f01017cd:	f7 da                	neg    %edx
f01017cf:	85 ff                	test   %edi,%edi
f01017d1:	0f 45 c2             	cmovne %edx,%eax
}
f01017d4:	5b                   	pop    %ebx
f01017d5:	5e                   	pop    %esi
f01017d6:	5f                   	pop    %edi
f01017d7:	5d                   	pop    %ebp
f01017d8:	c3                   	ret    
f01017d9:	66 90                	xchg   %ax,%ax
f01017db:	66 90                	xchg   %ax,%ax
f01017dd:	66 90                	xchg   %ax,%ax
f01017df:	90                   	nop

f01017e0 <__udivdi3>:
f01017e0:	55                   	push   %ebp
f01017e1:	57                   	push   %edi
f01017e2:	56                   	push   %esi
f01017e3:	53                   	push   %ebx
f01017e4:	83 ec 1c             	sub    $0x1c,%esp
f01017e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01017eb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01017ef:	8b 74 24 34          	mov    0x34(%esp),%esi
f01017f3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01017f7:	85 d2                	test   %edx,%edx
f01017f9:	75 35                	jne    f0101830 <__udivdi3+0x50>
f01017fb:	39 f3                	cmp    %esi,%ebx
f01017fd:	0f 87 bd 00 00 00    	ja     f01018c0 <__udivdi3+0xe0>
f0101803:	85 db                	test   %ebx,%ebx
f0101805:	89 d9                	mov    %ebx,%ecx
f0101807:	75 0b                	jne    f0101814 <__udivdi3+0x34>
f0101809:	b8 01 00 00 00       	mov    $0x1,%eax
f010180e:	31 d2                	xor    %edx,%edx
f0101810:	f7 f3                	div    %ebx
f0101812:	89 c1                	mov    %eax,%ecx
f0101814:	31 d2                	xor    %edx,%edx
f0101816:	89 f0                	mov    %esi,%eax
f0101818:	f7 f1                	div    %ecx
f010181a:	89 c6                	mov    %eax,%esi
f010181c:	89 e8                	mov    %ebp,%eax
f010181e:	89 f7                	mov    %esi,%edi
f0101820:	f7 f1                	div    %ecx
f0101822:	89 fa                	mov    %edi,%edx
f0101824:	83 c4 1c             	add    $0x1c,%esp
f0101827:	5b                   	pop    %ebx
f0101828:	5e                   	pop    %esi
f0101829:	5f                   	pop    %edi
f010182a:	5d                   	pop    %ebp
f010182b:	c3                   	ret    
f010182c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101830:	39 f2                	cmp    %esi,%edx
f0101832:	77 7c                	ja     f01018b0 <__udivdi3+0xd0>
f0101834:	0f bd fa             	bsr    %edx,%edi
f0101837:	83 f7 1f             	xor    $0x1f,%edi
f010183a:	0f 84 98 00 00 00    	je     f01018d8 <__udivdi3+0xf8>
f0101840:	89 f9                	mov    %edi,%ecx
f0101842:	b8 20 00 00 00       	mov    $0x20,%eax
f0101847:	29 f8                	sub    %edi,%eax
f0101849:	d3 e2                	shl    %cl,%edx
f010184b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010184f:	89 c1                	mov    %eax,%ecx
f0101851:	89 da                	mov    %ebx,%edx
f0101853:	d3 ea                	shr    %cl,%edx
f0101855:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101859:	09 d1                	or     %edx,%ecx
f010185b:	89 f2                	mov    %esi,%edx
f010185d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101861:	89 f9                	mov    %edi,%ecx
f0101863:	d3 e3                	shl    %cl,%ebx
f0101865:	89 c1                	mov    %eax,%ecx
f0101867:	d3 ea                	shr    %cl,%edx
f0101869:	89 f9                	mov    %edi,%ecx
f010186b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010186f:	d3 e6                	shl    %cl,%esi
f0101871:	89 eb                	mov    %ebp,%ebx
f0101873:	89 c1                	mov    %eax,%ecx
f0101875:	d3 eb                	shr    %cl,%ebx
f0101877:	09 de                	or     %ebx,%esi
f0101879:	89 f0                	mov    %esi,%eax
f010187b:	f7 74 24 08          	divl   0x8(%esp)
f010187f:	89 d6                	mov    %edx,%esi
f0101881:	89 c3                	mov    %eax,%ebx
f0101883:	f7 64 24 0c          	mull   0xc(%esp)
f0101887:	39 d6                	cmp    %edx,%esi
f0101889:	72 0c                	jb     f0101897 <__udivdi3+0xb7>
f010188b:	89 f9                	mov    %edi,%ecx
f010188d:	d3 e5                	shl    %cl,%ebp
f010188f:	39 c5                	cmp    %eax,%ebp
f0101891:	73 5d                	jae    f01018f0 <__udivdi3+0x110>
f0101893:	39 d6                	cmp    %edx,%esi
f0101895:	75 59                	jne    f01018f0 <__udivdi3+0x110>
f0101897:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010189a:	31 ff                	xor    %edi,%edi
f010189c:	89 fa                	mov    %edi,%edx
f010189e:	83 c4 1c             	add    $0x1c,%esp
f01018a1:	5b                   	pop    %ebx
f01018a2:	5e                   	pop    %esi
f01018a3:	5f                   	pop    %edi
f01018a4:	5d                   	pop    %ebp
f01018a5:	c3                   	ret    
f01018a6:	8d 76 00             	lea    0x0(%esi),%esi
f01018a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01018b0:	31 ff                	xor    %edi,%edi
f01018b2:	31 c0                	xor    %eax,%eax
f01018b4:	89 fa                	mov    %edi,%edx
f01018b6:	83 c4 1c             	add    $0x1c,%esp
f01018b9:	5b                   	pop    %ebx
f01018ba:	5e                   	pop    %esi
f01018bb:	5f                   	pop    %edi
f01018bc:	5d                   	pop    %ebp
f01018bd:	c3                   	ret    
f01018be:	66 90                	xchg   %ax,%ax
f01018c0:	31 ff                	xor    %edi,%edi
f01018c2:	89 e8                	mov    %ebp,%eax
f01018c4:	89 f2                	mov    %esi,%edx
f01018c6:	f7 f3                	div    %ebx
f01018c8:	89 fa                	mov    %edi,%edx
f01018ca:	83 c4 1c             	add    $0x1c,%esp
f01018cd:	5b                   	pop    %ebx
f01018ce:	5e                   	pop    %esi
f01018cf:	5f                   	pop    %edi
f01018d0:	5d                   	pop    %ebp
f01018d1:	c3                   	ret    
f01018d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01018d8:	39 f2                	cmp    %esi,%edx
f01018da:	72 06                	jb     f01018e2 <__udivdi3+0x102>
f01018dc:	31 c0                	xor    %eax,%eax
f01018de:	39 eb                	cmp    %ebp,%ebx
f01018e0:	77 d2                	ja     f01018b4 <__udivdi3+0xd4>
f01018e2:	b8 01 00 00 00       	mov    $0x1,%eax
f01018e7:	eb cb                	jmp    f01018b4 <__udivdi3+0xd4>
f01018e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01018f0:	89 d8                	mov    %ebx,%eax
f01018f2:	31 ff                	xor    %edi,%edi
f01018f4:	eb be                	jmp    f01018b4 <__udivdi3+0xd4>
f01018f6:	66 90                	xchg   %ax,%ax
f01018f8:	66 90                	xchg   %ax,%ax
f01018fa:	66 90                	xchg   %ax,%ax
f01018fc:	66 90                	xchg   %ax,%ax
f01018fe:	66 90                	xchg   %ax,%ax

f0101900 <__umoddi3>:
f0101900:	55                   	push   %ebp
f0101901:	57                   	push   %edi
f0101902:	56                   	push   %esi
f0101903:	53                   	push   %ebx
f0101904:	83 ec 1c             	sub    $0x1c,%esp
f0101907:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f010190b:	8b 74 24 30          	mov    0x30(%esp),%esi
f010190f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101913:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101917:	85 ed                	test   %ebp,%ebp
f0101919:	89 f0                	mov    %esi,%eax
f010191b:	89 da                	mov    %ebx,%edx
f010191d:	75 19                	jne    f0101938 <__umoddi3+0x38>
f010191f:	39 df                	cmp    %ebx,%edi
f0101921:	0f 86 b1 00 00 00    	jbe    f01019d8 <__umoddi3+0xd8>
f0101927:	f7 f7                	div    %edi
f0101929:	89 d0                	mov    %edx,%eax
f010192b:	31 d2                	xor    %edx,%edx
f010192d:	83 c4 1c             	add    $0x1c,%esp
f0101930:	5b                   	pop    %ebx
f0101931:	5e                   	pop    %esi
f0101932:	5f                   	pop    %edi
f0101933:	5d                   	pop    %ebp
f0101934:	c3                   	ret    
f0101935:	8d 76 00             	lea    0x0(%esi),%esi
f0101938:	39 dd                	cmp    %ebx,%ebp
f010193a:	77 f1                	ja     f010192d <__umoddi3+0x2d>
f010193c:	0f bd cd             	bsr    %ebp,%ecx
f010193f:	83 f1 1f             	xor    $0x1f,%ecx
f0101942:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101946:	0f 84 b4 00 00 00    	je     f0101a00 <__umoddi3+0x100>
f010194c:	b8 20 00 00 00       	mov    $0x20,%eax
f0101951:	89 c2                	mov    %eax,%edx
f0101953:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101957:	29 c2                	sub    %eax,%edx
f0101959:	89 c1                	mov    %eax,%ecx
f010195b:	89 f8                	mov    %edi,%eax
f010195d:	d3 e5                	shl    %cl,%ebp
f010195f:	89 d1                	mov    %edx,%ecx
f0101961:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101965:	d3 e8                	shr    %cl,%eax
f0101967:	09 c5                	or     %eax,%ebp
f0101969:	8b 44 24 04          	mov    0x4(%esp),%eax
f010196d:	89 c1                	mov    %eax,%ecx
f010196f:	d3 e7                	shl    %cl,%edi
f0101971:	89 d1                	mov    %edx,%ecx
f0101973:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101977:	89 df                	mov    %ebx,%edi
f0101979:	d3 ef                	shr    %cl,%edi
f010197b:	89 c1                	mov    %eax,%ecx
f010197d:	89 f0                	mov    %esi,%eax
f010197f:	d3 e3                	shl    %cl,%ebx
f0101981:	89 d1                	mov    %edx,%ecx
f0101983:	89 fa                	mov    %edi,%edx
f0101985:	d3 e8                	shr    %cl,%eax
f0101987:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010198c:	09 d8                	or     %ebx,%eax
f010198e:	f7 f5                	div    %ebp
f0101990:	d3 e6                	shl    %cl,%esi
f0101992:	89 d1                	mov    %edx,%ecx
f0101994:	f7 64 24 08          	mull   0x8(%esp)
f0101998:	39 d1                	cmp    %edx,%ecx
f010199a:	89 c3                	mov    %eax,%ebx
f010199c:	89 d7                	mov    %edx,%edi
f010199e:	72 06                	jb     f01019a6 <__umoddi3+0xa6>
f01019a0:	75 0e                	jne    f01019b0 <__umoddi3+0xb0>
f01019a2:	39 c6                	cmp    %eax,%esi
f01019a4:	73 0a                	jae    f01019b0 <__umoddi3+0xb0>
f01019a6:	2b 44 24 08          	sub    0x8(%esp),%eax
f01019aa:	19 ea                	sbb    %ebp,%edx
f01019ac:	89 d7                	mov    %edx,%edi
f01019ae:	89 c3                	mov    %eax,%ebx
f01019b0:	89 ca                	mov    %ecx,%edx
f01019b2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f01019b7:	29 de                	sub    %ebx,%esi
f01019b9:	19 fa                	sbb    %edi,%edx
f01019bb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f01019bf:	89 d0                	mov    %edx,%eax
f01019c1:	d3 e0                	shl    %cl,%eax
f01019c3:	89 d9                	mov    %ebx,%ecx
f01019c5:	d3 ee                	shr    %cl,%esi
f01019c7:	d3 ea                	shr    %cl,%edx
f01019c9:	09 f0                	or     %esi,%eax
f01019cb:	83 c4 1c             	add    $0x1c,%esp
f01019ce:	5b                   	pop    %ebx
f01019cf:	5e                   	pop    %esi
f01019d0:	5f                   	pop    %edi
f01019d1:	5d                   	pop    %ebp
f01019d2:	c3                   	ret    
f01019d3:	90                   	nop
f01019d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019d8:	85 ff                	test   %edi,%edi
f01019da:	89 f9                	mov    %edi,%ecx
f01019dc:	75 0b                	jne    f01019e9 <__umoddi3+0xe9>
f01019de:	b8 01 00 00 00       	mov    $0x1,%eax
f01019e3:	31 d2                	xor    %edx,%edx
f01019e5:	f7 f7                	div    %edi
f01019e7:	89 c1                	mov    %eax,%ecx
f01019e9:	89 d8                	mov    %ebx,%eax
f01019eb:	31 d2                	xor    %edx,%edx
f01019ed:	f7 f1                	div    %ecx
f01019ef:	89 f0                	mov    %esi,%eax
f01019f1:	f7 f1                	div    %ecx
f01019f3:	e9 31 ff ff ff       	jmp    f0101929 <__umoddi3+0x29>
f01019f8:	90                   	nop
f01019f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a00:	39 dd                	cmp    %ebx,%ebp
f0101a02:	72 08                	jb     f0101a0c <__umoddi3+0x10c>
f0101a04:	39 f7                	cmp    %esi,%edi
f0101a06:	0f 87 21 ff ff ff    	ja     f010192d <__umoddi3+0x2d>
f0101a0c:	89 da                	mov    %ebx,%edx
f0101a0e:	89 f0                	mov    %esi,%eax
f0101a10:	29 f8                	sub    %edi,%eax
f0101a12:	19 ea                	sbb    %ebp,%edx
f0101a14:	e9 14 ff ff ff       	jmp    f010192d <__umoddi3+0x2d>