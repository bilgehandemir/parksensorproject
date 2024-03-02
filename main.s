		
			AREA main, CODE, READONLY
			THUMB	
			EXPORT __main
			EXTERN 	normal_mode
				
__main		PROC
			BL normal_mode
			CPSIE I
loop		B	loop
			ENDP