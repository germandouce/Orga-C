

.text @ Indica que los siguientes ítems en memoria son instrucciones
@Aca comienza el programa
start: @ES UNA LABELLL
    @mov copia no mueve
    mov r0, #15 @ Seteo de parámetros. #numero es el valor entero
    mov r1, #20
    bl func @ Llamado a subrutina 
    @BL = Branch with link: bifurco y vuelvo a esta linea de ejecucion
    @y guarda en el reguistro 14 la direccion de la prox instruccion q deberia ejecutarase
    @B: Branch Bifurco pero no vuelvo

    swi 0x11 @ Fin de programa
    @SWI = Softrware Interruption. Es un llamado al SO. 
    @El codigo 0x11 es xa fin de prgrm. Puede haber otros.
    @Le cede el control al SO.
    @swi -INT-
    @El sisop tiene acceso a registros con los q va a leer o escribir informacion.
    @ejemplo
    
    @R0: Cadena de chars a imprimir por pantalla

func: @ Subrutina
    add r0, r0, r1 @ r0 = r0 + r1
    mov pc, lr @ Retornar desde subrutina
    @en la lr estaba la direc de la ult instruccion.Entonces piso el pc con el lr
    @Entonces bifurc a la instruccion dsps del llamado a la subrutina

    @que pasa si tengo una bl aca dentro, osea una rutina interna?
    @Se rompeeee
    

    .end @ Marcar fin de archivo. No s una directiva.
    @Nunca se ejecuta solo marca que no hay mas instrucciones en el archivo