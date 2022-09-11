global main

extern puts
extern fopen
extern fgets
extern fputs
extern printf
extern fclose
extern fread
extern fwrite


section .data

    fileName                db      "miArchivo.dat",0
    modo                    db      "r+",0  ;reescribe o crea si no existe, r (lee) ,
    ;r+: Opens file in r & w mode. File pointer starts at BEGINNING of the file.
    ;w+: Opens file in r & w mode. Creates a new file if it does not exist, 
    ;    if it exists, it ERASES CONTENT and the file pointer starts from the BEGINNING
    
    registro_write		times 	0	db	"" ;vacio DUDA XQ???
							        dw	9557	;Se guarda en LITTLE ENDIAN BB08 en memoria y cuando se copia en el archivo
								    db	"Computador",0

    registro_read   times 	0 	db ""
	id				dw 		0
	nombre			times 	10	db " ",0
    
    linea                   db      "9557 Orga",0 ;linea que quiero escribir en el archivo
    mensaje_error_open      db      "No se pudo abrir el archivo",0
    mensaje_error_read      db      "No se pudo leer el archivo o esta vacio",0
    mensaje_error_close     db      "Ocurrio un problema al intentar cerrar el archivo",0
    mensaje_mal_escrito     db      "No se pudo escribir correctamente el archivo",0
    mensaje_bien_escrito    db      "se escribio correctamente el archivo",0
    mensaje_correcto_cierre db      "se cerro bien el archivo",0
    mensaje_lectura         db      "%4i|%s",10,13,0 ; el %"numero" es la cantidad de digitos!!
    ;REVISAR ARCHIVO DE VARIAS LINEAS!! SON VARUIOS REGISTROS???

section .bss

    idArchivo           resq    1 ; para guardar el file-pointer (o handler)

    apertura_correcta   resb    1; "S" si se abre bien "N", en caso contrario

section .text
main:

    ;sub		rsp,40

    call    apertura

    cmp     word[apertura_correcta],"S" ;s abrio bien? 
    je      cierre ;solo cierro el archivo si efectivamente se abrio

ret

apertura:
    ;apertura del archivo de texto: 
    ;fopen (    RCX     ,   RDX     ,           RAX                )
    ;fopen (  fileName  ,   modo    , CantDeBytesLeidos/CodigoError  )
    mov         rcx,fileName ;en RCX fileName
    mov         rdx,modo ; RDX el modo

    sub         rsp,32
    call        fopen
    add         rsp,32

    cmp         rax,0 ; en RAX queda el handle / IdArchivo, el puntero
    jg          lectura
    mov         word[apertura_correcta],"N"
    jmp         error_open ;error si es 0 (no leyo nada) o < 0 (error)

    ret

lectura:
    ;lectura del archivo
    ;fgets (    RCX                     ,     RDX      ,     R8              ,    R9      )
    ;fgets ( registro(contenidoArchivo) ,  BytesALeer  ,  Cant d bloques leer, FilePointer)
    mov         word[apertura_correcta],"S"
    
    mov     qword[idArchivo], rax ; guardo en una var en memoria el FilePointer hasta que cierre el archivo

    mov     rcx, registro_read ; ;Parametro 1: dir area de memoria con datos a copiar
    mov     rdx,12 ;Parametro 2: longitud del registro
    mov     r8,1 ;Parametro 3: cantidad de registros
    ;REVISAR ARCHIVO DE VARIAS LINEAS!! SON VARUIOS REGISTROS???
    mov     r9,[idArchivo] ; Parametro 4: handle del archivo
    sub     rsp,32
    call    fread ;LEO registro. Devuelve en rax la cantidad de bytes leidos
    add     rsp,32

    ;DUDA
    cmp    rax,0   ;En RAX queda CANTIDAD TOTAL DE BLOQUES LEIDOS 
    jle    escritura   ;<= a 0, esta ok. Se puede escribir porque llego al EOF.
    ;porque estaba vacio ( 0 bytes leidos)
    ;Si no llego al EOF, devuelve el handle y entonces continua...
    ;imprimo por pantalla el contenido del archivo. OJO VER MODE. W+ deletes the content !

    ;imprimo el registro en pantalla    
    mov         rcx, mensaje_lectura ;Parametro 1: dir del texto a imprimir por pantalla
    sub         rdx,rdx ;dx es de 16 bits? para llenar de ceros y q no falle xq el numero decimal no es de 64 bits?
    mov         dx,[id] ;Parametro 2: dato a ser formateado como numero entero decimal
    mov		    r8,nombre ;Parametro 3: dir dato a ser formateado como string
    sub         rsp,32
    call        printf
    add         rsp,32

    ;no se como hacer para sobreescribir o agregar al final con r+ asi q 
    ;si habia algo escrito, imrpimo y corto el programa
    
    ret

escritura:
    ;escritura del archivo de texto  
    ;fputs  (       RCX                 ,        RDX      ,           RAX)
    ;fputs  ( BytesApuntadosPorLinea    ,   filePointer   ,           RAX)
    
    mov     rcx, registro_write ;Parametro 1: dir area de memoria con datos a copiar
    mov     rdx,12
    mov     r8,1
    mov     r9,[idArchivo] ;Parametro 2: longitud del registro
    sub     rsp,32
    call    fwrite; ya con esto escribe
    add     rsp,32

    ;DUDA
    cmp     rax,0 ; fwrote retorna  eof (-1) en caso de error, > 0 if it was successfully executed (????)
    ;jl      eof
    jle     eof ; hice pruebas y llegue a la conclusion, de q al escribir BIEN devuelve 0 (cero)

    mov     rcx,mensaje_bien_escrito
    sub     rsp,32
    call    puts
    add     rsp,32

    ret

cierre:
    
    ;cierre del archivo
    ;fclose (   RCX             ;       RDX    ;    RAX                 )
    ;fclose (   FilePointer     ;               ;    Codigo de error    )

    mov     rcx,[idArchivo] ;
    sub     rsp,32
    call    fclose; 
    add     rsp,32

    ;chequeo q se haya cerrado bien
    cmp     rax,0 ;retorna 0 on succes, (EOF = -1) < 0 en caso de error, > 0 si no se cerro completo(??).
    jne     error_close ;mensaje de error

    mov     rcx, mensaje_correcto_cierre ;
    sub     rsp,32 ; 
    call    puts
    add     rsp,32

    ;add		rsp,40

    ret

error_open:
    mov     rcx,mensaje_error_open
    sub     rsp,32
    call    puts
    add     rsp,32
    
    ret

error_read:
    mov     rcx,mensaje_error_read
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

error_close:
    mov     rcx, mensaje_error_close
    sub     rsp,32
    call    puts
    add     rsp,32
    
    ret