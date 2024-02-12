unit UnitPila;

interface

const
  N = 10;

type
  TDatoPila = Byte;
  TPila = record
    Elem: array[1..N] of TDatoPila;
    Tope: Word;
    Tam: Word;
  end;

procedure CrearPila(var P: TPila);
procedure Apilar(var P: TPila; x: TDatoPila);
procedure Desapilar(var P: TPila; var x: TDatoPila);
function TamanioPila(P: TPila): Word;
function PilaVacia(P: TPila): Boolean;
function PilaLlena(P: TPila): Boolean;

implementation
procedure CrearPila(var P: TPila);
begin
  P.Tope := 0;
  P.Tam := 0;
end;

procedure Apilar(var P: TPila; x: TDatoPila);
begin
  Inc(P.Tope);
  P.Elem[P.Tope] := x;
  Inc(P.Tam);
end;

procedure Desapilar(var P: TPila; var x: TDatoPila);
begin
  x := P.Elem[P.Tope];
  Dec(P.Tope);
  Dec(P.Tam);
end;

function TamanioPila(P: TPila): Word;
begin
  TamanioPila := P.Tam;
end;

function PilaVacia(P: TPila): Boolean;
begin
  if P.Tam = 0 then
    PilaVacia := True
  else
    PilaVacia := False;
end;

function PilaLlena(P: TPila): Boolean;
begin
  if P.Tam = N then
    PilaLlena := True
  else
    PilaLlena := False;
end;
end.
