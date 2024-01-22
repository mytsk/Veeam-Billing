#
# dev remark 100% working
# Stores data returned from get-WRVBRBackups to database
#

function Import-Initialize {
    Param(
        [parameter(Mandatory = $false)][String] $Note
    )
    
    Set-GlobalImportID | out-null 
    [string]$importId = $Global:ImportId
    [datetime]$datetime = (get-date)

    
    
    Write-Verbose "Building query" 
    $q += "INSERT INTO [dbo].[tbl_imports] ([import_id] ,[import_start],[import_note]) VALUES ('$importId','$datetime','$Note')" + [environment]::NewLine
            
    

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



 




  