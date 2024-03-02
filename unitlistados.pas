unit UnitListados;
{$CODEPAGE UTF8}

interface

uses
  SysUtils, crt, UnitLista, UnitTypes, UnitArchivo, UnitPila, UnitManejoFecha, UnitObtenerDatos, UnitInfracciones;

const
  EncabTotalesCon = 4;
  EncabezadosCon: array[1..EncabTotalesCon] of AnsiString = ('NOMBRE Y APELLIDOS', 'DNI', 'SCORING', 'HABILITADO');
  
  EncabTotalesInf = 3;
  //EncabezadosInf: array[1..EncabTotalesInf] of AnsiString = ('DNI', 'INFRACCIÓN', 'FECHA', 'PUNTOS');
  EncabezadosInf: array[1..EncabTotalesInf] of AnsiString = ('INFRACCIÓN', 'FECHA', 'PUNTOS');

type
  TVectorEncab = array[1..10] of AnsiString;
  TVectorInt = array[1..10] of Integer;

procedure ListadoCon(var ArchCon: TArchCon; SoloNoHabilidatos: Boolean);
procedure ListadoInf(var ArchInf: TArchInf; ConductorEspecifico: Boolean);

implementation
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

procedure InicializarListadoInf(var Encabezados: TVectorEncab;
  var ListaInf: TListaDatosInf; var LenEncab: TVectorInt; var PosSep: TVectorInt);
var
  i: word;
  LenAux: TVectorInt;
begin
  {LenAux[1] := 8;   // DNI 12.345.678}
  LenAux[1] := 62;  // Tipo de Infracción
  LenAux[2] := 10;  // DD/MM/AAAA
  LenAux[3] := 2;   // Puntos

  for i := 1 to EncabTotalesInf do
    LenEncab[i] := LenAux[i];
    
  for i := 1 to EncabTotalesInf do
  begin
    // Agregar espacios a cada lado del encabezado hasta que su longitud sea mayor
    // que la string más larga
    Encabezados[i] := ' ' + Encabezados[i] + ' ';
    while Length(UTF8Decode(Encabezados[i])) < LenEncab[i] + 2 do
      Encabezados[i] := ' ' + Encabezados[i] + ' ';

    LenEncab[i] := Length(UTF8Decode(Encabezados[i]));

    // Calcular la posición de los separadores '|'
    if i = 1 then
      PosSep[i] := LenEncab[i] + 2
    else
      PosSep[i] := PosSep[i - 1] + LenEncab[i] + 1;
  end;
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

procedure SeparadorEncabezado(Encabezados: TVectorEncab; CantEncabezados: Byte);
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

procedure SeparadorLineas(PosSep: TVectorInt; CantEncabezados: Byte);
var
  i: word;
begin
  GotoXY(1, WhereY);
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

procedure SeparadorColumnas(PosSep: TVectorInt; EncabTotales: Byte);
var
  i: Word;
begin
  GotoXY(1, WhereY);
  Write('|');
  for i := 1 to EncabTotales do
  begin
    GotoXY(PosSep[i], WhereY);
    Write('|');
  end;

  WriteLn;
end;

procedure MostrarEncabezado(Encabezados: TVectorEncab; CantEncabezados: Byte);
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
  ClrScr;
  InicializarListadoCon(Encabezados, ListaCon, LenEncab, PosSep);
  CrearPila(PilaPosiciones);
  OrdenAscendiente := True;
  i := 1;
  PosAnt := 1;
  Tecl := '';

  MostrarEncabezado(Encabezados, EncabTotalesCon);

  while (LowerCase(Tecl) <> 'q') do
  begin
    // Si no se llegó al final de la lista, muestra secuencialmente los datos
    if (i > 0) and (i <= TamanioLista(ListaCon)) then
    begin
      Recuperar(ListaCon, i, DatosCon);
      with DatosCon do
      begin
        GotoXY(2, WhereY);
        SetUseACP(False);
        Write(ApYNom: ((LenEncab[1] + Length(ansistring(ApyNom))) div 2));
        SetUseACP(True);

        GotoXY(PosSep[1] + 1, WhereY);
        Write(DNI: ((LenEncab[2] + Length(UIntToStr(DNI))) div 2));
        
        GotoXY(PosSep[2] + 1, WhereY);
        Write(Scoring: ((LenEncab[3] + Length(IntToStr(Scoring))) div 2));
        
        GotoXY(PosSep[3] + 1, WhereY);
        if Habilitado then
          Write('Si': ((LenEncab[4] + 2)) div 2)
        else
          Write('No': ((LenEncab[4] + 2)) div 2);
        
        GotoXY(1, WhereY);
        SeparadorColumnas(PosSep, EncabTotalesCon);
        SeparadorLineas(PosSep, EncabTotalesCon);
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
      // o: Orden Ascendiente/Descendiente
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
      MostrarEncabezado(Encabezados, EncabTotalesCon);
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
  i: Byte;
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

procedure MostrarListadoInf(Encabezados: TVectorEncab; var ListaInf: TListaDatosInf);
const
  LimiteInferior = 13;
var
  PilaPosiciones: TPila;
  CantInf: string[7];
  i, PosAnt, PosY: word;
  Aux: Byte;
  OrdenAscendiente: Boolean;
  Tecl: string[2];
  DatosInf: TDatoInfracciones;
  LenEncab, PosSep: TVectorInt;
begin
  // Inicialización
  ClrScr;
  InicializarListadoInf(Encabezados, ListaInf, LenEncab, PosSep);
  CrearPila(PilaPosiciones);
  OrdenAscendiente := True;
  i := 1;
  PosAnt := 1;
  Tecl := '';

  MostrarEncabezado(Encabezados, EncabTotalesInf);

  while (LowerCase(Tecl) <> 'q') do
  begin
    // Si no se llegó al final de la lista, muestra secuencialmente los datos
    if (i > 0) and (i <= TamanioLista(ListaInf)) then
    begin
      Recuperar(ListaInf, i, DatosInf);
      PosY := WhereY;
      with DatosInf do
      begin
        // Mostrar infracciones con DNI
        {
        GotoXY(2, PosY);
        Write(DNI: ((LenEncab[1] + Length(UIntToStr(DNI))) div 2));
        
        
        GotoXY(PosSep[2] + 1, PosY);
        Write(FormatoFecha(Fecha.Dia, Fecha.Mes, Fecha.Anio): ((LenEncab[3] + 10)) div 2);
        
        GotoXY(PosSep[3] + 1, PosY);
        Write(Puntos: (LenEncab[4] + Length(IntToStr(Puntos))) div 2);

        MostrarInfraccion(Tipo, PosSep[1] + 2, PosSep[2] - 2);
        for Aux := PosY to WhereY - 1 do
        begin
          GotoXY(1, Aux);
          SeparadorColumnas(PosSep, EncabTotalesInf);
        end;
        }
        // Mostrar infracciones sin DNI
        
        GotoXY(PosSep[1] + 1, PosY);
        Write(FormatoFecha(Fecha.Dia, Fecha.Mes, Fecha.Anio): ((LenEncab[2] + 10)) div 2);
        
        GotoXY(PosSep[2] + 1, PosY);
        Write(Puntos: (LenEncab[3] + Length(IntToStr(Puntos))) div 2);

        MostrarInfraccion(Tipo, 4, PosSep[1] - 2);
        for Aux := PosY to WhereY - 1 do
        begin
          GotoXY(1, Aux);
          SeparadorColumnas(PosSep, EncabTotalesInf);
        end;
        
        SeparadorLineas(PosSep, EncabTotalesInf);
      end;
      if OrdenAscendiente then
        Inc(i)
      else
        Dec(i);
    end;

    // Recibe una entrada del usuario si el texto supera un límite inferior
    // o supera el final de la lista
    if (WhereY > LimiteInferior) or (i > TamanioLista(ListaInf)) or (i = 0) then
    begin
      if OrdenAscendiente then
        CantInf := IntToStr(i - 1) + '/' + IntToStr(TamanioLista(ListaInf))
      else
        CantInf := IntToStr(TamanioLista(ListaInf) - i) + '/' + IntToStr(TamanioLista(ListaInf));
      WriteLn;
      Write('[S] Siguiente.');
      WriteLn(CantInf: PosSep[EncabTotalesInf] - WhereX + 1);
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
      // o: Orden Ascendiente/Descendiente
      case LowerCase(Tecl) of
        's':
          // Si NO se llegó al final de la lista, apila el índice del dato que se muestra actualmente
          // Si se llegó el final de la lista, muestra lo mismo
          if not ((i > TamanioLista(ListaInf)) or (i = 0)) then
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
            i := TamanioLista(ListaInf);
        'o':
        begin
          OrdenAscendiente := not OrdenAscendiente;
          CrearPila(PilaPosiciones);
          if not OrdenAscendiente then
            i := TamanioLista(ListaInf)
          else
            i := 1;
        end;
      else
        // Si la tecla no es 's' ni 'a', muestra lo mismo
        i := PosAnt;
      end;
      PosAnt := i;
      ClrScr;
      MostrarEncabezado(Encabezados, EncabTotalesInf);
    end;
  end;
end;

procedure InicializarListaInf(var ArchInf: TArchInf; var ListaInf: TListaDatosInf; DNICon: Cardinal; Inicio, Fin: TRegFecha);
{ Recorre el archivo de infracciones y guarda las infracciones de un conductor, según DNICon, en una lista 
  desde la fecha Inicio hasta Fin (inclusive)
  Si DNICon es igual a 0 guarda todas las infracciones sin importar el conductor}
var
  Inf: TDatoInfracciones;
begin
  Seek(ArchInf, 0);
  if FileSize(ArchInf) > 0 then
  begin
    Read(ArchInf, Inf);
    // Mientras que la fecha de la infracción sea anterior a la fecha de inicio, o no sea fin de archivo, 
    // lee la siguiente infracción
    while EsFechaAnterior(Inf.Fecha.Dia, Inf.Fecha.Mes, Inf.Fecha.Anio, Inicio.Dia, Inicio.Mes, Inicio.Anio) and not EOF(ArchInf) do
      Read(ArchInf, Inf);
      
    // Si la última fecha leída es posterior o igual (NO anterior) a la fecha de inicio
    if not EsFechaAnterior(Inf.Fecha.Dia, Inf.Fecha.Mes, Inf.Fecha.Anio, Inicio.Dia, Inicio.Mes, Inicio.Anio) then
    begin
      Seek(ArchInf, FilePos(ArchInf) - 1);
      // Mientras que la fecha de la infracción sea anterior o igual (NO posterior) a la fecha de fin, 
      // o no sea fin de archivo, lee la siguiente infracción
      repeat
        Read(ArchInf, Inf);
        if not (EsFechaPosterior(Inf.Fecha.Dia, Inf.Fecha.Mes, Inf.Fecha.Anio, Fin.Dia, Fin.Mes, Fin.Anio) or
          ListaLlena(ListaInf)) then
          if DNICon = 0 then
            Agregar(ListaInf, Inf)
          else
          if DNICon = Inf.DNI then
            Agregar(ListaInf, Inf);
      until EsFechaPosterior(Inf.Fecha.Dia, Inf.Fecha.Mes, Inf.Fecha.Anio, Fin.Dia, Fin.Mes, Fin.Anio) or EOF(ArchInf);
    end;
  end;
end;

procedure ListadoInf(var ArchInf: TArchInf; ConductorEspecifico: Boolean);
var
  ListaInf: TListaDatosInf;
  Encab: TVectorEncab;
  i: Byte;
  DNICon: Cardinal;
  FechaInicio, FechaFin: TRegFecha;
begin
  for i := 1 to EncabTotalesInf do
    Encab[i] := EncabezadosInf[i];

  if ConductorEspecifico then
  begin
    DNICon := ObtenerDNI;
    WriteLn;
  end
  else
    DNICon := 0;

  ObtenerFechaInicioFin(FechaInicio, FechaFin);

  CrearLista(ListaInf);
  InicializarListaInf(ArchInf, ListaInf, DNICon, FechaInicio, FechaFin);
  ClrScr;
  if not ListaVacia(ListaInf) then
    MostrarListadoInf(Encab, ListaInf)
  else
  begin
    TextColor(Red);
    Write('¡No se encontraron infracciones!');
    TextColor(White);
    Delay(1500);
  end;
end;
end.
