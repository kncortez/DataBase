CREATE TABLE [dbo].[UnifiedRouteSettlementDetailPiece] (
    [IdUnifiedRouteSettlementDetailPiece] INT           IDENTITY (1, 1) NOT NULL,
    [UnifiedRouteSettlementDetailId]      INT           NOT NULL,
    [PieceNumber]                         INT           NOT NULL,
    [IsDryPiece]                          BIT           DEFAULT ((1)) NOT NULL,
    [ActCode]                             INT           NULL,
    [RowStatus]                           BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]                        NVARCHAR (50) NOT NULL,
    [DateCreated]                         DATETIME      NOT NULL,
    [TokenUpdated]                        NVARCHAR (50) NULL,
    [DateUpdated]                         DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdUnifiedRouteSettlementDetailPiece] ASC),
    CONSTRAINT [FK_UnifiedRouteSettlementDetailPiece_Act] FOREIGN KEY ([ActCode]) REFERENCES [dbo].[Act] ([IdAct]),
    CONSTRAINT [FK_UnifiedRouteSettlementDetailPiece_UnifiedRouteSettlementDetail] FOREIGN KEY ([UnifiedRouteSettlementDetailId]) REFERENCES [dbo].[UnifiedRouteSettlementDetail] ([IdUnifiedRouteSettlementDetail])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetailPiece', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetailPiece', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetailPiece', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetailPiece', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetailPiece', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del acta donde se justifico pieza perdida.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetailPiece', @level2type = N'COLUMN', @level2name = N'ActCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la pieza es fría o seca.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetailPiece', @level2type = N'COLUMN', @level2name = N'IsDryPiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de pieza de la guía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetailPiece', @level2type = N'COLUMN', @level2name = N'PieceNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del detalle al que pertenece la pieza de la tabla UnifiedRouteSettlementDetail.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetailPiece', @level2type = N'COLUMN', @level2name = N'UnifiedRouteSettlementDetailId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetailPiece', @level2type = N'COLUMN', @level2name = N'IdUnifiedRouteSettlementDetailPiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Detalle de piezas de guías en liquidación de ruta  unificada.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UnifiedRouteSettlementDetailPiece';

