unit UnitListados;
{$CODEPAGE UTF8}

interface

uses
  SysUtils, crt, UnitLista, UnitTypes, UnitArchivo, UnitPila;

const
  EncabTotalesCon = 4;
  EncabezadosCon: array[1..EncabTotalesCon] of ShortString = ('NOMBRE Y APELLIDOS', 'DNI', 'SCORING', 'HABILITADO');

type
  TVectorEncab = array[1..10] of shortstring;
  TVectorInt = array[1..10] of integer;

procedure ListadoCon(var ArchCon: TArchCon; SoloNoHabilidatos: boolean);

implementation

{function EsCadMayorAlf(Cad1, Cad2: string): boolean;
var
  i, Min: word;
begin
  Cad1 := LowerCase(Cad1);
  Cad2 := LowerCase(Cad2);
  if Length(Cad1) < Length(Cad2) then
    Min := Length(Cad1)
  else
    Min := Length(Cad2);

  i := 1;
  EsCadMayorAlf := False;

  while (i <= Min) and (not EsCadMayorAlf) do
    if Cad1[i] > Cad2[i] then
      EsCadMayorAlf := True
    else
    if Cad1[i] < Cad2[i] then
      i := Min + 1
    else
      Inc(I);
end;}

procedure Burbuja_ApYNom(var L: TListaDatosCon);
var
  i, j: word;
  Ant, Sig: TDatoConductores;
begin
  for i := 1 to TamanioLista(L) - 1 do
    for j := 1 to TamanioLista(L) - i do
    begin
      Recuperar(L, j, Ant);
      Recuperar(L, j + 1, Sig);
      if LowerCase(Ant.ApYNom) > LowerCase(Sig.ApYNom) then
      begin
        Modificar(L, j, Sig);
        Modificar(L, j + 1, Ant);
      end;
    end;
end;

procedure SeparadorEncabezado(Encabezados: TVectorEncab);
var
  i, j: word;
begin
  for i := 1 to EncabTotalesCon do
  begin
    Write('+');
    for j := 1 to Length(Encabezados[i]) do
      Write('=');
  end;
  WriteLn('+');
end;

procedure MostrarEncabezado(Encabezados: TVectorEncab);
var
  i: word;
begin
  SeparadorEncabezado(Encabezados);

  for i := 1 to EncabTotalesCon do
  begin
    Write('|');
    Write(Encabezados[i]);
  end;
  WriteLn('|');

  SeparadorEncabezado(Encabezados);
end;

procedure SeparadorLineas(PosSep: TVectorInt);
var
  i: word;
begin
  Write('+');

  while WhereX < PosSep[EncabTotalesCon] do
  begin
    Write('-');
    for i := 1 to EncabTotalesCon do
      if WhereX = PosSep[i] then
        Write('+');
  end;

  WriteLn;
end;

procedure InicializarListadoCon(var Encabezados: TVectorEncab;
  var ListaCon: TListaDatosCon; var LenEncab: TVectorInt; var PosSep: TVectorInt);
var
  i, j: word;
  DatosCon: TDatoConductores;
  LenAux: TVectorInt;
begin
  LenAux[2] := 8;   // DNI 12.345.678
  LenAux[3] := 2;   // Scoring <= 20
  LenAux[4] := 2;   // Habilitado Si / No

  for i := 1 to EncabTotalesCon do
    LenEncab[i] := Length(Encabezados[i]);

  for i := 1 to TamanioLista(ListaCon) do
  begin
    // Determinar la longitud de la string más larga
    Recuperar(ListaCon, i, DatosCon);

    LenAux[1] := Length(ansistring(DatosCon.ApYNom));

    for j := 1 to EncabTotalesCon do
      if LenEncab[j] < LenAux[j] then
        LenEncab[j] := LenAux[j];
  end;

  for i := 1 to EncabTotalesCon do
  begin
    // Agregar espacios a cada lado del encabezado hasta que su longitud sea mayor
    // que la string más larga
    Encabezados[i] := ' ' + Encabezados[i] + ' ';
    while Length(Encabezados[i]) < LenEncab[i] + 3 do
      Encabezados[i] := ' ' + Encabezados[i] + ' ';
    LenEncab[i] := Length(Encabezados[i]);

    // Calcular la posición de los separadores '|'
    if i = 1 then
      PosSep[i] := LenEncab[i] + 2
    else
      PosSep[i] := PosSep[i - 1] + LenEncab[i] + 1;
  end;
end;

procedure MostrarListadoCon(Encabezados: TVectorEncab; var ListaCon: TListaDatosCon);
const
  LimiteInferior = 14;
var
  PosAnterior: TPila;
  CantCon: string[7];
  i, Anterior: word;
  Tecl: string[2];
  DatosCon: TDatoConductores;
  LenEncab, PosSep: TVectorInt;
begin
  // Inicialización
  InicializarListadoCon(Encabezados, ListaCon, LenEncab, PosSep);
  CrearPila(PosAnterior);
  i := 1;
  Anterior := 1;
  Tecl := '';
  MostrarEncabezado(Encabezados);

  while (LowerCase(Tecl) <> 'q') do
  begin
    // Si no se llegó al final de la lista, muestra secuencialmente los datos
    if i <= TamanioLista(ListaCon) then
    begin
      Recuperar(ListaCon, i, DatosCon);
      with DatosCon do
      begin
        Write('|');
        SetUseACP(False);
        Write(ApYNom: ((LenEncab[1] + Length(ansistring(ApyNom))) div 2));
        SetUseACP(True);
        GotoXY(PosSep[1], WhereY);
        Write('|', DNI: ((LenEncab[2] + Length(UIntToStr(DNI))) div 2));
        GotoXY(PosSep[2], WhereY);
        Write('|', Scoring: ((LenEncab[3] + Length(IntToStr(Scoring))) div 2));
        GotoXY(PosSep[3], WhereY);
        Write('|');
        if Habilitado then
          Write('Si': ((LenEncab[4] + 2)) div 2)
        else
          Write('No': ((LenEncab[4] + 2)) div 2);
        GotoXY(PosSep[4], WhereY);
        WriteLn('|');
        SeparadorLineas(PosSep);
      end;
      Inc(i);
    end;

    // Recibe una entrada del usuario si el texto supera un límite inferior
    // o supera el final de la lista
    if (WhereY > LimiteInferior) or (i > TamanioLista(ListaCon)) then
    begin
      CantCon := IntToStr(i - 1) + '/' + IntToStr(TamanioLista(ListaCon));
      WriteLn;
      Write('[S] Siguiente.');
      WriteLn(CantCon: PosSep[EncabTotalesCon] - WhereX + 1);
      WriteLn('[A] Anterior.');
      WriteLn('[Q] Salir.');
      WriteLn;
      Write(UTF8Decode('Opción: '));
      ReadLn(Tecl);
      // s: Siguiente
      // a: Anterior
      case LowerCase(Tecl) of
        's':
          // Si NO se llegó al final de la lista, apila el índice del dato que se muestra actualmente
          // Si se llegó el final de la lista, muestra lo mismo
          if not (i > TamanioLista(ListaCon)) then
            Apilar(PosAnterior, Anterior)
          else
            i := Anterior;
        'a':
          // Si la pila contiene algún índice, lo desapila y lo guarda en el índice de la lista 'i'
          // Si la pila NO contiene ningún índice, se encuentra en la primera "página", y establece el índice de la
          // lista nuevamente en la posición 0
          if not (PilaVacia(PosAnterior)) then
            Desapilar(PosAnterior, i)
          else
            i := 1;
        else
          // Si la tecla no es 's' ni 'a', muestra lo mismo
          i := Anterior;
      end;
      Anterior := i;
      ClrScr;
      MostrarEncabezado(Encabezados);
    end;
  end;
end;

procedure InicializarListaCon(var ArchCon: TArchCon; var ListaCon: TListaDatosCon;
  SoloNoHabilidatos: boolean);
var
  DatosCon: TDatoConductores;
begin
  Seek(ArchCon, 0);
  while not (EOF(ArchCon)) do
  begin
    Read(ArchCon, DatosCon);
    if not DatosCon.BajaLogica then
      if not SoloNoHabilidatos then
        Agregar(ListaCon, DatosCon)
      else
      if DatosCon.Scoring = 0 then
        Agregar(ListaCon, DatosCon);
  end;
  if not ListaVacia(ListaCon) then
    Burbuja_ApYNom(ListaCon);
end;

procedure ListadoCon(var ArchCon: TArchCon; SoloNoHabilidatos: boolean);
var
  i: Word;
  Encab: TVectorEncab;
  ListaCon: TListaDatosCon;
begin
  for i := 1 to EncabTotalesCon do
    Encab[i] := EncabezadosCon[i];
  CrearLista(ListaCon);
  InicializarListaCon(ArchCon, ListaCon, SoloNoHabilidatos);

  if not ListaVacia(ListaCon) then
    MostrarListadoCon(Encab, ListaCon)
  else
  begin
    TextColor(Red);
    Write('¡No se encontraron conductores!');
    TextColor(White);
    Delay(1500);
  end;
end;

end.
