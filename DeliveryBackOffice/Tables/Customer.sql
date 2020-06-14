USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[Customer]    Script Date: 3/06/2020 16:45:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Customer](
	[IdCustomer] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](100) NULL,
	[Domain] [nvarchar](50) NOT NULL,
	[RegexSubject] [nvarchar](100) NOT NULL,
	[RegexEmail] [nvarchar](100) NOT NULL,
	[RegexFilename] [nvarchar](100) NOT NULL,
	[Abbreviation] [nvarchar](25) NOT NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[IdCustomer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


