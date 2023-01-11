@ [2 puntos] Codificar un programa en assembler ARM de 32 bits que recorra un vector de enteros y 
@ genere un nuevo vector formado por elementos que resultan de sumar(restar) pares de elementos 
@ del vector original. Ej. Vector original {1,2,5,6}, vector nuevo {3,11}

    .equ SWI_Print_Int, 0x6B
    .equ SWI_Print_Str, 0x69
    .equ Stdout, 1
    .equ SWI_Exit, 0x11

    .data

array_origen:
    .word 1,2,5,6,1,1,2,2

array_destino:
    .word 0,0,0,0 @para mi van solo 2

array_orig_length:
    .word 8

array_nuevo_length:
    .word 4
eol:
    .asciz "\n"

    .text
    .global _start

_start:

    ldr r0,=array_origen
    ldr r1,=array_destino
    ldr r2,=array_orig_length @direc de mem

    ldr r2,[r2] @r2 =long

loop_suma:
    ldr r4, [r0] @r4 = 1er ele
    add r0, r0, #4 @r0 + 4 (me muevo 1 en array orig)
    ldr r5, [r0] @r5 = 2do ele
    add r0, r0, #4 @r0 + 4 (me muevo 1 en array orig)
    add r6, r4, r5 @r6 = r4 + r6
    @sub r6, r4, r5 @ si fuera restar la consigna
    str r6, [r1]  
    @r1(pos en mem del array destino) = suma de un par de eles
    
    sub r2, r2,#2 @resto dos a long array orig (me movi 2 pos)
    add r1, r1,#4 @me muevo 1 en el array de destino

    cmp r2, #0
    bne loop_suma

    ldr r2, =array_destino @r2 = pos en mem del array de destino
    ldr r3, =array_nuevo_length
    ldr r3,[r3] @r3 = long
    mov r0, #1
loop_mostrar:
    cmp r3,#0
    beq fin
    @ldr r0, =Stdout @para printear enteros
    ldr r1,[r2]   @r1= ele del array
    SWI SWI_Print_Int  
    
    ldr r1, =eol
    SWI SWI_Print_Str 

    add r2,#4       @mem muevo 1 en el array
    sub r3, r3, #1 @resto 1 al tam
    b   loop_mostrar

fin:
    swi SWI_Exit
    .end

