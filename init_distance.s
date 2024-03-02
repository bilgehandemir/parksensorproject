GPIO_PORTa_DATA EQU 0x400043FC
GPIO_PORTa_DIR EQU 0x40004400
GPIO_PORTa_AFSEL EQU 0x40004420
GPIO_PORTa_PCTL EQU 0x4000452C
GPIO_PORTa_DEN EQU 0x4000451C
GPIO_PORTB_DATA EQU 0x400053FC
GPIO_PORTB_DIR EQU 0x40005400
GPIO_PORTB_AFSEL EQU 0x40005420
GPIO_PORTB_PCTL EQU 0x4000552C
GPIO_PORTB_DEN EQU 0x4000551C
SYSCTL_RCGCGPIO EQU 0x400FE608
SYSCTL_RCGCTIMER EQU 0x400FE604
NVIC_EN0_INT19 EQU 0x00080000 
NVIC_EN0 EQU 0xE000E100 
NVIC_PRI4 EQU 0xE000E410 
TIMER0_CFG EQU 0x40030000
TIMER0_TAMR EQU 0x40030004
TIMER0_CTL EQU 0x4003000C
TIMER0_IMR EQU 0x40030018
TIMER0_RIS EQU 0x4003001C 
TIMER0_ICR EQU 0x40030024 
TIMER0_TAILR EQU 0x40030028 
TIMER0_TAPR EQU 0x40030038
TIMER0_TAR EQU 0x40030048 	
	
				AREA initdist , READONLY, CODE
				THUMB				
				EXPORT	init_distance	
					
;makes a measurement, puts the measured result in R4
init_distance	PROC
				PUSH	{LR}				
				LDR R1 , =SYSCTL_RCGCGPIO	;start clock for port A&B
				LDR R0 , [ R1 ]
				ORR R0 , R0 , #0x3
				STR R0 , [ R1 ]
				NOP
				NOP
				NOP 
				NOP
				LDR R1 , =GPIO_PORTa_DIR 	;pin pa7 is set to output
				LDR R0 , [ R1 ]
				ORR R0 , #0x80				
				STR R0 , [ R1 ]
				LDR R1 , =GPIO_PORTB_DIR 	;pin pb6 is set to input
				LDR R0 , [ R1 ]
				BIC R0 , #0x40				
				STR R0 , [ R1 ]	
				LDR R1 , =GPIO_PORTa_AFSEL	;no alternate function
				LDR R0 , [ R1 ]
				BIC R0 , #0xFF
				STR R0 , [ R1 ]
				LDR R1 , =GPIO_PORTa_PCTL	;no alternate function
				LDR R0 , [ R1 ]
				BIC R0 , #0xFF
				STR R0 , [ R1 ]
				LDR R1 , =GPIO_PORTB_AFSEL	;alternate function on pb6
				LDR R0 , [ R1 ]
				ORR R0 , #0x40
				STR R0 , [ R1 ]
				LDR R1 , =GPIO_PORTB_PCTL	;Set bits 26:24 of PCTL to 7 to enable TIMER0A on Pb6
				LDR R0 , [ R1 ]
				ORR R0 , #0x7000000
				STR R0 , [ R1 ]
				LDR R1 , =GPIO_PORTa_DEN	;pin pa7 is digital
				LDR R0 , [ R1 ]
				ORR R0 , #0x80
				STR R0 , [ R1 ]		
				LDR R1 , =GPIO_PORTB_DEN	;pin pb6 is digital
				LDR R0 , [ R1 ]
				ORR R0 , #0x40
				STR R0 , [ R1 ]					
				LDR R1 , =GPIO_PORTa_DATA 	;pin pa7 is cleared 
				LDR R0 , [ R1 ]
				BIC R0 , #0x80				
				STR R0 , [ R1 ]
				MOV32 R1, #0x82355
loop1			SUBS R1, #0x1
				BNE	loop1
				LDR R1 , =GPIO_PORTa_DATA 	;pin pa7 is set 
				LDR R0 , [ R1 ]
				ORR R0 , #0x80				
				STR R0 , [ R1 ]
				MOV R1, #0x12C
loophigh		SUBS R1, #0x1
				BNE	loophigh
				LDR R1 , =GPIO_PORTa_DATA 	;pin pa7 is cleared 
				LDR R0 , [ R1 ]
				BIC R0 , #0x80				
				STR R0 , [ R1 ]
				MOV R1, #0x3C
looplow			SUBS R1, #0x1
				BNE	looplow
				LDR R1 , =SYSCTL_RCGCTIMER ; Start Timer0 clk
				LDR R2 , [ R1 ]
				ORR R2 , R2 , #0x01
				STR R2 , [ R1 ]
				NOP 
				NOP
				NOP
				NOP
				LDR R1 , =TIMER0_CTL ; d i s a b l e tim e r du rin g se tup 
				LDR R2 , [ R1 ]
				BIC R2 , R2 , #0x01
				STR R2 , [ R1 ]
				LDR R1 , =TIMER0_CFG ; s e t 16 b i t mode
				MOV R2 , #0x04
				STR R2 , [ R1 ]
				LDR R1 , =TIMER0_TAMR
				MOV R2 , #0x17 ; set to Edge-time
				STR R2 , [ R1 ]
				LDR R1 , =TIMER0_CTL ; Set timer to detect both edges
				LDR R2 , [ R1 ]
				ORR R2 , R2 , #0x0C
				STR R2 , [ R1 ]
				LDR R1, =TIMER0_TAILR ; count-down is selected in _TAMR, so the starting value is the maximum value
				MOV R0, #0xFFFFFFFF 
				STR R0, [R1]
				LDR R1 , =TIMER0_CTL ;enable timer back again
				LDR R2 , [ R1 ]
				ORR R2 , R2 , #0x03 
				STR R2 , [ R1 ] 
			
signallow		LDR		R1,=GPIO_PORTB_DATA	;ensure that the polling starts when the signal is low
				LDR		R0,[R1]
				CMP		R0,#0
				BNE		signallow
			
polling1		LDR 	R1, =TIMER0_RIS  ;check if there is an edge
				LDR 	R2, [R1]
				ANDS 	R2, #0x04 ; if CAERIS bit is 0, no edge => keep polling
				BEQ 	polling1
				LDR 	R0,=TIMER0_ICR ; clear interrupt register
				LDR 	R1,[R0]
				ORR 	R1,R1,#0x04
				STR 	R1,[R0]					
				LDR 	R1, =TIMER0_TAR
				LDR 	R3, [R1]		  ;time when first edge is occured is stored in R3
polling2		LDR 	R1, =TIMER0_RIS  ;check if there is an edge
				LDR 	R2, [R1]
				ANDS 	R2, #0x04 ; if CAERIS bit is 0, no edge => keep polling
				BEQ 	polling2
				LDR 	R0,=TIMER0_ICR ; clear interrupt register
				LDR 	R1,[R0]
				ORR 	R1,R1,#0x04
				STR 	R1,[R0]	
				LDR 	R1, =TIMER0_TAR
				LDR 	R4, [R1]		  ;time when second edge is occured is stored in R4
				;SUB 	R0, R4, R3
				MOV		R1,#6
				UDIV	R4,R1	
				POP	{LR}
				BX	LR
				ENDP