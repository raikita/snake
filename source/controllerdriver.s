.section .text


/*	  Init_GPIO Subroutine  	*/
.globl Init_GPIO
Init_GPIO:
	//Initialise clock
	push {r4-r10, lr}
	ldr	r0, =0x20200004			//Address for GPFSEL1
	ldr	r1, [r0]			//copy GPFSEL1 into r1
	mov	r2, #7				//bit 0111
	lsl	r2, #3				//index of first bit for pin 11

	bic	r1, r2				//clear pin11's bits
	mov	r3, #1				//outputl function code
	lsl	r3, #3				//r3 = 0 001 000
	orr	r1, r3				//set pin11 function in r1 to 1
	str	r1, [r0]			//write back to GPFSEL1

	//initialise latch
	ldr	r0, =0x20200000			//Address for GPFSEL0
	ldr	r1, [r0]			//copy GPFSEL0 into r1
	mov	r2, #7				//bit 0111
	lsl	r2, #27				//index of first bit for pin 9

	bic	r1, r2				//clear pin9's bits
	mov	r3, #1				//output function code
	lsl	r3, #27				
	orr	r1, r3				//set pin9 function in r1 to 1
	str	r1, [r0]			//write back to GPFSEL0

	//initialise data
	ldr	r0, =0x20200004			//Address for GPFSEL1
	ldr	r1, [r0]			//copy GPFSEL1 into r1
	mov	r2, #7				//bit 0111

	bic	r1, r2				//clear pin10's bits
	str	r1, [r0]			//write back to GPFSEL1
	pop {r4-r10, lr}
	mov	pc, lr


/*	  Write_Clock Subroutine	*/
Write_Clock:					//r1 = value to write
	push {r4-r10, lr}
	ldr	r0, =0x20200000			//base GPIO register
	mov	r2, #1				//r2 == 1
	lsl	r2, #11				//align pin to 3, the clock line (pin 11)
	teq	r1, #0				//check if it is to write or not
	streq	r2, [r0, #40]			//GPCLR0 --write it as 0
	strne	r2, [r0, #28]			//GPSET0 --write it as 1
	pop {r4-r10, lr}
	mov	pc, lr


/*	  Write_Latch Subroutine	*/
.globl Write_Latch
Write_Latch:					//r1 = value to write
	push {r4-r10, lr}
	ldr	r0, =0x20200000			//base GPIO register
	mov	r2, #1				//r2 == 1
	lsl	r2, #9				//align to pin 9, the latch line
	teq	r1, #0				//check if r1 == 0 or not
	streq	r2, [r0, #40]			//GPCLR0 if so, clear bit
	strne	r2, [r0, #28]			//GPSET0 if not, set bit
	pop {r4-r10, lr}
	mov	pc, lr


/*	  Read_Data Subroutine  	*/
Read_Data:					
	push {r4-r10, lr}
	ldr	r2, =0x20200000			//base GPIO register
	ldr	r1, [r2, #52]			//GPLEV0
	mov	r3, #1
	lsl	r3, r0				//align pin10 bit
	and	r1, r3				//mask everything else
	teq	r1, #0				//check to see if 0 or not
	moveq	r0, #0				//return 0 if r1 is 0
	movne	r0, #1				//return 1 if r1 is not 0
	pop {r4-r10, lr}
	mov	pc, lr


/*	  Read_SNES Subroutine  	*/
.globl Read_SNES
Read_SNES:
	push	{r4-r10, lr}
	bic	r4, #0xffffffff			//clear r4

	mov	r5, #0xff			//set r5 to 0x000000ff
	orr	r5, r5, r5, lsl #8		//set r5 to 0x0000ffff
	orr	r5, r5, r5, lsl #16		//set r5 to 0xffffffff

	str	r5, [r4]			//set r4 to 0xffffffff

	mov	r1, #1				//value = 1
	bl	Write_Clock			//write to clock, 1
	mov	r1, #1				//value = 1
	bl	Write_Latch			//write latch, 1
	mov	r1, #12				//value = 12
	bl	Wait				//wait 12 microseconds
	mov	r1, #0				//value = 0
	bl	Write_Latch			//write to latch, 0

	mov	r5, #1				//i = 1

pulseLoop:
	mov	r1, #6				//value = 6
	bl	Wait				//wait 6 microseconds

	mov	r1, #0				//value = 0
	bl	Write_Clock			//write to clock, 0

	mov	r1, #6				//value = 6
	bl	Wait				//wait 6 microseconds

	mov	r0, #10				//read pin 10
	mov	r1, r5				//move bit i (r5) to r1
	bl	Read_Data			//read bit i

	cmp	r0, #1				//check if pressed or not
	beq	skip				//if not, skip

	mov	r0, #1				//change value to 1
	mov	r3, r5				//since r5 started at 1, subtract 1 to put in
	sub	r3, #1				//proper shifting place
	lsl	r0, r3				//move value to proper place
	ldr	r6, [r4]			//load from r4
	eor	r6, r0				//only change that bit to 0
	str	r6, [r4]			//store result to r4

skip:
	mov	r1, #1				//value = 1
	bl	Write_Clock			//write to clock, 1

	add	r5, #1				//i++
	cmp	r5, #16				//check if r5 < 16
	blt	pulseLoop			//if so, loop

	ldr	r6, [r4]			//check if any buttons are pressed
	
	mov	r0, r4				//return values
	pop	{r4-r10, lr}
	mov	pc, lr				//exit subroutine


/*	  Wait Subroutine  		*/
.globl Wait
Wait:
	push {r4-r10, lr}
	ldr	r0, =0x20003004			//address of clock (low 32 bits)
	ldr	r2, [r0]			//read clock
	add	r2, r1				//add microseconds

WaitLoop:
	ldr	r3, [r0]			//read clock
	cmp	r2, r3				//stop when clock == r3
	bhi	WaitLoop	
	pop {r4- r10, lr}
	mov	pc, lr

.globl CheckPressed
CheckPressed:
	push {r4-r10, lr}
	mov	r5, #0				//initiate i
	mov	r2, r0				//move r0 to r2 to save it

checkLoop:
	ldr	r1, [r0]			//load values from r2
	mov	r4, #1				//initiate bitmask
	lsl	r4, r5				//shift and align by r5
	and	r1, r4				//mask everything else
	lsr	r1, r5				//move it back to see if it is 1 or not
	teq	r1, #1				//check to see if it equals 1 or not
	bne	pressed				//if it does, that button wasn't pressed
	
	add	r5, #1				//inc i
	cmp	r5, #12				//if it is greater than 12, it is done checking
	ble	checkLoop

pressed:
	mov	r1, r5				//return number that equals what was pressed
	pop {r4-r10, lr}
	mov	pc, lr


