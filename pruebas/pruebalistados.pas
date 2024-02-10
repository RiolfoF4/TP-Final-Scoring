program PruebaListados;
{$CODEPAGE UTF8}

uses
  sysutils, UnitLista, UnitArchivo, UnitTypes;

{
  '┌', '┐', '└', '┘',
  '─', '│'
  '├', '┤', '┬', '┴', '┼'
}

var
  ArchCon: TArchCon;
  DatosCon: TDatoConductores;
  ListaCon: TListaCon;
  Lista: TListaInf;
  Box: WideString;
  Texto: String;
  i, j: Word;

begin
  CrearLista(Lista);
  CrearLista(ListaCon);
  Agregar(Lista, '    DNI    ');
  Agregar(Lista, '  NOMBRE Y APELLIDOS  ');
  Agregar(Lista, '  SCORING  ');

  CrearAbrirArchivoCon(ArchCon);
  while not (EOF(ArchCon)) do
  begin
    Read(ArchCon, DatosCon);
    Agregar(ListaCon, DatosCon);
  end;


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
    WriteLn('│' + UIntToStr(DatosCon.DNI) + '│' + DatosCon.ApYNom + '│' + IntToStr(DatosCon.Scoring) + '│');
    Inc(i);
  end;

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