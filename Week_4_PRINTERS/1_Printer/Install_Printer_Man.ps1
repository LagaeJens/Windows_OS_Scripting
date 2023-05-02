#
# Install Printer Management
#

$ComputerName = $env:COMPUTERNAME

$WindowsFeature = "Print-Server"
if (Get-WindowsFeature $WindowsFeature -ComputerName $ComputerName | Where-Object { $_.installed -eq $false }) {
    Write-Output "Installing $WindowsFeature ..."
    Install-WindowsFeature $WindowsFeature -ComputerName $ComputerName -IncludeManagementTools
}
else {
    Write-Output "$WindowsFeature already installed ..."
}

