USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[DeliveryAttempt]    Script Date: 31/07/2020 15:45:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DeliveryAttempt](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Guide_Serie] [nvarchar](2) NOT NULL,
	[Guide_Number] [int] NOT NULL,
	[Dry] [bit] NOT NULL,
	[Cold] [bit] NOT NULL,
	[Latitude] [nvarchar](20) NULL,
	[Longitude] [nvarchar](20) NULL,
	[Delivered] [bit] NOT NULL,
	[ID_Courier] [int] NOT NULL,
	[ID_DeliveryOrderBySettlement] [bigint] NULL,
	[User_Created] [nvarchar](50) NOT NULL,
	[Date_Created] [datetime] NOT NULL,
 CONSTRAINT [PK_DeliveryAttempt] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DeliveryAttempt]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryAttempt_DeliveryOrder] FOREIGN KEY([Guide_Serie], [Guide_Number])
REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
GO

ALTER TABLE [dbo].[DeliveryAttempt] CHECK CONSTRAINT [FK_DeliveryAttempt_DeliveryOrder]
GO

ALTER TABLE [dbo].[DeliveryAttempt]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryAttempt_IDCourier] FOREIGN KEY([ID_Courier])
REFERENCES [dbo].[SenderReceiver] ([ID])
GO

ALTER TABLE [dbo].[DeliveryAttempt] CHECK CONSTRAINT [FK_DeliveryAttempt_IDCourier]
GO


