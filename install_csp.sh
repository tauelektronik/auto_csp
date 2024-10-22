#!/bin/bash

# Função para verificar se o script está sendo executado como root
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        echo "Por favor, execute como root"
        exit
    fi
}

# Função para instalar o Java JRE 9.0.4
install_java() {
    echo "Baixando o Java JRE 9.0.4 da Oracle..."
    wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    "https://download.oracle.com/otn/java/jdk/9.0.4+11/c2514751926b4512b076cc82f959763f/jre-9.0.4_linux-x64_bin.tar.gz" -O /tmp/jre-9.0.4_linux-x64.tar.gz

    if [ $? -ne 0 ]; then
        echo "Erro ao baixar o Java JRE. Verifique o link e tente novamente."
        exit 1
    fi

    echo "Extraindo o Java JRE..."
    mkdir -p /opt/java
    tar -xzf /tmp/jre-9.0.4_linux-x64.tar.gz -C /opt/java/

    echo "Configurando o Java JRE..."
    update-alternatives --install /usr/bin/java java /opt/java/jre-9.0.4/bin/java 1
    update-alternatives --set java /opt/java/jre-9.0.4/bin/java

    echo "Verificando a versão do Java..."
    java -version

    echo "Java JRE 9.0.4 instalado com sucesso."
}

# Função para instalar as dependências e compilar o CSP
install_csp() {
    echo "Atualizando os pacotes..."
    apt update && apt upgrade -y

    echo "Instalando as dependências necessárias..."
    apt install -y build-essential cmake libssl-dev libpcap-dev git pkg-config libreadline-dev libncurses5-dev

    echo "Clonando o repositório CSP..."
    git clone https://git.streamboard.tv/common/csp.git /opt/csp
    cd /opt/csp

    echo "Iniciando a compilação do CSP..."
    mkdir build && cd build
    cmake ..
    make -j$(nproc)

    if [ $? -ne 0 ]; then
        echo "Erro na compilação do CSP."
        exit 1
    fi

    echo "Movendo o binário compilado para /usr/local/bin/..."
    cp /opt/csp/build/csp /usr/local/bin/csp

    echo "Ajustando permissões..."
    chmod +x /usr/local/bin/csp

    echo "Instalação do CSP finalizada com sucesso."
}

# Função principal para execução
main() {
    check_root
    install_java
    install_csp
}

# Execução do script
main
