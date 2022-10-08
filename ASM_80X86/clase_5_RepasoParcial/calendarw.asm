; Se dispone de una matriz C que representa un calendario de actividades de una persona. 
; La matriz C está formada por 7 columnas (que corresponden a los días de la semana) 
; y por 6 filas (que corresponden a las semanas que puede tener como máximo un mes en un calendario).
; Cada elemento de la matriz es un BPF S/Signo de 2 bytes (word) 
; representa la cantidad de actividades que realizará dicho día en la semana.
; Además se dispone de un archivo de entrada llamado CALEN.DAT donde cada registro tiene el siguiente formato:
; - Día de la semana: Carácter de 2 bytes (DO, LU, MA, MI, JU, VI, SA)
; - Semana: Binario de 1 byte (1..6)
; - Actividad: Caracteres de longitud 20 con la descripción.
; Como la información leída del archivo puede ser errónea, 
; se dispone de una rutina interna llamada VALCAL para su validación.
; Se pide realizar un programa assembler Intel x86 que actualice la matriz C con aquellos registros válidos. 
; Al finalizar la actualización se solicitará el ingreso por teclado de una semana 
; y se debe generar un listado indicando “Dia de la Semana – Cantidad de Actividades”.

; Dia de la Semana – Cantidad de Actividades
; Domingo                    1 
; Lunes                      3 
; Martes                     1 
; Miercoles                  4 
; Jueves                     1 
; Viernes                    1 
; Sabado                     1 

global 	main
extern 	printf
extern	gets
extern 	sscanf
extern	fopen
extern	fread
extern	fclose

section  .data
	; Definiciones del archivo binario
	fileName	db	"CALEN.dat",0
    mode		db	"rb",0		; modo lectura del archivo binario
	msgErrOpen	db  "Error en apertura de archivo",0

	; Registro del archivo
	registro	times 0 	db ""
	dia			times 2		db " "
	semana					db 0
	descrip		times 20	db " "

	; Matriz
	matriz		times 42	dw  0

	dias		db	"DOLUMAMIJUVISA"

	msgSemana	db	'Ingrese la semana [1..6]: ',10,13,0 ;10: \n 13: \r (retorno de carro)

	numFormat	db	'%i'	;%i 32 bits / %lli 64 bits
	
	msgEnc		db	'Dia      - Cant.Act',10,13,0

	diasImp		db	"Domingo       ",0
				db	"Lunes         ",0
				db  "Martes        ",0
				db  "Miercoles     ",0
				db  "Jueves        ",0
				db  "Viernes       ",0
				db  "Sabado        ",0
	
	msgCant		db	'%lli',10,13,0

section  .bss

	fileHandle	resq	1
	esValid		resb	1
	contador    resq    1
	diabin		resb	1
	nroIng		resd	1
	
	buffer      resb	10
	
section .text
main:
	call	abrirArch

	cmp		qword[fileHandle],0				;Error en apertura?
	jle		errorOpen

	call	leerArch
	call	listar
		
endProg:
	
	ret
	
errorOpen:
    mov		rcx, msgErrOpen
	sub		rsp,32
	call	printf
	add		rsp,32

    jmp		endProg

abrirArch:
	;	Abro archivo para lectura
	mov		rcx,fileName			;Parametro 1: dir nombre del archivo
	mov		rdx,mode				;Parametro 2: dir string modo de apertura
	sub		rsp,32
	call	fopen					;ABRE el archivo y deja el handle en RAX
	add		rsp,32

	mov		qword[fileHandle],rax	; lo dejamos en fileHandle

	ret

leerArch:

leerReg:
	mov		rcx,registro				;Parametro 1: dir area de memoria donde se copia
	mov		rdx,23						;Parametro 2: longitud del registro
	mov		r8,1						;Parametro 3: cantidad de registros
	mov		r9,qword[fileHandle]		;Parametro 4: handle del archivo
	sub		rsp,32
	call	fread						;LEO registro. Devuelve en rax la cantidad de bytes leidos
	add		rsp,32

	cmp		rax,0				        ;Fin de archivo?
	jle		eof

	call	VALCAL

	cmp		byte[esValid],'S'
	jne		leerReg

	; Actualizar la actividad leida del archivo en la matriz
	call	sumarAct

	jmp		leerReg

eof:
	;	Cierro archivo cuando llega a fin del archivo
	mov		rcx,qword[fileHandle]	;Parametro 1: handle del archivo
	sub		rsp,32
	call	fclose
	add		rsp,32

	ret

VALCAL:
	mov     rbx,0                       ;Utilizo rbx como puntero al vector dias
	mov		rcx,7						;7 días por semana
	mov     rax,0                       ;dia convertido en número
compDia:
	inc     rax
	mov		qword[contador],rcx			;Resguardo el rcx en [contador] porque se va usar para cmpsb
	mov		rcx,2
	lea		rsi,[dia]
	lea		rdi,[dias + rbx]
	repe	cmpsb		;xq estoy comparando memoria a memoria y son mayores a 1 byte
	mov		rcx,qword[contador]			;Recupero el rcx para el loop

	je		diaValido
	add		rbx,2						;Avanzo en el vector dias

	loop	compDia
	; Se ha finalizado el ciclo de iteraciones de todos los valores del vector dias
	jmp     invalido

diaValido:
	mov		byte[diabin],al				;Paso el dia en binario a una variable [diabin]
	cmp		byte[semana],1
	jl		invalido
	cmp		byte[semana],6
	jg		invalido

valido:
	mov		byte[esValid],'S'			;Devuelve S en la variable esValid si es un reg válido

finValidar:
	ret

invalido:
    mov		byte[esValid],'N'			;Devuelve N en la variable esValid si no es un reg válido
	jmp		finValidar

sumarAct:
	; deplazamiento de una matriz
	; (col - 1) * L + (fil - 1) * L * cant. cols
	; [Deplaz. Cols] + [Desplaz. Filas]

	mov		rax,0
	mov		rbx,0

	sub		byte[diabin],1				;Resto a [diabin] 1 para hacer el desplaz. columnas
    mov		al,byte[diabin]				;Copio el dia en binario ([diabin]) al reg AL
										;en rax va tener la columna de la matriz de [0..6]
	
	mov		bl,2			            ;muevo al bl 2 como multiplicador
    mul		bl				            ;mu ltiplico (col x 2) desplaz. cols. resultado en ax

	mov		rdx,rax			            ;copio a rdx el desplaz.cols

	sub		byte[semana],1	            ;Resto a semana 1 para hacer el desplaz. filas
	mov		al,byte[semana]

    mov		bl,14			;muevo al bl 14 como multiplicando (cant.cols x long.elem = 14)
	mul		bl				;resultado de la multip. en ax

	add		rax,rdx			;sumo ambos desplaz.

	mov		bx,word[matriz + rax]	;obtengo la cantidad de actividades del dia en la matriz
	inc		bx						;sumar 1
	mov		word[matriz + rax],bx	;volver a actualizar la cantidad del dia en la matriz

	ret

listar:

ingresoSemana:
	mov		rcx,msgSemana		;Parametro 1: direccion del mensaje a imprimir
	sub		rsp,32
	call	printf
	add		rsp,32

	mov		rcx,buffer			;Parametro 1: direccion de memoria del campo donde se guarda lo ingresado
	sub		rsp,32
	call	gets				;Lee de teclado y lo guarda como string hasta que se ingresa fin de linea . Agrega un 0 binario al final
	add		rsp,32

	mov		rcx,buffer		    ;Parametro 1: campo donde están los datos a leer
	mov		rdx,numFormat	    ;Parametro 2: dir del string q contiene los formatos
    mov		r8,nroIng		    ;Parametro 3: dir del campo que recibirá el dato formateado
	sub		rsp,32
	call	sscanf
	add		rsp,32

	cmp		rax,1			;rax tiene la cantidad de campos que pudo formatear correctamente
	jl		ingresoSemana

	;valido que el nro ingresado sea [1..6]
	cmp		dword[nroIng],1
	jl		ingresoSemana
	cmp		dword[nroIng],6
	jg		ingresoSemana

	;ya tengo el nro ingresado [1..6] en binario (double word 4 bytes)
    sub		dword[nroIng],1		;Restar 1 para hacer desplaz. filas (fila - 1) * L * Cant.Cols

	mov		rax,0
	mov     eax,dword[nroIng]

	mov		bl,14			;muevo el desplaz. filas a bl como multiplicador (fila - 1) * L * Cant.Cols
	mul		bl				;resultado de la multip. queda en el ax

	mov		rdi,rax			;Paso el desplaz. de la matriz al rdi

	mov		rcx,msgEnc			;Parametro 1: direccion de memoria del campo a imprimir
	sub		rsp,32
	call	printf				;Muestro encabezado del listado por pantalla
	add		rsp,32

	mov		rcx,7
	mov		rsi,0			;Utilizo rsi para desplazar dentro del vector diasImp
	mov		rbx,0			;Utilizo rbx como auxiliar para levantar cant. total actividades
mostrar:
	mov		qword[contador],rcx

	lea     rcx,[diasImp + rsi]
	sub		rsp,32
	call	printf
	add		rsp,32

	mov		bx,word[matriz + rdi]		; recupero la cantidad total de actividades en el dia de la matriz

	mov		rcx,msgCant		;Parametro 1: direccion de memoria de la cadena texto a imprimir
	mov		rdx,rbx			;Parametro 2: campo que se encuentra en el formato indicado q se imprime por pantalla
	sub		rsp,32
	call	printf
	add		rsp,32

	add		rdi,2			;Avanzo al próximo elemento de la fila (cada elem. es una WORD de 2 bytes)
	add		rsi,15			;Avanzo 14 + 1 bytes (1 byte de caract. especial 0 al final de cada dia)

	mov		rcx,qword[contador]
	loop	mostrar

	ret