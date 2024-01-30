unit UnitObtenerDatos;

{$CODEPAGE UTF8}

interface

uses
  crt, sysutils, UnitArchivo, UnitValidacion, UnitManejoFecha;

function ObtenerApYNom: String;
function ObtenerDNI: Cardinal;
function ObtenerTel: String;
function ObtenerEMail: String;
procedure ObtenerFechaActual(var Fecha: TRegFecha);
procedure ObtenerFechaNac(var Fecha: TRegFecha);
procedure ObtenerFechaInf(var Fecha: TRegFecha);
function ObtenerOpcionAlta: String;
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
begin
  Write('Fecha de Infracción: ');
  CadARegFecha(ObtenerFechaStr, Fecha.Dia, Fecha.Mes, Fecha.Anio);
end;

function ObtenerOpcionAlta: String;
var
  Op: String[2];
begin
  ObtenerOpcionAlta := '';
  WriteLn('¿Son correctos los datos ingresados?');
  WriteLn('[1] Sí');
  WriteLn('[2] No (Modificar)');
  WriteLn('[0] CANCELAR ALTA');
  WriteLn;

  while ObtenerOpcionAlta = '' do
  begin
    Write('Opción: ');
    ClrEol;
    ReadLn(Op);
    if (Op = '1') or (Op = '2') or (Op = '0') then
      ObtenerOpcionAlta := Op
    else
      GotoXY(1, WhereY-1);
  end;
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
end.
