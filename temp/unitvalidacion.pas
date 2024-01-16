unit UnitValidacion;

interface
uses
    StrUtils;

type
  TFecha = array[1..3] of Integer;

function EsNum(Cad: String): Boolean;
function EsCadenaFecha(Cad: String): Boolean;
function EsFecha(Anyo, Mes, Dia: Integer): Boolean;
function EsAnioBisiesto(Anyo: Integer): Boolean;
function EsEMail(Cad: String): Boolean;

implementation
function EsNum(Cad: String): Boolean;
  const
    Digitos = ['0'..'9'];
  var
    i: Integer;
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

function EsCadenaFecha(Cad: String): Boolean;
  const
    Meses = [1..12];
  var
    i: Byte;
    Fecha: String;
    VFecha: TFecha;    //(Día, Mes, Año)
  begin
    EsCadenaFecha := False;
    if WordCount(Cad, ['/']) = 3 then
      for i := 1 to 3 do
      begin
      {Extrae una subCadena, separada por '/', y la almacena en 'Fecha'}
        Fecha := ExtractDelimited(i, Cad, ['/']);
      {Si Fecha es un número, lo almacena en el vector, de otro modo
      establece un valor no válido}
        if EsNum(Fecha) then Val(Fecha, VFecha[i]) else VFecha[i] := -1;
      end;
    if (VFecha[3] > 0) and (VFecha[2] in Meses) and (VFecha[1] > 0) then
      case VFecha[2] of
        {Meses con 31 días}
        1,3,5,7,8,10,12:
          if (VFecha[1] <= 31) then EsCadenaFecha := True;
        {Meses con 30 días}
        4,6,9,11:
          if (VFecha[1] <= 30) then EsCadenaFecha := True;
        {Mes con 29 días si el año es bisiesto y 28 si no}
        2:
          if EsAnioBisiesto(VFecha[3]) then
            if (VFecha[1] <= 29) then EsCadenaFecha := True
          else
            if (VFecha[1] <= 28) then EsCadenaFecha := True;
      end;
  end;

function EsFecha(Anyo, Mes, Dia: Integer): Boolean;
  const
    Meses = [1..12];
  begin
    if (Anyo > 0) and (Mes in Meses) and (Dia > 0) then
      case Mes of
        {Meses con 31 días}
        1,3,5,7,8,10,12:
          if (Dia <= 31) then EsFecha := True;
        {Meses con 30 días}
        4,6,9,11:
          if (Dia <= 30) then EsFecha := True;
        {Mes con 29 días si el año es bisiesto y 28 si no}
        2:
          if EsAnioBisiesto(Anyo) then
            if (Dia <= 29) then EsFecha := True
          else
            if (Dia <= 28) then EsFecha := True;
      end
    else
      EsFecha := False;
  end;

function EsAnioBisiesto(Anyo: Integer): Boolean;
  begin
    if ((Anyo mod 4) = 0) and (not((Anyo mod 100) = 0) or ((Anyo mod 400) = 0)) then
      EsAnioBisiesto := True
    else
      EsAnioBisiesto := False;
  end;

function EsEMail(Cad: String): Boolean;
  var
    PosCad: Word;
    Dom: String;
  begin
    EsEMail := True;
    PosCad := 0;
    PosCad := Pos('@', Cad);
    if PosCad = 0 then
      EsEMail := False
    else
    begin
      Dom := LowerCase(Copy(Cad, PosCad + 1, Length(Cad) - PosCad));
      if not ((Dom = 'gmail.com') or (Dom = 'yahoo.com') or (Dom = 'yahoo.com.ar') or (Dom = 'hotmail.com') or (Dom = 'hotmail.com.ar') or (Dom = 'live.com') or (Dom = 'live.com.ar'))
        then EsEMail := False;
    end;
  end;
end.

