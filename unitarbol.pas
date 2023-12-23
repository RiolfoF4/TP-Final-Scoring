unit UnitArbol;
  
interface
type
  TDatoApYNom = record
    ApYNom: String[100];
    Pos: Word;
  end;

  TDatoDNI = record
    DNI: Cardinal;
    Pos: Word;
  end;
  
  TPuntApYNom = ^TNodoApYNom;
  TNodoApYNom = record
    InfoApYNom: TDatoApYNom;
    SAI, SAD: TPuntApYNom;
  end;

  TPuntDNI = ^TNodoDNI;
  TNodoDNI = record
    InfoDNI: TDatoDNI;
    SAI, SAD: TPuntDNI;
  end;

{ÁRBOL DE POSICIONES POR APELLIDO Y NOMBRE}
procedure CrearArbolApYNom(var Raiz: TPuntApYNom);
procedure AgregarApYNom(var Raiz: TPuntApYNom; x: TDatoApYNom);
procedure SuprimirApYNom(var Raiz: TPuntApYNom; x: TDatoApYNom);
procedure InordenApYNom(var Raiz: TPuntApYNom);
function PreordenApYNom(Raiz: TPuntApYNom; Buscado: String): LongInt;
function ArbolVacioApYNom(Raiz: TPuntApYNom): Boolean;
function ArbolLlenoApYNom(Raiz: TPuntApYNom): Boolean;
{-----------------------------------------}
{-------ÁRBOL DE POSICIONES POR DNI-------}
procedure CrearArbolDNI(var Raiz: TPuntDNI);
procedure AgregarDNI(var Raiz: TPuntDNI; x: TDatoDNI);
procedure SuprimirDNI(var Raiz: TPuntDNI; x: TDatoDNI);
procedure InordenDNI(var Raiz: TPuntDNI);
function PreordenDNI(Raiz: TPuntDNI; Buscado: Cardinal): LongInt;
function ArbolVacioDNI(Raiz: TPuntDNI): Boolean;
function ArbolLlenoDNI(Raiz: TPuntDNI): Boolean;
{-----------------------------------------}

implementation
procedure CrearArbolApYNom(var Raiz: TPuntApYNom);
  begin
    Raiz := NIL;
  end;

procedure AgregarApYNom(var Raiz: TPuntApYNom; x: TDatoApYNom);
  begin
    if Raiz = NIL then
    begin
      New(Raiz);
      Raiz^.InfoApYNom := x;
      Raiz^.SAI := NIL;
      Raiz^.SAD := NIL;
    end
    else
      if Raiz^.InfoApYNom.ApYNom > x.ApYNom then
        AgregarApYNom(Raiz^.SAI, x)
      else
        AgregarApYNom(Raiz^.SAD, x);
  end;

function SuprimirMin(var Raiz: TPuntApYNom): TDatoApYNom;
  begin
    if Raiz^.SAI = NIL then
    begin
      SuprimirMin := Raiz^.InfoApYNom;
      Raiz := Raiz^.SAD;
    end
    else
      SuprimirMin := SuprimirMin(Raiz^.SAI);
  end;

procedure SuprimirApYNom(var Raiz: TPuntApYNom; x: TDatoApYNom);
  begin
    if Raiz <> NIL then
      if x.ApYNom < Raiz^.InfoApYNom.ApYNom then
        SuprimirApYNom(Raiz^.SAI, x)
      else
        SuprimirApYNom(Raiz^.SAD, x)
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
            Raiz^.InfoApYNom := SuprimirMin(Raiz^.SAD);
  end;

procedure InordenApYNom(var Raiz: TPuntApYNom);
  begin
    if Raiz <> NIL then
    begin
      InordenApYNom(Raiz^.SAI);
      WriteLn(Raiz^.InfoApYNom.ApYNom);
      WriteLn(Raiz^.InfoApYNom.Pos);
      InordenApYNom(Raiz^.Sad);
    end;
  end;

function PreordenApYNom(Raiz: TPuntApYNom; Buscado: String): LongInt;
  begin
    if Raiz = NIL then
      PreordenApYNom := -1
    else
      if Raiz^.InfoApYNom.ApYNom = Buscado then
        PreordenApYNom := Raiz^.InfoApYNom.Pos
      else
        if Raiz^.InfoApYNom.ApYNom > Buscado then
          PreordenApYNom := PreordenApYNom(Raiz^.SAI, Buscado)
        else
          PreordenApYNom := PreordenApYNom(Raiz^.SAD, Buscado);
  end;

function ArbolVacioApYNom(Raiz: TPuntApYNom): Boolean;
  begin
    ArbolVacioApYNom := (Raiz = NIL);
  end;

function ArbolLlenoApYNom(Raiz: TPuntApYNom): Boolean;
  begin
    ArbolLlenoApYNom := (GetHeapStatus.TotalFree < SizeOf(TNodoApYNom));
  end;

procedure CrearArbolDNI(var Raiz: TPuntDNI);
  begin
    Raiz := NIL;
  end;

procedure AgregarDNI(var Raiz: TPuntDNI; x: TDatoDNI);
  begin
    if Raiz = NIL then
    begin
      New(Raiz);
      Raiz^.InfoDNI := x;
      Raiz^.SAI := NIL;
      Raiz^.SAD := NIL;
    end
    else
      if Raiz^.InfoDNI.DNI > x.DNI then
        AgregarDNI(Raiz^.SAI, x)
      else
        AgregarDNI(Raiz^.SAD, x);
  end;

function SuprimirMin(var Raiz: TPuntDNI): TDatoDNI;
  begin
    if Raiz^.SAI = NIL then
    begin
      SuprimirMin := Raiz^.InfoDNI;
      Raiz := Raiz^.SAD;
    end
    else
      SuprimirMin := SuprimirMin(Raiz^.SAI);
  end;

procedure SuprimirDNI(var Raiz: TPuntDNI; x: TDatoDNI);
  begin
    if Raiz <> NIL then
      if x.DNI < Raiz^.InfoDNI.DNI then
        SuprimirDNI(Raiz^.SAI, x)
      else
        SuprimirDNI(Raiz^.SAD, x)
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
            Raiz^.InfoDNI := SuprimirMin(Raiz^.SAD);
  end;

procedure InordenDNI(var Raiz: TPuntDNI);
  begin
    if Raiz <> NIL then
    begin
      InordenDNI(Raiz^.SAI);
      WriteLn(Raiz^.InfoDNI.DNI);
      WriteLn(Raiz^.InfoDNI.Pos);
      InordenDNI(Raiz^.Sad);
    end;
  end;

function PreordenDNI(Raiz: TPuntDNI; Buscado: Cardinal): LongInt;
  begin
    if Raiz = NIL then
      PreordenDNI := -1
    else
      if Raiz^.InfoDNI.DNI = Buscado then
        PreordenDNI := Raiz^.InfoDNI.Pos
      else
        if Raiz^.InfoDNI.DNI > Buscado then
          PreordenDNI := PreordenDNI(Raiz^.SAI, Buscado)
        else
          PreordenDNI := PreordenDNI(Raiz^.SAD, Buscado);
  end;

function ArbolVacioDNI(Raiz: TPuntDNI): Boolean;
  begin
    ArbolVacioDNI := (Raiz = NIL);
  end;

function ArbolLlenoDNI(Raiz: TPuntDNI): Boolean;
  begin
    ArbolLlenoDNI := (GetHeapStatus.TotalFree < SizeOf(TNodoDNI));
  end;
end.