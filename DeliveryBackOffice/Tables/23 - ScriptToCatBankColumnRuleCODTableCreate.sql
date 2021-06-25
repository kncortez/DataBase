USE [DeliveryBackOffice]
GO

BEGIN TRAN

/****** Object:  Table [dbo].[CatBankColumnRuleCOD]    Script Date: 15/06/2021 15:35:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatBankColumnRuleCOD](
	[IdCatBankColumnRuleCOD] [int] IDENTITY(1,1) NOT NULL,
	[CatBankColumnCODId] [int] NOT NULL,
	[CatRuleCODId] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatBankColumnRuleCOD_IdCatBankColumnRuleCOD] PRIMARY KEY CLUSTERED 
(
	[IdCatBankColumnRuleCOD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_CatBankColumnRuleCOD_CatBankColumnCODId_CatRuleCODId] UNIQUE NONCLUSTERED 
(
	[CatBankColumnCODId] ASC,
	[CatRuleCODId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatBankColumnRuleCOD] ADD  CONSTRAINT [DF_CatBankColumnRuleCOD_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

ALTER TABLE [dbo].[CatBankColumnRuleCOD] ADD  CONSTRAINT [DF_CatBankColumnRuleCOD_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

ALTER TABLE [dbo].[CatBankColumnRuleCOD]  WITH CHECK ADD  CONSTRAINT [FK_CatBankColumnRuleCOD_CatBankColumnCOD] FOREIGN KEY([CatBankColumnCODId])
REFERENCES [dbo].[CatBankColumnCOD] ([IdCatBankColumnCOD])
GO

ALTER TABLE [dbo].[CatBankColumnRuleCOD] CHECK CONSTRAINT [FK_CatBankColumnRuleCOD_CatBankColumnCOD]
GO

ALTER TABLE [dbo].[CatBankColumnRuleCOD]  WITH CHECK ADD  CONSTRAINT [FK_CatBankColumnRuleCOD_CatRuleCOD] FOREIGN KEY([CatRuleCODId])
REFERENCES [dbo].[CatRuleCOD] ([IdCatRuleCOD])
GO

ALTER TABLE [dbo].[CatBankColumnRuleCOD] CHECK CONSTRAINT [FK_CatBankColumnRuleCOD_CatRuleCOD]
GO

--COMMIT


