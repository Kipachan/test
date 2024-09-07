1. Dockerfile и docker-compose для приложения на Python
В качестве приложения было использовано FastUI-SQLModel-Demo.

База данных сохраняет результаты в директории ./app/db_data на сервере (относительный путь от расположения docker-compose файла).
Мониторинг настроен с использованием Grafana и Prometheus. Для сбора метрик используются:
node-exporter (в отдельном контейнере)
prometheus-fastapi-instrumentator (для сбора метрик с приложения).

Функция бэкапирования осуществляется с помощью скрипта backup.sh, который настраивается через cron на сервере.    
Для настройки cron необходимо актуализировать переменную CRON_PATH в скрипте и затем запустить его с флагом -c (например, bash ./backup.sh -c).
Для выполнения бэкапа вручную используйте флаг -b (обязательно актуализируйте переменные в скрипте перед запуском).
Без флагов скрипт выполнит обе функции: настройку cron и создание бэкапа. Бэкап осуществляется путем копирования файла базы данных на удаленный сервер через scp. На сервере должен быть установлен публичный ключ удаленного хоста.
Функция бэкапа не настроена в контейнере, так как база данных сохраняется на сервере, и это не имеет смысла в контейнере.

В проекте используются две сети:
app-network (для контейнера с приложением)
monitoring (для контейнеров мониторинга).

Скрипт мониторинга res_mon.py собирает данные об утилизации CPU и оперативной памяти и выводит результаты на экран. Он использует библиотеку psutil, которая обеспечивает более точные данные по сравнению с сбором данных через ps или напрямую из /proc в bash-скрипте. Скрипт можно было бы подключить к Grafana, но так как уже используется node-exporter, в этом нет необходимости.

2. GitLab CI для выполнения команды nmap и отправки результата через API
Джоб отправляет результаты сканирования через API в существующий Engagement на DefectDojo. ID Engagement нужно указать в переменной. Функция создания Engagements в джобе не включена. При необходимости могу добавить.

3. Ansible Playbook для удаленной машины с Ubuntu
Playbook выполняет следующие действия:

Устанавливает пакеты nginx, python3 и python3-pip.
Запускает службу nginx и настраивает её автоматический запуск при загрузке системы.
Копирует файл конфигурации nginx из локального компьютера в /etc/nginx/sites-available/default на удаленной машине.
Создает нового пользователя с именем testuser и паролем password.
Добавляет testuser в группу sudo.
Обновляет все установленные пакеты до последних версий.
Для хранения секретов используется vault (пароль: password). На всякий случай приложил расшифрованный файл (decrypted_vault.yml).
