unit UnitInfracciones;

interface

uses
  crt, SysUtils, Math, UnitValidacion, UnitArchivo, UnitPila,
  UnitObtenerDatos, UnitManejoFecha, UnitLista, UnitTypes, UnitMostrarACP;

procedure AltaInfraccion(var DatosCon: TDatoConductores; var ArchInf: TArchInf);
procedure ConsultaInfraccion(var DatosCon: TDatoConductores; var ArchInf: TArchInf);
procedure MostrarInfraccion(Infraccion: string; MinX, MaxX: Word);

implementation
procedure InicializarListaInf(var Lista: TListaInf);
var
  ArchListaInf: TArchListInf;
  x: string;
begin
  CrearAbrirArchivoListInf(ArchListaInf);
  while not (EOF(ArchListaInf)) do
  begin
    ReadLn(ArchListaInf, x);
    if (x <> '') and (Pos('|', x) <> 0) and (not ListaLlena(Lista)) then
      Agregar(Lista, x);
  end;
  CerrarArchivoListInf(ArchListaInf);
end;

function FormatoTipoInfYFecha(Infraccion: TDatoInfracciones; PosInf: word): string;
var
  Sep: string;
begin
  Sep := ' ' + #13#10 + '    ';
  if PosInf >= 10 then
    Sep := Sep + ' ';
  with Infraccion do
    FormatoTipoInfYFecha := Tipo + Sep + FormatoFecha(Fecha.Dia, Fecha.Mes, Fecha.Anio);
end;

procedure InicializarListaTiposInf(var ListaDatosInf: TListaDatosInf;
  var ListaTiposInfCon: TListaInf);
var
  i: word;
  DatosInf: TDatoInfracciones;
begin
  for i := 1 to TamanioLista(ListaDatosInf) do
    with DatosInf do
    begin
      Recuperar(ListaDatosInf, i, DatosInf);
      Agregar(ListaTiposInfCon, FormatoTipoInfYFecha(DatosInf, i));
    end;
end;

function PuntosInfraccion(Infraccion: string): integer;
var
  SeparadorPuntos: word;
begin
  // Los puntos están separados por '{Infraccion}.|Puntos', sin comillas ni espacios
  SeparadorPuntos := Pos('|', Infraccion);
  if SeparadorPuntos > 0 then
    Val(Copy(Infraccion, SeparadorPuntos + 1), PuntosInfraccion)
  else
    PuntosInfraccion := -1;
end;

procedure QuitarSeparadorPuntos(var Infraccion: shortstring);
begin
  Infraccion := Copy(Infraccion, 1, Pos('|', Infraccion) - 1);
end;

function InfraccionValida(NumeroInfrac: string;
  var ListaInfracciones: TListaInf): boolean;
var
  Num: integer;
begin
  InfraccionValida := False;
  if EsNum(NumeroInfrac) then
  begin
    Val(NumeroInfrac, Num);
    if (1 <= Num) and (Num <= TamanioLista(ListaInfracciones)) then
      InfraccionValida := True;
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

function MostrarListaInfracciones(var ListaInf: TListaInf): integer;
const
  LimiteInferior = 12;
var
  PosAnterior: TPila;
  CantInf: string[7];
  i, Anterior: word;
  Tecl: string[2];
  Infraccion: shortstring;
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
      MostrarInfraccion('[' + IntToStr(i) + '] ' + Infraccion, 1, WindMaxX - WindMinX);
      WriteLn;
      Inc(i);
    end;

    // Recibe una entrada del usuario si el texto supera un límite inferior
    // o supera el final de la lista
    if (WhereY > LimiteInferior) or (i > TamanioLista(ListaInf)) then
    begin
      CantInf := IntToStr(i - 1) + '/' + IntToStr(TamanioLista(ListaInf));
      Write('[S] Siguiente.');
      WriteLn(CantInf: (WindMaxX - WindMinX - WhereX));
      WriteLn('[A] Anterior.');
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

  // Devolver la posición de la infraccion seleccionada, o -1 si selecciona 'Salir'
  if InfraccionValida(Tecl, ListaInf) then
    Val(Tecl, MostrarListaInfracciones)
  else
    MostrarListaInfracciones := -1;
end;

procedure MostrarInfraccionesDisponibles(var Infraccion: TDatoInfracciones);
var
  ListaInf: TListaInf;
  PosInf: integer;
begin
  // Muestra todas las infracciones cargadas en 'listado_infracciones.txt'
  // y devuelve la infracción selecciona junto con los puntos, ó una string vacía
  // si selecciona salir
  CrearLista(ListaInf);
  InicializarListaInf(ListaInf);
  PosInf := MostrarListaInfracciones(ListaInf);
  if PosInf <> -1 then
  begin
    Recuperar(ListaInf, PosInf, Infraccion.Tipo);
    Infraccion.Puntos := PuntosInfraccion(Infraccion.Tipo);
    QuitarSeparadorPuntos(Infraccion.Tipo);
  end
  else
    Infraccion.Tipo := '';
end;

procedure ModificarTipoInfraccion(var Infraccion: TDatoInfracciones);
var
  InfAux: TDatoInfracciones;
begin
  MostrarInfraccionesDisponibles(InfAux);
  if InfAux.Tipo <> '' then
  begin
    Infraccion.Tipo := InfAux.Tipo;
    Infraccion.Puntos := InfAux.Puntos;
  end;
end;

procedure DesplazarDerecha(var ArchInf: TArchInf; Pos: word);
var
  i: word;
  xAux: TDatoInfracciones;
begin
  // Deja 'vacio' el lugar de Pos
  for i := FileSize(ArchInf) - 1 downto Pos do
  begin
    Seek(ArchInf, i);
    Read(ArchInf, xAux);
    Write(ArchInf, xAux);
  end;
end;

procedure Eliminar(var ArchInf: TArchInf; Pos: word);
var
  i: word;
  xAux: TDatoInfracciones;
begin
  // Pisa el lugar de Pos
  if Pos < FileSize(ArchInf) - 1 then
  begin
    for i := Pos + 1 to FileSize(ArchInf) - 1 do
    begin
      Seek(ArchInf, i);
      Read(ArchInf, xAux);
      Seek(ArchInf, i - 1);
      Write(ArchInf, xAux);
    end
  end;
  Seek((ArchInf), FileSize(ArchInf) - 1);
  Truncate(ArchInf);
end;

procedure AgregarInfraccion(Infraccion: TDatoInfracciones; var ArchInf: TArchInf);
var
  Pos: word;
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
    until (EsFechaPosterior(xAux.Fecha.Dia, xAux.Fecha.Mes,
        xAux.Fecha.Anio, Infraccion.Fecha.Dia, Infraccion.Fecha.Mes,
        Infraccion.Fecha.Anio) or (Pos = FileSize(ArchInf)));

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
  Dias: word;
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

procedure DescontarPuntos(var DatosCon: TDatoConductores; Puntos: shortint);
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
  MostrarInfraccion('Infracción: ' + Infraccion.Tipo, 1, WindMaxX - WindMinX);
  WriteLn;
  WriteLn(UTF8Decode('Fecha de infracción: '),
    FormatoFecha(Infraccion.Fecha.Dia, Infraccion.Fecha.Mes, Infraccion.Fecha.Anio));
  WriteLn('Puntos: ', Infraccion.Puntos);
end;

procedure AltaInfraccion(var DatosCon: TDatoConductores; var ArchInf: TArchInf);
var
  Infraccion: TDatoInfracciones;
  Op: string[2];
begin
  MostrarInfraccionesDisponibles(Infraccion);

  if Infraccion.Tipo <> '' then
  begin
    // Carga los datos inciales de la infracción
    Infraccion.DNI := DatosCon.DNI;
    ObtenerFechaActual(Infraccion.Fecha);
    {Infraccion.Puntos := PuntosInfraccion(Infraccion.Tipo);}

    repeat
      ClrScr;
      WriteLn('DNI: ', Infraccion.DNI);
      MostrarLn('Apellido y Nombres: ', DatosCon.ApYNom);
      WriteLn;
      MostrarDatosInf(Infraccion);
      Write('Scoring: ', DatosCon.Scoring, ' --> ');
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
      WriteLn(UTF8Decode(Copy(Infraccion.Tipo, 1, Pos('|', infraccion.Tipo) - 1)));
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
          WriteLn(UTF8Decode('¡Alta exitosa!'));
          TextColor(White);
          Delay(1500);
        end;
        '2': ModificarTipoInfraccion(Infraccion);
        '3': ObtenerFechaInf(Infraccion.Fecha);
        '0':
        begin
          TextColor(Red);
          WriteLn;
          WriteLn(UTF8Decode('¡Alta cancelada!'));
          TextColor(White);
          Delay(1500);
        end;
      end;
    until (Op = '1') or (Op = '0');
  end;
end;

procedure ObtenerInfraccionesCon(var ArchInf: TArchInf; DNICon: cardinal;
  var ListaDatosInf: TListaDatosInf);
var
  InfAux: TDatoInfracciones;
begin
  Seek(ArchInf, 0);
  while not (EOF(ArchInf)) do
  begin
    Read(ArchInf, InfAux);
    if (InfAux.DNI = DNICon) and not (ListaLlena(ListaDatosInf)) then
      Agregar(ListaDatosInf, InfAux);
  end;
end;

procedure MostrarModifInf(InfraccionOrig, InfraccionMod: TDatoInfracciones);
const
  f = ' --> ';
var
  FechaOrigAux, FechaModAux: string[10];
  {ScoringAux: integer;}
begin
  {if InfraccionOrig.Tipo <> InfraccionMod.Tipo then
  begin
    MostrarInfraccion('Infracción Anterior: ' + InfraccionOrig.Tipo);
    WriteLn;
    MostrarInfraccion('Infracción Nueva: ' + InfraccionMod.Tipo);
    WriteLn;
    WriteLn('Puntos a Descontar: ', InfraccionOrig.Puntos, f, InfraccionMod.Puntos);

    ScoringAux := (DatosCon.Scoring + InfraccionOrig.Puntos) - InfraccionMod.Puntos;
    WriteLn;
    Write('Scoring del Conductor: ', DatosCon.Scoring, f);
    if ScoringAux < 0 then
      WriteLn(0)
    else
      WriteLn(ScoringAux);
  end;}
  with InfraccionOrig.Fecha do
    FechaOrigAux := FormatoFecha(Dia, Mes, Anio);
  with InfraccionMod.Fecha do
    FechaModAux := FormatoFecha(Dia, Mes, Anio);
  if FechaOrigAux <> FechaModAux then
    WriteLn(UTF8Decode('Fecha de Infracción: '), FechaOrigAux, f, FechaModAux);
end;

{ SIN USO
procedure ActualizarInfraccion(var ArchInf: TArchInf; NuevaInf: TDatoInfracciones;
  PosLista: word);
var
  InfAux: TDatoInfracciones;
  PosAux: Word;
begin
  Seek(ArchInf, 0);
  PosAux := 0;
  while (PosAux <> PosLista) and not (EOF(ArchInf)) do
  begin
    Read(ArchInf, InfAux);
    if InfAux.DNI = NuevaInf.DNI then
    begin
      Inc(PosAux);
      if PosAux = PosLista then
      begin
        Eliminar(ArchInf, FilePos(ArchInf) - 1);
        AgregarInfraccion(NuevaInf, ArchInf);
      end;
    end;
  end;
end;
}

procedure ActualizarInfracciones(var ArchInf: TArchInf; DNICon: Cardinal; ListaInf: TListaDatosInf);
var
  InfAux: TDatoInfracciones;
  Pos, i: Word;
begin
  Seek(ArchInf, 0);
  while not (EOF(ArchInf)) do
  begin
    Pos := FilePos(ArchInf);
    Read(ArchInf, InfAux);
    if InfAux.DNI = DNICon then
    begin
      Eliminar(ArchInf, Pos);
      Seek(ArchInf, Pos);
    end;
  end;
  for i := 1 to TamanioLista(ListaInf) do
  begin
    Recuperar(ListaInf, i, InfAux);
    AgregarInfraccion(InfAux, ArchInf);
  end;
end;

procedure ConsultaInfraccion(var DatosCon: TDatoConductores; var ArchInf: TArchInf);
var
  Op: string[2];
  PosInf: integer;
  ModificaDatos: boolean;
  DatosInf, DatosInfAux: TDatoInfracciones;

  // Lista de las infracciones del conductor
  ListaInfCon: TListaDatosInf;
  // Lista de los tipos de infracciones del conductor, junto con la fecha
  ListaTiposInfCon: TListaInf;
begin
  // Guardar las infracciones del conductor en una lista
  CrearLista(ListaInfCon);
  ObtenerInfraccionesCon(ArchInf, DatosCon.DNI, ListaInfCon);

  if not ListaVacia(ListaInfCon) then
  begin
    // Inicializa una lista con los tipos de infracciones y la fecha
    CrearLista(ListaTiposInfCon);
    InicializarListaTiposInf(ListaInfCon, ListaTiposInfCon);

    ModificaDatos := False;
    repeat
      TextColor(White);
      ClrScr;
      // Obtiene la infracción
      PosInf := MostrarListaInfracciones(ListaTiposInfCon);
      if PosInf <> -1 then
      begin
        Recuperar(ListaInfCon, PosInf, DatosInf);
        DatosInfAux := DatosInf;

        repeat
          // Muestra los datos de la infracción
          WriteLn('DNI: ', DatosInf.DNI);
          MostrarLn('Apellido y Nombres: ', DatosCon.ApYNom);
          WriteLn;
          MostrarDatosInf(DatosInfAux);
          WriteLn;
          WriteLn(UTF8Decode('[1] Modificar Fecha de Infracción.'));
          WriteLn('[0] Volver.');
          WriteLn;
          Op := ObtenerOpcion(Utf8ToAnsi('Opción: '), 0, 1);
          ClrScr;

          if Op = '1' then
          begin
            ObtenerFechaInf(DatosInfAux.Fecha);
            if (DatosInfAux.Fecha.Anio <> DatosInf.Fecha.Anio) or
                (DatosInfAux.Fecha.Mes <> DatosInf.Fecha.Mes) or
                (DatosInfAux.Fecha.Dia <> DatosInf.Fecha.Dia) then
              ModificaDatos := True;
          end;
          ClrScr;
        until Op = '0';

        if ModificaDatos then
        begin
          // Si modifica algún dato, muestra el dato original y el dato modificado
          TextColor(Red);
          WriteLn(UTF8Decode('¡Atención!'));
          TextColor(White);
          WriteLn;
          WriteLn('Conductor:');
          WriteLn('       DNI: ', DatosInf.DNI);
          MostrarLn('       Apellido y Nombres: ', DatosCon.ApYNom);
          WriteLn;
          WriteLn(UTF8Decode('Se modificarán los siguientes datos:'));
          WriteLn;
          MostrarInfraccion('Infracción: ' + DatosInfAux.Tipo, 1, WindMaxX - WindMinX);
          WriteLn;
          MostrarModifInf(DatosInf, DatosInfAux);
          WriteLn;
          Write(UTF8Decode('¿Desea guardar los cambios? (S/N): '));
          if ObtenerRtaSN = 's' then
          begin
            Modificar(ListaInfCon, PosInf, DatosInfAux);
            Modificar(ListaTiposInfCon, PosInf, '*' +
              FormatoTipoInfYFecha(DatosInfAux, PosInf));
            WriteLn;
            TextColor(Green);
            Write('Cambios guardados correctamente.');
          end
          else
          begin
            WriteLn;
            TextColor(Red);
            Write('Se han descartado los cambios.');
          end;
          Delay(1500);
        end;
      end;
    until PosInf = -1;
    ActualizarInfracciones(ArchInf, DatosCon.DNI, ListaInfCon);
  end
  else
  begin
    TextColor(Red);
    WriteLn(UTF8Decode('¡El conductor no posee infracciones!'));
    Delay(1500);
  end;
  TextColor(White);
end;

end.
