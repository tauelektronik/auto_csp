#!/bin/bash

# Baixando o Java JRE 9.0.4 da Oracle (se você preferir, pode mudar para OpenJDK)
JAVA_URL="https://download.oracle.com/otn/java/jdk/9.0.4+11/c2514751926b4512b076cc82f959763f/jre-9.0.4_linux-x64_bin.tar.gz"
JAVA_DIR="/opt/java"

# Baixar JRE
echo "Baixando o Java JRE 9.0.4..."
if wget --no-check-certificate -O /tmp/jre-9.0.4_linux-x64.tar.gz "$JAVA_URL"; then
    echo "Java JRE baixado com sucesso."
else
    echo "Falha ao baixar o Java JRE. Verifique o link."
    exit 1
fi

# Extraindo o Java JRE
echo "Extraindo o Java JRE..."
mkdir -p "$JAVA_DIR"
tar -xzf /tmp/jre-9.0.4_linux-x64.tar.gz -C "$JAVA_DIR" --strip-components=1

# Configurando o Java JRE
echo "Configurando o Java JRE..."
update-alternatives --install /usr/bin/java java "$JAVA_DIR/bin/java" 1
update-alternatives --install /usr/bin/javac javac "$JAVA_DIR/bin/javac" 1
update-alternatives --install /usr/bin/javaws javaws "$JAVA_DIR/bin/javaws" 1

echo "Verificando a versão do Java..."
java -version

# Atualizando os pacotes
echo "Atualizando os pacotes..."
sudo apt-get update

# Instalando as dependências necessárias
echo "Instalando as dependências necessárias..."
sudo apt-get install -y build-essential cmake libssl-dev libpcap-dev git pkg-config libreadline-dev libncurses-dev

# Clonando o repositório CSP
CSP_DIR="/opt/csp"
if [ -d "$CSP_DIR" ]; then
    echo "O diretório $CSP_DIR já existe. Removendo..."
    sudo rm -rf "$CSP_DIR"
fi

echo "Clonando o repositório CSP..."
git clone https://git.streamboard.tv/common/csp.git "$CSP_DIR"

# Iniciando a compilação do CSP
echo "Iniciando a compilação do CSP..."
cd "$CSP_DIR"
mkdir build
cd build
cmake ..
make

if [ $? -eq 0 ]; then
    echo "Compilação do CSP concluída com sucesso."
else
    echo "Erro na compilação do CSP."
    exit 1
fi
