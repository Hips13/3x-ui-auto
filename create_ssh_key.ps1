# Navigate to the .ssh directory
$sshDir = "$env:USERPROFILE\.ssh"
if (-Not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir
}
cd $sshDir

# Generate an SSH key named "vpn" without a passphrase
ssh-keygen -t rsa -b 4096 -C "vpn_key" -f "$sshDir\vpn" -N '""'

# Check if the key was created successfully
if ((Test-Path "$sshDir\vpn") -and (Test-Path "$sshDir\vpn.pub")) {
    Write-Host "SSH key 'vpn' successfully created in the folder: $sshDir" -ForegroundColor Green

    # Open the public key in Notepad
    $publicKeyPath = "$sshDir\vpn.pub"
    notepad $publicKeyPath
} else {
    Write-Host "Error: Failed to create the SSH key." -ForegroundColor Red
}
