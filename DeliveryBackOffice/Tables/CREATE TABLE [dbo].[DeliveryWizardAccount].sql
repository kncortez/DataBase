USE [DeliveryBackOffice]
GO
/****** Object:  Table [dbo].[DeliveryWizardAccount]    Script Date: 1/25/2021 9:01:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeliveryWizardAccount](
	[IdWizAccount] [int] IDENTITY(1,1) NOT NULL,
	[AccIdAccount] [int] NULL,
	[IdWiz] [int] NULL,
	[StatusAccountWiz] [int] NULL,
	[DateCreate] [datetime] NULL,
	[TokenCreate] [varchar](50) NULL,
	[DateUpdate] [datetime] NULL,
	[TokenUpdate] [varchar](50) NULL
 CONSTRAINT [IdWizAccount] PRIMARY KEY CLUSTERED
(
	[IdWizAccount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO