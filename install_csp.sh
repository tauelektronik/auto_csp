#!/bin/bash

# Função para verificar se o script está sendo executado como root
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        echo "Por favor, execute como root"
        exit
    fi
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
    install_csp
}

# Execução do script
main
