USE [DeliveryBackOffice]
GO

BEGIN TRAN

/****** Object:  Table [dbo].[CatBankColumnCOD]    Script Date: 15/06/2021 13:39:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatBankColumnCOD](
	[IdCatBankColumnCOD] [int] IDENTITY(1,1) NOT NULL,
	[BankId] [int] NOT NULL,
	[CatColumnCODId] [int] NOT NULL,
	[Order] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatBankColumnCOD_IdCatBankColumnCOD] PRIMARY KEY CLUSTERED 
(
	[IdCatBankColumnCOD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_CatBankColumnCOD_BankId_CatColumnCODId] UNIQUE NONCLUSTERED 
(
	[BankId] ASC,
	[CatColumnCODId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatBankColumnCOD] ADD  CONSTRAINT [DF_CatBankColumnCOD_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

ALTER TABLE [dbo].[CatBankColumnCOD] ADD  CONSTRAINT [DF_CatBankColumnCOD_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

ALTER TABLE [dbo].[CatBankColumnCOD]  WITH CHECK ADD  CONSTRAINT [FK_CatBankColumnCOD_CatColumnCOD] FOREIGN KEY([CatColumnCODId])
REFERENCES [dbo].[CatColumnCOD] ([IdCatColumnCOD])
GO

ALTER TABLE [dbo].[CatBankColumnCOD] CHECK CONSTRAINT [FK_CatBankColumnCOD_CatColumnCOD]
GO

ALTER TABLE [dbo].[CatBankColumnCOD]  WITH CHECK ADD  CONSTRAINT [FK_CatBankColumnCOD_DeliveryBank] FOREIGN KEY([BankId])
REFERENCES [dbo].[DeliveryBank] ([Id_bank])
GO

ALTER TABLE [dbo].[CatBankColumnCOD] CHECK CONSTRAINT [FK_CatBankColumnCOD_DeliveryBank]
GO

--COMMIT


