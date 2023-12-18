unit UnitArbol;
  
interface
type
  TDato = Char;
  TPunt = ^TNodo;
  TNodo = record
    Info: TDato;
    SAI, SAD: TPunt;
  end;

procedure CrearArbol(var Raiz: TPunt);
procedure Agregar(var Raiz: TPunt; x: TDato);
procedure Suprimir(var Raiz: TPunt; x: TDato);
procedure Inorden(var Raiz: TPunt);
function Preorden(Raiz: TPunt; Buscado: Char): TPunt;
function ArbolVacio(Raiz: TPunt): Boolean;
function ArbolLleno(Raiz: TPunt): Boolean;

implementation
procedure CrearArbol(var Raiz: TPunt);
  begin
    Raiz := NIL;
  end;

procedure Agregar(var Raiz: TPunt; x: TDato);
  begin
    if Raiz = NIL then
    begin
      New(Raiz);
      Raiz^.Info := x;
      Raiz^.SAI := NIL;
      Raiz^.SAD := NIL;
    end
    else
      if Raiz^.Info > x then
        Agregar(Raiz^.SAI, x)
      else
        Agregar(Raiz^.SAD, x);
  end;

function SuprimirMin(var Raiz: TPunt): TDato;
  begin
    if Raiz^.SAI = NIL then
    begin
      SuprimirMin := Raiz^.Info;
      Raiz := Raiz^.SAD;
    end
    else
      SuprimirMin := SuprimirMin(Raiz^.SAI);
  end;

procedure Suprimir(var Raiz: TPunt; x: TDato);
  begin
    if Raiz <> NIL then
      if x < Raiz^.Info then
        Suprimir(Raiz^.SAI, x)
      else
        Suprimir(Raiz^.SAD, x)
    else
      if (Raiz^.SAI = NIL) and (Raiz^.SAD = NIL) then
        Raiz := NIL
      else
        if Raiz^.SAI = NIL then
          Raiz := Raiz^.SAD
        else
          if Raiz^.SAD = NIL then
            Raiz := Raiz^.SAI
          else
            Raiz^.Info := SuprimirMin(Raiz^.SAD);
  end;

procedure Inorden(var Raiz: TPunt);
  begin
    if Raiz <> NIL then
    begin
      Inorden(Raiz^.SAI);
      WriteLn(Raiz^.Info);
      Inorden(Raiz^.Sad);
    end;
  end;

function Preorden(Raiz: TPunt; Buscado: Char): TPunt;
  begin
    if Raiz = NIL then
      Preorden := NIL
    else
      if Raiz^.Info = Buscado then
        Preorden := Raiz
      else
        if Raiz^.Info > Buscado then
          Preorden := Preorden(Raiz^.SAI, Buscado)
        else
          Preorden := Preorden(Raiz^.SAD, Buscado);
  end;

function ArbolVacio(Raiz: TPunt): Boolean;
  begin
    ArbolVacio := (Raiz = NIL);
  end;

function ArbolLleno(Raiz: TPunt): Boolean;
  begin
    ArbolLleno := (GetHeapStatus.TotalFree < SizeOf(TNodo));
  end;
end.