USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[SMS_Sent]    Script Date: 18/09/2020 11:10:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SMS_Sent](
	[Sent_Id] [int] IDENTITY(1,1) NOT NULL,
	[Sent_Guide_Series] [nvarchar](50) NOT NULL,
	[Sent_Guide_Number] [int] NOT NULL,
	[Sent] [bit] NOT NULL,
	[Sent_Batch_Id] [bigint] NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[CreatedDatetime] [datetime] NOT NULL,
	[TokenUpdate] [nvarchar](50) NULL,
	[UpdatedDatetime] [datetime] NULL,
 CONSTRAINT [PK_SMS_Sent] PRIMARY KEY CLUSTERED 
(
	[Sent_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SMS_Sent] ADD  CONSTRAINT [DF_SMS_Sent_Sent]  DEFAULT ((0)) FOR [Sent]
GO

ALTER TABLE [dbo].[SMS_Sent] ADD  CONSTRAINT [DF_SMS_Sent_RowStatus]  DEFAULT ((1)) FOR [RowStatus]
GO


