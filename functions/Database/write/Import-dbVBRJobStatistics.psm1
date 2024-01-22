#
# dev remark: not started but get-wrvbrJobStatistics is complete.
#
#


          
            
function Import-dbVBRJobStatistics {
    Param(
        [parameter(ParameterSetName = 'All', Mandatory = $false)][switch] $All,
        [parameter(ParameterSetName = 'Single', Mandatory = $false)][switch] $Single,
        [parameter(ParameterSetName = 'Single', Mandatory = $true)] [string]$BackupServer
    )
    If (-not $global:ImportId) {
        Write-verbose "No GlobalImportID set, setting one..."
        set-GlobalImportID
        Write-verbose "GlobalImportID set"
    }    
    $q = ""
    if ($Single) {

        $buS = get-dbVBRServers | where-object { $_.'server_fqdn' -eq $BackupServer }
        [int]$buSCustomerID = $buS.'customer_id'
        [int]$buSServerID = $buS.'backupserver_id'
    
  
        Write-Verbose "Fetching stats for $BackupServer" 
        $stats = get-WRVBRJobStatistics -BackupServer $buS.server_fqdn
        

        foreach ($stat in $stats) {
            
            [string]$stat_statId = $stat.Id
            [string]$stat_jobJobId = $stat.JobId
            [string]$stat_jobName = $stat.JobName
            [string]$stat_jobJobType = $stat.JobType
            [string]$stat_jobSourceType = $stat.JobSourceType
            [string]$stat_jobIsScheduleEnabled = $stat.IsScheduleEnabled
            if ($stat.Description.Length -ge 256) {
                [string]$stat_jobDescription = ($stat.Description).Substring(0, 254)
            }
            else {
                [string]$stat_jobDescription = $stat.Description
            }

            [string]$stat_jobRunManually = $stat.RunManually
            [datetime]$stat_jobCreationTime = $stat.CreationTime
            [datetime]$stat_jobEndTime = $stat.EndTime
            [string]$stat_jobResult = $stat.Result
            [string]$stat_jobIsWorking = $stat.IsWorking
            [string]$stat_jobIsCompleted = $stat.IsCompleted
            [string]$stat_jobIsIsStarting = $stat.IsStarting
            [string]$stat_jobIsPostprocessing = $stat.IsPostprocessing
            [int]$stat_jobBaseProgress = $stat.BaseProgress
            [string]$stat_jobModifiedBy = $stat.ModifiedBy
            [Bool]$stat_jobIsEncryptionEnabled = $stat.IsEncryptionEnabled
            [string]$stat_jobEncryptionEnabled = $stat.EncryptionEnabled

            [int]$stat_jobTotalObjects = $stat.TotalObjects
            [int]$stat_jobProcessedObjects = $stat.ProcessedObjects

            [float]$stat_jobConfiguredSizeGB = $stat.ConfiguredSizeGB
            [float]$stat_jobProcessedUsedSizeGB = $stat.ProcessedUsedSizeGB
            [float]$stat_jobReadSizeGB = $stat.ReadSizeGB
            [float]$stat_jobTransferredSizeGB = $stat.TransferredSizeGB
            [string]$stat_jobBottleneck = $stat.Bottleneck.Value
            [int]$stat_jobBottleneckSourceWan = $stat.BottleneckSourceWan
            [int]$stat_jobBottleneckSourceProxy = $stat.BottleneckSourceProxy
            [int]$stat_jobBottleneckSourceNetwork = $stat.BottleneckSourceNetwork
            [int]$stat_jobBottleneckSourceStorage = $stat.BottleneckSourceStorage
            [int]$stat_jobBottleneckTargetWan = $stat.BottleneckTargetWan
            [int]$stat_jobBottleneckTargetProxy = $stat.BottleneckTargetProxy
            [int]$stat_jobBottleneckTargetNetwork = $stat.BottleneckTargetNetwork
            [int]$stat_jobBottleneckTargetStorage = $stat.BottleneckTargetStorage
            
            Write-Verbose "Building query for $stat_obj_name in job $stat_backup_job from $stat_startTime" 
            $q += "INSERT INTO [dbo].[tbl_jobStatistics]([customer_id]
            ,[backupserver_id]
            ,[stat_statId]
            ,[stat_jobName]
            ,[stat_job_type]
            ,[stat_jobSourceType]
            ,[stat_jobIsScheduleEnabled]
            ,[stat_jobDescription]
            ,[stat_jobRunManually]
            ,[stat_jobCreationTime]
            ,[stat_jobEndTime]
            ,[stat_jobIsWorking]
            ,[stat_jobIsCompleted]
            ,[stat_jobBaseProgress]
            ,[stat_jobModifiedBy]
            ,[stat_jobEncryptionEnabled]
            ,[stat_jobConfiguredSizeGB]
            ,[stat_jobProcessedUsedSizeGB]
            ,[stat_jobReadSizeGB]
            ,[stat_jobTransferredSizeGB]
            ,[stat_jobBottleneck]
            ,[stat_jobBottleneckSourceWan]
            ,[stat_jobBottleneckSourceProxy]
            ,[stat_jobBottleneckSourceNetwork]
            ,[stat_jobBottleneckSourceStorage]
            ,[stat_jobBottleneckTargetWan]
            ,[stat_jobBottleneckTargetProxy]
            ,[stat_jobBottleneckTargetNetwork]
            ,[stat_jobBottleneckTargetStorage]
            ,[Import_Id]
            ,[stat_jobResult]
            ,[stat_jobIsIsStarting]
            ,[stat_jobIsPostprocessing]
            ,[stat_jobIsEncryptionEnabled]
            ,[stat_jobTotalObjects]
            ,[stat_jobProcessedObjects]
            ,[stat_jobJobId]
            )
      
      VALUES('$buSCustomerID','$buSServerID','$stat_statId','$stat_jobName','$stat_jobJobType','$stat_jobSourceType','$stat_jobIsScheduleEnabled','$stat_jobDescription','$stat_jobRunManually','$stat_jobCreationTime','$stat_jobEndTime','$stat_jobIsWorking','$stat_jobIsCompleted','$stat_jobBaseProgress','$stat_jobModifiedBy','$stat_jobEncryptionEnabled','$stat_jobConfiguredSizeGB','$stat_jobProcessedUsedSizeGB','$stat_jobReadSizeGB','$stat_jobTransferredSizeGB','$stat_jobBottleneck','$stat_jobBottleneckSourceWan','$stat_jobBottleneckSourceProxy','$stat_jobBottleneckSourceNetwork','$stat_jobBottleneckSourceStorage','$stat_jobBottleneckTargetWan','$stat_jobBottleneckTargetProxy','$stat_jobBottleneckTargetNetwork','$stat_jobBottleneckTargetStorage','$importId','$stat_jobResult','$stat_jobIsIsStarting','$stat_jobIsPostprocessing','$stat_jobIsEncryptionEnabled','$stat_jobTotalObjects','$stat_jobProcessedObjects','$stat_jobJobId')" + [environment]::NewLine

        }
        
         
        try {
            Write-Verbose "Writing to database" 
            invoke-sqlcmd -query $q -ServerInstance $global:dbServer -database $global:dbDatabase
            
            
            write-verbose "Wrote to database successfully:"
            write-verbose "$q"
            Write-Log $q 
            return;
        }
        catch {
            Write-Verbose "Caught Error writing to database" 
            Write-Verbose $_
            write-host "An Error occurered writing to database"
            
        }
        finally {
            Write-Verbose "Done fetching stats for $BackupServer"  

        }
        
    }

    
    ####### FOR ALL SERVERS #######
    
    if ($All) {
        
        $vbrServers = get-dbVBRServers
        write-verbose "Processing All VBR servers"
        foreach ($vbr in $vbrServers) {

            
            Import-dbVBRJobStatistics -Single -BackupServer $vbr.'server_fqdn'
            

        }

        write-verbose "Done processing all VBR servers"
        
    }
   
    
    

}



  