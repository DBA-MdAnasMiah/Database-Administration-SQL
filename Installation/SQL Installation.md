<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=SQL+Server+Installation;DBA+Reference+Guide" />
</p>

---

# 🗄️ SQL Server — Installation Guide

A complete DBA reference covering pre-installation, installation configuration, and post-installation tuning.

---

## 📑 Table of Contents

- [Pre-Installation Configuration](#pre-installation-configuration)
  - [Server Requirements](#server-requirements)
  - [SQL Server Editions](#sql-server-editions)
  - [Drive Layout](#drive-layout)
  - [Drive Formatting Best Practice](#drive-formatting-best-practice)
- [Installation Configuration](#installation-configuration)
- [Post-Installation Configuration](#post-installation-configuration)
  - [MaxDOP](#maxdop)
  - [Cost Threshold for Parallelism](#cost-threshold-for-parallelism)
  - [Max Memory](#max-memory)
- [Installation Checklist](#-installation-checklist)

---

## Pre-Installation Configuration

### Server Requirements

| Component | Requirement |
|-----------|-------------|
| **OS** | Windows Server 2019 or 2022 (Enterprise/Datacenter) |
| **RAM** | 64–256 GB depending on workload |
| **CPU** | 16–32 cores recommended |
| **.NET Framework** | Version supported by chosen SQL edition |

> ⚠️ Network and OS security setup is usually handled by system engineers / sysadmins.

---

### SQL Server Editions

| Edition | Use Case |
|---------|----------|
| **Enterprise** | Banks, large companies, high-traffic systems, advanced HA/DR |
| **Standard** | Small/mid-size companies, medium workloads, basic HA, lower cost |
| **Developer** | Development environments **only** — cannot be used in production |

> ⭐ **Simple rule:** Enterprise = big production systems. Standard = normal production systems. Both are valid for production.

---

### Drive Layout

| Drive | Purpose |
|-------|---------|
| `C:` | OS + SQL Binaries (OS files, SQL Server installation & system binaries) |
| `B:` | Backup — database backup files |
| `D:` | SQLData — system/user database data files (`.mdf` / `.ndf`) |
| `L:` | SQLLogs — system/user database log files (`.ldf`) |
| `T:` | TempDB — TempDB data files (4–8 files recommended) |
| `I:` | TempDBLog — TempDB log files |

> ⚠️ Do **not** store database files or logs on the `C:` drive — best practice only keeps OS and SQL binaries there.

---

### Drive Formatting Best Practice

| Setting | Value |
|---------|-------|
| **File System** | NTFS |
| **Allocation Unit Size** | **64K (64 Kilobytes)** |
| **Why?** | Bigger data moves = fewer trips = faster SQL performance |

```
4K  = small data moves
64K = big data moves → fewer trips → faster SQL
```

> ⚠️ Formatting erases all data — must be done in a **fresh environment** before setup.

**To format:** Right-click drive → Format → File System: `NTFS` → Allocation Unit Size: `64 Kilobytes` → Set appropriate Volume Label (e.g. `Backup` for B:)

> 💡 Create a dedicated Windows login for the **SQL Server service account** and optionally a separate one for **SQL Agent**.

---

## Installation Configuration

**Step-by-step wizard flow:**

```
Open SQL Server setup file
→ Customize
→ Microsoft Update (uncheck) → Next
→ Install Rules → Next
→ Installation Type: New installation → Next
→ Product Key (Evaluation / Standard / Enterprise) → Next
→ Feature Selection → Next
→ Instance Configuration (Named Instance e.g. "master") → Next
→ Server Configuration (set service accounts) → Next
   ✔ Enable: Grant Perform Volume Maintenance Task privilege
→ Database Engine Configuration
   • Authentication: Mixed Mode + strong SA password
   • Add current local admin user
→ Data Directories
   • Instance root  → C:\
   • Data (MDF/NDF) → D:\
   • Logs (LDF)     → L:\
   • Backup         → B:\
→ TempDB Configuration
   • Files = number of CPU cores (e.g. 2 cores = 2 files)
   • Separate drive T:\ for data and log
   • Initial size: 512 MB per file | Auto-growth: 128 MB fixed
→ Integration Services Scale Out (Master Mode) → Next
→ Distribution Replay Controller → Next
→ Ready to Install → Install
```

> 💡 **Volume Maintenance Task privilege** lets SQL Server grow/shrink database files faster. Without it SQL still works but file operations are slower and may cause more disk fragmentation.

> 💡 **FILESTREAM** is NOT required for most SQL Server installations — safe to skip.

> 🔒 **SSIS Scale Out:** SSL Certificate = secure communication 🔒, Port = connection door 🚪, Scale Out = multiple servers working together ⚙️. Not needed unless using SSIS Scale Out.

---

## Post-Installation Configuration

After installation, install **SSMS** and connect, then apply the following settings.

---

### MaxDOP

Controls how many CPU cores SQL Server can use for a single query — prevents CPU overload and keeps performance balanced.

| Cores | Recommended MaxDOP |
|-------|--------------------|
| 4 cores | 4 |
| 8 cores | 8 |
| > 8 cores | **8** (cap at 8) |

```sql
EXEC sys.sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sys.sp_configure 'max degree of parallelism', 8;
RECONFIGURE;
```

```sql
-- Verify setting
SELECT value_in_use AS MaxDOP
FROM sys.configurations
WHERE name = 'max degree of parallelism';

-- View all advanced options
EXEC sys.sp_configure;
```

---

### Cost Threshold for Parallelism

Tells SQL Server to only use multiple CPUs for big/heavy queries, not small/quick ones.

| Value | Behavior |
|-------|----------|
| `25` | More queries use multiple CPUs |
| `50` | Balanced ✅ (recommended for 90% of environments) |
| `100` | Only very large queries use multiple CPUs |

| CPU Cores | Suggested Threshold |
|-----------|---------------------|
| 4–8 cores | 25–40 |
| 12–16 cores | 40–60 |
| 20+ cores | 50–100 |

```sql
EXEC sys.sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sys.sp_configure 'cost threshold for parallelism', 50;
RECONFIGURE;
```

```sql
-- Verify setting
SELECT value, value_in_use
FROM sys.configurations
WHERE name = 'cost threshold for parallelism';
```

---

### Max Memory

Prevents SQL Server from consuming all RAM — reserves memory for the OS.

```
Rule:    75% for SQL Server, remaining 25% for OS
Formula: Total RAM × 0.75 = SQL Max Memory (then convert to MB)
Example: 32 GB × 0.75 = 24 GB → 24 × 1024 = 24,576 MB
```

**Get total physical memory (run in CMD as admin):**
```cmd
systeminfo | find "Total Physical Memory"
```

```sql
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'max server memory (MB)', 24576;
RECONFIGURE;
```

```sql
-- Verify setting
SELECT name, value_in_use
FROM sys.configurations
WHERE name IN ('max server memory (MB)', 'min server memory (MB)');
```

> ⚠️ Leave **min server memory** at default (0 or near 0). Do **not** set it equal to max memory.

---

## ✅ Installation Checklist

```
[ ] Download SQL Server setup
[ ] Download SSMS
[ ] Run Setup.exe
[ ] Choose New SQL Server stand-alone installation
[ ] Accept license → Next
[ ] Run setup roles → Fix issues → Next
[ ] Select features: Database Engine, SQL Agent, (optional SSIS/SSRS) → Next
[ ] Choose instance: Default (MSSQLSERVER) or Named instance → Next
[ ] Set service accounts for SQL Engine & SQL Agent → Startup = Automatic → Next
[ ] Choose Mixed Mode → Set SA password → Add SQL admins
[ ] Disable default sa account
[ ] Set file locations:
      Data    → D:\
      Log     → L:\
      TempDB  → T:\Data  and  T:\Log
      Backups → B:\
[ ] Configure TempDB: 4–8 files, ~8 GB each, log 2–4 GB
[ ] Review summary → Click Install
[ ] Close installer
[ ] Install SSMS
[ ] Connect to SQL Server
[ ] Configure post-install settings:
      Max Memory
      MaxDOP
      Cost Threshold
      Backup jobs (if required)
```

---

## 📄 Google Drive Notes

- [Installation Notes — Google Doc](https://docs.google.com/document/d/12V21kO1DB0nqdWZR8wPLK0ArqkmN-9VN9MRcvQSSK5w/edit?tab=t.0)
