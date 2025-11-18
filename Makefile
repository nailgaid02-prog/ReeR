.PHONY: help install start stop restart logs status clean backup update

# Цвета для вывода
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

help: ## Показать эту справку
	@echo "$(BLUE)ReeR VPN - Доступные команды:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

install: ## Установить ReeR VPN
	@echo "$(BLUE)Запуск установки ReeR VPN...$(NC)"
	@chmod +x setup.sh
	@./setup.sh

start: ## Запустить VPN сервер
	@echo "$(BLUE)Запуск VPN сервера...$(NC)"
	@docker compose up -d
	@echo "$(GREEN)Сервер запущен!$(NC)"
	@make status

stop: ## Остановить VPN сервер
	@echo "$(YELLOW)Остановка VPN сервера...$(NC)"
	@docker compose down
	@echo "$(GREEN)Сервер остановлен$(NC)"

restart: ## Перезапустить VPN сервер
	@echo "$(BLUE)Перезапуск VPN сервера...$(NC)"
	@docker compose restart
	@echo "$(GREEN)Сервер перезапущен!$(NC)"

logs: ## Показать логи
	@docker compose logs -f

status: ## Показать статус сервисов
	@echo "$(BLUE)Статус сервисов:$(NC)"
	@docker compose ps
	@echo ""
	@if [ -f scripts/status.sh ]; then \
		chmod +x scripts/status.sh && ./scripts/status.sh; \
	fi

clean: ## Полностью удалить все данные (ОСТОРОЖНО!)
	@echo "$(YELLOW)ВНИМАНИЕ: Это удалит все данные включая конфигурации пользователей!$(NC)"
	@read -p "Вы уверены? (yes/no): " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		docker compose down -v; \
		rm -rf data/; \
		echo "$(GREEN)Данные удалены$(NC)"; \
	else \
		echo "Отменено"; \
	fi

backup: ## Создать резервную копию
	@echo "$(BLUE)Создание резервной копии...$(NC)"
	@if [ -f scripts/backup.sh ]; then \
		chmod +x scripts/backup.sh && ./scripts/backup.sh; \
	else \
		mkdir -p backups; \
		tar -czf backups/backup-$$(date +%Y%m%d-%H%M%S).tar.gz data/; \
		echo "$(GREEN)Backup создан в backups/$(NC)"; \
	fi

update: ## Обновить контейнеры
	@echo "$(BLUE)Обновление контейнеров...$(NC)"
	@if [ -f scripts/update.sh ]; then \
		chmod +x scripts/update.sh && ./scripts/update.sh; \
	else \
		docker compose pull; \
		docker compose up -d; \
		echo "$(GREEN)Контейнеры обновлены!$(NC)"; \
	fi

pull: ## Скачать последние образы
	@echo "$(BLUE)Скачивание последних образов...$(NC)"
	@docker compose pull
	@echo "$(GREEN)Образы обновлены!$(NC)"

shell: ## Войти в контейнер 3x-ui
	@docker compose exec 3x-ui /bin/sh

check: ## Проверить систему перед установкой
	@echo "$(BLUE)Проверка системы...$(NC)"
	@echo -n "Docker: "
	@command -v docker >/dev/null 2>&1 && echo "$(GREEN)✓$(NC)" || echo "$(YELLOW)✗ не установлен$(NC)"
	@echo -n "Docker Compose: "
	@docker compose version >/dev/null 2>&1 && echo "$(GREEN)✓$(NC)" || echo "$(YELLOW)✗ не установлен$(NC)"
	@echo -n "Git: "
	@command -v git >/dev/null 2>&1 && echo "$(GREEN)✓$(NC)" || echo "$(YELLOW)✗ не установлен$(NC)"
	@echo -n "UFW: "
	@command -v ufw >/dev/null 2>&1 && echo "$(GREEN)✓$(NC)" || echo "$(YELLOW)✗ не установлен$(NC)"
	@echo ""

troubleshoot: ## Диагностика проблем
	@if [ -f scripts/troubleshoot.sh ]; then \
		chmod +x scripts/troubleshoot.sh && ./scripts/troubleshoot.sh; \
	else \
		echo "$(BLUE)Базовая диагностика:$(NC)"; \
		echo ""; \
		echo "Статус контейнеров:"; \
		docker compose ps; \
		echo ""; \
		echo "Последние логи:"; \
		docker compose logs --tail=50; \
	fi

info: ## Показать информацию о сервере
	@echo "$(BLUE)Информация о сервере:$(NC)"
	@echo ""
	@echo "IP адрес: $$(curl -s ifconfig.me)"
	@echo "Веб-панель: http://$$(curl -s ifconfig.me):54321"
	@echo ""
	@if [ -f install-info.txt ]; then \
		cat install-info.txt; \
	fi

dev: ## Режим разработки (с просмотром логов)
	@docker compose up

# По умолчанию показываем help
.DEFAULT_GOAL := help
