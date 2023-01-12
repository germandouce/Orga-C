@Codificar un programa en ARM de 32 biuts que recorra un vector de eneteros y genere
@un artchivo de salida con el resultado de aplicar la funcion AND en cada uno de los 
@elementos del vector original contra una cte.

    .equ SWI_Open,0x66
    .equ SWI_Close,0x68
    .equ SWI_Print,0x6b
    .equ SWI_PrStr, 0x69
    .equ SWI_Exit, 0x11

    .data

array:
    .word 32, 14, -17, 9

array_length:
    .word 4

constante:
    .word 1

@numero and 1 en bpf
@deja 0 si es par, 1 si es impar
@buen ejemplo xa controlar facilmente q el prgrm funciono

saltoLinea:
    .asciz "\n"

    .align
filename:
    .asciz "archivo.txt"

inFileHandle:
    .word 0
    
    .text

    .global _start

_start:
    ldr r0,=filename
    mov r1,#1  @output (escritura)
    swi SWI_Open
    bcs finPrograma
    ldr r1, =inFileHandle
    str r0,[r1] @inFileHandle = filename
    
    @direc array
    ldr r8,=array
    
    @long array
    ldr r9,=array_length
    ldr r9,[r9]

    @cte o array de destino cuando uno quuiere hacer alguna operacion
    ldr r10, =constante
    ldr r10,[r10]

sig_ele:

    @cargo 1er ele en registrto DISTINTO al q uso para iterar
    @usar estrategico si necesito imprimr/ meter en archivo
    ldr r1,[r8] @r1 = num del array. 
    @aprovecho q lo necesito en r1 xa printearlo en el archivo
    and r1,r1,r10 @r1 = num and r10 =  num and cte

    bl escribirArhivo
    
    @me muvo a sig ele
    add r8,r8,#4 @sig elemento
    @achico el tam del vector para cortar el loop
    sub r9,r9,#1 @long -1
    
    @comparo y luego cond de corte de loop
    cmp r9,#0
    bne sig_ele

    b   cierro_archivo
    @fin loop sigo con otras cosas
    
escribirArhivo:
@ @subrutina, OJO no olvidar pila
    STMFD sp!, {r0, r1, lr}

    ldr   r0, =inFileHandle @lo tengo guardado aca
    ldr   r0,[r0]

    swi   SWI_Print

    ldr   r1,=saltoLinea
    swi   SWI_PrStr

    LDMFD sp!, {r0,r1,pc}

cierro_archivo:
    ldr r0, =inFileHandle
    ldr r0,[r0]
    swi SWI_Close

finPrograma:
    swi SWI_Exit
    .end
