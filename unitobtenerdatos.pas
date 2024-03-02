unit UnitObtenerDatos;

{$CODEPAGE UTF8}

interface

uses
  crt, SysUtils, UnitTypes, UnitValidacion, UnitManejoFecha;

function ObtenerApYNom: string;
function ObtenerDNI: cardinal;
function ObtenerTel: string;
function ObtenerEMail: string;
procedure ObtenerFechaActual(var Fecha: TRegFecha);
procedure ObtenerFechaNac(var Fecha: TRegFecha);
procedure ObtenerFechaInf(var Fecha: TRegFecha);
procedure ObtenerFechaInicioFin(var FechaInicio: TRegFecha; var FechaFin: TRegFecha);
function ObtenerOpcion(Texto: string; CotaInf, CotaSup: byte): string;
function ObtenerRtaSN: string;

implementation

function ObtenerApYNom: string;
begin
  SetUseACP(False);
  ObtenerApYNom := '';
  while ObtenerApYNom = '' do
  begin
    Write('Apellido y Nombres: ');
    ReadLn(ObtenerApYNom);
    if ObtenerApYNom = '' then
      GotoXY(1, WhereY - 1);
  end;
  SetUseACP(True);
end;

function ObtenerDNI: cardinal;
var
  Cad: string[10];
begin
  ObtenerDNI := 0;
  while not ((ObtenerDNI > 10000000) and (ObtenerDNI < 100000000)) do
  begin
    ClrEol;
    Write('DNI (Sin puntos ni espacios): ');
    ReadLn(Cad);
    if EsNum(Cad) then
    begin
      ObtenerDNI := StrToDWord(Cad);
      if not ((ObtenerDNI > 10000000) and (ObtenerDNI < 100000000)) then
        GotoXY(1, WhereY - 1);
    end
    else
      GotoXY(1, WhereY - 1);
  end;
end;

function ObtenerTel: string;
var
  Cad: string[20];
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
      GotoXY(1, WhereY - 1);
  end;
end;

function ObtenerEMail: string;
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
  FechaAux: string[10];
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
      Write(UTF8Decode(
        'La fecha de la infracción no puede ser posterior a la fecha actual!'));
      TextColor(White);
      GotoXY(1, 1);
    end;
  until FechaAuxPas <= FechaActualPas;

  with Fecha do
    CadARegFecha(FechaAux, Dia, Mes, Anio);
end;

procedure ObtenerFechaInicioFin(var FechaInicio: TRegFecha; var FechaFin: TRegFecha);
var
  PosX: Word;
  PosY: Word;
begin
  Write('Fecha de Inicio: ');
  with FechaInicio do
    CadARegFecha(ObtenerFechaStr, Dia, Mes, Anio);
  
  // Repetir hasta que la fecha de Fin sea posterior o igual (NO anterior) a la fecha de Inicio
  Write('Fecha de Fin: ');
  PosX := WhereX;
  PosY := WhereY;
  repeat
    GotoXY(PosX, PosY);
    with FechaFin do
      CadARegFecha(ObtenerFechaStr, Dia, Mes, Anio);
    if EsFechaAnterior(FechaFin.Dia, FechaFin.Mes, FechaFin.Anio, FechaInicio.Dia, FechaInicio.Mes, FechaInicio.Anio) then
    begin
      TextColor(Red);
      WriteLn(UTF8Decode('¡La fecha de Fin no puede ser posterior a la fecha de Inicio!'));
      TextColor(White);
    end;
  until not (EsFechaAnterior(FechaFin.Dia, FechaFin.Mes, FechaFin.Anio, FechaInicio.Dia, FechaInicio.Mes, FechaInicio.Anio));
end;

function ObtenerRtaSN: string;
var
  Rta: string[2];
  PosX, PosY: word;
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

function ObtenerOpcion(Texto: string; CotaInf, CotaSup: byte): string;
var
  Op: string[2];
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
        GotoXY(1, WhereY - 1)
    else
      GotoXY(1, WhereY - 1);
  end;
end;

end.
