program PruebaListados;
{$CODEPAGE UTF8}

uses
  sysutils, UnitLista, UnitArchivo, UnitTypes;

{
  '┌', '┐', '└', '┘',
  '─', '│'
  '├', '┤', '┬', '┴', '┼'
}

const
  Encab: array[1..3] of String = 
    ('   DNI   ', ' NOMBRE Y APELLIDOS ', ' SCORING ');
  Sep = '│';

var
  i: Word;
  ListaCon: TListaCon;
  DatosCon: TDatoConductores;
  ArchCon: TArchCon;

begin
  for i := 1 to 3 do
  begin
    Write(Sep);
    Write(Encab[i]);
    Write(Sep);
  end;
  WriteLn;

  CrearLista(ListaCon);

  CrearAbrirArchivoCon(ArchCon);
  while not (EOF(ArchCon)) do
  begin
    Read(ArchCon, DatosCon);
    Agregar(ListaCon, DatosCon);
  end;

  i := 1;
  while i <= TamanioLista(ListaCon) do
  begin
    Recuperar(ListaCon, i, DatosCon);
    Write(Sep);
    Write(UIntToStr(DatosCon.DNI):Length(Encab[1]));
    Write(Sep, Sep);
    Write(DatosCon.ApYNom:Length(Encab[2]));
    Write(Sep, Sep);
    Write(IntToStr(DatosCon.Scoring):Length(Encab[3]));
    WriteLn(Sep);
    Inc(i);
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
