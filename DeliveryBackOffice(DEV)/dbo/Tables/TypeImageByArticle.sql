CREATE TABLE [dbo].[TypeImageByArticle] (
    [IdTypeImageByArticle] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ArticleId]            INT           NOT NULL,
    [TypeOfImageId]        INT           NOT NULL,
    [IsRequired]           BIT           NOT NULL,
    [RowStatus]            BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]         NVARCHAR (50) NOT NULL,
    [DateCreated]          DATETIME      NOT NULL,
    [TokenUpdated]         NVARCHAR (50) NULL,
    [DateUpdated]          DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdTypeImageByArticle] ASC),
    CONSTRAINT [FK_TypeImageByArticle_Article] FOREIGN KEY ([ArticleId]) REFERENCES [dbo].[CatArticle] ([ArtId]),
    CONSTRAINT [FK_TypeImageByArticle_TypeOfImage] FOREIGN KEY ([TypeOfImageId]) REFERENCES [dbo].[CatTypeOfImage] ([IdTypeOfImage]),
    CONSTRAINT [Unique_TypeImageByArticle] UNIQUE NONCLUSTERED ([ArticleId] ASC, [TypeOfImageId] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de imagenes esperadas o relacionadas a tipo de artículo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TypeImageByArticle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TypeImageByArticle', @level2type = N'COLUMN', @level2name = N'IdTypeImageByArticle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del artículo de la tabla CatArticle.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TypeImageByArticle', @level2type = N'COLUMN', @level2name = N'ArticleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de imagen de la tabla CatTypeOfImage.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TypeImageByArticle', @level2type = N'COLUMN', @level2name = N'TypeOfImageId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si la imagen del registro es obligatorio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TypeImageByArticle', @level2type = N'COLUMN', @level2name = N'IsRequired';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TypeImageByArticle', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TypeImageByArticle', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TypeImageByArticle', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TypeImageByArticle', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TypeImageByArticle', @level2type = N'COLUMN', @level2name = N'DateUpdated';

