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
2023.09.02 :: Разразботана базовая Terraform конфигурация, которая:
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

#2
$ whoami                         ## devops
$ cd ~ && pwd                    ## /home/devops
$ ls -la ./ssh                   ## -rw------- 1 devops devops  id_ed25519
                                 ## -rw------- 1 devops devops  id_ed25519.pub

$ ssh <vm1_nginx_external_ip>    ## examples: ssh 158.160.23.86  -or-  ssh devops@158.160.23.86  -or-  ssh devops@158.160.23.86 -i ~/.ssh/id_ed25519

#3
$ terraform destroy -auto-approve
```
