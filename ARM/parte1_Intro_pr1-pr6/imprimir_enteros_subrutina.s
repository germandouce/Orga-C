	.equ SWI_Print_Int, 0x6B
    .equ SWI_Print_Str, 0x02
    .equ SWI_Exit, 0x11

    .data
cadena: 
    .asciz "linea"
eol:
    .asciz "EOL"

entero:
    .word 78

    .text

    .global _start

_start:
    @comentario
    bl  print_r1_int 
    b   fin


print_r1_int:
    stmfd sp! , {r0,lr} @stack R0. 
    mov     r1,#7
    mov     r0,#1
    @Guarda lo q hay en el R0 y en el lr
    @en el primer lugar del stack esta el r0, en el; segundo lr (una pila comun y corrientee)
    @ldr r0, #0x01 @ldr = load resgister. Guardo un 1 en r0
    swi SWI_Print_Int @ para mostrar entero en R1 por consola
    @ldr r0, =eol
    @swi SWI_Print_Str @Mostrar EOL por consola
    ldmfd sp!, {r0,pc} @Unstack
    @r0 vuelve a valer lo q valia al ppio
    @ahora el lr vale lo q valia el pc. Entonces vuelvo bien a donde estaba

fin:    
	swi SWI_Exit
    .end