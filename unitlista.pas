unit UnitLista;

interface

uses
  UnitTypes;

const
  N = 50;

type
  TDatoLista = shortstring;

  TListaInf = record
    Elem: array[1..N] of TDatoLista;
    Tam: word;
  end;

  TListaDatosInf = record
    Elem: array[1..N] of TDatoInfracciones;
    Tam: word;
  end;

  TListaDatosCon = record
    Elem: array[1..N] of TDatoConductores;
    Tam: word;
  end;

procedure CrearLista(var L: TListaInf);
procedure Agregar(var L: TListaInf; x: TDatoLista);
procedure Eliminar(var L: TListaInf; Pos: word; var x: TDatoLista);
procedure DesplazarLista(var L: TListaInf; Pos: word);
procedure Recuperar(var L: TListaInf; Pos: word; var x: TDatoLista);
procedure Modificar(var L: TListaInf; Pos: word; x: TDatoLista);
function TamanioLista(var L: TListaInf): word;
function ListaLlena(var L: TListaInf): boolean;
function ListaVacia(var L: TListaInf): boolean;

procedure CrearLista(var L: TListaDatosInf);
procedure Agregar(var L: TListaDatosInf; x: TDatoInfracciones);
procedure Eliminar(var L: TListaDatosInf; Pos: word; var x: TDatoInfracciones);
procedure DesplazarLista(var L: TListaDatosInf; Pos: word);
procedure Recuperar(var L: TListaDatosInf; Pos: word; var x: TDatoInfracciones);
procedure Modificar(var L: TListaDatosInf; Pos: word; x: TDatoInfracciones);
function TamanioLista(var L: TListaDatosInf): word;
function ListaLlena(var L: TListaDatosInf): boolean;
function ListaVacia(var L: TListaDatosInf): boolean;

procedure CrearLista(var L: TListaDatosCon);
procedure Agregar(var L: TListaDatosCon; x: TDatoConductores);
procedure Eliminar(var L: TListaDatosCon; Pos: word; var x: TDatoConductores);
procedure DesplazarLista(var L: TListaDatosCon; Pos: word);
procedure Recuperar(var L: TListaDatosCon; Pos: word; var x: TDatoConductores);
procedure Modificar(var L: TListaDatosCon; Pos: word; x: TDatoConductores);
function TamanioLista(var L: TListaDatosCon): word;
function ListaLlena(var L: TListaDatosCon): boolean;
function ListaVacia(var L: TListaDatosCon): boolean;

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

procedure Eliminar(var L: TListaInf; Pos: word; var x: TDatoLista);
begin
  x := L.Elem[Pos];
  Dec(L.Tam);
  if Pos <= L.Tam then
    DesplazarLista(L, Pos);
end;

procedure DesplazarLista(var L: TListaInf; Pos: word);
var
  i: 1..N;
begin
  for i := Pos to L.Tam do
    L.Elem[i] := L.Elem[i + 1];
end;

procedure Recuperar(var L: TListaInf; Pos: word; var x: TDatoLista);
begin
  x := L.Elem[Pos];
end;

procedure Modificar(var L: TListaInf; Pos: word; x: TDatoLista);
begin
  L.Elem[Pos] := x;
end;

function TamanioLista(var L: TListaInf): word;
begin
  TamanioLista := L.Tam;
end;

function ListaLlena(var L: TListaInf): boolean;
begin
  ListaLlena := (L.Tam = N);
end;

function ListaVacia(var L: TListaInf): boolean;
begin
  ListaVacia := (L.Tam = 0);
end;

procedure CrearLista(var L: TListaDatosInf);
begin
  L.Tam := 0;
end;

procedure Agregar(var L: TListaDatosInf; x: TDatoInfracciones);
begin
  Inc(L.Tam);
  L.Elem[L.Tam] := x;
end;

procedure Eliminar(var L: TListaDatosInf; Pos: word; var x: TDatoInfracciones);
begin
  x := L.Elem[Pos];
  Dec(L.Tam);
  if Pos <= L.Tam then
    DesplazarLista(L, Pos);
end;

procedure DesplazarLista(var L: TListaDatosInf; Pos: word);
var
  i: 1..N;
begin
  for i := Pos to L.Tam do
    L.Elem[i] := L.Elem[i + 1];
end;

procedure Recuperar(var L: TListaDatosInf; Pos: word; var x: TDatoInfracciones);
begin
  x := L.Elem[Pos];
end;

procedure Modificar(var L: TListaDatosInf; Pos: word; x: TDatoInfracciones);
begin
  L.Elem[Pos] := x;
end;

function TamanioLista(var L: TListaDatosInf): word;
begin
  TamanioLista := L.Tam;
end;

function ListaLlena(var L: TListaDatosInf): boolean;
begin
  ListaLlena := (L.Tam = N);
end;

function ListaVacia(var L: TListaDatosInf): boolean;
begin
  ListaVacia := (L.Tam = 0);
end;




procedure CrearLista(var L: TListaDatosCon);
begin
  L.Tam := 0;
end;

procedure Agregar(var L: TListaDatosCon; x: TDatoConductores);
begin
  Inc(L.Tam);
  L.Elem[L.Tam] := x;
end;

procedure Eliminar(var L: TListaDatosCon; Pos: word; var x: TDatoConductores);
begin
  x := L.Elem[Pos];
  Dec(L.Tam);
  if Pos <= L.Tam then
    DesplazarLista(L, Pos);
end;

procedure DesplazarLista(var L: TListaDatosCon; Pos: word);
var
  i: 1..N;
begin
  for i := Pos to L.Tam do
    L.Elem[i] := L.Elem[i + 1];
end;

procedure Recuperar(var L: TListaDatosCon; Pos: word; var x: TDatoConductores);
begin
  x := L.Elem[Pos];
end;

procedure Modificar(var L: TListaDatosCon; Pos: word; x: TDatoConductores);
begin
  L.Elem[Pos] := x;
end;

function TamanioLista(var L: TListaDatosCon): word;
begin
  TamanioLista := L.Tam;
end;

function ListaLlena(var L: TListaDatosCon): boolean;
begin
  ListaLlena := (L.Tam = N);
end;

function ListaVacia(var L: TListaDatosCon): boolean;
begin
  ListaVacia := (L.Tam = 0);
end;

end.
