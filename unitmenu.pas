unit UnitMenu;

interface
uses
  UnitArchivo;

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
    WriteLn('[1] Ingresar Nombre.');
    WriteLn('[2] Ingresar DNI');
    ReadLn(Op);
    Case Op of
      '1': 
    end;
    CerrarArchivoCon(ArchCon);
    CerrarArchivoInf(ArchInf);

  end;

end.