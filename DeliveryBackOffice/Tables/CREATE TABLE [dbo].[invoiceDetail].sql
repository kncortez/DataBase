USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[invoiceDetail]    Script Date: 12/10/2020 00:11:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[invoiceDetail](
	[dti_fk_header] [bigint] NOT NULL,
	[dti_fk_orderSerie] [nvarchar](2) NULL,
	[dti_fk_orderNumber] [int] NULL,
	[dti_identification] [varchar](200) NULL,
	[dti_category] [varchar](50) NOT NULL,
	[dti_quantity] [decimal](10, 5) NOT NULL,
	[dti_measurement] [varchar](20) NULL,
	[dti_priceUnit] [money] NOT NULL,
	[dti_description] [varchar](max) NOT NULL,
	[dti_IVA] [money] NULL,
	[dti_amount] [money] NOT NULL,
	[dti_dateRegister] [datetime] NOT NULL,
	[dti_tokenRegister] [varchar](200) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


