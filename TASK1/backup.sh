#!/bin/bash

# Переменные для путей
DB_PATH="./app/db_data/db.sqlite3"
REMOTE_USER="root"
REMOTE_SERVER="192.168.190.154"
REMOTE_DIR="/project/db_backup"
REMOTE_PATH="${REMOTE_DIR}/$(date +%F_%H-%M)_db.sqlite3"
CRON_PATH="/tmp/backup.sh"

# Функция для копирования базы данных
backup_db() {
  echo "Создание бэкапа базы данных..."

  # Создаем директорию на удаленном сервере, если её нет
  ssh ${REMOTE_USER}@${REMOTE_SERVER} "mkdir -p ${REMOTE_DIR}"

  # Отправляем файл на удаленный сервер
  scp $DB_PATH ${REMOTE_USER}@${REMOTE_SERVER}:${REMOTE_PATH}
  if [[ $? -ne 0 ]]; then
    echo "Ошибка: не удалось отправить файл на удаленный сервер!"
    exit 1
  fi

  echo "Бэкап отправлен на удаленный сервер: ${REMOTE_USER}@${REMOTE_SERVER}:${REMOTE_PATH}"
}

# Функция для настройки cron
setup_cron() {
  echo "Настройка cron для выполнения бэкапов каждую неделю..."

  # Строка для добавления в cron
  CRON_JOB="0 3 * * 1 bash $CRON_PATH -b >> /var/log/cron.log 2>&1"
  
  # Добавляем задачу в cron (удаляем старую, если она была)
  (crontab -l | grep -v "$CRON_PATH"; echo "$CRON_JOB") | crontab -
  if [[ $? -ne 0 ]]; then
    echo "Ошибка: не удалось настроить cron!"
    exit 1
  fi
  echo "Задача cron настроена на запуск бэкапов каждую неделю в понедельник в 3 утра."
}

# Логика обработки флагов
if [[ "$1" == "-c" ]]; then
  setup_cron
  exit 0
elif [[ "$1" == "-b" ]]; then
  backup_db
  exit 0
else
  # Если флагов нет — выполняем обе задачи
  setup_cron
  backup_db
fi

