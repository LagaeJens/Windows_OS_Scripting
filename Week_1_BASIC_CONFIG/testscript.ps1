# Prompt for hostname
$hostname = Read-Host "Enter the hostname for this server (e.g. DC01)"

# Prompt for local IP address
$localIP = Read-Host "Enter the local IP address for this server (e.g. 192.168.0.10)"

# Prompt for DNS server addresses
$dnsServers = Read-Host "Enter the DNS server addresses for this server (comma-separated list, e.g. 8.8.8.8,8.8.4.4)"

# Convert comma-separated list to array
$dnsServers = $dnsServers -split ","

# Set hostname
Write-Host "Setting hostname to $hostname ..."
Rename-Computer -NewName $hostname

# Set local IP address
Write-Host "Setting local IP address to $localIP ..."
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $localIP -PrefixLength 24 -DefaultGateway "192.168.0.1"
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $dnsServers

# Set time zone
Write-Host "Setting time zone ..."
Set-TimeZone -Id "Central Standard Time"

# Enable remote desktop access
Write-Host "Enabling remote desktop access ..."
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

# Disable IE Enhanced Security Setting
Write-Host "Disabling IE Enhanced Security Setting ..."
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0

# Set Control Panel view to "Small icons"
Write-Host "Setting Control Panel view to 'Small icons' ..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "AllItemsIconView" -Value 1

# Show file extensions in Windows Explorer
Write-Host "Showing file extensions in Windows Explorer ..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0

# Restart computer
Write-Host "Restarting computer ..."
Restart-Computer -Force
