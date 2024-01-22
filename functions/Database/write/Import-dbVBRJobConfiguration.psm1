# 
# dev remark:
# not complete
# Stores data returned from get-WRVBRJobsConfiguration to database
#
# This is actuallt object stats, should be renamed
# 


function Import-dbVBRJobConfiguration {
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
        # get backups from Server
  
        Write-Verbose "Fetching stats for $BackupServer" 
        $stats = get-WRVBRJobConfiguration -BackupServer $buS.server_fqdn
        

        foreach ($stat in $stats) {
            <# [string]$stat_obj_name = $stat.Name 
            [string]$stat_backup_job = $stat.JobName 
            [string]$stat_job_type = $stat.JobType 
            [string]$stat_status = $stat.Status 
            [int]$stat_bottleneck = $stat.Bottleneck 
            [int]$stat_bottleneckSourceWan = $stat.BottleneckSourceWan 
            [int]$stat_bottleneckSourceProxy = $stat.BottleneckSourceProxy   
            [int]$stat_bottleneckSourceNetwork = $stat.BottleneckSourceNetwork 
            [int]$stat_bottleneckSourceStorage = $stat.BottleneckSourceStorage 
            [int]$stat_bottleneckTargetWan = $stat.BottleneckTargetWan 
            [int]$stat_bottleneckTargetProxy = $stat.BottleneckTargetProxy 
            [int]$stat_bottleneckTargetNetwork = $stat.BottleneckTargetNetwork 
            [int]$stat_bottleneckTargetStorage = $stat.BottleneckTargetStorage 
            [datetime]$stat_startTime = $stat.StartTime
            [datetime]$stat_stopTime = $stat.StopTime 
            [string]$stat_duration = $stat.Duration   
            [float]$stat_processedSizeGB = $stat.ProcessedSizeGB
            [float]$stat_usedGB = $stat.UsedGB 
            [float]$stat_processedUsedSizeGB = $stat.ProcessedUsedSizeGB  
            [float]$stat_readSizeGB = $stat.ReadSizeGB
            [string]$stat_jobSessId = $stat.JobSessId
            [string]$stat_job_id = $stat.Id 
            [string]$stat_backupserver = $stat.PSComputerName #>
            Write-Verbose "Building query for $stat_obj_name in job $stat_backup_job from $stat_startTime" 
            $q += "INSERT INTO [dbo].[tbl_configuration]() VALUES()" + [environment]::NewLine
            
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

            
            Import-dbVBRJobConfiguration -Single -BackupServer $vbr.'server_fqdn'
            

        }

        write-verbose "Done processing all VBR servers"
        
    }
   
    
    

}



  