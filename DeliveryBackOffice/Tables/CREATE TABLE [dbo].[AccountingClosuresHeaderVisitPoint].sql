USE [DeliveryBackOffice]
GO
/****** Object:  Table [dbo].[AccountingClosuresHeaderVisitPoint]    Script Date: 25/03/2022 11:38:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccountingClosuresHeaderVisitPoint](
	[IdAccountingClosuresHeaderVisitPoint] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [bigint] NOT NULL,
	[ClosurerPOS] [nvarchar](50) NULL,
	[TotalAmountCash] [decimal](18, 5) NOT NULL,
	[TotalAmountCashDeclared] [decimal](18, 5) NOT NULL,
	[TotalAmountCredit] [decimal](18, 5) NOT NULL,
	[TotalAmountCreditDeclared] [decimal](18, 5) NOT NULL,
	[InvoiceAmountCash] [int] NOT NULL,
	[InvoiceAmountCredit] [int] NOT NULL,
	[VisitPoint] [int] NOT NULL,
	[Voucher1] [nvarchar](50) NULL,
	[Bag1] [nvarchar](50) NULL,
	[Voucher2] [nvarchar](50) NULL,
	[Bag2] [nvarchar](50) NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
	[TotalAmountCODCash] [decimal](18, 5) NOT NULL,
	[TotalAmountCODCredit] [decimal](18, 5) NOT NULL,
	[TotalAmountCODCashDeclared] [decimal](18, 5) NOT NULL,
	[TotalAmountCODCreditDeclared] [decimal](18, 5) NOT NULL,
	[TotalAmountFacturaCash] [decimal](18, 5) NOT NULL,
	[InvoiceAmountFacturaCash] [int] NOT NULL,
	[TotalAmountFacturaCard] [decimal](18, 5) NOT NULL,
	[InvoiceAmountFacturaCard] [int] NOT NULL,
	[TotalAmountFacturaCashDeclared] [decimal](18, 5) NOT NULL,
	[TotalAmountFacturaCardDeclared] [decimal](18, 5) NOT NULL,
	[InvoiceAmountCOD] [int] NOT NULL,
 CONSTRAINT [PK_AccountingClosuresHeaderVisitPoint] PRIMARY KEY CLUSTERED 
(
	[IdAccountingClosuresHeaderVisitPoint] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AccountingClosuresHeaderVisitPoint] ADD  DEFAULT ((0)) FOR [TotalAmountCODCash]
GO
ALTER TABLE [dbo].[AccountingClosuresHeaderVisitPoint] ADD  DEFAULT ((0)) FOR [TotalAmountCODCredit]
GO
ALTER TABLE [dbo].[AccountingClosuresHeaderVisitPoint] ADD  CONSTRAINT [ACHVP_TotalAmountCODCashDeclared]  DEFAULT ((0)) FOR [TotalAmountCODCashDeclared]
GO
ALTER TABLE [dbo].[AccountingClosuresHeaderVisitPoint] ADD  CONSTRAINT [ACHVP_TotalAmountCODCreditDeclared]  DEFAULT ((0)) FOR [TotalAmountCODCreditDeclared]
GO
ALTER TABLE [dbo].[AccountingClosuresHeaderVisitPoint] ADD  CONSTRAINT [ACHVP_TotalAmountFacturaCash]  DEFAULT ((0)) FOR [TotalAmountFacturaCash]
GO
ALTER TABLE [dbo].[AccountingClosuresHeaderVisitPoint] ADD  CONSTRAINT [ACHVP_InvoiceAmountFacturaCash]  DEFAULT ((0)) FOR [InvoiceAmountFacturaCash]
GO
ALTER TABLE [dbo].[AccountingClosuresHeaderVisitPoint] ADD  CONSTRAINT [ACHVP_TotalAmountFacturaCard]  DEFAULT ((0)) FOR [TotalAmountFacturaCard]
GO
ALTER TABLE [dbo].[AccountingClosuresHeaderVisitPoint] ADD  CONSTRAINT [ACHVP_InvoiceAmountFacturaCard]  DEFAULT ((0)) FOR [InvoiceAmountFacturaCard]
GO
ALTER TABLE [dbo].[AccountingClosuresHeaderVisitPoint] ADD  CONSTRAINT [ACHVP_TotalAmountFacturaCashDeclared]  DEFAULT ((0)) FOR [TotalAmountFacturaCashDeclared]
GO
ALTER TABLE [dbo].[AccountingClosuresHeaderVisitPoint] ADD  CONSTRAINT [ACHVP_TotalAmountFacturaCardDeclared]  DEFAULT ((0)) FOR [TotalAmountFacturaCardDeclared]
GO
ALTER TABLE [dbo].[AccountingClosuresHeaderVisitPoint] ADD  CONSTRAINT [ACHVP_InvoiceAmountCOD]  DEFAULT ((0)) FOR [InvoiceAmountCOD]
GO
ALTER TABLE [dbo].[AccountingClosuresHeaderVisitPoint]  WITH CHECK ADD  CONSTRAINT [FK_AccountingClosuresHeaderVisitPoint_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
GO
ALTER TABLE [dbo].[AccountingClosuresHeaderVisitPoint] CHECK CONSTRAINT [FK_AccountingClosuresHeaderVisitPoint_User]
GO
ALTER TABLE [dbo].[AccountingClosuresHeaderVisitPoint]  WITH CHECK ADD  CONSTRAINT [FK_AccountingClosuresHeaderVisitPoint_VisitPointClient] FOREIGN KEY([VisitPoint])
REFERENCES [dbo].[VisitPointClientParser] ([CodeOfReference])
GO
ALTER TABLE [dbo].[AccountingClosuresHeaderVisitPoint] CHECK CONSTRAINT [FK_AccountingClosuresHeaderVisitPoint_VisitPointClient]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'IdAccountingClosuresHeaderVisitPoint'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Operador del express center' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'UserId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cierre POS, documento generado cuando en el dispositivo de cobro con tarjeta se cierra la operación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'ClosurerPOS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total efectivo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'TotalAmountCash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total efectivo declarado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'TotalAmountCashDeclared'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total tarjeta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'TotalAmountCredit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total tarjeta declarado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'TotalAmountCreditDeclared'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de facturas efectivo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'InvoiceAmountCash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de facturas tarjeta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'InvoiceAmountCredit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'EXC quien hizo cierre' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'VisitPoint'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Voucher para envíos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'Voucher1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Bolsa para envíos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'Bag1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Voucher para COD y comisiones' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'Voucher2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Bolsa para COD y comisiones' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'Bag2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de Express Center quien crea registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha en la que se crear registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario que actualiza información' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha en la que se actualiza información' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total de COD en efectivo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'TotalAmountCODCash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total de COD con tarjeta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'TotalAmountCODCredit'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total de COD en efectivo declarado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'TotalAmountCODCashDeclared'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total de COD con tarjeta declarado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'TotalAmountCODCreditDeclared'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total de facturas en efectivo para COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'TotalAmountFacturaCash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de facturas efectivo para COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'InvoiceAmountFacturaCash'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total de facturas con tarjeta para COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'TotalAmountFacturaCard'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de facturas tarjeta para COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'InvoiceAmountFacturaCard'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total de facturas en efectivo para COD declarado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'TotalAmountFacturaCashDeclared'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total de facturas con tarjeta para COD declarado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'TotalAmountFacturaCardDeclared'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de cobros de COD' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint', @level2type=N'COLUMN',@level2name=N'InvoiceAmountCOD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Encabezado de cierres contables para Express Centers' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeaderVisitPoint'
GO
