
;_____________impresion por pantalla de un string solito__________________
section .data
    mensaje     db  "Hola Intel en Windowssssssssssss",10,0

section .text

    mov     rcx,mensaje
    sub     rsp,32
    call    puts
    add     rsp,32

;_____________impresion por pantalla con numeros formateados_____________
section .data

    msjSumatoria        db  "La sumatoria es : %i",10,0 ; %i 32 bits (doble plbra dword).
    msjSumatoria        db  "La sumatoria es : %lli",10,0 ; %i 64 bits (doble plbra qword).

section .bss    
sumatoria           resd    1


section .text
    mov             rcx,msjSumatoria
    ;mov             edx,dword[sumatoria] ;esto tiraria error xq rdx es de 64 bits y sumatoria era de 32 bit
    mov             rdx,0 ; ;para asegurarme que en los bits superiores del rdx haya ceros
    mov             edx,dword[sumatoria]; poner el dword ya que estoy fromateando un numero de menos de 64 bits
    sub             rsp,32
    call            printf
    add             rsp,32


;___________________pedido e ingreso de datos por teclado______________
section .data

    formatInputFilCol   db "%hi %hi",0 ;hi (16 bits, 2 bytes 1 word).         ;esto es para el sscanf
    inputFilCol         resb    50 ; para que me sobre y siempre al FINAL DE LA SECCION

section .text

ingresoDatos:

    mov             rcx,inputFilCol
    sub             rsp,32
    call            gets ;solo lee lo ingresado como texto y lo guarda en rcx. No castea nada.
    add             rsp,32  

    call            validarFyC ;validamos. en esa rutina modificamos el valor de 'inputValido'
    cmp             word[inputValido], "N" ;N - no valido / S - valido
    je              ingresoDatos

;_____________Rutina para validar ingreso de numeros en un rango_________________

validarFyC:
    ;Esperamos valores del tipo "[1..5] [1..5]" para Fila - Columna
    mov             byte[inputValido], "N"; Supongo inicialmente que el ingreso fue incorrecto

    ;formateo
    mov             rcx,inputFilCol; toma el ingreso por teclado fuere cual fuere. ANTES DEBO HABER USADO GETS
    mov             rdx,formatInputFilCol; formatea el ingreso como lo diga la variable 'formatInputFilCol'. El 
    mov             r8,fila ;xa guardar el valor de la fila
    mov             r9,columna ;xa guardar el valor de la columna
    sub             rsp,32
    call            sscanf ;nos devuelve la cant de numeros casteados exitosamente en el RAX.
    add             rsp,32

    ;validacion fisica (casteo los 2 valores enteros, ie, se ingresaron solo enteros no letras o chars especiales)
    cmp             rax,2 ;
    jl              invalido

    ;validacion logica x rango (Chequeo q la fila y la columna esten en el rango 1 a 5) 
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

    mov             byte[inputValido], "S" ;pongo una S para dar el okey de q se ingreso bien

;_____________Rutina para calcular desplazamiento en una matriz_________________
calcDesplaz:
    ;Suponiendo que el indice arranca en 1
    ;calculo de desplaza hasta llegar (fila, col) de la matriz
    ;[(fila - 1) * LongFila] = [ (columna -1) * LongElemento]    con longFila = longElemento * CantDeColumnas
    ;[(fila - 1) * (longElemento * CantDeColumnas)] = [ (columna -1) * LongElemento]       

    ;desplazamiento fila
    mov             bx,word[fila] ;
    sub             bx,1 ;(fila -1)
    imul            bx,bx,10 ;(fila -1) * Longfila = (fila -1) *(longElemento*CantCol) = (fila -1)* 2bytes(word) *5 = (fila -1)*10
    ;guardo desplazamiento FILA en DESPLAZ xa poder seguir usando bx
    mov             word[desplaz], bx
    
    ;desplazamiento columna
    mov             bx,word[columna]
    sub             bx,1
    imul            bx,bx,2 ;word = 2 bytes 
    ;dejo en BX el desplazamiento de la COLUMNA
    
    ;sumo los desplazamientos
    add             word[desplaz],bx 
    ;Dejo en DESPLAZ tengo el desplazamiento TOTAL

    ret


;_____________Rutina para caclular una sumatoria con loop de numeros de una matriz_________________

section .data

section .bss

sumatoria         resd    1; reservo un double (4 bytes 32 bits x si la suma es muy grande)

section .text 
main: 

    call            calcSumatoria

calcSumatoria:
        
        mov     dword[sumatoria],0 ;inicializo en 0 la variable sumatoria xa q no tenga basura
        
        ;loop labura con el registro RCX
        mov     rcx,0; completo 0's xq voy usar una parte mas chica
        mov     cx,6 ;indico el numero de vueltas (columnas_totales(5) + 1) = 6 (_*RCX*_)
        sub     cx,word[columna] ;  - columna_elegida. y lo guardo en RCX que hace de contador
        ;(esta formula se dedujo de una consigna puntual)

        ;uso RBX DE PUNTERO (BASE) para guardar el desplaz
        mov     rbx,0 ;relleno con 0's y uso BX de puntero indice
        mov     bx,word[desplaz] ;copio el desplaz a ese registro xa marcar el inicio.
        ;desplaz tiene la cant de bytes a saltear xa llegar a la pos indicada por la fila y columna

;esta dentro de calcSumatoria
sumarSgte: ;(_*RCX*_)
        ;uso AX para levantar cada elemento de la matriz q son de tipo word
        mov     rax,0 ;inicializo RAX en 0 para asegurarme que lo q viene antes de ax no tiene basura.
        ;sumo a la direc inicial de la matriz + los bytes para llegar a la pos i j
        ;y luego guardo el [CONTENIDO] de esa "pos de mem" n la q estoy parado en ax
        mov     ax,word[matriz + rbx] 

        ;como dije q iba a guardar el resultado de la suma en una dobleWord, uso eax (ya rellene con 0's)
        add     dword[sumatoria],eax ;con eso hice la 1era (N'ava) suma parcial

        ;muevo el puntero indice sumando 2 (Bytes). matriz con elementos doubleWords d 2 Bytes
        add     rbx,2
        
        ;(_*RCX*_)
        loop sumarSgte ;loop hace rcx - 1 , compara y si es = a 0 sigue de largo, sino otra vuelta

        ret

;____________Manejo de archivos externo txt_______________
;Claves/ resumen/ cosas que no me acuerdo? 
;q mas agrego aca??

