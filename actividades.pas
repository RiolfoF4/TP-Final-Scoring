unit Actividades;

interface

uses
  UnitArchivo;

procedure DeterminarCasoApYNom(var ArchCon: TArchCon; var ArchInf: TArchInf);
procedure DeterminarCasoDNI(var ArchCon: TArchCon; var ArchInf: TArchInf);

implementation
function ObtenerApYNom: String;
  begin
    
  end;

procedure DeterminarCasoApYNom(var ArchCon: TArchCon; var ArchInf: TArchInf);
  var
    ApYNom: String[50];
    Pos: Word;
  begin
    ApYNom := ObtenerApYNom;
    Pos := PosicionApYNom(ArbolApYNom, ApYNom);
    if Pos < 0 then
      AltaApYNom(ArchCon, ArchInf)
    else
      BMCApYNom(ArchCon, ArchInf);
  end;

procedure DeterminarCasoDNI(var ArchCon: TArchCon; var ArchInf: TArchInf);
  var
    DNI: Cardinal;
  begin
    
  end;
end.