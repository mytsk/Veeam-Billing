function get-dbVBRServers {

  $qBUServers =
  "
    SELECT tbl_backupserver.backupserver_id AS backupserver_id, tbl_backupserver.customer_id AS customer_id, server_fqdn, customer_name,vc_customer_id
    FROM tbl_backupserver
    INNER JOIN tbl_customer
    ON tbl_backupserver.customer_id = tbl_customer.customer_id
    WHERE tbl_backupserver.is_active = 1
    ORDER BY Customer_id
  "
  $rBUServers = Invoke-sqlcmd -query $qBUServers -ServerInstance $Global:dbServer -Database $Global:dbDatabase 

  return $rBUServers
}#function get-dbVBRServers
