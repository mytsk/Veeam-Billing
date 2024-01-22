import-module ..\Veeam-Billing.psd1 -Force 
Set-VBParameters
Set-VBParameters -AuthType Automation
Write-log -NewTranscript "Starting Monthly Import"
# Set-GlobalImportID # Depricated, import-initilize handles this
Import-Initialize -Note Monthly

Write-host "Import-dbVBRLicenseUsage -All"
Import-dbVBRLicenseUsage -All -Verbose

Write-host "Import-dbVBRBackupSessionStatsPastMonth -all"
Import-dbVBRBackupSessionStatsPastMonth -all -Verbose

Import-Finish
Write-log "Finished Monthly Import"
exit