CREATE TABLE [dbo].[LinehaulRouteSettlementContainerDetailPiece] (
    [IdLinehaulRouteSettlementContainerDetailPiece] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [LinehaulRouteSettlementContainerDetailId]      INT           NOT NULL,
    [PieceNumber]                                   INT           NOT NULL,
    [IsDryPiece]                                    INT           NOT NULL,
    [ActCode]                                       INT           NULL,
    [RowStatus]                                     BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]                                  NVARCHAR (50) NOT NULL,
    [DateCreated]                                   DATETIME      NOT NULL,
    [TokenUpdated]                                  NVARCHAR (50) NULL,
    [DateUpdated]                                   DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdLinehaulRouteSettlementContainerDetailPiece] ASC),
    CONSTRAINT [FK_LinehaulRouteSettlementContainerDetailPiece_RouteSettlement] FOREIGN KEY ([LinehaulRouteSettlementContainerDetailId]) REFERENCES [dbo].[LinehaulRouteSettlementContainerDetail] ([IdLinehaulRouteSettlementContainerDetail])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de acta de sustitución para piezas faltantes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'ActCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicador booleano de pieza seca', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'IsDryPiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Correlativo de pieza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'PieceNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de encabezado de guía en proceso de liquidación | Tabla LinehaulRouteSettlementContainerDetail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'LinehaulRouteSettlementContainerDetailId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'IdLinehaulRouteSettlementContainerDetailPiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de detalle de piezas en liquidación de ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementContainerDetailPiece';


GO
CREATE NONCLUSTERED INDEX [idx_LinehaulRouteSettlementContainerDetailId_PieceNumber]
    ON [dbo].[LinehaulRouteSettlementContainerDetailPiece]([LinehaulRouteSettlementContainerDetailId] ASC, [PieceNumber] ASC);

