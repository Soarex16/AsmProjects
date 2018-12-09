INCLUDE IO.ASM

; Дан массив целых чисел. Найти наименьшее 
; совершенное число, индекс которого кратен 3

.286

.MODEL SMALL

.STACK 128

.DATA
    N               DW 0
    ARR             DW 100 DUP(?)
    
    DIVIZOR         DW 3
    MIN_NUM         DW 32767
    IDX             DW 0
    PERF            DW ?
    
    ELEM_SIZE       DW TYPE ARR
	ELEM_SKIP		DW 0
	ARR_SIZE		DW 0
    
    _str_enter_n    DB 'ENTER ARRAY SIZE: ', '$'
    _str_enter_arr  DB 'ENTER ARRAY: ', '$'
    _str_print_res  DB 'SMALLEST PERFECT NUMBER WHOSE INDEX IS A MULTIPLE OF 3: ', '$'
    _str_print_err  DB 'THERE IS NO PERFECT NUMBER WHOSE INDEX IS A MULTIPLE OF 3!', '$'
.CODE

;---------------------------------------------------
; Нахождение минимума из 2-х чисел
; Обращение: min x, y
; x - r16/m16
; y - r16/m16
; Результат: x - минимум из 2-х чисел 
; Замечание: операнды не могут одновременно быть m16
;---------------------------------------------------
min     MACRO   x, y
    LOCAL   _min_x
    CMP     x, y
    JLE     _min_x
    
    MOV     x, y
    
    _min_x:
ENDM

is_perf PROC FAR
	PUSH	BX
	PUSH	CX
	PUSH	DX
	
    ENTER   0, 0
    
    MOV     BX, 1           ; SUM OF DIVIZORS TO BX
    MOV     AX, [BP + 12]
	SAR		AX, 1
	MOV		CX, AX
    
    _is_perf_while:
    CMP     CX, 1
    JLE      _is_perf_result
        MOV     DX, 0000h   ; AX /= CX
        MOV     AX, [BP + 12];
        DIV     CX          ;
        
        CMP     DX, 0
        JNE     _is_perf_while_continue
        
        ADD     BX, CX
        
        _is_perf_while_continue:
        DEC     CX
    JMP    _is_perf_while

_is_perf_result:
    MOV     AX, 0
    
    CMP     BX, [BP + 12]
    JNE     _is_perf_ret
    
    MOV     AX, 1

_is_perf_ret:    
    LEAVE
	
	POP		DX
	POP		CX
	POP		BX
    RET     2
is_perf ENDP

main PROC
    MOV     AX, @data           ; INIT DATA SEGMENT
    MOV     DS, AX              ;
    
    MOV     AH, 09h             ; PRINT 
    LEA     DX, _str_enter_n    ; 'ENTER ARRAY SIZE: ' 
    INT     21h                 ;
    
    inint   N
    
    MOV     AH, 09h             ; PRINT 
    LEA     DX, _str_enter_arr  ; 'ENTER ARRAY: ' 
    INT     21h                 ;
    
    MOV     CX, N               ; READ ARRAY
    MOV     BX, 0               ;
                                ;
    _loop_read_arr:             ;
        inint   ARR[BX]         ;
        ADD     BX, ELEM_SIZE   ;
    LOOP    _loop_read_arr      ;
    
	MOV		AX, ELEM_SIZE		; CALCULATE ELEM_SIZE * DIVIZOR
	MUL		DIVIZOR				;
	MOV		ELEM_SKIP, AX		;
	
	MOV		AX, ELEM_SIZE		; CALCULATE ARRAY SIZE
	MOV		DX, 0000h			;
	MUL		N					;
	MOV		ARR_SIZE, AX		;
	
	MOV     BX, ELEM_SKIP
    SUB     BX, ELEM_SIZE
	
    _loop_find_num:
		CMP 	BX, ARR_SIZE
		JG		_check_min

        PUSH    ARR[BX]         ; CHECK IS PERFECT NUMBER
        CALL    is_perf         ;
        MOV     PERF, AX        ;
        
        CMP     PERF, 1         ; IF NOT PERFECT => CONTINUE
        JNE     _iter
        
        MOV		AX, MIN_NUM		;
		MIN		AX, ARR[BX]     ; GET MINIMAL NUMBER
        MOV     MIN_NUM, AX     ;
		
        _iter:
		ADD		BX, ELEM_SKIP
    JMP		_loop_find_num
    
	_check_min:
    CMP     MIN_NUM, 32767      ; IF MIN ISN'T CHANGED
    JNE     _print_result       ; PRINT ERROR
    
    MOV     AH, 09h             ; PRINT
    LEA     DX, _str_print_err  ; ERROR
    INT     21h                 ;
    JMP     _exit               ;
    
    _print_result:
    MOV     AH, 09h             ; PRINT
    LEA     DX, _str_print_res  ; RESULT
    INT     21h                 ;
    outint  MIN_NUM             ;

_exit:    
    MOV     AX, 4c00h
    INT     21h
main ENDP
     END main