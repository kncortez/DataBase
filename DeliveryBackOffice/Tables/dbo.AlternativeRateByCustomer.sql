USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[AlternativeRateByCustomer]    Script Date: 6/16/2022 08:12:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AlternativeRateByCustomer](
	[IdAlternativeRatebyCustomer] [bigint] IDENTITY(1,1) NOT NULL,
	[RateId] [int] NOT NULL,
	[CustomerId] [int] NOT NULL,
	[VisitPointClientId] [int] NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdAlternativeRatebyCustomer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AlternativeRateByCustomer]  WITH CHECK ADD  CONSTRAINT [FK_AlternativeRates_Customer] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[Customer] ([IdCustomer])
GO

ALTER TABLE [dbo].[AlternativeRateByCustomer] CHECK CONSTRAINT [FK_AlternativeRates_Customer]
GO

ALTER TABLE [dbo].[AlternativeRateByCustomer]  WITH CHECK ADD  CONSTRAINT [FK_AlternativeRates_Rate] FOREIGN KEY([RateId])
REFERENCES [dbo].[RateHeader] ([RheId])
GO

ALTER TABLE [dbo].[AlternativeRateByCustomer] CHECK CONSTRAINT [FK_AlternativeRates_Rate]
GO

ALTER TABLE [dbo].[AlternativeRateByCustomer]  WITH CHECK ADD  CONSTRAINT [FK_AlternativeRates_VPC] FOREIGN KEY([VisitPointClientId])
REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
GO

ALTER TABLE [dbo].[AlternativeRateByCustomer] CHECK CONSTRAINT [FK_AlternativeRates_VPC]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AlternativeRateByCustomer', @level2type=N'COLUMN',@level2name=N'IdAlternativeRatebyCustomer'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del tarifario de la tabla RateHeader.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AlternativeRateByCustomer', @level2type=N'COLUMN',@level2name=N'RateId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del cliente de la tabla Customer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AlternativeRateByCustomer', @level2type=N'COLUMN',@level2name=N'CustomerId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Campo para vincular tarifario con un punto de visita.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AlternativeRateByCustomer', @level2type=N'COLUMN',@level2name=N'VisitPointClientId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AlternativeRateByCustomer', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AlternativeRateByCustomer', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AlternativeRateByCustomer', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Último token de actualización.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AlternativeRateByCustomer', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Última fecha de actualización.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AlternativeRateByCustomer', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla de tarifas alternativas por cliente.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AlternativeRateByCustomer'
GO


