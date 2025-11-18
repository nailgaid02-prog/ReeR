#!/bin/bash

###########################################
# ReeR VPN - Быстрый деплой с GitHub
# Используйте этот скрипт для деплоя на чистый сервер
###########################################

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
  ____            ____    __     ______  _   _
 |  _ \ ___  ___|  _ \   \ \   / /  _ \| \ | |
 | |_) / _ \/ _ \ |_) |___\ \ / /| |_) |  \| |
 |  _ <  __/  __/  _ <_____\ V / |  __/| |\  |
 |_| \_\___|\___|_| \_\     \_/  |_|   |_| \_|

  Быстрый деплой VPN сервера
EOF
echo -e "${NC}"

# Получаем имя пользователя для GitHub URL
GITHUB_USER=${GITHUB_USER:-"nailgaid02-prog"}
GITHUB_REPO=${GITHUB_REPO:-"ReeR"}
GITHUB_BRANCH=${GITHUB_BRANCH:-"main"}

echo -e "${BLUE}Конфигурация:${NC}"
echo "  GitHub: https://github.com/$GITHUB_USER/$GITHUB_REPO"
echo "  Ветка: $GITHUB_BRANCH"
echo ""

# Проверка root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ОШИБКА]${NC} Этот скрипт должен быть запущен от root"
   echo "Используйте: curl -sSL https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/$GITHUB_BRANCH/quick-deploy.sh | sudo bash"
   exit 1
fi

echo -e "${GREEN}[1/5]${NC} Обновление системы..."
apt-get update -qq > /dev/null 2>&1

echo -e "${GREEN}[2/5]${NC} Установка базовых пакетов..."
apt-get install -y -qq git curl wget > /dev/null 2>&1

echo -e "${GREEN}[3/5]${NC} Клонирование репозитория..."
INSTALL_DIR="/opt/ReeR"

if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Каталог $INSTALL_DIR уже существует${NC}"
    read -p "Удалить и установить заново? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$INSTALL_DIR"
    else
        echo "Отменено"
        exit 0
    fi
fi

git clone -q -b "$GITHUB_BRANCH" "https://github.com/$GITHUB_USER/$GITHUB_REPO.git" "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo -e "${GREEN}[4/5]${NC} Настройка прав доступа..."
chmod +x setup.sh
chmod +x scripts/*.sh 2>/dev/null || true

echo -e "${GREEN}[5/5]${NC} Запуск установки..."
echo ""
./setup.sh

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Быстрый деплой завершен!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📁 Проект установлен в:${NC} $INSTALL_DIR"
echo -e "${BLUE}📝 Логи установки:${NC} cat $INSTALL_DIR/install-info.txt"
echo ""
echo -e "${BLUE}🔧 Полезные команды:${NC}"
echo "  cd $INSTALL_DIR              # Перейти в каталог проекта"
echo "  make help                     # Показать все команды"
echo "  make status                   # Статус сервисов"
echo "  make logs                     # Просмотр логов"
echo ""
