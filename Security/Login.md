<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=SQL&#160Login;" />
</p>

# SQL Server Login Scripts


## To create login

The full backup is the **main** / **primary** backup that required for restoring the database.  

```sql
BACKUP DATABASE [your-db] 
TO DISK = N'D:\SQL-backup\your-db-backup-10-25-2025.bak' 
WITH NOFORMAT, NOINIT, NAME = N'test-db-Full Database Backup', SKIP, STATS = 10, compression;
```
