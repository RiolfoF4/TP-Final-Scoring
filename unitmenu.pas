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
    {PosX, PosY: Word;}
  begin
    Inicializar(ArchCon, ArchInf, ArbolApYNom, ArbolDNI);
    repeat
      ClrScr;
      {PosX := EsqX; PosY := EsqY;}
      {GotoXY(PosX, PosY);}
      WriteLn('[1] Ingresar Apellido y Nombre.');
      {PosY += 1; GotoXY(PosX, PosY);}
      WriteLn('[2] Ingresar DNI.');
      {PosY += 1; GotoXY(PosX, PosY);}
      WriteLn('[0] Salir.');
      {PosY += 2; GotoXY(PosX, PosY);}
      WriteLn;
      Write('Opción: ');
      ReadLn(Op);
      ClrScr;
      Case Op of
        '1': DeterminarCasoCon(ArchCon, ArchInf, ArbolApYNom, ArbolDNI, 1);
        '2': DeterminarCasoCon(ArchCon, ArchInf, ArbolApYNom, ArbolDNI, 2);
      end;
    until Op = '0';
    Cerrar(ArchCon, ArchInf);
  end;
end.