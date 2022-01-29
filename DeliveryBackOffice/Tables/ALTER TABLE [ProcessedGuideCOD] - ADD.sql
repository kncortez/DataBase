/*Se agrega campo para identificar la recolección*/
USE [DeliveryBackOffice]
GO

ALTER TABLE [ProcessedGuideCOD]
ADD [RecolectionBatchId] [bigint] NULL

ALTER TABLE [ProcessedGuideCOD]
ADD [CollectBatchId] [bigint] NULL


