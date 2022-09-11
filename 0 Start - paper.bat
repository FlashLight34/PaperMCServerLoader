@echo off
set dontsearch=0

:firsttime
chcp 65001 > nul
chcp 1252 > nul
set vers=2
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
if not exist %versionfile% (
  echo.
  echo. [36m***********************************[0m
  echo. [36m***** [32mFlash [33mServer loader V%vers% [36m******[0m
  echo. [36m******[33m Premi�re utilisation. [36m******[0m
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
echo. [33mV�rification local...[0m
FOR %%i IN (paper-*.jar) do (
  if not %%i == %fichierActuel% (
    for /f "tokens=2,3 delims=-" %%a in ("%%~ni") do (
      if %%b GTR %build% (
        if %firsttime% == 0 echo. [33mNouveau build d�couvert: [35m%%i[0m
        if %firsttime% == 1 echo. [33mVersion d�couverte: [35m%%i[0m
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
echo. [33mV�rification en ligne sur [34mpapermc.io[33m...[0m
set latestversiononline=0

set commande='curl -s "https://api.papermc.io/v2/projects/paper/versions/%version%" -H "accept: application/json"'
for /F "tokens=2 delims=[" %%a in (%commande%) do (
  for /F "tokens=1 delims=]" %%b in ("%%a") do (
    for %%c in (%%b) do (
      set latestversiononline=%%c
    )
  )
)

set telecharge=n
if %latestversiononline% GTR %build% (
  echo. [96mNouveau build d�couvert pour la version [95m%version%[96m: [95m%latestversiononline%[0m
  call :playsound
  ping 127.0.0.1 -n 5 > nul
  goto download
)
if %latestversiononline% == %build% (
  echo. [33mDernier build pour la version [36m%version%[33m: [36m%latestversiononline%[0m
)
goto bypasspromptdownload

:download
if %dontprompt% == 1 (
  set telecharge=o
  goto bypasspromptdownload
)
echo. [33mVoulez-vous acquerir le fichier:[0m
choice /C on /T 20 /D o /M ""
IF %ERRORLEVEL% EQU 2 set telecharge=n
IF %ERRORLEVEL% EQU 1 set telecharge=o
IF %ERRORLEVEL% EQU 0 set telecharge=n

:bypasspromptdownload
set fich=paper-%version%-%latestversiononline%.jar
IF %telecharge% == o (
  echo. [36mT�l�chargement en cour...[0m
  curl -s -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64)" -H "accept: application/json" -L "https://api.papermc.io/v2/projects/paper/versions/%version%/builds/%latestversiononline%/downloads/%fich%" -o "%BINDIR%%fich%"
  ping 127.0.0.1 -n 3 > nul
  if exist %BINDIR%%fich% (
    echo. [36mNouveau fichier [35m%fich% [36mt�l�charger![0m
    ping 127.0.0.1 -n 3 > nul
    echo. [92mUn instant s'il vous pla�t...[0m
  )
  if not exist %BINDIR%%fich% (
    echo. [91mEchec![0m
  )
  ping 127.0.0.1 -n 4 > nul
  cls
  set dontsearch=1
  goto firsttime
)
rem end check online
:bypasscheck
if %newversiondetected% == 1 (
  if exist %BINDIR%%fichierActuel% (
    ping 127.0.0.1 -n 3 > nul
    echo. [33m�ffacement de l'ancienne: [35m%fichierActuel%[0m 
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
echo. [33mD�marrage du serveur paper [36m%version% %build%[33m...[0m
echo.
ping 127.0.0.1 -n 3 > nul
rem call "Server MineCraft.bat" %version% %build%

Title %title%
java -Xmx2048M -Xms2048M -Dlog4j.configurationFile=log4j2.xml -jar paper-%version%-%build%.jar nogui
pause
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
  echo. [31m^[[92mPlaysound[31m^] Aucun fichier trouv�^^! ^([93m%finddirfile%[31m^)[0m
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