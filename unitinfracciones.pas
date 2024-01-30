unit UnitInfracciones;

interface

uses
  crt, sysutils, UnitValidacion, UnitArchivo, UnitPila, UnitObtenerDatos, UnitManejoFecha, UnitLista;

procedure AltaInfraccion(var DatosCon: TDatoConductores; var ArchInf: TArchInf);

implementation
procedure InicializarListaInf(var Lista: TLista; var ArchListaInf: TArchListInf);
var
  x: String;
begin
  while not (EOF(ArchListaInf)) do
  begin
    ReadLn(ArchListaInf, x);
    if x <> '' then
      Agregar(Lista, x);
  end;
  Reset(ArchListaInf);
end;

function PuntosInfraccion(Infraccion: String): Integer;
var
  SeparadorPuntos: Word;
begin
  // Los puntos están separados por '{Infraccion}.\Puntos', sin comillas ni espacios
  SeparadorPuntos := Pos('\', Infraccion);
  if SeparadorPuntos > 0 then
    Val(Copy(Infraccion, SeparadorPuntos+1), PuntosInfraccion)
  else
    PuntosInfraccion := -1;
end;

function InfraccionValida(NumeroInfrac: String; var ListaInfracciones: TLista): Boolean;
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
  // WindMaxX representa el borde derecho y WindMinX el borde izquierdo
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
  SeparadorPuntos: Word;
begin
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
  begin
    // Muestra la infracción
    SeparadorPuntos := Pos('\', Infraccion);
    WriteLn(UTF8Decode(Copy(Infraccion, 1, SeparadorPuntos-1)));
  end;
end;

function ObtenerInfraccion: ShortString;
const
  LimiteInferior = 16;
var
  ArchListaInf: TArchListInf;
  ListaInf: TLista;
  PosAnterior: TPila;
  i, Anterior: Byte;
  Tecl: String[2];
  Infraccion: ShortString;

begin
  CrearAbrirArchivoListInf(ArchListaInf);
  CrearLista(ListaInf);
  InicializarListaInf(ListaInf, ArchListaInf);
  CrearPila(PosAnterior);

  i := 1;
  Anterior := 1;
  Tecl := '';

  while (LowerCase(Tecl) <> 'q') and not (InfraccionValida(Tecl, ListaInf)) do
  begin
    // Si no se llegó al final del archivo, muestra secuencialmente las infracciones
    if i <= TamanioLista(ListaInf) then
    begin
      Recuperar(ListaInf, i, Infraccion);
      MostrarInfraccion('[' + IntToStr(i) + '] ' + Infraccion);
      WriteLn;
      Inc(i);
    end;

    // Recibe una entrada del usuario si el texto supera un límite inferior
    // o se llega al final del archivo
    if (WhereY > LimiteInferior) or (i = TamanioLista(ListaInf)) then
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
          // Si NO se llegó al final del archivo, apila el índice de la infracción que se muestra actualmente
          // Si se llegó el final del archivo, muestra lo mismo
          if not (i = TamanioLista(ListaInf)) then
            Apilar(PosAnterior, Anterior)
          else
            i := Anterior;
        'a': 
          // Si la pila contiene algún índice, lo desapila y lo guarda en el índice del archivo 'i'
          // Si la pila NO contiene ningún índice, se encuentra en la primera "página", y establece el índice del
          // archivo nuevamente en la posición 0
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
    Recuperar(ListaInf, StrToInt(Tecl), ObtenerInfraccion)
  else
    ObtenerInfraccion := '';
  CerrarArchivoListInf(ArchListaInf);
end;

procedure ModificarTipoInfraccion(var Infraccion: TDatoInfracciones);
begin
  Infraccion.Tipo := ObtenerInfraccion;
  Infraccion.Puntos := PuntosInfraccion(Infraccion.Tipo);
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
  FechaInf, FechaAux: TDateTime;
begin
  Seek(ArchInf, 0);

  // Si es la primer infracción que se ingresa, cargarla directamente
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

      // Guarda las fechas en el formato de Pascal
      FechaInf := StrToDate(FormatoFecha(Infraccion.Fecha.Dia, Infraccion.Fecha.Mes, Infraccion.Fecha.Anio), '/');
      FechaAux := StrToDate(FormatoFecha(xAux.Fecha.Dia, xAux.Fecha.Mes, xAux.Fecha.Anio), '/');
    until (FechaInf < FechaAux) or (Pos = FileSize(ArchInf));

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

procedure MostrarInfracciones(var ArchInf: TArchInf);         // TEMP
var
  InfAux: TDatoInfracciones;
begin
  Seek(ArchInf, 0);
  while not (EOF(ArchInf)) do
  begin
    Read(ArchInf, InfAux);
    MostrarInfraccion('[' + IntToStr(FilePos(ArchInf)) + '] Infracción: ' + InfAux.Tipo);
    WriteLn('Fecha: ', FormatoFecha(InfAux.Fecha.Dia, InfAux.Fecha.Mes, InfAux.Fecha.Anio));
    WriteLn;
  end;
  ReadLn;
end;

procedure AltaInfraccion(var DatosCon: TDatoConductores; var ArchInf: TArchInf);
var
  Infraccion: TDatoInfracciones;
  Rta: String[2];
begin
  Infraccion.Tipo := ObtenerInfraccion;
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
      MostrarInfraccion('Infracción: ' + Infraccion.Tipo);
      WriteLn;
      WriteLn(UTF8Decode('Fecha de infracción: '), FormatoFecha(Infraccion.Fecha.Dia, Infraccion.Fecha.Mes, Infraccion.Fecha.Anio));
      WriteLn('Puntos a descontar: ', Infraccion.Puntos);
      WriteLn('Scoring: ', DatosCon.Scoring, ' ==> ', DatosCon.Scoring - Infraccion.Puntos);
      WriteLn;
      WriteLn('[1] Confirmar Alta.');
      WriteLn(UTF8Decode('[2] Modificar Infracción.'));
      WriteLn(UTF8Decode('[3] Modifiar Fecha de Infracción.'));
      WriteLn('[4] TEMP Mostrar Infracciones.');
      WriteLn('[0] Cancelar Alta.');
      WriteLn;
      Write(UTF8Decode('Opción: '));
      ReadLn(Rta);
      if (Rta <> '1') and (Rta <> '0') then
        ClrScr;
      case Rta of
        '1':
        begin
          AgregarInfraccion(Infraccion, ArchInf);
          TextColor(Green);
          WriteLn('Alta exitosa!');
          TextColor(White);
          Delay(1500);
        end;
        '2': ModificarTipoInfraccion(Infraccion);
        '3': ObtenerFechaInf(Infraccion.Fecha);
        '4': MostrarInfracciones(ArchInf);
        '0':
        begin
          TextColor(Red);
          WriteLn('Alta cancelada!');
          TextColor(White);
          Delay(1500);
        end;
      end;
    until (Rta = '1') or (Rta = '0');
  end;
end;
end.
