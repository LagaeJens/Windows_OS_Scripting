# Create a shared folder named "UsersHome" at the path "C:\UsersHome" and grant full access to everyone.
New-SmbShare -Name "UsersHome" -Path "C:\UsersHome" -FullAccess "Everyone"

# Retrieve the current access control list (ACL) for the shared folder.
$ACL = Get-Acl -Path "\\localhost\UsersHome"

# Enable the access rule protection feature.
$ACL.SetAccessRuleProtection($true, $false)

# Create a new access rule that grants the "Domain Users" group read and execute permissions on the shared folder.
$Rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Domain Users", "ReadAndExecute", "Allow")
$ACL.SetAccessRule($Rule)

# Apply the modified ACL to the "UsersHome" share.
Set-Acl -Path "\\localhost\UsersHome" -AclObject $ACL
