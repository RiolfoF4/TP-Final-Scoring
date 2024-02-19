unit UnitPila;

interface

const
  N = 10;

type
  TDato = word;

  TPila = record
    Elem: array[1..N] of TDato;
    Tope: word;
    Tam: word;
  end;

procedure CrearPila(var P: TPila);
procedure Apilar(var P: TPila; x: TDato);
procedure Desapilar(var P: TPila; var x: TDato);
function TamanioPila(P: TPila): word;
function PilaVacia(P: TPila): boolean;
function PilaLlena(P: TPila): boolean;

implementation

procedure CrearPila(var P: TPila);
begin
  P.Tope := 0;
  P.Tam := 0;
end;

procedure Apilar(var P: TPila; x: TDato);
begin
  Inc(P.Tope);
  P.Elem[P.Tope] := x;
  Inc(P.Tam);
end;

procedure Desapilar(var P: TPila; var x: TDato);
begin
  x := P.Elem[P.Tope];
  Dec(P.Tope);
  Dec(P.Tam);
end;

function TamanioPila(P: TPila): word;
begin
  TamanioPila := P.Tam;
end;

function PilaVacia(P: TPila): boolean;
begin
  if P.Tam = 0 then
    PilaVacia := True
  else
    PilaVacia := False;
end;

function PilaLlena(P: TPila): boolean;
begin
  if P.Tam = N then
    PilaLlena := True
  else
    PilaLlena := False;
end;

end.
