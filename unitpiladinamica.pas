unit UnitPilaDinamica;

interface

type
  TDatoPilaDin = Byte;
  TPunt = ^TNodo;
  TNodo = record
   Info: TDatoPilaDin;
   Sig: TPunt;
  end;
  TPilaDin = record
    Tope: TPunt;
    Tam: Word;
  end;

procedure CrearPila(var P: TPilaDin);
procedure Apilar(var P: TPilaDin; x: TDatoPilaDin);
procedure Desapilar(var P: TPilaDin; var x: TDatoPilaDin);

function TamanioPila(P: TPilaDin): Word;
function PilaLlena(P: TPilaDin): Boolean;
function PilaVacia(P: TPilaDin): Boolean;

implementation
procedure CrearPila(var P: TPilaDin);
  begin
    P.Tope := NIL;
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

function TamanioPila(P: TPilaDin): Word;
  begin
    TamanioPila := P.Tam;
  end;

function PilaLlena(P: TPilaDin): Boolean;
  begin
    PilaLlena := (GetHeapStatus.TotalFree < SizeOf(TPilaDin));
  end;

function PilaVacia(P: TPilaDin): Boolean;
  begin
    PilaVacia := (P.Tam = 0);
  end;
end.
