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
`SQL Server Instance → Properties → Security → Server Authentication → SQL Server and Windows Authentication mode`
`⚠️ this requires SQL server restart to change the authentication mode.`

## Create Login with least privilage.

The following scirpt will generate a login with no permission, this login wont be able to do anything in the database, unless we grant any other permission, like sysadmin or anything.

```sql
USE [master]

CREATE LOGIN YourLogin
WITH PASSWORD = '123', CHECK_POLICY = OFF;

```
