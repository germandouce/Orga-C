;__________________Secciones .data y .bss_____________________

section .data
    
    ;___ARCHIVOS___
    #nombreArchivo	        db	"NOMBRE_ARCHIVO.dat",0
    #modoApertura		    db	"rb",0		; modo lectura del archivo binario
    #msgErrOpen             db  "Ocurrio un error al abrir el archivo"

    ;___MENSAJES X PANTALLA Y FORMATOS INPUTS___
    #msjOperacionPedidoAlUsuario	     db    "Ingrese la semana [1..6]: ",10,13,0 ;10: \n 13: \r (retorno de carro)
    #formatoDatoInputUsuario             db     "%i",0 ;#FALTA %hi 16 bits / %i 32 bits / %lli 64 bits

    #msgDescriptivoOperUser	             db	    "Dia      - Cant.Act",10,13,0
    ;#msjRtaOperacionPedidoUsuario        db     "La sumatoria es : %i",10,0 ; %i 32 bits (doble plbra dword).

    ;cada elemento tiene 14 bytes + el 0 = 15 bytes que le mando al printf
    #tablaImp   db	"Domingo       ",0
				db	"Lunes         ",0
				db  "Martes        ",0
				db  "Miercoles     ",0
				db  "Jueves        ",0
				db  "Viernes       ",0
				db  "Sabado        ",0

   	
    #FormatoXaTabla	db	"%lli",10,13,0   ;para "pisar el 0"

    ;___REGISTROS #NombreArchivo Lectura___ #OJO nombre archivo
	registro                    times 0 	db ""
        #datoAValidarPorTabla	times 2		db " "
        #datoAValidarPorRango   times 7		db " "
        #campoBPF		    	            db  0    ;como es binario no va nada pero reservo 2 bytes
        #campo3	            	times 20	db " "
    
    ;REGISTROS ARCHIVO ESCRITURA (EN CASO DE SER NECESARIO)

    ;___MATRICES___ #OJO
    ;Matriz "que se tiene" sin datos

    ;matriz llena de 0's
    #matrizDada      times 42	dw  0
    
    ;#OJO conviene dejar MATRIZ y pto
    
    ;observar que son words (2 bytes)
    #matrizDada	dw	1,1,1,1,1
                dw  2,2,2,2,2
                dw	3,3,3,3,3
                dw	4,4,4,4,4
                dw	5,5,5,5,5


    ;___VALIDACIONES___
    ;VALIDACION POR TABLA
    #tablaDeValidacion      db          "DOLUMAMIJUVISA"    
    ; #OJO muy repe #tabladeValidacion... ver de sacar un par de #

section .bss
    handle    resq	1


    RegEsValido		        resb	1	;'S' - Si 'N'- No
    contadorTransitorioRcx  resq    1   ;para almacenar transitoriamente

    #datoBin	            resb	1   
    ;#dato binario para convertir el dato que leo del archivo
    ;si necesito convertirlo para alguna operacion
    ;ver #ConteoDias

    #datoInputUsuario       resd    1  ;#FALTA resb(1 byte = 8 bits) resw (2bytes = 16 bits) resd (4 bytes = 32 bits) resq(8 bytes = 64 bits)

    desplaz                 resw    1  ;2 bytes como bx
    
    diaReal                 resb    1  ;me voy moviendo en la columna del #dia que corresponda

    #inputUsuario           resb    100 ; siempre al FINAL DE LA SECCION xq reserve espacio de sobra
    

