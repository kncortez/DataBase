USE [DeliveryBackOffice]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Abner, Juárez>
-- Create date: <2021-05-03>
-- Description:	<Inserción de los catalogos de la tablas CatTransportationZone y TransactionType>
-- =============================================

INSERT INTO DeliveryBackOffice.dbo.CatTransportationZone
	(Name,Description,RowStatus,TokenCreated,DateCreated) VALUES
	('Ruta de recolección','Ruta para la recolección de paquetes',1,'SYS-AJUAREZ',GETDATE())
	,('Ruta de entrega','Ruta para la entrega de paquetes',1,'SYS-AJUAREZ',GETDATE())
	,('Ruta de devolución','Ruta para la devolución de paquetes',1,'SYS-AJUAREZ',GETDATE())
	,('Bodega','Bodega de Forza Delivery',1,'SYS-AJUAREZ',GETDATE())
	,('Line Haul','Ruta Line Haul',1,'SYS-AJUAREZ',GETDATE())

INSERT INTO DeliveryBackOffice.dbo.TransactionType
	(Name,Description,RowStatus,TokenCreated,DateCreated) VALUES
	('Liquidación de Recolección','Liquidación de las rutas de recolección',1,'SYS-AJUAREZ',GETDATE())
	,('Liquidación de Entrega','Liquidación de las rutas de entrega',1,'SYS-AJUAREZ',GETDATE())
	,('Liquidación de Devolución','Liquidación de las rutas de devolución',1,'SYS-AJUAREZ',GETDATE())
	,('Liquidación de Line Haul','Liquidación de Line Haul',1,'SYS-AJUAREZ',GETDATE())