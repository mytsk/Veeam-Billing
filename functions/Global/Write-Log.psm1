Function Write-Log {
    param(
        [Parameter(Mandatory = $true)][String]$msg
        , [Parameter(Mandatory = $false)][Switch]$NewTranscript
    )
    
    if (!(Test-Path -Path $Global:LogDir)) { 
        New-Item -Type Directory -Path $Global:LogDir | out-null
    }
    if (!(!$NewTranscript)) {
        [string]$date = ((get-date).ToString())
        Add-Content -Path "$Global:LogDir\log.txt" -value "=== [ $date - $msg] ===============================================" -Encoding string
    }
    
    Add-Content -Path "$Global:LogDir\log.txt" -value "$((get-date).ToString()): $msg" -Encoding string
    
}