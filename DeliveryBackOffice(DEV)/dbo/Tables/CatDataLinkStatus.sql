CREATE TABLE [dbo].[CatDataLinkStatus] (
    [IdCatDataLinkStatus]       INT            IDENTITY (1, 1) NOT NULL,
    [DataLinkStatusName]        NVARCHAR (50)  NOT NULL,
    [DataLinkStatusDescription] NVARCHAR (200) NULL,
    [RowStatus]                 BIT            CONSTRAINT [DF__CatDataLi__RowSt__3CD4DB44] DEFAULT ((1)) NOT NULL,
    [TokenCreated]              NVARCHAR (50)  NOT NULL,
    [DateCreated]               DATETIME       NOT NULL,
    [TokenUpdated]              NVARCHAR (50)  NULL,
    [DateUpdated]               DATETIME       NULL,
    CONSTRAINT [PK_CatDataLinkStatus] PRIMARY KEY CLUSTERED ([IdCatDataLinkStatus] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatDataLinkStatus', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatDataLinkStatus', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatDataLinkStatus', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatDataLinkStatus', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatDataLinkStatus', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del estado de link.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatDataLinkStatus', @level2type = N'COLUMN', @level2name = N'DataLinkStatusDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del estado de link.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatDataLinkStatus', @level2type = N'COLUMN', @level2name = N'DataLinkStatusName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatDataLinkStatus', @level2type = N'COLUMN', @level2name = N'IdCatDataLinkStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de estados de links para recopilación de datos.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatDataLinkStatus';

