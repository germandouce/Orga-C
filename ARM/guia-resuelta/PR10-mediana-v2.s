	.equ SWI_Open_File, 0x66
	.equ SWI_Read_Int, 0x6C
	.equ SWI_Print_Int, 0x6B
	.equ SWI_Close_File, 0x68
	.equ SWI_Exit, 0x11

	.equ SWI_Print_Str, 0x69

    .equ Stdout, 1

	.data
filename:
	.asciz "tres_enteros.txt"
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

    @loads 3 values on r2, r3 and r4
    bl read_int
    mov r2, r0
    bl read_int
    mov r3, r0
    bl read_int
    mov r4, r0

    cmp r2, r3
    movgt r1, r2
    movgt r2, r3
    movgt r3, r1

    cmp r2, r4
    movgt r1, r2
    movgt r2, r4
    movgt r4, r1

    cmp r3, r4
    movgt r1, r3
    movgt r3, r4
    movgt r4, r1

    mov r1, r3
    bl print_r1_int

    b exit

@read integer from file
read_int:
    stmfd sp!, {lr}
    ldr r0,=InFileHandle
    ldr r0,[r0]
    swi SWI_Read_Int
    ldmfd sp!, {pc}

swapr5r6:
	stmfd sp!, {r1,lr}
	mov r1, r5
    mov r5, r6
    mov r6, r1
    ldmfd sp!, {r1,pc}

print_r1_int:
    stmfd sp!, {r0,r1,lr}      @ Stack r1
    ldr r0, =Stdout
    swi SWI_Print_Int          @ Print integer in register r1 to stdout
    ldr r1, =eol
    swi SWI_Print_Str          @ Print EOL in register r1 to stdout
    ldmfd sp!, {r0,r1,pc}      @ Unstack r1

InFileError:
EofReached:
exit:
    swi SWI_Exit
	.end
