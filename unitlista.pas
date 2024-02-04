unit UnitLista;

interface

const
  N = 50;

type
  TDatoLista = String;
  TListaInf = record
    Elem: array[1..N] of TDatoLista;
    Tam: Word;
  end;

procedure CrearLista(var L: TListaInf);
procedure Agregar(var L: TListaInf; x: TDatoLista);
procedure Eliminar(var L: TListaInf; Pos: Word; var x: TDatoLista);
procedure DesplazarLista(var L: TListaInf; Pos: Word);
procedure Recuperar(var L: TListaInf; Pos: Word; var x: TDatoLista);
procedure Modificar(var L: TListaInf; Pos: Word; x: TDatoLista);
function TamanioLista(var L: TListaInf): Word;
function ListaLlena(var L: TListaInf): Boolean;
function ListaVacia(var L: TListaInf): Boolean;

implementation
procedure CrearLista(var L: TListaInf);
  begin
    L.Tam := 0;
  end;

procedure Agregar(var L: TListaInf; x: TDatoLista);
  begin
    Inc(L.Tam);
    L.Elem[L.Tam] := x;
  end;

procedure Eliminar(var L: TListaInf; Pos: Word; var x: TDatoLista);
  begin
    x := L.Elem[Pos];
    Dec(L.Tam);
    if Pos <= L.Tam then
      DesplazarLista(L, Pos);
  end;

procedure DesplazarLista(var L: TListaInf; Pos: Word);
  var
    i: 1..N;
  begin
    for i := Pos to L.Tam do
      L.Elem[i] := L.Elem[i+1];
  end;

procedure Recuperar(var L: TListaInf; Pos: Word; var x: TDatoLista);
  begin
    x := L.Elem[Pos];
  end;

procedure Modificar(var L: TListaInf; Pos: Word; x: TDatoLista);
  begin
    L.Elem[Pos] := x;
  end;

function TamanioLista(var L: TListaInf): Word;
  begin
    TamanioLista := L.Tam;
  end;

function ListaLlena(var L: TListaInf): Boolean;
  begin
    ListaLlena := (L.Tam = N);
  end;

function ListaVacia(var L: TListaInf): Boolean;
  begin
    ListaVacia := (L.Tam = 0);
  end;
end.