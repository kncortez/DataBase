CREATE TABLE ClientConfigurationZPL (
    [IdCustomer]        INT PRIMARY KEY,
    [RowStatus]   BIT NOT NULL DEFAULT 0,
    [TokenCreated]      NVARCHAR(50) NOT NULL,
    [DateCreated]       DATETIME NOT NULL DEFAULT SYSDATETIME(),
    [TokenUpdated]      NVARCHAR(50) NULL,
    [DateUpdated]       DATETIME2(0) NULL,
    CONSTRAINT FK_ClientConfigurationZPL_Customer
        FOREIGN KEY (IdCustomer)
        REFERENCES Customer(IdCustomer)
        ON DELETE CASCADE
);

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador único de cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientConfigurationZPL', @level2type=N'COLUMN',@level2name=N'IdCustomer'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'El servicio de impresión ZPL está habilitado para el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientConfigurationZPL', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientConfigurationZPL', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientConfigurationZPL', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientConfigurationZPL', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientConfigurationZPL', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla de configuración para clientes con servicio ZPL' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClientConfigurationZPL'
GO


