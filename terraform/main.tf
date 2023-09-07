##--Описание коннектора Облачного Провайдера (в дс. Yandex.Cloud)
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.84.0" # версию необходимо указать только при первичной инициализации Terraform
    }
  }
}

##--Локальные переменные:
##  *iam токен авторизации;
##  *id Облака;
##  *id Каталога;
##  *зона доступности;
##  *public ssh-ключ для авторизации по ключу на серверах;
##
variable "yc_token" { type=string }

locals {
  ## token-created: 2023.04.20 10:00 (срок жизни: 12 часов)
  ## $ export TF_VAR_yc_token=$(yc iam create-token) && echo $TF_VAR_yc_token
  #
  iam_token        = "${var.yc_token}"
  cloud_id         = "b1g0u201bri5ljle0qi2"
  folder_id        = "b1gqi8ai4isl93o0qkuj"
  access_zone      = "ru-central1-b"
  netw_name        = "acme-net"
  net_id           = "enpjul7bs1mq29s7m5gf"
  net_sub_name     = "acme-net-sub1"
  net_sub_id       = "e2lcqv479p4bicmd33i1"
  vm_default_login = "ubuntu"                           # Ubuntu image default username;
  ssh_keys_dir     = "/home/devops/.ssh"                # Каталог размещения ключевой ssh-пары на локальном хосте
  #ssh_pubkey_path = "~/.ssh/id_ed25519.pub"            # Set a full path of SSH public and private keys;
  ssh_pubkey_path  = "/home/devops/.ssh/id_ed25519.pub"
  ssh_privkey_path = "/home/devops/.ssh/id_ed25519"
}

##--Авторизация на стороне провайдера и указание Ресурсов с которыми будет работать Terraform
provider "yandex" {
  token     = local.iam_token
  cloud_id  = local.cloud_id
  folder_id = local.folder_id
  zone      = local.access_zone
}


##--Создаем VM1 (Ubuntu 22.04, x2 vCPU, x2 GB RAM, x20 GB HDD) -- nginx хост (зависит от phpfpm)
resource "yandex_compute_instance" "host1" {
  name        = "nginx"             # имя ВМ;
  hostname    = "gw"                # сетевое имя ВМ (имя хоста);
  platform_id = "standard-v2"       # семейство облачной платформы ВМ (влияет на тип и параметры доступного для выбора CPU);
  zone        = local.access_zone   # зона доступности (размещение ВМ в конкретном датацентре);

  resources {
    cores         = 2 # колво виртуальных ядер vCPU;
    memory        = 2 # размер оперативной памяти, ГБ;
    core_fraction = 5 # % гарантированной доли CPU (самый дешевый вариант, при 100% вся процессорная мощность резервируется для клиента);
  }

  ## Делаем ВМ прерываемой (делает ВМ дешевле на 50% но ее в любой момент могут вырубить что происходит не часто)
  scheduling_policy {
    preemptible = true
  }

  ## Загрузочный образ на основе которого создается ВМ (из Yandex)
  boot_disk {
    initialize_params {
      image_id    = "fd8clogg1kull9084s9o"    # версия ОС: Ubuntu 22.04 LTS (family_id: ubuntu-2204-lts, image_id: fd8clogg1kull9084s9o);
      type        = "network-hdd"             # тип загрузочного носителя (network-hdd | network-ssd);
      size        = 8                         # размер диска, ГБ (меньше 8 ГБ для образа "Ubuntu 22.04" выбрать нельзя)
      description = "Ubuntu 22.04 LTS"
    }
  }

  ## Параметры локального сетевого интерфейса
  network_interface {
    #subnet_id = yandex_vpc_subnet.subnet1.id  # идентификатор подсети в которую будет смотреть интерфейс;
    subnet_id = local.net_sub_id               # подключаемся к уже существующей подсети
    ip_address = "10.0.10.14"                  # указываем явно какой внутренний IPv4 адрес назначить ВМ: последний адрес в диапазоне подсети 10.0.10.0/28;
    nat        = true                          # создаем интерфейс смотрящий в публичную сеть;
  }

  ## Данные авторизации пользователей на создаваемых ВМ
  metadata = {
    serial-port-enable = 0                                     # активация серийной консоли чтоб можно было подключиться к ВМ через веб-интерфейс (0, 1);
    ssh-keys = "ubuntu:${file("${local.ssh_pubkey_path}")}"    # передаем публичный ssh ключ который будет добавлен на ВМ в /home/ubuntu/.ssh/authorized_keys
    #ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

  ## Копирование файлов #1
  ## Копируем каталог с ssh-ключами из локального хоста на создаваемую ВМ (для дальнейшего создания учетной записи "devops")
  provisioner "file" {
    source      = local.ssh_keys_dir                # "/home/devops/.ssh/"
    destination = "/tmp"

    connection {
      type = "ssh"
      user = "ubuntu"
      host = yandex_compute_instance.host1.network_interface.0.nat_ip_address
      agent = false
      private_key = file(local.ssh_privkey_path)    # file("/home/devops/.ssh/id_ed25519")
      timeout = "3m"
    }
  }

  ## Копирование файлов #2
  ## Копируем шелл-скрипт из локального хоста на создаваемую ВМ
  provisioner "file" {
    ##-копируем только 1 скрипт
    #source      = "scripts/configure_nginx.sh"
    #destination = "/tmp/configure_nginx.sh"
    #
    ##-копируем весь каталог со скриптами
    #source      = "scripts"
    #destination = "/home/ubuntu"          # /home/ubuntu/scripts/..скрипты -или- /home/ubuntu/scripts/nginx/ + /home/ubuntu/scripts/artifactory/
    #..другие пути
    #source      = "scripts/nginx"
    #destination = "/home/ubuntu/"         # /home/ubuntu/nginx/..скрипты
    #..другие пути
    #source      = "scripts/nginx"
    #destination = "/home/ubuntu"          # /home/ubuntu/nginx/..скрипты
    #..другие пути
    #source      = "scripts/nginx"
    #destination = "/home/ubuntu/scripts"   # Upload failed: scp: /home/ubuntu/scripts: Not a directory
    #..другие пути
    source      = "scripts/nginx"
    destination = "/home/ubuntu/scripts/"   # /home/ubuntu/scripts/..скрипты

    connection {
      type = "ssh"
      user = "ubuntu"
      host = yandex_compute_instance.host1.network_interface.0.nat_ip_address
      agent = false
      private_key = file(local.ssh_privkey_path)
      timeout = "4m"
    }
  }

  ## Выполнение команд после того как ВМ будет создана
  ## *обновляем пакеты системы + устанавливаем python3
  provisioner "remote-exec" {
    ##..обязательный блок подключения к ВМ
    connection {
      type = "ssh"
      user = "ubuntu"
      host = yandex_compute_instance.host1.network_interface.0.nat_ip_address
      agent = false
      private_key = file(local.ssh_privkey_path)
      timeout = "4m"
    }
    ##..блок выполнения команд (1 команда выполняется за ssh 1 подключение)
    #inline = [
    #  "chmod +x /tmp/configure_nginx.sh",
    #  "/tmp/configure_nginx.sh"
    #]
    ##..лучше сделаем main/master шелл-скрипт который будет запускать остальные
    #inline = [
    #  "chmod +x /home/ubuntu/scripts/configure_00-main.sh",
    #  "/home/ubuntu/scripts/configure_00-main.sh"
    #]
    ##..изменен путь разещения скриптов на целевой ВМ
    inline = [
      "chmod +x /home/ubuntu/scripts/configure_00-main.sh",
      "/home/ubuntu/scripts/configure_00-main.sh"
    ]

  } ## << "provisioner remote-exec"

  ##--Возможно, в данном случае, применение Ansible может быть не обосновано, 
  ##  т.к появляется дополнительный слой сложности от которого можно избавится применяя обычные шелл-crhbgns
  ##
  #provisioner "local-exec" {
  #  ##--Применяем Ansible Плейбук "nginx" к инстансу "host1"
  #  ##  example: ansible-playbook -i 84.252.139.210, -u ubuntu -e host_public_ip_phpfpm=158.160.28.188 ./ansible/deploy_nginx.yml
  #  command = "ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_ASK_PASS=False ansible-playbook -i '${yandex_compute_instance.host1.network_interface.0.nat_ip_address},' -u ${local.vm_default_login} -e host_public_ip_phpfpm=${yandex_compute_instance.host2.network_interface.0.nat_ip_address} ./ansible/deploy_nginx.yml"
  #  #
  #} ## << "provisioner local-exec"

}


##--В Сервисе "Virtual Private Cloud" (vpc) Создаем Сеть "acme-net" и подсеть "acme-net-sub1"
##  *если в облаке уже существует такая сеть созданная ранее, то возникнет ошибка изза превышения квоты на кол-во сетей (не более 2х включая "default" сеть)
##      rpc error: code = ResourceExhausted desc = Quota limit vpc.networks.count exceeded
##  *такая сеть уже была создана ранее в предыдущем проекте, поэтому ее создание НЕ требуется и блок закомментирован
#
#resource "yandex_vpc_network" "net1" {
#  name = "acme-net" # имя сети так она будет отображаться в веб-консоли (чуть выше "net1" - это псевдоним ресурса);
#}
#
## *тоже самое это относится и к подсети :: подсеть уже была создана ранее в предыдущем проекте, поэтому ее создание НЕ требуется и блок закомментирован
#resource "yandex_vpc_subnet" "subnet1" {
#  name           = "acme-net-sub1"              # имя подсети;
#  zone           = local.access_zone            # зона доступности (из локальной переменной);
#  network_id     = yandex_vpc_network.net1.id   # связь подсети с сетью по id (net1 - это созданный псевдоним Ресурса);
#  v4_cidr_blocks = ["10.0.10.0/28"]             # адресное IPv4 пространство подсети;
#}
## *ПРИМЕЧАНИЕ:
##  - для подключения создаваемой ВМ к уже существующей сети и подсети, необходимо указать ее идентификатор в:
##    network_interface {
##        subnet_id = yandex_vpc_subnet.subnet1.id
##


/*=EXAMPLE_OUTPUT:

    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

    Outputs:

    vm1_nginx_external_ip = "nginx: 158.160.23.86"
    vm1_nginx_internal_ip = "nginx: 10.0.10.14"
*/
