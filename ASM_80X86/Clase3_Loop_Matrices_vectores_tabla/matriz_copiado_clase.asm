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

;1 1 1 1 1
;2 2 2 2 2
;3 3 3 3 3
;4 4 4 4 4
;5 5 5 5 5

;x ejemplo 
;fila 3  columna 2 -> deberia sumar todos los 3 de la fila 3 
;comenzando dde la 2da columna
;  1     1   1   1   1
;  2     2   2   2   2 
; 3(no!) 3 + 3 + 3 + 3 = 12

;vamos a usar un ejempo de 5x5 pero vamos a intentar q sea "standard"
;vamos a reservar memoria en .bss xq si o si necesitamos 

global main
extern printf
extern puts
extern sscanf ;interpreta una cadena de texto segun los calificadores q puse en la cadena
;xa eso usamos la variable FormatInputFilCol
extern gets

section     .data   ;variables con valores predefinidos (repaso jeje)

        ; simplificamos el ejemplo definiendo una matriz de 5x5 (dw, define word)
        ; podria haber puesto 0 en todos lados en vez de 1
        ;matriz      times 25 dw 1; 25 veces valores de 2btyes con valor inicial 1 (1 en todas las pos de la matriz)

        ;otra alternativa no tan habitual. Asi le podemos meter distintos valores a cada casillero
        ;para la maquina una matriz es una tira de bytes
        matriz  dw  1,1,1,1,1
                dw  2,2,2,2,2
                dw  3,3,3,3,3
                dw  4,4,4,4,4
                dw  5,5,5,5,5 
        ;asi no tenemos q cargar la matriz

        ;10 = \n 13 = "retorno de carro, pone cursor al inicio de la linea" 0 = "corta el printf" 
        msjIngFilCol        db "Ingrese fila (1 a 5) y columna (1 a 5): ",10,0 ;recordar 10 para \n y 0 para cortar el printf o puts 
        formatInputFilCol   db "%hi %hi",0 ;hi (16 bits, 2 bytes 1 word)
        ;esto es para el sscanf

        msjSumatorial       db "La sumatoria es : %i",10,0 ; %i 32 bits (doble plbra dword dd)


section     .bss
        ;tambien se podia definir la matriz aca con
        ;matriz  times 25 resw 1; estoy reservando espacio para una matriz sin valores iniciales
        ;25 veces un espacio de tam word (2 bytes)

        fila            resw    1
        columna         resw    1
        inputValido     resb    1 ;un caracter para usar como variable de control que valide 
        ;"S" valido "N" invalido. Es interna mia.

        sumatoria       resd    1 ;rserve 4 bytes por si la sumatoria llega  dar muy grande

        inputFilCol     resb    50;"para el texto por teclado, en este caso, fila y col"
        ;como gets (y sscanf???) es un funcion insegura siempre la defino como ult variable en el campo bss
        ;y siempre le defino espacio de mas para que no sobrepase el tamanio

section     .text

main:
        ;imprimo por pantalla pedido de fil y columna (rcx)
        mov             rcx,msjIngFilCol
        sub             rsp,32
        call            printf
        add             rsp,32

        ;pido fila y col (rcx la variable donde guardo)
        mov             rcx,inputFilCol
        sub             rsp,32
        call            gets ;solo lee lo ingresado como texto. No castea nada
        add             rsp,32

        call            validarFyC ;vamos a validar que la fila y la columna esten en el rango deseado
        ;colocando una letra dentro la var reservada parea eso en la subrutina
        ;comparamos el contenido del input del usuario contra las letra q metimos en la subrutina.                                
        cmp             [inputValido], "N" ; el contenido de inputValido
        ;si me encuentro una letra N en inputValido es que el ingreso del usuario no era valido
        je              ingresoDatos ; entonces bifurco al rotulo ingresoDatos y pido todo de vuelta
        
        ;pareceria q conviene meter solo los rotulos y dsps escribir el codigo de ellos

        ;si los datos son validos, subrutina para calcular desplazamiento
        call            calDesplaz
        
        ;subrutina para calcular sumatoria de elementos de la fila dde col dada
        call            calcSumatoria
        

        ;subrutina para motrar por pantalla resultado de la sumatoria
        ;call            
        mov             rcx,msjSumatoria
        ;mov             edx,dword[sumatoria] ;esto tiraria error xq rdx es de 64 bits
        ;y sumatoria era de 32 bits
        ;para asegurarme que en los bits superiores del rdx haya ceros
        mov             rdx,0 
        ;       [010101010 RDX            ] 64 bits
        ;       [-basura-  RDX             ] 64 bits
        ;       [000000000 RDX             ] 64 bits
        ;                 [     EDX       ] 32 bits
        ;                       [   DX    ] 16 bits
        ;                       [ DH | DL ]


        mov             edx,dword[sumatoria]; ahora si! 
        ;el dword[] tiene q ir siempre que voy a formatear un numero en el printf 
        ;de menos de 64 bits (32 bits en este caso)
        sub             rsp,32
        call            printf
        add             rsp,32


ret

;*************************************
;RUTINAS INTERNAS
;*************************************
validarFyC:
        ;Esperamos valores del tipo "[1..5] [1..5]" para Fila - Columna
        mov             byte[inputValido], "N"; Le coloco un no a la var. es como un false antes del ciclo

        ; voy a usar 4 parametros para sscanf
        mov             rcx,inputFilCol; tomado el ingreso por teclado fuere cual fuere
        mov             rdx,formatInputFilCol; formatea el ingreso como lo escribi
        mov             r8,fila ;xa guardar el valor de la fila
        mov             r9,columna ;xa guardar el valor de la columna
        sub             rsp,32
        call            sscanf ;nos devuelve la cant de resultados casteados exitosamente en el rax. 
        ;Sirve como validacion fisica de que no se hayan ingresado letras o chars especiales porque castea a enteros 
        add             rsp,32

        ;chequeo q haya casteados los 2 valores enteros ( por ej 3 E daria 1)
        cmp             rax,2 
        jl              invalido
        
        ;Chequeo q la fila y la columna esten en el rango 1 a 5 validacion logica x rango
        ;la fila
        cmp             word[fila],1
        jl              invalido
        cmp             word[fila],5
        jg              invalido
        ;chequeo la columna
        cmp             word[columna],1
        jl              invalido
        cmp             word[columna],5
        jg              invalido
        
        ;N:B todas las funciones externas devuelven algo por el registro rax, asi q cuidado porque puede
        ;pisar cosas

invalido:
        

        ret

CalcDesplaz:
        

        ret