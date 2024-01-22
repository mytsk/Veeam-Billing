function get-dbVBRCredentials {
  Param(
    [parameter(Mandatory = $false)][string] $backupserver       
  )

  $q =
  "
      SELECT tbl_backupserver.server_username AS Username, tbl_backupserver.server_password as SecureString
      FROM tbl_backupserver
      WHERE tbl_backupserver.server_fqdn = '$backupserver'
    "
  $result = Invoke-sqlcmd -query $q -ServerInstance $Global:dbServer -Database $Global:dbDatabase 
  
  return $result
}#function get-dbVBRCredentials
  