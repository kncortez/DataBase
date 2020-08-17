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
ALTER TABLE dbo.Customer SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Ecommerce
	(
	IdEcommerce int NOT NULL IDENTITY (1, 1),
	EcomerceName nvarchar(15) NULL,
	EcommerceDescription nvarchar(200) NULL,
	IsPaymentGateway bit NULL,
	IdCountry nvarchar(2) NULL,
	ApiWSEndPoint nvarchar(50) NULL,
	ApiWSPort nvarchar(5) NULL,
	ApiWSResource nvarchar(100) NULL,
	ApiWSController nvarchar(100) NULL,
	ApiWSMethod nvarchar(100) NULL,
	UserKey nvarchar(50) NULL,
	Passkey nvarchar(500) NULL,
	SecretKey nvarchar(100) NULL,
	CertSourceKey nvarchar(100) NULL,
	EcommerceStatus bit NULL,
	TokenCreated nvarchar(50) NULL,
	DateCreated datetime NULL,
	TokenUpdate nvarchar(50) NULL,
	DateUpdated datetime NULL,
	IdCustomer int NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Ecommerce ADD CONSTRAINT
	PK_Ecommerce PRIMARY KEY CLUSTERED 
	(
	IdEcommerce
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.Ecommerce ADD CONSTRAINT
	FK_Ecommerce_Customer FOREIGN KEY
	(
	IdCustomer
	) REFERENCES dbo.Customer
	(
	IdCustomer
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.Ecommerce SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
