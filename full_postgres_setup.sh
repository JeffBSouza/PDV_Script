#!/bin/bash

# sudo mkdir -p /vr >/dev/null 2>&1; sudo chmod 777 -R /vr >/dev/null 2>&1; sudo rm -rf /vr/script.sh >/dev/null 2>&1; sudo wget -c --no-check-certificate https://storage.googleapis.com/linux-pdv/Jeff/full_postgres_setup.sh -O /vr/script.sh; sudo chmod +x /vr/script.sh >/dev/null 2>&1; sudo /vr/script.sh

# release date: 22/09/2025 vrs 2.0

vrs=2.0

# Função para pausar o script em caso de erro
function pause_on_error() {
    if [ $? -ne 0 ]; then
        echo -e "\n[ERRO] - Um erro ocorreu. Pressione qualquer tecla para continuar..."
        read -n 1 -s
    fi
}

pause() {
echo -e "${WB2}Press any button to Exit or Continue...${End}"
read -n 1 -s -r
}

clearFiles() {
    sudo rm -rf /vr/util/*.txt >/dev/null 2>&1
}

checkRoot() {
    if [ "$EUID" -ne 0 ]; then
        echo "❌ [FALHA] Este script precisa ser executado com sudo. [sudo /vr/script.sh]"
        exit 1
    fi
}

filepermission_create() {
local FILE="$1"
sudo touch "$FILE" >/dev/null 2>&1
sudo chmod 777 "$FILE" >/dev/null 2>&1
}

createRegisterLog() {
local APPNAME="$1"
sudo mkdir -p -m 777 /vr/util >/dev/null 2>&1
sudo touch /vr/util/$APPNAME.txt >/dev/null 2>&1
sudo chmod 777 /vr/util/$APPNAME.txt >/dev/null 2>&1

date=$(date '+%Y-%m-%d_%H:%M:%S')
echo $APPNAME - $date >> /vr/util/$APPNAME.txt
}

dateFull_Info() {
date '+%Y-%m-%d_%H:%M:%S'
}

check() {
    if [ ! -e "/vr/util/$1.txt" ]; then
        echo -e "\n[INFO] - Falha no processo $1"
        echo -e "[INFO] - Deseja continuar? (S/N)"
        read -n 1 -s
        if [ "$REPLY" == "S" ] || [ "$REPLY" == "s" ]; then
            return 1
        else
            exit
        fi
    fi
    return 0
}

warnningInteraction() {
    echo -e "\n** ℹ️ [ATENCAO - INTERACAO NECESSARIA]ℹ️ **\n-- [INFO] A atualizacao/instalacao ira iniciar, existem momentos que sera necessario a sua interacao \nCaso seja necessario entrar com a senha SUDO (senha da maquina) ou um S/n\n Para selecao de opcoes voce pode usar o TAB (para navegar) e o ENTER (para confirmar)"
	echo -e "-- [INFO] Entao se atente a tela durante a atualizacao\n"
	pause
}

check_repos() {
# Verifica se o repositório universe está habilitado
if ! grep -q "^[^#].*universe" /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null; then
    echo "[INFO] - Habilitando repositório universe"
    sudo add-apt-repository universe -y
fi

# Verifica se o repositório multiverse está habilitado
if ! grep -q "^[^#].*multiverse" /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null; then
    echo "[INFO] - Habilitando repositório multiverse"
    sudo add-apt-repository multiverse -y
fi

# Verifica se a arquitetura i386 já está adicionada
if ! dpkg --print-foreign-architectures | grep -qw i386; then
    echo "[INFO] - Adicionando arquitetura i386"
    sudo dpkg --add-architecture i386
fi
}

comandosPreparacao() {
    sudo dpkg --configure -a
    sudo apt-get --fix-broken install
    sudo apt-get -f -y install
}

# wrapper para dpkg
safe_dpkg() {
  kill_dpkg_lock
  sudo dpkg "$@" || pause_on_error
}

# wrapper para apt
safe_apt() {
  kill_dpkg_lock
  sudo apt "$@" || pause_on_error
}

# kill_dpkg_lock: encontra processos que mantêm locks do dpkg/apt e mata-os forçadamente.
# Uso: apenas chame kill_dpkg_lock
# Requisitos: sudo (para inspecionar e matar processos que pertencem a root)
kill_dpkg_lock() {
  local locks=( \
    /var/lib/dpkg/lock-frontend \
    /var/lib/dpkg/lock \
    /var/lib/apt/lists/lock \
    /var/cache/apt/archives/lock \
  )
  local raw_pids=()
  local pid_list=()
  local me_pid=$$
  local my_ppid=$PPID

  # Recolher PIDs via fuser/lsof para cada arquivo de lock existente
  for lock in "${locks[@]}"; do
    if [ -e "$lock" ]; then
      # fuser retorna pids separados por espaço (se disponível)
      if sudo command -v fuser >/dev/null 2>&1; then
        local f=$(sudo fuser "$lock" 2>/dev/null || true)
        for p in $f; do
          raw_pids+=("$p")
        done
      fi

      # lsof (mais verboso) — pega segunda coluna como PID
      if sudo command -v lsof >/dev/null 2>&1; then
        while IFS= read -r line; do
          # linha: COMMAND PID USER ...
          pid=$(echo "$line" | awk '{print $2}')
          # só adiciona se for número
          if [[ $pid =~ ^[0-9]+$ ]]; then
            raw_pids+=("$pid")
          fi
        done < <(sudo lsof "$lock" 2>/dev/null || true)
      fi
    fi
  done

  # Também detecta processos cujo nome contém apt, apt-get, dpkg, aptitude, unattended
  while IFS= read -r pid comm; do
    if [[ "$comm" =~ apt(|-get)|dpkg|aptitude|unattended- ]]; then
      raw_pids+=("$pid")
    fi
  done < <(ps -eo pid=,comm=)

  # normalizar: remover vazios, remover nós duplicados, e evitar matar PID 1 / shell atual / parent
  for p in "${raw_pids[@]}"; do
    if [[ -z "$p" ]]; then
      continue
    fi
    if ! [[ $p =~ ^[0-9]+$ ]]; then
      continue
    fi
    # não matar PID 1 (init/systemd) nem o próprio shell ou seu pai
    if [ "$p" -eq 1 ] || [ "$p" -eq "$me_pid" ] || [ "$p" -eq "$my_ppid" ]; then
      continue
    fi
    pid_list+=("$p")
  done

  # deduplicação
  if [ ${#pid_list[@]} -eq 0 ]; then
    echo "[INFO] Nenhum processo que prenda locks do dpkg/apt foi encontrado - [ $(dateFull_Info) ]"
    return 0
  fi

  IFS=$'\n' read -r -d '' -a pid_list_unique < <(printf '%s\n' "${pid_list[@]}" | sort -n -u && printf '\0')
  echo "[AVISO] encontrados PIDs que parecem segurar locks do dpkg/apt: ${pid_list_unique[*]} - [ $(dateFull_Info) ]"

  # matar cada PID com sudo kill -9
  for p in "${pid_list_unique[@]}"; do
    if ps -p "$p" >/dev/null 2>&1; then
      echo "matando PID $p ..."
      sudo kill -9 "$p" || {
        echo "[AVISO] Falha ao matar PID $p (talvez já tenha terminado). - [ $(dateFull_Info) ]"
      }
    else
      echo "[INFO] PID $p já não existe. - [ $(dateFull_Info) ]"
    fi
  done

  # aguardar brevemente e tentar reparar dpkg
  sleep 1
  echo "[INFO] Executando reparo: sudo dpkg --configure -a && sudo apt-get install -f -y - [ $(dateFull_Info) ]"
  sudo dpkg --configure -a || echo "[INFO] dpkg --configure -a falhou (verifique manualmente). - [ $(dateFull_Info) ]"
  sudo apt-get install -f -y || echo "[INFO] apt-get install -f falhou (verifique manualmente). - [ $(dateFull_Info) ]"

  echo "[INFO] Concluído. - [ $(dateFull_Info) ]"
  return 0
}

installFolders() {
sudo rm -rf /vr/util/installFolders.txt >/dev/null 2>&1

echo -e "\n[INFO] - Criando diretórios /vr e /vr/exec... - [ $(dateFull_Info) ]"
sudo mkdir /vr >/dev/null 2>&1
sudo mkdir /vr/util >/dev/null 2>&1
sudo mkdir /vr/exec >/dev/null 2>&1
sudo mkdir /vr/exec/img >/dev/null 2>&1
sudo mkdir /vr/isl_LightClient_Folder >/dev/null 2>&1
sudo mkdir /vr/isl_LightClient_Folder/img >/dev/null 2>&1
sudo mkdir /vr/PacotesAtualizar >/dev/null 2>&1
sudo chmod 777 -R /vr >/dev/null 2>&1
sudo chown nobody:nogroup -R /vr >/dev/null 2>&1

createRegisterLog "installFolders"
}

islVR() {
echo -e "\n[INFO] - Validando ISL Light Client - [ $(dateFull_Info) ]"

URLISLONELIN_LIGHTCLIENT="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Linux/ISL_Light_ClientVR.zip"
appsIco="https://storage.googleapis.com/linux-pdv/Jeff/LinuxFiles/img.zip"
local DESTINO=/vr/isl_LightClient_Folder
local FILE=$DESTINO/ISL_Light_Client

if [ ! -e "$FILE" ]; then
    echo -e "\nInstalacao LightClient VR - [ $(dateFull_Info) ]"

    islVRDependencias

    sudo rm -rf $DESTINO 2>/dev/null
	sudo rm -rf $FILE 2>/dev/null
    sudo mkdir "$DESTINO"  >/dev/null 2>&1
    sudo mkdir "$DESTINO/img"  >/dev/null 2>&1
    sudo chmod 777 -R "$DESTINO" >/dev/null 2>&1
    sudo chown nobody:nogroup -R "$DESTINO" >/dev/null 2>&1

    sudo wget -c --no-check-certificate $URLISLONELIN_LIGHTCLIENT -O $DESTINO/ISL_Light_Client.zip 2>/dev/null
	sudo unzip -q -o $DESTINO/ISL_Light_Client.zip -d $DESTINO 2>/dev/null
	sudo rm -rf $DESTINO/ISL_Light_Client.zip 2>/dev/null
    # sudo mv $DESTINO/* $DESTINO/ISL_Light_Client >/dev/null 2>&1
	shopt -s nullglob
    local checkFile=("$DESTINO"/*)
	if [ ${#checkFile[@]} -eq 0 ]; then
        echo -e "\n[ERRO] Falha na extração ou arquivo estava vazio, arquivo em $DESTINO/ISL_Light_Client.zip estava vazio. - [ $(dateFull_Info) ]"
        pause
    fi
	shopt -u nullglob
	sudo chmod 777 -R $DESTINO 2>/dev/null
	sudo chown "nobody:nogroup" -R $DESTINO 2>/dev/null
    
    echo -e "\n[INFO] - Instalando dependencias ISL Light Client... - [ $(dateFull_Info) ]"
    sudo apt update
    comandosPreparacao
    sudo apt-get -y install libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-xkb1 libxkbcommon-x11-0

	if [ ! -e "$DESTINO/isl_online.png" ]; then
		echo -e "\n[INFO] Ajuste atalho ISL_LightClient. . . - [ $(dateFull_Info) ]"
		sudo wget -c --no-check-certificate $appsIco -O $DESTINO/img.zip 2>/dev/null
		sudo unzip -q -o $DESTINO/img.zip -d $DESTINO/img 2>/dev/null
		sudo rm -rf $DESTINO/img.zip 2>/dev/null
		sudo chmod 777 -R $DESTINO/* 2>/dev/null
		sudo chown "nobody:nogroup" -R $DESTINO/* 2>/dev/null
	fi

    filepermission_create "$DESTINO/run_light_client.sh" >/dev/null 2>&1
    filepermission_create "$DESTINO/ISL_Light.desktop" >/dev/null 2>&1

    cat << EOF > "$DESTINO/run_light_client.sh" 2>/dev/null
#!/bin/bash
cd "$DESTINO" ; ./ISL_Light_Client
EOF

    cat << EOF > "$DESTINO/ISL_Light.desktop" 2>/dev/null
[Desktop Entry]
Encoding=UTF-8
Name=ISL_LightClient
Exec=$DESTINO/run_light_client.sh
Type=Application
Categories=Application;Network;
Icon=$DESTINO/img/isl_online.png
EOF

    sudo chmod +x "$DESTINO/ISL_Light.desktop" >/dev/null 2>&1
    sudo chmod 644 "$DESTINO/ISL_Light.desktop" >/dev/null 2>&1
fi

createRegisterLog "ISL_LightClient"
}

islVRDependencias() {
warnningInteraction
comandosPreparacao
sudo apt-get -y install libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-xkb1 libxkbcommon-x11-0
sudo apt-get -yq clean
}

postgresRemove() {
sudo rm -rf /vr/util/postgresRemove.txt >/dev/null 2>&1
echo -e "\n[INFO] - Iniciando a remoção de instalações existentes do PostgreSQL... - [ $(dateFull_Info) ]"

# Detectar o gerenciador de pacotes
if command -v rpm &> /dev/null; then
    PACKAGE_MANAGER="rpm"
    echo -e "\n[INFO] - Gerenciador de pacotes detectado: RPM - [ $(dateFull_Info) ]"
elif command -v dpkg &> /dev/null; then
    PACKAGE_MANAGER="dpkg"
    echo -e "\n[INFO] - Gerenciador de pacotes detectado: DPKG (Debian/Ubuntu) - [ $(dateFull_Info) ]"
else
    echo -e "\n[INFO] - Nenhum gerenciador de pacotes suportado (RPM ou DPKG) encontrado. Pulando a remoção de pacotes. - [ $(dateFull_Info) ]"
    PACKAGE_MANAGER=""
fi

# Verificar e remover pacotes PostgreSQL
if [ -n "$PACKAGE_MANAGER" ]; then
    echo -e "\n[INFO] - Verificando pacotes PostgreSQL instalados... - [ $(dateFull_Info) ]"
    INSTALLED_PACKAGES=""

    warnningInteraction
    comandosPreparacao

    if [ "$PACKAGE_MANAGER" == "rpm" ]; then
        INSTALLED_PACKAGES=$(rpm -qa | grep postgres)
    elif [ "$PACKAGE_MANAGER" == "dpkg" ]; then
        INSTALLED_PACKAGES=$(dpkg -l | grep postgresql | awk '{print $2}')
    fi

    if [ -z "$INSTALLED_PACKAGES" ]; then
        echo -e "\n[INFO] - Nenhum pacote PostgreSQL encontrado para remoção. - [ $(dateFull_Info) ]"
    else
        echo ""
        echo -e "\n[INFO] - POSTGRES JA INSTALADO - [ $(dateFull_Info) ]"
        echo -e "\n[INFO] - Aperte ENTER para prosseguir com sua remocao e instalacao do PostgreSQL 14"
        read -n 1 -s -r

        echo -e "\n[INFO] - Pacotes encontrados:"
        comandosPreparacao
        echo -e "$INSTALLED_PACKAGES"
        for pkg in $INSTALLED_PACKAGES; do
            echo -e "\n[INFO] - Removendo pacote: $pkg"
            if [ "$PACKAGE_MANAGER" == "rpm" ]; then
                sudo rpm -e "$pkg" --nodeps || pause_on_error
            elif [ "$PACKAGE_MANAGER" == "dpkg" ]; then
                sudo apt-get purge -y "$pkg" || pause_on_error
            fi
        done
        echo -e "\n[INFO] - Remoção de pacotes concluída. - [ $(dateFull_Info) ]"
    fi

    # Remover diretórios de dados
    echo -e "\n[INFO] - Removendo diretórios de dados do PostgreSQL... - [ $(dateFull_Info) ]"
    if [ "$PACKAGE_MANAGER" == "rpm" ]; then
        sudo rm -rf /usr/pgsql-* || pause_on_error
        sudo rm -rf /var/lib/pgsql || pause_on_error
    elif [ "$PACKAGE_MANAGER" == "dpkg" ]; then
        sudo rm -rf /etc/postgresql/ || pause_on_error
        sudo rm -rf /var/lib/postgresql/ || pause_on_error
        sudo rm -rf /var/log/postgresql/ || pause_on_error
    fi
    echo -e "\n[INFO] - Remoção de diretórios concluída."
else
    echo -e "\n[INFO] - Pulando a remoção do PostgreSQL devido à falta de gerenciador de pacotes suportado."
fi

echo -e "\n[INFO] - Limpeza do PostgreSQL finalizada. - [ $(dateFull_Info) ]"

echo -e "\n--------------------------------------------------\n"
createRegisterLog "postgresRemove"
}

postgresInstall() {
sudo rm -rf /vr/util/postgresInstall.txt >/dev/null 2>&1

# Script de Instalacao do PostgreSQL 14
echo -e "\n[INFO] - Iniciando a Instalacao do PostgreSQL 14 no Ubuntu... - [ $(dateFull_Info) ]"

# Atualizar a lista de pacotes
echo -e "\n[INFO] - Atualizando a lista de pacotes... - [ $(dateFull_Info) ]"

warnningInteraction
sudo apt-get update || pause_on_error

# Instalar dependências necessárias
echo -e "\n[INFO] - Instalando dependências... - [ $(dateFull_Info) ]"
comandosPreparacao
sudo apt-get install -y curl apt-transport-https wget || pause_on_error

# Adicionar a chave GPG do PostgreSQL
echo -e "\n[INFO] - Adicionando a chave GPG do PostgreSQL..."
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg --yes || pause_on_error

# Adicionar o repositório do PostgreSQL
echo -e "\n[INFO] - Adicionando o repositório do PostgreSQL..."
echo -e "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list > /dev/null || pause_on_error

# Atualizar a lista de pacotes novamente para incluir o novo repositório
echo -e "\n[INFO] - Atualizando a lista de pacotes novamente... - [ $(dateFull_Info) ]"
sudo apt-get update || pause_on_error

# Instalar PostgreSQL 14 e contrib
echo -e "\n[INFO] - Instalando PostgreSQL 14 e pacotes adicionais... - [ $(dateFull_Info) ]"
sudo apt update
comandosPreparacao
sudo apt-get install -y postgresql-14 postgresql-client-14 postgresql-contrib-14 || pause_on_error

# Iniciar o serviço PostgreSQL e aguardar
echo -e "\n[INFO] - Iniciando o serviço PostgreSQL..."
sudo systemctl start postgresql || pause_on_error
sudo systemctl enable postgresql || pause_on_error

# Aguardar o PostgreSQL estar pronto para aceitar conexões
echo -e "\n[INFO] - Aguardando o PostgreSQL estar pronto... - [ $(dateFull_Info) ]"
until sudo -u postgres psql -c "select 1;" &> /dev/null; do
    sleep 1
done

createRegisterLog "postgresInstall"
}

postgresRestore() {
sudo rm -rf /vr/util/postgresRestore.txt >/dev/null 2>&1

echo -e "\n[INFO] - Configurando o usuário postgres... - [ $(dateFull_Info) ]"
sudo -u postgres bash -c "cd /tmp && psql -c \"ALTER USER postgres WITH PASSWORD 'postgres';\"" || pause_on_error

echo -e "\n[INFO] - Criando o banco de dados \'vr\'... - [ $(dateFull_Info) ]"
sudo -u postgres bash -c "cd /tmp && psql -c \"CREATE DATABASE vr;\"" || pause_on_error

echo -e "\n[INFO] - Baixando o arquivo de backup Banco_Multiloja.backup... - [ $(dateFull_Info) ]"
BACKUP_URL="https://storage.googleapis.com/linux-pdv/Jeff/LinuxFiles/Ubuntu_VR/Banco_Multiloja.backup"
BACKUP_FILE="/tmp/Banco_Multiloja.backup"
sudo wget -O "$BACKUP_FILE" "$BACKUP_URL" || pause_on_error
if [ ! -e "$BACKUP_FILE" ]; then
    echo -e "\n[ERROR] - O arquivo de backup 'Banco_Multiloja.backup' não foi baixado corretamente. - [ $(dateFull_Info) ] \n"
    pause_on_error
    exit
fi

echo -e "\n[INFO] - Realizando o restore do banco de dados 'vr'... - [ $(dateFull_Info) ]"
sudo -u postgres bash -c "cd /tmp && pg_restore -d vr '$BACKUP_FILE'"
# sudo -H -u postgres pg_restore -d vr "$BACKUP_FILE" || pause_on_error
sudo rm -rf "$BACKUP_FILE" >/dev/null 2>&1

createRegisterLog "postgresRestore"
}

postgresRestore_Specific() {
sudo rm -rf /vr/util/postgresRestore_Specific.txt >/dev/null 2>&1

if [ -z "${1// }" ]; then
    echo -e "\n[ERROR] - Nome do banco de dados não informado - [ $(dateFull_Info) ]"
    pause_on_error ; menuOptions
fi

local DATABASENAME="$1"
local BACKUPPATH="$2"

    # Se o arquivo não existir, tentar completar com extensões conhecidas
    if [ ! -e "$BACKUPPATH" ]; then
        local found=""
        for ext in .bk .backup .dump; do
            if [ -e "${BACKUPPATH}${ext}" ]; then
                BACKUPPATH="${BACKUPPATH}${ext}"
                found="yes"
                break
            fi
        done

        if [ -z "$found" ]; then
            echo -e "\n[ERROR] - O arquivo de backup '$BACKUPPATH' nao foi encontrado. - [ $(dateFull_Info) ] \n"
            pause_on_error ; menuOptions
        fi
    fi

echo -e "\n[INFO] - Criando o banco de dados '$DATABASENAME' ... - [ $(dateFull_Info) ]"
sudo -u postgres bash -c "cd /tmp && psql -c \"CREATE DATABASE $DATABASENAME;\"" || pause_on_error

echo -e "\n[INFO] - Realizando o restore do banco de dados '$DATABASENAME'... - [ $(dateFull_Info) ]"
sudo -u postgres bash -c "cd /tmp && pg_restore -d $DATABASENAME '$BACKUPPATH'"
# sudo -H -u postgres pg_restore -d vr "$BACKUP_FILE" || pause_on_error

createRegisterLog "postgresRestore_Specific"
}

postgresConfig() {
sudo rm -rf /vr/util/postgresConfig.txt >/dev/null 2>&1

echo -e "\n[INFO] - Baixando o arquivo vr.properties para /vr... - [ $(dateFull_Info) ]"
VR_PROPERTIES_URL="https://storage.googleapis.com/linux-pdv/Jeff/LinuxFiles/Ubuntu_VR/vr.properties"
VR_PROPERTIES_FILE="/vr/vr.properties"
sudo wget -O "$VR_PROPERTIES_FILE" "$VR_PROPERTIES_URL" || pause_on_error

echo -e "\n[INFO] - Configurando pg_hba.conf... - [ $(dateFull_Info) ]"
PG_HBA_URL="https://storage.googleapis.com/linux-pdv/Jeff/LinuxFiles/Ubuntu_VR/pg_hba.conf"
PG_HBA_FILE="/tmp/pg_hba.conf"
sudo wget -O "$PG_HBA_FILE" "$PG_HBA_URL" || pause_on_error
sudo mv "/etc/postgresql/14/main/pg_hba.conf" "/etc/postgresql/14/main/pg_hba_original.conf" || pause_on_error
sudo cp "$PG_HBA_FILE" "/etc/postgresql/14/main/" || pause_on_error

echo -e "\n[INFO] - Configurando postgresql.conf... - [ $(dateFull_Info) ]"
POSTGRESQL_URL="https://storage.googleapis.com/linux-pdv/Jeff/LinuxFiles/Ubuntu_VR/postgresql.conf"
POSTGRESQL_FILE="/tmp/postgresql.conf"
sudo wget -O "$POSTGRESQL_FILE" "$POSTGRESQL_URL" || pause_on_error
sudo mv "/etc/postgresql/14/main/postgresql.conf" "/etc/postgresql/14/main/postgresql_original.conf" || pause_on_error
sudo cp "$POSTGRESQL_FILE" "/etc/postgresql/14/main/" || pause_on_error

echo -e "\n[INFO] - Reiniciando o serviço PostgreSQL para aplicar as novas configurações... - [ $(dateFull_Info) ]"
sudo systemctl restart postgresql || pause_on_error

createRegisterLog "postgresConfig"
}

installPDV() {
    local TMP_LIB="/tmp/pdv_libs"
    local libslinux=vrdefault

    echo ""
    echo "======================================================"
    echo ""
    echo "** [INFO] - Instalando PDV ** - [ $(dateFull_Info) ]"
    echo -e "\n[INFO] - Criando diretórios /pdv... - [ $(dateFull_Info) ]"
    sudo mkdir /pdv/ >/dev/null 2>&1
    sudo mkdir /pdv/arquivoscupom >/dev/null 2>&1
    sudo mkdir /pdv/cfe >/dev/null 2>&1
    sudo mkdir /pdv/database >/dev/null 2>&1
    sudo mkdir /pdv/driver >/dev/null 2>&1
    sudo mkdir /pdv/exec >/dev/null 2>&1
    sudo mkdir /pdv/img >/dev/null 2>&1
    sudo mkdir /pdv/log >/dev/null 2>&1
    sudo mkdir /pdv/logpdv >/dev/null 2>&1
    sudo mkdir /pdv/nfce >/dev/null 2>&1
    sudo mkdir /pdv/sat >/dev/null 2>&1
    sudo mkdir /pdv/som >/dev/null 2>&1
    sudo mkdir /pdv/util >/dev/null 2>&1
    
    sudo chmod 777 -R /pdv >/dev/null 2>&1
    sudo chmod 777 -R /vr >/dev/null 2>&1
    sudo chown nobody:nogroup -R /pdv >/dev/null 2>&1

    if [ ! -e "/usr/lib/CliSiTef.ini" ]; then
    echo -e "\n[INFO] - Realizando Download e instalacao do CliSiTef.ini... - [ $(dateFull_Info) ]"
	    sudo mkdir -p -m 777 $clisitefinifolder 2>/dev/null
		sudo wget -c --no-check-certificate $URLCLISITEFINI -O /pdv/util/CliSiTef.ini 2>/dev/null
        sudo mv /pdv/util/CliSiTef.ini /usr/lib/CliSiTef.ini 2>/dev/null
        sudo chmod 777 /usr/lib/CliSiTef.ini 2>/dev/null
	fi

	echo -e "\n[INFO] - Realizando Download e instalacao Libs PDV... - [ $(dateFull_Info) ]"
    sudo rm -rf $TMP_LIB/libs.zip 2>/dev/null 
    sudo mkdir -p -m 777 $TMP_LIB 2>/dev/null
	sudo wget -c --no-check-certificate "https://storage.googleapis.com/linux-pdv/Jeff/lib.zip" -O $TMP_LIB/libs.zip 2>/dev/null 
		if [ $? -ne 0 ] || [ ! -s $TMP_LIB/libs.zip ]; then
			echo "" ; echo -e "Erro ao fazer download de Libs pdv" ; pause ; menuOptions
		fi
    echo -e "\n[INFO] - Extraindo Libs PDV... - [ $(dateFull_Info) ]"
	sudo unzip -q -o $TMP_LIB/libs.zip -d $TMP_LIB 2>/dev/null
		if [ $? -ne 0 ]; then
		    echo "" ; echo -e "Erro ao Extrair Libs" ; pause ; menuOptions
        else
            sudo chmod -R 777 $TMP_LIB/* 2>/dev/null
            sudo chown "$USER:firebird" -R $TMP_LIB/* 2>/dev/null
            sudo rm -f $TMP_LIB/libs.zip 2>/dev/null
		fi
	
	fileslibssitef=("$TMP_LIB/Cheque.txt" 
	"$TMP_LIB/Leiame.txt" 
	"$TMP_LIB/lgpl-2.1.txt" 
	"$TMP_LIB/libclisitef.so" 
	"$TMP_LIB/libcurl_LICENSE.txt" 
	"$TMP_LIB/libcurl32.so" 
	"$TMP_LIB/libemv.so" 
	"$TMP_LIB/libpng_LICENSE.txt" 
	"$TMP_LIB/libqrencode_LICENSE.txt" 
	"$TMP_LIB/libqrencode32.so" 
	"$TMP_LIB/rechargeRPC.so" 
	"$TMP_LIB/RELEASE.TXT")
	for filelibssitef_delete in "${fileslibssitef[@]}"; do
	if [ -e "$filelibssitef_delete" ]; then
		sudo rm -rf $filelibssitef_delete >/dev/null 2>&1
	fi
	done

    echo -e "\n[INFO] - Copiando arquivos /usr/lib... - [ $(dateFull_Info) ]"
	sudo rm -rf $TMP_LIB/$libslinux/CliSiTef.ini 2>/dev/null
    sudo cp --remove-destination -p $TMP_LIB/$libslinux/* /usr/lib 2>/dev/null

    if [ ! -e "/vr/vr.properties" ]; then
        echo -e "\n[INFO] - Instalando vr.properties... - [ $(dateFull_Info) ]"
        sudo wget -c --no-check-certificate $propertieslinux -O /vr/vr.properties 2>/dev/null
    fi

    javaPdvInstall
    check "javaPdvInstall" ; firebirdPDVInstall
    pdv_Shortcut
}

pdv_Shortcut() {
sudo rm -rf /vr/util/pdv_Shortcut.txt >/dev/null 2>&1

echo -e "\n[INFO] - Criando atalhos PDV - [ $(dateFull_Info) ]"
if [ ! -e "/vr/exec/img/VRPdv.png" ]; then
    appsIco="https://storage.googleapis.com/linux-pdv/Jeff/LinuxFiles/img.zip"
    sudo wget -c --no-check-certificate $appsIco -O /tmp/img.zip || pause_on_error
    sudo unzip -q -o /tmp/img.zip -d /vr/exec/img 2>/dev/null || pause_on_error 
fi

local icoFile="/vr/exec/img/VRPdv.png"
sudo rm -rf /usr/share/applications/VRPdv.desktop >/dev/null 2>&1
sudo tee /usr/share/applications/VRPdv.desktop >/dev/null <<EOF
[Desktop Entry]
Name=VRPdv
Comment=Aplicativo de PDV
Exec=/usr/lib/jvm/java-8-openjdk-i386/jre/bin/java -jar /pdv/exec/VRPdv.jar
Icon=$icoFile
Type=Application
Path=/pdv/exec
Terminal=false
Categories=Utility;Application;
EOF
sudo chmod +x /usr/share/applications/VRPdv.desktop >/dev/null 2>&1
sudo chmod 777 /usr/share/applications/VRPdv.desktop >/dev/null 2>&1

sudo rm -rf /usr/share/applications/VRPdv_Config.desktop >/dev/null 2>&1
sudo tee /usr/share/applications/VRPdv_Config.desktop >/dev/null <<EOF
[Desktop Entry]
Name=VRPdv_Config
Comment=Aplicativo de PDV
Exec=/usr/lib/jvm/java-8-openjdk-i386/jre/bin/java -jar /pdv/exec/VRPdv.jar -config
Icon=$icoFile
Type=Application
Path=/pdv/exec
Terminal=false
Categories=Utility;Application;
EOF
sudo chmod +x /usr/share/applications/VRPdv_Config.desktop >/dev/null 2>&1
sudo chmod 777 /usr/share/applications/VRPdv_Config.desktop >/dev/null 2>&1

if [ -e "/usr/share/applications/VRPdv.desktop" ]; then
    createRegisterLog "pdv_Shortcut"
fi

}

javaPdvInstall() {
sudo rm -rf /vr/util/javaPdvInstall.txt >/dev/null 2>&1

	local javaFile="/usr/lib/jvm/java-8-openjdk-i386/jre/bin/java"
	if [ ! -e "$javaFile" ]; then
        echo -e "\n[INFO] - Instalando java8 i386 (x86)... - [ $(dateFull_Info) ]"
        echo -e "\n[INFO] - Executando preparacao de pacotes... - [ $(dateFull_Info) ]"
        check_repos
        sudo apt update
        comandosPreparacao
        echo -e "\n[INFO] - Instalando java pdv... - [ $(dateFull_Info) ]"
		sudo apt -y install openjdk-8-jre:i386
        if [ -e "$javaFile" ]; then
            createRegisterLog "javaPdvInstall"
        else
            echo -e "\n[INFO] - Erro ao instalar Java8 i386 (x86)... - [ $(dateFull_Info) ]" ; pause
        fi
    else
        echo -e "\n[INFO] - Java8 i386 (x86) PDV ja esta instalado... - [ $(dateFull_Info) ]"
        createRegisterLog "javaPdvInstall"
	fi
}

firebirdPDVInstall() {
sudo rm -rf /vr/util/firebirdPDVInstall.txt >/dev/null 2>&1

firebirdInstallFolder="/tmp/firebird_Install/"
sudo rm -rf $firebirdInstallFolder >/dev/null 2>&1
sudo mkdir -m 777 $firebirdInstallFolder >/dev/null 2>&1

echo -e "\n[INFO] - InstallReinstall - 2.5.9.27139-0.i686 Firebird ... - [ $(dateFull_Info) ]"

echo -e "Download Firebird - [ $(dateFull_Info) ]"
sudo wget --no-check-certificate "https://storage.googleapis.com/linux-pdv/Jeff/LinuxFiles/firebird-2.5.zip" -O $firebirdInstallFolder/firebird-2.5.zip >/dev/null 2>&1
    if [ $? -ne 0 ] || [ ! -s $firebirdInstallFolder/firebird-2.5.zip ]; then
		echo "" ; echo -e "${R1}Erro Realizar Download Firebird${End}" ; pause ; menuOptions
	fi
echo -e "\n${G1}Extraindo Firebird${End}"
sudo unzip -q -o $firebirdInstallFolder/firebird-2.5.zip -d $firebirdInstallFolder
	if [ $? -ne 0 ]; then
		echo "" ; echo -e "${R1}Erro Extrair Firebird${End}" ; pause ; menuOptions
    else
        sudo rm -rf $firebirdInstallFolder/firebird-2.5.zip >/dev/null 2>&1
   	fi

sudo chmod +x $firebirdInstallFolder/firebird-2.5/FirebirdSS-2.5.9.27139-0.i686/install.sh >/dev/null 2>&1
sudo chmod +x -R $firebirdInstallFolder/firebird-2.5/FirebirdSS-2.5.9.27139-0.i686/* >/dev/null 2>&1

echo -e "\n[INFO] - Instalando pacotes e dependencias . . . - [ $(dateFull_Info) ]"
check_repos
sudo apt update
comandosPreparacao
sudo dpkg --add-architecture i386
sudo apt install libncurses6:i386 libtinfo6:i386
sudo ln -s /lib/i386-linux-gnu/libncurses.so.6 /lib/i386-linux-gnu/libncurses.so.5
sudo ln -s /lib/i386-linux-gnu/libtinfo.so.6   /lib/i386-linux-gnu/libtinfo.so.5
sudo ln -s /lib/x86_64-linux-gnu/libncurses.so.6 /lib/x86_64-linux-gnu/libncurses.so.5
sudo apt -y install xinetd
sudo apt-get -y install libncurses5:i386 libtommath1 libstdc++5 lib32stdc++6 libncurses5
firebirdRemover

if [ -e "$firebirdInstallFolder/firebird-2.5/FirebirdSS-2.5.9.27139-0.i686/" ]; then
    echo -e "\n[INFO] - Instalando Firebird . . .Aguarde . . . - [ $(dateFull_Info) ]"
    cd $firebirdInstallFolder/firebird-2.5/FirebirdSS-2.5.9.27139-0.i686/
    sudo ./install.sh
else
    echo -e "\n[INFO] - FALHA ACESSAR PASTA DE INSTALACAO DO FIREBIRD - [ $(dateFull_Info) ]"
    pause ; menuOptions
fi

local current_date=$(date +%Y-%m-%d)
if [ -d "/opt/firebird" ]; then
	# Obter a data de modificação do diretório /opt/firebird no formato YYYY-MM-DD
	firebird_date=$(stat -c %y /opt/firebird 2>/dev/null | cut -d ' ' -f 1)
	# Comparar a data do diretório com a data atual
	if [ "$firebird_date" == "$current_date" ]; then
		echo -e "\nAplicando permissoes Firebird . . .Aguarde . . . - [ $(dateFull_Info) ]"
		permissioesFirebird
        createRegisterLog "firebirdPDVInstall"
	fi
else
	echo -e "\n[INFO] - FALHA NA INSTALL/REINSTALL DO FIREBIRD - [ $(dateFull_Info) ]" ; pause
fi
}

firebirdRemover() {
	echo -e "\n[INFO] Removendo Firebird...Aguarde... - [ $(dateFull_Info) ]"
	
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

installJava() {
sudo rm -rf /vr/util/installJava.txt >/dev/null 2>&1

echo -e "\n[INFO] - Instalando Java - [ $(dateFull_Info) ]"
sudo apt update
sudo apt-get install ttf-mscorefonts-installer
# sudo apt install -y openjdk-8-jdk

if [ -d "/usr/lib/jvm/jdk1.8.0_202" ]; then
    sudo rm -rf /usr/lib/jvm/jdk1.8.0_202 >/dev/null 2>&1
fi

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
sudo update-alternatives --set java /usr/lib/jvm/jdk1.8.0_202/bin/java
if [ -e "/usr/lib/jvm/jdk1.8.0_202/bin/java" ]; then
    createRegisterLog "installJava"
fi
}

installApps() {
  echo -e "\n[INFO] - Instalando Dbeaver - [ $(dateFull_Info) ]"
  wget -c --no-check-certificate https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb -O /tmp/dbeaver-ce_latest_amd64.deb
  safe_dpkg -i /tmp/dbeaver-ce_latest_amd64.deb
  sudo rm -rf "/tmp/dbeaver-ce_latest_amd64.deb" >/dev/null 2>&1

  echo -e "\n[INFO] - Instalando LibreOffice - [ $(dateFull_Info) ]"
  safe_apt update -y
  safe_apt install -y libreoffice
  safe_apt install -y libreoffice-l10n-pt-br

  echo -e "\n[INFO] - Instalando Gedit - [ $(dateFull_Info) ]"
  safe_apt install -y gedit

  echo -e "\n[INFO] - Instalando Unrar - [ $(dateFull_Info) ]"
  safe_apt install -y unrar

  createRegisterLog "installApps"
}

installShortcuts() {
echo -e "\n[INFO] - Criando atalhos - [ $(dateFull_Info) ]"
if [ -e "/usr/share/pixmaps/vrmaster.png" ]; then
    icoFile="/usr/share/pixmaps/vrmaster.png"
else
    if [ ! -e "/vr/exec/img/VRMaster.png" ]; then
        appsIco="https://storage.googleapis.com/linux-pdv/Jeff/LinuxFiles/img.zip"
        sudo wget -c --no-check-certificate $appsIco -O /tmp/img.zip || pause_on_error
        sudo unzip -q -o /tmp/img.zip -d /vr/exec/img 2>/dev/null || pause_on_error
        sudo cp --remove-destination -p /vr/exec/img/VRMaster.png /usr/share/pixmaps 2>/dev/null || pause_on_error
    fi
    icoFile="/usr/share/pixmaps/vrmaster.png"
fi

sudo rm -rf "/vr/VRMaster.desktop" >/dev/null
echo -e "\n[Desktop Entry]" > "/vr/VRMaster.desktop"
echo -e "Name=VRMaster" >> "/vr/VRMaster.desktop"
echo -e "Path=/vr/exec/" >> "/vr/VRMaster.desktop"
echo -e "Exec=java -jar /vr/exec/VRMaster.jar" >> "/vr/VRMaster.desktop"
echo -e "Terminal=false" >> "/vr/VRMaster.desktop"
echo -e "Type=Application" >> "/vr/VRMaster.desktop"
echo -e "Icon=$icoFile" >> "/vr/VRMaster.desktop"
echo -e "Categories=System" >> "/vr/VRMaster.desktop"
sudo chmod +x "/vr/VRMaster.desktop" >/dev/null

realUser=$(ls /home | grep -v "^administrador$" | head -n 1)
userHome="/home/$realUser"
variable_atalhoFolders=("$userHome/Desktop" "$userHome/Área de Trabalho" "$userHome/Área de trabalho")
for variable_atalhoFolder in "${variable_atalhoFolders[@]}"; do
    if [ -d "$variable_atalhoFolder" ]; then
        sudo cp -p "/vr/VRMaster.desktop" "$variable_atalhoFolder" >/dev/null 2>&1
    fi
    if [ ! -e "$variable_atalhoFolder/Dbeaver.desktop" ]; then
        sudo chmod +x /usr/share/applications/dbeaver-ce.desktop >/dev/null 2>&1
        sudo cp /usr/share/applications/dbeaver-ce.desktop "$variable_atalhoFolder/Dbeaver.desktop" >/dev/null 2>&1
        sudo chmod +x "$variable_atalhoFolder/Dbeaver.desktop" >/dev/null 2>&1
        gio set "$variable_atalhoFolder/Dbeaver.desktop" metadata::trusted true >/dev/null 2>&1
    fi
    if [ ! -e "$variable_atalhoFolder/anydesk.desktop" ]; then
        sudo chmod +x /usr/share/applications/anydesk.desktop >/dev/null 2>&1
        sudo cp /usr/share/applications/anydesk.desktop "$variable_atalhoFolder/Anydesk.desktop" >/dev/null 2>&1
        sudo chmod +x "$variable_atalhoFolder/Anydesk.desktop" >/dev/null 2>&1
        gio set "$variable_atalhoFolder/Anydesk.desktop" metadata::trusted true >/dev/null 2>&1
    fi
    if [ ! -e "$variable_atalhoFolder/ISL_Light.desktop" ]; then
        sudo chmod +x "/vr/isl_LightClient_Folder/ISL_Light.desktop" >/dev/null 2>&1
        gio set "/vr/isl_LightClient_Folder/ISL_Light.desktop" metadata::trusted true >/dev/null 2>&1
        sudo cp -p /vr/isl_LightClient_Folder/ISL_Light.desktop "$variable_atalhoFolder/ISL_Light.desktop" >/dev/null 2>&1
        
    fi

    sudo mkdir -m 777 "$userHome"/.vr >/dev/null 2>&1
    sudo chmod 777 "$userHome"/.vr >/dev/null 2>&1
    sudo chown nobody:nogroup "$userHome"/.vr >/dev/null 2>&1
done

sudo cp -p "/vr/VRMaster.desktop" "/usr/share/applications" >/dev/null 2>&1
sudo cp -p /vr/isl_LightClient_Folder/ISL_Light.desktop "/usr/share/applications/ISL_Light.desktop" >/dev/null 2>&1

createRegisterLog "installShortcuts"
}

menuOptions() {
    
	echo ""
	echo "========================================= VRS: $vrs "
	echo "1. Instalacao Completa (PG, Base, ISL, Java, Apps)"
	echo "2. Base especifica"
    echo "3. Instalar Postgres 14"
    echo "4. Instalar Java VRMaster"
    # echo "5. Instalar Java PDV"
    # echo "6. Instalar Firebird PDV"
    # echo "7. Instalar PDV"
    echo "5. Extrair arquivos VR para a pasta /vr/exec"
    echo "6. ISL Light Client - Acesso Remoto VR"
	read -p "Escolha uma opcao: " OPTMENUOPTIONS
	
	if [ -z "$OPTMENUOPTIONS" ] || ! [[ "$OPTMENUOPTIONS" =~ ^[0-9]+$ ]]; then
		echo -e "\nErro: você deve escolher uma opcao valida." ; sleep 2 ; menuOptions
	fi
	
	if [ $OPTMENUOPTIONS -eq 1 ]; then
        echo -e "\n✅[INFO] - Configuracao Base VR iniciada - [ $(dateFull_Info) ]\n"
		checkRoot
        check_repos
        clearFiles
        installFolders
        islVR
        postgresRemove
        check "postgresRemove" ; postgresInstall
        check "postgresInstall" ; postgresRestore
        postgresConfig
        installJava
        check "installJava" ; installApps
        installShortcuts
        echo -e "\n[INFO] - Instalacao e configuração Base VR e App VRMaster concluida - [ $(dateFull_Info) ]"
        exit
	fi
	
	if [ $OPTMENUOPTIONS -eq 2 ]; then
        local FILE="$BACKUPPATH/$DATABASENAME"
        echo ""
        read -r -e -p "Nome da base (Ex: vr_contabil): " DATABASENAME
        read -r -e -p "Caminho completo do local do backup (Ex: /home/FULANO/Downloads/BASE.bk)(Obrigatorio informar a extensao do arquivo tambem): " BACKUPPATH 
        if [ -e "$FILE" ]; then
            echo -e "\n[INFO] - Restaurando Base $FILE . . . Aguarde . . . - [ $(dateFull_Info) ]"
            check "postgresInstall" ; postgresRestore_Specific "$DATABASENAME" "$BACKUPPATH"
            echo -e "\n[INFO] - Banco $DATABASENAME restaurada - [ $(dateFull_Info) ]"
            exit
        else
            echo -e "\n[FALHA] - Base $FILE nao encontrada - [ $(dateFull_Info) ]"
            exit
        fi
    fi

	if [ $OPTMENUOPTIONS -eq 3 ]; then
		checkRoot
        clearFiles
        installFolders
        check_repos
        postgresRemove
        check "postgresRemove" ; postgresInstall
        check "postgresInstall" ; postgresConfig
        echo -e "\n[INFO] - Instalacao Postgres 14 concluida - [ $(dateFull_Info) ]" ; sleep 2 ; exit
    fi

	if [ $OPTMENUOPTIONS -eq 4 ]; then
        installJava
        check "installJava" && (
            echo -e "\n[INFO] - Instalacao JAVA VRMASTER concluida - [ $(dateFull_Info) ]"
        ) || (
            echo -e "\n[FALHA] - Instalacao JAVA VRMASTER FALHA - [ $(dateFull_Info) ]" 
        )
        sleep 2 ; exit
	fi

	# if [ $OPTMENUOPTIONS -eq 5 ]; then
    #     javaPdvInstall
    #     check "javaPdvInstall" && (
    #         echo -e "\n[INFO] - Instalacao Java PDV concluida - [ $(dateFull_Info) ]"
    #     ) || (
    #         echo -e "\n[FALHA] - Instalacao Java PDV FALHA - [ $(dateFull_Info) ]"
    #     )
    #     sleep 2 ; exit
	# fi

    # if [ $OPTMENUOPTIONS -eq 6 ]; then
    #     firebirdPDVInstall
    #     check "firebirdPDVInstall" && (
    #         echo -e "\n[INFO] - Instalacao Firebird PDV concluida - [ $(dateFull_Info) ]"
    #     ) || (
    #         echo -e "\n[FALHA] - Instalacao Firebird PDV FALHA - [ $(dateFull_Info) ]"
    #     )
    #     sleep 2 ; exit
	# fi

    # if [ $OPTMENUOPTIONS -eq 7 ]; then
    #     installPDV
    #     check "javaPdvInstall" && (
    #         echo -e "\n[INFO] - Instalacao Java PDV concluida - [ $(dateFull_Info) ]"
    #     ) || (
    #         echo -e "\n[FALHA] - Instalacao Java PDV FALHA - [ $(dateFull_Info) ]"
    #     )

    #     check "firebirdPDVInstall" && (
    #         echo -e "\n[INFO] - Instalacao Firebird PDV concluida - [ $(dateFull_Info) ]"
    #     ) || (
    #         echo -e "\n[FALHA] - Instalacao Firebird PDV FALHA - [ $(dateFull_Info) ]"
    #     )

    #     check "pdv_Shortcut" && (
    #         echo -e "\n[INFO] - Instalacao Atalhos PDV concluida - [ $(dateFull_Info) ]"
    #     ) || (
    #         echo -e "\n[FALHA] - Instalacao Atalhos PDV FALHA - [ $(dateFull_Info) ]"
    #     )

    #     echo -e "\n[INFO] - Instalacao PDV concluida - [ $(dateFull_Info) ]" ; sleep 2 ; menuOptions
	# fi

	if [ $OPTMENUOPTIONS -eq 5 ]; then
        echo ""
        # Habilitar autocomplete de arquivos/pastas no read

        read -r -e -p "Informe o caminho do arquivo (Ex: /home/FULANO/Downloads/ARQUIVO.rar): " FILE
        if [ -e "$FILE" ]; then
            if [[ "$FILE" == *.rar ]]; then
                echo -e "\n[INFO] - Descompactando arquivo .RAR '$FILE' - [ $(dateFull_Info) ]"
                sudo chmod 777 $FILE >/dev/null 2>&1
                unrar x "$FILE" /vr/exec
            elif [[ "$FILE" == *.zip ]]; then
                echo -e "\n[INFO] - Descompactando arquivo .ZIP '$FILE' - [ $(dateFull_Info) ]"
                sudo chmod 777 $FILE >/dev/null 2>&1
                unzip -q -o "$FILE" -d /vr/exec
            else
                echo "Formato desconhecido"
                pause ; menuOptions
            fi
        else
            echo -e "\n[ERROR] - Arquivo '$FILE' nao foi encontrado. - [ $(dateFull_Info) ] \n"
            pause_on_error ; menuOptions
        fi

        echo -e "\n[INFO] - Aplicando permissoes em /vr/exec - [ $(dateFull_Info) ]"
        sudo chmod 777 -R /vr/exec >/dev/null 2>&1
        echo -e "\n[INFO] - Arquivos da pasta /vr/exec extraidos com sucesso - [ $(dateFull_Info) ]"
        exit
    fi

	if [ $OPTMENUOPTIONS -eq 6 ]; then
		checkRoot
        clearFiles
        check_repos
        installFolders
        islVR
        installShortcuts ; echo -e "\n[INFO] - Instalacao e configuração ISL Light Client concluida - [ $(dateFull_Info) ]" ; exit
	fi

	if [ $OPTMENUOPTIONS -ge 7 ]; then
		echo -e "\nOpcao incorreta, retornando ao menu" ; pause ; menuOptions
	fi
}

checkRoot
menuOptions

# ISL MANUALMENTE
# sudo mkdir /vr ; sudo chmod 777 -R /vr
# sudo wget -c --no-check-certificate "https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Linux/ISL_Light_Client.zip" -O /vr/ISL_Light_Client.zip
# sudo unzip -q -o /vr/ISL_Light_Client.zip -d /vr
# sudo rm -rf /vr/ISL_Light_Client.zip
# sudo mv /vr/ISL_Light_Client* /vr/ISL_Light_Client
# cd "/vr" ; ./ISL_Light_Client

# INSTALL JAVA MANUALMENTE
# sudo rm -rf /tmp/java_jdk_download
# sudo mkdir -m 777 /tmp/java_jdk_download
# sudo chmod 777 -R /tmp/java_jdk_download
# wget -O "/tmp/java_jdk_download/jdk-8u202-linux-x64.tar.gz" "https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Linux/jdk-8u202-linux-x64.tar.gz"
# tar -xvzf "/tmp/java_jdk_download/jdk-8u202-linux-x64.tar.gz" -C "/tmp/java_jdk_download"
# sudo mv "/tmp/java_jdk_download/jdk1.8.0_202" "/usr/lib/jvm/"
# sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.8.0_202/bin/java 2000
# sudo update-alternatives --set java /usr/lib/jvm/jdk1.8.0_202/bin/java

exit