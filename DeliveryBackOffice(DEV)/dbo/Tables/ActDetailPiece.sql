CREATE TABLE [dbo].[ActDetailPiece] (
    [IdActDetailPiece] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ActDetailId]      INT           NOT NULL,
    [PieceNumber]      INT           NOT NULL,
    [IsDryPiece]       BIT           CONSTRAINT [DF__ActDetail__IsDry__4DD54A14] DEFAULT ((1)) NOT NULL,
    [RowStatus]        BIT           CONSTRAINT [DF__ActDetail__RowSt__4EC96E4D] DEFAULT ((1)) NOT NULL,
    [TokenCreated]     NVARCHAR (50) NOT NULL,
    [DateCreated]      DATETIME      NOT NULL,
    [TokenUpdated]     NVARCHAR (50) NULL,
    [DateUpdated]      DATETIME      NULL,
    [UserRevoke]       NVARCHAR (75) NULL,
    [DateRevoke]       DATETIME      NULL,
    CONSTRAINT [PK__ActDetai__EA4B46252BE4438C] PRIMARY KEY CLUSTERED ([IdActDetailPiece] ASC),
    CONSTRAINT [FK_ActDetailPiece_Guide] FOREIGN KEY ([ActDetailId]) REFERENCES [dbo].[ActDetail] ([IdActDetail]),
    CONSTRAINT [UQ_ActDetailPiece_GuidePiece] UNIQUE NONCLUSTERED ([ActDetailId] ASC, [PieceNumber] ASC)
);








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de registro de piezas de guías de actas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ActDetailPiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de usuario que revoco el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ActDetailPiece', @level2type = N'COLUMN', @level2name = N'UserRevoke';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ActDetailPiece', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ActDetailPiece', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ActDetailPiece', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de pieza.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ActDetailPiece', @level2type = N'COLUMN', @level2name = N'PieceNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si la pieza es fría o seca.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ActDetailPiece', @level2type = N'COLUMN', @level2name = N'IsDryPiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ActDetailPiece', @level2type = N'COLUMN', @level2name = N'IdActDetailPiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ActDetailPiece', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de revocación del registro, identifica si la pieza fue encontrada.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ActDetailPiece', @level2type = N'COLUMN', @level2name = N'DateRevoke';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ActDetailPiece', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del detalle (guía) de la tabla ActDetail.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ActDetailPiece', @level2type = N'COLUMN', @level2name = N'ActDetailId';

