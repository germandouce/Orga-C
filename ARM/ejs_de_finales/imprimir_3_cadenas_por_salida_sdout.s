@ [2 puntos] Codificar un programa en assembler ARM de 32 bits que imprima tres cadenas de caracteres 
@ (definidas en el propio programa) por la salida estándar, haciendo uso de una subrutina interna

    .equ SWI_Print_Str, 0x69
    .equ SWI_Exit, 0x11

    .data

first_string:
    .asciz "Hola\n"

second_string:
    .asciz "Chau\n"

third_string:
    .asciz "como estas?\n"

    .text
    .global _start

_start:
    ldr r3,=first_string
    bl  print_r3    @bl =  branch with link

    ldr r3,=second_string
    bl  print_r3

    ldr r3,=third_string
    bl  print_r3
    b   fin

print_r3:
    STMFD   sp!, {r0,r1,lr}
    mov     r0, #1  @xa imprimir str
    mov     r1,r3    @str a printear
    SWI     SWI_Print_Str
    LDMFD   sp!, {r0,r1,pc} @pc = lr

fin:
    SWI SWI_Exit
    .end