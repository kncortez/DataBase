USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PaymentCommissionCODDetail](
	[IdPaymentCommissionCODDetail] [int] IDENTITY(1,1) NOT NULL,
	[PaymentCommissionCODId] [int] NOT NULL,
	[ctgTypeOfInOutOfMoneyId] [int] NULL,
	[Amount] [decimal](18, 2) NULL,
	[Voucher] [varchar](300) NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdPaymentCommissionCODDetail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PaymentCommissionCODDetail]  WITH CHECK ADD  CONSTRAINT [FK_PaymentCommissionCODDetail_PaymentCommissionCODId] FOREIGN KEY([PaymentCommissionCODId])
REFERENCES [dbo].[PaymentCommissionCOD] ([IdPaymentCommissionCOD])
GO

ALTER TABLE [dbo].[PaymentCommissionCODDetail] CHECK CONSTRAINT [FK_PaymentCommissionCODDetail_PaymentCommissionCODId]
GO

ALTER TABLE [dbo].[PaymentCommissionCODDetail]  WITH CHECK ADD  CONSTRAINT [FK_PaymentCommissionCODDetail_ctgTypeOfInOutOfMoneyId] FOREIGN KEY([ctgTypeOfInOutOfMoneyId])
REFERENCES [dbo].[ctgTypeOfInOutOfMoney] ([tio_pk_id])
GO

ALTER TABLE [dbo].[PaymentCommissionCODDetail] CHECK CONSTRAINT [FK_PaymentCommissionCODDetail_ctgTypeOfInOutOfMoneyId]
GO

ALTER TABLE [dbo].[PaymentCommissionCODDetail] ADD  CONSTRAINT [DF_PaymentCommissionCODDetail_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador PaymentCommissionCODDetail' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCODDetail', @level2type=N'COLUMN',@level2name=N'IdPaymentCommissionCODDetail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foránea de tabla PaymentCommissionCOD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCODDetail', @level2type=N'COLUMN',@level2name=N'PaymentCommissionCODId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foránea de tabla  ctgTypeOfInOutOfMoney' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCODDetail', @level2type=N'COLUMN',@level2name=N'ctgTypeOfInOutOfMoneyId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto de la comisión COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCODDetail', @level2type=N'COLUMN',@level2name=N'Amount'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Voucher de la transacción si es pago con tarjeta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCODDetail', @level2type=N'COLUMN',@level2name=N'Voucher'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de la fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCODDetail', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario que creó fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCODDetail', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCODDetail', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario que actualizó fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCODDetail', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización de la fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCODDetail', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para almacenar el detalle de los pagos de Comisión COD.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCODDetail'
GO
