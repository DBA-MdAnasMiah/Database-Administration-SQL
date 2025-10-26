
<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=Setup&nbsp;Backup&nbsp;With&nbsp;Ole&nbsp;Hallengren&nbsp;Script" />
</p>


## ✨ What you get

- ✅ Production-grade backup jobs (`FULL`, `DIFF`, `LOG`)
- ✅ DBCC CHECKDB integrity checks
- ✅ Index and statistics maintenance
- ✅ Everything installed via **one** script: `MaintenanceSolution.sql`

---

## 📦 Prerequisites

- SQL Server (any supported edition)
- **sysadmin** on the target instance (to create jobs, procs, and Agent objects)
- SQL Server Agent **running**
- A backup directory/UNC share with **read/write** permission for the SQL Server **service account** (and SQL Agent if different)

---

## 🚀 Steps Setup

### Step 1 — Download the script
Get **`MaintenanceSolution.sql`** from:
- GitHub (Ola Hallengren’s repository), or here in this git repo
- The official website (https://ola.hallengren.com/sql-server-backup.html)

> File name: `MaintenanceSolution.sql`

---

### Step 2 — Edit the backup root path
Open the script and set your backup directory (UNC recommended):

```sql
-- Example: set a custom backup root directory
DECLARE @BackupDirectory nvarchar(max) = N'\\\\ANAS_PC\\SQL-backup';
-- If you leave @BackupDirectory NULL, SQL Server's default backup directory is used.

```

### Step 3 — Execute the MaintenanceSolution.sql file
Run the Script and go check if the jobs has been created


### Step 4 — Execute the MaintenanceSolution.sql file
Schedule each jobs accordingly






## 📚 Credits

This setup is powered by **Ola Hallengren’s SQL Server Maintenance Solution**.  
Please go to his site(https://ola.hallengren.com/sql-server-backup.html).

---

## Resources

- [YouTube Video](https://www.youtube.com/watch?v=iacDlUsc9UE)

[![Watch on YouTube](https://img.shields.io/badge/Watch-YouTube-red.svg)](https://www.youtube.com/watch?v=iacDlUsc9UE)

[![Video thumbnail](https://img.youtube.com/vi/iacDlUsc9UE/maxresdefault.jpg)](https://www.youtube.com/watch?v=iacDlUsc9UE)

<details>
  <summary>Video link</summary>

  https://www.youtube.com/watch?v=iacDlUsc9UE
</details>




