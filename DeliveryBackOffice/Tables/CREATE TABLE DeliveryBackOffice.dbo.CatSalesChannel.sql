CREATE TABLE dbo.CatSalesChannel
	(
	IdSalesChannel int NOT NULL IDENTITY (1, 1),
	Description nvarchar(50) NOT NULL,
	TokenCreated nvarchar(50) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL,
	RowStatus bit NOT NULL
	)  ON [PRIMARY]
GO
DECLARE @v sql_variant 
SET @v = N'Canal de venta'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatSalesChannel', NULL, NULL
GO
DECLARE @v sql_variant 
SET @v = N'Identificador de canal de venta'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatSalesChannel', N'COLUMN', N'IdSalesChannel'
GO
DECLARE @v sql_variant 
SET @v = N'Descripción del canal de venta'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatSalesChannel', N'COLUMN', N'Description'
GO
DECLARE @v sql_variant 
SET @v = N'Usuario que creó el canal de venta'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatSalesChannel', N'COLUMN', N'TokenCreated'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de creación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatSalesChannel', N'COLUMN', N'DateCreated'
GO
DECLARE @v sql_variant 
SET @v = N'Token de actualización'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatSalesChannel', N'COLUMN', N'TokenUpdated'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de actualización'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatSalesChannel', N'COLUMN', N'DateUpdated'
GO
DECLARE @v sql_variant 
SET @v = N'Registro válido?'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatSalesChannel', N'COLUMN', N'RowStatus'
GO
ALTER TABLE dbo.CatSalesChannel ADD CONSTRAINT
	PK_CatSalesChannel PRIMARY KEY CLUSTERED 
	(
	IdSalesChannel
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

