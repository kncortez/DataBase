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
ALTER TABLE dbo.Unit ADD
	UnitStatus bit NULL,
	TokenCreated nvarchar(50) NULL,
	DateCreated datetime NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
GO
ALTER TABLE dbo.Unit ADD CONSTRAINT
	DF_Unit_UnitStatus DEFAULT 'TRUE' FOR UnitStatus
GO
ALTER TABLE dbo.Unit SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
