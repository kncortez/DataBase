CREATE TABLE [dbo].[InvoiceBatchDetail] (
    [Id]                   INT           IDENTITY (1, 1) NOT NULL,
    [Id_Lote]              INT           NOT NULL,
    [ProcessedCorrelative] VARCHAR (50)  NOT NULL,
    [inv_pk_id]            BIGINT        NOT NULL,
    [SendEmail]            BIT           NOT NULL,
    [RowStatus]            BIT           NOT NULL,
    [TokenCreated]         NVARCHAR (50) NOT NULL,
    [DateCreated]          DATETIME      NOT NULL,
    [TokenUpdated]         NVARCHAR (50) NULL,
    [DateUpdated]          DATETIME      NULL,
    CONSTRAINT [PK_InvoiceBathcDetail] PRIMARY KEY CLUSTERED ([Id_Lote] ASC, [ProcessedCorrelative] ASC, [inv_pk_id] ASC),
    CONSTRAINT [FK_InvoiceBathcDetail_InvoiceBatchHeader] FOREIGN KEY ([Id_Lote]) REFERENCES [dbo].[InvoiceBatchHeader] ([Id_Lote]),
    CONSTRAINT [FK_InvoiceBathcDetail_InvoiceHeader] FOREIGN KEY ([inv_pk_id]) REFERENCES [dbo].[invoiceHeader] ([inv_pk_id])
);

