# Prompt the user to enter the domain name and administrator credentials
Add-Type -AssemblyName Microsoft.VisualBasic
$DomainName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the name of the new domain (e.g. example.com)")
$DomainAdmin = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the domain administrator credentials")

# Install the AD DS role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Promote the server to a domain controller in a new forest and domain
Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName $DomainName.Split('.')[0] `
    -ForestMode Win2012R2 `
    -DomainMode Win2012R2 `
    -DomainAdministratorCredential $DomainAdmin `
    -InstallDNS:$true `
    -NoRebootOnCompletion:$false

# Prompt the user to enter the DNS server IP addresses
$DnsPrimary = Read-Host "Enter the IP address of the primary DNS server"
$DnsSecondary = Read-Host "Enter the IP address of the secondary DNS server"

# Set the DNS server IP addresses
Get-NetAdapter | Where-Object { $_.InterfaceDescription -like "*Ethernet*" } | Set-DnsClientServerAddress -ServerAddresses ($DnsPrimary, $DnsSecondary)

# Reboot the server to complete the domain controller installation
# Restart-Computer -Force
