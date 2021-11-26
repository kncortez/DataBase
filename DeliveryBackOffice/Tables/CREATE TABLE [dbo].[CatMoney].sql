USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatMoney]    Script Date: 26/11/2021 15:18:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatMoney](
	[IdCatMoney] [int] IDENTITY(1,1) NOT NULL,
	[CurrencyId] [int] NOT NULL,
	[Type] [varchar](10) NOT NULL,
	[Value] [decimal](8, 2) NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatMoney_IdCatMoney] PRIMARY KEY CLUSTERED 
(
	[IdCatMoney] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatMoney] ADD  CONSTRAINT [DF_CatMoney_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

ALTER TABLE [dbo].[CatMoney]  WITH CHECK ADD  CONSTRAINT [FK_CatMoney_CurrencyId] FOREIGN KEY([CurrencyId])
REFERENCES [dbo].[DeliveryCurrency] ([Currency_Id])
GO

ALTER TABLE [dbo].[CatMoney] CHECK CONSTRAINT [FK_CatMoney_CurrencyId]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla CatMoney' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMoney', @level2type=N'COLUMN',@level2name=N'IdCatMoney'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla DeliveryCurrency, que indica el id de la divisa.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMoney', @level2type=N'COLUMN',@level2name=N'CurrencyId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo del dinero, BILLETE o MONEDA.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMoney', @level2type=N'COLUMN',@level2name=N'Type'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor del dinero.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMoney', @level2type=N'COLUMN',@level2name=N'Value'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de la fila, TRUE o FALSE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMoney', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMoney', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMoney', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que actualizó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMoney', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se actualizó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatMoney', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO


