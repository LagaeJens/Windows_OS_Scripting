#
# Making a share remotely
#! - Select juiste driveletter
#! - name: public
# - share perms: everyone - full control
# - NTFS perms: Administrators - full control and DL-Personeel - modify
#

$fileServer = "win00-dc2"

$systemShare = "C$"
$driveLetter = $systemShare.replace("$", ":")
$shareName = "Public"
$localPath = $driveLetter + "\" + $shareName
$UNCPath = "\\" + $fileServer + "\" + $systemShare + "\" + $shareName

$modifyGroup = "DL-Personeel"

if (Get-Item -Path $UNCPath -ErrorAction SilentlyContinue) {
    Write-Output "$UNCPath already exists ..."   
}
else {
    Write-Output "Creating $Path ..." 
    
    New-Item -Path $Path -type directory -Force | Out-Null
}

if (Get-SmbShare -CimSession $FileServer -Name $Share -ErrorAction SilentlyContinue) {
    Write-Output "$LocalPath already shared on $FileServer ..."
}
else {
    Write-Output "Sharing $localPath on $fileServer as $shareName ..." 

    New-SmbShare -CimSession $fileServer -Name $shareName -Path $localPath -FullAccess Everyone | Out-Null
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

 
# Setting Modify for a Domain Local Group
$Identity = $modifyGroup
$Permission = "Modify"
$Inheritance = "ContainerInherit, ObjectInherit"
$Propagation = "None"
$AccessControlType = "Allow"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule
      ($Identity, $Permission, $Inheritance, $Propagation, $AccessControlType)
$acl.AddAccessRule($rule)

Set-Acl $UNCPath $acl
