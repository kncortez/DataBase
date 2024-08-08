CREATE TABLE [dbo].[InvoiceBatchRelationships] (
    [Id_Lote]         INT           NOT NULL,
    [CodeOfReference] INT           NOT NULL,
    [RowStatus]       BIT           NOT NULL,
    [TokenCreated]    NVARCHAR (50) NOT NULL,
    [DateCreated]     DATETIME      NOT NULL,
    [TokenUpdated]    NVARCHAR (50) NULL,
    [DateUpdated]     DATETIME      NULL,
    CONSTRAINT [PK_InvoiceBatchRelationships] PRIMARY KEY CLUSTERED ([Id_Lote] ASC, [CodeOfReference] ASC),
    CONSTRAINT [FK_InvoiceLoteBatchRelationships_InvoiceBatchHeader] FOREIGN KEY ([Id_Lote]) REFERENCES [dbo].[InvoiceBatchHeader] ([Id_Lote]),
    CONSTRAINT [FK_InvoiceLoteBatchRelationships_VisitPointClient] FOREIGN KEY ([CodeOfReference]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);

