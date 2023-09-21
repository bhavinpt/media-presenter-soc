;------------------------------------------------------------------------------------------------------
; Design and Implementation of an AHB VGA Peripheral
; 1)Display text string: "TEST" on VGA. 
; 2)Change the color of the four corners of the image region.
;------------------------------------------------------------------------------------------------------

; Vector Table Mapped to Address 0 at Reset

						PRESERVE8
                		THUMB

        				AREA	RESET, DATA, READONLY	  			; First 32 WORDS is VECTOR TABLE
        				EXPORT 	__Vectors
					
__Vectors		    	DCD		0x00003FFC
        				DCD		Reset_Handler
        				DCD		0  			
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD 	0
        				DCD		0
        				DCD		0
        				DCD 	0
        				DCD		0
        				
        				; External Interrupts
						        				
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
              
                AREA |.text|, CODE, READONLY
;Reset Handler
Reset_Handler   PROC
                GLOBAL Reset_Handler
                ENTRY



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   IMAGE  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

				LDR 	R2, =0x51000000		; data-mem-base (constant) MEMORY MAP --> 0x5100_0000 to 0x51FF_FFFF  16MB

showstart
				LDR 	R0, =0x50000000		; vga-text-base (constant)  MEMORY MAP --> 0x5000_0000
				LDR 	R1, =0x50000004		; vga-image-base (constant) MEMORY MAP --> 0x5000_0004 to 0x50FF_FFFF

				; read header byte [R3]
				LDR 	R3, [R2] 		
												
				; extract image/text indication (from MSB of header) [R5]
				; 0 = image  1 = text
				LSRS 	R5, R3, #31 			
					
				; determine hasMore [R4]
				LSRS 	R4, R3, #30
				MOVS	R7, #1
				ANDS	R4, R4, R7
				
				; determine address of last char/pixel from offset field(bit[29:0] of header) [R6]
				; offset is in #of chars/pixels, each chars/pixel occupy one word
				LDR 	R6, =0x3fffffff			; bitmask for offset
				ANDS 	R6, R3, R6				; offset in #of words

				
				; do looptxt or loopimg based on image/text indication
				CMP		R5, #0
				BEQ		showimg				; jump for image input


showtxt			
				ADDS 	R2, R2, #4			; data-mem-base++
				LDR		R3, [R2] 			; load byte from data-mem-base
				
				STR 	R3, [R0]			; put byte to vga-text-base
				
				SUBS	R6, #1
				CMP 	R6, #0   			; check if data-mem-base reached end address
				BNE 	showtxt
				
				;BL		DELAY_LOOP		; debug

				ADDS 	R2, R2, #4			; data-mem-base++ for next element
				CMP		R4, #0				; end if no more left
				BEQ		showend
				B		showstart


; 0x0004 to 0x190(active) 0x194 to 0x200(blanking)
; 0x0204 to 0x390(active) 0x394 to 0x400(blanking)
; 0x0404 to 0x590(active) 0x594 to 0x600(blanking)
; ...
showimg
				BL		SHOW_LINE
				BL		SHOW_BLANKING
				
				CMP 	R6, #0   			; check if data-mem-base reached end address
				BGE		showimg	
								
				;BL		DELAY_LOOP
				
				ADDS 	R2, R2, #4			; data-mem-base++ for next element
				CMP		R4, #0				; end if no more left
				BEQ		showend      
				B		showstart

				ENDP
					
					
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Shows one line of the image and returns. 
; Each line has 100 pixels (0x190/4 = 100)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				
SHOW_LINE		PROC
				PUSH	{R3, R4, LR}
				LDR 	R4, =0x190			; num of pixels in line actual #pixels = 0x190 / 4
nextpixel	
				; show the next pixel
				ADDS 	R2, R2, #4			; data-mem-base++	
				LDR		R3, [R2] 			; load pixel from data-mem-base
				STR		R3, [R1]			; put pixel to vga-image-base			
				ADDS 	R1, R1, #4			; vga-image-base++	
				
				; return if all pixels in image displayed
				SUBS	R6, R6, #1			
				CMP 	R6, #0   	
				BEQ		nomorepixels	
				
				; return when all the pixels in line displayed
				SUBS	R4, R4, #4			
				CMP 	R4, #0
				BGT		nextpixel
nomorepixels
				POP		{R3, R4, PC}
				ENDP
					
					

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Shows the blanking pixels after each line and returns. 
; Each line has 28 blanking pixels (0x70/4 = 28)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
SHOW_BLANKING	PROC
				PUSH	{R3, R4, LR}
				LDR 	R3, =0x70			; num of pixels in blanking (0x200 - 0x190)
nextblankingpixel		
				; skip blanking pixel
				ADDS 	R1, R1, #4			; vga-image-base++	
				
				; return when all blanking pixels are done
				SUBS	R3, R3, #4		
				CMP 	R3, #0
				BNE		nextblankingpixel

				POP		{R3, R4, PC}
				ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; To generate delay between two frames of a video
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELAY_LOOP		PROC
				PUSH	{R3, LR}
				LDR		R3, =0x132DCD5		;(33.333333 ms)/(10ns) = 0x32DCD5
dloop
				SUBS 	R3, R3, #1   
				CMP 	R3, #0
				BNE 	dloop     		
				POP		{R3, PC}
				ENDP

showend

			
				ALIGN 		4					 ; Align to a word boundary

		END                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
   