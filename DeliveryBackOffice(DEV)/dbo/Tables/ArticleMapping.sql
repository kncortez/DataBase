CREATE TABLE [dbo].[ArticleMapping] (
    [IdArticleMapping]      INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ArticleForzaId]        INT           NOT NULL,
    [ArticleUEId]          INT           NOT NULL,
    [RowStatus]             BIT           NOT NULL,
    [TokenCreated]          NVARCHAR (50) NOT NULL,
    [DateCreated]           DATETIME      NOT NULL,
    [TokenUpdated]          NVARCHAR (50) NULL,
    [DateUpdated]           DATETIME      NULL,
    CONSTRAINT [PK_ArticleMapping] PRIMARY KEY CLUSTERED ([IdArticleMapping] ASC),
    CONSTRAINT [FK_ArticleMapping_CatArticle] FOREIGN KEY ([ArticleForzaId]) REFERENCES [dbo].[CatArticle] ([ArtId])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del mapeo de los articulos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleMapping', @level2type = N'COLUMN', @level2name = N'IdArticleMapping';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Articulo de Forza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleMapping', @level2type = N'COLUMN', @level2name = N'ArticleForzaId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Articulo de Ultra Entregas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleMapping', @level2type = N'COLUMN', @level2name = N'ArticleUEId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si el registro está vigente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleMapping', @level2type = N'COLUMN', @level2name = N'RowStatus';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleMapping', @level2type = N'COLUMN', @level2name = N'TokenCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleMapping', @level2type = N'COLUMN', @level2name = N'DateCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleMapping', @level2type = N'COLUMN', @level2name = N'TokenUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ArticleMapping', @level2type = N'COLUMN', @level2name = N'DateUpdated';
