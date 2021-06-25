USE [DeliveryBackOffice]
GO

BEGIN TRAN

/****** Object:  Table [dbo].[CatEmailProcessCOD]    Script Date: 15/06/2021 09:44:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatEmailProcessCOD](
	[IdCatEmailProcessCOD] [int] IDENTITY(1,1) NOT NULL,
	[CatReceiverEmailCODId] [int] NOT NULL,
	[CatProcessCODId] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatEmailProcessCOD_IdCatEmailProcessCOD] PRIMARY KEY CLUSTERED 
(
	[IdCatEmailProcessCOD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_CatEmailProcessCOD_CatProcessCODId_CatReceiverEmailCODId] UNIQUE NONCLUSTERED 
(
	[CatProcessCODId] ASC,
	[CatReceiverEmailCODId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatEmailProcessCOD] ADD  CONSTRAINT [DF_CatEmailProcessCOD_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

ALTER TABLE [dbo].[CatEmailProcessCOD] ADD  CONSTRAINT [DF_CatEmailProcessCOD_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

ALTER TABLE [dbo].[CatEmailProcessCOD]  WITH CHECK ADD  CONSTRAINT [FK_CatEmailProcessCOD_CatProcessCOD] FOREIGN KEY([CatProcessCODId])
REFERENCES [dbo].[CatProcessCOD] ([IdCatProcessCOD])
GO

ALTER TABLE [dbo].[CatEmailProcessCOD] CHECK CONSTRAINT [FK_CatEmailProcessCOD_CatProcessCOD]
GO

ALTER TABLE [dbo].[CatEmailProcessCOD]  WITH CHECK ADD  CONSTRAINT [FK_CatEmailProcessCOD_CatReceiverEmailCOD] FOREIGN KEY([CatReceiverEmailCODId])
REFERENCES [dbo].[CatReceiverEmailCOD] ([IdCatReceiverEmailCOD])
GO

ALTER TABLE [dbo].[CatEmailProcessCOD] CHECK CONSTRAINT [FK_CatEmailProcessCOD_CatReceiverEmailCOD]
GO

--COMMIT


