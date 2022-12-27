        @ constantes
        .equ SWI_Print_String, 0x02
        .equ SWI_Exit, 0x11

        @ sección de datos - datos que el programa usará
        .data
mensaje:
        @ .asciz : string terminado en byte nulo
        .asciz "Hola Mundo"

        @ sección de código - porción ejecutable del código
        .text

        @ hace _start disponible al linker
        @ esto es effectivamente parte de la definición del "main"
        .global _start
_start:
        @ carga el puntero al string en el registro r0
        ldr r0, =mensaje

        @ solicita a ARMSim que imprima el string
        swi SWI_Print_String

        @ solicita a ARMSim que salga del programa
        swi SWI_Exit
        .end
