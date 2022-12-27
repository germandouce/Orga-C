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
	bl 	print_r3
	ldr r3, =second_string
	bl 	print_r3
	b 	fin

print_r3:
	stmfd sp!, {r0,lr}
	mov r0, r3
	swi SWI_Print_String
	ldmfd sp!, {r0,pc}

fin:
	swi SWI_Exit
	.end
