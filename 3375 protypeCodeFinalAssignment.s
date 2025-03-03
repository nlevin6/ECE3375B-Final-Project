.equ LED_BASE, 0xFF200000 
.equ MPCORE_PRIV_TIMER, 0xFFFEC600
.equ bit_9, 0x00000200
button_addr: .word 0xFF200050 
count: .word 0x00000000  // Variable to store the count
HEX3_HEX0_BASE:	.word	0xFF200020
SW_BASE:        .word   0xFF200040
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
		
	// see if any button is pressed
	ldr r3, #button_addr  
   	ldr r4, [r3]          
	cmp r4, #0 
	bne pressedButton

	
	LDR R3, [R1, #0xC] 		// read timer status
	CMP R3, #0
	BEQ WAIT 
	//caluclate rpm call fuction
	
	// wait for 1 second timer to expire
	STR R3, [R1, #0xC] 		// reset timer flag bit
	EOR R2, R2, #bit_9		// toggle the bit 9 red LEDs value
	b calculateRPM
	


pressedButton:
	// check to see if the button isn't just simulating the bike peddle
	 cmp r4, #1 
     bne setBikeRPM  
	 
    ldr r6,=count
	ldr r7, [r6]
	add r7,r7,#1
	STR r7, [r6]    // Store the updated count back to memory
   
	
	//wait for button to be unpressed
	loop1:
	
	ldr r3, #button_addr  
   	ldr r4, [r3]          
 	cmp r4, #0 
	bne loop1
	
	b WAIT
	
	//controlls for setting the bike speed
	//button 1 increase speed
	//button 2 decreaes speed
	//button 3 brakes (set speed to 0)
setBikeRPM:
	ldr r3, #button_addr  
   	ldr r4, [r3]      
	
	cmp r4, #2
	addeq r5,r5, #0x100
	
	cmp r4, #4
	subeq r5,r5, #0x100
	
  	cmp r5, #0
	movlt r5, #0
	
	cmp r4, #8
	moveq r5, #0x00000000
  
  b loop1




//calculate the rpm of the bike pulse by taking multiple the count by 3600
//as we have counts per second then 
calculateRPM:   
ldr r6, =count      // Load the address of count again
ldr r7, [r6]        // Load the original count value

mov r9, #3600       // Load 3600 into r8
mul r12, r7, r9      // Multiply the value in r7 by 3600 and store the result in r9

mov r7, #0          // Set count to zero

str r7, [r6]   
mov r6, #0

//display all the rpm to the seven segment display
displayRPM:
//reset values for adding
mov r10,#0x00000000
mov r11,#0x00000000


//calulate motor speed
sub r8, r5, r12
cmp r8, #0
//sets value to 0 if left then 0
movlt r8, #0


 

//first hext bit
ldr R9, #SW_BASE       // Load the base address of the switches
ldr R10, [R9]          // Load the current state of the switches
cmp R10, #1       
ANDEQ   R9, R5, #0x0000000F  
cmp R10, #2       
ANDEQ   R9, R8, #0x0000000F 
cmp R10, #4       
ANDEQ   R9, R12,#0x0000000F  

cmp r9, #0
moveq r10, #0x3F
cmp r9, #1
moveq r10, #0x06
cmp r9, #2
moveq r10, #0x5B
cmp r9, #3
moveq r10, #0x4F
cmp r9, #4
moveq r10, #0x66
cmp r9, #5
moveq r10, #0x6D
cmp r9, #6
moveq r10, #0x7D
cmp r9, #7
moveq r10, #0x07
cmp r9, #8
moveq r10, #0x7F
cmp r9, #9
moveq r10, #0x6F
cmp r9, #0xA
moveq r10, #0xF7
cmp r9, #0xB
moveq r10, #0xFC
cmp r9, #0xC
moveq r10, #0xB9
cmp r9, #0xD
moveq r10, #0xDE
cmp r9, #0xE
moveq r10, #0xF9
cmp r9, #0xF
moveq r10, #0xF1

add r11,r10,r11

//second hex bit
//AND   R9, R12, #0x000000F0  
ldr R9, #SW_BASE       // Load the base address of the switches
ldr R10, [R9]  
cmp R10, #1       
ANDEQ   R9, R5, #0x000000F0  
cmp R10, #2       
ANDEQ   R9, R8, #0x000000F0 
cmp R10, #4       
ANDEQ   R9, R12, #0x000000F0 



lsr r9,#4

cmp r9, #0
moveq r10, #0x3F
cmp r9, #1
moveq r10, #0x06
cmp r9, #2
moveq r10, #0x5B
cmp r9, #3
moveq r10, #0x4F
cmp r9, #4
moveq r10, #0x66
cmp r9, #5
moveq r10, #0x6D
cmp r9, #6
moveq r10, #0x7D
cmp r9, #7
moveq r10, #0x07
cmp r9, #8
moveq r10, #0x7F
cmp r9, #9
moveq r10, #0x6F
cmp r9, #0xA
moveq r10, #0xF7
cmp r9, #0xB
moveq r10, #0xFC
cmp r9, #0xC
moveq r10, #0xB9
cmp r9, #0xD
moveq r10, #0xDE
cmp r9, #0xE
moveq r10, #0xF9
cmp r9, #0xF
moveq r10, #0xF1

lsl r10 ,#8
add r11,r10,r11

//third hex bit
//AND   R9, R12, #0x00000F00  

ldr R9, #SW_BASE       // Load the base address of the switches
ldr R10, [R9]  
cmp R10, #1       
ANDEQ   R9, R5, #0x00000F00  
cmp R10, #2       
ANDEQ   R9, R8, #0x00000F00 
cmp R10, #4       
ANDEQ   R9, R12, #0x00000F00 


lsr r9,#8

cmp r9, #0
moveq r10, #0x3F
cmp r9, #1
moveq r10, #0x06
cmp r9, #2
moveq r10, #0x5B
cmp r9, #3
moveq r10, #0x4F
cmp r9, #4
moveq r10, #0x66
cmp r9, #5
moveq r10, #0x6D
cmp r9, #6
moveq r10, #0x7D
cmp r9, #7
moveq r10, #0x07
cmp r9, #8
moveq r10, #0x7F
cmp r9, #9
moveq r10, #0x6F
cmp r9, #0xA
moveq r10, #0xF7
cmp r9, #0xB
moveq r10, #0xFC
cmp r9, #0xC
moveq r10, #0xB9
cmp r9, #0xD
moveq r10, #0xDE
cmp r9, #0xE
moveq r10, #0xF9
cmp r9, #0xF
moveq r10, #0xF1

lsl r10 ,#16
add r11,r10,r11

//fourth hex bit
ldr R9, #SW_BASE       // Load the base address of the switches
ldr R10, [R9]  
cmp R10, #1       
ANDEQ   R9, R5, #0x0000F000  
cmp R10, #2       
ANDEQ   R9, R8, #0x0000F000 
cmp R10, #4       
ANDEQ   R9, R12,#0x0000F000 


lsr r9,#12

cmp r9, #0
moveq r10, #0x3F
cmp r9, #1
moveq r10, #0x06
cmp r9, #2
moveq r10, #0x5B
cmp r9, #3
moveq r10, #0x4F
cmp r9, #4
moveq r10, #0x66
cmp r9, #5
moveq r10, #0x6D
cmp r9, #6
moveq r10, #0x7D
cmp r9, #7
moveq r10, #0x07
cmp r9, #8
moveq r10, #0x7F
cmp r9, #9
moveq r10, #0x6F
cmp r9, #0xA
moveq r10, #0xF7
cmp r9, #0xB
moveq r10, #0xFC
cmp r9, #0xC
moveq r10, #0xB9
cmp r9, #0xD
moveq r10, #0xDE
cmp r9, #0xE
moveq r10, #0xF9
cmp r9, #0xF
moveq r10, #0xF1

lsl r10 ,#24
add r11,r10,r11

ldr r9, HEX3_HEX0_BASE
str r11, [r9]

b LOOP





.end
