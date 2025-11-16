#!/bin/bash

###########################################
# Включение BBR для ускорения TCP
###########################################

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Включение BBR...${NC}"

# Проверка текущего статуса
current_qdisc=$(sysctl net.core.default_qdisc | awk '{print $3}')
current_congestion=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')

if [ "$current_qdisc" = "fq" ] && [ "$current_congestion" = "bbr" ]; then
    echo -e "${GREEN}✅ BBR уже включен${NC}"
    exit 0
fi

# Включаем BBR
cat >> /etc/sysctl.conf <<EOF

# BBR TCP Congestion Control
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_fastopen=3
EOF

# Применяем изменения
sysctl -p

# Проверяем
if lsmod | grep -q bbr; then
    echo -e "${GREEN}✅ BBR успешно включен!${NC}"
else
    echo -e "${GREEN}✅ BBR включен (перезагрузите сервер для применения)${NC}"
fi

echo ""
echo "Статус:"
echo "  Qdisc: $(sysctl net.core.default_qdisc | awk '{print $3}')"
echo "  Congestion Control: $(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')"
