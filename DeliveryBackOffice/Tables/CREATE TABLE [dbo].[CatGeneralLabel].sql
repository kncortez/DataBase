CREATE TABLE dbo.CatGeneralLabel
	(
	IdLabel bigint NOT NULL IDENTITY (1, 1),
	LabelCode nvarchar(100) NOT NULL,
	LabelDescription nvarchar(200) NOT NULL,
	LanguageId int NOT NULL,
	RowStatus bit NOT NULL,
	TokenCreated nvarchar(50) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated nvarchar(50) NULL
	)  ON [PRIMARY]
GO
DECLARE @v sql_variant 
SET @v = N'Identificador de registro'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatGeneralLabel', N'COLUMN', N'IdLabel'
GO
DECLARE @v sql_variant 
SET @v = N'Identifica a la etiqueta'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatGeneralLabel', N'COLUMN', N'LabelCode'
GO
DECLARE @v sql_variant 
SET @v = N'Descripción por idioma'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatGeneralLabel', N'COLUMN', N'LabelDescription'
GO
DECLARE @v sql_variant 
SET @v = N'Lenguaje de la etiqueta'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatGeneralLabel', N'COLUMN', N'LanguageId'
GO
DECLARE @v sql_variant 
SET @v = N'Estado del registro'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatGeneralLabel', N'COLUMN', N'RowStatus'
GO
DECLARE @v sql_variant 
SET @v = N'Usuario de creación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatGeneralLabel', N'COLUMN', N'TokenCreated'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de creación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatGeneralLabel', N'COLUMN', N'DateCreated'
GO
DECLARE @v sql_variant 
SET @v = N'Usuario de actualización'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatGeneralLabel', N'COLUMN', N'TokenUpdated'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de modificación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatGeneralLabel', N'COLUMN', N'DateUpdated'
GO
ALTER TABLE dbo.CatGeneralLabel ADD CONSTRAINT
	PK_CatGeneralLabel PRIMARY KEY CLUSTERED 
	(
	IdLabel
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE CatGeneralLabel
ADD CONSTRAINT UC_CatGeneralLabel UNIQUE (LabelCode,LanguageId);
GO
CREATE UNIQUE INDEX IDX_CatGeneralLabel ON CatGeneralLabel (LabelCode DESC,LanguageId DESC);

