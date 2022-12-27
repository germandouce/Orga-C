	.equ SWI_Open_File, 0x66
	.equ SWI_Read_Int, 0x6C
	.equ SWI_Print_Int, 0x6B
	.equ SWI_Close_File, 0x68
	.equ SWI_Exit, 0x11
	.equ SWI_Print_Char, 0x00

	.equ SWI_Print_Str, 0x69

    .equ Stdout, 1

	.data
filename:
	.asciz "entero.txt"
eol:
    .asciz "\n"
    .align
InFileHandle:
    .word  0

	.text
	.global _start
_start:
   	@open file
    ldr r0,=filename        @ set Name for input file
    mov r1,#0               @ mode is input
    swi SWI_Open_File       @ open file for input
    bcs InFileError         @ if error?
    ldr r1,=InFileHandle    @ load input file handle
    str r0,[r1]             @ save the file handle

    bl read_int             @loads 1 value on r0
    bl fibonacci
    bl print_r1_int
    b exit
    
    @ (r1) = fibonacci(r0)
fibonacci:
    stmfd sp!, {r0,r2,lr}
    cmp r0, #1
    ble fibonacci1
    sub r0, r0, #1
    bl fibonacci
    mov r2, r1
    sub r0, r0, #1
    bl fibonacci
    add r1, r1, r2
    b fibonacci_end
fibonacci1:
    mov r1, r0
fibonacci_end:
    ldmfd sp!, {r0,r2,pc}

	@read integer from file
read_int:
    stmfd sp!, {lr}
    ldr r0,=InFileHandle
    ldr r0,[r0]
    swi SWI_Read_Int
    ldmfd sp!, {pc}

print_r1_int:
    stmfd sp!, {r0,r1,lr}      @ Stack r1
    ldr r0, =Stdout
    swi SWI_Print_Int          @ Print integer in register r1 to stdout
    ldr r1, =eol
    swi SWI_Print_Str          @ Print EOL in register r1 to stdout
    ldmfd sp!, {r0,r1,pc}      @ Unstack r1

InFileError:
exit:
	swi SWI_Exit
	.end
