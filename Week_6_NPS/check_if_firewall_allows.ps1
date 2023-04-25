#
# Check if RADIUS traffic is allowed in the Windows Firewall
#

$Radius1812 = @(Get-NetFirewallPortFilter -PolicyStore ActiveStore -Protocol UDP | Where-Object { $_.LocalPort -eq 1812 })
$Radius1813 = @(Get-NetFirewallPortFilter -PolicyStore ActiveStore -Protocol UDP | Where-Object { $_.LocalPort -eq 1813 })

if ($Radius1812.Length -ge 1 -and $Radius1813.Length -ge 1) {
    Write-Host "The RADIUS Firewall rules are in place." -ForegroundColor Green
}
else {
    Write-Host "The RADIUS Firewall rules are missing!" -ForegroundColor Red
}
