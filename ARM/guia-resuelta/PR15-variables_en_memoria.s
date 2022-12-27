	.equ SWI_Print_Int, 0x6B
	.equ SWI_Exit, 0x11
	.equ SWI_Print_Char, 0x00

	.data
entero1:
	.word 5
entero2:
	.word 28

	.text
	.global _start
_start:	
	@ imprimimos el contenido de ambas variables

	@ muestra entero1
	mov r0, #1			@ salida por stdout
	ldr r2, =entero1 	@ (r2) = DIR(entero1)
	ldr r1, [r2]		@ (r1) = entero1
	swi SWI_Print_Int

	mov r0, #'\n
	swi SWI_Print_Char
	
	@ entero2
	mov r0, #1			@ salida por stdout
	ldr r2, =entero2 	@ (r2) = DIR(entero2)
	ldr r1, [r2] 		@ (r1) = entero2
	swi SWI_Print_Int

	mov r0, #'\n
	swi SWI_Print_Char

	@ cargar 43 en entero1
	ldr r0, =entero1 	@ (r0) = DIR(entero1)
	mov r1, #43
	str r1, [r0]		@ almacena 43 in la memoria apuntada por r0

	@ cargar 79 en entero2
	ldr r0, =entero2 	@ (r0) = DIR(entero2)
	mov r1, #79
	str r1, [r0] 		@ almacena 79 in la memoria apuntada por r0

	@ muestra entero1
	mov r0, #1
	ldr r1, =entero1
	ldr r1, [r1]
	swi SWI_Print_Int

	mov r0, #'\n
	swi SWI_Print_Char

	@ muestra entero2
	mov r0, #1
	ldr r1, =entero2
	ldr r1, [r1]
	swi SWI_Print_Int
	
	swi SWI_Exit
	.end
