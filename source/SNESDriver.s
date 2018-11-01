.section    .init
.globl     _start

top:

    b      begin
    
.section .text

begin:
    mov     sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG // Enable JTAG
	//bl		InitUART    // Initialize the UART

	
// You can use WriteStringUART and ReadLineUART functions here after the UART initializtion.

/*	ldr	r0, =creator    //Printing creator string
	mov	r1, #50
	bl	WriteStringUART //Write string to screen
*/

.global start
start:
	/*ldr	r0, =button_press  	///Printing "Plese press button..."
	mov	r1, #22
	bl	WriteStringUART    	//Write string to screen
*/


	// initalizing GPIO pin 9
	mov	r0, #0  		//r0 = address of GPFSEL0
	mov r1, #1 			// r1 = input function code
	mov r2, #27 		// r2 =  will have the # of shifts 
	bl 	init_GPIO
	
	// initalizing GPIO pin 10
	mov	r0, #4  			//r0 = address of GPFSEL1
	mov r1, #0 				// r1 = output function code
	mov r2, #0 				// r2 =  will have the # of shifts 
	bl 	init_GPIO

	// initalizing GPIO pin 11
	mov	r0, #4  			//r0 = address of GPFSEL1
	mov r1, #1 				// r1 = input function code
	mov r2, #3 				// r2 =  will have the # of shifts 
	bl 	init_GPIO

	delay: 					//waiting for user input for 200000 micro seconds
		ldr r8, =200000
		mov r2, r8  		//r2 is argument to wait
		bl wait 			//wait

	read_next:
	bl  read_SNES 			//read button
	//bl 	print_Message 		//go to print message
	cmp r0, #1 				// check if there is input from user 
	bne start 				// if there was an input, go back to start 
	b   read_next  			//Read next button
	

	


	// initalizing GPIO
.global init_GPIO 
	init_GPIO:
		PUSH {r4-r10}			//Preserve registers r4 -r10
		
		mov r4, r0 				// r4 = address shift 
		mov r5, r1 				// r5 = function code 
		mov r6, r2 				// r6 = number of shifts 
		cmp r4, #0 				//check if shift is needed
		beq add0  				//if not, use base address
		ldr r0, =0x20200004 	//otherwise, shift
		b 	continueInit

	add0:
		ldr r0, =0x20200000
		
	continueInit:
		ldr r1, [r0] 			 
		mov r2, #7				//to clear bits 
		lsl r2, r6 				// subroutine: r7 will have the # of shifts 
		bic r1, r2 				// clear appropriate bits 
		lsl r5, r6	 			// shifting the bits 
		orr	r1, r5 				// setting function in r1 
		str r1, [r0] 			// wriring back to GPFSEL 
		POP	{r4 - r10} 			// popping back values 
		mov pc, lr  			// return subroutine 

.global wait
	wait:
		PUSH {lr}
		ldr	r0, =0x20003004		//clock address
		ldr r1, [r0] 			//read clock
		add r1, r2				//r2 = how long to wait
		waitLoop:
			ldr	r3, [r0]         // loading into r3 
			cmp	r1, r3			//stop when clock = r1
			bhi	waitLoop 		// waiting 
			POP {lr}
			mov pc, lr 

.global write_Latch
	write_Latch:
		//value to write in r1

		mov	r0, #9				//pin 9 align bit
	 	ldr	r2, =0x20200000 	//base address
		mov	r3, #1 			
		lsl	r3, r0
		teq	r1, #0
		streq r3, [r2, #40] 	// GPCLR0
		strne r3, [r2, #28] 	// GPSET0
		mov	  pc,lr

.global write_Clock
	write_Clock:

		//value to write in r1

		mov	r0, #11				//pin 10 align bit
		ldr	r2, =0x20200000
		mov	r3, #1
		lsl	r3, r0
		teq	r1, #0
		streq r3, [r2, #40] 	// GPCLR0
		strne r3, [r2, #28] 	// GPSET0

		mov	  pc,lr

.global read_Data
	read_Data:
		PUSH {lr}
		mov	r0, #10 			//DATA line
		ldr r2, =0x20200000 	// base GPIO reg
		ldr r1, [r2, #52] 		// GPLEV0
		mov r3, #1
		lsl r3, r0 				// align pin10 bit
		and r1, r3 				// mask everything else
		teq r1, #0
		moveq r2, #0 			//info/ return 0
		movne r2, #1 			// return 1 
		POP {lr}
		mov pc, lr 

.global read_SNES
	read_SNES:
		PUSH {r4-r10, lr} 		//Preserve registers r4 -r10, and link register

		mov r5, #0 				//r5 = buttons register
		mov r1, #1
		bl 	write_Clock 		//write 1 to clock
		bl 	write_Latch 		//write 1 to latch
		mov r2, #12 			
		bl 	wait 				//wait 12 microseconds
		mov r1, #0
		bl 	write_Latch 		//write 0 to latch 	
		mov r7, #0			

		
		pulseLoop:
	
			mov r2, #6 			//wait 6 microseconds
			bl  wait  			
			mov r1, #0 			// set clock low 
			bl  write_Clock 	
			mov r2, #6 			// wait 6 microseconds
			bl  wait 
			bl  read_Data 		// read Data 
	
			mov r4, #1 			// moving and shifting '1' to appropriate index 
			lsl r4, r7

			cmp r2, #1 			
			bne doNothing 	 	// if button was pressed, we do not 'or'
			orr r5, r4 
		

		doNothing:
			mov r1, #1
			bl 	write_Clock 	//set clock to high
			add r7, #1 			//increment counter   
			cmp r7, #16  		//limit for counter
			blt pulseLoop 		//if it's less than 16, go to pulse loop 	
		
		 
			mov r0, r5  		// moving r5 into r0 to pass as an argument later 
			mov r1, r7  		// moving r7 into r1 to pass as an argument later 
			POP {r4-r10, lr}
			mov pc, lr

				

haltLoop$:
	b	haltLoop$

.section .data  
//Strings to print	
	creator: 		.asciz "Created by: Chintav Shah and Edrienne Manalastas\n\r"
	
	button_press: 	.asciz "Press any button... \n\r"

	pressed_B:		.asciz "You have pressed B\n\r"

	pressed_Y:		.asciz "You have pressed Y\n\r"

	pressed_Select:	.asciz "You have pressed Select\n\r"

	pressed_Start:	.asciz "You have pressed Start\n\r"

	pressed_Up:		.asciz "You have pressed Joy-pad UP\n\r"

	pressed_Down:	.asciz "You have pressed Joy-pad DOWN\n\r"

	pressed_Left:	.asciz "You have pressed Joy-pad LEFT\n\r"

	pressed_Right:	.asciz "You have pressed Joy-pad RIGHT\n\r"

	pressed_A:		.asciz "You have pressed A\n\r"

	pressed_X:		.asciz "You have pressed X\n\r"

	pressed_L:		.asciz "You have pressed L\n\r"

	pressed_R:		.asciz "You have pressed R\n\r"

	termination: 	.asciz "Program is terminating...\n\r"