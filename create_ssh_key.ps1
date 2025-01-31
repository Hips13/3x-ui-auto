# Переход в папку .ssh
$sshDir = "$env:USERPROFILE\.ssh"
if (-Not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir
}
cd $sshDir

# Генерация SSH-ключа с именем "vpn" и без пароля
ssh-keygen -t rsa -b 4096 -C "vpn_key" -f "$sshDir\vpn" -N '""'

# Проверка, создан ли ключ
if ((Test-Path "$sshDir\vpn") -and (Test-Path "$sshDir\vpn.pub")) {
    Write-Host "SSH-ключ 'vpn' успешно создан в папке $sshDir" -ForegroundColor Green

    # Чтение и вывод публичного ключа зеленым цветом
    $publicKey = Get-Content -Path "$sshDir\vpn.pub"
    Write-Host "Публичная часть ключа:" -ForegroundColor Green
    Write-Host $publicKey -ForegroundColor Green
} else {
    Write-Host "Ошибка при создании SSH-ключа." -ForegroundColor Red
}
