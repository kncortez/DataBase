/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.VisitPointClient ADD
	BranchCode nvarchar(50) NULL
GO
DECLARE @v sql_variant 
SET @v = N'Se refiere al número de sucursal de la agencia, tienda u oficina identificada por cliente'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'VisitPointClient', N'COLUMN', N'BranchCode'
GO
ALTER TABLE dbo.VisitPointClient SET (LOCK_ESCALATION = TABLE)
GO
COMMIT

update DeliveryBackOffice.dbo.VisitPointClient 
set BranchCode = CodeOfReference