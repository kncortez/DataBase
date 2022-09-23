CREATE TABLE [dbo].[LinehaulRouteSettlementContainerDetail] (
    [IdLinehaulRouteSettlementContainerDetail] INT           IDENTITY (1, 1) NOT NULL,
    [LinehaulRouteSettlementContainerId]       INT           NOT NULL,
    [GuideSerie]                               NVARCHAR (2)  NOT NULL,
    [GuideNumber]                              INT           NOT NULL,
    [PiecesReceived]                           INT           NOT NULL,
    [PiecesMissing]                            INT           NOT NULL,
    [GuideReceived]                            BIT           NOT NULL,
    [IsOpenProcess]                            INT           NOT NULL,
    [UserProcess]                              NVARCHAR (50) NULL,
    [RowStatus]                                BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]                             NVARCHAR (50) NOT NULL,
    [DateCreated]                              DATETIME      NOT NULL,
    [TokenUpdated]                             NVARCHAR (50) NULL,
    [DateUpdated]                              DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdLinehaulRouteSettlementContainerDetail] ASC),
    CONSTRAINT [FK_LinehaulRouteSettlementContainerDetail_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_LinehaulRouteSettlementContainerDetail_RouteSettlementContainer] FOREIGN KEY ([LinehaulRouteSettlementContainerId]) REFERENCES [dbo].[LinehaulRouteSettlementContainer] ([IdLinehaulRouteSettlementContainer])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario con proceso abierto activo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetail', @level2type = N'COLUMN', @level2name = N'UserProcess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicador booleano de guía recibida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetail', @level2type = N'COLUMN', @level2name = N'GuideReceived';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas perdidas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetail', @level2type = N'COLUMN', @level2name = N'PiecesMissing';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas recibidas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetail', @level2type = N'COLUMN', @level2name = N'PiecesReceived';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía asignada | Tabla DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetail', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía asignada | Tabla DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetail', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de encabezado de contenedor en liquidación | Tabla LinehaulRouteSettlementContainer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetail', @level2type = N'COLUMN', @level2name = N'LinehaulRouteSettlementContainerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetail', @level2type = N'COLUMN', @level2name = N'IdLinehaulRouteSettlementContainerDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de registro de guías asignadas a contenedores en liquidación de ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicador booleano de proceso abierto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetail', @level2type = N'COLUMN', @level2name = N'IsOpenProcess';

