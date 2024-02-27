sys-23 Bazylev Artem

## 1. Terrafom. Развертывание инфраструктуры.

### 1.1 Основная Конфигурация (main.tf)

**Описание:** Файл `main.tf` описывает провайдера, параметры подключения, использует файл с описанием переменных `variables.tf` и переменные из файла `terraform.tfvars`. Также используется файл `locals.tf` для создания подсетей с использованием цикла `for_each`.

### 1.2. Создание ВМ (vms.tf)

**Описание:** Файл `vms.tf` описывает создание виртуальных машин для проекта. Операционная система - Linux Debian 11. Инфраструктура включает в себя:

- `web1` и `web2`: веб-серверы, отдающие статическую страницу, идентичны, без внешнего IP-адреса.
- `zabbix`: ВМ для развертывания сервера мониторинга Zabbix, с внешним IP-адресом.
- `elastic`: ВМ для ELK-системы сбора логов, без внешнего IP-адреса.
- `kibana`: ВМ веб-интерфейс для Elasticsearch, с внешним IP-адресом.
- `bastion`: ВМ для реализации bastion host, с внешним IP-адресом для SSH-подключений ко всем ВМ.

### 1.3. Сетевая Инфраструктура (network.tf)

**Описание:** Файл `network.tf` описывает создание сетевой инфраструктуры, включая сеть, подсети, target и backend группы, HTTP-роутер и сервис Application Load Balancer. Также создаются Security Groups для соответствующих сервисов.

### 1.4. Вывод Информации (output.tf)

**Описание:** Файл `output.tf` выводит информацию об IP-адресах создаваемых ВМ и сервисах, а также формирует параметры для SSH-подключения.

### 1.5. Резервное Копирование Дисков (snapshot.tf)

**Описание:** Файл `snapshot.tf` организует систему резервного копирования дисков всех ВМ.

### 1.6. Результаты и Резервное Копирование

**Описание:** После успешного запуска Terraform в Yandex Cloud развернута необходимая инфраструктура.

### 2. Подготовка Инвентаризации для Ansible

1. Создается файл инвентаризации `hosts` на основе результатов файла `output.tf`:
    ```bash
    terraform output output-ansible-hosts > ./ansible/hosts
    cd ./ansible
    sed -i '1d; $d' hosts
    ```

2. Пример файла инвентаризации:
```
[bastion]
bastion-host ansible_host=84.201.130.69 ansible_ssh_user=user-data

[webservers]
web1 ansible_host=web1.ru-central1.internal
web2 ansible_host=web2.ru-central1.internal

[elastic]
elastic-host ansible_host=elastic.ru-central1.internal

[kibana]
kibana-host ansible_host=kibana.ru-central1.internal

[zabbix]
zabbix-host ansible_host=zabbix.ru-central1.internal

[webservers:vars]
ansible_ssh_user=user-data
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p user-data@84.201.130.69"'

[elastic:vars]
ansible_ssh_user=user-data
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p user-data@84.201.130.69"'

[kibana:vars]
ansible_ssh_user=user-data
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p user-data@84.201.130.69"'

[zabbix:vars]
ansible_ssh_user=user-data
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p user-data@84.201.130.69"'
```
    Развернутая инфроструктура
![Yandex_1](https://github.com/VVEREW01F/diplom_sys/blob/main/IMG/yandex_1.PNG)
![Yandex_2](https://github.com/VVEREW01F/diplom_sys/blob/main/IMG/yandex_2.PNG)


## 2. Ansible. Настройка инфраструктуры.

### 2.1. Проверка доступности хостов через ВМ bastion

Начальный этап проверки доступности всех хостов.
![Ansible_ping](https://github.com/VVEREW01F/diplom_sys/blob/main/IMG/ansible_ping.PNG)

### 2.2. Настройка Веб-серверов

Запуск скрипта 1-webserv-playbook.yml для разворачивания и запуска HTTP-серверов Nginx на двух ВМ. Передача начального набора файлов для сайта и замена конфигурационного файла nginx.conf.
![nginx](https://github.com/VVEREW01F/diplom_sys/blob/main/IMG/nginx.PNG)

### 2.3. Настройка сервера Elasticsearch

Запуск скрипта 2-elastic-playbook.yml для разворачивания сервера Elasticsearch в Docker-контейнере. Установка Docker и необходимых пакетов.
![Elastic](https://github.com/VVEREW01F/diplom_sys/blob/main/IMG/elastic.PNG)

### 2.4. Настройка Kibana

Запуск скрипта 3-kibana-playbook.yml для разворачивания Docker-контейнера с Kibana (веб-интерфейс для Elasticsearch). Установка Docker и необходимых пакетов.
![Elastic_1](https://github.com/VVEREW01F/diplom_sys/blob/main/IMG/kibana.PNG)
![Kibana](https://github.com/VVEREW01F/diplom_sys/blob/main/IMG/elastic_1.PNG)
### 2.5. Настройка Filebeat

Запуск скрипта 4-filebeat-playbook.yml для установки, настройки и запуска ПО Filebeat на ВМ с веб-серверами. Конфигурация настроена на отправку access.log и error.log Nginx в Elasticsearch.
![filebeat](https://github.com/VVEREW01F/diplom_sys/blob/main/IMG/filebit.PNG)

### 2.6. Настройка сервера мониторинга Zabbix

Запуск скрипта 5-zabbix_server-playbook.yml для разворачивания сервера мониторинга Zabbix. Начальная конфигурация базы данных, правка конфигурационного файла zabbix_server.conf.
![zabbix](https://github.com/VVEREW01F/diplom_sys/blob/main/IMG/zabbix_1.PNG)

### 2.7. Установка Zabbix-agent на все ВМ

Запуск скрипта 6-zabbix_agent-playbook.yml для установки ПО Zabbix-agent на все ВМ. Настройка конфигурационного файла zabbix_agentd.conf.
![agent](https://github.com/VVEREW01F/diplom_sys/blob/main/IMG/agent.PNG)

В результате установки необходимого ПО мониторинга можно приступить к настройке отображения информации в веб-интерфейсе сервера Zabbix.
