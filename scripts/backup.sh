#!/bin/bash

###########################################
# Backup конфигурации ReeR VPN
###########################################

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="reer_backup_${TIMESTAMP}.tar.gz"

echo -e "${BLUE}Создание backup...${NC}"

# Создаем директорию для backup
mkdir -p "$BACKUP_DIR"

# Останавливаем контейнеры для консистентности
echo "Остановка контейнеров..."
docker compose stop

# Создаем архив
echo "Создание архива..."
tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
    data/ \
    docker-compose.yml \
    install-info.txt 2>/dev/null || true

# Запускаем контейнеры обратно
echo "Запуск контейнеров..."
docker compose start

# Размер backup
BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)

echo ""
echo -e "${GREEN}✅ Backup создан успешно!${NC}"
echo ""
echo "Файл: $BACKUP_DIR/$BACKUP_FILE"
echo "Размер: $BACKUP_SIZE"
echo ""
echo "Восстановление:"
echo "  tar -xzf $BACKUP_DIR/$BACKUP_FILE"
echo "  docker compose up -d"
