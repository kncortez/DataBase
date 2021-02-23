USE [DeliveryBackOffice]
GO
/****** Object:  Table [dbo].[CatWizard]    Script Date: 1/25/2021 9:01:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CatWizard](
	[IdWiz] [int] Identity (1,1) NOT NULL,
	[NameWiz] [varchar](50) NULL,
	[DescriptionWiz] [varchar](80) NULL,
	[StatusWiz] [int] NULL,
	[DateCreate] [datetime] NULL,
	[TokenCreate] [varchar](50) NULL,
	[DateUpdate] [datetime] NULL,
	[TokenUpdate] [varchar](50) NULL
 CONSTRAINT [IdWiz] PRIMARY KEY CLUSTERED
(
	[IdWiz] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO