/* --- DRAW WON SCREEN */
.globl winScreen
winScreen:
	push {r0-r10, lr}
	mov	r5, #0
	mov	r6, #0
	//ldr r7, =0xffff
	mov r3, #0
	mov r4, #0
	ldr r7, =winScreen
	ldr r8, =767


drawWinScreen:

	cmp r3, #1024
	beq maxWidthWinScreen
	mov r0, r5
	mov r1, r6
	//mov r2, r7
	ldr r2, [r7], #2
	push {r0-r10}
	bl 	DrawPixel
	pop {r0-r10}
	add r5, #1
	add r3, #1
	b drawWinScreen

maxWidthWinScreen:
	add r6, #1
	add r4, #1
	cmp r4, r8
	beq maxHeightWinScreen
	sub r5, #1024
	mov r3, #0
	b 	drawWinScreen
	
maxHeightWinScreen:
	bl 		Init_GPIO
	ldr 	r8, =100000
	mov 	r1, r8  		//r1 is argument to wait
	bl 		Wait 			//wait

	bl	Read_SNES

	ldr	r1, [r0]
	ldr r10, =0xfffffeff
	cmp	r1, r10
	bleq	StartGame 					//If A was pressed, go to StartGame
	ldr r10, =0xfffffffe
	cmp r1, r10
	bleq drawQuit 					//If B was pressed, quit game

	b	maxHeightWinScreen

	push {r0-r10, lr}
	mov	pc, lr
/* DONE DRAW WIN SCREEN */

.globl checkWon
checkWon:
	push {r0-r10, lr}

	ldr	r3, =snakeLength		//get length
	ldr	r2, [r3]
	ldr	r5, =snakex
	ldr	r6, [r5]
	ldr	r0, [r6, r2, lsl #2]	//get x
	ldr	r6, =snakey
	ldr	r1, [r6, r2, lsl #2]	//get y


	bl 	getColumnAndRow
	bl 	getIndex
	bl 	getIndexContent	
	cmp	r1, #4
	bleq winScreen


	ldr r6, =doorCoord
	ldr	r9, [r6]
	ldr r10, [r6, #4]


	cmp	r0, r9
	bne	noWin
	cmp	r1, r10
	bne	noWin

	bl	winScreen

noWin:
	pop	{r0-r10, lr}
	mov	pc, lr


.section .data

.globl doorCoord
doorCoord:
	.int 0
	.int 0
