
USE [DeliveryBackOffice]
GO


CREATE TABLE DeliveryBackOffice.dbo.CatServiceStatus
   (IdServiceStatus int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	Name nvarchar(100)  NULL,
	Description varchar(100) null,
	RowStatus bit  NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL)
GO 



Insert into CatServiceStatus (Name,RowStatus,TokenCreated,DateCreated)
Values
('Creado',1,'SYS-CAQUINO', GETDATE())
,('Asignado a Ruta',1,'SYS-CAQUINO', GETDATE())
,('Recolectado',1,'SYS-CAQUINO', GETDATE())
,('Incidencia',1,'SYS-CAQUINO', GETDATE())
,('Entregado ',1,'SYS-CAQUINO', GETDATE())
,('Recibido en Express Center',1,'SYS-CAQUINO', GETDATE())

select * from dbo.CatServiceStatus