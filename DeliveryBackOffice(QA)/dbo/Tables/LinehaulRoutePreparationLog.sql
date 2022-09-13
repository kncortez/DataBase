CREATE TABLE [dbo].[LinehaulRoutePreparationLog] (
    [IdLinehaulRoutePreparationLog]               INT            IDENTITY (1, 1) NOT NULL,
    [OriginStationLogId]                          INT            NOT NULL,
    [OriginLinehaulRoutePreparationId]            INT            NOT NULL,
    [OriginLinehaulRoutePreparationContainerId]   INT            NULL,
    [OriginLinehaulRoutePreparationCustomsMarkId] INT            NULL,
    [FinalLinehaulRoutePreparationId]             INT            NULL,
    [FinalLinehaulRoutePreparationContainerId]    INT            NULL,
    [GuideSerie]                                  NVARCHAR (2)   NULL,
    [GuideNumber]                                 INT            NULL,
    [GuidePiece]                                  INT            NULL,
    [ToolId]                                      INT            NULL,
    [LogDescription]                              NVARCHAR (200) NOT NULL,
    [RowStatus]                                   BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]                                NVARCHAR (50)  NOT NULL,
    [DateCreated]                                 DATETIME       NOT NULL,
    [TokenUpdated]                                NVARCHAR (50)  NULL,
    [DateUpdated]                                 DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdLinehaulRoutePreparationLog] ASC),
    CONSTRAINT [FK_LinehaulRoutePreparationLog_Guide] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_LinehaulRoutePreparationLog_LinehaulRoutePreparationContainerFinal] FOREIGN KEY ([FinalLinehaulRoutePreparationContainerId]) REFERENCES [dbo].[LinehaulRoutePreparationContainer] ([IdLinehaulRoutePreparationContainer]),
    CONSTRAINT [FK_LinehaulRoutePreparationLog_LinehaulRoutePreparationContainerOrigin] FOREIGN KEY ([OriginLinehaulRoutePreparationContainerId]) REFERENCES [dbo].[LinehaulRoutePreparationContainer] ([IdLinehaulRoutePreparationContainer]),
    CONSTRAINT [FK_LinehaulRoutePreparationLog_LinehaulRoutePreparationCustomsMark] FOREIGN KEY ([OriginLinehaulRoutePreparationCustomsMarkId]) REFERENCES [dbo].[LinehaulRoutePreparationCustomsMark] ([IdLinehaulRoutePreparationCustomsMark]),
    CONSTRAINT [FK_LinehaulRoutePreparationLog_LinehaulRoutePreparationFinal] FOREIGN KEY ([FinalLinehaulRoutePreparationId]) REFERENCES [dbo].[LinehaulRoutePreparation] ([IdLinehaulRoutePreparation]),
    CONSTRAINT [FK_LinehaulRoutePreparationLog_LinehaulRoutePreparationOrigin] FOREIGN KEY ([OriginLinehaulRoutePreparationId]) REFERENCES [dbo].[LinehaulRoutePreparation] ([IdLinehaulRoutePreparation]),
    CONSTRAINT [FK_LinehaulRoutePreparationLog_LinehaulRoutePreparationTool] FOREIGN KEY ([ToolId]) REFERENCES [dbo].[Tool] ([IdTool]),
    CONSTRAINT [FK_LinehaulRoutePreparationLog_Station] FOREIGN KEY ([OriginStationLogId]) REFERENCES [dbo].[CatStation] ([IdStation])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationLog', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del LOG', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationLog', @level2type = N'COLUMN', @level2name = N'LogDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de herramienta enlazada | Tabla Tool', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationLog', @level2type = N'COLUMN', @level2name = N'ToolId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número correlativo de pieza en guía enlazada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationLog', @level2type = N'COLUMN', @level2name = N'GuidePiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía enlazada | Tabla DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationLog', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de guía enlazada | Tabla DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationLog', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de contenedor final | Tabla LinehaulRoutePreparationContainer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationLog', @level2type = N'COLUMN', @level2name = N'FinalLinehaulRoutePreparationContainerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de proceso de preparacion de ruta final | Tabla LinehaulRoutePreparation', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationLog', @level2type = N'COLUMN', @level2name = N'FinalLinehaulRoutePreparationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de marchamo asignado en origen | Tabla LinehaulRoutePreparationCustomsMark', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationLog', @level2type = N'COLUMN', @level2name = N'OriginLinehaulRoutePreparationCustomsMarkId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de contenedor de origen | Tabla LinehaulRoutePreparationContainer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationLog', @level2type = N'COLUMN', @level2name = N'OriginLinehaulRoutePreparationContainerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de proceso de origen de Preparación de linehaul | Tabla LinehaulRoutePreparation', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationLog', @level2type = N'COLUMN', @level2name = N'OriginLinehaulRoutePreparationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de estación de origen | Tabla CatStation', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationLog', @level2type = N'COLUMN', @level2name = N'OriginStationLogId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationLog', @level2type = N'COLUMN', @level2name = N'IdLinehaulRoutePreparationLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de registro de logs de procesos y transacciones en preparación, despacho y liquidación de ruta de linehaul.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationLog';

