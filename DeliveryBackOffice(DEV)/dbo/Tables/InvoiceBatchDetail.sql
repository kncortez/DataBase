

CREATE TABLE [dbo].[InvoiceBatchDetail]
(
	Id						INTEGER IDENTITY(1,1) NOT NULL,
	Id_Lote					INTEGER			NOT NULL,
	ProcessedCorrelative	VARCHAR(50)		NOT NULL,
	inv_pk_id				BIGINT			NOT NULL,
	[SendEmail]				BIT				NOT NULL,
	[RowStatus]				BIT             NOT NULL,
    [TokenCreated]      	NVARCHAR (50)   NOT NULL,
    [DateCreated]       	DATETIME        NOT NULL,
    [TokenUpdated]      	NVARCHAR (50)   NULL,
    [DateUpdated]       	DATETIME        NULL,

	CONSTRAINT [PK_InvoiceBathcDetail] PRIMARY KEY CLUSTERED ([Id_Lote], [ProcessedCorrelative] ASC),
	CONSTRAINT [FK_InvoiceBathcDetail_InvoiceBatchHeader] FOREIGN KEY ([Id_Lote]) REFERENCES [dbo].[InvoiceBatchHeader] ([Id_Lote]),
	CONSTRAINT [FK_InvoiceBathcDetail_InvoiceHeader] FOREIGN KEY ([inv_pk_id]) REFERENCES [dbo].[InvoiceHeader] ([inv_pk_id]),
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Factura ya procesada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceBatchDetail', @level2type = N'COLUMN', @level2name = N'ProcessedCorrelative';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Numero de factura generada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceBatchDetail', @level2type = N'COLUMN', @level2name = N'inv_pk_id';
