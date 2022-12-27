{$M 14000,0,100000}
Program Abacus;

{Esto solo anda en VGA}

{Este programa no afecta la capa de ozono}

{Este es un claro ejemplo de programa muy mal hecho :), como no tengo
 mucho tiempo libre lo empece un sabado a la tarde y lo termine el
 domingo a las 19 horas, en ningun momento me detuve a pensar y asi
 salio... lo importante es que funciona (supongo) de todas formas
 nunca intenten tal cosa en sus casas :)}

{Cualquier persona que haga llegar este programa a algun tipo de profesor
 o programador respetable sera acusado de alta-traicion, esta mal hecho
 pero anda, en fin...}


{Ademas esta lleno de variables globales que salen de la nada y todas
 las atrocidades que se puedan imaginar, realmente deplorable}

{Todavia siguen leyendo???}


{Ha ingresado ud al club de masoquistas, bienvenido}

{No intenten esto en sus casas...}
{Alli vamos...}



Uses Crt, DOS, mcla, abacs, dvideo2, dvideo;



Const
  ext = '.ABA';   {extension de los archivos que maneja}
  Y = 2;
  D = 5;
  Col0 = 1;
  Col1 = 51;
  Col2 = 69;
  digitos_validos=['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'];
  {conjunto de digitos validos para validar (gran idea!!)}
  maximo = 32767; {Hello Maxint!!}
  minimo = - 32768; {Y este es el Minint :)}

Type
  Hex_digits = Char; {Los digitos hexa son char, he dicho}
  t_hexa = Array [1..4] Of Hex_Digits; {4 nibles, 1 por digito hexa}
  t_mem = Array [0..4095] Of t_hexa; {Memoria de la maquina}

Var
  fin_pgm: Boolean;
  tracing, microtracing: Boolean;
  ovf: Boolean;
  j, cod, auxi, num: Integer;
  h1: t_hexa;
  memory: t_mem;   {memoria de la Abacus}
  Pos: Integer;                    {Posicion del cursor en decimal}
  posh: t_hexa;                    {Posicion del cursor en hexa}
  tope: Integer;                   {Tope, donde empieza la pantalla}
  cte, entry_point, rpi, ac, rm, rdm, ri, co, op: Integer;
  c: Array [1..5] Of Integer;
  ke: Char;
  fin: Boolean;
  Scr : Array [0..3999] Of Byte;
  tecla: Boolean;
  f: File Of t_mem;
  no: Integer;
  st: String [12];
  long: LongInt;

  
  
{-------------------------------------------------------------------------}
  Procedure SaveScr;
Var i: Integer;
Begin
  For I := 0 To 3999 Do Scr [I] := Mem [$B800: I];
End;
{-------------------------------------------------------------------------}

{-------------------------------------------------------------------------}
Procedure RestoreScr;
Var i: Integer;
Begin
  For I := 0 To 3999 Do Mem [$B800: I] := Scr [I];
End;
{-------------------------------------------------------------------------}

{-------------------------------------------------------------------------}
{Imprime un numero hexadecimal por pantalla ojo es write y no writeln     }
Procedure Write_Hexa (h: t_hexa);
Var i: Integer;
Begin
  For i := 1 To 4 Do
    Write (h [i] );
End;
{-------------------------------------------------------------------------}


{-------------------------------------------------------------------------}
{Hace un NOT de un numero en hexa                                         }
Procedure Hex_Not (Var h: t_hexa);
Var i: Integer;
Begin
  For i := 1 To 4 Do
  Begin
    Case h [i] Of
      '0': h [i] := 'F';
      '1': h [i] := 'E';
      '2': h [i] := 'D';
      '3': h [i] := 'C';
      '4': h [i] := 'B';
      '5': h [i] := 'A';
      '6': h [i] := '9';
      '7': h [i] := '8';
      '8': h [i] := '7';
      '9': h [i] := '6';
      'A': h [i] := '5';
      'B': h [i] := '4';
      'C': h [i] := '3';
      'D': h [i] := '2';
      'E': h [i] := '1';
      'F': h [i] := '0';
    End;
  End;
End;
{-------------------------------------------------------------------------}

{-------------------------------------------------------------------------}
{Suma 1 a un digito hexadecimal                                           }
Procedure Sumar_1_1 (Var h: hex_digits);
Begin
  Case h Of
    '0': h := '1';
    '1': h := '2';
    '2': h := '3';
    '3': h := '4';
    '4': h := '5';
    '5': h := '6';
    '6': h := '7';
    '7': h := '8';
    '8': h := '9';
    '9': h := 'A';
    'A': h := 'B';
    'B': h := 'C';
    'C': h := 'D';
    'D': h := 'E';
    'E': h := 'F';
  End;
End;
{-------------------------------------------------------------------------}


{-------------------------------------------------------------------------}
{Suma uno a un numero en hexa                                             }
Procedure Sumar_1 (Var h: t_hexa; Var overflow: Boolean);
Var
  k: Integer;
Begin
  overflow := False;
  If h [4] = 'F' Then Begin h [4] := '0';
    If h [3] = 'F' Then Begin h [3] := '0';
      If h [2] = 'F' Then Begin h [2] := '0';
        If h [1] = 'F' Then Begin h [1] := '0';
          overflow := True; 
        End
        Else sumar_1_1 (h [1] ); 
      End
      Else sumar_1_1 (h [2] ); 
    End
    Else sumar_1_1 (h [3] ); 
  End
  Else sumar_1_1 (h [4] );
End;
{-------------------------------------------------------------------------}


{-------------------------------------------------------------------------}
{Complementa un numero hexa                                               }
Procedure Complementar (Var h: t_hexa; Var ovf: Boolean);
Begin
  hex_not (h);
  sumar_1 (h, ovf);
End;
{-------------------------------------------------------------------------}


{-------------------------------------------------------------------------}
{Dice si un numero hexa es negativo o no                                  }
Function es_negativo (h: t_hexa): Boolean;
Begin
  If (h [1] = '8') Or (h [1] = '9') Or (h [1] = 'A') Or (h [1] = 'B') Or (h [1] = 'C') Or
     (h [1] = 'D') Or (h [1] = 'E') Or (h [1] = 'E') Or (h [1] = 'F')
  Then es_negativo := True
  Else es_negativo := False;
End;
{-------------------------------------------------------------------------}


{-------------------------------------------------------------------------}
{Convierte un numero hexa positivo o negativo en su valor entero          }
Procedure Hex2Int (h: t_hexa; Var a: Integer);
Var
  j, num, cont, coef, aux, i: Integer;
  Comp: Boolean;
Begin
  Comp := False;
  If es_negativo (h) Then Begin complementar (h, ovf); Comp := True; End;
  cont := 0;
  num := 0;
  For i := 4 Downto 1 Do
  Begin
    Case h [i] Of
      '0': aux := 0;
      '1': aux := 1;
      '2': aux := 2;
      '3': aux := 3;
      '4': aux := 4;
      '5': aux := 5;
      '6': aux := 6;
      '7': aux := 7;
      '8': aux := 8;
      '9': aux := 9;
      'A': aux := 10;
      'B': aux := 11;
      'C': aux := 12;
      'D': aux := 13;
      'E': aux := 14;
      'F': aux := 15;
    End;
    coef := 1;
    If cont > 0 Then Begin
      For j := 1 To cont Do
        coef := coef * 16;
    End;
    coef := coef * aux;
    Inc (cont);
    num := num + coef;
  End;
  If Comp Then a := - num Else a := num;
End;
{-------------------------------------------------------------------------}


{-------------------------------------------------------------------------}
{Convierte un integer en un numero hexa                                   }
Procedure Int2Hex (a: LongInt; Var h: t_hexa);
Var
  coc, digit, i, resto: Integer;
  aux1: t_hexa;
  hchar: hex_digits;
  comple: Boolean;
Begin
  digit := 4;
  comple := False;
  If a < 0 Then Begin a := - a; comple := True; End;
  For i := 1 To 4 Do
    h [i] := '0';           {Inicializa el hexa en 0}
  While a > 0 Do
  Begin
    coc := a Div 16;
    resto := a Mod 16;
    Case resto Of
      10 : hchar := 'A';
      11 : hchar := 'B';
      12 : hchar := 'C';
      13 : hchar := 'D';
      14 : hchar := 'E';
      15 : hchar := 'F';
      1  : hchar := '1';
      2  : hchar := '2';
      3  : hchar := '3';
      4  : hchar := '4';
      5  : hchar := '5';
      6  : hchar := '6';
      7  : hchar := '7';
      8  : hchar := '8';
      9  : hchar := '9';
      0  : hchar := '0';
    End;
    a := coc;
    If digit > 0 Then h [digit] := hchar;
    Dec (digit);
  End;
  If comple Then complementar (h, ovf);
End;
{-------------------------------------------------------------------------}


{-------------------------------------------------------------------------}
{Inicializa la memoria                                                    }
Procedure Init_mem (Var tm: t_mem);
Var aux, i: Integer;
  haux: t_hexa;
Begin
  Randomize;
  For i := 0 To ( (SizeOf (tm) - 4) Div 4)  Do
  Begin
    aux := Random (MaxInt);
    Int2hex (aux, haux);
    tm [i] := haux;
  End;
  For i := 1 To 5 Do
  Begin
    aux := Random (1000);
    c [i] := aux;
  End;
  ac := Random (23000);
  rdm := Random (3000);
  rm := Random (23000);
  rpi := 0;
  ri := Random (23000);
  entry_point := 0;
  GotoXY (24, 22);
  Int2hex (entry_point, haux);
  write_hexa (haux);
End;
{-------------------------------------------------------------------------}






{-------------------------------------------------------------------------}
{Procedimiento que muestra en pantalla las posiciones de memoria          }
Procedure Actualice (t: Integer);   {Entra el tope                          }
Var
  aux, i: Integer;
  haux: t_hexa;
Begin
  TextColor (9);
  For i := 1 To 20 Do
  Begin
    GotoXY (col1, i + Y);
    Int2hex (tope+ i - 1, haux);
    write_hexa (haux);
    Write (':');
    write_hexa (memory [tope+ i - 1] );
  End;
  For i := 1 To 20 Do
  Begin
    GotoXY (col2, i + Y);
    Int2hex (20 + tope+ i - 1, haux);
    write_hexa (haux);
    Write (':');
    write_hexa (memory [tope+ i + 20 - 1] );
  End;
End;
{-------------------------------------------------------------------------}

{-------------------------------------------------------------------------}
{Aisla el codigo de operacion y lo muestra en su lugar                    }
Procedure _Co;
Var
  haux1, haux2: t_hexa;
  i: Integer;
Begin
  For i := 1 To 3 Do
    haux1 [i] := '0';
  Int2hex (ri, haux2);
  haux1 [4] := haux2 [1];
  GotoXY (24, 20);
  hex2Int (haux1, co);
  TextColor (11);
  TextBackground (1);
  write_hexa (haux1);
End;
{-------------------------------------------------------------------------}

{-------------------------------------------------------------------------}
{Aisla el operando y lo muestra en su lugar                               }
Procedure _Op;
Var
  haux1, haux2: t_hexa;
  i: Integer;
Begin
  Int2hex (ri, haux2);
  If (haux2 [2] = '9') Or (haux2 [2] = '8') Or (haux2 [2] = 'A') Or (haux2 [2] = 'B')
     Or (haux2 [2] = 'C') Or (haux2 [2] = 'D') Or (haux2 [2] = 'E') Or (haux2 [2] = 'F')
  Then haux1 [1] := 'F' Else haux1 [1] := '0';
  
  For i := 2 To 4 Do
    haux1 [i] := haux2 [i];
  
  
  hex2Int (haux1, op);
  TextColor (11);
  TextBackground (1);
  GotoXY (24, 21);
  write_hexa (haux1);
End;
{-------------------------------------------------------------------------}

{-------------------------------------------------------------------------}
{Muestra el contenido de cada componente y de las celdas especiales       }
Procedure Ver_Maquina;
Var
  haux: t_hexa;
  i: Integer;
Begin
  TextColor (11);
  TextBackground (1);
  
  GotoXY (7, 4);
  Int2hex (ac, haux);
  write_hexa (haux);
  
  GotoXY (27, 7);
  Int2hex (rm, haux);
  write_hexa (haux);
  
  GotoXY (17, 7);
  Int2hex (ri, haux);
  write_hexa (haux);
  
  GotoXY (27, 4);
  Int2hex (rdm, haux);
  write_hexa (haux);
  
  GotoXY (17, 4);
  Int2hex (rpi, haux);
  write_hexa (haux);
  
  _op;
  
  GotoXY (24, 21);
  Int2hex (op, haux);
  write_hexa (haux);

  _co;

  GotoXY (24, 20);
  Int2hex (CO, haux);
  write_hexa (haux);
  
  TextColor (10);
  For i := 1 To 5 Do
  Begin
    GotoXY (27, i + 13);
    Int2hex (c [i], haux);
    TextColor (11);
    TextBackground (1);
    write_hexa (haux);
    GotoXY (35, i + 13);
    TextColor (11);
    TextBackground (0);
    Write (memory [c [i] ] );
  End;
End;
{-------------------------------------------------------------------------}


{-------------------------------------------------------------------------}
{Edita las celdas de memoria que se muestran en pantalla                  }
{Datos de entrada: memoria, tope, posicion. Salen:posicion y la new mem   }
Procedure Edit_mem (Var mem: t_mem; tope: Integer; Var Pos: Integer);
Var
  ke: Char;
  i, posy, posx: Integer;
  salida: Boolean;
Begin
  salida := False;
  While Not (salida) Do
  Begin
    If Pos < 21 Then Begin posy := Pos; posx := col1 + 5; End
    Else Begin posx := col2 + 5; posy := Pos - 20; End;
    GotoXY (posx, posy + Y);
    TextColor (2); TextBackground (9);
    write_hexa (memory [tope+ Pos - 1] );
    ke := ReadKey;
    GotoXY (posx, posy + Y);
    TextColor (9); TextBackground (0);
    write_hexa (memory [tope+ Pos - 1] );
    If ke = #0 Then ke := ReadKey;
    If ke = #72 Then Dec (Pos);
    If ke = #80 Then Inc (Pos);
    If ke = #77 Then If Pos < 21 Then Pos := Pos + 20;
    If ke = #75 Then If Pos > 21 Then Pos := Pos - 20;
    If ke = #27 Then salida := True;
    If (ke In digitos_validos) Or (UpCase (ke) In digitos_validos) Then
    Begin
      Cursor (1);
      GotoXY (posx, posy + Y);
      ke := UpCase (ke);
      memory [tope+ Pos - 1] [1] := ke;
      Write (ke);
      GotoXY (posx + 1, posy + Y);
      For i := 2 To 4 Do
      Begin
        Repeat
          ke := ReadKey;
          ke := UpCase (ke);
        Until ke In digitos_validos;
        memory [tope+ Pos - 1] [i] := ke;
        Write (ke);
        GotoXY (posx + i, posy + Y);
      End;
      Cursor (0);
      Inc (Pos);
      ver_maquina;
    End;
    If Pos > 40 Then Pos := 1;
    If Pos < 1 Then Pos := 40;
  End;
End;
{-------------------------------------------------------------------------}

{-------------------------------------------------------------------------}
{Setea el Entry Point, punto de carga                                     }
Procedure set_carga (Var ep: Integer);
Var
  haux: t_hexa;
  i: Integer;
Begin
  GotoXY (24, 22);
  Cursor (1);
  For i := 1 To 4 Do
  Begin
    Repeat
      ke := ReadKey;
      ke := UpCase (ke);
    Until ke In digitos_validos;
    TextColor (2);
    TextBackground (1);
    Write (ke);
    haux [i] := ke;
  End;
  Cursor (0);
  hex2Int (haux, ep);
  rpi := ep;
  ver_maquina;
  For i := 14 To 18 Do
  Begin
    GotoXY (19, i);
    Write (' ');
  End;
End;
{-------------------------------------------------------------------------}

{-------------------------------------------------------------------------}
{Setea la direccion de la celda especial n                                }
Procedure Celda (n: Integer);
Var
  aux, i: Integer;
  haux: t_hexa;
Begin
  Cursor (1);
  GotoXY (27, 13 + n);
  TextColor (11);
  TextBackground (1);
  For i := 1 To 4 Do
  Begin
    Repeat
      ke := ReadKey;
      ke := UpCase (ke);
    Until ke In digitos_validos;
    Write (ke);
    haux [i] := ke;
  End;
  hex2Int (haux, aux);
  c [n] := aux;
  GotoXY (35, 13 + n);
  TextColor (11);
  TextBackground (0);
  write_hexa (memory [aux] );
  Cursor (0);
End;
{-------------------------------------------------------------------------}

{-------------------------------------------------------------------------}
{Este permite elegir un .ABA a cargar (Choose a file style                }
Procedure Choose_a_file;
Var
  dirinfo: SearchRec;
  vec: Array [1..20] Of SearchRec;
  Pos, cant, i: Integer;
  salida: Boolean;
Begin
  savescr;
  TextColor (1);
  TextBackground (0);
  Window (49, 1, 80, 23);
  ClrScr;
  Window (1, 1, 80, 25);
  box (48, 1, 80, 23, 's');
  TextColor (9);
  i := 1;
  FindFirst ('*.aba', AnyFile, dirinfo);
  vec [i] := dirinfo;
  While DosError = 0 Do
  Begin
    FindNext (dirinfo);
    Inc (i);
    vec [i] := dirinfo;
  End;
  cant := i - 1;
  For i := 1 To cant Do
  Begin
    GotoXY (50, 1 + i);
    Write (vec [i].Name);
  End;
  salida := False; Pos := 1;
  If cant > 0 Then Begin
    While Not (salida) Do
    Begin
      GotoXY (50, 1 + Pos);
      TextColor (11);
      TextBackground (1);
      Write (vec [Pos].Name);
      ke := ReadKey;
      If ke = #0 Then ke := ReadKey;
      GotoXY (50, 1 + Pos);
      TextColor (9);
      TextBackground (0);
      Write (vec [Pos].Name);
      If ke = #72 Then Dec (Pos);
      If ke = #80 Then Inc (Pos);
      If ke = #27 Then salida := True;
      If ke = #13 Then Begin
        Assign (f, vec [Pos].Name);
        Reset (f);
        Read (f, memory);
        Close (f);
        salida := True;
      End;
      If Pos > cant Then Pos := 1;
      If Pos < 1 Then Pos := cant;
      
    End;
  End;
  restorescr;
  actualice (tope);
  ver_maquina;
End;
{-------------------------------------------------------------------------}

{-------------------------------------------------------------------------}
{dibuja el caminito del RPI al RDM                                        }
Procedure RPI_RDM (co: Integer);
Var j, K: Integer;
Begin
  k := TextAttr;
  TextColor (co);
  TextBackground (0);
  For j := 21 To 26 Do
  Begin
    GotoXY (j, 4);
    Write ('Ä');
  End;
  TextAttr := k;
End;
{-------------------------------------------------------------------------}

{-------------------------------------------------------------------------}
{dibuja el caminito del RDM al RM                                         }
Procedure RDM_RM (co: Integer);
Var j, k: Integer;
Begin
  k := TextAttr;
  TextColor (co);
  TextBackground (0);
  For j := 31 To 39 Do
  Begin
    GotoXY (j, 4);
    Write ('Ä');
    GotoXY (j, 7);
    Write ('Ä');
  End;
  GotoXY (40, 4);
  Write ('¿');
  GotoXY (40, 5);
  Write ('Á');
  GotoXY (40, 6);
  Write ('Â');
  GotoXY (40, 7);
  Write ('Ù');
  TextAttr := k;
End;
{-------------------------------------------------------------------------}

{-------------------------------------------------------------------------}
{ Dibuja el caminito del RM al RI                                         }
Procedure RM_RI (co: Integer);
Var j, k: Integer;
Begin
  k := TextAttr;
  TextColor (co);
  TextBackground (0);
  For j := 21 To 26 Do
  Begin
    GotoXY (j, 7);
    Write ('Ä');
  End;
  TextAttr := k;
End;
{-------------------------------------------------------------------------}








{-------------------------------------------------------------------------}
{Este procedure realiza una fase de busqueda!!!                           }
Procedure busqueda;
Var
  haux: t_hexa;
Begin
  GotoXY (24, 12);
  TextColor (11);
  TextBackground (0);
  Write (' Fase de Busqueda  ');
  If microtracing Then ke := ReadKey;
  If ke = #0 Then ke := ReadKey;
  {rpi_rdm(27);}
  GotoXY (24, 12);
  Write (' (RPI)  ->  (RDM)  ');
  rdm := rpi;
  ver_maquina;
  If microtracing Then ke := ReadKey;
  If ke = #0 Then ke := ReadKey;
  {rpi_rdm(1);}
  {rdm_rm(27);}
  GotoXY (24, 12);
  Write ('((RMD)) ->  (RM)   ');
  haux := memory [rdm];
  hex2Int (haux, rm);
  ver_maquina;
  If microtracing Then ke := ReadKey;
  If ke = #0 Then ke := ReadKey;
  {rdm_rm(1);}
  {rM_ri(27);}
  GotoXY (24, 12);
  Write (' (RM)   ->  (RI)   ');
  ri := rm;
  ver_maquina;
  If microtracing Then ke := ReadKey;
  If ke = #0 Then ke := ReadKey;
  {rm_ri(1);}
  GotoXY (24, 12);
  Write (' (RPI)+1->  (RPI)  ');
  rpi := rpi + 1;
  ver_maquina;
  If microtracing Then ke := ReadKey;
  If ke = #0 Then ke := ReadKey;
  GotoXY (24, 12);
  Write (' Fin Busqueda      ');
  If microtracing Then ke := ReadKey;
  If ke = #0 Then ke := ReadKey;
  GotoXY (24, 12);
  Write ('                   ');
End;
{-------------------------------------------------------------------------}

{-------------------------------------------------------------------------}
{procedure ejecucion!!                                                    }
Procedure ejecucion;
Var i, aux: Integer;
  haux, haux2: t_hexa;
Begin
  _co;
  _op;
  Case co Of
    {CARGA INMEDIATA}
    00: 
        Begin
          TextColor (11);
          TextBackground (0);
          GotoXY (24, 12);
          Write (' Ejecucion ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' (OP)   ->  (AC) ');
          Int2hex (op, haux);
          If op > 0 Then haux [1] := '0';
          If op < 0 Then haux [1] := 'F';
          hex2Int (haux, ac);
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' Fin ejecucion   ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('                 ');
        End;
    {CARGA}
    01: 
        Begin
          TextColor (11);
          TextBackground (0);
          GotoXY (24, 12);
          Write (' Ejecucion ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' (OP)   -> (RDM) ');
          If op >= 0 Then rdm := op
          Else
          Begin
            Int2hex (op, haux);
            haux [1] := '0';
            hex2Int (haux, rdm);
          End;
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('((RDM)) -> (RM)  ');
          haux := memory [rdm];
          hex2Int (haux, rm);
          ver_maquina;
          actualice (tope);
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' (RM)   -> (AC)  ');
          ac := rm;
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' Fin ejecucion   ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('                 ');
        End;
    {ALMACENAR}
    02: 
        Begin
          TextColor (11);
          TextBackground (0);
          GotoXY (24, 12);
          Write (' Ejecucion       ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' (OP)   -> (RDM) ');
          If op >= 0 Then rdm := op
          Else
          Begin
            Int2hex (op, haux);
            haux [1] := '0';
            hex2Int (haux, rdm);
          End;
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' (AC)   -> (RM)  ');
          rm := ac;
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' (RM)   -> ((RMD)');
          Int2hex (rm, haux);
          memory [rdm] := haux;
          ver_maquina;
          actualice (tope);
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' Fin ejecucion   ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('                 ');
        End;
    {SUMAR}
    03: 
        Begin
          TextColor (11);
          TextBackground (0);
          GotoXY (24, 12);
          Write (' Ejecucion       ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' (OP)   -> (RDM) ');
          rdm := op;
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('((RDM)) -> (RM)  ');
          If rdm < 0 Then
          Begin
            Int2hex (rdm, haux);
            haux [1] := '0';
            hex2Int (haux, rdm);
          End;
          haux := memory [rdm];
          hex2Int (haux, rm);
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('AC+RM  -> (AC)   ');
          long := LongInt (rm) + LongInt (ac);
          If (long > maximo) Or (long < minimo) Then Begin
            GotoXY (19, 14);
            TextColor (27);
            Write ('Û');
            TextColor (11);
          End;
          If ( (long < maximo) And (long > minimo) ) Then ac := ac + rm
          Else Begin
            Int2hex (long, haux);
            hex2Int (haux, ac);
          End;

          
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' Fin ejecucion   ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('                 ');
          {gotoxy(19,14);
          textcolor(27);
          write(' ');
          textcolor(11);}
        End;
    {RESTAR}
    04: 
        Begin
          TextColor (11);
          TextBackground (0);
          GotoXY (24, 12);
          Write (' Ejecucion       ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' (OP)   -> (RDM) ');
          rdm := op;
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('((RDM)) -> (RM)  ');
          If rdm < 0 Then
          Begin
            Int2hex (rdm, haux);
            haux [1] := '0';
            hex2Int (haux, rdm);
          End;
          haux := memory [rdm];
          hex2Int (haux, rm);
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('AC-RM  -> (AC)   ');
          long := LongInt (rm) - LongInt (ac);
          If (long > maximo) Or (long < minimo) Then Begin
            GotoXY (19, 14);
            TextColor (27);
            Write ('Û');
            TextColor (11);
          End;
          If ( (long < maximo) And (long > minimo) ) Then ac := ac - rm
          Else Begin
            Int2hex (long, haux);
            hex2Int (haux, ac);
          End;
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' Fin ejecucion   ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('                 ');
          {gotoxy(19,14);
          textcolor(27);
          write(' ');
          textcolor(11);}
        End;
    {NOT(AC)}
    05: 
        Begin
          TextColor (11);
          TextBackground (0);
          GotoXY (24, 12);
          Write (' Ejecucion       ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('NOT(AC)->(AC)    ');
          ac := Not (ac);
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' Fin ejecucion   ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('                 ');
        End;
    {INC(AC)}
    06: 
        Begin
          TextColor (11);
          TextBackground (0);
          GotoXY (24, 12);
          Write (' Ejecucion       ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' (AC)+1->(AC)    ');
          If ac < maximo Then Inc (ac) Else
          Begin
            long := LongInt (ac) + 1;
            Int2hex (long, haux);
            hex2Int (haux, ac);
            GotoXY (19, 14);
            TextColor (27);
            Write ('Û');
            TextColor (11);
          End;
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' Fin ejecucion   ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('                 ');
        End;
    {AC=0}
    07: 
        Begin
          TextColor (11);
          TextBackground (0);
          GotoXY (24, 12);
          Write (' Ejecucion       ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' 0     -> (AC)   ');
          ac := 0;
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' Fin ejecucion   ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('                 ');
        End;
    {BIF AC>0}
    08: 
        Begin
          TextColor (11);
          TextBackground (0);
          GotoXY (24, 12);
          Write (' Ejecucion       ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          If ac < 0 Then Begin
            Write (' (OP)  -> (RPI)  ');
            rpi := op; 
          End
          Else Write (' No bifurca      ');
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' Fin ejecucion   ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('                 ');
        End;
    {BIF AC<0}
    09: 
        Begin
          TextColor (11);
          TextBackground (0);
          GotoXY (24, 12);
          Write (' Ejecucion       ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          If ac > 0 Then Begin
            Write (' (OP)  -> (RPI)  ');
            rpi := op; 
          End
          Else Write (' No bifurca      ');
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' Fin ejecucion   ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('                 ');
        End;
    {BIF AC=0}
    10: 
        Begin
          TextColor (11);
          TextBackground (0);
          GotoXY (24, 12);
          Write (' Ejecucion       ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          If ac = 0 Then Begin
            Write (' (OP)  -> (RPI)  ');
            rpi := op; 
          End
          Else Write (' No bifurca      ');
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' Fin ejecucion   ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('                 ');
        End;
    {BIF INCONDICIONAL}
    11:
        Begin
          TextColor (11);
          TextBackground (0);
          GotoXY (24, 12);
          Write (' Ejecucion       ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' (OP)  -> (RPI)  ');
          rpi := op;
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' Fin ejecucion   ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('                 ');
        End;
    {FIN DE PGM}
    15: 
        Begin
          TextColor (11);
          TextBackground (0);
          GotoXY (24, 12);
          Write (' Ejecucion       ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' Fin de PGM     ');
          GotoXY (19, 15);
          TextColor (27);
          Write ('Û');
          TextColor (11);
          ver_maquina;
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write (' Fin ejecucion   ');
          If microtracing Then ke := ReadKey;
          If ke = #0 Then ke := ReadKey;
          GotoXY (24, 12);
          Write ('                 ');
          fin_pgm := True;
        End;
  End; {Case}
  If (co > 11) And (co < 15) Then Begin
    GotoXY (19, 18);
    TextColor (27);
    Write ('Û');
    TextColor (11);
    ver_maquina;
  End;
End;
{-------------------------------------------------------------------------}








{-------------------------------------------------------------------------}
{procedure Step hace una busqueda y una ejecucion con readkeys    }
Procedure Step;
Begin
  Busqueda;
  Ejecucion;
End;
{-------------------------------------------------------------------------}












Begin {PPAL}
      {Este begin esta auspiciado por Casa 14}
  scrolldown (25);
  screenu;
  fin_pgm := False;
  no := 1;
  Cursor (0);
  tope := 0;
  Pos := 1;
  init_mem (memory);
  ver_maquina;
  actualice (tope);
  fin := False;
  {edit_mem(mem,tope,pos);}
  While Not (FIN) Do
  Begin
    Repeat
      {  scroller(scrl,1,24,tecla);}
    Until (tecla) Or (KeyPressed);
    ke := ReadKey;
    
    If ke = #0 Then ke := ReadKey;
    Case ke Of
      #81: Begin
        If tope < 4055 Then
        Begin
          tope := tope+40;
          ver_maquina;
          actualice (tope);
        End;
      End;
      #73: 
           Begin
             If tope > 0 Then
             Begin
               tope := tope-40;
               ver_maquina;
               actualice (tope);
             End;
           End;
      #27: fin := True;
      #63: edit_mem (memory, tope, Pos);
      #66: set_carga (entry_point);
      '1': 
           Begin Val (ke, auxi, cod); celda (auxi); End;
      '2': Begin Val (ke, auxi, cod); celda (auxi); End;
      '3': Begin Val (ke, auxi, cod); celda (auxi); End;
      '4': Begin Val (ke, auxi, cod); celda (auxi); End;
      '5': Begin Val (ke, auxi, cod); celda (auxi); End;
      
      #60: Begin microtracing := True; step; End;
      #61: Begin microtracing := False; tracing := True; step; End;
      #62: Begin
        gotoxy(19,17);
        textcolor(27);
        write('Û');
        textcolor(11);
        fin_pgm := False;
        microtracing := False;
        tracing := False;
        Repeat
          step
        Until (fin_pgm) Or (KeyPressed);
        gotoxy(19,17);
        write(' ');
      End;
      #59: 
           Begin
             Savescr;
             TextColor (1);
             Window (1, 1, 47, 21 + Y);
             ClrScr;
             GotoXY (1, 2 + Y);
             WriteLn (' Pantalla de Ayuda            | Codigos ');
             WriteLn ('                              | ');
             WriteLn (' Page Up  = Recorrer Memoria  | 00=Carga Inm.');
             WriteLn (' Page Down= Recorrer Memoria  | 01=Carga');
             WriteLn (' Home     = Posicion 0        | 02=Almacenar');
             WriteLn (' End      = Posicion 999(3E7) | 03=Sumar');
             WriteLn (' F1       = Ayuda             | 04=Restar');
             WriteLn (' F2       = Micro Trace       | 05=NOT(AC)');
             WriteLn (' F3       = Trace             | 06=INC(AC)');
             WriteLn (' F4       = RUN               | 07=(AC=0)');
             WriteLn (' F5       = Editar memoria    | 08=BIF AC<0');
             WriteLn (' F6       = Salvar memoria    | 09=BIF AC>0');
             WriteLn (' F7       = Cargar memoria    | 0A=BIF AC=0');
             WriteLn (' F8       = Cambiar pto carga | 0B=BIF INC');
             WriteLn (' F9       = Cambiar RPI       | 0F=FIN PGM');
             WriteLn (' F10      = Cambiar AC        |');
             WriteLn (' 1..5     = Cambiar C[1..5]   |');
             WriteLn (' ESC      = Salir del programa|');
             TextColor (11);
             box (1, 1, 47, 21 + Y, 's');
             ke := ReadKey;
             If ke = #0 Then ke := ReadKey;
             Window (1, 1, 80, 25);
             restorescr;
           End;
      #64: 
           Begin
             GotoXY (1, 24);
             TextColor (11);
             TextBackground (0);
             Write ('Nombre del archivo a grabar (8 caracteres) :');
             Cursor (1);
             st := '';
             For j := 1 To 8 Do
             Begin
               Repeat
                 ke := ReadKey;
                 ke := UpCase (ke);
               Until ( (ke <= 'Z') And (ke >= 'A') );
               Write (ke);
               st := st + ke;
             End;
             st := st + ext;
             Assign (f, st);
             Rewrite (f);
             Write (f, memory);
             Close (f);
             Cursor (0);
             GotoXY (1, 24);
             Write (' ': 79);
           End;
      #65: Choose_a_file;
      #71: 
           Begin
             tope := 0;
             ver_maquina;
             actualice (tope);
           End;
      #79: 
           Begin
             tope := 4055;
             ver_maquina;
             actualice (tope);
           End;
      
    End; {CASE}
  End;
  ClrScr;
  scrollup (25);
End.

(*


Estadisticas Pot-Mortem:

Numero de Lineas         : 1351 (mucho)
E-rrores de programacion : n      (n>347982749374)
Ho-rrores de programacion: Aleph8 (bastantes...)
Otros errores            : ?
Tiempo de programacion   : 7 horas  (Carisimo!)
Coca-Cola consumida      : 3 litros


1351 lineas en 7 horas.
193 lineas por hora.
3 lineas por minuto. Debe ser record.


*)

El programador no se hace responsable de los da¤os que este programa pudiera
causar en personas, objetos o cosos, en especial el programador no se hace
responsable de las notas que se originen por imitar el estilo de programacion
de este programa (HR saludos!) 


Ningun animal fue da¤ado para la realizacion de este programa...



