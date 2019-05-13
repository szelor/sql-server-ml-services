/*
The database can be downloaded here:

https://sqlchoice.blob.core.windows.net/sqlchoice/static/tpcxbb_1gb.bak

*/



USE master;
GO
RESTORE DATABASE tpcxbb_1gb
   FROM DISK = 'C:\Temp\tpcxbb_1gb.bak'
   WITH
                MOVE 'tpcxbb_1gb' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\tpcxbb_1gb.mdf'
                ,MOVE 'tpcxbb_1gb_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\tpcxbb_1gb.ldf';
GO
use [tpcxbb_1gb]
go
select top 10 * from [dbo].[store]
go
