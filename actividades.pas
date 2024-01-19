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
    WriteLn('[S]í');
    WriteLn('[N]o (Modificar)');
    WriteLn('[C]ANCELAR ALTA');
    WriteLn;

    while ObtenerOpcionAlta = #00 do
    begin
    Write('Opción: ');
    ClrEol;
    ReadLn(Op);
    if LowerCase(Op) in ['s', 'n', 'c'] then
      ObtenerOpcionAlta := LowerCase(Op)
    else
      GotoXY(1, WhereY-1);
    end;    
  end;

procedure AltaConductor(DatoIngresado: String; var ArchCon: TArchCon;
                        var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI; Caso: Byte); forward;
procedure MostrarDatosCon(var DatosCon: TDatoConductores) forward;
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
    ConAux: TDatoConductores;
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
    begin
      // Debería ser un procedimiento ConsultaConductor(ArchCon, ArbolApYNom, ArbolDNI);
      ClrScr;
      Seek(ArchCon, Pos);
      Read(ArchCon, ConAux);
      MostrarDatosCon(ConAux);
      WriteLn;
      WriteLn('[1] Modificar Datos.');
      WriteLn('[2] Dar de Baja.');
      WriteLn('[0] Volver.');
      ReadLn(Rta);
      ClrScr;
{      case Rta of
        '1': ModificarDatos(ConAux, ArchCon);
        '2': BajaCon(ConAux);
      end;}
    end;
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
      's':
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
      'n':; // ModificarDatos(DatosCon);
      'c': 
      begin
        TextColor(Red);
        WriteLn('Alta cancelada!');
        TextColor(White);
      end;
    end;
    until Op in ['s', 'c'];

    Delay(1000);
  end;

procedure MostrarDatosCon(var DatosCon: TDatoConductores);
  begin
    with DatosCon do
      if not (BajaLogica) then
      begin
        WriteLn('DNI: ', DNI);
        WriteLn('Apellido y Nombre: ', ApYNom);
        WriteLn('Fecha de Nacimiento: ', FechaNac.Dia, '/', FechaNac.Mes, '/', FechaNac.Anio);
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
        WriteLn('Fecha de Habilitación: ', FechaHab.Dia, '/', FechaHab.Mes, '/', FechaHab.Anio);
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

end.