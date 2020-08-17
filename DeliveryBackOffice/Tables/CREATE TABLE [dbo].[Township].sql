USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[Township]    Script Date: 16/07/2020 02:14:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Township](
	[IdTownship] [int] IDENTITY(1,1) NOT NULL,
	[TownshipName] [nvarchar](50) NULL,
	[TownshipDescription] [nvarchar](50) NULL,
	[TownshipLatitud] [decimal](9, 6) NULL,
	[TownshipLongitud] [decimal](9, 6) NULL,
	[PostalCode] [nvarchar](5) NULL,
	[TownshipStatus] [bit] NULL,
	[IdProvince] [int] NULL,
	[TokenCreated] [nvarchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DatedUpdated] [datetime] NULL,
 CONSTRAINT [PK_Township] PRIMARY KEY CLUSTERED 
(
	[IdTownship] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Township]  WITH CHECK ADD  CONSTRAINT [FK_Township_Province] FOREIGN KEY([IdProvince])
REFERENCES [dbo].[Province] ([IdProvince])
GO

ALTER TABLE [dbo].[Township] CHECK CONSTRAINT [FK_Township_Province]
GO


