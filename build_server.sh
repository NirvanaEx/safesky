#!/bin/bash
set -e

# Ловушка для ошибок (в CI не ждём ввода)
trap 'echo -e "\nОшибка произошла. Завершаем работу..."; exit 1' ERR

usage() {
  echo "Usage:"
  echo "  ./build_server.sh build [flag]"
  echo "Примеры:"
  echo "  В develop:  build -t или build -p"
  echo "  В staging:  build -t или build -p"
  echo "  В master:   build (без флага)"
  exit 1
}

COMMAND=${1:-build}
FLAG=${2:-}

BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Текущая ветка: $BRANCH"

# Подтягиваем теги, чтобы они были доступны в CI
git fetch --tags

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
    echo "Тег не содержит SUFFIX (флаг не определён)."
    if [[ "$BRANCH" == "develop" || "$BRANCH" == "staging" ]]; then
      FLAG="-t"
      echo "Используем значение по умолчанию: $FLAG"
    fi
  fi
fi

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
elif [ "$BRANCH" = "master" ]; then
  if [ "$COMMAND" != "build" ]; then
    echo "В master используйте команду 'build'"
    usage
  fi
  echo "Серверная сборка в master (финальная сборка)"
  flutter build apk --release --dart-define API_URL=http://195.158.18.149:8085/bpla_mobile_service/api/v1/ --dart-define BUILD_SUFFIX=""
  SUFFIX=""
else
  echo "Скрипт поддерживает сборку только в ветках develop, staging и master"
  exit 1
fi

# Переименование APK:
# Извлекаем версию из pubspec.yaml (до знака '+')
PACKAGE_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)
if [ "$BRANCH" = "master" ]; then
  NEW_FILENAME="atm_safesky_v.${PACKAGE_VERSION}.apk"
else
  NEW_FILENAME="atm_safesky_v.${PACKAGE_VERSION}${SUFFIX}.apk"
fi
APK_SOURCE="build/app/outputs/flutter-apk/app-release.apk"
APK_TARGET="build/app/outputs/flutter-apk/${NEW_FILENAME}"
if [ -f "$APK_SOURCE" ]; then
  mv "$APK_SOURCE" "$APK_TARGET"
  echo "APK переименован в: $NEW_FILENAME"
else
  echo "Файл APK не найден по пути: $APK_SOURCE"
fi

# Определяем подпись для Telegram: используем последний тег для develop/staging, для master – версию из pubspec
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ "$BRANCH" = "master" ]; then
  FINAL_CAPTION="v${PACKAGE_VERSION}"
else
  FINAL_CAPTION="$LAST_TAG"
fi

send_telegram() {
  APK_PATH=$1
  CAPTION=$2
  echo "Отправка APK в Telegram с подписью: $CAPTION"
  curl -F chat_id=${TELEGRAM_CHAT_ID} \
       -F caption="$CAPTION" \
       -F document=@"${APK_PATH}" \
       "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument"
}

send_telegram "$APK_TARGET" "$FINAL_CAPTION"

echo "Сборка завершена успешно."
