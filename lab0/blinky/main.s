; main.s
; Runs on any Cortex M processor
; A very simple first project implementing a random number generator
; Daniel Valvano
; May 4, 2012

;  This example accompanies the book
;  "Embedded Systems: Introduction to Arm Cortex M Microcontrollers",
;  ISBN: 978-1469998749, Jonathan Valvano, copyright (c) 2012
;  Section 3.3.10, Program 3.12
;
;Copyright 2012 by Jonathan W. Valvano, valvano@mail.utexas.edu
;   You may use, edit, run or distribute this file
;   as long as the above copyright notice remains
;THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
;OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
;MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
;VALVANO SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL,
;OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
;For more information about my classes, my research, and my books, see
;http://users.ece.utexas.edu/~valvano/


       THUMB
       AREA    DATA, ALIGN=2
       ALIGN          
       AREA    |.text|, CODE, READONLY, ALIGN=2
       EXPORT  Start
	   ;unlock 0x4C4F434B
	   
	   ;PF4 is SW1
	   ;PF0 is SW2
	   ;PF1 is RGB Red
	   ;Enable Clock RCGCGPIO p338
	   ;Set direction 1 is out 0 is in. GPIODIR
	   ;DEN 
	   ; 0x3FC
	   
	   
Start  
	mov32 R0, #0x400FE108 ; Enable GPIO Clock
	mov R1, #0x20
	str R1, [R0]
	
	mov32 R0, #0x40025000
	mov32 R1, #0x4C4F434B
	str R1, [R0,#0x520];GPIO unlock
	mov R1, #0x1F
	str R1, [R0,#0x524];GPIOCR
	mov R1, #0x11
	str R1, [R0,#0x510]
	mov R1, #0x0E
	str R1, [R0,#0x400] ;GPIODIR
	mov R1, #0x1F
	str R1, [R0,#0x51C] ;digital enable

	; R0 gpioF
	; R1 on
	; R2 off
	; R3 
loop
	ldr R1, [R0,#0x3FC]
	and R1, #0x11
	cmp R1, #0x11
	 beq loop
	
	cmp R1, #0x00
	 beq loop
	
	cmp R1, #0x01
	it eq
	 bleq sw1
	 blne sw2

	b loop
	
sw1
	push{lr}
wait
	bl delay
	ldr R1,[R0,#0x3FC]
	and R1, #0x01
	cmp R1, #0x01
	beq wait
	
	mov R2, #0x2
	mov R3, #0x0
	str R3, [R0,#0x08]
	bl delay
	str R2, [R0,#0x08]
	bl delay
	str R3, [R0,#0x08]
	bl delay
	str R2, [R0,#0x08]
	bl delay
	str R3, [R0,#0x08]
	bl delay
	str R2, [R0,#0x08]
	
	pop{lr}
	bx lr
	
sw2
	push{lr}
wait1
	bl delay
	ldr R1,[R0,#0x3FC]
	and R1, #0x10
	cmp R1, #0x10
	beq wait1
	
	mov R2, #0x2
	mov R3, #0x0
	str R3, [R0,#0x08]
	bl delay
	str R2, [R0,#0x08]
	bl delay
	str R3, [R0,#0x08]
	bl delay
	bl delay
	str R2, [R0,#0x08]
	bl delay
	str R3, [R0,#0x08]
	pop{lr}
	bx lr
	
delay 
	mov R5, #0x0
	mov32 R6, #0xFFFF
	mov32 R7, #0x0
delay_loop
	add R5, #0x1
	cmp R5, R6
	bne delay_loop
	bx lr

       B   Start

       ALIGN      
       END  
           