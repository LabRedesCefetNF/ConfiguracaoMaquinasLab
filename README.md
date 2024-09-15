# ConfiguracaoMaquinasLab

Script para configurar as máquinas do LabReDes. 

O script atual é para o Debian 12 LXDE.

## Utilização

### Coloque a lista de pacotes Debian no arquivo packages

### Crie uma pasta chamada DEBS e coloque nela os pacotes .deb baixados da Internet, caso deseje:

### Pelo terminal, carregue os procedimentos do script:

```
. setup.sh
```

### Serão carregados 3 procedimentos: 
   
1) labredes_install_apps_Internet: Instala os pacotes listados no packages usando repositórios da internet 

2) labredes_install_apps_privrepo: Instala a partir de repositório privado

3) labredes_customizacao: aplica diversas customizações das máquinas do lab.

Escolha um dos métodos de instalação de pacotes 1 ou 2 e, em seguida, execute o script de customizacao 3:

Exemplo: Para instalar pacotes da Internet e depois customizar:

```
labredes_install_apps_Internet && labredes_customizacao
```


