Add-Type -AssemblyName Microsoft.VisualBasic

# Domain name
$domainName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the domain name (e.g. intranet.mycompany.be)", "Domain name")

# Make netbios name from domain name take middle part
$domainNetbiosName = $domainName.Split(".")[1]
# Make sure the netbios name is not longer than 15 characters
if ($domainNetbiosName.Length -gt 15) {
    $domainNetbiosName = $domainNetbiosName.Substring(0, 15)
}
# Set the domain netbios name to uppercase
$domainNetbiosName = $domainNetbiosName.ToUpper()

# Promote the first server to the first DC for the new forest/domain
Install-ADDSForest -DomainName $domainName -DomainNetbiosName $domainNetbiosName -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "P@ssw0rd" -Force)

# Check if the necessary role(s) is/are installed. If not, install them.
$roles = "AD-Domain-Services", "DNS"
foreach ($role in $roles) {
    if ((Get-WindowsFeature -Name $role).Installed -ne $true) {
        Install-WindowsFeature -Name $role -IncludeManagementTools
    }
}

# Prompt the user to reboot the computer to complete the domain controller installation
if (Read-Host "The server must be rebooted for the changes to take effect. Do you want to reboot now? (Y/N)" -eq "Y") {
    Restart-Computer -Force
}


