unit UnitTypes;

interface
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


implementation
end.
