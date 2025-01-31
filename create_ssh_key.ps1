$sshDir = "$env:USERPROFILE\.ssh"
if (-Not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir
}
cd $sshDir

ssh-keygen -t rsa -b 4096 -C "vpn_key" -f "$sshDir\vpn" -N '""'

if ((Test-Path "$sshDir\vpn") -and (Test-Path "$sshDir\vpn.pub")) {
    Write-Host "SSH-key 'vpn' created in dir $sshDir" -ForegroundColor White

    $publicKey = Get-Content -Path "$sshDir\vpn.pub"
    Write-Host "Public key, copy to linux:" -ForegroundColor Green
    Write-Host $publicKey -ForegroundColor Green
} else {
    Write-Host "Ошибка при создании SSH-ключа." -ForegroundColor Red
}
