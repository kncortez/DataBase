CREATE TABLE [dbo].[CatInvoiceType] (
    [IdCatInvoiceType] INT            IDENTITY (1, 1) NOT NULL,
    [Name]             NVARCHAR (50)  NOT NULL,
    [Description]      NVARCHAR (100) NULL,
    [RowStatus]        BIT            CONSTRAINT [DF_CatInvoiceType_RowStatus] DEFAULT ('TRUE') NULL,
    [TokenCreated]     NVARCHAR (50)  NULL,
    [DateCreated]      DATETIME       NULL,
    [TokenUpdated]     NVARCHAR (50)  NULL,
    [DateUpdated]      DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdCatInvoiceType] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar los tipos de facturas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatInvoiceType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id CatInvoiceType', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatInvoiceType', @level2type = N'COLUMN', @level2name = N'IdCatInvoiceType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del tipo de factura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatInvoiceType', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del tipo de factura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatInvoiceType', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatInvoiceType', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatInvoiceType', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación de fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatInvoiceType', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que actualizó fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatInvoiceType', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatInvoiceType', @level2type = N'COLUMN', @level2name = N'DateUpdated';

