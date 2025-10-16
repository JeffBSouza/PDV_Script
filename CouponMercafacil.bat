@echo off
setlocal enabledelayedexpansion

echo.
echo ===== FORMATADOR DE CODIGO =====
echo.
echo Exemplo: 0040110251717390002671330000061373
echo.
set /p "codigo=Digite o codigo: "

:: Remove caracteres não numéricos
set "clean_code="
for /f "delims=" %%c in ('cmd /u /c echo %codigo% ^| find /v ""') do (
    if "%%c" geq "0" if "%%c" leq "9" set "clean_code=!clean_code!%%c"
)

set "codigo=!clean_code!"
set "tamanho=0"
if defined codigo set /a tamanho=!codigo:~0,1!+1-1 >nul 2>&1 && set "tamanho=!codigo!"

:: Conta os dígitos
set "count=0"
:count_loop
if "!codigo:~%count%,1!" neq "" (
    set /a count+=1
    goto count_loop
)

echo.
echo Codigo limpo: !codigo!
echo Tamanho: !count! digitos

if !count! equ 34 (
    :: Formata o código de 34 dígitos
    set "id_loja=!codigo:~0,3!"
    set "data_dd=!codigo:~3,2!"
    set "data_mm=!codigo:~5,2!"
    set "data_yy=!codigo:~7,2!"
    set "hora_hh=!codigo:~9,2!"
    set "hora_mm=!codigo:~11,2!"
    set "hora_ss=!codigo:~13,2!"
    set "operador=!codigo:~15,6!"
    set "ecf=!codigo:~21,3!"
    set "cupom=!codigo:~24,10!"
    
    :: Formata data e hora
    set "data_formatada=!data_dd!/!data_mm!/20!data_yy!"
    set "hora_formatada=!hora_hh!:!hora_mm!:!hora_ss!"
    set "data_sql=20!data_yy!-!data_mm!-!data_dd!"
    
    set "resultado=!id_loja!^|!data_dd!!data_mm!!data_yy!^|!hora_hh!!hora_mm!!hora_ss!^|!operador!^|!ecf!^|!cupom!"
    
    echo.
    echo ===== RESULTADO =====
    echo ID-LOJA....: !id_loja!
    echo DATA.......: !data_formatada!
    echo HORA.......: !hora_formatada!
    echo OPERADOR...: !operador!
    echo ECF........: !ecf!
    echo CUPOM......: !cupom!
    echo.
    echo FORMATADO: !resultado!
    
    :: Gera o comando SQL
    set "sql_query=SELECT * FROM pdv.venda WHERE ecf = !ecf! AND DATA= '!data_sql!' AND id_loja = !id_loja! AND numerocupom = !cupom!"
    
    echo.
    echo ===== COMANDO SQL =====
    echo !sql_query!
    
    :: CORREÇÃO: Usa arquivo temporário para copiar para clipboard
    echo !resultado! > temp_clip.txt
    clip < temp_clip.txt
    del temp_clip.txt
    
    echo.
    echo ? Codigo formatado copiado para area de transferencia!
    
    :: Cria arquivo com todos os resultados
    echo ===== RESULTADO DA CONSULTA ===== > resultado.txt
    echo. >> resultado.txt
    echo Codigo original: %codigo% >> resultado.txt
    echo Codigo limpo: !codigo! >> resultado.txt
    echo. >> resultado.txt
    echo === INFORMACOES FORMATADAS === >> resultado.txt
    echo ID-LOJA....: !id_loja! >> resultado.txt
    echo DATA.......: !data_formatada! >> resultado.txt
    echo HORA.......: !hora_formatada! >> resultado.txt
    echo OPERADOR...: !operador! >> resultado.txt
    echo ECF........: !ecf! >> resultado.txt
    echo CUPOM......: !cupom! >> resultado.txt
    echo. >> resultado.txt
    echo === FORMATO PADRAO === >> resultado.txt
    echo !resultado! >> resultado.txt
    echo. >> resultado.txt
    echo === COMANDO SQL === >> resultado.txt
    echo !sql_query! >> resultado.txt
    echo. >> resultado.txt
    echo Arquivo gerado em: %date% %time% >> resultado.txt
    
    :: Abre o Notepad com o resultado
    echo.
    echo ? Abrindo resultado no Notepad...
    notepad resultado.txt
    
)

echo.
exit