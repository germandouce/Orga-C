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
	mov		r4, #0

mostrar_loop:
	bl 		mostrar_elemento
	subs 	r3, r3, #1
	bne 	mostrar_loop
	b 		fin

	@ mostrar entero apuntado por r2
mostrar_elemento:
	stmfd 	sp!, {r0,r1,lr}		@ Stack: r0 y r1
    ldr 	r0, =Stdout
	ldr 	r1, [r2, r4, LSL #2]
	add		r4, r4, #1
    swi 	SWI_Print_Int
    ldr 	r1, =eol
    swi 	SWI_Print_Str
	ldmfd 	sp!, {r0,r1,pc}		@ Unstack: r0 y r1

fin:
	swi SWI_Exit
	.end