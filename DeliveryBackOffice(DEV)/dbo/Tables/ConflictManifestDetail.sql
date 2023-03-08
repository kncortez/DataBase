CREATE TABLE [dbo].[ConflictManifestDetail] (
    [IdConflictManifestDetail] INT             IDENTITY (1, 1) NOT NULL,
    [ConflictManifestId]       BIGINT          NOT NULL,
    [GuideSerie]               NVARCHAR (2)    NOT NULL,
    [GuideNumber]              INT             NOT NULL,
    [GuidePrice]               DECIMAL (18, 2) NOT NULL,
    [RowStatus]                BIT             CONSTRAINT [DF_ConflictManifestDetail_RowStatus] DEFAULT ((0)) NOT NULL,
    [TokenCreated]             NVARCHAR (50)   NOT NULL,
    [DateCreated]              DATETIME        NOT NULL,
    [TokenUpdated]             NVARCHAR (50)   NULL,
    [DateUpdated]              DATETIME        NULL,
    CONSTRAINT [PK_ConflictManifestDetail] PRIMARY KEY CLUSTERED ([IdConflictManifestDetail] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConflictManifestDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de creación ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConflictManifestDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConflictManifestDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConflictManifestDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precio de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConflictManifestDetail', @level2type = N'COLUMN', @level2name = N'GuidePrice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConflictManifestDetail', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'serie de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConflictManifestDetail', @level2type = N'COLUMN', @level2name = N'GuideSerie';

