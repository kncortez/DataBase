CREATE TABLE [dbo].[CatTypeProductMKP] (
    [IdCatTypeProductMKP]    INT         NOT NULL,
    [CatTypeProductNameMKP]  NCHAR (100) NOT NULL,
    [DescriptionTProductMKP] NCHAR (200) NOT NULL,
    [RowStatus]              BIT         NOT NULL,
    [DateCreated]            NCHAR (10)  NOT NULL,
    [TokenCreated]           NCHAR (10)  NOT NULL,
    [DateUpdated]            NCHAR (10)  NULL,
    [TokenUpdated]           NCHAR (10)  NULL,
    CONSTRAINT [PK_IdCatTypeProductMKP] PRIMARY KEY CLUSTERED ([IdCatTypeProductMKP] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que actualiza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeProductMKP', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha que actualiza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeProductMKP', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeProductMKP', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeProductMKP', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeProductMKP', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del tipo de Producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeProductMKP', @level2type = N'COLUMN', @level2name = N'DescriptionTProductMKP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del tipo de Producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeProductMKP', @level2type = N'COLUMN', @level2name = N'CatTypeProductNameMKP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatTypeProductMKP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeProductMKP', @level2type = N'COLUMN', @level2name = N'IdCatTypeProductMKP';

