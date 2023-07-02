# Дипломная работа по профессии «Системный администратор» - `Станислав Барановский`

### Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/).

### Инфраструктура
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

Настройте Security Groups соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Настройте все security groups на разрешение входящего ssh из этой security group. Эта вм будет реализовывать концепцию bastion host. Потом можно будет подключаться по ssh ко всем хостам через этот хост.

### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

### Дополнительно
Не входит в минимальные требования.

Для Prometheus можно реализовать альтернативный способ хранения данных — в базе данных PpostgreSQL. Используйте Yandex Managed Service for PostgreSQL. Разверните кластер из двух нод с автоматическим failover. Воспользуйтесь адаптером с https://github.com/CrunchyData/postgresql-prometheus-adapter для настройки отправки данных из Prometheus в новую БД.
Вместо конкретных ВМ, которые входят в target group, можно создать Instance Group, для которой настройте следующие правила автоматического горизонтального масштабирования: минимальное количество ВМ на зону — 1, максимальный размер группы — 3.
Можно добавить в Grafana оповещения с помощью Grafana alerts. Как вариант, можно также установить Alertmanager в ВМ к Prometheus, настроить оповещения через него.
В Elasticsearch добавьте мониторинг логов самого себя, Kibana, Prometheus, Grafana через filebeat. Можно использовать logstash тоже.
Воспользуйтесь Yandex Certificate Manager, выпустите сертификат для сайта, если есть доменное имя. Перенастройте работу балансера на HTTPS, при этом нацелен он будет на HTTP веб-серверов.
Выполнение работы
На этом этапе вы непосредственно выполняете работу. При этом вы можете консультироваться с руководителем по поводу вопросов, требующих уточнения.

**warning** В случае недоступности ресурсов Elastic для скачивания рекомендуется разворачивать сервисы с помощью docker контейнеров, основанных на официальных образах.

Важно: Ещё можно задавать вопросы по поводу того, как реализовать ту или иную функциональность. И руководитель определяет, правильно вы её реализовали или нет. Любые вопросы, которые не освещены в этом документе, стоит уточнять у руководителя. Если его требования и указания расходятся с указанными в этом документе, то приоритетны требования и указания руководителя.

### Критерии сдачи
Инфраструктура отвечает минимальным требованиям, описанным в Задаче.
Предоставлен доступ ко всем ресурсам, у которых предполагается веб-страница (сайт, Kibana, Grafanа).
Для ресурсов, к которым предоставить доступ проблематично, предоставлены скриншоты, команды, stdout, stderr, подтверждающие работу ресурса.
Работа оформлена в отдельном репозитории в GitHub или в Google Docs, разрешён доступ по ссылке.
Код размещён в репозитории в GitHub.
Работа оформлена так, чтобы были понятны ваши решения и компромиссы.
Если использованы дополнительные репозитории, доступ к ним открыт.
Как правильно задавать вопросы дипломному руководителю
Что поможет решить большинство частых проблем:

Попробовать найти ответ сначала самостоятельно в интернете или в материалах курса и только после этого спрашивать у дипломного руководителя. Навык поиска ответов пригодится вам в профессиональной деятельности.
Если вопросов больше одного, присылайте их в виде нумерованного списка. Так дипломному руководителю будет проще отвечать на каждый из них.
При необходимости прикрепите к вопросу скриншоты и стрелочкой покажите, где не получается. Программу для этого можно скачать здесь.
Что может стать источником проблем:

Вопросы вида «Ничего не работает. Не запускается. Всё сломалось». Дипломный руководитель не сможет ответить на такой вопрос без дополнительных уточнений. Цените своё время и время других.
Откладывание выполнения дипломной работы на последний момент.
Ожидание моментального ответа на свой вопрос. Дипломные руководители — работающие инженеры, которые занимаются, кроме преподавания, своими проектами. Их время ограничено, поэтому постарайтесь задавать правильные вопросы, чтобы получать быстрые ответы :)








---

## Подготовка к выполнению заданий

1. Подготовка защищаемой системы:

- установите **Suricata**,
- установите **Fail2Ban**.

```bash
#ubuntu
sudo apt update && sudo apt upgrade
sudo apt install software-properties-common
sudo add-apt-repository ppa:oisf/suricata-stable
sudo apt update
sudo apt install -y suricata
sudo suricata-update
sudo suricata-update list-sources
#sudo suricata-update update-sources
systemctl status suricata.service
suricata -V

sudo nano /etc/suricata/suricata.yaml # EXTERNAL_NET: "any"
sudo systemctl restart suricata.service
systemctl status suricata.service

sudo apt install -y fail2ban
systemctl status fail2ban
sudo systemctl start fail2ban
fail2ban-client -V

sudo nano /etc/fail2ban/jail.conf # [sshd] enabled = true
sudo systemctl restart fail2ban.service
systemctl status fail2ban.service
```

2. Подготовка системы злоумышленника: установите **nmap** и **thc-hydra** либо скачайте и установите **Kali linux**.

Обе системы должны находится в одной подсети.

------

## Задание 1

Проведите разведку системы и определите, какие сетевые службы запущены на защищаемой системе:

**sudo nmap -sA < ip-адрес >**

**sudo nmap -sT < ip-адрес >**

**sudo nmap -sS < ip-адрес >**

**sudo nmap -sV < ip-адрес >**

По желанию можете поэкспериментировать с опциями: https://nmap.org/man/ru/man-briefoptions.html.


*В качестве ответа пришлите события, которые попали в логи Suricata и Fail2Ban, прокомментируйте результат.*



```bash
#ubuntu
sudo suricata -c /etc/suricata/suricata.yaml -i enp0s3
tail -f /var/log/suricata/fast.log
grep "192.168.56.103" /var/log/suricata/fast.log


tail /var/log/auth.log
grep "192.168.56.103" /var/log/auth.log
cat /var/log/fail2ban.log

#kali
sudo nmap -sA 192.168.56.104
sudo nmap -sS 192.168.56.104
sudo nmap -sT 192.168.56.104
sudo nmap -sV 192.168.56.104

hydra -L users.txt -P pass.txt 192.168.56.104 ssh
```
Сканирование nmap -sA (ACK) в логи suricata не попало
В логах fail2ban зафиксировано только сканирование nmap -sV (Version detection)

**Сканирование nmap -sS (suricata)**
![Сканирование nmap -sS](https://github.com/StanislavBaranovskii/13-3-hw/blob/main/img/13-3-1-nmap-sS.png "Сканирование nmap -sS")

**Сканирование nmap -sT (suricata)**
![Сканирование nmap -sT](https://github.com/StanislavBaranovskii/13-3-hw/blob/main/img/13-3-1-nmap-sT.png "Сканирование nmap -sT")

**Сканирование nmap -sV (suricata)**
![Сканирование nmap -sV](https://github.com/StanislavBaranovskii/13-3-hw/blob/main/img/13-3-1-nmap-sV.png "Сканирование nmap -sV")

**Сканирование nmap -sV (fail2ban)**
![Сканирование nmap -sV (fail2ban)](https://github.com/StanislavBaranovskii/13-3-hw/blob/main/img/13-3-2-nmap-sV-fail2ban-log.png "Сканирование nmap -sV (fail2ban)")

------

## Задание 2

Проведите атаку на подбор пароля для службы SSH:

**hydra -L users.txt -P pass.txt < ip-адрес > ssh**

1. Настройка **hydra**: 
 
 - создайте два файла: **users.txt** и **pass.txt**;
 - в каждой строчке первого файла должны быть имена пользователей, второго — пароли. В нашем случае это могут быть случайные строки, но ради эксперимента можете добавить имя и пароль существующего пользователя.

Дополнительная информация по **hydra**: https://kali.tools/?p=1847.

2. Включение защиты SSH для Fail2Ban:

-  открыть файл /etc/fail2ban/jail.conf,
-  найти секцию **ssh**,
-  установить **enabled**  в **true**.

Дополнительная информация по **Fail2Ban**:https://putty.org.ru/articles/fail2ban-ssh.html.

*В качестве ответа пришлите события, которые попали в логи Suricata и Fail2Ban, прокомментируйте результат.*


После включения защиты ssh для Fail2Ban падает скорость перебора паролей. По умолчанию после 5 не верных паролей IP адрес хоста блокируется на 10 минут.

**Подбор пароля по ssh (fail2ban - до включения защиты ssh)**
![Подбор пароля по ssh (fail2ban)](https://github.com/StanislavBaranovskii/13-3-hw/blob/main/img/13-3-2-hydra-fail2ban-off.png "Подбор пароля по ssh (fail2ban - до включения защиты ssh)")

**Подбор пароля по ssh (fail2ban - после включения защиты ssh)**
![Подбор пароля по ssh (fail2ban)](https://github.com/StanislavBaranovskii/13-3-hw/blob/main/img/13-3-2-hydra-fail2ban-on.png "Подбор пароля по ssh (fail2ban - полсе включения защиты ssh)")

**Подбор пароля по ssh (suricata)**
![Подбор пароля по ssh (suricata)](https://github.com/StanislavBaranovskii/13-3-hw/blob/main/img/13-3-2-hydra-suricata.png "Подбор пароля по ssh (suricata)")

------
