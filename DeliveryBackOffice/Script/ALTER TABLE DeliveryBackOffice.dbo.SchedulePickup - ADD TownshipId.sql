USE [DeliveryBackOffice]
GO
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-04-20>
-- Description:	<Nuevo campo en la tabla SchedulePickup para agregar el idTownship>

ALTER TABLE DeliveryBackOffice.dbo.SchedulePickup add TownshipId int