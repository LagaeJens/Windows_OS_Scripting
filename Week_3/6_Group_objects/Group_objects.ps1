$GroupNames = Import-Csv ".\Groups.csv" -Delimiter ";"
 
Foreach ($Group in $GroupNames) { 
    $Name = $Group.Name
    $DisplayName = $Group.DisplayName
    $Path = $Group.Path
    $GroupCategory = $Group.GroupCategory
    $GroupScope = $Group.GroupScope

    try {
        Get-ADGroup -Identity $Name | Out-Null
        Write-Output "Group $Name in $Path already exists!"
    }
    catch {
        Write-Output "Making group $Name in $Path"
        New-ADGroup -Name $Name -SamAccountName $Name -GroupCategory $GroupCategory -GroupScope $GroupScope -DisplayName $DisplayName -Path $Path
    }
}
