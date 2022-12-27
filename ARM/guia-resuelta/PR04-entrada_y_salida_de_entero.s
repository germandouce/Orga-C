        @ constantes
    	.equ SWI_Open_File, 0x66
		.equ SWI_Read_Int, 0x6C
		.equ SWI_Print_Int, 0x6B
		.equ SWI_Close_File, 0x68
        .equ SWI_Exit, 0x11

        @ sección de datos - datos que el programa usará
        .data
filename:
        @ .asciz : string terminado en byte nulo
		.asciz "entero.txt"
	
        @ sección de código - porción ejecutable del código
		.text

      	@ hace _start disponible al linker
        @ esto es effectivamente parte de la definición del "main"
        .global _start
_start:
        @ carga el puntero al string en el registro r0
		ldr r0, =filename
		mov r1, #0 			@ abrir para lectura
		swi SWI_Open_File	@ abrir el archivo

		@ copia el manejador de archivo de r0 a r5
		mov r5, r0

		@ lee un entero desde el archivo
		@ PRECOND - r0: manejador del archivo
		@ POSCOND - r0: entero leído desde el archivo
		swi SWI_Read_Int

		@ mostrar el entero por pantalla
		@ PRECOND - r0: dónde mostrar (1: stdout)
		@ PRECOND - r1: entero a mostrar
		mov r1, r0
		mov r0, #1
		swi SWI_Print_Int

		@ cerrar el archivo, which looks for
		@ PRECOND - r0: manejador del archivo
		mov r0, r5
		swi SWI_Close_File

        @ solicita a ARMSim que salga del programa
		swi SWI_Exit
		.end
