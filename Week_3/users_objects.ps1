# Prompt for user details
$Name = Read-Host "Enter the full name of the user"
$Department = Read-Host "Enter the name of the department"

# Construct user details
$GivenName = $Name.Split(' ')[0]
$Surname = $Name.Split(' ')[1]
$SamAccountName = $GivenName.ToLower() + $Surname.ToLower().Substring(0, 1)

# Construct OU path
$OUPath = "OU=$Department,OU=Departments,OU=ABC,DC=contoso,DC=com"

# Create user object
New-ADUser -Name $Name -GivenName $GivenName -Surname $Surname -SamAccountName $SamAccountName -Path $OUPath -AccountPassword (ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force) -Enabled $true

# Create home folder
$HomeFolderPath = "\\fileserver\Users\$SamAccountName"
New-Item -ItemType Directory -Path $HomeFolderPath

# Set permissions on home folder
$Acl = Get-Acl $HomeFolderPath
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("contoso\$SamAccountName", "FullControl", "Allow")
$Acl.SetAccessRule($Ar)
Set-Acl $HomeFolderPath $Acl
