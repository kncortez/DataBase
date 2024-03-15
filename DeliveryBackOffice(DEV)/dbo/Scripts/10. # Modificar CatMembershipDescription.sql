ALTER TABLE dbo.Membership ADD
	ActivationDate datetime NULL
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de activación del producto'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Membership', N'COLUMN', N'ActivationDate'

ALTER TABLE dbo.Subscription ADD
	ActivationDate datetime NULL
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de activación del producto'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Subscription', N'COLUMN', N'ActivationDate'