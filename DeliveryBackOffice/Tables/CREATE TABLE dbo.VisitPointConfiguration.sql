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
ALTER TABLE dbo.DeliveryCurrency SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.CatBankAccountType SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.DeliveryBank SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.HubLogistics SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.CatTransportCompany SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.VisitPointClient SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.VisitPointConfiguration
	(
	IdVPConfiguration bigint NOT NULL  IDENTITY (1, 1),
	VisitPointID int NOT NULL,
	TransportCompanyID int NULL,
	HubLogisticID int NULL,
	CODAccountBankID int NULL,
	CODAccountName nvarchar(50) NULL,
	CODAccountNumber nvarchar(50) NULL,
	CODAccountBankTypeID int NULL,
	CODAccountCurrencyID int NULL,
	RowStatus bit NULL,
	TokenCreated nvarchar(50) NULL,
	DateCreated datetime NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.VisitPointConfiguration ADD CONSTRAINT
	PK_VisitPointConfiguration PRIMARY KEY CLUSTERED 
	(
	IdVPConfiguration
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.VisitPointConfiguration ADD CONSTRAINT
	FK_VisitPointConfiguration_VisitPointClient FOREIGN KEY
	(
	VisitPointID
	) REFERENCES dbo.VisitPointClient
	(
	CodeOfReference
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.VisitPointConfiguration ADD CONSTRAINT
	FK_VisitPointConfiguration_CatTransportCompany FOREIGN KEY
	(
	TransportCompanyID
	) REFERENCES dbo.CatTransportCompany
	(
	IdTransportCompany
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.VisitPointConfiguration ADD CONSTRAINT
	FK_VisitPointConfiguration_HubLogistics FOREIGN KEY
	(
	HubLogisticID
	) REFERENCES dbo.HubLogistics
	(
	IdHubLogistic
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.VisitPointConfiguration ADD CONSTRAINT
	FK_VisitPointConfiguration_DeliveryBank FOREIGN KEY
	(
	CODAccountBankID
	) REFERENCES dbo.DeliveryBank
	(
	Id_bank
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.VisitPointConfiguration ADD CONSTRAINT
	FK_VisitPointConfiguration_CatBankAccountType FOREIGN KEY
	(
	CODAccountBankTypeID
	) REFERENCES dbo.CatBankAccountType
	(
	IdBankAccountType
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.VisitPointConfiguration ADD CONSTRAINT
	FK_VisitPointConfiguration_DeliveryCurrency FOREIGN KEY
	(
	CODAccountCurrencyID
	) REFERENCES dbo.DeliveryCurrency
	(
	Currency_Id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.VisitPointConfiguration SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
