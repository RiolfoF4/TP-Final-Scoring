unit UnitInfracciones;

interface

uses
  crt, sysutils, UnitValidacion, UnitArchivo, UnitPila, UnitObtenerDatos;

procedure AltaInfraccion(var DatosCon: TDatoConductores; var ArchInf: TArchInf);

implementation
procedure InicializarArchBinListInf(var ArchBinListInf: TArchBinListInf; var ArchListaInf: TArchListInf);
  var
    x: String;
  begin
    while not (EOF(ArchListaInf)) do
    begin
      ReadLn(ArchListaInf, x);
      if x <> '' then
        Write(ArchBinListInf, x)
    end;
    Reset(ArchListaInf);
    Seek(ArchBinListInf, 0);
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

function InfraccionValida(NumeroInfrac: String; var ArchInf: TArchBinListInf): Boolean;
  var
    Num: Integer;
  begin
    InfraccionValida := False;
    if EsNum(NumeroInfrac) then
    begin
      Val(NumeroInfrac, Num);
      // NOTA: La infracción [1] se encuentra en la posición 0 del archivo, la [2] en el 1...
      // La última infracción coincide con el tamaño del archivo
      if (1 <= Num) and (Num <= FileSize(ArchInf)) then
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
    ArchBinListInf: TArchBinListInf;
    PosAnterior: TPila;
    i, Anterior: Byte;
    Tecl: String[2];
    Infraccion: ShortString;

  begin
    CrearAbrirArchivoListInf(ArchListaInf);
    CrearAbrirArchivoBinListInf(ArchBinListInf);
    InicializarArchBinListInf(ArchBinListInf, ArchListaInf);
    CrearPila(PosAnterior);

    i := 0;
    Anterior := 0;
    Tecl := '';

    while (LowerCase(Tecl) <> 'q') and not (InfraccionValida(Tecl, ArchBinListInf)) do
    begin
      // Si no se llegó al final del archivo, muestra secuencialmente las infracciones
      if i < FileSize(ArchBinListInf) then
      begin
        Seek(ArchBinListInf, i);
        Read(ArchBinListInf, Infraccion);
        Infraccion := '[' + IntToStr(i+1) + '] ' + Infraccion;
        MostrarInfraccion(Infraccion);
        WriteLn;
        Inc(i);
      end;

      // Recibe una entrada del usuario si el texto supera un límite inferior
      // o se llega al final del archivo
      if (WhereY > LimiteInferior) or (EOF(ArchBinListInf)) then
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
            if not (EOF(ArchBinListInf)) then
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
              i := 0;
        else
          // Si la tecla no es 's' ni 'a', muestra lo mismo
          i := Anterior;
        end;
        Anterior := i;
        ClrScr;
      end;
    end;

    // Devolver la infraccion seleccionada, o una string vacía si selecciona 'Salir'
    if InfraccionValida(Tecl, ArchBinListInf) then
    begin
      Seek(ArchBinListInf, StrToInt(Tecl) - 1);
      Read(ArchBinListInf, ObtenerInfraccion);
    end
    else
      ObtenerInfraccion := '';
    CerrarArchivoListInf(ArchListaInf);
    CerrarArchivoBinListInf(ArchBinListInf);
  end;

procedure CargarDatosInfraccion(DatosCon: TDatoConductores; var Infraccion: TDatoInfracciones);
  begin
    Infraccion.DNI := DatosCon.DNI;
    ObtenerFechaActual(Infraccion.Fecha);
    Infraccion.Puntos := PuntosInfraccion(Infraccion.Tipo);
  end;

procedure AgregarInfraccion(var DatosCon: TDatoConductores; Infraccion: TDatoInfracciones; var ArchInf: TArchInf);
  begin
    
  end;

procedure AltaInfraccion(var DatosCon: TDatoConductores; var ArchInf: TArchInf);
  var
    Infraccion: TDatoInfracciones;
    Rta: String[2];
  begin
    Infraccion.Tipo := ObtenerInfraccion;
    if Infraccion.Tipo <> '' then
    begin
      CargarDatosInfraccion(DatosCon, Infraccion);
			WriteLn('DNI: ', Infraccion.DNI);
			WriteLn;
      MostrarInfraccion('Infracción seleccionada: ' + Infraccion.Tipo);
      WriteLn;
      WriteLn('Puntos a descontar: ', Infraccion.Puntos);
      WriteLn;
      // TODO: Mostrar la fecha y permitir modificar el tipo y la fecha de la infraccion
      Write(UTF8Decode('¿Desea dar de alta la infracción seleccionada? (S/N): '));
      Rta := ObtenerRtaSN;
      WriteLn;
      if LowerCase(Rta) <> 's' then
      begin
				TextColor(Red);
				WriteLn('Alta cancelada!');
				TextColor(White);
			end
			else
			begin
				TextColor(Green);
				WriteLn('Alta exitosa!');
				TextColor(White);
			end;
    Delay(1500);
		end;
  end;
end.