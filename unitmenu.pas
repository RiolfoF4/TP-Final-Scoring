unit UnitMenu;

interface
uses
  UnitArchivo, UnitPosiciones, Actividades;

procedure MostrarMenu;

implementation
procedure MostrarMenu;
  var
    ArchCon: TArchCon;
    ArchInf: TArchInf;
    ArchPosApYNom: TArchPosApYNom;
    ArchPosDNI: TArchPosDNI;
    ArbolApYNom: TPuntApYNom;
    ArbolDNI: TPuntDNI;
    Op: String[2];
  begin
    Inicializar(ArchCon, ArchInf, ArchPosApYNom, ArchPosDNI, ArbolApYNom, ArbolDNI);
    repeat
      WriteLn('[1] Ingresar Apellido y Nombre.');
      WriteLn('[2] Ingresar DNI.');
      WriteLn('[0] Salir.');
      ReadLn(Op);
      Case Op of
        '1': DeterminarCasoCon(ArchCon, ArchInf, ArchPosApYNom, ArchPosDNI, ArbolApYNom, ArbolDNI, 1);
        '2': DeterminarCasoCon(ArchCon, ArchInf, ArchPosApYNom, ArchPosDNI, ArbolApYNom, ArbolDNI, 2);
      end;
    until Op = '0';
    Cerrar(ArchCon, ArchInf, ArchPosApYNom, ArchPosDNI);
  end;
end.