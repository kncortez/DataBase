USE [DeliveryBackOffice]
GO

BEGIN TRAN

/****** Object:  Table [dbo].[CatDebitAccountCOD]    Script Date: 22/06/2021 23:43:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatDebitAccountCOD](
	[IdCatDebitAccountCOD] [int] IDENTITY(1,1) NOT NULL,
	[AccountNumber] [nvarchar](50) NOT NULL,
	[BankId] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatDebitAccountCOD_IdCatDebitAccountCOD] PRIMARY KEY CLUSTERED 
(
	[IdCatDebitAccountCOD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_CatDebitAccountCOD_AccountNumber] UNIQUE NONCLUSTERED 
(
	[AccountNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatDebitAccountCOD] ADD  CONSTRAINT [DF_CatDebitAccountCOD_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

ALTER TABLE [dbo].[CatDebitAccountCOD] ADD  CONSTRAINT [DF_CatDebitAccountCOD_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

ALTER TABLE [dbo].[CatDebitAccountCOD]  WITH CHECK ADD  CONSTRAINT [FK_CatDebitAccountCOD_DeliveryBank] FOREIGN KEY([BankId])
REFERENCES [dbo].[DeliveryBank] ([Id_bank])
GO

ALTER TABLE [dbo].[CatDebitAccountCOD] CHECK CONSTRAINT [FK_CatDebitAccountCOD_DeliveryBank]
GO

--COMMIT


