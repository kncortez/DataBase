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
ALTER TABLE dbo.CatBankAccountType SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.DeliveryCurrency SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.DeliveryBank SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.CatConditionOfPayment SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.CatCommercialSegment SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.CatBusinessActivity SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.CatBusinessSegment SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.CatTypeOfBusiness SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.CatSaleAdvisor SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.CatCountry SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.Customer ADD
	CountryID varchar(2) NULL,
	CommercialName nvarchar(50) NULL,
	CustomerPhone nvarchar(50) NULL,
	WebsiteURI nvarchar(50) NULL,
	ContactName nvarchar(50) NULL,
	ContactEmail nvarchar(50) NULL,
	NotificationAddress nvarchar(200) NULL,
	SaleAdvisorID int NULL,
	DateUpService datetime NULL,
	DateDownService datetime NULL,
	TypeOfBusinessID int NULL,
	BusinessSegmentID int NULL,
	BusinessActivityID int NULL,
	CommercialSegmentID int NULL,
	OperationContactName nvarchar(50) NULL,
	OperationContactPhone nvarchar(50) NULL,
	OperationContactEmail nvarchar(50) NULL,
	LegalSponsorName nvarchar(50) NULL,
	LegalSponsorLastName nvarchar(50) NULL,
	LegalSponsorDPI nvarchar(50) NULL,
	HasAgreement bit NULL,
	AgreementNumber nvarchar(50) NULL,
	AgreementDateStart datetime NULL,
	AgreementDateEnd datetime NULL,
	InvoiceName nvarchar(100) NULL,
	TaxIdentificationNumber nvarchar(50) NULL,
	FiscalAddress nvarchar(200) NULL,
	InvoiceEmail nvarchar(50) NULL,
	ConditionOfPaymentID int NULL,
	InvoiceContactName nvarchar(50) NULL,
	InvoiceContactPhone nvarchar(50) NULL,
	InvoiceContactEmail nvarchar(50) NULL,
	CODAccountBankID int NULL,
	CODAccountNumber nvarchar(50) NULL,
	CODAccountName nvarchar(50) NULL,
	CODAccountTypeID int NULL,
	CODCurrencyID int NULL,
	CODContactName nvarchar(50) NULL,
	CODContactPhone nvarchar(50) NULL,
	CODContactEmail nvarchar(50) NULL,
	RowSatus bit NULL,
	TokenCreated nvarchar(50) NULL,
	DateCreated datetime NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
GO
ALTER TABLE dbo.Customer ADD CONSTRAINT
	FK_Customer_CatCountry FOREIGN KEY
	(
	CountryID
	) REFERENCES dbo.CatCountry
	(
	IdCountry
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.Customer ADD CONSTRAINT
	FK_Customer_CatSaleAdvisor FOREIGN KEY
	(
	SaleAdvisorID
	) REFERENCES dbo.CatSaleAdvisor
	(
	IdSaleAdvisor
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.Customer ADD CONSTRAINT
	FK_Customer_CatTypeOfBusiness FOREIGN KEY
	(
	TypeOfBusinessID
	) REFERENCES dbo.CatTypeOfBusiness
	(
	IdTypeOfBusiness
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.Customer ADD CONSTRAINT
	FK_Customer_CatBusinessSegment FOREIGN KEY
	(
	BusinessSegmentID
	) REFERENCES dbo.CatBusinessSegment
	(
	IdBusinessSegment
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.Customer ADD CONSTRAINT
	FK_Customer_CatBusinessActivity FOREIGN KEY
	(
	BusinessActivityID
	) REFERENCES dbo.CatBusinessActivity
	(
	IdBusinessActivity
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.Customer ADD CONSTRAINT
	FK_Customer_CatCommercialSegment FOREIGN KEY
	(
	CommercialSegmentID
	) REFERENCES dbo.CatCommercialSegment
	(
	IdCommercialSegment
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.Customer ADD CONSTRAINT
	FK_Customer_CatConditionOfPayment FOREIGN KEY
	(
	ConditionOfPaymentID
	) REFERENCES dbo.CatConditionOfPayment
	(
	IdConditionOfPayment
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.Customer ADD CONSTRAINT
	FK_Customer_DeliveryBank FOREIGN KEY
	(
	CODAccountBankID
	) REFERENCES dbo.DeliveryBank
	(
	Id_bank
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.Customer ADD CONSTRAINT
	FK_Customer_DeliveryCurrency FOREIGN KEY
	(
	CODCurrencyID
	) REFERENCES dbo.DeliveryCurrency
	(
	Currency_Id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 

GO
ALTER TABLE dbo.Customer ADD CONSTRAINT
	FK_Customer_CatBankAccountType FOREIGN KEY
	(
	CODAccountTypeID
	) REFERENCES dbo.CatBankAccountType
	(
	IdBankAccountType
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 

GO
ALTER TABLE dbo.Customer SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
