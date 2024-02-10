unit UnitArchivo;

interface
uses
  UnitTypes;

const
  RutaConductores = 'conductores.dat';
  RutaInfracciones = 'archivo\infracciones.dat';
  RutaListadoInfracciones = 'archivo\listado_infracciones.txt';
  RutaListadoInfraccionesBin = 'archivo\listado_infracciones.dat';

type
  TArchCon = file of TDatoConductores;
  TArchInf = file of TDatoInfracciones;
  TArchListInf = Text;
  
procedure CrearAbrirArchivoCon(var Arch: TArchCon);
procedure CerrarArchivoCon(var Arch: TArchCon);
procedure CrearAbrirArchivoInf(var Arch: TArchInf);
procedure CerrarArchivoInf(var Arch: TArchInf);
procedure CrearAbrirArchivoListInf(var Arch: TArchListInf);
procedure CerrarArchivoListInf(var Arch: TArchListInf);

implementation
procedure CrearAbrirArchivoCon(var Arch: TArchCon);  
begin
  Assign(Arch, RutaConductores);
    {$I-}
  Reset(Arch);
    {$I+}
  if IOResult <> 0 then
    Rewrite(Arch);
end;

procedure CerrarArchivoCon(var Arch: TArchCon);
begin
  Close(Arch);
end;

procedure CrearAbrirArchivoInf(var Arch: TArchInf);
begin
  Assign(Arch, RutaInfracciones);
    {$I-}
  Reset(Arch);
    {$I+}
  if IOResult <> 0 then
    Rewrite(Arch);
end;

procedure CerrarArchivoInf(var Arch: TArchInf);
begin
  Close(Arch);
end;

procedure CrearAbrirArchivoListInf(var Arch: TArchListInf);
begin
  Assign(Arch, RutaListadoInfracciones);
  Reset(Arch);
end;

procedure CerrarArchivoListInf(var Arch: TArchListInf);
begin
  Close(Arch);
end;
end.
