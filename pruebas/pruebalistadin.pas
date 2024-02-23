program PruebaListaDin;

uses
  Crt, UnitListaDinamica;

const
  LimiteInf = 14;

var
  L: TListaDin;
  Carac: Char;
  i: Word;

procedure MostrarLista(var L: TListaDin);
var
  C: Char;
  i: Word;
begin
  i := 1;
  Primero(L);
  while not Fin(L) do
  begin
    Recuperar(L, C);
    WriteLn(i, ': ', C);
    Inc(I);
    Siguiente(L);
  end;
  WriteLn;
end;

begin
  ClrScr;
  CrearLista(L);
  for i := 75 to 100 do
    Agregar(L, Char(i));

  MostrarLista(L);
  
  repeat
    Write('Pos: ');
    ReadLn(i);
    if (i <> 0) and (i <= TamanioLista(L)) then
    begin
      BuscarPos(L, i);
      Recuperar(L, Carac);
      WriteLn('Elemento ', i, ': ', Carac);
    end;
  until i = 0;
end.