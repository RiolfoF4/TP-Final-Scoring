unit Actividades;
{$CODEPAGE UTF8}

interface

uses
  SysUtils, crt, UnitArchivo, UnitConductores, UnitPosiciones,
  UnitManejoFecha, UnitObtenerDatos, UnitTypes;

const
  EsqX = 15;
  EsqY = 5;

procedure Inicializar(var ArchCon: TArchCon; var ArchInf: TArchInf; var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);
procedure Cerrar(var ArchCon: TArchCon; var ArchInf: TArchInf);
procedure DeterminarCasoCon(var ArchCon: TArchCon; var ArchInf: TArchInf;
  var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI; Caso: shortstring);
// Caso 'apynom': Ingresa Apellido y Nombres;  Caso 'dni': Ingresa DNI


implementation
procedure CargarArbolPos(var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI; var ArchCon: TArchCon);
var
  xPosApYNom: TDatoPosApYNom;
  xPosDNI: TDatoPosDNI;
  xAuxCon: TDatoConductores;
begin
  Seek(ArchCon, 0);
  // Recorrer el archivo de conductores hasta el final, o hasta que el árbol este lleno
  while not (EOF(ArchCon)) and not ((ArbolLlenoApYNom(ArbolApYNom)) or ArbolLlenoDNI(ArbolDNI)) do
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

procedure MostrarLineaHorizontal(X1, Y1, X2: Word);
var
  X: word;
begin
  // Muestra una línea horizontal '+----...----+' desde (X1, Y1) hasta (X2, Y1)
  GotoXY(X1, Y1);
  Write('+');
  for X := X1 + 1 to X2 - 1  do
    Write('-');
  WriteLn('+');
end;

procedure MostrarLineaVertical(X1, Y1, Y2: Word);
var
  Y: word;
begin
  // Muesta una línea vertical '| ... |' desde (X1, Y1) hasta (X1, Y2)
  for Y := Y1 to Y2 do
  begin
    GotoXY(X1, Y);
    Write('|');
  end;
end;

procedure MostrarMarco;
{ Crea un marco alrededor de Window, dejando EspX y EspY de margen}
const
  EspX = 4;
  EspY = 2;
var
  MinX, MaxX: word;
  MinY, MaxY: word;
begin
  MinX := EsqX - EspX;
  MaxX := WindMaxX - EsqX + EspX;
  MinY := EsqY - EspY;
  MaxY := WindMaxY - EsqY + EspY;

  MostrarLineaHorizontal(MinX, MinY, MaxX);

  MostrarLineaVertical(MinX, MinY + 1, MaxY - 1);
  MostrarLineaVertical(MaxX, MinY + 1, MaxY - 1);

  MostrarLineaHorizontal(MinX, MaxY, MaxX);
end;

procedure Inicializar(var ArchCon: TArchCon; var ArchInf: TArchInf; var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);
begin
  SetSafeCPSwitching(False);
  ClrScr;
  MostrarMarco;
  Window(EsqX, EsqY, WindMaxX - EsqX, WindMaxY - EsqY);
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
