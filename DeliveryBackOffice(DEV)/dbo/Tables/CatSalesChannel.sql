CREATE TABLE [dbo].[CatSalesChannel] (
    [IdSalesChannel] INT           IDENTITY (1, 1) NOT NULL,
    [Description]    NVARCHAR (50) NOT NULL,
    [TokenCreated]   NVARCHAR (50) NOT NULL,
    [DateCreated]    DATETIME      NOT NULL,
    [TokenUpdated]   NVARCHAR (50) NULL,
    [DateUpdated]    DATETIME      NULL,
    [RowStatus]      BIT           NOT NULL,
    CONSTRAINT [PK_CatSalesChannel] PRIMARY KEY CLUSTERED ([IdSalesChannel] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Canal de venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSalesChannel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de canal de venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSalesChannel', @level2type = N'COLUMN', @level2name = N'IdSalesChannel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del canal de venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSalesChannel', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el canal de venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSalesChannel', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSalesChannel', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSalesChannel', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSalesChannel', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Registro válido?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSalesChannel', @level2type = N'COLUMN', @level2name = N'RowStatus';

