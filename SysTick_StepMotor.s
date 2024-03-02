NVIC_ST_CTRL EQU 0xE000E010
NVIC_ST_RELOAD EQU 0xE000E014
NVIC_ST_CURRENT EQU 0xE000E018
SHP_SYSPRI3 EQU 0xE000ED20
GPIO_PORTB_DATA EQU 0x400053FC

; 0x7D0 = 2000 -> 2000*250 ns = 500mus 7a120
RELOAD_VALUE EQU 0x8000

				AREA initisr , CODE, READONLY, ALIGN=2
				THUMB
				EXPORT initsystickstep
initsystickstep PROC
				PUSH {LR}
				LDR R1 , =NVIC_ST_CTRL	;disable first
				MOV R0 , #0
				STR R0 , [ R1 ]
				LDR R1 , =NVIC_ST_RELOAD	;set period
				LDR R0 , =RELOAD_VALUE
				STR R0 , [ R1 ]
				LDR R1 , =NVIC_ST_CURRENT	;current value is set to reload value
				STR R0 , [ R1 ]
				LDR R1 , =NVIC_ST_CTRL		;enable systick 
				MOV R0 , #0x3
				STR R0 , [ R1 ]
;checksystick	LDR R1 , =NVIC_ST_CTRL		;check if ended
;				LDR R0 , [R1]
;				CMP R0, #0x10001
;				BNE checksystick
;				LDR R1 , =NVIC_ST_CTRL	;disable
;				MOV R0 , #0
;				STR R0 , [ R1 ]	
				POP {LR}
				BX LR
				ENDP
					
				EXPORT My_ST_ISR
My_ST_ISR 		PROC
				LDR R1 , =GPIO_PORTB_DATA	;if first pin high				
				LDR R0 , [ R1 ]				
				CMP R0 , #0x10
				MOVEQ R0, #0x80
				STR R0 , [ R1 ]
				BEQ isrend
				LDR R1 , =GPIO_PORTB_DATA	;if second pin high
				LDR R0 , [ R1 ]
				CMP R0 , #0x80
				MOVEQ R0, #0x1
				STR R0 , [ R1 ]
				BEQ isrend
				LDR R1 , =GPIO_PORTB_DATA	;if third pin high
				LDR R0 , [ R1 ]
				CMP R0 , #0x1
				MOVEQ R0, #0x20
				STR R0 , [ R1 ]
				BEQ isrend
				LDR R1 , =GPIO_PORTB_DATA	;if fourth pin high
				LDR R0 , [ R1 ]
				CMP R0 , #0x20
				MOVEQ R0, #0x10
				STR R0 , [ R1 ]
				BEQ isrend
isrend			NOP				
				BX LR 
				ENDP

