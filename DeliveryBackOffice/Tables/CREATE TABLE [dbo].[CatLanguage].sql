CREATE TABLE dbo.CatLanguage
	(
	IdLanguage int NOT NULL IDENTITY (1, 1),
	Language nvarchar(50) NOT NULL,
	Abbreviation nvarchar(5) NOT NULL,

	RowStatus bigint NOT NULL,
	TokenCreated nvarchar(50) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
DECLARE @v sql_variant 
SET @v = N'Identificador del idioma'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatLanguage', N'COLUMN', N'IdLanguage'
GO
DECLARE @v sql_variant 
SET @v = N'Lenguaje'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatLanguage', N'COLUMN', N'Language'
GO
DECLARE @v sql_variant 
SET @v = N'Abreviatura del lenguaje ISO 639-1'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatLanguage', N'COLUMN', N'Abbreviation'
GO
DECLARE @v sql_variant 
SET @v = N'Estado del registro'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatLanguage', N'COLUMN', N'RowStatus'
GO
DECLARE @v sql_variant 
SET @v = N'Usuario de creación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatLanguage', N'COLUMN', N'TokenCreated'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de creación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatLanguage', N'COLUMN', N'DateCreated'
GO
DECLARE @v sql_variant 
SET @v = N'Usuario de creación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatLanguage', N'COLUMN', N'TokenUpdated'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de creación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatLanguage', N'COLUMN', N'DateUpdated'
GO
ALTER TABLE dbo.CatLanguage ADD CONSTRAINT
	PK_CatLanguage PRIMARY KEY CLUSTERED 
	(
	IdLanguage
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]