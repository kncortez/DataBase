CREATE TABLE [dbo].[CatProductMKPAtribute] (
    [IdCatProductMKPAttribute]       INT            IDENTITY (1, 1) NOT NULL,
    [CatProductMKPId]                INT            NOT NULL,
    [ProductMKPAttributeDescription] NVARCHAR (300) NOT NULL,
    [ProductMKPAttributePosition]    INT            NOT NULL,
    [RowStatus]                      BIT            NOT NULL,
    [TokenCreated]                   NVARCHAR (50)  NOT NULL,
    [DateCreated]                    DATETIME       NOT NULL,
    [TokenUpdated]                   NVARCHAR (50)  NULL,
    [DateUpdated]                    DATETIME       NULL,
    CONSTRAINT [PK_IdCatProductMKPAttribute] PRIMARY KEY CLUSTERED ([IdCatProductMKPAttribute] ASC),
    CONSTRAINT [FK_CatProductMKP_CatProductMKPAtribute] FOREIGN KEY ([IdCatProductMKPAttribute]) REFERENCES [dbo].[CatProductMKP] ([IdCatProductMKP])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPAtribute', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPAtribute', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPAtribute', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPAtribute', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPAtribute', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Numero de posición del atributo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPAtribute', @level2type = N'COLUMN', @level2name = N'ProductMKPAttributePosition';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del atributo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPAtribute', @level2type = N'COLUMN', @level2name = N'ProductMKPAttributeDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id relacion con tabla CatProductMKP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPAtribute', @level2type = N'COLUMN', @level2name = N'CatProductMKPId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la tabla CatProductMKPAtribute', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductMKPAtribute', @level2type = N'COLUMN', @level2name = N'IdCatProductMKPAttribute';

