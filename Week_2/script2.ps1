# Get the current DNS server settings
$currentDNSServers = Get-DnsClientServerAddress -AddressFamily IPv4 | Select-Object -ExpandProperty ServerAddresses

# Set the preferred and alternate DNS server addresses
$preferredDNSServer = "192.168.1.2"  # Replace with the IP address of your preferred DNS server
$alternateDNSServer = "182.168.1.3"  # Replace with the IP address of your alternate DNS server

# Check if the current DNS servers match the preferred and alternate DNS servers
if ($currentDNSServers -ne $preferredDNSServer -and $currentDNSServers -ne $alternateDNSServer) {
    # Set the preferred and alternate DNS servers
    Set-DnsClientServerAddress -ServerAddresses ($preferredDNSServer, $alternateDNSServer) -Confirm:$false
}
