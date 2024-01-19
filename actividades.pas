unit Actividades;
{$CODEPAGE UTF8}

interface

uses
  sysutils, crt, UnitArchivo, UnitValidacion, UnitPosiciones;

const
  EsqX = 30;
  EsqY = 8;

procedure Inicializar(var ArchCon: TArchCon; var ArchInf: TArchInf; var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);
procedure Cerrar(var ArchCon: TArchCon; var ArchInf: TArchInf);

// Caso 1: Ingresa ApYNom  Caso 2: Ingresa DNI
procedure DeterminarCasoCon(var ArchCon: TArchCon; var ArchInf: TArchInf; 
                            var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI; Caso: Byte);               

implementation
function ObtenerApYNom: String;
  begin
    ObtenerApYNom := '';
    while ObtenerApYNom = '' do
    begin
      Write('Apellido y Nombre: ');
      ReadLn(ObtenerApYNom);
      if ObtenerApYNom = '' then
        GotoXY(1, WhereY-1);
    end;
  end;

function ObtenerDNI: Cardinal;
  var
    Cad: String[10];
  begin
    ObtenerDNI := 0;
    while (ObtenerDNI < 10000000) do
    begin
      ClrEol;
      Write('DNI (Sin puntos ni espacios): ');
      ReadLn(Cad);
      if EsNum(Cad) then
      begin
        ObtenerDNI := StrToDWord(Cad);
        if ObtenerDNI < 10000000 then
          GotoXY(1, WhereY-1);
      end
      else
        GotoXY(1, WhereY-1);
    end;
  end;

function ObtenerTel: String;
  var
    Cad: String[20];
  begin
    ObtenerTel := '';
    while ObtenerTel = '' do
    begin
      Write('Teléfono (Sin prefijo internacional ni espacios): ');
      ClrEol;
      ReadLn(Cad);
      if EsNum(Cad) then
        ObtenerTel := Cad
      else
        GotoXY(1, WhereY-1);
    end;
  end;

function ObtenerEMail: String;
{  var
    Cad: String;}
  begin
{    ObtenerEMail := '';
    while ObtenerEMail = '' do
    begin
      Write('EMail: ');
      ReadLn(Cad);
      if EsEMail(Cad) then
        ObtenerEMail := Cad;
    end;}
    Write('EMail: ');
    ReadLn(ObtenerEMail);
  end;

procedure ObtenerFechaActual(var Fecha: TRegFecha);
  begin
    DecodeDate(Date, Fecha.Anio, Fecha.Mes, Fecha.Dia);
  end;

procedure ObtenerFechaNac(var Fecha: TRegFecha);
  var
    FechaValida: Boolean;
  begin
    FechaValida := False;
    while not (FechaValida) do
      with Fecha do
      begin
        WriteLn('Fecha de Nacimiento');
        Write(' Año: ');
        ReadLn(Anio);
        Write(' Mes: ');
        ReadLn(Mes);
        Write(' Día: ');
        ReadLn(Dia);
        FechaValida := EsFecha(Anio, Mes, Dia);
      end;
  end;

function ObtenerOpcionAlta(DatosCon: TDatoConductores): Char;
  var
    Op: Char;
  begin
    ObtenerOpcionAlta := #00;
    WriteLn('¿Son correctos los datos ingresados?');
    WriteLn('[1] Sí');
    WriteLn('[2] No (Modificar)');
    WriteLn('[0] CANCELAR ALTA');
    WriteLn;

    while ObtenerOpcionAlta = #00 do
    begin
    Write('Opción: ');
    ClrEol;
    ReadLn(Op);
    if LowerCase(Op) in ['1', '2', '0'] then
      ObtenerOpcionAlta := LowerCase(Op)
    else
      GotoXY(1, WhereY-1);
    end;    
  end;

procedure AltaConductor(DatoIngresado: String; var ArchCon: TArchCon;
                        var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI; Caso: Byte); forward;
procedure ConsultaConductor(Pos: Word; var ArchCon: TArchCon; var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI) forward;
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
    xAux: TDatoPosApYNom;
  begin
    Pos := PreordenApYNom(ArbolApYNom, AnteriorApYNom);
    xAux.ApYNom := AnteriorApYNom;
    xAux.Pos := Pos;
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
    Window(EsqX, EsqY, WindMaxX, WindMaxY);
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
    Rta: String[2];
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
    begin
      WriteLn('No se encontró el conductor ingresado!');
      Write('¿Desea darlo de Alta? (s/N): ');
      ReadLn(Rta);
      ClrScr;
      if LowerCase(Rta) = 's' then
        AltaConductor(DatoIng, ArchCon, ArbolApYNom, ArbolDNI, Caso);
    end
    else
      ConsultaConductor(Pos, ArchCon, ArbolApYNom, ArbolDNI);
  end;


procedure AltaConductor(DatoIngresado: String; var ArchCon: TArchCon;
                        var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI; Caso: Byte);
  var
    DatosCon: TDatoConductores;
    PosArch: Word;
    Op: Char;
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
    Op := ObtenerOpcionAlta(DatosCon);
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
          Write('¿Desea agregar una infracción? (s/N): ');
          ReadLn;
      end;
      '2': ModificarDatos(DatosCon, ArbolApYNom, ArbolDNI);
      '0': 
      begin
        TextColor(Red);
        WriteLn('Alta cancelada!');
        TextColor(White);
      end;
    end;
    until Op in ['1', '0'];

    Delay(1000);
  end;

procedure ConsultaConductor(Pos: Word; var ArchCon: TArchCon; var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);
  var
    DatosCon: TDatoConductores;
    Op: String[2];
  begin
    ClrScr;

    // Lee los datos del conductor
    Seek(ArchCon, Pos);
    Read(ArchCon, DatosCon);


    repeat
    MostrarDatosCon(DatosCon);
    WriteLn;
    WriteLn('[1] Modificar Datos.');
    WriteLn('[2] Dar de Baja.');
    WriteLn('[0] Volver.');
    WriteLn;
    Write('Opción: ');
    ReadLn(Op);
    ClrScr;
    case Op of
      '1': ModificarDatos(DatosCon, ArbolApYNom, ArbolDNI);
    end;
    until Op = '0';

    // Sobrescribe los datos del conductor
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
        WriteLn('Fecha de Nacimiento: ', Format('%0.2d', [FechaNac.Dia]), '/', 
                Format('%0.2d', [FechaNac.Mes]), '/', FechaNac.Anio);
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
        WriteLn('Fecha de Habilitación: ', Format('%0.2d', [FechaHab.Dia]), '/',
                 Format('%0.2d', [FechaHab.Mes]), '/', FechaHab.Anio);
        WriteLn('Cantidad de Reincidencias: ', CantRein);
        // ¿Debería mostrar si está dado de alta o de baja?
  {      Write('Estado: ');
        if not(BajaLogica) then
        begin
          TextColor(Green);
          WriteLn('Alta');
        end
        else
        begin
          TextColor(Red);
          WriteLn('Baja');
        end;
        TextColor(White);}
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

procedure ModificarDatos(var DatosCon: TDatoConductores; var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);
  var
    Op: String[2];
    AnteriorApYNom: String[100];
  begin
    repeat
      ClrScr;
      MostrarOpDatosCon(DatosCon);
      WriteLn;
      Write('Opción: ');
      ReadLn(Op);
      ClrScr;
      case Op of
        '1': 
        begin
          // Muestra un error si el DNI del conductor ya está guardado en el archivo
          if PreordenDNI(ArbolDNI, DatosCon.DNI) = -1 then
            DatosCon.DNI := ObtenerDNI
          else
          begin
            TextColor(Red);
            WriteLn('ERROR: No es posible modificar un DNI ya cargado');
            ReadLn;
            TextColor(White);
          end;
        end;
        '2': 
        begin
          // Guarda el nombre anterior conductor si ya estaba guardado en el archivo
          if PreordenApYNom(ArbolApYNom, DatosCon.ApYNom) <> -1 then
            AnteriorApYNom := DatosCon.ApYNom;
          DatosCon.ApYNom := ObtenerApYNom;
          ActualizarPosApYNom(ArbolApYNom, DatosCon.ApYNom, AnteriorApYNom);
        end;
        '3': ObtenerFechaNac(DatosCon.FechaNac);
        '4': DatosCon.Tel := ObtenerTel;
        '5': DatosCon.EMail := ObtenerEMail;
      end;
    until Op = '0';
  end;

end.