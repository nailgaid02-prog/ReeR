#!/bin/bash

###########################################
# Диагностика проблем ReeR VPN
###########################################

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}ReeR VPN - Диагностика${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ISSUES_FOUND=0

# 1. Проверка Docker
echo -e "${BLUE}[1/8] Проверка Docker...${NC}"
if command -v docker &> /dev/null; then
    echo -e "  ${GREEN}✅ Docker установлен${NC}"
    docker --version
else
    echo -e "  ${RED}❌ Docker не установлен${NC}"
    echo "  Решение: установите Docker (см. README.md)"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo ""

# 2. Проверка запущенных контейнеров
echo -e "${BLUE}[2/8] Проверка контейнеров...${NC}"
if docker ps | grep -q "3x-ui"; then
    echo -e "  ${GREEN}✅ Контейнеры запущены${NC}"
    docker ps --format "  {{.Names}}: {{.Status}}"
else
    echo -e "  ${RED}❌ Контейнеры не запущены${NC}"
    echo "  Решение: docker compose up -d"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo ""

# 3. Проверка портов
echo -e "${BLUE}[3/8] Проверка портов...${NC}"
REQUIRED_PORTS=(443 2053 54321)
for port in "${REQUIRED_PORTS[@]}"; do
    if ss -tlnp | grep -q ":$port "; then
        echo -e "  ${GREEN}✅ Порт $port открыт${NC}"
    else
        echo -e "  ${YELLOW}⚠️  Порт $port не слушается${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
done
echo ""

# 4. Проверка Firewall
echo -e "${BLUE}[4/8] Проверка Firewall...${NC}"
if command -v ufw &> /dev/null; then
    UFW_STATUS=$(ufw status | grep -i "status:" | awk '{print $2}')
    if [ "$UFW_STATUS" = "active" ]; then
        echo -e "  ${GREEN}✅ UFW активен${NC}"

        # Проверяем правила
        for port in "${REQUIRED_PORTS[@]}"; do
            if ufw status | grep -q "$port"; then
                echo -e "  ${GREEN}✅ Порт $port разрешен${NC}"
            else
                echo -e "  ${RED}❌ Порт $port не разрешен в UFW${NC}"
                echo "  Решение: ufw allow $port/tcp"
                ISSUES_FOUND=$((ISSUES_FOUND + 1))
            fi
        done
    else
        echo -e "  ${YELLOW}⚠️  UFW неактивен${NC}"
    fi
else
    echo -e "  ${YELLOW}⚠️  UFW не установлен${NC}"
fi
echo ""

# 5. Проверка BBR
echo -e "${BLUE}[5/8] Проверка BBR...${NC}"
BBR_STATUS=$(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | awk '{print $3}')
if [ "$BBR_STATUS" = "bbr" ]; then
    echo -e "  ${GREEN}✅ BBR включен${NC}"
else
    echo -e "  ${YELLOW}⚠️  BBR выключен (используется $BBR_STATUS)${NC}"
    echo "  Рекомендация: ./scripts/enable-bbr.sh"
fi
echo ""

# 6. Проверка дискового пространства
echo -e "${BLUE}[6/8] Проверка дискового пространства...${NC}"
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    echo -e "  ${GREEN}✅ Достаточно места ($DISK_USAGE% использовано)${NC}"
else
    echo -e "  ${RED}❌ Мало места ($DISK_USAGE% использовано)${NC}"
    echo "  Решение: очистите диск"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi
echo ""

# 7. Проверка памяти
echo -e "${BLUE}[7/8] Проверка памяти...${NC}"
MEM_AVAILABLE=$(free -m | awk 'NR==2{print $7}')
if [ "$MEM_AVAILABLE" -gt 100 ]; then
    echo -e "  ${GREEN}✅ Достаточно памяти (${MEM_AVAILABLE}MB доступно)${NC}"
else
    echo -e "  ${YELLOW}⚠️  Мало памяти (${MEM_AVAILABLE}MB доступно)${NC}"
    echo "  Рекомендация: перезагрузите сервер или увеличьте RAM"
fi
echo ""

# 8. Проверка логов на ошибки
echo -e "${BLUE}[8/8] Проверка логов на ошибки...${NC}"
if docker compose logs --tail=50 2>/dev/null | grep -i "error\|failed\|fatal" > /dev/null; then
    echo -e "  ${YELLOW}⚠️  Обнаружены ошибки в логах${NC}"
    echo "  Последние ошибки:"
    docker compose logs --tail=50 2>/dev/null | grep -i "error\|failed\|fatal" | tail -5 | sed 's/^/  /'
    echo ""
    echo "  Полные логи: docker compose logs"
else
    echo -e "  ${GREEN}✅ Ошибок в логах не обнаружено${NC}"
fi
echo ""

# Итог
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ Критических проблем не обнаружено!${NC}"
else
    echo -e "${YELLOW}⚠️  Обнаружено проблем: $ISSUES_FOUND${NC}"
    echo ""
    echo "Рекомендуемые действия:"
    echo "  1. Исправьте проблемы выше"
    echo "  2. Перезапустите: docker compose restart"
    echo "  3. Проверьте логи: docker compose logs -f"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
