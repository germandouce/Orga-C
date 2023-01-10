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
movmi r0, #42   @movminus mover solo si el bit negativo esta encendido (<0)
movpl r0, #42   @movplus mover solo si el bit negativo NO esta encendido (>=0)
moveq r0, #42   @movequal mover si el cero esta encendido (=0)
movne r0, #42   @movnotequal mover solo si el cero NO esta encendido (!=0)


@TODAS LAS INSTRUCCIONES PUEDEN MODIFICAR LOS BITS DE SIGNO
@(aparte de cmp)
@HAY QUE AGREGARLE LA S.
@ejemplo
@subs
@adds

@------- PRACTICA 7 ------- Cálculo de valor absoluto con instrucciones condicionales 

@INSTRUCCION BRANCH (b)
@es com un jmp
@Se utiliza para saltar a una seccion de codigo marcado con una etiqueta
@branch nombre etiqueta
@ejemplo:
b otra  @incondicional, se ejecuta siempre
    @...
    @esto nunca se ejecuta
    @...
otra:


@Branch condicional
@salta a una seccion de codigo y vuelve
@es como una call
mov r1,#0
cmp r1,#5
beq otrolado    @Pregunta por los bits de estado que acaba de fijar el cmp

mov r0,#25

otrolado:
    mov r2, r0

@Cuando usar b y cuando b etiquetado
@- Si son muchas instrucciones complejas es mejor usar branches
@etiquetados
@-cuando tenga instrucciones anidadas (varias condiciones) conviene solo brach
@-condiciones simples (hasta 3 instrucciones, conviene la condicional)

@------- PRACTICA 8 ------- Cálculo de valor absoluto con bifurcación

@------- PRACTICS 9: ------ Cálculo de mínimo y máximo

@------- PRACTICS 10: ------ Cálculo de mínimo y máximo

@FALTAAAA


@_____________LOOPS___________________
@clqr for se puede convertir en while
@Se utiliza la instruccion Branch con saltos al inicio
@o al fina de un loop

@------- PRACTICA 11: ------# imprima los números del 0 al 9.

@3 tipos de loops

@DO WHILE
@al final del ciclo hacemos una branch condicional al ppio del ciclo
@si no se cumple vuelvo al inicio

@WHILE DE 1 A N VECES
@Chequeo al ppio del ciclo, si la condicion de corte se cumplio
@y segun eso entro o no entro con una bifurcacion al final del ciclo
@y al final del ciclo una bif INCONDICIONAL al ppio del ciclo



@------- PRACTICA 12:------ Cálculo de factorial
 
@------- PRACTICA 13:------ Cálculo de factorial recursivo

@------- PRACTICA 14:------ Fibonacci 
@(No hecho)

@Mas explicacion y aplicaciones de loops


