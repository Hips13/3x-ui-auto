#!/bin/bash

color_text() {
    local color=$1
    local text=$2
    case $color in
        green) echo -e "\e[32m$text\e[0m" ;;
        cyan) echo -e "\e[36m$text\e[0m" ;;
        *) echo "$text" ;;
    esac
}

confirm_continue() {
    while true; do
        read -p "Продолжить? (y/n): " yn
        case $yn in
            [Yy]* ) break ;;
            [Nn]* ) echo "Скрипт остановлен."; exit ;;
            * ) echo "Пожалуйста, введите y или n." ;;
        esac
    done
}

apt update && apt upgrade -y

RANDOM_PORT=$((RANDOM % 30001 + 30000))

SSHD_CONFIG="/etc/ssh/sshd_config"
sed -i "s/^#Port.*/Port $RANDOM_PORT/" $SSHD_CONFIG
sed -i "s/^Port.*/Port $RANDOM_PORT/" $SSHD_CONFIG

color_text green "В терминале вашего Windows (правой кнопкой по пуску - терминал) выполнить скрипт для генерации SSH ключа:"
printf '\e[34m%s\e[0m\n' "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Hips13/3x-ui-auto/main/create_ssh_key.ps1'))"

confirm_continue

echo "Введите ваш SSH ключ (завершите ввод пустой строкой):"
SSH_KEY=""
while IFS= read -r line; do
    if [ -z "$line" ]; then
        break
    fi
    SSH_KEY+="$line"$'\n'
done

mkdir -p /root/.ssh
echo "$SSH_KEY" >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

confirm_continue

sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' $SSHD_CONFIG
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' $SSHD_CONFIG
sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' $SSHD_CONFIG
sed -i 's/^PubkeyAuthentication no/PubkeyAuthentication yes/' $SSHD_CONFIG

systemctl restart sshd
systemctl restart ssh

mkdir -p /etc/ssl/private /etc/ssl/certs
openssl req -x509 -newkey rsa:4096 -nodes -sha256 -keyout /etc/ssl/private/private.key -out /etc/ssl/certs/public.key -days 3650 -subj "/CN=APP"

echo "Путь SSL ключа для панели:"
echo "/etc/ssl/private/private.key"
echo "/etc/ssl/certs/public.key"

confirm_continue

EXTERNAL_IP=$(curl -s ifconfig.me)

echo "Теперь подключение к серверу будет выполняться командой:"
echo "ssh root@$INTERNAL_IP -p $RANDOM_PORT -i \"C:\Users\\имя пользователя\\.ssh\\vpn\""

confirm_continue

bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
