; Синусоида
; и ничего лишнего...

; Ловпаче Шумаф 25/2
; ФПМ зима 2018

.MODEL  SMALL

.386

.STACK  128

.DATA
    SCREEN_WIDTH    EQU     320             ; НУ ТУТ ПО КЛАССИКЕ
    SCREEN_HEIGHT   EQU     200             ;
    
    BACK_COLOR      EQU     0               ; ЦВЕТ ФОНА
    
    PERIOD          EQU     4               ; ДЛЯ СДВИГА СИНУСОИДЫ ВО ВРЕМЕНИ
    
    SIN_X           DW      0               ; FPU НЕ УМЕЕТ РАБОТАТЬ С РЕГИСТРАМИ (А Я УМЕЮ)
    SIN_Y           DW      0               ; ПОЭТОМУ ДЛЯ РАБОТЫ С НИМ ЗАВОДИМ ПЕРЕМЕННЫЕ
    _1              DW      1               ; СИНУС [-1, 1] = > [0, 2]

    FPU_TEMP        DW      0               ;
    HEIGHT_MUL      DW      100             ; КОЭФФИЦИЕНТ РАСТЯЖЕНИЯ ПО X
    WIDTH_MUL       DW      2               ; КОЭФФИЦИЕНТ РАСТЯЖЕНИЯ ПО Y
    ADDEND          DW      0               ; АККУМУЛЯТОР ПЕРИОДА
    
.CODE
sin     PROC
    FILD    SIN_X
    FILD    WIDTH_MUL
    FMUL
    FILD    ADDEND
    FADD    ST(0), ST(1)
    FFREE   ST(1)
    FILD    FPU_TEMP
    FDIV
    FSIN
    FILD    _1
    FADD    ST(0), ST(1)
    FFREE   ST(1)
    FILD    HEIGHT_MUL
    FMUL
    FISTP   SIN_Y
    RET
sin     ENDP

main    PROC
    MOV     AX, @data
    MOV     DS, AX
    
    FINIT
    MOV     FPU_TEMP, SCREEN_WIDTH
    
    ; SETUP GRAPHICS MODE
    MOV     AX, 0A000h          ; ПОМЕСТИТЬ В ES АДРЕС ВИДЕОБУФФЕРА
    MOV     ES, AX              ;
    
    MOV     AX, 13h             ; 320*200 MODE
    INT     10h                 ;
    
    _loop_draw_sin:
        MOV     SIN_X, 0
        
        _loop_x:
            CALL    sin
            
            MOV     CX, SCREEN_HEIGHT
            MOV     DI, SIN_X
            
            ; ИНИЦИАЛИЗИРУЕМ РАДУГУ
            MOV     DL, 0
            _loop_y:
                CMP     CX, SIN_Y
                JG      _fill_background
                
                MOV     ES:DI, DL
                INC     DL
                JMP     _iter_y
                
                _fill_background:
                    MOV     ES:DI, BYTE PTR BACK_COLOR
                _iter_y:
                ADD     DI, SCREEN_WIDTH
            LOOP    _loop_y
            
            INC     SIN_X
        CMP     SIN_X, SCREEN_WIDTH
        JL      _loop_x
        
        ADD     ADDEND, PERIOD
    _check_key:
    MOV        AH, 1        ; ПОРИСОВАЛИ И ХВАТИТ
    INT        16h          ; ОЖИДАЕМ НАЖАТИЯ КЛАВИШИ
    JZ  _loop_draw_sin
    
    ; А ОНО НАМ НАДО?
    ; MOV     AX, 03h
    ; INT     10h
_exit:
    MOV     AX, 4C00h
    INT     21h
main    ENDP
END     main