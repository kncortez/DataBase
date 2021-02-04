USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[DeliveryFavCOD]    Script Date: 1/27/2021 9:01:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DeliveryFavCOD](
	[IdDeliveryFavCOD] [INT] Identity (1,1) NOT NULL,
	[AliasFavCOD] [varchar](50) NULL,
	[NameAccountFavCOD] [varchar](50) NULL,
	[TypeAccountFavCOD] [varchar](50) NULL,
	[DocumentIdFavCOD] [varchar](50) NULL,
	[StatusFavCOD] [int] NULL,
	[IdAccountFavCOD] [int] NULL,
	[TokenCreated] [varchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[TokenUpdate] [varchar](50) NULL,
	[DateUpdate] [datetime] NULL,
	[IdBank] [int] NULL,
	[NumberAccFavCOD] [varchar](50) NULL
 CONSTRAINT [IdDeliveryFavCOD] PRIMARY KEY CLUSTERED 
(
	[IdDeliveryFavCOD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
