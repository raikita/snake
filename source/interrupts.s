.section    .init
.globl     _start

startINT:
    b       mainInit
    
.section .text

.globl mainInit
mainInit:
	push 	{r0-r12, lr}

    bl		InstallIntTable			// *** MUST COME FIRST, sets the stack pointer
	bl		Init_GPIO				// initialize the SNES controller

	mov		r1, #1
	bl		Write_Latch				// set the Latch line high, so the B button changes the Data line

	// set the Rising Edge detect bit for GPIO line 10 (on the device)
	ldr		r0, =0x2020004C
	ldr		r1, [r0]
	orr		r1, #0x400				// set bit 10
	str		r1, [r0]

	// enable GPIO IRQ lines on Interrupt Controller
	ldr		r0, =0x2000B214			// Enable IRQs 2
	mov		r1, #0x001E0000			// bits 17 to 20 set (IRQs 49 to 52)
	str		r1, [r0]

	// Enable IRQ
	mrs		r0, cpsr
	bic		r0, #0x80
	msr		cpsr_c, r0
	pop		{r0-r12, lr}

	mov pc, lr

.globl initInterrupt
initInterrupt: 
	push 	{lr}

	//ldr r4, =30000000

	
//cl0 load from, add 30 seconds, str to c1

	ldr r4, =1000000 		// wait for 30 seconds
	ldr	r0, =0x20003004			//address of clock (low 32 bits)
	ldr	r2, [r0]			//read clock
	add	r2, r4				//add microseconds
	ldr r3, =0x20003010
	str r2, [r3]


	MRS r1, cpsr 			// ENABLING IRQ ITSELF
	BIC r1, #0x80
	MSR cpsr_c, r1

	ldr r1, =0x2000B210 	// enabling IRQ 1
	ldr r2, [r1]
	orr r2, #0x2
	str	r2, [r1]

	pop		{lr}
	mov pc, lr

.globl InstallIntTable
InstallIntTable:

	ldr		r0, =IntTable
	mov		r1, #0x00000000

	// load the first 8 words and store at the 0 address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// load the second 8 words and store at the next address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// switch to IRQ mode and set stack pointer
	mov		r0, #0xD2
	msr		cpsr_c, r0
	mov		sp, #0x8000

	// switch back to Supervisor mode, set the stack pointer
	mov		r0, #0xD3
	msr		cpsr_c, r0
	mov		sp, #0x8000000

	bx		lr	

irq:
	push	{r0-r12, lr}

	MRS r1, cpsr 		// disabling 
	ORR r1, #0x80
	MSR cpsr_c, r1

	// test if there is an interrupt pending in IRQ Pending 1
	ldr		r0, =0x2000B204
	ldr		r1, [r0]
	tst		r1, #0x2		// bit 2
	beq		irqEnd

	ldr		r0, =0x2000B204 // if there is, you disable interrupt
	ldr		r1, [r0]
	bic		r1, #0x2		// bit 2
	str 	r1, [r0]

	ldr 	r1, =0 			// x-coor of start  
	ldr 	r2, =0 			// y-coor of start
	ldr 	r0, =pointer 		// green = start
	push 	{lr}
	bl 		drawBrickMM
	pop 	{lr}
	

	ldr 	r0, =0x200300
	ldr 	r1, [r0]
	str 	r1, [r0]

irqEnd:
	pop		{r0-r12, lr}
	subs	pc, lr, #4

	
.section .data

SNESDat:
	.int	1

IntTable:
	// Interrupt Vector Table (16 words)
	ldr		pc, reset_handler
	ldr		pc, undefined_handler
	ldr		pc, swi_handler
	ldr		pc, prefetch_handler
	ldr		pc, data_handler
	ldr		pc, unused_handler
	ldr		pc, irq_handler
	ldr		pc, fiq_handler

reset_handler:		.word InstallIntTable
undefined_handler:	.word hang
swi_handler:		.word hang
prefetch_handler:	.word hang
data_handler:		.word hang
unused_handler:		.word hang
irq_handler:		.word irq
fiq_handler:		.word hang

hang:
	b		hang
