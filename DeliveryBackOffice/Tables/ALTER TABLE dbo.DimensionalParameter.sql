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
ALTER TABLE dbo.DimensionalParameter
	DROP CONSTRAINT FK_DimensionalParameters_Unit
GO
ALTER TABLE dbo.Unit SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_DimensionalParameter
	(
	IdDimensional int NOT NULL IDENTITY (1, 1),
	IdUnit int NULL,
	ByRange bit NULL,
	ByUnity bit NULL,
	MinimunValue int NULL,
	MaximunValue int NULL,
	DimensionalStatus bit NULL,
	IdCountry nvarchar(2) NULL,
	TokenCreated nvarchar(50) NULL,
	DateCreated datetime NULL,
	TokenUpdated nvarchar(50) NULL,
	UpdatedCreated datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_DimensionalParameter SET (LOCK_ESCALATION = TABLE)
GO
SET IDENTITY_INSERT dbo.Tmp_DimensionalParameter ON
GO
IF EXISTS(SELECT * FROM dbo.DimensionalParameter)
	 EXEC('INSERT INTO dbo.Tmp_DimensionalParameter (IdDimensional, IdUnit, ByRange, ByUnity, MinimunValue, MaximunValue, DimensionalStatus, IdCountry, TokenCreated, DateCreated, TokenUpdated, UpdatedCreated)
		SELECT CONVERT(int, IdDimensional), IdUnit, ByRange, ByUnity, MinimunValue, MaximunValue, DimensionalStatus, IdCountry, TokenCreated, DateCreated, TokenUpdated, UpdatedCreated FROM dbo.DimensionalParameter WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_DimensionalParameter OFF
GO
DROP TABLE dbo.DimensionalParameter
GO
EXECUTE sp_rename N'dbo.Tmp_DimensionalParameter', N'DimensionalParameter', 'OBJECT' 
GO
ALTER TABLE dbo.DimensionalParameter ADD CONSTRAINT
	PK_DimensionalParameter PRIMARY KEY CLUSTERED 
	(
	IdDimensional
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.DimensionalParameter ADD CONSTRAINT
	FK_DimensionalParameters_Unit FOREIGN KEY
	(
	IdUnit
	) REFERENCES dbo.Unit
	(
	IdUnit
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
