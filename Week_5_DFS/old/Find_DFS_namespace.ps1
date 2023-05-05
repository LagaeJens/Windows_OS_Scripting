#
# Finding DFS Namespaces and Folders
#
#! select juiste domain name!!!

# $UserDNSDomain = ”intranet.mct.be”
$DFSRoot = Get-DfsnRoot -Domain $UserDNSDomain | Where-object ( { $_.State -eq 'Online' } ) | Select-Object -ExpandProperty Path
Write-Host “The DFSRoot is $DFSRoot”

Write-Host “Getting DFS Folders …”
Get-DfsnFolder -Path "$DFSRoot\*" | Select-Object -ExpandProperty Path
