unit UnitMenu;
{$CODEPAGE UTF8}

interface

uses
  crt, UnitArchivo, UnitPosiciones, Actividades, UnitListados;

procedure MostrarMenu;

implementation

procedure MostrarListados(var ArchCon: TArchCon; var ArchInf: TArchInf;
  var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI) forward;

procedure MostrarMenu;
var
  ArchCon: TArchCon;
  ArchInf: TArchInf;
  ArbolApYNom: TPuntApYNom;
  ArbolDNI: TPuntDNI;
  Op: string[2];
begin
  Inicializar(ArchCon, ArchInf, ArbolApYNom, ArbolDNI);
  repeat
    ClrScr;
    WriteLn('[1] Ingresar Apellido y Nombres.');
    WriteLn('[2] Ingresar DNI.');
    WriteLn;
    WriteLn('[3] Listados.');
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
    end;
  until Op = '0';
  Cerrar(ArchCon, ArchInf);
end;

procedure MostrarListados(var ArchCon: TArchCon; var ArchInf: TArchInf;
  var ArbolApYNom: TPuntApYNom; var ArbolDNI: TPuntDNI);
var
  Op: string[2];
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
    end;
  until Op = '0';
end;

end.
