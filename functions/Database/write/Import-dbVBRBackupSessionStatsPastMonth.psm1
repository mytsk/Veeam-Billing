# 
# dev remark:
# 100% working but using deprecated cmdlet: should be updated to Get-VBRComputerBackupJob
#  Stores data returned from  get-WRVBRBackupSessionStatsPastMonth to database
# 

function Import-dbVBRBackupSessionStatsPastMonth {
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
        $stats = get-WRVBRBackupSessionStatsPastMonth -BackupServer $buS.server_fqdn
        
        foreach ($stat in $stats) {
            [string]$Object = $stat.'Name'
            [string]$backupJob = $stat.'BackupJob'
            [float]$transferedGB = $stat.'TransferedGB'
            [int]$sessions = $stat.'Backup sessions'
            [string]$period = $stat.'Period'
            [int]$restorepoints = $stat.'RestorePoints (total)'
            [int]$vc_Id = $stat.'vc_Id'
            Write-Verbose "Building query for $Object in job $backupJob" 
            $q += "INSERT INTO [dbo].[tbl_stats]([customer_id],[backupserver_id],[stats_obj_name],[stats_backup_job],[stats_transfered_gb],[stats_backup_sessions],[stats_period],[Import_Id],[stats_restorepoints],[vc_Id]) VALUES('$buSCustomerID','$buSServerID','$object','$backupJob','$transferedGB','$sessions','$period','$importId','$restorepoints','$vc_Id')" + [environment]::NewLine
        }
        
         
        try {
            Write-Verbose "Writing to database" 
            invoke-sqlcmd -query $q -ServerInstance $global:dbServer -database $global:dbDatabase
            write-verbose "Wrote to database successfully:"
            Write-Verbose "$q"
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

            #Import-dbVBRBackups -Single -BackupServer $vbr.'server_fqdn'
            
            Import-dbVBRBackupSessionStatsPastMonth  -Single -BackupServer $vbr.'server_fqdn'
            

        }

        write-verbose "Done processing all VBR servers"
        
    }
   
    
    

}



  