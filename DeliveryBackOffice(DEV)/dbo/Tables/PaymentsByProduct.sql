USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[PaymentsByProduct]    Script Date: 11/27/2023 11:14:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PaymentsByProduct](
	[IdPaymentsByProduct] [int] IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NOT NULL,
	[PaymentsByProductPaymentMethodId] [int] NOT NULL,
	[PaymentsByProductPaymentAmount] [decimal](18, 2) NOT NULL,
	[PaymentsByProductTransactionId] [bigint] NULL,
	[PaymentsByProductTransactionOrder] [nvarchar](100) NULL,
	[PaymentsByProductImageURL] [nvarchar](200) NULL,
	[PaymentsByProductInvoiceId] [bigint] NULL,
	[PaymentsByProductArticleSAPId] [int] NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_PaymentsByProduct] PRIMARY KEY CLUSTERED 
(
	[IdPaymentsByProduct] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PaymentsByProduct]  WITH CHECK ADD  CONSTRAINT [FK_PaymentsByProduct_CatArticleSAP] FOREIGN KEY([PaymentsByProductArticleSAPId])
REFERENCES [dbo].[CatArticleSAP] ([IdCatArticleSAP])
GO

ALTER TABLE [dbo].[PaymentsByProduct] CHECK CONSTRAINT [FK_PaymentsByProduct_CatArticleSAP]
GO

ALTER TABLE [dbo].[PaymentsByProduct]  WITH CHECK ADD  CONSTRAINT [FK_PaymentsByProduct_CreditCardTransactionByCustomer] FOREIGN KEY([PaymentsByProductTransactionId])
REFERENCES [dbo].[CreditCardTransactionByCustomer] ([IdTransaction])
GO

ALTER TABLE [dbo].[PaymentsByProduct] CHECK CONSTRAINT [FK_PaymentsByProduct_CreditCardTransactionByCustomer]
GO

ALTER TABLE [dbo].[PaymentsByProduct]  WITH CHECK ADD  CONSTRAINT [FK_PaymentsByProduct_ctgTypeOfInOutOfMoney] FOREIGN KEY([PaymentsByProductPaymentMethodId])
REFERENCES [dbo].[ctgTypeOfInOutOfMoney] ([tio_pk_id])
GO

ALTER TABLE [dbo].[PaymentsByProduct] CHECK CONSTRAINT [FK_PaymentsByProduct_ctgTypeOfInOutOfMoney]
GO

ALTER TABLE [dbo].[PaymentsByProduct]  WITH CHECK ADD  CONSTRAINT [FK_PaymentsByProduct_invoiceHeader] FOREIGN KEY([PaymentsByProductInvoiceId])
REFERENCES [dbo].[invoiceHeader] ([inv_pk_id])
GO

ALTER TABLE [dbo].[PaymentsByProduct] CHECK CONSTRAINT [FK_PaymentsByProduct_invoiceHeader]
GO

ALTER TABLE [dbo].[PaymentsByProduct]  WITH CHECK ADD  CONSTRAINT [FK_PaymentsByProduct_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Product] ([IdProduct])
GO

ALTER TABLE [dbo].[PaymentsByProduct] CHECK CONSTRAINT [FK_PaymentsByProduct_Product]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentsByProduct', @level2type=N'COLUMN',@level2name=N'IdPaymentsByProduct'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentsByProduct', @level2type=N'COLUMN',@level2name=N'ProductId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del método de pago' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentsByProduct', @level2type=N'COLUMN',@level2name=N'PaymentsByProductPaymentMethodId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto pagado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentsByProduct', @level2type=N'COLUMN',@level2name=N'PaymentsByProductPaymentAmount'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cuando sea cliente individual debe tener registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentsByProduct', @level2type=N'COLUMN',@level2name=N'PaymentsByProductTransactionId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cuando es express center ingresar voucher, id de transferencia, id de visalink' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentsByProduct', @level2type=N'COLUMN',@level2name=N'PaymentsByProductTransactionOrder'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Constancia del pago' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentsByProduct', @level2type=N'COLUMN',@level2name=N'PaymentsByProductImageURL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de factura relacionada' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentsByProduct', @level2type=N'COLUMN',@level2name=N'PaymentsByProductInvoiceId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de facturación del producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentsByProduct', @level2type=N'COLUMN',@level2name=N'PaymentsByProductArticleSAPId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentsByProduct', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentsByProduct', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentsByProduct', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentsByProduct', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentsByProduct', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Pagos realizados de productos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentsByProduct'
GO


