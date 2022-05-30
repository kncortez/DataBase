USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[PromoCoverage]    Script Date: 5/28/2022 16:56:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PromoCoverage](
	[IdPromoCoverage] [int] IDENTITY(1,1) NOT NULL,
	[CatPromoId] [int] NOT NULL,
	[CustomerId] [int] NULL,
	[VisitPointClientId] [int] NULL,
	[CustomerTypeId] [int] NULL,
	[RowStatus] [bit] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateUpdated] [datetime] NULL,
	[TokenUpdated] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[IdPromoCoverage] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PromoCoverage]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoverage_CatPromo] FOREIGN KEY([CatPromoId])
REFERENCES [dbo].[CatPromo] ([IdPromo])
GO

ALTER TABLE [dbo].[PromoCoverage] CHECK CONSTRAINT [FK_PromoCoverage_CatPromo]
GO

ALTER TABLE [dbo].[PromoCoverage]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoverage_Customer] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[Customer] ([IdCustomer])
GO

ALTER TABLE [dbo].[PromoCoverage] CHECK CONSTRAINT [FK_PromoCoverage_Customer]
GO

ALTER TABLE [dbo].[PromoCoverage]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoverage_CustomerType] FOREIGN KEY([CustomerTypeId])
REFERENCES [dbo].[CustomerType] ([IdCustomerType])
GO

ALTER TABLE [dbo].[PromoCoverage] CHECK CONSTRAINT [FK_PromoCoverage_CustomerType]
GO

ALTER TABLE [dbo].[PromoCoverage]  WITH CHECK ADD  CONSTRAINT [FK_PromoCoverage_VisitPointClient] FOREIGN KEY([VisitPointClientId])
REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
GO

ALTER TABLE [dbo].[PromoCoverage] CHECK CONSTRAINT [FK_PromoCoverage_VisitPointClient]
GO

ALTER TABLE [dbo].[PromoCoverage]  WITH CHECK ADD  CONSTRAINT [CHK_PromoCoverage_Minimum] CHECK  ((isnull([CustomerId],(0))>(0) OR isnull([VisitPointClientId],(0))>(0) OR isnull([CustomerTypeId],(0))>(0)))
GO

ALTER TABLE [dbo].[PromoCoverage] CHECK CONSTRAINT [CHK_PromoCoverage_Minimum]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoverage', @level2type=N'COLUMN',@level2name=N'IdPromoCoverage'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la promoción.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoverage', @level2type=N'COLUMN',@level2name=N'CatPromoId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referente a la creación de cupones, identificador de cliente a quien aplica la promoción.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoverage', @level2type=N'COLUMN',@level2name=N'CustomerId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referente a la creación de cupones, identificador de punto de visita al cual aplica la promoción.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoverage', @level2type=N'COLUMN',@level2name=N'VisitPointClientId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referente a la creación de cupones, identificador de tipo de cliente a quienes aplica la promoción.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoverage', @level2type=N'COLUMN',@level2name=N'CustomerTypeId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoverage', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoverage', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoverage', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Última fecha de actualización.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoverage', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Último token de actualización.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoverage', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cobertura de promociones basada en cleinte, punto de visita o tipo de cliente.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PromoCoverage'
GO


