#
# dev remark 100% working
# Stores data returned from get-WRVBRBackups to database
#

function Import-dbVBRBackups {
    Param(
        [parameter(ParameterSetName = 'All', Mandatory = $false)][switch] $All,
        [parameter(ParameterSetName = 'Single', Mandatory = $false)][switch] $Single,
        [parameter(ParameterSetName = 'Single', Mandatory = $true)] [string]$BackupServer
    )
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
  
        
        $VBRBackups = get-WRVBRBackups -BackupServer $buS.server_fqdn
        
        foreach ($backup in $VBRBackups) {
            
            [string]$backupName = $backup.'Job Name'
            [string]$backupId = $backup.Id
            [string]$jobID = $backup.JobId
            [float]$backupOrgSize = $backup.'Original Size (GB)'
            [float]$backupSize = $backup.'Size (GB)'
            [long]$backup_size_bytes_org = $backup.backup_size_bytes_org
            [long]$backup_size_bytes_stored = $backup.backup_size_bytes_stored
            [string]$backupType = $backup.'JobType'
            [int]$vc_Id = $backup.vc_Id
            Write-Verbose "Building query for backup job $backupName" 
            $q += "INSERT INTO [dbo].[tbl_backups]([customer_id],[backupserver_id],[backup_name],[backup_size_org],[backup_size_stored],[backup_size_bytes_org],[backup_size_bytes_stored],[Backup_type],[Import_Id],[vc_Id],[backup_backupID],[backup_jobID]) VALUES('$buSCustomerID','$buSServerID','$backupName','$backupOrgSize','$backupSize','$backup_size_bytes_org','$backup_size_bytes_stored','$backupType','$importId','$vc_Id', '$backupId', '$jobID')" + [environment]::NewLine
            
            
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
            write-host "An Error occurered:"
            write-host $_
        }
        finally {
           
            write-verbose "Wrote to database successfully:"
            Write-Verbose "$q"
        }
        
    }

    <# ####### FOR ALL SERVERS ########>
    if ($All) {
        
        $vbrServers = get-dbVBRServers

        foreach ($vbr in $vbrServers) {
           
            $VBRBackups = Import-dbVBRBackups -Single -BackupServer $vbr.'server_fqdn'

           
        }


        
    }

 

}



  