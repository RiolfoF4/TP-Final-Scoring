unit Actividades;

interface

uses
  sysutils, UnitArchivo, UnitValidacion;

// Caso 1: Ingresa ApYNom  Caso 2: Ingresa DNI}
procedure DeterminarCaso(var ArchCon: TArchCon; var ArchInf: TArchInf; Caso: Byte);
procedure AltaConductor(var ArchCon);                      

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
    while ObtenerTel <= 0 do
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

procedure DeterminarCaso(var ArchCon: TArchCon; var ArchInf: TArchInf; Caso: Byte);
  var
    ApYNom: String[50];
    DNI: Cardinal;
    Pos: Word;
    Rta: String[2];
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
        AltaConductor(ArchCon);
    end;
  end;

procedure AltaConductor(var ArchCon);
  var
    DatosCon: TDatoConductores;
  begin
    DatosCon.DNI := ObtenerDNI;
    DatosCon.ApYNom := ObtenerApYNom;
    DatosCon.FechaNac := ObtenerFechaNac;
    DatosCon.Tel := ObtenerTel;
    DatosCon.EMail := ObtenerEMail;
    DatosCon.Scoring := 20;
    DatosCon.Habilitado := True;
    DatosCon.FechaHab := ObtenerFecha;
    DatosCon.CantRein := 0;
    DatosCon.Estado := True;
    SeekEOF(ArchCon);
    Write(ArchCon, DatosCon);
  end;
end.