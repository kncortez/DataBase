USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[ctg_statusInvoice]    Script Date: 23/10/2020 6:44:50 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ctg_statusInvoice](
	[ist_pk_id] [int] NOT NULL,
	[ist_nombre] [varchar](50) NOT NULL,
	[ist_descripcion] [varchar](1000) NOT NULL,
	[ist_dateInsert] [datetime] NOT NULL,
	[ist_tokenInsert] [varchar](50) NOT NULL,
	[ist_dateUpdate] [datetime] NULL,
	[ist_tokenUpdate] [varchar](50) NULL,
 CONSTRAINT [PK_ctg_statusInvoice] PRIMARY KEY CLUSTERED 
(
	[ist_pk_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


