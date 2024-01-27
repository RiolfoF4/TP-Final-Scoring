unit Actividades;
{$CODEPAGE UTF8}

interface

uses
  sysutils, crt, UnitArchivo, UnitValidacion, UnitPosiciones, 
  UnitManejoFecha, UnitInfracciones, UnitObtenerDatos;

const
  EsqX = 15;
  EsqY = 5;

procedure Inicializar(var ArchCon: TArchCon; var ArchInf: TArchInf; var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);
procedure Cerrar(var ArchCon: TArchCon; var ArchInf: TArchInf);

// Caso 1: Ingresa ApYNom  Caso 2: Ingresa DNI
procedure DeterminarCasoCon(var ArchCon: TArchCon; var ArchInf: TArchInf; 
                            var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI; Caso: Byte);               

implementation
procedure MostrarFecha(Fecha: TRegFecha);
  begin
    Write(Format('%0.2d', [Fecha.Dia]), '/', Format('%0.2d', [Fecha.Mes]), '/', Fecha.Anio);
  end;
procedure AltaConductor(DatoIngresado: String; var ArchCon: TArchCon; var ArchInf: TArchInf;
                        var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI; Caso: Byte); forward;
procedure ConsultaConductor(Pos: Word; var ArchCon: TArchCon; var ArchInf: TArchInf;
                            var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI) forward;
procedure MostrarDatosCon(var DatosCon: TDatoConductores) forward;
procedure ModificarDatos(var DatosCon: TDatoConductores; var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI) forward;
procedure GuardarPosApYNom(var ArbolApYNom: TPuntApYNom; ApYNom: String; Pos: Cardinal);
  var
    xAux: TDatoPosApYNom;
  begin
    xAux.ApYNom := ApYNom;
    xAux.Pos := Pos;
    AgregarApYNom(ArbolApYNom, xAux);
  end;
procedure GuardarPosDNI(var ArbolDNI: TPuntDNI; DNI: Cardinal; Pos: Cardinal);
  var
    xAux: TDatoPosDNI;
  begin
    xAux.DNI := DNI;
    xAux.Pos := Pos;
    AgregarDNI(ArbolDNI, xAux);
  end;
procedure ActualizarPosApYNom(var ArbolApYNom: TPuntApYNom; NuevoApYNom: String; AnteriorApYNom: String);
  var
    Pos: Word;
  begin
    Pos := PreordenApYNom(ArbolApYNom, AnteriorApYNom);
    SuprimirApYNom(ArbolApYNom, AnteriorApYNom);
    GuardarPosApYNom(ArbolApYNom, NuevoApYNom, Pos);
  end;
procedure CargarArbolPos(var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI; var ArchCon: TArchCon);
  var
    xPosApYNom: TDatoPosApYNom;
    xPosDNI: TDatoPosDNI;
    xAuxCon: TDatoConductores;
  begin
    Seek(ArchCon, 0);
    // Recorrer el archivo de conductores hasta el final, o hasta que el árbol este lleno
    while not (EOF(ArchCon)) and not (ArbolLlenoApYNom(ArbolApYNom)) do
    begin
      Read(ArchCon, xAuxCon);
      // Guardar la clave y la posición
      xPosApYNom.ApYNom := xAuxCon.ApYNom;
      xPosApYNom.Pos := FilePos(ArchCon) - 1;
      xPosDNI.DNI := xAuxCon.DNI;
      xPosDNI.Pos := FilePos(ArchCon) - 1;

      // Agregar al árbol
      AgregarApYNom(ArbolApYNom, xPosApYNom);
      AgregarDNI(ArbolDNI, xPosDNI);
    end;
  end;

procedure Inicializar(var ArchCon: TArchCon; var ArchInf: TArchInf; var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);
  begin
    Window(EsqX, EsqY, WindMaxX - EsqX, WindMaxY);
    TextColor(White);
    CrearAbrirArchivoCon(ArchCon);
    CrearAbrirArchivoInf(ArchInf);
    CrearArbolApYNom(ArbolApYNom);
    CrearArbolDNI(ArbolDNI);
    CargarArbolPos(ArbolApYNom, ArbolDNI, ArchCon);
  end;

procedure Cerrar(var ArchCon: TArchCon; var ArchInf: TArchInf);
  begin
    CerrarArchivoCon(ArchCon);
    CerrarArchivoInf(ArchInf);
  end;

procedure DeterminarCasoCon(var ArchCon: TArchCon; var ArchInf: TArchInf;
                            var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI; Caso: Byte);               
  var
    ApYNom: String[50];
    DNI: Cardinal;
    Pos: LongInt;
    DatoIng: String[50];
  begin
    if Caso = 1 then
    begin
      ApYNom := ObtenerApYNom;
      DatoIng := ApYNom;
      Pos := PreordenApYNom(ArbolApYNom, ApYNom);
    end
    else
    begin
      DNI := ObtenerDNI;
      DatoIng := UIntToStr(DNI);
      Pos := PreordenDNI(ArbolDNI, DNI);
    end;
    if Pos < 0 then
        AltaConductor(DatoIng, ArchCon, ArchInf, ArbolApYNom, ArbolDNI, Caso)
    else
      ConsultaConductor(Pos, ArchCon, ArchInf, ArbolApYNom, ArbolDNI);
  end;


procedure AltaConductor(DatoIngresado: String; var ArchCon: TArchCon; var ArchInf: TArchInf;
                        var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI; Caso: Byte);
  var
    DatosCon: TDatoConductores;
    PosArch: Word;
    Op, Rta: String[2];
  begin
    WriteLn('No se encontró el conductor ingresado!');
    Write('¿Desea darlo de Alta? (s/N): ');
    ReadLn(Rta);
    ClrScr;
    if LowerCase(Rta) = 's' then
    begin
      // Guardar automáticamente el dato que se ingresa al consultar conductor
      if Caso = 1 then
      begin
        DatosCon.ApYNom := DatoIngresado;
        DatosCon.DNI := ObtenerDNI;
      end
      else
      begin
        DatosCon.ApYNom := ObtenerApYNom;
        Val(DatoIngresado, DatosCon.DNI);
      end;

      // Obtener el resto de los datos del conductor
      ObtenerFechaNac(DatosCon.FechaNac);
      DatosCon.Tel := ObtenerTel;
      DatosCon.EMail := ObtenerEMail;
      DatosCon.Scoring := 20;
      DatosCon.Habilitado := True;
      ObtenerFechaActual(DatosCon.FechaHab);
      DatosCon.CantRein := 0;
      DatosCon.BajaLogica := False;

      repeat
      ClrScr;
      MostrarDatosCon(DatosCon);
      WriteLn;
      Op := ObtenerOpcionAlta;
      Case Op of
        '1':
        begin
            // Guardar datos en el archivo de conductores
            PosArch := FileSize(ArchCon);
            Seek(ArchCon, PosArch);
            Write(ArchCon, DatosCon);

            // Guardar posición de los datos del conductor
            GuardarPosApYNom(ArbolApYNom, DatosCon.ApYNom, PosArch);
            GuardarPosDNI(ArbolDNI, DatosCon.DNI, PosArch);

            WriteLn;
            TextColor(Green);
            WriteLn('Alta exitosa!');
            TextColor(White);
            Delay(1000);
            ClrScr;
            ConsultaConductor(PosArch, ArchCon, ArchInf, ArbolApYNom, ArbolDNI);
        end;
        '2': ModificarDatos(DatosCon, ArbolApYNom, ArbolDNI);
        '0': 
        begin
          TextColor(Red);
          WriteLn('Alta cancelada!');
          TextColor(White);
          Delay(1000);
        end;
      end;
      until (Op = '1') or (Op = '0');
    end;
  end;

procedure ConsultaConductor(Pos: Word; var ArchCon: TArchCon; var ArchInf: TArchInf;
                            var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);
  var
    DatosCon: TDatoConductores;
    Op: String[2];
  begin
    ClrScr;

    // Lee los datos del conductor
    Seek(ArchCon, Pos);
    Read(ArchCon, DatosCon);

    repeat
    ClrScr;
    MostrarDatosCon(DatosCon);
    WriteLn;
    WriteLn('[1] Alta de Infracción.');
    WriteLn('[2] Consulta de Infracciones.');
    WriteLn('[3] Modificar Datos.');
    WriteLn('[4] Dar de Baja.');
    WriteLn('[0] Volver.');
    WriteLn;
    Write('Opción: ');
    ReadLn(Op);
    if Op <> '0' then
      ClrScr;
    case Op of
      '1': AltaInfraccion(DatosCon, ArchInf);
      '3': ModificarDatos(DatosCon, ArbolApYNom, ArbolDNI);
    end;
    until Op = '0';

    Seek(ArchCon, Pos);
    Write(ArchCon, DatosCon);
  end;

procedure MostrarDatosCon(var DatosCon: TDatoConductores);
  begin
    with DatosCon do
      if not (BajaLogica) then
      begin
        WriteLn('DNI: ', DNI);
        WriteLn('Apellido y Nombre: ', ApYNom);
        Write('Fecha de Nacimiento: '); 
        MostrarFecha(FechaNac);
        WriteLn;
        WriteLn('Teléfono: ', Tel);
        WriteLn('EMail: ', EMail);
        WriteLn('Scoring: ', Scoring);
        Write('Habilitado: ');
        if Habilitado then
        begin
          TextColor(Green);
          WriteLn('Sí');
        end
        else
        begin
          TextColor(Red);
          WriteLn('No');
        end;
        TextColor(White);
        Write('Fecha de Habilitación: ');
        MostrarFecha(FechaHab);
        WriteLn;
        WriteLn('Cantidad de Reincidencias: ', CantRein);
      end;
    end;

procedure MostrarOpDatosCon(var DatosCon: TDatoConductores);
  const
    CantOp = 5;
  var
    i, MaxOp: Word;
  begin
    // Deja un espacio de 4 caracteres para mostrar las opciones
    Window(EsqX + 4, EsqY, WindMaxX, WindMaxY);
    MostrarDatosCon(DatosCon);
    
    // Cantidad de datos mostrados
    MaxOp := WhereY - 1;

    // Restablece el Window original
    Window(EsqX, EsqY, WindMaxX, WindMaxY);
    
    // Muestra un índice en las opciones que se pueden modificar
    for i := 1 to CantOp do
      WriteLn('[', i, ']');

    // Muestra '[-]' en las opciones que NO se pueden modificar
    for i := (i + 1) to MaxOp do
      WriteLn('[-]');
  
    WriteLn;
    WriteLn('[0] Volver');
  end;

procedure MostrarModifCon(DatosOriginales, DatosModificados: TDatoConductores);
  const
    f = ' ==> ';
  begin
    // Muestra los datos modificados
    WriteLn('DNI: ', DatosOriginales.DNI);
    if DatosOriginales.ApYNom <> DatosModificados.ApYNom then
      WriteLn('Apellido y Nombre: ', DatosOriginales.ApYNom, f, DatosModificados.ApYNom);
    if (DatosOriginales.FechaNac.Dia <> DatosModificados.FechaNac.Dia) or 
       (DatosOriginales.FechaNac.Mes <> DatosModificados.FechaNac.Mes) or
       (DatosOriginales.FechaNac.Anio <> DatosModificados.FechaNac.Anio) then
    begin
      Write('Fecha de Nacimiento: ');
      MostrarFecha(DatosOriginales.FechaNac);
      Write(f);
      MostrarFecha(DatosModificados.FechaNac);
      WriteLn;
    end;
    if DatosOriginales.Tel <> DatosModificados.Tel then
      WriteLn('Teléfono: ', DatosOriginales.Tel, f, DatosModificados.Tel);
    if DatosOriginales.EMail <> DatosModificados.EMail then
      WriteLn('EMail: ', DatosOriginales.EMail, f, DatosModificados.EMail);
  end;

procedure ModificarDatos(var DatosCon: TDatoConductores; var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);
  var
    DatosConAux: TDatoConductores;
    EsAlta: Boolean;
    Op, Rta: String[2];
  begin
    DatosConAux := DatosCon;
    EsAlta := (PreordenDNI(ArbolDNI, DatosCon.DNI) = -1);
    repeat
      ClrScr;
      MostrarOpDatosCon(DatosConAux);
      WriteLn;
      Write('Opción: ');
      ReadLn(Op);
      ClrScr;
      case Op of
        '1': 
        begin
          // Muestra un error si el DNI del conductor ya está guardado en el archivo
          if EsAlta then
            DatosConAux.DNI := ObtenerDNI
          else
          begin
            TextColor(Red);
            WriteLn('ERROR: No es posible modificar un DNI ya cargado.');
            Delay(1500);
            TextColor(White);
          end;
        end;
        '2': DatosConAux.ApYNom := ObtenerApYNom;
        '3': ObtenerFechaNac(DatosConAux.FechaNac);
        '4': DatosConAux.Tel := ObtenerTel;
        '5': DatosConAux.EMail := ObtenerEMail;
      end;
    until Op = '0';
    
    if EsAlta then
      DatosCon := DatosConAux
    else
    begin
      MostrarModifCon(DatosCon, DatosConAux);
      WriteLn;
      Write('¿Desea guardar los cambios? (S/N): ');
      Rta := ObtenerRtaSN;
      WriteLn;
      if LowerCase(Rta) = 'n' then
      begin
        TextColor(LightRed);
        Write('Se han descartado los cambios.')
      end
      else
      begin
        ActualizarPosApYNom(ArbolApYNom, DatosConAux.ApYNom, DatosCon.ApYNom);

        // Sobrescribe los datos del conductor
        DatosCon := DatosConAux;
        TextColor(Green);
        Write('Cambios guardados correctamente.')
      end;
      TextColor(White);
      Delay(1500);
    end;
  end;
end.
