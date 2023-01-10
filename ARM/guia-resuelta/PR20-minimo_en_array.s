@ Práctica 20: Encontrar el menor elemento de un vector
@ Escribir el código ARM que ejecutado bajo ARMSim# encuentre e imprima el menor elemento
@ de un vector, donde el vector está especificado con el label vector y la longitud del vector con
@ el label long_vector .

	.equ SWI_Print_Int, 0x6B
	.equ SWI_Exit, 0x11
	.equ SWI_Print_Str, 0x69
    .equ Stdout, 1

	.data
array:
    .word 76, 14, 49, 27, -9, 108, 99, -25
array_length:
	.word 8
eol:
    .asciz "\n"

	.text
	.global _start
_start:	
	
    ldr r0, =array @r0 = direc del array
    ldr r1, [r0] @r1 = Primer ele
    ldr r2, =array_length 
    ldr r2, [r2] @r2 - cant de eles

buscar_min:

    @con post incremento, 
    @ldr r3, [r0], #4 @guardo el ele actual y me muevo al sig
    @pero ojo, dsps tendria q hacer ver(*)
    ldr r3, [r0]    @r3 = primer ele del array (ele actual en la iter)
    cmp r1, r3  @r1<r3? minAnt < r3(NumActual)
    ble es_menor @el ant es menor? si lo es, sig num
    @mov r1, r3 @ (*) xq el [r0] ya no apunta al prox (2 instr xa abajo)
    ldr r1, [r0]    @sino, pispo r1= nuevoMin
es_menor:
    add r0, r0, #4 @me muevo al sig ele
    sub r2, r2, #1 @resto 1 al cont del tam del array
    cmp r2, #0 @pregunto si el contador llego a 0
    bne buscar_min  @si no llego a 0, hay nums en el vector

print_r1_int:
    stmfd sp!, {r0,r1,lr}
    ldr r0, =Stdout
    swi SWI_Print_Int
    ldr r1, =eol
    swi SWI_Print_Str
    ldmfd sp!, {r0,r1,pc}

exit:
	swi SWI_Exit
	.end
