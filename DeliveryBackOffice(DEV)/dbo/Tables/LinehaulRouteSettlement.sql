CREATE TABLE [dbo].[LinehaulRouteSettlement] (
    [IdLinehaulRouteSettlement]  INT           IDENTITY (1, 1) NOT NULL,
    [LinehaulRoutePreparationId] INT           NOT NULL,
    [StationReceivedId]          INT           NULL,
    [UserReceived]               NVARCHAR (50) NOT NULL,
    [DateReceived]               DATETIME      NOT NULL,
    [ContainersReceived]         INT           NULL,
    [ToolsReceived]              INT           NULL,
    [GuidesReceived]             INT           NULL,
    [GuidePiecesReceived]        INT           NULL,
    [GuidePiecesMissing]         INT           NULL,
    [ActCode]                    NVARCHAR (50) NULL,
    [RowStatus]                  BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]               NVARCHAR (50) NOT NULL,
    [DateCreated]                DATETIME      NOT NULL,
    [TokenUpdated]               NVARCHAR (50) NULL,
    [DateUpdated]                DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdLinehaulRouteSettlement] ASC),
    CONSTRAINT [FK_LinehaulRouteSettlement_LinehaulRoutePreparation] FOREIGN KEY ([LinehaulRoutePreparationId]) REFERENCES [dbo].[LinehaulRoutePreparation] ([IdLinehaulRoutePreparation]),
    CONSTRAINT [FK_LinehaulRouteSettlement_Station] FOREIGN KEY ([StationReceivedId]) REFERENCES [dbo].[CatStation] ([IdStation])
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
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de acta (justificación) asignada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'ActCode';


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
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de estación liquidadora | Tabla CatStation', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'StationReceivedId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de preparación de ruta enlazada | Tabla LinehaulRoutePreparation', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'LinehaulRoutePreparationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement', @level2type = N'COLUMN', @level2name = N'IdLinehaulRouteSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de registro de liquidación de ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlement';



