
function Get-VBParameters {
    Param(
        [parameter(Mandatory = $false)][switch] $AuthType
    )
    
    if (!!($AuthType)) {
        return $global:AuthType

    }
    else {
        Write-Host "Base Dir: $Global:BaseDir"
        Write-Host "Log Dir: $Global:LogDir"
        Write-Host "Settings file: $Global:BaseDir\db.settings.ps1"
        Write-Host "AuthType: $global:AuthType"
        Write-Host "Global Import ID: $global:ImportId"
    }
}