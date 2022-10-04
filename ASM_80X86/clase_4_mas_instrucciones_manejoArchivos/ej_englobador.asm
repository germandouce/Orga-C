; Dado un archivo en formato BINARIO que contiene informacion sobre autos llamado listado.dat
; donde cada REGISTRO del archivo representa informacion de un auto con los campos: 
;   marca:							10 caracteres
;   año de fabricacion:				4 caracteres
;   patente:						7 caracteres
;	precio							7 caracteres
; Se pide codificar un programa en assembler intel que lea cada registro del archivo listado y guarde
; en un nuevo archivo en formato binario llamado seleccionados.dat las patentes y el precio (en bpfc/s) de aquellos autos
; cuyo año de fabricación esté entre 2010 y 2020 inclusive
; Como los datos del archivo pueden ser incorrectos, se deberan validar mediante una rutina interna.
; Se deberá validar Marca (que sea Fiat, Ford, Chevrolet o Peugeot), año (que sea un valor
; numérico y que cumpla la condicion indicada del rango) y precio que sea un valor numerico.

global main
extern puts
extern printf
extern fopen
extern fclose
extern fread
extern sscanf
extern fwrite

section .data
    debug               db      "debug",0

    fileListado         db      "listado.dat",0
    modeListado         db      "rb", 0     ; read | binario | abrir o error
    msjErrorOpenLis     db      "Error en apertura de archivo Listado",0
    handleListado       dq       0 ;define quoter
    msjAperturaOk       db      "se abrio corretamente el listado",0

    fileSeleccion       db      "seleccionados.dat",0
    modeSeleccion       db      "wb",0
    msjErrorOpenSel     db      "Error en apertura de archivo seleccion",0
    msjEscrituraOk      db      "se escribio el archivo seleccion",0
    handleSeleccion     dq      0 ;Al ser archivo binario tenemos q definir un registro (como un struct en C)
    ; en este ejercicio, tengo q leer 4 campos (marca, anio, patente y precio) (total 28 chars, 28 bytes), tonces...
    ;idArchivo = handle

    regListado          times   0   db  "" ;longitud total del resgistro: 28 
        marca           times   10  db  " "
        anio            times   4   db  " "
        patente         times   7   db  " "
        precio          times   7   db  " " ;Lo leo en formato de caracteres
        ;este registro se va a llenar al llamar fread
    ;y necesito otra estructura xa el archivo q voy a escribir. 
    ;son 2 campos. patente y precio(en bpf c/s de 4 bytes)

    regSeleccion        times   0   db  "" ;11 bytes en total
        patenteSel      times   7   db  " " ; 7 bytes
        precioSel                   dd  0   ;tengo q escribir el precio en (BPF C/s)
        ; double word (4 bytes ) con contenido inicial de 0

    ;Lo leo asi...
    precioStr                       db  "*******",0 ; meto 7 caracteres clqr porque dsps lo voy a pisar con el precio
    ;y lo paso con scanf pasandole el formato...
    precioFormat                    db  "%d",0 ; "%i",0 ;32 bits (double word)

    ;se podria usar el precio tal como viene pero al profe le parece mas organizado crear la variable precioStr
    ;xa no alterar el registro leido 

    ;TABLA DE VALIDACION DE MARCA. 
    ;Observar que como la marca viene como 10 caracteres dejo espacio h/ llegar a 10!
    vecMarcas           db  "Ford      "
                        db  "Chevrolet "
                        db  "Peugot    "
                        db  "Fiat      ",0

    ;VALIDADOR DEL ANIO
    anioStr             db  "****",0 ; 4 caracteres como el anio
    anioFormat          db  "%hi",0 ; xa leer el anio con scanf 16 bits (word)
    ;anioStr             db  "********" ; si x ejemplo quisiera convertir 2 nums 
    ;anioFormat          db  "%hi %hii"; en a bpf
    ; y en este caso me fijo si el rax es = a 2, xq se convirtieron 2 parametros bien!
    anioNum             dw  0     ;16 bits (word)

    charFormat		db "%c",10,0


section .bss

    registroValido     resb    1   ;S si es valido N si no
    datoValido         resb    1   ;para guaradar temporalmente los campos validados 

section .text
main:
    ;primero abrimos el archivo listado
    mov         rcx,fileListado ;en RCX fileName
    mov         rdx,modeListado ; RDX el modo

    sub         rsp,32
    call        fopen
    add         rsp,32

    cmp         rax,0 ; en RAX queda el handle / IdArchivo, el puntero
    jle         errorOpenLis

    mov         qword[handleListado],rax ; copiamos el handle al rax
    
    mov		rcx,msjAperturaOk
    sub		rsp,32
    call	puts
    add		rsp,32

    ;abrimos el archivo seleccion donde guaradamos lo q c pide
    mov         rcx,fileSeleccion ;en RCX fileName
    mov         rdx,modeSeleccion ; RDX el modo

    sub         rsp,32
    call        fopen
    add         rsp,32

    cmp         rax,0 ; en RAX queda el handle / IdArchivo, el puntero
    jle         errorOpenSel

    mov         qword[handleSeleccion],rax ; copiamos el hanle al rax

    ;si llegue aca es q abir bien los 2 archivos
    ;proceo registros del archivo listado

leerRegistro:
;
;    mov         rcx,regListado ; 1) buffer del q leo el archivo binario
 ;   mov         rdx, 28 ; 2) cant de bytes xa cada fread
   ; mov         r8,1 ;3) cantidad de registros
 ;   ;Es solo un regsitro. Leo registro, por registro, 1 a la vez. 1 solo bloque
    ;mov         r9,[handleListado] ; 4) handle del archivo
;
    
    ;dsps del fread podemos ver cuantos bytes leyo y determinar si se leyo bien
 ;   sub         rsp,32
  ;  call        fread
   ; add         rsp,32
    mov     rcx,regListado
    mov     rdx,28           
    mov     r8,1
	mov		r9,[handleListado] 
    sub		rsp,32  
	call    fread
	add		rsp,32
    ;devuelve en el rax el handler
    cmp         rax,0
    jle         closeFiles

    
    ;Cierro el archivo cuando se leyo todo (eof, 0 en rax)

    call        validarRegistro

    ;RECOMIENDAN HACERLO DSPS DEL RETURN DEL PROGRAM PPAL 
    ;XA Q NO SE EJECUTE ACCICENTALMENTE DENTRO DEL MISO PROGRAMA

    ;cada invocacion a esa rutina nos devuelve una letra s o 1 en la variable resgistroValido 
    cmp         byte[registroValido], "N"
    je          leerRegistro
    ;salto a antes de empezar con la fread, xq voy a leer otro resgitstro. 
    ;Si no es valido lo salteo y me muevo al siguiente
    ;si es valido es q lei el registro y paso las validaciones -> grabo registro en archivo de salida
    ;contiene 2 campos, patente y precio

    ;copio patente al campo del resgistro del archivo xa hacer la escritura
    

    mov         rcx, 7 ;  la cant de bytes q usa movsb ( la patente)
    mov         rsi, patente;direc inical del campo de origen que queremos copiar 
    ;copio los 7 bytes de patente a patenteSel, la q quiero escribir
    ;lea        rsi, [patente] ; low efective adress CORCHETESS
    ;lea        rdi,[patenteSel]
    mov         rdi, patenteSel 
    rep         movsb 

    ;Copio campo precio precio a campo precioStr xa transformar en bpf c/s
    mov         rcx, 7 ;  la cant de bytes q usa movsb ( la patente)
    mov         rsi, precio;direc inical del campo de origen que queremos copiar 
    ;copio los 7 bytes de precio a patenteSel, la q quiero escribir
    mov         rdi, precioStr ;primero lo guardo temporalmente en string y luego lo parseo
    rep         movsb

    mov         rcx, precioStr ;lo parseo a BPF C/s de 32 bits
    mov         rsi, precioFormat
    mov         r8, precioSel ; en la var q dsps se copia al archivo
    
    sub         rsp,32
    call        sscanf
    add         rsp,32
    ;no necesito validar de nuevo xq ya valide antes

    ;Guardo registro en archivo Selecccion

    ;xa escirbir el resgistro en el archivo binario frwrite
    mov         rcx,regSeleccion            ;1) Bufeer para escribir el archivo
    mov         rdx,11                      ;2) Longitud TOTAL del registro (suma de todos los campos)
    mov         r8,1                        ;3) Cantidad de registros a escribir
    mov         r9,qword[handleSeleccion]   ;4) Hadle del arhivo o id

    sub         rsp,32
    call        fwrite
    add         rsp,32


    jmp         leerRegistro ; salto a leer y escribir otro registro. esto hasta q llega al eof


errorOpenLis:
    mov     rcx,msjErrorOpenLis
    sub     rsp,32
    call    puts
    add     rsp,32
    jmp     endProg

errorOpenSel:
    mov     rcx,msjErrorOpenSel
    sub     rsp,32
    call    puts
    add     rsp,32

    jmp     closeFileListado

closeFiles:

    mov     rcx,qword[handleSeleccion]
    sub     rsp,32
    call    fclose
    add     rsp,32


closeFileListado:

    mov     rcx,qword[handleListado]
    sub     rsp,32
    call    fclose
    add     rsp,32

    mov		rcx,msjEscrituraOk
    sub		rsp,32
    call	puts
    add		rsp,32

    ;obs q no se salta a endProg xq quiero cerrar el q abri

endProg:
    ret

;------------------------------------------------
;RUTINAS INTERNAS -> MALA PRACTICA PONERLAS EN EL MEDIO DEL PROGRAMA, ANTES DEL EndProg
;------------------------------------------------

validarRegistro:

    mov     byte[registroValido], "N" 
    ;voy a usar 3 rutinas internas, con cada una valido una cosa distinta

    call    validarMarca
    cmp     byte[datoValido],"N"
    jle     finValidarRgistro

    call    validarAnio 
    cmp     byte[datoValido],"N"
    jle     finValidarRgistro

    call    validarPrecio
    cmp     byte[datoValido],"N"
    jle     finValidarRgistro

    ;si llegue aca el regsistro es valido, cambio cond de corte

    mov     byte[registroValido], "S" 


finValidarRgistro:
    ret

;---------------------------
;VALIDAR MARCA
validarMarca:
;validacion por tabla (una secuecia de valores posibles! si fuera un solo valor seria por valor)
;defino una tabla y voy moviendo para ver si el campo marca o no
    mov     byte[datoValido], "S" 

    mov     rbx,0 ; inicializo un indice en 0. y dsps lo voy aumentando
    mov     rcx,4 ;almaceno el nuemero de vueltas q quiero dar

    nextMarca:
        push    rcx, ;apilo momentaneamente el 4 en la pila
        ;otra ocion era definir una quoterWord (= tam q rcx, 64 bits) en la .bss y cargarle momentaneamente el 4 
        mov     rcx,10 ;xq voy a comparar 10 bytes
        lea     rsi,[marca];apunto el registro rsi a la direc inicial del campo en memoria q voy a estar comparando, la marca
        ;mov    rsi,marca ;sin corchetess
        lea     rdi,[vecMarcas + rbx];apunto el rdi destino a la tabla de marcas y un indice xa ir comparando
        ;mov    rsi,vec+rbx ;nooooo! <- no ensamblaa
        repe    cmpsb   ; PERMITE COMPARAR MEMORIA A MEMORIA
        pop     rcx ;desapilo el 4

        je      marcaOk;chequeo si la marca es valida
        ;si la marca no es la primera de la lista, aumento el rbx
        add     rbx,10 ;10 caracteres = 10 bytes xq asi era la tabla de marca
    loop    nextMarca ;si no llego a 0 bifurca a ese rotulo
    ; tambien usa el registro rcx x eso neceusto el pop y push

    mov     byte[datoValido], "N" 

    marcaOk:
    mov	rdx,[datoValido]
    call printf_char
    ret

;---------------------------
;VALIDAR ANIO
validarAnio:

;puedo usae sscanf, q inentara tranformar los caracter a un campo de salida en binario y dejara en
;rax el resultado de la conversion ( 1 o 0 )
    mov     byte[datoValido], "N" ;asumo no vailido

    ;copio el anio leido al campo anioStr.  
    mov     rcx,4   ;copio 4 bytes
    mov     rsi,anio ;apunto rsi a la direc origen de donde q quiero copiar
    mov     rdi,anioStr ;rdi a la de destino a copiar
    rep     movsb    

    mov     rcx,anioStr ;done tengo la cadena
    mov     rdx,anioFormat ;formato al q quiero convertir
    mov     r8,anioNum ;(2do param)
    sub     rsp,32
    call    sscanf
    add     rsp,32
    
    cmp     rax,1 ; (2) xa ver si convirio bien el (0 los numeros) numero 
    jl      anioError ;el anio no es numerico xq hay alguna letra o char especial


    ;me falta la validacion por rango de consigna
    ;verifico si el anio eta comprendido en el rango 2010 - 2020
    
    cmp     word[anioNum],2010
    jl      anioError ; si es igual a 2010
    cmp     word[anioNum],2020
    jg      anioError ; o igual a 2020 NO DESCARTO


    mov     byte[datoValido], "S" 

    anioError:
    mov	rdx,[datoValido]
    call printf_char
    ret

;---------------------------
;VALIDAR ANIO
validarPrecio:
;el precio esta formado por 7 caracteres, Suponemos precio es entero
;puedo usar scanf para chequear q sea numerico 
;recorrer byte x byte y compare x rango q no sea entre 0's y 9
        mov     byte[datoValido], "N" 
        mov     rcx,7 ;longitud del campo "precio", voy iterar 7 veces
        mov     rbx,0 ; indice xa iterar la estructura

nextDigitoP:
        cmp     byte[precio + rbx],"0"; compro precio <- '1', inmediato: '0'. 
        ;jump es una instruccion sobre aritmetica sin signo. entonces interpreta restas de codigos asciis
        ; Como 1 esta dsps en ascii que el 0 no me va a dar ni 0 ni negativo. 
        jl      precioError
        cmp     byte[precio + rbx],"9";
        jg      precioError

        ;este precio con el trabajamos es el mimso precio que leimos del registro
        ;precio times 7 db "". este se carga con fread de leer registro 
        inc     rbx
        ;add     rbx,1
    loop        nextDigitoP

    mov     byte[datoValido], "S" 

    precioError:
    mov	rdx,[datoValido]
    call printf_char
    ret

;------------------------------------------------------
;PRINTF_CHAR
printf_char:
	mov		rcx,charFormat	;PRIMER PARAMETRO DE printf. El segundo se carga afuera en rsi
	sub		rsp,32
	call	printf
	add		rsp,32
ret
