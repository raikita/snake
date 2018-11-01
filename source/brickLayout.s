/*

Coordinates for start menu (x, y)
START GAME = (680, 450)
QUIT GAME = (660, 525)


drawBrickMM:
		r0 = pixel to draw
		r1 = x-coordinate
 		r2 = y-coordinate
*/
.globl 	drawBrickMM
drawBrickMM:
	push {r4-r10,lr}
	
	mov r7, r0 			// r7 = r0 = colour to draw

	mov r3, #0  		// # of x pixels drawn 
	mov r4, #0 			// # of y pixels drawn 

	mov r5, r1 			// r5 = r1 = x-coordinate 
	mov r6, r2 			// r6 = r2 = y-coordinate 

drawBrickLoopMM:
	cmp r3, #32 			// checking how many pixels have been drawn horizontally
	beq maxWidthBrickMM 	// branch if we have drawn 32 pixels horizontally
	mov r0, r5 				// moving x-coordinate to r0 
	mov r1, r6 				// moving y-coordinate to r1
	ldr	r2, [r7], #2 		// moving the right colour into r2 
	//mov r2, r7
	push {r0-r10} 			// preserving what's in r0-r10 before drawPixel 
	bl 	DrawPixel 			// drawing pixel 
	pop {r0-r10} 			// popping values from r0-r10
	add r5, #1 				// adding 1 to the x-coordinate 
	add r3, #1 				// adding 1 to counter for x pixels 
	b 	drawBrickLoopMM

maxWidthBrickMM:
	add r6, #1 				// adding 1 to the y-coordinate 
	add r4, #1 				// adding 1 to the y pixel counter 
	cmp r4, #32 			// checking how many pixels have been drawn vertically 
	beq maxHeightBrickMM 		// if we have drawn 32 pixels vertically, we branch 
	sub r5, #32 			// resetting the x-coordinate for the next line 
	mov r3, #0 				// resetting x pixel counter 
	b 	drawBrickLoopMM 		// branch back to draw 

maxHeightBrickMM:
	mov r1, #0
	mov r2, #0
	pop {r4-r10, lr} 		// pop lr 
	mov pc, lr 				// go back to calling code 


continueExec:
	pop 	{r0-r10, lr}
	mov 	pc, lr



// drawing wall 
.globl wall 
wall:
	
	// drawing upper horizontal line
	PUSH 	{lr}
	mov 	r1, #0 		// r4 has the x-coordinate
	mov 	r2, #0 		// r5 has the y-coordinate
	mov 	r0, #0 			// 0 = horizontal
	mov 	r3, #0 		// 0 = top
	bl 		drawWall
	
	// drawing lower horizontal line
	mov 	r1, #0 		// r4 has the x-coordinate
	ldr 	r2, =672		// r5 has the y-coordinate
	mov 	r0, #0 	 		// 0 = horizontal
	mov 	r3, #1 		// 1 = bottom
	bl 		drawWall
	
	// drawing left vertical line
	mov 	r1, #0		// r4 has the x-coordinate
	mov 	r2, #32 		// r5 has the y-coordinate
	mov 	r0, #1 			// 1 = vertical
	mov 	r3, #2 			// 2 = wallLeft
	bl 		drawWall
	
	// drawing right vertical line
	ldr 	r1, =991		// r4 has the x-coordinate
	mov 	r2, #32 		// r5 has the y-coordinate
	mov 	r0, #1 			// 1 = vertical
	mov 	r3, #3			// 3 = wallRight
	bl 		drawWall

	pop 	{lr}
	mov 	pc, lr 

.globl drawWall
// drawing one wall 
drawWall:
	PUSH 	{r4-r10, lr}
	mov 	r7, r0 			// r7 has the direction of drawing
	mov 	r4, r1 			// r4 = x-coordinate
	mov 	r5, r2 			// r5 = y-coordinate
	mov 	r6, #0 			// resetting r6
drawWallLoop: 				// horizontal drawn first
	mov 	r1, r4 			// moving x-coordinate for drawBrick
	mov 	r2, r5  		// moving y-coordinate for drawwBrick
	cmp  	r6, #0
	
notCorner:
	mov 	r10, r3
contDrawWallLoop:
	bl 		drawBrick
	cmp 	r7, #1 			// horizontal or vertical?
	beq 	drawVertical
	mov 	r8, #32 		// draw 32 horizontal bricks 
	add 	r4, #32 		// add next brick 
	b 	continue
drawVertical:
	add 	r5, #32 		// add next brick
	mov 	r8, #20 		// draw 20 vertical bricks
continue:
	add 	r6, #1 			//# of bricks ++
	cmp	  	r6, r8 			// checking # of bricks drawn
	bne 	drawWallLoop
	POP 	{r4-r10, lr}
	mov 	pc, lr


.globl drawBrick
// drawing one square brick 
drawBrick:
/* 	@param
 		r1 = x-coordinate
 		r2 = y-coordinate
		r7 = picture to print 
		r10 = kind of brick to draw
*/


	push {r4-r10,lr}
	
	mov r8, r10 			// r8 = kind of brick to draw
	
	// 0 = top
	// 1 = bottom
	// 2 = left
	// 3 = right

	cmp r8, #0
	beq brickTop
	cmp r8, #1
	beq brickBottom
	cmp r8, #2
	beq brickLeft
	cmp r8, #3
	beq brickRight
	
brickTop:
	ldr r7, =wallTop
	b 	continueBrick
brickBottom:
	ldr r7, =wallBottom
	b 	continueBrick

brickLeft:
	ldr r7, =wallLeft
	b 	continueBrick

brickRight:
	ldr r7, =wallRight
	b 	continueBrick

continueBrick:
	
	mov r3, #0  		// # of x pixels drawn 
	mov r4, #0 			// # of y pixels drawn 

	mov r5, r1 			// r5 = x-coordinate 
	mov r6, r2 			// r6 = y-coordinate 

drawBrickLoop:
	cmp r3, #32 			// checking how many pixels have been drawn horizontally
	beq maxWidthBrick 		// branch if we have drawn 32 pixels horizontally
	mov r0, r5 				// moving x-coordinate to r0 
	mov r1, r6 				// moving y-coordinate to r1
	ldr	r2, [r7], #2 		// moving the right colour into r2 
	push {r0-r10} 			// preserving what's in r0-r10 before drawPixel 
	bl 	DrawPixel 			// drawing pixel 
	pop {r0-r10} 			// popping values from r0-r10
	add r5, #1 				// adding 1 to the x-coordinate 
	add r3, #1 				// adding 1 to counter for x pixels 
	b 	drawBrickLoop

maxWidthBrick:
	add r6, #1 				// adding 1 to the y-coordinate 
	add r4, #1 				// adding 1 to the y pixel counter 
	cmp r4, #32 			// checking how many pixels have been drawn vertically 
	beq maxHeightBrick 		// if we have drawn 32 pixels vertically, we branch 
	sub r5, #32 			// resetting the x-coordinate for the next line 
	mov r3, #0 				// resetting x pixel counter 
	b 	drawBrickLoop 		// branch back to draw 

maxHeightBrick:
	mov r1, #0
	mov r2, #0
	mov r3, r10


	mov r0, #0
	mov r1, #0
	ldr r2, =cornerTLeft 
	bl   DrawBox 		// drawing pixel 

	mov r0, #31
	lsl r0, #5
	mov r1, #0
	ldr r2, =cornerTRight 
	bl   DrawBox 		// drawing pixel 

	mov r0, #0
	mov r1, #21
	lsl r1, #5
	ldr r2, =cornerBLeft 
	bl   DrawBox 		// drawing pixel 

	mov r0, #31
	lsl r0, #5
	mov r1, #21
	lsl r1, #5
	ldr r2, =cornerBRight 
	bl   DrawBox 		// drawing pixel 

	pop {r4-r10, lr} 		// pop lr 
	mov pc, lr 			// go back to calling code 




.globl	WallMaker			//draw all the walls
WallMaker:
	push	{r4-r10, lr}
	mov		r0, #14
	mov		r1, #10
	bl		wallDraw

	mov		r0, #15
	mov		r1, #10
	bl		wallDraw

	mov		r0, #16
	mov		r1, #10
	bl		wallDraw

	mov		r0, #17
	mov		r1, #10
	bl		wallDraw

	mov		r0, #3
	mov		r1, #16
	bl		wallDraw

	mov		r0, #4
	mov		r1, #17
	bl		wallDraw

	mov		r0, #2
	mov		r1, #15
	bl		wallDraw

	mov		r0, #29
	mov		r1, #5
	bl		wallDraw

	mov		r0, #17
	mov		r1, #14
	bl		wallDraw

	mov		r0, #15
	mov		r1, #8
	bl		wallDraw	

	mov		r0, #14
	mov		r1, #30
	bl		wallDraw

	mov		r0, #29
	mov		r1, #19
	bl		wallDraw

	mov		r0, #24
	mov		r1, #19
	bl		wallDraw

	mov		r0, #14
	mov		r1, #8
	bl		wallDraw

	mov		r0, #14
	mov		r1, #9
	bl		wallDraw

	mov		r0, #25
	mov		r1, #18
	bl		wallDraw

	mov		r0, #16
	mov		r1, #16
	bl		wallDraw

	mov		r0, #16
	mov		r1, #15
	bl		wallDraw

	mov		r0, #11
	mov		r1, #14
	bl		wallDraw

	mov		r0, #4
	mov		r1, #1
	bl		wallDraw

	mov		r0, #4
	mov		r1, #2
	bl		wallDraw

	mov		r0, #4
	mov		r1, #3
	bl		wallDraw

	pop		{r4-r10, lr}
	mov		pc, lr


wallDraw:
	push	{r4-r10, lr}

	lsl		r1, #5
	lsl		r0, #5
	ldr		r2, =block
	bl 		DrawBox

	lsr		r0, #5
	lsr		r1, #5

	bl 		getIndex
	mov 	r1, #1
	bl 		setIndexContent

	pop		{r4-r10, lr}
	mov		pc, lr


.globl checkPowerUp
checkPowerUp:
	push	{r4-r10, lr}

	//get the coordinates of the snake
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
	cmp	r1, #5				//if it is 5, then it hit the power up
	bleq getPowerUp

	pop		{r4-r10, lr}
	mov		pc, lr


getPowerUp:		//do the value pack
	push	{r4-r10, lr}

	ldr 	r1, =500000		//make snake move slower
	ldr 	r2, =snakeSpeed
	str 	r1, [r2]

	pop		{r4-r10, lr}
	mov		pc, lr


.globl powerUpMake
powerUpMake:
	push	{r4-r10, lr}

tryRandom3:
	bl		randomNumber		//get random coordinates, in *32 form
	push 	{r0,r1}				//save coordinate values
	bl 		getColumnAndRow
	bl 		getIndex
	bl 		getIndexContent	
	mov 	r2, r0 				//move to r2
	pop 	{r0,r1}				//restore coordinate values
	cmp 	r2, #0 				//check if it's empty or not
	bne 	tryRandom3
	ldr		r2, =special
	bl 		DrawBox

	bl 		getIndex
	mov 	r1, #5				//5 means powerup
	bl 		setIndexContent

	pop		{r4-r10, lr}
	mov		pc, lr


 .section .data 

 .globl snakeSpeed
 snakeSpeed:
 	.int 	50000


