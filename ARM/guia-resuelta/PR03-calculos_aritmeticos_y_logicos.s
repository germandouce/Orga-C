@ En este programa realizamos varias operaciones aritméticas sobre dos números.
@ No imprime los resultados, sin embargo podemos verlos en los registros de ARMSim
@ si nos movemos utilizando single-step a través del código

        @ constantes
        .equ SWI_Exit, 0x11

        @ sección de código - porción ejecutable del código
        .text

        @ hace _start disponible al linker
        @ esto es effectivamente parte de la definición del "main"
        .global _start
_start:
		@ carga los valores 5 y 2 en los registros r0 y r1
		mov r0, #5
		mov r1, #2

		@ (r2) = (r0) + (r1)
		add r2, r0, r1

		@ (r3) = (r0) - (r1)
		sub r3, r0, r1

		@ (r4) = (r0) * (r1)
		mul r4, r0, r1

		@ (r5) = (r0) AND (r1)
		and r5, r0, r1

		@ (r6) = (r0) OR (r1)
		orr r6, r0, r1

		@ (r7) = (r0) XOR (r1)
		eor r7, r0, r1

		@ (r8) = shift izquierdo de (r0) en (r1) bits
		mov r8, r0, LSL r1 @ LSL: logical shift left

		@ (r9) = shift derecho de (r0) en (r1) bits
		mov r9, r0, LSR r1 @ LSR: logical shift right

		@ (r10) = shift aritmético derecho de (r0) en (r1) bits
		mov r10, r0, ASR r1 @ ASR: arithmetic shift right

        @ solicita a ARMSim que salga del programa
		swi SWI_Exit
		.end
