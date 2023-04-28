# Create a new shared folder named "RoamingProfiles" at the path "C:\RoamingProfiles" and grant full access to everyone.
New-SmbShare -Name "RoamingProfiles" -Path "C:\RoamingProfiles" -FullAccess "Everyone"

# Retrieve the current access control list (ACL) for the shared folder.
$ACL = Get-Acl -Path "\\localhost\RoamingProfiles"

# Enable the access rule protection feature.
$ACL.SetAccessRuleProtection($true, $false)

# Create a new access rule that grants the "Domain Users" group read and execute permissions on the shared folder.
$Rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Domain Users", "ReadAndExecute", "Allow")
$ACL.SetAccessRule($Rule)

# Apply the modified ACL to the "RoamingProfiles" share.
Set-Acl -Path "\\localhost\RoamingProfiles" -AclObject $ACL
