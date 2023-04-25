#
# Install the Certificate Authority of the Active Directory Cerficate Services
#

$WindowsFeature = "ADCS-Cert-Authority"
if (Get-WindowsFeature $WindowsFeature -ComputerName $env:COMPUTERNAME | Where-Object { $_.installed -eq $false }) {
    Write-Output "Installing $WindowsFeature ..."
    Install-WindowsFeature $WindowsFeature -ComputerName $env:COMPUTERNAME -IncludeManagementTools
}
else {
    Write-Output "$WindowsFeature already installed on $env:COMPUTERNAME ..."
}
