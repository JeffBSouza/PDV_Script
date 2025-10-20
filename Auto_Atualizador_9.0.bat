@echo off
setlocal enabledelayedexpansion
REM chcp 65001


REM https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Util/Auto_Atualizador.zip

REM ----------- SCRIPT VRS 9.0 ------------
REM 


set version=9.0
set "dllsitef_vrs=7.0.117.108.r1"

REM -- Inicia Menu
goto menu

REM ========================================================================
REM #################### limpezaFoldersFiles ####################
:limpezaFoldersFiles

REM limpeza pasta %temp%\Auto_Atualizador
if exist %temp%\Auto_Atualizador (
	rmdir /S /Q %temp%\Auto_Atualizador >nul 2>&1
	mkdir %temp%\Auto_Atualizador >nul 2>&1
) else ( 
mkdir %temp%\Auto_Atualizador >nul 2>&1
)
exit /b
REM #################### limpezaFoldersFiles ####################

REM #################### validaVersoesWindows ####################
:validaVersoesWindows
REM ===================== VERIFICA VERSAO WINDOWS ===========================
for /f "tokens=4-7 delims=[.] " %%i in ('ver') do (if %%i==Version (set v=%%j.%%k) else (set v=%%i.%%j))
if "%v%" == "6.1" (set winvrs=Win 7& goto versionArquiteturaWindows)
if "%v%" == "6.2" (set winvrs=Win 8& goto versionArquiteturaWindows)
if "%v%" == "6.3" (set winvrs=Win 8.1& goto versionArquiteturaWindows)
if "%v%" == "6.4" (set winvrs=Win 8& goto versionArquiteturaWindows)
if "%v%" == "10.0" (set winvrs=Win 10& goto versionArquiteturaWindows)

:versionArquiteturaWindows
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set winx=x64
    exit /b
) else (
    set winx=x86
    exit /b
)
REM #################### validaVersoesWindows ####################

REM #################### validaStartPath ####################
:validaStartPath
REM ------------ check folder path ------------
if not exist c:\pdv\util\Programs (
	echo:
	echo PASTA E BAT FORA DO CAMINHO PADRAO c:\pdv\util, COPIAR PARA PASTA PADRAO.
	mkdir "c:\pdv\util" >nul 2>&1
	pause
	exit
)
exit /b
REM #################### validaStartPath ####################

REM #################### setGlobalVariaveis ####################
:setGlobalVariaveis
set AND=IF
set wget="c:\pdv\util\Programs\wget\wget.exe"

REM ----------- JAVA Variaveis ---------------
SET holdjavainstall=msg/time:60 * "JAVA SERA INSTALADO, AGUARDE A MENSAGEM DE "JAVA INSTALADO""
SET javainstalled=msg/time:60 * "JAVA JA INSTALADO"
SET javadownloaderror=msg/time:60 * "ERRO DOWNLOAD DO JAVA"
SET javainstallerror=msg/time:60 * "ERRO AO INSTALAR JAVA"
SET javainstallsuccess=msg/time:60 * "JAVA INSTALADO COM SUCESSO !!!!!"

SET java251="https://javadl.oracle.com/webapps/download/AutoDL?BundleId=242058_3d5a2bb8f8d4428bbe94aed7ec7ae784"

REM set java251link="https://javadl.oracle.com/webapps/download/AutoDL?BundleId=242058_3d5a2bb8f8d4428bbe94aed7ec7ae784"
REM set java271link="https://javadl.oracle.com/webapps/download/AutoDL?BundleId=243735_61ae65e088624f5aaa0b1d2d801acb16"
REM set java291link="https://javadl.oracle.com/webapps/download/AutoDL?BundleId=244582_d7fc238d0cbf4b0dac67be84580cfb4b"

set java251link="https://storage.googleapis.com/linux-pdv/Jeff/java_version/jre-8u251-windows-i586.exe"
set java291link="https://storage.googleapis.com/linux-pdv/Jeff/java_version/jre-8u291-windows-i586.exe"
set java301link="https://storage.googleapis.com/linux-pdv/Jeff/java_version/jre-8u301-windows-i586.exe"
set javaXXXlink="https://javadl.oracle.com/webapps/download/AutoDL?BundleId=245805_df5ad55fdd604472a86a45a217032c7d"
REM set javaRemoverLink="https://javadl-esd-secure.oracle.com/update/jut/JavaUninstallTool.exe"
set javaRemoverLink="https://storage.googleapis.com/linux-pdv/Jeff/java_version/JavaUninstallTool.exe"
REM ----------- JAVA Variaveis ---------------

REM ----------- NOTEPAD++ Variaveis ---------------
set notepad="https://storage.googleapis.com/linux-pdv/Jeff/Ninite_Notepad_Installer.exe"
REM ----------- NOTEPAD++ Variaveis ---------------

REM ----------- GSURF Variaveis ---------------
SET certificadogsurf="https://gsurf.com.br/lib/win/certificado.zip"
SET clientgsurf="https://gsurf.com.br/lib/win/gsclient.zip"
SET errodowncertificadogsurf=msg/time:240 * "ERRO DOWNLOAD CERTIFICADO GSURF, RETORNANDO MENU PRINCIPAL"
SET erroextractcertificadogsurf=msg/time:240 * "ERRO EXTRAIR CERTIFICADO GSURF, RETORNANDO MENU PRINCIPAL"
SET errodownclientegsurf=msg/time:240 * "ERRO DOWNLOAD Client GSURF, RETORNANDO MENU PRINCIPAL"
SET erroextractclientegsurf=msg/time:240 * "ERRO EXTRAIR Client GSURF, RETORNANDO MENU PRINCIPAL"
REM ----------- GSURF Variaveis ---------------

REM ----------- NetFrame Variaveis ---------------
set installnetframe=msg/time:120 * "INSTALANDO NETFramework, AGUARDE FINALIZACAO"
SET netframeinstallerror=msg/time:240 * "ERRO AO INSTALAR NETFramework"
SET netframeinstallsuccess=msg/time:120 * "NETFramework INSTALADO COM SUCESSO !!!!!"
SET netframework="https://storage.googleapis.com/linux-pdv/Jeff/NetFramework-4.5.2-x86-x64.exe"
REM ----------- NetFrame Variaveis ---------------

REM ----------- Service Pack 1 Variaveis ---------------
set installsp1=msg/time:120 * "INSTALANDO SERVICE PACK 1, AGUARDE FINALIZACAO"
set servicepackx86="https://storage.googleapis.com/linux-pdv/Jeff/windows6.1-KB976932-X86.exe"
set servicepackx64="https://storage.googleapis.com/linux-pdv/Jeff/windows6.1-KB976932-X64.exe"
REM ----------- Service Pack 1 Variaveis ---------------

REM ----------- Firebird Variaveis ---------------
set firebirdlink="https://storage.googleapis.com/linux-pdv/Jeff/Firebird-2.5.2.26540_0_Win32.exe"
REM ----------- Firebird Variaveis ---------------

call :datetime
set bkpOldDlls32="c:\pdv\util\DllsSitefBKP\BKP_System32\BKP_%dateTime%"
set bkpOldDlls64="c:\pdv\util\DllsSitefBKP\BKP_SysWOW64\BKP_%dateTime%"
exit /b
REM #################### setGlobalVariaveis ####################

REM #################### checkJavaVersion ####################
:checkJavaVersion
set javacheck=0
if exist "C:\Program Files\Java" (
    for /f %%A in ('dir "C:\Program Files\Java" /b ^| findstr /r "^jre1\.8\.0_[0-9][0-9][0-9]$"') do (
      set "javaversao=%%A"
      set "winsystem=C:\Program Files"
      goto :achou
    )
)

if exist "C:\Program Files (x86)\Java" (
    for /f %%A in ('dir "C:\Program Files (x86)\Java" /b ^| findstr /r "^jre1\.8\.0_[0-9][0-9][0-9]$"') do (
      set "javaversao=%%A"
      set "winsystem=C:\Program Files (x86)"
      goto :achou
    )
)

goto :notFoundJava

:achou
for /f "tokens=2 delims=_" %%V in ("!javaversao!") do set "javacheck=%%V"
goto :foundJava

:foundJava
REM === Define executáveis com base na versão detectada ===
set javaexec=%winsystem%\Java\jre1.8.0_%javacheck%\bin\java.exe
set javawexec=%winsystem%\Java\jre1.8.0_%javacheck%\bin\javaw.exe
set javawsexec=%winsystem%\Java\jre1.8.0_%javacheck%\bin\javaws.exe

REM === Define atalhos do javapath ===
set "commonpath=%winsystem:Program Files=Common Files%"
set javapath_java=%commonpath%\Oracle\Java\javapath\java.exe
set javapath_javaw=%commonpath%\Oracle\Java\javapath\javaw.exe
set javapath_javaws=%commonpath%\Oracle\Java\javapath\javaws.exe

set printjavamenu="Versao java instalada: %javacheck%"
exit /b

:notFoundJava
set "printjavamenu=Versao java instalada: JAVA NAO INSTALADO"
exit /b
REM #################### checkJavaVersion ####################

REM #################### datetime ####################
:datetime
set data=%date:~6,4%_%date:~3,2%_%date:~0,2%
set hora=%time:~0,2%-%time:~3,2%
if "%hora:~0,1%"==" " set hora=0%hora:~1%
set dateTime=%data%_%hora%
exit /b
REM #################### datetime ####################

REM #################### menu ####################
:menu
call :limpezaFoldersFiles &
call :validaVersoesWindows &
call :validaStartPath &
call :setGlobalVariaveis &
call :checkJavaVersion &

cls
REM =========== MAIN MENU ================
REM color [fundo][letra]
color 80  &:: Fundo Cinza, Letras Pretas
REM color 0C  &:: Fundo preto, texto vermelho claro (mais vibrante)
REM color 0E  &:: Fundo preto, texto amarelo claro (mais legível)
REM color 6F  &:: Fundo amarelo escuro, letra branca (simula laranja)

time /t        date /t
echo:
echo Windows %winvrs% %winx%
echo Computador: %computername%        Usuario: %username%
echo %printjavamenu%
echo:
echo ====================================
echo            MENU PRINCIPAL
echo ====================================
echo * 1. SAIR
echo * 2. DLLs Sitef
echo * 3. Permissoes Pasta PDV e VR
echo * 4. Copiando Driver/Sat para System32 / SysWoW64
echo * -------------------------------------
echo * 5. JAVA Submenus
echo * 6. VPN Sitef / Gsurf Submenus
echo * 7. Firebird Instalar / Reinstalar
echo * 8. Drivers Submenus
echo * -------------------------------------
echo * 9. Sharing pasta PRINTERS - Printer Shared
echo * 10. Notepad++
echo * 11. Banco_PDV
echo * -------------------------------------
echo * 12. CheckList PDV
echo =====================================
echo Version: %version%

set /p opcao= Escolha uma opcao: 
echo ------------------------------
if %opcao% equ 1 cls & exit
if %opcao% equ 2 cls & call :menudllsitef & goto menu
if %opcao% equ 3 cls & call :permissoesdriversat & pause & goto menu
if %opcao% equ 4 cls & call :copiardlls & pause & goto menu
if %opcao% equ 5 cls & goto menujava
if %opcao% equ 6 cls & goto menuvpnsitefgsurf
if %opcao% equ 7 call :firebirdInstallReinstall & pause & goto menu
if %opcao% equ 8 cls & goto menudrivers
if %opcao% equ 9 cls & call :shareprinters & pause & goto menu
if %opcao% equ 10 cls & call :notepad & goto menu
if %opcao% equ 11 goto opcao11
if %opcao% equ 12 goto checklistPdvMenu
if %opcao% GEQ 13 call :opcaoinexistente menu
if %opcao% EQU 0 call :opcaoinexistente menu
REM =========== MAIN MENU ================

:opcao11
cls
cd c:\pdv\util\Programs >nul 2>&1
start Banco_PDV.bat >nul 2>&1
goto menu
REM #################### menu ####################

REM #################### opcaoinexistente ####################
:opcaoinexistente
cls
echo:
echo OPCAO INEXISTENTE
timeout 1 >nul
goto %~1
REM #################### opcaoinexistente ####################

REM #################### checklistPdvMenu ####################
:checklistPdvMenu
call :checkJavaVersion
call :validastatusfirebird

cls
time /t        date /t
echo:
echo Windows %winvrs% %winx%
echo Computador: %computername%        Usuario: %username%
echo %printjavamenu%
echo %printstatusfirebird%
echo:
echo ================================================================
echo Essa opcao executara as funcoes automaticamente listadas abaixo.
echo:
echo 1. Atualizar DLL Sitef - "DllSitef_Atual"
echo 2. Copiar DLLs para System32 / SysWoW64
echo 3. Instalar/Reinstalar Firebird
echo 4. Instalar Java 301
echo 5. Permissoes Drivers SAT
echo ================================================================
echo:
echo * 1. Realizar Checklist PDV
echo * 2. Retornar Menu Principal
echo * 3. SAIR
set /p opcaoChecklistPdvMenu= Escolha uma opcao: 
if %opcaoChecklistPdvMenu% equ 1 goto checklistPDV
if %opcaoChecklistPdvMenu% equ 2 goto menu
if %opcaoChecklistPdvMenu% equ 3 cls & exit
if %opcaoJava% GEQ 4 call :opcaoinexistente checklistPdvMenu
if %opcaoJava% EQU 0 call :opcaoinexistente checklistPdvMenu

REM #################### checklistPdvMenu ####################

REM #################### checklistPDV ####################
:checklistPDV
call :atualizarDllSitef "DllSitef_Atual"
echo:
call :copiardlls
echo:
call :firebirdInstallReinstall
echo:
call :updateJavaVRS "%java301link%" 301
echo:
call :permissoesdriversat
cls
echo:
echo ============================
echo    CheckList PDV Completo
echo ============================
pause
goto menu
REM #################### checklistPDV ####################

REM #################### menujava ####################
:menujava
call :checkJavaVersion

cls
time /t        date /t
echo:
echo Windows %winvrs% %winx%
echo Computador: %computername%        Usuario: %username%
echo %printjavamenu%
echo:
echo =============================
echo            MENU JAVA
echo =============================
echo * 1. SAIR
echo * 2. JAVA e DLLS Sitef
echo * 3. JAVA Versoes
echo * 4. Java Uninstaller
REM echo * 5. Abrir PDV
REM echo * 6. Abrir PDV Config
echo * 7. Retornar Menu Principal
echo =============================

set /p opcaoJava= Escolha uma opcao: 
echo ------------------------------
if %opcaoJava% equ 1 cls & exit
if %opcaoJava% equ 2 call :atualizarJavaDllSitef & pause & goto menu
if %opcaoJava% equ 3 call :javaVersions & goto menu
if %opcaoJava% equ 4 call :javaUninstaller & goto menu
if %opcaoJava% equ 7 cls & goto menu
if %opcaoJava% GEQ 8 call :opcaoinexistente menujava
if %opcaoJava% EQU 0 call :opcaoinexistente menujava

REM #################### menujava ####################

REM #################### javaVersions ####################
:javaVersions
REM =========== JAVA VERSOES MENU ================
cls
echo:
echo %printjavamenu%
echo:
echo  ===================================
echo            MENU JAVA VERSOES
echo  ===================================
echo * 1. SAIR
echo * 2. JAVA 251
echo * 3. JAVA 291
echo * 4. JAVA 301
echo * 5. JAVA Mais Atual
echo * 6. Retornar Menu Principal
echo  ====================================

set /p opcaoJavavrs= Escolha uma opcao: 
echo ------------------------------
if %opcaoJavavrs% equ 1 exit
if %opcaoJavavrs% equ 2 call :updateJavaVRS "%java251link%" 251 & goto menu
if %opcaoJavavrs% equ 3 call :updateJavaVRS "%java291link%" 291 & goto menu
if %opcaoJavavrs% equ 4 call :updateJavaVRS "%java301link%" 301 & goto menu
if %opcaoJavavrs% equ 5 call :updateJavaVRS "%javaXXXlink%" Latest & goto menu
if %opcaoJavavrs% equ 6 goto menu
if %opcaoJavavrs% GEQ 7 call :opcaoinexistente javaVersions
if %opcaoJavavrs% EQU 0 call :opcaoinexistente javaVersions

REM #################### javaVersions ####################

REM #################### validavpnsitefgsurf ####################
:validavpnsitefgsurf
set vpnmodelo=0

rem -----------------------------------
set "serviceName=GSurfRSA Listener"
set "serviceStatus="

if exist C:\Windows\SysWOW64\CONFITLS.ini (
  set vpnmodelo=1
  goto validavpnsitefgsurf2
)
if exist C:\Windows\System32\CONFITLS.ini (
  set vpnmodelo=1
  goto validavpnsitefgsurf2
)
rem -----------------------------------
rem -----------------------------------
for /f "tokens=3 delims=: " %%H in ('sc query "%serviceName%" ^| findstr "STATE"') do (
    set "serviceStatus=%%H"
)
if %errorlevel% EQU 0 (
	for /f "tokens=3 delims=: " %%H in ('sc query "%serviceName%" ^| findstr "ESTADO"') do (
		set "serviceStatus=%%H"
	)
)
if /i "%serviceStatus%" equ "RUNNING" (
    set vpnmodelo=2
) else (
    set vpnmodelo=2
)
exit /b
REM #################### validavpnsitefgsurf ####################
REM #################### validavpnsitefgsurf2 ####################
:validavpnsitefgsurf2
if %vpnmodelo% equ 0 set vpnmodeloprint=Nenhum
if %vpnmodelo% equ 1 set vpnmodeloprint=VPN Sitef Express
if %vpnmodelo% equ 2 set vpnmodeloprint=Gsurf
exit /b
REM #################### validavpnsitefgsurf2 ####################

REM #################### menuvpnsitefgsurf ####################
:menuvpnsitefgsurf
call :validavpnsitefgsurf
call :validavpnsitefgsurf2

cls
time /t        date /t
echo:
echo Windows %winvrs% %winx%
echo Computador: %computername%        Usuario: %username%
echo:
echo ====================================
echo            MENU VPN
echo Modelo VPN Ativo: %vpnmodeloprint%
echo ====================================
echo * 1. SAIR
echo * 2. GSURF
echo * 3. VPN Sitef (TLS)
echo * 4. Retornar Menu Principal
echo ====================================

set /p opcaoVPN= Escolha uma opcao: 
echo ------------------------------
if %opcaoVPN% equ 1 cls & exit
if %opcaoVPN% equ 2 goto menugsurf
if %opcaoVPN% equ 3 cls & call :installVPNSitef
if %opcaoVPN% equ 4 goto menu
if %opcaoVPN% GEQ 5 call :opcaoinexistente menuvpnsitefgsurf
if %opcaoVPN% EQU 0 call :opcaoinexistente menuvpnsitefgsurf
REM #################### menuvpnsitefgsurf ####################

REM #################### installVPNSitef ####################
:installVPNSitef
cls
echo:
echo Instalando/Reinstalando TLS Sitef Express
echo:

set SitefFolder=C:\CliSiTef\NaoExcluirControleCliSiTef
if exist %SitefFolder% (
del /q "%SitefFolder%\*.*" >nul 2>&1
for /d %%x in ("%SitefFolder%\*") do rmdir /s /q "%%x" >nul 2>&1
)

del /q "c:\pdv\util\CONFITLS.ini" >nul 2>&1

REM -- Define variavel %dateTime%
call :datetime

if exist C:\Windows\SysWOW64\CONFITLS.ini (
echo Deletando C:\Windows\SysWOW64\CONFITLS.ini
echo:
del /q "c:\pdv\util\CONFITLS.ini" >nul 2>&1
)
if exist C:\Windows\System32\CONFITLS.ini (
mkdir C:\pdv\util\BKP_VPN_CONFITLS >nul 2>&1
move "C:\Windows\System32\CONFITLS.ini" "C:\pdv\util\BKP_VPN_CONFITLS\CONFITLS_%dateTime%.ini"
)

echo Cliente utiliza Proxy ?
echo * 1. SIM
echo * 2. NAO
set /p opcaoproxy= Escolha uma opcao: 
echo ------------------------------
if %opcaoproxy% equ 1 goto opcaoproxy1
if %opcaoproxy% equ 2 goto opcaoproxy2
if %opcaoproxy% GEQ 3 goto menuvpnsitefgsurf
if %opcaoproxy% EQU 0 goto menuvpnsitefgsurf

:opcaoproxy1
echo:
echo Informe o IP do Proxy
set /p ipproxy= IP Proxy: 
echo Informe a PORTA do Proxy
set /p portaproxy= PORTA proxy: 
echo Informe o Token VPN Sitef Express
set /p tokenVPNSitef= Insira o Token: 

echo [ConfiguracaoTLS] >> c:\pdv\util\CONFITLS.ini
echo TipoComunicacaoExterna=TLSGWP >> c:\pdv\util\CONFITLS.ini
echo URLTLS=tls-prod.fiservapp.com >> c:\pdv\util\CONFITLS.ini
echo GwpTipoProxy=http >> c:\pdv\util\CONFITLS.ini
echo GwpEnderecoProxy=%ipproxy%:%portaproxy% >> c:\pdv\util\CONFITLS.ini
REM GwpEnderecoProxy= 127.0.0.1:1234
echo TokenRegistro=%tokenVPNSitef% >> c:\pdv\util\CONFITLS.ini
goto vpnsitefcontinue

:opcaoproxy2
echo Informe o Token VPN Sitef Express
set /p tokenVPNSitef= Insira o Token: 

echo [ConfiguracaoTLS] >> c:\pdv\util\CONFITLS.ini
echo TipoComunicacaoExterna=TLSGWP >> c:\pdv\util\CONFITLS.ini
echo URLTLS=tls-prod.fiservapp.com >> c:\pdv\util\CONFITLS.ini
echo TokenRegistro=%tokenVPNSitef% >> c:\pdv\util\CONFITLS.ini
goto vpnsitefcontinue

:vpnsitefcontinue
call :datetime
if exist C:\gsurfssl (
    net stop "GSurfRSA Listener" >nul 2>&1
    sc config "GSurfRSA Listener" start= Disabled >nul 2>&1
	ren "C:\gsurfssl" "Gsurfssl-Desativada_TLS-Ativada"
    echo GSURF_Desativada_%dateTime% >> c:\pdv\util\GSURF_Desativada_%dateTime%.txt
    echo GSURF_Desativada_%dateTime% >> c:\pdv\util\GSURF_Desativada_%dateTime%.txt
    echo GSURF_Desativada_%dateTime% >> c:\pdv\util\TLS_Ativada_%dateTime%.txt
)

call :UpdateOrAddTokenTLS "C:\vr\vr.properties" "%tokenVPNSitef%"

REM #################### UpdateOrAddTokenTLS ####################
:UpdateOrAddTokenTLS
set "file=%~1"
set "value=%~2"
set "found=false"

(
    for /f "usebackq delims=" %%A in ("%file%") do (
        set "line=%%A"
        if "!line:~0,9!"=="tokentls=" (
            set "found=true"
            echo tokentls=%value%
        ) else (
            echo !line!
        )
    )
    if "!found!"=="false" (
        echo tokentls=%value%
    )
) > "%file%.tmp"

rem Substitui o arquivo original pelo temporário
move /y "%file%.tmp" "%file%" >nul
REM #################### UpdateOrAddTokenTLS ####################

cacls c:\pdv\util\CONFITLS.ini /E /T /C /P Todos:F REDE:F >nul 2>&1

set CONFITLS=0
if "%winx%"=="x64" (
  copy c:\pdv\util\CONFITLS.ini C:\Windows\SysWOW64\ /Y >nul 2>&1
  cacls C:\Windows\SysWOW64\CONFITLS.ini /E /T /C /P Todos:F REDE:F >nul 2>&1
  del /q c:\pdv\util\CONFITLS.ini >nul 2>&1
  set CONFITLS=64
) else (
  copy c:\pdv\util\CONFITLS.ini C:\Windows\System32\ /Y >nul 2>&1
  cacls C:\Windows\System32\CONFITLS.ini /E /T /C /P Todos:F REDE:F >nul 2>&1
  del /q c:\pdv\util\CONFITLS.ini >nul 2>&1
  set CONFITLS=32
)

if %CONFITLS% neq 0 (
	if %CONFITLS% equ 64 (
	echo:
	echo Arquivo CONFITLS.ini configurado com sucesso em C:\Windows\SysWOW64
	)
	if %CONFITLS% equ 32 (
	echo:
	echo Arquivo CONFITLS.ini configurado com sucesso em C:\Windows\System32
	)
) else (
    echo:
	echo Arquivo CONFITLS.ini NAO configurado
    pause
    goto menu
)

REM -- Atualiza Dll Sitef
call :atualizarDllSitef "DllSitef_Atual"


call :checkJavaVersion
if %javacheck% LEQ 241 (
call :updateJavaVRS "%java301link%" 301
)

echo:
echo ============================
echo TLS - Sitef Express Completo
echo ============================
pause
goto menu
REM #################### installVPNSitef ####################

REM #################### desativarvpnsitef ####################
:desativarvpnsitef
set data=%date:~6,4%_%date:~3,2%_%date:~0,2%
set hora=%time:~0,2%-%time:~3,2%
set dateTime=%data%_%hora%
if exist C:\Windows\SysWOW64\CONFITLS.ini (
  del /q C:\Windows\SysWOW64\CONFITLS.ini >nul 2>&1
  echo VPN_TLS_Desativada_%dateTime% >> c:\pdv\VPN_TLS_Desativada_%dateTime%.txt
  echo VPN_TLS_Desativada_%dateTime% >> c:\VPN_TLS_Desativada_%dateTime%.txt
  echo VPN_TLS_Desativada_%dateTime% >> c:\Gsurf_Ativada_%dateTime%.txt
)
if exist C:\Windows\System32\CONFITLS.ini (
  del /q C:\Windows\SysWOW64\CONFITLS.ini >nul 2>&1
  echo VPN_TLS_Desativada_%dateTime% >> c:\pdv\VPN_TLS_Desativada_%dateTime%.txt
  echo VPN_TLS_Desativada_%dateTime% >> c:\VPN_TLS_Desativada_%dateTime%.txt
  echo VPN_TLS_Desativada_%dateTime% >> c:\Gsurf_Ativada_%dateTime%.txt
)
exit /b
REM #################### desativarvpnsitef ####################

REM #################### menugsurf ####################
:menugsurf
cls
time /t        date /t
echo:
echo Windows %winvrs% %winx%
echo Computador: %computername%        Usuario: %username%
echo:
echo ====================================
echo            MENU GSURF
echo ====================================
echo * 1. SAIR
echo * 2. Gsurf - Completo
echo * 3. Gsurf Express APENAS
echo * 4. Retornar Menu Principal
echo ====================================

set /p opcaoGsurf= Escolha uma opcao: 
echo ------------------------------
if %opcaoGsurf% equ 1 cls & exit
if %opcaoGsurf% equ 2 call :desativarvpnsitef & call :gsurfFullInstall & goto menu
if %opcaoGsurf% equ 3 call :desativarvpnsitef & call :gsurfFilesOnly & goto menu
if %opcaoGsurf% equ 4 goto menu
if %opcaoGsurf% GEQ 5 call :opcaoinexistente menugsurf
if %opcaoGsurf% EQU 0 call :opcaoinexistente menugsurf
REM #################### menugsurf ####################

REM #################### validastatusfirebird ####################
:validastatusfirebird
set "serviceName=FirebirdGuardianDefaultInstance"
set "serviceStatus="

if exist "C:\Program Files (x86)\Firebird" (
	set firebirdcheckstatus=1
) else (
    set firebirdcheckstatus=0
)

for /f "tokens=3 delims=: " %%H in ('sc query "%serviceName%" ^| findstr "STATE"') do (
    set "serviceStatus=%%H"
)
if %errorlevel% EQU 0 (
	for /f "tokens=3 delims=: " %%H in ('sc query "%serviceName%" ^| findstr "ESTADO"') do (
		set "serviceStatus=%%H"
	)
)

if /i "%serviceStatus%" equ "RUNNING" (
    set firebirdcheckstatus=1
) else (
    set firebirdcheckstatus=0
)

if %firebirdcheckstatus% equ 1 set printstatusfirebird="Status Firebird: Online"
if %firebirdcheckstatus% equ 0 set printstatusfirebird="Status Firebird: Offline"
exit /b
REM #################### validastatusfirebird ####################

REM #################### firebirdInstallReinstall ####################
:firebirdInstallReinstall
call :firebirdDownload
call :firebirdRemove
call :firebirdInstall

exit /b

:firebirdDownload
echo:
echo Realizando Download Firebird-2.5.2.26540_0_Win32, Aguarde . . .

if not exist C:\pdv\util\Firebird-2.5.2.26540_0_Win32.exe (
	%wget% --no-check-certificate %firebirdlink% -O C:\pdv\util\Firebird-2.5.2.26540_0_Win32.exe >nul 2>&1
		if not exist C:\pdv\util\Firebird-2.5.2.26540_0_Win32.exe (
		echo:
		echo Arquivo Firebird-2.5.2.26540_0_Win32.exe nao encontrado, verifique e faca o processo manual
		pause
		goto menu
	)
)
exit /b

:firebirdRemove
if exist "%PROGRAMFILES(X86)%\Firebird" (
	echo:
	echo Removendo Firebird...Aguarde . . .
	echo:
	net stop "Firebird Guardian - DefaultInstance" >nul 2>&1
	net stop "Firebird Server - DefaultInstance" >nul 2>&1
	cd /d "C:\Program Files (x86)\Firebird\Firebird_2_5"
	if %errorlevel% EQU 0 (
	start  "" /WAIT "C:\Program Files (x86)\Firebird\Firebird_2_5\unins000.exe" /SILENT
	timeout 2 >nul 2>&1
	)
	cd /d c:\
	rd /s /q "C:\Program Files (x86)\Firebird" >nul 2>&1
	echo Firebird-2.5.2.26540_0_Win32 Desinstalado.
	exit /b
) else (
	exit /b
)

:firebirdInstall
if exist C:\pdv\util\Firebird-2.5.2.26540_0_Win32.exe (
	echo:
	echo Instalando Firebird-2.5.2.26540_0_Win32...Aguarde . . .
	cd /d C:\pdv\util
	start "" /WAIT Firebird-2.5.2.26540_0_Win32.exe /SILENT
		if %errorlevel% neq 0 (
			cls
			echo:
			echo Falha na instalacao do Firebird
			pause
			goto menu
		) else (
			echo:
			echo Firebird instalado com sucesso!
			exit /b
		)
)

REM #################### firebirdInstallReinstall ####################

REM #################### menudrivers ####################
:menudrivers

rem ---- LINKS IMPRESSORAS -----
set bema4200="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Impressoras/Bema_4200_Package.zip"
set bema4200hs="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Impressoras/Bematech_4200_HS_Package.zip"
set elgini9="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Impressoras/Elgin_i9_Package.zip"
set epsontmt="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Impressoras/Epson_Package.zip"
set sweda="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Impressoras/Sweda_Package.zip"
set tanca="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Impressoras/Tanca_Package.zip"
rem ---- LINKS IMPRESSORAS -----
rem ---- LINKS SATS -----
set bemagotoelgin="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/SAT/BemaGo_to_Elgin_Package.zip"
set bemarb="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/SAT/BematechRB2000_Package.zip"
set dimep="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/SAT/Dimep_Package.zip"
set elginsmart="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/SAT/Elgin_Smart_Package_Win.zip"
set gertecepson="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/SAT/Gertec_Epson_Package.zip"
set satsweda="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/SAT/SAT_SWEDA_Package.zip"
set sateelginlinker="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/SAT/Elgin_Linker_1_Package.zip"
set controlid="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/SAT/Sat_Control_ID_Package.zip"
set sattanca="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/SAT/Sat_Tanca_Package.zip"
rem ---- LINKS SATS -----
rem ---- LINKS PINPAD -----
set gertecpinpad="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Pinpad/Gertec_Package.zip"
set ingenico="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Pinpad/Ingenico_Package.zip"
rem ---- LINKS PINPAD -----
rem ---- LINKS TECLADO -----
set tecladogertec="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Teclado/Gertec_Tec44_Tec55_PS2Geral.zip"
set tecladosmak="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Teclado/SMAK_Package.zip"
rem ---- LINKS TECLADO -----
rem ---- LINKS UTEIS -----
set biometria_hamsterdx_win="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Biometria/Hamster_Win.zip"
rem ---- LINKS UTEIS -----

cls
time /t        date /t
echo:
echo Windows %winvrs% %winx%
echo Computador: %computername%        Usuario: %username%
echo:
echo ============================
echo          MENU DRIVERS
echo ============================
echo * 1. SAIR
echo * 2. Impressora
echo * 3. SAT
echo * 4. Teclado
echo * 5. Pinpad
echo * 6. Util
echo * 7. MENU JAVA
echo * 8. Retornar Menu Principal
echo =============================

set /p opcaoJava= Escolha uma opcao: 
echo ------------------------------
if %opcaoJava% equ 1 cls & exit
if %opcaoJava% equ 2 goto menuimpressora & goto menu
if %opcaoJava% equ 3 goto menusat & goto menu
if %opcaoJava% equ 4 goto menuteclado & goto menu
if %opcaoJava% equ 5 goto menupinpad & goto menu
if %opcaoJava% equ 6 goto menuutil & goto menu
if %opcaoJava% equ 7 goto menujava & goto menu
if %opcaoJava% equ 8 goto menu
if %opcaoJava% GEQ 9 call :opcaoinexistente menu
if %opcaoJava% EQU 0 call :opcaoinexistente menu
REM #################### menudrivers ####################

REM #################### menuimpressora ####################
:menuimpressora

echo:
echo:
echo * 1. Bematech 4200 th
echo * 2. Bematech 4200 HS
echo * 3. Elgin i9
echo * 4. Epson TM T20 / T20x
echo * 5. Sweda
echo * 6. Tanca TP 650
echo * 7. Voltar Menu Drivers
echo * 8. Voltar Menu Principal
set /p opcaoImpressora= Escolha uma opcao: 
if %opcaoImpressora% equ 1 call :driversDown "%bema4200%" DriverImpressora "Bematech 4200 th" & goto menu
if %opcaoImpressora% equ 2 call :driversDown "%bema4200hs%" DriverImpressora "Bematech 4200 HS" & goto menu
if %opcaoImpressora% equ 3 call :driversDown "%elgini9%" DriverImpressora "Elgin i9" & goto menu
if %opcaoImpressora% equ 4 call :driversDown "%epsontmt%" DriverImpressora "Epson TM T20 / T20x" & goto menu
if %opcaoImpressora% equ 5 call :driversDown "%sweda%" DriverImpressora "Sweda" & goto menu
if %opcaoImpressora% equ 6 call :driversDown "%tanca%" DriverImpressora "Tanca TP 650" & goto menu
if %opcaoImpressora% equ 7 goto menudrivers
if %opcaoImpressora% equ 8 goto menu
if %opcaoImpressora% GEQ 9 call :opcaoinexistente menu
if %opcaoImpressora% EQU 0 call :opcaoinexistente menu
REM #################### menuimpressora ####################

REM #################### menusat ####################
:menusat
echo:
echo:
echo * 1. Converter BemaGo para Elgin
echo * 2. Bematech RB2000 / RB1000
echo * 3. Dimep
echo * 4. Elgin Smart
echo * 5. Elgin Linker/Erro 6099
echo * 6. Gertec / Epson
echo * 7. Sweda
echo * 8. ControlID
echo * 9. Tanca
echo * 10. Voltar Menu Drivers
echo * 11. Voltar Menu Principal
set /p opcaoSAT= Escolha uma opcao: 
if %opcaoSAT% equ 1 call :driversDown "%bemagotoelgin%" DriverSAT "BemaGo para Elgin" & goto menu
if %opcaoSAT% equ 2 call :driversDown "%bemarb%" DriverSAT "Bematech RB2000 / RB1000" & goto menu
if %opcaoSAT% equ 3 call :driversDown "%dimep%" DriverSAT "Dimep" & goto menu
if %opcaoSAT% equ 4 call :driversDown "%elginsmart%" DriverSAT "Elgin Smart" & goto menu
if %opcaoSAT% equ 5 call :driversDown "%sateelginlinker%" DriverSAT "Elgin Linker/Erro 6099" & goto menu
if %opcaoSAT% equ 6 call :driversDown "%gertecepson%" DriverSAT "Gertec / Epson" & goto menu
if %opcaoSAT% equ 7 call :driversDown "%satsweda%" DriverSAT "Sweda" & goto menu
if %opcaoSAT% equ 8 call :driversDown "%controlid%" DriverSAT "ControlID" & goto menu
if %opcaoSAT% equ 9 call :driversDown "%sattanca%" DriverSAT "Tanca" & goto menu
if %opcaoSAT% equ 10 goto menudrivers
if %opcaoSAT% equ 11 goto menu
if %opcaoSAT% GEQ 12 call :opcaoinexistente menu
if %opcaoSAT% EQU 0 call :opcaoinexistente menu
REM #################### menusat ####################

REM #################### menuteclado ####################
:menuteclado
echo:
echo:
echo * 1. Gertec
echo * 2. Smak
echo * 3. Voltar Menu Drivers
echo * 4. Voltar Menu Principal
set /p opcaoTeclado= Escolha uma opcao: 
if %opcaoTeclado% equ 1 call :driversDown "%tecladogertec%" DriverTeclado "Gertec" & goto menu
if %opcaoTeclado% equ 2 call :driversDown "%tecladosmak%" DriverTeclado "Smak" & goto menu
if %opcaoTeclado% equ 3 goto menudrivers
if %opcaoTeclado% equ 4 goto menu
if %opcaoTeclado% GEQ 5 call :opcaoinexistente menu
if %opcaoTeclado% EQU 0 call :opcaoinexistente menu
REM #################### menuteclado ####################

REM #################### menupinpad ####################
:opcaoDrivers5
echo:
echo:
echo * 1. Gertec
echo * 2. Ingenico
echo * 3. Voltar Menu Drivers
echo * 4. Voltar Menu Principal
set /p opcaoPinpad= Escolha uma opcao: 
if %opcaoPinpad% equ 1 call :driversDown "%gertecpinpad%" DriverPinpad "Gertec" & goto menu
if %opcaoPinpad% equ 2 call :driversDown "%ingenico%" DriverPinpad "Ingenico" & goto menu
if %opcaoPinpad% equ 3 goto menudrivers
if %opcaoPinpad% equ 4 goto menu
if %opcaoPinpad% GEQ 5 call :opcaoinexistente menu
if %opcaoPinpad% EQU 0 call :opcaoinexistente menu
REM #################### menupinpad ####################

REM #################### menuutil ####################
:opcaoDrivers6
echo:
echo:
echo * 1. Biometria Hamster DX
echo * 2. Firebird
echo * 3. NetFramework 4.5.2 Win7
echo * 4. Voltar Menu Drivers
echo * 5. Voltar Menu Principal
set /p opcaoUteis= Escolha uma opcao: 
if %opcaoUteis% equ 1 call :driversDown "%biometria_hamsterdx_win%" DriverBiometriaHamsterDX "Biometria Hamster DX" & goto menu
if %opcaoUteis% equ 2 call :firebirdInstallReinstall & goto menu
if %opcaoUteis% equ 3 call :driversDown "%netframework%" NetFramewok_452_Win7 "NetFramework 4.5.2 Win7" & goto menu
if %opcaoUteis% equ 4 goto menudrivers
if %opcaoUteis% equ 5 goto menu
if %opcaoUteis% GEQ 6 call :opcaoinexistente menu
if %opcaoUteis% EQU 0 call :opcaoinexistente menu
REM #################### menuutil ####################

REM #################### driversDown ####################
:driversDown
set driverLink=%~1
set driverName=%~2
set deviceName=%~3

echo:
echo Baixando %driverName% / %deviceName% ... Aguarde . . .

%wget% --no-check-certificate %driverLink% -O C:\pdv\util\%driverName%.zip >nul 2>&1
	if errorlevel 1 ( 
	echo ------------------
	echo ERRO DOWNLOAD %driverName%
	echo ------------------
	pause
	goto menu
	)

"C:\pdv\util\Programs\7zip\7z.exe" x C:\pdv\util\%driverName%.zip -oC:\pdv\util -y >nul 2>&1
	if errorlevel 1 ( 
	echo ---------------------------
	echo Erro Extracao %driverName%
	echo ---------------------------
	pause
	goto menu
	)

echo:
echo Driver %driverName% / %deviceName% baixado e extraido com sucesso!

del /q C:\pdv\util\%driverName%.zip >nul 2>&1
exit /b
REM #################### driversDown ####################

REM #################### menudllsitef ####################
:menudllsitef
echo:
echo ====================================
echo            MENU DLL SITEF
echo ====================================
echo * 1. SAIR
echo * 2. 7.0.117.89.r5
echo * 3. %dllsitef_vrs% (Atual)
echo * 4. Retornar Menu Principal
echo ====================================

set /p opcaoDllSitef= Escolha uma opcao: 
echo ------------------------------
if %opcaoDllSitef% equ 1 exit
if %opcaoDllSitef% equ 2 call :atualizarDllSitef "DllSitef_89r5" & pause & goto menu
if %opcaoDllSitef% equ 3 call :atualizarDllSitef "DllSitef_Atual" & pause & goto menu
if %opcaoDllSitef% equ 4 goto menu
if %opcaoDllSitef% GEQ 5 call :opcaoinexistente menudllsitef
if %opcaoDllSitef% EQU 0 call :opcaoinexistente menudllsitef

REM #################### menudllsitef ####################


REM #################### atualizarDllSitef ####################
:atualizarDllSitef
echo ----------------------
echo Atualizando Dlls Sitef
echo ----------------------

REM ===================== Declaracao de variaveis ===========================
set endmsg=msg/time:30 * "DLLS SITEF ATUALIZADAS, VERIFIQUE SE AS DLLS FORAM ATUALIZADAS"
set errodowndlls32=msg/time:30 * "ERRO DOWNLOAD DLLS SITEF"

REM set dllfile32="%temp%\Auto_Atualizador\tempdlls\%dllSitefFolder%"
set "dllfile32=%temp%\Auto_Atualizador\tempdlls\%~1"

set copyerror=Erro ao Copiar Dlls
set wget="c:\pdv\util\Programs\wget\wget.exe"
set dllsitefx86="https://storage.googleapis.com/linux-pdv/Jeff/Clisitef32_Win.zip"

call :datetime
set bkpOldDlls="c:\pdv\util\BKP_Dlls_Sitef_%dateTime%"

REM ===================== Declaracao de variaveis ===========================

taskkill /f /im java* >nul 2>&1
echo:
echo ==========================
echo      DLLs do Sitef         
echo ==========================
echo:
echo Renomeando ChavesClisitef ...
rmdir /S /Q C:\CliSiTef\ChavesCliSiTef >nul 2>&1

echo:
echo Ajustando Pasta para download Dlls Sitef ["%temp%\Auto_Atualizador\tempdlls"]
rmdir /S /Q "%temp%\Auto_Atualizador\tempdlls" >nul 2>&1
mkdir "%temp%\Auto_Atualizador\tempdlls" >nul 2>&1
timeout 2 >nul 2>&1

echo:
echo Baixando DLLS Sitef Win ... Aguarde ...
echo:
%wget% --no-check-certificate %dllsitefx86% -O %temp%\Auto_Atualizador\tempdlls\dllssitef.zip >nul 2>&1
if errorlevel 1 (
cls
echo:
echo ---------------------------
echo Erro Download DLLs do Sitef
echo ---------------------------
%errodowndlls32% >nul 2>&1
pause
goto menu
)

echo:
echo Extraindo dlls em TempDlls ...
echo:
"C:\pdv\util\Programs\7zip\7z.exe" x "%temp%\Auto_Atualizador\tempdlls\dllssitef.zip" -o"%temp%\Auto_Atualizador\tempdlls" -y >nul 2>&1
REM powershell -Command "Expand-Archive -LiteralPath '%temp%\Auto_Atualizador\tempdlls\dllssitef.zip' -DestinationPath '%temp%\Auto_Atualizador\tempdll' -Force"
if errorlevel 1 ( 
echo ---------------------------
echo Erro Extracao DLLs do Sitef
echo ---------------------------
pause
goto menu
)

REM  - Excluindo dllssitef.zip  
del /q %temp%\Auto_Atualizador\tempdlls\*.zip >nul 2>&1
del /q %temp%\Auto_Atualizador\tempdlls\*.pdf >nul 2>&1

if not exist "%dllfile32%" (
    echo Diretorio origem das dlls %dllfile32% não encontrado
	pause
	exit
)

REM Realizando BKP_Dlls_Sitef
echo Realizando Backup das dlls originais . . .
echo:

if exist "C:\Windows\SysWOW64\user32.dll" (
    mkdir %bkpOldDlls64%
    copy C:\Windows\SysWOW64\CliSiTef32I.dll %bkpOldDlls64% /Y >nul 2>&1
    copy C:\Windows\SysWOW64\libemv.dll %bkpOldDlls64% /Y >nul 2>&1
    copy C:\Windows\SysWOW64\QREncode32.dll %bkpOldDlls64% /Y >nul 2>&1
    copy C:\Windows\SysWOW64\RechargeRPC.dll %bkpOldDlls64% /Y >nul 2>&1
    copy C:\Windows\SysWOW64\Cheque.txt %bkpOldDlls64% /Y >nul 2>&1

    echo Copiando novas Dlls para SysWOW64...
    echo:
    echo Copiando de: %dllfile32% para SysWOW64
	for %%F in ("%dllfile32%\*.*") do (
		echo Copiando: %%~nxF
		copy "%%~F" C:\Windows\SysWOW64\ /Y
	)
    if errorlevel 1 call :copyerror
    if not exist "C:\Windows\SysWOW64\jCliSiTefI.dll" (
        copy C:\pdv\util\Programs\jClisitef\jCliSiTefI.dll C:\Windows\SysWOW64 /Y >nul 2>&1
    )
	echo Aplicando permissoes CliSitef.ini ...
	cacls C:\Windows\SysWOW64\CliSiTef.ini /E /T /C /P Todos:F REDE:F >nul 2>&1
	cacls C:\Windows\SysWOW64\CliSiTef32I.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
	cacls C:\Windows\SysWOW64\libemv.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
	cacls C:\Windows\SysWOW64\QREncode32.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
	cacls C:\Windows\SysWOW64\RechargeRPC.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
	explorer "C:\Windows\SysWOW64" >nul 2>&1
	
) else (
		mkdir %bkpOldDlls32%
		copy C:\Windows\System32\CliSiTef32I.dll %bkpOldDlls32% /Y >nul 2>&1
		copy C:\Windows\System32\libemv.dll %bkpOldDlls32% /Y >nul 2>&1
		copy C:\Windows\System32\QREncode32.dll %bkpOldDlls32% /Y >nul 2>&1
		copy C:\Windows\System32\RechargeRPC.dll %bkpOldDlls32% /Y >nul 2>&1
		copy C:\Windows\System32\Cheque.txt %bkpOldDlls32% /Y >nul 2>&1

		echo Copiando novas Dlls para System32 ...
		echo:
		echo Copiando de: %dllfile32% para System32
		for %%F in ("%dllfile32%\*.*") do (
			echo Copiando: %%~nxF
			copy "%%~F" C:\Windows\System32\ /Y
		)
		if errorlevel 1 call :copyerror

		if not exist "C:\Windows\System32\jCliSiTefI.dll" (
			copy C:\pdv\util\Programs\jClisitef\jCliSiTefI.dll C:\Windows\System32 /Y >nul 2>&1
		)
		echo Aplicando permissoes CliSitef.ini ...
		cacls C:\Windows\System32\CliSiTef.ini /E /T /C /P Todos:F REDE:F >nul 2>&1
		cacls C:\Windows\System32\CliSiTef32I.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
		cacls C:\Windows\System32\libemv.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
		cacls C:\Windows\System32\QREncode32.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
		cacls C:\Windows\System32\RechargeRPC.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
		explorer "C:\Windows\System32" >nul 2>&1
	)

if exist "C:\Windows\SysWOW64\CliSiTef32I.dll" (
 if exist "C:\Windows\System32\CliSiTef32I.dll" (
	del /q "C:\Windows\System32\CliSiTef32I.dll" >nul 2>&1
	del /q "C:\Windows\System32\libemv.dll" >nul 2>&1
	del /q "C:\Windows\System32\QREncode32.dll" >nul 2>&1
	del /q "C:\Windows\System32\RechargeRPC.dll" >nul 2>&1
	del /q "C:\Windows\System32\Cheque.txt" >nul 2>&1
	REM del /q "C:\Windows\System32\jCliSiTefI.dll" >nul 2>&1
 )
)

REM Apagando pasta TempDlls
rmdir /S /Q %temp%\Auto_Atualizador\tempdlls >nul 2>&1

REM Deletando dlls 64x
cd /d C:\Windows\SysWOW64 >nul 2>&1
del /q CliSiTef64I.dll >nul 2>&1
del /q libcurl64.dll >nul 2>&1
del /q libemv64.dll >nul 2>&1
del /q QREncode64.dll >nul 2>&1

echo ------------------------------------
echo ATUALIZACAO DE DLLS SITEF FINALIZADA
echo ------------------------------------
%endmsg% >nul 2>&1
exit /b

:copyerror
echo:
echo ------------------------------------
echo ERRO AO COPIAR OS ARQUIVOS!
echo Verifique se os arquivos de origem existem
echo ou se ha permissoes suficientes.
echo ------------------------------------
pause
goto menu

REM #################### atualizarDllSitef ####################

REM #################### permissoesdriversat ####################
:permissoesdriversat
cls
echo:
echo ==============================================
echo Aplicando permissoes pasta PDV ... Aguarde ...
echo ==============================================

cacls C:\pdv\database /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\pdv\database\*.* /E /T /C /P Todos:F REDE:F >nul 2>&1
REM cacls C:\pdv\logpdv /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\pdv\driver /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\pdv\driver\*.* /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\pdv\exec /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\pdv\exec\*.* /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\pdv\img /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\pdv\img\*.* /E /T /C /P Todos:F REDE:F >nul 2>&1
REM cacls C:\pdv\paf /E /T /C /P Todos:F REDE:F
cacls C:\pdv\sat /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\pdv\sat\*.* /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\pdv\som /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\pdv\som\*.* /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\Windows\SysWOW64\rxtxSerial.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\Windows\System32\rxtxSerial.dll /E /T /C /P Todos:F REDE:F >nul 2>&1

rem Permissao PDV.FDB
cacls %userprofile%\PDV.FDB /E /T /C /P Todos:F REDE:F >nul 2>&1

rem Permissao pasta Printers para compartilhamento
cacls C:\Windows\System32\spool\PRINTERS /E /T /C /P Todos:F REDE:F >nul 2>&1

rem PERMISSAO DLLS EM WINDOWS

if exist "C:\Program Files (x86)" (
set winpath="C:\Windows\SysWOW64"
) else (
	    set winpath="C:\Windows\System32"
	   )	

REM TECLADO
cacls %winpath%\inpout.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\inpout32.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\inpoutx64.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\ftlib.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\TEC55.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\TEC_55.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\WinIo.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\Tec44Win.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\tec65_32.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\WinIo.sys /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\sk_access.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\sk_access_tcp.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\SK_keyb.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\skgina.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\Ftlib-2.dll /E /T /C /P Todos:F REDE:F >nul 2>&1

REM SAT
cacls %winpath%\dllsat.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\dllsat_elgin.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\BemaSAT.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\BemaSAT32.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\BemaSAT64.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\bemasat.xml /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\libsatid.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\GERSAT.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\gersat.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\SAT.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\sat.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\SATDLL.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\satdll.dll /E /T /C /P Todos:F REDE:F >nul 2>&1

REM IMPRESSORAS
cacls %winpath%\BemaFI32.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\mp2032.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\SiUSBXp.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\DarumaFrameWork.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\GNE_Framework.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\lebin.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\LeituraMFDBin.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\QrCode_DarumaFramework.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\WS_Framework.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\hprtio.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\HprtPrinter.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\InterfaceEpsonNF.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\InterfaceEpsonNF.jar /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\InterfaceEpsonNF.xml /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\poscheque.dat /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\SI300.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\libiconvp.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\libintlp.dll /E /T /C /P Todos:F REDE:F >nul 2>&1

REM BIOMETRIA
cacls %winpath%\ftrScanAPI.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\libusb0.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\NBioBSP.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\NBioBSPISO4JNI.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\NBioBSPJNI.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\NBioNFIQJNI.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\pthreadVC2.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\sgfplib.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\UFLicense.dat /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\UFScanner.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\UFScanner_IZZIX.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\VrBio.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\VrModuleDigitalPersona.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\VrModuleFutronic.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\VrModuleNitgen.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\VrModuleSecugen.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\VrModuleSuprema.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\ftrJavaScanAPI.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\ftrScanAPI.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\ftrWSQ.dll /E /T /C /P Todos:F REDE:F >nul 2>&1

REM RXTX
cacls %winpath%\RXTXcomm.jar /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\rxtxParallel.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\rxtxSerial.dll /E /T /C /P Todos:F REDE:F >nul 2>&1

REM BALANCA
cacls %winpath%\LePeso.dll /E /T /C /P Todos:F REDE:F >nul 2>&1

REM FIREBIRD
set firebird_path32="C:\Program Files (x86)\Firebird"
cacls %firebird_path32% /E /T /C /P Todos:F REDE:F >nul 2>&1

echo:
echo =============================================
echo Aplicando permissoes pasta VR ... Aguarde ...
echo =============================================
echo:
cacls c:\vr\nfe /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls c:\vr\nfe\certificado /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls c:\vr\nfe\certificado\*.* /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls c:\vr\vr.properties /E /T /C /P Todos:F REDE:F >nul 2>&1
REM echo REDE /VR ...
REM cacls c:\vr\nfe /E /T /C /P REDE:F >nul 2>&1
REM cacls c:\vr\vr.properties /E /T /C /P REDE:F >nul 2>&1
REM timeout 1 >nul 2>&1

echo:
echo =========================================
echo Aplicando permissoes JAVA ... Aguarde ...
echo =========================================
echo:
echo Permissoes em java/javaw/javaws .exe
cacls %javaexec% /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %javawexec% /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %javawsexec% /E /T /C /P Todos:F REDE:F >nul 2>&1

rem ==============================================================================
echo Permissao JavaPath, VRPdv.jar, java.exe

cacls %javapath_java% /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %javapath_javaw% /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %javapath_javaws% /E /T /C /P Todos:F REDE:F >nul 2>&1

reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_java% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaw% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaws% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAEXEC% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWEXEC% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWSEXEC% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_java% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaw% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaws% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAEXEC% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWEXEC% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWSEXEC% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1

rem -----------------------------------
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_java% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaw% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaws% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAEXEC% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWEXEC% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWSEXEC% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_java% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaw% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaws% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAEXEC% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWEXEC% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWSEXEC% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
rem -----------------------------------

rem -----------------------------------
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_java% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaw% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaws% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAEXEC% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWEXEC% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWSEXEC% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_java% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaw% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaws% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAEXEC% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWEXEC% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWSEXEC% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
rem -----------------------------------

echo:
echo =============================================================
echo Aplicando permissoes CliSitef.ini e Dlls Sitef... Aguarde ...
echo =============================================================

if exist C:\Windows\SysWOW64 (
cacls C:\Windows\SysWOW64\CliSiTef.ini /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\Windows\SysWOW64\CliSiTef32I.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\Windows\SysWOW64\libemv.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\Windows\SysWOW64\QREncode32.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\Windows\SysWOW64\RechargeRPC.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
) else (
cacls C:\Windows\System32\CliSiTef.ini /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\Windows\System32\CliSiTef32I.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\Windows\System32\libemv.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\Windows\System32\QREncode32.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls C:\Windows\System32\RechargeRPC.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
)
REM timeout 1 >nul 2>&1

echo:
echo =================
echo Desabilitando UAC
echo =================
REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f >nul 2>&1

echo:
echo ==========================
echo AJUSTANDO PLANO DE ENERGIA
echo ==========================
echo:
echo "Ajustando desligamento ocisoso do hd para 0"
powercfg /setacvalueindex SCHEME_CURRENT 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0x00000000  >nul 2>&1
REM echo "Ajustando suspender para 0 min"
powercfg /setacvalueindex SCHEME_CURRENT 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0x00000000  >nul 2>&1
REM echo "Ajustando hibernar para 0 min"
powercfg /setacvalueindex SCHEME_CURRENT 238c9fa8-0aad-41ed-83f4-97be242c8f20 9d7815a6-7ee4-497e-8888-515a05f02364 0x00000000 >nul 2>&1
echo "Ajustando suspensao usb para desabilitado"
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 000 >nul 2>&1
REM echo "Ajustando energia PCIExpress para performace"
powercfg /setacvalueindex SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 000 >nul 2>&1
REM echo "Ajustando energia mínima Processador para performace"
powercfg /setacvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 0x00000064 >nul 2>&1
REM echo "Ajustando energia máxima Processador para performace"
powercfg /setacvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 0x00000064 >nul 2>&1
echo "Ajustando tempo de desligamento do monitor para 0"
powercfg /setacvalueindex SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0x00000000 >nul 2>&1

powercfg -setactive SCHEME_CURRENT >nul 2>&1

echo:
echo:
echo =================================
echo PROCESSO DE PERMISSOES FINALIZADO
echo =================================
exit /b
REM #################### permissoesdriversat ####################

REM #################### copiardlls ####################
:copiardlls
cls
echo:
echo ======================================
echo Copiando Dlls para System32 / SysWoW64
echo ======================================
echo:
echo Aplicando permissao de Todos para as dlls /pdv/driver e /pdv/sat/
cacls c:\pdv\driver\*.* /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls c:\pdv\sat\*.* /E /T /C /P Todos:F REDE:F >nul 2>&1

echo Copiando para pasta do Windows System32 ou SysWoW64
if exist C:\Windows\SysWOW64 (
  copy c:\pdv\driver\*.* C:\Windows\SysWOW64 /Y >nul 2>&1
  copy c:\pdv\sat\*.* C:\Windows\SysWOW64 /Y >nul 2>&1
  echo:
  echo Copiado para SysWOW64 ...
  ) else (
  copy c:\pdv\driver\*.* C:\Windows\System32 /Y >nul 2>&1
  copy c:\pdv\sat\*.* C:\Windows\System32 /Y >nul 2>&1
  echo:
  echo Copiado para System32 ...
)

rem PERMISSAO DLLS EM WINDOWS

if exist "C:\Program Files (x86)" (
set winpath="C:\Windows\SysWOW64"
) else (
	    set winpath="C:\Windows\System32"
	   )	

REM TECLADO
cacls %winpath%\inpout.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\inpout32.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\inpoutx64.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\ftlib.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\TEC55.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\TEC_55.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\WinIo.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\Tec44Win.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\tec65_32.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\WinIo.sys /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\sk_access.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\sk_access_tcp.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\SK_keyb.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\skgina.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\Ftlib-2.dll /E /T /C /P Todos:F REDE:F >nul 2>&1

REM SAT
cacls %winpath%\dllsat.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\dllsat_elgin.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\BemaSAT.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\BemaSAT32.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\BemaSAT64.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\bemasat.xml /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\libsatid.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\GERSAT.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\gersat.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\SAT.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\sat.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\SATDLL.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\satdll.dll /E /T /C /P Todos:F REDE:F >nul 2>&1

REM IMPRESSORAS
cacls %winpath%\BemaFI32.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\mp2032.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\SiUSBXp.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\DarumaFrameWork.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\GNE_Framework.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\lebin.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\LeituraMFDBin.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\QrCode_DarumaFramework.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\WS_Framework.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\hprtio.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\HprtPrinter.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\InterfaceEpsonNF.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\InterfaceEpsonNF.jar /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\InterfaceEpsonNF.xml /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\poscheque.dat /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\SI300.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\libiconvp.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\libintlp.dll /E /T /C /P Todos:F REDE:F >nul 2>&1

REM BIOMETRIA
cacls %winpath%\ftrScanAPI.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\libusb0.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\NBioBSP.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\NBioBSPISO4JNI.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\NBioBSPJNI.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\NBioNFIQJNI.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\pthreadVC2.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\sgfplib.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\UFLicense.dat /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\UFScanner.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\UFScanner_IZZIX.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\VrBio.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\VrModuleDigitalPersona.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\VrModuleFutronic.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\VrModuleNitgen.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\VrModuleSecugen.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\VrModuleSuprema.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\ftrJavaScanAPI.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\ftrScanAPI.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\ftrWSQ.dll /E /T /C /P Todos:F REDE:F >nul 2>&1

REM RXTX
cacls %winpath%\RXTXcomm.jar /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\rxtxParallel.dll /E /T /C /P Todos:F REDE:F >nul 2>&1
cacls %winpath%\rxtxSerial.dll /E /T /C /P Todos:F REDE:F >nul 2>&1

REM BALANCA
cacls %winpath%\LePeso.dll /E /T /C /P Todos:F REDE:F >nul 2>&1

echo:
echo ==================================
echo PROCESSO DE Copiar Dlls FINALIZADO
echo ==================================
exit /b
REM #################### copiardlls ####################

REM #################### atualizarJavaDllSitef ####################
:atualizarJavaDllSitef
call :updateJavaVRS "%java301link%" 301
echo:
echo:
call :atualizarDllSitef "DllSitef_Atual"
exit /b
REM #################### atualizarJavaDllSitef ####################

REM #################### gsurfFilesOnly ####################
:gsurfFilesOnly
cls
REM =======Checagem pasta VPN_Gsurf_Sitef_Express=======
if exist C:\pdv\util\VPN_Gsurf_Sitef_Express (
	cd c:\pdv\util >nul 2>&1
	rmdir /S /Q C:\pdv\util\VPN_Gsurf_Sitef_Express >nul 2>&1
	mkdir C:\pdv\util\VPN_Gsurf_Sitef_Express >nul 2>&1
) else (
	mkdir C:\pdv\util\VPN_Gsurf_Sitef_Express >nul 2>&1
)
REM =======Checagem pasta GsurfCertificado=======
if exist C:\pdv\util\GsurfCertificado (
	cd c:\pdv\util >nul 2>&1
	rmdir /S /Q C:\pdv\util\GsurfCertificado >nul 2>&1
	mkdir C:\pdv\util\GsurfCertificado >nul 2>&1
) else (
	mkdir C:\pdv\util\GsurfCertificado >nul 2>&1
)
REM =======Checagem pasta GsurfListenerClient=======
if exist C:\pdv\util\GsurfListenerClient (
	cd c:\pdv\util >nul 2>&1
	rmdir /S /Q C:\pdv\util\GsurfListenerClient >nul 2>&1
	mkdir C:\pdv\util\GsurfListenerClient >nul 2>&1
) else (
	mkdir C:\pdv\util\GsurfListenerClient >nul 2>&1
)
REM =======Checagem pasta RequisitosGsurf=======
if exist C:\pdv\util\RequisitosGsurf (
	cd c:\pdv\util >nul 2>&1
	rmdir /S /Q C:\pdv\util\RequisitosGsurf >nul 2>&1
	mkdir C:\pdv\util\RequisitosGsurf >nul 2>&1
) else (
	mkdir C:\pdv\util\RequisitosGsurf >nul 2>&1
)

call :gsurfDownloadCertificadoListenerClient

	echo:
	echo ===================================
	echo Gsurf - Arquivos Apenas - Encerrado
	echo ===================================
	pause

exit /b
REM #################### gsurfFilesOnly ####################

REM #################### gsurfFullInstall ####################
:gsurfFullInstall
cls
REM =======Checagem pasta VPN_Gsurf_Sitef_Express=======
if exist C:\pdv\util\VPN_Gsurf_Sitef_Express (
	cd c:\pdv\util >nul 2>&1
	rmdir /S /Q C:\pdv\util\VPN_Gsurf_Sitef_Express >nul 2>&1
	mkdir C:\pdv\util\VPN_Gsurf_Sitef_Express >nul 2>&1
) else (
	mkdir C:\pdv\util\VPN_Gsurf_Sitef_Express >nul 2>&1
)
REM =======Checagem pasta GsurfCertificado=======
if exist C:\pdv\util\GsurfCertificado (
	cd c:\pdv\util >nul 2>&1
	rmdir /S /Q C:\pdv\util\GsurfCertificado >nul 2>&1
	mkdir C:\pdv\util\GsurfCertificado >nul 2>&1
) else (
	mkdir C:\pdv\util\GsurfCertificado >nul 2>&1
)
REM =======Checagem pasta GsurfListenerClient=======
if exist C:\pdv\util\GsurfListenerClient (
	cd c:\pdv\util >nul 2>&1
	rmdir /S /Q C:\pdv\util\GsurfListenerClient >nul 2>&1
	mkdir C:\pdv\util\GsurfListenerClient >nul 2>&1
) else (
	mkdir C:\pdv\util\GsurfListenerClient >nul 2>&1
)
REM =======Checagem pasta RequisitosGsurf=======
if exist C:\pdv\util\RequisitosGsurf (
	cd c:\pdv\util >nul 2>&1
	rmdir /S /Q C:\pdv\util\RequisitosGsurf >nul 2>&1
	mkdir C:\pdv\util\RequisitosGsurf >nul 2>&1
) else (
	mkdir C:\pdv\util\RequisitosGsurf >nul 2>&1
)

call :gsurfDownloadCertificadoListenerClient
call :updateJavaVRS "%java301link%" 301
call :atualizarDllSitef "DllSitef_Atual"
call :gsurfInstall

	echo:
	echo ==============================
	echo Gsurf - Sitef Express Completo
	echo ==============================
	%javainstallsuccess% >nul 2>&1

exit /b
REM #################### gsurfFullInstall ####################

REM #################### gsurfDownloadCertificadoListenerClient ####################
:gsurfDownloadCertificadoListenerClient
cls
echo ==========================================================
echo        Download Certificado e Gsurf Listener Client       
echo ==========================================================
echo:

echo Download Certificado
echo:

%wget% --no-check-certificate %certificadogsurf% -O C:\pdv\util\VPN_Gsurf_Sitef_Express\Certificado.zip >nul 2>&1
if errorlevel 1 ( 
echo ----------------------------------------
echo Erro ao realizar Download do Certificado
echo ----------------------------------------
%errodowncertificadogsurf% >nul 2>&1
pause
goto menu
) 
REM timeout 1 >nul 2>&1

"C:\pdv\util\Programs\7zip\7z.exe" e C:\pdv\util\VPN_Gsurf_Sitef_Express\Certificado.zip -oC:\pdv\util\GsurfCertificado -y >nul 2>&1
if errorlevel 1 ( 
echo ----------------------------------------
echo Erro ao realizar Extracao do Certificado
echo ----------------------------------------
%erroextractcertificadogsurf% >nul 2>&1
pause
goto menu
) 
REM timeout 1 >nul 2>&1

REM ==Aplicando permissao de todos no executavel do Certificado==
cacls C:\pdv\util\GsurfCertificado\InstaladorGSurf.exe /E /T /C /P Todos:F REDE:F >nul 2>&1

REM ==========DOWNLOAD/EXTRACT CLIENT LISTENER=================================
echo Download Client
echo:
%wget% --no-check-certificate %clientgsurf% -O C:\pdv\util\VPN_Gsurf_Sitef_Express\GsurfListenerClient.zip >nul 2>&1
if errorlevel 1 ( 
echo -----------------------------------------
echo Erro ao realizar Download do Client Gsurf
echo -----------------------------------------
%errodownclientegsurf% >nul 2>&1
goto menu
) 
REM timeout 1 >nul 2>&1

"C:\pdv\util\Programs\7zip\7z.exe" e C:\pdv\util\VPN_Gsurf_Sitef_Express\GsurfListenerClient.zip -oC:\pdv\util\GsurfListenerClient -y >nul 2>&1
if errorlevel 1 ( 
echo -----------------------------------------
echo Erro ao realizar Extracao do Client Gsurf
echo -----------------------------------------
%erroextractclientegsurf% >nul 2>&1
goto menu
) 
REM timeout 1 >nul 2>&1

REM ==========DOWNLOAD/EXTRACT REQUISITOS=================================
%wget% --no-check-certificate https://gsurf.com.br/lib/win/requisitos.zip -O C:\pdv\util\VPN_Gsurf_Sitef_Express\Requisitos.zip >nul 2>&1

"C:\pdv\util\Programs\7zip\7z.exe" e C:\pdv\util\VPN_Gsurf_Sitef_Express\Requisitos.zip -oC:\pdv\util\RequisitosGsurf -y >nul 2>&1

REM ===============LIMPANDO ARQUIVOS BAIXADOS==================
rmdir /S /Q C:\pdv\util\VPN_Gsurf_Sitef_Express >nul 2>&1

exit /b
REM #################### gsurfDownloadCertificadoListenerClient ####################

REM #################### gsurfInstall ####################
:gsurfInstall
echo Checando NETFramework
echo:
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\SKUs\.NETFramework,Version=v4.5" >nul 2>&1
rem 1 = not installed e 0 = installed

	if errorlevel 1 (
		rem Download NetFramework
		echo --------------------------------------------------
		echo NETFramework nao instalado, realizando download...
		echo --------------------------------------------------
		"C:\pdv\util\Programs\wget\wget.exe" --no-check-certificate %netframework% -O %temp%\Auto_Atualizador\NetFramework452.exe >nul 2>&1
			if errorlevel 1 (
			echo -----------------------------
			echo Erro no Download NetFramework
			echo -----------------------------
			%netframeinstallerror% >nul 2>&1
			timeout 1 >nul 2>&1
			goto gsurfclient
			) 
		timeout 1 >nul 2>&1
			
		rem Instalando NetFramework
		echo -------------------------------------
		echo Instalando NetFramework....Aguarde...
		echo -------------------------------------
		%installnetframe% >nul 2>&1
		:installnetframe2
		start /WAIT %temp%\Auto_Atualizador\NetFramework452.exe /q /norestart >nul 2>&1
			if errorlevel 1 (
			echo -----------------------------
			echo Erro ao instalar NetFramework
			echo -----------------------------
			%netframeinstallerror% >nul 2>&1
			set netframefailed=1
			) else (
			echo ----------------------------------
			echo NetFramework instalado com sucesso
			echo ----------------------------------
			%netframeinstallsuccess% >nul 2>&1
			timeout 1 >nul 2>&1
			)
	) else (
		echo NetFramework ja instalado
		timeout 1 >nul 2>&1
	)
	
REM ============= Instalando Client Listener ================
:gsurfclient
echo =============================================
echo Instalando Gsurf Client Listener...Aguarde...
echo =============================================
start C:\pdv\util\GsurfListenerClient\GSurfRSA_Listener_Setup.msi
:menuclientgsurf
echo:
echo * 1 - Executar novamente
echo * 2 - Continuar instalacao
set /p option= Escolha uma opcao: 
if %option% equ 1 (
start C:\pdv\util\GsurfListenerClient\GSurfRSA_Listener_Setup.msi
goto menuclientgsurf
)
if %option% equ 2 goto certgsurf
REM msiexec.exe /i "C:\pdv\util\GsurfListenerClient\GSurfRSA_Listener_Setup.msi" /q SERVICO="sitef" >nul 2>&1
REM if errorlevel 1 (
REM echo -----------------------------------
REM echo ERRO Instalar Gsurf Client Listener
REM echo -----------------------------------
REM timeout 5 >nul 2>&1
REM ) else (
REM echo ===========================================
REM echo Client Gsurf Listener instalado com sucesso
REM echo ===========================================
REM timeout 1 >nul 2>&1
REM )

REM ============= Instalando Certificado =============
:certgsurf
echo:
echo =========================================
echo Instalando Certificado Gsurf...Aguarde...
echo =========================================
start C:\pdv\util\GsurfCertificado\InstaladorGSurf.exe
:menucertgsurf
echo:
echo * 1 - Executar novamente
echo * 2 - Continuar instalacao
set /p option= Escolha uma opcao: 
if %option% equ 1 (
start C:\pdv\util\GsurfCertificado\InstaladorGSurf.exe
goto menucertgsurf
)
if %option% equ 2 goto startservice
 REM >nul 2>&1
REM if errorlevel 1 (
REM echo ----------------------------------
REM echo ERRO ao instalar Certificado Gsurf
REM echo ----------------------------------
REM timeout 5 >nul 2>&1
REM ) else (
REM echo =======================================
REM echo Certificado Gsurf Instalado com Sucesso
REM echo =======================================
REM timeout 2 >nul 2>&1
REM )

REM =======INSTALACAO GSURF==============

REM ============= INICIANDO SERVICO GSURF CLIENT ==============
:startservice
echo:
echo Iniciando Servico Gsurf Listener
echo:
net stop "GSurfRSA Listener" >nul 2>&1
net start "GSurfRSA Listener" >nul 2>&1
if errorlevel 1 (
echo --------------------------------------
echo ERRO ao iniciar Servico Gsurf Listener
echo --------------------------------------
timeout 5 >nul 2>&1
) else (
REM echo ===========================================
echo Servico Gsurf Listener iniciado com sucesso
echo:
REM echo ===========================================
)
exit /b
REM #################### gsurfInstall ####################

REM #################### updateJavaVRS ####################
:updateJavaVRS
set javaDownLink=%~1
set javacheck=%~2

	taskkill /f /im java* >nul 2>&1

	if exist "C:\Program Files (x86)" (
	set "javaExist=C:\Program Files (x86)\Java"
	) else (
	set "javaExist=C:\Program Files\Java"
	)
	
	if not exist "%javaExist%" goto directInstallJava
	rem ---------- Check if java installed, if equ 1 no java installed ---------
	
	echo ==============================================================
	echo ***** Java Uninstaller Download em andamento. . . Aguarde ****
	echo ==============================================================
	%wget% --no-check-certificate %javaRemoverLink% -O %temp%\Auto_Atualizador\RemovedorJavasTool.exe >nul 2>&1
	copy %temp%\Auto_Atualizador\RemovedorJavasTool.exe C:\pdv\util >nul 2>&1
	start %temp%\Auto_Atualizador\RemovedorJavasTool.exe >nul 2>&1
	echo Java Uninstaller em andamento, aguarde ...
		:errorTypingJava
		echo:
		echo * 1 - Continuar instalacao
		echo * 2 - Retornar Menu Principal
		echo * 3 - Sair
		set /p optionjavavrs= Escolha uma opcao: 
		if %optionjavavrs% GEQ 4 (echo Opcao nao disponivel& goto errorTypingJava)
		if %optionjavavrs% equ 1 goto directInstallJava
		if %optionjavavrs% equ 2 goto menu
		if %optionjavavrs% equ 3 exit
		
	:directInstallJava
	echo:
	echo ==================================================
	echo ***** Java Download em andamento. . . Aguarde ****
	echo ==================================================
	taskkill /f /im java* >nul 2>&1
	%wget% --no-check-certificate %javaDownLink% -O %temp%\Auto_Atualizador\Java%javacheck%_SetupInstall.exe >nul 2>&1
	if errorlevel 1 ( 
	echo ------------------
	echo ERRO DOWNLOAD JAVA
	echo ------------------
	%javadownloaderror% >nul 2>&1
	timeout 3 >nul 2>&1
	goto menu
	)
	REM --------- Imprime a mensagem e aguarda clicar em Ok para dar sequencia
	%holdjavainstall% >nul 2>&1
	
	REM --------- Install Java e Remove anteriores
	echo ----------------------------
	echo Instalando Java, aguarde ...
	echo ----------------------------
	copy %temp%\Auto_Atualizador\Java%javacheck%_SetupInstall.exe C:\pdv\util >nul 2>&1
	start /WAIT %temp%\Auto_Atualizador\Java%javacheck%_SetupInstall.exe /s REMOVEOUTOFDATEJRES=Enable
	
	if errorlevel 1 (
	echo ---------------------
	echo Erro ao instalar java
	echo ---------------------
	%javainstallerror% >nul 2>&1
	pause
	goto menu
	)
	
	echo Permissoes em Java . . .
	
	echo Permissoes em java/javaw/javaws .exe
	cacls "%javaexec%" /E /T /C /P Todos:F REDE:F >nul 2>&1
	cacls "%javawexec%" /E /T /C /P Todos:F REDE:F >nul 2>&1
	cacls "%javawsexec%" /E /T /C /P Todos:F REDE:F >nul 2>&1

	cacls "%javapath_java%" /E /T /C /P Todos:F REDE:F >nul 2>&1
	cacls "%javapath_javaw%" /E /T /C /P Todos:F REDE:F >nul 2>&1
	cacls "%javapath_javaws%" /E /T /C /P Todos:F REDE:F >nul 2>&1

	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_java% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaw% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaws% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAEXEC% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWEXEC% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWSEXEC% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1

	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_java% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaw% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaws% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAEXEC% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWEXEC% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWSEXEC% /t REG_SZ /d "RUNASADMIN" /f >nul 2>&1

	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_java% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaw% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaws% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAEXEC% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWEXEC% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWSEXEC% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1

	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_java% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaw% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaws% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAEXEC% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWEXEC% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWSEXEC% /t REG_SZ /d "~RUNASADMIN" /f >nul 2>&1

	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_java% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaw% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaws% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAEXEC% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWEXEC% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWSEXEC% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1

	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_java% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaw% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %javapath_javaws% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAEXEC% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWEXEC% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %JAVAWSEXEC% /t REG_SZ /d "~ RUNASADMIN" /f >nul 2>&1
	
	echo:
	echo ==========================
	echo Java Instalado com sucesso
	echo ==========================
	%javainstallsuccess% >nul 2>&1
exit /b
REM #################### updateJavaVRS ####################

REM #################### javaUninstaller ####################
:javaUninstaller

echo ======================================
echo Download Java Uninstaller em progresso
echo ======================================

%wget% --no-check-certificate %javaRemoverLink% -O %temp%\Auto_Atualizador\RemovedorJavasTool.exe >nul 2>&1
if errorlevel 1 ( 
echo ------------------------------
echo ERRO DOWNLOAD JAVA Uninstaller
echo ------------------------------
pause
goto menujava
)
copy %temp%\Auto_Atualizador\RemovedorJavasTool.exe C:\pdv\util >nul 2>&1
start %temp%\Auto_Atualizador\RemovedorJavasTool.exe >nul 2>&1
exit /b
REM #################### javaUninstaller ####################


REM #################### notepad ####################
:notepad

	echo ===========================
	echo *** Download Notepad ++ ***
	echo ===========================
	echo:
	echo ----------------------------------
	echo Download em andamento...Aguarde...
	echo ----------------------------------
%wget% --no-check-certificate %notepad% -O %temp%\Auto_Atualizador\NotepadInstaller.exe >nul 2>&1
	echo:
	echo =============================
	echo $$$ INSTALANDO NOTEPAD ++ $$$
	echo =============================
	echo:
	echo **AGUARDE, NOTEPAD ++ SENDO INSTALADO**
	
	start %temp%\Auto_Atualizador\NotepadInstaller.exe >nul 2>&1
	exit /b
REM #################### notepad ####################

REM #################### shareprinters ####################
:shareprinters
echo =============================================
echo Sharing pasta PRINTERS - VRFood e VRFrente
echo:
echo Aplicando Permissoes de seguranCa
echo =============================================
cacls C:\Windows\System32\spool\PRINTERS /E /T /C /P Todos:F REDE:F >nul 2>&1
echo ==========================
echo Aplicando Compartilhamento
echo ==========================
net share "PRINTERS"=C:\Windows\System32\spool\PRINTERS /grant:Todos,full /grant:REDE,full >nul 2>&1

cacls C:\pdv\util\Programs\Rxtx\*.* /E /T /C /P Todos:F REDE:F >nul 2>&1
copy C:\pdv\util\Programs\Rxtx\*.* >nul 2>&1

if exist C:\Windows\SysWOW64 (
  copy C:\pdv\util\Programs\Rxtx\*.* C:\Windows\SysWOW64 /Y >nul 2>&1
  echo ==============================
  echo Copiado para SysWOW64
  echo ==============================
) else (
  copy C:\pdv\util\Programs\Rxtx\*.* C:\Windows\System32 /Y >nul 2>&1
)
exit /b
REM #################### shareprinters ####################



REM =========================================================================
endlocal