@ Práctica 9: Cálculo de mínimo y máximo
@ Escribir el código ARM que ejecutado bajo ARMSim# lea dos enteros desde un archivo e
@ imprima el mínimo y el máximo respectivamente de la siguiente manera:
@ Min: <mínimo>
@ Max: <máximo>

    .equ SWI_Print_String, 0x02
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
	.asciz "two_ints.txt"
min_header:	
    .asciz "Min: "
max_header:
    .asciz "Max: "
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

    bl read_int
    mov r2, r0
    bl read_int
    mov r3, r0

@Algorimo de min max
    cmp r2, r3
    blt print_result
    @pivote en r1
    mov r1, r2  @r1 = r2 =maxTemp
    mov r2, r3  @R2 = r3 = MIN  
    mov r3, r1  @R3 = r1 = MAX    

print_result:
    ldr r0, =Stdout
    ldr r1, =min_header
    swi SWI_Print_Str
    mov r1, r2  @siempre dejo en r2 el MIN
    bl print_r1_int

	ldr r0, =Stdout
    ldr r1, =max_header
    swi SWI_Print_Str
    mov r1, r3  @ siempre dejo en r3 el MAX
    bl print_r1_int

    b exit

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
EofReached:
exit:
    swi SWI_Exit
    .end
