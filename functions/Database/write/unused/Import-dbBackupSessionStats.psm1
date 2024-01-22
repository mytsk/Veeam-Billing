#
# not used
# dev remark not working
# depends on get-WRVBRBackupSessionStats which isnt working
#
 
function Import-dbBackupSessionStats {
    Param(
        [parameter(ParameterSetName = 'All', Mandatory = $false)][switch] $All,
        [parameter(ParameterSetName = 'Single', Mandatory = $false)][switch] $Single,
        [parameter(ParameterSetName = 'Single', Mandatory = $true)] [string]$BackupServer
    )

    # check if there's a global import ID defined
    If (-not $global:ImportId) {
        Write-Verbose "Not GlobalImportID set, setting one..."
        $giid = Set-GlobalImportID
        Write-Verbose "GlobalImportID set to $giid"
    }

    $q = ""
    if ($Single) {

        $buS = get-dbVBRServers | where-object { $_.'server_fqdn' -eq $BackupServer }
        [int]$buSCustomerID = $buS.'customer_id'
        [int]$buSServerID = $buS.'backupserver_id'
        # get backups from Server
  
        
        $stats = get-WRVBRBackupSessionStats -BackupServer $buS.server_fqdn
        
        foreach ($stat in $stats) {
            [string]$Object = $stat.'Name'
            [string]$backupJob = $stat.'BackupJob'
            [float]$transferedGB = $stat.'TransferedGB'
            [int]$sessions = $stat.'Backup sessions'
            [int]$restorepoints = $stat.'RestorePoints (total)'
            Write-Verbose "Building query for $Object in job $backupJob" 
            $q += "INSERT INTO [dbo].[tbl_stats]([customer_id],[backupserver_id],[stats_obj_name],[stats_backup_job],[stats_transfered_gb],[stats_backup_sessions],[stats_restorepoints]) VALUES('$buSCustomerID','$buSServerID','$object','$backupJob','$transferedGB','$sessions','$restorepoints')" + [environment]::NewLine
        }
        
        try {
            write-verbose "Writing to database"
            invoke-sqlcmd -query $q -ServerInstance $global:dbServer -database $global:dbDatabase
            return $q;        
            
        }
        catch {
            Write-Verbose "Caught Error" 
            write-host "An Error occurered:"
            write-host $_
        }
        finally {
            write-verbose "Wrote to database successfully"
        }
        
    }

    <# ####### FOR ALL SERVERS ########>
    if ($All) {        
        $vbrServers = get-dbVBRServers
        foreach ($vbr in $vbrServers) {
            # Import-dbVBRBackups -Single -BackupServer $vbr.'server_fqdn'
        }
    }

   

}



  