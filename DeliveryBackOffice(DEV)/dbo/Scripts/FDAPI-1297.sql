-- SCRIPT FDAPI-1297

ALTER TABLE PointsByServiceLog
ADD TypeTransaction NVARCHAR(50) NULL;

GO
DECLARE @v sql_variant 
SET @v = N'Tipo de transacción aplicada (MONTO o SERVICIO)'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'PointsByServiceLog', N'COLUMN', N'TypeTransaction'
GO

ALTER TABLE PointsByServiceLog
ADD CatPointPromoId BIGINT NULL;

ALTER TABLE PointsByServiceLog
ADD CONSTRAINT FK_PointsByServiceLog_CatPointPromo FOREIGN KEY (CatPointPromoId) REFERENCES CatPointPromo(IdPointPromo);

GO
DECLARE @v sql_variant 
SET @v = N'Identificador de la promoción de puntos adicionales aplicada'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'PointsByServiceLog', N'COLUMN', N'CatPointPromoId'
GO