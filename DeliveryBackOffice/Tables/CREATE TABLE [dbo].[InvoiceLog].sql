USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
	Tabla para poder llevar registro de las facturas que se envían a SAP,
	para poder tener la información enviada y recibida.
*/

CREATE TABLE [dbo].[InvoiceLog](
	[InvoiceLogId] [bigint] IDENTITY(1,1) NOT NULL,
	[InvIdRestriction] [bigint] NOT NULL,
	[inv_pk_id] BIGINT NOT NULL,
	[inv_DataSent] [nvarchar](max) NULL,
	[inv_DataReceived] [nvarchar](max) NULL,
	[ErrorDesc] [nvarchar](max) NULL,
	[Date] [datetime] NOT NULL,
	[TransactionStatus] [int] NULL, -- 1 ENVIADO A SAP ; 0 PENDIENTE DE ENVÍO
PRIMARY KEY CLUSTERED 
(
	[InvoiceLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[InvoiceLog]  WITH CHECK ADD  CONSTRAINT [FKIRestrictionInvoiceLog] FOREIGN KEY([InvIdRestriction])
REFERENCES [dbo].[InvoiceRestriction] ([InvIdRestriction])
GO


