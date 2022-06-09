CREATE TABLE [dbo].[CatArticleCategorySAP] (
    [IdCatCategoryArticleSAP] INT            IDENTITY (1, 1) NOT NULL,
    [Name]                    NVARCHAR (100) NOT NULL,
    [Description]             NVARCHAR (100) NULL,
    [RowSatus]                BIT            CONSTRAINT [DF_CatArticleCategorySAP_RowStatus] DEFAULT ('TRUE') NULL,
    [TokenCreated]            NVARCHAR (50)  NULL,
    [DateCreated]             DATETIME       NULL,
    [TokenUpdated]            NVARCHAR (50)  NULL,
    [DateUpdated]             DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdCatCategoryArticleSAP] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id CatArticleCategorySAP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleCategorySAP', @level2type = N'COLUMN', @level2name = N'IdCatCategoryArticleSAP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre categoría', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleCategorySAP', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción categoría', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleCategorySAP', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'RowSatus categoría', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleCategorySAP', @level2type = N'COLUMN', @level2name = N'RowSatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TokenCreated categoría', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleCategorySAP', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DateCreated categoría', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleCategorySAP', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TokenUpdated categoría', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleCategorySAP', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DateUpdated categoría', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatArticleCategorySAP', @level2type = N'COLUMN', @level2name = N'DateUpdated';

