USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[SMS_UpdatedElements]    Script Date: 14/09/2020 14:30:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SMS_UpdatedElements](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UpdateStatus] [bit] NOT NULL,
	[ElementId] [int] NOT NULL,
	[ElementName] [nvarchar](300) NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[Token] [nvarchar](50) NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_SMS_UpdatedElements] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SMS_UpdatedElements] ADD  CONSTRAINT [DF_SMS_UpdatedElements_UpdateStatus]  DEFAULT ((1)) FOR [UpdateStatus]
GO

ALTER TABLE [dbo].[SMS_UpdatedElements] ADD  CONSTRAINT [DF_SMS_UpdatedElements_RowStatus]  DEFAULT ((1)) FOR [RowStatus]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1=There is an update ; 0=No updates' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SMS_UpdatedElements', @level2type=N'COLUMN',@level2name=N'UpdateStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id starting at 10001' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SMS_UpdatedElements', @level2type=N'COLUMN',@level2name=N'ElementId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Element Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SMS_UpdatedElements', @level2type=N'COLUMN',@level2name=N'ElementName'
GO


