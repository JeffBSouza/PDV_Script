@echo off
title Desinstalar Java (PowerShell)
echo ================================
echo  REMOVENDO JAVA DO SISTEMA
echo ================================
echo.

:: Cria script PowerShell temporário
set "psfile=%temp%\remove_java.ps1"
> "%psfile%" echo $paths = @('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*')
>>"%psfile%" echo $apps = Get-ItemProperty $paths ^| Where-Object { $_.DisplayName -like 'Java*' }
>>"%psfile%" echo if ($apps) {
>>"%psfile%" echo   foreach ($app in $apps) {
>>"%psfile%" echo     Write-Host ('Removendo ' + $app.DisplayName + '...')
>>"%psfile%" echo     if ($app.UninstallString) {
>>"%psfile%" echo       $cmd = $app.UninstallString
>>"%psfile%" echo       if ($cmd -match 'msiexec') {
>>"%psfile%" echo         Start-Process -FilePath 'msiexec.exe' -ArgumentList '/x', $app.PSChildName, '/qn' -Wait
>>"%psfile%" echo       } else {
>>"%psfile%" echo         Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', $cmd, '/qn' -Wait
>>"%psfile%" echo       }
>>"%psfile%" echo     }
>>"%psfile%" echo   }
>>"%psfile%" echo } else {
>>"%psfile%" echo   Write-Host 'Nenhuma versão do Java encontrada.'
>>"%psfile%" echo }

:: Executa o PowerShell
powershell -ExecutionPolicy Bypass -NoProfile -File "%psfile%"

:: Remove o script temporário
del "%psfile%" >nul 2>&1

echo.
echo Limpando pastas residuais...
rmdir /s /q "C:\Program Files\Java" 2>nul
rmdir /s /q "C:\Program Files (x86)\Java" 2>nul
rmdir /s /q "%AppData%\Oracle\Java" 2>nul

echo.
echo Concluido!
pause
