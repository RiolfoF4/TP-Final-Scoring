program pruebalista;

uses
  UnitListaDinamica;

var
  L: TListaDin;
  Carac: Char;
  Pos: Word;

begin
  CrearLista(L);
  Write('Caracter: ');
  ReadLn(Carac);
  while (Carac <> 'q') and not (ListaLlena(L)) do
  begin
    if not ListaLlena(L) then
      Agregar(L, Carac);
    Write('Caracter: ');
    ReadLn(Carac);
  end;
  Primero(L);
  while not Fin(L) do
  begin
    Recuperar(L, Carac);
    WriteLn(Carac);
    Siguiente(L);
  end;
  WriteLn;
  Ultimo(L);
  while not Fin(L) do
  begin
    Recuperar(L, Carac);
    WriteLn(Carac);
    Anterior(L);
  end;
  WriteLn;
  Write('Pos: ');
  ReadLn(Pos);
  BuscarPos(L, Pos);
  Recuperar(L, Carac);
  WriteLn(Carac);
  WriteLn('FIN');
  EliminarLista(L);
  ReadLn;
end.