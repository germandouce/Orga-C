;__________________Secciones .data y .bss_____________________

section .data
    
    nombreArchivo	        db	"NOMBRE_ARCHIVO.dat",0
    modoApertura		    db	"rb",0		; modo lectura del archivo binario
    
    msjALGUNACOSA           db  "La sumatoria es : %i",10,0 ; %i 32 bits (doble plbra dword).
    
    formatInputFilCol       db "%hi %hi",0 ;hi (16 bits, 2 bytes 1 word). esto es para el sscanf

    ;REGISTROS NombreArchivo Lectura
	registro	times 0 	db ""
	campo1		times 2		db " "
    campo2		times 7		db " "
	campoBPF		    	db 0    ;como es binari no va nada pero reservo 2 bytes
	campo3		times 20	db " "
    
    ;REGISTROS ARCHIVO ESCRITURA (EN CASO DE SER NECESARIO)


    ;Matriz con datos
    ;observar que son words (2 bytes)
    matriz	dw	1,1,1,1,1
			dw  2,2,2,2,2
			dw	3,3,3,3,3
			dw	4,4,4,4,4
			dw	5,5,5,5,5

    ;matriz llena de 0's
    matriz		        times 42	dw  0
    

section .bss
    nombreArchivoHandle	    resq	1

    inputValido		        resb	1	;'S' - Si 'N'- No
    inputFilCol             resb    50 ; siempre al FINAL DE LA SECCION xq reserve espacio de sobra
    desplaz                 resw    1  ;2 bytes como bx