unit UnitMenu;
{$CODEPAGE UTF8}

interface

uses
  crt, UnitArchivo, UnitPosiciones, Actividades, UnitListadosYEstadisticas;

procedure MostrarMenu;

implementation
procedure MostrarListados(var ArchCon: TArchCon; var ArchInf: TArchInf;
  var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);
var
  Op: String[2];
begin
  repeat
    ClrScr;
    WriteLn('[1] Listado de Conductores.');
    WriteLn('[2] Listado de Conductores con Scoring 0.');
    WriteLn;
    WriteLn('[3] Listado de Infracciones en un Período Determinado.');
    WriteLn('[4] Listado de Infracciones de un Conductor en un Período Determinado.');
    WriteLn;
    WriteLn('[0] Volver.');
    WriteLn;
    Write('Opción: ');
    ReadLn(Op);
    ClrScr;
    case Op of
      '1': ListadoCon(ArchCon, False);
      '2': ListadoCon(ArchCon, True);
      '3': ListadoInf(ArchCon, ArchInf, ArbolDNI, False);
      '4': ListadoInf(ArchCon, ArchInf, ArbolDNI, True);
    end;
  until Op = '0';
end;

procedure MostrarEstadisticas(var ArchCon: TArchCon; var ArchInf: TArchInf;
  var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);
var
  Op: String[2];
begin
  repeat
    ClrScr;
    WriteLn('[1] Cantidad de Infracciones en un Período Determinado.');
    WriteLn('[2] Porcentaje de Conductores con Reincidencia.');
    WriteLn('[3] Porcentaje de Conductores con Scoring 0.');
    WriteLn('[4] Porcentaje de Conductores Sin Infracciones.');
    WriteLn('[5] Rango Etario con más Infracciones.');
    WriteLn;
    WriteLn('[0] Volver.');
    WriteLn;
    Write('Opción: ');
    ReadLn(Op);
    ClrScr;
    case Op of
      '1': EstCantInf(ArchCon, ArchInf, ArbolDNI);
      '2': EstPorcenRein(ArchCon);
      '3': EstPorcenNoHab(ArchCon);
      '4': EstTotalSinInf(ArchCon);
      '5': EstRangoEtario(ArchCon, ArchInf, ArbolDNI);
    end;
  until Op = '0'; 
end;

procedure MostrarMenu;
var
  ArchCon: TArchCon;
  ArchInf: TArchInf;
  ArbolApYNom: TPuntApYNom;
  ArbolDNI: TPuntDNI;
  Op: String[2];
begin
  Inicializar(ArchCon, ArchInf, ArbolApYNom, ArbolDNI);
  repeat
    ClrScr;
    WriteLn('[1] Ingresar Apellido y Nombres.');
    WriteLn('[2] Ingresar DNI.');
    WriteLn;
    WriteLn('[3] Listados.');
    WriteLn(UTF8Decode('[4] Estadísticas.'));
    WriteLn;
    WriteLn('[0] Salir.');
    WriteLn;
    Write('Opción: ');
    ReadLn(Op);
    ClrScr;
    case Op of
      '1': DeterminarCasoCon(ArchCon, ArchInf, ArbolApYNom, ArbolDNI, 'apynom');
      '2': DeterminarCasoCon(ArchCon, ArchInf, ArbolApYNom, ArbolDNI, 'dni');
      '3': MostrarListados(ArchCon, ArchInf, ArbolApYNom, ArbolDNI);
      '4': MostrarEstadisticas(ArchCon, ArchInf, ArbolApYNom, ArbolDNI);
    end;
  until Op = '0';
  Cerrar(ArchCon, ArchInf);
end;

end.
