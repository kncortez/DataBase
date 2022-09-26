CREATE TABLE [dbo].[LinehaulRoutePreparationContainer] (
    [IdLinehaulRoutePreparationContainer] INT           IDENTITY (1, 1) NOT NULL,
    [LinehaulRoutePreparationId]          INT           NOT NULL,
    [ContainerId]                         INT           NOT NULL,
    [HubDestinyId]                        INT           NULL,
    [GuideQuantity]                       INT           NOT NULL,
    [DryPieceQuantity]                    INT           NOT NULL,
    [ColdPieceQuantity]                   INT           NOT NULL,
    [RowStatus]                           BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]                        NVARCHAR (50) NOT NULL,
    [DateCreated]                         DATETIME      NOT NULL,
    [TokenUpdated]                        NVARCHAR (50) NULL,
    [DateUpdated]                         DATETIME      NULL,
    [CatLinehaulStatusId]                 INT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdLinehaulRoutePreparationContainer] ASC),
    CONSTRAINT [FK_LinehaulRoutePreparationContainer_Container] FOREIGN KEY ([ContainerId]) REFERENCES [dbo].[Container] ([IdContainer]),
    CONSTRAINT [FK_LinehaulRoutePreparationContainer_HubLogistics] FOREIGN KEY ([HubDestinyId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FK_LinehaulRoutePreparationContainer_RoutePreparation] FOREIGN KEY ([LinehaulRoutePreparationId]) REFERENCES [dbo].[LinehaulRoutePreparation] ([IdLinehaulRoutePreparation]),
    CONSTRAINT [UQ_LinehaulRoutePreparation_Container] UNIQUE NONCLUSTERED ([LinehaulRoutePreparationId] ASC, [ContainerId] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainer', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainer', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainer', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainer', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainer', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas frías asignadas al contenedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainer', @level2type = N'COLUMN', @level2name = N'ColdPieceQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas secas asignadas al contenedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainer', @level2type = N'COLUMN', @level2name = N'DryPieceQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de guías asignadas al contenedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainer', @level2type = N'COLUMN', @level2name = N'GuideQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID del HUB destino asignado | Tabla HubLogistics', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainer', @level2type = N'COLUMN', @level2name = N'HubDestinyId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID del contenedor enlazado | Tabla Container', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainer', @level2type = N'COLUMN', @level2name = N'ContainerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de preparación de ruta enlazada | Tabla LinehaulRoutePreparation', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainer', @level2type = N'COLUMN', @level2name = N'LinehaulRoutePreparationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainer', @level2type = N'COLUMN', @level2name = N'IdLinehaulRoutePreparationContainer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de registro de contenedores asignados a preparación de ruta de linehaul.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID del status asignado | Tabla CatLinehaulStatus', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainer', @level2type = N'COLUMN', @level2name = N'CatLinehaulStatusId';

