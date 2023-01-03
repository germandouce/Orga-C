        @ constantes
        .equ SWI_Print_String, 0x02
        .equ SWI_Exit, 0x11

        @.equ relacion el nombre con un numero
        @los define como ctes

        @ sección de datos - datos que el programa usará
        @indica donde colocar los bits en memoria
        .data
        @todo lo q son variables

mensaje:
        @ .asciz : string terminado en byte nulo
        .asciz "Hola Mundo"
        @existe .ascii pero eso define la cadena de caracteres pero sin el byte nulo

        @ sección de código - porción ejecutable del código
        .text

        @ hace _start disponible al linker
        @ esto es effectivamente parte de la definición del "main"
        .global _start
_start:
        @ carga el puntero al string en el registro r0
        @carga en R0 la direccion de mensaje
        ldr r0, =mensaje  
        @imprime hasta que encuentra una valor nulo

        @ solicita a ARMSim que imprima el string
        swi SWI_Print_String

        @ solicita a ARMSim que salga del programa
        swi SWI_Exit
        .end
