USE [DeliveryBackOffice]
GO

BEGIN TRAN

/****** Object:  Table [dbo].[ProcessedGuideCOD]    Script Date: 17/06/2021 12:00:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ProcessedGuideCOD](
	[IdProcessedGuideCOD] [int] IDENTITY(1,1) NOT NULL,
	[GuideSerie] [nvarchar](2) NOT NULL,
	[GuideNumber] [int] NOT NULL,
	[CourierManId] [int] NULL,
	[Date] [datetime] NOT NULL,
	[BatchCODId] [int] NULL,
	[BatchCODIdCommission] [int] NULL,
	[DataOriginId] [int] NOT NULL,
	[Notificated] [bit] NOT NULL,
	[Token] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ProcessedGuideCOD_IdProcessedGuideCOD] PRIMARY KEY CLUSTERED 
(
	[IdProcessedGuideCOD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_ProcessedGuideCOD_GuideSerie_GuideNumber] UNIQUE NONCLUSTERED 
(
	[GuideNumber] ASC,
	[GuideSerie] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ProcessedGuideCOD] ADD  CONSTRAINT [DF_ProcessedGuideCOD_Date]  DEFAULT (getdate()) FOR [Date]
GO

ALTER TABLE [dbo].[ProcessedGuideCOD] ADD  CONSTRAINT [DF_ProcessedGuideCOD_Notificated]  DEFAULT ('FALSE') FOR [Notificated]
GO

ALTER TABLE [dbo].[ProcessedGuideCOD]  WITH CHECK ADD  CONSTRAINT [FK_ProcessedGuideCOD_BatchCOD] FOREIGN KEY([BatchCODId])
REFERENCES [dbo].[BatchCOD] ([IdBatchCOD])
GO

ALTER TABLE [dbo].[ProcessedGuideCOD] CHECK CONSTRAINT [FK_ProcessedGuideCOD_BatchCOD]
GO

ALTER TABLE [dbo].[ProcessedGuideCOD]  WITH CHECK ADD  CONSTRAINT [FK_ProcessedGuideCOD_BatchCOD_BatchCODIdCommission] FOREIGN KEY([BatchCODIdCommission])
REFERENCES [dbo].[BatchCOD] ([IdBatchCOD])
GO

ALTER TABLE [dbo].[ProcessedGuideCOD] CHECK CONSTRAINT [FK_ProcessedGuideCOD_BatchCOD_BatchCODIdCommission]
GO

ALTER TABLE [dbo].[ProcessedGuideCOD]  WITH CHECK ADD  CONSTRAINT [FK_ProcessedGuideCOD_CatModule] FOREIGN KEY([DataOriginId])
REFERENCES [dbo].[CatModule] ([ModIdModule])
GO

ALTER TABLE [dbo].[ProcessedGuideCOD] CHECK CONSTRAINT [FK_ProcessedGuideCOD_CatModule]
GO

ALTER TABLE [dbo].[ProcessedGuideCOD]  WITH CHECK ADD  CONSTRAINT [FK_ProcessedGuideCOD_DeliveryOrder] FOREIGN KEY([GuideSerie], [GuideNumber])
REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
GO

ALTER TABLE [dbo].[ProcessedGuideCOD] CHECK CONSTRAINT [FK_ProcessedGuideCOD_DeliveryOrder]
GO

ALTER TABLE [dbo].[ProcessedGuideCOD]  WITH CHECK ADD  CONSTRAINT [FK_ProcessedGuideCOD_SenderReceiver] FOREIGN KEY([CourierManId])
REFERENCES [dbo].[SenderReceiver] ([ID])
GO

ALTER TABLE [dbo].[ProcessedGuideCOD] CHECK CONSTRAINT [FK_ProcessedGuideCOD_SenderReceiver]
GO

--COMMIT


