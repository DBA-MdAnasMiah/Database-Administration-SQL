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
```
Step 3: enable query store to run read_write mode (this allows to actively captures data)
 
 ```sql
alter database adventureworks2019 
set query_store (operation_mode = read_write);
go
```
Step 4: Increasing the size(production friendly)

 ```sql
alter database adventureworks2019  
set query_store (max_storage_size_mb = 2000);
 ```

Step 5: set collection interval to 30 mins (default is 60 minutes)

 ```sql
alter database adventureworks2019 
set query_store (interval_length_minutes = 30);
go
 ```

Step 6: Change capture mode to auto or all
```sql
alter database adventureworks2019   
set query_store (query_capture_mode = auto) 
/*
Three Options are there:
	set query_store (query_capture_mode = all);      --> Capture all queries information, Everything (heavy)
	set query_store (query_capture_mode = auto)  --> Captures only important qeuries, Smart capture (recommended) 
	set query_store (query_capture_mode = auto)  --> Capture Nothing
*/
```


---


## Cleanup old queries from QueryStore

Step 1:

```sql
-- cleanup old/stale queries (7 days)
alter database adventureworks2019   
set query_store (cleanup_policy = 
(stale_query_threshold_days = 7));

--Note: this cleaup query store so it doesnt grow too big or has storage issues.

```

Step 2: enable automatic size-based cleanup.

```sql
alter database adventureworks2019   
set query_store (size_based_cleanup_mode = auto);

/*
This allows --> If Query Store gets too big, automatically clean up old data to make space
                What SIZE_BASED_CLEANUP_MODE = AUTO does
                  --> SQL Server monitors Query Store size
                  --> When it hits a limit → it automatically deletes old/less useful data
                  --> You don’t need to manually clean it
*/

```

Step 3: You can remove a sppecific query from queryStore to cleanup(optional) or exetuion plan or statistices for a plan

```sql
-- Remove a specific query from query store history
exec sp_query_store_remove_query 136;

-- Remove a specific execution plan
exec sp_query_store_remove_plan 3;


-- Reset execution statistics for a plan
exec sp_query_store_reset_exec_stats 3;


```


---

## Save QueryStore in Disk

This allow query store to save into disk.
```sql

-- flush in-memory data to disk
exec sp_query_store_flush_db;
/* Take all Query Store data that is currently in memory (RAM) and save it to disk right now */
```


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






