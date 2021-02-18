USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatCountry]    Script Date: 1/23/2021 5:01:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LogTokenPOD](
	[IdLogToken] [INT] Identity (1,1) NOT NULL,
	[LogTokenPOD] [varchar](200) NULL,
	[IdCourierman] int NULL
 CONSTRAINT [PK_IdLogToken] PRIMARY KEY CLUSTERED 
(
	[IdLogToken] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


