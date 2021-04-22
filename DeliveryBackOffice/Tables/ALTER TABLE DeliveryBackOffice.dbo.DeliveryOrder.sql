USE [DeliveryBackOffice]
GO
-- =============================================
-- Author:		<Abner,Juárez>
-- Create date: <2021-04-06>
-- Description:	<Nuevo campo para relacionar las opciones de entrega>
-- =============================================

alter table DeliveryBackOffice.dbo.DeliveryOrder add IdDeliveryOption int

ALTER TABLE DeliveryBackOffice.dbo.DeliveryOrder
ADD FOREIGN KEY (IdDeliveryOption) REFERENCES DeliveryBackOffice.dbo.CatDeliveryOptions(IdDeliveryOption)