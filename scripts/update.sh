#!/bin/bash

###########################################
# Обновление ReeR VPN
###########################################

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Обновление ReeR VPN...${NC}"
echo ""

# Создаем backup перед обновлением
echo -e "${YELLOW}Создание backup перед обновлением...${NC}"
./scripts/backup.sh

echo ""
echo -e "${BLUE}Обновление Docker образов...${NC}"

# Останавливаем контейнеры
docker compose down

# Загружаем новые образы
docker compose pull

# Запускаем с новыми образами
docker compose up -d

# Ждем запуска
sleep 5

# Проверяем статус
if docker ps | grep -q "3x-ui"; then
    echo ""
    echo -e "${GREEN}✅ Обновление завершено успешно!${NC}"
    echo ""
    docker compose ps
else
    echo ""
    echo -e "${RED}❌ Ошибка при запуске. Проверьте логи:${NC}"
    echo "  docker compose logs"
    exit 1
fi

# Очистка старых образов
echo ""
echo -e "${BLUE}Очистка старых образов...${NC}"
docker image prune -f

echo ""
echo -e "${GREEN}✅ Система обновлена!${NC}"
