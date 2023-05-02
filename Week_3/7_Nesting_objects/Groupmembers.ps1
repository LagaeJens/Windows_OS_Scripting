$Members = Import-Csv ".\GroupMembers.csv" -Delimiter ";"
 
Foreach ($Member in $Members) { 
    $Identity = $Member.Identity
    $Members = $Member.Member

    try {
        Write-Output "Adding" $Members "to" $Identity
        Add-ADGroupMember -Identity $Identity -Members $Members
    }
    catch {
        Write-Output $Members "not added to" $Identity
    }
}
