
<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=Extended&nbsp;Event;" />
</p>




# Lets setup an Extended Event 
 - it will capture any query that runs more than 30 second and store to a table.

---

## Step 1: create the extended event

First we will create the extended Event and enable it.  

```sql

USE master;
GO

CREATE EVENT SESSION [capture30LongQuery] ON SERVER

ADD EVENT sqlserver.rpc_completed      /*👉 Watch stored procedures that take too long*/
(
    ACTION
    (
        sqlserver.client_app_name,                       /*👉 What app ran the query (SSMS, .NET app, etc.) */
        sqlserver.client_hostname,                      /*👉 What computer sent the query  */
        sqlserver.database_id,                         /*👉 Database number  */
        sqlserver.database_name,                      /*👉  Database name   */
        sqlserver.plan_handle,                       /* With this number, you can later open the execution plan */
        sqlserver.server_principal_name,            /*👉 Login name */
        sqlserver.session_nt_username,             /*👉Windows username */
        sqlserver.session_id,                     /*👉 Session number (ticket number) */
        sqlserver.username,                      /*👉 SQL username */
        sqlserver.sql_text                      /*👉 The exact SQL text that ran */
    )
    WHERE
    (
        duration > 30000000              /*👉 Only capture if > 30 seconds */
        AND NOT sqlserver.like_i_sql_unicode_string(sqlserver.sql_text, N'%backup%')
                                         /*👉 dont capture backup commands */
    )
),

ADD EVENT sqlserver.sql_batch_completed
(
    ACTION
    (
        sqlserver.client_app_name,                     /*👉 App running the query */
        sqlserver.client_hostname,                    /*👉 Computer name */
        sqlserver.database_id,                       /*👉 Database ID */
        sqlserver.database_name,                    /*👉 Database name */
        sqlserver.plan_handle,                     /*👉 A special ID that lets you open the execution plan later.*/
        sqlserver.server_principal_name,          /*👉Login name */
        sqlserver.session_nt_username,           /*👉 Windows username */
        sqlserver.session_id,                   /*👉 Session number */
        sqlserver.username,                    /*👉SQL user */
        sqlserver.sql_text                    /*👉 The SQL text developer or process = ran */
    )
    WHERE
    (
        duration > 30000000              /*👉 Only record any query running over 30 */
        AND NOT sqlserver.like_i_sql_unicode_string(sqlserver.sql_text, N'%backup%')
                                         /*👉  Skip backup commands */
    )
)


ADD TARGET  package0.event_file
(
    SET
        filename = N'\\ANAS_PC\anas\extendedEvent\capture30LongQuery.xel',   /*👉 location where to save the extended event file, makesure put SQL SA account permission to this folder */
        max_file_size = (10),                                               /*👉 Each file can grow to 10 MB */
        max_rollover_files = 3                                             /*👉 Keep 3 files max then rolls over */
)

WITH
(
    MAX_MEMORY = 4096 KB,                             /*👉 Memory use by the XE session */
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,  /*👉 If SQL Server is super busy, it’s okay to drop a tiny number of events so the server doesn’t slow down */
    MAX_DISPATCH_LATENCY = 60 SECONDS,              /* 👉 server waits 60 second before writting those logs to data file */
    MAX_EVENT_SIZE = 0 KB,                         /* 👉 Setting 0 means, we let sql manage it so it doesnt break */
    MEMORY_PARTITION_MODE = NONE,                 /*👉 Do NOT divide the XE memory */
    TRACK_CAUSALITY = OFF,                       /* 👉 We are NOT linking events together */
    STARTUP_STATE = ON                          /* 👉 If the SQL Server restarts, it automatically start*/
);
GO



```

### Options:
- **MAX_MEMORY**: Memory use by the XE session.  
- **EVENT_RETENTION_MODE**: If SQL Server is super busy, it’s okay to drop a tiny number of events so the server doesn’t slow down.  
- **MAX_DISPATCH_LATENCY**: server waits time before writting those logs to data file.  
- **MEMORY_PARTITION_MODEP**: Do NOT divide the XE memory.  
- **TRACK_CAUSALITY**: We are NOT linking events together.
- ** STARTUP_STATE**: If the SQL Server restarts, it automatically start.
> This extended event file will be created in the following path -> N'\\ANAS_PC\anas\extendedEvent\capture30LongQuery.xel'

---

## Step 2: Now run/enable the Extended Event that we generated.
```sql
USE MASTER;
GO;
ALTER EVENT SESSION [capture30LongQuery] ON SERVER STATE = START;
```
> to check the Extended Event -> Server(Anas_PC\DATACENTER) -> Management -> Extended Events -> capture30LongQuery -> package0.event_file -> View Target Data

## Step 3: Create a table in DBA databse.

the purpose of this table is that we want to store any information from our extended event that we generated.

```sql

Create database DBA    /* 👉only create dba database if you dont have it but you can 
                                          use any database, it doesnt have to be DBA database */
USE DBA
GO

CREATE TABLE DBA.dbo.Capture30SecondsLongQueriesTable 

   (logID INT IDENTITY (1,1) PRIMARY KEY,
	EventName nvarchar(50) not null,
	DurationSeconds float not null,
	Sqltext nvarchar(max) null,
	ClientAppName nvarchar(128) null,
	ClientHostName nvarchar (128) null,
	DatabaseName nvarchar(128) null,
	LoginName nvarchar(128) null,
	EventTime datetime not null )


```
**Notes:**
> Note: we will create store proc on step 5 that will transfer our extended event data to our table(Capture30SecondsLongQueriesTable).  


---


## Step 4: Check the path where we created the store proc

This script out the output for all database backup excluding 4 system databases

```sql

/* ===============   Step 4: check wherethe extended event file saved ============ */

USE MASTER
SELECT
	CAST(T.target_data as XML).value('(EventFileTarget/File/@name)[1]', 'nvarchar(260)') AS XEventFilePath
FROM sys.dm_xe_sessions As S
join sys.dm_xe_session_targets as T
on S.address = T.event_session_address
where S.name = 'capture30LongQuery'   /* 👉 our extended event's name */


```


##  Step 5: Create the store proc that will be resposnbible to tranfering data to table(Capture30SecondsLongQueriesTable). 

Once we create this store proc, we can schedule it to run every 5 mins so data from extended file will be saved on our table.

```sql

USE DBA
GO

CREATE PROCEDURE LOADXeventTOTABLE
AS
BEGIN

Declare  @LastEventTime datetime;
select @LastEventTime = ISNULL(max(EventTime), '2025-01-01')
from DBA.dbo.Capture30SecondsLongQueriesTable 

INSERT INTO DBA.dbo.Capture30SecondsLongQueriesTable 
(
    EventName,
    DurationSeconds,
    Sqltext,
    ClientAppName,
    ClientHostName,
    DatabaseName,
    LoginName,
    EventTime
)
SELECT
    event_data.value('(/event/@name)[1]', 'nvarchar(50)') AS EventName,
    event_data.value('(/event/data[@name="duration"]/value)[1]', 'float') / 1000000.0 AS DurationSeconds,
    event_data.value('(/event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS SqlText,
    event_data.value('(/event/action[@name="client_app_name"]/value)[1]', 'nvarchar(128)') AS ClientAppName,
    event_data.value('(/event/action[@name="client_hostname"]/value)[1]', 'nvarchar(128)') AS ClientHostName,
    event_data.value('(/event/action[@name="database_name"]/value)[1]', 'nvarchar(128)') AS DatabaseName,
    event_data.value('(/event/action[@name="server_principal_name"]/value)[1]', 'nvarchar(128)') AS LoginName,
    event_data.value('(/event/@timestamp)[1]', 'datetime') AS EventTime
FROM (
	select convert (XML, event_data) as event_data
	from sys.fn_xe_file_target_read_file
		   ( '\\ANAS_PC\anas\extendedEvent\capture30LongQuery*.xel',  /*👉 make sure to update the path with * */
			NULL,    NULL,      NULL )) as X
			where event_data.value ('(event/@timestamp)[1]',  'datetime') > @LastEventTime;
END


```
**Notes:**
-> Note: make sure to put the extended event file name here and also put * after the name so it dinamically capture other extended file as fills up.  



##  Step 6: Create the SQl job that runs every 5 mins for the procedure we created earlier.

this will run to upload extended event files to the table in every 5 mins

**Notes:**
> in the SQL job step, schedule the following store proc(LOADXeventTOTABLE) under DBA database to run every 5 mins interval.
- exec [dbo].[LOADXeventTOTABLE];

##  Step 7: now we need to create another store proc to remove 7 days older data from our table or else it will grow enormously. 

```sql
USE DBA
GO
CREATE PROCEDURE sp_delete7DaysOldData
AS BEGIN
delete from  DBA.dbo.Capture30SecondsLongQueriesTable 
where EventTime < dateadd(day, -7, getdate());
end

```

##  Step 9: create another sql job that runs this store proc(sp_delete7DaysOldData) 1 time every weeek
**Notes:**
> in the SQL job step, schedule the following store proc(sp_delete7DaysOldData) under DBA database to run 1 time every wweek, lets schedule it on saturday.
- exec [dbo].[sp_delete7DaysOldData];



## Summary

- We created an extended event that captures any long running query(30 seconds) that stores that information into a table and 7 days older data gets removed from those tables in a timely manner. <br>
In this way we can capture any long query and do query tuning as needed for those long running query.


## Google Drive
[Google Drive Notes : Extended Event Setup](https://docs.google.com/document/d/1FgF6hGR9dHWr_fG2SxMHb6jtwO9LCM1MW6szVg-wcX8/edit?tab=t.0)






