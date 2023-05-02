$OUNames = Import-Csv ".\OUs.csv" -Delimiter ";"
# Default path == C:\Users\Administrator
 
Foreach ($OU in $OUNames) { 
    $Name = $OU.Name
    $DisplayName = $OU.DisplayName
    $Description = $OU.Description
    $Path = $OU.Path
	
    $Identity = "OU=" + $Name + "," + $Path
    try {
        Get-ADOrganizationalUnit -Identity $Identity | Out-Null
        Write-Output "OU $Name already exists in $Path !"
    }
    catch {
        Write-Output "Making OU $Name in $Path ..."
        New-ADOrganizationalUnit -Name $Name -DisplayName $DisplayName  -Description $Description -Path $Path
    }
}
