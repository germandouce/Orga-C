global main

extern puts
extern fopen
extern fgets
extern fputs
extern fclose

section .data

    fileName                db      "miArchivo.txt",0
    modo                    db      "w+",0  ; reescritua - cada vez q abro vuelve al inicio. o creacion.
    linea                   db      "escribo esto: 9557/7503",0 ;linea que quiero escribir en el archivo
    mensaje_error           db      "No se pudo abrir/cerrar el archivo",0
    mensaje_mal_escrito     db      "No se pudo escribir correctamente el archivo",0
    mensaje_bien_escrito    db      "se escribio correctamente el archivo",0
    mensaje_correcto_cierre db      "se cerro bien el archivo",0
    debug                   db      "debug"

section .bss

    idArchivo       resq    1 ;para guardar durante el programa el file-pointer (o handler)
    registro        resb    81 ;buffer en memoria para que cada invocacion a la funcion nos copia el contenido del archivo aca

section .text
main:

    call    apertura

    call    escritura

    call    cierre

ret

apertura:
    ;apertura del archivo
    mov         rcx,fileName
    mov         rdx,modo

    sub         rsp,32
    call        fopen
    add         rsp,32

    cmp        rax,0
    jle        errorOpen

    mov         qword[idArchivo], rax ; guardo en una var en memoria el file pointer hasta que cierre el archivo
    
    ret

escritura:
    ;escritura del archivo
    mov     rcx, linea ;escribo la linea linea en el archivo
    mov     rdx,[idArchivo] ;recordar que r8 es de 8 bytes 64 bits  
    sub     rsp,32
    call    fputs; ya con esto escribe
    add     rsp,32

    ;DUDA
    cmp     rax,0 ;retorna 0 si es eof, negativo en caso de error
    jne     eof ; no se pudo escribir bien ya sea xq no escribio todos loss chars o dio error (negativo)

    mov     rcx,mensaje_bien_escrito
    sub     rsp,32
    call    puts
    add     rsp,32

    ret


cierre:

    ;debug
    mov     rcx, debug
    sub     rsp,32
    call    puts; 
    add     rsp,32

    ;cierre posta
    mov rcx,[idArchivo];
    sub     rsp,32
    call    fclose; 
    add     rsp,32

    ;chequeo q se haya cerrado bien
    cmp     rax,0 ;retorna 0 si se leyo bien. o negativo en caso de error o positivo si no se cerro completo
    jne     eof ;mensaje de error

    mov     rcx, mensaje_correcto_cierre
    sub     rsp,32
    call    puts
    add     rsp,32

    ret

errorOpen:
    mov     rcx,mensaje_error
    sub     rsp,32
    call    puts
    add     rsp,32
    
    ret

eof:
    mov     rcx,mensaje_mal_escrito 
    sub     rsp,32
    call    puts
    add     rsp,32

    ret