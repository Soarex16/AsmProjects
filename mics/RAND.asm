INCLUDE IO.ASM

.286

.MODEL SMALL

.STACK 128

.DATA
    _str_tab    DB 9, '$'
.CODE
SEED    DW 0
A       DW 51
C       DW 21
M       DW 32561

init_rand   PROC
    PUSH    AX
    PUSH    CX
    PUSH    DX
    
    MOV     AH, 2Ch
    INT     21h
    
    ; MOV     BX, CX
    ; MOV     CX, [BX]
    MOV     SEED, CX
    
    POP     DX
    POP     CX
    POP     AX
    RET
init_rand   ENDP

rand    PROC
    ; SEED = (A * SEED + C) % M
    PUSH    BX
    PUSH    DX
    
    MOV     AX, A
    MUL     SEED
    ADD     AX, C
    DIV     M
    
    MOV     SEED, DX
    MOV     BX, DX
    MOV     AX, [BX]
    ; MOV     AX, DX
    
    POP     DX
    POP     BX
    RET
rand    ENDP
main    PROC
    MOV     AX, @data
    MOV     DS, AX
    
    ; main code
    CALL init_rand
    
    inint   CX
    _loop:
        CALL    rand
        outint  AX
        
        MOV     AH, 09h
        LEA     DX, _str_tab
        INT     21h
    LOOP    _loop
    ; end of code
    
    MOV     AX, 4C00h
    INT     21h
main    ENDP
        END main