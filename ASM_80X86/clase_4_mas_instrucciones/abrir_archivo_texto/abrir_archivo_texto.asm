

global main

extern puts
extern fopen
extern fgets

section .data

    fileName        db      "miArchivo.txt",0
    modo            db      "r+",0 
    mensaje_error   db      "No se pudo abrir el archivo",0

section .bss

    idArchivo       resq    1 ;para guardar durante el programa el file-pointer (o handler)
    registro        resb    81 ;buffer en memoria para que cada invocacion a la funcion nos copia el contenido del archivo aca

section .text
main:
    ;apertura del archivo
    mov         rcx,fileName
    mov         rdx,modo

    sub         rsp,32
    call        fopen
    add         rsp,32

    cmp        rax,0
    jle        errorOpen

    mov         qword[idArchivo], rax ; guardo en una var en memoria el file pointer hasta que cierre el archivo
    
    ;lectura del archivo
    mov     rcx, registro ; guardamos en el 'buffer' registro el contenido del archivo (*)
    mov     rdx,200 ; Es el tamaio/longitud del archivo de texto q queremos copiar
    mov     r8,[idArchivo] ;recordar que r8 es de 8 bytes 64 bits  
    sub     rsp,32
    call    fgets
    add     rsp,32

    ; DUDA
    ;cmp rax,0 ; chequeo que el rax este en 0 o menos.xq almacena la cant de bytes efectivamente leidos
    ;jle EOF

    ;imprimo por pantalla el contenido del archivo
    mov     rcx, registro ;el contenido quedo en registro, lo vuelvo a mover a rcx
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
