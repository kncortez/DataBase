USE [DeliveryBackOffice]
GO

CREATE TABLE [dbo].[RateData](
	[IdRateData] [bigint] IDENTITY(1,1) NOT NULL,
	[RateId] [int] NOT NULL,
	[TypeServiceId] [int]  NULL,
	[TypeSegmentId] [int] NULL,
	
	[HubSourceId] [int] NULL,
	[HubDestinyId] [int] NULL,
	[ArticleId] [int] NULL,

	[RateValue] [decimal](14, 2) NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,

	primary key ([IdRateData]) ,
	CONSTRAINT FKRateDetId FOREIGN KEY (RateId) REFERENCES RateHeader(RheId)
	,CONSTRAINT FKRateServiceId FOREIGN KEY (TypeServiceId) REFERENCES CatTypeService(CtsId)
	,CONSTRAINT FKRateSegmentId FOREIGN KEY (TypeSegmentId) REFERENCES CatRateSegment(CrsId)
	,CONSTRAINT FKRateHubSourceId FOREIGN KEY (HubSourceId) REFERENCES HubLogistics(IdHubLogistic)
	,CONSTRAINT FKRateHubDestinyId FOREIGN KEY (HubDestinyId) REFERENCES HubLogistics(IdHubLogistic)
	,CONSTRAINT FKRateArticuleId FOREIGN KEY [ArticleId] REFERENCES ArticleByCustomer(AbcId)

	)


	--select * from dbo.RateHeader
	--select * from dbo.CatTypeService
	--select * from dbo.CatRateSegment
	--select top 3 * from dbo.HubLogistics
	--select * from dbo.ArticleByCustomer
	--select * from dbo.StatusOrder