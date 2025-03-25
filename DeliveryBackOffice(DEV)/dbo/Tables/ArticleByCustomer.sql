CREATE TABLE [dbo].[ArticleByCustomer] (
    [AbcId]            INT             IDENTITY (1, 1) NOT NULL,
    [AbcIdArticle]     INT             NOT NULL,
    [AbcIdCustomer]    INT             NULL,
    [AbcRowStatus]     BIT             NOT NULL,
    [AbcTokenCreated]  VARCHAR (50)    NOT NULL,
    [AbcDateCreated]   DATETIME        NOT NULL,
    [AbcTokenUpdated]  VARCHAR (50)    NULL,
    [AbcDateUpdated]   DATETIME        NULL,
    [Code]             NVARCHAR (20)   NULL,
    [PriceDefault]     DECIMAL (12, 2) NULL,
    [Height]           DECIMAL (18, 2) NULL,
    [Width]            DECIMAL (18, 2) NULL,
    [Length]           DECIMAL (18, 2) NULL,
    [MassWeight]       DECIMAL (18, 2) NULL,
    [VolumetricWeight] DECIMAL (18, 2) NULL,
    [ShowDefault]      BIT             NULL,
    [IdCurrency] INT NULL, 
    PRIMARY KEY CLUSTERED ([AbcId] ASC),
    CONSTRAINT [FKArticleCustom] FOREIGN KEY ([AbcIdArticle]) REFERENCES [dbo].[CatArticle] ([ArtId]),
    CONSTRAINT [FKCustomArticle] FOREIGN KEY ([AbcIdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [AK_Password] UNIQUE NONCLUSTERED ([Code] ASC),
    CONSTRAINT [FK_ArticleByCustomer_CatCurrencyCOD] FOREIGN KEY ([IdCurrency]) REFERENCES [dbo].[CatCurrencyCOD] ([IdCatCurrencyCOD])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleByCustomer', @level2type = N'COLUMN', @level2name = N'AbcId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del artículo. Referencia a tabla CatArticle', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleByCustomer', @level2type = N'COLUMN', @level2name = N'AbcIdArticle';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente asociado al artículo. Referencia a tabla Customer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleByCustomer', @level2type = N'COLUMN', @level2name = N'AbcIdCustomer';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del artículo por cliente (activo/inactivo).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleByCustomer', @level2type = N'COLUMN', @level2name = N'AbcRowStatus';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del artículo por cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleByCustomer', @level2type = N'COLUMN', @level2name = N'AbcTokenCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del artículo por cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleByCustomer', @level2type = N'COLUMN', @level2name = N'AbcDateCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de última actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleByCustomer', @level2type = N'COLUMN', @level2name = N'AbcTokenUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de última actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleByCustomer', @level2type = N'COLUMN', @level2name = N'AbcDateUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código del artículo asignado por el cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleByCustomer', @level2type = N'COLUMN', @level2name = N'Code';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precio por defecto del artículo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleByCustomer', @level2type = N'COLUMN', @level2name = N'PriceDefault';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Altura del artículo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleByCustomer', @level2type = N'COLUMN', @level2name = N'Height';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ancho del artículo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleByCustomer', @level2type = N'COLUMN', @level2name = N'Width';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Longitud del artículo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleByCustomer', @level2type = N'COLUMN', @level2name = N'Length';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Peso en masa del artículo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleByCustomer', @level2type = N'COLUMN', @level2name = N'MassWeight';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Peso volumétrico del artículo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleByCustomer', @level2type = N'COLUMN', @level2name = N'VolumetricWeight';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si el artículo se muestra por defecto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleByCustomer', @level2type = N'COLUMN', @level2name = N'ShowDefault';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la moneda asociada. Referencia a tabla CatCurrencyCOD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleByCustomer', @level2type = N'COLUMN', @level2name = N'IdCurrency';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tabla que almacena articulos por tabla de precios. Intermedia entre RateData y CatArticle',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ArticleByCustomer',
    @level2type = NULL,
    @level2name = NULL

