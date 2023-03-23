New-ADOrganizationalUnit -Name "ABC" -Path "DC=contoso,DC=com"


# Run the following command to create the "Departments" child OU under the "ABC" parent OU:
New-ADOrganizationalUnit -Name "Departments" -Path "OU=ABC,DC=contoso,DC=com"

# Run the following command to create the "Sales" child OU under the "Departments" OU:
New-ADOrganizationalUnit -Name "Sales" -Path "OU=Departments,OU=ABC,DC=contoso,DC=com"
