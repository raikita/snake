.global drawContents
drawContents:
	push 	{r0-r10, lr}
	bl 		drawBG
	mov 	r5, #0
	mov 	r6, #0
	mov 	r7, #0

continueDrawContents:
	cmp	 	r6, #21 	// checking width 
	beq  	maxWidthGrid1 	// branch if 20 columns done 
	mov 	r0, r5 		// r0 = row # param 
	mov 	r1, r6  	// r1 = column # param
	bl 		getIndex 	// getting index of [r0][r1], ret r0 = index in array 
	bl 		getIndexContent 
						// r0 = contents 

	cmp 	r0, #0 		// 0 = nothing = white = 0xffff
	beq 	aNothing
	cmp 	r0, #1 		// 1 = wall = blue = 0xff
	beq		aWall 
	cmp 	r0, #2 		// 2 = apple = red = 0xf820
	beq 	anApple
	cmp 	r0, #3 		// 3 = snake = green = 0x37e0
	beq 	aSnake
	
aNothing:
	ldr 	r7, =SnakeGone
	b 		drawIt
aWall:	
	ldr 	r7, =wallTop
	b 		drawIt
anApple:
	ldr 	r7, =apple
	b 		drawIt
aSnake: 
	ldr 	r7, =SnakeHead_U
	b 		drawIt

drawIt: 
	mov 	r0, r5
	mov 	r1, r6 
	bl 		getPixelXandY
	mov 	r2, r1 
	mov 	r1, r0
	mov 	r0, r7
	bl 		drawBrickMM

	add  	r6, #1 		// increment column # = r6++
	b 		continueDrawContents

maxWidthGrid1:
	add 	r5, #1 				// adding 1 to the y-coordinate 
	cmp 	r5, #31				// checking how many columns we've gone through
	beq 	maxHeightGrid1 		// if we have drawn 32 pixels vertically, we branch 
	mov 	r6, #0 				// resetting the x-coordinate for the next line 
	b 		continueDrawContents   		// branch back to draw 

maxHeightGrid1:
	pop 	{r0-r10, lr}
	mov 	pc, lr

.globl initializeGrid
initializeGrid:
/*
	Possible contents of grid:
 		0 = nothing
 		1 = wall
 		2 = apple
 		3 = snake 

*/
	push 	{r4-r10, lr}
	mov 	r5, #0 		// r5 = row #
	mov  	r6, #0 		// r6 = column #	
initializeGridLoop:
	cmp	 	r6, #31 	// checking width 
	beq  	maxWidthGrid 	// branch if 20 columns done 
	mov 	r0, r5 		// r0 = row # param 
	mov 	r1, r6  	// r1 = column # param
	bl 		getIndex 	// getting index of [r0][r1], ret r0 = index in array 
	mov 	r1, #0		// r1 = value to load (1)
	bl 		setIndexContent 		
	add  	r6, #1 		// r6++
	b 		initializeGridLoop

maxWidthGrid:
	add 	r5, #1 				// adding 1 to the y-coordinate 
	cmp 	r5, #21				// checking how many columns we've gone through
	beq 	maxHeightGrid 		// if we have drawn 32 pixels vertically, we branch 
	mov 	r6, #0 				// resetting the x-coordinate for the next line 
	b 		initializeGridLoop   		// branch back to draw 


maxHeightGrid:
	pop 	{r4-r10, lr} 		// pop lr 
	mov 	pc, lr 				// go back to calling code  	


// ---------------------------
.globl getPixelXandY
getPixelXandY: 
/* @param
 		r0 = row # 
		r1 = column #

	@return
		r0 = pixel row #
		r1 = pixel column #
*/
	
	push 	{r4-r10, lr}
	lsl 	r0, #5 			// r0 = r0 * 32
	lsl 	r1, #5 			// r1 = r1 * 32
 	pop 	{r4-r10, lr}
	mov 	pc, lr 

.globl getColumnAndRow
getColumnAndRow:

/* @param
 		r0 = x-coordinate 
		r1 = y-coordinate 

	@return
		r0 = row #
		r1 = column #
*/
	push 	{r4-r10, lr}

	mov 	r4, r0 			// r4 = i = x-coordinate
	mov 	r5, r1 			// r5 = j = y-coordinate
	lsr 	r4, #5 			//divide by 32

	lsr 	r5, #5
	mov 	r0, r4
	mov 	r1, r5

	pop 	{r4-r10, lr}
	mov 	pc, lr  		// return to calling code 

.globl	getIndex
getIndex:
/* 	@param
 		r0 = COLUMN #
 		r1 = ROW #

	@return
		r0 = index
*/
	push 	{r4-r10, lr}
	mov 	r6, #30 		// r6 = m = number of rows
	mov 	r7, #4 			// r7 = element size

	mul 	r8, r6, r0 		// r8 = m * i
	add 	r8, r1 			// r8 = (m * i) + j 
	mul 	r8, r8, r7 		// r8 = ((m * i) + j) * 4

	mov 	r0, r8 			// passes index in grid 
	pop 	{r4-r10, lr}
	mov 	pc, lr 			// return to calling code
	
.globl getIndexContent
getIndexContent:

/* @param
 		r0 = index in grid array

	@return
		r0 = content in grid array
*/
	ldr 	r1, =grid 		// r1 = grid array 
	ldr 	r2, [r1, r0]	// r2 = r1[r0]

	mov 	r0, r2 			// passes index in grid 
	mov 	pc, lr 			// return to calling code 

.globl setIndexContent
setIndexContent:
/*
Possible contents of grid:
 		0 = nothing
 		1 = wall
 		2 = apple
 		3 = snake 
 		4 = door
	 @param
 		r0 = index in grid array
 		r1 = value to store

	@return
		nothing
*/

	ldr 	r2, =grid 		// r1 = grid array
	str 	r1, [r2, r0]  		// r2[r0] = r1 
	mov 	pc, lr 


.globl Pause
Pause:

	push {r0-r10, lr}
	
	ldr 	r5, =480			// x-coor of start
	ldr 	r6, =320 			// y-coor of start
	//ldr r7, =0x0
	ldr  r7, =pauseResume
	mov  r3, #0
	mov  r4, #0
	ldr  r8, =64

drawPauseMenu:
	cmp r3, #96
	beq maxWidthPauseMenu
	mov r0, r5
	mov r1, r6
	//mov r2, r7
	ldr r2, [r7], #2
	push {r0-r10}
	bl 	DrawPixel
	pop {r0-r10}
	add r5, #1
	add r3, #1
	b drawPauseMenu

maxWidthPauseMenu:
	add r6, #1
	add r4, #1
	cmp r4, r8
	beq maxHeightPauseMenu
	sub r5, #96
	mov r3, #0
	b 	drawPauseMenu
	
maxHeightPauseMenu:
/*

goBackToReadPauseMenu:
	mov 	r5, #5 				// 5 = flag equals start
	ldr 	r1, =330 			// x-coor of start  
	ldr 	r2, =450			// x-coor of start  
	ldr 	r0, =pointer  		// green
	bl 		drawBrickMM
*/

beforeReadPauseMenu:

	mov 	r9, #5
ReadPauseMenu:
	
	push 	{r4-r10}

	//waiting for user input for 200000 micro seconds
	ldr r8, =10
	mov r1, r8  		//r1 is argument to wait
	bl Wait 			//wait

	bl		Read_SNES
	pop 	{r4-r10}
	ldr		r1, [r0]
	
	ldr 	r10, =0xffffffef 		// check if UP was pressed
	cmp		r1, r10			  		
	beq		pressedUPP 
	ldr 	r10, =0xffffffdf 
	cmp	 	r1, r10					// check if DOWN was pressed
	beq 	pressedDownPM

	ldr 	r10, =0xfffffeff 		// check if A was pressed
	cmp 	r1, r10
	beq 	pressedAP

	b 		ReadPauseMenu

pressedUPP:
	mov		r9, #5
	ldr 	r5, =480			// x-coor of start
	ldr 	r6, =320 			// y-coor of start
	//ldr r7, =0x0
	ldr  r7, =pauseResume
	mov  r3, #0
	mov  r4, #0
	ldr  r8, =64

drawPauseMenu2:
	cmp r3, #96
	beq maxWidthPauseMenu2
	mov r0, r5
	mov r1, r6
	//mov r2, r7
	ldr r2, [r7], #2
	push {r0-r10}
	bl 	DrawPixel
	pop {r0-r10}
	add r5, #1
	add r3, #1
	b drawPauseMenu2

maxWidthPauseMenu2:
	add r6, #1
	add r4, #1
	cmp r4, r8
	beq maxHeightPauseMenu2
	sub r5, #96
	mov r3, #0
	b 	drawPauseMenu2

maxHeightPauseMenu2:
	b 		ReadPauseMenu

pressedDownPM:
/* when you press down,  the pointer to start 
	screen is replaced by BG colour
*/
	
// pointer in 'Start Game' replaced by BG

//	push {r0-r10, lr}
	mov 	r9, #10
	ldr 	r5, =480			// x-coor of start
	ldr 	r6, =320 			// y-coor of start
	//ldr r7, =0x0
	ldr  r7, =pauseQuit
	mov  r3, #0
	mov  r4, #0
	ldr  r8, =64

drawPauseMenu1:
	cmp r3, #96
	beq maxWidthPauseMenu1
	mov r0, r5
	mov r1, r6
	//mov r2, r7
	ldr r2, [r7], #2
	push {r0-r10}
	bl 	DrawPixel
	pop {r0-r10}
	add r5, #1
	add r3, #1
	b drawPauseMenu1

maxWidthPauseMenu1:
	add r6, #1
	add r4, #1
	cmp r4, r8
	beq maxHeightPauseMenu1
	sub r5, #96
	mov r3, #0
	b 	drawPauseMenu1

maxHeightPauseMenu1:
	b 		ReadPauseMenu


pressedAP:
/* ------- draw the bg again ----- */


	ldr 	r5, =480			// x-coor of start
	ldr 	r6, =320 			// y-coor of start
	ldr r7, =0x0
	mov  r3, #0
	mov  r4, #0
	ldr  r8, =64

drawPauseMenuBLACK:
	cmp r3, #96
	beq maxWidthPauseMenuBLACK
	mov r0, r5
	mov r1, r6
	mov r2, r7
	push {r0-r10}
	bl 	DrawPixel
	pop {r0-r10}
	add r5, #1
	add r3, #1
	b drawPauseMenuBLACK

maxWidthPauseMenuBLACK:
	add r6, #1
	add r4, #1
	cmp r4, r8
	beq maxHeightPauseMenuBLACK
	sub r5, #96
	mov r3, #0
	b 	drawPauseMenuBLACK

maxHeightPauseMenuBLACK:
	bl 	WallMaker				//redraw the walls

	ldr	r2, =hasApple
	ldr	r0, [r2]
	ldr	r1, [r2, #4]
	ldr	r2, =apple
	bl	DrawBox

//check to quit or resume

	cmp 	r9, #5 				//check if we are starting game
	bne 	drawQuit 			// if r5 != 0, then quit
	pop 	{r0-r10, lr}
	mov 	pc, lr



.globl 	gameOver
gameOver:
	//reset the score
	ldr	r5, =score
	mov	r6, #0
	str	r6, [r5]
	//draw game over pic
	mov	r5, #0
	mov	r6, #0
	ldr r7, =0xffff
	//ldr  r7, =GameOverScreen
	mov  r3, #0
	mov  r4, #0
	ldr  r8, =767

drawGameOver:
	cmp r3, #1024
	beq maxWidthGameOver
	mov r0, r5
	mov r1, r6
	mov r2, r7
	//ldr r2, [r7], #2
	push {r0-r10}
	bl 	DrawPixel
	pop {r0-r10}
	add r5, #1
	add r3, #1
	b drawGameOver

maxWidthGameOver:
	add r6, #1
	add r4, #1
	cmp r4, r8
	beq maxHeightGameOver
	sub r5, #1024
	mov r3, #0
	b 	drawGameOver
	
maxHeightGameOver:
	bl	Read_SNES
	ldr	r1, [r0]
	ldr r10, =0xfffffeff
	cmp	r1, r10
	beq	StartGame 					//If A was pressed, go to StartGame
	ldr r10, =0xfffffffe
	cmp r1, r10
	beq drawQuit 					//If B was pressed, quit game

	ldr	r4, =lives
	mov	r5, #3
	str	r5, [r4]

	b	maxHeightGameOver



