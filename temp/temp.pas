program temp;

uses
  crt, sysutils, UnitValidacion;

const
  Ruta = 'listado_infracciones.txt';
  RutaTest = 'test.dat';
  Opciones = '[A]nterior           [S]iguiente           [Q]Salir';

type
  TArchTest = File of String;
  TPilaPos = record
    Tope: Byte;
    Tam: Byte;
    Elem: array[1..10] of Byte;
  end;

var
  ArchListaInf: Text;
  ArchTest: TArchTest;
  Infraccion: String;
  i: Byte;
  Anterior: Byte;
  Tecl: String[2];
  PosAnterior: TPilaPos;
  Margen: Integer;

{~~~~~~~ PROCEDIMIENTOS DE PILA ~~~~~~~}
procedure CrearPila(var P: TPilaPos);
  begin
    P.Tope := 0;
    P.Tam := 0;
  end;

procedure Apilar(var P: TPilaPos; x: Byte);
  begin
    Inc(P.Tope);
    P.Elem[P.Tope] := x;
    Inc(P.Tam);
  end;

procedure Desapilar(var P: TPilaPos; var x: Byte);
  begin
    x := P.Elem[P.Tope];
    Dec(P.Tope);
    Dec(P.Tam);
  end;

function PilaVacia(var P: TPilaPos): Boolean;
  begin
    PilaVacia := (P.Tam = 0);
  end;
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}


procedure InicializarArchTest(var ArchTest: TArchTest; var ArchListaInf: Text);
  var
    x: String;
  begin
    while not (EOF(ArchListaInf)) do
    begin
      ReadLn(ArchListaInf, x);
      Write(ArchTest, x);
    end;
    Reset(ArchListaInf);
    Seek(ArchTest, 0);
  end;

function UltimoEspacioEnLinea(Texto: String): Integer;
  var
    i: Word;
  begin
    // WindMaxX representa el borde derecho y WindMinX el borde izquierdo.
    i := WindMaxX - WindMinX;
    while (Texto[i] <> ' ') and (i > 0) do
      Dec(i);
    if i <> 0 then
      UltimoEspacioEnLinea := i
    else
      UltimoEspacioEnLinea := -1;
  end;

procedure MostrarInfraccion(Infraccion: String);
  var
    UltimoEspacio: Integer;
    SeparadorPuntos: Word;
  begin
    // Si el texto excede el largo de un línea.
    if Length(Utf8ToAnsi(Infraccion)) > (WindMaxX - WindMinX) then
    begin
      // Muestra el texto hasta el último espacio de la línea.
      UltimoEspacio := UltimoEspacioEnLinea(Infraccion);
      WriteLn(UTF8Decode(Copy(Infraccion, 1, UltimoEspacio)));

      // Llama recursivamente al procedimiento con el resto del texto.
      MostrarInfraccion(Copy(Infraccion, UltimoEspacio + 1));
    end
    else
    begin
      // Muestra la infracción.
      SeparadorPuntos := Pos('\', Infraccion);
      WriteLn(UTF8Decode(Copy(Infraccion, 1, SeparadorPuntos-1)));
    end;
  end;

function PuntosInfraccion(Infraccion: String): Integer;
  var
    SeparadorPuntos: Word;
  begin
    // Los puntos están separados por '\{Puntos}', sin comillas ni espacios.
    SeparadorPuntos := Pos('\', Infraccion);
    if SeparadorPuntos > 0 then
      Val(Copy(Infraccion, SeparadorPuntos+1), PuntosInfraccion)
    else
      PuntosInfraccion := -1;
  end;

function InfraccionValida(NumeroInfrac: String; var ArchInf: TArchTest): Boolean;
  var
    Num: Integer;
  begin
    InfraccionValida := False;
    if EsNum(NumeroInfrac) then
    begin
      Val(NumeroInfrac, Num);
      // NOTA: La infracción [1] se encuentra en la posición 0 del archivo, la [2] en el 1...
      // La última infracción coincide con el tamaño del archivo.
      if (1 <= Num) and (Num <= FileSize(ArchInf)) then
        InfraccionValida := True;
    end;
  end;

begin
  // Establece el área donde mostrar las infracciones/opciones.
  Window(20, 5, 100, 30);
  // ~~~~~~ Inicialización ~~~~~~ 
  Assign(ArchTest, RutaTest);
  Assign(ArchListaInf, Ruta);
  Rewrite(ArchTest);
  Reset(ArchListaInf);
  InicializarArchTest(ArchTest, ArchListaInf);
  CrearPila(PosAnterior);

  i := 0;
  Anterior := 0;
  Tecl := '';
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Centra el texto de opciones.
  Margen := ((80-Length(Opciones)) div 2) + Length(Opciones);

  while (Tecl <> 'q') and not (InfraccionValida(Tecl, ArchTest)) do
  begin
    // Si no se llegó al final del archivo, muestra secuencialmente las infracciones.
    if i < FileSize(ArchTest) then
    begin
      Seek(ArchTest, i);
      Read(ArchTest, Infraccion);
      Infraccion := '[' + IntToStr(i+1) + '] ' + Infraccion;
      MostrarInfraccion(Infraccion);
      WriteLn;
      Inc(i);
    end;

    // Recibe una entrada del usuario si el texto supera un límite inferior
    // o se llega al final del archivo.
    if (WhereY > 21) or (EOF(ArchTest)) then
    begin
      WriteLn(Opciones:Margen);
      Write(UTF8Decode('Opción: '));
{      WriteLn('i: ', i);
      WriteLn('Anterior: ', Anterior);
}
      ReadLn(Tecl);
      // s: Siguiente.
      // a: Anterior.
      case LowerCase(Tecl) of
        's':
          // Si NO se llegó al final del archivo, apila el índice de la infracción que se muestra actualmente.
          // Si se llegó el final del archivo, muestra lo mismo.
          if not (EOF(ArchTest)) then
            Apilar(PosAnterior, Anterior)
          else
            i := Anterior;
        'a': 
          // Si la pila contiene algún índice, lo desapila y lo guarda en el índice del archivo 'i'.
          // Si la pila NO contiene ningún índice, se encuentra en la primera "página", y establece el índice del
          // archivo acordemente.
          if not (PilaVacia(PosAnterior)) then
            Desapilar(PosAnterior, i)
          else
            i := 0;
      else
        // Si la tecla no es 's' ni 'a', muestra la misma "página"
        i := Anterior;
      end;
      Anterior := i;
      ClrScr;
    end;
  end;
  {------TEMP------}
  ClrScr;
  Seek(ArchTest, StrToInt(Tecl) - 1);
  Read(ArchTest, Infraccion);
  WriteLn(UTF8Decode('Infracción seleccionada: '));
  MostrarInfraccion(Infraccion);
  WriteLn('Puntos a descontar: ');
  WriteLn(PuntosInfraccion(Infraccion));
  ReadLn;
  {----------------}
  Close(ArchListaInf);
  Close(ArchTest);
end.