CREATE TABLE [dbo].[CustomerTownshipMapping] (
    [IdCustomerTownshipMapping] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [IdTownship]                BIGINT        NOT NULL,
    [IdCustomer]                INT           NOT NULL,
    [ExternalTownshipId]        NVARCHAR(200) NULL, -- Puede ser NULL si el cliente solo manda el nombre
    [ExternalTownshipName]      NVARCHAR(200) NULL, -- Puede ser NULL si el cliente solo manda el ID
    [RowStatus]                 BIT           NOT NULL DEFAULT 1,
    [TokenCreated]              NVARCHAR (50) NOT NULL,
    [DateCreated]               DATETIME      NOT NULL DEFAULT GETDATE(),
    [TokenUpdated]              NVARCHAR (50) NULL,
    [DateUpdated]               DATETIME      NULL,
    CONSTRAINT [PK_CustomerTownshipMapping] PRIMARY KEY CLUSTERED ([IdCustomerTownshipMapping] ASC),
    CONSTRAINT [FK_CustomerTownshipMapping_Township] FOREIGN KEY ([IdTownship]) REFERENCES [dbo].[Township] ([IdTownship]),
    CONSTRAINT [FK_CustomerTownshipMapping_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [UQ_CustomerTownshipMapping_Duplicate] UNIQUE ([IdTownship], [IdCustomer]),
    -- Restricción para asegurar que al menos uno de los dos datos externos (ID o Nombre) exista
    CONSTRAINT [CHK_CustomerTownshipMapping_ExternalData] CHECK ([ExternalTownshipId] IS NOT NULL OR [ExternalTownshipName] IS NOT NULL)
);
GO

-- --------------------------------------------------
-- ÍNDICES
-- --------------------------------------------------

-- 1. Índice para cuando se busca por Cliente + ID Externo
CREATE NONCLUSTERED INDEX [IX_CustomerTownshipMapping_Customer_ExternalId]
ON [dbo].[CustomerTownshipMapping] ([IdCustomer], [ExternalTownshipId])
INCLUDE ([IdTownship], [RowStatus]);
GO

-- 2. Índice para cuando se busca por Cliente + Nombre Externo
CREATE NONCLUSTERED INDEX [IX_CustomerTownshipMapping_Customer_ExternalName]
ON [dbo].[CustomerTownshipMapping] ([IdCustomer], [ExternalTownshipName])
INCLUDE ([IdTownship], [RowStatus]);
GO

-- 3. Índice para búsquedas inversas (que clientes cubren un municipio interno)
CREATE NONCLUSTERED INDEX [IX_CustomerTownshipMapping_IdTownship]
ON [dbo].[CustomerTownshipMapping] ([IdTownship], [RowStatus])
INCLUDE ([IdCustomer], [ExternalTownshipId], [ExternalTownshipName]);
GO

-- --------------------------------------------------
-- DESCRIPCIONES
-- --------------------------------------------------
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador principal del mapeo de municipio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'IdCustomerTownshipMapping';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foránea del municipio interno de Forza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'IdTownship';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foránea del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'IdCustomer';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID o código que utiliza el cliente externo para este municipio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'ExternalTownshipId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre externo que utiliza el cliente para este municipio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'ExternalTownshipName';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro (1 activo, 0 inactivo)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'RowStatus';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'TokenCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'DateCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de última actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'TokenUpdated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de última actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CustomerTownshipMapping', @level2type = N'COLUMN', @level2name = N'DateUpdated';
GO

