#
# dev remark, not used
#

function get-WRVBRBackupSizeGB {
    Param(
        [parameter(position = 0, Mandatory = $false)]
        $buServer
    )
    $result = invoke-command -ComputerName $buServer -ScriptBlock {
        add-pssnapin VeeamPSSnapin 
        (Get-VBRBackup | Select-object @{N="Job Name";E={$_.Name}}, @{N="Size (GB)";E={[math]::Round(($_.GetAllStorages().Stats.BackupSize | Measure-Object -Sum).Sum/1GB,1)}})
    }
    return $result | Select-Object -Property * -ExcludeProperty RunspaceId
    Remove-PSSession -Session $result
    
} #function get-WRVBRBackupSizeGB