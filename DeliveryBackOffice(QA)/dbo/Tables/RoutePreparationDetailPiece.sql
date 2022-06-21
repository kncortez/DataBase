CREATE TABLE [dbo].[RoutePreparationDetailPiece] (
    [IdRoutePreparationDetailPiece] INT           IDENTITY (1, 1) NOT NULL,
    [RoutePreparationDetailId]      INT           NOT NULL,
    [PieceNumber]                   INT           NOT NULL,
    [PieceType]                     BIT           NOT NULL,
    [RowStatus]                     BIT           NOT NULL,
    [TokenCreated]                  NVARCHAR (50) NOT NULL,
    [DateCreated]                   DATETIME      NOT NULL,
    [TokenUpdated]                  NVARCHAR (50) NULL,
    [DateUpdated]                   DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdRoutePreparationDetailPiece] ASC),
    CONSTRAINT [FK_RoutePreparationDetailPiece_RoutePreparationDetail] FOREIGN KEY ([RoutePreparationDetailId]) REFERENCES [dbo].[RoutePreparationDetail] ([IdRoutePreparationDetail])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar el detalle de piezas de las guías de la preparación de entregas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetailPiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetailPiece', @level2type = N'COLUMN', @level2name = N'IdRoutePreparationDetailPiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla RoutePreparationDetail.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetailPiece', @level2type = N'COLUMN', @level2name = N'RoutePreparationDetailId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de pieza.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetailPiece', @level2type = N'COLUMN', @level2name = N'PieceNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la pieza es fría(0) o seca(1).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetailPiece', @level2type = N'COLUMN', @level2name = N'PieceType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetailPiece', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetailPiece', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetailPiece', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que modificó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetailPiece', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetailPiece', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
CREATE NONCLUSTERED INDEX [idx_RowStatus]
    ON [dbo].[RoutePreparationDetailPiece]([RowStatus] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_PieceNumber_RowStatus]
    ON [dbo].[RoutePreparationDetailPiece]([PieceNumber] ASC, [RowStatus] ASC)
    INCLUDE([RoutePreparationDetailId]);

