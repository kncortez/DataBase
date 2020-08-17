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
CREATE TABLE dbo.Tmp_Province
	(
	IdProvince int NOT NULL IDENTITY (1, 1),
	ProvinceName nvarchar(50) NULL,
	ProvinceDescription nvarchar(100) NULL,
	ProvinceStatus bit NULL,
	ProvinceLatitud decimal(9, 6) NULL,
	ProvinceLongitud decimal(9, 6) NULL,
	PostalCode nvarchar(5) NULL,
	IdCountry nvarchar(2) NULL,
	TokenCreated nvarchar(50) NULL,
	DateCreated datetime NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_Province SET (LOCK_ESCALATION = TABLE)
GO
SET IDENTITY_INSERT dbo.Tmp_Province ON
GO
IF EXISTS(SELECT * FROM dbo.Province)
	 EXEC('INSERT INTO dbo.Tmp_Province (IdProvince, Name, Description, ProvinceStatus, ProvinceLatitud, ProvinceLongitud, IdCountry, TokenCreated, DateCreated, TokenUpdated, DateUpdated)
		SELECT IdProvince, Name, Description, ProvinceStatus, ProvinceLatitud, ProvinceLongitud, IdCountry, TokenCreated, DateCreated, TokenUpdated, DateUpdated FROM dbo.Province WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_Province OFF
GO
ALTER TABLE dbo.Township
	DROP CONSTRAINT FK_Township_Province
GO
ALTER TABLE dbo.Settlement
	DROP CONSTRAINT FK_Settlement_Province
GO
DROP TABLE dbo.Province
GO
EXECUTE sp_rename N'dbo.Tmp_Province', N'Province', 'OBJECT' 
GO
ALTER TABLE dbo.Province ADD CONSTRAINT
	PK_Province PRIMARY KEY CLUSTERED 
	(
	IdProvince
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
COMMIT
BEGIN TRANSACTION
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
BEGIN TRANSACTION
GO
ALTER TABLE dbo.Township ADD CONSTRAINT
	FK_Township_Province FOREIGN KEY
	(
	IdProvince
	) REFERENCES dbo.Province
	(
	IdProvince
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.Township SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
