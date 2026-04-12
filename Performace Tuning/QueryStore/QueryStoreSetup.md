<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=QueryStore;" />
</p>




# Query Store Setup
The purpose of query store to capture and store historical data for queries, execution plans, statistics and used as first point of reference for troubleshooting long running queries, performance related issues.
## Steps
Step 1: use your desire database.
```sql
USE AdventureWorks2019
```

Step 2: enable query store
```sql
alter database adventureworks2019 
set query_store = on;
```
Step 3: enable query store to run read_write mode (this allows to actively captures data)
 
 ```sql
alter database adventureworks2019 
set query_store (operation_mode = read_write);
go
```
Step 4: Increasing the size(production friendly)

 ```sql
alter database adventureworks2019  
set query_store (max_storage_size_mb = 2000);
 ```

Step 5: set collection interval to 30 mins (default is 60 minutes)

 ```sql
alter database adventureworks2019 
set query_store (interval_length_minutes = 30);
go
 ```

Step 6: Change capture mode to auto or all
```sql
alter database adventureworks2019   
set query_store (query_capture_mode = auto) 
/*
Three Options are there:
	set query_store (query_capture_mode = all);      --> Capture all queries information, Everything (heavy)
	set query_store (query_capture_mode = auto)  --> Captures only important qeuries, Smart capture (recommended) 
	set query_store (query_capture_mode = auto)  --> Capture Nothing
*/
```


---


## Cleanup old queries from QueryStore

Step 1:

```sql
-- cleanup old/stale queries (7 days)
alter database adventureworks2019   
set query_store (cleanup_policy = 
(stale_query_threshold_days = 7));

--Note: this cleaup query store so it doesnt grow too big or has storage issues.

```

Step 2: enable automatic size-based cleanup.

```sql
alter database adventureworks2019   
set query_store (size_based_cleanup_mode = auto);

/*
This allows --> If Query Store gets too big, automatically clean up old data to make space
                What SIZE_BASED_CLEANUP_MODE = AUTO does
                  --> SQL Server monitors Query Store size
                  --> When it hits a limit → it automatically deletes old/less useful data
                  --> You don’t need to manually clean it
*/

```

Step 3: You can remove a sppecific query from queryStore to cleanup(optional) or exetuion plan or statistices for a plan

```sql
-- Remove a specific query from query store history
exec sp_query_store_remove_query 136;

-- Remove a specific execution plan
exec sp_query_store_remove_plan 3;


-- Reset execution statistics for a plan
exec sp_query_store_reset_exec_stats 3;


```


Step 4: you can clearup entire query store in one go.

```sql

alter database adventureworks2019 
set query_store clear;

--Note: this clelar queryStore entirely (use carefully)
```

---

## Save QueryStore in Disk

This allow query store to save into disk.
```sql

-- flush in-memory data to disk
exec sp_query_store_flush_db;
/* Take all Query Store data that is currently in memory (RAM) and save it to disk right now */
```


## Script out all database full backup

This script out the output for all database backup excluding 4 system databases

```sql

select 'backup database [' +name+'] to disk = ''D:\SQL-backup\' + name +'.bak'' with stats = 15, compression;'
from sys.databases where database_id > 4

```


```sql

select
'BACKUP DATABASE ['+name+'] TO  DISK = N''B:\Anas_PC$DATACENTER\Events\'+name+'_FULL_'+format(getdate(), 'MM_dd_yyyy')+'.bak''
WITH compression,  STATS = 10'
from sys.databases
where database_id > 4

```



##  Check all queries from queryStore

This query out all the query inside the queryStore.

```sql
use adventureworks2019
go
select 
    txt.query_text_id,
    txt.query_sql_text,
    pl.plan_id,
    qry.*
from sys.query_store_plan as pl
join sys.query_store_query as qry
    on pl.query_id = qry.query_id
join sys.query_store_query_text as txt
    on qry.query_text_id = txt.query_text_id;
go

```



##  Check QueryStore Options

Step 1: Check query Store status
```sql

Step 1: Check query Store status



```
Step 1: Check query Store status in details

```sql
-- Shows Query Store settings for this database
-- (like ON/OFF, size limit, cleanup rules, capture mode, etc.)
select * from sys.database_query_store_options;


-- Shows environment/settings used when queries run
-- (like SET options, ANSI settings, etc. — helps explain why same query behaves differently)
select * from sys.query_context_settings;


-- Shows execution plans used by queries
-- (a plan = how SQL Server decides to run a query)
select * from sys.query_store_plan;


-- Shows list of queries stored in Query Store
-- (each query gets an internal ID here)
select * from sys.query_store_query;


-- Shows the actual SQL text (the real query you wrote)
-- (because sys.query_store_query only has IDs, not full text)
select * from sys.query_store_query_text;


-- Shows performance stats for queries
-- (like CPU time, duration, reads, executions)
select * from sys.query_store_runtime_stats;


-- Shows time intervals for the stats
-- (breaks performance data into time windows like hourly)
select * from sys.query_store_runtime_stats_interval;


/*

Think of Query Store like a performance tracking system:
		query_store_query_text →  What was the query?
		query_store_query →  Query ID
		query_store_plan →  How SQL ran it
		runtime_stats →  How fast/slow it was
		runtime_stats_interval →When it ran
		context_settings →  Environment/settings
		database_query_store_options → Configuration

*/



```

## Summary
Query Store is a tracker for your SQL queries. It keeps a record of how queries run, shows which ones are slow, and helps you understand what’s happening behind the scenes. With this information, you can quickly find problems and fix performance issues without guessing.

## Google Drive
[Google Drive Notes : Query Store]([https://docs.google.com/document/d/11Hq9WW8hcnbiI5aux144dF5ZbOWwO6shx2ptFRVTE0g/edit?tab=t.0](https://docs.google.com/document/d/16Z4kZ0FCqOSNa6MKwYqgyiqHj5PCLkQDM82DjyDiJkQ/edit?tab=t.0))






