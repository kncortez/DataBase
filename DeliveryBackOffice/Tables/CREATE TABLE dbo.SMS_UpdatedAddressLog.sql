USE [DeliveryBackOffice]
GO
CREATE TABLE [dbo].[SMS_UpdatedAddressLog](
	[UpdatedAddressId] [int] IDENTITY(1,1) NOT NULL,
	[GuideSerie] [nvarchar](2) NOT NULL,
	[GuideNumber] int NOT NULL,		
	[OriginalAddress] [nvarchar](200) NULL,
	[UpdatedAddress] [nvarchar](200) NULL,
	[NameReceiver] [nvarchar](200) NULL,	
	[PhoneReceiver] [nvarchar](100) NULL,
	[Token] [nvarchar](50) NULL,
	[DateCreated] [datetime] NULL,	
 CONSTRAINT [PK_SMS_UpdatedAddressLog] PRIMARY KEY CLUSTERED 
(
	[UpdatedAddressId] ASC
),
 CONSTRAINT FK_SMS_UpdatedAddressLog FOREIGN KEY (GuideSerie,GuideNumber)
    REFERENCES DeliveryOrder(Guide_Serie,Guide_Number)
)