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



; This file is the configuration of Analog Comparator 1, 
; which utilizes an analog input (PC4), an internal compare
; value (about 1v), and a digital output (PF1).






       THUMB
       AREA    DATA, ALIGN=2
       ALIGN          
       AREA    |.text|, CODE, READONLY, ALIGN=2
       EXPORT  Start 
	   AREA main, CODE,READONLY
RCGC0				DCD 0x400FE100		  
RCGCACMP 			DCD	0x400FE63C
RCGCGPIO 			DCD 0x400FE108
GPIO_UNLOCK_CODE	DCD 0x4C4F434B

GPIOC_UNLOCK		DCD 0x40006520
GPIOC_DIR			DCD 0x40006400
GPIOC_PCTL			DCD 0x4000652C
GPIOC_AFSEL			DCD 0x40006420
GPIOC_PINS			DCD 0x10; represents C4	
GPIOC_DEN			DCD 0x4000651C
GPIOC_AMSEL			DCD 0x40006528
GPIOF_AFSEL			DCD 0x40006420

GPIOF_UNLOCK		DCD 0x40025520
GPIOF_DIR			DCD 0x40025400
GPIOF_PCTL			DCD 0x4002552C
GPIOF_PINS			DCD 0x2 ; represents F1
GPIOF_WRITE			DCD 0x400253FC
GPIOF_DEN			DCD 0x4002551C
GPIOF_CR			DCD 0x40025524
GPIOF_DATA			DCD 0x400253FC
	
GPIOF1_C1o 			DCD 0x0090 ; pin F1 to analog comp 1 output

ACMPPP				DCD 0x4003CFC0
ACREFCTL			DCD 0x4003C010
ACCTL1				DCD 0x4003C044
ACSTAT1				DCD 0x4003C040
ACCTL0				DCD 0x4003C024
ACSTAT0				DCD 0x4003C020
ACCTL1_CONFIG		DCD 0x0482 ;11:toen. 10-9:asrcp. 7:tslval.
					;6-5:tsen. 4:islval. 3-2:isen. 1:cinv
					;0b0000.0100.1000.0010
ACREFCTL_CONFIG		DCD 0x0307 ; p9:en. p8:rng. p3-0:vref

	   ALIGN
	   ENTRY
Start  
	bl gpio_initialization
	bl comparator_initialization
	ldr R0, ACSTAT1
	ldr R1, GPIOF_DATA
loop 
	ldr R2, [R0]
	str R2, [R1]
	b loop 


gpio_initialization
	;0 enable analog comparator clock. 
	mov R1, #0x1
	ldr R0, RCGCACMP
	str R1, [R0]
	
	;1 enable port clock
	mov R1, #0x24 ; 0b0010.0100 ports c,f
	ldr R0, RCGCGPIO
	str R1, [R0]

	;1b unlock ports
	ldr R1, GPIO_UNLOCK_CODE 
	ldr R0, GPIOF_UNLOCK
	str R1, [R0]
	ldr R0, GPIOC_UNLOCK
	str R1, [R0]
	;2 make pin C4 an input by writing 0 to dir reg
	mov R1, #0x0
	ldr R0, GPIOC_DIR
	str R1, [R0]; C pins are input

	ldr R1, GPIOF_PINS ;make pin F1 an output. 
	ldr R0, GPIOF_DIR ; 
	str R1, [R0]
	
	; configure the PMCn fields in the GPIOPCTL reg for output.
	; pc4 is analog function. 

gpioC_config
	;3 enable the alternative function on AFSEL reg
	ldr R1, GPIOC_PINS ;
	ldr R0, GPIOC_AFSEL
	str R1, [R0]

	;4 disable digital function of the pin
	mov R1, #0x0
	ldr R0, GPIOC_DEN
	str R1, [R0]

	;5 enable analog function by AMSEL register
	ldr R1, GPIOC_PINS 
	ldr R0, GPIOC_AMSEL
	str R1, [R0]

gpioF_config
	;disable digital function of the pin
	mov R1, #0x0
	ldr R0, GPIOF_DEN
	str R1, [R0]
	
	; The alternate functionality of pin did not function as expected. 
	; I am using polling to update the output of the item. 
	; The following commented lines of code should configure PF1 to be
	; 	the analog comparator output.  
;	ldr R1, GPIOF_PINS ;
;	ldr R0, GPIOF_AFSEL
;	str R1, [R0]

;	ldr R1, GPIOF1_C1o
;	ldr R0, GPIOF_PCTL
;	str R1, [R0] 

;disable digital function of the pin
	ldr R1, GPIOF_PINS
	ldr R0, GPIOF_DEN
	str R1, [R0]
			
	bx lr

comparator_initialization
	; configure internal voltage reference with ACREFCTL register
	ldr R1, ACREFCTL_CONFIG
	ldr R0, ACREFCTL
	str R1, [R0]

	; configure ACCTL1 register. 
	ldr R1, ACCTL1_CONFIG
	ldr R0, ACCTL1
	str R1, [R0]
	
	bx lr ; return 

       ALIGN      
       END  
 	