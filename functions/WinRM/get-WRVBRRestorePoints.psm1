#
# Not implemented yet
# 
#

function get-WRVBRJobStatistics {
    Param(
        [parameter(position = 0, Mandatory = $false)]
        $BackupServer
    )
    if (!$BackupServer) {
        $BackupServer = $Global:BackupServer
        # if(!$Global:BackupServer){write-host "No BackupServer defined, set it by using -BackupServer or set $global:BackupServer'"}
    }
   
    if ((Get-VBParameters -AuthType) -eq 'ConfigFile' -or (Get-VBParameters -AuthType) -eq 'CurrentUser') {
        $creds = $global:vbrcreds
    }

    if ((Get-VBParameters -AuthType) -eq 'Automation') {
        $credsFromDb = get-dbVBRCredentials -backupserver $BackupServer
        $securePass = ConvertTo-SecureString -String $credsFromDb.SecureString
        $creds = New-Object System.Management.Automation.PsCredential($credsFromDb.Username, $securePass)
    }

    $result = invoke-command -Credential $creds -ComputerName $BackupServer -ScriptBlock {
        add-pssnapin VeeamPSSnapin 
        
        
        $rp = Get-VBRRestorePoint 
        $uniqueObjects = $rp | select -Unique -Property Name
       
       
        $rpList = $rp | select Name, Type, Algorithm, isFull, CreationTimeUtc, CompletionTimeUtc, IsConsistent, @{Name = "BackupName"; Expression = { ($_.GetBackup()).Name } }, @{Name = "BackupType"; Expression = { ($_.GetBackup()).JobType } } 
       
       
        $rr = @()
        foreach ($unique in $uniqueObjects) {
        
            $r = $rpList | ? { $_.Name -eq $unique.Name } 
            $rr += $r
            $r
        }
        
       
        
        $rp | Sort-Object -Property CreationTimeUtc, Name | select Name, Type, Algorithm, isFull, CreationTimeUtc, CompletionTimeUtc, IsConsistent, @{Name = "BackupName"; Expression = { ($_.GetBackup()).Name } }, @{Name = "BackupType"; Expression = { ($_.GetBackup()).JobType } }  | Out-GridView

    }
    return $result | Select-Object * -ExcludeProperty RunspaceId
    Remove-PSSession -Session $result
} #function get-WRVBRJobStatistics