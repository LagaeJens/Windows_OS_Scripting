# Create a new forest
Install-ADDSForest `
    -DomainName "mct.be" `
    -DomainMode "Win2016" `
    -ForestMode "Win2016" `
    -InstallDNS `
    -CreateDnsDelegation:$false `
    -NoRebootOnCompletion:$false `
    -Force:$true

# Get the network interface
$nic = Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.InterfaceAlias -eq "Ethernet"}

# Configure DNS servers
if($nic){
    $dnsServers = Get-DnsClientServerAddress -InterfaceIndex $nic.ifIndex | Select-Object -ExpandProperty ServerAddresses
}
if($dnsServers){
    $preferredDNSServer = "192.168.0.10"
    $alternateDNSServer = "192.168.0.11"
    Set-DnsClientServerAddress -InterfaceIndex $nic.ifIndex -ServerAddresses ($preferredDNSServer, $alternateDNSServer)
}

# Create DNS zones
$subnet = "192.168.0.0/24"
$zoneName = "mct.be"
Add-DnsServerZone -NetworkId $subnet -Name $zoneName

# Create DNS resource records
$ptrRecord = "mctbe-dc01"
$dnsServer = "mct.be"
Add-DnsServerResourceRecordPtr -ZoneName $zoneName -Name $ptrRecord -PtrDomainName $dnsServer

# Create and configure the AD site
if(Get-Command Set-ADSite){
    $dcsiteName = "Default-First-Site-Name"
    Set-ADSite -Identity $dcsiteName -Name "Main Site"
    Set-ADSite -Identity $dcsiteName -Add @{"Subnets" = $subnet}
}
