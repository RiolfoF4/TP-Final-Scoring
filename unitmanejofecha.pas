unit UnitManejoFecha;

interface

uses
  crt, sysutils, UnitValidacion;

function ObtenerFechaStr: String;
procedure CadARegFecha(Fecha: String; var Dia: Word; var Mes: Word; var Anio: Word);
function FormatoFecha(Dia, Mes, Anio: Word): String;

implementation
function ObtenerFechaStr: String;
  var
    Fecha: String[10];  // Formato DD/MM/AAAA
    Car: Char;
    PosX: Word;
  begin
    PosX := WhereX;
    TextColor(DarkGray);
    Write('DD/MM/AAAA');
    TextColor(White);
    GotoXY(PosX,WhereY);
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
          // Elimina la '/', si es necesario
          if (Length(Fecha) = 3) or (Length(Fecha) = 6) then
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
          GotoXY(PosX,WhereY);
        end;
      end;

      // Muestra si la fecha ingresada no es válida
      if not (EsCadenaFecha(Fecha)) then
      begin
        GotoXY(PosX,WhereY);
        ClrEol;
        TextColor(Red);
        Write(Fecha);
        TextColor(White);
      end;
    end;
    WriteLn;
    ObtenerFechaStr := Fecha;
  end;

procedure CadARegFecha(Fecha: String; var Dia: Word; var Mes: Word; var Anio: Word);
  // Formato de fecha: DD/MM/AAAA
  begin
    Val(Copy(Fecha, 1, 2), Dia);
    Val(Copy(Fecha, 4, 2), Mes);
    Val(Copy(Fecha, 7), Anio);
  end;

function FormatoFecha(Dia, Mes, Anio: Word): String;
  begin
    FormatoFecha := Format('%0.2d', [Dia]) + '/' + Format('%0.2d', [Mes]) + '/' + IntToStr(Anio);
  end;
end.