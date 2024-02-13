CREATE TABLE [dbo].[Membership](
	[IdMembership] [int] IDENTITY(1,1) NOT NULL,
	[CatMembershipId] [int] NOT NULL,
	[CatMembershipStatusId] [int] NOT NULL,
	[MembershipCode] [nvarchar](50) NULL,
	[MembershipCost] [decimal](18, 2) NOT NULL,
	[CustomerId] [int] NULL,
	[AccountId] [bigint] NULL,
	[VisitPointClientId] [int] NULL,
	[CustomerPaymentId] [int] NULL,
	[IsAutoRenewable] [bit] NULL,
	[MembershipFixedValue] [int] NOT NULL,
	[MembershipMaxServiceFixedValue] [int] NOT NULL,
	[ActualServiceCount] [int] NOT NULL,
	[ExpirationDate] [datetime] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
	[LastPaymentDate] [datetime] NULL,
	[InvoiceName] [nvarchar](100) NULL,
	[TaxIdNumber] [nvarchar](50) NULL,
	[InvoiceEmail] [nvarchar](50) NULL,
	[FiscalAddress] [nvarchar](200) NULL,
	[RenewalFixedDay] [int] NULL,
	[CatTMSalesPersonId] [int] NULL,
	[AccumulatedPoints] [int] NULL,
	[AvailablePoints] [int] NULL,
	[PointsExpirationDate] [datetime] NULL,
	[CatValueTypeId] [int] NULL,
	[ProductGiftShippingEmail] [nvarchar](100) NULL,
	[ActivationCode] [nvarchar](50) NULL,
	[ActivationDate] [datetime] NULL,
 CONSTRAINT [PK_Membership] PRIMARY KEY CLUSTERED 
(
	[IdMembership] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Membership] ADD  CONSTRAINT [DF_Membership_IsAutoRenewable]  DEFAULT ((0)) FOR [IsAutoRenewable]
GO

ALTER TABLE [dbo].[Membership] ADD  CONSTRAINT [DF_Membership_ActualServiceCount]  DEFAULT ((0)) FOR [ActualServiceCount]
GO

ALTER TABLE [dbo].[Membership] ADD  CONSTRAINT [DF_Membership_RowStatus]  DEFAULT ((1)) FOR [RowStatus]
GO

ALTER TABLE [dbo].[Membership]  WITH CHECK ADD  CONSTRAINT [FK_Membership_Account] FOREIGN KEY([AccountId])
REFERENCES [dbo].[Account] ([AccIdAccount])
GO

ALTER TABLE [dbo].[Membership] CHECK CONSTRAINT [FK_Membership_Account]
GO

ALTER TABLE [dbo].[Membership]  WITH CHECK ADD  CONSTRAINT [FK_Membership_CatMembership] FOREIGN KEY([CatMembershipId])
REFERENCES [dbo].[CatMembership] ([IdCatMembership])
GO

ALTER TABLE [dbo].[Membership] CHECK CONSTRAINT [FK_Membership_CatMembership]
GO

ALTER TABLE [dbo].[Membership]  WITH CHECK ADD  CONSTRAINT [FK_Membership_Customer] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[Customer] ([IdCustomer])
GO

ALTER TABLE [dbo].[Membership] CHECK CONSTRAINT [FK_Membership_Customer]
GO

ALTER TABLE [dbo].[Membership]  WITH CHECK ADD  CONSTRAINT [FK_Membership_CustomerPayment] FOREIGN KEY([CustomerPaymentId])
REFERENCES [dbo].[CustomerPaymentValue] ([IdCustomerPaymentValue])
GO

ALTER TABLE [dbo].[Membership] CHECK CONSTRAINT [FK_Membership_CustomerPayment]
GO

ALTER TABLE [dbo].[Membership]  WITH CHECK ADD  CONSTRAINT [FK_Membership_MembershipStatus] FOREIGN KEY([CatMembershipStatusId])
REFERENCES [dbo].[CatSalesPackageStatus] ([IdCatSalesPackageStatus])
GO

ALTER TABLE [dbo].[Membership] CHECK CONSTRAINT [FK_Membership_MembershipStatus]
GO

ALTER TABLE [dbo].[Membership]  WITH CHECK ADD  CONSTRAINT [FK_Membership_VisitPointClient] FOREIGN KEY([VisitPointClientId])
REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
GO

ALTER TABLE [dbo].[Membership] CHECK CONSTRAINT [FK_Membership_VisitPointClient]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla Membership.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'IdMembership'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla CatMembership.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'CatMembershipId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla CatSalesPackageStatus' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'CatMembershipStatusId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de activación de Express Center para uso en clientes individuales (no vigente)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'MembershipCode'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Costo de la membresía adquirida' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'MembershipCost'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del dueño de la mebresía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'CustomerId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la cuenta de la membresía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'AccountId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del punto de visita asociado a la membresía (no activo)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'VisitPointClientId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la forma de pago asociada, con que tarjeta se pagó, tabla CustomerPaymentValue' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'CustomerPaymentId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Si el cliente desea autorenovar su membresía anual' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'IsAutoRenewable'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto del servicio al tener membresía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'MembershipFixedValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad máxima de servicios de la membresía adquirida' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'MembershipMaxServiceFixedValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de servicio generados bajo membresías, luego de vencer se siguen acumulando con descuento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'ActualServiceCount'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de expiración de membresía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'ExpirationDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario que actualiza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha que actualiza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Última fecha de pago' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'LastPaymentDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nit con la que se compra la membresía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'TaxIdNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Correo de facturación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'InvoiceEmail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Dirección para facturar' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'FiscalAddress'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Día el cual se desea poder renovar la membresía.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'RenewalFixedDay'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del vendedor de telemercadeo asociado a la membresía vendida' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'CatTMSalesPersonId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Puntos acumulados durante un periodo de vigencia de membresía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'AccumulatedPoints'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Puntos disponibles para usar' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'AvailablePoints'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de expiración de puntos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'PointsExpirationDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de tabla CatValueType' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'CatValueTypeId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de activación del producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership', @level2type=N'COLUMN',@level2name=N'ActivationDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Listado de membresías generadas' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Membership'
GO


