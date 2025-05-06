CREATE TABLE [dbo].[LinehaulRouteSettlementToolDetail] (
    [IdLinehaulRouteSettlementToolDetail] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [LinehaulRouteSettlementId]           INT           NOT NULL,
    [ToolId]                              INT           NOT NULL,
    [ToolReceived]                        BIT           NOT NULL,
    [RowStatus]                           BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]                        NVARCHAR (50) NOT NULL,
    [DateCreated]                         DATETIME      NOT NULL,
    [TokenUpdated]                        NVARCHAR (50) NULL,
    [DateUpdated]                         DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdLinehaulRouteSettlementToolDetail] ASC),
    CONSTRAINT [FK_LinehaulRouteSettlementToolDetail_RouteSettlement] FOREIGN KEY ([LinehaulRouteSettlementId]) REFERENCES [dbo].[LinehaulRouteSettlement] ([IdLinehaulRouteSettlement]),
    CONSTRAINT [FK_LinehaulRouteSettlementToolDetail_Tool] FOREIGN KEY ([ToolId]) REFERENCES [dbo].[Tool] ([IdTool])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementToolDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementToolDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementToolDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementToolDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementToolDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Se recibió la herramienta (booleano)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementToolDetail', @level2type = N'COLUMN', @level2name = N'ToolReceived';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la herramienta enlazada | Tabla Tool', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementToolDetail', @level2type = N'COLUMN', @level2name = N'ToolId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de encabezado de liquidación de ruta | Tabla LinehaulRouteSettlement', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementToolDetail', @level2type = N'COLUMN', @level2name = N'LinehaulRouteSettlementId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementToolDetail', @level2type = N'COLUMN', @level2name = N'IdLinehaulRouteSettlementToolDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de detalle de herramientas en liquidación de ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRouteSettlementToolDetail';

