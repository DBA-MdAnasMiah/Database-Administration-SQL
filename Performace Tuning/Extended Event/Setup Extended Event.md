
<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=Extended&nbsp;Event;" />
</p>




# Lets Setup an Extended Event (it will capture any query that runs more than 30 second and store to a table).

---

## Step 1: lets create the extended event

First we will create the extended Event and enable it.  

```sql

USE master;
GO

CREATE EVENT SESSION [capture30LongQuery] ON SERVER

ADD EVENT sqlserver.rpc_completed      /*👉 Watch stored procedures that take too long*/
(
    ACTION
    (
        sqlserver.client_app_name,                   /*👉 What app ran the query (SSMS, .NET app, etc.) */
        sqlserver.client_hostname,                   /*👉 What computer sent the query  */
        sqlserver.database_id,                        /*👉 Database number  */
        sqlserver.database_name,               /*👉  Database name   */
        sqlserver.plan_handle,                     /* With this number, you can later open the execution plan */
        sqlserver.server_principal_name,  /*👉 Login name */
        sqlserver.session_nt_username,   /*👉Windows username */
        sqlserver.session_id,                    /*👉 Session number (ticket number) */
        sqlserver.username,                 /*👉 SQL username */
        sqlserver.sql_text                    /*👉 The exact SQL text that ran */
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
        sqlserver.client_app_name,                  /*👉 App running the query */
        sqlserver.client_hostname,                  /*👉 Computer name */
        sqlserver.database_id,                       /*👉 Database ID */
        sqlserver.database_name,              /*👉 Database name */
        sqlserver.plan_handle,                    /*👉 A special ID that lets you open the execution plan later.*/
        sqlserver.server_principal_name, /*👉Login name */
        sqlserver.session_nt_username,  /*👉 Windows username */
        sqlserver.session_id,                   /*👉 Session number */
        sqlserver.username,                /*👉SQL user */
        sqlserver.sql_text                   /*👉 The SQL text developer or process = ran */
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
        max_rollover_files = 3                                           /*👉 Keep 3 files max then rolls over */
)

WITH
(
    MAX_MEMORY = 4096 KB,                                                        /*👉 Memory use by the XE session */
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS, /*👉 If SQL Server is super busy, it’s okay to drop a tiny number of events so the server doesn’t slow down */
    MAX_DISPATCH_LATENCY = 60 SECONDS,   /* 👉 server waits 60 second before writting those logs to data file */
    MAX_EVENT_SIZE = 0 KB,                               /* 👉 Setting 0 means, we let sql manage it so it doesnt break */
    MEMORY_PARTITION_MODE = NONE,      /*👉 Do NOT divide the XE memory */
    TRACK_CAUSALITY = OFF,                        /* 👉 We are NOT linking events together */
    STARTUP_STATE = ON                              /* 👉 If the SQL Server restarts, it automatically start*/
);
GO



```

### Options:
- **MAX_MEMORY**: Memory use by the XE session.  
- **EVENT_RETENTION_MODE**: If SQL Server is super busy, it’s okay to drop a tiny number of events so the server doesn’t slow down.  
- **MAX_DISPATCH_LATENCY**: server waits time before writting those logs to data file.  
- **MEMORY_PARTITION_MODEP**: Do NOT divide the XE memory.  
- **TRACK_CAUSALITY**: We are NOT linking events together.
- ** STARTUP_STATE**: If the SQL Server restarts, it automatically star.
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
-> Note: we will create store proc on step 5 that will transfer our extended event data to our table(Capture30SecondsLongQueriesTable).  


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
-> Note: add the following script to the job and schedule it run every 5 mins, name the job as LoadToTable and select DBA database when configuring job step ->   exec [dbo].[LOADXeventTOTABLE] 
- if dont know how to create the job then simply run the following query  down below which will generate the job script for you.


```sql

USE [msdb]
GO

/****** Object:  Job [loadToTable]    Script Date: 11/15/2025 9:53:05 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/15/2025 9:53:05 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'loadToTable', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [my step]    Script Date: 11/15/2025 9:53:06 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'my step', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [dbo].[LOADXeventTOTABLE];', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'my schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=3, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20251115, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'97eeaddf-5f25-44c2-99df-79bf53e8ca31'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO




```


##  I have created an app called 'SIMPLE/EASY backup software'

When running this, it will take backup for you.

- **Download**: [sql_connect-v5.ps1](https://github.com/DBA-MdAnasMiah/Database-Administration-SQL/blob/main/Backup/MySoftwares/sql_connect-v5.ps1)
  





## Summary

- **Full Backup**: Complete backup of a database.  
- **Transaction Log Backup**: Incremental changes; must follow full backup and captures the small chnages over time 
- **Differential Backup**: All changes since last full backup; combines multiple logs.  

💡 **Tip:** Make sure to test your backups and restores to ensure reliability.

## Google Drive
[Google Drive Notes : Backup](https://docs.google.com/document/d/11Hq9WW8hcnbiI5aux144dF5ZbOWwO6shx2ptFRVTE0g/edit?tab=t.0)






