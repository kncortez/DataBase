CREATE TABLE ShippingContainer (
	IdContainer 		BIGINT IDENTITY(1,1) NOT NULL,
	ReferenceContainer 	NVARCHAR(50) NOT NULL,
	IdCustomer 			INT NOT NULL,
	IdStatusContainer 	INT NOT NULL,
	CountGuides 		INT NULL,
	RowStatus 			BIT NOT NULL DEFAULT 1,
    UserCreated 		NVARCHAR(50) NOT NULL,
	DateCreated 		DATETIME NOT NULL,
	TokenCreated 		NVARCHAR(50) NOT NULL,
    UserUpdated 		NVARCHAR(50) NULL,
	DateUpdated 		DATETIME NULL,
	TokenUpdated 		NVARCHAR(50) NULL,
	CONSTRAINT [PK_ShippingContainer] PRIMARY KEY CLUSTERED ([IdContainer] ASC),
	CONSTRAINT [FK_ShippingContainer_Customer] FOREIGN KEY (IdCustomer) REFERENCES [dbo].[Customer] (IdCustomer),
	CONSTRAINT [FK_ShippingContainer_CatShipContainerStatus] FOREIGN KEY ([IdStatusContainer]) REFERENCES [dbo].[CatShipContainerStatus] ([IdCatStatus])
);

EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador del contenedor', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainer', N'COLUMN', N'IdContainer'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador del cliente', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainer', N'COLUMN', N'IdCustomer'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Estado del contenedor', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainer', N'COLUMN', N'IdStatusContainer'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Cantidad de guías', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainer', N'COLUMN', N'CountGuides'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Estado lógico del registro', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainer', N'COLUMN', N'RowStatus'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Usuario que realizó la creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainer', N'COLUMN', N'UserCreated'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha de creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainer', N'COLUMN', N'DateCreated'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Token de creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainer', N'COLUMN', N'TokenCreated'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Usuario que realizó la actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainer', N'COLUMN', N'UserUpdated'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Última fecha de actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainer', N'COLUMN', N'DateUpdated'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Último token de actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainer', N'COLUMN', N'TokenUpdated'
GO