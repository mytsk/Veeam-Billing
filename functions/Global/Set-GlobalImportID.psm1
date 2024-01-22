

function Set-GlobalImportID {
    [string]$Global:ImportId = (New-Guid).ToString()
    Write-Verbose $Global:ImportId
}
