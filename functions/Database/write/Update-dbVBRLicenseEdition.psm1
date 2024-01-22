#
# dev remark 100% working
# Stores data returned from get-WRVBRLicenseUsage to database
#

function Update-dbVBRLicenseEdition {
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
        
         
        
        $ServerLicenseEdition = get-WRVBRLicenseEdition -BackupServer $buS.'server_fqdn'
        
        $server_license_edition = $ServerLicenseEdition.'Edition'.Value
        $BackupServer_fqdn = $ServerLicenseEdition.'PSComputerName'

        Write-Verbose "Building query for $BackupServer_fqdn with $server_license_edition"
       
        $q = "update tbl_backupserver SET server_license_edition = `'$server_license_edition`' WHERE backupserver_id = $buSServerID" + [environment]::NewLine
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
           
            Update-dbVBRLicenseEdition -Single -BackupServer $vbr.'server_fqdn'

           
        }


        
    }
}





  