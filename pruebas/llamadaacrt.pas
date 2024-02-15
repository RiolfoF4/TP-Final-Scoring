unit LlamadaACrt;

interface

uses
  crt;

function ObtenerNombre: String;
procedure MostrarNombre(Texto, Nombre: String);

implementation
function ObtenerNombre: String;
begin
  SetUseACP(False);
  Write('Nombre: ');
  ReadLn(ObtenerNombre);
  SetUseACP(True);
end;

procedure MostrarNombre(Texto, Nombre: String);
begin
  SetUseACP(False);
  Write(Texto, Nombre);
  SetUseACP(True);
end;
end.

