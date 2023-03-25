Add-Type -AssemblyName Microsoft.VisualBasic

# promote to domain controller
$domainname = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the domainname for this server (e.g. intranet.com )")
Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName $domainname -DomainNetBIOSName AD -InstallDNS -NoRebootOnCompletion:$true -Force:$true

# Set ip address and DNS server
$IPAddress = [Microsoft.VisualBasic.Interaction]::InputBox("Domain controller IP address (e.g. 192.168.1.x)")
New-NetIPAddress –IPAddress $IPAddress -DefaultGateway 192.168.1.1 -PrefixLength 24 -InterfaceIndex (Get-NetAdapter).InterfaceIndex
Set-DNSClientServerAddress –InterfaceIndex (Get-NetAdapter).InterfaceIndex –ServerAddresses $IPAddress


#variables
$dcIPAddress = [Microsoft.VisualBasic.Interaction]::InputBox("DNS server IP address nr 1 (e.g. 192.168.1.x)")
$dc2IPAddress = [Microsoft.VisualBasic.Interaction]::InputBox("DNS server IP address nr 2 (e.g. 192.168.1.x)")
$preferredDNSServer = $dcIPAddress
$alternateDNSServer = $dc2IPAddress

# Check and set local DNS servers
$nic = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.Name -eq "Ethernet0" } | Select-Object -First 1
$dnsServers = Get-DnsClientServerAddress -InterfaceIndex $nic.ifIndex | Select-Object -ExpandProperty ServerAddresses
if ($dnsServers[0] -ne $preferredDNSServer -or $dnsServers[1] -ne $alternateDNSServer) {
    $dnsServers = @($preferredDNSServer, $alternateDNSServer)
    Set-DnsClientServerAddress -InterfaceIndex $nic.ifIndex -ServerAddresses $dnsServers
    Write-Host "Local DNS servers updated."
}
else {
    Write-Host "Local DNS servers already set correctly."
}

Add-DnsServerPrimaryZone -NetworkId "192.168.1.0/24" -ReplicationScope Domain
Add-DnsServerResourceRecordPtr -Name "10" -ZoneName "1.168.192.in-addr.arpa" -AllowUpdateAny -TimeToLive 01:00:00 -AgeRecord -PtrDomainName "DC1.ad.$domainname"


# Variables
$dhcpScope = "192.168.1.0"
$dhcpRangeStart = "192.168.1.15"
$dhcpRangeEnd = "192.168.1.252"
$dhcpSubnetMask = "255.255.255.0"
$dhcpRouter = "192.168.1.0"
$dhcpDNSServers = "192.168.1.2", "192.168.1.3"

# Check if DHCP server role is installed and install if necessary
if ((Get-WindowsFeature -Name DHCP).Installed -ne "True") {
    Install-WindowsFeature -Name DHCP
    Write-Host "DHCP server role installed."
}
else {
    Write-Host "DHCP server role already installed."
}

# Configure DHCP server and scope
Add-DhcpServerv4Scope -Name "Main Scope" -StartRange $dhcpRangeStart -EndRange $dhcpRangeEnd -SubnetMask $dhcpSubnetMask -ScopeId $dhcpScope -State Active
Set-DhcpServerv4OptionValue -OptionId 3 -Value $dhcpRouter -ScopeId $dhcpScope
Set-DhcpServerv4OptionValue -OptionId 6 -Value $dhcpDNSServers -ScopeId $dhcpScope
Set-DhcpServerv4OptionValue -OptionId 15 -Value $domainName

# Authorize DHCP server and remove warning in Server Manager
Add-DhcpServerInDC -DnsName $env:COMPUTERNAME -IPAddress $dcIPAddress
Set-DhcpServerDnsCredential -Credential (Get-Credential)
Set-DhcpServerMode -DhcpServerMode "Both"
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ServerManager\Roles" -Name "PendingXmlIdentifier" -Force
Write-Host "DHCP server authorized and configured."