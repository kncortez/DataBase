USE [DeliveryBackOffice]
GO

-- =============================================
-- Author:		<Abner,Juárez>
-- Create date: <2021-04-08>
-- Description:	<Actualización de campos para modificar el tamaño de la dirección>
-- =============================================

ALTER TABLE DeliveryBackOffice.dbo.VisitPointClient ALTER COLUMN Address nvarchar(600)

ALTER TABLE DeliveryBackOffice.dbo.UserAddress ALTER COLUMN UadAddress1 nvarchar(600)