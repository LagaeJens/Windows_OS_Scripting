#
# Testing Internet access on IP addres and FQDN
#
$Hosts = @(”8.8.8.8”, ”www.google.be”)

foreach ($h in $Hosts) {
    if (Test-NetConnection $h -InformationLevel Quiet) {
        Write-Host “Internet Access is OK! ($h)” -ForeGroundColor Green
    }
    else {
        Write-Host “Internet Access failed! ($h)” -ForeGroundColor Red
    }
}
