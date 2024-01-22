#
# dev remark 100% working
# Stores data returned from get-WRVBRLicenseUsage to database
#

function Import-dbVBRLicenseUsage {
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
  
        
        $Licenses = get-WRVBRLicenseUsage -BackupServer $buS.server_fqdn
        
        foreach ($license in $Licenses) {
            #$Licenses
            [string]$licenseUsage_Type = $license.Type
            [int]$licenseUsage_Count = $license.Count
            [float]$licenseUsage_Multiplier = $license.Multiplier
            [float]$licenseUsage_Instances = $license.UsedInstancesNumber
            [string]$licenseUsage_fqdn = $license.'PSComputerName'
    
            Write-Verbose "Building query for type $licenseUsage_Type  on backupserver $licenseUsage_fqdn" 
       
            $q += "INSERT INTO tbl_licenseUsage([customer_id], [backupserver_id],[licenseUsage_fqdn],[licenseUsage_Type],[licenseUsage_Count],[licenseUsage_Multiplier], [licenseUsage_UsedInstancesNumber],[Import_Id]) VALUES ('$buSCustomerID','$buSServerID','$licenseUsage_fqdn','$licenseUsage_Type','$licenseUsage_Count','$licenseUsage_Multiplier','$licenseUsage_Instances','$importId')" + [environment]::NewLine
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
           
            $Licenses = Import-dbVBRLicenseUsage -Single -BackupServer $vbr.'server_fqdn'

           
        }


        
    }

 

}



  