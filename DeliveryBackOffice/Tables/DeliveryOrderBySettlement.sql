USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[DeliveryOrderBySettlement]    Script Date: 3/06/2020 16:53:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DeliveryOrderBySettlement](
	[Guide_Serie] [nvarchar](2) NOT NULL,
	[Guide_Number] [int] NOT NULL,
	[Pieces_Dry_read] [int] NOT NULL,
	[Pieces_Cold_read] [int] NOT NULL,
	[Received_Date] [datetime] NOT NULL,
 CONSTRAINT [PK_DeliveryOrderBySettlement] PRIMARY KEY CLUSTERED 
(
	[Guide_Serie] ASC,
	[Guide_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DeliveryOrderBySettlement]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryOrderBySettlement] FOREIGN KEY([Guide_Serie], [Guide_Number])
REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
GO

ALTER TABLE [dbo].[DeliveryOrderBySettlement] CHECK CONSTRAINT [FK_DeliveryOrderBySettlement]
GO


