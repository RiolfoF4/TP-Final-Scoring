program PruebaStr;

begin
  Write(UTF8Decode('Primera línea') + #13#10 + UTF8Decode('Segunda línea'), #13#10, UTF8Decode('Tercera línea'), #13#10);
  WriteLn(#13#10, #13#10, UTF8Decode('Dejando un espacio de dos líneas'));
  ReadLn;
end.