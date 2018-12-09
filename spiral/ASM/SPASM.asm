.MODEL  TINY

; link with flag /n

.DATA
    STEPS   DW 0, 0, 0, 0
    DELTAS  DW 2, 0, -2, 0
    
    ARR     DW 81 DUP(0)
    N       DW ?
    _10     DB 10
.CODE
print   PROC
    ADD     DL, 48
    MOV     AH, 02h
    INT     21h
    RET
print   ENDP

traverse    PROC
    MOV     CX, STEPS[BX]       ; КОЛИЧЕСТВО ШАГОВ
    MOV     AX, DELTAS[BX]      ; РАЗМЕР ШАГА
    _loop_travel:
        ADD     SI, AX          ; СЛЕДУЮЩИЙ ЭЛЕМЕНТ
        MOV     ARR[SI], DX     ; ПОМЕСТИЛИ ЧИСЛО
        INC     DX              ; УВЕЛИЧИЛИ ЧИСЛО
    LOOP    _loop_travel
    
    SUB     STEPS[BX], 2        ; В СЛЕДУЮЩИЙ РАЗ ПРОЙДЕМ НА 2 ШАГА МЕНЬШЕ
    ADD     BX, 2               ; СДВИНУЛИСЬ НА СЛЕДУЮЩИЙ ИНДЕКС
    RET
traverse    ENDP

main    PROC
    MOV     AX, @data
    MOV     DS, AX
    
    ;---N=---
    MOV     DL, 'N' - 48
    CALL    print
    
    MOV     DL, '=' - 48
    CALL    print
    ;---N=---
    
    ;AX = N
    DEC     AH
    INT     21h
    SUB     AX, 304

    MOV     N, AX
    
    ; AX = N*2
    SAL     AX, 1
    MOV     DELTAS + 2, AX  ; ВПРАВО ПРОПУСКАЕМ СТРОКИ
    NEG     AX
    MOV     DELTAS + 6, AX  ; ВЛЕВО ПРОПУСКАЕМ СТРОКИ
    
    MOV     DX, 1           ; САМИ ЧИСЛА 1-N^2
    MOV     SI, -2          ; ИНДЕКС В МАССИВЕ
    
    ; ИНИЦИАЛИЗИРУЕМ КОЛИЧЕСТВО ШАГОВ В КАЖДУЮ СТОРОНУ
    MOV     AX, N
    MOV     STEPS, AX       ; ВПРАВО СНАЧАЛА N ШАГОВ
    
    DEC     AX
    MOV     STEPS+2, AX     ; ВНИЗ СНАЧАЛА N-1 ШАГ
    MOV     STEPS+4, AX     ; ВЛЕВО СНАЧАЛА N-1 ШАГ
    
    DEC     AX
    MOV     STEPS+6, AX     ; ВВЕРХ N-2 ШАГА
    
    _fill_loop:
        ; LEFT=>RIGHT
        MOV     BX, 0
        CALL    traverse
        
        ; UP=>DOWN
        ;MOV     BX, 2
        CMP     STEPS[BX], 0
        JE      _print_mat
        CALL    traverse
        
        ; LEFT<=RIGHT
        ;MOV     BX, 4
        CALL    traverse
        
        ; UP<=DOWN
        ;MOV     BX, 6
        CMP     STEPS[BX], 0
        JE      _print_mat
        CALL    traverse
    JMP     _fill_loop
    
    _print_mat:
    MOV     SI, 0
    MOV     CX, N
    _print_outer:
        PUSH    CX
        
        MOV     DL, 10-48
        CALL    print
        
        MOV     CX, N
        _print_inner:
            MOV     AX, ARR[SI]
            DIV     _10
            MOV     BX, AX
            
            MOV     DL, BL
            CALL    print
            
            MOV     DL, BH
            CALL    print
            
            MOV     DL, ' ' - 48
            CALL    print
            
            ADD     SI, 2
        LOOP    _print_inner
        POP     CX
        
    LOOP    _print_outer
    MOV     AX, 4C00h
    INT     21h
main    ENDP
END     main