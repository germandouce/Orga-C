@Registros
REGISTROS DE PROPOSITO GENERAL
@R10 A R12
mejor, mejor, mejor, mejor
R3 AL R12 
porque algunas instrucciones usan los primeros

R3 R4 R5 R6 R7 R8 R9 R10 R11 R12

R13: STACK POINTER (SP) 
R14: LINK REGISTER (LR) (enlaza rutinas internas)
R15: PROGRAM COUNTER (PC) (Direccion de la instuccion q va a ser ejecutada)

CPSR: Current Program Status Register
Contiene indicadores y flags bits de estado
Nos interesan los primeros 4
Negative, Zero, Carry, Overflow
 

@MEMORIA Y TAMANIOS

WORD = 32 BITS (4 BYTES)
HALF-WORD = 16 BITS (2 BYTES) 


@Impresion por pantalla:
swi codigoDeImpresion
0x6B: "imprimir un entero"

.asciz "linea" @definir cadena de chars
.word 78 @define el enetero 78

@STACK Y SUBRUTINAS

@ldm = load multiple 
@sp = stack pointer
@! significa actualizar
@siempre usaremos como FD = Full Desscending
stmfd sp!, {r0,lr}  @para apilar (push)
@los parametros son los que quiero apilar
ldmfd sp!, {r0,PC}  @para desapilar (pop)
@los parametros son donde desapilo no LO que desapilo
@Ahora
@r0 = r0 
@lr = pc. vuelve al lugar donde debia ir
@siempre como ult instruccion para conservar el valor del lr

@OPERACION ARITMETICO-LOGICAS
@Oprn 2 es mas versatil
oper   regd, regn, Oprn2 @el regn siempre debe ser un registro
add r0, r1, r2 @r0 =  r1 + r2 
sub r0, r1, r2 @r0 =  r1 - r2 se guarda en el primero
@reverse substract
rsb r0, r1, r2 @r0 = r1 - r2
mul r0, r1, r2 @ro = r1*r2

@Instruccion logicas
@SON BIT A BIT.
@AND
@ (r5) = (r0) AND (r1)
and r5, r0, r1

@OR
@ (r6) = (r0) OR (r1)
orr r6, r0, r1

@EXCLUSIVE OR
@true y true = false
@false y falase = false
@1 y 0 = 1
@0 y 0 = 1
@ (r7) = (r0) XOR (r1)
eor r7, r0, r1

@---------------------------------------------
@SHIFT - BARREL SHIFTER

@SHIFT IZQUIERDO
1001 1100 R8
-> Si aplico un shift izquierdo de 1 BIT
@entonces pierdo el primer bit de la izquierda
1001 1100 <1 bit
|001 1100 @Corto el primer bit
001 1100? @corro a izq
@la shift rellena los ??? con 0's
001 11000

-> SHIFT IZQUIERDO DE 2 BITS (SHITEO 2 VECES A IZQ)
@multiplico por 10 en base 2
@multiplico por 2^bitsShifteados
1001 1100 R8
\\01 1100 @corto los 2 primeros bits
0111 00?? @corro a izq
0111 0000 @rellena con 0's a der para completar lo q deje al correrme

@SHIFT LOGICO 
@->reemplaza el ? por 0's
@SHIFT DERECHO
@divido por 10 en base 2
-> de 1 bit
1001 1100 R8
1001 110\ R8 @corto ult bi
?1001 110  R8 @corro a der
01001 110  R8 @rellena con 0's a izq para completar lo q deje al corererme

@SHIFT ARITMETICO
@EL bit que reemplaza a los ? es el bit de signo
@relplica el primer bit
@si era 1, 1 si era 0 0.
@->reemplaza el ? por 0's
-> aritmetico de 2 bits
1001 1100 R8
1001 11\\ R8 @corto ult bi
??10 0111 R8 @corro a der
1110 0111 R8 @rellena con 0's a izq para completar lo q deje al corererme

@____EN ARM_______
@le aplica el barrel shifter al contenido del registro 1 de n bits
@y lo guarda en el r0. NO SE MODIFICA EL R1
@ n bits a shiftear pueden estar en
@- un inmediato
@- el byte inferior de otro registro q no sea el r15

@Logical Shift Left
@ r0 = shift izquierdo de (r1) en n bits
mov r0, r1, LSL #n @ LSL: logical shift left

@Logical Shift Right
@ r0 = shift izquierdo de (r1) en n bits
mov r0, r1, LSR #n @ LSL: logical shift left

@Arithmetich Shift Right
@ r0 = shift izquierdo de (r1) en n bits
mov r0, r1, ASR #n @ LSL: logical shift left

@se puede hacer
mov r1, r1, LSR #n solo hago la shift de r1 y SI lo modifico

@