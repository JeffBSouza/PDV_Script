#!/bin/bash

# https://storage.googleapis.com/linux-pdv/Jeff/MercafacilCRM.sh
# sudo mkdir -p 777 /vr; sudo rm -rf /vr/script.sh; sudo wget -c --no-check-certificate https://storage.googleapis.com/linux-pdv/Jeff/MercafacilCRM.sh -O /vr/scriptMercafacil.sh; sudo chmod +x /vr/scriptMercafacil.sh; /vr/scriptMercafacil.sh

jarPath_vr_exec="/vr/exec"
jarPath_home_vr_exec="$HOME/.vr/server/exec"
fileScript="/vr/VRGerenciadormercafacil.sh"
fileScript_Config="/vr/VRGerenciadormercafacil_config.sh"

askSudo() {
	clear
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

pause() {
echo -e "Press any button to Exit or Continue..."
read -n 1 -s -r
}
folder_create() {
local FOLDER="$1"
echo "$PASSWD" | sudo -S mkdir -p -m 777 $FOLDER >/dev/null 2>&1
echo "$PASSWD" | sudo -S chown "nobody:nogroup" -R $FOLDER >/dev/null 2>&1
}
filepermission_create() {
local FILE="$1"
echo "$PASSWD" | sudo -S touch "$FILE" # >/dev/null 2>&1
echo "$PASSWD" | sudo -S chmod 777 "$FILE" # >/dev/null 2>&1
echo "$PASSWD" | sudo -S chown nobody:nogroup "$FILE" # >/dev/null 2>&1
}
finished() {
echo -e "\nPROCESSO ENCERRADO"
}
filepermission() {
local FILE="$1"
echo "$PASSWD" | sudo -S chmod 777 "$FILE" >/dev/null 2>&1
echo "$PASSWD" | sudo -S chown nobody:nogroup "$FILE" >/dev/null 2>&1
}

setshortcutfiles() {
    local desktopDirs=("$HOME/Desktop" "$HOME/Área de Trabalho" "$HOME/Área de trabalho")
    local dir
    for dir in "${desktopDirs[@]}"; do
        [ -d "$dir" ] && echo "$dir"
    done
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
		echo -e "\n[FALHA] Erro: você deve escolher uma opcao valida." ; sleep 2 ; valida_execPath
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
		echo -e "\nOpcao incorreta, retornando ao menu principal" ; pause ; valida_execPath
	fi
elif [ -e "$jar_vr_exec" ]; then
    create_scriptMercafacilCRM "$jarPath_vr_exec"
	create_shortcutMercafacilCRM "$jarPath_vr_exec"
elif [ -e "$jar_home_vr_exec" ]; then
    create_scriptMercafacilCRM "$jarPath_home_vr_exec"
	create_shortcutMercafacilCRM "$jarPath_home_vr_exec"
else
    echo -e "ERRO: VRGerenciadorMercaFacil.jar não foi encontrado em nenhum dos diretórios.\nEscolhe um dos caminhos abaixo para seguir com a configuracao e posteriormente envie o arquivo VRGerenciadorMercafacilCRM.jar para a pasta" >&2
	echo Local 1: "$jar_vr_exec"
	echo Local 2: "$jar_home_vr_exec"
    echo ""
	read -r -p -e "Forneça o caminho manual: " jarPath
	create_scriptMercafacilCRM "$jarPath"
fi
}

checkFiles() {
	if [ -e "$fileScript" ]; then
    	echo -e "[SUCESSO] - Script MercafacilCRM criado com sucesso"
	else
		echo -e "[INFO] - Script MercafacilCRM NAO encontrado"
    fi
	if [ -e "$fileScript_Config" ]; then
    	echo -e "[SUCESSO] - Script MercafacilCRM Config criado com sucesso"
	else
		echo -e "\n[INFO] - Script MercafacilCRM Config NAO encontrado"
	fi

shortcuts_to_create=(
    "VRGerenciadorMercafacilCRM.desktop"
    "VRGerenciadorMercafacil_CONFIG.desktop"
)
    for shortcut_file in "${shortcuts_to_create[@]}"; do
        while IFS= read -r desktopFolder; do
            if [ -e "$desktopFolder/$shortcut_file" ]; then
                echo -e "[SUCESSO] - Atalho '$shortcut_file' encontrado em '$desktopFolder'."
            else
                echo -e "[INFO] - Atalho '$shortcut_file' NÃO encontrado em '$desktopFolder'."
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

		echo -e "[SUCESSO] - $file ajustado com sucesso"
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

scriptMercafacilCRM() {
    clear
	echo -e "\n============================================"
	echo -e "Assistente de configuracao MercafacilCRM Linux\n"
	valida_execPath
	create_shortcutMercafacilCRM
	install_update_Gnome
	settingVRProperties_Mercafacil
	checkFiles
	finished
	exit
}

askSudo
scriptMercafacilCRM