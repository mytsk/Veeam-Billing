#
# Fetches summaized backup statistics for each object in each  session for past month.
#


function get-WRVBRBackupSessionStatsPastMonth {
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
       
        #region function get-qjobdata
        function get-qjobdata() {
            Param(
                [parameter(position = 0, Mandatory = $false)]
                $job,
                [parameter(position = 1, Mandatory = $false)]
                $date    
            )
            # Definierar Kundens jobb
            $customerJob = $job
            
            # Definierar månaden som avser rapporten
            $month = "$date*"
            
            # Tar fram backup sessioner får kunden $customerJob i får månad $month
            $busess = Get-VBRBackupSession | Where-Object { $_.JobName -eq $customerJob -and $_.EndTime.toString() -like $month } | Sort-Object EndTime
            $jobs = Get-VBRJob
            $regexCustID = '(?#\vc_ID\:).*?(?=#)'
            $vmreport = @()
            foreach ($session in $busess) { 
        
                $vmreport += Get-VBRTaskSession $session.SessionInfo.Id | Select-Object Name ,
                JobName,
                @{Name = "JobType"; Expression = { $_.JobSess.JobType } },
                Status,
                @{Name = "StartTime"; Expression = { $_.Progress.StartTimeLocal } },
                @{Name = "StopTime"; Expression = { $_.Progress.StopTimeLocal } },
                @{Name = "Duration"; Expression = { '{0:00}:{1:00}:{2:00}' -f $_.Progress.Duration.Hours, $_.Progress.Duration.Minutes, $_.Progress.Duration.Seconds } },
                @{Name = "SizeGB"; Expression = { [math]::Round(($_.Progress.ProcessedSize / 1GB), 3) } },
                @{Name = "UsedGB"; Expression = { [math]::Round(($_.Progress.ProcessedUsedSize / 1GB), 3) } },
                @{Name = "ReadGB"; Expression = { [math]::Round(($_.Progress.ReadSize / 1GB), 3) } },
                @{Name = "TransferedGB"; Expression = { [math]::Round(($_.Progress.TransferedSize / 1GB), 3) } }
                
            }
         
            $vrItem = @()

            foreach ($vrItem in $vmreport) {
                $vc_id = ""
                $buName = $vrItem.JobName
                
                if ($vrItem.JobType -eq 'Backup' -or $vrItem.JobType -eq 'BackupSync') {
                    $n = $buName
                    $job = ($jobs | Where-Object { $_.Name -eq $n })
                }
                if ($vrItem.JobType -eq 'EpAgentManagement') {
                    $n = $buName.Substring(0, (($buName.IndexOf(' -'))))
                    $job = ($jobs | Where-Object { $_.Name -like $n })
                }


                $match = $job.info.Description  | Select-String -Pattern $regexCustID -AllMatches | ForEach-Object { $_.Matches } | Where-Object { $_.value -gt '0' }  | ForEach-Object { $_.Value } -ErrorAction SilentlyContinue
                
                
                if (!!($match)) {
                    $vc_id = $match.Substring(7, 4)
                } 
                if (!($match)) {
                    $vc_id = "Missing in Job Desc"
                }

                

                $vrItem | Add-Member -NotePropertyName vc_ID -NotePropertyValue $vc_id
                
            }
            
           
            return $vmreport
        }
        #endRegion function get-qjobdata
        
        #region function get-qBackupStats
        function get-qBackupStats() {
            Param(
                [parameter(position = 1, Mandatory = $true)]
                $Month    
            )
            $result = @()
            $jobs = Get-VBRJob | where-object { $_.jobtype -eq 'backup' }
            foreach ($job in $jobs) {
                $result += get-qjobdata -job $job.Name -date $Month | where-object { $_.Status -eq 'success' } |  sort-object StartTime, Name
                
            }


            $vms = $result | Select-Object Name -Unique
            $restorePo = Get-VBRRestorePoint
            
            $backupitemdetails = @()
            foreach ($vm in $vms) {
                
                $totalTransfered = $result | where-object { $_.Name -eq $vm.Name } | sort-object StartTime | Measure-Object -Sum -Property 'TransferedGB'
                $restorePoints = $result | where-object { $_.Name -eq $vm.Name } | sort-object StartTime | measure-object -Sum -Property 'TransferedGB'
                $jobName = $result | where-object { $_.Name -eq $vm.Name }  | select-object -Unique JobName
                $restorePoint = $restorePo | Where-Object { $_.Name -eq $vm.Name } | measure-object 
                [int]$vc_Id = ($result | Where-Object { $_.Name -eq $vm.Name }).vc_Id | Select-Object -Unique
                

                $obj = New-Object PSObject |
                Add-Member -type NoteProperty -Name 'Name' -Value $vm.Name -PassThru |
                Add-Member -type NoteProperty -Name 'BackupJob' -Value $jobName.JobName -PassThru |
                #Add-Member -type NoteProperty -Name 'BackupJobType' -Value $jobName.Type -PassThru |
                Add-Member -type NoteProperty -Name 'TransferedGB' -Value $totalTransfered.Sum -PassThru |
                Add-Member -type NoteProperty -Name 'Backup sessions' -Value $restorePoints.Count -PassThru |
                Add-Member -type NoteProperty -Name 'RestorePoints (total)' -Value $restorePoint.Count -PassThru |
                Add-Member -type NoteProperty -Name 'Period' -Value $Month -PassThru |
                Add-Member -type NoteProperty -Name 'vc_ID' -Value $vc_ID -PassThru 

                $backupitemdetails += $obj
            }

            #$resBackupdetails = $backupitemdetails | sort-object BackupJob, Name
            #$resTotalDataSent = $backupitemdetails | sort-object BackupJob, Name | Measure-Object TransferedGB  -Sum
            return $backupitemdetails
        }#function get-qBackupStats

        #endRegion function get-qBackupStats

        get-qBackupStats -month ((get-date).AddMonths(-1).ToString("yyyy-MM"))
        

    }
    return $result | Select-Object -Property * -ExcludeProperty RunspaceId
    Remove-PSSession -Session $result
} #function get-WRVBRBackupSessionStatsPastMonth