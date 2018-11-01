.section .text



/*----------atoi Subroutine----------*/
.globl atoi
atoi:				//(r2 = bytes read, r3 = buffer address)
	mov	r0, #0		//resulting int
	mov	r10, #10	//r10 = 10 for multiplying
	mov	r9, #0		//initiate counter

atoiLoop:
	cmp	r9, r2		//while not at end of amount buffer read
	beq	atoiDone

	mul	r0, r10		//r4 = r4 * 10
	ldrb	r5, [r3, r9]	//get number from buffer
	sub	r5, #48		//convert ascii to int
	add	r0, r5		//add them together
				//return result to r0

	add	r9, #1		//inc r9
	b	atoiLoop
	
atoiDone:
	mov	pc, lr


/*----------iota Subroutine----------*/
.globl	itoa
itoa:				//(r2 = int num, r0 = char array)
	push	{r4-r10, lr}
	mov	r1, #0		//initiate remainder
	mov	r5, #0		//initiate counter
	mov	r8, r0		//save loaded array
	bic	r0, #0xffffffff	//initiate array

itoaLoop:
	//explicitely handle 0
	cmp	r2, #0
	bne	itoaNotZero	//if not zero, continue on

	mov	r10, #48
	strb	r10, [r0, r5]	//array[i++] = '0'
	mov	r10, #0		//make r10 hold null
	add	r5, #1
	strb	r10, [r0, r5]	//array[i] = '\0'
	
	b	itoaDone
	
itoaNotZero:
	cmp	r2, #0		//process individual digits, while num != 0
	beq	itoaReverse

	mov	r4, r0		//save r0 into r4

	mov	r3, #10		//make r3 into denomenator
	push	{lr}
	bl	divide		//divide by 10
	pop	{lr}
				//r1 = remainder, r0 = result
	mov	r2, r0		//move result into r2
	mov	r0, r4		//restore r0

itoaIf:
	cmp	r1, #9		//check if remainder < 9
	ble	itoaElse

	sub	r1, #10		//remainder - 10
	add	r1, #48		//remainder + 48
//	mov	r8, r0
	strb	r1, [r8, r5]	//store r1 into r0 array
	add	r5, #1		//inc r5
	add	r2, #1		//add 1 to r2 to make up for remainder - 10

	b	itoaNotZero

itoaElse:
	add	r1, #48		//remainder + 48
//	mov	r8, r0
	strb	r1, [r8, r5]	//array = remainder + 48
	add	r5, #1		//inc r5

	b	itoaNotZero

itoaReverse:
//	mov	r8, r0		//array = '\0'
	mov	r7, #0		//initiate start
	sub	r5, #1		//initate end

itoaRLoop:
	cmp	r7, r5		//check if start (r7) > length (r5)
	bge	itoaDone

	ldrb	r4, [r8, r7]	//swap
	ldrb	r3, [r8, r5]	
	strb	r4, [r8, r5]
	strb	r3, [r8, r7]	//end swapping
	
	add	r7, #1		//increment
	sub	r5, #1		//decrement

	b	itoaRLoop

itoaDone:	
	mov	r1, r7		//move length of string to r1
	pop	{r4-r10, lr}
	mov	pc, lr


/*----------Divide Subroutine----------*/
.globl	divide
divide:				//(r2 = int numerator, r3 = int denomenator)
	push {lr}
	mov	r9, #0		//initiate counter
	mov	r0, #0		//initiate result
	mov	r1, #0		//initiate remainder
	
divideLoop:
	cmp	r2, r3		//check if numerator > denomenator
	blt	divideDone	

	add	r0, #1		//result + 1
	sub	r2, r3		//numerator -= denomenator
	b	divideLoop

divideDone:
	mov	r1, r2		//move numerator to remainder
	pop {lr}
	mov	pc, lr

.global	randomNumber
randomNumber:
	push {r4-r10, lr}
	x	.req	r8
	y	.req	r4
	z	.req	r5
	w	.req	r6
	t	.req	r7

	// load numbers to be randomised
	ldr	r9, =wM
	ldr	w, [r9]
	ldr	r9, =xM
	ldr	x, [r9]
	ldr	r9, =yM
	ldr	y, [r9]
	ldr	r9, =zM
	ldr	z, [r9]

	//randomise it!
	mov t, x
	lsl t, #11
	eor t, x
	mov x, t
	lsl t, #8
	eor t, x
	mov x, y
	mov y, z
	mov z, w
	lsr w, #19
	eor w, z
	eor w, t

	// store randomised numbers back
	ldr	r9, =wM
	str	w, [r9]
	ldr	r9, =xM
	str	x, [r9]
	ldr	r9, =yM
	str	y, [r9]
	ldr	r9, =zM
	str	z, [r9]

	//r1 max = 20
	mov	r1, w
	and	r1, #0x1f		//and w with 31, for y coordinate
	cmp	r1, #21			//if it's 21 or greater
	subge	r1, #11			//sub by 11
	lsl	r1, #5			//multiply by 32
	cmp	r1, #0			//if it is 0, make it 32
	moveq	r1, #32

	//random again for x coordinate, does not save these values
	mov t, x
	lsl t, #11
	eor t, x
	mov x, t
	lsl t, #8
	eor t, x
	mov x, y
	mov y, z
	mov z, w
	lsr w, #19
	eor w, z
	eor w, t

	//r0 max = 30
	mov	r0, w
	and	r0, #0x1f		//and w with 31, for x coordinate
	cmp	r0, #31			//if it's 31, subtract 1 to make it 30
	subeq	r0, #1
	lsl	r0, #5			//multiply by 32
	cmp	r0, #0			//if it is 0, make it 32
	moveq	r0, #32	

	pop {r4-r10, lr}
	mov	pc, lr

.section .data

wM:
	.int	0x1011
xM:
	.int	0x0101
yM:
	.int	0x1000
zM:
	.int	0x1111

.globl scoreArray
scoreArray:
	.byte	0, 0

.global livesArray
livesArray:
	.byte	0
