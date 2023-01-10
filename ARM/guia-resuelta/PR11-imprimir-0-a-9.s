@ Escribir el código ARM que ejecutado bajo ARMSim# imprima los números del 0 al 9.
@ Pseudocódigo:
@ x = 0
@ while (x < 10) {
@ 	print x
@ 	x++
@ }
@ATENCCIOOOON
@SE MODIFICO EL EJERCICIO PARA Q SOLO IMPRIMA LOS PARES

	.equ SWI_Print_Int, 0x6B
	.equ SWI_Exit, 0x11

	.text
_start:
	@ r2: contador (x)
	mov r2, #0

loop:
	cmp r2, #10    @ x - 10
	@si r2>= 10 fin_loop
	@servia si eran iguales 
	bpl fin_loop   @ si (x - 10 >= 0): saltar a fin_loop
	bl print_r2
	add r2, r2, #1	@r2 +=1
	b loop	@vuelvo para arriba

@aca podria preguntar algo antes de imprimir (si es par o no x ej)
@y segun eso tomar alguna decision
print_r2:
	@Si no me equivoco, se podria haber apilado solamente lr
	@pues en cada vuelta que doy vuelvo a pisar el r0 y r1
    stmfd sp!, {r0,r1,lr}
	mov	r0, #1
	
	and r5, r2,#1	
	@numero and 0000 0001
	@para saber si es par o no. and en el ultimo bit
	@2[10] = 0000 0010 
	@1[10] = 0000 0001
	@and   = 0000 0000 es par !  

	@3[10] = 0000 0011 
	@1[10] = 0000 0001
	@and   = 0000 0001 es IMpar !

	@4[10] = 0000 0100 
	@1[10] = 0000 0001
	@and   = 0000 0000 es par !
	@(si hay un 0 en el ultimo bit, es par si hay 1 es impar)
	@r5 = and.
	cmp r5,#0
	bne	sigNum
	mov r1, r2
	swi SWI_Print_Int
	sigNum:
	ldmfd sp!, {r0,r1,pc}

fin_loop:
	@ salir del programa
	swi SWI_Exit
	.end
