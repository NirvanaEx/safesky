#!/bin/bash
set -e

# 1. Переключаемся на develop и обновляем её
git checkout develop
git pull origin develop

# 2. Извлекаем версию из pubspec.yaml
# Ожидается, что версия имеет формат X.Y.Z+BUILD, например: 2.7.4+119
FULL_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
# Берем только основную часть (X.Y.Z) и номер сборки отдельно
VERSION=$(echo "$FULL_VERSION" | cut -d'+' -f1)
BUILD_PART=$(echo "$FULL_VERSION" | cut -d'+' -f2)
# Если BUILD_PART содержит буквы, оставляем только цифры
CLEAN_BUILD=$(echo "$BUILD_PART" | sed 's/[^0-9]//g')
# Формируем тег для стабильного релиза в staging с суффиксом "b"
TAG="v${VERSION}+${CLEAN_BUILD}b"
echo "Извлечённая версия: $VERSION, сборка: $CLEAN_BUILD"
echo "Будущий тег для staging: $TAG"

# 3. Переключаемся на ветку staging
# Если ветка staging существует, переключаемся; иначе создаем её
if git show-ref --verify --quiet refs/heads/staging; then
    git checkout staging
    # Обновляем рабочую директорию: копируем файлы из develop
    git checkout develop -- .
else
    git checkout -b staging
    git checkout develop -- .
fi

# 4. Добавляем все файлы и создаем новый коммит (снимок стабильного состояния)
git add .
git commit -m "Staging release $TAG"

# 5. Создаем тег на последнем коммите в staging
git tag "$TAG"

# 6. Пушим ветку staging и тег в удалённый репозиторий
git push origin staging
git push origin "$TAG"

echo "Промоушен в staging завершен. Новый стабильный релиз: $TAG"
