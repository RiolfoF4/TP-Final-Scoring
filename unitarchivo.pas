unit UnitArchivo;

interface

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

implementation
end.