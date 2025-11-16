
<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=Extended&nbsp;Event;" />
</p>




# Lets Setup an Extended Event (it will capture any query that runs more than 30 second and store to a table).

---

## Step 1: lets create the extended event

First we will create the extended Event and enable it.  

```sql

USE master;
GO

CREATE EVENT SESSION [capture30LongQuery] ON SERVER

ADD EVENT sqlserver.rpc_completed      /*👉 Watch stored procedures that take too long*/
(
    ACTION
    (
        sqlserver.client_app_name,                   /*👉 What app ran the query (SSMS, .NET app, etc.) */
        sqlserver.client_hostname,                   /*👉 What computer sent the query  */
        sqlserver.database_id,                        /*👉 Database number  */
        sqlserver.database_name,               /*👉  Database name   */
        sqlserver.plan_handle,                     /* With this number, you can later open the execution plan */
        sqlserver.server_principal_name,  /*👉 Login name */
        sqlserver.session_nt_username,   /*👉Windows username */
        sqlserver.session_id,                    /*👉 Session number (ticket number) */
        sqlserver.username,                 /*👉 SQL username */
        sqlserver.sql_text                    /*👉 The exact SQL text that ran */
    )
    WHERE
    (
        duration > 30000000              /*👉 Only capture if > 30 seconds */
        AND NOT sqlserver.like_i_sql_unicode_string(sqlserver.sql_text, N'%backup%')
                                         /*👉 dont capture backup commands */
    )
),

ADD EVENT sqlserver.sql_batch_completed
(
    ACTION
    (
        sqlserver.client_app_name,                  /*👉 App running the query */
        sqlserver.client_hostname,                  /*👉 Computer name */
        sqlserver.database_id,                       /*👉 Database ID */
        sqlserver.database_name,              /*👉 Database name */
        sqlserver.plan_handle,                    /*👉 A special ID that lets you open the execution plan later.*/
        sqlserver.server_principal_name, /*👉Login name */
        sqlserver.session_nt_username,  /*👉 Windows username */
        sqlserver.session_id,                   /*👉 Session number */
        sqlserver.username,                /*👉SQL user */
        sqlserver.sql_text                   /*👉 The SQL text developer or process = ran */
    )
    WHERE
    (
        duration > 30000000              /*👉 Only record any query running over 30 */
        AND NOT sqlserver.like_i_sql_unicode_string(sqlserver.sql_text, N'%backup%')
                                         /*👉  Skip backup commands */
    )
)


ADD TARGET  package0.event_file
(
    SET
        filename = N'\\ANAS_PC\anas\extendedEvent\capture30LongQuery.xel',   /*👉 location where to save the extended event file, makesure put SQL SA account permission to this folder */
        max_file_size = (10),                                               /*👉 Each file can grow to 10 MB */
        max_rollover_files = 3                                           /*👉 Keep 3 files max then rolls over */
)

WITH
(
    MAX_MEMORY = 4096 KB,                                                        /*👉 Memory use by the XE session */
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS, /*👉 If SQL Server is super busy, it’s okay to drop a tiny number of events so the server doesn’t slow down */
    MAX_DISPATCH_LATENCY = 60 SECONDS,   /* 👉 server waits 60 second before writting those logs to data file */
    MAX_EVENT_SIZE = 0 KB,                               /* 👉 Setting 0 means, we let sql manage it so it doesnt break */
    MEMORY_PARTITION_MODE = NONE,      /*👉 Do NOT divide the XE memory */
    TRACK_CAUSALITY = OFF,                        /* 👉 We are NOT linking events together */
    STARTUP_STATE = ON                              /* 👉 If the SQL Server restarts, it automatically start*/
);
GO



```

### Options:
- **MAX_MEMORY**: Memory use by the XE session.  
- **EVENT_RETENTION_MODE**: If SQL Server is super busy, it’s okay to drop a tiny number of events so the server doesn’t slow down.  
- **MAX_DISPATCH_LATENCY**: server waits time before writting those logs to data file.  
- **MEMORY_PARTITION_MODEP**: Do NOT divide the XE memory.  
- **TRACK_CAUSALITY**: We are NOT linking events together.
- ** STARTUP_STATE**: If the SQL Server restarts, it automatically star.
> This extended event file will be created in the following path -> N'\\ANAS_PC\anas\extendedEvent\capture30LongQuery.xel'
---

## Step 2: Now run/enable the Extended Event that we generated.

```sql
USE MASTER;
GO;
ALTER EVENT SESSION [capture30LongQuery] ON SERVER STATE = START;
```

## Step 3: Create a table in DBA databse that will hold the 

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






