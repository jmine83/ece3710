            	AREA	main, CODE, READONLY, ALIGN=2
            	THUMB
            	EXPORT Start


message     	DCB     "Hello Students!",0     	; message stored readonly
 
            	ALIGN ;pg149
Start       	LDR 	R0, =message            	; load address of the message
            	
            	MOV 	R1, SP		            	; load memory location to store
				SUB		R1, #19						; offset memory location to store
				MOV 	R3, #4 				       	; used as a counter
           	
load        	LDR 	R2,[R0]                 	; load a word of the message
            	STR 	R2,[R1]						; store the word to memory
				ADD 	R0, R0, #4					; adds 4 to the src addr reg
				ADD		R1, R1, #4					; adds 4 to the dst addr reg

				SUB 	R3, R3, #1              	; decrements counter
				CMP 	R3, #0						; check for null
            	BNE 	load                    	; repeat if not null terminated
            	
loop        	B   	loop
 
            	ALIGN
            	END