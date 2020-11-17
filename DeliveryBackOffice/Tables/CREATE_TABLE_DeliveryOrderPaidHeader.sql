USE [DeliveryBackOffice]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DeliveryOrderPaidHeader](
	[IdDeliveryOrderPaid] [bigint] IDENTITY(1,1) NOT NULL,
	[Manifest_Date] [datetime] NULL,
	[Manifest_Serie] [nvarchar](5) NULL,
	[Manifest_Number] [bigint],
	[IdStatus] [bit] NULL
 CONSTRAINT [PK_DeliveryOrderPaidHeader] PRIMARY KEY CLUSTERED 
(
	[IdDeliveryOrderPaid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

