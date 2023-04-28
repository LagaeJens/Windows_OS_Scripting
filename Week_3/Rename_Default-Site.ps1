#
# Renaming Default-First-Site-Name + assigning the subnet
#

$newSiteName = "Kortrijk"   
$ipSubnet = "192.168.1.0/24"

if ($ADReplicationSite = Get-ADReplicationSite "Default-First-Site-Name" -ErrorAction SilentlyContinue) {
    Write-Output "Renaming Default-First-Site-Name ..."
    $ADReplicationSite | Rename-ADObject -NewName $newSiteName
    Get-ADReplicationSite $newSiteName | Set-ADReplicationSite -Description $newSiteName
    New-ADReplicationSubnet -Name $ipSubnet -Site $newSiteName -Description $newSiteName -Location $newSiteName
}
else {
    Write-Output "Default-First-Site-Name already renamed!"
}

#
# Creating extra site(s) and subnet(s)
#

$newSiteName = "Brugge"
$ipSubnet = "192.168.2.0/24"

if ($ADReplicationSite = Get-ADReplicationSite $newSiteName -ErrorAction SilentlyContinue) {
    Write-Output "Site $newSiteName already exists!"
}
else {
    Write-Output "Creating new site $newSiteName ..."

    New-ADReplicationSite -Name $newSiteName -Description $newSiteName
    New-ADReplicationSubnet -Name $ipSubnet -Site $newSiteName -Description $newSiteName -Location $newSiteName
}
