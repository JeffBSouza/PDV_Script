#!/bin/bash

# >/dev/null 2>&1 - Esconde todos os retornos sejam true ou false
# 2>/dev/null - Esconde apenas os retornos true, de sucesso
# 1>/dev/null - Esconde apenas os retornos false, de erros

# https://storage.googleapis.com/linux-pdv/Jeff/Script_Jeff.sh
# sudo mkdir -p /pdv >/dev/null 2>&1; sudo chmod 777 -R /pdv >/dev/null 2>&1; sudo rm -rf /pdv/script.sh >/dev/null 2>&1; sudo wget -c --no-check-certificate https://storage.googleapis.com/linux-pdv/Jeff/Script_Jeff.sh -O /pdv/script.sh; sudo chmod +x /pdv/script.sh >/dev/null 2>&1; /pdv/script.sh

# 25/08/2025 - Inserida funcao 19, para ajustes no Properties
# 25/08/2025 - Ajuste na funcao 18, para identificar a vrs do Linux (AlwaysOn disponivel apenas em Linux 20.04 em diante) (Linux 16.04 e 18.04, usar o ISL_Light_Client)
# 25/08/2025 - Ajuste na funcao de update Linux
# 15/09/2025 - Remocao do fluxo Gsurf do script
# 15/09/2025 - Remocao do notepadqq do sourcelist atraves da function startcheck
# 23/09/2025 - Inclusao da function show_usb_devices, para exibição dos dispositivos
# 24/09/2025 - Ajuste visual nos menus
# 30/09/2025 - Melhoria no fluxo de mapeamento de pasta de rede [Vrs 9.0.76]
# 01/10/2025 - Ajuste de melhoria na function disableNotificationUpdate [Vrs 9.0.77]
# 03/10/2025 - Inserida function para instalação do RustDesk em SubMenu(4);Aplicativos;RustDesk(29) [Vrs 9.0.77]
# 03/10/2025 - Ajuste na function setshortcutfiles e suas chamadas [Vrs 9.0.77]
# 03/10/2025 - Ajuste no fluxo de comandos update, para agora realizar interaçao manual [Vrs 9.0.77]
# 06/10/2025 - Ajuste na function settingVRProperties_NFCe [9.0.78]
# 06/10/2025 - Ajuste na function show_usb_devices para visualizar dispositivos /dev/usb/lp* [9.0.78]

# Declaracao de variaveis utilizadas nas funcoes.

vrs=9.0.79

# Ano, Mes, Dia, Hora, Minuto, Segundos
date=$(date '+%Y-%m-%d_%H:%M:%S')
# Dia, Mes Ano
DATEDMY=$(date '+%d-%m-%Y')

LINUX_VERSION=$(lsb_release -sr)

pdv_sat=/pdv/sat
DIRCLISITEF="/pdv/util/libsitef"
TMP_LIB="/pdv/util/libpdv"
DIR_SAT="/pdv/util/BemaGo"
DIRSOUND="/pdv/som"
logs_path="/pdv/util/logsScript"
bkp_UsrLib="/pdv/util/bkp_UsrLib"
bkp_LibSitef="/pdv/util/bkp_LibSitef"
bkp_pdvShortcut="/pdv/util/bkp_pdvShortcut"
DIRGUNNEBO="/pdv/gunnebo"
SHORTCUTPATH="/usr/share/applications"

FILENAME="$DIR_SAT/satelgin-7.0.1-linux-i686.deb"
libdllsat_elgin_old="/usr/lib/libdllsat_elgin.so"
libdllsat="/usr/lib/libdllsat.so"
libdllsat_elgin="/usr/lib/libdllsat_elgin.so"
propertiespdv="/vr/vr.properties"
SHEBANG='#!/bin/bash'

sitefVrs="7.0.117.112.r3"
sitefVrsTeste="7.0.117.109.r1"

rustDeskvrs="1.4.2"

setcheckvariable=0
hamsterDx=teste

anydesk_executable="/usr/bin/anydesk"

desktopFolder=/home/$USER/Desktop
icon=/pdv/exec/img/VRPdv.png
iconPath=/pdv/exec/img
exec=/pdv/util/.scripts/pdv.sh
path=/pdv/util/.scripts/
pathSH=/pdv/util/.scripts/pdv.sh
execConfig=/pdv/util/.scripts/pdvConfig.sh
pathSHConfig=/pdv/util/.scripts/pdvConfig.sh
pathSHConfigdate=/pdv/util/.scripts/pdvConfig-$date.sh
pathSHdate=/pdv/util/.scripts/$date-pdv.sh
pathAutostart=/etc/xdg/autostart/VRPdv.desktop
pathAutostart_1604=/etc/xdg/autostart/VRPdv_AutoRun.desktop
pathAutostart_1804=/etc/xdg/autostart/pdv.desktop

# =========================================================
# Paleta de Cores
# ${R1}   ${End}
# Letra Branca negrito com fundo Branco - Piscante
# ${RP1} e ${End} (Vermelho Piscante)
RP1='\033[01;05;37;41m'
BP1='\033[01;05;37;44m'

# Letra Branca negrito com fundo Branco
# ${R1} e ${End} (Vermelho)
# ${B1} e ${End} (Azul)
R1='\033[01;37;41m'
B1='\033[01;37;44m'
End='\033[0m'

# Letra Verde Negrito sem fundo
G1='\033[01;32m'
# Letra CYAN sem fundo
C1='\033[1;36m'
# Letra Branca e Cyan fundo
C2='\033[46;1;37m'
# Texto ciano com fundo magenta
CM1='\033[1;36;45m'
# Letras amarela Negrito sem fundo
Y1='\033[01;33m'
Y2="\033[1;33;41m"
# Letra Preta com fundo verde limão
BG1="\033[1;30;102m"
# Letra laranja, negrito e fundo preto
LNFP="\033[1;38;5;208m\033[40m"
# Letra laranja e fundo preto
LFP="\033[38;5;208m\033[40m"

# Texto Branco Negrito com fundo Preto
WB1='\033[1;37;40m'
WB2='\033[01;05;37;40m'

# Reseta para a cor padrão
NORMAL='\033[0m'

# ${G1}✅${End} - 
# ${R1}❌${End} - 
# ${Y1}⚠️${End} - 
# ${B1}ℹ️${End} - 
# ${B1}🔄${End} - 
# ${B1}⚙️${End} - 
# ${Y1}⏳${End} - 
# ${Y1}🔔${End} - 

# Paleta de Cores
# =========================================================

URLCLISITEFINI="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Linux/CliSiTef.ini"
# URLSITEF="https://storage.googleapis.com/linux-pdv/Jeff/libsitef.zip"
URLSITEF="https://storage.googleapis.com/linux-pdv/Jeff/libsitef_full.zip"
URLLIBS="https://storage.googleapis.com/linux-pdv/Jeff/lib.zip"
URLRULES="https://storage.googleapis.com/linux-pdv/Jeff/vr.rules"
URLBEMAGO="https://storage.googleapis.com/linux-pdv/Jeff/satelgin-7.0.1-linux-i686.deb"
# URLFIREBIRD="https://storage.googleapis.com/linux-pdv/Jeff/firebird-2.5.tar.gz"
URLFIREBIRD="https://storage.googleapis.com/linux-pdv/Jeff/LinuxFiles/firebird-2.5.zip"
anydeskLink="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Linux/anydesk_6.0.1-1_i386.deb"
URLTEAMVIEWER="https://download.teamviewer.com/download/linux/teamviewer_i386.deb"
URLSOURCESLIST="https://storage.googleapis.com/linux-pdv/Jeff/LinuxFiles/sources.list"
URLMAGELAN9800I="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Linux/Datalogic_Magellan_9800i_Linux.zip"
URLISLONLINE="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Linux/ISL_AlwaysOn.zip"
# URLISLONELIN_LIGHTCLIENT="https://account.islonline.net/start/ISLLightClient"
# URLISLONELIN_LIGHTCLIENT="https://www.islonline.net/start/ISLLight?custom=vrsoft-com-br"
# URLISLONELIN_LIGHTCLIENT="https://www.islonline.net/start/ISLLightClient?custom=vrsoft-com-br"
URLISLONELIN_LIGHTCLIENT="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Linux/ISL_Light_ClientVR.zip"
URLRUSTDESK="https://github.com/rustdesk/rustdesk/releases/download/1.4.2/rustdesk-1.4.2-x86_64.deb"

google="www.google.com.br"
ftpgoogle="www.storage.googleapis.com"
ipinternet="8.8.8.8"
si300link="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Impressoras/SWEDA_Receipt_Printer_Driver-0.1.0.0-Linux-x86-Install.tar"
# si300link=http://www.sistemas.sweda.com.br/downloads/SWEDA_Receipt_Printer_Driver-0.1.0.0-Linux-x86-Install.tar
propertieslinux="https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Linux/vr.properties"
appsIco="https://storage.googleapis.com/linux-pdv/Jeff/LinuxFiles/img.zip"

touchmode_800x600='xrandr --newmode "800x600_touch"  38.25 800 832 912 1024 600 603 607 624 -hsync +vsync'
touchmode_1366x768='xrandr --newmode "1366x768_touch"  85.25 1368 1440 1576 1784 768 771 781 798 -hsync +vsync'
touchmode_1024x768='xrandr --newmode "1024x768_touch" 63.50 1024 1072 1176 1328 768 771 775 798 -hsync +vsync'

usrlibfolder=$bkp_UsrLib/Bkp_UsrLib-$date
siteflibfolder=$bkp_LibSitef/Bkp_LibSitef_UsrLib-$date

askSudo() {
	clear
	if [ -e "/pdv/SENHA_SUDO.txt" ]; then
		PASSWD=$(</pdv/SENHA_SUDO.txt)
		TESTPASSWD=$(printf '%s\n' "$PASSWD" | sudo -S -p '' touch /root/.passtest 2>/dev/null; echo $?)
		if [ "$TESTPASSWD" -ne 0 ]; then
			# senha no arquivo está errada → pedir novamente
			while true; do
				clear
				echo -e "\nInforme a senha SUDO/ROOT para execucao do Script"
				read -s -p "Password: " PASSWD
				echo
				TESTPASSWD=$(printf '%s\n' "$PASSWD" | sudo -S -p '' touch /root/.passtest 2>/dev/null; echo $?)
				if [ "$TESTPASSWD" -eq 0 ]; then
					# sobrescreve com a senha correta
					printf '%s\n' "$PASSWD" | sudo -S -p '' tee /pdv/SENHA_SUDO.txt >/dev/null 2>&1
					printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /pdv/SENHA_SUDO.txt >/dev/null 2>&1
					printf '%s\n' "$PASSWD" | sudo -S -p '' chown nobody:nogroup /pdv/SENHA_SUDO.txt >/dev/null 2>&1
					break
				else
					clear
					echo -e "${R1}❌${End} - ${R1}Senha incorreta${End}\n${R1}Senha digitada: $PASSWD${End}"
					sleep 1
				fi
			done
		fi
	else
		# primeira execução → pedir senha
		while true; do
			echo -e "\nInforme a senha SUDO/ROOT para execucao do Script"
			read -r -s -p "Password: " PASSWD
			echo
			TESTPASSWD=$(printf '%s\n' "$PASSWD" | sudo -S -p '' touch /root/.passtest 2>/dev/null; echo $?)
			if [ "$TESTPASSWD" -eq 0 ]; then

				# Fecha todos os javas
				printf '%s\n' "$PASSWD" | sudo -S -p '' killall java >/dev/null 2>&1 || true
				printf '%s\n' "$PASSWD" | sudo -S -p '' pkill -9 java >/dev/null 2>&1 || true

				# Cria pastas PDVs caso não existam
				variable_pdvpaths=(
					"/pdv" "/pdv/arquivoscupom" "/pdv/database" "/pdv/driver"
					"/pdv/exec" "/pdv/img" "/pdv/log" "/pdv/logpdv"
					"/pdv/sat" "/pdv/som" "/pdv/util"
				)
				for variable_pdvpath in "${variable_pdvpaths[@]}"; do
					if [ ! -d "$variable_pdvpath" ]; then
						printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 "$variable_pdvpath" 2>/dev/null
						printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R "$variable_pdvpath" 2>/dev/null
						printf '%s\n' "$PASSWD" | sudo -S -p '' chown nobody:nogroup -R "$variable_pdvpath" 2>/dev/null
					fi
				done

				# Grava a senha em arquivo
				printf '%s\n' "$PASSWD" | sudo -S -p '' tee /pdv/SENHA_SUDO.txt >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /pdv/SENHA_SUDO.txt >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S -p '' chown nobody:nogroup /pdv/SENHA_SUDO.txt >/dev/null 2>&1

				break
			else
				clear
				echo -e "${R1}❌${End} - ${R1}Senha incorreta${End}\n${R1}Senha digitada: $PASSWD${End}"
				sleep 1
			fi
		done
	fi
}

# =================================================================================================
# Valida se o script esta iniciando como SUDO.
if [ $UID -eq 0 ]; then
    echo -e "${R1}\nO script nao deve ser executado utilizando o usuario root.\nPor gentileza execute novamente e digite a senha somente quando solicitada.${End}\n"
    read -n 1 -s -r -p "Press to Exit/Continue. . ."
    exit
else
	sudo -k
	askSudo
fi
# =================================================================================================
startCheck() {
libsitefinfo
# checkVPNTEF

printf '%s\n' "$PASSWD" | sudo -S -p '' rm /etc/apt/sources.list.d/notepadqq-team-ubuntu-notepadqq-focal.list >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' rm /etc/apt/sources.list.d/notepadqq-team-ubuntu-notepadqq-focal.list.save >/dev/null 2>&1

# Valida pasta /pdv e as internas
valida_paths=("/pdv" "/pdv/driver" "/pdv/sat" "/pdv/exec" "/pdv/database" "/pdv/util" "/pdv/som" "$path" "/vr" "$logs_path" "$bkp_UsrLib" "$bkp_LibSitef" "$bkp_pdvShortcut" "$iconPath")
for valida_path in "${valida_paths[@]}"; do
    if [ ! -d "$valida_path" ]; then
		echo -e "\n${B1}ℹ️${End}[INFO] - Ajustando pastas padroes $valida_path - [ $(dateFull_Info) ]"
        printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $valida_path >/dev/null 2>&1
        printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $valida_path >/dev/null 2>&1
        printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" $valida_path >/dev/null 2>&1
    fi
done

#Deletar arquivos .expect
printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/util/.scripts/*.expect >/dev/null 2>&1

#Redefinição de variaveis
firebird_installdate=$(stat -c %y /opt/firebird 2>/dev/null | cut -d ' ' -f 1)
java_installdate=$(stat -c %y /usr/lib/jvm/java-8-openjdk-i386 2>/dev/null | cut -d ' ' -f 1)
ecfcaixa=$(grep "naofiscal.numeroecf=" "$propertiespdv" 2>/dev/null | sed -n 's/.*naofiscal.numeroecf=\(.*\)/\1/p' 2>/dev/null)

# Valida atalho TestaPeriferico
while IFS= read -r desktopFolder; do
    if grep -q 'Exec=java -jar /pdv/exec/VRPdv.jar -teste' "$desktopFolder/VRTestaPeriferico.desktop" 2>/dev/null; then
        printf '%s\n' "$PASSWD" | sudo -S rm -f "$desktopFolder/VRTestaPeriferico.desktop" 2>/dev/null
        printf '%s\n' "$PASSWD" | sudo -S rm -f "$logs_path/AtalhoTestaPeriferico.txt" 2>/dev/null
    fi
done < <(setshortcutfiles)
if [ ! -e $logs_path/AtalhoTestaPeriferico.txt ]; then
	if [ $skipWget -ne 1 ]; then
		echo -e "\n${B1}ℹ️${End}[INFO] - Ajustando Atalho TestaPeriferico - [ $(dateFull_Info) ]"
		atalhoTestaPeriferico
	fi
fi

# Realiza autoupdate em caso de script nao estar atualizado
if [ ! -e $logs_path/UtilitarioOk.txt ]; then
	if [ $skipWget -ne 1 ]; then
		updateUtilitarioPDV
	fi
fi

# Desativa manualmente notificações do linux caso ja nao tenha sido feito
if [ ! -e $logs_path/disableNotification.txt ]; then
	if [ $skipWget -ne 1 ]; then
		echo -e "\n${B1}ℹ️${End} [INFO] - Ajustando NotificacoesLinux - [ $(dateFull_Info) ]"
		disableNotificationUpdate
	fi
fi

# Valida libs vr em pastas incorretas
if [ ! -e $logs_path/deletaLibs_lib32_64.txt ]; then
	echo -e "\n${B1}ℹ️${End} [INFO] - Ajustando pastas /usr/lib32 e /usr/lib64 - [ $(dateFull_Info) ]"
	checkLibsFolders_usr32_usr64
fi

# Identifica data que o linux foi instalado na maquina
LINUX_INSTALL_DATE=$(ls -lct /etc | tail -1 | awk '{print $6, $7, $8}')
# Identifica Versao e Kernel da ISO
LINUX_VERSION=$(lsb_release -sr)
# Traz valor completo do Kernel
LINUX_KERNEL=$(uname -r)
# Identifica se é x86 ou x64
LINUX_ARCHITECTURE=`arch`

ip_address=$(hostname -I | cut -d' ' -f1)

required_kernel_20="5.15.0-55-generic"
current_kernel=$(uname -r)

if [[ ${LINUX_ARCHITECTURE} == "i686" ]]; then
	linuxArquitetura="x86/32bits"
elif [[ ${LINUX_ARCHITECTURE} == "i386" ]]; then
	linuxArquitetura="x86/32bits"
elif [[ ${LINUX_ARCHITECTURE} == "x86_64" ]]; then
	linuxArquitetura="x64/64bits"
fi

if [[ ${LINUX_VERSION} == "16.04" ]]; then
	hamsterDx=ok
	kernelcompatible="${G1}Kernel Compativel${End}"
	vrscompatible="${G1}Versao Compativel${End}"
	# linuxVrs=antiga
fi
if [[ ${LINUX_VERSION} == "18.04" ]]; then
	hamsterDx=notok
	kernelcompatible="${R1}Kernel NAO Compativel${End}"
	vrscompatible="${R1}Versao NAO Compativel${End}"
	# linuxVrs=estavel
fi
if [[ ${LINUX_VERSION} == "20.04" ]]; then
	if dpkg --compare-versions "$current_kernel" "ge" "$required_kernel_20"; then
        hamsterDx=ok
        kernelcompatible="${G1}Kernel EM AVALIACAO${End}"
        vrscompatible="${G1}Versao  EM AVALIACAO${End}"
    else
        hamsterDx=notok
        kernelcompatible="${R1}Kernel NAO Compatível${End}"
        vrscompatible="${R1}Versao NAO Compatível${End}"
    fi
fi
if [[ ${LINUX_VERSION} == "22.04" ]]; then
	hamsterDx=notok
	kernelcompatible="${R1}Kernel NAO Compativel${End}"
	vrscompatible="${R1}Versao NAO Compativel${End}"
	# linuxVrs=estavel
fi

Print_Menu="Versao - $LINUX_VERSION / Kernel - $LINUX_KERNEL"

# Identifica Processador
PROCESSADOR=$(lscpu | grep 'Nome do modelo' | cut -f 2 -d ":" | awk '{$1=$1}1')
if [[ -z "$PROCESSADOR" ]]; then
	PROCESSADOR=$(lscpu | grep 'Model name' | cut -f 2 -d ":" | awk '{$1=$1}1')
fi
#Identifica Quantidade de Memoria Ram em MB
MEMORY_RAM=$(free -m | awk '/Mem.:/{print "Mem.Total: " $2 " Em uso: " $3 " Livre: " $4}')
if [[ -z "$MEMORY_RAM" ]]; then
	MEMORY_RAM=$(free -m | awk '/Mem:/{print "Mem.Total: " $2 " Em uso: " $3 " Livre: " $4}')
fi

# Checa versoes java
java_version=$(dpkg -l | grep -i openjdk-8-jre:i386 | cut -f 2 -d "u" | cut -b 1-3)
java_Checkarchiteture=$(dpkg -l | grep -i openjdk-8-jre: | cut -f 2 -d ":" | cut -b 1-4)

if [[ ${java_Checkarchiteture} == "i386" ]]; then
	java_architeture="x86"
else
	java_architeture="Java com arquitetura desconhecida"
fi

if [ ! -e "/opt/ISLOnline/ISLAlwaysOn/ISLAlwaysOn" ]; then
	if [ -e "$HOME/Desktop/ISLAlwaysOn.desktop" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "$HOME/Desktop/ISLAlwaysOn.desktop" >/dev/null 2>&1
	fi
	if [ -e "$HOME/Desktop/ISLAlwaysOn_Desinstalar.desktop" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "$HOME/Desktop/ISLAlwaysOn_Desinstalar.desktop" >/dev/null 2>&1
	fi
fi
}

separador() {
	echo -e "${LNFP}=======================================================${End}"
}

warnningInteraction() {
    echo -e "\n** ${B1}ℹ️${End} [ATENCAO - INTERACAO NECESSARIA]${B1}ℹ️${End} **\n-- [INFO] A atualizacao/instalacao ira iniciar, existem momentos que sera necessario a sua interacao \nCaso seja necessario entrar com a senha SUDO (senha da maquina) ou um S/n\n Para selecao de opcoes voce pode usar o TAB (para navegar) e o ENTER (para confirmar)"
	echo -e "-- [INFO] Entao se atente a tela durante a atualizacao\n"
	pause
}

dateFull_Info() {
date '+%Y-%m-%d_%H:%M:%S'
}
#  - [ $(dateFull_Info) ]

pause() {
echo -e "${WB2}Press any button to Exit or Continue...${End}"
read -n 1 -s -r
}

pause_on_error() {
echo -e "[ERRO] - Um erro ocorreu no comando anterior."
pause
}

finished() {
echo -e "${G1}✅${End} - ${BG1}PROCESSO ENCERRADO${End} - ${G1}✅${End}"
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

folder_create() {
local FOLDER="$1"
printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $FOLDER >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R $FOLDER >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 "$FOLDER" >/dev/null 2>&1
}

createRegisterLog() {
createlogpathfolder
local logNameFile="$1"
printf '%s\n' "$PASSWD" | sudo -S -p '' touch $logs_path/$logNameFile.txt >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $logs_path/$logNameFile.txt >/dev/null 2>&1

date=$(date '+%Y-%m-%d_%H:%M:%S')
echo "=============================" >> $logs_path/$logNameFile.txt
echo "$logNameFile em $date" >> $logs_path/$logNameFile.txt
}

createlogpathfolder() {
printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $logs_path >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R $logs_path >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R $logs_path >/dev/null 2>&1
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

updateSystem_FixCommand() {
    echo -e "\n${B1}ℹ️${End}[INFO] - Executando preparacao de pacotes... - [ $(dateFull_Info) ]"
	printf '%s\n' "$PASSWD" | sudo -S -p '' -v || { echo "[ERRO] - Senha incorreta para execucao de comandos SUDO"; pause ; menuOptions; }
	local commandsList=(
	"apt update"
	"dpkg --configure -a"
	"apt-get -y --fix-broken install"
	"apt-get -f -y install"
	"ldconfig"
	"apt -y clean"
	)
	for cmd in "${commandsList[@]}"; do
		echo
		echo "[EXECUTANDO] - $cmd"
		sudo bash -c "$cmd"
		if [ $? -ne 0 ]; then
			pause_on_error "$cmd"
		fi
	done
}

updateSystem_UpgradeCommand() {
	printf '%s\n' "$PASSWD" | sudo -S -p '' -v || { echo "[ERRO] - Senha incorreta para execucao de comandos SUDO"; pause ; menuOptions; }
	local commandsList=(
	"apt update"
	"dpkg --configure -a"
	"apt-get -y --fix-broken install"
	"apt-get -f -y install"
	"ldconfig"
	"apt -y upgrade"
	)
	for cmd in "${commandsList[@]}"; do
		echo
		echo "[EXECUTANDO] - $cmd"
		sudo bash -c "$cmd"
		if [ $? -ne 0 ]; then
			pause_on_error "$cmd"
		fi
	done
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

setshortcutfiles() {
    local desktopDirs=("$HOME/Desktop" "$HOME/Área de Trabalho" "$HOME/Área de trabalho")
    local dir
    for dir in "${desktopDirs[@]}"; do
        [ -d "$dir" ] && printf '%s\n' "$dir"
    done
}

checkLibsFolders_usr32_usr64() {
bkp_usr32=/pdv/util/bkp_UsrLib32
bkp_usr64=/pdv/util/bkp_UsrLib64

    valida_FolderLibs=("/usr/lib32" "/usr/lib64")
    valida_libs=("99-tanca.rules" "bemasat.xml" "CliSiTef.ini" "CONVERSOR.ini" "DarumaFrameWork.xml" "ftrWSQ.so" "libBemaSAT32.so" "libcidbio.so" "libcidbio.so.0" "libclisitef.so" "libconvecf.so" "libDarumaFramework.a" "libDarumaFramework.so" "libdllsat.so" "libdllsat_elgin.so" "libemv.so" "libftrJavaScanAPI.so" "libGNE_Framework.so" "libinpout32.so" "libInterfaceEpsonNF.dll.so" "libjCliSiTefI.so" "liblebin.so" "libLeituraMFDBin.so" "libmkse.so" "libQrCode_DarumaFramework.so" "libsat.a" "libsat.so" "libsat_daruma.so" "libSATDLL.so" "libSatGer.conf" "libSatGer.so" "libsatid.so.1.2.3" "libScanAPI.so" "libseppemv.so" "libsk_access.so" "libsk_access_tcp.so" "libusb-1.0.so.0.1.0.22" "sk_access.h" "sk_access.inc" "sk_access_tcp.h" "sk_access_tcp.inc" "TCP_Server" "use_sk_access" "libswmfd.so" "libswmfd.so.0" "libtec_linux.so" "libWS_Framework.so" "mp2032" "rechargeRPC.so" "SI300" "libNBioBSP.so" "libNBioBSPISO4JNI.so" "libNBioBSPJNI.so" "libGCPlug.so")

for valida_libFolderLib in "${valida_FolderLibs[@]}"; do
    for valida_lib in "${valida_libs[@]}"; do
        if [ -d "$valida_libFolderLib" ]; then
            if [ -e "$valida_libFolderLib/$valida_lib" ]; then
                if [ "$valida_libFolderLib" = "/usr/lib32" ]; then
                    if [ ! -d "$bkp_usr32" ]; then
						printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 "$bkp_usr32" >/dev/null 2>&1
					fi
                    bkp_usr=$bkp_usr32
                elif [ "$valida_libFolderLib" = "/usr/lib64" ]; then
                    if [ ! -d "$bkp_usr64" ]; then
						printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 "$bkp_usr64" >/dev/null 2>&1
					fi
                    bkp_usr=$bkp_usr64
                fi
				
                printf '%s\n' "$PASSWD" | sudo -S -p '' mv "$valida_libFolderLib/$valida_lib" "$bkp_usr/$valida_lib" >/dev/null 2>&1
                local date=$(date '+%Y-%m-%d_%H:%M:%S')
				filepermission_create "$logs_path/deletaLibs_lib32_64.txt"
                echo "Lib $valida_libFolderLib/$valida_lib deletada em $date" >> /pdv/util/logsScript/deletaLibs_lib32_64.txt >/dev/null 2>&1
            fi
        fi
    done
done

valida_FolderLibs=("$bkp_usr32" "$bkp_usr64")
shopt -s nullglob
for valida_libFolderLib in "${valida_FolderLibs[@]}"; do
    arquivos=("$valida_libFolderLib"/*)

    if [ -d "$valida_libFolderLib" ] && [ ${#arquivos[@]} -gt 0 ]; then
        DATEYMD=$(date '+%Y-%m-%d')

        printf '%s\n' "$PASSWD" | sudo -S -p '' zip -r "$valida_libFolderLib/Bkp_UsrLib-$DATEYMD.zip" "$valida_libFolderLib" >/dev/null 2>&1
        printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 "$valida_libFolderLib/Bkp_UsrLib-$DATEYMD.zip" 2>/dev/null
        printf '%s\n' "$PASSWD" | sudo -S -p '' chown nobody:nogroup "$valida_libFolderLib/Bkp_UsrLib-$DATEYMD.zip" 2>/dev/null

        find "$valida_libFolderLib/" -mindepth 1 ! -name '*.zip' \
            -exec sh -c 'echo "$0" | sudo -S rm -rf "$@" >/dev/null 2>&1' "$PASSWD" {} +
    fi
done
shopt -u nullglob

createRegisterLog "deletaLibs_lib32_64"
}

check_and_handle_files() {
    local DIR="$1"
    local PREFIX="$2"
    local CMD_IF_FOUND="$3"
    local CMD_IF_NOT_FOUND="$4"

    # se dir não existe -> fallback
    if [ ! -d "$DIR" ]; then
        [ -n "$CMD_IF_NOT_FOUND" ] && eval "$CMD_IF_NOT_FOUND"
        return 1
    fi

    # coleta com find (seguro para nomes com espaços)
    local -a _files=()
    while IFS= read -r -d '' f; do
        _files+=("$f")
    done < <(find "$DIR" -maxdepth 1 -type f -name "${PREFIX}*.zip" -print0 2>/dev/null)

    if [ ${#_files[@]} -eq 0 ]; then
        [ -n "$CMD_IF_NOT_FOUND" ] && eval "$CMD_IF_NOT_FOUND"
        return 1
    fi

    # --- Compatibilidade / variáveis úteis (não locais) ---
    arquivos=( "${_files[@]}" )

    for f in "${arquivos[@]:1}"; do
        [[ "$f" -nt "$newest" ]] && newest="$f"
    done
    arquivos_newest="$newest"

    # string com nomes shell-escaped (útil se necessário)
    local -a _quoted=()
    for f in "${arquivos[@]}"; do
        _quoted+=( "$(printf '%q' "$f")" )
    done
    arquivos_escaped="${_quoted[*]}"

    # Se o comando tem '{}' => tratar como template por arquivo (mais seguro)
    if [[ "$CMD_IF_FOUND" == *'{}'* ]]; then
        for f in "${arquivos[@]}"; do
            local file_esc
            file_esc="$(printf '%q' "$f")"
            local cmd="${CMD_IF_FOUND//\{\}/$file_esc}"
            eval "$cmd"
        done
    else
        # Modo legado: eval direto (pode usar "${arquivos[@]}")
        eval "$CMD_IF_FOUND"
    fi

    return 0
}

check_and_install_firefox() {
    if ! command -v firefox >/dev/null 2>&1; then
        echo -e "\n${Y1}⚠️${End} - Firefox não encontrado. Instalando agora..."
        printf '%s\n' "$PASSWD" | safe_apt_get update -y >/dev/null 2>&1
        if printf '%s\n' "$PASSWD" | safe_apt_get install -y firefox >/dev/null 2>&1; then
            echo -e "${G1}✅ Firefox instalado com sucesso.${End}"
        else
            echo -e "${R1}❌ Falha ao instalar o Firefox.${End}"
            pause
            menuOptions
        fi
    else
        echo -e "${G1}✔ Firefox já está instalado.${End}"
    fi
}

checkGooglePublicDNS() {

if [ -d "/etc/resolvconf/resolv.conf.d" ]; then
	if [ ! -e "/etc/resolvconf/resolv.conf.d/head" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' touch /etc/resolvconf/resolv.conf.d/head >/dev/null 2>&1
	fi
else 
	printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 "/etc/resolvconf/resolv.conf.d" >/dev/null 2>&1
	if [ ! -e "/etc/resolvconf/resolv.conf.d/head" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' touch /etc/resolvconf/resolv.conf.d/head >/dev/null 2>&1
	fi
fi
	
	resolvfilesnames=("/etc/resolvconf/resolv.conf.d/head" "/etc/resolv.conf")
	googlepublicdnsIPS=("nameserver 8.8.8.8" "nameserver 8.8.4.4")
	
	for filenames in "${resolvfilesnames[@]}"; do
		for ips in "${googlepublicdnsIPS[@]}"; do
			if ! grep -q "^$ips$" "$filenames" >/dev/null 2>&1; then
				echo "$ips" | sudo tee -a "$filenames" >/dev/null 2>&1
				date=$(date '+%Y-%m-%d_%H:%M:%S')
				printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "Linha: $ips\nAdicionada ao $filenames em $date" | sudo tee -a $logs_path/ResolvConfUpdated.txt >/dev/null 2>&1
			fi
		done
	done
}

internetConnectionCheck() {
	echo -e "\n[Testando conexoes Rede e Internet...]"
	
	echo -e "\n[Testando Ping Google...]"
	ping -c2 $google &> /dev/null
    if [ $? -ne 0 ]; then
		checkGooglePublicDNS
		ping -c2 $google &> /dev/null
		if [ $? -ne 0 ]; then
		testeGoogle=notOk && connectionTest=failed
		else echo -e "${B1}PING Internet [8.8.8.8] OK${End}" ; testeGoogle=Ok
		fi
	else echo -e "${B1}PING Internet [8.8.8.8] OK${End}" ; testeGoogle=Ok
	fi
	
    echo -e "\n[Testando Ping FTP Google...]"
	ping -c2 $ftpgoogle &> /dev/null
    if [ $? -ne 0 ]; then
		checkGooglePublicDNS
		ping -c2 $ftpgoogle &> /dev/null
		if [ $? -ne 0 ]; then
			testeftpGoogle=notOk && connectionTest=failed
		else 
			echo -e "\${B1}PING FTP Google OK${End}" ; sleep 1 ; testeftpGoogle=Ok
			googleFTPDownloadtest
		fi
	else 
		echo -e "${B1}PING FTP Google OK${End}" ; sleep 1 ; testeftpGoogle=Ok
		googleFTPDownloadtest
	fi
	if [[ ${ftpdownloadtest} == "Ok" ]]; then
		echo -e "${B1}Download FTP Google OK${End}"
	fi

	if [[ ${connectionTest} == "failed" ]]; then
		echo ""
		if [[ ${testeGoogle} == "notOk" ]]; then
			echo -e "\n${R1}Sem conexao com a internet, teste de ping no GOOGLE sem sucesso${End}"
		fi
		if [[ ${testeftpGoogle} == "notOk" ]]; then
			echo -e "\n${R1}Sem conexao com a FTP Google, teste de ping sem sucesso${End}\n${B1}Algumas funcoes podem nao funcionar${End}"
		fi
		if [[ ${ftpdownloadtest} == "notOk" ]]; then
			echo -e "\n${R1}Sem conexao com a FTP Google, teste de Download sem sucesso${End}\n${B1}Algumas funcoes podem nao funcionar${End}"
		fi
		menuCheckNetwork
	fi
}

internetTest() {
	clear
	
	echo -e "${C1}[Ping Google (google.com) . . .]${End}\n"
	ping -c10 $google | sudo tee -a /tmp/file.txt


	echo -e "\n${C1}[Ping FTP Google VR . . .]${End}\n"
    ping -c10 $ftpgoogle | sudo tee -a /tmp/file.txt

	
	echo -e "\n${C1}[Ping 8.8.8.8 (GooglePublicDNS). . .]${End}\n"
    ping -c10 $ipinternet | sudo tee -a /tmp/file.txt
	
	googleFTPDownloadtest
	if [[ ${ftpdownloadtest} == "Ok" ]]; then
		echo -e "${B1}Download FTP Google OK${End}"
	fi
	if [[ ${ftpdownloadtest} == "notOk" ]]; then
		echo -e "\n${R1}Sem conexao com a FTP Google, teste de Download sem sucesso${End}\n${R1}Algumas funcoes podem nao funcionar${End}"
	fi

	date=$(date '+%Y-%m-%d_%H:%M:%S')
	printf '%s\n' "$PASSWD" | sudo -S -p '' cp /tmp/file.txt $logs_path/Internet_ConnectionTeste-$date.txt 2>/dev/null
	
	createRegisterLog "InternetTeste"
}

googleFTPDownloadtest() {
echo -e "\n[Testando Download FTP Google...]"

	if [ -e "/tmp/script.sh" ];then
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /tmp/script.sh >/dev/null 2>&1
	fi
	
	local tamanho_minimo=150
	
	# Aciona funcao para download
	download_script 10
	# Verifica se o wget ainda está em execução
	if ps | grep -q "[w]get"; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' pkill -f "[w]get"
	fi

	if [ ! -e /tmp/script.sh ]; then
		connectionTest=failed && ftpdownloadtest=notOk
	fi
	if [[ $(stat -c%s "/tmp/script.sh") -lt $((tamanho_minimo * 1024)) ]]; then
		connectionTest=failed && ftpdownloadtest=notOk
	else
		connectionTest=sucess && ftpdownloadtest=Ok
	fi
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /tmp/script.sh >/dev/null 2>&1
}

menuCheckNetwork() {
		echo "Por favor verifique com o cliente sobre o acesso a internet"
		echo -e "${LNFP}1) Retornar ao menu Central${End}"
		echo "2) Continuar o processo mesmo sem sucesso no teste"
		echo "3) Sair do Script"
		read -p "Opcao:" OPTNETTEST
				
		if [ -z "$OPTNETTEST" ] || ! [[ "$OPTNETTEST" =~ ^[0-9]+$ ]]; then
			echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; menuOptions
		fi
		if [ $OPTNETTEST -eq 1 ]; then
			menuOptions
		fi
		if [ $OPTNETTEST -eq 2 ]; then
			:
		fi
		if [ $OPTNETTEST -eq 3 ]; then
			exit
		fi
		if [ $OPTNETTEST -ge 4 ]; then
			echo -e "\n${R1}Opcao incorreta, retornando ao menu principal${End}" ; pause ; menuOptions
		fi
}

setResolvconf() {
checkGooglePublicDNS

	createRegisterLog "SetResolvConf"
}

menuSitef() {
	checkVPNTEF
	add_3624_Clisitef_CargaTabelasManual

	clear
	echo ""
	echo -e "${COLOR_TLS_FILE}VPN SitefExpress (TLS) Status:${End} $VPNSTATUS"
	echo -e "${COLOR_VR}Token_VRProperties:${End} $TOKEN_VR | ${COLOR_CONFITLS}Token_ConfiTLS:${End} $TOKEN_CONFITLS "
	separador
    echo -e "${G1}1. Atualizar Libs/Dll Sitef${End}"
    echo -e "${G1}2. Instalar/Reinstalar VPN Sitef Express [ TLS ]${End}"
	echo "3. Renomear ChavesCliSitef (Descer Carga de Tabelas novamente)"
	echo "4. Desativando Carga Tabelas automatica"
	echo "5. Ativar Carteira Digital no CliSitef.ini (;7;8)"
	echo "6. Novo Clisitef.ini"
	echo "7. jClisitef (libjCliSiTefI.so) [Finalizar TEF apenas pisca a tela]"
	echo "8. Validacao GLIBC ldd (GNU libc) para novas Libs Sitef [EM TESTE]"
	echo "9. Remover definicao de Pasta de DMP e Cargas Sitef [Nao recomendado]"
	echo "10. Teste Conexao TLS"
	echo -e "${G1}11. Excluir CONFITLS - TEF TERCEIRO${End}"
	echo -e "${LNFP}12. Retornar Menu Geral${End}"
	echo "13. Realizar BKP arquivo Log DMP em  /pdv/util/BKP_DMPs"
	echo -e "${R1}99. SAIR${End}"
    read -p "Escolha o tipo de ajuste: " NAMESITEF

		if [ -z "$NAMESITEF" ] || ! [[ "$NAMESITEF" =~ ^[0-9]+$ ]]; then
			echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; pause ; menuSitef
		fi
		if [ $NAMESITEF -eq 1 ]; then
			atualizarClisitef
		fi

		if [ $NAMESITEF -eq 2 ]; then
			vpnSitefExpress
		fi
		
		if [ $NAMESITEF -eq 3 ]; then
			renomearchavesclisitef
		fi

		if [ $NAMESITEF -eq 4 ]; then
			removerLinhasCliSiTef "DiretorioBase=/home/$USER/CliSiTef/ChavesCliSiTef" "[SalvaEstado]" "DiretorioBase=/home/$USER/CliSiTef"
			setCargaSitefFolder_default
		fi
		
		if [ $NAMESITEF -eq 5 ]; then
			ativarCarteiraDigital
		fi

		if [ $NAMESITEF -eq 6 ]; then
			novoClisitefIni
		fi

		if [ $NAMESITEF -eq 7 ]; then	
			jclisitef
		fi

		if [ $NAMESITEF -eq 8 ]; then	
			check_glibc
		fi
		
		if [ $NAMESITEF -eq 9 ]; then	
			removerLinhasCliSiTef "[SalvaEstado]" "DiretorioBase=/home/$USER/CliSiTef/ChavesCliSiTef" "DiretorioBase=/home/$USER/CliSiTef" "DiretorioTrace=/home/$USER/CliSiTef"
		fi
		
		if [ $NAMESITEF -eq 10 ]; then	
			check_tls_connection
		fi

		if [ $NAMESITEF -eq 11 ]; then	
			removerLinhas_TokenTLS "/vr/vr.properties"
		fi
		
		if [ $NAMESITEF -eq 12 ]; then	
			menuOptions
		fi
		
		if [ $NAMESITEF -eq 13 ]; then	
			bkpDmps
		fi

		if [ $NAMESITEF -ge 14 ]; then
			if [ $NAMESITEF -le 98 ]; then	
			echo -e "\n${R1}Opcao incorreta, retornando ao menu Sitef${End}" ; pause ; menuSitef
			fi
		fi
		
		if [ $NAMESITEF -eq 99 ]; then	
			exit
		fi
}

libsitefinfo() {
size_in_bytes=$(stat -c %s /usr/lib/libclisitef.so 2>/dev/null)
size_in_megabytes=$(echo "scale=2; $size_in_bytes / (1024 * 1024)" | bc 2>/dev/null)
libSitefversion=$(grep '^clisitef-' /usr/lib/RELEASE.TXT 2>/dev/null)
data_line=$(grep '^Data' /usr/lib/RELEASE.TXT 2>/dev/null)
}

checkSitefFiles() {
	pathlib32=/usr/lib32
	pathlib64=/usr/lib64
	pathlibdriver=/pdv/driver
	pathlibsat=/pdv/sat

	checkPath=("$pathlib32" "$pathlib64" "$pathlibdriver" "$pathlibsat" "$bkp_UsrLib" "/pdv" "/vr" "/pdv/util" "$TMP_LIB" "$HOME")
	for checkPath in "${checkPath[@]}"; do
		if [ -d "$checkPath" ]; then
			filesSitef=("$checkPath/Cheque.txt" "$checkPath/Leiame.txt" "$checkPath/lgpl-2.1.txt" "$checkPath/libclisitef.so" 
			"$checkPath/libcurl_LICENSE.txt" "$checkPath/libcurl32.so" "$checkPath/libemv.so" "$checkPath/libpng_LICENSE.txt" 
			"$checkPath/libqrencode_LICENSE.txt" "$checkPath/libqrencode32.so" "$checkPath/rechargeRPC.so" "$checkPath/RELEASE.TXT" 
			"$checkPath/CONFITLS.INI" "$checkPath/CONFITLS.ini" "$checkPath/CliSiTef.ini")
			for filesSitef in "${filesSitef[@]}"; do
				if [ -e "$filesSitef" ]; then
					printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "$filesSitef" >/dev/null 2>&1
					date=$(date '+%Y-%m-%d_%H:%M:%S')
					filepermission_create "$logs_path/FilesSitef_Del.txt"
					echo "$filesSitef deletado em $date" >> "$logs_path/FilesSitef_Del.txt" >/dev/null 2>&1
				fi
			done
		fi
	done

	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $siteflibfolder 2>/dev/null
	# Remove todos os arquivos e pastas dentro de "$bkp_LibSitef/" exceto arquivos .zip, 
	find "$bkp_LibSitef/" -mindepth 1 ! -name '*.zip' -exec sh -c 'echo "$0" | sudo -S rm -rf "$@" >/dev/null 2>&1' "$PASSWD" {} + >/dev/null 2>&1

	#Deleta o arquivo CliSiTef.ini que esteja dentro da pasta /pdv/util e suas subpastas
	date=$(date '+%Y-%m-%d_%H:%M:%S')
	find /pdv/util -type d -exec sh -c 'if [ -e "$1/CliSiTef.ini" ]; then echo "$1/CliSiTef.ini em $2" >> "$3/FilesSitef_Del.txt"; rm -rf "$1/CliSiTef.ini"; fi' sh {} "$date" "$logs_path" \; >/dev/null 2>&1
}

atualizarClisitef() {

if [ $setcheckvariable -ne 1 ]; then
		echo ""
		echo "----------------------"
		echo -e "${G1}Atualizando Libs SITEF${End}"
		echo "----------------------"
	
		killApp java

	libsitefinfo

	echo ""
	echo -e "[Info da Lib/Dll Sitef atual no PDV]"
	echo -e "${G1}Data Dll Sitef:${End} $data_line"
	echo -e "${G1}Tamanho Dll Sitef:${End} $size_in_megabytes Mb"
	echo -e "${G1}Versao Dll Sitef:${End} $libSitefversion"
	separador
    echo "1. Libs Atuais ($sitefVrs)"
	echo "2. Vrs Teste ($sitefVrsTeste)"
	echo -e "${LNFP}3. Retornar Menu Geral${End}"
	echo "99. SAIR"
    read -p "Escolha o tipo de ajuste: " NAMECLISITEF
	
	if [ -z "$NAMECLISITEF" ] || ! [[ "$NAMECLISITEF" =~ ^[0-9]+$ ]]; then
		echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; menuSitef
	fi
    if [ $NAMECLISITEF -eq 1 ]; then
		libSitefVrs=LibSitef_Atual
		internetConnectionCheck
	fi

    if [ $NAMECLISITEF -eq 2 ]; then
		libSitefVrs=LibSitef_Teste
		internetConnectionCheck
	fi
	
	if [ $NAMECLISITEF -eq 3 ]; then	
		menuOptions
	fi
	
	if [ $NAMECLISITEF -ge 4 ]; then
		if [ $NAMECLISITEF -le 98 ]; then	
		echo -e "\n${R1}Opcao incorreta, retornando ao menu Sitef${End}" ; pause ; menuSitef
		fi
	fi
		
	if [ $NAMECLISITEF -eq 99 ]; then	
		exit
	fi

fi
	
	if [ -d "$DIRCLISITEF" ]; then
        printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $DIRCLISITEF 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $DIRCLISITEF 2>/dev/null
	else
		printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $DIRCLISITEF 2>/dev/null
    fi
		
	EXTRACT1="$DIRCLISITEF/linuxclisitef.zip"
	
	echo ""
	echo "Baixando libs SiTef..."
    printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $URLSITEF -O $EXTRACT1 2>/dev/null
		if [ $? -ne 0 ] || [ ! -s $EXTRACT1 ]; then
			echo "" ; echo -e "${R1}Erro DOWNLOAD Libs Sitef${End}" ; pause ; menuOptions
		fi

	echo "Realizando backup libs Sitef em /pdv/util..."
	date=$(date '+%Y-%m-%d_%H:%M:%S')
	siteflibfolder=$bkp_LibSitef/Bkp_LibSitef_UsrLib-$date
	printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $siteflibfolder 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' cp /usr/lib/{Cheque.txt,Leiame.txt,lgpl-2.1.txt,libclisitef.so,libcurl_LICENSE.txt,libcurl32.so,libemv.so,libpng_LICENSE.txt,libqrencode_LICENSE.txt,libqrencode32.so,rechargeRPC.so,RELEASE.TXT} $siteflibfolder 2>/dev/null

	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R $siteflibfolder 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R $siteflibfolder 2>/dev/null
	
	DATEYMD=$(date '+%Y-%m-%d')
	printf '%s\n' "$PASSWD" | sudo -S -p '' zip -r $bkp_LibSitef/Bkp_LibSitef_UsrLib-$DATEYMD.zip $siteflibfolder >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $siteflibfolder 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R $bkp_LibSitef/Bkp_LibSitef_UsrLib-$DATEYMD.zip 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" $bkp_LibSitef/Bkp_LibSitef_UsrLib-$DATEYMD.zip 2>/dev/null

	echo "Atualizando arquivos..."
	printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $DIRCLISITEF 2>/dev/null
    printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o $EXTRACT1 -d $DIRCLISITEF 2>/dev/null
		if [ $? -ne 0 ]; then
			echo "" ; echo -e "${R1}Erro EXTRAIR Libs Sitef${End}" ; pause ; printf "\n\n" ; menuOptions
		fi
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $EXTRACT1 2>/dev/null
    printf '%s\n' "$PASSWD" | sudo -S -p '' chmod -R 777 $DIRCLISITEF 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R $DIRCLISITEF 2>/dev/null
    printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p $DIRCLISITEF/$libSitefVrs/* /usr/lib 2>/dev/null
		if [ $? -ne 0 ]; then
			checkClisitef=0
			echo "" ; echo -e "${R1}Erro COPIAR Libs Sitef${End}" ; pause ; printf "\n\n" ; menuOptions
		else
			checkClisitef=1
		fi
    printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $DIRCLISITEF 2>/dev/null
	
	echo -e "Deletando arquivos CliSiTef.ini e CONFITLS.INI e Dlls/Libs de pastas nao padrao . . ."
	checkSitefFiles

	echo "Definindo caminho de dmps para /home/$USER/CliSiTef/ChavesCliSiTef ..."
	if [ ! -e "/usr/lib/CliSiTef.ini" ]; then
		novoClisitefIni
	fi
	removerLinhasCliSiTef "[SalvaEstado]" "DiretorioBase=/home/$USER/CliSiTef/ChavesCliSiTef" "DiretorioBase=/home/$USER/CliSiTef" "DiretorioTrace=/home/$USER/CliSiTef"
	setcheckvariable=1
	setCargaSitefFolder_default
	setTraceDMPSitefFolder_default

	echo "Renomeando ChavesClistef Linux ..."
	if [ $setcheckvariable -ne 1 ]; then
		setcheckvariable=1
		renomearchavesclisitef
	else
		renomearchavesclisitef
	fi	

	createRegisterLog "libSitefVrs"

	if [ $checkClisitef -eq 1 ]; then 
	echo -e "\n${B1}Libs Sitef Atualizadas.${End}"
	else echo -e "\n${R1}Libs Sitef NAO tualizadas.${End}"
	fi
}

remover_arquivo() {
    # Verifica se há pelo menos dois argumentos (arquivos e caminhos)
    if [ "$#" -lt 2 ]; then
        return 1
    fi

    local arquivos=()
    local caminhos=()
    local encontrou_caminho=0

    # Separa os argumentos entre arquivos e caminhos
    for arg in "$@"; do
        if [ -d "$arg" ] || [[ "$arg" == /* ]]; then
            encontrou_caminho=1
        fi

        if [ "$encontrou_caminho" -eq 0 ]; then
            arquivos+=("$arg")
        else
            caminhos+=("$arg")
        fi
    done

    # Se não houver caminhos informados, aborta silenciosamente
    if [ "${#caminhos[@]}" -eq 0 ]; then
        return 1
    fi

    # Percorre arquivos e caminhos para remover
    for nome_arquivo in "${arquivos[@]}"; do
        for caminho in "${caminhos[@]}"; do
            find "$caminho" -type f -name "$nome_arquivo" -exec rm -f {} + 2>/dev/null
        done
    done
}

jclisitef() {
	echo ""
	echo -e "${C1}[ Atualizando jCliSiTef (libjCliSiTefI.so) ]${End}"

	libslinux=jclisitef

	if [ -d "$TMP_LIB" ]; then
      printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $TMP_LIB 2>/dev/null
    fi
	printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $TMP_LIB 2>/dev/null
	
	echo "Baixando Libs"
	printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $URLLIBS -O $TMP_LIB/libs.zip 2>/dev/null 
		if [ $? -ne 0 ] || [ ! -s $TMP_LIB/libs.zip ]; then
		echo "" ; echo -e "${R1}Erro ao fazer download de Libs/jClisitef pdv${End}" ; pause ; menuOptions
		fi

	echo "Extraindo jCliSiTef ..."
	printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o $TMP_LIB/libs.zip -d $TMP_LIB 2>/dev/null
	if [ $? -ne 0 ]; then
		echo "" ; echo -e "${R1}Erro ao Extrair Libs/jClisitef $libslinux${End}" ; pause ; menuOptions
	fi
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod -R 777 $TMP_LIB/* 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" -R $TMP_LIB/* 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -f $TMP_LIB/libs.zip 2>/dev/null
	
	echo "Copiando jCliSiTef para /usr/lib ..."
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p $TMP_LIB/$libslinux/* /usr/lib 2>/dev/null
	if [ $? -eq 0 ]; then
		echo "" ; finished
	fi
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $TMP_LIB 2>/dev/null
	
	createRegisterLog "Lib_JCliSiTef"
}

check_glibc() {
    # version=$(ldd --version | grep -oP '\d+\.\d+' | head -n1)
    
    warnningInteraction
    sudo apt update
	sudo apt-get -y binutils

    echo "================================================================================"
    
	objdump_version=$(objdump --version)  # Obtém a versão corretamente
	objdump_version_num=$(echo "$objdump_version" | grep -Eo '[0-9]+\.[0-9]+')

    if [[ "$(echo "$objdump_version_num < 2.2" | bc -l)" -eq 1 ]]; then
		echo -e "\nVersão GLIBC desatualizada e abaixo da recomendada 2.17 (mínima recomendada pela Sitef)"
        update_check_glibc
    else
        echo -e "\n${G1} - clock_gettime encontrado com GLIBC $objdump_version_num, compatível. (Versao minima, 2.17)${End}"
    fi
}

update_check_glibc() {

	echo ""
	echo -e "Atualizar GLIBC ?"
	echo -e "1. SIM - Atualizar"
	echo -e "${LNFP}2. NAO - NAO Atualizar e retornar ao menu Geral${End}"
    read -p "Escolha o tipo de ajuste: " GLIBCOPT
	
	if [ -z "$GLIBCOPT" ] || ! [[ "$GLIBCOPT" =~ ^[0-9]+$ ]]; then
		echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 1 ; update_check_glibc
	fi
    if [ $GLIBCOPT -eq 1 ]; then
		echo ""
		echo -e "[Realizando atualizacao do 'libc6']\n"
		warnningInteraction
		aptLockFix
		sudo apt update
		sudo dpkg --configure -a
		sudo apt-get -y --fix-broken install
		sudo apt-get -f -y install
        sudo ldconfig
		aptLockFix
		sudo apt-get -yq install --only-upgrade libc6:i386
		
		objdump_version_num=$(echo "$objdump_version" | grep -Eo '[0-9]+\.[0-9]+')

		if [[ "$(echo "$objdump_version_num < 2.2" | bc -l)" -eq 1 ]]; then
			echo -e "\nVersão GLIBC desatualizada e abaixo da recomendada 2.17 (mínima recomendada pela Sitef)\n${R1}"
			pause
		else
			echo -e "\nVersao GLIBC >= a 2.2\nclock_gettime encontrado com GLIBC ${objdump_version_num}, compatível."
			pause
		fi
	fi
    if [ $GLIBCOPT -eq 2 ]; then
		menuOptions
	fi
	if [ $GLIBCOPT -ge 3 ]; then
		echo -e "\n${R1}Opcao incorreta, retornando ao menu Update GLIBC${End}" ; sleep 1 ; update_check_glibc
	fi
}

vpnSitefExpress() {
	clear
	echo ""
	echo "Instalacao/Reinstalacao VPN Sitef Express (Nova VPN TLS)"
	killApp java
	
	
	if [ -e "/usr/lib/systemd/system/libssl.service" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' systemctl -q is-active libssl.service
		if [ $? -eq 0 ]; then
			echo "Desativando Gsurf . . ."
			printf '%s\n' "$PASSWD" | sudo -S -p '' systemctl stop libssl.service 2>/dev/null
			printf '%s\n' "$PASSWD" | sudo -S -p '' systemctl disable libssl.service 2>/dev/null
		fi
	fi
	if [ -e "/usr/gsurf/gsurfcli.txt" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' mv /usr/gsurf/ /usr/gsurf_old/ 2>/dev/null
	fi
	
	if [ -e "/usr/lib/CONFITLS.INI" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /usr/lib/CONFITLS.INI 2>/dev/null
	elif [ -e "/usr/lib/CONFITLS.ini" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /usr/lib/CONFITLS.ini 2>/dev/null
	fi
	if [ -e "/pdv/util/CONFITLS.INI" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/util/CONFITLS.INI 2>/dev/null
	elif [ -e "/pdv/util/CONFITLS.ini" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/util/CONFITLS.ini 2>/dev/null
	fi
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/home/$USER/CliSiTef/ChavesCliSiTef/NaoExcluirControleCliSiTef" >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/home/$USER/CliSiTef/ChavesCliSiTef" >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/home/$USER/CliSiTef >/dev/null" 2>&1

	# Define caminho padrao ChavesClisitef
	removerLinhasCliSiTef "[SalvaEstado]" "DiretorioBase=/home/$USER/CliSiTef/ChavesCliSiTef" "DiretorioBase=/home/$USER/CliSiTef" "DiretorioTrace=/home/$USER/CliSiTef"
	setcheckvariable=1
	setCargaSitefFolder_default
	setTraceDMPSitefFolder_default
	
	echo ""
	echo "Cliente utiliza PROXY ?"
	echo -e "${R1}1. SIM${End}"
    echo -e "${B1}2. NAO${End}"
    read -p "Escolha opcao para prosseguir: " OPTVPNLOCAL
	echo ""
	read -p "INFORME O TOKEN GERADO NO PORTAL SITEF EXPRESS: " TOKENVPNEXPRESS

	if [ -z "$OPTVPNLOCAL" ] || ! [[ "$OPTVPNLOCAL" =~ ^[0-9]+$ ]]; then
		echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; menuOptions
	fi
	if [ $OPTVPNLOCAL -eq 1 ]; then
		echo ""
		read -p "Informe o IP do Proxy: " PROXYIP
		read -p "Informe a PORTA do Proxy: " PROXYPORTA
		
		echo "[ConfiguracaoTLS]" >> /pdv/util/CONFITLS.INI
		echo "TipoComunicacaoExterna=TLSGWP" >> /pdv/util/CONFITLS.INI
		echo "URLTLS=tls-prod.fiservapp.com" >> /pdv/util/CONFITLS.INI
		echo "GwpTipoProxy=http" >> /pdv/util/CONFITLS.INI
		echo "GwpEnderecoProxy=$PROXYIP:$PROXYPORTA" >> /pdv/util/CONFITLS.INI
		echo "TokenRegistro=$TOKENVPNEXPRESS" >> /pdv/util/CONFITLS.INI
	fi
	if [ $OPTVPNLOCAL -eq 2 ]; then	
		echo "[ConfiguracaoTLS]" >> /pdv/util/CONFITLS.INI
		echo "TipoComunicacaoExterna=TLSGWP" >> /pdv/util/CONFITLS.INI
		echo "URLTLS=tls-prod.fiservapp.com" >> /pdv/util/CONFITLS.INI
		echo "TokenRegistro=$TOKENVPNEXPRESS" >> /pdv/util/CONFITLS.INI
	fi
	if [ $OPTVPNLOCAL -ge 3 ]; then
		echo -e "\n${R1}Opcao incorreta, retornando ao menu Sitef${End}" ; pause ; menuOptions
	fi
	
	# Atualizar/Inserir Token em vr.properties
	update_or_add_tokentls "/vr/vr.properties" "$TOKENVPNEXPRESS"

	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /pdv/util/CONFITLS.INI 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" /pdv/util/CONFITLS.INI 2>/dev/null
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p /pdv/util/CONFITLS.INI /usr/lib 2>/dev/null
	
	if [ -e "/usr/lib/CONFITLS.INI" ]; then
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/util/CONFITLS.INI >/dev/null 2>&1
	fi
	
	echo -e "\n======================\nAtualizando Libs SITEF\n======================\n"
	
	echo -e "Deletando arquivos em /home/$USER/CliSiTef/ChavesCliSiTef"
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /home/$USER/CliSiTef >/dev/null 2>&1
	setcheckvariable=1
	libSitefVrs=LibSitef_Atual
	atualizarClisitef
	
	if [ -e "/usr/lib/CliSiTef.ini" ]; then
		if [ -e "/usr/lib/CONFITLS.INI" ]; then
			checkVPNTEF

			echo ""
			echo "------------------------------------"
			echo -e "${B1}VPN Sitef Express TLS Instalado com sucesso${End}"
			echo -e "${COLOR_VR}Token_VRProperties:${End} $TOKEN_VR | ${COLOR_CONFITLS}Token_ConfiTLS:${End} $TOKEN_CONFITLS "
			echo -e "${B1}Em caso de erros, reinicie a maquina${End}"
			echo -e "------------------------------------\n"
		
			createRegisterLog "VPNSitefExpress_Install"
		else 
			echo -e "\n${R1}Falha ao criar /usr/lib/CONFITLS.INI, verifique e realize o processo novamente${End}"
			createRegisterLog "Falha_VPNSitefExpress_Install"
		fi
	else 
		echo -e "\n${R1}Arquivo /usr/lib/CliSiTef.ini nao existe\nExecute o script novamente e use a opcao 1 e depois opcao 7 para baixa-lo e reinicie a instalacao da VPN TLS${End}"
		createRegisterLog "Falha_VPNSitefExpress_Install"
	fi
}

update_or_add_tokentls() {
    local file="$1"    # Primeiro argumento: caminho do arquivo
    local value="$2"   # Segundo argumento: valor para substituir ou adicionar

    # Verifica se a linha existe
    if grep -q '^tokentls=' "$file"; then
        # Substitui o valor existente
        sed -i "s/^tokentls=.*/tokentls=$value/" "$file"
    else
        # Adiciona a linha ao final do arquivo
        echo "tokentls=$value" >> "$file"
    fi
}

extract_tokenTLS() {
    local file="$1"      # Caminho do arquivo
    local key="$2"       # Chave a ser procurada
    local var_name="$3"  # Nome da variável para armazenar o valor
    
    if [[ -f "$file" ]]; then
        # Extrai o valor da chave de forma silenciosa
        local value
        value=$(grep -oP "^\s*${key}=\K.*" "$file" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' 2>/dev/null || true)
        
        if [[ -n "$value" ]]; then
            printf -v "$var_name" "%s" "$value"
        else
            printf -v "$var_name" ""
        fi
    else
        printf -v "$var_name" ""
    fi
}

set_tokenTLS_extracted() {

	extract_tokenTLS "/vr/vr.properties" "tokentls" TOKEN_VR
	extract_tokenTLS "/usr/lib/CONFITLS.INI" "TokenRegistro" TOKEN_CONFITLS

	if [[ -z "$TOKEN_VR" ]]; then
		COLOR_VR="$NORMAL"
	else
		COLOR_VR="$G1"
	fi

	if [[ -z "$TOKEN_CONFITLS" ]]; then
		COLOR_CONFITLS="$NORMAL"
		COLOR_TLS_FILE="$NORMAL"
		VPNSTATUS=""
	else
		COLOR_CONFITLS="$G1"
		COLOR_TLS_FILE="$G1"
		VPNSTATUS="${B1}VPN Sitef Express (TLS) Ativada${End}"
	fi

}

removerLinhas_TokenTLS() {
    local ARQUIVO="$1"

    # Deleta CONFITLS.INI
    printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/usr/lib/CONFITLS.INI" 2>/dev/null

    # Verifica se um arquivo foi informado
    if [ -z "$ARQUIVO" ]; then
        return
    fi

    # Remove linhas que começam com "tokentls=", ignorando maiúsculas/minúsculas
    printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i '/^[Tt][Oo][Kk][Ee][Nn][Tt][Ll][Ss]=/d' "$ARQUIVO" 2>/dev/null
}

checkVPNTEF() {
set_tokenTLS_extracted
}

novoClisitefIni() {
	clisitefinifolder=$bkp_LibSitef/Bkp_CliSitefINI-$date

	printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $URLCLISITEFINI -O $path/CliSiTef.ini 2>/dev/null
	if [ $? -ne 0 ] || [ ! -s $path/CliSiTef.ini ]; then
		clear ; echo "" ; echo -e "${R1}Erro Realizar Download $path/CliSiTef.ini{End}" ; pause ; printf "\n\n" ; menuOptions
	fi
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $path/CliSiTef.ini 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" $path/CliSiTef.ini 2>/dev/null
	if [ -e "/usr/lib/CliSiTef.ini" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $clisitefinifolder 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' mv /usr/lib/CliSiTef.ini $clisitefinifolder 2>/dev/null
	fi
	printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p $path/CliSiTef.ini /usr/lib 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $path/CliSiTef.ini >/dev/null 2>&1
	createRegisterLog "NovaClisitefINI"
	
	removerLinhasCliSiTef "[SalvaEstado]" "DiretorioBase=/home/$USER/CliSiTef/ChavesCliSiTef" "DiretorioBase=/home/$USER/CliSiTef" "DiretorioTrace=/home/$USER/CliSiTef"
	setcheckvariable=1
	setCargaSitefFolder_default
	setTraceDMPSitefFolder_default
}

setCargaSitefFolder_default() {
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /usr/lib/CliSiTef.ini 2>/dev/null
	# Linhas a serem verificadas e inseridas
	LINHA1="[SalvaEstado]"
	LINHA2="DiretorioBase=/home/$USER/CliSiTef"

	# Arquivo alvo
	ARQUIVO1="/usr/lib/CliSiTef.ini"
	
	# Adicionar ou substituir as linhas diretamente no arquivo
	if ! grep -q "$LINHA2" "$ARQUIVO1" >/dev/null 2>&1; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i "/$(echo "$LINHA1" | sed 's/[^a-zA-Z0-9]/\\&/g')/d; /$(echo "$LINHA2" | sed 's/[^a-zA-Z0-9]/\\&/g')/d; s/^[[:space:]]*//" "$ARQUIVO1"

		if [ $? -ne 0 ]; then
			echo -e "\n\n Falha ao remover linhas do setCargaSitefFolder_default"
			pause
			menuOptions
		else 
			echo -e "$LINHA1\n$LINHA2" >> "$ARQUIVO1"
			printf '%s\n' "$PASSWD" | sudo -S -p '' awk '!NF {if (++count <= 1) print ""; next} {count=0} 1' $ARQUIVO1 > /tmp/awk1_tmpfile && printf '%s\n' "$PASSWD" | sudo -S -p '' mv /tmp/awk1_tmpfile $ARQUIVO1
			printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $ARQUIVO1 2>/dev/null
		fi

		if [ $setcheckvariable -ne 1 ]; then
			createRegisterLog "setCargaSitefFolder_default"
			echo "" ; echo -e "${C2}PROCESSO ENCERRADO${End}"
		fi
	fi
}

setTraceDMPSitefFolder_default() {
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /usr/lib/CliSiTef.ini 2>/dev/null
		# Linhas a serem removidas e adicionadas
		LINHA3="[CliSiTef]"
		LINHA4="HabilitaTrace=1"
		LINHA5="DiretorioTrace=/home/$USER/CliSiTef"
		LINHA6="[CliSiTefI]"
		LINHA7="HabilitaTrace=1"

		# Arquivo alvo
		ARQUIVO2="/usr/lib/CliSiTef.ini"

if ! grep -q "$LINHA5" "$ARQUIVO2" >/dev/null 2>&1; then
		# Adicionar ou substituir as linhas diretamente no arquivo
		printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i "/$(echo "$LINHA3" | sed 's/[^a-zA-Z0-9]/\\&/g')/d; /$(echo "$LINHA4" | sed 's/[^a-zA-Z0-9]/\\&/g')/d; /$(echo "$LINHA5" | sed 's/[^a-zA-Z0-9]/\\&/g')/d; /$(echo "$LINHA6" | sed 's/[^a-zA-Z0-9]/\\&/g')/d; /$(echo "$LINHA7" | sed 's/[^a-zA-Z0-9]/\\&/g')/d" "$ARQUIVO2"

		if [ $? -ne 0 ]; then
			echo -e "\n\n Falha ao remover linhas do setTraceDMPSitefFolder_default"
			pause
			exit
		else 
			echo -e "$LINHA3\n$LINHA4\n$LINHA5\n$LINHA6\n$LINHA7" >> "$ARQUIVO2"
			printf '%s\n' "$PASSWD" | sudo -S -p '' awk '!NF {if (++count <= 1) print ""; next} {count=0} 1' $ARQUIVO2 > /tmp/awk2_tmpfile && printf '%s\n' "$PASSWD" | sudo -S -p '' mv /tmp/awk2_tmpfile $ARQUIVO2
			printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $ARQUIVO2 2>/dev/null
		fi

	if [ $setcheckvariable -ne 1 ]; then
		createRegisterLog "setTraceDMPSitefFolder_default"
		echo "" ; echo -e "${C2}PROCESSO ENCERRADO${End}"
	fi
fi
}

removerLinhasCliSiTef() {
    local ARQUIVO="/usr/lib/CliSiTef.ini"

    # Verifica se pelo menos um argumento foi passado
    if [ "$#" -eq 0 ]; then
        return
    fi

    # Monta a expressão sed dinamicamente com base nos argumentos
    local SED_CMD=""
    for padrao in "$@"; do
        SED_CMD+="\|^$padrao$|d; " # remove apenas o que for informado na chamada
    done

    # Executa o sed com privilégio de superusuário
    printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i "$SED_CMD" "$ARQUIVO" 2>/dev/null
}

bkpDmps() {
	date=$(date '+%Y-%m-%d_%H:%M:%S')
	printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 "/pdv/util/BKP_DMPs/BKP-$date/DMPS_HomeFolder" 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R "/pdv/util/BKP_DMPs" >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R "/pdv/util/BKP_DMPs" >/dev/null 2>&1

	printf '%s\n' "$PASSWD" | sudo -S -p '' cp -r "/home/$USER/CliSiTef" "/pdv/util/BKP_DMPs/BKP-$date" 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' cp "/home/$USER"/*.dmp "/pdv/util/BKP_DMPs/BKP-$date/DMPS_HomeFolder" 2>/dev/null

	if [ -d "/tmp/CliSiTef" ]; then
	printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 "/pdv/util/BKP_DMPs/BKP-$date/DMPS_TMPFolder" 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' cp -r "/tmp/CliSiTef" "/pdv/util/BKP_DMPs/BKP-$date/DMPS_TMPFolder" 2>/dev/null
	fi

	if [ -d "/tmp/ChavesCliSiTef" ]; then
	printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 "/pdv/util/BKP_DMPs/BKP-$date/DMPS_TMPFolder" 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' cp -r "/tmp/ChavesCliSiTef" "/pdv/util/BKP_DMPs/BKP-$date/DMPS_TMPFolder" 2>/dev/null
	fi

	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R "/pdv/util/BKP_DMPs/" >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R "/pdv/util/BKP_DMPs/" >/dev/null 2>&1
}

ativarCarteiraDigital() {

echo -e "\nAdicionando ;7;8 e renomeando pasta de Carga de Tabelas . . ."

	ARQUIVO="/usr/lib/CliSiTef.ini"
	TEXTO_ADICIONAL=";7;8"

# Função para adicionar texto se não estiver presente
add_text_if_missing() {
  grep -q "$1.*$TEXTO_ADICIONAL" "$ARQUIVO" || printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i "/$1/s/\$/ $TEXTO_ADICIONAL/" "$ARQUIVO" 2>/dev/null
}

add_text_if_missing "^TransacoesAdicionaisHabilitadas="
add_text_if_missing "^TransacoesHabilitadas="

	# Funcao Renomeia ChavesCliSitef
	renomearchavesclisitef

	createRegisterLog "AtivaCarteiraDigital"
	echo "" ; echo -e "${C2}PROCESSO ENCERRADO${End}"
}

add_3624_Clisitef_CargaTabelasManual() {
    ARQUIVO="/usr/lib/CliSiTef.ini"
    TEXTO_ADICIONAL=";3624"

    # Função para adicionar texto se não estiver presente
    add_text_if_missing() {
        grep -q "$1.*$TEXTO_ADICIONAL" "$ARQUIVO" || \
        printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i "/$1/s/[[:space:]]*$/$TEXTO_ADICIONAL/" "$ARQUIVO" 2>/dev/null
    }

    add_text_if_missing "^TransacoesAdicionaisHabilitadas="
}

numerodiasLogDMP() {
	ARQUIVO="/usr/lib/CliSiTef.ini"

    # Verifica se a linha com "NumeroDeDiasNoLog=120" já existe
    grep -q "NumeroDeDiasNoLog=15" "$ARQUIVO" || {
      # Caso não exista, adiciona a linha logo abaixo da linha que contém "[Geral]"
      printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i "/\[Geral\]/a NumeroDeDiasNoLog=15" "$ARQUIVO" 2>/dev/null
    }
	
	createRegisterLog "Ativar15DiasLogDMP"
}

renomearchavesclisitef() {
	if [ $setcheckvariable -ne 1 ]; then
		echo ""
		echo "Renomeando ChavesClistef Linux ..."
	fi

	killApp java
	bkpDmps
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/pdv/exec"/*.dmp >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/home/$USER"/*.dmp >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/usr"/*.dmp >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/home/$USER/CliSiTef/ChavesCliSiTef"/*.dmp >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/home/$USER/CliSiTef"/*.dmp >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/tmp"/*.dmp >/dev/null 2>&1

	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/tmp/CliSiTef" >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/tmp/ChavesCliSiTef" >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/home/$USER/CliSiTef/ChavesCliSiTef/ChavesCliSiTef" >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/home/$USER/CliSiTef/ChavesCliSiTef" >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/home/$USER/ChavesClisitef" >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/home/$USER/ChavesCliSiTef" >/dev/null 2>&1

	echo -e "\n${B1}ChavesCliSitef renomeada com sucesso.${End}"
}

check_tls_connection() {
    local host1="tls-prod.fiservapp.com"
	local host2="66.22.76.37"
    local port="443"
	e
	echo -e "\nRealizando teste de conexao TLS . . . Aguarde . . ."
	echo -e "\ntelnet \"\$host1\" \"$port\""
    # Testa conexão com telnet e verifica se conectou com sucesso
    if echo -e "QUIT" | telnet "$host1" "$port" | grep -q "Connected to"; then
        echo -e "\n${B1}Conexão bem-sucedida com $host1:$port${End}"
    else
        # notify-send "Alerta" "Falha ao conectar em $host1:$port"
        echo -e "\n${R1}Erro: Não foi possível conectar em $host1:$port${End}"
    fi
	
	echo -e "\nRealizando teste de conexao TLS . . . Aguarde . . ."
	echo -e "\ntelnet "$host1" "$port""
    if echo -e "QUIT" | telnet "$host2" "$port" | grep -q "Connected to"; then
        echo -e "\n${B1}Conexão bem-sucedida com $host2:$port${End}"
    else
        # notify-send "Alerta" "Falha ao conectar em $host2:$port"
        echo -e "\n${R1}Erro: Não foi possível conectar em $host2:$port${End}"
    fi
}

atualizarLibsPDV() {
	if [ $setcheckvariable -ne 1 ]; then
	internetConnectionCheck
		clear
		echo ""
		echo "Atualizacao de Libs PDV"
			echo "---------------------"
			echo "[1] Libs Sat Elgin Smart"
			echo "[2] Libs Sat Dimep"
			echo "[3] Libs Sat EpsonGertec"
			echo "[4] Libs Originais - Primeira Instalacao ISO 18.04_x86"
			echo "[5] Libs Impressora EpsonTMT20/20X"
			echo "[6] Libs Teclado Smak SKO-44(Atualizadas SiteFabricante)"
			echo "[7] Lib 'libGCPlug.so' para Cameras Gunnebo"
			echo -e "${G1}[8] Libs Gerais VR atualizadas${End}"
			echo "[9] Ajuste SAT TANCA - Cria Arquivo sat.ini"
			echo -e "${LNFP}[10] Retornar Menu Principal${End}"
			echo "---------------------"
			read -p "Escolha qual Pacote de Libs deseja: " OPTLIBS
			
		case $OPTLIBS in
			1) libslinux=elginsmart ;;
			 
			2) libslinux=dimep-latest ;;
			 
			3) libslinux=epsongertec ;;
			
			4) libslinux=libsoriginais_18.04_x86 ;;

			5) libslinux=tmt20 ;;
			
			6) libslinux=tecladosmak ;;
			
			7) libslinux=libgunnebo ;;
			
			8) libslinux=vrdefault ;;
			
			9) tancafile && pause && menuOptions ;;
			
			10) menuOptions ;;
			
			*) echo -e "\n${R1}Opcao incorreta${End}" ; pause ; atualizarLibsPDV ;;
		esac
		
	fi
	
	killApp java
	
	# Executa configurador da funcao tancafile
	setcheckvariable=1
	tancafile
	
	if [ -d "$TMP_LIB" ]; then
      printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $TMP_LIB 2>/dev/null
    fi
	printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $TMP_LIB 2>/dev/null
	
	echo "Baixando Libs"
	printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $URLLIBS -O $TMP_LIB/libs.zip 2>/dev/null 
		if [ $? -ne 0 ] || [ ! -s $TMP_LIB/libs.zip ]; then
			clear ; echo "" ; echo -e "${R1}Erro ao fazer download de Libs pdv${End}" ; pause ; printf "\n\n" ; menuOptions
		fi
	
	echo "Realizando Backup de Libs em /pdv/util"
	date=$(date '+%Y-%m-%d_%H:%M:%S')
	usrlibfolder=$bkp_UsrLib/Bkp_UsrLib-$date
	printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $usrlibfolder >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' cp /usr/lib/{99-tanca.rules,bemasat.xml,CONVERSOR.ini,DarumaFrameWork.xml,ftrWSQ.so,libBemaSAT32.so,libcidbio.so,libcidbio.so.0,libconvecf.so,libDarumaFramework.a,libDarumaFramework.so,libdllsat.so,libdllsat_elgin.so,libftrJavaScanAPI.so,libGNE_Framework.so,libinpout32.so,libInterfaceEpsonNF.dll.so,liblebin.so,libLeituraMFDBin.so,libmkse.so,libQrCode_DarumaFramework.so,librxtxParallel.so,librxtxSerial.so,librxtxSerial_64.so,libsat.a,libsat.so,libsat_daruma.so,libSATDLL.so,libSatGer.conf,libSatGer.so,libsatid.so.1.2.3,libScanAPI.so,libseppemv.so,libsk_access.so,libsk_access_tcp.so,libusb-1.0.so.0.1.0.22,sk_access.h,sk_access.inc,sk_access_tcp.h,sk_access_tcp.inc,TCP_Server,use_sk_access,libswmfd.so,libswmfd.so.0,libtec_linux.so,libWS_Framework.so,mp2032,SI300,libNBioBSP.so,libNBioBSPISO4JNI.so,libNBioBSPJNI.so,libGCPlug.so} $usrlibfolder 2>/dev/null
	
	DATEYMD=$(date '+%Y-%m-%d')
	printf '%s\n' "$PASSWD" | sudo -S -p '' zip -r $bkp_UsrLib/Bkp_UsrLib-$DATEYMD.zip $usrlibfolder >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $usrlibfolder 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R $bkp_UsrLib/Bkp_UsrLib-$DATEYMD.zip 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" $bkp_UsrLib/Bkp_UsrLib-$DATEYMD.zip 2>/dev/null
	
	
	if [[ "${LINUX_VERSION}" == "20.04" ]]; then
		echo "Deletando Libs em /usr/lib32 e e/usr/lib64"
		checkLibsFolders_usr32_usr64
		if [[ "${libslinux}" == "epsongertec" ]]; then
			satEpsonGertec
		fi
	fi

	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R $usrlibfolder >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" -R $usrlibfolder >/dev/null 2>&1
	
	echo "Extraindo arquivos ..."
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o $TMP_LIB/libs.zip -d $TMP_LIB 2>/dev/null
		if [ $? -ne 0 ]; then
		clear ; echo "" ; echo -e "${R1}Erro ao Extrair Libs $libslinux${End}" ; pause ; printf "\n\n" ; menuOptions
		fi
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod -R 777 $TMP_LIB/* 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" -R $TMP_LIB/* 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -f $TMP_LIB/libs.zip 2>/dev/null
	
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
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $filelibssitef_delete >/dev/null 2>&1
	fi
	done

	echo "Copiando arquivos /usr/lib ..."
	
	arquivosClisitef=("/pdv/sat/CliSiTef.ini" "/pdv/driver/CliSiTef.ini" "/usr/lib/CliSiTef.ini")
	for arquivoClisitef in "${arquivosClisitef[@]}"; do
    if [ -e "$arquivoClisitef" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $TMP_LIB/$libslinux/CliSiTef.ini 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/sat/CliSiTef.ini 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/driver/CliSiTef.ini 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $HOME/CliSiTef.ini 2>/dev/null
	fi
	done

	if [ ! -e "/pdv/exec/CONVERSOR.ini" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p $TMP_LIB/$libslinux/CONVERSOR.ini /pdv/exec 2>/dev/null
	fi

	if [ ! -e "/home/$USER/CONVERSOR.ini" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p $TMP_LIB/$libslinux/CONVERSOR.ini /home/$USER 2>/dev/null
	fi	
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $TMP_LIB/$libslinux/CONVERSOR.ini 2>/dev/null
	
	# Copiando Libs
	printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p $TMP_LIB/$libslinux/* /usr/lib 2>/dev/null
	
	if [[ ${libslinux} != "libgunnebo" ]]; then
		echo "Copiando arquivos /pdv/sat e /pdv/driver..."
		printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p $TMP_LIB/$libslinux/* /pdv/sat 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p $TMP_LIB/$libslinux/* /pdv/driver 2>/dev/null
	fi
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $TMP_LIB 2>/dev/null

	createRegisterLog "LibsUpdate_$libslinux"
	# printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "Libs $libslinux atualizadas em $date" | sudo tee -a $logs_path/LibsUpdate_$libslinux-$date.txt >/dev/null 2>&1
	
	echo -e "\n${B1}Libs $libslinux Atualizadas.${End}"
}

satEpsonGertec() {
printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p /pdv/sat/libSatGer.conf /pdv/exec/ >/dev/null 2>&1

if ! grep -q "cd /pdv/exec" "/pdv/util/.scripts/pdv.sh" >/dev/null 2>&1; then
echo -e "[Realizando ajuste do pdv.sh devido uso de sat GERTEC/Epson]"
    if grep -q "java -jar /pdv/exec/VRPdv.jar" "/pdv/util/.scripts/pdv.sh" >/dev/null 2>&1; then
        printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i 's|java -jar /pdv/exec/VRPdv.jar|cd /pdv/exec\njava -jar VRPdv.jar|' "/pdv/util/.scripts/pdv.sh"
    elif grep -q "java -jar /pdv/exec/VRPdv.jar -selfcheckout" "/pdv/util/.scripts/pdv.sh" >/dev/null 2>&1; then
        printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i 's|java -jar /pdv/exec/VRPdv.jar -selfcheckout|cd /pdv/exec\njava -jar VRPdv.jar -selfcheckout|' "/pdv/util/.scripts/pdv.sh" >/dev/null 2>&1
    elif grep -q "java -jar /pdv/exec/VRPdv.jar -touchscreen" "/pdv/util/.scripts/pdv.sh" >/dev/null 2>&1; then
        printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i 's|java -jar /pdv/exec/VRPdv.jar -touchscreen|cd /pdv/exec\njava -jar VRPdv.jar -touchscreen|' "/pdv/util/.scripts/pdv.sh" >/dev/null 2>&1
    fi

    if grep -q "java -jar /pdv/exec/VRPdv.jar" "/pdv/util/.scripts/pdv_atraso.sh" >/dev/null 2>&1; then
        printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i 's|java -jar /pdv/exec/VRPdv.jar|cd /pdv/exec\njava -jar VRPdv.jar|' "/pdv/util/.scripts/pdv_atraso.sh" >/dev/null 2>&1
    elif grep -q "java -jar /pdv/exec/VRPdv.jar -selfcheckout" "/pdv/util/.scripts/pdv_atraso.sh" >/dev/null 2>&1; then
        printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i 's|java -jar /pdv/exec/VRPdv.jar -selfcheckout|cd /pdv/exec\njava -jar VRPdv.jar -selfcheckout|' "/pdv/util/.scripts/pdv_atraso.sh" >/dev/null 2>&1
    elif grep -q "java -jar /pdv/exec/VRPdv.jar -touchscreen" "/pdv/util/.scripts/pdv_atraso.sh" >/dev/null 2>&1; then
        printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i 's|java -jar /pdv/exec/VRPdv.jar -touchscreen|cd /pdv/exec\njava -jar VRPdv.jar -touchscreen|' "/pdv/util/.scripts/pdv_atraso.sh" >/dev/null 2>&1
    fi
fi
}

corrigirPermissoes() {
checkSitefFiles

if [ $setcheckvariable -ne 1 ]; then
	echo -e "${LNFP}======================================${End}"
	echo -e "${G1}Aplicando ajuste de Permissoes PDV ...${End}"
	echo -e "${LNFP}======================================${End}"
fi

	killApp java
	
	    # Permissoes para diretorios.
		echo -e "\nAplicando permissoes Firebird, Java, VRPdv.jar . . ."
		permissioesFirebird
		permissoesJava
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x /pdv/exec/VRPdv.jar 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" /pdv/exec/VRPdv.jar 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /pdv/exec/VRPdv.jar 2>/dev/null

		echo -e "Aplicando permissoes em /pdv, /home/$USER, /vr . . ."
		folders_permission=("/pdv" "/vr")
		for folder_permission in "${folders_permission[@]}"; do
			if [ -d "$folder_permission" ]; then
				printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R $folder_permission >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" -R $folder_permission >/dev/null 2>&1
			fi
		done

		folders_permission=("$HOME" "/home/$USER")
		for folder_permission in "${folders_permission[@]}"; do
			if [ -d "$folder_permission" ]; then
				printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $folder_permission >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" $folder_permission >/dev/null 2>&1
			fi
		done

		echo -e "Aplicando permissoes em "/home/$USER/PDV.FDB", /pdv/database/VR.FDB, /usr/lib/CliSiTef.ini  . . ."
		files_permission=("/home/$USER/PDV.FDB" "/pdv/database/VR.FDB" "/usr/lib/CliSiTef.ini")
		for file_permission in "${files_permission[@]}"; do
		if [ -e "$file_permission" ]; then
				printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $file_permission 2>/dev/null
				printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" -R $file_permission 2>/dev/null
			fi
		done
		
		echo -e "Aplicando permissoes em LibsPDV . . ."
		
		fileslibspdv=("/usr/lib/99-tanca.rules" "/usr/lib/bemasat.xml" "/usr/lib/CliSiTef.ini" "/usr/lib/CONVERSOR.ini" "/usr/lib/DarumaFrameWork.xml" "/usr/lib/ftrWSQ.so" "/usr/lib/libBemaSAT32.so" "/usr/lib/libcidbio.so" "/usr/lib/libcidbio.so.0" "/usr/lib/libclisitef.so" "/usr/lib/libconvecf.so" "/usr/lib/libDarumaFramework.a" "/usr/lib/libDarumaFramework.so" "/usr/lib/libdllsat.so" "/usr/lib/libdllsat_elgin.so" "/usr/lib/libemv.so" "/usr/lib/libftrJavaScanAPI.so" "/usr/lib/libGNE_Framework.so" "/usr/lib/libinpout32.so" "/usr/lib/libInterfaceEpsonNF.dll.so" "/usr/lib/libjCliSiTefI.so" "/usr/lib/liblebin.so" "/usr/lib/libLeituraMFDBin.so" "/usr/lib/libmkse.so" "/usr/lib/libQrCode_DarumaFramework.so" "/usr/lib/librxtxParallel.so" "/usr/lib/librxtxSerial.so" "/usr/lib/librxtxSerial_64.so" "/usr/lib/libsat.a" "/usr/lib/libsat.so" "/usr/lib/libsat_daruma.so" "/usr/lib/libSATDLL.so" "/usr/lib/libSatGer.conf" "/usr/lib/libSatGer.so" "/usr/lib/libsatid.so.1.2.3" "/usr/lib/libScanAPI.so" "/usr/lib/libseppemv.so" "/usr/lib/libsk_access.so" "/usr/lib/libsk_access_tcp.so" "/usr/lib/libusb-1.0.so.0.1.0.22" "/usr/lib/sk_access.h" "/usr/lib/sk_access.inc" "/usr/lib/sk_access_tcp.h" "/usr/lib/sk_access_tcp.inc" "/usr/lib/TCP_Server" "/usr/lib/use_sk_access" "/usr/lib/libswmfd.so" "/usr/lib/libswmfd.so.0" "/usr/lib/libtec_linux.so" "/usr/lib/libWS_Framework.so" "/usr/lib/mp2032" "/usr/lib/rechargeRPC.so" "/usr/lib/SI300" "/usr/lib/libNBioBSP.so" "/usr/lib/libNBioBSPISO4JNI.so" "/usr/lib/libNBioBSPJNI.so" "/usr/lib/libGCPlug.so")
		for filelibs_permission in "${fileslibspdv[@]}"; do
		if [ -e "$filelibs_permission" ]; then
			printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $filelibs_permission 2>/dev/null
			printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" $filelibs_permission 2>/dev/null
		fi
		done
		
		echo -e "Aplicando permissoes em LibsSitef . . ."
		fileslibssitef=("/usr/lib/Cheque.txt" "/usr/lib/Leiame.txt" "/usr/lib/lgpl-2.1.txt" "/usr/lib/libclisitef.so" "/usr/lib/libcurl_LICENSE.txt" "/usr/lib/libcurl32.so" "/usr/lib/libemv.so" "/usr/lib/libpng_LICENSE.txt" "/usr/lib/libqrencode_LICENSE.txt" "/usr/lib/libqrencode32.so" "/usr/lib/rechargeRPC.so" "/usr/lib/RELEASE.TXT")
		for filelibssitef_permission in "${fileslibssitef[@]}"; do
		if [ -e "$filelibssitef_permission" ]; then
			printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $filelibssitef_permission 2>/dev/null
			printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" $filelibssitef_permission 2>/dev/null
		fi
		done
		
		# Valida Grupos Firebird e afins
		gruposPDV

	createRegisterLog "PermissoesLinuxUpdate"
	# printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "Permissoes Linux atualizadas em $date" | sudo tee -a $logs_path/PermissoesLinuxUpdate-$date.txt 2>/dev/null

	echo -e "\n${B1}Permissionamento realizado com sucesso${End}"
}

permissioesFirebird() {
printf '%s\n' "$PASSWD" | sudo -S -p '' chmod -R u+s /opt/firebird 2>/dev/null
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
                printf '%s\n' "$PASSWD" | sudo -S -p '' chown firebird:firebird "$item" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 600 "$item" >/dev/null 2>&1
                ;;
            "/opt/firebird/bin"|"/opt/firebird/doc"|"/opt/firebird/help"|"/opt/firebird/include"|"/opt/firebird/intl"|"/opt/firebird/lib"|"/opt/firebird/plugins"|"/opt/firebird/UDF")
                # Diretórios que precisam de chown recursivo
                printf '%s\n' "$PASSWD" | sudo -S -p '' chown -R root:root "$item" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S -p '' chmod -R 755 "$item" >/dev/null 2>&1
                ;;
            "/opt/firebird")
                # Diretório principal sem recursão
                printf '%s\n' "$PASSWD" | sudo -S -p '' chown root:root "$item" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 755 "$item" >/dev/null 2>&1
                ;;
            "/opt/firebird/de_DE.msg"|"/opt/firebird/firebird.msg"|"/opt/firebird/fr_FR.msg"|"/opt/firebird/IDPLicense.txt"|"/opt/firebird/IPLicense.txt")
                printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 444 "$item" >/dev/null 2>&1
                ;;
            "/opt/firebird/examples")
                printf '%s\n' "$PASSWD" | sudo -S -p '' chmod -R 555 "$item" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S -p '' chown -R root:root "$item" >/dev/null 2>&1
                ;;
            "/opt/firebird/misc")
				printf '%s\n' "$PASSWD" | sudo -S -p '' chown root:root "$item" >/dev/null 2>&1
                printf '%s\n' "$PASSWD" | sudo -S -p '' chmod -R 700 "$item" >/dev/null 2>&1
                ;;
			"/opt/firebird/aliases.conf"|"/opt/firebird/fbtrace.conf"|"/opt/firebird/firebird.conf"|"/opt/firebird/README"|"/opt/firebird/WhatsNew")
                printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 644 "$item" >/dev/null 2>&1
				;;
            *)
                # Arquivos normais pertencentes ao root
                printf '%s\n' "$PASSWD" | sudo -S -p '' chown root:root "$item" >/dev/null 2>&1
                ;;
        esac
    fi
done

}

permissoesJava() {
printf '%s\n' "$PASSWD" | sudo -S -p '' chmod -R u+s /usr/lib/jvm 2>/dev/null
# Lista de arquivos e diretórios para chown e chmod
files_folders_perms=(
	"/usr/lib/jvm"
	"/usr/lib/jvm/java-8-openjdk-i386"
    "/usr/lib/jvm/java-8-openjdk-i386/bin"
    "/usr/lib/jvm/java-8-openjdk-i386/docs"
    "/usr/lib/jvm/java-8-openjdk-i386/jre"
    "/usr/lib/jvm/java-8-openjdk-i386/man"
    "/usr/lib/jvm/java-8-openjdk-i386/jre/bin"
    "/usr/lib/jvm/java-8-openjdk-i386/jre/bin/java"
    "/usr/lib/jvm/java-8-openjdk-i386/jre/bin/jjs"
    "/usr/lib/jvm/java-8-openjdk-i386/jre/bin/keytool"
    "/usr/lib/jvm/java-8-openjdk-i386/jre/bin/orbd"
    "/usr/lib/jvm/java-8-openjdk-i386/jre/bin/pack200"
    "/usr/lib/jvm/java-8-openjdk-i386/jre/bin/policytool"
    "/usr/lib/jvm/java-8-openjdk-i386/jre/bin/rmid"
    "/usr/lib/jvm/java-8-openjdk-i386/jre/bin/rmiregistry"
    "/usr/lib/jvm/java-8-openjdk-i386/jre/bin/servertool"
    "/usr/lib/jvm/java-8-openjdk-i386/jre/bin/tnameserv"
    "/usr/lib/jvm/java-8-openjdk-i386/jre/bin/unpack200"
)

# Aplicando chown e chmod conforme o tipo do item
for item in "${files_folders_perms[@]}"; do
    if [ -e "$item" ]; then
        case "$item" in
            "/usr/lib/jvm")
                # Diretório principal sem recursão
                printf '%s\n' "$PASSWD" | sudo -S -p '' chown root:root "$item" >/dev/null 2>&1
                printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 755 "$item" >/dev/null 2>&1
                ;;
            "/usr/lib/jvm/java-8-openjdk-i386/docs")
                # Link simbólico (não alterar permissões)
                ;;
            *)
                # Aplicar chown e chmod 4755 para arquivos e diretórios relevantes
                printf '%s\n' "$PASSWD" | sudo -S -p '' chown root:root "$item" >/dev/null 2>&1
                printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 4755 "$item" >/dev/null 2>&1
                ;;
        esac
    fi
done
}

gruposPDV() {
	echo -e "Aplicando permissoes de Grupos . . ."
	createRegisterLog "GruposPDV"

	USER="${USER:-$(whoami)}"

	check_and_install_package() {
		local pkg="$1"
		local date=$(date '+%Y-%m-%d_%H:%M:%S')
		if dpkg -s "$pkg" &>/dev/null; then
			:
		else
			echo -e "Instalando pacote '$pkg'..."
			echo "Instalando pacote '$pkg' em $date" >> $logs_path/$logNameFile.txt
			warnningInteraction
			aptLockFix
			sudo -S apt-get install -y "$pkg"
		fi
	}

	add_to_group_if_needed() {
		local group="$1"
		local date=$(date '+%Y-%m-%d_%H:%M:%S')
		if getent group "$group" > /dev/null; then
			if id -nG "$USER" | grep -qw "$group"; then
				:
			else
				echo -e "Adicionando usuário ao grupo '$group'..."
				echo "Adicionando usuário ao grupo '$group' em $date" >> $logs_path/$logNameFile.txt
				printf '%s\n' "$PASSWD" | sudo -S -p '' usermod -aG "$group" "$USER" 2>/dev/null
			fi
		fi
	}

	# Verifica e instala pacotes necessários (exceto Firebird)
	check_and_install_package udisks2
	check_and_install_package pmount

	# Ajusta os grupos
	add_to_group_if_needed lp
	add_to_group_if_needed dialout
	add_to_group_if_needed plugdev
	add_to_group_if_needed firebird
}

atualizarVRRules() {

if [ $setcheckvariable -ne 1 ]; then
		echo -e "\nAtualizacao de arquivo VRules"
			
	internetConnectionCheck
	killApp java
fi

	BACKUP=/pdv/util/backupRules
	printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $BACKUP 2>/dev/null
	FILE=/etc/udev/rules.d/vr.rules

	killApp java
	echo -e "\nBaixando vr.rules ..."
	printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $URLRULES -O /pdv/util/vr.rules 2>/dev/null
		if [ $? -ne 0 ] || [ ! -s /pdv/util/vr.rules ]; then
		clear ; echo "" ; echo -e "${R1}Erro ao realizar download do VRRules${End}" ; pause ; printf "\n\n" ; menuOptions
		fi

	printf '%s\n' "$PASSWD" | sudo -S -p '' mv $FILE $BACKUP/ 2>/dev/null
		echo "Atualizando arquivo $FILE ..."
	printf '%s\n' "$PASSWD" | sudo -S -p '' mv /pdv/util/vr.rules $FILE 2>/dev/null || echo -e "${R1}Erro ao atualizar o arquivo VRRules${End}"
	
	echo "Reiniciando servico UDEV ..."
	printf '%s\n' "$PASSWD" | sudo -S -p '' service udev restart 2>/dev/null || echo -e "${R1}Erro ao iniciar servico VRRules${End}"
	
	createRegisterLog "VRRulesUpdate"
	# printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "VRRules atualizado em $date" | sudo tee -a $logs_path/VRRulesUpdate-$date.txt >/dev/null 2>&1
	
	echo -e "\n${B1}VR.RULES atualizado, por favor reinicie o computador para aplicacao das alteracoes${End}"
}

atualizarBancoVR() {
if [ $setcheckvariable -ne 1 ]; then
	echo -e "\nAtualizando banco VR.FDB..."
fi
		killApp java
		
		date=$(date '+%Y-%m-%d_%H:%M:%S')
		if [ -e "/pdv/database/VR.FDB"  ]; then
			date=$(date '+%Y-%m-%d_%H:%M:%S')
			printf '%s\n' "$PASSWD" | sudo -S -p '' mv /pdv/database/VR.FDB /pdv/database/$date-VR.FDB >/dev/null 2>/dev/null
		fi		
		
		local setcopyBancoVR=0

		if printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination /pdv_vr/pdv/database/VR.FDB /pdv/database 2>/dev/null; then
			setcopyBancoVR=1
		fi

		if [ "$setcopyBancoVR" = "1" ]; then
			printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" -R /pdv/database/VR.FDB 2>/dev/null
			printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /pdv/database/VR.FDB 2>/dev/null
			echo -e "\n${B1}Banco de dados atualizado com o arquivo em /pdv_vr/pdv/database${End}"

			createRegisterLog "Copy_BancoVRFDB"
		else
			echo -e "${R1}ATENÇÃO: Banco NÃO copiado para /pdv/database.${End}" >&2
			echo -e "${R1}Verifique permissoes, espaco em disco ou se o arquivo de origem existe.${End}" >&2
			# Log de erro opcional:
			echo "$(date '+%Y-%m-%d %H:%M:%S') - ERRO: Falha ao copiar banco de dados." >> "$logs_path/Copy_BancoVRFDB-erro.txt"
		fi
}

atualizarPDV() {
if [ $setcheckvariable -ne 1 ]; then
	echo -e "\nCopiando VRPdv.jar ..."
fi

DATEDMY=`date +%d-%m-%Y`
	if [ ! -e "/pdv_vr/exec/VRPdv.jar"  ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' mount -a >/dev/null 2>&1
	fi
	
	if [ -e "/pdv_vr/exec/VRPdv.jar"  ]; then
		killApp java
		
		printf '%s\n' "$PASSWD" | sudo -S -p '' mv /pdv/exec/VRPdv.jar /pdv/exec/$DATEDMY-VRPdv.jar 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination /pdv_vr/exec/VRPdv.jar /pdv/exec/ && \
		setcopyExecVR=1 || \
		setcopyExecVR=0
		
		if [ $setcopyExecVR = 1 ]; then	
		
			printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" /pdv/exec/VRPdv.jar 2>/dev/null
			printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /pdv/exec/VRPdv.jar 2>/dev/null
			printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x /pdv/exec/VRPdv.jar 2>/dev/null
			
			echo -e "\n${B1}VRPdv.jar copiado com sucesso${End}"
			
			createRegisterLog "Copy_VRPdv.jar_Script"
			# printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "PDV Atualizado via script em $date" | sudo tee -a $logs_path/Copy_VRPdv.jar_Script-$date.txt >/dev/null 2>&1
		else
			echo -e "\n${R1}ATENCAO: Arquivo VRPdv.jar nao copiado. Verifique manualmente e reinicie a funcao${End}"
		fi
	else
		echo -e "\n${R1}Arquivo VRPdv.jar nao encontrado em /pdv_vr/exec/, verifique e execute novamente${End}"
	fi
}

removeLockFiles() {
    echo -e "\nRemovendo arquivos de estado lock de /var/lock..."
    printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /var/lock/LCK*
	
	createRegisterLog "Remove_LockFiles"
	# printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "Remocao arquivos Lock em $date" | sudo tee -a $logs_path/Remove_LockFiles-$date.txt >/dev/null 2>&1
}

subMenu() {
	clear
	echo ""

	separador
	echo -e "${LNFP}               SUB MENU DE SUPORTE PDV               ${End}"
	separador

	echo -e "\n${LNFP}--- Sistema ---${End}"
	printf "%-3s %b\n" "1." "JAVA Update/Reinstall"
	printf "%-3s %b\n" "2." "Atualizar Linux ${C1}(atencao, isso pode demorar um pouco)${End}"
	printf "%-3s %b\n" "3." "Firebird 2.5.9.27139-0:i386 (x86) Reinstall"
	printf "%-3s %b\n" "16." "Remover java 11"

	echo -e "\n${LNFP}--- Configurações ---${End}"
	printf "%-3s %b\n" "4." "Desativar ScreenSaver e Controle de Energia"
	printf "%-3s %b\n" "6." "Configurar ResolvConf"
	printf "%-3s %b\n" "10." "Habilitar login automatico Lubuntu 20.04"
	printf "%-3s %b\n" "13." "Modificar configuracoes de som (self-checkout)"
	printf "%-3s %b\n" "15." "Remover arquivos de estado lock dos perifericos"
	printf "%-3s %b\n" "24." "Ajustar Data/Hora Linux Manualmente"
	printf "%-3s %b\n" "25." "Desativar Firewall Linux Lubuntu"
	printf "%-3s %b\n" "26." "Unlock DPKG/APT"

	echo -e "\n${LNFP}--- Aplicativos ---${End}"
	printf "%-3s %b\n" "5." "Teste Internet e FTPs"
	printf "%-3s %b\n" "7." "Firefox / Gedit / Htop / CUPS (modulo de impressoes)"
	printf "%-3s %b\n" "8." "${G1}AnyDesk Install/Reinstall/Update/ResetID${End}"
	printf "%-3s %b\n" "29." "${B1}RustDesk Install/Reinstall${End}"
	printf "%-3s %b\n" "9." "Remover tela de Spider-Man/Alienigena"
	printf "%-3s %b\n" "11." "Configurando BemaGo - Elgin"
	printf "%-3s %b\n" "12." "Instalar Sweda SI300"
	printf "%-3s %b\n" "14." "Instalar Camera Gunnebo"
	printf "%-3s %b\n" "20." "TeamViewer Install/Reinstall"
	printf "%-3s %b\n" "21." "Desativar Notificacoes Update/Atualizacao"
	printf "%-3s %b\n" "22." "${C1}Atalho Atualizar Imagens PDV${End}"
	printf "%-3s %b\n" "23." "Atualizar Imagens/Tema PDV manualmente"
	printf "%-3s %b\n" "27." "Balanca Magelan 9800i"
	printf "%-3s %b\n" "28." "Ajuste da dependencia (libatk-wrapper-java-jni:i386) e (libatk-bridge2.0-0:i386)"

	echo -e "\n${LNFP}--- Utilitários ---${End}"
	printf "%-3s %b\n" "17." "${G1}Configurar Atraso ou Abrir/Fechar PDV para falha de SAT${End}"
	printf "%-3s %b\n" "18." "${G1}Pesquisa de arquivos${End}"
	printf "%-3s %b\n" "19." "${G1}Download vr.properties${End}"

	separador
	printf "%-3s %b\n" "99." "${LNFP}Voltar ao menu principal${End}"
	separador

    read -p "Escolha o tipo de ajuste: " APPUPDATE
		
		if [ -z "$APPUPDATE" ] || ! [[ "$APPUPDATE" =~ ^[0-9]+$ ]]; then
			echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; subMenu
		fi
		if [ $APPUPDATE -eq 1 ]; then	
			internetConnectionCheck
			javaInstallReinstall
		fi
		if [ $APPUPDATE -eq 2 ]; then	
			internetConnectionCheck
			linuxUpdate
			setcheckvariable=1
			corrigirPermissoes
			echo -e "\n${B1}LINUX ATUALIZADO${End}\n"
			finished
		fi
		if [ $APPUPDATE -eq 3 ]; then	
			internetConnectionCheck
			firebirdInstallReinstall
		fi
		if [ $APPUPDATE -eq 4 ]; then
			disableEnergyScreensaver
			# printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "ScreenSaver / EnergyControl Disabled em $date" | sudo tee -a $logs_path/disableEnergyScreensaver-$date.txt >/dev/null 2>&1
			echo -e "\n${B1}DisableEnergySaver_ScreenSaver criado e iniciado!!${End}\n"
		fi
		if [ $APPUPDATE -eq 5 ]; then
			internetTest
			echo -e "\n\n" ; pause ; menuOptions
		fi
		if [ $APPUPDATE -eq 6 ]; then
			setResolvconf
		fi
		if [ $APPUPDATE -eq 7 ]; then	
			internetConnectionCheck
			echo ""
			echo "Instalando Apps...Aguarde..."
			appsInstallReinstall
		fi
			if [ $APPUPDATE -eq 8 ]; then
			anydeskMenu
		fi
		if [ $APPUPDATE -eq 9 ]; then
			rootBanner
			echo -e "\n${B1}Removido tela de Spider-Man/Alienigena${End}\nReinicie o Computador para confirmacao."
		fi

		if [ $APPUPDATE -eq 10 ]; then
			if [[ ${LINUX_VERSION} == "20.04" ]]; then
				autoLogin
			else
				echo -e "\nVersao 20.04 nao autorizada para essa funcao" ; pause ; menuOptions
			fi
		fi
		if [ $APPUPDATE -eq 11 ]; then
			bemagoElgin
		fi
		if [ $APPUPDATE -eq 12 ]; then
			swedaSI300
		fi
		if [ $APPUPDATE -eq 13 ]; then
			modifySound
		fi
		if [ $APPUPDATE -eq 14 ]; then
			installGunnebo
		fi
		if [ $APPUPDATE -eq 15 ]; then
			removeLockFiles
		fi
		if [ $APPUPDATE -eq 16 ]; then
			
			printf '%s\n' "$PASSWD" | safe_apt_get -yq remove openjdk-11-*
			createRegisterLog "java11Removed"
		fi
		if [ $APPUPDATE -eq 17 ]; then
			menuAtrasoPDV
			finished
		fi
		if [ $APPUPDATE -eq 18 ]; then
			findfiles
		fi
		if [ $APPUPDATE -eq 19 ]; then
			checkVRProperties
		fi
		if [ $APPUPDATE -eq 20 ]; then
			installreinstallteamviewer
		fi
		if [ $APPUPDATE -eq 21 ]; then
			setcheckvariable=1
			disableNotificationUpdate
		fi
		if [ $APPUPDATE -eq 22 ]; then
			updateThemePDVManualScript
		fi
		if [ $APPUPDATE -eq 23 ]; then
			updateThemePDVManual
		fi
		if [ $APPUPDATE -eq 24 ]; then
			update_datahora
		fi
		if [ $APPUPDATE -eq 25 ]; then
			firewallLinux
		fi
		if [ $APPUPDATE -eq 26 ]; then
			echo -e "\n[Unlocking dpkg / apt]"
			echo -e "Aguarde . . ."
			
			echo ""
			finished
		fi
		if [ $APPUPDATE -eq 27 ]; then
			install_Magelan9800i
		fi
		if [ $APPUPDATE -eq 28 ]; then
			javaWrapperError
		fi
		if [ $APPUPDATE -eq 29 ]; then
			rustdeskInstallReinstall
		fi
		if [ $APPUPDATE -ge 30 ]; then
			if [ $APPUPDATE -le 98 ]; then	
			echo -e "\n${R1}Opcao incorreta, retornando ao menu de Apps${End}" ; pause ; subMenu
			fi
		fi
		if [ $APPUPDATE -eq 99 ]; then	
			menuOptions
		fi
		
		# echo "" ; echo -e "${C2}PROCESSO ENCERRADO${End}" ; pause ; menuOptions
}

firewallLinux() {
	echo ""
    printf '%s\n' "$PASSWD" | sudo -S -p '' ufw disable
	
	createRegisterLog "DisabelFirewallLinux"
}

appsInstallReinstall() {

printf '%s\n' "$PASSWD" | safe_apt_get -y install firefox
printf '%s\n' "$PASSWD" | safe_apt_get -yq install gedit
printf '%s\n' "$PASSWD" | safe_apt_get -y install htop

appInstallReinstall_Onboard

reinstallCups

createRegisterLog "Apps_Firefox_Gedit_Htop"
}

appInstallReinstall_Onboard() {
printf '%s\n' "$PASSWD" | safe_apt_get -y install onboard

while IFS= read -r desktopFolder; do
    printf '%s\n' "$PASSWD" | sudo -S cp --remove-destination -p \
        /usr/share/applications/onboard.desktop \
        "$desktopFolder/TecladoVirtual.desktop"
done < <(setshortcutfiles)
}

install_Magelan9800i() {
echo -e "\n${C2}[Realizando Download Arquivos Magelan 9800i]${End}"

list_delete=(
  "/pdv/exec/brand.properties"
  "/pdv/exec/dls.properties"
  "/pdv/exec/jpos.xml"
  "/tmp/VRJavaPOS-Datalogic.zip"
)

for item in "${list_delete[@]}"; do
    if [ -e "$item" ]; then
        case "$item" in
            "/pdv/exec/javapos"|"/pdv/exec/brand.properties"|"/pdv/exec/dls.properties"|"/tmp/VRJavaPOS-Datalogic.zip")
                # Arquivos pertencentes ao usuário firebird
                printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "$item" &>/dev/null
                ;;
            "/pdv/exec/jpos.xml")
				date=$(date '+%Y-%m-%d_%H:%M:%S')
				if [ ! -d "/pdv/exec/util/bkp_JPOS_Magelan" ]; then
					printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p /pdv/exec/util/bkp_JPOS_Magelan >/dev/null 2>&1
					printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R /pdv/exec/util/bkp_JPOS_Magelan >/dev/null 2>&1
					printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R /pdv/exec/util/bkp_JPOS_Magelan >/dev/null 2>&1
				fi
				printf '%s\n' "$PASSWD" | sudo -S -p '' mv "/pdv/exec/jpos.xml" "/pdv/exec/util/bkp_JPOS_Magelan/jpos-$date.xml" >/dev/null 2>&1
                ;;
		esac
	fi
done
    if [ -d "/pdv/exec/javapos" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/pdv/exec/javapos" &>/dev/null
	fi

downloadArquivo $URLMAGELAN9800I "/tmp/VRJavaPOS-Datalogic.zip"

echo -e "\n[Extraindo Arquivos Magelan 9800i]\n"
printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o "/tmp/VRJavaPOS-Datalogic.zip" -d /pdv/exec/ 2>/dev/null
list_extractedFiles=(
  "/pdv/exec/javapos"
  "/pdv/exec/brand.properties"
  "/pdv/exec/dls.properties"
  "/pdv/exec/jpos.xml"
)

for item in "${list_extractedFiles[@]}"; do
	if [ -e "$item" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 "$item" >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" "$item" >/dev/null 2>&1
		echo -e "Permissao aplicada em: $item"
	fi
done

echo -e "\n{B1}[Configuracao de Porta SERIAL]{End}"
echo -e "\nPara configurar a porta voce precisa abrir o TestaPeriferico (VRPdv.jar -test)\ne realizar os testes de porta da balança para identificar em qual esta configurada\nInforme a porta serial que funcionou nos testes do TestaPeriferico\nSem essa informacao, sera preciso editar o arquivo /pdv/exec/jpos.xml manualmente e inserir a porta completa no campo portName\n"
echo "1. /dev/ttyS0"
echo "2. /dev/ttyS1"
echo "3. /dev/ttyS2"
echo "4. /dev/ttyS3"
echo "5. /dev/ttyS4"
echo "6. /dev/ttyS5"
echo "7. /dev/ttyS6"
echo "8. SAIR e realizar a configuracao do arquivo jpos.xml manualmente ou posteriormente"
read -p "Escolha uma opcao: " OPTPORTMAGELAN
		if [ $OPTPORTMAGELAN -eq 1 ]; then	
			value=/dev/ttyS0
		fi
		if [ $OPTPORTMAGELAN -eq 2 ]; then	
			value=/dev/ttyS1
		fi
		if [ $OPTPORTMAGELAN -eq 3 ]; then	
			value=/dev/ttyS2
		fi
		if [ $OPTPORTMAGELAN -eq 4 ]; then	
			value=/dev/ttyS3
		fi
		if [ $OPTPORTMAGELAN -eq 5 ]; then	
			value=/dev/ttyS4
		fi
		if [ $OPTPORTMAGELAN -eq 6 ]; then	
			value=/dev/ttyS5
		fi
		if [ $OPTPORTMAGELAN -eq 7 ]; then	
			value=/dev/ttyS6
		fi
		if [ $OPTPORTMAGELAN -eq 8 ]; then	
			menuOptions
		fi
		if [ $OPTPORTMAGELAN -ge 9 ]; then
			echo -e "\n${R1}Opcao incorreta, retornando ao menu de Apps${End}" ; pause ; subMenu
		fi

echo -e "\n[Ajustando porta serial no arquivo /pdv/exec/jpos.xml]\n"
if grep -q '^[[:space:]]*<prop name="portName" type="String" value=' "/pdv/exec/jpos.xml"; then
    sed -i "s|\(<prop name=\"portName\" type=\"String\" value=\"\)[^\"]*\(\"\s*/>\)|\1$value\2|" "/pdv/exec/jpos.xml"
fi

finished
}

anydeskMenu() {
	echo ""
	echo "[ANYDESK MENU]"
	echo "1. Install/Reinstall/Update"
	echo "2. Reset ID"
	echo -e "${LNFP}3. Retornar menu principal${End}"
	read -p "Escolha uma opcao: " OPTANYDESKMENU
	
	if [ -z "$OPTANYDESKMENU" ] || ! [[ "$OPTANYDESKMENU" =~ ^[0-9]+$ ]]; then
		echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; anydeskMenu
	fi
	if [ $OPTANYDESKMENU -eq 1 ]; then	
		installreinstallanydesk
		finished
	fi
	if [ $OPTANYDESKMENU -eq 2 ]; then	
		resetIDAnydesk
		finished
	fi
	if [ $OPTANYDESKMENU -eq 3 ]; then	
		subMenu
	fi
	if [ $OPTANYDESKMENU -ge 4 ]; then
		if [ $OPTANYDESKMENU -le 98 ]; then	
		echo -e "\n${R1}Opcao incorreta, retornando ao menu de Apps${End}" ; pause ; anydeskMenu
		fi
	fi
}

anydeskvalidaversion() {
	echo ""
	echo "Este linux possivelmente ja possui a versao 6.0.1 do Anydesk"
	echo -e "${C1}Gostaria de prosseguir com a instalacao/reinstalacao ?${End}"
	echo "1. SIM"
	echo -e "${LNFP}2. NAO (retornar menu principal)${End}"
	read -p "Escolha uma opcao: " OPTANYDESKVALIDAVERSION

	if [ -z "$OPTANYDESKVALIDAVERSION" ] || ! [[ "$OPTANYDESKVALIDAVERSION" =~ ^[0-9]+$ ]]; then
		echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; menuOptions
	fi
    if [ $OPTANYDESKVALIDAVERSION -eq 1 ]; then
		:
	fi
	if [ $OPTANYDESKVALIDAVERSION -eq 2 ]; then
		menuOptions
	fi
	if [ $OPTANYDESKVALIDAVERSION -ge 3 ]; then
		echo -e "\n${R1}Opcao incorreta${End}" ; pause ; menuOptions
	fi
}

anydescheckUpgrade() {
	echo ""
	echo -e "Este proceso requer a TOTAL atualizacao do Linux\n*** E isso pode demorar um pouco ***"
	echo -e "${C1}Gostaria de prosseguir com a instalacao/reinstalacao do Anydesk ?${End}"
	echo "1. SIM"
	echo -e "${LNFP}2. NAO (retornar menu principal)${End}"
	read -p "Escolha uma opcao: " OPTANYDESKVALIDAVERSION

	if [ -z "$OPTANYDESKVALIDAVERSION" ] || ! [[ "$OPTANYDESKVALIDAVERSION" =~ ^[0-9]+$ ]]; then
		echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; menuOptions
	fi
    if [ $OPTANYDESKVALIDAVERSION -eq 1 ]; then
		:
	fi
	if [ $OPTANYDESKVALIDAVERSION -eq 2 ]; then
		menuOptions
	fi
	if [ $OPTANYDESKVALIDAVERSION -ge 3 ]; then
		echo -e "\n${R1}Opcao incorreta${End}" ; pause ; menuOptions
	fi
}

installreinstallanydesk() {
	if [[ ${LINUX_VERSION} != "16.04" ]]; then
		anydeskvalidaversion
	fi
	
	anydescheckUpgrade
	internetConnectionCheck
	
	killApp java
	check_repos
	echo -e "${C1}[Ajustando links de SourcesList]${End}"
	sourcelist
	
	echo -e "\n${G1}## ATUALIZANDO/REINSTALANDO ANYDESK ##${End}"
	echo -e "\n${G1}[Baixando versao 6.0.1-1 AnyDesk...Aguarde...]${End}"
	printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $anydeskLink -O /pdv/util/anydesk_6.0.1-1_i386.deb >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		if [ -e "/pdv/util/anydesk_6.0.1-1_i386.deb" ]; then
			echo -e "${G1}[Arquivo baixado com sucesso !!!]${End}"
			echo -e "${G1}[Removendo anydesk atual . . .]${End}\n"
			printf '%s\n' "$PASSWD" | sudo -S -p '' pkill -9 anydesk >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | safe_apt_get -y purge anydesk
			printf '%s\n' "$PASSWD" | safe_apt_get -y autoclean
		else
			clear ; echo ""
			echo -e "${R1}Erro ao realizar download do arquivo anydesk_6.0.1-1_i386.deb${End}"
			pause ; menuOptions
		fi
	else
		clear ; echo ""
		echo -e "${R1}Erro ao realizar download do arquivo anydesk_6.0.1-1_i386.deb${End}"
		pause ; menuOptions			
	fi

	echo -e "\n${G1}[Instalando nova versao do Anydesk . . .]${End}"
	echo -e "${G1}[Este processo ira demorar um pouco . . . Aguarde . . .]${End}\n"

	updateSystem_UpgradeCommand

    local commandsList=(
        "sudo apt-get -f -yq install libgtkglext1"
        "sudo apt-get -f -yq install libgtkglext1:i386"
        "sudo apt-get -f -yq install libgtkglext:i386"
        "sudo apt -y install libpolkit-gobject-1-0"
        "sudo apt -y install libpolkit-gobject-1-0:i386"
        "sudo apt-get -f -yq install libgtkglext1"
        "sudo apt-get -f -yq install libgtkglext1:i386"
        "sudo apt-get -f -yq install libgtkglext:i386"
        "sudo apt -y install libpolkit-gobject-1-0"
        "sudo apt -y install libpolkit-gobject-1-0:i386"
        "sudo apt-get -f -y install"
        "sudo apt -y --fix-broken install"
        "sudo dpkg --configure -a"
        "sudo apt -y install wget gdebi-core"
        "sudo gdebi -n /pdv/util/anydesk_6.0.1-1_i386.deb"
        "sudo ldconfig"
    )
    
    # Executa todos os comandos
    executeCommands "${commandsList[@]}"
	
	APPNAME="Anydesk"
	# Checa se existe atalho na /usr/share/applications e renomeia caso true
	if [ ! -e "$SHORTCUTPATH/$APPNAME.desktop" ];then
		printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "[Desktop Entry]\nName=AnyDesk\nGenericName=AnyDesk\nX-GNOME-FullName=AnyDesk\nExec=/usr/bin/anydesk %u\nIcon=anydesk\nTerminal=false\nTryExec=anydesk\nType=Application\nCategories=Network;GTK;"| sudo tee -a $SHORTCUTPATH/$APPNAME.desktop >/dev/null 2>&1	
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x $SHORTCUTPATH/$APPNAME.desktop >/dev/null 2>&1
	fi

while IFS= read -r desktopFolder; do
    if [ ! -e "$desktopFolder/$APPNAME.desktop" ]; then
        printf '%s\n' "$PASSWD" | sudo -S cp --remove-destination -p \
            "$SHORTCUTPATH/$APPNAME.desktop" "$desktopFolder/" >/dev/null 2>&1
        printf '%s\n' "$PASSWD" | sudo -S chmod +x \
            "$desktopFolder/$APPNAME.desktop" >/dev/null 2>&1

        if [ -e "$SHORTCUTPATH/anydesk_global_tray.desktop" ]; then
            printf '%s\n' "$PASSWD" | sudo -S cp --remove-destination -p \
                "$SHORTCUTPATH/anydesk_global_tray.desktop" "$desktopFolder/" >/dev/null 2>&1
            printf '%s\n' "$PASSWD" | sudo -S chmod +x \
                "$desktopFolder/anydesk_global_tray.desktop" >/dev/null 2>&1
        fi
    fi
done < <(setshortcutfiles)
	
	createRegisterLog "AnydeskUpdate"
	
	local checkanydeskVariable=1
	resetIDAnydesk

	# Testa Iniciar o AnyDesk
	$anydesk_executable &
	sleep 2
	ANYDESK_PID=$!
	sleep 2
	if ps -p $ANYDESK_PID > /dev/null
		then
			echo -e "\n\n${B1}Anydesk atualizado com sucesso.${End}"
			echo -e "Anydesk sera encerrado e reiniciado automaticamente"
			# sleep 2
			printf '%s\n' "$PASSWD" | sudo -S -p '' pkill -9 anydesk >/dev/null 2>&1
			sleep 2
			nohup anydesk > /dev/null 2>&1 &
		else
		   echo -e "\n\n${R1}Falha ao iniciar o AnyDesk.${End}"
	fi
}

resetIDAnydesk() {
echo ""
echo -e "\n${G1}[Realizando Limpeza de ID Anydesk]${End}"

printf '%s\n' "$PASSWD" | sudo -S -p '' pkill -9 anydesk >/dev/null 2>&1
# printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf ~/.anydesk/service.conf /etc/anydesk/ >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /home/$USER/.anydesk/service.conf
printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /etc/anydesk/
echo -e "${G1}[Iniciando AnyDesk com novo ID]${End}"
printf '%s\n' "$PASSWD" | sudo -S -p '' pkill -9 anydesk >/dev/null 2>&1

if [ $checkanydeskVariable -eq 1 ]; then
	nohup anydesk > /dev/null 2>&1 &
fi
}

installreinstallteamviewer() {
echo -e "\nFoi inserido o teamviewer devido a facilitar para o cliente receber suporte de fabricantes ou terceiros.\nA VR se manterá usando APENAS o AnyDesk como forma de acesso."

teamviewerfail=0
if command -v teamviewer &> /dev/null; then
	echo -e "\n${R1}Removendo TeamViewer . . .${End}"
	printf '%s\n' "$PASSWD" | safe_apt remove -y teamviewer
	printf '%s\n' "$PASSWD" | safe_apt purge -y teamviewer
	printf '%s\n' "$PASSWD" | safe_apt_get -y autoclean
fi

echo -e "\n${G1}Instalando dependencias TeamViewer . . .${End}"
local commandsList=("sudo apt update" 
		"sudo dpkg --configure -a" 
		"sudo apt-get -y --fix-broken install" 
		"sudo apt-get -f -y install"
        "sudo ldconfig"
		"sudo apt-get -y install wget gdebi-core")
executeCommands "${commandsList[@]}"

echo -e "\n${G1}Realizando Download TeamViewer . . .${End}"
	if [ -e "/tmp/teamviewer.deb" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /tmp/teamviewer.deb >/dev/null 2>&1
	fi
printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate  $URLTEAMVIEWER -O /tmp/teamviewer.deb >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		clear ; echo "" ; echo -e "${R1}Erro Realizar Download TeamViewer${End}" ; pause ; printf "\n\n" ; menuOptions
	fi

echo -e "\n${G1}Instalando TeamViewer . . .${End}"
local commandsList=("sudo gdebi -n /tmp/teamviewer.deb")
executeCommands "${commandsList[@]}"
if [ $? -ne 0 ]; then
	teamviewerfail=1
fi

if [ $teamviewerfail -eq 1 ]; then 


	local commandsList=("sudo dpkg -i /tmp/teamviewer.deb")
	executeCommands "${commandsList[@]}"
fi

if ! command -v teamviewer &> /dev/null; then
	echo -e "\n${R1}Erro instalacao TeamViewer${End}" ; pause ; menuOptions
else
	local APPNAME=teamviewer
while IFS= read -r desktopFolder; do
    if [ ! -e "$desktopFolder/teamviewer.desktop" ]; then

        # Criação da pasta de ícones e download, se necessário
        if [ ! -e "$iconPath/teamviewer.png" ]; then
            printf '%s\n' "$PASSWD" | sudo -S mkdir -p -m 777 "$iconPath" >/dev/null 2>&1
            printf '%s\n' "$PASSWD" | sudo -S wget -c --no-check-certificate "$appsIco" -O "$iconPath/img.zip" 2>/dev/null

            if [ $? -ne 0 ] || [ ! -s "$iconPath/img.zip" ]; then
                clear
                echo ""
                echo -e "${R1}Erro ao realizar download $iconPath/img.zip${End}"
                pause
                printf "\n\n"
                menuOptions
            fi

            printf '%s\n' "$PASSWD" | sudo -S unzip -q -o "$iconPath/img.zip" -d "$iconPath" 2>/dev/null
            printf '%s\n' "$PASSWD" | sudo -S rm -rf "$iconPath/img.zip" 2>/dev/null
            printf '%s\n' "$PASSWD" | sudo -S chmod 777 -R "$iconPath"/*
            printf '%s\n' "$PASSWD" | sudo -S chown "nobody:nogroup" -R "$iconPath"/*
        fi

        # Criação do atalho TeamViewer
        SHORTCUT_FILE="$desktopFolder/teamviewer.desktop"
        printf '%s\n' "$PASSWD" | sudo -S touch "$SHORTCUT_FILE" >/dev/null 2>&1
        printf '%s\n' "$PASSWD" | sudo -S chmod 644 "$SHORTCUT_FILE" >/dev/null 2>&1
        printf '%s\n' "$PASSWD" | sudo -S chown "nobody:nogroup" "$SHORTCUT_FILE" >/dev/null 2>&1

        printf '%s\n' "$PASSWD" | sudo -S bash -c "cat > \"$SHORTCUT_FILE\" <<EOF
[Desktop Entry]
Version=1.0
Name=TeamViewer
Exec=/usr/bin/teamviewer
Icon=$iconPath/teamviewer.png
Terminal=false
Type=Application
Categories=Network;RemoteAccess;
EOF"

        printf '%s\n' "$PASSWD" | sudo -S chmod +x "$SHORTCUT_FILE" >/dev/null 2>&1
    fi
done < <(setshortcutfiles)
	echo -e "\n${BP1}TeamViewer instalado com sucesso${End}"
fi
}

linuxUpdate() {
	
	if [ $setcheckvariable -ne 1 ]; then
		echo -e "\n${G1}Atualizando Linux...Aguarde...${End}\n"
	fi
	killApp java
	check_repos
	echo -e "${C1}[Ajustando links de SourcesList]${End}"
	sourcelist
	
	echo -e "\n${B1}ℹ️${End} - ${G1}[INFO] Instalando pacotes essenciais...Aguarde...${End}\n"
	packages=("mlocate" "libnotify-bin" "expect" "gedit" "net-tools" "htop" "gnome-terminal" "firefox" "onboard")
	for package in "${packages[@]}"; do
		if printf '%s\n' "$PASSWD" | safe_apt_get -yq install $package; then
			echo -e "\n${B1}Instalação do $package bem-sucedida.${End}\n"
		else
			echo -e "\n${R1}A instalação do $package falhou.${End}\n"
		fi
	done

	printf '%s\n' "$PASSWD" | sudo -S -p '' usermod -aG lp $USER
	printf '%s\n' "$PASSWD" | sudo -S -p '' usermod -aG $USER lp

	LOGFILE="$logs_path/LinuxUpdate.txt"
	if [ ! -e "$LOGFILE" ]; then
		filepermission_create $LOGFILE
	fi

	echo -e "\n${Y1}⚠️${End} [INFO] A atualizacao ira iniciar, existem momentos que sera necessario a sua interacao \nCaso seja necessario entrar com a senha sudo ou um S/n ou selecao de opcoes ${Y1}⚠️${End}"
	echo -e "${Y1}⚠️${End} [INFO] Entao se atente a tela durante a atualizacao ${Y1}⚠️${End}\n"

	pause
			 
	date=$(date '+%Y-%m-%d_%H:%M:%S')
	{
		echo "########################################################################################"
		echo "Processo iniciado $date"
		echo "========================================================================================"

		# Autentica sudo apenas uma vez no início
		printf '%s\n' "$PASSWD" | sudo -S -p '' -v || { echo "[ERRO] - Senha incorreta"; exit 1; }

		commandsList=(
			"apt update"
			"dpkg --configure -a"
			"apt-get --fix-broken install"
			"apt-get -f -y install"
			"ldconfig"
			"apt-get -yq install --reinstall cups"
			"apt-get -yq install wget gdebi-core"
			"apt-get -yq install --only-upgrade libc6:i386"
			"apt-get -yq install udisks2"
			"apt-get -yq install pmount"
			"apt-get upgrade"
		)

		for cmd in "${commandsList[@]}"; do
			echo
			echo "[EXECUTANDO] - $cmd"
			sudo bash -c "$cmd"
			if [ $? -ne 0 ]; then
				pause_on_error "$cmd"
			fi
		done

		printf '%s\n' "$PASSWD" | safe_apt_get clean

		disableNotificationUpdate

		echo "========================================================================================"
		date=$(date '+%Y-%m-%d_%H:%M:%S')
		echo "Processo encerrado $date"
		echo "########################################################################################"

	} | tee "$LOGFILE"
	
	createRegisterLog "LinuxAtualizado"
}

sourcelist() {
	sources_list="/etc/apt/sources.list"
	lines_to_check=(
		"deb http://ca.archive.ubuntu.com/ubuntu/ bionic main restricted universe multiverse"
		"deb http://ca.archive.ubuntu.com/ubuntu/ bionic-updates main restricted universe multiverse"
		"deb http://ca.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse"
		"deb http://security.ubuntu.com/ubuntu bionic-security main restricted universe multiverse"
		"deb-src http://ca.archive.ubuntu.com/ubuntu/ bionic main restricted universe multiverse"
		"deb-src http://security.ubuntu.com/ubuntu bionic-security main restricted universe multiverse"
		"deb-src http://ca.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse"
		"deb-src http://ca.archive.ubuntu.com/ubuntu/ bionic-updates main restricted universe multiverse"
		"deb http://archive.ubuntu.com/ubuntu/ bionic main universe"
		"deb http://archive.ubuntu.com/ubuntu/ bionic-updates main universe"
		"deb http://archive.ubuntu.com/ubuntu/ bionic-security main universe"
	)
	for line in "${lines_to_check[@]}"; do
		if ! grep -q "^$line$" "$sources_list" >/dev/null 2>&1; then
			printf '%s\n' "$PASSWD" | sudo -S -p '' echo "$line" | sudo tee -a /etc/apt/sources.list >/dev/null 2>&1
		fi
	done
}

disableNotificationUpdate() {
if [ $setcheckvariable -eq 1 ]; then
	echo -e "\n${R1}Desativando Notificacoes de Atualizacao/Update${End}"
fi

services=(
  apt-daily.timer
  apt-daily.service
  apt-daily-upgrade.timer
  apt-daily-upgrade.service
  unattended-upgrades.service
)

for s in "${services[@]}"; do
	printf '%s\n' "$PASSWD" | sudo -S -p '' systemctl stop --no-block "$s" 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' systemctl disable --now "$s" 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' systemctl mask "$s" 2>/dev/null
done

# Desliga a periodicidade do APT (cria/override seguro)
if [ -n "$PASSWD" ]; then
  printf '%s\n' "$PASSWD" | sudo -S -p '' bash -c 'cat > /etc/apt/apt.conf.d/99disable-auto <<EOF
APT::Periodic::Enable "0";
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Unattended-Upgrade "0";
EOF' &>/dev/null
else
  printf '%s\n' "$PASSWD" | sudo -S -p '' bash -c 'cat > /etc/apt/apt.conf.d/99disable-auto <<EOF
APT::Periodic::Enable "0";
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Unattended-Upgrade "0";
EOF' &>/dev/null
fi

# Opcional (silenciar notificações GUI para o usuário atual, sem sudo)
if [ -f /etc/xdg/autostart/update-notifier.desktop ]; then
  mkdir -p "$HOME/.config/autostart" 2>/dev/null
  cp /etc/xdg/autostart/update-notifier.desktop "$HOME/.config/autostart/" 2>/dev/null
  sed -i 's/^X-GNOME-Autostart-enabled=.*/X-GNOME-Autostart-enabled=false/' "$HOME/.config/autostart/update-notifier.desktop" 2>/dev/null
fi

setcheckvariable=0

createRegisterLog "disableNotification"
}

linuxFullUpdate() {
	clear
	echo -e "Esta opcao ira atualizar seu Linux a nivel de alterar o Kernel\nDeseja prosseguir ?"
	echo "1. SIM"
	echo -e "${LNFP}2. NAO (retornar menu principal)${End}"
	read -p "Escolha uma opcao: " OPTLINUXFULLUPDATE
	if [ -z "$OPTLINUXFULLUPDATE" ] || ! [[ "$OPTLINUXFULLUPDATE" =~ ^[0-9]+$ ]]; then
		echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; menuOptions
	fi
    if [ $OPTLINUXFULLUPDATE -eq 1 ]; then
		if [[ ${LINUX_VERSION} == "20.04" ]]; then
			echo -e "\n${G1}- [Ajustando arquivo 'sources.list']${End}"
			downloadArquivo "$URLSOURCESLIST" "/tmp/sources.list"
			local tamanho_minimo=4
			if [ ! -e "/tmp/sources.list" ]; then
				echo -e "\n\n${R1}- Arquivo sources.list nao baixado, processo encerrado.${End}"
				sleep 2
				return 1
			else
				if [[ $(stat -c%s "/tmp/sources.list") -lt $((tamanho_minimo * 1024)) ]]; then
					echo -e "\n\n${R1}- Arquivo sources.list nao baixado, processo encerrado.[2]${End}"
					sleep 2
					return 1
				fi
			fi

			if [ -e "/etc/apt/sources.list" ]; then
				date=$(date '+%Y-%m-%d_%H:%M:%S')
				printf '%s\n' "$PASSWD" | sudo -S -p '' mv "/etc/apt/sources.list" "/pdv/util/.scripts/sources-$date.list" >/dev/null 2>&1
			fi
			
			printf '%s\n' "$PASSWD" | sudo -S -p '' mv "/tmp/sources.list" "/etc/apt/sources.list" >/dev/null 2>&1
		fi
		echo -e "\n${G1}- [Iniciando atualizacao]${End}"
		check_repos
		
		echo -e "\n${Y1}⚠️${End} [INFO] A atualizacao ira iniciar, existem momentos que sera necessario a sua interacao \nCaso seja necessario entrar com a senha sudo ou um S/n ou selecao de opcoes ${Y1}⚠️${End}"
		echo -e "${Y1}⚠️${End} [INFO] Entao se atente a tela durante a atualizacao ${Y1}⚠️${End}\n"

		pause

		printf '%s\n' "$PASSWD" | sudo -S -p '' -v || { echo "[ERRO] - Senha incorreta"; exit 1; }
		local commandsList=( "apt-get clean"
			"apt update"
			"dpkg --configure -a"
			"apt-get --fix-broken install"
			"apt-get -f -y install"
			"ldconfig"
			"apt-get -yq install --reinstall cups"
			"apt-get -yq install wget gdebi-core"
			"apt-get -yq install --only-upgrade libc6:i386"
			"apt-get -yq install udisks2"
			"apt-get -yq install pmount"
			"apt-get full-upgrade"
		)

		for cmd in "${commandsList[@]}"; do
			echo
			echo "[EXECUTANDO] - $cmd"
			sudo bash -c "$cmd"
			if [ $? -ne 0 ]; then
				pause_on_error "$cmd"
			fi
		done

		printf '%s\n' "$PASSWD" | safe_apt_get clean

		createRegisterLog "LinuxFullAtualizado"
	fi
    if [ $OPTLINUXFULLUPDATE -eq 2 ]; then
		menuOptions
	fi
    if [ $OPTLINUXFULLUPDATE -ge 3 ]; then
		echo -e "\n${R1}Opcao incorreta, retornando ao menu${End}" ; pause ; menuOptions
	fi
}

bemagoElgin() {
	internetConnectionCheck

	echo ""
	echo "---------------"
	echo "BemaGo to Elgin"
	echo "---------------"
	
	# echo "Configurando rede"
	# sudo dpkg-reconfigure resolvconf 2>/dev/null
		
if [ -d "$DIR_SAT" ]; then
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $DIR_SAT 2>/dev/null
fi	
	printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $DIR_SAT 2>/dev/null
	
	echo "Baixando libs BemaGo ..."
	printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $URLBEMAGO -O $FILENAME 2>/dev/null
		if [ $? -ne 0 ]; then
		clear ; echo "" ; echo -e "${R1}Erro Realizar Download Arquivos BEMAGO TO ELGIN${End}" ; pause ; printf "\n\n" ; menuOptions
		fi
	
	echo "Executando Instalador ..."
	printf '%s\n' "$PASSWD" | safe_dpkg -i $FILENAME 2>/dev/null
	
	echo "Ajustando Libs ..."
	if [ -e "$libdllsat_elgin_old" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $libdllsat_elgin_old 2>/dev/null
	fi
	
	if [ -e "$libdllsat" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' cp $libdllsat $libdllsat_elgin 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $libdllsat 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $libdllsat_elgin 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" -R $libdllsat 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" -R $libdllsat_elgin 2>/dev/null
	fi
	
	if [ -e "$libdllsat" ]; then
		if [ -e "$libdllsat_elgin" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p $libdllsat $pdv_sat 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p $libdllsat_elgin $pdv_sat 2>/dev/null
		fi
	fi
	echo "" ; echo "Processo finalizado"
	createRegisterLog "BemaGo_to_Elgin"
}

reinstallCups() {
	internetConnectionCheck

    echo ""
    echo "Reinstalando CUPS (modulo de impressoes)."
    printf '%s\n' "$PASSWD" | safe_apt -y install --reinstall cups
    printf '%s\n' "$PASSWD" | sudo -S -p '' usermod -aG lp $USER
    printf '%s\n' "$PASSWD" | sudo -S -p '' usermod -aG $USER lp
	
	createRegisterLog "Cups"
}

atalhoMenu() {
	echo ""
	separador
	echo "1. Atalhos PDV."
    echo "2. Atalhos Apps VR."
	echo -e "${LNFP}3. Menu Principal.${End}"
    read -p "Escolha o atalho desejado: " OPTATALHOMENU
	if [ -z "$OPTATALHOMENU" ] || ! [[ "$OPTATALHOMENU" =~ ^[0-9]+$ ]]; then
		echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; menuOptions
	fi
    if [ $OPTATALHOMENU -eq 1 ]; then
		createShortcut
	fi
	if [ $OPTATALHOMENU -eq 2 ]; then
		createShortcutVR
	fi
	if [ $OPTATALHOMENU -eq 3 ]; then
		menuOptions
	fi
	if [ $OPTATALHOMENU -ge 4 ]; then
		echo -e "\n${R1}Opcao incorreta${End}" ; pause ; atalhoMenu
	fi
} 

createShortcut() {

	clear
	echo ""
	separador
    echo "1. VRPdv;"
    echo "2. PDVConfig;"
    echo "3. Touch;"
    echo "4. TouchConfig;"
    echo "5. Self;"
    echo "6. SelfConfig;"
	echo "7. TestaPeriferico;"
	echo "8. Anydesk;"
    echo "9. Sair."
    read -p "Escolha o atalho desejado: " OPTAPP

	if [ -z "$OPTAPP" ] || ! [[ "$OPTAPP" =~ ^[0-9]+$ ]]; then
		echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; createShortcut
	fi
    if [ $OPTAPP -eq 1 ]; then
		# Criar atalho PDV Comum
		APPNAME="VRPdv"
		atalhosresolucao
		menuOptions
	fi
	if [ $OPTAPP -eq 2 ]; then
		# Criar atalho PDV Comum
		APPNAME="PDVConfig"
		atalhoConfig
		menuOptions
	fi
	if [ $OPTAPP -eq 3 ]; then
		# Criar atalho Touch Comum
		clear
		cabosTouch
		APPNAME="Touch"
		touchModels
		atalhosresolucao
		menuOptions
	fi
	if [ $OPTAPP -eq 4 ]; then
		# Criar atalho Touch Config
		clear
		cabosTouch
		APPNAME="TouchConfig"
		touchModels
		atalhoConfig
		menuOptions
	fi
	
	if [ $OPTAPP -eq 5 ]; then
		# Criar atalho Self Comum
		APPNAME="Self"
		atalhosresolucao
		menuOptions
	fi
	
	if [ $OPTAPP -eq 6 ]; then
		# Criar atalho Self Config
		APPNAME="SelfConfig"
		atalhoConfig
		menuOptions
	fi
	
    if [ $OPTAPP -eq 7 ]; then
		# Criar atalho -teste
		atalhoTestaPeriferico
		menuOptions
	fi
		
	if [ $OPTAPP -eq 8 ]; then
		APPNAME="AnyDesk"
		createAnyDesk
		menuOptions		
	fi
	
	if [ $OPTAPP -eq 9 ]; then
		menuOptions
	fi
	
	if [ $OPTAPP -ge 10 ]; then
		echo -e "\n${R1}Opcao incorreta${End}" ; pause ; createShortcut
	fi
}

manualAdjustment() {
    clear
	echo ""
	echo -e "${R1}\nApos o ajuste, sera necessario executar o atalho ou script de inicializacao para ser aplicada a resolucao escolhida${End}\n"
	echo ""
	echo -e "${LNFP}Ajuste de resolucao Lubuntu${End}"
	separador
    echo "1. PDV Convencional - 800x600;"
    echo "2. PDV Self-Checkout - 1024x768;"
    echo "3. PDV TouchScreen - VGA-1 1366x768 | HDMI-1 800x600;"
	echo -e "4. PDV TouchScreen - VGA-1 1024x768 | HDMI-1 800x600 \n(${C1}Disponivel a partir da vrs VRPdv 3.23.27-X${End});"
    echo -e "${LNFP}5. Retornar ao Menu Principal.${End}"
    read -p "Escolha o tipo de ajuste: " PDVTYPE
		if [ -z "$PDVTYPE" ] || ! [[ "$PDVTYPE" =~ ^[0-9]+$ ]]; then
			echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; manualAdjustment
		fi
		if [ $PDVTYPE -eq 1 ]; then		
			# Criar atalho PDV Comum
			APPNAME="VRPdv"
			atalhosresolucao
			menuOptions
		fi
		if [ $PDVTYPE -eq 2 ]; then	
			# Criar atalho Self Comum
			APPNAME="Self"
			atalhosresolucao
			menuOptions
		fi
		if [ $PDVTYPE -eq 3 ]; then	
			# Criar atalho Touch Comum 1366x768
			clear
			touchresolucao=1366x768_touch
			cabosTouch
			APPNAME="Touch"
			touchModels
			atalhosresolucao
			menuOptions
		fi
		if [ $PDVTYPE -eq 4 ]; then	
			# Criar atalho Touch Comum 1024x768
			clear
			touchresolucao=1024x768_touch
			cabosTouch
			APPNAME="Touch"
			touchModels
			atalhosresolucao
			menuOptions
		fi
		if [ $PDVTYPE -eq 5 ]; then	
			menuOptions
		fi
		if [ $PDVTYPE -ge 6 ]; then	
			echo -e "\n${R1}Opcao incorreta${End}" ; pause ; manualAdjustment			
		fi
}

cabosTouch() {
	clear
	echo ""
	separador
    echo -e "1. PDV TouchScreen\n- Cabo VGA Monitor Operador (1366x768 ou 1024x768) | Cabo HDMI Monitor Cliente (800x600)\n${C1}VGA-1 1366x768/1024x768 | HDMI-1 800x600${End}\n"
    echo -e "2. PDV TouchScreen\n- Cabo HDMI Monitor Operador (1366x768 ou 1024x768) | Cabo VGA Monitor Cliente (800x600)\n${C1}HDMI-1 1366x768/1024x768 | VGA-1 800x600${End}\n${G1}Tambem conhecido como 'Cabos invertidos do padrao'${End}\n"
    echo "3. Sair."
	echo -e "\n${B1}Em caso de duvida, utilize a Opcao '1' ou '3', em sua maioria os monitores seguem o padrao da opcao 1${End}\n"
	read -p "Escolha o tipo de ajuste: " TYPE

	if [ -z "$TYPE" ] || ! [[ "$TYPE" =~ ^[0-9]+$ ]]; then
		echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; cabosTouch
	fi	
	if [ $TYPE -eq 1 ]; then	
		cabo_800x600=HDMI
		cabo_1366x768=VGA
	fi
	if [ $TYPE -eq 2 ]; then	
		cabo_800x600=VGA
		cabo_1366x768=HDMI
	fi
	if [ $TYPE -eq 3 ]; then	
		menuOptions
	fi
	if [ $TYPE -ge 4 ]; then	
		echo -e "\n${R1}Opcao incorreta${End}" ; pause ; cabosTouch			
	fi
}

touchModels() {
	clear
	echo -e "\n\n${G1}SELECAO DE MODELO DE MONITOR TOUCH${End}\n==================================\n"
	xinput && \
	echo "=============================" >> /pdv/util/logsScript/Xinput.txt
	date=$(date '+%Y-%m-%d_%H:%M:%S')
	echo "XINPUT - $date" >> /pdv/util/logsScript/Xinput.txt
	echo "" >> /pdv/util/logsScript/Xinput.txt
	xinput >> /pdv/util/logsScript/Xinput.txt
	echo "" >> /pdv/util/logsScript/Xinput.txt
	echo "=============================" >> /pdv/util/logsScript/Xinput.txt
	echo "XRANDR - $date" >> /pdv/util/logsScript/Xinput.txt
	echo "" >> /pdv/util/logsScript/Xinput.txt
	xrandr >> /pdv/util/logsScript/Xinput.txt
	echo "" >> /pdv/util/logsScript/Xinput.txt
	echo -e "\n==========================================="
	echo -e "${G1}Qual modelo do Monitor Touch da OPERADORA ?${End}"
	echo "1. eGalax Inc. eGalaxTouch P80H100 0842 v00_T1 k07_117"
	echo "2. Elo TouchSystems, Inc. Elo TouchSystems 2700 IntelliTouch(r) USB"
	echo "3. Elo Touch Solutions Elo Touch Solutions Pcap USB Interface"
	echo "4. ILITEK ILITEK-TP"
	echo "5. eGalax Inc. eGalaxTouch EXC3111-5621-08.00.00.00"
	echo "6. Weida Hi-Tech CoolTouch System"
	echo "7. eGalax Inc. eGalaxTouch EXC3111-5541-08.00.00.00"
	echo -e "8. ${C1}Selecionar Modelo por ID${End}"
	echo -e "\n9. ${C2}Modelo Desconhecido${End}\nUtilize essa opcao caso as opcoes acima nao aparecam na lista do xinput.\nEm alguns monitores Touch, eles ja vem com calibracao automatica, nisso essa opcao 5 apenas define  parametros de resolucao e nao possue a linha de calibracao e se encaixa melhor para eles.\nCaso o Monitor Operador estiver descalibrado e nao conter o modelo listado nas opcoes acima, sera necessario adicionar manualmte o modelo no script localizado abaixo.\n${C1}$pathSH${End}"
	echo -e "\n${LNFP}10. Retornar Menu Principal${End}\n"
	read -p "Opcao de modelo Monitor Touch: " TOUCHMODEL

	if [ -z "$TOUCHMODEL" ] || ! [[ "$TOUCHMODEL" =~ ^[0-9]+$ ]]; then
		echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; touchModels
	fi
	
	if [ $TOUCHMODEL -eq 1 ]; then
		touchMonitor="\"eGalax Inc. eGalaxTouch P80H100 0842 v00_T1 k07_117\""
		model_TouchMonitor="xinput map-to-output $touchMonitor $cabo_1366x768-1"
	fi
	if [ $TOUCHMODEL -eq 2 ]; then
		touchMonitor="\"Elo TouchSystems, Inc. Elo TouchSystems 2700 IntelliTouch(r) USB\""
		model_TouchMonitor="xinput map-to-output $touchMonitor $cabo_1366x768-1"
	fi
	if [ $TOUCHMODEL -eq 3 ]; then
		touchMonitor="\"Elo Touch Solutions Elo Touch Solutions Pcap USB Interface\""
		model_TouchMonitor="xinput map-to-output $touchMonitor $cabo_1366x768-1"
	fi
	if [ $TOUCHMODEL -eq 4 ]; then
		touchMonitor="\"ILITEK ILITEK-TP\""
		model_TouchMonitor="xinput map-to-output $touchMonitor $cabo_1366x768-1"
	fi
	if [ $TOUCHMODEL -eq 5 ]; then
		touchMonitor="\"eGalax Inc. eGalaxTouch EXC3111-5621-08.00.00.00\""
		model_TouchMonitor="xinput map-to-output $touchMonitor $cabo_1366x768-1"
	fi
	if [ $TOUCHMODEL -eq 6 ]; then
		touchMonitor="\"Weida Hi-Tech CoolTouch System\""
		model_TouchMonitor="xinput map-to-output $touchMonitor $cabo_1366x768-1"
	fi
	if [ $TOUCHMODEL -eq 7 ]; then
		touchMonitor="\"eGalax Inc. eGalaxTouch EXC3111-5541-08.00.00.00\""
		model_TouchMonitor="xinput map-to-output $touchMonitor $cabo_1366x768-1"
	fi
	if [ $TOUCHMODEL -eq 8 ]; then
		idTouchModels
	fi
	if [ $TOUCHMODEL -eq 9 ]; then
	# Criar atalho Touch Comum sem modelo Monitor
		touchUnknown=1
		touchMonitor="\"TOUCH-MODEL-FROM-XINPUT\""
		model_TouchMonitor="# xinput map-to-output $touchMonitor $cabo_1366x768-1"
	fi
	if [ $TOUCHMODEL -eq 10 ]; then
		menuOptions
	fi
	if [ $TOUCHMODEL -ge 11 ]; then
		echo -e "\n${R1}Opcao incorreta, retornando ao menu${End}" ; pause ; touchModels
	fi
}

idTouchModels() {
	clear
	echo -e "\n\n${G1}SELECAO DE MODELO DE MONITOR TOUCH POR ID${End}\n==================================\n"
	xinput && \
	echo -e "\nInforme o NUMERO ID do modelo desejado"
	read -p "ID do monitor Operador: " TOUCHMODELID
	touchMonitor="$TOUCHMODELID"
	model_TouchMonitor="xinput map-to-output $touchMonitor $cabo_1366x768-1"
}

atalhosresolucao() {

	if [ ! -e "$iconPath/VRPdv.png" ];then
		printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $iconPath >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $appsIco -O $iconPath/img.zip 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o $iconPath/img.zip -d $iconPath 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $iconPath/img.zip 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R $iconPath/*
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R $iconPath/*
	fi

	while IFS= read -r desktopFolder; do
		if [ ! -e "$desktopFolder/lxrandr.desktop" ]; then
			if [ -e "$SHORTCUTPATH/lxrandr.desktop" ]; then
				printf '%s\n' "$PASSWD" | sudo -S cp --remove-destination -p \
					"$SHORTCUTPATH/lxrandr.desktop" "$desktopFolder/" >/dev/null 2>&1
			fi
		fi
	done < <(setshortcutfiles)
	
	while IFS= read -r desktopFolder; do
		if [ ! -e "$desktopFolder/lxqt-config-monitor.desktop" ]; then
			if [ -e "$SHORTCUTPATH/lxqt-config-monitor.desktop" ]; then
				printf '%s\n' "$PASSWD" | sudo -S cp --remove-destination -p \
					"$SHORTCUTPATH/lxqt-config-monitor.desktop" "$desktopFolder/" >/dev/null 2>&1
			fi
		fi
	done < <(setshortcutfiles)
	
	if [ ! -e "/etc/xdg/autostart/anydesk_global_tray.desktop" ];then
		printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "[Desktop Entry]\nName=AnyDesk Tray\nGenericName=AnyDeskTray\nX-GNOME-FullName=AnyDesk\nExec=/usr/bin/anydesk --tray\nIcon=anydesk\nTerminal=false\nType=Application" | sudo tee -a /etc/xdg/autostart/anydesk_global_tray.desktop >/dev/null 2>&1
	fi
		
			# Criacao de atalho $SHORTCUTPATH
			printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $SHORTCUTPATH/$APPNAME.desktop >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "[Desktop Entry]\n\nName=$APPNAME\nExec=$exec\nIcon=$icon\nType=Application\nPath=$path" | sudo tee -a $SHORTCUTPATH/$APPNAME.desktop >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x $SHORTCUTPATH/$APPNAME.desktop >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $SHORTCUTPATH/$APPNAME.desktop >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" $SHORTCUTPATH/$APPNAME.desktop >/dev/null 2>&1		
			# Criacao de atalho /etc/xdg/autostart
			printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $pathAutostart >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $pathAutostart_1604 >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $pathAutostart_1804 >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p $SHORTCUTPATH/$APPNAME.desktop /etc/xdg/autostart >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" /etc/xdg/autostart/$APPNAME.desktop >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /etc/xdg/autostart/$APPNAME.desktop >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x /etc/xdg/autostart/$APPNAME.desktop >/dev/null 2>&1
			while IFS= read -r desktopFolder; do
				# Remove os atalhos antigos
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/$APPNAME.desktop" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/pdv.desktop" >/dev/null 2>&1

				# Copia o novo atalho
				printf '%s\n' "$PASSWD" | sudo -S cp --remove-destination -p \
					"$SHORTCUTPATH/$APPNAME.desktop" "$desktopFolder/" >/dev/null 2>&1
			done < <(setshortcutfiles)
			
			# Bkp /pdv/util/.scripts/pdv.sh
			date=$(date '+%Y-%m-%d_%H:%M:%S')
			printf '%s\n' "$PASSWD" | sudo -S -p '' mv $pathSH $pathSHdate >/dev/null 2>&1

			if [[ ${APPNAME} == "VRPdv" ]]; then
				printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "$SHEBANG\n\npkill -9 java\n\nxrandr -s 800x600\nxset -dpms\nxset s off\nxset s noblank\n\nsleep 1\necho \"\$PASSWD\" | sudo -S rm -rf /var/lock/LCK*\nsleep 1\njava -jar /pdv/exec/VRPdv.jar" | sudo tee -a "$pathSH" >/dev/null 2>&1

				while IFS= read -r desktopFolder; do
					printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/Self.desktop" >/dev/null 2>&1
					printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/SelfConfig.desktop" >/dev/null 2>&1
					printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/Touch.desktop" >/dev/null 2>&1
					printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/TouchConfig.desktop" >/dev/null 2>&1
				done < <(setshortcutfiles)
			fi
			if [[ ${APPNAME} == "Self" ]]; then
				printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "$SHEBANG\n\npkill -9 java\n\nxrandr -s 1024x768\nxset -dpms\nxset s off\nxset s noblank\n\nsleep 1\necho \"\$PASSWD\" | sudo -S rm -rf /var/lock/LCK*\nsleep 1\njava -jar /pdv/exec/VRPdv.jar -selfcheckout" | sudo tee -a "$pathSH" >/dev/null 2>&1

				while IFS= read -r desktopFolder; do
					printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/VRPdv.desktop" >/dev/null 2>&1
					printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/Touch.desktop" >/dev/null 2>&1
					printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/TouchConfig.desktop" >/dev/null 2>&1
				done < <(setshortcutfiles)
			fi
			if [[ ${APPNAME} == "Touch" ]]; then
				printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "$SHEBANG\n\npkill -9 java\n\n$touchmode_800x600\n$touchmode_1366x768\n$touchmode_1024x768\nxrandr --addmode $cabo_800x600-1 800x600_touch\nxrandr --addmode $cabo_1366x768-1 $touchresolucao\nxrandr --output $cabo_800x600-1 --mode 800x600_touch --pos 0x0 --rotate normal --output $cabo_1366x768-1 --primary --mode $touchresolucao --pos 800x0 --rotate normal\n\nxset -dpms\nxset s off\nxset s noblank\n\npkill -9 java\nsleep 1\n$model_TouchMonitor\n\nsleep 1\necho \"\$PASSWD\" | sudo -S rm -rf /var/lock/LCK*\nsleep 1\npkill -9 java\njava -jar /pdv/exec/VRPdv.jar -touchscreen" | sudo tee -a "$pathSH" >/dev/null 2>&1

				while IFS= read -r desktopFolder; do
					printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/Self.desktop" >/dev/null 2>&1
					printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/SelfConfig.desktop" >/dev/null 2>&1
					printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/VRPdv.desktop" >/dev/null 2>&1
				done < <(setshortcutfiles)
			fi

		printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" $pathSH >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $pathSH >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x $pathSH >/dev/null 2>&1

			createRegisterLog "ResolucaoAtalho_PDV-$APPNAME"
}

atalhoConfig() {

	if [ ! -e "$iconPath/VRPdv.png" ];then
		printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $iconPath >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $appsIco -O $iconPath/img.zip 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o $iconPath/img.zip -d $iconPath 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $iconPath/img.zip 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R $iconPath/*
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R $iconPath/*
	fi
		
	# Bkp /pdv/util/.scripts/pdvConfig.sh
	date=$(date '+%Y-%m-%d_%H:%M:%S')
	printf '%s\n' "$PASSWD" | sudo -S -p '' mv $pathSHConfig $pathSHConfigdate >/dev/null 2>&1

	while IFS= read -r desktopFolder; do
		printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/$APPNAME.desktop" >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/ConfigPDV.desktop" >/dev/null 2>&1
	done < <(setshortcutfiles)

	echo \"\$PASSWD\" | sudo -S rm -rf $SHORTCUTPATH/$APPNAME.desktop >/dev/null 2>&1
	echo \"\$PASSWD\" | sudo -S rm -rf $SHORTCUTPATH/ConfigPDV.desktop >/dev/null 2>&1
	
	# Criacao de atalho
	printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "[Desktop Entry]\n\nName=$APPNAME\nExec=$execConfig\nIcon=$icon\nType=Application\nPath=$path" | sudo tee -a $SHORTCUTPATH/$APPNAME.desktop >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $SHORTCUTPATH/$APPNAME.desktop >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" $SHORTCUTPATH/$APPNAME.desktop >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x $SHORTCUTPATH/$APPNAME.desktop >/dev/null 2>&1
	while IFS= read -r desktopFolder; do
    	printf '%s\n' "$PASSWD" | sudo -S cp --remove-destination -p \
        "$SHORTCUTPATH/$APPNAME.desktop" "$desktopFolder/" >/dev/null 2>&1
	done < <(setshortcutfiles)

		if [[ ${APPNAME} == "PDVConfig" ]]; then
			printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "$SHEBANG\n\npkill -9 java\n\nxrandr -s 800x600\nxset -dpms\nxset s off\nxset s noblank\n\nsleep 1\necho \"\$PASSWD\" | sudo -S rm -rf /var/lock/LCK*\nsleep 1\njava -jar /pdv/exec/VRPdv.jar -config" | sudo tee -a $pathSHConfig >/dev/null 2>&1

			while IFS= read -r desktopFolder; do
				if [ -e "$desktopFolder/VRPdv.desktop" ]; then
					# Remove arquivos na pasta Desktop
					printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/SelfConfig.desktop" >/dev/null 2>&1
					printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/TouchConfig.desktop" >/dev/null 2>&1

					# Remove arquivos no SHORTCUTPATH
					printf '%s\n' "$PASSWD" | sudo -S rm -rf "$SHORTCUTPATH/SelfConfig.desktop" >/dev/null 2>&1
					printf '%s\n' "$PASSWD" | sudo -S rm -rf "$SHORTCUTPATH/TouchConfig.desktop" >/dev/null 2>&1
				fi
			done < <(setshortcutfiles)
		fi
		if [[ ${APPNAME} == "SelfConfig" ]]; then
			printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "$SHEBANG\n\npkill -9 java\n\nxrandr -s 1024x768\nxset -dpms\nxset s off\nxset s noblank\n\nsleep 1\necho \"\$PASSWD\" | sudo -S rm -rf /var/lock/LCK*\nsleep 1\njava -jar /pdv/exec/VRPdv.jar -selfcheckout -mouse -config" | sudo tee -a $pathSHConfig >/dev/null 2>&1
			while IFS= read -r desktopFolder; do
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/VRPdv.desktop" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$SHORTCUTPATH/VRPdv.desktop" >/dev/null 2>&1

				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/Touch.desktop" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$SHORTCUTPATH/Touch.desktop" >/dev/null 2>&1

				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/TouchConfig.desktop" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$SHORTCUTPATH/TouchConfig.desktop" >/dev/null 2>&1
			done < <(setshortcutfiles)
		fi
		if [[ ${APPNAME} == "TouchConfig" ]]; then
			printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "$SHEBANG\n\npkill -9 java\n\n$touchmode_800x600\n$touchmode_1366x768\n$touchmode_1024x768\nxrandr --addmode $cabo_800x600-1 800x600_touch\nxrandr --addmode $cabo_1366x768-1 $touchresolucao\nxrandr --output $cabo_800x600-1 --mode 800x600_touch --pos 0x0 --rotate normal --output $cabo_1366x768-1 --primary --mode $touchresolucao --pos 800x0 --rotate normal\n\nxset -dpms\nxset s off\nxset s noblank\n\npkill -9 java\nsleep 1\n$model_TouchMonitor\n\nsleep 1\necho \"\$PASSWD\" | sudo -S rm -rf /var/lock/LCK*\nsleep 1\npkill -9 java\njava -jar /pdv/exec/VRPdv.jar -touchscreen -mouse -config" | sudo tee -a $pathSHConfig >/dev/null 2>&1
			while IFS= read -r desktopFolder; do
				# Remover VRPdv.desktop
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/VRPdv.desktop" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$SHORTCUTPATH/VRPdv.desktop" >/dev/null 2>&1

				# Remover Self.desktop
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/Self.desktop" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$SHORTCUTPATH/Self.desktop" >/dev/null 2>&1

				# Remover SelfConfig.desktop
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/SelfConfig.desktop" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$SHORTCUTPATH/SelfConfig.desktop" >/dev/null 2>&1
			done < <(setshortcutfiles)
		fi
		if [[ ${APPNAME} == "SelfConfig" ]]; then
			printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "$SHEBANG\n\npkill -9 java\n\nxrandr -s 1024x768\nxset -dpms\nxset s off\nxset s noblank\n\nsleep 1\necho \"\$PASSWD\" | sudo -S rm -rf /var/lock/LCK*\nsleep 1\njava -jar /pdv/exec/VRPdv.jar -selfcheckout -mouse -config" | sudo tee -a $pathSHConfig >/dev/null 2>&1
			while IFS= read -r desktopFolder; do
				# Remover VRPdv.desktop
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/VRPdv.desktop" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$SHORTCUTPATH/VRPdv.desktop" >/dev/null 2>&1

				# Remover Touch.desktop
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/Touch.desktop" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$SHORTCUTPATH/Touch.desktop" >/dev/null 2>&1

				# Remover TouchConfig.desktop
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/TouchConfig.desktop" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$SHORTCUTPATH/TouchConfig.desktop" >/dev/null 2>&1
			done < <(setshortcutfiles)
		fi
		if [[ ${APPNAME} == "TouchConfig" ]]; then
			printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "$SHEBANG\n\npkill -9 java\n\n$touchmode_800x600\n$touchmode_1366x768\n$touchmode_1024x768\nxrandr --addmode $cabo_800x600-1 800x600_touch\nxrandr --addmode $cabo_1366x768-1 $touchresolucao\nxrandr --output $cabo_800x600-1 --mode 800x600_touch --pos 0x0 --rotate normal --output $cabo_1366x768-1 --primary --mode $touchresolucao --pos 800x0 --rotate normal\n\nxset -dpms\nxset s off\nxset s noblank\n\npkill -9 java\nsleep 1\n$model_TouchMonitor\n\nsleep 1\necho \"\$PASSWD\" | sudo -S rm -rf /var/lock/LCK*\nsleep 1\npkill -9 java\njava -jar /pdv/exec/VRPdv.jar -touchscreen -mouse -config" | sudo tee -a $pathSHConfig >/dev/null 2>&1
			while IFS= read -r desktopFolder; do
				# Remover VRPdv.desktop
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/VRPdv.desktop" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$SHORTCUTPATH/VRPdv.desktop" >/dev/null 2>&1

				# Remover Self.desktop
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/Self.desktop" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$SHORTCUTPATH/Self.desktop" >/dev/null 2>&1

				# Remover SelfConfig.desktop
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/SelfConfig.desktop" >/dev/null 2>&1
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$SHORTCUTPATH/SelfConfig.desktop" >/dev/null 2>&1
			done < <(setshortcutfiles)
		fi
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" -R $pathSHConfig >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $pathSHConfig >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x $pathSHConfig >/dev/null 2>&1
		
			createRegisterLog "AtalhoConfig_PDV-$APPNAME"
}

atalhoTestaPeriferico() {
while IFS= read -r desktopFolder; do
    if [ ! -e "$desktopFolder/VRTestaPeriferico.desktop" ]; then

        # Criação da pasta de ícones e download, se necessário
        if [ ! -e "$iconPath/VRTestaPeriferico.png" ]; then
            printf '%s\n' "$PASSWD" | sudo -S mkdir -p -m 777 "$iconPath" >/dev/null 2>&1
            printf '%s\n' "$PASSWD" | sudo -S wget -c --no-check-certificate "$appsIco" -O "$iconPath/img.zip" 2>/dev/null
            printf '%s\n' "$PASSWD" | sudo -S unzip -q -o "$iconPath/img.zip" -d "$iconPath" 2>/dev/null
            printf '%s\n' "$PASSWD" | sudo -S rm -rf "$iconPath/img.zip" 2>/dev/null
            printf '%s\n' "$PASSWD" | sudo -S chmod 777 -R "$iconPath"/* >/dev/null 2>&1
            printf '%s\n' "$PASSWD" | sudo -S chown "nobody:nogroup" -R "$iconPath"/* >/dev/null 2>&1
        fi

        # Criação do atalho VRTestaPeriferico
        printf '%s\n' "$PASSWD" | sudo -S tee "$desktopFolder/VRTestaPeriferico.desktop" >/dev/null 2>&1 <<EOF
[Desktop Entry]

Name=VRTestaPeriferico
Exec=java -jar /pdv/exec/VRPdv.jar -test
Icon=/pdv/exec/img/VRTestaPeriferico.png
Type=Application
Path=/pdv/exec
EOF

        printf '%s\n' "$PASSWD" | sudo -S chown "$USER:firebird" "$desktopFolder/VRTestaPeriferico.desktop" >/dev/null 2>&1
        printf '%s\n' "$PASSWD" | sudo -S chmod 777 "$desktopFolder/VRTestaPeriferico.desktop" >/dev/null 2>&1
        printf '%s\n' "$PASSWD" | sudo -S chmod +x "$desktopFolder/VRTestaPeriferico.desktop" >/dev/null 2>&1
    fi
done < <(setshortcutfiles)

	createRegisterLog "AtalhoTestaPeriferico"
}

createShortcutVR() {
	
	clear
	echo ""
	separador
	echo -e "${B1}1. INSTALAR atalho via Rede (/pdv_vr)${End}"
	echo -e "${B1}2. INSTALAR atalho via Local (/vr/exec)${End}"
	echo -e "${R1}3. DESINSTALAR${End}"
	echo -e "${LNFP}99. Retornar ao MENU.${End}"
    read -p "Escolha o tipo de ajuste: " SHORTCUTVROPTION

		if [ -z "$SHORTCUTVROPTION" ] || ! [[ "$SHORTCUTVROPTION" =~ ^[0-9]+$ ]]; then
			echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; createShortcutVR
		fi	
		if [ $SHORTCUTVROPTION -eq 1 ]; then	
			local checkVariable=INSTALL
			local checkVariable2=NOT_LOCAL
		fi
		if [ $SHORTCUTVROPTION -eq 2 ]; then
			local checkVariable=INSTALL	
			local checkVariable2=INSTALL_LOCAL
		fi
		if [ $SHORTCUTVROPTION -eq 3 ]; then	
			local checkVariable=UNINSTALL
		fi
		if [ $SHORTCUTVROPTION -eq 99 ]; then	
			menuOptions
		fi
		if [ $SHORTCUTVROPTION -ge 4 ]; then
			if [ $SHORTCUTVROPTION -le 98 ]; then	
			echo -e "\n${R1}Opcao incorreta, retornando ao menu CriarAtalhosVRApps${End}" ; pause ; createShortcutVR
			fi
		fi

	echo ""
	separador
	echo "1. VRAdm"
	echo "2. VRAtacado"
	echo "3. VRAtacarejo"
	echo "4. VRAutorizador"
	echo "5. VRCaixa"
	echo "6. VRCash"
	echo "7. VRConcentrador"
	echo "8. VREmissorEtiqueta"
	echo "9. VRFicha"
	echo "10. VRFood"
	echo "11. VRFrente"
	echo "12. VRMaster"
    echo -e "${LNFP}99. Retornar ao MENU.${End}"
    read -p "Escolha o tipo de ajuste: " NAMEAPP
		
		if [ -z "$NAMEAPP" ] || ! [[ "$NAMEAPP" =~ ^[0-9]+$ ]]; then
			echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; createShortcutVR
		fi
		if [ $NAMEAPP -eq 1 ]; then	
			VRAPPNAME=VRAdm
		fi
		if [ $NAMEAPP -eq 2 ]; then	
			VRAPPNAME=VRAtacado
		fi
		if [ $NAMEAPP -eq 3 ]; then	
			VRAPPNAME=VRAtacarejo
		fi
		if [ $NAMEAPP -eq 4 ]; then	
			VRAPPNAME=VRAutorizador
		fi
		if [ $NAMEAPP -eq 5 ]; then	
			VRAPPNAME=VRCaixa
		fi
		if [ $NAMEAPP -eq 6 ]; then	
			VRAPPNAME=VRCash
		fi
		if [ $NAMEAPP -eq 7 ]; then	
			VRAPPNAME=VRConcentrador
		fi
		if [ $NAMEAPP -eq 8 ]; then	
			VRAPPNAME=VREmissorEtiqueta
		fi
		if [ $NAMEAPP -eq 9 ]; then	
			VRAPPNAME=VRFicha
		fi
		if [ $NAMEAPP -eq 10 ]; then	
			VRAPPNAME=VRFood
		fi
		if [ $NAMEAPP -eq 11 ]; then	
			VRAPPNAME=VRFrente
		fi
		if [ $NAMEAPP -eq 12 ]; then	
			VRAPPNAME=VRMaster
		fi
		if [ $NAMEAPP -eq 99 ]; then	
			menuOptions
		fi
		if [ $NAMEAPP -ge 13 ]; then
			if [ $NAMESITEF -le 98 ]; then	
			echo -e "\n${R1}Opcao incorreta, retornando ao menu Sitef${End}" ; pause ; createShortcutVR
			fi
		fi
		
if [[ ${checkVariable} == "UNINSTALL" ]]; then
	while IFS= read -r desktopFolder; do
		printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/$VRAPPNAME.desktop" >/dev/null 2>&1
	done < <(setshortcutfiles)
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $SHORTCUTPATH/$VRAPPNAME.desktop >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /vr/exec/$VRAPPNAME.sh >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /vr/exec/$VRAPPNAME.jar >/dev/null 2>&1
	
	echo -e "\n${B1}$VRAPPNAME desinstalado.${End}"
	
	createRegisterLog "AtalhoRemovido_$VRAPPNAME"
fi

if [[ ${checkVariable} == "INSTALL" ]]; then
		setcheckvariable=1
		mountServerShared

		printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 /vr/exec >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 /pdv/exec/img >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R /vr/* >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown nobody:nogroup -R /vr/* >/dev/null 2>&1

		if [ -e "$iconPath/$VRAPPNAME.ico" ]; then
			printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $iconPath/$VRAPPNAME.ico >/dev/null 2>&1
		fi
		if [ -e "$iconPath/img.zip" ]; then
			printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $iconPath/img.zip >/dev/null 2>&1
		fi
		printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $appsIco -O $iconPath/img.zip 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o $iconPath/img.zip -d $iconPath 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $iconPath/img.zip 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R $iconPath/* 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R $iconPath/* 2>/dev/null
		
		if [ -e "$SHORTCUTPATH/$VRAPPNAME.desktop" ]; then
			printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $SHORTCUTPATH/$VRAPPNAME.desktop >/dev/null 2>&1
		fi

	if [[ ${checkVariable2} == "INSTALL_LOCAL" ]]; then
		echo -e "[Desktop Entry]\n\nName=$VRAPPNAME\nExec=/vr/exec/java -jar /vr/exec/$VRAPPNAME.jar\nIcon=$iconPath/$VRAPPNAME.png\nType=Application\nPath=/vr/exec" | sudo tee -a $SHORTCUTPATH/$VRAPPNAME.desktop >/dev/null 2>&1
		echo -e "${Y1}⚠️${End} [INFO] Validando arquivos do Servidor para copiar localmente ${Y1}⚠️${End}"
		if [ -e "/pdv_vr/exec/$VRAPPNAME.jar" ]; then
			echo -e "${Y1}⚠️${End} [INFO] Copiando "/pdv_vr/exec/$VRAPPNAME.jar" ${Y1}⚠️${End}"
			printf '%s\n' "$PASSWD" | sudo -S -p '' cp -p --remove-destination "/pdv_vr/exec/$VRAPPNAME.jar" "/vr/exec" >/dev/null 2>&1
			echo -e "${Y1}⚠️${End} [INFO] Copiando /pdv_vr/exec/lib ${Y1}⚠️${End}"
			printf '%s\n' "$PASSWD" | sudo -S -p '' cp -r -p --remove-destination "/pdv_vr/exec/lib" "/vr/exec" >/dev/null 2>&1
			
			shopt -s nullglob
			jars=(/vr/exec/*.jar)
			libs=(/vr/exec/lib/*)

			if [ ${#jars[@]} -gt 0 ]; then
				echo -e "\n${G1}✅${End} - ${B1}[INFO] Arquivos .jar copiados com sucesso.${End}"
			else
				echo -e "\n${R1}❌${End} - ${R1}[ERRO] Falha ao copiar arquivos .jar para /vr/exec${End}"
				pause
			fi

			if [ ${#libs[@]} -gt 0 ]; then
				echo -e "\n${G1}✅${End} - ${B1}[INFO] Pasta /vr/exec/lib copiada com sucesso.${End}"
			else
				echo -e "\n${R1}❌${End} - ${R1}[ERRO] Pasta /vr/exec/lib está vazia. Caso seja algum app que dependa dela, nao sera possivel executar.${End}"
				pause
			fi
			shopt -u nullglob
		else
			echo -e "${R1}❌${End} -[FALHA] Arquivo "/pdv_vr/exec/$VRAPPNAME.jar" nao encontrado no servidor - ${R1}❌${End} -"
			pause ; menuOptions
		fi
	else
		echo -e "[Desktop Entry]\n\nName=$VRAPPNAME\nExec=/vr/exec/$VRAPPNAME.sh\nIcon=$iconPath/$VRAPPNAME.png\nType=Application\nPath=/vr/exec" | sudo tee -a $SHORTCUTPATH/$VRAPPNAME.desktop >/dev/null 2>&1
	fi

		while IFS= read -r desktopFolder; do
			# Remove o atalho antigo, se existir
			if [ -e "$desktopFolder/$VRAPPNAME.desktop" ]; then
				printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/$VRAPPNAME.desktop" >/dev/null 2>&1
			fi

			# Copia o novo atalho
			printf '%s\n' "$PASSWD" | sudo -S cp --remove-destination -p \
				"$SHORTCUTPATH/$VRAPPNAME.desktop" "$desktopFolder/" >/dev/null 2>&1
		done < <(setshortcutfiles)

	if [[ ${checkVariable2} == "NOT_LOCAL" ]]; then
		if [ ! -e "/vr/exec/$VRAPPNAME.sh" ]; then
			printf '%s\n' "$PASSWD" | sudo -S -p '' touch "/vr/exec/$VRAPPNAME.sh" >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 "/vr/exec/$VRAPPNAME.sh" >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" "/vr/exec/$VRAPPNAME.sh" >/dev/null 2>&1
		fi

		if ! grep -q "java -jar /pdv_vr/exec/$VRAPPNAME.jar" "/vr/exec/$VRAPPNAME.sh" >/dev/null 2>&1; then
			echo -e "$SHEBANG\n\njava -jar /pdv_vr/exec/$VRAPPNAME.jar" | sudo tee -a /vr/exec/$VRAPPNAME.sh >/dev/null 2>&1
		fi
	fi
		
		while IFS= read -r desktopFolder; do
			printf '%s\n' "$PASSWD" | sudo -S chmod +x "$desktopFolder/$VRAPPNAME.desktop" >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S chmod 777 "$desktopFolder/$VRAPPNAME.desktop" >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S chown nobody:nogroup "$desktopFolder/$VRAPPNAME.desktop" >/dev/null 2>&1
		done < <(setshortcutfiles)

		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x "$SHORTCUTPATH/$VRAPPNAME.desktop" >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x "/vr/exec/$VRAPPNAME.sh" >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 "$SHORTCUTPATH/$VRAPPNAME.desktop" >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 "/vr/exec/$VRAPPNAME.sh" >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown nobody:nogroup "$SHORTCUTPATH/$VRAPPNAME.desktop" >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown nobody:nogroup "/vr/exec/$VRAPPNAME.sh" >/dev/null 2>&1

		echo -e "\n${B1}$VRAPPNAME instalado.${End}"

		if [ -e "/pdv_vr/vr.properties" ]; then
			printf '%s\n' "$PASSWD" | sudo -S -p '' cp /pdv_vr/vr.properties /vr/vr_Servidor.properties >/dev/null 2>&1
			vrpropertiesCheck
		else
			echo -e "\nArquivo /pdv_vr/vr.properties não existe na rede\nPortanto o atalho foi configurado mas nao o vr.properties"
		fi
		
		createRegisterLog "Atalho_$VRAPPNAME"
fi
}

createAnyDesk() {
	# Cria o atalho original em SHORTCUTPATH
	printf '%s\n' "$PASSWD" | sudo -S -p '' bash -c "echo -e '[Desktop Entry]
Name=AnyDesk
GenericName=AnyDesk
X-GNOME-FullName=AnyDesk
Exec=anydesk
Icon=anydesk
Terminal=false
TryExec=anydesk
Type=Application
Categories=Network;GTK;' > '$SHORTCUTPATH/$APPNAME.desktop'"

	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x "$SHORTCUTPATH/$APPNAME.desktop" >/dev/null 2>&1

	# Usa a função setshortcutfiles para replicar o atalho nos diretórios Desktop válidos
	while IFS= read -r desktopFolder; do
		# Copia o atalho usando bash -c para preservar o conteúdo
		printf '%s\n' "$PASSWD" | sudo -S bash -c "cat \"$SHORTCUTPATH/$APPNAME.desktop\" > \"$desktopFolder/$APPNAME.desktop\""

		# Torna o atalho executável
		printf '%s\n' "$PASSWD" | sudo -S chmod +x "$desktopFolder/$APPNAME.desktop" >/dev/null 2>&1
	done < <(setshortcutfiles)

	# Registro de log
	createRegisterLog "AtalhoAnyDesk"

	# Cria autostart global do tray, se ainda não existir
	if [ ! -e "/etc/xdg/autostart/anydesk_global_tray.desktop" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' bash -c "echo -e '[Desktop Entry]
Name=AnyDesk Tray
GenericName=AnyDeskTray
X-GNOME-FullName=AnyDesk
Exec=/usr/bin/anydesk --tray
Icon=anydesk
Terminal=false
Type=Application' > /etc/xdg/autostart/anydesk_global_tray.desktop"

		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x /etc/xdg/autostart/anydesk_global_tray.desktop >/dev/null 2>&1
	fi
}

menubiometrias() {
    clear
	echo ""
	separador
    echo "1. Hamster DX;"
    echo "2. Futronic;"
    echo -e "${LNFP}3. Menu Principal;${End}"
	echo "4. Sair;"
    read -p "Escolha o tipo de ajuste: " BIOMETRIATYPE

		if [ -z "$BIOMETRIATYPE" ] || ! [[ "$BIOMETRIATYPE" =~ ^[0-9]+$ ]]; then
			echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; menubiometrias
		fi
		if [ $BIOMETRIATYPE -eq 1 ]; then
			menuHamsterDX
		fi
		if [ $BIOMETRIATYPE -eq 2 ]; then
			setcheckvariable=1
			libslinux=futronicso
			echo -e "\nO Futronics apenas utiliza libs especificas para funcionamento\nEssa opcao ira baixar e inserir tais libs.\n"
			atualizarLibsPDV
		fi
		if [ $BIOMETRIATYPE -eq 3 ]; then
			menuOptions
		fi
		if [ $BIOMETRIATYPE -eq 4 ]; then
			exit
		fi
		if [ $BIOMETRIATYPE -ge 5 ]; then	
			echo -e "\n${R1}Opcao incorreta${End}" ; pause ; menubiometrias			
		fi
}


menuHamsterDX() {
    clear
	startCheck
	echo ""
	separador
	echo -e "\nLinux Versao: $LINUX_VERSION / $vrscompatible"
	echo -e "\nKernel Versao: $LINUX_KERNEL / $kernelcompatible"
	separador
    echo "1. INSTALAR Hamster DX;"
    echo "2. DESINSTALAR Hamster DX;"
    echo "3. Iniciar App de teste Hamster DX;"
    echo "4. REINSTALAR Hamster DX; (Utilizar apenas quando ja fez a instalacao e gostaria de reinstalar)"
	echo "5. Sair."
    read -p "Escolha o tipo de ajuste: " HAMSTERTYPE

		if [ -z "$HAMSTERTYPE" ] || ! [[ "$HAMSTERTYPE" =~ ^[0-9]+$ ]]; then
			echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; menuHamsterDX
		fi
		if [ $HAMSTERTYPE -eq 1 ]; then
			installHamsterDX
		fi
		if [ $HAMSTERTYPE -eq 2 ]; then
			uninstallHamsterDX
		fi
		if [ $HAMSTERTYPE -eq 3 ]; then
			if [ ! -e "/pdv/util/HamsterDX/eNBSP_SDK_Linux_v1.851/eNBSP_SDK_v1.851_x86/eNBSP-1.8.5-1/eNBSP-1.8.5-1/eNBSP/bin/NBioBSP_Demo" ]; then
				clear ; echo -e "${R1}\nApp de Teste de dispositivo nao identificado, por favor realize a instalacao completa do Hamster DX com a opcao 1. INSTALAR Hamster DX ${End}\n" ; read -n 1 -s -r -p "Press to Continue . . ." ; menuHamsterDX
			else 
				printf '%s\n' "$PASSWD" | sudo -S -p '' ./NBioBSP_Demo
			fi
			menuOptions
		fi
		if [ $HAMSTERTYPE -eq 4 ]; then
			reinstallHamsterDXcheck=ok
			uninstallHamsterDX
			installHamsterDX

			createRegisterLog "HamsterDX_Reinstall"
			menuOptions
		fi
		if [ $HAMSTERTYPE -eq 5 ]; then
			menuOptions
		fi
		if [ $HAMSTERTYPE -ge 6 ]; then	
			echo -e "\n${R1}Opcao incorreta${End}" ; pause ; menuHamsterDX			
		fi
}

installHamsterDX() {
	echo ""
	if [[ ${hamsterDx} == "notok" ]]; then
		clear
		echo ""
		echo -e "${R1}Versao do Kernel nao apta para o HamsterDX${End}\n" 
		echo "1) Continuar o processo de Instalacao"
		echo -e "${LNFP}2) Retornar ao menu Central${End}"
		echo "3) Sair do Script"
		read -p "Opcao:" OPTHAMSTERNOTOK
				
		if [ -z "$OPTHAMSTERNOTOK" ] || ! [[ "$OPTHAMSTERNOTOK" =~ ^[0-9]+$ ]]; then
			echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; menuOptions
		fi
		if [ $OPTHAMSTERNOTOK -eq 1 ]; then
			:
		fi
		if [ $OPTHAMSTERNOTOK -eq 2 ]; then
			menuOptions
		fi
		if [ $OPTHAMSTERNOTOK -eq 3 ]; then
			exit
		fi
		if [ $OPTHAMSTERNOTOK -ge 4 ]; then
			echo -e "\n${R1}Opcao incorreta, retornando ao menu principal${End}" ; pause ; menuOptions
		fi
	fi

if [[ ${reinstallHamsterDXcheck} != "ok" ]]; then
	internetConnectionCheck
fi
	clear
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/util/Hamster_Linux.zip >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/util/HamsterDX/eNBSP_SDK_Linux_v1.851.tgz >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/util/HamsterDX >/dev/null 2>&1
	
	echo -e "\n${RP1}========================= *** ATENCAO *** =========================${End}\n"
	echo -e "\n${R1}Para correta instalacao da Biometria Hamster, ela deve estar DESCONECTADA do computador no inicio da instalacao, por favor desconecte-a caso esteja conectada e APENAS RECONECTE ao fim da instalacao com a mensagem de solicitacao.${End}\n"
	read -n 1 -s -r -p "Press to Continue. . ." ; clear
	
	echo -e "\nInstalando Hamster DX ...\n"

	killApp java
	
	updateSystem_UpgradeCommand
	sudo apt-get install build-essential

    local commandsList=("sudo apt update"
	"sudo apt-get -f -y install"
	"sudo dpkg --configure -a"
	"sudo ldconfig"
	"sudo apt-get -y install build-essential")
	executeCommands "${commandsList[@]}"

	printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Biometria/HamsterDX_Linux/Hamster_Linux.zip -O /pdv/util/Hamster_Linux.zip &> /dev/null	
		if [ $? -ne 0 ]; then
		clear ; echo "" ; echo -e "${R1}Erro Realizar Download arquivos HamsterDX${End}" ; pause ; printf "\n\n" ; menuOptions
		fi
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o /pdv/util/Hamster_Linux.zip -d /pdv/util/HamsterDX &> /dev/null
		if [ $? -ne 0 ]; then
		clear ; echo "" ; echo -e "${R1}Erro extrair arquivos HamsterDX${End}" ; pause ; printf "\n\n" ; menuOptions
		fi
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/util/Hamster_Linux.zip >/dev/null 2>&1
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' tar -xzvf /pdv/util/HamsterDX/eNBioBSP_Driver_Linux_HamsterDX_v1.0.4-5.1_2018.08.22.tgz -C /pdv/util/HamsterDX
	printf "\n\n"
	printf '%s\n' "$PASSWD" | sudo -S -p '' tar -xzvf /pdv/util/HamsterDX/eNBSP_SDK_Linux_v1.851.tgz -C /pdv/util/HamsterDX
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/util/HamsterDX/eNBSP_SDK_Linux_v1.851.tgz >/dev/null 2>&1
	printf "\n\n"
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x -R /pdv/util/HamsterDX
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R /pdv/util/HamsterDX
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" -R /pdv/util/HamsterDX
	printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p /pdv/util/HamsterDX/libNBioBSP.so /usr/lib
	printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p /pdv/util/HamsterDX/libNBioBSPJNI.so /usr/lib
	printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p /pdv/util/HamsterDX/libNBioBSPISO4JNI.so /usr/lib


	echo -e "${R1}INSTALACAO SERA AUTOMATICA${End}\n${R1}NAO DIGITE NADA POR ENQUANTO, AGUARDE A FINALIZACAO${End}"
	sleep 1
	local hamsterfolderpath="/pdv/util/HamsterDX/eNBioBSP_Driver_Linux_HamsterDX_v1.0.4-5.1_2018.08.22/VenusDrv-v1.0.4-5.1-Ubuntu11.04~Ubuntu18.04-32bit"
	cd $hamsterfolderpath
	warnningInteraction
	sudo ./install.sh
	if [ $? -ne 0 ]; then
		echo -e "\n${R1}Falha Instalador de HamsterDX${End}\n" ; pause ; menuOptions
	fi	
	
	printf "\n\n"
	printf '%s\n' "$PASSWD" | sudo -S -p '' cp -p VenusLib.so /lib

	cd /pdv/util/HamsterDX/eNBSP_SDK_Linux_v1.851/eNBSP_SDK_v1.851_x86/eNBSP-1.8.5-1/eNBSP-1.8.5-1/
	printf '%s\n' "$PASSWD" | sudo -S -p '' ./NBioBSP_Signer <<< "010701-F6B95C1975E63701-22627000F00163FD"
	printf "\n\n"

	cd /pdv/util/HamsterDX/eNBSP_SDK_Linux_v1.851/eNBSP_SDK_v1.851_x86/eNBSP-1.8.5-1/eNBSP-1.8.5-1/eNBSP/bin
	printf '%s\n' "$PASSWD" | safe_apt_get -y install libQtGui*
	printf "\n\n"
	
	
		createRegisterLog "HamsterDX_Install"
	
	echo -e "\n${RP1}========================= *** ATENCAO *** =========================${End}\n"
	echo "Caso a biometria esteja CONECTADA, Desconecte e conecte."
	echo "Caso a biometria esteja DESCONECTADA, APENAS conecte."
	echo -e "Aguarde ela piscar uma luz azul/branca no leitor\n"
	echo -e "${R1}Caso nao pisque, o leitor nao esta sendo reconhecido, troque de porta USB${End}\n"
	echo -e "${B1}Apenas prossiga caso a Biometria tenha piscado a luz azul/branca${End}\n"
	read -n 1 -s -r -p "Pressione qualquer tecla para Iniciar o HamsterDX_Demo . . ."
	printf "\n\n"

	printf '%s\n' "$PASSWD" | sudo -S -p '' ./NBioBSP_Demo ; echo ""
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/util/Hamster_Linux.zip >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/util/HamsterDX/eNBSP_SDK_Linux_v1.851.tgz >/dev/null 2>&1
	# NBioBSP_Demo eNBSP SDK version : 1.8510
}

uninstallHamsterDX() {
	
	echo ""
	internetConnectionCheck

	clear
	echo -e "\n${R1}REMOVENDO HAMSTER DX${End}\n"
	
	killApp java

	printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Biometria/HamsterDX_Linux/Hamster_Linux.zip -O /pdv/util/Hamster_Linux.zip
	printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o /pdv/util/Hamster_Linux.zip -d /pdv/util/HamsterDX
	printf '%s\n' "$PASSWD" | sudo -S -p '' tar -xzvf /pdv/util/HamsterDX/eNBioBSP_Driver_Linux_HamsterDX_v1.0.4-5.1_2018.08.22.tgz -C /pdv/util/HamsterDX
	printf "\n\n"
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x -R /pdv/util/HamsterDX
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R /pdv/util/HamsterDX
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" -R /pdv/util/HamsterDX

	cd /pdv/util/HamsterDX/eNBioBSP_Driver_Linux_HamsterDX_v1.0.4-5.1_2018.08.22/VenusDrv-v1.0.4-5.1-Ubuntu11.04~Ubuntu18.04-32bit
	printf '%s\n' "$PASSWD" | sudo -S -p '' ./uninstall.sh

		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/util/Hamster_Linux.zip >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/util/HamsterDX/eNBSP_SDK_Linux_v1.851.tgz >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/util/HamsterDX >/dev/null 2>&1
		
			createRegisterLog "HamsterDX_Uninstall"

	if [[ ${reinstallHamsterDXcheck} != "ok" ]]; then
		echo -e "\n${RP1}========================= *** ATENCAO *** =========================${End}\n"
		echo -e "${R1}HAMSTER DX DESINSTALADO${End}\n"
		echo -e "${R1}Caso a biometria esteja conectada e deseje reinstalar, DESCONECTE-A do PC antes de prosseguir com a reinstalacao${End}\n"
		pause ; menuOptions
	fi
}

# Essa funcao monta o servidor onde os aplicativos estao hospedados, testa a conexao com o IP e tenta montar com os parametros informados antes de adicionar as linhas no arquivo FSTAB.
mountServerShared() {

if [ $setcheckvariable -ne 1 ]; then
		clear
		echo ""
		echo "----------------------"
		echo "Mapeando pasta /pdv_vr/"
		echo "----------------------"
	
		killApp java
fi

	if [ ! -d "/pdv_vr/" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 /pdv_vr 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R /pdv_vr 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R /pdv_vr 2>/dev/null
	fi

	echo -e "Verificando se /pdv_vr/ esta mapeada...Aguarde...\n"
	shopt -s nullglob
	jars=(/pdv_vr/exec/*.jar)
	if [ ${#jars[@]} -eq 0 ]; then
			clear
			echo -e "\n${R1}/pdv_vr nao mapeada, siga o passo abaixo para mapeamento${End}\n"
			read -p "Digite o IP do servidor onde estao localizados os aplicativos VR: " IPSERVER
			echo -e "\nTestando conexao..."
			ping -c4 $IPSERVER &> /dev/null
		if [ $? -ne 0 ]; then
			echo -e "${R1}Nao houve conexao com o servidor informado, verifique o IP e tente novamente.${End}"
			sleep 2
			exit 0
		else
			echo -e "\nTeste de conexao IP, OK"
			mountPDV_VR_Standard
		fi
	else
		echo -e "\n${B1}Pasta Compartilhada /pdv_vr/ ja mapeada${End}"
	fi
	shopt -u nullglob
}

mountMapingGeneral() {
    # Data/hora atual para anotação
    current_date=$(date '+desativado em %Y-%m-%d %H:%M:%S')

    # Comentar apenas linhas ativas (não comentadas) que montam /pdv_vr/
    printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i "/^[^#].*[[:space:]]\/pdv_vr\// s/$/  # $current_date/" /etc/fstab
    printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i "/^[^#].*[[:space:]]\/pdv_vr\// s/^/#/" /etc/fstab

    # Testa o mapeamento com as credenciais informadas
    printf '%s\n' "$PASSWD" | sudo -S -p '' mount -t cifs "//$IPSERVER/vr" /pdv_vr -o "username=$SRVSHAREDUSER,password=$SRVSHAREDPASSWD,iocharset=utf8,rw,_netdev,vers=2.0" >/dev/null 2>&1

	if [ $? -eq 0 ] && [ -d "/pdv_vr/exec" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' umount /pdv_vr >/dev/null 2>&1

		# Adiciona nova linha ativa no fstab
		printf '%s\n' "$PASSWD" | sudo -S tee -a /etc/fstab >/dev/null <<< "//$IPSERVER/vr /pdv_vr cifs username=$SRVSHAREDUSER,password=$SRVSHAREDPASSWD,iocharset=utf8,rw,_netdev,x-systemd.automount,x-systemd.requires=network-online.target,vers=2.0  0  0"

		printf '%s\n' "$PASSWD" | sudo -S -p '' mount -a >/dev/null 2>&1

		mountstatus=1
	else
		mountstatus=2
	fi

    # Tenta mapeamento com outro usuário se o primeiro falhar
    if [ $mountstatus -eq 2 ]; then
        if [ $mountUserPWstatus -ne 1 ]; then
            mountPDV_VRUserPW
            mountMapingGeneral
        fi
    fi

    # Resultado final
    if [ $mountstatus -eq 1 ]; then
        echo -e "\n${B1}Pasta mapeada com usuario ($SRVSHAREDUSER) e senha($SRVSHAREDPASSWD)${End}"
        date=$(date '+%Y-%m-%d_%H:%M:%S')
        echo "=============================" >> $logs_path/Montagem_pdv_vr.txt
        echo "Mapeamento realizado em $date IP:$IPSERVER User:$SRVSHAREDUSER Password:$SRVSHAREDPASSWD" >> $logs_path/Montagem_pdv_vr.txt
    else
        echo -e "\n${R1}Pasta /pdv_vr/ NAO mapeada\nVerifique o processo de mapeamento manual${End}"
    fi
}

mountPDV_VR_Standard() {
	SRVSHAREDUSER=vr
	SRVSHAREDPASSWD=pdv
	mountMapingGeneral
}

mountPDV_VRUserPW() {
mountUserPWstatus=1
	echo -e "\nFalha mapear via usuario e login padrao, portanto seu servidor utiliza login e senha especificos\nGostaria de testar utilizando Login e Senha do servidor (necessario informa-los) ?"
	read -p "[1] SIM [2] NAO (Retornar Menu): " SRVSHAREDPASS
		if [ $SRVSHAREDPASS -eq 1 ]; then
			read -p "Digite o usuario: " SRVSHAREDUSER
			read -p "Digite a senha: " SRVSHAREDPASSWD
			:
		elif [ $SRVSHAREDPASS -eq 2 ]; then
			menuOptions
		fi
}

# vrpropertiesCheck() {
# vrpropertiescreate
# origem="/pdv_vr/vr.properties"
# destino="/vr/vr.properties"

# palavras_chave=("database.ip" "database.porta" "database.nome" "database.usuario" "database.senha" "system.numeroloja")

# # Loop pelas palavras-chave
# for palavra_chave in "${palavras_chave[@]}"; do
#   if ! grep -q "^$palavra_chave" "$destino" >/dev/null 2>&1; then
#     linha_origem=$(grep "^$palavra_chave" "$origem")
#     if [ -n "$linha_origem" ]; then
# 	  echo "" >> "$destino"
#       sed -i "1i$linha_origem" "$destino"
#     else
#       echo "A palavra-chave '$palavra_chave' não foi adicionada ao arquivo de destino."
# 	  :
#     fi
#   fi
# done
# }

vrpropertiesCheck() {
 vrpropertiescreate
	local origem="/pdv_vr/vr.properties"
	local destino="/vr/vr.properties"

	local patterns=(
		"# ----- CONFIGURACOES DO BANCO DE DADOS ----- #"
        "database.ip"
        "database.porta"
        "database.nome"
        "database.usuario"
        "database.senha"
        "system.numeroloja"
    )
	# echo "[INFO] Limpando linhas antigas..."
    clearLinesFromFile "$destino" "${patterns[@]}"

	# echo "[INFO] Recriando parâmetros de banco..."
    for palavra_chave in "${patterns[@]}"; do
        linha_origem=$(grep -m1 "^$palavra_chave" "$origem")
        if [ -n "$linha_origem" ]; then
            echo "$linha_origem" >> "$destino"
            # echo "[OK] $palavra_chave -> adicionado"
        # else
            # echo "[WARN] $palavra_chave não encontrado no arquivo origem"
        fi
    done

    filepermission "$destino"
}

vrpropertiescreate() {
	if [ ! -e "/vr/vr.properties" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 /vr 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R /vr 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown nobody:nogroup -R /vr 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $propertieslinux -O /vr/vr.properties 2>/dev/null	
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /vr/vr.properties 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown nobody:nogroup /vr/vr.properties 2>/dev/null
	fi
}

installPDV() {

clear
echo -e "\nInstalacao PDV"
	
	internetConnectionCheck
	checkSitefFiles

	killApp java
	setcheckvariable=1
	
	separador
	echo ""
	echo -e "${B1}Atualizacao Linux${End}"
	echo ""

	echo -e "${B1}1. Atualizar Linux${End}"
    echo -e "${R1}2. Atualizar mais tarde (Seguir instalacao sem atualizar Linux)${End}"
    read -p "Escolha o tipo de ajuste: " OPTLINUXUPDATE
	
		if [ -z "$OPTLINUXUPDATE" ] || ! [[ "$OPTLINUXUPDATE" =~ ^[0-9]+$ ]]; then
			echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; menuOptions
		fi	
		if [ $OPTLINUXUPDATE -eq 1 ]; then	
			internetConnectionCheck
			linuxUpdate
		fi
		if [ $OPTLINUXUPDATE -eq 2 ]; then
			createRegisterLog "LinuxNAO_Atualizado"
			sleep 1
		fi
		if [ $OPTLINUXUPDATE -ge 3 ]; then
			echo -e "\n${R1}Opcao incorreta, retornando ao menu principal${End}" ; pause ; menuOptions
		fi

	# Cria atalho AnyDesk
	createAnyDesk
		
		echo -e "\n\n"
		echo =======================================
		echo -e "${B1}Escolha o tipo de PDV a ser instalado${End}"
	    echo "1. PDV Comum."
		echo "2. PDV Touch."
		echo "3. PDV Self."
		echo "4. Sair."
		read -p "Escolha o atalho desejado: " OPTPDVTYPE

		if [ -z "$OPTPDVTYPE" ] || ! [[ "$OPTPDVTYPE" =~ ^[0-9]+$ ]]; then
			echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; installPDV
		fi
		if [ $OPTPDVTYPE -eq 1 ]; then
			# Criar atalho PDV
			APPNAME="VRPdv"
			atalhosresolucao
			APPNAME="PDVConfig"
			atalhoConfig
		fi
		if [ $OPTPDVTYPE -eq 2 ]; then
			# Criar atalho Touch
			clear
			APPNAME="Touch"
			touchModels
			atalhosresolucao
			APPNAME="TouchConfig"
			touchModels
			atalhoConfig
		fi
		if [ $OPTPDVTYPE -eq 3 ]; then
			# Criar atalho Self
			soundOnSelf
			APPNAME="Self"
			atalhosresolucao
			APPNAME="SelfConfig"
			atalhoConfig
		fi
		if [ $OPTPDVTYPE -eq 4 ]; then	
			menuOptions
		fi
		
		if [ $OPTPDVTYPE -ge 5 ]; then	
			echo -e "\n${R1}Opcao incorreta${End}" ; pause ; installPDV			
		fi

createPDVFolders
gruposPDV

echo ""
separador
echo ""
echo "** Instalando ISL Light Client **"
	islOnlineType=LightClient
	islOnline_Dependencias && \
	islOnline_LightClient && \
	islOnline_Atalho && \
	sleep 1
separador
echo ""
echo "1) Mapeando /pdv_vr/ ..."
echo ""

	mountServerShared && \
	sleep 1

separador
echo ""
echo "2) Atualizacao de Libs/Dlls Sitef ..."
	novoClisitefIni
	libSitefVrs=LibSitef_Atual
	setcheckvariable=1
	atualizarClisitef && \
	sleep 1

separador
echo ""	
echo "3) Atualizacao Libs Gerais PDV ..."
	libslinux=vrdefault
	atualizarLibsPDV && \
	sleep 1

separador
echo ""
echo "4) Atualizacao VR Rules ..."
	
	atualizarVRRules && \
	sleep 1
	
separador
echo ""	
echo "5) Copiar VRPdv.jar e vr.properties . . ."
	
	checkVRProperties && \
	atualizarPDV && \
	updateUtilitarioPDV && \
	sleep 1

separador
echo ""	
echo "6) Copiar VR.FDB (Banco do concentrador) ..."
echo -e "\nSera copiado o VR.FDB que existir no caminho /pdv_vr/pdv/database\nSendo possivel que as suas informacoes estejam desatualizadas."
	
	atualizarBancoVR && \
	sleep 1

separador
echo ""	
echo "7) Validando se o java i386 (x86) esta instalado ..."
	
	javaCheckFile && \

	javaInstallReinstall
	sleep 1

separador
echo ""	
echo "8) Reaplicar permissoes ..."

	echo "Aplicando ajuste de Permissoes PDV ..."
	
	disableEnergyScreensaver
	rootBanner
	
	corrigirPermissoes && \
	sleep 1
	
separador
	echo ""	
	echo -e "${B1}INSTALACAO ENCERRADA${End}"
	echo ""	

	createRegisterLog "InstallPDV_Script"
}

createPDVFolders() {
	variable_pdvpaths=("/pdv" "/pdv/arquivoscupom" "/pdv/database" 
	"/pdv/driver" "/pdv/exec" "/pdv/img" "/pdv/log" "/pdv/logpdv" 
	"/pdv/sat" "/pdv/som" "/pdv/util" "/pdv/nfce"
	)
	for variable_pdvpath in "${variable_pdvpaths[@]}"; do
		if [ ! -d "$variable_pdvpath" ]; then
			printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $variable_pdvpath 2>/dev/null
			printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R $variable_pdvpath 2>/dev/null
			printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R $variable_pdvpath 2>/dev/null
		fi
	done
}

swedaSI300() {
    # clear
	internetConnectionCheck
    echo -e "\nDownload e inicializacao do instalador Sweda SI300 ..."
	if [ ! -d "/pdv/util/si300" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/util/si300 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 /pdv/util/si300 2>/dev/null
	fi
	cd /pdv/util/si300 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $si300link -O /pdv/util/si300/SWEDA_Receipt_Printer_Driver-0.1.0.0-Linux-x86-Install.tar 2>/dev/null	
		if [ $? -ne 0 ]; then
		clear ; echo "" ; echo -e "${R1}Erro Realizar Download arquivos SI300${End}" ; pause ; printf "\n\n" ; menuOptions
		fi
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' tar -xf /pdv/util/si300/SWEDA_Receipt_Printer_Driver-0.1.0.0-Linux-x86-Install.tar 2>/dev/null
	
	createRegisterLog "Install_SI300"
	
	clear
	echo -e "\n========================= *** ATENCAO *** ========================="
	echo -e "${RP1}Atencao${End}\nExecute o comando abaixo apos esse script finalizar\nEle deve ser realizado de forma externa ao script\nSelecione-o, copie e cole após o encerramento do script"
	echo -e "cd /pdv/util/si300/ && sudo ./SWEDA_Receipt_Printer_Driver-0.1.0.0-Linux-x86-Install"
	echo -e "\n========================= *** ATENCAO *** =========================\n"
	
	pause ; echo "" ; exit
}

# Funcao responsavel por incluir e remover o som do PDV Self-Checkout.
modifySound() {
    internetConnectionCheck
	clear
	echo ""
	echo -e "${LNFP}====================================${End}"
    echo "1. Incluir som do PDV Self-Checkout;"
    echo "2. Remover som do PDV Self-Checkout;"
    echo "3. Sair."
	echo -e "${LNFP}99. Retornar Menu Principal.${End}"
    read -p "Escolha a modificacao: " SOUND
	if [ -z "$SOUND" ] || ! [[ "$SOUND" =~ ^[0-9]+$ ]]; then
		echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; subMenu
	fi
	if [ $SOUND -eq 1 ]; then
		soundOnSelf
	fi
	if [ $SOUND -eq 2 ]; then
        if [ -d $DIRSOUND ]; then
           printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $DIRSOUND
        fi

		createRegisterLog "DesativaSomSelf"

        echo "Configuracoes de som alteradas com sucesso."
	fi
	if [ $SOUND -eq 3 ]; then
		exit
	fi
		
	if [ $SOUND -ge 4 ]; then
		if [ $SOUND -le 98 ]; then	
		echo -e "\n${R1}Opcao incorreta, retornando ao menu de Apps${End}" ; pause ; subMenu
		fi
	fi
	if [ $SOUND -eq 99 ]; then	
		menuOptions
	fi

}

soundOnSelf() {
	echo "Inserindo Sons Self . . ."
    if [ -d $DIRSOUND ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $DIRSOUND
    fi
    printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $DIRSOUND
    printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate https://storage.googleapis.com/linux-pdv/Jeff/PDV_Files/Sons/Sons_PDVSelf.zip -O $DIRSOUND/som.zip
    printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q $DIRSOUND/som.zip -d $DIRSOUND ; rm -rf $DIRSOUND/som.zip
    printf '%s\n' "$PASSWD" | sudo -S -p '' chmod -R 777 $DIRSOUND/*
    printf '%s\n' "$PASSWD" | sudo -S -p '' chown -R $USER:firebird $DIRSOUND/*
		
	createRegisterLog "AtivaSomSelf"
		
    echo "Configuracoes de som alteradas com sucesso."
}

properties() {

#Descobre versao PDV
if [ ! -z "$ecfcaixa" ]; then
	latest_file=$(ls -t /pdv/logpdv/*.$ecfcaixa 2>/dev/null | head -n1)
	pdvversao=$(grep "INICIANDO PDVVERSAO " "$latest_file" 2>/dev/null | sed -n 's/.*INICIANDO PDVVERSAO \(.*\)/\1/p' | tr '\n' '/')

fi

if [ -e "$propertiespdv" ]; then
	ippdv=$(grep "sat.enderecoservidor=" "$propertiespdv" 2>/dev/null | sed -n 's/.*sat.enderecoservidor=\(.*\)/\1/p')
	ecfcaixa=$(grep "naofiscal.numeroecf=" "$propertiespdv" 2>/dev/null | sed -n 's/.*naofiscal.numeroecf=\(.*\)/\1/p')
	idtoken=$(grep "nfce.idtoken=" "$propertiespdv" 2>/dev/null | sed -n 's/.*nfce.idtoken=\(.*\)/\1/p')
	csc=$(grep "nfce.csc=" "$propertiespdv" 2>/dev/null | sed -n 's/.*nfce.csc=\(.*\)/\1/p')
	senha=$(grep "nfce.certificado.senha=" "$propertiespdv" 2>/dev/null | sed -n 's/.*nfce.certificado.senha=\(.*\)/\1/p')
	tempoconexao=$(grep "nfce.tempoconexao=" "$propertiespdv" 2>/dev/null | sed -n 's/.*nfce.tempoconexao=\(.*\)/\1/p')
	tipoambiente=$(grep "nfce.tipoambiente=" "$propertiespdv" 2>/dev/null | sed -n 's/.*nfce.tipoambiente=\(.*\)/\1/p')
	certificado_diretorio=$(grep "nfce.certificado.diretorio=" "$propertiespdv" 2>/dev/null | sed -n 's/.*nfce.certificado.diretorio=\(.*\)/\1/p')
	diretorio=$(grep "nfce.diretorio=" "$propertiespdv" 2>/dev/null | sed -n 's/.*nfce.diretorio=\(.*\)/\1/p')
	
	checkSatServidor=$(grep "sat.tipocomunicacao=" "$propertiespdv" 2>/dev/null | sed -n 's/.*sat.tipocomunicacao=\(.*\)/\1/p' | while read -r line; do
	  case "$line" in
		0) echo -e "SAT Local";;
		1) echo -e "SAT Compartilhado";;
		2) echo -e "SAT Servidor";;
		*) echo -e "Nao Informado";;
	  esac
	done)
else 
	checkSatServidor="Nao Informado"
fi
if [ -e "/home/$USER/PDV.FDB" ]; then
	sizePDVFDB=$(du -h /home/$USER/PDV.FDB 2>/dev/null)
fi
procqtdade=$(nproc)

checkVPNTEF

	echo ""
	echo -e "- Data de instalacao do Linux: ${R1}$LINUX_INSTALL_DATE${End}"
	echo -e "- Versao do Linux:\n---- Versao: ${R1}$LINUX_VERSION${End}\n---- Kernel: ${R1}$LINUX_KERNEL${End}\n---- Arquitetura: ${R1}$linuxArquitetura${End}"
	echo -e "- Processador: ${R1}$PROCESSADOR | QtdeProcessadores: $procqtdade${End}"
	echo -e "- Memoria Ram: ${R1}$MEMORY_RAM${End}"
	echo -e "- Versao Java: ${R1}$java_version $java_architeture${End}"
	echo -e "- Data Install Java (java-8-openjdk-i386): ${R1}$java_installdate${End}"
	echo -e "- Data Install Firebird: ${R1}$firebird_installdate${End}"
	echo -e "- Ip Atual: ${R1}$ip_address${End}"
	echo -e "- SAT Infos"
	echo -e "---- Sat Servidor: $checkSatServidor"
	echo -e "---- IP Sat Servidor: ${R1}$ippdv${End}"
	echo -e "- NFCe Infos"
	echo -e "---- ID_Token: ${R1}$idtoken${End}"
	echo -e "---- CSC: ${R1}$csc${End}"
	echo -e "---- Senha Certificado: ${R1}$senha${End}"
	echo -e "---- Tempo Conexao: ${R1}$tempoconexao${End}"
	echo -e "---- Tipo Ambiente: ${R1}$tipoambiente${End}"
	echo -e "---- Diretorio Certificado: ${R1}$certificado_diretorio${End}"
	echo -e "---- Diretorio: ${R1}$diretorio${End}"
	echo -e "- Numero de ECF: ${R1}$ecfcaixa${End}"
	echo -e "- Versao PDV: $pdvversao"
	echo -e "- Tamanho PDV.FDB: ${R1}$sizePDVFDB${End}"
	echo -e "- Sitef Status"
	echo -e "---- ${COLOR_TLS_FILE}VPN SitefExpress (TLS) Status:${End} $VPNSTATUS"
	echo -e "---- ${COLOR_VR}Token_VRProperties:${End} $TOKEN_VR | ${COLOR_CONFITLS}Token_ConfiTLS:${End} $TOKEN_CONFITLS "
	echo -e "---- Versao Dll Sitef: $libSitefversion"
	# echo -e "- Anydesk Versao: $anydesk_version"
	echo ""
	echo -e "- Senha Sudo: ${R1}$PASSWD${End}"
}

autoLogin() {
    # Declaracao variavel auxiliar onde recebera o nome do arquivo de configuracao do display manager
    local AUX
    AUX='/etc/sddm.conf'
    # Teste para verificar se o arquivo existe, caso exista e removido
    if [ -e "$AUX" ]; then
        printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "$AUX"
    fi
    # Criacao de arquivo com os dados de usuario para autoLogin
printf '%s\n' "$PASSWD" | sudo -S -p '' tee "$AUX" > /dev/null << EOF
[Autologin]
User=$USER
Session=Lubuntu
EOF
	
	createRegisterLog "AutoLogin_Linux_20.04"
}

renamePDVFDB() {
	if [ -e "/home/$USER/PDV.FDB" ]; then
		date=$(date '+%Y-%m-%d_%H:%M:%S')
		printf '%s\n' "$PASSWD" | sudo -S -p '' mv /home/$USER/PDV.FDB /home/$USER/PDV-$date.FDB && echo -e "\n${B1}Banco renomeado com sucesso${End}" || echo -e "\n${R1}Erro ao renomear banco PDV.FDB${End}"
		createRegisterLog "Renomear_PDVFDB"
	else 
		echo -e "\n${R1}Banco PDV.FDB nao encontrado em /home/$USER${End}\n"
	fi
}

disableEnergyScreensaver() {
	local OffScreenSaver="/pdv/util/.scripts/OffScreenSaver.sh"
    printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "$SHORTCUTPATH/DisableEnergySaver_ScreenSaver.desktop" >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/pdv/util/.scripts/OffScreenSaver.sh" >/dev/null 2>&1

    if [[ ${LINUX_VERSION} == "20.04" ]]; then
	filepermission_create "$OffScreenSaver"
		cat <<EOF > "$OffScreenSaver" 2>/dev/null
#!/bin/bash
PASSWD=$(</pdv/SENHA_SUDO.txt)

# Desativar xscreensaver
if [ -f "$HOME/.xscreensaver" ]; then
  printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i 's/^lock:.*/lock:           False/' "$HOME/.xscreensaver"
  printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i 's/^lockTimeout:.*/lockTimeout:    0:00:00/' "$HOME/.xscreensaver"
  printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i 's/^dpmsEnabled:.*/dpmsEnabled:    False/' "$HOME/.xscreensaver"
  printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i 's/^dpmsQuickOff:.*/dpmsQuickOff:   False/' "$HOME/.xscreensaver"
  printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i 's/^timeout:.*/timeout:        0:00:00/' "$HOME/.xscreensaver"
  printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i 's/^cycle:.*/cycle:          0:00:00/' "$HOME/.xscreensaver"
  printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i 's/^mode:.*/mode:           off/' "$HOME/.xscreensaver"
fi

# Reinicia o xscreensaver com config nova
pkill xscreensaver
sleep 2
nohup xscreensaver -no-splash >/dev/null 2>&1 &

# Desativa o modo de energia do X
export DISPLAY=:0.0
xset s off
xset -dpms
xset s noblank

# Remove autostart do xscreensaver
printf '%s\n' "$PASSWD" | sudo -S -p '' rm -f ~/.config/autostart/xscreensaver.desktop

# Ajustes do gerenciador de energia do XFCE
printf '%s\n' "$PASSWD" | sudo -S -p '' xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/inactivity-sleep-mode-on-ac -s 0
printf '%s\n' "$PASSWD" | sudo -S -p '' xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/inactivity-sleep-mode-on-battery -s 0
printf '%s\n' "$PASSWD" | sudo -S -p '' xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/brightness-on-ac -s 100
printf '%s\n' "$PASSWD" | sudo -S -p '' xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/brightness-on-battery -s 100

# Tenta parar xfce4-screensaver se estiver presente
printf '%s\n' "$PASSWD" | sudo -S -p '' systemctl stop xfce4-screensaver.service >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' systemctl disable xfce4-screensaver.service >/dev/null 2>&1

exit
EOF
        createRegisterLog "OffScreenSaver_20.04"
    fi

    if [[ ${LINUX_VERSION} == "18.04" || ${LINUX_VERSION} == "16.04" ]]; then
	filepermission_create "$OffScreenSaver"
		cat <<EOF > "$OffScreenSaver" 2>/dev/null
#!/bin/bash
PASSWD=$(</pdv/SENHA_SUDO.txt)

# Desativa o modo de energia do X
export DISPLAY=:0.0
xset s off
xset -dpms
xset s noblank

printf '%s\n' "$PASSWD" | sudo -S -p '' gsettings set org.gnome.desktop.session idle-delay 0
printf '%s\n' "$PASSWD" | sudo -S -p '' gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
printf '%s\n' "$PASSWD" | sudo -S -p '' gsettings set org.gnome.desktop.screensaver lock-enabled false

# Desabilita light-locker na inicialização
mkdir -p ~/.config/autostart
cp /etc/xdg/autostart/light-locker.desktop ~/.config/autostart/
echo "Hidden=true" >> ~/.config/autostart/light-locker.desktop

exit
EOF
        createRegisterLog "OffScreenSaver_18.04_16.04"
    fi

    if [ ! -e "$OffScreenSaver" ]; then
		filepermission_create "$OffScreenSaver"
        cat <<EOF > "$OffScreenSaver" 2>/dev/null
#!/bin/bash
sleep 3
export DISPLAY=:0.0
xset -dpms
xset s off
xset s noblank
exit
EOF
	fi

filepermission_create "$SHORTCUTPATH/DisableEnergySaver_ScreenSaver.desktop"
cat <<EOF > "$SHORTCUTPATH/DisableEnergySaver_ScreenSaver.desktop" 2>/dev/null
[Desktop Entry]
Encoding=UTF-8
Name=OffScreenSaver
Exec=$OffScreenSaver
Icon=$icon
Type=Application
Path=/pdv/util/.scripts/
EOF

    printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x "$OffScreenSaver" >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x "$SHORTCUTPATH/DisableEnergySaver_ScreenSaver.desktop" >/dev/null 2>&1

    # Recria regra do udev para manter USBs sempre ativas
    printf '%s\n' "$PASSWD" | sudo -S -p '' bash <<EOF
rm -f /etc/udev/rules.d/99-usb-autosuspend.rules
cat <<EOL > /etc/udev/rules.d/99-usb-autosuspend.rules
ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
EOL
chmod 644 /etc/udev/rules.d/99-usb-autosuspend.rules
chown root:root /etc/udev/rules.d/99-usb-autosuspend.rules
udevadm control --reload-rules
udevadm trigger
EOF
}


tancafile() {
	killApp java
	if [ ! -e "/var/tanca/sat.ini" ]; then
      printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 /var/tanca 2>/dev/null
	  printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "[DEFAULT]\nSERIAL= /dev/ttyS901" | sudo tee -a /var/tanca/sat.ini >/dev/null 2>&1
	  printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" -R /var/tanca/sat.ini >/dev/null 2>&1
	  printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /var/tanca/sat.ini >/dev/null 2>&1
		date=$(date '+%Y-%m-%d_%H:%M:%S')
		printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "Arquivo SAT.INI criado em $date" | sudo tee -a $logs_path/Tanca_SAT.INI-$date.txt >/dev/null 2>&1
	 else
	  printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /var/tanca/sat.ini >/dev/null 2>&1
	  printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "[DEFAULT]\nSERIAL= /dev/ttyS901" | sudo tee -a /var/tanca/sat.ini >/dev/null 2>&1
	  printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" -R /var/tanca/sat.ini >/dev/null 2>&1
	  printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /var/tanca/sat.ini >/dev/null 2>&1
			
			
		createRegisterLog "Tanca_SAT.INI"
		# printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "Arquivo SAT.INI criado em $date" | sudo tee -a $logs_path/Tanca_SAT.INI-$date.txt >/dev/null 2>&1
    fi
	if [ $setcheckvariable -ne 1 ]; then
	echo -e "\n${B1}Arquivo SAT.INI Tanca criado!!${End}"
	fi
}

installGunnebo() {
    clear
	echo -e "\n${G1}Instalacao Camera Gunnebo${End}\n"
	
	if [ ! -e $logs_path/CamGunnebo.txt ]; then
		
		printf '%s\n' "$PASSWD" | safe_apt -y update
		printf '%s\n' "$PASSWD" | safe_apt -y install cifs-utils
	fi
    clear
	
	#Realize download da lib libGCPlug.so caso nao exista
	if [ ! -e "/usr/lib/libGCPlug.so" ]; then
		echo -e "\nRealizando download da libGCPlug.so. . . Aguarde . . .\n"
		libslinux=libgunnebo
		setcheckvariable=1
		atualizarLibsPDV
	fi
	
	echo -e "\nAgora sera feito o processo para mapear a pasta compartilhada que foi configurada no PDV>>Parametros>>Perifericos>>Camera>>Gunnebo\nInforme o mesmo IP e em seguida pasta criada, onde essa pasta deve estar compartilhada via rede\n\n"
    read -p "Digite o IP do servidor onde a aplicacao gunnebo esta: " IPSERVERGUNNEBO
    echo -e "\nTestando conexao..."
    ping -c4 $IPSERVERGUNNEBO &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Nao houve conexao com o servidor, verifique o IP e nome da pasta informados."
        exit 0
    else
        read -p "O compartilhamento possui usuario e senha para acesso? [1] SIM [2] NAO: " SRVGUNNEBOSHAREDPASS
        if [ $SRVGUNNEBOSHAREDPASS -eq 1 ]; then
            printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 -m 777 $DIRGUNNEBO 2>/dev/null
            read -p "Digite o usuario: " SRVGUNNEBOSHAREDUSER
            read -p "Digite a senha: " SRVGUNNEBOSHAREDPASSWD
            read -p "Digite o nome do dominio, se houver (tecle apenas Enter se nao houver): " SRVGUNNEBOSHAREDDOMAIN
            read -p "Digite o nome da pasta Gunnebo / Gatecash compartilhada do servidor de cameras: " GUNNEBOFOLDER
            printf '%s\n' "$PASSWD" | sudo -S -p '' mount -t cifs //$IPSERVERGUNNEBO/$GUNNEBOFOLDER $DIRGUNNEBO -o username=$SRVGUNNEBOSHAREDUSER,password=$SRVGUNNEBOSHAREDPASSWD,domain=$SRVSHAREDDOMAIN,iocharset=utf8,noperm
            if [ $? -eq 0 ]; then
                printf '%s\n' "$PASSWD" | sudo -S -p '' umount $DIRGUNNEBO
                echo -e "user=$SRVSHAREDUSER\npassword=$SRVSHAREDPASSWD\ndomain=$SRVGUNNEBOSHAREDDOMAIN" > /home/$USER/.gunnebocredentials
                chmod 600 /home/$USER/.gunnebocredentials
				printf '%s\n' "$PASSWD" | sudo -S -p '' tee -a /etc/fstab > /dev/null << EOF
//$IPSERVERGUNNEBO/$GUNNEBOFOLDER\t$DIRGUNNEBO\tcifs\tcredentials=/home/$USER/.gunnebocredentials,iocharset=utf8,noperm\t0\t0
EOF
                printf '%s\n' "$PASSWD" | sudo -S -p '' mount -a
            else
                clear ; echo "Parametros invalidos, encerrando configuracao."
                sleep 4
                exit
            fi
        elif [ $SRVGUNNEBOSHAREDPASS -eq 2 ]; then
            printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 -m 777 $DIRGUNNEBO 2>/dev/null
            read -p "Digite o nome da pasta Gunnebo / Gatecash compartilhada do servidor de cameras: " GUNNEBOFOLDER
            printf '%s\n' "$PASSWD" | sudo -S -p '' mount -t cifs //$IPSERVERGUNNEBO/$GUNNEBOFOLDER $DIRGUNNEBO -o username=$USER,password=$PASSWD,iocharset=utf8,noperm
            if [ $? -eq 0 ]; then
                printf '%s\n' "$PASSWD" | sudo -S -p '' umount $DIRGUNNEBO
				printf '%s\n' "$PASSWD" | sudo -S -p '' tee -a /etc/fstab > /dev/null << EOF
//$IPSERVERGUNNEBO/$GUNNEBOFOLDER\t$DIRGUNNEBO\tcifs\tuid=0,username=$USER,password=$PASSWD,iocharset=utf8,noperm\t0\t0
EOF
                printf '%s\n' "$PASSWD" | sudo -S -p '' mount -a
            else
                clear ; echo "Parametros invalidos, encerrando configuracao."
                sleep 4
                exit
            fi
        else
            clear ; echo "Opcao invalida, encerrando configuracao."
            sleep 4
            exit
        fi
    fi

	createRegisterLog "CamGunnebo"
}

rootBanner() {
	if [[ ${LINUX_VERSION} == "18.04" ]]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' grep -i "#Banner /etc/issue" /etc/ssh/sshd_config 2>/dev/null
		if [ $? -ne 0 ]; then
			sudo sed -i 's/\bBanner \/etc\/issue\b/#Banner \/etc\/issue/g' /etc/ssh/sshd_config >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /etc/issue >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S -p '' echo "Ubuntu 18.04.4 LTS \n \l" | sudo tee -a /etc/issue >/dev/null 2>&1
			
			createRegisterLog "SpiderRootBanner"
			# printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "Arquivo SpiderRootBanner ajustado em $date" | sudo tee -a $logs_path/SpiderRootBanner.txt >/dev/null 2>&1
		fi
	fi
}

menuAtrasoPDV() {
	clear
	echo ""
	echo -e "${LNFP}=========================================${End}"
	echo -e "1. Ativar Abrir/Fechar devido falha de SAT"
	echo -e "2. Ativar apenas atraso de tempo para abrir PDV"
	echo -e "3. Alterar Tempo para abertura do PDV (ajusta independente da funcao acima)"
	echo -e "4. Desativar Atraso"
	echo -e "${LNFP}99. Retornar ao MENU.${End}"
    read -p "Escolha o tipo de ajuste: " ATRASOOPT
	
		if [ -z "$ATRASOOPT" ] || ! [[ "$ATRASOOPT" =~ ^[0-9]+$ ]]; then
			echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; menuAtrasoPDV
		fi
		if [ $ATRASOOPT -eq 1 ]; then	
			atrasoApenas=2
			setAtrasoPDV
		fi
		if [ $ATRASOOPT -eq 2 ]; then	
			atrasoApenas=1
			setAtrasoPDV
		fi
		if [ $ATRASOOPT -eq 3 ]; then
			ajusteTempoAtraso=1
			setAtrasoPDV
		fi
		if [ $ATRASOOPT -eq 4 ]; then	
			unsetAtrasoPDV
		fi
		if [ $ATRASOOPT -eq 99 ]; then	
			menuOptions
		fi
		if [ $ATRASOOPT -ge 5 ]; then
			if [ $ATRASOOPT -le 98 ]; then	
			echo -e "\n${R1}Opcao incorreta, retornando ao menu MenuAtrasoPDV${End}" ; pause ; menuAtrasoPDV
			fi
		fi

}

setAtrasoPDV() {

if [ ! -e "/pdv/util/.scripts/pdv.sh" ]; then
	echo -e "\nArquivo /pdv/util/.scripts/pdv.sh, nao existe\nPor favor crie um novo atalho utilizando o script e em seguida use a funcao de Configurar Atraso PDV novamente."
	pause ; menuOptions
fi

	arquivo_atraso="/pdv/util/.scripts/pdv_atraso.sh"
    startModeloPDV=""

	echo -e "\nPor favor insira o Tempo de Espera\nRecomendamos tempo minimo de 25 (seg), mas normalmente 45 ou 70 sao os mais usados."
	read -p "Digite o Tempo de Espera: " restarttime

	if [ ! -e "/pdv/util/.scripts/pdv_atraso.sh" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' cp -p $pathSH /pdv/util/.scripts/pdv_atraso.sh >/dev/null 2>&1
	fi

	# Validacao opcao 3
	if [ $ajusteTempoAtraso -eq 1 ]; then
		if grep -q "atrasoTime=" "$arquivo_atraso" >/dev/null 2>&1; then
			printf '%s\n' "$PASSWD" | sudo -S -p '' sed -i "s/atrasoTime=[0-9]*/atrasoTime=$restarttime/" $arquivo_atraso
			if grep -q "$startModeloPDV" "$arquivo_atraso"; then
				echo -e "Alteração de tempo realizada com sucesso."
				createRegisterLog "ConfiguraAtrasoPDV-$restarttime"
				pause ; menuOptions
			fi
		else
			echo -e "\nArquivo nao esta configurado com atraso previamente, escolha a opcao 1 ou 2 anteriores para configurar" ; pause ; echo "" ; menuAtrasoPDV
		fi
	fi

    if grep -q "java -jar /pdv/exec/VRPdv.jar" "$arquivo_atraso" >/dev/null 2>&1; then
        startModeloPDV="java -jar /pdv/exec/VRPdv.jar"
    elif grep -q "java -jar /pdv/exec/VRPdv.jar -selfcheckout" "$arquivo_atraso" >/dev/null 2>&1; then
        startModeloPDV="java -jar /pdv/exec/VRPdv.jar -selfcheckout"
    elif grep -q "java -jar /pdv/exec/VRPdv.jar -touchscreen" "$arquivo_atraso" >/dev/null 2>&1; then
        startModeloPDV="java -jar /pdv/exec/VRPdv.jar -touchscreen"
    else
        echo -e "Arquivo $arquivo_atraso fora do padrao.\nVerifique o arquivo pdv.sh para confirmar se esta devidamente configurado"
        pause ; menuOptions
    fi
	
	#Insere no arquivo pdv_atraso.sh os comandos
	if [ $atrasoApenas -eq 1 ]; then
		if [ -e "/pdv/util/.scripts/pdv_atraso.sh" ]; then
		 printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/pdv/util/.scripts/pdv_atraso.sh" >/dev/null 2>&1
		 printf '%s\n' "$PASSWD" | sudo -S -p '' cp -p $pathSH /pdv/util/.scripts/pdv_atraso.sh >/dev/null 2>&1
		fi
		startModeloPDV_escaped=$(printf '%s\n' "$startModeloPDV" | sed 's/[\/&]/\\&/g')
		sed -i "/$startModeloPDV_escaped/,\$d" "$arquivo_atraso" >/dev/null 2>&1
		echo "" >> $arquivo_atraso
		echo "pkill -9 java" >> $arquivo_atraso
		echo "atrasoTime=$restarttime" >> $arquivo_atraso
		echo "mensagem=\"PDV IRA INICIAR EM \${atrasoTime} segundos, AGUARDE\"" >> $arquivo_atraso
		echo "alertMsg=\$(notify-send 'AVISO !!!' \"\$mensagem\" --expire-time=\${atrasoTime}000)" >> $arquivo_atraso
		echo "" >> $arquivo_atraso
		echo 'sleep $atrasoTime' >> $arquivo_atraso
		echo "$startModeloPDV" >> $arquivo_atraso
		if grep -q "pkill -9 java" "$arquivo_atraso" && grep -q "mensagem=\"PDV IRA INICIAR EM" "$arquivo_atraso" && grep -q "atrasoTime=$restarttime" "$arquivo_atraso" && grep -q "$startModeloPDV" "$arquivo_atraso"; then
			echo -e "\n${C1}[Atraso configurado com sucesso]${End}"
		fi
	else
		if [ -e "/pdv/util/.scripts/pdv_atraso.sh" ]; then
		 printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/pdv/util/.scripts/pdv_atraso.sh" >/dev/null 2>&1
		 printf '%s\n' "$PASSWD" | sudo -S -p '' cp -p $pathSH /pdv/util/.scripts/pdv_atraso.sh >/dev/null 2>&1
		fi
		startModeloPDV_escaped=$(printf '%s\n' "$startModeloPDV" | sed 's/[\/&]/\\&/g')
		sed -i "/$startModeloPDV_escaped/,\$d" "$arquivo_atraso" >/dev/null 2>&1
		echo "" >> $arquivo_atraso
		echo "atrasoTime=$restarttime" >> $arquivo_atraso
		echo "mensagem=\"PDV IRA REINICIAR EM \${atrasoTime} segundos, AGUARDE\"" >> $arquivo_atraso
		echo "alertMsg=\$(notify-send 'AVISO !!!' \"\$mensagem\" --expire-time=\${atrasoTime}000)" >> $arquivo_atraso
		echo "" >> $arquivo_atraso
		echo "pkill -9 java" >> $arquivo_atraso
		echo "" >> $arquivo_atraso
		echo "$startModeloPDV & sleep 3 && \$alertMsg & sleep \${atrasoTime} && pkill -9 java && sleep 2 && $startModeloPDV" >> $arquivo_atraso

		echo -e "\n${C1}[Atraso configurado com sucesso]${End}"
	fi
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x $arquivo_atraso >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $arquivo_atraso >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" $arquivo_atraso >/dev/null 2>&1
	
	#Bkp do atalho original da pasta autostart
	printf '%s\n' "$PASSWD" | sudo -S -p '' mv /etc/xdg/autostart/VRPdv.desktop $bkp_pdvShortcut >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		if [ ! -e "$bkp_pdvShortcut/VRPdv.desktop" ]; then
			printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "[Desktop Entry]\n\nName=VRPdv\nExec=/pdv/util/.scripts/pdv.sh\nIcon=/pdv/exec/img/VRPdv.png\nType=Application\nPath=/pdv/util/.scripts/" | sudo tee -a $bkp_pdvShortcut/VRPdv.desktop >/dev/null 2>&1
		fi
	fi
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $pathAutostart >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $pathAutostart_1604 >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $pathAutostart_1804 >/dev/null 2>&1
	
	#Criando novo atalho na pasta autostart
	printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "[Desktop Entry]\n\nName=VRPdv\nExec=/pdv/util/.scripts/pdv_atraso.sh\nIcon=/pdv/exec/img/VRPdv.png\nType=Application\nPath=/pdv/util/.scripts/" | sudo tee -a /tmp/VRPdv.desktop >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' mv /tmp/VRPdv.desktop /etc/xdg/autostart/VRPdv.desktop >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x /etc/xdg/autostart/VRPdv.desktop >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /etc/xdg/autostart/VRPdv.desktop >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" /etc/xdg/autostart/VRPdv.desktop >/dev/null 2>&1
	
	createRegisterLog "ConfiguraAtrasoPDV-$restarttime"
}

unsetAtrasoPDV() {
	if [ -e "$bkp_pdvShortcut/VRPdv.desktop" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $pathAutostart >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p $bkp_pdvShortcut/VRPdv.desktop "/etc/xdg/autostart" >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x $pathAutostart >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $pathAutostart >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" $pathAutostart >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/pdv/util/.scripts/pdv_atraso.sh" >/dev/null 2>&1
	else
		echo -e "\nNao existe $bkp_pdvShortcut/VRPdv.desktop"
	fi
}

findfiles() {
	echo ""
	separador
    read -p "Digite o nome do arquivo que deseja procurar (pode ser maiusculo ou minusculo): " findvariable
	echo ""
	echo "Realizando busca. . .  Aguarde . . ."
	echo ""
	date=$(date '+%Y-%m-%d_%H:%M:%S')
	find / -iname "*$findvariable*" 2>/dev/null | tee -a /pdv/util/RetornoBusca-$findvariable-$date.txt
	echo ""
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
                    pids=$(sudo fuser "$lock" 2>/dev/null)
                    if [ -n "$pids" ]; then
                        echo "[INFO] - Matando processos que seguram $lock: $pids"
                        sudo kill -9 $pids 2>/dev/null
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

checklistPDV() {

clear
killApp java

echo -e "\nChecklist PDV, sera realizado os topicos abaixo, portanto aguarde sua finalizacao"
echo -e "\n- Atualizacao completa do Linux\n- Atualizacao/Reinstalacao Java\n- Reinstalacao Firebird\n- Correcao de Permissoes"

echo ""
read -n 1 -s -r -p "Tecle ENTER para continuar. . ."
echo ""

LOGFILE="$logs_path/ChecklistPDV.txt"
if [ ! -e "$LOGFILE" ]; then
	printf '%s\n' "$PASSWD" | sudo -S -p '' touch "$LOGFILE" >/dev/null 2>&1
fi
printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 "$LOGFILE" >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" "$LOGFILE" >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' touch "$LOGFILE" >/dev/null 2>&1

date=$(date '+%Y-%m-%d_%H:%M:%S')
{
echo "########################################################################################"
date=$(date '+%Y-%m-%d_%H:%M:%S')
echo "Processo iniciado $date"
echo "========================================================================================"
internetConnectionCheck
echo "========================================================================================"
echo "========================================================================================"
linuxUpdate
echo "========================================================================================"
echo "========================================================================================"
setcheckvariable=2
javaInstallReinstall
echo "========================================================================================"
echo "========================================================================================"
firebirdInstallReinstall
echo "========================================================================================"
echo "========================================================================================" 
setcheckvariable=1
libSitefVrs=LibSitef_Atual
atualizarClisitef
echo "========================================================================================"
echo "========================================================================================" 
corrigirPermissoes
echo "========================================================================================"
date=$(date '+%Y-%m-%d_%H:%M:%S')
echo "Processo encerrado $date"
echo "########################################################################################"
} | tee "$LOGFILE"

printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $LOGFILE 2>/dev/null
printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" $LOGFILE 2>/dev/null

echo -e "\n\n${BP1}Checklist PDV finalizado${End}\n"
}

checkVRProperties() {
	echo -e "\nVerificando vr.properties . . ."
	if [ -e "/vr/vr.properties" ]; then
		echo -e "Renomeando vr.properties . . ."
		date=$(date '+%Y-%m-%d_%H:%M:%S')
		printf '%s\n' "$PASSWD" | sudo -S -p '' mv /vr/vr.properties /vr/vr-$date.properties 2>/dev/null
	fi
	echo -e "Baixando vr.properties . . ."
	printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 /vr 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R /vr 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" -R /vr 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $propertieslinux -O /vr/vr.properties 2>/dev/null
		if [ $? -ne 0 ] || [ ! -s /vr/vr.properties ]; then
			clear ; echo "" ; echo -e "${R1}Erro Realizar Download /vr/vr.properties${End}" ; pause ; printf "\n\n" ; menuOptions
		fi
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /vr/vr.properties 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" -R /vr/vr.properties 2>/dev/null
	echo -e "Properties baixado com sucesso"
}

checkPDVInstalled() {
	date=$(date '+%Y-%m-%d_%H:%M:%S') # >> $logs_path/CheckPDV_Install.txt >/dev/null
	echo -e "\n"
{
echo -e "================================================"
	echo "$date"
	echo ""
	valida_PDVpaths=("/pdv" "/vr")
for valida_PDVpaths in "${valida_PDVpaths[@]}"; do
    if [ ! -d "$valida_PDVpaths" ]; then
		status="** Nao Existe **"
		echo "($status) - $valida_PDVpaths"
	else
		status="Existe"
		echo "($status) - $valida_PDVpaths"
    fi
done

	valida_PDVfiles=("/pdv/exec/VRPdv.jar" "/vr/vr.properties" "/pdv/database/VR.FDB" "/home/$USER/PDV.FDB")
for valida_PDVfiles in "${valida_PDVfiles[@]}"; do
    if [ ! -e "$valida_PDVfiles" ]; then
		status="** Nao Existe **"
		echo "($status) - $valida_PDVfiles"
	else
		status="Existe"
		echo "($status) - $valida_PDVfiles"
    fi
done

	echo ""
	echo -e "VPN SitefExpress (TLS): $VPNSTATUS"
	echo "Data Dll Sitef: $data_line"
	echo "Tamanho Dll Sitef: $size_in_megabytes Mb"
	echo "Versao Dll Sitef: $libSitefversion"
echo -e "================================================"
} | tee -a "$logs_path/CheckPDV_Install.txt"

pause
}

rustdeskInstallReinstall() {
echo -e "\n${LNFP}Install/Reinstall RustDesk . . .${End}"

if command -v rustdesk &> /dev/null; then
	echo -e "\n${R1}Removendo RustDesk . . .${End}"
	printf '%s\n' "$PASSWD" | safe_apt remove -y rustdesk
	printf '%s\n' "$PASSWD" | safe_apt purge -y rustdesk
	printf '%s\n' "$PASSWD" | safe_apt_get -y autoclean
	printf '%s\n' "$PASSWD" | sudo -S -p '' umount cliprdr-server 2>/dev/null
fi

echo -e "\n${G1}Instalando dependencias RustDesk . . .${End}"
local commandsList=("sudo apt update" 
		"sudo dpkg --configure -a" 
		"sudo apt-get -y --fix-broken install" 
		"sudo apt-get -f -y install"
        "sudo ldconfig"
		"sudo apt-get -y install wget gdebi-core")
executeCommands "${commandsList[@]}"

echo -e "\n[INFO] Realizando Download RustDesk $rustDeskvrs . . ."
printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/tmp/RustDesk" >/dev/null 2>&1
folder_create "/tmp/RustDesk"
if [ -d "/tmp/RustDesk" ]; then
	printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate  $URLRUSTDESK -O /tmp/RustDesk/rustdesk-1.4.2-x86_64.deb >/dev/null 2>&1
	if ! is_valid_file "/tmp/RustDesk/rustdesk-1.4.2-x86_64.deb"; then
		echo -e "\n${R1}[FALHA] Erro Realizar Download RustDesk${End}" ; pause ; menuOptions
	fi
else
	echo -e "\n${R1}[FALHA] Erro ao criar pasta RustDesk${End}" ; pause ; menuOptions
fi

echo -e "\n[INFO] Instalando RustDesk $rustDeskvrs . . ."
if ! echo "$PASSWD" | sudo -S -p '' gdebi -n /tmp/RustDesk/rustdesk-1.4.2-x86_64.deb 2>/dev/null; then
    echo -e "\n${R1}[FALHA] Erro na instalação do RustDesk${End}"
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
	createRegisterLog "RustDesk"

echo -e "\n${BP1}RustDesk $rustDeskvrs instalado com sucesso${End}"
fi
}

javaWrapperError() {
	internetConnectionCheck

	clear
	echo -e "\nAjuste do erro "openjdk-8-jre:i386 : Depende: libatk-wrapper-java-jni:i386"\nE "libatk-wrapper-java-jni:i386 : Depende: libatk-bridge2.0-0:i386""
	check_repos
	local commandsList=("sudo apt -y clean" 
	"sudo apt update" 
	"sudo dpkg --configure -a" 
	"sudo apt-get -y --fix-broken install" 
	"sudo apt-get -f -y install"
	"sudo apt -y install libatk-bridge2.0-0:i386" 
	"sudo apt -y install libatk-wrapper-java-jni:i386" 
	"sudo apt -y clean"
	)
	executeCommands "${commandsList[@]}"
	finished
}

javaInstallReinstall() {
		
echo -e "\n==============================="
echo -e "${G1}InstallReinstall Java . . .${End}\n"
	
	echo -e "${C1}[Ajustando links de SourcesList]${End}"
	sourcelist

		echo -e "\n${C1}[Instalando dependencias Java e Linux . . .Aguarde . . .]${End}"
		check_repos
		local commandsList=("sudo apt -y clean" 
		"sudo apt update" 
		"sudo dpkg --configure -a" 
		"sudo apt-get -y --fix-broken install" 
		"sudo apt-get -f -y install"
		"sudo ldconfig" 
		"sudo apt -y clean"
		)
		executeCommands "${commandsList[@]}"
		
		echo -e "\n${G1}[Aguarde enquanto removemos a antiga versao instalada...]${End}"
		printf '%s\n' "$PASSWD" | safe_apt -y remove 'openjdk-*'
		printf '%s\n' "$PASSWD" | safe_apt_get remove -y --purge openjdk-8-jre:i386
		printf '%s\n' "$PASSWD" | safe_apt -y remove 'openjdk-8-*'
		printf '%s\n' "$PASSWD" | safe_apt -y remove 'openjdk-11-*'
		printf '%s\n' "$PASSWD" | sudo -S -p '' update-alternatives --remove-all java
		printf '%s\n' "$PASSWD" | sudo -S -p '' update-alternatives --remove-all javac

		echo -e "\n${G1}Instalando java. . .Aguarde . . .${End}"
		updateSystem_FixCommand		
		printf '%s\n' "$PASSWD" | safe_apt -yq install openjdk-8-jre:i386
		if [ $? -eq 0 ]; then
			if ! dpkg-query -l openjdk-8-jre:i386 >/dev/null 2>&1; then
				echo -e "${R1}FALHA na instalacao: Java openjdk-8-jre:i386 (x86).${End}"
				createRegisterLog "FALHA_JavaUpdateReinstall"
				pause
				menuOptions
			fi
		else
			echo -e "${R1}FALHA na instalacao: Java openjdk-8-jre:i386 (x86).${End}"
			createRegisterLog "FALHA_JavaUpdateReinstall"
			pause
			menuOptions
		fi

		echo -e "\nReaplicando permissoes"
		permissoesJava
		
		echo -e "\n${B1}Java openjdk-8-jre:i386 (x86) instalado com sucesso.${End}\n"
		
		createRegisterLog "JavaUpdateReinstall"
	
	date=$(date '+%Y-%m-%d_%H:%M:%S')
	echo "=============================" >> /pdv/util/logsScript/JAVA_Version.txt >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' java -version >> /pdv/util/logsScript/JAVA_Version.txt >/dev/null 2>&1
	echo "$date" >> /pdv/util/logsScript/JAVA_Version.txt 2>&1
	
	echo "=============================" >> /pdv/util/logsScript/JAVA_update-alternatives.txt >/dev/null 2>&1
	date=$(date '+%Y-%m-%d_%H:%M:%S')
	echo "$date" >> /pdv/util/logsScript/JAVA_update-alternatives.txt >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' update-alternatives --config java >> /pdv/util/logsScript/JAVA_update-alternatives.txt >/dev/null 2>&1
	
	if [[ ${LINUX_VERSION} == "20.04" ]]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' update-alternatives --set java /usr/lib/jvm/java-8-openjdk-i386/jre/bin/java >/dev/null 2>&1
		echo "=============================" >> /pdv/util/logsScript/JAVA_update-alternatives.txt >/dev/null 2>&1
		
		date=$(date '+%Y-%m-%d_%H:%M:%S')
		echo "$date" >> /pdv/util/logsScript/JAVA_update-alternatives.txt >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' update-alternatives --config java >> /pdv/util/logsScript/JAVA_update-alternatives.txt >/dev/null 2>&1
	elif [[ ${LINUX_VERSION} == "22.04" ]]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' update-alternatives --set java /usr/lib/jvm/java-8-openjdk-i386/jre/bin/java >/dev/null 2>&1
		echo "=============================" >> /pdv/util/logsScript/JAVA_update-alternatives.txt >/dev/null 2>&1
		
		date=$(date '+%Y-%m-%d_%H:%M:%S')
		echo "$date" >> /pdv/util/logsScript/JAVA_update-alternatives.txt >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' update-alternatives --config java >> /pdv/util/logsScript/JAVA_update-alternatives.txt >/dev/null 2>&1
	fi
}

javaCheckFile() {
	local javaFile="/usr/lib/jvm/java-8-openjdk-i386/jre/bin/java"
	if [ ! -e "$javaFile" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $path 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R $path 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" -R $path 2>/dev/null
	fi
}

firebirdInstallReinstall() {
LOGFILE_FirebirdReinstallLog="$logs_path/FirebirdReinstallLog.txt"

if [ -e "$LOGFILE_FirebirdReinstallLog" ]; then
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $LOGFILE_FirebirdReinstallLog >/dev/null 2>&1
fi

{
		echo -e "\n==============================+"
		echo -e "${G1}InstallReinstall Firebird . . .${End}\n"

		#Valida /pdv/util/.scripts
		if [ ! -d "$path" ]; then
			printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $path 2>/dev/null
			printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R $path 2>/dev/null
			printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" -R $path 2>/dev/null
		fi

			echo -e "\n${G1}Download Firebird${End}"
			printf '%s\n' "$PASSWD" | sudo -S -p '' wget --no-check-certificate $URLFIREBIRD -O /pdv/util/firebird-2.5.zip >/dev/null 2>&1
				if [ $? -ne 0 ] || [ ! -s /pdv/util/firebird-2.5.zip ]; then
					clear ; echo "" ; echo -e "${R1}Erro Realizar Download Firebird${End}" ; pause ; printf "\n\n" ; menuOptions
				fi
			echo -e "\n${G1}Extraindo Firebird${End}"
			printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o /pdv/util/firebird-2.5.zip -d /pdv/util
				if [ $? -ne 0 ]; then
					clear ; echo "" ; echo -e "${R1}Erro Extrair Firebird${End}" ; pause ; printf "\n\n" ; menuOptions
				fi
			printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x /pdv/util/firebird-2.5/FirebirdSS-2.5.9.27139-0.i686/install.sh >/dev/null 2>&1
			printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x -R /pdv/util/firebird-2.5/FirebirdSS-2.5.9.27139-0.i686/* >/dev/null 2>&1
			
			echo -e "\n${G1}Instalando pacotes e dependencias . . .${End}"
			check_repos
			local commandsList=(
			"sudo apt update"
			"sudo dpkg --configure -a"
			"sudo apt-get -y --fix-broken install"
			"sudo apt-get -f -y install"
			"sudo apt-get -y install libncurses5:i386"
			"sudo apt-get -y install libtommath1"
			"sudo apt-get -y install libstdc++5"
			"sudo apt-get -y install lib32stdc++6"
			"sudo apt-get -y install libncurses5"
			)
			executeCommands "${commandsList[@]}"

			firebirdRemover

			echo -e "\n${G1}Instalando Firebird . . .Aguarde . . .${End}"

			cd "/pdv/util/firebird-2.5/FirebirdSS-2.5.9.27139-0.i686/"
			warnningInteraction
			sudo ./install.sh

			current_date=$(date +%Y-%m-%d)
			if [ -d "/opt/firebird" ]; then
				# Obter a data de modificação do diretório /opt/firebird no formato YYYY-MM-DD
				firebird_date=$(stat -c %y /opt/firebird 2>/dev/null | cut -d ' ' -f 1)
				# Comparar a data do diretório com a data atual
				if [ "$firebird_date" == "$current_date" ]; then
					echo -e "\n${G1}Aplicando permissoes Firebird . . .Aguarde . . .${End}"
					permissioesFirebird
					echo -e "\n${B1}Install/Reinstall Firebird Finalizado${End}"
				else
					echo -e "\n${B1}Install/Reinstall Firebird Finalizado porem a pasta /otp/firebird seria de uma data diferente da Install/Reinstall${End}\n" | tee "$logs_path/InstallReinstall_Firebird.txt"
				fi
			else
				echo -e "\n${R1}FALHA NA INSTALL/REINSTALL DO FIREBIRD${End}\n"
				pause ; menuOptions
			fi
} | tee "$LOGFILE_FirebirdReinstallLog"

}

firebirdRemover() {
echo ""
	echo -e "\n${R1}Removendo Firebird...Aguarde...${End}"
		echo -e "\n${R1}Parando servicos${End}\n"
	checkdpkgExpect
	
	variable_firebirdservices=("firebird" "firebird-superserver" "firebird-classic" "firebird-guardian")
	for variable_firebirdservice in "${variable_firebirdservices[@]}"; do
		printf '%s\n' "$PASSWD" | sudo -S -p '' systemctl stop $variable_firebirdservice >/dev/null 2>&1
	done
	
	echo -e "\n${R1}Parando processos${End}"
	variable_firebirdprocesses=("firebird" "fbserver" "fbguard")
	for variable_firebirdprocess in "${variable_firebirdprocesses[@]}"; do
		printf '%s\n' "$PASSWD" | sudo -S -p '' pkill -9 $variable_firebirdprocess >/dev/null 2>&1
	done
	
	echo -e "\n${R1}Removendo pacotes${End}"
	variable_firebirdpackages=("firebird*" "firebi*")
	for variable_firebirdpackage in "${variable_firebirdpackages[@]}"; do
		printf '%s\n' "$PASSWD" | safe_apt -y purge $variable_firebirdpackage >/dev/null 2>&1
	done
	
	echo -e "\n${R1}Removendo arquivos residuais${End}"
	variable_firebirdpaths=("/etc/firebird*" "/var/lib/firebird*" "/var/log/firebird*" "/usr/lib/firebird*" "/opt/firebird*")
	for variable_firebirdpath in "${variable_firebirdpaths[@]}"; do
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $variable_firebirdpath >/dev/null 2>&1
	done
}

updateThemePDVManualScript() {
# Valida pasta img mapeada no servidor
if [ ! -d "/pdv_vr/pdv/img" ]; then
	setcheckvariable=1
	mountServerShared
fi

# Valida atalho em /usr/share/applications
if [ -e "$SHORTCUTPATH/VRAtualizarImagensPDV.desktop" ]; then
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "$SHORTCUTPATH/VRAtualizarImagensPDV.desktop" 2>/dev/null
fi

# Valida se o script de start existe ou nao
if [ -e "/pdv/util/.scripts/VRAtualizarImagensPDV.sh" ]; then
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/pdv/util/.scripts/VRAtualizarImagensPDV.sh" 2>/dev/null
fi

# Valida se o icone nao existe
if [ ! -e "/pdv/exec/img/VRAtualizador.png" ]; then
	printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $appsIco -O $iconPath/img.zip 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o $iconPath/img.zip -d $iconPath 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $iconPath/img.zip 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R $iconPath/* 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R $iconPath/* 2>/dev/null
fi

# Cria o script de Copiar Imagem
	printf '%s\n' "$PASSWD" | sudo -S -p '' touch /pdv/util/.scripts/VRAtualizarImagensPDV.sh >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /pdv/util/.scripts/VRAtualizarImagensPDV.sh >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" /pdv/util/.scripts/VRAtualizarImagensPDV.sh >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x /pdv/util/.scripts/VRAtualizarImagensPDV.sh >/dev/null 2>&1

printf '%s\n' "$PASSWD" | sudo -S -p '' tee /pdv/util/.scripts/VRAtualizarImagensPDV.sh > /dev/null <<EOF
#!/bin/bash

printf "%s\n" "$PASSWD" | sudo -S -p "" rm -rf /pdv/img/* >/dev/null 2>&1
printf "%s\n" "$PASSWD" | sudo -S -p "" cp --remove-destination -p /pdv_vr/pdv/img/* /pdv/img 2>/dev/null
printf "%s\n" "$PASSWD" | sudo -S -p "" chmod 777 /pdv/img/* 2>/dev/null
printf "%s\n" "$PASSWD" | sudo -S -p "" chown "$USER:firebird" /pdv/img/* 2>/dev/null
EOF

# Aplica permissao no script de Copiar Imagem
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /pdv/util/.scripts/VRAtualizarImagensPDV.sh >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" /pdv/util/.scripts/VRAtualizarImagensPDV.sh >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x /pdv/util/.scripts/VRAtualizarImagensPDV.sh >/dev/null 2>&1

# Cria atalho na pasta Desktop
	printf '%s\n' "$PASSWD" | sudo -S -p '' touch $SHORTCUTPATH/VRAtualizarImagensPDV.desktop >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 $SHORTCUTPATH/VRAtualizarImagensPDV.desktop >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" $SHORTCUTPATH/VRAtualizarImagensPDV.desktop >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' echo -e "[Desktop Entry]\n\nName=VRAtualizarImagensPDV\nExec=/pdv/util/.scripts/VRAtualizarImagensPDV.sh\nIcon=/pdv/exec/img/VRAtualizador.png\nType=Application\nPath=/pdv/util/.scripts" | sudo tee -a $SHORTCUTPATH/VRAtualizarImagensPDV.desktop >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x $SHORTCUTPATH/VRAtualizarImagensPDV.desktop >/dev/null 2>&1
	# printf '%s\n' "$PASSWD" | sudo -S -p '' ln -s $SHORTCUTPATH/VRAtualizarImagensPDV.desktop $desktopFolder >/dev/null 2>&1
	while IFS= read -r desktopFolder; do
		printf '%s\n' "$PASSWD" | sudo -S cp --remove-destination -p \
			"$SHORTCUTPATH/VRAtualizarImagensPDV.desktop" "$desktopFolder/" >/dev/null 2>&1
	done < <(setshortcutfiles)
}

updateThemePDVManual() {
# Valida pasta img mapeada no servidor
echo ""
echo -e "[Atualizando Imagens/Tema PDV]"

echo -e "\n-- Validando mapeamento /pdv_vr/pdv/img/"
if [ ! -d "/pdv_vr/pdv/img" ]; then
	setcheckvariable=1
	mountServerShared
fi

echo -e "\n-- Copiando imagens de /pdv_vr/pdv/img/"
printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/img/* >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p /pdv_vr/pdv/img/* /pdv/img/ 2>/dev/null
if [ $? -eq 0 ]; then
	echo -e "\n${B1}Imagens/Tema copiadas com sucesso${End}"
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /pdv/img/* 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" /pdv/img/* 2>/dev/null
	createRegisterLog "updateThemePDVManual"
else
	echo -e "\n${R1}FALHA copiar Imagens de /pdv_vr/pdv/img/${End}"
	createRegisterLog "updateThemePDVManual_Falha"
fi
}

menuOpenPDV() {
openpdv=true
	echo ""
	separador
	echo -e "1. java -jar /pdv/exec/VRPdv.jar -mouse ${WB1}(PDV Comum com seta mouse)${End}"
	echo -e "2. java -jar /pdv/exec/VRPdv.jar -config -mouse ${WB1}(PDV Comum Tela Config com seta mouse)${End}"
	echo -e "3. java -jar /pdv/exec/VRPdv.jar -touchscreen -mouse ${WB1}(PDV Touch com seta mouse)${End}"
	echo -e "4. java -jar /pdv/exec/VRPdv.jar -touchscreen -config -mouse ${WB1}(PDV Touch Tela Config com seta mouse)${End}"
	echo -e "5. java -jar /pdv/exec/VRPdv.jar -selfcheckout -mouse ${WB1}(PDV Self com seta mouse)${End}"
	echo -e "6. java -jar /pdv/exec/VRPdv.jar -selfcheckout -config -mouse ${WB1}(PDV Self Tela Config com seta mouse)${End}"
	echo -e "7. /pdv/util/.scripts/pdv.sh ${WB1}(Script de Start, inicia como se fosse o atalho)${End}"
	echo -e "${R1}8. EXIT${End}"
	echo -e "${LNFP}99. Retornar ao MENU${End}"
    read -p "Escolha uma opcao: " OPENPDVOPT
	
		if [ -z "$OPENPDVOPT" ] || ! [[ "$OPENPDVOPT" =~ ^[0-9]+$ ]]; then
			echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; menuOpenPDV
		fi
		if [ $OPENPDVOPT -eq 1 ]; then
			openpdv "VRPdv.jar -mouse" && nohup /vr/exec/pdv.sh > /dev/null 2>&1 & sleep 5 && menuOptions
		fi
		if [ $OPENPDVOPT -eq 2 ]; then
			openpdv "VRPdv.jar -config -mouse" && nohup /vr/exec/pdv.sh > /dev/null 2>&1 & sleep 5 && menuOptions
		fi
		if [ $OPENPDVOPT -eq 3 ]; then
			openpdv "VRPdv.jar -touchscreen -mouse" && nohup /vr/exec/pdv.sh > /dev/null 2>&1 & sleep 5 && menuOptions
		fi
		if [ $OPENPDVOPT -eq 4 ]; then
			openpdv "VRPdv.jar -touchscreen -config -mouse" && nohup /vr/exec/pdv.sh > /dev/null 2>&1 & sleep 5 && menuOptions
		fi
		if [ $OPENPDVOPT -eq 5 ]; then
			openpdv "VRPdv.jar -selfcheckout -mouse" && nohup /vr/exec/pdv.sh > /dev/null 2>&1 & sleep 5 && menuOptions
		fi
		if [ $OPENPDVOPT -eq 6 ]; then
			openpdv "VRPdv.jar -selfcheckout -config -mouse" && nohup /vr/exec/pdv.sh > /dev/null 2>&1 & sleep 5 && menuOptions
		fi
		if [ $OPENPDVOPT -eq 7 ]; then
			clear ; /pdv/util/.scripts/pdv.sh ; exit
		fi
		if [ $OPENPDVOPT -eq 8 ]; then
			exit
		fi
		if [ $OPENPDVOPT -eq 99 ]; then
			menuOptions
		fi
		if [ $OPENPDVOPT -ge 9 ]; then
			if [ $OPENPDVOPT -le 98 ]; then	
			echo -e "\n${R1}Opcao incorreta, retornando ao menu OpenPDV${End}" ; pause ; menuOpenPDV
			fi
		fi
}

openpdv() {
	local comando="$1"
	printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 /vr/exec >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /vr/exec/pdv.sh >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' touch /vr/exec/pdv.sh >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /vr/exec/pdv.sh >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" /vr/exec/pdv.sh >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x /vr/exec/pdv.sh >/dev/null 2>&1

	echo -e "$SHEBANG\n\njava -jar /pdv/exec/$comando" | sudo tee -a /vr/exec/pdv.sh >/dev/null 2>&1
}

update_datahora() {
if [ -e "/pdv/util/.scripts/update_datahora_shell.sh" ]; then
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/util/.scripts/update_datahora_shell.sh >/dev/null 2>&1
fi

echo -e "\n${C2}[Alteracao Data/Hora Linux]${End}"
echo ""

while true; do
    read -p "Informe o ANO [ YYYY ]: " ano
    if [[ "$ano" =~ ^[0-9]{4}$ && "$ano" -ge 1 ]]; then
        break
    else
        echo "Entrada inválida. Digite um ano com 4 dígitos."
    fi
done

# MES
while true; do
    read -p "Informe o MES [ mm ]: " mes
    mes=$((10#$mes))                          # força decimal
    mes=$(printf "%02d" "$mes")               # zero à esquerda
    if [[ "$mes" =~ ^[0-9]{2}$ && "$mes" -ge 1 && "$mes" -le 12 ]]; then
        break
    else
        echo "Entrada inválida. Digite um número de 01 a 12."
    fi
done

# DIA
while true; do
    read -p "Informe o DIA [ dd ]: " dia
    dia=$((10#$dia))                          # força decimal
    dia=$(printf "%02d" "$dia")               # zero à esquerda
    if [[ "$dia" =~ ^[0-9]{2}$ && "$dia" -ge 1 && "$dia" -le 31 ]]; then
        break
    else
        echo "Entrada inválida. Digite um dia de 01 a 31."
    fi
done

# HORA
while true; do
    read -p "Informe a HORA [HH]: " hora
    hora=$((10#$hora))                        # força decimal
    hora=$(printf "%02d" "$hora")
    if [[ "$hora" =~ ^[0-9]{2}$ && "$hora" -ge 0 && "$hora" -le 23 ]]; then
        break
    else
        echo "Entrada inválida. Digite uma hora de 00 a 23."
    fi
done

# MINUTO
while true; do
    read -p "Informe o MINUTO [MM]: " minuto
    minuto=$((10#$minuto))                    # força decimal
    minuto=$(printf "%02d" "$minuto")
    if [[ "$minuto" =~ ^[0-9]{2}$ && "$minuto" -ge 0 && "$minuto" -le 59 ]]; then
        break
    else
        echo "Entrada inválida. Digite um minuto de 00 a 59."
    fi
done

echo ""
echo -e "Valores informados:\n${C2}Dia/Mes/Ano:${End} ${dia}/${mes}/${ano}\n${C2}HORARIO:${End} ${hora}hr ${minuto}min\n"
echo "1. Corrigir valores informados"
echo "2. Valores estao corretos, seguir com a configuracao"
echo -e "${LNFP}3. Retornar Menu Central${End}"
read -p "Opcao: " OPTDATETIMECONFIG
				
if [ -z "$OPTDATETIMECONFIG" ] || ! [[ "$OPTDATETIMECONFIG" =~ ^[0-9]+$ ]]; then
 echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; update_datahora
fi
if [ $OPTDATETIMECONFIG -eq 1 ]; then
 update_datahora
fi
if [ $OPTDATETIMECONFIG -eq 2 ]; then
 :
fi
if [ $OPTDATETIMECONFIG -eq 3 ]; then
 exit
fi
if [ $OPTDATETIMECONFIG -ge 4 ]; then
 echo -e "\n${R1}Opcao incorreta, retornando ao menu principal${End}" ; pause ; update_datahora
fi

if [ -e "/pdv/util/.scripts/update_datahora_shell.sh" ]; then
 	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/util/.scripts/update_datahora_shell.sh >/dev/null 2>&1
fi

printf '%s\n' "$PASSWD" | sudo -S -p '' touch /pdv/util/.scripts/update_datahora_shell.sh >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /pdv/util/.scripts/update_datahora_shell.sh >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x /pdv/util/.scripts/update_datahora_shell.sh >/dev/null 2>&1

echo '#!/bin/bash' >> /pdv/util/.scripts/update_datahora_shell.sh
echo "" >> /pdv/util/.scripts/update_datahora_shell.sh

if [[ "$(readlink /etc/localtime)" != "/usr/share/zoneinfo/America/Fortaleza" ]]; then
	echo "sudo mv /etc/localtime /etc/localtime.bak" >> /pdv/util/.scripts/update_datahora_shell.sh
	echo "sudo --remove-destination -p /usr/share/zoneinfo/America/Fortaleza /etc/localtime" >> /pdv/util/.scripts/update_datahora_shell.sh
fi

if [[ $(cat /etc/timezone) != "America/Fortaleza" ]]; then
echo "sudo mv /etc/timezone /etc/timezone.bak" >> /pdv/util/.scripts/update_datahora_shell.sh
echo "sudo touch /etc/timezone >/dev/null 2>&1" >> /pdv/util/.scripts/update_datahora_shell.sh
echo "echo America/Fortaleza | sudo tee /etc/timezone" >> /pdv/util/.scripts/update_datahora_shell.sh
echo "sudo chmod --reference=/etc/timezone.bak /etc/timezone" >> /pdv/util/.scripts/update_datahora_shell.sh
echo "sudo chown --reference=/etc/timezone.bak /etc/timezone" >> /pdv/util/.scripts/update_datahora_shell.sh
fi

echo "sudo dpkg-reconfigure -f noninteractive tzdata" >> /pdv/util/.scripts/update_datahora_shell.sh
echo "sudo timedatectl set-ntp false" >> /pdv/util/.scripts/update_datahora_shell.sh
echo "date ${mes}${dia}${hora}${minuto}${ano}" >> /pdv/util/.scripts/update_datahora_shell.sh
echo "sudo hwclock -w" >> /pdv/util/.scripts/update_datahora_shell.sh

cd /pdv/util/.scripts/
warnningInteraction
sudo ./update_datahora_shell.sh
}

islOnline_menu() {
printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/tmp/isl-download" >/dev/null 2>&1
folder_create "/tmp/isl-download"

    # internetConnectionCheck
    clear
	echo -e "\n==============================="
	echo "1. Unidades Parceiras - AlwaysOn"
	echo "2. Software House - AlwaysOn"
	echo "3. Install/Reinstall ISL_Light_Client - Acesso monitorado e unico"
	echo "4. Desinstalar ISL_Light_Client - Acesso monitorado e unico"
	echo -e "${LNFP}5. Retornar Menu Central${End}"
	read -p "Opcao: " OPTISLMENU
					
	if [ -z "$OPTISLMENU" ] || ! [[ "$OPTISLMENU" =~ ^[0-9]+$ ]]; then
	echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; sleep 2 ; islOnline_menu
	fi
	if [ $OPTISLMENU -eq 1 ]; then
	islOnline_CheckLinuxVersion
	islOnlineType=AlwaysOn
	read -r -p $'\nInforme o link ISL Online de download: ' URL
	islOnline_Dependencias
	islOnline_download "$URL" "ISL_AlwaysOn"
	fi
	if [ $OPTISLMENU -eq 2 ]; then
	islOnline_CheckLinuxVersion
	islOnlineType=AlwaysOn
	islOnline_Dependencias
	islOnline_SoftwareHouse
	fi
	if [ $OPTISLMENU -eq 3 ]; then
	islOnlineType=LightClient
	islOnline_Dependencias
	islOnline_LightClient
	islOnline_Atalho
	# VR Software - Suporte Remoto
	fi
	if [ $OPTISLMENU -eq 4 ]; then
	islOnlineType=LightClient
	islOnline_Unninstal_LightClient
	fi
	if [ $OPTISLMENU -eq 5 ]; then
	menuOptions
	fi
	if [ $OPTISLMENU -ge 6 ]; then
	echo -e "\n${R1}Opcao incorreta, retornando ao menu principal${End}" ; pause ; islOnline_menu
	fi
}

islOnline_Dependencias(){
echo -e "\n${G1}[Instalando Dependencias ISL Online. . .]${End}\n"
check_repos
sudo apt update
comandosPreparacao
sudo apt-get -y install libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-xkb1 libxkbcommon-x11-0
sudo apt-get -yq clean
}

islOnline_LightClient() {
local DESTINO=/pdv/util/isl_LightClient
local FILE=$DESTINO/ISL_Light_Client

echo -e "\Instalacao LightClient VR"

    printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $DESTINO 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $FILE 2>/dev/null
    folder_create "$DESTINO"

    printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $URLISLONELIN_LIGHTCLIENT -O $DESTINO/ISL_Light_Client.zip 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o $DESTINO/ISL_Light_Client.zip -d $DESTINO 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $DESTINO/ISL_Light_Client.zip 2>/dev/null
    # printf '%s\n' "$PASSWD" | sudo -S -p '' mv $DESTINO/* $DESTINO/ISL_Light_Client >/dev/null 2>&1
	shopt -s nullglob
    local checkFile=("$DESTINO"/*)
	if [ ${#checkFile[@]} -eq 0 ]; then
        echo -e "\n${R1}❌${End} Falha na extração ou arquivo estava vazio, arquivo em $DESTINO/ISL_Light_Client.zip estava vazio."
        pause
        exit
    fi
	shopt -u nullglob
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R $DESTINO 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R $DESTINO 2>/dev/null
}

islOnline_download() {
	local URL="$1"
	local FILENAME="$2"

	echo -e "\n${Y1}⏳${End} - ${B1}Abrindo Firefox para realizar o download. . .Aguarde . . .${End} - ${Y1}⏳${End}"
	killApp firefox

	check_and_install_firefox

	if [ -z "$URL" ]; then
		echo -e "${R1}❌${End} Link não informado. Cancelando..."
		pause
		menuOptions
	fi

	# remove em Downloads (se houver)
	check_and_handle_files "$HOME/Downloads" "$FILENAME" \
	"printf '%s\n' \"\$PASSWD\" | sudo -S -p '' rm -rf \"\${arquivos[@]}\" >/dev/null 2>&1"

	# remove em $HOME (se houver)
	check_and_handle_files "$HOME" "$FILENAME" \
	"printf '%s\n' \"\$PASSWD\" | sudo -S -p '' rm -rf \"\${arquivos[@]}\" >/dev/null 2>&1"

	echo -e "\n${R1}NAO feche o FIREFOX, aguarde o termino do Download${End}"
	echo -e "\n${Y1}⚠️${End} - Ao terminar o download, pode fecha-lo e apertar enter no terminal para seguir com a instalacao - ${Y1}⚠️${End}"
	firefox "$URL" &

	pause

# Primeira tentativa: verifica em $HOME/Downloads
if [[ "$FILENAME" == "ISL_Light_Client" ]]; then
	FILENAME2="VR Software - Suporte Remoto Client"
elif [[ "$FILENAME" == "ISL_AlwaysOn" ]]; then
	FILENAME2="ISL_AlwaysOn"
fi

# tenta em $HOME/Downloads
check_and_handle_files "$HOME/Downloads" "$FILENAME2" \
"printf '%s\n' \"\$PASSWD\" | sudo -S -p '' mv '{}' \"/tmp/isl-download/$FILENAME.zip\" >/dev/null 2>&1" \
"echo -e \"\n[INFO] - Arquivo $HOME/Downloads/$FILENAME2 nao encontrado\""

if [ $? -eq 0 ]; then
    islOnline_extract_install "/tmp/isl-download"
else
    # tenta em $HOME
    check_and_handle_files "$HOME" "$FILENAME2" \
    "printf '%s\n' \"\$PASSWD\" | sudo -S -p '' mv '{}' \"/tmp/isl-download/$FILENAME.zip\" >/dev/null 2>&1" \
    "echo -e \"\n[INFO] - Arquivo $HOME/$FILENAME2 nao encontrado\""

    if [ $? -eq 0 ]; then
        islOnline_extract_install "/tmp/isl-download"
    else
        pause
        menuOptions
    fi
fi
}

islOnline_extract_install() {
	local DESTINO="$1"

if [[ "$islOnlineType" == "AlwaysOn" ]]; then
	echo -e "\n[Extraindo ISL_AlwaysOn . . .]"
	printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o $DESTINO/ISL_AlwaysOn.zip -d $DESTINO >/dev/null 2>&1
	
	shopt -s nullglob
	local checkFile=($DESTINO/*)
	if [ ${#checkFile[@]} -gt 0 ]; then
		echo -e "${G1}✅${End} Arquivos extraídos com sucesso!"
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $DESTINO/*.zip >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x $DESTINO/* >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' mv $DESTINO/* $DESTINO/ISL_AlwaysOn >/dev/null 2>&1
	else
		echo -e "${R1}❌${End} Falha na extração ou arquivo estava vazio."
		pause
		menuOptions
	fi
	shopt -u nullglob

	echo -e "\n${G1}[Instalando ISL_AlwaysOn Unidades Parceiras. . .]${End}\n"
	cd $DESTINO >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' ./ISL_AlwaysOn install_missing
fi
islOnline_Atalho
}

islOnline_SoftwareHouse() {
clear
echo -e "\n${C1}[Install/Reinstall ISL_AlwaysOn Acesso Remoto. . .]${End}"

echo -e "\n[Download ISL_AlwaysOn . . .]"
if [ -e "/tmp/ISL_AlwaysOn.zip" ]; then
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/tmp/ISL_AlwaysOn.zip" >/dev/null 2>&1
fi
if [ -d "/tmp/ISL_AlwaysOn" ]; then
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/tmp/ISL_AlwaysOn" >/dev/null 2>&1
fi

downloadArquivo "$URLISLONLINE" "/tmp/ISL_AlwaysOn.zip"
folderpermission_create "/tmp/ISL_AlwaysOn"

echo -e "\n[Extraindo ISL_AlwaysOn . . .]"
printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o /tmp/ISL_AlwaysOn.zip -d "/tmp/ISL_AlwaysOn" >/dev/null 2>&1
shopt -s nullglob
local checkFile=(/tmp/ISL_AlwaysOn/*)
if [ ${#checkFile[@]} -gt 0 ]; then
	echo -e "${G1}✅${End} - Arquivo extraído com sucesso!"
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x /tmp/ISL_AlwaysOn/* >/dev/null 2>&1
else
    echo -e "${R1}❌${End} - Falha na extração ou arquivo estava vazio."
	pause
	menuOptions
fi
shopt -u nullglob

echo -e "\n${G1}[Instalando ISL_AlwaysOn Software House. . .]${End}\n"
	cd /tmp/ISL_AlwaysOn/ >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' ./ISL_AlwaysOn install_missing

islOnline_Atalho
}

islOnline_Atalho() {
	if [ ! -e "/pdv/exec/img/isl_online.png" ]; then
		echo -e "\n[Ajuste atalho ISL_Online . . .]"
		printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $appsIco -O $iconPath/img.zip 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o $iconPath/img.zip -d $iconPath 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $iconPath/img.zip 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R $iconPath/* 2>/dev/null
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R $iconPath/* 2>/dev/null
	fi

if [[ "$islOnlineType" == "AlwaysOn" ]]; then
    if [ -e "/opt/ISLOnline/ISLAlwaysOn/ISLAlwaysOn" ]; then
        echo -e "\n${G1}✅${End} - ${B1}Processo finalizado.${End}"
        echo -e "${B1}Por favor informe o Analista para verificar o Painel ISL dele${End}"
        echo -e "${B1}E conectar no equipamento de nome:${End} ${G1}$HOSTNAME${End} \n"

        if [ ! -e "/opt/ISLOnline/ISLAlwaysOn/isl_online.png" ]; then
            printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p "/pdv/exec/img/isl_online.png" "/opt/ISLOnline/ISLAlwaysOn" 2>/dev/null
        fi

        if [ ! -e "/pdv/util/ISLAlwaysOn.desktop" ]; then
            filepermission_create "/pdv/util/ISLAlwaysOn.desktop" >/dev/null 2>&1

            cat <<EOF > "/pdv/util/ISLAlwaysOn.desktop" 2>/dev/null
[Desktop Entry]
Encoding=UTF-8
Name=ISL AlwaysOn
Exec='/opt/ISLOnline/ISLAlwaysOn/ISLAlwaysOn' overview
Type=Application
Categories=Application;Network;
Icon=/opt/ISLOnline/ISLAlwaysOn/isl_online.png
EOF

            printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x "/pdv/util/ISLAlwaysOn.desktop" >/dev/null 2>&1
			while IFS= read -r desktopFolder; do
				printf '%s\n' "$PASSWD" | sudo -S cp --remove-destination \
					/pdv/util/ISLAlwaysOn.desktop "$desktopFolder/ISLAlwaysOn.desktop"
			done < <(setshortcutfiles)
        fi

        if [ ! -e "/pdv/util/ISLAlwaysOn_Desinstalar.desktop" ]; then
            filepermission_create "/pdv/util/ISLAlwaysOn_Desinstalar.desktop" >/dev/null 2>&1

            cat <<EOF > "/pdv/util/ISLAlwaysOn_Desinstalar.desktop" 2>/dev/null
[Desktop Entry]
Encoding=UTF-8
Name=Uninstall ISL AlwaysOn
Exec='/opt/ISLOnline/ISLAlwaysOn/uninstall.pl'
Type=Application
Categories=Application;Network;
Icon=/opt/ISLOnline/ISLAlwaysOn/isl_online.png
EOF

            printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x "/pdv/util/ISLAlwaysOn_Desinstalar.desktop" >/dev/null 2>&1
			while IFS= read -r desktopFolder; do
				printf '%s\n' "$PASSWD" | sudo -S cp --remove-destination \
					/pdv/util/ISLAlwaysOn_Desinstalar.desktop "$desktopFolder/ISLAlwaysOn_Desinstalar.desktop"
			done < <(setshortcutfiles)
        fi

        if [ "$logNameFile" = "InstallReinstall_ISLOnline_SoftwareHouse" ]; then
            createRegisterLog "InstallReinstall_ISLOnline_SoftwareHouse"
        else
            createRegisterLog "InstallReinstall_ISLOnline"
        fi
        finished
    else
        echo -e "\n${R1}❌${End}Falha na instalacao do ISL Online."
        createRegisterLog "FALHA_InstallReinstall_ISLOnline"
        pause
        menuOptions
    fi
fi


if [[ "$islOnlineType" == "LightClient" ]]; then
    local DESTINO=/pdv/util/isl_LightClient

    printf '%s\n' "$PASSWD" | sudo -S -p '' cp --remove-destination -p "/pdv/exec/img/isl_online.png" "$DESTINO" 2>/dev/null

    filepermission_create "$DESTINO/run_light_client.sh" >/dev/null 2>&1
    filepermission_create "/pdv/util/ISL_Light.desktop" >/dev/null 2>&1

    cat << EOF > "$DESTINO/run_light_client.sh" 2>/dev/null
#!/bin/bash
cd "$DESTINO" >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' ./ISL_Light_Client
EOF

    cat << EOF > "/pdv/util/ISL_Light.desktop" 2>/dev/null
[Desktop Entry]
Encoding=UTF-8
Name=Suporte - Acesso Remoto ISL Light
Exec=$DESTINO/run_light_client.sh
Type=Application
Categories=Application;Network;
Icon=$DESTINO/isl_online.png
EOF

    printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x "/pdv/util/ISL_Light.desktop" >/dev/null 2>&1
	while IFS= read -r desktopFolder; do
		printf '%s\n' "$PASSWD" | sudo -S cp --remove-destination \
			/pdv/util/ISL_Light.desktop "$desktopFolder/ISL_Light.desktop"
	done < <(setshortcutfiles)

	echo -e "\n${G1}✅${End} - ISL_ISL_Light_Client instalado, execute ele a partir do novo atalho."

    createRegisterLog "InstallReinstall_ISLOnline_LightClient"
    finished
fi
}

islOnline_Unninstal_LightClient() {

echo -e "\n${C1}[Desinstalacao ISLOnline_LightClient Acesso Remoto. . .]${End}"

printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "/pdv/util/isl_LightClient/" >/dev/null 2>&1
printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf "$HOME/Desktop/ISL_Light.desktop" >/dev/null 2>&1

if [ ! -d  "/pdv/util/isl_LightClient/" ]; then
	if [ ! -e  "$HOME/Desktop/ISL_Light.desktop" ]; then
		echo -e "\n${G1}✅${End} - ${B1}ISLOnline_LightClien desinstalado.${End}"
	fi
fi

	createRegisterLog "Unninstall_ISLOnline_LightClient"
}

islOnline_CheckLinuxVersion() {
if [[ ${LINUX_VERSION} == "16.04" ]]; then
	echo -e "\n${R1}❌${End}Linux 16.04 nao compativel para a versao AlwaysOn."
	echo -e "Instale o ISL_Light_Client - Acesso monitorado e unico"
	pause ; islOnline_menu
elif [[ ${LINUX_VERSION} == "18.04" ]]; then
	echo -e "\n${R1}❌${End}Linux 18.04 nao compativel para a versao AlwaysOn."
	echo -e "Instale o ISL_Light_Client - Acesso monitorado e unico"
	pause ; islOnline_menu
fi
}

menuProperties() {
	if [ ! -e "/vr/vr.properties" ]; then
		echo -e "\n${Y1}⚠️${End} [INFO] Arquivo properties nao encontrado ${Y1}⚠️${End}"
		echo -e "Download do properties em andamento . . ."
		vrpropertiescreate
	fi
	clear
	echo ""
	separador
	echo -e "1. Configurar NFCe no vr.properties"
	echo -e "2. Ativar ContingenciaNFCe fixa: nfce.contingenciaoffline=true"
	echo -e "3. Parametro timeout VRPix: vrpix.timeout=800"
	echo -e "4. Controle de sensibilidade em Biometria ControlID: biometria.sensibilidade="
	echo -e "${LNFP}5. Retornar Menu Principal${End}"
	echo -e "6. Sair do Script"
	read -p "Opcao:" OPTMENUPROPERTIES
			
	if [ -z "$OPTMENUPROPERTIES" ] || ! [[ "$OPTMENUPROPERTIES" =~ ^[0-9]+$ ]]; then
		echo -e "\n${R1}Erro: você deve escolher uma opcao valida.${End}" ; pause ; menuProperties
	fi
	if [ $OPTMENUPROPERTIES -eq 1 ]; then
		settingVRProperties_NFCe
	fi
	if [ $OPTMENUPROPERTIES -eq 2 ]; then
		clearLinesFromFile "/vr/vr.properties" \
		"nfce.contingenciaoffline"
		local lines=("nfce.contingenciaoffline=true")
		insertLinesForFile "/vr/vr.properties" "${lines[@]}"
		createRegisterLog "VRProperties_nfce.contingenciaoffline"
	fi
	if [ $OPTMENUPROPERTIES -eq 3 ]; then
		clearLinesFromFile "/vr/vr.properties" \
		"vrpix.timeout"
		local lines=("vrpix.timeout=800")
		insertLinesForFile "/vr/vr.properties" "${lines[@]}"
		createRegisterLog "VRProperties_vrpix.timeout"
	fi
	if [ $OPTMENUPROPERTIES -eq 4 ]; then
		clearLinesFromFile "/vr/vr.properties" \
		"biometria.sensibilidade="
		echo ""
		read -p "Informe um valor para sensibilidade, onde 10 muito sensivel e conforme maior se torna menos sensivel: " SENSIBILIDADEVALOR
		local lines=("vrpix.timeout=$SENSIBILIDADEVALOR")
		insertLinesForFile "/vr/vr.properties" "${lines[@]}"
		createRegisterLog "VRProperties_vrpix.timeout=$SENSIBILIDADEVALOR"
	fi
	if [ $OPTMENUPROPERTIES -eq 5 ]; then
		menuOptions
	fi
	if [ $OPTMENUPROPERTIES -eq 6 ]; then
		exit
	fi
	if [ $OPTMENUPROPERTIES -ge 7 ]; then
		echo -e "\n${R1}Opcao incorreta, retornando ao menu principal${End}" ; pause ; menuProperties
	fi
}

settingVRProperties_NFCe() {
	# clear
	echo ""
	local file="/vr/vr.properties"
	date=$(date '+%Y-%m-%d_%H:%M:%S')
	filepermission $file
	printf '%s\n' "$PASSWD" | sudo -S -p '' cp -p $propertiespdv "/vr/vr_$date.properties" >/dev/null 2>&1
		
	# read -p "Informe o CSC: " CSC_INFO
	# read -p "Informe o IDToken: " IDTOKEN_INFO
	# read -p "Informe a senha do Certificado: " SENHACERT_INFO
	CSC_INFO=$(ask_input "Informe o CSC: ")
	IDTOKEN_INFO=$(ask_input "Informe o IDToken: ")
	SENHACERT_INFO=$(ask_input "Informe a senha do Certificado: ")
	
	local patterns=(
	"######################################################"
	"#-----------------------------------------------------"
    "nfce.idtoken"
	"nfce.csc"
	"nfce.certificado.senha"
	"nfce.certificado.tipo=A1"
	"nfce.tempoconexao="
	"nfce.tipoambiente="
	"nfce.certificado.diretorio"
	"nfce.diretorio"
	"nfce.enviaintermediador=true"
	"nfe.idtoken"
	"nfe.csc"
	"nfe.certificado.senha"
	"nfe.certificado.tipo=A1"
	"nfe.tempoconexao="
	"nfe.tipoambiente="
	"nfe.certificado.diretorio"
	"nfe.diretorio"
	"repositorio.windows"
    )
	clearLinesFromFile "$file" "${patterns[@]}"
	filepermission $file

	echo "######################################################" >> "$file"
	echo "nfce.idtoken=$IDTOKEN_INFO" >> "$file"
	echo "nfce.csc=$CSC_INFO" >> "$file"
	echo "nfce.certificado.senha=$SENHACERT_INFO" >> "$file"
	echo "nfce.certificado.tipo=A1" >> "$file"
	echo "nfce.tempoconexao=10" >> "$file"
	echo "nfce.tipoambiente=1" >> "$file"
	echo "nfce.certificado.diretorio=/vr/nfe/certificado/" >> "$file"
	echo "nfce.diretorio=/vr/nfe/" >> "$file"
	echo "nfce.enviaintermediador=true" >> "$file"
	echo "#-----------------------------------------------------" >> "$file"
	echo "nfe.idtoken=$IDTOKEN_INFO" >> "$file"
	echo "nfe.csc=$CSC_INFO" >> "$file"
	echo "nfe.certificado.senha=$SENHACERT_INFO" >> "$file"
	echo "nfe.certificado.tipo=A1" >> "$file"
	echo "nfe.tempoconexao=10" >> "$file"
	echo "nfe.tipoambiente=1" >> "$file"
	echo "nfe.certificado.diretorio=/vr/nfe/certificado/" >> "$file"
	echo "nfe.diretorio=/vr/nfe/" >> "$file"
	echo "######################################################" >> "$file"
	
	createRegisterLog "NFCe_VRProperties"
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

insertLinesForFile() {
    local file="$1"
    shift             

    for cmd in "$@"; do
        echo "$cmd" >> "$file"
    done
}

ask_input() {
    local prompt="$1"
    local input=""

    while [[ -z "$input" ]]; do
        read -p "$prompt" input
        if [[ -z "$input" ]]; then
            echo "[ERRO] O valor não pode ser vazio!"
        fi
    done

    echo "$input"
}

show_usb_devices() {
    # Método mais robusto usando array e loop
    local DEVICES=()
    local printdeviceLink="Dispositivo USB Conectado: DESCONHECIDO"
    
    # Adiciona dispositivos ttyACM
    for device in /dev/ttyACM*; do
        [[ -e "$device" ]] && DEVICES+=("$device")
    done
    
    # Adiciona dispositivos ttyUSB
    for device in /dev/ttyUSB*; do
        [[ -e "$device" ]] && DEVICES+=("$device")
    done

    # Adiciona dispositivos USB de impressora (ex: /dev/usb/lp2)
    for device in /dev/usb/lp*; do
        [[ -e "$device" ]] && DEVICES+=("$device")
    done

    if [ ${#DEVICES[@]} -eq 0 ]; then
        echo "Nenhum dispositivo /dev/ttyACM ou /dev/ttyUSB encontrado."
        return
    fi

    # Agora percorre todos os dispositivos de uma vez
    for DEV in "${DEVICES[@]}"; do
        echo "------------------------------------------------------------"
        echo "Detalhes do dispositivo: $DEV"
        udevadm info --query=all --name="$DEV" \
          | grep -E "^(E: ID_MODEL=|E: ID_MODEL_ENC=|E: SUBSYSTEM=|E: ID_BUS=|E: ID_VENDOR_ID=|E: ID_MODEL_ID=|E: DEVPATH=|DEVNAME=)"
        
        echo ""
        echo "Aliases / symlinks apontando para $DEV:"
        FOUND=0
        for LINK in /dev/tty* ; do
            if [ -L "$LINK" ] 2>/dev/null; then
                TARGET=$(readlink -f "$LINK")
                if [ "$TARGET" = "$DEV" ]; then
                    usbDevicesList "$LINK"
                    echo -e "  $TARGET >> ${B1} $LINK ${End}"
                    echo -e "${G1} ✅ $printdeviceLink${End}"
                    FOUND=1
                fi
            fi
        done
        [ $FOUND -eq 0 ] && echo -e "${Y1}⚠️${End} -[INFO] Nenhuma porta /dev/ttyS90* encontrada ${Y1}⚠️${End} -"
        echo "------------------------------------------------------------"
    done
}

usbDevicesList() {
	local deviceLink="$1"

	if [ "$deviceLink" == "/dev/ttyS901" ]; then
		printdeviceLink="Dispositivo USB Conectado: SAT"
	elif [ "$deviceLink" == "/dev/ttyS902" ]; then
		printdeviceLink="Dispositivo USB Conectado: IMPRESSORA USB"
	elif [ "$deviceLink" == "/dev/ttyS903" ]; then
		printdeviceLink="Dispositivo USB Conectado: PINPAD"
	elif [ "$deviceLink" == "/dev/ttyS904" ]; then
		printdeviceLink="Dispositivo USB Conectado: BALANCA USB"
	fi
	
}

updateUtilitarioPDV() {

	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /usr/share/applications/utilitario-pdv.desktop >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /tmp/utilitario-pdv >/dev/null 2>&1
	while IFS= read -r desktopFolder; do
		printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/utilitario-pdv.desktop" >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S rm -rf "$desktopFolder/Utilitario.desktop" >/dev/null 2>&1
	done < <(setshortcutfiles)

	folder_create /tmp/utilitario-pdv
	filepermission_create "/tmp/utilitario-pdv/Utilitario.desktop" >/dev/null 2>&1
	local tmpShortcut="/tmp/utilitario-pdv/Utilitario.desktop"
    local execPath="/pdv/script.sh"
    local iconFile="/pdv/exec/img/Utilitario.png"
	local iconPath="/pdv/exec/img/"

    cat <<EOF > "$tmpShortcut" 2>/dev/null
[Desktop Entry]
Name=Utilitário PDV
Exec=$execPath
Icon=$iconFile
Type=Application
Terminal=true
EOF

	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x "$tmpShortcut"

	while IFS= read -r desktopFolder; do
		printf '%s\n' "$PASSWD" | sudo -S cp --remove-destination -p /tmp/utilitario-pdv/Utilitario.desktop "$desktopFolder/Utilitario.desktop"
	done < <(setshortcutfiles)

	if [ ! -e "$iconPath/Utilitario.png" ];then
		printf '%s\n' "$PASSWD" | sudo -S -p '' mkdir -p -m 777 $iconPath >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' wget -c --no-check-certificate $appsIco -O $iconPath/img.zip >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' unzip -q -o $iconPath/img.zip -d $iconPath >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf $iconPath/img.zip >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R $iconPath/* >/dev/null 2>&1
		printf '%s\n' "$PASSWD" | sudo -S -p '' chown "nobody:nogroup" -R $iconPath/* >/dev/null 2>&1
	fi
	
	date=$(date '+%Y-%m-%d_%H:%M:%S')
	filepermission_create "$logs_path/UtilitarioShortcutOk.txt >/dev/null 2>&1"
	echo "Utilitario Ajustado em $date" >> $logs_path/UtilitarioShortcutOk.txt
}

# Opcao 25
#temp() {
#}

updateUtility() {
	clear
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod -R 777 /pdv/util 2>/dev/null
	
	echo "$SHEBANG" >> /pdv/util/Update_Script.sh
	echo "echo $PASWD | sudo -S rm -rf /pdv/script.sh" >> /pdv/util/Update_Script.sh
	echo "echo $PASWD | sudo -S wget -c --no-check-certificate https://storage.googleapis.com/linux-pdv/Jeff/script-jeff.sh -O /pdv/script.sh" >> /pdv/util/Update_Script.sh
	echo "if [ \$? -ne 0 ]; then"  >> /pdv/util/Update_Script.sh
	echo "   clear ; echo "" ; echo \"Erro ao fazer download do novo Script\" ; read -n 1 -s -r -p \"Press to Exit/Continue. . .\" ; exit" >> /pdv/util/Update_Script.sh
	echo "fi" >> /pdv/util/Update_Script.sh
	echo "echo $PASWD | sudo -S chmod +x /pdv/script.sh" >> /pdv/util/Update_Script.sh
	echo "echo $PASWD | sudo -S chmod 777 /pdv/script.sh" >> /pdv/util/Update_Script.sh
	echo "echo $PASWD | sudo -S chown nobody:nogroup /pdv/script.sh" >> /pdv/util/Update_Script.sh
	echo "sed -i -e 's/$//' /pdv/script.sh" >> /pdv/util/Update_Script.sh
	
    printf '%s\n' "$PASSWD" | sudo -S -p '' chmod +x /pdv/util/Update_Script.sh >/dev/null 2>&1
	clear ; printf '%s\n' "$PASSWD" | sudo -S -p '' bash /pdv/util/Update_Script.sh >/dev/null 2>&1
    clear ; echo -e "${BP1}Script atualizado, por favor execute-o novamente${End}\n"
    sleep 1
	exit
}

autoUpdateScript() {
	vrs_pdv=$(grep "vrs=" /pdv/script.sh 2>/dev/null | cut -d '=' -f 2)
	
	clear
	echo ""
	echo -e "\n${Y1}⏳${End} ${LNFP}- Validando versao do Script . . . Aguarde . . . :D${End} - ${Y1}⏳${End}"
	echo -e "${B1}ℹ️${End} ${LNFP}- Versao do arquivo: $vrs${End}\n"
	
	if [ -e "/tmp/script.sh" ];then
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /tmp/script.sh >/dev/null 2>&1
	fi

	local tamanho_minimo=150

	# Aciona funcao para download
	download_script 10
	
	# Verifica se o wget ainda está em execução
	if ps | grep -q "[w]get"; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' pkill -f "[w]get"
	fi
	
	if [ ! -e /tmp/script.sh ]; then
		echo -e "\n\n${R1}❌${End} ${R1}- Arquivo nao atualizado, se possivel atualize manualmente.[1]${End}"
		skipWget=1
		sleep 3
		return 1
	else
		if [[ $(stat -c%s "/tmp/script.sh") -lt $((tamanho_minimo * 1024)) ]]; then
			echo -e "\n\n${R1}❌${End} ${R1}- Arquivo nao atualizado, se possivel atualize manualmente.[2]${End}"
			skipWget=1
			sleep 3
			return 1
		fi
	skipWget=0
	fi
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 /tmp/script.sh >/dev/null 2>&1
	# Extrair o valor da linha "vrs" do arquivo /pdv/script.sh
	#vrs_pdv=$(grep "vrs=" /pdv/script.sh | cut -d '=' -f 2 >/dev/null 2>&1)

	vrs_tmp=$(grep "vrs=" /tmp/script.sh 2>/dev/null | cut -d '=' -f 2)
	if [ -z "$vrs_tmp" ]; then
		echo -e "\n${R1}❌${End} ${R1}- Arquivo nao atualizado, se possivel atualize manualmente.[3]${End}" ; skipWget=0 ; sleep 3 ; return 1
	else
		if [[ "$vrs_pdv" < "$vrs_tmp" ]]; then
			echo -e "\n${B1}🔄${End} ${RP1}- Existe uma nova versão do Script, aguarde enquanto Auto Atualiza${End}"
			sleep 2
			date=$(date '+%Y-%m-%d_%H:%M:%S')
			filepermission_create "/pdv/util/AutoUpdateScript.txt"
			echo "AutoUpdate Script em $date" >> /pdv/util/AutoUpdateScript.txt
			printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /tmp/script.sh >/dev/null 2>&1
			updateUtility
		else
			echo -e "${G1}✅${End} ${BP1}- Versao Ok ! ! !${End}" ; echo -e "${BP1} :D${End}" ; sleep 2
			printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /tmp/script.sh >/dev/null 2>&1 ; return 0
		fi
	fi
}

download_script() {
    local url="https://storage.googleapis.com/linux-pdv/Jeff/script-jeff.sh"
    local output="/tmp/script.sh"
    local timeout="$1"
    local log_file="/tmp/wget.log"

    # Limpa o log anterior
    > "$log_file"

    # Executa o wget em segundo plano e captura a saída no log
    printf '%s\n' "$PASSWD" | sudo -S -p '' timeout "$timeout" wget -c --no-check-certificate "$url" -O "$output" > "$log_file" 2>&1 &
    local wget_pid=$!

    # Aguarda até 5 segundos verificando se o arquivo começou a ser criado
    local counter=0
    while kill -0 $wget_pid 2>/dev/null && [ $counter -lt 5 ]; do
        if [ -s "$output" ]; then
            echo "Download em progresso, arquivo detectado..."
        fi
        sleep 1
        ((counter++))
    done

    # Aguarda o término do wget
    wait $wget_pid

    # Verificação final: se download completou com 100% ou se arquivo existe e não está vazio
    if grep -q "100%" "$log_file" || [ -s "$output" ]; then
        # Verifica se o conteúdo é plausivelmente um script
        if grep -Eq '^#!(/bin/(bash|sh))|^[[:space:]]*echo|^[[:space:]]*function' "$output"; then
            # echo "Script baixado com conteúdo válido."
            rm -f "$log_file"
            return 0
        else
            echo "Arquivo baixado, mas não parece ser um script válido."
            rm -f "$output" "$log_file"
            return 2
        fi
    else
        echo "Erro no download ou timeout atingido."
        rm -f "$output" "$log_file"
        return 1
    fi
}

downloadArquivo() {
    local URL="$1"
    local DESTINO="$2"

    printf '%s\n' "$PASSWD" | sudo -S -p '' timeout 30 wget -c --no-check-certificate "$URL" -O "$DESTINO" 2>/dev/null

    if [ $? -ne 0 ]; then
        echo -e "\n${R1}Falha no download: Tempo excedido ou erro de conexão.${End}"
		echo "1. Continuar"
		echo "2. Sair"
		read -p "Escolha uma opcao: " OPTDOWNLOADFILE
		if [ $OPTDOWNLOADFILE -eq 1 ]; then	
			:
		fi
		if [ $OPTDOWNLOADFILE -eq 2 ]; then	
			menuOptions
		fi
		if [ $OPTDOWNLOADFILE -ge 3 ]; then
			echo -e "\n${R1}Opcao incorreta, retornando ao menu de Apps${End}" ; pause ; subMenu
		fi
    fi
	
	if ps | grep -q "[w]get"; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' pkill -f "[w]get"
	fi
}

resetVariables() {
	setcheckvariable=0
	reinstallHamsterDXcheck=notok
	connectionTest=notfailed
	local logNameFile=""
	mountUserPWstatus=0
	ajusteTempoAtraso=0
}

killApp() {
	local app="$1"
	printf '%s\n' "$PASSWD" | sudo -S -p '' killall $app >/dev/null 2>&1
	printf '%s\n' "$PASSWD" | sudo -S -p '' pkill -9 $app >/dev/null 2>&1
}

menuOptions() {
	
	if [[ "$openpdv" == "false" ]]; then
		killApp java
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /vr/exec/pdv.sh >/dev/null 2>&1
	fi

	openpdv=false
	clear
	PASSWD=$(</pdv/SENHA_SUDO.txt)
	if [ -e "/pdv/util/Update_Script.sh" ]; then
		printf '%s\n' "$PASSWD" | sudo -S -p '' rm -rf /pdv/util/Update_Script.sh >/dev/null 2>&1
	fi
	echo -e "\n${Y1}⏳${End} - ${LNFP}[Carregando...Aguarde...]${End} - ${Y1}⏳${End}"
	startCheck
	resetVariables
	numerodiasLogDMP
	clear
	
	printf '%s\n' "$PASSWD" | sudo -S -p '' chmod 777 -R /pdv/util 2>/dev/null
	printf '%s\n' "$PASSWD" | sudo -S -p '' chown "$USER:firebird" -R /pdv/util 2>/dev/null

	echo ""
	separador
	echo -e "          ${LNFP}MENU SUPORTE PDV LINUX${End}          | ${CM1}Vrs.$vrs${End}"
	echo -e "${LFP}Linux instalado em:${End} ${CM1}$LINUX_INSTALL_DATE${End}"
	echo -e "${LFP}Versao Linux:${End} ${CM1}$Print_Menu${End}"
	echo -e "${LFP}Java Vrs:${End} ${CM1}$java_version${End} ${CM1}$java_architeture${End}"
	echo -e "${LFP}Ip Atual:${End} ${CM1}$ip_address${End} | ${LFP}ECF:${End} ${CM1}$ecfcaixa${End}"
	separador
	echo "1. Libs Sitef, Sitef Express" 
	echo "2. Atualizar VR.FDB"
	echo "3. Renomear PDV.FDB"
	echo -e "${G1}4. [SubMenu]${End} Java,Apps,Atualizar Linux,ScreenSaver,Controle de Energia,Outros"
	echo "5. Atualizar Libs PDV"
	echo "6. Corrigir Permissoes"
	echo "7. Atualizar VRRules"
	echo "8. Copiar VRPdv.jar (atualizar pdv)"
	echo "9. Ajuste de Resolucao PDV"
    echo -e "${B1}10. Instalar PDV${End}"
	echo "11. Mapear /pdv_vr/"
	echo "12. Criar Atalhos PDV / Apps VR"
	echo -e "${C1}13. Versao Linux, Qtdade de Memoria, Processador, etc${End}"
	echo "14. Biometrias - HamsterDX / Futronic"
	echo -e "${G1}15. Atualizar Script${End}"
	echo "16. Check PDV Status Instalacao"
	echo -e "${G1}17. Checklist PDV (Manutencao)${End}"
	echo -e "${B1}18. ISL_ONLINE [Novo Acesso Remoto]${End}"
	echo "19. SubMenu VR.PROPERTIES"
	echo -e "${WB1}20. Abrir PDV${End}"
	echo "21. Gerenciador de Dispositivos - Listar Dispositivos"
	echo -e "${R1}98. Reiniciar PC${End}"
	echo "99. Sair"
	read -p "Escolha uma das opcoes: " OPTION
		case $OPTION in
				1 ) menuSitef ; echo "" ; finished ; pause ; menuOptions;;
				2 ) atualizarBancoVR && echo "" &&  pause && menuOptions || fail "Falha ao atualizar banco VR.FDB" ;;
				3 ) renamePDVFDB ; echo "" ; pause ; menuOptions;;
				4 ) subMenu ; echo "" ; pause ; menuOptions;;
				5 ) atualizarLibsPDV && echo "" && pause && menuOptions || fail "Falha ao Atualizar Libs PDV" ;;
				6 ) corrigirPermissoes && pause && menuOptions || fail "Falha ao Corrigir Permissoes PDV" ;;
				7 ) atualizarVRRules && pause && menuOptions || fail "Falha ao Atualizar VRRules" ;;
				8 ) atualizarPDV && echo "" && pause && menuOptions || fail "Falha ao atualizar PDV" ;;
				9 ) manualAdjustment && echo "" && pause && menuOptions || clear ; echo "Falha no ajuste de resolucao." ; sleep 2 ;;
				10 ) installPDV && echo "" && pause && menuOptions || clear ; echo "Falha Instalar PDV" ; sleep 2 ;;
				11 ) mountServerShared ; echo "" ; pause ; menuOptions;;
				12 ) atalhoMenu ; pause ; menuOptions;;
				13 ) properties ; echo "" ; pause ; menuOptions;;
				14 ) menubiometrias ; echo "" ; pause ; menuOptions;;
				15 ) updateUtility;;
				16 ) checkPDVInstalled ; menuOptions;;
				17 ) checklistPDV ; pause ; menuOptions;;
				18 ) islOnline_menu ; pause ; menuOptions;;
				19 ) menuProperties ; finished ; pause ; menuOptions;;
				20 ) menuOpenPDV;;
				21 ) echo "" ; show_usb_devices ; finished ; pause ; menuOptions;;
				#25 ) temp ; pause ; menuOptions;;
				66 ) linuxFullUpdate ; echo "" ; finished ; pause ; menuOptions;;
				80 ) checkDmesg;;
				98 ) printf '%s\n' "$PASSWD" | sudo -S -p '' reboot -f ;;
				99 ) exit ;;
			* ) echo "Opcao invalida." ; sleep 1 ; menuOptions ;;
		esac
}

autoUpdateScript
menuOptions