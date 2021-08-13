
CREATE TABLE [dbo].[ServiceDataForGuide](
	[ServiceDataForGuideId] [bigint] IDENTITY(1,1) NOT NULL,
	[Guide_Serie] [nvarchar](2) NOT NULL,
	[Guide_Number] [int] NOT NULL,
	[Guide_Token] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[Latitude] [decimal](18, 15) NULL,
	[Longitude] [decimal](18, 15) NULL,
	[startTime] [time](7) NULL,
	[endTime] [time](7) NULL,
	[DateUsed] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ServiceDataForGuideId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ServiceDataForGuide]  WITH CHECK ADD  CONSTRAINT [ServiceDataForGuide_FK] FOREIGN KEY([Guide_Serie], [Guide_Number])
REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
GO

ALTER TABLE [dbo].[ServiceDataForGuide] CHECK CONSTRAINT [ServiceDataForGuide_FK]
GO

