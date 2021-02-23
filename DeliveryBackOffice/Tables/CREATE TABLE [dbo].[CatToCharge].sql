CREATE TABLE dbo.CatToCharge
	(
	IdToCharge int NOT NULL IDENTITY (1, 1),
	Name nvarchar(50) NOT NULL,
	Description nvarchar(100) NULL,
	DescriptionLabel nvarchar(100) NULL,
	Value decimal(18,2) NOT NULL,
	UnitId int NULL,
	CountryId varchar(2) NULL,
	CurrencyId int NULL,
	RowStatus bit NOT NULL,
	TokenCreated nvarchar(50) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
DECLARE @v sql_variant 
SET @v = N'Catálogo por defecto de los monto a cobrar a los clientes del portal'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatToCharge', NULL, NULL
GO
DECLARE @v sql_variant 
SET @v = N'Identificado de registro'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatToCharge', N'COLUMN', N'IdToCharge'
GO
DECLARE @v sql_variant 
SET @v = N'Descripción de monto a cobrar'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatToCharge', N'COLUMN', N'Name'
GO
DECLARE @v sql_variant 
SET @v = N'Descripción del monto a cobrar'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatToCharge', N'COLUMN', N'Description'
GO
DECLARE @v sql_variant 
SET @v = N'Valor o porcentaje'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatToCharge', N'COLUMN', N'Value'
GO
DECLARE @v sql_variant 
SET @v = N'Unidad de media valor o porcentaje'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatToCharge', N'COLUMN', N'UnitId'
GO
DECLARE @v sql_variant 
SET @v = N'País al que pertenece el cobro'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatToCharge', N'COLUMN', N'CountryId'
GO
DECLARE @v sql_variant 
SET @v = N'Moneda'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatToCharge', N'COLUMN', N'CurrencyId'
GO
DECLARE @v sql_variant 
SET @v = N'Estado activo o no'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatToCharge', N'COLUMN', N'RowStatus'
GO
DECLARE @v sql_variant 
SET @v = N'Usuario de creación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatToCharge', N'COLUMN', N'TokenCreated'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de creación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatToCharge', N'COLUMN', N'DateCreated'
GO
DECLARE @v sql_variant 
SET @v = N'Usuario de modificación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatToCharge', N'COLUMN', N'TokenUpdated'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de modificación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CatToCharge', N'COLUMN', N'DateUpdated'
GO
ALTER TABLE dbo.CatToCharge ADD CONSTRAINT
	PK_CatToCharge PRIMARY KEY CLUSTERED 
	(
	IdToCharge
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.CatToCharge ADD CONSTRAINT
	FK_CatToCharge_CatCountry FOREIGN KEY
	(
	CountryId
	) REFERENCES dbo.CatCountry
	(
	IdCountry
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.CatToCharge ADD CONSTRAINT
	FK_CatToCharge_DeliveryCurrency FOREIGN KEY
	(
	CurrencyId
	) REFERENCES dbo.DeliveryCurrency
	(
	Currency_Id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.CatToCharge ADD CONSTRAINT
	FK_CatToCharge_Unit FOREIGN KEY
	(
	UnitId
	) REFERENCES dbo.Unit
	(
	IdUnit
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.CatToCharge ADD CONSTRAINT
	FK_CatToCharge_CatToCharge FOREIGN KEY
	(
	IdToCharge
	) REFERENCES dbo.CatToCharge
	(
	IdToCharge
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
GO