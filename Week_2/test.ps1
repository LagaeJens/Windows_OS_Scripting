# Variables
$domainName = "intranet.com"
$domainNetBIOSName = "intranet"
$dcName = "DC1"
$dcIPAddress = "192.168.1.2"
$adminCreds = Get-Credential
$dhcpScopeName = "MyScope"
$dhcpRangeStart = "192.168.1.10"
$dhcpRangeEnd = "192.168.1.200"
$dhcpSubnetMask = "255.255.255.0"
$dhcpRouter = "192.168.1.1"
$dhcpDNSServers = "192.168.1.2"
$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1


# Promote first server to DC
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment
Install-ADDSDomainController `
    -Credential $adminCreds `
    -NoGlobalCatalog:$false `
    -CreateDnsDelegation:$false `
    -Force:$true `
    -Confirm:$false `
    -AllowPasswordReplicationAccountCreation:$true `
    -CriticalReplicationOnly:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -LogPath "C:\Windows\NTDS" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true `
    -NoRebootOnCompletion:$true `
    -SkipPreCheck:$false `
    -Path "C:\Windows\NTDS" `
    -DomainAdministratorCredential $adminCreds `
    -Server $dcName `
    -InstallDns:$true

# Check if necessary role(s) are installed
$roles = Get-WindowsFeature | Where-Object { $_.Name -eq "AD-Domain-Services" -or $_.Name -eq "DNS" }
foreach ($role in $roles) {
    if ($role.Installed -ne $true) {
        # Install necessary role(s)
        Install-WindowsFeature $role.Name
    }
}

# Set DNS server for the domain
Set-DnsClientServerAddress -InterfaceIndex $adapter -ServerAddresses $dcIPAddress

# Configure DHCP server and scope
Add-WindowsFeature DHCP
Add-DhcpServerv4Scope -Name $dhcpScopeName -StartRange $dhcpRangeStart -EndRange $dhcpRangeEnd -SubnetMask $dhcpSubnetMask -State Active
Set-DhcpServerv4OptionValue -OptionId 3 -Value $dhcpRouter -ScopeId $dhcpScopeName
Set-DhcpServerv4OptionValue -OptionId 6 -Value $dhcpDNSServers -ScopeId $dhcpScopeName
