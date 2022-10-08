;__________________Secciones .data y .bss_____________________

section .data
    
    ;___ARCHIVOS___
    #nombreArchivo	        db	"NOMBRE_ARCHIVO.dat",0
    #modoApertura		    db	"rb",0		; modo lectura del archivo binario
    
    ;___MENSAJES X PANTALLA Y FORMATOS INPUTS___
    #msjOperacionPedidoAlUsuario	     db    "Ingrese la semana [1..6]: ",10,13,0 ;10: \n 13: \r (retorno de carro)
    #formatoDatoInputUsuario             db     "%i",0 ;#FALTA %hi 16 bits / %i 32 bits / %lli 64 bits

    #msjRtaOperacionPedidoUsuario        db     "La sumatoria es : %i",10,0 ; %i 32 bits (doble plbra dword).
    

    ;___REGISTROS NombreArchivo Lectura___
	registro                    times 0 	db ""
        #datoAValidarPorTabla	times 2		db " "
        #datoAValidarPorRango   times 7		db " "
        #campoBPF		    	            db  0    ;como es binario no va nada pero reservo 2 bytes
        #campo3	            	times 20	db " "
    
    ;REGISTROS ARCHIVO ESCRITURA (EN CASO DE SER NECESARIO)

    ;___MATRICES___
    ;Matriz con datos
    ;observar que son words (2 bytes)
    matriz	dw	1,1,1,1,1
			dw  2,2,2,2,2
			dw	3,3,3,3,3
			dw	4,4,4,4,4
			dw	5,5,5,5,5

    ;matriz llena de 0's
    matriz		        times 42	dw  0

    ;___VALIDACIONES___
    ;VALIDACION POR TABLA
    #tablaDeValidacion      db          "DOLUMAMIJUVISA"    

section .bss
    #nombreArchivoHandle    resq	1


    RegEsValido		        resb	1	;'S' - Si 'N'- No
    contadorLoopValidacion  resq    1   ;para almacenar transitoriamente el rcx

    #datoBin	            resb	1   
    ;#dato binario para convertir el dato que leo del archivo
    ;si necesito convertirlo para alguna operacion
    ;ver #ConteoDias

    #datoInputUsuario       resd    1  ;#FALTA resb(1 byte = 8 bits) resw (2bytes = 16 bits) resd (4 bytes = 32 bits) resq(8 bytes = 64 bits)

    desplaz                 resw    1  ;2 bytes como bx

    #inputUsuario           resb    100 ; siempre al FINAL DE LA SECCION xq reserve espacio de sobra
    

