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




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que almacena el historial de operaciones para facturas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor que representa el estado del registro log', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceLog', @level2type = N'COLUMN', @level2name = N'TransactionStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador unico para los logs de facturas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceLog', @level2type = N'COLUMN', @level2name = N'InvoiceLogId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de restriccion aplicada al registro almacenado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceLog', @level2type = N'COLUMN', @level2name = N'InvIdRestriction';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador asociado a la factura con el registro log', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceLog', @level2type = N'COLUMN', @level2name = N'inv_pk_id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Trama o informacion enviada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceLog', @level2type = N'COLUMN', @level2name = N'inv_DataSent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Trama o informacion recibida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceLog', @level2type = N'COLUMN', @level2name = N'inv_DataReceived';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripcion del error registrada en el log', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceLog', @level2type = N'COLUMN', @level2name = N'ErrorDesc';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de registro del log', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceLog', @level2type = N'COLUMN', @level2name = N'Date';

