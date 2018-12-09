INCLUDE IO.ASM

; Дана целочисленная неквадратная матрица порядка N*M.
; Найти номера строк, элементы которой образуют геометрическую прогрессию

.286

.MODEL SMALL

.STACK 128

.DATA
    ; VARIABLES DECLARATION
    matrix          DW 10 DUP(10 DUP(0))
    N               DW 0
    M               DW 0
    line_num        DW 0
    mult            DW 0
    
    ELEM_SIZE       DW TYPE matrix
    LINE_SIZE       DW 0
    
    _str_enter_n_m  DB 'ENTER MATRIX DIM (N, M): ', '$'
    _str_enter_mat  DB 'ENTER MATRIX BY ROWS: ', 13, 10, '$'
    _str_result     DB 'LINE NUMBERS WHOSE ELEMENTS FORM A GEOMETRIC PROGRESSION: ', 13, 10, '$'
    
.CODE
main PROC
    MOV     AX, @data           ; INIT DATA SEGMENT
    MOV     DS, AX              ;
    
    MOV     AH, 09h             ; PRINT 
    LEA     DX, _str_enter_n_m  ; 'ENTER MATRIX DIM (N, M): ' 
    INT     21h                 ;
    
    inint   N                   ; ENTER MATRIX SIZE
    inint   M                   ;
    
    MOV     AX, N               ; CALCULATE NUMBER OF ELEMENTS
    MOV     BX, M               ; IN MATRIX
    MUL     BX                  ;
    
    MOV     CX, AX              ; NUMBER OF ELEMENTS TO CX
    
    MOV     AH, 09h             ; PRINT 
    LEA     DX, _str_enter_mat  ; 'ENTER MATRIX BY ROWS: ' 
    INT     21h                 ;
    
    ; SINCE THE ELEMENTS OF THE MATRIX ARE ARRANGED IN LINES, 
    ; THEIR INPUT CAN BE DONE USING A SINGLE CYCLE.
    MOV     BX, 0               ; MEMORY POINTER TO 0
    
    _loop_read_matrix:
    
        inint   matrix[BX]
        ADD     BX, ELEM_SIZE
    
    LOOP    _loop_read_matrix
    
    MOV     BX, 0               ; ROWS POINTER
    
    MOV     AX, M               ; CALCULATE
    MUL     ELEM_SIZE           ; SIZE OF 1 ROW
    MOV     LINE_SIZE, AX       ;
    
    MOV     AH, 09h
    LEA     DX, _str_result
    INT     21h
    
    MOV     CX, N
    _loop_process_n:
        PUSH    CX                  		; SAVE CX
        MOV     CX, M               		; LOAD NUMBER OF COLUMNS
        DEC     CX                  		; CX = M - 1 (BECAUSE WE USE 2 ELEMENTS)
        
        MOV     SI, ELEM_SIZE               ;
        MOV     AX, matrix[BX][SI]          ; CALCULATE MULTIPLIER
        MOV     DX, 0000h                   ; OF PROGRESSION
        IDIV    matrix[BX][0]               ;
        MOV     mult, AX                    ;
        
        MOV     SI, 0                       ; COLUMNS POINTER = 0
        INC     line_num                    ; NUMBER OF LINE + 1
        _loop_process_m:
            MOV     DX, 0000h               ; CALCULATE DELTA FOR EVERY PAIR
            ADD     SI, ELEM_SIZE           ; GET SI + 1 ELEMENT
            MOV     AX, matrix[BX][SI]      ;
            SUB     SI, ELEM_SIZE           ; RESTORE SI
            IDIV    matrix[BX][SI]          ;
            
            ADD     SI, ELEM_SIZE           ; GO TO NEXT ELEMENT
            
            CMP     DX, 0                   ; IF matrix[I][J + 1] % matrix[I][J] != 0
            JNE     _loop_process_n_inc     ; SKIP THIS LINE
            
            CMP     AX, mult                ; COMPARE DELTA BETWEEN ELEMENTS 
        LOOPE   _loop_process_m             ; WITH DELTA OF 1 AND 2 ELEMENTS == MULT 
            
            JNZ     _loop_process_n_inc     ; IF CX != 0 => DON'T PRINT THIS LINE
            
            outint  line_num                ; PRINT LINE NUMBER
            newline                         ; AND NEWLINE
            
        _loop_process_n_inc:
            POP     CX                      ; RESTORE CX FROM STACK
            ADD     BX, LINE_SIZE           ; SET LINE POINTER TO NEW LINE
    LOOP    _loop_process_n
    
    ; ; DEBUG PRINT
    ; MOV     CX, N
    ; MOV     BX, 0
    ; _loop_n:
        ; PUSH    CX
        ; MOV     CX, M
        ; MOV     SI, 0
        ; _loop_m:
            ; outint matrix[BX][SI], 3
            
            ; ADD     SI, ELEM_SIZE
        ; LOOP    _loop_m
        
        ; ADD     BX, LINE_SIZE
        ; POP     CX
        ; newline
    ; LOOP    _loop_n

_exit:
    MOV     AX, 4c00h
    INT     21h
main ENDP
     END main