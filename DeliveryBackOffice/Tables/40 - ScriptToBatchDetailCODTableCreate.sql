USE [DeliveryBackOffice]
GO

BEGIN TRAN

/****** Object:  Table [dbo].[BatchDetailCOD]    Script Date: 23/06/2021 13:16:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BatchDetailCOD](
	[IdBatchDetailCOD] [int] IDENTITY(1,1) NOT NULL,
	[BatchCODId] [int] NOT NULL,
	[GuideSerie] [nvarchar](2) NOT NULL,
	[GuideNumber] [int] NOT NULL,
	[CatDebitAccountCODId] [int] NULL,
	[CreditAccountId] [int] NOT NULL,
	[CreditDate] [date] NOT NULL,
	[Amount] [decimal](18, 2) NOT NULL,
	[Commission] [decimal](18, 2) NOT NULL,
	[Reference] [int] NULL,
	[CatTransactionTypeCODId] [int] NULL,
	[CatCurrencyCODId] [int] NOT NULL,
	[BankId] [int] NOT NULL,
	[CatAccountTypeCODId] [int] NOT NULL,
	[CatConceptCODId] [int] NOT NULL,
	[Password] [int] NULL,
	[AuthorizationNumber] [nvarchar](50) NULL,
	[AuthorizationDate] [datetime] NULL,
	[Excluded] [bit] NOT NULL,
 CONSTRAINT [PK_BatchDetailCOD_IdBatchDetailCOD] PRIMARY KEY CLUSTERED 
(
	[IdBatchDetailCOD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_BatchDetailCOD_BatchCODId_GuideSerie_GuideNumber_CreditAccountId] UNIQUE NONCLUSTERED 
(
	[BatchCODId] ASC,
	[GuideSerie] ASC,
	[GuideNumber] ASC,
	[CreditAccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[BatchDetailCOD] ADD  CONSTRAINT [DF_BatchDetailCOD_CreditDate]  DEFAULT (getdate()) FOR [CreditDate]
GO

ALTER TABLE [dbo].[BatchDetailCOD] ADD  CONSTRAINT [DF_BatchDetailCOD_Amount]  DEFAULT ((0)) FOR [Amount]
GO

ALTER TABLE [dbo].[BatchDetailCOD] ADD  CONSTRAINT [DF_BatchDetailCOD_Commission]  DEFAULT ((0)) FOR [Commission]
GO

ALTER TABLE [dbo].[BatchDetailCOD] ADD  CONSTRAINT [DF_BatchDetailCOD_CatCurrencyCODId]  DEFAULT ((1)) FOR [CatCurrencyCODId]
GO

ALTER TABLE [dbo].[BatchDetailCOD] ADD  CONSTRAINT [DF_BatchDetailCOD_Password]  DEFAULT ((0)) FOR [Password]
GO

ALTER TABLE [dbo].[BatchDetailCOD] ADD  CONSTRAINT [DF_BatchDetailCOD_Excluded]  DEFAULT ('FALSE') FOR [Excluded]
GO

ALTER TABLE [dbo].[BatchDetailCOD]  WITH CHECK ADD  CONSTRAINT [FK_BatchDetailCOD_BatchCOD] FOREIGN KEY([BatchCODId])
REFERENCES [dbo].[BatchCOD] ([IdBatchCOD])
GO

ALTER TABLE [dbo].[BatchDetailCOD] CHECK CONSTRAINT [FK_BatchDetailCOD_BatchCOD]
GO

ALTER TABLE [dbo].[BatchDetailCOD]  WITH CHECK ADD  CONSTRAINT [FK_BatchDetailCOD_CatAccountTypeCOD] FOREIGN KEY([CatAccountTypeCODId])
REFERENCES [dbo].[CatAccountTypeCOD] ([IdCatAccountTypeCOD])
GO

ALTER TABLE [dbo].[BatchDetailCOD] CHECK CONSTRAINT [FK_BatchDetailCOD_CatAccountTypeCOD]
GO

ALTER TABLE [dbo].[BatchDetailCOD]  WITH CHECK ADD  CONSTRAINT [FK_BatchDetailCOD_CatConceptCOD] FOREIGN KEY([CatConceptCODId])
REFERENCES [dbo].[CatConceptCOD] ([IdCatConceptCOD])
GO

ALTER TABLE [dbo].[BatchDetailCOD] CHECK CONSTRAINT [FK_BatchDetailCOD_CatConceptCOD]
GO

ALTER TABLE [dbo].[BatchDetailCOD]  WITH CHECK ADD  CONSTRAINT [FK_BatchDetailCOD_CatCurrencyCOD] FOREIGN KEY([CatCurrencyCODId])
REFERENCES [dbo].[CatCurrencyCOD] ([IdCatCurrencyCOD])
GO

ALTER TABLE [dbo].[BatchDetailCOD] CHECK CONSTRAINT [FK_BatchDetailCOD_CatCurrencyCOD]
GO

ALTER TABLE [dbo].[BatchDetailCOD]  WITH CHECK ADD  CONSTRAINT [FK_BatchDetailCOD_CatDebitAccountCOD] FOREIGN KEY([CatDebitAccountCODId])
REFERENCES [dbo].[CatDebitAccountCOD] ([IdCatDebitAccountCOD])
GO

ALTER TABLE [dbo].[BatchDetailCOD] CHECK CONSTRAINT [FK_BatchDetailCOD_CatDebitAccountCOD]
GO

ALTER TABLE [dbo].[BatchDetailCOD]  WITH CHECK ADD  CONSTRAINT [FK_BatchDetailCOD_CatTransactionTypeCOD] FOREIGN KEY([CatTransactionTypeCODId])
REFERENCES [dbo].[CatTransactionTypeCOD] ([IdCatTransactionTypeCOD])
GO

ALTER TABLE [dbo].[BatchDetailCOD] CHECK CONSTRAINT [FK_BatchDetailCOD_CatTransactionTypeCOD]
GO

ALTER TABLE [dbo].[BatchDetailCOD]  WITH CHECK ADD  CONSTRAINT [FK_BatchDetailCOD_DeliveryBank] FOREIGN KEY([BankId])
REFERENCES [dbo].[DeliveryBank] ([Id_bank])
GO

ALTER TABLE [dbo].[BatchDetailCOD] CHECK CONSTRAINT [FK_BatchDetailCOD_DeliveryBank]
GO

ALTER TABLE [dbo].[BatchDetailCOD]  WITH CHECK ADD  CONSTRAINT [FK_BatchDetailCOD_DeliveryCustomerBankAccount] FOREIGN KEY([CreditAccountId])
REFERENCES [dbo].[DeliveryCustomerBankAccount] ([DCBA_Id])
GO

ALTER TABLE [dbo].[BatchDetailCOD] CHECK CONSTRAINT [FK_BatchDetailCOD_DeliveryCustomerBankAccount]
GO

ALTER TABLE [dbo].[BatchDetailCOD]  WITH CHECK ADD  CONSTRAINT [FK_BatchDetailCOD_DeliveryOrder] FOREIGN KEY([GuideSerie], [GuideNumber])
REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
GO

ALTER TABLE [dbo].[BatchDetailCOD] CHECK CONSTRAINT [FK_BatchDetailCOD_DeliveryOrder]
GO

--COMMIT


