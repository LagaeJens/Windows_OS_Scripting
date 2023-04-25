#
# Exporting the NPS Configuration
#
$File = "NPSConfiguration.xml"

Write-Host "Exporting the NPS Configuration to the XML-file $File ... " -Foreground Cyan
Export-NpsConfiguration $File

#
# Importing the NPS Configuration
#
try {
    $File = "NPSConfiguration.xml"
    Import-NpsConfiguration $File
    Write-Host "Importing the NPS Configuration from the XML-file $File ... " -Foreground Cyan
}
catch {
    Write-Host "Unable to open the file $File ... " -Foreground Red
}
