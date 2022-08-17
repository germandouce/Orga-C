

global main

extern puts
extern fopen

section .data

    fileName        db      "Miarchivo.txt",0
    modo            db      "r+",0 
    mensaje_error   db      "No se pudo abrir el archivo",0

section .bss

    idArchivo   resq    1 ;para guardar durante el programa el file-pointer (o handler)

section .text
main:
    mov         rcx,fileName
    mov         rdx,modo

    sub         rsp,32
    call        fopen
    add         rsp,32

    cmp        rax,0
    jle        errorOpen

    mov         qword[idArchivo], rax ; guardo en una var en memoria el file pointer hasta que cierre el archivo
    
    ;asi no se lee. hay q usar fgets. corto y lo sigo tomorrow
    ;mov     rcx,[idArchivo]
    ;sub     rsp,32
    ;call    puts
    ;add     rsp,32

    ret

errorOpen:
    mov     rcx,mensaje_error
    sub     rsp,32
    call    puts
    add     rsp,32
    
    ret
