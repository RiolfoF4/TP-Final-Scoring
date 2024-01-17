unit Actividades;
{$CODEPAGE UTF8}

interface

uses
  sysutils, crt, UnitArchivo, UnitValidacion, UnitPosiciones;

const
  EsqX = 30;
  EsqY = 8;

procedure Inicializar(var ArchCon: TArchCon; var ArchInf: TArchInf; var ArchPosApYNom: TArchPosApYNom;
                      var ArchPosDNI: TArchPosDNI; var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);
procedure Cerrar(var ArchCon: TArchCon; var ArchInf: TArchInf; 
                 var ArchPosApYNom: TArchPosApYNom; var ArchPosDNI: TArchPosDNI);

// Caso 1: Ingresa ApYNom  Caso 2: Ingresa DNI
procedure DeterminarCasoCon(var ArchCon: TArchCon; var ArchInf: TArchInf; var ArchPosApYNom: TArchPosApYNom;
                            var ArchPosDNI: TArchPosDNI; var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI; Caso: Byte);               

implementation
function ObtenerApYNom: String;
  begin
    ObtenerApYNom := '';
    while ObtenerApYNom = '' do
    begin
      GotoXY(1, WhereY-1);
      Write('Apellido y Nombre: ');
      ReadLn(ObtenerApYNom);
    end;
  end;

function ObtenerDNI: Cardinal;
  var
    Cad: String[10];
  begin
    ObtenerDNI := 0;
    while (ObtenerDNI < 10000000) do
    begin
      GotoXY(1, WhereY-1);
      ClrEol;
      Write('DNI (Sin puntos ni espacios): ');
      ReadLn(Cad);
      if EsNum(Cad) then
        ObtenerDNI := StrToDWord(Cad);
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
      ReadLn(Cad);
      if EsNum(Cad) then
        ObtenerTel := Cad;
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

procedure AltaConductor(DatoIngresado: String; var ArchCon: TArchCon; var ArchPosApYNom: TArchPosApYNom; var ArchPosDNI: TArchPosDNI; 
                        var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI; Caso: Byte); forward;
procedure MostrarDatosCon(var DatosCon: TDatoConductores) forward;
procedure GuardarPosApYNom(var ArchPosApYNom: TArchPosApYNom; var ArbolApYNom: TPuntApYNom; ApYNom: String; Pos: Cardinal);
  var
    xAux: TDatoPosApYNom;
  begin
    xAux.ApYNom := ApYNom;
    xAux.Pos := Pos;
    Seek(ArchPosApYNom, FileSize(ArchPosApYNom));
    Write(ArchPosApYNom, xAux);
    AgregarApYNom(ArbolApYNom, xAux);
  end;
procedure GuardarPosDNI(var ArchPosDNI: TArchPosDNI; var ArbolDNI: TPuntDNI; DNI: Cardinal; Pos: Cardinal);
  var
    xAux: TDatoPosDNI;
  begin
    xAux.DNI := DNI;
    xAux.Pos := Pos;
    Seek(ArchPosDNI, FileSize(ArchPosDNI));
    Write(ArchPosDNI, xAux);
    AgregarDNI(ArbolDNI, xAux);
  end;
procedure CargarArbolApYNom(var ArbolApYNom: TPuntApYNom; var ArchPosApYNom: TArchPosApYNom);
  var
    xAuxArch: TDatoPosApYNom;
  begin
    Seek(ArchPosApYNom, 0);
    if FileSize(ArchPosApYNom) > 0 then
      while not (EOF(ArchPosApYNom)) and not (ArbolLlenoApYNom(ArbolApYNom)) do
      begin
        Read(ArchPosApYNom, xAuxArch);
        AgregarApYNom(ArbolApYNom, xAuxArch);
      end;
  end;

procedure CargarArbolDNI(var ArbolDNI: TPuntDNI; var ArchPosDNI: TArchPosDNI);
  var
    xAuxArch: TDatoPosDNI;
  begin
    Seek(ArchPosDNI, 0);
    if FileSize(ArchPosDNI) > 0 then
      while not (EOF(ArchPosDNI)) and not (ArbolLlenoDNI(ArbolDNI)) do
      begin
        Read(ArchPosDNI, xAuxArch);
        AgregarDNI(ArbolDNI, xAuxArch);
      end;
  end;

procedure Inicializar(var ArchCon: TArchCon; var ArchInf: TArchInf; var ArchPosApYNom: TArchPosApYNom;
                      var ArchPosDNI: TArchPosDNI; var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);
  begin
    Window(EsqX, EsqY, WindMaxX, WindMaxY);
    TextColor(White);
    CrearAbrirArchivoCon(ArchCon);
    CrearAbrirArchivoInf(ArchInf);
    CrearAbrirArchivoPosApYNom(ArchPosApYNom);
    CrearAbrirArchivoPosDNI(ArchPosDNI);
    CrearArbolApYNom(ArbolApYNom);
    CrearArbolDNI(ArbolDNI);
    CargarArbolApYNom(ArbolApYNom, ArchPosApYNom);
    CargarArbolDNI(ArbolDNI, ArchPosDNI);
  end;

procedure Cerrar(var ArchCon: TArchCon; var ArchInf: TArchInf; 
                 var ArchPosApYNom: TArchPosApYNom; var ArchPosDNI: TArchPosDNI);
  begin
    CerrarArchivoCon(ArchCon);
    CerrarArchivoInf(ArchInf);
    CerrarArchivoPosApYNom(ArchPosApYNom);
    CerrarArchivoPosDNI(ArchPosDNI);
  end;

procedure DeterminarCasoCon(var ArchCon: TArchCon; var ArchInf: TArchInf; var ArchPosApYNom: TArchPosApYNom;
                            var ArchPosDNI: TArchPosDNI; var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI; Caso: Byte);               
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
      begin
        AltaConductor(DatoIng, ArchCon, ArchPosApYNom, ArchPosDNI, ArbolApYNom, ArbolDNI, Caso);
        Write('¿Desea agregar una infracción? (s/N): ');
        ReadLn(Rta);
        ClrScr;
{        if LowerCase(Rta) = 's' then
          AltaInfraccion(ArchInf);}
      end;
    end
    else
    begin
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
        '1': ModificarCon(ConAux);
        '2': BajaCon(ConAux);
      end;}
    end;
  end;


procedure AltaConductor(DatoIngresado: String; var ArchCon: TArchCon; var ArchPosApYNom: TArchPosApYNom; var ArchPosDNI: TArchPosDNI; 
                        var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI; Caso: Byte);
  var
    DatosCon: TDatoConductores;
    PosArch: Word;
  begin
    // Guardar automáticamente el dato que se ingresa al consultar conductor, ingresar el que falta.
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

    // Obtener el resto de los datos del conductor.
    ObtenerFechaNac(DatosCon.FechaNac);
    DatosCon.Tel := ObtenerTel;
    DatosCon.EMail := ObtenerEMail;
    DatosCon.Scoring := 20;
    DatosCon.Habilitado := True;
    ObtenerFechaActual(DatosCon.FechaHab);
    DatosCon.CantRein := 0;
    DatosCon.BajaLogica := False;

    {TODO:  Mostrar datos ingresados
                Confirmar datos
                Modificar datos
                Cancelar
            Si confirma: WriteLn('Alta exitosa!');
                         Guardar Datos}

    // Guardar datos en el archivo de conductores
    PosArch := FileSIze(ArchCon);
    Seek(ArchCon, PosArch);
    Write(ArchCon, DatosCon);

    // Guardar posición de los datos del conductor
    GuardarPosApYNom(ArchPosApYNom, ArbolApYNom, DatosCon.ApYNom, PosArch);
    GuardarPosDNI(ArchPosDNI, ArbolDNI, DatosCon.DNI, PosArch);
  end;

procedure MostrarDatosCon(var DatosCon: TDatoConductores);
  begin
    with DatosCon do
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