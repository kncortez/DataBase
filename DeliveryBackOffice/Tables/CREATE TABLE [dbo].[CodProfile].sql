Use DeliveryBackOffice
GO
CREATE TABLE dbo.CodProfile
	(
	CustomerId int NOT NULL,
	NotificationEmail nvarchar(200) NOT NULL,
	TradeName nvarchar(100) NOT NULL,
	LocalCommission decimal(14, 2) NOT NULL,
	MetropolitanCommission decimal(14, 2) NOT NULL,
	ForeignCommission decimal(14, 2) NOT NULL,
	SpecialCommision decimal(14, 2) NOT NULL,
	TokenCreated nvarchar(50) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
DECLARE @v sql_variant 
SET @v = N'Perfil de COD para clientes'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodProfile', NULL, NULL
GO
DECLARE @v sql_variant 
SET @v = N'Identificador del cliente	'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodProfile', N'COLUMN', N'CustomerId'
GO
DECLARE @v sql_variant 
SET @v = N'Email notificación acreditamiento	'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodProfile', N'COLUMN', N'NotificationEmail'
GO
DECLARE @v sql_variant 
SET @v = N'Nombre del comercio'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodProfile', N'COLUMN', N'TradeName'
GO
DECLARE @v sql_variant 
SET @v = N'Comisión local'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodProfile', N'COLUMN', N'LocalCommission'
GO
DECLARE @v sql_variant 
SET @v = N'Porcentaje de comisión área metropolitana'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodProfile', N'COLUMN', N'MetropolitanCommission'
GO
DECLARE @v sql_variant 
SET @v = N'Porcentaje de comisión foráneo'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodProfile', N'COLUMN', N'ForeignCommission'
GO
DECLARE @v sql_variant 
SET @v = N'Porcentaje de comisión especial'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodProfile', N'COLUMN', N'SpecialCommision'
GO
DECLARE @v sql_variant 
SET @v = N'Token de creación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodProfile', N'COLUMN', N'TokenCreated'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de creación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodProfile', N'COLUMN', N'DateCreated'
GO
DECLARE @v sql_variant 
SET @v = N'Token de actualización'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodProfile', N'COLUMN', N'TokenUpdated'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de actualización'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodProfile', N'COLUMN', N'DateUpdated'
GO
ALTER TABLE dbo.CodProfile ADD CONSTRAINT
	PK_CodProfile PRIMARY KEY CLUSTERED 
	(
	CustomerId
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

ALTER TABLE dbo.CodProfile ADD CONSTRAINT
	FK_CodProfile_Customer FOREIGN KEY
	(
	CustomerId
	) REFERENCES dbo.Customer
	(
	IdCustomer
	) 