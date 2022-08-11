;*******************************************************************************
; textoL.asm
; Ingresar por teclado un texto y luego un caracter e imprimir por pantalla:
;   - El texto de forma invertida
;   - El cantidad de apareciones del caracter en un texto
;   - El porcentaje de esas apariciones respecto de la longitud total del texto
; 
;*******************************************************************************
global main
extern puts
extern gets
extern printf

section     .data   ;con contenido
    
    ;Texto para que el usuario ingrese texto y caracter. Se recomienda doble 
    ;comillas para cadenas de chars
    msjIngTexto     db "Ingrese un texto por teclado (max 99 caracteres)",0
    msjIngCaracter  db "Ingrese un caracter: ",0

    ;Mensajes para informarle al usuario del resultado

    contadorCarac   dq 0; define quoter quod inicializado en 0
    longTexto       dq 0; para saber la longitud total del texto
    ;porcentaje      dq 0; podria ir aca el calculo de %



section     .bss    ;sin contenido
    
    texto       resb    500 ;reservo 500 bytes exagerado para un texto que ingresara el usuario
    textoInv    resb    500 ;y otro espacio igual de grande para el texto invertido
    ;No es necesario definir una variable para iterar. No es unica la solucion
    ;se podia iterar el texto con esa variable como indice
    caracter    resb    50; para guardar el caracter sobre el q estoy parado 
    ;porcentaje  resq    1;  (q = 8 bytes) tambien aca pero vamos a hacer !=

section     .txt
main:
    
    ret