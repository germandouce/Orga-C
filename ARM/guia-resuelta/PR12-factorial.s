@ Práctica 12: Cálculo de factorial
@ Escribir el código ARM que ejecutado bajo ARMSim# lea un entero desde un archivo, calcule el
@ factorial de ese entero y muestre los valores intermedios del proceso. El algoritmo podría
@ resumirse como:
@ n = <<entero leído desde archivo>>
@ accum = 1
@ while (n != 0) {
@ accum = accum * n
@ print accum
@ print "\n"
@ n = n - 1
@ }
@ print accum
@ print "\n"
@ Una salida aceptable del programa sería, para el caso que el valor de entrada fuera 5:
@ 5
@ 20
@ 60
@ 120
@ 120
@ 120
@ Puede asumirse que el archivo no contendrá un entero negativo.

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

    bl read_int 			@loads 1 value on r0

    mov r1, #1

factorial:
    @es cero?
    cmp r0, #0
    @si es cero bifurco, si no, sigo
    beq factorial_end
    @ r1 = r0*r1 = 7 * 1 (en primera vuelta )
    @ r1 = 6*7 = 42 (segunda vuelta)
    mul r1, r0, r1
    bl print_r1_int
    @r0 -=1 7-> 6
    sub r0, r0, #1
    b factorial @vuelvo dar otra vuelta

factorial_end:
    bl print_r1_int @r1= resultado del factorial
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
exit:
    swi SWI_Exit
    .end
	
