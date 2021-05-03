USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.CatTypeRate
   (IdTypeRate int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	Name varchar(100) NOT NULL,
	Description varchar(50)  NULL,
	RowStatus bit NOT NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL)
GO  

insert into DeliveryBackOffice.dbo.CatTypeRate  
	(Name
	,Description
	,RowStatus
	,TokenCreated
	,DateCreated)
Values('Estándar por canal ','Tarifas estándar',0,'SYS-CAQUINO',GETDATE())
,('Todo Destino','Tarifas todo destino',1,'SYS-CAQUINO',GETDATE())
,('Tipo de Artículo','Tarifas  con base a codigo de articulos',0,'SYS-CAQUINO',GETDATE())
,('Sevicios Especiales','Tarifas de servicios Especiales',0,'SYS-CAQUINO',GETDATE())

select * from DeliveryBackOffice.dbo.CatTypeRate  