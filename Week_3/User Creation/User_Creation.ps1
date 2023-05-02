#
# Creating users in AD
#
# *** Make sure the root folder for the user home folders already exists and is already shared
#

$userNames = Import-Csv ".\UserAccounts.csv" -Delimiter ";"

$UPNSuffix = 'mijnschool.be'

$homeServer = "win15-ms"
$homeShare = "Homedirs"

Foreach ($User in $userNames) { 
    $userName = $User.Name
    $samAccountName = $User.SamAccountName
    $userPrincipalName = $User.Name + "@" + $UPNSuffix
    $displayName = $User.DisplayName
    $givenName = $User.GivenName
    $surName = $User.SurName
    $homeDrive = $User.HomeDrive
    $homeDirectory = "\\" + $homeServer + "\" + $homeShare + "\" + $User.Name
    $objectPath = $User.Path

    $accountPassword = ConvertTo-SecureString $User.AccountPassword -AsPlainText -force

    try {
        Get-ADUser -identity $samAccountName | Out-Null
        Write-Output "$Name already exists in $Path!"
    }
    catch {
        Write-Output "Making $User.Name in $Path ..." 

        New-ADUser -Name $userName -SamAccountName $samAccountName -UserPrincipalName $userPrincipalName -DisplayName $displayName -GivenName $givenName -Surname $surName -HomeDrive $homeDrive -HomeDirectory $homeDirectory -Path $objectPath -AccountPassword $accountPassword -Enabled:$true
	    
        New-Item -Path $homeDirectory -type directory -Force
    
        $acl = Get-Acl $homeDirectory

        # Enable inheritance and copy permissions
        $acl.SetAccessRuleProtection($False, $True)
        # Setting Modify for the User account
        $Identity = $userPrincipalName
        $Permission = "Modify"
        $Inheritance = "ContainerInherit, ObjectInherit"
        $Propagation = "None"
        $AccessControlType = "Allow"
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule
	        ($Identity, $Permission, $Inheritance, $Propagation, $AccessControlType)
        $acl.AddAccessRule($rule)
 
        Set-Acl $HomeDirectory $acl
    }
}
