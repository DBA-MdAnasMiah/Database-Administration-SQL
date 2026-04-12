<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=QueryStore;" />
</p>




# Query Store Setup
The purpose of query store to capture and store historical data for queries, execution plans, statistics and used as first point of reference for troubleshooting long running queries, performance related issues.
## Steps
Step 1: use your desire database.


```sql
USE AdventureWorks2019
```

Step 2: enable query store

```sql
alter database adventureworks2019 
set query_store = on;
go
```
---


## Transaction Log Backup

Transaction log backups are **incremental backups**. They store all changes and modification since the last backup and require a **full backup first** for recovery.

```sql
BACKUP LOG [anas] 
TO DISK = N'D:\SQL-backup\your-db-11-25-2025.trn' with STATS = 10, compression;

```

**Notes:**
- Only valid if a full backup exists.  
- Essential for point-in-time recovery.

---

## Differential Backup

Differential backups capture **all changes since the last full backup**, allowing you to combine multiple transaction logs into a single backup file.

```sql

BACKUP DATABASE [anas] TO  DISK = N'D:\SQL-backup\anas-diff-2025-10-25.bak' 
WITH  DIFFERENTIAL ,STATS = 10, compression;
```
**Notes:**
- Requires a full backup to restore.  
- Useful for reducing restore time compared to restoring multiple transaction log backups.

---


## Script out all database full backup

This script out the output for all database backup excluding 4 system databases

```sql

select 'backup database [' +name+'] to disk = ''D:\SQL-backup\' + name +'.bak'' with stats = 15, compression;'
from sys.databases where database_id > 4

```


```sql

select
'BACKUP DATABASE ['+name+'] TO  DISK = N''B:\Anas_PC$DATACENTER\Events\'+name+'_FULL_'+format(getdate(), 'MM_dd_yyyy')+'.bak''
WITH compression,  STATS = 10'
from sys.databases
where database_id > 4

```



##  To check if the last backup with 'copy only' or not 

This Script will show you if the last backup had copy only option selected

```sql


SELECT TOP 1
    bs.database_name,
    bs.backup_start_date,
    bs.backup_finish_date,
    bs.type AS backup_type,       -- D = full, I = diff, L = log
    bs.is_copy_only,              -- 1 = COPY_ONLY, 0 = normal
    CASE 
        WHEN bs.is_copy_only = 1 THEN 'COPY_ONLY Backup'
        ELSE 'Normal Backup'
    END AS CopyOnlyStatus,
    bmf.physical_device_name AS BackupFile
FROM msdb.dbo.backupset bs
JOIN msdb.dbo.backupmediafamily bmf
    ON bs.media_set_id = bmf.media_set_id
WHERE bs.database_name = 'AdventureWaorks2019'
ORDER BY bs.backup_finish_date DESC;

```



##  To check if last the backup had compression or not

This Script will show you if the last backup had copy only option selected

```sql


SELECT
    bs.database_name,
    bs.backup_finish_date,
    bs.backup_size,
    bs.compressed_backup_size,
    CASE
        WHEN bs.compressed_backup_size < bs.backup_size THEN 'Compressed'
        ELSE 'Not Compressed'
    END AS CompressionStatus,
    bmf.physical_device_name
FROM msdb.dbo.backupset bs
JOIN msdb.dbo.backupmediafamily bmf
    ON bs.media_set_id = bmf.media_set_id
ORDER BY bs.backup_finish_date DESC;


```


##  I have created an app called 'SIMPLE/EASY backup software'

When running this, it will take backup for you.

- **Download**: [sql_connect-v5.ps1](https://github.com/DBA-MdAnasMiah/Database-Administration-SQL/blob/main/Backup/MySoftwares/sql_connect-v5.ps1)
  





## Summary

- **Full Backup**: Complete backup of a database.  
- **Transaction Log Backup**: Incremental changes; must follow full backup and captures the small chnages over time 
- **Differential Backup**: All changes since last full backup; combines multiple logs.  

💡 **Tip:** Make sure to test your backups and restores to ensure reliability.

## Google Drive
[Google Drive Notes : Backup](https://docs.google.com/document/d/11Hq9WW8hcnbiI5aux144dF5ZbOWwO6shx2ptFRVTE0g/edit?tab=t.0)






