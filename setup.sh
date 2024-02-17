#!/bin/bash

# Executar o script na pasta em que se encontra e no login de root

# Debian nao tem sudo ... caso esteja se tentando fazer a instalacao no Ubuntu e derivados, comentar a linha abaixo
alias sudo="";

install_dir="`pwd`"

# O arquivo abaixo deverá conter a lista de pacotes do Debian a instalar. Devera estar na mesma pasta do setup.sh
packages="packages" 
[[ ! -d DEBS ]] && mkdir DEBS

# Na primeira vez que executar o script, faz um full-upgrade e reboota a maquina
if [[ ! -f /root/.full-upgrade.stamp  ]]; then 

    # distro update & upgrade
    echo "Fazendo um upgrade ... "

    echo "Fazendo upgrade ... "
    sudo apt update
    sudo apt-get -y full-upgrade

    sudo touch /root/.full-upgrade.stamp

    sudo reboot

fi

sudo apt-get -y install wget gpg git

### MySQL & MySQL Workbench ###
cd DEBS

echo "\
deb http://ftp.br.debian.org/debian bookworm          main contrib non-free non-free-firmware 
deb http://ftp.br.debian.org/debian bookworm-updates  main contrib non-free non-free-firmware 
deb http://security.debian.org      bookworm-security  main contrib non-free

deb http://ftp.br.debian.org/debian bookworm-backports  main contrib non-free
deb http://ftp.br.debian.org/debian sid  main contrib non-free non-free-firmware" | sudo tee /etc/apt/sources.list

apt update

cd ..
### ChonOS ###

echo "deb [trusted=yes] http://packages.chon.group/ chonos main" | sudo tee /etc/apt/sources.list.d/chonos.list
sudo apt-get update

### Visual Studio Code ###

wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

sudo apt update

### WeBOTS ###

echo "Configuring new repositories in the package manager"
sudo mkdir -p /etc/apt/keyrings
cd /etc/apt/keyrings
sudo wget -q https://cyberbotics.com/Cyberbotics.asc
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/Cyberbotics.asc] https://cyberbotics.com/debian binary-amd64/" | sudo tee /etc/apt/sources.list.d/Cyberbotics.list

sudo apt update

### Instalação dos pacotes via repositorios. ###

cd "${install_dir}"
echo "Starting packages installation on ${install_dir} ..."

if [[ -f "$packages" ]]; then
    ok_pkgs=`mktemp`
    # Pacotes inexistentes serão salvos no arquivo ${error_pkgs}
    error_pkgs=missingpackages-`date +"%Y-%m-%d_%H-%M"`.txt 
    
    for pkg in $(cat "$packages"); do
        echo -n "Checando $pkg ...";
        apt-get install -q -s -y $pkg > /dev/null
        if [[ $? -eq 0 ]]; then 
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

fi

### Google Chrome ###

cd DEBS
GOOGLE_CHROME_DEB=google-chrome-stable_current_amd64.deb

if [[ ! -f ${GOOGLE_CHROME_DEB} ]]; then 
    wget https://dl.google.com/linux/direct/${GOOGLE_CHROME_DEB}
    sudo apt install -y ./google-chrome-stable_current_amd64.deb
fi

cd ..

### PyCharm ###
PYCHARM_VERSION="pycharm-community-2023.3.3"
PYCHARM_TGZ="${PYCHARM_VERSION}.tar.gz"

cd DEBS 

if [[ ! -f "${PYCHARM_TGZ}" ]]; then 

    wget "https://download.jetbrains.com/python/${PYCHARM_TGZ}"

fi

tar xaf "${PYCHARM_TGZ}"

mv ${PYCHARM_VERSION} /home/aluno/.local/.

if [[ ! -d /home/aluno/.local ]]; then 
    
    mkdir /home/aluno/.local
    chown aluno:aluno /home/aluno/.local

fi

echo "export PATH=\"/home/aluno/.local/${PYCHARM_VERSION}/bin:\${PATH}\"" | sudo tee -a /home/aluno/.profile

cd ..

### Customizacao: autologin ###
cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf-`date +"%Y-%m-%d_%H-%M"`.backup

sed 's/#autologin-user=/autologin-user=aluno/g' /etc/lightdm/lightdm.conf > /tmp/lightdm.conf
mv /tmp/lightdm.conf /etc/lightdm/lightdm.conf

sed 's/#autologin-user-timeout=0/autologin-user-timeout=0/g' /etc/lightdm/lightdm.conf > /tmp/lightdm.conf
mv /tmp/lightdm.conf /etc/lightdm/lightdm.conf

### Customizacao: Senha de root do MariaDB / MySQL ###

root_passwd=root # mudar a senha do root aqui se quiser

echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${root_passwd}'" | sudo mysql

### Customizacao: Atalhos para aplicativos ###

sudo cp /usr/share/applications/lxterminal.desktop /home/aluno/Desktop/.
sudo cp /usr/share/applications/firefox-esr.desktop /home/aluno/Desktop/.

# Customizacao: alunos nao podem alterar .profile e .bashrc

sudo chown root:root /home/aluno/.profile
sudo chown root:root /home/aluno/.bashrc

sudo chmod a=r /home/aluno/.profile
sudo chmod a=r /home/aluno/.bashrc

# Customizacao: todos podem escrever e alterar a pasta do servidor web

sudo chmod a=rw /var/www/html

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
