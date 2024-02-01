program PruebaFecha;

uses
  UnitManejoFecha;

var
  FechaStr: String;
  Anio, Mes, Dia: Word;
  XAnio, XMes, XDia: Word;
  CantDias: Word;
begin
  repeat
  FechaStr := ObtenerFechaStr();
  CadARegFecha(FechaStr, Dia, Mes, Anio);
  WriteLn('Fecha: ', FormatoFecha(Dia, Mes, Anio));
  Write('Dias: ');
  ReadLn(CantDias);
  NuevaFechaAXDias(Dia, Mes, Anio, CantDias, XDia, XMes, XAnio);
  WriteLn('Nueva Fecha: ', FormatoFecha(XDia, XMes, XAnio));
  ReadLn;
  until FechaStr = '11/11/1111';
end.