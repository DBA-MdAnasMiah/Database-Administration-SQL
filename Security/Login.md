<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?size=22&duration=4000&color=00C7B7&center=true&vCenter=true&width=650&lines=SQL&#160Login;" />
</p>

# SQL Server Login Scripts


## To create login

The following Script will create SQL login with higest Privilage in the SQL instance.

```sql
USE [master]

CREATE LOGIN [Anas] WITH PASSWORD=N'123', DEFAULT_DATABASE=[master], 
CHECK_EXPIRATION=OFF, 
CHECK_POLICY=OFF

GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [Anas]
GO

```

**To create SQL Login graphically:**  
`SQL Server Instance → Security → Login → New Login` (right clicking Logins folder) → `General -> Login name:` AnasLogin, click on SQL `Server Authentication`, provide the password and click on `sysadmin` on the `Server Roles -> ok` <br>

### Options:
- **CHECK_EXPIRATION=OFF**: this allow the login to be never expire.  
- **CHECK_POLICY=OFF**: this allow to SQL login to ignores Windows password rules, also allows us to put easy password. 
---


**Notes:**
-

> **Note:**  
>  Using a Login a system/application or persion can login to the SQL instance.
>  To allow both Windows and SQL logins to connect, ensure the server is set to **Mixed Authentication Mode**.

**To change the Authentication Mode:**  
`SQL Server Instance → Properties → Security → Server Authentication → SQL Server and Windows Authentication mode` <br>
`⚠️ this requires SQL server restart to change the authentication mode.`

## To Create Login with least privilage.

The following scirpt will generate a login with no permission, this login wont be able to do anything in the database, unless we grant any other permission, like sysadmin or anything.

```sql
USE [master]

CREATE LOGIN YourLogin
WITH PASSWORD = '123', CHECK_POLICY = OFF;

```

## To drop a SQL Login

```sql
USE [master]
DROP LOGIN [test_user]

```
> **Note:**  
>  This will drop the SQL login from the instance Completely.


> **Extra Notes:**  
Sometimes SQL logins doesnt want to get deleted for the few reason that I have listed.
<br>`- The SQL login has a user inside one or more databases.`
<br>`- The SQL login is the owner of a database.`
<br>`- The SQL login owns a schema.`
<br>`- The SQL login is still connected or has active sessions.`
<br>`- The SQL login owns a SQL Agent job.`
<br>`- The SQL login owns a SQL Agent proxy or credential.`
<br>`- The SQL login owns a server object like an endpoint.`
<br>`- The SQL login is used by replication or an application service.`
<br>`- The SQL login is still part of a server or database role.`
<br>`- The SQL login belongs to a contained database user <br>
Remove the connection of the SQL login before dropping it`

**To drop/delete SQL Login graphically:**  
`SQL Server Instance → **Security → Login** → Anas_login` (right clicking) → `Delete -> ok` 

