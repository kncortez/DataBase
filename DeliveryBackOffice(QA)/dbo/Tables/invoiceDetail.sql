CREATE TABLE [dbo].[invoiceDetail] (
    [dti_fk_header]      BIGINT          NOT NULL,
    [dti_fk_orderSerie]  NVARCHAR (2)    NULL,
    [dti_fk_orderNumber] INT             NULL,
    [dti_identification] VARCHAR (200)   NULL,
    [dti_category]       VARCHAR (50)    NOT NULL,
    [dti_quantity]       DECIMAL (10, 5) NOT NULL,
    [dti_measurement]    VARCHAR (20)    NULL,
    [dti_priceUnit]      MONEY           NOT NULL,
    [dti_description]    VARCHAR (MAX)   NOT NULL,
    [dti_IVA]            MONEY           NULL,
    [dti_amount]         MONEY           NOT NULL,
    [dti_dateRegister]   DATETIME        NOT NULL,
    [dti_tokenRegister]  VARCHAR (200)   NOT NULL,
    [SAPCode]            NVARCHAR (50)   NULL,
    [SendToInvoice]      BIT             NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_dti_fk_header]
    ON [dbo].[invoiceDetail]([dti_fk_header] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_dti_fk_orderNumber_dti_fk_orderSerie]
    ON [dbo].[invoiceDetail]([dti_fk_orderNumber] ASC, [dti_fk_orderSerie] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_ordernumber_orderserie]
    ON [dbo].[invoiceDetail]([dti_fk_orderSerie] ASC, [dti_fk_orderNumber] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder registrar el código SAP del artículo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'invoiceDetail', @level2type = N'COLUMN', @level2name = N'SAPCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder registrar si el artículo se enviará al detalle de factura cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'invoiceDetail', @level2type = N'COLUMN', @level2name = N'SendToInvoice';

