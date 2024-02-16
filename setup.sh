#!/bin/bash

# Executar o script na pasta em que se encontra

alias sudo=""

packages="packages" # esse arquivo deverá conter a lista de pacotes do Debian a baixar
[[ ! -d DEBS ]] && mkdir DEBS

# distro update & upgrade
echo "Atualizando a lista de pacotes ... "

echo "Fazendo upgrade ... "
sudo apt update
sudo apt-get -y upgrade

sudo apt-get -y install wget gpg git

### MySQL & MySQL Workbench ###
cd DEBS

echo "\
deb http://ftp.br.debian.org/debian bullseye          main contrib non-free non-free-firmware 
deb http://ftp.br.debian.org/debian bullseye-updates  main contrib non-free non-free-firmware 
deb http://security.debian.org      bullseye-security  main contrib non-free non-free-firmware

deb http://ftp.br.debian.org/debian bullseye-backports  main contrib non-free non-free-firmware
deb http://ftp.br.debian.org/debian sid  main contrib non-free non-free-firmware" | sudo tee /etc/apt/sources.list

apt update

cd ..
### ChonOS ###

echo "deb [trusted=yes] http://packages.chon.group/ chonos main" | sudo tee /etc/apt/sources.list.d/chonos.list
sudo apt-get update

### Visual Studio Code ###
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

sudo apt update

# Instalação dos pacotes via repositorios. 
# Pacotes inexistentes serão salvos no arquivo ${error_pkgs}
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
    exit 1

fi

### Google Chrome ###

cd DEBS
GOOGLE_CHROME_DEB=google-chrome-stable_current_amd64.deb

if [[ ! -f ${GOOGLE_CHROME_DEB} ]]; then 
    wget https://dl.google.com/linux/direct/${GOOGLE_CHROME_DEB}
    sudo apt install ./google-chrome-stable_current_amd64.deb
fi

cd ..

clear
echo "Configuring new repositories in the package manager"
sudo mkdir -p /etc/apt/keyrings
cd /etc/apt/keyrings
sudo wget -q https://cyberbotics.com/Cyberbotics.asc
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/Cyberbotics.asc] https://cyberbotics.com/debian binary-amd64/" | sudo tee /etc/apt/sources.list.d/Cyberbotics.list

sudo apt update

echo "Installing the JaCaMo"
sudo apt install jacamo-cli -y

echo "Installing the Jason CLI"
sudo apt install jason-cli -y

echo "Installing the Simulator"
sudo apt install webots -y


# Configuracao: autologin
cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf-`date +"%Y-%m-%d_%H-%M"`.backup

sed 's/#autologin-user=/autologin-user=aluno/g' /etc/lightdm/lightdm.conf > /tmp/lightdm.conf
mv /tmp/lightdm.conf /etc/lightdm/lightdm.conf

sed 's/#autologin-user-timeout=0/autologin-user-timeout=0/g' /etc/lightdm/lightdm.conf > /tmp/lightdm.conf
mv /tmp/lightdm.conf /etc/lightdm/lightdm.conf


#### Configuração do MySQL ####

#root_passwd=root # mudar a senha do root aqui se quiser

# Activating root password
#echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${root_passwd}'" | sudo mysql




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
