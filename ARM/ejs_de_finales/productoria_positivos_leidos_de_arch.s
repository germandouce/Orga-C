@ [2 puntos] Codificar un programa en Assembler ARM de 32 bits que
@ lea desde un archivo números enteros e imprima por la salida 
@ estándar la productoria de aquellos números que sean positivos


    .equ SWI_PrInt, 0x6B
    .equ SWI_PrStr, 0x69
    .equ SWI_PrChr, 0x00
    .equ SWI_Open, 0x66
    .equ SWI_RdInt, 0x6C
    .equ SWI_Close, 0x68
    .equ SWI_Exit, 0x11
    .equ Stdout,1

    .data

archivo_not_found:
    .asciz "no se encontro el archivo"

filename:
    .asciz "enteros.txt"

eol:
    .asciz "\n"
    
    .align
InFileHandle:
    .word   0

    .text
    .global _start

_start:
    ldr r0,=filename        @nombre archivo
    mov r1,#0               @modo.(input) LECTURA = 0
    swi SWI_Open            @abre el archivo y lo "deja" en r0
    bcs InFileError         @bifurca si hubo error

    ldr r1,=InFileHandle    @r1 = direc en mem donde almacenar el fileHandler
    str r0,[r1]             @InfileHandler = filename
    
    mov r4, #1              @r4 = acum productoria
    @(variante de ej)
    @mov r4, #0              @r4 = acum sumatoria 

    read_loop:
    ldr r0, =InFileHandle
    ldr r0,[r0]     @r0 = primer numero
    swi SWI_RdInt   @ademas de leer mueve el puntero al sig ele o algo asi
    bcs cierro_archivo  @bcs si, llegue al eof
    
    @sino, 
    mov r2,r0   @r2 = entero
    cmp r2,#0   @r2-0
    bmi read_loop @si es negativo voy al sig num
    
    @sino, hago la productoria
    @(variante ejercicio)
    @add r4, r4, r2
    mul r4, r4, r2
    
    b read_loop

    InFileError:
    mov r0,#1
    ldr r1,=archivo_not_found
    swi SWI_PrStr
    b   finPrgrm

    cierro_archivo:
    ldr r0,= InFileHandle @[ro] -> InFileHanlde
    ldr r0,[r0]         @[ro] = InFileHanlde
    swi SWI_Close

    ldr r0,=Stdout
    mov r1,r4 @r4=resultado productoria 
    swi SWI_PrInt

    finPrgrm:
    swi SWI_Exit
    .end



