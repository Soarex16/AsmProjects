; Диаграмма Вороного
; ВОРОНИЛ, ВОРОНЮ И БУДУ ВОРОНИТЬ!

; Ловпаче Шумаф 25/2
; ФПМ зима 2018

.MODEL  SMALL

.286

.STACK  128

.DATA
    N               EQU     25              ; КОЛИЧЕСТВО ЛОКУСОВ
    FOCUS_COLOR     EQU     0               ; ЦВЕТ ФОКУСНЫХ ТОЧЕК
    SCREEN_WIDTH    EQU     320             ; ЕСЛИ ВЫ НЕ ЗНАЕТЕ ЗАЧЕМ ЭТО
    SCREEN_HEIGHT   EQU     200             ; ТО ЗАКРОЙТЕ ЭТОТ ШЕДЕВР
    FRAME_SIZE      EQU     SCREEN_WIDTH * SCREEN_HEIGHT
    
    MIN_DIST        DW      65535           ; МАКСИМАЛЬНОЕ РАССТОЯНИЕ (ДОЛЖНО БЫТЬ БОЛЬШЕ ДИАГОНАЛИ ДИСПЛЕЯ)
	CURRENT_DIST    DW      65535           ; ПРОМЕЖУТОЧНАЯ ПЕРЕМЕННАЯ ДЛЯ ПОИСКА МИНИМУМА
    X_COORD		    DW 	    100 DUP(?)      ; X КООРДИНАТЫ ФОКУСОВ
	Y_COORD		    DW	    100 DUP(?)      ; Y КООРДИНАТЫ ФОКУСОВ
	_42             DW      10              ; АЛЬЕТРНАТИВНЫЙ ОТВЕТ НА ГЛАВНЫЙ ВОПРОС ЖИЗНИ, ВСЕЛЕННОЙ И ВСЕГО ТАКОГО

    RAND_SEED       DW      32561           ; "ТАК НАДО." КОСТЕНКО К. И.
    
    X               DW      0
    Y               DW      0
    
    
.CODE
; Я НЕ ЗНАЮ ПОЧЕМУ ОНО РАБОТАЕТ
; Я ПРОСТО ГДЕ-ТО В ИНТЕРНЕТЕ УВИДЕЛ
; ТАКУЮ ФОРМУЛУ

; РЕЗУЛЬТАТ В AX
rand    PROC
    PUSH    CX
    PUSH    DX
    
    PUSH    BP
    MOV     BP, SP

    ; GET TIME
    MOV     AH, 0
    INT     1Ah
    
    ; CALCULATE RANDOM
    MOV     AX, DX
    MUL     CX
    XOR     AX, [RAND_SEED]
    XOR     DX, DX
    DIV     WORD PTR [BP + 4 + 4]
    MOV     AX, DX
    
    ; UPDATE SEED
    ADD     RAND_SEED, BX
    ADD     RAND_SEED, CX
    
    POP     BP
    POP     DX
    POP     CX
    
    RET     2
rand    ENDP

; IN: X, Y
; OUT: AX - MIN_IDX
calc_closest    PROC
    PUSH    BX
    PUSH    CX
    PUSH    DX
    
    MOV     CX, N
    MOV     BX, 0
    
    MOV     DX, 65535               ; MINIMAL DISTANCE
    MOV     AX, -1                  ; INDEX OF MIN
    
    _loop_find_min_dist:
        FILD    X_COORD[BX]
        FILD    X
        FSUB    ST(0), ST(1)        ; X_COORD[BX] - X
        FMUL    ST(0), ST(0)        ; (X_COORD[BX] - X)^2
        
        FILD    Y_COORD[BX]
        FILD    Y
        FSUB    ST(0), ST(1)        ; Y_COORD[BX] - Y
        FMUL    ST(0), ST(0)        ; (Y_COORD[BX] - Y)^2
        
        FADD    ST(0), ST(2)        ; D_X^2 + D_Y^2
        FSQRT
        
        FILD    _42                 ; MUL BY 10
        FMUL    ST(0), ST(1)        ; FOR HUGHER PRESCISION
        
        FISTP   CURRENT_DIST        ; SAVE CURRENT DIST
        
        FFREE   ST(0)               ; CLEAR FPU STACK
        FFREE   ST(1)               ; У FPU В ПРИНЦИПЕ СТЕК
        FFREE   ST(2)               ; ЗАКОЛЬЦОВАН, НО ЛУЧШЕ
        FFREE   ST(3)               ; ЗА СОБОЙ ПРИБРАТЬСЯ
        
        CMP     CURRENT_DIST, DX    ; НАДЕЕМСЯ НА ЛУЧШЕЕ
        JNB     _find_closest_continue
        
        ; UPDATE MINIMUN
        MOV     DX, CURRENT_DIST
        MOV     AX, BX
        
        _find_closest_continue:
        ADD     BX, 2
    LOOP    _loop_find_min_dist
    
    ; ХОДИЛИ ПО КООРДИНАТАМ
    ; ПОЛУЧИЛИ ПО НИМ ИНДЕКС
    ; ПОДЕЛИЛИ ПОПОЛАМ
    SHR     AX, 1
    
    POP     DX
    POP     CX
    POP     BX
    
    RET
calc_closest    ENDP

main    PROC
    MOV     AX, @data
    MOV     DS, AX
    
    FINIT
    
    ; SETUP GRAPHICS MODE
    MOV     AX, 0A000h          ; ПОМЕСТИТЬ В ES АДРЕС ВИДЕОБУФФЕРА
    MOV     ES, AX              ;
    
    MOV     AX, 13h             ; 320*200 MODE
    INT     10h                 ;
    
    ; RANDOMIZE POINTS
    MOV     CX, N
    MOV     BX, 0
    
    ; ВЫЧИСЛЯЕМ КООРДИНАТЫ ФОКУСОВ
    _loop_randomize:
        PUSH    SCREEN_WIDTH
        CALL    rand
        MOV     X_COORD[BX], AX
        
        PUSH    SCREEN_HEIGHT
        CALL    rand
        MOV     Y_COORD[BX], AX
        
        ADD     BX, 2
    LOOP    _loop_randomize
    
    MOV     BX, 0
    MOV     DI, 0
    
    _loop_fill_areas:
        ; ВЫЧИСЛЯЕМ ИНДЕКС БЛИЖАЙШЕЙ ТОЧКИ
        CALL    calc_closest
        MOV     BX, AX
        
        ; ПО ИНДЕКСУ ВЫЧИСЛЯЕМ ЦВЕТ
        ; (IDX + 30) * 2
        ADD     AL, 30
        SHL     AL, 1
        
        ; ПОМЕЩАЕМ В ВИДЕОБУФФЕР ТОЧКУ
        MOV     ES:DI, AL
        INC     DI
        
        ; ЕСЛИ КОНЧИЛАСЬ СТРОКА, СБРАСЫВАЕМ X
        INC     X
        CMP     X, SCREEN_WIDTH
        JNE     _loop_fill_areas
        MOV     X, 0
        
        ; ЕСЛИ КОНЧИЛСЯ СТОЛБЕЦ, СБРАСЫВАЕМ Y
        INC     Y
        CMP     Y, SCREEN_HEIGHT
        JNE     _loop_fill_areas
        MOV     Y, 0
    
    ; ДОЙДЕМ СЮДА, КОГДА ЗАПОЛНИМ ВСЕ ТОЧКИ
    
    ; РИСУЕМ ФОКУСЫ
    ; покусы
    MOV     BX, 0
    MOV     CX, N
    _draw_area_focuses:
        ; СЧИТАЕМ ПОЗИЦИЮ ТОЧКИ В ВИДЕОБУФФЕРЕ
        MOV     AX, SCREEN_WIDTH
        MUL     Y_COORD[BX]
        ADD     AX, X_COORD[BX]
        MOV     DI, AX
        
        ; X, Y
        PUSH    DI
        MOV     ES:DI, BYTE PTR FOCUS_COLOR
        POP     DI
        
        ; X+1, Y
        PUSH    DI
        INC     DI
        MOV     ES:DI, BYTE PTR FOCUS_COLOR
        POP     DI
        
        ; X-1, Y
        PUSH    DI
        DEC     DI
        MOV     ES:DI, BYTE PTR FOCUS_COLOR
        POP     DI
        
        ; X, Y+1
        PUSH    DI
        ADD     DI, SCREEN_WIDTH
        MOV     ES:DI, BYTE PTR FOCUS_COLOR
        POP     DI
        
        ; X, Y-1
        PUSH    DI
        SUB     DI, SCREEN_WIDTH
        MOV     ES:DI, BYTE PTR FOCUS_COLOR
        POP     DI
        
        ADD     BX, 2
    LOOP    _draw_area_focuses
    
    MOV        AH, 0        ; ОЖИДАЕМ НАЖАТИЯ КЛАВИШИ
    INT        16h
    
    ; А ОНО НАМ НАДО?
    ; MOV     AX, 03h
    ; INT     10h
_exit:
    MOV     AX, 4C00h
    INT     21h
main    ENDP
END     main
; ДОЧИТАЛ ДО СЮДА - МОЛОДЕЦ, МОЖЕШЬ ТРЕБОВАТЬ КОНФЕТКУ У АВТОРА





; P.S. но не факт, что он вам ее даст