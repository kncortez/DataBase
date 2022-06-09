CREATE TABLE [dbo].[InvoiceLog] (
    [InvoiceLogId]      BIGINT         IDENTITY (1, 1) NOT NULL,
    [InvIdRestriction]  BIGINT         NOT NULL,
    [inv_pk_id]         BIGINT         NOT NULL,
    [inv_DataSent]      NVARCHAR (MAX) NULL,
    [inv_DataReceived]  NVARCHAR (MAX) NULL,
    [ErrorDesc]         NVARCHAR (MAX) NULL,
    [Date]              DATETIME       NOT NULL,
    [TransactionStatus] INT            NULL,
    PRIMARY KEY CLUSTERED ([InvoiceLogId] ASC),
    CONSTRAINT [FKIRestrictionInvoiceLog] FOREIGN KEY ([InvIdRestriction]) REFERENCES [dbo].[InvoiceRestriction] ([InvIdRestriction])
);

