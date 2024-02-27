program PruebaListadoInf;

uses
  crt, SysUtils, UnitArchivo, UnitPila, UnitTypes, UnitManejoFecha, UnitLista;

const
  Ruta = 'infracciones.dat';
  EncabTotalesInf = 4;
  EncabezadosInf: array[1..EncabTotalesInf] of ShortString = ('DNI', 'INFRACCIÓN', 'FECHA', 'PUNTOS');

type
  TVectorEncab = array[1..10] of shortstring;
  TVectorInt = array[1..10] of integer;

var
  ArchInf: TArchInf;
  Inf: TDatoInfracciones;
  L: TListaDatosInf;
  Encab: TVectorEncab;
  i: Word;


function UltimoEspacioEnLinea(Texto: string; MinX, MaxX: Word): integer;
var
  i: word;
begin
  i := MaxX - MinX;
  while (Texto[i] <> ' ') and (i > 0) do
    Dec(i);
  if i <> 0 then
    UltimoEspacioEnLinea := i
  else
    UltimoEspacioEnLinea := -1;
end;

procedure MostrarInfraccion(Infraccion: string; MinX, MaxX: Word);
var
  UltimoEspacio: integer;
begin
  // Remueve los puntos de la infracción, si los hay
  if Pos('|', Infraccion) > 0 then
    Infraccion := Copy(Infraccion, 1, Pos('|', Infraccion) - 1);

  GotoXY(MinX, WhereY);
  // Si el texto excede el largo de un línea
  if Length(Utf8ToAnsi(Infraccion)) > (MaxX - MinX) then
  begin
    // Muestra el texto hasta el último espacio de la línea
    UltimoEspacio := UltimoEspacioEnLinea(Infraccion, MinX, MaxX);

    // Mostrar aunque no quepa en la línea
    {if UltimoEspacio = -1 then
      UltimoEspacio := MaxX - MinX;}
    
    WriteLn(UTF8Decode(Copy(Infraccion, 1, UltimoEspacio)));

    // Llama recursivamente al procedimiento con el resto del texto
    MostrarInfraccion(Copy(Infraccion, UltimoEspacio + 1), MinX, MaxX);
  end
  else
    WriteLn(UTF8Decode(Infraccion));
end;

procedure SeparadorEncabezado(Encabezados: TVectorEncab);
var
  i, j: word;
begin
  for i := 1 to EncabTotalesInf do
  begin
    Write('+');
    for j := 1 to Length(UTF8Decode(Encabezados[i])) do
      Write('=');
  end;
  WriteLn('+');
end;

procedure MostrarEncabezado(Encabezados: TVectorEncab);
var
  i: word;
begin
  SeparadorEncabezado(Encabezados);

  for i := 1 to EncabTotalesInf do
  begin
    Write('|');
    Write(UTF8Decode(Encabezados[i]));
  end;
  WriteLn('|');

  SeparadorEncabezado(Encabezados);
end;

procedure SeparadorColumnas(PosSep: TVectorInt);
var
  i: Word;
begin
  Write('|');
  for i := 1 to EncabTotalesInf do
  begin
    GotoXY(PosSep[i], WhereY);
    Write('|');
  end;

  WriteLn;
end;

procedure SeparadorLineas(PosSep: TVectorInt);
var
  i: word;
begin
  Write('+');

  while WhereX < PosSep[EncabTotalesInf] do
  begin
    Write('-');
    for i := 1 to EncabTotalesInf do
      if WhereX = PosSep[i] then
        Write('+');
  end;

  WriteLn;
end;

procedure InicializarListadoInf(var Encabezados: TVectorEncab;
  var ListaInf: TListaDatosInf; var LenEncab: TVectorInt; var PosSep: TVectorInt);
var
  i: word;
  LenAux: TVectorInt;
begin
  LenAux[1] := 8;   // DNI 12.345.678
  LenAux[2] := 44;   // Tipo de Infracción
  LenAux[3] := 10;  // DD/MM/AAAA
  LenAux[4] := 2;   // Puntos

  for i := 1 to EncabTotalesInf do
    LenEncab[i] := LenAux[i];
{
  for i := 1 to TamanioLista(ListaCon) do
  begin
    // Determinar la longitud de la string más larga
    Recuperar(ListaCon, i, DatosCon);

    for j := 1 to EncabTotalesCon do
      if LenEncab[j] < LenAux[j] then
        LenEncab[j] := LenAux[j];
  end;
}
  for i := 1 to EncabTotalesInf do
  begin
    // Agregar espacios a cada lado del encabezado hasta que su longitud sea mayor
    // que la string más larga
    Encabezados[i] := ' ' + Encabezados[i] + ' ';
    while Length(UTF8Decode(Encabezados[i])) < LenEncab[i] + 3 do
      Encabezados[i] := ' ' + Encabezados[i] + ' ';
    LenEncab[i] := Length(UTF8Decode(Encabezados[i]));

    // Calcular la posición de los separadores '|'
    if i = 1 then
      PosSep[i] := LenEncab[i] + 2
    else
      PosSep[i] := PosSep[i - 1] + LenEncab[i] + 1;
  end;
end;

procedure MostrarListadoInf(Encabezados: TVectorEncab; var ListaInf: TListaDatosInf);
var
  CantInf: string[7];
  i, PosAnt: word;
  Aux, PosY: Word;
  OrdenAscendiente: Boolean;
  Tecl: string[2];
  DatosInf: TDatoInfracciones;
  LenEncab, PosSep: TVectorInt;
begin
  InicializarListadoInf(Encabezados, ListaInf, LenEncab, PosSep);
  OrdenAscendiente := True;
  i := 1;
  PosAnt := 1;
  Tecl := '';

  MostrarEncabezado(Encabezados);
  for i := 1 to 3 do
  begin
    Recuperar(ListaInf, i, DatosInf);
    PosY := WhereY;
    with DatosInf do
    begin
      GotoXY(2, PosY);
      Write(DNI: ((LenEncab[1] + Length(UIntToStr(DNI))) div 2));
      
      
      GotoXY(PosSep[2] + 1, PosY);
      Write(FormatoFecha(Fecha.Dia, Fecha.Mes, Fecha.Anio): ((LenEncab[3] + 10)) div 2);
      
      GotoXY(PosSep[3] + 1, PosY);
      Write(Puntos: (LenEncab[4] + Length(IntToStr(Puntos))) div 2);
      
      GotoXY(PosSep[4] + 1, PosY);

      GotoXY(PosSep[3] + 1, PosY);
      MostrarInfraccion(Tipo, PosSep[1] + 2, PosSep[2] - 2);
      for Aux := PosY to WhereY - 1 do
      begin
        GotoXY(1, Aux);
        SeparadorColumnas(PosSep);
      end;
      SeparadorLineas(PosSep);
    end;
  end;

end;

begin
  Assign(ArchInf, Ruta);
  Reset(ArchInf);
  CrearLista(L);
  
  while not (EOF(ArchInf)) do
  begin
    Read(ArchInf, Inf);
    if not ListaLlena(L) then
      Agregar(L, Inf);
  end;
  
  for i := 1 to EncabTotalesInf do
    Encab[i] := EncabezadosInf[i];

  MostrarListadoInf(Encab, L);
  
  ReadLn;

end.
