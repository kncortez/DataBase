CREATE TABLE [dbo].[RegistrationofTransactionProcessStates](
	[IdRegistrationofTransactionProcessStates] [int] IDENTITY(1,1) NOT NULL,
	[AccountId] [int] NULL,
	[CustomerId] [int] NULL,
	[OrderNumber] [nvarchar](50) NOT NULL,
	[NameTax] [nvarchar](250) NULL,
	[AddressTax] [nvarchar](1000) NULL,
	[TaxId] [nvarchar](50) NULL,
	[IsSuscription] [bit] NOT NULL,
	[GetRenovacionAutomatica] [bit] NOT NULL,
	[GetCardsCredit] [int] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdate] [nvarchar](50) NULL,
	[DateUpdate] [datetime] NULL,
	[IdSalePackage] [int] NULL,
	[TypeSalePackage] [nvarchar](25) NULL,
	[Vaucher] [nvarchar](25) NULL,
	[InvoiceEmail] [nvarchar](50) NULL,
	[ProductGiftShippingEmail] [nvarchar](50) NULL,
	[PaymentImageURL] [nvarchar](600) NULL,
	[PhoneNumber] [nvarchar](10) NULL,
 CONSTRAINT [PK_RegistrationofTransactionProcessStates] PRIMARY KEY CLUSTERED 
(
	[IdRegistrationofTransactionProcessStates] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'tabla para guardar los datos de un proceso de pago, asociación y certificación de factura de ser fallido permitir retomarlo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegistrationofTransactionProcessStates', @level2type=N'COLUMN',@level2name=N'IdRegistrationofTransactionProcessStates'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'identioficador de cuenta de usuario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegistrationofTransactionProcessStates', @level2type=N'COLUMN',@level2name=N'AccountId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'identificador de cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegistrationofTransactionProcessStates', @level2type=N'COLUMN',@level2name=N'CustomerId'
GO



EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'el numero de orden esta compuesto por las iniciales MP que indican membership payment seguid de ceros y el nùmero de la susripciòn o memrbesìa adquirida' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegistrationofTransactionProcessStates', @level2type=N'COLUMN',@level2name=N'OrderNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'nombre para facturar' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegistrationofTransactionProcessStates', @level2type=N'COLUMN',@level2name=N'NameTax'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'dirección para facturar' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegistrationofTransactionProcessStates', @level2type=N'COLUMN',@level2name=N'AddressTax'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'NIT de factura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegistrationofTransactionProcessStates', @level2type=N'COLUMN',@level2name=N'TaxId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Si se esta adquiriendo una membresía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegistrationofTransactionProcessStates', @level2type=N'COLUMN',@level2name=N'IsSuscription'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'indica si se requiere que el plan adquirido sea autorenobable' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegistrationofTransactionProcessStates', @level2type=N'COLUMN',@level2name=N'GetRenovacionAutomatica'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'obtener últimos digitos de la tarjeta con la que se ejecuta el pago' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegistrationofTransactionProcessStates', @level2type=N'COLUMN',@level2name=N'GetCardsCredit'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Correo electronico de la persona a la que se envía el regalo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegistrationofTransactionProcessStates', @level2type=N'COLUMN',@level2name=N'ProductGiftShippingEmail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'URL de la imagen del vaucher de compra ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegistrationofTransactionProcessStates', @level2type=N'COLUMN',@level2name=N'PaymentImageURL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de teléfono para campo obligatorio de plataforma de pago versión 2.7' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RegistrationofTransactionProcessStates', @level2type=N'COLUMN',@level2name=N'PhoneNumber'
GO

