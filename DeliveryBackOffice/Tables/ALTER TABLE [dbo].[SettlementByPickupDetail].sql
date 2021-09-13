/*
Script ALTER SettlementByPickupDetail
ALTER PARA AGREGAR IsCODSettlement para liquidación de rutas recolectora COD
*/
​
ALTER TABLE [dbo].[SettlementByPickupDetail]
ADD IsCODSettlement INT NULL;

