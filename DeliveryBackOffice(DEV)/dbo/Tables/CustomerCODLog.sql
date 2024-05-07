CREATE TABLE [dbo].[CustomerCODLog](
	[IdCustomerCODLog] [int] IDENTITY(1,1) NOT NULL,
	[CustomerId] [int] NULL,
	[VisitPointId] [int] NULL,
	[IsCOD] [int] NULL,
	[CODExcludePriceShipping] [int] NULL,
	[CODExcludeComission] [int] NULL,
	[CODIdBank] [int] NULL,
	[CODAccountName] [varchar](100) NULL,
	[CODAccountNumber] [varchar](50) NULL,
	[CODAccountTypeId] [int] NULL,
	[CODCurrencyId] [int] NULL,
	[CODCatBatchType] [bigint] NULL,
	[CODCatBatchFrequency] [bigint] NULL,
	[CODBillingTimeId] [int] NULL,
	[CODBillingVolumeId] [int] NULL,
	[CODBillingCutOfDate] [datetime] NULL,
	[DateRegister] [datetime] NULL,
	[TokenRegister] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
	[TokenUpdated] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[IdCustomerCODLog] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CustomerCODLog]  WITH CHECK ADD FOREIGN KEY([CODAccountTypeId])
REFERENCES [dbo].[CatBankAccountType] ([IdBankAccountType])
GO

ALTER TABLE [dbo].[CustomerCODLog]  WITH CHECK ADD FOREIGN KEY([VisitPointId])
REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
GO

ALTER TABLE [dbo].[CustomerCODLog]  WITH CHECK ADD FOREIGN KEY([CODBillingTimeId])
REFERENCES [dbo].[CatBillingTime] ([IdCatBillingTime])
GO

ALTER TABLE [dbo].[CustomerCODLog]  WITH CHECK ADD FOREIGN KEY([CODBillingVolumeId])
REFERENCES [dbo].[CatBillingVolume] ([IdCatBillingVolume])
GO

ALTER TABLE [dbo].[CustomerCODLog]  WITH CHECK ADD FOREIGN KEY([CODCatBatchType])
REFERENCES [dbo].[CatBatchTypeCOD] ([CatBatchTypeCODId])
GO

ALTER TABLE [dbo].[CustomerCODLog]  WITH CHECK ADD FOREIGN KEY([CODCatBatchFrequency])
REFERENCES [dbo].[CatBatchFrequencyCOD] ([CatBatchFrequencyCODId])
GO

ALTER TABLE [dbo].[CustomerCODLog]  WITH CHECK ADD FOREIGN KEY([CODCurrencyId])
REFERENCES [dbo].[DeliveryCurrency] ([Currency_Id])
GO

ALTER TABLE [dbo].[CustomerCODLog]  WITH CHECK ADD FOREIGN KEY([CODIdBank])
REFERENCES [dbo].[DeliveryBank] ([Id_bank])
GO

ALTER TABLE [dbo].[CustomerCODLog]  WITH CHECK ADD FOREIGN KEY([CustomerId])
REFERENCES [dbo].[Customer] ([IdCustomer])
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador unico de registro log COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'IdCustomerCODLog'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de usuario corporativo con tabla Customer' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CustomerId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de punto de visita asociado al registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'VisitPointId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado booleano que indica si esta activo o inactivo para guias COD (0: Inactivo, 1:activo)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'IsCOD'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado booleano que indica si puede excluir cobro de envio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODExcludePriceShipping'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado booleano que indica si puede excluir cobro de comision' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODExcludeComission'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de banco asociado a cuenta bancaria de cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODIdBank'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de cuenta bancaria asociada a cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODAccountName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de cuenta bancaria asociado a cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODAccountNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de tipo de cuenta bancaria asociada a cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODAccountTypeId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de tipo de moneda asociada a cuenta bancaria de cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODCurrencyId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Formato de lote asociado a cuenta bancaria de cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODCatBatchType'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Frecuencia de deposito asociada a cuenta bancaria de cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODCatBatchFrequency'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de Tiempo de Facturacion asociado a cuenta bancaria de cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODBillingTimeId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Volumen de facturacion asociado a cuenta bancaria de cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODBillingVolumeId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de corte asociada a cuenta bancaria de cliente COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'CODBillingCutOfDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de registro de Log' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'DateRegister'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de registro de Log' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'TokenRegister'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualizacion de Log' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de Actualizacion de Log' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla de registro de logs para clientes corporativos que habilitan o deshabilitan guias COD en Socio de Negocio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerCODLog'
GO


