CREATE TABLE [dbo].[CatSubscription](
	[IdCatSubscription] [int] IDENTITY(1,1) NOT NULL,
	[SubscriptionName] [nvarchar](50) NOT NULL,
	[SubscriptionDescription] [nvarchar](300) NULL,
	[SubscriptionCost] [decimal](18, 2) NULL,
	[SubscriptionFixedValue] [int] NOT NULL,
	[SubscriptionMaxServiceFixedValue] [int] NOT NULL,
	[SubscriptionValidity] [int] NOT NULL,
	[SubscriptionWeight] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
	[Icon] [nvarchar](50) NULL,
	[NextSalesPackageBanner] [nvarchar](200) NULL,
	[RateHeaderId] [int] NULL,
	[AlternativeRateHeaderId] [int] NULL,
	[IncludedMembershipId] [int] NULL,
	[CatTypeSubscriptionId] [int] NULL,
	[CatProductCategoryId] [int] NULL,
	[Tag] [nvarchar](100) NULL,
	[Position] [int] NULL,
 CONSTRAINT [PK_CatSubscription] PRIMARY KEY CLUSTERED 
(
	[IdCatSubscription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatSubscription] ADD  CONSTRAINT [DF_CatSubscription_RowStatus]  DEFAULT ((1)) FOR [RowStatus]
GO

ALTER TABLE [dbo].[CatSubscription]  WITH CHECK ADD  CONSTRAINT [FK_CatSubscription_AlternativeRate] FOREIGN KEY([AlternativeRateHeaderId])
REFERENCES [dbo].[RateHeader] ([RheId])
GO

ALTER TABLE [dbo].[CatSubscription] CHECK CONSTRAINT [FK_CatSubscription_AlternativeRate]
GO

ALTER TABLE [dbo].[CatSubscription]  WITH CHECK ADD  CONSTRAINT [FK_CatSubscription_CatMembership] FOREIGN KEY([IncludedMembershipId])
REFERENCES [dbo].[CatMembership] ([IdCatMembership])
GO

ALTER TABLE [dbo].[CatSubscription] CHECK CONSTRAINT [FK_CatSubscription_CatMembership]
GO

ALTER TABLE [dbo].[CatSubscription]  WITH CHECK ADD  CONSTRAINT [FK_CatSubscription_CatProductCategory] FOREIGN KEY([CatProductCategoryId])
REFERENCES [dbo].[CatProductCategory] ([IdCatProductCategory])
GO

ALTER TABLE [dbo].[CatSubscription] CHECK CONSTRAINT [FK_CatSubscription_CatProductCategory]
GO

ALTER TABLE [dbo].[CatSubscription]  WITH CHECK ADD  CONSTRAINT [FK_CatSubscription_CatTypeSubscription] FOREIGN KEY([CatTypeSubscriptionId])
REFERENCES [dbo].[CatTypeSubscription] ([IdCatTypeSubscription])
GO

ALTER TABLE [dbo].[CatSubscription] CHECK CONSTRAINT [FK_CatSubscription_CatTypeSubscription]
GO

ALTER TABLE [dbo].[CatSubscription]  WITH CHECK ADD  CONSTRAINT [FK_CatSubscription_Rate] FOREIGN KEY([RateHeaderId])
REFERENCES [dbo].[RateHeader] ([RheId])
GO

ALTER TABLE [dbo].[CatSubscription] CHECK CONSTRAINT [FK_CatSubscription_Rate]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de banner a desplegar cuando servicios de monto fijo esten proximos a acabarse' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatSubscription', @level2type=N'COLUMN',@level2name=N'NextSalesPackageBanner'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tarifario a utilizar cuando se usa suscripción' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatSubscription', @level2type=N'COLUMN',@level2name=N'RateHeaderId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tarifario alterno a utilizar cuando se usa suscripción' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatSubscription', @level2type=N'COLUMN',@level2name=N'AlternativeRateHeaderId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indicativo si suscripci?n contiene una membres?a incluida y cual membres?a es de la tabla CatMembership' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatSubscription', @level2type=N'COLUMN',@level2name=N'IncludedMembershipId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id relacion con tabla CatTypeSubscription' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatSubscription', @level2type=N'COLUMN',@level2name=N'CatTypeSubscriptionId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id relacion con tabla CatProductCategory' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatSubscription', @level2type=N'COLUMN',@level2name=N'CatProductCategoryId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'etiqueta de identificación del producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatSubscription', @level2type=N'COLUMN',@level2name=N'Tag'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'campo para el ordenamiento por  Posición ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatSubscription', @level2type=N'COLUMN',@level2name=N'Position'
GO
