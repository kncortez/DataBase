USE DeliveryBackOffice
ALTER TABLE dbo.DeliveryOrder ADD
	DateUpdated datetime NULL,
	TokenUpdated nvarchar(50) NULL
GO
DECLARE @v sql_variant 
SET @v = N'Date editing guide'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'DeliveryOrder', N'COLUMN', N'DateUpdated'
GO
DECLARE @v2 sql_variant 
SET @v2 = N'User editing guide'
EXECUTE sp_addextendedproperty N'MS_Description', @v2, N'SCHEMA', N'dbo', N'TABLE', N'DeliveryOrder', N'COLUMN', N'TokenUpdated'
GO
