;Formulita clave para matrices:
;__Posicionamiento en elemento i de un vector:__
;PosV = (i - 1) * longElemento

;__Posicionamiento en el elemento i,j de una matriz__
;PosM = (i - 1) * longFila + (j - 1) * longElemento
;Un ejemplo
;Dada una matriz (3 filas x 4 columnas) del tipo doble (dword, 4 bytes)
;Se pide cargar un valor en el elemento de la fila 2 y la columna 3
global main
extern puts
extern printf

section .data
    posX            dd 02 
    posY            dd 03
    longFila        dd 16 ;4 (por ser tipo doble) * 4 cols
    longElemento    dd 4    
    
    mensaje1	db	'Imprimo con printf el primer numero %lli',10,  

section .bss
    matriz times 12 resd 1 ; 12* 4 byes = 48 bytes (3 filas * 16 bytes c/u = cal = 48)

section .text
main:
    
    mov     ebx,matriz      ;guardo la direc donde empieza mi matriz

    ;obletener pos en fila: (i-1) * LongFila
    mov     eax,dword[posX] ;guardo el valor de la fila en el resgitro EAX
    sub     eax,1 ; le resto 1 a la pos de fila (i-1)
    ;dec    eax 
    imul    dword[longFila] ;multiplico por la longitud de la fila (i-1) * LongFila
    ;esto ult vale porque imul labura con el EAX
    add     ecx,eax         ;guardo en ECX deplazamiento de la i-fila
    ;4
    ;obletener pos en col: (j - 1) * LongElemento
    mov     eax, dword[posY]    ;guardo el valor de la fila en EAX
    sub     eax,1 ;le resto 1 a la pos de columna (j-1)
    ;dec    dec
    imul    dword[longElemento] ;(j - 1) * longElemento (4 bytes em este caso, podria ponero directo)
    ;me quedo el desplazamiento en la j-columna en EAX
    ;8
    
    ;Sumo los 2 desplazamientos
    add     ecx,eax ;me queda en el resgistro contador el desplazamiento total
    ;Le sumo el desplazamientoTot a la direc de inicio de la matriz,
    add     ebx,ecx

    ;Proceso y coloco lo q queria en la pos deseada que quedo en ebx
    mov     dword[ebx],1
    ;pongo dword para no olviarme q son 2 bytes x celda, asi no me como las celdas con el registro

    ;Muestro por pantalla el dato accediendo a la matriz sabiendo que en ebx quedo la direc del dato
    mov     rcx, mensaje1
    mov    rdx,0 ;para completar 0's a izq del regsitro y q no quede con basura
    mov     edx, [ebx]
    ;mov	rdx,[ebx] ; probar con edx y agregar dword

    sub     rsp,32
    call    printf
    add     rsp,32

ret

