unit UnitManejoFecha;

interface

uses
  crt, SysUtils, UnitValidacion;

function ObtenerFechaStr: string;
procedure CadARegFecha(Fecha: string; var Dia: word; var Mes: word; var Anio: word);
function FormatoFecha(Dia, Mes, Anio: word): string;
procedure NuevaFechaAXDias(Dia, Mes, Anio: word; CantDias: word; var XDia: word; var XMes: word; var XAnio: word);
function EsFechaPosterior(Dia0, Mes0, Anio0: word; Dia1, Mes1, Anio1: word): boolean;
function EsFechaAnterior(Dia0, Mes0, Anio0: word; Dia1, Mes1, Anio1: word): boolean;

implementation

function ObtenerFechaStr: string;
var
  Fecha: string[10];  // Formato DD/MM/AAAA
  Car: char;
  PosX: word;
begin
  PosX := WhereX;
  TextColor(DarkGray);
  Write('DD/MM/AAAA');
  TextColor(White);
  GotoXY(PosX, WhereY);
  Fecha := '';

  while not (EsCadenaFecha(Fecha)) do
  begin
    // Inicializa Car en NULL
    Car := #00;

    // Mientras no se precione Enter
    while Car <> #13 do
    begin
      Car := ReadKey;

      // Si se pulsa retroceso, se elimina el último caracter
      if Car = #08 then
      begin
        Delete(Fecha, Length(Fecha), 1);
        // Elimina la '/', o el número escrito anteriormente, si es necesario
        if (Length(Fecha) = 3) or (Length(Fecha) = 6) or (Length(Fecha) = 2) or (Length(Fecha) = 5) then
          Delete(Fecha, Length(Fecha), 1);
      end
      else
      // Si el caracter ingresado es un número decimal
      if (#48 <= Car) and (Car <= #57) then
        if Length(Fecha) < 10 then
        begin
          // Agrega '/' en las posiciones 3 y 6 de la string, DD[/]MM[/]AAAA
          //                                                     3    6
          if (Length(Fecha) = 2) or (Length(Fecha) = 5) then
            Fecha := Fecha + '/';
          Fecha := Fecha + Car;
          if (Length(Fecha) = 2) or (Length(Fecha) = 5) then
            Fecha := Fecha + '/';
        end;

      // Muestra lo que se está escribiendo
      GotoXY(PosX, WhereY);
      ClrEol;
      Write(Fecha);

      // Muestra el formato de la fecha a ingresar
      if Length(Fecha) = 0 then
      begin
        TextColor(DarkGray);
        Write('DD/MM/AAAA');
        TextColor(White);
        GotoXY(PosX, WhereY);
      end;
    end;

    // Muestra si la fecha ingresada no es válida
    if not (EsCadenaFecha(Fecha)) then
    begin
      GotoXY(PosX, WhereY);
      ClrEol;
      TextColor(Red);
      Write(Fecha);
      Write(UTF8Decode('    ¡La fecha ingresada no es válida!'));
      TextColor(White);
    end;
  end;
  WriteLn;
  ObtenerFechaStr := Fecha;
end;

procedure CadARegFecha(Fecha: string; var Dia: word; var Mes: word; var Anio: word);
begin
  // Formato de fecha: DD/MM/AAAA
  Val(Copy(Fecha, 1, 2), Dia);
  Val(Copy(Fecha, 4, 2), Mes);
  Val(Copy(Fecha, 7), Anio);
end;

function FormatoFecha(Dia, Mes, Anio: word): string;
var
  DiaAux, MesAux: String[2];
begin
  DiaAux := IntToStr(Dia);
  if Length(DiaAux) < 2 then
    DiaAux := '0' + DiaAux;
  
  MesAux := IntToStr(Mes);
  if Length(MesAux) < 2 then
    MesAux := '0' + MesAux; 
  
  FormatoFecha := DiaAux + '/' + MesAux + '/' + IntToStr(Anio);
  //FormatoFecha := Format('%0.2d', [Dia]) + '/' + Format('%0.2d', [Mes]) + '/' + IntToStr(Anio);
end;

function MaxDiasMes(Mes, Anio: word): word;
begin
  MaxDiasMes := 0;
  case Mes of
    {Meses con 31 días}
    1, 3, 5, 7, 8, 10, 12: MaxDiasMes := 31;
    {Meses con 30 días}
    4, 6, 9, 11: MaxDiasMes := 30;
    {Mes con 29 días si el año es bisiesto y 28 si no}
    2:
      if EsAnioBisiesto(Anio) then
        MaxDiasMes := 29
      else
        MaxDiasMes := 28;
  end;
end;

procedure NuevaFechaAXDias(Dia, Mes, Anio: word; CantDias: word; var XDia: word; var XMes: word; var XAnio: word);
begin
  XDia := Dia + CantDias;
  XMes := Mes;
  XAnio := Anio;
  while XDia > MaxDiasMes(XMes, XAnio) do
  begin
    XDia := XDia - MaxDiasMes(XMes, XAnio);
    if XMes <> 12 then
      Inc(XMes)
    else
    begin
      Inc(XAnio);
      XMes := 1;
    end;
  end;
end;

function EsFechaPosterior(Dia0, Mes0, Anio0: word; Dia1, Mes1, Anio1: word): boolean;
begin
  EsFechaPosterior := False;
  if Anio0 > Anio1 then
    EsFechaPosterior := True
  else
  if (Anio0 = Anio1) and (Mes0 > Mes1) then
    EsFechaPosterior := True
  else
  if (Anio0 = Anio1) and (Mes0 = Mes1) and (Dia0 > Dia1) then
    EsFechaPosterior := True;
end;

function EsFechaAnterior(Dia0, Mes0, Anio0: word; Dia1, Mes1, Anio1: word): boolean;
begin
  EsFechaAnterior := False;
  if Anio0 < Anio1 then
    EsFechaAnterior := True
  else
  if (Anio0 = Anio1) and (Mes0 < Mes1) then
    EsFechaAnterior := True
  else
  if (Anio0 = Anio1) and (Mes0 = Mes1) and (Dia0 < Dia1) then
    EsFechaAnterior := True;
end;

end.
