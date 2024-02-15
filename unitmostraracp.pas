unit UnitMostrarACP;
{$CODEPAGE UTF8}

interface

uses
  crt;

procedure Mostrar(s: string);
procedure Mostrar(Texto: shortstring; s: string);
procedure MostrarLn(s: string);
procedure MostrarLn(Texto: shortstring; s: string);

implementation

procedure Mostrar(s: string);
begin
  SetUseACP(False);
  Write(s);
  SetUseACP(True);
end;

procedure Mostrar(Texto: shortstring; s: string);
begin
  Write(Texto);
  SetUseACP(False);
  Write(s);
  SetUseACP(True);
end;

procedure MostrarLn(s: string);
begin
  SetUseACP(False);
  WriteLn(s);
  SetUseACP(True);
end;

procedure MostrarLn(Texto: shortstring; s: string);
begin
  Write(Texto);
  SetUseACP(False);
  WriteLn(s);
  SetUseACP(True);
end;

end.
