	.equ SWI_Print_String, 0x02
	.equ SWI_Exit, 0x11

	.data
first_string:
	.asciz "Hola\n"
second_string:
	.asciz "Chau\n"

	.text
	.global _start
_start:
	ldr r3, =first_string
	bl 	print_r3 @bifurco a print_r3
	ldr r3, =second_string
	bl 	print_r3 @ojo, b and link vuelve
	b 	fin @b etiqueta
	@en cambio b solo bifruca, no vuelve

print_r3:
	@guardo en el stack el valor del lr que tendra la sig instruccion
	@ y el de r0 (noi se xa q)
	stmfd sp!, {r0,lr}
	mov r0, r3 @pongo en r0 la direc del string a imprimir
	swi SWI_Print_String @lo imprimo
	ldmfd sp!, {r0,pc} 
	@piso el valor del pc con el de lr q guarde en el stack

fin:
	swi SWI_Exit
	.end
