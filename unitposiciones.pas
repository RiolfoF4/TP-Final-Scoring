unit UnitPosiciones;

interface

type
  TDatoPosApYNom = record
    ApYNom: string[50];
    Pos: word;
  end;

  TDatoPosDNI = record
    DNI: cardinal;
    Pos: word;
  end;

  TPuntApYNom = ^TNodoApYNom;

  TNodoApYNom = record
    InfoApYNom: TDatoPosApYNom;
    SAI, SAD: TPuntApYNom;
  end;

  TPuntDNI = ^TNodoDNI;

  TNodoDNI = record
    InfoDNI: TDatoPosDNI;
    SAI, SAD: TPuntDNI;
  end;

{-ÁRBOL DE POSICIONES POR APELLIDO Y NOMBRE-}
procedure CrearArbolApYNom(var Raiz: TPuntApYNom);
procedure AgregarApYNom(var Raiz: TPuntApYNom; x: TDatoPosApYNom);
procedure SuprimirApYNom(var Raiz: TPuntApYNom; x: string);
procedure InordenApYNom(var Raiz: TPuntApYNom);
function PreordenApYNom(Raiz: TPuntApYNom; Buscado: string): longint;
function ArbolVacioApYNom(Raiz: TPuntApYNom): boolean;
function ArbolLlenoApYNom(Raiz: TPuntApYNom): boolean;
{-------------------------------------------}

{--------ÁRBOL DE POSICIONES POR DNI--------}
procedure CrearArbolDNI(var Raiz: TPuntDNI);
procedure AgregarDNI(var Raiz: TPuntDNI; x: TDatoPosDNI);
procedure SuprimirDNI(var Raiz: TPuntDNI; x: TDatoPosDNI);
procedure InordenDNI(var Raiz: TPuntDNI);
function PreordenDNI(Raiz: TPuntDNI; Buscado: cardinal): longint;
function ArbolVacioDNI(Raiz: TPuntDNI): boolean;
function ArbolLlenoDNI(Raiz: TPuntDNI): boolean;
{-------------------------------------------}

implementation

procedure CrearArbolApYNom(var Raiz: TPuntApYNom);
begin
  Raiz := nil;
end;

procedure AgregarApYNom(var Raiz: TPuntApYNom; x: TDatoPosApYNom);
begin
  if Raiz = nil then
  begin
    New(Raiz);
    Raiz^.InfoApYNom := x;
    Raiz^.SAI := nil;
    Raiz^.SAD := nil;
  end
  else
  if Raiz^.InfoApYNom.ApYNom > x.ApYNom then
    AgregarApYNom(Raiz^.SAI, x)
  else
    AgregarApYNom(Raiz^.SAD, x);
end;

function SuprimirMin(var Raiz: TPuntApYNom): TDatoPosApYNom;
begin
  if Raiz^.SAI = nil then
  begin
    SuprimirMin := Raiz^.InfoApYNom;
    Raiz := Raiz^.SAD;
  end
  else
    SuprimirMin := SuprimirMin(Raiz^.SAI);
end;

procedure SuprimirApYNom(var Raiz: TPuntApYNom; x: string);
begin
  if Raiz <> nil then
    if x < Raiz^.InfoApYNom.ApYNom then
      SuprimirApYNom(Raiz^.SAI, x)
    else
    if x > Raiz^.InfoApYNom.ApYNom then
      SuprimirApYNom(Raiz^.SAD, x)
    else
    if (Raiz^.SAI = nil) and (Raiz^.SAD = nil) then
      Raiz := nil
    else
    if Raiz^.SAI = nil then
      Raiz := Raiz^.SAD
    else
    if Raiz^.SAD = nil then
      Raiz := Raiz^.SAI
    else
      Raiz^.InfoApYNom := SuprimirMin(Raiz^.SAD);
end;

procedure InordenApYNom(var Raiz: TPuntApYNom);
begin
  if Raiz <> nil then
  begin
    InordenApYNom(Raiz^.SAI);
    WriteLn(Raiz^.InfoApYNom.ApYNom);
    WriteLn(Raiz^.InfoApYNom.Pos);
    InordenApYNom(Raiz^.Sad);
  end;
end;

function PreordenApYNom(Raiz: TPuntApYNom; Buscado: string): longint;
begin
  if Raiz = nil then
    PreordenApYNom := -1
  else
  if LowerCase(Raiz^.InfoApYNom.ApYNom) = LowerCase(Buscado) then
    PreordenApYNom := Raiz^.InfoApYNom.Pos
  else
  if LowerCase(Raiz^.InfoApYNom.ApYNom) > LowerCase(Buscado) then
    PreordenApYNom := PreordenApYNom(Raiz^.SAI, Buscado)
  else
    PreordenApYNom := PreordenApYNom(Raiz^.SAD, Buscado);
end;

function ArbolVacioApYNom(Raiz: TPuntApYNom): boolean;
begin
  ArbolVacioApYNom := (Raiz = nil);
end;

function ArbolLlenoApYNom(Raiz: TPuntApYNom): boolean;
begin
  ArbolLlenoApYNom := (GetHeapStatus.TotalFree < SizeOf(TNodoApYNom));
end;

procedure CrearArbolDNI(var Raiz: TPuntDNI);
begin
  Raiz := nil;
end;

procedure AgregarDNI(var Raiz: TPuntDNI; x: TDatoPosDNI);
begin
  if Raiz = nil then
  begin
    New(Raiz);
    Raiz^.InfoDNI := x;
    Raiz^.SAI := nil;
    Raiz^.SAD := nil;
  end
  else
  if Raiz^.InfoDNI.DNI > x.DNI then
    AgregarDNI(Raiz^.SAI, x)
  else
    AgregarDNI(Raiz^.SAD, x);
end;

function SuprimirMin(var Raiz: TPuntDNI): TDatoPosDNI;
begin
  if Raiz^.SAI = nil then
  begin
    SuprimirMin := Raiz^.InfoDNI;
    Raiz := Raiz^.SAD;
  end
  else
    SuprimirMin := SuprimirMin(Raiz^.SAI);
end;

procedure SuprimirDNI(var Raiz: TPuntDNI; x: TDatoPosDNI);
begin
  if Raiz <> nil then
    if x.DNI < Raiz^.InfoDNI.DNI then
      SuprimirDNI(Raiz^.SAI, x)
    else
    if x.DNI < Raiz^.InfoDNI.DNI then
      SuprimirDNI(Raiz^.SAD, x)
    else
    if (Raiz^.SAI = nil) and (Raiz^.SAD = nil) then
      Raiz := nil
    else
    if Raiz^.SAI = nil then
      Raiz := Raiz^.SAD
    else
    if Raiz^.SAD = nil then
      Raiz := Raiz^.SAI
    else
      Raiz^.InfoDNI := SuprimirMin(Raiz^.SAD);
end;

procedure InordenDNI(var Raiz: TPuntDNI);
begin
  if Raiz <> nil then
  begin
    InordenDNI(Raiz^.SAI);
    WriteLn(Raiz^.InfoDNI.DNI);
    InordenDNI(Raiz^.Sad);
  end;
end;

function PreordenDNI(Raiz: TPuntDNI; Buscado: cardinal): longint;
begin
  if Raiz = nil then
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

function ArbolVacioDNI(Raiz: TPuntDNI): boolean;
begin
  ArbolVacioDNI := (Raiz = nil);
end;

function ArbolLlenoDNI(Raiz: TPuntDNI): boolean;
begin
  ArbolLlenoDNI := (GetHeapStatus.TotalFree < SizeOf(TNodoDNI));
end;

end.
