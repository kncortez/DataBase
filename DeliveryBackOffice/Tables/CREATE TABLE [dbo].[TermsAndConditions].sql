USE [DeliveryBackOffice]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TermsAndConditions](
	[IdTAC] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](250) NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdTAC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

GO


