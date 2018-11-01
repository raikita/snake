.section .text

.globl DrawPixel
DrawPixel:
	push	{r0-r3, lr}

	offset	.req	r3

	// offset = (y * 1024) + x = x + (y << 10)
	add	offset,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl	offset, #1

	// store the colour (half word) at framebuffer pointer + offset

	ldr	r0, =FrameBufferPointer
	ldr	r0, [r0]
	strh	r2, [r0, offset]

	pop	{r0-r3, lr}
	mov	pc, lr

/*
 * r0 = x
 * r1 = y
 * r2 = colour
 * r3 = length
 */
.globl	DrawBox
DrawBox:
	push {r4-r10, lr}

	px	.req	r0
	py	.req	r1
	mov r10, r2 	//save r2
	mov r9, r1 		//save value of y
	mov	r7, r0		//save value of x
	mov	r5, #1		//pixels drawn x
	mov	r6, #1		//pixals drawn y	
	mov	r8, r2
drawLoopH:
	cmp	r5, #32
	bge	drawLoopW
	ldrh	r2, [r8], #2

	bl	DrawPixel

	add	r5, #1
	add	px, #1
	b	drawLoopH

drawLoopW:
	cmp	r6, #32
	bge	done
	ldrh	r2, [r8], #2
	bl	DrawPixel
	add	r6, #1
	add	py, #1
	mov	r5, #1
	mov	r0, r7		//restart x
	b	drawLoopH 
done:
	//restore values
	mov r0, r7
	mov r1, r9
	mov r2, r10

	pop {r4-r10, lr}
	mov	pc, lr




.section .data

snake:
	.byte	500
