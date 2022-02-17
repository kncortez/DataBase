USE [DeliveryBackOffice]
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[InvoiceRestriction](
	[InvIdRestriction] [bigint] IDENTITY(1,1) NOT NULL,
	[inv_pk_id] [bigint] NOT NULL,
	[inv_SAPDocEntry] [int] NOT NULL,
	[invRetries] [int] NOT NULL,
	[invRowStatus] [bit] NOT NULL,
	[invTokenCreated] [varchar](50) NOT NULL,
	[invDateCreated] [datetime] NOT NULL,
	[invOperationDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[InvIdRestriction] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[InvoiceRestriction]  WITH CHECK ADD  CONSTRAINT [FKInvoiceHeader] FOREIGN KEY([inv_pk_id])
REFERENCES [dbo].[invoiceHeader] ([inv_pk_id])
GO




