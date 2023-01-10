@ Práctica 16: Mostrar elementos de un vector utilizando direccionamiento por registro indirecto
@ Escribir el código ARM que ejecutado bajo ARMSim# imprima los valores de un vector de
@ cuatro enteros definidos en memoria, recorriendo el vector mediante una subrutina que utilice
@ direccionamiento por registro indirecto.

	.equ SWI_Print_Int, 0x6B
	.equ SWI_Exit, 0x11
    .equ SWI_Print_Str, 0x69

    .equ Stdout, 1
	.data
array:
	.word 4, 8, 12, 9
eol:
	.asciz "\n"

	.text
	.global _start
start:
	@ r2: base
	@ r4: offset
	ldr 	r2, =array
	mov 	r3, #4				@ (r3): longitud array

mostrar_loop:
	bl 		mostrar_elemento
	add 	r2, r2, #4	@r2 +=4
	subs 	r3, r3, #1	@r3 -=1 (vueltas  )
	bne 	mostrar_loop	
	@si no es igual a 0, es decir me quedan vueltas para terminar de recorrer el array,
	@vuelvo a mostrar loop
	b 		fin

	@ mostrar entero apuntado por r2
mostrar_elemento:
	stmfd 	sp!, {r0,r1,lr}		@ Stack: r0 y r1
    ldr 	r0, =Stdout
	ldr 	r1, [r2]
    swi 	SWI_Print_Int
    ldr 	r1, =eol
    swi 	SWI_Print_Str
	ldmfd 	sp!, {r0,r1,pc}		@ Unstack: r0 y r1

fin:
	swi SWI_Exit
	.end