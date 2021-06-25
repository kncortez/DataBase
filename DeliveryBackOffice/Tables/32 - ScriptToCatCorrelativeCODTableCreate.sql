USE [DeliveryBackOffice]
GO

BEGIN TRAN

/****** Object:  Table [dbo].[CatCorrelativeCOD]    Script Date: 23/06/2021 08:36:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatCorrelativeCOD](
	[IdCatCorrelativeCOD] [int] IDENTITY(1,1) NOT NULL,
	[Begin] [int] NOT NULL,
	[End] [int] NOT NULL,
	[Last] [int] NOT NULL,
	[BankId] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatCorrelativeCOD_IdCatCorrelativeCOD] PRIMARY KEY CLUSTERED 
(
	[IdCatCorrelativeCOD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_CatCorrelativeCOD_Begin_End_BankId] UNIQUE NONCLUSTERED 
(
	[Begin] ASC,
	[End] ASC,
	[BankId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatCorrelativeCOD] ADD  CONSTRAINT [DF_CatCorrelativeCOD_Begin]  DEFAULT ((1)) FOR [Begin]
GO

ALTER TABLE [dbo].[CatCorrelativeCOD] ADD  CONSTRAINT [DF_CatCorrelativeCOD_Last]  DEFAULT ((1)) FOR [Last]
GO

ALTER TABLE [dbo].[CatCorrelativeCOD] ADD  CONSTRAINT [DF_CatCorrelativeCOD_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

ALTER TABLE [dbo].[CatCorrelativeCOD] ADD  CONSTRAINT [DF_CatCorrelativeCOD_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

ALTER TABLE [dbo].[CatCorrelativeCOD]  WITH CHECK ADD  CONSTRAINT [FK_CatCorrelativeCOD_DeliveryBank] FOREIGN KEY([BankId])
REFERENCES [dbo].[DeliveryBank] ([Id_bank])
GO

ALTER TABLE [dbo].[CatCorrelativeCOD] CHECK CONSTRAINT [FK_CatCorrelativeCOD_DeliveryBank]
GO

--COMMIT


