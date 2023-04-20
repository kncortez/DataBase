CREATE TABLE [dbo].[ServiceDetailPiece] (
    [IdServiceDetailPiece] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ServiceDetailId]      BIGINT        NOT NULL,
    [PieceNumber]          INT           NOT NULL,
    [PieceType]            BIT           DEFAULT ((0)) NOT NULL,
    [RowStatus]            BIT           DEFAULT ((1)) NOT NULL,
    [DateCreated]          DATETIME      NOT NULL,
    [TokenCreated]         NVARCHAR (50) NOT NULL,
    [DateUpdated]          DATETIME      NULL,
    [TokenUpdated]         NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([IdServiceDetailPiece] ASC),
    CONSTRAINT [FK_ServiceDetailPiece_ServiceDetail] FOREIGN KEY ([ServiceDetailId]) REFERENCES [dbo].[ServiceDetail] ([IdServiceDetail])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetailPiece', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetailPiece', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetailPiece', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetailPiece', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetailPiece', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de pieza (0 = pieza fría, 1 = pieza seca).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetailPiece', @level2type = N'COLUMN', @level2name = N'PieceType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de pieza.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetailPiece', @level2type = N'COLUMN', @level2name = N'PieceNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del detalle del servicio de la tabla ServiceDetail.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetailPiece', @level2type = N'COLUMN', @level2name = N'ServiceDetailId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetailPiece', @level2type = N'COLUMN', @level2name = N'IdServiceDetailPiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para registro de piezas de una guía bajo un servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceDetailPiece';

