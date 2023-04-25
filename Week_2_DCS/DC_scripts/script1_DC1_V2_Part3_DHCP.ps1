#
# Install the DHCP Server Role on DC1
#

$ComputerName = $env:COMPUTERNAME
$UserDNSDomain = $env:USERDNSDOMAIN.ToLower()

$scopeId = "192.168.1.0"
$scopeName = "My first scope"
$scopeDescription = "My first scope"
$startRange = "192.168.1.1"
$endRange = "192.168.1.254"
$subnetMask = "255.255.255.0"

$excludeStartRange = "192.168.1.1"
$excludeEndRange = "192.168.1.10"

$defaultGateway = "192.168.1.1"

$DNSServers = @("192.168.1.2", "192.168.1.3")

$eth0 = Get-NetAdapter -Physical | Where-Object { $_.PhysicalMediaType -match "802.3" -and $_.status -eq "up" }
$ip = $eth0 | Get-NetIPAddress -AddressFamily IPv4

$WindowsFeature = "DHCP"
if (Get-WindowsFeature $WindowsFeature -ComputerName $ComputerName | Where-Object { $_.installed -eq $false }) {
    Write-Output "Installing $WindowsFeature ..."
    Install-WindowsFeature $WindowsFeature -ComputerName $ComputerName -IncludeManagementTools
}
else {
    Write-Output "$WindowsFeature already installed ..."
}

#
# Authorizing DHCP server in AD
#
if (Get-DhcpServerInDC | Where-Object { $_.IPAddress -match $ip.IPAddress }) {
    Write-Output "DHCP server already authorized!"
}
else {
    Write-Output "Authorizing the DHCP server in AD ..."
    
    Add-DhcpServerInDC -IPAddress $ip.ipaddress -DnsName $UserDNSDomain

    #Notify Server Manager that post-install DHCP configuration is complete

    Set-ItemProperty –Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 –Name ConfigurationState –Value 2
}

#
# Test if scope already exists
#

if (get-dhcpserverv4Scope $scopeId -ErrorAction SilentlyContinue) {
    Write-Output "DHCP Scope $scopeId already exists!"
}
else {
    #
    # Configure first scope
    #
    Write-Output "Creating DHCP Scope $scopeId ..."

    Add-DhcpServerv4Scope `
        -Computername $ComputerName `
        -Name $scopeName `
        -Description $scopeDescription `
        -StartRange $startRange `
        -EndRange $endRange `
        -SubnetMask $subnetMask `
        -LeaseDuration 8:0:0:0 `
        -State Active
    
    Add-Dhcpserverv4ExclusionRange `
        -Computername $ComputerName `
        -ScopeID $scopeId `
        -StartRange $excludeStartRange `
        -EndRange $excludeEndRange

    Set-DhcpServerv4OptionValue `
        -ComputerName $ComputerName `
        -ScopeID $scopeId `
        -Router $defaultGateway

    Add-DhcpServerv4Reservation `
        -ComputerName $ComputerName `
        -ScopeID $scopeId `
        -IPAddress 192.168.1.200 `
        -Name "printer1.$UserDNSDomain" `
        -ClientId "00-11-22-33-44-55" `
        -Description "HP Color Laserjet"
}

#
# Configuring DHCP Server Options
#

Set-DhcpServerv4OptionValue `
    -ComputerName $ComputerName ` -DnsServer $DNSServers ` -DNSDomain $UserDNSDomain ` -Force 
