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
ALTER TABLE dbo.Province SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.Township SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Settlement
	(
	IdSettlement bigint NOT NULL IDENTITY (1, 1),
	Settlement nvarchar(100) NULL,
	SettlementLatitud decimal(9, 6) NULL,
	SettlementLongitud decimal(9, 6) NULL,
	PostalCode nvarchar(5) NULL,
	SettlementSatus bit NULL,
	IdTownship int NULL,
	IdProvince int NULL,
	IdCountry nvarchar(2) NULL,
	IsSpecial bit NULL,
	TokenCreated nvarchar(50) NULL,
	DateCreated datetime NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Settlement ADD CONSTRAINT
	PK_Settlement PRIMARY KEY CLUSTERED 
	(
	IdSettlement
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.Settlement ADD CONSTRAINT
	FK_Settlement_Township FOREIGN KEY
	(
	IdTownship
	) REFERENCES dbo.Township
	(
	IdTownship
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.Settlement ADD CONSTRAINT
	FK_Settlement_Province FOREIGN KEY
	(
	IdProvince
	) REFERENCES dbo.Province
	(
	IdProvince
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.Settlement SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
