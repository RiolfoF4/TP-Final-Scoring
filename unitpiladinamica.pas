unit UnitPilaDinamica;

interface

type
  TDatoPilaDin = word;
  TPunt = ^TNodo;

  TNodo = record
    Info: TDatoPilaDin;
    Sig: TPunt;
  end;

  TPilaDin = record
    Tope: TPunt;
    Tam: word;
  end;

procedure CrearPila(var P: TPilaDin);
procedure Apilar(var P: TPilaDin; x: TDatoPilaDin);
procedure Desapilar(var P: TPilaDin; var x: TDatoPilaDin);

function TamanioPila(P: TPilaDin): word;
function PilaLlena(P: TPilaDin): boolean;
function PilaVacia(P: TPilaDin): boolean;

implementation

procedure CrearPila(var P: TPilaDin);
begin
  P.Tope := nil;
  P.Tam := 0;
end;

procedure Apilar(var P: TPilaDin; x: TDatoPilaDin);
var
  Dir: TPunt;
begin
  New(Dir);
  Dir^.Info := x;
  Dir^.Sig := P.Tope;
  P.Tope := Dir;
  Inc(P.Tam);
end;

procedure Desapilar(var P: TPilaDin; var x: TDatoPilaDin);
var
  Dir: TPunt;
begin
  x := P.Tope^.Info;
  Dir := P.Tope;
  P.Tope := Dir^.Sig;
  Dispose(Dir);
  Dec(P.Tam);
end;

function TamanioPila(P: TPilaDin): word;
begin
  TamanioPila := P.Tam;
end;

function PilaLlena(P: TPilaDin): boolean;
begin
  PilaLlena := (GetHeapStatus.TotalFree < SizeOf(TPilaDin));
end;

function PilaVacia(P: TPilaDin): boolean;
begin
  PilaVacia := (P.Tam = 0);
end;

end.
