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
CREATE TABLE dbo.CatCommercialSegment
	(
	IdCommercialSegment int NOT NULL IDENTITY (1, 1),
	CommercialSegmentName nvarchar(75) NOT NULL,
	CommercialSegmentDescription nvarchar(200) NULL,
	RowStatus bit NOT NULL,
	TokenCreated nvarchar(50) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.CatCommercialSegment ADD CONSTRAINT
	DF_CatCommercialSegment_RowStatus DEFAULT 'TRUE' FOR RowStatus
GO
ALTER TABLE dbo.CatCommercialSegment ADD CONSTRAINT
	PK_CatCommercialSegment PRIMARY KEY CLUSTERED 
	(
	IdCommercialSegment
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.CatCommercialSegment SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
