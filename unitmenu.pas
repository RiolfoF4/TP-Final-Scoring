unit UnitMenu;

interface
uses
  UnitArchivo, Actividades;

procedure MostrarMenu;

implementation
procedure MostrarMenu;
  var
    ArchCon: TArchCon;
    ArchInf: TArchInf;
    Op: String[2];
  begin
    CrearAbrirArchivoCon(ArchCon);
    CrearAbrirArchivoInf(ArchInf);
    repeat
      WriteLn('[1] Ingresar Apellido y Nombre.');
      WriteLn('[2] Ingresar DNI.');
      WriteLn('[0] Salir.');
      ReadLn(Op);
      Case Op of
        '1': DeterminarCasoCon(ArchCon, ArchInf, 1);
        '2': DeterminarCasoCon(ArchCon, ArchInf, 2);
      end;
    until Op = '0';
    CerrarArchivoCon(ArchCon);
    CerrarArchivoInf(ArchInf);
  end;
end.