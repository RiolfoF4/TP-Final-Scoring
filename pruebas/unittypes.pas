unit UnitTypes;

interface

type
  TRegFecha = record
    Dia: word;
    Mes: word;
    Anio: word;
  end;

  TDatoConductores = record
    DNI: cardinal;
    ApYNom: string[50];
    FechaNac: TRegFecha;
    Tel: string[20];
    EMail: string[50];
    Scoring: shortint;
    Habilitado: boolean;
    FechaHab: TRegFecha;
    CantRein: byte;
    BajaLogica: boolean;
  end;

  TDatoInfracciones = record
    DNI: cardinal;
    Fecha: TRegFecha;
    Tipo: shortstring;
    Puntos: shortint;
  end;


implementation

end.
