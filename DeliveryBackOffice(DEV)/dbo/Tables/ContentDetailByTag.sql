CREATE TABLE [dbo].[ContentDetailByTag] (
    [IdContentDetailByTag] BIGINT        IDENTITY (1, 1) NOT NULL,
    [TagContentId]         BIGINT        NOT NULL,
    [ContentDetailId]      BIGINT        NOT NULL,
    [RowStatus]            BIT           DEFAULT ((1)) NOT NULL,
    [DateCreated]          DATETIME      NOT NULL,
    [TokenCreated]         NVARCHAR (50) NOT NULL,
    [DateUpdated]          DATETIME      NULL,
    [TokenUpdated]         NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([IdContentDetailByTag] ASC),
    CONSTRAINT [FK_ContentDetailByTag_CatTagContent] FOREIGN KEY ([TagContentId]) REFERENCES [dbo].[CatTagContent] ([IdCatTagContent]),
    CONSTRAINT [FK_ContentDetailByTag_ContentDetail] FOREIGN KEY ([ContentDetailId]) REFERENCES [dbo].[ContentDetail] ([IdContentDetail]),
    UNIQUE NONCLUSTERED ([TagContentId] ASC, [ContentDetailId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetailByTag', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetailByTag', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetailByTag', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetailByTag', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetailByTag', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del contenido de la tabla ContentDetail.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetailByTag', @level2type = N'COLUMN', @level2name = N'ContentDetailId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la etiqueta de la tabla CatTagContent.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetailByTag', @level2type = N'COLUMN', @level2name = N'TagContentId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetailByTag', @level2type = N'COLUMN', @level2name = N'IdContentDetailByTag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para relacionar etiquetas con cuerpo de contenido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetailByTag';

