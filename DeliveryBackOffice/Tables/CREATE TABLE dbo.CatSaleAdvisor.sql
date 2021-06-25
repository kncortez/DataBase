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
ALTER TABLE dbo.CatCountry SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.CatSaleAdvisor
	(
	IdSaleAdvisor int NOT NULL IDENTITY (1, 1),
	SaleAdvisorCode nvarchar(12) NOT NULL,
	SaleAdvisorDescription nvarchar(50) NOT NULL,
	EmployeID int NOT NULL,
	SAPSellerID int NULL,
	CountryID varchar(2) NOT NULL,
	SaleAdvisorStatus bit NOT NULL,
	TokenCreated nvarchar(50) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.CatSaleAdvisor ADD CONSTRAINT
	PK_CatSaleAdvisor PRIMARY KEY CLUSTERED 
	(
	IdSaleAdvisor
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.CatSaleAdvisor ADD CONSTRAINT
	FK_CatSaleAdvisor_CatCountry FOREIGN KEY
	(
	CountryID
	) REFERENCES dbo.CatCountry
	(
	IdCountry
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.CatSaleAdvisor SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
