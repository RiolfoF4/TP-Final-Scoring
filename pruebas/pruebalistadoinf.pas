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
  FechaInicio, FechaFin: TRegFecha;
  i: Word;

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
  end else
    WriteLn(UTF8Decode(Infraccion));
end;

procedure SeparadorEncabezado(Encabezados: TVectorEncab; EncabTotales: Byte);
var
  i, j: word;
begin
  for i := 1 to EncabTotales do
  begin
    Write('+');
    for j := 1 to Length(UTF8Decode(Encabezados[i])) do
      Write('=');
  end;
  WriteLn('+');
end;

procedure MostrarEncabezado(Encabezados: TVectorEncab; EncabTotales: Byte);
var
  i: word;
begin
  SeparadorEncabezado(Encabezados, EncabTotales);

  for i := 1 to EncabTotales do
  begin
    Write('|');
    Write(UTF8Decode(Encabezados[i]));
  end;
  WriteLn('|');

  SeparadorEncabezado(Encabezados, EncabTotales);
end;

procedure SeparadorColumnas(PosSep: TVectorInt; EncabTotales: Byte);
var
  i: Word;
begin
  Write('|');
  for i := 1 to EncabTotales do
  begin
    GotoXY(PosSep[i], WhereY);
    Write('|');
  end;

  WriteLn;
end;

procedure SeparadorLineas(PosSep: TVectorInt; EncabTotales: Word);
var
  i: word;
begin
  Write('+');

  while WhereX < PosSep[EncabTotales] do
  begin
    Write('-');
    for i := 1 to EncabTotales do
      if WhereX = PosSep[i] then
        Write('+');
  end;

  WriteLn;
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

  MostrarEncabezado(Encabezados, EncabTotalesInf);
  for i := 1 to TamanioLista(ListaInf) do
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
        SeparadorColumnas(PosSep, EncabTotalesInf);
      end;
      SeparadorLineas(PosSep);
    end;
  end;
end;

procedure InicializarListaInf(var ArchInf: TArchInf; var ListaInf: TListaDatosInf; Inicio, Fin: TRegFecha);
var
  Inf: TDatoInfracciones;
begin
  Seek(ArchInf, 0);
  if FileSize(ArchInf) > 0 then
  begin
    Read(ArchInf, Inf);
    // Mientras que la fecha de la infracción sea anterior a la fecha de inicio, o no sea fin de archivo, 
    // lee la siguiente infracción
    while EsFechaAnterior(Inf.Fecha.Dia, Inf.Fecha.Mes, Inf.Fecha.Anio, Inicio.Dia, Inicio.Mes, Inicio.Anio) and not EOF(ArchInf) do
      Read(ArchInf, Inf);
      
    // Si la última fecha leída es posterior o igual a la fecha de inicio
    if not EsFechaAnterior(Inf.Fecha.Dia, Inf.Fecha.Mes, Inf.Fecha.Anio, Inicio.Dia, Inicio.Mes, Inicio.Anio) then
    begin
      Seek(ArchInf, FilePos(ArchInf) - 1);
      // Mientras que la fecha de la infracción sea anterior o igual (NO posterior) a la fecha de fin, 
      // o no sea fin de archivo, lee la siguiente infracción
      repeat
        Read(ArchInf, Inf);
        if not (EsFechaPosterior(Inf.Fecha.Dia, Inf.Fecha.Mes, Inf.Fecha.Anio, Fin.Dia, Fin.Mes, Fin.Anio) or
          ListaLlena(ListaInf)) then
          Agregar(ListaInf, Inf);
      until EsFechaPosterior(Inf.Fecha.Dia, Inf.Fecha.Mes, Inf.Fecha.Anio, Fin.Dia, Fin.Mes, Fin.Anio) or EOF(ArchInf);
    end;
  end;
end;

begin
  Assign(ArchInf, Ruta);
  Reset(ArchInf);
  CrearLista(L);

  with FechaInicio do
  begin
    Dia := 1;
    Mes := 2;
    Anio := 2024;
  end;
  with FechaFin do
  begin
    Dia := 1;
    Mes := 3;
    Anio := 2024;
  end;

  InicializarListaInf(ArchInf, L, FechaInicio, FechaFin);

  {while not (EOF(ArchInf)) do
  begin
    Read(ArchInf, Inf);
    if not ListaLlena(L) then
      Agregar(L, Inf);
  end;}
  
  for i := 1 to EncabTotalesInf do
    Encab[i] := EncabezadosInf[i];

  if not ListaVacia(L) then
    MostrarListadoInf(Encab, L)
  else
    WriteLn('No se encontraron infracciones en el periodo indicado!');
  
end.
