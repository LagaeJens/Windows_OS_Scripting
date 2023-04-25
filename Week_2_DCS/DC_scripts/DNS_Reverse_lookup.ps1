#
# Create the Reverse Lookup Zone for 192.168.1.0
#

$ComputerName = $env:COMPUTERNAME
$zoneName = "1.168.192.in-addr.arpa"      
$ipSubnet = "192.168.1.0/24"  
if (get-dnsserverzone $zoneName -ErrorAction SilentlyContinue) 
{ Write-Output "Reverse lookup zone already exists!" } 
else {
    Write-Output "Creating the reverse lookup zone for subnet $ipsubnet ..."          
    Add-DnsServerPrimaryZone `
    -ComputerName $ComputerName `
    -NetworkID $ipSubnet `
    -ReplicationScope "Forest"      
    Register-DnsClient 
} 
