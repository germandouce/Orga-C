global main
extern puts

section .data
    mensaje     db  "Hola Intel en Windowssssssssssss",0

section .text
main:

    mov     rcx,mensaje
    sub     rsp,32
    call    puts
    add     rsp,32

    ret