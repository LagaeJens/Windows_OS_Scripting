# Prompt for hostname, local IP address, and DNS server addresses
Add-Type -AssemblyName Microsoft.VisualBasic
$hostname = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the hostname for this server (e.g. DC01)", "Hostname")
$localIP = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the local IP address for this server (e.g. 192.168.0.10)", "Local IP address")
$dnsServers = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the DNS server addresses for this server (comma-separated list, e.g. 8.8.8.8,8.8.4.4)", "DNS server addresses")

# Convert comma-separated list to array
$dnsServers = $dnsServers -split ","

try {
    # Set hostname
    Write-Host "Setting hostname to $hostname ..."
    Rename-Computer -NewName $hostname -ErrorAction Stop
    Start-Sleep -Seconds 5

    # Set local IP address
    Write-Host "Setting local IP address to $localIP ..."
    New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $localIP -PrefixLength 24 -DefaultGateway "192.168.0.1" -ErrorAction Stop
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $dnsServers -ErrorAction Stop
    Start-Sleep -Seconds 5

    # Set time zone
    Write-Host "Setting time zone ..."
    Set-TimeZone -Id "Central Standard Time" -ErrorAction Stop
    Start-Sleep -Seconds 5

    # Enable remote desktop access
    Write-Host "Enabling remote desktop access ..."
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 -ErrorAction Stop
    Start-Sleep -Seconds 5

    # Disable IE Enhanced Security Setting
    Write-Host "Disabling IE Enhanced Security Setting ..."
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -ErrorAction Stop
    Start-Sleep -Seconds 5

    # Set Control Panel view to "Small icons"
    Write-Host "Setting Control Panel view to 'Small icons' ..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "AllItemsIconView" -Value 1 -ErrorAction Stop
    Start-Sleep -Seconds 5

    # Show file extensions in Windows Explorer
    Write-Host "Showing file extensions in Windows Explorer ..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -ErrorAction Stop
    Start-Sleep -Seconds 5

    # Restart computer
    Write-Host "Restarting computer ..."
    Restart-Computer -Force -ErrorAction Stop
}
catch {
    Write-Error "Error occurred during step: $($_.InvocationInfo.ScriptLineNumber). `nError message: $($_.Exception.Message)"
    Pause
    exit 1
}