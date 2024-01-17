program prueba_fecha;

uses
  crt, sysutils, UnitValidacion;

type
  TRegFecha = record
    Dia, Mes: Byte;
    Anio: Word;
  end;

var
  Fecha: String[10];  // Formato DD/MM/AAAA
  RegFecha: TRegFecha;
  Car: Char;
  PosX, PosY: Word;

procedure CadARegFecha(Fecha: String; var RegFecha: TRegFecha);
  begin
    Val(Copy(Fecha, 1, 2), RegFecha.Dia);
    Val(Copy(Fecha, 4, 2), RegFecha.Mes);
    Val(Copy(Fecha, 7), RegFecha.Anio);
  end;

begin
  Fecha := '';
  TextColor(White);
  Write('Formato de Fecha: DD/MM/AAAA');
  GotoXY(19,3);
  while not (EsCadenaFecha(Fecha)) do
  begin
    // Inicializa Car en NULL
    Car := #00;

    // Mientras no se precione Enter
    while Car <> #13 do
    begin
      Car := ReadKey;
      Write(Car);
      // Si se pulsa el retroceso, se elimina el último caracter
      if Car = #08 then
        Delete(Fecha, Length(Fecha), 1)
      else
        // Si el caracter ingresado es un número decimal
        if (#48 <= Car) and (Car <= #57) then
          if Length(Fecha) < 10 then
          begin
            // Agrega '/' en las posiciones 3 y 6 de la string, DD[/]MM[/]AAAA
            //                                                     3    6
            if ((Length(Fecha) = 2) or (Length(Fecha) = 5)) and (Fecha[Length(Fecha)] <> '/') then
              Fecha := Fecha + '/';
            Fecha := Fecha + Car;
            if (Length(Fecha) = 2) or (Length(Fecha) = 5) then
              Fecha := Fecha + '/';
          end;
      // Muestra lo que se está escribiendo
      GotoXY(19,3);    // CAMBIAR
      ClrEol;
      Write(Fecha);

      PosX := WhereX; 
      PosY := WhereY;
    end;

    {TEMPORAL}
    if EsCadenaFecha(Fecha) then
    begin
      GotoXY(19, 5);
      ClrEol;
      TextColor(Green);
      WriteLn(UTF8Decode('La fecha ingresada es válida!'));
      TextColor(White);
      GotoXY(19, 6);  
      WriteLn('Fecha final: ', Fecha);
    end
    else
    begin
      GotoXY(19, 5);
      TextColor(Red);
      WriteLn(UTF8Decode('La fecha ingresada no es válida!'));
      TextColor(White);
      GotoXY(PosX, PosY);
    end;
    {~~~~~~~~}
  end;
  ReadLn;

  CadARegFecha(Fecha, RegFecha);
  WriteLn('Dia: ', RegFecha.Dia);
  WriteLn('Mes: ', RegFecha.Mes);
  WriteLn(UTF8Decode('Año: '), RegFecha.Anio);

  ReadLn;

  WriteLn(StrToDate(Fecha, '/'));
  ReadLn;

  if StrToDate(Fecha, '/') < StrToDate('10/10/2004', '/') then
    WriteLn('La fecha ingresada es anterior al 10/10/2004')
  else
    WriteLn('La fecha ingresada es posterior al 10/10/2004');
  ReadLn;
end.