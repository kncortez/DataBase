CREATE TABLE [dbo].[ZPLFilesStatusLog] (
    [IdZPLFilesStatusLog] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [IdCustomer]          INT            NOT NULL,
    [TicketNumber]        NVARCHAR (150) NOT NULL,
    [FileName]            NVARCHAR (100) NOT NULL,
    [IsDeleted]           BIT            DEFAULT ((0)) NOT NULL,
    [IsProcessed]         BIT            DEFAULT ((0)) NOT NULL,
    [JobId]               NVARCHAR (75)  DEFAULT ('') NOT NULL,
    [GuideSerie]          NVARCHAR (2)   NOT NULL,
    [GuideNumber]         INT            NOT NULL,
    [DateCreatedQueue]    DATETIME       DEFAULT (sysdatetime()) NOT NULL,
    [TokenCreated]        NVARCHAR (50)  DEFAULT ('') NOT NULL,
    [DateCreated]         DATETIME       DEFAULT (sysdatetime()) NOT NULL,
    [TokenUpdated]        NVARCHAR (50)  NULL,
    [DateUpdated]         DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdZPLFilesStatusLog] ASC),
    CONSTRAINT [FK_ZPLFilesStatusLog_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]) ON DELETE CASCADE,
    CONSTRAINT [FK_ZPLFilesStatusLog_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IDX_ZPLFilesStatusLog_GuideSerie_GuideNumber]
    ON [dbo].[ZPLFilesStatusLog]([GuideSerie] ASC, [GuideNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_ZPLFilesStatusLog_FileName]
    ON [dbo].[ZPLFilesStatusLog]([FileName] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZPLFilesStatusLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZPLFilesStatusLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZPLFilesStatusLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZPLFilesStatusLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ingreso a cola SQS', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZPLFilesStatusLog', @level2type = N'COLUMN', @level2name = N'DateCreatedQueue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZPLFilesStatusLog', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZPLFilesStatusLog', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de Job', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZPLFilesStatusLog', @level2type = N'COLUMN', @level2name = N'JobId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ya fue procesado en S3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZPLFilesStatusLog', @level2type = N'COLUMN', @level2name = N'IsProcessed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fue eliminado de S3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZPLFilesStatusLog', @level2type = N'COLUMN', @level2name = N'IsDeleted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de archivo en S3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZPLFilesStatusLog', @level2type = N'COLUMN', @level2name = N'FileName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de ticket', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZPLFilesStatusLog', @level2type = N'COLUMN', @level2name = N'TicketNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZPLFilesStatusLog', @level2type = N'COLUMN', @level2name = N'IdCustomer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZPLFilesStatusLog', @level2type = N'COLUMN', @level2name = N'IdZPLFilesStatusLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Registro histórico de archivos ZPL procesados', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZPLFilesStatusLog';

