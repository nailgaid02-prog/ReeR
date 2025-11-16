#!/bin/bash

###########################################
# ReeR VPN - Удаленная установка
# curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/ReeR/main/install-remote.sh | bash
###########################################

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
  ____           ____   __     ______  _   _
 |  _ \ ___  ___|  _ \  \ \   / /  _ \| \ | |
 | |_) / _ \/ _ \ |_) |  \ \ / /| |_) |  \| |
 |  _ <  __/  __/  _ <    \ V / |  __/| |\  |
 |_| \_\___|\___|_| \_\    \_/  |_|   |_| \_|

EOF
echo -e "${NC}"

echo -e "${GREEN}Установка ReeR VPN...${NC}"
echo ""

# Проверка root
if [[ $EUID -ne 0 ]]; then
   echo "Этот скрипт должен быть запущен от root"
   echo "Используйте: sudo bash"
   exit 1
fi

# Установка git если нет
if ! command -v git &> /dev/null; then
    echo "Установка git..."
    apt-get update -qq
    apt-get install -y -qq git
fi

# Клонирование репозитория
REPO_URL="https://github.com/nailgaid02-prog/ReeR.git"
INSTALL_DIR="/opt/ReeR"

if [ -d "$INSTALL_DIR" ]; then
    echo "ReeR уже установлен в $INSTALL_DIR"
    read -p "Переустановить? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$INSTALL_DIR"
    else
        exit 0
    fi
fi

echo "Клонирование репозитория..."
git clone "$REPO_URL" "$INSTALL_DIR"

# Переход в директорию
cd "$INSTALL_DIR"

# Запуск установки
echo ""
echo "Запуск установки..."
chmod +x setup.sh
./setup.sh

echo ""
echo -e "${GREEN}Установка завершена!${NC}"
echo ""
echo "Директория проекта: $INSTALL_DIR"
echo ""
echo "Полезные команды:"
echo "  cd $INSTALL_DIR"
echo "  docker compose logs -f"
echo "  ./scripts/status.sh"
