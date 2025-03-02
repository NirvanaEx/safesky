#!/bin/bash
set -e

# Ловушка для обработки ошибок
trap 'echo -e "\nОшибка произошла. Нажмите любую клавишу для выхода..."; read -n 1 -s -r; exit 1' ERR

usage() {
  echo "Usage:"
  echo "  В develop:"
  echo "    run -t        # Локальный запуск тестовой версии (BUILD_SUFFIX = at)"
  echo "    build -p      # Локальная сборка с автоматическим коммитом и тегом (например, v2.7.18.131ap)"
  echo ""
  echo "  В staging:"
  echo "    build -t      # Сборка с тегом (например, v2.7.18.131bt)"
  echo "    build -p      # Сборка с тегом (например, v2.7.18.131bp)"
  echo ""
  echo "  В master:"
  echo "    build         # Промоушен из staging в master, сборка с финальным тегом (без суффикса)"
  exit 1
}

COMMAND=$1
FLAG=$2

if [ -z "$COMMAND" ]; then
  usage
fi

# Определяем текущую ветку
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Текущая ветка: $BRANCH"

if [ "$BRANCH" = "develop" ]; then
  if [ "$COMMAND" = "run" ]; then
    if [ "$FLAG" = "-t" ]; then
      SUFFIX="at"
      API_URL="http://91.213.31.234:8898/bpla_mobile_service/api/v1/"
    elif [ "$FLAG" = "-p" ]; then
      SUFFIX="ap"
      API_URL="http://195.158.18.149:8085/bpla_mobile_service/api/v1/"
    else
      echo "Укажите флаг -t или -p для команды run"
      usage
    fi
    echo "Локальный запуск в develop с BUILD_SUFFIX=$SUFFIX"
    flutter run --release --dart-define API_URL=${API_URL} --dart-define BUILD_SUFFIX=${SUFFIX}

  elif [ "$COMMAND" = "build" ]; then
    if [ "$FLAG" = "-t" ]; then
      SUFFIX="at"
      API_URL="http://91.213.31.234:8898/bpla_mobile_service/api/v1/"
    elif [ "$FLAG" = "-p" ]; then
      SUFFIX="ap"
      API_URL="http://195.158.18.149:8085/bpla_mobile_service/api/v1/"
    else
      echo "Укажите флаг -t или -p для команды build в develop"
      usage
    fi
    echo "Локальная сборка в develop с BUILD_SUFFIX=$SUFFIX"

    # Получаем версию из pubspec.yaml (например, 2.7.18+131)
    FULL_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
    # Преобразуем формат: заменяем '+' на '.' (результат: 2.7.18.131)
    PROCESSED_VERSION=$(echo "$FULL_VERSION" | sed 's/+/./')
    # Формируем тег: добавляем SUFFIX к числовой версии
    TAG="v${PROCESSED_VERSION}${SUFFIX}"
    echo "Автоматический коммит с тегом: $TAG"

    git add .
    git commit -m "$TAG" || echo "Нет изменений для коммита"
    # Создаем тег, если он не существует
    if git rev-parse "$TAG" >/dev/null 2>&1; then
      echo "Тег $TAG уже существует, пропускаем создание."
    else
      git tag "$TAG"
    fi
    git push origin develop
    git push origin "$TAG" || echo "Не удалось запушить тег."

    echo "Коммит и тег отправлены. Серверная сборка (CI) должна запуститься автоматически."
  else
    echo "В develop используйте команды 'run' или 'build'"
    usage
  fi

elif [ "$BRANCH" = "staging" ]; then
  if [ "$COMMAND" != "build" ]; then
    echo "В staging используйте команду 'build'"
    usage
  fi
  if [ "$FLAG" = "-t" ]; then
    SUFFIX="bt"
    API_URL="http://91.213.31.234:8898/bpla_mobile_service/api/v1/"
  elif [ "$FLAG" = "-p" ]; then
    SUFFIX="bp"
    API_URL="http://195.158.18.149:8085/bpla_mobile_service/api/v1/"
  else
    echo "Укажите флаг -t или -p для сборки в staging"
    usage
  fi
  echo "Обновление ветки staging (копирование из develop) с BUILD_SUFFIX=$SUFFIX"
  git checkout develop
  git pull origin develop
  if git show-ref --verify --quiet refs/heads/staging; then
    git checkout staging
    git reset --hard develop
  else
    git checkout -b staging develop
  fi
  FULL_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
  PROCESSED_VERSION=$(echo "$FULL_VERSION" | sed 's/+/./')
  TAG="v${PROCESSED_VERSION}${SUFFIX}"
  echo "Сформирован тег для staging: $TAG"
  git add .
  git commit -m "Staging release $TAG" || echo "Нет изменений для коммита"
  if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "Тег $TAG уже существует, пропускаем создание."
  else
    git tag "$TAG"
  fi
  git push origin staging
  git push origin "$TAG" || echo "Не удалось запушить тег."

  echo "Коммит и тег отправлены. Серверная сборка (CI) должна запуститься автоматически."

elif [ "$BRANCH" = "master" ]; then
  if [ "$COMMAND" != "build" ]; then
    echo "В master используйте команду 'build'"
    usage
  fi
  echo "Промоушен в master (из staging в master)"
  git checkout staging
  git pull origin staging
  if git show-ref --verify --quiet refs/heads/master; then
    git checkout master
    git merge staging --no-edit
  else
    git checkout -b master staging
  fi
  FULL_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
  PROCESSED_VERSION=$(echo "$FULL_VERSION" | sed 's/+/./')
  TAG="v${PROCESSED_VERSION}"
  echo "Сформирован финальный тег для master: $TAG"
  git add .
  git commit -m "Master release $TAG" || echo "Нет изменений для коммита"
  git tag "$TAG"
  git push origin master
  git push origin "$TAG"

  echo "Коммит и тег отправлены. Серверная сборка (CI) должна запуститься автоматически."

else
  echo "Скрипт поддерживает сборку только в ветках develop, staging и master"
  exit 1
fi

read -n 1 -s -r -p "Нажмите любую клавишу для выхода..."
echo
