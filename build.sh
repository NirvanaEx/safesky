#!/bin/bash
set -e

# Ловушка для ошибок (локально ждём нажатия клавиши)
trap 'echo -e "\nОшибка произошла. Нажмите любую клавишу для выхода..."; read -n 1 -s -r; exit 1' ERR

usage() {
  echo "Usage:"
  echo "  run <flag>   # Локальный запуск"
  echo "  build <flag> # Автоматический коммит, сборка, push и запуск workflow (через push)"
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
FLAG=$2

if [ -z "$COMMAND" ] || [ -z "$FLAG" ]; then
  usage
fi

# Работаем только в ветке develop
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Текущая ветка: $BRANCH"
if [ "$BRANCH" != "develop" ]; then
  echo "Скрипт поддерживает сборку только из ветки develop"
  exit 1
fi

# Определяем префикс для commit message, SUFFIX и API_URL в зависимости от флага
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
  # Извлекаем версию из pubspec.yaml (например, 2.7.2+122) и заменяем '+' на '.'
  FULL_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
  NUMERIC_VERSION=$(echo "$FULL_VERSION" | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+\+[0-9]+).*/\1/')
  PROCESSED_VERSION=$(echo "$NUMERIC_VERSION" | sed 's/+/./')

  # Формируем commit message с маркером [BUILD_FLAG:<flag>]
  COMMIT_MESSAGE="$PREFIX v${PROCESSED_VERSION}${SUFFIX} [BUILD_FLAG:$FLAG]"
  echo "Автоматический коммит: $COMMIT_MESSAGE"

  # Экспортируем переменную, чтобы pre-commit hook пропустил обновление версии
  export SKIP_VERSION_INCREMENT=true
  echo "SKIP_VERSION_INCREMENT is set to: $SKIP_VERSION_INCREMENT"

  git add .
  git commit --allow-empty -m "$COMMIT_MESSAGE" || echo "Нет изменений для коммита"
  git push origin develop

  echo "Коммит отправлен. Workflow запустится автоматически при push."
else
  echo "Используйте команды 'run' или 'build'"
  usage
fi

read -n 1 -s -r -p "Нажмите любую клавишу для выхода..."
echo
