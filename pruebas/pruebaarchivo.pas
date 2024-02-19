program pruebaarchivo;

const
  Ruta = 'pruebaarch.dat';

type
  TArch = File of Char;

var
  LocalArch: TArch;
  Carac: Char;

procedure Eliminar(var Arch: TArch; Pos: word);
var
  i: word;
  xAux: Char;
begin
  // Pisa el lugar de Pos
  if Pos < FileSize(Arch) - 1 then
  begin
    for i := Pos + 1 to FileSize(Arch) - 1 do
    begin
      Seek(Arch, i);
      Read(Arch, xAux);
      Seek(Arch, i - 1);
      Write(Arch, xAux);
    end
  end;
  Seek((Arch), FileSize(Arch) - 1);
  Truncate(Arch);
end;

procedure MostrarArch(var Arch: TArch);
var
  i: Word;
begin
  Seek(LocalArch, 0);
  if FileSize(LocalArch) > 0 then
    for i := 1 to FileSize(LocalArch) do
    begin
      Read(LocalArch, Carac);
      Write(Carac, ' ');
    end;
  WriteLn;
end;

begin
  Assign(LocalArch, Ruta);
  Reset(LocalArch);
  MostrarArch(LocalArch);
  Eliminar(LocalArch, FileSize(LocalArch) - 1);
  MostrarArch(LocalArch);
end.