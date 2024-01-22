#
# dev remark 100% working
# Stores data returned from get-WRVBRLicenseUsage to database
#

function Update-dbVBRServerVersion {
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
        #[int]$buSCustomerID = $buS.'customer_id'
        [int]$buSServerID = $buS.'backupserver_id'
        
         
        
        $ServerVersion = get-WRVBRServerVersion -BackupServer $buS.'server_fqdn'
        
        $server_major_version = $ServerVersion.'Version' 
        $BackupServer_fqdn = $ServerVersion.'PSComputerName'

        Write-Verbose "Building query for $BackupServer_fqdn"
       
        $q = "update tbl_backupserver SET server_major_version = `'$server_major_version`' WHERE backupserver_id = $buSServerID" + [environment]::NewLine
        write-verbose $q
    
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
           
            Update-dbVBRServerVersion -Single -BackupServer $vbr.'server_fqdn'

           
        }


        
    }
}





  