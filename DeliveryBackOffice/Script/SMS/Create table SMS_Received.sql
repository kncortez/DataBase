USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[SMS_Received]    Script Date: 31/08/2020 12:14:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SMS_Received](
	[SMS_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SMS_Message_ID] [bigint] NOT NULL,
	[SMS_Message] [nvarchar](500) NOT NULL,
	[SMS_MSisdn] [nvarchar](50) NOT NULL,
	[SMS_Short_Number] [nvarchar](50) NOT NULL,
	[SMS_Type] [nvarchar](50) NOT NULL,
	[SMS_Status] [nvarchar](50) NOT NULL,
	[SMS_Datetime] [datetime] NOT NULL,
	[SMS_Row_Status] [bit] NOT NULL,
	[SMS_TokenCreated] [nvarchar](50) NOT NULL,
	[SMS_TokenCreatedDatetime] [datetime] NOT NULL,
	[SMS_TokenUpdate] [nvarchar](50) NULL,
	[SMS_TokenUpdateDatetime] [datetime] NULL,
 CONSTRAINT [PK_SMS_Received] PRIMARY KEY CLUSTERED 
(
	[SMS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SMS_Received] ADD  CONSTRAINT [DF_SMS_Received_SMS_Row_Status]  DEFAULT ((1)) FOR [SMS_Row_Status]
GO


