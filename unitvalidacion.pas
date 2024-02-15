unit UnitValidacion;

interface

uses
  StrUtils;

type
  TFecha = array[1..3] of integer;

function EsNum(Cad: string): boolean;
function EsCadenaFecha(Cad: string): boolean;
function EsFecha(Anyo, Mes, Dia: integer): boolean;
function EsAnioBisiesto(Anyo: integer): boolean;
function EsEMail(Cad: string): boolean;

implementation

function EsNum(Cad: string): boolean;
const
  Digitos = ['0'..'9'];
var
  i: integer;
begin
  EsNum := True;
  i := 0;
  if Length(Cad) < 1 then
    EsNum := False
  else
  begin
    while (i < Length(Cad)) and EsNum do
    begin
      Inc(i);
      if not (Cad[i] in Digitos) then EsNum := False;
    end;
  end;
end;

function EsCadenaFecha(Cad: string): boolean;
var
  i: byte;
  Fecha: string;
  VFecha: TFecha;    //(día,mes,año)
begin
  if WordCount(Cad, ['/']) = 3 then
  begin
    for i := 1 to 3 do
    begin
      {Extrae una subCadena, separada por '/', y la almacena en 'Fecha'}
      Fecha := ExtractDelimited(i, Cad, ['/']);
      {Si Fecha es un número, lo almacena en el vector, de otro modo
      establece un valor no válido}
      if EsNum(Fecha) then Val(Fecha, VFecha[i])
      else
        VFecha[i] := -1;
    end;
    EsCadenaFecha := EsFecha(VFecha[3], VFecha[2], VFecha[1]);
  end
  else
    EsCadenaFecha := False;
end;

function EsFecha(Anyo, Mes, Dia: integer): boolean;
const
  Meses = [1..12];
begin
  EsFecha := False;
  if (Anyo > 0) and (Mes in Meses) and (Dia > 0) then
    case Mes of
      {Meses con 31 días}
      1, 3, 5, 7, 8, 10, 12:
        if (Dia <= 31) then EsFecha := True;
      {Meses con 30 días}
      4, 6, 9, 11:
        if (Dia <= 30) then EsFecha := True;
      {Mes con 29 días si el año es bisiesto y 28 si no}
      2:
        if EsAnioBisiesto(Anyo) then
        begin
          if (Dia <= 29) then EsFecha := True;
        end
        else
        begin
          if (Dia <= 28) then EsFecha := True;
        end;
    end;
end;

function EsAnioBisiesto(Anyo: integer): boolean;
begin
  if (Anyo mod 4 = 0) and (not (Anyo mod 100 = 0) or (Anyo mod 400 = 0)) then
    EsAnioBisiesto := True
  else
    EsAnioBisiesto := False;
end;

function EsEMail(Cad: string): boolean;
var
  PosCad: word;
  Dom: string;
begin
  EsEMail := True;
  PosCad := 0;
  PosCad := Pos('@', Cad);
  if PosCad = 0 then
    EsEMail := False
  else
  begin
    Dom := LowerCase(Copy(Cad, PosCad + 1, Length(Cad) - PosCad));
    if not ((Dom = 'gmail.com') or (Dom = 'yahoo.com') or
      (Dom = 'yahoo.com.ar') or (Dom = 'hotmail.com') or
      (Dom = 'hotmail.com.ar') or (Dom = 'live.com') or (Dom = 'live.com.ar')) then
      EsEMail := False;
  end;
end;

end.
