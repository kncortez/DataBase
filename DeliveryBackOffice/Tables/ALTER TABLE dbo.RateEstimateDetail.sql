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
ALTER TABLE dbo.RateEstimateDetail
	DROP CONSTRAINT FK_RateEstimateDetail_RateEstimate
GO
ALTER TABLE dbo.RateEstimate SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.RateEstimateDetail
	DROP CONSTRAINT FK_RateEstimateDetail_RateCategory
GO
ALTER TABLE dbo.RateCategory SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.RateEstimateDetail
	DROP CONSTRAINT FK_RateEstimateDetail_Surcharge
GO
ALTER TABLE dbo.Surcharge SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.RateEstimateDetail
	DROP CONSTRAINT FK_RateEstimateDetail_Settlement
GO
ALTER TABLE dbo.Settlement SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_RateEstimateDetail
	(
	IdRateEstimateDetail bigint NOT NULL IDENTITY (1, 1),
	IdRateEstimate bigint NULL,
	IdSettlment bigint NULL,
	CountValue decimal(18, 2) NULL,
	IdSurcharge int NULL,
	SurchargeDescription nvarchar(50) NULL,
	PriceRate decimal(18, 2) NULL,
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
ALTER TABLE dbo.Tmp_RateEstimateDetail SET (LOCK_ESCALATION = TABLE)
GO
SET IDENTITY_INSERT dbo.Tmp_RateEstimateDetail ON
GO
IF EXISTS(SELECT * FROM dbo.RateEstimateDetail)
	 EXEC('INSERT INTO dbo.Tmp_RateEstimateDetail (IdRateEstimateDetail, IdRateEstimate, IdSettlment, CountValue, IdSurcharge, PercentValue, TotalAmount, IdRateCategory, Selected, DateExpire, EstimateDetailStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated)
		SELECT IdRateEstimateDetail, IdRateEstimate, IdSettlment, CountValue, IdSurcharge, PercentValue, TotalAmount, IdRateCategory, Selected, DateExpire, EstimateDetailStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated FROM dbo.RateEstimateDetail WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_RateEstimateDetail OFF
GO
DROP TABLE dbo.RateEstimateDetail
GO
EXECUTE sp_rename N'dbo.Tmp_RateEstimateDetail', N'RateEstimateDetail', 'OBJECT' 
GO
ALTER TABLE dbo.RateEstimateDetail ADD CONSTRAINT
	PK_RateEstimateDetail PRIMARY KEY CLUSTERED 
	(
	IdRateEstimateDetail
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

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
COMMIT
