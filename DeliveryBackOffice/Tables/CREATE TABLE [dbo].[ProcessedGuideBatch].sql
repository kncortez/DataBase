USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[ProcessedGuideBatch]    Script Date: 10/05/2022 10:56:29 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ProcessedGuideBatch](
	[IdProcessedGuideBatch] [int] IDENTITY(1,1) NOT NULL,
	[GuideSerie] [nvarchar](2) NOT NULL,
	[GuideNumber] [int] NOT NULL,
	[CourierManId] [int] NULL,
	[Date] [datetime] NOT NULL,
	[BatchId] [int] NULL,
	[CatBatchId] [int] NULL,
	[DataOriginId] [int] NOT NULL,
	[Notificated] [bit] NOT NULL,
	[Token] [varchar](50) NOT NULL,
	[BatchNotified] [bit] NULL,
	[DeliveryReportNotified] [bit] NULL,
	[DateUpdated] [datetime] NULL,
	[TokenUpdated] [varchar](50) NULL,
	[RowStatus] [bit] NOT NULL,
	[CustomerId] [int] NULL,
 CONSTRAINT [PK_ProcessedGuideBatch_ProcessedGuideBatch] PRIMARY KEY CLUSTERED 
(
	[IdProcessedGuideBatch] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ProcessedGuideBatch] ADD  CONSTRAINT [DF_ProcessedGuideBatch_Date]  DEFAULT (getdate()) FOR [Date]
GO

ALTER TABLE [dbo].[ProcessedGuideBatch] ADD  CONSTRAINT [DF_ProcessedGuideBatch_Notificated]  DEFAULT ('FALSE') FOR [Notificated]
GO

ALTER TABLE [dbo].[ProcessedGuideBatch] ADD  CONSTRAINT [DF_ProcessedGuideBatch_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

ALTER TABLE [dbo].[ProcessedGuideBatch]  WITH CHECK ADD  CONSTRAINT [FK_ProcessedGuideBatch_CatBatchId] FOREIGN KEY([CatBatchId])
REFERENCES [dbo].[CatBatch] ([IdCatBatch])
GO

ALTER TABLE [dbo].[ProcessedGuideBatch] CHECK CONSTRAINT [FK_ProcessedGuideBatch_CatBatchId]
GO

ALTER TABLE [dbo].[ProcessedGuideBatch]  WITH CHECK ADD  CONSTRAINT [FK_ProcessedGuideBatch_CatModule] FOREIGN KEY([DataOriginId])
REFERENCES [dbo].[CatModule] ([ModIdModule])
GO

ALTER TABLE [dbo].[ProcessedGuideBatch] CHECK CONSTRAINT [FK_ProcessedGuideBatch_CatModule]
GO

ALTER TABLE [dbo].[ProcessedGuideBatch]  WITH CHECK ADD  CONSTRAINT [FK_ProcessedGuideBatch_DeliveryOrder] FOREIGN KEY([GuideSerie], [GuideNumber])
REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
GO

ALTER TABLE [dbo].[ProcessedGuideBatch] CHECK CONSTRAINT [FK_ProcessedGuideBatch_DeliveryOrder]
GO

ALTER TABLE [dbo].[ProcessedGuideBatch]  WITH CHECK ADD  CONSTRAINT [FK_ProcessedGuideBatch_SenderReceiver] FOREIGN KEY([CourierManId])
REFERENCES [dbo].[SenderReceiver] ([ID])
GO

ALTER TABLE [dbo].[ProcessedGuideBatch] CHECK CONSTRAINT [FK_ProcessedGuideBatch_SenderReceiver]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Flag para poder saber cuando el correo de lote fue enviado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProcessedGuideBatch', @level2type=N'COLUMN',@level2name=N'BatchNotified'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id del Cliente al que le pertenece la guía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProcessedGuideBatch', @level2type=N'COLUMN',@level2name=N'CustomerId'
GO


