CREATE TABLE [dbo].[HistoricalSAPInvoice] (
    [HistoricalSAPInvoiceId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [inv_pk_id]              BIGINT        NOT NULL,
    [inv_certificationFEL]   VARCHAR (200) NULL,
    [inv_serieFEL]           VARCHAR (200) NULL,
    [inv_numberFEL]          VARCHAR (50)  NULL,
    [inv_SAPDocEntry]        INT           NULL,
    [inv_SAPError]           VARCHAR (300) NULL,
    [TransactionDate]        DATETIME      NOT NULL,
    [TransactionStatus]      BIT           NULL,
    PRIMARY KEY CLUSTERED ([HistoricalSAPInvoiceId] ASC),
    CONSTRAINT [FK_Historical_inv_pk_id] FOREIGN KEY ([inv_pk_id]) REFERENCES [dbo].[invoiceHeader] ([inv_pk_id])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id para la tabla HistoricalSAPInvoice ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HistoricalSAPInvoice', @level2type = N'COLUMN', @level2name = N'HistoricalSAPInvoiceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id primario de la tabla invoiceDetail  ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HistoricalSAPInvoice', @level2type = N'COLUMN', @level2name = N'inv_pk_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es el número de serie de la factura electrónica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HistoricalSAPInvoice', @level2type = N'COLUMN', @level2name = N'inv_serieFEL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es el número de factura electrónica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HistoricalSAPInvoice', @level2type = N'COLUMN', @level2name = N'inv_numberFEL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es el número de documento registrado en SAP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HistoricalSAPInvoice', @level2type = N'COLUMN', @level2name = N'inv_SAPDocEntry';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es el error retornado por SAP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HistoricalSAPInvoice', @level2type = N'COLUMN', @level2name = N'inv_SAPError';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es la fecha en que se registro la factura en SAP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HistoricalSAPInvoice', @level2type = N'COLUMN', @level2name = N'TransactionDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es estatus del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HistoricalSAPInvoice', @level2type = N'COLUMN', @level2name = N'TransactionStatus';


GO
CREATE NONCLUSTERED INDEX [idx_inv_certificationFEL]
    ON [dbo].[HistoricalSAPInvoice]([inv_certificationFEL] ASC);

