USE [DeliveryBackOffice]

BEGIN TRAN

--AGREGAR COLUMNAS
ALTER TABLE [dbo].[ProcessedGuideCOD] ADD [DateUpdated] [datetime] NULL;
ALTER TABLE [dbo].[ProcessedGuideCOD] ADD [TokenUpdated] [varchar](50) NULL;
ALTER TABLE [dbo].[ProcessedGuideCOD] ADD [RowStatus] [bit] NULL;

--AGREGAR DATO EN LA COLUMNA ROWSTATUS
UPDATE [dbo].[ProcessedGuideCOD]
SET [RowStatus] = 'TRUE'

--MODIFICAR COLUMNA ROWSTATUS
ALTER TABLE [dbo].[ProcessedGuideCOD] ALTER COLUMN [RowStatus] [bit] NOT NULL;
ALTER TABLE [dbo].[ProcessedGuideCOD] ADD  CONSTRAINT [DF_ProcessedGuideCOD_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]

--COMMIT



