ALTER TABLE dbo.CatTypeIncidence ADD
	EvidenceRequirement bit NULL,
	CourierInstructions nvarchar(100) NULL
GO
DECLARE @v sql_variant 
SET @v = N'Evidencia es requerida para esta incidencia?'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatTypeIncidence', N'COLUMN', N'EvidenceRequirement'
GO
DECLARE @v sql_variant 
SET @v = N'Instrucciones para el courier'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatTypeIncidence', N'COLUMN', N'CourierInstructions'
