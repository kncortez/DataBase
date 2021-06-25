USE [DeliveryBackOffice]
GO

BEGIN TRAN

/****** Object:  Table [dbo].[CatTransactionTypeCOD]    Script Date: 23/06/2021 09:32:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatTransactionTypeCOD](
	[IdCatTransactionTypeCOD] [int] IDENTITY(1,1) NOT NULL,
	[TransactionType] [nvarchar](10) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[BankId] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatTransactionTypeCOD_IdCatTransactionTypeCOD] PRIMARY KEY CLUSTERED 
(
	[IdCatTransactionTypeCOD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_CatTransactionTypeCOD_TransactionType_BankId] UNIQUE NONCLUSTERED 
(
	[TransactionType] ASC,
	[BankId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatTransactionTypeCOD] ADD  CONSTRAINT [DF_CatTransactionTypeCOD_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

ALTER TABLE [dbo].[CatTransactionTypeCOD] ADD  CONSTRAINT [DF_CatTransactionTypeCOD_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

ALTER TABLE [dbo].[CatTransactionTypeCOD]  WITH CHECK ADD  CONSTRAINT [FK_CatTransactionTypeCOD_DeliveryBank] FOREIGN KEY([BankId])
REFERENCES [dbo].[DeliveryBank] ([Id_bank])
GO

ALTER TABLE [dbo].[CatTransactionTypeCOD] CHECK CONSTRAINT [FK_CatTransactionTypeCOD_DeliveryBank]
GO

--COMMIT


