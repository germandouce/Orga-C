@ [2 puntos] Codificar un programa en Assembler ARM de 32 bits que
@ lea desde un archivo números enteros e imprima por la salida 
@ estándar la sumatoria de ellos

    .equ SWI_Open, 0x66
    .equ SWI_RdInt, 0x6C
    .equ SWI_PrInt, 0x6B
    .equ SWI_PrStr, 0x69
    .equ SWI_PrChr, 0x00
    .equ SWI_Close, 0x68
    .equ SWI_Exit, 0x11
    .equ Stdout,1

    .data

filename:
    .asciz "numeros.txt"

leyenda:
    .asciz "sumatoria"

    .align
inFileHandle:
    .word 0

    .text
    .global _start

_start:
    @open file y error
    ldr r0, =filename
    mov r1,#0 @input = lectura
    swi SWI_Open
    bcs finPrgrm

    @guardo file handle
    @OJO primero, ldr
    ldr r1,=inFileHandle
    str r0,[r1] @guardo el filename en fileHanlde
    @Segundo STR el filenam en la pos de mem donde estaba el hanlder

    @guardo algo para futuras cuentas
    mov r2,#0 @para sumatoria

sig_num:
    @rellamo al handler ldr ldr
    ldr r0,=inFileHandle
    ldr r0,[r0] 
    
    swi SWI_RdInt @deja en r0 el int ledio
    bcs closeFile

    add r2,r2,r0 @r2+= num n

    b sig_num

closeFile:
@rellamo al handler
    ldr r0,=inFileHandle
    ldr r0,[r0]

    swi SWI_Close

    @Solo para practicar uso subrutina

    bl  imprimirSumatoria

    b   finPrgrm

imprimirSumatoria:
    STMFD sp!, {r0,r1,lr}
    
    mov r0,#1
    mov r1,r2
    swi SWI_PrInt

    STMFD sp!, {r0,r1,pc}

finPrgrm:
    swi SWI_Exit
    .end


