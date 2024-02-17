@echo off

SET LAZBUILD="D:\lazarus\lazbuild.exe"
SET PROJECT="C:\Users\Franco\Documents\Cosa\2do Cuatrimestre\Algoritmos y Estructuras de Datos\GitHub\TP-Final-Scoring\scoring.lpi"

REM Modify .lpr file in order to avoid nothing-to-do-bug (http://lists.lazarus.freepascal.org/pipermail/lazarus/2016-February/097554.html)
echo. >> "C:\Users\Franco\Documents\Cosa\2do Cuatrimestre\Algoritmos y Estructuras de Datos\GitHub\TP-Final-Scoring\scoring.lpr"

%LAZBUILD% %PROJECT%

if %ERRORLEVEL% NEQ 0 GOTO END

echo. 

if "%1"=="" goto END

if /i %1%==test (
  "C:\Users\Franco\Documents\Cosa\2do Cuatrimestre\Algoritmos y Estructuras de Datos\GitHub\TP-Final-Scoring\scoring.exe" 
)
:END
