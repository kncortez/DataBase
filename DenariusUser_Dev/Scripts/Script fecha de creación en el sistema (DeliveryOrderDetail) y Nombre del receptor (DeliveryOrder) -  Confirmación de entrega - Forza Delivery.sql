use DeliveryBackOffice
GO
ALTER TABLE dbo.DeliveryOrderDetail ADD
	DateCreatedInSystem datetime NULL
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de creación en el sistema'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'DeliveryOrderDetail', N'COLUMN', N'DateCreatedInSystem'
GO
ALTER TABLE dbo.DeliveryOrder ADD	
	NameOfReceiver varchar(200)
GO
DECLARE @v2 sql_variant 
SET @v2 = N'Nombre del receptor'
EXECUTE sp_addextendedproperty N'MS_Description', @v2, N'SCHEMA', N'dbo', N'TABLE', N'DeliveryOrder', N'COLUMN', N'NameOfReceiver'
GO

