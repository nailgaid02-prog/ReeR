#!/bin/bash
set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════╗"
echo "║   ReeR HTTP Proxy - Quick Deploy              ║"
echo "║   Simple & Fast Proxy for API Requests        ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"

# Проверка Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker не установлен${NC}"
    echo "Установите Docker: curl -fsSL https://get.docker.com | sh"
    exit 1
fi

# Проверка Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose не установлен${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Создание директории для логов...${NC}"
mkdir -p logs

echo -e "${YELLOW}🔧 Остановка старых контейнеров...${NC}"
docker compose down 2>/dev/null || true

echo -e "${YELLOW}🔥 Проверка firewall (порт 3128)...${NC}"
if command -v ufw &> /dev/null; then
    if ufw status | grep -q "Status: active"; then
        if ! ufw status | grep -q "3128"; then
            echo -e "${YELLOW}⚠️  Порт 3128 не открыт в firewall${NC}"
            echo -e "${YELLOW}   Открываю порт 3128...${NC}"
            ufw allow 3128/tcp || echo -e "${YELLOW}   (требуются права root для открытия порта)${NC}"
        else
            echo -e "${GREEN}   ✓ Порт 3128 уже открыт${NC}"
        fi
    fi
fi

echo -e "${YELLOW}🚀 Запуск прокси сервера...${NC}"
docker compose up -d

# Ожидание запуска
echo -e "${YELLOW}⏳ Ожидание запуска (10 сек)...${NC}"
sleep 10

# Проверка статуса
CONTAINER_STATUS=$(docker ps -a --filter name=reer-proxy --format "{{.Status}}")
if echo "$CONTAINER_STATUS" | grep -q "Up"; then
    echo -e "${GREEN}✅ Прокси сервер успешно запущен!${NC}"
    echo ""

    # Получение IP сервера
    SERVER_IP=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')

    echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           ИНФОРМАЦИЯ ДЛЯ ПОДКЛЮЧЕНИЯ          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}🌐 Прокси адрес:${NC}"
    echo -e "   HTTP:  http://${SERVER_IP}:3128"
    echo -e "   HTTPS: http://${SERVER_IP}:3128"
    echo ""
    echo -e "${BLUE}📝 Использование в коде:${NC}"
    echo ""
    echo -e "${YELLOW}Node.js (axios):${NC}"
    echo "const axios = require('axios');"
    echo "const agent = require('https-proxy-agent');"
    echo ""
    echo "const proxy = 'http://${SERVER_IP}:3128';"
    echo "const httpsAgent = new agent(proxy);"
    echo ""
    echo "axios.get('https://api.openai.com/v1/models', {"
    echo "  httpsAgent,"
    echo "  headers: { 'Authorization': 'Bearer YOUR_KEY' }"
    echo "});"
    echo ""
    echo -e "${YELLOW}Python (requests):${NC}"
    echo "import requests"
    echo ""
    echo "proxies = {"
    echo "  'http': 'http://${SERVER_IP}:3128',"
    echo "  'https': 'http://${SERVER_IP}:3128'"
    echo "}"
    echo ""
    echo "response = requests.get('https://api.openai.com/v1/models',"
    echo "  proxies=proxies,"
    echo "  headers={'Authorization': 'Bearer YOUR_KEY'})"
    echo ""
    echo -e "${YELLOW}curl:${NC}"
    echo "curl -x http://${SERVER_IP}:3128 https://api.openai.com/v1/models"
    echo ""
    echo -e "${BLUE}📊 Команды управления:${NC}"
    echo "  docker compose logs -f     # Просмотр логов"
    echo "  docker compose restart     # Перезапуск"
    echo "  docker compose down        # Остановка"
    echo "  docker compose up -d       # Запуск"
    echo ""
    echo -e "${BLUE}🔍 Проверка работы прокси:${NC}"
    echo "  curl -x http://${SERVER_IP}:3128 https://api.openai.com/v1/models"
    echo "  # Должен вернуть ошибку 401 (это нормально - нет API ключа)"
    echo ""
    echo -e "${GREEN}✨ Готово! Прокси сервер работает${NC}"
elif echo "$CONTAINER_STATUS" | grep -q "Restarting"; then
    echo -e "${RED}❌ Контейнер постоянно перезапускается${NC}"
    echo ""
    echo -e "${YELLOW}📋 Последние 30 строк логов:${NC}"
    docker logs --tail=30 reer-proxy
    echo ""
    echo -e "${YELLOW}💡 Возможные причины:${NC}"
    echo "  1. Ошибка в squid.conf - проверьте синтаксис"
    echo "  2. Недостаточно памяти - проверьте 'docker stats'"
    echo "  3. Конфликт портов - проверьте 'netstat -tulpn | grep 3128'"
    echo ""
    echo -e "${BLUE}Команды для диагностики:${NC}"
    echo "  docker logs reer-proxy           # Полные логи"
    echo "  docker inspect reer-proxy        # Детали контейнера"
    echo "  docker compose down && docker compose up -d  # Перезапуск"
    exit 1
else
    echo -e "${RED}❌ Контейнер не запущен${NC}"
    echo "Статус: $CONTAINER_STATUS"
    echo ""
    echo "Проверьте логи: docker compose logs"
    exit 1
fi
