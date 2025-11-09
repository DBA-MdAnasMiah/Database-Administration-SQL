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
