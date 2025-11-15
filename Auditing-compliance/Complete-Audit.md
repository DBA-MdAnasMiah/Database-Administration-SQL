

<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=Capture&#160Database&#160;Modification;" />
</p>




# Capture Database Modification,
We will be capturing the listed thing down below.
> - Who(Login) access/logged in to the server <br>
> - Who deleted Datbase, table, store proc, etc. <br>
> - Who updated, deleted, inserted data in to the database table<br>

---

Step 1: we need to create a server audit first, the following sql create the audit and enable it.

```sql
USE MASTER
CREATE SERVER AUDIT my_server_Audit
TO FILE (
   FILEPATH = 'D:\Audit\',                 -- put the path where you want to save your audit file.
    MAXSIZE = 1 GB,                        -- each file is 1 GB and this is where we define it
    MAX_ROLLOVER_FILES =3, -- it will be creating 1gb storage all together then rollback to oldest one and start to write the log to the old one.
	RESERVE_DISK_SPACE = OFF   
)
WITH (
    QUEUE_DELAY = 1000,         -- flush every 1 second
    ON_FAILURE = CONTINUE      -- keep running even if audit fails
 
)
 WHERE server_principal_name <> 'app';  -- exclude this login , if you want to exclude any login like app login or something that are very busy
                                        -- and we dont need to capture their activty as they will have constant login activity, then we can simple exclude it here.

-- Enable the audit
ALTER SERVER AUDIT my_server_Audit WITH (STATE = ON);
GO


```

> **Note:**   <br>
> - we are excluding the app login because it will be connected to the application site and generate alot of login attempts. <br>
> - in you want to just do audit for only specific user then in where condition we need to put like 'WHERE server_principal_name = 'AnasLogin';'
> - also note, we need to create the server audit on Master database.
> - sometimes, audit doesnt work so install appropriate hotfixes

Step 2: We need to create audit specification for the audit we created so lets name is my_Server_Audit_specs, you can name anything you like. 

```sql
USE master
GO
CREATE SERVER AUDIT SPECIFICATION my_Server_Audit_specs
FOR SERVER AUDIT my_server_Audit
    ADD (SUCCESSFUL_LOGIN_GROUP), -- this captures the login
    ADD (LOGOUT_GROUP), -- capture the logout
    ADD (DATABASE_CHANGE_GROUP); -- this capture  CREATE/ALTER/DROP DATABASE
GO

ALTER SERVER AUDIT SPECIFICATION  my_Server_Audit_specs WITH (STATE = ON);
GO


```

> **Note:**   <br>
> - ADD (SUCCESSFUL_LOGIN_GROUP), -- this captures the login <br>
> - ADD (SUCCESSFUL_LOGIN_GROUP) capture the successful logins list <br>
> - ADD (LOGOUT_GROUP), -- capture the logout. <br>
> - ADD (DATABASE_CHANGE_GROUP); -- this capture  CREATE/ALTER/DROP DATABASE.


Step 3: Apply the audit to one specific database, in our case lets choose AdventureWorks database, so run the following script down below.

```sql

USE [Adventureworks]
GO
Create DATABASE AUDIT SPECIFICATION my_DB_Audit -- give your database audit name
FOR SERVER AUDIT my_server_Audit -- include server audit name here
	add (SCHEMA_OBJECT_CHANGE_GROUP), -- captures CREATE/ALTER/DROP of tables, views, procs, etc.
    ADD (INSERT ON DATABASE::AdventureWorks BY PUBLIC),  -- capture inserts into any table
    ADD (UPDATE ON DATABASE::AdventureWorks BY PUBLIC),  -- capture updates on any table
    ADD (DELETE ON DATABASE::AdventureWorks BY PUBLIC);  -- capture deletes on any table
GO

ALTER DATABASE AUDIT SPECIFICATION my_DB_Audit WITH (STATE = ON); -- this enable the specs
GO


```

> **Note:**   <br>
> - add (SCHEMA_OBJECT_CHANGE_GROUP), -- captures CREATE/ALTER/DROP of tables, views, procs, etc. <br>
> - ADD (INSERT ON DATABASE::AdventureWorks BY PUBLIC),  -- capture inserts into any table
> - ADD (UPDATE ON DATABASE::AdventureWorks BY PUBLIC),  -- capture updates on any table
> - ADD (DELETE ON DATABASE::AdventureWorks BY PUBLIC);  -- capture deletes on any table
> - makesure to chnage the database name based upon your database name.


Step 4: now query out the server audit to check who deleted a database or table.
```sql

--- check who dropped database 
SELECT event_time, server_principal_name, database_name, schema_name, object_name, statement
FROM sys.fn_get_audit_file('D:\Audit\*.sqlaudit', DEFAULT, DEFAULT)
WHERE statement LIKE 'DROP Database %'
ORDER BY event_time DESC;


--- check who dropped table 
SELECT event_time, server_principal_name, database_name, schema_name, object_name, statement
FROM sys.fn_get_audit_file('D:\Audit\*.sqlaudit', DEFAULT, DEFAULT)
WHERE statement LIKE 'DROP TABLE %'
ORDER BY event_time DESC;



```

we can also view graphically see the audit log event
security -> Audit -> View Audit Logs



## Summary
This setup creates a SQL Server audit that records who logs in, fails to log in, and logs out, Who created database/table, drop database/table etc.
It saves the audit data into 3 files, each 1 GB in size.
When the third file fills up, SQL Server automatically deletes (overwrites) the oldest file and starts a new one.
This keeps the audit small, clean, and always shows the latest 3 GB of login history without filling up the disk.

## Google Drive
[Google Drive Notes : Audit - CapturingEverything](https://docs.google.com/document/d/1yAmW_-dvr1cFHdyi8z55WWV5s2DJTTxcKrM22euKpoM/edit?tab=t.0)







