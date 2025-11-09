
<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=Capture&#160Login;" />
</p>




# SQL Server Login Capture by Audit
We will be capturing who login to SQL server. This audit wont capture anything else other than Logins.
---

Step 1: Run this query to generate the SQL audit. 

```sql
USE [master]

CREATE SERVER AUDIT [your_Login_Audit_name]
TO FILE (
    FILEPATH = 'D:\Audit\',                -- Folder where audit files will be stored
    MAXSIZE = 1 GB,                        -- Each file is 1 GB and this is where we define it
    MAX_ROLLOVER_FILES = 3,                -- Keep only the latest 3 files (~3 GB total), so lets say if those 3 files fill up
	                                                           --, the oldest audit file will be erase and resatrt to add the new audit, so it goes to 2nd , 3rd and so on
    RESERVE_DISK_SPACE = OFF                -- Pre-allocates space for better performance but we turn it off for now.
)
WITH (
    QUEUE_DELAY = 1000,                    -- 1-second buffer to lower overhead
    ON_FAILURE = CONTINUE                  -- if something happends to audit, we still want to run sql without any issue
);
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


## Summary

- **WITH NORECOVERY**: Keeps the database in restoring mode. Allows more backups (like differential or log) to be restored.Use this for all restores before the final one.
- **WITH RECOVERY**:Brings the database online and ready to use. No more backups can be restored after this. Use this for the last restore step.

`RECOVERY → Finish and bring online` <br>
`NORECOVERY → Keep restoring`

First, restore the full backup and keep it in restoring mode - WITH NORECOVERY.
Next, restore the differential backup if you have one - WITH NORECOVERY.
Finally, restore the log backup and use WITH RECOVERY to make the database ready to use.


## Google Drive
[Google Drive Notes : Restore](https://docs.google.com/document/d/1pNMo2O8gcfVnmWUz7CUNayFCvlc6lQzvt-mkI7haPbM/edit?tab=t.0)







