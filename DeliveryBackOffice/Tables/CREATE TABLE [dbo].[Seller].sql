Use DeliveryBackOffice
GO
CREATE TABLE dbo.Seller
	(
	IdSeller int NOT NULL IDENTITY (1, 1),
	IdCustomer int NOT NULL,
	Name nvarchar(100) NOT NULL,
	CodeOfReference nvarchar(100) NOT NULL,
	CONSTRAINT Seller_UK UNIQUE(CodeOfReference),
	IsPrincipal bit NOT NULL,
	Status bit NOT NULL,
	DateCreated datetime NOT NULL
	)  ON [PRIMARY]
GO
DECLARE @v sql_variant 
SET @v = N'Identificador del cliente '
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Seller', N'COLUMN', N'IdSeller'
GO
DECLARE @v sql_variant 
SET @v = N'A quien pertenece el seller'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Seller', N'COLUMN', N'IdCustomer'
GO
DECLARE @v sql_variant 
SET @v = N'Nombre del seller'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Seller', N'COLUMN', N'Name'
GO
DECLARE @v sql_variant 
SET @v = N'Código que identifica al seller'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Seller', N'COLUMN', N'CodeOfReference'
GO
DECLARE @v sql_variant 
SET @v = N'Si el seller es principal o no'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Seller', N'COLUMN', N'IsPrincipal'
GO
DECLARE @v sql_variant 
SET @v = N'Activo o inactivo'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Seller', N'COLUMN', N'Status'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de creación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Seller', N'COLUMN', N'DateCreated'
GO
ALTER TABLE dbo.Seller ADD CONSTRAINT
	PK_Seller PRIMARY KEY CLUSTERED 
	(
	IdSeller
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.Seller ADD CONSTRAINT
	FK_Seller_Customer FOREIGN KEY
	(
	IdCustomer
	) REFERENCES dbo.Customer
	(
	IdCustomer
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.Seller SET (LOCK_ESCALATION = TABLE)

