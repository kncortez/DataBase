CREATE TABLE [dbo].[ContentTitle] (
    [IdContentTitle]     BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TypeContentId]      BIGINT         NOT NULL,
    [ContentTitle]       NVARCHAR (100) NOT NULL,
    [ContentDescription] NVARCHAR (500) NULL,
    [RowStatus]          BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]        DATETIME       NOT NULL,
    [TokenCreated]       NVARCHAR (50)  NOT NULL,
    [DateUpdated]        DATETIME       NULL,
    [TokenUpdated]       NVARCHAR (50)  NULL,
    [CountryId]          VARCHAR (2)    DEFAULT ('GT') NOT NULL,
    PRIMARY KEY CLUSTERED ([IdContentTitle] ASC),
    CONSTRAINT [FK_ContentTitle_CatTypeContent] FOREIGN KEY ([TypeContentId]) REFERENCES [dbo].[CatTypeContent] ([IdCatTypeContent])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentTitle', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentTitle', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentTitle', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentTitle', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentTitle', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del titulo de contenido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentTitle', @level2type = N'COLUMN', @level2name = N'ContentDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Titulo del contenido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentTitle', @level2type = N'COLUMN', @level2name = N'ContentTitle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de contenido de la tabla CatTypeContent.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentTitle', @level2type = N'COLUMN', @level2name = N'TypeContentId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentTitle', @level2type = N'COLUMN', @level2name = N'IdContentTitle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'País de origen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentTitle', @level2type = N'COLUMN', @level2name = N'CountryId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cabecera de contenido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentTitle';

