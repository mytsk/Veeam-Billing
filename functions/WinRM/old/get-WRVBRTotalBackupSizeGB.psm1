#
# dev remark, not used
#

function get-WRVBRTotalBackupSizeGB {
    Param(
        [parameter(position = 0, Mandatory = $false)]
        $buServer
    )
    $result = invoke-command -ComputerName $buServer -ScriptBlock {
        add-pssnapin VeeamPSSnapin 
        (Get-VBRBackup | Select-object @{N="Job Name";E={$_.Name}}, @{N="Size (GB)";E={[math]::Round(($_.GetAllStorages().Stats.BackupSize | Measure-Object -Sum).Sum/1GB,1)}} | Measure-Object 'Size (GB)' -sum).Sum
    }
    return $result
    Remove-PSSession -Session $result
} #function get-WRVBRTotalBackupSizeGB