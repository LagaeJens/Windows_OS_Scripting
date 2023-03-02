# Test network configuration commands separately

# Define network configuration parameters
$HostName = "mycomputer"
$IpAddress = "192.168.1.100"
$SubnetMask = "24"
$DefaultGateway = "192.168.1.1"
$DnsServer1 = "8.8.8.8"
$DnsServer2 = "8.8.4.4"
$InterfaceAlias = "Ethernet"

# Stop script if there is an error
$ErrorActionPreference = "Stop"

# Stop for 5 seconds after each step
$Delay = New-TimeSpan -Seconds 5

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
