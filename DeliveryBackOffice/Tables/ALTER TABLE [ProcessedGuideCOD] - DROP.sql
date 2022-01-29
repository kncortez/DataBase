/*Se quita para poder insertar sin problemas en Recolección y Entregas*/
USE [DeliveryBackOffice]
GO

ALTER TABLE [ProcessedGuideCOD]
DROP CONSTRAINT [UK_ProcessedGuideCOD_GuideSerie_GuideNumber];

select * from [ProcessedGuideCOD]