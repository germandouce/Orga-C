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
        bcs EofReached
        @ el entero está ahora en r0

        mov r2, r0

        mov r1, r2
        bl print_r1_int
        mov r3, #-1
        EOR r1, r2, r3          @ (r1)=NOT(r2)
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
	swi SWI_Exit
	.end
