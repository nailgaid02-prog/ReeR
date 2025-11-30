# QUICKFIX: ReeR HTTP Proxy (Squid + Docker)

Этот файл описывает **актуальную рабочую конфигурацию** прокси, которая сейчас используется на RackNerd.

---

## 1. Требования

На сервере должны быть установлены:

- Docker
- Docker Compose v2 (`docker-compose-plugin`)

Проверка:

```bash
docker --version
docker compose version
