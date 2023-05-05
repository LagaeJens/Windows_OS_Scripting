#
# "Promote" a standalone server to a Domain Controller (=DC)
#

#! dit het juiste invoeren !!!!!
# $UserDNSDomain = "intranet.mijnschool.be"
# $UserDomain = "mijnschool"

#
# Install Active Directory Domain Services - ADDS
#

$WindowsFeature = "AD-Domain-Services"
if (Get-WindowsFeature $WindowsFeature -ComputerName $env:COMPUTERNAME | Where-Object { $_.installed -eq $false }) {
    Write-Output "Installing $WindowsFeature ..."
    Install-WindowsFeature $WindowsFeature -ComputerName $env:COMPUTERNAME -IncludeManagementTools
}
else {
    Write-Output "$WindowsFeature already installed ..."
}

#
# Create a new forest and the first DC
#

Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\windows\NTDS" `
    -DomainName $UserDNSDomain `
    -DomainNetbiosName $UserDomain `
    -InstallDns:$true `
    -LogPath "C:\windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\windows\SYSVOL" `
    -Force:$true


