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
CREATE TABLE dbo.VisitPointClient
	(
	IdVisitPointClient bigint NOT NULL IDENTITY (1, 1),
	CodeOfReference nvarchar(10) NULL,
	DescriptionOfClient varchar(100) NULL,
	StatusClient bit NULL,
	CountryId nvarchar(2) NULL,
	VisitPointId bigint NULL,
	TokenCreated nvarchar(50) NULL,
	DateCreated datetime NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL,
	CONSTRAINT UQ_CodeOfReferenceporVisitPointId UNIQUE( CodeOfReference,VisitPointId )
	)  ON [PRIMARY]
GO
DECLARE @v sql_variant 
SET @v = N'Desktop Visitpoint'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'VisitPointClient', N'COLUMN', N'VisitPointId'
GO
ALTER TABLE dbo.VisitPointClient ADD CONSTRAINT
	PK_VisitPointClient PRIMARY KEY CLUSTERED 
	(
	IdVisitPointClient
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.VisitPointClient SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
