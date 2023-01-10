@PARTE 3
@-Acceder a valores en memoria con ldr
@-Almacenar valores en memoria coin str
@-Iterar sobre vectores en memoria

@ARM es una arquitectura load store, osea que para poder trabajar con
@la memoria tiene traer informacion a los registros desde la memoria
@o de la memoria hacia los registros

@NO HAY INSTRUCCIONES Q TRABAJEN DIRECTAMENTE CON LA MEMORIA
@(no exiten instruccion mem,mem)
@solo se puede operar con la mem a traves de las oper de load store

@repaso de como funca ldr

@___________STRINGS
    .data

mensaje:
    .asciz "hola_mundo"

    .text
    ldr r0,= mensaje @ldr retiene la direc de memoria del str
    @r0 APUNTA a la direc de memoria donde esta el str hola_mundo   

@___________ENTEROS
    .data

mensaje:
    .asciz "hola_mundo"

entero1:
    .word 42
    @OJO en arm una word son 32 bits, 4 bytes
    @HALF WORD 16 BITS = 2 bytes (cada registro mide esto (creo) )
entero2:
    .word 38

    .text
    ldr r0, =entero1 
    @r0 no guarda el contenido, guarda l DIRECCION de mem
    ldr r1, [r0] @guardo lo q apunta el r0 en r1 [r0]
    @r0 = 96372040
    @r1 = 42

@COMO ALMACENAR UN ENTERO EN MEMORIA?
    
    ldr r0, =entero1 @r0 apunta a entero 1
    mov r1, #57 
    str r1, [r0] @store en r0 la DIRECCION de memoria de lo q hay en r1
    @str r1 -> [r0] 
    @ENTERO 1 = 57. se pisa

@---------------- Práctica 15: Imprimir y reemplazar enteros almacenados en memoria------------


@______________ ARRAYS_______________
@Se especifican multiples valores con la directiva word

    .data
entero1:
    .word 42
array:
    .word 32, 65, 76, 87

@xa acceder, enfoque de siempre, incrementar la pos en memoria
@de a 4 bytes (32 bits) = 1 word x c/ ele del array
    .text 
    ldr r0, =array @r0 = direc de mem. levanto la pos inicial del array
    ldr r1, [r0]   @guardo lo q apunta r0 en r1 = 32 (el 1er ele del array)
    add r0, r0, #4  @r0 +=4 
    ldr r2, [r0]   @r2 = 2do ele del array = 65
    add r0, r0, #4
    ldr r3, [r0] @3er ele del array = 76

@------- PRACTICS 16: ------ Registro indirecto

@------- PRACTICA 17: ------ Registro indirecto con post incremento

@r1 = direc de mem en r2.
@y al mismo [r2] + 4 bytes
@esto es post incremento. Agregarle al final de la load que hago de mem
@lo q incremento el r2. Lee y suma.
ldr 	r1, [r2], #4


@MODOS DE DIRECCIONAMIENTO

@1) Por registro indirecto:
ldr r3,[r0]
@un registro apunta a una parte de la mem (r0)
@y usando ese registro como puntero, accedo a la info en mem

@2) Por registro indirecto con offset:

@3) registro indirecto con pre-incremento

@4) registro indirecto con pot-incremento


@------- PRACTICA 18: ------ Registro indirecto con reg indexado

@FALTA

@------- PRACTICA 19: ------ Registro indirecto con reg index escalado

@FALTA

@------- PRACTICA 20: ------ Minimo en array

@------- PRACTICA 21: ------ Suma cte en array





