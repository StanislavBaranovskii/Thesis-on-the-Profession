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
- Ansible 2.15.1
- Python 3.10.6
- Yandex Cloud CLI 0.108.1 (как альтернатива заблокированному продукту Terraform)
- *Terraform 1.5.3*
- sqlite3 3.37.2 (для редактирования файла базы данных Grafana `grafana.db`)
- DB Browser for SQLite 3.12.1 (для удобства наглядного изучения структуры базы данных Grafana `grafana.db`)
- stress 1.0.5 (для тестовой нагрузки центрального процессора, подсистемы памяти и дисковой подсистемы ВМ с целью тестирования подсистемы сбора метрик)

Проблема в использовании Terraform связана проблема в настройке провайдера - при выполнении сценариев идёт проверка провайдера с обращением на заблокированные на территории РФ интернет ресурсы `terraform.io` и `hashicorp.com`.
Написание файлов-скриптов на bash, с применением Yandex Cloud CLI, для разворачивания облачной инфраструктуры в качестве альтернативы заблокированного на территории РФ продукта Terraform не противоречит основной идеи модели Инфраструктура-как-Код (Infrastructure as Code, IaC). 

**Структура и описание назначения файлов и каталогов проекта**

1. Корневой каталог проекта.

В корне каталога проекта располагаются файлы bash скриптов создания, конфигурирования и удаления инфраструктуры в облаке.

`INSTALL-cloud-infrastructure` - основной, стартовый файл скрипта создания облачной инфраструктуру. Инфраструктура проекта поднимается в отдельном новом каталоге (VPC) текущего облака и не затрагивает другую существующую инфраструктуру. Облако задаётся в конфигурировании YC CLI (`yc config --help`). Для разворачивания рабочей инфраструктуры проекта достаточно запустить и дождаться завершения выполнения данного скрипта.

`REMOVE-cloud-infrastructure` - файл bash скрипта удаления инфраструктуры в текущем каталоге/облаке и освобождения тарифицируемых ресурсов. Облако и каталог задаются в конфигурировании YC CLI (`yc config --help`).

Остальные файлы bash скриптов выполняют создание/конфигурирование отдельных ВМ, и создание отдельных специализированных облачных сервисов. Запускаются на выполнение в основном стартовом bash скрипте.

2. Каталог `ansible`.

Каталог `ansible` содержит файлы YAML сценарии (playbook) создания сервисов на ВМ и файл инвентаризации (inventary) host. Файл host заполняется автоматически при выполнении bash скриптов и по мере создания ВМ в облаке. Файлы сценарии YAML запускаются на выполнение в bash скриптах разворачивания соотвествующих целевых ВМ и после создания последних.

3. Каталог `logs`

Каталог `logs` содержит подготовленные конфигурационные файлы Elasticsearch, Filebeat и Kibana для копирования на целевые ВМ после разворачивания самих ВМ и соответствующих сервисов на ВМ.

4. Каталог `monitoring`

Каталог `monitoring` содержит подготовленные конфигурационные файлы Prometheus (в одноименном дочернем каталоге), Kibana (в одноименном дочернем каталоге), Node Exporter и Prometheus Nginxlog Exporter и файлы bash скриптов установки Prometheus и Node Exporter. Конфигурационные файлы копироуются на целевые ВМ после разворачивания самих ВМ и в процессе разворачивания соответствующих сервисов на ВМ.

5. Каталог `notes`

Каталог `notes` содержит текстовые файлы с рабочими заметками и комментариями, возникшими в процессе работы над проектом.

*6. Каталог `terraform`*

7. Каталог `web`

Каталог `web` содержит подготовленные конфигурационные файлы Nginx (в одноименном дочернем каталоге) и изменённый файл HTML в дочернем каталоге WWW - тестовая страница сайта. Конфигурационные файлы и HTML файл копироуются на целевые ВМ после разворачивания самих ВМ и в процессе разворачивания web сервиса на ВМ.

---

### Сайт

**Требования к ресурсам ВМ (процессор - оперативная память - дисковая подсистема)**

Учитывая, что на ВМ из web группы под управлением ОС Debian будут работать только следующие сервисы:
- сервер Nginx с опубликованной одно статической страницей сайта;
- клиент сбора логов Filebeat;
- клиент сбора метрик Node Exporter;
- клиент сбора метрик Prometheus Nginxlog Exporter.
Требования к аппаратным ресурсам машины минимальны. [Рекомендуемые минимальные аппаратные требования для Debian](https://www.debian.org/releases/bullseye/amd64/ch03s04.ru.html)

Останавливаемся на минимально возможной для выбора на платформе Yandex Cloud аппаратной конфигурации ВМ:
- центральный процессор - 2 ядра;
- подсистема оперативной памяти - 1 ГБ;
- дисковая подсистема - 3 ГБ.




*Что касается объема памяти, то практически невозможно дать какие-то общие рекомендации, все слишком индивидуально для каждой системы и поставленных задач. Как показала практика, в среднем для сервера баз данных должно хватить 256 мегабайт на нужды операционной системы, примерно по 64 мегабайта на каждого активно работающего с базой пользователя плюс не менее половины от объема самой базы данных.*

Для работы web-сервера...
Nginx плюс, по условию задания, клиенты мониторинга Node Exporter, Nginx Log Exporter, плюс клиент сбора логов Filebeat

Проверка корректности работы клиентов передачи метрик/логов:
curl -XGET '<Внутренний_или_внешний_IP>:9100/metrics'
curl -XGET '<Внутренний_или_внешний_IP>:4040/metrics'
curl -XGET 'localhost:5066/stats'


```bash
for ((i = 1; i <= 10; i++)); do curl -XGET '130.193.37.98:80'; done
for ((i = 1; i <= 10; i++)); do curl -XGET '130.193.37.98:80/testtest'; done
```

```bash

```

---

### Мониторинг

Требования к ресурсам ВМ (процессор - оперативная память - дисковая подсистема).

Выбор версий Prometheus и Grafana

Новую на данный момент версию 10.0.х не рискнул использовал. Остановился на последней стабильной версии 9.5.6 (в процессе написания дипломной работы вышла версия 9.5.7). Выбор не новой но проверенной и обкатанной версии продукта гарантирует поддержку интернет-сообщества пользователей данного продукта в решении проблем, связанных с установкой или конфигурированием.


При установке и конфигурировании Grafana руководствовался следующими официальными источниками:
- [Порядок установки grafana, edition:oss, version:9.5.6](https://grafana.com/grafana/download/9.5.6?edition=oss)
- [Настройка grafana](https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/)
- [Конфигурация grafana](https://grafana.com/docs/grafana/latest/administration/provisioning/#data-sources)

После установки Grafana, останавливаем сервис grafana-server, копируем файл grafana.db на ВМ в /var/lib/grafana/ , запукаем сервис. Файле grafana.db уже содержит хеш  установленного пароля для пользователя admin (таблица user), предварительно настроенные пользовательские панели (таблица dashboard) и отредактированные параметры подключения к серверу pometheus (таблица data_source). Параметры подключения к серверу pometheus (IP адрес и порт) редактирую в файле grafana.db с помощью консольной утилиты sqlite3 в Ansible Playbook сценарии `monitoring.yaml` (bash скрипт cloud-monitoring-install).
Примеры запросов к файлу базы данных Grafana:
```bash
sqlite3 ~/Thesis-on-the-Profession/monitoring/grafana/grafana.db "select url from data_source where name='Prometheus'"
sqlite3 ~/Thesis-on-the-Profession/monitoring/grafana/grafana.db "update data_source set url='http://1.2.3.4:9090' where name='Prometheus'"
sqlite3 ~/Thesis-on-the-Profession/monitoring/grafana/grafana.db "select url from data_source where name='Prometheus'"
``` 

Графический интерфейс (GUI) Gafana доступен по адресу: http://<Внешний-IP-ВМ-Grafana>:3000/
Авторизация: admin / Grafana123
Пароль для встроенной учетной записи admin меняется при первой авторизации в Grafana и хранится в виде хеша в файле базы данных Grafana `grafana.db` (таблица user). Пароль так же можно изменить в командной строке grafana cli `sudo grafana cli admin reset-admin-password 12345`, но только после первой авторизации в GUI.
После прохождения этапа авторизации для открытия предварительно настроенной панели (dashboard) `My Node Exporter` отображения метрик необходимо в GUI пройти по следующим пунктам меню:
"Toggle Menu" (пиктограмма в виде трёх горизонтальных черточек) --> "Dashboards" --> "General" --> "My Node Exporter"

[Порядок установки grafana, edition:oss, version:9.5.6](https://grafana.com/grafana/download/9.5.6?edition=oss)

[Настройка grafana](https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/)
[Конфигурация grafana](https://grafana.com/docs/grafana/latest/administration/provisioning/#data-sources)

---

### Логи

Требования к ресурсам ВМ (процессор - оперативная память - дисковая подсистема).

Выбор версий Filebeat, Elasticsearch, Kibana.

Новую на данный момент версию 8.х стека ELK не использовал. Остановился на последней стабильной версии 7.17.11. Выбор не новой но проверенной и обкатанной версии продукта гарантирует поддержку интернет-сообщества пользователей данного продукта в решении проблем, связанных с установкой или конфигурированием.
Доступ к ресурсам на территории РФ заблокирован...
Скачал установочные пакеты Filebeat, Elasticsearch и Kibana с официального ресурса с использованием...
Скачанные установочные пакеты разместил на яндекс.диске и в Ansible Playbook сценариях по прямым ссылкам скачивал и устанавливал продукты на ВМ в облаке. 

Графический интерфейс (GUI) Kibana доступен по адресу: http://<Внешний-IP-ВМ-Kibana>:5601/
Авторизация: elastic / Elastic123
Пароль для втроенных учетных записей Elasticsearch, включая elastic и kibana_system, меняется в Ansible Playbook сценарии `logs.yaml` (bash скрипт `cloud-elk-install`).
После прохождения этапа авторизации для просмотра логов необходимо в GUI пройти по следующим пунктам меню:
Пиктограмма в виде трёх горизонтальных черточек --> "Observability" --> "Logs" --> "Stream"
Для подключения панели отображения логов Nginx необходимо в GUI Kibana выполнить следующее:
Пиктограмма в виде трёх горизонтальных черточек --> "Analytics" --> "Dashboard" --> в строке поиска набрать и выбрать панель "[Filebeat Nginx] Access and error logs ECS" 

---

### Сеть

**Разворачиваем один VPC**

Virtual Private Cloud (VPC) - представляет собой отдельный каталог (folder) в облаке с созданой внутри каталога сетью (network) и подсетью (subnet).

> Предполагается, что:
> - интерфейс командной строки Yandex Cloud уже установлен и
> - в личном аккаунте сервиса Yandex Cloud уже существует хотя бы одно облако (cloud).

В текущем облаке создаем новый отдельный каталог `thesis-on-the-profession`. В конфигурации командной строки YC CLI устанавливаем созданный каталог `thesis-on-the-profession` по умолчанию. В новом текущем каталоге создаём сеть `default` и в ней две подсети: `default-ru-central1-a` и `default-ru-central1-b`. Имя подсети состоит из префикса - имя сети (network) и суфикса - имя зоны доступности (zone). Размер подсети (range) выбираем с учётом планируемого колличества работающих в данной подсети ВМ (плюс шлюз и плюс DNS). Диапазоны различных подсетей в границах одной сети не должны пересекаться [cloud.yandex.ru/docs](https://cloud.yandex.ru/docs/vpc/concepts/network). Имена сети, подсетей и значения размеров подсетей оставил в значениях, используемх по умолчанию.
Далее всю облачную инфраструктуру разворачиваем в отдельном каталоге (стартовый bash скрипт `INSTALL-cloud-infrastructure`). По окончании работ удалаем созданную инфраструктуру вместе с каталогом `thesis-on-the-profession` (VPC), не затрагивая другую существующую в облаке инфраструктуру (bash скрипт `REMOVE-cloud-infrastructure`).

Листинг команд с использованием YC CLI:
```bash
# создаём новый каталог thesis-on-the-profession
yc resource-manager folder create --name thesis-on-the-profession --description "Проект дипломной работы"

# устанавливаем каталог thesis-on-the-profession по умолчанию в конфигурации командной строки yc
yc config set folder-name thesis-on-the-profession

# создаём в текущем каталоге thesis-on-the-profession сеть default
yc vpc network create --name default --description "Сеть дипломной работы"
#yc vpc network create --folder-name thesis-on-the-profession --name default --description "Сеть дипломной работы"

# создаём две подсети: default-ru-central1-a и default-ru-central1-b
yc vpc subnet create --name default-ru-central1-a --description "Подсеть зоны А" --zone ru-central1-a --network-name default --range 10.128.0.0/24
#yc vpc subnet create --folder-name thesis-on-the-profession --name default-ru-central1-a --description "Подсеть зоны А" --zone ru-central1-a --network-name default --range 10.128.0.0/24
yc vpc subnet create --name default-ru-central1-b --description "Подсеть зоны B" --zone ru-central1-b --network-name default --range 10.129.0.0/24
```

**Создание групп безопасности (Security Groups) и реализация концепции Bastion Host**

Группы безопасности действуют по принципу «запрещено все, что не разрешено». Если назначить сетевому интерфейсу ВМ группу безопасности без правил, ВМ не сможет передавать и принимать трафик ([cloud.yandex.ru/docs](https://cloud.yandex.ru/docs/vpc/concepts/security-groups)).
Если в группе безопасности существует только правило для исходящего трафика, но нет правил для входящего трафика, ответный трафик все равно сможет поступать на ВМ. Если в группе безопасности есть только правила для входящего трафика, ВМ сможет только отвечать на запросы, но не инициировать их ([cloud.yandex.ru/docs](https://cloud.yandex.ru/docs/vpc/concepts/security-groups)).

Создаём следующие группы безопасности (Security Groups)
1. Группа безопасности `sg-web` для двух ВМ с web серверами - сайт:
- входящий трафик на порт 80 по TCP с любого ip (CIDR 0.0.0.0/0) - доступ к сайту по HTTP
- входящий трафик на порт 8080 по TCP с любого ip (CIDR 0.0.0.0/0) - доступ к сайту по HTTPS
- входящий трафик на порт 9100 по TCP с внутреннего ip (CIDR 10.128.0.0/16,10.129.0.0/16) - доступ к Node Exporter из двух подсетей
- входящий трафик на порт 4040 по TCP с внутреннего ip (CIDR 10.128.0.0/16,10.129.0.0/16) - доступ к Nginx Log Exporter из двух подсетей
- входящий трафик: добавляем предустановленное правило loadbalancer_healthchecks - для проверки состояния балансировщика
- входящий трафик на порт 22 по TCP(SSH) с внутреннего ip vm-grafana (bastion) (CIDR 10.128.0.22/32) - доступ по SSH только из внутренней сети и только с одного хоста
- исходящий трафик на порт 9200 по TCP на внутренний ip (CIDR 10.128.0.0/16) - логи от Filebeat к Elasticsearch (подсеть зоны А)
- *(?)исходящий трафик на порт 5601 по TCP на внутренний ip (CIDR 10.128.0.0/16) - доступ Filebeat к Kibana (подсеть зоны А)*

2. Группа безопасности `sg-prometheus` для ВМ с Prometheus:
- входящий трафик на порт 9090 по TCP с внутреннего ip (CIDR 10.128.0.0/16) - доступ к Prometheus из подсети зоны А
- входящий трафик на порт 22 по TCP(SSH) с внутреннего ip vm-grafana (bastion) (CIDR 10.128.0.22/32) - доступ по SSH только из внутренней сети и только с одного хоста
- исходящий трафик на порт 9100 по TCP на внутренний ip (CIDR 10.128.0.0/16,10.129.0.0/16) - запросы от Prometheus к Node Exporter в две подсети
- исходящий трафик на порт 4040 по TCP на внутренний ip (CIDR 10.128.0.0/16,10.129.0.0/16) - запросы от Prometheus к Nginx Log Exporter в две подсети

3. Группа безопасности `sg-grafana` для ВМ с Grafana и с ролью Bastion Host:
- входящий трафик на порт 3000 по TCP с любого ip (CIDR 0.0.0.0/0) - доступ к GUI
- входящий трафик на порт 22 по TCP(SSH) с любого ip (CIDR 0.0.0.0/0) - доступ по SSH из любой сети (Bastion Host)
- исходящий трафик на порт 22 по TCP(SSH) на внутренний ip (CIDR 10.128.0.0/16,10.129.0.0/16) - подключение к любой ВМ в двух подсетях (Bastion Host)
- исходящий трафик на порт 9100 по TCP на внутренний ip (CIDR 10.128.0.0/16) - подключение к Prometheus (подсеть зоны А)

4. Группа безопасности `sg-elastic` для ВМ Elasticsearch:
- входящий трафик на порт 22 по TCP(SSH) с внутреннего ip vm-grafana (bastion) (CIDR 10.128.0.22/32) - доступ по SSH только из внутренней сети и только с одного хоста
- входящий трафик на порт 9200 по TCP на внутренний ip (CIDR 10.128.0.0/16,10.129.0.0/16) - логи от Filebeat к Elasticsearch из двух подсетей
- иходящий трафик на порт 5601 по TCP с внутреннего ip (CIDR 10.128.0.0/16) - доступ к Kibana

5. Группа безопасности `sg-kibana` для ВМ Kibana:
- входящий трафик на порт 22 по TCP(SSH) с внутреннего ip vm-grafana (bastion) (CIDR 10.128.0.22/32) - доступ по SSH только из внутренней сети и только с одного хоста
- входящий трафик на порт 5601 по TCP с любого ip (CIDR 0.0.0.0/0) - доступ к GUI
- исходящий трафик на порт 9200 по TCP на внутренний ip (CIDR 10.128.0.0/24) - логи от Filebeat к Elasticsearch

Для реализации роли Bastion Host (возможность доступа по SSH с одной ВМ на остальные ВМ в VPC) необходимо скопировать используемые для авторизации по SSH пару ключей на ВМ Grafana.
Копирование публичного ключа выполняется на этапе создания ВМ.  Копирование приватного ключа выполняется в ansible playbook сценарии `monitoring.yaml` (bash скрипт `cloud-monitoring-install`).

Листинг команд с использованием YC CLI:
```bash
NETWORK_ID=$(yc vpc network get --name default |grep -e "^id: " |awk '{print $ 2}')
#
# создаём группу безопасности sg-web
yc vpc security-group create --name sg-web --description "SG для WEB" --network-id $NETWORK_ID \
--rule description="in web server",direction=ingress,port=80,protocol=tcp,v4-cidrs=[0.0.0.0/0] \
--rule description="from internal Grafana to SSH",direction=ingress,port=22,protocol=tcp,v4-cidrs=[10.128.0.22/32] \
--rule description="from internal to metrics node-exporter",direction=ingress,port=9100,protocol=tcp,v4-cidrs=[10.128.0.0/16,10.129.0.0/16] \
--rule description="from internal to metrics nginxlog-exporter",direction=ingress,port=4040,protocol=tcp,v4-cidrs=[10.128.0.0/16,10.129.0.0/16] \
--rule description="loadbalancer healthchecks",direction=ingress,port=any,protocol=any,predefined=loadbalancer_healthchecks \
--rule description="to internal Elasticsearch from Filebeat",direction=egress,port=9200,protocol=tcp,v4-cidrs=[10.128.0.0/16] \
--rule description="to internal Kibana from Filebeat",direction=egress,port=5601,protocol=tcp,v4-cidrs=[10.128.0.0/16]

# подключаем группу безопасности sg-web к сетевому интерфейсу ВМ vm-web1 и vm-web2
SG_WEB_ID=$(yc vpc security-group get --name sg-web |grep -e "^id: " |awk '{print $ 2}')
for VM_NAME in vm-web1 vm-web2
do
    yc compute instance update-network-interface --name $VM_NAME --network-interface-index 0 --security-group-id $SG_WEB_ID
    #yc compute instance update-network-interface --name $VM_NAME --network-interface-index 0 --security-group-name sg-web #по имени группы не подключает
done

#
# создаём группу безопасности sg-prometheus
yc vpc security-group create --name sg-prometheus --description "SG для Prometheus" --network-id $NETWORK_ID \
--rule description="from internal Grafana to Prometheus",direction=ingress,port=9090,protocol=tcp,v4-cidrs=[10.128.0.0/16] \
--rule description="from internal Grafana to SSH",direction=ingress,port=22,protocol=tcp,v4-cidrs=[10.128.0.22/32] \
--rule description="to internal Node Exporter from Prometheus",direction=egress,port=9100,protocol=tcp,v4-cidrs=[10.128.0.0/16,10.129.0.0/16] \
--rule description="to internal Nginx Log Exporter from Prometheus",direction=egress,port=4040,protocol=tcp,v4-cidrs=[10.128.0.0/16,10.129.0.0/16]

# подключаем группу безопасности sg-prometheus к сетевому интерфейсу ВМ vm-prometheus
SG_PROMETHEUS_ID=$(yc vpc security-group get --name sg-prometheus |grep -e "^id: " |awk '{print $ 2}')
yc compute instance update-network-interface --name $MONS_VM1_NAME --network-interface-index 0 --security-group-id $SG_PROMETHEUS_ID
#yc compute instance update-network-interface --name $MONS_VM1_NAME --network-interface-index 0 --security-group-name sg-prometheus #по имени группы не подключает

#
# создаём группу безопасности sg-grafana
yc vpc security-group create --name sg-grafana --description "SG для Grafana" --network-id $NETWORK_ID \
--rule description="in Grafana GUI",direction=ingress,port=3000,protocol=tcp,v4-cidrs=[0.0.0.0/0] \
--rule description="in Grafana SSH",direction=ingress,port=22,protocol=tcp,v4-cidrs=[0.0.0.0/0] \
--rule description="to internal Prometheus from Grafana",direction=egress,port=9090,protocol=tcp,v4-cidrs=[10.128.0.0/16,10.129.0.0/16] \
--rule description="to internal VM SSH from Grafana",direction=egress,port=22,protocol=tcp,v4-cidrs=[10.128.0.0/16,10.129.0.0/16]

# подключаем группу безопасности sg-grafana к сетевому интерфейсу ВМ vm-grafana
SG_GRAFANA_ID=$(yc vpc security-group get --name sg-grafana |grep -e "^id: " |awk '{print $ 2}')
yc compute instance update-network-interface --name $MONS_VM2_NAME --network-interface-index 0 --security-group-id $SG_GRAFANA_ID

#
# создаём группу безопасности sg-elastic
yc vpc security-group create --name sg-elastic --description "SG для Elasticsearch" --network-id $NETWORK_ID \
--rule description="from internal to Elasticsearc",direction=ingress,port=9200,protocol=tcp,v4-cidrs=[10.128.0.0/16,10.129.0.0/16] \
--rule description="from internal Grafana to SSH",direction=ingress,port=22,protocol=tcp,v4-cidrs=[10.128.0.22/32] \
--rule description="to internal Kibana from Elasticsearch",direction=egress,port=5601,protocol=tcp,v4-cidrs=[10.128.0.0/16,10.129.0.0/16]

# подключаем группу безопасности sg-elastic к сетевому интерфейсу ВМ vm-elastic
SG_ELASTIC_ID=$(yc vpc security-group get --name sg-elastic |grep -e "^id: " |awk '{print $ 2}')
yc compute instance update-network-interface --name $LOGS_VM1_NAME --network-interface-index 0 --security-group-id $SG_ELASTIC_ID

# создаём группу безопасности sg-kibana
yc vpc security-group create --name sg-kibana --description "SG для Kibana" --network-id $NETWORK_ID \
--rule description="in Kibana GUI",direction=ingress,port=5601,protocol=tcp,v4-cidrs=[0.0.0.0/0] \
--rule description="from internal Grafana to SSH",direction=ingress,port=22,protocol=tcp,v4-cidrs=[10.128.0.22/32] \
--rule description="to internal Elasticsearch from Kibana",direction=egress,port=9200,protocol=tcp,v4-cidrs=[10.128.0.0/16,10.129.0.0/16]

# подключаем группу безопасности sg-kibana к сетевому интерфейсу ВМ vm-kibana
SG_KIBANA_ID=$(yc vpc security-group get --name sg-kibana |grep -e "^id: " |awk '{print $ 2}')
yc compute instance update-network-interface --name $LOGS_VM2_NAME --network-interface-index 0 --security-group-id $SG_KIBANA_ID
```

---

### Резервное копирование

Создал расписание (snapshot-schedule) `project-snapshot-schedule` создания снимков (snapshot): снимки создаются ежедневно в 03:10 (UTC+3) или 0:10 (UTC+0), срок хранения снимков 1-а неделя (168 часов).
В созданное раписание `project-snapshot-schedule` добавил все диски всех ВМ из каталога проекта.
Процесс создания и добавления реализован в bash скрипте `cloud-snapshot-shed-create` (вызывается в основном bash скрипте `INSTALL-cloud-infrastructure`)

Листинг команд с использованием YC CLI:
```bash
# создаём расписание project-snapshot-schedule в текущем каталоге
yc compute snapshot-schedule create project-snapshot-schedule \
--description "Ежедневные снимки. Срок харанения 7 дней" \
--expression "10 0 ? * *" \
--start-at "1h" \
--retention-period 168h

# добавляем в расписание project-snapshot-schedule все диски в текущем каталоге
yc compute snapshot-schedule add-disks \
--name project-snapshot-schedule \
--disk-id $(yc compute disk list |awk 'NR > 3' |cut -d ' ' -f 2 |head -n -2 |paste -sd ',')
```

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
