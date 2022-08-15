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

;3 1 ->  toda la fila 3, 5*3 = 15
;3 4 -> ults 2 valores de la fila 3 -> 3 + 3 = 6

;formula para cant de veces a sumar: 
;(columnas_totales + 1) - columna_elegida
;col 2 -> (5 + 1)       -       2         = 4 veces
;
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

        msjSumatoria        db "La sumatoria es : %i",10,0 ; %i 32 bits (doble plbra dword dd)


section     .bss
        ;tambien se podia definir la matriz aca con
        ;matriz  times 25 resw 1; estoy reservando espacio para una matriz sin valores iniciales
        ;25 veces un espacio de tam word (2 bytes)

        fila            resw    1
        columna         resw    1
        inputValido     resb    1 ;un caracter para usar como variable de control que valide 
        ;"S" valido "N" invalido. Es interna mia.

        desplaz         resw    1

        sumatoria       resd    1 ;rserve 4 bytes por si la sumatoria llega  dar muy grande

        inputFilCol     resb    50;"para el texto por teclado, en este caso, fila y col"
        ;como gets (y sscanf???) es un funcion insegura siempre la defino como ult variable en el campo bss
        ;y siempre le defino espacio de mas para que no sobrepase el tamanio

section     .text

main:
ingresoDatos:

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
        cmp             word[inputValido], "N" ; el contenido de inputValido
        ;si me encuentro una letra N en inputValido es que el ingreso del usuario no era valido
        je              ingresoDatos ; entonces bifurco al rotulo ingresoDatos y pido todo de vuelta

        ;je              main; es lo mismo
        ;pareceria q conviene meter solo los rotulos y dsps escribir el codigo de ellos

        ;si los datos son validos, subrutina para calcular desplazamiento
        call            calcDesplaz
        
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
        call            sscanf ;nos devuelve la cant de numeros casteados exitosamente en el RAX.
        ;Sirve como validacion fisica de que no se hayan ingresado letras o chars especiales porque castea a enteros 
        add             rsp,32

        ;chequeo q haya casteados los 2 valores enteros ( por ej 3 E daria 1)
        cmp             rax,2 ;
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

        mov             byte[inputValido], "S";pongo una S para dar el okey de q se ingreso bien
        
        ;N:B todas las funciones externas devuelven algo por el registro rax, asi q cuidado porque puede
        ;pisar cosas

invalido:
        
        ret

calcDesplaz:
        ;Suponiendo que el indice arranca en 1
        ;calculo de desplaza hasta llegar (fila, col) de la matriz
        ;[(fila - 1) *LongFila] = [(columna -1)*LongElemento]
        ;longFila = longElemento * CantDeColumnas

        ;desplazamiento fila
        mov             bx,word[fila] ;
        sub             bx,1 ;restamos 1 porque el indice empieza en 1
        imul            bx,bx,10 ;(fila -1)*Longfila = (fila -1) *2bytes (word) *5 
        ;dejo en bx, desplazamiento de la fila
        ;guardo momentaneamente el desplazamiento en desplaz xa poder seguir usando bx
        mov             word[desplaz], bx
        
        ;desplazamiento columna
        mov             bx,word[columna]
        sub             bx,1
        imul            bx,bx,2 ;word = 2 bytes 
        ;dejo en bx el desplazamiento de la columna
        
        ;sumo los desplazamientos
        add             word[desplaz],bx ;en desplaz tengo el desplazamiento total

        ret

calcSumatoria:
        
        mov     dword[sumatoria],0 ;inicializo en 0 la variable sumatoria xa q no tenga basura
        
        ;loop labura con el registro RCX (counter xd)
        mov     rcx,0
        mov     cx,6 ;(columnas_totales(5) + 1) = 6 (_*RCX*_)
        sub     cx,word[columna] ;  - columna_elegida. y lo guardo en RCX que hace de contador
        
        ;uso RBX de puntero (Base) para guardar el desplaz
        mov     rbx,0 ;relleno con 0's y uso BX de puntero indice
        mov     bx,word[desplaz] ;copio el desplaz a ese registro xa marcar el inicio.
        ;desplaz tiene la cant de bytes a saltear xa llegar a la pos indicada por la fila y columna

sumarSgte: ;(_*RCX*_)
        ;uso AX para levantar cada elemento de la matriz q son de tipo word
        mov     rax,0 ;inicializo RAX en 0 para asegurarme que lo q viene antes de ax no tiene basura.
        ;le sumo a la direc inicial de la matriz los bytes para llegar a la pos i j
        ;y luego guardo el [CONTENIDO] de esa "pos de mem" n la q estoy parado
        mov     ax,word[matriz + rbx] 

        ;como dije q iba a guardar el resultado de la suma en una dobleWord, uso eax
        add     dword[sumatoria],eax ;con eso hice la 1era (N'ava) suma parcial

        ; sumo 2 (Bytes) al puntero q uso de indice debido a q es una matriz con elementos doubleWords d 2 Bytes
        add     rbx,2
        
        ;(_*RCX*_)
        loop sumarSgte ;loop hace rcx - 1 , compara y si es = a 0 sigue de largo, sino otra vuelta

        ret