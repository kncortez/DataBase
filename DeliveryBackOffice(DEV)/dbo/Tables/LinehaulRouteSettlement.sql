CREATE TABLE [dbo].[LinehaulRouteSettlement] (
    [IdLinehaulRouteSettlement]      INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [LinehaulRoutePreparationId]     INT           NOT NULL,
    [UserReceived]                   NVARCHAR (50) NOT NULL,
    [DateReceived]                   DATETIME      NOT NULL,
    [ContainersReceived]             INT           NULL,
    [ToolsReceived]                  INT           NULL,
    [GuidesReceived]                 INT           NULL,
    [GuidePiecesReceived]            INT           NULL,
    [GuidePiecesMissing]             INT           NULL,
    [RowStatus]                      BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]                   NVARCHAR (50) NOT NULL,
    [DateCreated]                    DATETIME      NOT NULL,
    [TokenUpdated]                   NVARCHAR (50) NULL,
    [DateUpdated]                    DATETIME      NULL,
    [HubID]                          INT           NULL,
    [CatLinehaulStatusId]            INT           NOT NULL,
    [VehicleKms]                     INT           CONSTRAINT [DF_LinehaulRouteSettlement_VehicleKms] DEFAULT ((0)) NULL,
    [EndDateLinehaulRouteSettlement] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdLinehaulRouteSettlement] ASC),
    CONSTRAINT [FK_LinehaulRouteSettlement_CatLinehaulStatus] FOREIGN KEY ([CatLinehaulStatusId]) REFERENCES [dbo].[CatLinehaulStatus] ([IdCatLinehaulStatus]),
    CONSTRAINT [FK_LinehaulRouteSettlement_Hub] FOREIGN KEY ([HubID]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FK_LinehaulRouteSettlement_LinehaulRoutePreparation] FOREIGN KEY ([LinehaulRoutePreparationId]) REFERENCES [dbo].[LinehaulRoutePreparation] ([IdLinehaulRoutePreparation])
);














GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'DateUpdated';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'TokenUpdated';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'DateCreated';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas faltantes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'GuidePiecesMissing';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas liquidadas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'GuidePiecesReceived';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de guías liquidadas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'GuidesReceived';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de herramientas liquidadas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'ToolsReceived';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de contenedores liquidados', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'ContainersReceived';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de liquidación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'DateReceived';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario liquidador', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'UserReceived';


GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de preparación de ruta enlazada | Tabla LinehaulRoutePreparation', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'LinehaulRoutePreparationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'IdLinehaulRouteSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de registro de liquidación de ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de HUB liquidador | Tabla HubLogistics', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'HubID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de estado | Tabla CatLinehaulStatus', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'CatLinehaulStatusId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Registro de kilometraje de salida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'VehicleKms';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de finalización de despacho', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'EndDateLinehaulRouteSettlement';

