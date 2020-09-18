USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[DeliveryOrderPaid]    Script Date: 9/18/2020 4:25:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DeliveryOrderPaid](
	[IdDeliveryOrderPaid] [bigint] IDENTITY(1,1) NOT NULL,
	[Guide_Serie] [nvarchar](2) NULL,
	[Guide_Number] [int] NULL,
	[Deposit_Number] [nvarchar](50) NULL,
	[IsVirtualDeposit] [bit] NULL,
	[IdStatus] [bit] NULL,
	[TokenCreated] [nvarchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[TokenUpdate] [nvarchar](50) NULL,
	[DateUpdate] [datetime] NULL,
 CONSTRAINT [PK_DeliveryOrderPaid] PRIMARY KEY CLUSTERED 
(
	[IdDeliveryOrderPaid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DeliveryOrderPaid] ADD  CONSTRAINT [DF_DeliveryOrderPaid_IsVirtualDeposit]  DEFAULT ('TRUE') FOR [IsVirtualDeposit]
GO

ALTER TABLE [dbo].[DeliveryOrderPaid] ADD  CONSTRAINT [DF_DeliveryOrderPaid_IdStatus]  DEFAULT ('TRUE') FOR [IdStatus]
GO

ALTER TABLE [dbo].[DeliveryOrderPaid]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryOrderPaid_DeliveryOrder] FOREIGN KEY([Guide_Serie], [Guide_Number])
REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
GO

ALTER TABLE [dbo].[DeliveryOrderPaid] CHECK CONSTRAINT [FK_DeliveryOrderPaid_DeliveryOrder]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 electronic 0 manual' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderPaid', @level2type=N'COLUMN',@level2name=N'IsVirtualDeposit'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 Paid 0 UnPaid' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DeliveryOrderPaid', @level2type=N'COLUMN',@level2name=N'IdStatus'
GO


