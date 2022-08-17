

global main

extern puts
extern fopen
extern fgets
extern fread

section .data

    fileName        db      "miArchivo.dat",0
    modo            db      "rb",0 ; Read Binary
    mensaje_error   db      "No se pudo abrir el archivo",0

section .bss

    idArchivo       resq    1 ;para guardar durante el programa el file-pointer (o handler)
    registro        times   0 resb  22 ;22 son los bytes que van a ocupar los siguientes campos del registro
    ; disenia una etiqueta de una estructura para poder identificar los campos de las variables
    ; es una especie de destruct
    id              resw    1 ;2 bytes + 
    nombre          resb    20 ; 20 bytes = 22 bytes

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

    mov        qword[idArchivo], rax ; guardo en una var en memoria el file pointer hasta que cierre el archivo
    
    ; NO FUNCIONAAAAAAAA!!!!
    ;lectura del archivo
    mov     rcx, registro
    mov     rdx,22 ;cantidad de bytes que levanta el archivo. 
    ;En gral se pone lo que reserve de mem en archivo
    mov     r8,1 ;cant de bloques que quiero leer. podria poner 10 bloques de 22 bytes.
    ;En ese caso registro deberia tener un tamaio de 22*10 = 220. Si levanto bloques,
    ;uno esta levantando un array de registros.
    ;todo lo q levanto se vuelca en la var registro. En gral vamos a estar hardcodeando 1 xq queremos leer secuencial//
    mov     r9,[idArchivo] ;el file pointer va en r9
    
    sub     rsp,32
    call    fread
    add     rsp,32

    mov     rcx, registro ;el contenido quedo en registro, lo vuelvo a mover a rcx
    ;DUDA
    ;mov     rcx, id ;imprime todo no se xq
    ;mov     rcx, nombre ;imprime a partir del 3er byte
    
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
