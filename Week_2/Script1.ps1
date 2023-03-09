# Prompt the user to enter the domain name and administrator credentials
Add-Type -AssemblyName Microsoft.VisualBasic
$DomainName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the hostname for this server (e.g. DC01)", "Hostname")
$Username = "administrator"
$Password = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$DomainAdmin = New-Object System.Management.Automation.PSCredential($Username, $Password)

# Install the AD DS role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Promote the server to a domain controller in a new forest and domain
Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName $DomainName.Split('.')[0] `
    -ForestMode WinThreshold `
    -DomainMode WinThreshold `
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
