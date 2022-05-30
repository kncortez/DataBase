USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[PromoCoupon]    Script Date: 5/28/2022 17:23:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PromoCoupon](
	[IdPromoCoupon] [int] IDENTITY(1,1) NOT NULL,
	[CatPromoId] [int] NOT NULL,
	[PromoCouponSerie] [nvarchar](20) NOT NULL,
	[GuideSerieOrigin] [nvarchar](2) NULL,
	[GuideNumberOrigin] [int] NULL,
	[ServiceManagementOrigin] [int] NULL,
	[SystemOrigin] [int] NOT NULL,
	[CustomerOrigin] [int] NULL,
	[VisitPointClientOrigin] [int] NULL,
	[VisitPointClientPortfolioOrigin] [bigint] NULL,
	[GuideSerieDestination] [nvarchar](2) NULL,
	[GuideNumberDestination] [int] NULL,
	[ServiceManagementDestination] [int] NULL,
	[SystemDestination] [int] NULL,
	[CustomerDestination] [int] NULL,
	[VisitPointClientDestination] [int] NULL,
	[VisitPointClientPortfolioDestination] [bigint] NULL,
	[CatDiscountTypeId] [int] NOT NULL,
	[CatValueTypeId] [int] NOT NULL,
	[CouponValue] [decimal](5, 2) NOT NULL,
	[OriginalAmount] [decimal](18, 2) NULL,
	[DiscountAmount] [decimal](18, 2) NULL,
	[FinalAmount] [decimal](18, 2) NULL,
	[RedeemedDate] [datetime] NULL,
	[StartActiveDate] [datetime] NOT NULL,
	[FinalActiveDate] [datetime] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateUpdated] [datetime] NULL,
	[TokenUpdated] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[IdPromoCoupon] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PromoCoupon]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoupon_CatPromo] FOREIGN KEY([CatPromoId])
REFERENCES [dbo].[CatPromo] ([IdPromo])
GO

ALTER TABLE [dbo].[PromoCoupon] CHECK CONSTRAINT [FK_PromoCoupon_CatPromo]
GO

ALTER TABLE [dbo].[PromoCoupon]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoupon_CustomerDestination] FOREIGN KEY([CustomerDestination])
REFERENCES [dbo].[Customer] ([IdCustomer])
GO

ALTER TABLE [dbo].[PromoCoupon] CHECK CONSTRAINT [FK_PromoCoupon_CustomerDestination]
GO

ALTER TABLE [dbo].[PromoCoupon]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoupon_CustomerOrigin] FOREIGN KEY([CustomerOrigin])
REFERENCES [dbo].[Customer] ([IdCustomer])
GO

ALTER TABLE [dbo].[PromoCoupon] CHECK CONSTRAINT [FK_PromoCoupon_CustomerOrigin]
GO

ALTER TABLE [dbo].[PromoCoupon]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoupon_DiscountType] FOREIGN KEY([CatDiscountTypeId])
REFERENCES [dbo].[CatTypeDiscount] ([IdCatTypeDiscount])
GO

ALTER TABLE [dbo].[PromoCoupon] CHECK CONSTRAINT [FK_PromoCoupon_DiscountType]
GO

ALTER TABLE [dbo].[PromoCoupon]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoupon_GuideDestination] FOREIGN KEY([GuideSerieDestination], [GuideNumberDestination])
REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
GO

ALTER TABLE [dbo].[PromoCoupon] CHECK CONSTRAINT [FK_PromoCoupon_GuideDestination]
GO

ALTER TABLE [dbo].[PromoCoupon]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoupon_GuideOrigin] FOREIGN KEY([GuideSerieOrigin], [GuideNumberOrigin])
REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
GO

ALTER TABLE [dbo].[PromoCoupon] CHECK CONSTRAINT [FK_PromoCoupon_GuideOrigin]
GO

ALTER TABLE [dbo].[PromoCoupon]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoupon_ServiceDestination] FOREIGN KEY([ServiceManagementDestination])
REFERENCES [dbo].[ServiceManagement] ([IdServiceManagement])
GO

ALTER TABLE [dbo].[PromoCoupon] CHECK CONSTRAINT [FK_PromoCoupon_ServiceDestination]
GO

ALTER TABLE [dbo].[PromoCoupon]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoupon_ServiceOrigin] FOREIGN KEY([ServiceManagementOrigin])
REFERENCES [dbo].[ServiceManagement] ([IdServiceManagement])
GO

ALTER TABLE [dbo].[PromoCoupon] CHECK CONSTRAINT [FK_PromoCoupon_ServiceOrigin]
GO

ALTER TABLE [dbo].[PromoCoupon]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoupon_SystemDestination] FOREIGN KEY([SystemDestination])
REFERENCES [dbo].[CatSystem] ([SysIdSystem])
GO

ALTER TABLE [dbo].[PromoCoupon] CHECK CONSTRAINT [FK_PromoCoupon_SystemDestination]
GO

ALTER TABLE [dbo].[PromoCoupon]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoupon_SystemOrigin] FOREIGN KEY([SystemOrigin])
REFERENCES [dbo].[CatSystem] ([SysIdSystem])
GO

ALTER TABLE [dbo].[PromoCoupon] CHECK CONSTRAINT [FK_PromoCoupon_SystemOrigin]
GO

ALTER TABLE [dbo].[PromoCoupon]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoupon_ValueType] FOREIGN KEY([CatValueTypeId])
REFERENCES [dbo].[CatValueType] ([IdCatValueType])
GO

ALTER TABLE [dbo].[PromoCoupon] CHECK CONSTRAINT [FK_PromoCoupon_ValueType]
GO

ALTER TABLE [dbo].[PromoCoupon]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoupon_VisitPointClientDestination] FOREIGN KEY([VisitPointClientDestination])
REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
GO

ALTER TABLE [dbo].[PromoCoupon] CHECK CONSTRAINT [FK_PromoCoupon_VisitPointClientDestination]
GO

ALTER TABLE [dbo].[PromoCoupon]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoupon_VisitPointClientOrigin] FOREIGN KEY([VisitPointClientOrigin])
REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
GO

ALTER TABLE [dbo].[PromoCoupon] CHECK CONSTRAINT [FK_PromoCoupon_VisitPointClientOrigin]
GO

ALTER TABLE [dbo].[PromoCoupon]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoupon_VisitPointClientPortfolioDestination] FOREIGN KEY([VisitPointClientPortfolioDestination])
REFERENCES [dbo].[VisitPointByClientPortfolio] ([IdVisitPointByClientPortfolio])
GO

ALTER TABLE [dbo].[PromoCoupon] CHECK CONSTRAINT [FK_PromoCoupon_VisitPointClientPortfolioDestination]
GO

ALTER TABLE [dbo].[PromoCoupon]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoupon_VisitPointClientPortfolioOrigin] FOREIGN KEY([VisitPointClientPortfolioOrigin])
REFERENCES [dbo].[VisitPointByClientPortfolio] ([IdVisitPointByClientPortfolio])
GO

ALTER TABLE [dbo].[PromoCoupon] CHECK CONSTRAINT [FK_PromoCoupon_VisitPointClientPortfolioOrigin]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'IdPromoCoupon'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la promoción relacionada al cupon.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'CatPromoId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie del cupon, dato que identifica al cupon.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'PromoCouponSerie'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie de la guía que genero el cupon, si existiese.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'GuideSerieOrigin'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de la guía que genero el cupon, si existiese.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'GuideNumberOrigin'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del servicio que genero el cupon, si existiese.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'ServiceManagementOrigin'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del sistema donde se origino el cupon.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'SystemOrigin'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del cliente que genero el cupon.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'CustomerOrigin'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del punto de visita que genero el cupon.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'VisitPointClientOrigin'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la cartera de clientes que genero el cupon' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'VisitPointClientPortfolioOrigin'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie de la guía donde se utilizo el cupon, si existiese.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'GuideSerieDestination'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de la guía donde se utilizo el cupon, si existiese.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'GuideNumberDestination'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del servicio donde se utilizo el cupon, si existiese.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'ServiceManagementDestination'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del sistema donde se utilizo el cupon.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'SystemDestination'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del cliente que utilizo el cupon.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'CustomerDestination'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del punto de visita donde se utilizo el cupon.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'VisitPointClientDestination'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la cartera de clientes donde se utilizo el cupon.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'VisitPointClientPortfolioDestination'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del tipo de descuento que aplica el cupon.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'CatDiscountTypeId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del tipo de valor para realizar el descuento.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'CatValueTypeId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor del descuento a realizar.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'CouponValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto original de la guía o servicio.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'OriginalAmount'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto descontado del valor de la guía o servicio.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'DiscountAmount'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor final tras aplicar el descuento de la guía o servicio.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'FinalAmount'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha en la que se utilizo el cupon.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'RedeemedDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha inicial para poder canjear el cupon.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'StartActiveDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha final para poder canjear el cupon.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'FinalActiveDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Última fecha de actualización.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Último token de actualización.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla de cupones generados.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoupon'
GO


