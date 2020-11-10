USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[Delivery_DataRestrictionByRol]    Script Date: 3/11/2020 15:02:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Delivery_DataRestrictionByRol](
	[DRR_IdRol] [int] NOT NULL,
	[DRR_IdCountry] [varchar](2) NOT NULL,
	[DRR_IdHubLogistic] [int] NOT NULL,
	[DRR_IdModule] [int] NOT NULL,
	[DRR_IdVisitPointClient] [int] NOT NULL,
	[DRR_Status] [bit] NOT NULL,
 CONSTRAINT [PK_LGN_DataRestrictionByRol] PRIMARY KEY CLUSTERED 
(
	[DRR_IdRol] ASC,
	[DRR_IdCountry] ASC,
	[DRR_IdHubLogistic] ASC,
	[DRR_IdModule] ASC,
	[DRR_IdVisitPointClient] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


