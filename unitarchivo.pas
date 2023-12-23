unit UnitArchivo;

interface
const
  RutaConductores = 'archivo\conductores.dat';
  RutaInfracciones = 'archivo\infracciones.dat';
  RutaPosicionesApYNom = 'archivo\posicionesapynom.dat';
  RutaPosicionesDNI = 'archivo\posicionesdni.dat';

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
    Estado: Boolean;
  end;

  TDatoInfracciones = record
    DNI: Cardinal;
    Fecha: TRegFecha;
    Tipo: Byte;
    Puntos: ShortInt;
  end;

  TDatoPosApYNom = record
    ApYNom: String[100];
    Pos: Word;
  end;

  TDatoPosDNI = record
    DNI: Cardinal;
    Pos: Word;
  end;

  TArchCon = File of TDatoConductores;
  TArchInf = File of TDatoInfracciones;
  TArchPosApYNom = File of TDatoPosApYNom;
  TArchPosDNI = File of TDatoPosDNI;
  
procedure CrearAbrirArchivoCon(var Arch: TArchCon);
procedure CerrarArchivoCon(var Arch: TArchCon);
procedure CrearAbrirArchivoInf(var Arch: TArchInf);
procedure CerrarArchivoInf(var Arch: TArchInf);
procedure CrearAbrirArchivoPosApYNom(var Arch: TArchPosApYNom);
procedure CerrarArchivoPosApYNom(var Arch: TArchPosApYNom);
procedure CrearAbrirArchivoPosDNI(var Arch: TArchPosDNI);
procedure CerrarArchivoPosDNI(var Arch: TArchPosDNI);

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

procedure CrearAbrirArchivoPosApYNom(var Arch: TArchPosApYNom);  
  begin
    Assign(Arch, RutaPosicionesApYNom);
    {$I-}
    Reset(Arch);
    {$I+}
    if IOResult <> 0 then
      Rewrite(Arch);
  end;

procedure CerrarArchivoPosApYNom(var Arch: TArchPosApYNom);
  begin
    Close(Arch);
  end;

procedure CrearAbrirArchivoPosDNI(var Arch: TArchPosDNI);  
  begin
    Assign(Arch, RutaPosicionesDNI);
    {$I-}
    Reset(Arch);
    {$I+}
    if IOResult <> 0 then
      Rewrite(Arch);
  end;

procedure CerrarArchivoPosDNI(var Arch: TArchPosDNI);
  begin
    Close(Arch);
  end;
end.