# Инструкция по добавлению фото профиля

## Шаг 1: Сохранение фото
1. Сохраните ваше фото в папку: `devops-resume-platform/app/src/images/`
2. Переименуйте файл в: `profile-photo.jpg`
3. Убедитесь, что файл имеет формат JPG

## Шаг 2: Проверка
После сохранения файла:
- JavaScript автоматически найдет фото
- Заменит placeholder с инициалами "ВР" на ваше фото
- Фото будет круглым (120x120px) с эффектом hover

## Шаг 3: Обновление на сервере
После сохранения фото локально:
1. Сделайте коммит: `git add . && git commit -m "Add profile photo"`
2. Загрузите на GitHub: `git push origin main`
3. Обновите на сервере: `git pull origin main`
4. Перезапустите контейнер: `docker restart resume-nginx`

## Структура файлов должна быть:
```
devops-resume-platform/
├── app/
│   └── src/
│       └── images/
│           ├── profile-photo.jpg  ← ВАШЕ ФОТО
│           ├── docker.svg
│           ├── kubernetes.svg
│           └── ...
```

JavaScript уже настроен и автоматически загрузит фото!
