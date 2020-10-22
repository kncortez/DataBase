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
CREATE TABLE dbo.HubLogistics
	(
	IdHubLogistic int NOT NULL IDENTITY (1, 1),
	HubName varchar(50) NULL,
	HubAbbreviation varchar(5) NULL,
	HubStatus bit NULL,
	IdStation int NULL,
	IdCountry varchar(2) NULL,
	TokenCreated varchar(50) NULL,
	DateCreated datetime NULL,
	TokenUpdate varchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.HubLogistics ADD CONSTRAINT
	PK_HubLogistics PRIMARY KEY CLUSTERED 
	(
	IdHubLogistic
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.HubLogistics SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
