unit UnitObtenerDatos;

{$CODEPAGE UTF8}

interface

uses
  crt, sysutils, UnitTypes, UnitValidacion, UnitManejoFecha;

function ObtenerApYNom: String;
function ObtenerDNI: Cardinal;
function ObtenerTel: String;
function ObtenerEMail: String;
procedure ObtenerFechaActual(var Fecha: TRegFecha);
procedure ObtenerFechaNac(var Fecha: TRegFecha);
procedure ObtenerFechaInf(var Fecha: TRegFecha);
function ObtenerOpcion(Texto: String; CotaInf, CotaSup: Byte): String;
function ObtenerRtaSN: String;

implementation
function ObtenerApYNom: String;
begin
  ObtenerApYNom := '';
  while ObtenerApYNom = '' do
  begin
    Write('Apellido y Nombres: ');
    ReadLn(ObtenerApYNom);
    if ObtenerApYNom = '' then
      GotoXY(1, WhereY-1);
  end;
end;

function ObtenerDNI: Cardinal;
var
  Cad: String[10];
begin
  ObtenerDNI := 0;
  while (ObtenerDNI < 10000000) do
  begin
    ClrEol;
    Write('DNI (Sin puntos ni espacios): ');
    ReadLn(Cad);
    if EsNum(Cad) then
    begin
      ObtenerDNI := StrToDWord(Cad);
      if ObtenerDNI < 10000000 then
        GotoXY(1, WhereY-1);
    end
    else
      GotoXY(1, WhereY-1);
  end;
end;

function ObtenerTel: String;
var
  Cad: String[20];
begin
  ObtenerTel := '';
  while ObtenerTel = '' do
  begin
    Write('Teléfono (Sin prefijo internacional ni espacios): ');
    ClrEol;
    ReadLn(Cad);
    if EsNum(Cad) then
      ObtenerTel := Cad
    else
      GotoXY(1, WhereY-1);
  end;
end;

function ObtenerEMail: String;
begin
  Write('EMail: ');
  ReadLn(ObtenerEMail);
end;

procedure ObtenerFechaActual(var Fecha: TRegFecha);
begin
  DecodeDate(Date, Fecha.Anio, Fecha.Mes, Fecha.Dia);
end;

procedure ObtenerFechaNac(var Fecha: TRegFecha);
begin
  Write('Fecha de Nacimiento: ');
  CadARegFecha(ObtenerFechaStr, Fecha.Dia, Fecha.Mes, Fecha.Anio);
end;

procedure ObtenerFechaInf(var Fecha: TRegFecha);
var
  FechaActual: TRegFecha;
  FechaActualPas: TDateTime;
  FechaAux: String[10];
  FechaAuxPas: TDateTime;
begin
  ObtenerFechaActual(FechaActual);
  with FechaActual do
    FechaActualPas := StrToDate(FormatoFecha(Dia, Mes, Anio), '/');
  repeat
    Write('Fecha de Infracción: ');
    FechaAux := ObtenerFechaStr;
    FechaAuxPas := StrToDate(FechaAux, '/');
    if FechaAuxPas > FechaActualPas then
    begin
      TextColor(Red);
      Write(UTF8Decode('La fecha de la infracción no puede ser posterior a la fecha actual!'));
      TextColor(White);
      GotoXY(1,1);
    end;
  until FechaAuxPas <= FechaActualPas;
  
  with Fecha do
    CadARegFecha(FechaAux, Dia, Mes, Anio);
end;

function ObtenerRtaSN: String;
var
  Rta: String[2];
  PosX, PosY: Word;
begin
  PosX := WhereX;
  PosY := WhereY;
  repeat
    GotoXY(PosX, PosY);
    ClrEol;
    ReadLn(Rta);
  until (LowerCase(Rta) = 's') or (LowerCase(Rta) = 'n');
  ObtenerRtaSN := LowerCase(Rta);
end;

function ObtenerOpcion(Texto: String; CotaInf, CotaSup: Byte): String;
var
  Op: String[2];
begin
  ObtenerOpcion := '';
  while ObtenerOpcion = '' do
  begin
    Write(Texto);
    ClrEol;
    ReadLn(Op);
    if EsNum(Op) then
      if (CotaInf <= StrToInt(Op)) and (StrToInt(Op) <= CotaSup) then
        ObtenerOpcion := Op
      else
        GotoXY(1, WhereY-1)
    else
      GotoXY(1, WhereY-1);
  end;
end;

end.
