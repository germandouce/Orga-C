	.equ SWI_Open_File, 0x66
	.equ SWI_Read_Int, 0x6C
	.equ SWI_Close_File, 0x68
	.equ SWI_Print_Char, 0x00
    .equ SWI_Print_Str, 0x69
    .equ SWI_Print_Int, 0x6B 
    .equ SWI_Exit, 0x11 @ solicita a ARMSim que salga del programa   
    
    .data

filename:
    .asciz "archivo.txt" @es el path. puede ser relativo o abs.
    .align
InFileHandle: @es opcional
    @es la referencia al archivo que va a utilizar el programa cuando el
    @sisop le devuelva el handler para hablar con el archivo
    @puede no ser necesario en memoria. Puede ser posible mantenerlo en un registro.
    .word 0

    .text

    .global _start

    @APERTURA de archivo
    ldr r0, =filename @se apunta al registro que tiene el archivo (en este caso esta en mem)
    mov r1,#0   @r1 = 0 modo de apertura. 0 = entrada de info
    swi 0x66    @swi para apertura de archivos @IMPORTANTE
    @deja en el r0 el handler
    bcs InFileError @bifurcacion si hubo error
    ldr r1, =InFileHandle @la load, el r1 apunta una palabra en memoria
    str r0, [r1]    @store guarda el contenido del r0 en lo APUNTADO POR EL R1
    @osea hago guardo el contenido del r0 en la var en mem InFileHandle
    @InFileHandle = puntero a filename

    @LECTURA de entero archivo
    @es condicion que en el r0 este el fileHandler
    ldr r0,= InFileHandle
    ldr r0,[r0]
    swi 0x6c    
    @OJO, XQ ESTA SWI pisa el r0. entonces si no lo guarde en memoria, lo pierdo 

    @CERRAR ARCHIVO
    ldr r0,= InFileHandle @[ro] -> InFileHanlde
    ldr r0,[r0] @[ro] = InFileHanlde
    swi 0x68

    @SALIDA ESTANDAR DE UN ENTERO
    mov r0,#1   @[r0] = Stdout (salida por pantalla)
    mov r1,r2   @[r1] = entero a mostrar (suponemos que estaba en r2)
    swi 0x6b

_start:

InFileError:

fin:
	swi SWI_Exit
	.end