-- Fetches all the backups collected today.

SELECT *
	FROM tbl_backups 
	WHERE import_id in (SELECT DISTINCT import_id FROM tbl_backups WHERE import_id IS NOT NULL ) 
		AND backup_fetch_date >= CONVERT(DATE, getdate())

