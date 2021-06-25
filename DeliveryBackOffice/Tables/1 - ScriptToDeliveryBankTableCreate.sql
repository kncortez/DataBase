USE [DeliveryBackOffice]
GO

BEGIN TRAN

/****** Object:  Table [dbo].[DeliveryBank]    Script Date: 9/06/2021 09:27:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DeliveryBank](
	[Id_bank] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Acronym] [nvarchar](15) NULL,
	[Description] [nvarchar](255) NULL,
	[create_date] [datetime] NOT NULL,
	[Id_status] [int] NOT NULL,
	[Id_country] [nvarchar](2) NOT NULL,
	[URL_logo] [text] NULL,
	[CardCode] [nvarchar](50) NULL,
	[ACHCode] [int] NULL,
	[PayingBank] [int] NULL,
 CONSTRAINT [PK_SP_DEPOSITOS_BANCOS] PRIMARY KEY CLUSTERED 
(
	[Id_bank] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[DeliveryBank] ADD  CONSTRAINT [DF_DeliveryBank_PayingBank]  DEFAULT ((31)) FOR [PayingBank]
GO

ALTER TABLE [dbo].[DeliveryBank]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryBank_IdBank_PayingBank] FOREIGN KEY([PayingBank])
REFERENCES [dbo].[DeliveryBank] ([Id_bank])
GO

ALTER TABLE [dbo].[DeliveryBank] CHECK CONSTRAINT [FK_DeliveryBank_IdBank_PayingBank]
GO

--COMMIT

