#
# dev remark 100% working
# Stores data returned from get-WRVBRBackups to database
#

function Import-Finish {
    
    
    
    [string]$importId = $Global:ImportId
    [datetime]$datetime = (get-date)

    #UPDATE [dbo].[tbl_imports] SET import_end = `'$datetime`' WHERE import_id = $importId" + [environment]::NewLine
    
    Write-Verbose "Building query" 
    $q += "UPDATE [dbo].[tbl_imports] SET import_end = `'$datetime`' WHERE import_id = `'$importId`' AND import_end IS NULL AND import_START IS NOT NULL" + [environment]::NewLine
            
    

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



 




  