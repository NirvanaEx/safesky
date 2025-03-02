#!/bin/bash
set -e

# Ловушка для обработки ошибок
trap 'echo -e "\nОшибка произошла. Нажмите любую клавишу для выхода..."; exit 1' ERR

usage() {
  echo "Usage:"
  echo "  ./build_server.sh build [flag]"
  echo "Примеры:"
  echo "  В develop:  build -t или build -p"
  echo "  В staging:  build -t или build -p"
  echo "  В master:   build (без флага)"
  exit 1
}

# Получаем аргументы (если они заданы)
COMMAND=${1:-build}
FLAG=${2:-}

# Определяем текущую ветку
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Текущая ветка: $BRANCH"

# Если флаг не задан, пробуем извлечь его из последнего тега
if [ -z "$FLAG" ]; then
  LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
  echo "Последний тег: $LAST_TAG"
  if [[ "$LAST_TAG" =~ (at|ap|bt|bp)$ ]]; then
    SUFFIX_FROM_TAG=${BASH_REMATCH[1]}
    echo "SUFFIX из тега: $SUFFIX_FROM_TAG"
    if [[ "$SUFFIX_FROM_TAG" == "at" || "$SUFFIX_FROM_TAG" == "bt" ]]; then
      FLAG="-t"
    elif [[ "$SUFFIX_FROM_TAG" == "ap" || "$SUFFIX_FROM_TAG" == "bp" ]]; then
      FLAG="-p"
    fi
    echo "Установленный флаг: $FLAG"
  else
    echo "Тег не содержит суффикс (флаг не определён). Используем значение по умолчанию."
  fi
fi

# Функция отправки APK в Telegram
send_telegram() {
  APK_PATH=$1
  echo "Отправка APK в Telegram..."
  curl -F chat_id=${TELEGRAM_CHAT_ID} \
       -F caption="Сборка APK завершена" \
       -F document=@"${APK_PATH}" \
       "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument"
}

if [ "$BRANCH" = "develop" ]; then
  if [ "$COMMAND" != "build" ]; then
    echo "В develop для серверной сборки используйте команду 'build'"
    usage
  fi
  if [ "$FLAG" = "-t" ]; then
    SUFFIX="at"
    API_URL="http://91.213.31.234:8898/bpla_mobile_service/api/v1/"
  elif [ "$FLAG" = "-p" ]; then
    SUFFIX="ap"
    API_URL="http://195.158.18.149:8085/bpla_mobile_service/api/v1/"
  else
    echo "Укажите флаг -t или -p для сборки в develop"
    usage
  fi
  echo "Серверная сборка в develop с BUILD_SUFFIX=$SUFFIX"
  flutter build apk --release --dart-define API_URL=${API_URL} --dart-define BUILD_SUFFIX=${SUFFIX}
  send_telegram "build/app/outputs/flutter-apk/app-release.apk"

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
  echo "Серверная сборка в staging с BUILD_SUFFIX=$SUFFIX"
  flutter build apk --release --dart-define API_URL=${API_URL} --dart-define BUILD_SUFFIX=${SUFFIX}
  send_telegram "build/app/outputs/flutter-apk/app-release.apk"

elif [ "$BRANCH" = "master" ]; then
  if [ "$COMMAND" != "build" ]; then
    echo "В master используйте команду 'build'"
    usage
  fi
  echo "Серверная сборка в master (финальная сборка)"
  flutter build apk --release --dart-define API_URL=http://195.158.18.149:8085/bpla_mobile_service/api/v1/ --dart-define BUILD_SUFFIX=""
  send_telegram "build/app/outputs/flutter-apk/app-release.apk"

else
  echo "Скрипт поддерживает сборку только в ветках develop, staging и master"
  exit 1
fi

read -n 1 -s -r -p "Нажмите любую клавишу для выхода..."
echo
