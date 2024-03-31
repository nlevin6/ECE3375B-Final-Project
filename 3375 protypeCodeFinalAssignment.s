.equ LED_BASE, 0xFF200000 
.equ MPCORE_PRIV_TIMER, 0xFFFEC600
.equ bit_9, 0x00000200
button_addr: .word 0xFF200050 
count: .word 0x00000000  // Variable to store the count

/* This program provides a simple example of code for the ARM A9. The program
* performs the following:
* 1. starts the ARM A9 private timer
* 2. loops forever, toggling the bit 9 red light LEDs when the timer expires
*/
.text
.global _start
_start:
	LDR R0, =LED_BASE 		// LED base address
	LDR R1, =MPCORE_PRIV_TIMER 	// MPCore private timer base address
	LDR R2, =bit_9		 	// value to turn on the bit 9 of red light LEDs 
	STR R2, [R0] 			// write to the LEDs register to turn on bit 9 						
	LDR R3, =200000000 		// timeout = 1/(200 MHz) x 200x10^6 = 1 sec
	STR R3, [R1] 			// write to timer load register
	MOV R3, #0b011 			// set bits: mode = 1 (auto), enable = 1
	STR R3, [R1, #0x8] 
	mov r5,#0// write to timer control register
LOOP:
	STR R2, [R0] 			// turn on/off bit 9 of red LEDs
WAIT:
		
		
	ldr r3, #button_addr  
   	ldr r4, [r3]          

	cmp r4, #0 
    bne pressedButton

	
	LDR R3, [R1, #0xC] 		// read timer status
	CMP R3, #0
	BEQ WAIT 
	//caluclate rpm call fuction
	
	// wait for timer to expire
	STR R3, [R1, #0xC] 		// reset timer flag bit
	EOR R2, R2, #bit_9		// toggle the bit 9 red LEDs value
	b calculateRPM
	


pressedButton:
              // Load the address of count into r2
    ldr r6,=count
	ldr r7, [r6]
	add r7,r7,#1
	STR r7, [r6]    // Store the updated count back to memory
   
	
	loop1:
	ldr r3, #button_addr  
   	ldr r4, [r3]          

	cmp r4, #0 
   
    
	bne loop1
	b WAIT

calculateRPM:
    
ldr r6, =count      // Load the address of count again
ldr r7, [r6]        // Load the original count value

mov r8, #60         // Load divisor 60 into r8
mov r9, #0          // Initialize quotient (result) in r9
mov r10, #0         // Initialize remainder in r10

//delate this when divitor is working
mov r7, #0

str r7, [r6] 
mov r6, #0
b LOOP


DIVIDE_LOOP:
cmp r7, r8          // Compare dividend with divisor
subge r7, r7, r8    // Subtract divisor from dividend if dividend >= divisor
addge r9, r9, #1    // Increment quotient if dividend >= divisor
bge DIVIDE_LOOP     // Repeat loop if dividend >= divisor

mov r6, #0
mov r7, #0
b LOOP              // Branch to the WAIT label






.end


