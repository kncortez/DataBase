CREATE TABLE [dbo].[TransferLog] (
    [IdTransferLog]   INT            IDENTITY (1, 1) NOT NULL,
    [IdCourier]       INT            NOT NULL,
    [CourierName]     NVARCHAR (50)  NOT NULL,
    [DPI]             NVARCHAR (50)  NULL,
    [IdIncidence]     INT            NULL,
    [IncidenceName]   VARCHAR (200)  NULL,
    [Comentary]       NVARCHAR (200) NULL,
    [GuideSerie]      NVARCHAR (2)   NOT NULL,
    [GuideNumber]     INT            NOT NULL,
    [TokenCreated]    NVARCHAR (50)  NOT NULL,
    [DateCreated]     DATETIME       NOT NULL,
    [TokenUpdate]     NVARCHAR (50)  NULL,
    [DateUpdate]      DATETIME       NULL,
    [CodeOfReference] INT            NULL,
    CONSTRAINT [Pk_TransferLog] PRIMARY KEY CLUSTERED ([IdTransferLog] ASC),
    FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_TransferLog_VisitPointClient] FOREIGN KEY ([CodeOfReference]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar log de transferencias de paquetes a express center.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransferLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla TransferLog.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransferLog', @level2type = N'COLUMN', @level2name = N'IdTransferLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de courier-man.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransferLog', @level2type = N'COLUMN', @level2name = N'IdCourier';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de courier-man.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransferLog', @level2type = N'COLUMN', @level2name = N'CourierName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DPI de courier-man.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransferLog', @level2type = N'COLUMN', @level2name = N'DPI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de incidencia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransferLog', @level2type = N'COLUMN', @level2name = N'IdIncidence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de incidencia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransferLog', @level2type = N'COLUMN', @level2name = N'IncidenceName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comentario.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransferLog', @level2type = N'COLUMN', @level2name = N'Comentary';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de guía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransferLog', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransferLog', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransferLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransferLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransferLog', @level2type = N'COLUMN', @level2name = N'TokenUpdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransferLog', @level2type = N'COLUMN', @level2name = N'DateUpdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Express center en donde se realizó el traslado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TransferLog', @level2type = N'COLUMN', @level2name = N'CodeOfReference';

