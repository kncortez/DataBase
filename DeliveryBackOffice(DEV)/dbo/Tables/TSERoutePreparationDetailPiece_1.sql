CREATE TABLE [dbo].[TSERoutePreparationDetailPiece] (
    [IdTSERoutePreparationDetailPiece] BIGINT        IDENTITY (1, 1) NOT NULL,
    [TSERoutePreparationDetailId]      INT           NOT NULL,
    [PieceNumber]                      INT           NOT NULL,
    [RowStatus]                        BIT           DEFAULT ((1)) NOT NULL,
    [DateCreated]                      DATETIME      NOT NULL,
    [TokenCreated]                     NVARCHAR (50) NOT NULL,
    [DateUpdated]                      DATETIME      NULL,
    [TokenUpdated]                     NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([IdTSERoutePreparationDetailPiece] ASC),
    CONSTRAINT [FK_TSERoutePreparationDetailPiece_TSERoutePreparationDetail] FOREIGN KEY ([TSERoutePreparationDetailId]) REFERENCES [dbo].[TSERoutePreparationDetail] ([IDTSERoutePreparationDetail]),
    UNIQUE NONCLUSTERED ([TSERoutePreparationDetailId] ASC, [PieceNumber] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationDetailPiece', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationDetailPiece', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationDetailPiece', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationDetailPiece', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationDetailPiece', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de pieza de la guía procesada.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationDetailPiece', @level2type = N'COLUMN', @level2name = N'PieceNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la guía de la ruta de la tabla TSERoutePreparationDetail.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationDetailPiece', @level2type = N'COLUMN', @level2name = N'TSERoutePreparationDetailId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationDetailPiece', @level2type = N'COLUMN', @level2name = N'IdTSERoutePreparationDetailPiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Registro de piezas de guías procesadas de rutas especiales del TSE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationDetailPiece';

