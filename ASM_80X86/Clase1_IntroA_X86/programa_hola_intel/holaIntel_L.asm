global main
extern puts

section .data
    mensaje     db  "Hola Intel en Linux",0

section .text
main:

    mov     rdi,mensaje
    call    puts

    ret