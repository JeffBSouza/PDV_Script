@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:inicio
cls
echo ================================
echo    GERADOR DE LINK ISL ONLINE
echo ================================
echo.

set /p "nome=Por favor, informe o nome: "

if "!nome!"=="" (
    echo.
    echo Erro: Nome nao pode estar vazio!
    timeout /t 2 /nobreak >nul
    goto inicio
)

set "url_base=https://account.islonline.net/start/ISLAlwaysOn?cmdline=%22password_md5%22+%22c5d7c5561d84f6a20e59bcdccb9093be%22+%22%2fVERYSILENT%22+%22grant_silent%22+%22zeJxtUj1PxDAMVUBsTEyMHQFB1KRN2o6MSAgkkJhucRKnhMslkDR3fCz8dAoj18XD8%2fN7frJHbQ%2fJzeNtdR%2b8C1jd4bSLaX1CRmcOSdvWWmsmukE0rNfIgYNmPVPCYjtgJ1DUQjFpVVdziUbY2jQSawNgByV6NIBKQ4%2bc8VrqDsC0pm8GJmXPRSeElkywBlXNh4YZO8gBZl5rms42vG%2b%2bSSYE%2fA4%2bcgxXF9RlH%2f%2f2pAGnU1IIYdVV9fQwlwfUuLkJeQIPJuYZuR4LJAPBxApeSp6wOlutcrTTDhI%2bx5JxdXFZ%2fYcseveKNMEm5v3uCCo59B6pggTeuAXKbAXbSC0kBwsSzxiSeytIJ3Tv6BLsU17QWkxzZKrKJ0xxn7GexQPQVyh%2bYX4NHwUCjd5tlw02kDT6Bd3fRsk0pgBjWQiXMMzC2fktnH%2bRg%2fL3JB3vmajlfMH2mByRH5IBzI4%3d%22+%22ignore_system_account%22+%22grant_password_md5%22+%22c5d7c5561d84f6a20e59bcdccb9093be%22+%22description%22+%22"

set "url_final=!url_base!!nome!&__ISL+Network+Start__hide_gui=1"

echo.
echo Link gerado com sucesso!
echo.
echo Abrindo o link no Notepad...
echo.

set "temp_file=%temp%\isl_link_%random%.txt"
echo !url_final! > "!temp_file!"

notepad "!temp_file!"

echo.
echo O arquivo foi aberto no Notepad.
echo Pressione qualquer tecla para sair...
pause >nul

del "!temp_file!" >nul 2>&1
endlocal