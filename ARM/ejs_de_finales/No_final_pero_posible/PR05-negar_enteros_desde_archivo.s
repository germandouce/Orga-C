@ Práctica 5. Negar enteros desde archivo
@ Escribir el código ARM que ejecutado bajo ARMSim# lea dos enteros desde un archivo e
@ imprima:
@ El primer entero en su propia línea.
@ El resultado de aplicar NOT al primer entero en su propia línea.
@ El segundo entero en su propia línea.
@ El resultado de aplicar NOT al segundo entero en su propia línea.

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
	.asciz "dos_enteros.txt"
eol:
        .asciz "\n"
        .align
InFileHandle:
        .word  0

	.text
	.global _start
_start:
        @abrir archivo
        ldr r0,=filename        @ nombre de archivo de entrada
        mov r1,#0               @ modo: entrada
        swi SWI_Open_File       @ abre archivo
        bcs InFileError         @ chequear si hubo error
        ldr r1,=InFileHandle    @ cargar dirección donde almacenar el handler
        str r0,[r1]             @ almacenar handler

read_loop:
        @leer entero de archivo
        ldr r0,=InFileHandle
        ldr r0,[r0]
        swi SWI_Read_Int
        bcs EofReached  @bcs carry es 0, fin de prgm
        @ el entero está ahora en r0

        mov r2, r0

@imprimo el primer entero en su propia linea
        mov r1, r2
        bl print_r1_int @imprime el numero en r1 como un entero
        mov r3, #-1     @ (*) cargo -1 en un registro 
        @r3 = 1111 1110
        @63 [10] = 0011 1111
        @r3  = 1111 1111
        @xor (resultado de aplicar not al primer entero)
        @ma da el opuesto xq si habia 1, contra 1 da 0. si habia 0, contra 1 da 0.
        @r2  = 0011 1111
        @r1  = 1100 0001
        @(literal hace not (-63) y resta 1 -> -64)
        @5 -> -6
        EOR r1, r2, r3          @ (*) (r1)=NOT(r2)
        @EOR r1, r2, #-1    @ESTO NO SIRVE XQ -1 LO TOMA COMO UNA CTE
        @NO COMO UN NUMERO      @ (r1)=NOT(r2)

        bl print_r1_int
        b read_loop

print_r1_int:
        stmfd sp!, {r0,r1,lr}
        ldr r0, =Stdout
        swi SWI_Print_Int
        ldr r1, =eol
        swi SWI_Print_Str
        ldmfd sp!, {r0,r1,pc}

InFileError:
EofReached:
        @cierro archivo
        ldr r0,= InFileHandle @[ro] -> InFileHanlde
        ldr r0,[r0] @[ro] = InFileHanlde
        swi 0x68

	swi SWI_Exit
	.end
