GPIO_PORTA_DATA EQU 0x400043FC
GPIO_PORTA_DIR EQU 0x40004400
GPIO_PORTA_AFSEL EQU 0x40004420
GPIO_PORTA_PCTL EQU 0x4000452C
GPIO_PORTA_DEN EQU 0x4000451C
	
	
				AREA lcd , READONLY, CODE
				THUMB				
				EXPORT	init_lcd				

init_lcd		PROC
				PUSH	{LR}
				LDR R1 , =SYSCTL_RCGCGPIO	;start clock for port A
				LDR R0 , [ R1 ]
				ORR R0 , R0 , #0x1
				STR R0 , [ R1 ]
				NOP
				NOP
				NOP 
				NOP
				LDR R1 , =GPIO_PORTA_DEN	;pins are digital
				LDR R0 , [ R1 ]
				ORR R0 , #0x3C
				STR R0 , [ R1 ]
				LDR R1 , =GPIO_PORTA_DIR 	;pins pa2, pa3, pa5 are set to output
				LDR R0 , [ R1 ]
				ORR R0 , #0x2C				
				STR R0 , [ R1 ]				
				LDR R1 , =GPIO_PORTA_AFSEL	;alternate function
				LDR R0 , [ R1 ]
				BIC R0 , #0x3C
				STR R0 , [ R1 ]				
				LDR R1 , =GPIO_PORTA_PCTL	;alternate function 2 for bytes 2, 3, 4 and 5
				LDR R0 , [ R1 ]
				BIC R0 , #0x222200
				STR R0 , [ R1 ]
				LDR R1 , =RCGCSSI	;start clock for SSI0
				LDR R0 , [ R1 ]
				ORR R0 , R0 , #0x1
				STR R0 , [ R1 ]
				NOP
				NOP
				NOP 
				NOP 
pollprssi		LDR R1 , =PRSSI	;check if the module is ready
				LDR R0 , [ R1 ]
				CMP	R0, #0x1
				BNE	pollprssi
				LDR R1 , =SSICR1	;disable the SPI interface
				LDR R0 , [ R1 ]
				BIC R0 , R0 , #0x2
				STR R0 , [ R1 ]	
				LDR R1 , =SSICPSR	;cpsrdvsr = 6
				LDR R0 , [ R1 ]
				MOV	R0 , #0x6
				STR R0 , [ R1 ]
				LDR R1 , =SSICR0	;scr = 3, data size = 8 bits
				LDR R0 , [ R1 ]
				MOV R0 , #0x307
				STR R0 , [ R1 ]
				LDR R1 , =SSICR1	;enable the SPI interface
				LDR R0 , [ R1 ]
				ORR R0 , R0 , #0x2
				STR R0 , [ R1 ]	
				
				
				
				
				
				
				
				
				POP		{LR}
				BX LR
				ENDP