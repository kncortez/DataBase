/*
Script ALTER SettlementByPickupDetail
ALTER PARA AGREGAR campos para liquidación de rutas recolectora COD
*/
​
ALTER TABLE [dbo].[SettlementByPickupDetail]
ADD IsCODSettlement INT NULL;

ALTER TABLE [dbo].[SettlementByPickupDetail]
ADD CODSettlement_TokenCreated NVARCHAR(50) NULL;

ALTER TABLE [dbo].[SettlementByPickupDetail]
ADD CODSettlement_DateCreated DATETIME NULL;
