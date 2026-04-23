<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=SQL&nbsp;Server&nbsp;Mirroring;" />
</p>


# SQL Server Database Mirroring Setup Guide


> Step-by-step guide to configuring SQL Server Database Mirroring with troubleshooting, endpoint setup, and health monitoring.

---

## Architecture and Design

```
┌─────────────────────────────────────────────────────────────┐
                      MIRRORING TOPOLOGY                      
                                                             
   ┌──────────────┐              ┌──────────────┐           
   │  PRINCIPAL   │◄────────────►│    MIRROR    │           
   │   SERVER     │   TCP/IP     │    SERVER    │           
   │  Port: 5022  │    sync      │  Port: 5023  │           
   └──────┬───────┘              └──────┬───────┘           
          │                             │                   
          └──────────────┬──────────────┘                   
                        │                                  
                  ┌──────▼───────┐                          
                  │   WITNESS    │  <- Optional             
                  │    SERVER    │    (Auto Failover)        
                  └──────────────┘                          
└─────────────────────────────────────────────────────────────┘
```

---

## Table of Contents

- [Prerequisites](#-prerequisites)
- [Step 1 — Environment Setup](#-step-1--environment-setup)
- [Step 2 — Backup Databases](#-step-2--backup-databases)
- [Step 3 — Restore on Mirror Server](#-step-3--restore-on-mirror-server)
- [Step 4 — Configure Mirroring](#-step-4--configure-mirroring)
- [Step 5 — Health Status](#-step-5--health-status)
- [Troubleshooting](#-troubleshooting)
- [Health Metrics Reference](#-health-metrics-reference)
- [Useful Commands](#-useful-commands)

---

## Prerequisites

| Server | Role | Required |
|--------|------|----------|
| Principal Server | Primary active database |  Required |
| Mirror Server | Standby replica |  Required |
| Witness Server | Arbitrator for automatic failover |  Optional |

>  Configuration is easiest when all servers are in the **same domain**.

**Service Account** — create or have your service accounts ready
```
svc_mirror_account
```
> Can be a single shared domain account or separate service accounts.

---

##  Step 1 — Environment Setup

### Enable TCP/IP on ALL Servers

> ⚠️ TCP/IP is **mandatory**. SQL Server sends transaction log records over the network and only supports TCP/IP for mirroring.

Verify TCP/IP listeners are active:

```sql
SELECT * FROM sys.dm_tcp_listener_states;
```

>  Returns NULL? Go to **SQL Server Configuration Manager** → **SQL Server Network Configuration** → Enable **TCP/IP**.

---

##  Step 2 — Backup Databases

Run on the **Principal Server**. Copy-only backups work too.

### Full Backup

```sql
BACKUP DATABASE [YourDatabaseName]
TO DISK = N'C:\Backups\YourDatabaseName_FULL.bak'
WITH FORMAT, INIT, NAME = N'Full Backup', STATS = 10;
```

### Log Backup

```sql
BACKUP LOG [YourDatabaseName]
TO DISK = N'C:\Backups\YourDatabaseName_LOG.bak'
WITH FORMAT, INIT, NAME = N'Log Backup', STATS = 10;
```

---

## Step 3 — Restore on Mirror Server

Restore on the **Mirror Server** with `NORECOVERY` — the database must stay in **Restoring** state.

```sql
-- Restore Full Backup
RESTORE DATABASE [YourDatabaseName]
FROM DISK = N'C:\Backups\YourDatabaseName_FULL.bak'
WITH NORECOVERY, STATS = 10;

-- Restore Log Backup
RESTORE LOG [YourDatabaseName]
FROM DISK = N'C:\Backups\YourDatabaseName_LOG.bak'
WITH NORECOVERY, STATS = 10;
```

 The mirror database will show as **"Restoring..."** in SSMS — this is correct!

---

## Step 4 — Configure Mirroring


1. In Object Explorer, right-click the database → Properties
2. Go to the Mirroring page
3. Click Configure Security
4. Follow the wizard:

```
[Next] → Include Witness?
         ├── YES → Automatic Failover 
         └── NO  → Manual Failover

→ Select Principal Server (auto-filled)
→ Add Mirror Server instance
→ Add Witness Server instance (if applicable)
→ Configure Service Accounts for all three

no add mirroring endpoint steps here with the same style that i gave you
```


### Via T-SQL

> Run on **Mirror FIRST**, then Principal.

```sql
-- On MIRROR first:
ALTER DATABASE [YourDatabaseName]  
SET PARTNER = 'TCP://10.0.0.214:5022'; -- Your principal IP or device name goes here.

-- On PRINCIPAL second:
ALTER DATABASE [YourDatabaseName]
SET PARTNER = 'TCP://10.0.0.214:5023'; Your mirror IP or device name goes here.
```

---

## Step 5 — Health Status

### ✔ Success State

```
Principal Server:  YourDB (Principal, Synchronized) 
Mirror Server:     YourDB (Mirror, Synchronized / Restoring) 
```

### Status Reference

| Status | Meaning |
|--------|---------|
| `Principal, Synchronized` |  Live and in sync |
| `Mirror, Synchronized / Restoring` |  Receiving and applying logs |
| `Disconnected` | ✗ Network or service issue |
| `Suspended` | ⚠️ Mirroring paused manually or due to error |

---

## 🩺 Health Metrics Reference

### Unsent Log
Data waiting on the principal to be sent to the mirror.

| Range | Status |
|-------|--------|
| `0 – 100 MB` | Healthy |
| `Growing GBs` | Log cannot truncate — **disk space risk!** |

> If unchecked, the log file can fill the drive and **stop all database operations**.

---

### Current Sent Log
Data already transmitted over the network.

| Range | Status |
|-------|--------|
| `0 – 200 MB` |  Healthy |
| `200 – 500 MB` |  Acceptable under peak load |
| `500 MB – 2 GB` (stable) | Network slowdown warning |
| `5 GB+` (growing) | ✗ Network bottleneck or mirror lag |

---

### Redo Queue
Data received by mirror but not yet applied.

| Range | Status |
|-------|--------|
| `0 – 200 MB` | ✔ Healthy |
| `Growing GBs` | ✗ Mirror CPU/disk bottleneck |

---

### Time Behind
How far the mirror is lagging behind the principal.

| Range | Status |
|-------|--------|
| `0 – 1 second` | Healthy (sync mode) |
| `Increasing` |  Mirror falling behind — failover risk |

---

## Troubleshooting

### Common Problems & Fixes

| # | Problem | Fix |
|---|---------|-----|
| 1 | Used `localhost` in TCP address | Use actual IP e.g. `10.0.0.214` |
| 2 | Both endpoints on same port `5022` | Move mirror to port `5023` |
| 3 | Service accounts not granted CONNECT | Create logins & grant CONNECT on endpoints |
| 4 | **Encryption mismatch** *(the real killer)* | Recreate both endpoints with matching AES |

---

### Fix 1 — Use IP Address, Not Hostname

Always use the actual server IP. Never use `localhost` or machine name for cross-server mirroring.

---

### Fix 2 — Enable TCP/IP

SQL Server Configuration Manager → SQL Server Network Configuration → Enable **TCP/IP**.

---

### Fix 3 — Same Machine? Use Different Ports

- Principal: `5022`
- Mirror: `5023`

---

### Fix 4 — Create Service Account Login

```sql
-- Check current service account
SELECT servicename, service_account, status_desc
FROM sys.dm_server_services;

-- Create the login if missing
CREATE LOGIN [NT Service\MSSQL$DATACENTER] FROM WINDOWS;
```

---

### Fix 5 — Grant CONNECT on Mirroring Endpoint

```sql
-- On Principal:
GRANT CONNECT ON ENDPOINT::Mirroring TO [NT Service\MSSQL$DATACENTER];

-- On Mirror:
GRANT CONNECT ON ENDPOINT::Mirroring TO [NT Service\MSSQL$TESTINGSERVER];
```

---

### Fix 6 — Fix Encryption Mismatch

Check current settings on both servers:

```sql
SELECT name, state_desc, encryption_algorithm_desc, connection_auth_desc
FROM sys.database_mirroring_endpoints;
```

Recreate with matching AES encryption.

**Principal (Port 5022):**

```sql
CREATE ENDPOINT Mirroring
    STATE = STARTED
    AS TCP (LISTENER_PORT = 5022)
    FOR DATABASE_MIRRORING (
        AUTHENTICATION = WINDOWS NEGOTIATE,
        ENCRYPTION = REQUIRED ALGORITHM AES,
        ROLE = ALL
    );
```

**Mirror (Port 5023):**

```sql
CREATE ENDPOINT Mirroring
    STATE = STARTED
    AS TCP (LISTENER_PORT = 5023)
    FOR DATABASE_MIRRORING (
        AUTHENTICATION = WINDOWS NEGOTIATE,
        ENCRYPTION = REQUIRED ALGORITHM AES,
        ROLE = ALL
    );
```

---

## Useful Commands

### Read Error Logs

```sql
EXEC xp_readerrorlog 0, 1, N'Mirroring';
EXEC xp_readerrorlog 0, 1, N'login';
```

### Reset / Clear Mirroring

```sql
-- Run on BOTH servers:
ALTER DATABASE [YourDatabaseName] SET PARTNER OFF;
```

### Manual Failover

```sql
-- Run on PRINCIPAL only:
ALTER DATABASE [YourDatabaseName] SET PARTNER FAILOVER;
```

### Common Error

```
Connection handshake failed. There is no compatible encryption algorithm. State 22.
```

> One endpoint is `REQUIRED`, the other is `DISABLED` or a different algorithm. See [Fix 6](#fix-6--fix-encryption-mismatch).

---

## Quick Reference Flow

```
1. Prepare servers ──► Principal + Mirror + optional Witness
         │
2. Enable TCP/IP ────► On ALL servers
         │
3. Create service ───► svc_mirror_account
   account
         │
4. Backup ───────────► FULL + LOG on Principal
         │
5. Restore ──────────► NORECOVERY on Mirror
         │
6. Configure ────────► Security Wizard in SSMS
         │
7. Verify ───────────► Principal, Synchronized 
```

---

<div align="center">

### You have successfully configured SQL Server Database Mirroring!

## Google Drive
[Google Drive Notes : Mirroring](https://docs.google.com/document/d/1uexkx1Rm6sl_CHoepIMffk_YvBakuHIaDzY4HZW4iYI/edit?tab=t.0)



