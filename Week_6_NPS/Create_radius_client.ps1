#
# Creating RADIUS clients
#
try {
    $File = ".\Radiusclients.csv"
    $RadiusClients = Import-Csv $File -Delimiter ";" -ErrorAction Stop
    Foreach ($RadiusClient in $RadiusClients) { 
        $IP = $RadiusClient.IP
        $Name = $RadiusClient.Name
        $Secret = $RadiusClient.Secret

        try {
            New-NpsRadiusClient -Address $IP -Name $Name -SharedSecret $Secret | Out-Null
            Write-Host "Creating RADIUS Client $Name with IP address $IP and secret $Secret ..."
        }
        catch {
            Write-Host "RADIUS Client $Name with IP address $IP and secret $Secret already exists ..."
        }
    }
}
catch {
    Write-Host "Unable to open the file $File ... " -Foreground Red
}
