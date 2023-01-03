CREATE TABLE [dbo].[LinehaulRouteSettlementGuideDetail] (
    [IdLinehaulRouteSettlementGuideDetail] INT           IDENTITY (1, 1) NOT NULL,
    [LinehaulRouteSettlementId]            INT           NOT NULL,
    [GuideSerieReceived]                   NVARCHAR (2)  NOT NULL,
    [GuideNumberReceived]                  INT           NOT NULL,
    [GuidePiecesReceived]                  INT           NOT NULL,
    [GuidePiecesMissing]                   INT           NULL,
    [GuideReceived]                        BIT           NOT NULL,
    [RowStatus]                            BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]                         NVARCHAR (50) NOT NULL,
    [DateCreated]                          DATETIME      NOT NULL,
    [TokenUpdated]                         NVARCHAR (50) NULL,
    [DateUpdated]                          DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdLinehaulRouteSettlementGuideDetail] ASC),
    CONSTRAINT [FK_LinehaulRouteSettlementDetail_Guide] FOREIGN KEY ([GuideSerieReceived], [GuideNumberReceived]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_LinehaulRouteSettlementDetail_RouteSettlement] FOREIGN KEY ([LinehaulRouteSettlementId]) REFERENCES [dbo].[LinehaulRouteSettlement] ([IdLinehaulRouteSettlement])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementGuideDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementGuideDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementGuideDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementGuideDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementGuideDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de guías liquidadas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementGuideDetail', @level2type = N'COLUMN', @level2name = N'GuideReceived';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas faltantes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementGuideDetail', @level2type = N'COLUMN', @level2name = N'GuidePiecesMissing';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas liquidadas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementGuideDetail', @level2type = N'COLUMN', @level2name = N'GuidePiecesReceived';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía liquidada | Tabla Delivery Order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementGuideDetail', @level2type = N'COLUMN', @level2name = N'GuideNumberReceived';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía liquidada | Tabla DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementGuideDetail', @level2type = N'COLUMN', @level2name = N'GuideSerieReceived';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de encabzezado de liquidación de ruta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementGuideDetail', @level2type = N'COLUMN', @level2name = N'LinehaulRouteSettlementId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementGuideDetail', @level2type = N'COLUMN', @level2name = N'IdLinehaulRouteSettlementGuideDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de detalle de liquidación de ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementGuideDetail';

