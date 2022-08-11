;*******************************************************************************
; textoL.asm
; Ingresar por teclado un texto y luego un caracter e imprimir por pantalla:
;   - El texto de forma invertida
;   - El cantidad de apareciones del caracter en un texto
;   - El porcentaje de esas apariciones respecto de la longitud total del texto
; 
;*******************************************************************************
global  main
extern	puts
extern  gets
extern  printf

section     .data
	msjIngTexto		db	"Ingrese un texto por teclado (max 99 caracteres)",0
    msjIngCaracter  db  "ingrese un caracter: ",0
    contadorCarac   dq  0
    longTexto       dq  0
    msjTextoInv     db  "Texto invertido: %s",10,0
    msjCantidad     db  "El caracter %c aparece %lli veces.",10,0
    msjPorcentaje   db  "El porcentaje de aparicion es %lli %%",0

;Para debug
    msjLongTexto    db  "Longitud de texto: %lli",10,0
    
section     .bss
    texto    resb    500
    caracter    resb 50
    textoInv    resb 100

section     .text

main:
;   Ingreso texto
    mov     rdi,msjIngTexto
    call    puts

    mov     rdi,texto
    call    gets  

;   Ingreso caracter
    mov     rdi,msjIngCaracter
    call    puts
    
    mov     rdi,caracter
    call    gets
    

    mov     rsi,0
compCaracter:
    cmp     byte[texto + rsi],0
    je      finString
    inc     qword[longTexto]

    mov     al,[texto + rsi]
    cmp     al,[caracter]
    jne     sgteCarac
    inc     qword[contadorCarac]
sgteCarac:
    inc     rsi
    jmp     compCaracter
finString:

;   Invierto texto
    mov     rcx,[longTexto]
    mov     rdi,0   ;para q apunte al primer caracter de textoInv
copioCarac:
    cmp     rcx,0
    je      finCopia
    mov     al,[texto + rsi - 1]
    mov     [textoInv + rdi],al
    inc     rdi
    dec     rsi
    dec     rcx
    jmp     copioCarac
finCopia:
    mov     byte[textoInv + rdi],0


mov     rdi,msjLongTexto
mov     rsi,[longTexto]
sub     rsp,8   ;ACOMODO EL PUNTERO A LA PILA SOLO PARA PRINTF EN LINUX
call    printf
add     rsp,8   ;VUELVO EL PUNTERO A LA PILA A SU VALOR ANTERIOR

;   Imprimo texto invertido
    mov     rdi,msjTextoInv
    mov     rsi,textoInv
    sub     rsp,8   ;ACOMODO EL PUNTERO A LA PILA SOLO PARA PRINTF EN LINUX
    call    printf
    add     rsp,8   ;VUELVO EL PUNTERO A LA PILA A SU VALOR ANTERIOR
    

;   Imprimo cantidad de apariciones del caracter
    mov     rdi,msjCantidad
    mov     rsi,[caracter]
    mov     rdx,[contadorCarac]
    sub     rsp,8   ;ACOMODO EL PUNTERO A LA PILA SOLO PARA PRINTF EN LINUX
    call    printf
    add     rsp,8   ;VUELVO EL PUNTERO A LA PILA A SU VALOR ANTERIOR
      

;   Imprimo Porcentaje
    imul    rax,[contadorCarac],100
    sub     rdx,rdx
    idiv    qword[longTexto]

    mov     rdi,msjPorcentaje
    mov     rsi,rax
    sub     rsp,8   ;ACOMODO EL PUNTERO A LA PILA SOLO PARA PRINTF EN LINUX
    call    printf
    add     rsp,8   ;VUELVO EL PUNTERO A LA PILA A SU VALOR ANTERIOR
    
    ret