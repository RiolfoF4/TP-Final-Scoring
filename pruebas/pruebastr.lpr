program pruebastr;
{$CODEPAGE UTF8}

uses
  crt, windows, LazUtils, LazUTF8;

var
  s: String;
  r: record
    str: String;
    num: Byte;
  end;

begin
  SetSafeCPSwitching(False);
  SetUseACP(False);
  ReadLn(s);
  WriteLn('s: ', s);
  SetUseACP(True);
  r.str := 'áéíóú';
  WriteLn;
  WriteLn('r.str: ', r.str);
  ReadLn;
  WriteLn('áéóíú ññ ¿? ¡!');
  ReadLn;
end.

