.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:
//	mov	sp, #0x8000	//get rid of this when initialising interrupts

	bl	EnableJTAG

	mov 	r4, #0
	mov 	r5, #0
	mov 	r6, #0
	mov 	r7, #0
	mov 	r8, #0
	mov 	r9, #0
	mov 	r10, #0

	//bl	InstallIntTable
	bl	Init_GPIO
	bl	InitFrameBuffer
	bl 	MainMenu
	//b  haltLoop$




// Game begins
.globl StartGame
StartGame:

	
	ldr	r4, =hasDoor
	mov	r3, #0
	str	r3, [r4]
	ldr	r4, =hasApple
	ldr r0, [r4]
	ldr r1, [r4, #4]
	lsr		r0, #5
	lsr		r1, #5
	bl 		getIndex
	mov 	r1, #0
	bl 		setIndexContent

	ldr	r4, =lives
	ldr	r5, [r4]
	cmp	r5, #0
	beq	gameOver
	mov 	r4, #0
	mov 	r5, #0

	bl  drawBG
	bl	wall
	
	bl 	initializeGrid
	push	{r0-r10}
	bl	writeScore
	pop 	{r0-r10}
	push 	{r0-r10}
	bl	writeLives
	pop 	{r0-r10}

	bl	WallMaker

	b 	playGame

gameOver:
	//reset snake length
	mov	r5, #4				//length equals number - 1
	ldr	r2, =snakeLength
	str	r5, [r2]			//store the value

	//reset the score
	ldr	r5, =score
	mov	r6, #0
	str	r6, [r5]
	//draw game over pic
	mov	r5, #0
	mov	r6, #0
	//ldr r7, =0xffff
	ldr  r7, =GameOverScreen
	mov  r3, #0
	mov  r4, #0
	ldr  r8, =767

drawGameOver:
	cmp r3, #1024
	beq maxWidthGameOver
	mov r0, r5
	mov r1, r6
	//mov r2, r7
	ldr r2, [r7], #2
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

//Resetting registers 
	mov 	r4, #0
	mov 	r5, #0
	mov 	r6, #0
	mov 	r7, #0
	mov 	r8, #0
	mov 	r9, #0
	mov 	r10, #0

/* how we draw the main menu is exactly how 
we draw the background, but we are drawing a different
picture (check drawBG for documentation)
*/
MainMenu:
	push {r0-r10, lr}
	mov	r5, #0 					
	mov	r6, #0
	//ldr r7, =0x0
	ldr  r7, =StartScreen
	mov  r3, #0
	mov  r4, #0
	ldr  r8, =767

drawMainMenu:
	cmp r3, #1024
	beq maxWidthMenu
	mov r0, r5
	mov r1, r6
	//mov r2, r7
	ldr r2, [r7], #2
	push {r0-r10}
	bl 	DrawPixel
	pop {r0-r10}
	add r5, #1
	add r3, #1
	b drawMainMenu

maxWidthMenu:
	add r6, #1
	add r4, #1
	cmp r4, r8
	beq maxHeightMenu
	sub r5, #1024
	mov r3, #0
	b 	drawMainMenu
	
maxHeightMenu:


goBackToReadMainMenu:
	mov 	r5, #5 				// 5 = flag equals start
	ldr 	r1, =330 			// x-coor of start  
	ldr 	r2, =450			// x-coor of start  
	ldr 	r0, =pointer  		// green
	bl 		drawBrickMM

ReadMainMenu:
	
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
	beq		pressedUP 
	ldr 	r10, =0xffffffdf 
	cmp	 	r1, r10					// check if DOWN was pressed
	beq 	pressedDownMM

	ldr 	r10, =0xfffffeff 		// check if A was pressed
	cmp 	r1, r10
	beq 	pressedA

	b 		ReadMainMenu

pressedUP:
	mov 	r5, #5 				// 5 = flag equals start
	ldr 	r1, =330 			// x-coor of start  
	ldr 	r2, =450 			// y-coor of start
	ldr 	r0, =pointer 		// green = start
	bl 		drawBrickMM
	
	ldr 	r1, =330 			// x-coor of quit  
	ldr 	r2, =525 			// y-coor of quit
	ldr 	r0, =SnakeGone		// replace with black
	bl 		drawBrickMM
	b 		ReadMainMenu

pressedDownMM:
/* when you press down,  the pointer to start 
	screen is replaced by BG colour
*/
	
// pointer in 'Start Game' replaced by BG
	mov 	r5, #10 			// 10 = flag equals quit
	ldr 	r1, =330 			// x-coor of start
	ldr 	r2, =450 			// y-coor of start
	ldr 	r0, =SnakeGone 		// replacing quit with black
	bl 		drawBrickMM


	ldr 	r1, =330 			// x-coor of quit
	ldr 	r2, =525 			// x-coor of quit
	ldr 	r0, =pointer 		// pink = quit
	bl 		drawBrickMM
	b 		ReadMainMenu


pressedA:

	cmp 	r5, #5 				//check if we are starting game
	bne 	drawQuit 			// if r5 != 0, then quit
	b 		StartGame
	pop 	{r0-r10, lr}
	mov 	pc, lr
	
.globl drawQuit
drawQuit:

	bl 		drawBG	 			// draw black 
	b 		haltLoop$ 			// halt loop = quit


// ----------------------
.globl drawBG
drawBG:
	push {r0-r10, lr}
	//ldr  r7, =background 	// uncomment later
	mov  r5, #0
	mov  r6, #0
	mov  r3, #0 		//# of x pixels drawn
	mov  r4, #0 		//# of y pixels drawn
	ldr r8, =767 	

drawBGLoop:
	cmp	 r3, #1024 		//checking x limit
	beq  maxWidthBG
	mov  r0, r5
	mov  r1, r6
	//ldr  r2, [r7], #2   // uncomment later
	ldr  r2, =0x0
	push {r0-r10}
	bl 	 DrawPixel
	pop  {r0-r10}
	add  r5, #1
	add  r3, #1
	b 	 drawBGLoop

maxWidthBG:
	add r6, #1 				// adding 1 to the y-coordinate 
	add r4, #1 				// adding 1 to the y pixel counter 
	cmp r4, r8			// checking how many pixels have been drawn vertically 
	beq maxHeightBG 		// if we have drawn 32 pixels vertically, we branch 
	sub r5, #1024 			// resetting the x-coordinate for the next line 
	mov r3, #0 				// resetting x pixel counter 
	b 	drawBGLoop   		// branch back to draw 

maxHeightBG:
	pop {r0-r10, lr} 				// pop lr 
	mov pc, lr 				// go back to calling code 



playGame:
	//initial values
	bl 	InitApple
	mov	r6, #0
	mov	r0, #320 			// what is r0 and r1?
	mov	r1, #2
	lsl	r1, #5 			//
	mov	r8, #4				//start moving right
	ldr	r6, =snakeDirection
	str	r8, [r6]

	ldr	r3, =snakex
	ldr	r4, =snakey

	//initialise where the snake begins
	// this is initialised so the body starts with length of 4 (plus back space = 5)
	str	r0, [r3, #12]			//snake head begins
	str	r1, [r4, #12]

	sub	r0, #32					//snake body begins
	str	r0, [r3, #8]
	str	r1, [r4, #8]

	sub	r0, #32					//snake tail
	str	r0, [r3, #4]
	str	r1, [r4, #4]

	sub	r0, #32					//blank (after tail)
	str	r0, [r3]
	str	r1, [r4]



gameLoop:
	push	{r0-r10}

	//bl	powerUpMake
	//bl 	initInterrupt

	bl	Read_SNES
	ldr	r1, [r0]			//load values from r0 to see which buttons pressed
loopagain:
	cmp	r1, #0xffffffdf			//check if DOWN was pushed
	beq	mayTurnD
	cmp	r1, #0xffffffef			//check if UP was pushed
	beq	mayTurnU
	cmp	r1, #0xffffffbf			//check if LEFT was pushed
	beq	mayTurnL
	cmp	r1, #0xffffff7f			//check if RIGHT was pushed
	beq	mayTurnR
	cmp r1, #0xfffffff7
	bleq Pause
	b	moving				//if none of the above, continue automatically moving



	//check if snake is making illegal move
mayTurnD:
	ldr	r6, =snakeDirection
	ldr	r8, [r6]
	cmp	r8, #1		//if 1, snake is currently moving up
	beq	moving
	bne	turnDown
mayTurnU:
	ldr	r6, =snakeDirection
	ldr	r8, [r6]
	cmp	r8, #2		//if 2, snake is currently moving down
	beq	moving
	bne	turnUp
mayTurnL:
	ldr	r6, =snakeDirection
	ldr	r8, [r6]
	cmp	r8, #4		//if 4, snake is currently moving right
	beq	moving
	bne	turnLeft
mayTurnR:
	ldr	r6, =snakeDirection
	ldr	r8, [r6]
	cmp	r8, #3		//if 3, snake is currently moving left
	beq	moving
	bne	turnRight	



moving:
	pop	{r0-r10}
	ldr	r6, =snakeDirection
	ldr	r8, [r6]

	cmp	r8, #1
	bleq	MoveU
	cmp	r8, #2
	bleq	MoveD
	cmp	r8, #3
	bleq	MoveL
	cmp	r8, #4
	bleq	MoveR
   	push	{r0-r2}
	ldr	r2, =lives
	ldr	r0, [r2]
	cmp	r0, #0
	pop	{r0-r2}
	beq	haltLoop


	push	{r0-r10}
	ldr	r2, =snakeSpeed			//Wait for 50000 microseconds (0.5 seconds)
	ldr r1, [r2]
	bl	Wait
	pop	{r0-r10}

	b	gameLoop

turnDown:
	pop	{r0-r10}
	bl	MoveD
	push	{r0-r10}

	bl	Read_SNES
	ldr	r1, [r0]			//load values from r0 to see which buttons pressed
	push	{r1}
	ldr	r2, =snakeSpeed			//Wait for 50000 microseconds (0.5 seconds)
	ldr r1, [r2]
	bl	Wait
	pop	{r1}
	cmp	r1, #0xffffffff 	//If no button is pressed, continue moving down
	bne	loopagain
	b	turnDown

turnUp:
	pop	{r0-r10}
	bl	MoveU
	push	{r0-r10}

	bl	Read_SNES
	ldr	r1, [r0]			//load values from r0 to see which buttons pressed
	push	{r1}
	ldr	r2, =snakeSpeed			//Wait for 50000 microseconds (0.5 seconds)
	ldr r1, [r2]
	bl	Wait
	pop	{r1}
	cmp	r1, #0xffffffff 	//If no button is pressed, continue moving up
	bne	loopagain
	
	b	turnUp
turnLeft:
	pop	{r0-r10}
	bl	MoveL
	push	{r0-r10}

	bl	Read_SNES
	ldr	r1, [r0]			//load values from r0 to see which buttons pressed
	push	{r1}
	ldr	r2, =snakeSpeed			//Wait for 50000 microseconds (0.5 seconds)
	ldr r1, [r2]
	bl	Wait
	pop	{r1}
	cmp	r1, #0xffffffff
	bne	loopagain
	
	
	b	turnLeft
turnRight:
	pop	{r0-r10}
	bl	MoveR
	push	{r0-r10}

	bl	Read_SNES
	ldr	r1, [r0]			//load values from r0 to see which buttons pressed
	push	{r1}
	ldr	r2, =snakeSpeed			//Wait for 50000 microseconds (0.5 seconds)
	ldr r1, [r2]
	bl	Wait
	pop	{r1}
	cmp	r1, #0xffffffff
	bne	loopagain
	
	b	turnRight

haltLoop:

	b	haltLoop


UpdateSnake:
	push 	{r0-r10, lr}		//all values must be saved or it'll
					//kill the program (or my pi) so 
					//yes we are temporarily going
					//against the ACPS format
	bl 	getColumnAndRow
	bl 	getIndex
	mov 	r1, #3
	bl 	setIndexContent
 	pop 	{r0-r10, lr}
 	mov 	pc, lr


/*---------MoveU--------------------*/
MoveU:
	push {lr}
	//check if snake ate apple
	bl	AteApple
	//update grid to say snake is here
	bl 	UpdateSnake
	ldr	r2, =snakeLength
	ldr	r5, [r2]
	mov	r8, #1				//state that it's moving up
	ldr	r6, =snakeDirection
	str	r8, [r6]
	sub	r1, #32				//move head up
	str	r1, [r4, r5, lsl #2]

	push	{r0-r10, lr}
	bl	DrawSnake
	pop	{r0-r10, lr}



	pop {lr}
	mov	pc, lr

/*---------MoveD--------------------*/
MoveD:
	push {lr}
	//check if snake ate apple
	bl	AteApple
	//update grid to say snake is here
	bl 	UpdateSnake
	ldr	r2, =snakeLength
	ldr	r5, [r2]
	mov	r8, #2				//state that it's moving down
	ldr	r6, =snakeDirection
	str	r8, [r6]
	add	r1, #32				//move head down
	str	r1, [r4, r5, lsl #2]

	push	{r0-r10, lr}
	bl	DrawSnake
	pop	{r0-r10, lr}

	pop {lr}
	mov	pc, lr

/*---------MoveL--------------------*/
MoveL:	
	push {lr}
	//check if snake ate apple
	bl	AteApple
	//update grid to say snake is here
	bl 	UpdateSnake
	ldr	r2, =snakeLength
	ldr	r5, [r2]
	mov	r8, #3				//state that it's moving left
	ldr	r6, =snakeDirection
	str	r8, [r6]
	sub	r0, #32				//move head left
	str	r0, [r3, r5, lsl #2]

	push	{r0-r10, lr}
	bl	DrawSnake
	pop	{r0-r10, lr}

	pop {lr}
	mov	pc, lr

/*---------MoveR--------------------*/
MoveR:
	push {lr}
	//check if snake ate apple
	bl	AteApple
	//update grid to say snake is here
	bl 	UpdateSnake

	ldr	r2, =snakeLength
	ldr	r5, [r2]
	mov	r8, #4				//state that it's moving right
	ldr	r6, =snakeDirection
	str	r8, [r6]
	add	r0, #32				//move head right
	str	r0, [r3, r5, lsl #2]

	push	{r0-r10, lr}
	bl	DrawSnake
	pop	{r0-r10, lr}

	pop {lr}
	mov	pc, lr


/*---------DrawSnake Subroutine---------*/	
DrawSnake:
	push 	{r0-r10, lr}
	ldr	r2, =snakeLength
	ldr	r5, [r2]
	mov	r7, r5
	str	r0, [r3, r7, lsl #2]	//store x value into r3 at head
	str	r1, [r4, r7, lsl #2]	//store y value into r4 at head

	bl 	checkWon

	//check if snake is hitting edge
checkLegal:

	cmp	r0, #32
	blt	die
	mov	r6, #992
	cmp	r0, r6
	bge	die
	cmp	r1, #32
	blt	die
	cmp	r1, #672
	bge	die

	push 	{r0-r9}				//save coordinate values
	bl 	getColumnAndRow
	bl 	getIndex
	bl 	getIndexContent	
	mov 	r10, r0 			//move to r10
	pop 	{r0-r9}				//restore coordinate values
//	cmp 	r10, #3 			//check if it's empty or not
//	beq	die
	cmp	r10, #1
	beq	die
	cmp 	r10, #4
	beq 	winScreen


	//check if snake eats itself
checkCannibalism:
	mov	r6, r5			//begin counter version 2

cannibalLoop:
	sub	r6, #1			//iterate backwards
	cmp	r6, #1			//if reached end of array
	ble	safeToMove		//then snake isn't eating itself

	ldr	r9, [r3, r6, lsl #2]	//load snake's body
	ldr	r10, [r4, r6, lsl #2]

	cmp	r0, r9			//if both x coordinates equal
	bne	cannibalLoop		//if they don't then restart loop, else check
	cmp	r1, r10			//if both y coordinates equal
	beq	die			//if they do, snake ate itself

	cmp	r6, #1			//check if snake reached end of array
	bgt	cannibalLoop		//if not, continue checking

die:
	ldr	r5, =snakeLength
	ldr	r6, [r5]

	//decrease number of lives
	ldr	r2, =lives
	ldr	r0, [r2]
	sub	r0, #1
	str	r0, [r2]

	//half the score
	ldr	r2, =score
	ldr 	r0, [r2]
	lsr	r0, #1		//divide by 2
	str	r0, [r2]

	mov 	r5, #0 		// r0 = column 
	mov 	r6, #23 	// r1 = row 

redrawScoreandLives:
	cmp 	r5, #8
	mov 	r0, r5
	mov 	r1, r6 
	bgt 	goToStartGame
	bl 		getPixelXandY
	mov 	r2, r1
	mov 	r1, r0 
	ldr 	r0, =SnakeGone
	bl 		drawBrickMM
	add 	r5, #1
	b 		redrawScoreandLives
goToStartGame:
	b	StartGame

safeToMove:
	//load which head image to draw depending on direction it's moving
	cmp	r8, #1
	ldreq	r2, =SnakeHead_U
	cmp	r8, #2
	ldreq	r2, =SnakeHead_D
	cmp	r8, #3
	ldreq	r2, =SnakeHead_L
	cmp	r8, #4
	ldreq	r2, =SnakeHead_R
	bl	DrawBox

// this will only do the turn once.
follow:
	// check if turning
	// by how the controller works, 1 = up
	//				2 = down
	//				3 = left
	//				4 = right
	ldr	r6, =snakeDirection
	ldr	r8, [r6]

	cmp	r8, #1		//check what previously was
	beq	moveTurnU
	cmp	r8, #2		//check what previously was
	beq	moveTurnD
	cmp	r8, #3		//check what previously was
	beq	moveTurnL
	cmp	r8, #4		//check what previously was
	beq	moveTurnR

update:
	mov	r7, #1

updateLoop:
	mov	r8, r7
	add	r8, #1
	cmp	r7, r5
	bge	drawTail

	ldr	r0, [r3, r7, lsl #2]
	ldr	r1, [r4, r7, lsl #2]

	mov	r8, r7
	sub	r8, #1
	str	r0, [r3, r8, lsl #2]
	str	r1, [r4, r8, lsl #2]

	add	r7, #1
	b	updateLoop


/*----------Move UP----------*/
moveTurnU:
	ldr	r0, [r3, r7, lsl #2]	//load previous
	ldr	r1, [r4, r7, lsl #2]
	add	r1, #32			//move current
	sub	r7, #1
	str	r0, [r3, r7, lsl #2]	//update current
	str	r1, [r4, r7, lsl #2]

	ldr	r2, =SnakeBody_U	//draw the body	
	bl	DrawBox


	mov	r8, r7			//make r8 currrent array index
	sub	r8, #2			//look two before current

	ldr	r9, [r3, r8, lsl #2]	//load two before current
	ldr	r10, [r4, r8, lsl #2]

	mov	r6, r10
	sub	r6, r1
	cmp	r6, #0
	bgt	update			//if y1 - y2 = 0, then it is bent. Else it's going straight

	// problem is that if you turn REALLY TIGHT CORNER (no space in between) it wont draw.
	// if you take out the top 4 codes, then the "bend" will appear twice
	// :/

	//before is r0, r1 (x1, y1 respectively), after is r9, r10 (x2, y2 respectively)
	cmp	r0, r9			//compare with before and after (previously loaded)
	ble	check2_U

	add	r8, #2
	ldr	r0, [r3, r8, lsl #2]	//load the corner's coordinates
	ldr	r1, [r4, r8, lsl #2]

	ldr	r2, =SnakeBody_LU	//draw the corner
	bl	DrawBox


	cmp	r0, r9			//compare with before and after (previously loaded)
	beq	update

check2_U:
	cmp	r0, r9			//compare with before and after (previously loaded)
	bge	update

	add	r8, #2
	ldr	r0, [r3, r8, lsl #2]	//load the corner's coordinates
	ldr	r1, [r4, r8, lsl #2]

	ldr	r2, =SnakeBody_RU	//draw the corner
	bl	DrawBox

	b	update

/*----------Move DOWN----------*/
moveTurnD:
	ldr	r0, [r3, r7, lsl #2]	//load previous
	ldr	r1, [r4, r7, lsl #2]
	sub	r1, #32			//move current
	sub	r7, #1
	str	r0, [r3, r7, lsl #2]	//update current
	str	r1, [r4, r7, lsl #2]

	ldr	r2, =SnakeBody_D	//draw the body	
	bl	DrawBox

/*-- check if turning --*/
	mov	r8, r7			//make r8 currrent array index
	sub	r8, #2			//look two before current

	ldr	r9, [r3, r8, lsl #2]	//load two before current
	ldr	r10, [r4, r8, lsl #2]

	mov	r6, r10
	sub	r6, r1
	cmp	r6, #0
	bne	update			//if y1 - y2 = 0, then it is bent. Else it's going straight
	// problem is that if you turn REALLY TIGHT CORNER (no space in between) it wont draw.
	// if you take out the top 4 codes, then the "bend" will appear twice
	// :/

	//before is r0, r1 (x1, y1 respectively), after is r9, r10 (x2, y2 respectively)
	cmp	r0, r9			//compare with before and after (previously loaded)
	ble	check2_D

	add	r8, #2
	ldr	r0, [r3, r8, lsl #2]	//load the corner's coordinates
	ldr	r1, [r4, r8, lsl #2]

	ldr	r2, =SnakeBody_RD	//draw the corner
	bl	DrawBox


	cmp	r0, r9			//compare with before and after (previously loaded)
	beq	update

check2_D:
	cmp	r0, r9			//compare with before and after (previously loaded)
	bge	update

	add	r8, #2
	ldr	r0, [r3, r8, lsl #2]	//load the corner's coordinates
	ldr	r1, [r4, r8, lsl #2]

	ldr	r2, =SnakeBody_LD	//draw the corner
	bl	DrawBox


	b	update

/*----------Move LEFT----------*/
moveTurnL:
	ldr	r0, [r3, r7, lsl #2]	//load previous
	ldr	r1, [r4, r7, lsl #2]
	add	r0, #32			//move current
	sub	r7, #1
	str	r0, [r3, r7, lsl #2]	//update current
	str	r1, [r4, r7, lsl #2]

	ldr	r2, =SnakeBody_L	//draw the body	
	bl	DrawBox

/*-- check if turning --*/
	mov	r8, r7			//make r8 currrent array index
	sub	r8, #2			//look two before current

	ldr	r9, [r3, r8, lsl #2]	//load two before current
	ldr	r10, [r4, r8, lsl #2]

	mov	r6, r9
	sub	r6, r0
	cmp	r6, #0
	bne	update			//if y1 - y2 = 0, then it is bent. Else it's going straight
	// problem is that if you turn REALLY TIGHT CORNER (no space in between) it wont draw.
	// if you take out the top 4 codes, then the "bend" will appear twice
	// :/

	//before is r0, r1 (x1, y1 respectively), after is r9, r10 (x2, y2 respectively)
	cmp	r1, r10			//compare with before and after (previously loaded)
	ble	check2_L

	add	r8, #2
	ldr	r0, [r3, r8, lsl #2]	//load the corner's coordinates
	ldr	r1, [r4, r8, lsl #2]

	ldr	r2, =SnakeBody_DL	//draw the corner
	bl	DrawBox

	cmp	r0, r9			//compare with before and after (previously loaded)
	beq	update

check2_L:
	cmp	r1, r10			//compare with before and after (previously loaded)
	bge	update

	add	r8, #2
	ldr	r0, [r3, r8, lsl #2]	//load the corner's coordinates
	ldr	r1, [r4, r8, lsl #2]

	ldr	r2, =SnakeBody_UL	//draw the corner
	bl	DrawBox


	b	update

/*----------Move RIGHT----------*/
moveTurnR:
	ldr	r0, [r3, r7, lsl #2]	//load previous
	ldr	r1, [r4, r7, lsl #2]
	sub	r0, #32			//move current
	sub	r7, #1
	str	r0, [r3, r7, lsl #2]	//update current
	str	r1, [r4, r7, lsl #2]

	ldr	r2, =SnakeBody_R	//draw the body	
	bl	DrawBox

/*-- check if turning --*/
	mov	r8, r7			//make r8 currrent array index
	sub	r8, #2			//look two before current

	ldr	r9, [r3, r8, lsl #2]	//load two before current
	ldr	r10, [r4, r8, lsl #2]

	mov	r6, r9
	sub	r6, r0
	cmp	r6, #0
	bne	update			//if y1 - y2 = 0, then it is bent. Else it's going straight
	// problem is that if you turn REALLY TIGHT CORNER (no space in between) it wont draw.
	// if you take out the top 4 codes, then the "bend" will appear twice
	// :/

	//before is r0, r1 (x1, y1 respectively), after is r9, r10 (x2, y2 respectively)
	cmp	r1, r10			//compare with before and after (previously loaded)
	ble	check2_R

	add	r8, #2
	ldr	r0, [r3, r8, lsl #2]	//load the corner's coordinates
	ldr	r1, [r4, r8, lsl #2]

	ldr	r2, =SnakeBody_DR	//draw the corner
	bl	DrawBox


	cmp	r0, r9			//compare with before and after (previously loaded)
	beq	update

check2_R:
	cmp	r1, r10			//compare with before and after (previously loaded)
	bge	update

	add	r8, #2
	ldr	r0, [r3, r8, lsl #2]	//load the corner's coordinates
	ldr	r1, [r4, r8, lsl #2]

	ldr	r2, =SnakeBody_UR	//draw the corner
	bl	DrawBox

	b	update

// -------------drawTail-------------------------

drawTail:
	ldr	r9, [r3, #8]		//load coordinates right before tail
	ldr	r10, [r4, #8]

	push 	{r0-r10}		//all values must be saved or it'll
							//kill the program (or my pi) so 
							//yes we are temporarily going
							//against the ACPS format
	mov r0, r9
	mov	r1, r10

	bl 	getColumnAndRow
	bl 	getIndex
	mov r1, #0 			//say this part of grid is empty
	bl 	setIndexContent
 	pop 	{r0-r10}

	ldr	r0, [r3, #4]		//load tail coordinates
	ldr	r1, [r4, #4]

	push 	{r0-r10}		//all values must be saved or it'll
							//kill the program (or my pi) so 
							//yes we are temporarily going
							//against the ACPS format

	bl 	getColumnAndRow
	bl 	getIndex
	mov r1, #0 			//say this part of grid is empty
	bl 	setIndexContent
 	pop 	{r0-r10}

	//compare the two coordinates to know where to point tail
	cmp	r0, r9
	ldrlt	r2, =SnakeTail_R
	cmp	r0, r9
	ldrgt	r2, =SnakeTail_L
	cmp	r1, r10
	ldrlt	r2, =SnakeTail_D
	cmp	r1, r10
	ldrgt	r2, =SnakeTail_U
	bl	DrawBox

	ldr	r0, [r3]		//load coordinates of very end
	ldr	r1, [r4]
	ldr	r2, =SnakeGone		//fill with background colour
	bl	DrawBox	

	push 	{r0-r10}		//all values must be saved or it'll
							//kill the program (or my pi) so 
							//yes we are temporarily going
							//against the ACPS format

	bl 	getColumnAndRow
	bl 	getIndex
	mov r1, #0 			//say this part of grid is empty
	bl 	setIndexContent
 	pop 	{r0-r10}


	pop	{r0-r10, lr}
	mov	pc, lr



InitApple:
	push 	{r4-r10, lr}

/*
	ldr  r2, =hasApple
	ldr  r0, [r2]
	ldr  r1, [r2, #4]
	bl 	getColumnAndRow			// x, y = *1
	bl 	getIndex 				// get array num
	mov r1, #0
	bl 	setIndexContent 
*/

	bl 	randomNumber			//x, y = *32
	ldr	r4, =hasApple
	str	r0, [r4]
	str	r1, [r4, #4]
	bl 	drawApple 				// drawing apple
	bl 	getColumnAndRow			//x, y = *1
	bl 	getIndex 				//get array num
	mov r1, #2 
	bl 	setIndexContent 		//set it as apple

	pop 	{r4-r10, lr}
	mov 	pc, lr


drawApple:
/* @param
 		r0 = row # 
		r1 = column #
*/
	//draw the apple
	push 	{r4-r10, lr}
	ldr	r2, =apple
	bl	DrawBox

	pop 	{r4-r10, lr}
	mov 	pc, lr


AteApple:
	//check if it ate an apple
	push 	{r0-r10,lr}

	bl 	getColumnAndRow		//coordinates in *1 form
	bl 	getIndex 		//change numbers into array form
	bl 	getIndexContent		//get what's in grid 
	cmp r0, #2 			//check to see if it's 2 (has apple) or not
	mov	r10, r0
	bne leaveAteApple		//if not, leave subroutine
	bl 	getColumnAndRow
	bl 	getIndex
	mov r0, #0
	bl 	setIndexContent
break:
	ldr	r2, =snakeLength	//if it equals, increase r5 by 1
	ldr	r5, [r2]
	cmp	r5, #10			//after eating 20 apples (plus initial 4)
	bge	noGrow
	blt	contAteApple
noGrow:
	ldr	r2, =hasDoor
	ldr	r5, [r2]
	cmp	r5, #1			//only call exitDoor once
	bge	leaveAteApple
	bl	exitDoor
	mov	r5, #1
	str	r5, [r2]
	b	leaveAteApple

contAteApple:
	add	r5, #1			//increase snake length
	str	r5, [r2]
	ldr	r2, =score		//increase score by	
	ldr	r5, [r2]
	add	r5, #2			//two!
	str	r5, [r2]
	push 	{r0-r10}
	bl	writeScore
	pop 	{r0-r10}
	push 	{r0-r10, lr}
//Use this snippit also for the random power-up item	
tryRandom:
	bl	randomNumber		//get random coordinates, in *32 form
	push 	{r0,r1}				//save coordinate values
	bl 	getColumnAndRow
	bl 	getIndex
	bl 	getIndexContent	
	mov 	r2, r0 				//move to r2
	pop 	{r0,r1}				//restore coordinate values
	cmp 	r2, #0 				//check if it's empty or not
	bne 	tryRandom
	ldr	r4, =hasApple
	str r0, [r4]
	str r1, [r4, #4]
	bl 	drawApple	
	bl 	getColumnAndRow
	bl 	getIndex
	mov r1, #2
	bl 	setIndexContent

	pop 	{r0-r10, lr}

leaveAteApple:
	pop	{r0-r10, lr}
	mov	pc, lr


exitDoor:
	push	{r0-r10, lr}

	ldr	r4, =snakeLength
	ldr	r5, [r4]
	cmp	r5, #10			//after eating 20 apples (plus initial 4)
	blt	endExitDoor
tryRandom2:
	bl	randomNumber		//get random coordinates, in *32 form
	push 	{r0,r1}				//save coordinate values
	bl 	getColumnAndRow
	bl 	getIndex
	bl 	getIndexContent	
	mov 	r2, r0 				//move to r2
	pop 	{r0,r1}				//restore coordinate values
	cmp 	r2, #0 				//check if it's empty or not
	bne 	tryRandom2

	ldr	r6, =doorCoord
	str	r0, [r6]
	str	r1, [r6, #4]
	ldr	r2, =door
	bl	DrawBox

	bl 	getColumnAndRow			//x, y = *1
	bl 	getIndex 				//get array num
	mov r1, #4 
	bl 	setIndexContent 		//set it as exit door

	lsr r0, #5
	lsr r1, #5

	bl 		getIndex
	mov 	r1, #4
	bl 		setIndexContent


endExitDoor:	
	pop	{r0-r10, lr}
	mov	pc, lr


makeWall:
	mov	r3, #32
	mov	r4, #32
	
	bl	DrawBox

	mov	pc, lr	

DrawChar:
	push	{r4-r8, lr}

	chAdr	.req	r4
	px	.req	r5
	py	.req	r6
	row	.req	r7
	mask	.req	r8

	ldr	chAdr, =font		// load the address of the font map

	add	chAdr, r0, lsl #4	// char address = font base + (char * 16)

	mov	py, r6

charLoop$:
 	mov	px, r9		// init the X coordinate

	mov	mask, #0x01		// set the bitmask to 1 in the LSB
	
	ldrb	row, [chAdr], #1	// load the row byte, post increment chAdr

rowLoop$:
	tst	row, mask		// test row byte against the bitmask
	beq	noPixel$

	mov	r0, px
	mov	r1, py
	ldr	r2, =0x3cee		// greenish
	push	{lr}
	bl	DrawPixel2		// draw red pixel at (px, py)
	pop	{lr}	

noPixel$:
	add	px, #1			// increment x coordinate by 1
	lsl	mask, #1		// shift bitmask left by 1

	tst	mask, #0x100		// test if the bitmask has shifted 8 times (test 9th bit)
	beq	rowLoop$

	add	py, #1			// increment y coordinate by 1

	tst	chAdr,#0xF
	bne	charLoop$		// loop back to charLoop$, 
					// unless address evenly divisibly by 16
					// (ie: at the next char)

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask

	pop	{r4-r8, lr}
	mov	pc, lr

writeLives:
	push	{r0-r10, lr}
	
	mov 	r3, #4 		// r0 = column 
	mov 	r4, #22 	// r1 = row 

emptyLives:
	cmp 	r3, #3
	mov 	r0, r3
	mov 	r1, r4 
	bgt 	nowWriteLives
	bl 		getPixelXandY
	mov 	r2, r1
	mov 	r1, r0 
	ldr 	r0, =SnakeGone
	bl 		drawBrickMM
	add 	r3, #1
	b 		emptyLives
	pop 	{r0-r10, lr}
nowWriteLives:
	push 	{r0-r10, lr}
	mov	r6, #22			//initiate y
	lsl	r6, #5			//multiply by 32
	mov	r9, #4			//initiate x
	lsl	r9, #5			//multiply by 32

	mov	r0, #'L'
	bl	DrawChar

	add	r9, #10
	mov	r0, #'I'
	bl	DrawChar

	add	r9, #10
	mov	r0, #'V'
	bl	DrawChar

	add	r9, #10
	mov	r0, #'E'
	bl	DrawChar

	add	r9, #10
	mov	r0, #'S'
	bl	DrawChar

	add	r9, #10
	mov	r0, #':'
	bl	DrawChar

	//MY ITOA DOESN'T DO 0... so that's why it's blank when number
	//is 0 (not including 10, 20, etc.)
	ldr	r4, =lives
	ldr	r2, [r4]
	mov	r7, r2			//save value
	ldr	r0, =livesArray
	bl	itoa
	ldr	r5, =livesArray
	ldrb	r0, [r5]

	add	r9, #10
	bl	DrawChar

	cmp	r7, #10			//if less than ten
	blt	endScoreShow		//don't write second digit
	ldrb	r0, [r5, #1]
	add	r9, #10
	bl	DrawChar

	pop	{r0-r10, lr}
	mov	pc, lr


writeScore:
	push	{r0-r10, lr}
	
	mov 	r5, #0 		// r0 = column 
	mov 	r6, #22 	// r1 = row 

emptyScore:
	cmp 	r5, #3
	mov 	r0, r5
	mov 	r1, r6 
	bgt 	nowWriteScore
	bl 		getPixelXandY
	mov 	r2, r1
	mov 	r1, r0 
	ldr 	r0, =SnakeGone
	bl 		drawBrickMM
	add 	r5, #1
	b 		emptyScore

nowWriteScore:
	
	mov	r6, #22			//initiate y
	lsl	r6, #5			//multiply by 32
	mov	r9, #0			//initiate x

	mov	r0, #'S'
	bl	DrawChar

	add	r9, #10
	mov	r0, #'C'
	bl	DrawChar

	add	r9, #10
	mov	r0, #'O'
	bl	DrawChar

	add	r9, #10
	mov	r0, #'R'
	bl	DrawChar

	add	r9, #10
	mov	r0, #'E'
	bl	DrawChar

	add	r9, #10
	mov	r0, #':'
	bl	DrawChar

	mov	r0, r9
	add	r0, #10
	mov	r1, r6
	ldr	r2, =SnakeGone
	bl	DrawBox

	//MY ITOA DOESN'T DO 0... so that's why it's blank when number
	//is 0 (not including 10, 20, etc.)
	ldr	r4, =score
	ldr	r2, [r4]
	mov	r7, r2			//save value
	ldr	r0, =scoreArray
	bl	itoa
	ldr	r5, =scoreArray
	ldrb	r0, [r5]

	add	r9, #10
	bl	DrawChar

	cmp	r7, #10			//if less than ten
	blt	endScoreShow		//don't write second digit
	ldrb	r0, [r5, #1]
	add	r9, #10
	bl	DrawChar

endScoreShow:
	pop	{r0-r10, lr}
	mov	pc, lr

haltLoop$:
	b		haltLoop$

.section .data

.globl hasApple
hasApple:
	.int 	0   				//x coordinate
	.int 	0					//y coordinate

hasDoor:
	.int	0

snakeDirection:
	.int	4

.globl lives 
lives:
	.int 	3

.globl score 
score:
	.int	0

.globl snakeLength
snakeLength:
	.int	4

.globl snakex
snakex:
	.rept	256
	.word	0
	.endr	

.globl snakey
snakey:
	.rept	256
	.word	0
	.endr	
	
.globl grid 
grid: 
	.rept	500
	.word	0
	.endr	


.align 4
font:	.incbin	"font.bin"


