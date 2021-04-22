USE [DeliveryBackOffice]
GO
-- =============================================
-- Author:		<Abner,Juárez>
-- Create date: <2021-04-06>
-- Description:	<Registro de opciones de entrega>
-- =============================================

INSERT INTO DeliveryBackOffice.dbo.CatDeliveryOptions (Name,Description,RowStatus,TokenCreated,DateCreated)
VALUES ('Casa','Opción de entrega casa',1,'SYS-AJUAREZ',GETDATE())

INSERT INTO DeliveryBackOffice.dbo.CatDeliveryOptions (Name,Description,RowStatus,TokenCreated,DateCreated)
VALUES ('Oficina','Opción de entrega oficina',1,'SYS-AJUAREZ',GETDATE())

INSERT INTO DeliveryBackOffice.dbo.CatDeliveryOptions (Name,Description,RowStatus,TokenCreated,DateCreated)
VALUES ('Express Center','Opción de entrega Express Center',1,'SYS-AJUAREZ',GETDATE())

INSERT INTO DeliveryBackOffice.dbo.CatDeliveryOptions (Name,Description,RowStatus,TokenCreated,DateCreated)
VALUES ('Smart Locker','Opción de entrega Smart Locker',1,'SYS-AJUAREZ',GETDATE())