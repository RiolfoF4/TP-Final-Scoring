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
  EncabTotales = 3;
  Encab: array[1..EncabTotales] of String = 
    ('     APELLIDO Y NOMBRES     ', '     DNI     ', ' SCORING ');
  Sep = '│';
type
  TVectorInt = array[1..EncabTotales] of Integer;

var
  ArchCon: TArchCon;
  ListaCon: TListaCon;
  DatosCon: TDatoConductores;
  PosSep: TVectorInt;
  LenEncab: TVectorInt;
  i: Word;

procedure SeparadorLineas(PosSep: TVectorInt);
begin
  while WhereX <= PosSep[3] do
    if (WhereX = 1) or (WhereX = PosSep[3]) then
      Write('+')
    else
    if (WhereX = PosSep[1]) or (WhereX = PosSep[2]) then
      Write('+')
    else
      Write('-');
  WriteLn;
end;

begin
  // Inicializar
  CrearAbrirArchivoCon(ArchCon);
  CrearLista(ListaCon);

  for i := 1 to EncabTotales do
    LenEncab[i] := Length(Encab[i]);

  while not (EOF(ArchCon)) do
  begin
    Read(ArchCon, DatosCon);
    Agregar(ListaCon, DatosCon);  // Pasarla como parámetro, ya ordenada por ApYNom
  end;

  DatosCon.DNI := 46152098;
  DatosCon.ApYNom := 'Riolfo Franco Ariel';
  DatosCon.Scoring := 15;

  Agregar(ListaCon, DatosCon);

  for i := 1 to EncabTotales do
  begin
    if i = 1 then
      Write('|');
    Write(Encab[i], '|');
    PosSep[i] := WhereX - 1;
  end;

  WriteLn;
  for i := 1 to TamanioLista(ListaCon) do
  begin
    Recuperar(ListaCon, i, DatosCon);
    with DatosCon do
    begin
      SeparadorLineas(PosSep);
      Write('|', ApYNom:((LenEncab[1] + Length(AnsiString(ApyNom))) div 2));
      GotoXY(PosSep[1], WhereY);
      Write('|', DNI:((LenEncab[2] + Length(UIntToStr(DNI))) div 2));
      GotoXY(PosSep[2], WhereY);
      Write('|', Scoring:((LenEncab[3] + Length(IntToStr(Scoring))) div 2));
      GotoXY(PosSep[3], WhereY);
      WriteLn('|');
    end;
  end;


{
  // ¿Procedure MostrarEncabezados?
  i := 1;

  while i <= TamanioLista(Lista) do
  begin
    Recuperar(Lista, i, Texto);
    if i = 1 then
      Write('┌');
    for j := 1 to Length(Texto) do
      Write('─');
    if i = TamanioLista(Lista) then
      WriteLn('┐')
    else
      Write('┬');
    Inc(i);
  end;

  i := 1;

  while i <= TamanioLista(Lista) do
  begin
    Recuperar(Lista, i, Texto);
    Write('│'+ Texto);
    if i = TamanioLista(Lista) then
      WriteLn('│');
    Inc(i);
  end;

  i := 1;

  while i <= TamanioLista(Lista) do
  begin
    Recuperar(Lista, i, Texto);
    if i = 1 then
      Write('├');
    for j := 1 to Length(Texto) do
      Write('─');
    if i = TamanioLista(Lista) then
      WriteLn('┤')
    else
      Write('┼');
    Inc(i);
  end;

  i := 1;

  while i <= TamanioLista(ListaCon) do
  begin
    Recuperar(ListaCon, i, DatosCon);
    Write('│');
    Write(UIntToStr(DatosCon.DNI):11);
    Write('│');
    Write(DatosCon.ApYNom:22);
    Write('│');
    Write(DatosCon.Scoring:11);
    WriteLn('│');
    Inc(i);
  end;}

{  Texto := 'Holol';
  Write('┌');
  for i := 1 to Length(Texto) do
    Write('─');
  WriteLn('┐');
  WriteLn('│' + Texto + '│');
  Write('└');
  for i := 1 to Length(Texto) do
    Write('─');
  WriteLn('┘');
}
  
end.
