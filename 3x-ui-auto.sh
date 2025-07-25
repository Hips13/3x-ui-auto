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
            * ) echo "Введи y или n." ;;
        esac
    done
}

apt update && apt upgrade -y

if [ -d "/etc/ssh/sshd_config.d" ]; then
  rm -f /etc/ssh/sshd_config.d/*
fi

RANDOM_PORT=$((RANDOM % 30001 + 30000))

SSHD_CONFIG="/etc/ssh/sshd_config"
sed -i "s/^#Port.*/Port $RANDOM_PORT/" $SSHD_CONFIG
sed -i "s/^Port.*/Port $RANDOM_PORT/" $SSHD_CONFIG

color_text green "В терминале Windows (правой кнопкой по пуску - терминал) выполнить скрипт для генерации SSH ключа:"
printf '\e[34m%s\e[0m\n' "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Hips13/3x-ui-auto/main/create_ssh_key.ps1'))"

confirm_continue

echo "Ввести SSH ключ (завершить ввод пустой строкой):"
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

systemctl restart ssh

systemctl restart sshd

mkdir -p /etc/ssl/private /etc/ssl/certs
openssl req -x509 -newkey rsa:4096 -nodes -sha256 -keyout /etc/ssl/private/private.key -out /etc/ssl/certs/public.key -days 3650 -subj "/CN=APP"

echo "Путь SSL ключа для панели:"
color_text green "/etc/ssl/private/private.key"
color_text green "/etc/ssl/certs/public.key"

confirm_continue

EXTERNAL_IP=$(curl -s ifconfig.me)

color_text green "Теперь подключение к серверу будет выполняться командой:"
printf '\e[34m%s\e[0m\n' "ssh root@$EXTERNAL_IP -p $RANDOM_PORT -i \"C:\Users\\имя пользователя\\.ssh\\vpn\""

confirm_continue

bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
