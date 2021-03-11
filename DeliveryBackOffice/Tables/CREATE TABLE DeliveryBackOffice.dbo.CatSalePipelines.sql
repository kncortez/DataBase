USE [DeliveryBackOffice]
GO
 
CREATE TABLE DeliveryBackOffice.dbo.CatSalePipelines  
   (IdSalePipeLine int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	Name varchar(50) NOT NULL,
	ShortName varchar(10) not null,
	Description varchar(100)  NULL,
	RowStatus bit NOT NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL)
GO  

insert into DeliveryBackOffice.dbo.CatSalePipelines  
	(Name
	,ShortName
	,Description
	,RowStatus
	,TokenCreated
	,DateCreated)
Values('Autoventa','ATV', 'Autoventa',0,'SYS-CAQUINO',GETDATE())
,('Telemarketing','TMK', 'Telemarketing',0,'SYS-CAQUINO',GETDATE())
,('Express Center','EXP', 'Express Center',1,'SYS-CAQUINO',GETDATE())
,('Ejecutivo','EJC', 'Ejecutivo',0,'SYS-CAQUINO',GETDATE())
,('Pagina Web','WEB', 'Portal Web',1,'SYS-CAQUINO',GETDATE())


select * from DeliveryBackOffice.dbo.CatSalePipelines  