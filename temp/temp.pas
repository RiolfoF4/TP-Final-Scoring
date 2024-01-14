program temp;

uses
  crt, sysutils;

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
  Offset: Integer;

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
  begin
    if Length(Utf8ToAnsi(Infraccion)) > (WindMaxX - WindMinX) then
    begin
      UltimoEspacio := UltimoEspacioEnLinea(Infraccion);
      WriteLn(UTF8Decode(Copy(Infraccion, 1, UltimoEspacio)));
      MostrarInfraccion(Copy(Infraccion, UltimoEspacio + 1, Length(Infraccion) - UltimoEspacio));
    end
    else
      WriteLn(UTF8Decode(Infraccion));
  end;

begin
  Window(20, 5, 100, 30);
  Assign(ArchTest, RutaTest);
  Assign(ArchListaInf, Ruta);
  Rewrite(ArchTest);
  Reset(ArchListaInf);
  InicializarArchTest(ArchTest, ArchListaInf);
  CrearPila(PosAnterior);
  Offset := ((80-Length(Opciones)) div 2) + Length(Opciones);

  i := 0;
  Anterior := 0;
  Tecl := '';

  while Tecl <> 'q' do              // Debería salir mediante una tecla
  begin
    if i < FileSize(ArchTest) then
    begin
      Seek(ArchTest, i);
      Read(ArchTest, Infraccion);
      Infraccion := '[' + IntToStr(i+1) + '] ' + Infraccion;
      MostrarInfraccion(Infraccion);
      WriteLn;
      Inc(i);
    end;
    if (WhereY > 21) or (EOF(ArchTest)) then
    begin
      WriteLn(Opciones:Offset);
      WriteLn('i: ', i);
      WriteLn('Anterior: ', Anterior);
      ReadLn(Tecl);
      case LowerCase(Tecl) of
        's':
          if not (EOF(ArchTest)) then
            Apilar(PosAnterior, Anterior)
          else
            i := Anterior;
        'a': 
          if not (PilaVacia(PosAnterior)) then
            Desapilar(PosAnterior, i)
          else
            i := 0;
      else
        i := Anterior;
      end;
      Anterior := i;
      ClrScr;
    end;
  end;
  Close(ArchListaInf);
  Close(ArchTest);
end.