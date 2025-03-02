#!/bin/bash
set -e

# Ловушка для ошибок (локально ждём нажатия клавиши)
trap 'echo -e "\nОшибка произошла. Нажмите любую клавишу для выхода..."; read -n 1 -s -r; exit 1' ERR

usage() {
  echo "Usage:"
<<<<<<< HEAD
  echo "  run <flag>   # Локальный запуск"
  echo "  build <flag> # Автоматический коммит, сборка и push (без создания тэга)"
  echo ""
  echo "Флаги:"
  echo "  -at  : Develop release с суффиксом at (тестовый URL)"
  echo "  -ap  : Develop release с суффиксом ap (production URL)"
  echo "  -bt  : Testing release с суффиксом bt (тестовый URL)"
  echo "  -bp  : Testing release с суффиксом bp (production URL)"
  echo "  -t   : Testing release с суффиксом t (тестовый URL)"
  echo "  -p   : Production release (без суффикса, production URL)"
=======
  echo "  В develop:"
  echo "    run -t        # Локальный запуск тестовой версии (BUILD_SUFFIX = at)"
  echo "    build -p      # Локальная сборка с коммитом и тегом (например, Develop release v2.7.23.133at)"
  echo ""
  echo "  В staging:"
  echo "    build -t      # (например, Staging release v2.7.23.133bt)"
  echo "    build -p      # (например, Staging release v2.7.23.133bp)"
  echo ""
  echo "  В master:"
  echo "    build         # (например, Master release v2.7.23.133)"
>>>>>>> b97b7cb (Сборка)
  exit 1
}

COMMAND=$1
FLAG=$2

<<<<<<< HEAD
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
  # Извлекаем версию из pubspec.yaml (например, 2.12.123+123) и заменяем '+' на '.'
  FULL_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
  NUMERIC_VERSION=$(echo "$FULL_VERSION" | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+\+[0-9]+).*/\1/')
  PROCESSED_VERSION=$(echo "$NUMERIC_VERSION" | sed 's/+/./')

  # Формируем commit message с версией и маркером с флагом
  COMMIT_MESSAGE="$PREFIX v${PROCESSED_VERSION}${SUFFIX} [BUILD_FLAG:$FLAG]"
  echo "Автоматический коммит: $COMMIT_MESSAGE"

  # Экспортируем переменную, чтобы pre-commit hook пропустил обновление версии
=======
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

    # Извлекаем версию из pubspec.yaml (например, 2.7.23+133)
    FULL_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
    # Преобразуем: заменяем '+' на '.' → 2.7.23.133
    PROCESSED_VERSION=$(echo "$FULL_VERSION" | sed 's/+/./')
    # Формируем тег, добавляя SUFFIX
    TAG="v${PROCESSED_VERSION}${SUFFIX}"
    echo "Автоматический коммит с тегом: $TAG"

    # Экспортируем переменную, чтобы pre-commit hook пропустил обновление версии
    export SKIP_VERSION_INCREMENT=true
    echo "SKIP_VERSION_INCREMENT is set to: $SKIP_VERSION_INCREMENT"

    git add .
    COMMIT_MESSAGE="Develop release $TAG"
    # Создаем пустой коммит, если нет изменений
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

>>>>>>> b97b7cb (Сборка)
  export SKIP_VERSION_INCREMENT=true
  echo "SKIP_VERSION_INCREMENT is set to: $SKIP_VERSION_INCREMENT"

  git add .
<<<<<<< HEAD
  # Создаём пустой коммит, если нет изменений
  git commit --allow-empty -m "$COMMIT_MESSAGE" || echo "Нет изменений для коммита"
  # Выполняем один push (без тэга)
  git push origin develop

  echo "Коммит отправлен. Серверная сборка (CI) должна запуститься автоматически."
else
  echo "Используйте команды 'run' или 'build'"
  usage
=======
  COMMIT_MESSAGE="Staging release $TAG"
  git commit --allow-empty -m "$COMMIT_MESSAGE" || echo "Нет изменений для коммита"
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

  export SKIP_VERSION_INCREMENT=true
  echo "SKIP_VERSION_INCREMENT is set to: $SKIP_VERSION_INCREMENT"

  git add .
  COMMIT_MESSAGE="Master release $TAG"
  git commit --allow-empty -m "$COMMIT_MESSAGE" || echo "Нет изменений для коммита"
  git tag "$TAG"
  git push origin master
  git push origin "$TAG" || echo "Не удалось запушить тег."

  echo "Коммит и тег отправлены. Серверная сборка (CI) должна запуститься автоматически."
else
  echo "Скрипт поддерживает сборку только в ветках develop, staging и master"
  exit 1
>>>>>>> b97b7cb (Сборка)
fi

read -n 1 -s -r -p "Нажмите любую клавишу для выхода..."
echo
