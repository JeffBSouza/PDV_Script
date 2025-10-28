#!/bin/bash

# https://storage.googleapis.com/linux-pdv/Jeff/ISL_Server.sh
# sudo mkdir -p /vr >/dev/null 2>&1; sudo chmod 777 /vr >/dev/null 2>&1; sudo rm -rf /vr/script.sh >/dev/null 2>&1; sudo wget -c --no-check-certificate https://storage.googleapis.com/linux-pdv/Jeff/ISL_Server.sh -O /vr/script.sh; sudo chmod +x /vr/script.sh >/dev/null 2>&1; /vr/script.sh

appsIco="https://storage.googleapis.com/linux-pdv/Jeff/LinuxFiles/img.zip"
URLISLONELIN_LIGHTCLIENT="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Linux/ISL_Light_ClientVR.zip"
EXPECTFILE="/tmp/ISLExpect/islDependencias.expect"
URLRUSTDESK="https://github.com/rustdesk/rustdesk/releases/download/1.4.2/rustdesk-1.4.2-x86_64.deb"
rustDeskvrs="1.4.2"
jarPath_vr_exec="/vr/exec"
jarPath_home_vr_exec="$HOME/.vr/server/exec"
fileScript="/vr/VRGerenciadormercafacil.sh"
fileScript_Config="/vr/VRGerenciadormercafacil_config.sh"
APP_DIR="$HOME/.vr/integracao/vrgerenciadorifood"
ENV_FILE="$APP_DIR/.env"
DOCKER_COMPOSE_FILE="$APP_DIR/docker-compose-gerenciadorifood.yml"
URL_GERENCIADORIFOOD="https://storage.googleapis.com/linux-pdv/Jeff/iFood_Files/VRGerenciadorIfood.zip"
DESTINO_TEMP="/tmp/vrgerenciadorifood"

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

test_PW() {
local TESTPASSWD="$1"
TESTPASSWD=$(printf '%s\n' "$PASSWD" | sudo -S -p '' touch /root/.passtest 2>/dev/null; echo $?)
    if [ $TESTPASSWD -ne 0 ]; then
        clear ; echo -e "Senha digitada nao esta correta. O valor digitado foi: $PASSWD\nEncerrando script!\n"
        exit
    else
        printf '%s\n' "$PASSWD" | sudo -S -p '' -S rm -rf /root/.passtest
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

dateFull_Info() {
date '+%Y-%m-%d_%H:%M:%S'
}

check_repos() {
# Verifica se o repositório universe está habilitado
if ! grep -q "^[^#].*universe" /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null; then
    echo "[INFO] - Habilitando repositório universe"
    printf '%s\n' "$PASSWD" | sudo -S -p '' add-apt-repository universe -y
fi

# Verifica se o repositório multiverse está habilitado
if ! grep -q "^[^#].*multiverse" /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null; then
    echo "[INFO] - Habilitando repositório multiverse"
    printf '%s\n' "$PASSWD" | sudo -S -p '' add-apt-repository multiverse -y
fi

# Verifica se a arquitetura i386 já está adicionada
if ! dpkg --print-foreign-architectures | grep -qw i386; then
    echo "[INFO] - Adicionando arquitetura i386"
    printf '%s\n' "$PASSWD" | safe_dpkg --add-architecture i386
fi
}

comandosPreparacao() {
    sudo dpkg --configure -a
    sudo apt-get --fix-broken install
    sudo apt-get -f -y install
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

    echo -e "ℹ️ [INFO] - Verificando locks do APT/DPKG..."

    # Espera o lock ser liberado naturalmente
    while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 \
       || sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1 \
       || sudo fuser /var/cache/apt/archives/lock >/dev/null 2>&1; do

        if [ "$elapsed" -ge "$timeout" ]; then
            echo -e "ℹ️ [WARN] - Timeout atingido ($timeout s). Forçando liberação do lock..."
            
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
        echo -e "ℹ️ [INFO] - Lock ainda ativo, aguardando... ($elapsed s)"
    done

    # Repara possíveis pacotes quebrados
    echo -e "ℹ️ [INFO] - Executando reparo do dpkg..."
    sudo dpkg --configure -a >/dev/null 2>&1
    sudo apt-get install -f -y >/dev/null 2>&1

    echo -e "✅ [OK] - Locks liberados e dpkg reparado."
}

executeCommands() {
    local commandsList=("$@")

	warnningInteraction
	aptLockFix
    
    if [ ${#commandsList[@]} -eq 0 ]; then
        echo -e "\n❌ [FALHA] Nenhum comando fornecido para executar"
        return 1
    fi
    
    echo -e "ℹ️ [INFO] Executando ${#commandsList[@]} comandos..."
    
    for command in "${commandsList[@]}"; do
        echo -e "\nℹ️ [INFO] Executando: $command"
        eval "$command"
        
        # Verifica se o comando foi executado com sucesso
        if [ $? -ne 0 ]; then
            echo -e "❌ [FALHA] Erro ao executar: $command"
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

echo -e "\nℹ️ [INFO] Realizando Download RustDesk . . ."
printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/tmp/RustDesk" >/dev/null 2>&1
folder_create "/tmp/RustDesk"
if [ -d "/tmp/RustDesk" ]; then
	printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate  $URLRUSTDESK -O /tmp/RustDesk/rustdesk-1.4.2-x86_64.deb >/dev/null 2>&1
	if ! is_valid_file "/tmp/RustDesk/rustdesk-1.4.2-x86_64.deb"; then
		echo -e "\n[FALHA] Erro Realizar Download RustDesk" ; pause ; menuOptions
	fi
else
	echo -e "\n❌ [FALHA] Erro ao criar pasta RustDesk" ; pause ; menuOptions
fi

echo -e "\nℹ️ [INFO] Instalando RustDesk $rustDeskvrs . . ."
if ! echo "$PASSWD" | sudo -S -p '' gdebi -n /tmp/RustDesk/rustdesk-1.4.2-x86_64.deb >/dev/null 2>&1; then
    echo -e "\n❌ [FALHA] Erro na instalação do RustDesk"
    pause
    menuOptions
fi

if command -v rustdesk &> /dev/null; then
echo -e "\nℹ️ [INFO] Criando atalho RustDesk $rustDeskvrs . . ."
while IFS= read -r desktopFolder; do
    # Copia o atalho RustDesk
    printf '%s\n' "$PASSWD" | sudo -S cp --remove-destination -p \
        "$SHORTCUTPATH/rustdesk.desktop" "$desktopFolder/rustdesk.desktop" >/dev/null 2>&1

    # Verifica se a cópia funcionou e ajusta permissões
    if [ -e "$desktopFolder/rustdesk.desktop" ]; then
        printf '%s\n' "$PASSWD" | sudo -S chmod +x "$desktopFolder/rustdesk.desktop"
        echo -e "ℹ️ [INFO] Atalho [\"$desktopFolder/rustdesk.desktop\"] RustDesk $rustDeskvrs criado com sucesso"
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
        echo -e "\n\n❌ Erro detectado: $output\n"
        pause
        menuOptions
    elif echo "$output" | grep -q "install script done"; then
        echo -e "\n\n✅ Instalação concluída com sucesso!"
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
    
    echo -e "\nInstalando dependencias LightClient"
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
            cat <<EOF > "$dest1" 2>/dev/null
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
            cat <<EOF > "$dest2" 2>/dev/null
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
fi

if [[ "$islOnlineType" == "LightClient" ]]; then
    local DESTINO=/vr/isl_LightClient
    local atalhoDestino=/vr/atalho_islonline

    # Verifica imagem do atalho
    if [ ! -e "$atalhoDestino/isl_online.png" ]; then
        echo -e "\n❌ Falha: imagem do atalho do LightClient não encontrada.\nO atalho será criado sem ícone."
        pause
    fi

    # Garante script de execução
    if [ -e "$DESTINO/run_light_client.sh" ]; then
        printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "$DESTINO/run_light_client.sh" >/dev/null 2>&1
    fi
    if [ ! -e "$DESTINO/run_light_client.sh" ]; then
        filepermission_create "$DESTINO/run_light_client.sh" >/dev/null 2>&1
        cat << EOF > "$DESTINO/run_light_client.sh" 2>/dev/null
#!/bin/bash
cd "$DESTINO" >/dev/null 2>&1
./ISL_Light_Client
EOF

        printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x "$DESTINO/run_light_client.sh" >/dev/null 2>&1
    fi

    if [ -e "/usr/share/applications/ISL_LightClient.desktop" ]; then
        printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/usr/share/applications/ISL_LightClient.desktop" >/dev/null 2>&1
    fi

    filepermission_create "/usr/share/applications/ISL_LightClient.desktop" >/dev/null 2>&1
    printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x "/usr/share/applications/ISL_LightClient.desktop" >/dev/null 2>&1

            cat << EOF > "/usr/share/applications/ISL_LightClient.desktop" 2>/dev/null
[Desktop Entry]
Encoding=UTF-8
Name=ISL LightClient - Suporte Acesso Remoto
Exec=$DESTINO/run_light_client.sh
Type=Application
Categories=Application;Network;
Icon=$atalhoDestino/isl_online.png
EOF
 
    # Diretórios onde o atalho será criado
    desktopDirs=( "$HOME/Desktop" "$HOME/Área de Trabalho" "$HOME/Área de trabalho" )
    
    for dir in "${desktopDirs[@]}"; do
        atalho="$dir/ISL_LightClient.desktop"

        if [ ! -e "$atalho" ]; then
            printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p "/usr/share/applications/ISL_LightClient.desktop" "$atalho" >/dev/null 2>&1
        else
            printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "$atalho" >/dev/null 2>&1
            printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p "/usr/share/applications/ISL_LightClient.desktop" "$atalho" >/dev/null 2>&1
        fi

    done

    echo -e "\n✅ ISL_Light_Client instalado. Execute-o a partir do atalho."
else
    echo -e "\n❌ Falha ao criar atalho do ISL LightClient."
    pause
    menuOptions
fi
}

firebirdPDVInstall() {

firebirdInstallFolder="/tmp/firebird_Install/"
sudo rm -rf $firebirdInstallFolder >/dev/null 2>&1
sudo mkdir -m 777 $firebirdInstallFolder >/dev/null 2>&1

echo -e "\nℹ️ [INFO] - InstallReinstall - 2.5.9.27139-0.i686 Firebird ... - [ $(dateFull_Info) ]"

echo -e "Download Firebird - [ $(dateFull_Info) ]"
sudo wget --no-check-certificate "https://storage.googleapis.com/linux-pdv/Jeff/LinuxFiles/firebird-2.5.zip" -O $firebirdInstallFolder/firebird-2.5.zip >/dev/null 2>&1
    if [ $? -ne 0 ] || [ ! -s $firebirdInstallFolder/firebird-2.5.zip ]; then
		echo "" ; echo -e "Erro Realizar Download Firebird" ; pause ; menuOptions
	fi
echo -e "\nℹ️ Extraindo Firebird"
sudo unzip -q -o $firebirdInstallFolder/firebird-2.5.zip -d $firebirdInstallFolder
	if [ $? -ne 0 ]; then
		echo "" ; echo -e "Erro Extrair Firebird" ; pause ; menuOptions
    else
        sudo rm -rf $firebirdInstallFolder/firebird-2.5.zip >/dev/null 2>&1
   	fi

sudo chmod +x $firebirdInstallFolder/firebird-2.5/FirebirdSS-2.5.9.27139-0.i686/install.sh >/dev/null 2>&1
sudo chmod +x -R $firebirdInstallFolder/firebird-2.5/FirebirdSS-2.5.9.27139-0.i686/* >/dev/null 2>&1

echo -e "\nℹ️ [INFO] - Instalando pacotes e dependencias . . . - [ $(dateFull_Info) ]"
check_repos
sudo apt update
comandosPreparacao
sudo dpkg --add-architecture i386
sudo apt install -y libncurses5 libtommath1 libstdc++5 libncurses5:i386 lib32stdc++6 libncurses6:i386 libtinfo6:i386

firebirdRemover

if [ -e "$firebirdInstallFolder/firebird-2.5/FirebirdSS-2.5.9.27139-0.i686/" ]; then
    echo -e "\nℹ️ [INFO] - Instalando Firebird . . .Aguarde . . . - [ $(dateFull_Info) ]"
    cd $firebirdInstallFolder/firebird-2.5/FirebirdSS-2.5.9.27139-0.i686/
    sudo ./install.sh
else
    echo -e "\nℹ️ [INFO] - FALHA ACESSAR PASTA DE INSTALACAO DO FIREBIRD - [ $(dateFull_Info) ]"
    pause ; menuOptions
fi

local current_date=$(date +%Y-%m-%d)
if [ -d "/opt/firebird" ]; then
	# Obter a data de modificação do diretório /opt/firebird no formato YYYY-MM-DD
	firebird_date=$(stat -c %y /opt/firebird 2>/dev/null | cut -d ' ' -f 1)
	# Comparar a data do diretório com a data atual
	if [ "$firebird_date" == "$current_date" ]; then
		echo -e "\nℹ️ Aplicando permissoes Firebird . . .Aguarde . . . - [ $(dateFull_Info) ]"
		permissioesFirebird
	fi
else
	echo -e "\n❌ [FALHA] - FALHA NA INSTALL/REINSTALL DO FIREBIRD - [ $(dateFull_Info) ]" ; pause
fi
}

firebirdRemover() {
	echo -e "\nℹ️ [INFO] Removendo Firebird...Aguarde... - [ $(dateFull_Info) ]"
	
	variable_firebirdservices=("firebird" "firebird-superserver" "firebird-classic" "firebird-guardian")
	for variable_firebirdservice in "${variable_firebirdservices[@]}"; do
        echo -e "\nParando servicos\n"
		sudo systemctl stop $variable_firebirdservice >/dev/null 2>&1
	done
	
	variable_firebirdprocesses=("firebird" "fbserver" "fbguard")
	for variable_firebirdprocess in "${variable_firebirdprocesses[@]}"; do
		echo -e "Parando processos"
        sudo pkill -9 $variable_firebirdprocess >/dev/null 2>&1
	done
	
	variable_firebirdpackages=("firebird*" "firebi*")
	for variable_firebirdpackage in "${variable_firebirdpackages[@]}"; do
		echo -e "Removendo pacotes"
        sudo apt -y purge $variable_firebirdpackage >/dev/null 2>&1
	done
	
	variable_firebirdpaths=("/etc/firebird*" "/var/lib/firebird*" "/var/log/firebird*" "/usr/lib/firebird*" "/opt/firebird*")
	for variable_firebirdpath in "${variable_firebirdpaths[@]}"; do
		echo -e "Removendo arquivos residuais"
        sudo rm -rf $variable_firebirdpath >/dev/null 2>&1
	done
}

permissioesFirebird() {
sudo chmod -R u+s /opt/firebird 2>/dev/null
# Lista de arquivos e diretórios
files_folders_chown_chmod=(
    "/opt/firebird"
    "/opt/firebird/aliases.conf"
    "/opt/firebird/de_DE.msg"
    "/opt/firebird/fb_guard"
    "/opt/firebird/fbtrace.conf"
    "/opt/firebird/firebird.conf"
    "/opt/firebird/firebird.log"
    "/opt/firebird/firebird.msg"
    "/opt/firebird/fr_FR.msg"
    "/opt/firebird/IDPLicense.txt"
    "/opt/firebird/IPLicense.txt"
    "/opt/firebird/README"
    "/opt/firebird/security2.fdb"
    "/opt/firebird/WhatsNew"
    "/opt/firebird/bin"
    "/opt/firebird/doc"
    "/opt/firebird/examples"
    "/opt/firebird/help"
    "/opt/firebird/include"
    "/opt/firebird/intl"
    "/opt/firebird/lib"
    "/opt/firebird/misc"
    "/opt/firebird/plugins"
    "/opt/firebird/UDF"
)

# Aplicando chown conforme o tipo do item
for item in "${files_folders_chown_chmod[@]}"; do
    if [ -e "$item" ]; then
        case "$item" in
            "/opt/firebird/fb_guard"|"/opt/firebird/firebird.log"|"/opt/firebird/security2.fdb")
                # Arquivos pertencentes ao usuário firebird
                sudo chown firebird:firebird "$item" >/dev/null 2>&1
				sudo chmod 600 "$item" >/dev/null 2>&1
                ;;
            "/opt/firebird/bin"|"/opt/firebird/doc"|"/opt/firebird/help"|"/opt/firebird/include"|"/opt/firebird/intl"|"/opt/firebird/lib"|"/opt/firebird/plugins"|"/opt/firebird/UDF")
                # Diretórios que precisam de chown recursivo
                sudo chown -R root:root "$item" >/dev/null 2>&1
				sudo chmod -R 755 "$item" >/dev/null 2>&1
                ;;
            "/opt/firebird")
                # Diretório principal sem recursão
                sudo chown root:root "$item" >/dev/null 2>&1
				sudo chmod 755 "$item" >/dev/null 2>&1
                ;;
            "/opt/firebird/de_DE.msg"|"/opt/firebird/firebird.msg"|"/opt/firebird/fr_FR.msg"|"/opt/firebird/IDPLicense.txt"|"/opt/firebird/IPLicense.txt")
                sudo chmod 444 "$item" >/dev/null 2>&1
                ;;
            "/opt/firebird/examples")
                sudo chmod -R 555 "$item" >/dev/null 2>&1
				sudo chown -R root:root "$item" >/dev/null 2>&1
                ;;
            "/opt/firebird/misc")
				sudo chown root:root "$item" >/dev/null 2>&1
                sudo chmod -R 700 "$item" >/dev/null 2>&1
                ;;
			"/opt/firebird/aliases.conf"|"/opt/firebird/fbtrace.conf"|"/opt/firebird/firebird.conf"|"/opt/firebird/README"|"/opt/firebird/WhatsNew")
                sudo chmod 644 "$item" >/dev/null 2>&1
				;;
            *)
                # Arquivos normais pertencentes ao root
                sudo chown root:root "$item" >/dev/null 2>&1
                ;;
        esac
    fi
done

}
java_x64_InstallReinstall() {

echo -e "\nℹ️ [INFO] - Instalando Java 11 | Java 8 | Java jdk1.8.0_202 - [ $(dateFull_Info) ]"
sudo apt update
sudo apt-get install ttf-mscorefonts-installer

echo -e "\nℹ️ [INFO] - Instalando Java 8 - [ $(dateFull_Info) ]"
sudo apt install -y openjdk-8-jdk
echo -e "\nℹ️ [INFO] - Instalando Java 11 - [ $(dateFull_Info) ]"
sudo apt install -y openjdk-11-jdk

if [ -d "/usr/lib/jvm/jdk1.8.0_202" ]; then
    sudo rm -rf /usr/lib/jvm/jdk1.8.0_202 >/dev/null 2>&1
fi

echo -e "\nℹ️ [INFO] - Instalando Java jdk1.8.0_202 - [ $(dateFull_Info) ]"
JAVA_JDK_URL="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Linux/jdk-8u202-linux-x64.tar.gz"
JAVA_JDK_FILE="/tmp/java_jdk_download/jdk-8u202-linux-x64.tar.gz"
sudo rm -rf /tmp/java_jdk_download >/dev/null 2>&1
sudo mkdir -m 777 /tmp/java_jdk_download >/dev/null 2>&1
wget -O "$JAVA_JDK_FILE" "$JAVA_JDK_URL" || pause_on_error
tar -xvzf "/tmp/java_jdk_download/jdk-8u202-linux-x64.tar.gz" -C "/tmp/java_jdk_download" >/dev/null 2>&1 || pause_on_error

if [ ! -d "/usr/lib/jvm/" ]; then
    sudo mkdir "/usr/lib/jvm/" >/dev/null 2>&1
    sudo chmod 755 "/usr/lib/jvm/" >/dev/null 2>&1
    sudo chown nobody:nogroup "/usr/lib/jvm/" >/dev/null 2>&1
    echo
fi
sudo mv "/tmp/java_jdk_download/jdk1.8.0_202" "/usr/lib/jvm/" || pause_on_error
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.8.0_202/bin/java 2000

if [ -e "/usr/lib/jvm/jdk1.8.0_202/bin/java" ]; then
    echo -e "\nℹ️ [INFO] - Java jdk1.8.0_202 instalado com sucesso - [ $(dateFull_Info) ]"
fi
if [ -e "/usr/lib/jvm/java-11-openjdk-amd64/bin/java" ]; then
    echo -e "\nℹ️ [INFO] - Java 11 instalado com sucesso - [ $(dateFull_Info) ]"
    /usr/lib/jvm/java-11-openjdk-amd64/bin/java -version
fi
if [ -e "/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java" ]; then
    echo -e "\nℹ️ [INFO] - Java 8 instalado com sucesso - [ $(dateFull_Info) ]"
    /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java -version
fi
}

javaPdvInstall() {

	local javaFile="/usr/lib/jvm/java-8-openjdk-i386/jre/bin/java"
	if [ ! -e "$javaFile" ]; then
        echo -e "\nℹ️ [INFO] - Instalando java 8 i386 (x86)... - [ $(dateFull_Info) ]"
        echo -e "\nℹ️ [INFO] - Executando preparacao de pacotes... - [ $(dateFull_Info) ]"
        check_repos
        sudo apt update
        comandosPreparacao
        echo -e "\nℹ️ [INFO] - Instalando java 8 i386 (x86)... - [ $(dateFull_Info) ]"
		sudo apt -y install openjdk-8-jre:i386
        if [ -e "$javaFile" ]; then
            echo -e "\nℹ️ [INFO] - Java 8 i386 (x86) instalado com sucesso... - [ $(dateFull_Info) ]"
        else
            echo -e "\n❌ [FALHA] - Erro ao instalar Java8 i386 (x86)... - [ $(dateFull_Info) ]" ; pause
        fi
    else
        echo -e "\nℹ️ [INFO] - Java 8 i386 (x86) ja esta instalado...Realizando remocao de java x86 - [ $(dateFull_Info) ]"
        sudo apt-get remove -y --purge openjdk-8-jre:i386
		sudo apt -y remove 'openjdk-8-*'
        echo -e "\nℹ️ [INFO] - Instalando java8 i386 (x86)... - [ $(dateFull_Info) ]"
        echo -e "\nℹ️ [INFO] - Executando preparacao de pacotes... - [ $(dateFull_Info) ]"
        check_repos
        sudo apt update
        comandosPreparacao
        echo -e "\nℹ️ [INFO] - Instalando java pdv... - [ $(dateFull_Info) ]"
		sudo apt -y install openjdk-8-jre:i386
        if [ -e "$javaFile" ]; then
            echo -e "\nℹ️ [INFO] - Java 8 i386 (x86) instalado com sucesso... - [ $(dateFull_Info) ]"
            /usr/lib/jvm/java-8-openjdk-i386/jre/bin/java -version
        else
            echo -e "\n❌ [FALHA] - Erro ao instalar Java8 i386 (x86)... - [ $(dateFull_Info) ]" ; pause
        fi
	fi
}

javaRemover() {
printf '%s\n' "$PASSWD" | safe_apt -y remove 'openjdk-*'
printf '%s\n' "$PASSWD" | safe_apt_get remove -y --purge openjdk-8-jre:i386
printf '%s\n' "$PASSWD" | safe_apt -y remove 'openjdk-8-*'
printf '%s\n' "$PASSWD" | safe_apt -y remove 'openjdk-11-*'
printf '%s\n' "$PASSWD" | sudo -S -p '' update-alternatives --remove-all java
printf '%s\n' "$PASSWD" | sudo -S -p '' update-alternatives --remove-all javac    
}

setRestartAppsServer() {
SCRIPT_PATH="/vr/RestartApps.sh"

    echo ""
    echo "=============================================="
    echo "      CRIADOR DE /vr/RestartApps.sh"
    echo "=============================================="

    # Detecta o caminho existente
    if [ -e "/vr/exec/VRConcentrador.jar" ] || [ -e "/vr/exec/VRAutorizador.jar" ]; then
        execPath="/vr/exec"
    elif [ -e "/home/$USER/.vr/server/exec/VRConcentrador.jar" ] || [ -e "/home/$USER/.vr/server/exec/VRAutorizador.jar" ]; then
        execPath="/home/$USER/.vr/server/exec"
    else
        echo -e "\n❌ Nenhum dos caminhos de execucao foi encontrado!"
        pause ; menuOptions
    fi
    if [ -z "$execPath" ]; then
        echo -e "\n❌ Nenhum dos caminhos de execucao foi encontrado!"
        pause ; menuOptions
    fi

    echo -e "\n✅ Caminho de execucao dos arquivos .jar detectado: $execPath"

    # Solicita senha sudo
if [ -z "$PASSWD" ]; then
    read -s -p "Digite a senha sudo: " PASSWD_SUDO
    if [ -z "$PASSWD_SUDO" ]; then
        echo -e "\n❌ Senha nao informada. Abortando."
        pause ; menuOptions
    fi
    test_PW "$PASSWD_SUDO"
else 
    echo -e "\n✅ Senha sudo ja detectada: $PASSWD"
fi

    echo ""
    echo "Selecione os apps a incluir no script:"
    echo "1) VRConcentrador"
    echo "2) VRAutorizador"
    echo "3) Ambos"
    read -p "Escolha (1/2/3): " escolha

    include_concentrador=false
    include_autorizador=false

    case $escolha in
        1) include_concentrador=true ;;
        2) include_autorizador=true ;;
        3) include_concentrador=true; include_autorizador=true ;;
        *) echo "Opcao invalida"; return 1 ;;
    esac

    echo
    echo -e "Gerando /vr/RestartApps.sh ..."

    filepermission_create "/vr/RestartApps.sh"
    # Criação do script
    echo "$PASSWD" | sudo -S tee /vr/RestartApps.sh >/dev/null <<EOF
#!/bin/bash

log_file="/vr/log/RestartApps.txt"
# Para rastrear o funcionamento dos restarts, execute "gedit /vr/log/RestartApps.txt" no terminal

# Defina o caminho dos executáveis. Remova o # para ativar a linha. Nao pode ter as duas linhas ativas.
execPath="$execPath"

## Senha sudo mandatória
PASSWD="$PASSWD"
DISPLAY=:0

echo "\$PASSWD" | sudo -S touch \$log_file >/dev/null 2>&1
echo "\$PASSWD" | sudo -S chmod 777 \$log_file >/dev/null 2>&1

check_java_app() {
    app_name="\$1"
    pids=\$(ps -ef | grep java | grep "\$app_name" | awk '{print \$2}')
    if [ -n "\$pids" ]; then
        echo "\$(date): App \$app_name (PIDs: \$pids) inicializado com sucesso" >> "\$log_file"
    else
        echo "\$(date): App \$app_name nao inicializado" >> "\$log_file"
    fi
}

kill_java_app() {
    app_name="\$1"
    pids=\$(ps -ef | grep java | grep "\$app_name" | awk '{print \$2}')
    if [ -n "\$pids" ]; then
        echo "\$(date): Fechando \$app_name (PIDs: \$pids)" >> "\$log_file"
        echo \$PASSWD | sudo -S kill \$pids >/dev/null 2>&1 &
        sleep 2
        for pid in \$pids; do
            if ps -p \$pid > /dev/null; then
                echo "\$(date): \$app_name PID \$pid ainda ativo. Matando forçadamente." >> "\$log_file"
                echo \$PASSWD | sudo -S kill -9 \$pid >/dev/null 2>&1 &
            fi
        done
    fi
}

start_java_app() {
    app_name="\$1"
    jar_path="\$2"
    echo "\$(date): Iniciando \$app_name" >> "\$log_file"
    DISPLAY=:0 java -jar "\$jar_path" &
    if [ \$? -eq 0 ]; then
        echo "\$(date): \$app_name iniciado com sucesso" >> "\$log_file"
    else
        echo "\$(date): \$app_name NAO iniciado" >> "\$log_file"
    fi
}

EOF

    # Adiciona chamadas conforme seleção
    if $include_concentrador; then
        echo 'kill_java_app "Concentrador"' | sudo tee -a /vr/RestartApps.sh >/dev/null
    else
        echo '#kill_java_app "Concentrador"' | sudo tee -a /vr/RestartApps.sh >/dev/null
    fi

    if $include_autorizador; then
        echo 'kill_java_app "Autorizador"' | sudo tee -a /vr/RestartApps.sh >/dev/null
    else
        echo '#kill_java_app "Autorizador"' | sudo tee -a /vr/RestartApps.sh >/dev/null
    fi

    echo >> /vr/RestartApps.sh

    if $include_concentrador; then
        echo 'start_java_app "VR Concentrador" "$execPath/VRConcentrador.jar"' | sudo tee -a /vr/RestartApps.sh >/dev/null
    else
        echo '#start_java_app "VR Concentrador" "$execPath/VRConcentrador.jar"' | sudo tee -a /vr/RestartApps.sh >/dev/null
    fi

    if $include_autorizador; then
        echo 'start_java_app "VR Autorizador" "$execPath/VRAutorizador.jar"' | sudo tee -a /vr/RestartApps.sh >/dev/null
    else
        echo '#start_java_app "VR Autorizador" "$execPath/VRAutorizador.jar"' | sudo tee -a /vr/RestartApps.sh >/dev/null
    fi

    cat <<'EOF' | sudo tee -a /vr/RestartApps.sh 2>/dev/null

sleep 20 >/dev/null 2>&1

EOF

    if $include_concentrador; then
        echo 'check_java_app "Concentrador"' | sudo tee -a /vr/RestartApps.sh >/dev/null
    else
        echo '#check_java_app "Concentrador"' | sudo tee -a /vr/RestartApps.sh >/dev/null
    fi

    if $include_autorizador; then
        echo 'check_java_app "Autorizador"' | sudo tee -a /vr/RestartApps.sh >/dev/null
    else
        echo '#check_java_app "Autorizador"' | sudo tee -a /vr/RestartApps.sh >/dev/null
    fi

    cat <<'EOF' | sudo tee -a /vr/RestartApps.sh 2>/dev/null

echo "\$(date): Script concluído." >> "\$log_file"
echo "================================================================" >> "\$log_file"
EOF

if [ -e "/vr/RestartApps.sh" ]; then
    # Permissão de execução
    echo "$PASSWD" | sudo -S chmod +x /vr/RestartApps.sh
    echo -e "\n✅ Arquivo /vr/RestartApps.sh criado com sucesso!"
    echo "Conteudo adaptado conforme selecao."
else
    echo
    echo -e "\n❌ Erro ao criar o arquivo /vr/RestartApps.sh."
    echo "Verifique as permissoes do usuario."
    pause ; menuOptions
fi

echo ""
echo "=========================================="
echo "     CONFIGURACAO DE TAREFA CRONTAB"
echo "=========================================="
echo "Selecione o intervalo desejado:"
echo "1) A cada 2 horas"
echo "2) A cada 1 hora"
echo "3) A cada 30 minutos"
echo "4) A cada 45 minutos"
echo "5) Cancelar"
echo "=========================================="
read -p "Opcao: " opcao

# Define o agendamento conforme escolha
case "$opcao" in
  1) tempo="0 */2 * * *"
     time="2hr";;
  2) tempo="0 */1 * * *"
     time="1hr";;
  3) tempo="*/30 * * * *"
     time="30mins";;
  4) tempo="*/45 * * * *"
     time="45mins";;
  5) echo "Operacao cancelada."; exit 0;;
  *) echo "Opcao invalida."; exit 1;;
esac

# Caminho temporário
TMP_CRON="/tmp/cron_atual_$$.txt"
TMP_NEW="/tmp/cron_novo_$$.txt"

# Faz backup e cria base
crontab -l 2>/dev/null > "$TMP_CRON"

# Remove QUALQUER uma das quatro linhas anteriores (seguras com regex)
grep -Ev "^(0 \*/2 \* \* \*|0 \*/1 \* \* \*|\*/30 \* \* \* \*|\*/45 \* \* \* \*)[[:space:]]+$SCRIPT_PATH$" "$TMP_CRON" > "$TMP_NEW"

# Adiciona nova linha no final
echo "$tempo $SCRIPT_PATH" >> "$TMP_NEW"

# Aplica o novo crontab
crontab "$TMP_NEW"

# Limpa arquivos temporários
rm -f "$TMP_CRON" "$TMP_NEW"

# Confirma configuração
echo
echo "✅ Tarefa agendada com sucesso! - [ $(dateFull_Info) ]"
echo "⏰ Intervalo: $time"
echo "📄 Script: $SCRIPT_PATH"
echo
echo "Crontab atual:"
echo "------------------------------------------"
crontab -l
echo "------------------------------------------"

echo -e "\nℹ️ [INFO] - Reiniciando servico cron... - [ $(dateFull_Info) ]"
sudo service cron restart

echo -e "\nℹ️ [INFO] - Configuracao Script Restart e Agendamento concluida... - [ $(dateFull_Info) ]"

}

create_scriptMercafacilCRM() {
    local jarPathExec="$1"

    if [ ! -d "/vr" ]; then
        folder_create "/vr"
    fi

    variable_filescripts=("$fileScript" "$fileScript_Config")
	for variable_filescript in "${variable_filescripts[@]}"; do
	    if [ -e "$variable_filescript" ]; then
            echo "$PASSWD" | sudo -S rm -f "$variable_filescript" >/dev/null 2>&1
        fi
        filepermission_create "$variable_filescript"
        echo "$PASSWD" | sudo -S chmod +x "$variable_filescript" >/dev/null 2>&1
    done

echo "$PASSWD" | sudo -S bash -c "
{
  echo '#!/bin/bash'
  echo 'while :; do'
  echo '/usr/lib/jvm/java-11-openjdk-amd64/bin/java -Dfile.encoding=UTF-8 -jar \"$jarPathExec/VRGerenciadorMercaFacil.jar\" -log &'
  echo 'X=\$!'
  echo 'sleep 60'
  echo 'kill -9 \$X'
  echo 'done'
} > \"$fileScript\""

    
echo "$PASSWD" | sudo -S bash -c "
{
  echo '#!/bin/bash'
  echo 'java -Dfile.encoding=UTF-8 -jar \"$jarPathExec/VRGerenciadorMercaFacil.jar\" -log -config'
  echo 'exit'
} > \"$fileScript_Config\""

}

create_shortcutMercafacilCRM() {
	local jarPathExec="$1"
	
	if [ -e "/usr/share/pixmaps/vrutil.png" ]; then
		local icoFile="/usr/share/pixmaps/vrutil.png"
	elif [ -e "/vr/exec/img/vrutil.png" ]; then
		local icoFile="/vr/exec/img/vrutil.png"
	elif [ -e "$HOME/.vr/server/exec/img/vrutil.png" ]; then
		local icoFile="$HOME/.vr/server/exec/img/vrutil.png"
	elif [ -e "/usr/share/pixmaps/vrutil.ico" ]; then
		local icoFile="/usr/share/pixmaps/vrutil.ico"
	elif [ -e "/vr/exec/img/vrutil.ico" ]; then
		local icoFile="/vr/exec/img/vrutil.ico"
	elif [ -e "$HOME/.vr/server/exec/img/vrutil.ico" ]; then
		local icoFile="$HOME/.vr/server/exec/img/vrutil.ico"
	else
		local icoFile="vrmaster"
	fi

	while IFS= read -r desktopFolder; do
            echo "$PASSWD" | sudo -S rm -f "$desktopFolder/VRGerenciadorMercafacilCRM.desktop" >/dev/null 2>&1
			echo "$PASSWD" | sudo -S rm -f "$desktopFolder/VRGerenciadorMercafacil_CONFIG.desktop" >/dev/null 2>&1
    done < <(setshortcutfiles)

while IFS= read -r desktopFolder; do
    # Cria o .desktop (o $icoFile será expandido)
    printf '%s\n' "$PASSWD" | sudo -S bash -c "cat > \"$desktopFolder/VRGerenciadorMercafacilCRM.desktop\" <<EOF
[Desktop Entry]
Name=VRGerenciadorMercafacilCRM
Path=/vr/
Exec=bash -c \"/vr/VRGerenciadormercafacil.sh; bash\"
Terminal=true
Type=Application
Icon=$icoFile
Categories=System
EOF" >/dev/null 2>&1

    # Torna executável
    printf '%s\n' "$PASSWD" | sudo -S chmod +x "$desktopFolder/VRGerenciadorMercafacilCRM.desktop" >/dev/null 2>&1
done < <(setshortcutfiles)

while IFS= read -r desktopFolder; do
    # Cria/ sobrescreve o .desktop (icoFile será expandido)
    printf '%s\n' "$PASSWD" | sudo -S bash -c "cat > \"$desktopFolder/VRGerenciadorMercafacil_CONFIG.desktop\" <<EOF
[Desktop Entry]
Name=VRGerenciadorMercafacil_CONFIG
Path=/vr/
Exec=bash -c \"/vr/VRGerenciadormercafacil_config.sh; bash\"
Terminal=true
Type=Application
Icon=$icoFile
Categories=System
EOF" >/dev/null 2>&1

    # Torna executável
    printf '%s\n' "$PASSWD" | sudo -S chmod +x "$desktopFolder/VRGerenciadorMercafacil_CONFIG.desktop" >/dev/null 2>&1
done < <(setshortcutfiles)

	if [ -e "$HOME/Desktop/VRGerenciadorMercafacilCRM.desktop" ]; then
		echo "$PASSWD" | sudo -S cp --remove-destination -p "$HOME/Desktop/VRGerenciadorMercafacilCRM.desktop" "$HOME/.config/autostart" 2>/dev/null
	elif [ -e "$HOME/Área de Trabalho/VRGerenciadorMercafacilCRM.desktop" ]; then
		echo "$PASSWD" | sudo -S cp --remove-destination -p "$HOME/Área de Trabalho/VRGerenciadorMercafacilCRM.desktop" "$HOME/.config/autostart" 2>/dev/null
	fi
}

valida_execPath() {
jar_vr_exec="$jarPath_vr_exec/VRGerenciadorMercaFacil.jar"
jar_home_vr_exec="$jarPath_home_vr_exec/VRGerenciadorMercaFacil.jar"

if [ -e "$jar_vr_exec" ] && [ -e "$jar_home_vr_exec" ]; then
    echo "Aviso: O arquivo JAR foi encontrado em ambos os locais."
    echo Local 1: "$jar_vr_exec"
	echo Local 2: "$jar_home_vr_exec"
	echo "Sera necessario verificar qual o caminho tem o arquivo mais atualizado e escolhe-lo"
	read -p "Qual caminho deseja usar para a configuracao: " jarPath_select
	if [ -z "$jarPath_select" ] || ! [[ "$jarPath_select" =~ ^[0-9]+$ ]]; then
		echo -e "\n❌ [FALHA] Erro: você deve escolher uma opcao valida." ; sleep 2 ; valida_execPath
	fi
	if [ $jarPath_select -eq 1 ]; then
		create_scriptMercafacilCRM "$jarPath_vr_exec"
		create_shortcutMercafacilCRM "$jarPath_vr_exec"
	fi
	if [ $jarPath_select -eq 2 ]; then
		create_scriptMercafacilCRM "$jarPath_home_vr_exec"
		create_shortcutMercafacilCRM "$jarPath_home_vr_exec"
	fi
	if [ $jarPath_select -eq 3 ]; then
		exit
	fi
	if [ $jarPath_select -ge 4 ]; then
		echo -e "\n❌ Opcao incorreta, retornando ao menu principal" ; pause ; valida_execPath
	fi
elif [ -e "$jar_vr_exec" ]; then
    create_scriptMercafacilCRM "$jarPath_vr_exec"
	create_shortcutMercafacilCRM "$jarPath_vr_exec"
elif [ -e "$jar_home_vr_exec" ]; then
    create_scriptMercafacilCRM "$jarPath_home_vr_exec"
	create_shortcutMercafacilCRM "$jarPath_home_vr_exec"
else
    echo -e "❌ ERRO: VRGerenciadorMercaFacil.jar não foi encontrado em nenhum dos diretórios.\nEscolhe um dos caminhos abaixo para seguir com a configuracao e posteriormente envie o arquivo VRGerenciadorMercafacilCRM.jar para a pasta" >&2
	echo Local 1: "$jar_vr_exec"
	echo Local 2: "$jar_home_vr_exec"
    echo ""
	read -r -p -e "Forneça o caminho manual: " jarPath
	create_scriptMercafacilCRM "$jarPath"
fi
}

checkFiles() {
	if [ -e "$fileScript" ]; then
    	echo -e "✅ [SUCESSO] - Script MercafacilCRM criado com sucesso"
	else
		echo -e "[INFO] - Script MercafacilCRM NAO encontrado"
    fi
	if [ -e "$fileScript_Config" ]; then
    	echo -e "✅ [SUCESSO] - Script MercafacilCRM Config criado com sucesso"
	else
		echo -e "\nℹ️ [INFO] - Script MercafacilCRM Config NAO encontrado"
	fi

shortcuts_to_create=(
    "VRGerenciadorMercafacilCRM.desktop"
    "VRGerenciadorMercafacil_CONFIG.desktop"
)
    for shortcut_file in "${shortcuts_to_create[@]}"; do
        while IFS= read -r desktopFolder; do
            if [ -e "$desktopFolder/$shortcut_file" ]; then
                echo -e "✅ [SUCESSO] - Atalho '$shortcut_file' encontrado em '$desktopFolder'."
            else
                echo -e "✅ [INFO] - Atalho '$shortcut_file' NÃO encontrado em '$desktopFolder'."
            fi
        done < <(setshortcutfiles)
    done
}

settingVRProperties_Mercafacil() {
propertiesFiles=( "/vr/vr.properties" "$HOME/.vr/server/vr.properties" "$HOME/.vr/vr.properties" )
for propertiesFile in "${propertiesFiles[@]}"; do
	if [ -e "$propertiesFile" ]; then
		local file=$propertiesFile
		filepermission $file
		echo "$PASSWD" | sudo -S cp -p "$propertiesFile" "$propertiesFile.backup_$(date +%Y%m%d%H%M%S)" >/dev/null 2>&1

		local patterns=(
		"#================================================"
		"gerenciadormercafacil.diasretroativos"
		"gerenciadormercafacil.limiteregistrosvenda"
		"gerenciadormercafacil.limiteregistros"
		"gerenciadormercafacil.homologacao"
		"mercafacil.tipoambiente"
		)
		clearLinesFromFile "$file" "${patterns[@]}"
		filepermission "$file"

		echo "#================================================" >> "$file"
		echo "gerenciadormercafacil.diasretroativos = 180" >> "$file"
		echo "gerenciadormercafacil.limiteregistrosvenda = 200" >> "$file"
		echo "gerenciadormercafacil.limiteregistros = 10000" >> "$file"
		echo "gerenciadormercafacil.homologacao = false" >> "$file"
		echo "mercafacil.tipoambiente = 1" >> "$file"
		echo "#================================================" >> "$file"

		echo -e "✅ [SUCESSO] - $file ajustado com sucesso"
	fi
done
}

clearLinesFromFile () {
    local file="$1"
    shift   # remove o 1º argumento (o arquivo), o resto são padrões

    # Faz backup
    cp "$file" "$file.bak_$(date +%Y%m%d%H%M%S)"

    > "$file.tmp"

    while IFS= read -r line; do
        skip=false
        for pat in "$@"; do
            if [[ "$line" == "$pat"* ]]; then
                skip=true
                break
            fi
        done
        $skip || echo "$line" >> "$file.tmp"
    done < "$file"

    mv "$file.tmp" "$file"
}

install_update_Gnome() {
	echo ""
	echo "$PASSWD" | sudo -S apt update
	echo "$PASSWD" | sudo -S apt-get -yq install gnome-terminal
	echo ""
}

criar_Atalho_PortalPedidos() {
filepermission_create "/usr/share/applications/Portal_VRGerenciadorIfood.desktop"
filepermission_create "/usr/share/applications/Config_VRGerenciadorIfood.desktop"

cat <<EOF > "/usr/share/applications/Portal_VRGerenciadorIfood.desktop" 2>/dev/null
[Desktop Entry]
Version=1.0
Type=Application
Name=Portal VRGerenciador Ifood
Comment=Abre o Portal VRGerenciador Ifood no navegador
Exec=xdg-open http://localhost:9031/VRGerenciadorIfood/pedidos
Icon=web-browser
Categories=Network;WebBrowser;
Terminal=false
StartupNotify=true
EOF

cat <<EOF > "/usr/share/applications/Config_VRGerenciadorIfood.desktop" 2>/dev/null
[Desktop Entry]
Version=1.0
Type=Application
Name=Config VRGerenciador Ifood
Comment=Abre o Config VRGerenciador Ifood
Exec=x-terminal-emulator -e bash -c "/vr/ifood.sh; exec bash"
Icon=web-browser
Categories=Network;WebBrowser;
Terminal=false
StartupNotify=true
EOF
}

download_Arquivo() {
    echo ""
    echo -e "ℹ️ [INFO] Criando pastas temporarias"
    pastas_Temp
    echo -e "ℹ️ [INFO] Download Arquivos"
    printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $URL_GERENCIADORIFOOD -O $DESTINO_TEMP/VRGerenciadorIfood.zip 2>/dev/null
	echo -e "ℹ️ [INFO] Extraindo Arquivos"
    printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o $DESTINO_TEMP/VRGerenciadorIfood.zip -d $APP_DIR 2>/dev/null
	# printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $DESTINO_TEMP/VRGerenciadorIfood.zip 2>/dev/null
    
    local unzip_result=$?
    local checkFile
    {
        shopt -s nullglob
        checkFile=("$APP_DIR"/*)
        shopt -u nullglob
    }

    if [ $unzip_result -ne 0 ]; then
        echo -e "\n❌ [ERRO] Falha no comando de extração unzip"
        exit 1
    elif [ ${#checkFile[@]} -eq 0 ]; then
        echo -e "\n❌ [ERRO] Extração concluída mas pasta vazia - arquivo $DESTINO_TEMP/VRGerenciadorIfood.zip pode estar corrompido ou vazio"
        exit 1
    else
        echo -e "✅ [OK] Arquivo extraído com sucesso - ${#checkFile[@]} arquivos em $APP_DIR"
    fi
}

# Função para validar e criar diretório
criar_diretorio() {
    echo ""
    echo -e "ℹ️ [INFO] Validando e criando diretorio: $APP_DIR"

    if [ ! -d "$APP_DIR" ]; then
        printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p "$APP_DIR"
        if [ $? -eq 0 ]; then
            printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 "$APP_DIR"
            echo -e "ℹ️ [INFO] Diretorio $APP_DIR criado com sucesso"
        else
            echo -e "❌ [FALHA] Erro ao criar diretorio!"
            exit 1
        fi
    else
        echo -e "ℹ️ [INFO] Diretorio ja existe"
        printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 "$APP_DIR"
    fi
}

# Função para exibir menu e coletar dados
coletar_dados() {
    echo ""
    echo "=== CONFIGURAÇAO VRGerenciadorIFood ==="
    echo ""
    
    # Solicitar dados do banco
    read -p "Digite o DATABASE_IP: " DATABASE_IP
    read -p "Digite o DATABASE_PORTA: " DATABASE_PORTA
    read -p "Digite o DATABASE_USUARIO: " DATABASE_USUARIO
    read -p "Digite o DATABASE_SENHA: " DATABASE_SENHA
    read -p "Digite o DATABASE_NOME: " DATABASE_NOME
    echo ""
    echo -e "Abrindo portal de Versao do GerenciadorIfood no navegador...\n"
    nohup firefox "https://hub.docker.com/r/vrsoftbr/vrgerenciadorifood/tags" </dev/null &>/dev/null &
    read -p "Digite a Versao VRGerenciadorIFood: " VERSAO
    
    # Validar dados obrigatórios
    if [ -z "$DATABASE_IP" ] || [ -z "$DATABASE_PORTA" ] || [ -z "$DATABASE_USUARIO" ] || [ -z "$DATABASE_SENHA" ] || [ -z "$DATABASE_NOME" ] || [ -z "$VERSAO" ]; then
        echo -e "❌ [FALHA] Erro: Todos os campos sao obrigatorios!"
        exit 1
    fi
}

# Função para criar/atualizar arquivo .env
criar_arquivo_env() {
    echo ""
    echo -e "ℹ️ [INFO] Criando/atualizando arquivo .env..."
    
printf '%s\n' "$PASSWD" | sudo -S -p '' tee "$ENV_FILE" > /dev/null << EOF
DATABASE_IP=$DATABASE_IP
DATABASE_PORTA=$DATABASE_PORTA
DATABASE_USUARIO=$DATABASE_USUARIO
DATABASE_SENHA=$DATABASE_SENHA
DATABASE_NOME=$DATABASE_NOME
EOF

    if [ $? -eq 0 ]; then
        echo -e "ℹ️ [INFO] Arquivo .env criado/atualizado com sucesso!"
        printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 600 "$ENV_FILE"
    else
        echo -e "❌ [FALHA] Erro ao criar arquivo .env!"
        exit 1
    fi
}

# Função para atualizar docker-compose
atualizar_docker_compose() {
    echo -e "ℹ️ [INFO] Atualizando docker-compose com a versao $VERSAO..."
    
    # Verificar se o arquivo existe
    if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
        echo -e "❌ [FALHA] Aviso: Arquivo docker-compose não encontrado em $DOCKER_COMPOSE_FILE"
        exit 1
    else
        # Atualizar a versão no arquivo existente
        printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i "s|vrsoftbr/vrgerenciadorifood:[^[:space:]]*|vrsoftbr/vrgerenciadorifood:$VERSAO|g" "$DOCKER_COMPOSE_FILE"
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "ℹ️ [INFO] Docker-compose atualizado com sucesso!"
        # chmod 644 "$DOCKER_COMPOSE_FILE"
    else
        echo -e "❌ [FALHA] Erro ao atualizar docker-compose!"
        exit 1
    fi
}

# Função principal
config_iFood() {
    echo ""
    echo "Iniciando configuração do VRGerenciadorIFood..."
    
    # Criar diretório
    criar_diretorio
    
    download_Arquivo

    # Coletar dados
    coletar_dados
    
    # Criar arquivo .env
    criar_arquivo_env
    
    # Atualizar docker-compose
    atualizar_docker_compose
    
    echo ""
    finished
    echo "=== CONFIGURAÇÃO CONCLUÍDA ==="
    echo "Diretório: $APP_DIR"
    echo "Arquivo .env: $ENV_FILE"
    echo "Docker-compose: $DOCKER_COMPOSE_FILE"
    echo ""
    echo "Configurações aplicadas:"
    echo "Versão: $VERSAO"
    echo "Database: $DATABASE_IP:$DATABASE_PORTA"
    echo ""
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
    echo "6. Instalar/Reinstalar Firebird para Concentrador"
    echo "7. Instalar/Reinstalar Java 11 | Java 8 | Java jdk1.8.0_202 (x64 | amd64)"
    echo "8. Instalar/Reinstalar Java x86"
    echo "9. Listar javas com update-alternatives --list java"
	echo "10. Config Restart App [Concentrador, Autorizador]"
    echo "11. Config MercafacilCRM"
    echo "12. Instalar o VRGerenciadorIFood"
    echo "13. Alterar Versao VRGerenciadorIFood"
    echo "14. Alterar Configs Banco VR no .env"
    echo "15. Iniciar container VRGrenciadorIfood"
    echo "16. Reiniciar container VRGrenciadorIfood"
    echo "17. Desativar o VRGerenciadorIFood"
    echo "18. Deslogar forçado do portal VRGerenciadorIFood"
    echo "19. SAIR"
	read -p "Opcao: " OPTISLMENU

	if [ -z "$OPTISLMENU" ] || ! [[ "$OPTISLMENU" =~ ^[0-9]+$ ]]; then
        echo -e "\nErro: você deve escolher uma opcao valida." ; sleep 2 ; menuOptions
	fi
	if [ $OPTISLMENU -eq 1 ]; then
        islOnlineType=AlwaysOn
        islOnline_AlwaysOn
        islOnline_Atalho
        finished ; pause ; menuOptions
	fi
	if [ $OPTISLMENU -eq 2 ]; then
        islOnlineType=LightClient
        islOnline_LightClient
        islOnline_Atalho
        finished ; pause ; menuOptions
	fi
	if [ $OPTISLMENU -eq 3 ]; then
        echo -e "\nInstalando dependencias ISL"
        islOnline_Dependencias
        finished ; pause ; menuOptions
	fi
	if [ $OPTISLMENU -eq 4 ]; then
	    firefox
        finished ; pause ; menuOptions
	fi
	if [ $OPTISLMENU -eq 5 ]; then
	    rustdeskInstallReinstall
        finished ; pause ; menuOptions
	fi
	if [ $OPTISLMENU -eq 6 ]; then
	    firebirdPDVInstall
        finished ; pause ; menuOptions
	fi
	if [ $OPTISLMENU -eq 7 ]; then
	    java_x64_InstallReinstall
        finished ; pause ; menuOptions
	fi
	if [ $OPTISLMENU -eq 8 ]; then
	    javaPdvInstall
        finished ; pause ; menuOptions
	fi
	if [ $OPTISLMENU -eq 9 ]; then
        echo ""
	    update-alternatives --list java
        pause ; menuOptions
	fi
	if [ $OPTISLMENU -eq 10 ]; then
	    setRestartAppsServer
        pause ; menuOptions
	fi
	if [ $OPTISLMENU -eq 11 ]; then
        clear
        echo -e "\n============================================"
        echo -e "Assistente de configuracao MercafacilCRM Linux\n"
        valida_execPath
        create_shortcutMercafacilCRM
        install_update_Gnome
        settingVRProperties_Mercafacil
        checkFiles
        finished
        menuOptions
	fi
    if [ $OPTMENUOPTIONS -eq 12 ]; then
        config_iFood ; criar_Atalho_PortalPedidos ; finished ; pause ; menuOptions
    fi
    if [ $OPTMENUOPTIONS -eq 13 ]; then
        echo ""
        read -p "Digite a Versao VRGerenciadorIFood (formato: X.X.X): " VERSAO
        # Remover espaços extras
        VERSAO=$(echo "$VERSAO" | xargs)

        if [ -z "$VERSAO" ]; then
            echo "Erro: Versao nao informada"
            exit 1
        fi

        # Validar formato: apenas números e pontos, no formato X.X.X
        if ! echo "$VERSAO" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
            echo "Erro: Formato de versao invalido!"
            echo "Use apenas numeros e pontos no formato: NUMBER.NUMBER.NUMBER"
            echo "Exemplo: 1.4.0, 2.0.1, 1.12.5"
            exit 1
        fi

        # Validar que cada parte da versão é um número válido
        IFS='.' read -ra VERSION_PARTS <<< "$VERSAO"
        for part in "${VERSION_PARTS[@]}"; do
            if ! [[ "$part" =~ ^[0-9]+$ ]]; then
                echo "Erro: Parte da versao invalida: '$part'"
                echo "Cada parte deve conter apenas numeros"
                exit 1
            fi
        done

        echo "Versao validada: $VERSAO"
        atualizar_docker_compose ; finished ; pause ; menuOptions
    fi
    if [ $OPTMENUOPTIONS -eq 14 ]; then
        echo ""
        read -p "Digite o DATABASE_IP: " DATABASE_IP
        read -p "Digite o DATABASE_PORTA: " DATABASE_PORTA
        read -p "Digite o DATABASE_USUARIO: " DATABASE_USUARIO
        read -p "Digite o DATABASE_SENHA: " DATABASE_SENHA
        read -p "Digite o DATABASE_NOME: " DATABASE_NOME
        if [ -z "$DATABASE_IP" ] || [ -z "$DATABASE_PORTA" ] || [ -z "$DATABASE_USUARIO" ] || [ -z "$DATABASE_SENHA" ] || [ -z "$DATABASE_NOME" ]; then
            echo "Erro: Todos os campos solicitados sao obrigatorios"
            exit 1
        else
            criar_arquivo_env
        fi
        finished ; pause ; menuOptions
    fi
    if [ $OPTMENUOPTIONS -eq 15 ]; then
        echo ""
        echo "Iniciando containers..."
        cd $HOME/.vr/integracao/vrgerenciadorifood/
        sudo docker compose -f docker-compose-gerenciadorifood.yml up -d
        finished ; menuOptions
    fi
    if [ $OPTMENUOPTIONS -eq 16 ]; then
        echo ""
        echo "Reiniciando containers..."
        cd $HOME/.vr/integracao/vrgerenciadorifood/
        sudo docker compose -f docker-compose-gerenciadorifood.yml restart
        finished ; menuOptions
    fi
    if [ $OPTMENUOPTIONS -eq 17 ]; then
        echo ""
        echo "Parando containers..."
        cd $HOME/.vr/integracao/vrgerenciadorifood/
        docker compose -f docker-compose-gerenciadorifood.yml stop
        finished ; menuOptions
    fi
    if [ $OPTISLMENU -eq 18 ]; then
	    echo ""
        curl -X POST http://localhost:9031/VRGerenciadorIfood/auth/logout
        finished ; menuOptions
	fi
	if [ $OPTISLMENU -eq 19 ]; then
	    exit
	fi
	if [ $OPTISLMENU -ge 20 ]; then
	echo -e "\nOpcao incorreta, retornando ao menu principal" ; pause ; menuOptions
	fi
}

askSudo
menuOptions