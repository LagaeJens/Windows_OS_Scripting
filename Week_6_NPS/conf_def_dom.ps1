#
# Configure a default Domain CA
#

$Credential = get-credential -Credential "$env:USERDOMAIN\$env:USERNAME"

$CryptoProviderName = "RSA#Microsoft Software Key Storage Provider"
$KeyLength = 4096
$HashAlgorithmName = ”SHA256”
$ValidityPeriod = ”Years”
$ValidityPeriodUnits = 10

Install-AdcsCertificationAuthority -CAType EnterpriseRootCa -Credential $Credential -CryptoProviderName $CryptoProviderName-KeyLength $KeyLength -HashAlgorithmName $HashAlgorithmName -ValidityPeriod $ValidityPeriod -ValidityPeriodUnits $ValidityPeriodUnits -Confirm:$False | Out-Null


#
# Install Network Policy and Access Services
#

$WindowsFeature = "NPAS"
if (Get-WindowsFeature $WindowsFeature -ComputerName $env:COMPUTERNAME | Where-Object { $_.installed -eq $false }) {
    Write-Output "Installing $WindowsFeature ..."
    Install-WindowsFeature $WindowsFeature -ComputerName $env:COMPUTERNAME -IncludeManagementTools
}
else {
    Write-Output "$WindowsFeature already installed on $env:COMPUTERNAME ..."
}

#
# Registering NPS in Active Directory by adding DC1 to the group ‘RAS and IAS Servers’
#
$Identity = "RAS and IAS Servers"
$Members = Get-ADComputer -identity $env:COMPUTERNAME

try {
    Add-ADGroupMember -Identity $Identity -Members $Members
    Write-Output "Adding $Members to $Identity ..."
}
catch {
    Write-Output "The NPS server $Members is already member of $Identity ..."
}

