unit UnitListaDinamica;

interface

type
  TDatoListaDin = Char;
  TPunt = ^TNodo;
  TNodo = record
    Info: TDatoListaDin;
    Sig: TPunt;
    Ant: TPunt;
  end;
  TListaDin = record
    Cab: TPunt;
    Act: TPunt;
    Tam: Word;
  end;

procedure CrearLista(var L: TListaDin);
procedure Agregar(var L: TListaDin; x: TDatoListaDin);
procedure Eliminar(var L: TListaDin; Buscado: TDatoListaDin; var x: TDatoListaDin);
procedure Recuperar(var L: TListaDin; var x: TDatoListaDin);
procedure EliminarLista(var L: TListaDin);

procedure Primero(var L: TListaDin);
procedure Siguiente(var L: TListaDin);
procedure Anterior(var L: TListaDin);
procedure Ultimo(var L: TListaDin);
procedure BuscarPos(var L: TListaDin; Pos: Word);

function TamanioLista(L: TListaDin): Word;
function ListaVacia(L: TListaDin): Boolean;
function ListaLlena(L: TListaDin): Boolean;
function Fin(L: TListaDin): Boolean;

implementation
procedure CrearLista(var L: TListaDin);
begin
  L.Cab := NIL;
  L.Tam := 0;
end;

procedure Agregar(var L: TListaDin; x: TDatoListaDin);
var
  Dir: TPunt;
  Ant: TPunt;
begin
  New(Dir);
  Dir^.Info := x;
  if (L.Cab = NIL) or (L.Cab^.Info > x) then
  begin
    Dir^.Sig := L.Cab;
    if L.Cab <> NIL then
      L.Cab^.Ant := Dir;
    Dir^.Ant := NIL;
    L.Cab := Dir;
  end
  else
  begin
    Ant := L.Cab;
    L.Act := L.Cab^.Sig;
    while (L.Act <> NIL) and (L.Act^.Info < x) do
    begin
      Ant := L.Act;
      L.Act := L.Act^.Sig;
    end;
    Dir^.Sig := L.Act;
    Dir^.Ant := Ant;
    Ant^.Sig := Dir;
  end;
  Inc(L.Tam);
end;

procedure Eliminar(var L: TListaDin; Buscado: TDatoListaDin; var x: TDatoListaDin);
var
  Dir: TPunt;
  Ant: TPunt;
begin
  if L.Cab^.Info = Buscado then
  begin
    x := L.Cab^.Info;
    Dir := L.Cab;
    L.Cab := Dir^.Sig;
  end
  else
  begin
    Ant := L.Cab;
    L.Act := L.Cab^.Sig;
    while (L.Act^.Info <> Buscado) do
    begin
      Ant := L.Act;
      L.Act := L.Act^.Sig;
    end;
    x := L.Act^.Info;
    Dir := L.Act;
    Ant^.Sig := L.Act^.Sig;
  end;
  Dispose(Dir);
  Dec(L.Tam);
end;

procedure Recuperar(var L: TListaDin; var x: TDatoListaDin);
begin
  x := L.Act^.Info;
end;

procedure EliminarLista(var L: TListaDin);
begin
  Primero(L);
  while L.Cab <> NIL do
  begin
    L.Act := L.Cab;
    L.Cab := L.Cab^.Sig;
    Dispose(L.Act);
  end;
end;

procedure Primero(var L: TListaDin);
begin
  L.Act := L.Cab;
end;

procedure Siguiente(var L: TListaDin);
begin
  L.Act := L.Act^.Sig;
end;

procedure Anterior(var L: TListaDin);
begin
  L.Act := L.Act^.Ant;
end;

procedure Ultimo(var L: TListaDin);
begin
  L.Act := L.Cab;
  while L.Act^.Sig <> NIL do
    L.Act := L.Act^.Sig;
end;

procedure BuscarPos(var L: TListaDin; Pos: Word);
var
  i: Word;
begin
  Primero(L);
  for i := 1 to Pos - 1 do
    Siguiente(L);
end;

function TamanioLista(L: TListaDin): Word;
begin
  TamanioLista := L.Tam;
end;

function ListaVacia(L: TListaDin): Boolean;
begin
  ListaVacia := (L.Tam = 0);
end;

function ListaLlena(L: TListaDin): Boolean;
begin
  ListaLlena := (GetHeapStatus.TotalFree < SizeOf(L));
end;

function Fin(L: TListaDin): Boolean;
begin
  Fin := (L.Act = NIL);
end;
end.
