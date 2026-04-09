RESET:
    ; set SP
    LD SP, 0FFFFh

    ; set input char '>' ASCII code
    LD A, '>'

    ; call PUTCHAR
    CALL PUTCHAR

    ; call HALT_LOOP
    CALL HALT_LOOP

;--------------------------------
; PUTCHAR
; Sends character in A to output
;--------------------------------
PUTCHAR:
    ; send arg to output
    OUT (01h), A
    
;--------------------------------
; HALT_LOOP
; Infinite halt loop
;--------------------------------
HALT_LOOP:
    HALT

    ; call HALT_LOOP
    CALL HALT_LOOP