@ Práctica 21: Calcular y almacenar suma de una constante a un vector
@ Escribir el código ARM que ejecutado bajo ARMSim# lea los valores de un vector 
@( vector ) de longitud long_vector , sume un valor específico ( valor ) y 
@ `guarde el resultado en otro vector
@ ( vector_suma ).

	.equ SWI_Print_Int, 0x6B
	.equ SWI_Exit, 0x11
	.equ SWI_Print_Str, 0x69
	.equ Stdout, 1

	.data
array_origen:
	.word 76, 14, 49, 27, -9, 108, 99
array_destino:
	.word 0, 0, 0, 0, 0, 0, 0
array_length:
	.word 7
constante:
	.word 9
eol:
    .asciz "\n"
	
	.text
	.global _start
_start:

    ldr r0, =array_origen
    ldr r1, =array_destino
    ldr r2, =array_length
    ldr r2, [r2]	@r2 = long del vector orig
    ldr r3, =constante
    ldr r3, [r3]	@r3 = valor de la cte

loop_suma:
    ldr r4, [r0]	@r4 pivote = contenido de la direc del primer ele
    add r4, r4,r3	@r4=1er ele + cte
    str r4, [r1]	@dejo en la direc de memoria del nuevo vector
    add r0, r0, #4	@avanzo en vector orig
    add r1, r1, #4	@avanzo en vector destomp
    sub r2, r2, #1	@resto 1 a la long del vector orig
    cmp r2, #0		
    bne loop_suma	@si no es igual, sig elemento

	ldr r2, =array_destino	@direc de destino
	ldr r3, =array_length 
	ldr r3, [r3]	@r3 = tam array orig, guardado en var
	
loop_mostrar:
	cmp r3, #0
	beq exit

	ldr r0, =Stdout
	ldr r1, [r2]	@num en esa direc
	swi SWI_Print_Int	
	ldr r1, =eol
    swi SWI_Print_Str

	add r2, r2, #4
	sub r3, r3, #1
	b loop_mostrar

exit:	
	swi SWI_Exit
	.end
