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
ALTER TABLE dbo.RateCategory SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.Surcharge SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.Settlement SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.RateEstimate SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.RateEstimateDetail
	(
	IdRateEstimateDetail bigint NOT NULL IDENTITY (1, 1),
	IdRateEstimate bigint NULL,
	IdSettlment bigint NULL,
	IdSurcharge int NULL,
	PercentValue decimal(18, 2) NULL,
	TotalAmount decimal(18, 2) NULL,
	IdRateCategory int NULL,
	Selected bit NULL,
	DateExpire datetime NULL,
	EstimateDetailStatus bit NULL,
	TokenCreated nvarchar(50) NULL,
	DateCreated datetime NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.RateEstimateDetail ADD CONSTRAINT
	PK_RateEstimateDetail PRIMARY KEY CLUSTERED 
	(
	IdRateEstimateDetail
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.RateEstimateDetail ADD CONSTRAINT
	FK_RateEstimateDetail_RateEstimate FOREIGN KEY
	(
	IdRateEstimate
	) REFERENCES dbo.RateEstimate
	(
	IdRateEstimated
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.RateEstimateDetail ADD CONSTRAINT
	FK_RateEstimateDetail_Settlement FOREIGN KEY
	(
	IdSettlment
	) REFERENCES dbo.Settlement
	(
	IdSettlement
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.RateEstimateDetail ADD CONSTRAINT
	FK_RateEstimateDetail_Surcharge FOREIGN KEY
	(
	IdSurcharge
	) REFERENCES dbo.Surcharge
	(
	IdSurcharge
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.RateEstimateDetail ADD CONSTRAINT
	FK_RateEstimateDetail_RateCategory FOREIGN KEY
	(
	IdRateCategory
	) REFERENCES dbo.RateCategory
	(
	IdRateCategory
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.RateEstimateDetail SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
