global main
    ;nasm es nuestro compilador
    ;le indica al  
    ;gcc q comience por main
extern puts
    ;le aviso a nasm que puts es una etiqueta q esta afuera asi no rompe

section .data
    ;creo un campo para guaradar el contenido del mensaje
    mensaje db "Hola Mundo",0 ;concateo un 0 porque usamos funciones de C para todo
                            ;lo que son mensajes por pantallas y manejo de archivos
                            ;y perifericos
    ; al hacer db "string" resero tantos bytes como son necesarios para que entre
    ;ese string

section .bss
    ;En este programa en particular no la usaremos

section .text
main:

    ;[mensaje] campo con corchete, contenido (Hola Mundo)
    ;mensaje ,campo sin corchete, direccion del campo (Direc de memoria)
    ;cuando el parametro es un string, se carga la direccion de inicio del string
    mov rcx, mensaje
    
    sub rsp, 32 ; Solo en windows. SIEMPRE QUE INVOQUE UNA FUNCION EXTERNA SIEMPRE
    ;Sub resta al primer operando el contenido del segundo, es decir,
    ;le estoy restando al contenido del registro rsp (de pila), 32.
    ;Justificacion: las Calling conventions requieren antes de llamar un programa
    ;dde otro, reservar 32 bytes en la pila y luego revertirlo xq el programa llamador
    ;podria necesitar ese espacio. 


    ;call es una instruccion que permite invocar un subprograma, en particular,
    ;bifurca a una etiqueta que puede estar en nuestro programa o uno externo.
    call puts ; invoco a una funcion de C (put string)
    ;puts imprime un string hasta que se encuentra con un 0 (cero binario) y agrega 
    ;el caracter de fin de linea a la salida para q la sig. orden de impresion vaya
    ;al renglon de abajo

    add rsp,32 ;Solo en windows


    ;la manera de pasar parametros a una funcion en asm es con registros, asi:
    ;en windows el parametro 1, esta en el rcx, el param 2 en rdx, el 3 etc.
    ;(rcx rdx r8 r9, a partir de r9 en el STACK)
    ret
