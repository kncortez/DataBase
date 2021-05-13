USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[InternalUser]    Script Date: 13/05/2021 10:34:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[VisitPointByUser](
	[IdVisitPointByUser] [bigint] IDENTITY NOT NULL,
	[IdVisitPointClient] [INT] NOT NULL,
	[RegisterUserID] [bigint] NULL,
	[RowStatus] [bit] NULL,
	[TokenCreated] [nvarchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdVisitPointByUser]  ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] 
GO

ALTER TABLE [dbo].[VisitPointByUser] ADD  CONSTRAINT [DF_VisitPointByUser_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

ALTER TABLE [dbo].[VisitPointByUser]  WITH CHECK ADD  CONSTRAINT [FK_VisitPointByUser_RegisterUser] FOREIGN KEY([RegisterUserID])
REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
GO

ALTER TABLE [dbo].[InternalUser] CHECK CONSTRAINT [FK_InternalUser_RegisterUser]
GO

