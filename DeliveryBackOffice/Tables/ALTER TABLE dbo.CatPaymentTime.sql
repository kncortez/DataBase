ALTER TABLE dbo.CatPaymentTime
ADD TimeSequence int null,CollectCOD bit null
GO
select * from dbo.CatPaymentTime
GO
DECLARE @v sql_variant
SET @v = N'Secuencia de tiempo de pago, Ej. Ahora es antes que recolección'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatPaymentTime', N'COLUMN', N'TimeSequence'
SET @v = N'Indica si en ese tiempo se debo cobrar el monto COD'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatPaymentTime', N'COLUMN', N'CollectCOD'