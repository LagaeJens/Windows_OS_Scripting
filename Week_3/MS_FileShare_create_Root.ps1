#
# Making the root share that will contain the user home folders
#

$fileServer = "win15-ms"

$systemShare = "C$"
$driveLetter = $systemShare.replace("$", ":")
$rootShare = "Homedirs"
$localPath = $driveLetter + "\" + $rootShare
$UNCPath = "\\" + $fileServer + "\" + $systemShare + "\" + $rootShare

if (Get-Item -Path $UNCPath -ErrorAction SilentlyContinue) {
    Write-Output “$UNCPath already exists ..."   
}
else {
    Write-Output "Creating $UNCPath ..." 
    New-Item -Path $UNCPath -type directory -Force | Out-Null
}

if (Get-SmbShare -CimSession $fileServer -Name $rootShare -ErrorAction SilentlyContinue) {
    Write-Output “$localPath already shared ..."
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

    # Setting Read & Execute for Authenticated Users on This Folder only
    $Identity = "Authenticated Users"
    $Permission = "ReadAndExecute"
    $Inheritance = "None"
    $Propagation = "NoPropagateInherit"
    $AccessControlType = "Allow"
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule
		($Identity, $Permission, $Inheritance, $Propagation, $AccessControlType)
    $acl.AddAccessRule($rule)

    Set-Acl $UNCPath $acl
}
