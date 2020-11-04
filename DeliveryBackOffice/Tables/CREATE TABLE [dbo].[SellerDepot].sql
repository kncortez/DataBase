Use DeliveryBackOffice
GO
CREATE TABLE dbo.SellerDepot
	(
	IdSellerDepot int NOT NULL IDENTITY (1, 1),
	IdSeller int NOT NULL,
	IdSettlement bigint NOT NULL,
	CodeOfReference nvarchar(100) NOT NULL,
	CONSTRAINT SellerDepot_UK UNIQUE(CodeOfReference),	
	DescriptionOfClient nvarchar(100) NOT NULL,
	Address nvarchar(200) NOT NULL,
	Phone nvarchar(50) NULL,
	ContactName nvarchar(200) NULL,
	Status bit NOT NULL,
	DateCreated datetime NOT NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
DECLARE @v sql_variant 
SET @v = N'Identificador de la bodega'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SellerDepot', N'COLUMN', N'IdSellerDepot'
GO
DECLARE @v sql_variant 
SET @v = N'Identificador del seller'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SellerDepot', N'COLUMN', N'IdSeller'
GO
DECLARE @v sql_variant 
SET @v = N'Ubicación del depósito para cálculo de servicio'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SellerDepot', N'COLUMN', N'IdSettlement'
GO
DECLARE @v sql_variant 
SET @v = N'Identificador único de bodega'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SellerDepot', N'COLUMN', N'CodeOfReference'
GO
DECLARE @v sql_variant 
SET @v = N'Descripción de bodega'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SellerDepot', N'COLUMN', N'DescriptionOfClient'
GO
DECLARE @v sql_variant 
SET @v = N'Dirección de bodega'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SellerDepot', N'COLUMN', N'Address'
GO
DECLARE @v sql_variant 
SET @v = N'Teléfono de bodega'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SellerDepot', N'COLUMN', N'Phone'
GO
DECLARE @v sql_variant 
SET @v = N'Nombre del contacto de bodega'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SellerDepot', N'COLUMN', N'ContactName'
GO
DECLARE @v sql_variant 
SET @v = N'Activo o inactivo'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SellerDepot', N'COLUMN', N'Status'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de creación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SellerDepot', N'COLUMN', N'DateCreated'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de actualización'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'SellerDepot', N'COLUMN', N'DateUpdated'
GO
ALTER TABLE dbo.SellerDepot ADD CONSTRAINT
	PK_SellerDepot PRIMARY KEY CLUSTERED 
	(
	IdSellerDepot
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.SellerDepot ADD CONSTRAINT
	FK_SellerDepot_Seller FOREIGN KEY
	(
	IdSeller
	) REFERENCES dbo.Seller
	(
	IdSeller
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.SellerDepot ADD CONSTRAINT
	FK_SellerDepot_Settlement FOREIGN KEY
	(
	IdSettlement
	) REFERENCES dbo.Settlement
	(
	IdSettlement
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.SellerDepot SET (LOCK_ESCALATION = TABLE)
