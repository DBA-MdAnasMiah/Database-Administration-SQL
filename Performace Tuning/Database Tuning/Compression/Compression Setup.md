
<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=Database&nbsp;Compression&nbsp;Setup;" />
</p>

## ==================== ROW Compression ==================

Row compression makes each row smaller by removing wasted/empty space.  
Like packing your clothes tighter in a suitcase. SQL only removes wasted internal space, **not your real data**.

### When to use ROW compression:
- The table is large.
- The table is read-heavy (many SELECTs).
- Indexes are big and used a lot.
- Data has many repeating or small numeric values.
- Storage or I/O is expensive.
- CPU has some free capacity.

### Benefits:
- Rows become smaller → database size goes down.
- More rows fit into each page → SQL reads fewer pages → faster queries.
- Helps with index scans (less I/O → better performance).

### Downside:
- Slight CPU overhead to compress/decompress.
- Doesn’t help much if data is already stored efficiently.

### What it removes (internal only):
- Fixed-length CHAR padding.
- Zero-padding on numeric values.
- Metadata padding (internal helper bytes).
- Unused bytes inside the row.

---

## Setup ROW compression:

### Step 1: Check table size
```sql
EXEC sp_spaceused 'Person.Person';
GO
```

### Step 2: Estimate compression (optional)
```sql
EXEC sp_estimate_data_compression_savings 
    @schema_name = 'Person',
    @object_name = 'Person',
    @index_id = NULL,
    @partition_number = NULL,
    @data_compression = 'ROW';
GO
```

### Step 3: Apply ROW compression
```sql
ALTER TABLE Person.Person
REBUILD PARTITION = ALL
WITH (DATA_COMPRESSION = ROW);
GO
```

### Step 4: Check table size again
```sql
EXEC sp_spaceused 'Person.Person';
GO
```

---

## ================ PAGE Compression ======================

PAGE compression makes a table smaller by finding repeated patterns in SQL’s internal pages and storing those patterns once.

### Important:
- Does NOT change your real data.
- Only reduces duplicate internal storage.

### Best for:
- Large tables.
- Read-heavy workloads.
- Repeated values.
- When you need more savings than ROW compression.

### Apply PAGE compression:
```sql
ALTER TABLE Person.Person
REBUILD PARTITION = ALL
WITH (DATA_COMPRESSION = PAGE);
GO
```

### Check size:
```sql
EXEC sp_spaceused 'Person.Person';
GO
```

---

## ======================= Backup Compression ================

Backup compression compresses the **backup file**, not the live database.

### Benefits:
- Smaller backup files.
- Faster backups.
- Safe for production.

### Apply backup compression:
```sql
BACKUP DATABASE [AdventureWorks2019]
TO DISK = N'D:\SQLData\AdventureWork2019.bak'
WITH
    NAME = N'AdventureWorks2019-Full Database Backup',
    COMPRESSION,
    STATS = 10;
GO
```

---

## Google Drive

[Google Drive Notes : Compression Setup](https://docs.google.com/document/d/1sxh61Ns_wgALPQ2UKWmlqkQA38QbCRBwc8vcTBvcvU0/edit?tab=t.0)

