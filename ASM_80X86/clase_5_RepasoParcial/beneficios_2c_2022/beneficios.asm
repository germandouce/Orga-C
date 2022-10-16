;Se cuenta con un archivo en formato binario llamado BENEFICIOS.DAT que contiene información sobre un relevamiento 
;de los tipos de beneficios para sus empleados que ofrecen las 10 empresas del rubro de tecnología más reconocidas.
;Cada registro del archivo contiene la siguiente información.
;  - Código de empresa: 1 byte en formato binario de punto fijo sin signo [1 a 10]
;  - Código de beneficio: 2 bytes en formato ASCII.  
;       SD (Salario en dólares), 
;       KT (kit de tecnología), 
;       VE (Vacaciones extendidas),
;       TR (Trabajo Remoto), HF (horario flexible)
;Se pide realizar un programa en assembler Intel que lea el archivo y por cada registro 
;actualice una matriz (M) de 10x5 
;donde cada fila representa a una empresa y cada columna un tipo de beneficio.  
; Cada elemento de M es un binario de punto fijo sin signo de 1 byte 
;que indica si la empresa ofrece el beneficio (1) o no lo ofrece (0).
;Como la información del archivo puede ser inválida, se hará uso de una rutina interna VALREG que validará los datos de cada 
;registro descartando
;los incorrectos.
;Por último el programa deberá:
;Ingresar un código de empresa (no debe ser validado) e informar por pantalla 
; “Ofrece todos los beneficios” en caso que así sea, o “No ofrece todos los beneficio” en caso contrario

;La matriz se llena con lo q viene en el archivo binario
;Al hacer el 'informe' hay q chequear q en la fila sean todos 1('s') tiene todos los beneficios?
;o q la suma de toodos los 1's sean 5. Un recorrido x fila

;vairantes:
; 1- ingreso codigo de empresa y ver si tiene o no beneficio
; 2- un beneficio y ver cuales lo tienen??

; casi siempre se usan
global 	main
extern  puts
extern 	printf
extern	gets
extern 	sscanf
extern	fopen
extern	fread
extern	fclose

; VER seccion # clase 5 #OJO

;____________________secciones___________________
section     .data

 ;___ARCHIVOS___
    file	                db	"beneficios.dat",0
    mode        		    db	"rb",0		; modo lectura del archivo binario
    msgErrOpen              db  "error al abrir",0

    ;___MENSAJES X PANTALLA Y FORMATOS INPUTS___
    #msjpedidoNumEmpresa	     db    "Ingrese un codigo de emrpesa semana [1..10]: ",10,13,0 ;10: \n 13: \r (retorno de carro)
    formatoNumEmpresa db     "%i",0 ;#FALTA %hi 16 bits / %i 32 bits / %lli 64 bits

    #msjBeneifios	        db	                   "#OJO",10,13,0
    #msjNoOfreceTodos        db                    "La empresa no Ofrece todos los beneifcios",10,0 ; %i 32 bits (doble plbra dword).
    #msjOfreceTodos          db                    "Ofrece todos los beneifcios",10,0 ; %i 32 bits (doble plbra dword).

    ;#OJO NUEVO
    msjLeyendo          db                    "leyendo...",10,0 ; %i 32 bits (doble plbra dword).


    ;___REGISTROS beneficios.dat Lectura___
	#registro                    times 0 	    db ""       ; no debe ocupar lugar xq es la cabecera
        #codEmp              			        db " "      ; 1 byte en formato binario de punto fijo sin signo [1 a 10]
        #beneficio               times 2		db " "  ; 2 bytes 2 letras xa el codigo de beneficio
        ;este es el q valido pot taabla, y necesito una var extra xa contar/ buscar en matriz
        
        ;beneficio              times 2    dw " "
    
    ;REGISTROS ARCHIVO ESCRITURA (EN CASO DE SER NECESARIO)

    ;___MATRICES___
    ;Matriz "que se tiene" sin datos
    ;matriz llena de 0's
    matriz      times 50	db  0 ; Cada registro actualice una matriz (M) de 10x5 
    ;Cada elemento de M es un binario de punto fijo sin signo de 1 byte 


    ;___VALIDACIONES___
    ;VALIDACION POR TABLA
    VecBeneficios      db          "SDKTVETRHF"    


section     .bss

    handle    resq	1


    regEsvalido		        resb	1	;'S' - Si 'N'- No
    datoValido              resb	1; #OJO ver

    ;#contadorTransitorioRcx  resq    1   ;para almacenar transitoriamente
    ;se reemplza por push y pop

    columna                 resb    1 ;me voy moviendo en la "columna del vec de beneficios"
    ;#datoBin	            resb	1   
    ;#dato binario para convertir el dato que leo del archivo
    ;si necesito convertirlo para alguna operacion
    ;ver #ConteoDias

    CodigoEmpNum            resd    1  ;#FALTA resb(1 byte = 8 bits) resw (2bytes = 16 bits) resd (4 bytes = 32 bits) resq(8 bytes = 64 bits)

    desplaz                 resw    1  ;2 bytes como bx

    CodEmpStr               resb    100 ; siempre al FINAL DE LA SECCION xq reserve espacio de sobra

    sumaBeneficios          resw    1; 2 bytes como bx Para hacer la suma de 1's en la fila del usuaior

section     .text 
main: 


;__________________Abrir archivo___________________

    call	abrirArchivo

	cmp		qword[handle],0				;Error en apertura?
	jle		errorOpen

    call    llenarMatriz

    call    cerrarArchivo

	call	informe

    jmp     finProg

errorOpen:
    mov		rcx, msgErrOpen
	sub		rsp,32
	call	printf
	add		rsp,32

finProg:

	ret ;esta ret corresponde a la de fin alizar el programa


;Abro archivo para lectura
abrirArchivo:
    
    mov		rcx, file	    ;Parametro 1: dir nombre del archivo
    mov		rdx, mode       ;Parametro 2: dir string modo de apertura
    sub		rsp,32
    call	fopen			;ABRE el archivo y deja el handle en RAX
    add		rsp,32

    mov		qword[handle],rax ; lo dejamos en fileHandle

    ret

cerrarArchivo:    
        mov     rcx,qword[handle]
        sub     rsp,32
        call    fclose
        add     rsp,32
ret

llenarMatriz:

    ;______________Leer registro binario_____________
    leerRegistro:

            mov		rcx,registro		              ;Parametro 1: dir area de memoria donde se copia
            mov		rdx, 3 ;cod empresa+ codBeenficio ;Parametro 2: longitud del registro
            mov		r8,1						      ;Parametro 3: cantidad de registros
            mov		r9,qword[handle]                  ;Parametro 4: handle del archivo
            sub		rsp,32
            call	fread						;LEO registro. Devuelve en rax la cantidad de bytes leidos
            add		rsp,32

            cmp		rax,0				        ;Fin de archivo?
            jle		eof                  ;salto cuando en el rax hay 0, osea fread llego a eof
            
            ;____leyendo...
            mov		rcx, msjLeyendo
	        sub		rsp,32
	        call	puts
	        add		rsp,32
            ;... _____

            ;#OJO una jpm dentro d euna rutina tiene q ser a una etiqueta dentro de la misma rutina
            
            call    VALREG    ;VALIDACIONES

            cmp		byte[regEsvalido],'N' ;#OJO CAMBIE ACA, DEBERIA ESTAR CORRECTO....
            je		leerReg ; je = 'N' no es valido, leo sig registro
            ;el regsitro es valido...
            ;Luego se salta al siguiente registro

            ;en leerReg devuelvo (correctamente los valores para actualizar
            ;la #matrizDada en el ejercicio. Una "fila" y una "columna")
            ;Ahora en calcDesplaz uso los datos que valide para posionarme en #matrizDada
            call    calcDesplaz

            ;Actualizar #matrizDada con lo que calcule
            call    ebx,[desplaz] ;esto es xq necesito que sea un registro
            mov     byte[matriz + ebx],1    ;meto un 1 en la matriz x consigna

        jmp		leerReg ;Leo el prox registro


    ;________________CloseFiles___________________________
    eof:
        ;cierro archivos    
        mov     rcx,qword[handle]
        sub     rsp,32
        call    fclose
        add     rsp,32

    ret ;finalizo rutina llenarMatriz


;___________________VALIDACIONES_________________________
VALREG:

    mov     byte[regEsvalido],"N"
    
    call    #validarEmpresa
    mov		byte[datoValido],'N'			;Devuelve S en la variable esValid si es un reg válido
    je		finValidarRegistro
    
    call    #validarBeneficio
    mov		byte[datoValido],'N'			;Devuelve S en la variable esValid si es un reg válido
    je	    finValidarRegistro

    mov     byte[regEsvalido],"S"

    finValidarRegistro:
        ret

    ;_______Validacion por RANGO de empresa__________
    validarEmpresa:
        
        mov		byte[datoValido],"N"
        cmp		byte[codEmp],1
        jl		codEmpInval
        
        cmp		byte[codEmp],10
        jl      codEmpInval
        mov		byte[datoValido],"S"	
    
    codEmpInval:
	    ;ya corto y voy a otro registro
        ret
    
    ;____VALIDAR BENEFICIO____
    validarBeneficio:

        ;Solo si la #empresa era valida

        mov     [datoValido],"S"
        
        ;_______Validacion por TABLA de #dato_1_AValidar_______
        mov     rbx,0   ;Utilizo rbx como puntero al vector VecBeneficios
        mov     rcx,5   ;Longitud de vector VecBeneficios. Para la loop
        
        ;Xa actualizar la matriz. Es analogo al conteo de dias. En este caso, no son dias
        ;sino columnas con beneficios.
        mov     byte[columna],1 ;la inicializo en 1
        
        sigBeneficio:
        
            push    rcx; guarda en la pila el cont del rcx
            mov     rcx,2

            ;mov		qword[contadorTransitorioRcx],rcx	;Resguardo el rcx en un contador porque se va usar para cmpsb
            
            ;para CMPSB
            mov     rcx,2                       ;1) bytes de beneficio
            lea     rsi,[beneficio]             ;2) beneficio origen -> rsi
            lea     rdi,[VecBeneficios + rbx]   ;3) #tabla de dias destino -> rdi
            repe    cmpsb                               ;funciona con 3 registros
            
            ;mov		rcx,qword[contadorTransitorioRcx]			;Recupero el rcx para el loop
            
            pop     rcx ;saca el elemento de la pila y lo copia en rcx

            je      beneficioValido
            add		rbx,2	    ;Avanzo en el vector VecBeneficiosidacion el tam de datoAValidarPorTabla

            ;#conteo dias. Es analogo, solo que en este caso, solo sumo 1 en la columna
            ;si el beneficio no es valido. Xq si es valido significa que ese es el num de
            ;beneficio (columna) en la/ el que estoy parado
            ;y cuando lo encuentro me queda aignado el num de columna en el campo
            inc     byte[columna] ;xa actualizar columna

        loop    sigBeneficio
        ;fin ciclo iteraciones de valores del vector VecBeneficiosidacion    
        
        mov     byte[datoValido],"N"

    beneficioValido:
        
        ret


calcDesplaz:
    ;  [(fila-1)*longFila]  + [(columna-1)*longElemento]
    ;  [(fila -1) *(longElemento*CantCol)] + [(columna -1) *(longElemento)]
    ;  longFila = longElemento * cantidad columnas

    ;___desplaz en filas____
    sub     ebx, ebx
    mov     bl,[codEmp]

    dec     bl          ;(fila -1 )
	imul	bx,bx,5		; (fila -1) *(longElemento*CantCol)
    ;bx tengo el desplazamiento a la fila

	mov		[desplaz],ebx   ; lo dejo parcialmente en desplaz

    sub     rbx,ebx

    ;___desplaz en columnas___
	mov		bl,[columna]    ;
	dec		bl              ;(col - 1)
	imul	bx,bx,1			;[(columna -1) *(longElemento)]
    ; bx tengo el deplazamiento a la columna (1 bye)

	add		[desplaz],bx	; en desplaz tengo el desplazamiento final
    
    ret


informe:
    
    ;#ingresoDatosUsuario
    encontrarEmpresa:
            mov		rcx,#msjpedidoNumEmpresa    ;Parametro 1: direccion del mensaje a imprimir
            sub		rsp,32
            call	printf
            add		rsp,32

            mov		rcx,#CodEmpStr    ;Parametro 1: direccion de memoria del campo donde se guarda lo ingresado
            sub		rsp,32
            call	gets	;Lee de teclado y lo guarda como string hasta que se ingresa fin de linea . Agrega un 0 binario al final
            add		rsp,32

            mov		rcx,#CodEmpStr    ;Parametro 1: campo donde están los datos a leer
            mov		rdx,#formatoNumEmpresa   ;Parametro 2: dir del string q contiene los formatos
            mov		r8,#CodigoEmpNum     ;Parametro 3: dir del campo que recibirá el dato formateado
            sub		rsp,32
            call	sscanf                  ;chequeo que no haya ingreado chars especiales o letras
            add		rsp,32

            cmp		rax,1			;rax tiene la cantidad de campos que formateo bien 
        
        jl		ingresoDatosUsuario

    ;No lo pide la consigna pero como era facil lo agregue. Suma medio puntito...?
    ;___Validacion por RANGO ingreso Datos Usuario___
        cmp		word[#CodigoEmpNum],1  ;minimo
        jl		ingresoDatosUsuario
        cmp		word[#CodigoEmpNum],6  ;maximo
        jg		ingresoDatosUsuario
        
    ;_____ Desplazamiento en #matrizDada #operacion usuario _____
    ;_____ #EN ESTE CASO CORRESPONDE A UN DESPLZAMIENTO EN FILAS, 
    ;______EL USUSAIRO ELIJE UN FILA = UNA SEMANA. Luego itero sobre cols xa esa fila
    ; [(fila-1)*longFila] + [(columna-1)*longElemento]
    ; [(fila -1) *(longElemento*CantCol)] + [(columna -1) *(longElemento)]
    ; longFila = longElemento * cantidad columnas
    ;Ya tengo el  #numEmpresa ingresado
    
    ;______Desplaz en filas________
        sub		word[CodigoEmpNum],1 ;desplaz. filas (fila - 1)

        mov		rax,0
        mov     eax,word[CodigoEmpNum] ;eax = (fila - 1)

        mov		bl,5			; bl = (longElemento*CantCol)
        mul		bl				;ax = FilasDeplaz = eax * bl = (fila - 1) * (longElemento*CantCol)
        
        ;DEJO EN RDI EL DESPLAZAMIENTO EN FILAS
        mov		rdi,rax			;RDI = FilasDesplaz 
        ;xq  el retorno de printf puedo llegar a pisar el rax

    ;____#msgDescriptivoOperUser_____
       ; mov		rcx,msjBeneifios	
       ; sub		rsp,32
       ; call	printf				;Muestro texto descruptivo al usuario
        ;add		rsp,32

    ;___ impresion de listado indicando tablaImpresion___.
        mov		    rcx,5           ;(long tablaImp) = Cantidad de filas/cols sobre las q voy a iterar
        ;mov		rsi,0			;Utilizo rsi para moverme en el vector tablaImp
        ;mov		rbx,0			;RBX en 0 para no tener basura y levantar valor de cada pos de la tabla. 
    
    proxColumna:    
            ;mov		qword[contadorTransitorioRcx],rcx ;xq con el printf piso el rcx

            ;___Imprimo la lyenda de #tablaImp___
            ;lea     rcx,[#tablaImp + rsi] ;le paso a rcx la direc de cada ele al iterar en la tabla (siempre en la fila que me dio el usuario)
            ;sub		rsp,32
            ;call	printf
            ;add		rsp,32

            ;____Obtengo dato en la matiz____
            ;RDI = FilasDesplaz 
            mov		bx,word[matriz + rdi]	;recupero el valor de la matrizDada
            ;(R)BX = valor en la matrizDada que quiero recuperar

            ;___Imprimo el dato obtenido___
            ;mov		rcx,#FormatoXaTabla		;Parametro 1: direccion de memoria de la cadena texto a imprimir
            ;mov		rdx,rbx			         ;Parametro 2: dato recuperado de tabla. imprimo en #FormatoXaTabla
            ;sub		rsp,32
            ;call	    printf
            ;add		rsp,32

            add		rdi,1   ;Avanzo LongEle de MatrizDada (cada elem. es una Byte de 1 bytes)
            
            ;add		rsi,15	;Avanzo LongEle + 1 bytes. Tam c/ fila de #tablaImp

            ;mov		rcx,qword[contadorTransitorioRcx]

        loop	proxColumna
        
        cmp     bx,5
        je      todosLosBenef ;si es 5 ofrece todos sino...

        mov		rcx,msjNoOfreceTodos	
        sub		rsp,32
        call	printf				;Muestro texto descruptivo al usuario
        add		rsp,32 
        
        jmp     finInforme

        todosLosBenef:
            mov		rcx,msjOfreceTodos	
            sub		rsp,32
            call	printf				;Muestro texto descruptivo al usuario
            add		rsp,32

    finInforme:

        ret 
