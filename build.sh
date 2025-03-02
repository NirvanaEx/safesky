#!/bin/bash
set -e

# Ловушка для ошибок (локально ждём нажатия клавиши)
trap 'echo -e "\nОшибка произошла. Нажмите любую клавишу для выхода..."; read -n 1 -s -r; exit 1' ERR

usage() {
  echo "Usage:"
  echo "  run <flag>   # Локальный запуск"
  echo "  build <flag> # Автоматический коммит и тег, сборка и пуш"
  echo ""
  echo "Флаги:"
  echo "  -at  : Develop release с суффиксом at (тестовый URL)"
  echo "  -ap  : Develop release с суффиксом ap (production URL)"
  echo "  -bt  : Testing release с суффиксом bt (тестовый URL)"
  echo "  -bp  : Testing release с суффиксом bp (production URL)"
  echo "  -t   : Testing release с суффиксом t (тестовый URL)"
  echo "  -p   : Production release (без суффикса, production URL)"
  exit 1
}

COMMAND=$1
FLAG=${2:--at}

if [ -z "$COMMAND" ]; then
  usage
fi

# Работаем только в ветке develop
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Текущая ветка: $BRANCH"

if [ "$BRANCH" != "develop" ]; then
  echo "Скрипт поддерживает сборку только из ветки develop"
  exit 1
fi

# Определяем префикс для commit-message, SUFFIX и API_URL в зависимости от флага
case "$FLAG" in
  -at)
    PREFIX="Develop release"
    SUFFIX="at"
    API_URL="http://91.213.31.234:8898/bpla_mobile_service/api/v1/"
    ;;
  -ap)
    PREFIX="Develop release"
    SUFFIX="ap"
    API_URL="http://195.158.18.149:8085/bpla_mobile_service/api/v1/"
    ;;
  -bt)
    PREFIX="Testing release"
    SUFFIX="bt"
    API_URL="http://91.213.31.234:8898/bpla_mobile_service/api/v1/"
    ;;
  -bp)
    PREFIX="Testing release"
    SUFFIX="bp"
    API_URL="http://195.158.18.149:8085/bpla_mobile_service/api/v1/"
    ;;
  -t)
    PREFIX="Testing release"
    SUFFIX="t"
    API_URL="http://91.213.31.234:8898/bpla_mobile_service/api/v1/"
    ;;
  -p)
    PREFIX="Production release"
    SUFFIX=""
    API_URL="http://195.158.18.149:8085/bpla_mobile_service/api/v1/"
    ;;
  *)
    echo "Неверный флаг: $FLAG"
    usage
    ;;
esac

if [ "$COMMAND" = "run" ]; then
  echo "Локальный запуск с BUILD_SUFFIX=$SUFFIX"
  flutter run --release --dart-define API_URL=${API_URL} --dart-define BUILD_SUFFIX=${SUFFIX}
elif [ "$COMMAND" = "build" ]; then
  # Извлекаем версию из pubspec.yaml (например, 2.2.12+123)
  FULL_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
  # Заменяем '+' на '.' → 2.2.12.123
  PROCESSED_VERSION=$(echo "$FULL_VERSION" | sed 's/+/./')
  if [ -z "$SUFFIX" ]; then
    TAG="v${PROCESSED_VERSION}"
  else
    TAG="v${PROCESSED_VERSION}${SUFFIX}"
  fi
  echo "Автоматический коммит с тегом: $TAG"

  # Экспортируем переменную, чтобы pre-commit hook пропустил обновление версии
  export SKIP_VERSION_INCREMENT=true
  echo "SKIP_VERSION_INCREMENT is set to: $SKIP_VERSION_INCREMENT"

  git add .
  COMMIT_MESSAGE="$PREFIX $TAG"
  # Создаём пустой коммит, если нет изменений
  git commit --allow-empty -m "$COMMIT_MESSAGE" || echo "Нет изменений для коммита"
  if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "Тег $TAG уже существует, пропускаем создание."
  else
    git tag "$TAG"
  fi
  git push origin develop
  git push origin "$TAG" || echo "Не удалось запушить тег."

  echo "Коммит и тег отправлены. Серверная сборка (CI) должна запуститься автоматически."
else
  echo "Используйте команды 'run' или 'build'"
  usage
fi

read -n 1 -s -r -p "Нажмите любую клавишу для выхода..."
echo
