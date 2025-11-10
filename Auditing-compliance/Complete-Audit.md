

<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=Capture&#160Database&#160Modification;" />
</p>




# SQL Server Login Capture by Audit
We will be capturing who login to SQL server. This audit wont capture anything else other than Logins.
---

Step 1: Run this query to generate the SQL audit. 

```sql
USE [master]

CREATE SERVER AUDIT [your_Login_Audit_name]
TO FILE (
    FILEPATH = 'D:\Audit\',                -- Folder/location where audit files will be stored
    MAXSIZE = 1 GB,                        -- each file is 1 GB and this is where we define it
    MAX_ROLLOVER_FILES = 3,                -- keep only the latest 3 files (~3 GB total), so lets say if those 3 files fill up
                                           --, the oldest audit file will be truncate/erase and resatrt to add the new audit,
                                           -- so it goes to 2nd , 3rd and so on
    RESERVE_DISK_SPACE = OFF                -- Pre-allocates space for better performance but we turn it off for now.
)



WITH (
    QUEUE_DELAY = 1000,                    -- 1-second buffer to lower overhead
    ON_FAILURE = CONTINUE                  -- if something happends to audit, we still want to run sql without any issue
)

WHERE server_principal_name <> 'Your_app_login'; /* this exclude any app_login as they will be have constant logged in to the server
                                                    for the backend activity like customer activity and all but if you want to also
                                                    inlcude it then just simply removed the entire where condition line. */
GO

```

> **Note:**   <br>
> - In order for us to create auditing in SQL, we must create the audit and step 1 does the work <br>
> - step 2 will generate the audit specs which mean what we want to capture, in our case we will be capturng the SQL login, basically who logged in and out to server. <br>
> - In step 3 we will be enabling the audit and specs in order for it to run it.<br>
> - step 4, we will query out the audit.

> **Extra Notes:** <br>
> - It starts with file #1 (1 GB). <br>
> - When that fills up, it makes file #2, then file #3. <br>
> - When it reaches file #3 and needs to make file #4, it deletes the oldest one (file #1) and reuses that space.


Step 2: Let's now create the audit specification(specs) for the audit we created, so run it.

```sql
USE [master]

CREATE SERVER AUDIT SPECIFICATION [Login_Audit_Spec]
FOR SERVER AUDIT [your_Login_Audit_name]
ADD (SUCCESSFUL_LOGIN_GROUP),   -- Records successful logins
ADD (FAILED_LOGIN_GROUP),       -- Records failed login attempts
ADD (LOGOUT_GROUP)              -- Records logouts
WITH (STATE = OFF);             -- Turned off until audit is enabled, which we will enable after creating this.
GO

```

> **Note:**   <br>
> - This will only allow is to capture login <br>
> - ADD (SUCCESSFUL_LOGIN_GROUP) capture the successful logins list <br>
> - ADD (FAILED_LOGIN_GROUP) capture those login who attempted to get in but failed.<br>
> - ADD (LOGOUT_GROUP) , capture logout logins
> - WITH (STATE = OFF), this just turn of the specification off before we can enable the audit.



Step 3: This will enable the audit and it's specs so execute it.

```sql

USE [master]
ALTER SERVER AUDIT [your_Login_Audit_name] WITH (STATE = ON);                -- Start writing audit files
ALTER SERVER AUDIT SPECIFICATION [Login_Audit_Spec] WITH (STATE = ON);       -- Start capturing events
GO


```

> **Note:**   <br>
> - this requires in order for us to run the audit <br>



Step 4: check if they are enabled or not by the running this step.
```sql

SELECT
    name,
    audit_file_path,
    status_desc,         -- Shows whether audit is started or stopped
    is_state_enabled = CASE WHEN status = 1 THEN 'ON' ELSE 'OFF' END
FROM sys.dm_server_audit_status;
GO


```


Step 5: We will check what it captures by the following query

```sql

SELECT TOP (10)
    event_time,
    server_principal_name,   -- Who logged in/out
    client_ip,
    action_id,               -- LGIS=Login success, LGIF=Login failed, LOGO=Logout
    succeeded,
    session_id
FROM sys.fn_get_audit_file('D:\Audit\*.sqlaudit', DEFAULT, DEFAULT)
ORDER BY event_time DESC;
GO

```


we can also graphically see the audit log event
security -> Audit -> View Audit Logs



## Summary
This setup creates a SQL Server audit that records who logs in, fails to log in, and logs out.
It saves the audit data into 3 files, each 1 GB in size.
When the third file fills up, SQL Server automatically deletes (overwrites) the oldest file and starts a new one.
This keeps the audit small, clean, and always shows the latest 3 GB of login history without filling up the disk.

## Google Drive
[Google Drive Notes : Audit](https://docs.google.com/document/d/1F9vcGpvaGicK3ZLIcwkm-B0L5r0uAmskWXILgC2bRIs/edit?tab=t.0)







