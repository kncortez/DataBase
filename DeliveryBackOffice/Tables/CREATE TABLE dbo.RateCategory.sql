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
CREATE TABLE dbo.RateCategory
	(
	IdRateCategory int NOT NULL IDENTITY (1, 1),
	TitleName nvarchar(50) NULL,
	RateCatDescription nvarchar(200) NULL,
	RateCatStatus bit NULL,
	TokenCreated nvarchar(50) NULL,
	DateCreated datetime NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.RateCategory ADD CONSTRAINT
	PK_RateCategory PRIMARY KEY CLUSTERED 
	(
	IdRateCategory
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.RateCategory SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
