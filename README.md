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

Скриншот1: Nginx Шлюз/ReverseProxy - Основная/Домашняя страница (без https) <br>
![screen](_screens/gateway__index-page__v1.png?raw=true)
<br>

Скриншот2: Nginx Шлюз/ReverseProxy - Основная/Домашняя страница (с https) <br>
![screen](_screens/gateway__index-page__v1_https.png?raw=true)
<br>

Скриншот3: HTTP/SSL сертификат для сайта "gw.dotspace.ru" выданный SA "Lets Encrypt" <br>
![screen](_screens/gateway__self__cert_1.png?raw=true)
<br>
![screen](_screens/gateway__self__cert_2.png?raw=true)
<br>

Скриншот4: Tomcat/Artifactory - Основная/Домашняя страница (без https) <br>
![screen](_screens/repo__tomcat__1_homepage.png?raw=true)
<br>

Скриншот5: Tomcat/Artifactory - Раздел "Manager App" (без https) <br>
![screen](_screens/repo__tomcat__2_manager-app.png?raw=true)
<br>

Скриншот6: Tomcat/Artifactory - Раздел "Host Manager" (без https) <br>
![screen](_screens/repo__tomcat__3_host-manager.png?raw=true)
<br>

Скриншот7: Результат перехода по URL /cicd (https-сайт) <br>
![screen](_screens/gateway__jenkins.png?raw=true)
<br>

Скриншот8: HTTP/SSL сертификат для сайта "jenkins.dotspace.ru" выданный SA "Lets Encrypt" <br>
![screen](_screens/gateway__jenkins__cert.png?raw=true)
<br>
