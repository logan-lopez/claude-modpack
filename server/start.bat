@echo off
rem Starts the server in this folder. The first start copies the default settings, installs
rem NeoForge (which downloads Minecraft's server) and asks you to accept the Minecraft EULA.
rem After a crash it restarts the server; after a `stop` or a failed load it exits.
rem Arguments pass through to the server. README.txt has the rest.
rem
rem No parenthesized blocks around %variables%: a path like "Program Files (x86)" would end them.
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"

set "NEOFORGE=@NEOFORGE_VERSION@"
set "ARGS_FILE=libraries\net\neoforged\neoforge\%NEOFORGE%\win_args.txt"
set "TEMURIN=https://adoptium.net/temurin/releases/?version=21"

rem 1. Java 21: JAVA_HOME, then java on PATH.
set "JAVA="
if defined JAVA_HOME call :try_java "%JAVA_HOME%\bin\java.exe"
if not defined JAVA for /f "delims=" %%J in ('where java 2^>nul') do if not defined JAVA call :try_java "%%J"
if defined JAVA goto :defaults
echo [start] This server needs Java 21, and none was found. Looked at:
if defined JAVA_HOME echo   JAVA_HOME: %JAVA_HOME%
if not defined JAVA_HOME echo   JAVA_HOME: not set
echo   java on PATH:
where java 2>nul || echo     none
echo [start] Install Temurin 21 from %TEMURIN%
echo [start] A newer Java won't do; Java 21 installs alongside it.
pause
exit /b 1

:defaults
echo [start] Java: %JAVA%

rem 2. Default settings, only where there's no file yet: an update never overwrites them.
if not exist server.properties copy defaults\server.properties server.properties >nul
if not exist user_jvm_args.txt copy defaults\user_jvm_args.txt user_jvm_args.txt >nul

rem 3. NeoForge, on the first start and after an update that changes its version. It leaves an
rem existing user_jvm_args.txt alone.
if exist "%ARGS_FILE%" goto :eula
echo [start] Installing NeoForge %NEOFORGE%. It downloads Minecraft's server, which takes a minute.
"%JAVA%" -jar "neoforge-%NEOFORGE%-installer.jar" --installServer . >nul 2>&1
if errorlevel 1 goto :install_failed
if exist "%ARGS_FILE%" goto :eula
:install_failed
set "LOG=neoforge-%NEOFORGE%-installer.jar.log"
echo [start] The NeoForge installer failed. The end of its log, %LOG%:
set "SKIP=0"
if exist "%LOG%" for /f %%N in ('find /c /v "" ^< "%LOG%"') do set /a SKIP=%%N-20
if %SKIP% lss 0 set "SKIP=0"
if exist "%LOG%" more +%SKIP% "%LOG%"
pause
exit /b 1

rem 4. The EULA, asked once.
:eula
findstr /b /c:"eula=true" eula.txt >nul 2>&1 && goto :run
echo [start] Minecraft's EULA: https://aka.ms/MinecraftEULA
set "ANSWER="
set /p "ANSWER=Do you accept the Minecraft EULA? [y/N] "
if /i "%ANSWER%"=="y" goto :accept
echo [start] Not accepted. The server can't start without it.
pause
exit /b 1
:accept
> eula.txt echo # Accepted at the start script's prompt: https://aka.ms/MinecraftEULA
>> eula.txt echo eula=true

rem 5 and 6. Run, and restart only after a crash: the server reached Done in this run, and a crash
rem report appeared during it. NeoForge exits 0 after a failed load too, so the exit code can't
rem tell a crash from a stop. latest.log counts as this run's when its time or size changed.
:run
call :count_crashes
set "CRASHES_BEFORE=%COUNT%"
call :log_stamp
set "LOG_BEFORE=%STAMP%"
"%JAVA%" @user_jvm_args.txt @%ARGS_FILE% nogui %*
set "CODE=%ERRORLEVEL%"
call :count_crashes
if %COUNT% leq %CRASHES_BEFORE% goto :stopped
call :log_stamp
if "%STAMP%"=="%LOG_BEFORE%" goto :stopped
findstr /c:"Done (" logs\latest.log >nul 2>&1 || goto :stopped
echo [start] Server crashed. Restarting in 10 seconds, Ctrl+C to quit.
timeout /t 10
goto :run
:stopped
echo [start] The server stopped (exit code %CODE%).
pause
exit /b %CODE%

rem Sets JAVA to %1 when it's Java 21. findstr's . stands for the quote in: version "21
:try_java
if not exist "%~1" goto :eof
"%~1" -version 2>&1 | findstr /r /c:"version .21" >nul && set "JAVA=%~1"
goto :eof

rem Sets COUNT to the number of files in crash-reports\.
:count_crashes
set "COUNT=0"
if exist crash-reports\ for %%F in (crash-reports\*) do set /a COUNT+=1
goto :eof

rem Sets STAMP to logs\latest.log's time and size, or none.
:log_stamp
set "STAMP=none"
if exist logs\latest.log for %%F in (logs\latest.log) do set "STAMP=%%~tF %%~zF"
goto :eof
