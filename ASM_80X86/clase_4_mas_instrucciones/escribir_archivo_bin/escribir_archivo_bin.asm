

global main

extern puts
extern fopen
extern fclose
extern fwrite

section .data

    fileName        db      "miArchivo.dat",0
    modo            db      "wb+",0 ; write Binary
    mensaje_error_apertura   db      "No se pudo abrir el archivo",0 ;deberia ser dos disntintas es solo de prueba
    mensaje_error_cierre   db      "No se pudo cerrar el archivo",0 ;deberia ser dos disntintas es solo de prueba
    mensaje_bien_cerrado   db   "se cerro y guardo correctamente el archivo",0


    registro        times   0   db  "" ;es una especie de struct
    id              dw      2020 ; 1 byte +
    mes             db      "ENE" ;4 bytes

section .bss

    idArchivo       resq    1 ;para guardar durante el programa el file-pointer (o handler)   

section .text
main:
    ;apertura del archivo
    mov         rcx,fileName
    mov         rdx,modo

    sub         rsp,32
    call        fopen
    add         rsp,32

    cmp        rax,0
    jle         errorOpen

    mov        qword[idArchivo], rax ; guardo en una var en memoria el file pointer hasta que cierre el archivo
    
    ;lectura del archivo
    mov     rcx, registro
    ;DUDA
    ;mov     rcx, id ;escribe todo no se xq
    ;mov     rcx, nombre ;imprime a partir del 3er byte
    mov     rdx,5 ;cantidad de bytes que levanta el archivo. (tantos como quiero escribir en gral)
    mov     r8,1 ;cant de bloques que quiero leer. podria poner 10 bloques de 22 bytes.
    mov     r9,[idArchivo] ;el file pointer va en r9
    
    sub     rsp,32
    call    fwrite
    add     rsp,32

    ;cierre del archivo
    mov rcx,[idArchivo];
    sub     rsp,32
    call    fclose; devuelve cero si cerro bien el stream
    add     rsp,32

    cmp rax,0 ; 
    jne  error_cierre ; si no es cero

    mov     rcx,mensaje_bien_cerrado
    sub     rsp,32
    call    puts
    add     rsp,32

    ret

error_cierre:
    mov     rcx,mensaje_error_cierre
    sub     rsp,32
    call    puts
    add     rsp,32

errorOpen:
    mov     rcx,mensaje_error_apertura
    sub     rsp,32
    call    puts
    add     rsp,32
    
    ret
