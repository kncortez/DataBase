USE [DeliveryBackOffice]

BEGIN TRAN

--AGREGAR COLUMNAS
ALTER TABLE [dbo].[BatchDetailCOD] ADD [Comments] [nvarchar](2000) NULL

--COMMIT



