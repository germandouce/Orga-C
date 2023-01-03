	.equ SWI_Open_File, 0x66
	.equ SWI_Read_Int, 0x6C
	.equ SWI_Close_File, 0x68
	.equ SWI_Print_Char, 0x00
    .equ SWI_Print_Str, 0x69
    .equ SWI_Print_Int, 0x6B 
    .equ SWI_Exit, 0x11 @ solicita a ARMSim que salga del programa   
    
    .data
cadena: 
    .asciz "linea"

first_string: 
    .asciz "Hola\n"

second_string:
	.asciz "Chau\n"

entero:
    .word 78

    .text

    .global _start

_start:
	ldr r3, =first_string
	bl 	print_r3 @bifurco a print_r3
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
    @y vuelvpo al lin=
fin:
	swi SWI_Exit
	.end