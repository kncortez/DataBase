CREATE TABLE [dbo].[InvoiceBatchRelationships] (
    [Id_Lote]         INT           NULL,
    [CodeOfReference] INT           NULL,
    [RowStatus]       BIT           NOT NULL,
    [TokenCreated]    NVARCHAR (50) NOT NULL,
    [DateCreated]     DATETIME      NOT NULL,
    [TokenUpdated]    NVARCHAR (50) NULL,
    [DateUpdated]     DATETIME      NULL,
    [IdStation]       INT           NULL,
    CONSTRAINT [FK_InvoiceLoteBatchRelationships_InvoiceBatchHeader] FOREIGN KEY ([Id_Lote]) REFERENCES [dbo].[InvoiceBatchHeader] ([Id_Lote]),
    CONSTRAINT [FK_InvoiceLoteBatchRelationships_VisitPointClient] FOREIGN KEY ([CodeOfReference]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference]),
    CONSTRAINT [FK_InvoiceLoteBatchRL_CatStation] FOREIGN KEY ([IdStation]) REFERENCES [dbo].[CatStation] ([IdStation])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Relacion entre los lotes registrados y los puntos de venta registrados', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceBatchRelationships';

