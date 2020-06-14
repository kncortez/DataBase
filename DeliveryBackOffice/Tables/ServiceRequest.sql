USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[ServiceRequest]    Script Date: 3/06/2020 16:54:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ServiceRequest](
	[Messageid] [nvarchar](max) NULL,
	[Receiver_Name] [nvarchar](100) NOT NULL,
	[Receiver_Email] [nvarchar](200) NOT NULL,
	[PathReceivedFile] [nvarchar](100) NULL,
	[PathSticker] [nvarchar](100) NULL,
	[Status] [nvarchar](50) NOT NULL,
	[Receiver_Date] [datetime] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[Manifest_Serie] [nvarchar](2) NOT NULL,
	[Manifest_Number] [int] NOT NULL,
	[CustomerID] [int] NULL,
 CONSTRAINT [pk_manifest] PRIMARY KEY CLUSTERED 
(
	[Manifest_Serie] ASC,
	[Manifest_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[ServiceRequest]  WITH CHECK ADD  CONSTRAINT [FK_ServiceRequest_Customer] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customer] ([IdCustomer])
GO

ALTER TABLE [dbo].[ServiceRequest] CHECK CONSTRAINT [FK_ServiceRequest_Customer]
GO


