#
# Change UPN suffix for all users
#

$oldUPNsuffix = "intranet.mijnschool.be"
$newUPNsuffix = "mijnschool.be"

$AllUsers = Get-ADUser -Filter "UserPrincipalName -like '*$oldUPNsuffix'" -Properties UserPrincipalName -ResultSetSize $null
$AllUsers | foreach { $newUpn = $_.UserPrincipalName.Replace($oldUPNsuffix, $newUPNsuffix); $_ | Set-ADUser -UserPrincipalName $newUpn }
