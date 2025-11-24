
<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=Database&nbsp;Query;" />
</p>




# In this page we will use query to retrive information details about database

---

## To use a specific database
we simple use the word 'USE'.

```sql
USE [DBA] --> place your own database here, in our case we are using the DBA database
```

# To check how many tables are in your database

```sql
use AdventureWorks2019 --> your database name goes here
select * from INFORMATION_SCHEMA.tables  /* information_schema has all the table 
                                            information/built-in system view that lists all tables in the database. */
where TABLE_TYPE = 'Base table' --> The 'Base table' return only real physical tables, not views.
```


```sql
SELECT 
  st.name,                                               --  Table name (from sys.tables)
  ss.name                                                --  Schema name (from sys.schemas)
FROM sys.tables AS st                            --  List of all user tables in the database
JOIN sys.schemas AS ss                         --  List of all schemas (dbo, Sales, Person, etc.)
    ON st.schema_id = ss.schema_id     --  Match each table to its correct schema
```

### To count the tables

```sql
SELECT 
count(*)                                       -- this return the count of the table          
FROM sys.tables AS st                            
JOIN sys.schemas AS ss                       
    ON st.schema_id = ss.schema_id    
```


**Notes:**
- must have fullbackup earlier
- Essential for point-in-time recovery.
- Need to have 'with recovery' to bring back database online

---


## To restore differential backup 

to restore differencial backup, we need to have the database in restoring state earlier.

```sql

RESTORE DATABASE [Datawarehouse]
FROM DISK = N'D:\backup\datawarehouse_diff.bak' -- must have accurate path
WITH RECOVERY,
STATS = 10;

```


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







