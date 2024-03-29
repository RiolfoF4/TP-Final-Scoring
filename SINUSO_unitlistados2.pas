unit UnitListados2;
{$CODEPAGE UTF8}

interface

uses
  SysUtils, crt, UnitListaDinamica, UnitTypes, UnitArchivo, UnitPila;

const
  EncabTotalesCon = 4;
  EncabezadosCon: array[1..EncabTotalesCon] of ShortString = 
    ('NOMBRE Y APELLIDOS', 'DNI', 'SCORING', 'HABILITADO');

type
  TVectorEncab = array[1..10] of shortstring;
  TVectorInt = array[1..10] of integer;

procedure ListadoCon(var ArchCon: TArchCon; SoloNoHabilidatos: boolean);

implementation
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
  var ListaCon: TListaDin; var LenEncab: TVectorInt; var PosSep: TVectorInt);
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

  Primero(ListaCon);
  while not (Fin(ListaCon)) do
  begin
    // Determinar la longitud de la string más larga
    Recuperar(ListaCon, DatosCon);
    Siguiente(ListaCon);

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

procedure MostrarListadoCon(Encabezados: TVectorEncab; var ListaCon: TListaDin);
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
  Primero(ListaCon);
  OrdenAscendiente := True;
  i := 1;
  PosAnt := 1;
  Tecl := '';

  MostrarEncabezado(Encabezados);

  while (LowerCase(Tecl) <> 'q') do
  begin
    // Si no se llegó al final de la lista, muestra secuencialmente los datos
    if not Fin(ListaCon) then
    begin
      Recuperar(ListaCon, DatosCon);
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
      if OrdenAscendiente then
      begin
        Siguiente(ListaCon);
        Inc(i);
      end
      else
      begin
        Anterior(ListaCon);
        Dec(i);
      end;
    end;

    // Recibe una entrada del usuario si el texto supera un límite inferior
    // o supera el final de la lista
    if (WhereY > LimiteInferior) or Fin(ListaCon) then
    begin
      if OrdenAscendiente then
        CantCon := IntToStr(i - 1) + '/' + IntToStr(TamanioLista(ListaCon))
      else
        CantCon := IntToStr(TamanioLista(ListaCon) - i) + '/' + IntToStr(TamanioLista(ListaCon));
      WriteLn;
      Write('[S] Siguiente.');
      WriteLn(CantCon: PosSep[EncabTotalesCon] - WhereX + 1);
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
          if not Fin(ListaCon) then
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
      BuscarPos(ListaCon, i);
      ClrScr;
      MostrarEncabezado(Encabezados);
    end;
  end;
end;

procedure InicializarListaCon(var ArchCon: TArchCon; var ListaCon: TListaDin;
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
end;

procedure ListadoCon(var ArchCon: TArchCon; SoloNoHabilidatos: boolean);
var
  i: Word;
  Encab: TVectorEncab;
  ListaCon: TListaDin;
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
  EliminarLista(ListaCon);
end;
end.
