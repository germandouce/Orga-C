.text

mov     r0,#5
mov     r1,#7
add     r2, r2,r1 @ r2 = 12

mov     r1,r2   @r1: entero a imprimir = 12
mov     r0,#1   @r0 = 1 significa donde lo imprimo, por pantalla
swi     0x6b    @0x6b imprimir entero

swi     0x11    @0x11: salir del programa
@no lleva parametros

    .end    
