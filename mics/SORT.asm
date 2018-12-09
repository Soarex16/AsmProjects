INCLUDE IO.ASM

.MODEL SMALL

.STACK 128

.DATA
	N			DW	0
	ARR			DW 	128 DUP(?)
	ELEM_SIZE	DW TYPE ARR
	
	_str_err_n	DB	'N MUST BE POSITIVE NUMBER!', '$'

	.CODE	
main PROC
	MOV		AX, @data
	MOV		DS, AX
	
	;=======CODE=======

	inint	N
	
	CMP		N, 0
	JLE		_err_n
	
	MOV		BX, 0
	_loop_read_arr:
		inint	ARR[BX]
		ADD		BX, ELEM_SIZE
	LOOP _loop_read_arr
	
	; PROCESS ARRAY
	MOV		AX, N
	MUL		ELEM_SIZE
	MOV		BX, AX
	
	_while:
	CMP		BX, ELEM_SIZE
	JE		_print_arr
		
		MOV		SI, 0
		
		_loop2:
		CMP		SI, BX
		JE		_iter
			MOV		AX, ARR[SI]
			ADD		SI, ELEM_SIZE
			CMP		AX, ARR[SI]
			JLE		_loop2
			
			XCHG	AX, ARR[SI]
			SUB		SI, ELEM_SIZE
			XCHG	AX, ARR[SI]
			ADD		SI, ELEM_SIZE
		JMP		_loop2
		_iter:
		SUB		BX, ELEM_SIZE
	LOOP	_while
	; PROCESS ARRAY
	
_print_arr:
	MOV		BX, 0	
	_loop_print_arr:
		outint	ARR[BX]
		ADD		BX, ELEM_SIZE
	LOOP _loop_print_arr
	
	JMP _exit
	
_err_n:
	MOV		AH, 09h
	LEA		DX, _str_err_n
	INT		21h
	;=======CODE=======
	
	; FINISH
_exit:
	MOV		AX, 4C00h
	INT		21h
main ENDP
	 END	main
