#
# Fetches Information about all Backups
# JobName, JobType, EncryptionState, OriginalSize (GB), Size (GB), Repository Server
#

function get-WRVBRBackups {
    Param(
        [parameter(position = 0, Mandatory = $false)]
        $BackupServer
    )
    if (!$BackupServer) {
        $BackupServer = $Global:BackupServer
        # if(!$Global:BackupServer){write-host "No BackupServer defined, set it by using -BackupServer or set $global:BackupServer'"}
    }
    if ((Get-VBParameters -AuthType) -eq 'ConfigFile' -or (Get-VBParameters -AuthType) -eq 'CurrentUser') {
        $creds = $global:vbrcreds
    }

    if ((Get-VBParameters -AuthType) -eq 'Automation') {

        $credsFromDb = get-dbVBRCredentials -backupserver $BackupServer
        $securePass = ConvertTo-SecureString -String $credsFromDb.SecureString
        $creds = New-Object System.Management.Automation.PsCredential($credsFromDb.Username, $securePass)
    }



    

    $result = invoke-command -Credential $creds -ComputerName $BackupServer -ScriptBlock {
        add-pssnapin VeeamPSSnapin 
        $backups = (Get-VBRBackup | 
            Select-object  @{N = "Job Name"; E = { $_.Name } },
            JobType,
            Id,
            BackupPolicyTag,
            JobId,
            EncryptionState,
            @{N = "Original Size (GB)"    ; E = { [math]::Round(($_.GetAllStorages().Stats.DataSize | Measure-Object -Sum).Sum / 1GB, 1) } },
            @{N = "Size (GB)"; E = { [math]::Round(($_.GetAllStorages().Stats.BackupSize | Measure-Object -Sum).Sum / 1GB, 1) } },
            @{N = "backup_size_bytes_org"; E = { (($_.GetAllStorages().Stats.DataSize) | Measure-Object -sum).sum } },
            @{N = "backup_size_bytes_stored"; E = { (($_.GetAllStorages().Stats.BackupSize) | Measure-Object -sum).sum } },
            @{N = "Repo Server"; E = { $_.GetTargetHost().Name } } |
            Sort-object JobType, 'Job Name')

            

            
        # find customer Id and apply to Backups
        $regexCustID = '(?#\vc_ID\:).*?(?=#)'
        $jobs = Get-VBRJob



        foreach ($backup in $backups) {
            $vc_id = ""
            
            
            if ($backup.JobType -eq 'Backup' -or $backup.JobType -eq 'BackupSync') {
                $backupJobID = $backup.JobId                
                $job = ($jobs | Where-Object { $_.Id -eq $backupJobID })
            }
            if ($backup.JobType -eq 'EpAgentManagement' -or $backup.JobType -eq 'SimpleBackupCopyWorker') {
                $buPolicyTag = $backup.BackupPolicyTag
                $job = ($jobs | Where-Object { $_.id -eq $buPolicyTag })
 
            }


            $match = $job.info.Description  | Select-String -Pattern $regexCustID -AllMatches | ForEach-Object { $_.Matches } | Where-Object { $_.value -gt '0' }  | ForEach-Object { $_.Value } -ErrorAction SilentlyContinue
            if (!!($match)) {
                [int]$vc_id = $match.Substring(7, 4)
            } 
            if (!($match)) {
                [int]$vc_id = 0
            }


            $backup | Add-Member -NotePropertyName vc_ID -NotePropertyValue $vc_id
        }


        return $backups
    }

    
    return $result | Select-Object * -ExcludeProperty RunspaceId
    Remove-PSSession -Session $result
} #function get-WRVBRBackups