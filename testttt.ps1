param(
    [string]$HostName,
    [string]$IpAddress,
    [string]$SubnetMask,
    [string]$DefaultGateway,
    [string]$DnsServer1,
    [string]$DnsServer2,
    [string]$TimeZone,
    [string]$InterfaceAlias
)

# Stop script if there is an error
$ErrorActionPreference = "Stop"

# Stop for 5 seconds after each step
$Delay = New-TimeSpan -Seconds 5

# Prompt user to fill in details if not provided as arguments
if (-not $HostName) {
    $HostName = Read-Host "Please enter the hostname"
}
if (-not $IpAddress) {
    $IpAddress = Read-Host "Please enter the IP address"
}
if (-not $SubnetMask) {
    $SubnetMask = Read-Host "Please enter the subnet mask"
}
if (-not $DefaultGateway) {
    $DefaultGateway = Read-Host "Please enter the default gateway"
}
if (-not $DnsServer1) {
    $DnsServer1 = Read-Host "Please enter the primary DNS server"
}
if (-not $DnsServer2) {
    $DnsServer2 = Read-Host "Please enter the secondary DNS server"
}
if (-not $TimeZone) {
    $TimeZone = Read-Host "Please enter the time zone (e.g. 'Central Standard Time')"
}
if (-not $InterfaceAlias) {
    $InterfaceAlias = Read-Host "Please enter the network interface alias"
}

# Set hostname
Write-Host "Setting hostname to $HostName"
Rename-Computer -NewName $HostName -Force
Start-Sleep -Seconds $Delay.TotalSeconds

# Configure network settings
Write-Host "Configuring network settings"
$NIC = Get-NetAdapter -InterfaceAlias $InterfaceAlias
$IPConfig = @{
    AddressFamily  = "IPv4"
    IPAddress      = $IpAddress
    InterfaceIndex = $NIC.ifIndex
    DefaultGateway = $DefaultGateway
    PrefixLength   = $SubnetMask
}
try {
    Set-NetIPAddress @IPConfig -ErrorAction Stop
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
Start-Sleep -Seconds $Delay.TotalSeconds

# Set DNS servers
Write-Host "Setting DNS servers"
$DNSConfig = @{
    InterfaceIndex  = $NIC.ifIndex
    ServerAddresses = @($DnsServer1, $DnsServer2)
}
try {
    Set-DnsClientServerAddress @DNSConfig -ErrorAction Stop
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
Start-Sleep -Seconds $Delay.TotalSeconds

# Set time zone
Write-Host "Setting time zone to $TimeZone"
Set-TimeZone -Name $TimeZone
Start-Sleep -Seconds $Delay.TotalSeconds

# Enable Remote Desktop
Write-Host "Enabling Remote Desktop"
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Start-Sleep -Seconds $Delay.TotalSeconds

# Disable IE Enhanced Security Settings
Write-Host "Disabling IE Enhanced Security Settings"
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
Start-Sleep -Seconds $Delay.TotalSeconds

# Set Control Panel view to "Small icons"
Write-Host "Setting Control Panel view to 'Small icons'"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "AllItemsIconView" -Value 1
Start-Sleep -Seconds $Delay.TotalSeconds

# Show file extensions in Windows Explorer
Write-Host "Showing file extensions in Windows Explorer"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
Start-Sleep -Seconds $Delay.TotalSeconds

# Restart computer
Write-Host "Restarting computer ..."
Restart-Computer -Force -ErrorAction Stop

