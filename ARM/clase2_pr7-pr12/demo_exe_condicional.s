    .text
    .global _start

_start:
    mov r0, #20
    cmp r0, #5
    
    mov r1, #5  @r1 = 5
    @subs r1, r0 @r1 - r0 @ la s al final setea el bit de signo
    cmp r1, #20 @5 - 20 = r1 - 20 = -15
    @se prende el negativo xq hace 
    
    @mueve si el bit negativo   SI esta encendido ( es +)
    @si esta encendido por la cuenta ant,
    @entonces SI se ejecuta
    movmi   r1,#42  
    
    @mueve si el bit negativo no esta encendido ( es +)
    @no esta encendido por la cuenta ant,
    @entonces no se ejecuta
    movpl r2, #87

    swi 0x11
    .end
 