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
    ;todo lo q se ingresa por teclado se interpreta como caracteres ascii asi q si por ej uno mete 0 no pasa nada
    msjIngTexto     db "Ingrese un texto por teclado (max 99 caracteres)",0; el enter es el caracter 99
    msjIngCaracter  db "Ingrese un caracter: ",0

    ;Mensajes para informarle al usuario del resultado

    contadorCarac   dq 0; define quoter quod inicializado en 0
    longTexto       dq 0; para saber la longitud total del texto
    ;porcentaje      dq 0; podria ir aca el calculo de %
    
    ;para que el usuario ingrese el texto
    msjTextoInv     db "Texto invertido: %s ",10,0 ;el 10 genera un /n, salto de linea y el 0 es xa cortar el printf
    msjCantidad     db "El caracter %c aparece %lli veces.",10,0. ; %c es el caracter lli es long long int
    msjPorcentaje   db "El porcentaje de aparicion es %lli %%",0

section     .bss    ;sin contenido
    
    texto       resb    500 ;reservo 500 bytes exagerado para un texto que ingresara el usuario. Si se pasa me pisa el sig ingreo
    textoInv    resb    500 ;y otro espacio igual de grande para el texto invertido
    ;No es necesario definir una variable para iterar. No es unica la solucion
    ;se podia iterar el texto con esa variable como indice
    caracter    resb    50; para guardar el caracter sobre el q estoy parado 
    ;porcentaje  resq    1;  (q = 8 bytes) tambien aca pero vamos a hacer !=
    ;assss

section     .txt; aca va el algoritmo, la logica
main:
; ingreso texto
    ;mensaje pidiendo el texto
    ;como para imprimir con puts el primer parametro de puts debe estar en el resgistro rcx..
    mov     rcx, msjInTexto
    sub     rsp, 32 ;x el llamado a una funcion externo. Es debido al registro de stack pointer
    call    puts
    add     rsp, 32

;ingreso por teclado del texto
    mov     rcx, texto; el parametro es el buffer donde guardo lo q ingreso el usuario (en .bss)
    sub     rsp, 32
    call    gets
    add     rsp, 32

;ingreso de caracter
    mov     rcx, caracter 
    sub     rsp, 32
    call    gets
    add     rsp, 32

;recorrer cadena de caracteres. Una manera es con un indide.
;otra es recorrerlo con un registro. En gral se usa el rsi
    mov     rsi,0; lo inicializamos en 0 y le vamos incrementando el indice
    ;cuando el usuario termina el ingreso de la cadena de caracteres hace un 'enter'
    ;entonces el 0 q se genera es nuevo punto de corte. 

compCaracter:

    cmp     byte[texto + rsi],0; altera el flag de registro de flags
    ;estoy restando la variable en mem texto + el valor del rsi - 0.
    ;Luego comparo si los dos operandos de la instruccion compare eran iguales 
    ;(estoy chequeando si el ZF esta prendido, cosas que ocurrira solo con 0 - 0 = 0)
    je      finString 
    ;si son iguales salta al rotulo finString. 
    ;-> Si no son iguales, sigue dando vueltas, incrementando la long del rsi
    inc qword[longTexto] ;ingrementa en 1 longTexto

    ;cmp     caracter, byte [texo + rsi]; ESTO ES UN 2 EN EL PARCIAL XD
    ;esto se debe a q no se puede hacer comparacion de mem a mem. solo contra registros o inm
    mov     al,byte[texto + rsi] ; guardo el caracter leido del texto en al
    cmp     al, byte[caracter]; y luego comparo en byte de carcater q ingreso el usuario
    jne     sgteCarac; si el caracter no es el mismo 
    ;-> Si no entro en jne, osea que son iguales    
    inc     qword[contadorCarac]

sgteCarac:
    inc     rsi; para recorrer el vector
    jmp     compCaracter; bifurcamos "hacia arriba para que funcione como un ciclo de iteraciones"
    ;Esto va a iterar hasta que se cumpla la condicion en linea 77 je   finString

;ya contamos cuantas apariciones hubo de cada caracter

finString: ;este rotulo va afuera del ciclo
;invierto texto
    
    mov     rcx, qword[longTexto] ;copio la pos del ult caracter al rcx 
    mov     rdi, 0; para q apunte al primer caracter de textoInv y almacene los chars de forma invertida
    
    comp    rcx,0
    je      finCopia
    
    ;puedo aprovechar que mi indice rsi quedo en la ult pos del texto para recorrerlo al reves
    ;mov     byte[textoInv + rdi], byte [texto + rsi -1]; 2 en el parcial xq la mov no permite copiar de mem a mem 
    mov     al, byte[texto + rsi - 1] ; el menos 1 xq no quiero copiar el byte 0 de control
    ;copio transitoriamente al regitro al
    mov     byte[textoInv + rdi], al; y dsps copio el caracter al la primera pos del texto invertido
    
    ;Ahora tengo avanzar el rdi y que retroceder el rsi para ir invirtiendo y luego restarle rcx
    ;xq tengo que ir achicando la long de texto para saber hasta donde leer
    inc     rdi
    dec     rsi
    dec     rcx

    ret