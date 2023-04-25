#
# Join domain
#
$ComputerName = $env:COMPUTERNAME
$UserDNSDomain = "intranet.mijnschool.be"
$Credential = "$env:USERNAME@$UserDNSDomain"

# Check if computer part of domain
if ((Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain) {
    Write-Output "Computer is already member of a domain!"
}
else {
    Write-Output "Adding computer $ComputerName to domain $UserDNSDomain ..."

    Add-Computer –DomainName $UserDNSDomain -Credential $Credential -restart
}
