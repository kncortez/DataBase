CREATE TABLE [dbo].[ContentDetail] (
    [IdContentDetail]            BIGINT         IDENTITY (1, 1) NOT NULL,
    [ContentTitleId]             BIGINT         NOT NULL,
    [ContentDetailTitle]         NVARCHAR (100) NULL,
    [ContentDetailDescription]   NVARCHAR (500) NULL,
    [ContentDetailVideoURL]      NVARCHAR (500) NULL,
    [ContentDetailImageURL]      NVARCHAR (500) NULL,
    [ContentDetailPageURLButton] NVARCHAR (50)  NULL,
    [ContentDetailPageURL]       NVARCHAR (500) NULL,
    [RowStatus]                  BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]                DATETIME       NOT NULL,
    [TokenCreated]               NVARCHAR (50)  NOT NULL,
    [DateUpdated]                DATETIME       NULL,
    [TokenUpdated]               NVARCHAR (50)  NULL,
    [IsPageURLExternal]          BIT            CONSTRAINT [DF_ContentDetail_IsPageURLExternal] DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([IdContentDetail] ASC),
    CONSTRAINT [FK_ContentDetail_ContentTitle] FOREIGN KEY ([ContentTitleId]) REFERENCES [dbo].[ContentTitle] ([IdContentTitle])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'URL a donde el boton del contenido debe redireccionar.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetail', @level2type = N'COLUMN', @level2name = N'ContentDetailPageURL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Texto de boton que puede poseer el contenido, de estar NULL se considera que no lleva un boton.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetail', @level2type = N'COLUMN', @level2name = N'ContentDetailPageURLButton';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'URL de imagen que puede poseer el contenido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetail', @level2type = N'COLUMN', @level2name = N'ContentDetailImageURL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'URL de video que puede poseer el contenido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetail', @level2type = N'COLUMN', @level2name = N'ContentDetailVideoURL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cuerpo del contenido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetail', @level2type = N'COLUMN', @level2name = N'ContentDetailDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sub titulo del contenido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetail', @level2type = N'COLUMN', @level2name = N'ContentDetailTitle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la cabecera de contenido de la tabla ContentTitle.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetail', @level2type = N'COLUMN', @level2name = N'ContentTitleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetail', @level2type = N'COLUMN', @level2name = N'IdContentDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cuerpo de contenido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ContentDetail';

