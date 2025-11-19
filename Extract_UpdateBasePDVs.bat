@echo off
setlocal enabledelayedexpansion
echo:

taskkill /f /im java*
taskkill /f /im emulador*

set files44="C:\vr\PacotesAtualizar\4_4-Complementar.rar" "C:\vr\PacotesAtualizar\4_4.rar"
for %%a in (%files44%) do (
    if exist "%%~a" (
    echo Extraindo arquivo "%%~a"
    "C:\vr\7zip\7z.exe" x "%%~a" -o"C:\vr\exec44" -y >nul 2>&1
        if errorlevel 1 (
            echo ERRO ao extrair "%%~a"
            echo:
        ) else (
            echo Sucesso: "%%~a"
            del /q "%%~a" >nul 2>&1
            echo:
        )
    )
)

set files43="C:\vr\PacotesAtualizar\4_3-Complementar.rar" "C:\vr\PacotesAtualizar\4_3.rar"
for %%b in (%files43%) do (
    if exist "%%~b" (
    echo Extraindo arquivo "%%~b"
    "C:\vr\7zip\7z.exe" x "%%~b" -o"C:\vr\exec43" -y >nul 2>&1
        if errorlevel 1 (
            echo ERRO ao extrair "%%~b"
            echo:
        ) else (
            echo Sucesso: "%%~b"
            del /q "%%~b" >nul 2>&1
            echo:
        )
    )
)

set "list_version=44 43"
for %%k in (%list_version%) do (
set "base=%%k"
set "lista_dbs=!base! connect!base! multiloja!base!"
	
	for %%j in (!lista_dbs!) do (
	set "basename=%%j"
		IF EXIST "C:\pdv!basename!" (
			echo:
			echo Atualizando PDV !basename! . . .
			cd /d "%driveRaiz%\exec!base!" || echo Erro ao acessar %driveRaiz%\exec!base! && pause
			copy VRPdv.jar "c:\pdv!basename!\exec\" /Y >nul 2>&1 && echo Arquivo VRPdv.jar !base! !basename! copiado com sucesso || echo Erro ao copiar VRPdv.jar !base!
		)
		IF EXIST "C:\pdv\!basename!.txt" (
			echo:
			echo Atualizando PDV !basename! . . .
			cd /d "%driveRaiz%\exec!base!" || echo Erro ao acessar %driveRaiz%\exec!base! && pause
			copy VRPdv.jar "c:\pdv\exec\" /Y >nul 2>&1 && echo Arquivo VRPdv.jar !base! !basename! copiado com sucesso || echo Erro ao copiar VRPdv.jar !base!
		)
	)
)

endlocal
pause