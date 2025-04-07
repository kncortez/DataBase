CREATE TABLE [dbo].[LinehaulRouteSettlementContainer] (
    [IdLinehaulRouteSettlementContainer] INT           IDENTITY (1, 1) NOT NULL,
    [LinehaulRouteSettlementId]          INT           NOT NULL,
    [ContainerId]                        INT           NOT NULL,
    [HubId]                              INT           NOT NULL,
    [GuideQuantity]                      INT           NOT NULL,
    [DryPiecesQuantity]                  INT           NULL,
    [ColdPiecesQuantity]                 INT           NULL,
    [RowStatus]                          BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]                       NVARCHAR (50) NOT NULL,
    [DateCreated]                        DATETIME      NOT NULL,
    [TokenUpdated]                       NVARCHAR (50) NULL,
    [DateUpdated]                        DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdLinehaulRouteSettlementContainer] ASC),
    CONSTRAINT [FK_LinehaulRouteSettlementContainer_Container] FOREIGN KEY ([ContainerId]) REFERENCES [dbo].[Container] ([IdContainer]),
    CONSTRAINT [FK_LinehaulRouteSettlementContainer_Hub] FOREIGN KEY ([HubId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FK_LinehaulRouteSettlementContainer_RouteSettlement] FOREIGN KEY ([LinehaulRouteSettlementId]) REFERENCES [dbo].[LinehaulRouteSettlement] ([IdLinehaulRouteSettlement])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainer', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainer', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainer', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainer', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainer', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas frías asignadas al contenedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainer', @level2type = N'COLUMN', @level2name = N'ColdPiecesQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas secas asignadas al contenedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainer', @level2type = N'COLUMN', @level2name = N'DryPiecesQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de guías asignadas al contenedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainer', @level2type = N'COLUMN', @level2name = N'GuideQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID del contenedor asignado | Tabla Container', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainer', @level2type = N'COLUMN', @level2name = N'ContainerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de encabezado de liquidación | Tabla LinehaulRouteSettlement', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainer', @level2type = N'COLUMN', @level2name = N'LinehaulRouteSettlementId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainer', @level2type = N'COLUMN', @level2name = N'IdLinehaulRouteSettlementContainer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de registro de contenedores en liquidación de ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hub destino asignado | Tabla HubLogistics', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainer', @level2type = N'COLUMN', @level2name = N'HubId';


GO
CREATE NONCLUSTERED INDEX [idx_ContainerId_LinehaulRouteSettlementId]
    ON [dbo].[LinehaulRouteSettlementContainer]([ContainerId] ASC, [LinehaulRouteSettlementId] ASC);

