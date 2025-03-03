#!/bin/bash
set -e

# Ловушка для ошибок (в CI не ждём ввода)
trap 'echo -e "\nОшибка произошла. Завершаем работу..."; exit 1' ERR

usage() {
  echo "Usage:"
  echo "  ./build_server.sh build <flag>"
  echo "Флаги:"
  echo "  -at, -ap, -bt, -bp, -t, -p"
  exit 1
}

COMMAND=${1:-build}
FLAG=$2

# Если флаг не указан (например, при push-событии), пытаемся извлечь его из тега на HEAD
if [ -z "$FLAG" ]; then
  EXISTING_TAG=$(git tag --points-at HEAD | grep '^v' | head -n 1)
  if [ -n "$EXISTING_TAG" ]; then
    # Извлекаем суффикс: если тег вида v<версия><суффикс> (например, v2.7.41.165ap),
    # то извлекается часть из букв (если отсутствует – пустая)
    EXTRACTED_SUFFIX=$(echo "$EXISTING_TAG" | sed -E 's/^v[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+([a-z]+)?$/\1/')
    if [ -n "$EXTRACTED_SUFFIX" ]; then
      FLAG="-$EXTRACTED_SUFFIX"
    else
      FLAG="-p"
    fi
  else
    FLAG="-at"
  fi
fi

# Работаем только в ветке develop
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Текущая ветка: $BRANCH"
if [ "$BRANCH" != "develop" ]; then
  echo "Скрипт поддерживает сборку только из ветки develop"
  exit 1
fi

case "$FLAG" in
  -at)
    SUFFIX="at"
    API_URL="http://91.213.31.234:8898/bpla_mobile_service/api/v1/"
    ;;
  -ap)
    SUFFIX="ap"
    API_URL="http://195.158.18.149:8085/bpla_mobile_service/api/v1/"
    ;;
  -bt)
    SUFFIX="bt"
    API_URL="http://91.213.31.234:8898/bpla_mobile_service/api/v1/"
    ;;
  -bp)
    SUFFIX="bp"
    API_URL="http://195.158.18.149:8085/bpla_mobile_service/api/v1/"
    ;;
  -t)
    SUFFIX="t"
    API_URL="http://91.213.31.234:8898/bpla_mobile_service/api/v1/"
    ;;
  -p)
    SUFFIX=""
    API_URL="http://195.158.18.149:8085/bpla_mobile_service/api/v1/"
    ;;
  *)
    echo "Неверный флаг: $FLAG"
    usage
    ;;
esac

echo "Серверная сборка с BUILD_SUFFIX=$SUFFIX"
flutter build apk --release --dart-define API_URL=${API_URL} --dart-define BUILD_SUFFIX=${SUFFIX}

# Извлекаем версию из pubspec.yaml и оставляем только числовую часть
FULL_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
NUMERIC_VERSION=$(echo "$FULL_VERSION" | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+\+[0-9]+).*/\1/')
PROCESSED_VERSION=$(echo "$NUMERIC_VERSION" | sed 's/+/./')

if [ -z "$SUFFIX" ]; then
  NEW_FILENAME="atm_safesky_v.${PROCESSED_VERSION}.apk"
else
  NEW_FILENAME="atm_safesky_v.${PROCESSED_VERSION}${SUFFIX}.apk"
fi
APK_SOURCE="build/app/outputs/flutter-apk/app-release.apk"
APK_TARGET="build/app/outputs/flutter-apk/${NEW_FILENAME}"
if [ -f "$APK_SOURCE" ]; then
  mv "$APK_SOURCE" "$APK_TARGET"
  echo "APK переименован в: $NEW_FILENAME"
else
  echo "Файл APK не найден по пути: $APK_SOURCE"
fi

# Формирование подписи для Telegram на основе версии и переданного SUFFIX
if [ -z "$SUFFIX" ]; then
  FINAL_CAPTION="v${PROCESSED_VERSION}"
else
  FINAL_CAPTION="v${PROCESSED_VERSION}${SUFFIX}"
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
