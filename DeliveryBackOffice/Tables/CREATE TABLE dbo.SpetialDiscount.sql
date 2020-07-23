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
CREATE TABLE dbo.SpetialDiscount
	(
	IdSpetialDiscount int NOT NULL IDENTITY (1, 1),
	DiscountName nvarchar(50) NULL,
	PercentValue decimal(18, 2) NULL,
	SpetialDiscountStatus bit NULL,
	DateExpire datetime NULL,
	IdCustomer int NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.SpetialDiscount ADD CONSTRAINT
	PK_SpetialDiscount PRIMARY KEY CLUSTERED 
	(
	IdSpetialDiscount
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.SpetialDiscount ADD CONSTRAINT
	FK_SpetialDiscount_Customer FOREIGN KEY
	(
	IdCustomer
	) REFERENCES dbo.Customer
	(
	IdCustomer
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.SpetialDiscount SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
