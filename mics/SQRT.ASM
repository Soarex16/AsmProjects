INCLUDE IO.ASM

.MODEL SMALL

.STACK 128

.DATA
	N			DW	0

	_str_n		DB	'NUMBER = ', '$'
	_str_neg	DB	'ERROR! NUMBER MUST BE NOT NEGATIVE...', '$'
	_str_res	DB	'SQRT(N) = ', '$'

	.CODE	
main PROC
	; STARTUP
	PUSH	AX
	PUSH	DS	

	MOV		AX, @data
	MOV		DS, AX
	
	;=======CODE=======
	
	; DON'T WORKS WITH 32761 = 181^2 < 32765 (MAX SIGNED WORD)
	; WHY ? (MAYBE OVERFLOW ???)

	MOV 	AH, 09h			; PRINT 'NUMBER = '
	LEA 	DX, _str_n		;
	INT 	21h				;
	
	inint 	N				; READ NUMBER AND CHECK SIGN
	CMP 	N, 0			; SQRT(N), N < 0 NOT DEFINED
	JL		_print_err		; PRINT ERROR
	
	MOV		AX, 0			; AX - SUM OF NUMBERS
	MOV 	CX, 1			; CX - ODD NUMBERS (1,3,5,7,...)
	MOV		BX, 0			; BX - RESULT (SQRT)
	
	_while:
		ADD		AX,	CX		; WHILE SUM + CX <= N
		CMP		AX, N		;
		JG		_print_res	;
	
		INC 	BX			; RESULT++
		ADD		CX, 2		; NEW ODD NUMBER
	JMP		_while			; RETURN TO CONDITION

_print_res:
	MOV		AH, 09h			; 
	LEA		DX, _str_res	;
	INT		21h				;

	outint	BX				; PRINT RESULT

	JMP		_exit			;

_print_err:
	MOV 	AH, 09h			; PRINT 'SQRT(N) = '
	LEA		DX, _str_neg	;
	INT 	21h				;
	JMP		_exit			;

	;=======CODE=======
	
	; FINISH
_exit:
	POP		DS
	POP		AX

	MOV		AX, 4C00h
	INT		21h
main ENDP
	 END	main
