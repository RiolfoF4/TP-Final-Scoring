program PruebaListados;
{$CODEPAGE UTF8}

uses
  sysutils, crt, UnitLista, UnitArchivo, UnitTypes, UnitPila;

{
  '┌', '┐', '└', '┘',
  '─', '│'
  '├', '┤', '┬', '┴', '┼'
}
{
  '|', '+', '-', '_'
}

const
  EncabTotales = 4;

type
  TVectorInt = array[1..EncabTotales] of Integer;
  TVectorEncab = array[1..EncabTotales] of String;

var
  ArchCon: TArchCon;
  ListaCon: TListaCon;
  DatosCon: TDatoConductores;
  {  PosSep: TVectorInt;}
  Encab: TVectorEncab;
{  LenEncab: TVectorInt;
  LenAux: TVectorInt;}

  i: Word;

procedure SeparadorEncabezado(Encabezados: TVectorEncab);
var
  i, j: Word;
begin
  for i := 1 to EncabTotales do
  begin
    Write('+');
    for j := 1 to Length(Encabezados[i]) do
      Write('=');
  end;
  WriteLn('+');
end;

procedure MostrarEncabezado(Encabezados: TVectorEncab);
var
  i: Word;
begin
  SeparadorEncabezado(Encabezados);

  for i := 1 to EncabTotales do
  begin
    Write('|');
    Write(Encabezados[i]);
  end;
  WriteLn('|');

  SeparadorEncabezado(Encabezados);
end;

procedure SeparadorLineas(PosSep: TVectorInt);
var
  i: Word;
begin
  Write('+');

  while WhereX < PosSep[EncabTotales] do
  begin
    Write('-');
    for i := 1 to EncabTotales do
      if WhereX = PosSep[i] then
        Write('+');
  end;

  WriteLn;
end;

procedure InicializarListadoCon(var Encabezados: TVectorEncab; var ListaCon: TListaCon;
  var LenEncab: TVectorInt; var PosSep: TVectorInt);
var
  i: Word;
  DatosCon: TDatoConductores;
  LenAux: TVectorInt;
begin
  LenAux[2] := 8;   // DNI 12.345.678
  LenAux[3] := 2;   // Scoring <= 20
  LenAux[4] := 2;   // Habilitado Si / No

  for i := 1 to TamanioLista(ListaCon) do
  begin
    Recuperar(ListaCon, i, DatosCon);
    LenAux[1] := Length(AnsiString(DatosCon.ApYNom));
    if Length(Encabezados[1]) < LenAux[1] then
      LenEncab[1] := LenAux[1];
  end;
  for i := 1 to EncabTotales do
  begin
    Encabezados[i] := ' ' + Encabezados[i] + ' ';
    while Length(Encabezados[i]) < LenAux[i] + 2 do
      Encabezados[i] := ' ' + Encabezados[i] + ' ';
    LenEncab[i] := Length(Encabezados[i]);

    {for i := 1 to EncabTotales do}
    if i = 1 then
      PosSep[i] := LenEncab[i] + 2
    else
      PosSep[i] := PosSep[i-1] + LenEncab[i] + 1;
  end;
end;

procedure ListadoConductores(Encabezados: TVectorEncab; var ListaCon: TListaCon);
const
  LimiteInferior = 20;
var
  PosAnterior: TPila;
  CantCon: String[7];
  i, Anterior: Byte;
  Tecl: String[2];
  DatosCon: TDatoConductores;
  LenEncab, PosSep: TVectorInt;
begin
  // Inicialización
  InicializarListadoCon(Encabezados, ListaCon, LenEncab, PosSep);
  CrearPila(PosAnterior);
  i := 1;
  Anterior := 1;
  Tecl := '';
  MostrarEncabezado(Encabezados);
  
  while (LowerCase(Tecl) <> 'q') do
  begin
    // Si no se llegó al final de la lista, muestra secuencialmente las infracciones
    if i <= TamanioLista(ListaCon) then
    begin
      Recuperar(ListaCon, i, DatosCon);
      with DatosCon do
      begin
        Write('|', ApYNom:((LenEncab[1] + Length(AnsiString(ApyNom))) div 2));
        GotoXY(PosSep[1], WhereY);
        Write('|', DNI:((LenEncab[2] + Length(UIntToStr(DNI))) div 2));
        GotoXY(PosSep[2], WhereY);
        Write('|', Scoring:((LenEncab[3] + Length(IntToStr(Scoring))) div 2));
        GotoXY(PosSep[3], WhereY);
        Write('|');
        if Habilitado then
          Write('Si':((LenEncab[4] + 2)) div 2)
        else
          Write('No':((LenEncab[4] + 2)) div 2);
        GotoXY(PosSep[4], WhereY);
        WriteLn('|');
        SeparadorLineas(PosSep);
      end;
      Inc(i);
    end;

    // Recibe una entrada del usuario si el texto supera un límite inferior
    // o supera el final de la lista
    if (WhereY > LimiteInferior) or (i > TamanioLista(ListaCon)) then
    begin
      CantCon := IntToStr(i - 1) + '/' + IntToStr(TamanioLista(ListaCon));
      WriteLn;
      {WriteLn('[S] iguiente.', CantCon:(WindMaxX - WindMinX - 13));}
      WriteLn('[S] iguiente.', CantCon:46);
      WriteLn('[A] nterior.');
      WriteLn('[Q] Salir.');
      WriteLn;
      Write(UTF8Decode('Opción: '));
      ReadLn(Tecl);
      // s: Siguiente
      // a: Anterior
      case LowerCase(Tecl) of
        's':
          // Si NO se llegó al final de la lista, apila el índice de la infracción que se muestra actualmente
          // Si se llegó el final de la lista, muestra lo mismo
          if not (i > TamanioLista(ListaCon)) then
            Apilar(PosAnterior, Anterior)
          else
            i := Anterior;
        'a': 
          // Si la pila contiene algún índice, lo desapila y lo guarda en el índice de la lista 'i'
          // Si la pila NO contiene ningún índice, se encuentra en la primera "página", y establece el índice de la
          // lista nuevamente en la posición 0
          if not (PilaVacia(PosAnterior)) then
            Desapilar(PosAnterior, i)
          else
            i := 1;
      else
        // Si la tecla no es 's' ni 'a', muestra lo mismo
        i := Anterior;
      end;
      Anterior := i;
      ClrScr;
      MostrarEncabezado(Encabezados);
    end;
  end;
end;

begin
  // Inicializar
  CrearAbrirArchivoCon(ArchCon);
  CrearLista(ListaCon);
  ClrScr;

  Encab[1] := 'APELLIDO Y NOMBRES';
  Encab[2] := 'DNI';
  Encab[3] := 'SCORING';
  Encab[4] := 'HABILITADO';

{  LenAux[2] := 8;   // DNI 12.345.678
  LenAux[3] := 2;   // Scoring <= 20
  LenAux[4] := 2;   // Habilitado Si / No}

  while not (EOF(ArchCon)) do
  begin
    Read(ArchCon, DatosCon);
    {if not DatosCon.Habilitado then}
    Agregar(ListaCon, DatosCon);
  end;

{  for i := 1 to EncabTotales do
  begin
    Encab[i] := ' ' + Encab[i] + ' ';
    while Length(Encab[i]) < LenAux[i] + 2 do
      Encab[i] := ' ' + Encab[i] + ' ';
    LenEncab[i] := Length(Encab[i]);

    {for i := 1 to EncabTotales do}
    if i = 1 then
      PosSep[i] := LenEncab[i] + 2
    else
      PosSep[i] := PosSep[i-1] + LenEncab[i] + 1;
  end;}

  ListadoConductores(Encab, ListaCon);

{  MostrarEncabezado(Encab);

  for i := 1 to TamanioLista(ListaCon) do
  begin
    Recuperar(ListaCon, i, DatosCon);
    with DatosCon do
    begin
      Write('|', ApYNom:((LenEncab[1] + Length(AnsiString(ApyNom))) div 2));
      GotoXY(PosSep[1], WhereY);
      Write('|', DNI:((LenEncab[2] + Length(UIntToStr(DNI))) div 2));
      GotoXY(PosSep[2], WhereY);
      Write('|', Scoring:((LenEncab[3] + Length(IntToStr(Scoring))) div 2));
      GotoXY(PosSep[3], WhereY);
      Write('|');
      if Habilitado then
        Write('Si':((LenEncab[4] + 2)) div 2)
      else
        Write('No':((LenEncab[4] + 2)) div 2);
      GotoXY(PosSep[4], WhereY);
      WriteLn('|');
    end;

    SeparadorLineas(PosSep);
    if WhereY > 20 then
    begin
      WriteLn;
      WriteLn('PULSE UNA TECLA');
      ReadLn;
      ClrScr;
      MostrarEncabezado(Encab);
    end;
  end;}

  {Write('FIN':PosSep[4]);}
end.
