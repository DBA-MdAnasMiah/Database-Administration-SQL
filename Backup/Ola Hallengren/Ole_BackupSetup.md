
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

## 🚀 3-Step Setup

### Step 1 — Download the script
Get **`MaintenanceSolution.sql`** from:
- GitHub (Ola Hallengren’s repository), or  
- The official website

> File name: `MaintenanceSolution.sql` (exact casing doesn’t matter)

---

### Step 2 — Edit the backup root path
Open the script and set your backup directory (UNC recommended):

```sql
-- Example: set a custom backup root directory
DECLARE @BackupDirectory nvarchar(max) = N'\\\\ANAS_PC\\SQL-backup';
-- If you leave @BackupDirectory NULL, SQL Server's default backup directory is used.




https://ola.hallengren.com/sql-server-backup.html
