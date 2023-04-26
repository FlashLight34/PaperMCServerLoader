@echo off
set dontsearch=0

:firsttime
chcp 65001 > nul
chcp 1252 > nul
rem config
rem %WINDIR%\media\Alarm*.wav
rem %WINDIR%\media\Ring*.wav
set vers=7
set newversionfound_randomsong=%WINDIR%\media\Alarm*.wav
set version=1.19.4
set dontprompt=1
set latestnewsinfileandanotherscreen=1
set title=Serveur de Nini et Jo
rem end config

set build=0
set versionfile=paper_version.txt
set latestnewsfile=paper_latestnews.bat
set firsttime=0
SET BINDIR=%~dp0
CD /D "%BINDIR%"
Title Flash Server loader V%vers%

rem test
rem call :descriptions 1.19.2 244 0
rem call :downloadpapermc 1.19.2 191
rem echo fin
rem pause

if not exist %versionfile% (
  echo.
  echo. [36m***********************************[0m
  echo. [36m***** [32mFlash [33mServer loader V%vers% [36m******[0m
  echo. [36m******[33m Première utilisation. [36m******[0m
  echo. [36m***********************************[0m
  echo.
  type nul >%versionfile%
  echo %version% 0>%versionfile%
  set firsttime=1
  call :pause 4
)

set /p readversion=< %versionfile%
set newversiondetected=0

for /F "tokens=1,2 delims= " %%a in ("%readversion%") do (
  rem set version=%%a
  set build=%%b
)
if %firsttime% == 0 (
  call :title 1
)
set fichierActuel=paper-%version%-%build%.jar
call :pause 2
set filefound=0
::ici etait local check
call :checklocalversion %build%
::end
if %filefound% == 0 (
  cls
  echo.
  echo. [31m***********************************[0m
  echo. [31m***** [33mFlash [96mServer loader V%vers% [31m******[0m
  echo. [31m********[91m Paper introuvable! [31m*******[0m
  echo. [31m***********************************[0m
  echo.
  call :pause 3
)
rem check sur internet yeah!

if %dontsearch% EQU 1 goto bypasscheck
set latestbuildonline=0
call :checkonlinebuild %version% %build%
set latestbuildonline=%errorlevel%

::ici etait checkonline
set telecharge=n

if %latestbuildonline% GTR %build% (
  echo. [96mNouveau build découvert pour la version [95m%version%[96m: [95m%latestbuildonline%[0m
  call :playsound
  call :pause 3
  if %latestnewsinfileandanotherscreen% == 1 (
    (
      echo ^@echo off
      echo ^chcp 65001 ^> nul
      echo ^chcp 1252 ^> nul
      echo ^echo Nouveautés
    )>%latestnewsfile%
    echo. [34mÉcriture dans le fichier [35m%latestnewsfile%[36m %multibuild%[34... [0m
  )
  if %latestnewsinfileandanotherscreen% == 0 echo. [34mChangements dans les derniers builds: [0m
  call :pause 2
  call :multiNotes %version% %multibuild% %latestnewsinfileandanotherscreen%
  if %latestnewsinfileandanotherscreen% == 1 (
    echo ^pause>>%latestnewsfile%
    echo ^exit>>%latestnewsfile%
    @start /wait "Latest news" %latestnewsfile%
  )
  call :pause 2
  call :downloadpapermc %version% %latestbuildonline%
  call :pause 2
  call :checklocalversion %build%
  call :pause 3
  cls
  call :title 1
  rem goto firsttime
)

if %latestbuildonline% == %build% (
  echo. [33mDernier build pour la version [36m%version%[33m: [36m%latestbuildonline%[0m
)
rem goto bypasspromptdownload

rem end check online
:bypasscheck
if %newversiondetected% == 1 (
  if exist %BINDIR%%fichierActuel% (
    call :pause 3
    echo. [33mÉffacement de l'ancienne: [35m%fichierActuel%[0m 
    del "%BINDIR%%fichierActuel%"
  )
  call :pause 3
  if %firsttime% == 0 echo. [33mEnregistrement de la nouvelle version...[0m
  if %firsttime% == 1 echo. [33mEnregistrement de la version...[0m 
  echo %version% %build%>%versionfile%
rem set firsttime=1
)
if %firsttime% == 1 (
rem call :pause 5
rem cls
rem goto firsttime
)
call :pause 3
::start server
call :startserver %version% %build%
EXIT /B 0

:playsound
setlocal enabledelayedexpansion
set filename=playsound.vbs
set file=0
set total=0
set soundnumber=0
FOR %%i IN (%newversionfound_randomsong%) do (
  set /a total+=1
)
if %total% == 0 (
  echo. [31m^[[92mPlaysound[31m^] Aucun fichier trouvé^^! ^([93m%newversionfound_randomsong%[31m^)[0m
  exit /b 1
)
set /a soundnumber=(%Random% %%(%total%))+1
set count=0
FOR %%i IN (%newversionfound_randomsong%) do (
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
::playsound end
::local check
:checklocalversion
set bu=%1
echo. [33mVérification local...[0m
FOR %%i IN (paper-*.jar) do (
  if not %%i == %fichierActuel% (
    for /f "tokens=2,3 delims=-" %%a in ("%%~ni") do (
      if %%b GTR %bu% (
        if %firsttime% == 0 echo. [33mNouveau build découvert: [35m%%i[0m
        if %firsttime% == 1 echo. [33mVersion découverte: [35m%%i[0m
        set version=%%a
        set build=%%b
        set newversiondetected=1
      )
      if %%b LSS %bu% (
        echo. [31mEffacement d'ancienne version: [35m%%i[0m
        del "%BINDIR%%%i"
      )
    )
  )
  set filefound=1
)
EXIT /B 0
::local check end
::check online
:checkonlinebuild
echo. [33mVérification en ligne sur [34mpapermc.io[33m...[0m
set ve=%1
set bd=%2
set multibuild=0
set commande='curl -s "https://api.papermc.io/v2/projects/paper/versions/%ve%" -H "accept: application/json"'

for /F "tokens=2 delims=[" %%a in (%commande%) do (
  for /F "tokens=1 delims=]" %%b in ("%%a") do (
    for %%c in (%%b) do (
      call :setmultibuilds %bd% %%c
      set bd=%%c 
    )
  )
)

EXIT /B %bd%
::check online end

:descriptions
setlocal EnableDelayedExpansion
set vers=%1
set bd=%2
set latest=%3
if %latest% == 1 echo ^echo [33m%bd%[0m:>>%latestnewsfile%
if %latest% == 0 echo. [35m%bd%[34m: [0m

set com='curl -s "https://api.papermc.io/v2/projects/paper/versions/%vers%/builds/%bd%" -H "accept: application/json"'
for /F "tokens=2 delims=[" %%a in (%com%) do (
  for /F "tokens=1 delims=]" %%b in ("%%a") do (
    for /F "tokens=4* delims=:" %%c in ("%%b") do (
      for /F "tokens=1 delims=}" %%e in ("%%c%%d") do (
        set messages=%%e
      )
    )
  )
)

IF [!messages!] == [] (
  echo [31mErreur msg is empty![0m
  EXIT /B 1
)

::replace \n by ^&echo.^and remove \r
set messages=%messages:<=%
set messages=%messages:>=%
set messages=%messages:&=and%
set messages=%messages:(=%
set messages=%messages:)=%
set messages=%messages:\r=%
set messages=%messages:"=%

::direct display
if %latest% == 0 ( 
  set n=^&echo.
  set messages=!messages:\n\n=\n!
  set messages=!messages:\n=%n%!
)
::display message in seperate window

if %latest% == 1 ( 
  set mess=!messages:\n\n=\n!
  set mess=!mess:\n=_!
  call :writenewstofile "!mess!"
)

if %latest% == 0 echo %messages%
endlocal
EXIT /B 0

:writenewstofile
for /F "tokens=1* delims=_" %%a in ("%~1") do (
  echo ^echo. %%a>>%latestnewsfile%
  if not "%%b" == "" call :writenewstofile "%%b"
rem add space to .txt
rem if "%%b" == "" echo. >> %latestnewsfile%
)

EXIT /B 0

:startserver
Title %title%
setlocal
set v=%1
set b=%2
echo.
echo. [34mDémarrage du serveur paper [36m%v% %b%[34m...[0m
echo.
call :pause 3
java -Xmx2048M -Xms2048M -Dlog4j.configurationFile=log4j2.xml -jar paper-%v%-%b%.jar nogui
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

rem set fich=paper-%version%-%latestbuildonline%.jar
set fich=paper-%version%-%build%.jar
set url=https://api.papermc.io/v2/projects/paper/versions/%version%/builds/%build%/downloads/%fich%
IF %telecharge% == o (
  rem set url=https://api.papermc.io/v2/projects/paper/versions/%version%/builds/%latestbuildonline%/downloads/%fich%
  echo. [36mTéléchargement en cour...[0m
  curl -s -A "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64)" -H "accept: application/json" -L "%url%" -o "%BINDIR%%fich%"
  call :pause 5
  if exist %BINDIR%%fich% (
    echo. [36mNouveau fichier [35m%fich% [36mtélécharger![0m
    call :pause 3
    echo. [92mUn instant s'il vous plaît...[0m
    call :pause 3
    set dontsearch=1
  )
  if not exist %BINDIR%%fich% (
    echo. [91mEchec![0m
  )
)
EXIT /B 0
::End donwloadpapermc
:setmultibuilds
if %2 GTR %1 (
  if %multibuild% GTR 0 set multibuild=%multibuild%-%2
  if %multibuild% EQU 0 set multibuild=%2
)
EXIT /B 0

:multiNotes
setlocal EnableDelayedExpansion
set ver=%1
set versions=%2
set latest=%3
IF [%1] == [] (
  echo [31mErreur 1 null![0m
  EXIT /B 1
)
IF [%2] == [] (
  echo [31mErreur 2 null![0m
  EXIT /B 2
)
set versions=!versions:-= !
FOR %%a in (%versions%) do (
  call :descriptions %ver% %%a %latest%
  if %latest% == 0 call :pause 2
)
endlocal
EXIT /B 0
:pause
ping 127.0.0.1 -n %1 > nul
EXIT /B 0
:title
echo.
echo. [33m***********************************[0m
echo. [33m***** [35mFlash [36mServer loader V%vers% [33m******[0m
echo. [33m**[36m Version Actuel: [35m%version% [36mb: [35m%build% [33m**[0m
echo. [33m***********************************[0m
echo.
exit /b 0