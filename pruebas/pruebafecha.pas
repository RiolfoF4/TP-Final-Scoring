program PruebaFecha;

uses
  UnitManejoFecha;

var
  FechaStr1, FechaStr2: String;
  Anio0, Mes0, Dia0: Word;
  XAnio, XMes, XDia: Word;
  CantDias: Word;
begin
  repeat
  FechaStr1 := ObtenerFechaStr();
  CadARegFecha(FechaStr1, Dia0, Mes0, Anio0);
  WriteLn('Fecha1: ', FormatoFecha(Dia0, Mes0, Anio0));
  FechaStr2 := ObtenerFechaStr();
  CadARegFecha(FechaStr2, XDia, XMes, XAnio);
  WriteLn('Fecha2: ', FormatoFecha(XDia, XMes, XAnio));
  if EsFechaPosterior(Dia0, Mes0, Anio0, XDia, XMes, XAnio) then
    WriteLn('Apa, funca')
  else
    WriteLn('Nose che');
  until FechaStr1 = '11/11/1111';
end.