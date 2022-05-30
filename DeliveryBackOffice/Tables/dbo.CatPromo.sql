USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatPromo]    Script Date: 5/28/2022 16:34:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatPromo](
	[IdPromo] [int] IDENTITY(1,1) NOT NULL,
	[PromoDescription] [nvarchar](200) NOT NULL,
	[PromoWeight] [int] NOT NULL,
	[StartPromoDate] [datetime] NOT NULL,
	[FinishPromoDate] [datetime] NOT NULL,
	[LimitPromoTime] [decimal](6, 2) NULL,
	[Monday] [bit] NOT NULL,
	[Tuesday] [bit] NOT NULL,
	[Wednesday] [bit] NOT NULL,
	[Thursday] [bit] NOT NULL,
	[Friday] [bit] NOT NULL,
	[Saturday] [bit] NOT NULL,
	[Sunday] [bit] NOT NULL,
	[CatValueTypeId] [int] NOT NULL,
	[PromoValue] [decimal](5, 2) NOT NULL,
	[CatDiscountTypeId] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateUpdated] [datetime] NULL,
	[TokenUpdated] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[IdPromo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatPromo]  WITH CHECK ADD  CONSTRAINT [FK_CatPromo_CatDiscountType] FOREIGN KEY([CatDiscountTypeId])
REFERENCES [dbo].[CatTypeDiscount] ([IdCatTypeDiscount])
GO

ALTER TABLE [dbo].[CatPromo] CHECK CONSTRAINT [FK_CatPromo_CatDiscountType]
GO

ALTER TABLE [dbo].[CatPromo]  WITH CHECK ADD  CONSTRAINT [FK_CatPromo_CatValueType] FOREIGN KEY([CatValueTypeId])
REFERENCES [dbo].[CatValueType] ([IdCatValueType])
GO

ALTER TABLE [dbo].[CatPromo] CHECK CONSTRAINT [FK_CatPromo_CatValueType]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'IdPromo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de la promoción.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'PromoDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor que determina la generación de un cupon en relación a otros (Mayor peso implica que se genera sobre los que tienen menor peso).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'PromoWeight'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referente a la generación de cupones, fecha de inicio de valides de la promoción.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'StartPromoDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referente a la generación de cupones, fecha final de valides de la promoción.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'FinishPromoDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referente a la generación de cupones, indica si se pueden generar cupones los lunes.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'Monday'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referente a la generación de cupones, indica si se pueden generar cupones los martes.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'Tuesday'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referente a la generación de cupones, indica si se pueden generar cupones los miercoles.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'Wednesday'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referente a la generación de cupones, indica si se pueden generar cupones los jueves.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'Thursday'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referente a la generación de cupones, indica si se pueden generar cupones los viernes.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'Friday'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referente a la generación de cupones, indica si se pueden generar cupones los sabados.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'Saturday'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referente a la generación de cupones, indica si se pueden generar cupones los domingos.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'Sunday'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del tipo de valor a descontar en la promoción (Ej: %, Q, etc.).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'CatValueTypeId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor a descontar de la promoción.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'PromoValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del tipo de descuento a realizar (Ej: Base, Total, etc.),' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'CatDiscountTypeId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Última fecha de actualización.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Último token de actualziación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tiempo de valides de los cupones de la promoción (En horas).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo', @level2type=N'COLUMN',@level2name=N'LimitPromoTime'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Catálogo de promociones' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPromo'
GO


