# Define variables
$domainName = "newdomain.com"
$adminUser = "Administrator"
$adminPassword = "P@ssw0rd"
$dnsPrimary = "192.168.1.10"
$dnsSecondary = "192.168.1.11"
$subnet = "192.168.1.0/24"
$firstDCIP = "192.168.1.10"
$dhcpRangeStart = "192.168.1.100"
$dhcpRangeEnd = "192.168.1.200"
$dhcpRouter = "192.168.1.1"
$dhcpDNS = $dnsPrimary, $dnsSecondary

# Promote the first server to the first DC for the new forest/domain
Install-ADDSForest -DomainName $domainName -InstallDNS -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText $adminPassword -Force)

# Check if the necessary role(s) is/are installed. If not, install them.
$roles = "DNS"
foreach ($role in $roles) {
    if ((Get-WindowsFeature -Name $role).Installed -ne $true) {
        Install-WindowsFeature -Name $role -IncludeManagementTools
    }
}

# Set the DNS server IP addresses
Get-NetAdapter | Where-Object { $_.InterfaceDescription -like "*Ethernet*" } | Set-DnsClientServerAddress -ServerAddresses ($dnsPrimary, $dnsSecondary)

# Create the reverse lookup zone for the subnet and add a pointer record for the first domain controller
Add-DnsServerPrimaryZone -Name "1.168.192.in-addr.arpa" -ZoneFile "1.168.192.in-addr.arpa.dns"
Add-DnsServerResourceRecordPtr -ZoneName "1.168.192.in-addr.arpa" -PTRDomainName "dc1.$domainName" -IPv4Address $firstDCIP

# Rename the default site and add the subnet to it
Rename-Item -Path "AD:\Sites\Default-First-Site-Name" -NewName "Site-1"
$site = Get-ADReplicationSubnet -Filter "Name -eq '192.168.1.0/24'"
Set-ADReplicationSubnet -Identity $site -Site "Site-1"

# Install and configure DHCP server
Install-WindowsFeature -Name DHCP -IncludeManagementTools
Add-DhcpServerInDC
Set-DhcpServerDnsCredential -Credential (New-Object System.Management.Automation.PSCredential ($adminUser, (ConvertTo-SecureString $adminPassword -AsPlainText -Force)))
Add-DhcpServerv4Scope -Name "Scope-1" -StartRange $dhcpRangeStart -EndRange $dhcpRangeEnd -SubnetMask "255.255.255.0" -State Active
Set-DhcpServerv4OptionValue -ScopeId 1.168.192.0 -Router $dhcpRouter -DnsServer $dhcpDNS

# Authorize DHCP server
Add-DhcpServerInDC
Set-DhcpServerInDC -DnsCredential (New-Object System.Management.Automation.PSCredential ($adminUser, (ConvertTo-SecureString $adminPassword -AsPlainText -Force))) -DnsUpdateProxy "Any"

# Check if DHCP server is authorized and remove warning in Server Manager
Get-DhcpServerInDC | Set-DhcpServerInDC -Dns
