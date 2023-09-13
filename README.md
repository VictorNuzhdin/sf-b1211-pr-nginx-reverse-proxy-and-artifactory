# sf-b1211-pr-nginx-reverse-proxy-and-artifactory
For Skill Factory study project (B12, PR)

<br>


### 01. Общее описание (возможно будет корректироваться)

```bash
Terraform IaC-конфигурация для создания 2х виртуальных машин в облаке провайдера Yandex.Cloud:
1. ВМ1 на основе Ubuntu 22.04 LTS :: Nginx как обратный прокси и шлюз доступа (10.0.10.14/28) перенаправляющий HTTPS-запросы на внутренние сервера
2. ВМ2 на основе Ubuntu 22.04 LTS :: Artifactory как сервер размещенный во внутренней сети и не имеющий прямого доступа извне (10.0.10.11/28)
3. ВМ1 привязана к домену [dotspace.ru] и должна быть доступна по URL: https://gw.dotspace.ru
4. ВМ2 должна быть доступна через шлюз доступа по URL: https://gw.dotspace.ru/repo
```

### 02. История изменений (не детальная, сверху - новые)

```bash
2023.09.14 :: Реализовано JavaEE веб-приложение заглушка эмулирующая начальную страницу JFrog Platform/Artifactory:
    - на ВМ2 (tomcat) создано JavaEE веб-приложение и создан скрипт конфигурации "configure_07-tomcat-deploy-webapp.sh" для деплоя этого приложения на tomcat
    - на ВМ1 (nginx) доработана конфигурация сайта "gw2.dotspace.ru" и домашняя страница шлюза "index.html"
    - выявлена очередная проблема которой раньше не было:
      * при установке пакетов на ВМ2, шелл требовал интерактивного действия перезапуска сервисов для обновления ядра
        в итоге решение найдено, но оно не полностью понятное (принудитнльное подавление интерактивного запроса)

2023.09.12 :: ВМ1 (nginx) настроена как "reverse-proxy" (шлюз доступа по типу "снаружи-внутрь" для доступа к веб-приложениям во внутренней сети)
    - в проект добавлен конфигурационный блок "terraform/scripts/nginx (nginx__v2 и nginx__v3)" содержащий скрипты для настройки SSL/HTTPS на Nginx
    - изменения имен некоторых конфигурационных шелл-скриптов
    - добавлены/изменены скрипты и файлы: 
      * "configure_05-ssl-letsencrypt-gw2-request-new.sh"
      * "configure_05-ssl-letsencrypt-gw2-reuse-old.sh"
      * "configure_06-nginx-proxy-gw1.sh"
      * "configure_06-nginx-proxy-gw2.sh"
      * "getLetsEncryptCert_gw2-request-new.sh"
      * "getLetsEncryptCert_gw2-reuse-old.sh"
      * "gw2.dotspace.ru"
      * "index.html"
    - ВАЖНО: выявлен нюанс работы с SA "Lets Encrypt":
      кол-во запросов на перевыпуск SSL сертификатов НЕ_ДОЛЖНО превышать 50 за последние 168 часов (7 дней)
      подробности тут: 
      * https://www.plesk.com/kb/support/unable-to-install-a-lets-encrypt-certificate-too-many-certificates-already-issued-for-exact-set-of-domains
      * https://community.letsencrypt.org/t/5-already-issued-for-this-exact-set-of-domains-in-the-last-168-hours/153169
    - в результате выявленного эксперементально выше нюанса, изза срабатывания лимита 
      пришлось создавать новый суб-домен [gw2.dotspace.ru] и перестраивать все файлы конфигурации
    - кроме того, чтобы исключить постоянные ненужные запросы на перевыпуск SSL сертификатов через SA "Lets Encrypt",
      разработан и внедрен механизм повторного использования ранее выпущенного и еще действующего SSL серификата
      через бекапирование и восстановления каталога "/etc/letsencrypt" на вновь создаваемой ВМ (для сайта на томже самом домене);
      в результате при многократном пересоздании ВМ, запрос нового SSL сертификата НЕ происходит, а используется ранее выпущенный и валидный

2023.09.09 :: Добавлены/Изменены скрипты настройки ВМ2:
    - в проект добавлен конфигурационный блок "terraform/scripts/tomcat" содержащий необходимые скрипты для установки и настройки "Apache Tomcat 9.0.80"
    - помимо Tomcat, производится установка "Oracle Java JDK 17" которая необходима для работы Tomcat 9 (от версии Java 1.8 и выше)

2023.09.08 :: Разработана базовая Terraform конфигурация, которая:
    - создает ВМ2 (tomcat/repo) на основе Ubuntu 22.04
    - создает и настраивает на ВМ2 нового пользователя "devops" с авторизацией по ssh-ключу
    - подготавливает каркасные шелл-скрипты для выполнения прочих настроек ВМ2

2023.09.07 :: Добавлены/Изменены скрипты настройки ВМ1:
    - скрипт "configure_05-ssl-letsencrypt.sh" (выполняет установку LetsEncrypt "certbot" для запроса SSL сертификата)
    - скрипт "requesLetsEncryptCert.sh" (циклически проверяет доступность сайта по доменному имени http://gw.dotspace.ru и запрашивает выпуск LetsEncrypt сертификата)
    - незначительные изменения цифровых идентификаторов в именах скриптов
    - в результате Nginx сервер становится доступен по URL https://gw.dotspace.ru с валидным SSL сертификатом сроком на 90 дней

2023.09.05 :: Добавлены/Изменены скрипты настройки ВМ1:
    - скрипт "configure_03-nginx.sh"    (добавлена конфигурация виртуального сайта [gw.dotspace.ru])
    - добавлена index.html страница с приветствием
    - в результате:
      *при переходе по URL http://gw.dotspace.ru мы видим корневую страницу шлюза "Welcome to [gw.dotspace.ru] (Reverse-Proxy Gateway)"
      *при переходе по URL http://gw.dotspace.ru/cicd происходит редирект на https://jenkins.dotspace.ru

2023.09.04 :: Добавлены/Изменены скрипты настройки ВМ1:
    - в проект добавлен конифигурационный блок "terraform/scripts/nginx" содержащий необходимые скрипты для установки и настройки "Nginx"
    - скрипт "configure_03-nginx.sh"    (первичная установка Nginx)
    - скрипт "configure_66-firewall.sh" (активация и настройка сетевого экрана "ufw" :: открыты порты: 80,443,22)
    - скрипт "configure_77-freedns.sh"  (взаимодействие с API FreeDNS сервиса добавляющего динамический IP-адрес сервера в глобальную DNS)
    - в результате Nginx сервер становится доступен по URL http://gw.dotspace.ru

2023.09.02 :: Разработана базовая Terraform конфигурация, которая:
    - создает ВМ1 (nginx/gw) на основе Ubuntu 22.04
    - создает и настраивает на ВМ1 нового пользователя "devops" с авторизацией по ssh-ключу
    - подготавливает каркасные шелл-скрипты для выполнения прочих настроек ВМ1
      *разработана раздельная установка и запуск шелл-скриптов :: есть мастер-скрипт который запускает отдельные скрипты для каждого блока задач
```

### 03. Порядок работы
```bash
#0
$ export TF_VAR_yc_token=$(yc iam create-token) && echo $TF_VAR_yc_token

#1
$ cd terraform
$ terraform validate
$ terraform plan
$ terraform apply -auto-approve

#--раздельное развертывание ресурсов (на этапе разработки когда нет необходимости уничтожать/создавать все ресурсы сразу)
#..сначала пересоздаем ВМ1
$ terraform destroy -target=yandex_compute_instance.host1 -auto-approve && \ 
terraform validate && \
terraform plan -target=yandex_compute_instance.host1 && \
terraform apply -target=yandex_compute_instance.host1 -auto-approve

#..затем пересоздаем ВМ2
$ terraform destroy -target=yandex_compute_instance.host2 -auto-approve && \ 
terraform validate && \
terraform plan -target=yandex_compute_instance.host2 && \
terraform apply -target=yandex_compute_instance.host2 -auto-approve

#2
$ whoami                         ## devops
$ cd ~ && pwd                    ## /home/devops
$ ls -la ./ssh                   ## -rw------- 1 devops devops  id_ed25519
                                 ## -rw------- 1 devops devops  id_ed25519.pub

$ ssh <vm1_nginx_external_ip>    ## examples: ssh 158.160.23.86  -or-  ssh devops@158.160.23.86  -or-  ssh devops@158.160.23.86 -i ~/.ssh/id_ed25519
..or
$ ping -c 1 gw.dotspace.ru       ## 64 bytes from 158.160.23.86 (158.160.23.86): icmp_seq=1 ttl=63 time=0.606 ms
$ ssh gw.dotspace.ru

#3
$ curl -s https://gw.dotspace.ru | grep title | awk '{$1=$1;print}'        ## <title>Welcome | gw.dotspace.ru</title>
$ url -s http://$(curl -s 2ip.ru):8080 | grep title | awk '{$1=$1;print}'  ## <title>Apache Tomcat/9.0.80</title>

browser: https://gw.dotspace.ru     ## Welcome to [gw.dotspace.ru] (Reverse-Proxy Gateway) --> View site information - Connection is secure - Certificate is valid
browser: http://51.250.16.254:8080  ## Apache Tomcat/9.0.80

#4
$ terraform destroy -auto-approve                                          ## уничтожаются все ресурсы
$ terraform destroy -target=yandex_compute_instance.host1 -auto-approve    ## уничтожается только ВМ1 (nginx)
$ terraform destroy -target=yandex_compute_instance.host2 -auto-approve    ## уничтожается только ВМ2 (tomcat)
```

### 05. Результат работы веб-приложения

Скриншот01: Nginx Шлюз/ReverseProxy - Домашняя страница (v3) (с https/ssl выданным SA "Lets Encrypt") <br>
![screen](_screens/gateway__index-page__v3.png?raw=true)
<br>
![screen](_screens/gateway__index-page__v3_https.png?raw=true)
<br>

Скриншот02: Корневой домен/сайт "dotspace.ru" - Домашняя страница (с https) <br>
![screen](_screens/domain__index-page__1.png?raw=true)
<br>
![screen](_screens/domain__index-page__2_https.png?raw=true)
<br>

Скриншот03: Результат перехода по URL /cicd на Jenkins сервер (с https/ssl выданный SA "Lets Encrypt") <br>
![screen](_screens/gateway__jenkins.png?raw=true)
<br>
![screen](_screens/gateway__jenkins__cert.png?raw=true)
<br>

Скриншот04: Tomcat - Домашняя страница (без https) <br>
![screen](_screens/repo__tomcat__gw1__1_homepage.png?raw=true)
<br>

Скриншот05: Tomcat - Раздел "Manager App" (без https) <br>
![screen](_screens/repo__tomcat__gw1__2_manager-app.png?raw=true)
<br>

Скриншот06: Tomcat - Раздел "docs" (с https) <br>
![screen](_screens/repo__tomcat__gw2__1_docs.png?raw=true)
<br>

Скриншот07: Tomcat - Раздел "examples" (с https) <br>
![screen](_screens/repo__tomcat__gw2__2_examples.png?raw=true)
<br>

Скриншот08: Tomcat - Демо веб-приложение на Java "app1" (с https) <br>
![screen](_screens/repo__tomcat__gw2__3_example-app.png?raw=true)
<br>

Скриншот09: Tomcat - Веб-приложение-заглушка "Фейковый JFrog Сервис" (index.html) <br>
![screen](_screens/repo__tomcat__gw2__4_fakeRepo__1_html.png?raw=true)
<br>

Скриншот10: Tomcat - Веб-приложение-заглушка "Фейковый JFrog Сервис" (welcome.jsp) <br>
![screen](_screens/repo__tomcat__gw2__4_fakeRepo__2_jsp.png?raw=true)
<br>

Скриншот11: Tomcat - Веб-приложение-заглушка "Фейковый JFrog Сервис" (FakeJFrog Servlet) -- длинный URL <br>
![screen](_screens/repo__tomcat__gw2__4_fakeRepo__3_servlet_path1.png?raw=true)
<br>

Скриншот12: Tomcat - Веб-приложение-заглушка "Фейковый JFrog Сервис" (FakeJFrog Servlet) -- короткий URL <br>
![screen](_screens/repo__tomcat__gw2__4_fakeRepo__3_servlet_path2.png?raw=true)
<br>

----

