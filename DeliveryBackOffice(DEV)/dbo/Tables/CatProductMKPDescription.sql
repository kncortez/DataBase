CREATE TABLE [dbo].[CatProductMKPDescription] (
    [IdCatProductMKPDescription] INT            IDENTITY (1, 1) NOT NULL,
    [Title]                      NVARCHAR (100) NOT NULL,
    [Description]                NVARCHAR (500) NOT NULL,
    [Position]                   INT            NOT NULL,
    [Type]                       NVARCHAR (50)  NOT NULL,
    [CatProductMKPId]            INT            NOT NULL,
    [RowStatus]                  BIT            NOT NULL,
    [DateCreated]                DATETIME       NOT NULL,
    [TokenCreated]               NVARCHAR (50)  NOT NULL,
    [DateUpdated]                DATETIME       NULL,
    [TokenUpdated]               NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([IdCatProductMKPDescription] ASC),
    CONSTRAINT [FK_CatProductMKP_CatProductMKPDescription] FOREIGN KEY ([IdCatProductMKPDescription]) REFERENCES [dbo].[CatProductMKP] ([IdCatProductMKP])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPDescription', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPDescription', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPDescription', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPDescription', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPDescription', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del Producto a la que hace referencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPDescription', @level2type = N'COLUMN', @level2name = N'CatProductMKPId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo para agrupar los registros en listado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPDescription', @level2type = N'COLUMN', @level2name = N'Type';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Orden para mostrar el registro en listado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPDescription', @level2type = N'COLUMN', @level2name = N'Position';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPDescription', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Título del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPDescription', @level2type = N'COLUMN', @level2name = N'Title';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPDescription', @level2type = N'COLUMN', @level2name = N'IdCatProductMKPDescription';

