-- Fetches Total backup size for each server

DECLARE @importID VARCHAR(MAX) 
set @importID  = '5befaa7a-5653-45bc-9cca-92ff8da76b20'

SELECT  bs.server_fqdn as 'Backup Server', bj.BackupJob AS 'Backup Job', cj.CopyJob AS 'Copy Job'
  FROM tbl_backupserver bs
  INNER JOIN
  (
  SELECT backupserver_id, SUM(tbl_backups.backup_size_stored) AS BackupJob
	FROM tbl_backups
		WHERE Backup_type = 'Backup' AND import_id = @importID
		GROUP BY backupserver_id
		) bj ON bs.backupserver_id = bj.backupserver_id

 INNER JOIN
  (
  SELECT backupserver_id, SUM(tbl_backups.backup_size_stored) AS CopyJob
	FROM tbl_backups
		WHERE Backup_type = 'BackupSync' AND import_id = @importID
		GROUP BY backupserver_id
		) cj ON bs.backupserver_id = cj.backupserver_id


		ORDER BY server_fqdn


		