"""
Пример использования ReeR Proxy с Python и requests
Для запросов к OpenAI API из России
"""

import os
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed

# Адрес вашего прокси сервера
PROXY_URL = "http://YOUR_SERVER_IP:3128"

# Настройка прокси
proxies = {
    "http": PROXY_URL,
    "https": PROXY_URL
}

# Пример 1: Простой запрос к OpenAI
def example_openai():
    """Простой запрос к OpenAI API через прокси"""
    url = "https://api.openai.com/v1/chat/completions"

    headers = {
        "Authorization": f"Bearer {os.getenv('OPENAI_API_KEY')}",
        "Content-Type": "application/json"
    }

    data = {
        "model": "gpt-4",
        "messages": [
            {"role": "user", "content": "Hello!"}
        ]
    }

    try:
        response = requests.post(
            url,
            json=data,
            headers=headers,
            proxies=proxies,
            timeout=60  # 60 секунд таймаут
        )
        response.raise_for_status()
        print("OpenAI Response:", response.json())
    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")


# Пример 2: Множественные параллельные запросы
def make_request(index):
    """Функция для выполнения одного запроса"""
    url = "https://api.openai.com/v1/models"
    headers = {
        "Authorization": f"Bearer {os.getenv('OPENAI_API_KEY')}"
    }

    try:
        response = requests.get(
            url,
            headers=headers,
            proxies=proxies,
            timeout=30
        )
        response.raise_for_status()
        return {"index": index, "success": True}
    except Exception as e:
        return {"index": index, "success": False, "error": str(e)}


def example_parallel_requests():
    """100 параллельных запросов через прокси"""
    print("🚀 Запуск 100 параллельных запросов...")

    # ThreadPoolExecutor для параллельных запросов
    with ThreadPoolExecutor(max_workers=50) as executor:
        # Создаем 100 задач
        futures = [executor.submit(make_request, i) for i in range(100)]

        # Собираем результаты
        results = []
        for future in as_completed(futures):
            results.append(future.result())

    # Статистика
    successful = sum(1 for r in results if r["success"])
    failed = len(results) - successful

    print(f"✅ Успешно: {successful}")
    print(f"❌ Ошибок: {failed}")


# Пример 3: Создание переиспользуемой сессии
class OpenAIClient:
    """Клиент OpenAI с встроенным прокси"""

    def __init__(self, api_key=None, proxy_url=PROXY_URL):
        self.api_key = api_key or os.getenv('OPENAI_API_KEY')
        self.base_url = "https://api.openai.com/v1"

        # Создаем сессию с прокси
        self.session = requests.Session()
        self.session.proxies = {
            "http": proxy_url,
            "https": proxy_url
        }
        self.session.headers.update({
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        })

    def get_models(self):
        """Получить список моделей"""
        response = self.session.get(
            f"{self.base_url}/models",
            timeout=30
        )
        response.raise_for_status()
        return response.json()

    def chat_completion(self, messages, model="gpt-4"):
        """Создать chat completion"""
        response = self.session.post(
            f"{self.base_url}/chat/completions",
            json={
                "model": model,
                "messages": messages
            },
            timeout=60
        )
        response.raise_for_status()
        return response.json()

    def close(self):
        """Закрыть сессию"""
        self.session.close()


def example_with_client():
    """Использование клиента с автоматическим прокси"""
    client = OpenAIClient()

    try:
        # Все запросы автоматически идут через прокси
        models = client.get_models()
        print("Available models:", len(models.get("data", [])))

        completion = client.chat_completion([
            {"role": "user", "content": "Hi!"}
        ])
        print("Completion:", completion)
    except Exception as e:
        print(f"Error: {e}")
    finally:
        client.close()


# Пример 4: Проверка работы прокси
def test_proxy():
    """Проверить работает ли прокси"""
    try:
        # Запрос без прокси (должен не работать из РФ)
        print("📡 Тест без прокси...")
        response_no_proxy = requests.get(
            "https://api.openai.com/v1/models",
            headers={"Authorization": f"Bearer {os.getenv('OPENAI_API_KEY')}"},
            timeout=10
        )
        print("❌ Без прокси работает (вы не в РФ?)")
    except:
        print("✅ Без прокси не работает (ожидаемо)")

    try:
        # Запрос с прокси (должен работать)
        print("\n📡 Тест с прокси...")
        response_with_proxy = requests.get(
            "https://api.openai.com/v1/models",
            headers={"Authorization": f"Bearer {os.getenv('OPENAI_API_KEY')}"},
            proxies=proxies,
            timeout=10
        )
        print(f"✅ С прокси работает! Status: {response_with_proxy.status_code}")
    except Exception as e:
        print(f"❌ С прокси не работает: {e}")


if __name__ == "__main__":
    print("🚀 Тестирование ReeR Proxy...\n")

    # Раскомментируйте нужный пример:
    # example_openai()
    # example_parallel_requests()
    # example_with_client()
    test_proxy()
