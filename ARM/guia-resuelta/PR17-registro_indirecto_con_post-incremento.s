@Práctica 17: Mostrar elementos de un vector utilizando direccionamiento por 
@registro indirecto con post-incremento
@Modificar el ejercicio para utilizar direccionamiento por registro 
@indirecto con post-incremento.

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
	subs 	r3, r3, #1
	bne 	mostrar_loop
	b 		fin

	@ mostrar entero apuntado por r2
mostrar_elemento:
	stmfd 	sp!, {r0,r1,lr}		@ Stack: r0 y r1
    ldr 	r0, =Stdout
	@r1 = direc de mem en r2.
	@y al mismo [r2] + 4 bytes
	@esto es post incremento. Agregarle al final de la load que hago de mem
	@lo q incremento el r2. Lee y suma.
	ldr 	r1, [r2], #4
    swi 	SWI_Print_Int
    ldr 	r1, =eol
    swi 	SWI_Print_Str
	ldmfd 	sp!, {r0,r1,pc}		@ Unstack: r0 y r1

fin:
	swi SWI_Exit
	.end