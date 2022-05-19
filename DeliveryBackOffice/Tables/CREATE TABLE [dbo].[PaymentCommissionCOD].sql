USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PaymentCommissionCOD](
	[IdPaymentCommissionCOD] [int] IDENTITY(1,1) NOT NULL,
	[invoiceHeaderId] [bigint] NOT NULL,
	[CatTypeProductId] [int] NULL,
	[TotalAmount] [decimal](18, 2) NULL,
	[PaymentDate] [datetime] NULL,
	[CatModuleId] [int] NULL,
	[TotalAmountPaid] [decimal](12, 2) NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdPaymentCommissionCOD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PaymentCommissionCOD]  WITH CHECK ADD  CONSTRAINT [FK_PaymentCommissionCOD_inv_pk_id] FOREIGN KEY([invoiceHeaderId])
REFERENCES [dbo].[invoiceHeader] ([inv_pk_id])
GO

ALTER TABLE [dbo].[PaymentCommissionCOD] CHECK CONSTRAINT [FK_PaymentCommissionCOD_inv_pk_id]
GO

ALTER TABLE [dbo].[PaymentCommissionCOD]  WITH CHECK ADD  CONSTRAINT [FK_PaymentCommissionCOD_CatTypeProductId] FOREIGN KEY([CatTypeProductId])
REFERENCES [dbo].[CatTypeProduct] ([IdTypeProduct])
GO

ALTER TABLE [dbo].[PaymentCommissionCOD] CHECK CONSTRAINT [FK_PaymentCommissionCOD_CatTypeProductId]
GO

ALTER TABLE [dbo].[PaymentCommissionCOD]  WITH CHECK ADD  CONSTRAINT [FK_PaymentCommissionCOD_CatModuleId] FOREIGN KEY([CatModuleId])
REFERENCES [dbo].[CatModule] ([ModIdModule])
GO

ALTER TABLE [dbo].[PaymentCommissionCOD] CHECK CONSTRAINT [FK_PaymentCommissionCOD_CatModuleId]
GO

ALTER TABLE [dbo].[PaymentCommissionCOD] ADD  CONSTRAINT [DF_PaymentCommissionCOD_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador PaymentCommissionCOD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCOD', @level2type=N'COLUMN',@level2name=N'IdPaymentCommissionCOD'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foránea de tabla invoiceHeader' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCOD', @level2type=N'COLUMN',@level2name=N'invoiceHeaderId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foránea de tabla  CatTypeProduct' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCOD', @level2type=N'COLUMN',@level2name=N'CatTypeProductId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total de la comisión COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCOD', @level2type=N'COLUMN',@level2name=N'TotalAmount'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora de pago' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCOD', @level2type=N'COLUMN',@level2name=N'PaymentDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foránea de tabla  CatModule' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCOD', @level2type=N'COLUMN',@level2name=N'CatModuleId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total pagado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCOD', @level2type=N'COLUMN',@level2name=N'TotalAmountPaid'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de la fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCOD', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario que creó fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCOD', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCOD', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario que actualizó fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCOD', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización de la fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCOD', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para almacenar los pagos de Comisión COD.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PaymentCommissionCOD'
GO
