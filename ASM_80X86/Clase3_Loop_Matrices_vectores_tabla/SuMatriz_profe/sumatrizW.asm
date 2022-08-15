;*****************************************************************************
; sumatriz.asm
; Dada una matriz de 5x5 cuyos elementos son números enteros de 2 bytes (word)
; se pide solicitar por teclado un nro de fila y columna y realizar
; la sumatoria de los elementos de la fila elegida a partir de la
; columan elegida y mostrar el resultado por pantalla.
; Se deberá validar mediante una rutina interna que los datos ingresados por
; teclado sean validos.
;
;*****************************************************************************
global	main

extern	printf
extern	sscanf
extern	gets

section	.data
	msjIngFilCol		db		"Ingrese fila (1 a 5) y columna (1 a 5) separados por un espacio: ",0
	formatInputFilCol	db	"%hi %hi",0
	matriz	dw	1,1,1,1,1
			dw  2,2,2,2,2
			dw	3,3,3,3,3
			dw	4,4,4,4,4
			dw	5,5,5,5,5
;   matriz  dw  1,1,1,1,1,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5		
	
	msjSumatoria	db	"La sumatoria es: %i",10,0
	sumatoria		dd 0

section	.bss
	inputFilCol		resb	50
	inputValido		resb	1	;'S' valido  'N' invalido
	fila			resw	1
	columna			resw	1
	desplaz			resw	1

	;sumatoria		resd	1

section	.text
main:

	mov		rcx,msjIngFilCol
	sub		rsp,32
	call	printf
	add		rsp,32

	mov		rcx,inputFilCol	
	sub		rsp,32
	call	gets
	add		rsp,32

	call	validarFyC
	
	cmp		byte[inputValido],'N'
	je		main

	call	calcDesplaz

	call	calcSumatoria

	mov		rcx,msjSumatoria
	sub		rdx,rdx
	mov		edx,[sumatoria]
	sub 	rsp,32	
	call	printf
	add 	rsp,32		

ret

;*********************************
; RUTINAS INTERNAS
;*********************************
validarFyC:
	mov		byte[inputValido],'N'

	mov		rcx,inputFilCol
	mov		rdx,formatInputFilCol
	mov		r8,fila
	mov		r9,columna
	sub		rsp,32
	call	sscanf
	add		rsp,32

	cmp		rax,2
	jl		invalido

	cmp		word[fila],1
	jl		invalido
	cmp		word[fila],5
	jg		invalido

	cmp		word[columna],1
	jl		invalido
	cmp		word[columna],5
	jg		invalido

	mov		byte[inputValido],'S'

;	call	checkAlign
;	sub		rsp,[plusRsp]
;	call	sscanf
;	add		rsp,[plusRsp]

invalido:
ret

;*********************************
calcDesplaz:
;  [(fila-1)*longFila]  + [(columna-1)*longElemento]
;  longFila = longElemento * cantidad columnas

	mov		bx,[fila]
	sub		bx,1
	imul	bx,bx,10		;bx tengo el desplazamiento a la fila

	mov		[desplaz],bx

	mov		bx,[columna]
	dec		bx
	imul	bx,bx,2			; bx tengo el deplazamiento a la columna

	add		[desplaz],bx	; en desplaz tengo el desplazamiento final
ret

;*********************************
calcSumatoria:
	mov		dword[sumatoria],0

	sub		rcx,rcx
	mov		cx,6
	sub		cx,[columna]
;	inc		cx

	sub		ebx,ebx
	mov		bx,[desplaz]

sumarSgte:
	sub		eax,eax		;mov eax,0  ; xor  eax, eax
	mov		ax,[matriz + ebx]
	
	add		[sumatoria],eax

	add		ebx,2

	loop	sumarSgte

ret