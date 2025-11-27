/**
 * Пример использования ReeR Proxy с Node.js и axios
 * Для запросов к OpenAI API из России
 */

const axios = require('axios');
const { HttpsProxyAgent } = require('https-proxy-agent');

// Адрес вашего прокси сервера
const PROXY_URL = 'http://YOUR_SERVER_IP:3128';

// Создаем agent для прокси
const httpsAgent = new HttpsProxyAgent(PROXY_URL);

// Пример 1: Запрос к OpenAI API
async function exampleOpenAI() {
  try {
    const response = await axios.post(
      'https://api.openai.com/v1/chat/completions',
      {
        model: 'gpt-4',
        messages: [
          { role: 'user', content: 'Hello!' }
        ]
      },
      {
        httpsAgent, // Используем прокси
        headers: {
          'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
          'Content-Type': 'application/json'
        },
        timeout: 60000 // 60 секунд таймаут
      }
    );

    console.log('OpenAI Response:', response.data);
  } catch (error) {
    console.error('Error:', error.message);
  }
}

// Пример 2: Множественные параллельные запросы
async function exampleParallelRequests() {
  const requests = [];

  // Создаем 100 параллельных запросов
  for (let i = 0; i < 100; i++) {
    requests.push(
      axios.get('https://api.openai.com/v1/models', {
        httpsAgent,
        headers: {
          'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`
        }
      })
    );
  }

  try {
    const results = await Promise.all(requests);
    console.log(`Успешно выполнено ${results.length} запросов`);
  } catch (error) {
    console.error('Error in parallel requests:', error.message);
  }
}

// Пример 3: Создание переиспользуемого клиента
const openaiClient = axios.create({
  baseURL: 'https://api.openai.com/v1',
  httpsAgent,
  headers: {
    'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
    'Content-Type': 'application/json'
  },
  timeout: 60000
});

async function exampleWithClient() {
  try {
    // Теперь все запросы автоматически идут через прокси
    const models = await openaiClient.get('/models');
    console.log('Available models:', models.data);

    const completion = await openaiClient.post('/chat/completions', {
      model: 'gpt-4',
      messages: [{ role: 'user', content: 'Hi!' }]
    });
    console.log('Completion:', completion.data);
  } catch (error) {
    console.error('Error:', error.message);
  }
}

// Запуск примеров
if (require.main === module) {
  console.log('🚀 Тестирование ReeR Proxy...\n');

  // Раскомментируйте нужный пример:
  // exampleOpenAI();
  // exampleParallelRequests();
  // exampleWithClient();
}

module.exports = {
  openaiClient,
  PROXY_URL
};
