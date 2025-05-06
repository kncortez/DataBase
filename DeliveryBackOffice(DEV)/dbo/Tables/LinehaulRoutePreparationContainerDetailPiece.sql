CREATE TABLE [dbo].[LinehaulRoutePreparationContainerDetailPiece] (
    [IdLinehaulRoutePreparationContainerDetailPiece] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [LinehaulRoutePreparationContainerDetailId]      INT           NOT NULL,
    [PieceNumber]                                    INT           NOT NULL,
    [IsDryPiece]                                     BIT           DEFAULT ((1)) NOT NULL,
    [ActCode]                                        NVARCHAR (50) NULL,
    [RowStatus]                                      BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]                                   NVARCHAR (50) NOT NULL,
    [DateCreated]                                    DATETIME      NOT NULL,
    [TokenUpdated]                                   NVARCHAR (50) NULL,
    [DateUpdated]                                    DATETIME      NULL,
    [CatLinehaulStatusId]                            INT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdLinehaulRoutePreparationContainerDetailPiece] ASC),
    CONSTRAINT [FK_LinehaulRoutePreparationContainerDetailPiece_Guide] FOREIGN KEY ([LinehaulRoutePreparationContainerDetailId]) REFERENCES [dbo].[LinehaulRoutePreparationContainerDetail] ([IdLinehaulRoutePreparationContainerDetail]),
    CONSTRAINT [UQ_LinehualRoutePreparation_GuidePiece] UNIQUE NONCLUSTERED ([LinehaulRoutePreparationContainerDetailId] ASC, [PieceNumber] ASC)
);














GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de acta de justificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'ActCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es pieza seca (Booleano)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'IsDryPiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número correlativo de pieza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'PieceNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de detalle de contenedor enlazado | Tabla LinehaulRoutePreparationContainerDetail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'LinehaulRoutePreparationContainerDetailId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'IdLinehaulRoutePreparationContainerDetailPiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de detalle de piezas asignadas a contenedor en preparación de ruta de linehaul.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainerDetailPiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID del status asignado | Tabla CatLinehaulStatus', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LinehaulRoutePreparationContainerDetailPiece', @level2type = N'COLUMN', @level2name = N'CatLinehaulStatusId';


GO


