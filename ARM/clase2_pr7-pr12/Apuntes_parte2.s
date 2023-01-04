@TEMAS
@-> instruccion cmp
@-> instruccion condicionales
@->sentencias condicionales simples y complejas
@---> LOOPS IMPORTANTE <------
@recursividad, pila xa mejorar complejidad de un algortimo (gue)

@INSTRUCCION COMPARE
@resta dos operandos y descarta el resultado. Solo setea los bits de estado.
@El bit de carry, cero y overflow
Compare (cmp)
@ejemplo
mov r0, #5 @r0 = 5
cmp r0, #5 @r0 = 5 ?? setea el cero flag xq hace la resta
@son iguales

mov r0, #5  @r0 = 5
cmp r0, #20 @5 vs 20 se prende el negativo xq hace r0 - 20 = 5-20 = -15

@EJECUCION CONDICIONAL
@En arm todas las instrcciones se ejecutan condicionalmente a los bits de estado
@si el bit esta como la condicion que puse en el nemonico
movmi r0, #42   @mover solo si el bit negativo esta encendido (<0)
movpl r0, #42   @mover solo si el bit negativo NO esta encendido (>=0)
moveq r0, #42   @mover si el cero esta encendido (=0)
movne r0, #42   @mover solo si el cero NO esta encendido (!=0)


@TODAS LAS INSTRUCCIONES PUEDEN MODIFICAR LOS BITS DE SIGNO
@(aparte de cmp)
@HAY QUE AGREGARLE LA S.