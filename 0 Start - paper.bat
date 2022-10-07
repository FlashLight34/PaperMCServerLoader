@echo off
set dontsearch=0

:firsttime
chcp 65001 > nul
chcp 1252 > nul
set vers=4
rem config
rem %WINDIR%\media\Alarm*.wav
rem %WINDIR%\media\Ring*.wav
set finddirfile=%WINDIR%\media\Alarm*.wav
set version=1.19.2
set dontprompt=1
set title=Serveur de Nini et Jo
rem end config

set build=0
set versionfile=paper_version.txt
set firsttime=0
SET BINDIR=%~dp0
CD /D "%BINDIR%"
Title Flash Server loader V%vers%

rem test
rem call :descriptions 1.19.2 180
rem call :downloadpapermc 1.19.2 191


if not exist %versionfile% (
  echo.
  echo. [36m***********************************[0m
  echo. [36m***** [32mFlash [33mServer loader V%vers% [36m******[0m
  echo. [36m******[33m Première utilisation. [36m******[0m
  echo. [36m***********************************[0m
  echo.
  type nul >%versionfile%
  set firsttime=1
  ping 127.0.0.1 -n 4 > nul
)

set /p readversion=< %versionfile%
set newversiondetected=0

for /F "tokens=1,2 delims= " %%a in ("%readversion%") do (
  set version=%%a
  set build=%%b
)
if %firsttime% == 0 (
  echo.
  echo. [33m***********************************[0m
  echo. [33m***** [35mFlash [36mServer loader V%vers% [33m******[0m
  echo. [33m**[36m Version Actuel: [35m%version% [36mb: [35m%build% [33m**[0m
  echo. [33m***********************************[0m
  echo.
)
set fichierActuel=paper-%version%-%build%.jar
ping 127.0.0.1 -n 3 > nul
set filefound=0
echo. [33mVérification local...[0m
FOR %%i IN (paper-*.jar) do (
  if not %%i == %fichierActuel% (
    for /f "tokens=2,3 delims=-" %%a in ("%%~ni") do (
      if %%b GTR %build% (
        if %firsttime% == 0 echo. [33mNouveau build découvert: [35m%%i[0m
        if %firsttime% == 1 echo. [33mVersion découverte: [35m%%i[0m
        set version=%%a
        set build=%%b
        set newversiondetected=1
      )
      if %%b LSS %build% (
        echo. [31mEffacement d'ancienne version: [35m%%i[0m
        del "%BINDIR%%%i"
      )
    )
  )
  set filefound=1
)
if %filefound% == 0 (
  cls
  echo.
  echo. [31m***********************************[0m
  echo. [31m***** [33mFlash [96mServer loader V%vers% [31m******[0m
  echo. [31m********[91m Paper introuvable! [31m*******[0m
  echo. [31m***********************************[0m
  echo.
  ping 127.0.0.1 -n 3 > nul
  rem exit 0
)
rem check sur internet yeah!

if %dontsearch% EQU 1 goto bypasscheck
echo. [33mVérification en ligne sur [34mpapermc.io[33m...[0m

set latestversiononline=0
set multibuild=0
set commande='curl -s "https://api.papermc.io/v2/projects/paper/versions/%version%" -H "accept: application/json"'
for /F "tokens=2 delims=[" %%a in (%commande%) do (
  for /F "tokens=1 delims=]" %%b in ("%%a") do (
    for %%c in (%%b) do (
      if %%c GTR %build% (
        call :multibuilds %build% %%c
        set latestversiononline=%%c
      )
    )
  )
)
::echo %multibuild%


set telecharge=n
if %latestversiononline% GTR %build% (
  echo. [96mNouveau build découvert pour la version [95m%version%[96m: [95m%latestversiononline%[0m
  call :playsound
  ping 127.0.0.1 -n 2 > nul
  rem download description
  rem https://api.papermc.io/v2/projects/paper/versions/1.19.2/builds/177
  ::call :descriptions %version% %latestversiononline%
  echo. [34mChangements dans les derniers builds: [0m
  call :multiNotes %version% %multibuild%
  ping 127.0.0.1 -n 5 > nul
  
  call :downloadpapermc %version% %latestversiononline%
  ping 127.0.0.1 -n 4 > nul
  cls
  goto firsttime
)
if %latestversiononline% == %build% (
  echo. [33mDernier build pour la version [36m%version%[33m: [36m%latestversiononline%[0m
)
goto bypasspromptdownload

::ici etait downloadpapermc

rem end check online
:bypasscheck
if %newversiondetected% == 1 (
  if exist %BINDIR%%fichierActuel% (
    ping 127.0.0.1 -n 3 > nul
    echo. [33mÉffacement de l'ancienne: [35m%fichierActuel%[0m 
    del "%BINDIR%%fichierActuel%"
  )
  ping 127.0.0.1 -n 3 > nul
  if %firsttime% == 0 echo. [33mEnregistrement de la nouvelle version...[0m
  if %firsttime% == 1 echo. [33mEnregistrement de la version...[0m 
  echo %version% %build%>%versionfile%
  set firsttime=1
)
if %firsttime% == 1 (
  ping 127.0.0.1 -n 5 > nul
  cls
  goto firsttime
)
ping 127.0.0.1 -n 3 > nul
echo.
echo. [34mDémarrage du serveur paper [36m%version% %build%[34m...[0m
echo.
ping 127.0.0.1 -n 3 > nul
rem call "Server MineCraft.bat" %version% %build%

rem start server
call :startserver %version% %build%
EXIT /B 0

:playsound
setlocal enabledelayedexpansion
set filename=playsound.vbs
set file=0
set total=0
set soundnumber=0
FOR %%i IN (%finddirfile%) do (
  set /a total+=1
)
if %total% == 0 (
  echo. [31m^[[92mPlaysound[31m^] Aucun fichier trouvé^^! ^([93m%finddirfile%[31m^)[0m
  exit /b 1
)
set /a soundnumber=(%Random% %%(%total%))+1
set count=0
FOR %%i IN (%finddirfile%) do (
  set /a count+=1
  if %soundnumber%==!count! set file=%%i
)
(echo Set Sound = CreateObject("WMPlayer.OCX.7"^)
echo Sound.URL = "%file%"
echo Sound.Controls.play
echo do while Sound.currentmedia.duration = 0
echo wscript.sleep 100
echo loop
echo wscript.sleep (int(Sound.currentmedia.duration^)+1^)*1000
echo Set objFSO = CreateObject("Scripting.FileSystemObject"^)
echo strScript = Wscript.ScriptFullName
echo objFSO.DeleteFile(strScript^)) >%filename%
start /min %filename%
ENDLOCAL
EXIT /B 0

:descriptions
setlocal EnableDelayedExpansion
set version=%1
set build=%2
echo [35m%build%[34m: [0m

set com='curl -s "https://api.papermc.io/v2/projects/paper/versions/%version%/builds/%build%" -H "accept: application/json"'
rem set com='curl -s "https://api.papermc.io/v2/projects/paper/versions/1.19.2/builds/177" -H "accept: application/json"'

for /F "tokens=2 delims=[" %%a in (%com%) do (
  for /F "tokens=1 delims=]" %%b in ("%%a") do (
    for /F "tokens=4 delims=:" %%c in ("%%b") do (
      for /F "tokens=1 delims=}" %%d in ("%%c") do (
        set messages=%%d
      )
    )
  )
)
set n=^&echo. 
set messages=%messages:(=%
set messages=%messages:)=%
set messages=%messages:"=%
set messages=%messages:\r=%
set messages=%messages:\n=!n!%
::display message
echo. %messages%

rem si il y des  () dans le message cela bug!
::for /F "delims=" %%a in (%messages%) do (
::  echo. %%a[0m
::)
endlocal
EXIT /B 0

:startserver
Title %title%
setlocal
set version=%1
set build=%2
java -Xmx2048M -Xms2048M -Dlog4j.configurationFile=log4j2.xml -jar paper-%version%-%build%.jar nogui
endlocal
pause
EXIT /B 0

::Start donwloadpapermc
:downloadpapermc

set version=%1
set build=%2
IF %dontprompt% == 1 (
  set telecharge=o
  goto bypasspromptdownload
)

echo. [33mVoulez-vous acquerir le fichier:[0m

choice /C on /T 20 /D o /M ""
IF %ERRORLEVEL% EQU 2 set telecharge=n
IF %ERRORLEVEL% EQU 1 set telecharge=o
IF %ERRORLEVEL% EQU 0 set telecharge=n

:bypasspromptdownload

rem set fich=paper-%version%-%latestversiononline%.jar
set fich=paper-%version%-%build%.jar
set url="https://api.papermc.io/v2/projects/paper/versions/%version%/builds/%build%/downloads/%fich%"
IF %telecharge% == o (
  rem set url=https://api.papermc.io/v2/projects/paper/versions/%version%/builds/%latestversiononline%/downloads/%fich%
  echo. [36mTéléchargement en cour...[0m
  ::echo %url%
  ::echo %fich%
  curl -s -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64)" -H "accept: application/json" -L %url% -o "%BINDIR%%fich%"
  ping 127.0.0.1 -n 5 > nul
  if exist %BINDIR%%fich% (
    echo. [36mNouveau fichier [35m%fich% [36mtélécharger![0m
    ping 127.0.0.1 -n 3 > nul
    echo. [92mUn instant s'il vous plaît...[0m
    set dontsearch=1
  )
  if not exist %BINDIR%%fich% (
    echo. [91mEchec![0m
  )
)
EXIT /B 0
::End donwloadpapermc
:multibuilds
if %multibuild% GTR 0 (
  set multibuild=%multibuild%-%2
)
if %multibuild% EQU 0 set multibuild=%2
EXIT /B 0

:multiNotes
setlocal ENABLEDELAYEDEXPANSION
set ver=%1
set versions=%2
set versions=!versions:-= !
FOR %%a in (%versions%) do (
  call :descriptions %ver% %%a
  ping 127.0.0.1 -n 3 > nul
)
endlocal