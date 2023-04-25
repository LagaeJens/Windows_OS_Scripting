#
# Removing RADIUS clients
#
try {
    $File = ".\Radiusclients.csv"
    $RadiusClients = Import-Csv $File -Delimiter ";" -ErrorAction Stop
    Foreach ($RadiusClient in $RadiusClients) { 
        $IP = $RadiusClient.IP
        $Name = $RadiusClient.Name
        $Secret = $RadiusClient.Secret

        try {
            Remove-NpsRadiusClient -Name $Name
            Write-Host "Removing RADIUS Client $Name ..."
        }
        catch {
            Write-Host "RADIUS Client $Name already removed ..."
        }
    }
}
catch {
    Write-Host "Unable to open the file $File ... " -Foreground Red
}

