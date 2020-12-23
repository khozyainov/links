# Links

## Запуск приложения

```sh
docker-compose up -d
```
Дефолтный порт `4000`

## Примеры

- Загрузка посещений
```sh
curl -X POST 'http://localhost:4000/visited_links' \
  -H 'Content-Type: application/json' \
  -d '{
      "links": [
          "https://ya.ru",
          "https://ya.ru?q=123",
          "funbox.ru",
          "https://stackoverflow.com/questions/11828270"
      ]
  }'
```

- Получение статистики
```sh
curl -X GET 'http://localhost:4000/visited_domains?from=1608650723&to=1808650723'
```

## Тесты

```sh
docker-compose run -e MIX_ENV=test web mix test
```
