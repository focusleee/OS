
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
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# physical addresses [0, 4MB).  This 4MB region will be suffice
	# until we set up our real page table in mem_init in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 a0 11 00       	mov    $0x11a000,%eax
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
f0100034:	bc 00 a0 11 f0       	mov    $0xf011a000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 90 ee 17 f0       	mov    $0xf017ee90,%eax
f010004b:	2d 69 df 17 f0       	sub    $0xf017df69,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 69 df 17 f0 	movl   $0xf017df69,(%esp)
f0100063:	e8 51 51 00 00       	call   f01051b9 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 f2 04 00 00       	call   f010055f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 80 56 10 f0 	movl   $0xf0105680,(%esp)
f010007c:	e8 10 3b 00 00       	call   f0103b91 <cprintf>

	// Lab 2 memory management initialization functions
	cprintf("mem_init 1!\n", 6828);
f0100081:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100088:	00 
f0100089:	c7 04 24 9b 56 10 f0 	movl   $0xf010569b,(%esp)
f0100090:	e8 fc 3a 00 00       	call   f0103b91 <cprintf>
	mem_init();
f0100095:	e8 62 11 00 00       	call   f01011fc <mem_init>
	cprintf("mem_init 2!\n", 6828);
f010009a:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000a1:	00 
f01000a2:	c7 04 24 a8 56 10 f0 	movl   $0xf01056a8,(%esp)
f01000a9:	e8 e3 3a 00 00       	call   f0103b91 <cprintf>
	// Lab 3 user environment initialization functions
	env_init();
f01000ae:	e8 a7 33 00 00       	call   f010345a <env_init>
	trap_init();
f01000b3:	e8 55 3b 00 00       	call   f0103c0d <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01000b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01000bf:	00 
f01000c0:	c7 44 24 04 4a 78 00 	movl   $0x784a,0x4(%esp)
f01000c7:	00 
f01000c8:	c7 04 24 4d 2c 13 f0 	movl   $0xf0132c4d,(%esp)
f01000cf:	e8 97 35 00 00       	call   f010366b <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000d4:	a1 cc e1 17 f0       	mov    0xf017e1cc,%eax
f01000d9:	89 04 24             	mov    %eax,(%esp)
f01000dc:	e8 c9 39 00 00       	call   f0103aaa <env_run>

f01000e1 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e1:	55                   	push   %ebp
f01000e2:	89 e5                	mov    %esp,%ebp
f01000e4:	56                   	push   %esi
f01000e5:	53                   	push   %ebx
f01000e6:	83 ec 10             	sub    $0x10,%esp
f01000e9:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ec:	83 3d 80 ee 17 f0 00 	cmpl   $0x0,0xf017ee80
f01000f3:	75 3d                	jne    f0100132 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000f5:	89 35 80 ee 17 f0    	mov    %esi,0xf017ee80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000fb:	fa                   	cli    
f01000fc:	fc                   	cld    

	va_start(ap, fmt);
f01000fd:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100100:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100103:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100107:	8b 45 08             	mov    0x8(%ebp),%eax
f010010a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010010e:	c7 04 24 b5 56 10 f0 	movl   $0xf01056b5,(%esp)
f0100115:	e8 77 3a 00 00       	call   f0103b91 <cprintf>
	vcprintf(fmt, ap);
f010011a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011e:	89 34 24             	mov    %esi,(%esp)
f0100121:	e8 38 3a 00 00       	call   f0103b5e <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 9e 5c 10 f0 	movl   $0xf0105c9e,(%esp)
f010012d:	e8 5f 3a 00 00       	call   f0103b91 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100132:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100139:	e8 c9 06 00 00       	call   f0100807 <monitor>
f010013e:	eb f2                	jmp    f0100132 <_panic+0x51>

f0100140 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100140:	55                   	push   %ebp
f0100141:	89 e5                	mov    %esp,%ebp
f0100143:	53                   	push   %ebx
f0100144:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100147:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010014a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010014d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100151:	8b 45 08             	mov    0x8(%ebp),%eax
f0100154:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100158:	c7 04 24 cd 56 10 f0 	movl   $0xf01056cd,(%esp)
f010015f:	e8 2d 3a 00 00       	call   f0103b91 <cprintf>
	vcprintf(fmt, ap);
f0100164:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100168:	8b 45 10             	mov    0x10(%ebp),%eax
f010016b:	89 04 24             	mov    %eax,(%esp)
f010016e:	e8 eb 39 00 00       	call   f0103b5e <vcprintf>
	cprintf("\n");
f0100173:	c7 04 24 9e 5c 10 f0 	movl   $0xf0105c9e,(%esp)
f010017a:	e8 12 3a 00 00       	call   f0103b91 <cprintf>
	va_end(ap);
}
f010017f:	83 c4 14             	add    $0x14,%esp
f0100182:	5b                   	pop    %ebx
f0100183:	5d                   	pop    %ebp
f0100184:	c3                   	ret    
f0100185:	66 90                	xchg   %ax,%ax
f0100187:	66 90                	xchg   %ax,%ax
f0100189:	66 90                	xchg   %ax,%ax
f010018b:	66 90                	xchg   %ax,%ax
f010018d:	66 90                	xchg   %ax,%ax
f010018f:	90                   	nop

f0100190 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100190:	55                   	push   %ebp
f0100191:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100193:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100198:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100199:	a8 01                	test   $0x1,%al
f010019b:	74 08                	je     f01001a5 <serial_proc_data+0x15>
f010019d:	b2 f8                	mov    $0xf8,%dl
f010019f:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001a0:	0f b6 c0             	movzbl %al,%eax
f01001a3:	eb 05                	jmp    f01001aa <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001aa:	5d                   	pop    %ebp
f01001ab:	c3                   	ret    

f01001ac <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001ac:	55                   	push   %ebp
f01001ad:	89 e5                	mov    %esp,%ebp
f01001af:	53                   	push   %ebx
f01001b0:	83 ec 04             	sub    $0x4,%esp
f01001b3:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001b5:	eb 2a                	jmp    f01001e1 <cons_intr+0x35>
		if (c == 0)
f01001b7:	85 d2                	test   %edx,%edx
f01001b9:	74 26                	je     f01001e1 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01001bb:	a1 a4 e1 17 f0       	mov    0xf017e1a4,%eax
f01001c0:	8d 48 01             	lea    0x1(%eax),%ecx
f01001c3:	89 0d a4 e1 17 f0    	mov    %ecx,0xf017e1a4
f01001c9:	88 90 a0 df 17 f0    	mov    %dl,-0xfe82060(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01001cf:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01001d5:	75 0a                	jne    f01001e1 <cons_intr+0x35>
			cons.wpos = 0;
f01001d7:	c7 05 a4 e1 17 f0 00 	movl   $0x0,0xf017e1a4
f01001de:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001e1:	ff d3                	call   *%ebx
f01001e3:	89 c2                	mov    %eax,%edx
f01001e5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001e8:	75 cd                	jne    f01001b7 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001ea:	83 c4 04             	add    $0x4,%esp
f01001ed:	5b                   	pop    %ebx
f01001ee:	5d                   	pop    %ebp
f01001ef:	c3                   	ret    

f01001f0 <kbd_proc_data>:
f01001f0:	ba 64 00 00 00       	mov    $0x64,%edx
f01001f5:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001f6:	a8 01                	test   $0x1,%al
f01001f8:	0f 84 ef 00 00 00    	je     f01002ed <kbd_proc_data+0xfd>
f01001fe:	b2 60                	mov    $0x60,%dl
f0100200:	ec                   	in     (%dx),%al
f0100201:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100203:	3c e0                	cmp    $0xe0,%al
f0100205:	75 0d                	jne    f0100214 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f0100207:	83 0d 80 df 17 f0 40 	orl    $0x40,0xf017df80
		return 0;
f010020e:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100213:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100214:	55                   	push   %ebp
f0100215:	89 e5                	mov    %esp,%ebp
f0100217:	53                   	push   %ebx
f0100218:	83 ec 14             	sub    $0x14,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010021b:	84 c0                	test   %al,%al
f010021d:	79 37                	jns    f0100256 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010021f:	8b 0d 80 df 17 f0    	mov    0xf017df80,%ecx
f0100225:	89 cb                	mov    %ecx,%ebx
f0100227:	83 e3 40             	and    $0x40,%ebx
f010022a:	83 e0 7f             	and    $0x7f,%eax
f010022d:	85 db                	test   %ebx,%ebx
f010022f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100232:	0f b6 d2             	movzbl %dl,%edx
f0100235:	0f b6 82 40 58 10 f0 	movzbl -0xfefa7c0(%edx),%eax
f010023c:	83 c8 40             	or     $0x40,%eax
f010023f:	0f b6 c0             	movzbl %al,%eax
f0100242:	f7 d0                	not    %eax
f0100244:	21 c1                	and    %eax,%ecx
f0100246:	89 0d 80 df 17 f0    	mov    %ecx,0xf017df80
		return 0;
f010024c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100251:	e9 9d 00 00 00       	jmp    f01002f3 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100256:	8b 0d 80 df 17 f0    	mov    0xf017df80,%ecx
f010025c:	f6 c1 40             	test   $0x40,%cl
f010025f:	74 0e                	je     f010026f <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100261:	83 c8 80             	or     $0xffffff80,%eax
f0100264:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100266:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100269:	89 0d 80 df 17 f0    	mov    %ecx,0xf017df80
	}

	shift |= shiftcode[data];
f010026f:	0f b6 d2             	movzbl %dl,%edx
f0100272:	0f b6 82 40 58 10 f0 	movzbl -0xfefa7c0(%edx),%eax
f0100279:	0b 05 80 df 17 f0    	or     0xf017df80,%eax
	shift ^= togglecode[data];
f010027f:	0f b6 8a 40 57 10 f0 	movzbl -0xfefa8c0(%edx),%ecx
f0100286:	31 c8                	xor    %ecx,%eax
f0100288:	a3 80 df 17 f0       	mov    %eax,0xf017df80

	c = charcode[shift & (CTL | SHIFT)][data];
f010028d:	89 c1                	mov    %eax,%ecx
f010028f:	83 e1 03             	and    $0x3,%ecx
f0100292:	8b 0c 8d 20 57 10 f0 	mov    -0xfefa8e0(,%ecx,4),%ecx
f0100299:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010029d:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01002a0:	a8 08                	test   $0x8,%al
f01002a2:	74 1b                	je     f01002bf <kbd_proc_data+0xcf>
		if ('a' <= c && c <= 'z')
f01002a4:	89 da                	mov    %ebx,%edx
f01002a6:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01002a9:	83 f9 19             	cmp    $0x19,%ecx
f01002ac:	77 05                	ja     f01002b3 <kbd_proc_data+0xc3>
			c += 'A' - 'a';
f01002ae:	83 eb 20             	sub    $0x20,%ebx
f01002b1:	eb 0c                	jmp    f01002bf <kbd_proc_data+0xcf>
		else if ('A' <= c && c <= 'Z')
f01002b3:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002b6:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002b9:	83 fa 19             	cmp    $0x19,%edx
f01002bc:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002bf:	f7 d0                	not    %eax
f01002c1:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002c3:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002c5:	f6 c2 06             	test   $0x6,%dl
f01002c8:	75 29                	jne    f01002f3 <kbd_proc_data+0x103>
f01002ca:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002d0:	75 21                	jne    f01002f3 <kbd_proc_data+0x103>
		cprintf("Rebooting!\n");
f01002d2:	c7 04 24 e7 56 10 f0 	movl   $0xf01056e7,(%esp)
f01002d9:	e8 b3 38 00 00       	call   f0103b91 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002de:	ba 92 00 00 00       	mov    $0x92,%edx
f01002e3:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e8:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002e9:	89 d8                	mov    %ebx,%eax
f01002eb:	eb 06                	jmp    f01002f3 <kbd_proc_data+0x103>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002f2:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002f3:	83 c4 14             	add    $0x14,%esp
f01002f6:	5b                   	pop    %ebx
f01002f7:	5d                   	pop    %ebp
f01002f8:	c3                   	ret    

f01002f9 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002f9:	55                   	push   %ebp
f01002fa:	89 e5                	mov    %esp,%ebp
f01002fc:	57                   	push   %edi
f01002fd:	56                   	push   %esi
f01002fe:	53                   	push   %ebx
f01002ff:	83 ec 1c             	sub    $0x1c,%esp
f0100302:	89 c7                	mov    %eax,%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100304:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100309:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f010030a:	a8 20                	test   $0x20,%al
f010030c:	75 21                	jne    f010032f <cons_putc+0x36>
f010030e:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100313:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100318:	be fd 03 00 00       	mov    $0x3fd,%esi
f010031d:	89 ca                	mov    %ecx,%edx
f010031f:	ec                   	in     (%dx),%al
f0100320:	ec                   	in     (%dx),%al
f0100321:	ec                   	in     (%dx),%al
f0100322:	ec                   	in     (%dx),%al
f0100323:	89 f2                	mov    %esi,%edx
f0100325:	ec                   	in     (%dx),%al
f0100326:	a8 20                	test   $0x20,%al
f0100328:	75 05                	jne    f010032f <cons_putc+0x36>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010032a:	83 eb 01             	sub    $0x1,%ebx
f010032d:	75 ee                	jne    f010031d <cons_putc+0x24>
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f010032f:	89 f8                	mov    %edi,%eax
f0100331:	0f b6 c0             	movzbl %al,%eax
f0100334:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100337:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010033c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010033d:	b2 79                	mov    $0x79,%dl
f010033f:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100340:	84 c0                	test   %al,%al
f0100342:	78 21                	js     f0100365 <cons_putc+0x6c>
f0100344:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100349:	b9 84 00 00 00       	mov    $0x84,%ecx
f010034e:	be 79 03 00 00       	mov    $0x379,%esi
f0100353:	89 ca                	mov    %ecx,%edx
f0100355:	ec                   	in     (%dx),%al
f0100356:	ec                   	in     (%dx),%al
f0100357:	ec                   	in     (%dx),%al
f0100358:	ec                   	in     (%dx),%al
f0100359:	89 f2                	mov    %esi,%edx
f010035b:	ec                   	in     (%dx),%al
f010035c:	84 c0                	test   %al,%al
f010035e:	78 05                	js     f0100365 <cons_putc+0x6c>
f0100360:	83 eb 01             	sub    $0x1,%ebx
f0100363:	75 ee                	jne    f0100353 <cons_putc+0x5a>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100365:	ba 78 03 00 00       	mov    $0x378,%edx
f010036a:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f010036e:	ee                   	out    %al,(%dx)
f010036f:	b2 7a                	mov    $0x7a,%dl
f0100371:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100376:	ee                   	out    %al,(%dx)
f0100377:	b8 08 00 00 00       	mov    $0x8,%eax
f010037c:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010037d:	89 fa                	mov    %edi,%edx
f010037f:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100385:	89 f8                	mov    %edi,%eax
f0100387:	80 cc 07             	or     $0x7,%ah
f010038a:	85 d2                	test   %edx,%edx
f010038c:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010038f:	89 f8                	mov    %edi,%eax
f0100391:	0f b6 c0             	movzbl %al,%eax
f0100394:	83 f8 09             	cmp    $0x9,%eax
f0100397:	74 79                	je     f0100412 <cons_putc+0x119>
f0100399:	83 f8 09             	cmp    $0x9,%eax
f010039c:	7f 0a                	jg     f01003a8 <cons_putc+0xaf>
f010039e:	83 f8 08             	cmp    $0x8,%eax
f01003a1:	74 19                	je     f01003bc <cons_putc+0xc3>
f01003a3:	e9 9e 00 00 00       	jmp    f0100446 <cons_putc+0x14d>
f01003a8:	83 f8 0a             	cmp    $0xa,%eax
f01003ab:	90                   	nop
f01003ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01003b0:	74 3a                	je     f01003ec <cons_putc+0xf3>
f01003b2:	83 f8 0d             	cmp    $0xd,%eax
f01003b5:	74 3d                	je     f01003f4 <cons_putc+0xfb>
f01003b7:	e9 8a 00 00 00       	jmp    f0100446 <cons_putc+0x14d>
	case '\b':
		if (crt_pos > 0) {
f01003bc:	0f b7 05 a8 e1 17 f0 	movzwl 0xf017e1a8,%eax
f01003c3:	66 85 c0             	test   %ax,%ax
f01003c6:	0f 84 e5 00 00 00    	je     f01004b1 <cons_putc+0x1b8>
			crt_pos--;
f01003cc:	83 e8 01             	sub    $0x1,%eax
f01003cf:	66 a3 a8 e1 17 f0    	mov    %ax,0xf017e1a8
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003d5:	0f b7 c0             	movzwl %ax,%eax
f01003d8:	66 81 e7 00 ff       	and    $0xff00,%di
f01003dd:	83 cf 20             	or     $0x20,%edi
f01003e0:	8b 15 ac e1 17 f0    	mov    0xf017e1ac,%edx
f01003e6:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003ea:	eb 78                	jmp    f0100464 <cons_putc+0x16b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003ec:	66 83 05 a8 e1 17 f0 	addw   $0x50,0xf017e1a8
f01003f3:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003f4:	0f b7 05 a8 e1 17 f0 	movzwl 0xf017e1a8,%eax
f01003fb:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100401:	c1 e8 16             	shr    $0x16,%eax
f0100404:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100407:	c1 e0 04             	shl    $0x4,%eax
f010040a:	66 a3 a8 e1 17 f0    	mov    %ax,0xf017e1a8
f0100410:	eb 52                	jmp    f0100464 <cons_putc+0x16b>
		break;
	case '\t':
		cons_putc(' ');
f0100412:	b8 20 00 00 00       	mov    $0x20,%eax
f0100417:	e8 dd fe ff ff       	call   f01002f9 <cons_putc>
		cons_putc(' ');
f010041c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100421:	e8 d3 fe ff ff       	call   f01002f9 <cons_putc>
		cons_putc(' ');
f0100426:	b8 20 00 00 00       	mov    $0x20,%eax
f010042b:	e8 c9 fe ff ff       	call   f01002f9 <cons_putc>
		cons_putc(' ');
f0100430:	b8 20 00 00 00       	mov    $0x20,%eax
f0100435:	e8 bf fe ff ff       	call   f01002f9 <cons_putc>
		cons_putc(' ');
f010043a:	b8 20 00 00 00       	mov    $0x20,%eax
f010043f:	e8 b5 fe ff ff       	call   f01002f9 <cons_putc>
f0100444:	eb 1e                	jmp    f0100464 <cons_putc+0x16b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100446:	0f b7 05 a8 e1 17 f0 	movzwl 0xf017e1a8,%eax
f010044d:	8d 50 01             	lea    0x1(%eax),%edx
f0100450:	66 89 15 a8 e1 17 f0 	mov    %dx,0xf017e1a8
f0100457:	0f b7 c0             	movzwl %ax,%eax
f010045a:	8b 15 ac e1 17 f0    	mov    0xf017e1ac,%edx
f0100460:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100464:	66 81 3d a8 e1 17 f0 	cmpw   $0x7cf,0xf017e1a8
f010046b:	cf 07 
f010046d:	76 42                	jbe    f01004b1 <cons_putc+0x1b8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010046f:	a1 ac e1 17 f0       	mov    0xf017e1ac,%eax
f0100474:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010047b:	00 
f010047c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100482:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100486:	89 04 24             	mov    %eax,(%esp)
f0100489:	e8 78 4d 00 00       	call   f0105206 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010048e:	8b 15 ac e1 17 f0    	mov    0xf017e1ac,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100494:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100499:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010049f:	83 c0 01             	add    $0x1,%eax
f01004a2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004a7:	75 f0                	jne    f0100499 <cons_putc+0x1a0>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004a9:	66 83 2d a8 e1 17 f0 	subw   $0x50,0xf017e1a8
f01004b0:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004b1:	8b 0d b0 e1 17 f0    	mov    0xf017e1b0,%ecx
f01004b7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004bc:	89 ca                	mov    %ecx,%edx
f01004be:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004bf:	0f b7 1d a8 e1 17 f0 	movzwl 0xf017e1a8,%ebx
f01004c6:	8d 71 01             	lea    0x1(%ecx),%esi
f01004c9:	89 d8                	mov    %ebx,%eax
f01004cb:	66 c1 e8 08          	shr    $0x8,%ax
f01004cf:	89 f2                	mov    %esi,%edx
f01004d1:	ee                   	out    %al,(%dx)
f01004d2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004d7:	89 ca                	mov    %ecx,%edx
f01004d9:	ee                   	out    %al,(%dx)
f01004da:	89 d8                	mov    %ebx,%eax
f01004dc:	89 f2                	mov    %esi,%edx
f01004de:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004df:	83 c4 1c             	add    $0x1c,%esp
f01004e2:	5b                   	pop    %ebx
f01004e3:	5e                   	pop    %esi
f01004e4:	5f                   	pop    %edi
f01004e5:	5d                   	pop    %ebp
f01004e6:	c3                   	ret    

f01004e7 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004e7:	83 3d b4 e1 17 f0 00 	cmpl   $0x0,0xf017e1b4
f01004ee:	74 11                	je     f0100501 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004f0:	55                   	push   %ebp
f01004f1:	89 e5                	mov    %esp,%ebp
f01004f3:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004f6:	b8 90 01 10 f0       	mov    $0xf0100190,%eax
f01004fb:	e8 ac fc ff ff       	call   f01001ac <cons_intr>
}
f0100500:	c9                   	leave  
f0100501:	f3 c3                	repz ret 

f0100503 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100503:	55                   	push   %ebp
f0100504:	89 e5                	mov    %esp,%ebp
f0100506:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100509:	b8 f0 01 10 f0       	mov    $0xf01001f0,%eax
f010050e:	e8 99 fc ff ff       	call   f01001ac <cons_intr>
}
f0100513:	c9                   	leave  
f0100514:	c3                   	ret    

f0100515 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100515:	55                   	push   %ebp
f0100516:	89 e5                	mov    %esp,%ebp
f0100518:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010051b:	e8 c7 ff ff ff       	call   f01004e7 <serial_intr>
	kbd_intr();
f0100520:	e8 de ff ff ff       	call   f0100503 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100525:	a1 a0 e1 17 f0       	mov    0xf017e1a0,%eax
f010052a:	3b 05 a4 e1 17 f0    	cmp    0xf017e1a4,%eax
f0100530:	74 26                	je     f0100558 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100532:	8d 50 01             	lea    0x1(%eax),%edx
f0100535:	89 15 a0 e1 17 f0    	mov    %edx,0xf017e1a0
f010053b:	0f b6 88 a0 df 17 f0 	movzbl -0xfe82060(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100542:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100544:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010054a:	75 11                	jne    f010055d <cons_getc+0x48>
			cons.rpos = 0;
f010054c:	c7 05 a0 e1 17 f0 00 	movl   $0x0,0xf017e1a0
f0100553:	00 00 00 
f0100556:	eb 05                	jmp    f010055d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100558:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010055d:	c9                   	leave  
f010055e:	c3                   	ret    

f010055f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010055f:	55                   	push   %ebp
f0100560:	89 e5                	mov    %esp,%ebp
f0100562:	57                   	push   %edi
f0100563:	56                   	push   %esi
f0100564:	53                   	push   %ebx
f0100565:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100568:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010056f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100576:	5a a5 
	if (*cp != 0xA55A) {
f0100578:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010057f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100583:	74 11                	je     f0100596 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100585:	c7 05 b0 e1 17 f0 b4 	movl   $0x3b4,0xf017e1b0
f010058c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010058f:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f0100594:	eb 16                	jmp    f01005ac <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100596:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010059d:	c7 05 b0 e1 17 f0 d4 	movl   $0x3d4,0xf017e1b0
f01005a4:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005a7:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f01005ac:	8b 0d b0 e1 17 f0    	mov    0xf017e1b0,%ecx
f01005b2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005b7:	89 ca                	mov    %ecx,%edx
f01005b9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005ba:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005bd:	89 da                	mov    %ebx,%edx
f01005bf:	ec                   	in     (%dx),%al
f01005c0:	0f b6 f0             	movzbl %al,%esi
f01005c3:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005c6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005cb:	89 ca                	mov    %ecx,%edx
f01005cd:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005ce:	89 da                	mov    %ebx,%edx
f01005d0:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005d1:	89 3d ac e1 17 f0    	mov    %edi,0xf017e1ac
	
	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005d7:	0f b6 d8             	movzbl %al,%ebx
f01005da:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005dc:	66 89 35 a8 e1 17 f0 	mov    %si,0xf017e1a8
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005e3:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ed:	89 f2                	mov    %esi,%edx
f01005ef:	ee                   	out    %al,(%dx)
f01005f0:	b2 fb                	mov    $0xfb,%dl
f01005f2:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005f7:	ee                   	out    %al,(%dx)
f01005f8:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005fd:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100602:	89 da                	mov    %ebx,%edx
f0100604:	ee                   	out    %al,(%dx)
f0100605:	b2 f9                	mov    $0xf9,%dl
f0100607:	b8 00 00 00 00       	mov    $0x0,%eax
f010060c:	ee                   	out    %al,(%dx)
f010060d:	b2 fb                	mov    $0xfb,%dl
f010060f:	b8 03 00 00 00       	mov    $0x3,%eax
f0100614:	ee                   	out    %al,(%dx)
f0100615:	b2 fc                	mov    $0xfc,%dl
f0100617:	b8 00 00 00 00       	mov    $0x0,%eax
f010061c:	ee                   	out    %al,(%dx)
f010061d:	b2 f9                	mov    $0xf9,%dl
f010061f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100624:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100625:	b2 fd                	mov    $0xfd,%dl
f0100627:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100628:	3c ff                	cmp    $0xff,%al
f010062a:	0f 95 c1             	setne  %cl
f010062d:	0f b6 c9             	movzbl %cl,%ecx
f0100630:	89 0d b4 e1 17 f0    	mov    %ecx,0xf017e1b4
f0100636:	89 f2                	mov    %esi,%edx
f0100638:	ec                   	in     (%dx),%al
f0100639:	89 da                	mov    %ebx,%edx
f010063b:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010063c:	85 c9                	test   %ecx,%ecx
f010063e:	75 0c                	jne    f010064c <cons_init+0xed>
		cprintf("Serial port does not exist!\n");
f0100640:	c7 04 24 f3 56 10 f0 	movl   $0xf01056f3,(%esp)
f0100647:	e8 45 35 00 00       	call   f0103b91 <cprintf>
}
f010064c:	83 c4 1c             	add    $0x1c,%esp
f010064f:	5b                   	pop    %ebx
f0100650:	5e                   	pop    %esi
f0100651:	5f                   	pop    %edi
f0100652:	5d                   	pop    %ebp
f0100653:	c3                   	ret    

f0100654 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100654:	55                   	push   %ebp
f0100655:	89 e5                	mov    %esp,%ebp
f0100657:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010065a:	8b 45 08             	mov    0x8(%ebp),%eax
f010065d:	e8 97 fc ff ff       	call   f01002f9 <cons_putc>
}
f0100662:	c9                   	leave  
f0100663:	c3                   	ret    

f0100664 <getchar>:

int
getchar(void)
{
f0100664:	55                   	push   %ebp
f0100665:	89 e5                	mov    %esp,%ebp
f0100667:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010066a:	e8 a6 fe ff ff       	call   f0100515 <cons_getc>
f010066f:	85 c0                	test   %eax,%eax
f0100671:	74 f7                	je     f010066a <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100673:	c9                   	leave  
f0100674:	c3                   	ret    

f0100675 <iscons>:

int
iscons(int fdnum)
{
f0100675:	55                   	push   %ebp
f0100676:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100678:	b8 01 00 00 00       	mov    $0x1,%eax
f010067d:	5d                   	pop    %ebp
f010067e:	c3                   	ret    
f010067f:	90                   	nop

f0100680 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100680:	55                   	push   %ebp
f0100681:	89 e5                	mov    %esp,%ebp
f0100683:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100686:	c7 44 24 08 40 59 10 	movl   $0xf0105940,0x8(%esp)
f010068d:	f0 
f010068e:	c7 44 24 04 5e 59 10 	movl   $0xf010595e,0x4(%esp)
f0100695:	f0 
f0100696:	c7 04 24 63 59 10 f0 	movl   $0xf0105963,(%esp)
f010069d:	e8 ef 34 00 00       	call   f0103b91 <cprintf>
f01006a2:	c7 44 24 08 08 5a 10 	movl   $0xf0105a08,0x8(%esp)
f01006a9:	f0 
f01006aa:	c7 44 24 04 6c 59 10 	movl   $0xf010596c,0x4(%esp)
f01006b1:	f0 
f01006b2:	c7 04 24 63 59 10 f0 	movl   $0xf0105963,(%esp)
f01006b9:	e8 d3 34 00 00       	call   f0103b91 <cprintf>
f01006be:	c7 44 24 08 75 59 10 	movl   $0xf0105975,0x8(%esp)
f01006c5:	f0 
f01006c6:	c7 44 24 04 93 59 10 	movl   $0xf0105993,0x4(%esp)
f01006cd:	f0 
f01006ce:	c7 04 24 63 59 10 f0 	movl   $0xf0105963,(%esp)
f01006d5:	e8 b7 34 00 00       	call   f0103b91 <cprintf>
	return 0;
}
f01006da:	b8 00 00 00 00       	mov    $0x0,%eax
f01006df:	c9                   	leave  
f01006e0:	c3                   	ret    

f01006e1 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006e1:	55                   	push   %ebp
f01006e2:	89 e5                	mov    %esp,%ebp
f01006e4:	83 ec 18             	sub    $0x18,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006e7:	c7 04 24 a1 59 10 f0 	movl   $0xf01059a1,(%esp)
f01006ee:	e8 9e 34 00 00       	call   f0103b91 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006f3:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006fa:	00 
f01006fb:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100702:	f0 
f0100703:	c7 04 24 30 5a 10 f0 	movl   $0xf0105a30,(%esp)
f010070a:	e8 82 34 00 00       	call   f0103b91 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010070f:	c7 44 24 08 77 56 10 	movl   $0x105677,0x8(%esp)
f0100716:	00 
f0100717:	c7 44 24 04 77 56 10 	movl   $0xf0105677,0x4(%esp)
f010071e:	f0 
f010071f:	c7 04 24 54 5a 10 f0 	movl   $0xf0105a54,(%esp)
f0100726:	e8 66 34 00 00       	call   f0103b91 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010072b:	c7 44 24 08 69 df 17 	movl   $0x17df69,0x8(%esp)
f0100732:	00 
f0100733:	c7 44 24 04 69 df 17 	movl   $0xf017df69,0x4(%esp)
f010073a:	f0 
f010073b:	c7 04 24 78 5a 10 f0 	movl   $0xf0105a78,(%esp)
f0100742:	e8 4a 34 00 00       	call   f0103b91 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100747:	c7 44 24 08 90 ee 17 	movl   $0x17ee90,0x8(%esp)
f010074e:	00 
f010074f:	c7 44 24 04 90 ee 17 	movl   $0xf017ee90,0x4(%esp)
f0100756:	f0 
f0100757:	c7 04 24 9c 5a 10 f0 	movl   $0xf0105a9c,(%esp)
f010075e:	e8 2e 34 00 00       	call   f0103b91 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-entry+1023)/1024);
f0100763:	b8 8f f2 17 f0       	mov    $0xf017f28f,%eax
f0100768:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Special kernel symbols:\n");
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010076d:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100773:	85 c0                	test   %eax,%eax
f0100775:	0f 48 c2             	cmovs  %edx,%eax
f0100778:	c1 f8 0a             	sar    $0xa,%eax
f010077b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010077f:	c7 04 24 c0 5a 10 f0 	movl   $0xf0105ac0,(%esp)
f0100786:	e8 06 34 00 00       	call   f0103b91 <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f010078b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100790:	c9                   	leave  
f0100791:	c3                   	ret    

f0100792 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100792:	55                   	push   %ebp
f0100793:	89 e5                	mov    %esp,%ebp
f0100795:	53                   	push   %ebx
f0100796:	83 ec 44             	sub    $0x44,%esp

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100799:	89 eb                	mov    %ebp,%ebx
	unsigned int ebp;
	unsigned int eip;
	unsigned int args[5];
	unsigned int i;
     	ebp=read_ebp();
	cprintf("Stack backtrace:\n");
f010079b:	c7 04 24 ba 59 10 f0 	movl   $0xf01059ba,(%esp)
f01007a2:	e8 ea 33 00 00       	call   f0103b91 <cprintf>
	do{
           eip = *((unsigned int*)(ebp + 4));
f01007a7:	8b 4b 04             	mov    0x4(%ebx),%ecx
           for(i=0;i<5;i++)
f01007aa:	b8 00 00 00 00       	mov    $0x0,%eax
		args[i] = *((unsigned int*)(ebp+8+4*i));
f01007af:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f01007b3:	89 54 85 e4          	mov    %edx,-0x1c(%ebp,%eax,4)
	unsigned int i;
     	ebp=read_ebp();
	cprintf("Stack backtrace:\n");
	do{
           eip = *((unsigned int*)(ebp + 4));
           for(i=0;i<5;i++)
f01007b7:	83 c0 01             	add    $0x1,%eax
f01007ba:	83 f8 05             	cmp    $0x5,%eax
f01007bd:	75 f0                	jne    f01007af <mon_backtrace+0x1d>
		args[i] = *((unsigned int*)(ebp+8+4*i));
	cprintf(" ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",
f01007bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01007c2:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f01007c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01007c9:	89 44 24 18          	mov    %eax,0x18(%esp)
f01007cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01007d0:	89 44 24 14          	mov    %eax,0x14(%esp)
f01007d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01007d7:	89 44 24 10          	mov    %eax,0x10(%esp)
f01007db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01007de:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01007e2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01007e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01007ea:	c7 04 24 ec 5a 10 f0 	movl   $0xf0105aec,(%esp)
f01007f1:	e8 9b 33 00 00       	call   f0103b91 <cprintf>
		ebp,eip,args[0],args[1],args[2],args[3],args[4]);
	ebp =*((unsigned int*)ebp);
f01007f6:	8b 1b                	mov    (%ebx),%ebx
	}while(ebp!=0);
f01007f8:	85 db                	test   %ebx,%ebx
f01007fa:	75 ab                	jne    f01007a7 <mon_backtrace+0x15>
	return 0;
}
f01007fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100801:	83 c4 44             	add    $0x44,%esp
f0100804:	5b                   	pop    %ebx
f0100805:	5d                   	pop    %ebp
f0100806:	c3                   	ret    

f0100807 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100807:	55                   	push   %ebp
f0100808:	89 e5                	mov    %esp,%ebp
f010080a:	57                   	push   %edi
f010080b:	56                   	push   %esi
f010080c:	53                   	push   %ebx
f010080d:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100810:	c7 04 24 20 5b 10 f0 	movl   $0xf0105b20,(%esp)
f0100817:	e8 75 33 00 00       	call   f0103b91 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010081c:	c7 04 24 44 5b 10 f0 	movl   $0xf0105b44,(%esp)
f0100823:	e8 69 33 00 00       	call   f0103b91 <cprintf>

	if (tf != NULL)
f0100828:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010082c:	74 0b                	je     f0100839 <monitor+0x32>
		print_trapframe(tf);
f010082e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100831:	89 04 24             	mov    %eax,(%esp)
f0100834:	e8 8b 37 00 00       	call   f0103fc4 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100839:	c7 04 24 cc 59 10 f0 	movl   $0xf01059cc,(%esp)
f0100840:	e8 9b 46 00 00       	call   f0104ee0 <readline>
f0100845:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100847:	85 c0                	test   %eax,%eax
f0100849:	74 ee                	je     f0100839 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010084b:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100852:	be 00 00 00 00       	mov    $0x0,%esi
f0100857:	eb 0a                	jmp    f0100863 <monitor+0x5c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100859:	c6 03 00             	movb   $0x0,(%ebx)
f010085c:	89 f7                	mov    %esi,%edi
f010085e:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100861:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100863:	0f b6 03             	movzbl (%ebx),%eax
f0100866:	84 c0                	test   %al,%al
f0100868:	74 6a                	je     f01008d4 <monitor+0xcd>
f010086a:	0f be c0             	movsbl %al,%eax
f010086d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100871:	c7 04 24 d0 59 10 f0 	movl   $0xf01059d0,(%esp)
f0100878:	e8 dc 48 00 00       	call   f0105159 <strchr>
f010087d:	85 c0                	test   %eax,%eax
f010087f:	75 d8                	jne    f0100859 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100881:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100884:	74 4e                	je     f01008d4 <monitor+0xcd>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100886:	83 fe 0f             	cmp    $0xf,%esi
f0100889:	75 16                	jne    f01008a1 <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010088b:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100892:	00 
f0100893:	c7 04 24 d5 59 10 f0 	movl   $0xf01059d5,(%esp)
f010089a:	e8 f2 32 00 00       	call   f0103b91 <cprintf>
f010089f:	eb 98                	jmp    f0100839 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f01008a1:	8d 7e 01             	lea    0x1(%esi),%edi
f01008a4:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01008a8:	0f b6 03             	movzbl (%ebx),%eax
f01008ab:	84 c0                	test   %al,%al
f01008ad:	75 0c                	jne    f01008bb <monitor+0xb4>
f01008af:	eb b0                	jmp    f0100861 <monitor+0x5a>
			buf++;
f01008b1:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008b4:	0f b6 03             	movzbl (%ebx),%eax
f01008b7:	84 c0                	test   %al,%al
f01008b9:	74 a6                	je     f0100861 <monitor+0x5a>
f01008bb:	0f be c0             	movsbl %al,%eax
f01008be:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008c2:	c7 04 24 d0 59 10 f0 	movl   $0xf01059d0,(%esp)
f01008c9:	e8 8b 48 00 00       	call   f0105159 <strchr>
f01008ce:	85 c0                	test   %eax,%eax
f01008d0:	74 df                	je     f01008b1 <monitor+0xaa>
f01008d2:	eb 8d                	jmp    f0100861 <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f01008d4:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008db:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008dc:	85 f6                	test   %esi,%esi
f01008de:	0f 84 55 ff ff ff    	je     f0100839 <monitor+0x32>
f01008e4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01008e9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008ec:	8b 04 85 80 5b 10 f0 	mov    -0xfefa480(,%eax,4),%eax
f01008f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008f7:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008fa:	89 04 24             	mov    %eax,(%esp)
f01008fd:	e8 d3 47 00 00       	call   f01050d5 <strcmp>
f0100902:	85 c0                	test   %eax,%eax
f0100904:	75 24                	jne    f010092a <monitor+0x123>
			return commands[i].func(argc, argv, tf);
f0100906:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100909:	8b 55 08             	mov    0x8(%ebp),%edx
f010090c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100910:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100913:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100917:	89 34 24             	mov    %esi,(%esp)
f010091a:	ff 14 85 88 5b 10 f0 	call   *-0xfefa478(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100921:	85 c0                	test   %eax,%eax
f0100923:	78 25                	js     f010094a <monitor+0x143>
f0100925:	e9 0f ff ff ff       	jmp    f0100839 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010092a:	83 c3 01             	add    $0x1,%ebx
f010092d:	83 fb 03             	cmp    $0x3,%ebx
f0100930:	75 b7                	jne    f01008e9 <monitor+0xe2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100932:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100935:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100939:	c7 04 24 f2 59 10 f0 	movl   $0xf01059f2,(%esp)
f0100940:	e8 4c 32 00 00       	call   f0103b91 <cprintf>
f0100945:	e9 ef fe ff ff       	jmp    f0100839 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010094a:	83 c4 5c             	add    $0x5c,%esp
f010094d:	5b                   	pop    %ebx
f010094e:	5e                   	pop    %esi
f010094f:	5f                   	pop    %edi
f0100950:	5d                   	pop    %ebp
f0100951:	c3                   	ret    

f0100952 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100952:	55                   	push   %ebp
f0100953:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100955:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100958:	5d                   	pop    %ebp
f0100959:	c3                   	ret    
f010095a:	66 90                	xchg   %ax,%ax
f010095c:	66 90                	xchg   %ax,%ax
f010095e:	66 90                	xchg   %ax,%ax

f0100960 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100960:	55                   	push   %ebp
f0100961:	89 e5                	mov    %esp,%ebp
f0100963:	53                   	push   %ebx
f0100964:	83 ec 14             	sub    $0x14,%esp
f0100967:	89 c3                	mov    %eax,%ebx
	cprintf("boot_alloc\r\n");
f0100969:	c7 04 24 a4 5b 10 f0 	movl   $0xf0105ba4,(%esp)
f0100970:	e8 1c 32 00 00       	call   f0103b91 <cprintf>
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100975:	83 3d b8 e1 17 f0 00 	cmpl   $0x0,0xf017e1b8
f010097c:	75 0f                	jne    f010098d <boot_alloc+0x2d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010097e:	b8 8f fe 17 f0       	mov    $0xf017fe8f,%eax
f0100983:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100988:	a3 b8 e1 17 f0       	mov    %eax,0xf017e1b8
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result=nextfree;
f010098d:	a1 b8 e1 17 f0       	mov    0xf017e1b8,%eax
	nextfree+=ROUNDUP(n,PGSIZE);
f0100992:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0100998:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010099e:	01 c3                	add    %eax,%ebx
f01009a0:	89 1d b8 e1 17 f0    	mov    %ebx,0xf017e1b8
	return result;
}
f01009a6:	83 c4 14             	add    $0x14,%esp
f01009a9:	5b                   	pop    %ebx
f01009aa:	5d                   	pop    %ebp
f01009ab:	c3                   	ret    

f01009ac <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01009ac:	89 d1                	mov    %edx,%ecx
f01009ae:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01009b1:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009b4:	a8 01                	test   $0x1,%al
f01009b6:	74 5d                	je     f0100a15 <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009bd:	89 c1                	mov    %eax,%ecx
f01009bf:	c1 e9 0c             	shr    $0xc,%ecx
f01009c2:	3b 0d 84 ee 17 f0    	cmp    0xf017ee84,%ecx
f01009c8:	72 26                	jb     f01009f0 <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009ca:	55                   	push   %ebp
f01009cb:	89 e5                	mov    %esp,%ebp
f01009cd:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009d4:	c7 44 24 08 38 5f 10 	movl   $0xf0105f38,0x8(%esp)
f01009db:	f0 
f01009dc:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f01009e3:	00 
f01009e4:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01009eb:	e8 f1 f6 ff ff       	call   f01000e1 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f01009f0:	c1 ea 0c             	shr    $0xc,%edx
f01009f3:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009f9:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a00:	89 c2                	mov    %eax,%edx
f0100a02:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a05:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a0a:	85 d2                	test   %edx,%edx
f0100a0c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a11:	0f 44 c2             	cmove  %edx,%eax
f0100a14:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100a1a:	c3                   	ret    

f0100a1b <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a1b:	55                   	push   %ebp
f0100a1c:	89 e5                	mov    %esp,%ebp
f0100a1e:	57                   	push   %edi
f0100a1f:	56                   	push   %esi
f0100a20:	53                   	push   %ebx
f0100a21:	83 ec 3c             	sub    $0x3c,%esp
f0100a24:	89 c3                	mov    %eax,%ebx
	cprintf("check_page_free_list");
f0100a26:	c7 04 24 bd 5b 10 f0 	movl   $0xf0105bbd,(%esp)
f0100a2d:	e8 5f 31 00 00       	call   f0103b91 <cprintf>
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a32:	85 db                	test   %ebx,%ebx
f0100a34:	0f 85 35 03 00 00    	jne    f0100d6f <check_page_free_list+0x354>
f0100a3a:	e9 42 03 00 00       	jmp    f0100d81 <check_page_free_list+0x366>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a3f:	c7 44 24 08 5c 5f 10 	movl   $0xf0105f5c,0x8(%esp)
f0100a46:	f0 
f0100a47:	c7 44 24 04 b1 02 00 	movl   $0x2b1,0x4(%esp)
f0100a4e:	00 
f0100a4f:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0100a56:	e8 86 f6 ff ff       	call   f01000e1 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f0100a5b:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a5e:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a61:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a64:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a67:	89 c2                	mov    %eax,%edx
f0100a69:	2b 15 8c ee 17 f0    	sub    0xf017ee8c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a6f:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a75:	0f 95 c2             	setne  %dl
f0100a78:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a7b:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a7f:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a81:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a85:	8b 00                	mov    (%eax),%eax
f0100a87:	85 c0                	test   %eax,%eax
f0100a89:	75 dc                	jne    f0100a67 <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a8e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a94:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a97:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a9a:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a9c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a9f:	a3 c0 e1 17 f0       	mov    %eax,0xf017e1c0
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100aa4:	89 c3                	mov    %eax,%ebx
f0100aa6:	85 c0                	test   %eax,%eax
f0100aa8:	74 6c                	je     f0100b16 <check_page_free_list+0xfb>
static void
check_page_free_list(bool only_low_memory)
{
	cprintf("check_page_free_list");
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100aaa:	be 01 00 00 00       	mov    $0x1,%esi
f0100aaf:	89 d8                	mov    %ebx,%eax
f0100ab1:	2b 05 8c ee 17 f0    	sub    0xf017ee8c,%eax
f0100ab7:	c1 f8 03             	sar    $0x3,%eax
f0100aba:	c1 e0 0c             	shl    $0xc,%eax
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
f0100abd:	89 c2                	mov    %eax,%edx
f0100abf:	c1 ea 16             	shr    $0x16,%edx
f0100ac2:	39 f2                	cmp    %esi,%edx
f0100ac4:	73 4a                	jae    f0100b10 <check_page_free_list+0xf5>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ac6:	89 c2                	mov    %eax,%edx
f0100ac8:	c1 ea 0c             	shr    $0xc,%edx
f0100acb:	3b 15 84 ee 17 f0    	cmp    0xf017ee84,%edx
f0100ad1:	72 20                	jb     f0100af3 <check_page_free_list+0xd8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ad3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ad7:	c7 44 24 08 38 5f 10 	movl   $0xf0105f38,0x8(%esp)
f0100ade:	f0 
f0100adf:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100ae6:	00 
f0100ae7:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f0100aee:	e8 ee f5 ff ff       	call   f01000e1 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100af3:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100afa:	00 
f0100afb:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100b02:	00 
	return (void *)(pa + KERNBASE);
f0100b03:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b08:	89 04 24             	mov    %eax,(%esp)
f0100b0b:	e8 a9 46 00 00       	call   f01051b9 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b10:	8b 1b                	mov    (%ebx),%ebx
f0100b12:	85 db                	test   %ebx,%ebx
f0100b14:	75 99                	jne    f0100aaf <check_page_free_list+0x94>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100b16:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b1b:	e8 40 fe ff ff       	call   f0100960 <boot_alloc>
f0100b20:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b23:	8b 15 c0 e1 17 f0    	mov    0xf017e1c0,%edx
f0100b29:	85 d2                	test   %edx,%edx
f0100b2b:	0f 84 f2 01 00 00    	je     f0100d23 <check_page_free_list+0x308>
		// check that we didn't corrupt the free list itself
		//cprintf("%d",pp->pp_ref);
		assert(pp >= pages);
f0100b31:	8b 1d 8c ee 17 f0    	mov    0xf017ee8c,%ebx
f0100b37:	39 da                	cmp    %ebx,%edx
f0100b39:	72 3f                	jb     f0100b7a <check_page_free_list+0x15f>
		assert(pp < pages + npages);
f0100b3b:	a1 84 ee 17 f0       	mov    0xf017ee84,%eax
f0100b40:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100b43:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0100b46:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100b49:	39 c2                	cmp    %eax,%edx
f0100b4b:	73 56                	jae    f0100ba3 <check_page_free_list+0x188>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b4d:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100b50:	89 d0                	mov    %edx,%eax
f0100b52:	29 d8                	sub    %ebx,%eax
f0100b54:	a8 07                	test   $0x7,%al
f0100b56:	75 78                	jne    f0100bd0 <check_page_free_list+0x1b5>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b58:	c1 f8 03             	sar    $0x3,%eax
f0100b5b:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b5e:	85 c0                	test   %eax,%eax
f0100b60:	0f 84 98 00 00 00    	je     f0100bfe <check_page_free_list+0x1e3>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b66:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b6b:	0f 85 dc 00 00 00    	jne    f0100c4d <check_page_free_list+0x232>
f0100b71:	e9 b3 00 00 00       	jmp    f0100c29 <check_page_free_list+0x20e>

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		//cprintf("%d",pp->pp_ref);
		assert(pp >= pages);
f0100b76:	39 d3                	cmp    %edx,%ebx
f0100b78:	76 24                	jbe    f0100b9e <check_page_free_list+0x183>
f0100b7a:	c7 44 24 0c e0 5b 10 	movl   $0xf0105be0,0xc(%esp)
f0100b81:	f0 
f0100b82:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0100b89:	f0 
f0100b8a:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
f0100b91:	00 
f0100b92:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0100b99:	e8 43 f5 ff ff       	call   f01000e1 <_panic>
		assert(pp < pages + npages);
f0100b9e:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100ba1:	72 24                	jb     f0100bc7 <check_page_free_list+0x1ac>
f0100ba3:	c7 44 24 0c 01 5c 10 	movl   $0xf0105c01,0xc(%esp)
f0100baa:	f0 
f0100bab:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0100bb2:	f0 
f0100bb3:	c7 44 24 04 cd 02 00 	movl   $0x2cd,0x4(%esp)
f0100bba:	00 
f0100bbb:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0100bc2:	e8 1a f5 ff ff       	call   f01000e1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bc7:	89 d0                	mov    %edx,%eax
f0100bc9:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100bcc:	a8 07                	test   $0x7,%al
f0100bce:	74 24                	je     f0100bf4 <check_page_free_list+0x1d9>
f0100bd0:	c7 44 24 0c 80 5f 10 	movl   $0xf0105f80,0xc(%esp)
f0100bd7:	f0 
f0100bd8:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0100bdf:	f0 
f0100be0:	c7 44 24 04 ce 02 00 	movl   $0x2ce,0x4(%esp)
f0100be7:	00 
f0100be8:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0100bef:	e8 ed f4 ff ff       	call   f01000e1 <_panic>
f0100bf4:	c1 f8 03             	sar    $0x3,%eax
f0100bf7:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100bfa:	85 c0                	test   %eax,%eax
f0100bfc:	75 24                	jne    f0100c22 <check_page_free_list+0x207>
f0100bfe:	c7 44 24 0c 15 5c 10 	movl   $0xf0105c15,0xc(%esp)
f0100c05:	f0 
f0100c06:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0100c0d:	f0 
f0100c0e:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
f0100c15:	00 
f0100c16:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0100c1d:	e8 bf f4 ff ff       	call   f01000e1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c22:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c27:	75 2e                	jne    f0100c57 <check_page_free_list+0x23c>
f0100c29:	c7 44 24 0c 26 5c 10 	movl   $0xf0105c26,0xc(%esp)
f0100c30:	f0 
f0100c31:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0100c38:	f0 
f0100c39:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f0100c40:	00 
f0100c41:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0100c48:	e8 94 f4 ff ff       	call   f01000e1 <_panic>
check_page_free_list(bool only_low_memory)
{
	cprintf("check_page_free_list");
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c4d:	be 00 00 00 00       	mov    $0x0,%esi
f0100c52:	bf 00 00 00 00       	mov    $0x0,%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c57:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c5c:	75 24                	jne    f0100c82 <check_page_free_list+0x267>
f0100c5e:	c7 44 24 0c b4 5f 10 	movl   $0xf0105fb4,0xc(%esp)
f0100c65:	f0 
f0100c66:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0100c6d:	f0 
f0100c6e:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f0100c75:	00 
f0100c76:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0100c7d:	e8 5f f4 ff ff       	call   f01000e1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c82:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c87:	75 24                	jne    f0100cad <check_page_free_list+0x292>
f0100c89:	c7 44 24 0c 3f 5c 10 	movl   $0xf0105c3f,0xc(%esp)
f0100c90:	f0 
f0100c91:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0100c98:	f0 
f0100c99:	c7 44 24 04 d4 02 00 	movl   $0x2d4,0x4(%esp)
f0100ca0:	00 
f0100ca1:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0100ca8:	e8 34 f4 ff ff       	call   f01000e1 <_panic>
f0100cad:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100caf:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100cb4:	76 57                	jbe    f0100d0d <check_page_free_list+0x2f2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cb6:	c1 e8 0c             	shr    $0xc,%eax
f0100cb9:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100cbc:	77 20                	ja     f0100cde <check_page_free_list+0x2c3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cbe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100cc2:	c7 44 24 08 38 5f 10 	movl   $0xf0105f38,0x8(%esp)
f0100cc9:	f0 
f0100cca:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100cd1:	00 
f0100cd2:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f0100cd9:	e8 03 f4 ff ff       	call   f01000e1 <_panic>
	return (void *)(pa + KERNBASE);
f0100cde:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0100ce4:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0100ce7:	76 29                	jbe    f0100d12 <check_page_free_list+0x2f7>
f0100ce9:	c7 44 24 0c d8 5f 10 	movl   $0xf0105fd8,0xc(%esp)
f0100cf0:	f0 
f0100cf1:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0100cf8:	f0 
f0100cf9:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f0100d00:	00 
f0100d01:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0100d08:	e8 d4 f3 ff ff       	call   f01000e1 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d0d:	83 c7 01             	add    $0x1,%edi
f0100d10:	eb 03                	jmp    f0100d15 <check_page_free_list+0x2fa>
		else
			++nfree_extmem;
f0100d12:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d15:	8b 12                	mov    (%edx),%edx
f0100d17:	85 d2                	test   %edx,%edx
f0100d19:	0f 85 57 fe ff ff    	jne    f0100b76 <check_page_free_list+0x15b>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d1f:	85 ff                	test   %edi,%edi
f0100d21:	7f 24                	jg     f0100d47 <check_page_free_list+0x32c>
f0100d23:	c7 44 24 0c 59 5c 10 	movl   $0xf0105c59,0xc(%esp)
f0100d2a:	f0 
f0100d2b:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0100d32:	f0 
f0100d33:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f0100d3a:	00 
f0100d3b:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0100d42:	e8 9a f3 ff ff       	call   f01000e1 <_panic>
	assert(nfree_extmem > 0);
f0100d47:	85 f6                	test   %esi,%esi
f0100d49:	7f 53                	jg     f0100d9e <check_page_free_list+0x383>
f0100d4b:	c7 44 24 0c 6b 5c 10 	movl   $0xf0105c6b,0xc(%esp)
f0100d52:	f0 
f0100d53:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0100d5a:	f0 
f0100d5b:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f0100d62:	00 
f0100d63:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0100d6a:	e8 72 f3 ff ff       	call   f01000e1 <_panic>
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100d6f:	a1 c0 e1 17 f0       	mov    0xf017e1c0,%eax
f0100d74:	85 c0                	test   %eax,%eax
f0100d76:	0f 85 df fc ff ff    	jne    f0100a5b <check_page_free_list+0x40>
f0100d7c:	e9 be fc ff ff       	jmp    f0100a3f <check_page_free_list+0x24>
f0100d81:	83 3d c0 e1 17 f0 00 	cmpl   $0x0,0xf017e1c0
f0100d88:	0f 84 b1 fc ff ff    	je     f0100a3f <check_page_free_list+0x24>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d8e:	8b 1d c0 e1 17 f0    	mov    0xf017e1c0,%ebx
static void
check_page_free_list(bool only_low_memory)
{
	cprintf("check_page_free_list");
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d94:	be 00 04 00 00       	mov    $0x400,%esi
f0100d99:	e9 11 fd ff ff       	jmp    f0100aaf <check_page_free_list+0x94>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100d9e:	83 c4 3c             	add    $0x3c,%esp
f0100da1:	5b                   	pop    %ebx
f0100da2:	5e                   	pop    %esi
f0100da3:	5f                   	pop    %edi
f0100da4:	5d                   	pop    %ebp
f0100da5:	c3                   	ret    

f0100da6 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100da6:	55                   	push   %ebp
f0100da7:	89 e5                	mov    %esp,%ebp
f0100da9:	56                   	push   %esi
f0100daa:	53                   	push   %ebx
f0100dab:	83 ec 10             	sub    $0x10,%esp
	cprintf("page_init\r\n");
f0100dae:	c7 04 24 7c 5c 10 f0 	movl   $0xf0105c7c,(%esp)
f0100db5:	e8 d7 2d 00 00       	call   f0103b91 <cprintf>
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100dba:	83 3d 84 ee 17 f0 00 	cmpl   $0x0,0xf017ee84
f0100dc1:	0f 84 d2 00 00 00    	je     f0100e99 <page_init+0xf3>
f0100dc7:	8b 1d c0 e1 17 f0    	mov    0xf017e1c0,%ebx
f0100dcd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dd2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100dd9:	89 d1                	mov    %edx,%ecx
f0100ddb:	03 0d 8c ee 17 f0    	add    0xf017ee8c,%ecx
f0100de1:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100de7:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100de9:	03 15 8c ee 17 f0    	add    0xf017ee8c,%edx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100def:	83 c0 01             	add    $0x1,%eax
f0100df2:	8b 0d 84 ee 17 f0    	mov    0xf017ee84,%ecx
f0100df8:	39 c1                	cmp    %eax,%ecx
f0100dfa:	76 04                	jbe    f0100e00 <page_init+0x5a>
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100dfc:	89 d3                	mov    %edx,%ebx
f0100dfe:	eb d2                	jmp    f0100dd2 <page_init+0x2c>
f0100e00:	89 15 c0 e1 17 f0    	mov    %edx,0xf017e1c0
	}
	//first page
	extern char end[];
	pages[1].pp_link=0;
f0100e06:	a1 8c ee 17 f0       	mov    0xf017ee8c,%eax
f0100e0b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e12:	81 f9 a0 00 00 00    	cmp    $0xa0,%ecx
f0100e18:	77 1c                	ja     f0100e36 <page_init+0x90>
		panic("pa2page called with invalid pa");
f0100e1a:	c7 44 24 08 20 60 10 	movl   $0xf0106020,0x8(%esp)
f0100e21:	f0 
f0100e22:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0100e29:	00 
f0100e2a:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f0100e31:	e8 ab f2 ff ff       	call   f01000e1 <_panic>
	//io hole and kernel and kern_pgdir and pages
	struct Page* pgstart=pa2page((physaddr_t)IOPHYSMEM);
	struct Page* pgend=pa2page((physaddr_t)(end-KERNBASE+PGSIZE+ROUNDUP(npages*sizeof(struct Page),PGSIZE)+ROUNDUP(NENV*sizeof(struct Env),PGSIZE)));
f0100e36:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0100e3d:	8d 9a ff 0f 00 00    	lea    0xfff(%edx),%ebx
f0100e43:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
f0100e49:	29 da                	sub    %ebx,%edx
f0100e4b:	8d 92 8f 8e 19 00    	lea    0x198e8f(%edx),%edx
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e51:	c1 ea 0c             	shr    $0xc,%edx
f0100e54:	39 d1                	cmp    %edx,%ecx
f0100e56:	77 1c                	ja     f0100e74 <page_init+0xce>
		panic("pa2page called with invalid pa");
f0100e58:	c7 44 24 08 20 60 10 	movl   $0xf0106020,0x8(%esp)
f0100e5f:	f0 
f0100e60:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0100e67:	00 
f0100e68:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f0100e6f:	e8 6d f2 ff ff       	call   f01000e1 <_panic>
	return &pages[PGNUM(pa)];
f0100e74:	8d 1c d0             	lea    (%eax,%edx,8),%ebx
	//cprintf("pgstart %x ,pgend %x \r\n",(int)pgstart,(int)pgend);
	pgend=pgend+1;
	pgstart=pgstart-1;
f0100e77:	8d b0 f8 04 00 00    	lea    0x4f8(%eax),%esi
	pages[1].pp_link=0;
	//io hole and kernel and kern_pgdir and pages
	struct Page* pgstart=pa2page((physaddr_t)IOPHYSMEM);
	struct Page* pgend=pa2page((physaddr_t)(end-KERNBASE+PGSIZE+ROUNDUP(npages*sizeof(struct Page),PGSIZE)+ROUNDUP(NENV*sizeof(struct Env),PGSIZE)));
	//cprintf("pgstart %x ,pgend %x \r\n",(int)pgstart,(int)pgend);
	pgend=pgend+1;
f0100e7d:	8d 43 08             	lea    0x8(%ebx),%eax
	pgstart=pgstart-1;
	cprintf("pgstart %x ,pgend %x \r\n",(int)pgstart,(int)pgend);
f0100e80:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100e84:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e88:	c7 04 24 88 5c 10 f0 	movl   $0xf0105c88,(%esp)
f0100e8f:	e8 fd 2c 00 00       	call   f0103b91 <cprintf>
    pgend->pp_link=pgstart;
f0100e94:	89 73 08             	mov    %esi,0x8(%ebx)
f0100e97:	eb 11                	jmp    f0100eaa <page_init+0x104>
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	//first page
	extern char end[];
	pages[1].pp_link=0;
f0100e99:	a1 8c ee 17 f0       	mov    0xf017ee8c,%eax
f0100e9e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
f0100ea5:	e9 70 ff ff ff       	jmp    f0100e1a <page_init+0x74>
	//cprintf("pgstart %x ,pgend %x \r\n",(int)pgstart,(int)pgend);
	pgend=pgend+1;
	pgstart=pgstart-1;
	cprintf("pgstart %x ,pgend %x \r\n",(int)pgstart,(int)pgend);
    pgend->pp_link=pgstart;
}
f0100eaa:	83 c4 10             	add    $0x10,%esp
f0100ead:	5b                   	pop    %ebx
f0100eae:	5e                   	pop    %esi
f0100eaf:	5d                   	pop    %ebp
f0100eb0:	c3                   	ret    

f0100eb1 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f0100eb1:	55                   	push   %ebp
f0100eb2:	89 e5                	mov    %esp,%ebp
f0100eb4:	53                   	push   %ebx
f0100eb5:	83 ec 14             	sub    $0x14,%esp
	//cprintf("page_alloc\r\n");
	if(page_free_list==NULL)
f0100eb8:	8b 1d c0 e1 17 f0    	mov    0xf017e1c0,%ebx
f0100ebe:	85 db                	test   %ebx,%ebx
f0100ec0:	74 69                	je     f0100f2b <page_alloc+0x7a>
	{
		return NULL;
	}
	struct Page* result=page_free_list;
	page_free_list=page_free_list->pp_link;
f0100ec2:	8b 03                	mov    (%ebx),%eax
f0100ec4:	a3 c0 e1 17 f0       	mov    %eax,0xf017e1c0
	if(alloc_flags & ALLOC_ZERO)
	{
	memset(page2kva(result),0,PGSIZE);
	}
	return result;
f0100ec9:	89 d8                	mov    %ebx,%eax
	{
		return NULL;
	}
	struct Page* result=page_free_list;
	page_free_list=page_free_list->pp_link;
	if(alloc_flags & ALLOC_ZERO)
f0100ecb:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100ecf:	74 5f                	je     f0100f30 <page_alloc+0x7f>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ed1:	2b 05 8c ee 17 f0    	sub    0xf017ee8c,%eax
f0100ed7:	c1 f8 03             	sar    $0x3,%eax
f0100eda:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100edd:	89 c2                	mov    %eax,%edx
f0100edf:	c1 ea 0c             	shr    $0xc,%edx
f0100ee2:	3b 15 84 ee 17 f0    	cmp    0xf017ee84,%edx
f0100ee8:	72 20                	jb     f0100f0a <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100eea:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100eee:	c7 44 24 08 38 5f 10 	movl   $0xf0105f38,0x8(%esp)
f0100ef5:	f0 
f0100ef6:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100efd:	00 
f0100efe:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f0100f05:	e8 d7 f1 ff ff       	call   f01000e1 <_panic>
	{
	memset(page2kva(result),0,PGSIZE);
f0100f0a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100f11:	00 
f0100f12:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100f19:	00 
	return (void *)(pa + KERNBASE);
f0100f1a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f1f:	89 04 24             	mov    %eax,(%esp)
f0100f22:	e8 92 42 00 00       	call   f01051b9 <memset>
	}
	return result;
f0100f27:	89 d8                	mov    %ebx,%eax
f0100f29:	eb 05                	jmp    f0100f30 <page_alloc+0x7f>
page_alloc(int alloc_flags)
{
	//cprintf("page_alloc\r\n");
	if(page_free_list==NULL)
	{
		return NULL;
f0100f2b:	b8 00 00 00 00       	mov    $0x0,%eax
	if(alloc_flags & ALLOC_ZERO)
	{
	memset(page2kva(result),0,PGSIZE);
	}
	return result;
}
f0100f30:	83 c4 14             	add    $0x14,%esp
f0100f33:	5b                   	pop    %ebx
f0100f34:	5d                   	pop    %ebp
f0100f35:	c3                   	ret    

f0100f36 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0100f36:	55                   	push   %ebp
f0100f37:	89 e5                	mov    %esp,%ebp
f0100f39:	8b 45 08             	mov    0x8(%ebp),%eax
	//cprintf("page_frees\r\n");
	pp->pp_ref=0;
f0100f3c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	pp->pp_link=page_free_list;
f0100f42:	8b 15 c0 e1 17 f0    	mov    0xf017e1c0,%edx
f0100f48:	89 10                	mov    %edx,(%eax)
	page_free_list=pp;
f0100f4a:	a3 c0 e1 17 f0       	mov    %eax,0xf017e1c0
}
f0100f4f:	5d                   	pop    %ebp
f0100f50:	c3                   	ret    

f0100f51 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0100f51:	55                   	push   %ebp
f0100f52:	89 e5                	mov    %esp,%ebp
f0100f54:	83 ec 04             	sub    $0x4,%esp
f0100f57:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100f5a:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f0100f5e:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0100f61:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100f65:	66 85 d2             	test   %dx,%dx
f0100f68:	75 08                	jne    f0100f72 <page_decref+0x21>
		page_free(pp);
f0100f6a:	89 04 24             	mov    %eax,(%esp)
f0100f6d:	e8 c4 ff ff ff       	call   f0100f36 <page_free>
}
f0100f72:	c9                   	leave  
f0100f73:	c3                   	ret    

f0100f74 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100f74:	55                   	push   %ebp
f0100f75:	89 e5                	mov    %esp,%ebp
f0100f77:	56                   	push   %esi
f0100f78:	53                   	push   %ebx
f0100f79:	83 ec 10             	sub    $0x10,%esp
f0100f7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	//cprintf("pgdir_walk\r\n");
	// Fill this function in
	pte_t* result=NULL;
	if(pgdir[PDX(va)]==(pte_t)NULL)
f0100f7f:	89 de                	mov    %ebx,%esi
f0100f81:	c1 ee 16             	shr    $0x16,%esi
f0100f84:	c1 e6 02             	shl    $0x2,%esi
f0100f87:	03 75 08             	add    0x8(%ebp),%esi
f0100f8a:	8b 06                	mov    (%esi),%eax
f0100f8c:	85 c0                	test   %eax,%eax
f0100f8e:	75 76                	jne    f0101006 <pgdir_walk+0x92>
	{
		if(create==0)
f0100f90:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f94:	0f 84 d1 00 00 00    	je     f010106b <pgdir_walk+0xf7>
		{
			return NULL;
		}
		else
		{
			struct Page* page=page_alloc(1);
f0100f9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0100fa1:	e8 0b ff ff ff       	call   f0100eb1 <page_alloc>
			if(page==NULL)
f0100fa6:	85 c0                	test   %eax,%eax
f0100fa8:	0f 84 c4 00 00 00    	je     f0101072 <pgdir_walk+0xfe>
			{
				return NULL;
			}
			page->pp_ref++;
f0100fae:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fb3:	89 c2                	mov    %eax,%edx
f0100fb5:	2b 15 8c ee 17 f0    	sub    0xf017ee8c,%edx
f0100fbb:	c1 fa 03             	sar    $0x3,%edx
f0100fbe:	c1 e2 0c             	shl    $0xc,%edx
			pgdir[PDX(va)]=page2pa(page)|PTE_P|PTE_W|PTE_U;
f0100fc1:	83 ca 07             	or     $0x7,%edx
f0100fc4:	89 16                	mov    %edx,(%esi)
f0100fc6:	2b 05 8c ee 17 f0    	sub    0xf017ee8c,%eax
f0100fcc:	c1 f8 03             	sar    $0x3,%eax
f0100fcf:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fd2:	89 c2                	mov    %eax,%edx
f0100fd4:	c1 ea 0c             	shr    $0xc,%edx
f0100fd7:	3b 15 84 ee 17 f0    	cmp    0xf017ee84,%edx
f0100fdd:	72 20                	jb     f0100fff <pgdir_walk+0x8b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fdf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fe3:	c7 44 24 08 38 5f 10 	movl   $0xf0105f38,0x8(%esp)
f0100fea:	f0 
f0100feb:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100ff2:	00 
f0100ff3:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f0100ffa:	e8 e2 f0 ff ff       	call   f01000e1 <_panic>
	return (void *)(pa + KERNBASE);
f0100fff:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101004:	eb 58                	jmp    f010105e <pgdir_walk+0xea>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101006:	c1 e8 0c             	shr    $0xc,%eax
f0101009:	8b 15 84 ee 17 f0    	mov    0xf017ee84,%edx
f010100f:	39 d0                	cmp    %edx,%eax
f0101011:	72 1c                	jb     f010102f <pgdir_walk+0xbb>
		panic("pa2page called with invalid pa");
f0101013:	c7 44 24 08 20 60 10 	movl   $0xf0106020,0x8(%esp)
f010101a:	f0 
f010101b:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0101022:	00 
f0101023:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f010102a:	e8 b2 f0 ff ff       	call   f01000e1 <_panic>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010102f:	89 c1                	mov    %eax,%ecx
f0101031:	c1 e1 0c             	shl    $0xc,%ecx
f0101034:	39 d0                	cmp    %edx,%eax
f0101036:	72 20                	jb     f0101058 <pgdir_walk+0xe4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101038:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010103c:	c7 44 24 08 38 5f 10 	movl   $0xf0105f38,0x8(%esp)
f0101043:	f0 
f0101044:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010104b:	00 
f010104c:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f0101053:	e8 89 f0 ff ff       	call   f01000e1 <_panic>
	return (void *)(pa + KERNBASE);
f0101058:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
	else
	{
		//cprintf("%u ",PGNUM(PTE_ADDR(pgdir[PDX(va)])));
		result=page2kva(pa2page(PTE_ADDR(pgdir[PDX(va)])));
	}
	pte_t* r=&result[PTX(va)];
f010105e:	c1 eb 0a             	shr    $0xa,%ebx
f0101061:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
	pte_t pte=*r;

	return r;
f0101067:	01 d8                	add    %ebx,%eax
f0101069:	eb 0c                	jmp    f0101077 <pgdir_walk+0x103>
	pte_t* result=NULL;
	if(pgdir[PDX(va)]==(pte_t)NULL)
	{
		if(create==0)
		{
			return NULL;
f010106b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101070:	eb 05                	jmp    f0101077 <pgdir_walk+0x103>
		else
		{
			struct Page* page=page_alloc(1);
			if(page==NULL)
			{
				return NULL;
f0101072:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pte=*r;

	return r;


}
f0101077:	83 c4 10             	add    $0x10,%esp
f010107a:	5b                   	pop    %ebx
f010107b:	5e                   	pop    %esi
f010107c:	5d                   	pop    %ebp
f010107d:	c3                   	ret    

f010107e <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010107e:	55                   	push   %ebp
f010107f:	89 e5                	mov    %esp,%ebp
f0101081:	53                   	push   %ebx
f0101082:	83 ec 14             	sub    $0x14,%esp
f0101085:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//cprintf("page_lookup\r\n");
	// Fill this function in
	pte_t* pte=pgdir_walk(pgdir,va,0);
f0101088:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010108f:	00 
f0101090:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101093:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101097:	8b 45 08             	mov    0x8(%ebp),%eax
f010109a:	89 04 24             	mov    %eax,(%esp)
f010109d:	e8 d2 fe ff ff       	call   f0100f74 <pgdir_walk>
	if(pte==NULL)
f01010a2:	85 c0                	test   %eax,%eax
f01010a4:	74 3e                	je     f01010e4 <page_lookup+0x66>
	{
		return NULL;
	}
	if(pte_store!=0)
f01010a6:	85 db                	test   %ebx,%ebx
f01010a8:	74 02                	je     f01010ac <page_lookup+0x2e>
	{
		*pte_store=pte;
f01010aa:	89 03                	mov    %eax,(%ebx)
	}
    pte_t* unuse=pte;

	if(pte[0] !=(pte_t)NULL)
f01010ac:	8b 00                	mov    (%eax),%eax
f01010ae:	85 c0                	test   %eax,%eax
f01010b0:	74 39                	je     f01010eb <page_lookup+0x6d>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010b2:	c1 e8 0c             	shr    $0xc,%eax
f01010b5:	3b 05 84 ee 17 f0    	cmp    0xf017ee84,%eax
f01010bb:	72 1c                	jb     f01010d9 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f01010bd:	c7 44 24 08 20 60 10 	movl   $0xf0106020,0x8(%esp)
f01010c4:	f0 
f01010c5:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01010cc:	00 
f01010cd:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f01010d4:	e8 08 f0 ff ff       	call   f01000e1 <_panic>
	return &pages[PGNUM(pa)];
f01010d9:	8b 15 8c ee 17 f0    	mov    0xf017ee8c,%edx
f01010df:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	{

		return pa2page(PTE_ADDR(pte[0]));
f01010e2:	eb 0c                	jmp    f01010f0 <page_lookup+0x72>
	//cprintf("page_lookup\r\n");
	// Fill this function in
	pte_t* pte=pgdir_walk(pgdir,va,0);
	if(pte==NULL)
	{
		return NULL;
f01010e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01010e9:	eb 05                	jmp    f01010f0 <page_lookup+0x72>
		return pa2page(PTE_ADDR(pte[0]));

	}
	else
	{
		return NULL;
f01010eb:	b8 00 00 00 00       	mov    $0x0,%eax
	}
}
f01010f0:	83 c4 14             	add    $0x14,%esp
f01010f3:	5b                   	pop    %ebx
f01010f4:	5d                   	pop    %ebp
f01010f5:	c3                   	ret    

f01010f6 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01010f6:	55                   	push   %ebp
f01010f7:	89 e5                	mov    %esp,%ebp
f01010f9:	53                   	push   %ebx
f01010fa:	83 ec 24             	sub    $0x24,%esp
f01010fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	//cprintf("page_remove\r\n");
	pte_t* pte=0;
f0101100:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct Page* page=page_lookup(pgdir,va,&pte);
f0101107:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010110a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010110e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101112:	8b 45 08             	mov    0x8(%ebp),%eax
f0101115:	89 04 24             	mov    %eax,(%esp)
f0101118:	e8 61 ff ff ff       	call   f010107e <page_lookup>
	if(page!=NULL)
f010111d:	85 c0                	test   %eax,%eax
f010111f:	74 08                	je     f0101129 <page_remove+0x33>
	{
		page_decref(page);
f0101121:	89 04 24             	mov    %eax,(%esp)
f0101124:	e8 28 fe ff ff       	call   f0100f51 <page_decref>
	}

	pte[0]=0;
f0101129:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010112c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101132:	0f 01 3b             	invlpg (%ebx)
	tlb_invalidate(pgdir,va);
}
f0101135:	83 c4 24             	add    $0x24,%esp
f0101138:	5b                   	pop    %ebx
f0101139:	5d                   	pop    %ebp
f010113a:	c3                   	ret    

f010113b <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f010113b:	55                   	push   %ebp
f010113c:	89 e5                	mov    %esp,%ebp
f010113e:	57                   	push   %edi
f010113f:	56                   	push   %esi
f0101140:	53                   	push   %ebx
f0101141:	83 ec 1c             	sub    $0x1c,%esp
f0101144:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101147:	8b 75 10             	mov    0x10(%ebp),%esi
	//cprintf("page_insert\r\n");
	// Fill this function in
	pte_t* pte;
	struct Page* pg=page_lookup(pgdir,va,NULL);
f010114a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101151:	00 
f0101152:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101156:	8b 45 08             	mov    0x8(%ebp),%eax
f0101159:	89 04 24             	mov    %eax,(%esp)
f010115c:	e8 1d ff ff ff       	call   f010107e <page_lookup>
f0101161:	89 c7                	mov    %eax,%edi
	if(pg==pp)
f0101163:	39 d8                	cmp    %ebx,%eax
f0101165:	75 36                	jne    f010119d <page_insert+0x62>
	{
		pte=pgdir_walk(pgdir,va,1);
f0101167:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010116e:	00 
f010116f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101173:	8b 45 08             	mov    0x8(%ebp),%eax
f0101176:	89 04 24             	mov    %eax,(%esp)
f0101179:	e8 f6 fd ff ff       	call   f0100f74 <pgdir_walk>
		pte[0]=page2pa(pp)|perm|PTE_P;
f010117e:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0101181:	83 c9 01             	or     $0x1,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101184:	2b 3d 8c ee 17 f0    	sub    0xf017ee8c,%edi
f010118a:	c1 ff 03             	sar    $0x3,%edi
f010118d:	c1 e7 0c             	shl    $0xc,%edi
f0101190:	89 fa                	mov    %edi,%edx
f0101192:	09 ca                	or     %ecx,%edx
f0101194:	89 10                	mov    %edx,(%eax)
			return 0;
f0101196:	b8 00 00 00 00       	mov    $0x0,%eax
f010119b:	eb 57                	jmp    f01011f4 <page_insert+0xb9>
	}
	else if(pg!=NULL )
f010119d:	85 c0                	test   %eax,%eax
f010119f:	74 0f                	je     f01011b0 <page_insert+0x75>
	{
		page_remove(pgdir,va);
f01011a1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01011a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01011a8:	89 04 24             	mov    %eax,(%esp)
f01011ab:	e8 46 ff ff ff       	call   f01010f6 <page_remove>
	}
	pte=pgdir_walk(pgdir,va,1);
f01011b0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01011b7:	00 
f01011b8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01011bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01011bf:	89 04 24             	mov    %eax,(%esp)
f01011c2:	e8 ad fd ff ff       	call   f0100f74 <pgdir_walk>
	if(pte==NULL)
f01011c7:	85 c0                	test   %eax,%eax
f01011c9:	74 24                	je     f01011ef <page_insert+0xb4>
	{
		return -E_NO_MEM;
	}
	pte[0]=page2pa(pp)|perm|PTE_P;
f01011cb:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01011ce:	83 c9 01             	or     $0x1,%ecx
f01011d1:	89 da                	mov    %ebx,%edx
f01011d3:	2b 15 8c ee 17 f0    	sub    0xf017ee8c,%edx
f01011d9:	c1 fa 03             	sar    $0x3,%edx
f01011dc:	c1 e2 0c             	shl    $0xc,%edx
f01011df:	09 ca                	or     %ecx,%edx
f01011e1:	89 10                	mov    %edx,(%eax)
	pp->pp_ref++;
f01011e3:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	return 0;
f01011e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01011ed:	eb 05                	jmp    f01011f4 <page_insert+0xb9>
		page_remove(pgdir,va);
	}
	pte=pgdir_walk(pgdir,va,1);
	if(pte==NULL)
	{
		return -E_NO_MEM;
f01011ef:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	}
	pte[0]=page2pa(pp)|perm|PTE_P;
	pp->pp_ref++;
	return 0;
}
f01011f4:	83 c4 1c             	add    $0x1c,%esp
f01011f7:	5b                   	pop    %ebx
f01011f8:	5e                   	pop    %esi
f01011f9:	5f                   	pop    %edi
f01011fa:	5d                   	pop    %ebp
f01011fb:	c3                   	ret    

f01011fc <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01011fc:	55                   	push   %ebp
f01011fd:	89 e5                	mov    %esp,%ebp
f01011ff:	57                   	push   %edi
f0101200:	56                   	push   %esi
f0101201:	53                   	push   %ebx
f0101202:	83 ec 3c             	sub    $0x3c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101205:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f010120c:	e8 10 29 00 00       	call   f0103b21 <mc146818_read>
f0101211:	89 c3                	mov    %eax,%ebx
f0101213:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010121a:	e8 02 29 00 00       	call   f0103b21 <mc146818_read>
f010121f:	c1 e0 08             	shl    $0x8,%eax
f0101222:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101224:	89 d8                	mov    %ebx,%eax
f0101226:	c1 e0 0a             	shl    $0xa,%eax
f0101229:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010122f:	85 c0                	test   %eax,%eax
f0101231:	0f 48 c2             	cmovs  %edx,%eax
f0101234:	c1 f8 0c             	sar    $0xc,%eax
f0101237:	a3 c4 e1 17 f0       	mov    %eax,0xf017e1c4
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010123c:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101243:	e8 d9 28 00 00       	call   f0103b21 <mc146818_read>
f0101248:	89 c3                	mov    %eax,%ebx
f010124a:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101251:	e8 cb 28 00 00       	call   f0103b21 <mc146818_read>
f0101256:	c1 e0 08             	shl    $0x8,%eax
f0101259:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010125b:	89 d8                	mov    %ebx,%eax
f010125d:	c1 e0 0a             	shl    $0xa,%eax
f0101260:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101266:	85 c0                	test   %eax,%eax
f0101268:	0f 48 c2             	cmovs  %edx,%eax
f010126b:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010126e:	85 c0                	test   %eax,%eax
f0101270:	74 0e                	je     f0101280 <mem_init+0x84>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101272:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101278:	89 15 84 ee 17 f0    	mov    %edx,0xf017ee84
f010127e:	eb 0c                	jmp    f010128c <mem_init+0x90>
	else
		npages = npages_basemem;
f0101280:	8b 15 c4 e1 17 f0    	mov    0xf017e1c4,%edx
f0101286:	89 15 84 ee 17 f0    	mov    %edx,0xf017ee84

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010128c:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010128f:	c1 e8 0a             	shr    $0xa,%eax
f0101292:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101296:	a1 c4 e1 17 f0       	mov    0xf017e1c4,%eax
f010129b:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010129e:	c1 e8 0a             	shr    $0xa,%eax
f01012a1:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01012a5:	a1 84 ee 17 f0       	mov    0xf017ee84,%eax
f01012aa:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01012ad:	c1 e8 0a             	shr    $0xa,%eax
f01012b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012b4:	c7 04 24 40 60 10 f0 	movl   $0xf0106040,(%esp)
f01012bb:	e8 d1 28 00 00       	call   f0103b91 <cprintf>
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
	cprintf("npages :%u",npages);
f01012c0:	a1 84 ee 17 f0       	mov    0xf017ee84,%eax
f01012c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012c9:	c7 04 24 a0 5c 10 f0 	movl   $0xf0105ca0,(%esp)
f01012d0:	e8 bc 28 00 00       	call   f0103b91 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01012d5:	b8 00 10 00 00       	mov    $0x1000,%eax
f01012da:	e8 81 f6 ff ff       	call   f0100960 <boot_alloc>
f01012df:	a3 88 ee 17 f0       	mov    %eax,0xf017ee88
	memset(kern_pgdir, 0, PGSIZE);
f01012e4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01012eb:	00 
f01012ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01012f3:	00 
f01012f4:	89 04 24             	mov    %eax,(%esp)
f01012f7:	e8 bd 3e 00 00       	call   f01051b9 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01012fc:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101301:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101306:	77 20                	ja     f0101328 <mem_init+0x12c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101308:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010130c:	c7 44 24 08 7c 60 10 	movl   $0xf010607c,0x8(%esp)
f0101313:	f0 
f0101314:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
f010131b:	00 
f010131c:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101323:	e8 b9 ed ff ff       	call   f01000e1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101328:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010132e:	83 ca 05             	or     $0x5,%edx
f0101331:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct Page's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct Page in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = (struct Page *) boot_alloc(npages*sizeof(struct Page));
f0101337:	a1 84 ee 17 f0       	mov    0xf017ee84,%eax
f010133c:	c1 e0 03             	shl    $0x3,%eax
f010133f:	e8 1c f6 ff ff       	call   f0100960 <boot_alloc>
f0101344:	a3 8c ee 17 f0       	mov    %eax,0xf017ee8c

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs=(struct Env*)boot_alloc(NENV*sizeof(struct Env));
f0101349:	b8 00 80 01 00       	mov    $0x18000,%eax
f010134e:	e8 0d f6 ff ff       	call   f0100960 <boot_alloc>
f0101353:	a3 cc e1 17 f0       	mov    %eax,0xf017e1cc
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101358:	e8 49 fa ff ff       	call   f0100da6 <page_init>

	check_page_free_list(1);
f010135d:	b8 01 00 00 00       	mov    $0x1,%eax
f0101362:	e8 b4 f6 ff ff       	call   f0100a1b <check_page_free_list>
// and page_init()).
//
static void
check_page_alloc(void)
{
	cprintf("check_page_alloc");
f0101367:	c7 04 24 ab 5c 10 f0 	movl   $0xf0105cab,(%esp)
f010136e:	e8 1e 28 00 00       	call   f0103b91 <cprintf>
	int nfree;
	struct Page *fl;
	char *c;
	int i;

	if (!pages)
f0101373:	83 3d 8c ee 17 f0 00 	cmpl   $0x0,0xf017ee8c
f010137a:	75 1c                	jne    f0101398 <mem_init+0x19c>
		panic("'pages' is a null pointer!");
f010137c:	c7 44 24 08 bc 5c 10 	movl   $0xf0105cbc,0x8(%esp)
f0101383:	f0 
f0101384:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f010138b:	00 
f010138c:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101393:	e8 49 ed ff ff       	call   f01000e1 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101398:	a1 c0 e1 17 f0       	mov    0xf017e1c0,%eax
f010139d:	85 c0                	test   %eax,%eax
f010139f:	74 10                	je     f01013b1 <mem_init+0x1b5>
f01013a1:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f01013a6:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013a9:	8b 00                	mov    (%eax),%eax
f01013ab:	85 c0                	test   %eax,%eax
f01013ad:	75 f7                	jne    f01013a6 <mem_init+0x1aa>
f01013af:	eb 05                	jmp    f01013b6 <mem_init+0x1ba>
f01013b1:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01013b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01013bd:	e8 ef fa ff ff       	call   f0100eb1 <page_alloc>
f01013c2:	89 c7                	mov    %eax,%edi
f01013c4:	85 c0                	test   %eax,%eax
f01013c6:	75 24                	jne    f01013ec <mem_init+0x1f0>
f01013c8:	c7 44 24 0c d7 5c 10 	movl   $0xf0105cd7,0xc(%esp)
f01013cf:	f0 
f01013d0:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f01013d7:	f0 
f01013d8:	c7 44 24 04 f8 02 00 	movl   $0x2f8,0x4(%esp)
f01013df:	00 
f01013e0:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01013e7:	e8 f5 ec ff ff       	call   f01000e1 <_panic>
	assert((pp1 = page_alloc(0)));
f01013ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01013f3:	e8 b9 fa ff ff       	call   f0100eb1 <page_alloc>
f01013f8:	89 c6                	mov    %eax,%esi
f01013fa:	85 c0                	test   %eax,%eax
f01013fc:	75 24                	jne    f0101422 <mem_init+0x226>
f01013fe:	c7 44 24 0c ed 5c 10 	movl   $0xf0105ced,0xc(%esp)
f0101405:	f0 
f0101406:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f010140d:	f0 
f010140e:	c7 44 24 04 f9 02 00 	movl   $0x2f9,0x4(%esp)
f0101415:	00 
f0101416:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f010141d:	e8 bf ec ff ff       	call   f01000e1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101422:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101429:	e8 83 fa ff ff       	call   f0100eb1 <page_alloc>
f010142e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101431:	85 c0                	test   %eax,%eax
f0101433:	75 24                	jne    f0101459 <mem_init+0x25d>
f0101435:	c7 44 24 0c 03 5d 10 	movl   $0xf0105d03,0xc(%esp)
f010143c:	f0 
f010143d:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101444:	f0 
f0101445:	c7 44 24 04 fa 02 00 	movl   $0x2fa,0x4(%esp)
f010144c:	00 
f010144d:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101454:	e8 88 ec ff ff       	call   f01000e1 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101459:	39 f7                	cmp    %esi,%edi
f010145b:	75 24                	jne    f0101481 <mem_init+0x285>
f010145d:	c7 44 24 0c 19 5d 10 	movl   $0xf0105d19,0xc(%esp)
f0101464:	f0 
f0101465:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f010146c:	f0 
f010146d:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f0101474:	00 
f0101475:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f010147c:	e8 60 ec ff ff       	call   f01000e1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101481:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101484:	39 c6                	cmp    %eax,%esi
f0101486:	74 04                	je     f010148c <mem_init+0x290>
f0101488:	39 c7                	cmp    %eax,%edi
f010148a:	75 24                	jne    f01014b0 <mem_init+0x2b4>
f010148c:	c7 44 24 0c a0 60 10 	movl   $0xf01060a0,0xc(%esp)
f0101493:	f0 
f0101494:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f010149b:	f0 
f010149c:	c7 44 24 04 fe 02 00 	movl   $0x2fe,0x4(%esp)
f01014a3:	00 
f01014a4:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01014ab:	e8 31 ec ff ff       	call   f01000e1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01014b0:	8b 15 8c ee 17 f0    	mov    0xf017ee8c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014b6:	a1 84 ee 17 f0       	mov    0xf017ee84,%eax
f01014bb:	c1 e0 0c             	shl    $0xc,%eax
f01014be:	89 f9                	mov    %edi,%ecx
f01014c0:	29 d1                	sub    %edx,%ecx
f01014c2:	c1 f9 03             	sar    $0x3,%ecx
f01014c5:	c1 e1 0c             	shl    $0xc,%ecx
f01014c8:	39 c1                	cmp    %eax,%ecx
f01014ca:	72 24                	jb     f01014f0 <mem_init+0x2f4>
f01014cc:	c7 44 24 0c 2b 5d 10 	movl   $0xf0105d2b,0xc(%esp)
f01014d3:	f0 
f01014d4:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f01014db:	f0 
f01014dc:	c7 44 24 04 ff 02 00 	movl   $0x2ff,0x4(%esp)
f01014e3:	00 
f01014e4:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01014eb:	e8 f1 eb ff ff       	call   f01000e1 <_panic>
f01014f0:	89 f1                	mov    %esi,%ecx
f01014f2:	29 d1                	sub    %edx,%ecx
f01014f4:	c1 f9 03             	sar    $0x3,%ecx
f01014f7:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01014fa:	39 c8                	cmp    %ecx,%eax
f01014fc:	77 24                	ja     f0101522 <mem_init+0x326>
f01014fe:	c7 44 24 0c 48 5d 10 	movl   $0xf0105d48,0xc(%esp)
f0101505:	f0 
f0101506:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f010150d:	f0 
f010150e:	c7 44 24 04 00 03 00 	movl   $0x300,0x4(%esp)
f0101515:	00 
f0101516:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f010151d:	e8 bf eb ff ff       	call   f01000e1 <_panic>
f0101522:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101525:	29 d1                	sub    %edx,%ecx
f0101527:	89 ca                	mov    %ecx,%edx
f0101529:	c1 fa 03             	sar    $0x3,%edx
f010152c:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010152f:	39 d0                	cmp    %edx,%eax
f0101531:	77 24                	ja     f0101557 <mem_init+0x35b>
f0101533:	c7 44 24 0c 65 5d 10 	movl   $0xf0105d65,0xc(%esp)
f010153a:	f0 
f010153b:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101542:	f0 
f0101543:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f010154a:	00 
f010154b:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101552:	e8 8a eb ff ff       	call   f01000e1 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101557:	a1 c0 e1 17 f0       	mov    0xf017e1c0,%eax
f010155c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010155f:	c7 05 c0 e1 17 f0 00 	movl   $0x0,0xf017e1c0
f0101566:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101569:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101570:	e8 3c f9 ff ff       	call   f0100eb1 <page_alloc>
f0101575:	85 c0                	test   %eax,%eax
f0101577:	74 24                	je     f010159d <mem_init+0x3a1>
f0101579:	c7 44 24 0c 82 5d 10 	movl   $0xf0105d82,0xc(%esp)
f0101580:	f0 
f0101581:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101588:	f0 
f0101589:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f0101590:	00 
f0101591:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101598:	e8 44 eb ff ff       	call   f01000e1 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010159d:	89 3c 24             	mov    %edi,(%esp)
f01015a0:	e8 91 f9 ff ff       	call   f0100f36 <page_free>
	page_free(pp1);
f01015a5:	89 34 24             	mov    %esi,(%esp)
f01015a8:	e8 89 f9 ff ff       	call   f0100f36 <page_free>
	page_free(pp2);
f01015ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015b0:	89 04 24             	mov    %eax,(%esp)
f01015b3:	e8 7e f9 ff ff       	call   f0100f36 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015bf:	e8 ed f8 ff ff       	call   f0100eb1 <page_alloc>
f01015c4:	89 c6                	mov    %eax,%esi
f01015c6:	85 c0                	test   %eax,%eax
f01015c8:	75 24                	jne    f01015ee <mem_init+0x3f2>
f01015ca:	c7 44 24 0c d7 5c 10 	movl   $0xf0105cd7,0xc(%esp)
f01015d1:	f0 
f01015d2:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f01015d9:	f0 
f01015da:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f01015e1:	00 
f01015e2:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01015e9:	e8 f3 ea ff ff       	call   f01000e1 <_panic>
	assert((pp1 = page_alloc(0)));
f01015ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015f5:	e8 b7 f8 ff ff       	call   f0100eb1 <page_alloc>
f01015fa:	89 c7                	mov    %eax,%edi
f01015fc:	85 c0                	test   %eax,%eax
f01015fe:	75 24                	jne    f0101624 <mem_init+0x428>
f0101600:	c7 44 24 0c ed 5c 10 	movl   $0xf0105ced,0xc(%esp)
f0101607:	f0 
f0101608:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f010160f:	f0 
f0101610:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f0101617:	00 
f0101618:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f010161f:	e8 bd ea ff ff       	call   f01000e1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101624:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010162b:	e8 81 f8 ff ff       	call   f0100eb1 <page_alloc>
f0101630:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101633:	85 c0                	test   %eax,%eax
f0101635:	75 24                	jne    f010165b <mem_init+0x45f>
f0101637:	c7 44 24 0c 03 5d 10 	movl   $0xf0105d03,0xc(%esp)
f010163e:	f0 
f010163f:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101646:	f0 
f0101647:	c7 44 24 04 11 03 00 	movl   $0x311,0x4(%esp)
f010164e:	00 
f010164f:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101656:	e8 86 ea ff ff       	call   f01000e1 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010165b:	39 fe                	cmp    %edi,%esi
f010165d:	75 24                	jne    f0101683 <mem_init+0x487>
f010165f:	c7 44 24 0c 19 5d 10 	movl   $0xf0105d19,0xc(%esp)
f0101666:	f0 
f0101667:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f010166e:	f0 
f010166f:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f0101676:	00 
f0101677:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f010167e:	e8 5e ea ff ff       	call   f01000e1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101683:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101686:	39 c7                	cmp    %eax,%edi
f0101688:	74 04                	je     f010168e <mem_init+0x492>
f010168a:	39 c6                	cmp    %eax,%esi
f010168c:	75 24                	jne    f01016b2 <mem_init+0x4b6>
f010168e:	c7 44 24 0c a0 60 10 	movl   $0xf01060a0,0xc(%esp)
f0101695:	f0 
f0101696:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f010169d:	f0 
f010169e:	c7 44 24 04 14 03 00 	movl   $0x314,0x4(%esp)
f01016a5:	00 
f01016a6:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01016ad:	e8 2f ea ff ff       	call   f01000e1 <_panic>
	assert(!page_alloc(0));
f01016b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016b9:	e8 f3 f7 ff ff       	call   f0100eb1 <page_alloc>
f01016be:	85 c0                	test   %eax,%eax
f01016c0:	74 24                	je     f01016e6 <mem_init+0x4ea>
f01016c2:	c7 44 24 0c 82 5d 10 	movl   $0xf0105d82,0xc(%esp)
f01016c9:	f0 
f01016ca:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f01016d1:	f0 
f01016d2:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f01016d9:	00 
f01016da:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01016e1:	e8 fb e9 ff ff       	call   f01000e1 <_panic>
f01016e6:	89 f0                	mov    %esi,%eax
f01016e8:	2b 05 8c ee 17 f0    	sub    0xf017ee8c,%eax
f01016ee:	c1 f8 03             	sar    $0x3,%eax
f01016f1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016f4:	89 c2                	mov    %eax,%edx
f01016f6:	c1 ea 0c             	shr    $0xc,%edx
f01016f9:	3b 15 84 ee 17 f0    	cmp    0xf017ee84,%edx
f01016ff:	72 20                	jb     f0101721 <mem_init+0x525>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101701:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101705:	c7 44 24 08 38 5f 10 	movl   $0xf0105f38,0x8(%esp)
f010170c:	f0 
f010170d:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101714:	00 
f0101715:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f010171c:	e8 c0 e9 ff ff       	call   f01000e1 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101721:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101728:	00 
f0101729:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101730:	00 
	return (void *)(pa + KERNBASE);
f0101731:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101736:	89 04 24             	mov    %eax,(%esp)
f0101739:	e8 7b 3a 00 00       	call   f01051b9 <memset>
	page_free(pp0);
f010173e:	89 34 24             	mov    %esi,(%esp)
f0101741:	e8 f0 f7 ff ff       	call   f0100f36 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101746:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010174d:	e8 5f f7 ff ff       	call   f0100eb1 <page_alloc>
f0101752:	85 c0                	test   %eax,%eax
f0101754:	75 24                	jne    f010177a <mem_init+0x57e>
f0101756:	c7 44 24 0c 91 5d 10 	movl   $0xf0105d91,0xc(%esp)
f010175d:	f0 
f010175e:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101765:	f0 
f0101766:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f010176d:	00 
f010176e:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101775:	e8 67 e9 ff ff       	call   f01000e1 <_panic>
	assert(pp && pp0 == pp);
f010177a:	39 c6                	cmp    %eax,%esi
f010177c:	74 24                	je     f01017a2 <mem_init+0x5a6>
f010177e:	c7 44 24 0c af 5d 10 	movl   $0xf0105daf,0xc(%esp)
f0101785:	f0 
f0101786:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f010178d:	f0 
f010178e:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f0101795:	00 
f0101796:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f010179d:	e8 3f e9 ff ff       	call   f01000e1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01017a2:	89 f2                	mov    %esi,%edx
f01017a4:	2b 15 8c ee 17 f0    	sub    0xf017ee8c,%edx
f01017aa:	c1 fa 03             	sar    $0x3,%edx
f01017ad:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017b0:	89 d0                	mov    %edx,%eax
f01017b2:	c1 e8 0c             	shr    $0xc,%eax
f01017b5:	3b 05 84 ee 17 f0    	cmp    0xf017ee84,%eax
f01017bb:	72 20                	jb     f01017dd <mem_init+0x5e1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01017c1:	c7 44 24 08 38 5f 10 	movl   $0xf0105f38,0x8(%esp)
f01017c8:	f0 
f01017c9:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01017d0:	00 
f01017d1:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f01017d8:	e8 04 e9 ff ff       	call   f01000e1 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01017dd:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f01017e4:	75 11                	jne    f01017f7 <mem_init+0x5fb>
f01017e6:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
f01017ec:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f01017f2:	80 38 00             	cmpb   $0x0,(%eax)
f01017f5:	74 24                	je     f010181b <mem_init+0x61f>
f01017f7:	c7 44 24 0c bf 5d 10 	movl   $0xf0105dbf,0xc(%esp)
f01017fe:	f0 
f01017ff:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101806:	f0 
f0101807:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f010180e:	00 
f010180f:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101816:	e8 c6 e8 ff ff       	call   f01000e1 <_panic>
f010181b:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010181e:	39 d0                	cmp    %edx,%eax
f0101820:	75 d0                	jne    f01017f2 <mem_init+0x5f6>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101822:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101825:	a3 c0 e1 17 f0       	mov    %eax,0xf017e1c0

	// free the pages we took
	page_free(pp0);
f010182a:	89 34 24             	mov    %esi,(%esp)
f010182d:	e8 04 f7 ff ff       	call   f0100f36 <page_free>
	page_free(pp1);
f0101832:	89 3c 24             	mov    %edi,(%esp)
f0101835:	e8 fc f6 ff ff       	call   f0100f36 <page_free>
	page_free(pp2);
f010183a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010183d:	89 04 24             	mov    %eax,(%esp)
f0101840:	e8 f1 f6 ff ff       	call   f0100f36 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101845:	a1 c0 e1 17 f0       	mov    0xf017e1c0,%eax
f010184a:	85 c0                	test   %eax,%eax
f010184c:	74 09                	je     f0101857 <mem_init+0x65b>
		--nfree;
f010184e:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101851:	8b 00                	mov    (%eax),%eax
f0101853:	85 c0                	test   %eax,%eax
f0101855:	75 f7                	jne    f010184e <mem_init+0x652>
		--nfree;
	assert(nfree == 0);
f0101857:	85 db                	test   %ebx,%ebx
f0101859:	74 24                	je     f010187f <mem_init+0x683>
f010185b:	c7 44 24 0c c9 5d 10 	movl   $0xf0105dc9,0xc(%esp)
f0101862:	f0 
f0101863:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f010186a:	f0 
f010186b:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f0101872:	00 
f0101873:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f010187a:	e8 62 e8 ff ff       	call   f01000e1 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010187f:	c7 04 24 c0 60 10 f0 	movl   $0xf01060c0,(%esp)
f0101886:	e8 06 23 00 00       	call   f0103b91 <cprintf>

// check page_insert, page_remove, &c
static void
check_page(void)
{
	cprintf("check_page\r\n");
f010188b:	c7 04 24 d4 5d 10 f0 	movl   $0xf0105dd4,(%esp)
f0101892:	e8 fa 22 00 00       	call   f0103b91 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101897:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010189e:	e8 0e f6 ff ff       	call   f0100eb1 <page_alloc>
f01018a3:	89 c3                	mov    %eax,%ebx
f01018a5:	85 c0                	test   %eax,%eax
f01018a7:	75 24                	jne    f01018cd <mem_init+0x6d1>
f01018a9:	c7 44 24 0c d7 5c 10 	movl   $0xf0105cd7,0xc(%esp)
f01018b0:	f0 
f01018b1:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f01018b8:	f0 
f01018b9:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f01018c0:	00 
f01018c1:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01018c8:	e8 14 e8 ff ff       	call   f01000e1 <_panic>
	assert((pp1 = page_alloc(0)));
f01018cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018d4:	e8 d8 f5 ff ff       	call   f0100eb1 <page_alloc>
f01018d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018dc:	85 c0                	test   %eax,%eax
f01018de:	75 24                	jne    f0101904 <mem_init+0x708>
f01018e0:	c7 44 24 0c ed 5c 10 	movl   $0xf0105ced,0xc(%esp)
f01018e7:	f0 
f01018e8:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f01018ef:	f0 
f01018f0:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f01018f7:	00 
f01018f8:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01018ff:	e8 dd e7 ff ff       	call   f01000e1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101904:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010190b:	e8 a1 f5 ff ff       	call   f0100eb1 <page_alloc>
f0101910:	89 c6                	mov    %eax,%esi
f0101912:	85 c0                	test   %eax,%eax
f0101914:	75 24                	jne    f010193a <mem_init+0x73e>
f0101916:	c7 44 24 0c 03 5d 10 	movl   $0xf0105d03,0xc(%esp)
f010191d:	f0 
f010191e:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101925:	f0 
f0101926:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f010192d:	00 
f010192e:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101935:	e8 a7 e7 ff ff       	call   f01000e1 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010193a:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f010193d:	75 24                	jne    f0101963 <mem_init+0x767>
f010193f:	c7 44 24 0c 19 5d 10 	movl   $0xf0105d19,0xc(%esp)
f0101946:	f0 
f0101947:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f010194e:	f0 
f010194f:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0101956:	00 
f0101957:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f010195e:	e8 7e e7 ff ff       	call   f01000e1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101963:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101966:	74 04                	je     f010196c <mem_init+0x770>
f0101968:	39 c3                	cmp    %eax,%ebx
f010196a:	75 24                	jne    f0101990 <mem_init+0x794>
f010196c:	c7 44 24 0c a0 60 10 	movl   $0xf01060a0,0xc(%esp)
f0101973:	f0 
f0101974:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f010197b:	f0 
f010197c:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0101983:	00 
f0101984:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f010198b:	e8 51 e7 ff ff       	call   f01000e1 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101990:	a1 c0 e1 17 f0       	mov    0xf017e1c0,%eax
f0101995:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101998:	c7 05 c0 e1 17 f0 00 	movl   $0x0,0xf017e1c0
f010199f:	00 00 00 
	cprintf("1");
f01019a2:	c7 04 24 01 5e 10 f0 	movl   $0xf0105e01,(%esp)
f01019a9:	e8 e3 21 00 00       	call   f0103b91 <cprintf>
	// should be no free memory
	assert(!page_alloc(0));
f01019ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019b5:	e8 f7 f4 ff ff       	call   f0100eb1 <page_alloc>
f01019ba:	85 c0                	test   %eax,%eax
f01019bc:	74 24                	je     f01019e2 <mem_init+0x7e6>
f01019be:	c7 44 24 0c 82 5d 10 	movl   $0xf0105d82,0xc(%esp)
f01019c5:	f0 
f01019c6:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f01019cd:	f0 
f01019ce:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f01019d5:	00 
f01019d6:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01019dd:	e8 ff e6 ff ff       	call   f01000e1 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01019e2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01019e5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01019e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01019f0:	00 
f01019f1:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f01019f6:	89 04 24             	mov    %eax,(%esp)
f01019f9:	e8 80 f6 ff ff       	call   f010107e <page_lookup>
f01019fe:	85 c0                	test   %eax,%eax
f0101a00:	74 24                	je     f0101a26 <mem_init+0x82a>
f0101a02:	c7 44 24 0c e0 60 10 	movl   $0xf01060e0,0xc(%esp)
f0101a09:	f0 
f0101a0a:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101a11:	f0 
f0101a12:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0101a19:	00 
f0101a1a:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101a21:	e8 bb e6 ff ff       	call   f01000e1 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101a26:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101a2d:	00 
f0101a2e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101a35:	00 
f0101a36:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a3d:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0101a42:	89 04 24             	mov    %eax,(%esp)
f0101a45:	e8 f1 f6 ff ff       	call   f010113b <page_insert>
f0101a4a:	85 c0                	test   %eax,%eax
f0101a4c:	78 24                	js     f0101a72 <mem_init+0x876>
f0101a4e:	c7 44 24 0c 18 61 10 	movl   $0xf0106118,0xc(%esp)
f0101a55:	f0 
f0101a56:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101a5d:	f0 
f0101a5e:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f0101a65:	00 
f0101a66:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101a6d:	e8 6f e6 ff ff       	call   f01000e1 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101a72:	89 1c 24             	mov    %ebx,(%esp)
f0101a75:	e8 bc f4 ff ff       	call   f0100f36 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101a7a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101a81:	00 
f0101a82:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101a89:	00 
f0101a8a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a8d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a91:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0101a96:	89 04 24             	mov    %eax,(%esp)
f0101a99:	e8 9d f6 ff ff       	call   f010113b <page_insert>
f0101a9e:	85 c0                	test   %eax,%eax
f0101aa0:	74 24                	je     f0101ac6 <mem_init+0x8ca>
f0101aa2:	c7 44 24 0c 48 61 10 	movl   $0xf0106148,0xc(%esp)
f0101aa9:	f0 
f0101aaa:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101ab1:	f0 
f0101ab2:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f0101ab9:	00 
f0101aba:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101ac1:	e8 1b e6 ff ff       	call   f01000e1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ac6:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101acb:	8b 3d 8c ee 17 f0    	mov    0xf017ee8c,%edi
f0101ad1:	8b 08                	mov    (%eax),%ecx
f0101ad3:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101ad9:	89 da                	mov    %ebx,%edx
f0101adb:	29 fa                	sub    %edi,%edx
f0101add:	c1 fa 03             	sar    $0x3,%edx
f0101ae0:	c1 e2 0c             	shl    $0xc,%edx
f0101ae3:	39 d1                	cmp    %edx,%ecx
f0101ae5:	74 24                	je     f0101b0b <mem_init+0x90f>
f0101ae7:	c7 44 24 0c 78 61 10 	movl   $0xf0106178,0xc(%esp)
f0101aee:	f0 
f0101aef:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101af6:	f0 
f0101af7:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0101afe:	00 
f0101aff:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101b06:	e8 d6 e5 ff ff       	call   f01000e1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b0b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b10:	e8 97 ee ff ff       	call   f01009ac <check_va2pa>
f0101b15:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101b18:	29 fa                	sub    %edi,%edx
f0101b1a:	c1 fa 03             	sar    $0x3,%edx
f0101b1d:	c1 e2 0c             	shl    $0xc,%edx
f0101b20:	39 d0                	cmp    %edx,%eax
f0101b22:	74 24                	je     f0101b48 <mem_init+0x94c>
f0101b24:	c7 44 24 0c a0 61 10 	movl   $0xf01061a0,0xc(%esp)
f0101b2b:	f0 
f0101b2c:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101b33:	f0 
f0101b34:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0101b3b:	00 
f0101b3c:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101b43:	e8 99 e5 ff ff       	call   f01000e1 <_panic>
	assert(pp1->pp_ref == 1);
f0101b48:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b4b:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b50:	74 24                	je     f0101b76 <mem_init+0x97a>
f0101b52:	c7 44 24 0c e1 5d 10 	movl   $0xf0105de1,0xc(%esp)
f0101b59:	f0 
f0101b5a:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101b61:	f0 
f0101b62:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f0101b69:	00 
f0101b6a:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101b71:	e8 6b e5 ff ff       	call   f01000e1 <_panic>
	assert(pp0->pp_ref == 1);
f0101b76:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b7b:	74 24                	je     f0101ba1 <mem_init+0x9a5>
f0101b7d:	c7 44 24 0c f2 5d 10 	movl   $0xf0105df2,0xc(%esp)
f0101b84:	f0 
f0101b85:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101b8c:	f0 
f0101b8d:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f0101b94:	00 
f0101b95:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101b9c:	e8 40 e5 ff ff       	call   f01000e1 <_panic>
	cprintf("2");
f0101ba1:	c7 04 24 3d 5e 10 f0 	movl   $0xf0105e3d,(%esp)
f0101ba8:	e8 e4 1f 00 00       	call   f0103b91 <cprintf>
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bad:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101bb4:	00 
f0101bb5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101bbc:	00 
f0101bbd:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101bc1:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0101bc6:	89 04 24             	mov    %eax,(%esp)
f0101bc9:	e8 6d f5 ff ff       	call   f010113b <page_insert>
f0101bce:	85 c0                	test   %eax,%eax
f0101bd0:	74 24                	je     f0101bf6 <mem_init+0x9fa>
f0101bd2:	c7 44 24 0c d0 61 10 	movl   $0xf01061d0,0xc(%esp)
f0101bd9:	f0 
f0101bda:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101be1:	f0 
f0101be2:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0101be9:	00 
f0101bea:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101bf1:	e8 eb e4 ff ff       	call   f01000e1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bf6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bfb:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0101c00:	e8 a7 ed ff ff       	call   f01009ac <check_va2pa>
f0101c05:	89 f2                	mov    %esi,%edx
f0101c07:	2b 15 8c ee 17 f0    	sub    0xf017ee8c,%edx
f0101c0d:	c1 fa 03             	sar    $0x3,%edx
f0101c10:	c1 e2 0c             	shl    $0xc,%edx
f0101c13:	39 d0                	cmp    %edx,%eax
f0101c15:	74 24                	je     f0101c3b <mem_init+0xa3f>
f0101c17:	c7 44 24 0c 0c 62 10 	movl   $0xf010620c,0xc(%esp)
f0101c1e:	f0 
f0101c1f:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101c26:	f0 
f0101c27:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0101c2e:	00 
f0101c2f:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101c36:	e8 a6 e4 ff ff       	call   f01000e1 <_panic>
	assert(pp2->pp_ref == 1);
f0101c3b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c40:	74 24                	je     f0101c66 <mem_init+0xa6a>
f0101c42:	c7 44 24 0c 03 5e 10 	movl   $0xf0105e03,0xc(%esp)
f0101c49:	f0 
f0101c4a:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101c51:	f0 
f0101c52:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0101c59:	00 
f0101c5a:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101c61:	e8 7b e4 ff ff       	call   f01000e1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101c66:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c6d:	e8 3f f2 ff ff       	call   f0100eb1 <page_alloc>
f0101c72:	85 c0                	test   %eax,%eax
f0101c74:	74 24                	je     f0101c9a <mem_init+0xa9e>
f0101c76:	c7 44 24 0c 82 5d 10 	movl   $0xf0105d82,0xc(%esp)
f0101c7d:	f0 
f0101c7e:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101c85:	f0 
f0101c86:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f0101c8d:	00 
f0101c8e:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101c95:	e8 47 e4 ff ff       	call   f01000e1 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c9a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ca1:	00 
f0101ca2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ca9:	00 
f0101caa:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101cae:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0101cb3:	89 04 24             	mov    %eax,(%esp)
f0101cb6:	e8 80 f4 ff ff       	call   f010113b <page_insert>
f0101cbb:	85 c0                	test   %eax,%eax
f0101cbd:	74 24                	je     f0101ce3 <mem_init+0xae7>
f0101cbf:	c7 44 24 0c d0 61 10 	movl   $0xf01061d0,0xc(%esp)
f0101cc6:	f0 
f0101cc7:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101cce:	f0 
f0101ccf:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0101cd6:	00 
f0101cd7:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101cde:	e8 fe e3 ff ff       	call   f01000e1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ce3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ce8:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0101ced:	e8 ba ec ff ff       	call   f01009ac <check_va2pa>
f0101cf2:	89 f2                	mov    %esi,%edx
f0101cf4:	2b 15 8c ee 17 f0    	sub    0xf017ee8c,%edx
f0101cfa:	c1 fa 03             	sar    $0x3,%edx
f0101cfd:	c1 e2 0c             	shl    $0xc,%edx
f0101d00:	39 d0                	cmp    %edx,%eax
f0101d02:	74 24                	je     f0101d28 <mem_init+0xb2c>
f0101d04:	c7 44 24 0c 0c 62 10 	movl   $0xf010620c,0xc(%esp)
f0101d0b:	f0 
f0101d0c:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101d13:	f0 
f0101d14:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101d1b:	00 
f0101d1c:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101d23:	e8 b9 e3 ff ff       	call   f01000e1 <_panic>
	assert(pp2->pp_ref == 1);
f0101d28:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d2d:	74 24                	je     f0101d53 <mem_init+0xb57>
f0101d2f:	c7 44 24 0c 03 5e 10 	movl   $0xf0105e03,0xc(%esp)
f0101d36:	f0 
f0101d37:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101d3e:	f0 
f0101d3f:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0101d46:	00 
f0101d47:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101d4e:	e8 8e e3 ff ff       	call   f01000e1 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101d53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d5a:	e8 52 f1 ff ff       	call   f0100eb1 <page_alloc>
f0101d5f:	85 c0                	test   %eax,%eax
f0101d61:	74 24                	je     f0101d87 <mem_init+0xb8b>
f0101d63:	c7 44 24 0c 82 5d 10 	movl   $0xf0105d82,0xc(%esp)
f0101d6a:	f0 
f0101d6b:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101d72:	f0 
f0101d73:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f0101d7a:	00 
f0101d7b:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101d82:	e8 5a e3 ff ff       	call   f01000e1 <_panic>
	cprintf("3");
f0101d87:	c7 04 24 14 5e 10 f0 	movl   $0xf0105e14,(%esp)
f0101d8e:	e8 fe 1d 00 00       	call   f0103b91 <cprintf>
	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101d93:	8b 15 88 ee 17 f0    	mov    0xf017ee88,%edx
f0101d99:	8b 02                	mov    (%edx),%eax
f0101d9b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101da0:	89 c1                	mov    %eax,%ecx
f0101da2:	c1 e9 0c             	shr    $0xc,%ecx
f0101da5:	3b 0d 84 ee 17 f0    	cmp    0xf017ee84,%ecx
f0101dab:	72 20                	jb     f0101dcd <mem_init+0xbd1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101dad:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101db1:	c7 44 24 08 38 5f 10 	movl   $0xf0105f38,0x8(%esp)
f0101db8:	f0 
f0101db9:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0101dc0:	00 
f0101dc1:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101dc8:	e8 14 e3 ff ff       	call   f01000e1 <_panic>
	return (void *)(pa + KERNBASE);
f0101dcd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101dd2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101dd5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ddc:	00 
f0101ddd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101de4:	00 
f0101de5:	89 14 24             	mov    %edx,(%esp)
f0101de8:	e8 87 f1 ff ff       	call   f0100f74 <pgdir_walk>
f0101ded:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101df0:	8d 57 04             	lea    0x4(%edi),%edx
f0101df3:	39 d0                	cmp    %edx,%eax
f0101df5:	74 24                	je     f0101e1b <mem_init+0xc1f>
f0101df7:	c7 44 24 0c 3c 62 10 	movl   $0xf010623c,0xc(%esp)
f0101dfe:	f0 
f0101dff:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101e06:	f0 
f0101e07:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0101e0e:	00 
f0101e0f:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101e16:	e8 c6 e2 ff ff       	call   f01000e1 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101e1b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101e22:	00 
f0101e23:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e2a:	00 
f0101e2b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e2f:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0101e34:	89 04 24             	mov    %eax,(%esp)
f0101e37:	e8 ff f2 ff ff       	call   f010113b <page_insert>
f0101e3c:	85 c0                	test   %eax,%eax
f0101e3e:	74 24                	je     f0101e64 <mem_init+0xc68>
f0101e40:	c7 44 24 0c 7c 62 10 	movl   $0xf010627c,0xc(%esp)
f0101e47:	f0 
f0101e48:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101e4f:	f0 
f0101e50:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101e57:	00 
f0101e58:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101e5f:	e8 7d e2 ff ff       	call   f01000e1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e64:	8b 3d 88 ee 17 f0    	mov    0xf017ee88,%edi
f0101e6a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e6f:	89 f8                	mov    %edi,%eax
f0101e71:	e8 36 eb ff ff       	call   f01009ac <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101e76:	89 f2                	mov    %esi,%edx
f0101e78:	2b 15 8c ee 17 f0    	sub    0xf017ee8c,%edx
f0101e7e:	c1 fa 03             	sar    $0x3,%edx
f0101e81:	c1 e2 0c             	shl    $0xc,%edx
f0101e84:	39 d0                	cmp    %edx,%eax
f0101e86:	74 24                	je     f0101eac <mem_init+0xcb0>
f0101e88:	c7 44 24 0c 0c 62 10 	movl   $0xf010620c,0xc(%esp)
f0101e8f:	f0 
f0101e90:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101e97:	f0 
f0101e98:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f0101e9f:	00 
f0101ea0:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101ea7:	e8 35 e2 ff ff       	call   f01000e1 <_panic>
	assert(pp2->pp_ref == 1);
f0101eac:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101eb1:	74 24                	je     f0101ed7 <mem_init+0xcdb>
f0101eb3:	c7 44 24 0c 03 5e 10 	movl   $0xf0105e03,0xc(%esp)
f0101eba:	f0 
f0101ebb:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101ec2:	f0 
f0101ec3:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f0101eca:	00 
f0101ecb:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101ed2:	e8 0a e2 ff ff       	call   f01000e1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101ed7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ede:	00 
f0101edf:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ee6:	00 
f0101ee7:	89 3c 24             	mov    %edi,(%esp)
f0101eea:	e8 85 f0 ff ff       	call   f0100f74 <pgdir_walk>
f0101eef:	f6 00 04             	testb  $0x4,(%eax)
f0101ef2:	75 24                	jne    f0101f18 <mem_init+0xd1c>
f0101ef4:	c7 44 24 0c bc 62 10 	movl   $0xf01062bc,0xc(%esp)
f0101efb:	f0 
f0101efc:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101f03:	f0 
f0101f04:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0101f0b:	00 
f0101f0c:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101f13:	e8 c9 e1 ff ff       	call   f01000e1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101f18:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0101f1d:	f6 00 04             	testb  $0x4,(%eax)
f0101f20:	75 24                	jne    f0101f46 <mem_init+0xd4a>
f0101f22:	c7 44 24 0c 16 5e 10 	movl   $0xf0105e16,0xc(%esp)
f0101f29:	f0 
f0101f2a:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101f31:	f0 
f0101f32:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101f39:	00 
f0101f3a:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101f41:	e8 9b e1 ff ff       	call   f01000e1 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f46:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f4d:	00 
f0101f4e:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101f55:	00 
f0101f56:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f5a:	89 04 24             	mov    %eax,(%esp)
f0101f5d:	e8 d9 f1 ff ff       	call   f010113b <page_insert>
f0101f62:	85 c0                	test   %eax,%eax
f0101f64:	78 24                	js     f0101f8a <mem_init+0xd8e>
f0101f66:	c7 44 24 0c f0 62 10 	movl   $0xf01062f0,0xc(%esp)
f0101f6d:	f0 
f0101f6e:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101f75:	f0 
f0101f76:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0101f7d:	00 
f0101f7e:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101f85:	e8 57 e1 ff ff       	call   f01000e1 <_panic>
	cprintf("4");
f0101f8a:	c7 04 24 2c 5e 10 f0 	movl   $0xf0105e2c,(%esp)
f0101f91:	e8 fb 1b 00 00       	call   f0103b91 <cprintf>
	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f96:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f9d:	00 
f0101f9e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101fa5:	00 
f0101fa6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fa9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101fad:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0101fb2:	89 04 24             	mov    %eax,(%esp)
f0101fb5:	e8 81 f1 ff ff       	call   f010113b <page_insert>
f0101fba:	85 c0                	test   %eax,%eax
f0101fbc:	74 24                	je     f0101fe2 <mem_init+0xde6>
f0101fbe:	c7 44 24 0c 28 63 10 	movl   $0xf0106328,0xc(%esp)
f0101fc5:	f0 
f0101fc6:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0101fcd:	f0 
f0101fce:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f0101fd5:	00 
f0101fd6:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0101fdd:	e8 ff e0 ff ff       	call   f01000e1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101fe2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fe9:	00 
f0101fea:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ff1:	00 
f0101ff2:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0101ff7:	89 04 24             	mov    %eax,(%esp)
f0101ffa:	e8 75 ef ff ff       	call   f0100f74 <pgdir_walk>
f0101fff:	f6 00 04             	testb  $0x4,(%eax)
f0102002:	74 24                	je     f0102028 <mem_init+0xe2c>
f0102004:	c7 44 24 0c 64 63 10 	movl   $0xf0106364,0xc(%esp)
f010200b:	f0 
f010200c:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102013:	f0 
f0102014:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f010201b:	00 
f010201c:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102023:	e8 b9 e0 ff ff       	call   f01000e1 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102028:	8b 3d 88 ee 17 f0    	mov    0xf017ee88,%edi
f010202e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102033:	89 f8                	mov    %edi,%eax
f0102035:	e8 72 e9 ff ff       	call   f01009ac <check_va2pa>
f010203a:	89 c1                	mov    %eax,%ecx
f010203c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010203f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102042:	2b 05 8c ee 17 f0    	sub    0xf017ee8c,%eax
f0102048:	c1 f8 03             	sar    $0x3,%eax
f010204b:	c1 e0 0c             	shl    $0xc,%eax
f010204e:	39 c1                	cmp    %eax,%ecx
f0102050:	74 24                	je     f0102076 <mem_init+0xe7a>
f0102052:	c7 44 24 0c 9c 63 10 	movl   $0xf010639c,0xc(%esp)
f0102059:	f0 
f010205a:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102061:	f0 
f0102062:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0102069:	00 
f010206a:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102071:	e8 6b e0 ff ff       	call   f01000e1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102076:	ba 00 10 00 00       	mov    $0x1000,%edx
f010207b:	89 f8                	mov    %edi,%eax
f010207d:	e8 2a e9 ff ff       	call   f01009ac <check_va2pa>
f0102082:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102085:	74 24                	je     f01020ab <mem_init+0xeaf>
f0102087:	c7 44 24 0c c8 63 10 	movl   $0xf01063c8,0xc(%esp)
f010208e:	f0 
f010208f:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102096:	f0 
f0102097:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f010209e:	00 
f010209f:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01020a6:	e8 36 e0 ff ff       	call   f01000e1 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01020ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020ae:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f01020b3:	74 24                	je     f01020d9 <mem_init+0xedd>
f01020b5:	c7 44 24 0c 2e 5e 10 	movl   $0xf0105e2e,0xc(%esp)
f01020bc:	f0 
f01020bd:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f01020c4:	f0 
f01020c5:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f01020cc:	00 
f01020cd:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01020d4:	e8 08 e0 ff ff       	call   f01000e1 <_panic>
	assert(pp2->pp_ref == 0);
f01020d9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01020de:	74 24                	je     f0102104 <mem_init+0xf08>
f01020e0:	c7 44 24 0c 3f 5e 10 	movl   $0xf0105e3f,0xc(%esp)
f01020e7:	f0 
f01020e8:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f01020ef:	f0 
f01020f0:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f01020f7:	00 
f01020f8:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01020ff:	e8 dd df ff ff       	call   f01000e1 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102104:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010210b:	e8 a1 ed ff ff       	call   f0100eb1 <page_alloc>
f0102110:	85 c0                	test   %eax,%eax
f0102112:	74 04                	je     f0102118 <mem_init+0xf1c>
f0102114:	39 c6                	cmp    %eax,%esi
f0102116:	74 24                	je     f010213c <mem_init+0xf40>
f0102118:	c7 44 24 0c f8 63 10 	movl   $0xf01063f8,0xc(%esp)
f010211f:	f0 
f0102120:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102127:	f0 
f0102128:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f010212f:	00 
f0102130:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102137:	e8 a5 df ff ff       	call   f01000e1 <_panic>
	cprintf("5");
f010213c:	c7 04 24 50 5e 10 f0 	movl   $0xf0105e50,(%esp)
f0102143:	e8 49 1a 00 00       	call   f0103b91 <cprintf>
	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102148:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010214f:	00 
f0102150:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0102155:	89 04 24             	mov    %eax,(%esp)
f0102158:	e8 99 ef ff ff       	call   f01010f6 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010215d:	8b 3d 88 ee 17 f0    	mov    0xf017ee88,%edi
f0102163:	ba 00 00 00 00       	mov    $0x0,%edx
f0102168:	89 f8                	mov    %edi,%eax
f010216a:	e8 3d e8 ff ff       	call   f01009ac <check_va2pa>
f010216f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102172:	74 24                	je     f0102198 <mem_init+0xf9c>
f0102174:	c7 44 24 0c 1c 64 10 	movl   $0xf010641c,0xc(%esp)
f010217b:	f0 
f010217c:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102183:	f0 
f0102184:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f010218b:	00 
f010218c:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102193:	e8 49 df ff ff       	call   f01000e1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102198:	ba 00 10 00 00       	mov    $0x1000,%edx
f010219d:	89 f8                	mov    %edi,%eax
f010219f:	e8 08 e8 ff ff       	call   f01009ac <check_va2pa>
f01021a4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01021a7:	2b 15 8c ee 17 f0    	sub    0xf017ee8c,%edx
f01021ad:	c1 fa 03             	sar    $0x3,%edx
f01021b0:	c1 e2 0c             	shl    $0xc,%edx
f01021b3:	39 d0                	cmp    %edx,%eax
f01021b5:	74 24                	je     f01021db <mem_init+0xfdf>
f01021b7:	c7 44 24 0c c8 63 10 	movl   $0xf01063c8,0xc(%esp)
f01021be:	f0 
f01021bf:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f01021c6:	f0 
f01021c7:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f01021ce:	00 
f01021cf:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01021d6:	e8 06 df ff ff       	call   f01000e1 <_panic>
	assert(pp1->pp_ref == 1);
f01021db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021de:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01021e3:	74 24                	je     f0102209 <mem_init+0x100d>
f01021e5:	c7 44 24 0c e1 5d 10 	movl   $0xf0105de1,0xc(%esp)
f01021ec:	f0 
f01021ed:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f01021f4:	f0 
f01021f5:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f01021fc:	00 
f01021fd:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102204:	e8 d8 de ff ff       	call   f01000e1 <_panic>
	assert(pp2->pp_ref == 0);
f0102209:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010220e:	74 24                	je     f0102234 <mem_init+0x1038>
f0102210:	c7 44 24 0c 3f 5e 10 	movl   $0xf0105e3f,0xc(%esp)
f0102217:	f0 
f0102218:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f010221f:	f0 
f0102220:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0102227:	00 
f0102228:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f010222f:	e8 ad de ff ff       	call   f01000e1 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102234:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010223b:	00 
f010223c:	89 3c 24             	mov    %edi,(%esp)
f010223f:	e8 b2 ee ff ff       	call   f01010f6 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102244:	8b 3d 88 ee 17 f0    	mov    0xf017ee88,%edi
f010224a:	ba 00 00 00 00       	mov    $0x0,%edx
f010224f:	89 f8                	mov    %edi,%eax
f0102251:	e8 56 e7 ff ff       	call   f01009ac <check_va2pa>
f0102256:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102259:	74 24                	je     f010227f <mem_init+0x1083>
f010225b:	c7 44 24 0c 1c 64 10 	movl   $0xf010641c,0xc(%esp)
f0102262:	f0 
f0102263:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f010226a:	f0 
f010226b:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0102272:	00 
f0102273:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f010227a:	e8 62 de ff ff       	call   f01000e1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010227f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102284:	89 f8                	mov    %edi,%eax
f0102286:	e8 21 e7 ff ff       	call   f01009ac <check_va2pa>
f010228b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010228e:	74 24                	je     f01022b4 <mem_init+0x10b8>
f0102290:	c7 44 24 0c 40 64 10 	movl   $0xf0106440,0xc(%esp)
f0102297:	f0 
f0102298:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f010229f:	f0 
f01022a0:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f01022a7:	00 
f01022a8:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01022af:	e8 2d de ff ff       	call   f01000e1 <_panic>
	assert(pp1->pp_ref == 0);
f01022b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022b7:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01022bc:	74 24                	je     f01022e2 <mem_init+0x10e6>
f01022be:	c7 44 24 0c 52 5e 10 	movl   $0xf0105e52,0xc(%esp)
f01022c5:	f0 
f01022c6:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f01022cd:	f0 
f01022ce:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f01022d5:	00 
f01022d6:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01022dd:	e8 ff dd ff ff       	call   f01000e1 <_panic>
	assert(pp2->pp_ref == 0);
f01022e2:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022e7:	74 24                	je     f010230d <mem_init+0x1111>
f01022e9:	c7 44 24 0c 3f 5e 10 	movl   $0xf0105e3f,0xc(%esp)
f01022f0:	f0 
f01022f1:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f01022f8:	f0 
f01022f9:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0102300:	00 
f0102301:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102308:	e8 d4 dd ff ff       	call   f01000e1 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010230d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102314:	e8 98 eb ff ff       	call   f0100eb1 <page_alloc>
f0102319:	85 c0                	test   %eax,%eax
f010231b:	74 05                	je     f0102322 <mem_init+0x1126>
f010231d:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0102320:	74 24                	je     f0102346 <mem_init+0x114a>
f0102322:	c7 44 24 0c 68 64 10 	movl   $0xf0106468,0xc(%esp)
f0102329:	f0 
f010232a:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102331:	f0 
f0102332:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0102339:	00 
f010233a:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102341:	e8 9b dd ff ff       	call   f01000e1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102346:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010234d:	e8 5f eb ff ff       	call   f0100eb1 <page_alloc>
f0102352:	85 c0                	test   %eax,%eax
f0102354:	74 24                	je     f010237a <mem_init+0x117e>
f0102356:	c7 44 24 0c 82 5d 10 	movl   $0xf0105d82,0xc(%esp)
f010235d:	f0 
f010235e:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102365:	f0 
f0102366:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f010236d:	00 
f010236e:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102375:	e8 67 dd ff ff       	call   f01000e1 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010237a:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f010237f:	8b 08                	mov    (%eax),%ecx
f0102381:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102387:	89 da                	mov    %ebx,%edx
f0102389:	2b 15 8c ee 17 f0    	sub    0xf017ee8c,%edx
f010238f:	c1 fa 03             	sar    $0x3,%edx
f0102392:	c1 e2 0c             	shl    $0xc,%edx
f0102395:	39 d1                	cmp    %edx,%ecx
f0102397:	74 24                	je     f01023bd <mem_init+0x11c1>
f0102399:	c7 44 24 0c 78 61 10 	movl   $0xf0106178,0xc(%esp)
f01023a0:	f0 
f01023a1:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f01023a8:	f0 
f01023a9:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f01023b0:	00 
f01023b1:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01023b8:	e8 24 dd ff ff       	call   f01000e1 <_panic>
	kern_pgdir[0] = 0;
f01023bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01023c3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01023c8:	74 24                	je     f01023ee <mem_init+0x11f2>
f01023ca:	c7 44 24 0c f2 5d 10 	movl   $0xf0105df2,0xc(%esp)
f01023d1:	f0 
f01023d2:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f01023d9:	f0 
f01023da:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f01023e1:	00 
f01023e2:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01023e9:	e8 f3 dc ff ff       	call   f01000e1 <_panic>
	pp0->pp_ref = 0;
f01023ee:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	cprintf("6");
f01023f4:	c7 04 24 63 5e 10 f0 	movl   $0xf0105e63,(%esp)
f01023fb:	e8 91 17 00 00       	call   f0103b91 <cprintf>
	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102400:	89 1c 24             	mov    %ebx,(%esp)
f0102403:	e8 2e eb ff ff       	call   f0100f36 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102408:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010240f:	00 
f0102410:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102417:	00 
f0102418:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f010241d:	89 04 24             	mov    %eax,(%esp)
f0102420:	e8 4f eb ff ff       	call   f0100f74 <pgdir_walk>
f0102425:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102428:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010242b:	8b 15 88 ee 17 f0    	mov    0xf017ee88,%edx
f0102431:	8b 7a 04             	mov    0x4(%edx),%edi
f0102434:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010243a:	8b 0d 84 ee 17 f0    	mov    0xf017ee84,%ecx
f0102440:	89 f8                	mov    %edi,%eax
f0102442:	c1 e8 0c             	shr    $0xc,%eax
f0102445:	39 c8                	cmp    %ecx,%eax
f0102447:	72 20                	jb     f0102469 <mem_init+0x126d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102449:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010244d:	c7 44 24 08 38 5f 10 	movl   $0xf0105f38,0x8(%esp)
f0102454:	f0 
f0102455:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f010245c:	00 
f010245d:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102464:	e8 78 dc ff ff       	call   f01000e1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102469:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f010246f:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0102472:	74 24                	je     f0102498 <mem_init+0x129c>
f0102474:	c7 44 24 0c 65 5e 10 	movl   $0xf0105e65,0xc(%esp)
f010247b:	f0 
f010247c:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102483:	f0 
f0102484:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f010248b:	00 
f010248c:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102493:	e8 49 dc ff ff       	call   f01000e1 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102498:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f010249f:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01024a5:	89 d8                	mov    %ebx,%eax
f01024a7:	2b 05 8c ee 17 f0    	sub    0xf017ee8c,%eax
f01024ad:	c1 f8 03             	sar    $0x3,%eax
f01024b0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024b3:	89 c2                	mov    %eax,%edx
f01024b5:	c1 ea 0c             	shr    $0xc,%edx
f01024b8:	39 d1                	cmp    %edx,%ecx
f01024ba:	77 20                	ja     f01024dc <mem_init+0x12e0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01024c0:	c7 44 24 08 38 5f 10 	movl   $0xf0105f38,0x8(%esp)
f01024c7:	f0 
f01024c8:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01024cf:	00 
f01024d0:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f01024d7:	e8 05 dc ff ff       	call   f01000e1 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01024dc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024e3:	00 
f01024e4:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01024eb:	00 
	return (void *)(pa + KERNBASE);
f01024ec:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024f1:	89 04 24             	mov    %eax,(%esp)
f01024f4:	e8 c0 2c 00 00       	call   f01051b9 <memset>
	page_free(pp0);
f01024f9:	89 1c 24             	mov    %ebx,(%esp)
f01024fc:	e8 35 ea ff ff       	call   f0100f36 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102501:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102508:	00 
f0102509:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102510:	00 
f0102511:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0102516:	89 04 24             	mov    %eax,(%esp)
f0102519:	e8 56 ea ff ff       	call   f0100f74 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010251e:	89 da                	mov    %ebx,%edx
f0102520:	2b 15 8c ee 17 f0    	sub    0xf017ee8c,%edx
f0102526:	c1 fa 03             	sar    $0x3,%edx
f0102529:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010252c:	89 d0                	mov    %edx,%eax
f010252e:	c1 e8 0c             	shr    $0xc,%eax
f0102531:	3b 05 84 ee 17 f0    	cmp    0xf017ee84,%eax
f0102537:	72 20                	jb     f0102559 <mem_init+0x135d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102539:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010253d:	c7 44 24 08 38 5f 10 	movl   $0xf0105f38,0x8(%esp)
f0102544:	f0 
f0102545:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010254c:	00 
f010254d:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f0102554:	e8 88 db ff ff       	call   f01000e1 <_panic>
	return (void *)(pa + KERNBASE);
f0102559:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010255f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102562:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102569:	75 11                	jne    f010257c <mem_init+0x1380>
f010256b:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
f0102571:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f0102577:	f6 00 01             	testb  $0x1,(%eax)
f010257a:	74 24                	je     f01025a0 <mem_init+0x13a4>
f010257c:	c7 44 24 0c 7d 5e 10 	movl   $0xf0105e7d,0xc(%esp)
f0102583:	f0 
f0102584:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f010258b:	f0 
f010258c:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f0102593:	00 
f0102594:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f010259b:	e8 41 db ff ff       	call   f01000e1 <_panic>
f01025a0:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01025a3:	39 d0                	cmp    %edx,%eax
f01025a5:	75 d0                	jne    f0102577 <mem_init+0x137b>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01025a7:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f01025ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025b2:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	cprintf("7");
f01025b8:	c7 04 24 94 5e 10 f0 	movl   $0xf0105e94,(%esp)
f01025bf:	e8 cd 15 00 00       	call   f0103b91 <cprintf>
	// give free list back
	page_free_list = fl;
f01025c4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01025c7:	a3 c0 e1 17 f0       	mov    %eax,0xf017e1c0

	// free the pages we took
	page_free(pp0);
f01025cc:	89 1c 24             	mov    %ebx,(%esp)
f01025cf:	e8 62 e9 ff ff       	call   f0100f36 <page_free>
	page_free(pp1);
f01025d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025d7:	89 04 24             	mov    %eax,(%esp)
f01025da:	e8 57 e9 ff ff       	call   f0100f36 <page_free>
	page_free(pp2);
f01025df:	89 34 24             	mov    %esi,(%esp)
f01025e2:	e8 4f e9 ff ff       	call   f0100f36 <page_free>

	cprintf("check_page() succeeded!\n");
f01025e7:	c7 04 24 96 5e 10 f0 	movl   $0xf0105e96,(%esp)
f01025ee:	e8 9e 15 00 00       	call   f0103b91 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	for(i=0;i<ROUNDUP(npages*sizeof(struct Page),PGSIZE);i+=PGSIZE)
f01025f3:	8b 0d 84 ee 17 f0    	mov    0xf017ee84,%ecx
f01025f9:	8d 04 cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%eax
f0102600:	89 c2                	mov    %eax,%edx
f0102602:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f0102608:	39 d0                	cmp    %edx,%eax
f010260a:	0f 84 7c 0a 00 00    	je     f010308c <mem_init+0x1e90>
	{

		page_insert(kern_pgdir, pa2page(PADDR(pages)+i),(void*) (UPAGES+i), PTE_U);
f0102610:	a1 8c ee 17 f0       	mov    0xf017ee8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102615:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010261a:	76 21                	jbe    f010263d <mem_init+0x1441>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f010261c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102622:	c1 ea 0c             	shr    $0xc,%edx
f0102625:	39 d1                	cmp    %edx,%ecx
f0102627:	77 5e                	ja     f0102687 <mem_init+0x148b>
f0102629:	eb 40                	jmp    f010266b <mem_init+0x146f>
f010262b:	8d b3 00 00 00 ef    	lea    -0x11000000(%ebx),%esi
f0102631:	a1 8c ee 17 f0       	mov    0xf017ee8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102636:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010263b:	77 20                	ja     f010265d <mem_init+0x1461>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010263d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102641:	c7 44 24 08 7c 60 10 	movl   $0xf010607c,0x8(%esp)
f0102648:	f0 
f0102649:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
f0102650:	00 
f0102651:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102658:	e8 84 da ff ff       	call   f01000e1 <_panic>
f010265d:	8d 94 10 00 00 00 10 	lea    0x10000000(%eax,%edx,1),%edx
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102664:	c1 ea 0c             	shr    $0xc,%edx
f0102667:	39 d1                	cmp    %edx,%ecx
f0102669:	77 26                	ja     f0102691 <mem_init+0x1495>
		panic("pa2page called with invalid pa");
f010266b:	c7 44 24 08 20 60 10 	movl   $0xf0106020,0x8(%esp)
f0102672:	f0 
f0102673:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010267a:	00 
f010267b:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f0102682:	e8 5a da ff ff       	call   f01000e1 <_panic>
f0102687:	be 00 00 00 ef       	mov    $0xef000000,%esi
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	for(i=0;i<ROUNDUP(npages*sizeof(struct Page),PGSIZE);i+=PGSIZE)
f010268c:	bb 00 00 00 00       	mov    $0x0,%ebx
	{

		page_insert(kern_pgdir, pa2page(PADDR(pages)+i),(void*) (UPAGES+i), PTE_U);
f0102691:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0102698:	00 
f0102699:	89 74 24 08          	mov    %esi,0x8(%esp)
	return &pages[PGNUM(pa)];
f010269d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01026a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01026a4:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f01026a9:	89 04 24             	mov    %eax,(%esp)
f01026ac:	e8 8a ea ff ff       	call   f010113b <page_insert>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	for(i=0;i<ROUNDUP(npages*sizeof(struct Page),PGSIZE);i+=PGSIZE)
f01026b1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01026b7:	89 da                	mov    %ebx,%edx
f01026b9:	8b 0d 84 ee 17 f0    	mov    0xf017ee84,%ecx
f01026bf:	8d 04 cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%eax
f01026c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01026cb:	39 c3                	cmp    %eax,%ebx
f01026cd:	0f 82 58 ff ff ff    	jb     f010262b <mem_init+0x142f>
f01026d3:	e9 b4 09 00 00       	jmp    f010308c <mem_init+0x1e90>
static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f01026d8:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026dd:	c1 e8 0c             	shr    $0xc,%eax
f01026e0:	39 05 84 ee 17 f0    	cmp    %eax,0xf017ee84
f01026e6:	0f 87 67 0a 00 00    	ja     f0103153 <mem_init+0x1f57>
f01026ec:	eb 44                	jmp    f0102732 <mem_init+0x1536>
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	   for(i=0;i<ROUNDUP(NENV*sizeof(struct Env),PGSIZE);i+=PGSIZE)
		{
		 //  cprintf("map a UENVS pages");
		page_insert(kern_pgdir, pa2page(PADDR(envs)+i),(void*) (UENVS+i), PTE_U);
f01026ee:	8d 8a 00 00 c0 ee    	lea    -0x11400000(%edx),%ecx
f01026f4:	a1 cc e1 17 f0       	mov    0xf017e1cc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026f9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026fe:	77 20                	ja     f0102720 <mem_init+0x1524>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102700:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102704:	c7 44 24 08 7c 60 10 	movl   $0xf010607c,0x8(%esp)
f010270b:	f0 
f010270c:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f0102713:	00 
f0102714:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f010271b:	e8 c1 d9 ff ff       	call   f01000e1 <_panic>
f0102720:	8d 84 10 00 00 00 10 	lea    0x10000000(%eax,%edx,1),%eax
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102727:	c1 e8 0c             	shr    $0xc,%eax
f010272a:	3b 05 84 ee 17 f0    	cmp    0xf017ee84,%eax
f0102730:	72 1c                	jb     f010274e <mem_init+0x1552>
		panic("pa2page called with invalid pa");
f0102732:	c7 44 24 08 20 60 10 	movl   $0xf0106020,0x8(%esp)
f0102739:	f0 
f010273a:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0102741:	00 
f0102742:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f0102749:	e8 93 d9 ff ff       	call   f01000e1 <_panic>
f010274e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0102755:	00 
f0102756:	89 4c 24 08          	mov    %ecx,0x8(%esp)
	return &pages[PGNUM(pa)];
f010275a:	8b 15 8c ee 17 f0    	mov    0xf017ee8c,%edx
f0102760:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102763:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102767:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f010276c:	89 04 24             	mov    %eax,(%esp)
f010276f:	e8 c7 e9 ff ff       	call   f010113b <page_insert>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	   for(i=0;i<ROUNDUP(NENV*sizeof(struct Env),PGSIZE);i+=PGSIZE)
f0102774:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010277a:	89 da                	mov    %ebx,%edx
f010277c:	81 fb 00 80 01 00    	cmp    $0x18000,%ebx
f0102782:	0f 85 66 ff ff ff    	jne    f01026ee <mem_init+0x14f2>
f0102788:	e9 39 09 00 00       	jmp    f01030c6 <mem_init+0x1eca>
static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f010278d:	b8 00 20 11 00       	mov    $0x112000,%eax
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102792:	c1 e8 0c             	shr    $0xc,%eax
f0102795:	3b 05 84 ee 17 f0    	cmp    0xf017ee84,%eax
f010279b:	0f 82 6e 09 00 00    	jb     f010310f <mem_init+0x1f13>
f01027a1:	eb 36                	jmp    f01027d9 <mem_init+0x15dd>
f01027a3:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f01027a6:	89 d8                	mov    %ebx,%eax
f01027a8:	c1 e8 0c             	shr    $0xc,%eax
f01027ab:	3b 05 84 ee 17 f0    	cmp    0xf017ee84,%eax
f01027b1:	72 42                	jb     f01027f5 <mem_init+0x15f9>
f01027b3:	eb 24                	jmp    f01027d9 <mem_init+0x15dd>

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027b5:	c7 44 24 0c 00 20 11 	movl   $0xf0112000,0xc(%esp)
f01027bc:	f0 
f01027bd:	c7 44 24 08 7c 60 10 	movl   $0xf010607c,0x8(%esp)
f01027c4:	f0 
f01027c5:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
f01027cc:	00 
f01027cd:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f01027d4:	e8 08 d9 ff ff       	call   f01000e1 <_panic>

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		panic("pa2page called with invalid pa");
f01027d9:	c7 44 24 08 20 60 10 	movl   $0xf0106020,0x8(%esp)
f01027e0:	f0 
f01027e1:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01027e8:	00 
f01027e9:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f01027f0:	e8 ec d8 ff ff       	call   f01000e1 <_panic>
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	//cprintf("%x,%x \r\n",bootstack,bootstacktop);
	for(i=0;i<KSTKSIZE;i+=PGSIZE)
	{
		page_insert(kern_pgdir,pa2page(PADDR(bootstack)+i),(void*)(KSTACKTOP-KSTKSIZE+i),PTE_W);
f01027f5:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01027fc:	00 
f01027fd:	89 54 24 08          	mov    %edx,0x8(%esp)
	return &pages[PGNUM(pa)];
f0102801:	8b 15 8c ee 17 f0    	mov    0xf017ee8c,%edx
f0102807:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010280a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010280e:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0102813:	89 04 24             	mov    %eax,(%esp)
f0102816:	e8 20 e9 ff ff       	call   f010113b <page_insert>
f010281b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	//cprintf("%x,%x \r\n",bootstack,bootstacktop);
	for(i=0;i<KSTKSIZE;i+=PGSIZE)
f0102821:	39 fb                	cmp    %edi,%ebx
f0102823:	0f 85 7a ff ff ff    	jne    f01027a3 <mem_init+0x15a7>
f0102829:	e9 ad 08 00 00       	jmp    f01030db <mem_init+0x1edf>
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    for(i=0;i<0xffffffff-KERNBASE;i+=PGSIZE)
    {
    	if(i<npages*PGSIZE)
f010282e:	a1 84 ee 17 f0       	mov    0xf017ee84,%eax
f0102833:	89 c2                	mov    %eax,%edx
f0102835:	c1 e2 0c             	shl    $0xc,%edx
f0102838:	39 f2                	cmp    %esi,%edx
f010283a:	0f 86 86 00 00 00    	jbe    f01028c6 <mem_init+0x16ca>
    	{
    		page_insert(kern_pgdir,pa2page(i),(void*)(KERNBASE+i),PTE_W);
f0102840:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102846:	c1 ee 0c             	shr    $0xc,%esi
f0102849:	39 f0                	cmp    %esi,%eax
f010284b:	77 1c                	ja     f0102869 <mem_init+0x166d>
		panic("pa2page called with invalid pa");
f010284d:	c7 44 24 08 20 60 10 	movl   $0xf0106020,0x8(%esp)
f0102854:	f0 
f0102855:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010285c:	00 
f010285d:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f0102864:	e8 78 d8 ff ff       	call   f01000e1 <_panic>
	return &pages[PGNUM(pa)];
f0102869:	8d 3c f5 00 00 00 00 	lea    0x0(,%esi,8),%edi
f0102870:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102877:	00 
f0102878:	89 54 24 08          	mov    %edx,0x8(%esp)
f010287c:	89 f8                	mov    %edi,%eax
f010287e:	03 05 8c ee 17 f0    	add    0xf017ee8c,%eax
f0102884:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102888:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f010288d:	89 04 24             	mov    %eax,(%esp)
f0102890:	e8 a6 e8 ff ff       	call   f010113b <page_insert>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102895:	3b 35 84 ee 17 f0    	cmp    0xf017ee84,%esi
f010289b:	72 1c                	jb     f01028b9 <mem_init+0x16bd>
		panic("pa2page called with invalid pa");
f010289d:	c7 44 24 08 20 60 10 	movl   $0xf0106020,0x8(%esp)
f01028a4:	f0 
f01028a5:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01028ac:	00 
f01028ad:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f01028b4:	e8 28 d8 ff ff       	call   f01000e1 <_panic>
	return &pages[PGNUM(pa)];
f01028b9:	03 3d 8c ee 17 f0    	add    0xf017ee8c,%edi
    		pa2page(i)->pp_ref--;
f01028bf:	66 83 6f 04 01       	subw   $0x1,0x4(%edi)
f01028c4:	eb 77                	jmp    f010293d <mem_init+0x1741>
    	}
    	else
    	{
    		page_insert(kern_pgdir,pa2page(0),(void*)(KERNBASE+i),PTE_W);
f01028c6:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01028cc:	85 c0                	test   %eax,%eax
f01028ce:	75 1c                	jne    f01028ec <mem_init+0x16f0>
		panic("pa2page called with invalid pa");
f01028d0:	c7 44 24 08 20 60 10 	movl   $0xf0106020,0x8(%esp)
f01028d7:	f0 
f01028d8:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01028df:	00 
f01028e0:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f01028e7:	e8 f5 d7 ff ff       	call   f01000e1 <_panic>
f01028ec:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01028f3:	00 
f01028f4:	89 74 24 08          	mov    %esi,0x8(%esp)
f01028f8:	a1 8c ee 17 f0       	mov    0xf017ee8c,%eax
f01028fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102901:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0102906:	89 04 24             	mov    %eax,(%esp)
f0102909:	e8 2d e8 ff ff       	call   f010113b <page_insert>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010290e:	83 3d 84 ee 17 f0 00 	cmpl   $0x0,0xf017ee84
f0102915:	75 1c                	jne    f0102933 <mem_init+0x1737>
		panic("pa2page called with invalid pa");
f0102917:	c7 44 24 08 20 60 10 	movl   $0xf0106020,0x8(%esp)
f010291e:	f0 
f010291f:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0102926:	00 
f0102927:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f010292e:	e8 ae d7 ff ff       	call   f01000e1 <_panic>
	return &pages[PGNUM(pa)];
f0102933:	a1 8c ee 17 f0       	mov    0xf017ee8c,%eax
    		pa2page(0)->pp_ref--;
f0102938:	66 83 68 04 01       	subw   $0x1,0x4(%eax)
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    for(i=0;i<0xffffffff-KERNBASE;i+=PGSIZE)
f010293d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102943:	89 de                	mov    %ebx,%esi
f0102945:	81 fb 00 00 00 10    	cmp    $0x10000000,%ebx
f010294b:	0f 85 dd fe ff ff    	jne    f010282e <mem_init+0x1632>
    	{
    		page_insert(kern_pgdir,pa2page(0),(void*)(KERNBASE+i),PTE_W);
    		pa2page(0)->pp_ref--;
    	}
    }
    cprintf("%d\r\n",page_free_list->pp_ref);
f0102951:	a1 c0 e1 17 f0       	mov    0xf017e1c0,%eax
f0102956:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f010295a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010295e:	c7 04 24 99 66 10 f0 	movl   $0xf0106699,(%esp)
f0102965:	e8 27 12 00 00       	call   f0103b91 <cprintf>
    cprintf("3\r\n");
f010296a:	c7 04 24 af 5e 10 f0 	movl   $0xf0105eaf,(%esp)
f0102971:	e8 1b 12 00 00       	call   f0103b91 <cprintf>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102976:	8b 35 88 ee 17 f0    	mov    0xf017ee88,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f010297c:	a1 84 ee 17 f0       	mov    0xf017ee84,%eax
f0102981:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102984:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
	for (i = 0; i < n; i += PGSIZE)
f010298b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102990:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102993:	75 30                	jne    f01029c5 <mem_init+0x17c9>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102995:	8b 1d cc e1 17 f0    	mov    0xf017e1cc,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010299b:	89 df                	mov    %ebx,%edi
f010299d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01029a2:	89 f0                	mov    %esi,%eax
f01029a4:	e8 03 e0 ff ff       	call   f01009ac <check_va2pa>
f01029a9:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01029af:	0f 86 94 00 00 00    	jbe    f0102a49 <mem_init+0x184d>
f01029b5:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01029ba:	81 c7 00 00 40 21    	add    $0x21400000,%edi
f01029c0:	e9 a4 00 00 00       	jmp    f0102a69 <mem_init+0x186d>
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01029c5:	8b 1d 8c ee 17 f0    	mov    0xf017ee8c,%ebx
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f01029cb:	8d bb 00 00 00 10    	lea    0x10000000(%ebx),%edi
f01029d1:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01029d6:	89 f0                	mov    %esi,%eax
f01029d8:	e8 cf df ff ff       	call   f01009ac <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029dd:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01029e3:	77 20                	ja     f0102a05 <mem_init+0x1809>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01029e9:	c7 44 24 08 7c 60 10 	movl   $0xf010607c,0x8(%esp)
f01029f0:	f0 
f01029f1:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f01029f8:	00 
f01029f9:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102a00:	e8 dc d6 ff ff       	call   f01000e1 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102a05:	ba 00 00 00 00       	mov    $0x0,%edx
f0102a0a:	8d 0c 17             	lea    (%edi,%edx,1),%ecx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102a0d:	39 c1                	cmp    %eax,%ecx
f0102a0f:	74 24                	je     f0102a35 <mem_init+0x1839>
f0102a11:	c7 44 24 0c 8c 64 10 	movl   $0xf010648c,0xc(%esp)
f0102a18:	f0 
f0102a19:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102a20:	f0 
f0102a21:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f0102a28:	00 
f0102a29:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102a30:	e8 ac d6 ff ff       	call   f01000e1 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102a35:	8d 9a 00 10 00 00    	lea    0x1000(%edx),%ebx
f0102a3b:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102a3e:	0f 87 85 07 00 00    	ja     f01031c9 <mem_init+0x1fcd>
f0102a44:	e9 4c ff ff ff       	jmp    f0102995 <mem_init+0x1799>
f0102a49:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102a4d:	c7 44 24 08 7c 60 10 	movl   $0xf010607c,0x8(%esp)
f0102a54:	f0 
f0102a55:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0102a5c:	00 
f0102a5d:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102a64:	e8 78 d6 ff ff       	call   f01000e1 <_panic>
f0102a69:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102a6c:	39 d0                	cmp    %edx,%eax
f0102a6e:	74 24                	je     f0102a94 <mem_init+0x1898>
f0102a70:	c7 44 24 0c c0 64 10 	movl   $0xf01064c0,0xc(%esp)
f0102a77:	f0 
f0102a78:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102a7f:	f0 
f0102a80:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0102a87:	00 
f0102a88:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102a8f:	e8 4d d6 ff ff       	call   f01000e1 <_panic>
f0102a94:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102a9a:	81 fb 00 80 c1 ee    	cmp    $0xeec18000,%ebx
f0102aa0:	0f 85 15 07 00 00    	jne    f01031bb <mem_init+0x1fbf>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102aa6:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102aa9:	c1 e7 0c             	shl    $0xc,%edi
f0102aac:	85 ff                	test   %edi,%edi
f0102aae:	0f 84 e6 06 00 00    	je     f010319a <mem_init+0x1f9e>
f0102ab4:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102ab9:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
	{

		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102abf:	89 f0                	mov    %esi,%eax
f0102ac1:	e8 e6 de ff ff       	call   f01009ac <check_va2pa>
f0102ac6:	39 c3                	cmp    %eax,%ebx
f0102ac8:	74 24                	je     f0102aee <mem_init+0x18f2>
f0102aca:	c7 44 24 0c f4 64 10 	movl   $0xf01064f4,0xc(%esp)
f0102ad1:	f0 
f0102ad2:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102ad9:	f0 
f0102ada:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f0102ae1:	00 
f0102ae2:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102ae9:	e8 f3 d5 ff ff       	call   f01000e1 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102aee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102af4:	39 fb                	cmp    %edi,%ebx
f0102af6:	72 c1                	jb     f0102ab9 <mem_init+0x18bd>
f0102af8:	e9 9d 06 00 00       	jmp    f010319a <mem_init+0x1f9e>
f0102afd:	8d 14 1f             	lea    (%edi,%ebx,1),%edx

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
	{

		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102b00:	39 d0                	cmp    %edx,%eax
f0102b02:	74 24                	je     f0102b28 <mem_init+0x192c>
f0102b04:	c7 44 24 0c 1c 65 10 	movl   $0xf010651c,0xc(%esp)
f0102b0b:	f0 
f0102b0c:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102b13:	f0 
f0102b14:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f0102b1b:	00 
f0102b1c:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102b23:	e8 b9 d5 ff ff       	call   f01000e1 <_panic>
f0102b28:	81 c3 00 10 00 00    	add    $0x1000,%ebx

		assert(check_va2pa(pgdir, KERNBASE + i) == i);
	}

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102b2e:	81 fb 00 00 c0 ef    	cmp    $0xefc00000,%ebx
f0102b34:	0f 85 52 06 00 00    	jne    f010318c <mem_init+0x1f90>
	{

		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	}
			assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102b3a:	ba 00 00 80 ef       	mov    $0xef800000,%edx
f0102b3f:	89 f0                	mov    %esi,%eax
f0102b41:	e8 66 de ff ff       	call   f01009ac <check_va2pa>
f0102b46:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b49:	74 24                	je     f0102b6f <mem_init+0x1973>
f0102b4b:	c7 44 24 0c 64 65 10 	movl   $0xf0106564,0xc(%esp)
f0102b52:	f0 
f0102b53:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102b5a:	f0 
f0102b5b:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f0102b62:	00 
f0102b63:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102b6a:	e8 72 d5 ff ff       	call   f01000e1 <_panic>
f0102b6f:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102b74:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102b7a:	83 fa 03             	cmp    $0x3,%edx
f0102b7d:	77 2e                	ja     f0102bad <mem_init+0x19b1>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102b7f:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102b83:	0f 85 aa 00 00 00    	jne    f0102c33 <mem_init+0x1a37>
f0102b89:	c7 44 24 0c b3 5e 10 	movl   $0xf0105eb3,0xc(%esp)
f0102b90:	f0 
f0102b91:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102b98:	f0 
f0102b99:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0102ba0:	00 
f0102ba1:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102ba8:	e8 34 d5 ff ff       	call   f01000e1 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102bad:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102bb2:	76 55                	jbe    f0102c09 <mem_init+0x1a0d>
				assert(pgdir[i] & PTE_P);
f0102bb4:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102bb7:	f6 c2 01             	test   $0x1,%dl
f0102bba:	75 24                	jne    f0102be0 <mem_init+0x19e4>
f0102bbc:	c7 44 24 0c b3 5e 10 	movl   $0xf0105eb3,0xc(%esp)
f0102bc3:	f0 
f0102bc4:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102bcb:	f0 
f0102bcc:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0102bd3:	00 
f0102bd4:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102bdb:	e8 01 d5 ff ff       	call   f01000e1 <_panic>
				assert(pgdir[i] & PTE_W);
f0102be0:	f6 c2 02             	test   $0x2,%dl
f0102be3:	75 4e                	jne    f0102c33 <mem_init+0x1a37>
f0102be5:	c7 44 24 0c c4 5e 10 	movl   $0xf0105ec4,0xc(%esp)
f0102bec:	f0 
f0102bed:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102bf4:	f0 
f0102bf5:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0102bfc:	00 
f0102bfd:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102c04:	e8 d8 d4 ff ff       	call   f01000e1 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102c09:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102c0d:	74 24                	je     f0102c33 <mem_init+0x1a37>
f0102c0f:	c7 44 24 0c d5 5e 10 	movl   $0xf0105ed5,0xc(%esp)
f0102c16:	f0 
f0102c17:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102c1e:	f0 
f0102c1f:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102c26:	00 
f0102c27:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102c2e:	e8 ae d4 ff ff       	call   f01000e1 <_panic>

	}
			assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102c33:	83 c0 01             	add    $0x1,%eax
f0102c36:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102c3b:	0f 85 33 ff ff ff    	jne    f0102b74 <mem_init+0x1978>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102c41:	c7 04 24 94 65 10 f0 	movl   $0xf0106594,(%esp)
f0102c48:	e8 44 0f 00 00       	call   f0103b91 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102c4d:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c52:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c57:	77 20                	ja     f0102c79 <mem_init+0x1a7d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c59:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c5d:	c7 44 24 08 7c 60 10 	movl   $0xf010607c,0x8(%esp)
f0102c64:	f0 
f0102c65:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
f0102c6c:	00 
f0102c6d:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102c74:	e8 68 d4 ff ff       	call   f01000e1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102c79:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102c7e:	0f 22 d8             	mov    %eax,%cr3
	cprintf("env_id:%d\r\n",(((struct Env*)UENVS)[0]).env_id);
f0102c81:	a1 48 00 c0 ee       	mov    0xeec00048,%eax
f0102c86:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102c8a:	c7 04 24 e3 5e 10 f0 	movl   $0xf0105ee3,(%esp)
f0102c91:	e8 fb 0e 00 00       	call   f0103b91 <cprintf>
	cprintf("%d\r\n",page_free_list->pp_ref);
f0102c96:	a1 c0 e1 17 f0       	mov    0xf017e1c0,%eax
f0102c9b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0102c9f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102ca3:	c7 04 24 99 66 10 f0 	movl   $0xf0106699,(%esp)
f0102caa:	e8 e2 0e 00 00       	call   f0103b91 <cprintf>
	check_page_free_list(0);
f0102caf:	b8 00 00 00 00       	mov    $0x0,%eax
f0102cb4:	e8 62 dd ff ff       	call   f0100a1b <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102cb9:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0102cbc:	83 e0 f3             	and    $0xfffffff3,%eax
f0102cbf:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102cc4:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102cc7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102cce:	e8 de e1 ff ff       	call   f0100eb1 <page_alloc>
f0102cd3:	89 c3                	mov    %eax,%ebx
f0102cd5:	85 c0                	test   %eax,%eax
f0102cd7:	75 24                	jne    f0102cfd <mem_init+0x1b01>
f0102cd9:	c7 44 24 0c d7 5c 10 	movl   $0xf0105cd7,0xc(%esp)
f0102ce0:	f0 
f0102ce1:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102ce8:	f0 
f0102ce9:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f0102cf0:	00 
f0102cf1:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102cf8:	e8 e4 d3 ff ff       	call   f01000e1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102cfd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d04:	e8 a8 e1 ff ff       	call   f0100eb1 <page_alloc>
f0102d09:	89 c7                	mov    %eax,%edi
f0102d0b:	85 c0                	test   %eax,%eax
f0102d0d:	75 24                	jne    f0102d33 <mem_init+0x1b37>
f0102d0f:	c7 44 24 0c ed 5c 10 	movl   $0xf0105ced,0xc(%esp)
f0102d16:	f0 
f0102d17:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102d1e:	f0 
f0102d1f:	c7 44 24 04 20 04 00 	movl   $0x420,0x4(%esp)
f0102d26:	00 
f0102d27:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102d2e:	e8 ae d3 ff ff       	call   f01000e1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102d33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d3a:	e8 72 e1 ff ff       	call   f0100eb1 <page_alloc>
f0102d3f:	89 c6                	mov    %eax,%esi
f0102d41:	85 c0                	test   %eax,%eax
f0102d43:	75 24                	jne    f0102d69 <mem_init+0x1b6d>
f0102d45:	c7 44 24 0c 03 5d 10 	movl   $0xf0105d03,0xc(%esp)
f0102d4c:	f0 
f0102d4d:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102d54:	f0 
f0102d55:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f0102d5c:	00 
f0102d5d:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102d64:	e8 78 d3 ff ff       	call   f01000e1 <_panic>
	page_free(pp0);
f0102d69:	89 1c 24             	mov    %ebx,(%esp)
f0102d6c:	e8 c5 e1 ff ff       	call   f0100f36 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d71:	89 f8                	mov    %edi,%eax
f0102d73:	2b 05 8c ee 17 f0    	sub    0xf017ee8c,%eax
f0102d79:	c1 f8 03             	sar    $0x3,%eax
f0102d7c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d7f:	89 c2                	mov    %eax,%edx
f0102d81:	c1 ea 0c             	shr    $0xc,%edx
f0102d84:	3b 15 84 ee 17 f0    	cmp    0xf017ee84,%edx
f0102d8a:	72 20                	jb     f0102dac <mem_init+0x1bb0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d90:	c7 44 24 08 38 5f 10 	movl   $0xf0105f38,0x8(%esp)
f0102d97:	f0 
f0102d98:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102d9f:	00 
f0102da0:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f0102da7:	e8 35 d3 ff ff       	call   f01000e1 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102dac:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102db3:	00 
f0102db4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102dbb:	00 
	return (void *)(pa + KERNBASE);
f0102dbc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102dc1:	89 04 24             	mov    %eax,(%esp)
f0102dc4:	e8 f0 23 00 00       	call   f01051b9 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102dc9:	89 f0                	mov    %esi,%eax
f0102dcb:	2b 05 8c ee 17 f0    	sub    0xf017ee8c,%eax
f0102dd1:	c1 f8 03             	sar    $0x3,%eax
f0102dd4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102dd7:	89 c2                	mov    %eax,%edx
f0102dd9:	c1 ea 0c             	shr    $0xc,%edx
f0102ddc:	3b 15 84 ee 17 f0    	cmp    0xf017ee84,%edx
f0102de2:	72 20                	jb     f0102e04 <mem_init+0x1c08>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102de4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102de8:	c7 44 24 08 38 5f 10 	movl   $0xf0105f38,0x8(%esp)
f0102def:	f0 
f0102df0:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102df7:	00 
f0102df8:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f0102dff:	e8 dd d2 ff ff       	call   f01000e1 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102e04:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102e0b:	00 
f0102e0c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102e13:	00 
	return (void *)(pa + KERNBASE);
f0102e14:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102e19:	89 04 24             	mov    %eax,(%esp)
f0102e1c:	e8 98 23 00 00       	call   f01051b9 <memset>

	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102e21:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102e28:	00 
f0102e29:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102e30:	00 
f0102e31:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102e35:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0102e3a:	89 04 24             	mov    %eax,(%esp)
f0102e3d:	e8 f9 e2 ff ff       	call   f010113b <page_insert>

	assert(pp1->pp_ref == 1);
f0102e42:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102e47:	74 24                	je     f0102e6d <mem_init+0x1c71>
f0102e49:	c7 44 24 0c e1 5d 10 	movl   $0xf0105de1,0xc(%esp)
f0102e50:	f0 
f0102e51:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102e58:	f0 
f0102e59:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f0102e60:	00 
f0102e61:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102e68:	e8 74 d2 ff ff       	call   f01000e1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e6d:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102e74:	01 01 01 
f0102e77:	74 24                	je     f0102e9d <mem_init+0x1ca1>
f0102e79:	c7 44 24 0c b4 65 10 	movl   $0xf01065b4,0xc(%esp)
f0102e80:	f0 
f0102e81:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102e88:	f0 
f0102e89:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f0102e90:	00 
f0102e91:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102e98:	e8 44 d2 ff ff       	call   f01000e1 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102e9d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102ea4:	00 
f0102ea5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102eac:	00 
f0102ead:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102eb1:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0102eb6:	89 04 24             	mov    %eax,(%esp)
f0102eb9:	e8 7d e2 ff ff       	call   f010113b <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ebe:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102ec5:	02 02 02 
f0102ec8:	74 24                	je     f0102eee <mem_init+0x1cf2>
f0102eca:	c7 44 24 0c d8 65 10 	movl   $0xf01065d8,0xc(%esp)
f0102ed1:	f0 
f0102ed2:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102ed9:	f0 
f0102eda:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f0102ee1:	00 
f0102ee2:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102ee9:	e8 f3 d1 ff ff       	call   f01000e1 <_panic>
	assert(pp2->pp_ref == 1);
f0102eee:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102ef3:	74 24                	je     f0102f19 <mem_init+0x1d1d>
f0102ef5:	c7 44 24 0c 03 5e 10 	movl   $0xf0105e03,0xc(%esp)
f0102efc:	f0 
f0102efd:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102f04:	f0 
f0102f05:	c7 44 24 04 2c 04 00 	movl   $0x42c,0x4(%esp)
f0102f0c:	00 
f0102f0d:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102f14:	e8 c8 d1 ff ff       	call   f01000e1 <_panic>
	assert(pp1->pp_ref == 0);
f0102f19:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102f1e:	74 24                	je     f0102f44 <mem_init+0x1d48>
f0102f20:	c7 44 24 0c 52 5e 10 	movl   $0xf0105e52,0xc(%esp)
f0102f27:	f0 
f0102f28:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102f2f:	f0 
f0102f30:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f0102f37:	00 
f0102f38:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102f3f:	e8 9d d1 ff ff       	call   f01000e1 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102f44:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102f4b:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f4e:	89 f0                	mov    %esi,%eax
f0102f50:	2b 05 8c ee 17 f0    	sub    0xf017ee8c,%eax
f0102f56:	c1 f8 03             	sar    $0x3,%eax
f0102f59:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f5c:	89 c2                	mov    %eax,%edx
f0102f5e:	c1 ea 0c             	shr    $0xc,%edx
f0102f61:	3b 15 84 ee 17 f0    	cmp    0xf017ee84,%edx
f0102f67:	72 20                	jb     f0102f89 <mem_init+0x1d8d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f69:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f6d:	c7 44 24 08 38 5f 10 	movl   $0xf0105f38,0x8(%esp)
f0102f74:	f0 
f0102f75:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102f7c:	00 
f0102f7d:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f0102f84:	e8 58 d1 ff ff       	call   f01000e1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102f89:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102f90:	03 03 03 
f0102f93:	74 24                	je     f0102fb9 <mem_init+0x1dbd>
f0102f95:	c7 44 24 0c fc 65 10 	movl   $0xf01065fc,0xc(%esp)
f0102f9c:	f0 
f0102f9d:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102fa4:	f0 
f0102fa5:	c7 44 24 04 2f 04 00 	movl   $0x42f,0x4(%esp)
f0102fac:	00 
f0102fad:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102fb4:	e8 28 d1 ff ff       	call   f01000e1 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102fb9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102fc0:	00 
f0102fc1:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0102fc6:	89 04 24             	mov    %eax,(%esp)
f0102fc9:	e8 28 e1 ff ff       	call   f01010f6 <page_remove>
	assert(pp2->pp_ref == 0);
f0102fce:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102fd3:	74 24                	je     f0102ff9 <mem_init+0x1dfd>
f0102fd5:	c7 44 24 0c 3f 5e 10 	movl   $0xf0105e3f,0xc(%esp)
f0102fdc:	f0 
f0102fdd:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0102fe4:	f0 
f0102fe5:	c7 44 24 04 31 04 00 	movl   $0x431,0x4(%esp)
f0102fec:	00 
f0102fed:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0102ff4:	e8 e8 d0 ff ff       	call   f01000e1 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ff9:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0102ffe:	8b 08                	mov    (%eax),%ecx
f0103000:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103006:	89 da                	mov    %ebx,%edx
f0103008:	2b 15 8c ee 17 f0    	sub    0xf017ee8c,%edx
f010300e:	c1 fa 03             	sar    $0x3,%edx
f0103011:	c1 e2 0c             	shl    $0xc,%edx
f0103014:	39 d1                	cmp    %edx,%ecx
f0103016:	74 24                	je     f010303c <mem_init+0x1e40>
f0103018:	c7 44 24 0c 78 61 10 	movl   $0xf0106178,0xc(%esp)
f010301f:	f0 
f0103020:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0103027:	f0 
f0103028:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f010302f:	00 
f0103030:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0103037:	e8 a5 d0 ff ff       	call   f01000e1 <_panic>
	kern_pgdir[0] = 0;
f010303c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103042:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103047:	74 24                	je     f010306d <mem_init+0x1e71>
f0103049:	c7 44 24 0c f2 5d 10 	movl   $0xf0105df2,0xc(%esp)
f0103050:	f0 
f0103051:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0103058:	f0 
f0103059:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f0103060:	00 
f0103061:	c7 04 24 b1 5b 10 f0 	movl   $0xf0105bb1,(%esp)
f0103068:	e8 74 d0 ff ff       	call   f01000e1 <_panic>
	pp0->pp_ref = 0;
f010306d:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0103073:	89 1c 24             	mov    %ebx,(%esp)
f0103076:	e8 bb de ff ff       	call   f0100f36 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010307b:	c7 04 24 28 66 10 f0 	movl   $0xf0106628,(%esp)
f0103082:	e8 0a 0b 00 00       	call   f0103b91 <cprintf>
f0103087:	e9 51 01 00 00       	jmp    f01031dd <mem_init+0x1fe1>

	}



	cprintf("%d\r\n",page_free_list->pp_ref);
f010308c:	a1 c0 e1 17 f0       	mov    0xf017e1c0,%eax
f0103091:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0103095:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103099:	c7 04 24 99 66 10 f0 	movl   $0xf0106699,(%esp)
f01030a0:	e8 ec 0a 00 00       	call   f0103b91 <cprintf>
	cprintf("1\r\n");
f01030a5:	c7 04 24 ef 5e 10 f0 	movl   $0xf0105eef,(%esp)
f01030ac:	e8 e0 0a 00 00       	call   f0103b91 <cprintf>
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	   for(i=0;i<ROUNDUP(NENV*sizeof(struct Env),PGSIZE);i+=PGSIZE)
		{
		 //  cprintf("map a UENVS pages");
		page_insert(kern_pgdir, pa2page(PADDR(envs)+i),(void*) (UENVS+i), PTE_U);
f01030b1:	a1 cc e1 17 f0       	mov    0xf017e1cc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030b6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030bb:	0f 87 17 f6 ff ff    	ja     f01026d8 <mem_init+0x14dc>
f01030c1:	e9 3a f6 ff ff       	jmp    f0102700 <mem_init+0x1504>
f01030c6:	b8 00 20 11 f0       	mov    $0xf0112000,%eax
f01030cb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030d0:	0f 86 df f6 ff ff    	jbe    f01027b5 <mem_init+0x15b9>
f01030d6:	e9 b2 f6 ff ff       	jmp    f010278d <mem_init+0x1591>
	//cprintf("%x,%x \r\n",bootstack,bootstacktop);
	for(i=0;i<KSTKSIZE;i+=PGSIZE)
	{
		page_insert(kern_pgdir,pa2page(PADDR(bootstack)+i),(void*)(KSTACKTOP-KSTKSIZE+i),PTE_W);
	}
	cprintf("%d\r\n",page_free_list->pp_ref);
f01030db:	a1 c0 e1 17 f0       	mov    0xf017e1c0,%eax
f01030e0:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01030e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01030e8:	c7 04 24 99 66 10 f0 	movl   $0xf0106699,(%esp)
f01030ef:	e8 9d 0a 00 00       	call   f0103b91 <cprintf>
	cprintf("2\r\n");
f01030f4:	c7 04 24 f3 5e 10 f0 	movl   $0xf0105ef3,(%esp)
f01030fb:	e8 91 0a 00 00       	call   f0103b91 <cprintf>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    for(i=0;i<0xffffffff-KERNBASE;i+=PGSIZE)
f0103100:	be 00 00 00 00       	mov    $0x0,%esi
f0103105:	bb 00 00 00 00       	mov    $0x0,%ebx
f010310a:	e9 1f f7 ff ff       	jmp    f010282e <mem_init+0x1632>
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	//cprintf("%x,%x \r\n",bootstack,bootstacktop);
	for(i=0;i<KSTKSIZE;i+=PGSIZE)
	{
		page_insert(kern_pgdir,pa2page(PADDR(bootstack)+i),(void*)(KSTACKTOP-KSTKSIZE+i),PTE_W);
f010310f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103116:	00 
f0103117:	c7 44 24 08 00 80 bf 	movl   $0xefbf8000,0x8(%esp)
f010311e:	ef 
static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010311f:	8b 15 8c ee 17 f0    	mov    0xf017ee8c,%edx
f0103125:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103128:	89 44 24 04          	mov    %eax,0x4(%esp)
f010312c:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0103131:	89 04 24             	mov    %eax,(%esp)
f0103134:	e8 02 e0 ff ff       	call   f010113b <page_insert>
f0103139:	bb 00 30 11 00       	mov    $0x113000,%ebx
f010313e:	bf 00 a0 11 00       	mov    $0x11a000,%edi
f0103143:	be 00 80 bf df       	mov    $0xdfbf8000,%esi
f0103148:	81 ee 00 20 11 f0    	sub    $0xf0112000,%esi
f010314e:	e9 50 f6 ff ff       	jmp    f01027a3 <mem_init+0x15a7>
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	   for(i=0;i<ROUNDUP(NENV*sizeof(struct Env),PGSIZE);i+=PGSIZE)
		{
		 //  cprintf("map a UENVS pages");
		page_insert(kern_pgdir, pa2page(PADDR(envs)+i),(void*) (UENVS+i), PTE_U);
f0103153:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010315a:	00 
f010315b:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
f0103162:	ee 
f0103163:	8b 15 8c ee 17 f0    	mov    0xf017ee8c,%edx
f0103169:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010316c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103170:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
f0103175:	89 04 24             	mov    %eax,(%esp)
f0103178:	e8 be df ff ff       	call   f010113b <page_insert>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	   for(i=0;i<ROUNDUP(NENV*sizeof(struct Env),PGSIZE);i+=PGSIZE)
f010317d:	bb 00 10 00 00       	mov    $0x1000,%ebx
f0103182:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103187:	e9 62 f5 ff ff       	jmp    f01026ee <mem_init+0x14f2>

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
	{

		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010318c:	89 da                	mov    %ebx,%edx
f010318e:	89 f0                	mov    %esi,%eax
f0103190:	e8 17 d8 ff ff       	call   f01009ac <check_va2pa>
f0103195:	e9 63 f9 ff ff       	jmp    f0102afd <mem_init+0x1901>
f010319a:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f010319f:	89 f0                	mov    %esi,%eax
f01031a1:	e8 06 d8 ff ff       	call   f01009ac <check_va2pa>
f01031a6:	bb 00 80 bf ef       	mov    $0xefbf8000,%ebx
f01031ab:	bf 00 20 11 f0       	mov    $0xf0112000,%edi
f01031b0:	81 c7 00 80 40 20    	add    $0x20408000,%edi
f01031b6:	e9 42 f9 ff ff       	jmp    f0102afd <mem_init+0x1901>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01031bb:	89 da                	mov    %ebx,%edx
f01031bd:	89 f0                	mov    %esi,%eax
f01031bf:	e8 e8 d7 ff ff       	call   f01009ac <check_va2pa>
f01031c4:	e9 a0 f8 ff ff       	jmp    f0102a69 <mem_init+0x186d>
f01031c9:	81 ea 00 f0 ff 10    	sub    $0x10fff000,%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01031cf:	89 f0                	mov    %esi,%eax
f01031d1:	e8 d6 d7 ff ff       	call   f01009ac <check_va2pa>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01031d6:	89 da                	mov    %ebx,%edx
f01031d8:	e9 2d f8 ff ff       	jmp    f0102a0a <mem_init+0x180e>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01031dd:	83 c4 3c             	add    $0x3c,%esp
f01031e0:	5b                   	pop    %ebx
f01031e1:	5e                   	pop    %esi
f01031e2:	5f                   	pop    %edi
f01031e3:	5d                   	pop    %ebp
f01031e4:	c3                   	ret    

f01031e5 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01031e5:	55                   	push   %ebp
f01031e6:	89 e5                	mov    %esp,%ebp
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01031e8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031eb:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01031ee:	5d                   	pop    %ebp
f01031ef:	c3                   	ret    

f01031f0 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01031f0:	55                   	push   %ebp
f01031f1:	89 e5                	mov    %esp,%ebp
f01031f3:	57                   	push   %edi
f01031f4:	56                   	push   %esi
f01031f5:	53                   	push   %ebx
f01031f6:	83 ec 3c             	sub    $0x3c,%esp
f01031f9:	8b 7d 08             	mov    0x8(%ebp),%edi
f01031fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	// LAB 3: Your code here.

	     int i=0;
		int flag=0;
		int t=(int)va;
		for(i=t;i<(t+len);i+=PGSIZE)
f01031ff:	89 c2                	mov    %eax,%edx
f0103201:	03 55 10             	add    0x10(%ebp),%edx
f0103204:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0103207:	39 d0                	cmp    %edx,%eax
f0103209:	0f 83 88 00 00 00    	jae    f0103297 <user_mem_check+0xa7>
f010320f:	89 c3                	mov    %eax,%ebx
f0103211:	89 c6                	mov    %eax,%esi
			pte_t* store=0;
			struct Page* pg=page_lookup(env->env_pgdir, (void*)i, &store);
			if(store!=NULL)
			{
				//cprintf("pte!=NULL %08x\r\n",*store);
			   if((((*store) &(perm|PTE_P))!=(perm|PTE_P)) || i>ULIM)
f0103213:	8b 45 14             	mov    0x14(%ebp),%eax
f0103216:	83 c8 01             	or     $0x1,%eax
f0103219:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	     int i=0;
		int flag=0;
		int t=(int)va;
		for(i=t;i<(t+len);i+=PGSIZE)
		{
			pte_t* store=0;
f010321c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			struct Page* pg=page_lookup(env->env_pgdir, (void*)i, &store);
f0103223:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103226:	89 44 24 08          	mov    %eax,0x8(%esp)
f010322a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010322e:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103231:	89 04 24             	mov    %eax,(%esp)
f0103234:	e8 45 de ff ff       	call   f010107e <page_lookup>
			if(store!=NULL)
f0103239:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010323c:	85 c0                	test   %eax,%eax
f010323e:	74 27                	je     f0103267 <user_mem_check+0x77>
			{
				//cprintf("pte!=NULL %08x\r\n",*store);
			   if((((*store) &(perm|PTE_P))!=(perm|PTE_P)) || i>ULIM)
f0103240:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103243:	89 ca                	mov    %ecx,%edx
f0103245:	23 10                	and    (%eax),%edx
f0103247:	39 d1                	cmp    %edx,%ecx
f0103249:	75 08                	jne    f0103253 <user_mem_check+0x63>
f010324b:	81 fe 00 00 80 ef    	cmp    $0xef800000,%esi
f0103251:	76 28                	jbe    f010327b <user_mem_check+0x8b>
			   {
				cprintf("pte protect!\r\n");
f0103253:	c7 04 24 f7 5e 10 f0 	movl   $0xf0105ef7,(%esp)
f010325a:	e8 32 09 00 00       	call   f0103b91 <cprintf>
				flag=-E_FAULT;
				user_mem_check_addr=(int)i;
f010325f:	89 35 bc e1 17 f0    	mov    %esi,0xf017e1bc
				break;
f0103265:	eb 29                	jmp    f0103290 <user_mem_check+0xa0>
			   }
			}
			else
			{
				cprintf("no pte!\r\n");
f0103267:	c7 04 24 06 5f 10 f0 	movl   $0xf0105f06,(%esp)
f010326e:	e8 1e 09 00 00       	call   f0103b91 <cprintf>
				flag=-E_FAULT;
				user_mem_check_addr=(int)i;
f0103273:	89 35 bc e1 17 f0    	mov    %esi,0xf017e1bc
				break;
f0103279:	eb 15                	jmp    f0103290 <user_mem_check+0xa0>
			}
		      i=ROUNDDOWN(i,PGSIZE);
f010327b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// LAB 3: Your code here.

	     int i=0;
		int flag=0;
		int t=(int)va;
		for(i=t;i<(t+len);i+=PGSIZE)
f0103281:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103287:	89 de                	mov    %ebx,%esi
f0103289:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f010328c:	72 8e                	jb     f010321c <user_mem_check+0x2c>
f010328e:	eb 0e                	jmp    f010329e <user_mem_check+0xae>
			   if((((*store) &(perm|PTE_P))!=(perm|PTE_P)) || i>ULIM)
			   {
				cprintf("pte protect!\r\n");
				flag=-E_FAULT;
				user_mem_check_addr=(int)i;
				break;
f0103290:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103295:	eb 0c                	jmp    f01032a3 <user_mem_check+0xb3>
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.

	     int i=0;
		int flag=0;
f0103297:	b8 00 00 00 00       	mov    $0x0,%eax
f010329c:	eb 05                	jmp    f01032a3 <user_mem_check+0xb3>
f010329e:	b8 00 00 00 00       	mov    $0x0,%eax
			}
		      i=ROUNDDOWN(i,PGSIZE);
		}

	return flag;
}
f01032a3:	83 c4 3c             	add    $0x3c,%esp
f01032a6:	5b                   	pop    %ebx
f01032a7:	5e                   	pop    %esi
f01032a8:	5f                   	pop    %edi
f01032a9:	5d                   	pop    %ebp
f01032aa:	c3                   	ret    

f01032ab <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01032ab:	55                   	push   %ebp
f01032ac:	89 e5                	mov    %esp,%ebp
f01032ae:	53                   	push   %ebx
f01032af:	83 ec 14             	sub    $0x14,%esp
f01032b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("user_mem_assert\r\n");
f01032b5:	c7 04 24 10 5f 10 f0 	movl   $0xf0105f10,(%esp)
f01032bc:	e8 d0 08 00 00       	call   f0103b91 <cprintf>
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01032c1:	8b 45 14             	mov    0x14(%ebp),%eax
f01032c4:	83 c8 04             	or     $0x4,%eax
f01032c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032cb:	8b 45 10             	mov    0x10(%ebp),%eax
f01032ce:	89 44 24 08          	mov    %eax,0x8(%esp)
f01032d2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032d5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01032d9:	89 1c 24             	mov    %ebx,(%esp)
f01032dc:	e8 0f ff ff ff       	call   f01031f0 <user_mem_check>
f01032e1:	85 c0                	test   %eax,%eax
f01032e3:	79 24                	jns    f0103309 <user_mem_assert+0x5e>
		cprintf("[%08x] user_mem_check assertion failure for "
f01032e5:	a1 bc e1 17 f0       	mov    0xf017e1bc,%eax
f01032ea:	89 44 24 08          	mov    %eax,0x8(%esp)
f01032ee:	8b 43 48             	mov    0x48(%ebx),%eax
f01032f1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01032f5:	c7 04 24 54 66 10 f0 	movl   $0xf0106654,(%esp)
f01032fc:	e8 90 08 00 00       	call   f0103b91 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103301:	89 1c 24             	mov    %ebx,(%esp)
f0103304:	e8 4a 07 00 00       	call   f0103a53 <env_destroy>
	}
	cprintf("assert success!!\r\n");
f0103309:	c7 04 24 22 5f 10 f0 	movl   $0xf0105f22,(%esp)
f0103310:	e8 7c 08 00 00       	call   f0103b91 <cprintf>
}
f0103315:	83 c4 14             	add    $0x14,%esp
f0103318:	5b                   	pop    %ebx
f0103319:	5d                   	pop    %ebp
f010331a:	c3                   	ret    

f010331b <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010331b:	55                   	push   %ebp
f010331c:	89 e5                	mov    %esp,%ebp
f010331e:	57                   	push   %edi
f010331f:	56                   	push   %esi
f0103320:	53                   	push   %ebx
f0103321:	83 ec 1c             	sub    $0x1c,%esp
f0103324:	89 c6                	mov    %eax,%esi
f0103326:	89 d3                	mov    %edx,%ebx
f0103328:	89 cf                	mov    %ecx,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void* i;
	cprintf("region_alloc %x,%d\r\n",e->env_pgdir,len);
f010332a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010332e:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103331:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103335:	c7 04 24 89 66 10 f0 	movl   $0xf0106689,(%esp)
f010333c:	e8 50 08 00 00       	call   f0103b91 <cprintf>
	for(i=ROUNDDOWN(va,PGSIZE);i<ROUNDUP(va+len,PGSIZE);i+=PGSIZE)
f0103341:	89 d8                	mov    %ebx,%eax
f0103343:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0103349:	8d bc 38 ff 0f 00 00 	lea    0xfff(%eax,%edi,1),%edi
f0103350:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0103356:	39 fb                	cmp    %edi,%ebx
f0103358:	73 51                	jae    f01033ab <region_alloc+0x90>
	{
		struct Page* p=(struct Page*)page_alloc(1);
f010335a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103361:	e8 4b db ff ff       	call   f0100eb1 <page_alloc>
		if(p==NULL)
f0103366:	85 c0                	test   %eax,%eax
f0103368:	75 1c                	jne    f0103386 <region_alloc+0x6b>
			panic("Memory out!");
f010336a:	c7 44 24 08 9e 66 10 	movl   $0xf010669e,0x8(%esp)
f0103371:	f0 
f0103372:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
f0103379:	00 
f010337a:	c7 04 24 aa 66 10 f0 	movl   $0xf01066aa,(%esp)
f0103381:	e8 5b cd ff ff       	call   f01000e1 <_panic>
		page_insert(e->env_pgdir,p,i,PTE_W|PTE_U);
f0103386:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010338d:	00 
f010338e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103392:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103396:	8b 46 5c             	mov    0x5c(%esi),%eax
f0103399:	89 04 24             	mov    %eax,(%esp)
f010339c:	e8 9a dd ff ff       	call   f010113b <page_insert>
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void* i;
	cprintf("region_alloc %x,%d\r\n",e->env_pgdir,len);
	for(i=ROUNDDOWN(va,PGSIZE);i<ROUNDUP(va+len,PGSIZE);i+=PGSIZE)
f01033a1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01033a7:	39 fb                	cmp    %edi,%ebx
f01033a9:	72 af                	jb     f010335a <region_alloc+0x3f>
		if(p==NULL)
			panic("Memory out!");
		page_insert(e->env_pgdir,p,i,PTE_W|PTE_U);
	}

}
f01033ab:	83 c4 1c             	add    $0x1c,%esp
f01033ae:	5b                   	pop    %ebx
f01033af:	5e                   	pop    %esi
f01033b0:	5f                   	pop    %edi
f01033b1:	5d                   	pop    %ebp
f01033b2:	c3                   	ret    

f01033b3 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01033b3:	55                   	push   %ebp
f01033b4:	89 e5                	mov    %esp,%ebp
f01033b6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01033b9:	85 c0                	test   %eax,%eax
f01033bb:	75 11                	jne    f01033ce <envid2env+0x1b>
		*env_store = curenv;
f01033bd:	a1 c8 e1 17 f0       	mov    0xf017e1c8,%eax
f01033c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01033c5:	89 01                	mov    %eax,(%ecx)
		return 0;
f01033c7:	b8 00 00 00 00       	mov    $0x0,%eax
f01033cc:	eb 60                	jmp    f010342e <envid2env+0x7b>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01033ce:	89 c2                	mov    %eax,%edx
f01033d0:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01033d6:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01033d9:	c1 e2 05             	shl    $0x5,%edx
f01033dc:	03 15 cc e1 17 f0    	add    0xf017e1cc,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01033e2:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f01033e6:	74 05                	je     f01033ed <envid2env+0x3a>
f01033e8:	39 42 48             	cmp    %eax,0x48(%edx)
f01033eb:	74 10                	je     f01033fd <envid2env+0x4a>
		*env_store = 0;
f01033ed:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033f0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01033f6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01033fb:	eb 31                	jmp    f010342e <envid2env+0x7b>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01033fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103401:	74 21                	je     f0103424 <envid2env+0x71>
f0103403:	a1 c8 e1 17 f0       	mov    0xf017e1c8,%eax
f0103408:	39 c2                	cmp    %eax,%edx
f010340a:	74 18                	je     f0103424 <envid2env+0x71>
f010340c:	8b 40 48             	mov    0x48(%eax),%eax
f010340f:	39 42 4c             	cmp    %eax,0x4c(%edx)
f0103412:	74 10                	je     f0103424 <envid2env+0x71>
		*env_store = 0;
f0103414:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103417:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010341d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103422:	eb 0a                	jmp    f010342e <envid2env+0x7b>
	}

	*env_store = e;
f0103424:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103427:	89 10                	mov    %edx,(%eax)
	return 0;
f0103429:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010342e:	5d                   	pop    %ebp
f010342f:	c3                   	ret    

f0103430 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103430:	55                   	push   %ebp
f0103431:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103433:	b8 00 c3 11 f0       	mov    $0xf011c300,%eax
f0103438:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010343b:	b8 23 00 00 00       	mov    $0x23,%eax
f0103440:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103442:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103444:	b0 10                	mov    $0x10,%al
f0103446:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103448:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010344a:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f010344c:	ea 53 34 10 f0 08 00 	ljmp   $0x8,$0xf0103453
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103453:	b0 00                	mov    $0x0,%al
f0103455:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103458:	5d                   	pop    %ebp
f0103459:	c3                   	ret    

f010345a <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010345a:	55                   	push   %ebp
f010345b:	89 e5                	mov    %esp,%ebp
f010345d:	57                   	push   %edi
f010345e:	56                   	push   %esi
f010345f:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
    int i=0;
    for(i=0;i<=NENV-1;i++)
    {
    	envs[i].env_id=0;
f0103460:	8b 1d cc e1 17 f0    	mov    0xf017e1cc,%ebx
f0103466:	c7 43 48 00 00 00 00 	movl   $0x0,0x48(%ebx)
f010346d:	89 df                	mov    %ebx,%edi
f010346f:	8d 53 60             	lea    0x60(%ebx),%edx
f0103472:	89 de                	mov    %ebx,%esi
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
    int i=0;
    for(i=0;i<=NENV-1;i++)
f0103474:	b8 00 00 00 00       	mov    $0x0,%eax
    {
    	envs[i].env_id=0;
f0103479:	b9 00 00 00 00       	mov    $0x0,%ecx
f010347e:	eb 02                	jmp    f0103482 <env_init+0x28>
f0103480:	89 fb                	mov    %edi,%ebx
    	if(i!=NENV-1)
    	{
    	envs[i].env_link=&envs[i+1];
f0103482:	8d 4c 49 03          	lea    0x3(%ecx,%ecx,2),%ecx
f0103486:	c1 e1 05             	shl    $0x5,%ecx
f0103489:	01 cb                	add    %ecx,%ebx
f010348b:	89 5e 44             	mov    %ebx,0x44(%esi)
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
    int i=0;
    for(i=0;i<=NENV-1;i++)
f010348e:	83 c0 01             	add    $0x1,%eax
    {
    	envs[i].env_id=0;
f0103491:	89 c1                	mov    %eax,%ecx
f0103493:	89 d6                	mov    %edx,%esi
f0103495:	c7 42 48 00 00 00 00 	movl   $0x0,0x48(%edx)
f010349c:	83 c2 60             	add    $0x60,%edx
    	if(i!=NENV-1)
f010349f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01034a4:	75 da                	jne    f0103480 <env_init+0x26>
    	{
    	envs[i].env_link=&envs[i+1];
    	}
    }
    env_free_list=envs;
f01034a6:	a1 cc e1 17 f0       	mov    0xf017e1cc,%eax
f01034ab:	a3 d0 e1 17 f0       	mov    %eax,0xf017e1d0
	// Per-CPU part of the initialization
	env_init_percpu();
f01034b0:	e8 7b ff ff ff       	call   f0103430 <env_init_percpu>
}
f01034b5:	5b                   	pop    %ebx
f01034b6:	5e                   	pop    %esi
f01034b7:	5f                   	pop    %edi
f01034b8:	5d                   	pop    %ebp
f01034b9:	c3                   	ret    

f01034ba <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01034ba:	55                   	push   %ebp
f01034bb:	89 e5                	mov    %esp,%ebp
f01034bd:	56                   	push   %esi
f01034be:	53                   	push   %ebx
f01034bf:	83 ec 10             	sub    $0x10,%esp
	cprintf("env_alloc");
f01034c2:	c7 04 24 b5 66 10 f0 	movl   $0xf01066b5,(%esp)
f01034c9:	e8 c3 06 00 00       	call   f0103b91 <cprintf>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01034ce:	8b 1d d0 e1 17 f0    	mov    0xf017e1d0,%ebx
f01034d4:	85 db                	test   %ebx,%ebx
f01034d6:	0f 84 7c 01 00 00    	je     f0103658 <env_alloc+0x19e>
static int
env_setup_vm(struct Env *e)
{
	int i;
	struct Page *p = NULL;
	cprintf("env_setup_vm\r\n");
f01034dc:	c7 04 24 bf 66 10 f0 	movl   $0xf01066bf,(%esp)
f01034e3:	e8 a9 06 00 00       	call   f0103b91 <cprintf>
	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01034e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01034ef:	e8 bd d9 ff ff       	call   f0100eb1 <page_alloc>
f01034f4:	85 c0                	test   %eax,%eax
f01034f6:	0f 84 63 01 00 00    	je     f010365f <env_alloc+0x1a5>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01034fc:	89 c2                	mov    %eax,%edx
f01034fe:	2b 15 8c ee 17 f0    	sub    0xf017ee8c,%edx
f0103504:	c1 fa 03             	sar    $0x3,%edx
f0103507:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010350a:	89 d1                	mov    %edx,%ecx
f010350c:	c1 e9 0c             	shr    $0xc,%ecx
f010350f:	3b 0d 84 ee 17 f0    	cmp    0xf017ee84,%ecx
f0103515:	72 20                	jb     f0103537 <env_alloc+0x7d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103517:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010351b:	c7 44 24 08 38 5f 10 	movl   $0xf0105f38,0x8(%esp)
f0103522:	f0 
f0103523:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010352a:	00 
f010352b:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f0103532:	e8 aa cb ff ff       	call   f01000e1 <_panic>
	return (void *)(pa + KERNBASE);
f0103537:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010353d:	89 53 5c             	mov    %edx,0x5c(%ebx)
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
    e->env_pgdir=page2kva(p);
f0103540:	ba ec 0e 00 00       	mov    $0xeec,%edx
    for(i=PDX(UTOP);i<1024;i++)
    {
    	e->env_pgdir[i]=kern_pgdir[i];
f0103545:	8b 0d 88 ee 17 f0    	mov    0xf017ee88,%ecx
f010354b:	8b 34 11             	mov    (%ecx,%edx,1),%esi
f010354e:	8b 4b 5c             	mov    0x5c(%ebx),%ecx
f0103551:	89 34 11             	mov    %esi,(%ecx,%edx,1)
f0103554:	83 c2 04             	add    $0x4,%edx
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
    e->env_pgdir=page2kva(p);
    for(i=PDX(UTOP);i<1024;i++)
f0103557:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f010355d:	75 e6                	jne    f0103545 <env_alloc+0x8b>
    {
    	e->env_pgdir[i]=kern_pgdir[i];
    }
    p->pp_ref++;
f010355f:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103564:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103567:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010356c:	77 20                	ja     f010358e <env_alloc+0xd4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010356e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103572:	c7 44 24 08 7c 60 10 	movl   $0xf010607c,0x8(%esp)
f0103579:	f0 
f010357a:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
f0103581:	00 
f0103582:	c7 04 24 aa 66 10 f0 	movl   $0xf01066aa,(%esp)
f0103589:	e8 53 cb ff ff       	call   f01000e1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010358e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103594:	83 ca 05             	or     $0x5,%edx
f0103597:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010359d:	8b 43 48             	mov    0x48(%ebx),%eax
f01035a0:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01035a5:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01035aa:	ba 00 10 00 00       	mov    $0x1000,%edx
f01035af:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01035b2:	89 da                	mov    %ebx,%edx
f01035b4:	2b 15 cc e1 17 f0    	sub    0xf017e1cc,%edx
f01035ba:	c1 fa 05             	sar    $0x5,%edx
f01035bd:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01035c3:	09 d0                	or     %edx,%eax
f01035c5:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01035c8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035cb:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01035ce:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01035d5:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f01035dc:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01035e3:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01035ea:	00 
f01035eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01035f2:	00 
f01035f3:	89 1c 24             	mov    %ebx,(%esp)
f01035f6:	e8 be 1b 00 00       	call   f01051b9 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01035fb:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103601:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103607:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010360d:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103614:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f010361a:	8b 43 44             	mov    0x44(%ebx),%eax
f010361d:	a3 d0 e1 17 f0       	mov    %eax,0xf017e1d0
	*newenv_store = e;
f0103622:	8b 45 08             	mov    0x8(%ebp),%eax
f0103625:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103627:	8b 53 48             	mov    0x48(%ebx),%edx
f010362a:	a1 c8 e1 17 f0       	mov    0xf017e1c8,%eax
f010362f:	85 c0                	test   %eax,%eax
f0103631:	74 05                	je     f0103638 <env_alloc+0x17e>
f0103633:	8b 40 48             	mov    0x48(%eax),%eax
f0103636:	eb 05                	jmp    f010363d <env_alloc+0x183>
f0103638:	b8 00 00 00 00       	mov    $0x0,%eax
f010363d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103641:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103645:	c7 04 24 ce 66 10 f0 	movl   $0xf01066ce,(%esp)
f010364c:	e8 40 05 00 00       	call   f0103b91 <cprintf>
	return 0;
f0103651:	b8 00 00 00 00       	mov    $0x0,%eax
f0103656:	eb 0c                	jmp    f0103664 <env_alloc+0x1aa>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103658:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010365d:	eb 05                	jmp    f0103664 <env_alloc+0x1aa>
	int i;
	struct Page *p = NULL;
	cprintf("env_setup_vm\r\n");
	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010365f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103664:	83 c4 10             	add    $0x10,%esp
f0103667:	5b                   	pop    %ebx
f0103668:	5e                   	pop    %esi
f0103669:	5d                   	pop    %ebp
f010366a:	c3                   	ret    

f010366b <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f010366b:	55                   	push   %ebp
f010366c:	89 e5                	mov    %esp,%ebp
f010366e:	57                   	push   %edi
f010366f:	56                   	push   %esi
f0103670:	53                   	push   %ebx
f0103671:	83 ec 3c             	sub    $0x3c,%esp
f0103674:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.

	struct Env* env;

	if(env_alloc(&env,0)==0)
f0103677:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010367e:	00 
f010367f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103682:	89 04 24             	mov    %eax,(%esp)
f0103685:	e8 30 fe ff ff       	call   f01034ba <env_alloc>
f010368a:	85 c0                	test   %eax,%eax
f010368c:	0f 85 d1 01 00 00    	jne    f0103863 <env_create+0x1f8>
	{
		env->env_type=type;
f0103692:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103695:	89 c7                	mov    %eax,%edi
f0103697:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010369a:	8b 45 10             	mov    0x10(%ebp),%eax
f010369d:	89 47 50             	mov    %eax,0x50(%edi)
	//  You must also do something with the program's entry point,
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	lcr3(PADDR(e->env_pgdir));
f01036a0:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036a3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036a8:	77 20                	ja     f01036ca <env_create+0x5f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01036ae:	c7 44 24 08 7c 60 10 	movl   $0xf010607c,0x8(%esp)
f01036b5:	f0 
f01036b6:	c7 44 24 04 5f 01 00 	movl   $0x15f,0x4(%esp)
f01036bd:	00 
f01036be:	c7 04 24 aa 66 10 f0 	movl   $0xf01066aa,(%esp)
f01036c5:	e8 17 ca ff ff       	call   f01000e1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01036ca:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01036cf:	0f 22 d8             	mov    %eax,%cr3
	cprintf("load_icode\r\n");
f01036d2:	c7 04 24 e3 66 10 f0 	movl   $0xf01066e3,(%esp)
f01036d9:	e8 b3 04 00 00       	call   f0103b91 <cprintf>
	struct Elf * ELFHDR=(struct Elf *)binary;
	struct Proghdr *ph, *eph;
	int i;
	if (ELFHDR->e_magic != ELF_MAGIC)
f01036de:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f01036e4:	74 1c                	je     f0103702 <env_create+0x97>
			panic("Not a elf binary");
f01036e6:	c7 44 24 08 f0 66 10 	movl   $0xf01066f0,0x8(%esp)
f01036ed:	f0 
f01036ee:	c7 44 24 04 65 01 00 	movl   $0x165,0x4(%esp)
f01036f5:	00 
f01036f6:	c7 04 24 aa 66 10 f0 	movl   $0xf01066aa,(%esp)
f01036fd:	e8 df c9 ff ff       	call   f01000e1 <_panic>


		ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0103702:	89 f3                	mov    %esi,%ebx
f0103704:	03 5e 1c             	add    0x1c(%esi),%ebx
		eph = ph + ELFHDR->e_phnum;
f0103707:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f010370b:	c1 e0 05             	shl    $0x5,%eax
f010370e:	01 d8                	add    %ebx,%eax
f0103710:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		for (; ph < eph; ph++)
f0103713:	39 c3                	cmp    %eax,%ebx
f0103715:	73 5e                	jae    f0103775 <env_create+0x10a>
		{
			// p_pa is the load address of this segment (as well
			// as the physical address)
			if(ph->p_type==ELF_PROG_LOAD)
f0103717:	83 3b 01             	cmpl   $0x1,(%ebx)
f010371a:	75 51                	jne    f010376d <env_create+0x102>
			{
			cprintf("load_prog %08x %08x \r\n",ph->p_filesz,ph->p_va);
f010371c:	8b 43 08             	mov    0x8(%ebx),%eax
f010371f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103723:	8b 43 10             	mov    0x10(%ebx),%eax
f0103726:	89 44 24 04          	mov    %eax,0x4(%esp)
f010372a:	c7 04 24 01 67 10 f0 	movl   $0xf0106701,(%esp)
f0103731:	e8 5b 04 00 00       	call   f0103b91 <cprintf>
			region_alloc(e,(void*)ph->p_va,ph->p_filesz);
f0103736:	8b 4b 10             	mov    0x10(%ebx),%ecx
f0103739:	8b 53 08             	mov    0x8(%ebx),%edx
f010373c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010373f:	e8 d7 fb ff ff       	call   f010331b <region_alloc>
			char* va=(char*)ph->p_va;
f0103744:	8b 7b 08             	mov    0x8(%ebx),%edi
			for(i=0;i<ph->p_filesz;i++)
f0103747:	83 7b 10 00          	cmpl   $0x0,0x10(%ebx)
f010374b:	74 20                	je     f010376d <env_create+0x102>
f010374d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103752:	ba 00 00 00 00       	mov    $0x0,%edx
			{

				va[i]=binary[ph->p_offset+i];
f0103757:	8d 0c 16             	lea    (%esi,%edx,1),%ecx
f010375a:	03 4b 04             	add    0x4(%ebx),%ecx
f010375d:	0f b6 09             	movzbl (%ecx),%ecx
f0103760:	88 0c 17             	mov    %cl,(%edi,%edx,1)
			if(ph->p_type==ELF_PROG_LOAD)
			{
			cprintf("load_prog %08x %08x \r\n",ph->p_filesz,ph->p_va);
			region_alloc(e,(void*)ph->p_va,ph->p_filesz);
			char* va=(char*)ph->p_va;
			for(i=0;i<ph->p_filesz;i++)
f0103763:	83 c0 01             	add    $0x1,%eax
f0103766:	89 c2                	mov    %eax,%edx
f0103768:	3b 43 10             	cmp    0x10(%ebx),%eax
f010376b:	72 ea                	jb     f0103757 <env_create+0xec>
			panic("Not a elf binary");


		ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
		eph = ph + ELFHDR->e_phnum;
		for (; ph < eph; ph++)
f010376d:	83 c3 20             	add    $0x20,%ebx
f0103770:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0103773:	77 a2                	ja     f0103717 <env_create+0xac>
			}

			}
		}
		struct Secthdr *shdr,*eshdr;
		shdr = (struct Secthdr *) ((uint8_t *) ELFHDR + ELFHDR->e_shoff);
f0103775:	89 f3                	mov    %esi,%ebx
f0103777:	03 5e 20             	add    0x20(%esi),%ebx
		eshdr= shdr + ELFHDR->e_shnum;
f010377a:	0f b7 46 30          	movzwl 0x30(%esi),%eax
f010377e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103781:	8d 3c c3             	lea    (%ebx,%eax,8),%edi
				for (; shdr < eshdr; shdr++)
f0103784:	39 fb                	cmp    %edi,%ebx
f0103786:	73 44                	jae    f01037cc <env_create+0x161>
				{
					// p_pa is the load address of this segment (as well
					// as the physical address)
					if(shdr->sh_type==8)
f0103788:	83 7b 04 08          	cmpl   $0x8,0x4(%ebx)
f010378c:	75 37                	jne    f01037c5 <env_create+0x15a>
					{
					cprintf("section %08x %08x %08x %08x\r\n",shdr->sh_size,shdr->sh_addr,shdr->sh_offset,shdr->sh_type);
f010378e:	c7 44 24 10 08 00 00 	movl   $0x8,0x10(%esp)
f0103795:	00 
f0103796:	8b 43 10             	mov    0x10(%ebx),%eax
f0103799:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010379d:	8b 43 0c             	mov    0xc(%ebx),%eax
f01037a0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01037a4:	8b 43 14             	mov    0x14(%ebx),%eax
f01037a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037ab:	c7 04 24 18 67 10 f0 	movl   $0xf0106718,(%esp)
f01037b2:	e8 da 03 00 00       	call   f0103b91 <cprintf>
					region_alloc(e,(void*)shdr->sh_addr,shdr->sh_size);
f01037b7:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01037ba:	8b 53 0c             	mov    0xc(%ebx),%edx
f01037bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01037c0:	e8 56 fb ff ff       	call   f010331b <region_alloc>
			}
		}
		struct Secthdr *shdr,*eshdr;
		shdr = (struct Secthdr *) ((uint8_t *) ELFHDR + ELFHDR->e_shoff);
		eshdr= shdr + ELFHDR->e_shnum;
				for (; shdr < eshdr; shdr++)
f01037c5:	83 c3 28             	add    $0x28,%ebx
f01037c8:	39 df                	cmp    %ebx,%edi
f01037ca:	77 bc                	ja     f0103788 <env_create+0x11d>


					}
				}

		e->env_tf.tf_eip=ELFHDR->e_entry;
f01037cc:	8b 46 18             	mov    0x18(%esi),%eax
f01037cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01037d2:	89 46 30             	mov    %eax,0x30(%esi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
		struct Page* p=(struct Page*)page_alloc(1);
f01037d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01037dc:	e8 d0 d6 ff ff       	call   f0100eb1 <page_alloc>
     if(p==NULL)
f01037e1:	85 c0                	test   %eax,%eax
f01037e3:	75 1c                	jne    f0103801 <env_create+0x196>
    	 panic("Not enough mem for user stack!");
f01037e5:	c7 44 24 08 78 67 10 	movl   $0xf0106778,0x8(%esp)
f01037ec:	f0 
f01037ed:	c7 44 24 04 93 01 00 	movl   $0x193,0x4(%esp)
f01037f4:	00 
f01037f5:	c7 04 24 aa 66 10 f0 	movl   $0xf01066aa,(%esp)
f01037fc:	e8 e0 c8 ff ff       	call   f01000e1 <_panic>
     page_insert(e->env_pgdir,p,(void*)(USTACKTOP-PGSIZE),PTE_W|PTE_U);
f0103801:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103808:	00 
f0103809:	c7 44 24 08 00 d0 bf 	movl   $0xeebfd000,0x8(%esp)
f0103810:	ee 
f0103811:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103815:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103818:	8b 40 5c             	mov    0x5c(%eax),%eax
f010381b:	89 04 24             	mov    %eax,(%esp)
f010381e:	e8 18 d9 ff ff       	call   f010113b <page_insert>
     cprintf("load_icode finish!\r\n");
f0103823:	c7 04 24 36 67 10 f0 	movl   $0xf0106736,(%esp)
f010382a:	e8 62 03 00 00       	call   f0103b91 <cprintf>
     lcr3(PADDR(kern_pgdir));
f010382f:	a1 88 ee 17 f0       	mov    0xf017ee88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103834:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103839:	77 20                	ja     f010385b <env_create+0x1f0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010383b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010383f:	c7 44 24 08 7c 60 10 	movl   $0xf010607c,0x8(%esp)
f0103846:	f0 
f0103847:	c7 44 24 04 96 01 00 	movl   $0x196,0x4(%esp)
f010384e:	00 
f010384f:	c7 04 24 aa 66 10 f0 	movl   $0xf01066aa,(%esp)
f0103856:	e8 86 c8 ff ff       	call   f01000e1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010385b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103860:	0f 22 d8             	mov    %eax,%cr3
	{
		env->env_type=type;
		load_icode(env, binary,size);
	}

}
f0103863:	83 c4 3c             	add    $0x3c,%esp
f0103866:	5b                   	pop    %ebx
f0103867:	5e                   	pop    %esi
f0103868:	5f                   	pop    %edi
f0103869:	5d                   	pop    %ebp
f010386a:	c3                   	ret    

f010386b <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010386b:	55                   	push   %ebp
f010386c:	89 e5                	mov    %esp,%ebp
f010386e:	57                   	push   %edi
f010386f:	56                   	push   %esi
f0103870:	53                   	push   %ebx
f0103871:	83 ec 2c             	sub    $0x2c,%esp
f0103874:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103877:	a1 c8 e1 17 f0       	mov    0xf017e1c8,%eax
f010387c:	39 c7                	cmp    %eax,%edi
f010387e:	75 37                	jne    f01038b7 <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f0103880:	8b 15 88 ee 17 f0    	mov    0xf017ee88,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103886:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010388c:	77 20                	ja     f01038ae <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010388e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103892:	c7 44 24 08 7c 60 10 	movl   $0xf010607c,0x8(%esp)
f0103899:	f0 
f010389a:	c7 44 24 04 bd 01 00 	movl   $0x1bd,0x4(%esp)
f01038a1:	00 
f01038a2:	c7 04 24 aa 66 10 f0 	movl   $0xf01066aa,(%esp)
f01038a9:	e8 33 c8 ff ff       	call   f01000e1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01038ae:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01038b4:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01038b7:	8b 57 48             	mov    0x48(%edi),%edx
f01038ba:	85 c0                	test   %eax,%eax
f01038bc:	74 05                	je     f01038c3 <env_free+0x58>
f01038be:	8b 40 48             	mov    0x48(%eax),%eax
f01038c1:	eb 05                	jmp    f01038c8 <env_free+0x5d>
f01038c3:	b8 00 00 00 00       	mov    $0x0,%eax
f01038c8:	89 54 24 08          	mov    %edx,0x8(%esp)
f01038cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01038d0:	c7 04 24 4b 67 10 f0 	movl   $0xf010674b,(%esp)
f01038d7:	e8 b5 02 00 00       	call   f0103b91 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01038dc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01038e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01038e6:	89 c8                	mov    %ecx,%eax
f01038e8:	c1 e0 02             	shl    $0x2,%eax
f01038eb:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01038ee:	8b 47 5c             	mov    0x5c(%edi),%eax
f01038f1:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f01038f4:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01038fa:	0f 84 b7 00 00 00    	je     f01039b7 <env_free+0x14c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103900:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103906:	89 f0                	mov    %esi,%eax
f0103908:	c1 e8 0c             	shr    $0xc,%eax
f010390b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010390e:	3b 05 84 ee 17 f0    	cmp    0xf017ee84,%eax
f0103914:	72 20                	jb     f0103936 <env_free+0xcb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103916:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010391a:	c7 44 24 08 38 5f 10 	movl   $0xf0105f38,0x8(%esp)
f0103921:	f0 
f0103922:	c7 44 24 04 cc 01 00 	movl   $0x1cc,0x4(%esp)
f0103929:	00 
f010392a:	c7 04 24 aa 66 10 f0 	movl   $0xf01066aa,(%esp)
f0103931:	e8 ab c7 ff ff       	call   f01000e1 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103936:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103939:	c1 e0 16             	shl    $0x16,%eax
f010393c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010393f:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103944:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f010394b:	01 
f010394c:	74 17                	je     f0103965 <env_free+0xfa>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010394e:	89 d8                	mov    %ebx,%eax
f0103950:	c1 e0 0c             	shl    $0xc,%eax
f0103953:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103956:	89 44 24 04          	mov    %eax,0x4(%esp)
f010395a:	8b 47 5c             	mov    0x5c(%edi),%eax
f010395d:	89 04 24             	mov    %eax,(%esp)
f0103960:	e8 91 d7 ff ff       	call   f01010f6 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103965:	83 c3 01             	add    $0x1,%ebx
f0103968:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010396e:	75 d4                	jne    f0103944 <env_free+0xd9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103970:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103973:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103976:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010397d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103980:	3b 05 84 ee 17 f0    	cmp    0xf017ee84,%eax
f0103986:	72 1c                	jb     f01039a4 <env_free+0x139>
		panic("pa2page called with invalid pa");
f0103988:	c7 44 24 08 20 60 10 	movl   $0xf0106020,0x8(%esp)
f010398f:	f0 
f0103990:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103997:	00 
f0103998:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f010399f:	e8 3d c7 ff ff       	call   f01000e1 <_panic>
	return &pages[PGNUM(pa)];
f01039a4:	a1 8c ee 17 f0       	mov    0xf017ee8c,%eax
f01039a9:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01039ac:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f01039af:	89 04 24             	mov    %eax,(%esp)
f01039b2:	e8 9a d5 ff ff       	call   f0100f51 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01039b7:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01039bb:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f01039c2:	0f 85 1b ff ff ff    	jne    f01038e3 <env_free+0x78>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01039c8:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039cb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039d0:	77 20                	ja     f01039f2 <env_free+0x187>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039d6:	c7 44 24 08 7c 60 10 	movl   $0xf010607c,0x8(%esp)
f01039dd:	f0 
f01039de:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
f01039e5:	00 
f01039e6:	c7 04 24 aa 66 10 f0 	movl   $0xf01066aa,(%esp)
f01039ed:	e8 ef c6 ff ff       	call   f01000e1 <_panic>
	e->env_pgdir = 0;
f01039f2:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f01039f9:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01039fe:	c1 e8 0c             	shr    $0xc,%eax
f0103a01:	3b 05 84 ee 17 f0    	cmp    0xf017ee84,%eax
f0103a07:	72 1c                	jb     f0103a25 <env_free+0x1ba>
		panic("pa2page called with invalid pa");
f0103a09:	c7 44 24 08 20 60 10 	movl   $0xf0106020,0x8(%esp)
f0103a10:	f0 
f0103a11:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103a18:	00 
f0103a19:	c7 04 24 d2 5b 10 f0 	movl   $0xf0105bd2,(%esp)
f0103a20:	e8 bc c6 ff ff       	call   f01000e1 <_panic>
	return &pages[PGNUM(pa)];
f0103a25:	8b 15 8c ee 17 f0    	mov    0xf017ee8c,%edx
f0103a2b:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103a2e:	89 04 24             	mov    %eax,(%esp)
f0103a31:	e8 1b d5 ff ff       	call   f0100f51 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103a36:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103a3d:	a1 d0 e1 17 f0       	mov    0xf017e1d0,%eax
f0103a42:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103a45:	89 3d d0 e1 17 f0    	mov    %edi,0xf017e1d0
}
f0103a4b:	83 c4 2c             	add    $0x2c,%esp
f0103a4e:	5b                   	pop    %ebx
f0103a4f:	5e                   	pop    %esi
f0103a50:	5f                   	pop    %edi
f0103a51:	5d                   	pop    %ebp
f0103a52:	c3                   	ret    

f0103a53 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103a53:	55                   	push   %ebp
f0103a54:	89 e5                	mov    %esp,%ebp
f0103a56:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0103a59:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a5c:	89 04 24             	mov    %eax,(%esp)
f0103a5f:	e8 07 fe ff ff       	call   f010386b <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103a64:	c7 04 24 98 67 10 f0 	movl   $0xf0106798,(%esp)
f0103a6b:	e8 21 01 00 00       	call   f0103b91 <cprintf>
	while (1)
		monitor(NULL);
f0103a70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103a77:	e8 8b cd ff ff       	call   f0100807 <monitor>
f0103a7c:	eb f2                	jmp    f0103a70 <env_destroy+0x1d>

f0103a7e <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103a7e:	55                   	push   %ebp
f0103a7f:	89 e5                	mov    %esp,%ebp
f0103a81:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0103a84:	8b 65 08             	mov    0x8(%ebp),%esp
f0103a87:	61                   	popa   
f0103a88:	07                   	pop    %es
f0103a89:	1f                   	pop    %ds
f0103a8a:	83 c4 08             	add    $0x8,%esp
f0103a8d:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103a8e:	c7 44 24 08 61 67 10 	movl   $0xf0106761,0x8(%esp)
f0103a95:	f0 
f0103a96:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
f0103a9d:	00 
f0103a9e:	c7 04 24 aa 66 10 f0 	movl   $0xf01066aa,(%esp)
f0103aa5:	e8 37 c6 ff ff       	call   f01000e1 <_panic>

f0103aaa <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103aaa:	55                   	push   %ebp
f0103aab:	89 e5                	mov    %esp,%ebp
f0103aad:	53                   	push   %ebx
f0103aae:	83 ec 14             	sub    $0x14,%esp
f0103ab1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	cprintf("Run env!\r\n");
f0103ab4:	c7 04 24 6d 67 10 f0 	movl   $0xf010676d,(%esp)
f0103abb:	e8 d1 00 00 00       	call   f0103b91 <cprintf>
    if(curenv!=NULL)
f0103ac0:	a1 c8 e1 17 f0       	mov    0xf017e1c8,%eax
f0103ac5:	85 c0                	test   %eax,%eax
f0103ac7:	74 0d                	je     f0103ad6 <env_run+0x2c>
    {
    	if(curenv->env_status==ENV_RUNNING)
f0103ac9:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0103acd:	75 07                	jne    f0103ad6 <env_run+0x2c>
    	{
    		curenv->env_status=ENV_RUNNABLE;
f0103acf:	c7 40 54 01 00 00 00 	movl   $0x1,0x54(%eax)
    	}
    }
    curenv=e;
f0103ad6:	89 1d c8 e1 17 f0    	mov    %ebx,0xf017e1c8
    e->env_status=ENV_RUNNING;
f0103adc:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
    e->env_runs++;
f0103ae3:	83 43 58 01          	addl   $0x1,0x58(%ebx)
    lcr3(PADDR(e->env_pgdir));
f0103ae7:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103aea:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103aef:	77 20                	ja     f0103b11 <env_run+0x67>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103af1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103af5:	c7 44 24 08 7c 60 10 	movl   $0xf010607c,0x8(%esp)
f0103afc:	f0 
f0103afd:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
f0103b04:	00 
f0103b05:	c7 04 24 aa 66 10 f0 	movl   $0xf01066aa,(%esp)
f0103b0c:	e8 d0 c5 ff ff       	call   f01000e1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103b11:	05 00 00 00 10       	add    $0x10000000,%eax
f0103b16:	0f 22 d8             	mov    %eax,%cr3
    env_pop_tf(&e->env_tf);
f0103b19:	89 1c 24             	mov    %ebx,(%esp)
f0103b1c:	e8 5d ff ff ff       	call   f0103a7e <env_pop_tf>

f0103b21 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103b21:	55                   	push   %ebp
f0103b22:	89 e5                	mov    %esp,%ebp
f0103b24:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103b28:	ba 70 00 00 00       	mov    $0x70,%edx
f0103b2d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103b2e:	b2 71                	mov    $0x71,%dl
f0103b30:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103b31:	0f b6 c0             	movzbl %al,%eax
}
f0103b34:	5d                   	pop    %ebp
f0103b35:	c3                   	ret    

f0103b36 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103b36:	55                   	push   %ebp
f0103b37:	89 e5                	mov    %esp,%ebp
f0103b39:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103b3d:	ba 70 00 00 00       	mov    $0x70,%edx
f0103b42:	ee                   	out    %al,(%dx)
f0103b43:	b2 71                	mov    $0x71,%dl
f0103b45:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b48:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103b49:	5d                   	pop    %ebp
f0103b4a:	c3                   	ret    

f0103b4b <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103b4b:	55                   	push   %ebp
f0103b4c:	89 e5                	mov    %esp,%ebp
f0103b4e:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103b51:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b54:	89 04 24             	mov    %eax,(%esp)
f0103b57:	e8 f8 ca ff ff       	call   f0100654 <cputchar>
	*cnt++;
}
f0103b5c:	c9                   	leave  
f0103b5d:	c3                   	ret    

f0103b5e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103b5e:	55                   	push   %ebp
f0103b5f:	89 e5                	mov    %esp,%ebp
f0103b61:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103b64:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103b6b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b72:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b75:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103b79:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103b7c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b80:	c7 04 24 4b 3b 10 f0 	movl   $0xf0103b4b,(%esp)
f0103b87:	e8 2e 0e 00 00       	call   f01049ba <vprintfmt>
	return cnt;
}
f0103b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b8f:	c9                   	leave  
f0103b90:	c3                   	ret    

f0103b91 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103b91:	55                   	push   %ebp
f0103b92:	89 e5                	mov    %esp,%ebp
f0103b94:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103b97:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103b9a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b9e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ba1:	89 04 24             	mov    %eax,(%esp)
f0103ba4:	e8 b5 ff ff ff       	call   f0103b5e <vcprintf>
	va_end(ap);

	return cnt;
}
f0103ba9:	c9                   	leave  
f0103baa:	c3                   	ret    
f0103bab:	66 90                	xchg   %ax,%ax
f0103bad:	66 90                	xchg   %ax,%ax
f0103baf:	90                   	nop

f0103bb0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103bb0:	55                   	push   %ebp
f0103bb1:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103bb3:	c7 05 04 ea 17 f0 00 	movl   $0xefc00000,0xf017ea04
f0103bba:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f0103bbd:	66 c7 05 08 ea 17 f0 	movw   $0x10,0xf017ea08
f0103bc4:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103bc6:	66 c7 05 48 c3 11 f0 	movw   $0x68,0xf011c348
f0103bcd:	68 00 
f0103bcf:	b8 00 ea 17 f0       	mov    $0xf017ea00,%eax
f0103bd4:	66 a3 4a c3 11 f0    	mov    %ax,0xf011c34a
f0103bda:	89 c2                	mov    %eax,%edx
f0103bdc:	c1 ea 10             	shr    $0x10,%edx
f0103bdf:	88 15 4c c3 11 f0    	mov    %dl,0xf011c34c
f0103be5:	c6 05 4e c3 11 f0 40 	movb   $0x40,0xf011c34e
f0103bec:	c1 e8 18             	shr    $0x18,%eax
f0103bef:	a2 4f c3 11 f0       	mov    %al,0xf011c34f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103bf4:	c6 05 4d c3 11 f0 89 	movb   $0x89,0xf011c34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103bfb:	b8 28 00 00 00       	mov    $0x28,%eax
f0103c00:	0f 00 d8             	ltr    %ax
}  

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103c03:	b8 50 c3 11 f0       	mov    $0xf011c350,%eax
f0103c08:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103c0b:	5d                   	pop    %ebp
f0103c0c:	c3                   	ret    

f0103c0d <trap_init>:
}


void
trap_init(void)
{
f0103c0d:	55                   	push   %ebp
f0103c0e:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];
	SETGATE(idt[0], 1, GD_KT, dividezero_handler, 0);
f0103c10:	b8 20 43 10 f0       	mov    $0xf0104320,%eax
f0103c15:	66 a3 e0 e1 17 f0    	mov    %ax,0xf017e1e0
f0103c1b:	66 c7 05 e2 e1 17 f0 	movw   $0x8,0xf017e1e2
f0103c22:	08 00 
f0103c24:	c6 05 e4 e1 17 f0 00 	movb   $0x0,0xf017e1e4
f0103c2b:	c6 05 e5 e1 17 f0 8f 	movb   $0x8f,0xf017e1e5
f0103c32:	c1 e8 10             	shr    $0x10,%eax
f0103c35:	66 a3 e6 e1 17 f0    	mov    %ax,0xf017e1e6
	SETGATE(idt[2], 0, GD_KT, nmi_handler, 0);
f0103c3b:	b8 26 43 10 f0       	mov    $0xf0104326,%eax
f0103c40:	66 a3 f0 e1 17 f0    	mov    %ax,0xf017e1f0
f0103c46:	66 c7 05 f2 e1 17 f0 	movw   $0x8,0xf017e1f2
f0103c4d:	08 00 
f0103c4f:	c6 05 f4 e1 17 f0 00 	movb   $0x0,0xf017e1f4
f0103c56:	c6 05 f5 e1 17 f0 8e 	movb   $0x8e,0xf017e1f5
f0103c5d:	c1 e8 10             	shr    $0x10,%eax
f0103c60:	66 a3 f6 e1 17 f0    	mov    %ax,0xf017e1f6
	SETGATE(idt[3], 1, GD_KT, breakpoint_handler, 3);
f0103c66:	b8 2c 43 10 f0       	mov    $0xf010432c,%eax
f0103c6b:	66 a3 f8 e1 17 f0    	mov    %ax,0xf017e1f8
f0103c71:	66 c7 05 fa e1 17 f0 	movw   $0x8,0xf017e1fa
f0103c78:	08 00 
f0103c7a:	c6 05 fc e1 17 f0 00 	movb   $0x0,0xf017e1fc
f0103c81:	c6 05 fd e1 17 f0 ef 	movb   $0xef,0xf017e1fd
f0103c88:	c1 e8 10             	shr    $0x10,%eax
f0103c8b:	66 a3 fe e1 17 f0    	mov    %ax,0xf017e1fe
	SETGATE(idt[4], 1, GD_KT, overflow_handler, 3);
f0103c91:	b8 32 43 10 f0       	mov    $0xf0104332,%eax
f0103c96:	66 a3 00 e2 17 f0    	mov    %ax,0xf017e200
f0103c9c:	66 c7 05 02 e2 17 f0 	movw   $0x8,0xf017e202
f0103ca3:	08 00 
f0103ca5:	c6 05 04 e2 17 f0 00 	movb   $0x0,0xf017e204
f0103cac:	c6 05 05 e2 17 f0 ef 	movb   $0xef,0xf017e205
f0103cb3:	c1 e8 10             	shr    $0x10,%eax
f0103cb6:	66 a3 06 e2 17 f0    	mov    %ax,0xf017e206
	SETGATE(idt[5], 1, GD_KT, bdrgeexceed_handler, 3);
f0103cbc:	b8 38 43 10 f0       	mov    $0xf0104338,%eax
f0103cc1:	66 a3 08 e2 17 f0    	mov    %ax,0xf017e208
f0103cc7:	66 c7 05 0a e2 17 f0 	movw   $0x8,0xf017e20a
f0103cce:	08 00 
f0103cd0:	c6 05 0c e2 17 f0 00 	movb   $0x0,0xf017e20c
f0103cd7:	c6 05 0d e2 17 f0 ef 	movb   $0xef,0xf017e20d
f0103cde:	c1 e8 10             	shr    $0x10,%eax
f0103ce1:	66 a3 0e e2 17 f0    	mov    %ax,0xf017e20e
	SETGATE(idt[6], 1, GD_KT, invalidop_handler, 0);
f0103ce7:	b8 3e 43 10 f0       	mov    $0xf010433e,%eax
f0103cec:	66 a3 10 e2 17 f0    	mov    %ax,0xf017e210
f0103cf2:	66 c7 05 12 e2 17 f0 	movw   $0x8,0xf017e212
f0103cf9:	08 00 
f0103cfb:	c6 05 14 e2 17 f0 00 	movb   $0x0,0xf017e214
f0103d02:	c6 05 15 e2 17 f0 8f 	movb   $0x8f,0xf017e215
f0103d09:	c1 e8 10             	shr    $0x10,%eax
f0103d0c:	66 a3 16 e2 17 f0    	mov    %ax,0xf017e216
	SETGATE(idt[7], 1, GD_KT, nomathcopro_handler, 0);
f0103d12:	b8 44 43 10 f0       	mov    $0xf0104344,%eax
f0103d17:	66 a3 18 e2 17 f0    	mov    %ax,0xf017e218
f0103d1d:	66 c7 05 1a e2 17 f0 	movw   $0x8,0xf017e21a
f0103d24:	08 00 
f0103d26:	c6 05 1c e2 17 f0 00 	movb   $0x0,0xf017e21c
f0103d2d:	c6 05 1d e2 17 f0 8f 	movb   $0x8f,0xf017e21d
f0103d34:	c1 e8 10             	shr    $0x10,%eax
f0103d37:	66 a3 1e e2 17 f0    	mov    %ax,0xf017e21e
	SETGATE(idt[8], 1, GD_KT, dbfault_handler, 0);
f0103d3d:	b8 4a 43 10 f0       	mov    $0xf010434a,%eax
f0103d42:	66 a3 20 e2 17 f0    	mov    %ax,0xf017e220
f0103d48:	66 c7 05 22 e2 17 f0 	movw   $0x8,0xf017e222
f0103d4f:	08 00 
f0103d51:	c6 05 24 e2 17 f0 00 	movb   $0x0,0xf017e224
f0103d58:	c6 05 25 e2 17 f0 8f 	movb   $0x8f,0xf017e225
f0103d5f:	c1 e8 10             	shr    $0x10,%eax
f0103d62:	66 a3 26 e2 17 f0    	mov    %ax,0xf017e226
	SETGATE(idt[10], 1, GD_KT, invalidTSS_handler, 0);
f0103d68:	b8 4e 43 10 f0       	mov    $0xf010434e,%eax
f0103d6d:	66 a3 30 e2 17 f0    	mov    %ax,0xf017e230
f0103d73:	66 c7 05 32 e2 17 f0 	movw   $0x8,0xf017e232
f0103d7a:	08 00 
f0103d7c:	c6 05 34 e2 17 f0 00 	movb   $0x0,0xf017e234
f0103d83:	c6 05 35 e2 17 f0 8f 	movb   $0x8f,0xf017e235
f0103d8a:	c1 e8 10             	shr    $0x10,%eax
f0103d8d:	66 a3 36 e2 17 f0    	mov    %ax,0xf017e236

	SETGATE(idt[11], 1, GD_KT, sgmtnotpresent_handler, 0);
f0103d93:	b8 52 43 10 f0       	mov    $0xf0104352,%eax
f0103d98:	66 a3 38 e2 17 f0    	mov    %ax,0xf017e238
f0103d9e:	66 c7 05 3a e2 17 f0 	movw   $0x8,0xf017e23a
f0103da5:	08 00 
f0103da7:	c6 05 3c e2 17 f0 00 	movb   $0x0,0xf017e23c
f0103dae:	c6 05 3d e2 17 f0 8f 	movb   $0x8f,0xf017e23d
f0103db5:	c1 e8 10             	shr    $0x10,%eax
f0103db8:	66 a3 3e e2 17 f0    	mov    %ax,0xf017e23e
	SETGATE(idt[12], 1, GD_KT, stacksgmtfault_handler, 0);
f0103dbe:	b8 56 43 10 f0       	mov    $0xf0104356,%eax
f0103dc3:	66 a3 40 e2 17 f0    	mov    %ax,0xf017e240
f0103dc9:	66 c7 05 42 e2 17 f0 	movw   $0x8,0xf017e242
f0103dd0:	08 00 
f0103dd2:	c6 05 44 e2 17 f0 00 	movb   $0x0,0xf017e244
f0103dd9:	c6 05 45 e2 17 f0 8f 	movb   $0x8f,0xf017e245
f0103de0:	c1 e8 10             	shr    $0x10,%eax
f0103de3:	66 a3 46 e2 17 f0    	mov    %ax,0xf017e246
	SETGATE(idt[14], 1, GD_KT, pagefault_handler, 0);
f0103de9:	b8 5e 43 10 f0       	mov    $0xf010435e,%eax
f0103dee:	66 a3 50 e2 17 f0    	mov    %ax,0xf017e250
f0103df4:	66 c7 05 52 e2 17 f0 	movw   $0x8,0xf017e252
f0103dfb:	08 00 
f0103dfd:	c6 05 54 e2 17 f0 00 	movb   $0x0,0xf017e254
f0103e04:	c6 05 55 e2 17 f0 8f 	movb   $0x8f,0xf017e255
f0103e0b:	c1 e8 10             	shr    $0x10,%eax
f0103e0e:	66 a3 56 e2 17 f0    	mov    %ax,0xf017e256
	SETGATE(idt[13], 1, GD_KT, generalprotection_handler, 0);
f0103e14:	b8 5a 43 10 f0       	mov    $0xf010435a,%eax
f0103e19:	66 a3 48 e2 17 f0    	mov    %ax,0xf017e248
f0103e1f:	66 c7 05 4a e2 17 f0 	movw   $0x8,0xf017e24a
f0103e26:	08 00 
f0103e28:	c6 05 4c e2 17 f0 00 	movb   $0x0,0xf017e24c
f0103e2f:	c6 05 4d e2 17 f0 8f 	movb   $0x8f,0xf017e24d
f0103e36:	c1 e8 10             	shr    $0x10,%eax
f0103e39:	66 a3 4e e2 17 f0    	mov    %ax,0xf017e24e
	SETGATE(idt[16], 1, GD_KT, FPUerror_handler, 0);
f0103e3f:	b8 62 43 10 f0       	mov    $0xf0104362,%eax
f0103e44:	66 a3 60 e2 17 f0    	mov    %ax,0xf017e260
f0103e4a:	66 c7 05 62 e2 17 f0 	movw   $0x8,0xf017e262
f0103e51:	08 00 
f0103e53:	c6 05 64 e2 17 f0 00 	movb   $0x0,0xf017e264
f0103e5a:	c6 05 65 e2 17 f0 8f 	movb   $0x8f,0xf017e265
f0103e61:	c1 e8 10             	shr    $0x10,%eax
f0103e64:	66 a3 66 e2 17 f0    	mov    %ax,0xf017e266
	SETGATE(idt[17], 1, GD_KT, alignmentcheck_handler, 0);
f0103e6a:	b8 68 43 10 f0       	mov    $0xf0104368,%eax
f0103e6f:	66 a3 68 e2 17 f0    	mov    %ax,0xf017e268
f0103e75:	66 c7 05 6a e2 17 f0 	movw   $0x8,0xf017e26a
f0103e7c:	08 00 
f0103e7e:	c6 05 6c e2 17 f0 00 	movb   $0x0,0xf017e26c
f0103e85:	c6 05 6d e2 17 f0 8f 	movb   $0x8f,0xf017e26d
f0103e8c:	c1 e8 10             	shr    $0x10,%eax
f0103e8f:	66 a3 6e e2 17 f0    	mov    %ax,0xf017e26e
	SETGATE(idt[18],1, GD_KT, machinecheck_handler, 0);
f0103e95:	b8 6c 43 10 f0       	mov    $0xf010436c,%eax
f0103e9a:	66 a3 70 e2 17 f0    	mov    %ax,0xf017e270
f0103ea0:	66 c7 05 72 e2 17 f0 	movw   $0x8,0xf017e272
f0103ea7:	08 00 
f0103ea9:	c6 05 74 e2 17 f0 00 	movb   $0x0,0xf017e274
f0103eb0:	c6 05 75 e2 17 f0 8f 	movb   $0x8f,0xf017e275
f0103eb7:	c1 e8 10             	shr    $0x10,%eax
f0103eba:	66 a3 76 e2 17 f0    	mov    %ax,0xf017e276
	SETGATE(idt[19], 1, GD_KT, SIMDFPexception_handler, 0);
f0103ec0:	b8 72 43 10 f0       	mov    $0xf0104372,%eax
f0103ec5:	66 a3 78 e2 17 f0    	mov    %ax,0xf017e278
f0103ecb:	66 c7 05 7a e2 17 f0 	movw   $0x8,0xf017e27a
f0103ed2:	08 00 
f0103ed4:	c6 05 7c e2 17 f0 00 	movb   $0x0,0xf017e27c
f0103edb:	c6 05 7d e2 17 f0 8f 	movb   $0x8f,0xf017e27d
f0103ee2:	c1 e8 10             	shr    $0x10,%eax
f0103ee5:	66 a3 7e e2 17 f0    	mov    %ax,0xf017e27e
	SETGATE(idt[48], 0, GD_KT, systemcall_handler, 3);
f0103eeb:	b8 78 43 10 f0       	mov    $0xf0104378,%eax
f0103ef0:	66 a3 60 e3 17 f0    	mov    %ax,0xf017e360
f0103ef6:	66 c7 05 62 e3 17 f0 	movw   $0x8,0xf017e362
f0103efd:	08 00 
f0103eff:	c6 05 64 e3 17 f0 00 	movb   $0x0,0xf017e364
f0103f06:	c6 05 65 e3 17 f0 ee 	movb   $0xee,0xf017e365
f0103f0d:	c1 e8 10             	shr    $0x10,%eax
f0103f10:	66 a3 66 e3 17 f0    	mov    %ax,0xf017e366
	// LAB 3: Your code here.

	// Per-CPU setup 
	trap_init_percpu();
f0103f16:	e8 95 fc ff ff       	call   f0103bb0 <trap_init_percpu>
}
f0103f1b:	5d                   	pop    %ebp
f0103f1c:	c3                   	ret    

f0103f1d <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103f1d:	55                   	push   %ebp
f0103f1e:	89 e5                	mov    %esp,%ebp
f0103f20:	53                   	push   %ebx
f0103f21:	83 ec 14             	sub    $0x14,%esp
f0103f24:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103f27:	8b 03                	mov    (%ebx),%eax
f0103f29:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f2d:	c7 04 24 ce 67 10 f0 	movl   $0xf01067ce,(%esp)
f0103f34:	e8 58 fc ff ff       	call   f0103b91 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103f39:	8b 43 04             	mov    0x4(%ebx),%eax
f0103f3c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f40:	c7 04 24 dd 67 10 f0 	movl   $0xf01067dd,(%esp)
f0103f47:	e8 45 fc ff ff       	call   f0103b91 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103f4c:	8b 43 08             	mov    0x8(%ebx),%eax
f0103f4f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f53:	c7 04 24 ec 67 10 f0 	movl   $0xf01067ec,(%esp)
f0103f5a:	e8 32 fc ff ff       	call   f0103b91 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103f5f:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103f62:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f66:	c7 04 24 fb 67 10 f0 	movl   $0xf01067fb,(%esp)
f0103f6d:	e8 1f fc ff ff       	call   f0103b91 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103f72:	8b 43 10             	mov    0x10(%ebx),%eax
f0103f75:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f79:	c7 04 24 0a 68 10 f0 	movl   $0xf010680a,(%esp)
f0103f80:	e8 0c fc ff ff       	call   f0103b91 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103f85:	8b 43 14             	mov    0x14(%ebx),%eax
f0103f88:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f8c:	c7 04 24 19 68 10 f0 	movl   $0xf0106819,(%esp)
f0103f93:	e8 f9 fb ff ff       	call   f0103b91 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103f98:	8b 43 18             	mov    0x18(%ebx),%eax
f0103f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f9f:	c7 04 24 28 68 10 f0 	movl   $0xf0106828,(%esp)
f0103fa6:	e8 e6 fb ff ff       	call   f0103b91 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103fab:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103fae:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fb2:	c7 04 24 37 68 10 f0 	movl   $0xf0106837,(%esp)
f0103fb9:	e8 d3 fb ff ff       	call   f0103b91 <cprintf>
}
f0103fbe:	83 c4 14             	add    $0x14,%esp
f0103fc1:	5b                   	pop    %ebx
f0103fc2:	5d                   	pop    %ebp
f0103fc3:	c3                   	ret    

f0103fc4 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103fc4:	55                   	push   %ebp
f0103fc5:	89 e5                	mov    %esp,%ebp
f0103fc7:	56                   	push   %esi
f0103fc8:	53                   	push   %ebx
f0103fc9:	83 ec 10             	sub    $0x10,%esp
f0103fcc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103fcf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103fd3:	c7 04 24 87 69 10 f0 	movl   $0xf0106987,(%esp)
f0103fda:	e8 b2 fb ff ff       	call   f0103b91 <cprintf>
	print_regs(&tf->tf_regs);
f0103fdf:	89 1c 24             	mov    %ebx,(%esp)
f0103fe2:	e8 36 ff ff ff       	call   f0103f1d <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103fe7:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103feb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fef:	c7 04 24 88 68 10 f0 	movl   $0xf0106888,(%esp)
f0103ff6:	e8 96 fb ff ff       	call   f0103b91 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103ffb:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103fff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104003:	c7 04 24 9b 68 10 f0 	movl   $0xf010689b,(%esp)
f010400a:	e8 82 fb ff ff       	call   f0103b91 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010400f:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0104012:	83 f8 13             	cmp    $0x13,%eax
f0104015:	77 09                	ja     f0104020 <print_trapframe+0x5c>
		return excnames[trapno];
f0104017:	8b 14 85 60 6b 10 f0 	mov    -0xfef94a0(,%eax,4),%edx
f010401e:	eb 10                	jmp    f0104030 <print_trapframe+0x6c>
	if (trapno == T_SYSCALL)
		return "System call";
f0104020:	83 f8 30             	cmp    $0x30,%eax
f0104023:	ba 46 68 10 f0       	mov    $0xf0106846,%edx
f0104028:	b9 52 68 10 f0       	mov    $0xf0106852,%ecx
f010402d:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104030:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104034:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104038:	c7 04 24 ae 68 10 f0 	movl   $0xf01068ae,(%esp)
f010403f:	e8 4d fb ff ff       	call   f0103b91 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104044:	3b 1d e0 e9 17 f0    	cmp    0xf017e9e0,%ebx
f010404a:	75 19                	jne    f0104065 <print_trapframe+0xa1>
f010404c:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104050:	75 13                	jne    f0104065 <print_trapframe+0xa1>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104052:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104055:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104059:	c7 04 24 c0 68 10 f0 	movl   $0xf01068c0,(%esp)
f0104060:	e8 2c fb ff ff       	call   f0103b91 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104065:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104068:	89 44 24 04          	mov    %eax,0x4(%esp)
f010406c:	c7 04 24 cf 68 10 f0 	movl   $0xf01068cf,(%esp)
f0104073:	e8 19 fb ff ff       	call   f0103b91 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104078:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010407c:	75 51                	jne    f01040cf <print_trapframe+0x10b>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010407e:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104081:	89 c2                	mov    %eax,%edx
f0104083:	83 e2 01             	and    $0x1,%edx
f0104086:	ba 61 68 10 f0       	mov    $0xf0106861,%edx
f010408b:	b9 6c 68 10 f0       	mov    $0xf010686c,%ecx
f0104090:	0f 45 ca             	cmovne %edx,%ecx
f0104093:	89 c2                	mov    %eax,%edx
f0104095:	83 e2 02             	and    $0x2,%edx
f0104098:	ba 78 68 10 f0       	mov    $0xf0106878,%edx
f010409d:	be 7e 68 10 f0       	mov    $0xf010687e,%esi
f01040a2:	0f 44 d6             	cmove  %esi,%edx
f01040a5:	83 e0 04             	and    $0x4,%eax
f01040a8:	b8 83 68 10 f0       	mov    $0xf0106883,%eax
f01040ad:	be b2 69 10 f0       	mov    $0xf01069b2,%esi
f01040b2:	0f 44 c6             	cmove  %esi,%eax
f01040b5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01040b9:	89 54 24 08          	mov    %edx,0x8(%esp)
f01040bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040c1:	c7 04 24 dd 68 10 f0 	movl   $0xf01068dd,(%esp)
f01040c8:	e8 c4 fa ff ff       	call   f0103b91 <cprintf>
f01040cd:	eb 0c                	jmp    f01040db <print_trapframe+0x117>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01040cf:	c7 04 24 9e 5c 10 f0 	movl   $0xf0105c9e,(%esp)
f01040d6:	e8 b6 fa ff ff       	call   f0103b91 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01040db:	8b 43 30             	mov    0x30(%ebx),%eax
f01040de:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040e2:	c7 04 24 ec 68 10 f0 	movl   $0xf01068ec,(%esp)
f01040e9:	e8 a3 fa ff ff       	call   f0103b91 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01040ee:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01040f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040f6:	c7 04 24 fb 68 10 f0 	movl   $0xf01068fb,(%esp)
f01040fd:	e8 8f fa ff ff       	call   f0103b91 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104102:	8b 43 38             	mov    0x38(%ebx),%eax
f0104105:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104109:	c7 04 24 0e 69 10 f0 	movl   $0xf010690e,(%esp)
f0104110:	e8 7c fa ff ff       	call   f0103b91 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104115:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104119:	74 27                	je     f0104142 <print_trapframe+0x17e>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010411b:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010411e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104122:	c7 04 24 1d 69 10 f0 	movl   $0xf010691d,(%esp)
f0104129:	e8 63 fa ff ff       	call   f0103b91 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010412e:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104132:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104136:	c7 04 24 2c 69 10 f0 	movl   $0xf010692c,(%esp)
f010413d:	e8 4f fa ff ff       	call   f0103b91 <cprintf>
	}
}
f0104142:	83 c4 10             	add    $0x10,%esp
f0104145:	5b                   	pop    %ebx
f0104146:	5e                   	pop    %esi
f0104147:	5d                   	pop    %ebp
f0104148:	c3                   	ret    

f0104149 <break_point_handler>:
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
	cprintf("  eax  0x%08x\n", regs->reg_eax);
}
void
break_point_handler(struct Trapframe *tf)
{
f0104149:	55                   	push   %ebp
f010414a:	89 e5                	mov    %esp,%ebp
f010414c:	83 ec 18             	sub    $0x18,%esp
	monitor(tf);
f010414f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104152:	89 04 24             	mov    %eax,(%esp)
f0104155:	e8 ad c6 ff ff       	call   f0100807 <monitor>
}
f010415a:	c9                   	leave  
f010415b:	c3                   	ret    

f010415c <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010415c:	55                   	push   %ebp
f010415d:	89 e5                	mov    %esp,%ebp
f010415f:	83 ec 18             	sub    $0x18,%esp
f0104162:	8b 45 08             	mov    0x8(%ebp),%eax
f0104165:	0f 20 d2             	mov    %cr2,%edx
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();
	if((tf->tf_cs & 3)==0)
f0104168:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f010416c:	75 1c                	jne    f010418a <page_fault_handler+0x2e>
	{
		panic("kernel mode page faults!!");
f010416e:	c7 44 24 08 3f 69 10 	movl   $0xf010693f,0x8(%esp)
f0104175:	f0 
f0104176:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
f010417d:	00 
f010417e:	c7 04 24 59 69 10 f0 	movl   $0xf0106959,(%esp)
f0104185:	e8 57 bf ff ff       	call   f01000e1 <_panic>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010418a:	8b 40 30             	mov    0x30(%eax),%eax
f010418d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104191:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104195:	a1 c8 e1 17 f0       	mov    0xf017e1c8,%eax
f010419a:	8b 40 48             	mov    0x48(%eax),%eax
f010419d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01041a1:	c7 04 24 fc 6a 10 f0 	movl   $0xf0106afc,(%esp)
f01041a8:	e8 e4 f9 ff ff       	call   f0103b91 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	//print_trapframe(tf);
	env_destroy(curenv);
f01041ad:	a1 c8 e1 17 f0       	mov    0xf017e1c8,%eax
f01041b2:	89 04 24             	mov    %eax,(%esp)
f01041b5:	e8 99 f8 ff ff       	call   f0103a53 <env_destroy>
}
f01041ba:	c9                   	leave  
f01041bb:	c3                   	ret    

f01041bc <trap>:



void
trap(struct Trapframe *tf)
{
f01041bc:	55                   	push   %ebp
f01041bd:	89 e5                	mov    %esp,%ebp
f01041bf:	57                   	push   %edi
f01041c0:	56                   	push   %esi
f01041c1:	83 ec 20             	sub    $0x20,%esp
f01041c4:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01041c7:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01041c8:	9c                   	pushf  
f01041c9:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01041ca:	f6 c4 02             	test   $0x2,%ah
f01041cd:	74 24                	je     f01041f3 <trap+0x37>
f01041cf:	c7 44 24 0c 65 69 10 	movl   $0xf0106965,0xc(%esp)
f01041d6:	f0 
f01041d7:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f01041de:	f0 
f01041df:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
f01041e6:	00 
f01041e7:	c7 04 24 59 69 10 f0 	movl   $0xf0106959,(%esp)
f01041ee:	e8 ee be ff ff       	call   f01000e1 <_panic>
   // panic("trap called!");
	cprintf("Incoming TRAP frame at %p\n", tf);
f01041f3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01041f7:	c7 04 24 7e 69 10 f0 	movl   $0xf010697e,(%esp)
f01041fe:	e8 8e f9 ff ff       	call   f0103b91 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0104203:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104207:	83 e0 03             	and    $0x3,%eax
f010420a:	66 83 f8 03          	cmp    $0x3,%ax
f010420e:	75 3c                	jne    f010424c <trap+0x90>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f0104210:	a1 c8 e1 17 f0       	mov    0xf017e1c8,%eax
f0104215:	85 c0                	test   %eax,%eax
f0104217:	75 24                	jne    f010423d <trap+0x81>
f0104219:	c7 44 24 0c 99 69 10 	movl   $0xf0106999,0xc(%esp)
f0104220:	f0 
f0104221:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0104228:	f0 
f0104229:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
f0104230:	00 
f0104231:	c7 04 24 59 69 10 f0 	movl   $0xf0106959,(%esp)
f0104238:	e8 a4 be ff ff       	call   f01000e1 <_panic>
		curenv->env_tf = *tf;
f010423d:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104242:	89 c7                	mov    %eax,%edi
f0104244:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104246:	8b 35 c8 e1 17 f0    	mov    0xf017e1c8,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010424c:	89 35 e0 e9 17 f0    	mov    %esi,0xf017e9e0
}
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	print_trapframe(tf);
f0104252:	89 34 24             	mov    %esi,(%esp)
f0104255:	e8 6a fd ff ff       	call   f0103fc4 <print_trapframe>
	// LAB 3: Your code here.
	if(tf->tf_trapno==T_PGFLT)
f010425a:	8b 46 28             	mov    0x28(%esi),%eax
f010425d:	83 f8 0e             	cmp    $0xe,%eax
f0104260:	75 0a                	jne    f010426c <trap+0xb0>
	{
		page_fault_handler(tf);
f0104262:	89 34 24             	mov    %esi,(%esp)
f0104265:	e8 f2 fe ff ff       	call   f010415c <page_fault_handler>
f010426a:	eb 78                	jmp    f01042e4 <trap+0x128>
		return;
	}
	if(tf->tf_trapno==T_BRKPT)
f010426c:	83 f8 03             	cmp    $0x3,%eax
f010426f:	90                   	nop
f0104270:	75 0a                	jne    f010427c <trap+0xc0>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
}
void
break_point_handler(struct Trapframe *tf)
{
	monitor(tf);
f0104272:	89 34 24             	mov    %esi,(%esp)
f0104275:	e8 8d c5 ff ff       	call   f0100807 <monitor>
f010427a:	eb 68                	jmp    f01042e4 <trap+0x128>
	if(tf->tf_trapno==T_BRKPT)
	{
		break_point_handler(tf);
		return;
	}
	if(tf->tf_trapno==T_SYSCALL)
f010427c:	83 f8 30             	cmp    $0x30,%eax
f010427f:	90                   	nop
f0104280:	75 32                	jne    f01042b4 <trap+0xf8>
	{
		tf->tf_regs.reg_eax=syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx,tf->tf_regs.reg_ecx,tf->tf_regs.reg_ebx,tf->tf_regs.reg_edi,tf->tf_regs.reg_esi);
f0104282:	8b 46 04             	mov    0x4(%esi),%eax
f0104285:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104289:	8b 06                	mov    (%esi),%eax
f010428b:	89 44 24 10          	mov    %eax,0x10(%esp)
f010428f:	8b 46 10             	mov    0x10(%esi),%eax
f0104292:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104296:	8b 46 18             	mov    0x18(%esi),%eax
f0104299:	89 44 24 08          	mov    %eax,0x8(%esp)
f010429d:	8b 46 14             	mov    0x14(%esi),%eax
f01042a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042a4:	8b 46 1c             	mov    0x1c(%esi),%eax
f01042a7:	89 04 24             	mov    %eax,(%esp)
f01042aa:	e8 f1 00 00 00       	call   f01043a0 <syscall>
f01042af:	89 46 1c             	mov    %eax,0x1c(%esi)
f01042b2:	eb 30                	jmp    f01042e4 <trap+0x128>
	    return;
	}
	// Unexpected trap: The user process or the kernel has a bug.

	if (tf->tf_cs == GD_KT)
f01042b4:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01042b9:	75 1c                	jne    f01042d7 <trap+0x11b>
		panic("unhandled trap in kernel");
f01042bb:	c7 44 24 08 a0 69 10 	movl   $0xf01069a0,0x8(%esp)
f01042c2:	f0 
f01042c3:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f01042ca:	00 
f01042cb:	c7 04 24 59 69 10 f0 	movl   $0xf0106959,(%esp)
f01042d2:	e8 0a be ff ff       	call   f01000e1 <_panic>
	else {
		env_destroy(curenv);
f01042d7:	a1 c8 e1 17 f0       	mov    0xf017e1c8,%eax
f01042dc:	89 04 24             	mov    %eax,(%esp)
f01042df:	e8 6f f7 ff ff       	call   f0103a53 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f01042e4:	a1 c8 e1 17 f0       	mov    0xf017e1c8,%eax
f01042e9:	85 c0                	test   %eax,%eax
f01042eb:	74 06                	je     f01042f3 <trap+0x137>
f01042ed:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01042f1:	74 24                	je     f0104317 <trap+0x15b>
f01042f3:	c7 44 24 0c 20 6b 10 	movl   $0xf0106b20,0xc(%esp)
f01042fa:	f0 
f01042fb:	c7 44 24 08 ec 5b 10 	movl   $0xf0105bec,0x8(%esp)
f0104302:	f0 
f0104303:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
f010430a:	00 
f010430b:	c7 04 24 59 69 10 f0 	movl   $0xf0106959,(%esp)
f0104312:	e8 ca bd ff ff       	call   f01000e1 <_panic>
	env_run(curenv);
f0104317:	89 04 24             	mov    %eax,(%esp)
f010431a:	e8 8b f7 ff ff       	call   f0103aaa <env_run>
f010431f:	90                   	nop

f0104320 <dividezero_handler>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(dividezero_handler, 0x0)
f0104320:	6a 00                	push   $0x0
f0104322:	6a 00                	push   $0x0
f0104324:	eb 58                	jmp    f010437e <_alltraps>

f0104326 <nmi_handler>:
TRAPHANDLER_NOEC(nmi_handler, 0x2)
f0104326:	6a 00                	push   $0x0
f0104328:	6a 02                	push   $0x2
f010432a:	eb 52                	jmp    f010437e <_alltraps>

f010432c <breakpoint_handler>:
TRAPHANDLER_NOEC(breakpoint_handler, 0x3)
f010432c:	6a 00                	push   $0x0
f010432e:	6a 03                	push   $0x3
f0104330:	eb 4c                	jmp    f010437e <_alltraps>

f0104332 <overflow_handler>:
TRAPHANDLER_NOEC(overflow_handler, 0x4)
f0104332:	6a 00                	push   $0x0
f0104334:	6a 04                	push   $0x4
f0104336:	eb 46                	jmp    f010437e <_alltraps>

f0104338 <bdrgeexceed_handler>:
TRAPHANDLER_NOEC(bdrgeexceed_handler, 0x5)
f0104338:	6a 00                	push   $0x0
f010433a:	6a 05                	push   $0x5
f010433c:	eb 40                	jmp    f010437e <_alltraps>

f010433e <invalidop_handler>:
TRAPHANDLER_NOEC(invalidop_handler, 0x6)
f010433e:	6a 00                	push   $0x0
f0104340:	6a 06                	push   $0x6
f0104342:	eb 3a                	jmp    f010437e <_alltraps>

f0104344 <nomathcopro_handler>:
TRAPHANDLER_NOEC(nomathcopro_handler, 0x7)
f0104344:	6a 00                	push   $0x0
f0104346:	6a 07                	push   $0x7
f0104348:	eb 34                	jmp    f010437e <_alltraps>

f010434a <dbfault_handler>:
TRAPHANDLER(dbfault_handler, 0x8)
f010434a:	6a 08                	push   $0x8
f010434c:	eb 30                	jmp    f010437e <_alltraps>

f010434e <invalidTSS_handler>:
TRAPHANDLER(invalidTSS_handler, 0xA)
f010434e:	6a 0a                	push   $0xa
f0104350:	eb 2c                	jmp    f010437e <_alltraps>

f0104352 <sgmtnotpresent_handler>:
TRAPHANDLER(sgmtnotpresent_handler, 0xB)
f0104352:	6a 0b                	push   $0xb
f0104354:	eb 28                	jmp    f010437e <_alltraps>

f0104356 <stacksgmtfault_handler>:
TRAPHANDLER(stacksgmtfault_handler,0xC)
f0104356:	6a 0c                	push   $0xc
f0104358:	eb 24                	jmp    f010437e <_alltraps>

f010435a <generalprotection_handler>:
TRAPHANDLER(generalprotection_handler, 0xD)
f010435a:	6a 0d                	push   $0xd
f010435c:	eb 20                	jmp    f010437e <_alltraps>

f010435e <pagefault_handler>:
TRAPHANDLER(pagefault_handler, 0xE)
f010435e:	6a 0e                	push   $0xe
f0104360:	eb 1c                	jmp    f010437e <_alltraps>

f0104362 <FPUerror_handler>:
TRAPHANDLER_NOEC(FPUerror_handler, 0x10)
f0104362:	6a 00                	push   $0x0
f0104364:	6a 10                	push   $0x10
f0104366:	eb 16                	jmp    f010437e <_alltraps>

f0104368 <alignmentcheck_handler>:
TRAPHANDLER(alignmentcheck_handler, 0x11)
f0104368:	6a 11                	push   $0x11
f010436a:	eb 12                	jmp    f010437e <_alltraps>

f010436c <machinecheck_handler>:
TRAPHANDLER_NOEC(machinecheck_handler, 0x12)
f010436c:	6a 00                	push   $0x0
f010436e:	6a 12                	push   $0x12
f0104370:	eb 0c                	jmp    f010437e <_alltraps>

f0104372 <SIMDFPexception_handler>:
TRAPHANDLER_NOEC(SIMDFPexception_handler, 0x13)
f0104372:	6a 00                	push   $0x0
f0104374:	6a 13                	push   $0x13
f0104376:	eb 06                	jmp    f010437e <_alltraps>

f0104378 <systemcall_handler>:
TRAPHANDLER_NOEC(systemcall_handler, 0x30)
f0104378:	6a 00                	push   $0x0
f010437a:	6a 30                	push   $0x30
f010437c:	eb 00                	jmp    f010437e <_alltraps>

f010437e <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
pushw $0
f010437e:	66 6a 00             	pushw  $0x0
pushw %ds
f0104381:	66 1e                	pushw  %ds
pushw $0
f0104383:	66 6a 00             	pushw  $0x0
pushw %es
f0104386:	66 06                	pushw  %es
pushal
f0104388:	60                   	pusha  
pushl %esp
f0104389:	54                   	push   %esp
movw $(GD_KD),%ax
f010438a:	66 b8 10 00          	mov    $0x10,%ax
movw %ax,%ds
f010438e:	8e d8                	mov    %eax,%ds
movw %ax,%es
f0104390:	8e c0                	mov    %eax,%es
call trap
f0104392:	e8 25 fe ff ff       	call   f01041bc <trap>
f0104397:	66 90                	xchg   %ax,%ax
f0104399:	66 90                	xchg   %ax,%ax
f010439b:	66 90                	xchg   %ax,%ax
f010439d:	66 90                	xchg   %ax,%ax
f010439f:	90                   	nop

f01043a0 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01043a0:	55                   	push   %ebp
f01043a1:	89 e5                	mov    %esp,%ebp
f01043a3:	83 ec 28             	sub    $0x28,%esp
f01043a6:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
		
	int32_t r=0;		
	switch(syscallno){
f01043a9:	83 f8 01             	cmp    $0x1,%eax
f01043ac:	74 5e                	je     f010440c <syscall+0x6c>
f01043ae:	83 f8 01             	cmp    $0x1,%eax
f01043b1:	72 12                	jb     f01043c5 <syscall+0x25>
f01043b3:	83 f8 02             	cmp    $0x2,%eax
f01043b6:	74 5b                	je     f0104413 <syscall+0x73>
f01043b8:	83 f8 03             	cmp    $0x3,%eax
f01043bb:	74 60                	je     f010441d <syscall+0x7d>
f01043bd:	8d 76 00             	lea    0x0(%esi),%esi
f01043c0:	e9 c4 00 00 00       	jmp    f0104489 <syscall+0xe9>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);
f01043c5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01043cc:	00 
f01043cd:	8b 45 10             	mov    0x10(%ebp),%eax
f01043d0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01043d4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043db:	a1 c8 e1 17 f0       	mov    0xf017e1c8,%eax
f01043e0:	89 04 24             	mov    %eax,(%esp)
f01043e3:	e8 c3 ee ff ff       	call   f01032ab <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01043e8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043eb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01043ef:	8b 45 10             	mov    0x10(%ebp),%eax
f01043f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043f6:	c7 04 24 b0 6b 10 f0 	movl   $0xf0106bb0,(%esp)
f01043fd:	e8 8f f7 ff ff       	call   f0103b91 <cprintf>
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
		
	int32_t r=0;		
f0104402:	b8 00 00 00 00       	mov    $0x0,%eax
f0104407:	e9 82 00 00 00       	jmp    f010448e <syscall+0xee>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f010440c:	e8 04 c1 ff ff       	call   f0100515 <cons_getc>
	int32_t r=0;		
	switch(syscallno){
	case SYS_cputs:sys_cputs((const char*)a1, (size_t)a2);
			break;
        case SYS_cgetc: r=sys_cgetc();
			break;
f0104411:	eb 7b                	jmp    f010448e <syscall+0xee>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104413:	a1 c8 e1 17 f0       	mov    0xf017e1c8,%eax
f0104418:	8b 40 48             	mov    0x48(%eax),%eax
	case SYS_cputs:sys_cputs((const char*)a1, (size_t)a2);
			break;
        case SYS_cgetc: r=sys_cgetc();
			break;
	case SYS_getenvid: r=sys_getenvid();
			break;
f010441b:	eb 71                	jmp    f010448e <syscall+0xee>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010441d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104424:	00 
f0104425:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104428:	89 44 24 04          	mov    %eax,0x4(%esp)
f010442c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010442f:	89 04 24             	mov    %eax,(%esp)
f0104432:	e8 7c ef ff ff       	call   f01033b3 <envid2env>
f0104437:	85 c0                	test   %eax,%eax
f0104439:	78 53                	js     f010448e <syscall+0xee>
		return r;
	if (e == curenv)
f010443b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010443e:	8b 15 c8 e1 17 f0    	mov    0xf017e1c8,%edx
f0104444:	39 d0                	cmp    %edx,%eax
f0104446:	75 15                	jne    f010445d <syscall+0xbd>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104448:	8b 40 48             	mov    0x48(%eax),%eax
f010444b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010444f:	c7 04 24 b5 6b 10 f0 	movl   $0xf0106bb5,(%esp)
f0104456:	e8 36 f7 ff ff       	call   f0103b91 <cprintf>
f010445b:	eb 1a                	jmp    f0104477 <syscall+0xd7>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010445d:	8b 40 48             	mov    0x48(%eax),%eax
f0104460:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104464:	8b 42 48             	mov    0x48(%edx),%eax
f0104467:	89 44 24 04          	mov    %eax,0x4(%esp)
f010446b:	c7 04 24 d0 6b 10 f0 	movl   $0xf0106bd0,(%esp)
f0104472:	e8 1a f7 ff ff       	call   f0103b91 <cprintf>
	env_destroy(e);
f0104477:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010447a:	89 04 24             	mov    %eax,(%esp)
f010447d:	e8 d1 f5 ff ff       	call   f0103a53 <env_destroy>
	return 0;
f0104482:	b8 00 00 00 00       	mov    $0x0,%eax
        case SYS_cgetc: r=sys_cgetc();
			break;
	case SYS_getenvid: r=sys_getenvid();
			break;
	case SYS_env_destroy: r=sys_env_destroy((envid_t)a1);
			break;
f0104487:	eb 05                	jmp    f010448e <syscall+0xee>
	default:
		r=-E_INVAL;
f0104489:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}

	return r;
	
	panic("syscall not implemented");
}
f010448e:	c9                   	leave  
f010448f:	c3                   	ret    

f0104490 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104490:	55                   	push   %ebp
f0104491:	89 e5                	mov    %esp,%ebp
f0104493:	57                   	push   %edi
f0104494:	56                   	push   %esi
f0104495:	53                   	push   %ebx
f0104496:	83 ec 14             	sub    $0x14,%esp
f0104499:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010449c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010449f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01044a2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01044a5:	8b 1a                	mov    (%edx),%ebx
f01044a7:	8b 01                	mov    (%ecx),%eax
f01044a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	
	while (l <= r) {
f01044ac:	39 c3                	cmp    %eax,%ebx
f01044ae:	0f 8f 9a 00 00 00    	jg     f010454e <stab_binsearch+0xbe>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f01044b4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01044bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01044be:	01 d8                	add    %ebx,%eax
f01044c0:	89 c7                	mov    %eax,%edi
f01044c2:	c1 ef 1f             	shr    $0x1f,%edi
f01044c5:	01 c7                	add    %eax,%edi
f01044c7:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01044c9:	39 df                	cmp    %ebx,%edi
f01044cb:	0f 8c c4 00 00 00    	jl     f0104595 <stab_binsearch+0x105>
f01044d1:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01044d4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01044d7:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01044da:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f01044de:	39 f0                	cmp    %esi,%eax
f01044e0:	0f 84 b4 00 00 00    	je     f010459a <stab_binsearch+0x10a>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01044e6:	89 f8                	mov    %edi,%eax
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01044e8:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01044eb:	39 d8                	cmp    %ebx,%eax
f01044ed:	0f 8c a2 00 00 00    	jl     f0104595 <stab_binsearch+0x105>
f01044f3:	0f b6 4a f8          	movzbl -0x8(%edx),%ecx
f01044f7:	83 ea 0c             	sub    $0xc,%edx
f01044fa:	39 f1                	cmp    %esi,%ecx
f01044fc:	75 ea                	jne    f01044e8 <stab_binsearch+0x58>
f01044fe:	e9 99 00 00 00       	jmp    f010459c <stab_binsearch+0x10c>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104503:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104506:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104508:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010450b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104512:	eb 2b                	jmp    f010453f <stab_binsearch+0xaf>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104514:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104517:	76 14                	jbe    f010452d <stab_binsearch+0x9d>
			*region_right = m - 1;
f0104519:	83 e8 01             	sub    $0x1,%eax
f010451c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010451f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104522:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104524:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010452b:	eb 12                	jmp    f010453f <stab_binsearch+0xaf>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010452d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104530:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104532:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104536:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104538:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f010453f:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104542:	0f 8e 73 ff ff ff    	jle    f01044bb <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104548:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010454c:	75 0f                	jne    f010455d <stab_binsearch+0xcd>
		*region_right = *region_left - 1;
f010454e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104551:	8b 00                	mov    (%eax),%eax
f0104553:	83 e8 01             	sub    $0x1,%eax
f0104556:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104559:	89 06                	mov    %eax,(%esi)
f010455b:	eb 57                	jmp    f01045b4 <stab_binsearch+0x124>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010455d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104560:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104562:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104565:	8b 0f                	mov    (%edi),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104567:	39 c8                	cmp    %ecx,%eax
f0104569:	7e 23                	jle    f010458e <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f010456b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010456e:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104571:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104574:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104578:	39 f3                	cmp    %esi,%ebx
f010457a:	74 12                	je     f010458e <stab_binsearch+0xfe>
		     l--)
f010457c:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010457f:	39 c8                	cmp    %ecx,%eax
f0104581:	7e 0b                	jle    f010458e <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f0104583:	0f b6 5a f8          	movzbl -0x8(%edx),%ebx
f0104587:	83 ea 0c             	sub    $0xc,%edx
f010458a:	39 f3                	cmp    %esi,%ebx
f010458c:	75 ee                	jne    f010457c <stab_binsearch+0xec>
		     l--)
			/* do nothing */;
		*region_left = l;
f010458e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104591:	89 06                	mov    %eax,(%esi)
f0104593:	eb 1f                	jmp    f01045b4 <stab_binsearch+0x124>
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104595:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104598:	eb a5                	jmp    f010453f <stab_binsearch+0xaf>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f010459a:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010459c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010459f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01045a2:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01045a6:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01045a9:	0f 82 54 ff ff ff    	jb     f0104503 <stab_binsearch+0x73>
f01045af:	e9 60 ff ff ff       	jmp    f0104514 <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01045b4:	83 c4 14             	add    $0x14,%esp
f01045b7:	5b                   	pop    %ebx
f01045b8:	5e                   	pop    %esi
f01045b9:	5f                   	pop    %edi
f01045ba:	5d                   	pop    %ebp
f01045bb:	c3                   	ret    

f01045bc <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01045bc:	55                   	push   %ebp
f01045bd:	89 e5                	mov    %esp,%ebp
f01045bf:	57                   	push   %edi
f01045c0:	56                   	push   %esi
f01045c1:	53                   	push   %ebx
f01045c2:	83 ec 3c             	sub    $0x3c,%esp
f01045c5:	8b 7d 08             	mov    0x8(%ebp),%edi
f01045c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01045cb:	c7 06 e8 6b 10 f0    	movl   $0xf0106be8,(%esi)
	info->eip_line = 0;
f01045d1:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01045d8:	c7 46 08 e8 6b 10 f0 	movl   $0xf0106be8,0x8(%esi)
	info->eip_fn_namelen = 9;
f01045df:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01045e6:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f01045e9:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01045f0:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01045f6:	0f 87 ae 00 00 00    	ja     f01046aa <debuginfo_eip+0xee>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *) USTABDATA, sizeof(struct UserStabData), 0) < 0) 
f01045fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104603:	00 
f0104604:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f010460b:	00 
f010460c:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0104613:	00 
f0104614:	a1 c8 e1 17 f0       	mov    0xf017e1c8,%eax
f0104619:	89 04 24             	mov    %eax,(%esp)
f010461c:	e8 cf eb ff ff       	call   f01031f0 <user_mem_check>
f0104621:	85 c0                	test   %eax,%eax
f0104623:	0f 88 01 02 00 00    	js     f010482a <debuginfo_eip+0x26e>
		{
		    return -1;
		}
		stabs = usd->stabs;
f0104629:	a1 00 00 20 00       	mov    0x200000,%eax
f010462e:	89 c1                	mov    %eax,%ecx
f0104630:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0104633:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f0104639:	a1 08 00 20 00       	mov    0x200008,%eax
f010463e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stabstr_end = usd->stabstr_end;
f0104641:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104647:	89 55 cc             	mov    %edx,-0x34(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *) stabs, stab_end - stabs, 0) < 0 || user_mem_check(curenv, (void *) stabstr, stabstr_end - stabstr, 0) < 0)
f010464a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104651:	00 
f0104652:	89 d8                	mov    %ebx,%eax
f0104654:	29 c8                	sub    %ecx,%eax
f0104656:	c1 f8 02             	sar    $0x2,%eax
f0104659:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010465f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104663:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104667:	a1 c8 e1 17 f0       	mov    0xf017e1c8,%eax
f010466c:	89 04 24             	mov    %eax,(%esp)
f010466f:	e8 7c eb ff ff       	call   f01031f0 <user_mem_check>
f0104674:	85 c0                	test   %eax,%eax
f0104676:	0f 88 b5 01 00 00    	js     f0104831 <debuginfo_eip+0x275>
f010467c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104683:	00 
f0104684:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104687:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010468a:	29 ca                	sub    %ecx,%edx
f010468c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104690:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104694:	a1 c8 e1 17 f0       	mov    0xf017e1c8,%eax
f0104699:	89 04 24             	mov    %eax,(%esp)
f010469c:	e8 4f eb ff ff       	call   f01031f0 <user_mem_check>
f01046a1:	85 c0                	test   %eax,%eax
f01046a3:	79 1f                	jns    f01046c4 <debuginfo_eip+0x108>
f01046a5:	e9 8e 01 00 00       	jmp    f0104838 <debuginfo_eip+0x27c>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01046aa:	c7 45 cc b7 1b 11 f0 	movl   $0xf0111bb7,-0x34(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01046b1:	c7 45 d0 b9 f1 10 f0 	movl   $0xf010f1b9,-0x30(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01046b8:	bb b8 f1 10 f0       	mov    $0xf010f1b8,%ebx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01046bd:	c7 45 d4 00 6e 10 f0 	movl   $0xf0106e00,-0x2c(%ebp)
		    return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01046c4:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01046c7:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01046ca:	0f 83 6f 01 00 00    	jae    f010483f <debuginfo_eip+0x283>
f01046d0:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01046d4:	0f 85 6c 01 00 00    	jne    f0104846 <debuginfo_eip+0x28a>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01046da:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01046e1:	2b 5d d4             	sub    -0x2c(%ebp),%ebx
f01046e4:	c1 fb 02             	sar    $0x2,%ebx
f01046e7:	69 c3 ab aa aa aa    	imul   $0xaaaaaaab,%ebx,%eax
f01046ed:	83 e8 01             	sub    $0x1,%eax
f01046f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01046f3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01046f7:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01046fe:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104701:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104704:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104707:	89 d8                	mov    %ebx,%eax
f0104709:	e8 82 fd ff ff       	call   f0104490 <stab_binsearch>
	if (lfile == 0)
f010470e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104711:	85 c0                	test   %eax,%eax
f0104713:	0f 84 34 01 00 00    	je     f010484d <debuginfo_eip+0x291>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104719:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010471c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010471f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104722:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104726:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010472d:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104730:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104733:	89 d8                	mov    %ebx,%eax
f0104735:	e8 56 fd ff ff       	call   f0104490 <stab_binsearch>

	if (lfun <= rfun) {
f010473a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010473d:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0104740:	7f 23                	jg     f0104765 <debuginfo_eip+0x1a9>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104742:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104745:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104748:	8d 04 87             	lea    (%edi,%eax,4),%eax
f010474b:	8b 10                	mov    (%eax),%edx
f010474d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104750:	2b 4d d0             	sub    -0x30(%ebp),%ecx
f0104753:	39 ca                	cmp    %ecx,%edx
f0104755:	73 06                	jae    f010475d <debuginfo_eip+0x1a1>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104757:	03 55 d0             	add    -0x30(%ebp),%edx
f010475a:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f010475d:	8b 40 08             	mov    0x8(%eax),%eax
f0104760:	89 46 10             	mov    %eax,0x10(%esi)
f0104763:	eb 06                	jmp    f010476b <debuginfo_eip+0x1af>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104765:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104768:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010476b:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0104772:	00 
f0104773:	8b 46 08             	mov    0x8(%esi),%eax
f0104776:	89 04 24             	mov    %eax,(%esp)
f0104779:	e8 11 0a 00 00       	call   f010518f <strfind>
f010477e:	2b 46 08             	sub    0x8(%esi),%eax
f0104781:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104784:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104787:	39 fb                	cmp    %edi,%ebx
f0104789:	7c 5f                	jl     f01047ea <debuginfo_eip+0x22e>
	       && stabs[lline].n_type != N_SOL
f010478b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010478e:	c1 e0 02             	shl    $0x2,%eax
f0104791:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104794:	8d 14 01             	lea    (%ecx,%eax,1),%edx
f0104797:	89 55 c8             	mov    %edx,-0x38(%ebp)
f010479a:	0f b6 52 04          	movzbl 0x4(%edx),%edx
f010479e:	80 fa 84             	cmp    $0x84,%dl
f01047a1:	74 2f                	je     f01047d2 <debuginfo_eip+0x216>
f01047a3:	8d 44 01 f4          	lea    -0xc(%ecx,%eax,1),%eax
f01047a7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01047aa:	eb 15                	jmp    f01047c1 <debuginfo_eip+0x205>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01047ac:	83 eb 01             	sub    $0x1,%ebx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01047af:	39 fb                	cmp    %edi,%ebx
f01047b1:	7c 37                	jl     f01047ea <debuginfo_eip+0x22e>
	       && stabs[lline].n_type != N_SOL
f01047b3:	89 c1                	mov    %eax,%ecx
f01047b5:	83 e8 0c             	sub    $0xc,%eax
f01047b8:	0f b6 50 10          	movzbl 0x10(%eax),%edx
f01047bc:	80 fa 84             	cmp    $0x84,%dl
f01047bf:	74 11                	je     f01047d2 <debuginfo_eip+0x216>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01047c1:	80 fa 64             	cmp    $0x64,%dl
f01047c4:	75 e6                	jne    f01047ac <debuginfo_eip+0x1f0>
f01047c6:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f01047ca:	74 e0                	je     f01047ac <debuginfo_eip+0x1f0>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01047cc:	39 df                	cmp    %ebx,%edi
f01047ce:	66 90                	xchg   %ax,%ax
f01047d0:	7f 18                	jg     f01047ea <debuginfo_eip+0x22e>
f01047d2:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01047d5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01047d8:	8b 04 87             	mov    (%edi,%eax,4),%eax
f01047db:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01047de:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01047e1:	39 d0                	cmp    %edx,%eax
f01047e3:	73 05                	jae    f01047ea <debuginfo_eip+0x22e>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01047e5:	03 45 d0             	add    -0x30(%ebp),%eax
f01047e8:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01047ea:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01047ed:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f01047f0:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01047f5:	39 ca                	cmp    %ecx,%edx
f01047f7:	7d 75                	jge    f010486e <debuginfo_eip+0x2b2>
		for (lline = lfun + 1;
f01047f9:	8d 42 01             	lea    0x1(%edx),%eax
f01047fc:	39 c1                	cmp    %eax,%ecx
f01047fe:	7e 54                	jle    f0104854 <debuginfo_eip+0x298>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104800:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104803:	c1 e2 02             	shl    $0x2,%edx
f0104806:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104809:	80 7c 17 04 a0       	cmpb   $0xa0,0x4(%edi,%edx,1)
f010480e:	75 4b                	jne    f010485b <debuginfo_eip+0x29f>
f0104810:	8d 54 17 f4          	lea    -0xc(%edi,%edx,1),%edx
		     lline++)
			info->eip_fn_narg++;
f0104814:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104818:	83 c0 01             	add    $0x1,%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010481b:	39 c1                	cmp    %eax,%ecx
f010481d:	7e 43                	jle    f0104862 <debuginfo_eip+0x2a6>
f010481f:	83 c2 0c             	add    $0xc,%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104822:	80 7a 10 a0          	cmpb   $0xa0,0x10(%edx)
f0104826:	74 ec                	je     f0104814 <debuginfo_eip+0x258>
f0104828:	eb 3f                	jmp    f0104869 <debuginfo_eip+0x2ad>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *) USTABDATA, sizeof(struct UserStabData), 0) < 0) 
		{
		    return -1;
f010482a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010482f:	eb 3d                	jmp    f010486e <debuginfo_eip+0x2b2>

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *) stabs, stab_end - stabs, 0) < 0 || user_mem_check(curenv, (void *) stabstr, stabstr_end - stabstr, 0) < 0)
		 {
		    return -1;
f0104831:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104836:	eb 36                	jmp    f010486e <debuginfo_eip+0x2b2>
f0104838:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010483d:	eb 2f                	jmp    f010486e <debuginfo_eip+0x2b2>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010483f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104844:	eb 28                	jmp    f010486e <debuginfo_eip+0x2b2>
f0104846:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010484b:	eb 21                	jmp    f010486e <debuginfo_eip+0x2b2>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010484d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104852:	eb 1a                	jmp    f010486e <debuginfo_eip+0x2b2>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f0104854:	b8 00 00 00 00       	mov    $0x0,%eax
f0104859:	eb 13                	jmp    f010486e <debuginfo_eip+0x2b2>
f010485b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104860:	eb 0c                	jmp    f010486e <debuginfo_eip+0x2b2>
f0104862:	b8 00 00 00 00       	mov    $0x0,%eax
f0104867:	eb 05                	jmp    f010486e <debuginfo_eip+0x2b2>
f0104869:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010486e:	83 c4 3c             	add    $0x3c,%esp
f0104871:	5b                   	pop    %ebx
f0104872:	5e                   	pop    %esi
f0104873:	5f                   	pop    %edi
f0104874:	5d                   	pop    %ebp
f0104875:	c3                   	ret    
f0104876:	66 90                	xchg   %ax,%ax
f0104878:	66 90                	xchg   %ax,%ax
f010487a:	66 90                	xchg   %ax,%ax
f010487c:	66 90                	xchg   %ax,%ax
f010487e:	66 90                	xchg   %ax,%ax

f0104880 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104880:	55                   	push   %ebp
f0104881:	89 e5                	mov    %esp,%ebp
f0104883:	57                   	push   %edi
f0104884:	56                   	push   %esi
f0104885:	53                   	push   %ebx
f0104886:	83 ec 3c             	sub    $0x3c,%esp
f0104889:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010488c:	89 d7                	mov    %edx,%edi
f010488e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104891:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104894:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104897:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010489a:	8b 45 10             	mov    0x10(%ebp),%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010489d:	b9 00 00 00 00       	mov    $0x0,%ecx
f01048a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01048a5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01048a8:	39 f1                	cmp    %esi,%ecx
f01048aa:	72 14                	jb     f01048c0 <printnum+0x40>
f01048ac:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01048af:	76 0f                	jbe    f01048c0 <printnum+0x40>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01048b1:	8b 45 14             	mov    0x14(%ebp),%eax
f01048b4:	8d 70 ff             	lea    -0x1(%eax),%esi
f01048b7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01048ba:	85 f6                	test   %esi,%esi
f01048bc:	7f 60                	jg     f010491e <printnum+0x9e>
f01048be:	eb 72                	jmp    f0104932 <printnum+0xb2>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01048c0:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01048c3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01048c7:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01048ca:	8d 51 ff             	lea    -0x1(%ecx),%edx
f01048cd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01048d1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01048d5:	8b 44 24 08          	mov    0x8(%esp),%eax
f01048d9:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01048dd:	89 c3                	mov    %eax,%ebx
f01048df:	89 d6                	mov    %edx,%esi
f01048e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01048e4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01048e7:	89 54 24 08          	mov    %edx,0x8(%esp)
f01048eb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01048ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048f2:	89 04 24             	mov    %eax,(%esp)
f01048f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01048f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048fc:	e8 ef 0a 00 00       	call   f01053f0 <__udivdi3>
f0104901:	89 d9                	mov    %ebx,%ecx
f0104903:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104907:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010490b:	89 04 24             	mov    %eax,(%esp)
f010490e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104912:	89 fa                	mov    %edi,%edx
f0104914:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104917:	e8 64 ff ff ff       	call   f0104880 <printnum>
f010491c:	eb 14                	jmp    f0104932 <printnum+0xb2>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010491e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104922:	8b 45 18             	mov    0x18(%ebp),%eax
f0104925:	89 04 24             	mov    %eax,(%esp)
f0104928:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010492a:	83 ee 01             	sub    $0x1,%esi
f010492d:	75 ef                	jne    f010491e <printnum+0x9e>
f010492f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104932:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104936:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010493a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010493d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104940:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104944:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104948:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010494b:	89 04 24             	mov    %eax,(%esp)
f010494e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104951:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104955:	e8 c6 0b 00 00       	call   f0105520 <__umoddi3>
f010495a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010495e:	0f be 80 f2 6b 10 f0 	movsbl -0xfef940e(%eax),%eax
f0104965:	89 04 24             	mov    %eax,(%esp)
f0104968:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010496b:	ff d0                	call   *%eax
}
f010496d:	83 c4 3c             	add    $0x3c,%esp
f0104970:	5b                   	pop    %ebx
f0104971:	5e                   	pop    %esi
f0104972:	5f                   	pop    %edi
f0104973:	5d                   	pop    %ebp
f0104974:	c3                   	ret    

f0104975 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104975:	55                   	push   %ebp
f0104976:	89 e5                	mov    %esp,%ebp
f0104978:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010497b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010497f:	8b 10                	mov    (%eax),%edx
f0104981:	3b 50 04             	cmp    0x4(%eax),%edx
f0104984:	73 0a                	jae    f0104990 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104986:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104989:	89 08                	mov    %ecx,(%eax)
f010498b:	8b 45 08             	mov    0x8(%ebp),%eax
f010498e:	88 02                	mov    %al,(%edx)
}
f0104990:	5d                   	pop    %ebp
f0104991:	c3                   	ret    

f0104992 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104992:	55                   	push   %ebp
f0104993:	89 e5                	mov    %esp,%ebp
f0104995:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0104998:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010499b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010499f:	8b 45 10             	mov    0x10(%ebp),%eax
f01049a2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01049a6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01049a9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01049b0:	89 04 24             	mov    %eax,(%esp)
f01049b3:	e8 02 00 00 00       	call   f01049ba <vprintfmt>
	va_end(ap);
}
f01049b8:	c9                   	leave  
f01049b9:	c3                   	ret    

f01049ba <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01049ba:	55                   	push   %ebp
f01049bb:	89 e5                	mov    %esp,%ebp
f01049bd:	57                   	push   %edi
f01049be:	56                   	push   %esi
f01049bf:	53                   	push   %ebx
f01049c0:	83 ec 3c             	sub    $0x3c,%esp
f01049c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01049c6:	89 df                	mov    %ebx,%edi
f01049c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01049cb:	eb 03                	jmp    f01049d0 <vprintfmt+0x16>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
f01049cd:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01049d0:	8b 45 10             	mov    0x10(%ebp),%eax
f01049d3:	8d 70 01             	lea    0x1(%eax),%esi
f01049d6:	0f b6 00             	movzbl (%eax),%eax
f01049d9:	83 f8 25             	cmp    $0x25,%eax
f01049dc:	74 2d                	je     f0104a0b <vprintfmt+0x51>
			if (ch == '\0')
f01049de:	85 c0                	test   %eax,%eax
f01049e0:	75 14                	jne    f01049f6 <vprintfmt+0x3c>
f01049e2:	e9 6b 04 00 00       	jmp    f0104e52 <vprintfmt+0x498>
f01049e7:	85 c0                	test   %eax,%eax
f01049e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01049f0:	0f 84 5c 04 00 00    	je     f0104e52 <vprintfmt+0x498>
				return;
			putch(ch, putdat);
f01049f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01049fa:	89 04 24             	mov    %eax,(%esp)
f01049fd:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01049ff:	83 c6 01             	add    $0x1,%esi
f0104a02:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f0104a06:	83 f8 25             	cmp    $0x25,%eax
f0104a09:	75 dc                	jne    f01049e7 <vprintfmt+0x2d>
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104a0b:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
f0104a0f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104a16:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0104a1d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0104a24:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104a29:	eb 1f                	jmp    f0104a4a <vprintfmt+0x90>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a2b:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104a2e:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
f0104a32:	eb 16                	jmp    f0104a4a <vprintfmt+0x90>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a34:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104a37:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
f0104a3b:	eb 0d                	jmp    f0104a4a <vprintfmt+0x90>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0104a3d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104a40:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104a43:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a4a:	8d 46 01             	lea    0x1(%esi),%eax
f0104a4d:	89 45 10             	mov    %eax,0x10(%ebp)
f0104a50:	0f b6 06             	movzbl (%esi),%eax
f0104a53:	0f b6 d0             	movzbl %al,%edx
f0104a56:	83 e8 23             	sub    $0x23,%eax
f0104a59:	3c 55                	cmp    $0x55,%al
f0104a5b:	0f 87 c4 03 00 00    	ja     f0104e25 <vprintfmt+0x46b>
f0104a61:	0f b6 c0             	movzbl %al,%eax
f0104a64:	ff 24 85 7c 6c 10 f0 	jmp    *-0xfef9384(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104a6b:	8d 42 d0             	lea    -0x30(%edx),%eax
f0104a6e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				ch = *fmt;
f0104a71:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0104a75:	8d 50 d0             	lea    -0x30(%eax),%edx
f0104a78:	83 fa 09             	cmp    $0x9,%edx
f0104a7b:	77 63                	ja     f0104ae0 <vprintfmt+0x126>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a7d:	8b 75 10             	mov    0x10(%ebp),%esi
f0104a80:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104a83:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104a86:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0104a89:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0104a8c:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0104a90:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0104a93:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0104a96:	83 f9 09             	cmp    $0x9,%ecx
f0104a99:	76 eb                	jbe    f0104a86 <vprintfmt+0xcc>
f0104a9b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104a9e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104aa1:	eb 40                	jmp    f0104ae3 <vprintfmt+0x129>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104aa3:	8b 45 14             	mov    0x14(%ebp),%eax
f0104aa6:	8b 00                	mov    (%eax),%eax
f0104aa8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104aab:	8b 45 14             	mov    0x14(%ebp),%eax
f0104aae:	8d 40 04             	lea    0x4(%eax),%eax
f0104ab1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ab4:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104ab7:	eb 2a                	jmp    f0104ae3 <vprintfmt+0x129>
f0104ab9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104abc:	85 d2                	test   %edx,%edx
f0104abe:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ac3:	0f 49 c2             	cmovns %edx,%eax
f0104ac6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ac9:	8b 75 10             	mov    0x10(%ebp),%esi
f0104acc:	e9 79 ff ff ff       	jmp    f0104a4a <vprintfmt+0x90>
f0104ad1:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104ad4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104adb:	e9 6a ff ff ff       	jmp    f0104a4a <vprintfmt+0x90>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ae0:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0104ae3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104ae7:	0f 89 5d ff ff ff    	jns    f0104a4a <vprintfmt+0x90>
f0104aed:	e9 4b ff ff ff       	jmp    f0104a3d <vprintfmt+0x83>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104af2:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104af5:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104af8:	e9 4d ff ff ff       	jmp    f0104a4a <vprintfmt+0x90>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104afd:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b00:	8d 70 04             	lea    0x4(%eax),%esi
f0104b03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104b07:	8b 00                	mov    (%eax),%eax
f0104b09:	89 04 24             	mov    %eax,(%esp)
f0104b0c:	ff d7                	call   *%edi
f0104b0e:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
f0104b11:	e9 ba fe ff ff       	jmp    f01049d0 <vprintfmt+0x16>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104b16:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b19:	8d 70 04             	lea    0x4(%eax),%esi
f0104b1c:	8b 00                	mov    (%eax),%eax
f0104b1e:	99                   	cltd   
f0104b1f:	31 d0                	xor    %edx,%eax
f0104b21:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104b23:	83 f8 06             	cmp    $0x6,%eax
f0104b26:	7f 0b                	jg     f0104b33 <vprintfmt+0x179>
f0104b28:	8b 14 85 d4 6d 10 f0 	mov    -0xfef922c(,%eax,4),%edx
f0104b2f:	85 d2                	test   %edx,%edx
f0104b31:	75 20                	jne    f0104b53 <vprintfmt+0x199>
				printfmt(putch, putdat, "error %d", err);
f0104b33:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104b37:	c7 44 24 08 0a 6c 10 	movl   $0xf0106c0a,0x8(%esp)
f0104b3e:	f0 
f0104b3f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104b43:	89 3c 24             	mov    %edi,(%esp)
f0104b46:	e8 47 fe ff ff       	call   f0104992 <printfmt>
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104b4b:	89 75 14             	mov    %esi,0x14(%ebp)
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104b4e:	e9 7d fe ff ff       	jmp    f01049d0 <vprintfmt+0x16>
			else
				printfmt(putch, putdat, "%s", p);
f0104b53:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104b57:	c7 44 24 08 fe 5b 10 	movl   $0xf0105bfe,0x8(%esp)
f0104b5e:	f0 
f0104b5f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104b63:	89 3c 24             	mov    %edi,(%esp)
f0104b66:	e8 27 fe ff ff       	call   f0104992 <printfmt>
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104b6b:	89 75 14             	mov    %esi,0x14(%ebp)
f0104b6e:	e9 5d fe ff ff       	jmp    f01049d0 <vprintfmt+0x16>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b73:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b76:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104b79:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104b7c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0104b80:	8b 00                	mov    (%eax),%eax
				p = "(null)";
f0104b82:	85 c0                	test   %eax,%eax
f0104b84:	b9 03 6c 10 f0       	mov    $0xf0106c03,%ecx
f0104b89:	0f 45 c8             	cmovne %eax,%ecx
f0104b8c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
			if (width > 0 && padc != '-')
f0104b8f:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
f0104b93:	74 04                	je     f0104b99 <vprintfmt+0x1df>
f0104b95:	85 f6                	test   %esi,%esi
f0104b97:	7f 19                	jg     f0104bb2 <vprintfmt+0x1f8>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104b99:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104b9c:	8d 70 01             	lea    0x1(%eax),%esi
f0104b9f:	0f b6 10             	movzbl (%eax),%edx
f0104ba2:	0f be c2             	movsbl %dl,%eax
f0104ba5:	85 c0                	test   %eax,%eax
f0104ba7:	0f 85 9a 00 00 00    	jne    f0104c47 <vprintfmt+0x28d>
f0104bad:	e9 87 00 00 00       	jmp    f0104c39 <vprintfmt+0x27f>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104bb2:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104bb6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104bb9:	89 04 24             	mov    %eax,(%esp)
f0104bbc:	e8 11 04 00 00       	call   f0104fd2 <strnlen>
f0104bc1:	29 c6                	sub    %eax,%esi
f0104bc3:	89 f0                	mov    %esi,%eax
f0104bc5:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0104bc8:	85 f6                	test   %esi,%esi
f0104bca:	7e cd                	jle    f0104b99 <vprintfmt+0x1df>
					putch(padc, putdat);
f0104bcc:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f0104bd0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104bd3:	89 c3                	mov    %eax,%ebx
f0104bd5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104bd8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104bdc:	89 34 24             	mov    %esi,(%esp)
f0104bdf:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104be1:	83 eb 01             	sub    $0x1,%ebx
f0104be4:	75 ef                	jne    f0104bd5 <vprintfmt+0x21b>
f0104be6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104be9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104bec:	eb ab                	jmp    f0104b99 <vprintfmt+0x1df>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104bee:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104bf2:	74 1e                	je     f0104c12 <vprintfmt+0x258>
f0104bf4:	0f be d2             	movsbl %dl,%edx
f0104bf7:	83 ea 20             	sub    $0x20,%edx
f0104bfa:	83 fa 5e             	cmp    $0x5e,%edx
f0104bfd:	76 13                	jbe    f0104c12 <vprintfmt+0x258>
					putch('?', putdat);
f0104bff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c02:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c06:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0104c0d:	ff 55 08             	call   *0x8(%ebp)
f0104c10:	eb 0d                	jmp    f0104c1f <vprintfmt+0x265>
				else
					putch(ch, putdat);
f0104c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104c15:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104c19:	89 04 24             	mov    %eax,(%esp)
f0104c1c:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104c1f:	83 eb 01             	sub    $0x1,%ebx
f0104c22:	83 c6 01             	add    $0x1,%esi
f0104c25:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f0104c29:	0f be c2             	movsbl %dl,%eax
f0104c2c:	85 c0                	test   %eax,%eax
f0104c2e:	75 23                	jne    f0104c53 <vprintfmt+0x299>
f0104c30:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104c33:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104c36:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104c39:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104c3c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104c40:	7f 25                	jg     f0104c67 <vprintfmt+0x2ad>
f0104c42:	e9 89 fd ff ff       	jmp    f01049d0 <vprintfmt+0x16>
f0104c47:	89 7d 08             	mov    %edi,0x8(%ebp)
f0104c4a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104c4d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104c50:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104c53:	85 ff                	test   %edi,%edi
f0104c55:	78 97                	js     f0104bee <vprintfmt+0x234>
f0104c57:	83 ef 01             	sub    $0x1,%edi
f0104c5a:	79 92                	jns    f0104bee <vprintfmt+0x234>
f0104c5c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104c5f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104c62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104c65:	eb d2                	jmp    f0104c39 <vprintfmt+0x27f>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104c67:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104c6b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0104c72:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104c74:	83 ee 01             	sub    $0x1,%esi
f0104c77:	75 ee                	jne    f0104c67 <vprintfmt+0x2ad>
f0104c79:	e9 52 fd ff ff       	jmp    f01049d0 <vprintfmt+0x16>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104c7e:	83 f9 01             	cmp    $0x1,%ecx
f0104c81:	7e 19                	jle    f0104c9c <vprintfmt+0x2e2>
		return va_arg(*ap, long long);
f0104c83:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c86:	8b 50 04             	mov    0x4(%eax),%edx
f0104c89:	8b 00                	mov    (%eax),%eax
f0104c8b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104c8e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104c91:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c94:	8d 40 08             	lea    0x8(%eax),%eax
f0104c97:	89 45 14             	mov    %eax,0x14(%ebp)
f0104c9a:	eb 38                	jmp    f0104cd4 <vprintfmt+0x31a>
	else if (lflag)
f0104c9c:	85 c9                	test   %ecx,%ecx
f0104c9e:	74 1b                	je     f0104cbb <vprintfmt+0x301>
		return va_arg(*ap, long);
f0104ca0:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ca3:	8b 30                	mov    (%eax),%esi
f0104ca5:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0104ca8:	89 f0                	mov    %esi,%eax
f0104caa:	c1 f8 1f             	sar    $0x1f,%eax
f0104cad:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0104cb0:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cb3:	8d 40 04             	lea    0x4(%eax),%eax
f0104cb6:	89 45 14             	mov    %eax,0x14(%ebp)
f0104cb9:	eb 19                	jmp    f0104cd4 <vprintfmt+0x31a>
	else
		return va_arg(*ap, int);
f0104cbb:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cbe:	8b 30                	mov    (%eax),%esi
f0104cc0:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0104cc3:	89 f0                	mov    %esi,%eax
f0104cc5:	c1 f8 1f             	sar    $0x1f,%eax
f0104cc8:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0104ccb:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cce:	8d 40 04             	lea    0x4(%eax),%eax
f0104cd1:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104cd4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104cd7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104cda:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104cdf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104ce3:	0f 89 06 01 00 00    	jns    f0104def <vprintfmt+0x435>
				putch('-', putdat);
f0104ce9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104ced:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0104cf4:	ff d7                	call   *%edi
				num = -(long long) num;
f0104cf6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104cf9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104cfc:	f7 da                	neg    %edx
f0104cfe:	83 d1 00             	adc    $0x0,%ecx
f0104d01:	f7 d9                	neg    %ecx
			}
			base = 10;
f0104d03:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104d08:	e9 e2 00 00 00       	jmp    f0104def <vprintfmt+0x435>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104d0d:	83 f9 01             	cmp    $0x1,%ecx
f0104d10:	7e 10                	jle    f0104d22 <vprintfmt+0x368>
		return va_arg(*ap, unsigned long long);
f0104d12:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d15:	8b 10                	mov    (%eax),%edx
f0104d17:	8b 48 04             	mov    0x4(%eax),%ecx
f0104d1a:	8d 40 08             	lea    0x8(%eax),%eax
f0104d1d:	89 45 14             	mov    %eax,0x14(%ebp)
f0104d20:	eb 26                	jmp    f0104d48 <vprintfmt+0x38e>
	else if (lflag)
f0104d22:	85 c9                	test   %ecx,%ecx
f0104d24:	74 12                	je     f0104d38 <vprintfmt+0x37e>
		return va_arg(*ap, unsigned long);
f0104d26:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d29:	8b 10                	mov    (%eax),%edx
f0104d2b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d30:	8d 40 04             	lea    0x4(%eax),%eax
f0104d33:	89 45 14             	mov    %eax,0x14(%ebp)
f0104d36:	eb 10                	jmp    f0104d48 <vprintfmt+0x38e>
	else
		return va_arg(*ap, unsigned int);
f0104d38:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d3b:	8b 10                	mov    (%eax),%edx
f0104d3d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d42:	8d 40 04             	lea    0x4(%eax),%eax
f0104d45:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0104d48:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0104d4d:	e9 9d 00 00 00       	jmp    f0104def <vprintfmt+0x435>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0104d52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104d56:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0104d5d:	ff d7                	call   *%edi
			putch('X', putdat);
f0104d5f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104d63:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0104d6a:	ff d7                	call   *%edi
			putch('X', putdat);
f0104d6c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104d70:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0104d77:	ff d7                	call   *%edi
			break;
f0104d79:	e9 52 fc ff ff       	jmp    f01049d0 <vprintfmt+0x16>

		// pointer
		case 'p':
			putch('0', putdat);
f0104d7e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104d82:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0104d89:	ff d7                	call   *%edi
			putch('x', putdat);
f0104d8b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104d8f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0104d96:	ff d7                	call   *%edi
			num = (unsigned long long)
f0104d98:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d9b:	8b 10                	mov    (%eax),%edx
f0104d9d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f0104da2:	8d 40 04             	lea    0x4(%eax),%eax
f0104da5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104da8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0104dad:	eb 40                	jmp    f0104def <vprintfmt+0x435>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104daf:	83 f9 01             	cmp    $0x1,%ecx
f0104db2:	7e 10                	jle    f0104dc4 <vprintfmt+0x40a>
		return va_arg(*ap, unsigned long long);
f0104db4:	8b 45 14             	mov    0x14(%ebp),%eax
f0104db7:	8b 10                	mov    (%eax),%edx
f0104db9:	8b 48 04             	mov    0x4(%eax),%ecx
f0104dbc:	8d 40 08             	lea    0x8(%eax),%eax
f0104dbf:	89 45 14             	mov    %eax,0x14(%ebp)
f0104dc2:	eb 26                	jmp    f0104dea <vprintfmt+0x430>
	else if (lflag)
f0104dc4:	85 c9                	test   %ecx,%ecx
f0104dc6:	74 12                	je     f0104dda <vprintfmt+0x420>
		return va_arg(*ap, unsigned long);
f0104dc8:	8b 45 14             	mov    0x14(%ebp),%eax
f0104dcb:	8b 10                	mov    (%eax),%edx
f0104dcd:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104dd2:	8d 40 04             	lea    0x4(%eax),%eax
f0104dd5:	89 45 14             	mov    %eax,0x14(%ebp)
f0104dd8:	eb 10                	jmp    f0104dea <vprintfmt+0x430>
	else
		return va_arg(*ap, unsigned int);
f0104dda:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ddd:	8b 10                	mov    (%eax),%edx
f0104ddf:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104de4:	8d 40 04             	lea    0x4(%eax),%eax
f0104de7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0104dea:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104def:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f0104df3:	89 74 24 10          	mov    %esi,0x10(%esp)
f0104df7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104dfa:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104dfe:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104e02:	89 14 24             	mov    %edx,(%esp)
f0104e05:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104e09:	89 da                	mov    %ebx,%edx
f0104e0b:	89 f8                	mov    %edi,%eax
f0104e0d:	e8 6e fa ff ff       	call   f0104880 <printnum>
			break;
f0104e12:	e9 b9 fb ff ff       	jmp    f01049d0 <vprintfmt+0x16>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104e17:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104e1b:	89 14 24             	mov    %edx,(%esp)
f0104e1e:	ff d7                	call   *%edi
			break;
f0104e20:	e9 ab fb ff ff       	jmp    f01049d0 <vprintfmt+0x16>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104e25:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104e29:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0104e30:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104e32:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0104e36:	0f 84 91 fb ff ff    	je     f01049cd <vprintfmt+0x13>
f0104e3c:	89 75 10             	mov    %esi,0x10(%ebp)
f0104e3f:	89 f0                	mov    %esi,%eax
f0104e41:	83 e8 01             	sub    $0x1,%eax
f0104e44:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0104e48:	75 f7                	jne    f0104e41 <vprintfmt+0x487>
f0104e4a:	89 45 10             	mov    %eax,0x10(%ebp)
f0104e4d:	e9 7e fb ff ff       	jmp    f01049d0 <vprintfmt+0x16>
				/* do nothing */;
			break;
		}
	}
}
f0104e52:	83 c4 3c             	add    $0x3c,%esp
f0104e55:	5b                   	pop    %ebx
f0104e56:	5e                   	pop    %esi
f0104e57:	5f                   	pop    %edi
f0104e58:	5d                   	pop    %ebp
f0104e59:	c3                   	ret    

f0104e5a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104e5a:	55                   	push   %ebp
f0104e5b:	89 e5                	mov    %esp,%ebp
f0104e5d:	83 ec 28             	sub    $0x28,%esp
f0104e60:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e63:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104e66:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104e69:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104e6d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104e70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104e77:	85 c0                	test   %eax,%eax
f0104e79:	74 30                	je     f0104eab <vsnprintf+0x51>
f0104e7b:	85 d2                	test   %edx,%edx
f0104e7d:	7e 2c                	jle    f0104eab <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104e7f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e82:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104e86:	8b 45 10             	mov    0x10(%ebp),%eax
f0104e89:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104e8d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104e90:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e94:	c7 04 24 75 49 10 f0 	movl   $0xf0104975,(%esp)
f0104e9b:	e8 1a fb ff ff       	call   f01049ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104ea0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104ea3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ea9:	eb 05                	jmp    f0104eb0 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104eab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104eb0:	c9                   	leave  
f0104eb1:	c3                   	ret    

f0104eb2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104eb2:	55                   	push   %ebp
f0104eb3:	89 e5                	mov    %esp,%ebp
f0104eb5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104eb8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104ebb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104ebf:	8b 45 10             	mov    0x10(%ebp),%eax
f0104ec2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104ec6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ecd:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ed0:	89 04 24             	mov    %eax,(%esp)
f0104ed3:	e8 82 ff ff ff       	call   f0104e5a <vsnprintf>
	va_end(ap);

	return rc;
}
f0104ed8:	c9                   	leave  
f0104ed9:	c3                   	ret    
f0104eda:	66 90                	xchg   %ax,%ax
f0104edc:	66 90                	xchg   %ax,%ax
f0104ede:	66 90                	xchg   %ax,%ax

f0104ee0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104ee0:	55                   	push   %ebp
f0104ee1:	89 e5                	mov    %esp,%ebp
f0104ee3:	57                   	push   %edi
f0104ee4:	56                   	push   %esi
f0104ee5:	53                   	push   %ebx
f0104ee6:	83 ec 1c             	sub    $0x1c,%esp
f0104ee9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104eec:	85 c0                	test   %eax,%eax
f0104eee:	74 10                	je     f0104f00 <readline+0x20>
		cprintf("%s", prompt);
f0104ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ef4:	c7 04 24 fe 5b 10 f0 	movl   $0xf0105bfe,(%esp)
f0104efb:	e8 91 ec ff ff       	call   f0103b91 <cprintf>

	i = 0;
	echoing = iscons(0);
f0104f00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104f07:	e8 69 b7 ff ff       	call   f0100675 <iscons>
f0104f0c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104f0e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104f13:	e8 4c b7 ff ff       	call   f0100664 <getchar>
f0104f18:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104f1a:	85 c0                	test   %eax,%eax
f0104f1c:	79 17                	jns    f0104f35 <readline+0x55>
			cprintf("read error: %e\n", c);
f0104f1e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f22:	c7 04 24 f0 6d 10 f0 	movl   $0xf0106df0,(%esp)
f0104f29:	e8 63 ec ff ff       	call   f0103b91 <cprintf>
			return NULL;
f0104f2e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f33:	eb 6d                	jmp    f0104fa2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104f35:	83 f8 7f             	cmp    $0x7f,%eax
f0104f38:	74 05                	je     f0104f3f <readline+0x5f>
f0104f3a:	83 f8 08             	cmp    $0x8,%eax
f0104f3d:	75 19                	jne    f0104f58 <readline+0x78>
f0104f3f:	85 f6                	test   %esi,%esi
f0104f41:	7e 15                	jle    f0104f58 <readline+0x78>
			if (echoing)
f0104f43:	85 ff                	test   %edi,%edi
f0104f45:	74 0c                	je     f0104f53 <readline+0x73>
				cputchar('\b');
f0104f47:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0104f4e:	e8 01 b7 ff ff       	call   f0100654 <cputchar>
			i--;
f0104f53:	83 ee 01             	sub    $0x1,%esi
f0104f56:	eb bb                	jmp    f0104f13 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104f58:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104f5e:	7f 1c                	jg     f0104f7c <readline+0x9c>
f0104f60:	83 fb 1f             	cmp    $0x1f,%ebx
f0104f63:	7e 17                	jle    f0104f7c <readline+0x9c>
			if (echoing)
f0104f65:	85 ff                	test   %edi,%edi
f0104f67:	74 08                	je     f0104f71 <readline+0x91>
				cputchar(c);
f0104f69:	89 1c 24             	mov    %ebx,(%esp)
f0104f6c:	e8 e3 b6 ff ff       	call   f0100654 <cputchar>
			buf[i++] = c;
f0104f71:	88 9e 80 ea 17 f0    	mov    %bl,-0xfe81580(%esi)
f0104f77:	8d 76 01             	lea    0x1(%esi),%esi
f0104f7a:	eb 97                	jmp    f0104f13 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0104f7c:	83 fb 0d             	cmp    $0xd,%ebx
f0104f7f:	74 05                	je     f0104f86 <readline+0xa6>
f0104f81:	83 fb 0a             	cmp    $0xa,%ebx
f0104f84:	75 8d                	jne    f0104f13 <readline+0x33>
			if (echoing)
f0104f86:	85 ff                	test   %edi,%edi
f0104f88:	74 0c                	je     f0104f96 <readline+0xb6>
				cputchar('\n');
f0104f8a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0104f91:	e8 be b6 ff ff       	call   f0100654 <cputchar>
			buf[i] = 0;
f0104f96:	c6 86 80 ea 17 f0 00 	movb   $0x0,-0xfe81580(%esi)
			return buf;
f0104f9d:	b8 80 ea 17 f0       	mov    $0xf017ea80,%eax
		}
	}
}
f0104fa2:	83 c4 1c             	add    $0x1c,%esp
f0104fa5:	5b                   	pop    %ebx
f0104fa6:	5e                   	pop    %esi
f0104fa7:	5f                   	pop    %edi
f0104fa8:	5d                   	pop    %ebp
f0104fa9:	c3                   	ret    
f0104faa:	66 90                	xchg   %ax,%ax
f0104fac:	66 90                	xchg   %ax,%ax
f0104fae:	66 90                	xchg   %ax,%ax

f0104fb0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104fb0:	55                   	push   %ebp
f0104fb1:	89 e5                	mov    %esp,%ebp
f0104fb3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104fb6:	80 3a 00             	cmpb   $0x0,(%edx)
f0104fb9:	74 10                	je     f0104fcb <strlen+0x1b>
f0104fbb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0104fc0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104fc3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104fc7:	75 f7                	jne    f0104fc0 <strlen+0x10>
f0104fc9:	eb 05                	jmp    f0104fd0 <strlen+0x20>
f0104fcb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0104fd0:	5d                   	pop    %ebp
f0104fd1:	c3                   	ret    

f0104fd2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104fd2:	55                   	push   %ebp
f0104fd3:	89 e5                	mov    %esp,%ebp
f0104fd5:	53                   	push   %ebx
f0104fd6:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104fd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104fdc:	85 c9                	test   %ecx,%ecx
f0104fde:	74 1c                	je     f0104ffc <strnlen+0x2a>
f0104fe0:	80 3b 00             	cmpb   $0x0,(%ebx)
f0104fe3:	74 1e                	je     f0105003 <strnlen+0x31>
f0104fe5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0104fea:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104fec:	39 ca                	cmp    %ecx,%edx
f0104fee:	74 18                	je     f0105008 <strnlen+0x36>
f0104ff0:	83 c2 01             	add    $0x1,%edx
f0104ff3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0104ff8:	75 f0                	jne    f0104fea <strnlen+0x18>
f0104ffa:	eb 0c                	jmp    f0105008 <strnlen+0x36>
f0104ffc:	b8 00 00 00 00       	mov    $0x0,%eax
f0105001:	eb 05                	jmp    f0105008 <strnlen+0x36>
f0105003:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0105008:	5b                   	pop    %ebx
f0105009:	5d                   	pop    %ebp
f010500a:	c3                   	ret    

f010500b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010500b:	55                   	push   %ebp
f010500c:	89 e5                	mov    %esp,%ebp
f010500e:	53                   	push   %ebx
f010500f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105012:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105015:	89 c2                	mov    %eax,%edx
f0105017:	83 c2 01             	add    $0x1,%edx
f010501a:	83 c1 01             	add    $0x1,%ecx
f010501d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105021:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105024:	84 db                	test   %bl,%bl
f0105026:	75 ef                	jne    f0105017 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105028:	5b                   	pop    %ebx
f0105029:	5d                   	pop    %ebp
f010502a:	c3                   	ret    

f010502b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010502b:	55                   	push   %ebp
f010502c:	89 e5                	mov    %esp,%ebp
f010502e:	53                   	push   %ebx
f010502f:	83 ec 08             	sub    $0x8,%esp
f0105032:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105035:	89 1c 24             	mov    %ebx,(%esp)
f0105038:	e8 73 ff ff ff       	call   f0104fb0 <strlen>
	strcpy(dst + len, src);
f010503d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105040:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105044:	01 d8                	add    %ebx,%eax
f0105046:	89 04 24             	mov    %eax,(%esp)
f0105049:	e8 bd ff ff ff       	call   f010500b <strcpy>
	return dst;
}
f010504e:	89 d8                	mov    %ebx,%eax
f0105050:	83 c4 08             	add    $0x8,%esp
f0105053:	5b                   	pop    %ebx
f0105054:	5d                   	pop    %ebp
f0105055:	c3                   	ret    

f0105056 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105056:	55                   	push   %ebp
f0105057:	89 e5                	mov    %esp,%ebp
f0105059:	56                   	push   %esi
f010505a:	53                   	push   %ebx
f010505b:	8b 75 08             	mov    0x8(%ebp),%esi
f010505e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105061:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105064:	85 db                	test   %ebx,%ebx
f0105066:	74 17                	je     f010507f <strncpy+0x29>
f0105068:	01 f3                	add    %esi,%ebx
f010506a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
f010506c:	83 c1 01             	add    $0x1,%ecx
f010506f:	0f b6 02             	movzbl (%edx),%eax
f0105072:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105075:	80 3a 01             	cmpb   $0x1,(%edx)
f0105078:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010507b:	39 d9                	cmp    %ebx,%ecx
f010507d:	75 ed                	jne    f010506c <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010507f:	89 f0                	mov    %esi,%eax
f0105081:	5b                   	pop    %ebx
f0105082:	5e                   	pop    %esi
f0105083:	5d                   	pop    %ebp
f0105084:	c3                   	ret    

f0105085 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105085:	55                   	push   %ebp
f0105086:	89 e5                	mov    %esp,%ebp
f0105088:	57                   	push   %edi
f0105089:	56                   	push   %esi
f010508a:	53                   	push   %ebx
f010508b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010508e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105091:	8b 75 10             	mov    0x10(%ebp),%esi
f0105094:	89 f8                	mov    %edi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105096:	85 f6                	test   %esi,%esi
f0105098:	74 34                	je     f01050ce <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
f010509a:	83 fe 01             	cmp    $0x1,%esi
f010509d:	74 26                	je     f01050c5 <strlcpy+0x40>
f010509f:	0f b6 0b             	movzbl (%ebx),%ecx
f01050a2:	84 c9                	test   %cl,%cl
f01050a4:	74 23                	je     f01050c9 <strlcpy+0x44>
f01050a6:	83 ee 02             	sub    $0x2,%esi
f01050a9:	ba 00 00 00 00       	mov    $0x0,%edx
			*dst++ = *src++;
f01050ae:	83 c0 01             	add    $0x1,%eax
f01050b1:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01050b4:	39 f2                	cmp    %esi,%edx
f01050b6:	74 13                	je     f01050cb <strlcpy+0x46>
f01050b8:	83 c2 01             	add    $0x1,%edx
f01050bb:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01050bf:	84 c9                	test   %cl,%cl
f01050c1:	75 eb                	jne    f01050ae <strlcpy+0x29>
f01050c3:	eb 06                	jmp    f01050cb <strlcpy+0x46>
f01050c5:	89 f8                	mov    %edi,%eax
f01050c7:	eb 02                	jmp    f01050cb <strlcpy+0x46>
f01050c9:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01050cb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01050ce:	29 f8                	sub    %edi,%eax
}
f01050d0:	5b                   	pop    %ebx
f01050d1:	5e                   	pop    %esi
f01050d2:	5f                   	pop    %edi
f01050d3:	5d                   	pop    %ebp
f01050d4:	c3                   	ret    

f01050d5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01050d5:	55                   	push   %ebp
f01050d6:	89 e5                	mov    %esp,%ebp
f01050d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01050db:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01050de:	0f b6 01             	movzbl (%ecx),%eax
f01050e1:	84 c0                	test   %al,%al
f01050e3:	74 15                	je     f01050fa <strcmp+0x25>
f01050e5:	3a 02                	cmp    (%edx),%al
f01050e7:	75 11                	jne    f01050fa <strcmp+0x25>
		p++, q++;
f01050e9:	83 c1 01             	add    $0x1,%ecx
f01050ec:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01050ef:	0f b6 01             	movzbl (%ecx),%eax
f01050f2:	84 c0                	test   %al,%al
f01050f4:	74 04                	je     f01050fa <strcmp+0x25>
f01050f6:	3a 02                	cmp    (%edx),%al
f01050f8:	74 ef                	je     f01050e9 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01050fa:	0f b6 c0             	movzbl %al,%eax
f01050fd:	0f b6 12             	movzbl (%edx),%edx
f0105100:	29 d0                	sub    %edx,%eax
}
f0105102:	5d                   	pop    %ebp
f0105103:	c3                   	ret    

f0105104 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105104:	55                   	push   %ebp
f0105105:	89 e5                	mov    %esp,%ebp
f0105107:	56                   	push   %esi
f0105108:	53                   	push   %ebx
f0105109:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010510c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010510f:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
f0105112:	85 f6                	test   %esi,%esi
f0105114:	74 29                	je     f010513f <strncmp+0x3b>
f0105116:	0f b6 03             	movzbl (%ebx),%eax
f0105119:	84 c0                	test   %al,%al
f010511b:	74 30                	je     f010514d <strncmp+0x49>
f010511d:	3a 02                	cmp    (%edx),%al
f010511f:	75 2c                	jne    f010514d <strncmp+0x49>
f0105121:	8d 43 01             	lea    0x1(%ebx),%eax
f0105124:	01 de                	add    %ebx,%esi
		n--, p++, q++;
f0105126:	89 c3                	mov    %eax,%ebx
f0105128:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010512b:	39 f0                	cmp    %esi,%eax
f010512d:	74 17                	je     f0105146 <strncmp+0x42>
f010512f:	0f b6 08             	movzbl (%eax),%ecx
f0105132:	84 c9                	test   %cl,%cl
f0105134:	74 17                	je     f010514d <strncmp+0x49>
f0105136:	83 c0 01             	add    $0x1,%eax
f0105139:	3a 0a                	cmp    (%edx),%cl
f010513b:	74 e9                	je     f0105126 <strncmp+0x22>
f010513d:	eb 0e                	jmp    f010514d <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
f010513f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105144:	eb 0f                	jmp    f0105155 <strncmp+0x51>
f0105146:	b8 00 00 00 00       	mov    $0x0,%eax
f010514b:	eb 08                	jmp    f0105155 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010514d:	0f b6 03             	movzbl (%ebx),%eax
f0105150:	0f b6 12             	movzbl (%edx),%edx
f0105153:	29 d0                	sub    %edx,%eax
}
f0105155:	5b                   	pop    %ebx
f0105156:	5e                   	pop    %esi
f0105157:	5d                   	pop    %ebp
f0105158:	c3                   	ret    

f0105159 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105159:	55                   	push   %ebp
f010515a:	89 e5                	mov    %esp,%ebp
f010515c:	53                   	push   %ebx
f010515d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105160:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f0105163:	0f b6 18             	movzbl (%eax),%ebx
f0105166:	84 db                	test   %bl,%bl
f0105168:	74 1d                	je     f0105187 <strchr+0x2e>
f010516a:	89 d1                	mov    %edx,%ecx
		if (*s == c)
f010516c:	38 d3                	cmp    %dl,%bl
f010516e:	75 06                	jne    f0105176 <strchr+0x1d>
f0105170:	eb 1a                	jmp    f010518c <strchr+0x33>
f0105172:	38 ca                	cmp    %cl,%dl
f0105174:	74 16                	je     f010518c <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105176:	83 c0 01             	add    $0x1,%eax
f0105179:	0f b6 10             	movzbl (%eax),%edx
f010517c:	84 d2                	test   %dl,%dl
f010517e:	75 f2                	jne    f0105172 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
f0105180:	b8 00 00 00 00       	mov    $0x0,%eax
f0105185:	eb 05                	jmp    f010518c <strchr+0x33>
f0105187:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010518c:	5b                   	pop    %ebx
f010518d:	5d                   	pop    %ebp
f010518e:	c3                   	ret    

f010518f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010518f:	55                   	push   %ebp
f0105190:	89 e5                	mov    %esp,%ebp
f0105192:	53                   	push   %ebx
f0105193:	8b 45 08             	mov    0x8(%ebp),%eax
f0105196:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f0105199:	0f b6 18             	movzbl (%eax),%ebx
f010519c:	84 db                	test   %bl,%bl
f010519e:	74 16                	je     f01051b6 <strfind+0x27>
f01051a0:	89 d1                	mov    %edx,%ecx
		if (*s == c)
f01051a2:	38 d3                	cmp    %dl,%bl
f01051a4:	75 06                	jne    f01051ac <strfind+0x1d>
f01051a6:	eb 0e                	jmp    f01051b6 <strfind+0x27>
f01051a8:	38 ca                	cmp    %cl,%dl
f01051aa:	74 0a                	je     f01051b6 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01051ac:	83 c0 01             	add    $0x1,%eax
f01051af:	0f b6 10             	movzbl (%eax),%edx
f01051b2:	84 d2                	test   %dl,%dl
f01051b4:	75 f2                	jne    f01051a8 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
f01051b6:	5b                   	pop    %ebx
f01051b7:	5d                   	pop    %ebp
f01051b8:	c3                   	ret    

f01051b9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01051b9:	55                   	push   %ebp
f01051ba:	89 e5                	mov    %esp,%ebp
f01051bc:	57                   	push   %edi
f01051bd:	56                   	push   %esi
f01051be:	53                   	push   %ebx
f01051bf:	8b 7d 08             	mov    0x8(%ebp),%edi
f01051c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01051c5:	85 c9                	test   %ecx,%ecx
f01051c7:	74 36                	je     f01051ff <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01051c9:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01051cf:	75 28                	jne    f01051f9 <memset+0x40>
f01051d1:	f6 c1 03             	test   $0x3,%cl
f01051d4:	75 23                	jne    f01051f9 <memset+0x40>
		c &= 0xFF;
f01051d6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01051da:	89 d3                	mov    %edx,%ebx
f01051dc:	c1 e3 08             	shl    $0x8,%ebx
f01051df:	89 d6                	mov    %edx,%esi
f01051e1:	c1 e6 18             	shl    $0x18,%esi
f01051e4:	89 d0                	mov    %edx,%eax
f01051e6:	c1 e0 10             	shl    $0x10,%eax
f01051e9:	09 f0                	or     %esi,%eax
f01051eb:	09 c2                	or     %eax,%edx
f01051ed:	89 d0                	mov    %edx,%eax
f01051ef:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01051f1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01051f4:	fc                   	cld    
f01051f5:	f3 ab                	rep stos %eax,%es:(%edi)
f01051f7:	eb 06                	jmp    f01051ff <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01051f9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01051fc:	fc                   	cld    
f01051fd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01051ff:	89 f8                	mov    %edi,%eax
f0105201:	5b                   	pop    %ebx
f0105202:	5e                   	pop    %esi
f0105203:	5f                   	pop    %edi
f0105204:	5d                   	pop    %ebp
f0105205:	c3                   	ret    

f0105206 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105206:	55                   	push   %ebp
f0105207:	89 e5                	mov    %esp,%ebp
f0105209:	57                   	push   %edi
f010520a:	56                   	push   %esi
f010520b:	8b 45 08             	mov    0x8(%ebp),%eax
f010520e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105211:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105214:	39 c6                	cmp    %eax,%esi
f0105216:	73 35                	jae    f010524d <memmove+0x47>
f0105218:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010521b:	39 d0                	cmp    %edx,%eax
f010521d:	73 2e                	jae    f010524d <memmove+0x47>
		s += n;
		d += n;
f010521f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0105222:	89 d6                	mov    %edx,%esi
f0105224:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105226:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010522c:	75 13                	jne    f0105241 <memmove+0x3b>
f010522e:	f6 c1 03             	test   $0x3,%cl
f0105231:	75 0e                	jne    f0105241 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105233:	83 ef 04             	sub    $0x4,%edi
f0105236:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105239:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010523c:	fd                   	std    
f010523d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010523f:	eb 09                	jmp    f010524a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105241:	83 ef 01             	sub    $0x1,%edi
f0105244:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105247:	fd                   	std    
f0105248:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010524a:	fc                   	cld    
f010524b:	eb 1d                	jmp    f010526a <memmove+0x64>
f010524d:	89 f2                	mov    %esi,%edx
f010524f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105251:	f6 c2 03             	test   $0x3,%dl
f0105254:	75 0f                	jne    f0105265 <memmove+0x5f>
f0105256:	f6 c1 03             	test   $0x3,%cl
f0105259:	75 0a                	jne    f0105265 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010525b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010525e:	89 c7                	mov    %eax,%edi
f0105260:	fc                   	cld    
f0105261:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105263:	eb 05                	jmp    f010526a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105265:	89 c7                	mov    %eax,%edi
f0105267:	fc                   	cld    
f0105268:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010526a:	5e                   	pop    %esi
f010526b:	5f                   	pop    %edi
f010526c:	5d                   	pop    %ebp
f010526d:	c3                   	ret    

f010526e <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f010526e:	55                   	push   %ebp
f010526f:	89 e5                	mov    %esp,%ebp
f0105271:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105274:	8b 45 10             	mov    0x10(%ebp),%eax
f0105277:	89 44 24 08          	mov    %eax,0x8(%esp)
f010527b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010527e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105282:	8b 45 08             	mov    0x8(%ebp),%eax
f0105285:	89 04 24             	mov    %eax,(%esp)
f0105288:	e8 79 ff ff ff       	call   f0105206 <memmove>
}
f010528d:	c9                   	leave  
f010528e:	c3                   	ret    

f010528f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010528f:	55                   	push   %ebp
f0105290:	89 e5                	mov    %esp,%ebp
f0105292:	57                   	push   %edi
f0105293:	56                   	push   %esi
f0105294:	53                   	push   %ebx
f0105295:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105298:	8b 75 0c             	mov    0xc(%ebp),%esi
f010529b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010529e:	8d 78 ff             	lea    -0x1(%eax),%edi
f01052a1:	85 c0                	test   %eax,%eax
f01052a3:	74 36                	je     f01052db <memcmp+0x4c>
		if (*s1 != *s2)
f01052a5:	0f b6 03             	movzbl (%ebx),%eax
f01052a8:	0f b6 0e             	movzbl (%esi),%ecx
f01052ab:	ba 00 00 00 00       	mov    $0x0,%edx
f01052b0:	38 c8                	cmp    %cl,%al
f01052b2:	74 1c                	je     f01052d0 <memcmp+0x41>
f01052b4:	eb 10                	jmp    f01052c6 <memcmp+0x37>
f01052b6:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f01052bb:	83 c2 01             	add    $0x1,%edx
f01052be:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f01052c2:	38 c8                	cmp    %cl,%al
f01052c4:	74 0a                	je     f01052d0 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
f01052c6:	0f b6 c0             	movzbl %al,%eax
f01052c9:	0f b6 c9             	movzbl %cl,%ecx
f01052cc:	29 c8                	sub    %ecx,%eax
f01052ce:	eb 10                	jmp    f01052e0 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01052d0:	39 fa                	cmp    %edi,%edx
f01052d2:	75 e2                	jne    f01052b6 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01052d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01052d9:	eb 05                	jmp    f01052e0 <memcmp+0x51>
f01052db:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01052e0:	5b                   	pop    %ebx
f01052e1:	5e                   	pop    %esi
f01052e2:	5f                   	pop    %edi
f01052e3:	5d                   	pop    %ebp
f01052e4:	c3                   	ret    

f01052e5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01052e5:	55                   	push   %ebp
f01052e6:	89 e5                	mov    %esp,%ebp
f01052e8:	53                   	push   %ebx
f01052e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01052ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
f01052ef:	89 c2                	mov    %eax,%edx
f01052f1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01052f4:	39 d0                	cmp    %edx,%eax
f01052f6:	73 13                	jae    f010530b <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
f01052f8:	89 d9                	mov    %ebx,%ecx
f01052fa:	38 18                	cmp    %bl,(%eax)
f01052fc:	75 06                	jne    f0105304 <memfind+0x1f>
f01052fe:	eb 0b                	jmp    f010530b <memfind+0x26>
f0105300:	38 08                	cmp    %cl,(%eax)
f0105302:	74 07                	je     f010530b <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105304:	83 c0 01             	add    $0x1,%eax
f0105307:	39 d0                	cmp    %edx,%eax
f0105309:	75 f5                	jne    f0105300 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010530b:	5b                   	pop    %ebx
f010530c:	5d                   	pop    %ebp
f010530d:	c3                   	ret    

f010530e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010530e:	55                   	push   %ebp
f010530f:	89 e5                	mov    %esp,%ebp
f0105311:	57                   	push   %edi
f0105312:	56                   	push   %esi
f0105313:	53                   	push   %ebx
f0105314:	8b 55 08             	mov    0x8(%ebp),%edx
f0105317:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010531a:	0f b6 0a             	movzbl (%edx),%ecx
f010531d:	80 f9 09             	cmp    $0x9,%cl
f0105320:	74 05                	je     f0105327 <strtol+0x19>
f0105322:	80 f9 20             	cmp    $0x20,%cl
f0105325:	75 10                	jne    f0105337 <strtol+0x29>
		s++;
f0105327:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010532a:	0f b6 0a             	movzbl (%edx),%ecx
f010532d:	80 f9 09             	cmp    $0x9,%cl
f0105330:	74 f5                	je     f0105327 <strtol+0x19>
f0105332:	80 f9 20             	cmp    $0x20,%cl
f0105335:	74 f0                	je     f0105327 <strtol+0x19>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105337:	80 f9 2b             	cmp    $0x2b,%cl
f010533a:	75 0a                	jne    f0105346 <strtol+0x38>
		s++;
f010533c:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010533f:	bf 00 00 00 00       	mov    $0x0,%edi
f0105344:	eb 11                	jmp    f0105357 <strtol+0x49>
f0105346:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010534b:	80 f9 2d             	cmp    $0x2d,%cl
f010534e:	75 07                	jne    f0105357 <strtol+0x49>
		s++, neg = 1;
f0105350:	83 c2 01             	add    $0x1,%edx
f0105353:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105357:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f010535c:	75 15                	jne    f0105373 <strtol+0x65>
f010535e:	80 3a 30             	cmpb   $0x30,(%edx)
f0105361:	75 10                	jne    f0105373 <strtol+0x65>
f0105363:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105367:	75 0a                	jne    f0105373 <strtol+0x65>
		s += 2, base = 16;
f0105369:	83 c2 02             	add    $0x2,%edx
f010536c:	b8 10 00 00 00       	mov    $0x10,%eax
f0105371:	eb 10                	jmp    f0105383 <strtol+0x75>
	else if (base == 0 && s[0] == '0')
f0105373:	85 c0                	test   %eax,%eax
f0105375:	75 0c                	jne    f0105383 <strtol+0x75>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105377:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105379:	80 3a 30             	cmpb   $0x30,(%edx)
f010537c:	75 05                	jne    f0105383 <strtol+0x75>
		s++, base = 8;
f010537e:	83 c2 01             	add    $0x1,%edx
f0105381:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f0105383:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105388:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010538b:	0f b6 0a             	movzbl (%edx),%ecx
f010538e:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0105391:	89 f0                	mov    %esi,%eax
f0105393:	3c 09                	cmp    $0x9,%al
f0105395:	77 08                	ja     f010539f <strtol+0x91>
			dig = *s - '0';
f0105397:	0f be c9             	movsbl %cl,%ecx
f010539a:	83 e9 30             	sub    $0x30,%ecx
f010539d:	eb 20                	jmp    f01053bf <strtol+0xb1>
		else if (*s >= 'a' && *s <= 'z')
f010539f:	8d 71 9f             	lea    -0x61(%ecx),%esi
f01053a2:	89 f0                	mov    %esi,%eax
f01053a4:	3c 19                	cmp    $0x19,%al
f01053a6:	77 08                	ja     f01053b0 <strtol+0xa2>
			dig = *s - 'a' + 10;
f01053a8:	0f be c9             	movsbl %cl,%ecx
f01053ab:	83 e9 57             	sub    $0x57,%ecx
f01053ae:	eb 0f                	jmp    f01053bf <strtol+0xb1>
		else if (*s >= 'A' && *s <= 'Z')
f01053b0:	8d 71 bf             	lea    -0x41(%ecx),%esi
f01053b3:	89 f0                	mov    %esi,%eax
f01053b5:	3c 19                	cmp    $0x19,%al
f01053b7:	77 16                	ja     f01053cf <strtol+0xc1>
			dig = *s - 'A' + 10;
f01053b9:	0f be c9             	movsbl %cl,%ecx
f01053bc:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01053bf:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f01053c2:	7d 0f                	jge    f01053d3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01053c4:	83 c2 01             	add    $0x1,%edx
f01053c7:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f01053cb:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f01053cd:	eb bc                	jmp    f010538b <strtol+0x7d>
f01053cf:	89 d8                	mov    %ebx,%eax
f01053d1:	eb 02                	jmp    f01053d5 <strtol+0xc7>
f01053d3:	89 d8                	mov    %ebx,%eax

	if (endptr)
f01053d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01053d9:	74 05                	je     f01053e0 <strtol+0xd2>
		*endptr = (char *) s;
f01053db:	8b 75 0c             	mov    0xc(%ebp),%esi
f01053de:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f01053e0:	f7 d8                	neg    %eax
f01053e2:	85 ff                	test   %edi,%edi
f01053e4:	0f 44 c3             	cmove  %ebx,%eax
}
f01053e7:	5b                   	pop    %ebx
f01053e8:	5e                   	pop    %esi
f01053e9:	5f                   	pop    %edi
f01053ea:	5d                   	pop    %ebp
f01053eb:	c3                   	ret    
f01053ec:	66 90                	xchg   %ax,%ax
f01053ee:	66 90                	xchg   %ax,%ax

f01053f0 <__udivdi3>:
f01053f0:	55                   	push   %ebp
f01053f1:	57                   	push   %edi
f01053f2:	56                   	push   %esi
f01053f3:	83 ec 0c             	sub    $0xc,%esp
f01053f6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01053fa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f01053fe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0105402:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0105406:	85 c0                	test   %eax,%eax
f0105408:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010540c:	89 ea                	mov    %ebp,%edx
f010540e:	89 0c 24             	mov    %ecx,(%esp)
f0105411:	75 2d                	jne    f0105440 <__udivdi3+0x50>
f0105413:	39 e9                	cmp    %ebp,%ecx
f0105415:	77 61                	ja     f0105478 <__udivdi3+0x88>
f0105417:	85 c9                	test   %ecx,%ecx
f0105419:	89 ce                	mov    %ecx,%esi
f010541b:	75 0b                	jne    f0105428 <__udivdi3+0x38>
f010541d:	b8 01 00 00 00       	mov    $0x1,%eax
f0105422:	31 d2                	xor    %edx,%edx
f0105424:	f7 f1                	div    %ecx
f0105426:	89 c6                	mov    %eax,%esi
f0105428:	31 d2                	xor    %edx,%edx
f010542a:	89 e8                	mov    %ebp,%eax
f010542c:	f7 f6                	div    %esi
f010542e:	89 c5                	mov    %eax,%ebp
f0105430:	89 f8                	mov    %edi,%eax
f0105432:	f7 f6                	div    %esi
f0105434:	89 ea                	mov    %ebp,%edx
f0105436:	83 c4 0c             	add    $0xc,%esp
f0105439:	5e                   	pop    %esi
f010543a:	5f                   	pop    %edi
f010543b:	5d                   	pop    %ebp
f010543c:	c3                   	ret    
f010543d:	8d 76 00             	lea    0x0(%esi),%esi
f0105440:	39 e8                	cmp    %ebp,%eax
f0105442:	77 24                	ja     f0105468 <__udivdi3+0x78>
f0105444:	0f bd e8             	bsr    %eax,%ebp
f0105447:	83 f5 1f             	xor    $0x1f,%ebp
f010544a:	75 3c                	jne    f0105488 <__udivdi3+0x98>
f010544c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0105450:	39 34 24             	cmp    %esi,(%esp)
f0105453:	0f 86 9f 00 00 00    	jbe    f01054f8 <__udivdi3+0x108>
f0105459:	39 d0                	cmp    %edx,%eax
f010545b:	0f 82 97 00 00 00    	jb     f01054f8 <__udivdi3+0x108>
f0105461:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105468:	31 d2                	xor    %edx,%edx
f010546a:	31 c0                	xor    %eax,%eax
f010546c:	83 c4 0c             	add    $0xc,%esp
f010546f:	5e                   	pop    %esi
f0105470:	5f                   	pop    %edi
f0105471:	5d                   	pop    %ebp
f0105472:	c3                   	ret    
f0105473:	90                   	nop
f0105474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105478:	89 f8                	mov    %edi,%eax
f010547a:	f7 f1                	div    %ecx
f010547c:	31 d2                	xor    %edx,%edx
f010547e:	83 c4 0c             	add    $0xc,%esp
f0105481:	5e                   	pop    %esi
f0105482:	5f                   	pop    %edi
f0105483:	5d                   	pop    %ebp
f0105484:	c3                   	ret    
f0105485:	8d 76 00             	lea    0x0(%esi),%esi
f0105488:	89 e9                	mov    %ebp,%ecx
f010548a:	8b 3c 24             	mov    (%esp),%edi
f010548d:	d3 e0                	shl    %cl,%eax
f010548f:	89 c6                	mov    %eax,%esi
f0105491:	b8 20 00 00 00       	mov    $0x20,%eax
f0105496:	29 e8                	sub    %ebp,%eax
f0105498:	89 c1                	mov    %eax,%ecx
f010549a:	d3 ef                	shr    %cl,%edi
f010549c:	89 e9                	mov    %ebp,%ecx
f010549e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01054a2:	8b 3c 24             	mov    (%esp),%edi
f01054a5:	09 74 24 08          	or     %esi,0x8(%esp)
f01054a9:	89 d6                	mov    %edx,%esi
f01054ab:	d3 e7                	shl    %cl,%edi
f01054ad:	89 c1                	mov    %eax,%ecx
f01054af:	89 3c 24             	mov    %edi,(%esp)
f01054b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01054b6:	d3 ee                	shr    %cl,%esi
f01054b8:	89 e9                	mov    %ebp,%ecx
f01054ba:	d3 e2                	shl    %cl,%edx
f01054bc:	89 c1                	mov    %eax,%ecx
f01054be:	d3 ef                	shr    %cl,%edi
f01054c0:	09 d7                	or     %edx,%edi
f01054c2:	89 f2                	mov    %esi,%edx
f01054c4:	89 f8                	mov    %edi,%eax
f01054c6:	f7 74 24 08          	divl   0x8(%esp)
f01054ca:	89 d6                	mov    %edx,%esi
f01054cc:	89 c7                	mov    %eax,%edi
f01054ce:	f7 24 24             	mull   (%esp)
f01054d1:	39 d6                	cmp    %edx,%esi
f01054d3:	89 14 24             	mov    %edx,(%esp)
f01054d6:	72 30                	jb     f0105508 <__udivdi3+0x118>
f01054d8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01054dc:	89 e9                	mov    %ebp,%ecx
f01054de:	d3 e2                	shl    %cl,%edx
f01054e0:	39 c2                	cmp    %eax,%edx
f01054e2:	73 05                	jae    f01054e9 <__udivdi3+0xf9>
f01054e4:	3b 34 24             	cmp    (%esp),%esi
f01054e7:	74 1f                	je     f0105508 <__udivdi3+0x118>
f01054e9:	89 f8                	mov    %edi,%eax
f01054eb:	31 d2                	xor    %edx,%edx
f01054ed:	e9 7a ff ff ff       	jmp    f010546c <__udivdi3+0x7c>
f01054f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01054f8:	31 d2                	xor    %edx,%edx
f01054fa:	b8 01 00 00 00       	mov    $0x1,%eax
f01054ff:	e9 68 ff ff ff       	jmp    f010546c <__udivdi3+0x7c>
f0105504:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105508:	8d 47 ff             	lea    -0x1(%edi),%eax
f010550b:	31 d2                	xor    %edx,%edx
f010550d:	83 c4 0c             	add    $0xc,%esp
f0105510:	5e                   	pop    %esi
f0105511:	5f                   	pop    %edi
f0105512:	5d                   	pop    %ebp
f0105513:	c3                   	ret    
f0105514:	66 90                	xchg   %ax,%ax
f0105516:	66 90                	xchg   %ax,%ax
f0105518:	66 90                	xchg   %ax,%ax
f010551a:	66 90                	xchg   %ax,%ax
f010551c:	66 90                	xchg   %ax,%ax
f010551e:	66 90                	xchg   %ax,%ax

f0105520 <__umoddi3>:
f0105520:	55                   	push   %ebp
f0105521:	57                   	push   %edi
f0105522:	56                   	push   %esi
f0105523:	83 ec 14             	sub    $0x14,%esp
f0105526:	8b 44 24 28          	mov    0x28(%esp),%eax
f010552a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010552e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0105532:	89 c7                	mov    %eax,%edi
f0105534:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105538:	8b 44 24 30          	mov    0x30(%esp),%eax
f010553c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0105540:	89 34 24             	mov    %esi,(%esp)
f0105543:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105547:	85 c0                	test   %eax,%eax
f0105549:	89 c2                	mov    %eax,%edx
f010554b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010554f:	75 17                	jne    f0105568 <__umoddi3+0x48>
f0105551:	39 fe                	cmp    %edi,%esi
f0105553:	76 4b                	jbe    f01055a0 <__umoddi3+0x80>
f0105555:	89 c8                	mov    %ecx,%eax
f0105557:	89 fa                	mov    %edi,%edx
f0105559:	f7 f6                	div    %esi
f010555b:	89 d0                	mov    %edx,%eax
f010555d:	31 d2                	xor    %edx,%edx
f010555f:	83 c4 14             	add    $0x14,%esp
f0105562:	5e                   	pop    %esi
f0105563:	5f                   	pop    %edi
f0105564:	5d                   	pop    %ebp
f0105565:	c3                   	ret    
f0105566:	66 90                	xchg   %ax,%ax
f0105568:	39 f8                	cmp    %edi,%eax
f010556a:	77 54                	ja     f01055c0 <__umoddi3+0xa0>
f010556c:	0f bd e8             	bsr    %eax,%ebp
f010556f:	83 f5 1f             	xor    $0x1f,%ebp
f0105572:	75 5c                	jne    f01055d0 <__umoddi3+0xb0>
f0105574:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0105578:	39 3c 24             	cmp    %edi,(%esp)
f010557b:	0f 87 e7 00 00 00    	ja     f0105668 <__umoddi3+0x148>
f0105581:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105585:	29 f1                	sub    %esi,%ecx
f0105587:	19 c7                	sbb    %eax,%edi
f0105589:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010558d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105591:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105595:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105599:	83 c4 14             	add    $0x14,%esp
f010559c:	5e                   	pop    %esi
f010559d:	5f                   	pop    %edi
f010559e:	5d                   	pop    %ebp
f010559f:	c3                   	ret    
f01055a0:	85 f6                	test   %esi,%esi
f01055a2:	89 f5                	mov    %esi,%ebp
f01055a4:	75 0b                	jne    f01055b1 <__umoddi3+0x91>
f01055a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01055ab:	31 d2                	xor    %edx,%edx
f01055ad:	f7 f6                	div    %esi
f01055af:	89 c5                	mov    %eax,%ebp
f01055b1:	8b 44 24 04          	mov    0x4(%esp),%eax
f01055b5:	31 d2                	xor    %edx,%edx
f01055b7:	f7 f5                	div    %ebp
f01055b9:	89 c8                	mov    %ecx,%eax
f01055bb:	f7 f5                	div    %ebp
f01055bd:	eb 9c                	jmp    f010555b <__umoddi3+0x3b>
f01055bf:	90                   	nop
f01055c0:	89 c8                	mov    %ecx,%eax
f01055c2:	89 fa                	mov    %edi,%edx
f01055c4:	83 c4 14             	add    $0x14,%esp
f01055c7:	5e                   	pop    %esi
f01055c8:	5f                   	pop    %edi
f01055c9:	5d                   	pop    %ebp
f01055ca:	c3                   	ret    
f01055cb:	90                   	nop
f01055cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01055d0:	8b 04 24             	mov    (%esp),%eax
f01055d3:	be 20 00 00 00       	mov    $0x20,%esi
f01055d8:	89 e9                	mov    %ebp,%ecx
f01055da:	29 ee                	sub    %ebp,%esi
f01055dc:	d3 e2                	shl    %cl,%edx
f01055de:	89 f1                	mov    %esi,%ecx
f01055e0:	d3 e8                	shr    %cl,%eax
f01055e2:	89 e9                	mov    %ebp,%ecx
f01055e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055e8:	8b 04 24             	mov    (%esp),%eax
f01055eb:	09 54 24 04          	or     %edx,0x4(%esp)
f01055ef:	89 fa                	mov    %edi,%edx
f01055f1:	d3 e0                	shl    %cl,%eax
f01055f3:	89 f1                	mov    %esi,%ecx
f01055f5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01055f9:	8b 44 24 10          	mov    0x10(%esp),%eax
f01055fd:	d3 ea                	shr    %cl,%edx
f01055ff:	89 e9                	mov    %ebp,%ecx
f0105601:	d3 e7                	shl    %cl,%edi
f0105603:	89 f1                	mov    %esi,%ecx
f0105605:	d3 e8                	shr    %cl,%eax
f0105607:	89 e9                	mov    %ebp,%ecx
f0105609:	09 f8                	or     %edi,%eax
f010560b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f010560f:	f7 74 24 04          	divl   0x4(%esp)
f0105613:	d3 e7                	shl    %cl,%edi
f0105615:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105619:	89 d7                	mov    %edx,%edi
f010561b:	f7 64 24 08          	mull   0x8(%esp)
f010561f:	39 d7                	cmp    %edx,%edi
f0105621:	89 c1                	mov    %eax,%ecx
f0105623:	89 14 24             	mov    %edx,(%esp)
f0105626:	72 2c                	jb     f0105654 <__umoddi3+0x134>
f0105628:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f010562c:	72 22                	jb     f0105650 <__umoddi3+0x130>
f010562e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0105632:	29 c8                	sub    %ecx,%eax
f0105634:	19 d7                	sbb    %edx,%edi
f0105636:	89 e9                	mov    %ebp,%ecx
f0105638:	89 fa                	mov    %edi,%edx
f010563a:	d3 e8                	shr    %cl,%eax
f010563c:	89 f1                	mov    %esi,%ecx
f010563e:	d3 e2                	shl    %cl,%edx
f0105640:	89 e9                	mov    %ebp,%ecx
f0105642:	d3 ef                	shr    %cl,%edi
f0105644:	09 d0                	or     %edx,%eax
f0105646:	89 fa                	mov    %edi,%edx
f0105648:	83 c4 14             	add    $0x14,%esp
f010564b:	5e                   	pop    %esi
f010564c:	5f                   	pop    %edi
f010564d:	5d                   	pop    %ebp
f010564e:	c3                   	ret    
f010564f:	90                   	nop
f0105650:	39 d7                	cmp    %edx,%edi
f0105652:	75 da                	jne    f010562e <__umoddi3+0x10e>
f0105654:	8b 14 24             	mov    (%esp),%edx
f0105657:	89 c1                	mov    %eax,%ecx
f0105659:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f010565d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0105661:	eb cb                	jmp    f010562e <__umoddi3+0x10e>
f0105663:	90                   	nop
f0105664:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105668:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f010566c:	0f 82 0f ff ff ff    	jb     f0105581 <__umoddi3+0x61>
f0105672:	e9 1a ff ff ff       	jmp    f0105591 <__umoddi3+0x71>
