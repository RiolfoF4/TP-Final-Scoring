unit UnitArchivo;

interface
const
  RutaConductores = 'archivo\conductores.dat';
  RutaInfracciones = 'archivo\infracciones.dat';
  RutaListadoInfracciones = 'archivo\listado_infracciones.txt';
  RutaListadoInfraccionesBin = 'archivo\listado_infracciones.dat';

type
  TRegFecha = record
    Dia: Word;
    Mes: Word;
    Anio: Word;
  end;

  TDatoConductores = record
    DNI: Cardinal;
    ApYNom: String[50];
    FechaNac: TRegFecha;
    Tel: String[20];
    EMail: String[50];
    Scoring: ShortInt;
    Habilitado: Boolean;
    FechaHab: TRegFecha;
    CantRein: Byte;
    BajaLogica: Boolean;
  end;

  TDatoInfracciones = record
    DNI: Cardinal;
    Fecha: TRegFecha;
    Tipo: ShortString;
    Puntos: ShortInt;
  end;

  TArchCon = File of TDatoConductores;
  TArchInf = File of TDatoInfracciones;
  TArchListInf = Text;
  TArchBinListInf = File of ShortString;
  
procedure CrearAbrirArchivoCon(var Arch: TArchCon);
procedure CerrarArchivoCon(var Arch: TArchCon);
procedure CrearAbrirArchivoInf(var Arch: TArchInf);
procedure CerrarArchivoInf(var Arch: TArchInf);
procedure CrearAbrirArchivoListInf(var Arch: TArchListInf);
procedure CerrarArchivoListInf(var Arch: TArchListInf);
procedure CrearAbrirArchivoBinListInf(var Arch: TArchBinListInf);
procedure CerrarArchivoBinListInf(var Arch: TArchBinListInf);

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

procedure CrearAbrirArchivoBinListInf(var Arch: TArchBinListInf);
  begin
    Assign(Arch, RutaListadoInfraccionesBin);
    Rewrite(Arch);
  end;

procedure CerrarArchivoBinListInf(var Arch: TArchBinListInf);
  begin
    Close(Arch);
  end;
end.
