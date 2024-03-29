unit UnitConductores;
{$CODEPAGE UTF8}

interface

uses
  SysUtils, crt, UnitArchivo, UnitPosiciones,
  UnitManejoFecha, UnitInfracciones, UnitObtenerDatos, UnitTypes,
  UnitMostrarACP;

procedure AltaConductor(DatoIngresado: string; var ArchCon: TArchCon;
  var ArchInf: TArchInf; var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI;
  Caso: shortstring);
procedure ConsultaConductor(var ArchCon: TArchCon; Pos: word;
  var ArchInf: TArchInf; var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);

implementation

procedure GuardarPosApYNom(var ArbolApYNom: TPuntApYNom; ApYNom: string; Pos: cardinal);
var
  xAux: TDatoPosApYNom;
begin
  xAux.ApYNom := ApYNom;
  xAux.Pos := Pos;
  AgregarApYNom(ArbolApYNom, xAux);
end;

procedure GuardarPosDNI(var ArbolDNI: TPuntDNI; DNI: cardinal; Pos: cardinal);
var
  xAux: TDatoPosDNI;
begin
  xAux.DNI := DNI;
  xAux.Pos := Pos;
  AgregarDNI(ArbolDNI, xAux);
end;

procedure ActualizarPosApYNom(var ArbolApYNom: TPuntApYNom; NuevoApYNom: string;
  AnteriorApYNom: string);
var
  Pos: longint;
begin
  Pos := PreordenApYNom(ArbolApYNom, AnteriorApYNom);
  SuprimirApYNom(ArbolApYNom, AnteriorApYNom);
  GuardarPosApYNom(ArbolApYNom, NuevoApYNom, Pos);
end;

procedure MostrarDatosCon(var DatosCon: TDatoConductores);
begin
  with DatosCon do
  begin
    WriteLn('DNI: ', DNI);
    MostrarLn('Apellido y Nombres: ', ApYNom);
    WriteLn('Fecha de Nacimiento: ', FormatoFecha(FechaNac.Dia,
      FechaNac.Mes, FechaNac.Anio));
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
    WriteLn('Fecha de Habilitación: ', FormatoFecha(FechaHab.Dia,
      FechaHab.Mes, FechaHab.Anio));
    WriteLn('Cantidad de Reincidencias: ', CantRein);
  end;
end;

procedure MostrarOpDatosCon(var DatosCon: TDatoConductores);
const
  CantOp = 5;
var
  i, MaxOp: word;
  EsqX, EsqY: word;
begin
  EsqX := WindMinX;
  EsqY := WindMinY;
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
  f = ' --> ';
begin
  // Muestra los datos modificados
  WriteLn('DNI: ', DatosOriginales.DNI);
  WriteLn;
  if DatosOriginales.ApYNom <> DatosModificados.ApYNom then
  begin
    Mostrar('Apellido y Nombres: ', DatosOriginales.ApYNom);
    MostrarLn(f, DatosModificados.ApYNom);
  end;
  if (DatosOriginales.FechaNac.Dia <> DatosModificados.FechaNac.Dia) or
    (DatosOriginales.FechaNac.Mes <> DatosModificados.FechaNac.Mes) or
    (DatosOriginales.FechaNac.Anio <> DatosModificados.FechaNac.Anio) then
  begin
    with DatosOriginales do
      Write('Fecha de Nacimiento: ', FormatoFecha(FechaNac.Dia,
        FechaNac.Mes, FechaNac.Anio));
    Write(f);
    with DatosModificados do
      WriteLn(FormatoFecha(FechaNac.Dia, FechaNac.Mes, FechaNac.Anio));
  end;
  if DatosOriginales.Tel <> DatosModificados.Tel then
    WriteLn('Teléfono: ', DatosOriginales.Tel, f, DatosModificados.Tel);
  if DatosOriginales.EMail <> DatosModificados.EMail then
    WriteLn('EMail: ', DatosOriginales.EMail, f, DatosModificados.EMail);
end;

procedure ModificarDatos(var DatosCon: TDatoConductores;
  var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);
var
  DatosConAux: TDatoConductores;
  EsAlta, ModificaDatos: boolean;
  Op, Rta: string[2];
begin
  DatosConAux := DatosCon;
  EsAlta := (PreordenDNI(ArbolDNI, DatosCon.DNI) = -1);
  ModificaDatos := False;
  repeat
    ClrScr;
    MostrarOpDatosCon(DatosConAux);
    WriteLn;
    Op := ObtenerOpcion('Opción: ', 0, 5);
    if (Op <> '0') and (Op <> '1') and not (EsAlta) then
      ModificaDatos := True;
    ClrScr;
    case Op of
      '1':
        if EsAlta then
          DatosConAux.DNI := ObtenerDNI
        else
        begin
          // Muestra un error si el DNI del conductor ya está guardado en el archivo
          TextColor(Red);
          WriteLn('ERROR: No es posible modificar un DNI ya cargado.');
          Delay(2000);
          TextColor(White);
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
  if ModificaDatos then
  begin
    MostrarModifCon(DatosCon, DatosConAux);
    WriteLn;
    Write('¿Desea guardar los cambios? (S/N): ');
    Rta := ObtenerRtaSN;
    WriteLn;
    if LowerCase(Rta) = 'n' then
    begin
      TextColor(LightRed);
      Write('Se han descartado los cambios.');
    end
    else
    begin
      ActualizarPosApYNom(ArbolApYNom, DatosConAux.ApYNom, DatosCon.ApYNom);

      // Sobrescribe los datos del conductor
      DatosCon := DatosConAux;
      TextColor(Green);
      Write('Cambios guardados correctamente.');
    end;
    TextColor(White);
    Delay(1500);
  end;
end;

procedure AltaConductor(DatoIngresado: string; var ArchCon: TArchCon;
  var ArchInf: TArchInf; var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI;
  Caso: shortstring);
var
  DatosCon: TDatoConductores;
  PosArch: word;
  Op, Rta: string[2];
begin
  WriteLn;
  WriteLn('¡No se encontró el conductor ingresado!');
  Write('¿Desea darlo de Alta? (s/N): ');
  ReadLn(Rta);
  ClrScr;
  if LowerCase(Rta) = 's' then
  begin
    // Guardar automáticamente el dato que se ingresa al consultar conductor
    if Caso = 'apynom' then
    begin
      MostrarLn('Apellido y Nombres: ' + DatoIngresado);
      DatosCon.ApYNom := DatoIngresado;
      DatosCon.DNI := ObtenerDNI;
    end
    else
    begin
      WriteLn('DNI: ', DatoIngresado);
      DatosCon.ApYNom := ObtenerApYNom;
      Val(DatoIngresado, DatosCon.DNI);
    end;

    // Obtener el resto de los datos del conductor
    ObtenerFechaNac(DatosCon.FechaNac);
    DatosCon.Tel := ObtenerTel;
    DatosCon.EMail := ObtenerEMail;

    // Inicializar los demás datos
    DatosCon.Scoring := 20;
    DatosCon.Habilitado := True;
    ObtenerFechaActual(DatosCon.FechaHab);
    DatosCon.CantRein := 0;
    DatosCon.BajaLogica := False;

    repeat
      ClrScr;
      MostrarDatosCon(DatosCon);
      WriteLn;
      WriteLn('¿Son correctos los datos ingresados?');
      WriteLn('[1] Sí.');
      WriteLn('[2] No (Modificar).');
      WriteLn('[0] CANCELAR ALTA.');
      WriteLn;
      Op := ObtenerOpcion('Opción: ', 0, 2);
      case Op of
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
          WriteLn('¡Alta exitosa!');
          TextColor(White);
          Delay(1000);
          ClrScr;
          ConsultaConductor(ArchCon, PosArch, ArchInf, ArbolApYNom, ArbolDNI);
        end;
        '2': ModificarDatos(DatosCon, ArbolApYNom, ArbolDNI);
        '0':
        begin
          WriteLn;
          TextColor(Red);
          WriteLn('¡Alta cancelada!');
          TextColor(White);
          Delay(1000);
        end;
      end;
    until (Op = '1') or (Op = '0');
  end;
end;

procedure BajaConductor(var DatosCon: TDatoConductores);
begin
  TextColor(Red);
  WriteLn('¡Advertencia!');
  WriteLn;
  TextColor(White);
  WriteLn('Se dará de baja al siguiente conductor:');
  WriteLn('           DNI: ', DatosCon.DNI);
  MostrarLn('           Apellido y Nombres: ', DatosCon.ApYNom);
  WriteLn;
  WriteLn('Esta acción NO eliminará los datos o las infracciones guardadas,');
  WriteLn('pero lo excluirá de listados y promedios.');
  WriteLn;
  Write('¿Desea continuar con la baja? (S/N): ');
  if ObtenerRtaSN = 's' then
  begin
    DatosCon.BajaLogica := True;
    TextColor(Green);
    WriteLn;
    WriteLn('¡Baja Exitosa!');
    TextColor(White);
  end
  else
  begin
    TextColor(Red);
    WriteLn;
    WriteLn('¡Baja Cancelada!');
    TextColor(White);
  end;
  Delay(1500);
end;

procedure ConsultaBajaConductor(var DatosCon: TDatoConductores);
begin
  TextColor(Red);
  WriteLn('¡Advertencia!');
  WriteLn;
  TextColor(White);
  WriteLn('El conductor ingresado se encuentra dado de baja:');
  WriteLn('           DNI: ', DatosCon.DNI);
  MostrarLn('           Apellido y Nombres: ', DatosCon.ApYNom);
  WriteLn;
  WriteLn('Para poder acceder a los datos debe darlo de alta.');
  WriteLn;
  Write('¿Desea darlo de alta? (S/N): ');
  if ObtenerRtaSN = 's' then
  begin
    DatosCon.BajaLogica := False;
    WriteLn;
    TextColor(Green);
    WriteLn('¡Alta Exitosa!');
    TextColor(White);
  end
  else
  begin
    WriteLn;
    TextColor(Red);
    WriteLn('¡Alta Cancelada!');
    TextColor(White);
  end;
  Delay(1500);
end;

procedure ConsultaConductor(var ArchCon: TArchCon; Pos: word;
  var ArchInf: TArchInf; var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);
var
  DatosCon: TDatoConductores;
  Op: string[2];
begin
  ClrScr;

  // Lee los datos del conductor
  Seek(ArchCon, Pos);
  Read(ArchCon, DatosCon);

  repeat
    ClrScr;
    if not (DatosCon.BajaLogica) then
    begin
      MostrarDatosCon(DatosCon);
      WriteLn;
      WriteLn('[1] Alta de Infracción.');
      WriteLn('[2] Consulta de Infracciones.');
      WriteLn('[3] Modificar Datos.');
      WriteLn('[4] Dar de Baja.');
      WriteLn('[0] Volver.');
      WriteLn;
      Op := ObtenerOpcion('Opción: ', 0, 4);
      if Op <> '0' then
        ClrScr;
      case Op of
        '1': AltaInfraccion(DatosCon, ArchInf);
        '2': ConsultaInfraccion(DatosCon, ArchInf);
        '3': ModificarDatos(DatosCon, ArbolApYNom, ArbolDNI);
        '4': BajaConductor(DatosCon);
      end;
    end
    else
      ConsultaBajaConductor(DatosCon);
  until (Op = '0') or (DatosCon.BajaLogica);

  // Guarda los datos del conductor en el archivo
  Seek(ArchCon, Pos);
  Write(ArchCon, DatosCon);
end;

end.
