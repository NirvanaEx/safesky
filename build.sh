#!/bin/bash
set -e

# Универсальный скрипт build.sh
# Использование:
#  В develop:
#    Локально:         ./build.sh run -t    # тестовая сборка (BUILD_SUFFIX = at)
#                      ./build.sh run -p    # production сборка (BUILD_SUFFIX = ap)
#    Серверная сборка:  ./build.sh build -t  # тестовая сборка (BUILD_SUFFIX = at)
#                      ./build.sh build -p  # production сборка (BUILD_SUFFIX = ap)
#
#  В staging:
#                      ./build.sh build -t  # тестовая сборка (BUILD_SUFFIX = bt)
#                      ./build.sh build -p  # production сборка (BUILD_SUFFIX = bp)
#
#  В master:
#                      ./build.sh build     # финальная сборка (без суффикса)
#
# Функция отправки APK (пример – необходимо, чтобы переменные TELEGRAM_TOKEN и TELEGRAM_CHAT_ID были установлены)
send_telegram() {
  APK_PATH=$1
  echo "Отправка APK в Telegram..."
  curl -F chat_id=${TELEGRAM_CHAT_ID} \
       -F caption="Сборка APK завершена" \
       -F document=@"${APK_PATH}" \
       "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument"
}

usage() {
  echo "Usage:"
  echo "  In develop:"
  echo "    Local run:      ./build.sh run -t   # BUILD_SUFFIX = at"
  echo "                    ./build.sh run -p   # BUILD_SUFFIX = ap"
  echo "    Server build:   ./build.sh build -t # BUILD_SUFFIX = at"
  echo "                    ./build.sh build -p # BUILD_SUFFIX = ap"
  echo ""
  echo "  In staging:"
  echo "    ./build.sh build -t   # BUILD_SUFFIX = bt"
  echo "    ./build.sh build -p   # BUILD_SUFFIX = bp"
  echo ""
  echo "  In master:"
  echo "    ./build.sh build    # финальная сборка (без суффикса)"
  exit 1
}

# Первый параметр: команда (run или build)
COMMAND=$1
# Второй параметр: флаг (-t или -p) (для develop и staging; в master не нужен)
FLAG=$2

if [ -z "$COMMAND" ]; then
  usage
fi

# Определяем текущую ветку
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Текущая ветка: $BRANCH"

if [ "$BRANCH" = "develop" ]; then
  # В develop доступны команды run и build
  if [ "$COMMAND" = "run" ]; then
    # Локальный запуск через flutter run
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
    # Серверная сборка в develop (с отправкой в Telegram)
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
    echo "Серверная сборка в develop с BUILD_SUFFIX=$SUFFIX"
    flutter build apk --release --dart-define API_URL=${API_URL} --dart-define BUILD_SUFFIX=${SUFFIX}
    send_telegram "build/app/outputs/flutter-apk/app-release.apk"
  else
    echo "В develop используйте команду 'run' или 'build'"
    usage
  fi

elif [ "$BRANCH" = "staging" ]; then
  # В staging доступна только команда build с флагом
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

  echo "Промоушен в staging (из develop в staging) с BUILD_SUFFIX=$SUFFIX"
  # 1. Обновляем develop и переключаемся на неё
  git checkout develop
  git pull origin develop

  # 2. Переключаемся (или создаём) ветку staging и вливаем develop
  if git show-ref --verify --quiet refs/heads/staging; then
    git checkout staging
    git merge develop --no-edit
  else
    git checkout -b staging develop
  fi

  # 3. Извлекаем версию из pubspec.yaml и формируем тег (с буквой "b")
  FULL_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
  VERSION=$(echo "$FULL_VERSION" | cut -d'+' -f1)
  BUILD_PART=$(echo "$FULL_VERSION" | cut -d'+' -f2)
  CLEAN_BUILD=$(echo "$BUILD_PART" | sed 's/[^0-9]//g')
  TAG="v${VERSION}+${CLEAN_BUILD}b"
  echo "Сформирован тег для staging: $TAG"

  # 4. Фиксируем состояние: коммит и тег
  git add .
  git commit -m "Staging release $TAG" || echo "Нет изменений для коммита"
  git tag "$TAG"
  git push origin staging
  git push origin "$TAG"

  # 5. Собираем APK из ветки staging
  flutter build apk --release --dart-define API_URL=${API_URL} --dart-define BUILD_SUFFIX=${SUFFIX}
  send_telegram "build/app/outputs/flutter-apk/app-release.apk"

elif [ "$BRANCH" = "master" ]; then
  # В master доступна только команда build (без флага)
  if [ "$COMMAND" != "build" ]; then
    echo "В master используйте команду 'build'"
    usage
  fi
  echo "Промоушен в master (из staging в master)"
  # 1. Обновляем staging и переключаемся на неё
  git checkout staging
  git pull origin staging

  # 2. Переключаемся (или создаём) ветку master и вливаем staging
  if git show-ref --verify --quiet refs/heads/master; then
    git checkout master
    git merge staging --no-edit
  else
    git checkout -b master staging
  fi

  # 3. Извлекаем версию и формируем финальный тег (без суффикса)
  FULL_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
  VERSION=$(echo "$FULL_VERSION" | cut -d'+' -f1)
  BUILD_PART=$(echo "$FULL_VERSION" | cut -d'+' -f2)
  CLEAN_BUILD=$(echo "$BUILD_PART" | sed 's/[^0-9]//g')
  TAG="v${VERSION}+${CLEAN_BUILD}"
  echo "Сформирован финальный тег для master: $TAG"

  # 4. Фиксируем состояние: коммит и тег
  git add .
  git commit -m "Master release $TAG" || echo "Нет изменений для коммита"
  git tag "$TAG"
  git push origin master
  git push origin "$TAG"

  # 5. Собираем финальный APK (production, без суффикса)
  flutter build apk --release --dart-define API_URL=http://195.158.18.149:8085/bpla_mobile_service/api/v1/ --dart-define BUILD_SUFFIX=""
  send_telegram "build/app/outputs/flutter-apk/app-release.apk"

else
  echo "Скрипт поддерживает сборку только в ветках develop, staging и master"
  exit 1
fi
