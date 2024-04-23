
CREATE TABLE [dbo].[Customer](
	[IdCustomer] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](100) NULL,
	[Domain] [nvarchar](50) NOT NULL,
	[RegexSubject] [nvarchar](100) NOT NULL,
	[RegexEmail] [nvarchar](100) NOT NULL,
	[RegexFilename] [nvarchar](100) NOT NULL,
	[Abbreviation] [nvarchar](25) NOT NULL,
	[IdCustomerType] [int] NULL,
	[ConditionOfPaymentID] [int] NULL,
	[CountryID] [varchar](2) NULL,
	[CommercialName] [nvarchar](50) NULL,
	[CustomerPhone] [nvarchar](50) NULL,
	[WebsiteURI] [nvarchar](50) NULL,
	[ContactName] [nvarchar](50) NULL,
	[ContactEmail] [nvarchar](50) NULL,
	[NotificationAddress] [nvarchar](200) NULL,
	[SaleAdvisorID] [int] NULL,
	[DateUpService] [datetime] NULL,
	[DateDownService] [datetime] NULL,
	[TypeOfBusinessID] [int] NULL,
	[BusinessSegmentID] [int] NULL,
	[BusinessActivityID] [int] NULL,
	[CommercialSegmentID] [int] NULL,
	[OperationContactName] [nvarchar](50) NULL,
	[OperationContactPhone] [nvarchar](50) NULL,
	[OperationContactEmail] [nvarchar](50) NULL,
	[LegalSponsorName] [nvarchar](50) NULL,
	[LegalSponsorLastName] [nvarchar](50) NULL,
	[LegalSponsorDPI] [nvarchar](50) NULL,
	[HasAgreement] [bit] NULL,
	[AgreementNumber] [nvarchar](50) NULL,
	[AgreementDateStart] [datetime] NULL,
	[AgreementDateEnd] [datetime] NULL,
	[InvoiceName] [nvarchar](100) NULL,
	[TaxIdentificationNumber] [nvarchar](50) NULL,
	[FiscalAddress] [nvarchar](200) NULL,
	[InvoiceEmail] [nvarchar](50) NULL,
	[InvoiceContactName] [nvarchar](50) NULL,
	[InvoiceContactPhone] [nvarchar](50) NULL,
	[InvoiceContactEmail] [nvarchar](50) NULL,
	[CODAccountBankID] [int] NULL,
	[CODAccountNumber] [nvarchar](50) NULL,
	[CODAccountName] [nvarchar](50) NULL,
	[CODAccountTypeID] [int] NULL,
	[CODCurrencyID] [int] NULL,
	[CODContactName] [nvarchar](50) NULL,
	[CODContactPhone] [nvarchar](50) NULL,
	[CODContactEmail] [nvarchar](50) NULL,
	[RowSatus] [bit] NULL,
	[TokenCreated] [nvarchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
	[SAPCardCode] [nvarchar](50) NULL,
	[ExcludePriceShippingCOD] [bit] NULL,
	[ExcludeCommissionCOD] [bit] NULL,
	[CatBatchTypeCODId] [bigint] NULL,
	[CatBatchFrequencyCODId] [bigint] NULL,
	[CatTMSalesPersonId] [int] NULL,
	[CutOffDate] [datetime] NULL,
	[UpgradeDate] [datetime] NULL,
	[CustomerGoalQuantity] [int] NULL,
	[CatBillingTimeId] [int] NULL,
	[CatBillingVolumeId] [int] NULL,
	[BillingCut_offDate] [date] NULL,
	[NumImgEvidence] [int] NULL,
	[isCOD] [int] NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[IdCustomer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_CatBankAccountType] FOREIGN KEY([CODAccountTypeID])
REFERENCES [dbo].[CatBankAccountType] ([IdBankAccountType])
GO

ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_CatBankAccountType]
GO

ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_CatBillingTime] FOREIGN KEY([CatBillingTimeId])
REFERENCES [dbo].[CatBillingTime] ([IdCatBillingTime])
GO

ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_CatBillingTime]
GO

ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_CatBillingVolume] FOREIGN KEY([CatBillingVolumeId])
REFERENCES [dbo].[CatBillingVolume] ([IdCatBillingVolume])
GO

ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_CatBillingVolume]
GO

ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_CatBusinessActivity] FOREIGN KEY([BusinessActivityID])
REFERENCES [dbo].[CatBusinessActivity] ([IdBusinessActivity])
GO

ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_CatBusinessActivity]
GO

ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_CatBusinessSegment] FOREIGN KEY([BusinessSegmentID])
REFERENCES [dbo].[CatBusinessSegment] ([IdBusinessSegment])
GO

ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_CatBusinessSegment]
GO

ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_CatCommercialSegment] FOREIGN KEY([CommercialSegmentID])
REFERENCES [dbo].[CatCommercialSegment] ([IdCommercialSegment])
GO

ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_CatCommercialSegment]
GO

ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_CatConditionOfPayment] FOREIGN KEY([ConditionOfPaymentID])
REFERENCES [dbo].[CatConditionOfPayment] ([IdConditionOfPayment])
GO

ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_CatConditionOfPayment]
GO

ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_CatCountry] FOREIGN KEY([CountryID])
REFERENCES [dbo].[CatCountry] ([IdCountry])
GO

ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_CatCountry]
GO

ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_CatSaleAdvisor] FOREIGN KEY([SaleAdvisorID])
REFERENCES [dbo].[CatSaleAdvisor] ([IdSaleAdvisor])
GO

ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_CatSaleAdvisor]
GO

ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_CatTMSalesPerson] FOREIGN KEY([CatTMSalesPersonId])
REFERENCES [dbo].[CatTMSalesPerson] ([IdCatTMSalesPerson])
GO

ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_CatTMSalesPerson]
GO

ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_CatTypeOfBusiness] FOREIGN KEY([TypeOfBusinessID])
REFERENCES [dbo].[CatTypeOfBusiness] ([IdTypeOfBusiness])
GO

ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_CatTypeOfBusiness]
GO

ALTER TABLE [dbo].[Customer]  WITH NOCHECK ADD  CONSTRAINT [FK_Customer_CustomerType] FOREIGN KEY([IdCustomerType])
REFERENCES [dbo].[CustomerType] ([IdCustomerType])
GO

ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_CustomerType]
GO

ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_DeliveryBank] FOREIGN KEY([CODAccountBankID])
REFERENCES [dbo].[DeliveryBank] ([Id_bank])
GO

ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_DeliveryBank]
GO

ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_DeliveryCurrency] FOREIGN KEY([CODCurrencyID])
REFERENCES [dbo].[DeliveryCurrency] ([Currency_Id])
GO

ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_DeliveryCurrency]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id para la tabla Customer ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'IdCustomer'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'Name'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion que complementa el nombre del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'Description'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Es el dominio que utiliza el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'Domain'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Expresion regular para la solicitud del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'RegexSubject'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Expresion regular para el correo del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'RegexEmail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Expresion regular para nombre del archivo del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'RegexFilename'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Abreviatura del nombre del cliente con el que se identifica' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'Abbreviation'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de cliente segun clasificatoria interna de Forza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'IdCustomerType'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de condicion de pago que tiene el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'ConditionOfPaymentID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ciudad a la que pertenece el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CountryID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre comercial del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CommercialName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Telefono del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CustomerPhone'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sitio web del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'WebsiteURI'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del contacto que se tiene del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'ContactName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Correo de contacto que se tiene del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'ContactEmail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Direccion del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'NotificationAddress'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Asesor de venta del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'SaleAdvisorID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha en que se levanta el servicio para el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'DateUpService'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha en que se baja el servicio para el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'DateDownService'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de negocio al que pertenece el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'TypeOfBusinessID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Segmento de negocio al que pertenece el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'BusinessSegmentID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Actividad que realiza el negocio del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'BusinessActivityID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Segmento cormercial o mercado objetivo del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CommercialSegmentID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del contacto de operaciones del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'OperationContactName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Telefono del contacto de operaciones del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'OperationContactPhone'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Correo electronico del contacto de operaciones del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'OperationContactEmail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de la persona que asume la responsabilidad legal del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'LegalSponsorName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Apellido de la persona que asume la responsabilidad legal del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'LegalSponsorLastName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Documento de identificacion personal de la persona que asume la responsabilidad legal del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'LegalSponsorDPI'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Campo que indica si el cliente tiene o no acuerdos con la empresa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'HasAgreement'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de acuerdo que se tiene con el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'AgreementNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de inicio del acuerdo que se tiene con el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'AgreementDateStart'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de finalizacion del acuerdo que se tiene con el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'AgreementDateEnd'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre que se le asigna a la factura del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'InvoiceName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de identificacion fiscal del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'TaxIdentificationNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Direccion fiscal del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'FiscalAddress'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Correo electronico de facturacion del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'InvoiceEmail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del contacto de facturacion del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'InvoiceContactName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Telefono del contacto de facturacion del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'InvoiceContactPhone'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Correo electronico del contacto de facturacion del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'InvoiceContactEmail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Banco al que pertenece la cuenta del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CODAccountBankID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de cuenta de banco del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CODAccountNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de la cuenta de banco del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CODAccountName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de cuenta de banco del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CODAccountTypeID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Moneda que maneja el cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CODCurrencyID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del contacto de COD del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CODContactName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Telefono del contacto de COD del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CODContactPhone'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Correo electronico del contacto de COD del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CODContactEmail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de la fila habilitado o deshabilitado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'RowSatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creacion de la fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creacion de la fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualizacion de la fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualizacion de la fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de tarjeta de SAP asociado al cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'SAPCardCode'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Bandera para indicar si se excluye el precio de envio.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'ExcludePriceShippingCOD'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Bandera para indicar si se excluye la comision.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'ExcludeCommissionCOD'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id de la tabla CatBatchTypeCOD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CatBatchTypeCODId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id para la tabla CatBatchFrequencyCOD ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CatBatchFrequencyCODId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del vendedor de telemercadeo asociado al cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CatTMSalesPersonId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de corte para los clientes de tipo PYMES' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CutOffDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización de tipo de cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'UpgradeDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Meta de envíos para cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CustomerGoalQuantity'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'identificador de el tiempo en que se requiere la facturaci�n' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CatBillingTimeId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador que indica volumen de facturaci�n' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'CatBillingVolumeId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fechad e corte de facturaci�n' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'BillingCut_offDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacenar cantidad de imagenes de evidencias permitidas' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'NumImgEvidence'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado que indica si el cliente esta autorizado para guías COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer', @level2type=N'COLUMN',@level2name=N'isCOD'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'La tabla Cliente almacena informacon relacionada con los clientes de la empresa Forza Delivery' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Customer'
GO


