unit UnitListadosYEstadisticas;
{$CODEPAGE UTF8}

interface

uses
  SysUtils, crt, UnitLista, UnitTypes, UnitArchivo, UnitPila, UnitManejoFecha, UnitObtenerDatos, UnitInfracciones,
  UnitPosiciones;

const
  EncabTotalesCon = 4;
  EncabezadosCon: array[1..EncabTotalesCon] of AnsiString = ('NOMBRE Y APELLIDOS', 'DNI', 'SCORING', 'HABILITADO');
  
  EncabTotalesInf = 4;
  EncabezadosInf: array[1..EncabTotalesInf] of AnsiString = ('DNI', 'INFRACCIÓN', 'FECHA', 'PUNTOS');
  //EncabezadosInf: array[1..EncabTotalesInf] of AnsiString = ('INFRACCIÓN', 'FECHA', 'PUNTOS');

  RangosEtariosTotales = 3;
  RangosEtarios: array[1..RangosEtariosTotales] of Integer = (51, 31, 0);
  {Establece la edad mínima de los rangos etarios, en años: +51, 50-31, 31-0.
  El primer rango etario siempre es "mayor a"}

type
  TVectorEncab = array[1..10] of AnsiString;
  TVectorInt = array[1..10] of Integer;

procedure ListadoCon(var ArchCon: TArchCon; SoloNoHabilidatos: Boolean);
procedure ListadoInf(var ArchCon: TArchCon; var ArchInf: TArchInf; var ArbolDNI: TPuntDNI; ConductorEspecifico: Boolean);

procedure EstCantInf(var ArchCon: TArchCon; var ArchInf: TArchInf; var ArbolDNI: TPuntDNI);
procedure EstPorcenRein(var ArchCon: TArchCon);
procedure EstPorcenNoHab(var ArchCon: TArchCon);
procedure EstTotalSinInf(var ArchCon: TArchCon);
procedure EstRangoEtario(var ArchCon: TArchCon; var ArchInf: TArchInf; var ArbolDNI: TPuntDNI);

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
  LenAux[1] := 8;   // DNI 12.345.678
  LenAux[2] := 50;  // Tipo de Infracción
  LenAux[3] := 10;  // DD/MM/AAAA
  LenAux[4] := 2;   // Puntos

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
        

        // Mostrar infracciones sin DNI
        {
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
        }

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

function EsBajaLogicaCon(var ArchCon: TArchCon; DNICon: Cardinal; var ArbolDNI: TPuntDNI): Boolean;
var
  Pos: longint;
  DatosCon: TDatoConductores;
begin
  Pos := PreordenDNI(ArbolDNI, DNICon);
  if Pos >= 0 then
  begin
    Seek(ArchCon, Pos);
    Read(ArchCon, DatosCon);
    EsBajaLogicaCon := DatosCon.BajaLogica
  end;
end;

procedure InicializarListaInf(var ArchCon: TArchCon; var ArchInf: TArchInf; var ListaInf: TListaDatosInf; ArbolDNI: TPuntDNI;
  DNICon: Cardinal; Inicio, Fin: TRegFecha);
{Recorre el archivo de infracciones y guarda las infracciones de un conductor, según DNICon, en una lista 
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
          if not EsBajaLogicaCon(ArchCon, Inf.DNI, ArbolDNI) then
            if DNICon = 0 then
              Agregar(ListaInf, Inf)
            else
            if DNICon = Inf.DNI then
              Agregar(ListaInf, Inf);
      until EsFechaPosterior(Inf.Fecha.Dia, Inf.Fecha.Mes, Inf.Fecha.Anio, Fin.Dia, Fin.Mes, Fin.Anio) or EOF(ArchInf);
    end;
  end;
end;

procedure ListadoInf(var ArchCon: TArchCon; var ArchInf: TArchInf; var ArbolDNI: TPuntDNI; ConductorEspecifico: Boolean);
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
  InicializarListaInf(ArchCon, ArchInf, ListaInf, ArbolDNI, DNICon, FechaInicio, FechaFin);
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

procedure PrecioneUnaTecla;
{Muestra un texto y espera a que se precione alguna tecla}
begin
  TextColor(LightGreen);
  Write('Presione una tecla para continuar.');
  TextColor(White);
  ReadLn;
end;

procedure EstCantInf(var ArchCon: TArchCon; var ArchInf: TArchInf; var ArbolDNI: TPuntDNI);
{Muestra la cantidad de infracciones cometidas entre dos fechas}
var
  ListaInf: TListaDatosInf;
  FechaInicio, FechaFin: TRegFecha;
begin
  ObtenerFechaInicioFin(FechaInicio, FechaFin);

  CrearLista(ListaInf);
  InicializarListaInf(ArchCon, ArchInf, ListaInf, ArbolDNI, 0, FechaInicio, FechaFin);
  
  ClrScr;
  Write('Entre el ', FormatoFecha(FechaInicio.Dia, FechaInicio.Mes, FechaInicio.Anio), ' y el ',
    FormatoFecha(FechaFin.Dia, FechaFin.Mes, FechaFin.Anio));
  if TamanioLista(ListaInf) > 0 then
    if TamanioLista(ListaInf) = 1 then
      WriteLn(' se cometió ', TamanioLista(ListaInf), ' infracción.')
    else
      WriteLn(' se cometieron ', TamanioLista(ListaInf), ' infracciones.')
  else
    WriteLn(' no se cometieron infracciones.');
  WriteLn;
  PrecioneUnaTecla;
end;

function CantConRein(var ArchCon: TArchCon): Word;
{Devuelve la cantidad de conductores que poseen al menos una reincidencia y no están dados de baja}
var
  DatosConAux: TDatoConductores;
begin
  CantConRein := 0;
  Seek(ArchCon, 0);
  while not (EOF(ArchCon)) do
  begin
    Read(ArchCon, DatosConAux);
    if (not DatosConAux.BajaLogica) and (DatosConAux.CantRein > 0) then
      Inc(CantConRein);
  end;
end;

function CantCon(var ArchCon: TArchCon): Word;
{Devuelve la cantidad de conductores que NO están dados de baja}
var
  DatosConAux: TDatoConductores;
begin
  CantCon := 0;
  Seek(ArchCon, 0);
  while not (EOF(ArchCon)) do
  begin
    Read(ArchCon, DatosConAux);
    if (not DatosConAux.BajaLogica) then
      Inc(CantCon);
  end;
end;

function Porcentaje(Parte, Total: Word): Real;
{Devuelve el porcentaje entre Parte y Total}
begin
  Porcentaje := (Parte / Total) * 100;
end;

procedure EstPorcenRein(var ArchCon: TArchCon);
{Muestra el porcentaje de conductores que poseen al menos una reincidencia}
var
  TotalCon, TotalConRein: Word;
begin
  TotalCon := CantCon(ArchCon);
  TotalConRein := CantConRein(ArchCon);

  WriteLn('De ', TotalCon, ' conductores, el ', Porcentaje(TotalConRein, TotalCon):0:2, '% es reincidente.');
  WriteLn;
  PrecioneUnaTecla;
end;

procedure EstPorcenNoHab(var ArchCon: TArchCon);
{Muestra el porcentajes de conductores con scoring 0 (NO habilitados)}
var
  ListaCon: TListaDatosCon;
  TotalCon, TotalConNoHab: Word;
begin
  CrearLista(ListaCon);
  InicializarListaCon(ArchCon, ListaCon, True);

  TotalCon := CantCon(ArchCon);
  TotalConNoHab := TamanioLista(ListaCon);

  WriteLn('De ', TotalCon, ' conductores, el ', Porcentaje(TotalConNoHab, TotalCon):0:2, '% posee scoring 0.');
  WriteLn;
  PrecioneUnaTecla;
end;

function CantConSinInf(var ArchCon: TArchCon): Word;
{Devuelve la cantidad de conductores sin ninguna infracción}
var
  ConAux: TDatoConductores;
begin
  CantConSinInf := 0;
  Seek(ArchCon, 0);
  while not EOF(ArchCon) do
  begin
    Read(ArchCon, ConAux);
    if (ConAux.Scoring = 20) and (ConAux.CantRein = 0) then
      Inc(CantConSinInf);
  end;
end;

procedure EstTotalSinInf(var ArchCon: TArchCon);
{Muestra el porcentaje de conductores sin ninguna infracción}
var
  TotalCon, TotalSinInf: Word;
begin
  TotalCon := CantCon(ArchCon);
  TotalSinInf := CantConSinInf(ArchCon);

  WriteLn('De ', TotalCon, ' conductores, el ', Porcentaje(TotalSinInf, TotalCon):0:2, '% nunca ha cometido una infracción.');
  WriteLn;
  PrecioneUnaTecla;
end;

procedure CantInfRangoEtario(var ArchCon: TArchCon; var ArchInf: TArchInf; var ArbolDNI: TPuntDNI; var CantInf: TVectorInt);
{Devuelve un array con la cantidad de infracciones cometidas por rango etario, según esten definidos en RangoEtarios}
var
  i: Word;
  InfAux: TDatoInfracciones;
  ConAux: TDatoConductores;
  FechaActual: TRegFecha;
begin
  for i := 1 to RangosEtariosTotales do
    CantInf[i] := 0;
  ObtenerFechaActual(FechaActual);
  ConAux.DNI := 0;
  Seek(ArchInf, 0);
  while not EOF(ArchInf) do
  begin
    Read(ArchInf, InfAux);
    if InfAux.DNI <> ConAux.DNI then
    begin
      Seek(ArchCon, PreordenDNI(ArbolDNI, InfAux.DNI));
      Read(ArchCon, ConAux);  
    end;

    if not ConAux.BajaLogica then
      with ConAux do
      begin
        i := 1;
        {Mientras la edad del conductor sea menor a la edad mínima del rango etario i,
         y haya más rangos etarios, incrementar i}
        while  (EsFechaPosterior(FechaNac.Dia, FechaNac.Mes, FechaNac.Anio, 
                FechaActual.Dia, FechaActual.Mes, FechaActual.Anio - RangosEtarios[i])) and (i <= RangosEtariosTotales) do
          Inc(i);
        
        if i <= RangosEtariosTotales then
          Inc(CantInf[i]);
      end;
  end;
end;

procedure EstRangoEtario(var ArchCon: TArchCon; var ArchInf: TArchInf; var ArbolDNI: TPuntDNI);
var
  CantInf: TVectorInt;
begin
  CantInfRangoEtario(ArchCon, ArchInf, ArbolDNI, CantInf);

  Write('El rango etario con más infracciones es: ');
  if (CantInf[1] >= CantInf[2]) and (CantInf[1] >= CantInf[3]) then
    WriteLn('Mayores de ', RangosEtarios[1], ' años, con ', CantInf[1], ' infracciones.')
  else
  if (CantInf[2] >= CantInf[1]) and (CantInf[2] >= CantInf[3]) then
    WriteLn('Entre ', RangosEtarios[2], ' y ', RangosEtarios[1], ' años, con ', CantInf[2], ' infracciones.')
  else
    WriteLn('Menores de ', RangosEtarios[2], ' años, con ', CantInf[3], ' infracciones.');

{  WriteLn;
  Write('VECTOR: ', CantInf[1], '; ', CantInf[2], '; ', CantInf[3]);}
  WriteLn;
  PrecioneUnaTecla;
end;
end.
