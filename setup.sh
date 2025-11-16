#!/bin/bash

###########################################
# ReeR VPN - Автоматическая установка
# Установка Xray + 3x-ui панели
###########################################

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция вывода
print_msg() {
    echo -e "${GREEN}[ReeR]${NC} $1"
}

print_error() {
    echo -e "${RED}[ОШИБКА]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[ВНИМАНИЕ]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Проверка что скрипт запущен от root
if [[ $EUID -ne 0 ]]; then
   print_error "Этот скрипт должен быть запущен от root"
   echo "Используйте: sudo ./setup.sh"
   exit 1
fi

print_msg "Начинаем установку ReeR VPN..."
echo ""

# Получение IP адреса сервера
SERVER_IP=$(curl -s ifconfig.me || curl -s icanhazip.com || echo "unknown")
print_info "IP адрес сервера: $SERVER_IP"
echo ""

# 1. Обновление системы
print_msg "Шаг 1/7: Обновление системы..."
apt-get update -qq
apt-get upgrade -y -qq

# 2. Установка необходимых пакетов
print_msg "Шаг 2/7: Установка необходимых пакетов..."
apt-get install -y -qq \
    curl \
    wget \
    git \
    ufw \
    ca-certificates \
    gnupg \
    lsb-release \
    qrencode

# 3. Установка Docker
print_msg "Шаг 3/7: Установка Docker..."
if ! command -v docker &> /dev/null; then
    # Добавляем официальный GPG ключ Docker
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Добавляем репозиторий Docker
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Устанавливаем Docker
    apt-get update -qq
    apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Запускаем Docker
    systemctl enable docker
    systemctl start docker

    print_info "Docker установлен успешно"
else
    print_info "Docker уже установлен"
fi

# 4. Настройка Firewall
print_msg "Шаг 4/7: Настройка firewall..."
ufw --force enable

# Разрешаем SSH
ufw allow 22/tcp comment 'SSH'

# Разрешаем порты для VPN
ufw allow 443/tcp comment 'VLESS Reality'
ufw allow 443/udp comment 'VLESS Reality UDP'
ufw allow 2053/tcp comment 'VMess WebSocket'
ufw allow 54321/tcp comment '3x-ui Web Panel'

# Применяем правила
ufw reload

print_info "Firewall настроен"

# 5. Включение BBR (ускорение TCP)
print_msg "Шаг 5/7: Включение BBR для ускорения..."
if ! grep -q "net.core.default_qdisc=fq" /etc/sysctl.conf; then
    cat >> /etc/sysctl.conf <<EOF

# BBR для ускорения TCP
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_fastopen=3
EOF
    sysctl -p > /dev/null
    print_info "BBR включен"
else
    print_info "BBR уже включен"
fi

# 6. Создание структуры директорий
print_msg "Шаг 6/7: Создание директорий..."
mkdir -p data/db data/logs data/cert

# 7. Запуск Docker Compose
print_msg "Шаг 7/7: Запуск VPN сервера..."
docker compose down 2>/dev/null || true
docker compose pull
docker compose up -d

# Ждем запуска
print_info "Ожидание запуска сервисов..."
sleep 10

# Проверка что контейнер запущен
if docker ps | grep -q "3x-ui"; then
    print_msg "✅ VPN сервер успешно запущен!"
else
    print_error "Контейнер не запустился. Проверьте логи: docker compose logs"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}🎉 УСТАНОВКА ЗАВЕРШЕНА!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BLUE}📱 Веб-панель управления:${NC}"
echo -e "   http://$SERVER_IP:54321"
echo ""
echo -e "${BLUE}👤 Данные для входа:${NC}"
echo -e "   Логин: admin"
echo -e "   Пароль: admin"
echo ""
echo -e "${YELLOW}⚠️  ВАЖНО: Сразу смените пароль в панели!${NC}"
echo ""
echo -e "${BLUE}📝 Следующие шаги:${NC}"
echo "   1. Откройте панель в браузере"
echo "   2. Войдите с данными выше"
echo "   3. Смените пароль администратора"
echo "   4. Создайте пользователей (Inbounds → Add)"
echo "   5. Получите QR-коды для телефонов"
echo ""
echo -e "${BLUE}🔧 Полезные команды:${NC}"
echo "   docker compose logs -f     # Просмотр логов"
echo "   docker compose restart     # Перезапуск"
echo "   docker compose down        # Остановка"
echo "   ./scripts/add-user.sh      # Добавить пользователя"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Сохраняем информацию в файл
cat > install-info.txt <<EOF
ReeR VPN - Информация об установке
═══════════════════════════════════

Дата установки: $(date)
IP сервера: $SERVER_IP

Веб-панель: http://$SERVER_IP:54321
Логин: admin
Пароль: admin (СМЕНИТЕ!)

Открытые порты:
- 443 (VLESS Reality)
- 2053 (VMess WebSocket)
- 54321 (Web Panel)

Управление:
- docker compose logs -f
- docker compose restart
- ./scripts/add-user.sh

Документация: README.md
EOF

print_info "Информация сохранена в install-info.txt"
