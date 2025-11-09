
<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=Capture&#160Login;" />
</p>




# SQL Server Login Capture by Audit
We will be capturing who login to SQL server. This audit wont capture anything else other than Logins.
---

Step 1: 

```sql
USE [master]

RESTORE DATABASE [Datawarehouse] FROM  DISK = N'D:\backup\Datawrarehouse.bak' WITH  FILE = 1, 
MOVE N'Datawarehouse' TO N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Datawarehouse.mdf', 
MOVE N'Datawarehouse_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Datawarehouse_log.ldf',  STATS = 10

GO


```

### Options:
- **Restore with Recovery**: finishes the restore and makes the database ready to use — no more restores can be done after that.
- **Restore with no Recovery**: Means other file left to add. This keeps the database in restoring mode, so you can apply more backups (like differential or log backups) before making it usable.
- **Relocate all files to folder**: when we restore a database, SQL Server will put all the database files (.mdf, .ndf, .ldf) into the new folder you choose instead of their old original paths.
---

## To restore trn logs

To restore a transaction log backup, the database must first be in restoring mode, which happens when you restore the earlier backup with NO RECOVERY.

```sql
RESTORE LOG [Datawarehouse] -- database name goes here
FROM DISK = N'D:\backup\datawarehouse.trn' -- path of your tnn log file
WITH RECOVERY;     -- this makes DB ready to use

```

**Notes:**
- must have fullbackup earlier
- Essential for point-in-time recovery.
- Need to have 'with recovery' to bring back database online

---


## To restore differential backup 

to restore differencial backup, we need to have the database in restoring state earlier.

```sql

RESTORE DATABASE [Datawarehouse]
FROM DISK = N'D:\backup\datawarehouse_diff.bak' -- must have accurate path
WITH RECOVERY,
STATS = 10;

```


## Summary

- **WITH NORECOVERY**: Keeps the database in restoring mode. Allows more backups (like differential or log) to be restored.Use this for all restores before the final one.
- **WITH RECOVERY**:Brings the database online and ready to use. No more backups can be restored after this. Use this for the last restore step.

`RECOVERY → Finish and bring online` <br>
`NORECOVERY → Keep restoring`

First, restore the full backup and keep it in restoring mode - WITH NORECOVERY.
Next, restore the differential backup if you have one - WITH NORECOVERY.
Finally, restore the log backup and use WITH RECOVERY to make the database ready to use.


## Google Drive
[Google Drive Notes : Restore](https://docs.google.com/document/d/1pNMo2O8gcfVnmWUz7CUNayFCvlc6lQzvt-mkI7haPbM/edit?tab=t.0)







