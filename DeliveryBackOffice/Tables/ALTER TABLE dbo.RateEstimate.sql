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
ALTER TABLE dbo.RateEstimate
	DROP CONSTRAINT FK_RateEstimate_Settlement
GO
ALTER TABLE dbo.Settlement SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.RateEstimate
	DROP CONSTRAINT FK_RateEstimate_Ecommerce
GO
ALTER TABLE dbo.Ecommerce SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.RateEstimate
	DROP CONSTRAINT FK_RateEstimate_Customer
GO
ALTER TABLE dbo.Customer SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_RateEstimate
	(
	IdRateEstimated bigint NOT NULL IDENTITY (1, 1),
	IdSource bigint NULL,
	IdDestiny bigint NULL,
	ObjectType nvarchar(50) NULL,
	CountPieces int NULL,
	UnitValue decimal(5, 2) NULL,
	IdUnit int NULL,
	CodeCredit nvarchar(10) NULL,
	IdRate int NULL,
	EstimateTotalAmount decimal(18, 2) NULL,
	IdCustomer int NULL,
	IdEcommerce int NULL,
	DateService datetime NULL,
	EstimatedStatus bit NULL,
	TokenCreated nvarchar(50) NULL,
	DateCreated datetime NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_RateEstimate SET (LOCK_ESCALATION = TABLE)
GO
DECLARE @v sql_variant 
SET @v = N'Description of the object to Transport'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_RateEstimate', N'COLUMN', N'ObjectType'
GO
DECLARE @v sql_variant 
SET @v = N'Value of Unit Mass Lbs Weight'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_RateEstimate', N'COLUMN', N'UnitValue'
GO
DECLARE @v sql_variant 
SET @v = N'Mass Lbs'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_RateEstimate', N'COLUMN', N'IdUnit'
GO
SET IDENTITY_INSERT dbo.Tmp_RateEstimate ON
GO
IF EXISTS(SELECT * FROM dbo.RateEstimate)
	 EXEC('INSERT INTO dbo.Tmp_RateEstimate (IdRateEstimated, IdSource, IdDestiny, ObjectType, CountPieces, UnitValue, IdUnit, CodeCredit, IdRate, EstimateTotalAmount, IdCustomer, IdEcommerce, DateService, EstimatedStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated)
		SELECT IdRateEstimated, IdSource, IdDestiny, ObjectType, CountPieces, UnitValue, IdUnit, CodeCredit, IdRate, EstimateTotalAmount, IdCustomer, IdEcommerce, DateService, EstimatedStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated FROM dbo.RateEstimate WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_RateEstimate OFF
GO
ALTER TABLE dbo.RateEstimateDetail
	DROP CONSTRAINT FK_RateEstimateDetail_RateEstimate
GO
DROP TABLE dbo.RateEstimate
GO
EXECUTE sp_rename N'dbo.Tmp_RateEstimate', N'RateEstimate', 'OBJECT' 
GO
ALTER TABLE dbo.RateEstimate ADD CONSTRAINT
	PK_RateEstimate PRIMARY KEY CLUSTERED 
	(
	IdRateEstimated
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.RateEstimate ADD CONSTRAINT
	FK_RateEstimate_Customer FOREIGN KEY
	(
	IdCustomer
	) REFERENCES dbo.Customer
	(
	IdCustomer
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.RateEstimate ADD CONSTRAINT
	FK_RateEstimate_Ecommerce FOREIGN KEY
	(
	IdEcommerce
	) REFERENCES dbo.Ecommerce
	(
	IdEcommerce
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.RateEstimate ADD CONSTRAINT
	FK_RateEstimate_Settlement FOREIGN KEY
	(
	IdDestiny
	) REFERENCES dbo.Settlement
	(
	IdSettlement
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
BEGIN TRANSACTION
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
ALTER TABLE dbo.RateEstimateDetail SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
