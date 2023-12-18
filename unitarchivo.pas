unit UnitArchivo;

interface
const
  RutaConductores = 'archivo\conductores.dat';
  RutaInfracciones = 'archivo\infracciones.dat';

type
  TRegFecha = record
    Dia: Byte;
    Mes: Byte;
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
  end;

  TDatoInfracciones = record
    DNI: Cardinal;
    Fecha: TRegFecha;
    Tipo: Byte;
    Puntos: ShortInt;
  end;

  TArchCon = File of TDatoConductores;
  TArchInf = File of TDatoInfracciones;

procedure CrearAbrirArchivoCon(var Arch: TArchCon);
procedure CerrarArchivoCon(var Arch: TArchCon);
procedure CrearAbrirArchivoInf(var Arch: TArchInf);
procedure CerrarArchivoInf(var Arch: TArchInf);

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
end.