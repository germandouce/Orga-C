@ [2 puntos] Codificar un programa en assembler ARM de 32 bits que 
@recorra un vector de enteros y los imprima por la salida estándar agregando 
@ la leyenda “PAR” a continuación de todos aquellos que así lo sean

    .equ SWI_Print_Int, 0x6B
    .equ SWI_Print_Str, 0x69
    .equ SWI_Exit, 0x11
    .equ Stdout, 1

    .data

array_origen:
    .word 1,2,5,6,132

array_length:
    .word 5

par:
    .asciz " PAR"

impar:
    .asciz " IMPAR"

eol:
    .asciz "\n"

    .text
    .global _start

_start:
    ldr r0, =array_origen
    ldr r2, =array_length
    ldr r2, [r2] @r2 = long

loop:
    ldr r4,[r0] @r4 = ele del array
    bl imprimir
avanzar_en_array:
    add r0, r0, #4
    sub r2, r2, #1
    cmp r2,#0
    bne loop
    b   fin

imprimir:
    STMFD   sp!, {r0,r1,lr}
    ldr     r0,=Stdout
    mov     r1,r4         @r1 = num a imprimir
    SWI     SWI_Print_Int @ lo imprimo siempre
    and     r5,r4, #1  @r5 = num and 1 (en bpf, bit a bit)
    @hago AND entre el numero en r4 y un 1 en en bpf
    @1[10] = 0000 0001 en bpf
    @2[10] = 0000 0010 
	@3[10] = 0000 0011 
    @si el ult bit de un de un numero es 0, es par, si
    @es 1 es impar. x eso al hacer and con 1, 
    @se si es impar (1and 1 = 1) o par (1 and 0 =0)
    @r5 = 0000 0001 (es impar)
    @r5 = 0000 0000 = 0[10] (si es impar)
    cmp     r5, #0
    bne     es_impar
    @Si es cero (par) primero imprimo la lyenda par
    ldr     r1,=par
    SWI     SWI_Print_Str
    b       salto_de_linea
    @si es impar salteo lo anterior e imprimo un salto de linea
    es_impar:
    ldr     r1,=impar
    SWI     SWI_Print_Str

    salto_de_linea:
    ldr     r1,=eol
    SWI     SWI_Print_Str
    LDMFD   sp!, {r0, r1,pc} @pc = lr

fin:
    SWI SWI_Exit
    .end
