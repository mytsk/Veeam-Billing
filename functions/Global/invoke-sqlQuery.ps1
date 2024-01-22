# 
# dev remark: Not used
#

function Invoke-sqlQuery() {
    Param(
        [parameter(position = 0, Mandatory = $false)]
        [string]$server,
        [parameter(position = 1, Mandatory = $false)]
        [string]$database,
        [parameter(position = 2, Mandatory = $false)]
        [string]$port,
        [parameter(position = 3, Mandatory = $false)]
        [securestring]$credentials,
        [parameter(position = 4, Mandatory = $true)]
        [string]$query
    )
    write-host $query
    Invoke-Sqlcmd -ServerInstance $global:dbServer -Database $global:dbDatabase -Query $query 
}#function Invoke-sqlQuery