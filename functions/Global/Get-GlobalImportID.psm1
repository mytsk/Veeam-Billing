

function Get-GlobalImportID {

        
    if (!$Global:ImportId) {
        Write-Warning "Global:ImportId is not defined, use Set-GlobalImportID to generate one"
    }
    else {
        write-host $Global:ImportId
    }
}
