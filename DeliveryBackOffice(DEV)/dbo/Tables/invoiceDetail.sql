CREATE TABLE [dbo].[invoiceDetail](
	[dti_fk_header] [bigint] NOT NULL,
	[dti_fk_orderSerie] [nvarchar](2) NULL,
	[dti_fk_orderNumber] [int] NULL,
	[dti_identification] [varchar](200) NULL,
	[dti_category] [varchar](50) NOT NULL,
	[dti_quantity] [decimal](10, 5) NOT NULL,
	[dti_measurement] [varchar](20) NULL,
	[dti_priceUnit] [money] NOT NULL,
	[dti_description] [varchar](max) NOT NULL,
	[dti_IVA] [money] NULL,
	[dti_amount] [money] NOT NULL,
	[dti_dateRegister] [datetime] NOT NULL,
	[dti_tokenRegister] [varchar](200) NOT NULL,
	[SAPCode] [nvarchar](50) NULL,
	[SendToInvoice] [bit] NULL,
	[MembershipId] [int] NULL,
	[SubscriptionId] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[invoiceDetail]  WITH CHECK ADD  CONSTRAINT [FK_invoiceDetail_Membership] FOREIGN KEY([MembershipId])
REFERENCES [dbo].[Membership] ([IdMembership])
GO

ALTER TABLE [dbo].[invoiceDetail] CHECK CONSTRAINT [FK_invoiceDetail_Membership]
GO

ALTER TABLE [dbo].[invoiceDetail]  WITH CHECK ADD  CONSTRAINT [FK_invoiceDetail_Subscription] FOREIGN KEY([SubscriptionId])
REFERENCES [dbo].[Subscription] ([IdSubscription])
GO

ALTER TABLE [dbo].[invoiceDetail] CHECK CONSTRAINT [FK_invoiceDetail_Subscription]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de cabecera de factura con tabla InvoiceHeader (llave foranea)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceDetail', @level2type=N'COLUMN',@level2name=N'dti_fk_header'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie asociada al detalle de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceDetail', @level2type=N'COLUMN',@level2name=N'dti_fk_orderSerie'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de orden asociada al detalle de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceDetail', @level2type=N'COLUMN',@level2name=N'dti_fk_orderNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Categoria de identificacion o servicio asociado al detalle de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceDetail', @level2type=N'COLUMN',@level2name=N'dti_identification'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Categoria de producto del detalle de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceDetail', @level2type=N'COLUMN',@level2name=N'dti_category'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'cantidad en unidades de detalle de la factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceDetail', @level2type=N'COLUMN',@level2name=N'dti_quantity'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion de tipo de unidad del detalle de factura (UND = unidad)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceDetail', @level2type=N'COLUMN',@level2name=N'dti_measurement'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Precio unitario del detalle de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceDetail', @level2type=N'COLUMN',@level2name=N'dti_priceUnit'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion del registro del detalle de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceDetail', @level2type=N'COLUMN',@level2name=N'dti_description'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion del precio de IVA para el detalle de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceDetail', @level2type=N'COLUMN',@level2name=N'dti_IVA'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Precio unitario del detalle de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceDetail', @level2type=N'COLUMN',@level2name=N'dti_amount'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de registro del detalle de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceDetail', @level2type=N'COLUMN',@level2name=N'dti_dateRegister'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de registro del detalle de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceDetail', @level2type=N'COLUMN',@level2name=N'dti_tokenRegister'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Campo para poder registrar el código SAP del artículo.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceDetail', @level2type=N'COLUMN',@level2name=N'SAPCode'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Campo para poder registrar si el artículo se enviará al detalle de factura cliente.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceDetail', @level2type=N'COLUMN',@level2name=N'SendToInvoice'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de membresía facturada' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceDetail', @level2type=N'COLUMN',@level2name=N'MembershipId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de suscripción facturada' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceDetail', @level2type=N'COLUMN',@level2name=N'SubscriptionId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla de modulo de facturación que almacena el cuerpo o detalle de las facturas de su respectiva cabecera con InvoiceHeader' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'invoiceDetail'
GO


GO
CREATE NONCLUSTERED INDEX [idx_dti_fkheader_idsubscription]
    ON [dbo].[invoiceDetail]([SubscriptionId] ASC)
    INCLUDE([dti_fk_header]);


GO
CREATE NONCLUSTERED INDEX [idx_dti_fkheader_idmembership]
    ON [dbo].[invoiceDetail]([MembershipId] ASC)
    INCLUDE([dti_fk_header]);


GO
CREATE NONCLUSTERED INDEX [idx_dti_fk_header_SubscriptionId]
    ON [dbo].[invoiceDetail]([dti_fk_header] ASC, [SubscriptionId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_dti_fk_header_MembershipId]
    ON [dbo].[invoiceDetail]([dti_fk_header] ASC, [MembershipId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_dti_fk_header]
    ON [dbo].[invoiceDetail]([dti_fk_header] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_dti_fk_orderNumber_dti_fk_orderSerie]
    ON [dbo].[invoiceDetail]([dti_fk_orderNumber] ASC, [dti_fk_orderSerie] ASC);

GO
CREATE NONCLUSTERED INDEX [idx_dti_fk_header_dti_fk_orderSerie_dti_fk_orderNumber]
    ON [dbo].[invoiceDetail]([dti_fk_orderSerie],[dti_fk_orderNumber]) INCLUDE ([dti_fk_header]);
    
GO


GO
CREATE NONCLUSTERED INDEX [IDX_ordernumber_orderserie]
    ON [dbo].[invoiceDetail]([dti_fk_orderSerie] ASC, [dti_fk_orderNumber] ASC);


GO
