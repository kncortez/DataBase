
CREATE TABLE [dbo].[ExtPlatformService](
	[IdExtPlatformService] [int] IDENTITY(1,1) NOT NULL,
	[ExtPlatformId] [int] NOT NULL,
	[serviceEPId] [int] NOT NULL,
	[referenceEP] [nvarchar](20) NULL,
	[TrackingEPData] [nvarchar](150) NULL,
	[PlanEP] [nvarchar](200) NULL,
	[RouteEP] [nvarchar](200) NULL,
	[AddressEP] [nvarchar](200) NOT NULL,
	[PlannedDateEP] [datetime] NULL,
	[LatitudeEP] [decimal](18, 15) NOT NULL,
	[LongitudeEP] [decimal](18, 15) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateCompleted] [datetime] NULL,
	[StartServiceDateTime] [datetime] NOT NULL,
	[EndServiceDatetime] [datetime] NOT NULL,
	[RowStatus] [int] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdExtPlatformService] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ExtPlatformService] ADD  DEFAULT ((1)) FOR [RowStatus]
GO

ALTER TABLE [dbo].[ExtPlatformService]  WITH CHECK ADD  CONSTRAINT [ExtPlatformService_PlatformId_FK] FOREIGN KEY([ExtPlatformId])
REFERENCES [dbo].[CatExternalPlatform] ([IdExternalPlatform])
GO

ALTER TABLE [dbo].[ExtPlatformService] CHECK CONSTRAINT [ExtPlatformService_PlatformId_FK]
GO

