# Дипломная работа по профессии «Системный администратор» - `Станислав Барановский`

## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/).

## Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible.

Параметры виртуальной машины (ВМ) подбирайте по потребностям сервисов, которые будут на ней работать.

Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и могут влиять друг на друга.

### Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

Протестируйте сайт `curl -v <публичный IP балансера>:80`

### Мониторинг
Создайте ВМ, разверните на ней Prometheus. На каждую ВМ из веб-серверов установите Node Exporter и [Nginx Log Exporter](https://github.com/martin-helmich/prometheus-nginxlog-exporter). Настройте Prometheus на сбор метрик с этих exporter.

Создайте ВМ, установите туда Grafana. Настройте её на взаимодействие с ранее развернутым Prometheus. Настройте дешборды с отображением метрик, минимальный набор — Utilization, Saturation, Errors для CPU, RAM, диски, сеть, http_response_count_total, http_response_size_bytes. Добавьте необходимые [tresholds](https://grafana.com/docs/grafana/latest/panels/thresholds/) на соответствующие графики.

### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

### Сеть
Разверните один VPC. Сервера web, Prometheus, Elasticsearch поместите в приватные подсети. Сервера Grafana, Kibana, application load balancer определите в публичную подсеть.

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Настройте все security groups на разрешение входящего ssh из этой security group. Эта вм будет реализовывать концепцию bastion host. Потом можно будет подключаться по ssh ко всем хостам через этот хост.

### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

### Дополнительно
Не входит в минимальные требования.

1. Для Prometheus можно реализовать альтернативный способ хранения данных — в базе данных PpostgreSQL. Используйте [Yandex Managed Service for PostgreSQL](https://cloud.yandex.com/en-ru/services/managed-postgresql). Разверните кластер из двух нод с автоматическим failover. Воспользуйтесь адаптером с https://github.com/CrunchyData/postgresql-prometheus-adapter для настройки отправки данных из Prometheus в новую БД.
2. Вместо конкретных ВМ, которые входят в target group, можно создать [Instance Group](https://cloud.yandex.com/en/docs/compute/concepts/instance-groups/), для которой настройте следующие правила автоматического горизонтального масштабирования: минимальное количество ВМ на зону — 1, максимальный размер группы — 3.
3. Можно добавить в Grafana оповещения с помощью Grafana alerts. Как вариант, можно также установить Alertmanager в ВМ к Prometheus, настроить оповещения через него.
4. В Elasticsearch добавьте мониторинг логов самого себя, Kibana, Prometheus, Grafana через filebeat. Можно использовать logstash тоже.
5. Воспользуйтесь Yandex Certificate Manager, выпустите сертификат для сайта, если есть доменное имя. Перенастройте работу балансера на HTTPS, при этом нацелен он будет на HTTP веб-серверов.

## Выполнение работы
На этом этапе вы непосредственно выполняете работу. При этом вы можете консультироваться с руководителем по поводу вопросов, требующих уточнения.

**warning** В случае недоступности ресурсов Elastic для скачивания рекомендуется разворачивать сервисы с помощью docker контейнеров, основанных на официальных образах.

**Важно:** Ещё можно задавать вопросы по поводу того, как реализовать ту или иную функциональность. И руководитель определяет, правильно вы её реализовали или нет. Любые вопросы, которые не освещены в этом документе, стоит уточнять у руководителя. Если его требования и указания расходятся с указанными в этом документе, то приоритетны требования и указания руководителя.

## Критерии сдачи
1. Инфраструктура отвечает минимальным требованиям, описанным в [Задаче](https://github.com/netology-code/sys-diplom/blob/main/README.md#Задача).
2. Предоставлен доступ ко всем ресурсам, у которых предполагается веб-страница (сайт, Kibana, Grafanа).
3. Для ресурсов, к которым предоставить доступ проблематично, предоставлены скриншоты, команды, stdout, stderr, подтверждающие работу ресурса.
4. Работа оформлена в отдельном репозитории в GitHub или в [Google Docs](https://docs.google.com/), разрешён доступ по ссылке.
5. Код размещён в репозитории в GitHub.
6. Работа оформлена так, чтобы были понятны ваши решения и компромиссы.
7. Если использованы дополнительные репозитории, доступ к ним открыт.

## Как правильно задавать вопросы дипломному руководителю
Что поможет решить большинство частых проблем:

1. Попробовать найти ответ сначала самостоятельно в интернете или в материалах курса и только после этого спрашивать у дипломного руководителя. Навык поиска ответов пригодится вам в профессиональной деятельности.
2. Если вопросов больше одного, присылайте их в виде нумерованного списка. Так дипломному руководителю будет проще отвечать на каждый из них.
3. При необходимости прикрепите к вопросу скриншоты и стрелочкой покажите, где не получается. Программу для этого можно скачать [здесь](https://app.prntscr.com/ru/).

Что может стать источником проблем:

1. Вопросы вида «Ничего не работает. Не запускается. Всё сломалось». Дипломный руководитель не сможет ответить на такой вопрос без дополнительных уточнений. Цените своё время и время других.
2. Откладывание выполнения дипломной работы на последний момент.
3. Ожидание моментального ответа на свой вопрос. Дипломные руководители — работающие инженеры, которые занимаются, кроме преподавания, своими проектами. Их время ограничено, поэтому постарайтесь задавать правильные вопросы, чтобы получать быстрые ответы :)

---

## Выполнение дипломной работы

**Выбор гостевых операционных систем (ОС) для виртуальных машин (ВМ)**

Выбор состоялся между наиболее стабильными, популярными и свободно раcпространяемыми семействами ОС из доступных на сервисе Yandex Cloud: Debian и CentOS.
Популярность ОС гарантирует техническую поддержку интернет-сообщества пользователей.
Остановился на Debian 11 для всех разворачиваемых ВМ.

**Перечень используемого программного обеспечения (ПО)**

Для создания облачной инфраструктуры в Yandex Cloud использовались следующие продукты:
- Ansible 2.15.1 (ubuntu) / 2.10.8 (debian)
- Python 3.10.6 (ubuntu) / 3.9.2 (debian)
- Terraform 1.5.5 (плюс провайдер: yandex, версия 0.96.1, платформа linux_amd64)
- Yandex Cloud CLI 0.109.0
- sqlite3 3.37.2 (для редактирования файла базы данных Grafana `grafana.db`)
- DB Browser for SQLite 3.12.1 (для удобства наглядного изучения структуры базы данных Grafana `grafana.db`)
- stress 1.0.5 (для тестовой нагрузки центрального процессора, подсистемы памяти и дисковой подсистемы ВМ с целью тестирования подсистемы сбора метрик)

**Структура и описание назначения файлов и каталогов проекта**

1. Корневой каталог проекта.

В корне каталога проекта располагаются файлы bash скриптов создания, конфигурирования и удаления инфраструктуры в облаке.

`INSTALL-cloud-infrastructure` - основной, стартовый файл скрипта создания облачной инфраструктуру с использованием terraform и ansible. Инфраструктура разворачивается от имени сервисной учётной записи с правами editor на каталог. Облако и каталог задаётся через соотвествующие переменны:
```bash
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```

Для разворачивания рабочей инфраструктуры проекта достаточно запустить и дождаться завершения выполнения скрипта `INSTALL-cloud-infrastructure`. Вслучае успешного окончания развёртывания инфраструктуры в конце своей работы скрипт распечатает в терминале список созданных облачных ресурсов и способы доступа к ним.
Необходимым условием запуска скриптов является наличие установленного интерфейса командной строки Yandex Cloud с настроенным профилем сервисного аккаунта и наличие облака (cloud) и каталога в личном аккаунте сервиса Yandex Cloud.

`INSTALL-cloud-infrastructure-cli` - основной, стартовый файл скрипта создания облачной инфраструктуру с использованием интерфейса команд YC CLI. Инфраструктура проекта поднимается в отдельном новом каталоге (VPC) текущего облака и не затрагивает другую существующую инфраструктуру. Облако задаётся в конфигурировании YC CLI (`yc config --help`). Для разворачивания рабочей инфраструктуры проекта достаточно запустить и дождаться завершения выполнения данного скрипта. Вслучае успешного окончания развёртывания инфраструктуры в конце своей работы скрипт распечатает в терминале список созданных облачных ресурсов и способы доступа к ним.
Необходимым условием запуска скриптов является наличие установленного интерфейса командной строки Yandex Cloud и наличие хотя бы одно облака (cloud) в личном аккаунте сервиса Yandex Cloud.

`REMOVE-cloud-infrastructure-cli` - файл bash скрипта удаления инфраструктуры в текущем каталоге/облаке и освобождения тарифицируемых ресурсов. Облако и каталог задаются в конфигурировании YC CLI (`yc config --help`). Как и основной, стартовый файл скрипта так же написаны с использованием интерфейса команд YC CLI.

2. Каталог `ansible`.

Каталог `ansible` содержит:
- конфигурационный файл `ansible.cfg`;
- файлы YAML сценарии (playbook) создания сервисов на ВМ;
- файл инвентаризации (inventary) `hosts`.

Файлы сценарии YAML запускаются на выполнение в bash скриптах создания соотвествующих целевых ВМ и после создания последних. Файл hosts заполняется автоматически при выполнении bash скриптов и по мере создания ВМ в облаке.

3. Каталог `logs`

Каталог `logs` содержит подготовленные конфигурационные файлы Elasticsearch (в одноименном дочернем каталоге), Filebeat (в одноименном дочернем каталоге) и Kibana (в одноименном дочернем каталоге) для копирования на целевые ВМ после разворачивания самих ВМ и соответствующих сервисов на ВМ.

4. Каталог `monitoring`

Каталог `monitoring` содержит подготовленные конфигурационные файлы Prometheus (в одноименном дочернем каталоге), Kibana (в одноименном дочернем каталоге), Node Exporter и Prometheus Nginxlog Exporter и файлы bash скриптов установки Prometheus и Node Exporter в ручной режиме. Конфигурационные файлы копироуются на целевые ВМ после разворачивания самих ВМ и в процессе разворачивания соответствующих сервисов на ВМ.

5. Каталог `notes`

Каталог `notes` содержит текстовые файлы с рабочими заметками и комментариями, возникшими в процессе работы над проектом.

6. Каталог `terraform`

Каталог `terraform` содержит файлы TF сценариев развертывания инфраструктуры в облаке с использованием terraform.

7. Каталог `web`

Каталог `web` содержит:
- подготовленные конфигурационные файлы Nginx (в одноименном дочернем каталоге) - `default` и `nginx.conf`;
- изменённый файл HTML в дочернем каталоге WWW - тестовая страница сайта.

Конфигурационные файлы и HTML файл копироуются на целевые ВМ после разворачивания самих ВМ и в процессе разворачивания web сервиса на ВМ.

8. Каталог `yc_cli`

Каталог `yc_cli` содержит остальные файлы bash скриптов, которые выполняют создание/конфигурирование отдельных ВМ, и создание отдельных специализированных облачных сервисов. Запускаются на выполнение в основном стартовом bash скрипте `INSTALL-cloud-infrastructure-cli`. Так же написаны с использованием интерфейса команд YC CLI.

---

### Сайт

**Требования к ресурсам ВМ (процессор - оперативная память - дисковая подсистема)**

Учитывая, что на ВМ из web группы под управлением ОС Debian будут работать только следующие сервисы:
- сервер Nginx с опубликованной одно статической страницей сайта и с количеством одновременно обслуживаемых клиентов не более 10 шт.;
- клиент сбора логов Filebeat (целевые лог файлы access.log и error.log);
- клиент сбора метрик Node Exporter;
- клиент сбора метрик Prometheus Nginxlog Exporter (целевые лог файлы access.log и error.log).
Требования к аппаратным ресурсам машины минимальны. [Рекомендуемые минимальные аппаратные требования для Debian](https://www.debian.org/releases/bullseye/amd64/ch03s04.ru.html)

Останавливаемся на минимально возможной для выбора на платформе Yandex Cloud аппаратной конфигурации ВМ:
- центральный процессор - 2 ядра;
- подсистема оперативной памяти - 1 ГБ;
- дисковая подсистема - 3 ГБ.

**Порядок развертывания, проверка доступности и работоспособности сервиса**

В соответствии со сценарием развёртывания инфрастуктуры ВМ web сайта создаются после создания ВМ с Elasticsearch. Вслучае динамически назначаемых внутренних адресов ВМ новый IP адрес ВМ с Elasticsearch необходимо прописать в конфигурационный файл `filebeat.yml` (секция output.elasticsearch параметр hosts) клиента Filebeats. Процедура создание L7 балансировщика инициализируется только после подъёма всей web серверов из целевой группы.

Установка и запуск на ВМ клиентов сбора и передачи метрик/логов выполняется после запуска web сервера.

Проверку корректности работы клиентов передачи метрик/логов можно выполнить соответствующими запросами в терминале:
- `curl -XGET '<Локальный_или_публичный_IP_адрес>:9100/metrics'` - для Node Exporter;
- `curl -XGET '<Локальный_или_публичный_IP_адрес>:4040/metrics'` - для Prometheus Nginxlog Exporter;
- `curl -XGET 'localhost:5066/stats'` - для Filebeat (зону доступность статистики можно расширить указав в конфигурационном файле `filebeat.yml` в параметре `http.host` локальный или публичный IP адрес ВМ с клиентом Filebeat)

Проверку корректности работы L7 балансировщика и web серверов (и заодно заполнить логи nginx серверов) можно выполнить соответствующими запросами в терминале:
- `curl -XGET '<Публичный_IP_адрес_балансировщика>:80'` - запрос существующей web страницы;
- `curl -XGET '<Публичный_IP_адрес_алансировщика>:80/fakepath` - запрос не существующей web страницы.

Пример нагрузки ВМ группы web серверов (через публичный IP адрес L7 балансировщика):
```bash
for ((i = 1; i <= 10; i++)); do curl -XGET '51.250.98.136:80'; done
for ((i = 1; i <= 10; i++)); do curl -XGET '51.250.98.136:80/fakepath'; done
```

**Листинг команд с использованием Terraform:**
```bash
###########################
#Создаем два идентичных web сервера
###########################

#Создаём ВМ: vm_web1 и vm_web1
cp -f ~/Thesis-on-the-Profession/terraform/website/main_website.tf ~/Thesis-on-the-Profession/terraform/
cd ~/Thesis-on-the-Profession/terraform/
terraform init
terraform plan
terraform apply -auto-approve

#Запускаем плейбук развертывания web серверов
cd ~/Thesis-on-the-Profession/ansible
ansible-playbook web.yaml

###########################
#Создаём L7 балансировщик для двух web серверов
###########################

#Создаём целевую группу (TG)
#Создаём группу бэкендов (BG)
# - добавляем бэкенд в группу бэкендов (B)
#Создаём HTTP-роутер (router)
# - создаём виртуальный хост (VH)
# - создаём маршрут (route)
#Создаём L7 балансировщик (ALB)
# - добавляем обработчик в балансировщик (listener)

cp -f ~/Thesis-on-the-Profession/terraform/yc-application-load-balancer/alb.tf ~/Thesis-on-the-Profession/terraform/
terraform plan
terraform apply -auto-approve
```
С содержимом файлов сценариев terraform **[main_website.tf](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/tree/main/terraform/website/main_website.tf)**, **[alb.tf](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/tree/main/terraform/yc-application-load-balancer/alb.tf)** и файла YAML сценария **[web.yaml](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/tree/main/ansible/web.yaml)** можно ознакомится подробно.

**Скриншот страницы сайта ( http://51.250.98.136:80/ )**

Страница web-сайта Nginx / L7 балансировщик

![Страница web-сайта Nginx / L7 балансировщик](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/blob/main/README-data/img/web-site.png "Страница web-сайта Nginx / L7 балансировщик")

---

### Мониторинг

**Требования к ресурсам ВМ (процессор - оперативная память - дисковая подсистема)**

Для продукта Prometheus в официальных источниках не увидел минимальных или рекумендуемых требований к аппаратным ресурсам.
Ожидаемо, что требования к ресурсам напрямую зависят от количества опрашиваемых клиентов сбора метрик и от типа и количества самих собираемых метрик.

Для продукта Grafana указаны следующие рекомендации [Hardware recommendations](https://grafana.com/docs/grafana/next/setup-grafana/installation/?src=FB) к оборудованию:
- минимальный рекомендуемый объем памяти: 512 МБ
- минимальный рекомендуемый процессор: 1 ядро

Для Grafana Enterprise Metrics (GEM) указаны следующие рекомендации [GEM hardware requirements](https://grafana.com/docs/enterprise-metrics/latest/setup/hardware/) к оборудованию:
- соотношением процессора (количества ядер) к памяти (в ГБ) 1:4
- хранилище со скоростью 50 операций ввода-вывода на гигабайт при минимальной 150Gi выделеной для обеспечения эффективного ввода-вывода.
- скорость сетевого соединения не ниже 10 Гб/сек

С учетом конфигурации и характеристик создаваемой учебно-тестовой инфраструктуры и, исходя из минимально возможной для выбора на платформе Yandex Cloud аппаратной конфигурации ВМ,
задаем следующие одинаковые планки для ВМ Prometheus и для ВМ Grafana:
- центральный процессор - 2 ядра;
- подсистема оперативной памяти - 2 ГБ;
- дисковая подсистема - 6 ГБ.

**Выбор версий Prometheus и Grafana**

Prometheus

Использовал версию Prometheus 2.45.0 - последнюю на момент начала работ. В процессе работы над дипломным проектом вышла новая версия 2.46.0.

Grafana

Новую на данный момент версию Grafana 10.0.х не рискнул использовал. Остановился на предпоследней стабильной версии 9.5.6. В процессе работы над дипломным проектом вышла версия 9.5.7. Данный факт проигнорировал, т.к. с выходом новой версии могла измениться уже изученная мной структура файла базы данных grafana.db.

Выбор не новой но проверенной и обкатанной версии продукта гарантирует поддержку интернет-сообщества пользователей данного продукта в решении возможных проблем, связанных с установкой или конфигурированием.

**Порядок развертывания, проверка доступности и работоспособности сервиса**

В соответствии со сценарием развёртывания инфрастуктуры ВМ Prometheus и Grafana создаются после создания ВМ web группы. Вслучае динамически назначаемых внутренних адресов ВМ новые IP адреса ВМ web группы, необходимо перечислить в конфигурационный файл `prometheus.yml` (scrape_configs -> job_name -> targets) Prometheus.
Grafana поднимается после разворачивания Prometheus по той же причине. Вслучае динамически назначаемых внутренних адресов ВМ новый IP адрес ВМ Prometheus необходимо указать при первоначальной настроки подключения Grafana к Prometheus или изменить уже сохраненное подключение в файле базы данных `grafana.db` (таблица data_source -> поле url).

После установки Grafana, останавливаем сервис grafana-server, копируем файл `grafana.db` на ВМ в `/var/lib/grafana/`, запукаем сервис. Файл `grafana.db` уже содержит хеш  установленного пароля для пользователя admin (таблица user), предварительно настроенные пользовательские панели (таблица dashboard) и отредактированные параметры подключения к серверу pometheus (таблица data_source). Параметры подключения к серверу pometheus (IP адрес и порт) редактирую в файле grafana.db с помощью консольной утилиты sqlite3 в Ansible Playbook сценарии `monitoring.yaml`.

Примеры запросов к файлу базы данных Grafana:
```bash
sqlite3 ~/Thesis-on-the-Profession/monitoring/grafana/grafana.db "select url from data_source where name='Prometheus'"
sqlite3 ~/Thesis-on-the-Profession/monitoring/grafana/grafana.db "update data_source set url='http://1.2.3.4:9090' where name='Prometheus'"
sqlite3 ~/Thesis-on-the-Profession/monitoring/grafana/grafana.db "select url from data_source where name='Prometheus'"
``` 

Графический интерфейс (GUI) Gafana доступен по адресу: http://<Внешний-IP-ВМ-Grafana>:3000/ .
Авторизация: `admin` / `Grafana123`.

Пароль для встроенной учетной записи admin меняется при первой авторизации в Grafana и хранится в виде хеша в файле базы данных Grafana `grafana.db` (таблица user). Пароль так же можно изменить в командной строке grafana cli `sudo grafana cli admin reset-admin-password 12345`, но только после первой авторизации в GUI. Попытка поменять пароль учетной записи в терминале сразу после первого запуска службы grafana-server приведёт к ошибке.
После прохождения этапа авторизации для открытия предварительно настроенной панели (dashboard) `My Node Exporter` отображения метрик необходимо в GUI пройти по следующим пунктам меню:
"Toggle Menu" (пиктограмма в виде трёх горизонтальных черточек) --> "Dashboards" --> "General" --> "My Node Exporter"

Так же на ВМ Gafana реализована концепция Bastion Host: `ssh <Внешний-IP-ВМ-Grafana>:22` .

При установке и конфигурировании Grafana руководствовался следующими официальными источниками:
- [Порядок установки grafana, edition:oss, version:9.5.6](https://grafana.com/grafana/download/9.5.6?edition=oss)
- [Настройка grafana](https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/)
- [Конфигурация grafana](https://grafana.com/docs/grafana/latest/administration/provisioning/#data-sources)

При установке и конфигурировании Prometheus так же руководствовался офицальныой документацией [Prometheus - Docs](https://prometheus.io/docs/introduction/overview/) .

**Листинг команд с использованием Terraform:**
```bash
###########################
#Создаем ВМ Prometheus и ВМ Grafana
###########################

#Создаём ВМ: vm-prometheus и vm-grafana
cp -f ~/Thesis-on-the-Profession/terraform/monitoring/main_monitoring.tf ~/Thesis-on-the-Profession/terraform/
cd ~/Thesis-on-the-Profession/terraform/
#terraform init
terraform plan
terraform apply -auto-approve

#Запускаем плейбук развертывания Prometheus и Grafana
cd ~/Thesis-on-the-Profession/ansible
ansible-playbook monitoring.yaml --extra-vars="ip_prom=10.128.0.21"

```
С содержимом файла сценария terraform **[main_monitoring.tf](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/tree/main/terraform/monitoring/main_monitoring.tf)** и файла YAML сценария **[monitoring.yaml](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/tree/main/ansible/monitoring.yaml)** можно ознакомится подробно.

**Скриншоты интерфейса Grafana ( http://51.250.74.96:3000/ )**



---

### Логи

**Требования к ресурсам ВМ (процессор - оперативная память - дисковая подсистема)**

На официальном ресурсе Elastic аппаратные требования указаны только для Elastic Cloud Enterprise (ECE) - [Elastic - Hardware Prerequisites](https://www.elastic.co/guide/en/cloud-enterprise/2.13/ece-hardware-prereq.html).

Требования к ресурсам напрямую зависят от количества подключёных клиентов сбора логов и от вида и количества самих логов.

С учетом конфигурации и характеристик создаваемой учебно-тестовой инфраструктуры и, исходя из минимально возможной для выбора на платформе Yandex Cloud аппаратной конфигурации ВМ,
задаем следующие одинаковые планки для ВМ Elasticsearch и для ВМ Kibana:
- центральный процессор - 2 ядра;
- подсистема оперативной памяти - 4 ГБ;
- дисковая подсистема - 8 ГБ.

**Выбор версий Elasticsearch, Filebeat, Kibana**

Не смотря на то, что целом поддерживается совместный запуск и работа различных версий Elasticsearch, Filebeat, Kibana, разработчики ПО Elastic рекомендуют использовать продукты одной и той же версии. [Elastic - Supported Platforms](https://www.elastic.co/guide/en/kibana/7.17/setup.html).

Новую на данный момент версию 8.х стека ELK не использовал. Остановился на последней стабильной версии 7.17.11. Выбор не новой но проверенной и обкатанной версии продукта гарантирует поддержку интернет-сообщества пользователей данного продукта в решении проблем, связанных с установкой или конфигурированием.

Доступ к ресурсам Elastic на территории РФ ограничен.
Скачал установочные пакеты Filebeat, Elasticsearch и Kibana версии 7.17.11 с официального ресурса с использованием в web браузере прокси-аддона(proxy-addon). 
Скачанные DEB пакеты разместил на яндекс.диске и в Ansible Playbook сценариях по прямым ссылкам скачивал и устанавливал продукты на ВМ в облаке. 

**Порядок развертывания, проверка доступности и работоспособности сервиса**

В соответствии со сценарием развёртывания инфрастуктуры ВМ Elasticsearch и Kibana создаются первыми. Вслучае динамически назначаемых внутренних адресов ВМ новый IP адрес ВМ с Elasticsearch необходимо прописать в конфигурационный файл `filebeat.yml` (секция output.elasticsearch параметр hosts) клиентов Filebeats, устанавливаемых на ВМ в облаке.

Графический интерфейс (GUI) Kibana доступен по адресу: http://<Внешний-IP-ВМ-Kibana>:5601/ .
Авторизация: `elastic` / `Elastic123`.

Пароль для втроенных учетных записей Elasticsearch, включая elastic и kibana_system, меняется в Ansible Playbook сценарии `logs.yaml`
После прохождения этапа авторизации для просмотра логов необходимо в GUI пройти по следующим пунктам меню:
Пиктограмма в виде трёх горизонтальных черточек --> "Observability" --> "Logs" --> "Stream"
Для подключения панели отображения логов Nginx необходимо в GUI Kibana выполнить следующее:
Пиктограмма в виде трёх горизонтальных черточек --> "Analytics" --> "Dashboard" --> в строке поиска набрать и выбрать панель "[Filebeat Nginx] Access and error logs ECS" 

**Листинг команд с использованием Terraform:**
```bash
###########################
#Создаем ВМ Elasticsearch и ВМ Kibana
###########################

#Создаём ВМ: vm-elastic и vm-kibana
cp -f ~/Thesis-on-the-Profession/terraform/log-collection/main_log-collection.tf ~/Thesis-on-the-Profession/terraform/
cd ~/Thesis-on-the-Profession/terraform/
#terraform init
terraform plan
terraform apply -auto-approve

#Запускаем плейбук развертывания Elasticsearch и Kibana
cd ~/Thesis-on-the-Profession/ansible
ansible-playbook logs.yaml
```

С содержимом файла сценария terraform **[main_log-collection.tf](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/tree/main/terraform/log-collection/main_log-collection.tf)** и файла YAML сценария **[logs.yaml](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/tree/main/ansible/logs.yaml)** можно ознакомится подробно.

**Скриншоты интерфейса Kibana ( http://158.160.57.84:5601/ )**

Логи от Elasticsearch (IP 10.128.0.31)

![Логи Filebeat от Elasticsearch. IP 10.128.0.31](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/blob/main/README-data/img/kibana-log-elasticsearch.png "Логи от Elasticsearch (IP 10.128.0.31)")

Логи от Kiban (IP 10.128.0.32):

![Логи Filebeat от Kiban (IP 10.128.0.32)](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/blob/main/README-data/img/kibana-log-kibana.png "Логи от Kibana (IP 10.128.0.32)")

Логи от Prometheus (IP 10.128.0.21)

![Логи Filebeat от Prometheus (IP 10.128.0.21)](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/blob/main/README-data/img/kibana-log-prometheus.png "Логи от Prometheus (IP 10.128.0.21)")

Логи от Grafana (IP 10.128.0.22):

![Логи Filebeat от Grafana (IP 10.128.0.22)](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/blob/main/README-data/img/kibana-log-grafana.png "Логи от Grafana (IP 10.128.0.22)")

Дашбоард логов от web серверов Nginx (IP 10.128.0.11 и 10.129.0.11)

![Дашбоард логов от web серверов Nginx (IP 10.128.0.11 и 10.129.0.11)](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/blob/main/README-data/img/kibana-dashboard.png "Логи от web-серверов (IP 10.128.0.11 и 10.129.0.11)")

---

### Сеть

**Разворачиваем один VPC**

Virtual Private Cloud (VPC) - представляет собой отдельный каталог (folder) в облаке с созданой внутри каталога сетью (network) и подсетью (subnet).

> Предполагается, что:
> - интерфейс командной строки Yandex Cloud уже установлен и
> - в личном аккаунте сервиса Yandex Cloud уже существует хотя бы одно облако (cloud) и каталог (folder) в облаке.

Код разворичивания VPC размещён в TF файле `terraform/network_subnet.tf`.

В текущем каталоге создаём сеть `default` и в ней две подсети: `default-ru-central1-a` и `default-ru-central1-b`. Имя подсети состоит из префикса - имя сети (network) и суфикса - имя зоны доступности (zone). Размер подсети (range) выбираем с учётом планируемого колличества работающих в данной подсети ВМ (плюс шлюз и плюс DNS). Диапазоны различных подсетей в границах одной сети не должны пересекаться [cloud.yandex.ru/docs](https://cloud.yandex.ru/docs/vpc/concepts/network). Имена сети, подсетей и значения размеров подсетей оставил в значениях, используемх по умолчанию.
По окончании работ удаляем созданную инфраструктуру в текущем каталогом, не затрагивая другую существующую в облаке инфраструктуру (bash скрипт `REMOVE-cloud-infrastructure-cli`).

С содержимом файла сценария terraform **[network_subnet.tf](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/tree/main/terraform/network_subnet.tf)** можно ознакомится подробно.

**Создание групп безопасности (Security Groups) и реализация концепции Bastion Host**

Группы безопасности действуют по принципу «запрещено все, что не разрешено». Если назначить сетевому интерфейсу ВМ группу безопасности без правил, ВМ не сможет передавать и принимать трафик ([cloud.yandex.ru/docs](https://cloud.yandex.ru/docs/vpc/concepts/security-groups)).
Если в группе безопасности существует только правило для исходящего трафика, но нет правил для входящего трафика, ответный трафик все равно сможет поступать на ВМ. Если в группе безопасности есть только правила для входящего трафика, ВМ сможет только отвечать на запросы, но не инициировать их ([cloud.yandex.ru/docs](https://cloud.yandex.ru/docs/vpc/concepts/security-groups)).

Код создания групп размещён в TF файле `terraform/yc-security-groups/yc_sg.tf`.

Создаём следующие группы безопасности (Security Groups)
1. Группа безопасности `sg-web` для двух ВМ с web серверами - сайт:
- входящий трафик на порт 80 по TCP с любого ip (CIDR 0.0.0.0/0) - доступ к сайту по HTTP
- входящий трафик на порт 9100 по TCP с внутреннего ip (CIDR 10.128.0.0/16,10.129.0.0/16) - доступ к Node Exporter из двух подсетей
- входящий трафик на порт 4040 по TCP с внутреннего ip (CIDR 10.128.0.0/16,10.129.0.0/16) - доступ к Nginx Log Exporter из двух подсетей
- входящий трафик: добавляем предустановленное правило loadbalancer_healthchecks - для проверки состояния балансировщика
- входящий трафик на порт 22 по TCP(SSH) с внутреннего ip vm-grafana (bastion) (CIDR 10.128.0.22/32) - доступ по SSH только из внутренней сети и только с одного хоста
- исходящий трафик на порт 9200 по TCP на внутренний ip (CIDR 10.128.0.0/16) - логи от Filebeat к Elasticsearch (подсеть зоны А)

2. Группа безопасности `sg-prometheus` для ВМ с Prometheus:
- входящий трафик на порт 9090 по TCP с внутреннего ip (CIDR 10.128.0.0/16) - доступ к Prometheus из подсети зоны А
- входящий трафик на порт 22 по TCP(SSH) с внутреннего ip vm-grafana (bastion) (CIDR 10.128.0.22/32) - доступ по SSH только из внутренней сети и только с одного хоста
- исходящий трафик на порт 9100 по TCP на внутренний ip (CIDR 10.128.0.0/16,10.129.0.0/16) - запросы от Prometheus к Node Exporter в две подсети
- исходящий трафик на порт 4040 по TCP на внутренний ip (CIDR 10.128.0.0/16,10.129.0.0/16) - запросы от Prometheus к Nginx Log Exporter в две подсети
- исходящий трафик на порт 9200 по TCP на внутренний ip (CIDR 10.128.0.0/16) - логи от Filebeat к Elasticsearch (подсеть зоны А)

3. Группа безопасности `sg-grafana` для ВМ с Grafana и с ролью Bastion Host:
- входящий трафик на порт 3000 по TCP с любого ip (CIDR 0.0.0.0/0) - доступ к GUI
- входящий трафик на порт 22 по TCP(SSH) с любого ip (CIDR 0.0.0.0/0) - доступ по SSH из любой сети (Bastion Host)
- исходящий трафик на порт 22 по TCP(SSH) на внутренний ip (CIDR 10.128.0.0/16,10.129.0.0/16) - подключение к любой ВМ в двух подсетях (Bastion Host)
- исходящий трафик на порт 9100 по TCP на внутренний ip (CIDR 10.128.0.0/16) - подключение к Prometheus (подсеть зоны А)
- исходящий трафик на порт 9200 по TCP на внутренний ip (CIDR 10.128.0.0/16) - логи от Filebeat к Elasticsearch (подсеть зоны А)

4. Группа безопасности `sg-elastic` для ВМ Elasticsearch:
- входящий трафик на порт 22 по TCP(SSH) с внутреннего ip vm-grafana (bastion) (CIDR 10.128.0.22/32) - доступ по SSH только из внутренней сети и только с одного хоста
- входящий трафик на порт 9200 по TCP на внутренний ip (CIDR 10.128.0.0/16,10.129.0.0/16) - логи от Filebeat к Elasticsearch из двух подсетей
- иходящий трафик на порт 5601 по TCP с внутреннего ip (CIDR 10.128.0.0/16) - доступ к Kibana

5. Группа безопасности `sg-kibana` для ВМ Kibana:
- входящий трафик на порт 22 по TCP(SSH) с внутреннего ip vm-grafana (bastion) (CIDR 10.128.0.22/32) - доступ по SSH только из внутренней сети и только с одного хоста
- входящий трафик на порт 5601 по TCP с любого ip (CIDR 0.0.0.0/0) - доступ к GUI
- исходящий трафик на порт 9200 по TCP на внутренний ip (CIDR 10.128.0.0/24) - логи от Filebeat к Elasticsearch

Для реализации роли Bastion Host (возможность доступа по SSH с одной ВМ на остальные ВМ в VPC) необходимо скопировать используемые для авторизации по SSH пару ключей на ВМ Grafana.
Копирование публичного ключа выполняется на этапе создания ВМ.  Копирование приватного ключа выполняется в ansible playbook сценарии `monitoring.yaml`

**Листинг команд с использованием Terraform:**
```bash
###########################
#Создаем ВМ SG и назначаем на интерфейсы ВМ
#Освобождаем не используемые публичные IP-адреса 
###########################

# создаём группы безопасности sg-web, sg-prometheus, sg-grafana, sg-elastic, sg-kibana
cp -f ~/Thesis-on-the-Profession/terraform/yc-security-groups/yc_sg.tf ~/Thesis-on-the-Profession/terraform/
cd ~/Thesis-on-the-Profession/terraform/
#terraform init
terraform plan
terraform apply -auto-approve

# подключаем группу безопасности sg-web к сетевому интерфейсу ВМ vm-web1 и vm-web2. Освободдаем публичные IP.
# подключаем группу безопасности sg-prometheus к сетевому интерфейсу ВМ vm-prometheus. Освободдаем публичные IP.
# подключаем группу безопасности sg-grafana к сетевому интерфейсу ВМ vm-grafana
# подключаем группу безопасности sg-elastic к сетевому интерфейсу ВМ vm-elastic. Освободдаем публичные IP.
# подключаем группу безопасности sg-kibana к сетевому интерфейсу ВМ vm-kibana. Освободдаем публичные IP.
cp -f ~/Thesis-on-the-Profession/terraform/yc-security-groups/main_log-collection.tf ~/Thesis-on-the-Profession/terraform/
cp -f ~/Thesis-on-the-Profession/terraform/yc-security-groups/main_website.tf ~/Thesis-on-the-Profession/terraform/
cp -f ~/Thesis-on-the-Profession/terraform/yc-security-groups/main_monitoring.tf ~/Thesis-on-the-Profession/terraform/
cd ~/Thesis-on-the-Profession/terraform/
#terraform init
terraform plan
terraform apply -auto-approve

```
С содержимом файлов сценариев terraform можно ознакомится подробно:
- **[yc_sg.tf](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/tree/main/terraform/yc-security-groups/yc_sg.tf)**
- **[main_website.tf](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/tree/main/terraform/yc-security-groups/main_website.tf)**
- **[main_monitoring.tf](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/tree/main/terraform/yc-security-groups/main_monitoring.tf)**
- **[main_log-collection.tf](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/tree/main/terraform/yc-security-groups/main_log-collection.tf)**

---

### Резервное копирование

Создал расписание (snapshot-schedule) `project-snapshot-schedule` создания снимков (snapshot): снимки создаются ежедневно в 03:10 (UTC+3) или 0:10 (UTC+0), срок хранения снимков 1-а неделя (168 часов).
Процесс создания и добавления реализован в файле TF `terraform/yc-snapshots/yc_snapshot_schedule.tf`

**Листинг команд с использованием Terraform:**
```bash
###########################
#Создаем ВМ SG и назначаем на интерфейсы ВМ
#Освобождаем не используемые публичные IP-адреса 
###########################

# создаём расписание project-snapshot-schedule
# добавляем в расписание project-snapshot-schedule диски ВМ
cp -f ~/Thesis-on-the-Profession/terraform/yc-snapshots/yc_snapshot_schedule.tf ~/Thesis-on-the-Profession/terraform/
#terraform init
terraform plan
terraform apply -auto-approve

```

С содержимом файла сценария terraform **[yc_snapshot_schedule.tf](https://github.com/StanislavBaranovskii/Thesis-on-the-Profession/tree/main/terraform/yc-snapshots/yc_snapshot_schedule.tf)** можно ознакомится подробно.

Перед созданием снимка диска ВМ необходимо, на время создания снимка, остановить ВМ.
Или для Linux подобных ОС для не системных дисков:
1. Остановить все сервисы/приложения, выполняющие операции записи на диск;
2. Записать кэш ОС на диск - `sync`;
3. Заморозит файловую систему (ФС) - `sudo fsfreeze --freeze <точка_монтирования_ФС>`;
4. Выполнить создание снимока диска;
5. Разморозить ФС - `sudo fsfreeze --unfreeze <точка_монтирования>`.
[cloud.yandex.ru/docs](https://cloud.yandex.ru/docs/compute/operations/disk-control/create-snapshot)
Но поскольку сервис Yandex Cloud, при большой нагрузки на сервис, не регламентирует время выполнения создания снимка ([cloud.yandex.ru/docs](https://cloud.yandex.ru/docs/compute/concepts/snapshot-schedule)) то ВМ перед созданием снимка не останавливаем.

---
