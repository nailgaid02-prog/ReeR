# 🚀 Инструкции по деплою ReeR VPN

Подробные инструкции для разных хостинг-провайдеров.

## 📋 Общие требования

- Ubuntu 20.04+ или Debian 10+
- Минимум 1GB RAM
- 10GB свободного места
- Root доступ по SSH
- Открытые порты: 22, 443, 2053, 54321

---

## 🟦 Hetzner Cloud (Рекомендуется)

**Цена:** от €4.15/мес
**Плюсы:** Быстро, надежно, европейские дата-центры

### 1. Создание сервера

1. Зарегистрируйтесь на [hetzner.com](https://www.hetzner.com/)
2. Перейдите в Cloud Console
3. Создайте новый проект "ReeR VPN"
4. Добавьте сервер:
   - **Location:** Nuremberg (Германия) или Helsinki (Финляндия)
   - **Image:** Ubuntu 22.04
   - **Type:** CPX11 (2 vCPU, 2GB RAM) - €4.15/мес
   - **Networking:** IPv4 + IPv6
   - **SSH Key:** Добавьте ваш публичный ключ

### 2. Подключение и установка

```bash
# Подключитесь к серверу
ssh root@YOUR_SERVER_IP

# Скачайте проект
git clone https://github.com/YOUR_USERNAME/ReeR.git
cd ReeR

# Запустите установку
chmod +x setup.sh
./setup.sh
```

### 3. Настройка Firewall в Hetzner

В панели Hetzner Cloud:
1. Networks → Firewalls → Create Firewall
2. Добавьте правила:
   - SSH: TCP 22 (0.0.0.0/0)
   - HTTPS: TCP 443 (0.0.0.0/0)
   - VMess: TCP 2053 (0.0.0.0/0)
   - Panel: TCP 54321 (ТОЛЬКО ВАШ IP!)

---

## 🟧 Oracle Cloud (БЕСПЛАТНО!)

**Цена:** $0 навсегда
**Плюсы:** Щедрый бесплатный tier, хорошая производительность

### 1. Регистрация

1. Создайте аккаунт на [oracle.com/cloud/free](https://www.oracle.com/cloud/free/)
2. Понадобится банковская карта (списания не будет)
3. Выберите регион (Amsterdam или Frankfurt для Европы)

### 2. Создание инстанса

1. Compute → Instances → Create Instance
2. Настройки:
   - **Name:** reer-vpn
   - **Image:** Ubuntu 22.04
   - **Shape:** VM.Standard.E2.1.Micro (Always Free)
   - **Network:** Создайте новую VCN или используйте default
   - **SSH Keys:** Добавьте публичный ключ

3. После создания запомните Public IP

### 3. Настройка Security List

1. Networking → Virtual Cloud Networks → Ваша VCN
2. Security Lists → Default Security List
3. Добавьте Ingress Rules:
   - SSH: TCP 22, Source 0.0.0.0/0
   - HTTPS: TCP 443, Source 0.0.0.0/0
   - VMess: TCP 2053, Source 0.0.0.0/0
   - Panel: TCP 54321, Source YOUR_IP/32

### 4. Установка

```bash
ssh ubuntu@YOUR_SERVER_IP

# Станьте root
sudo su -

# Скачайте проект
git clone https://github.com/YOUR_USERNAME/ReeR.git
cd ReeR

# Запустите установку
chmod +x setup.sh
./setup.sh
```

### ⚠️ Важно для Oracle Cloud

Oracle блокирует некоторые порты по умолчанию. Выполните:

```bash
# Очистите iptables
sudo iptables -F
sudo netfilter-persistent save

# Или отключите firewalld
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```

---

## 🟩 DigitalOcean

**Цена:** от $6/мес
**Плюсы:** $200 бонус для новых пользователей, простой интерфейс

### 1. Создание Droplet

1. Зарегистрируйтесь на [digitalocean.com](https://www.digitalocean.com/)
2. Create → Droplets
3. Настройки:
   - **Image:** Ubuntu 22.04 LTS
   - **Plan:** Basic, Regular - $6/mo (1GB RAM)
   - **Datacenter:** Amsterdam, Frankfurt, London
   - **Authentication:** SSH Key
   - **Hostname:** reer-vpn

### 2. Установка

```bash
ssh root@YOUR_DROPLET_IP

git clone https://github.com/YOUR_USERNAME/ReeR.git
cd ReeR
chmod +x setup.sh
./setup.sh
```

### 3. Настройка Cloud Firewall (опционально)

1. Networking → Firewalls → Create Firewall
2. Inbound Rules:
   - SSH: TCP 22 All IPv4
   - Custom: TCP 443 All IPv4
   - Custom: TCP 2053 All IPv4
   - Custom: TCP 54321 Your IP
3. Apply to Droplets → Выберите reer-vpn

---

## 🟨 Vultr

**Цена:** от $6/мес
**Плюсы:** Много локаций, хорошая скорость

### 1. Deploy Server

1. Зарегистрируйтесь на [vultr.com](https://www.vultr.com/)
2. Deploy New Server
3. Настройки:
   - **Type:** Cloud Compute
   - **Location:** Amsterdam, Frankfurt, Paris
   - **Server Type:** Ubuntu 22.04 LTS
   - **Plan:** $6/mo (1GB RAM)
   - **SSH Keys:** Добавьте ключ

### 2. Установка

```bash
ssh root@YOUR_SERVER_IP

git clone https://github.com/YOUR_USERNAME/ReeR.git
cd ReeR
chmod +x setup.sh
./setup.sh
```

---

## 🔧 После установки на любой платформе

### 1. Откройте веб-панель

```
http://YOUR_SERVER_IP:54321
```

Логин: `admin`
Пароль: `admin`

### 2. ОБЯЗАТЕЛЬНО смените пароль!

1. Settings → Change Password
2. Используйте сложный пароль

### 3. Создайте пользователей

1. Panel → Inbounds → Add Inbound
2. Выберите протокол:
   - **VLESS + Reality** (рекомендуется для РФ)
   - **VMess + WebSocket** (универсальный)
3. Настройки:
   - Port: 443 (VLESS) или 2053 (VMess)
   - Client ID: Генерируется автоматически
   - Enable: ON

### 4. Получите конфигурацию

1. Нажмите на пользователя
2. QR Code → Отсканируйте на телефоне
3. Или скопируйте ссылку для ручного ввода

---

## 📱 Установка клиентов

### iOS

**Streisand** (рекомендуется):
1. [App Store](https://apps.apple.com/app/streisand/id6450534064)
2. Scan QR или Add Configuration
3. Connect

**Альтернативы:**
- [V2Box](https://apps.apple.com/app/v2box/id6446814690)
- [Shadowrocket](https://apps.apple.com/app/shadowrocket/id932747118) ($2.99)

### Android

**v2rayNG** (бесплатно):
1. [GitHub Releases](https://github.com/2dust/v2rayNG/releases)
2. Установите APK
3. + → Import config from QR code
4. Подключитесь

**Альтернативы:**
- [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid)
- [SagerNet](https://github.com/SagerNet/SagerNet)

### Windows

**Nekoray** (рекомендуется):
1. [GitHub Releases](https://github.com/MatsuriDayo/nekoray/releases)
2. Download nekoray-windows64.zip
3. Распакуйте и запустите nekoray.exe
4. Server → New profile → Import from clipboard

**Альтернативы:**
- [v2rayN](https://github.com/2dust/v2rayN)
- [Qv2ray](https://github.com/Qv2ray/Qv2ray)

### macOS

**Nekoray** или **V2RayXS**:
1. [Nekoray Mac](https://github.com/MatsuriDayo/nekoray/releases)
2. Установите DMG
3. Импортируйте конфигурацию

---

## 🔒 Безопасность

### Ограничьте доступ к панели управления

```bash
# Разрешите доступ только с вашего IP
sudo ufw delete allow 54321/tcp
sudo ufw allow from YOUR_HOME_IP to any port 54321
sudo ufw reload
```

### Автоматические обновления

```bash
# Включите unattended-upgrades
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

### Регулярные бэкапы

```bash
# Создавайте backup раз в неделю
./scripts/backup.sh

# Настройте cron
crontab -e
# Добавьте строку:
0 3 * * 0 cd /root/ReeR && ./scripts/backup.sh
```

---

## 🆘 Помощь

**Не работает?**
```bash
./scripts/troubleshoot.sh
```

**Проверить статус:**
```bash
./scripts/status.sh
```

**Логи:**
```bash
docker compose logs -f
```

**Перезапуск:**
```bash
docker compose restart
```

---

## 💡 Советы

1. **Используйте VLESS Reality** - самый стойкий к блокировкам
2. **Включите BBR** - значительно ускоряет соединение
3. **Не используйте порт 22** для SSH - смените на нестандартный
4. **Настройте fail2ban** - защита от брутфорса
5. **Регулярно обновляйте** - `./scripts/update.sh`

---

Успешного деплоя! 🚀
