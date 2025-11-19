#!/bin/bash
# Versao 1.1 - Alterado estrutura geral do arquivo
# Versao 1.2 - Criado funcao que verifica se o usuario esta executando como root e tambem se o usuario atual esta no arquivo sudoers
# Versao 1.3 - Refatoracao do codigo, implementado funcao installsm
# Versao 1.4 - Separado funcao de instalar service manager
# Versao 1.5.1 - Ajsutado funcao installsm
# Versao 1.5.2 - Ajustado funcoes do service manager
# Versao 1.5.3 - Ajustado funcao getscappchoices - ainda precisa finalizar
# Versao 1.5.4 - Criado funcao smappchoices e ajustado funcao para escolha de vrencerramento
# Versao 1.5.5 - Ajustado funcao getscappchoices e getsmappchoices para colocar o .war/.jar  no final do nome do arquivo
# Versao 1.5.6 - Ajustado funcao getsc/smappchoices para alterar a permissao do arquivo baixando
# Versao 1.5.7 - Criado funcoes para instalacao server app
# Versao 1.5.8 - Ajustado funcao para usar icone corretamente
# Versao 1.5.9 - Ajustado funcao samba para diretorio vr
# Versao 1.5.10 - Ajustado funcao de criacao de atalhos e adicionado mais opcoes
# Versao 1.6 - Adicionados muitas funcionalidades novas como: instalacao de java, firebird, ssh, docker, anydesk
# Versao 1.7 - Alterado script para uso de convencoes
# Versao 1.8 - Alterado funcao installDocker para instalar repositorio jammy
# Versao 1.9 - Alerado createDesktop para atalho ser criado com categoria System
# Versao 1.9.1 - Alterado createDesktop para maior legibilidade
# Versao 1.9.2 - Alterado createDesktop para que aplicativos normais nao abram com terminal
# Versao 1.9.3 - installDocker voltado a instalar o a saida do comando lsb_release
# Versao 1.9.4 - Autologin
# Versao 2.0 - Removido chmod u+s da funcao de instalar o java
# Versao 2.1 - Criado uma funcao para o exporta precos connect referente a versao do vr master
# Versao 2.2 - Ajustado funcao getVrExportaPrecosConnect e getVrEncerramento
# Versao 2.3 - Ajustado funcao de criacao de aplicativos, adicionado a variavel Path
# Versao 2.4 - Criado nova funcao para remover o protetor de tela
# Versao 2.5 - Criado nova funcao para desabilitar o log de erro do Xsession
# Versao 3.0 - Adicionado funcao para atualizar somente um aplicativo versao 4.2
# Versao 3.1 - Modificado funcao removedor protetor de tela
# Versao 3.2 - Adicionado funcao para gerenciamento dos containers
# Versao 3.3 - Adicinoado nova funcao para verificar versao dos aplicativos atualmente instalados do servicecontainer
# Versao 3.4 - Adicionado nova funcao para listar arquivos do service manager
# Versao 4.0 - Adicionado nova funcao para gerenciamento dos containers do PDV ADMIN DEGUSTACAO
# Versao 4.0 - Adicionado nova funcao para gerneciamento do login do docker
# Versao 4.1 - Adicionado funcoes do pdv web
# Versao 4.2 - Alterado funcoes do pdv para integrador
# Versao 4.3 - Adicionado opÃ§Ã£o de instalaÃ§Ã£o da versÃ£o 4.3 do vr master

# Versao 4.3
SCRIPT_VERSION="4.3"
# Variaveis Globais
VERSAO=''
PATH_USER_HOME="$HOME/.vr"
STORAGE="https://storage.googleapis.com/linux-pdv/gbardini/util/sm"
UBUNTU_IP=$(hostname -I | cut -d' ' -f1)
DB_IP=
DB_PORT=
DB_NAME=
DB_PASSWD=
STORE_NUMBER=
IP_UBUNTU=

# --- util --- #
function getIpUbuntu() {
	read -rp 'Digite o IP do Ubuntu: ' IP_UBUNTU
	# Condicao para verificar se o IP do Ubuntu e valido
	while true; do
		if [ "$IP_UBUNTU" = "$UBUNTU_IP" ]; then
			echo 'O endereco informado corresponde ao IP do ubuntu, continuando com o script.'
			break
		else
			read -rp 'O endereco informado nao Ã© o IP do ubuntu, digite um IP valido: ' IP_UBUNTU
		fi
	done
}

function getPgInfo() {
	read -rp "Digite o IP do banco de dados: " DB_IP
	# Condicao para verificar se o IP do banco esta pingando
	while ! ping -c1 "$DB_IP" &>/dev/null; do
		read -rp 'Digite um endereco valido: ' DB_IP
	done
	read -rp 'Digite a porta do banco de dados: ' DB_PORT
	while true; do
		if ! [[ $DB_PORT =~ ^[0-9]+$ ]]; then
			echo 'Erro: a porta deve ser um nÃºmero inteiro!'
			read -rp 'Digite a porta do banco de dados: ' DB_PORT
		elif (("$DB_PORT" > 65535 || "$DB_PORT" < 1)); then
			echo 'Erro: a porta deve estar entre 1 e 65535'
			read -rp 'Digite a porta do banco de dados: ' DB_PORT
		else
			break
		fi
	done

	read -rp 'Digite a senha do usuario postgres do banco: ' DB_PASSWD
	read -rp 'Digite o numero da loja: ' STORE_NUMBER
	while true; do
		if ! [[ $STORE_NUMBER =~ ^[0-9]+$ ]]; then
			echo 'Erro: a loja deve ser um nÃºmero inteiro!'
			read -rp 'Digite o numero da loja: ' STORE_NUMBER
		else
			break
		fi
	done
	read -rp 'Digite o nome da base (e.g vr): ' DB_NAME
	echo 'Nao ha nenhuma validacao no numero da loja, nome e senha da base informados, caso tenha errado ajuste manualmente depois!'
	sleep 4

}

# --- END util --- #

# Funcao para escolha se deseja continuar no script
function choice() {
	local OPT
	echo -e 'Opcao invalida, deseja encerrar o script?\n\t1) SIM\t2) MENU'
	read -r OPT
	case "$OPT" in
	1) echo 'Encerrando o script!' ;;
	2) main ;;
	*) echo 'Opcao invalida, encerrando o script!' && exit 1 ;;
	esac
}

###servicemanager###
function getMasterVersion() {
	local OPT
	echo "Versao do VRMaster:"
	echo -e "\t1) 4.0"
	echo -e "\t2) 4.1"
	echo -e "\t3) 4.2"
	echo -e "\t4) 4.3"
	echo -e "\t99) Menu"
	read -r OPT
	case "$OPT" in
	1) VERSAO='Versao40' ;;
	2) VERSAO='Versao41' ;;
	3) VERSAO='Versao42' ;;
	4) VERSAO='Versao43' ;;
	99) main ;;
	*) echo 'Versao incorreta, digite novamente!' && getMasterVersion ;;
	esac
}
function serviceManager() {
	local DB_IP DB_PORT IP_UBUNTU DB_NAME DB_PASSWD STORE_NUMBER OPT
	local SM='servicemanager/service'
	local SC='servicecontainer/service'
	local DC_SC_FILE="$PATH_USER_HOME/docker-compose-sm-sc.yml"
	local DC_PORTAL_FILE="$PATH_USER_HOME/docker-compose-portal.yml"
	local DC_DISPLAY_FILE="$PATH_USER_HOME/docker-compose-display-atendimento.yml"
	local DC_ONLINE_FILE="$PATH_USER_HOME/docker-compose-online.yml"
	local SM_DIR="$PATH_USER_HOME/$SM"
	local SC_DIR="$PATH_USER_HOME/$SC"

	sudo usermod -aG docker "$USER"
	echo -e 'O que deseja?
    1) Instalacao do service manager (necessario reinicializacao da maquina para aplicar permissao ao usuario a utilizar o docker)
    2) Atualizacao service manager
    3) Menu'
	read -r OPT
	case "$OPT" in
	1) userSmRequest && getSmConfigFiles && getSmExecutableFiles && echo -e "Configuracao dos arquivos do service manager feita com sucesso! Voce sera redirecionado ao menu de opcoes em 20 segundos.\nSegue o comando do docker:\n docker-compose -f $HOME/.vr/docker-compose-sm-sc.yml up -d" && sleep 20 && main ;;
	2) getUpdateSm ;;
	3) main ;;
	*) choice ;;
	esac
}

function userSmRequest() {
	local UBUNTU_IP
	UBUNTU_IP=$(hostname -I | cut -d' ' -f1)

	read -rp 'Digite o IP do Ubuntu: ' IP_UBUNTU
	# Condicao para verificar se o IP do Ubuntu e valido
	while true; do
		if [ "$IP_UBUNTU" = "$UBUNTU_IP" ]; then
			echo 'O endereco informado corresponde ao IP do ubuntu, continuando com o script.'
			break
		else
			read -rp 'O endereco informado nao Ã© o IP do ubuntu, digite um IP valido: ' IP_UBUNTU
		fi
	done
	read -rp "Digite o IP do banco de dados: " DB_IP
	# Condicao para verificar se o IP do banco esta pingando
	while ! ping -c1 "$DB_IP" &>/dev/null; do
		read -rp 'Digite um endereco valido: ' DB_IP
	done
	read -rp 'Digite a porta do banco de dados: ' DB_PORT
	while true; do
		if ! [[ $DB_PORT =~ ^[0-9]+$ ]]; then
			echo 'Erro: a porta deve ser um nÃºmero inteiro!'
			read -rp 'Digite a porta do banco de dados: ' DB_PORT
		elif (("$DB_PORT" > 65535 || "$DB_PORT" < 1)); then
			echo 'Erro: a porta deve estar entre 1 e 65535'
			read -rp 'Digite a porta do banco de dados: ' DB_PORT
		else
			break
		fi
	done

	read -rp 'Digite a senha do usuario postgres do banco: ' DB_PASSWD
	read -rp 'Digite o numero da loja: ' STORE_NUMBER
	while true; do
		if ! [[ $STORE_NUMBER =~ ^[0-9]+$ ]]; then
			echo 'Erro: a loja deve ser um nÃºmero inteiro!'
			read -rp 'Digite o numero da loja: ' STORE_NUMBER
		else
			break
		fi
	done
	read -rp 'Digite o nome da base (e.g vr): ' DB_NAME
	echo 'Nao ha nenhuma validacao no numero da loja, nome e senha da base informados, caso tenha errado ajuste manualmente depois!'
	sleep 4
}

function getSmConfigFiles() {
	# Criando estrutura de diretÃ³rios do service manager
	echo 'Apagando .vr existente e criando estrutura de diretÃ³rios...'
	if [ -d "$PATH_USER_HOME" ]; then
		sudo find "$PATH_USER_HOME" ! -name server -type f -exec rm -f {} + && sudo find "$PATH_USER_HOME" -mindepth 1 -type d ! -name server -delete
	fi
	mkdir -p "$PATH_USER_HOME"/{"$SM","$SC"}
	tree "$PATH_USER_HOME"

	# Download e configuracao do vr.properties
	echo 'Baixando vr.properties...'
	local AUX="$PATH_USER_HOME/vr.properties"
	curl 'https://storage.googleapis.com/linux-pdv/gbardini/util/sm/vr.properties' -o "$AUX"
	sed -i -e "s/dbIp/$DB_IP/g" -e "s/ubuntuIp/$IP_UBUNTU/g" -e "s/dbPasswd/$DB_PASSWD/g" -e "s/dbName/$DB_NAME/g" -e "s/dbPort/$DB_PORT/g" -e "s/storeNumber/$STORE_NUMBER/g" "$AUX"

	# Download do script para particionar as tabelas automaticamente
	echo 'Baixando script para particionar as tabelas...'
	local AUX="$PATH_USER_HOME/sm.sh"
	curl 'https://storage.googleapis.com/linux-pdv/gbardini/util/sm/sm.sh' -o "$AUX"

	# Download dos arquivos YML
	echo 'Baixando arquivos YML...'
	curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/docker-compose-yml/docker-compose-sm-sc.yml" -o "$DC_SC_FILE"
	sed -i "s/127.0.0.1/$IP_UBUNTU/g" "$DC_SC_FILE"

	curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/docker-compose-yml/docker-compose-portal.yml" -o "$DC_PORTAL_FILE"
	sed -i -e "s/dbIp/$DB_IP/g" -e "s/dbPasswd/$DB_PASSWD/g" -e "s/dbName/$DB_NAME/g" -e "s/dbPort/$DB_PORT/g" "$DC_PORTAL_FILE"

	curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/docker-compose-yml/docker-compose-display-atendimento.yml" -o "$DC_DISPLAY_FILE"

	curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/docker-compose-yml/docker-compose-online.yml" -o "$DC_ONLINE_FILE"
	sed -i -e "s/dbIp/$DB_IP/g" -e "s/dbPasswd/$DB_PASSWD/g" -e "s/dbName/$DB_NAME/g" -e "s/dbPort/$DB_PORT/g" "$DC_PORTAL_FILE"
}

function getSmExecutableFiles() {
	sudo chown -R "$USER:$USER" "$SC_DIR" "$SM_DIR"
	if [ -d "$SM_DIR" ]; then
		sudo rm -rf "$SC_DIR" "$SM_DIR"
		sudo mkdir -p "$SC_DIR" "$SM_DIR"
		sudo chown -R "$USER:$USER" "$SC_DIR" "$SM_DIR"
	fi
	# Download dos arquivos .jar e .war
	echo 'Baixando arquivos do service container...'
	local AUX="$SC_DIR/servicecontainer.tar.gz"
	curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/servicecontainer/service/servicecontainer.tar.gz" -o "$AUX"
	tar -xvzf "$AUX" -C "$SC_DIR"
	rm -rf "$AUX"

	# Download do vrencerramento
	getVrEncerramento
	getVrExportaPrecosConnect
	getVrGerenciadorEcommerce
	if [ "$VERSAO" != 'Versao40' ]; then
		getVrCluster
		getVrHistoricoVenda
	fi

	echo 'Baixando arquivos do service manager...'
	local AUX="$SM_DIR/servicemanager.tar.gz"
	curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/servicemanager/service/servicemanager.tar.gz" -o "$AUX"
	tar -xvzf "$AUX" -C "$SM_DIR"
	rm -rf "$AUX"
	echo 'Download dos arquivos do service manager feita com sucesso!'

	sudo chown -R "$USER:$USER" "$HOME/.vr"
}

function getVrEncerramento() {
	if [ "$VERSAO" = 'Versao40' ]; then
		curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/servicecontainer/service/VREncerramento40.war" -o "$SC_DIR/VREncerramento.war"
	elif [ "$VERSAO" = 'Versao41' ]; then
		curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/servicecontainer/service/VREncerramento41.war" -o "$SC_DIR/VREncerramento.war"
	elif [ "$VERSAO" = 'Versao42' ]; then
		curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/servicecontainer/service/VREncerramento42.war" -o "$SC_DIR/VREncerramento.war"
	else
		curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/servicecontainer/service/VREncerramento43.war" -o "$SC_DIR/VREncerramento.war"
	fi
	sudo chown "$USER:$USER" "$SC_DIR/VREncerramento.war"
}

function getVrExportaPrecosConnect() {
	if [ "$VERSAO" = 'Versao40' ]; then
		curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/servicecontainer/service/VRExportaPrecosConnect40.war" -o "$SC_DIR/VRExportaPrecosConnect.war"
	else
		curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/servicecontainer/service/VRExportaPrecosConnect41.war" -o "$SC_DIR/VRExportaPrecosConnect.war"
	fi
	sudo chown "$USER:$USER" "$SC_DIR/VRExportaPrecosConnect.war"
}

function getVrCluster() {
	if [ "$VERSAO" = 'Versao42' ]; then
		curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/servicecontainer/service/VRCluster42.war" -o "$SC_DIR/VRCluster.war"
	else
		curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/servicecontainer/service/VRCluster43.war" -o "$SC_DIR/VRCluster.war"
	fi
	sudo chown "$USER:$USER" "$SC_DIR/VRCluster.war"
}

function getVrHistoricoVenda() {
	if [ "$VERSAO" = 'Versao42' ]; then
		curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/servicecontainer/service/VRHistoricoVenda42.war" -o "$SC_DIR/VRHistoricoVenda.war"
	else
		curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/servicecontainer/service/VRHistoricoVenda43.war" -o "$SC_DIR/VRHistoricoVenda.war"
	fi
	sudo chown "$USER:$USER" "$SC_DIR/VRHistoricoVenda.war"
}
function getVrGerenciadorEcommerce() {
	if [ "$VERSAO" = 'Versao40' ]; then
		curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/servicecontainer/service/VRGerenciadorEcommerce40.war" -o "$SC_DIR/VRGerenciadorEcommerce.war"
	elif [ "$VERSAO" = 'Versao41' ]; then
		curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/servicecontainer/service/VRGerenciadorEcommerce41.war" -o "$SC_DIR/VRGerenciadorEcommerce.war"
	elif [ "$VERSAO" = 'Versao42' ]; then
		curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/servicecontainer/service/VRGerenciadorEcommerce42.war" -o "$SC_DIR/VRGerenciadorEcommerce.war"
	else
		curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/servicecontainer/service/VRGerenciadorEcommerce43.war" -o "$SC_DIR/VRGerenciadorEcommerce.war"
	fi
	sudo chown "$USER:$USER" "$SC_DIR/VRGerenciadorEcommerce.war"
}

function getUpdateSm() {
	local OPT
	echo "Selecione o que deseja:"
	echo -e "\t1) Atualizar todos os aplicativos"
	echo -e "\t2) Atualizar um aplicativo"
	echo -e "\t3) Menu"
	read -r OPT
	case "$OPT" in
	1) getSmExecutableFiles && main ;;
	2) getSmApp ;;
	3) main ;;
	*) choice ;;
	esac
}

function getSmApp() {
	local OPT
	echo -e 'Qual container deseja atualizar?
    1) ServiceContainer
    2) ServiceManager
    3) Menu'
	read -r OPT
	case "$OPT" in
	1) getScAppChoices && getSmApp ;;
	2) getSmAppChoices && getSmApp ;;
	3) main ;;
	*) choice ;;
	esac
}

function getScAppChoices() {
	local SC_APP OPT
	echo "Opcoes:"
	echo -e "\t1) VREncerramento"
	echo -e "\t2) VRConciliadorTEF"
	echo -e "\t3) VRDisplayatendimento"
	echo -e "\t4) VRCurvaAbc"
	echo -e "\t5) VRGerenciadorEcommerce"
	echo -e "\t6) VRExportaPrecosConnect"
	echo -e "\t7) VRScanntech"
	echo -e "\t8) VRHistoricoVenda"
	echo -e "\t9) VRCluster"
	echo -e "\t10) VRMobileServer"
	echo -e "\t11) Menu"
	read -r OPT
	case "$OPT" in
	1) SC_APP='VREncerramento' ;;
	2) SC_APP='VRConciliadorTEF' ;;
	3) SC_APP='VRDisplayAtendimento' ;;
	4) SC_APP='VRCurvaAbc' ;;
	5) SC_APP='VRGerenciadorEcommerce' ;;
	6) SC_APP='VRExportaPrecosConnect' ;;
	7) SC_APP='VRScanntech' ;;
	8) SC_APP='VRHistoricoVenda' ;;
	9) SC_APP='VRCluster' ;;
	10) SC_APP='VRMobileServer' ;;
	11) main ;;
	*) choice ;;
	esac
	if [ "$OPT" -eq 1 ]; then
		getVrEncerramento
	elif [ "$OPT" -eq 5 ]; then
		getVrGerenciadorEcommerce
	elif [ "$OPT" -eq 6 ]; then
		getVrExportaPrecosConnect
	elif [ "$OPT" -eq 8 ]; then
		getVrHistoricoVenda
	elif [ "$OPT" -eq 9 ]; then
		getVrCluster
	else
		curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/servicecontainer/service/$SC_APP.war" -o "$SC_DIR/$SC_APP".war
		sudo chown -R "$USER:$USER" "$SC_DIR"
	fi
	echo 'Aplicativo atualizado com sucesso!'
}

function getSmAppChoices() {
	local SM_APP OPT
	echo -e 'Opcoes:
    1) VRParticionador
    2) VRExpurgador
    3) VRVendaMedia
    4) Menu'
	read -r OPT
	case "$OPT" in
	1) SM_APP=VRParticionador ;;
	2) SM_APP=VRExpurgador ;;
	3) SM_APP=VRVendaMedia ;;
	4) main ;;
	*) choice ;;
	esac
	curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/servicemanager/service/$SM_APP.jar" -o "$SM_DIR/$SM_APP".jar
	sudo chown -R "$USER:$USER" "$SM_DIR"
	echo 'Aplicativo atualizado com sucesso!'
}

###end service manager###

###criacao de atalhos###
function getExecPath() {
	local OPT
	echo -e "O diretÃ³rio exec esta em qual lugar?
    1) /vr/exec
    2) $HOME/.vr/server/exec
    3) Diretorio customizavel
    4) Menu"
	read -r OPT
	case $OPT in
	1) DIR_EXEC='/vr/exec' ;;
	2) DIR_EXEC="$PATH_USER_HOME/server/exec" ;;
	3) read -rp 'Digite o caminho da exec: ' DIR_EXEC ;;
	4) main ;;
	*) choice ;;
	esac

}

function getApp() {
	local OPT
	echo "Escolha um aplicativo:"
	echo -e "\t1) VRMaster"
	echo -e "\t2) VRConcentrador"
	echo -e "\t3) VRAutorizador"
	echo -e "\t4) VRGlassFishStarter"
	echo -e "\t5) VRChat"
	echo -e "\t6) VRGerenciadorXML"
	echo -e "\t7) VRGerenciadorCRM"
	echo -e "\t8) VRGerenciadorScanntech"
	echo -e "\t9) VRMobileServer"
	echo -e "\t10) VRColetorServer"
	echo -e "\t11) VRFrente"
	echo -e "\t12) VREmissorEtiqueta"
	echo -e "\t13) VRCaixa"
	echo -e "\t14) VRConsultaPreco"
	echo -e "\t15) VRConcentradorAPI"
	echo -e "\t16) VRAtacadoAPI"
	echo -e "\t17) VRIntegracao"
	echo -e "\t18) VRAdm"

	read -r OPT

	case "$OPT" in
	1) APP='VRMaster' ;;
	2) APP='VRConcentrador' ;;
	3) APP='VRAutorizador' ;;
	4) APP='VRGlassFishStarter' ;;
	5) APP='VRChat' ;;
	6) APP='VRGerenciadorXML' ;;
	7) APP='VRGerenciadorCRM' ;;
	8) APP='VRGerenciadorScanntech' ;;
	9) APP='VRMobileServer' ;;
	10) APP='VRColetorServer' ;;
	11) APP='VRFrente' ;;
	12) APP='VREmissorEtiqueta' ;;
	13) APP='VRCaixa' ;;
	14) APP='VRConsultaPreco' ;;
	15) APP='VRConcentradorAPI' ;;
	16) APP='VRAtacadoAPI' ;;
	17) APP='VRIntegracao' ;;
	18) APP='VRAdm' ;;
	*) choice ;;
	esac
}

function getAppChoice() {
	local DESKTOP_DIR DIR_EXEC APP OPT
	if [ -z "$DIR_EXEC" ]; then
		getExecPath
	fi
	# Define o diretÃ³rio de destino para o arquivo .desktop alÃ©m do diretÃ³rio vr
	DESKTOP_DIR=$(xdg-user-dir DESKTOP)

	# Cria o arquivo .desktop com as informacoes fornecidas pelo usuario
	getApp && createDesktop && sudo cp "$DESKTOP_DIR"/*.desktop '/usr/share/applications'

	echo -e "Selecione uma opcao:
    1) Criar arquivo .desktop
    2) Menu"
	read -r OPT
	while true; do
		case "$OPT" in
		1)
			getApp && createDesktop && sudo cp "$DESKTOP_DIR"/*.desktop '/usr/share/applications'
			echo -e "Selecione uma opcao:
               1) Criar arquivo .desktop
               2) Menu"
			read -r OPT
			;;
		2) main ;;
		*) choice ;;
		esac
	done
}

function createDesktop() {
	local NAME_IN_LOWER_CASE ICON_NAME DESKTOP_FILE
	NAME_IN_LOWER_CASE="$(echo "$APP" | tr '[:upper:]' '[:lower:]').desktop"
	ICON_NAME=$(echo "$APP" | tr '[:upper:]' '[:lower:]')
	DESKTOP_FILE="$(xdg-user-dir DESKTOP)/$NAME_IN_LOWER_CASE"

	#if [[ $APP = VRMobileServer ]]; then
	#	echo "$NAME_IN_LOWER_CASE"
	#	echo -e "[Desktop Entry]\nName=$APP\nComment=VRSoftware - ERP\nTerminal=true\nExec=/usr/lib/jvm/java-11-openjdk-amd64/bin/java -jar $DIR_EXEC/$APP.jar\nType=Application\nIcon=$ICON_NAME\nCategories=System" | tee "$(xdg-user-dir DESKTOP)"/"$NAME_IN_LOWER_CASE"
	#	chmod u+x "$(xdg-user-dir DESKTOP)"/"$NAME_IN_LOWER_CASE"
	#	echo "Arquivo $NAME_IN_LOWER_CASE.desktop criado em $(xdg-user-dir DESKTOP)."
	#	return 0
	#fi
	rm -rf "$DESKTOP_FILE"
	if [[ $APP = VRMobileServer || $APP = VRConcentradorAPI || $APP = VRAtacadoAPI ]]; then
		echo "$NAME_IN_LOWER_CASE"
		echo "[Desktop Entry]" >>"$DESKTOP_FILE"
		echo "Name=$APP" >>"$DESKTOP_FILE"
		echo "Path=$DIR_EXEC" >>"$DESKTOP_FILE"
		echo "Comment=VRSoftware - ERP" >>"$DESKTOP_FILE"
		echo "Terminal=true" >>"$DESKTOP_FILE"
		if [[ $APP = VRAtacadoAPI ]]; then
			echo "Exec=/usr/lib/jvm/java-11-openjdk-amd64/bin/java -jar $DIR_EXEC/$APP.war" >>"$DESKTOP_FILE"
		else
			echo "Exec=/usr/lib/jvm/java-11-openjdk-amd64/bin/java -jar $DIR_EXEC/$APP.jar" >>"$DESKTOP_FILE"
		fi
		echo "Type=Application" >>"$DESKTOP_FILE"
		echo "Icon=$ICON_NAME" >>"$DESKTOP_FILE"
		echo "Categories=System" >>"$DESKTOP_FILE"
		chmod 755 "$DESKTOP_FILE"
		gio set "$DESKTOP_FILE" metadata::trusted true
		echo "Arquivo $DESKTOP_FILE criado em $(xdg-user-dir DESKTOP)."
		return 0
	fi
	#if [[ $APP = VRConcentradorAPI ]]; then
	#	echo "$NAME_IN_LOWER_CASE"
	#	echo -e "[Desktop Entry]\nName=$APP\nComment=VRSoftware - ERP\nTerminal=true\nExec=/usr/lib/jvm/java-11-openjdk-amd64/bin/java -jar $DIR_EXEC/$APP.jar\nType=Application\nIcon=vrconcentrador\nCategories=System" | tee "$(xdg-user-dir DESKTOP)"/"$NAME_IN_LOWER_CASE"
	#	chmod u+x "$(xdg-user-dir DESKTOP)"/"$NAME_IN_LOWER_CASE"
	#	echo "Arquivo $NAME_IN_LOWER_CASE.desktop criado em $(xdg-user-dir DESKTOP)."
	#	return 0
	#fi
	#if [[ $APP = VRAtacadoAPI ]]; then
	#	echo "$NAME_IN_LOWER_CASE"
	#	echo -e "[Desktop Entry]\nName=$APP\nComment=VRSoftware - ERP\nTerminal=true\nExec=/usr/lib/jvm/java-11-openjdk-amd64/bin/java -jar $DIR_EXEC/$APP.war\nType=Application\nIcon=vratacadoserver\nCategories=System" | tee "$(xdg-user-dir DESKTOP)"/"$NAME_IN_LOWER_CASE"
	#	chmod u+x "$(xdg-user-dir DESKTOP)"/"$NAME_IN_LOWER_CASE"
	#	echo "Arquivo $NAME_IN_LOWER_CASE.desktop criado em $(xdg-user-dir DESKTOP)."
	#	return 0
	#fi
	echo "$NAME_IN_LOWER_CASE"
	echo "[Desktop Entry]" >>"$DESKTOP_FILE"
	echo "Name=$APP" >>"$DESKTOP_FILE"
	echo "Path=$DIR_EXEC" >>"$DESKTOP_FILE"
	echo "Comment=VRSoftware - ERP" >>"$DESKTOP_FILE"
	echo "Exec=java -jar $DIR_EXEC/$APP.jar" >>"$DESKTOP_FILE"
	echo "Terminal=false" >>"$DESKTOP_FILE"
	echo "Type=Application" >>"$DESKTOP_FILE"
	echo "Icon=$ICON_NAME" >>"$DESKTOP_FILE"
	echo "Categories=System" >>"$DESKTOP_FILE"
	chmod 755 "$DESKTOP_FILE"
	gio set "$DESKTOP_FILE" metadata::trusted true
	echo "Arquivo $DESKTOP_FILE criado em $(xdg-user-dir DESKTOP)."
}
###end criacao de atalhos###
#
###i386 architecture###
function installi386Architecture() {
	sudo dpkg --add-architecture i386
	sudo apt update
}
###end i386 architecture###
#
###firebird###
function installFirebird() {
	local AUX
	AUX='/tmp/firebird-2.5.tar.gz'
	sudo apt-get install -y libncurses5:i386 libtommath1 libstdc++5 lib32stdc++6
	curl 'https://storage.googleapis.com/linux-pdv/gbardini/util/sm/firebird-2.5.tar.gz' -o "$AUX"
	tar -xvzf "$AUX" -C /tmp
	echo 'Execute o comando como root depois que finalizar o script para instalar o FIREBIRD: /tmp/FirebirdSS-2.5.9.27139-0.i686/install.sh'
}
###end firebird###
#
###png icons###
function installIcons() {
	local AUX
	AUX='/tmp/png.tar.gz'
	curl "https://storage.googleapis.com/linux-pdv/gbardini/util/sm/png.tar.gz" -o "$AUX"
	sudo tar xzvf $AUX -C /usr/share/pixmaps
	echo 'Icones instalados com sucesso no /usr/share/pixmaps'
}
###end png icons###
#
###openjdk###
function installOpenJdk() {
	sudo apt purge -y openjdk-8*:amd64
	sudo apt install -y openjdk-8-jdk:i386
	sudo update-alternatives --config java
	echo -e 'Java provavelmente instalado com sucesso verifique o
    update-alternatives --config java'
}
###end openjdk###
#
###samba###
function installSamba() {
	if [[ ! -d '/vr' ]]; then
		sudo mkdir -p /vr/exec
	fi
	sudo chown -R "$USER:$USER" /vr
	sudo chmod -R 2777 /vr
	sudo apt install -y samba
	echo -e "[vr]\n   comment = vr\n   path = /vr\n   writable = yes\n   create mask = 2777\n   directory mask = 2777\n   public = yes" | sudo tee -a /etc/samba/smb.conf
	sudo systemctl restart smbd nmbd
	echo 'Samba instalado e configurado com sucesso!'
}
###end samba###
#
###docker###
function installDocker() {
	sudo apt-get remove -y docker docker-engine docker.io containerd runc
	sudo apt-get update
	sudo apt-get install -y \
		ca-certificates \
		curl \
		gnupg \
		lsb-release

	sudo mkdir -m 0755 -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" |
		sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

	sudo apt-get update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io
	sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	sudo usermod -aG docker "$USER"
	echo 'Docker instalado com sucesso!'
}
###end docker###
###openssh###
function installOpenSsh() {
	sudo apt install -y openssh-server
	echo 'SSH Instalado com sucesso!'
}
###end openssh###
#
###unrar###
function installUnrar() {
	sudo apt install unrar -y
	echo 'Unrar instalado com sucesso!'
}
###end unrar###
#
###repo###
function updRepo() {
	sudo apt-get clean
	sudo apt update
	echo 'Repositorios atualizados com sucesso!'
}
###end repo###
#
###anydesk###
function installAnydesk() {
	curl 'https://storage.googleapis.com/linux-pdv/gbardini/util/sm/anydesk-6.0.1-1-amd64.deb' -o /tmp/anydesk.deb
	curl 'https://storage.googleapis.com/linux-pdv/gbardini/util/sm/libpangox-1.0-amd64.deb' -o /tmp/libpangox.deb
	sudo apt install -y /tmp/libpangox.deb
	sudo apt install -y libgtkglext1
	sudo dpkg -i /tmp/anydesk.deb
	sudo cp /usr/share/applications/anydesk.desktop "$(xdg-user-dir DESKTOP)"
	sudo chown -R "$USER":"$USER" "$(xdg-user-dir DESKTOP)"
	echo 'Anydesk instalado com sucesso!'
}
###end anydesk###
###autologin for vrxubuntu###
function autoLogin() {
	local AUX
	AUX="/etc/lightdm/lightdm.conf"
	if [ -e "$AUX" ]; then
		sudo rm -rf "$AUX"
	fi
	echo "[SeatDefaults]" | sudo tee -a "$AUX"
	echo "autologin-user=$USER" | sudo tee -a "$AUX"
	echo "autologin-user-timeout=0" | sudo tee -a "$AUX"
	echo 'Auto Login configurado com sucesso!'
}
###end autologin###

# Funcao para remover o protetor de tela do Xubuntu 22.02
function removeLockScreen() {
	local AUX
	sudo apt remove xfce4-screensaver -y
	AUX="/etc/apt/preferences.d/noscreensaver.pref"
	if [ -e "$AUX" ]; then
		sudo rm -rf "$AUX"
	fi
	echo "# This is to prevent screensaver from ever being installed" | sudo tee -a "$AUX"
	echo "Package: xfce4-screensaver" | sudo tee -a "$AUX"
	echo "Pin: release a=*" | sudo tee -a "$AUX"
	echo "Pin-Priority: -10" | sudo tee -a "$AUX"
	echo "Removido o protetor de tela com sucesso!"
}
# end removeLockScreen

# Funcao para remover logs de erro do XSession
function disableXsessionLog() {
	local linha='export XSESSION_ERRORS=no'

	# Verificar se a linha jÃ¡ existe no arquivo
	if ! grep -qxF "$linha" ~/.profile; then
		echo "$linha" >>~/.profile
		echo "Linha adicionada com sucesso!"
	else
		echo "A linha que desabilita o log jÃ¡ existe. Nenhuma alteraÃ§Ã£o realizada."
	fi
}

# -- CONTAINER MANAGEMENT
function containerManagement() {
	local OPT
	function startContainers() {
		echo "Iniciando os containers..."
		docker-compose -f $HOME/.vr/docker-compose-sm-sc.yml up -d
		echo "Containers iniciados!"
	}
	function stopContainers() {
		echo "Parando os containers..."
		docker-compose -f $HOME/.vr/docker-compose-sm-sc.yml down
		echo "Containers parados!"
	}
	function clearImagesContainersNetwork() {
		echo "Apagando os containers existentes..."
		docker container prune -f
		echo "Apagando as imagens existentes..."
		docker image prune -af
		echo "Apagado as networks dos containers existentes"
		docker network prune -f
		echo "Processo de remover containers / imagens / networks concluida com sucesso!"
	}
	function listContainers() {
		echo "Imagens instaladas dos containers: "
		docker images
	}

	function statusContainers() {
		echo "Estado dos containers:"
		docker ps -a
	}
	function callMenu() {
		echo -e "\t1) Iniciar os containers"
		echo -e "\t2) Parar os containers"
		echo -e "\t3) Verificar status dos containers"
		echo -e "\t4) Verificar imagens / versoes instaladas dos containers"
		echo -e "\t5) Limpar imagens e containers de versoes instaladas"
		echo -e "\t6) Menu"
	}
	callMenu
	read -r OPT
	while true; do
		case "$OPT" in
		1) startContainers && callMenu && read -r OPT ;;
		2) stopContainers && callMenu && read -r OPT ;;
		3) statusContainers && callMenu && read -r OPT ;;
		4) listContainers && callMenu && read -r OPT ;;
		5) stopContainers && clearImagesContainersNetwork && callMenu && read -r OPT ;;
		6) main ;;
		*) echo 'Opcao invalida, encerrando o script!' && exit 1 ;;
		esac
	done
}
# -- END CONTAINER MANAGEMENT

# -- ScAppsVersion
function scAppsVersion() {
	local SC_APP OPT
	function callMenu() {
		echo -e "\t1) Verificar versao dos aplicativos do SERVICE CONTAINER"
		echo -e "\t2) Verificar versao dos aplicativos do SERVICE MANAGER"
		echo -e "\t3) Menu"
	}
	function callApps() {
		local OPT
		echo "Opcoes:"
		echo -e "\t1) VREncerramento"
		echo -e "\t2) VRConciliadorTEF"
		echo -e "\t3) VRDisplayatendimento"
		echo -e "\t4) VRCurvaAbc"
		echo -e "\t5) VRGerenciadorEcommerce"
		echo -e "\t6) VRExportaPrecosConnect"
		echo -e "\t7) VRScanntech"
		echo -e "\t8) VRHistoricoVenda"
		echo -e "\t9) VRCluster"
		echo -e "\t10) VRMobileServer"
		echo -e "\t11) Menu"
		read -r OPT
		case "$OPT" in
		1) SC_APP='VREncerramento' ;;
		2) SC_APP='VRConciliadorTEF' ;;
		3) SC_APP='VRDisplayAtendimento' ;;
		4) SC_APP='VRCurvaAbc' ;;
		5) SC_APP='VRGerenciadorEcommerce' ;;
		6) SC_APP='VRExportaPrecosConnect' ;;
		7) SC_APP='VRScanntech' ;;
		8) SC_APP='VRHistoricoVenda' ;;
		9) SC_APP='VRCluster' ;;
		10) SC_APP='VRMobileServer' ;;
		11) main ;;
		*) choice ;;
		esac
	}

	function getScAppVersion() {
		echo $SC_APP
		unzip -p "$HOME/.vr/servicecontainer/service/$SC_APP.war" WEB-INF/classes/application.yml | head -n8
	}

	callMenu
	read -r OPT
	while true; do
		case "$OPT" in
		1) callApps && getScAppVersion && callMenu && read -r OPT ;;
		2) echo "Feature nao habilitada" && callMenu && read -r OPT ;;
		3) main ;;
		*) echo 'Opcao invalida, encerrando o script!' && exit 1 ;;
		esac
	done
}
# -- END scAppsVersion

# -- listServiceFiles

function listServiceFiles() {
	local OPT DOT_VR SM_DIR SC_DIR
	DOT_VR="$HOME/.vr"
	SM_DIR="$DOT_VR/servicemanager/service"
	SC_DIR="$DOT_VR/servicecontainer/service"
	echo "Arquivos da pasta .vr:"
	tree -L 1 "$DOT_VR" | grep -v file
	echo "Arquivos do service manager:"
	tree -L 1 "$SM_DIR" | grep -v file
	echo "Arquivos do service container:"
	tree -L 1 "$SC_DIR" | grep -v file
	echo "1) Voltar ao menu"
	read -r OPT
	case "$OPT" in
	1) main ;;
	esac
}

# -- PDV Admin degustacao

function installPdvAdmin() {
	local PDV_ADMIN_DIR OPT
	PDV_ADMIN_DIR="$HOME/.vr/pdvadmin"

	function getPdvAdmin() {
		# Baixando arquivos
		curl "$STORAGE/pdvadmindegust.tar.gz" -o /tmp/pdvadmin.tar.gz
		mkdir -p "$PDV_ADMIN_DIR"
		tar xvzf /tmp/pdvadmin.tar.gz -C "$PDV_ADMIN_DIR"

		# Formatando Docker compose
		sed -i -e "s/ubuntuIp/$IP_UBUNTU/g" "$PDV_ADMIN_DIR/docker-compose-pdv-admin.yml"

		# Ajustando permissoes nos scripts
		chmod -R +x "$PDV_ADMIN_DIR/camera"/*
	}

	function containersMenu() {
		local OPT
		echo -e "Gerenciamento de containers do PDV ADMIN"
		echo -e "\t1) Iniciar os containers do PDV ADMIN"
		echo -e "\t2) Parar os containers do PDV ADMIN"
		echo -e "\t3) Reiniciar os containers do PDV ADMIN"
		echo -e "\t4) Menu"
		read -r OPT
		while true; do
			case "$OPT" in
			1) startContainers && containersMenu && read -r OPT ;;
			2) stopContainers && containersMenu && read -r OPT ;;
			3) restartContainers && containersMenu && read -r OPT ;;
			4) main ;;
			*) echo 'Opcao invalida, encerrando o script!' && exit 1 ;;
			esac
		done
	}

	function startContainers() {
		docker-compose -f "$PDV_ADMIN_DIR/docker-compose-pdv-admin.yml" up -d
	}

	function stopContainers() {
		docker-compose -f "$PDV_ADMIN_DIR/docker-compose-pdv-admin.yml" down
	}

	function restartContainers() {
		docker-compose -f "$PDV_ADMIN_DIR/docker-compose-pdv-admin.yml" restart
	}

	echo -e "PDV ADMIN"
	echo -e "Selecione uma opcao:"
	echo -e "\t1) Instalar PDVAdmin"
	echo -e "\t2) Gerenciar containers do PDV ADMIN"
	echo -e "\t3) Menu"
	read -r OPT
	while true; do
		case "$OPT" in
		1) getIpUbuntu && getPdvAdmin && containersMenu ;;
		2) containersMenu ;;
		3) main ;;
		*) echo 'Opcao invalida, encerrando o script!' && exit 1 ;;
		esac
	done
}

## Docker login

function dockerLogin() {
	local OPT

	function login() {
		echo "c63b2d@@@" | docker login -u vrsuporte --password-stdin
	}

	function removeLogin() {
		rm -rf "$HOME/.docker/config.json"
	}

	echo -e "DOCKER LOGIN"
	echo -e "Selecione uma opcao:"
	echo -e "\t1) Configurar login padrÃ£o vrsuporte"
	echo -e "\t2) Remover atual login configurado"
	echo -e "\t3) Menu"
	read -r OPT
	while true; do
		case "$OPT" in
		1) login && echo "Login configurado com sucesso" && dockerLogin ;;
		2) removeLogin && echo "Login removido com sucesso" && dockerLogin ;;
		3) main ;;
		*) echo 'Opcao invalida, encerrando o script!' && exit 1 ;;
		esac
	done

}

# -- userVerify
function userVerify() {
	local password
	if [[ $EUID -eq 0 ]]; then
		echo 'Este script nao pode ser executado como root.'
		exit 1
	fi
	if ! sudo -v; then
		echo 'Senha incorreta, encerrando o script.'
		exit 1
	fi
	#sudo -v
	#if [ $? -ne 0 ]; then
	#    echo 'Senha incorreta, encerrando o script.'
	#    exit 1
	#fi
	if sudo -lS &>/dev/null <<<"$password" && sudo -n true &>/dev/null; then
		clear
	else
		echo 'O usuario nao estÃ¡ no arquivo sudoers.'
		exit 1
	fi
}
# -- END userVerify

function integrador() {
	local OPT
	local COMPOSE_FILE="docker-compose-integrador.yml"
	function getDb() {
		local FILE=db.tar.gz
		echo "Baixando arquivo de configuraÃ§Ã£o do MongoDB"
		curl "$STORAGE/$FILE" -o "/tmp/$FILE"
		tar xvzf "/tmp/$FILE" -C "$HOME/.vr"
		rm -rf "/tmp/$FILE"
		echo "Arquivo de configuraÃ§Ã£o do MongoDB baixado com sucesso"
	}
	function instalarIntegrador() {
		local AUX
		AUX="$HOME/.vr/$COMPOSE_FILE"
		curl "$STORAGE/docker-compose-yml/$COMPOSE_FILE" -o "$AUX"
		echo "Preencha os dados para configuraÃ§Ã£o do Integrador:"
		getDb
		getIpUbuntu
		getPgInfo
		echo "Alterando arquivo de configuraÃ§Ã£o do Integrador"
		sed -i -e "s/dbIp/$DB_IP/g" -e "s/dbPasswd/$DB_PASSWD/g" -e "s/dbName/$DB_NAME/g" -e "s/dbPort/$DB_PORT/g" -e "s/ubuntuIp/$IP_UBUNTU/g" "$AUX"
	}

	function startIntegrador() {
		docker compose -f "$HOME/.vr/$COMPOSE_FILE" up -d
	}
	function stopIntegrador() {
		docker compose -f "$HOME/.vr/$COMPOSE_FILE" down
	}

	echo -e "INTEGRADOR"
	echo -e "OBS: Para subir os containers do Integrador, o login no docker precisa ser realizado!"
	echo -e "Selecione uma opcao:"
	echo -e "\t1) Instalar Integrador"
	echo -e "\t2) Start compose"
	echo -e "\t3) Stop compose"
	echo -e "\t4) Menu"
	read -r OPT
	while true; do
		case "$OPT" in
		1) instalarIntegrador && echo "Arquivos baixados e configurados com sucesso" && integrador || echo "Erro ao baixar arquivos" ;;
		2) startIntegrador && integrador || echo "Erro ao iniciar containers" ;;
		3) stopIntegrador && integrador || echo "Erro ao parar containers" ;;
		4) main ;;
		*) echo 'Opcao invalida, encerrando o script!' && exit 1 ;;
		esac
	done
}

function main() {
	local opcao
	userVerify
	echo "VERSAO DO SCRIPT: $SCRIPT_VERSION"
	echo "Selecione uma opcao:"
	echo -e "\t1) Criacao de atalhos na area de trabalho"
	echo -e "\t2) Service Manager"
	echo -e "\t3) Instalar ambiente servidor de aplicativos (Firebird + Java + Icones + Samba + SSH)"
	echo -e "\t4) Instalar Docker (necessario reinicializacao da maquina para aplicar permissao ao usuario a utilizar o docker)"
	echo -e "\t5) Instalar SSH"
	echo -e "\t6) Instalar Icones"
	echo -e "\t7) Instalar Firebird"
	echo -e "\t8) Instalar Java"
	echo -e "\t9) Instalar Samba"
	echo -e "\t10) Instalar unrar"
	echo -e "\t11) Limpar e atualizar repositorios"
	echo -e "\t12) Instalar anydesk"
	echo -e "\t13) Auto login para VR Xubuntu - LightDM"
	echo -e "\t14) Remover protetor de tela VR Xubuntu 22.04"
	echo -e "\t15) Desabilitar logs de erro do Xsession"
	echo -e "\t16) Gerenciamento de Containers (iniciar/parar)"
	echo -e "\t17) Verificar versao aplicativos SERVICE CONTAINER"
	echo -e "\t18) Listar arquivos do Service Manager"
	echo -e "\t19) Instalacao PDV ADMIN DEGUSTACAO"
	echo -e "\t20) Docker Login"
	echo -e "\t21) Integrador"
	echo -e "\t22) Sair"
	read -r opcao
	while true; do
		case "$opcao" in
		1) getAppChoice ;;                       # Opcao para criacao de atalhos
		2) getMasterVersion && serviceManager ;; # Service Manager
		3) installi386Architecture && installSamba && installIcons && installOpenJdk && installOpenSsh && installFirebird && sleep 5 && main ;;
		4) installDocker && sleep 5 && main ;;
		5) installOpenSsh && sleep 5 && main ;;
		6) installIcons && sleep 5 && main ;;
		7) installi386Architecture && installFirebird && sleep 5 && main ;;
		8) installi386Architecture && installOpenJdk && sleep 5 && main ;;
		9) installSamba && sleep 5 && main ;;
		10) installUnrar && sleep 5 && main ;;
		11) updRepo && sleep 5 && main ;;
		12) installAnydesk && sleep 5 && main ;;
		13) autoLogin && sleep 5 && main ;;
		14) removeLockScreen && sleep 5 && main ;;
		15) disableXsessionLog && sleep 5 && main ;;
		16) containerManagement && sleep 5 && main ;;
		17) scAppsVersion && sleep 5 && main ;;
		18) listServiceFiles ;;
		19) installPdvAdmin && sleep 5 && main ;;
		20) dockerLogin && sleep 5 && main ;;
		21) integrador && sleep 5 && main ;;
		22) exit 0 ;;
		*) echo 'Opcao invalida! Encerrando script' && exit 1 ;;
		esac
	done
}
main
