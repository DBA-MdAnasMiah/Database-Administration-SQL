<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=Backup;" />
</p>




# SQL Server Backup Scripts

---

## Full Backup

The full backup is the **main** / **primary** backup that required for restoring the database.  

```sql
BACKUP DATABASE [your-db] 
TO DISK = N'D:\SQL-backup\your-db-backup-10-25-2025.bak' 
WITH NOFORMAT, NOINIT, NAME = N'test-db-Full Database Backup', SKIP, STATS = 10;
GO
```

### Options:
- **NOFORMAT**: Does not delete existing backups in the destination.  
- **NOINIT**: Prevents overwriting old backups in the file.  
- **NAME**: Metadata saved in SQL Server to identify this backup.  
- **SKIP**: Ignores certain safety checks. Allows backup even if file was created for a different database.  
- **STATS = 10**: Shows progress in 10% increments.

---

## Transaction Log Backup

Transaction log backups are **incremental backups**. They store all changes and modification since the last backup and require a **full backup first** for recovery.

```sql
BACKUP LOG [anas] 
TO DISK = N'D:\SQL-backup\your-db-11-25-2025.trn' with STATS = 10;

```

**Notes:**
- Only valid if a full backup exists.  
- Essential for point-in-time recovery.

---

## Differential Backup

Differential backups capture **all changes since the last full backup**, allowing you to combine multiple transaction logs into a single backup file.

```sql

BACKUP DATABASE [anas] TO  DISK = N'D:\SQL-backup\anas-diff-2025-10-25.bak' 
WITH  DIFFERENTIAL ,STATS = 10
```



## Script out all database full backup

This script out the output for all database excluding 4 system databases

```sql

select 'backup database [' +name+'] to disk = ''D:\SQL-backup\' + name +'.bak'' with stats = 15, compression;'
from sys.databases where database_id > 4

```



**Notes:**
- Requires a full backup to restore.  
- Useful for reducing restore time compared to restoring multiple transaction log backups.

---

## Summary

- **Full Backup**: Complete backup of a database.  
- **Transaction Log Backup**: Incremental changes; must follow full backup and captures the small chnages over time 
- **Differential Backup**: All changes since last full backup; combines multiple logs.  

💡 **Tip:** Make sure to test your backups and restores to ensure reliability.

