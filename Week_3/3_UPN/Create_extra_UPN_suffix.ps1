#
# Creating an extra UPN suffix
#

$UPNsuffix = "mijnschool.be"

if (Get-ADForest | Where-Object { $_.UPNSuffixes -match $UPNsuffix }) {
    Write-Output "UPN suffix $UPNsuffix already exist!"
}
else {
    Write-Output "Adding UPN suffix $UPN_suffix ..."
    
    Get-ADForest | Set-ADForest -UPNSuffixes @{add = $UPNsuffix }
}
