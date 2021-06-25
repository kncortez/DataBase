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
ALTER TABLE dbo.HubLogistics SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.CatRoute SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.VisitPointFrequency SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.VisitPointItinerary
	(
	IdVPItinerary bigint NOT NULL IDENTITY (1, 1),
	VPFrequencyID bigint NULL,
	DayOfVisit int NULL,
	InitializationTimeOfVisit nvarchar(5) NULL,
	FinalizationTimeOfVisit nvarchar(5) NULL,
	OrderSequence int NULL,
	RouteCodeID int NULL,
	HubLogisticID int NULL,
	RowStatus bit NULL,
	TokenCreated nvarchar(50) NULL,
	DateCreated datetime NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.VisitPointItinerary ADD CONSTRAINT
	PK_VisitPointItinerary PRIMARY KEY CLUSTERED 
	(
	IdVPItinerary
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.VisitPointItinerary ADD CONSTRAINT
	FK_VisitPointItinerary_VisitPointFrequency FOREIGN KEY
	(
	VPFrequencyID
	) REFERENCES dbo.VisitPointFrequency
	(
	IdVPFrequency
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.VisitPointItinerary ADD CONSTRAINT
	FK_VisitPointItinerary_CatRoute FOREIGN KEY
	(
	RouteCodeID
	) REFERENCES dbo.CatRoute
	(
	IdRoute
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.VisitPointItinerary ADD CONSTRAINT
	FK_VisitPointItinerary_HubLogistics FOREIGN KEY
	(
	HubLogisticID
	) REFERENCES dbo.HubLogistics
	(
	IdHubLogistic
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.VisitPointItinerary SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
