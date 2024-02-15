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
  //SetUseACP(True);
  ReadLn;
  WriteLn('áéóíú ññ ', Utf8ToAnsi('áéóíú ññ'), ' ', UTF8Decode('áéóíú ññ'));
  ReadLn;
end.

