
#
# Gets detailed per object statistics 
#


function get-WRVBRBackupSessionStatistics {
    Param(
        [parameter(position = 0, Mandatory = $false)]$BackupServer,
        [parameter(position = 0, Mandatory = $false)]$Days
    )
    if (!$BackupServer) {
        $BackupServer = $Global:BackupServer
        # if(!$Global:BackupServer){write-host "No BackupServer defined, set it by using -BackupServer or set $global:BackupServer'"}
    }
    Write-Verbose "Backup Server: $BackupServer"
    if (!$Days) {
        #Default fetch 2 days history
        
        $Days = (get-date).AddDays(-2).ToString("yyyy-MM-dd")
    }
    else {
        # Days based on Param
        $Days = (get-date).AddDays(-$Days).ToString("yyyy-MM-dd")

    }
    Write-Verbose "Days: $days"
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
        function get-jobdata {
            $busess = Get-VBRBackupSession | Where-Object { $_.EndTime.toString("yyyy-MM-dd") -gt $Using:Days }  
            $vmreport = @()
            foreach ($session in $busess) { 
                
                $vmreport += Get-VBRTaskSession $session.SessionInfo.Id | Select-Object Name,
                JobName,
                @{Name = "JobType"; Expression = { $session.SessionInfo.JobType } },
                Status,
                @{Name = "TaskAlgorithm"; Expression = { $_.WorkDetails.TaskAlgorithm } },
                @{Name = "Bottleneck"; Expression = { $session.Progress.BottleneckInfo.Bottleneck } },
                @{Name = "BottleneckSourceWan"; Expression = { $session.Progress.BottleneckInfo.SourceWan } } ,
                @{Name = "BottleneckSourceProxy"; Expression = { $session.Progress.BottleneckInfo.SourceProxy } } ,
                @{Name = "BottleneckSourceNetwork"; Expression = { $session.Progress.BottleneckInfo.SourceNetwork } } ,
                @{Name = "BottleneckSourceStorage"; Expression = { $session.Progress.BottleneckInfo.SourceStorage } } ,
                @{Name = "BottleneckTargetWan"; Expression = { $session.Progress.BottleneckInfo.TargetWan } } ,
                @{Name = "BottleneckTargetProxy"; Expression = { $session.Progress.BottleneckInfo.TargetProxy } } ,
                @{Name = "BottleneckTargetNetwork"; Expression = { $session.Progress.BottleneckInfo.TargetNetwork } } ,
                @{Name = "BottleneckTargetStorage"; Expression = { $session.Progress.BottleneckInfo.TargetStorage } },
                @{Name = "StartTime"; Expression = { $_.Progress.StartTimeLocal } },
                @{Name = "StopTime"; Expression = { $_.Progress.StopTimeLocal } },
                @{Name = "Duration"; Expression = { '{0:00}:{1:00}:{2:00}' -f $_.Progress.Duration.Hours, $_.Progress.Duration.Minutes, $_.Progress.Duration.Seconds } },
                @{Name = "ProcessedSizeGB"; Expression = { [math]::Round(($_.Progress.ProcessedSize / 1GB), 3) } },
                @{Name = "UsedGB"; Expression = { [math]::Round(($_.Progress.ProcessedUsedSize / 1GB), 0) } },
                @{Name = "ProcessedUsedSizeGB"; Expression = { [math]::Round(($_.Progress.ReadSize / 1GB), 0) } },
                @{Name = "ReadSizeGB"; Expression = { [math]::Round(($_.Progress.TransferedSize / 1GB), 0) } },
                Id, # taskId
                @{Name = "JobId"; Expression = { $_.JobSess.JobId } }, # JobId
                JobSessId # SessionId

            }
            return $vmreport 
        }
        return get-jobdata
    }
    
    return $result | Select-Object -Property * -ExcludeProperty RunspaceId
    Remove-PSSession -Session $result
} #function get-WRVBRBackupSessions
