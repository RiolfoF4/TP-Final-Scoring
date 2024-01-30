unit UnitMenu;
{$CODEPAGE UTF8}

interface
uses
  crt, UnitArchivo, UnitPosiciones, Actividades;

procedure MostrarMenu;

implementation
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
    WriteLn('[0] Salir.');
    WriteLn;
    Write('Opción: ');
    ReadLn(Op);
    ClrScr;
    case Op of
      '1': DeterminarCasoCon(ArchCon, ArchInf, ArbolApYNom, ArbolDNI, 1);
      '2': DeterminarCasoCon(ArchCon, ArchInf, ArbolApYNom, ArbolDNI, 2);
    end;
  until Op = '0';
  Cerrar(ArchCon, ArchInf);
end;
end.
