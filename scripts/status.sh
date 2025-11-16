#!/bin/bash

###########################################
# Проверка статуса ReeR VPN
###########################################

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}ReeR VPN - Статус системы${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# IP адрес
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || echo "unknown")
echo -e "${BLUE}🌐 IP сервера:${NC} $SERVER_IP"
echo ""

# Статус Docker контейнеров
echo -e "${BLUE}📦 Контейнеры:${NC}"
if docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -q "3x-ui"; then
    docker ps --format "  {{.Names}}: ${GREEN}{{.Status}}${NC}"
    echo ""
else
    echo -e "  ${RED}❌ Контейнеры не запущены${NC}"
    echo ""
fi

# Использование ресурсов
echo -e "${BLUE}💻 Ресурсы:${NC}"
echo "  CPU: $(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')"
echo "  RAM: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
echo "  Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')"
echo ""

# Открытые порты
echo -e "${BLUE}🔓 Открытые порты:${NC}"
if command -v netstat &> /dev/null; then
    netstat -tlnp | grep -E ":(443|2053|54321)" | awk '{print "  " $4}' || echo "  Нет данных"
else
    ss -tlnp | grep -E ":(443|2053|54321)" | awk '{print "  " $4}' || echo "  Нет данных"
fi
echo ""

# Firewall статус
echo -e "${BLUE}🔥 Firewall:${NC}"
if command -v ufw &> /dev/null; then
    UFW_STATUS=$(ufw status | head -1)
    echo "  $UFW_STATUS"
else
    echo "  UFW не установлен"
fi
echo ""

# BBR статус
echo -e "${BLUE}⚡ BBR (ускорение):${NC}"
BBR_STATUS=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
if [ "$BBR_STATUS" = "bbr" ]; then
    echo -e "  ${GREEN}✅ Включен${NC}"
else
    echo -e "  ${YELLOW}⚠️  Выключен (используется $BBR_STATUS)${NC}"
fi
echo ""

# Последние логи
echo -e "${BLUE}📝 Последние события:${NC}"
docker compose logs --tail=5 2>/dev/null || echo "  Нет данных"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}Веб-панель:${NC} http://$SERVER_IP:54321"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
