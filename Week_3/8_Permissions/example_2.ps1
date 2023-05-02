#
#
# Making additional shares
#

$Group = "DL-Secretariaat"
$Folder = "secretariaat"

#
# Making a shared folder remotely
# - name: desktops
# - share perms: everyone - full control
# - NTFS perms: Administrators - full control and Authenticated Users - Read
#

$FileServer = "win00-dc2"

$systemShare = "C$"
$driveLetter = $systemShare.replace("$", ":")
$shareName = "Desktops"
$LocalPath = $driveLetter + "\" + $shareName
$UNCPath = "\\" + $FileServer + "\" + $systemShare + "\" + $shareName

if (Get-Item -Path $UNCPath -ErrorAction SilentlyContinue) {
    Write-Output "$UNCPath already exists ..."   
}
else {
    Write-Output "Creating $UNCPath ..." 
    New-Item -Path $UNCPath -type directory -Force | Out-Null
}

if (Get-SmbShare -CimSession $FileServer -Name $shareName -ErrorAction SilentlyContinue) {
    Write-Output "$LocalPath already shared on $FileServer ..."
}
else {
    Write-Output "Sharing $LocalPath on $FileServer as $shareName ..." 
    New-SmbShare -CimSession $FileServer -Name $shareName -Path $LocalPath -FullAccess Everyone | Out-Null
}

$acl = Get-Acl $UNCPath

# Disable inheritance and remove all permissions
$acl.SetAccessRuleProtection($True, $False)

 
# Setting Full Control for Administrators
$Identity = ”Administrators”
$Permission = "Fullcontrol"
$Inheritance = "ContainerInherit, ObjectInherit"
$Propagation = "None"
$AccessControlType = "Allow"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule
      ($Identity, $Permission, $Inheritance, $Propagation, $AccessControlType)
$acl.AddAccessRule($rule)

# Setting Read & Execute for Authenticated Users on This Folder only
$Identity = ”Authenticated Users”
$Permission = "ReadAndExecute"
$Inheritance = "None"
$Propagation = "NoPropagateInherit"
$AccessControlType = "Allow"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule
      ($Identity, $Permission, $Inheritance, $Propagation, $AccessControlType)
$acl.AddAccessRule($rule)

Set-Acl $UNCPath $acl

#
# Making a subfolder for $Folder
# - name: $Folder
# - NTFS perms: Administrators - full control and $Group - read
#
$UNCPath = $UNCPath + "\" + $Folder

if (Get-Item -Path $UNCPath -ErrorAction SilentlyContinue) {
    Write-Output $UNCPath "already exists ..."   
}
else {
    Write-Output "Creating $UNCPath ..." 
    New-Item -Path $UNCPath -type directory -Force | Out-Null
}

$acl = Get-Acl $UNCPath

# Enable inheritance and copy permissions
$acl.SetAccessRuleProtection($False, $True)

# Setting Read & Execute for a Domain Local Group
$Identity = $Group
$Permission = "ReadAndExecute"
$Inheritance = " ContainerInherit, ObjectInherit"
$Propagation = "None"
$AccessControlType = "Allow"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule
      ($Identity, $Permission, $Inheritance, $Propagation, $AccessControlType)
$acl.AddAccessRule($rule)

Set-Acl $UNCPath $acl
