USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[VisitPointClient]    Script Date: 3/06/2020 16:55:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[VisitPointClient](
	[IdVisitPointClient] [int] IDENTITY(1,1) NOT NULL,
	[CodeOfReference] [int] NOT NULL,
	[DescriptionOfClient] [nvarchar](100) NULL,
	[StatusClient] [bit] NOT NULL,
	[CountryId] [nvarchar](2) NOT NULL,
	[VisitPointId] [bigint] NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
	[CustomerID] [int] NULL,
	[Address] [nvarchar](200) NULL,
	[Zone] [nvarchar](100) NULL,
	[Town] [nvarchar](100) NULL,
	[Department] [nvarchar](100) NULL,
	[Phone] [nvarchar](50) NULL,
	[ContactName] [nvarchar](200) NULL,
 CONSTRAINT [PK_VisitPointClient_1] PRIMARY KEY CLUSTERED 
(
	[CodeOfReference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_CodeOfReferenceporVisitPointId] UNIQUE NONCLUSTERED 
(
	[CodeOfReference] ASC,
	[VisitPointId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[VisitPointClient]  WITH CHECK ADD  CONSTRAINT [FK_VisitPointClient_Customer] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customer] ([IdCustomer])
GO

ALTER TABLE [dbo].[VisitPointClient] CHECK CONSTRAINT [FK_VisitPointClient_Customer]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Desktop Visitpoint' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'VisitPointClient', @level2type=N'COLUMN',@level2name=N'VisitPointId'
GO


