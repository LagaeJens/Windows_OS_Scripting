#
# Enable print pooling and assigning printer ports
#
# Printer name that you want to create a pool for
$PrinterName = "HP Laserjet 4050"


# Printer IP addresses
$PrinterIPs = @(”172.23.80.3”, "172.23.82.3")
$PrinterPorts = @()

foreach ($PrinterIP in $PrinterIPs) {
    $PrinterPort = $PrinterIP + "_TCPPort"
    $PrinterPorts += $PrinterPort
    # Add a network printer port
    Add-PrinterPort -Name $PrinterPort -PrinterHostAddress $PrinterIP -ErrorAction SilentlyContinue -Verbose
}
# Replace value separator by a comma
$PrinterPorts = $PrinterPorts -join ','

#
# Creating printer pool, adding printer ports
#
write-host "Creating printer pool for '$PrinterName' ..."
rundll32 printui.dll, PrintUIEntry /Xs /n $PrinterName PortName $PrinterPorts

#
# Disable printer pool and assign first print port to the printer
#
#$PrinterName="HP Laserjet 4050"
#
#$PrinterIPs=@(”172.23.80.3”,"172.23.82.3")
#$PrinterPort=$PrinterIPs[0]+"_TCPPort"
#
#rundll32 printui.dll,PrintUIEntry /Xs /n $PrinterName PortName $PrinterPort
