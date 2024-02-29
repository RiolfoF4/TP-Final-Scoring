unit UnitListados;
{$CODEPAGE UTF8}

interface

uses
  SysUtils, crt, UnitLista, UnitTypes, UnitArchivo, UnitPila;

const
  CantEncabezadosCon = 4;
  EncabezadosCon: array[1..CantEncabezadosCon] of ShortString = ('NOMBRE Y APELLIDOS', 'DNI', 'SCORING', 'HABILITADO');

type
  TVectorEncab = array[1..10] of ShortString;
  TVectorInt = array[1..10] of Integer;

procedure ListadoCon(var ArchCon: TArchCon; SoloNoHabilidatos: Boolean);
procedure ListadoInf(var ArchInf: TArchInf; ConductorEspecifico: Boolean);

implementation
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

procedure SeparadorEncabezado(Encabezados: TVectorEncab; CantEncabezados: Word);
var
  i, j: word;
begin
  for i := 1 to CantEncabezados do
  begin
    Write('+');
    for j := 1 to Length(Encabezados[i]) do
      Write('=');
  end;
  WriteLn('+');
end;

procedure MostrarEncabezado(Encabezados: TVectorEncab; CantEncabezados: Word);
var
  i: word;
begin
  SeparadorEncabezado(Encabezados, CantEncabezados);

  for i := 1 to CantEncabezados do
  begin
    Write('|');
    Write(Encabezados[i]);
  end;
  WriteLn('|');

  SeparadorEncabezado(Encabezados, CantEncabezados);
end;

procedure SeparadorLineas(PosSep: TVectorInt; CantEncabezados: Word);
var
  i: word;
begin
  Write('+');

  while WhereX < PosSep[CantEncabezados] do
  begin
    Write('-');
    for i := 1 to CantEncabezados do
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

  for i := 1 to CantEncabezadosCon do
    LenEncab[i] := Length(Encabezados[i]);

  for i := 1 to TamanioLista(ListaCon) do
  begin
    // Determinar la longitud de la string más larga
    Recuperar(ListaCon, i, DatosCon);

    LenAux[1] := Length(ansistring(DatosCon.ApYNom));

    for j := 1 to CantEncabezadosCon do
      if LenEncab[j] < LenAux[j] then
        LenEncab[j] := LenAux[j];
  end;

  for i := 1 to CantEncabezadosCon do
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
  LimiteInferior = 12;
var
  PilaPosiciones: TPila;
  CantCon: string[7];
  i, PosAnt: word;
  OrdenAscendiente: Boolean;
  Tecl: string[2];
  DatosCon: TDatoConductores;
  LenEncab, PosSep: TVectorInt;
begin
  // Inicialización
  InicializarListadoCon(Encabezados, ListaCon, LenEncab, PosSep);
  CrearPila(PilaPosiciones);
  OrdenAscendiente := True;
  i := 1;
  PosAnt := 1;
  Tecl := '';

  MostrarEncabezado(Encabezados, CantEncabezadosCon);

  while (LowerCase(Tecl) <> 'q') do
  begin
    // Si no se llegó al final de la lista, muestra secuencialmente los datos
    if (i > 0) and (i <= TamanioLista(ListaCon)) then
    begin
      Recuperar(ListaCon, i,  DatosCon);
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
        SeparadorLineas(PosSep, CantEncabezadosCon);
      end;
      if OrdenAscendiente then
        Inc(i)
      else
        Dec(i);
    end;

    // Recibe una entrada del usuario si el texto supera un límite inferior
    // o supera el final de la lista
    if (WhereY > LimiteInferior) or (i > TamanioLista(ListaCon)) or (i = 0) then
    begin
      if OrdenAscendiente then
        CantCon := IntToStr(i - 1) + '/' + IntToStr(TamanioLista(ListaCon))
      else
        CantCon := IntToStr(TamanioLista(ListaCon) - i) + '/' + IntToStr(TamanioLista(ListaCon));
      WriteLn;
      Write('[S] Siguiente.');
      WriteLn(CantCon: PosSep[CantEncabezadosCon] - WhereX + 1);
      WriteLn('[A] Anterior.');
      Write('[O] Orden ');
      if OrdenAscendiente then
        WriteLn('Descendiente.')
      else
        WriteLn('Ascendiente.');
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
          if not ((i > TamanioLista(ListaCon)) or (i = 0)) then
            Apilar(PilaPosiciones, PosAnt)
          else
            i := PosAnt;
        'a':
          // Si la pila contiene algún índice, lo desapila y lo guarda en el índice de la lista 'i'
          // Si la pila NO contiene ningún índice, se encuentra en la primera "página", y establece el índice de la
          // lista nuevamente en la posición 0
          if not (PilaVacia(PilaPosiciones)) then
            Desapilar(PilaPosiciones, i)
          else
          if OrdenAscendiente then
            i := 1
          else
            i := TamanioLista(ListaCon);
        'o':
        begin
          OrdenAscendiente := not OrdenAscendiente;
          CrearPila(PilaPosiciones);
          if not OrdenAscendiente then
            i := TamanioLista(ListaCon)
          else
            i := 1;
        end;
      else
        // Si la tecla no es 's' ni 'a', muestra lo mismo
        i := PosAnt;
      end;
      PosAnt := i;
      ClrScr;
      MostrarEncabezado(Encabezados, CantEncabezadosCon);
    end;
  end;
end;

procedure ListadoCon(var ArchCon: TArchCon; SoloNoHabilidatos: boolean);
var
  i: Word;
  Encab: TVectorEncab;
  ListaCon: TListaDatosCon;
begin
  for i := 1 to CantEncabezadosCon do
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


procedure ListadoInf(var ArchInf: TArchInf; ConductorEspecifico: Boolean);
begin
  
end;
end.
