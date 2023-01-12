    .equ Stdout,1
    .equ SWI_Open, 0x66
    .equ SWI_RdInt, 0x6c
    .equ SWI_PrInt, 0x6b
    .equ SWI_PrStr, 0x69
    .equ SWI_Close, 0x68
    .equ SWI_Exit, 0x11

    .equ SWI_PrChr, 0x00 ???

    @________________________
    @ABRIR ARCHIVO
    ldr r0,=filename
    mov r1, 0 input = lectura
            1 output = print en archivo
            2 append
    
    swi SWI_Open
    bcs finPrgrm

    @guardo fileHandle    
    LDR r1,=inFileHandle
    STR r0,[r1]
    
    @_______________________
    @LEER ENTERO DE ARCHIVO
    LDR r0,=inFileHandle
    LDR r0,[r0]
    
    mov r0,#entero  @QUEDA EN R0
    
    swi SWI_RdInt
    @________________________
    @IMPRIMIR ENTERO POR PANATALLA/ EN ARCHIVO
    LDR r0,=Stdout (1)
    LDR r0,=inFileHandle
    LDR r0,[r0]
    
    mov r1, #entero
    
    swi SWI_PrInt
    @________________________
    @IMPRIMIR STRING POR PANTALLA/ EN ARCHIVO
    LDR r0,=Stdout
    LDR r0,=inFileHandle
    LDR r0,[r0]
    
    ldr r1,=string
    
    swi SWI_PrStr
    @________________________
    @CERRAR ARCHIVO
    LDR r0,=inFileHandle
    LDR r0,[r0]
    
    swi SWI_Close


