CREATE TABLE [dbo].[InvoiceBatchDetailLinehaul] (
    [IdInvoiceBatchDetailLinehaul] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [IdBatch]                      INT           NOT NULL,
    [ProcessedCorrelative]         VARCHAR (50)  NOT NULL,
    [LinehaulRoutePreparationId]   INT           NOT NULL,
    [SendManifest]                 BIT           NOT NULL,
    [RowStatus]                    BIT           NOT NULL,
    [TokenCreated]                 NVARCHAR (50) NOT NULL,
    [DateCreated]                  DATETIME      NOT NULL,
    [TokenUpdated]                 NVARCHAR (50) NULL,
    [DateUpdated]                  DATETIME      NULL,
    CONSTRAINT [PK_InvoiceBathcDetailLH] PRIMARY KEY CLUSTERED ([IdBatch] ASC, [ProcessedCorrelative] ASC),
    CONSTRAINT [FK_InvoiceBathcDetailLH_InvoiceBatchHeader] FOREIGN KEY ([IdBatch]) REFERENCES [dbo].[InvoiceBatchHeader] ([Id_Lote]),
    CONSTRAINT [FK_InvoiceBathcDetailLH_LinehaulRoutePreparation] FOREIGN KEY ([LinehaulRoutePreparationId]) REFERENCES [dbo].[LinehaulRoutePreparation] ([IdLinehaulRoutePreparation])
);

