CREATE TABLE [dbo].[PaymentsByProduct] (
    [IdPaymentsByProduct]               INT             IDENTITY (1, 1) NOT NULL,
    [ProductId]                         INT             NOT NULL,
    [PaymentsByProductPaymentMethodId]  INT             NOT NULL,
    [PaymentsByProductPaymentAmount]    DECIMAL (18, 2) NOT NULL,
    [PaymentsByProductTransactionId]    BIGINT          NULL,
    [PaymentsByProductTransactionOrder] NVARCHAR (100)  NULL,
    [PaymentsByProductImageURL]         NVARCHAR (200)  NULL,
    [PaymentsByProductInvoiceId]        BIGINT          NULL,
    [PaymentsByProductArticleSAPId]     INT             NULL,
    [RowStatus]                         BIT             NOT NULL,
    [TokenCreated]                      NVARCHAR (50)   NOT NULL,
    [DateCreated]                       DATETIME        NOT NULL,
    [TokenUpdated]                      NVARCHAR (50)   NULL,
    [DateUpdated]                       DATETIME        NULL,
    CONSTRAINT [PK_PaymentsByProduct] PRIMARY KEY CLUSTERED ([IdPaymentsByProduct] ASC),
    CONSTRAINT [FK_PaymentsByProduct_CatArticleSAP] FOREIGN KEY ([PaymentsByProductArticleSAPId]) REFERENCES [dbo].[CatArticleSAP] ([IdCatArticleSAP]),
    CONSTRAINT [FK_PaymentsByProduct_CreditCardTransactionByCustomer] FOREIGN KEY ([PaymentsByProductTransactionId]) REFERENCES [dbo].[CreditCardTransactionByCustomer] ([IdTransaction]),
    CONSTRAINT [FK_PaymentsByProduct_ctgTypeOfInOutOfMoney] FOREIGN KEY ([PaymentsByProductPaymentMethodId]) REFERENCES [dbo].[ctgTypeOfInOutOfMoney] ([tio_pk_id]),
    CONSTRAINT [FK_PaymentsByProduct_invoiceHeader] FOREIGN KEY ([PaymentsByProductInvoiceId]) REFERENCES [dbo].[invoiceHeader] ([inv_pk_id]),
    CONSTRAINT [FK_PaymentsByProduct_Product] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Product] ([IdProduct])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentsByProduct', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentsByProduct', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentsByProduct', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentsByProduct', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentsByProduct', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de facturación del producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentsByProduct', @level2type = N'COLUMN', @level2name = N'PaymentsByProductArticleSAPId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de factura relacionada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentsByProduct', @level2type = N'COLUMN', @level2name = N'PaymentsByProductInvoiceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Constancia del pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentsByProduct', @level2type = N'COLUMN', @level2name = N'PaymentsByProductImageURL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cuando es express center ingresar voucher, id de transferencia, id de visalink', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentsByProduct', @level2type = N'COLUMN', @level2name = N'PaymentsByProductTransactionOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cuando sea cliente individual debe tener registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentsByProduct', @level2type = N'COLUMN', @level2name = N'PaymentsByProductTransactionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto pagado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentsByProduct', @level2type = N'COLUMN', @level2name = N'PaymentsByProductPaymentAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del método de pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentsByProduct', @level2type = N'COLUMN', @level2name = N'PaymentsByProductPaymentMethodId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentsByProduct', @level2type = N'COLUMN', @level2name = N'ProductId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentsByProduct', @level2type = N'COLUMN', @level2name = N'IdPaymentsByProduct';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pagos realizados de productos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentsByProduct';

