/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
#define TH(N) TRAPHANDLER(handler_##N,T_##N)

#define THN(N) TRAPHANDLER_NOEC(handler_##N,T_##N)

THN(DIVIDE)
THN(DEBUG)
THN(NMI)
THN(BRKPT)
THN(OFLOW)
THN(BOUND)
THN(ILLOP)
THN(DEVICE)
TH(DBLFLT)
TH(TSS)
TH(SEGNP)
TH(STACK)
TH(GPFLT)
TH(PGFLT)
THN(FPERR)
TH(ALIGN)
THN(MCHK)
THN(SIMDERR)
THN(SYSCALL)
TRAPHANDLER_NOEC(handler_TIMER, IRQ_OFFSET+IRQ_TIMER)
TRAPHANDLER_NOEC(handler_KBD, IRQ_OFFSET+IRQ_KBD)
TRAPHANDLER_NOEC(handler_SERIAL, IRQ_OFFSET+IRQ_SERIAL)
TRAPHANDLER_NOEC(handler_SPURIOUS, IRQ_OFFSET+IRQ_SPURIOUS)
TRAPHANDLER_NOEC(handler_IDE, IRQ_OFFSET+IRQ_IDE)
TRAPHANDLER_NOEC(handler_ERROR,IRQ_OFFSET+IRQ_ERROR)
/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
	#build trap frame
	pushl %ds
	pushl %es
	pushal
	#set up data segments
	movw $GD_KD,%ax
	movw %ax,%ds
	movw %ax,%es
	#Call trap(tf), where tf=%esp
	pushl %esp
	call trap
     
