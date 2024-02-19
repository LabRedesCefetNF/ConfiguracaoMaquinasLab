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

    clear

    echo "O computador será reiniciado em 10s"
    echo 
    echo "Certifique-se de fazer um login no usuário 'aluno' a fim de serem criadas as pastas e arquivos do usuário"
    echo "O processo de configuração irá alterar tais pastas e arquivos"
    sleep 10

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

    echo "error: file $packages not found - aborting"

    exit 1

fi

### Google Chrome ###

cd DEBS
GOOGLE_CHROME_DEB=google-chrome-stable_current_amd64.deb

if [[ ! -f ${GOOGLE_CHROME_DEB} ]]; then 
    wget https://dl.google.com/linux/direct/${GOOGLE_CHROME_DEB}
    sudo apt install -y ./google-chrome-stable_current_amd64.deb
    sudo apt install -y -f
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

chown -R aluno:aluno ${PYCHARM_VERSION}
chmod a+x ${PYCHARM_VERSION}/pycharm.sh

mv ${PYCHARM_VERSION} /home/aluno/.local/.

if [[ ! -d /home/aluno/.local ]]; then 
    
    mkdir /home/aluno/.local
    sudo chown aluno:aluno /home/aluno/.local
    
fi

echo "export PATH=\"/home/aluno/.local/${PYCHARM_VERSION}/bin:\${PATH}\"" | sudo tee -a /home/aluno/.profile

cd /home/aluno/Desktop

ln -s /home/aluno/.local/${PYCHARM_VERSION}/bin/pycharm.sh

cd ..

### Packet Tracer ###

# Tive que baixar o pacote da NetAcad e depois por no meu OneDrive ... 

cd "${install_dir}"/DEBS

wget http://bsi.cefet-rj.br/repo/~cisco/packet_tracer.deb

sudo dpkg -i packet_tracer.deb

sudo apt install -f -y

### Wireshark ###

# No Debian 12 sid ele está com a instalação quebrada, portanto estamos fazendo compilacao na unha
# Se isso mudar, colocar o pacote 'wireshark' no packages e comentar/retirar as linhas abaixo

sudo apt install -y libpcap-dev libglib2.0-dev flex asciidoctor qt6-base-dev cmake libgcrypt20-dev libc-ares-dev qt6-tools-dev libqt6core5compat6-dev libspeexdsp-dev

cd "${install_dir}"

wget https://2.na.dl.wireshark.org/src/wireshark-4.2.3.tar.xz

tar xaf wireshark-4.2.3.tar.xz

cd wireshark-4.2.3
wireshark_src_dir="`pwd`"

mkdir build
cd build
cmake "${wireshark_src_dir}"
make all
make install

### Customizacao: colocando 'aluno' no grupo 'dialup' para usar o Arduino ###
sudo usermod -aG dialout aluno

### Customizacao: autologin ###
cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf-`date +"%Y-%m-%d_%H-%M"`.backup

sed 's/#autologin-user=/autologin-user=aluno/g' /etc/lightdm/lightdm.conf | sudo tee /tmp/lightdm.conf
sudo mv /tmp/lightdm.conf /etc/lightdm/lightdm.conf

sed 's/#autologin-user-timeout=0/autologin-user-timeout=0/g' /etc/lightdm/lightdm.conf | sudo tee /tmp/lightdm.conf
sudo mv /tmp/lightdm.conf /etc/lightdm/lightdm.conf

### Customizacao: Senha de root do MariaDB / MySQL ###

root_passwd=root # mudar a senha do root aqui se quiser

echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${root_passwd}'" | sudo mysql

### Customizacao: Atalhos para aplicativos na Área de Trabalho e não podem apagar ou salvar coisas nela ###

if [[ ! -d /home/aluno/Desktop ]]; then 

    sudo mkdir /home/aluno/Desktop
    sudo chown aluno:aluno /home/aluno/Desktop

fi

sudo cp /usr/share/applications/lxterminal.desktop /home/aluno/Desktop/.
sudo cp /usr/share/applications/firefox-esr.desktop /home/aluno/Desktop/.
sudo cp /usr/share/applications/code.desktop /home/aluno/Desktop/.
sudo cp /usr/share/applications/codeblocks.desktop /home/aluno/Desktop/.
sudo cp /usr/share/applications/mysql-workbench.desktop /home/aluno/Desktop/.
sudo cp /usr/share/applications/google-chrome.desktop /home/aluno/Desktop/.
sudo cp /usr/share/applications/arduino.desktop /home/aluno/Desktop/.
sudo cp /usr/share/applications/group.chon.ide.desktop /home/aluno/Desktop/.
sudo cp /usr/share/applications/group.chon.simulide.desktop /home/aluno/Desktop/.
sudo cp /usr/share/applications/webots.desktop /home/aluno/Desktop/.
sudo cp /usr/share/applications/logisim.desktop /home/aluno/Desktop/.
sudo cp /usr/share/applications/cisco-pt821.desktop /home/aluno/Desktop/.

# compilados e dpkgs ficam no /usr/local/share/applications
sudo cp /usr/local/share/applications/org.wireshark.Wireshark.desktop /home/aluno/Desktop/.

cd /home/aluno/Desktop/

ls *.desktop | xargs -I{} sudo chown root:root '{}'
ls *.desktop | xargs -I{} sudo chmod 555 '{}'

# copiando tudo pro root tambem para facilitar nossa vida
sudo cp /home/aluno/Desktop/* /root/Desktop/.

# Customizacao: alunos nao podem alterar a pasta Desktop

sudo chown root:root /home/aluno/Desktop
sudo chmod a=rx /home/aluno/Desktop

# Customizacao: alunos nao podem alterar .profile e .bashrc

sudo chown root:root /home/aluno/.profile
sudo chown root:root /home/aluno/.bashrc

sudo chmod a=r /home/aluno/.profile
sudo chmod a=r /home/aluno/.bashrc

# Customizacao: todos podem escrever e alterar a pasta do servidor web

sudo chown root:root /var/www/html
sudo chmod a=rwx /var/www/html


# Customizacao: alunos nao podem mudar o papel de parede

cd /home/aluno/.config/
sudo chown -R root:root pcmanfm
sudo chmod -R a=rx pcmanfm

cd pcmanfm/LXDE

wget https://images3.alphacoders.com/221/221297.png \
    -O labredes_default_wallpaper.png

wallpaper_path="`pwd`/labredes_default_wallpaper.png"

cp desktop-items-0.conf desktop-items-0.conf-`date +"%Y-%m-%d_%H-%M"`.backup

sed "s|^wallpaper=.*|wallpaper=${wallpaper_path}|g" desktop-items-0.conf > novo_desktop.conf

mv novo_desktop.conf desktop-items-0.conf

sudo chown root:root ./*
sudo chmod a=r ./*

# Customizacao: adicionando algumas aplicaoes padrao ao sistema

echo "application/pdf=org.kde.okular.desktop" | sudo tee -a /usr/share/applications/defaults.list

# Customizacao: lipando os cookies do Chrome e Firefox ao dar login 

cd /home/aluno/.mozilla/firefox

echo "\
for site in \$(find "\$HOME/.mozilla/firefox" -maxdepth 1 -type d); do \
    cd "\$site"; \
    rm -f cookies.sqlite ; \
done" | sudo tee -a /home/aluno/.profile

# Finalizando instalacao: limpando pacotes desnecessarios

sudo apt -y autoremove

reboot

exit 0
