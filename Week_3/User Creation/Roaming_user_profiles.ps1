#! FIRST RUN THE SCRIPT: Create_users.ps1
#
# Making the root share for storing the roaming user profiles
#

$fileServer = "win00-ms"

$systemShare = "C$"
$driveLetter = $systemShare.replace("$", ":")
$rootShare = "Profiles$"
$localPath = $driveLetter + "\" + $rootShare
$UNCPath = "\\" + $fileServer + "\" + $systemShare + "\" + $rootShare

if (Get-Item -Path $UNCPath -ErrorAction SilentlyContinue) {
    Write-Output "$UNCPath already exists ..."   
}
else {
    Write-Output "Creating $UNCPath ..." 
    New-Item -Path $UNCPath -type directory -Force | Out-Null
}

if (Get-SmbShare -CimSession $fileServer -Name $rootShare -ErrorAction SilentlyContinue) {
    Write-Output "$localPath already shared on $fileServer ..."
}
else {
    Write-Output "Sharing $localPath on $fileServer as $rootShare ..." 
    New-SmbShare -CimSession $fileServer -Name $rootShare -Path $localPath -FullAccess Everyone | Out-Null

    $acl = Get-Acl $UNCPath

    # Disable inheritance and remove all permissions
    $acl.SetAccessRuleProtection($True, $False)

    # Setting Full Control for Administrators
    $Identity = "Administrators"
    $Permission = "FullControl"
    $Inheritance = "ContainerInherit, ObjectInherit"
    $Propagation = "None"
    $AccessControlType = "Allow"
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule
    ($Identity, $Permission, $Inheritance, $Propagation, $AccessControlType)
    $acl.AddAccessRule($rule)

    # Setting Modify for Authenticated Users
    $Identity = "Authenticated Users"
    $Permission = "Modify"
    $Inheritance = "ContainerInherit, ObjectInherit"
    $Propagation = "None"
    $AccessControlType = "Allow"
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule
	    ($Identity, $Permission, $Inheritance, $Propagation, $AccessControlType)
    $acl.AddAccessRule($rule)

    Set-Acl $UNCPath $acl
}
