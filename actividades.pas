unit Actividades;
{$CODEPAGE UTF8}

interface

uses
  SysUtils, crt, UnitArchivo, UnitConductores, UnitPosiciones,
  UnitManejoFecha, UnitObtenerDatos, UnitTypes;

const
  EsqX = 15;
  EsqY = 5;

procedure Inicializar(var ArchCon: TArchCon; var ArchInf: TArchInf;
  var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);
procedure Cerrar(var ArchCon: TArchCon; var ArchInf: TArchInf);
procedure DeterminarCasoCon(var ArchCon: TArchCon; var ArchInf: TArchInf;
  var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI; Caso: shortstring);
  // Caso 1: Ingresa ApYNom  Caso 2: Ingresa DNI


implementation

procedure CargarArbolPos(var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI;
  var ArchCon: TArchCon);
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

procedure ComprobarInhabilitaciones(var ArchCon: TArchCon);
var
  FechaActual: TRegFecha;
  xAux: TDatoConductores;
begin
  // Guarda la fecha de hoy
  ObtenerFechaActual(FechaActual);

  Seek(ArchCon, 0);
  while not (EOF(ArchCon)) do
  begin
    Read(ArchCon, xAux);
    if not (xAux.Habilitado) then
      with xAux do
        // Si la fecha de habilitación NO es posterior a la fecha actual (es anterior o igual)
        if not (EsFechaPosterior(FechaHab.Dia, FechaHab.Mes, FechaHab.Anio,
          FechaActual.Dia, FechaActual.Mes, FechaActual.Anio)) then
        begin
          xAux.Habilitado := True;
          xAux.Scoring := 20;
          Seek(ArchCon, FilePos(ArchCon) - 1);
          Write(ArchCon, xAux);
        end;
  end;
end;

procedure Inicializar(var ArchCon: TArchCon; var ArchInf: TArchInf;
  var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);
begin
  SetSafeCPSwitching(False);
  ClrScr;
  Window(EsqX, EsqY, WindMaxX - EsqX, WindMaxY);
  TextColor(White);
  CrearAbrirArchivoCon(ArchCon);
  CrearAbrirArchivoInf(ArchInf);
  CrearArbolApYNom(ArbolApYNom);
  CrearArbolDNI(ArbolDNI);
  CargarArbolPos(ArbolApYNom, ArbolDNI, ArchCon);
  ComprobarInhabilitaciones(ArchCon);
end;

procedure Cerrar(var ArchCon: TArchCon; var ArchInf: TArchInf);
begin
  CerrarArchivoCon(ArchCon);
  CerrarArchivoInf(ArchInf);
end;

procedure DeterminarCasoCon(var ArchCon: TArchCon; var ArchInf: TArchInf;
  var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI; Caso: shortstring);

var
  ApYNom: string[50];
  DNI: cardinal;
  Pos: longint;
  DatoIng: string[50];
begin
  if LowerCase(Caso) = 'apynom' then
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
    ConsultaConductor(ArchCon, Pos, ArchInf, ArbolApYNom, ArbolDNI);
end;

end.
