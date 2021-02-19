-----------------/////////////////////// Tabla para el tipo de incidencia ///////////////////////////////////
CREATE TABLE DeliveryBackOffice.dbo.CatTypeIncidence
(IdIncidenceType int IDENTITY (1,1) PRIMARY KEY NOT NULL,
NameIncidence varchar (200) null,
DescriptionIncidence varchar(200) null,
RowStatus bit not NULL,
TokenCreated varchar(50)  NOT NULL,
DateCreated datetime  NOT NULL,
TokenUpdated varchar(50)   NULL,
DateUpdated datetime   NULL)
GO

INSERT INTO DeliveryBackOffice.dbo.CatTypeIncidence 
(NameIncidence
,RowStatus
,TokenCreated 
,DateCreated )

VALUES
('No hay nadie en casa',1,'SYS-CAQUINO',GETDATE())
,('Dirección errónea',1,'SYS-CAQUINO',GETDATE())
,('Cliente no vive en la dirección',1,'SYS-CAQUINO',GETDATE())
,('Cliente no dejó documento a la persona que recibe el paquete',1,'SYS-CAQUINO',GETDATE())
,('Servicio fuera de ruta',1,'SYS-CAQUINO',GETDATE())

select * from dbo.CatTypeIncidence