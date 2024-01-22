import-module ..\Veeam-Billing.psd1 -Force 
Set-VBParameters
Set-VBParameters -AuthType Automation
Write-log -NewTranscript "Starting Daily Import"
# Set-GlobalImportID # Depricated, import-initilize handles this
Import-Initialize -Note Daily

write-host "Update-dbVBRLicenseEdition -all" -verbose
Update-dbVBRLicenseEdition -all -verbose

write-host "Update-dbVBRServerVersion -all"
Update-dbVBRServerVersion -all -verbose

write-host "Import-dbVBRBackups -all"
Import-dbVBRBackups -all -verbose

#write-host "#Import-dbVBRSessionStatistics -all"
#Import-dbVBRSessionStatistics -all -verbose

write-host "Import-dbVBRBackupSessionStatistics -all"
Import-dbVBRBackupSessionStatistics -all -verbose


#write-host ""
#Import-dbVBRJobConfiguration -all -verbose

write-host "Import-dbVBRJobStatistics -all"
Import-dbVBRJobStatistics -all -verbose
Import-Finish
Write-log "Finished Daily Import"

exit