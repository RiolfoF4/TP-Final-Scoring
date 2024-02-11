program PruebaListados;
{$CODEPAGE UTF8}

uses
  sysutils, crt, UnitLista, UnitArchivo, UnitTypes;

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
  PosSep: TVectorInt;
  Encab: TVectorEncab;

  LenEncab: TVectorInt;

  LenAux: TVectorInt;

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

begin
  // Inicializar
  CrearAbrirArchivoCon(ArchCon);
  CrearLista(ListaCon);
  ClrScr;

  Encab[1] := 'APELLIDO Y NOMBRES';
  Encab[2] := 'DNI';
  Encab[3] := 'SCORING';
  Encab[4] := 'HABILITADO';

  LenAux[2] := 8;   // DNI 12.345.678
  LenAux[3] := 2;   // Scoring <= 20
  LenAux[4] := 2;   // Habilitado Si / No

  while not (EOF(ArchCon)) do
  begin
    Read(ArchCon, DatosCon);
    LenAux[1] := Length(AnsiString(DatosCon.ApYNom));
    if Length(Encab[1]) < LenAux[1] then
      LenEncab[1] := LenAux[1];
      {if not DatosCon.Habilitado then}
        Agregar(ListaCon, DatosCon);  // Pasarla como parámetro, ya ordenada por ApYNom
  end;

  for i := 1 to EncabTotales do
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
  end;

  MostrarEncabezado(Encab);

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
  end;
  Write('FIN':PosSep[4]);
end.
