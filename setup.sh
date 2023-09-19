#!/bin/bash

# Executar o script na pasta em que se encontra

packages="packages" # esse arquivo deverá conter a lista de pacotes do Debian a baixar
[[ ! -d DEBS ]] && mkdir DEBS

# distro update & upgrade
echo "Atualizando a lista de pacotes ... "

echo "deb [trusted=yes] http://packages.chon.group/ chonos main" | sudo tee /etc/apt/sources.list.d/chonos.list
sudo apt-get update

echo "Fazendo upgrade ... "
sudo apt-get -y upgrade

# Instalação dos pacotes. Pacotes inexistentes serão salvos no arquivo ${error_pkgs}
if [[ -f "$packages" ]]; then
    ok_pkgs=`mktemp`
    error_pkgs=missingpackages-`date +"%Y-%m-%d_%H-%M"`.txt
    
    for pkg in $(cat "$packages"); do
        echo -n "Checando $pkg ...";
        apt-get install -q -s -y $pkg > /dev/null
        if [ $? -eq 0 ]; then 
            echo "ok";
            echo "$pkg" >> $ok_pkgs ;

        else 
            echo "ERROR";
            echo "$pkg" >> $error_pkgs ;
        fi
    done

    sudo apt-get install -y `cat $ok_pkgs`

else 

    echo "error: file $packages not found"
    return 1

fi

cd DEBS

### Google Chrome ###
GOOGLE_CHROME_DEB=google-chrome-stable_current_amd64.deb

if [[ ! -f ${GOOGLE_CHROME_DEB} ]]; then 
    wget https://dl.google.com/linux/direct/${GOOGLE_CHROME_DEB}
fi

### MySQL Workbench ###
MYSQL_WORKBENCH_DEB=mysql-workbench-community_8.0.29-1ubuntu20.04_amd64.deb

if [[ ! -f ${MYSQL_WORKBENCH_DEB} ]]; then
	wget https://downloads.mysql.com/archives/get/p/8/file/${MYSQL_WORKBENCH_DEB}
fi

# Instalando todos os debs na pasta
for deb in $(ls *.deb); do 

	sudo dpkg -i ${deb}
	sudo apt -y install -f
	
done

##### Visual Studio Code ####
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"

sudo apt update
sudo apt install code

#### Configuração do MySQL ####

root_passwd=root # mudar a senha do root aqui se quiser

# Activating root password
echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${root_passwd}'" | sudo mysql





# Corrigindo dependências, se houver
# sudo apt install -f

# Criando grupo 'dev' para desenvolvimento de projetos
# sudo addgroup dev

# Adicionando permissões de escrita e leitura para membros do grupo 'dev' na pasta 'www'
# sudo chown root:dev -R /var/www

# sudo chmod g+rwx -R /var/www

# Usuário 'dev' no grupo 'dev', senha "???"
# sudo adduser projetos -G dev 

# Criando um usuário 'dev', senha '12345678', com permissão total no MySQL 


# IDE PyCharm
# sudo snap install pycharm-community --classic

# if [[ ! -f pycharm-community-2022.1.tar.gz ]]; then
#     wget https://download-cdn.jetbrains.com/python/pycharm-community-2022.1.tar.gz
# fi

# tar xaf pycharm-community-2022.1.tar.gz

# if [[ $? -ne 0 ]]; then
#     error_string="`date`: Erro instalando PyCharm!"
#     echo "$error_string" >> error.log
# fi

# Corrigindo pacotes inexistentes, se houver
sudo apt -f install

# Setup do ambiente dos projetos
sudo mkdir /projetos
