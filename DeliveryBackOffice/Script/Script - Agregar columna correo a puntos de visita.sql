USE DeliveryBackOffice
GO
ALTER TABLE dbo.VisitPointClient ADD
	Email nvarchar(200) NULL
GO
DECLARE @v sql_variant 
SET @v = N'Correo del punto de visita'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'VisitPointClient', N'COLUMN', N'Email'