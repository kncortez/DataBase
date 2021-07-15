USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[AccountingClosuresHeader]    Script Date: 15/07/2021 14:05:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AccountingClosuresHeader](
	[IdAccountingClosuresHeader] [int] IDENTITY(1,1) NOT NULL,
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
 CONSTRAINT [PK_AccountingClosuresHeader] PRIMARY KEY CLUSTERED 
(
	[IdAccountingClosuresHeader] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AccountingClosuresHeader]  WITH CHECK ADD  CONSTRAINT [FK_AccountingClosuresHeader_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
GO

ALTER TABLE [dbo].[AccountingClosuresHeader] CHECK CONSTRAINT [FK_AccountingClosuresHeader_User]
GO

ALTER TABLE [dbo].[AccountingClosuresHeader]  WITH CHECK ADD  CONSTRAINT [FK_AccountingClosuresHeader_VisitPointClient] FOREIGN KEY([VisitPoint])
REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
GO

ALTER TABLE [dbo].[AccountingClosuresHeader] CHECK CONSTRAINT [FK_AccountingClosuresHeader_VisitPointClient]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'IdAccountingClosuresHeader'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Operador del express center' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'UserId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cierre POS, documento generado cuando en el dispositivo de cobro con tarjeta se cierra la operación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'ClosurerPOS'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total efectivo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'TotalAmountCash'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total efectivo declarado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'TotalAmountCashDeclared'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total tarjeta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'TotalAmountCredit'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total tarjeta declarado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'TotalAmountCreditDeclared'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de facturas efectivo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'InvoiceAmountCash'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de facturas tarjeta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'InvoiceAmountCredit'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'EXC quien hizo cierre' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'VisitPoint'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Voucher para envíos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'Voucher1'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Bolsa para envíos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'Bag1'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Voucher para COD y comisiones' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'Voucher2'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Bolsa para COD y comisiones' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'Bag2'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de Express Center quien crea registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha en la que se crear registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario que actualiza información' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha en la que se actualiza información' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Encabezado de cierres contables para Express Centers' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AccountingClosuresHeader'
GO

