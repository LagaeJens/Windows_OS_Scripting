# Set share name and path
$ShareName = "DataShare"
$SharePath = "D:\DataShare"

# Create share folder
New-Item -ItemType Directory -Path $SharePath

# Create the SMB share
New-SmbShare -Name $ShareName -Path $SharePath -FullAccess "Domain Admins" -ChangeAccess "Domain Users"

# Set share permissions
$Acl = Get-Acl $SharePath
$Ar1 = New-Object System.Security.AccessControl.FileSystemAccessRule("Domain Admins", "FullControl", "Allow")
$Ar2 = New-Object System.Security.AccessControl.FileSystemAccessRule("Domain Users", "ReadAndExecute", "Allow")
$Acl.SetAccessRuleProtection($true, $false)
$Acl.SetAccessRule($Ar1)
$Acl.SetAccessRule($Ar2)
Set-Acl $SharePath $Acl

# Create subfolders for departments/business units
$Departments = @("Sales", "Marketing", "Finance", "IT")
foreach ($Department in $Departments) {
    $FolderPath = "$SharePath\$Department"
    New-Item -ItemType Directory -Path $FolderPath

    # Set folder permissions
    $Acl = Get-Acl $FolderPath
    $Ar1 = New-Object System.Security.AccessControl.FileSystemAccessRule("Domain Admins", "FullControl", "Allow")
    $Ar2 = New-Object System.Security.AccessControl.FileSystemAccessRule("$Department", "Modify", "Allow")
    $Ar3 = New-Object System.Security.AccessControl.FileSystemAccessRule("Domain Users", "ReadAndExecute", "Allow")
    $Acl.SetAccessRuleProtection($true, $false)
    $Acl.SetAccessRule($Ar1)
    $Acl.SetAccessRule($Ar2)
    $Acl.SetAccessRule($Ar3)
    Set-Acl $FolderPath $Acl
}
