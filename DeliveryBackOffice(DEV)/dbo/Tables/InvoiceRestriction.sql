CREATE TABLE [dbo].[InvoiceRestriction] (
    [InvIdRestriction] BIGINT       IDENTITY (1, 1) NOT NULL,
    [inv_pk_id]        BIGINT       NOT NULL,
    [inv_SAPDocEntry]  INT          NOT NULL,
    [invRetries]       INT          NOT NULL,
    [invRowStatus]     BIT          NOT NULL,
    [invTokenCreated]  VARCHAR (50) NOT NULL,
    [invDateCreated]   DATETIME     NOT NULL,
    [invOperationDate] DATETIME     NOT NULL,
    PRIMARY KEY CLUSTERED ([InvIdRestriction] ASC),
    CONSTRAINT [FKInvoiceHeader] FOREIGN KEY ([inv_pk_id]) REFERENCES [dbo].[invoiceHeader] ([inv_pk_id])
);




GO
CREATE NONCLUSTERED INDEX [idx_inv_pk_id]
    ON [dbo].[InvoiceRestriction]([inv_pk_id] ASC);

