; casi siempre se usan
global 	main
extern puts
extern 	printf
extern	gets
extern 	sscanf
extern	fopen
extern	fread
extern	fclose

;____________________secciones___________________
section .data

section .bss

section .text 
main: 


;__________________Abrir archivo___________________

    call	abrirArhivo

	cmp		qword[handle],0				;Error en apertura?
	jle		errorOpen

	call	leerArchivo
	call	#operacionConPedidoAlUsuario
    
    ;jmp     endProg

errorOpen:
    mov		rcx, msgErrOpen
	sub		rsp,32
	call	printf
	add		rsp,32

endProg:

	ret ;esat ret finaliza el programa


;Abro archivo para lectura
abrirArchivo:
    
    mov		rcx, #nombreArchivo	    ;Parametro 1: dir nombre del archivo
    mov		rdx, #modoApertura				;Parametro 2: dir string modo de apertura
    sub		rsp,32
    call	fopen					;ABRE el archivo y deja el handle en RAX
    add		rsp,32

    mov		qword[#nombreArchivoHandle],rax ; lo dejamos en fileHandle

    ret


leerArchivo:

    ;______________Leer registro binario_____________
    leerRegistro:

            mov		rcx,registro		    ;Parametro 1: dir area de memoria donde se copia
            mov		rdx, 23     				  ;Parametro 2: longitud del registro
            mov		r8,1						  ;Parametro 3: cantidad de registros
            mov		r9,qword[#nombreArchivoHandle] ;Parametro 4: handle del archivo
            sub		rsp,32
            call	fread						;LEO registro. Devuelve en rax la cantidad de bytes leidos
            add		rsp,32

            cmp		rax,0				        ;Fin de archivo?
            jle		eof                  ;salto cuando en el rax hay 0, osea fread llego a eof

            call    #VAL_CONSIGNA    ;VALIDACIONES

            cmp		byte[RegEsValido],'S'
            jne		leerReg ;para que no llegue al eof. Iteri hasta el ult rotulo
            
            ;el regsitro es valido...
            ;#OJO EN ESTE ESPACIO VA LA LLAMADA A LA RUTINA QUE AGARRA EL REGISTRO Y LO PROCESA 
            ;Luego se salta al siguiente registro

            ; Actualizar la actividad leida del archivo en la matriz
            call	#operacionConMatrizDada

        jmp		leerReg ;Leo el prox registro


    ;________________CloseFiles___________________________
    eof:
        ;cierro archivos    
        mov     rcx,qword[#nombreArchivoHandle] ;# OJO dejar solo handle..?
        sub     rsp,32
        call    fclose
        add     rsp,32

    ret ;finalizo rutina leerArchivo


;___________________VALIDACIONES_________________________
VAL_CONSIGNA:

    ;_______Validacion por TABLA de #dato_1_AValidar_______
    mov     rbx,0   ;Utilizo rbx como puntero al vector #tablaDeValidacion
    mov     rcx,7   ;Longitud de vector #tablaDeValidacion. Para la loop
    
    ;vale usar una variable x, ej columna
    ;mov     [diaReal],1
    
    mov     rax,0   ;#ConteoDias dato convertido en num bin. Arranca en 0 

    compDatoAValidar:

            ;inc     byte[diaReal] ;sumo 1 a la columna xa moverme a la sig en la matriz
            ;#ConteoDias
            inc     rax ; sumo 1 al dato convertido en binario (ver datoAValidarPorTablaEsValido)
            ;para moverme de columna en el vector q venia en chars. Sig dia

            ;push    rcx,2 
            mov		qword[contadorTransitorioRcx],rcx	;Resguardo el rcx en un contador porque se va usar para cmpsb
            
            ;para CMPSB
            mov     rcx,2                               ;1) bytes de #dato_1_AValidar
            lea     rsi,[#datoAValidarPorTabla]         ;2) #dia origen -> rsi
            lea     rdi,[#tablaDeValidacion + rbx]      ;3) #tabla de dias destino -> rdi
            repe    cmpsb                               ;funciona con 3 registros
            
            mov		rcx,qword[contadorTransitorioRcx]			;Recupero el rcx para el loop
            ;pop     rcx,2

            je      #datoAValidarPorTablaEsValido
            add		rbx,2	    ;Avanzo en el vector #tablaDeValidacion el tam de datoAValidarPorTabla
        
        loop    #compDatoAValidar

        ;fin ciclo iteraciones de valores del vector #tablaDeValidacion
	    jmp     invalido

    ;_______Validacion por RANGO de #dato_2_AValidar_______
    datoAValidarPorTablaEsValido
        
        ;solo el dia era valido,
        
        ;#
        ;si use una variable antes... #diaReal
        ;No necesito la prox instr
        ;#conteoDias
        mov		byte[datoBin],al	;Paso el dia en binario a una variable [datoBin]
        ;uso el al porque es solo 1 byte el dia e bpf. El conteo lo hago yo a mano!

        cmp		byte[#datoAValidarPorRango],1
        jl		invalido
        cmp		byte[#datoAValidarPorRango],6
        jg		invalido

    valido:
        
        ;#OJO EN MINUSCULAAA
	    
        mov		byte[RegEsValido],'S'			;Devuelve S en la variable esValid si es un reg válido
        jmp		finValidar

    invalido:
        mov		byte[RegEsValido],"N"			;Coloco "N" en la variable RegEsValido si no es un reg valido    

    finValidar:
	    ret

operacionConMatrizDada:
    ;El problema en este ejercicio es q en las columnas no tengo numeros de dias sino
    ;dias con characteres Lu Ma etc, y necesito un valor numerico!
    ;Aprovecho el loop de validacion para convertir

    ; deplazamiento de una #matrizDada
	; (col - 1) * L + (fil - 1) * L * cant. cols
	; [Deplaz. Cols] + [Desplaz. Filas]

    mov		rax,0
	mov		rbx,0   ; x las dudas de q el rbx tenga basura

    ;__Desplazamiento en columna__
    ;sub     byte[diaReal],1

	sub		byte[#datoBin],1				;(col - 1)
    mov		al,byte[#datoBin]				;al = (col - 1)
	
	mov		bl,2			            ;bl = LongEle
    mul		bl				            ;ax = ax * bl = (col - 1) * LongEle
    
	mov		rdx,rax			            ;rdx = ColsDesplaz 

    ;__Desplazamiento en Filas__
	sub		byte[#datoAValidarPorRango],1	            ;(fila -1)
	mov		al,byte[#datoAValidarPorRango]             ;al = (fila -1)
    mov		bl,14			            ;bl = (L * cant.cols)
	mul		bl	            ;ax = FilsDesplaz = = ax * bl = (fila - 1) * L * Cant.Cols

	add		rax,rdx			;rax = DesplazTotal = ColsDesplaz + FilsDesplaz

	mov		bx,word[#matrizDada + rax]	;obtengo el valor la matrizDada
	inc		bx						;#OJO sumar 1 x consigna
	mov		word[#matrizDada + rax],bx	;volver a actualizar valor en matrizDada

    ;inc     word[#matrizDada + rax] ;otra opcion #OJO

    ret
        

operacionConPedidoAlUsuario:

    ingresoDatosUsuario:
            mov		rcx,#msjOperacionPedidoAlUsuario    ;Parametro 1: direccion del mensaje a imprimir
            sub		rsp,32
            call	printf
            add		rsp,32

            mov		rcx,#inputUsuario    ;Parametro 1: direccion de memoria del campo donde se guarda lo ingresado
            sub		rsp,32
            call	gets				;Lee de teclado y lo guarda como string hasta que se ingresa fin de linea . Agrega un 0 binario al final
            add		rsp,32

            mov		rcx,#datoInputUsuario    ;Parametro 1: campo donde están los datos a leer
            mov		rdx,#formatInputUsario   ;Parametro 2: dir del string q contiene los formatos
            mov		r8,#datoInputUsuario     ;Parametro 3: dir del campo que recibirá el dato formateado
            sub		rsp,32
            call	sscanf                  ;chequeo que no haya ingreado chars especiales o letras
            add		rsp,32

            cmp		rax,1			;rax tiene la cantidad de campos que formateo bien 
        
        jl		#ingresoDatosUsuario

    ;___Validacion por RANGO ingreso Datos Usuario___
        cmp		dword[#datoInputUsuario],1  ;minimo
        jl		#ingresoDatosUsuario
        cmp		dword[#datoInputUsuario],6  ;maximo
        jg		#ingresoDatosUsuario
        

    ;_____ Desplazamiento en #matrizDada operacion usuario _____
    ;_____ #EN ESTE CASO CORRESPONDE A UN DESPLZAMIENTO EN FILAS, 
    ;______EL USUSAIRO ELIJE UN FILA = UNA SEMANA. Luego itero sobre cols xa esa fila
    ; (col - 1) * L + (fil - 1) * L * cant. cols
    ; [Deplaz. Cols] + [Desplaz. Filas]
    ;ya tengo el nro ingresado [1..6] en binario (double word 4 bytes)
        sub		dword[#datoInputUsuario],1 ;desplaz. filas (fila - 1)

        mov		rax,0
        mov     eax,dword[#datoInputUsuario] ;eax = (fila - 1)

        mov		bl,14			; bl = (L * Cant.Cols)
        mul		bl				;ax = FilasDeplaz = eax * bl = (fila - 1) * (L * Cant.Cols)

        mov		rdi,rax			;RDI = FilasDesplaz 
        ;xq  el retorno de printf puedo llegar a pisar el rax

    ;____#msgDescriptivoOperUser_____
        mov		rcx,#msgDescriptivoOperUser	
        sub		rsp,32
        call	printf				;Muestro texto descruptivo al usuario
        add		rsp,32

    ;___ impresin de listado indicando tablaImpresion___.
        mov		rcx,7           ;(long tablaImp) = Cantidad de filas/cols sobre las q voy a iterar
        mov		rsi,0			;Utilizo rsi para moverme en el vector tablaImp
        mov		rbx,0			;RBX en 0 para no tener basura y levantar valor de cada pos de la tabla. 
    
    imprimir:    
            mov		qword[contadorTransitorioRcx],rcx ;xq con el printf piso el rcx

            ;___Imprimo la lyenda de #tablaImp___
            lea     rcx,[#tablaImp + rsi] ;le paso a rcx la direc de cada ele al iterar en la tabla (siempre en la fila que me dio el usuario)
            sub		rsp,32
            call	printf
            add		rsp,32

            ;___Obtengo dato a a imprimir de la matrizDada___
            ;RDI = FilasDesplaz 
            mov		bx,word[#matrizDada + rdi]	;recupero el valor de la matrizDada
            ;(R)BX = valor en la matrizDada que quiero recuperar

            ;___Imprimo el dato obtenido___
            mov		rcx,#FormatoXaTabla		;Parametro 1: direccion de memoria de la cadena texto a imprimir
            mov		rdx,rbx			         ;Parametro 2: dato recuperado de tabla. imprimo en #FormatoXaTabla
            sub		rsp,32
            call	printf
            add		rsp,32

            add		rdi,2   ;Avanzo LongEle de MatrizDada (cada elem. es una WORD de 2 bytes)
            add		rsi,15	;Avanzo LongEle + 1 bytes. Tam c/ fila de #tablaImp

            mov		rcx,qword[contadorTransitorioRcx]

        loop	imprimir

    ret 





;_____________impresion por pantalla de un string solito__________________
section .data
    mensaje     db  "Hola Intel en Windowssssssssssss",10,0

section .text

    mov     rcx,mensaje
    sub     rsp,32
    call    puts
    add     rsp,32

;_____________impresion por pantalla con numeros formateados_____________
section .data

    msjSumatoria        db  "La sumatoria es : %i",10,0 ; %i 32 bits (doble plbra dword).
    msjSumatoria        db  "La sumatoria es : %lli",10,0 ; %i 64 bits (doble plbra qword).

section .bss    
sumatoria           resd    1


section .text
    mov             rcx,msjSumatoria    ;parametro 1), el string con el texto
    ;mov             edx,dword[sumatoria] ;esto tiraria error xq rdx es de 64 bits y sumatoria era de 32 bit
    mov             rdx,0 ; parametro 2); el numero a formatear en %i con el tam q corresponda
    ;para asegurarme que en los bits superiores del rdx haya ceros
    mov             edx,dword[sumatoria]; poner el dword ya que estoy fromateando un numero de menos de 64 bits
    sub             rsp,32
    call            printf
    add             rsp,32


;___________________pedido e ingreso de datos por teclado______________
section .data

    formatInputFilCol   db "%hi %hi",0 ;hi (16 bits, 2 bytes 1 word).         ;esto es para el sscanf

section .bss
    
    inputFilCol         resb    50 ; para que me sobre y siempre al FINAL DE LA SECCION

section .text

ingresoDatos:

    mov             rcx,inputFilCol
    sub             rsp,32
    call            gets ;solo lee lo ingresado como texto y lo guarda en rcx. No castea nada.
    add             rsp,32  

    call            validarFyC ;validamos. en esa rutina modificamos el valor de 'inputValido'
    cmp             word[inputValido], "N" ;N - no valido / S - valido
    je              ingresoDatos

;_____________Rutina para validar ingreso de numeros en un rango_________________

validarFyC:
    ;Esperamos valores del tipo "[1..5] [1..5]" para Fila - Columna
    mov             byte[inputValido], "N"; Supongo inicialmente que el ingreso fue incorrecto

    ;formateo
    mov             rcx,inputFilCol; toma el ingreso por teclado fuere cual fuere. ANTES DEBO HABER USADO GETS
    mov             rdx,formatInputFilCol; formatea el ingreso como lo diga la variable 'formatInputFilCol'. El 
    mov             r8,fila ;xa guardar el valor de la fila
    mov             r9,columna ;xa guardar el valor de la columna
    sub             rsp,32
    call            sscanf ;nos devuelve la cant de numeros casteados exitosamente en el RAX.
    add             rsp,32

    ;validacion fisica (casteo los 2 valores enteros, ie, se ingresaron solo enteros no letras o chars especiales)
    cmp             rax,2 ;
    jl              invalido

    ;validacion logica x rango (Chequeo q la fila y la columna esten en el rango 1 a 5) 
    ;la fila
    cmp             word[fila],1
    jl              invalido
    cmp             word[fila],5
    jg              invalido
    ;chequeo la columna
    cmp             word[columna],1
    jl              invalido
    cmp             word[columna],5
    jg              invalido

    mov             byte[inputValido], "S" ;pongo una S para dar el okey de q se ingreso bien

    invalido:
        ret

;_____________Rutina para calcular desplazamiento en una matriz_________________
calcDesplaz:
;#FALTA 
;Ver si conviene esta o la del pptx!!!!

    ;Suponiendo que el indice arranca en 1
    ;calculo de desplaza hasta llegar (fila, col) de la matriz 
    ;[(fila-1)*longFila]  + [(columna-1)*longElemento]
    ; [(fila -1) *(longElemento*CantCol)] + [(columna -1) *(longElemento)]
    ; longFila = longElemento * cantidad columnas     

    ;desplazamiento fila
    mov             bx,word[fila] ;
    sub             bx,1 ;(fila -1)
    imul            bx,bx,10 ;(fila -1) * Longfila = (fila -1) *(longElemento*CantCol) = (fila -1)* 2bytes(word) *5 = (fila -1)*10
    ;guardo desplazamiento FILA en DESPLAZ xa poder seguir usando bx
    mov             word[desplaz], bx
    
    ;desplazamiento columna
    mov             bx,word[columna]
    sub             bx,1
    imul            bx,bx,2 ;word = 2 bytes 
    ;dejo en BX el desplazamiento de la COLUMNA
    
    ;sumo los desplazamientos
    add             word[desplaz],bx 
    ;Dejo en DESPLAZ tengo el desplazamiento TOTAL

    ret


;_____________Rutina para caclular una sumatoria con loop de numeros de una matrizDada_________________

section .data

section .bss

sumatoria         resd    1; reservo un double (4 bytes 32 bits x si la suma es muy grande)

section .text 
main: 

    call            calcSumatoria

calcSumatoria:
        
        mov     dword[sumatoria],0 ;inicializo en 0 la variable sumatoria xa q no tenga basura
        
        ;loop labura con el registro RCX
        mov     rcx,0; completo 0's xq voy usar una parte mas chica
        mov     cx,6 ;indico el numero de vueltas (columnas_totales(5) + 1) = 6 (_*RCX*_)
        sub     cx,word[columna] ;  - columna_elegida. y lo guardo en RCX que hace de contador
        ;(esta formula se dedujo de una consigna puntual)

        ;uso RBX DE PUNTERO (BASE) para guardar el desplaz
        mov     rbx,0 ;relleno con 0's y uso BX de puntero indice
        mov     bx,word[desplaz] ;copio el desplaz a ese registro xa marcar el inicio.
        ;desplaz tiene la cant de bytes a saltear xa llegar a la pos indicada por la fila y columna

;esta dentro de calcSumatoria
sumarSgte: ;(_*RCX*_)
        ;uso AX para levantar cada elemento de la matriz q son de tipo word
        mov     rax,0 ;inicializo RAX en 0 para asegurarme que lo q viene antes de ax no tiene basura.
        ;sumo a la direc inicial de la matriz + los bytes para llegar a la pos i j
        ;y luego guardo el [CONTENIDO] de esa "pos de mem" n la q estoy parado en ax
        mov     ax,word[matriz + rbx] 

        ;como dije q iba a guardar el resultado de la suma en una dobleWord, uso eax (ya rellene con 0's)
        add     dword[sumatoria],eax ;con eso hice la 1era (N'ava) suma parcial

        ;muevo el puntero indice sumando 2 (Bytes). matriz con elementos doubleWords d 2 Bytes
        add     rbx,2
        
        ;(_*RCX*_)
        loop sumarSgte ;loop hace rcx - 1 , compara y si es = a 0 sigue de largo, sino otra vuelta

        ret

;____________Manejo de archivos externo txt_______________
;Claves/ resumen/ cosas que no me acuerdo? 
;q mas agrego aca??

