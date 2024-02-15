program pruebastr;
{$CODEPAGE UTF8}


uses
  crt, windows, LazUtils, LazUTF8;

var
  s: String;

begin
  SetSafeCPSwitching(false);
  SetUseACP(False);
  ReadLn(s);
  WriteLn('s: ', s);
  SetUseACP(True);
  ReadLn;
  WriteLn('áéóíú ññ ');
  ReadLn;
end.

