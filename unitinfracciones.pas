unit UnitInfracciones;

interface

uses
  crt, sysutils, Math, UnitValidacion, UnitArchivo, UnitPila, UnitObtenerDatos, UnitManejoFecha, UnitLista, UnitTypes;

procedure AltaInfraccion(var DatosCon: TDatoConductores; var ArchInf: TArchInf);
procedure ConsultaInfraccion(var DatosCon: TDatoConductores; var ArchInf: TArchInf);


implementation
procedure InicializarListaInf(var Lista: TListaInf; var ArchListaInf: TArchListInf);
var
  x: String;
begin
  while not (EOF(ArchListaInf)) do
  begin
    ReadLn(ArchListaInf, x);
    if (x <> '') and (Pos('|', x) <> 0) and (not ListaLlena(Lista)) then
      Agregar(Lista, x);
  end;
  Reset(ArchListaInf);
end;

function PuntosInfraccion(Infraccion: String): Integer;
var
  SeparadorPuntos: Word;
begin
  // Los puntos están separados por '{Infraccion}.|Puntos', sin comillas ni espacios
  SeparadorPuntos := Pos('|', Infraccion);
  if SeparadorPuntos > 0 then
    Val(Copy(Infraccion, SeparadorPuntos+1), PuntosInfraccion)
  else
    PuntosInfraccion := -1;
end;

function InfraccionValida(NumeroInfrac: String; var ListaInfracciones: TListaInf): Boolean;
var
  Num: Integer;
begin
  InfraccionValida := False;
  if EsNum(NumeroInfrac) then
  begin
    Val(NumeroInfrac, Num);
    if (1 <= Num) and (Num <= TamanioLista(ListaInfracciones)) then
      InfraccionValida := True;
  end;
end;

function UltimoEspacioEnLinea(Texto: String): Integer;
var
  i: Word;
begin
  // WindMaxX representa el margen derecho y WindMinX el margen izquierdo
  i := WindMaxX - WindMinX;
  while (Texto[i] <> ' ') and (i > 0) do
    Dec(i);
  if i <> 0 then
    UltimoEspacioEnLinea := i
  else
    UltimoEspacioEnLinea := -1;
end;

procedure MostrarInfraccion(Infraccion: String);
var
  UltimoEspacio: Integer;
begin
  // Remueve los puntos de la infracción, si los hay
  if Pos('|', Infraccion) > 0 then
    Infraccion := Copy(Infraccion, 1, Pos('|', Infraccion)-1);

  // Si el texto excede el largo de un línea
  if Length(Utf8ToAnsi(Infraccion)) > (WindMaxX - WindMinX) then
  begin
    // Muestra el texto hasta el último espacio de la línea
    UltimoEspacio := UltimoEspacioEnLinea(Infraccion);
    WriteLn(UTF8Decode(Copy(Infraccion, 1, UltimoEspacio)));

    // Llama recursivamente al procedimiento con el resto del texto
    MostrarInfraccion(Copy(Infraccion, UltimoEspacio + 1));
  end
  else
    WriteLn(UTF8Decode(Infraccion));
end;

function MostrarListaInfracciones(var ListaInf: TListaInf): ShortString;
const
  LimiteInferior = 16;
var
  PosAnterior: TPila;
  i, Anterior: Byte;
  Tecl: String[2];
  Infraccion: ShortString;
begin
  // Inicialización
  CrearPila(PosAnterior);
  i := 1;
  Anterior := 1;
  Tecl := '';

  while (LowerCase(Tecl) <> 'q') and not (InfraccionValida(Tecl, ListaInf)) do
  begin
    // Si no se llegó al final de la lista, muestra secuencialmente las infracciones
    if i <= TamanioLista(ListaInf) then
    begin
      Recuperar(ListaInf, i, Infraccion);
      MostrarInfraccion('[' + IntToStr(i) + '] ' + Infraccion);
      WriteLn;
      Inc(i);
    end;

    // Recibe una entrada del usuario si el texto supera un límite inferior
    // o supera el final de la lista
    if (WhereY > LimiteInferior) or (i > TamanioLista(ListaInf)) then
    begin
      WriteLn('[S] iguiente.');
      WriteLn('[A] nterior.');
      WriteLn('[Q] Salir.');
      WriteLn;
      Write(UTF8Decode('Opción: '));
      ReadLn(Tecl);
      // s: Siguiente
      // a: Anterior
      case LowerCase(Tecl) of
        's':
          // Si NO se llegó al final de la lista, apila el índice de la infracción que se muestra actualmente
          // Si se llegó el final de la lista, muestra lo mismo
          if not (i > TamanioLista(ListaInf)) then
            Apilar(PosAnterior, Anterior)
          else
            i := Anterior;
        'a': 
          // Si la pila contiene algún índice, lo desapila y lo guarda en el índice de la lista 'i'
          // Si la pila NO contiene ningún índice, se encuentra en la primera "página", y establece el índice de la
          // lista nuevamente en la posición 0
          if not (PilaVacia(PosAnterior)) then
            Desapilar(PosAnterior, i)
          else
            i := 1;
      else
        // Si la tecla no es 's' ni 'a', muestra lo mismo
        i := Anterior;
      end;
      Anterior := i;
      ClrScr;
    end;
  end;

  // Devolver la infraccion seleccionada, o una string vacía si selecciona 'Salir'
  if InfraccionValida(Tecl, ListaInf) then
    Recuperar(ListaInf, StrToInt(Tecl), MostrarListaInfracciones)
  else
    MostrarListaInfracciones := '';
end;

procedure ModificarTipoInfraccion(var Infraccion: TDatoInfracciones; var ListaInf: TListaInf);
var
  InfAux: ShortString;
begin
  InfAux := MostrarListaInfracciones(ListaInf);
  if InfAux <> '' then
  begin
    Infraccion.Tipo := InfAux;
    Infraccion.Puntos := PuntosInfraccion(Infraccion.Tipo);   
  end;
end;

procedure DesplazarDerecha(var ArchInf: TArchInf; Pos: Word);
var
  i: Word;  
  xAux: TDatoInfracciones;
begin
  for i := FileSize(ArchInf) - 1 downto Pos do
  begin
    Seek(ArchInf, i);
    Read(ArchInf, xAux);
    Write(ArchInf, xAux);
  end;
end;

procedure AgregarInfraccion(Infraccion: TDatoInfracciones; var ArchInf: TArchInf);
var
  Pos: Word;
  xAux: TDatoInfracciones;
begin
  Seek(ArchInf, 0);

  // Si es la primer infracción que se ingresa, guardarla directamente
  if FileSize(ArchInf) = 0 then
    Write(ArchInf, Infraccion)
  else
  begin
    // Si no, recorrer el archivo hasta encontrar una fecha que sea posterior a la ingresada,
    // o al llegar al final del archivo
    repeat
      Pos := FilePos(ArchInf);
      if not (EOF(ArchInf)) then
        Read(ArchInf, xAux);
    until (
        EsFechaPosterior(xAux.Fecha.Dia, xAux.Fecha.Mes, xAux.Fecha.Anio, 
        Infraccion.Fecha.Dia, Infraccion.Fecha.Mes, Infraccion.Fecha.Anio) 
        or (Pos = FileSize(ArchInf))
      );

    // Si se llegó al final del archivo, agregar la infraccion
    if Pos = FileSize(ArchInf) then
    begin
      Seek(ArchInf, Pos);
      Write(ArchInf, Infraccion);
    end
    else
    begin
      // Desplaza hacia la derecha todas las infracciones a partir de Pos
      DesplazarDerecha(ArchInf, Pos);
      Seek(ArchInf, Pos);
      Write(ArchInf, Infraccion);
    end;
  end;
end;

procedure CalcularPlazoInhab(var DatosCon: TDatoConductores);
var
  Dias: Word;
  FechaActual: TRegFecha;
begin
  Inc(DatosCon.CantRein);
  // Calcula los días que el conductor queda inhabilitado
  if DatosCon.CantRein <= 3 then
    Dias := 60 + 60 * (DatosCon.CantRein - 1)
  else
    Dias := 180 * Round(IntPower(2, DatosCon.CantRein - 3));

  // Establece la fecha de habilitación a X Dias de la fecha actual
  ObtenerFechaActual(FechaActual);
  NuevaFechaAXDias(
    FechaActual.Dia, FechaActual.Mes, FechaActual.Anio, Dias, 
    DatosCon.FechaHab.Dia, DatosCon.FechaHab.Mes, DatosCon.FechaHab.Anio
    );
end;

procedure DescontarPuntos(var DatosCon: TDatoConductores; Puntos: ShortInt);
begin
  DatosCon.Scoring := DatosCon.Scoring - Puntos;
  if DatosCon.Scoring <= 0 then
  begin
    DatosCon.Scoring := 0;
    DatosCon.Habilitado := False;
    CalcularPlazoInhab(DatosCon);
  end;
end;

procedure MostrarDatosInf(Infraccion: TDatoInfracciones);
begin
  MostrarInfraccion('Infracción: ' + Infraccion.Tipo);
  WriteLn;
  WriteLn(UTF8Decode('Fecha de infracción: '), FormatoFecha(Infraccion.Fecha.Dia, Infraccion.Fecha.Mes, Infraccion.Fecha.Anio));
  WriteLn('Puntos: ', Infraccion.Puntos);
end;

procedure AltaInfraccion(var DatosCon: TDatoConductores; var ArchInf: TArchInf);
var
  Infraccion: TDatoInfracciones;
  ListaInf: TListaInf;
  ArchListaInf: TArchListInf;
  Op: String[2];
begin
  // Inicialización
  CrearAbrirArchivoListInf(ArchListaInf);
  CrearLista(ListaInf);
  InicializarListaInf(ListaInf, ArchListaInf);
  CerrarArchivoListInf(ArchListaInf);
  Infraccion.Tipo := MostrarListaInfracciones(ListaInf);

  if Infraccion.Tipo <> '' then
  begin
    Infraccion.DNI := DatosCon.DNI;
    ObtenerFechaActual(Infraccion.Fecha);
    Infraccion.Puntos := PuntosInfraccion(Infraccion.Tipo);
    repeat
      ClrScr;
      WriteLn('DNI: ', Infraccion.DNI);
      WriteLn('Apellido y Nombres: ', DatosCon.ApYNom);
      WriteLn;
      MostrarDatosInf(Infraccion);
      Write('Scoring: ', DatosCon.Scoring, ' ==> ');
      if DatosCon.Scoring - Infraccion.Puntos < 0 then
        WriteLn(0)
      else
        WriteLn(DatosCon.Scoring - Infraccion.Puntos);

      WriteLn;
      WriteLn('[1] Confirmar Alta.');
      WriteLn(UTF8Decode('[2] Modificar Infracción.'));
      WriteLn(UTF8Decode('[3] Modifiar Fecha de Infracción.'));
      WriteLn('[0] CANCELAR ALTA.');
      WriteLn;
      Op := ObtenerOpcion(Utf8ToAnsi('Opción: '), 0, 3);
      if not ((Op = '1') or (Op = '0')) then
        ClrScr;
      case Op of
        '1':
        begin
          AgregarInfraccion(Infraccion, ArchInf);
          DescontarPuntos(DatosCon, Infraccion.Puntos);
          TextColor(Green);
          WriteLn;
          WriteLn('Alta exitosa!');
          TextColor(White);
          Delay(1500);
        end;
        '2': ModificarTipoInfraccion(Infraccion, ListaInf);
        '3': ObtenerFechaInf(Infraccion.Fecha);
        '0':
        begin
          TextColor(Red);
          WriteLn;
          WriteLn('Alta cancelada!');
          TextColor(White);
          Delay(1500);
        end;
      end;
    until (Op = '1') or (Op = '0');
  end;
end;

procedure ObtenerInfraccionesCon(var ArchInf: TArchInf; DNICon: Cardinal; var ListaInf: TListaInf);
var
  InfAux: TDatoInfracciones;
  TipoInfAux: ShortString;
begin
  Seek(ArchInf, 0);
  while not (EOF(ArchInf)) do
  begin
    Read(ArchInf, InfAux);
    
    if InfAux.DNI = DNICon then
      with InfAux do
      begin
        TipoInfAux := Copy(Tipo, 1, Pos('|', Tipo) - 1) + #13#10 + FormatoFecha(Fecha.Dia, Fecha.Mes, Fecha.Anio) + Copy(Tipo, Pos('|', Tipo));
        Agregar(ListaInf, TipoInfAux);
      end;
  end;
end;

procedure ConsultaInfraccion(var DatosCon: TDatoConductores; var ArchInf: TArchInf);
var
  Op: String[2];
  InfAux: ShortString;
  DatosInf: TDatoInfracciones;
  ListaInf: TListaInf;
begin
  CrearLista(ListaInf);
  ObtenerInfraccionesCon(ArchInf, DatosCon.DNI, ListaInf);
  if not ListaVacia(ListaInf) then
  begin
    InfAux := MostrarListaInfracciones(ListaInf);
    DatosInf.Tipo := Copy(InfAux, 1, Pos(#13, InfAux));
    DatosInf.Puntos := PuntosInfraccion(InfAux);
    CadARegFecha(Copy(InfAux, Pos(#10, InfAux) + 1, 10), DatosInf.Fecha.Dia, DatosInf.Fecha.Mes, DatosInf.Fecha.Anio);
    DatosInf.DNI := DatosCon.DNI;
    WriteLn('DNI: ', DatosInf.DNI);
    WriteLn('Apellido y Nombres: ', DatosCon.ApYNom);
    WriteLn;
    MostrarDatosInf(DatosInf);
    ReadLn;
  end
  else
  begin
    TextColor(Red);
    WriteLn('El conductor no posee infracciones!');
    TextColor(White);
    Delay(1500);
  end;
end;
end.
