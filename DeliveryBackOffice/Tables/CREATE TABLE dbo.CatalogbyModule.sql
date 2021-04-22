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
ALTER TABLE dbo.CatSystem SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.CatModule SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.CatalogbyModule
	(
	IdCatModule int NOT NULL IDENTITY (1, 1),
	NameCatalog nvarchar(50) NULL,
	ModuleID int NULL,
	SystemID int NULL,
	RowStatus bit NULL,
	TokenCreated nvarchar(50) NULL,
	DateCreated datetime NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.CatalogbyModule ADD CONSTRAINT
	DF_CatalogbyModule_RowStatus DEFAULT 'TRUE' FOR RowStatus
GO
ALTER TABLE dbo.CatalogbyModule ADD CONSTRAINT
	PK_CatalogbyModule PRIMARY KEY CLUSTERED 
	(
	IdCatModule
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.CatalogbyModule ADD CONSTRAINT
	FK_CatalogbyModule_CatModule FOREIGN KEY
	(
	ModuleID
	) REFERENCES dbo.CatModule
	(
	ModIdModule
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.CatalogbyModule ADD CONSTRAINT
	FK_CatalogbyModule_CatSystem FOREIGN KEY
	(
	SystemID
	) REFERENCES dbo.CatSystem
	(
	SysIdSystem
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.CatalogbyModule SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
