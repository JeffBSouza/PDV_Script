#!/bin/bash

# sudo mkdir -p /vr >/dev/null 2>&1; sudo chmod 777 -R /vr >/dev/null 2>&1; sudo rm -rf /vr/script.sh >/dev/null 2>&1; sudo wget -c --no-check-certificate https://storage.googleapis.com/linux-pdv/Jeff/ifood.sh -O /vr/ifood.sh; sudo chmod +x /vr/ifood.sh >/dev/null 2>&1; /vr/ifood.sh

# Configurações
APP_DIR="$HOME/.vr/integracao/vrgerenciadorifood"
ENV_FILE="$APP_DIR/.env"
DOCKER_COMPOSE_FILE="$APP_DIR/docker-compose-gerenciadorifood.yml"
URL_GERENCIADORIFOOD="https://storage.googleapis.com/linux-pdv/Jeff/iFood_Files/VRGerenciadorIfood.zip"
DESTINO_TEMP="/tmp/vrgerenciadorifood"

pause() {
echo -e "Press any button to Exit or Continue..."
read -n 1 -s -r
}

checkRoot() {
if [ $UID -eq 0 ]; then
    echo -e "O script nao deve ser executado utilizando o usuario root.\nPor gentileza execute novamente e digite a senha somente quando solicitada."
    exit
else
    read -s -p "Digite a senha de root: " PASSWD
    TESTPASSWD=$(printf '%s\n' "$PASSWD" | sudo -S -p '' touch /root/.passtest 2>/dev/null; echo $?)
    if [ $TESTPASSWD -ne 0 ]; then
        clear ; echo -e "Senha digitada nao esta correta. O valor digitado foi: $PASSWD\nEncerrando script!\n"
        exit
    else
        printf '%s\n' "$PASSWD" | sudo -S -p '' -S rm -rf /root/.passtest
    fi
fi
}

finished() {
echo -e "✅ - PROCESSO ENCERRADO - ✅"
}

filepermission_create() {
local FILE="$1"
printf '%s\n' "$PASSWD" | sudo -S -p '' touch "$FILE" >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 "$FILE" >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' chown nobody:nogroup "$FILE" >/dev/null 2>&1
}

filepermission() {
local FILE="$1"
printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 "$FILE" >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' chown nobody:nogroup "$FILE" >/dev/null 2>&1
}

folderpermission_create() {
local FOLDER="$1"
printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 "$FOLDER" >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' chown nobody:nogroup "$FOLDER" >/dev/null 2>&1
}

pastas_Temp() {
printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $DESTINO_TEMP 2>/dev/null
printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $DESTINO_TEMP 2>/dev/null
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
    echo "[INFO] Criando pastas temporarias"
    pastas_Temp
    echo "[INFO] Download Arquivos"
    printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $URL_GERENCIADORIFOOD -O $DESTINO_TEMP/VRGerenciadorIfood.zip 2>/dev/null
	echo "[INFO] Extraindo Arquivos"
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
        echo -e "\n[ERRO] Falha no comando de extração unzip"
        exit 1
    elif [ ${#checkFile[@]} -eq 0 ]; then
        echo -e "\n[ERRO] Extração concluída mas pasta vazia - arquivo $DESTINO_TEMP/VRGerenciadorIfood.zip pode estar corrompido ou vazio"
        exit 1
    else
        echo -e "[OK] Arquivo extraído com sucesso - ${#checkFile[@]} arquivos em $APP_DIR"
    fi
}

# Função para validar e criar diretório
criar_diretorio() {
    echo ""
    echo "[INFO] Validando e criando diretorio: $APP_DIR"

    if [ ! -d "$APP_DIR" ]; then
        printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p "$APP_DIR"
        if [ $? -eq 0 ]; then
            printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 "$APP_DIR"
            echo "[INFO] Diretorio $APP_DIR criado com sucesso"
        else
            echo "[FALHA] Erro ao criar diretorio!"
            exit 1
        fi
    else
        echo "[INFO] Diretorio ja existe"
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
        echo "[FALHA] Erro: Todos os campos sao obrigatorios!"
        exit 1
    fi
}

# Função para criar/atualizar arquivo .env
criar_arquivo_env() {
    echo ""
    echo "[INFO] Criando/atualizando arquivo .env..."
    
printf '%s\n' "$PASSWD" | sudo -S -p '' tee "$ENV_FILE" > /dev/null << EOF
DATABASE_IP=$DATABASE_IP
DATABASE_PORTA=$DATABASE_PORTA
DATABASE_USUARIO=$DATABASE_USUARIO
DATABASE_SENHA=$DATABASE_SENHA
DATABASE_NOME=$DATABASE_NOME
EOF

    if [ $? -eq 0 ]; then
        echo "[INFO] Arquivo .env criado/atualizado com sucesso!"
        printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 600 "$ENV_FILE"
    else
        echo "[FALHA] Erro ao criar arquivo .env!"
        exit 1
    fi
}

# Função para atualizar docker-compose
atualizar_docker_compose() {
    echo "[INFO] Atualizando docker-compose com a versao $VERSAO..."
    
    # Verificar se o arquivo existe
    if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
        echo "[FALHA] Aviso: Arquivo docker-compose não encontrado em $DOCKER_COMPOSE_FILE"
        exit 1
    else
        # Atualizar a versão no arquivo existente
        printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i "s|vrsoftbr/vrgerenciadorifood:[^[:space:]]*|vrsoftbr/vrgerenciadorifood:$VERSAO|g" "$DOCKER_COMPOSE_FILE"
    fi
    
    if [ $? -eq 0 ]; then
        echo "[INFO] Docker-compose atualizado com sucesso!"
        # chmod 644 "$DOCKER_COMPOSE_FILE"
    else
        echo "[FALHA] Erro ao atualizar docker-compose!"
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
    echo ""
    echo "=== MENU ==="
    echo "1 - Instalar o VRGerenciadorIFood"
    echo "2 - Alterar Versao VRGerenciadorIFood"
    echo "3 - Alterar Configs Banco VR no .env"
    echo "4 - Iniciar container VRGrenciadorIfood"
    echo "5 - Reiniciar container VRGrenciadorIfood"
    echo "6 - Desativar o VRGerenciadorIFood"
    echo "99 - Sair"
    read -p "Escolha uma opcao: " OPTMENUOPTIONS
	if [ -z "$OPTMENUOPTIONS" ] || ! [[ "$OPTMENUOPTIONS" =~ ^[0-9]+$ ]]; then
		echo -e "\nErro: você deve escolher uma opcao valida." ; sleep 2 ; menuOptions
	fi
    if [ $OPTMENUOPTIONS -eq 1 ]; then
        config_iFood ; criar_Atalho_PortalPedidos ; finished ; pause ; exit
    fi
    if [ $OPTMENUOPTIONS -eq 2 ]; then
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
        atualizar_docker_compose ; finished ; pause ; exit
    fi
    if [ $OPTMENUOPTIONS -eq 3 ]; then
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
        finished ; pause ; exit
    fi
    if [ $OPTMENUOPTIONS -eq 4 ]; then
        echo ""
        echo "Iniciando containers..."
        cd $HOME/.vr/integracao/vrgerenciadorifood/
        docker compose -f docker-compose-gerenciadorifood.yml up -d
        finished ; exit
    fi
    if [ $OPTMENUOPTIONS -eq 5 ]; then
        echo ""
        echo "Reiniciando containers..."
        cd $HOME/.vr/integracao/vrgerenciadorifood/
        docker compose -f docker-compose-gerenciadorifood.yml restart
        finished ; exit
    fi
    if [ $OPTMENUOPTIONS -eq 6 ]; then
        echo ""
        echo "Parando containers..."
        cd $HOME/.vr/integracao/vrgerenciadorifood/
        docker compose -f docker-compose-gerenciadorifood.yml stop
        finished ; exit
    fi
    if [ $OPTMENUOPTIONS -eq 99 ]; then
        exit
    fi
    if [ $OPTMENUOPTIONS -ge 7 ]; then
        if [[ $OPTMENUOPTIONS -le 98 || $OPTMENUOPTIONS -ge 100 ]]; then
            echo -e "\nOpcao incorreta, retornando ao menu" ; sleep 1 ; menuOptions
        fi
    fi
}

# Executar função principal
checkRoot
menuOptions