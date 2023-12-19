unit Actividades;

interface

uses
  sysutils, UnitArchivo, UnitValidacion;

// Caso 1: Ingresa ApYNom  Caso 2: Ingresa DNI}
procedure DeterminarCasoCon(var ArchCon: TArchCon; var ArchInf: TArchInf; Caso: Byte);
procedure AltaConductor(var ArchCon: TArchCon);                      

implementation
function ObtenerApYNom: String;
  begin
    ObtenerApYNom := '';
    while ObtenerApYNom = '' do
    begin
      Write('Apellido y Nombre: ');
      ReadLn(ObtenerApYNom);
    end;
  end;

function ObtenerDNI: Cardinal;
  var
    Cad: String[10];
  begin
    ObtenerDNI := 0;
    while (ObtenerDNI < 1000000) do
    begin
      Write('DNI: ');
      ReadLn(Cad);
      if EsNum(Cad) then
        ObtenerDNI := StrToDWord(Cad);
    end;
  end;

function ObtenerTel: Cardinal;
  var
    Cad: String[12];
  begin
    ObtenerTel := 0;
    while ObtenerTel = 0 do
    begin
      Write('Teléfono (Sin prefijo internacional ni espacios): ');
      ReadLn(Cad);
      if EsNum(Cad) then
        ObtenerTel := StrToDWord(Cad);
    end;
  end;

function ObtenerEMail: String;
  var
    Cad: String;
  begin
    ObtenerEMail := '';
    while ObtenerEMail = '' do
    begin
      Write('EMail: ');
      ReadLn(Cad);
      if EsEMail(Cad) then
        ObtenerEMail := Cad;
    end;
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
        Write('Año: ');
        ReadLn(Anyo);
        Write('Mes: ');
        ReadLn(Mes);
        Write('Día: ');
        ReadLn(Dia);
        FechaValida := EsFecha(Anio, Mes, Dia);
      end;
  end;

procedure DeterminarCasoCon(var ArchCon: TArchCon; var ArchInf: TArchInf; Caso: Byte);
  var
    ApYNom: String[50];
    DNI: Cardinal;
    Pos: Word;
    Rta: String[2];
    ConAux: TDatoConductores;
  begin
    if Caso = 1 then
    begin
      ApYNom := ObtenerApYNom;
      Pos := PosicionApYNom(ArbolApYNom, ApYNom);
    end
    else
    begin
      DNI := ObtenerDNI;
      Pos := PosicionDNI(ArbolDNI, DNI);
    end;
    if Pos < 0 then
    begin
      WriteLn('No se encontró el conductor ingresado!');
      Write('¿Desea darlo de Alta? (s/N): ');
      ReadLn(Rta);
      if LowerCase(Rta) = 's' then
      begin
        AltaConductor(ArchCon);
        Write('¿Desea agregar una infracción? (s/N): ');
        ReadLn(Rta);
        if LowerCase(Rta) = 's' then
          AltaInfraccion(ArchInf);
      end;
    end
    else
    begin
      Seek(ArchCon, Pos);
      Read(ArchCon, ConAux);
      MostrarDatosCon(ConAux);
      WriteLn('[1] Modificar Datos.');
      WriteLn('[2] Dar de Baja.');
      WriteLn('[0] Volver.');
      ReadLn(Rta);
      case Rta of
        '1': ModificarCon(ConAux);
        '2': BajaCon(ConAux);
      end;
    end;
  end;

procedure AltaConductor(var ArchCon: TArchCon);
  var
    DatosCon: TDatoConductores;
  begin
    DatosCon.DNI := ObtenerDNI;
    DatosCon.ApYNom := ObtenerApYNom;
    ObtenerFechaNac(DatosCon.FechaNac);
    DatosCon.Tel := ObtenerTel;
    DatosCon.EMail := ObtenerEMail;
    DatosCon.Scoring := 20;
    DatosCon.Habilitado := True;
    ObtenerFechaActual(DatosCon.FechaHab);
    DatosCon.CantRein := 0;
    DatosCon.Estado := True;
    SeekEOF(ArchCon);
    Write(ArchCon, DatosCon);
    {Agregar al árbol}
  end;
end.