USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[SenderReceiver]    Script Date: 31/07/2020 11:49:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SenderReceiver](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[First_Name] [nvarchar](100) NOT NULL,
	[Last_Name] [nvarchar](100) NOT NULL,
	[Address] [nvarchar](200) NOT NULL,
	[Zone] [nvarchar](100) NULL,
	[Town] [nvarchar](100) NOT NULL,
	[Department] [nvarchar](100) NOT NULL,
	[Phone] [nvarchar](50) NOT NULL,
	[Social_Security_ID] [nvarchar](200) NULL,
	[Email] [nvarchar](200) NULL,
	[CUI] [nvarchar](25) NULL,
	[Latitude] [nvarchar](40) NULL,
	[Longitude] [nvarchar](40) NULL,
	[Entity_Type] [tinyint] NOT NULL,
	[User_Created] [nvarchar](50) NOT NULL,
	[Date_Created] [datetime] NOT NULL,
 CONSTRAINT [PK_SenderReceiver] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE SenderReceiver ADD CONSTRAINT UC_CUI UNIQUE (CUI)