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
	
    ldr r0, =array
    ldr r1, [r0]
    ldr r2, =array_length
    ldr r2, [r2]

buscar_min:
    ldr r3, [r0]
    cmp r1, r3
    ble es_menor
    ldr r1, [r0]
es_menor:
    add r0, r0, #4
    sub r2, r2, #1
    cmp r2, #0
    bne buscar_min

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
