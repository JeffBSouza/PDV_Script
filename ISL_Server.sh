#!/bin/bash

# https://storage.googleapis.com/linux-pdv/Jeff/ISL_Server.sh
# sudo mkdir -p /vr >/dev/null 2>&1; sudo chmod 777 /vr >/dev/null 2>&1; sudo rm -rf /vr/script.sh >/dev/null 2>&1; sudo wget -c --no-check-certificate https://storage.googleapis.com/linux-pdv/Jeff/ISL_Server.sh -O /vr/script.sh; sudo chmod +x /vr/script.sh >/dev/null 2>&1; /vr/script.sh

appsIco="https://storage.googleapis.com/linux-pdv/Jeff/LinuxFiles/img.zip"
URLISLONELIN_LIGHTCLIENT="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Linux/ISL_Light_ClientVR.zip"
EXPECTFILE="/tmp/ISLExpect/islDependencias.expect"
URLRUSTDESK="https://github.com/rustdesk/rustdesk/releases/download/1.4.2/rustdesk-1.4.2-x86_64.deb"
rustDeskvrs="1.4.2"

askSudo() {
	clear
if [ $UID -eq 0 ]; then
    echo -e "O script nao deve ser executado utilizando o usuario root.\nPor gentileza execute novamente e digite a senha somente quando solicitada."
    exit
else
    read -s -p "Digite a senha de root: " PASSWD
    TESTPASSWD=$(printf '%s\n' "$PASSWD" | sudo -S -p '' touch /root/.passtest >/dev/null 2>&1; echo $?)
    if [ "$TESTPASSWD" -ne 0 ]; then
        clear ; echo -e "Senha digitada nao esta correta. O valor digitado foi: $PASSWD\nEncerrando script!\n"
        exit
    else
        printf '%s\n' "$PASSWD" | sudo -S -p '' -S rm -rf /root/.passtest
    fi
fi
}

pause() {
echo -e "Press any button to Exit or Continue..."
read -n 1 -s -r
}

folder_create() {
local FOLDER="$1"
printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $FOLDER >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R $FOLDER >/dev/null 2>&1
}
filepermission_create() {
local FILE="$1"
printf '%s\n' "$PASSWD" | sudo -S -p '' touch "$FILE" # >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 "$FILE" # >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' chown nobody:nogroup "$FILE" # >/dev/null 2>&1
}
folderpermission_create() {
local FOLDER="$1"
printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 "$FOLDER" >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' chown nobody:nogroup "$FOLDER" >/dev/null 2>&1
}
finished() {
echo -e "\nPROCESSO ENCERRADO"
}

expectPermissionsFiles() {
printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x "$EXPECTFILE" >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 "$EXPECTFILE" >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" "$EXPECTFILE" >/dev/null 2>&1
}

# wrapper para dpkg
safe_dpkg() {
  aptLockFix
  sudo -S -p '' dpkg "$@"
}

# wrapper para apt
safe_apt() {
  aptLockFix
  sudo -S -p '' apt "$@"
}

safe_apt_get() {
  aptLockFix
  sudo -S -p '' apt-get "$@"
}

is_valid_file() {
    [ -f "$1" ] && [ -s "$1" ]
}

aptLockFix() {
    local timeout=30   # tempo máximo de espera (segundos)
    local elapsed=0

    echo "[INFO] - Verificando locks do APT/DPKG..."

    # Espera o lock ser liberado naturalmente
    while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 \
       || sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1 \
       || sudo fuser /var/cache/apt/archives/lock >/dev/null 2>&1; do

        if [ "$elapsed" -ge "$timeout" ]; then
            echo "[WARN] - Timeout atingido ($timeout s). Forçando liberação do lock..."
            
            # Mata processos que realmente seguram os locks
            for lock in /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock /var/cache/apt/archives/lock; do
                if [ -e "$lock" ]; then
                    local pids
                    pids=$(sudo fuser "$lock" >/dev/null 2>&1)
                    if [ -n "$pids" ]; then
                        echo "[INFO] - Matando processos que seguram $lock: $pids"
                        sudo kill -9 $pids >/dev/null 2>&1
                    fi
                fi
            done
            break
        fi

        sleep 5
        elapsed=$((elapsed + 5))
        echo "[INFO] - Lock ainda ativo, aguardando... ($elapsed s)"
    done

    # Repara possíveis pacotes quebrados
    echo "[INFO] - Executando reparo do dpkg..."
    sudo dpkg --configure -a >/dev/null 2>&1
    sudo apt-get install -f -y >/dev/null 2>&1

    echo "[OK] - Locks liberados e dpkg reparado."
}

executeCommands() {
    local commandsList=("$@")

	warnningInteraction
	aptLockFix
    
    if [ ${#commandsList[@]} -eq 0 ]; then
        echo -e "\n[FALHA] Nenhum comando fornecido para executar"
        return 1
    fi
    
    echo -e "[INFO] Executando ${#commandsList[@]} comandos..."
    
    for command in "${commandsList[@]}"; do
        echo -e "\n[INFO] Executando: $command"
        eval "$command"
        
        # Verifica se o comando foi executado com sucesso
        if [ $? -ne 0 ]; then
            echo -e "[FALHA] Erro ao executar: $command"
            read -p "Continuar mesmo assim? (s/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Ss]$ ]]; then
                echo "Execucao interrompida pelo usuario"
                return 1
            fi
        fi
        echo "----------------------------------------"
    done
    
    echo -e "[INFO] Todos os comandos foram executados!"
}

warnningInteraction() {
    echo -e "\n** ℹ️ [ATENCAO - INTERACAO NECESSARIA]ℹ️ **\n-- [INFO] A atualizacao/instalacao ira iniciar, existem momentos que sera necessario a sua interacao \nCaso seja necessario entrar com a senha SUDO (senha da maquina) ou um S/n\n Para selecao de opcoes voce pode usar o TAB (para navegar) e o ENTER (para confirmar)"
	echo -e "-- [INFO] Entao se atente a tela durante a atualizacao\n"
	pause
}

setshortcutfiles() {
    local desktopDirs=("$HOME/Desktop" "$HOME/Área de Trabalho" "$HOME/Área de trabalho")
    local dir
    for dir in "${desktopDirs[@]}"; do
        [ -d "$dir" ] && echo "$dir"
    done
}

rustdeskInstallReinstall() {
echo -e "\nInstall/Reinstall RustDesk . . ."

if command -v rustdesk &> /dev/null; then
	echo -e "\nRemovendo RustDesk . . ."
	printf '%s\n' "$PASSWD" | safe_apt remove -y rustdesk
	printf '%s\n' "$PASSWD" | safe_apt purge -y rustdesk
	printf '%s\n' "$PASSWD" | safe_apt_get -y autoclean
	printf '%s\n' "$PASSWD" | sudo -S -p '' umount cliprdr-server >/dev/null 2>&1
fi

echo -e "\nInstalando dependencias RustDesk . . ."

warnningInteraction
printf '%s\n' "$PASSWD" | safe_apt update
printf '%s\n' "$PASSWD" | sudo -S -p '' dpkg --configure -a
printf '%s\n' "$PASSWD" | safe_apt_get -y --fix-broken install
printf '%s\n' "$PASSWD" | safe_apt_get -f -y install
printf '%s\n' "$PASSWD" | sudo -S -p '' ldconfig
printf '%s\n' "$PASSWD" | safe_apt_get -y install wget gdebi-core

echo -e "\n[INFO] Realizando Download RustDesk . . ."
printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/tmp/RustDesk" >/dev/null 2>&1
folder_create "/tmp/RustDesk"
if [ -d "/tmp/RustDesk" ]; then
	printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate  $URLRUSTDESK -O /tmp/RustDesk/rustdesk-1.4.2-x86_64.deb >/dev/null 2>&1
	if ! is_valid_file "/tmp/RustDesk/rustdesk-1.4.2-x86_64.deb"; then
		echo -e "\n[FALHA] Erro Realizar Download RustDesk" ; pause ; menuOptions
	fi
else
	echo -e "\n[FALHA] Erro ao criar pasta RustDesk" ; pause ; menuOptions
fi

echo -e "\n[INFO] Instalando RustDesk $rustDeskvrs . . ."
if ! echo "$PASSWD" | sudo -S -p '' gdebi -n /tmp/RustDesk/rustdesk-1.4.2-x86_64.deb >/dev/null 2>&1; then
    echo -e "\n[FALHA] Erro na instalação do RustDesk"
    pause
    menuOptions
fi

if command -v rustdesk &> /dev/null; then
echo -e "\n[INFO] Criando atalho RustDesk $rustDeskvrs . . ."
while IFS= read -r desktopFolder; do
    # Copia o atalho RustDesk
    printf '%s\n' "$PASSWD" | sudo -S cp --remove-destination -p \
        "$SHORTCUTPATH/rustdesk.desktop" "$desktopFolder/rustdesk.desktop" >/dev/null 2>&1

    # Verifica se a cópia funcionou e ajusta permissões
    if [ -e "$desktopFolder/rustdesk.desktop" ]; then
        printf '%s\n' "$PASSWD" | sudo -S chmod +x "$desktopFolder/rustdesk.desktop"
        echo -e "[INFO] Atalho [\"$desktopFolder/rustdesk.desktop\"] RustDesk $rustDeskvrs criado com sucesso"
    fi
done < <(setshortcutfiles)

echo -e "\nRustDesk $rustDeskvrs instalado com sucesso"
fi
}

firefox() {
printf '%s\n' "$PASSWD" | sudo -S -p '' apt update
echo -e "\n - [Instalando Firefox]\n"
printf '%s\n' "$PASSWD" | sudo -S -p '' apt-get -yq install firefox
if [ -e "/usr/share/applications/firefox.desktop" ]; then
    desktopDirs=( "$HOME/Desktop" "$HOME/Área de Trabalho" "$HOME/Área de trabalho" )
    for dir in "${desktopDirs[@]}"; do
        if [ -d "$dir" ]; then
			if [ ! -e "$dir/firefox.desktop" ]; then
            	printf '%s\n' "$PASSWD" | sudo -S -p '' ln -sf "/usr/share/applications/firefox.desktop" "$dir/firefox.desktop" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x "$dir/firefox.desktop" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 "$dir/firefox.desktop" >/dev/null 2>&1
			fi
        fi
    done
fi
echo -e "\n [Instalando gedit]\n"
printf '%s\n' "$PASSWD" | sudo -S -p '' apt-get -yq install gedit
finished
sleep 2
menuOptions
}

islOnline_Dependencias(){
	printf '%s\n' "$PASSWD" | sudo -S -p '' -v || { echo "[ERRO] - Senha incorreta"; exit 1; }
	local commandsList=(
    "sudo add-apt-repository universe -y"
    "sudo add-apt-repository multiverse -y"
	"sudo apt update"
	"sudo dpkg --configure -a"
	"sudo apt-get -y --fix-broken install"
	"sudo apt-get -f -y install"
	"sudo ldconfig"
	"sudo apt -y upgrade"
	)
    executeCommands "${commandsList[@]}"

    printf '%s\n' "$PASSWD" | safe_apt_get install -y libxcb-icccm4 
    printf '%s\n' "$PASSWD" | safe_apt_get install -y libxcb-image0 
    printf '%s\n' "$PASSWD" | safe_apt_get install -y libxcb-keysyms1 
    printf '%s\n' "$PASSWD" | safe_apt_get install -y libxcb-xkb1 
    printf '%s\n' "$PASSWD" | safe_apt_get install -y libxkbcommon-x11-0
    printf '%s\n' "$PASSWD" | sudo -S -p '' apt-get clean
}

islOnline_AlwaysOn() {
echo -e "\nInstalando AlwaysON"

arquivos=( "$HOME/Downloads"/ISL_AlwaysOn* )

if [ ! -e "${arquivos[0]}" ]; then
    echo -e "\nNenhum arquivo ISL_AlwaysOn encontrado na pasta $HOME/Downloads.\nRealize o download novamente (Apenas uma vez)\nE execute o script em seguida.."
    pause
    exit
elif [ "${#arquivos[@]}" -gt 1 ]; then
    echo -e"\nExistem mais de um arquivo ISL_AlwaysOn na pasta Downloads."
    printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $HOME/Downloads/*.zip
    echo -e "Arquivos Deletados !!\nAbra o Firefox e realize o download novamente (Apenas uma vez)\nE execute o script em seguida..."
    pause
    exit
fi

echo -e "Instalando dependencias AlwaysOn"
islOnline_Dependencias

printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/tmp/isl-download"
printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "$HOME/Downloads/ISL_AlwaysOn*"
printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 "/tmp/isl-download"
printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o "$HOME/Downloads/ISL_AlwaysOn*" -d "/tmp/isl-download/ISL_AlwaysOn"
printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "$HOME/Downloads/*.zip"
shopt -s nullglob
DESTINO="/tmp/isl-download"
local checkFile=("$DESTINO"/*)
if [ ${#checkFile[@]} -eq 0 ]; then
    echo -e "\n❌ Falha na extração ou arquivo estava vazio, arquivo em $HOME/Downloads/ISL_AlwaysOn* estava vazio."
    pause
    exit
fi
shopt -u nullglob
LOGFILE="/tmp/install_log.txt"

{
    echo "########################################################################################"
    date=$(date '+%Y-%m-%d_%H:%M:%S')
    echo "Processo iniciado $date"
    echo "========================================================================================"

    # Executa o chmod
    printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x /tmp/isl-download/*
    cd /tmp/isl-download/ISL_AlwaysOn

    # Executa o comando de instalação e captura a saída, mas também exibe na tela
    output=$(echo "$PASSWD" | sudo -S ./ISL_AlwaysOn* install_missing 2>&1)
    echo "$output"  # Exibe a saída do comando na tela e no log

    # Verifica se a saída contém a mensagem de erro
    if echo "$output" | grep -q "Error running launch"; then
        echo -e "\n\nErro detectado: $output\n"
        pause
        menuOptions
    elif echo "$output" | grep -q "install script done"; then
        echo -e "\n\nInstalação concluída com sucesso!"
    else
        echo -e "\n\nResultado inesperado: $output\n"
        pause
        menuOptions
    fi
    
    echo "========================================================================================"
    date=$(date '+%Y-%m-%d_%H:%M:%S')
    echo "Processo encerrado $date"
    echo "########################################################################################"
} | tee -a "$LOGFILE"
}

islOnline_LightClient() {
local FILE=/vr/isl_LightClient/ISL_Light_Client
local DESTINO=/vr/isl_LightClient

echo -e "\nInstalando LightClient"

    printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $DESTINO >/dev/null 2>&1

    folder_create "$DESTINO"

	if [ -e "$FILE" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $FILE >/dev/null 2>&1
    fi
    printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $URLISLONELIN_LIGHTCLIENT -O $DESTINO/ISL_Light_Client.zip >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o $DESTINO/ISL_Light_Client.zip -d $DESTINO >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $DESTINO/ISL_Light_Client.zip >/dev/null 2>&1
    # echo "$PASSWD" | sudo -S mv $DESTINO/* $DESTINO/ISL_Light_Client >/dev/null 2>&1
	shopt -s nullglob
    local checkFile=("$DESTINO"/*)
	if [ ${#checkFile[@]} -eq 0 ]; then
        echo -e "\n❌Falha na extração ou arquivo estava vazio, arquivo em $DESTINO/ISL_Light_Client.zip estava vazio."
        pause
        exit
    fi
	shopt -u nullglob
    
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R $DESTINO >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R $DESTINO >/dev/null 2>&1
    
    echo -e "Instalando dependencias LightClient"
    islOnline_Dependencias
}

islOnline_Atalho() {

    if [ ! -d "/vr/atalho_islonline" ]; then
        folder_create "/vr/atalho_islonline"
    else 
        folderpermission_create "/vr/atalho_islonline"
    fi

	if [ ! -e "/vr/atalho_islonline/isl_online.png" ]; then
		echo -e "\n[Ajuste atalho ISL_Online . . .]"
		printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $appsIco -O /vr/atalho_islonline/img.zip >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o /vr/atalho_islonline/img.zip -d /vr/atalho_islonline >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /vr/atalho_islonline/img.zip >/dev/null 2>&1

		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R /vr/atalho_islonline/* >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R /vr/atalho_islonline/* >/dev/null 2>&1
	fi

if [[ "$islOnlineType" == "AlwaysOn" ]]; then
    # Garante que o ícone esteja presente
    if [ ! -e "/opt/ISLOnline/ISLAlwaysOn/isl_online.png" ]; then
        printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p "/vr/atalho_islonline/isl_online.png" "/opt/ISLOnline/ISLAlwaysOn" >/dev/null 2>&1
    fi

    # Define destinos de desktop possíveis
    desktopDirs=( "$HOME/Desktop" "$HOME/Área de Trabalho" "$HOME/Área de trabalho" "$HOME/Desktop")

    for dir in "${desktopDirs[@]}"; do
        # Criação ISLAlwaysOn.desktop
        dest1="$dir/ISLAlwaysOn.desktop"
        if [ ! -e "$dest1" ]; then
            filepermission_create "$dest1" >/dev/null 2>&1
            cat <<EOF > "$dest1" >/dev/null 2>&1
[Desktop Entry]
Encoding=UTF-8
Name=ISL AlwaysOn
Exec='/opt/ISLOnline/ISLAlwaysOn/ISLAlwaysOn' overview
Type=Application
Categories=Application;Network;
Icon=/opt/ISLOnline/ISLAlwaysOn/isl_online.png
EOF
            printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x "$dest1" >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p "$dest1" "/usr/share/applications" >/dev/null 2>&1
        fi

        # Criação ISLAlwaysOn_Desinstalar.desktop
        dest2="$dir/ISLAlwaysOn_Desinstalar.desktop"
        if [ ! -e "$dest2" ]; then
            filepermission_create "$dest2" >/dev/null 2>&1
            cat <<EOF > "$dest2" >/dev/null 2>&1
[Desktop Entry]
Encoding=UTF-8
Name=Uninstall ISL AlwaysOn
Exec='/opt/ISLOnline/ISLAlwaysOn/uninstall.pl'
Type=Application
Categories=Application;Network;
Icon=/opt/ISLOnline/ISLAlwaysOn/isl_online.png
EOF
            printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x "$dest2" >/dev/null 2>&1
        fi
    done

    finished
	pause
    exit
fi

if [[ "$islOnlineType" == "LightClient" ]]; then
    local DESTINO=/vr/isl_LightClient
    local atalhoDestino=/vr/atalho_islonline

    # Verifica imagem do atalho
    if [ ! -e "$atalhoDestino/isl_online.png" ]; then
        echo -e "\nFalha: imagem do atalho do LightClient não encontrada.\nO atalho será criado sem ícone."
        pause
    fi

    # Garante script de execução
    if [ ! -e "$DESTINO/run_light_client.sh" ]; then
        filepermission_create "$DESTINO/run_light_client.sh" >/dev/null 2>&1
        cat << EOF > "$DESTINO/run_light_client.sh" >/dev/null 2>&1
#!/bin/bash
cd "$DESTINO" >/dev/null 2>&1
./ISL_Light_Client
EOF
        printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x "$DESTINO/run_light_client.sh" >/dev/null 2>&1
    fi

    # Diretórios onde o atalho será criado
    desktopDirs=( "$HOME/Desktop" "$HOME/Área de Trabalho" "$HOME/Área de trabalho" )
    
    for dir in "${desktopDirs[@]}"; do
        atalho="$dir/ISL_LightClient.desktop"

        if [ ! -e "$atalho" ]; then
            filepermission_create "$atalho" >/dev/null 2>&1
            cat << EOF > "$atalho" >/dev/null 2>&1
[Desktop Entry]
Encoding=UTF-8
Name=ISL LightClient - Suporte Acesso Remoto
Exec=$DESTINO/run_light_client.sh
Type=Application
Categories=Application;Network;
Icon=$atalhoDestino/isl_online.png
EOF
            printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x "$atalho" >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p "$atalho" "/usr/share/applications" >/dev/null 2>&1
        fi
    done

    echo -e "ISL_Light_Client instalado. Execute-o a partir do atalho."
    finished
	pause
    exit
else
    echo -e "\nFalha ao criar atalho do ISL LightClient."
    pause
    menuOptions
fi
}

menuOptions() {
    clear
	echo -e "\n==============================="
	echo -e "Nome da maquina: $(uname -n)"
	echo "1. AlwaysOn (Necessario download do ISL_AlwaysOn via firefox previamente)"
	echo "2. ISL_Light_Client - Acesso monitorado e unico"
	echo "3. Dependencias ISL (Light Client e AlwaysOn)"
    echo "4. Instalar Firefox"
    echo "5. Instalar RustDesk"
	echo "6. SAIR"
	read -p "Opcao: " OPTISLMENU

	if [ -z "$OPTISLMENU" ] || ! [[ "$OPTISLMENU" =~ ^[0-9]+$ ]]; then
        echo -e "\nErro: você deve escolher uma opcao valida." ; sleep 2 ; menuOptions
	fi
	if [ $OPTISLMENU -eq 1 ]; then
        islOnlineType=AlwaysOn
        islOnline_AlwaysOn
        islOnline_Atalho
	fi
	if [ $OPTISLMENU -eq 2 ]; then
        islOnlineType=LightClient
        islOnline_LightClient
        islOnline_Atalho
	fi
	if [ $OPTISLMENU -eq 3 ]; then
        echo -e "\nInstalando dependencias ISL"
        islOnline_Dependencias
        finished
        pause
        menuOptions
	fi
	if [ $OPTISLMENU -eq 4 ]; then
	    firefox
	fi
	if [ $OPTISLMENU -eq 5 ]; then
	    rustdeskInstallReinstall
	fi
	if [ $OPTISLMENU -eq 6 ]; then
	    exit
	fi
	if [ $OPTISLMENU -ge 7 ]; then
	echo -e "\nOpcao incorreta, retornando ao menu principal" ; pause ; menuOptions
	fi
}

askSudo
menuOptions