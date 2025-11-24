
<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=Retrive&nbsp;Database/Table;" />
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


## Google Drive
[Google Drive Notes : xyz](https:linkgoeshere)







