INCLUDE IO.ASM

.286

.MODEL SMALL

.STACK 128

.DATA
    ARR         DW 100 DUP(?)
    N           DW ?

.CODE
; WORD N - NUMBER OF ELEMENTS
; WORD ARRAY ARR - REFERENCE TO ARRAY
selection_sort  PROC    FAR
    PUSHA
    MOV     BP, SP
    
    MOV     CX, [BP + 20]   ; N (16 FOR PUSHA + 2 FOR CS + 2 FOR IP)
    MOV     BX, [BP + 22]   ; ARR REF
    
    MOV     AX, CX          ; ARRAY SIZE IN BYTES
    ADD     AX, CX          ;
    
    DEC     CX              ; CX = N - 1
    
    _loop_sort:
        MOV     DI, BX      ; MOV IDX TO DI
        
        MOV     SI, BX      ; I = J + 1
        ADD     SI, 2       ;
       
        _loop_find_min:
        CMP     SI, AX      ; SI < ARR_SIZE
        JGE      _iter
 
            MOV     DX, [DI]        ;
            CMP     DX, [SI]        ; IF CURRENT MIN < ELEMENT
            JL      _skip_min_iter  ; CONTINUE
           
            MOV     DI, SI
 
            _skip_min_iter:
            ADD     SI, 2           ; ++I
        JMP     _loop_find_min
   
        _iter:
        MOV     DX, [BX]    ; SWAP WITH MIN
        XCHG    DX, [DI]    ;
        MOV     [BX], DX    ;
 
        ADD     BX, 2       ; ++BX
    LOOP    _loop_sort
    
    POPA
    RET     4
selection_sort  ENDP

main    PROC
    MOV     AX, @data
    MOV     DS, AX
    
    ; main code
    inint   N
    
    MOV     CX, N
    MOV     BX, 0
    
    _loop_read:
        inint   ARR[BX]
        ADD     BX, 2
    LOOP    _loop_read
    
    PUSH    OFFSET ARR
    PUSH    N
    CALL    selection_sort
    
    MOV     CX, N
    MOV     BX, 0
    
    _loop_print:
        outint   ARR[BX], 4
        ADD     BX, 2
    LOOP    _loop_print
    ; end of code
    
    MOV     AX, 4C00h
    INT     21h
main    ENDP
        END main