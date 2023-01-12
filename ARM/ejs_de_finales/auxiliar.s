@archivo auxiliar xa copiar solucion de ejercicio que estoy resolviendop
      .equ SWI_Open_File, 0x66
    .equ SWI_Close_File, 0x68
    .equ SWI_Print_Str, 0x69
    .equ SWI_Read_Str, 0x6a
    .equ SWI_Print_Int, 0x6b
    .equ SWI_Read_Int, 0x6c
    .equ Stdout,1
    .equ SWI_Exit, 0x11

    .data
fileName:
    .asciz "numeros.txt"
    .align

InFileHandle:
    .word

    .text
    .global _start

_start:
    ldr r0,=fileName
    mov r1,#0
    swi SWI_Open_File
    bcs InFileError
    ldr r1,=InFileHandle
    str r0,[r1]

    mov r2,#0
loop:
    ldr r0,=InFileHandle
    ldr r0,[r0]
    swi SWI_Read_Int
    bcs EofReached

    add r2,r2,r0

    b loop

EofReached:
    @stmfd sp!,{r0,r1,lr}

    mov r1,r2
    ldr r0,=Stdout


    swi  SWI_Print_Int

    @ldmfd sp!,{r0,r1,pc}

InFileError:
    ldr r0,=InFileHandle
    ldr r0,[r0]
    swi SWI_Close_File
    swi SWI_Exit
    .end

