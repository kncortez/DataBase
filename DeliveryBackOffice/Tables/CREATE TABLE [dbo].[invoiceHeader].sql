USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[invoiceHeader]    Script Date: 12/10/2020 00:10:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[invoiceHeader](
	[inv_pk_id] [bigint] IDENTITY(1,1) NOT NULL,
	[inv_cmp_name] [varchar](500) NOT NULL,
	[inv_cmp_adress] [varchar](1000) NOT NULL,
	[inv_cmp_nit] [varchar](100) NOT NULL,
	[inv_cli_name] [varchar](500) NOT NULL,
	[inv_cli_adress] [varchar](1000) NOT NULL,
	[inv_cli_nit] [varchar](100) NOT NULL,
	[inv_cli_email] [varchar](500) NOT NULL,
	[inv_date] [datetime] NOT NULL,
	[inv_tickets] [varchar](500) NULL,
	[inv_documentSend] [varchar](max) NULL,
	[inv_documentRecieved] [varchar](max) NULL,
	[inv_certificationFEL] [varchar](200) NULL,
	[inv_serieFEL] [varchar](200) NULL,
	[inv_numberFEL] [varchar](50) NULL,
	[inv_descriptionFEL] [varchar](500) NULL,
	[inv_RequestorFEL] [varchar](250) NULL,
	[inv_TransactionFEL] [varchar](100) NULL,
	[inv_CountryFEL] [varchar](4) NULL,
	[inv_EntityFEL] [varchar](50) NULL,
	[inv_UserFEL] [varchar](150) NULL,
	[inv_UserName] [varchar](150) NULL,
	[inv_Data1FEL] [varchar](150) NULL,
	[inv_Data3FEL] [varchar](150) NULL,
	[inv_MailSendFEL] [varchar](150) NULL,
	[inv_subjectFEL] [varchar](150) NULL,
	[inv_IVA] [money] NULL,
	[inv_amount] [money] NULL,
	[inv_status] [int] NOT NULL,
	[inv_dateRegister] [datetime] NOT NULL,
	[inv_tokenRegister] [varchar](200) NOT NULL,
	[inv_dateUpdate] [datetime] NULL,
	[inv_tokenUpdate] [varchar](200) NULL,
 CONSTRAINT [PK_invoiceHeader] PRIMARY KEY CLUSTERED 
(
	[inv_pk_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


