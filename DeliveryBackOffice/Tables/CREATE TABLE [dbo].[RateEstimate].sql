USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[RateEstimate]    Script Date: 16/07/2020 04:25:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RateEstimate](
	[IdRateEstimated] [bigint] NOT NULL,
	[IdSource] [bigint] NULL,
	[IdDestiny] [bigint] NULL,
	[ObjectType] [nvarchar](50) NULL,
	[CountPieces] [int] NULL,
	[UnitValue] [decimal](5, 2) NULL,
	[IdUnit] [int] NULL,
	[CodeCredit] [nvarchar](10) NULL,
	[IdRate] [int] NULL,
	[EstimateTotalAmount] [decimal](18, 2) NULL,
	[IdCustomer] [int] NULL,
	[IdEcommerce] [int] NULL,
	[DateService] [datetime] NULL,
	[EstimatedStatus] [bit] NULL,
	[TokenCreated] [nvarchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_RateEstimate] PRIMARY KEY CLUSTERED 
(
	[IdRateEstimated] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[RateEstimate]  WITH CHECK ADD  CONSTRAINT [FK_RateEstimate_Customer] FOREIGN KEY([IdCustomer])
REFERENCES [dbo].[Customer] ([IdCustomer])
GO

ALTER TABLE [dbo].[RateEstimate] CHECK CONSTRAINT [FK_RateEstimate_Customer]
GO

ALTER TABLE [dbo].[RateEstimate]  WITH CHECK ADD  CONSTRAINT [FK_RateEstimate_Ecommerce] FOREIGN KEY([IdEcommerce])
REFERENCES [dbo].[Ecommerce] ([IdEcommerce])
GO

ALTER TABLE [dbo].[RateEstimate] CHECK CONSTRAINT [FK_RateEstimate_Ecommerce]
GO

ALTER TABLE [dbo].[RateEstimate]  WITH CHECK ADD  CONSTRAINT [FK_RateEstimate_Settlement] FOREIGN KEY([IdDestiny])
REFERENCES [dbo].[Settlement] ([IdSettlement])
GO

ALTER TABLE [dbo].[RateEstimate] CHECK CONSTRAINT [FK_RateEstimate_Settlement]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of the object to Transport' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateEstimate', @level2type=N'COLUMN',@level2name=N'ObjectType'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Value of Unit Mass Lbs Weight' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateEstimate', @level2type=N'COLUMN',@level2name=N'UnitValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mass Lbs' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RateEstimate', @level2type=N'COLUMN',@level2name=N'IdUnit'
GO


