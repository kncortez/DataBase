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
ALTER TABLE dbo.SegmentArea ADD
	IdTypeOfSegment int NULL
GO
DECLARE @v sql_variant 
SET @v = N'1 Geografia , 2 Kilometraje'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SegmentArea', N'COLUMN', N'IdTypeOfSegment'
GO
ALTER TABLE dbo.SegmentArea SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


update SegmentArea
set IdTypeOfSegment = 1 
where IdTypeOfSegment is null 