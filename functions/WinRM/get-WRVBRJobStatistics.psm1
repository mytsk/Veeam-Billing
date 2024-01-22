#
# Fetches Information about all Backups
# JobName, JobType, EncryptionState, OriginalSize (GB), Size (GB), Repository Server
#

function get-WRVBRJobStatistics {
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
        $jobs = ((get-vbrjob))
        $backupSessions = (Get-VBRBackupSession | Where-Object { ($_.CreationTime -ge ([DateTime]::Today.AddDays(-1) ) -and $_.EndTime -lt ([DateTime]::Today) ) -or (!!($_.isWorking)) })
        $r = @()
        $rr = @()
        foreach ($job in $jobs) {
            #$r = @()

            $jobBackupSessions = (($backupSessions | Where-Object { ($_.jobId -eq $job.id.guid) }) ) # | Sort-Object CreationTimeUTC | select-object -last 2)

            foreach ($Session in $jobBackupSessions) {
                #$Session = $Job.FindLastSession()
                #$TaskSession = $Session | Get-VBRTaskSession
                $r = $session | Select-Object -Property Id,
                JobName,
                JobType,
                JobSourceType,
                @{Name = "IsScheduleEnabled"; Expression = { $job.IsScheduleEnabled } },
                @{Name = "Description"; Expression = { $job.info.Description.toString() } },
                @{Name = "RunManually"; Expression = { $Session.info.RunManually } },
                @{Name = "CreationTime"; Expression = { $Session.CreationTime } },
                @{Name = "EndTime"; Expression = { $Session.info.EndTime } },
                @{Name = "Result"; Expression = { $Session.info.Result } },
                @{Name = "IsWorking"; Expression = { $Session.IsWorking } },
                @{Name = "IsCompleted"; Expression = { $Session.IsCompleted } },
                @{Name = "IsStarting"; Expression = { $Session.IsStarting } },
                @{Name = "IsPostprocessing"; Expression = { $Session.IsPostprocessing } },
                @{Name = "BaseProgress"; Expression = { $Session.BaseProgress } },
                @{Name = "ModifiedBy"; Expression = { $job.info.ModifiedBy.FullName } } ,
                @{Name = "IsEncryptionEnabled"; Expression = { $Session.IsEncryptionEnabled } },
                @{Name = "EncryptionEnabled"; Expression = { if (!$job.UserCryptoKey) { "False" }else { "True" } } },
                @{Name = "TotalObjects"; Expression = { $Session.progress.TotalObjects } },
                @{Name = "ProcessedObjects"; Expression = { $Session.Progress.ProcessedObjects } },
                @{Name = "ConfiguredSizeGB"; Expression = { [math]::Round(($Session.Progress.ProcessedSize / 1GB), 1) } },
                @{Name = "ProcessedUsedSizeGB"; Expression = { [math]::Round(($Session.Progress.ProcessedUsedSize / 1GB), 1) } },
                @{Name = "ReadSizeGB"; Expression = { [math]::Round(($Session.Progress.ReadSize / 1GB), 1) } },
                @{Name = "TransferredSizeGB"; Expression = { [math]::Round(($Session.Progress.TransferedSize / 1GB), 1) } },
                @{Name = "Bottleneck"; Expression = { $Session.Progress.BottleneckInfo.Bottleneck } },
                @{Name = "BottleneckSourceWan"; Expression = { $Session.Progress.BottleneckInfo.SourceWan } },
                @{Name = "BottleneckSourceProxy"; Expression = { $Session.Progress.BottleneckInfo.SourceProxy } },
                @{Name = "BottleneckSourceNetwork"; Expression = { $Session.Progress.BottleneckInfo.SourceNetwork } },
                @{Name = "BottleneckSourceStorage"; Expression = { $Session.Progress.BottleneckInfo.SourceStorage } },
                @{Name = "BottleneckTargetWan"; Expression = { $Session.Progress.BottleneckInfo.TargetWan } },
                @{Name = "BottleneckTargetProxy"; Expression = { $Session.Progress.BottleneckInfo.TargetProxy } },
                @{Name = "BottleneckTargetNetwork"; Expression = { $Session.Progress.BottleneckInfo.TargetNetwork } },
                @{Name = "BottleneckTargetStorage"; Expression = { $Session.Progress.BottleneckInfo.TargetStorage } },
                JobId
                #@{Name = "SessionType"; Expression = { "LastSession" } }
                #$r 
                $rr += $r
            }
            

        }
        #$Global:rrr = $rr
        $result = ($rr | Sort-Object JobName, CreationTime)
        return $result
    }
    return $result | Select-Object * -ExcludeProperty RunspaceId
    Remove-PSSession -Session $result
} #function get-WRVBRJobStatistics