USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[SMS_UpdatedAddressLog]    Script Date: 9/12/2020 18:44:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SMS_UpdatedAddressLog](
	[UpdatedAddressId] [int] IDENTITY(1,1) NOT NULL,
	[GuideSerie] [nvarchar](2) NOT NULL,
	[GuideNumber] [int] NOT NULL,
	[OriginalAddress] [nvarchar](200) NULL,
	[UpdatedAddress] [nvarchar](200) NULL,
	[NameReceiver] [nvarchar](200) NULL,
	[PhoneReceiver] [nvarchar](100) NULL,
	[Token] [nvarchar](50) NULL,
	[DateCreated] [datetime] NULL,
 CONSTRAINT [PK_SMS_UpdatedAddressLog] PRIMARY KEY CLUSTERED 
(
	[UpdatedAddressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SMS_UpdatedAddressLog]  WITH CHECK ADD  CONSTRAINT [FK_SMS_UpdatedAddressLog] FOREIGN KEY([GuideSerie], [GuideNumber])
REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
GO

ALTER TABLE [dbo].[SMS_UpdatedAddressLog] CHECK CONSTRAINT [FK_SMS_UpdatedAddressLog]
GO


