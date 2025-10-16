CREATE TABLE [dbo].[LinehaulRoutePreparationActDetailPiece] (
    [IdLinehaulRoutePreparationActDetailPiece] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [LinehaulRoutePreparationActDetailId]      INT           NOT NULL,
    [PieceNumber]                              INT           NOT NULL,
    [IsDryPiece]                               BIT           DEFAULT ((1)) NOT NULL,
    [RowStatus]                                BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]                             NVARCHAR (50) NOT NULL,
    [DateCreated]                              DATETIME      NOT NULL,
    [TokenUpdated]                             NVARCHAR (50) NULL,
    [DateUpdated]                              DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdLinehaulRoutePreparationActDetailPiece] ASC),
    CONSTRAINT [FK_LinehaulRoutePreparationActDetailPiece_Guide] FOREIGN KEY ([LinehaulRoutePreparationActDetailId]) REFERENCES [dbo].[LinehaulRoutePreparationActDetail] ([IdLinehaulRoutePreparationActDetail]),
    CONSTRAINT [UQ_LinehualRoutePreparationActDetailPiece_GuidePiece] UNIQUE NONCLUSTERED ([LinehaulRoutePreparationActDetailId] ASC, [PieceNumber] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetailPiece', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetailPiece', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetailPiece', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetailPiece', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetailPiece', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es pieza seca (booleano)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetailPiece', @level2type = N'COLUMN', @level2name = N'IsDryPiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número correlativo de pieza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetailPiece', @level2type = N'COLUMN', @level2name = N'PieceNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de detalle de acta enlazado | Tabla LinehaulRoutePreparationActDetail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetailPiece', @level2type = N'COLUMN', @level2name = N'LinehaulRoutePreparationActDetailId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetailPiece', @level2type = N'COLUMN', @level2name = N'IdLinehaulRoutePreparationActDetailPiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de piezas asignadas a detalle de actas (justificaciones) en proceso de preparación de linehaul.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationActDetailPiece';

