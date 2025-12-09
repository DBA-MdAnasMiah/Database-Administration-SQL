
<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=High&nbsp;Performance&nbsp;SQL&nbsp;Server&nbsp;Database&nbsp;Setup;" />
</p>


---

## 📌 Create basic database (not production grade)

```sql
CREATE DATABASE YourDBName
```

---

## 🏭 Create Database in production

```sql
CREATE DATABASE YourDBName
ON PRIMARY
(
    NAME       = N'YourDBName_Data',
    FILENAME   = N'D:\SQLData\YourDBName_Data.mdf',
    SIZE       = 20MB,                /* start with 1 GB in the prod, but lets use 20MB 
                                                     as we have limited storage. */
    FILEGROWTH = 20MB  )   /*   grow by 1 GB in actual production 
                                                      for now lets use 20MB */

LOG ON
(
    NAME       = N'YourDBName_Log',
    FILENAME   = N'L:\SQLLogs\YourDBName_Log.ldf',
    SIZE       = 20MB,        --20mb growth but usually  1-4 GB initial is fit for prod env
    FILEGROWTH = 20MB,         -- 20 MB growth
    MAXSIZE    = 1200MB        /*-- max 1 GB (optional), 
						we can also put unlimited here but best practice to calculate the size prior and provide it there 
	                   to prevent the log file from filling the entire disk, add more space as needed. */
);

ALTER DATABASE YourDBName SET RECOVERY FULL;
```

---

## 📘 What production environments have

👉 Large pre-sized data and log files  
👉 Multiple data files for performance (for big DBs)  
👉 Separate filegroups (audit, archive, indexes)  
👉 Fixed MB autogrowth  
👉 Dedicated drives for data/log/tempdb  

---

## 📂 Adding Secondary files to Database (best performance)

Small database (< 100 GB):  
- 1 data file (MDF only) is enough.  
- You do NOT need NDFs.

Medium OLTP database (100 GB – 500 GB):  
- 2–4 data files total (including MDF)  
- 1 MDF + 3 NDF (very common & best practice)  
- 1 MDF + 3 NDF (total 4 files) is a good default for OLTP.

Large OLTP or heavy workload (> 500 GB):  
- 4–8 data files (including MDF)

### ➕ Add secondary data files

```sql
USE master;
GO
ALTER DATABASE YourDBName
ADD FILE
  ( NAME       = N'YourDBName_Data2',
    FILENAME   = N'D:\SQLData\YourDBName_Data2.ndf',
    SIZE       = 20MB,
    FILEGROWTH =20MB),

   ( NAME       = N'YourDBName_Data3',
      FILENAME   = N'D:\SQLData\YourDBName_Data3.ndf',
      SIZE       = 20MB,
       FILEGROWTH = 20MB),

    ( NAME       = N'YourDBName_Data4',
    FILENAME   = N'D:\SQLData\YourDBName_Data4.ndf',
    SIZE       = 20MB,
    FILEGROWTH =20MB)
   TO FILEGROUP [PRIMARY];
```

### Notes

✔ Size & autogrowth must match master file  
✔ Same filegroup = same size + same autogrowth  
✔ MAXSIZE = UNLIMITED for MDF/NDF usually  

Benefits:  
✔ Perfect round-robin  
✔ Balanced I/O  
✔ Even free space distribution  

---

## 🔄 Enable proportional file growth (autogrow all files)

To check:

```sql
USE YourDBName
GO
SELECT * FROM sys.filegroups
```

Enable:

```sql
ALTER DATABASE YourDBName MODIFY FILEGROUP [primary] AUTOGROW_ALL_FILES;

USE YourDBName
GO
SELECT * FROM sys.filegroups
```

---

## 🚫 AUTO_SHRINK OFF

```sql
ALTER DATABASE YourDBName SET AUTO_SHRINK OFF;
```

AUTO_SHRINK OFF → prevents fragmentation.  
AUTO_SHRINK ON →  
❌ random shrinking  
❌ slows server  
❌ messy indexes  
❌ wastes CPU/I/O  

---

# ⚙️ Server(instance) level settings for performance

---

## ⚡ MaxDOP setting

MaxDOP = how many CPUs a query can use.

Best practice:  
 > 4 cores → MaxDOP 4  
 > 8 cores → MaxDOP 8  
  

```sql
EXEC sys.sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sys.sp_configure 'max degree of parallelism', 8;
RECONFIGURE;

SELECT value_in_use AS MaxDOP
FROM sys.configurations
WHERE name = 'max degree of parallelism';

EXEC sys.sp_configure;
```

---

## ⚙️ Cost threshold for parallelism

25 → more parallel queries  
50 → balanced  
100 → only big queries go parallel  

CPU Cores | Suggested Threshold  
--------- | -------------------  
4–8 cores | 25–40  
12–16 cores | 40–60  
20+ cores | 50–100  

Use **50**.

```sql
EXEC sys.sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sys.sp_configure 'cost threshold for parallelism', 50; 
RECONFIGURE;

SELECT value, value_in_use
FROM sys.configurations
WHERE name = 'cost threshold for parallelism';
```

---

## 💾 Setup Max Memory setting

SQL uses lots of RAM. OS needs RAM too.

Rule:  
- SQL Server = 75% of total RAM  
- OS = 25%  

Example:  
32GB * 0.75 = 24GB = 24576 MB  

```sql
EXEC sp_configure 'show advanced options', 1; 
RECONFIGURE;

EXEC sp_configure 'max server memory (MB)', 24576;
RECONFIGURE;

SELECT name, value_in_use
FROM sys.configurations
WHERE name IN ('max server memory (MB)', 'min server memory (MB)');
```

Note: keep **min memory** default.

---


## Google Drive
[Google Drive Notes : Database Best Settings](https://docs.google.com/document/d/1427v8ZH-i03cehsf8C95uEl2O4WJsg9onG1mgyv3OSo/edit?tab=t.0)







